--------------------------------------------------------
--  DDL for Package PAC_LOGIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_LOGIN" AS
/******************************************************************************
   NOMBRE:       PAC_LOGIN
   PROPÓSITO:  Funciones para realizar una conexión
               a base de datos de la capa de negocio

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        4/12/2008   PCT               1. Creación del package.
******************************************************************************/

   /*************************************************************************
      Función que insertará en la tabla log_conexión.
   *************************************************************************/
   FUNCTION f_set_log_conexion(
      pcusuari IN usuarios.cusuari%TYPE,
      psession IN log_conexion.session_id%TYPE,
      remoteip IN VARCHAR2,
      pfconexion IN log_conexion.fconexion%TYPE,
      pcoficina IN log_conexion.coficina%TYPE,
      pmsg IN log_conexion.msg%TYPE,
      pvalpaswd IN NUMBER)
      RETURN NUMBER;
END pac_login;

/

  GRANT EXECUTE ON "AXIS"."PAC_LOGIN" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_LOGIN" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_LOGIN" TO "PROGRAMADORESCSI";
