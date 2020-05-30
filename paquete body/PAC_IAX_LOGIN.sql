--------------------------------------------------------
--  DDL for Package Body PAC_IAX_LOGIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_LOGIN" AS
   /******************************************************************************
      NOMBRE:       PAC_IAX_LOGIN
      PROPÓSITO:  Funciones para validar el usuario
      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        20/11/2007   ACC                1. Creación del package.
      2.0        06/05/2009   DRA                2. 0009981: IAX - Baixar l'empresa a totes les taules del model CFG
      3.         22/11/2010   JAS                3. 13266: Modificación interfases apertura y cierre de puesto (parte PL) Diverses modificacions al codi
   ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*************************************************************************
            Comprueba si la aplicación se permite el autologin de usuarios
      return           : 1 indica que se permite autologin
                         0 no esta permitido
   *************************************************************************/
   FUNCTION f_empresa_autologin
      RETURN NUMBER IS
      isautologin    NUMBER := 0;
      num_err        NUMBER;
      mensajes       t_iax_mensajes;
      vempresa       NUMBER;
      no_autlogin    EXCEPTION;
   BEGIN
      --S'ha de comprovar que l'aplicació tingui autologin
      vempresa := pac_parametros.f_parinstalacion_n('EMPRESADEF');

      IF vempresa IS NULL THEN
         RAISE no_autlogin;
      END IF;

      isautologin := pac_parametros.f_parempresa_n(vempresa, 'AUTOLOGIN');
      RETURN NVL(isautologin, 0);
   EXCEPTION
      WHEN no_autlogin THEN
         RETURN 0;
      WHEN OTHERS THEN
         RETURN 0;
   END f_empresa_autologin;

   /*************************************************************************
                  Cuando JAVA establezca una conexión, debe llamar a esta función para
      establecer las variables de contexto
      param in usuario  : usuario que se ha conectado a la aplicación.
                          A partir de este usuario se obtendrán los valores
                          para el resto de variables de contexto que se deben
                          inicializar (empresa, idioma, agente)
   *************************************************************************/
   PROCEDURE p_iax_iniconnect(pusuario IN VARCHAR2) IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_LOGIN.P_IAX_Iniconnect';
      vparam         VARCHAR2(500) := 'parámetros - pusuario: ' || pusuario;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vobuser        ob_iax_users;
      mensajes       t_iax_mensajes;
   BEGIN
      --Comprovació de paràmetres d'entrada
      IF pusuario IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      --Recuperació de les dades de l'usuari.
      vobuser := pac_md_user.f_get_datuser(pusuario, mensajes);

      IF vobuser IS NULL THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 5;
      --Inicialització del context.
      pac_md_common.p_set_cxtusuario(vobuser.cusuari);
      pac_md_common.p_set_cxtempresa(vobuser.cempres);
      pac_md_common.p_set_cxtidioma(vobuser.cidioma);
      pac_md_common.p_set_cxtagente(vobuser.cagente);
      pac_md_common.p_set_cxtagenteprod(vobuser.cagente);
   EXCEPTION
      WHEN e_param_error THEN
         pac_md_common.p_grabadberror(vobjectname, vpasexec, vparam,
                                      f_axis_literales(1000005));
      WHEN e_object_error THEN
         pac_md_common.p_grabadberror(vobjectname, vpasexec, vparam,
                                      f_axis_literales(1000006));
      WHEN OTHERS THEN
         pac_md_common.p_grabadberror(vobjectname, vpasexec, vparam,
                                      'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
   END;

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
      RETURN NUMBER IS
      vautologin     NUMBER;
      vcautlog       NUMBER;
      vvcedida       NUMBER;
      vvalusu        NUMBER;
      vvalidado      NUMBER;
      voficina       NUMBER;
      vtnombre       VARCHAR2(100);
      vsinterf       NUMBER;
      vcrear         NUMBER;
      vpreval        NUMBER;
      num_err        NUMBER;
      vabrirp        NUMBER;
      vabrirp_usu    NUMBER;
      vactoficina    NUMBER(2);
      vcrealiza      NUMBER;
      vempresa       NUMBER;
      vtermlog       NUMBER;
      vrespuesta     NUMBER;
      vactivo        NUMBER;
      vobjectname    VARCHAR2(500) := 'PAC_IAX_LOGIN.F_IAX_LOGIN';
      vparam         VARCHAR2(1000)
         := 'parámetros - pusuario: ' || pusuario || ' ptipcon:' || ptipcon || ' poficina:'
            || poficina || ' pterminal:' || pterminal;
      vpasexec       NUMBER(5) := 1;
      vpwd           VARCHAR2(25);
      vintentos      NUMBER;

      PROCEDURE inicializar_user IS
      BEGIN
         --Carga del objecto de salida con los datos del usuario.
         pdatuser := pac_md_user.f_get_datuser(pusuario, mensajes);

         IF pdatuser IS NULL THEN
            RAISE e_object_error;
         END IF;

         -- Inicialitzem variables de contexte ACC 19/10/2007
         pac_md_common.p_set_cxtusuario(pdatuser.cusuari);
         pac_md_common.p_set_cxtempresa(pdatuser.cempres);
         pac_md_common.p_set_cxtidioma(pdatuser.cidioma);
         pac_md_common.p_set_cxtagente(pdatuser.cagente);
         pac_md_common.p_set_cxtagenteprod(pdatuser.cagente);
      END inicializar_user;
   BEGIN
      pac_md_common.p_set_cxtagente(poficina);
      vpasexec := 2;
      pac_md_common.p_set_cxtusuario(UPPER(pusuario));
      vpasexec := 3;

      IF pempresa IS NULL THEN
         vempresa := pac_parametros.f_parinstalacion_n('EMPRESADEF');
      ELSE
         vempresa := pempresa;
      END IF;

      pac_md_common.p_set_cxtempresa(vempresa);
      vpasexec := 4;

      IF UPPER(ptipcon) = 'AUTOLOGIN' THEN
         -- dra 18-12-2008: Si la empresa no tiene autologin no dejaremos entrar
         vautologin := pac_parametros.f_parempresa_n(vempresa, 'AUTOLOGIN');

         IF NVL(vautologin, 0) <> 1 THEN
            RAISE e_object_error;
         END IF;
      ELSE
         vautologin := 0;
      END IF;

      vpasexec := 5;

      IF vautologin = 1 THEN   -- Vamos por autologin
         vpasexec := 6;
         -- Miramos si el usuario existe en la BBDD
         num_err := pac_md_user.f_existuser(pusuario, vrespuesta, mensajes);

         IF num_err <> 0 THEN
            RAISE e_object_error;
         END IF;

         vpasexec := 7;
         num_err := pac_iax_login.f_logea(pusuario, mensajes);

         IF num_err <> 0 THEN
            RAISE e_object_error;
         END IF;

         vpasexec := 71;

         IF vrespuesta = 1 THEN
            vpasexec := 8;
            -- Miramos si usuario es autologin
            num_err := pac_md_user.f_isautologinuser(pusuario, vcautlog, mensajes);

            IF num_err <> 0 THEN
               RAISE e_object_error;
            END IF;

            IF vcautlog = 1 THEN
               vpasexec := 9;
               -- Miramos si la validacion es cedida
               vvcedida := pac_parametros.f_parempresa_n(vempresa, 'VALCEDIDA_AUTOLOGIN');

               IF vvcedida = 1 THEN
                  vpasexec := 10;
                  -- axis-connect
                  -- Validamos el usuario y password
                  vvalusu := pac_md_con.f_validar_usuario(pusuario, ppwd, vvalidado, voficina,
                                                          vtnombre, vsinterf, mensajes);

                  IF vvalusu <> 0 THEN
                     vpasexec := 11;
                     pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 110925,
                                                       vpasexec, vparam, NULL, SQLCODE,
                                                       SQLERRM);
                     num_err := pac_md_login.f_set_log_conexion(pusuario, remoteip, vvalidado,
                                                                mensajes);
                     -- Añadido por pct bug 8352 (mantis)
                     RETURN 0;
                  END IF;

                  vpasexec := 12;

                  IF vvalidado = 1 THEN
                     vpasexec := 13;
                     num_err := pac_md_user.f_set_agente(pusuario, voficina, mensajes);
                     COMMIT;

                     -- Se tiene que eliminar, tambien esta en pac_user y hacer un unico (f_set_terminal tambien)
                     IF num_err <> 0 THEN
                        RAISE e_object_error;
                     END IF;

                     vpasexec := 14;
                     pac_md_common.p_set_cxtagente(voficina);
                     vpasexec := 15;
                     --Comprovem si cal realitzar obertura de "puesto"
                     vabrirp := pac_parametros.f_parempresa_n(vempresa, 'ABRIR_PUESTO');
                     vabrirp_usu :=
                        pac_cfg.f_get_user_accion_permitida(pac_md_common.f_get_cxtusuario,
                                                            'ABRIR_PUESTO', NULL, vempresa,   -- BUG9981:DRA:06/05/2009
                                                            vcrealiza);

                     IF vabrirp = 1
                        AND vabrirp_usu = 1 THEN
                        vpasexec := 16;
                        num_err := pac_md_user.f_set_termfisic(pusuario, pterminal, mensajes);

                        IF num_err <> 0 THEN
                           RAISE e_object_error;
                        END IF;

                        vpasexec := 17;
                        num_err := pac_md_con.f_abrir_puesto(pusuario, ppwd, vsinterf,
                                                             voficina, vtermlog, mensajes);
                        vpasexec := 18;

                        IF num_err <> 0 THEN
                           pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 9000555,
                                                             vpasexec, vparam, NULL, SQLCODE,
                                                             SQLERRM);
                           num_err := pac_md_login.f_set_log_conexion(pusuario, remoteip,
                                                                      vvalidado, mensajes);
                           -- Añadido por pct bug 8352 (mantis)
                           RETURN 0;
                        END IF;

                        pac_md_common.p_set_cxtterminal(vtermlog);
                        vpasexec := 19;
                        num_err := pac_md_user.f_setterminal(pusuario, vtermlog, mensajes);

                        IF num_err <> 0 THEN
                           RAISE e_object_error;
                        END IF;

                        vpasexec := 21;
                        -- Miramos si se actualiza la oficina
                        vactoficina := pac_parametros.f_parempresa_n(pempresa, 'ACT_OFICINA');

                        IF vactoficina = 1 THEN
                           vpasexec := 22;
                           num_err := pac_md_user.f_set_agente(pusuario, voficina, mensajes);
                        -- Se tiene que eliminar, tambien esta en pac_user y hacer un unico (f_set_terminal tambien)
                        END IF;

                        IF num_err <> 0 THEN
                           RETURN num_err;
                        END IF;
                     END IF;

                     vpasexec := 23;
                     inicializar_user;
                     vpasexec := 24;
                     num_err := pac_md_login.f_set_log_conexion(pusuario, remoteip, vvalidado,
                                                                mensajes);
                     -- Añadido por pct bug 8352 (mantis)
                     RETURN 1;
                  ELSE
                     vpasexec := 25;
                     num_err := pac_md_login.f_set_log_conexion(pusuario, remoteip, vvalidado,
                                                                mensajes);
                     -- Añadido por pct bug 8352 (mantis)
                     RETURN 0;
                  END IF;
               ELSE
                  --BUG 11704: Si no tenemos validación cedida, miramos si tenemos prevalidacion
                  --En ese caso dejamos entrar.
                  vpasexec := 246;
                  --vcrear := pac_parametros.f_parempresa_n(vempresa, 'CREAR_USUARIO');
                  vpreval := pac_parametros.f_parempresa_n(vempresa, 'PRE_VALIDACIO');

                  IF   /*vcrear = 1
                                         AND*/
                     vpreval = 1
                     AND poficina IS NOT NULL THEN
                     vpasexec := 232;
                     -- Miramos si se actualiza la oficina
                     vactoficina := pac_parametros.f_parempresa_n(pempresa, 'ACT_OFICINA');

                     IF vactoficina = 1 THEN
                        vpasexec := 240;
                        num_err := pac_user.f_set_agente(pusuario, poficina);

                        IF pterminal IS NOT NULL THEN
                           num_err := pac_user.f_set_terminal(pusuario, pterminal);
                        END IF;

                        COMMIT;
                     END IF;

                     IF num_err <> 0 THEN
                        RETURN num_err;
                     END IF;

                     vpasexec := 259;
                     inicializar_user;
                     vpasexec := 260;
                     num_err := pac_md_login.f_set_log_conexion(pusuario, remoteip, vvalidado,
                                                                mensajes);
                     -- Añadido por pct bug 8352 (mantis)
                     RETURN 1;
                  ELSE
                     vpasexec := 26;
                     num_err := pac_md_login.f_set_log_conexion(pusuario, remoteip, vvalidado,
                                                                mensajes);
                     -- Añadido por pct bug 8352 (mantis)
                     RETURN 0;
                  END IF;
               END IF;
            ELSE
               vpasexec := 27;
               -- login
               num_err := pac_md_login.f_set_log_conexion(pusuario, remoteip, vvalidado,
                                                          mensajes);
               -- Añadido por pct bug 8352 (mantis)
               RETURN 0;
            END IF;
         ELSE
            vpasexec := 28;
            -- Miramos si la validacion es cedida
            vvcedida := pac_parametros.f_parempresa_n(vempresa, 'VALCEDIDA_AUTOLOGIN');

            IF vvcedida = 1 THEN
               vpasexec := 29;
               -- axis-connect
               -- Validamos el usuario y password
               vvalusu := pac_md_con.f_validar_usuario(pusuario, ppwd, vvalidado, voficina,
                                                       vtnombre, vsinterf, mensajes);

               IF vvalusu <> 0 THEN
                  vpasexec := 30;
                  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 110925, vpasexec,
                                                    vparam, NULL, SQLCODE, SQLERRM);
                  num_err := pac_md_login.f_set_log_conexion(pusuario, remoteip, vvalidado,
                                                             mensajes);
                  -- Añadido por pct bug 8352 (mantis)
                  RETURN 0;
               END IF;

               IF vvalidado = 1 THEN
                  vpasexec := 31;
                  pac_md_common.p_set_cxtagente(voficina);
                  vcrear := pac_parametros.f_parempresa_n(vempresa, 'CREAR_USUARIO');

                  --vpreval := pac_parametros.f_parempresa_n(vempresa, 'PRE_VALIDACIO');
                  IF vcrear = 1
                               /*AND vpreval = 1*/
                  THEN
                     vpasexec := 32;

                     IF ppwd IS NULL THEN
                        -- Generamos un password
                        SELECT TO_CHAR(SYSTIMESTAMP, 'DDMMYYYYHH24MISSFF3')
                          INTO vpwd
                          FROM DUAL;
                     ELSE
                        vpwd := ppwd;
                     END IF;

                     num_err := pac_md_user.f_creauserdefault(pusuario, vtnombre, voficina, 1,
                                                              vautologin, vpwd, vempresa,
                                                              mensajes);

                     IF num_err <> 0 THEN
                        vpasexec := 33;
                        pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1513255,
                                                          vpasexec, vparam, NULL, SQLCODE,
                                                          SQLERRM);
                        num_err := pac_md_login.f_set_log_conexion(pusuario, remoteip,
                                                                   vvalidado, mensajes);
                        -- Añadido por pct bug 8352 (mantis)
                        RETURN 0;
                     END IF;

                     --Confirmamos el usuario
                     COMMIT;
                     vpasexec := 34;
                     --Comprvem si cal realitzar obertura de "puesto"
                     vabrirp := pac_parametros.f_parempresa_n(vempresa, 'ABRIR_PUESTO');
                     vabrirp_usu :=
                        pac_cfg.f_get_user_accion_permitida(pac_md_common.f_get_cxtusuario,
                                                            'ABRIR_PUESTO', NULL, vempresa,   -- BUG9981:DRA:06/05/2009
                                                            vcrealiza);

                     IF vabrirp = 1
                        AND vabrirp_usu = 1 THEN
                        vpasexec := 35;
                        num_err := pac_md_user.f_set_termfisic(pusuario, pterminal, mensajes);

                        IF num_err <> 0 THEN
                           RAISE e_object_error;
                        END IF;

                        vpasexec := 36;
                        num_err := pac_md_con.f_abrir_puesto(pusuario, ppwd, vsinterf,
                                                             voficina, vtermlog, mensajes);

                        IF num_err <> 0 THEN
                           vpasexec := 37;
                           pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 9000555,
                                                             vpasexec, vparam, NULL, SQLCODE,
                                                             SQLERRM);
                           num_err := pac_md_login.f_set_log_conexion(pusuario, remoteip,
                                                                      vvalidado, mensajes);
                           -- Añadido por pct bug 8352 (mantis)
                           RETURN 0;
                        END IF;

                        vpasexec := 38;
                        pac_md_common.p_set_cxtterminal(vtermlog);
                        num_err := pac_md_user.f_setterminal(pusuario, vtermlog, mensajes);

                        IF num_err <> 0 THEN
                           RAISE e_object_error;
                        END IF;

                        -- Miramos si se actualiza la oficina
                        vpasexec := 39;
                        vactoficina := pac_parametros.f_parempresa_n(pempresa, 'ACT_OFICINA');

                        IF vactoficina = 1 THEN
                           vpasexec := 40;
                           num_err := pac_md_user.f_set_agente(pusuario, voficina, mensajes);
                        -- Se tiene que eliminar, tambien esta en pac_user y hacer un unico (f_set_terminal tambien)
                        END IF;

                        vpasexec := 41;

                        IF num_err <> 0 THEN
                           RETURN num_err;
                        END IF;
                     END IF;
                  ELSE
                     vpasexec := 42;
                     -- Si no tiene permiso para crear el usuario no dejamos entrar
                     num_err := pac_md_login.f_set_log_conexion(pusuario, remoteip, vvalidado,
                                                                mensajes);
                     -- Añadido por pct bug 8352 (mantis)
                     RETURN 0;
                  END IF;

                  vpasexec := 43;
                  inicializar_user;
                  vpasexec := 44;
                  num_err := pac_md_login.f_set_log_conexion(pusuario, remoteip, vvalidado,
                                                             mensajes);
                  -- Añadido por pct bug 8352 (mantis)
                  RETURN 1;
               ELSE
                  vpasexec := 45;
                  num_err := pac_md_login.f_set_log_conexion(pusuario, remoteip, vvalidado,
                                                             mensajes);
                  -- Añadido por pct bug 8352 (mantis)
                  RETURN 0;
               END IF;
            ELSE
               --BUG 11704: Si no tenemos validación cedida, miramos si creamos el usuario por defecto.
               --En ese caso dejamos entrar.
               vpasexec := 146;
               vcrear := pac_parametros.f_parempresa_n(vempresa, 'CREAR_USUARIO');
               vpreval := pac_parametros.f_parempresa_n(vempresa, 'PRE_VALIDACIO');

               IF vcrear = 1
                  AND vpreval = 1
                  AND poficina IS NOT NULL THEN
                  vpasexec := 132;

                  IF ppwd IS NULL THEN
                     -- Generamos un password
                     SELECT TO_CHAR(SYSTIMESTAMP, 'DDMMYYYYHH24MISSFF3')
                       INTO vpwd
                       FROM DUAL;
                  ELSE
                     vpwd := ppwd;
                  END IF;

                  num_err := pac_md_user.f_creauserdefault(pusuario, pusuario, poficina, 1,
                                                           vautologin, vpwd, vempresa,
                                                           mensajes);

                  IF num_err <> 0 THEN
                     vpasexec := 133;
                     pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1513255,
                                                       vpasexec, vparam, NULL, SQLCODE,
                                                       SQLERRM);
                     num_err := pac_md_login.f_set_log_conexion(pusuario, remoteip, vvalidado,
                                                                mensajes);
                     -- Añadido por pct bug 8352 (mantis)
                     RETURN 0;
                  END IF;

                  --Confirmamos el usuario
                  COMMIT;
                  -- Miramos si se actualiza la oficina
                  vactoficina := pac_parametros.f_parempresa_n(pempresa, 'ACT_OFICINA');

                  IF vactoficina = 1 THEN
                     vpasexec := 140;
                     num_err := pac_user.f_set_agente(pusuario, poficina);

                     IF pterminal IS NOT NULL THEN
                        num_err := pac_user.f_set_terminal(pusuario, pterminal);
                     END IF;

                     COMMIT;
                  END IF;

                  IF num_err <> 0 THEN
                     RETURN num_err;
                  END IF;

                  vpasexec := 159;
                  inicializar_user;
                  vpasexec := 160;
                  num_err := pac_md_login.f_set_log_conexion(pusuario, remoteip, vvalidado,
                                                             mensajes);
                  -- Añadido por pct bug 8352 (mantis)
                  RETURN 1;
               ELSE
                  vpasexec := 46;
                  num_err := pac_md_login.f_set_log_conexion(pusuario, remoteip, vvalidado,
                                                             mensajes);
                  -- Añadido por pct bug 8352 (mantis)
                  RETURN 0;
               END IF;
            END IF;

            vpasexec := 47;
         END IF;
      ELSE
         vpasexec := 48;
         -- Vamos por login
         -- Miramos si la validacion es cedida
         vvcedida := pac_parametros.f_parempresa_n(vempresa, 'VALCEDIDA');
         num_err := pac_md_user.f_useractivo(pusuario, vactivo, mensajes);

         IF num_err <> 0 THEN
            RAISE e_object_error;
         END IF;

         IF vactivo <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, pac_md_common.f_get_cxtidioma,
                                                 vactivo);
         ELSE
            IF vvcedida = 1 THEN
               vpasexec := 49;
               -- axis-connect
               -- Validamos el usuario y password
               vvalusu := pac_md_con.f_validar_usuario(pusuario, ppwd, vvalidado, voficina,
                                                       vtnombre, vsinterf, mensajes);

               IF vvalusu <> 0 THEN
                  vpasexec := 50;
                  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 110925, vpasexec,
                                                    vparam, NULL, SQLCODE, SQLERRM);
                  num_err := pac_md_login.f_set_log_conexion(pusuario, remoteip, vvalidado,
                                                             mensajes);
                  -- Añadido por pct bug 8352 (mantis)
                  RETURN 0;
               END IF;

               IF vvalidado = 1 THEN
                  vpasexec := 51;
                  --Comprovem si cal realitzar l'obertura de "puesto"
                  vabrirp := pac_parametros.f_parempresa_n(vempresa, 'ABRIR_PUESTO');
                  vabrirp_usu :=
                     pac_cfg.f_get_user_accion_permitida(pac_md_common.f_get_cxtusuario,
                                                         'ABRIR_PUESTO', NULL, vempresa,   -- BUG9981:DRA:06/05/2009
                                                         vcrealiza);
                  vpasexec := 52;

                  IF vabrirp = 1
                     AND vabrirp_usu = 1 THEN
                     vpasexec := 53;
                     num_err := pac_md_user.f_set_termfisic(pusuario, pterminal, mensajes);

                     IF num_err <> 0 THEN
                        RAISE e_object_error;
                     END IF;

                     vpasexec := 54;
                     num_err := pac_md_con.f_abrir_puesto(pusuario, ppwd, vsinterf, voficina,
                                                          vtermlog, mensajes);

                     IF num_err <> 0 THEN
                        vpasexec := 55;
                        pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 9000555,
                                                          vpasexec, vparam, NULL, SQLCODE,
                                                          SQLERRM);
                        num_err := pac_md_login.f_set_log_conexion(pusuario, remoteip,
                                                                   vvalidado, mensajes);
                        -- Añadido por pct bug 8352 (mantis)
                        RETURN 0;
                     END IF;

                     vpasexec := 56;
                     pac_md_common.p_set_cxtterminal(vtermlog);
                     num_err := pac_md_user.f_setterminal(pusuario, vtermlog, mensajes);

                     IF num_err <> 0 THEN
                        RAISE e_object_error;
                     END IF;

                     -- Miramos si se actualiza la oficina
                     vpasexec := 57;
                     vactoficina := pac_parametros.f_parempresa_n(pempresa, 'ACT_OFICINA');

                     IF vactoficina = 1 THEN
                        vpasexec := 58;
                        num_err := pac_md_user.f_set_agente(pusuario, voficina, mensajes);
                     -- Se tiene que eliminar, tambien esta en pac_user y hacer un unico (f_set_terminal tambien)
                     END IF;

                     IF num_err <> 0 THEN
                        RETURN num_err;
                     END IF;
                  END IF;

                  vpasexec := 59;
                  inicializar_user;
                  vpasexec := 60;
                  num_err := pac_md_login.f_set_log_conexion(pusuario, remoteip, vvalidado,
                                                             mensajes);
                  -- Añadido por pct bug 8352 (mantis)
                  RETURN 1;
               ELSE
                  vpasexec := 61;
                  num_err := pac_md_login.f_set_log_conexion(pusuario, remoteip, vvalidado,
                                                             mensajes);
                  -- Añadido por pct bug 8352 (mantis)
                  RETURN 0;
               END IF;
            ELSE
               vpasexec := 62;
               -- Validamos usuario en BBDD
               num_err := pac_md_user.f_validateuser(pusuario, ppwd, vrespuesta, vintentos,
                                                     mensajes);

               IF num_err <> 0 THEN
                  RAISE e_object_error;
               END IF;

               vpasexec := 71;
               --logeamos el usuario
               num_err := pac_iax_login.f_logea(pusuario, mensajes);

               IF num_err <> 0 THEN
                  RAISE e_object_error;
               END IF;

               IF vrespuesta = 1 THEN
                  vpasexec := 63;
                  --Comprovem si cal realitzar obertura de puesto
                  vabrirp := pac_parametros.f_parempresa_n(vempresa, 'ABRIR_PUESTO');
                  vabrirp_usu :=
                     pac_cfg.f_get_user_accion_permitida(pac_md_common.f_get_cxtusuario,
                                                         'ABRIR_PUESTO', NULL, vempresa,   -- BUG9981:DRA:06/05/2009
                                                         vcrealiza);
                  vpasexec := 64;

                  IF vabrirp = 1
                     AND vabrirp_usu = 1 THEN
                     vpasexec := 65;
                     num_err := pac_md_user.f_set_termfisic(pusuario, pterminal, mensajes);

                     IF num_err <> 0 THEN
                        RAISE e_object_error;
                     END IF;

                     vpasexec := 66;
                     num_err := pac_md_con.f_abrir_puesto(pusuario, ppwd, vsinterf, voficina,
                                                          vtermlog, mensajes);

                     IF num_err <> 0 THEN
                        vpasexec := 67;
                        pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 9000555,
                                                          vpasexec, vparam, NULL, SQLCODE,
                                                          SQLERRM);
                        num_err := pac_md_login.f_set_log_conexion(pusuario, remoteip,
                                                                   vrespuesta, mensajes);
                        -- Añadido por pct bug 8352 (mantis)
                        RETURN 0;
                     END IF;

                     vpasexec := 68;
                     pac_md_common.p_set_cxtterminal(vtermlog);
                     num_err := pac_md_user.f_setterminal(pusuario, vtermlog, mensajes);

                     IF num_err <> 0 THEN
                        RAISE e_object_error;
                     END IF;

                     -- Miramos si se actualiza la oficina
                     vpasexec := 69;
                     vactoficina := pac_parametros.f_parempresa_n(pempresa, 'ACT_OFICINA');

                     IF vactoficina = 1 THEN
                        vpasexec := 70;
                        num_err := pac_md_user.f_set_agente(pusuario, voficina, mensajes);
                     -- Se tiene que eliminar, tambien esta en pac_user y hacer un unico (f_set_terminal tambien)
                     END IF;

                     vpasexec := 71;

                     IF num_err <> 0 THEN
                        RETURN num_err;
                     END IF;
                  END IF;

                  vpasexec := 73;
                  inicializar_user;
                  vpasexec := 74;
                  num_err := pac_md_login.f_set_log_conexion(pusuario, remoteip, vrespuesta,
                                                             mensajes);
                  -- Añadido por pct bug 8352 (mantis)
                  RETURN 1;
               ELSE
                  vpasexec := 75;

                  IF vrespuesta = 0 THEN
                     pac_iobj_mensajes.crea_nuevo_mensaje(mensajes,
                                                          pac_md_common.f_get_cxtidioma,
                                                          700026);
                  ELSIF vrespuesta IN(1, 2) THEN
                     pac_iobj_mensajes.crea_nuevo_mensaje
                        (mensajes, 1, 9903629,
                         REPLACE
                            (pac_iobj_mensajes.f_get_descmensaje
                                                              (9903629,
                                                               pac_md_common.f_get_cxtidioma
                                                                                            ()),
                             '$$',
                             NVL(pac_md_common.f_get_parconexion('INTENTOS'), 0) - vintentos));
                  ELSIF vrespuesta = 3 THEN
                     pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9903630);
                  ELSIF vrespuesta = 4 THEN
                     pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9903637);
                  ELSIF vrespuesta = 5 THEN
                     pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9903639);
                  END IF;

                  num_err := pac_md_login.f_set_log_conexion(pusuario, remoteip, vrespuesta,
                                                             mensajes);
                  -- Añadido por pct bug 8352 (mantis)
                  RETURN 0;
               END IF;
            END IF;
         END IF;
      END IF;

      -- dra 18-12-2008: Pongo este Return 0 para que si hay error en el código de la función no deje entrar en la aplicación
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         num_err := pac_md_login.f_set_log_conexion(pusuario, remoteip, vvalidado, mensajes);
         -- Añadido por pct bug 8352 (mantis)
         RETURN 0;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         num_err := pac_md_login.f_set_log_conexion(pusuario, remoteip, vvalidado, mensajes);
         -- Añadido por pct bug 8352 (mantis)
         RETURN 0;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         num_err := pac_md_login.f_set_log_conexion(pusuario, remoteip, vvalidado, mensajes);
         -- Añadido por pct bug 8352 (mantis)
         RETURN 0;
   END f_iax_login;

   --BUG21762 - JTS - 24/05/2012
   FUNCTION f_limite_sesiones(mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vobjectname    VARCHAR2(500) := 'pac_iax_login.f_limite_sesiones';
      vparam         VARCHAR2(500);
      vnumerr        NUMBER;
   BEGIN
      IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa, 'LIMITA_SESIONES'),
             0) = 1 THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 0;
   END f_limite_sesiones;

   --BUG21762 - JTS - 20/03/2012
   FUNCTION f_logea(puser IN usuarios.cusuari%TYPE, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vobjectname    VARCHAR2(500) := 'pac_iax_login.F_logea';
      vparam         VARCHAR2(500) := 'parámetros - pUser: ' || puser;
      vnumerr        NUMBER;
   BEGIN
      IF f_limite_sesiones(mensajes) = 1 THEN
         vnumerr := pac_md_login.f_logea(puser, mensajes);
      ELSE
         vnumerr := 0;
      END IF;

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_logea;

   FUNCTION f_deslogea(puser IN usuarios.cusuari%TYPE, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vobjectname    VARCHAR2(500) := 'pac_iax_login.F_deslogea';
      vparam         VARCHAR2(500) := 'parámetros - pUser: ' || puser;
      vnumerr        NUMBER;
   BEGIN
      IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa, 'LIMITA_SESIONES'),
             0) = 1 THEN
         vnumerr := pac_md_login.f_deslogea(puser, mensajes);
      ELSE
         vnumerr := 0;
      END IF;

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_deslogea;
--Fi BUG21762
END pac_iax_login;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_LOGIN" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_LOGIN" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_LOGIN" TO "PROGRAMADORESCSI";
