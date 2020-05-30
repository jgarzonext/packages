--------------------------------------------------------
--  DDL for Package PAC_MD_LOGIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_LOGIN" AS
/******************************************************************************
   NOMBRE:       PAC_MD_LOGIN
   PROPÓSITO:  Funciones para realizar una conexión
               a base de datos de la capa M

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
      remoteip IN VARCHAR2,
      valpaswd IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   --BUG21762 - JTS - 20/03/2012
   FUNCTION f_logea(puser IN usuarios.cusuari%TYPE, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_deslogea(puser IN usuarios.cusuari%TYPE, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;
--FiBUG21762
END pac_md_login;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_LOGIN" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_LOGIN" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_LOGIN" TO "PROGRAMADORESCSI";
