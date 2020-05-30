--------------------------------------------------------
--  DDL for Package Body PAC_IAX_EMPLEADOS_REPRESENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_EMPLEADOS_REPRESENT" IS
/******************************************************************************
   NOMBRE:       PAC_IAX_EMPLEADOS_REPRESENT
   PROPÓSITO:    Funciones para gestionar empleados y representantes

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        23/10/2012  MDS              1. Creación del package. 0022266: LCOL_P001 - PER - Mantenimiento de promotores, gestores, empleados, coordinador
   2.0        04/10/2013  JDS              2. 0028395: LCOL - PER - No aparece el campo “Compañía” al seleccionar la opción “Externo”

******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*************************************************************************
     Función que obtiene la lista de empleados
     param out mensajes  : t_iax_mensajes
     return              : sys_refcursor
    *************************************************************************/
   FUNCTION f_get_empleados(
      psperson IN NUMBER,
      pctipo IN NUMBER,
      pcsubtipo IN NUMBER,
      pccargo IN NUMBER,
      pccanal IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vnumerr        NUMBER := 0;
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_EMPLEADOS_REPRESENT.f_get_empleados';
      cur            sys_refcursor;
   BEGIN
      cur := pac_md_empleados_represent.f_get_empleados(psperson, pctipo, pcsubtipo, pccargo,
                                                        pccanal, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
   END f_get_empleados;

   /*************************************************************************
     Función que obtiene un empleado
     ...
     param out obempleado : ob_iax_empleado
     param out mensajes   : t_iax_mensajes
     return               : 0.- OK, 1.- KO
    *************************************************************************/
   FUNCTION f_get_empleado(
      psperson IN NUMBER,
      obempleado OUT ob_iax_empleado,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500) := 'parámetros - psperson: ' || psperson;
      vobject        VARCHAR2(200) := 'PAC_IAX_EMPLEADOS_REPRESENT.f_get_empleado';
   BEGIN
      -- Control parámetros entrada
      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      obempleado := pac_md_empleados_represent.f_get_empleado(psperson, mensajes);
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_empleado;

   /*************************************************************************
     Función que inserta/modifica un registro de empleado
     ...
     param out mensajes  : t_iax_mensajes
     return              : 0.- OK, 1.- KO
    *************************************************************************/
   FUNCTION f_set_empleado(
      psperson IN NUMBER,
      pctipo IN NUMBER,
      pcsubtipo IN NUMBER,
      pcargo IN NUMBER,
      pccanal IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500)
         := 'parámetros - psperson: ' || psperson || ' pctipo: ' || pctipo || ' pcsubtipo: '
            || pcsubtipo || ' pcargo: ' || pcargo || ' pccanal: ' || pccanal;
      vobject        VARCHAR2(200) := 'PAC_IAX_EMPLEADOS_REPRESENT.f_set_empleado';
   BEGIN
      -- Control parámetros entrada
      IF psperson IS NULL
         OR pctipo IS NULL
         OR pccanal IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 40202);
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_empleados_represent.f_set_empleado(psperson, pctipo, pcsubtipo, pcargo,
                                                           pccanal, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_empleado;

   /*************************************************************************
     Función que borra un registro de empleado
     ...
     param out mensajes  : t_iax_mensajes
     return              : 0.- OK, 1.- KO
    *************************************************************************/
   FUNCTION f_del_empleado(psperson IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500) := 'parámetros - psperson: ' || psperson;
      vobject        VARCHAR2(200) := 'PAC_IAX_EMPLEADOS_REPRESENT.f_del_empleado';
   BEGIN
      -- Control parámetros entrada
      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_empleados_represent.f_del_empleado(psperson, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_del_empleado;

   /*************************************************************************
     Función que obtiene la lista de representantes
     param out pcur      : sys_refcursor
     param out mensajes  : t_iax_mensajes
     return              : 0.- OK, 1.- KO
    *************************************************************************/
   FUNCTION f_get_representantes(
      psperson IN NUMBER,
      pctipo IN NUMBER,
      pcsubtipo IN NUMBER,
      ptcompania IN VARCHAR2,
      ptpuntoventa IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vnumerr        NUMBER := 0;
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_EMPLEADOS_REPRESENT.f_get_representantes';
      squery         VARCHAR2(3000);
      cur            sys_refcursor;
   BEGIN
      cur := pac_md_empleados_represent.f_get_representantes(psperson, pctipo, pcsubtipo,
                                                             ptcompania, ptpuntoventa,
                                                             mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
   END f_get_representantes;

   /*************************************************************************
     Función que obtiene un representante
     ...
     param out obrepresentante : ob_iax_representante
     param out mensajes        : t_iax_mensajes
     return                    : 0.- OK, 1.- KO
    *************************************************************************/
   FUNCTION f_get_representante(
      psperson IN NUMBER,
      obrepresentante OUT ob_iax_representante,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500) := 'parámetros - psperson: ' || psperson;
      vobject        VARCHAR2(200) := 'PAC_IAX_EMPLEADOS_REPRESENT.f_get_representante';
   BEGIN
      -- Control parámetros entrada
      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      obrepresentante := pac_md_empleados_represent.f_get_representante(psperson, mensajes);
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_representante;

   /*************************************************************************
     Función que inserta/modifica un registro de representante
     ...
     param out mensajes  : t_iax_mensajes
     return              : 0.- OK, 1.- KO
    *************************************************************************/
   FUNCTION f_set_representante(
      psperson IN NUMBER,
      pctipo IN NUMBER,
      pcsubtipo IN NUMBER,
      ptcompania IN VARCHAR2,
      ptpuntoventa IN VARCHAR2,
      pspercoord IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500)
         := 'parámetros - psperson: ' || psperson || ' pctipo: ' || pctipo || ' pcsubtipo: '
            || pcsubtipo || ' ptcompania: ' || ptcompania || ' ptpuntoventa: ' || ptpuntoventa
            || ' pspercoord: ' || pspercoord;
      vobject        VARCHAR2(200) := 'PAC_IAX_EMPLEADOS_REPRESENT.f_set_representante';
   BEGIN
      -- Control parámetros entrada
      IF psperson IS NULL
         OR pctipo IS NULL
         OR pcsubtipo IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 40202);
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_empleados_represent.f_set_representante(psperson, pctipo, pcsubtipo,
                                                                ptcompania, ptpuntoventa,
                                                                pspercoord, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_representante;

   /*************************************************************************
     Función que borra un registro de representante
     ...
     param out mensajes  : t_iax_mensajes
     return              : 0.- OK, 1.- KO
    *************************************************************************/
   FUNCTION f_del_representante(psperson IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500) := 'parámetros - psperson: ' || psperson;
      vobject        VARCHAR2(200) := 'PAC_IAX_EMPLEADOS_REPRESENT.f_del_representante';
   BEGIN
      -- Control parámetros entrada
      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_empleados_represent.f_del_representante(psperson, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_del_representante;
END pac_iax_empleados_represent;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_EMPLEADOS_REPRESENT" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_EMPLEADOS_REPRESENT" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_EMPLEADOS_REPRESENT" TO "PROGRAMADORESCSI";
