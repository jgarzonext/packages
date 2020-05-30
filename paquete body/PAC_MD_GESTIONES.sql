--------------------------------------------------------
--  DDL for Package Body PAC_MD_GESTIONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_GESTIONES" AS
/******************************************************************************
   NOMBRE:    PAC_MD_GESTIONES
   PROPÓSITO: Funciones para gestiones en siniestros

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
    1.0       24/08/2011   ASN             Creacion
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*************************************************************************
      Abre un cursor con la sentencia suministrada
      param in squery    : consulta a executar
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_opencursor(squery IN VARCHAR2, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(4000) := SUBSTR(squery, 1, 1900);
      vobject        VARCHAR2(200) := 'PAC_MD_LISTVALORES.F_OpenCursor';
      terror         VARCHAR2(200) := 'No se puede recuperar la información';
   BEGIN
      OPEN cur FOR squery;

      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_opencursor;

   FUNCTION f_get_gestiones(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN sin_tramitacion.ntramit%TYPE,
      t_gestiones OUT t_iax_sin_tramita_gestion,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      /*************************************************************************
         Llena objeto gestion para carga del bloque en tramitacion
         param in  pnsinies : numero de siniestro
         param in  pntramit : numero de tramitacion
         param out mensajes : mesajes de error
         return             : number
      *************************************************************************/
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_GESTIONES.F_Get_Gestiones ';
      terror         VARCHAR2(200) := ' Error recuperar gestiones';
      vquery         VARCHAR2(1000);
      vnerror        NUMBER;
      vcidioma       NUMBER;
      vobjgestion    ob_iax_sin_tramita_gestion;
      t_servicios    t_iax_sin_tramita_detgestion;
      t_movimientos  t_iax_sin_tramita_movgestion;
   BEGIN
      t_gestiones := t_iax_sin_tramita_gestion();
      vcidioma := pac_md_common.f_get_cxtidioma();
      vpasexec := 2;
      vnerror := pac_gestiones.f_gestiones(pnsinies, pntramit, vcidioma, vquery);

      IF vnerror <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnerror);
         RAISE e_object_error;
      END IF;

      vpasexec := 3;
      cur := f_opencursor(vquery, mensajes);
      vpasexec := 4;
      vobjgestion := ob_iax_sin_tramita_gestion();

      LOOP
         FETCH cur
          INTO vobjgestion.sseguro, vobjgestion.nsinies, vobjgestion.ntramit,
               vobjgestion.nlocali, vobjgestion.cgarant, vobjgestion.sgestio,
               vobjgestion.ctipreg, vobjgestion.ctipges, vobjgestion.ttipges,
               vobjgestion.sprofes, vobjgestion.tnompro, vobjgestion.ctippro,
               vobjgestion.csubpro, vobjgestion.tsubpro, vobjgestion.spersed,
               vobjgestion.tnomsed, vobjgestion.sconven, vobjgestion.ccancom,
               vobjgestion.ccomdef, vobjgestion.trefext, vobjgestion.fgestio;

         EXIT WHEN cur%NOTFOUND;
         t_gestiones.EXTEND;
         t_gestiones(t_gestiones.LAST) := ob_iax_sin_tramita_gestion();

         BEGIN
            SELECT cestges, csubges
              INTO vobjgestion.cestges, vobjgestion.csubges
              FROM sin_tramita_movgestion
             WHERE sgestio = vobjgestion.sgestio
               AND nmovges = (SELECT MAX(nmovges)
                                FROM sin_tramita_movgestion
                               WHERE sgestio = vobjgestion.sgestio);
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         t_gestiones(t_gestiones.LAST) := vobjgestion;
         vobjgestion := ob_iax_sin_tramita_gestion();
      END LOOP;

      vpasexec := 5;

      IF t_gestiones IS NOT NULL THEN
         IF t_gestiones.COUNT > 0 THEN
            FOR i IN t_gestiones.FIRST .. t_gestiones.LAST LOOP
               IF t_gestiones(i).sgestio IS NOT NULL THEN
                  vnerror := pac_md_gestiones.f_get_detgestiones(t_gestiones(i).sgestio,
                                                                 t_servicios, mensajes);

                  IF mensajes IS NOT NULL THEN
                     IF mensajes.COUNT > 0 THEN
                        RETURN 1;
                     END IF;
                  END IF;

                  t_gestiones(i).servicios := t_servicios;
                  vnerror := pac_md_gestiones.f_get_movgestiones(t_gestiones(i).sgestio,
                                                                 t_movimientos, mensajes);

                  IF mensajes IS NOT NULL THEN
                     IF mensajes.COUNT > 0 THEN
                        RETURN 1;
                     END IF;
                  END IF;

                  t_gestiones(i).movimientos := t_movimientos;
               END IF;
            END LOOP;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN 1;
   END f_get_gestiones;

   FUNCTION f_get_detgestiones(
      psgestio IN NUMBER,
      t_detgestiones OUT t_iax_sin_tramita_detgestion,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      /*************************************************************************
         Llena objeto servicios de una gestion para carga en el objeto gestion
         param in  psgestio       : numero de gestion
         param out t_detgestiones : t_iax_sin_tramita_detgestion
         param out mensajes       : mesajes de error
         return                   : number
      *************************************************************************/
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_GESTIONES.F_Get_Detgestiones ';
      terror         VARCHAR2(200) := ' Error recuperar movimientos de gestion ';
      vquery         VARCHAR2(1000);
      vnerror        NUMBER;
      vcidioma       NUMBER;
      vobjdetgestion ob_iax_sin_tramita_detgestion;
   BEGIN
      t_detgestiones := t_iax_sin_tramita_detgestion();
      vcidioma := pac_md_common.f_get_cxtidioma();

      IF psgestio IS NOT NULL THEN
         vnerror := pac_gestiones.f_servicios(psgestio, vcidioma, vquery);
      END IF;

      IF vnerror <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnerror);
         RAISE e_object_error;
      END IF;

      vpasexec := 2;
      cur := f_opencursor(vquery, mensajes);

      IF mensajes IS NOT NULL THEN
         IF mensajes.COUNT > 0 THEN
            RETURN 1;
         END IF;
      END IF;

      vpasexec := 3;
      vobjdetgestion := ob_iax_sin_tramita_detgestion();

      LOOP
         FETCH cur
          INTO vobjdetgestion.sgestio, vobjdetgestion.ndetges, vobjdetgestion.sservic,
               vobjdetgestion.tservic, vobjdetgestion.nvalser, vobjdetgestion.ncantid,
               vobjdetgestion.cnocarg, vobjdetgestion.cunimed, vobjdetgestion.tunimed,
               vobjdetgestion.itotal, vobjdetgestion.ccodmon, vobjdetgestion.tmoneda,
               vobjdetgestion.fcambio, vobjdetgestion.falta;   -- 25913:ASN:11/02/13

         EXIT WHEN cur%NOTFOUND;
         vpasexec := 4;
         t_detgestiones.EXTEND;
         t_detgestiones(t_detgestiones.LAST) := ob_iax_sin_tramita_detgestion();
         t_detgestiones(t_detgestiones.LAST) := vobjdetgestion;
      END LOOP;

      vpasexec := 5;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN 1;
   END f_get_detgestiones;

   FUNCTION f_get_movgestiones(
      psgestio IN NUMBER,
      t_movgestiones OUT t_iax_sin_tramita_movgestion,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      /*************************************************************************
         Llena objeto movimientos de una gestion para carga en el objeto gestion
         param in  psgestio       : numero de gestion
         param out t_movgestiones : t_iax_sin_tramita_movgestion
         param out mensajes       : mesajes de error
         return                   : number
      *************************************************************************/
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_GESTIONES.F_Get_Movgestiones ';
      terror         VARCHAR2(200) := ' Error recuperar movimientos de gestion ';
      vquery         VARCHAR2(1000);
      vnerror        NUMBER;
      vcidioma       NUMBER;
      vobjmovgestion ob_iax_sin_tramita_movgestion;
   BEGIN
      t_movgestiones := t_iax_sin_tramita_movgestion();
      vcidioma := pac_md_common.f_get_cxtidioma();
      vnerror := pac_gestiones.f_movimientos(psgestio, vcidioma, vquery);

      IF vnerror <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnerror);
         RAISE e_object_error;
      END IF;

      cur := f_opencursor(vquery, mensajes);

      IF mensajes IS NOT NULL THEN
         IF mensajes.COUNT > 0 THEN
            RETURN 1;
         END IF;
      END IF;

      vobjmovgestion := ob_iax_sin_tramita_movgestion();

      LOOP
         FETCH cur
          INTO vobjmovgestion.sgestio, vobjmovgestion.nmovges, vobjmovgestion.ctipmov,
               vobjmovgestion.ttipmov, vobjmovgestion.cestges, vobjmovgestion.testges,
               vobjmovgestion.csubges, vobjmovgestion.tsubges, vobjmovgestion.tcoment,
               vobjmovgestion.fmovini, vobjmovgestion.fmovfin, vobjmovgestion.finicio,
               vobjmovgestion.fproxim, vobjmovgestion.flimite, vobjmovgestion.faccion,
               vobjmovgestion.caccion, vobjmovgestion.ntotava, vobjmovgestion.nmaxava,
               vobjmovgestion.cusualt;

         EXIT WHEN cur%NOTFOUND;
         t_movgestiones.EXTEND;
         t_movgestiones(t_movgestiones.LAST) := ob_iax_sin_tramita_movgestion();
         vobjmovgestion.tdescri := ff_desvalorfijo(723, pac_md_common.f_get_cxtidioma,
                                                   vobjmovgestion.ctipmov);
         t_movgestiones(t_movgestiones.LAST) := vobjmovgestion;
         vobjmovgestion := ob_iax_sin_tramita_movgestion();
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN 1;
   END f_get_movgestiones;

   FUNCTION f_get_lstlocalizacion(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN sin_tramitacion.ntramit%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      /*************************************************************************
         Devuelve la lista de localizaciones
         param in  pnsinies : numero de siniestro
         param in  pntramit : numero de tramitacion
         param out mensajes : mesajes de error
         return             : ref cursor
      *************************************************************************/
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_GESTIONES.F_Get_Lstlocalizacion';
      terror         VARCHAR2(200) := ' Error recuperar localizaciones';
      vquery         VARCHAR2(1000);
      vnerror        NUMBER;
   BEGIN
      vnerror := pac_gestiones.f_lstlocalizacion(pnsinies, pntramit, vquery);

      IF vnerror <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnerror);
         RAISE e_object_error;
      END IF;

      cur := f_opencursor(vquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstlocalizacion;

   FUNCTION f_get_lsttipgestion(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pctramit IN sin_tramitacion.ctramit%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      /*************************************************************************
         Crea cursor para el valor fijo 722 - Tipo de Gestion
         param in  pnsinies : numero de siniestro
         param in  pctramit : tipo de tramitacion
         param out mensajes : mesajes de error
         return             : ref cursor
      *************************************************************************/
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_GESTIONES.F_Get_Lsttipgestion';
      terror         VARCHAR2(200) := ' Error recuperar tipos de gestion';
      vquery         VARCHAR2(1000);
      vnerror        NUMBER;
      vcidioma       NUMBER;
   BEGIN
      vcidioma := pac_md_common.f_get_cxtidioma();
      vnerror := pac_gestiones.f_lsttipgestion(pnsinies, pctramit, vcidioma, vquery);

      IF vnerror <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnerror);
         RAISE e_object_error;
      END IF;

      cur := f_opencursor(vquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lsttipgestion;

   FUNCTION f_get_lsttipprof(
      pctipges IN sin_tramita_gestion.ctipges%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      /*************************************************************************
         Crea cursor para el valor fijo 724 - Tipo Profesional
         param in  pctipges : tipo de gestion
         param out mensajes : mesajes de error
         return             : ref cursor
      *************************************************************************/
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_GESTIONES.F_Get_Lsttipprof ';
      terror         VARCHAR2(200) := ' Error recuperar tipos de profesional';
      vquery         VARCHAR2(1000);
      vcidioma       NUMBER;
      vnerror        NUMBER;
   BEGIN
      vcidioma := pac_md_common.f_get_cxtidioma();
      vnerror := pac_gestiones.f_lsttipprof(pctipges, vcidioma, vquery);

      IF vnerror <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnerror);
         RAISE e_object_error;
      END IF;

      cur := f_opencursor(vquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lsttipprof;

   FUNCTION f_get_lstsubprof(
      pctipges IN sin_tramita_gestion.ctipges%TYPE,
      pctippro IN sin_prof_tipoprof.ctippro%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      /*************************************************************************
         Crea cursor para el valor fijo 725 - Subtipo Profesional
         param in  pctipges : tipo de gestion
         param in  pctippro : tipo profesional
         param out mensajes : mesajes de error
         return             : ref cursor
      *************************************************************************/
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_GESTIONES.F_Get_Lstsubprof ';
      terror         VARCHAR2(200) := ' Error recuperar subtipos de profesional';
      vquery         VARCHAR2(1000);
      vcidioma       NUMBER;
      vnerror        NUMBER;
   BEGIN
      vcidioma := pac_md_common.f_get_cxtidioma();
      vnerror := pac_gestiones.f_lstsubprof(pctipges, pctippro, vcidioma, vquery);

      IF vnerror <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnerror);
         RAISE e_object_error;
      END IF;

      cur := f_opencursor(vquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstsubprof;

   FUNCTION f_get_lstprofesional(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN sin_tramitacion.ntramit%TYPE,
      pnlocali IN NUMBER,
      pctippro IN NUMBER,
      pcsubpro IN NUMBER,
      psgestio IN NUMBER DEFAULT NULL,   --26630
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      /*************************************************************************
          Devuelve query para carga lista de profesionales
          param in  pnsinies  : numero de siniestro
          param in  pntramit  : numero de tramitacion
          param in  pnlocali  : numero de localizacion
          param in  pctippro  : tipo de profesional
          param in  pcsubpro  : subtipo de profesional
       *************************************************************************/
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_GESTIONES.F_Get_Lstprofesionales ';
      terror         VARCHAR2(200) := ' Error recuperar lista de profesionales ';
      vcquery        NUMBER;
      vquery         VARCHAR2(2000);
      vnerror        NUMBER;
   BEGIN
      BEGIN
         SELECT NVL(cquery, 0)
           INTO vcquery
           FROM sin_prof_tipoprof
          WHERE ctippro = pctippro
            AND csubpro = pcsubpro;
      EXCEPTION
         WHEN OTHERS THEN
            vcquery := 0;
      END;

      IF vcquery = 1 THEN   -- solo seleccion por zona
         vnerror := pac_gestiones.f_lstprofesional1(pnsinies, pntramit, pnlocali, pctippro,
                                                    pcsubpro, vquery);
      ELSE   -- normal : zona + carga
         vnerror := pac_gestiones.f_lstprofesional(pnsinies, pntramit, pnlocali, pctippro,
                                                   pcsubpro, psgestio,   --26630
                                                   vquery);
      END IF;

      IF vnerror <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnerror);
         RAISE e_object_error;
      END IF;

      cur := f_opencursor(vquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstprofesional;

   FUNCTION f_get_lstsedes(psprofes IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      /*************************************************************************
         Crea cursor para la lista de sedes del Profesional
         param in  psprofes : codigo profesional
         param out mensajes : mesajes de error
         return             : ref cursor
      *************************************************************************/
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_GESTIONES.F_Get_Lstsedes ';
      terror         VARCHAR2(200) := ' Error recuperar lista de sedes ';
      vquery         VARCHAR2(1000);
      vnerror        NUMBER;
   BEGIN
      vnerror := pac_gestiones.f_lstsedes(psprofes, vquery);

      IF vnerror <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnerror);
         RAISE e_object_error;
      END IF;

      cur := f_opencursor(vquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstsedes;

   FUNCTION f_get_lsttarifas(
      psprofes IN NUMBER,
      pspersed IN NUMBER,
      pfecha IN DATE,
      pcconven IN NUMBER,   --26630
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      /*************************************************************************
         Crea cursor para la lista de convenios/baremos de un profesional
         param in  psprofes : codigo profesional
         param in  pspersed : clave sede (personas)
         param in  pfecha   : fecha de vigencia del convenio/baremo
         param out mensajes : mesajes de error
         return             : ref cursor
      *************************************************************************/
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_GESTIONES.F_Get_Lsttarifas ';
      terror         VARCHAR2(200) := ' Error recuperar lista de tarifas ';
      vquery         VARCHAR2(5000);
      vnerror        NUMBER;
      vcidioma       NUMBER;
   BEGIN
      vcidioma := pac_md_common.f_get_cxtidioma();
      vnerror := pac_gestiones.f_lsttarifas(psprofes, pspersed, pfecha, pcconven, vcidioma,   --26630
                                            vquery);

      IF vnerror <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnerror);
         RAISE e_object_error;
      END IF;

      cur := f_opencursor(vquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lsttarifas;

   FUNCTION f_get_lstgarantias(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pctipges IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      /*************************************************************************
         Crea cursor para la lista de garantias contratadas
         param in  nsinies  : numero de siniestro
         param in  ctipges  : tipo de gestion
         param out mensajes : mesajes de error
         return             : ref cursor
      *************************************************************************/
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_GESTIONES.F_Get_Lstgarantias ';
      terror         VARCHAR2(200) := ' Error recuperar las garantias de la poliza';
      vquery         VARCHAR2(1000);
      vcidioma       NUMBER;
      vnerror        NUMBER;
   BEGIN
      vcidioma := pac_md_common.f_get_cxtidioma();
      vnerror := pac_gestiones.f_lstgarantias(pnsinies, pctipges, vcidioma, vquery);

      IF vnerror <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnerror);
         RAISE e_object_error;
      END IF;

      cur := f_opencursor(vquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstgarantias;

   FUNCTION f_get_lstestados(
      pctipges IN NUMBER,
      pctipmov IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      /*************************************************************************
         Crea cursor para la lista de estados posibles para un tipo de gestion y movimiento
         param in  ctipges  : tipo de gestion
         param in  ctipmov  : movimiento
         param out mensajes : mesajes de error
         return             : ref cursor
      *************************************************************************/
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_GESTIONES.F_Get_Lstestados ';
      terror         VARCHAR2(200) := ' Error recuperar lista estados de gestion';
      vquery         VARCHAR2(1000);
      vcidioma       NUMBER;
      vnerror        NUMBER;
   BEGIN
      vcidioma := pac_md_common.f_get_cxtidioma();
      vnerror := pac_gestiones.f_lstestados(pctipges, pctipmov, vcidioma, vquery);

      IF vnerror <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnerror);
         RAISE e_object_error;
      END IF;

      cur := f_opencursor(vquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstestados;

   FUNCTION f_get_lstsubestados(
      pctipges IN NUMBER,
      pcestges IN NUMBER,
      pctipmov IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      /*************************************************************************
         Crea cursor para la lista de subestados posibles para un tipo de gestion, estado y movimiento
         param in  ctipges  : tipo de gestion
         param in  cestges  : estado gestion
         param in  ctipmov  : movimiento
         param out mensajes : mesajes de error
         return             : ref cursor
      *************************************************************************/
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_GESTIONES.F_Get_Lstsubestados ';
      terror         VARCHAR2(200) := ' Error recuperar lista subestados de gestion';
      vquery         VARCHAR2(1000);
      vcidioma       NUMBER;
      vnerror        NUMBER;
   BEGIN
      vcidioma := pac_md_common.f_get_cxtidioma();
      vnerror := pac_gestiones.f_lstsubestados(pctipges, pcestges, pctipmov, vcidioma, vquery);

      IF vnerror <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnerror);
         RAISE e_object_error;
      END IF;

      cur := f_opencursor(vquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstsubestados;

   FUNCTION f_get_lstmovimientos(
      pctipges IN NUMBER,
      pcestges IN NUMBER,
      pcsubges IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      /*************************************************************************
         Crea cursor de movimientos permitidos para una gestion en funcion del estado
         param in  ctipges  : tipo de gestion
         param in  cestges  : estado gestion
         param in  csubges  : subestado gestion
         param out mensajes : mesajes de error
         return             : ref cursor
      *************************************************************************/
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_GESTIONES.F_Get_Lstmovimientos ';
      terror         VARCHAR2(200) := ' Error recuperar lista movimientos permitidos';
      vquery         VARCHAR2(1000);
      vcidioma       NUMBER;
      vnerror        NUMBER;
   BEGIN
      vcidioma := pac_md_common.f_get_cxtidioma();
      vnerror := pac_gestiones.f_lstmovimientos(pctipges, pcestges, pcsubges, vcidioma,
                                                vquery);

      IF vnerror <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnerror);
         RAISE e_object_error;
      END IF;

      cur := f_opencursor(vquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstmovimientos;

   FUNCTION f_get_lstservicios(
      psservic IN NUMBER,
      ptdescri IN VARCHAR2,
      psconven IN NUMBER,
      pfecha IN DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      /*************************************************************************
         Crea cursor de servicios
         param in  sservic  : codigo de servicio
         param in  tdescri  : descripcion de servicio
         param in  sconven  : numero de convenio/baremo
         param in  fecha    : fecha de vigencia
         param out mensajes : mesajes de error
         return             : ref cursor
      *************************************************************************/
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_GESTIONES.F_Get_Lstservicios ';
      terror         VARCHAR2(200) := ' Error recuperar lista servicios ';
      vquery         VARCHAR2(2000);
      vcidioma       NUMBER;
      vnerror        NUMBER;
   BEGIN
      vpasexec := 11;
      vnerror := pac_gestiones.f_lstservicios(psservic, ptdescri, psconven, pfecha, vquery);
      vpasexec := 2;

      IF vnerror <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnerror);
         RAISE e_object_error;
      END IF;

      vpasexec := 3;
      cur := f_opencursor(vquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstservicios;

   FUNCTION f_get_precio_servicio(
      psconven IN NUMBER,
      pnvalser IN NUMBER,
      pccodmon IN VARCHAR2,
      pctipcal IN NUMBER,
      piprecio OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      /*************************************************************************
         Devuelve el precio de un servicio
         param in  sconven  : clave convenio/baremo
         param in  nvalser  : valor unitario
         param in  ccodmon  : codigo moneda
         param in  ctipcal  : tipo de calculo cambio
         param in  itotal   : total
         param in  iminimo  : importe minimo
         param out mensajes : mesajes de error
         return             : number 0/1
      *************************************************************************/
      vvalor_uni     NUMBER;
      vnvalser       NUMBER;
      vtermino       NUMBER;
      vcvalor        NUMBER;
      vctipo         NUMBER;
      vnimporte      NUMBER;
      vnporcent      NUMBER;
   BEGIN
      IF pctipcal = 1 THEN   -- moneda
         /*IF no es la moneda de la instalacion
            cambiar moneda
         END IF;*/
         piprecio := pnvalser;
      ELSIF pctipcal = 3 THEN   -- unidades valor relativo
         SELECT termino
           INTO vtermino
           FROM sin_prof_tarifa
          WHERE sconven = psconven;

         SELECT valor
           INTO vvalor_uni
           FROM sgt_parm_formulas
          WHERE clave = vtermino
            AND fecha_efecto = (SELECT MAX(fecha_efecto)
                                  FROM sgt_parm_formulas
                                 WHERE clave = vtermino
                                   AND fecha_efecto < f_sysdate);

         piprecio := pnvalser * vvalor_uni;
      ELSE
         NULL;
      END IF;

      SELECT cvalor, ctipo, nimporte, nporcent
        INTO vcvalor, vctipo, vnimporte, vnporcent
        FROM sin_prof_tarifa
       WHERE sconven = psconven;

      IF vctipo = 1 THEN
         piprecio := piprecio +(vcvalor * vnimporte);
      ELSIF vctipo = 2 THEN
         piprecio := piprecio +(((vnimporte / 100) * piprecio) * vcvalor);
      END IF;

      RETURN 0;
   END f_get_precio_servicio;

   FUNCTION f_get_imp_servicio(
      psconven IN NUMBER,
      pnvalser IN NUMBER,
      pccodmon IN VARCHAR2,
      pctipcal IN NUMBER,
      pncantid IN NUMBER,
      pcnocarg IN NUMBER,
      pitotal OUT NUMBER,
      piminimo OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      /*************************************************************************
         Devuelve el precio de un servicio
         param in  sconven  : clave convenio/baremo
         param in  nvalser  : valor unitario
         param in  ccodmon  : codigo moneda
         param in  ctipcal  : tipo de calculo cambio
         param in  ncantid  : cantidad
         param in  cnocarg  : 0 = sin cargo
         param in  itotal   : total
         param in  iminimo  : importe minimo
         param out mensajes : mesajes de error
         return             : number 0/1
      *************************************************************************/
      viprecio       NUMBER;
      vnumerr        NUMBER;
      vobjectname    VARCHAR2(500) := 'PAC_MD_GESTIONES.F_Get_Imp_Servicio';
      vparam         VARCHAR2(500) := 'parámetros - ';   -- --------------------------------- FALTA PARAMETROS
      vpasexec       NUMBER := 1;
   BEGIN
      IF pcnocarg = 0 THEN
         pitotal := 0;
      ELSE
         /*
         IF pctipcal = 1 THEN   -- moneda
            vnvalser := pnvalser;
         ELSIF pctipcal = 3 THEN   -- unidades valor relativo
            SELECT termino
              INTO vtermino
              FROM sin_prof_tarifa
             WHERE sconven = psconven;

            SELECT valor
              INTO vvalor_uni
              FROM sgt_parm_formulas
             WHERE codigo = vcodigo
               AND fecha_efecto = (SELECT MAX(fecha_efecto)
                                     FROM sgt_parm_formulas
                                    WHERE codigo = vcodigo
                                      AND fecha_efecto < f_sysdate);

            vnvalser := pnvalser * vvalor_uni;
         ELSE
            NULL;
         END IF;
         */
         vnumerr := f_get_precio_servicio(psconven, pnvalser, pccodmon, pctipcal, viprecio,
                                          mensajes);

         IF vnumerr <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
            RAISE e_object_error;
         END IF;

         pitotal := viprecio * pncantid;

         IF pitotal < piminimo THEN
            pitotal := piminimo;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_imp_servicio;

   FUNCTION f_set_obj_gestion(
      psseguro NUMBER,
      pnsinies VARCHAR2,
      pntramit NUMBER,
      pnlocali NUMBER,
      pcgarant NUMBER,
      psgestio NUMBER,
      pctipreg NUMBER,
      pctipges NUMBER,
      psprofes NUMBER,
      pctippro NUMBER,
      pcsubpro NUMBER,
      pspersed NUMBER,
      psconven NUMBER,
--      PCESTGES NUMBER,
--      PCSUBGES NUMBER,
      pccancom NUMBER,
      pccomdef NUMBER,
      ptrefext VARCHAR2,
      ptobserv VARCHAR2,
      pobjeto OUT ob_iax_sin_tramita_gestion,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
         /*************************************************************************
          Graba en una variable global de la capa IAX los valores del objeto ob_iax_gestion
            param in SSEGURO NUMBER 'Clave de la tabla SEGUROS',
            param in NSINIES VARCHAR2 'Numero de siniestro',
            param in NTRAMIT NUMBER 'Numero tramitacion',
            param in NLOCALI NUMBER 'Numero de localizacion',
            param in CGARANT NUMBER 'Codigo de garantia',
            param in SGESTIO NUMBER 'Secuencial. Codigo unico de gestion (PK)',
            param in CTIPREG NUMBER 'Tipo Registro: Varios, Peritaje, Gasto Sanitario, Mesa Repuestos.',
            param in CTIPGES NUMBER 'Tipo Gestion.',
            param in SPROFES NUMBER 'Clave de la tabla Profesionales',
            param in CTIPPRO NUMBER 'Tipo de profesional'
            param in CSUBPRO NUMBER 'Subtipo profesional'
            param in SPERSED NUMBER 'Clave de la sede (sperson)',
            param in SCONVEN NUMBER 'Numero de Convenio',
      --      param in CESTGES NUMBER 'Estado de la gestion',
      --      param in CSUBGES NUMBER 'Subestado de la gestion.',
            param in CCANCOM NUMBER 'Canal de comunicacion,
            param in CCOMDEF NUMBER 'Comunicacion por defecto (Mant. Proveedores) 0-No 1-Si',
            param in TREFEXT VARCHAR2 'Referencia externa',
            param in TOBSERV VARCHAR2 'Observaciones'
            param out mensajes : mesajes de error
            return             : 0/1
          *************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_MD_GESTIONES.f_set_obj_gestion';
      vparam         VARCHAR2(500) := 'parámetros - ';
      vpasexec       NUMBER(5) := 1;
   BEGIN
      pobjeto.sseguro := psseguro;
      pobjeto.nsinies := pnsinies;
      pobjeto.ntramit := pntramit;
      pobjeto.nlocali := pnlocali;
      pobjeto.cgarant := pcgarant;
      pobjeto.ctipreg := pctipreg;
      pobjeto.ctipges := pctipges;
      pobjeto.sprofes := psprofes;
      pobjeto.tnompro := pac_gestiones.f_nom_prof(psprofes);
      pobjeto.ctippro := pctippro;
      pobjeto.csubpro := pcsubpro;
      pobjeto.tsubpro := ff_desvalorfijo(725, pac_md_common.f_get_cxtidioma, pcsubpro);
      pobjeto.spersed := pspersed;
      pobjeto.tnomsed := f_nombre(pspersed, 1);
      pobjeto.sconven := psconven;
      pobjeto.ccancom := pccancom;
      pobjeto.ccomdef := pccomdef;
      pobjeto.trefext := ptrefext;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_obj_gestion;

   FUNCTION f_set_gestion(
      psseguro IN sin_tramita_gestion.sseguro%TYPE,
      pnsinies IN sin_tramita_gestion.nsinies%TYPE,
      pntramit IN sin_tramita_gestion.ntramit%TYPE,
      pcgarant IN sin_tramita_gestion.cgarant%TYPE,
      pctipreg IN sin_tramita_gestion.ctipreg%TYPE,
      pctipges IN sin_tramita_gestion.ctipges%TYPE,
      psprofes IN sin_tramita_gestion.sprofes%TYPE,
      pctippro IN sin_tramita_gestion.ctippro%TYPE,
      pcsubpro IN sin_tramita_gestion.csubpro%TYPE,
      pspersed IN sin_tramita_gestion.spersed%TYPE,
      psconven IN sin_tramita_gestion.sconven%TYPE,
      pccancom IN sin_tramita_gestion.ccancom%TYPE,
      pccomdef IN sin_tramita_gestion.ccomdef%TYPE,
      ptrefext IN sin_tramita_gestion.trefext%TYPE,
      pnlocali IN sin_tramita_gestion.nlocali%TYPE,   -- 27276
      pfgestio IN sin_tramita_gestion.fgestio%TYPE,   -- 26630
      psgestio OUT sin_tramita_gestion.sgestio%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
/*************************************************************************
  Graba una gestion
      param in SSEGURO NUMBER 'Clave de la tabla SEGUROS',
      param in NSINIES VARCHAR2 'Numero de siniestro',
      param in NTRAMIT NUMBER 'Numero tramitacion',
      param in NLOCALI NUMBER 'Numero de localizacion',
      param in CGARANT NUMBER 'Codigo de garantia',
      param in CTIPREG NUMBER 'Tipo Registro: Varios, Peritaje, Gasto Sanitario, Mesa Repuestos.',
      param in CTIPGES NUMBER 'Tipo Gestion.',
      param in SPROFES NUMBER 'Clave de la tabla Profesionales',
      param in SPERSED NUMBER 'Clave de la sede (sperson)',
      param in SCONVEN NUMBER 'Numero de Convenio',
      param in CESTGES NUMBER 'Estado de la gestion',
      param in CSUBGES NUMBER 'Subestado de la gestion.',
      param in CCANCOM NUMBER 'Canal de comunicacion,
      param in CCOMDEF NUMBER 'Comunicacion por defecto (Mant. Proveedores) 0-No 1-Si',
      param in TREFEXT VARCHAR2 'Referencia externa',
      param out SGESTIO NUMBER 'Secuencial. Codigo unico de gestion (PK)',
      param out mensajes : mesajes de error
      return             : 0/1
*************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_MD_GESTIONES.F_Set_Gestion';
      vparam         VARCHAR2(500) := 'parámetros - ';   -- --------------------------------- FALTA PARAMETROS
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vfsinies       DATE;
      vtmsg          VARCHAR2(1000);
      vsgestio       NUMBER;
      vtotal         NUMBER := 0;
   BEGIN
      vnumerr := pac_gestiones.f_ins_gestion(psseguro, pnsinies, pntramit, pcgarant, pctipreg,
                                             pctipges, psprofes, pctippro, pcsubpro, pspersed,
                                             psconven, pccancom, pccomdef, ptrefext, pnlocali,   -- 27276
                                             pfgestio,   -- 26630
                                             vsgestio);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      ELSE
         psgestio := vsgestio;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_set_gestion;

   FUNCTION f_set_detgestion(
      psgestio IN sin_tramita_detgestion.sgestio%TYPE,
      psservic IN sin_tramita_detgestion.sservic%TYPE,
      pncantid IN sin_tramita_detgestion.ncantid%TYPE,
      pcunimed IN sin_tramita_detgestion.cunimed%TYPE,
      pnvalser IN sin_tramita_detgestion.nvalser%TYPE,
      pcnocarg IN sin_tramita_detgestion.cnocarg%TYPE,
      pitotal IN sin_tramita_detgestion.itotal%TYPE,
      pccodmon IN sin_tramita_detgestion.ccodmon%TYPE,
      pfcambio IN sin_tramita_detgestion.fcambio%TYPE,
      pfalta IN sin_tramita_detgestion.falta%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
/*************************************************************************
  Graba una linea de detalle de gestion
  return              : NUMBER 0 / 1
*************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_MD_GESTIONES.F_Set_Detgestion';
      vparam         VARCHAR2(500) := ' parámetros - ';   -- --------------------------------- FALTA PARAMETROS
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vfsinies       DATE;
      vtmsg          VARCHAR2(1000);
      vsgestio       NUMBER;
      vtotal         NUMBER := 0;
   BEGIN
      vnumerr := pac_gestiones.f_ins_detgestion(psgestio, psservic, pncantid, pcunimed,
                                                pnvalser, pcnocarg, pitotal, pccodmon,
                                                pfcambio, pfalta);
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_set_detgestion;

   FUNCTION f_set_movgestion(
      psgestio IN sin_tramita_movgestion.sgestio%TYPE,
      pctipmov IN sin_tramita_movgestion.ctipmov%TYPE,
      pctipges IN sin_tramita_gestion.ctipges%TYPE,
      ptcoment IN sin_tramita_movgestion.tcoment%TYPE,
      pcestges IN sin_tramita_movgestion.cestges%TYPE,
      pcsubges IN sin_tramita_movgestion.csubges%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
/*************************************************************************
  Graba un movimiento de gestion
  param in  psgestio  : clave de sin_tramita_gestion
  param in  pctipmov  : moviento
  param in  pctipges  : tipo de gestion
  return              : NUMBER 0 / 1
*************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_MD_GESTIONES.F_Set_Movgestion';
      vparam         VARCHAR2(500) := ' parámetros - ';   -- --------------------------------- FALTA PARAMETROS
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vfsinies       DATE;
      vtmsg          VARCHAR2(1000);
      vsgestio       NUMBER;
      vtotal         NUMBER := 0;
   BEGIN
      vnumerr := pac_gestiones.f_ins_movgestion(psgestio, pctipmov, pctipges, ptcoment,
                                                pcestges, pcsubges);

      IF vnumerr <> 0 THEN
         RETURN vnumerr;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_set_movgestion;

   FUNCTION f_get_servicio(
      psconven IN NUMBER,
      psservic IN NUMBER,
      pncantid IN NUMBER,
      ptservic OUT VARCHAR2,
      pcunimed OUT NUMBER,
      ptunimed OUT VARCHAR2,
      pnvalser OUT NUMBER,
      pccodmon OUT VARCHAR2,
      ptmoneda OUT VARCHAR2,
      piminimo OUT NUMBER,
      pctipcal OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      /*************************************************************************

         Devuelve los datos de un servicio

         param out mensajes : mesajes de error

         return             : number 0/1

      *************************************************************************/
      vcidioma       NUMBER;
      vtraza         NUMBER;
      vparam         VARCHAR2(500)
         := 'parametros psconven=' || psconven || ' psservic=' || psservic || ' pncantid='
            || pncantid;
   BEGIN
      vcidioma := pac_md_common.f_get_cxtidioma();

      SELECT d.tdescri, d.cunimed, ff_desvalorfijo(734, 1, d.cunimed), d.iprecio, d.iminimo,
             d.ccodmon, d.ctipcal
        INTO ptservic, pcunimed, ptunimed, pnvalser, piminimo,
             pccodmon, pctipcal
        FROM sin_dettarifas d, sin_prof_tarifa t
       WHERE t.starifa = d.starifa
         AND t.sconven = psconven
         AND d.sservic = psservic;

      vtraza := 1;

      BEGIN
         SELECT cmoneda
           INTO ptmoneda
           FROM eco_codmonedas
          WHERE cmoneda = pccodmon;
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      vtraza := 2;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_MD_GESTIONES.F_GET_SERVICIO', vtraza, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1000455;
   END f_get_servicio;

   FUNCTION f_gestion_modificable(
      psgestio IN NUMBER,
      psi_o_no OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
/*************************************************************************
   Decide si una gestion esta en un estado modificable
*************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_MD_GESTIONES.F_gestion_modificable';
      vparam         VARCHAR2(500) := ' parámetros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_gestiones.f_gestion_modificable(psgestio, psi_o_no);

      IF vnumerr <> 0 THEN
         RETURN vnumerr;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_gestion_modificable;

   FUNCTION f_impacto_reserva(
      psgestio IN NUMBER,
      pctipges IN NUMBER,
      psi_o_no OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
/*************************************************************************
   Devuelve 1 si la gestion ha tenido impacto sobre la reserva
*************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_MD_GESTIONES.F_impacto_reserva';
      vparam         VARCHAR2(500)
                       := ' parámetros - psegestio= ' || psgestio || ' pctipges= ' || pctipges;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      FOR i IN (SELECT   creserv
                    FROM sin_parges_movimientos p, sin_tramita_movgestion m
                   WHERE m.ctipmov = p.ctipmov
                     AND p.ctipges = pctipges
                     AND m.sgestio = psgestio
                ORDER BY m.nmovges) LOOP
         IF NVL(i.creserv, 99) IN(1, 2) THEN
            psi_o_no := 1;
         ELSIF NVL(i.creserv, 99) = 0 THEN
            psi_o_no := 0;
         END IF;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_impacto_reserva;

   FUNCTION f_ajusta_reserva(
      psgestio IN NUMBER,
      psigno IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
/*************************************************************************
   Aumenta o disminuye la reserva para una gestion
*************************************************************************/
      vitotal        NUMBER;
      vccodmon       sin_tramita_detgestion.ccodmon%TYPE;
      vnerror        NUMBER;
      vobjectname    VARCHAR2(500) := 'PAC_MD_GESTIONES.F_ajusta_reserva';
      vparam         VARCHAR2(500)
                           := ' parámetros - psegestio= ' || psgestio || ' psigno= ' || psigno;
      vpasexec       NUMBER := 1;
   BEGIN
      SELECT SUM(itotal), MAX(ccodmon)
        INTO vitotal, vccodmon
        FROM sin_tramita_detgestion
       WHERE sgestio = psgestio;

      IF vitotal <> 0 THEN
         IF psigno = 1 THEN   -- constituir reserva
            vnerror := pac_gestiones.f_ajusta_reserva(psgestio, vitotal, vccodmon, 1);
         ELSE   -- liberar reserva
            vnerror := pac_gestiones.f_ajusta_reserva(psgestio, vitotal, vccodmon, 0);
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_ajusta_reserva;

   FUNCTION f_borra_detalle(psgestio IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnerror        NUMBER;
   BEGIN
      vnerror := pac_gestiones.f_borra_detalle(psgestio);

      IF vnerror <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnerror);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, 'PAC_MD_GESTIONES.F_borra_detalle',
                                           1000001, 1, 'Param - psgestio = ' || psgestio,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_borra_detalle;

   FUNCTION f_gestion_permitida(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pctipges IN NUMBER,
      ptlitera OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
/*************************************************************************
   Decide si una gestion se puede dar de alta
*************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_MD_GESTIONES.F_gestion_permitida';
      vparam         VARCHAR2(500) := ' parámetros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vcidioma       NUMBER;
   BEGIN
      vcidioma := pac_md_common.f_get_cxtidioma();
      vnumerr := pac_gestiones.f_gestion_permitida(pnsinies, pntramit, pctipges, vcidioma,
                                                   ptlitera);

      IF vnumerr <> 0 THEN
         RETURN vnumerr;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_gestion_permitida;

   FUNCTION f_estado_valoracion(
      psgestio IN NUMBER,
      pcsubges OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_GESTIONES.F_estado_valoracion';
      vparam         VARCHAR2(500) := ' parámetros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vcidioma       NUMBER;
   BEGIN
      vnumerr := pac_gestiones.f_estado_valoracion(psgestio, pcsubges);

      IF vnumerr <> 0 THEN
         RETURN vnumerr;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_estado_valoracion;

   FUNCTION f_get_servicios(
      psconven IN NUMBER,
      pstarifa IN NUMBER,
      pnlinea IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
/*************************************************************************
    Devuelve el servicio seleccionado o la lista, si es un servicio empaquetado
*************************************************************************/
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_GESTIONES.F_Get_servicios ';
      terror         VARCHAR2(200) := ' Error recuperar lista servicios ';
      vquery         VARCHAR2(2000);
      vnerror        NUMBER;
   BEGIN
      vpasexec := 11;
      vnerror := pac_gestiones.f_get_servicios(psconven, pstarifa, pnlinea, vquery);
      vpasexec := 2;

      IF vnerror <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnerror);
         RAISE e_object_error;
      END IF;

      vpasexec := 3;
      cur := f_opencursor(vquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_servicios;

--INI bug 26630
   FUNCTION f_get_cfecha(pctipges IN NUMBER, pcfecha OUT NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
/*************************************************************************
   Devuelve si se debe mostrar la fecha o no
*************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_MD_GESTIONES.f_get_cfecha';
      vparam         VARCHAR2(500) := ' parámetros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vcidioma       NUMBER;
   BEGIN
      vnumerr := pac_gestiones.f_get_cfecha(pctipges, pcfecha);

      IF vnumerr <> 0 THEN
         RETURN vnumerr;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_cfecha;

   FUNCTION f_usuario_permitido(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      psgestio IN NUMBER,
      pctipmov IN NUMBER,
      pcpermit OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
/*************************************************************************
   Devuelve si ese usuario puede realizar ese movimiento
*************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_MD_GESTIONES.f_usuario_permitido';
      vparam         VARCHAR2(500) := ' parámetros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_gestiones.f_usuario_permitido(pnsinies, pntramit, psgestio, pctipmov,
                                                   pcpermit);

      IF vnumerr <> 0 THEN
         RETURN vnumerr;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_usuario_permitido;

   FUNCTION f_cancela_pantalla(
      psconven IN NUMBER,
      psprofes IN NUMBER,
      pnsinies IN NUMBER,
      pntramit IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
/*************************************************************************
   Si se ha dado de alta algun convio temporal, se eliminan esos datos.
*************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_MD_GESTIONES.f_cancela_pantalla';
      vparam         VARCHAR2(500) := ' parámetros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_gestiones.f_cancela_pantalla(psconven, psprofes, pnsinies, pntramit);

      IF vnumerr <> 0 THEN
         RETURN vnumerr;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_cancela_pantalla;

   FUNCTION f_get_acceso_tramitador(
      pnsinies IN NUMBER,
      pntramit IN NUMBER,
      pcconven OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
/*************************************************************************
   Devuelve si el tramitador tiene acceso a convenios inactivos y temporales (0-No, 1-Si)
*************************************************************************/
      vobjectname    VARCHAR2(500) := 'PAC_MD_GESTIONES.f_get_acceso_tramitador';
      vparam         VARCHAR2(500) := ' parámetros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_gestiones.f_get_acceso_tramitador(pnsinies, pntramit, pcconven);

      IF vnumerr <> 0 THEN
         RETURN vnumerr;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_acceso_tramitador;
--FIN bug 26630
END pac_md_gestiones;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_GESTIONES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_GESTIONES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_GESTIONES" TO "PROGRAMADORESCSI";
