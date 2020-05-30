--------------------------------------------------------
--  DDL for Function F_DIN_AUTORIZA_RIESGO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_DIN_AUTORIZA_RIESGO" (psseguro IN NUMBER, puser IN VARCHAR2, pmodo IN NUMBER)
RETURN NUMBER authid current_user IS
lsentencia varchar2(1000);
num_err NUMBER := 0;
BEGIN
   lsentencia :='begin  :num_err := f_autoriza_riesgo(psseguro ,puser, pmodo); end;';
   EXECUTE IMMEDIATE lsentencia USING  OUT num_err,  IN psseguro, IN puser, IN pmodo;
   RETURN num_err;
END;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_DIN_AUTORIZA_RIESGO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_DIN_AUTORIZA_RIESGO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_DIN_AUTORIZA_RIESGO" TO "PROGRAMADORESCSI";
