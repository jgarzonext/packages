--------------------------------------------------------
--  DDL for Function FF_DESVINCULOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FF_DESVINCULOS" (pcvinclo IN NUMBER, pcidioma IN NUMBER)
RETURN VARCHAR2 AUTHID current_user IS
   vtexto  vinculos.tvinclo%TYPE;
BEGIN
vtexto := NULL;
BEGIN
 SELECT tvinclo
 INTO   vtexto
 FROM   vinculos
 WHERE  cvinclo = pcvinclo
    AND cidioma = pcidioma;
 
 RETURN vtexto;
 
EXCEPTION
 WHEN OTHERS THEN
   RETURN '**';  -- Error al llegir de vinculos
END;
RETURN 0;
END; 
 
 

/

  GRANT EXECUTE ON "AXIS"."FF_DESVINCULOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FF_DESVINCULOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FF_DESVINCULOS" TO "PROGRAMADORESCSI";
