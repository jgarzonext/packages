--------------------------------------------------------
--  DDL for Function F_IAX_NOMBREUSUARIO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_IAX_NOMBREUSUARIO" (cusu IN USUARIOS.CUSUARI%TYPE)
                                                             RETURN VARCHAR2 IS
/******************************************************************************
   NOMBRE:       F_IAX_NOMBREUSUARIO
   PROPÓSITO: Recupera el nombre del usuario especificado

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        27/11/2007   ACC                1. Creación de la función.
******************************************************************************/

  vusuario   VARCHAR2(100);

BEGIN

    SELECT TUSUNOM
    INTO vusuario
    FROM USUARIOS
    WHERE UPPER(cusuari) = UPPER(cusu);

    RETURN vusuario;
EXCEPTION
  WHEN OTHERS THEN
    RETURN null;
END F_IAX_NOMBREUSUARIO;



 
 

/

  GRANT EXECUTE ON "AXIS"."F_IAX_NOMBREUSUARIO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_IAX_NOMBREUSUARIO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_IAX_NOMBREUSUARIO" TO "PROGRAMADORESCSI";
