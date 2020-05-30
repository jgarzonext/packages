--------------------------------------------------------
--  DDL for Package Body PAC_MD_TRAMITADORES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_TRAMITADORES" AS
/******************************************************************************
      NOMBRE:       PAC_MD_TRAMITADORES
      PROPÃ“SITO:  Funciones para recuperar valores

      REVISIONES:
      Ver        Fecha        Autor   Descripcion
     ---------  ----------  ------   ------------------------------------
      1.0        07/05/2012   AMC     1. Creacion del package.
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
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_TRAMITADORES.Consulta_lstsini';
      vparam         VARCHAR2(500)
         := 'parámetros - pnpoliza: ' || pnpoliza || ' - pnsinies: ' || pnsinies
            || ' - pncertif: ' || pncertif || ' - pcestsin: ' || pcestsin || ' - pcramo:'
            || pcramo || ' - psproduc:' || psproduc || ' - pfsinies:' || pfsinies
            || ' - pctrami:' || pctrami;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vcursor        sys_refcursor;
      vsquery        VARCHAR2(5000);
      vbuscar        VARCHAR2(2000);
      vsubus         VARCHAR2(500);
      vtabtp         VARCHAR2(10);
      vauxnom        VARCHAR2(200);
      vqueryfiltro   VARCHAR2(1200);
   BEGIN
      vpasexec := 1;

      IF pctrami IS NULL THEN
         RAISE e_param_error;
      END IF;

      vsquery :=
         ' select sm.nsinies,sm.ntramit,dt.ttramit,si.tsinies,si.fsinies,si.sseguro'
         || ' from sin_tramita_movimiento sm, sin_tramitacion st, sin_destramitacion dt, sin_siniestro si, sin_movsiniestro sv  '
         || ' where sm.ctramitad = ' || CHR(39) || pctrami || CHR(39)
         || ' and nmovtra = (select max(nmovtra) from sin_tramita_movimiento sm2 '
         || ' where sm2.nsinies = sm.nsinies and sm2.ntramit = sm.ntramit)'
         || ' and sm.nsinies = st.nsinies' || ' and sm.ntramit = st.ntramit'
         || ' and dt.ctramit = st.ctramit' || ' and dt.cidioma = '
         || pac_md_common.f_get_cxtidioma() || ' and si.nsinies = sm.nsinies'
         || ' and si.nsinies = sv.nsinies'
         || ' and sv.nmovsin = (select max(nmovsin) from sin_movsiniestro where nsinies = si.nsinies)';
      vpasexec := 2;

      IF pnsinies IS NOT NULL THEN
         vsquery := vsquery || ' and si.nsinies = ' || pnsinies;
      END IF;

      IF pcestsin IS NOT NULL THEN
         vsquery := vsquery || ' and sv.cestsin = ' || pcestsin;
      END IF;

      vpasexec := 3;

      IF pfsinies IS NOT NULL THEN
         vsquery := vsquery || ' and si.fsinies = ' || CHR(39) || pfsinies || CHR(39);
      END IF;

      vpasexec := 4;

      IF pcramo IS NOT NULL
         OR psproduc IS NOT NULL
         OR pnpoliza IS NOT NULL
         OR pcactivi IS NOT NULL THEN
         vsquery := vsquery || ' and si.sseguro in (select sseguro from seguros';

         IF pcramo IS NOT NULL THEN
            IF vbuscar IS NULL THEN
               vbuscar := ' where cramo = ' || pcramo;
            ELSE
               vbuscar := vbuscar || ' and cramo = ' || pcramo;
            END IF;
         END IF;

         IF psproduc IS NOT NULL THEN
            IF vbuscar IS NULL THEN
               vbuscar := ' where sproduc = ' || psproduc;
            ELSE
               vbuscar := vbuscar || ' and sproduc = ' || psproduc;
            END IF;
         END IF;

         IF pcactivi IS NOT NULL THEN
            IF vbuscar IS NULL THEN
               vbuscar := ' where cactivi = ' || pcactivi;
            ELSE
               vbuscar := vbuscar || ' and cactivi = ' || pcactivi;
            END IF;
         END IF;

         IF pnpoliza IS NOT NULL THEN
            IF vbuscar IS NULL THEN
               vbuscar := ' where npoliza = ' || pnpoliza;
            ELSE
               vbuscar := vbuscar || ' and npoliza = ' || pnpoliza;
            END IF;

            IF pncertif IS NOT NULL THEN
               vbuscar := vbuscar || ' and ncertif = ' || pncertif;
            END IF;
         END IF;

         vsquery := vsquery || vbuscar || ' )';
      END IF;

      vpasexec := 5;
      vsquery := vsquery || ' order by si.nsinies';
      vpasexec := 6;
      vcursor := pac_md_listvalores.f_opencursor(vsquery, mensajes);

      IF pac_md_log.f_log_consultas(vsquery, 'PAC_MD_TRAMITADORES.F_CONSULTASINI', 1, 4,
                                    mensajes) <> 0 THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;
      END IF;

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
        FUNCTION f_get_ctramitad
        Recupera els tramidors amb les seves descripcions
        param in pctramitad  : codi tramitador
        param in  out pttramitad  : Nombre de tramitador
        param out mensajes : missatges d'error
        return             : refcursor
   *************************************************************************/
   FUNCTION f_get_tramitador(
      pctramitad IN VARCHAR2,
      pttramitad IN OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parametres - pctramitad:' || pctramitad;
      vobject        VARCHAR2(200) := 'pac_md_tramitadores.f_get_tramitador';
      vnumerr        NUMBER;
   BEGIN
      IF pctramitad IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      vnumerr := pac_tramitadores.f_get_tramitador(pctramitad, pttramitad);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN 0;
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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(5000)
         := 'parametres - psiniestros:' || psiniestros || ' pcunitra:' || pcunitra
            || ' pctramitad:' || pctramitad;
      vobject        VARCHAR2(200) := 'pac_md_tramitadores.f_cambio_tramitador';
      vnumerr        NUMBER;
   BEGIN
      IF psiniestros IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      vnumerr := pac_tramitadores.f_cambio_tramitador(psiniestros, pcunitra, pctramitad);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      ELSE
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 9903673);
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
   END f_cambio_tramitador;

   /*************************************************************************
      Devuelve lista tramitadores para alta siniestro
      param in pcempres     : codigo empresa
      param out mensajes    : mensajes de error
      return                : ref cursor

      -- BUG 0024964 - 03/12/2012 - JMF
   *************************************************************************/
   FUNCTION f_get_tramitador_alta(pcempres IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_TRAMITADORES.f_get_tramitador_alta';
      vparam         VARCHAR2(500) := 'e=' || pcempres;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vcursor        sys_refcursor;
      vsquery        VARCHAR2(5000);
      vbuscar        VARCHAR2(2000);
      vsubus         VARCHAR2(500);
      vtabtp         VARCHAR2(10);
      vauxnom        VARCHAR2(200);
      vqueryfiltro   VARCHAR2(1200);
   BEGIN
      vpasexec := 1;

      IF pcempres IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vsquery :=
         'select CTRAMITAD, TTRAMITAD, decode(cusuari,f_user,1,0) CDEFECTO'
         || ' from  SIN_CODTRAMITADOR' || ' where cempres = ' || pcempres
         || ' and CTIPTRAMIT = 3
                      AND NVL(fbaja, f_sysdate) >= f_sysdate' || ' order by 2';   --BUG 29045:NSS:22/11/2013
      vpasexec := 3;
      vcursor := pac_md_listvalores.f_opencursor(vsquery, mensajes);
      vpasexec := 4;

      IF pac_md_log.f_log_consultas(vsquery, 'PAC_MD_TRAMITADORES.F_GET_TRAMITADOR_ALTA', 1, 4,
                                    mensajes) <> 0 THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;
      END IF;

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
END pac_md_tramitadores;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_TRAMITADORES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_TRAMITADORES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_TRAMITADORES" TO "PROGRAMADORESCSI";
