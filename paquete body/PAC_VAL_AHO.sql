--------------------------------------------------------
--  DDL for Package Body PAC_VAL_AHO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_VAL_AHO" 
AS

  FUNCTION f_valida_prima_aho(ptipo IN NUMBER, psproduc IN NUMBER, psperson IN NUMBER, ptipo_prima IN NUMBER, pprima IN NUMBER, pcforpag IN NUMBER, pfefecto IN DATE DEFAULT F_Sysdate)
  RETURN NUMBER IS
  /*********************************************************************************************************************************
   Función que valida la prima periódica de una póliza de ahorro
   Parámetros de entrada: . ptipo := 1 - alta o simulación
	                                 2 - suplemento o modificación
                          . psproduc = Identificador del producto
                          . psperson = Identificador de la persona
                          . ptipo_prima = Tipo de prima : 3.Prima Periódica
                                                          4.Prima inicial o extraordinaria
                          . pprima = Importe de la prima períodica
                          . pcforpag = Código de forma de pago
   *******************************************************************************************************************************/
    v_cgarant       NUMBER;
    v_ctipgar       NUMBER;
    v_capmin        NUMBER;
    v_capmax        NUMBER;
    num_err         NUMBER;
  BEGIN

    -- Se busca el código de la garantía
    v_cgarant := pac_calc_comu.f_cod_garantia(psproduc, ptipo_prima, NULL, v_ctipgar);

    -- Se valida el importe de la prima mínima y máxima
    num_err := Pac_Val_Comu.f_valida_capital(ptipo, psproduc, 0,v_cgarant, pprima, pcforpag, v_capmin, v_capmax);
    IF num_err <> 0 THEN
       RETURN num_err;
    END IF;

    -- Se valida el importe de la prima según la persona: residente - no residente, cúmulos
    num_err := Pac_Val_Comu.f_valida_capital_persona(ptipo, psproduc, 0, v_cgarant, pprima, psperson, null, pfefecto);
    IF num_err <> 0 THEN
       RETURN num_err;
    END IF;

    RETURN 0;

  EXCEPTION
    WHEN OTHERS THEN
         p_tab_error (f_sysdate,  F_USER, 'Pac_Val_Aho.f_valida_prima_aho', 1,  'parametros: ptipo = '||ptipo||' sproduc ='||psproduc||
                      ' psperson ='||psperson||' ptipo_prima = '||ptipo_prima||' pprima = '||pprima||' pcforpag = '||pcforpag,SQLERRM );
         RETURN 108190;  -- Error general
  END f_valida_prima_aho;


  FUNCTION f_valida_garantia_adicional(psproduc IN NUMBER, psperson IN NUMBER, pcobliga IN NUMBER, ptipo_garant IN NUMBER, ppropietario_garant IN NUMBER, pfefecto IN DATE)
    RETURN NUMBER IS

    v_garant     NUMBER;
    v_ctipgar    NUMBER;
    num_err      NUMBER;
  BEGIN

    IF psperson IS NOT NULL THEN
       IF pcobliga = 1 THEN -- la garantia adicional está contratada
          v_garant := pac_calc_comu.f_cod_garantia(psproduc, ptipo_garant, ppropietario_garant, v_ctipgar);
          IF v_garant IS NOT NULL THEN
             num_err := pac_val_comu.f_valida_edad_garant(psproduc, 0, v_garant, psperson, pfefecto);
             IF num_err <> 0 THEN
                RETURN num_err;
             END IF;
          ELSE
            RETURN 180434;  -- Garantía no contratable
          END IF;
       END IF;
    END IF;

    RETURN 0;

  EXCEPTION
    WHEN OTHERS THEN
         p_tab_error (f_sysdate,  F_USER, 'Pac_Val_Aho.f_valida_garantia_adicional', 1,  'parametros: psproduc = '||psproduc||
                      ' psperson ='||psperson||' pcobliga = '||pcobliga||' ptipo_garant = '||ptipo_garant||
                      ' ppropietario_garant = '||ppropietario_garant||' pfefecto = '||pfefecto, SQLERRM );
         RETURN 108190;  -- Error general
  END f_valida_garantia_adicional;


   FUNCTION f_solicitud_traspaso (pcinout IN NUMBER, psseguro IN NUMBER, ocoderror OUT NUMBER)
      RETURN NUMBER
   IS
      err         EXCEPTION;
      v_sproduc   productos.sproduc%TYPE;
      v_cagrpro   productos.cagrpro%TYPE;
      v_valpar    NUMBER;
      num_err     NUMBER;
      v_count     NUMBER;
   BEGIN
      SELECT sproduc, cagrpro
        INTO v_sproduc, v_cagrpro
        FROM seguros
       WHERE sseguro = psseguro;

      IF NVL (f_prodactivo (v_sproduc), 0) != 1
      THEN
         ocoderror := 101176;
         RAISE err;
      END IF;

      IF f_situacion_v (psseguro, TRUNC (SYSDATE)) != 1
      THEN
         ocoderror := 102662;
         RAISE err;
      END IF;

      IF pcinout = 1
      THEN
         num_err := f_parproductos (v_sproduc, 'TDC234_IN', v_valpar);

         IF NVL (v_valpar, 0) != 1
         THEN
            ocoderror := 500186;
            RAISE err;
         END IF;

         IF v_cagrpro = 11
         THEN
            IF NVL (f_ppabierto (psseguro, NULL, TRUNC (SYSDATE)), 'X') != 'A'
            THEN
               ocoderror := 500185;
               RAISE err;
            END IF;
         END IF;
      ELSE
         num_err := f_parproductos (v_sproduc, 'TDC234_OUT', v_valpar);

         IF NVL (v_valpar, 0) != 1
         THEN
            ocoderror := 500186;
            RAISE err;
         END IF;

         SELECT COUNT (1)
           INTO v_count
           FROM trasplainout
          WHERE sseguro = psseguro AND cinout = 2 AND cestado IN (1, 2);

         IF NVL (v_count, 0) > 0
         THEN
            ocoderror := 108298;
            RAISE err;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN err
      THEN
         RETURN NULL;
      WHEN OTHERS
      THEN
         p_tab_error (SYSDATE,
                      getuser,
                      'VALIDA_AHO.f_solicitud_traspaso',
                      NULL,
                      'pcinout  = ' || pcinout || ' psseguro = ' || psseguro,
                      SQLERRM
                     );
         ocoderror := 500188;
         RETURN NULL;
   END f_solicitud_traspaso;

END Pac_Val_Aho;

/

  GRANT EXECUTE ON "AXIS"."PAC_VAL_AHO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_VAL_AHO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_VAL_AHO" TO "PROGRAMADORESCSI";
