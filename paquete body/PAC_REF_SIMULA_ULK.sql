--------------------------------------------------------
--  DDL for Package Body PAC_REF_SIMULA_ULK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_REF_SIMULA_ULK" 
AS

   FUNCTION f_valida_prima_ulk(ptipo IN NUMBER, psproduc IN NUMBER, pcactivi IN NUMBER, pcgarant IN NUMBER,
                               picapital IN NUMBER, pcforpag IN NUMBER, psperson IN NUMBER, pcpais IN NUMBER,
                               pcidioma_user IN NUMBER DEFAULT F_IdiomaUser, coderror OUT NUMBER, msgerror OUT VARCHAR2)
     RETURN NUMBER IS

     num_err       NUMBER;
     v_capmin        NUMBER;
     v_capmax         NUMBER;
   BEGIN
      num_err := PAC_REF_SIMULA_AHO.f_valida_prima_aho(ptipo, psproduc, pcactivi, pcgarant, picapital, pcforpag,
                                                    psperson, pcpais, pcidioma_user, coderror, msgerror);
      RETURN num_err;
   END f_valida_prima_ulk;

   FUNCTION f_simulacion(psproduc IN NUMBER, psperson1 IN NUMBER, pnombre1 IN VARCHAR2,  ptapelli1 IN VARCHAR2,
            pfnacimi1 IN DATE, psexo1 IN NUMBER, pcpais1 IN NUMBER, psperson2 IN NUMBER, pnombre2 IN VARCHAR2,  ptapelli2 IN VARCHAR2, pfnacimi2 IN DATE,
            psexo2 IN NUMBER, pcpais2 IN NUMBER, pcidioma IN NUMBER, pcidioma_user IN NUMBER DEFAULT F_IdiomaUser, piprima IN NUMBER, pndurper IN NUMBER,
            ppinttec IN NUMBER, pcagente IN NUMBER)
      RETURN ob_resp_simula_pu_ulk  IS
    /**********************************************************************************************************************************
     F_SIMULACION_PU: función para simular la contratación de pólizas de prima única (EUROPLAZO16, EUROTERM16,
                                                   y AHORRO SEGURO
     2-1-2007. CSI
     Vida Ahorro

     La función retornará  un objeto de tipo ob_resp_simula_pu con los datos de los valores garantizados y el error
     (si se ha producido)
     ptipo: 1 .- Alta
     Si ptipo =2 (revisión) los parámetros pnpoliza y pncertif deben venir informados
    **********************************************************************************************************************************/
     v_ob_resp_simula_pu                 ob_resp_simula_pu_ulk;
     v_t_det_simula_pu                 t_det_simula_pu := t_det_simula_pu();
         v_t_det_simula_pu_ulk                 t_det_simula_pu_ulk := t_det_simula_pu_ulk();

         v_ob_det_simula_pu                  ob_det_simula_pu_ulk;

     v_errores                   ob_errores;

     ndir           NUMBER:= 0;
     num_err       NUMBER;
     v_ssolicit       NUMBER;
     vcapvenci     NUMBER;
     vcapndurper   NUMBER;
     ncontador     NUMBER;
     prendimiento  NUMBER;
         v_fefecto     DATE;
         v_frevisio    DATE;
         v_nanyos_transcurridos  NUMBER := 0;
         v_nduraci    NUMBER;
         v_fvencim    DATE;
         v_traza      TAB_ERROR.NTRAZA%TYPE;

     error   EXCEPTION;
     ocoderror           NUMBER;
     omsgerror           VARCHAR2(1000);

         -- RSC 26/11/2007
         vCapEuroplazo  NUMBER(13,2);
         vCapIbex       NUMBER(13,2);
         pPrimaIbex     NUMBER(5,2);
         ttramoibex     NUMBER;
         itramoIbex     NUMBER(13,2);
         pinttec        NUMBER(5,2);
         pfvencim       DATE := NULL;

  BEGIN
        v_traza := 1;

        -- --------------------------------------------------------------
        -- Validamos que los parámetros obligatorios vengan informados --
        -- --------------------------------------------------------------
        IF (psproduc IS NULL) THEN
           v_errores := ob_errores(-999, 'f_simulacion_pu: Param PSPRODUC is null');
           RAISE ERROR;
        END IF;

        IF (ptapelli1 IS NULL OR pnombre1 IS NULL) THEN
           v_errores := ob_errores(-999,  'f_simulacion_pu: Param PNOMBRE1 is null');
           RAISE ERROR;
        END IF;

        IF pfnacimi1 IS NULL THEN
           v_errores := ob_errores(-999,  'f_simulacion_pu: Param PFNACIMI1 is null');
           RAISE ERROR;
        END IF;

        IF psexo1 IS NULL THEN
           v_errores := ob_errores(-999,  'f_simulacion_pu: Param PSEXO1 is null');
           RAISE ERROR;
        END IF;

        IF pcpais1 IS NULL THEN
           v_errores := ob_errores(-999,  'f_simulacion_pu: Param PCPAIS1 is null');
           RAISE ERROR;
        END IF;

        IF (pnombre2 IS NOT NULL OR ptapelli2 IS NOT NULL)
           AND (pfnacimi2 IS NULL OR psexo2 IS NULL OR pcpais2 IS NULL) THEN
           v_errores := ob_errores(-999,  'f_simulacion_pu: Faltan parametros del segundo asegurado');
           RAISE ERROR;
        END IF;

        IF piprima IS NULL THEN
           v_errores := ob_errores(-999,  'f_simulacion_pu: Param PPRIMA is null');
           RAISE ERROR;
        END IF;

        IF (pndurper IS NULL) and pfvencim is null THEN
           v_errores := ob_errores(-999, 'f_simulacion_pu: Param PNDURPER is null');
           RAISE ERROR;
        END IF;

        --IF NVL(f_parproductos_v(psproduc, 'DURPER'),0) <> 1  AND pfvencim is null THEN
        --   v_errores := ob_errores(-999, 'f_simulacion_pu: Param PFVENCIM is null');
        --   RAISE ERROR;
        --END IF;

        IF (ppinttec IS NULL) THEN
           v_errores := ob_errores(-999, 'f_simulacion_pu: Param PPINTTEC is null');
           RAISE ERROR;
        END IF;

    ----------------------------------------------------------------------------------------
        -- Inicializamos la variable pg_idioma para ser utilizada desde el resto de funciones --
    ----------------------------------------------------------------------------------------
        -- Se valida que el idioma esté informado
        v_traza := 2;
        num_err := Pac_Val_Comu.F_VALIDA_IDIOMA(pcidioma);
        IF num_err <> 0 THEN
           v_errores := ob_errores(num_err, f_literal(num_err, pcidioma_user));
           RAISE ERROR;
        END IF;

        -------------------------------------------------------------------------------------------------------------------
        -- Si ptipo = 1 (Alta), la fecha de efecto es SYSDATE
        -------------------------------------------------------------------------------------------------------------------
        v_fefecto := trunc(f_sysdate);

       ----------------------------------------
       -- Validamos los datos: edad, etc...  --
       ----------------------------------------
       v_traza := 6;
       num_err := pac_ref_simula_comu.f_valida_asegurados(psproduc, psperson1, pfnacimi1, psexo1, pcpais1, psperson2, pfnacimi2, psexo2, pcpais2,
                                                      v_fefecto, null, null, 0, pcidioma_user,
                                                      oCODERROR, oMSGERROR);
       IF num_err IS NULL THEN
          v_errores := ob_errores(oCODERROR, oMSGERROR);
              RAISE ERROR;
       END IF;

       ----------------------------------------
       -- Validamos la prima                 --
       ----------------------------------------
       v_traza := 7;
       num_err := f_valida_prima_ulk(1, psproduc, 0, 48, piprima, 0, psperson1, pcpais1, pcidioma_user,
                                     oCODERROR, oMSGERROR);
       IF num_err IS NULL THEN
          v_errores := ob_errores(oCODERROR, oMSGERROR);
              RAISE ERROR;
       END IF;

       ----------------------------------------
       -- Validamos la duración              --
       ----------------------------------------
       -- MSR 3/7/2007. Incluore Ahorro Seguro / PE / PPA
       IF NVL(f_parproductos_v(psproduc, 'DURPER'),0) = 1 THEN  -- Producto Europlazo 16 o Euroterm 16
         v_traza := 8;
         num_err := Pac_Val_Comu.F_VALIDA_DURACION(psproduc, pfnacimi1, v_fefecto,
                                                  pndurper, pfvencim);
         IF num_err <> 0 THEN
                v_errores := ob_errores(num_err, f_literal(num_err, pcidioma_user));
                    RAISE ERROR;
         END IF;
       ELSE -- Ibex 35 Garantizado
          v_traza := 10;
          v_nduraci := pndurper;
          v_fvencim := pfvencim;
          num_err := pac_calc_comu.F_CALCULA_FVENCIM_NDURACI(psproduc, pfnacimi1, v_fefecto, NULL, v_nduraci, v_fvencim);
          IF num_err <> 0 THEN
            v_errores := ob_errores(num_err, f_literal(num_err, pcidioma_user));
            RAISE Error;
          END IF;
       END IF;

       ------------------------------------------------------------
       -- Si todo es correcto generamos la solicitud y tarifamos --
       ------------------------------------------------------------
       v_traza := 11;
       num_err :=  pac_simul_ulk.f_genera_sim_pu(psproduc,
                                                  pnombre1, ptapelli1, pfnacimi1, psexo1,
                                                  pnombre2, ptapelli2, pfnacimi2, psexo2,
                                                  piprima, pndurper, pfvencim, ppinttec,
                                                  v_fefecto, v_ssolicit);
       IF num_err <> 0 THEN
          v_errores := ob_errores(num_err, f_literal(num_err, pcidioma_user));
              RAISE ERROR;
       END IF;

      ---------------------------
      -- Devolvemos los datos  --
      ---------------------------
      v_traza := 12;
      IF NVL(f_parproductos_v(psproduc, 'EVOLUPROVMATSEG'),0) = 1  THEN
           -- Agafa dels que han desat les dades a SOLEVOLUPROVMATSEG
       v_t_det_simula_pu := pac_simul_ulk.f_get_evoluprovmat(v_ssolicit, pndurper, v_nanyos_transcurridos, num_err);
       IF num_err <> 0 THEN
          v_errores := ob_errores(num_err, f_literal(num_err, pcidioma_user));
              RAISE ERROR;
            END IF;

           v_traza := 13;
       ncontador := 0;
       vcapvenci := NULL;
         prendimiento := NULL;

       ncontador := v_t_det_simula_pu.COUNT;

       IF ncontador <> 0 THEN
               vcapndurper := v_t_det_simula_pu(ncontador).icapgar;
                 prendimiento := Round(((POWER ((vcapndurper/piprima), (1/pndurper)) - 1) * 100),2);
       END IF;

           v_traza := 14;
       vcapvenci := pac_calc_comu.ff_Capital_Gar_Tipo('SOL', v_ssolicit, 1, 5, 1);
       IF vcapvenci IS NULL THEN
             v_errores := ob_errores(153052, f_literal(153052, pcidioma_user));  -- Error al buscar el capital de la garantía
             RAISE ERROR;
       END IF;

           --------------------------------------------------------------------------------------------------------
            -- Obtenemos parte de capital Europlazo
            v_traza:= 311;
            BEGIN
               SELECT NVL(crespue,0) into vCapEuroplazo
               from solpregunseg
               where ssolicit = v_ssolicit
               and cpregun = 1012;
            exception
               when others then
                vCapEuroplazo := 0;
            end;

            -- Obtenemos parte de capital Ibex 35
            v_traza:= 312;
            BEGIN
               SELECT NVL(crespue,0) into vCapIbex
               from solpregunseg
               where ssolicit = v_ssolicit
               and cpregun = 1013;
            exception
               when others then
                  vCapIbex := 0;
            end;

            -- Porcentaje de la prima única inicial destinado al indice
            pPrimaIbex := (vCapIbex/piprima)*100;

            ttramoIbex := -60;
            WHILE (ttramoIbex <= 60) LOOP
              IF ttramoIbex <= 0 THEN
                itramoIbex := vCapIbex*(ttramoIbex/100) + vCapIbex;
                v_t_det_simula_pu_ulk.EXTEND;
                v_t_det_simula_pu_ulk(v_t_det_simula_pu_ulk.LAST) := ob_det_simula_pu_ulk(ttramoIbex,
                                                                                pPrimaIbex*((100+ttramoIbex)/100),
                                                                                itramoIbex,
                                                                                NULL) ;
              ELSE
                itramoIbex := vCapIbex*(ttramoIbex/100) + vCapIbex;
                v_t_det_simula_pu_ulk.EXTEND;
                v_t_det_simula_pu_ulk(v_t_det_simula_pu_ulk.LAST) := ob_det_simula_pu_ulk(ttramoIbex,
                                                                                pPrimaIbex*((100+ttramoIbex)/100),
                                                                                itramoIbex,
                                                                                (itramoIbex/(piprima*(ttramoIbex/100)))*100) ;
              END IF;
              ttramoIbex := ttramoIbex + 20;
            END LOOP;

            SELECT pinttec INTO pinttec
            FROM solintertecseg
            WHERE ssolicit = v_ssolicit;
            --------------------------------------------------------------------------------------------------------------

       v_ob_resp_simula_pu := ob_resp_simula_pu_ulk(v_ssolicit, v_t_det_simula_pu, piprima, prendimiento, vcapvenci, pinttec, vCapIbex, pPrimaIbex, v_t_det_simula_pu_ulk, v_errores);
      ELSE
        -- Agafa dels que NO han desat les dades a SOLEVOLUPROVMATSEG
         v_ob_resp_simula_pu := pac_simul_ulk.f_get_dades_calculades(v_ssolicit, v_fefecto, piprima, pcidioma_user, num_err);
      END IF;

       --------------------------------------------------------------------------------------------------------
       -- Se inserta un registro en SIMULAESTADIST para realizar estadísticas de las simulaciones realizadas --
       --------------------------------------------------------------------------------------------------------
       v_traza := 15;
       num_err := pac_simul_comu.f_ins_simulaestadist(pcagente, psproduc, 1);
       IF num_err <> 0 THEN
          v_errores := ob_errores(num_err, f_literal(num_err, pcidioma_user));
              RAISE ERROR;
       END IF;
       --------------------
       -- Todo ha ido OK --
       --------------------
       Commit;
       RETURN v_ob_resp_simula_pu;

  EXCEPTION
    WHEN error THEN
        v_ob_det_simula_pu := NULL;
        v_t_det_simula_pu.DELETE;
        v_ob_resp_simula_pu := ob_resp_simula_pu_ulk(v_ssolicit, v_t_det_simula_pu, NULL, NULL, NULL, NULL, NULL, NULL, v_t_det_simula_pu_ulk, v_errores);
        Rollback;
        RETURN v_ob_resp_simula_pu;
     WHEN OTHERS THEN
        v_ob_det_simula_pu := NULL;
        v_t_det_simula_pu.DELETE;
        v_errores := ob_errores(-999, 'Pac_Ref_Simula_Ulk.f_simulacion_pu: '||f_literal(108190,pcidioma));  -- Error General
    v_ob_resp_simula_pu := ob_resp_simula_pu_ulk(v_ssolicit, v_t_det_simula_pu, NULL, NULL, NULL, NULL, NULL, NULL, v_t_det_simula_pu_ulk, v_errores);
        Rollback;
        p_tab_error(f_sysdate,  F_USER,  'Pac_Ref_Simula_Ulk.f_simulacion_pu', v_traza, 'f_simulacion_pu',SQLERRM);
        RETURN v_ob_resp_simula_pu;

  END f_simulacion;
END Pac_Ref_Simula_Ulk;

/

  GRANT EXECUTE ON "AXIS"."PAC_REF_SIMULA_ULK" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_REF_SIMULA_ULK" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_REF_SIMULA_ULK" TO "PROGRAMADORESCSI";
