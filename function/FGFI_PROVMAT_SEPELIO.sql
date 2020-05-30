--------------------------------------------------------
--  DDL for Function FGFI_PROVMAT_SEPELIO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FGFI_PROVMAT_SEPELIO" (sesion IN NUMBER) RETURN NUMBER IS
 
CAPITAL NUMBER;
CGARANT NUMBER;
FECEFE NUMBER;
FEFEPOL NUMBER;
GARANTIA NUMBER;
NRIESGO NUMBER;
PBENEF NUMBER;
PINTTEC NUMBER;
RETENI NUMBER;
SEXO NUMBER;
SSEGURO NUMBER;
ANYO NUMBER;
NDIAS_PROV NUMBER;
T_DIAS_ANYO NUMBER;
PROVMAT_SEPELIO NUMBER;
RETORNO NUMBER;

BEGIN

 
CAPITAL:= pac_GFI.f_sgt_parms ('CAPITAL', sesion);
CGARANT:= pac_GFI.f_sgt_parms ('CGARANT', sesion);
FECEFE:= pac_GFI.f_sgt_parms ('FECEFE', sesion);
FEFEPOL:= pac_GFI.f_sgt_parms ('FEFEPOL', sesion);
GARANTIA:= pac_GFI.f_sgt_parms ('GARANTIA', sesion);
NRIESGO:= pac_GFI.f_sgt_parms ('NRIESGO', sesion);
PBENEF:= pac_GFI.f_sgt_parms ('PBENEF', sesion);
PINTTEC:= pac_GFI.f_sgt_parms ('PINTTEC', sesion);
RETENI:= pac_GFI.f_sgt_parms ('RETENI', sesion);
SEXO:= pac_GFI.f_sgt_parms ('SEXO', sesion);
SSEGURO:= pac_GFI.f_sgt_parms ('SSEGURO', sesion);
SELECT TRUNC(MONTHS_BETWEEN(TO_DATE(FECEFE,'YYYYMMDD'),TO_DATE(FEFEPOL,'YYYYMMDD'))/12) + 1 INTO ANYO FROM DUAL;
Pac_Gfi.p_grabar_rastro (sesion, 'ANYO', ANYO, 0);
SELECT NVL(TO_DATE(FECEFE,'YYYYMMDD') - TO_DATE(FFPROV_T0(sesion, SSEGURO, NRIESGO, CGARANT,ANYO),'YYYYMMDD'),0) INTO NDIAS_PROV FROM DUAL;
Pac_Gfi.p_grabar_rastro (sesion, 'NDIAS_PROV', NDIAS_PROV, 0);
T_DIAS_ANYO :=        365.25;
Pac_Gfi.p_grabar_rastro (sesion, 'T_DIAS_ANYO', T_DIAS_ANYO, 0);
SELECT DECODE(RETENI,0,(FIPROV_T0(sesion, SSEGURO, NRIESGO, GARANTIA,ANYO)*(1-(NDIAS_PROV/T_DIAS_ANYO))+((NDIAS_PROV/T_DIAS_ANYO)*FIPROV_T1(sesion, SSEGURO, NRIESGO, GARANTIA,ANYO))),
FULTPROVCALC(sesion, SSEGURO, NRIESGO, GARANTIA, FECEFE, 1)) INTO PROVMAT_SEPELIO FROM DUAL;
Pac_Gfi.p_grabar_rastro (sesion, 'PROVMAT_SEPELIO', PROVMAT_SEPELIO, 0);
Retorno := PROVMAT_SEPELIO;
RETURN Retorno;

END;
 
 

/

  GRANT EXECUTE ON "AXIS"."FGFI_PROVMAT_SEPELIO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FGFI_PROVMAT_SEPELIO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FGFI_PROVMAT_SEPELIO" TO "PROGRAMADORESCSI";