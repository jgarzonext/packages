--------------------------------------------------------
--  DDL for Package Body PAC_MATCHING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MATCHING" AS
   /****************************************************************************
        NOM:      PAC_MATCHING
        PROPÒSIT:

        REVISIONS:
        Ver        Data        Autor             Descripció
        ---------  ----------  ---------------  ----------------------------------
        1.0        08/07/2009  DCT               1. BUG 0010612: CRE - Error en la generació de pagaments automàtics.
                                                  Canviar vista personas por tablas personas y añadir filtro de visión de agente.
     ****************************************************************************/
   FUNCTION f_sictr026(
      pcidioma IN seguros.cidioma%TYPE,
      pffecha IN DATE,
      pcempresa IN seguros.cempres%TYPE)
      RETURN NUMBER IS
      -- Variables de proceso
      perror         NUMBER;
      ex_error       EXCEPTION;
      ex_jump        EXCEPTION;
      vsproduc_ant   NUMBER := -1;
      vsproduc_cur   NUMBER := -1;
      vsseguro_cur   NUMBER := -1;
      vsseguro_ant   NUMBER := -1;
      vyears         NUMBER;
      vany           NUMBER;
      vfejerc        DATE;
      -- Pagos probables
      vpprobsuperv   NUMBER;
      vpprobfallec   NUMBER;
      vpprobrentas   NUMBER;
      vprovision     NUMBER;
      -- Fracciones
      vfraccion      NUMBER;
      vanyfcalc      NUMBER;
      vanyfvenc      NUMBER;
      -- Capital fallecimiento
      vcapfallpond   NUMBER;
      vprobfall      NUMBER;
      -- Renta de supervivencia (LRC y Renta Plus)
      vrentapond     NUMBER;
      vprobsuperv    NUMBER;
      -- Provisión
      vmaxnmovimi    NUMBER;
      vffinal        NUMBER;
      -- Rentas
      vcforpag       NUMBER;
      -- Fecha de vencimiento (teniendo en cuenta revisiones, etc)
      vvcto          DATE;
      -- Claves
      vclaveprovac   NUMBER;   -- Clave para calcular la IPROVAC del producto Ibex 35 Garantizado (parte de Europlazo)
      vclavecgarac   NUMBER;   -- Clave para calcular la IPROVAC del producto Ibex 35 Garantizado (parte de Europlazo)
      vclavecfallac  NUMBER;   -- Clave para calcular la ICFALLAC del producto Ibex 35 Garantizado (parte de Europlazo)
      -- Provisión del RVI a fecha de revisión (Rescate al final del período garantizado)
      vprovac_200    NUMBER;
      vfrevisio      DATE;
      vprovmibex     NUMBER;
      vcgareur       NUMBER;
      vcfallibex     NUMBER;
      -- SPROCES
      v_sproces      NUMBER;
      nerrores       NUMBER := 0;   -- numero de errores en el proceso
      -- En tabla
      lv_flujo       flujo_pasivos%ROWTYPE;
      lv_detflujo    detflujo_pasivos%ROWTYPE;
      -- Linea
      vlinea         NUMBER := 1;
      vregistro      NUMBER;
      vtraza         NUMBER;
      vprimer        NUMBER := 1;
      ttexto         VARCHAR2(200);
      texto          VARCHAR2(400);
      vconterr       NUMBER := 0;
      nlin           NUMBER;
      vcf1           NUMBER;
      vcf2           NUMBER;
      vanysrev       NUMBER;
      vfrac3         NUMBER;
      vdfcvctfra     NUMBER;
      vdfc3112fra    NUMBER;
      vfrevanyo      DATE;
      -- RSC 25/11/2008
      vfactor        NUMBER;
      vfprovmat      DATE;
      vdiaprogresion NUMBER;
   BEGIN
      vtraza := 1;
      perror := f_procesini(f_user, 1, 'F.PASIVOS:' || TO_CHAR(pffecha, 'dd/mm/yyyy'),
                            f_literal(180757, pcidioma), v_sproces);

      FOR r_dades IN (SELECT   s.sseguro, f_formatopol(s.npoliza, s.ncertif, 1) contrato,
                               s.sproduc, s.cramo, r.tramo, s.fefecto,
                               NVL(s.fvencim, sa.frevisio) vct, sa.frevisio, i.pinttec,
                               pp.ipromat provmat, pp.ivalact cfall, pp.icapgar capgar,
                               pp.fcalcul
                          FROM seguros s, seguros_aho sa, intertecseg i, ramos r, provmat pp
                         WHERE NVL(f_parproductos_v(s.sproduc, 'MATCHING'), 0) = 1
--and s.sseguro in (600056, 600055, 600198,600195,600195,619620,600276,600055,600089,600055,600051,600047,600040,619620,619003,618959,611699,612272,612268)
--and s.sseguro in (600051,600047,611699)
--and s.sseguro = 611699
                           AND s.sseguro = i.sseguro
                           AND i.nmovimi = (SELECT MAX(i2.nmovimi)
                                              FROM intertecseg i2
                                             WHERE i2.sseguro = i.sseguro
                                               AND i2.fefemov <= TRUNC(pp.fcalcul))   -- bug 480
                           AND i.pinttec > (SELECT interes
                                              FROM matching
                                             WHERE cmatching = 1
                                               AND finicial <= TRUNC(pp.fcalcul)
                                               AND(ffinal >= TRUNC(pp.fcalcul)
                                                   OR ffinal IS NULL))
                           AND s.fefecto > (SELECT fecha
                                              FROM matching
                                             WHERE cmatching = 1
                                               AND finicial <= TRUNC(pp.fcalcul)
                                               AND(ffinal >= TRUNC(pp.fcalcul)
                                                   OR ffinal IS NULL))
                           AND s.csituac = 0
                           AND s.sseguro = sa.sseguro(+)
                           AND s.cramo = r.cramo
                           AND r.cidioma = pcidioma
                           AND s.sseguro = pp.sseguro
                           AND pp.fcalcul = (SELECT MAX(fcalcul)
                                               FROM provmat
                                              WHERE sseguro = s.sseguro
                                                AND TRUNC(fcalcul) <= TRUNC(pffecha))
                      ORDER BY s.sproduc, s.sseguro) LOOP
         BEGIN
            -- Realizamos validación y eliminamos datos anteriores del mismo cierre
            IF vprimer = 1 THEN   -- Tratamiento solo una vez
               vtraza := 2;
               perror := f_valida_existe_delete(r_dades.fcalcul);

               IF perror IS NULL THEN
                  RAISE ex_error;
               END IF;

               vprimer := 0;
            END IF;

            -- Fecha de cálculo
            lv_flujo := NULL;
            lv_detflujo := NULL;
            lv_flujo.sproces := v_sproces;
            lv_flujo.fcalcul := f_sysdate;
            lv_flujo.fvalor := r_dades.fcalcul;
            vsproduc_cur := r_dades.sproduc;

            IF vsproduc_cur <> vsproduc_ant THEN
               vsproduc_ant := vsproduc_cur;
            END IF;

            vtraza := 3;
            vsseguro_cur := r_dades.sseguro;

            IF vsseguro_cur <> vsseguro_ant THEN
               /********************************************************************
                 Obtención de cálculos iniciales (valores actuales de provisión,
                 capital de fallecimiento y renta bruta)
               ********************************************************************/
               IF NVL(f_parproductos_v(vsproduc_cur, 'ES_PRODUCTO_INDEXADO'), 0) <> 1 THEN
                  --lv_flujo.provper := r_dades.provmat;
                  lv_flujo.provper := r_dades.capgar;
                  lv_flujo.cfallec := r_dades.cfall;
               ELSE   -- Ibex 35 Garantizado
                  --SELECT clave INTO vclavecgarac FROM garanformula WHERE cramo = r_dades.cramo AND ccampo = 'ICGARAC' AND cgarant = 283;

                  -- Parte de Ibex 35 de la provisión en la fecha de cierre
                  --perror := Pac_Calculo_Formulas.CALC_FORMUL (r_dades.fcalcul,vsproduc_cur, 0, 48,1, vsseguro_cur, vclavecgarac, vcgarEur, NULL, NULL, 2, r_dades.fcalcul, 'R');
                  --lv_flujo.provper := vcgarEur; --r_dades.provmat - vprovmIbex;
                  lv_flujo.provper := r_dades.capgar;

                  -- Parte de Ibex 35 del Capital de Fallecimiento en la fecha de cierre
                  --SELECT clave INTO vclavecfallac FROM garanformula WHERE cramo = r_dades.cramo AND ccampo = 'IPROVAC' AND cgarant = 48;
                  SELECT clave
                    INTO vclavecfallac
                    FROM garanformula
                   WHERE cramo = r_dades.cramo
                     AND ccampo = 'ICFALLAC'
                     AND cgarant = 48;

                  perror := pac_calculo_formulas.calc_formul(r_dades.fcalcul, vsproduc_cur, 0,
                                                             48, 1, vsseguro_cur,
                                                             vclavecfallac, vcfallibex, NULL,
                                                             NULL, 2, r_dades.fcalcul, 'R');
                  lv_flujo.cfallec := r_dades.cfall - vcfallibex;
               --SELECT clave INTO vclavecfallac FROM garanformula WHERE cramo = r_dades.cramo AND ccampo = 'ICFALLAC' AND cgarant = 283;
               --perror := Pac_Calculo_Formulas.CALC_FORMUL (r_dades.fcalcul,vsproduc_cur, 0, 283,1, vsseguro_cur, vclavecfallac, lv_flujo.cfallec, NULL, NULL, 2, r_dades.fcalcul, 'R'); --ICFALLAC Europlazo
               END IF;

               IF NVL(f_parproductos_v(vsproduc_cur, 'ES_PRODUCTO_RENTAS'), 0) = 1 THEN
                  IF NVL(f_parproductos_v(vsproduc_cur, 'PLAN_RENTAS'), 0) = 0 THEN   --Si no tiene plan de rentas las garantias deben tener informadas las rentas
                     SELECT MAX(nmovimi)
                       INTO vmaxnmovimi
                       FROM movseguro
                      WHERE sseguro = vsseguro_cur;

                     lv_flujo.renta := pac_calc_comu.ff_capital_gar_tipo('', vsseguro_cur, 1,
                                                                         8, vmaxnmovimi);
                  ELSE
                     SELECT cforpag
                       INTO vcforpag
                       FROM seguros_ren
                      WHERE sseguro = vsseguro_cur;

                     lv_flujo.renta :=
                        pk_rentas.f_buscarentabruta(1, vsseguro_cur,
                                                    TO_NUMBER(TO_CHAR(lv_flujo.fvalor,
                                                                      'yyyymmdd')),
                                                    2);
                     lv_flujo.renta := lv_flujo.renta * vcforpag;
                  END IF;
               END IF;

               lv_flujo.sseguro := vsseguro_cur;
               lv_flujo.falta := r_dades.fefecto;
               --lv_flujo.frevisio := r_dades.frevisio;
               vanysrev := TO_NUMBER(TO_CHAR(lv_flujo.fvalor, 'YYYY'))
                           - TO_NUMBER(TO_CHAR(lv_flujo.falta, 'YYYY'));
               lv_flujo.frevisio := ADD_MONTHS(lv_flujo.falta, vanysrev * 12);

               IF lv_flujo.fvalor > lv_flujo.frevisio THEN
                  lv_flujo.frevisio := ADD_MONTHS(lv_flujo.frevisio, 12);
               END IF;

               lv_flujo.fvencim := r_dades.vct;
               vsseguro_ant := vsseguro_cur;
            END IF;

            -- Datos asegurado 1 -----------------------------------------
            vtraza := 4;
            perror := f_datos_asegurado(vsseguro_cur, 1, pcidioma, lv_flujo.fnacimi1,
                                        lv_flujo.csexo1);

            IF perror <> 0 THEN
               ROLLBACK;
               texto := f_axis_literales(perror, pcidioma);
               perror := f_proceslin(v_sproces, ttexto || ' - FLUJO_PASIVOS ', vsseguro_cur,
                                     nlin);
               COMMIT;
               vconterr := vconterr + 1;
               nlin := NULL;
               RAISE ex_jump;
            --P_Tab_Error (F_Sysdate, F_User, 'pac_matching.f_sictr026', vtraza, 'sproces = '||v_sproces, SQLERRM);
            --RAISE ex_Error;
            END IF;

------------------------------------------------------

            -- Datos asegurado 2 -----------------------------------------
            vtraza := 5;
            perror := f_datos_asegurado(vsseguro_cur, 2, pcidioma, lv_flujo.fnacimi2,
                                        lv_flujo.csexo2);

            IF perror <> 0 THEN
               ROLLBACK;
               texto := f_axis_literales(perror, pcidioma);
               perror := f_proceslin(v_sproces, ttexto || ' - FLUJO_PASIVOS ', vsseguro_cur,
                                     nlin);
               COMMIT;
               vconterr := vconterr + 1;
               nlin := NULL;
               RAISE ex_jump;
            --P_Tab_Error (F_Sysdate, F_User, 'pac_matching.f_sictr026', vtraza, 'sproces = '||v_sproces, SQLERRM);
            --RAISE ex_Error;
            END IF;

------------------------------------------------------

            -- Obtenemos ejercicio final de cálculo (Vencimiento)
            IF NVL(f_parproductos_v(vsproduc_cur, 'ES_PRODUCTO_RENTAS'), 0) <> 1 THEN
               IF NVL(f_parproductos_v(vsproduc_cur, 'RENOVA_REVISA'), 0) = 2 THEN   -- Europlazo 16 y Euroterm 16
                  vvcto := r_dades.frevisio;
               ELSE
                  vvcto := r_dades.vct;
               END IF;
            ELSE
               vvcto := r_dades.vct;   -- Rentas (RVI no tiene vencimiento (=null) por tanto la query ya coge la fecha de revisión)
            END IF;

            -- Cálculo de fracciones -----------------------------------------------
            vanyfcalc := TO_NUMBER(TO_CHAR(lv_flujo.fvalor, 'YYYY'));
            vanyfvenc := TO_NUMBER(TO_CHAR(vvcto, 'YYYY'));
            vtraza := 6;
            perror := f_calc_fracciones(lv_flujo.fvalor, lv_flujo.frevisio, lv_flujo.d0101vcto,
                                        lv_flujo.frac2, lv_flujo.dfc3112, lv_flujo.frac1,
                                        lv_flujo.dfcvcto, lv_flujo.fracb, vsproduc_cur);
            --   bug557  08/01/2009 -- lv_flujo.frevisio,
            lv_flujo.frevisio := NVL(r_dades.frevisio, lv_flujo.frevisio);
------------------------------------------------------------------------

            /***********************************************************************
  Valor de rescate
***********************************************************************/
            vtraza := 7;
            perror := f_valor_rescate_match(vsseguro_cur, vsproduc_cur, pcidioma,
                                            lv_flujo.fvalor, r_dades.provmat,   --lv_flujo.provper,
                                            lv_flujo.rescate);

            IF perror <> 0 THEN
               ROLLBACK;
               texto := f_axis_literales(perror, pcidioma);
               perror := f_proceslin(v_sproces, ttexto || ' - FLUJO_PASIVOS ', vsseguro_cur,
                                     nlin);
               COMMIT;
               vconterr := vconterr + 1;
               nlin := NULL;
               RAISE ex_jump;
            --P_Tab_Error (F_Sysdate, F_User, 'pac_matching.f_sictr026', vtraza, 'sproces = '||v_sproces, SQLERRM);
            --RAISE ex_Error;
            END IF;

--------------------------------------------------------------

            -- RSC 15/10/2008 ----------------------------------------------------
            IF NVL(f_parproductos_v(vsproduc_cur, 'PLAN_RENTAS'), 0) = 1 THEN
               lv_flujo.rescate := lv_flujo.provper;
            END IF;

----------------------------------------------------------------------

            -- Insertamos el FLUJO_PASIVO
            vtraza := 8;
            perror := f_inserta_flujo(lv_flujo);

            IF perror <> 0 THEN
               ROLLBACK;
               texto := f_axis_literales(perror, pcidioma);
               perror := f_proceslin(v_sproces, ttexto || ' - FLUJO_PASIVOS ', vsseguro_cur,
                                     nlin);
               COMMIT;
               vconterr := vconterr + 1;
               nlin := NULL;
               RAISE ex_jump;
            END IF;

            vregistro := 1;
            vprovac_200 := NULL;
            vany := TO_NUMBER(TO_CHAR(vvcto, 'YYYY'));
            vyears := TRUNC(MONTHS_BETWEEN(vvcto, r_dades.fefecto) / 12);
            vcf1 := NULL;
            vcf2 := NULL;

            WHILE vyears >= 0 LOOP   -- LOOP de Ejercicios
               -- Ejercicio
               vfejerc := TO_DATE('31/12/' ||(vany - vyears), 'dd/mm/yyyy');

               IF vfejerc > vvcto THEN
                  vfejerc := vvcto;
               END IF;

               -- Pago Probable Supervivencia -------------------------------------
               vtraza := 9;

               IF vfejerc >= lv_flujo.fvalor THEN
                  IF NVL(f_parproductos_v(vsproduc_cur, 'ES_PRODUCTO_RENTAS'), 0) = 1 THEN
                     IF NVL(f_parproductos_v(vsproduc_cur, 'PLAN_RENTAS'), 0) <> 1 THEN   -- RVI
                        /******************************************************************************************
                          Este IF de a continuación es para no llamar al calculo de la formula para cada iteración!
                          No es necesario! Con llamar una vez es suficiente para saber la provisión a fecha de
                          revisión!
                        *******************************************************************************************/
                        IF vprovac_200 IS NULL THEN
                           SELECT frevisio
                             INTO vfrevisio
                             FROM seguros_aho
                            WHERE sseguro = vsseguro_cur;

                           vprovac_200 :=
                              pac_provmat_formul.f_calcul_formulas_provi(vsseguro_cur,
                                                                         vfrevisio, 'IPROVAC');
                        END IF;
                     END IF;
                  END IF;

                  vtraza := 10;

                  -- Lo haremos así para minimizar el impacto
                  IF NVL(f_parproductos_v(vsproduc_cur, 'ES_PRODUCTO_RENTAS'), 0) = 1 THEN
                     vpprobsuperv :=
                        f_pprob_supervivencia_rentas
                                              (vsseguro_cur, r_dades.sproduc, lv_flujo.fvalor,   -- Fecha del momento de cálculo
                                               lv_flujo.fnacimi1, lv_flujo.csexo1,
                                               lv_flujo.fnacimi2, lv_flujo.csexo2, vfejerc,   -- Fecha del ejercicio
                                               vvcto, r_dades.capgar, vprovac_200);
                  ELSE
                     vpprobsuperv :=
                        f_pprob_supervivencia(vsseguro_cur, r_dades.sproduc, lv_flujo.fvalor,   -- Fecha del momento de cálculo
                                              lv_flujo.fnacimi1, lv_flujo.csexo1,
                                              lv_flujo.fnacimi2, lv_flujo.csexo2, vfejerc,   -- Fecha del ejercicio
                                              vvcto, r_dades.capgar, vprovac_200);
                  END IF;
               ELSE
                  vpprobsuperv := 0.00;   -- En ejercicio pasado ya no mostramos cálculos
               END IF;

--------------------------------------------------------------------

               -- Cálculo de fracciones -------------------------------------------
               vtraza := 11;

               IF TO_NUMBER(TO_CHAR(vfejerc, 'YYYY')) = vanyfcalc THEN
                  vfraccion := lv_flujo.frac1;
               ELSIF TO_NUMBER(TO_CHAR(vfejerc, 'YYYY')) = vanyfvenc THEN   -- Ejercicio final
                  IF vanyfvenc = vanyfcalc THEN
                     vfraccion := lv_flujo.fracb;
                  ELSE
                     vfraccion := lv_flujo.frac2;
                  END IF;
               ELSE
                  vfraccion := 1;
               END IF;

------------------------------------------------------------

               -- Capital de fallecimiento ponderado ------------------------------
               vtraza := 12;

               IF NVL(f_parproductos_v(vsproduc_cur, 'ES_PRODUCTO_RENTAS'), 0) <> 1 THEN
                  -- Valor constante
                  IF NVL(f_parproductos_v(vsproduc_cur, 'ES_PRODUCTO_INDEXADO'), 0) <> 1 THEN
                     vcapfallpond := pac_provmat_formul.f_calcul_formulas_provi(vsseguro_cur,
                                                                                vfejerc,
                                                                                'ICFALLAC');
                  ELSE   -- Ibex 35 Garantizado
                     SELECT clave
                       INTO vclavecfallac
                       FROM garanformula
                      WHERE cramo = r_dades.cramo
                        AND ccampo = 'ICFALLAC'
                        AND cgarant = 283;

                     perror := pac_calculo_formulas.calc_formul(vfejerc, vsproduc_cur, 0, 283,
                                                                1, vsseguro_cur, vclavecfallac,
                                                                vcapfallpond, NULL, NULL, 2,
                                                                vfejerc, 'R');   --ICFALLAC Europlazo
                  END IF;
               ELSE
                  -- En LRC el capital de fallecimiento es constante mientras que en RVI o Renta Plus se debe
                  -- retornar el CF en el momento de cálculo que precisamente es lv_flujo.cfallec
                  vcapfallpond := lv_flujo.cfallec;
               END IF;

               IF vcf1 IS NULL
                  AND vcf2 IS NULL THEN   -- Primer Iteracion
                  vcf1 := vcapfallpond;
                  vcf2 := vcapfallpond;
               ELSE   -- Iteraciones restantes
                  vcf2 := vcapfallpond;
               END IF;

-- RSC 25/11/2008
               IF NVL(f_parproductos_v(vsproduc_cur, 'ES_PRODUCTO_INDEXADO'), 0) = 1 THEN
                  BEGIN
                     SELECT fprovmat
                       INTO vfprovmat
                       FROM evoluprovmatseg
                      WHERE sseguro = vsseguro_cur
                        AND r_dades.fcalcul BETWEEN fprovmat AND ADD_MONTHS(fprovmat, 12);
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        vfprovmat := TO_DATE('01/01/2999', 'dd/mm/yyyy');   -- no deberia pasar nunca
                  END;

                  IF TO_NUMBER(TO_CHAR(vfprovmat, 'YYYY')) = vanyfcalc THEN
                     /********************************************
                         -- Ya  ha cumplido años en ejercicio
                     ********************************************/
                     IF TO_NUMBER(TO_CHAR(vfejerc, 'YYYY')) = vanyfcalc THEN
                        vfactor := ((vcf2 / vcf1) - 1) / 365;   -- Progesión aritmetica

                        SELECT r_dades.fcalcul - vfprovmat - 1
                          INTO vdiaprogresion
                          FROM DUAL;

                        lv_flujo.cfallec := vcf1 *(1 + vdiaprogresion * vfactor);
                     END IF;
                  ELSIF TO_NUMBER(TO_CHAR(vfprovmat, 'YYYY')) =(vanyfcalc - 1) THEN
                     /************************************************
                         -- No ha cumplido años en ejercicio todavia
                     *************************************************/
                     IF TO_NUMBER(TO_CHAR(vfejerc, 'YYYY')) =(vanyfcalc - 1) THEN
                        vfactor := ((vcf2 / vcf1) - 1) / 365;   -- Progesión aritmetica

                        SELECT r_dades.fcalcul - vfprovmat - 1
                          INTO vdiaprogresion
                          FROM DUAL;   --Ya ha cumplido años

                        lv_flujo.cfallec := vcf1 *(1 + vdiaprogresion * vfactor);
                     END IF;
                  END IF;

                  UPDATE flujo_pasivos
                     SET cfallec = lv_flujo.cfallec
                   WHERE sproces = lv_flujo.sproces
                     AND fvalor = TRUNC(lv_flujo.fvalor)
                     AND sseguro = lv_flujo.sseguro;
               END IF;

               -- Probabilidad de fallecimiento
               vtraza := 13;

               IF NVL(f_parproductos_v(vsproduc_cur, 'ES_PRODUCTO_RENTAS'), 0) = 1
                  OR NVL(f_parproductos_v(vsproduc_cur, 'ES_PRODUCTO_INDEXADO'), 0) = 1 THEN
                  vprobfall :=
                     f_prob_fallecimiento_rentas
                                              (vsseguro_cur, r_dades.sproduc, lv_flujo.fvalor,   -- Fecha del momento de cálculo
                                               lv_flujo.fnacimi1, lv_flujo.csexo1,
                                               lv_flujo.fnacimi2, lv_flujo.csexo2,
                                               vfejerc   -- Fecha del ejercicio
                                                      );   -- r_dades.vct
               ELSE
                  vprobfall :=
                     f_prob_fallecimiento(vsseguro_cur, r_dades.sproduc, lv_flujo.fvalor,   -- Fecha del momento de cálculo
                                          lv_flujo.fnacimi1, lv_flujo.csexo1,
                                          lv_flujo.fnacimi2, lv_flujo.csexo2,
                                          vfejerc   -- Fecha del ejercicio
                                                 );   -- r_dades.vct
               END IF;

               -- Pago probable por fallecimiento
               IF vfejerc >= lv_flujo.fvalor THEN
                  IF TO_NUMBER(TO_CHAR(lv_flujo.fvalor, 'YYYY')) =(vany - vyears) THEN   -- Ejercicio de cálculo
                     -- RSC 02/02/2009 Tratamiento especial por el tema de los años bisiestos
                     IF (TRUNC(TO_DATE('01/01/' ||((vany - vyears) + 1)))
                         - TRUNC(TO_DATE('01/01/' ||(vany - vyears)))) = 365 THEN
                        IF TO_CHAR(lv_flujo.frevisio, 'dd') = '29'
                           AND TO_CHAR(lv_flujo.frevisio, 'mm') = '02' THEN
                           vfrevanyo := TO_DATE('28' || '/' || '02' || '/' ||(vany - vyears),
                                                'dd/mm/yyyy');
                        ELSE
                           vfrevanyo := TO_DATE(TO_CHAR(lv_flujo.frevisio, 'dd') || '/'
                                                || TO_CHAR(lv_flujo.frevisio, 'mm') || '/'
                                                ||(vany - vyears),
                                                'dd/mm/yyyy');
                        END IF;
                     ELSE   -- año bisiesto
                        vfrevanyo := TO_DATE(TO_CHAR(lv_flujo.frevisio, 'dd') || '/'
                                             || TO_CHAR(lv_flujo.frevisio, 'mm') || '/'
                                             ||(vany - vyears),
                                             'dd/mm/yyyy');
                     END IF;

                     IF lv_flujo.fvalor <= vfrevanyo THEN
                        vdfcvctfra := vfrevanyo - lv_flujo.fvalor;
                        vdfc3112fra := TO_DATE('31/12/' ||(vany - vyears), 'dd/mm/yyyy')
                                       - lv_flujo.fvalor;

                        IF (TRUNC(TO_DATE('01/01/' ||((vany - vyears) + 1)))
                            - TRUNC(TO_DATE('01/01/' ||(vany - vyears)))) = 366 THEN   -- año bisiesto
                           vdfcvctfra := vdfcvctfra - 1;
                           vdfc3112fra := vdfc3112fra - 1;   -- no los tenemos en cuenta!
                        END IF;

                        vfrac3 := vdfcvctfra / vdfc3112fra;   -- d-fc-vct / d-fc-3112
                        vpprobfallec := vfraccion *((vcf1 * vfrac3) +(vcf2 *(1 - vfrac3)))
                                        * vprobfall;
                     ELSE   -- ya ha revisado este año --> no hay que ponderar?
                        --vpprobfallec := vfraccion * ((vcf1*lv_flujo.frac2) + (vcf2*(1-lv_flujo.frac2))) * vprobfall;
                        vpprobfallec := vfraccion * vcapfallpond * vprobfall;
                     END IF;
                  ELSE
                     IF (vany - vyears) = TO_NUMBER(TO_CHAR(vvcto, 'YYYY')) THEN
                        vpprobfallec := vfraccion * vcapfallpond * vprobfall;
                     ELSE
                        vpprobfallec := vfraccion
                                        *((vcf1 * lv_flujo.frac2)
                                          +(vcf2 *(1 - lv_flujo.frac2)))
                                        * vprobfall;
                     END IF;
                  END IF;
               --vpprobfallec := vfraccion * ((vcf1*lv_flujo.frac2) + (vcf2*(1-lv_flujo.frac2))) * vprobfall;
               ELSE
                  vpprobfallec := 0.00;   -- En ejercicio pasado ya no mostramos cálculos
               END IF;

               vcf1 := vcapfallpond;   -- Actualizamos el CF anterior (ejercicio anterior)
--------------------------------------------------------------------

               -- Pago probable de las Rentas de Supervivencia --------------------
               vtraza := 14;

               IF NVL(f_parproductos_v(vsproduc_cur, 'ES_PRODUCTO_RENTAS'), 0) = 1 THEN
                  IF NVL(f_parproductos_v(vsproduc_cur, 'PLAN_RENTAS'), 0) = 1 THEN   -- Libreta Renta Creciente
                     -- Renta Anual ponderada
                     vrentapond := f_renta_anual_ponderada(vsseguro_cur, lv_flujo.fvalor,
                                                           vfejerc);
                  ELSE   -- RVI
                     SELECT cforpag
                       INTO vcforpag
                       FROM seguros_ren
                      WHERE sseguro = vsseguro_cur;

                     vrentapond := lv_flujo.renta * vcforpag;
                  END IF;

                  -- Probabilidad de Supervivencia
                  vtraza := 15;
                  vprobsuperv :=
                     f_prob_supervivencia_rentas
                                               (vsseguro_cur, r_dades.sproduc, lv_flujo.fvalor,   -- Fecha del momento de cálculo
                                                lv_flujo.fnacimi1, lv_flujo.csexo1,
                                                lv_flujo.fnacimi2, lv_flujo.csexo2,
                                                ADD_MONTHS(vfejerc, -12)   -- Fecha del ejercicio
                                                                        );   -- r_dades.vct

                  IF vfejerc >= lv_flujo.fvalor THEN
                     vpprobrentas := vfraccion * vrentapond * vprobsuperv;
                  ELSE
                     vrentapond := 0.00;
                     vpprobrentas := 0.00;   -- En ejercicio pasado ya no mostramos cálculos
                  END IF;
               ELSE
                  vrentapond := 0.00;
                  vpprobrentas := 0.00;   -- En ahorro o Unit Linked este cálculo no tiene sentido
               END IF;

--------------------------------------------------------------------

               -- Columna Provisión -----------------------------------------------
               IF vyears = 0 THEN
                  vprovision := vpprobsuperv;
               ELSE
                  vprovision := 0.0;
               END IF;

--------------------------------------------------------------------

               -- Si último ejercicio entonces en año final de ejercicio ponemos un 0
               vtraza := 16;

               IF (vany - vyears) = TO_NUMBER(TO_CHAR(vvcto, 'YYYY')) THEN
                  vffinal := 0;
               ELSE
                  vffinal :=(vany - vyears + 1);
               END IF;

               -- DETFLUJO_PASIVOS
               lv_detflujo.sproces := v_sproces;
               lv_detflujo.fvalor := lv_flujo.fvalor;
               lv_detflujo.sseguro := vsseguro_cur;
               lv_detflujo.ejerc :=(vany - vyears);
               lv_detflujo.linea := vlinea;
               lv_detflujo.registro := vregistro;
               lv_detflujo.inicioper :=(vany - vyears);
               lv_detflujo.finper := vffinal;

               IF NVL(f_parproductos_v(vsproduc_cur, 'ES_PRODUCTO_RENTAS'), 0) = 1
                  AND NVL(f_parproductos_v(vsproduc_cur, 'PLAN_RENTAS'), 0) = 1 THEN
                  ----------
                  -- LRC
                  ----------
                  IF lv_detflujo.finper <> 0 THEN
                     BEGIN
                        SELECT SUM(p.importerenta)
                          INTO lv_detflujo.iimport
                          FROM planrentas p, seguros s
                         WHERE p.sseguro = vsseguro_cur
                           AND p.sseguro = s.sseguro
                           AND p.fechaini >= TO_DATE(TO_CHAR(s.fefecto, 'dd') || '/'
                                                     || TO_CHAR(ADD_MONTHS(s.fefecto, 1), 'mm')
                                                     || '/' || lv_detflujo.inicioper,
                                                     'dd/mm/yyyy')
                           AND p.fechafin <= TO_DATE(TO_CHAR(s.fefecto, 'dd') || '/'
                                                     || TO_CHAR(ADD_MONTHS(s.fefecto, 1), 'mm')
                                                     || '/' || lv_detflujo.finper,
                                                     'dd/mm/yyyy')
                           AND p.nmovimi =
                                 (SELECT MAX(a.nmovimi)
                                    FROM planrentas a
                                   WHERE a.sseguro = p.sseguro
                                     AND a.fechaini >=
                                           TO_DATE(TO_CHAR(s.fefecto, 'dd') || '/'
                                                   || TO_CHAR(ADD_MONTHS(s.fefecto, 1), 'mm')
                                                   || '/' || lv_detflujo.inicioper,
                                                   'dd/mm/yyyy')
                                     AND a.fechafin <=
                                           TO_DATE(TO_CHAR(s.fefecto, 'dd') || '/'
                                                   || TO_CHAR(ADD_MONTHS(s.fefecto, 1), 'mm')
                                                   || '/' || lv_detflujo.finper,
                                                   'dd/mm/yyyy'));
                     EXCEPTION
                        WHEN OTHERS THEN
                           lv_detflujo.iimport := NULL;
                     END;
                  ELSE
                     BEGIN
                        SELECT SUM(p.importerenta)
                          INTO lv_detflujo.iimport
                          FROM planrentas p, seguros s
                         WHERE p.sseguro = vsseguro_cur
                           AND p.sseguro = s.sseguro
                           AND p.fechaini >= TO_DATE(TO_CHAR(s.fefecto, 'dd') || '/'
                                                     || TO_CHAR(ADD_MONTHS(s.fefecto, 1), 'mm')
                                                     || '/' ||(lv_detflujo.inicioper - 1),
                                                     'dd/mm/yyyy')
                           AND p.fechafin <= TO_DATE(TO_CHAR(s.fefecto, 'dd') || '/'
                                                     || TO_CHAR(ADD_MONTHS(s.fefecto, 1), 'mm')
                                                     || '/' || lv_detflujo.inicioper,
                                                     'dd/mm/yyyy')
                           AND p.nmovimi =
                                 (SELECT MAX(a.nmovimi)
                                    FROM planrentas a
                                   WHERE a.sseguro = p.sseguro
                                     AND a.fechaini >=
                                           TO_DATE(TO_CHAR(s.fefecto, 'dd') || '/'
                                                   || TO_CHAR(ADD_MONTHS(s.fefecto, 1), 'mm')
                                                   || '/' ||(lv_detflujo.inicioper - 1),
                                                   'dd/mm/yyyy')
                                     AND a.fechafin <=
                                           TO_DATE(TO_CHAR(s.fefecto, 'dd') || '/'
                                                   || TO_CHAR(ADD_MONTHS(s.fefecto, 1), 'mm')
                                                   || '/' || lv_detflujo.inicioper,
                                                   'dd/mm/yyyy'));
                     EXCEPTION
                        WHEN OTHERS THEN
                           lv_detflujo.iimport := NULL;
                     END;
                  END IF;
               ELSE
                  lv_detflujo.iimport := vcapfallpond;
               END IF;

               lv_detflujo.cfall := vpprobfallec;
               lv_detflujo.cgarren := vpprobrentas;
               lv_detflujo.rentas := vrentapond;
               lv_detflujo.cgarvct := vprovision;

               IF lv_detflujo.inicioper = TO_NUMBER(TO_CHAR(lv_flujo.fvalor, 'YYYY')) THEN
                  lv_detflujo.duracion := TO_NUMBER(TO_CHAR(vvcto, 'YYYY')) - vanyfcalc;
               END IF;

               vlinea := vlinea + 1;
               vregistro := vregistro + 1;
               -- Inserta DETFLUJO_PASIVOS
               vtraza := 17;
               perror := f_inserta_detflujo(lv_detflujo);

               IF perror <> 0 THEN
                  ROLLBACK;
                  texto := f_axis_literales(perror, pcidioma);
                  perror := f_proceslin(v_sproces, ttexto || ' - FLUJO_PASIVOS ',
                                        vsseguro_cur, nlin);
                  COMMIT;
                  vconterr := vconterr + 1;
                  nlin := NULL;
                  RAISE ex_jump;
               END IF;

               lv_detflujo := NULL;
               vyears := vyears - 1;
            END LOOP;

            -- Adelantamos un valor para linea ya que el numero entre medio lo reservamos
            -- para la linea de totales
            vlinea := vlinea + 1;
            -- Realizamos COMMIT de la póliza actual
            COMMIT;
         EXCEPTION
            WHEN ex_jump THEN
               NULL;
         END;
      END LOOP;

      -- Finalizamos proces
      perror := f_procesfin(v_sproces, nerrores);
      RETURN(0);
   EXCEPTION
      WHEN ex_error THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, 'pac_matching.f_sictr026', vtraza,
                     'sproces = ' || v_sproces, SQLERRM);
         RETURN perror;
      WHEN OTHERS THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, 'pac_matching.f_sictr026', vtraza,
                     'sproces = ' || v_sproces, SQLERRM);
         RETURN SQLCODE;
   END f_sictr026;

   FUNCTION ff_interes_matching(pcmatching IN NUMBER, fefecto IN DATE)
      RETURN NUMBER IS
      vinteres       NUMBER;
   BEGIN
      SELECT interes
        INTO vinteres
        FROM matching
       WHERE cmatching = pcmatching
         AND finicial <= TRUNC(fefecto)
         AND(ffinal >= TRUNC(fefecto)
             OR ffinal IS NULL);

      RETURN(vinteres);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN(NULL);
   END ff_interes_matching;

   FUNCTION ff_fecha_matching(pcmatching IN NUMBER, fefecto IN DATE)
      RETURN DATE IS
      vfecha         DATE;
   BEGIN
      SELECT fecha
        INTO vfecha
        FROM matching
       WHERE cmatching = pcmatching
         AND finicial <= TRUNC(fefecto)
         AND(ffinal >= TRUNC(fefecto)
             OR ffinal IS NULL);

      RETURN(vfecha);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN(NULL);
   END ff_fecha_matching;

   FUNCTION f_datos_asegurado(
      psseguro IN NUMBER,
      pnorden IN NUMBER,
      pcidioma IN NUMBER,
      pfnacimiento IN OUT DATE,
      psexo IN OUT NUMBER)
      RETURN NUMBER IS
   BEGIN
      -- Bug10612 - 08/07/2009 - DCT (Añadir vagente_poliza y canviar vista personas)
      -- Datos de las personas aseguradas
      SELECT p.fnacimi, p.csexper
        INTO pfnacimiento, psexo
        FROM asegurados a, per_personas p
       WHERE a.sseguro = psseguro
         AND a.sperson = p.sperson
         AND a.norden = pnorden;

      /*SELECT p.fnacimi, p.csexper
        INTO pfnacimiento, psexo
        FROM asegurados a, personas p
       WHERE a.sseguro = psseguro
         AND a.sperson = p.sperson
         AND a.norden = pnorden;*/

      -- FI Bug10612 - 08/07/2009 - DCT (Añadir vagente_poliza y canviar vista personas)
      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 0;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_matching.f_datos_asegurado', NULL, NULL, SQLERRM);
         RETURN(120007);
   END f_datos_asegurado;

   /***************************************************************************
    -- Cálculo Pago probable de Supervivencia
   ***************************************************************************/
   FUNCTION f_pprob_supervivencia(
      psseguro IN NUMBER,
      psproduc IN NUMBER,
      pffecha IN DATE,   -- Fecha del momento de cálculo
      pfnacimi1 IN DATE,
      psexo1 IN NUMBER,
      pfnacimi2 IN DATE,
      psexo2 IN NUMBER,
      pfejerc IN DATE,   -- Fecha del ejercicio
      pfvencim IN DATE,
      pcapgar IN NUMBER,
      vprovac_200 IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      vnumaseg       NUMBER;
      vcapgar        NUMBER;   -- CS
      vsesion        NUMBER;
      vedad_x        NUMBER;   -- edad actuarial asegurado1 en el momento del cálculo del matching
      vedad_x_n      NUMBER;   -- edad actuarial asegurado1 al vencimiento del contrato
      vedad_y        NUMBER;   -- edad actuarial asegurado2 en el momento del cálculo del matching
      vedad_y_n      NUMBER;   -- edad actuarial asegurado2 al vencimiento del contrato
      vlx            NUMBER;   -- lx
      vlx_n          NUMBER;   -- lx+n
      vly            NUMBER;   -- ly
      vly_n          NUMBER;   -- ly+n
      vctabla        NUMBER;   -- Tabla de mortalidad
      vres           NUMBER;
      -- Rentas
      vfrevisio      DATE;
   BEGIN
      SELECT COUNT(*)
        INTO vnumaseg
        FROM asegurados
       WHERE sseguro = psseguro;

      -- Capital de Supervivencia al vencimiento (CS)
      IF NVL(f_parproductos_v(psproduc, 'ES_PRODUCTO_RENTAS'), 0) <> 1 THEN
         vcapgar := pcapgar;   --F_CAPGAR_ULT_ACT (psseguro,pfFecha);
      --Aqui es posible que tengamos que hacer una query a EVOLUPROVMATSEG
      --para escoger el capital garantizado al vencimiento (no al perdiodo
      --de revisión como hace el cierre de provisiones para los productos
      --EuroTerm 16 y Europlazo16. Para ello escogeremos el campo IPROVMAT
      --del NMOVIMI mas alto del seguro.
      ELSE
         IF NVL(f_parproductos_v(psproduc, 'PLAN_RENTAS'), 0) = 1 THEN   -- Libreta Renta Creciente
            vcapgar := pcapgar;   --F_CAPGAR_ULT_ACT (psseguro,pfFecha);
         ELSE   -- RVI
            IF vprovac_200 IS NULL THEN
               SELECT frevisio
                 INTO vfrevisio
                 FROM seguros_aho
                WHERE sseguro = psseguro;

               vcapgar := pac_provmat_formul.f_calcul_formulas_provi(psseguro, vfrevisio,
                                                                     'IPROVAC');
            ELSE
               vcapgar := vprovac_200;
            END IF;
         END IF;
      END IF;

      -- Obtenemos la sequence
      SELECT sgt_sesiones.NEXTVAL
        INTO vsesion
        FROM DUAL;

      -- Obtenemos la tabla de mortalidad en función del producto
      IF NVL(f_parproductos_v(psproduc, 'ES_PRODUCTO_RENTAS'), 0) = 1 THEN
         SELECT ctabla
           INTO vctabla
           FROM garanpro
          WHERE sproduc = psproduc
            AND cgarant = 48;
      ELSE
         SELECT ctabla
           INTO vctabla
           FROM garanpro
          WHERE sproduc = psproduc
            AND cgarant = 283;
      END IF;

      IF vnumaseg = 1 THEN   -- 1 CABEZA
         --IF NVL(F_PARPRODUCTOS_V(psproduc,'ES_PRODUCTO_RENTAS'),0) = 1 THEN
           -- En los de Rentas esta función se llamará unicamente con la fecha de cálculo
         vedad_x := fedad(vsesion, TO_NUMBER(TO_CHAR(pfnacimi1, 'yyyymmdd')),
                          TO_NUMBER(TO_CHAR(pffecha, 'yyyymmdd')), 2);
         --ELSE
           -- En Europlazo, etc se llamará a esta función para cada ejercicio
         --  vedad_x := FEDAD (vsesion, to_number(to_char(pfnacimi1,'yyyymmdd')), to_number(to_char(pfejerc,'yyyymmdd')), 2);
         --END IF;
         vedad_x_n := fedad(vsesion, TO_NUMBER(TO_CHAR(pfnacimi1, 'yyyymmdd')),
                            TO_NUMBER(TO_CHAR(pfvencim, 'yyyymmdd')), 2);
         -- Con la tabla de mortalidad que toca
         vlx := pac_formul_rentas.ff_lx(vsesion, vctabla, vedad_x, psexo1, 2);   -- lx
         vlx_n := pac_formul_rentas.ff_lx(vsesion, vctabla, vedad_x_n, psexo1, 2);   -- lx + n
         vres := vcapgar *(vlx_n / vlx);
      ELSE   -- 2 CABEZAS
         --IF NVL(F_PARPRODUCTOS_V(psproduc,'ES_PRODUCTO_RENTAS'),0) = 1 THEN
         -- En los de Rentas esta función se llamará unicamente con la fecha de cálculo
         vedad_x := fedad(vsesion, TO_NUMBER(TO_CHAR(pfnacimi1, 'yyyymmdd')),
                          TO_NUMBER(TO_CHAR(pffecha, 'yyyymmdd')), 2);
         vedad_y := fedad(vsesion, TO_NUMBER(TO_CHAR(pfnacimi2, 'yyyymmdd')),
                          TO_NUMBER(TO_CHAR(pffecha, 'yyyymmdd')), 2);
         --ELSE
         -- En Europlazo, etc se llamará a esta función para cada ejercicio
         --  vedad_x := FEDAD (vsesion, to_number(to_char(pfnacimi1,'yyyymmdd')), to_number(to_char(pfejerc,'yyyymmdd')), 2);
         --  vedad_y := FEDAD (vsesion, to_number(to_char(pfnacimi2,'yyyymmdd')), to_number(to_char(pfejerc,'yyyymmdd')), 2);
         --END IF;
         vedad_x_n := fedad(vsesion, TO_NUMBER(TO_CHAR(pfnacimi1, 'yyyymmdd')),
                            TO_NUMBER(TO_CHAR(pfvencim, 'yyyymmdd')), 2);
         vedad_y_n := fedad(vsesion, TO_NUMBER(TO_CHAR(pfnacimi2, 'yyyymmdd')),
                            TO_NUMBER(TO_CHAR(pfvencim, 'yyyymmdd')), 2);
         -- Con la tabla de mortalidad que toca
         vlx := pac_formul_rentas.ff_lx(vsesion, vctabla, vedad_x, psexo1, 2);   -- lx
         vlx_n := pac_formul_rentas.ff_lx(vsesion, vctabla, vedad_x_n, psexo1, 2);   -- lx + n
         vly := pac_formul_rentas.ff_lx(vsesion, vctabla, vedad_y, psexo2, 2);   -- ly
         vly_n := pac_formul_rentas.ff_lx(vsesion, vctabla, vedad_y_n, psexo2, 2);   -- ly + n
         vres := vcapgar *(((vlx_n / vlx) +(vly_n / vly)) -((vlx_n * vly_n) /(vlx * vly)));
      END IF;

      RETURN(vres);
   END f_pprob_supervivencia;

   /***************************************************************************
    -- Cálculo Pago probable de Supervivencia Rentas
   ***************************************************************************/
   FUNCTION f_pprob_supervivencia_rentas(
      psseguro IN NUMBER,
      psproduc IN NUMBER,
      pffecha IN DATE,   -- Fecha del momento de cálculo
      pfnacimi1 IN DATE,
      psexo1 IN NUMBER,
      pfnacimi2 IN DATE,
      psexo2 IN NUMBER,
      pfejerc IN DATE,   -- Fecha del ejercicio
      pfvencim IN DATE,
      pcapgar IN NUMBER,
      vprovac_200 IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      vnumaseg       NUMBER;
      vcapgar        NUMBER;   -- CS
      vsesion        NUMBER;
      vedad_x        NUMBER;   -- edad actuarial asegurado1 en el momento del cálculo del matching
      vedad_x_n      NUMBER;   -- edad actuarial asegurado1 al vencimiento del contrato
      vedad_y        NUMBER;   -- edad actuarial asegurado2 en el momento del cálculo del matching
      vedad_y_n      NUMBER;   -- edad actuarial asegurado2 al vencimiento del contrato
      vlx            NUMBER;   -- lx
      vlx_n          NUMBER;   -- lx+n
      vly            NUMBER;   -- ly
      vly_n          NUMBER;   -- ly+n
      vctabla        NUMBER;   -- Tabla de mortalidad
      vres           NUMBER;
      -- Rentas
      vfrevisio      DATE;
      -- RSC 31/10/2008 ----
      vpfnacimi1     DATE;
      vpsexo1        NUMBER;
      vpfnacimi2     DATE;
      vpsexo2        NUMBER;
      fmue_ase1      NUMBER;
      fmue_ase2      NUMBER;
      anyo_aho       NUMBER;
      vfefepol       DATE;
      vcempres       seguros.cempres%TYPE;
      vagente_poliza seguros.cagente%TYPE;
   BEGIN
      -- RSC 31/10/2008 --------------------------------------------------------
      vpfnacimi1 := pfnacimi1;
      vpsexo1 := psexo1;
      vpfnacimi2 := pfnacimi2;
      vpsexo2 := psexo2;

      IF NVL(f_parproductos_v(psproduc, 'ES_PRODUCTO_RENTAS'), 0) = 1
         AND NVL(f_parproductos_v(psproduc, 'PLAN_RENTAS'), 0) <> 1 THEN
         -- Bug10612 - 08/07/2009 - DCT (Añadir vagente_poliza y canviar vista personas)
         -- Empresa y agente de la póliza
         SELECT fefecto, cagente, cempres
           INTO vfefepol, vagente_poliza, vcempres
           FROM seguros
          WHERE sseguro = psseguro;

         -- Termino FMUE_ASE1
         SELECT TO_NUMBER(NVL(TO_CHAR(MAX(a.ffecfin), 'yyyymmdd'), '10000101'))
           INTO fmue_ase1
           FROM asegurados a, per_personas p
          WHERE a.norden = 1
            AND a.sperson = p.sperson
            AND a.sseguro = psseguro;

         /*SELECT TO_NUMBER(NVL(TO_CHAR(MAX(a.ffecfin), 'yyyymmdd'), '10000101'))
             INTO fmue_ase1
             FROM asegurados a, personas p
            WHERE a.norden = 1
              AND a.sperson = p.sperson
              AND a.sseguro = psseguro;*/

         -- Termino FMUE_ASE2
         SELECT TO_NUMBER(NVL(TO_CHAR(MAX(a.ffecfin), 'yyyymmdd'), '10000101'))
           INTO fmue_ase2
           FROM asegurados a, per_personas p
          WHERE a.norden = 2
            AND a.sperson = p.sperson
            AND a.sseguro = psseguro;

         /*SELECT TO_NUMBER(NVL(TO_CHAR(MAX(a.ffecfin), 'yyyymmdd'), '10000101'))
           INTO fmue_ase2
           FROM asegurados a, personas p
          WHERE a.norden = 2
            AND a.sperson = p.sperson
            AND a.sseguro = psseguro;*/

         -- FI Bug10612 - 08/07/2009 - DCT (Añadir vagente_poliza y canviar vista personas)
         SELECT TRUNC(MONTHS_BETWEEN(pffecha, vfefepol) / 12)
           INTO anyo_aho
           FROM DUAL;
      END IF;

--------------------------------------------------------------------------
      SELECT COUNT(*)
        INTO vnumaseg
        FROM asegurados
       WHERE sseguro = psseguro;

      -- Capital de Supervivencia al vencimiento (CS)
      IF NVL(f_parproductos_v(psproduc, 'ES_PRODUCTO_RENTAS'), 0) <> 1 THEN
         vcapgar := pcapgar;   --F_CAPGAR_ULT_ACT (psseguro,pfFecha);
      --Aqui es posible que tengamos que hacer una query a EVOLUPROVMATSEG
      --para escoger el capital garantizado al vencimiento (no al perdiodo
      --de revisión como hace el cierre de provisiones para los productos
      --EuroTerm 16 y Europlazo16. Para ello escogeremos el campo IPROVMAT
      --del NMOVIMI mas alto del seguro.
      ELSE
         IF NVL(f_parproductos_v(psproduc, 'PLAN_RENTAS'), 0) = 1 THEN   -- Libreta Renta Creciente
            vcapgar := pcapgar;   --F_CAPGAR_ULT_ACT (psseguro,pfFecha);
         ELSE   -- RVI
            IF vprovac_200 IS NULL THEN
               SELECT frevisio
                 INTO vfrevisio
                 FROM seguros_aho
                WHERE sseguro = psseguro;

               vcapgar := pac_provmat_formul.f_calcul_formulas_provi(psseguro, vfrevisio,
                                                                     'IPROVAC');
            ELSE
               vcapgar := vprovac_200;
            END IF;
         END IF;
      END IF;

      -- RSC 31/10/2008 --------------------------------------------------------
      IF NVL(f_parproductos_v(psproduc, 'ES_PRODUCTO_RENTAS'), 0) = 1
         AND NVL(f_parproductos_v(psproduc, 'PLAN_RENTAS'), 0) <> 1 THEN
         IF fmue_ase1 <> 10000101
            OR fmue_ase2 <> 10000101 THEN
            vnumaseg := 1;   -- Alguien a muerto por tanto cálculo para 1 asegurado

            -- Asegurado 1 fallecido
            IF fmue_ase1 <> 10000101
               AND fmue_ase2 = 10000101 THEN
               IF (TO_DATE(fmue_ase1, 'yyyymmdd') <= ADD_MONTHS(vfefepol, anyo_aho * 12))
                  OR(TO_DATE(fmue_ase1, 'yyyymmdd') >= ADD_MONTHS(vfefepol, anyo_aho * 12)
                     AND TO_DATE(fmue_ase1, 'yyyymmdd') <=
                                                        ADD_MONTHS(vfefepol,
                                                                   (anyo_aho + 1) * 12)) THEN
                  vpfnacimi1 := vpfnacimi2;
                  vpsexo1 := vpsexo2;
               END IF;
            END IF;
         -- Asegurado 2 fallecido
         -- No hay que hacer nada mas si el fallecido es el segundo
         -- ya entraremos por la rama de 1 cabeza
         END IF;
      END IF;

--------------------------------------------------------------------------

      -- Obtenemos la sequence
      SELECT sgt_sesiones.NEXTVAL
        INTO vsesion
        FROM DUAL;

      -- Obtenemos la tabla de mortalidad en función del producto
      IF NVL(f_parproductos_v(psproduc, 'ES_PRODUCTO_RENTAS'), 0) = 1 THEN
         SELECT ctabla
           INTO vctabla
           FROM garanpro
          WHERE sproduc = psproduc
            AND cgarant = 48;
      ELSE
         SELECT ctabla
           INTO vctabla
           FROM garanpro
          WHERE sproduc = psproduc
            AND cgarant = 283;
      END IF;

      IF vnumaseg = 1 THEN   -- 1 CABEZA
         vedad_x := fedad(vsesion, TO_NUMBER(TO_CHAR(vpfnacimi1, 'yyyymmdd')),
                          TO_NUMBER(TO_CHAR(pffecha, 'yyyymmdd')), 2);
         vedad_x_n := fedad(vsesion, TO_NUMBER(TO_CHAR(vpfnacimi1, 'yyyymmdd')),
                            TO_NUMBER(TO_CHAR(pfvencim, 'yyyymmdd')), 2);
         -- Con la tabla de mortalidad que toca
         vlx := pac_formul_rentas.ff_lx(vsesion, vctabla, vedad_x, vpsexo1, 2);   -- lx
         vlx_n := pac_formul_rentas.ff_lx(vsesion, vctabla, vedad_x_n, vpsexo1, 2);   -- lx + n
         vres := vcapgar *(vlx_n / vlx);
      ELSE   -- 2 CABEZAS
         vedad_x := fedad(vsesion, TO_NUMBER(TO_CHAR(vpfnacimi1, 'yyyymmdd')),
                          TO_NUMBER(TO_CHAR(pffecha, 'yyyymmdd')), 2);
         vedad_y := fedad(vsesion, TO_NUMBER(TO_CHAR(vpfnacimi2, 'yyyymmdd')),
                          TO_NUMBER(TO_CHAR(pffecha, 'yyyymmdd')), 2);
         vedad_x_n := fedad(vsesion, TO_NUMBER(TO_CHAR(vpfnacimi1, 'yyyymmdd')),
                            TO_NUMBER(TO_CHAR(pfvencim, 'yyyymmdd')), 2);
         vedad_y_n := fedad(vsesion, TO_NUMBER(TO_CHAR(vpfnacimi2, 'yyyymmdd')),
                            TO_NUMBER(TO_CHAR(pfvencim, 'yyyymmdd')), 2);
         -- Con la tabla de mortalidad que toca
         vlx := pac_formul_rentas.ff_lx(vsesion, vctabla, vedad_x, vpsexo1, 2);   -- lx
         vlx_n := pac_formul_rentas.ff_lx(vsesion, vctabla, vedad_x_n, vpsexo1, 2);   -- lx + n
         vly := pac_formul_rentas.ff_lx(vsesion, vctabla, vedad_y, vpsexo2, 2);   -- ly
         vly_n := pac_formul_rentas.ff_lx(vsesion, vctabla, vedad_y_n, vpsexo2, 2);   -- ly + n
         vres := vcapgar *(((vlx_n / vlx) +(vly_n / vly)) -((vlx_n * vly_n) /(vlx * vly)));
      END IF;

      RETURN(vres);
   END f_pprob_supervivencia_rentas;

   FUNCTION f_calc_fracciones(
      vpffecha IN DATE,
      vflufrev IN DATE,
      vdiasvct IN OUT NUMBER,
      vfracn IN OUT NUMBER,
      vdiascalc IN OUT NUMBER,
      vfrac1 IN OUT NUMBER,
      vdiasfcvct IN OUT NUMBER,
      vfracnb IN OUT NUMBER,
      psproduc IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      vanyfcalc      NUMBER;
      vanyvctrev     NUMBER;
      v_anyos        NUMBER;
      vffechavct     DATE;
   BEGIN
      vanyfcalc := TO_NUMBER(TO_CHAR(vpffecha, 'YYYY'));
      vanyvctrev := TO_NUMBER(TO_CHAR(vflufrev, 'YYYY'));
      --D-0101-VTO -------------------------------
      vdiasvct := TRUNC(vflufrev) - TRUNC(TO_DATE('01/01/' || vanyvctrev, 'dd/mm/yyyy'));

      IF (TRUNC(TO_DATE('01/01/' ||(vanyvctrev + 1))) - TRUNC(TO_DATE('01/01/' || vanyvctrev))) =
                                                                                            366 THEN   -- año bisiesto
         IF vflufrev > TO_DATE('29/02/' || vanyvctrev, 'dd/mm/yyyy') THEN
            vdiasvct := vdiasvct - 1;
         END IF;
      END IF;

      vfracn :=(vdiasvct / 365);

      IF (TRUNC(TO_DATE('01/01/' ||(vanyvctrev + 1))) - TRUNC(TO_DATE('01/01/' || vanyvctrev))) =
                                                                                            366 THEN   -- año bisiesto
         IF vflufrev > TO_DATE('29/02/' || vanyvctrev, 'dd/mm/yyyy') THEN
            vdiasvct := vdiasvct + 1;
         END IF;
      END IF;

--                nº de dias a transcurrir desde el día del cálculo hasta
--                el próximo 31.12.xxxx
--  Fracción 1 = -------------------------------------------------------
--                                      365
-- D-FC-3112
      vdiascalc := TRUNC(TO_DATE('31/12/' || vanyfcalc, 'dd/mm/yyyy')) - TRUNC(vpffecha);

      IF (TRUNC(TO_DATE('01/01/' ||(vanyfcalc + 1))) - TRUNC(TO_DATE('01/01/' || vanyfcalc))) =
                                                                                            366 THEN   -- año bisiesto
         -- RSC 09/10/2008
         -- RSC 15/10/2008 Como en principio esto para ahorro funcionaba este nuevo tratamiento solo lo
         -- ponemos para Rentas
         IF psproduc IS NOT NULL
            AND(NVL(f_parproductos_v(psproduc, 'ES_PRODUCTO_RENTAS'), 0) = 1
                OR NVL(f_parproductos_v(psproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1) THEN
            IF TRUNC(vpffecha) > LAST_DAY(TO_DATE('01/02/' || vanyfcalc, 'dd/mm/yyyy')) THEN
               vfrac1 :=(vdiascalc / 365);
            ELSE
               vfrac1 :=((vdiascalc - 1) / 365);
            END IF;
         ELSE
            vfrac1 :=((vdiascalc - 1) / 365);
         END IF;
      ELSE
         vfrac1 :=(vdiascalc / 365);
      END IF;

------------------------------------

      -- D-FC-VTO
      v_anyos := TO_NUMBER(TO_CHAR(vflufrev, 'YYYY')) - TO_NUMBER(TO_CHAR(vpffecha, 'YYYY'));

      SELECT ADD_MONTHS(vpffecha, 12 * v_anyos)
        INTO vffechavct
        FROM DUAL;

      vdiasfcvct := TRUNC(vflufrev) - TRUNC(vffechavct);

      IF vdiasfcvct < 0 THEN
         vdiasfcvct := 365 + vdiasfcvct;
      END IF;

      IF (TRUNC(TO_DATE('01/01/' ||(vanyvctrev + 1))) - TRUNC(TO_DATE('01/01/' || vanyvctrev))) =
                                                                                            366 THEN   -- año bisiesto
         IF vflufrev > TO_DATE('29/02/' || vanyvctrev, 'dd/mm/yyyy') THEN
            vdiasfcvct := vdiasfcvct - 1;
         END IF;
      END IF;

      vfracnb :=(vdiasfcvct / 365);

      IF (TRUNC(TO_DATE('01/01/' ||(vanyvctrev + 1))) - TRUNC(TO_DATE('01/01/' || vanyvctrev))) =
                                                                  366 /*OR vpfFecha > vflufrev*/ THEN   -- año bisiesto
         IF vflufrev > TO_DATE('29/02/' || vanyvctrev, 'dd/mm/yyyy') THEN
            vdiasfcvct := vdiasfcvct + 1;
         END IF;
      END IF;

      IF (TRUNC(vflufrev) - TRUNC(vffechavct)) < 0 THEN
         vdiasfcvct := vdiasfcvct + 1;
      END IF;

      RETURN(0);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_calc_fracciones;

   /***************************************************************************
    -- Cálculo de la probabilidad de fallecimiento
   ***************************************************************************/
   FUNCTION f_prob_fallecimiento(
      psseguro IN NUMBER,
      psproduc IN NUMBER,
      pffecha IN DATE,   -- Fecha del momento de cálculo
      pfnacimi1 IN DATE,
      psexo1 IN NUMBER,
      pfnacimi2 IN DATE,
      psexo2 IN NUMBER,
      pfejerc IN DATE   -- Fecha del ejercicio
                     )
      RETURN NUMBER IS
      vnumaseg       NUMBER;
      vsesion        NUMBER;
      vedad_xc       NUMBER;
      vedad_x        NUMBER;   -- edad actuarial asegurado1 en el momento del cálculo del matching
      vedad_x_1      NUMBER;   -- edad actuarial asegurado1 al año siguiente del momento del cálculo del matching
      vedad_yc       NUMBER;
      vedad_y        NUMBER;   -- edad actuarial asegurado2 en el momento del cálculo del matching
      vedad_y_1      NUMBER;   -- edad actuarial asegurado2 al año siguiente del momento del cálculo del matching
      vlx_c          NUMBER;   -- lx con la edad del asegurado 1 en el momento de cálculo
      vlx            NUMBER;   -- lx con la edad del asegurado 1 en el momento transcurrido (ejercicio)
      vlx_1          NUMBER;   -- lx+1 con la edad del asegurado 1 en el momento transcurrido (ejercicio) + 1 año
      vly_c          NUMBER;   -- ly con la edad del asegurado 1 en el momento de cálculo
      vly            NUMBER;   -- ly
      vly_1          NUMBER;   -- ly+1
      vdx            NUMBER;   -- dx
      vdx_1          NUMBER;   -- dx+1
      vdy            NUMBER;   -- dy
      vdy_1          NUMBER;   -- dy+1
      vctabla        NUMBER;   -- Tabla de mortalidad
      vres           NUMBER;
      v_anyos0       NUMBER;
      v_anyos        NUMBER;
      vfechat0       DATE;
      vfechat        DATE;
   BEGIN
      -- Año transcurrido des de la fecha de cálculo
      v_anyos0 := TO_NUMBER(TO_CHAR(pfejerc, 'YYYY')) - TO_NUMBER(TO_CHAR(pffecha, 'YYYY'));
      v_anyos := TO_NUMBER(TO_CHAR(pfejerc, 'YYYY')) - TO_NUMBER(TO_CHAR(pffecha, 'YYYY')) + 1;

      SELECT COUNT(*)
        INTO vnumaseg
        FROM asegurados
       WHERE sseguro = psseguro;

      -- Obtenemos la sequence
      SELECT sgt_sesiones.NEXTVAL
        INTO vsesion
        FROM DUAL;

      -- Obtenemos la tabla de mortalidad en función del producto
      IF NVL(f_parproductos_v(psproduc, 'ES_PRODUCTO_RENTAS'), 0) = 1 THEN
         SELECT ctabla
           INTO vctabla
           FROM garanpro
          WHERE sproduc = psproduc
            AND cgarant = 48;
      ELSE
         SELECT ctabla
           INTO vctabla
           FROM garanpro
          WHERE sproduc = psproduc
            AND cgarant = 283;
      END IF;

      -- Obtenemos fecha desde la fecha de calculo hasta 31/12/ejercicio
      SELECT ADD_MONTHS(pffecha, 12 * v_anyos0)
        INTO vfechat0
        FROM DUAL;

      SELECT ADD_MONTHS(pffecha, 12 * v_anyos)
        INTO vfechat
        FROM DUAL;

      IF vnumaseg = 1 THEN   -- 1 CABEZA
         vedad_xc := fedad(vsesion, TO_NUMBER(TO_CHAR(pfnacimi1, 'yyyymmdd')),
                           TO_NUMBER(TO_CHAR(pffecha, 'yyyymmdd')), 2);
         vedad_x := fedad(vsesion, TO_NUMBER(TO_CHAR(pfnacimi1, 'yyyymmdd')),
                          TO_NUMBER(TO_CHAR(vfechat0, 'yyyymmdd')), 2);
         vedad_x_1 := fedad(vsesion, TO_NUMBER(TO_CHAR(pfnacimi1, 'yyyymmdd')),
                            TO_NUMBER(TO_CHAR(vfechat, 'yyyymmdd')), 2);
         -- Con la tabla de mortalidad que toca
         vlx_c := pac_formul_rentas.ff_lx(vsesion, vctabla, vedad_xc, psexo1, 2);   -- lx (fecha de cálculo)
         vlx := pac_formul_rentas.ff_lx(vsesion, vctabla, vedad_x, psexo1, 2);   -- lx
         vlx_1 := pac_formul_rentas.ff_lx(vsesion, vctabla, vedad_x_1, psexo1, 2);   -- lx + 1
         vdx := vlx - vlx_1;   -- lx - lx+1
         vres := vdx / vlx_c;   -- dx/lxc, dx+1/lxc, dx+2/lxc, ...., dx+n/lxc
      ELSE   -- 2 CABEZAS
         -- Asegurado 1
         vedad_xc := fedad(vsesion, TO_NUMBER(TO_CHAR(pfnacimi1, 'yyyymmdd')),
                           TO_NUMBER(TO_CHAR(pffecha, 'yyyymmdd')), 2);
         vedad_x := fedad(vsesion, TO_NUMBER(TO_CHAR(pfnacimi1, 'yyyymmdd')),
                          TO_NUMBER(TO_CHAR(vfechat0, 'yyyymmdd')), 2);
         vedad_x_1 := fedad(vsesion, TO_NUMBER(TO_CHAR(pfnacimi1, 'yyyymmdd')),
                            TO_NUMBER(TO_CHAR(vfechat, 'yyyymmdd')), 2);
         -- Asegurado 2
         vedad_yc := fedad(vsesion, TO_NUMBER(TO_CHAR(pfnacimi2, 'yyyymmdd')),
                           TO_NUMBER(TO_CHAR(pffecha, 'yyyymmdd')), 2);
         vedad_y := fedad(vsesion, TO_NUMBER(TO_CHAR(pfnacimi2, 'yyyymmdd')),
                          TO_NUMBER(TO_CHAR(vfechat0, 'yyyymmdd')), 2);
         vedad_y_1 := fedad(vsesion, TO_NUMBER(TO_CHAR(pfnacimi2, 'yyyymmdd')),
                            TO_NUMBER(TO_CHAR(vfechat, 'yyyymmdd')), 2);
         -- Con la tabla de mortalidad que toca
         vlx_c := pac_formul_rentas.ff_lx(vsesion, vctabla, vedad_xc, psexo1, 2);   -- lx (fecha de cálculo)
         vlx := pac_formul_rentas.ff_lx(vsesion, vctabla, vedad_x, psexo1, 2);   -- lx
         vlx_1 := pac_formul_rentas.ff_lx(vsesion, vctabla, vedad_x_1, psexo1, 2);   -- lx + 1
         vly_c := pac_formul_rentas.ff_lx(vsesion, vctabla, vedad_yc, psexo2, 2);   -- ly (fecha de cálculo)
         vly := pac_formul_rentas.ff_lx(vsesion, vctabla, vedad_y, psexo2, 2);   -- ly
         vly_1 := pac_formul_rentas.ff_lx(vsesion, vctabla, vedad_y_1, psexo2, 2);   -- ly + 1
         vdx := vlx - vlx_1;   -- lx - lx+1
         vdy := vly - vly_1;   -- lx - lx+1

         IF v_anyos = 1 THEN
            /*********************
                   dx*dy
                   -----
                   lx*ly
            **********************/
            vres := (vdx * vdy) /(vlx_c * vly_c);
         ELSE   -- > 1 (Fallecimiento Segundo año, tercer año, ..., Último año)
            /*****************************************************************************
                   dx+n * dy+n        dx+n          ly+n         dy+n          lx+n
                 ( ----------- ) + (------- * (1 - ------)) + (------- * (1 - ------))
                      lx*ly            lx            ly           ly            lx
            ******************************************************************************/
            vres := ((vdx * vdy) /(vlx_c * vly_c)) +((vdx / vlx_c) *(1 -(vly / vly_c)))
                    +((vdy / vly_c) *(1 -(vlx / vlx_c)));
         END IF;
      END IF;

      RETURN(vres);
   EXCEPTION
      WHEN OTHERS THEN
         --dbms_output.put_line('ERROR = '||SQLERRM);
         NULL;
   END f_prob_fallecimiento;

   /***************************************************************************
    -- Cálculo de la probabilidad de fallecimiento
    Esta es una función identica a f_prob_fallecimiento pero con la peculiaridad
    del tratamiento especial que hay que hacer para RVI. En RVI para el cálculo
    de la provisión se tiene en cuenta si el asegurado está o no fallecido.
   ***************************************************************************/
   FUNCTION f_prob_fallecimiento_rentas(
      psseguro IN NUMBER,
      psproduc IN NUMBER,
      pffecha IN DATE,   -- Fecha del momento de cálculo
      pfnacimi1 IN DATE,
      psexo1 IN NUMBER,
      pfnacimi2 IN DATE,
      psexo2 IN NUMBER,
      pfejerc IN DATE   -- Fecha del ejercicio
                     )
      RETURN NUMBER IS
      vnumaseg       NUMBER;
      vsesion        NUMBER;
      vedad_xc       NUMBER;
      vedad_x        NUMBER;   -- edad actuarial asegurado1 en el momento del cálculo del matching
      vedad_x_1      NUMBER;   -- edad actuarial asegurado1 al año siguiente del momento del cálculo del matching
      vedad_yc       NUMBER;
      vedad_y        NUMBER;   -- edad actuarial asegurado2 en el momento del cálculo del matching
      vedad_y_1      NUMBER;   -- edad actuarial asegurado2 al año siguiente del momento del cálculo del matching
      vlx_c          NUMBER;   -- lx con la edad del asegurado 1 en el momento de cálculo
      vlx            NUMBER;   -- lx con la edad del asegurado 1 en el momento transcurrido (ejercicio)
      vlx_1          NUMBER;   -- lx+1 con la edad del asegurado 1 en el momento transcurrido (ejercicio) + 1 año
      vly_c          NUMBER;   -- ly con la edad del asegurado 1 en el momento de cálculo
      vly            NUMBER;   -- ly
      vly_1          NUMBER;   -- ly+1
      vdx            NUMBER;   -- dx
      vdx_1          NUMBER;   -- dx+1
      vdy            NUMBER;   -- dy
      vdy_1          NUMBER;   -- dy+1
      vctabla        NUMBER;   -- Tabla de mortalidad
      vres           NUMBER;
      v_anyos0       NUMBER;
      v_anyos        NUMBER;
      vfechat0       DATE;
      vfechat        DATE;
      -- RSC 31/10/2008 ----
      vpfnacimi1     DATE;
      vpsexo1        NUMBER;
      vpfnacimi2     DATE;
      vpsexo2        NUMBER;
      fmue_ase1      NUMBER;
      fmue_ase2      NUMBER;
      anyo_aho       NUMBER;
      vfefepol       DATE;
   BEGIN
      -- RSC 31/10/2008 --------------------------------------------------------
      vpfnacimi1 := pfnacimi1;
      vpsexo1 := psexo1;
      vpfnacimi2 := pfnacimi2;
      vpsexo2 := psexo2;

      IF (NVL(f_parproductos_v(psproduc, 'ES_PRODUCTO_RENTAS'), 0) = 1
          AND NVL(f_parproductos_v(psproduc, 'PLAN_RENTAS'), 0) <> 1)
         OR NVL(f_parproductos_v(psproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1 THEN
         -- Bug10612 - 08/07/2009 - DCT (Añadir vagente_poliza y canviar vista personas)
         -- Empresa y agente de la póliza
         SELECT fefecto
           INTO vfefepol
           FROM seguros
          WHERE sseguro = psseguro;

         -- Termino FMUE_ASE1
         SELECT TO_NUMBER(NVL(TO_CHAR(MAX(a.ffecfin), 'yyyymmdd'), '10000101'))
           INTO fmue_ase1
           FROM asegurados a, per_personas p
          WHERE a.norden = 1
            AND a.sperson = p.sperson
            AND a.sseguro = psseguro;

         /*SELECT TO_NUMBER(NVL(TO_CHAR(MAX(a.ffecfin), 'yyyymmdd'), '10000101'))
           INTO fmue_ase1
           FROM asegurados a, personas p
          WHERE a.norden = 1
            AND a.sperson = p.sperson
            AND a.sseguro = psseguro;*/

         -- Termino FMUE_ASE2
         SELECT TO_NUMBER(NVL(TO_CHAR(MAX(a.ffecfin), 'yyyymmdd'), '10000101'))
           INTO fmue_ase2
           FROM asegurados a, per_personas p
          WHERE a.norden = 2
            AND a.sperson = p.sperson
            AND a.sseguro = psseguro;

         /*SELECT TO_NUMBER(NVL(TO_CHAR(MAX(a.ffecfin), 'yyyymmdd'), '10000101'))
           INTO fmue_ase2
           FROM asegurados a, personas p
          WHERE a.norden = 2
            AND a.sperson = p.sperson
            AND a.sseguro = psseguro;*/

         -- FI Bug10612 - 08/07/2009 - DCT (Añadir vagente_poliza y canviar vista personas)
         SELECT TRUNC(MONTHS_BETWEEN(pffecha, vfefepol) / 12)
           INTO anyo_aho
           FROM DUAL;
      END IF;

--------------------------------------------------------------------------

      -- Año transcurrido des de la fecha de cálculo
      v_anyos0 := TO_NUMBER(TO_CHAR(pfejerc, 'YYYY')) - TO_NUMBER(TO_CHAR(pffecha, 'YYYY'));
      v_anyos := TO_NUMBER(TO_CHAR(pfejerc, 'YYYY')) - TO_NUMBER(TO_CHAR(pffecha, 'YYYY')) + 1;

      SELECT COUNT(*)
        INTO vnumaseg
        FROM asegurados
       WHERE sseguro = psseguro;

      -- RSC 31/10/2008 --------------------------------------------------------
      IF (NVL(f_parproductos_v(psproduc, 'ES_PRODUCTO_RENTAS'), 0) = 1
          AND NVL(f_parproductos_v(psproduc, 'PLAN_RENTAS'), 0) <> 1)
         OR NVL(f_parproductos_v(psproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1 THEN
         IF fmue_ase1 <> 10000101
            OR fmue_ase2 <> 10000101 THEN
            vnumaseg := 1;   -- Alguien a muerto por tanto cálculo para 1 asegurado

            -- Asegurado 1 fallecido
            IF fmue_ase1 <> 10000101
               AND fmue_ase2 = 10000101 THEN
               IF (TO_DATE(fmue_ase1, 'yyyymmdd') <= ADD_MONTHS(vfefepol, anyo_aho * 12))
                  OR(TO_DATE(fmue_ase1, 'yyyymmdd') >= ADD_MONTHS(vfefepol, anyo_aho * 12)
                     AND TO_DATE(fmue_ase1, 'yyyymmdd') <=
                                                        ADD_MONTHS(vfefepol,
                                                                   (anyo_aho + 1) * 12)) THEN
                  vpfnacimi1 := vpfnacimi2;
                  vpsexo1 := vpsexo2;
               END IF;
            END IF;
         -- Asegurado 2 fallecido
         -- No hay que hacer nada mas si el fallecido es el segundo
         -- ya entraremos por la rama de 1 cabeza
         END IF;
      END IF;

--------------------------------------------------------------------------

      -- Obtenemos la sequence
      SELECT sgt_sesiones.NEXTVAL
        INTO vsesion
        FROM DUAL;

      -- Obtenemos la tabla de mortalidad en función del producto
      IF NVL(f_parproductos_v(psproduc, 'ES_PRODUCTO_RENTAS'), 0) = 1 THEN
         SELECT ctabla
           INTO vctabla
           FROM garanpro
          WHERE sproduc = psproduc
            AND cgarant = 48;
      ELSE
         SELECT ctabla
           INTO vctabla
           FROM garanpro
          WHERE sproduc = psproduc
            AND cgarant = 283;
      END IF;

      -- Obtenemos fecha desde la fecha de calculo hasta 31/12/ejercicio
      SELECT ADD_MONTHS(pffecha, 12 * v_anyos0)
        INTO vfechat0
        FROM DUAL;

      SELECT ADD_MONTHS(pffecha, 12 * v_anyos)
        INTO vfechat
        FROM DUAL;

      IF vnumaseg = 1 THEN   -- 1 CABEZA
         vedad_xc := fedad(vsesion, TO_NUMBER(TO_CHAR(vpfnacimi1, 'yyyymmdd')),
                           TO_NUMBER(TO_CHAR(pffecha, 'yyyymmdd')), 2);
         vedad_x := fedad(vsesion, TO_NUMBER(TO_CHAR(vpfnacimi1, 'yyyymmdd')),
                          TO_NUMBER(TO_CHAR(vfechat0, 'yyyymmdd')), 2);
         vedad_x_1 := fedad(vsesion, TO_NUMBER(TO_CHAR(vpfnacimi1, 'yyyymmdd')),
                            TO_NUMBER(TO_CHAR(vfechat, 'yyyymmdd')), 2);
         -- Con la tabla de mortalidad que toca
         vlx_c := pac_formul_rentas.ff_lx(vsesion, vctabla, vedad_xc, vpsexo1, 2);   -- lx (fecha de cálculo)
         vlx := pac_formul_rentas.ff_lx(vsesion, vctabla, vedad_x, vpsexo1, 2);   -- lx
         vlx_1 := pac_formul_rentas.ff_lx(vsesion, vctabla, vedad_x_1, vpsexo1, 2);   -- lx + 1
         vdx := vlx - vlx_1;   -- lx - lx+1
         vres := vdx / vlx_c;   -- dx/lxc, dx+1/lxc, dx+2/lxc, ...., dx+n/lxc
      ELSE   -- 2 CABEZAS
         -- Asegurado 1
         vedad_xc := fedad(vsesion, TO_NUMBER(TO_CHAR(vpfnacimi1, 'yyyymmdd')),
                           TO_NUMBER(TO_CHAR(pffecha, 'yyyymmdd')), 2);
         vedad_x := fedad(vsesion, TO_NUMBER(TO_CHAR(vpfnacimi1, 'yyyymmdd')),
                          TO_NUMBER(TO_CHAR(vfechat0, 'yyyymmdd')), 2);
         vedad_x_1 := fedad(vsesion, TO_NUMBER(TO_CHAR(vpfnacimi1, 'yyyymmdd')),
                            TO_NUMBER(TO_CHAR(vfechat, 'yyyymmdd')), 2);
         -- Asegurado 2
         vedad_yc := fedad(vsesion, TO_NUMBER(TO_CHAR(vpfnacimi2, 'yyyymmdd')),
                           TO_NUMBER(TO_CHAR(pffecha, 'yyyymmdd')), 2);
         vedad_y := fedad(vsesion, TO_NUMBER(TO_CHAR(vpfnacimi2, 'yyyymmdd')),
                          TO_NUMBER(TO_CHAR(vfechat0, 'yyyymmdd')), 2);
         vedad_y_1 := fedad(vsesion, TO_NUMBER(TO_CHAR(vpfnacimi2, 'yyyymmdd')),
                            TO_NUMBER(TO_CHAR(vfechat, 'yyyymmdd')), 2);
         -- Con la tabla de mortalidad que toca
         vlx_c := pac_formul_rentas.ff_lx(vsesion, vctabla, vedad_xc, vpsexo1, 2);   -- lx (fecha de cálculo)
         vlx := pac_formul_rentas.ff_lx(vsesion, vctabla, vedad_x, vpsexo1, 2);   -- lx
         vlx_1 := pac_formul_rentas.ff_lx(vsesion, vctabla, vedad_x_1, vpsexo1, 2);   -- lx + 1
         vly_c := pac_formul_rentas.ff_lx(vsesion, vctabla, vedad_yc, vpsexo2, 2);   -- ly (fecha de cálculo)
         vly := pac_formul_rentas.ff_lx(vsesion, vctabla, vedad_y, vpsexo2, 2);   -- ly
         vly_1 := pac_formul_rentas.ff_lx(vsesion, vctabla, vedad_y_1, vpsexo2, 2);   -- ly + 1
         vdx := vlx - vlx_1;   -- lx - lx+1
         vdy := vly - vly_1;   -- lx - lx+1

         IF v_anyos = 1 THEN
            /*********************
                   dx*dy
                   -----
                   lx*ly
            **********************/
            vres := (vdx * vdy) /(vlx_c * vly_c);
         ELSE   -- > 1 (Fallecimiento Segundo año, tercer año, ..., Último año)
            /*****************************************************************************
                   dx+n * dy+n        dx+n          ly+n         dy+n          lx+n
                 ( ----------- ) + (------- * (1 - ------)) + (------- * (1 - ------))
                      lx*ly            lx            ly           ly            lx
            ******************************************************************************/
            vres := ((vdx * vdy) /(vlx_c * vly_c)) +((vdx / vlx_c) *(1 -(vly / vly_c)))
                    +((vdy / vly_c) *(1 -(vlx / vlx_c)));
         END IF;
      END IF;

      RETURN(vres);
   EXCEPTION
      WHEN OTHERS THEN
         --dbms_output.put_line('ERROR = '||SQLERRM);
         NULL;
   END f_prob_fallecimiento_rentas;

   /***************************************************************************
    -- Cálculo de la probabilidad de supervivencia (LRC) en cada ejercicio
   ***************************************************************************/
   /*
   FUNCTION f_prob_supervivencia_rentas (psseguro IN NUMBER,
                                         psproduc IN NUMBER,
                                         pfFecha IN DATE,    -- Fecha del momento de cálculo
                                         pfnacimi1 IN DATE,
                                         psexo1 IN NUMBER,
                                         pfnacimi2 IN DATE,
                                         psexo2 IN NUMBER,
                                         pfejerc IN DATE    -- Fecha del ejercicio
                                         ) RETURN NUMBER IS
    vnumaseg   NUMBER;
    vcapgar    NUMBER; -- CS
    vsesion    NUMBER;

    vedad_xc   NUMBER;
    vedad_x    NUMBER; -- edad actuarial asegurado1 en el momento del cálculo del matching
    vedad_x_1  NUMBER; -- edad actuarial asegurado1 al año siguiente del momento del cálculo del matching
    vedad_yc   NUMBER;
    vedad_y    NUMBER; -- edad actuarial asegurado2 en el momento del cálculo del matching
    vedad_y_1  NUMBER; -- edad actuarial asegurado2 al año siguiente del momento del cálculo del matching

    vlx_c      NUMBER; -- lx con la edad del asegurado 1 en el momento de cálculo
    vlx        NUMBER; -- lx con la edad del asegurado 1 en el momento transcurrido (ejercicio)
    vlx_1      NUMBER; -- lx+1 con la edad del asegurado 1 en el momento transcurrido (ejercicio) + 1 año
    vly_c      NUMBER; -- ly con la edad del asegurado 1 en el momento de cálculo
    vly        NUMBER; -- ly
    vly_1      NUMBER; -- ly+1

    vdx        NUMBER; -- dx
    vdx_1      NUMBER; -- dx+1
    vdy        NUMBER; -- dy
    vdy_1      NUMBER; -- dy+1

    vctabla    NUMBER; -- Tabla de mortalidad
    vres       NUMBER;

    v_anyos0   NUMBER;
    v_anyos    NUMBER;
    vfechat0   DATE;
    vfechat    DATE;
   BEGIN
      -- Año transcurrido des de la fecha de cálculo
      v_anyos0 := to_number(to_char(pfejerc,'YYYY')) - to_number(to_char(pfFecha,'YYYY'));
      v_anyos := to_number(to_char(pfejerc,'YYYY')) - to_number(to_char(pfFecha,'YYYY')) + 1;

      -- 1 o 2 cabezas?
      SELECT COUNT(*) INTO vnumaseg
      FROM asegurados
      WHERE sseguro = psseguro;

      -- Obtenemos la sequence
      SELECT SGT_SESIONES.NEXTVAL INTO vsesion FROM DUAL;

      -- Obtenemos la tabla de mortalidad en función del producto
      IF NVL(F_PARPRODUCTOS_V(psproduc,'ES_PRODUCTO_RENTAS'),0) = 1 THEN
        SELECT ctabla INTO vctabla FROM garanpro WHERE sproduc = psproduc and cgarant = 48;
      ELSE
        SELECT ctabla INTO vctabla FROM garanpro WHERE sproduc = psproduc and cgarant = 283;
      END IF;

      -- Obtenemos fecha desde la fecha de calculo hasta 31/12/ejercicio
      SELECT add_months(pfFecha, 12*v_anyos) INTO vfechat FROM DUAL;

      IF vnumaseg = 1 THEN -- 1 CABEZA
        vedad_xc := FEDAD (vsesion, to_number(to_char(pfnacimi1,'yyyymmdd')), to_number(to_char(pfFecha,'yyyymmdd')), 2);
        vedad_x_1 := FEDAD (vsesion, to_number(to_char(pfnacimi1,'yyyymmdd')), to_number(to_char(vfechat,'yyyymmdd')), 2);

        -- Con la tabla de mortalidad que toca
        vlx_c := PAC_FORMUL_RENTAS.FF_LX (vsesion, vctabla, vedad_xc, psexo1, 2);  -- lx (fecha de cálculo)
        vlx_1 := PAC_FORMUL_RENTAS.FF_LX (vsesion, vctabla, vedad_x_1, psexo1, 2); -- lx + 1

        --    lx+n
        --    ----
        --     lx

        vres := vlx_1 / vlx_c;  -- dx/lxc, dx+1/lxc, dx+2/lxc, ...., dx+n/lxc
      ELSE -- 2 CABEZAS
        -- Asegurado 1
        vedad_xc := FEDAD (vsesion, to_number(to_char(pfnacimi1,'yyyymmdd')), to_number(to_char(pfFecha,'yyyymmdd')), 2);
        vedad_x_1 := FEDAD (vsesion, to_number(to_char(pfnacimi1,'yyyymmdd')), to_number(to_char(vfechat,'yyyymmdd')), 2);

        -- Asegurado 2
        vedad_yc := FEDAD (vsesion, to_number(to_char(pfnacimi2,'yyyymmdd')), to_number(to_char(pfFecha,'yyyymmdd')), 2);
        vedad_y_1 := FEDAD (vsesion, to_number(to_char(pfnacimi2,'yyyymmdd')), to_number(to_char(vfechat,'yyyymmdd')), 2);

        -- Con la tabla de mortalidad que toca
        vlx_c := PAC_FORMUL_RENTAS.FF_LX (vsesion, vctabla, vedad_xc, psexo1, 2);  -- lx (fecha de cálculo)
        vlx_1 := PAC_FORMUL_RENTAS.FF_LX (vsesion, vctabla, vedad_x_1, psexo1, 2); -- lx + 1

        vly_c := PAC_FORMUL_RENTAS.FF_LX (vsesion, vctabla, vedad_yc, psexo2, 2);  -- ly (fecha de cálculo)
        vly_1 := PAC_FORMUL_RENTAS.FF_LX (vsesion, vctabla, vedad_y_1, psexo2, 2); -- ly + 1

        --       lx+n * ly+n        lx+n          ly+n         ly+n          lx+n
        --     ( ----------- ) + (------- * (1 - ------)) + (------- * (1 - ------))
        --          lx*ly            lx            ly           ly            lx
        vres := ((vlx_1 * vly_1) / (vlx_c*vly_c)) + ((vlx_1/vlx_c)*(1 - (vly_1/vly_c))) + ((vly_1/vly_c)*(1 - (vlx_1/vlx_c)));
      END IF;
      RETURN (vres);
   END f_prob_supervivencia_rentas;
   */
   FUNCTION f_prob_supervivencia_rentas(
      psseguro IN NUMBER,
      psproduc IN NUMBER,
      pffecha IN DATE,   -- Fecha del momento de cálculo
      pfnacimi1 IN DATE,
      psexo1 IN NUMBER,
      pfnacimi2 IN DATE,
      psexo2 IN NUMBER,
      pfejerc IN DATE   -- Fecha del ejercicio
                     )
      RETURN NUMBER IS
      vnumaseg       NUMBER;
      vcapgar        NUMBER;   -- CS
      vsesion        NUMBER;
      vedad_xc       NUMBER;
      vedad_x        NUMBER;   -- edad actuarial asegurado1 en el momento del cálculo del matching
      vedad_x_1      NUMBER;   -- edad actuarial asegurado1 al año siguiente del momento del cálculo del matching
      vedad_yc       NUMBER;
      vedad_y        NUMBER;   -- edad actuarial asegurado2 en el momento del cálculo del matching
      vedad_y_1      NUMBER;   -- edad actuarial asegurado2 al año siguiente del momento del cálculo del matching
      vlx_c          NUMBER;   -- lx con la edad del asegurado 1 en el momento de cálculo
      vlx            NUMBER;   -- lx con la edad del asegurado 1 en el momento transcurrido (ejercicio)
      vlx_1          NUMBER;   -- lx+1 con la edad del asegurado 1 en el momento transcurrido (ejercicio) + 1 año
      vly_c          NUMBER;   -- ly con la edad del asegurado 1 en el momento de cálculo
      vly            NUMBER;   -- ly
      vly_1          NUMBER;   -- ly+1
      vdx            NUMBER;   -- dx
      vdx_1          NUMBER;   -- dx+1
      vdy            NUMBER;   -- dy
      vdy_1          NUMBER;   -- dy+1
      vctabla        NUMBER;   -- Tabla de mortalidad
      vres           NUMBER;
      v_anyos0       NUMBER;
      v_anyos        NUMBER;
      vfechat0       DATE;
      vfechat        DATE;
      -- RSC 31/10/2008 ----
      vpfnacimi1     DATE;
      vpsexo1        NUMBER;
      vpfnacimi2     DATE;
      vpsexo2        NUMBER;
      fmue_ase1      NUMBER;
      fmue_ase2      NUMBER;
      anyo_aho       NUMBER;
      vfefepol       DATE;
      vagente_poliza seguros.cagente%TYPE;
      vcempres       seguros.cempres%TYPE;
   BEGIN
      -- RSC 31/10/2008 --------------------------------------------------------
      vpfnacimi1 := pfnacimi1;
      vpsexo1 := psexo1;
      vpfnacimi2 := pfnacimi2;
      vpsexo2 := psexo2;

      IF NVL(f_parproductos_v(psproduc, 'ES_PRODUCTO_RENTAS'), 0) = 1
         AND NVL(f_parproductos_v(psproduc, 'PLAN_RENTAS'), 0) <> 1 THEN
         -- Bug10612 - 08/07/2009 - DCT (Añadir vagente_poliza y canviar vista personas)
         -- Empresa y agente de la póliza
         SELECT fefecto, cagente, cempres
           INTO vfefepol, vagente_poliza, vcempres
           FROM seguros
          WHERE sseguro = psseguro;

         -- Termino FMUE_ASE1
         SELECT TO_NUMBER(NVL(TO_CHAR(MAX(a.ffecfin), 'yyyymmdd'), '10000101'))
           INTO fmue_ase1
           FROM asegurados a, per_personas p
          WHERE a.norden = 1
            AND a.sperson = p.sperson
            AND a.sseguro = psseguro;

         /*SELECT TO_NUMBER(NVL(TO_CHAR(MAX(a.ffecfin), 'yyyymmdd'), '10000101'))
           INTO fmue_ase1
           FROM asegurados a, personas p
          WHERE a.norden = 1
            AND a.sperson = p.sperson
            AND a.sseguro = psseguro;*/

         -- Termino FMUE_ASE2
         SELECT TO_NUMBER(NVL(TO_CHAR(MAX(a.ffecfin), 'yyyymmdd'), '10000101'))
           INTO fmue_ase2
           FROM asegurados a, per_personas p
          WHERE a.norden = 2
            AND a.sperson = p.sperson
            AND a.sseguro = psseguro;

         /*SELECT TO_NUMBER(NVL(TO_CHAR(MAX(a.ffecfin), 'yyyymmdd'), '10000101'))
           INTO fmue_ase2
           FROM asegurados a, personas p
          WHERE a.norden = 2
            AND a.sperson = p.sperson
            AND a.sseguro = psseguro;*/

         -- FI Bug10612 - 08/07/2009 - DCT (Añadir vagente_poliza y canviar vista personas)
         SELECT TRUNC(MONTHS_BETWEEN(pffecha, vfefepol) / 12)
           INTO anyo_aho
           FROM DUAL;
      END IF;

--------------------------------------------------------------------------

      -- Año transcurrido des de la fecha de cálculo
      v_anyos0 := TO_NUMBER(TO_CHAR(pfejerc, 'YYYY')) - TO_NUMBER(TO_CHAR(pffecha, 'YYYY'));
      v_anyos := TO_NUMBER(TO_CHAR(pfejerc, 'YYYY')) - TO_NUMBER(TO_CHAR(pffecha, 'YYYY')) + 1;

      -- 1 o 2 cabezas?
      SELECT COUNT(*)
        INTO vnumaseg
        FROM asegurados
       WHERE sseguro = psseguro;

      -- RSC 31/10/2008 --------------------------------------------------------
      IF NVL(f_parproductos_v(psproduc, 'ES_PRODUCTO_RENTAS'), 0) = 1
         AND NVL(f_parproductos_v(psproduc, 'PLAN_RENTAS'), 0) <> 1 THEN
         IF fmue_ase1 <> 10000101
            OR fmue_ase2 <> 10000101 THEN
            vnumaseg := 1;   -- Alguien a muerto por tanto cálculo para 1 asegurado

            -- Asegurado 1 fallecido
            IF fmue_ase1 <> 10000101
               AND fmue_ase2 = 10000101 THEN
               IF (TO_DATE(fmue_ase1, 'yyyymmdd') <= ADD_MONTHS(vfefepol, anyo_aho * 12))
                  OR(TO_DATE(fmue_ase1, 'yyyymmdd') >= ADD_MONTHS(vfefepol, anyo_aho * 12)
                     AND TO_DATE(fmue_ase1, 'yyyymmdd') <=
                                                        ADD_MONTHS(vfefepol,
                                                                   (anyo_aho + 1) * 12)) THEN
                  vpfnacimi1 := vpfnacimi2;
                  vpsexo1 := vpsexo2;
               END IF;
            END IF;
         -- Asegurado 2 fallecido
         -- No hay que hacer nada mas si el fallecido es el segundo
         -- ya entraremos por la rama de 1 cabeza
         END IF;
      END IF;

--------------------------------------------------------------------------

      -- Obtenemos la sequence
      SELECT sgt_sesiones.NEXTVAL
        INTO vsesion
        FROM DUAL;

      -- Obtenemos la tabla de mortalidad en función del producto
      IF NVL(f_parproductos_v(psproduc, 'ES_PRODUCTO_RENTAS'), 0) = 1 THEN
         SELECT ctabla
           INTO vctabla
           FROM garanpro
          WHERE sproduc = psproduc
            AND cgarant = 48;
      ELSE
         SELECT ctabla
           INTO vctabla
           FROM garanpro
          WHERE sproduc = psproduc
            AND cgarant = 283;
      END IF;

      -- Obtenemos fecha desde la fecha de calculo hasta 31/12/ejercicio
      SELECT ADD_MONTHS(pffecha, 12 * v_anyos)
        INTO vfechat
        FROM DUAL;

      IF vnumaseg = 1 THEN   -- 1 CABEZA
         vedad_xc := fedad(vsesion, TO_NUMBER(TO_CHAR(vpfnacimi1, 'yyyymmdd')),
                           TO_NUMBER(TO_CHAR(pffecha, 'yyyymmdd')), 2);
         vedad_x_1 := fedad(vsesion, TO_NUMBER(TO_CHAR(vpfnacimi1, 'yyyymmdd')),
                            TO_NUMBER(TO_CHAR(vfechat, 'yyyymmdd')), 2);
         -- Con la tabla de mortalidad que toca
         vlx_c := pac_formul_rentas.ff_lx(vsesion, vctabla, vedad_xc, vpsexo1, 2);   -- lx (fecha de cálculo)
         vlx_1 := pac_formul_rentas.ff_lx(vsesion, vctabla, vedad_x_1, vpsexo1, 2);   -- lx + 1
         --    lx+n
         --    ----
         --     lx
         vres := vlx_1 / vlx_c;   -- dx/lxc, dx+1/lxc, dx+2/lxc, ...., dx+n/lxc
      ELSE   -- 2 CABEZAS
         -- Asegurado 1
         vedad_xc := fedad(vsesion, TO_NUMBER(TO_CHAR(vpfnacimi1, 'yyyymmdd')),
                           TO_NUMBER(TO_CHAR(pffecha, 'yyyymmdd')), 2);
         vedad_x_1 := fedad(vsesion, TO_NUMBER(TO_CHAR(vpfnacimi1, 'yyyymmdd')),
                            TO_NUMBER(TO_CHAR(vfechat, 'yyyymmdd')), 2);
         -- Asegurado 2
         vedad_yc := fedad(vsesion, TO_NUMBER(TO_CHAR(vpfnacimi2, 'yyyymmdd')),
                           TO_NUMBER(TO_CHAR(pffecha, 'yyyymmdd')), 2);
         vedad_y_1 := fedad(vsesion, TO_NUMBER(TO_CHAR(vpfnacimi2, 'yyyymmdd')),
                            TO_NUMBER(TO_CHAR(vfechat, 'yyyymmdd')), 2);
         -- Con la tabla de mortalidad que toca
         vlx_c := pac_formul_rentas.ff_lx(vsesion, vctabla, vedad_xc, vpsexo1, 2);   -- lx (fecha de cálculo)
         vlx_1 := pac_formul_rentas.ff_lx(vsesion, vctabla, vedad_x_1, vpsexo1, 2);   -- lx + 1
         vly_c := pac_formul_rentas.ff_lx(vsesion, vctabla, vedad_yc, vpsexo2, 2);   -- ly (fecha de cálculo)
         vly_1 := pac_formul_rentas.ff_lx(vsesion, vctabla, vedad_y_1, vpsexo2, 2);   -- ly + 1
         --       lx+n * ly+n        lx+n          ly+n         ly+n          lx+n
         --     ( ----------- ) + (------- * (1 - ------)) + (------- * (1 - ------))
         --          lx*ly            lx            ly           ly            lx
         vres := ((vlx_1 * vly_1) /(vlx_c * vly_c)) +((vlx_1 / vlx_c) *(1 -(vly_1 / vly_c)))
                 +((vly_1 / vly_c) *(1 -(vlx_1 / vlx_c)));
      END IF;

      RETURN(vres);
   END f_prob_supervivencia_rentas;

   /***************************************************************************
    -- Cálculo de la probabilidad de supervivencia (LRC y Renta Plus)
       en cada ejercicio
   ***************************************************************************/
   FUNCTION f_renta_anual_ponderada(
      psseguro IN NUMBER,
      pffecha IN DATE,   -- Fecha del momento de cálculo
      pfejerc IN DATE)
      RETURN NUMBER IS
      vfcalc1        DATE;
      vfcalc2        DATE;
      vrenta1        NUMBER;
      vrenta2        NUMBER;
      vanyoejerc     NUMBER;
      vd             NUMBER;
      vres           NUMBER;
      v_anyos        NUMBER;
      v_anyos2       NUMBER;
      vfvencim       DATE;
      -- RSC 09/10/2008
      vcforpag       NUMBER;
      -- RSC 15/10/2008
      vd1            NUMBER;
      vd2            NUMBER;
      -- RSC 31/10/2008
      vfecha1        DATE;
      vfefecto       DATE;
   BEGIN
      SELECT fvencim
        INTO vfvencim
        FROM seguros
       WHERE sseguro = psseguro;

      SELECT cforpag
        INTO vcforpag
        FROM seguros_ren
       WHERE sseguro = psseguro;

--dbms_output.put_line('-------------------- f_renta_anual_ponderada.pfFecha = '||pfFecha);
--dbms_output.put_line('-------------------- f_renta_anual_ponderada.pfejerc = '||pfejerc);
      v_anyos := TO_NUMBER(TO_CHAR(pfejerc, 'YYYY')) - TO_NUMBER(TO_CHAR(pffecha, 'YYYY'));
      v_anyos2 := TO_NUMBER(TO_CHAR(pfejerc, 'YYYY')) - TO_NUMBER(TO_CHAR(vfvencim, 'YYYY'));

--dbms_output.put_line('-------------------- f_renta_anual_ponderada.v_anyos = '||v_anyos);
--dbms_output.put_line('-------------------- f_renta_anual_ponderada.v_anyos2 = '||v_anyos2);

      --IF v_anyos = 0 OR v_anyos2 = 0 THEN  -- Primer y último ejercicio (la renta en esos ejercicios será constante)
      IF v_anyos2 = 0 THEN   -- Primer y último ejercicio (la renta en esos ejercicios será constante)
         IF v_anyos = 0 THEN
            vres := pk_rentas.f_buscarentabruta(1, psseguro,
                                                TO_NUMBER(TO_CHAR(pfejerc, 'yyyymmdd')), 2);
         ELSIF v_anyos2 = 0 THEN
            vres := pk_rentas.f_buscarentabruta(1, psseguro,
                                                TO_NUMBER(TO_CHAR(vfvencim, 'yyyymmdd')), 2);
         END IF;
      ELSE   -- Ejercicio intermedios
         SELECT fefecto
           INTO vfefecto
           FROM seguros
          WHERE sseguro = psseguro;

         vfecha1 := TO_DATE(TO_CHAR(vfefecto, 'ddmm') || TO_CHAR(pfejerc, 'yyyy'), 'ddmmyyyy');
         --select fppren into fecproxpago from seguros_ren where sseguro= psseguro;
         vrenta1 := pk_rentas.f_buscarentabruta(1, psseguro,
                                                TO_NUMBER(TO_CHAR(vfecha1 - 1, 'yyyymmdd')), 2);
         vrenta2 := pk_rentas.f_buscarentabruta(1, psseguro,
                                                TO_NUMBER(TO_CHAR(pfejerc, 'yyyymmdd')), 2);
         vd := TRUNC(vfecha1 - 1)
               - TRUNC(TO_DATE('0101' || TO_CHAR(pfejerc, 'yyyy'), 'ddmmyyyy'));
         vres := (vrenta1 *(vd / 365)) +(vrenta2 *(((365 - vd) / 365)));
      END IF;

      -- RSC 09/10/2008
      -- Es anual ponderada se debe multiplicar por la forma de pago de la renta
      vres := vres * vcforpag;
      RETURN(vres);
   END f_renta_anual_ponderada;

   /***************************************************************************
    -- Cálculo de la probabilidad de supervivencia (LRC y Renta Plus)
       en cada ejercicio
   ***************************************************************************/
   FUNCTION f_valor_rescate_match(
      psseguro IN NUMBER,
      psproduc IN NUMBER,
      pcidioma IN NUMBER,
      pffecha IN DATE,
      pprovision IN NUMBER,
      vresultat IN OUT NUMBER)
      RETURN NUMBER IS
      num_err        NUMBER;
      vpivalora      NUMBER;   -- Valoracion
      vipenali       NUMBER;   -- Importe de Penalizacion
      vpicapris      NUMBER;   -- Capital de riesgo
      vgarantia      NUMBER;
      v_cdelega      NUMBER;
      vocoderror     NUMBER;
      vomsgerror     VARCHAR2(1000);
      ex_error       EXCEPTION;
      vanyo          NUMBER;
      vtippenali     NUMBER;
      -- RSC 31/10/2008
      viprovacibex   NUMBER;
      vclaveiprovac  NUMBER;
      vprovision     NUMBER;
      perror         NUMBER;
      vcramo         NUMBER;
   BEGIN
      vprovision := pprovision;

      IF NVL(f_parproductos_v(psproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1 THEN
         SELECT cramo
           INTO vcramo
           FROM seguros
          WHERE sseguro = psseguro;

         SELECT clave
           INTO vclaveiprovac
           FROM garanformula
          WHERE cramo = vcramo
            AND ccampo = 'IPROVAC'
            AND cgarant = 48;

         perror := pac_calculo_formulas.calc_formul(pffecha, psproduc, 0, 48, 1, psseguro,
                                                    vclaveiprovac, viprovacibex, NULL, NULL, 2,
                                                    pffecha, 'R');
         vprovision := vprovision - viprovacibex;
      END IF;

      BEGIN
         SELECT cdelega
           INTO v_cdelega
           FROM usuarios
          WHERE UPPER(cusuari) = UPPER(f_user);
      EXCEPTION
         WHEN OTHERS THEN
            num_err := 140821;
            RAISE ex_error;
      END;

      IF NVL(f_parproductos_v(psproduc, 'ES_PRODUCTO_RENTAS'), 0) = 1
         OR NVL(f_parproductos_v(psproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1 THEN   -- 'IPENALI', 321 (79, 200, 205)
         SELECT DECODE(calc_rescates.fporcenpenali(1, psseguro,
                                                   TO_NUMBER(TO_CHAR(pffecha, 'yyyymmdd')), 4),
                       100, GREATEST
                                  (vprovision
                                   - calc_rescates.fprimasaport
                                                               (1, psseguro,
                                                                TO_NUMBER(TO_CHAR(pffecha,
                                                                                  'yyyymmdd')),
                                                                4),
                                   0),
                       vprovision
                       * calc_rescates.fporcenpenali(1, psseguro,
                                                     TO_NUMBER(TO_CHAR(pffecha, 'yyyymmdd')),
                                                     4)
                       / 100)
           INTO vipenali
           FROM DUAL;
      ELSE
         SELECT vprovision
                * calc_rescates.fporcenpenali(1, psseguro,
                                              TO_NUMBER(TO_CHAR(pffecha, 'yyyymmdd')), 4)
                / 100
           INTO vipenali
           FROM DUAL;
      END IF;

      vresultat := vprovision - vipenali;
      RETURN 0;
   EXCEPTION
      WHEN ex_error THEN
         RETURN num_err;
      WHEN OTHERS THEN
         RETURN SQLCODE;
   END;

   FUNCTION f_inserta_flujo(lv_flujo flujo_pasivos%ROWTYPE)
      RETURN NUMBER IS
   BEGIN
      INSERT INTO flujo_pasivos
                  (sproces, fvalor, sseguro,
                   fcalcul, provper, cfallec, renta,
                   falta, frevisio, fvencim, fnacimi1,
                   csexo1, fnacimi2, csexo2, frac1,
                   frac2, fracb, d0101vcto, dfc3112,
                   dfcvcto, rescate)
           VALUES (lv_flujo.sproces, TRUNC(lv_flujo.fvalor), lv_flujo.sseguro,
                   lv_flujo.fcalcul, lv_flujo.provper, lv_flujo.cfallec, lv_flujo.renta,
                   lv_flujo.falta, lv_flujo.frevisio, lv_flujo.fvencim, lv_flujo.fnacimi1,
                   lv_flujo.csexo1, lv_flujo.fnacimi2, lv_flujo.csexo2, lv_flujo.frac1,
                   lv_flujo.frac2, lv_flujo.fracb, lv_flujo.d0101vcto, lv_flujo.dfc3112,
                   lv_flujo.dfcvcto, lv_flujo.rescate);

      RETURN(0);
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_matching.f_inserta_flujo', NULL,
                     'sproces = ' || lv_flujo.sproces, SQLERRM);
         RETURN 180758;
   END;

   FUNCTION f_inserta_detflujo(lv_detflujo detflujo_pasivos%ROWTYPE)
      RETURN NUMBER IS
   BEGIN
      INSERT INTO detflujo_pasivos
                  (sproces, fvalor, sseguro,
                   ejerc, linea, registro,
                   duracion, inicioper, finper,
                   iimport, cfall, cgarren,
                   rentas, cgarvct)
           VALUES (lv_detflujo.sproces, TRUNC(lv_detflujo.fvalor), lv_detflujo.sseguro,
                   lv_detflujo.ejerc, lv_detflujo.linea, lv_detflujo.registro,
                   lv_detflujo.duracion, lv_detflujo.inicioper, lv_detflujo.finper,
                   lv_detflujo.iimport, lv_detflujo.cfall, lv_detflujo.cgarren,
                   lv_detflujo.rentas, lv_detflujo.cgarvct);

      RETURN(0);
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_matching.f_inserta_detflujo', NULL,
                     'sproces = ' || lv_detflujo.sproces, SQLERRM);
         RETURN 180759;
   END;

   FUNCTION f_valida_existe_delete(pffecha IN DATE)
      RETURN NUMBER IS
      vfvalor        DATE;
      vcontac        NUMBER;
      vcontapost     NUMBER;   -- Contador de cierres posteriores
   BEGIN
      vfvalor := pffecha;

      SELECT COUNT(*)
        INTO vcontapost
        FROM flujo_pasivos
       WHERE fvalor > TRUNC(vfvalor);

      IF vcontapost = 0 THEN   -- Si no se ha generado ningún cierre posterior
         SELECT COUNT(*)
           INTO vcontac
           FROM flujo_pasivos
          WHERE fvalor = TRUNC(vfvalor);

         IF vcontac > 0 THEN
            -- Borramos el detalle DETFLUJO_PASIVOS
            BEGIN
               DELETE FROM detflujo_pasivos
                     WHERE fvalor = TRUNC(vfvalor);
            EXCEPTION
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user, 'pac_matching.f_valida_existe_delete', NULL,
                              'pfFecha = ' || pffecha, SQLERRM);
                  RETURN 180761;
            END;

            -- Borramos Flujo_Pasivos
            BEGIN
               DELETE FROM flujo_pasivos
                     WHERE fvalor = TRUNC(vfvalor);
            EXCEPTION
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user, 'pac_matching.f_valida_existe_delete', NULL,
                              'pfFecha = ' || pffecha, SQLERRM);
                  RETURN 180760;
            END;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_matching.f_valida_existe_delete', NULL,
                     'pfFecha = ' || pffecha, SQLERRM);
         RETURN 108190;   -- Error General
   END;
END;

/

  GRANT EXECUTE ON "AXIS"."PAC_MATCHING" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MATCHING" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MATCHING" TO "PROGRAMADORESCSI";
