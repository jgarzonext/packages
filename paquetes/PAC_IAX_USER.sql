--------------------------------------------------------
--  DDL for Package PAC_IAX_USER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_USER" AS

   /******************************************************************************
      NOMBRE:      PAC_IAX_USER
      PROP¿¿SITO:   Funciones para la gesti¿¿n de usuarios de la aplicaci¿¿n.
      REVISIONES:
      Ver        Fecha        Autor             Descripci¿¿n
      ---------  ----------  ---------------  ------------------------------------
      1.0        23/01/2008   JAS               1. Creaci¿¿n del package.
      1.1        31/01/2008   JTS               2. Se implementan las funciones:
                                                           - F_Get_User
                                                           - F_Set_DatUsuario
                                                           - F_Set_Password
      2.0
      3.0
      4.0
      5.0        13/03/2009   DCT               5. Modificaci¿¿n F_SET_USUARIO.
      6.0        26/10/2010   DRA               6. 16471: CRT - Configuracion de visibilidad/contratacion de productos a nivel de perfil
      7.0        22/11/2010   JAS               7. 13266: Modificaci¿¿n interfases apertura y cierre de puesto (parte PL) Diverses modificacions al codi
      8.0        07/03/2012   JMP               8. 21569: CRE998 - Configurar llen¿¿ador d'Informes per perfil
      9.0        22/10/2013   FAC               9. 28627: Agregar al mantenimiento de Usuario la asignaci¿n de nivel de psu
     10.0        21/02/2014   FAL              10. 0029965: RSA702 - GAPS renovaci¿n
     11.0        03/08/2019   JMJRR            11. IAXIS-4994 Se modifican parametros de entrada para agregar informacion a los usuarios
   ******************************************************************************/

   /***********************************************************************
         Recupera el usuario conectado a la aplicaci¿¿n.
      param out mensajes : mensajes de error
      return             : VARCAHR2
   ***********************************************************************/

	FUNCTION f_get_user(
			 mensajes	OUT	T_IAX_MENSAJES
	)   RETURN VARCHAR2;

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
	Carga la informaci¿¿n del usuario al objeto
	param in pUser       : usuario identificado en la aplicaci¿¿n
	param out mensajes   : mensajes de error
	return               : pdatuser -> Datos del usuario
	NULL si error
	*************************************************************************/
	FUNCTION f_get_datusuario(
			 puser	IN	VARCHAR2,
			 mensajes	OUT	T_IAX_MENSAJES
	)   RETURN OB_IAX_USERS;

	  /***********************************************************************
	Realiza el cambio de password de un determinado usuario
	param in  pUser    : Usuario sobre el que aplicar el cambio de password.
	param in  pOldPwd  : Password antiguo del usuario.
	param in  pNewPwd  : Nuevo password del usuario.
	param out mensajes : mensajes de error
	return             : 1/0 indicando si se ha podido realizar el cambio correctamente
	***********************************************************************/
	FUNCTION f_set_password(
			 puser	IN	VARCHAR2,
			 poldpwd	IN	VARCHAR2,
			 pnewpwd	IN	VARCHAR2,
			 mensajes	OUT	T_IAX_MENSAJES
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
			 pcdelega	IN	NUMBER,
			 poldpwd	IN	VARCHAR2,
			 pnewpwd	IN	VARCHAR2,
			 pnewpwdcnf	IN	VARCHAR2,
			 pcempleado	IN	VARCHAR2,
			 pcwizard	IN	VARCHAR2,
			 pcform	IN	VARCHAR2,
			 pcaccion	IN	VARCHAR2,
			 pcmenu	IN	VARCHAR2,
			 pcconsupl	IN	VARCHAR2,
			 pcdocumentacio	IN	VARCHAR2, --BUG8898-23032009-XVM
			 pcautlog	IN	NUMBER,
			 pcaccprod	IN	VARCHAR2, -- BUG16471:DRA:26/10/2010
			 pccfgmap	IN	VARCHAR2, -- BUG 21569 - 07/03/2012 - JMP
			 pcvispubli	IN	NUMBER,
			 pcrol	IN	VARCHAR2,
			 pcusuagru	IN	NUMBER,
			 pmail_usu	IN	VARCHAR2, -- BUG 29965 - FAL - 07/02/2014
			 ptelfusu	IN	VARCHAR2,
			 punidept	IN	NUMBER,
			 pcategprof	IN	NUMBER,
             psperson IN NUMBER,
             pareas   IN VARCHAR2,--IAXIS-4994
			 mensajes	OUT	T_IAX_MENSAJES
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
			 mensajes	OUT	T_IAX_MENSAJES
	)   RETURN NUMBER;

	  /*************************************************************************
	Carga la informaci¿¿n del usuario al objeto
	param in pUser      : usuario identificado en la aplicaci¿¿n
	param out pUsuario  : objeto de USUARIOS
	param out mensajes  : mensajes de error
	return              : 1/0 indicando si se ha realizado correctamente
	*************************************************************************/
	FUNCTION f_get_usuario(
			 puser	IN	VARCHAR2,
			 pusuario	OUT	OB_IAX_USUARIOS,
			 mensajes	OUT	T_IAX_MENSAJES
	)   RETURN NUMBER;

	  /*************************************************************************
	Devuelve los terminales que cumplan con el criterio de selecci¿¿n
	param in pcempres   : c¿¿digo de la empresa
	param in pcmaqfisi  : M¿¿quina f¿¿sica
	param in pcterminal : Terminal Axis
	param out mensajes    : mensajes de error
	return                : ref cursor
	*************************************************************************/
	FUNCTION f_consulta_usuarios(
			 pcempres	IN	NUMBER,
			 puser	IN	VARCHAR2,
			 ptusername	IN	VARCHAR2,
			 pcdelega	IN	NUMBER,
			 mensajes	OUT	T_IAX_MENSAJES
	)   RETURN SYS_REFCURSOR;

	  /******************************************************************************************
	Autor: XVILA (05/12/2008)
	Descripci¿¿: Funci¿¿ que activa un usuari donat de baixa.
	Par¿¿metres entrada: - pcusuari -> id. usuari
	Par¿¿metres sortida: - mensajes -> Missatges d'error
	return:             retorna 0 si va tot b¿¿, sino el codi de l'error
	******************************************************************************************/
	FUNCTION f_activar_usuario(
			 pcusuari	IN	VARCHAR2,
			 mensajes	OUT	T_IAX_MENSAJES
	)   RETURN NUMBER;

	  /*************************************************************************
	BUG 13266
	Actualiza el terminal fisico del usuario
	param in usuario    : c¿¿digo de usuario
	param in ctermfisic : t. fisic
	param in out mensajes : mensajes de error
	return                : 1 error
	0 ok
	*************************************************************************/
	FUNCTION f_set_termfisic(
			 pusuario	IN	VARCHAR2,
			 pctermfisic	IN	VARCHAR2,
			 mensajes	OUT	T_IAX_MENSAJES
	)   RETURN NUMBER;

	  /*************************************************************************
	BUG 13266
	Obt¿¿ el terminal fisico del usuario
	param in usuario    : c¿¿digo de usuario
	param out ctermfisic : t. fisic
	param in out mensajes : mensajes de error
	return                : 1 error
	0 ok
	*************************************************************************/
	FUNCTION f_get_termfisic(
			 pusuario	IN	VARCHAR2,
			 pctermfisic	OUT	VARCHAR2,
			 mensajes	OUT	T_IAX_MENSAJES
	)   RETURN NUMBER;

	  /***********************************************************************
	Recupera una colecc¿¿n de usuarios seg¿¿n la visi¿¿n del usuario conectado
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
			 mensajes	OUT	T_IAX_MENSAJES
	)   RETURN NUMBER;

	FUNCTION f_val_cambio_paswd(
			 puser	IN	VARCHAR2,
			 mensajes	OUT	T_IAX_MENSAJES
	)   RETURN NUMBER;

	FUNCTION f_get_usuarios(
			 puser	IN	usuarios.cusuari%TYPE,
			 pusername	IN	usuarios.tusunom%TYPE,
			 tusers	OUT	T_IAX_USERS,
			 mensajes	OUT	T_IAX_MENSAJES
	)   RETURN NUMBER;

END pac_iax_user;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_USER" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_USER" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_USER" TO "PROGRAMADORESCSI";
