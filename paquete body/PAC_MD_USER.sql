--------------------------------------------------------
--  DDL for Package Body PAC_MD_USER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_USER" AS

   /******************************************************************************
      NOMBRE:      PAC_MD_USER
      PROPÓSITO:   Funciones para validar el usuario
      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        24/01/2008   JAS                1. Creación del package.
      1.1        31/01/2008   JTS                2. Se crean las funciones:
                                                           - F_Set_DatUsuario
                                                           - F_CompPas
                                                           - F_SetPass
      3          02/07/2009   ETM               3. bug 0010616: IAX - Actualització de l'idioma del context al modificar l'idioma de l'usuari que està connectat.
      10.0       30/03/2009   DCT               10.Modificar f_get_usuario
      11.0       2/11/2010    JAS               11. 13266: Modificación interfases apertura y cierre de puesto (parte PL)
      12.0       07/03/2012   JMP               12. 21569: CRE998 - Configurar llençador d'Informes per perfil
      13.0       22/10/2013   FAC               13. 28627: Agregar al mantenimiento de Usuario la asignación de nivel de psu
      14.0       21/02/2014   FAL               14. 0029965: RSA702 - GAPS renovación
      15.0       03/08/2019   JMJRR             15. IAXIS-4994 Se ajusta recuperacion de la informacion de usuarios
   ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

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
	) RETURN NUMBER
	IS
	  vobject  VARCHAR2(500):='PAC_MD_USER.F_ExistUser';
	  vparam   VARCHAR2(500):='parámetros - pusuario: '
	                        || pusuario;
	  vpasexec NUMBER(5):=1;
	  vnumerr  NUMBER(8):=0;
	  vexist   NUMBER(1);
	BEGIN
	    /*Comprovació de paràmetres d'entrada*/
	    IF pusuario IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    vpasexec:=3;

	    prespuesta:=1;

	    vnumerr:=pac_user.f_existuser(pusuario, vexist);

	    IF vnumerr<>0 THEN
	      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);

	      RAISE e_object_error;
	    END IF;

	    prespuesta:=vexist;

	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

	             RETURN 1; WHEN e_object_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

	             RETURN 1; WHEN OTHERS THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, psqcode=>SQLCODE, psqerrm=>SQLERRM);

	             RETURN 1;
	END f_existuser;

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
	) RETURN NUMBER
	IS
	  vobject  VARCHAR2(500):='PAC_MD_USER.F_isAutologinUser';
	  vparam   VARCHAR2(500):='parámetros - pusuario: '
	                        || pusuario;
	  vpasexec NUMBER(5):=1;
	  vnumerr  NUMBER(8):=0;
	  vcautlog NUMBER(1);
	BEGIN
	    /*Comprovació de paràmetres d'entrada*/
	    IF pusuario IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    vpasexec:=3;

	    vnumerr:=pac_user.f_isautologinuser(pusuario, vcautlog);

	    IF vnumerr<>0 THEN
	      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);

	      RAISE e_object_error;
	    END IF;

	    prespuesta:=vcautlog;

	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

	             /* Si hay un error devolvemos que no es autologin para que salga*/
	             RETURN 1; WHEN e_object_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

	             /* Si hay un error devolvemos que no es autologin para que salga*/
	             RETURN 1; WHEN OTHERS THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, psqcode=>SQLCODE, psqerrm=>SQLERRM);

	             /* Si hay un error devolvemos que no es autologin para que salga*/
	             RETURN 1;
	END f_isautologinuser;

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
	) RETURN NUMBER
	IS
	  vobject     VARCHAR2(500):='PAC_MD_USER.F_ValidateUser';
	  vparam      VARCHAR2(500):='parámetros - pusuario: '
	                        || pusuario;
	  vpasexec    NUMBER(5):=1;
	  vnumerr     NUMBER(8):=0;
	  vtpwd       VARCHAR2(100);
	  vvalidation NUMBER(1);
	BEGIN
	    /*Comprovació de paràmetres d'entrada*/
	    IF pusuario IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    vpasexec:=3;

	    vnumerr:=pac_user.f_validateuser(pusuario, ppwd, vvalidation, pintentos);

	    IF vnumerr<>0 THEN
	      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);

	      RAISE e_object_error;
	    END IF;

	    pvalido:=vvalidation;

	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

	             RETURN 1; WHEN e_object_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

	             RETURN 1; WHEN OTHERS THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, psqcode=>SQLCODE, psqerrm=>SQLERRM);

	             RETURN 1;
	END f_validateuser;

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
	) RETURN OB_IAX_USERS
	IS
	  vobjectname VARCHAR2(500):='PAC_MD_USER.F_Get_DatUser';
	  vparam      VARCHAR2(500):='parámetros - pusuario: '
	                        || pusuario;
	  vpasexec    NUMBER(5):=1;
	  vnumerr     NUMBER(8):=0;
	  vsperson    NUMBER;

	  CURSOR c_user IS
	    SELECT u.*
	      FROM usuarios u
	     WHERE lower(u.cusuari)=lower(pusuario);

	  vtpooluser  VARCHAR2(100);
	  vdatuser    OB_IAX_USERS;
	BEGIN
	    /*Comprovació de paràmetres d'entrada*/
	    IF pusuario IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    vpasexec:=3;

	    vtpooluser:=pac_md_common.f_get_parinstalacion_t('POOL_USER');

	    vdatuser:=ob_iax_users();

	    FOR reg IN c_user LOOP
	        vpasexec:=5;

	        vdatuser.cusuari:=upper(reg.cusuari);

	        vdatuser.cidioma:=reg.cidioma;

	        vdatuser.cempres:=reg.cempres;

	        vdatuser.ctipusu:=reg.ctipusu;

	        vdatuser.copcion:=reg.copcion;

	        vdatuser.nombre:=reg.tusunom;

	        vdatuser.cusuariodb:=nvl(reg.cusubbdd, vtpooluser);

	        vdatuser.fultimologin:=reg.flogin;

	        /*bug 18039-21/03/2011-AMC*/
	        SELECT sperson
	          INTO vsperson
	          FROM agentes
	         WHERE cagente=reg.cdelega;

	        vdatuser.tagente:=f_nombre(vsperson, 1, reg.cdelega);

	        /*Fi bug 18039-21/03/2011-AMC*/
	        /*Si l'usuari de base de dades es diferent al del pool sha de canviar*/
	        /*el pool per 2 (falta definir com establir el usuari pool)*/
	        IF reg.cusuari=reg.cusubbdd THEN
	          vdatuser.pool:=2;

	          vdatuser.passworddb:=reg.cusuari;
	        ELSE
	          vdatuser.pool:=1;
	        END IF;

	        /* DE MOMENT EL CAGENTE ES CDELEGA s'ha de canviar tot*/
	        vdatuser.cagente:=reg.cdelega;
	    END LOOP;

	    RETURN vdatuser;
	EXCEPTION
	  WHEN e_param_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

	             RETURN NULL; WHEN OTHERS THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);

	             RETURN NULL;
	END f_get_datuser;

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
	  vparam      VARCHAR2(500):='parámetros - NULL';
	  vpasexec    NUMBER(5):=1;
	  vnumerr     NUMBER(8):=0;
	  vuser       VARCHAR2(20);
	BEGIN
	    /*Comprovació dels parámetres d'entrada*/
	    IF puser IS NULL  OR
	       ptusername IS NULL  OR
	       pcidioma IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    vnumerr:=pac_user.f_set_datusuario(puser, ptusername, pcidioma);

	    IF vnumerr<>0 THEN
	      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);

	      RAISE e_object_error;
	    END IF;

	    /* bug 0010616: 02/07/2009 :ETM :IAX - Actualització de l'idioma del context al modificar l'idioma de l'usuari que està connectat.*/
	    IF upper(pac_md_common.f_get_cxtusuario)=upper(puser) THEN
	      pac_md_common.p_set_cxtidioma(pcidioma);
	    END IF;

	    /* fin bug 0010616: 02/07/2009 :ETM*/
	    RETURN vnumerr;
	EXCEPTION
	  WHEN e_param_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

	             RETURN 1; WHEN OTHERS THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);

	             RETURN 1;
	END f_set_datusuario;

	/*************************************************************************
	         Comprueba que el nuevo password del usuario no sea repetido
	   param in usuario : código de usuario
	   param in ppwd    : nuevo password
	   return           : 1 indica que está repetido
	                      0 no está repetido
	*************************************************************************/
	FUNCTION f_comppass(
			pusuario	IN	VARCHAR2,
			ppwd	IN	VARCHAR2
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='PAC_MD_USER.F_CompPass';
	  vparam      VARCHAR2(500):='parámetros - pusuario: '
	                        || pusuario;
	  vpasexec    NUMBER(5):=1;
	  vnumerr     NUMBER(8):=0;
	  vpassdifer  NUMBER(5):=nvl(pac_md_common.f_get_parconexion('PASSDIFER'), 0);
	  vexist      NUMBER(1):=0;
	  vcont       NUMBER(5);

	  CURSOR c_password IS
	    SELECT u.tpwd
	      FROM usuarios_his_pass u
	     WHERE u.cusuari=upper(pusuario)
	     ORDER BY u.fcambio DESC;
	BEGIN
	    /*Comprovació de paràmetres d'entrada*/
	    IF pusuario IS NULL  OR
	       ppwd IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    vpasexec:=3;

	    vcont:=1;

	    FOR reg IN c_password LOOP
	        IF vcont>=vpassdifer THEN
	          vexist:=0;

	          RETURN vexist;
	        END IF;

	        IF ppwd=rtrim (utl_raw.cast_to_varchar2 (dbms_obfuscation_toolkit.desdecrypt (input=>reg.tpwd, KEY=>utl_raw.cast_to_raw(upper(rpad(pusuario, 32, ' '))))), ' ') THEN
	          vexist:=1;

	          RETURN vexist;
	        END IF;

	        vcont:=vcont+1;
	    END LOOP;

	    RETURN vexist;
	EXCEPTION
	  WHEN e_param_error THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'Objeto invocado con parámetros erroneos');

	             RETURN 1; WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'SQLERROR: '
	                                                                           || SQLCODE
	                                                                           || ' - '
	                                                                           || SQLERRM);

	             RETURN 1;
	END f_comppass;

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
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='PAC_MD_USER.F_SetPass';
	  vparam      VARCHAR2(500):='parámetros - pusuario:'
	                        || pusuario
	                        || ' pOldPwd:'
	                        || poldpwd
	                        || ' pNewPwd:'
	                        || pnewpwd;
	  vpasexec    NUMBER(5):=1;
	  vnumerr     NUMBER(8):=0;
	  vpasslong   NUMBER(5):=nvl(pac_md_common.f_get_parconexion('LONGPASS'), 0);
	  vmenserr    VARCHAR2(250);
	  vnewpwdenc  VARCHAR2(100);
	  vvalidate   NUMBER;
	  vcambiapass NUMBER:=nvl(pac_md_common.f_get_parconexion('CAMBPASS'), 0); -- Bug 36663/209495 - JR
	BEGIN
	    vnumerr:=f_validate_pwd(pusuario, poldpwd, pnewpwd, 'MODIF', mensajes);

	    IF vnumerr<>0 THEN
	      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);

	      RAISE e_object_error;
	    END IF;

	    vpasexec:=2;

	    /*Fem un update a l'usuari amb el nou password*/
	    vnumerr:=pac_user.f_update_userpwd(pusuario, pnewpwd);

	    IF vnumerr<>0 THEN
	      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);

	      RAISE e_object_error;
	    END IF;

	    vpasexec:=3;

	    /*Fem un insert a l'historic de passwords*/
	    vnumerr:=pac_user.f_insert_usuario_his(pusuario, pnewpwd);

	    IF vnumerr<>0 THEN
	      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);

	      RAISE e_object_error;
	    END IF;

	    /* Ini: Bug 36663/209495 - JR*/
	    IF vcambiapass=1 AND
	       pac_md_common.f_get_cxtusuario<>upper(pusuario) THEN
	      vnumerr:=pac_user.f_set_cambia_pass(pusuario, 1);

	      IF vnumerr<>0 THEN
	        RAISE e_object_error;
	      END IF;
	    END IF;

	    /* Fin: Bug 36663/209495 - JR*/
	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

	             RETURN 1; WHEN e_object_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);

	             RETURN 1; WHEN OTHERS THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);

	             RETURN 1;
	END f_setpass;

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
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='PAC_MD_USER.F_NewPass';
	  vparam      VARCHAR2(500):='parámetros - pusuario:'
	                        || pusuario
	                        || ' pNewPwd:'
	                        || pnewpwd;
	  vpasexec    NUMBER(5):=1;
	  vnumerr     NUMBER(8):=0;
	  vpasslong   NUMBER(5):=nvl(pac_md_common.f_get_parconexion('LONGPASS'), 0);
	  vmenserr    VARCHAR2(250);
	  vnewpwdenc  VARCHAR2(100);
	  vvalidate   NUMBER;
	BEGIN
	    vnumerr:=f_validate_pwd(pusuario, NULL, pnewpwd, 'NEW', mensajes);

	    IF vnumerr<>0 THEN
	      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);

	      RAISE e_object_error;
	    END IF;

	    vpasexec:=6;

	    /*Fem un update a l'usuari amb el nou password*/
	    vnumerr:=pac_user.f_update_userpwd(pusuario, pnewpwd);

	    IF vnumerr<>0 THEN
	      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);

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
	END f_newpass;

	/*************************************************************************
	            Crea un usuario nuevo en la gestión de usuarios
	      param in usuario    : usuario que se ha conectado a la aplicación
	      param in nombre     : nombre del usuario
	      param in delegacion : codigo de delegacion
	      param in pctipacc   : código tipo aceso aplicación
	      param in pcautlog   : indica si autologin
	      param in ppassword  : password
	      param in cempres    : codi empresa
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
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='PAC_MD_USER.F_CreaUserDefault';
	  vparam      VARCHAR2(500):='parámetros - pusuario: '
	                        || pusuario
	                        || ' pnombre:'
	                        || pnombre
	                        || ' pdelega:'
	                        || pdelega;
	  vpasexec    NUMBER(5):=1;
	  vnum_err    NUMBER;
	BEGIN
	    vnum_err:=pac_user.f_creauserdefault(pusuario, pnombre, pdelega, pac_parametros.f_parempresa_n(pcempresa, 'IDIOMA_DEF'), pcempresa, pcautlog);

	    IF vnum_err<>0 THEN
	      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnum_err);

	      RAISE e_object_error;
	    END IF;

	    vnum_err:=pac_md_user.f_setpass(pusuario, NULL, ppassword, mensajes);

	    IF vnum_err<>0 THEN
	      RAISE e_object_error;
	    END IF;

	    vnum_err:=pac_cfg.f_set_cfg_defecto(pusuario, pcempresa, pctipacc);

	    IF vnum_err<>0 THEN
	      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnum_err);

	      RAISE e_object_error;
	    END IF;

	    RETURN vnum_err;
	EXCEPTION
	  WHEN OTHERS THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam, NULL, SQLCODE, SQLERRM);

	             RETURN 1;
	END f_creauserdefault;

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
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='PAC_MD_USER.F_SetTerminal';
	  vparam      VARCHAR2(500):='parámetros - pusuario: '
	                        || pusuario
	                        || ' pterminal:'
	                        || pterminal;
	  vpasexec    NUMBER(5):=1;
	  vnumerr     NUMBER(8):=0;
	  vmenserr    VARCHAR2(250);
	  vnewpwdenc  VARCHAR2(100);
	BEGIN
	    /*Comprovació de paràmetres d'entrada*/
	    IF pusuario IS NULL  OR
	       pterminal IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    /*Actualitcen el terminal*/
	    vnumerr:=pac_user.f_set_terminal(pusuario, pterminal);

	    IF vnumerr<>0 THEN
	      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);

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
	END f_setterminal;

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
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='PAC_MD_USER.F_SetDelega';
	  vparam      VARCHAR2(500):='parámetros - pusuario: '
	                        || pusuario
	                        || ' pcagente:'
	                        || pcagente;
	  vpasexec    NUMBER(5):=1;
	  vnumerr     NUMBER(8):=0;
	  vmenserr    VARCHAR2(250);
	  vnewpwdenc  VARCHAR2(100);
	BEGIN
	    /*Comprovació de paràmetres d'entrada*/
	    IF pusuario IS NULL  OR
	       pcagente IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    /*Actualitcen el terminal*/
	    vnumerr:=pac_user.f_set_agente(pusuario, pcagente);

	    IF vnumerr<>0 THEN
	      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);

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
	END f_set_agente;

	/***********************************************************************
	         Crea un usuario
	   param in           : Todos los parametros del usuario.
	   param out mensajes : mensajes de error
	   return             : 1/0 indicando si se ha realizado el insert correctamente
	***********************************************************************/
	FUNCTION f_set_usuario(pcusuari	IN	VARCHAR2,pcidioma	IN	NUMBER,pcempres	IN	NUMBER,ptusunom	IN	VARCHAR2,ptpcpath	IN	VARCHAR2,pcdelega	IN	NUMBER,pcprovin	IN	NUMBER,pcpoblac	IN	NUMBER,pcvistas	IN	NUMBER,pcweb	IN	NUMBER,prepserver	IN	VARCHAR2,pejecucion	IN	NUMBER,psperson	IN	NUMBER,pfbaja	IN	DATE,pctipusu	IN	NUMBER,pcagecob	IN	NUMBER,pcopcion	IN	NUMBER,ptpwd	IN	VARCHAR2,pfalta	IN	DATE,pcusubbdd	IN	VARCHAR2,pcautlog	IN	NUMBER,pcempleado	IN	VARCHAR2,pcterminal	IN	VARCHAR2,pcvispubli	IN	NUMBER,pmail_usu	IN	VARCHAR2,/* BUG 29965 - FAL - 07/02/2014*/ptelfusu	IN	VARCHAR2,punidept	IN	NUMBER,pcategprof	IN	NUMBER,mensajes	IN	OUT T_IAX_MENSAJES)
	RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='PAC_MD_USER.F_SET_USUARIO';
	  vparam      VARCHAR2(500):='parámetros - pcusuari: '
	                        || pcusuari;
	  vpasexec    NUMBER(5):=1;
	  vnumerr     NUMBER(8):=0;
	BEGIN
	    /*Comprovació de paràmetres d'entrada*/
	    IF pcusuari IS NULL  OR
	       pcidioma IS NULL  OR
	       pcempres IS NULL  OR
	       ptusunom IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    vnumerr:=pac_user.f_set_usuario(pcusuari, pcidioma, pcempres, ptusunom, ptpcpath, pcdelega, pcprovin, pcpoblac, pcvistas, pcweb, prepserver, pejecucion, psperson, pfbaja, pctipusu, pcagecob, pcopcion, ptpwd, pfalta, pcusubbdd, pcautlog, pcempleado, pcterminal, pcvispubli, pmail_usu, ptelfusu, punidept, pcategprof); /* BUG 29965 - FAL - 07/02/2014*/

	    IF vnumerr<>0 THEN
	      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);

	      RAISE e_object_error;
	    END IF;

	    /* bug 0010616: 02/07/2009 :ETM :IAX - Actualització de l'idioma del context al modificar l'idioma de l'usuari que està connectat.*/
	    IF upper(pac_md_common.f_get_cxtusuario)=upper(pcusuari) THEN
	      pac_md_common.p_set_cxtidioma(pcidioma);
	    END IF;

	    /* Fin bug 0010616: 02/07/2009 :ETM*/
	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

	             RETURN 1; WHEN e_object_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);

	             RETURN 1; WHEN OTHERS THEN
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
			mensajes	IN	OUT T_IAX_MENSAJES
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='PAC_MD_USER.F_DEL_USUARIO';
	  vparam      VARCHAR2(500):='parámetros - pusuario: '
	                        || pcusuari;
	  vpasexec    NUMBER(5):=1;
	  vnumerr     NUMBER(8):=0;
	BEGIN
	    /*Comprovació de paràmetres d'entrada*/
	    IF pcusuari IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    vnumerr:=pac_user.f_del_usuario(pcusuari);

	    IF vnumerr<>0 THEN
	      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);

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
	END f_del_usuario;

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
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='PAC_MD_USER.F_GET_USUARIO';
	  vparam      VARCHAR2(500):='parámetros - pcusuari: '
	                        || pcusuari;
	  vpasexec    NUMBER(5):=1;
	  vnumerr     NUMBER(8):=0;
	  vusuario    usuarios%ROWTYPE;
	  vtempres    VARCHAR2(200);
	  vtdelega    VARCHAR2(200);
	  vccfgwiz    VARCHAR2(200);
	  vccfgform   VARCHAR2(200);
	  vccfgacc    VARCHAR2(200);
	  vcrolmen    VARCHAR2(200);
	  vcconsupl   VARCHAR2(50);
	  vccfgdoc    VARCHAR2(200);
	  vcaccprod   VARCHAR2(200); /* BUG16471:DRA:26/10/2010*/
	  vccfgmap    VARCHAR2(200); /* BUG 21569 - 07/03/2012 - JMP*/
	  vcrol       VARCHAR2(50);
	  vareas       VARCHAR2(50);  -- IAXIS-4994    
	  vcusuagru   VARCHAR2(200); /*FAC Asociar nivel PSU al usuario*/
	  vcbloqueo   NUMBER:=0;
	  vfbloqueo   DATE;
	BEGIN
	    /*Comprovació de paràmetres d'entrada*/
	    IF pcusuari IS NULL THEN
	      RAISE e_param_error;
	    END IF;
        --IAXIS-4994
	    vnumerr:=pac_user.f_get_usuario(pcusuari, vusuario, vtempres, vtdelega, vccfgwiz, vccfgform, vccfgacc, vcrolmen, vcconsupl, vccfgdoc, vcaccprod, vccfgmap, vcrol,vareas, vcusuagru); /* BUG16471:DRA:26/10/2010*/

																																																			   

	    IF vnumerr<>0 THEN
	      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);

	      RAISE e_object_error;
	    END IF;

	    pusuario:=ob_iax_usuarios();

	    pusuario.cusuari:=vusuario.cusuari;

	    pusuario.cidioma:=vusuario.cidioma;

	    pusuario.cempres:=vusuario.cempres;

	    pusuario.tusunom:=vusuario.tusunom;

	    pusuario.cdelega:=vusuario.cdelega;

	    pusuario.ejecucion:=vusuario.ejecucion;

	    pusuario.sperson:=vusuario.sperson;

	    BEGIN
	        SELECT cbloqueo,fbloqueo
	          INTO vcbloqueo, vfbloqueo
	          FROM usuarios
	         WHERE cusuari=vusuario.cusuari;
	    EXCEPTION
	        WHEN no_data_found THEN
	          vcbloqueo:=0;

	          vfbloqueo:=NULL;
	    END;

	    IF vcbloqueo IS NOT NULL AND
	       vcbloqueo=1 THEN
	      pusuario.fbaja:=vfbloqueo;
	    ELSE
	      pusuario.fbaja:=vusuario.fbaja;
	    END IF;

	    pusuario.ctipusu:=vusuario.ctipusu;

	    pusuario.copcion:=vusuario.copcion;

	    pusuario.falta:=vusuario.falta;

	    pusuario.cempleado:=vusuario.cempleado;

	    pusuario.tempres:=vtempres;

	    pusuario.tdelega:=vtdelega;

	    pusuario.ccfgwiz:=vccfgwiz;

	    pusuario.ccfgform:=vccfgform;

	    pusuario.ccfgacc:=vccfgacc;

	    pusuario.crolmen:=vcrolmen;

	    pusuario.cconsupl:=vcconsupl;

	    pusuario.ccfgdoc:=vccfgdoc;

	    pusuario.cautlog:=vusuario.cautlog;

	    pusuario.caccprod:=vcaccprod; /* BUG16471:DRA:26/10/2010*/

	    pusuario.ccfgmap:=vccfgmap; /* BUG 21569 - 07/03/2012 - JMP*/

	    pusuario.cvispubli:=vusuario.cvispubli; /*BUG21653 - 14/03/2012 - JTS*/

	    pusuario.cvispubli:=vusuario.cvispubli; /*BUG21653 - 14/03/2012 - JTS*/

	    pusuario.crol:=vcrol;
        
        pusuario.ccfgmarca := vareas; --IAXIS-4994

	    pusuario.cusuagru:=vcusuagru;

	    pusuario.mail_usu:=vusuario.mail_usu; /* BUG 29965 - FAL - 07/02/2014*/

	    pusuario.telfusu:=vusuario.telfusu;

	    pusuario.unidept:=vusuario.unidept;

	    pusuario.categprof:=vusuario.categprof;

	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

	             RETURN 1; WHEN e_object_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);

	             RETURN 1; WHEN OTHERS THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);

	             RETURN 1;
	END f_get_usuario;

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
	) RETURN SYS_REFCURSOR
	IS
	  cur        SYS_REFCURSOR;
	  squery     VARCHAR2(2500);
	  subus      VARCHAR2(500);
	  tabtp      VARCHAR2(10);
	  auxnom     VARCHAR2(200);
	  nerr       NUMBER;
	  vobject    VARCHAR2(500):='PAC_MD_USER.F_Consulta_Usuario';
	  vparam     VARCHAR2(500):='parámetros - pUser:'
	                        || puser
	                        || ' pcempres:'
	                        || pcempres
	                        || ' ptUsername:'
	                        || ptusername
	                        || ' pcDelega:'
	                        || pcdelega;
	  vpasexec   NUMBER(5):=1;
	  vselec     VARCHAR2(500);
	  pcidioma   NUMBER:=pac_md_common.f_get_cxtidioma();
	  vtusername VARCHAR2(1000); /* BUG 38344/217178 - 29/10/2015 - ACL*/
	BEGIN
	    /*  squery := pac_user.ff_consulta_usuarios(pcempres, puser, ptusername, pcdelega,
	                                              pac_md_common.f_get_cxtidioma());
	      */
	    vpasexec:=2;

	    vselec:='select u.cusuari,u.tusunom,i.TIDIOMA,u.CEMPLEADO,
		                   PAC_REDCOMERCIAL.ff_desagente (a.cagente, '
	            || pcidioma
	            || ', 2) cdelega,
		                   FF_DESVALORFIJO(862,'
	            || pcidioma
	            || ',decode(u.fbaja,null, decode(u.fbloqueo,null,1,3),2)) testado'
	            || ' from usuarios u, idiomas i,agentes a'
	            || ' where i.cidioma = u.cidioma '
	            || '   and u.CDELEGA = a.CAGENTE '
	            || '   and u.cempres = '
	            || pcempres;

	    IF ptusername IS NOT NULL THEN
	      /* Inicio BUG 38344/217178 - 29/10/2015 - ACL*/
	      vtusername:=ptusername;

	      vtusername:=replace(vtusername, chr(39), chr(39)
	                                               || chr(39));

	      vselec:=vselec
	              || ' AND upper(u.tusunom) like ''%'
	              || upper(vtusername)
	              || '%''';
	    /* Fin BUG 38344/217178 - 29/10/2015 - ACL*/
	    END IF;

	    IF puser IS NOT NULL THEN
	      vselec:=vselec
	              || ' AND upper(u.cusuari) like ''%'
	              || upper(puser)
	              || '%''';
	    END IF;

	    IF pcdelega IS NOT NULL THEN
	      vselec:=vselec
	              || ' and u.cdelega = '
	              || pcdelega;
	    END IF;

	    cur:=pac_md_listvalores.f_opencursor(vselec, mensajes);

	    IF cur IS NULL THEN
	      p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'cursor vacio');
	    END IF;

	    vpasexec:=3;

	    IF pac_md_log.f_log_consultas(vselec, vobject, 1, 2, mensajes)<>0 THEN
	      p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'cierra cursor');

	      IF cur%isopen THEN
	        CLOSE cur;
	      END IF;

	      RETURN cur;
	    END IF;

	    vpasexec:=4;

	    RETURN cur;
	EXCEPTION
	  WHEN e_param_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

	             IF cur%isopen THEN
	               CLOSE cur;
	             END IF;

	             RETURN cur; WHEN e_object_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

	             IF cur%isopen THEN
	               CLOSE cur;
	             END IF;

	             RETURN cur; WHEN OTHERS THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, psqcode=>SQLCODE, psqerrm=>SQLERRM);

	             IF cur%isopen THEN
	               CLOSE cur;
	             END IF;

	             RETURN cur;
	END f_consulta_usuario;

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
	) RETURN NUMBER
	IS
	  vobjectname   VARCHAR2(500):='PAC_MD_USER.F_VALIDATE_PWD';
	  vparam        VARCHAR2(500):='parámetros - pusuario:'
	                        || pusuario
	                        || ' pOldPwd:'
	                        || poldpwd
	                        || ' pNewPwd:'
	                        || pnewpwd
	                        || ' pmodo:'
	                        || pmodo;
	  vpasexec      NUMBER(5):=1;
	  vnumerr       NUMBER(8):=0;
	  vpasslong     NUMBER(5):=nvl(pac_md_common.f_get_parconexion('LONGPASS'), 0);
	  vmismopassusu NUMBER(5):=nvl(pac_md_common.f_get_parconexion('PASSIGUUSU'), 0);
	  vmenserr      VARCHAR2(250);
	  vnewpwdenc    VARCHAR2(100);
	  vvalidate     NUMBER;
	BEGIN
	    IF pmodo='MODIF' THEN -- Canvi pwd
	      /*Comprovació de paràmetres d'entrada*/
	      IF pusuario IS NULL  OR
	         pnewpwd IS NULL THEN
	        RAISE e_param_error;
	      END IF;

	      vpasexec:=3;

	      vpasexec:=4;

	      /*Comprovem la longitud del nou password*/
	      IF length(pnewpwd)<vpasslong THEN
	        pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 180138, pac_iobj_mensajes.f_get_descmensaje(180138, pac_md_common.f_get_cxtidioma())
	                                                                   || vpasslong);

	        RAISE e_object_error;
	      END IF;

	      vpasexec:=5;

	      /*Miramos si permite el pusuario como passwd. Sino permite validamos que sea correcto.*/
	      IF vmismopassusu=0 THEN
	        /*Comprovem que el nou password no sigui igual al nom d'usuari*/
	        IF upper(pusuario)=upper(pnewpwd) THEN
	          pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 180139);

	          RAISE e_object_error;
	        END IF;
	      END IF;

	      vpasexec:=6;

	      /*Comprovem que el nou password no estigui repetit*/
	      IF f_comppass(pusuario, pnewpwd)=1 THEN
	        pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 180140, replace(pac_iobj_mensajes.f_get_descmensaje(180140, pac_md_common.f_get_cxtidioma()), '$$', pac_md_common.f_get_parconexion('PASSDIFER')));

	        RAISE e_object_error;
	      END IF;
	    ELSE /* Nou pwd*/
	      /*Comprovació de paràmetres d'entrada*/
	      IF pusuario IS NULL  OR
	         pnewpwd IS NULL THEN
	        RAISE e_param_error;
	      END IF;

	      vpasexec:=3;

	      /*Comprovem la longitud del nou password*/
	      IF length(pnewpwd)<vpasslong THEN
	        pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 180138, pac_iobj_mensajes.f_get_descmensaje(180138, pac_md_common.f_get_cxtidioma())
	                                                                   || vpasslong);

	        RAISE e_object_error;
	      END IF;

	      vpasexec:=4;

	      /*Miramos si permite el pusuario como passwd. Sino permite validamos que sea correcto.*/
	      IF vmismopassusu=0 THEN
	        /*Comprovem que el nou password no sigui igual al nom d'usuari*/
	        IF upper(pusuario)=upper(pnewpwd) THEN
	          pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 180139);

	          RAISE e_object_error;
	        END IF;
	      END IF;

	      vpasexec:=5;

	      /*Comprovem que el nou password no estigui repetit*/
	      IF f_comppass(pusuario, pnewpwd)=1 THEN
	        pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 180140, replace(pac_iobj_mensajes.f_get_descmensaje(180140, pac_md_common.f_get_cxtidioma()), '$$', pac_md_common.f_get_parconexion('PASSDIFER')));

	        RAISE e_object_error;
	      END IF;
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
	END f_validate_pwd;

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
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='pac_md_user.f_activar_usuario';
	  vparam      VARCHAR2(500):='parámetros - pusuario:'
	                        || pcusuari;
	  vpasexec    NUMBER(5):=1;
	  vnumerr     NUMBER(8):=0;
	BEGIN
	    /*Comprovació de paràmetres d'entrada*/
	    IF pcusuari IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    vnumerr:=pac_user.f_activar_usuario(pcusuari);

	    IF vnumerr<>0 THEN
	      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);

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
	END f_activar_usuario;

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
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='PAC_MD_USER.f_set_termfisic';
	  vparam      VARCHAR2(500):='parámetros - pusuario: '
	                        || pusuario
	                        || ' pctermfisic:'
	                        || pctermfisic;
	  vpasexec    NUMBER(5):=1;
	  vnumerr     NUMBER(8):=0;
	BEGIN
	    /*Comprovació de paràmetres d'entrada*/
	    IF pusuario IS NULL  OR
	       pctermfisic IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    /*Actualitzem el terminal fisic*/
	    vnumerr:=pac_user.f_set_termfisic(pusuario, pctermfisic);

	    IF vnumerr<>0 THEN
	      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);

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
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='PAC_MD_USER.f_get_termfisic';
	  vparam      VARCHAR2(500):='parámetros - pusuario: '
	                        || pusuario;
	  vpasexec    NUMBER(5):=1;
	  vnumerr     NUMBER(8):=0;
	BEGIN
	    /*Comprovació de paràmetres d'entrada*/
	    IF pusuario IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    /*Obtenim el terminal fisic*/
	    vnumerr:=pac_user.f_get_termfisic(pusuario, pctermfisic);

	    IF vnumerr<>0 THEN
	      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);

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
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='PAC_MD_USER.F_GET_USUARIO_vision';
	  vparam      VARCHAR2(500):='parámetros - pcusuari: '
	                        || pcusuari;
	  vpasexec    NUMBER(5):=1;
	  vnumerr     NUMBER(8):=0;
	  vusuario    OB_IAX_USERS:=ob_iax_users();
	  vcusuari    VARCHAR2(20);

	  CURSOR c_usu_vision IS
	    SELECT d.cusuari
	      FROM usuarios d,agentes a,per_personas per
	     WHERE d.cdelega=a.cagente AND
	           a.sperson=per.sperson AND
	           (pcusuari IS NULL  OR
	            d.cusuari=pcusuari) AND
	           (pnomusuario IS NULL  OR
	            upper(tusunom) LIKE upper('%'
	                                      || pnomusuario
	                                      || '%')) AND
	           d.cdelega IN(SELECT cagente
	                          FROM redcomercial
	                         WHERE cempres=pac_md_common.f_get_cxtempresa) AND
	           ((per.swpubli=1)  OR
	            (per.swpubli=0 AND
	             d.cdelega IN(SELECT r.cagente
	                            FROM redcomercial r
	                           WHERE fmovfin IS NULL AND
	                                 cempres=pac_md_common.f_get_cxtempresa AND
	                                 LEVEL=decode (ff_agente_cpernivel(pac_md_common.f_get_cxtagente), 1, LEVEL,
	                                                                                                   1)
	                          START WITH cagente=ff_agente_cpervisio(pac_md_common.f_get_cxtagente)
	                          CONNECT BY PRIOR cagente=cpadre AND
	                                           PRIOR fmovfin IS NULL)));
	BEGIN
	    ptusuario:=t_iax_users();

	    FOR reg IN c_usu_vision LOOP
	        vusuario:=pac_md_user.f_get_datuser(reg.cusuari, mensajes);

	        ptusuario.extend;

	        ptusuario(ptusuario.last):=vusuario;
	    END LOOP;

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
			mensajes	IN	OUT T_IAX_MENSAJES
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='PAC_MD_USER.f_val_cambio_paswd';
	  vparam      VARCHAR2(500):='parámetros - pcusuari: '
	                        || puser;
	  vpasexec    NUMBER(5):=1;
	  vnumerr     NUMBER(8):=0;
	  vusuario    OB_IAX_USERS:=ob_iax_users();
	  vcusuari    VARCHAR2(20);
	  vdias       NUMBER:=0;
	BEGIN
	    vnumerr:=pac_user.f_val_cambio_paswd(puser, vdias);

	    IF vnumerr<>0 THEN
	      pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 2, vnumerr, replace(pac_iobj_mensajes.f_get_descmensaje(vnumerr, pac_md_common.f_get_cxtidioma()), '$$', vdias));

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
	FUNCTION f_useractivo(
			pusuario	IN	VARCHAR2,
			pactivo	OUT	NUMBER,
			mensajes	IN	OUT T_IAX_MENSAJES
	) RETURN NUMBER
	IS
	  vobject  VARCHAR2(500):='PAC_MD_USER.f_useractivo';
	  vparam   VARCHAR2(500):='parámetros - pusuario: '
	                        || pusuario;
	  vpasexec NUMBER(5):=1;
	  vnumerr  NUMBER(8):=0;
	  vactivo  NUMBER;
	BEGIN
	    /*Comprovació de paràmetres d'entrada*/
	    IF pusuario IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    vpasexec:=3;

	    vnumerr:=pac_user.f_useractivo(pusuario, vactivo);

	    IF vnumerr<>0 THEN
	      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);

	      RAISE e_object_error;
	    END IF;

	    pactivo:=vactivo;

	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

	             RETURN 1; WHEN e_object_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

	             RETURN 1; WHEN OTHERS THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, psqcode=>SQLCODE, psqerrm=>SQLERRM);

	             RETURN 1;
	END f_useractivo;
	FUNCTION f_get_usuarios(
			puser	IN	usuarios.cusuari%TYPE,
			pusername	IN	usuarios.tusunom%TYPE,
			tusers	OUT	T_IAX_USERS,
			mensajes	OUT	T_IAX_MENSAJES
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='PAC_MD_USER.f_get_usuarios';
	  vparam      VARCHAR2(500):='parmetros - pcusuari: '
	                        || puser
	                        || ' pusername '
	                        || pusername;
	  vpasexec    NUMBER(5):=1;
	  vnumerr     NUMBER(8):=0;
	  /**/
	  obuser      OB_IAX_USERS;
	  /**/
	  users_src   SYS_REFCURSOR;
	  /**/
	  sql_stmt    VARCHAR2(4000);
	  vcusuari    usuarios.cusuari%TYPE;
	  vtusunom    usuarios.tusunom%TYPE;
	  vtagente    VARCHAR2(200);
	/**/
	BEGIN
	    /**/
	    IF puser IS NOT NULL AND
	       pusername IS NOT NULL THEN
	      /**/
	      sql_stmt:='SELECT cusuari ,tusunom ,PAC_REDCOMERCIAL.ff_desagente(cdelega, pac_md_common.f_get_cxtidioma(), 2) tagente '
	                || '   FROM usuarios '
	                || '  WHERE UPPER(tusunom) like ''%'
	                || upper(pusername)
	                || '%'' OR '
	                || '        UPPER(cusuari) like ''%'
	                || upper(puser)
	                || '%'' '
	                || '  ORDER BY cusuari ASC';
	    /**/
	    ELSIF puser IS NOT NULL AND
	          pusername IS NULL THEN
	      /**/
	      sql_stmt:='SELECT cusuari ,tusunom ,PAC_REDCOMERCIAL.ff_desagente(cdelega, pac_md_common.f_get_cxtidioma(), 2) tagente '
	                || '  FROM usuarios '
	                || ' WHERE UPPER(cusuari) like ''%'
	                || upper(puser)
	                || '%'' '
	                || ' ORDER BY cusuari ASC';
	    /**/
	    ELSIF puser IS NULL AND
	          pusername IS NOT NULL THEN
	      /**/
	      sql_stmt:='SELECT cusuari ,tusunom ,PAC_REDCOMERCIAL.ff_desagente(cdelega, pac_md_common.f_get_cxtidioma(), 2) tagente '
	                || ' FROM usuarios '
	                || ' WHERE UPPER(tusunom) like ''%'
	                || upper(pusername)
	                || '%'' '
	                || ' ORDER BY cusuari ASC';
	    /**/
	    ELSE
	      /**/
	      sql_stmt:='SELECT cusuari ,tusunom ,PAC_REDCOMERCIAL.ff_desagente(cdelega, pac_md_common.f_get_cxtidioma(), 2) tagente '
	                || ' FROM usuarios '
	                || ' ORDER BY cusuari ASC';
	    /**/
	    END IF;

	    /**/
	    tusers:=t_iax_users();

	    /**/
	    OPEN users_src FOR sql_stmt;

	    /**/
	    LOOP
	        FETCH users_src INTO vcusuari, vtusunom, vtagente;

	        /**/
	        EXIT WHEN users_src%NOTFOUND;

	        /**/
	        obuser:=ob_iax_users();

	        obuser.cusuari:=vcusuari;

	        obuser.nombre:=vtusunom;

	        obuser.tagente:=vtagente;

	        /**/
	        tusers.extend;

	        tusers(tusers.last):=obuser;
	    /**/
	    END LOOP;

	    CLOSE users_src;

	    /**/
	    RETURN vnumerr;
	EXCEPTION
	  WHEN e_object_error THEN
	             /**/
	             IF users_src%isopen THEN
	               CLOSE users_src;
	             END IF;

	             /**/
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);

	             RETURN 1; WHEN OTHERS THEN
	             /**/
	             IF users_src%isopen THEN
	               CLOSE users_src;
	             END IF;

	             /**/
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);

	             RETURN 1;
	END f_get_usuarios;

END pac_md_user;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_USER" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_USER" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_USER" TO "PROGRAMADORESCSI";
