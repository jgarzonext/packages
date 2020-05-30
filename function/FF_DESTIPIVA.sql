--------------------------------------------------------
--  DDL for Function FF_DESTIPIVA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FF_DESTIPIVA" (pctipiva IN descripcioniva.ttipiva%TYPE, pcidioma in number)
  RETURN VARCHAR2 AUTHID current_user IS
  vtexto  descripcioniva.ttipiva%TYPE;
BEGIN
  vtexto := NULL;

 SELECT ttipiva
   INTO vtexto
 FROM descripcioniva
 WHERE cidioma = pcidioma
   AND ctipiva = pctipiva;

   RETURN vtexto;

EXCEPTION
   WHEN OTHERS THEN
     RETURN '**';
END; 
 
 

/

  GRANT EXECUTE ON "AXIS"."FF_DESTIPIVA" TO "PROGRAMADORESCSI";
  GRANT EXECUTE ON "AXIS"."FF_DESTIPIVA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FF_DESTIPIVA" TO "CONF_DWH";
