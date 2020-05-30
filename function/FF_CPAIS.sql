--------------------------------------------------------
--  DDL for Function FF_CPAIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FF_CPAIS" (pcprovin IN NUMBER)
RETURN VARCHAR2 AUTHID current_user IS
vcpais  provincias.cpais%TYPE;
BEGIN

BEGIN
 SELECT cpais
 INTO   vcpais
 FROM   Provincias
 WHERE  cprovin = pcprovin;
 RETURN vcpais;
 
EXCEPTION
 WHEN OTHERS THEN
   RETURN null;  -- Error al llegir de EMPRESAS
END;
END; 
 
 

/

  GRANT EXECUTE ON "AXIS"."FF_CPAIS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FF_CPAIS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FF_CPAIS" TO "PROGRAMADORESCSI";
