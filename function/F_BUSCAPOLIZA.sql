--------------------------------------------------------
--  DDL for Function F_BUSCAPOLIZA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_BUSCAPOLIZA" (psseguro IN NUMBER, pnpoliza  OUT NUMBER, pncertif OUT NUMBER)
  RETURN NUMBER authid current_user IS
/************************************************************************************
    10/07/2007: APD
    F_BuscaPoliza: Función que dado un sseguro, devuelve el npoliza y ncertif de la póliza
*************************************************************************************/
  nsseguro   NUMBER;
BEGIN

  Select npoliza, ncertif
  Into pnpoliza, pncertif
  From Seguros
  Where sseguro = psseguro;

  RETURN 0;

EXCEPTION
  WHEN OTHERS THEN
       RETURN 140897;  -- Error al buscar la poliza
END F_BuscaPoliza;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_BUSCAPOLIZA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_BUSCAPOLIZA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_BUSCAPOLIZA" TO "PROGRAMADORESCSI";
