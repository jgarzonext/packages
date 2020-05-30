--------------------------------------------------------
--  DDL for Function FF_CRETENC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FF_CRETENC" (pcretenc IN descripcionret.cretenc%TYPE, pcidioma in number)
RETURN VARCHAR2 AUTHID current_user IS
  vtexto  descripcionret.ttipret%TYPE;
BEGIN
  vtexto := NULL;
 SELECT ttipret
   INTO vtexto
 FROM descripcionret
 WHERE cidioma = pcidioma
   AND cretenc = pcretenc;


   RETURN vtexto;

EXCEPTION
   WHEN OTHERS THEN
     RETURN '**';
END; 
 
 

/

  GRANT EXECUTE ON "AXIS"."FF_CRETENC" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FF_CRETENC" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FF_CRETENC" TO "PROGRAMADORESCSI";
