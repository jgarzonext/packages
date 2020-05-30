--------------------------------------------------------
--  DDL for Package Body PAC_IAX_TRAMITADORES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_TRAMITADORES" AS
/******************************************************************************
      NOMBRE:       PAC_IAX_TRAMITADORES
      PROPÃ“SITO:  Funciones para recuperar valores

      REVISIONES:
      Ver        Fecha        Autor   DescripciÃ³n
     ---------  ----------  ------   ------------------------------------
      1.0        07/05/2012   AMC     1. CreaciÃ³n del package.
      2.0        03/12/2012   JMF    0024964: LCOL_S001-SIN - Seleccion tramitador en alta siniestro (Id=2754)

   ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*************************************************************************
      Devuelve los siniestros que cumplan con el criterio de selección
      param in pnpoliza     : número de póliza
      param in pncert       : número de cerificado por defecto 0
      param in pnsinies     : número del siniestro1
      param in pcestsin     : Estado del siniestro
      param in pcramo       : Numero de ramo
      param in psproduc     : Numero de producto
      param in pfsinies     : Fecha del siniestro
      param in pctrami      : Codigo del tramitador
      param in pcactivi     : Codigo de la actividad
      param out mensajes    : mensajes de error
      return                : ref cursor

      Bug 21196/113187 - 07/05/2012 - AMC
   *************************************************************************/
   FUNCTION f_consulta_lstsini(
      pnpoliza IN NUMBER,
      pncertif IN NUMBER DEFAULT -1,
      pnsinies IN VARCHAR2,
      pcestsin IN NUMBER,
      pfiltro IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pfsinies IN DATE,
      pctrami IN VARCHAR2,
      pcactivi IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_TRAMITADORES.Consulta_lstsini';
      vparam         VARCHAR2(500)
         := 'parámetros - pnpoliza: ' || pnpoliza || ' - pnsinies: ' || pnsinies
            || ' - pncertif: ' || pncertif || ' - pcestsin: ' || pcestsin || ' - pcramo:'
            || pcramo || ' - psproduc:' || psproduc || ' - pfsinies:' || pfsinies
            || ' - pctrami:' || pctrami;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vcursor        sys_refcursor;
   BEGIN
      IF pctrami IS NULL THEN
         RAISE e_param_error;
      END IF;

      vcursor := pac_md_tramitadores.f_consulta_lstsini(pnpoliza, pncertif, pnsinies, pcestsin,
                                                        pfiltro, pcramo, psproduc, pfsinies,
                                                        pctrami, pcactivi, mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN vcursor;
      WHEN OTHERS THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN vcursor;
   END f_consulta_lstsini;

    /*************************************************************************
        FUNCTION f_get_tramitador
        Recupera els tramidors amb les seves descripcions
        param in pctramitad  : codi tramitador
        param out pttramitad  : Nombre de tramitador
        param out mensajes : missatges d'error
        return             : 0 - Ok ; 1 - Ko
   *************************************************************************/
   FUNCTION f_get_tramitador(
      pctramitad IN VARCHAR2,
      pttramitad OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parametres - pctramitad:' || pctramitad;
      vobject        VARCHAR2(200) := 'pac_iax_tramitadores.f_get_tramitador';
      vnumerr        NUMBER;
   BEGIN
      IF pctramitad IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      vnumerr := pac_md_tramitadores.f_get_tramitador(pctramitad, pttramitad, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
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
   END f_get_tramitador;

    /*************************************************************************
        FUNCTION f_cambio_tramitador
        Inserta el movimiento de cambio de tramitador
        param in pctramitad  : codi tramitador
        param in pcunitra : codi de la unidad de tramitacion
        param in pctramitad : codi del tramitador
        param out mensajes : missatges d'error
        return             : 0 - Ok ; 1 - Ko
   *************************************************************************/
   FUNCTION f_cambio_tramitador(
      psiniestros IN VARCHAR2,
      pcunitra IN VARCHAR2,
      pctramitad IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(4000) := 'parametres - psiniestros:' || psiniestros;
      vobject        VARCHAR2(200) := 'pac_iax_tramitadores.f_cambio_tramitador';
      vnumerr        NUMBER;
   BEGIN
      IF psiniestros IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      vnumerr := pac_md_tramitadores.f_cambio_tramitador(psiniestros, pcunitra, pctramitad,
                                                         mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_cambio_tramitador;

   /*************************************************************************
      Devuelve lista tramitadores para alta siniestro
      param in pcempres     : codigo empresa
      param out mensajes    : mensajes de error
      return                : ref cursor

      -- BUG 0024964 - 03/12/2012 - JMF
   *************************************************************************/
   FUNCTION f_get_tramitador_alta(pcempres IN NUMBER DEFAULT NULL, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_TRAMITADORES.f_get_tramitador_alta';
      vparam         VARCHAR2(500) := 'e=' || pcempres;
      vpasexec       NUMBER(5) := 1;
      vcursor        sys_refcursor;
      vemp           empresas.cempres%TYPE;
   BEGIN
      vemp := NVL(pcempres, f_empres);
      vcursor := pac_md_tramitadores.f_get_tramitador_alta(vemp, mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN vcursor;
      WHEN OTHERS THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN vcursor;
   END f_get_tramitador_alta;
END pac_iax_tramitadores;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_TRAMITADORES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_TRAMITADORES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_TRAMITADORES" TO "PROGRAMADORESCSI";
