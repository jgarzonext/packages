--------------------------------------------------------
--  DDL for Package Body PAC_MD_EVENTOS_SIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_EVENTOS_SIN" AS
/******************************************************************************
   NOMBRE:    PAC_MD_EVENTOS_SIN
   PROPÓSITO: Funciones para la gestión de los eventos de un siniestro.

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        10/12/2009   AMC               1. Creación del package.
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*************************************************************************
      Función f_get_eventos
      Recupera los eventos
      param in pcevento  : codigo del evento
      param in ptevento  : texto del evento
      param in pfinicio  : fecha inicio
      param in pffinal   : fecha fin
      param out peventos : lista de eventos
      param out mensajes : mensajes de error
      return             : sys_refcursor

      -- Bug 12211 - 10/12/2009 - AMC
     *************************************************************************/
   FUNCTION f_get_eventos(
      pcevento IN VARCHAR2,
      ptevento IN VARCHAR2,
      pfinicio IN DATE,
      pffinal IN DATE,
      peventos OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'pcevento:' || pcevento || ' ptevento:' || ptevento || ' pfinicio:' || pfinicio
            || ' pffinal:' || pffinal;
      vobject        VARCHAR2(50) := 'PAC_MD_EVENTOS_SIN.f_get_eventos';
      vcursor        sys_refcursor;
      num_err        NUMBER;
   BEGIN
      num_err := pac_eventos_sin.f_get_eventos(pcevento, ptevento, pfinicio, pffinal,
                                               pac_md_common.f_get_cxtidioma(), peventos);

      IF num_err <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN num_err;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN 1;
   END f_get_eventos;

   /*************************************************************************
    Función f_get_evento
    Recupera lun evento
    param in pcevento  : codigo del evento
    param out pcevento_out
    param out PFINIEVE    : fecha inicio evento
    param out PFFINEVE    : fecha fin evento
    param out pdeseventos : lista de eventos
    param out mensajes    : mensajes de error
    return   0 - ok , 1 - ko

    -- Bug 12211 - 10/12/2009 - AMC
   *************************************************************************/
   FUNCTION f_get_evento(
      pcevento IN VARCHAR2,
      pcevento_out OUT VARCHAR2,   --se deja preparado por si alguna vez se tiene que devolver
      pfinieve OUT DATE,
      pffineve OUT DATE,
      pdeseventos OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'pcevento:' || pcevento;
      vobject        VARCHAR2(50) := 'PAC_IAX_EVENTOS_SIN.f_get_evento';
      num_err        NUMBER;
      vsquery        VARCHAR2(2000);
   BEGIN
      IF pcevento IS NOT NULL THEN
         num_err := pac_eventos_sin.f_get_codevento(pcevento, pcevento_out, pfinieve,
                                                    pffineve);
      END IF;

      num_err := pac_eventos_sin.f_get_desevento(pcevento, vsquery);
      pdeseventos := pac_md_listvalores.f_opencursor(vsquery, mensajes);
      RETURN 0;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_evento;

   /*************************************************************************
     Función f_set_codevento
     Función para insertar un evento
     param in pcevento  : codigo del evento
     param in PFINIEVE  : fecha inicio evento
     param in PFFINEVE  : fecha fin evento
     param out mensajes : mensajes de error
     return   0 - ok , 1 - ko

     -- Bug 12211 - 10/12/2009 - AMC
    *************************************************************************/
   FUNCTION f_set_codevento(
      pcevento IN VARCHAR2,
      pfinieve IN DATE,
      pffineve IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
            := 'pcevento:' || pcevento || ' pfinieve:' || pfinieve || ' pffineve:' || pffineve;
      vobject        VARCHAR2(50) := 'PAC_MD_EVENTOS_SIN.f_set_codevento';
      num_err        NUMBER;
   BEGIN
      IF pcevento IS NULL THEN
         RAISE e_param_error;
      END IF;

      num_err := pac_eventos_sin.f_set_codevento(pcevento, pfinieve, pffineve);

      IF num_err <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN num_err;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_codevento;

    /*************************************************************************
     Función f_del_evento
     Función para borrar un evento
     param in pcevento  : codigo del evento
     param out mensajes : mensajes de error
     return   0 - ok , 1 - ko

     -- Bug 12211 - 10/12/2009 - AMC
   *************************************************************************/
   FUNCTION f_del_evento(pcevento IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'pcevento:' || pcevento;
      vobject        VARCHAR2(50) := 'PAC_MD_EVENTOS_SIN.f_del_evento';
      num_err        NUMBER;
   BEGIN
      IF pcevento IS NULL THEN
         RAISE e_param_error;
      END IF;

      num_err := pac_eventos_sin.f_del_evento(pcevento);

      IF num_err <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN num_err;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_del_evento;

    /*************************************************************************
     Función f_set_desevento
     Función para insertar/actualizar la descripción de un evento
     param in pcevento  : codigo del evento
     param in pttiteve  : titulo del evento
     param in ptevento  : Descripción del evento
     param in pcidioma  : Codigo del idioma
     param out mensajes : mensajes de error
     return   0 - ok , 1 - ko

     -- Bug 12211 - 10/12/2009 - AMC
   *************************************************************************/
   FUNCTION f_set_desevento(
      pcevento IN VARCHAR2,
      pttiteve IN VARCHAR2,
      ptevento IN VARCHAR2,
      pcidioma IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'pcevento:' || pcevento || ' pttiteve:' || pttiteve || ' ptevento:' || ptevento
            || ' pcidioma:' || pcidioma;
      vobject        VARCHAR2(50) := 'PAC_MD_EVENTOS_SIN.f_set_desevento';
      num_err        NUMBER;
   BEGIN
      IF pcevento IS NULL
         OR pcidioma IS NULL THEN
         RAISE e_param_error;
      END IF;

      num_err := pac_eventos_sin.f_set_desevento(pcevento, pttiteve, ptevento, pcidioma);

      IF num_err <> 0 THEN
         RAISE e_object_error;
      END IF;

      FOR regs IN (SELECT cidioma
                     FROM idiomas
                    WHERE cvisible = 0) LOOP
         num_err := pac_eventos_sin.f_set_desevento(pcevento, pttiteve, ptevento,
                                                    regs.cidioma);

         IF num_err <> 0 THEN
            RAISE e_object_error;
         END IF;
      END LOOP;

      RETURN num_err;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_desevento;
END pac_md_eventos_sin;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_EVENTOS_SIN" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_EVENTOS_SIN" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_EVENTOS_SIN" TO "PROGRAMADORESCSI";
