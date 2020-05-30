--------------------------------------------------------
--  DDL for Function F_DESRIESGO_T_DWH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_DESRIESGO_T_DWH" (
   psseguro IN NUMBER,
   pnriesgo IN NUMBER,
   pfriesgo IN DATE,
   pcidioma IN NUMBER)
   RETURN VARCHAR2 AUTHID DEFINER IS
/***********************************************************************
   De uso exclusivo en el módulo de DWH, esta función llama a F_DESRIESGO_T para obtener la descripción del riesgo, después
   de que previamente haya inicializado el contexto.
***********************************************************************/
   w_triesgo      VARCHAR2(200);
   w_nerror       NUMBER;
BEGIN
   w_nerror :=
      pac_contexto.f_inicializarctx
              (pac_parametros.f_parempresa_t(pac_parametros.f_parinstalacion_n('EMPRESADEF'),
                                             'USER_BBDD'));
   w_triesgo := f_desriesgo_t(psseguro, pnriesgo, pfriesgo, pcidioma);
   RETURN w_triesgo;
EXCEPTION
   WHEN OTHERS THEN
      RETURN('**');
END f_desriesgo_t_dwh;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_DESRIESGO_T_DWH" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_DESRIESGO_T_DWH" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_DESRIESGO_T_DWH" TO "PROGRAMADORESCSI";
