--------------------------------------------------------
--  DDL for Package Body PAC_IAX_AGENDA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_AGENDA" AS
/******************************************************************************
   NOMBRE:      pac_iax_agenda
   PROPÃ“SITO:

   REVISIONES:
   Ver        Fecha        Autor             DescripciÃ³n
   ---------  ----------  ---------------  ------------------------------------
   1.0        19/11/2010   XPL               1. CreaciÃ³n del package.
   2.0        25/02/2011   JMF              0017744: CRT - Mejoras en agenda
   3.0        25/07/2011   ICV              0018845: CRT901 - Modificacionas tareas usuario: boton responder, grupos, envio de mail al crear tarea,etc
******************************************************************************/
   e_param_error  EXCEPTION;
   e_object_error EXCEPTION;
   gvisionrol     t_iax_agd_vision;
   gvisionusu     t_iax_agd_vision;

   FUNCTION f_get_lstapuntes(
      pidapunte IN NUMBER,
      pidagenda IN NUMBER,
      pcclagd IN NUMBER,
      ptclagd IN VARCHAR2,
      pcconapu IN NUMBER,
      pcestapu IN NUMBER,
      pcgrupo IN VARCHAR2,
      ptgrupo IN VARCHAR2,
      pttitapu IN VARCHAR2,
      pctipapu IN NUMBER,
      pcperagd IN NUMBER,
      pcambito IN NUMBER,
      pcpriori IN NUMBER,
      pfapunte IN DATE,
      pfalta IN DATE,
      pfrecordatorio IN DATE,
      pcusuari IN VARCHAR2,
      pcapuage IN VARCHAR2,
      pntramit IN NUMBER DEFAULT NULL,
      plstagenda OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vsquery        VARCHAR2(5000);
      vobjectname    VARCHAR2(500) := 'PAC_IAX_AGENDA.f_get_lstapuntes';
      vparam         VARCHAR2(1000)
         := 'parámetros - pidapunte: ' || pidapunte || ' pidagenda:' || pidagenda
            || ' pcclagd:' || pcclagd || ' ptclagd:' || ptclagd || ' pcconapu:' || pcconapu
            || ' pcestapu:' || pcestapu || ' pcgrupo:' || pcgrupo || ' ptgrupo:' || ptgrupo
            || ' pttitapu:' || pttitapu || ' pctipapu:' || pctipapu || ' pcperagd:'
            || pcperagd || ' pcambito:' || pcambito || ' pcpriori:' || pcpriori
            || ' pfapunte:' || pfapunte || ' pfalta:' || pfalta|| ' pntramit:' || pntramit;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vquery         VARCHAR2(3000);
   BEGIN
      -- Bug 0017744 - 25/02/2011 - JMF
      vnumerr := pac_md_agenda.f_get_lstapuntes(pidapunte, pidagenda, pcclagd, ptclagd,
                                                pcconapu, pcestapu, pcgrupo, ptgrupo,
                                                pttitapu, pctipapu, pcperagd, pcambito,
                                                pcpriori, pfapunte, pfalta, pfrecordatorio,
                                                pcusuari, pcapuage, pntramit, plstagenda, mensajes);

      IF vnumerr != 0 THEN
         RAISE e_object_error;
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
   END f_get_lstapuntes;

   FUNCTION f_get_agenda(
      pidapunte IN NUMBER,
      pidagenda IN NUMBER,
      pobagenda OUT ob_iax_agenda,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      cur            sys_refcursor;
      vsquery        VARCHAR2(5000);
      vobjectname    VARCHAR2(500) := 'PAC_IAX_AGENDA.f_get_agenda';
      vparam         VARCHAR2(1000)
                     := 'parámetros - pidapunte: ' || pidapunte || ' pidagenda:' || pidagenda;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vquery         VARCHAR2(3000);
   BEGIN
      vnumerr := pac_md_agenda.f_get_agenda(pidapunte, pidagenda, pobagenda, mensajes);

      IF vnumerr != 0 THEN
         RAISE e_object_error;
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
   END f_get_agenda;

   FUNCTION f_get_lstagdtareas(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      plstagenda OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_AGENDA.f_get_lstagdtareas';
      vparam         VARCHAR2(1000) := 'parámetros - pnsinies: ' || pnsinies || ' pntramit:' || pntramit;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_agenda.f_get_lstagdtareas(pnsinies, pntramit, plstagenda, mensajes);

      IF vnumerr != 0 THEN
         RAISE e_object_error;
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
   END f_get_lstagdtareas;

   FUNCTION f_set_agenda(
      pidapunte IN NUMBER,
      pidagenda IN NUMBER,
      pcclagd IN NUMBER,
      ptclagd IN VARCHAR2,
      pcconapu IN NUMBER,
      pcestapu IN NUMBER,
      pcgrupo IN VARCHAR2,
      ptgrupo IN VARCHAR2,
      pttitapu IN VARCHAR2,
      ptapunte IN VARCHAR2,
      pctipapu IN NUMBER,
      pcperagd IN NUMBER,
      pcambito IN NUMBER,
      pcpriori IN NUMBER,
      pcusuari IN VARCHAR2,
      pfapunte IN DATE,
      pfestapu IN DATE,
      pfalta IN DATE,
      pfrecordatorio IN DATE,
      pcusuari_ori IN VARCHAR2 DEFAULT NULL,
      pcgrupo_ori IN VARCHAR2 DEFAULT NULL,
      ptgrupo_ori IN VARCHAR2 DEFAULT NULL,
      pidapunte_out OUT VARCHAR2,
      MENSAJES OUT T_IAX_MENSAJES,
      PTRESP IN VARCHAR2 default null, --CONF-347-01/12/2016-RCS
      pntramit IN NUMBER default null)
      RETURN NUMBER IS
      cur            sys_refcursor;
      vsquery        VARCHAR2(5000);
      vobjectname    VARCHAR2(500) := 'PAC_IAX_AGENDA.f_set_agenda';
      vparam         VARCHAR2(1000)
         := 'parámetros - pidapunte: ' || pidapunte || ' pidagenda:' || pidagenda
            || ' pcclagd:' || pcclagd || ' ptclagd:' || ptclagd || ' pcconapu:' || pcconapu
            || ' pcestapu:' || pcestapu || ' pcgrupo:' || pcgrupo || ' ptgrupo:' || ptgrupo
            || ' pttitapu:' || pttitapu || ' pctipapu:' || pctipapu || ' pcperagd:'
            || pcperagd || ' pcambito:' || pcambito || ' pcpriori:' || pcpriori
            || ' pfapunte:' || pfapunte || ' pfalta:' || pfalta;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vtext          VARCHAR2(200);
   BEGIN
      --18845 - 25/07/2011 - ICV - Se añaden los campos de origen
      vnumerr := pac_md_agenda.f_set_agenda(pidapunte, pidagenda, pcclagd, ptclagd, pcconapu,
                                            pcestapu, pcgrupo, ptgrupo, pttitapu, ptapunte,
                                            pctipapu, pcperagd, pcambito, pcpriori, pcusuari,
                                            pfapunte, pfestapu, pfalta, pfrecordatorio,
                                            pcusuari_ori, pcgrupo_ori, ptgrupo_ori,
                                            pidapunte_out, mensajes,PTRESP, pntramit); --CONF-347-01/12/2016-RCS

      IF vnumerr != 0 THEN
         RAISE e_object_error;
      END IF;

      IF pidapunte IS NULL THEN
         vtext := f_axis_literales(9001332, pac_iax_common.f_get_cxtidioma);
         vtext := vtext || ' - ' || f_axis_literales(9001189, pac_iax_common.f_get_cxtidioma)
                  || ' : ' || pidapunte_out;
      ELSE
         vtext := f_axis_literales(9001895, pac_iax_common.f_get_cxtidioma);
         vtext := vtext || ' ' || f_axis_literales(9001189, pac_iax_common.f_get_cxtidioma)
                  || ' : ' || pidapunte_out;
      END IF;

      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, NULL, vtext);
      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_agenda;

   FUNCTION f_get_valoresgrupo(
      pcgrupo IN VARCHAR2,
      pctodos IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vsquery        VARCHAR2(5000);
      vobjectname    VARCHAR2(500) := 'PAC_IAX_AGENDA.f_get_grupo';
      vparam         VARCHAR2(1000)
                            := 'parámetros - pcgrupo: ' || pcgrupo || ' pctodos: ' || pctodos;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vquery         VARCHAR2(3000);
      cur            sys_refcursor;
   BEGIN
      cur := pac_md_agenda.f_get_valoresgrupo(pcgrupo, pctodos, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN NULL;
   END f_get_valoresgrupo;

   FUNCTION f_convertir_varchar_coleccion(pparams IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN t_iax_info IS
      vsquery        VARCHAR2(5000);
      vobjectname    VARCHAR2(500) := 'PAC_IAX_AGENDA.f_convertir_varchar_coleccion';
      vparam         VARCHAR2(1000) := 'parámetros - pparams :';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vtinfo         t_iax_info := t_iax_info();
      tipo           VARCHAR2(4000);
      nombre_columna VARCHAR2(1000);
      valor_columna  VARCHAR2(4000);
      vinfo          ob_iax_info;
      pos            NUMBER;
      posdp          NUMBER;
      posvalor       NUMBER;
   BEGIN
      vtinfo := t_iax_info();

      FOR i IN 1 .. LENGTH(pparams) LOOP
         pos := INSTR(pparams, '#', 1, i);
         posdp := INSTR(pparams, '#', 1, i + 1);
         tipo := SUBSTR(pparams, NVL(pos, 0) + 1,(posdp - NVL(pos, 0)) - 1);
         posvalor := INSTR(tipo, ';', 1, 1);
         nombre_columna := SUBSTR(tipo, 1, posvalor - 1);

         IF nombre_columna != 'TOBS' THEN
            valor_columna := SUBSTR(tipo, posvalor + 1);

            IF valor_columna IS NOT NULL THEN
               vinfo := ob_iax_info();
               vtinfo.EXTEND;
               vinfo.nombre_columna := nombre_columna;
               vinfo.valor_columna := valor_columna;
               vtinfo(vtinfo.LAST) := vinfo;
            END IF;
         END IF;
      END LOOP;

      RETURN vtinfo;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN NULL;
   END f_convertir_varchar_coleccion;

    /*************************************************************************
      Devuelve la lista de todas las observaciones por tipo de agenda y según la visibilidad
      del usuario, de su rol o del rol propietario de la agenda
      param in pctipagd     : Tipo de Agenda (póliza, recibo, siniestro...)
      param in pparams       : Parametros para filtrar y su valor
      return                : 0/1 OK/KO
   *************************************************************************/
   FUNCTION f_get_lstagdobs(
      pctipagd IN NUMBER,
      pidobs IN NUMBER,
      pparams IN VARCHAR2,
      plstagdobs OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vsquery        VARCHAR2(5000);
      vobjectname    VARCHAR2(500) := 'PAC_IAX_AGENDA.f_get_lstagdobs';
      vparam         VARCHAR2(1000) := 'parámetros - pctipagd :' || pctipagd;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vparams        t_iax_info;
   BEGIN
      vparams := f_convertir_varchar_coleccion(pparams, mensajes);
      vnumerr := pac_md_agenda.f_get_lstagdobs(pctipagd, pidobs, vparams, plstagdobs,
                                               mensajes);

      IF vnumerr != 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

         IF plstagdobs%ISOPEN THEN
            CLOSE plstagdobs;
         END IF;

         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);

         IF plstagdobs%ISOPEN THEN
            CLOSE plstagdobs;
         END IF;

         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);

         IF plstagdobs%ISOPEN THEN
            CLOSE plstagdobs;
         END IF;

         RETURN 1;
   END f_get_lstagdobs;

   /*************************************************************************
      devolvemos la entidad dependiendo de la parametrización hecha en la tabla
      agd_obs_config. Según el tipo de agenda nos devolverá NPOLIZA - NCERTIF, NRECIBO, Nombre del agente...
      param in pctipagd     : Tipo de Agenda (póliza, recibo, siniestro...)
      param in pparams       : Parametros para filtrar y su valor
      return                : 0/1 OK/KO
   *************************************************************************/
   FUNCTION f_get_entidad(
      pctipagd IN NUMBER,
      pparams IN VARCHAR2,
      ptentidad OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vsquery        VARCHAR2(5000);
      vobjectname    VARCHAR2(500) := 'PAC_IAX_AGENDA.f_get_entidad';
      vparam         VARCHAR2(1000) := 'parámetros - pctipagd :' || pctipagd;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vparams        t_iax_info;
   BEGIN
      vparams := f_convertir_varchar_coleccion(pparams, mensajes);
      vnumerr := pac_md_agenda.f_get_entidad(pctipagd, vparams, ptentidad, mensajes);

      IF vnumerr != 0 THEN
         RAISE e_object_error;
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
   END f_get_entidad;

    /*************************************************************************
      Devuelve la lista de los conceptos según el tipo de agenda
      del usuario, de su rol o del rol propietario de la agenda
      param in pctipagd     : Tipo de Agenda (póliza, recibo, siniestro...)
      param out plstconceptos       : Cursor con los conceptos a mostrar
      return                : 0/1 OK/KO
   *************************************************************************/
   FUNCTION f_get_lstconceptos(
      pctipagd IN NUMBER,
      pcmodo IN VARCHAR2,
      plstconceptos OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vsquery        VARCHAR2(5000);
      vobjectname    VARCHAR2(500) := 'PAC_IAX_AGENDA.f_get_lstconceptos';
      vparam         VARCHAR2(1000) := 'parámetros - pctipagd :' || pctipagd;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_agenda.f_get_lstconceptos(pctipagd,pcmodo, plstconceptos, mensajes);

      IF vnumerr != 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

         IF plstconceptos%ISOPEN THEN
            CLOSE plstconceptos;
         END IF;

         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);

         IF plstconceptos%ISOPEN THEN
            CLOSE plstconceptos;
         END IF;

         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);

         IF plstconceptos%ISOPEN THEN
            CLOSE plstconceptos;
         END IF;

         RETURN 1;
   END f_get_lstconceptos;

   /*************************************************************************
      Devuelve la lista de los tipos de agenda
      param out pquery       : query que devolveremos
      return                : 0/1 OK/KO
   *************************************************************************/
   FUNCTION f_get_lsttiposagenda(plsttiposagenda OUT sys_refcursor, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vsquery        VARCHAR2(5000);
      vobjectname    VARCHAR2(500) := 'PAC_IAX_AGENDA.f_get_lsttiposagenda';
      vparam         VARCHAR2(1000) := 'parámetros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_agenda.f_get_lsttiposagenda(plsttiposagenda, mensajes);

      IF vnumerr != 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

         IF plsttiposagenda%ISOPEN THEN
            CLOSE plsttiposagenda;
         END IF;

         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);

         IF plsttiposagenda%ISOPEN THEN
            CLOSE plsttiposagenda;
         END IF;

         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);

         IF plsttiposagenda%ISOPEN THEN
            CLOSE plsttiposagenda;
         END IF;

         RETURN 1;
   END f_get_lsttiposagenda;

   /*************************************************************************
          Devuelve la lista de los roles de la agenda, si nos pasan el tipo de agenda no devolveremos el rol
          propietario ya que no se podrá gestionar este rol, siempre será visible
          pctipagd IN NUMBER,
          plstroles OUT sys_refcursor       : cursor que devolveremos
          return                : 0/1 OK/KO
       *************************************************************************/
   FUNCTION f_get_lstroles(
      pctipagd IN NUMBER,
      plstroles OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vsquery        VARCHAR2(5000);
      vobjectname    VARCHAR2(500) := 'PAC_IAX_AGENDA.f_get_lstroles';
      vparam         VARCHAR2(1000) := 'parámetros - pctipagd :' || pctipagd;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_agenda.f_get_lstroles(pctipagd, plstroles, mensajes);

      IF vnumerr != 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

         IF plstroles%ISOPEN THEN
            CLOSE plstroles;
         END IF;

         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);

         IF plstroles%ISOPEN THEN
            CLOSE plstroles;
         END IF;

         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);

         IF plstroles%ISOPEN THEN
            CLOSE plstroles;
         END IF;

         RETURN 1;
   END f_get_lstroles;

   FUNCTION f_set_obs(
      pidobs IN NUMBER,
      pcconobs IN NUMBER,
      pctipobs IN NUMBER,
      pttitobs IN VARCHAR2,
      ptobs IN VARCHAR2,
      pfobs IN DATE,
      pfrecordatorio IN DATE,
      pctipagd IN NUMBER,
      pcambito IN NUMBER,
      pcpriori IN NUMBER,
      pcprivobs IN NUMBER,
      ppublico IN NUMBER,
      pcestobs IN NUMBER,
      pfestobs IN DATE,
      pttipagd IN VARCHAR2,
      pidobs_out OUT VARCHAR2,
      pdescripcion IN VARCHAR2,
      ptfilename IN VARCHAR2,
      piddocgedox IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      cur            sys_refcursor;
      vsquery        VARCHAR2(5000);
      vobjectname    VARCHAR2(500) := 'PAC_IAX_AGENDA.f_set_obs';
      vparam         VARCHAR2(1000)
         := 'parámetros - pidobs: ' || pidobs || ' cconobs:' || pcconobs || ' pctipobs:'
            || pctipobs || ' pfobs:' || pfobs || ' pfrecordatorio:' || pfrecordatorio
            || ' pctipagd:' || pctipagd || ' pcambito:' || pcambito || ' pcpriori:'
            || pcpriori || ' pcprivobs:' || pcprivobs || ' pcestobs:' || pcestobs
            || ' pfestobs:' || pfestobs || ' ppublico:' || ppublico;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vtext          VARCHAR2(200);
      vttipagd       t_iax_info;
      viddocgedox    NUMBER;
      pidcat         NUMBER := 8;
   BEGIN
      vttipagd := f_convertir_varchar_coleccion(pttipagd, mensajes);
    vpasexec:= 2;
      IF vttipagd IS NULL
         OR(ptobs IS NOT NULL
            AND LENGTH(ptobs) > 3000) THEN
         RAISE e_object_error;
      END IF;

      viddocgedox := piddocgedox;

      IF viddocgedox IS NULL AND ptfilename IS NOT NULL THEN
         vnumerr := pac_md_gedox.f_set_documobservagedox(ptfilename, viddocgedox, pdescripcion, pidcat, mensajes);
      END IF;

      vnumerr := pac_md_agenda.f_set_obs(pidobs, pcconobs, pctipobs, pttitobs, ptobs, pfobs,
                                         pfrecordatorio, pctipagd, pcambito, pcpriori,
                                         pcprivobs, ppublico, pcestobs, pfestobs, vttipagd,
                                         gvisionrol, gvisionusu, pidobs_out, pdescripcion, ptfilename, viddocgedox, mensajes);
    vpasexec := 3;
      IF vnumerr != 0 THEN
         RAISE e_object_error;
      END IF;

      IF pidobs IS NULL THEN
         vtext := f_axis_literales(9001332, pac_iax_common.f_get_cxtidioma);
         vtext := vtext || ' - ' || f_axis_literales(9001189, pac_iax_common.f_get_cxtidioma)
                  || ' : ' || pidobs_out;
      ELSE
         vtext := f_axis_literales(9001895, pac_iax_common.f_get_cxtidioma);
         vtext := vtext || ' ' || f_axis_literales(9001189, pac_iax_common.f_get_cxtidioma)
                  || ' : ' || pidobs_out;
      END IF;

      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, NULL, vtext);
      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_obs;

   /*************************************************************************
          Devuelve la visión de la observación
          propietario ya que no se podrá gestionar este rol, siempre será visible
          pidobs IN NUMBER,
          plstvision OUT sys_refcursor       : cursor que devolveremos
          return                : 0/1 OK/KO
       *************************************************************************/
   FUNCTION f_get_visionobs(
      pidobs IN NUMBER,
      pctipagd IN NUMBER,
      plstvisionrol OUT t_iax_agd_vision,
      plstvisionusu OUT t_iax_agd_vision,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vsquery        VARCHAR2(5000);
      vobjectname    VARCHAR2(500) := 'PAC_IAX_AGENDA.f_get_lstvision';
      vparam         VARCHAR2(1000) := 'parámetros - pidobs :' || pidobs;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      obvision       ob_iax_agd_vision := ob_iax_agd_vision();
      cur            sys_refcursor;
   BEGIN
      vnumerr := pac_md_agenda.f_get_visionobs(pidobs, pctipagd, plstvisionrol, plstvisionusu,
                                               mensajes);

      IF vnumerr != 0 THEN
         RAISE e_object_error;
      END IF;

      gvisionrol := plstvisionrol;
      gvisionusu := plstvisionusu;
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
   END f_get_visionobs;

   /*************************************************************************
          Devuelve la visión de la observación que tenemos en la persistencia
          return                : 0/1 OK/KO
       *************************************************************************/
   FUNCTION f_get_visionobs_ob(
      plstvisionrol OUT t_iax_agd_vision,
      plstvisionusu OUT t_iax_agd_vision,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vsquery        VARCHAR2(5000);
      vobjectname    VARCHAR2(500) := 'PAC_IAX_AGENDA.f_get_lstvision';
      vparam         VARCHAR2(1000) := 'parámetros -  :';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      obvision       ob_iax_agd_vision := ob_iax_agd_vision();
      cur            sys_refcursor;
   BEGIN
      plstvisionrol := gvisionrol;
      plstvisionusu := gvisionusu;
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
   END f_get_visionobs_ob;

   /*************************************************************************
            Grabamos al objeto la vision del apunte si es publico marcamos todos
            propietario ya que no se podrá gestionar este rol, siempre será visible
            pidobs IN NUMBER,
            ppublico IN NUMBER,
            pctipvision IN NUMBER,
            pttipvision IN VARCHAR2,
            pcvisible IN NUMBER,
            return                : 0/1 OK/KO
         *************************************************************************/
   FUNCTION f_set_visionobs_ob(
      pidobs IN NUMBER,
      ppublico IN NUMBER,
      pctipvision IN NUMBER,
      pttipvision IN VARCHAR2,
      pcvisible IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vsquery        VARCHAR2(5000);
      vobjectname    VARCHAR2(500) := 'PAC_IAX_AGENDA.f_set_visionobs_ob';
      vparam         VARCHAR2(1000)
         := 'parámetros - pidobs :' || pidobs || ',pctipvision =' || pctipvision
            || ', ppublico =' || ppublico || ',ttipvision = ' || pttipvision || ',cvisible='
            || pcvisible;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      obvision       ob_iax_agd_vision := ob_iax_agd_vision();
      cur            sys_refcursor;
      trobat         BOOLEAN := FALSE;
      vidobs         NUMBER := -1;
   BEGIN
      IF pidobs IS NOT NULL THEN
         vidobs := pidobs;
      END IF;

      vpasexec := 2;

      IF pctipvision = 2
         AND pttipvision = pac_md_common.f_get_cxtusuario THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9901956);
         RAISE e_object_error;
      END IF;

      IF ppublico = 1 THEN
         /*  IF gvisionrol IS NOT NULL
              AND gvisionrol.COUNT > 0 THEN
              FOR i IN gvisionrol.FIRST .. gvisionrol.LAST LOOP
                 gvisionrol(i).cvisible := 1;
              END LOOP;
           END IF;*/
         gvisionrol := t_iax_agd_vision();
         gvisionusu := t_iax_agd_vision();
      END IF;

      vpasexec := 3;

      IF pctipvision = 1 THEN
         IF gvisionrol IS NOT NULL
            AND gvisionrol.COUNT > 0 THEN
            FOR i IN gvisionrol.FIRST .. gvisionrol.LAST LOOP
               IF gvisionrol.EXISTS(i) THEN
                  IF gvisionrol(i).ctipvision = pctipvision
                     AND gvisionrol(i).ttipvision = pttipvision THEN
                     gvisionrol(i).cvisible := pcvisible;
                     trobat := TRUE;
                  END IF;
               END IF;
            END LOOP;
         END IF;

         vpasexec := 4;

         IF trobat = FALSE THEN
            IF gvisionrol IS NULL THEN
               gvisionrol := t_iax_agd_vision();
            END IF;

            obvision.cvisible := pcvisible;
            obvision.ttipvision := pttipvision;
            obvision.ctipvision := pctipvision;
            obvision.idobs := vidobs;
            gvisionrol.EXTEND;
            gvisionrol(gvisionrol.LAST) := obvision;
         END IF;
      ELSIF pctipvision = 2 THEN
         vpasexec := 5;

         IF gvisionusu IS NOT NULL
            AND gvisionusu.COUNT > 0 THEN
            vpasexec := 55;

            FOR i IN gvisionusu.FIRST .. gvisionusu.LAST LOOP
               vpasexec := 56;

               IF gvisionusu.EXISTS(i) THEN
                  vpasexec := 57;

                  IF gvisionusu(i).ctipvision = pctipvision
                     AND gvisionusu(i).ttipvision = pttipvision THEN
                     vpasexec := 58;
                     gvisionusu(i).cvisible := pcvisible;
                     trobat := TRUE;
                  END IF;
               END IF;
            END LOOP;
         END IF;

         vpasexec := 6;

         IF trobat = FALSE THEN
            IF gvisionusu IS NULL THEN
               gvisionusu := t_iax_agd_vision();
            END IF;

            obvision := ob_iax_agd_vision();
            obvision.cvisible := pcvisible;
            obvision.ttipvision := pttipvision;

            IF pttipvision IS NOT NULL THEN
               vnumerr := f_desusuario(pttipvision, obvision.descttipvision);
            END IF;

            vpasexec := 7;
            obvision.ctipvision := pctipvision;
            obvision.idobs := vidobs;
            gvisionusu.EXTEND;
            gvisionusu(gvisionusu.LAST) := obvision;
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
   END f_set_visionobs_ob;

   /*************************************************************************
      Actualizamos el objeto segun sea privado o publico
      pidobs IN NUMBER,
      ppublico IN NUMBER,
      pcprivobs IN NUMBER,
      return                : 0/1 OK/KO
   *************************************************************************/
   FUNCTION f_actualizar_vision_ob(
      pidobs IN NUMBER,
      ppublico IN NUMBER,
      pcprivobs IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vsquery        VARCHAR2(5000);
      vobjectname    VARCHAR2(500) := 'PAC_IAX_AGENDA.f_actualizar_vision_ob';
      vparam         VARCHAR2(1000)
         := 'parámetros - pidobs :' || pidobs || ',ppublico =' || ppublico || ', pcprivobs ='
            || pcprivobs;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      obvision       ob_iax_agd_vision := ob_iax_agd_vision();
      cur            sys_refcursor;
      trobat         BOOLEAN := FALSE;
      vidobs         NUMBER := -1;
   BEGIN
      IF pidobs IS NOT NULL THEN
         vidobs := pidobs;
      END IF;

      vpasexec := 2;

      IF ppublico = 1 THEN
         /* IF gvisionrol IS NOT NULL
             AND gvisionrol.COUNT > 0 THEN
             FOR i IN gvisionrol.FIRST .. gvisionrol.LAST LOOP
                gvisionrol(i).cvisible := 1;
             END LOOP;
          END IF;*/
         gvisionrol := t_iax_agd_vision();
         gvisionusu := t_iax_agd_vision();
      ELSIF pcprivobs = 1 THEN
         IF gvisionrol IS NOT NULL
            AND gvisionrol.COUNT > 0 THEN
            FOR i IN gvisionrol.FIRST .. gvisionrol.LAST LOOP
               gvisionrol(i).cvisible := 0;
            END LOOP;
         END IF;

         gvisionusu := t_iax_agd_vision();
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
   END f_actualizar_vision_ob;

   /*************************************************************************
            Grabamos al objeto la vision del apunte si es publico marcamos todos
            propietario ya que no se podrá gestionar este rol, siempre será visible
            pidobs IN NUMBER,
            ppublico IN NUMBER,
            pctipvision IN NUMBER,
            pttipvision IN VARCHAR2,
            pcvisible IN NUMBER,
            return                : 0/1 OK/KO
         *************************************************************************/
   FUNCTION f_del_visionobs_ob(
      pidobs IN NUMBER,
      pctipvision IN NUMBER,
      pttipvision IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vsquery        VARCHAR2(5000);
      vobjectname    VARCHAR2(500) := 'PAC_IAX_AGENDA.f_set_visionobs_ob';
      vparam         VARCHAR2(1000)
         := 'parámetros - pidobs :' || pidobs || ',pctipvision =' || pctipvision
            || ',ttipvision = ' || pttipvision;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      obvision       ob_iax_agd_vision := ob_iax_agd_vision();
      cur            sys_refcursor;
      trobat         BOOLEAN := FALSE;
      vidobs         NUMBER := -1;
   BEGIN
      IF pidobs IS NOT NULL THEN
         vidobs := pidobs;
      END IF;

      IF pctipvision = 1 THEN
         IF gvisionrol IS NOT NULL
            AND gvisionrol.COUNT > 0 THEN
            FOR i IN gvisionrol.FIRST .. gvisionrol.LAST LOOP
               IF gvisionrol(i).ctipvision = pctipvision
                  AND gvisionrol(i).ttipvision = pttipvision THEN
                  gvisionrol.DELETE(i);
               END IF;
            END LOOP;
         END IF;
      ELSIF pctipvision = 2 THEN
         IF gvisionusu IS NOT NULL
            AND gvisionusu.COUNT > 0 THEN
            FOR i IN gvisionusu.FIRST .. gvisionusu.LAST LOOP
               IF gvisionusu(i).ctipvision = pctipvision
                  AND gvisionusu(i).ttipvision = pttipvision THEN
                  gvisionusu.DELETE(i);
               END IF;
            END LOOP;
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
   END f_del_visionobs_ob;

   /*************************************************************************
            Borramos un apunte/observacion
            pidobs IN NUMBER,
            return                : 0/1 OK/KO
         *************************************************************************/
   FUNCTION f_del_observacion(pidobs IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vsquery        VARCHAR2(5000);
      vobjectname    VARCHAR2(500) := 'PAC_IAX_AGENDA.f_del_observacion';
      vparam         VARCHAR2(1000) := 'parámetros - pidobs :' || pidobs;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      cur            sys_refcursor;
      trobat         BOOLEAN := FALSE;
      vidobs         NUMBER := -1;
   BEGIN
      IF pidobs IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_agenda.f_del_observacion(pidobs, mensajes);

      IF vnumerr != 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_del_observacion;

   FUNCTION f_get_lstchat(
      pidagenda IN NUMBER,
      pidapunte IN NUMBER,
      pnmovagd IN NUMBER,
      pnmovchat IN NUMBER,
      pcusuari IN VARCHAR2,
      pcgrupo IN VARCHAR2,
      ptgrupo IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobjectname    VARCHAR2(200) := 'PAC_IAX_AGENDA.f_get_grupo';
      vsquery        VARCHAR2(500);
      vnumerr        NUMBER;
   BEGIN
      cur := pac_md_agenda.f_get_lstchat(pidagenda, pidapunte, pnmovagd, pnmovchat, pcusuari,
                                         pcgrupo, ptgrupo, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN NULL;
   END f_get_lstchat;

   FUNCTION f_set_chat(
      pidagenda IN NUMBER,
      pidapunte IN NUMBER,
      pnmovagd IN NUMBER,
      pnmovchat IN NUMBER,
      pttexto IN VARCHAR2,
      pcusuari IN VARCHAR2,
      pcgrupo IN VARCHAR2,
      ptgrupo IN VARCHAR2,
      pctipres IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      cur            sys_refcursor;
      vsquery        VARCHAR2(5000);
      vobjectname    VARCHAR2(500) := 'PAC_IAX_AGENDA.f_set_agenda';
      vparam         VARCHAR2(1000)
         := 'parámetros - pidapunte: ' || pidapunte || ' pidagenda:' || pidagenda
            || ' pnmovagd:' || pnmovagd || ' pnmovchat:' || pnmovchat || ' pcusuari:'
            || pcusuari || ' pcgrupo:' || pcgrupo || ' ptgrupo:' || ptgrupo || ' PCTIPRES:'
            || pctipres;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_agenda.f_set_chat(pidapunte, pidagenda, pnmovagd, pnmovchat, pttexto,
                                          pcusuari, pcgrupo, ptgrupo, pctipres, mensajes);

      IF vnumerr != 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_chat;

   FUNCTION f_get_lstgrupos(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobjectname    VARCHAR2(200) := 'PAC_IAX_AGENDA.f_get_lstgrupos';
      vsquery        VARCHAR2(500);
      vnumerr        NUMBER;
   BEGIN
      cur := pac_md_agenda.f_get_lstgrupos(mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN NULL;
   END f_get_lstgrupos;

   /*************************************************************************
          Devuelve los motivos de respuesta
          return                : Cursor
       *************************************************************************/
   FUNCTION f_get_lstmotrespuesta(pcclagd NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobjectname    VARCHAR2(200) := 'PAC_IAX_AGENDA.f_get_lstMotrespuesta';
      vsquery        VARCHAR2(500);
      vnumerr        NUMBER;
   BEGIN
      cur := pac_md_agenda.f_get_lstmotrespuesta(pcclagd, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN NULL;
   END f_get_lstmotrespuesta;

   /*Funció que retorna el valor a mostrar per pantalla.
   Si es un apunt de pòlissa, retornarà npol + ncertif, si és de rebut nrecibo i si és sinistre el nsinies.
   XPL#14102011#
   */
   FUNCTION f_get_valorclagd(
      pcclagd IN VARCHAR2,
      ptclagd IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_info IS
      vsquery        VARCHAR2(5000);
      vobjectname    VARCHAR2(500) := 'PAC_IAX_AGENDA.valorclagd';
      vparam         VARCHAR2(1000)
                            := 'parámetros - pcclagd: ' || pcclagd || ' ptclagd: ' || ptclagd;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vquery         VARCHAR2(3000);
      cur            sys_refcursor;
      vtclagd        t_iax_info := t_iax_info();
   BEGIN
      vtclagd := pac_md_agenda.f_get_valorclagd(pcclagd, ptclagd, mensajes);
      RETURN vtclagd;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN NULL;
   END f_get_valorclagd;

   /*Funci?e crear tasca de la solicitud de projecte
    XPL#24102011#
    */
   FUNCTION f_tarea_sol_proyecto(psseguro IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vsquery        VARCHAR2(5000);
      vobjectname    VARCHAR2(500) := 'PAC_IAX_AGENDA.f_tarea_sol_proyecto';
      vparam         VARCHAR2(1000) := 'par?tros - psseguro: ' || psseguro;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_agenda.f_tarea_sol_proyecto(psseguro, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_tarea_sol_proyecto;
   
      /*ABJ bug 4961 validar si existe conclusiones y si no traer descripcion de riesgo
      FECHA: 01/08/2019
	  FUNCION: F_VALCONCLUSIONES*/
      FUNCTION f_valconclusiones(
      PIDOBS IN NUMBER,
      PNSINIES IN NUMBER,
      TDESCRIE OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_AGENDA.f_valconclusiones';
      vparam         VARCHAR2(1000) := 'parÃ¡metros - PNSINIES :' || PNSINIES;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      info    VARCHAR2(500) := 'Info.';
   BEGIN
   
      vnumerr := pac_md_agenda.f_valconclusiones(PIDOBS, PNSINIES, TDESCRIE, mensajes);

      IF vnumerr != 0 THEN
      IF vnumerr =2 THEN 
       RAISE e_param_error; -- REGISTRO YA EXISTENTE LO RETORNO CON ESTE RISE
      ELSE
         RAISE e_object_error;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, info, 89907043, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_valconclusiones;
   
END pac_iax_agenda;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_AGENDA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_AGENDA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_AGENDA" TO "PROGRAMADORESCSI";
