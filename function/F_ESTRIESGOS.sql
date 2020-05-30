--------------------------------------------------------
--  DDL for Function F_ESTRIESGOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_ESTRIESGOS" (
   psseguro     IN       NUMBER,
   pnriesgo     IN       NUMBER,
   pasegurado   IN OUT   VARCHAR2
)
   RETURN NUMBER AUTHID CURRENT_USER
IS
/**********************************************************************
F_ASEGURADO: Retorna el nombre del asegurado de la tabla RIESGOS
ALLIBCTR - Gestión de datos referentes a los seguros
Es la misma función que antes se llamaba
F_ASEGURADO.
***********************************************************************/

BEGIN

    SELECT  f_nombre_est ( r.sperson , 1, r.sseguro)
       INTO pasegurado
     FROM estriesgos r
     where r.sseguro = psseguro
       and r.nriesgo = pnriesgo;

    RETURN 0;

EXCEPTION                              -- L'assegurat no existeix
   WHEN OTHERS
   THEN
      RETURN 100523;                               -- L'assegurat no existeix
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_ESTRIESGOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_ESTRIESGOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_ESTRIESGOS" TO "PROGRAMADORESCSI";
