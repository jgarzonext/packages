--------------------------------------------------------
--  DDL for Function FF_BUSCASSEGURO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FF_BUSCASSEGURO" (pnpoliza  IN NUMBER, pncertif IN NUMBER DEFAULT 0)
  RETURN NUMBER authid current_user IS
/************************************************************************************
    05/03/2007: APD
	Ff_BUSCASSEGURO: Función que dada una póliza, devuelve el sseguro de la póliza
*************************************************************************************/
  nsseguro   NUMBER;
BEGIN

  Select sseguro
  Into nsseguro
  From Seguros
  Where npoliza = pnpoliza
    And ncertif = pncertif;

  RETURN (nsseguro);

EXCEPTION
  WHEN OTHERS THEN
       p_tab_error(f_sysdate, user, 'Ff_BUSCASSEGURO', null, 101903, f_literal(101903,2));
       RETURN (null);
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."FF_BUSCASSEGURO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FF_BUSCASSEGURO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FF_BUSCASSEGURO" TO "PROGRAMADORESCSI";
