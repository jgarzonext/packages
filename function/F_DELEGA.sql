--------------------------------------------------------
--  DDL for Function F_DELEGA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_DELEGA" (psseguro IN NUMBER,pfecha IN DATE)
RETURN NUMBER authid current_user IS
/**********************************************************
        F_DELEGA Retorna la delegació d'una pòlissa
                 en una data determinada
***********************************************************/

l_delegacio NUMBER;

BEGIN
   BEGIN
      SELECT c01 INTO l_delegacio
      FROM seguredcom
      WHERE sseguro = psseguro
        AND fmovini <= pfecha
        ANd (fmovfin > pfecha OR fmovfin IS NULL);

   EXCEPTION
      WHEN OTHERS THEN
         l_delegacio := null;
   END;
RETURN l_delegacio;
END f_delega;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_DELEGA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_DELEGA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_DELEGA" TO "PROGRAMADORESCSI";
