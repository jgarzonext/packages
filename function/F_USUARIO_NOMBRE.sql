--------------------------------------------------------
--  DDL for Function F_USUARIO_NOMBRE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_USUARIO_NOMBRE" 
RETURN varchar IS
/****************************************************************************
    F_USUARIO_NOMBRE: DEVUELVE EL NOMBRE DEL USUARIO CON FORMATO APE1 + APE2, NOMBRE
    DATOS DE ENTRADA: CODIGO DE USUARIO.
    DATOS DE SALIDA:  NOMBRE
    24-11-2003  AMG
    JFD 19-09-2007 cambiamos la función devuelve el nombre
****************************************************************************/
  vtusuario   varchar2(100);  

BEGIN


       select tusunom
         into vtusuario
         from usuarios
        where cusuari = UPPER(f_user);

   RETURN vtusuario;
EXCEPTION
  WHEN OTHERS THEN
    RETURN null;
END; 
 
 

/

  GRANT EXECUTE ON "AXIS"."F_USUARIO_NOMBRE" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_USUARIO_NOMBRE" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_USUARIO_NOMBRE" TO "PROGRAMADORESCSI";
