CREATE OR REPLACE PACKAGE pac_user AS


   /******************************************************************************
      NOMBRE:      PAC_USER
      PROPÓSITO:   Funciones para la gestión de usuarios
      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        11/02/2008   JAS                1. Creación del package.
      8.0        30/03/2009   DCT                8. Modificación f_get_usuario
     10.0        23/10/2009   JTS               10. 11404: CEM003 - Plantillas del producto
     11.0        26/10/2010   DRA               11. 16471: CRT - Configuracion de visibilidad/contratacion de productos a nivel de perfil
     12.0        22/11/2010  JAS                12. 13266: CIVF001 - Modificación interfases apertura y cierre de puesto (parte PL)
     13.0        07/03/2012   JMP               13. 21569: CRE998 - Configurar llençador d'Informes per perfil
     14.0        22/10/2013   FAC               14. 28627: Agregar al mantenimiento de Usuario la asignación de nivel de psu
     15.0        21/02/2014   FAL               15. 0029965: RSA702 - GAPS renovación
     16.0        03/08/2019   JMJRR             16. IAXIS-4994 se modifican parametros de entrada y se ajusta proceso de persistencia y consulta de usuarios
   ******************************************************************************/

   /*************************************************************************
         Modifica la clave de acceso de un determinado usuario.
      param in pUser   : código de usuario
      param in pNewPwd : nueva clave de acceso
      return           : 0 indica cambio realizado correctamente
                         <> 0 indica error
   *************************************************************************/

	FUNCTION f_update_userpwd(
			 puser	IN	VARCHAR2,
			 pnewpwd	IN	VARCHAR2
	)   RETURN NUMBER;

	  /*************************************************************************
	Inserta en el histórico de usuario.
	param in pUser   : código de usuario
	param in pNewPwd : clave de acceso
	return           : 0 indica cambio realizado correctamente
	<> 0 indica error
	*************************************************************************/
	FUNCTION f_insert_usuario_his(
			 puser	IN	VARCHAR2,
			 pnewpwd	IN	VARCHAR2
	)   RETURN NUMBER;

	  /*************************************************************************
	Obté el password de l'usuari
	param in pUser   : código de usuario
	param in pPwd : clave de acceso
	return           : 0 indica cambio realizado correctamente
	<> 0 indica error
	*************************************************************************/
	FUNCTION f_get_password(
			 puser	IN	VARCHAR2,
			 ppwd	OUT	VARCHAR2
	)   RETURN NUMBER;

	  /*************************************************************************
	Obtiene el empleado de un usuario
	param in pUser   : código de usuario
	return           : 1 indica que existe
	0 no existe
	*************************************************************************/
	FUNCTION f_get_empleado(
			 puser	IN	usuarios.cusuari%TYPE,
			 pcempleado	OUT	usuarios.cempleado%TYPE
	)   RETURN NUMBER;

	  /***********************************************************************
	Recupera un empleado
	param in pcusuari : Codigo del usuario.
	return            : empleado
	***********************************************************************/
	FUNCTION ff_get_empleado(
			 pcusuari	IN	VARCHAR2
	)   RETURN NUMBER;

	  /*************************************************************************
	Obtiene el terminal de un usuario
	param in pUser   : código de usuario
	return           : 1 indica que existe
	0 no existe
	*************************************************************************/
	FUNCTION f_get_terminal(
			 puser	IN	usuarios.cusuari%TYPE,
			 pcterminal	OUT	usuarios.cterminal%TYPE
	)   RETURN NUMBER;

	  /***********************************************************************
	Recupera un terminal
	param in pcusuari : Codigo del usuario.
	return            : terminal
	***********************************************************************/
	FUNCTION ff_get_terminal(
			 pcusuari	IN	VARCHAR2
	)   RETURN NUMBER;

	  /*************************************************************************
	Inserta el terminal a l'usuari
	param in pUser   : código de usuario
	param in pterminal : terminal
	return           : 0 indica cambio realizado correctamente
	<> 0 indica error
	*************************************************************************/
	FUNCTION f_set_terminal(
			 puser	IN	VARCHAR2,
			 pterminal	IN	VARCHAR2
	)   RETURN NUMBER;

	  /*************************************************************************
	Inserta l'agent de l'usuari
	param in pUser   : código de usuario
	param in pcagente : agent
	return           : 0 indica cambio realizado correctamente
	<> 0 indica error
	*************************************************************************/
	FUNCTION f_set_agente(
			 puser	IN	VARCHAR2,
			 pcagente	IN	NUMBER
	)   RETURN NUMBER;

  -- INI IAXIS-3288 - JLTS - Se crea esta función para obtener el nombre del usuario
  /*************************************************************************
   Devuelve el nombre del usuario
   param in cusuari : código de usuario
   return: nombre del usuario
  *************************************************************************/
  FUNCTION f_nomuser(
      pcusuari  IN  USUARIOS.CUSUARI%TYPE
  ) RETURN VARCHAR2;
	
	-- FIN IAXIS-3288 - JLTS - Se crea esta función para obtener el nombre del usuario

	  /*************************************************************************
	Comprueba que un usuario este dado de alta en la gestión de usuarios
	param in usuario : código de usuario
	param out pexiste: 1 indica que existe
	0 no existe
	return: 0 - ok
	<> 0 - devuelve codigo del error
	*************************************************************************/
	FUNCTION f_existuser(
			 pusuario	IN	VARCHAR2,
			 pexiste	OUT	NUMBER
	)   RETURN NUMBER;

	  /*************************************************************************
	Comprueba que un usuario tenga activada la opción de autologin
	param in usuario : código de usuario
	param out pvcautlog : 1 indica que es usuario autologin
	0 no es usuario autologin
	*************************************************************************/
	FUNCTION f_isautologinuser(
			 pusuario	IN	VARCHAR2,
			 pvcautlog	OUT	NUMBER
	)   RETURN NUMBER;

	  /*************************************************************************
	Validación de usuario y contraseña
	param in usuario  : usuario que se indica en la pantalla
	param in pwd      : constraseña que se ha indicado
	param out pvalidation : 0 indica el usuario es correcto
	1 usuario no valido
	*************************************************************************/
	FUNCTION f_validateuser(
			 pusuario	IN	VARCHAR2,
			 ppwd	IN	VARCHAR2,
			 pvalidation	OUT	NUMBER,
			 pintentos	OUT	NUMBER
	)   RETURN NUMBER;

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
			 pcidioma	IN	NUMBER
	)   RETURN NUMBER;

	  /*************************************************************************
	Crea un usuario nuevo en la gestión de usuarios
	param in usuario : usuario que se ha conectado a la aplicación
	param in nombre : nombre del usuario
	param in agente : codigo de agente
	param in delegacion : codigo de delegacion
	param in idioma : codigo de idioma
	param in empresa : codigo de la empresa
	param in pcautlog : indica si autologin
	return           : 1 se ha creado el usuario
	0 no se ha podido crear el usario
	*************************************************************************/
	FUNCTION f_creauserdefault(
			 pusuario	IN	VARCHAR2,
			 pnombre	IN	VARCHAR2,
			 pdelega	IN	NUMBER,
			 pcidioma	IN	NUMBER,
			 pcempresa	IN	NUMBER,
			 pcautlog	IN	NUMBER
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
			 pcategprof	IN	NUMBER
	)
	  RETURN NUMBER;

	  /***********************************************************************
	Borra un usuario
	param in pcusuari : Codigo del usuario.
	return             : 1/0 indicando si se ha realizado el insert correctamente
	***********************************************************************/
	FUNCTION f_del_usuario(
			 pcusuari	IN	VARCHAR2
	)   RETURN NUMBER;

	  /***********************************************************************
	Recupera un usuario
	param in pcusuari : Codigo del usuario.
	param out pusuario : Usuario solicitado
	return             : 1/0 indicando si se ha realizado el insert correctamente
	***********************************************************************/
	FUNCTION f_get_usuario(
			 pcusuari	IN	VARCHAR2,
			 pusuario	OUT	usuarios%ROWTYPE,
			 ptempres	OUT	VARCHAR2,
			 ptdelega	OUT	VARCHAR2,
			 pccfgwiz	OUT	VARCHAR2,
			 pccfgform	OUT	VARCHAR2,
			 pccfgacc	OUT	VARCHAR2,
			 pcrolmen	OUT	VARCHAR2,
			 pcconsupl	OUT	VARCHAR2,
			 pccfgdoc	OUT	VARCHAR2,
			 pcaccprod	OUT	VARCHAR2, -- BUG16471:DRA:26/10/2010
			 pccfgmap	OUT	VARCHAR2, -- BUG 21569 - 07/03/2012 - JMP
			 pcrol	OUT	VARCHAR2,
             pareas OUT VARCHAR2, -- IAXIS-4994
			 pcusuagru	OUT	VARCHAR2) --FAC Asociar nivel PSU al usuario
	  RETURN NUMBER;

	  /*************************************************************************
	Devuelve los usuarios que cumplan con el criterio de selección
	param in pcempres   : código de la empresa
	param in pcusuari   : código del usuario
	param in ptusername : Nombre del usuario
	param in pcdelega : codigo de la delegacion
	param in pcidioma : codigo de idioma
	return                : varchar2
	*************************************************************************/
	FUNCTION ff_consulta_usuarios(
			 pcempres NUMBER,
			 puser VARCHAR2,
			 ptusername VARCHAR2,
			 pcdelega NUMBER,
			 pcidioma NUMBER
	)   RETURN VARCHAR2;

	  /***********************************************************************
	Recupera un agente
	param in pcusuari : Codigo del usuario.
	param out pcagente : agente solicitado
	return             : 1/0 indicando si se ha realizado el insert correctamente
	***********************************************************************/
	FUNCTION f_get_cagente(
			 pcusuari	IN	VARCHAR2,
			 pcagente	OUT	NUMBER
	)   RETURN NUMBER;

	  /***********************************************************************
	Recupera un agente
	param in pcusuari : Codigo del usuario.
	return             : codigo de agente
	***********************************************************************/
	FUNCTION ff_get_cagente(
			 pcusuari	IN	VARCHAR2
	)   RETURN NUMBER;

	  /******************************************************************************************
	Autor: XVILA (05/12/2008)
	Descripció: Funció que activa un usuari donat de baixa.
	Paràmetres entrada: - pcusuari    -> id. usuari
	return:             retorna 0 si va tot bé, sino el codi de l'error
	******************************************************************************************/
	FUNCTION f_activar_usuario(
			 pcusuari	IN	VARCHAR2
	)   RETURN NUMBER;

	  /*************************************************************************
	BUG 13266
	Obtiene el terminal fisico de un usuario
	param in pUser   : código de usuario
	return           : 1 indica que existe
	0 no existe
	*************************************************************************/
	FUNCTION f_get_termfisic(
			 puser	IN	usuarios.cusuari%TYPE,
			 pctermfisic	OUT	VARCHAR2
	)   RETURN NUMBER;

	  /***********************************************************************
	BUG 13266
	Recupera un terminal fisic
	param in pcusuari : Codigo del usuario.
	return            : terminal
	***********************************************************************/
	FUNCTION ff_get_termfisic(
			 pcusuari	IN	VARCHAR2
	)   RETURN VARCHAR2;

	  /*************************************************************************
	BUG 13266
	Inserta el terminal fisic a l'usuari
	param in pUser   : código de usuario
	param in pterminal : terminal
	return           : 0 indica cambio realizado correctamente
	<> 0 indica error
	*************************************************************************/
	FUNCTION f_set_termfisic(
			 puser	IN	VARCHAR2,
			 pterminal	IN	VARCHAR2
	)   RETURN NUMBER;

	  --BUG21762 - JTS - 20/03/2012
	FUNCTION f_logea(
			 puser	IN	VARCHAR2
	)   RETURN NUMBER;

	FUNCTION f_deslogea(
			 puser	IN	VARCHAR2
	)   RETURN NUMBER;

	  --FiBUG21762
	FUNCTION f_val_cambio_paswd(
			 puser	IN	VARCHAR2,
			 pdias	OUT	NUMBER
	)   RETURN NUMBER;

	FUNCTION f_set_cambia_pass(
			 puser	IN	VARCHAR2,
			 pvalue	IN	NUMBER
	)   RETURN NUMBER;

	FUNCTION f_get_cambia_pass(
			 puser	IN	VARCHAR2,
			 pvalue	OUT	NUMBER
	)   RETURN NUMBER;

	FUNCTION f_useractivo(
			 pusuario	IN	VARCHAR2,
			 pactivo	OUT	NUMBER
	)   RETURN NUMBER;

END pac_user;
/
