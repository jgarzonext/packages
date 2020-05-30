--------------------------------------------------------
--  DDL for Package Body PAC_SIMUL_RENTAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_SIMUL_RENTAS" AS
/******************************************************************************
   NOMBRE:     Pac_Simul_Rentas
   PROPÓSITO:  Funciones para la simulacion de Rentas

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        XX/XX/XXXX   XXX                1. Creación del package.
   2.0        30/04/2009   APD                2. Bug 9685 - primero se ha de buscar para la actividad en concreto
                                                 y si no se encuentra nada ir a buscar a GARANFORMULA para la actividad cero
   2.1        30/04/2009   APD                3. Bug 9685 - en lugar de coger la actividad de la tabla seguros, llamar a la
                                                 función pac_seguros.ff_get_actividad
   3.0        14/05/2009   APD                4. Bug 10112 : Se elimina la parte del código que hace un IF hipoteca_invesa...
******************************************************************************/
   TYPE rg_duraciones IS RECORD(
      periodo        NUMBER,
      anualidad      NUMBER,
      capitales      NUMBER
   );

   TYPE tb_duraciones IS TABLE OF rg_duraciones
      INDEX BY BINARY_INTEGER;

   v_regduraciones rg_duraciones;
   v_tabladuraciones tb_duraciones;

--JRH Aquesta funció grava les variables que canvien durant la simulació i retarifica
   FUNCTION f_graba_datos_tarif(
      ptipo IN NUMBER,
      psproduc IN NUMBER,
      v_ssolicit IN NUMBER,
      pfefecto IN DATE,
      pduraci IN NUMBER,
      pfvencim IN DATE,
      pfnacimi1 IN DATE,
      pcapital IN NUMBER,
      pintec IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      v_traza        tab_error.ntraza%TYPE;
      num_err        NUMBER;
      error          EXCEPTION;
      v_fvencim      DATE;
      v_nduraci      NUMBER;
      v_garant       NUMBER;
      v_ctipgar      NUMBER;
   BEGIN
      v_fvencim := pfvencim;
      v_nduraci := pduraci;

----------------------------------------------------------
-- actualizamos la duración periodo interés garantizado --
----------------------------------------------------------
      IF v_fvencim IS NOT NULL THEN
         -- MSR Ref 1991
         num_err := pac_calc_comu.f_calcula_fvencim_nduraci(psproduc, pfnacimi1, pfefecto,
                                                            NULL, v_nduraci, v_fvencim);
      END IF;

-- el producto utiliza duración periodo
      IF NVL(f_parproductos_v(psproduc, 'DURPER'), 0) = 1 THEN   -- Producto Europlazo 16 o Euroterm 16
         v_traza := 7;
         num_err := pac_simul_comu.f_actualiza_duracion_periodo(v_ssolicit, v_nduraci);

         IF num_err <> 0 THEN
            RAISE error;
         END IF;
      ELSE   -- psproduc IN (85, 86, 87, 88, 89, 90) = Producto Ahorro Seguro
         v_traza := 8;
         num_err := pac_simul_comu.f_actualiza_duracion(v_ssolicit, v_nduraci, v_fvencim);

         IF num_err <> 0 THEN
            RAISE error;
         END IF;
      END IF;

/*IF nvl(f_parproductos_v(psproduc, 'TRAMOINTTEC'), 0) = 2 THEN --Si los tramos de interes son por capital actualizamos el valor de éste

    update solseguros_ren
    set icapren=pcapital
    where
    ssolicit=v_ssolicit;

    v_garant := pac_calc_comu.f_cod_garantia(psproduc, 3, NULL,v_ctipgar);
    IF v_garant IS NULL THEN
        num_err:=180588;
      RAISE ERROR;
    END IF;
    num_err := pac_simul_comu.f_actualiza_capital(v_ssolicit, 1, v_garant, pcapital);
    IF num_err <> 0 THEN
      RAISE ERROR;
    END IF;
END IF;*/
      num_err := pac_prod_comu.f_grabar_inttec(psproduc, v_ssolicit, pfefecto, ptipo, pintec,
                                               'SOL');

      IF num_err <> 0 THEN
         RAISE error;
      END IF;

--JRH IMP
/*pac_ref_contrata_rentas.f_actualizar_segurosren(psproduc, pfefecto,pnduraci,    pfvencim, pcforpag,
                                                 prima_per, pcfallaseg1, pcfallaseg2, tasinmuebHI,
                                                 pcttasinmuebHI,capitaldispHI,pctrevRT,forpagorenta,
                                                 v_ssolicit,num_err,'SOL');
IF num_err <> 0 THEN
   oCODERROR := num_err;
   oMSGERROR := f_AXIS_literalES(num_err, pcidioma_user);
   RAISE error;
END IF;*/
 -- tarifamos --
---------------
      v_traza := 10;
      num_err := pac_tarifas.f_tarifar_riesgo_tot('SOL', v_ssolicit, 1, 1,

                                                  -- JLB - I - BUG 18423 COjo la moneda del producto
                                                                                         --        1,
                                                  pac_monedas.f_moneda_producto(psproduc),

-- JLB - F - BUG 18423 COjo la moneda del producto
                                                  pfefecto);

      IF num_err <> 0 THEN
         RAISE error;
      END IF;

-----------------------
-- Valor de ssolicit --
-----------------------
      v_traza := 11;
      RETURN 0;   -- Todo OK
   EXCEPTION
      WHEN error THEN
         p_tab_error(f_sysdate, f_user, 'pac_simul_rentas.f_graba_datos_tarif', v_traza,
                     'parametros: sproduc =' || psproduc || ' v_nduraci =' || v_nduraci,
                     SQLERRM);
         RETURN num_err;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_simul_rentas.f_graba_datos_tarif', v_traza,
                     'parametros: sproduc =' || psproduc || ' v_nduraci =' || v_nduraci,
                     SQLERRM);
         RETURN(108190);   -- Error general
   END f_graba_datos_tarif;

   --v_traza := 10;
         --Validar(Pac_Calculo_Formulas.CALC_FORMUL ( v_fecha_calculo, rDades.SPRODUC, rDades.CACTIVI, rDades.CGARANT, 1, pssolicit, vr_garan.CLAVE, vCapGar, NULL, NULL, 0, pfefecto, 'R' ));
         --v_traza := 11;
         -- Validar(Pac_Calculo_Formulas.CALC_FORMUL ( v_fecha_calculo, rDades.SPRODUC, rDades.CACTIVI, rDades.CGARANT, 1, pssolicit, vr_fall.CLAVE, vCapFall, NULL, NULL, 0, pfefecto, 'R' ));
         --v_traza := 111;
   FUNCTION f_get_dades_calculades_dur(
      ptipo IN NUMBER,
      pssolicit IN NUMBER,
      psproduct IN NUMBER,
      pfefecto IN DATE,
      piprima IN NUMBER,
      pcidioma_user IN literales.cidioma%TYPE,
      v_fvencim IN DATE,
      pfnacimi1 IN DATE,
      pcpais1 IN NUMBER,
      pnum_err OUT NUMBER,
      pintec IN NUMBER DEFAULT NULL)
      RETURN ob_resp_simula_rentas IS
      vtsimulaanys   t_det_simula_rentas := t_det_simula_rentas();

      TYPE rt_dades IS RECORD(
         clave          garanformula.clave%TYPE,
         ccampo         garanformula.ccampo%TYPE
      );

      vr_garan       rt_dades;
      vr_fall        rt_dades;
      vr_provmat     rt_dades;
      ex_error       EXCEPTION;
      num_err        NUMBER;
      v_traza        tab_error.ntraza%TYPE;
      v_errores      ob_errores;
      vsimulacion    ob_resp_simula_rentas;
      error          EXCEPTION;
      --Datos HI
      valortashi     NUMBER := 0;
      pctvalortashi  NUMBER := 0;
      capdispinihi   NUMBER := 0;
      durccrhi       NUMBER := 0;
      primrenthi     NUMBER := 0;
      comisaperthi   NUMBER := 0;
      gastnothi      NUMBER := 0;
      gastgestionhi  NUMBER := 0;
      impuajdhi      NUMBER := 0;
      gatostasacionhi NUMBER := 0;
      gatosgestoriahi NUMBER := 0;
      deudacumhi     NUMBER := 0;
      tramoa         NUMBER := 0;
      tramob         NUMBER := 0;
      tramoc         NUMBER := 0;
      fechaulttrasp  DATE;
      fechainiciorenta DATE;
      taehi          NUMBER := 0;
      rentahi        NUMBER := NULL;
      pctreten       NUMBER := NULL;
      pctretenini    paisprete.pretenc%TYPE := NULL;   --       pctretenini    NUMBER := NULL; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      primacalculada NUMBER := NULL;
      vforpagren     solseguros_ren.cforpag%TYPE;   --       vforpagren     NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---

      PROCEDURE validar(perror IN NUMBER) IS
      BEGIN
         IF perror <> 0 THEN
            v_errores := ob_errores(perror, f_axis_literales(perror, pcidioma_user));
            RAISE ex_error;
         END IF;
      END;
   BEGIN
      pnum_err := 0;

      SELECT cforpag
        INTO vforpagren
        FROM solseguros_ren
       WHERE ssolicit = pssolicit;

      --Hem de tenir la garantia del tipus contractat.
      FOR rdades IN (
                     -- Bug 9685 - APD - 30/04/2009 - en lugar de coger la actividad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
                     SELECT s.sproduc,
                            pac_seguros.ff_get_actividad(s.ssolicit, g.nriesgo, 'SOL') cactivi,
                            s.fvencim, g.cgarant, s.ccolect, s.ctipseg, s.cmodali, s.cramo
                       FROM solgaranseg g, solseguros s
                      WHERE g.ssolicit = s.ssolicit
                        AND f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect,
                                            pac_seguros.ff_get_actividad(s.ssolicit, g.nriesgo,
                                                                         'SOL'),
                                            g.cgarant, 'TIPO') = 3   -- Garantía con la renta
                        AND s.ssolicit = pssolicit
                                                  -- Bug 9685 - APD - 30/04/2009 - Fin
                   ) LOOP
         FOR rformula IN
            (   --Ens guardem les fòrmules necessàries
             -- Bug 9685 - APD - 30/04/2009 - primero se ha de buscar para la actividad en concreto
             -- y si no se encuentra nada ir a buscar a GARANFORMULA para la actividad cero
             SELECT gf.clave, gf.ccampo
               FROM garanformula gf
              WHERE gf.cgarant = rdades.cgarant
                AND gf.cramo = rdades.cramo
                AND gf.cmodali = rdades.cmodali
                AND gf.ctipseg = rdades.ctipseg
                AND gf.ccolect = rdades.ccolect
                AND gf.cactivi = rdades.cactivi
             UNION
             SELECT gf.clave, gf.ccampo
               FROM garanformula gf
              WHERE gf.cgarant = rdades.cgarant
                AND gf.cramo = rdades.cramo
                AND gf.cmodali = rdades.cmodali
                AND gf.ctipseg = rdades.ctipseg
                AND gf.ccolect = rdades.ccolect
                AND gf.cactivi = 0
                AND NOT EXISTS(SELECT gf.clave, gf.ccampo
                                 FROM garanformula gf
                                WHERE gf.cgarant = rdades.cgarant
                                  AND gf.cramo = rdades.cramo
                                  AND gf.cmodali = rdades.cmodali
                                  AND gf.ctipseg = rdades.ctipseg
                                  AND gf.ccolect = rdades.ccolect
                                  AND gf.cactivi = rdades.cactivi)
                                                                  -- Bug 9685 - APD - 30/04/2009 - Fin
            ) LOOP
            CASE rformula.ccampo
               WHEN 'ICGARAC' THEN
                  vr_garan.clave := rformula.clave;
                  vr_garan.ccampo := rformula.ccampo;
                  NULL;
               WHEN 'IPROVAC' THEN
                  vr_provmat.clave := rformula.clave;
                  vr_provmat.ccampo := rformula.ccampo;
               WHEN 'ICFALLAC' THEN
                  vr_fall.clave := rformula.clave;
                  vr_fall.ccampo := rformula.ccampo;
               ELSE
                  NULL;
            END CASE;
         END LOOP;

         FOR v_i IN 1 .. v_tabladuraciones.LAST LOOP   -- Per a cada un dels períodes necessaris a la simulació (en anys)
            DECLARE
               rentabruta     NUMBER;   --La renta bruta resultante
               rentamin       NUMBER;   --La renta mínima resultante
               capfall        NUMBER;   -- El capital de fallecimiento
               intgarant      NUMBER;   ---- interes garantizado en el periodo
               v_fecha_calculo DATE;   --fecha a la que se suponen realizan los cálculos
               vprovmat       NUMBER;   --NUMBER(13, 2);
               v_error        literales.slitera%TYPE;
               vintprom       NUMBER;   --NUMBER(7, 2);
               vintfin        NUMBER;   --NUMBER(7, 2);
               vintmin        NUMBER;   --NUMBER(7, 2);
               v_tipo_penalizacion NUMBER;
               v_imp_penalizacion NUMBER;
               v_rendimiento  NUMBER(7, 2);
               v_nduraci      NUMBER;   --JRH IMP
               v_anualitat    NUMBER;
               num_err        NUMBER;
               anyo           NUMBER;
               tramo          NUMBER;
               vprima         NUMBER;
               formpagren     NUMBER;
               v_fecefecto    DATE;
               importereten   NUMBER;   --NUMBER(13, 2);
               importeneto    NUMBER;   --NUMBER(13, 2);
               vctramtip      NUMBER;
            BEGIN
               --periodo
               v_nduraci := NVL(v_tabladuraciones(v_i).periodo, 1);   --Puede ser vitalicia sin periodo
               v_anualitat := v_tabladuraciones(v_i).anualidad;
               vprima := piprima;

               IF (v_anualitat = 0) THEN
                  v_fecha_calculo := ADD_MONTHS(pfefecto, 12 * NVL(v_nduraci, 0));
                  anyo := v_nduraci;
                  v_fecefecto := pfefecto;
               ELSE
                  v_fecha_calculo := ADD_MONTHS(pfefecto, 12 * v_anualitat);
                  anyo := v_anualitat;
                  v_fecefecto := ADD_MONTHS(pfefecto, 12 *(v_anualitat - 1));
               END IF;

               v_traza := 10;
               --Para cada periodo tendremos que retarificar. Esto lo hace esta función.
               --Guarda las duraciones e ntereses y tarifica.
               --JRH IMP Faltaria el tractament de LRC (afegir l'anulalitat). Revisar si hay que hacerlo en cada bucle.
               num_err := f_graba_datos_tarif(ptipo, rdades.sproduc, pssolicit, v_fecefecto,
                                              v_nduraci, v_fvencim, pfnacimi1,
                                              v_tabladuraciones(v_i).capitales, pintec);

               IF num_err <> 0 THEN
                  v_errores := ob_errores(num_err, f_axis_literales(num_err, pcidioma_user));
                  RAISE ex_error;
               END IF;

               --IF nvl(f_parproductos_v(rDades.SProduc, 'TRAMOINTTEC'), 0) = 3 THEN
                    --tramo:=v_nduraci||LPAD(v_anualitat,3,0); --Hemos de escoger la anualidad que toca
                --ELSE
               tramo := 0;   --El tramo a nivel de seguro siempre vale ahora 0 (31/10/2007)
               --END IF;
               v_traza := 11;
               --Aquesta funció ens retorna els imports més importants de la pòlissa de rendes.
               num_err := pac_calc_rentas.f_get_capitales_rentas(rdades.sproduc, pssolicit,
                                                                 v_fecefecto, tramo, 1, 1,
                                                                 rentabruta, rentamin, capfall,
                                                                 intgarant, 'SOL');
               rentahi := rentabruta;   --Nos sirve para después en HI

               IF num_err <> 0 THEN
                  v_errores := ob_errores(num_err, f_axis_literales(num_err, pcidioma_user));
                  RAISE ex_error;
               END IF;

               v_traza := 110;
               validar(pac_calculo_formulas.calc_formul(v_fecha_calculo, rdades.sproduc,
                                                        rdades.cactivi, rdades.cgarant, 1,
                                                        pssolicit, vr_provmat.clave, vprovmat,
                                                        NULL, NULL, 0, v_fecefecto, 'R'));
               v_traza := 12;
               validar(f_penalizacion(3, 2, rdades.sproduc, NULL, v_fecefecto,
                                      v_imp_penalizacion, v_tipo_penalizacion, 'SOL', 1));
               v_traza := 14;
               -- Calculamos el interés financiero JRH IMP Todo lo de abajo?
               vtsimulaanys.EXTEND;
               v_traza := 16;
               --Omplim la taula amb els valors d'un període
               v_traza := 17;

                 /*IF nvl(f_parproductos_v(rDades.SProduc, 'TRAMOINTTEC'), 0) = 1 THEN
                     tramo:=v_nduraci;
                 ELSIF nvl(f_parproductos_v(rDades.SProduc, 'TRAMOINTTEC'), 0) = 2 THEN
                     tramo:=v_tablaDuraciones(v_i).Capitales;
                 ELSIF nvl(f_parproductos_v(rDades.SProduc, 'TRAMOINTTEC'), 0) = 3 THEN
                     formpagren:= pac_calc_rentas.ff_get_formapagoren('SOL', pssolicit);
                     tramo:=1;--v_nduraci||LPAD(v_anualitat,3,0)||LPAD(formpagren,2,'0'); --JRH IMP Cual
               END IF;*/

               -- Recuperamos el tipo de calculo
               SELECT ctramtip
                 INTO vctramtip
                 FROM intertecmov i, intertecprod p
                WHERE p.sproduc = rdades.sproduc
                  AND p.ncodint = i.ncodint
                  AND i.ctipo = 1   --Para el interes que estamos calculando.
                  AND i.finicio <= v_fecha_calculo
                  AND(i.ffin >= v_fecha_calculo
                      OR i.ffin IS NULL);

               IF vctramtip = 1 THEN
                  tramo := v_nduraci;
               ELSIF vctramtip = 2 THEN
                  tramo := v_tabladuraciones(v_i).capitales;
               ELSIF vctramtip = 3 THEN
                  formpagren := pac_calc_rentas.ff_get_formapagoren('SQL', pssolicit);
                  tramo := 1;   --v_nduraci||LPAD(v_anualitat,3,0)||LPAD(formpagren,2,'0'); --JRH IMP Cual
               END IF;

               v_traza := 18;
               vintmin := pac_inttec.ff_int_producto(rdades.sproduc, 1, v_fecha_calculo, tramo);

               IF vintmin IS NULL THEN
                  v_errores := ob_errores(104396, f_axis_literales(104396, pcidioma_user));
                  RAISE ex_error;
               END IF;

               DECLARE
                  xpreducc       NUMBER;
                  xcgarant       NUMBER;
                  xanys          NUMBER;
                  xerror         NUMBER;
                  pnpagos        NUMBER;
                  v_ctipgar      NUMBER;
                  pclaren        NUMBER;
               BEGIN
                  SELECT pretenc
                    INTO pctretenini
                    FROM paisprete
                   WHERE cpais = pcpais1
                     AND sproduc = psproduct
                     AND finicio = (SELECT MAX(finicio)
                                      FROM paisprete
                                     WHERE cpais = pcpais1
                                       AND sproduc = psproduct
                                       AND finicio <= pfefecto);

                  /*select CCLAREN
                  into pclaren
                  from producto_ren
                  where sproduc=rDades.SProduc;

                  if (pclaren)=0 then --Si no es vitalicia buscamos por duración

                      xanys:=pac_albsgt_snv.f_obtvalor_preg_riesg('SOL', pssolicit,1,1,111);

                      xcgarant := pac_calc_comu.f_cod_garantia(rDades.SProduc, 3, NULL,v_ctipgar);

                      if (xcgarant IS NULL) then
                           v_errores := ob_errores(180588, f_AXIS_literalES(180588, pcidioma_user));
                     RAISE ex_Error;
                      end if;

                      xerror := F_Difdata (PFNACIMI1,trunc(pfefecto), 1, 1, xanys);

                  else
                      xanys:=anyo;
                  end if;


                    xpreducc := NVL(Fbuscapreduc (1, rDades.SProduc, rDades.CACTIVI, xcgarant, TO_CHAR(pfefecto,'yyyymmdd'), xanys),0);
                    */
                  xpreducc := pk_rentas.f_buscaprduccion(1, pssolicit,
                                                         TO_CHAR(pfefecto, 'yyyymmdd'), 0);
                  pctreten := pctretenini *(1 - xpreducc / 100);
                  --número pagos
                  pnpagos := NVL(anyo, 1) * vforpagren;
                  pnpagos := 1;   --JRH IMP de momento lo hacemos sobre la renta mensual (según forma de pago)

                  IF piprima IS NULL THEN   --Para los productos en que la prima se debe calcular porque no la da el usuario.
                     primacalculada := pac_calc_comu.ff_capital_gar_tipo('SOL', pssolicit, 1,
                                                                         3, 1);
                  END IF;

                  v_rendimiento := (rentabruta * pnpagos) *(1 - xpreducc / 100);
                  --v_rendimiento := nvl(PrimaCalculada,piprima) * (1-xpreducc/100);

                  --Interes equivalente
                  vintfin := intgarant *(1 - (pctretenini / 100) *(1 - xpreducc / 100))
                             /(1 - pctretenini / 100);
               EXCEPTION
                  WHEN OTHERS THEN
                     pctreten := 0;
                     v_rendimiento := 0;
               END;

               importereten := pctreten * rentabruta / 100;
               importeneto := rentabruta - importereten;
               vtsimulaanys(vtsimulaanys.LAST) :=
                  ob_det_simula_rentas(anyo, intgarant /*int*/, vintfin /*int2*/,
                                       v_fecha_calculo, rentabruta /*?renta*/, importereten,
                                       importeneto, vprovmat, capfall, rentamin /*rentamin*/,
                                       v_rendimiento /*rcm*/);
               v_traza := 34;
            END;
         END LOOP;

         EXIT;   -- Només hi ha d'haver un registre
      END LOOP;

      vsimulacion := ob_resp_simula_rentas(pssolicit, vtsimulaanys,
                                           NVL(primacalculada, piprima), pctreten /*retIRPF*/,
                                           durccrhi /*durCCRHI*/, primrenthi /*primrentHI*/,
                                           comisaperthi /*comisapertHI*/,
                                           gastnothi /*gastnotHI*/,
                                           gastgestionhi /*gastgestionHI*/,
                                           impuajdhi /*impuajdHI*/,
                                           gatostasacionhi /*gatostasacionHI*/,
                                           gatosgestoriahi /*gatosgestoriaHI*/,
                                           deudacumhi /*deudacumHI*/, taehi /*TAE*/,
                                           tramoa /*tramoA*/, tramob /*tramoB*/,
                                           tramoc /*tramoC*/, fechaulttrasp /*fechaulttrasp*/,
                                           fechainiciorenta /*fechaInicioRenta*/, v_errores);
      RETURN vsimulacion;
   EXCEPTION
      WHEN ex_error THEN
         pnum_err := -4;
         p_tab_error(f_sysdate, f_user, 'pac_simul_rentas.f_get_dades_calculades_dur',
                     v_traza,
                     'parametros: pssolicit =' || pssolicit || ' piprima =' || piprima,
                     'ERROR-' || v_errores.cerror || ':' || v_errores.terror);
         RETURN ob_resp_simula_rentas(pssolicit, vtsimulaanys, NULL, NULL /*pctretIRPF*/,
                                      NULL /*durCCRHI*/, NULL /*primrentHI*/,
                                      NULL /*comisapertHI*/, NULL /*gastnotHI*/,
                                      NULL /*gastgestionHI*/, NULL /*impuajdHI*/,
                                      NULL /*gatostasacionHI*/, NULL /*gatostgestoHI*/,
                                      NULL /*deudacumHI*/, NULL /*TAE*/, NULL /*tramoA*/,
                                      NULL /*tramoB*/, NULL /*tramoC*/, NULL /*fechaulttrasp*/,
                                      NULL /*fechaInicioRenta*/, v_errores);
      WHEN OTHERS THEN
         pnum_err := -1;
         p_tab_error(f_sysdate, f_user, 'pac_simul_rentas.f_get_dades_calculades_dur',
                     v_traza,
                     'parametros: pssolicit =' || pssolicit || ' piprima =' || piprima,
                     SQLERRM);
         RETURN ob_resp_simula_rentas(pssolicit, vtsimulaanys, NULL, NULL /*pctretIRPF*/,
                                      NULL /*durCCRHI*/, NULL /*primrentHI*/,
                                      NULL /*comisapertHI*/, NULL /*gastnotHI*/,
                                      NULL /*gastgestionHI*/, NULL /*impuajdHI*/,
                                      NULL /*gatostasacionHI*/, NULL /*gatosgestoHI*/,
                                      NULL /*deudacumHI*/, NULL /*TAE*/, NULL /*tramoA*/,
                                      NULL /*tramoB*/, NULL /*tramoC*/, NULL /*fechaulttrasp*/,
                                      NULL /*fechaInicioRenta*/,
                                      ob_errores(180160,
                                                 f_axis_literales(180160, pcidioma_user)));
   END f_get_dades_calculades_dur;

   --  JRH f_get_dades_calculades
   --    Únicament preparada per simulacions
   --
   --  Paràmetres
   --      pssolicit  :  número de la simulació
   --      pfefecto   :  data d'alta de la pòlissa
   --      piprima    :  prima unica inicail
   --      pcidioma_user: idioma del usuario
   --          fvencim : data venciment si existeix
   --          pfnacimi1 : data neixament
   --      pndurper : duració del período
   -- JRH  Aquí es donde está toda la historia.
   FUNCTION f_get_dades_calculades(
      ptipo IN NUMBER,
      psproduc IN NUMBER,
      pssolicit IN NUMBER,
      pfefecto IN DATE,
      piprima IN NUMBER,
      pcidioma_user IN literales.cidioma%TYPE,
      fvencim IN DATE,
      pfnacimi1 IN DATE,
      pndurper IN NUMBER,
      pcpais1 IN NUMBER,
      pnum_err OUT NUMBER,
      pintec IN NUMBER DEFAULT NULL)
      RETURN ob_resp_simula_rentas IS
      -- Utilitzats per omplir la simulació. Torna un object amb les dades de la simulació.
      vtsimulaanys   t_det_simula_rentas := t_det_simula_rentas();   --registre on guardar les simulacions per més d'un període
      v_errores      ob_errores;   --Objecte amb els erros
      vsimulacion    ob_resp_simula_rentas;   --Objecte amb tota la informació de la simulació
      ex_error       EXCEPTION;
      v_traza        tab_error.ntraza%TYPE;

      CURSOR durprod(prod IN NUMBER, fecefec IN DATE) IS   --Duracions/Períodes permesos per un producte
         SELECT ndurper
           FROM durperiodoprod
          WHERE sproduc = prod
            AND finicio <= fecefec
            AND((ndurper = pndurper
                 AND pndurper IS NOT NULL)
                OR(pndurper IS NULL))
            AND(ffin >= fecefec
                OR ffin IS NULL);

      CURSOR capitales(prod IN NUMBER, fecefec IN DATE, pctipo IN NUMBER) IS
         SELECT ID.ndesde
           FROM intertecprod ip, intertecmov im, intertecmovdet ID
          WHERE ip.sproduc = prod
            AND ip.ncodint = im.ncodint
            AND im.ctipo = pctipo
            AND im.finicio <= fecefec
            AND(im.ffin >= fecefec
                OR im.ffin IS NULL)
            AND im.ncodint = ID.ncodint
            AND im.finicio = ID.finicio
            AND im.ctipo = ID.ctipo;

      durper         durprod%ROWTYPE;
      existedur      BOOLEAN := FALSE;
      i              NUMBER := 1;
      duracion       NUMBER;
      coderr         NUMBER;
      vtipo          NUMBER;
   BEGIN
      coderr := 0;
      pnum_err := 0;
      v_tabladuraciones.DELETE;   --Taula on informem tots els periodes possibles per a una simulació (i si en té , anualitat per revisió)

      IF ptipo = 1 THEN
         vtipo := 3;
      ELSE
         vtipo := 4;
      END IF;

--        IF nvl(f_parproductos_v(psproduc, 'TRAMOINTTEC'), 0) <> 2 THEN--Tramos de simulacón no van por capital
      OPEN durprod(psproduc, pfefecto);

      FETCH durprod
       INTO durper;

      IF durprod%FOUND THEN
         existedur := TRUE;
      END IF;

      CLOSE durprod;

      --JRH Considerem tots els valors en anys.
      IF existedur THEN   --Si té la possibilitat de contractar varios periodes els informem a la taula de periodes
         IF NVL(f_parproductos_v(psproduc, 'FECHAREV'), 0) = 3 THEN   -- Si a més revisa anualment, posem un registre amb el periode i cada anualitat de revisió
            FOR reg IN durprod(psproduc, pfefecto) LOOP   --Periodes
               FOR j IN 1 .. reg.ndurper LOOP   -- Anualitats
                  v_regduraciones.periodo := reg.ndurper;
                  v_regduraciones.anualidad := j;
                  v_regduraciones.capitales := piprima;
                  v_tabladuraciones(i) := v_regduraciones;
                  i := i + 1;
               END LOOP;
            END LOOP;
         ELSE
            FOR reg IN durprod(psproduc, pfefecto) LOOP   --Periodes
               v_regduraciones.periodo := reg.ndurper;
               v_regduraciones.anualidad := 0;
               v_regduraciones.capitales := piprima;
               v_tabladuraciones(i) := v_regduraciones;
               i := i + 1;
            END LOOP;
         END IF;
      ELSE   --Si no té varios periodes contractables busquem/obtenim directament la duració de la polissa usada a la simulació
               --duracion:=pac_calc_comu.ff_get_duracion('SOL', pssolicit);
               --IF duracion IS NULL THEN
         --        RAISE ex_Error;
           --END IF;
         duracion := pndurper;
         v_regduraciones.periodo := duracion;
         v_regduraciones.anualidad := 0;
         v_regduraciones.capitales := piprima;
         v_tabladuraciones(1) := v_regduraciones;
      END IF;

--    ELSE

      --            FOR Reg in Capitales(psproduc,pfefecto,vtipo) LOOP  --Capitales
--                        v_regduraciones.periodo:=1;
--                        v_regduraciones.anualidad:=0;
--                        v_regduraciones.Capitales:=Reg.ndesde;
--                        v_tablaDuraciones(i):=v_regduraciones;
--                        i:=i+1;
--            END LOOP;

      --    END IF;

      --f_get_dades_calculades_dur ens retorna l'objecte amb tots els valors de la simulació
      vsimulacion := f_get_dades_calculades_dur(ptipo, pssolicit, psproduc, pfefecto, piprima,
                                                pcidioma_user, fvencim, pfnacimi1, pcpais1,
                                                coderr, pintec);

      IF coderr <> 0 THEN
         RAISE ex_error;
      END IF;

      RETURN vsimulacion;
   EXCEPTION
      WHEN ex_error THEN
         pnum_err := 110015;
         p_tab_error(f_sysdate, f_user, 'pac_simul_rentas.f_get_dades_calculades', v_traza,
                     'parametros: pssolicit =' || pssolicit || ' piprima =' || piprima,
                     'ERROR-' || v_errores.cerror || ':' || v_errores.terror);
         RETURN ob_resp_simula_rentas(pssolicit, vtsimulaanys, NULL, NULL /*pctretIRPF*/,
                                      NULL /*durCCRHI*/, NULL /*primrentHI*/,
                                      NULL /*comisapertHI*/, NULL /*gastnotHI*/,
                                      NULL /*gastgestionHI*/, NULL /*impuajdHI*/,
                                      NULL /*gatostasacionHI*/, NULL /*gatosgestHI*/,
                                      NULL /*deudacumHI*/, NULL /*TAE*/, NULL /*tramoA*/,
                                      NULL /*tramoB*/, NULL /*tramoC*/, NULL /*fechaulttrasp*/,
                                      NULL /*fechaInicioRenta*/, v_errores);
      WHEN OTHERS THEN
         -- BUG -21546_108724- 08/02/2012 - JLTS - Cierre de posibles cursores abiertos
         IF durprod%ISOPEN THEN
            CLOSE durprod;
         END IF;

         pnum_err := 110015;
         p_tab_error(f_sysdate, f_user, 'pac_simul_rentas.f_get_dades_calculades', v_traza,
                     'parametros: pssolicit =' || pssolicit || ' piprima =' || piprima,
                     SQLERRM);
         RETURN ob_resp_simula_rentas(pssolicit, vtsimulaanys, NULL, NULL /*pctretIRPF*/,
                                      NULL /*durCCRHI*/, NULL /*primrentHI*/,
                                      NULL /*comisapertHI*/, NULL /*gastnotHI*/,
                                      NULL /*gastgestionHI*/, NULL /*impuajdHI*/,
                                      NULL /*gatostasacionHI*/, NULL /*gatosgestoHI*/,
                                      NULL /*deudacumHI*/, NULL /*TAE*/, NULL /*tramoA*/,
                                      NULL /*tramoB*/, NULL /*tramoC*/, NULL /*fechaulttrasp*/,
                                      NULL /*fechaInicioRenta*/,
                                      ob_errores(180160,
                                                 f_axis_literales(180160, pcidioma_user)));
   END;

   FUNCTION f_genera_sim_rentas(
      ptipo IN NUMBER,
      psproduc IN NUMBER,
      pnombre1 IN VARCHAR2,
      ptapelli1 IN VARCHAR2,
      pfnacimi1 IN DATE,
      psexo1 IN NUMBER,
      pnombre2 IN VARCHAR2,
      ptapelli2 IN VARCHAR2,
      pfnacimi2 IN DATE,
      psexo2 IN NUMBER,
      piprima IN NUMBER,
      pndurper IN NUMBER,
      pfoper IN DATE,
      pctrcap IN NUMBER,
      valtashi IN NUMBER,
      pcttashi IN NUMBER,
      capdisphi IN NUMBER,
      pctreversrtrvd IN NUMBER,
      fecoperhi IN DATE,
      rentpercrt IN NUMBER,
      psseguro IN NUMBER,
      pfefecto IN DATE,
      pfvencim IN DATE,
      pforpagorenta IN NUMBER,
      pssolicit OUT NUMBER,
      pintec IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      /**********************************************************************************************************************************
             f_genera_sim_rentas: Función que genera la simulación y la tarificación (calcula datos)
             26-2-2007. CSI
             Vida Ahorro

             La función retornará
                 a) Si todo es correcto: 0
                 b) Si hay un error: código de error

      **********************************************************************************************************************************/
      v_ssolicit     NUMBER;
      num_err        NUMBER;
      v_nduraci      NUMBER;
      v_fvencim      DATE;
      v_errores      ob_errores;
      error          EXCEPTION;
      v_traza        tab_error.ntraza%TYPE;
   BEGIN
--------------------------
-- se crea la solicitud --
--------------------------
      v_traza := 1;
      num_err := pk_simulaciones.f_crea_solicitud(psproduc, v_ssolicit, 1, pfefecto);

      IF num_err <> 0 THEN
         RAISE error;
      END IF;

---------------------------------------
-- actualizamos los datos del riesgo --
---------------------------------------
      v_traza := 2;
      num_err := pac_simul_comu.f_actualiza_riesgo(v_ssolicit, 1, pfnacimi1, psexo1, pnombre1,
                                                   ptapelli1);

      IF num_err <> 0 THEN
         RAISE error;
      END IF;

------------------------------------------
-- actualizamos los datos del asegurado --
------------------------------------------
      v_traza := 3;
      num_err := pac_simul_comu.f_actualiza_asegurado(v_ssolicit, 1, pfnacimi1, psexo1,
                                                      pnombre1, ptapelli1);

      IF num_err <> 0 THEN
         RAISE error;
      END IF;

---------------------------------------------
-- Informa los datos del segundo asegurado --
---------------------------------------------
      v_traza := 4;

      IF pfnacimi2 IS NOT NULL THEN   -- hay 2 asegurados
         num_err := pac_simul_comu.f_crea_solasegurado(v_ssolicit, 2, ptapelli2, pnombre2,
                                                       pfnacimi2, psexo2);

         IF num_err <> 0 THEN
            RAISE error;
         END IF;
      END IF;

      v_traza := 5;

      DECLARE
         pmensa         VARCHAR2(2000);
         v_ctipgar      NUMBER;
         v_garant       NUMBER;
         v_garantf      NUMBER;
         pcactivi       NUMBER;
         v_icapital     solseguros_ren.icapren%TYPE;   --          v_icapital     NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
         fecharev       DATE;
      BEGIN
  ---------------------------
-- actualizamos la prima --
---------------------------
         v_garant := pac_calc_comu.f_cod_garantia(psproduc, 3, NULL, v_ctipgar);

         IF v_garant IS NULL THEN
            num_err := 180588;
            RAISE error;
         END IF;

         num_err := pac_simul_comu.f_actualiza_capital(v_ssolicit, 1, v_garant, piprima);

         IF num_err <> 0 THEN
            RAISE error;
         END IF;

         --if nvl(pctrcap,0)<>0 then  --Activamos cobertura si contrata fallecimiento
         v_garantf := pac_calc_comu.f_cod_garantia(psproduc, 6, NULL, v_ctipgar);

         IF v_garantf IS NULL THEN
            num_err := 180589;
            RAISE error;
         END IF;

         v_traza := 20;

         UPDATE solgaranseg
            SET cobliga = 1
          WHERE ssolicit = v_ssolicit
            AND nriesgo = 1
            AND cgarant = v_garantf;

         -- Bug 9685 - APD - 30/04/2009 - en lugar de coger la actividad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
         -- Se le pasa nriesgo = 1 ya que en la funcion pk_simulaciones.f_validacion_cobliga tambien
         -- se le pasa 1 al nriesgo
         SELECT pac_seguros.ff_get_actividad(ssolicit, 1, 'SOL') cactivi
           INTO pcactivi
           FROM solseguros
          WHERE ssolicit = v_ssolicit;

         -- Bug 9685 - APD - 30/04/2009 - Fin
         num_err := pk_simulaciones.f_validacion_cobliga(v_ssolicit, 1, 1, v_garantf, 'SEL',
                                                         psproduc, pcactivi, pmensa);

         IF num_err <> 0 THEN
            RAISE error;
         END IF;

         --end if;
         IF ptipo <> 1 THEN
            SELECT frevisio
              INTO fecharev
              FROM seguros_aho
             WHERE sseguro = psseguro;

            v_icapital := pac_provmat_formul.f_calcul_formulas_provi(psseguro, fecharev,
                                                                     'IPROVAC');   --Actualizamos el valor de la provisió
         ELSE
            v_icapital := piprima;
         END IF;

         IF rentpercrt IS NOT NULL THEN   --Si viene informada la renta el capital se ha de poner a 0
            v_icapital := NVL(v_icapital, 0);
         END IF;

         UPDATE solseguros_ren
            SET pcapfall = pctrcap,
                icapren = v_icapital,
                cforpag = pforpagorenta,
                ibruren = NVL(rentpercrt, 0)   --JRH Renta a percibir en el caso de RT
          WHERE ssolicit = v_ssolicit;

         IF SQL%ROWCOUNT <> 1 THEN
            num_err := 180590;
            RAISE error;
         END IF;

         v_traza := 6;
      END;

---------------------------
    -- actualizamos las preguntas --
    ---------------------------
      IF (valtashi IS NOT NULL) THEN
         UPDATE solpregunseg
            SET crespue = valtashi
          WHERE ssolicit = v_ssolicit
            AND nriesgo = 1
            AND cpregun = 100;

         IF SQL%ROWCOUNT <> 1 THEN
            num_err := 180590;
            RAISE error;
         END IF;

         v_traza := 7;
      END IF;

      IF (pcttashi IS NOT NULL) THEN
         UPDATE solpregunseg
            SET crespue = pcttashi
          WHERE ssolicit = v_ssolicit
            AND nriesgo = 1
            AND cpregun = 101;

         IF SQL%ROWCOUNT <> 1 THEN
            num_err := 180590;
            RAISE error;
         END IF;

         v_traza := 8;
      END IF;

      IF (capdisphi IS NOT NULL) THEN
         UPDATE solpregunseg
            SET crespue = capdisphi
          WHERE ssolicit = v_ssolicit
            AND nriesgo = 1
            AND cpregun = 102;

         IF SQL%ROWCOUNT <> 1 THEN
            num_err := 180590;
            RAISE error;
         END IF;

         v_traza := 9;
      END IF;

      IF (fecoperhi IS NOT NULL) THEN
         UPDATE solpregunseg
            SET crespue = TO_CHAR(fecoperhi, 'ddmmyyyy')
          WHERE ssolicit = v_ssolicit
            AND nriesgo = 1
            AND cpregun = 103;

         IF SQL%ROWCOUNT <> 1 THEN
            num_err := 180590;
            RAISE error;
         END IF;

         v_traza := 9;
      END IF;

      --validamos preguntas
      DECLARE
         tipo           NUMBER;
         campo          VARCHAR2(100);
      BEGIN
         num_err := pk_simulaciones.f_valida_solpregunseg(v_ssolicit, 1, psproduc, tipo,
                                                          campo);

         IF num_err <> 0 THEN
            RAISE error;
         END IF;
      END;

      -- commit;

      --JRH IMP
      /*pac_ref_contrata_rentas.f_actualizar_segurosren(psproduc, pfefecto,pnduraci,    pfvencim, pcforpag,
                                                           prima_per, pcfallaseg1, pcfallaseg2, tasinmuebHI,
                                                           pcttasinmuebHI,capitaldispHI,pctrevRT,forpagorenta,
                                                           v_ssolicit,num_err,'SOL');
      IF num_err <> 0 THEN
         oCODERROR := num_err;
           oMSGERROR := f_AXIS_literalES(num_err, pcidioma_user);
         RAISE error;
      END IF;*/

      ---------------
      pssolicit := v_ssolicit;
      RETURN 0;   -- Todo OK
   EXCEPTION
      WHEN error THEN
         RETURN num_err;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_simul_rentas.f_genera_sim_rentas', v_traza,
                     'parametros: sproduc =' || psproduc || ' ptipo =' || ptipo
                     || ' pnombre1=' || pnombre1 || ' ptapelli1=' || ptapelli1
                     || ' pfnacimi1=' || pfnacimi1 || ' psexo1=' || psexo1 || ' pnombre2='
                     || pnombre2 || ' ptapelli2=' || ptapelli2 || ' pfnacimi2=' || pfnacimi2
                     || ' psexo1=' || psexo2 || ' piprima=' || piprima || ' pndurper='
                     || pndurper || ' ppinttec=' || 0 || ' psseguro=' || psseguro,
                     SQLERRM);
         RETURN(108190);   -- Error general
   END f_genera_sim_rentas;

-- ---------------------------------------------------------------------------------------
--       f_get_evoluprovmat: Devuelve los datos de la simulación
--
--       La función retornará
--           a) Si todo es correcto: 0
--           b) Si hay un error: código de error en el parámetro de salida pnum_err
--
-- ---------------------------------------------------------------------------------------
   FUNCTION f_get_evoluprovmat(
      pssolicit IN NUMBER,
      pndurper IN NUMBER,
      pnanyos_transcurridos IN NUMBER,
      pnum_err OUT NUMBER)
      RETURN t_det_simula_rentas IS
      /**********************************************************************************************************************************
             f_get_evoluprovmat: Devuelve los datos de la tabla SOLEVOLUPROVMATSEG
             2-1-2007. CSI
             Vida Ahorro

             La función retornará
                 a) Si todo es correcto: 0
                 b) Si hay un error: código de error en el parámetro de salida pnum_err

      **********************************************************************************************************************************/
      v_t_det_simula_rentas t_det_simula_rentas := t_det_simula_rentas();
      v_ob_det_simula_rentas ob_det_simula_rentas;
      ncount         NUMBER := 0;

      CURSOR c_prov IS
         SELECT   *
             FROM solevoluprovmatseg
            WHERE ssolicit = pssolicit
              AND nanyo <= pndurper
         ORDER BY nanyo, fprovmat;
   BEGIN
      pnum_err := 0;
      v_t_det_simula_rentas.DELETE;

      FOR prov IN c_prov LOOP
         ncount := ncount + 1;
         v_t_det_simula_rentas.EXTEND;
         v_ob_det_simula_rentas := ob_det_simula_rentas(prov.nanyo + pnanyos_transcurridos,
                                                        0 /*int*/, 0 /*int2*/, prov.fprovmat,
                                                        0 /*renta*/, 0, 0, prov.iprovmat,
                                                        prov.icapfall, 0 /*rentamin*/,
                                                        0 /*rcm*/);
         v_t_det_simula_rentas(ncount) := v_ob_det_simula_rentas;
      END LOOP;

      RETURN v_t_det_simula_rentas;
   EXCEPTION
      WHEN OTHERS THEN
         v_ob_det_simula_rentas := NULL;
         v_t_det_simula_rentas.DELETE;
         pnum_err := 180160;   -- Error al leer de la tabla EVOLUPROVMATSEG
         p_tab_error(f_sysdate, f_user, 'pac_simul_rentas.f_get_evoluprovmat', NULL,
                     'parametros: pssolicit =' || pssolicit || ' pndurper =' || pndurper,
                     SQLERRM);
         RETURN v_t_det_simula_rentas;
   END f_get_evoluprovmat;
/*
     -- Ref 2253. : F_GENERA_SIM_PP.
  --
  --       F_GENERA_SIM_PP:
  --
  --       La función retornará
  --           a) Si todo es correcto: 0
  --           b) Si hay un error: código de error en el parámetro de salida pnum_err
  --
   FUNCTION f_genera_sim_pp(psproduc IN NUMBER, psseguro IN NUMBER,
                            -- Persona 1
                            ptNombre1      IN PERSONAS.TNOMBRE%TYPE,
                            ptApellido1    IN PERSONAS.TAPELLI%TYPE,
                            pfNacimiento1  IN PERSONAS.FNACIMI%TYPE,
                            pcSexo1        IN PERSONAS.CSEXPER%TYPE,
                            -- Persona 2
                            ptNombre2      IN PERSONAS.TNOMBRE%TYPE,
                            ptApellido2    IN PERSONAS.TAPELLI%TYPE,
                            pfNacimiento2  IN PERSONAS.FNACIMI%TYPE,
                            pcSexo2        IN PERSONAS.CSEXPER%TYPE,
                            pfefecto IN DATE, pfvencim IN DATE,
                            piprima IN NUMBER, piperiodico IN NUMBER,
                            ppInteres IN NUMBER, pprevalorizacion IN NUMBER,
                            ppinteres_pres IN NUMBER, pprevalorizacion_pres IN NUMBER DEFAULT NULL, preversion_pres IN NUMBER DEFAULT NULL, panosrenta_pres IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
    num_err    NUMBER;
    v_lineas    NUMBER;
    exError    EXCEPTION;
    v_traza     TAB_ERROR.NTRAZA%TYPE;
  BEGIN
    ---------------
    -- tarifamos --
    ---------------
    v_traza := 1;
    num_err := PAC_SIMULACION.F_pac_calc_comuAPOR_PP
                                      ( pfNacimiento1,
                                        pfNacimiento2,
                                        pcSexo1,
                                        pcSexo2,
                    pfVencim,
                    TRUNC(MONTHS_BETWEEN(pfVencim,pfNacimiento1) / 12),
                    ptNombre1,
                    ptNombre2,
                                        piperiodico,
                                        NVL(piprima,0),
                                        NVL(ppinteres,0),
                                        NVL(pprevalorizacion,0),
                                        NVL(ppinteres_pres,0),
                                        NVL(pprevalorizacion_pres,0),
                                        NVL(preversion_pres,CASE WHEN pfNacimiento2 IS NOT NULL THEN 100 ELSE 0 END),
                                        NVL(panosrenta_pres,0),
                                        v_lineas ) ;
    IF num_err <> 0 THEN
      num_err := 108029;
      RAISE exError;
    END IF;

    RETURN 0; -- Todo OK

   EXCEPTION
     WHEN ExError THEN
         RETURN num_err;
     WHEN OTHERS THEN
           p_tab_error(f_sysdate,  F_user,  'pac_simul_rentas.f_genera_sim_rentas',v_traza, 'parametros: sproduc ='||psproduc||
                       ' ptNombre1='||ptNombre1||' ptApellido1='||ptApellido1||' pfNacimiento1='||pfNacimiento1||' pcSexo1='||pcSexo1||
                       ' ptNombre2='||ptNombre2||' ptApellido2='||ptApellido2||' pfNacimiento2='||pfNacimiento2||' pcSexo2='||pcSexo2||
                       ' piprima='||piprima||' ppInteres='||ppInteres||' psseguro='||psseguro,
                       SQLERRM);
         RETURN (108190);  -- Error general
  END;

  -- Ref 2253
  --
  --  F_GET_DADES_PP: Carrega les dades que són a SIMULAPP i DETSIMULAPP a un objecte tipus OB_RESP_SIMULA_PP
  --
  --  Paràmetres
  --    pcidioma_user   Idioma en que mostrar l'error
  FUNCTION f_get_dades_pp (pcidioma_user IN LITERALES.CIDIOMA%TYPE) RETURN ob_resp_simula_pp IS
    v_ob_resp_simula_pp ob_resp_simula_pp;
    llista t_det_simula_pp := t_det_simula_pp();
    v_traza TAB_ERROR.NTRAZA%TYPE;
  BEGIN
    v_traza := 1;
    FOR rCap IN ( SELECT APORREA, DURANOS, DURMESES, RENTAVIT
                    FROM SIMULAPP
                    WHERE SESION = USERENV('SESSIONID') ) LOOP
      FOR rDades IN ( SELECT SESION,EJERCICIO,FFINEJER,APORMES,CAPITAL
                     FROM DETSIMULAPP
                     WHERE SESION = USERENV('SESSIONID')
                     order by SESION, EJERCICIO )  LOOP

        v_traza := 2;
        llista.EXTEND;
        v_traza := 3;
        llista(llista.LAST) := OB_DET_SIMULA_PP(rDades.ejercicio, rDades.fFinEjer, rDades.apormes,rDades.capital);
      END LOOP;
      v_traza := 4;
      v_ob_resp_simula_pp := OB_RESP_SIMULA_PP(llista, llista(llista.LAST).iCapital, rCap.aporrea, rCap.duranos, rCap.durmeses, rCap.rentavit, OB_ERRORES(0,NULL) );
    END LOOP;
    RETURN v_ob_resp_simula_pp;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,  F_user,  'pac_simul_rentas.f_get_dades_pp', v_traza, 'parametros: sessionid ='||USERENV('SESSIONID'), SQLERRM);

      RETURN OB_RESP_SIMULA_PP(llista, NULL, NULL, NULL, NULL, NULL, OB_ERRORES(180431, f_AXIS_literalES(180431, pcidioma_user)) );
  END;

*/
END pac_simul_rentas;

/

  GRANT EXECUTE ON "AXIS"."PAC_SIMUL_RENTAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_SIMUL_RENTAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_SIMUL_RENTAS" TO "PROGRAMADORESCSI";
