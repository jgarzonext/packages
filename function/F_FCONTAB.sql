--------------------------------------------------------
--  DDL for Function F_FCONTAB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_FCONTAB" (cempresa IN NUMBER, fcontable IN OUT DATE)
RETURN NUMBER authid current_user IS
BEGIN
BEGIN
SELECT fmescon
INTO fcontable
FROM EMPRESAS
WHERE cempres = cempresa;
RETURN 0;
EXCEPTION
WHEN others THEN
fcontable := NULL;
RETURN 100853;                   -- Codi d'empresa inexistent
END;
END;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_FCONTAB" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_FCONTAB" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_FCONTAB" TO "PROGRAMADORESCSI";
