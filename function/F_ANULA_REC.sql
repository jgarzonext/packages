--------------------------------------------------------
--  DDL for Function F_ANULA_REC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_ANULA_REC" (
   pnrecibo IN NUMBER,
   pfanulac IN DATE,
   pcmotanul IN NUMBER DEFAULT 0,
   psmovagr IN NUMBER DEFAULT NULL)
   RETURN NUMBER AUTHID CURRENT_USER IS
/***********************************************************************************************************
      F_ANULA_REC. Funci¿n que anula un recibo.
     pnrecibo: Recibo que queremos anular
  pfanulac: Fecha de efecto de anulacion del recibo
  pcmotanul: Motivo de anulaci¿n. 0.- Anulaci¿n de p¿liza
                                  1.- Anulaci¿n por reemplazo.
                           Por defecto 0.- Anulaci¿n de p¿liza.
    psmovagr: agrupaci¿n de recibos por remesa. Si es null se incrementa la secuencia
**********************************************************************************************************/

   /******************************************************************************
      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        --/--/----   ---               1. Creación del package.
      2.0        26/09/2012   JGR               2. 0022346: LCOL_A003-Cobro parcial de los recibos Fase 2
      3.0        17/10/2012   JGR               3. 0022346: LCOL_A003-Cobro parcial de los recibos Fase 2 - 0126249
      4.0        27/02/2013   ECP               4. 0026070: LCOL_T010-LCOL - Revision incidencias qtracker (V). Nota 139289
      5.0        26/07/2013   MMM               5. 0027723: LCOL_A003-Una poliza que esta domiciliada o en tramite de respuesta no se debe modificar
      6.0        26/01/2016   FAL               6. 0039682: Extornos agrupados no se anulan cuando se anula el recibo agrupador
   ******************************************************************************/
   num_err        NUMBER;
   ccdelega       NUMBER;
   ccempres       NUMBER;
   v_fmovini      DATE;
   v_cestrec      NUMBER;
   v_cestant      NUMBER;
   ffanularec     DATE;
   v_smovagr      NUMBER;
   nnliqmen       NUMBER;
   nnliqlin       NUMBER;
   -- Bug 9383 - 06/03/2009 - RSC - CRE: Unificación de recibos
   vcramo         seguros.cramo%TYPE;
   vcmodali       seguros.cmodali%TYPE;
   vctipseg       seguros.ctipseg%TYPE;
   vccolect       seguros.ccolect%TYPE;
   vcountagrp     NUMBER;
-- Fin Bug 9383
   -- 2. 0022346: LCOL_A003-Cobro parcial de los recibos Fase 2 - Inicio
   v_rec_parc     NUMBER
                       := pac_adm_cobparcial.f_get_importe_cobro_parcial(pnrecibo, NULL, NULL);
   vfanulac       DATE;
-- 2. 0022346: LCOL_A003-Cobro parcial de los recibos Fase 2 - Fin
   v_estimp       recibos.cestimp%TYPE;   -- 5. 0027723: LCOL_A003-Una poliza que esta domiciliada o en tramite de respuesta no se debe modificar
   ffanularec_hijo DATE;   -- BUG 0039682 - FAL - 26/01/2016
BEGIN
   BEGIN
      SELECT cdelega, cempres,
             cestimp   -- 5. 0027723: LCOL_A003-Una poliza que esta domiciliada o en tramite de respuesta no se debe modificar
        INTO ccdelega, ccempres,
             v_estimp   -- 5. 0027723: LCOL_A003-Una poliza que esta domiciliada o en tramite de respuesta no se debe modificar
        FROM recibos
       WHERE nrecibo = pnrecibo;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 112614;   --{rebut no trobat a la llista de rebuts}
   END;

   -- 5. 0027723: LCOL_A003-Una poliza que esta domiciliada o en tramite de respuesta no se debe modificar -  Inicio
   IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(), 'NO_ANUL_SI_DOMIS'),
          0) = 1
      AND v_estimp = 5 THEN
      RETURN 9903191;
   END IF;

   -- 5. 0027723: LCOL_A003-Una poliza que esta domiciliada o en tramite de respuesta no se debe modificar -  Fin
   BEGIN
      SELECT fmovini, cestrec, cestant
        INTO v_fmovini, v_cestrec, v_cestant
        FROM movrecibo
       WHERE nrecibo = pnrecibo
         AND fmovfin IS NULL;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 104939;   -- recibo no encontrado en la tabla MOVRECIBO
   END;

   -- Bug 0017970 - 01/04/2011 - JMF
   IF v_cestrec NOT IN(0, 3) THEN
      RETURN 101126;   -- El recibo no est¿endente de cobro
   END IF;

   -- MSR 19/06/2007 Ref 1880.
   IF psmovagr IS NULL THEN
      SELECT smovagr.NEXTVAL
        INTO v_smovagr
        FROM DUAL;
   ELSE
      v_smovagr := psmovagr;
   END IF;

   /*
   {
    La fecha de efecto de la anulaci¿n del recibo, para que sea coherente con las ventas ser¿    1.- La de la anulaci¿n de la p¿liza si se anula con fecha futura.
      2.- La del dia si no estamos en el tiempo a¿adido de un mes no cerrado.
      3.- La del ¿ltimo dia del mes de ventas abierto , si estamos en en el tiempo a¿adido de un mes no cerrado.
     Y siempre se tendr¿n cuenta que no puede ser anterior al ¿ltimo movimiento
    }
   */
   IF pfanulac >= TRUNC(f_sysdate) THEN
      ffanularec := pfanulac;
   ELSE
      SELECT LAST_DAY(ADD_MONTHS(MAX(fperini), 1))
        INTO ffanularec
        FROM cierres
       WHERE ctipo = 1
         AND cestado = 1
         AND cempres = ccempres;

      IF TRUNC(f_sysdate) < ffanularec THEN
         ffanularec := TRUNC(f_sysdate);
      END IF;
   END IF;

   IF ffanularec < v_fmovini
      OR ffanularec IS NULL THEN
      ffanularec := v_fmovini;
   END IF;

   -- Bug 9383 - 06/03/2009 - RSC - CRE: Unificación de recibos
   -- El cobro del recibo agrupado debe dejar los recibos pequeñitos en estado cobrado
   BEGIN
      SELECT s.cramo, s.cmodali, s.ctipseg, s.ccolect
        INTO vcramo, vcmodali, vctipseg, vccolect
        FROM recibos r, seguros s
       WHERE r.nrecibo = pnrecibo
         AND r.sseguro = s.sseguro;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'F_ANULA_REC', 1,
                     'Error al buscar datos del recibo: ' || pnrecibo, SQLERRM);
         RETURN 101731;
   END;

   IF NVL(f_parproductos_v(f_sproduc_ret(vcramo, vcmodali, vctipseg, vccolect), 'RECUNIF'), 0) IN
                                                                                         (1, 3) THEN   -- = 1 THEN -- BUG 0019627: GIP102 - Reunificación de recibos - FAL - 10/11/2011
      /*******************************************
       No se puede anular un recibo pequeñito que
       pertenezca a una agrupación de recibos.
      ********************************************/
      SELECT COUNT(*)
        INTO vcountagrp
        FROM adm_recunif
       WHERE nrecibo = pnrecibo;

      IF vcountagrp > 0 THEN
         p_tab_error(f_sysdate, f_user, 'F_ANULA_REC', 2,
                     f_axis_literales(9001160, f_idiomauser), SQLERRM);
         RETURN 9001160;
      END IF;
   END IF;

   -- 2. 0022346: LCOL_A003-Cobro parcial de los recibos Fase 2 - Inicio
   IF v_rec_parc > 0 THEN
      vfanulac := pfanulac;
      -- Todas las acciones a realizar con la anulación de recibos parciales
      num_err := pac_adm_cobparcial.f_anula_rec(pnrecibo, pfanulac, v_smovagr,
                                                1   -- 3. 0022346 - 0126249 (+)
                                                 );

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;
   ELSE
      -- 2. 0022346: LCOL_A003-Cobro parcial de los recibos Fase 2 - Fin
         -- Fin Bug 9383
      -- Ini Bug 26070 -- ECP -- 27/02/2013
      --IF NVL(f_parproductos_v(f_sproduc_ret(vcramo, vcmodali, vctipseg, vccolect), 'RECUNIF'),
      --       0) = 2 THEN
         -- Si se anula un recibo agrupado entrará en LOOP
      FOR v_recind IN (SELECT nrecibo
                         FROM adm_recunif a
                        WHERE nrecunif = pnrecibo
                          AND nrecibo <> pnrecibo) LOOP
         -- BUG 0039682 - FAL - 26/01/2016 - Calcula fecha anulación para cada recibo hijo
         BEGIN
            SELECT fmovini
              INTO v_fmovini
              FROM movrecibo
             WHERE nrecibo = v_recind.nrecibo
               AND fmovfin IS NULL;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN 104939;   -- recibo no encontrado en la tabla MOVRECIBO
         END;

         IF pfanulac >= TRUNC(f_sysdate) THEN
            ffanularec_hijo := pfanulac;
         ELSE
            SELECT LAST_DAY(ADD_MONTHS(MAX(fperini), 1))
              INTO ffanularec_hijo
              FROM cierres
             WHERE ctipo = 1
               AND cestado = 1
               AND cempres = ccempres;

            IF TRUNC(f_sysdate) < ffanularec_hijo THEN
               ffanularec_hijo := TRUNC(f_sysdate);
            END IF;
         END IF;

         IF ffanularec_hijo < v_fmovini
            OR ffanularec_hijo IS NULL THEN
            ffanularec_hijo := v_fmovini;
         END IF;

         num_err := f_movrecibo(v_recind.nrecibo, 2, pfanulac, 2, v_smovagr, nnliqmen,

                                -- nnliqlin, ffanularec_hijo, NULL, ccdelega, pcmotanul, NULL);
                                nnliqlin, ffanularec_hijo, NULL, ccdelega, pcmotanul, NULL);   -- BUG 0039682 - FAL - 26/01/2016
      END LOOP;

      --END IF;
      -- Ini Bug 26070 -- ECP -- 27/02/2013

      /* {creamos el movimiento de anulaci¿n del recibo} */
      num_err := f_movrecibo(pnrecibo, 2, pfanulac, 2, v_smovagr, nnliqmen, nnliqlin,
                             ffanularec, NULL, ccdelega, pcmotanul, NULL);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;
   END IF;   -- 2. 0022346: LCOL_A003-Cobro parcial de los recibos Fase 2

   RETURN 0;
END f_anula_rec;

/

  GRANT EXECUTE ON "AXIS"."F_ANULA_REC" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_ANULA_REC" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_ANULA_REC" TO "PROGRAMADORESCSI";
