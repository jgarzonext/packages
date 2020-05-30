--------------------------------------------------------
--  DDL for Package Body PAC_PPA_PLANES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_PPA_PLANES" IS
/****************************************************************************

   NOMBRE:       PAC_PPA_PLANES
   PROPÓSITO:  Funciones para PPA Planes

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ----------------------------------
   1.0           -          -               Creació del package
   2.0        20/04/2009   APD              Bug 9685 - en lugar de coger la acticad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
   3.0        28/04/2009   DCT              1-Modificación f_pargaranpro. Bug:0009783
   4.0        21/07/2009   jgm        fUNCIONS PER AL CALCUL DE ppaS
   5.0        28/10/2009   FAL              2. 0011595: CEM - Siniestros. Adaptación al nuevo módulo de siniestros
   6.0        18/05/2010   RSC              3. 0014582: CIV800 - Informe trimestral PPA
   7.0        08/10/2010   RSC              4. 0014582: CIV800 - Informe trimestral PPA
   8.0        20/11/2013   AGG              5. 0028906: CALI800-Parametrizar producto PIAS para poder gestionar traspasos
****************************************************************************/

   -----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
   FUNCTION primas_pendientes_emitir(
      anyo NUMBER,
      modo NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      psperson IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
/*********************************************************************************************
     modo = 0==> sin límite de aportaciones (hay que mirar solo esta póliza)
    modo = 1 ==> hay límite de aportaciones. Tener en cuenta todas la pólizas
*********************************************************************************************/
      v_sperson      NUMBER;
      v_prima        NUMBER;
      v_prima_pend   NUMBER := 0;
      v_fcarpro      DATE;
      lmeses         NUMBER;
      prevcap        NUMBER;
      prevprima      NUMBER;
      pfactor        NUMBER;
      v_primaanu     NUMBER;
      num_err        NUMBER;
   BEGIN
      IF psperson IS NULL THEN
         SELECT sperson
           INTO v_sperson
           FROM riesgos
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo;
      ELSE
         v_sperson := psperson;
      END IF;

      -- buscamos todas las pólizas que tenga esta persona en productos con aportaciones
      -- máximas. Para cada póliza miramos cuantas aportaciones periódicas le faltan por
      -- emitir
      -- Bug 9685 - APD - 20/04/2009 - en lugar de coger la acticad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
      FOR pol IN (SELECT s.sseguro, DECODE(s.cforpag, 0, 1, s.cforpag) cforpag, s.fcarpro,
                         r.nriesgo, s.cramo, s.cmodali, s.ctipseg, s.ccolect,
                         pac_seguros.ff_get_actividad(s.sseguro, r.nriesgo) cactivi, s.fcaranu,
                         s.crevali, s.irevali, s.prevali
                    FROM seguros s, riesgos r, productos p
                   WHERE s.sseguro = r.sseguro
                     AND s.cramo = p.cramo
                     AND s.cmodali = p.cmodali
                     AND s.ctipseg = p.ctipseg
                     AND s.ccolect = p.ccolect
                     AND r.sperson = v_sperson
                     AND s.csituac = 0
                     AND((modo = 1
                          AND f_parproductos_v(s.sproduc, 'APORTMAXIMAS') = 1)
                         OR(modo = 0
                            AND s.sseguro = psseguro))) LOOP
         -- Bug 9685 - APD - 20/04/2009 - Fin
         BEGIN
            SELECT icaptot, ipritot
              INTO v_prima, v_primaanu
              FROM garanseg
             WHERE sseguro = pol.sseguro
               AND nriesgo = pol.nriesgo
               AND ffinefe IS NULL
               AND f_pargaranpro_v(pol.cramo, pol.cmodali, pol.ctipseg, pol.ccolect,
                                   pol.cactivi, cgarant, 'TIPO') = 3;
         EXCEPTION
            WHEN OTHERS THEN
               v_prima := NULL;
         END;

         v_fcarpro := pol.fcarpro;
         lmeses := 12 / pol.cforpag;

         WHILE v_fcarpro <= TO_DATE('3112' || anyo, 'ddmmyyyy') LOOP
            IF v_fcarpro = pol.fcaranu THEN   -- revalorizamos la prima
               num_err := f_revalgar(pol.sseguro, 0, 48, pol.cactivi, pol.cramo, pol.cmodali,
                                     pol.ctipseg, pol.ccolect, v_prima, v_primaanu,
                                     pol.crevali, pol.irevali, pol.prevali,
                                     TO_CHAR(v_fcarpro, 'mm'), TO_CHAR(v_fcarpro, 'yyyy'),
                                     prevcap, prevprima, pfactor);
               v_prima := prevcap;
            END IF;

            v_prima_pend := v_prima_pend + v_prima;
            v_fcarpro := ADD_MONTHS(v_fcarpro, lmeses);
         END LOOP;
      END LOOP;

/*
  -- *** Buscamos si también hicimos alguna entrada este anyo
  BEGIN
     SELECT SUM ( nvl(IIMPANU,0) )
     INTO IMPORTEANUAL
     FROM TRASPLAINOUT,riesgos,ctaseguro, seguros, productos
     WHERE CINOUT = 1
     AND trasplainout.CESTADO IN ( 3,4)
     and ctaseguro.sseguro = trasplainout.sseguro
     and ctaseguro.nnumlin = trasplainout.nnumlin
     and seguros.sseguro = riesgos.sseguro
     and seguros.cramo = productos.cramo
     and seguros.cmodali = productos.cmodali
     and seguros.ctipseg = productos.ctipseg
     and seguros.ccolect = productos.ccolect
     AND PRODUCTOS.CAGRPRO = 11
     and TO_DATE(to_char(AÑO,'0000'),'YYYY') = TO_DATE(to_char(fvalmov,'yyyy'),'YYYY')
     AND SEGUROS.CSITUAC = 0
     and trasplainout.sseguro = riesgos.sseguro
     and riesgos.sperson = :area_seguros.ip_riesgo
     AND CDIVISA = :IP_NUMMONEDA;
  EXCEPTION
     WHEN OTHERS THEN
       IMPORTEANUAL := 0;
  END;



  */

      --RETURN ( nvl(IMPORTEANUAL,0) +  nvl(IMPCTASEGURO,0) );
      RETURN v_prima_pend;
   END primas_pendientes_emitir;

-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
   FUNCTION importe_recibos_pendientes(
      anyo NUMBER,
      modo NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      psperson IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      v_recpend      NUMBER;
      v_imprecpend   NUMBER;
      v_imp_pend     NUMBER := 0;
      v_sperson      NUMBER;
   BEGIN
      IF psperson IS NULL THEN
         SELECT sperson
           INTO v_sperson
           FROM riesgos
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo;
      ELSE
         v_sperson := psperson;
      END IF;

      -- buscamos todas las pólizas que tenga esta persona en productos con aportaciones
      -- máximas. Para cada póliza miramos el importe de los recibos pendientes
      FOR pol IN (SELECT s.sseguro, DECODE(s.cforpag, 0, 1, s.cforpag) cforpag, s.fcarpro,
                         r.nriesgo, s.cramo, s.cmodali, s.ctipseg, s.ccolect,
                         pac_seguros.ff_get_actividad(s.sseguro, r.nriesgo) cactivi, s.fcaranu,
                         s.crevali, s.irevali, s.prevali
                    FROM seguros s, riesgos r, productos p
                   WHERE s.sseguro = r.sseguro
                     AND s.cramo = p.cramo
                     AND s.cmodali = p.cmodali
                     AND s.ctipseg = p.ctipseg
                     AND s.ccolect = p.ccolect
                     AND r.sperson = v_sperson
                     AND s.csituac = 0
                     AND((modo = 1
                          AND f_parproductos_v(s.sproduc, 'APORTMAXIMAS') = 1)
                         OR(modo = 0
                            AND s.sseguro = psseguro))) LOOP
--p_control_error(null, 'ppa','sseguro ='||pol.sseguro);
         BEGIN
            SELECT DECODE(COUNT(*), 0, NULL, COUNT(*)),
                   DECODE(NVL(SUM(itotalr), 0), 0, NULL, NVL(SUM(itotalr), 0))
              INTO v_recpend,
                   v_imprecpend
              FROM movrecibo m, vdetrecibos v, recibos r
             WHERE r.sseguro = pol.sseguro
               AND m.nrecibo = r.nrecibo
               AND m.nrecibo = v.nrecibo
               AND m.fmovfin IS NULL
               AND m.cestrec = 0;
         EXCEPTION
            WHEN OTHERS THEN
               v_imp_pend := NULL;
         END;

--p_control_error(null, 'ppa','v_imprecpend ='||v_imprecpend);
         v_imp_pend := v_imp_pend + v_imprecpend;
      END LOOP;

      RETURN v_imp_pend;
   END importe_recibos_pendientes;

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
   FUNCTION primas_permitidas(
      anyo NUMBER,
      psperson IN NUMBER,
      prima_periodo IN NUMBER,
      prima_extr IN NUMBER,
      pcforpag IN NUMBER,
      pmodo IN VARCHAR2,
      pfcarpro IN DATE,
      pfefecto IN DATE,
      pnrenova IN NUMBER,
      psproduc IN NUMBER,
      psseguro IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
        /*****************************************************************************************
           pmodo =  ' SUP'  se llama desde suplementos. Se pasará la pfcarpro
          pmodo = 'NP'  se llama desde el alta de pólizas. Se pasa pfefecto, pnrenova, psproduc

        Primero se valida que no se supere el máximo de aportaciones en el anyo vigente.
        Si esta validación se supera, se valida que la suma anual de aportaciones periódicas no
        supere el máximo del anyo siguiente
      ********************************************************************************************/
      aport_max      NUMBER;
      aport_max_2    NUMBER;
      aport_realizadas NUMBER;
      aport_pendientes NUMBER;
      limite_aportacion NUMBER;
      v_fcarpro      DATE;
      prima_inicial  NUMBER;
      v_prima_pend   NUMBER;
      lmeses         NUMBER;
      limite         NUMBER;
      v_cforpag      NUMBER;
      prima_anual    NUMBER;
      prevcap        NUMBER;
      prevprima      NUMBER;
      pfactor        NUMBER;
      v_ssegpol      NUMBER;
      v_cactivi      NUMBER;
      v_cramo        NUMBER;
      v_cmodali      NUMBER;
      v_ctipseg      NUMBER;
      v_ccolect      NUMBER;
      v_fcaranu      DATE;
      vv_fcarpro     DATE;
      v_crevali      NUMBER;
      v_irevali      NUMBER;
      v_prevali      NUMBER;
      num_err        NUMBER;
      v_prima        NUMBER;
      imp_rec_pend   NUMBER;
   BEGIN
      IF pcforpag = 0 THEN
         v_cforpag := 1;
      ELSE
         v_cforpag := pcforpag;
      END IF;

      -- Validaciones máximo aportaciones para añi en curso

      -- Primero calculamos aportaciones máximas este anyo
      aport_max := NVL(pac_ppa_planes.calcula_importe_maximo_persona(anyo, NULL, NULL,
                                                                     psperson),
                       0);
      aport_realizadas := NVL(pac_ppa_planes.calcula_importe_anual_persona(anyo, 1, NULL, NULL,
                                                                           psperson),
                              0);
      aport_pendientes := NVL(pac_ppa_planes.primas_pendientes_emitir(anyo, 1, NULL, NULL,
                                                                      psperson),
                              0);
      imp_rec_pend := NVL(pac_ppa_planes.importe_recibos_pendientes(anyo, 1, NULL, NULL,
                                                                    psperson),
                          0);
--p_control_error(null, 'ppa','imp_rec_pend ='||imp_rec_pend);
--p_control_error(null, 'ppa','aport_pendientes ='||aPORT_PENDIENTES);
      limite_aportacion := aport_max - aport_realizadas - aport_pendientes - imp_rec_pend;

--p_control_error(null, 'ppa' ,'limite aportacion ='||limite_aportacion);

      -- ahora calculamos la prima que se emitiría de esta póliza
      IF pmodo = 'SUP' THEN
         v_fcarpro := pfcarpro;

         BEGIN
            --BUG 9783 - 29/04/2009 - DCT - Modificar cactivi por pac_seguros.ff_get_actividad(psseguro, pnriesgo)
            SELECT ssegpol, cramo, cmodali, ctipseg, ccolect,
                   pac_seguros.ff_get_actividad(estseguros.sseguro, 1, 'EST') cactivi,
                   crevali, irevali, prevali, fcarpro, fcaranu
              INTO v_ssegpol, v_cramo, v_cmodali, v_ctipseg, v_ccolect,
                   v_cactivi,
                   v_crevali, v_irevali, v_prevali, vv_fcarpro, v_fcaranu
              FROM estseguros
             WHERE sseguro = psseguro;
         --FI BUG 9783 - 29/04/2009 - DCT
         EXCEPTION
            WHEN OTHERS THEN
               RETURN NULL;
         END;
      ELSE
         v_fcarpro := pac_ppa_planes.f_fcarpro(psproduc, v_cforpag, pnrenova, pfefecto);
      END IF;

      IF prima_extr = 0 THEN
         prima_inicial := prima_periodo;
      ELSE
         prima_inicial := prima_extr;
      END IF;

      v_prima_pend := prima_inicial;
      lmeses := 12 / v_cforpag;
      v_prima := prima_periodo;

      WHILE v_fcarpro <= TO_DATE('3112' || anyo, 'ddmmyyyy') LOOP
         IF v_fcarpro = v_fcaranu
            AND pmodo = 'SUP' THEN   -- hay que revalorizar
            num_err := f_revalgar(v_ssegpol, 0, 48, v_cactivi, v_cramo, v_cmodali, v_ctipseg,
                                  v_ccolect, prima_periodo, prima_periodo * v_cforpag,
                                  v_crevali, v_irevali, v_prevali, TO_CHAR(v_fcarpro, 'mm'),
                                  TO_CHAR(v_fcarpro, 'yyyy'), prevcap, prevprima, pfactor);
            v_prima := prevcap;
         END IF;

         v_prima_pend := v_prima_pend + v_prima;
         v_fcarpro := ADD_MONTHS(v_fcarpro, lmeses);
      END LOOP;

--p_control_error(null, 'apo', 'v_prima_pend ='||v_prima_pend);
--p_control_error(null, 'apo', 'limite aportacion ='||limite_aportacion);
      IF v_prima_pend > limite_aportacion THEN
         limite := 1;
      ELSE
         limite := 0;
      END IF;

--p_control_error(null, 'apo', 'limit ='||limite);
      IF limite = 0 THEN   -- HA pasado la validación del primer anyo, ahora validamos el segundo
         aport_max_2 := NVL(pac_ppa_planes.calcula_importe_maximo_persona(anyo + 1, NULL,
                                                                          NULL, psperson),
                            0);
         prima_anual := v_prima * v_cforpag;

--p_control_error(null, 'apo', 'prima_anual ='||prima_anual);
--p_control_error(null, 'apo', 'aport_max_2 ='||aport_max_2);
         IF prima_anual > aport_max_2 THEN
            limite := 1;
         ELSE
            limite := 0;
         END IF;
      END IF;

      RETURN limite;
   END primas_permitidas;

   FUNCTION f_fcarpro(
      psproduc IN NUMBER,
      pcforpag IN NUMBER,
      pnrenova IN NUMBER,
      pfefecto IN DATE)
      RETURN DATE IS
      lndiaspro      NUMBER;
      lctipefe       NUMBER;
      num_err        NUMBER;
      lfcapro        DATE;
      lmeses         NUMBER;
      dd             VARCHAR2(2);
      ddmm           VARCHAR2(4);
      lfcanua        DATE;
      fecha_aux      DATE;
      lfaux          DATE;
      v_cforpag      NUMBER;
      l_fefecto_1    DATE;
   BEGIN
      num_err := 0;

      IF pcforpag = 0 THEN
         v_cforpag := 1;
      ELSE
         v_cforpag := pcforpag;
      END IF;

      BEGIN
         SELECT ndiaspro,
                         -- Se recupera ndiaspro para utilizarlo en el cálculo de fcarpro.
                         ctipefe
           --  Para saber qué tipo de renovación (calcular fcaranu)
         INTO   lndiaspro,   -- Para el cálculo de fcarpro.
                          lctipefe
           FROM productos
          WHERE sproduc = psproduc;
      EXCEPTION
         WHEN OTHERS THEN
            lfcapro := NULL;
            num_err := 1;
      END;

      IF num_err = 0 THEN
         -- Calcul de la data de renovació
         lmeses := 12 / v_cforpag;
         dd := SUBSTR(LPAD(pnrenova, 4, 0), 3, 2);
         ddmm := dd || SUBSTR(LPAD(pnrenova, 4, 0), 1, 2);

         IF TO_CHAR(pfefecto, 'DDMM') = ddmm
            OR LPAD(pnrenova, 4, 0) IS NULL THEN
            lfcanua := f_summeses(pfefecto, 12, dd);
         ELSE
            IF lctipefe = 2 THEN   -- a día 1/mes por exceso
               fecha_aux := ADD_MONTHS(pfefecto, 13);
               lfcanua := TO_DATE(ddmm || TO_CHAR(fecha_aux, 'YYYY'), 'DDMMYYYY');
            ELSE
               BEGIN
                  lfcanua := TO_DATE(ddmm || TO_CHAR(pfefecto, 'YYYY'), 'DDMMYYYY');
               EXCEPTION
                  WHEN OTHERS THEN
                     IF ddmm = 2902 THEN
                        ddmm := 2802;
                        lfcanua := TO_DATE(ddmm || TO_CHAR(pfefecto, 'YYYY'), 'DDMMYYYY');
                     ELSE
                        lfcapro := NULL;
                        --Fecha de renovación (mmdd) incorrecta
                        num_err := 1;
                     END IF;
               END;
            END IF;

            IF lfcanua <= pfefecto THEN
               lfcanua := f_summeses(lfcanua, 12, dd);
            END IF;
         END IF;

         -- Se calcula la próx. cartera partiendo de la cartera de renovación (fcaranu)
         -- y restándole periodos de pago
         IF lctipefe = 2
            AND TO_CHAR(pfefecto, 'dd') <> 1
            AND v_cforpag <> 12 THEN
            l_fefecto_1 := '01/' || TO_CHAR(ADD_MONTHS(pfefecto, 1), 'mm/yyyy');
         ELSE
            l_fefecto_1 := pfefecto;
         END IF;

         lfaux := lfcanua;

         WHILE TRUE LOOP
            lfaux := f_summeses(lfaux, -lmeses, dd);

            IF lfaux <= l_fefecto_1 THEN
               lfcapro := f_summeses(lfaux, lmeses, dd);
               EXIT;
            END IF;
         END LOOP;

-----------------------------------
-- Si el día de la fecha de efecto es mayor o igual que
-- ndiaspro, se le añade un periodo más.
-- Només funcionava per mensuals. Cal mirar del peride que cubreix si
-- supera el dia 15 de l'ultim mes , i que no es passi de la renovació
--
         IF (lndiaspro IS NOT NULL) THEN
            IF TO_NUMBER(TO_CHAR(pfefecto, 'dd')) >= lndiaspro
               AND TO_NUMBER(TO_CHAR(lfcapro, 'mm')) =
                                              TO_NUMBER(TO_CHAR(ADD_MONTHS(pfefecto, 1), 'mm')) THEN
               -- és a dir , que el dia sigui > que el dia 15 de l'ultim més del periode
               lfcapro := ADD_MONTHS(lfcapro, lmeses);

               IF lfcapro > lfcanua THEN
                  lfcapro := lfcanua;
               END IF;
            END IF;
         END IF;
      END IF;

-----------------------------------
      RETURN lfcapro;
   END f_fcarpro;

   FUNCTION ff_limite_aportaciones(anyo IN NUMBER, pctipapor IN NUMBER, pedad IN NUMBER)
      RETURN NUMBER IS
       /*******************************************************************************************************************
       Calcula el limite de aportaciones anual según la edad y el tipo de aportante:
               1.- 'Normal'
             2.- Minusválido
             3.- Aportante de minusválido
             4.- Promotor
      **********************************************************************************************************************/
      v_importe_maximo NUMBER;
   BEGIN
      BEGIN
         SELECT iimporte
           INTO v_importe_maximo
           FROM planedades
          WHERE nano = anyo
            AND ntipo = pctipapor
            AND pedad BETWEEN nedadini AND nedadfin;
      EXCEPTION
         WHEN OTHERS THEN
            v_importe_maximo := NULL;
      END;

      RETURN v_importe_maximo;
   END ff_limite_aportaciones;

   FUNCTION ff_tipo_aportante(psperson IN NUMBER, psseguro IN NUMBER)
      RETURN NUMBER IS
      /***************************************************************************************************************
            El objetivo es saber el tipo de aportante de la póliza(aportante de minusválido o promotor), no del partícipe (asegurado).
          Si entramos por persona sólo devolveremos si es aportante de minusválido o promotor.
                   3.- Aportante de minusválido. Aparece en algun póliza con RIESGOS.SPERSON <> RIESGOS.SPERMIN
                   4.- Promotor. Es tomador de algún producto de Plan Empleo
          Si no es ninguno de los dos tipos devuelve null

          Si miramos por póliza el criterio es: primero mirar si es promotor o aportante de minusválido y si no es ninguno
            de los dos entonces miramos si es póliza de partícipe normal o minusválido (hacemos esto último porque
            así podemos usar la función en el cálculo del importe anual de la póliza.

          Si no es ninguno de los dos tipos devuelve null

      ****************************************************************************************************/
      hay            NUMBER;
      v_sperson      NUMBER;
      v_spermin      NUMBER;
      ntipo_aport    NUMBER;
      v_sperson_tom  NUMBER;
   BEGIN
      IF psperson IS NOT NULL THEN   --entramos por persona
         SELECT COUNT(sperson)
           INTO hay
           FROM riesgos
          WHERE sperson = psperson
            AND spermin IS NOT NULL   -- pólizas con beneficiario minusválido
            AND sperson <> spermin;

         IF hay > 0 THEN
            RETURN 3;   -- aportante de minusválido
         END IF;

         -- miramos si es promotor
         SELECT COUNT(t.sperson)
           INTO hay
           FROM tomadores t, seguros s
          WHERE s.sseguro = t.sseguro
            AND f_parproductos_v(s.sproduc, 'PPEMPLEO') = 1
            AND t.sperson = psperson;

         IF hay > 0 THEN
            RETURN 4;
         END IF;

         RETURN NULL;
      ELSE   -- entramos por póliza
         SELECT COUNT(s.sseguro)
           INTO hay
           FROM seguros s
          WHERE f_parproductos_v(s.sproduc, 'PPEMPLEO') = 1
            AND s.sseguro = psseguro;

         IF hay > 0 THEN
            RETURN 4;
         ELSE
            SELECT sperson, spermin
              INTO v_sperson, v_spermin
              FROM riesgos
             WHERE sseguro = psseguro;

            IF v_spermin IS NULL THEN   -- IF 2
               ntipo_aport := 1;   --partícipe 'normal'
            ELSIF v_spermin IS NOT NULL
                  AND v_spermin = v_sperson THEN
               ntipo_aport := 2;   -- partícipe minusválido
            ELSIF v_spermin IS NOT NULL
                  AND v_spermin <> v_sperson THEN
               ntipo_aport := 3;
            END IF;

            RETURN ntipo_aport;
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_ppa_planes.ff_tipo_aportante', NULL,
                     'sperson =' || psperson || ' sseguro =' || psseguro, SQLERRM);
         RETURN NULL;
   END ff_tipo_aportante;

   FUNCTION ff_tipo_participe(psperson IN NUMBER, psseguro IN NUMBER)
      RETURN NUMBER IS
      /******************************************************************************************************************************
         Devuelve el tipo de partícipe, es decir, del 'asegurado'. Si la persona no es partícipe en ninguna póliza
        entonces miramos si es aportante de minusválido o promotor.
              1.- Partícipe 'normal'
             2.- Minusválido. La persona aparece en alguna póliza como minusvalido RIESGOS.SPERMIN
             3.- Aportante
            4.- Promotor

          Puede preguntarse por persona (psseguro = null) o por póliza (psperson = null)

      **************************************************************************************************************************/
      ntipo_aport    NUMBER;
      hay            NUMBER;
      v_sperson      NUMBER;
      v_spermin      NUMBER;
      v_sperson_tom  NUMBER;
   BEGIN
      IF psseguro IS NOT NULL THEN   --1
         SELECT sperson, spermin
           INTO v_sperson, v_spermin
           FROM riesgos
          WHERE sseguro = psseguro;

         IF v_spermin IS NULL THEN   -- IF 2
            ntipo_aport := 1;   --partícipe 'normal'
         ELSIF v_spermin IS NOT NULL
               AND v_spermin = v_sperson THEN
            ntipo_aport := 2;   -- partícipe minusválido
         ELSIF v_spermin IS NOT NULL
               AND v_spermin <> v_sperson THEN
            ntipo_aport := 3;   -- aportante de minusválido
         ELSE
            SELECT COUNT(s.sseguro)
              INTO hay
              FROM seguros s
             WHERE f_parproductos_v(s.sproduc, 'PPEMPLEO') = 1
               AND s.sseguro = psseguro;

            IF hay > 0 THEN
               RETURN 4;
            END IF;
         END IF;   --FIN 2
      ELSE   -- psseguro is  null       -- ELSE 1
       -- miramos si es partícipe MINUSVÁLIDO
--dbms_output.put_line('sperson is not null');
         SELECT COUNT(*)
           INTO hay
           FROM riesgos r
          WHERE r.spermin = psperson;

--dbms_output.put_line('hay minus ='||hay);
         IF hay > 0 THEN   -- IF 3
            ntipo_aport := 2;   --PERSONA MINUSVALIDA, PORQUE APARECE EN ALGUNA PÓLIZA COMO BENEFICIARIO
         -- MINUSVALIDO
         ELSE   --ELSE 3
--dbms_output.put_line('else 3');
        --miramos si es NORMAL
            SELECT COUNT(*)
              INTO hay
              FROM riesgos r, seguros s
             WHERE r.sperson = psperson
               AND s.sseguro = r.sseguro
               AND f_parproductos_v(s.sproduc, 'APORTMAXIMAS') = 1
               AND r.spermin IS NULL;

--dbms_output.put_line('hay normal ='||hay);
            IF hay > 0 THEN   -- IF 4
               ntipo_aport := 1;   --
            ELSE   -- ELSE 4
--dbms_output.put_line('else 4');
             -- miramos si es aportante o promotor o partícipe normal
               ntipo_aport := ff_tipo_aportante(psperson, NULL);
--dbms_output.put_line('ntipo_aport ='||ntipo_aport);
            END IF;   -- FIN 4
         END IF;   -- FIN 3
      END IF;   -- FIN 1

--dbms_output.put_line('return ntipo_aport ='||ntipo_aport);
      RETURN ntipo_aport;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_ppa_planes.ff_tipo_participe', NULL,
                     'sperson =' || psperson || ' sseguro =' || psseguro, SQLERRM);
         RETURN NULL;
   END ff_tipo_participe;

   FUNCTION calcula_importe_anual_persona(
      anyo NUMBER,
      modo NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      psperson IN NUMBER DEFAULT NULL,
      pctipapor IN NUMBER DEFAULT NULL,
      porigen IN NUMBER DEFAULT 2)
      RETURN NUMBER IS
      impctaseguro   NUMBER(25, 10);
      importeanual   NUMBER(25, 10);
      importeanualotra NUMBER(25, 10);
      v_sperson      NUMBER;
      perror         NUMBER;
      ntipo_apor     NUMBER;
      v_spermin      NUMBER;
      vv_sperson     NUMBER;
   BEGIN
      perror := 0;

      IF modo = 1 THEN
         -- hay límite de aportaciones . Se buscan todas las pólizas de la persona
         IF psperson IS NULL THEN
            ntipo_apor := ff_tipo_participe(NULL, psseguro);

            IF ntipo_apor = 1 THEN
               IF porigen = 2 THEN
                  SELECT sperson
                    INTO v_sperson
                    FROM riesgos
                   WHERE sseguro = psseguro
                     AND nriesgo = pnriesgo;
               ELSIF porigen = 1 THEN
                  SELECT sperson
                    INTO v_sperson
                    FROM estriesgos
                   WHERE sseguro = psseguro
                     AND nriesgo = pnriesgo;
               END IF;
            ELSE
               IF porigen = 2 THEN
                  SELECT sperson, spermin
                    INTO v_sperson, v_spermin
                    FROM riesgos
                   WHERE sseguro = psseguro
                     AND nriesgo = pnriesgo;
               ELSIF porigen = 1 THEN
                  SELECT sperson, spermin
                    INTO v_sperson, v_spermin
                    FROM estriesgos
                   WHERE sseguro = psseguro
                     AND nriesgo = pnriesgo;
               END IF;
            END IF;
         ELSE
            IF porigen = 1 THEN   -- ESTAMOS EN EL EST
               SELECT spereal
                 INTO vv_sperson
                 FROM estper_personas
                WHERE sperson = psperson;
            ELSE
               vv_sperson := psperson;
            END IF;

            --AGG 20/11/2013 Bug: 0028906 Se añade el sseguro para obtener el tipo de aportación
            ntipo_apor := ff_tipo_participe(vv_sperson, psseguro);
            v_sperson := vv_sperson;
            v_spermin := vv_sperson;
         END IF;

--dbms_output.put_line('ntipo_apor calcula ='||ntipo_apor);
         IF v_sperson IS NULL THEN   -- estamos en las est y es una persona nueva
            importeanual := 0;
         ELSE
            IF ntipo_apor = 1 THEN
               -- aportaciones realizadas durante el año por el partícipe
               SELECT SUM(NVL(DECODE(cmovimi, 51, -imovimi, imovimi), 0))   --SUM(NVL( imovimi,0))
                 INTO impctaseguro
                 FROM seguros, ctaseguro, riesgos
                WHERE cmovimi IN(1, 2, 51)
                  AND seguros.sseguro = ctaseguro.sseguro
                  --  AND SEGUROS.CSITUAC = 0 -- TAMBIÉN LAS ANULADAS SI TIENEN MOVIMIENTOS EN ESTE AÑO
                  AND TO_CHAR(fvalmov, 'YYYY') = TO_CHAR(anyo)
                  AND f_parproductos_v(seguros.sproduc, 'APORTMAXIMAS') = 1
                  --  AND ( CTASEGURO.CTIPAPOR <> 'SP' OR CTASEGURO.CTIPAPOR IS NULL )
                  AND(NVL(ctaseguro.ctipapor, 'X') <> 'SP')
                  AND seguros.sseguro = riesgos.sseguro
                  AND riesgos.fanulac IS NULL
                  AND riesgos.sperson = v_sperson
                  AND riesgos.spermin IS NULL;

                 --AND CMOVANU <> 1;
--dbms_output.put_line('ppa impctaseguro ='||impctaseguro);

               -- Aportaciones realizadas por el participe en otro plan durante al año.
               SELECT SUM(NVL(trasplainout.iimpanu, 0))
                 INTO importeanualotra
                 FROM trasplainout, riesgos, ctaseguro
                WHERE cinout = 1
                  AND trasplainout.cestado IN(3, 4)   -- 3 = Traspaso pdte. informar; 4 = Traspasado
                  AND trasplainout.sseguro = riesgos.sseguro
                  AND riesgos.sperson = v_sperson
                  AND riesgos.spermin IS NULL
                  AND riesgos.fanulac IS NULL
                  --AND TRASPLAINOUT.CEXTERNO = 'E'
                  AND trasplainout.sseguro = ctaseguro.sseguro
                  AND trasplainout.nnumlin = ctaseguro.nnumlin
                  AND TO_CHAR(fvalmov, 'YYYY') = TO_CHAR(anyo);
--dbms_output.put_line('ppa importe_anual ='||importeanualotra);
            ELSE   --ntipo_apor <>1
               -- aportaciones realizadas durante el año por el partícipe minusválido
               SELECT SUM(NVL(DECODE(cmovimi, 51, -imovimi, imovimi), 0))   --SUM(NVL( imovimi,0))
                 INTO impctaseguro
                 FROM seguros, ctaseguro, riesgos
                WHERE cmovimi IN(1, 2, 51)
                  AND seguros.sseguro = ctaseguro.sseguro
                  AND TO_CHAR(fvalmov, 'YYYY') = TO_CHAR(anyo)
                  AND f_parproductos_v(seguros.sproduc, 'APORTMAXIMAS') = 1
                  AND(ctaseguro.ctipapor <> 'SP'
                      OR ctaseguro.ctipapor IS NULL)
                  AND seguros.sseguro = riesgos.sseguro
                  AND riesgos.fanulac IS NULL
                  AND riesgos.spermin = v_spermin;

                 --AND CMOVANU <> 1;
--dbms_output.put_line('ppa impctaseguro ='||impctaseguro);
                 -- Aportaciones realizadas por el participe minusválido en otro plan durante al año.
               SELECT SUM(NVL(trasplainout.iimpanu, 0))
                 INTO importeanualotra
                 FROM trasplainout, riesgos, ctaseguro
                WHERE cinout = 1
                  AND trasplainout.cestado IN(3, 4)   -- 3 = Traspaso pdte. informar; 4 = Traspasado
                  AND trasplainout.sseguro = riesgos.sseguro
                  AND riesgos.spermin = v_spermin
                  AND riesgos.fanulac IS NULL
                  --AND TRASPLAINOUT.CEXTERNO = 'E'
                  AND trasplainout.sseguro = ctaseguro.sseguro
                  AND trasplainout.nnumlin = ctaseguro.nnumlin
                  AND TO_CHAR(fvalmov, 'YYYY') = TO_CHAR(anyo);
--dbms_output.put_line('ppa importe_anual ='||importeanualotra);
            END IF;

            importeanual := NVL(importeanualotra, 0) + NVL(impctaseguro, 0);
         END IF;
      ELSE
         -- aportaciones de esta póliza
         SELECT SUM(NVL(DECODE(cmovimi, 51, -imovimi, imovimi), 0))   -- SUM(NVL( imovimi,0))
           INTO impctaseguro
           FROM seguros, ctaseguro, riesgos
          WHERE cmovimi IN(1, 2, 51)
            AND ctaseguro.sseguro = psseguro;
      -- AND TO_CHAR(FVALMOV,'YYYY')  = TO_CHAR(PAÑO)
      --AND CMOVANU <> 1;
      END IF;

      RETURN importeanual;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_ppa_planes.calcula_importe_anual_persona', NULL,
                     'sperson =' || psperson || ' sseguro =' || psseguro || ' anyo ' || anyo
                     || ' pctipapor=' || pctipapor,
                     SQLERRM);
         RETURN NULL;
   END calcula_importe_anual_persona;

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
   FUNCTION calcula_importe_maximo_persona(
      anyo IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      psperson IN NUMBER DEFAULT NULL,
      pctipapor IN NUMBER DEFAULT NULL,
      porigen IN NUMBER DEFAULT 2)
      RETURN NUMBER IS
         /***************************************************************************************************************
           Calcula el importe máximo de aportaciones que puede realizar una persona.
          Podemos llamar a la función con:
             -- una póliza concreta: vendrá informado sseguro y nriesgo.
            -- una persona concreta: vendrá informado el sperson
            -- sólo el tipo de partícipe: normal o minusválido. Este caso será desde TF2 en un alta de póliza.
                Todavía no sabemos el sseguro pero si sabemos el tipo de partícipe que es. Entonces el parámetro
               psperson vendrá informado de la siguiente manera:
                  pctipapor = 1 (normal)  ===> psperson = sperson del partícipe
                  pctipapor = 2 (minusválido) ====> psperson = spermin ( beneficiario minusválido)
                  pctipapor = 3 (aportante) =====> psperson = spermin (beneficiario minusválido) si se quiere saber el límite del beneficiario
                  pctipapor = 3 (aportante) =====> psperson = sperson (si se quiere saber el límite del aportante)
                  pctipapor = 4 (promotor) =====> psperson = sperson del tomador (límite del promotor)
      ************************************************************************************************************/
      v_sperson      NUMBER;
      v_cestado      NUMBER;
      v_fnacimi      DATE;
      ntipo_aport    NUMBER;
      fin_anyo       VARCHAR2(10);
      edad           NUMBER;
      num_err        NUMBER;
      v_importe_maximo NUMBER;
   BEGIN
      IF psperson IS NULL THEN
         ntipo_aport := ff_tipo_participe(NULL, psseguro);

         IF ntipo_aport IN(1, 4) THEN
            SELECT sperson
              INTO v_sperson
              FROM riesgos
             WHERE sseguro = psseguro
               AND nriesgo = pnriesgo;

            IF ntipo_aport = 4 THEN
               ntipo_aport := 1;   --porque queremos el límite del partícipe
            END IF;
         ELSE
            SELECT spermin
              INTO v_sperson
              FROM riesgos
             WHERE sseguro = psseguro
               AND nriesgo = pnriesgo;

            IF ntipo_aport = 3 THEN
               ntipo_aport := 2;   -- porque queremos el límite del partícipe minusválido, no del aportante
            END IF;
         END IF;
      ELSIF psperson IS NOT NULL
            AND pctipapor IS NULL THEN
         v_sperson := psperson;
         ntipo_aport := ff_tipo_participe(v_sperson, NULL);
      ELSIF psperson IS NOT NULL
            AND pctipapor IS NOT NULL THEN
         v_sperson := psperson;
         ntipo_aport := pctipapor;
      ELSE
         RETURN NULL;   --ERROR
      END IF;

--dbms_output.put_line('imp_maximo-- sperson ='||v_sperson||' tipo ='||ntipo_aport);
      -- edad de la persona a final de año
      fin_anyo := anyo || '1231';

      IF ntipo_aport IS NULL THEN   -- no es partícipe de ningún tipo
         RETURN NULL;
      ELSIF ntipo_aport = 4 THEN
         edad := 1;   -- porque no tienen fecha de nacimiento, son empresas
      ELSE
--dbms_output.put_line('llamamos a fedadaseg con porigen ='||porigen);
         edad := fedadaseg(1, v_sperson, fin_anyo, 1, porigen);
--dbms_output.put_line('despues edad ='||edad);
      END IF;

      v_importe_maximo := ff_limite_aportaciones(anyo, ntipo_aport, edad);
      RETURN v_importe_maximo;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_ppa_planes.calcula_importe_maximo_persona', NULL,
                     'sperson =' || psperson || ' sseguro =' || psseguro || ' anyo ' || anyo
                     || ' pctipapor=' || pctipapor,
                     SQLERRM);
         RETURN NULL;
   END calcula_importe_maximo_persona;

   FUNCTION ff_importe_por_aportar_persona(
      anyo IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      psperson IN NUMBER DEFAULT NULL,
      pctipapor IN NUMBER DEFAULT NULL,
      porigen IN NUMBER DEFAULT 2)
      RETURN NUMBER IS
      aport_max      NUMBER;
      aport_realizadas NUMBER;
   BEGIN
      -- Primero calculamos aportaciones máximas este anyo
      aport_max := NVL(pac_ppa_planes.calcula_importe_maximo_persona(anyo, psseguro, pnriesgo,
                                                                     psperson, pctipapor,
                                                                     porigen),
                       0);
      aport_realizadas := NVL(pac_ppa_planes.calcula_importe_anual_persona(anyo, 1, psseguro,
                                                                           pnriesgo, psperson,
                                                                           pctipapor, porigen),
                              0);
      RETURN aport_max - aport_realizadas;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_ppa_planes.ff_importe_por_aportar_persona', NULL,
                     'sperson =' || psperson || ' sseguro =' || psseguro || ' anyo ' || anyo
                     || ' pctipapor=' || pctipapor,
                     SQLERRM);
         RETURN NULL;
   END ff_importe_por_aportar_persona;

   FUNCTION calcula_importe_maximo_poliza(
      anyo IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      porigen IN NUMBER DEFAULT 2)
      RETURN NUMBER IS
         /***************************************************************************************************************
           Calcula el importe máximo de aportaciones que puede realizar una póliza
         Dará el importe menor entre la póliza (aportante o promotor) y la persona
      ************************************************************************************************************/
      ntipo_aport    NUMBER;
      v_importe_max  NUMBER;
      v_imp_max_persona NUMBER;
   BEGIN
      ntipo_aport := ff_tipo_aportante(NULL, psseguro);

      IF ntipo_aport IN(1, 2) THEN
         RETURN calcula_importe_maximo_persona(anyo, psseguro, pnriesgo, NULL, NULL, porigen);
      ELSIF ntipo_aport IN(3, 4) THEN   -- aportante
         v_imp_max_persona := calcula_importe_maximo_persona(anyo, psseguro, pnriesgo, NULL,
                                                             NULL, porigen);
         v_importe_max := ff_limite_aportaciones(anyo, ntipo_aport, 1);
         RETURN LEAST(v_importe_max, v_imp_max_persona);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_ppa_planes.calcula_importe_maximo_poliza', NULL,
                     ' sseguro =' || psseguro || ' anyo ' || anyo, SQLERRM);
         RETURN NULL;
   END calcula_importe_maximo_poliza;

   FUNCTION calcula_importe_anual_poliza(
      anyo NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      porigen IN NUMBER DEFAULT 2)
      RETURN NUMBER IS
      impctaseguro   NUMBER(25, 10);
      importeanual   NUMBER(25, 10);
      importeanualotra NUMBER(25, 10);
      v_sperson      NUMBER;
      perror         NUMBER;
      ntipo_apor     NUMBER;
      v_spermin      NUMBER;
      v_sperson_tom  NUMBER;
   BEGIN
      perror := 0;
      -- hay límite de aportaciones . Se buscan todas las pólizas de la persona
      ntipo_apor := ff_tipo_aportante(NULL, psseguro);

      IF ntipo_apor IN(1, 2) THEN
         RETURN calcula_importe_anual_persona(anyo, 1, psseguro, pnriesgo, NULL, NULL,
                                              porigen);
      ELSIF ntipo_apor = 3 THEN
         SELECT sperson, spermin
           INTO v_sperson, v_spermin
           FROM riesgos
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo;

         -- aportaciones realizadas durante el año por el aportante o promotor a este partícipe
         SELECT SUM(NVL(DECODE(cmovimi, 51, -imovimi, imovimi), 0))   --SUM(NVL( imovimi,0))
           INTO impctaseguro
           FROM seguros, ctaseguro, riesgos
          WHERE cmovimi IN(1, 2, 51)
            AND seguros.sseguro = ctaseguro.sseguro
            --  AND SEGUROS.CSITUAC = 0 -- TAMBIÉN LAS ANULADAS SI TIENEN MOVIMIENTOS EN ESTE AÑO
            AND TO_CHAR(fvalmov, 'YYYY') = TO_CHAR(anyo)
            AND f_parproductos_v(seguros.sproduc, 'APORTMAXIMAS') = 1
            --  AND ( CTASEGURO.CTIPAPOR <> 'SP' OR CTASEGURO.CTIPAPOR IS NULL )
            AND(NVL(ctaseguro.ctipapor, 'X') <> 'SP')
            AND seguros.sseguro = riesgos.sseguro
            AND riesgos.fanulac IS NULL
            AND riesgos.sperson = v_sperson
            AND riesgos.spermin = v_spermin;

                 --AND CMOVANU <> 1;
--dbms_output.put_line('ppa impctaseguro ='||impctaseguro);
                 -- Aportaciones realizadas por el aportante o promotor  en otro plan durante al año.
         SELECT SUM(NVL(trasplainout.iimpanu, 0))
           INTO importeanualotra
           FROM trasplainout, riesgos, ctaseguro
          WHERE cinout = 1
            AND trasplainout.cestado IN(3, 4)   -- 3 = Traspaso pdte. informar; 4 = Traspasado
            AND trasplainout.sseguro = riesgos.sseguro
            AND riesgos.sperson = v_sperson
            AND riesgos.spermin = v_spermin
            AND riesgos.fanulac IS NULL
            --AND TRASPLAINOUT.CEXTERNO = 'E'
            AND trasplainout.sseguro = ctaseguro.sseguro
            AND trasplainout.nnumlin = ctaseguro.nnumlin
            AND TO_CHAR(fvalmov, 'YYYY') = TO_CHAR(anyo);

--dbms_output.put_line('ppa importe_anual ='||importeanualotra);
         importeanual := NVL(importeanualotra, 0) + NVL(impctaseguro, 0);
      ELSIF ntipo_apor = 4 THEN
         SELECT sperson, spermin
           INTO v_sperson, v_spermin
           FROM riesgos
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo;

         SELECT sperson
           INTO v_sperson_tom
           FROM tomadores
          WHERE sseguro = psseguro;

         -- aportaciones realizadas durante el año por el aportante o promotor a este partícipe
         SELECT SUM(NVL(DECODE(cmovimi, 51, -imovimi, imovimi), 0))   --SUM(NVL( imovimi,0))
           INTO impctaseguro
           FROM seguros, ctaseguro, riesgos, tomadores
          WHERE cmovimi IN(1, 2, 51)
            AND seguros.sseguro = ctaseguro.sseguro
            AND tomadores.sseguro = seguros.sseguro
            AND tomadores.sperson = v_sperson_tom
            AND TO_CHAR(fvalmov, 'YYYY') = TO_CHAR(anyo)
            AND f_parproductos_v(seguros.sproduc, 'APORTMAXIMAS') = 1
            AND(ctaseguro.ctipapor <> 'SP')
            AND seguros.sseguro = riesgos.sseguro
            AND riesgos.fanulac IS NULL
            AND riesgos.sperson = v_sperson;

                 --AND CMOVANU <> 1;
--dbms_output.put_line('ppa impctaseguro ='||impctaseguro);
                 -- Aportaciones realizadas por el aportante o promotor  en otro plan durante al año.
         SELECT SUM(NVL(trasplainout.iimpanu, 0))
           INTO importeanualotra
           FROM trasplainout, riesgos, ctaseguro, tomadores
          WHERE cinout = 1
            AND trasplainout.cestado IN(3, 4)   -- 3 = Traspaso pdte. informar; 4 = Traspasado
            AND tomadores.sseguro = riesgos.sseguro
            AND tomadores.sperson = v_sperson_tom
            AND trasplainout.sseguro = riesgos.sseguro
            AND riesgos.sperson = v_sperson
            AND riesgos.fanulac IS NULL
            --AND TRASPLAINOUT.CEXTERNO = 'E'
            AND trasplainout.sseguro = ctaseguro.sseguro
            AND trasplainout.nnumlin = ctaseguro.nnumlin
            AND TO_CHAR(fvalmov, 'YYYY') = TO_CHAR(anyo);

--dbms_output.put_line('ppa importe_anual ='||importeanualotra);
         importeanual := NVL(importeanualotra, 0) + NVL(impctaseguro, 0);
      END IF;

      RETURN importeanual;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_ppa_planes.calcula_importe_anual_poliza', NULL,
                     ' sseguro =' || psseguro || ' anyo ' || anyo, SQLERRM);
         RETURN NULL;
   END calcula_importe_anual_poliza;

   FUNCTION ff_importe_por_aportar_poliza(
      anyo IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      porigen IN NUMBER DEFAULT 2)
      RETURN NUMBER IS
      aport_max      NUMBER;
      aport_realizadas NUMBER;
      ntipo_apor     NUMBER;
      v_pendiente_por_persona NUMBER;
   BEGIN
      ntipo_apor := ff_tipo_aportante(NULL, psseguro);

      IF ntipo_apor IN(1, 2) THEN
         RETURN ff_importe_por_aportar_persona(anyo, psseguro, pnriesgo, NULL, NULL, porigen);
      ELSIF ntipo_apor IN(3, 4) THEN
         -- Primero calculamos aportaciones máximas este anyo
         aport_max := NVL(pac_ppa_planes.calcula_importe_maximo_poliza(anyo, psseguro,
                                                                       pnriesgo, porigen),
                          0);
         aport_realizadas := NVL(pac_ppa_planes.calcula_importe_anual_poliza(anyo, psseguro,
                                                                             pnriesgo,
                                                                             porigen),
                                 0);
         -- ahora calulamos el pendiente de aportar por persona
         v_pendiente_por_persona := ff_importe_por_aportar_persona(anyo, psseguro, pnriesgo,
                                                                   NULL, NULL, porigen);
         -- retornamos el menor
         RETURN LEAST((aport_max - aport_realizadas), v_pendiente_por_persona);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_ppa_planes.ff_importe_por_aportar_poliza', NULL,
                     ' sseguro =' || psseguro || ' anyo ' || anyo, SQLERRM);
         RETURN NULL;
   END ff_importe_por_aportar_poliza;

   FUNCTION calcula_imp_maximo_simulacion(anyo IN NUMBER, pfnacimi IN DATE, pctipapor IN NUMBER)
      RETURN NUMBER IS
      /***************************************************************************************************************
        Calcula el importe máximo de aportaciones que puede realizar una persona en una simulacion impersonal,
       es decir, sólo sabremos la fecha de nacimiento y el tipo de partícipe.
       ************************************************************************************************************/
      fin_anyo       DATE;
      edad           NUMBER;
      num_err        NUMBER;
      v_importe_maximo NUMBER;
   BEGIN
      fin_anyo := TO_DATE('3112' || anyo, 'ddmmyyyy');
      -- Calculamos la edad
      num_err := f_difdata(pfnacimi, fin_anyo, 1, 1, edad);
      v_importe_maximo := ff_limite_aportaciones(anyo, pctipapor, edad);
      RETURN v_importe_maximo;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_ppa_planes.calcula_imp_maximo_simulacion', NULL,
                     'anyo ' || anyo || ' fnacimi =' || pfnacimi || 'pctipapor=' || pctipapor,
                     SQLERRM);
         RETURN NULL;
   END calcula_imp_maximo_simulacion;

   FUNCTION ff_total_aportaciones_per(
      psseguro IN NUMBER,
      pfechaini IN NUMBER,
      pfechafin IN NUMBER)
      RETURN NUMBER IS
      vfechaini      DATE;
      vfechafin      DATE;
      vresultado     NUMBER;
   BEGIN
      vfechaini := TO_DATE(TO_CHAR(pfechaini), 'yyyymmdd');
      vfechafin := TO_DATE(TO_CHAR(pfechafin), 'yyyymmdd');

      SELECT   SUM(DECODE(c.cmovimi, 51, c.imovimi * -1, c.imovimi))
          INTO vresultado
          FROM ctaseguro c, seguros s
         WHERE s.sseguro = c.sseguro
           AND c.cmovimi IN(1, 2, 4, 51)
           --AND c.fvalmov >= vfechaini
           --AND c.fvalmov <= vfechafin
           AND((TRUNC(c.fvalmov) BETWEEN vfechaini AND vfechafin
                AND TRUNC(c.fcontab) <= vfechafin)
               OR(TRUNC(c.fcontab) BETWEEN vfechaini AND vfechafin
                  AND c.fvalmov <= vfechaini))
           AND s.sseguro = psseguro
      ORDER BY c.sseguro;

      RETURN vresultado;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END ff_total_aportaciones_per;

   FUNCTION ff_total_prestaciones_per(
      psseguro IN NUMBER,
      pfechaini IN NUMBER,
      pfechafin IN NUMBER)
      RETURN NUMBER IS
      vfechaini      DATE;
      vfechafin      DATE;
      vresultado     NUMBER;
      -- Bug 14582 - RSC - 08/10/2010 - CIV800 - Informe trimestral PPA
      v_sproduc      productos.sproduc%TYPE;
   -- Fin Bug
   BEGIN
      vfechaini := TO_DATE(TO_CHAR(pfechaini), 'yyyymmdd');
      vfechafin := TO_DATE(TO_CHAR(pfechafin), 'yyyymmdd');

      -- Bug 14582 - RSC - 08/10/2010 - CIV800 - Informe trimestral PPA
      SELECT sproduc
        INTO v_sproduc
        FROM seguros
       WHERE sseguro = psseguro;

      IF NVL(f_parproductos_v(v_sproduc, 'TIPO_LIMITE'), 0) = 1 THEN
         SELECT   SUM(c.imovimi)
             INTO vresultado
             FROM ctaseguro c, seguros s
            WHERE s.sseguro = c.sseguro
              AND c.cmovimi IN(31, 33, 34, 53)
              AND NVL(c.cmovanu, 0) = 0
              AND((TRUNC(c.fvalmov) BETWEEN vfechaini AND vfechafin
                   AND TRUNC(c.fcontab) <= vfechafin)
                  OR(TRUNC(c.fcontab) BETWEEN vfechaini AND vfechafin
                     AND c.fvalmov <= vfechaini))
              AND s.sseguro = psseguro
         ORDER BY c.sseguro;
      ELSE
         -- Fin Bug 14582
         SELECT   SUM(c.imovimi)
             INTO vresultado
             FROM ctaseguro c, seguros s
            WHERE s.sseguro = c.sseguro
              AND c.cmovimi IN(31, 53)
              AND NVL(c.cmovanu, 0) = 0
              AND((TRUNC(c.fvalmov) BETWEEN vfechaini AND vfechafin
                   AND TRUNC(c.fcontab) <= vfechafin)
                  OR(TRUNC(c.fcontab) BETWEEN vfechaini AND vfechafin
                     AND c.fvalmov <= vfechaini))
              AND s.sseguro = psseguro
         ORDER BY c.sseguro;
      END IF;

      RETURN vresultado;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END ff_total_prestaciones_per;

   FUNCTION ff_total_traspasoentrada_per(
      psseguro IN NUMBER,
      pfechaini IN NUMBER,
      pfechafin IN NUMBER)
      RETURN NUMBER IS
      vfechaini      DATE;
      vfechafin      DATE;
      vresultado     NUMBER;
   BEGIN
      vfechaini := TO_DATE(TO_CHAR(pfechaini), 'yyyymmdd');
      vfechafin := TO_DATE(TO_CHAR(pfechafin), 'yyyymmdd');

      SELECT   SUM(c.imovimi)
          INTO vresultado
          FROM ctaseguro c, seguros s
         WHERE s.sseguro = c.sseguro
           AND c.cmovimi = 8   -- Traspaso de entrada
           AND NVL(c.cmovanu, 0) = 0
           --AND c.fvalmov >= vfechaini
           --AND c.fvalmov <= vfechafin
           AND((TRUNC(c.fvalmov) BETWEEN vfechaini AND vfechafin
                AND TRUNC(c.fcontab) <= vfechafin)
               OR(TRUNC(c.fcontab) BETWEEN vfechaini AND vfechafin
                  AND c.fvalmov <= vfechaini))
           AND s.sseguro = psseguro
      ORDER BY c.sseguro;

      RETURN vresultado;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END ff_total_traspasoentrada_per;

   FUNCTION ff_total_traspasosalida_per(
      psseguro IN NUMBER,
      pfechaini IN NUMBER,
      pfechafin IN NUMBER)
      RETURN NUMBER IS
      vfechaini      DATE;
      vfechafin      DATE;
      vresultado     NUMBER;
   BEGIN
      vfechaini := TO_DATE(TO_CHAR(pfechaini), 'yyyymmdd');
      vfechafin := TO_DATE(TO_CHAR(pfechafin), 'yyyymmdd');

      SELECT   SUM(c.imovimi)
          INTO vresultado
          FROM ctaseguro c, seguros s
         WHERE s.sseguro = c.sseguro
           AND c.cmovimi = 47   -- Traspaso de salida
           AND NVL(c.cmovanu, 0) = 0
           --AND c.fvalmov >= vfechaini
           --AND c.fvalmov <= vfechafin
           AND((TRUNC(c.fvalmov) BETWEEN vfechaini AND vfechafin
                AND TRUNC(c.fcontab) <= vfechafin)
               OR(TRUNC(c.fcontab) BETWEEN vfechaini AND vfechafin
                  AND c.fvalmov <= vfechaini))
           AND s.sseguro = psseguro
      ORDER BY c.sseguro;

      RETURN vresultado;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END ff_total_traspasosalida_per;

-----------------------------------------------------------------------------------------------
-- BUG 0010132 - 21/07/2009 - jgarciam - fUNCIONS PER AL CALCUL DE ppaS
-----------------------------------------------------------------------------------------------
   /*************************************************************************
       FUNCTION ff_total_retenc_per
       Función que retornará El TOTAL retencio
       param in
   PSSEGURO IN NUMBER
   PFECHAINI in date
   pfechafin IN DATE
       return             : Devolverá una numérico con el TOTAL
   *************************************************************************/
   FUNCTION ff_total_retenc_per(psseguro IN NUMBER, pfechaini IN NUMBER, pfechafin IN NUMBER)
      RETURN NUMBER IS
      vfechaini      DATE;
      vfechafin      DATE;
      vresultado     NUMBER;
      v_cempres      NUMBER;
      -- Bug 14582 - RSC - 08/10/2010 - CIV800 - Informe trimestral PPA
      v_sproduc      productos.sproduc%TYPE;
   -- Fin Bug 14582
   BEGIN
      vfechaini := TO_DATE(TO_CHAR(pfechaini), 'yyyymmdd');
      vfechafin := TO_DATE(TO_CHAR(pfechafin), 'yyyymmdd');

      -- BUG 0011595 - 28/10/2009 - FAL - Adaptación al nuevo módulo de siniestros
      SELECT cempres, sproduc
        INTO v_cempres, v_sproduc
        FROM seguros
       WHERE sseguro = psseguro;

      IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'MODULO_SINI'), 0) = 0 THEN
         -- Bug 14582 - RSC - 08/10/2010 - CIV800 - Informe trimestral PPA
         IF NVL(f_parproductos_v(v_sproduc, 'TIPO_LIMITE'), 0) = 1 THEN
            SELECT   SUM(p.iretenc)
                INTO vresultado
                FROM ctaseguro c, seguros s, pagosini p, siniestros i
               WHERE s.sseguro = c.sseguro
                 AND i.nsinies = p.nsinies
                 AND i.sseguro = s.sseguro
                 AND c.cmovimi IN(47, 31, 33, 34, 53)
                 AND NVL(c.cmovanu, 0) = 0
                 AND((TRUNC(c.fvalmov) BETWEEN vfechaini AND vfechafin
                      AND TRUNC(c.fcontab) <= vfechafin)
                     OR(TRUNC(c.fcontab) BETWEEN vfechaini AND vfechafin
                        AND c.fvalmov <= vfechaini))
                 AND s.sseguro = psseguro
                 -- Bug 014582 - 18/05/2010 - RSC - CIV800 - Informe trimestral PPA
                 AND c.nsinies = p.nsinies
                 AND p.cestpag = 2
                 AND p.ctippag = 2
                 AND p.sidepag NOT IN(SELECT NVL(pp.spganul, 0)
                                        FROM pagosini pp
                                       WHERE nsinies = p.nsinies
                                         AND cestpag <> 8)
            -- Fin Bug 014582
            ORDER BY c.sseguro;
         ELSE
            -- Fin Bug 14582
            SELECT   SUM(p.iretenc)
                INTO vresultado
                FROM ctaseguro c, seguros s, pagosini p, siniestros i
               WHERE s.sseguro = c.sseguro
                 AND i.nsinies = p.nsinies
                 AND i.sseguro = s.sseguro
                 AND c.cmovimi IN(47, 31, 53)
                 AND NVL(c.cmovanu, 0) = 0
                 AND((TRUNC(c.fvalmov) BETWEEN vfechaini AND vfechafin
                      AND TRUNC(c.fcontab) <= vfechafin)
                     OR(TRUNC(c.fcontab) BETWEEN vfechaini AND vfechafin
                        AND c.fvalmov <= vfechaini))
                 AND s.sseguro = psseguro
                 -- Bug 014582 - 18/05/2010 - RSC - CIV800 - Informe trimestral PPA
                 AND c.nsinies = p.nsinies
                 AND p.cestpag = 2
                 AND p.ctippag = 2
                 AND p.sidepag NOT IN(SELECT NVL(pp.spganul, 0)
                                        FROM pagosini pp
                                       WHERE nsinies = p.nsinies
                                         AND cestpag <> 8)
            -- Fin Bug 014582
            ORDER BY c.sseguro;
         END IF;
      ELSE
         -- Bug 14582 - RSC - 08/10/2010 - CIV800 - Informe trimestral PPA
         IF NVL(f_parproductos_v(v_sproduc, 'TIPO_LIMITE'), 0) = 1 THEN
            SELECT   SUM(p.iretenc)
                INTO vresultado
                FROM ctaseguro c, seguros s, sin_tramita_pago p, sin_siniestro i,
                     sin_tramita_movpago m
               WHERE s.sseguro = c.sseguro
                 AND i.nsinies = p.nsinies
                 AND i.sseguro = s.sseguro
                 AND c.cmovimi IN(47, 31, 33, 34, 53)
                 AND NVL(c.cmovanu, 0) = 0
                 AND((TRUNC(c.fvalmov) BETWEEN vfechaini AND vfechafin
                      AND TRUNC(c.fcontab) <= vfechafin)
                     OR(TRUNC(c.fcontab) BETWEEN vfechaini AND vfechafin
                        AND c.fvalmov <= vfechaini))
                 AND s.sseguro = psseguro
                 -- Bug 014582 - 18/05/2010 - RSC - CIV800 - Informe trimestral PPA
                 AND c.nsinies = p.nsinies
                 AND p.sidepag = m.sidepag
                 AND m.nmovpag = (SELECT MAX(nmovpag)
                                    FROM sin_tramita_movpago
                                   WHERE sidepag = m.sidepag)
                 AND m.cestpag = 2
                 AND p.ctippag = 2
                 AND m.cestpag <> 8
            -- Fin Bug 014582
            ORDER BY c.sseguro;
         ELSE
            -- Fin Bug 14582
            SELECT   SUM(p.iretenc)
                INTO vresultado
                FROM ctaseguro c, seguros s, sin_tramita_pago p, sin_siniestro i,
                     sin_tramita_movpago m
               WHERE s.sseguro = c.sseguro
                 AND i.nsinies = p.nsinies
                 AND i.sseguro = s.sseguro
                 AND c.cmovimi IN(47, 31, 53)
                 AND NVL(c.cmovanu, 0) = 0
                 AND((TRUNC(c.fvalmov) BETWEEN vfechaini AND vfechafin
                      AND TRUNC(c.fcontab) <= vfechafin)
                     OR(TRUNC(c.fcontab) BETWEEN vfechaini AND vfechafin
                        AND c.fvalmov <= vfechaini))
                 AND s.sseguro = psseguro
                 -- Bug 014582 - 18/05/2010 - RSC - CIV800 - Informe trimestral PPA
                 AND c.nsinies = p.nsinies
                 AND p.sidepag = m.sidepag
                 AND m.nmovpag = (SELECT MAX(nmovpag)
                                    FROM sin_tramita_movpago
                                   WHERE sidepag = m.sidepag)
                 AND m.cestpag = 2
                 AND p.ctippag = 2
                 AND m.cestpag <> 8
            -- Fin Bug 014582
            ORDER BY c.sseguro;
         END IF;
      END IF;

-- FI BUG 0011595 - 28/10/2009 - FAL
      RETURN vresultado;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END ff_total_retenc_per;

-----------------------------------------------------------------------------------------------
-- BUG 0010132 - 21/07/2009 - jgarciam - fUNCIONS PER AL CALCUL DE ppaS
-----------------------------------------------------------------------------------------------
   /*************************************************************************
       FUNCTION ff_total_REDUC_per
       Función que retornará El TOTAL REduccio
       param in
   PSSEGURO IN NUMBER
   PFECHAINI in date
   pfechafin IN DATE
       return             : Devolverá una numérico con el TOTAL
   *************************************************************************/
   FUNCTION ff_total_reduc_per(psseguro IN NUMBER, pfechaini IN NUMBER, pfechafin IN NUMBER)
      RETURN NUMBER IS
      vfechaini      DATE;
      vfechafin      DATE;
      vresultado     NUMBER;
      v_cempres      NUMBER;
      -- Bug 14582 - RSC - 08/10/2010 - CIV800 - Informe trimestral PPA
      v_sproduc      productos.sproduc%TYPE;
   -- Fin Bug 14582
   BEGIN
      vfechaini := TO_DATE(TO_CHAR(pfechaini), 'yyyymmdd');
      vfechafin := TO_DATE(TO_CHAR(pfechafin), 'yyyymmdd');

      -- BUG 0011595 - 28/10/2009 - FAL - Adaptación al nuevo módulo de siniestros
      SELECT cempres, sproduc
        INTO v_cempres, v_sproduc
        FROM seguros
       WHERE sseguro = psseguro;

      IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'MODULO_SINI'), 0) = 0 THEN
         -- Bug 14582 - RSC - 08/10/2010 - CIV800 - Informe trimestral PPA
         IF NVL(f_parproductos_v(v_sproduc, 'TIPO_LIMITE'), 0) = 1 THEN
            SELECT   SUM(p.iresred)
                INTO vresultado
                FROM ctaseguro c, seguros s, pagosini p, siniestros i
               WHERE s.sseguro = c.sseguro
                 AND i.nsinies = p.nsinies
                 AND i.sseguro = s.sseguro
                 AND c.cmovimi IN(47, 31, 33, 34, 53)
                 AND NVL(c.cmovanu, 0) = 0
                 AND((TRUNC(c.fvalmov) BETWEEN vfechaini AND vfechafin
                      AND TRUNC(c.fcontab) <= vfechafin)
                     OR(TRUNC(c.fcontab) BETWEEN vfechaini AND vfechafin
                        AND c.fvalmov <= vfechaini))
                 AND s.sseguro = psseguro
                 -- Bug 014582 - 18/05/2010 - RSC - CIV800 - Informe trimestral PPA
                 AND c.nsinies = p.nsinies
                 AND p.cestpag = 2
                 AND p.ctippag = 2
                 AND p.sidepag NOT IN(SELECT NVL(pp.spganul, 0)
                                        FROM pagosini pp
                                       WHERE nsinies = p.nsinies
                                         AND cestpag <> 8)
            -- Fin Bug 014582
            ORDER BY c.sseguro;
         ELSE
            -- Fin Bug 14582
            SELECT   SUM(p.iresred)
                INTO vresultado
                FROM ctaseguro c, seguros s, pagosini p, siniestros i
               WHERE s.sseguro = c.sseguro
                 AND i.nsinies = p.nsinies
                 AND i.sseguro = s.sseguro
                 AND c.cmovimi IN(47, 31, 53)
                 AND NVL(c.cmovanu, 0) = 0
                 AND((TRUNC(c.fvalmov) BETWEEN vfechaini AND vfechafin
                      AND TRUNC(c.fcontab) <= vfechafin)
                     OR(TRUNC(c.fcontab) BETWEEN vfechaini AND vfechafin
                        AND c.fvalmov <= vfechaini))
                 AND s.sseguro = psseguro
                 -- Bug 014582 - 18/05/2010 - RSC - CIV800 - Informe trimestral PPA
                 AND c.nsinies = p.nsinies
                 AND p.cestpag = 2
                 AND p.ctippag = 2
                 AND p.sidepag NOT IN(SELECT NVL(pp.spganul, 0)
                                        FROM pagosini pp
                                       WHERE nsinies = p.nsinies
                                         AND cestpag <> 8)
            -- Fin Bug 014582
            ORDER BY c.sseguro;
         END IF;
      ELSE
         -- Bug 14582 - RSC - 08/10/2010 - CIV800 - Informe trimestral PPA
         IF NVL(f_parproductos_v(v_sproduc, 'TIPO_LIMITE'), 0) = 1 THEN
            SELECT   SUM(p.iresred)
                INTO vresultado
                FROM ctaseguro c, seguros s, sin_tramita_pago p, sin_siniestro i,
                     sin_tramita_movpago m
               WHERE s.sseguro = c.sseguro
                 AND i.nsinies = p.nsinies
                 AND i.sseguro = s.sseguro
                 AND c.cmovimi IN(47, 31, 33, 34, 53)
                 AND NVL(c.cmovanu, 0) = 0
                 AND((TRUNC(c.fvalmov) BETWEEN vfechaini AND vfechafin
                      AND TRUNC(c.fcontab) <= vfechafin)
                     OR(TRUNC(c.fcontab) BETWEEN vfechaini AND vfechafin
                        AND c.fvalmov <= vfechaini))
                 AND s.sseguro = psseguro
                 -- Bug 014582 - 18/05/2010 - RSC - CIV800 - Informe trimestral PPA
                 AND c.nsinies = p.nsinies
                 AND p.sidepag = m.sidepag
                 AND m.nmovpag = (SELECT MAX(nmovpag)
                                    FROM sin_tramita_movpago
                                   WHERE sidepag = m.sidepag)
                 AND m.cestpag = 2
                 AND p.ctippag = 2
                 AND m.cestpag <> 8
            -- Fin Bug 014582
            ORDER BY c.sseguro;
         ELSE
            -- Fin Bug 14582
            SELECT   SUM(p.iresred)
                INTO vresultado
                FROM ctaseguro c, seguros s, sin_tramita_pago p, sin_siniestro i,
                     sin_tramita_movpago m
               WHERE s.sseguro = c.sseguro
                 AND i.nsinies = p.nsinies
                 AND i.sseguro = s.sseguro
                 AND c.cmovimi IN(47, 31, 53)
                 AND NVL(c.cmovanu, 0) = 0
                 AND((TRUNC(c.fvalmov) BETWEEN vfechaini AND vfechafin
                      AND TRUNC(c.fcontab) <= vfechafin)
                     OR(TRUNC(c.fcontab) BETWEEN vfechaini AND vfechafin
                        AND c.fvalmov <= vfechaini))
                 AND s.sseguro = psseguro
                 -- Bug 014582 - 18/05/2010 - RSC - CIV800 - Informe trimestral PPA
                 AND c.nsinies = p.nsinies
                 AND p.sidepag = m.sidepag
                 AND m.nmovpag = (SELECT MAX(nmovpag)
                                    FROM sin_tramita_movpago
                                   WHERE sidepag = m.sidepag)
                 AND m.cestpag = 2
                 AND p.ctippag = 2
                 AND m.cestpag <> 8
            -- Fin Bug 014582
            ORDER BY c.sseguro;
         END IF;
      END IF;

      -- FI BUG 0011595 - 28/10/2009 - FAL
      RETURN vresultado;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END ff_total_reduc_per;
-----------------------------------------------------------------------------------------------
-- fi BUG 0010132 - 21/07/2009 - jgarciam - fUNCIONS PER AL CALCUL DE ppaS
-----------------------------------------------------------------------------------------------
END pac_ppa_planes;

/

  GRANT EXECUTE ON "AXIS"."PAC_PPA_PLANES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PPA_PLANES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PPA_PLANES" TO "PROGRAMADORESCSI";
