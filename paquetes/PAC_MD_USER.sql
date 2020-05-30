--------------------------------------------------------
--  DDL for Package PAC_MD_USER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_USER" AS

   /******************************************************************************
      NOMBRE:      PAC_MD_USER
      PROPÓSITO:   Funciones para la gestión de usuarios
      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        24/01/2008   JAS                1. Creación del package.
      1.1        31/01/2008   JTS                2. Se crean las funciones:
                                                           - F_Set_DatUsuario
                                                           - F_CompPas
                                                           - F_SetPass
     10.0        30/03/2009   DCT               10.Modificar f_get_usuario
     11.0        22/11/2010   JAS               11. 13266: Modificación interfases apertura y cierre de puesto (parte PL)
     12.0        22/10/2013   FAC               12. 28627: Agregar al mantenimiento de Usuario la asignación de nivel de psu
     13.0        21/02/2014   FAL               13. 0029965: RSA702 - GAPS renovación
   ******************************************************************************/

   /*************************************************************************
               Comprueba que un usuario este dado de alta en la gestión de usuarios
      param in usuario : código de usuario
      param out prespuesta: : 1 indica que existe
                              0 no existe
      return: 0 ok
              1 ko
   *************************************************************************/

	FUNCTION f_existuser(
			 pusuario	IN	VARCHAR2,
			 prespuesta	OUT	NUMBER,
			 mensajes	IN	OUT T_IAX_MENSAJES
	)   RETURN NUMBER;

	  /*************************************************************************
	Comprueba que un usuario tenga activada la opción de autologin
	param in usuario : código de usuario
	param out prespuesta: : 1 indica que es usuario autologin
	0 no es usuario autologin
	return: 0 ok
	1 ko
	*************************************************************************/
	FUNCTION f_isautologinuser(
			 pusuario	IN	VARCHAR2,
			 prespuesta	OUT	NUMBER,
			 mensajes	IN	OUT T_IAX_MENSAJES
	)   RETURN NUMBER;

	  /*************************************************************************
	Validación de usuario y contraseña
	param in usuario  : usuario que se indica en la pantalla
	param in pwd      : constraseña que se ha indicado
	param out pvalido : 1 indica el usuario es correcto
	0 usuario no valido
	param out mensajes: mensajes de error
	return            : 1 indica error
	0 todo ok
	*************************************************************************/
	FUNCTION f_validateuser(
			 pusuario	IN	VARCHAR2,
			 ppwd	IN	VARCHAR2,
			 pvalido	OUT	NUMBER,
			 pintentos	OUT	NUMBER,
			 mensajes	IN	OUT T_IAX_MENSAJES
	)   RETURN NUMBER;

	  /*************************************************************************
	Carga la información del usuario al objeto
	param in pusuario     : usuario identificado en la aplicación
	param in out mensajes : mensajes de error
	return                : pdatuser -> Datos del usuario
	NULL si error
	*************************************************************************/
	FUNCTION f_get_datuser(
			 pusuario	IN	VARCHAR2,
			 mensajes	IN	OUT T_IAX_MENSAJES
	)   RETURN OB_IAX_USERS;

	  /***********************************************************************
	Cambia los datos de un determinado usuario.
	param in pUser      : id de usuario
	param in ptUsername : nombre del usuario
	param in pcIdioma   : id idioma de trabajo del usuario
	param out mensajes  : mensajes de error
	return              : 1/0 indicando si se ha podido realizar el cambio correctamente
	***********************************************************************/
	FUNCTION f_set_datusuario(
			 puser	IN	VARCHAR2,
			 ptusername	IN	VARCHAR2,
			 pcidioma	IN	NUMBER,
			 mensajes	OUT	T_IAX_MENSAJES
	)   RETURN NUMBER;

	  /*************************************************************************
	Cambia el password del usuario
	param in usuario      : código de usuario
	param in pOldPwd      : password antiguo
	param in pNewPwd      : nuevo password
	param in out mensajes : mensajes de error
	return                : 1 error
	0 ok
	*************************************************************************/
	FUNCTION f_setpass(
			 pusuario	IN	VARCHAR2,
			 poldpwd	IN	VARCHAR2,
			 pnewpwd	IN	VARCHAR2,
			 mensajes	IN	OUT T_IAX_MENSAJES
	)   RETURN NUMBER;

	  /*************************************************************************
	Da de alta el password del usuario
	param in usuario      : código de usuario
	param in pNewPwd      : nuevo password
	param in out mensajes : mensajes de error
	return                : 1 error
	0 ok
	*************************************************************************/
	FUNCTION f_newpass(
			 pusuario	IN	VARCHAR2,
			 pnewpwd	IN	VARCHAR2,
			 mensajes	IN	OUT T_IAX_MENSAJES
	)   RETURN NUMBER;

	  /*************************************************************************
	Crea un usuario nuevo en la gestión de usuarios
	param in usuario : usuario que se ha conectado a la aplicación
	param in nombre : nombre del usuario
	param in delegacion : codigo de delegacion
	param in pctipacc   : código tipo aceso aplicación
	param in pcautlog : indica si autologin
	param in ppassword: password
	return           : 1 se ha creado el usuario
	0 no se ha podido crear el usario
	*************************************************************************/
	FUNCTION f_creauserdefault(
			 pusuario	IN	VARCHAR2,
			 pnombre	IN	VARCHAR2,
			 pdelega	IN	NUMBER,
			 pctipacc	IN	NUMBER,
			 pcautlog	IN	NUMBER,
			 ppassword	IN	VARCHAR2,
			 pcempresa	IN	NUMBER,
			 mensajes	IN	OUT T_IAX_MENSAJES
	)   RETURN NUMBER;

	  /*************************************************************************
	Actualiza el terminal del usuario
	param in usuario      : código de usuario
	param in terminal     : terminal
	param in out mensajes : mensajes de error
	return                : 1 error
	0 ok
	*************************************************************************/
	FUNCTION f_setterminal(
			 pusuario	IN	VARCHAR2,
			 pterminal	IN	VARCHAR2,
			 mensajes	IN	OUT T_IAX_MENSAJES
	)   RETURN NUMBER;

	  /*************************************************************************
	Actualiza el agente del usuario
	param in usuario   : código de usuario
	param in agente    : agente
	param in out mensajes : mensajes de error
	return                : 1 error
	0 ok
	*************************************************************************/
	FUNCTION f_set_agente(
			 pusuario	IN	VARCHAR2,
			 pcagente	IN	NUMBER,
			 mensajes	IN	OUT T_IAX_MENSAJES
	)   RETURN NUMBER;

	  /***********************************************************************
	Crea un usuario
	param in           : Todos los parametros del usuario.
	param out mensajes : mensajes de error
	return             : 1/0 indicando si se ha realizado el insert correctamente
	***********************************************************************/
	FUNCTION f_set_usuario(
			 pcusuari	IN	VARCHAR2,
			 pcidioma	IN	NUMBER,
			 pcempres	IN	NUMBER,
			 ptusunom	IN	VARCHAR2,
			 ptpcpath	IN	VARCHAR2,
			 pcdelega	IN	NUMBER,
			 pcprovin	IN	NUMBER,
			 pcpoblac	IN	NUMBER,
			 pcvistas	IN	NUMBER,
			 pcweb	IN	NUMBER,
			 prepserver	IN	VARCHAR2,
			 pejecucion	IN	NUMBER,
			 psperson	IN	NUMBER,
			 pfbaja	IN	DATE,
			 pctipusu	IN	NUMBER,
			 pcagecob	IN	NUMBER,
			 pcopcion	IN	NUMBER,
			 ptpwd	IN	VARCHAR2,
			 pfalta	IN	DATE,
			 pcusubbdd	IN	VARCHAR2,
			 pcautlog	IN	NUMBER,
			 pcempleado	IN	VARCHAR2,
			 pcterminal	IN	VARCHAR2,
			 pcvispubli	IN	NUMBER,
			 pmail_usu	IN	VARCHAR2, -- BUG 29965 - FAL - 07/02/2014
			 ptelfusu	IN	VARCHAR2,
			 punidept	IN	NUMBER,
			 pcategprof	IN	NUMBER,
			 mensajes	IN	OUT T_IAX_MENSAJES
	)
	  RETURN NUMBER;

	  /***********************************************************************
	Borra un usuario
	param in pcusuari : Codigo del usuario.
	param out mensajes : mensajes de error
	return             : 1/0 indicando si se ha realizado el insert correctamente
	***********************************************************************/
	FUNCTION f_del_usuario(
			 pcusuari	IN	VARCHAR2,
			 mensajes	IN	OUT T_IAX_MENSAJES
	)   RETURN NUMBER;

	  /***********************************************************************
	Recupera un usuario
	param in pcusuari : Codigo del usuario.
	param out pusuario : Datos del Usuario
	param out mensajes : mensajes de error
	return             : 1/0 indicando si se ha realizado el insert correctamente
	***********************************************************************/
	FUNCTION f_get_usuario(
			 pcusuari	IN	VARCHAR2,
			 pusuario	IN	OUT OB_IAX_USUARIOS,
			 mensajes	IN	OUT T_IAX_MENSAJES
	)   RETURN NUMBER;

	  /*************************************************************************
	Devuelve los usuarios que cumplan con el criterio de selección
	param in pcempres   : código de la empresa
	param in pcusuari   : código del usuario
	param in ptusername : Nombre del usuario
	param in pcdelega : codigo de la delegacion
	param out mensajes    : mensajes de error
	return                : ref cursor
	*************************************************************************/
	FUNCTION f_consulta_usuario(
			 pcempres NUMBER,
			 puser VARCHAR2,
			 ptusername VARCHAR2,
			 pcdelega NUMBER,
			 mensajes	IN	OUT T_IAX_MENSAJES
	)   RETURN SYS_REFCURSOR;

	  /*************************************************************************
	Comprueba el password del usuario
	param in usuario      : código de usuario
	param in pOldPwd      : password antiguo
	param in pNewPwd      : nuevo password
	param in out mensajes : mensajes de error
	return                : 1 error
	0 ok
	*************************************************************************/
	FUNCTION f_validate_pwd(
			 pusuario	IN	VARCHAR2,
			 poldpwd	IN	VARCHAR2,
			 pnewpwd	IN	VARCHAR2,
			 pmodo	IN	VARCHAR2,
			 mensajes	IN	OUT T_IAX_MENSAJES
	)   RETURN NUMBER;

	  /******************************************************************************************
	Autor: XVILA (05/12/2008)
	Descripció: Funció que activa un usuari donat de baixa.
	Paràmetres entrada: - pcusuari -> id. usuari
	Paràmetres sortida: - mensajes -> Missatges d'error
	return:             retorna 0 si va tot bé, sino el codi de l'error
	******************************************************************************************/
	FUNCTION f_activar_usuario(
			 pcusuari	IN	VARCHAR2,
			 mensajes	IN	OUT T_IAX_MENSAJES
	)   RETURN NUMBER;

	  /*************************************************************************
	BUG 13266
	Actualiza el terminal fisico del usuario
	param in usuario    : código de usuario
	param in ctermfisic : t. fisic
	param in out mensajes : mensajes de error
	return                : 1 error
	0 ok
	*************************************************************************/
	FUNCTION f_set_termfisic(
			 pusuario	IN	VARCHAR2,
			 pctermfisic	IN	VARCHAR2,
			 mensajes	IN	OUT T_IAX_MENSAJES
	)   RETURN NUMBER;

	  /*************************************************************************
	BUG 13266
	Obté el terminal fisico del usuario
	param in usuario    : código de usuario
	param out ctermfisic : t. fisic
	param in out mensajes : mensajes de error
	return                : 1 error
	0 ok
	*************************************************************************/
	FUNCTION f_get_termfisic(
			 pusuario	IN	VARCHAR2,
			 pctermfisic	OUT	VARCHAR2,
			 mensajes	IN	OUT T_IAX_MENSAJES
	)   RETURN NUMBER;

	  /***********************************************************************
	Recupera una colecc??e usuarios seg? visi??el usuario conectado
	param in pcusuari : Codigo del usuario.
	param in pnomusuario : Nombre del usuario.
	param out pusuario : Datos del Usuario
	param out mensajes : mensajes de error
	return             : 1/0 indicando si se ha realizado el insert correctamente
	***********************************************************************/
	FUNCTION f_get_usuario_vision(
			 pcusuari	IN	VARCHAR2,
			 pnomusuario	IN	VARCHAR2,
			 ptusuario	OUT	T_IAX_USERS,
			 mensajes	IN	OUT T_IAX_MENSAJES
	)   RETURN NUMBER;

	FUNCTION f_val_cambio_paswd(
			 puser	IN	VARCHAR2,
			 mensajes	IN	OUT T_IAX_MENSAJES
	)   RETURN NUMBER;

	FUNCTION f_useractivo(
			 pusuario	IN	VARCHAR2,
			 pactivo	OUT	NUMBER,
			 mensajes	IN	OUT T_IAX_MENSAJES
	)   RETURN NUMBER;

	FUNCTION f_get_usuarios(
			 puser	IN	usuarios.cusuari%TYPE,
			 pusername	IN	usuarios.tusunom%TYPE,
			 tusers	OUT	T_IAX_USERS,
			 mensajes	OUT	T_IAX_MENSAJES
	)   RETURN NUMBER;

END pac_md_user;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_USER" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_USER" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_USER" TO "PROGRAMADORESCSI";
