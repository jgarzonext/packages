--------------------------------------------------------
--  DDL for Package Body PAC_MD_LOGIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_LOGIN" AS
/******************************************************************************
   NOMBRE:       PAC_MD_LOGIN
   PROPÓSITO:  Funciones para realizar una conexión
               a base de datos de la capa md

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        4/12/2008   PCT               1. Creación del package.
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*************************************************************************
      Función que insertará en la tabla log_conexión.
   *************************************************************************/
   FUNCTION f_set_log_conexion(
      pcusuari IN usuarios.cusuari%TYPE,
      remoteip IN VARCHAR2,
      valpaswd IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      lv_count       NUMBER(4) := 0;
      lv_error       NUMBER := 0;
   BEGIN
      IF mensajes IS NOT NULL THEN   ---pct. se comprueba si existen registros en t_iax_mensajes
         lv_count := mensajes.COUNT;
      END IF;

      IF lv_count = 0 THEN
         lv_error := pac_login.f_set_log_conexion(pcusuari, f_session, remoteip, f_sysdate,
                                                  NULL, NULL, valpaswd);

         IF lv_error <> 0 THEN
            RETURN 1;
         ELSE
            RETURN 0;
         END IF;
      ELSE
         FOR i IN mensajes.FIRST .. mensajes.LAST LOOP   -- pct. se graba el error en log_conexion
            IF mensajes.EXISTS(i) THEN
               lv_error := pac_login.f_set_log_conexion(pcusuari, f_session, remoteip,
                                                        f_sysdate, NULL, mensajes(i).terror,
                                                        valpaswd);

               IF lv_error <> 0 THEN
                  RETURN 1;
               ELSE
                  RETURN 0;
               END IF;
            END IF;
         END LOOP;
      END IF;
   END f_set_log_conexion;

   --BUG21762 - JTS - 20/03/2012
   FUNCTION f_logea(puser IN usuarios.cusuari%TYPE, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vobjectname    VARCHAR2(500) := 'pac_md_login.F_logea';
      vparam         VARCHAR2(500) := 'parámetros - pUser: ' || puser;
      vnumerr        NUMBER;
   BEGIN
      vnumerr := pac_user.f_logea(puser);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, pac_md_common.f_get_cxtidioma,
                                              vnumerr);
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

   FUNCTION f_deslogea(puser IN usuarios.cusuari%TYPE, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vobjectname    VARCHAR2(500) := 'pac_md_login.F_deslogea';
      vparam         VARCHAR2(500) := 'parámetros - pUser: ' || puser;
      vnumerr        NUMBER;
   BEGIN
      vnumerr := pac_user.f_deslogea(puser);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, pac_md_common.f_get_cxtidioma,
                                              vnumerr);
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
END pac_md_login;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_LOGIN" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_LOGIN" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_LOGIN" TO "PROGRAMADORESCSI";
