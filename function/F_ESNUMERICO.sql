--------------------------------------------------------
--  DDL for Function F_ESNUMERICO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_ESNUMERICO" (
   pvalor IN varchar2
)
RETURN NUMBER AUTHID CURRENT_USER
IS
/***********************************************************************
 Pasando un valor varchar comprobar si es un numero o tiene letras
***********************************************************************/
 nvalor number;
BEGIN
   BEGIN
      SELECT to_number(pvalor)
      into   nvalor
      from   dual;
      return(0);
   EXCEPTION
      WHEN OTHERS
      THEN
         return(-1);
   END;
END f_esnumerico;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_ESNUMERICO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_ESNUMERICO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_ESNUMERICO" TO "PROGRAMADORESCSI";
