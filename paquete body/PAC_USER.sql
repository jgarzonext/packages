--------------------------------------------------------
--  DDL for Package Body PAC_USER
--------------------------------------------------------
CREATE OR REPLACE PACKAGE BODY pac_user AS


   /******************************************************************************
      NOMBRE:      PAC_USER
      PROPÓSITO:   Funciones para validar el usuario
      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        24/01/2008   JAS                1. Creación del package.
      9.0        30/03/2009   DCT                9. Modificación f_get_usuario
     10.0        23/10/2009   JTS               10. 11404: CEM003 - Plantillas del producto
     11.0        26/10/2010   DRA               11. 16471: CRT - Configuracion de visibilidad/contratacion de productos a nivel de perfil
     12.0        22/11/2010   JAS               12. 13266: CIVF001 - Modificación interfases apertura y cierre de puesto (parte PL)
     13.0        07/03/2012   JMP               13. 21569: CRE998 - Configurar llençador d'Informes per perfil
     14.0        22/10/2013   FAC               14. 28627: Agregar al mantenimiento de Usuario la asignación de nivel de psu
     15.0        10/02/2014   ETM               15.validar que el usuario no este dado de baja
     16.0        21/02/2014   FAL               16. 0029965: RSA702 - GAPS renovación
     17.0        14/03/2014   JLTS              17. 30417_0169644_QT-0011827: Se cambia el literal 104631 (Error al leer de la tabla USUARIOS) por 9906626 (Error de validación)
                                                  además se cambia el literal 9906488 por 9906626
     16.0        03/08/2019   JMJRR             16. IAXIS-4994 se modifican parametros de entrada y se ajusta proceso de persistencia y consulta de usuarios
   ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*************************************************************************
         Modifica la clave de acceso de un determinado usuario.
      param in pUser   : código de usuario
      param in pNewPwd : nueva clave de acceso
      return           : 1 indica que existe
                         0 no existe
   *************************************************************************/

	FUNCTION f_update_userpwd(
			puser	IN	VARCHAR2,
			pnewpwd	IN	VARCHAR2
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='PAC_USER.F_Update_UserPwd';
	  vparam      VARCHAR2(500):='parámetros - pUser: '
	                        || puser;
	  vpasexec    NUMBER(5):=1;
	  vnumerr     NUMBER(8):=0;
	  vnewpwdenc  VARCHAR2(100);
	  vcount      NUMBER;
	  vcambiapass NUMBER:=nvl(pac_md_common.f_get_parconexion('CAMBPASS'), 0);
	  vnum_err    NUMBER;
	BEGIN
	    /*Comprovació de paràmetres d'entrada*/
	    IF puser IS NULL  OR
	       pnewpwd IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    vpasexec:=3;

	    /*Encriptació de la clau.*/
	    vnewpwdenc:=dbms_obfuscation_toolkit.desencrypt(input=>utl_raw.cast_to_raw(rpad(pnewpwd, 32, ' ')), KEY=>utl_raw.cast_to_raw(upper(rpad(puser, 32, ' '))));

	    vpasexec:=5;

	    /*Modificació de la clau.*/
	    UPDATE usuarios
	       SET tpwd=vnewpwdenc
	     WHERE upper(cusuari)=upper(puser);

	    p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'pac_md_common.f_get_cxtusuario'
	                                                                  || pac_md_common.f_get_cxtusuario
	                                                                  || ' UPPER(puser) '
	                                                                  || upper(puser)
	                                                                  || ' vcambiapass '
	                                                                  || vcambiapass);

	    /* Ini: Bug 36663/209495 - JR*/
	    IF vcambiapass=1 THEN
	      IF pac_md_common.f_get_cxtusuario<>upper(puser) THEN
	        vnum_err:=pac_user.f_set_cambia_pass(upper(puser), 1);
	      ELSE
	        vnum_err:=pac_user.f_set_cambia_pass(upper(puser), 0);
	      END IF;

	      IF vnum_err<>0 THEN
	        RETURN vnum_err;
	      END IF;
	    END IF;

	    /* Fin: Bug 36663/209495 - JR*/
	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'Objeto invocado con parámetros erroneos');

	             RETURN 102241; /*Error al modificar a la taula USUARIOS.*/
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'SQLERROR: '
	                                                                           || SQLCODE
	                                                                           || ' - '
	                                                                           || SQLERRM);

	             RETURN 102241; /*Error al modificar a la taula USUARIOS.*/
	END;

	/*************************************************************************
	                          Inserta en el histórico de usuario.
	   param in pUser   : código de usuario
	   param in pNewPwd : clave de acceso
	   return           : 1 indica que existe
	                      0 no existe
	*************************************************************************/
	FUNCTION f_insert_usuario_his(
			puser	IN	VARCHAR2,
			pnewpwd	IN	VARCHAR2
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='PAC_USER.F_Insert_Usuario_His';
	  vparam      VARCHAR2(500):='parámetros - pUser: '
	                        || puser;
	  vpasexec    NUMBER(5):=1;
	  vnumerr     NUMBER(8):=0;
	  vnewpwdenc  VARCHAR2(100);
	BEGIN
	    /*Comprovació de paràmetres d'entrada*/
	    IF puser IS NULL  OR
	       pnewpwd IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    vpasexec:=3;

	    /*Encriptació de la clau.*/
	    vnewpwdenc:=dbms_obfuscation_toolkit.desencrypt(input=>utl_raw.cast_to_raw(rpad(pnewpwd, 32, ' ')), KEY=>utl_raw.cast_to_raw(upper(rpad(puser, 32, ' '))));

	    vpasexec:=5;

			INSERT INTO usuarios_his_pass
		           (cusuari,fcambio,tpwd)
		    VALUES
		           (upper(puser),f_sysdate,vnewpwdenc);


	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'Objeto invocado con parámetros erroneos');

	             RETURN 103196; --Error a l'inserir a la taula USUARIOS.
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'SQLERROR: '
	                                                                           || SQLCODE
	                                                                           || ' - '
	                                                                           || SQLERRM);

	             RETURN 103196; --Error a l'inserir a la taula USUARIOS.
	END;

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
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='PAC_USER.F_Get_Password';
	  vparam      VARCHAR2(500):='parámetros - pUser: '
	                        || puser;
	  vpasexec    NUMBER(5):=1;
	  vnumerr     NUMBER(8):=0;
	  vnewpwdenc  VARCHAR2(100);
	BEGIN
	    /*Comprovació de paràmetres d'entrada*/
	    IF puser IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    vpasexec:=3;

	    SELECT tpwd
	      INTO ppwd
	      FROM usuarios
	     WHERE upper(cusuari)=upper(puser);

	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'Objeto invocado con parámetros erroneos');

	             RETURN 9906626; /*Error de validación*/
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'SQLERROR: '
	                                                                           || SQLCODE
	                                                                           || ' - '
	                                                                           || SQLERRM);

	             RETURN 9906626; /*Error de validación*/
	END;

	/*************************************************************************
	                          Obtiene el empleado de un usuario
	   param in pUser   : código de usuario
	   return           : 1 indica que existe
	                      0 no existe
	*************************************************************************/
	FUNCTION f_get_empleado(
			puser	IN	usuarios.cusuari%TYPE,
			pcempleado	OUT	usuarios.cempleado%TYPE
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='PAC_USER.F_Get_Empleado';
	  vparam      VARCHAR2(500):='parámetros - puser: '
	                        || puser;
	  vpasexec    NUMBER(5):=1;
	  vnumerr     NUMBER(8):=0;
	BEGIN
	    /*Comprovació de paràmetres d'entrada*/
	    IF puser IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    vpasexec:=3;

	    SELECT u.cempleado
	      INTO pcempleado
	      FROM usuarios u
	     WHERE upper(u.cusuari)=upper(puser);

	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'Objeto invocado con parámetros erroneos');

	             RETURN 9906626; /*Error de validación*/
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'SQLERROR: '
	                                                                           || SQLCODE
	                                                                           || ' - '
	                                                                           || SQLERRM);

	             RETURN 9906626; /*Error de validación*/
	END;

	/***********************************************************************
	                          Recupera un empleado
	   param in pcusuari : Codigo del usuario.
	   return            : empleado
	***********************************************************************/
	FUNCTION ff_get_empleado(
			pcusuari	IN	VARCHAR2
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='PAC_USER.FF_GET_EMPLEADO';
	  vparam      VARCHAR2(500):='parámetros - pusuario: '
	                        || pcusuari;
	  vpasexec    NUMBER(5):=1;
	  vempleado   NUMBER;
	  vnum_err    NUMBER;
	BEGIN
	    /*Comprovació dels parámetres d'entrada*/
	    IF pcusuari IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    vnum_err:=f_get_empleado(pcusuari, vempleado);

	    IF vnum_err<>0 THEN
	      RETURN NULL;
	    END IF;

	    RETURN vempleado;
	EXCEPTION
	  WHEN e_param_error THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'Objeto invocado con parámetros erroneos');

	             RETURN NULL; WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'SQLERROR: '
	                                                                           || SQLCODE
	                                                                           || ' - '
	                                                                           || SQLERRM);

	             RETURN NULL;
	END ff_get_empleado;

	/*************************************************************************
	         Obtiene el terminal de un usuario
	   param in pUser   : código de usuario
	   return           : 1 indica que existe
	                      0 no existe
	*************************************************************************/
	FUNCTION f_get_terminal(
			puser	IN	usuarios.cusuari%TYPE,
			pcterminal	OUT	usuarios.cterminal%TYPE
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='PAC_USER.F_Get_Terminal';
	  vparam      VARCHAR2(500):='parámetros - puser: '
	                        || puser;
	  vpasexec    NUMBER(5):=1;
	  vnumerr     NUMBER(8):=0;
	BEGIN
	    /*Comprovació de paràmetres d'entrada*/
	    IF puser IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    vpasexec:=3;

	    SELECT u.cterminal
	      INTO pcterminal
	      FROM usuarios u
	     WHERE upper(u.cusuari)=upper(puser);

	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'Objeto invocado con parámetros erroneos');

	             RETURN 9906626; /*Error de validación*/
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'SQLERROR: '
	                                                                           || SQLCODE
	                                                                           || ' - '
	                                                                           || SQLERRM);

	             RETURN 9906626; /*Error de validación*/
	END;

	/***********************************************************************
	                          Recupera un terminal
	   param in pcusuari : Codigo del usuario.
	   return            : terminal
	***********************************************************************/
	FUNCTION ff_get_terminal(
			pcusuari	IN	VARCHAR2
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='PAC_USER.FF_GET_TERMINAL';
	  vparam      VARCHAR2(500):='parámetros - pusuario: '
	                        || pcusuari;
	  vpasexec    NUMBER(5):=1;
	  vterminal   NUMBER;
	  vnum_err    NUMBER;
	BEGIN
	    /*Comprovació dels parámetres d'entrada*/
	    IF pcusuari IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    vnum_err:=f_get_terminal(pcusuari, vterminal);

	    IF vnum_err<>0 THEN
	      RETURN NULL;
	    END IF;

	    RETURN vterminal;
	EXCEPTION
	  WHEN e_param_error THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'Objeto invocado con parámetros erroneos');

	             RETURN NULL; WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'SQLERROR: '
	                                                                           || SQLCODE
	                                                                           || ' - '
	                                                                           || SQLERRM);

	             RETURN NULL;
	END ff_get_terminal;

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
	) RETURN NUMBER
	IS
	  PRAGMA autonomous_transaction;
	  vobjectname VARCHAR2(500):='PAC_USER.F_Set_Terminal';
	  vparam      VARCHAR2(500):='parámetros - pUser: '
	                        || puser
	                        || ' pterminal:'
	                        || pterminal;
	  vpasexec    NUMBER(5):=1;
	  vnumerr     NUMBER(8):=0;
	BEGIN
	    /*Comprovació de paràmetres d'entrada*/
	    IF puser IS NULL  OR
	       pterminal IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    UPDATE usuarios
	       SET cterminal=pterminal
	     WHERE upper(cusuari)=upper(puser);

	    COMMIT;

	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'Objeto invocado con parámetros erroneos');

	             RETURN 103196; --Error a l'inserir a la taula USUARIOS.
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'SQLERROR: '
	                                                                           || SQLCODE
	                                                                           || ' - '
	                                                                           || SQLERRM);

	             RETURN 103196; --Error a l'inserir a la taula USUARIOS.
	END f_set_terminal;

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
	) RETURN NUMBER
	IS
	  PRAGMA autonomous_transaction;
	  vobjectname VARCHAR2(500):='PAC_USER.F_Set_Agente';
	  vparam      VARCHAR2(500):='parámetros - pUser: '
	                        || puser
	                        || ' pcagente:'
	                        || pcagente;
	  vpasexec    NUMBER(5):=1;
	  vnumerr     NUMBER(8):=0;
	BEGIN
	    /*Comprovació de paràmetres d'entrada*/
	    IF puser IS NULL  OR
	       pcagente IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    UPDATE usuarios
	       SET cdelega=pcagente
	     WHERE upper(cusuari)=upper(puser);

	    COMMIT;

	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'Objeto invocado con parámetros erroneos');

	             RETURN 103196; --Error a l'inserir a la taula USUARIOS.
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'SQLERROR: '
	                                                                           || SQLCODE
	                                                                           || ' - '
	                                                                           || SQLERRM);

	             RETURN 103196; --Error a l'inserir a la taula USUARIOS.
	END f_set_agente;

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
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='PAC_USER.F_ExistUser';
	  vparam      VARCHAR2(500):='parámetros - pusuario: '
	                        || pusuario;
	  vpasexec    NUMBER(5):=1;
	  vnumerr     NUMBER(8):=0;
	BEGIN
	    /*Comprovació de paràmetres d'entrada*/
	    IF pusuario IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    vpasexec:=3;

	    SELECT decode(count(*), 0, 0,
	                            1)
	      INTO pexiste
	      FROM usuarios u
	     WHERE upper(u.cusuari)=upper(pusuario);

	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'Objeto invocado con parámetros erroneos');

	             RETURN 9000505; WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'SQLERROR: '
	                                                                           || SQLCODE
	                                                                           || ' - '
	                                                                           || SQLERRM);

	             RETURN 9906626;
	END f_existuser;
  -- INI IAXIS-3288 - JLTS - Se crea esta función para obtener el nombre del usuario
  /*************************************************************************
   Devuelve el nombre del usuario
   param in cusuari : código de usuario
   return: nombre del usuario
  *************************************************************************/
  FUNCTION f_nomuser(
      pcusuari  IN  USUARIOS.CUSUARI%TYPE
  ) RETURN VARCHAR2
  IS
    vobjectname VARCHAR2(500):='PAC_USER.f_nomuser';
    vparam      VARCHAR2(500):='parámetros - pcusuari: '
                          || pcusuari;
    vpasexec    NUMBER(5):=1;
		v_usunom    usuarios.tusunom%TYPE;
    vnumerr     NUMBER(8):=0;
  BEGIN
      /*Comprobación de parámetros de entrada*/
      IF pcusuari IS NULL THEN
        RAISE e_param_error;
      END IF;

      vpasexec:=3;

      SELECT u.tusunom
        INTO v_usunom
        FROM usuarios u
       WHERE upper(u.cusuari)=upper(pcusuari);

      RETURN v_usunom;
  EXCEPTION
    WHEN e_param_error THEN
               p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'Objeto invocado con parámetros erroneos');

               RETURN 9000505; WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'SQLERROR: '
                                                                             || SQLCODE
                                                                             || ' - '
                                                                             || SQLERRM);

               RETURN 9906626;
  END f_nomuser;
	-- FIN IAXIS-3288 - JLTS - Se crea esta función para obtener el nombre del usuario

	/*************************************************************************
	         Comprueba que un usuario tenga activada la opción de autologin
	   param in usuario : código de usuario
	   param out pvcautlog : 1 indica que es usuario autologin
	                         0 no es usuario autologin
	*************************************************************************/
	FUNCTION f_isautologinuser(
			pusuario	IN	VARCHAR2,
			pvcautlog	OUT	NUMBER
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='PAC_USER.F_isAutologinUser';
	  vparam      VARCHAR2(500):='parámetros - pusuario: '
	                        || pusuario;
	  vpasexec    NUMBER(5):=1;
	  vnumerr     NUMBER(8):=0;
	  vcautlog    NUMBER(1);
	BEGIN
	    /*Comprovació de paràmetres d'entrada*/
	    IF pusuario IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    vpasexec:=3;

	    SELECT nvl(u.cautlog, 0)
	      INTO pvcautlog
	      FROM usuarios u
	     WHERE upper(u.cusuari)=upper(pusuario);

	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'Objeto invocado con parámetros erroneos');

	             RETURN 9000505; WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'SQLERROR: '
	                                                                           || SQLCODE
	                                                                           || ' - '
	                                                                           || SQLERRM);

	             RETURN 9906626;
	END f_isautologinuser;

	/*************************************************************************
	         Validación de usuario y contraseña
	   param in usuario  : usuario que se indica en la pantalla
	   param in pwd      : constraseña que se ha indicado
	   param out pvalidation : 0 indica el usuario es correcto
	                           1 usuario no valido
	                           2 contraseña incorrecta
	*************************************************************************/
	FUNCTION f_validateuser(
			pusuario	IN	VARCHAR2,
			ppwd	IN	VARCHAR2,
			pvalidation	OUT	NUMBER,
			pintentos	OUT	NUMBER
	) RETURN NUMBER
	IS
	  vobjectname  VARCHAR2(500):='PAC_USER.F_ValidateUser';
	  vparam       VARCHAR2(500):='parámetros - pusuario: '
	                        || pusuario
	                        || '-'
	                        || ppwd;
	  vpasexec     NUMBER(5):=1;
	  vpassdifer   NUMBER(5):=nvl(pac_md_common.f_get_parconexion('DIASCAMBIO'), 0);
	  vnumerr      NUMBER(8):=0;
	  vtpwd        VARCHAR2(100);
	  vvalpaswd    NUMBER:=0;
	  vfconok      DATE;
	  vaccesoko    NUMBER;
	  vintentos    NUMBER;
	  vfechacaduca DATE;
	  vfcambio     DATE;
	BEGIN
	    /*Comprovació de paràmetres d'entrada*/
	    IF pusuario IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    vpasexec:=3;

	    vtpwd:=dbms_obfuscation_toolkit.desencrypt (input=>utl_raw.cast_to_raw(rpad(ppwd, 32, ' ')), KEY=>utl_raw.cast_to_raw(rpad(upper(pusuario), 32, ' ')));

	    vpasexec:=5;

	    SELECT decode(count(*), 0, 0,
	                            1)
	      INTO pvalidation
	      FROM usuarios u
	     WHERE upper(u.cusuari)=upper(pusuario) AND
	           u.tpwd=vtpwd AND
	           u.fbaja IS NULL AND
	           (u.cbloqueo IS NULL  OR
	            u.cbloqueo!=1);

	    vpasexec:=6;

	    /*O el usuario no existe o la contraseña es incorrecta*/
	    IF pvalidation=0 THEN
	      SELECT count(1)
	        INTO vvalpaswd
	        FROM usuarios u
	       WHERE upper(u.cusuari)=upper(pusuario);

	      vpasexec:=7;

	      IF vvalpaswd>0 THEN
	        SELECT count(1)
	          INTO vvalpaswd
	          FROM usuarios u
	         WHERE upper(u.cusuari)=upper(pusuario) AND
	               u.cbloqueo=1;

	        vpasexec:=8;

	        vintentos:=nvl(pac_md_common.f_get_parconexion('INTENTOS'), 0);

	        /*Miramos si el usuario ha sido bloqueado*/
	        IF vvalpaswd>0 THEN
	          pvalidation:=4;

	          pintentos:=vintentos;

	          RETURN 0;
	        END IF;

	        vpasexec:=9;

	      /*Usuario activo pero se ha introducido la contraseña incorrecta*/
	      /*vamos a mirar los últimos accesos*/
	        /*Miramos ultima fecha correcta logado*/
	        SELECT nvl(max(to_date(to_char(fconexion, 'DD/MM/YYYY hh24:mi:ss'), 'DD/MM/YYYY hh24:mi:ss')), to_date('01/01/2000', 'DD/MM/YYYY'))
	          INTO vfconok
	          FROM log_conexion u
	         WHERE upper(u.cusuari)=upper(pusuario) AND
	               cestcon=1;

	        vpasexec:=10;

	        p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, 'FOK', vfconok);

	        /*Miramos cuantos intentos del usuario entre la fecha OK y el día de hoy*/
	        SELECT count(1)
	          INTO vaccesoko
	          FROM log_conexion
	         WHERE upper(cusuari)=upper(pusuario) AND
	               cestcon=2 AND
	               to_date(to_char(fconexion, 'DD/MM/YYYY hh24:mi:ss'), 'DD/MM/YYYY hh24:mi:ss') BETWEEN vfconok AND to_date (to_char(f_sysdate, 'DD/MM/YYYY hh24:mi:ss'), 'DD/MM/YYYY hh24:mi:ss');

	        vaccesoko:=vaccesoko+1; /*contamos el acceso actual como incorrecto*/

	        vpasexec:=11;

	        /*Si el número de intentos KO supera el numero máximo marcado por el cliente bloqueamos el usuario*/
	        IF vintentos>0 AND
	           vaccesoko>=vintentos THEN
	          vpasexec:=12;

	          UPDATE usuarios
	             SET cbloqueo=1,fbloqueo=f_sysdate
	           WHERE upper(cusuari)=upper(pusuario);

	          pintentos:=vintentos;

	          pvalidation:=3;
	        ELSIF vintentos>0 THEN
	          pintentos:=vaccesoko;

	          pvalidation:=2;
	        END IF;
	      END IF;
	    ELSE
	      vpasexec:=13;

	      SELECT count(1)
	        INTO vvalpaswd
	        FROM usuarios u
	       WHERE upper(u.cusuari)=upper(pusuario) AND
	             u.cbloqueo=1;

	      vpasexec:=14;

	      /*Miramos si el usuario ha sido bloqueado*/
	      IF vvalpaswd>0 THEN
	        pvalidation:=4;
	      END IF;

	      vpasexec:=15;

	      /*Miramos si la contraseña no ha caducado*/
	      IF vpassdifer!=0 THEN
	        SELECT max(to_date(to_char(fcambio, 'DD/MM/YYYY hh24:mi:ss'), 'DD/MM/YYYY hh24:mi:ss'))
	          INTO vfcambio
	          FROM usuarios_his_pass u
	         WHERE u.cusuari=upper(pusuario);

	        vpasexec:=16;

	        IF vfcambio IS NULL THEN
	        /*Miramos PRIMERA fecha correcta logado*/
	        BEGIN
	              SELECT min(to_date(to_char(fconexion, 'DD/MM/YYYY hh24:mi:ss'), 'DD/MM/YYYY hh24:mi:ss'))
	                INTO vfcambio
	                FROM log_conexion u
	               WHERE upper(u.cusuari)=upper(pusuario) AND
	                     cestcon=1;
	          EXCEPTION
	              WHEN no_data_found THEN
	                RETURN 0; /*Miramos la caducidad desde el primer acceso OK. Si aún no hay ningun acceso no hacemos nada*/
	          END;
	        END IF;

	        vpasexec:=17;

	        vfechacaduca:=vfcambio+vpassdifer; /*fecha de bloqueo o caducidad*/

	        IF to_date(to_char(f_sysdate, 'DD/MM/YYYY hh24:mi:ss'), 'DD/MM/YYYY hh24:mi:ss')>=(vfechacaduca) THEN /*bloqueamos usuario ya que la contraseña esta caducada*/
	          UPDATE usuarios
	             SET cbloqueo=1,fbloqueo=f_sysdate
	           WHERE upper(cusuari)=upper(pusuario);

	          pvalidation:=5;
	        END IF;

	        vpasexec:=18;
	      END IF;
	    END IF;

	    vpasexec:=19;

	    COMMIT;

	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'Objeto invocado con parámetros erroneos');

	             ROLLBACK;

	             RETURN 9000505; WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'SQLERROR: '
	                                                                           || SQLCODE
	                                                                           || ' - '
	                                                                           || SQLERRM);

	             ROLLBACK;

	             RETURN 9906626;
	END f_validateuser;

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
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='PAC_USER.F_Set_DatUsuario';
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

	    UPDATE usuarios
	       SET tusunom=ptusername,cidioma=pcidioma
	     WHERE upper(cusuari)=upper(puser);

	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'Objeto invocado con parámetros erroneos');

	             RETURN 9000505; WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'SQLERROR: '
	                                                                           || SQLCODE
	                                                                           || ' - '
	                                                                           || SQLERRM);

	             RETURN 9906626;
	END f_set_datusuario;

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
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='PAC_USER.F_CreaUserDefault';
	  vparam      VARCHAR2(500):='parámetros - pusuario: '
	                        || pusuario
	                        || ' pnombre:'
	                        || pnombre
	                        || ' pdelega:'
	                        || pdelega
	                        || ' pcidioma:'
	                        || pcidioma
	                        || ' pcempresa:'
	                        || pcempresa;
	  vpasexec    NUMBER(5):=1;
	BEGIN
	    /*Comprovació dels parámetres d'entrada*/
	    IF pusuario IS NULL  OR
	       pnombre IS NULL  OR
	       pdelega IS NULL  OR
	       pcidioma IS NULL  OR
	       pcempresa IS NULL THEN
	      RAISE e_param_error;
	    END IF;

			INSERT INTO usuarios
		           (cusuari,tusunom,cdelega,cidioma,cempres,ejecucion,
		           ctipusu,copcion,tpcpath,cautlog,falta)

		    VALUES
		           (upper(pusuario),pnombre,pdelega,pcidioma,pcempresa,0,
		           2,0,'c:\',pcautlog,f_sysdate);


	    RETURN 0;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'SQLERROR: '
	                                                                           || SQLCODE
	                                                                           || ' - '
	                                                                           || SQLERRM);

	             RETURN 9906626;
	END f_creauserdefault;

	/***********************************************************************
	         Crea un usuario
	   param in           : Todos los parametros del usuario.
	   param out mensajes : mensajes de error
	   return             : 1/0 indicando si se ha realizado el insert correctamente
	***********************************************************************/
	FUNCTION f_set_usuario(pcusuari	IN	VARCHAR2,pcidioma	IN	NUMBER,pcempres	IN	NUMBER,ptusunom	IN	VARCHAR2,ptpcpath	IN	VARCHAR2,pcdelega	IN	NUMBER,pcprovin	IN	NUMBER,pcpoblac	IN	NUMBER,pcvistas	IN	NUMBER,pcweb	IN	NUMBER,prepserver	IN	VARCHAR2,pejecucion	IN	NUMBER,psperson	IN	NUMBER,pfbaja	IN	DATE,pctipusu	IN	NUMBER,pcagecob	IN	NUMBER,pcopcion	IN	NUMBER,ptpwd	IN	VARCHAR2,pfalta	IN	DATE,pcusubbdd	IN	VARCHAR2,pcautlog	IN	NUMBER,pcempleado	IN	VARCHAR2,pcterminal	IN	VARCHAR2,pcvispubli	IN	NUMBER,pmail_usu	IN	VARCHAR2,/* BUG 29965 - FAL - 07/02/2014*/ptelfusu	IN	VARCHAR2,punidept	IN	NUMBER,pcategprof	IN	NUMBER)
	RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='PAC_USER.F_SET_USUARIO';
	  vparam      VARCHAR2(500):='parámetros - pusuario: '
	                        || pcusuari
	                        || ' pcidioma:'
	                        || pcidioma
	                        || ' pcempres:'
	                        || pcempres
	                        || ' ptusunom:'
	                        || ptusunom;
	  vpasexec    NUMBER(5):=1;
	  vcount      NUMBER;
	  vcambiapass NUMBER:=nvl(pac_md_common.f_get_parconexion('CAMBPASS'), 0);
	  vnum_err    NUMBER;
	BEGIN
	    /*Comprovació dels parámetres d'entrada*/
	    IF pcusuari IS NULL  OR
	       pcidioma IS NULL  OR
	       pcempres IS NULL  OR
	       ptusunom IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    BEGIN
			INSERT INTO usuarios
		           (cusuari,cidioma,cempres,tusunom,tpcpath,cdelega,
		           cprovin,cpoblac,cvistas,cweb,repserver,
		           ejecucion,sperson,fbaja,ctipusu,cagecob,
		           copcion,tpwd,falta,cusubbdd,cautlog,
		           cempleado,cterminal,cvispubli,mail_usu,telfusu,
		           unidept,categprof) /* BUG 29965 - FAL - 07/02/2014*/
		    VALUES
		           (upper(pcusuari),pcidioma,pcempres,ptusunom,ptpcpath,pcdelega,
		           pcprovin,pcpoblac,pcvistas,pcweb,prepserver,
		           pejecucion,psperson,pfbaja,pctipusu,pcagecob,
		           pcopcion,ptpwd,pfalta,pcusubbdd,pcautlog,
		           pcempleado,pcterminal,pcvispubli,pmail_usu,ptelfusu,
		           punidept,pcategprof ); /* BUG 29965 - FAL - 07/02/2014*/


	    /* Bug 36663/209495 - JR
	    IF vcambiapass = 1
	      AND pac_md_common.f_get_cxtusuario <> UPPER(pcusuari) THEN
	      p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'Entro');
	      vnum_err := pac_user.f_set_cambia_pass(UPPER(pcusuari), 1);

	      IF vnum_err <> 0 THEN
	         RETURN vnum_err;
	      END IF;
	    END IF;*/
	    EXCEPTION
	        WHEN dup_val_on_index THEN
	          SELECT count(1)
	            INTO vcount
	            FROM usuarios
	           WHERE cidioma=pcidioma AND
	                 cempres=pcempres AND
	                 tusunom=ptusunom AND
	                 tpcpath=ptpcpath AND
	                 cdelega=pcdelega AND
	                 ejecucion=pejecucion AND
	                 ctipusu=pctipusu AND
	                 copcion=pcopcion AND
	                 falta=pfalta AND
	                 cempleado=pcempleado AND
	                 cusuari=pcusuari AND
	                 cvispubli=pcvispubli /*BUG21653 - 14/03/2012 - JTS*/
	                 AND
	                 mail_usu=pmail_usu AND
	                 telfusu=ptelfusu; /* BUG 29965 - FAL - 07/02/2014*/

	          IF vcount=0 THEN /* Solo actualizamos si hay cambios*/
	            UPDATE usuarios
	               SET cidioma=pcidioma,cempres=pcempres,tusunom=ptusunom,tpcpath=ptpcpath,cdelega=pcdelega,cprovin=pcprovin,cpoblac=pcpoblac,cvistas=pcvistas,cweb=pcweb,repserver=prepserver,ejecucion=pejecucion,sperson=psperson,fbaja=pfbaja,ctipusu=pctipusu,cagecob=pcagecob,copcion=pcopcion,tpwd=nvl(ptpwd, tpwd),falta=pfalta,cusubbdd=nvl(pcusubbdd, cusubbdd),cautlog=pcautlog,cempleado=pcempleado,cterminal=pcterminal,cvispubli=pcvispubli,/*BUG21653 - 14/03/2012 - JTS*/mail_usu=pmail_usu,/* BUG 29965 - FAL - 07/02/2014*/telfusu=ptelfusu,unidept=punidept,categprof=pcategprof
	             WHERE upper(cusuari)=upper(pcusuari);
	          /* Bug 36663/209495 - JR
	          IF vcambiapass = 1
	             AND pac_md_common.f_get_cxtusuario <> UPPER(pcusuari) THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'Entro2');
	             vnum_err := pac_user.f_set_cambia_pass(UPPER(pcusuari), 1);

	             IF vnum_err <> 0 THEN
	                RETURN vnum_err;
	             END IF;
	          END IF;*/
	          END IF;
	    END;

	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'Objeto invocado con parámetros erroneos');

	             RETURN 9000505; WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'SQLERROR: '
	                                                                           || SQLCODE
	                                                                           || ' - '
	                                                                           || SQLERRM);

	             RETURN 9906626;
	END;

	/***********************************************************************
	                    Borra un usuario
	    param in pcusuari : Codigo del usuario.
	    param out mensajes : mensajes de error
	    return             : 1/0 indicando si se ha realizado el insert correctamente
	 ***********************************************************************/
	FUNCTION f_del_usuario(
			pcusuari	IN	VARCHAR2
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='PAC_USER.F_DEL_USUARIO';
	  vparam      VARCHAR2(500):='parámetros - pusuario: '
	                        || pcusuari;
	  vpasexec    NUMBER(5):=1;
	BEGIN
	    /*Comprovació dels parámetres d'entrada*/
	    IF pcusuari IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    /* Borramos usuario*/
	    UPDATE usuarios
	       SET fbaja=f_sysdate,cusubaja=f_user
	     WHERE upper(cusuari)=upper(pcusuari);

	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'Objeto invocado con parámetros erroneos');

	             RETURN 9000505; WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'SQLERROR: '
	                                                                           || SQLCODE
	                                                                           || ' - '
	                                                                           || SQLERRM);

	             RETURN 9906626;
	END f_del_usuario;

	/***********************************************************************
	          Recupera un usuario
	    param in pcusuari : Codigo del usuario.
	    param out pusuario : Usuario solicitado
	    return             : 1/0 indicando si se ha realizado el insert correctamente
	 ***********************************************************************/
	FUNCTION f_get_usuario(pcusuari	IN	VARCHAR2,pusuario	OUT	usuarios%ROWTYPE,ptempres	OUT	VARCHAR2,ptdelega	OUT	VARCHAR2,pccfgwiz	OUT	VARCHAR2,pccfgform	OUT	VARCHAR2,pccfgacc	OUT	VARCHAR2,pcrolmen	OUT	VARCHAR2,pcconsupl	OUT	VARCHAR2,pccfgdoc	OUT	VARCHAR2,pcaccprod	OUT	VARCHAR2,/* BUG16471:DRA:26/10/2010*/pccfgmap	OUT	VARCHAR2,/* BUG 21569 - 07/03/2012 - JMP*/pcrol	OUT	VARCHAR2,pareas OUT VARCHAR2/*IAXIS-4994*/,pcusuagru	OUT	VARCHAR2) /*FAC Asociar nivel PSU al usuario*/
	RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='PAC_USER.F_GET_USUARIO';
	  vparam      VARCHAR2(500):='parámetros - pusuario: '
	                        || pcusuari;
	  vpasexec    NUMBER(5):=1;
	  vnum_err    NUMBER;
	BEGIN
	    SELECT cusuari,cidioma,cempres,tusunom,cdelega,ejecucion,sperson,fbaja,ctipusu,copcion,falta,cempleado,cautlog,cvispubli,mail_usu,telfusu,unidept,categprof /* BUG 29965 - FAL - 07/02/2014*/
	      INTO pusuario.cusuari, pusuario.cidioma, pusuario.cempres, pusuario.tusunom,
	    pusuario.cdelega, pusuario.ejecucion, pusuario.sperson, pusuario.fbaja,
	    pusuario.ctipusu, pusuario.copcion, pusuario.falta, pusuario.cempleado,
	    pusuario.cautlog, pusuario.cvispubli, pusuario.mail_usu, pusuario.telfusu,
	    pusuario.unidept, pusuario.categprof /* BUG 29965 - FAL - 07/02/2014*/
	      FROM usuarios
	     WHERE upper(cusuari)=upper(pcusuari);

	    vpasexec:=2;

	    BEGIN
	        SELECT tempres
	          INTO ptempres
	          FROM empresas
	         WHERE cempres=pusuario.cempres;
	    EXCEPTION
	        WHEN no_data_found THEN
	          ptempres:=NULL;
	    END;

	    vpasexec:=3;

	    vnum_err:=f_desagente(pusuario.cdelega, ptdelega);

	    IF vnum_err<>0 THEN
	      ptdelega:=NULL;
	    END IF;

	    vpasexec:=4;

	    BEGIN
	        SELECT cconsupl
	          INTO pcconsupl
	          FROM pds_config_user
	         WHERE upper(cuser)=upper(pcusuari);
	    EXCEPTION
	        WHEN no_data_found THEN
	          pcconsupl:=NULL;
	    END;

	    BEGIN
	        SELECT ccfgwiz,ccfgform,ccfgacc,ccfgdoc,caccprod,ccfgmap,/* BUG16471:DRA:26/10/2010*/ccfgmarca,crol --IAXIS-4994
	          INTO pccfgwiz, pccfgform, pccfgacc, pccfgdoc,
	        pcaccprod, pccfgmap, /* BUG16471:DRA:26/10/2010*/
	        pareas,pcrol --IAXIS-4994
	          FROM cfg_user
	         WHERE upper(cuser)=upper(pcusuari) AND
	               cempres=pusuario.cempres; /* BUG9981:DRA:06/05/2009*/
	    EXCEPTION
	        WHEN no_data_found THEN
	          pccfgwiz:=NULL;

	          pccfgform:=NULL;

	          pccfgacc:=NULL;

	          pccfgdoc:=NULL;

	          pcaccprod:=NULL; /* BUG16471:DRA:26/10/2010*/

	          pccfgmap:=NULL;
	    END;

	    vpasexec:=5;

	    BEGIN
	        SELECT crolmen
	          INTO pcrolmen
	          FROM menu_usercodirol
	         WHERE upper(cuser)=upper(pcusuari) AND
	               ROWNUM=1;
	    /* Por el momento solo recuperamos un rol de menu*/
	    EXCEPTION
	        WHEN no_data_found THEN
	          pcrolmen:=NULL;
	    END;

	    vpasexec:=6;

	    BEGIN
	        SELECT cusuagru
	          INTO pcusuagru
	          FROM psu_usuagru b
	         WHERE upper(b.cusuari)=upper(pcusuari) AND
	               ROWNUM=1;
	    EXCEPTION
	        WHEN no_data_found THEN
	          pcusuagru:=NULL;
	    END;

	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'Objeto invocado con parámetros erroneos');

	             RETURN 9000505; WHEN e_object_error THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'vnum_err: '
	                                                                           || vnum_err);

	             RETURN 108094; WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'SQLERROR: '
	                                                                           || SQLCODE
	                                                                           || ' - '
	                                                                           || SQLERRM);

	             RETURN 9906626;
	END f_get_usuario;

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
	) RETURN VARCHAR2
	IS
	  vobjectname VARCHAR2(500):='PAC_TERMINALES.FF_CONSULTA_USUARIOS';
	  vparam      VARCHAR2(500):='parámetros - pUser:'
	                        || puser
	                        || ' pcempres:'
	                        || pcempres
	                        || ' ptUsername:'
	                        || ptusername
	                        || ' pcDelega:'
	                        || pcdelega;
	  vpasexec    NUMBER(5):=1;
	  vselec      VARCHAR2(500);
	BEGIN
	    vselec:='select u.cusuari,u.tusunom,i.TIDIOMA,u.CEMPLEADO,
		                   PAC_REDCOMERCIAL.ff_desagente (a.cagente, '
	            || pcidioma
	            || ', 2) cdelega,
		                   FF_DESVALORFIJO(862,'
	            || pcidioma
	            || ',decode(u.fbaja,null,1,2)) testado'
	            || ' from usuarios u, idiomas i,agentes a'
	            || ' where i.cidioma = u.cidioma '
	            || '   and u.CDELEGA = a.CAGENTE '
	            || '   and u.cempres = '
	            || pcempres;

	    IF ptusername IS NOT NULL THEN
	      vselec:=vselec
	              || ' AND upper(u.tusunom) like ''%'
	              || upper(ptusername)
	              || '%''';
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

	    RETURN vselec;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'SQLERROR: '
	                                                                           || SQLCODE
	                                                                           || ' - '
	                                                                           || SQLERRM);

	             RETURN 111715; /*Error a la definició de la consulta.*/
	END ff_consulta_usuarios;

	/***********************************************************************
	                          Recupera un agente
	   param in pcusuari : Codigo del usuario.
	   param out pcagente : agente solicitado
	   return             : 1/0 indicando si se ha realizado el insert correctamente
	***********************************************************************/
	FUNCTION f_get_cagente(
			pcusuari	IN	VARCHAR2,
			pcagente	OUT	NUMBER
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='PAC_USER.F_GET_CAGENTE';
	  vparam      VARCHAR2(500):='parámetros - pusuario: '
	                        || pcusuari;
	  vpasexec    NUMBER(5):=1;
	BEGIN
	    /*Comprovació dels parámetres d'entrada*/
	    IF pcusuari IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    SELECT cdelega
	      INTO pcagente
	      FROM usuarios
	     WHERE upper(cusuari)=upper(pcusuari);

	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'Objeto invocado con parámetros erroneos');

	             RETURN 9000505; WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'SQLERROR: '
	                                                                           || SQLCODE
	                                                                           || ' - '
	                                                                           || SQLERRM);

	             RETURN 9906626;
	END f_get_cagente;

	/***********************************************************************
	        Recupera un agente
	  param in pcusuari : Codigo del usuario.
	  return             : codigo de agente
	***********************************************************************/
	FUNCTION ff_get_cagente(
			pcusuari	IN	VARCHAR2
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='PAC_USER.FF_GET_CAGENTE';
	  vparam      VARCHAR2(500):='parámetros - pusuario: '
	                        || pcusuari;
	  vpasexec    NUMBER(5):=1;
	  vcagente    NUMBER;
	  vnum_err    NUMBER;
	BEGIN
	    /*Comprovació dels parámetres d'entrada*/
	    IF pcusuari IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    vnum_err:=f_get_cagente(pcusuari, vcagente);

	    IF vnum_err<>0 THEN
	      RETURN NULL;
	    END IF;

	    RETURN vcagente;
	EXCEPTION
	  WHEN e_param_error THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'Objeto invocado con parámetros erroneos');

	             RETURN NULL; WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'SQLERROR: '
	                                                                           || SQLCODE
	                                                                           || ' - '
	                                                                           || SQLERRM);

	             RETURN NULL;
	END ff_get_cagente;

	/******************************************************************************************
	        Autor: XVILA (05/12/2008)
	  Descripció: Funció que activa un usuari donat de baixa.
	  Paràmetres entrada: - pcusuari    -> id. usuari
	  return:             retorna 0 si va tot bé, sino el codi de l'error
	******************************************************************************************/
	FUNCTION f_activar_usuario(
			pcusuari	IN	VARCHAR2
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='PAC_USER.f_activar_usuario';
	  vparam      VARCHAR2(500):='parámetros - pcusuari: '
	                        || pcusuari;
	  vpasexec    NUMBER(5):=1;
	  vnumerr     NUMBER(8):=0;
	BEGIN
	    /*Comprovació de paràmetres d'entrada*/
	    IF pcusuari IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    UPDATE usuarios
	       SET fbaja=NULL,cusubaja=NULL,cbloqueo=NULL,fbloqueo=NULL
	     WHERE upper(cusuari)=upper(pcusuari);

	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'Objeto invocado con parámetros erroneos');

	             RETURN 9000505; WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'SQLERROR: '
	                                                                           || SQLCODE
	                                                                           || ' - '
	                                                                           || SQLERRM);

	             RETURN 102241; /*Error al modificar a la taula USUARIOS*/
	END f_activar_usuario;

	/**/
	/**/
	/**/
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
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='PAC_USER.F_Get_Termfisic';
	  vparam      VARCHAR2(500):='parámetros - puser: '
	                        || puser;
	  vpasexec    NUMBER(5):=1;
	  vnumerr     NUMBER(8):=0;
	BEGIN
	    /*Comprovació de paràmetres d'entrada*/
	    IF puser IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    vpasexec:=3;

	    SELECT u.ctermfisic
	      INTO pctermfisic
	      FROM usuarios u
	     WHERE upper(u.cusuari)=upper(puser);

	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'Objeto invocado con parámetros erroneos');

	             RETURN 9906626; /*Error de validación*/
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'SQLERROR: '
	                                                                           || SQLCODE
	                                                                           || ' - '
	                                                                           || SQLERRM);

	             RETURN 9906626; /*Error de validación*/
	END f_get_termfisic;

	/***********************************************************************
	                          BUG 13266
	   Recupera un terminal fisic
	   param in pcusuari : Codigo del usuario.
	   return            : terminal
	***********************************************************************/
	FUNCTION ff_get_termfisic(
			pcusuari	IN	VARCHAR2
	) RETURN VARCHAR2
	IS
	  vobjectname VARCHAR2(500):='PAC_USER.FF_GET_TERMFISIC';
	  vparam      VARCHAR2(500):='parámetros - pusuario: '
	                        || pcusuari;
	  vpasexec    NUMBER(5):=1;
	  vterminal   usuarios.ctermfisic%TYPE;
	  vnum_err    NUMBER;
	BEGIN
	    /*Comprovació dels parámetres d'entrada*/
	    IF pcusuari IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    vnum_err:=f_get_termfisic(pcusuari, vterminal);

	    IF vnum_err<>0 THEN
	      RETURN NULL;
	    END IF;

	    RETURN vterminal;
	EXCEPTION
	  WHEN e_param_error THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'Objeto invocado con parámetros erroneos');

	             RETURN NULL; WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'SQLERROR: '
	                                                                           || SQLCODE
	                                                                           || ' - '
	                                                                           || SQLERRM);

	             RETURN NULL;
	END ff_get_termfisic;

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
	) RETURN NUMBER
	IS
	  PRAGMA autonomous_transaction;
	  vobjectname VARCHAR2(500):='PAC_USER.F_Set_Termfisic';
	  vparam      VARCHAR2(500):='parámetros - pUser: '
	                        || puser
	                        || ' pterminal:'
	                        || pterminal;
	  vpasexec    NUMBER(5):=1;
	  vnumerr     NUMBER(8):=0;
	BEGIN
	    /*Comprovació de paràmetres d'entrada*/
	    IF puser IS NULL  OR
	       pterminal IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    UPDATE usuarios
	       SET ctermfisic=pterminal
	     WHERE upper(cusuari)=upper(puser);

	    COMMIT;

	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'Objeto invocado con parámetros erroneos');

	             RETURN 103196; --Error a l'inserir a la taula USUARIOS.
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'SQLERROR: '
	                                                                           || SQLCODE
	                                                                           || ' - '
	                                                                           || SQLERRM);

	             RETURN 103196; --Error a l'inserir a la taula USUARIOS.
	END f_set_termfisic;

	/*BUG21762 - JTS - 20/03/2012*/
	FUNCTION f_logea(
			puser	IN	VARCHAR2
	) RETURN NUMBER
	IS
	  PRAGMA autonomous_transaction;
	  vobjectname VARCHAR2(500):='PAC_USER.F_logea';
	  vparam      VARCHAR2(500):='parámetros - pUser: '
	                        || puser;
	  vcislogged  NUMBER;
	  vflogin     DATE;
	  vcnsesiones NUMBER;
	  vpasexec    NUMBER:=1;
	BEGIN
	    /*Comprovació de paràmetres d'entrada*/
	    IF puser IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    vpasexec:=2;

	    SELECT cislogged,flogin,cnsesiones
	      INTO vcislogged, vflogin, vcnsesiones
	      FROM usuarios
	     WHERE upper(cusuari)=upper(puser);

	    IF vcislogged=1 THEN
	    /*Aquí se deberá añadir comprovación de numero de sesiones*/
	    /*que tiene el usuario, para saber si puede abrir una mas o no*/
	    /*de momento solo permitimos una*/
	    /**/
	    /*Al comprovar el numero de sesiones (cnsesiones) debemos ir*/
	      /*incrementando el campo, evidentemente*/
	      RETURN 9903720; /*No se permite realizar una nueva conexión*/
	    END IF;

	    vpasexec:=3;

	    UPDATE usuarios
	       SET cislogged=1,flogin=f_sysdate,cnsesiones=1 /*De momento solo una sesión, ya marcaremos mas mas adelante*/
	     WHERE upper(cusuari)=upper(puser);

	    COMMIT;

	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, 1, vparam, 'Objeto invocado con parámetros erroneos');

	             RETURN 1000005; WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'SQLERROR: '
	                                                                           || SQLCODE
	                                                                           || ' - '
	                                                                           || SQLERRM);

	             RETURN 1000001;
	END f_logea;
	FUNCTION f_deslogea(
			puser	IN	VARCHAR2
	) RETURN NUMBER
	IS
	  PRAGMA autonomous_transaction;
	  vobjectname VARCHAR2(500):='PAC_USER.F_deslogea';
	  vparam      VARCHAR2(500):='parámetros - pUser: '
	                        || puser;
	  vcislogged  NUMBER;
	  vflogin     DATE;
	  vcnsesiones NUMBER;
	  vpasexec    NUMBER:=1;
	BEGIN
	    /*Comprovació de paràmetres d'entrada*/
	    IF puser IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    vpasexec:=2;

	    /*En un futuro se comprovaran el numero de sesiones*/
	    /*y se iran restando*/
	    UPDATE usuarios
	       SET cislogged=0,cnsesiones=0 /*De momento a 0, mas adelante restaremos sesiones*/
	     WHERE upper(cusuari)=upper(puser);

	    COMMIT;

	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, 1, vparam, 'Objeto invocado con parámetros erroneos');

	             RETURN 1000005; WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'SQLERROR: '
	                                                                           || SQLCODE
	                                                                           || ' - '
	                                                                           || SQLERRM);

	             RETURN 1000001;
	END f_deslogea;

	/*Fi BUG21762*/
	FUNCTION f_val_cambio_paswd(
			puser	IN	VARCHAR2,
			pdias	OUT	NUMBER
	) RETURN NUMBER
	IS
	  vobjectname  VARCHAR2(500):='PAC_USER.f_val_cambio_paswd';
	  vparam       VARCHAR2(500):='parámetros - pUser: '
	                        || puser;
	  vcislogged   NUMBER;
	  vflogin      DATE;
	  vpassdifer   NUMBER(5):=nvl(pac_md_common.f_get_parconexion('DIASCAMBIO'), 0);
	  vavisocambio NUMBER(5):=nvl(pac_md_common.f_get_parconexion('DIASAVISCM'), 0);
	  vcnsesiones  NUMBER;
	  vpasexec     NUMBER:=1;
	  vfcambio     DATE;
	  vdias        NUMBER;
	  vfechacaduca DATE;
	  vfechaaviso  DATE;
	BEGIN
	    /*Comprovació de paràmetres d'entrada*/
	    IF puser IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    vpasexec:=2;

	    IF vpassdifer!=0 THEN
	      SELECT max(to_date(to_char(fcambio, 'DD/MM/YYYY hh24:mi:ss'), 'DD/MM/YYYY hh24:mi:ss'))
	        INTO vfcambio
	        FROM usuarios_his_pass u
	       WHERE u.cusuari=upper(puser);

	      IF vfcambio IS NULL THEN
	        /*Miramos PRIMERA fecha correcta logado*/
	        SELECT nvl(min(to_date(to_char(fconexion, 'DD/MM/YYYY hh24:mi:ss'), 'DD/MM/YYYY hh24:mi:ss')), to_date('01/01/2000', 'DD/MM/YYYY'))
	          INTO vfcambio
	          FROM log_conexion u
	         WHERE upper(u.cusuari)=upper(puser) AND
	               cestcon=1;
	      /*  pdias := ROUND(f_sysdate - vfcambio);*/
	      END IF;

	      vfechacaduca:=(vfcambio)+vpassdifer; /*fecha de bloqueo o caducidad*/

	      vfechaaviso:=(vfechacaduca)-vavisocambio; /*fecha de aviso de caducidad*/

	      IF to_date(to_char(f_sysdate, 'DD/MM/YYYY hh24:mi:ss'), 'DD/MM/YYYY hh24:mi:ss') BETWEEN(vfechaaviso) AND(vfechacaduca) THEN
	        pdias:=round((vfechacaduca)-(f_sysdate));

	        RETURN 9903638;
	      END IF;
	    END IF;

	    RETURN 0;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'SQLERROR: '
	                                                                           || SQLCODE
	                                                                           || ' - '
	                                                                           || SQLERRM);

	             RETURN 1000001;
	END f_val_cambio_paswd;
	FUNCTION f_set_cambia_pass(
			puser	IN	VARCHAR2,
			pvalue	IN	NUMBER
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='PAC_USER.f_set_cambia_pass';
	  vparam      VARCHAR2(500):='parámetros - pUser: '
	                        || puser;
	BEGIN
	    /*Comprovació de paràmetres d'entrada*/
	    IF puser IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    BEGIN
			INSERT INTO usuarios_cambpass
		           (cusuari,ccambpass)
		    VALUES
		           (puser,pvalue);


	    EXCEPTION
	        WHEN dup_val_on_index THEN
	          UPDATE usuarios_cambpass
	             SET ccambpass=pvalue
	           WHERE cusuari=puser;
	    END;

	    RETURN 0;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, 1, vparam, 'SQLERROR: '
	                                                                    || SQLCODE
	                                                                    || ' - '
	                                                                    || SQLERRM);

	             RETURN 1000001;
	END f_set_cambia_pass;
	FUNCTION f_get_cambia_pass(
			puser	IN	VARCHAR2,
			pvalue	OUT	NUMBER
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='PAC_USER.f_get_cambia_pass';
	  vparam      VARCHAR2(500):='parámetros - pUser: '
	                        || puser;
	BEGIN
	    /*Comprovació de paràmetres d'entrada*/
	    IF puser IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    BEGIN
	        SELECT nvl(ccambpass, 0)
	          INTO pvalue
	          FROM usuarios_cambpass
	         WHERE cusuari=puser;
	    EXCEPTION
	        WHEN no_data_found THEN
	          pvalue:=0;
	    END;

	    RETURN 0;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, 1, vparam, 'SQLERROR: '
	                                                                    || SQLCODE
	                                                                    || ' - '
	                                                                    || SQLERRM);

	             RETURN 1000001;
	END f_get_cambia_pass;
	FUNCTION f_useractivo(
			pusuario	IN	VARCHAR2,
			pactivo	OUT	NUMBER
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='PAC_USER.F_useractivo';
	  vparam      VARCHAR2(500):='parámetros - pusuario: '
	                        || pusuario;
	  vpasexec    NUMBER(5):=1;
	  vnumerr     NUMBER(8):=0;
	  vbaja       usuarios.fbaja%TYPE;
	  vbloqueo    usuarios.cbloqueo%TYPE;
	BEGIN
	    /*Comprovació de paràmetres d'entrada*/
	    IF pusuario IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    vpasexec:=3;

	    SELECT u.fbaja,nvl(u.cbloqueo, 0)
	      INTO vbaja, vbloqueo
	      FROM usuarios u
	     WHERE upper(u.cusuari)=upper(pusuario);

	    IF vbaja IS NOT NULL THEN
	      pactivo:=9906626;
	    ELSE
	      pactivo:=0;
	    END IF;

	    /*  if pbloqueo=1 then
	       pactivo:= 9903637;
	      end if;*/
	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'Objeto invocado con parámetros erroneos');

	             RETURN 9000505; WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'SQLERROR: '
	                                                                           || SQLCODE
	                                                                           || ' - '
	                                                                           || SQLERRM);

	             RETURN 9906626;
	END f_useractivo;

END pac_user;

/

