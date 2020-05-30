--------------------------------------------------------
--  DDL for Package Body PAC_IAX_USER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_USER" AS

   /******************************************************************************
      NOMBRE:      PAC_IAX_USER
      PROP¿SITO:   Funciones para la gesti¿n de usuarios de la aplicaci¿n.
      REVISIONES:
      Ver        Fecha        Autor             Descripci¿n
      ---------  ----------  ---------------  ------------------------------------
      1.0        23/01/2008   JAS               1. Creaci¿n del package.
      1.1        31/01/2008   JTS               2. Se implementan las funciones:
                                                           - F_Get_User
                                                           - F_Set_DatUsuario
                                                           - F_Set_Password
      2.0
      3.0
      4.0
      5.0
      6.0
      7.0
      8.0
      9.0        13/03/2009   DCT               9. Modificaci¿n F_SET_USUARIO.
     10.0        26/10/2010   DRA              10. 16471: CRT - Configuracion de visibilidad/contratacion de productos a nivel de perfil
     11.0        22/11/2010   JAS              11. 13266: Modificaci¿n interfases apertura y cierre de puesto (parte PL) Diverses modificacions al codi
     12.0        07/03/2012   JMP              12. 21569: CRE998 - Configurar llen¿ador d'Informes per perfil
     13.0        21/05/2012   ETM               13.0022240: MDP - COM - Alta y modificaci¿n de usuarios. pantalla AXISUSU003
     14.0        22/10/2013   FAC               14. 28627: Agregar al mantenimiento de Usuario la asignaci¿n de nivel de psu
     15.0        21/02/2014   FAL               15. 0029965: RSA702 - GAPS renovaci¿n
     16.0        03/08/2019   JMJRR             16.IAXIS-4994 Se modifican parametros de entrada para agregar informacion a los usuarios
   ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /***********************************************************************
               Recupera el usuario conectado a la aplicaci¿n.
      param out mensajes : mensajes de error
      return             : VARCAHR2
   ***********************************************************************/

	FUNCTION f_get_user(
			mensajes	OUT	T_IAX_MENSAJES
	) RETURN VARCHAR2
	IS
	  vobjectname VARCHAR2(500):='PAC_IAX_USER.F_Get_User';
	  vparam      VARCHAR2(500):='par¿metros - NULL';
	  vpasexec    NUMBER(5):=1;
	  vnumerr     NUMBER(8):=0;
	  vuser       VARCHAR2(20);
	BEGIN
	    vuser:=pac_md_common.f_get_cxtusuario;

	    RETURN vuser;
	EXCEPTION
	  WHEN e_param_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

	             RETURN NULL; WHEN OTHERS THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);

	             RETURN NULL;
	END f_get_user;

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
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='PAC_IAX_USER.F_Set_DatUsuario';
	  vparam      VARCHAR2(500):='par¿metros - pUser: '
	                        || puser
	                        || ' ptUsername: '
	                        || ptusername
	                        || ' pcIdioma: '
	                        || pcidioma;
	  vpasexec    NUMBER(5):=1;
	  vnumerr     NUMBER(8):=0;
	  vuser       VARCHAR2(20);
	BEGIN
	    /*Comprovaci¿ dels par¿metres d'entrada*/
	    IF puser IS NULL  OR
	       ptusername IS NULL  OR
	       pcidioma IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    vpasexec:=3;

	    vnumerr:=pac_md_user.f_set_datusuario(puser, ptusername, pcidioma, mensajes);

	    IF vnumerr<>0 THEN
	      RAISE e_object_error;
	    END IF;

	    vpasexec:=5;

	    /*Si l'usuari que est¿ connectat ¿s el mateix pel que es canvia l'idioma,*/
	    /*actualitzo el context perqu¿ tingui "efectes inmmediats" en l'execuci¿*/
	    /* de l'aplicaci¿.*/
	    IF upper(pac_md_common.f_get_cxtusuario)=upper(puser) THEN
	      pac_md_common.p_set_cxtidioma(pcidioma);
	    END IF;

	    /*Dades d'usuari guardades correctament.*/
	    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 111313);

	    COMMIT;

	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             ROLLBACK;

	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

	             RETURN 1; WHEN e_object_error THEN
	             ROLLBACK;

	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);

	             RETURN 1; WHEN OTHERS THEN
	             ROLLBACK;

	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);

	             RETURN 1;
	END f_set_datusuario;

	/*************************************************************************
	                     Carga la informaci¿n del usuario al objeto
	   param in pUser       : usuario identificado en la aplicaci¿n
	   param in mensajes    : mensajes de error
	   return               : pdatuser -> Datos del usuario
	                           NULL si error
	*************************************************************************/
	FUNCTION f_get_datusuario(
			puser	IN	VARCHAR2,
			mensajes	OUT	T_IAX_MENSAJES
	) RETURN OB_IAX_USERS
	IS
	  vobjectname VARCHAR2(500):='PAC_IAX_USER.F_Get_DatUsuario';
	  vparam      VARCHAR2(500):='par¿metros - pUser: '
	                        || puser;
	  vpasexec    NUMBER(5):=1;
	  vnumerr     NUMBER(8):=0;
	  vdatuser    OB_IAX_USERS;
	  vuser       VARCHAR2(20);
	BEGIN
	    /*Si no ens informen usuari, agafem les dades del que t¿ la sessi¿ iniciada*/
	    vuser:=nvl(puser, f_get_user(mensajes));

	    /*Comprovaci¿ dels par¿metres d'entrada*/
	    IF vuser IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    vpasexec:=3;

	    /*SBG 30/05/2008 - Registre de LOG*/
	    vnumerr:=pac_md_log.f_log_consultas('pusuario = '
	                                        || vuser, 'PAC_IAX_USER.F_Get_DatUsuario', 2, 4, mensajes);

	    vdatuser:=pac_md_user.f_get_datuser(vuser, mensajes);

	    IF vdatuser IS NULL THEN
	      RAISE e_object_error;
	    END IF;

	    COMMIT; /* Necesario por el log de las consultas*/

	    RETURN vdatuser;
	EXCEPTION
	  WHEN e_param_error THEN
	             ROLLBACK;

	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

	             RETURN NULL; WHEN e_object_error THEN
	             ROLLBACK;

	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);

	             RETURN NULL; WHEN OTHERS THEN
	             ROLLBACK;

	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);

	             RETURN NULL;
	END f_get_datusuario;

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
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='PAC_IAX_USER.F_Set_Password';
	  vparam      VARCHAR2(500):='par¿metros - pUser: '
	                        || puser;
	  vpasexec    NUMBER(5):=1;
	  vnumerr     NUMBER(8):=0;
	BEGIN
	    /*Comprovaci¿ dels par¿metres d'entrada*/
	    IF puser IS NULL  OR
	       pnewpwd IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    vpasexec:=3;

	    vnumerr:=pac_md_user.f_setpass(puser, poldpwd, pnewpwd, mensajes);

	    IF vnumerr<>0 THEN
	      RAISE e_object_error;
	    END IF;

	    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 111313);

	    COMMIT;

	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             ROLLBACK;

	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

	             RETURN 1; WHEN e_object_error THEN
	             ROLLBACK;

	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);

	             RETURN 1; WHEN OTHERS THEN
	             ROLLBACK;

	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);

	             RETURN 1;
	END f_set_password;
    
	FUNCTION f_set_usuario(pcusuari	IN	VARCHAR2,pcidioma	IN	NUMBER,pcempres	IN	NUMBER,ptusunom	IN	VARCHAR2,pcdelega	IN	NUMBER,poldpwd	IN	VARCHAR2,pnewpwd	IN	VARCHAR2,pnewpwdcnf	IN	VARCHAR2,pcempleado	IN	VARCHAR2,pcwizard	IN	VARCHAR2,pcform	IN	VARCHAR2,pcaccion	IN	VARCHAR2,pcmenu	IN	VARCHAR2,pcconsupl	IN	VARCHAR2,pcdocumentacio	IN	VARCHAR2,/*BUG8898-23032009-XVM*/pcautlog	IN	NUMBER,pcaccprod	IN	VARCHAR2,/* BUG16471:DRA:26/10/2010*/pccfgmap	IN	VARCHAR2,/* BUG 21569 - 07/03/2012 - JMP*/pcvispubli	IN	NUMBER,pcrol	IN	VARCHAR2,pcusuagru	IN	NUMBER,/*FAC Asociar nivel PSU al usuario*/pmail_usu	IN	VARCHAR2,/* BUG 29965 - FAL - 07/02/2014*/ptelfusu	IN	VARCHAR2,punidept	IN	NUMBER,pcategprof	IN	NUMBER,psperson IN	NUMBER,pareas IN VARCHAR2 /*IAXIS-4994*/,mensajes	OUT	T_IAX_MENSAJES)
	RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='PAC_IAX_USER.F_SET_USUARIO';
	  vparam      VARCHAR2(500):='par¿metros - pcusuari: '
	                        || pcusuari
	                        || ' pcidioma:'
	                        || pcidioma
	                        || ' pcempres:'
	                        || pcempres
	                        || ' ptusunom'
	                        || ptusunom
	                        || ' pOldPwd:'
	                        || poldpwd
	                        || ' pNewPwd:'
	                        || pnewpwd
	                        || ' pNewPwdCnf:'
	                        || pnewpwdcnf
	                        || ' pcwizard:'
	                        || pcwizard
	                        || ' pcform:'
	                        || pcform
	                        || ' pcaccion:'
	                        || pcaccion
	                        || ' pcconsupl:'
	                        || pcconsupl
	                        || ' pcrol:'
	                        || pcrol
	                        || ' ppsu: '
	                        || pcusuagru
                            --IAXIS-4994
                            || 'pareas: '
                            || pareas;
	  vpasexec    NUMBER(5):=1;
	  vnumerr     NUMBER(8):=0;
	  vrespuesta  NUMBER;
	  vcusuagru   NUMBER;
	  e_error_pwd EXCEPTION;
	BEGIN
	    /*Comprovaci¿ de par¿metres d'entrada*/
	    IF pcusuari IS NULL  OR
	       pcidioma IS NULL  OR
	       pcempres IS NULL  OR
	       ptusunom IS NULL /*OR pcconsupl IS NOT NULL*/
	    THEN
	      RAISE e_param_error;
	    END IF;

	    vpasexec:=1;

	    vnumerr:=pac_md_user.f_existuser(pcusuari, vrespuesta, mensajes);

	    IF vrespuesta=0 THEN
	      IF pnewpwd IS NULL THEN
	        pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000170);

	        RAISE e_param_error;
	      END IF;
	    END IF;

	    vpasexec:=2;

	    /* Verifica que hayan informado los 2 campos de claves y estas sean iguales*/
	    IF pnewpwd IS NOT NULL AND
	       pnewpwdcnf IS NOT NULL AND
	       (pnewpwd<>pnewpwdcnf) THEN
	      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000151);

	      RAISE e_param_error;
	    END IF;

	    /* Verifica que hayan informado las 2 claves*/
	    IF (pnewpwd IS NOT NULL AND
	        pnewpwdcnf IS NULL) THEN
	      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000168);

	      RAISE e_param_error;
	    END IF;

	    /* Verifica que hayan informado las 2 claves*/
	    IF (pnewpwd IS NULL AND
	        pnewpwdcnf IS NOT NULL) THEN
	      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000170);

	      RAISE e_param_error;
	    END IF;

	    vpasexec:=3;

	    IF pnewpwd IS NOT NULL AND
	       vrespuesta=1 THEN
	      vnumerr:=pac_md_user.f_validate_pwd(pcusuari, poldpwd, pnewpwd, 'MODIF', mensajes);

	      vpasexec:=4;
	    ELSIF pnewpwd IS NOT NULL THEN
	      vnumerr:=pac_md_user.f_validate_pwd(pcusuari, poldpwd, pnewpwd, 'NEW', mensajes);

	      vpasexec:=5;
	    END IF;

	    IF vnumerr<>0 THEN
	      RAISE e_object_error;
	    END IF;

	    vpasexec:=6;

	    vnumerr:=pac_md_user.f_set_usuario(pcusuari, pcidioma, pcempres, ptusunom, 'C:/', pcdelega, NULL, NULL, NULL, NULL, NULL, 0, psperson, NULL, 2, NULL, 0, NULL, trunc(f_sysdate), NULL, pcautlog, pcempleado, NULL, nvl(pcvispubli, 1), pmail_usu, /* BUG 29965 - FAL - 07/02/2014*/
	             ptelfusu, punidept, pcategprof, mensajes); /*ETM 22240*/

	    vpasexec:=7;

	    IF vnumerr<>0 THEN
	      RAISE e_object_error;
	    END IF;

	    vpasexec:=8;

	    IF pnewpwd IS NOT NULL AND
	       vrespuesta=1 THEN
	      vnumerr:=pac_md_user.f_setpass(pcusuari, poldpwd, pnewpwd, mensajes);
	    ELSIF pnewpwd IS NOT NULL THEN
	      vnumerr:=pac_md_user.f_newpass(pcusuari, pnewpwd, mensajes);
	    END IF;

	    IF vnumerr<>0 THEN
	      RAISE e_object_error;
	    END IF;

	    /*Modificamos el usuario por ROL*/
	    IF pcrol IS NOT NULL THEN
	      vpasexec:=9;

	      vnumerr:=pac_md_cfg.f_set_cfg_userrol(pcusuari, pcempres, pcrol, mensajes);

	      IF vnumerr<>0 THEN
	        RAISE e_object_error;
	      END IF;
	    /*Modificamos el usuario manualmente*/
	    ELSE
	      vpasexec:=10;

	      vnumerr:=pac_md_cfg.f_set_cfg_user(pcusuari, pcwizard, pcform, pcaccion, pcempres, pcdocumentacio, pcaccprod, pccfgmap, pcrol, /* BUG16471:DRA:26/10/2010*/ pareas,/*IAXIS-4994*/
	               mensajes); /*BUG8898-24032009-XVM*/

	      vpasexec:=11;

	      IF vnumerr<>0 THEN
	        RAISE e_object_error;
	      END IF;

	      vpasexec:=12;

	      vnumerr:=pac_md_cfg.f_set_cfg_menu(pcusuari, pcmenu, mensajes);

	      IF vnumerr<>0 THEN
	        RAISE e_object_error;
	      END IF;

	      vpasexec:=13;

	      vnumerr:=pac_md_cfg.f_set_pds_configuser(pcusuari, pcconsupl, mensajes);

	      IF vnumerr<>0 THEN
	        RAISE e_object_error;
	      END IF;

	      vpasexec:=14;

	      BEGIN
	          vnumerr:=pac_md_cfg.f_set_psu_usuagru(pcusuari, pcusuagru, mensajes);

	          IF vnumerr<>0 THEN
	            RAISE e_object_error;
	          END IF;
	      END;

	      vpasexec:=15;
	    END IF;

	    COMMIT;

	    RETURN 0;
	EXCEPTION
	  WHEN e_error_pwd THEN
	             ROLLBACK;

	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000170, vpasexec, vparam);

	             RETURN 1; WHEN e_param_error THEN
	             ROLLBACK;

	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

	             RETURN 1; WHEN e_object_error THEN
	             ROLLBACK;

	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);

	             RETURN 1; WHEN OTHERS THEN
	             ROLLBACK;

	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);

	             RETURN 1;
	END f_set_usuario;

	/***********************************************************************
	                                                                                                                                             Borra un usuario
	   param in pcusuari : Codigo del usuario.
	   param out mensajes : mensajes de error
	   return             : 1/0 indicando si se ha realizado el insert correctamente
	***********************************************************************/
	FUNCTION f_del_usuario(
			pcusuari	IN	VARCHAR2,
			mensajes	OUT	T_IAX_MENSAJES
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='PAC_MD_USER.F_DEL_USUARIO';
	  vparam      VARCHAR2(500):='par¿metros - pusuario: '
	                        || pcusuari;
	  vpasexec    NUMBER(5):=1;
	  vnumerr     NUMBER(8):=0;
	BEGIN
	    /*Comprovaci¿ de par¿metres d'entrada*/
	    IF pcusuari IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    vnumerr:=pac_md_user.f_del_usuario(pcusuari, mensajes);

	    IF vnumerr<>0 THEN
	      RAISE e_object_error;
	    END IF;

	    COMMIT;

	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             ROLLBACK;

	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

	             RETURN 1; WHEN e_object_error THEN
	             ROLLBACK;

	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);

	             RETURN 1; WHEN OTHERS THEN
	             ROLLBACK;

	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);

	             RETURN 1;
	END f_del_usuario;

	/*************************************************************************
	                     Carga la informaci¿n del usuario al objeto
	   param in pUser      : usuario identificado en la aplicaci¿n
	   param out pUsuario  : objeto de USUARIOS
	   param out mensajes  : mensajes de error
	   return              : 1/0 indicando si se ha realizado correctamente
	*************************************************************************/
	FUNCTION f_get_usuario(
			puser	IN	VARCHAR2,
			pusuario	OUT	OB_IAX_USUARIOS,
			mensajes	OUT	T_IAX_MENSAJES
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='PAC_IAX_USER.F_Get_Usuario';
	  vparam      VARCHAR2(500):='par¿metros - pUser: '
	                        || puser;
	  vpasexec    NUMBER(5):=1;
	  vnumerr     NUMBER(8):=0;
	BEGIN
	    /*Comprovaci¿ dels par¿metres d'entrada*/
	    IF puser IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    vpasexec:=3;

	    vnumerr:=pac_md_user.f_get_usuario(puser, pusuario, mensajes);

	    IF vnumerr<>0 THEN
	      RAISE e_object_error;
	    END IF;

	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

	             RETURN NULL; WHEN e_object_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);

	             RETURN NULL; WHEN OTHERS THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);

	             RETURN NULL;
	END f_get_usuario;

	/*************************************************************************
	                     Devuelve los terminales que cumplan con el criterio de selecci¿n
	   param in pcempres   : c¿digo de la empresa
	   param in pcmaqfisi  : M¿quina f¿sica
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
	) RETURN SYS_REFCURSOR
	IS
	  cur      SYS_REFCURSOR;
	  vobject  VARCHAR2(500):='PAC_IAX_USER.F_CONSULTA_USUARIOS';
	  vparam   VARCHAR2(500):='par¿metros - pUser:'
	                        || puser
	                        || ' ptUsername:'
	                        || ptusername
	                        || ' pcDelega:'
	                        || pcdelega
	                        || ' pcempres:'
	                        || pcempres;
	  vpasexec NUMBER(5):=1;
	  vnumerr  NUMBER(8):=0;
	BEGIN
	    cur:=pac_md_user.f_consulta_usuario(pcempres, puser, ptusername, pcdelega, mensajes);

	    COMMIT; /* Necesario por el LOG de las consultas*/

	    RETURN cur;
	EXCEPTION
	  WHEN e_param_error THEN
	             ROLLBACK;

	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

	             IF cur%isopen THEN
	               CLOSE cur;
	             END IF;

	             RETURN cur; WHEN e_object_error THEN
	             ROLLBACK;

	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

	             IF cur%isopen THEN
	               CLOSE cur;
	             END IF;

	             RETURN cur; WHEN OTHERS THEN
	             ROLLBACK;

	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, psqcode=>SQLCODE, psqerrm=>SQLERRM);

	             IF cur%isopen THEN
	               CLOSE cur;
	             END IF;

	             RETURN cur;
	END f_consulta_usuarios;

	/******************************************************************************************
	                                         Autor: XVILA (05/12/2008)
	  Descripci¿: Funci¿ que activa un usuari donat de baixa.
	  Par¿metres entrada: - pcusuari -> id. usuari
	  Par¿metres sortida: - mensajes -> Missatges d'error
	  return:             retorna 0 si va tot b¿, sino el codi de l'error
	******************************************************************************************/
	FUNCTION f_activar_usuario(
			pcusuari	IN	VARCHAR2,
			mensajes	OUT	T_IAX_MENSAJES
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='pac_iax_user.f_activar_usuario';
	  vparam      VARCHAR2(500):='par¿metros - pcusuari:'
	                        || pcusuari;
	  vpasexec    NUMBER(5):=1;
	  vnumerr     NUMBER(8):=0;
	BEGIN
	    /*Comprovaci¿ de par¿metres d'entrada*/
	    IF pcusuari IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    vnumerr:=pac_md_user.f_activar_usuario(pcusuari, mensajes);

	    IF vnumerr<>0 THEN
	      RAISE e_object_error;
	    END IF;

	    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 9000662);

	    COMMIT;

	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             ROLLBACK;

	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

	             RETURN 1; WHEN e_object_error THEN
	             ROLLBACK;

	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);

	             RETURN 1; WHEN OTHERS THEN
	             ROLLBACK;

	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);

	             RETURN 1;
	END f_activar_usuario;

	/*************************************************************************
	                     BUG 13266
	   Actualiza el terminal fisico del usuario
	   param in usuario    : c¿digo de usuario
	   param in ctermfisic : t. fisic
	   param in out mensajes : mensajes de error
	   return                : 1 error
	                           0 ok
	*************************************************************************/
	FUNCTION f_set_termfisic(
			pusuario	IN	VARCHAR2,
			pctermfisic	IN	VARCHAR2,
			mensajes	OUT	T_IAX_MENSAJES
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='PAC_IAX_USER.f_set_termfisic';
	  vparam      VARCHAR2(500):='par¿metros - pusuario: '
	                        || pusuario
	                        || ' pctermfisic:'
	                        || pctermfisic;
	  vpasexec    NUMBER(5):=1;
	  vnumerr     NUMBER(8):=0;
	BEGIN
	    /*Comprovaci¿ de par¿metres d'entrada*/
	    IF pusuario IS NULL  OR
	       pctermfisic IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    /*Actualitzem el terminal fisic*/
	    vnumerr:=pac_md_user.f_set_termfisic(pusuario, pctermfisic, mensajes);

	    IF vnumerr<>0 THEN
	      RAISE e_object_error;
	    END IF;

	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

	             RETURN 1; WHEN e_object_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);

	             RETURN 1; WHEN OTHERS THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);

	             RETURN 1;
	END f_set_termfisic;

	/*************************************************************************
	                     BUG 13266
	   Obt¿ el terminal fisico del usuario
	   param in usuario    : c¿digo de usuario
	   param out ctermfisic : t. fisic
	   param in out mensajes : mensajes de error
	   return                : 1 error
	                           0 ok
	*************************************************************************/
	FUNCTION f_get_termfisic(
			pusuario	IN	VARCHAR2,
			pctermfisic	OUT	VARCHAR2,
			mensajes	OUT	T_IAX_MENSAJES
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='PAC_IAX_USER.f_get_termfisic';
	  vparam      VARCHAR2(500):='par¿metros - pusuario: '
	                        || pusuario;
	  vpasexec    NUMBER(5):=1;
	  vnumerr     NUMBER(8):=0;
	BEGIN
	    /*Comprovaci¿ de par¿metres d'entrada*/
	    IF pusuario IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    /*Obtenim el terminal fisic*/
	    vnumerr:=pac_md_user.f_get_termfisic(pusuario, pctermfisic, mensajes);

	    IF vnumerr<>0 THEN
	      RAISE e_object_error;
	    END IF;

	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

	             RETURN 1; WHEN e_object_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);

	             RETURN 1; WHEN OTHERS THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);

	             RETURN 1;
	END f_get_termfisic;

	/***********************************************************************
	   Recupera una coleccn de usuarios segn la visin del usuario conectado
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
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='pac_iax_user.f_get_usuario_vision';
	  vparam      VARCHAR2(500):='par¿metros - pcusuari:'
	                        || pcusuari;
	  vpasexec    NUMBER(5):=1;
	  vnumerr     NUMBER(8):=0;
	BEGIN
	    vnumerr:=pac_md_user.f_get_usuario_vision(pcusuari, pnomusuario, ptusuario, mensajes);

	    IF vnumerr<>0 THEN
	      RAISE e_object_error;
	    END IF;

	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

	             RETURN 1; WHEN e_object_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);

	             RETURN 1; WHEN OTHERS THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);

	             RETURN 1;
	END f_get_usuario_vision;
	FUNCTION f_val_cambio_paswd(
			puser	IN	VARCHAR2,
			mensajes	OUT	T_IAX_MENSAJES
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='PAC_iax_USER.f_val_cambio_paswd';
	  vparam      VARCHAR2(500):='parmetros - pcusuari: '
	                        || puser;
	  vpasexec    NUMBER(5):=1;
	  vnumerr     NUMBER(8):=0;
	  vusuario    OB_IAX_USERS:=ob_iax_users();
	  vcusuari    VARCHAR2(20);
	  vdias       NUMBER:=0;
	BEGIN
	    vnumerr:=pac_md_user.f_val_cambio_paswd(puser, mensajes);

	    IF vnumerr<>0 THEN
	      RAISE e_object_error;
	    END IF;

	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

	             RETURN 1; WHEN e_object_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);

	             RETURN 1; WHEN OTHERS THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);

	             RETURN 1;
	END f_val_cambio_paswd;
	FUNCTION f_get_usuarios(
			puser	IN	usuarios.cusuari%TYPE,
			pusername	IN	usuarios.tusunom%TYPE,
			tusers	OUT	T_IAX_USERS,
			mensajes	OUT	T_IAX_MENSAJES
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='PAC_IAX_USER.f_get_usuarios';
	  vparam      VARCHAR2(500):='parmetros - pcusuari: '
	                        || puser
	                        || ' pusername '
	                        || pusername;
	  vpasexec    NUMBER(5):=1;
	  vnumerr     NUMBER(8):=0;
	BEGIN
	    /**/
	    vnumerr:=pac_md_user.f_get_usuarios(puser, pusername, tusers, mensajes);

	    /**/
	    IF vnumerr<>0 THEN
	      RAISE e_object_error;
	    END IF;

	    /**/
	    RETURN vnumerr;
	EXCEPTION
	  WHEN e_object_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);

	             RETURN 1; WHEN OTHERS THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);

	             RETURN 1;
	END f_get_usuarios;

END pac_iax_user;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_USER" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_USER" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_USER" TO "PROGRAMADORESCSI";
