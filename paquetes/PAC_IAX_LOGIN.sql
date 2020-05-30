--------------------------------------------------------
--  DDL for Package PAC_IAX_LOGIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_LOGIN" AS
/******************************************************************************
   NOMBRE:       PAC_IAX_LOGIN
   PROPÓSITO:  Funciones para validar el usuario

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        20/11/2007   ACC                1. Creación del package.
******************************************************************************/

   /*************************************************************************
      Comprueba si la aplicación se permite el autologin de usuarios
      return           : 1 indica que se permite autologin
                         0 no esta permitido
   *************************************************************************/
   FUNCTION f_empresa_autologin
      RETURN NUMBER;

   /*************************************************************************
      Cuando JAVA establezca una conexión, debe llamar a esta función para
      establecer las variables de contexto
      param in usuario  : usuario que se ha conectado a la aplicación.
                          A partir de este usuario se obtendrán los valores
                          para el resto de variables de contexto que se deben
                          inicializar (empresa, idioma, agente)
   *************************************************************************/
   PROCEDURE p_iax_iniconnect(pusuario IN VARCHAR2);

   /*************************************************************************
    Función creada paraunificar las funciones f_iax_autologin y f_iax_login
    param in usuario: usuario que se conecta a la aplicación
    param in password: password del usuario
    param in tipcon: tipo de conexion
    param in oficina: oficina des de donde se conecta
    param in puesto: puesto des de deonde se conecta
    param out mensajes: mensajes de error
    *************************************************************************/
   FUNCTION f_iax_login(
      pusuario IN VARCHAR2,
      ppwd IN VARCHAR2,
      remoteip IN VARCHAR2,
      ptipcon IN VARCHAR2,
      poficina IN NUMBER,
      pterminal IN VARCHAR2,
      pempresa IN NUMBER,
      pdatuser OUT ob_iax_users,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   --BUG21762 - JTS - 24/05/2012
   FUNCTION f_limite_sesiones(mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   --BUG21762 - JTS - 20/03/2012
   FUNCTION f_logea(puser IN usuarios.cusuari%TYPE, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_deslogea(puser IN usuarios.cusuari%TYPE, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
--Fi BUG21762
END pac_iax_login;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_LOGIN" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_LOGIN" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_LOGIN" TO "PROGRAMADORESCSI";
