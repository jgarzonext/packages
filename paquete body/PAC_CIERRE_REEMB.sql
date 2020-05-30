--------------------------------------------------------
--  DDL for Package Body PAC_CIERRE_REEMB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_CIERRE_REEMB" AS
/******************************************************************************
   NOMBRE:    PAC_CIERRE_REEMB

   REVISIONES:
   Ver        Fecha       Autor            Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        28/07/2009  ASN               creacion
   2.0        11/03/2010  ICV               2. 0010733: CRE - Listados de Reembolsos: Informe de siniestralidad
   3.0        04/05/2010  JGR               3. 0010733: CRE - Listados de Reembolsos: Informe de siniestralidad (AXIS1871)
   4.0        06/05/2010  JGR               4. 0010733: CRE - Listados de Reembolsos: Informe de siniestralidad (AXIS1878)
   5.0        11/05/2010  JGR               5. 0010733: CRE - Listados de Reembolsos: Informe de siniestralidad (AXIS1891)
******************************************************************************/

   /***************************************************************************
         28/07/2009 ASN
         Cierre de reembolsos. Llena la tabla reemb_siniestralidad para estadisticas
   ***************************************************************************/
   PROCEDURE proceso_batch_cierre(
      pmodo IN NUMBER,
      pcempres IN NUMBER,
      pmoneda IN NUMBER,
      pcidioma IN NUMBER,
      pfperini IN DATE,
      pfperfin IN DATE,
      pfcierre IN DATE,
      pcerror OUT NUMBER,
      psproces OUT NUMBER,
      pfproces OUT DATE) IS
   --verror         NUMBER;
   BEGIN
      p_procesini(f_user, pcempres, 'cierre_reembolsos',
                  'Llenado de la tabla reemb_siniestralidad ', psproces);
      /*BEGIN
        -- DELETE FROM tmp_reembolsos;

         COMMIT;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'CIERRE REEMBOLSOS =' || psproces, NULL,
                        'Error trucate table', SQLERRM);
      END;*/
      pcerror := pac_cierre_reemb.f_reemb_siniestralidad(pcempres,
                                                         TO_NUMBER(TO_CHAR(pfcierre, 'yyyy')),
                                                         psproces, pcidioma);
      p_procesfin(psproces, pcerror);
      pfproces := f_sysdate;
      pcerror := 0;
      COMMIT;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'CIERRE REEMBOLSOS =' || psproces, NULL,
                     'when others del cierre', SQLERRM);
         pcerror := 1;
   END proceso_batch_cierre;

   FUNCTION f_reemb_siniestralidad(
      pcempres IN NUMBER,
      panyo IN NUMBER,
      psproces IN NUMBER,
      pcidioma IN NUMBER)
      RETURN NUMBER IS
/******************************************************************************
   NOMBRE:       cierre_reembolsos
   PROPÓSITO:    Llena la tabla reemb_siniestralidad con la estadistica de siniestralidad.

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        27/07/2009  ASN               Creacion
   2.0        11/03/2010  ICV               2. 0010733: CRE - Listados de Reembolsos: Informe de siniestralidad
   3.0        04/05/2010  JGR               3. 0010733: CRE - Listados de Reembolsos: Informe de siniestralidad (AXIS1871)
   4.0        06/05/2010  JGR               4. 0010733: CRE - Listados de Reembolsos: Informe de siniestralidad (AXIS1878)
   5.0        11/05/2010  JGR               5. 0010733: CRE - Listados de Reembolsos: Informe de siniestralidad (AXIS1891)
******************************************************************************/
/***************************************************************************
Ramo: 2 (salud)

Agrupación de la consulta: 1 registro por riesgo.
Solo mostrar datos de pólizas y riesgos activos.
Solo mostrar datos de pagos de reembolsos transferidos.
Mostrar datos de recibos cobrados.

Campos de salida:
- Producto
- Num póliza
- Certificado
- Nombre colectivo (solo en caso de colectivos)
- Riesgo
- Nombre del riesgo.
- Fecha de efecto (alta del riesgo)
-
- Total primas reembolso (cgarant = 80)
- Total pagos reembolso complemento CASS
- Total pagos reembolso complemento factura.
- Total pago importe extra
- Total prestaciones (suma de los tres anteriores)
- Ratio: (total prestaciones/total primas)*100
-
- Total primas reembolso año en curso (cgarant = 80)
- Total pagos reembolso complemento CASS año en curso
- Total pagos reembolso complemento factura año en curso.
- Total pago importe extra año en curso
- Total prestaciones año en curso (suma de los tres anteriores)
- Ratio año en curso: (total prestaciones/total primas)*100

****************************************************************************/
      f_act_ini      DATE;
      f_act_fin      DATE;
      v_tot80_tot    NUMBER;
      v_tot80_act    NUMBER;
      v_pag_tot      NUMBER;
      v_extra_tot    NUMBER;
      v_comp_tot     NUMBER;
      v_pag_act      NUMBER;
      v_extra_act    NUMBER;
      v_comp_act     NUMBER;
      v_nom_tom      VARCHAR2(200);
      v_nom_col      VARCHAR2(200);
      v_producto     VARCHAR2(400);
      cont           NUMBER := 0;
      cont_error     NUMBER := 0;
   BEGIN
      SELECT TO_DATE('01/01/' || panyo, 'dd/mm/yyyy'),
             TO_DATE('31/12/' || panyo, 'dd/mm/yyyy')
        INTO f_act_ini,
             f_act_fin
        FROM DUAL;

-- Leemos las polizas de salud vigentes
      FOR i IN (SELECT sseguro, npoliza, ncertif, sproduc, cagente, fefecto
                  FROM seguros seg
                 WHERE seg.cramo = 2
                    --and seg.sseguro = 150688
                   -- AND f_vigente(seg.sseguro, seg.npoliza, f_sysdate) = 1 -- 4.0 - 06/05/2010 - JGR - BUG10733 - AXIS1878 INI
                   AND csituac <> 4   -- 4.0 - 06/05/2010 - JGR - BUG10733 - AXIS1878 FIN
                                   ) LOOP
         cont := cont + 1;

         INSERT INTO reemb_siniestralidad
                     (sproces, sseguro, npoliza, ncertif, sproduc, fefecto)
              VALUES (psproces, i.sseguro, i.npoliza, i.ncertif, i.sproduc, i.fefecto);

         -- 1 registro por cada riesgo vigente
         /*INSERT INTO tmp_reembolsos
                     (sseguro, npoliza, ncertif, sproduc, nriesgo, tnombre, fefecto)
            SELECT sseguro, i.npoliza, i.ncertif, i.sproduc, nriesgo,
                   f_nombre(sperson, 1, i.cagente), fefecto
              FROM riesgos
             WHERE sseguro = i.sseguro
               AND TRUNC(f_sysdate) BETWEEN fefecto AND NVL(fanulac, TRUNC(f_sysdate));*/
         IF cont > 1000 THEN
            COMMIT;
            cont := 0;
         END IF;
      END LOOP;

      COMMIT;

      FOR i IN (SELECT *
                  FROM reemb_siniestralidad
                 WHERE sproces = psproces) LOOP
         BEGIN
            cont := cont + 1;
            v_tot80_tot := 0;
            v_tot80_act := 0;
            v_pag_tot := 0;
            v_extra_tot := 0;
            v_comp_tot := 0;
            v_pag_act := 0;
            v_extra_act := 0;
            v_comp_act := 0;

            -- Primas reembolso total
            SELECT SUM(iconcep)
              INTO v_tot80_tot
              FROM detrecibos d, recibos r
             WHERE d.nrecibo = r.nrecibo
               AND d.cgarant = 80
               AND d.cconcep = 0   -- prima neta
               --AND d.nriesgo = i.nriesgo
               AND f_cestrec(r.nrecibo, f_sysdate) = 1
               AND r.sseguro = i.sseguro;

            -- Primas reembolso año actual
            SELECT SUM(iconcep)
              INTO v_tot80_act
              FROM detrecibos d, recibos r
             WHERE d.nrecibo = r.nrecibo
               AND d.cgarant = 80
               AND d.cconcep = 0   -- prima neta
               --AND d.nriesgo = i.nriesgo
               AND fefecto BETWEEN f_act_ini AND f_act_fin
               AND f_cestrec(r.nrecibo, f_sysdate) = 1
               AND r.sseguro = i.sseguro;

            -- Siniestros (pagos de reembolsos) total
            SELECT SUM(reembactosfac.ipago), SUM(reembactosfac.iextra)
              INTO v_pag_tot, v_extra_tot
              FROM reembactosfac, reembfact, reembolsos
             WHERE reembactosfac.nreemb = reembfact.nreemb
               AND reembactosfac.nfact = reembfact.nfact
               AND reembfact.nreemb = reembolsos.nreemb
               AND reembactosfac.fbaja IS NULL
               AND reembfact.fbaja IS NULL
               AND reembolsos.cestado <> 4
               AND reembolsos.sseguro = i.sseguro
               --AND reembolsos.nriesgo = i.nriesgo
               AND ftrans IS NOT NULL;

            SELECT SUM(reembactosfac.ipagocomp)
              INTO v_comp_tot
              FROM reembactosfac, reembfact, reembolsos
             WHERE reembactosfac.nreemb = reembfact.nreemb
               AND reembactosfac.nfact = reembfact.nfact
               AND reembfact.nreemb = reembolsos.nreemb
               AND reembactosfac.fbaja IS NULL
               AND reembfact.fbaja IS NULL
               AND reembolsos.cestado <> 4
               AND reembolsos.sseguro = i.sseguro
               --AND reembolsos.nriesgo = i.nriesgo
               AND ftranscomp IS NOT NULL;

            -- Siniestros año actual
            SELECT SUM(reembactosfac.ipago), SUM(reembactosfac.iextra)
              INTO v_pag_act, v_extra_act
              FROM reembactosfac, reembfact, reembolsos
             WHERE reembactosfac.nreemb = reembfact.nreemb
               AND reembactosfac.nfact = reembfact.nfact
               AND reembfact.nreemb = reembolsos.nreemb
               AND reembactosfac.fbaja IS NULL
               AND reembfact.fbaja IS NULL
               AND reembolsos.cestado <> 4
               AND reembolsos.sseguro = i.sseguro
               --AND reembolsos.nriesgo = i.nriesgo
               AND ftrans BETWEEN f_act_ini AND f_act_fin;

            --AND ftrans BETWEEN f_act_ini AND f_act_fin;
            SELECT SUM(reembactosfac.ipagocomp)
              INTO v_comp_act
              FROM reembactosfac, reembfact, reembolsos
             WHERE reembactosfac.nreemb = reembfact.nreemb
               AND reembactosfac.nfact = reembfact.nfact
               AND reembfact.nreemb = reembolsos.nreemb
               AND reembactosfac.fbaja IS NULL
               AND reembfact.fbaja IS NULL
               AND reembolsos.cestado <> 4
               AND reembolsos.sseguro = i.sseguro
               --AND reembolsos.nriesgo = i.nriesgo
               AND ftranscomp BETWEEN f_act_ini AND f_act_fin;

            --AND ftranscomp BETWEEN f_act_ini AND f_act_fin;
            SELECT trotulo
              INTO v_producto
              FROM titulopro t, productos p
             WHERE t.cramo = p.cramo
               AND t.cmodali = p.cmodali
               AND t.ctipseg = p.ctipseg
               AND t.ccolect = p.ccolect
               AND p.sproduc = i.sproduc
               AND t.cidioma = pcidioma;

            IF i.ncertif > 0 THEN
               BEGIN
                  SELECT f_nombre(t.sperson, 1, s.cagente)
                    INTO v_nom_col
                    FROM tomadores t, seguros s
                   WHERE t.sseguro = s.sseguro
                     AND t.nordtom = 1
                     AND s.npoliza = i.npoliza
                     AND s.ncertif = 0;
               EXCEPTION
                  WHEN OTHERS THEN
                     v_nom_col := NULL;
               END;
            ELSE
               v_nom_col := NULL;   -- 5.0 - 11/05/2010 - JGR - BUG10733 - AXIS1891
            END IF;

            BEGIN
               SELECT f_nombre(t.sperson, 1, s.cagente)
                 INTO v_nom_tom
                 FROM tomadores t, seguros s
                WHERE t.sseguro = s.sseguro
                  AND t.nordtom = 1
                  AND s.sseguro = i.sseguro;
            EXCEPTION
               WHEN OTHERS THEN
                  v_nom_tom := NULL;
            END;

            UPDATE reemb_siniestralidad
               SET tnom_col = v_nom_col,
                   tnombre = v_nom_tom,
                   tproducto = v_producto,
                   itot80_tot = NVL(v_tot80_tot, 0),
                   itot80_act = NVL(v_tot80_act, 0),
                   ipag_tot = NVL(v_pag_tot, 0),
                   iextra_tot = NVL(v_extra_tot, 0),
                   icomp_tot = NVL(v_comp_tot, 0),
                   iprest_tot =(NVL(v_pag_tot, 0) + NVL(v_comp_tot, 0)),
                   -- 3.0 - 04/05/2010 - JGR - BUG10733 - AXIS1871 - INI
                   pratio_tot = DECODE(NVL(v_tot80_tot, 1),
                                       0, 0,
                                       (ROUND((NVL(v_pag_tot, 0) + NVL(v_extra_tot, 0)
                                               + NVL(v_comp_tot, 0))
                                              / DECODE(NVL(v_tot80_tot, 1),
                                                       0, 1,
                                                       NVL(v_tot80_tot, 1)),
                                              2)
                                        * 100)),
                   -- 3.0 - 04/05/2010 - JGR - BUG10733 - AXIS1871 - FIN
                   --pratio_tot =(ROUND((NVL(v_pag_tot, 0) + NVL(v_extra_tot, 0)
                   --                    + NVL(v_comp_tot, 0))
                   --                   / NVL(v_tot80_tot, 1),
                   --                   2)
                   --             * 100),
                   ipag_act = NVL(v_pag_act, 0),
                   iextra_act = NVL(v_extra_act, 0),
                   icomp_act = NVL(v_comp_act, 0),
                   iprest_act =(NVL(v_pag_act, 0) + NVL(v_comp_act, 0)),
                   -- 3.0 - 04/05/2010 - JGR - BUG10733 - AXIS1871 - INI
                   pratio_act = DECODE(NVL(v_tot80_act, 1),
                                       0, 0,
                                       (ROUND((NVL(v_pag_act, 0) + NVL(v_extra_act, 0)
                                               + NVL(v_comp_act, 0))
                                              / DECODE(NVL(v_tot80_act, 1),
                                                       0, 1,
                                                       NVL(v_tot80_act, 1)),
                                              2)
                                        * 100))
             -- 3.0 - 04/05/2010 - JGR - BUG10733 - AXIS1871 - FIN
             --pratio_act =(ROUND((NVL(v_pag_act, 0) + NVL(v_extra_act, 0)
             --                    + NVL(v_comp_act, 0))
             --                   / NVL(v_tot80_act, 1),
             --                   2)
             --             * 100)
            WHERE  sseguro = i.sseguro;

            --AND nriesgo = i.nriesgo;
            --IF cont > 1000 THEN
            COMMIT;
         /*      cont := 0;
            END IF;*/
         EXCEPTION
            WHEN OTHERS THEN
               cont_error := cont_error + 1;
               p_proceslin(psproces, 'seg:' || i.sseguro || ' error:' || SQLERRM, i.sseguro);
         END;
      END LOOP;

      COMMIT;
      RETURN cont_error;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'f_reemb_siniestralidad ', 1, 'Error general',
                     SQLERRM);
         cont_error := cont_error + 1;
         RETURN cont_error;
   END f_reemb_siniestralidad;
END pac_cierre_reemb;

/

  GRANT EXECUTE ON "AXIS"."PAC_CIERRE_REEMB" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CIERRE_REEMB" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CIERRE_REEMB" TO "PROGRAMADORESCSI";
