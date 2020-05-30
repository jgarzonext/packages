--------------------------------------------------------
--  DDL for Package PAC_VAL_RENTAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_VAL_RENTAS" AUTHID CURRENT_USER IS
   FUNCTION f_valida_prima_rentas(
      ptipo IN NUMBER,
      psproduc IN NUMBER,
      psperson IN NUMBER,
      ptipo_prima IN NUMBER,
      pprima IN NUMBER,
      pcforpag IN NUMBER,
      pfefecto IN DATE DEFAULT f_sysdate)
      RETURN NUMBER;

--FUNCTION f_valida_garantia_adicional(psproduc IN NUMBER, psperson IN NUMBER, pcobliga IN NUMBER, ptipo_garant IN NUMBER, ppropietario_garant IN NUMBER, pfefecto IN DATE)
--RETURN NUMBER;
   FUNCTION f_valida_percreservcap(psproduc IN NUMBER, pfallec IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_valida_forma_pago_renta(psproduc IN NUMBER, formapago IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_valida_pct_revers(psproduc IN NUMBER, prevers IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_valida_perctasacio(psproduc IN NUMBER, pcttasinmuebhi IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_valida_capitaldisp(
      psproduc IN NUMBER,
      tasinmuebhi IN NUMBER,
      capitaldisphi IN NUMBER)
      RETURN NUMBER;

--Validación del suplemento de cambio de capital
   FUNCTION f_valida_cambreservcap(psseguro IN NUMBER, pcapital IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_valida_gestion_rentas(
      psproduc IN NUMBER,
      pctipban IN NUMBER,
      pfefecto IN DATE,
      pfnacimi IN DATE,
      pcidioma IN NUMBER,
      pcforpag IN NUMBER,
      pnduraci IN NUMBER,
      pfvencim IN DATE,
      pcbancar IN VARCHAR2,
      pcidioma_user IN NUMBER DEFAULT f_idiomauser,
      pformpagorenta IN NUMBER,
      ocoderror OUT NUMBER,
      omsgerror OUT VARCHAR2)
      RETURN NUMBER;

   --
   -- La funció retorna 0 si tot és correcte
   --                  codi error si no es compleix alguna validació
   --  Informar psPerson únicamente cuando se haya realizado la búsqueda por asegurado.
   --
   FUNCTION f_valida_permite_impr_libreta(psseguro seguros.sseguro%TYPE, psperson IN NUMBER)
      RETURN NUMBER;
END pac_val_rentas;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_VAL_RENTAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_VAL_RENTAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_VAL_RENTAS" TO "PROGRAMADORESCSI";
