--------------------------------------------------------
--  DDL for Package Body PAC_MD_AGENDA
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY PAC_MD_AGENDA AS
/******************************************************************************
   NOMBRE:      pac_md_agenda
   PROPÓSITO:

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        19/11/2010   XPL               1. Creación del package.
   2.0        25/02/2011   JMF              0017744: CRT - Mejoras en agenda
   3.0        25/07/2011   ICV              0018845: CRT901 - Modificacionas tareas usuario: boton responder, grupos, envio de mail al crear tarea,etc
   4.0        28/06/2013   JGR              0027525: La pantalla de [axisadm003] Consulta datos de un recibo tarda mucho en abrirse
   5.0        17/04/2019   SGM              IAXIS 3482 PODER INGRESAR ACUERDOS DE PAGO, MASIVAMENTE Y TRAZAR
   6.0        29/05/2019   ECP              IAXIS-3592. Proceso de terminación por no pago

******************************************************************************/
   e_param_error  EXCEPTION;
   e_object_error EXCEPTION;

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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      cur            sys_refcursor;
      vsquery        VARCHAR2(5000);
      vobjectname    VARCHAR2(500) := 'PAC_MD_AGENDA.f_get_lstapuntes';
      vparam         VARCHAR2(1000)
         := 'par?tros - pidapunte: ' || pidapunte || ' pidagenda:' || pidagenda
            || ' pcclagd:' || pcclagd || ' ptclagd:' || ptclagd || ' pcconapu:' || pcconapu
            || ' pcestapu:' || pcestapu || ' pcgrupo:' || pcgrupo || ' ptgrupo:' || ptgrupo
            || ' pttitapu:' || pttitapu || ' pctipapu:' || pctipapu || ' pcperagd:'
            || pcperagd || ' pcambito:' || pcambito || ' pcpriori:' || pcpriori
            || ' pfapunte:' || pfapunte || ' pfalta:' || pfalta|| ' pntramit:' || pntramit;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vquery         CLOB;
   BEGIN
      -- Bug 0017744 - 25/02/2011 - JMF
      vnumerr := pac_agenda.f_get_lstapuntes(pidapunte, pidagenda, pcclagd, ptclagd, pcconapu,
                                             pcestapu, pcgrupo, ptgrupo, pttitapu, pctipapu,
                                             pcperagd, pcambito, pcpriori,
                                             pac_md_common.f_get_cxtidioma, pfapunte, pfalta,
                                             pfrecordatorio, pcusuari, pcapuage, vquery,
                                             pac_md_common.f_get_cxtempresa,
                                             pac_md_common.f_get_cxtusuario, pntramit);

      IF vnumerr != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      plstagenda := pac_iax_listvalores.f_opencursor(vquery, mensajes);
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

         IF plstagenda%ISOPEN THEN
            CLOSE plstagenda;
         END IF;

         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);

         IF plstagenda%ISOPEN THEN
            CLOSE plstagenda;
         END IF;

         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);

         IF plstagenda%ISOPEN THEN
            CLOSE plstagenda;
         END IF;

         RETURN 1;
   END f_get_lstapuntes;

   FUNCTION f_get_agenda(
      pidapunte IN NUMBER,
      pidagenda IN NUMBER,
      pobagenda OUT ob_iax_agenda,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      cur            sys_refcursor;
      vsquery        CLOB;
      vobjectname    VARCHAR2(500) := 'PAC_MD_AGENDA.f_get_agenda';
      vparam         VARCHAR2(1000)
                     := 'parámetros - pidapunte: ' || pidapunte || ' pidagenda:' || pidagenda;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vquery         CLOB;
      vtlistgrupo    VARCHAR2(1000);
      vtlistgrupo_ori VARCHAR2(1000);
      vtclagd_out    VARCHAR2(1000);
      vtdestino      VARCHAR2(1000);
      vtorigen       VARCHAR2(1000);
      vtdescgrupo    VARCHAR2(1000);
      vtusuoridelega VARCHAR2(1000);
      vtusuoridesc   VARCHAR2(1000);
      vtgrupodesc_ori VARCHAR2(1000);
	  vntramit       NUMBER(5);
      vtusufinapu    VARCHAR2(1000);
      vRESAPUN        VARCHAR2(1000); --CONF-347-01/12/2016-RCS

   BEGIN
      -- Bug 0017744 - 25/02/2011 - JMF
      vnumerr := pac_agenda.f_get_lstapuntes(pidapunte, pidagenda, NULL, NULL, NULL, NULL,
                                             NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                             pac_md_common.f_get_cxtidioma, NULL, NULL, NULL,
                                             NULL, NULL, vquery,
                                             pac_md_common.f_get_cxtempresa,
                                             pac_md_common.f_get_cxtusuario);

      IF vnumerr != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      vpasexec := 4;
      pobagenda := ob_iax_agenda();

      IF pidapunte IS NOT NULL THEN
         cur := pac_iax_listvalores.f_opencursor(vquery, mensajes);

         LOOP
            FETCH cur
             INTO pobagenda.idapunte, pobagenda.idagenda, pobagenda.cconapu,
                  pobagenda.tcconapu, pobagenda.cclagd, pobagenda.tclagd, vtclagd_out,
                  pobagenda.tclagddesc, pobagenda.ctipapu, pobagenda.ttipapu, pobagenda.falta,
                  pobagenda.cusuari, pobagenda.ttitapu, pobagenda.cgrupo, vntramit,
                  pobagenda.tgrupodesc, pobagenda.tgrupo, pobagenda.cestapu,
                  pobagenda.testapu, pobagenda.tapunte, pobagenda.festapu, pobagenda.cperagd,
                  pobagenda.cusualt, pobagenda.frecordatorio, vtlistgrupo,
                  pobagenda.cusuari_ori,   --18845 - 25/07/2011 - ICV
                                        pobagenda.cgrupo_ori, vtgrupodesc_ori,   --pobagenda.tgrupodesc_ori,
                  pobagenda.tgrupo_ori, vtlistgrupo_ori, vtdestino, vtorigen, vtdescgrupo,
                  vtusuoridelega, vtusuoridesc, vtusufinapu,pobagenda.RESAPUN; --CONF-347-01/12/2016-RCS
            EXIT WHEN cur%NOTFOUND;
            pobagenda.tgrupodesc_ori := SUBSTR(vtgrupodesc_ori, 1, 50);
         END LOOP;

         CLOSE cur;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN 1;
   END f_get_agenda;

   FUNCTION f_get_lstagdtareas(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      plstagenda OUT sys_refcursor,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vsquery        CLOB;
      vobjectname    VARCHAR2(500) := 'PAC_MD_AGENDA.f_get_lstagdtareas';
      vparam         VARCHAR2(1000) := 'parámetros - pnsinies: ' || pnsinies || ' pntramit:' || pntramit;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vquery         CLOB;
      vqueryapu      CLOB;
      vqueryagd      CLOB;
      vidioma        NUMBER := pac_md_common.f_get_cxtidioma;
      vempresa       NUMBER := pac_md_common.f_get_cxtempresa;
      vusuario       VARCHAR2(100) := pac_md_common.f_get_cxtusuario;
      idapunte       NUMBER;
      vwhereapu      VARCHAR2(3000);
      vwhereagd      VARCHAR2(3000);
      vctipage       NUMBER;
      vcagente       NUMBER;

   BEGIN


      IF pnsinies IS NOT NULL THEN


        IF pnsinies IS NOT NULL THEN
         vwhereagd := vwhereagd || ' and ao.nsinies = ' || pnsinies;
        END IF;

        IF pntramit IS NOT NULL THEN
         vwhereagd := vwhereagd || ' and ao.ntramit = ' || pntramit;
--		ELSE
--		 vwhereagd := vwhereagd || ' and ao.ntramit IS NULL';
        END IF;
-- Ini IAXIS-34592 -- ECP -- 29/05/2019
        vwhereagd :=
         vwhereagd || ' and ao.cempres = ' || vempresa
         || ' and (pac_agenda.f_obs_isvisible(' || vempresa
         || ',ao.ctipagd,ao.idobs) = 1 or ((ao.cprivobs = 1 or ao.cprivobs is null) and ao.cusualt = '''
         || vusuario || ''') OR ao.publico = 1) ';

        vqueryagd :=
  'select
         ao.IDOBS IDAPUNTE,
         ff_desvalorfijo(nvl(aoc.cconobs,800031 ),' || vidioma || ',ao.CCONOBS) TCONCEP,
         ao.NSINIES,
         ao.FRECORDATORIO,
         ff_desvalorfijo(323,' || vidioma || ', ao.ctipobs),
         ''Nota'' ttipapu,
         ao.falta,
         ao.NTRAMIT,
         ff_desvalorfijo(800,' || vidioma || ', (select codtram.ctiptra from sin_codtramitacion codtram, sin_tramitacion tram where tram.nsinies = ' || pnsinies || ' and tram.ntramit = ao.ntramit and codtram.ctramit = tram.ctramit)) ttiptra,
         ao.TOBS TTEXTO,
         ff_desvalorfijo(29,' || vidioma || ', am.cestobs) TESTADO ,
         ao.TTITOBS TTITULO,
         decode(am.cestobs,1,am.festobs,null) ffinali,
         (select tusunom from usuarios usu where usu.cusuari = ao.cusualt) tusualt,
         decode(am.cestobs,1,(select tusunom from usuarios usu where usu.cusuari = am.cusualt),null) tusufin
  from agd_observaciones ao, agd_destiposagenda ad, agd_movobs am, agd_obs_config aoc
  where aoc.cempres = ao.cempres
    and ad.cempres = ao.cempres
    and ao.ctipagd = aoc.ctipagd
    and ao.cempres = am.cempres
    and ao.ctipagd = ad.ctipagd and ad.cidioma = ' || vidioma || '
    and am.idobs = ao.idobs and am.nmovobs = (select max(amm.nmovobs) from agd_movobs amm where amm.idobs = ao.idobs and amm.cempres = ao.cempres) '
    || vwhereagd ;



      IF pntramit IS NOT NULL THEN
         vwhereapu := vwhereapu || ' and agd.ntramit = ' || pntramit;
--	  ELSE
--		 vwhereapu := vwhereapu || ' and agd.ntramit IS NULL';
      END IF;

      IF pnsinies  IS NOT NULL THEN
         vwhereapu := vwhereapu || ' and agd.tclagd = ' || pnsinies;
      END IF;

      SELECT r.ctipage, r.cagente
        INTO vctipage, vcagente
        FROM redcomercial r, usuarios uu
       WHERE uu.cusuari = vusuario
         AND r.cagente = uu.cdelega
         AND r.cempres = vempresa
         AND uu.cempres = r.cempres
         AND r.fmovfin IS NULL
         AND uu.cidioma = vidioma;

     IF vctipage <> 0 THEN
         vwhereapu :=
            vwhereapu || '   and   (( (  ama.tgrupo_dest is not null and  ama.tgrupo_dest in'
            || '         (SELECT a.cagente '
            || '                   FROM (SELECT     LEVEL nivel, cagente '
            || '                                 FROM redcomercial r '
            || '                                WHERE '
            || '                                   r.fmovfin is null '
            || '                           START WITH '
            || '                                   r.CTIPAGE =  ' || vctipage
            || '                                   AND r.cempres = ' || vempresa
            || '                                   AND R.CAGENTE = ' || vcagente
            || '                                   and r.fmovfin is null '
            || '                           CONNECT BY PRIOR r.cagente =(r.cpadre + 0) '
            || '                                  AND PRIOR r.cempres =(r.cempres + 0) '
            || '                                  and r.fmovfin is null '
            || '                                  AND r.cagente >= 0) rr, '
            || '                         agentes a '
            || '                    where rr.cagente = a.cagente ) )'
            || '  or (ama.tgrupo_dest is not null and ama.cgrupo_dest is not null and '
            || '          agd.tgrupo in (select distinct(agg.CSUBGRUP) from agd_grupos agg, agd_grupos_usu aguu where '
            || '                               agg.cgrupo = ama.cgrupo_dest and agg.CSUBGRUP = aguu.CGRUPO '
            || '                                 and agg.cempres = ' || vempresa
            || ' and agg.cempres = aguu.cempres '
            || '                               and upper(aguu.CUSUARIO) like upper('''
            || vusuario || ''') '
            || '  ) ) or (ama.cusuari_dest is not null and ( upper(ama.cusuari_dest) like upper('''
            || vusuario || ''') ' || ' or ( ama.cusuari_dest in '
            || '         (SELECT rr.cusuari '
            || '                   FROM (SELECT     u.cusuari, r.cagente '
            || '                                 FROM redcomercial r, usuarios u '
            || '                                WHERE '
            || '                                   r.fmovfin is null and r.cagente = u.cdelega'
            || '                           START WITH '
            || '                                   r.CTIPAGE =  ' || vctipage
            || '                                   AND r.cempres = ' || vempresa
            || '                                   AND R.CAGENTE = ' || vcagente
            || '                                   and r.fmovfin is null '
            || '                           CONNECT BY PRIOR r.cagente =(r.cpadre + 0) '
            || '                                  AND PRIOR r.cempres =(r.cempres + 0) '
            || '                                  and r.fmovfin is null '
            || '                                  AND r.cagente >= 0) rr, '
            || '                         agentes a '
            || '                    where rr.cagente = a.cagente ) )' || ') ' || ' ) ' || ') ';
         vwhereapu :=
            vwhereapu || '   or  ( ( ama.TGRUPO_ORI is not null and  ama.TGRUPO_ORI in'
            || '         (SELECT a.cagente '
            || '                   FROM (SELECT     LEVEL nivel, cagente '
            || '                                 FROM redcomercial r '
            || '                                WHERE '
            || '                                   r.fmovfin is null '
            || '                           START WITH '
            || '                                   r.CTIPAGE =  ' || vctipage
            || '                                   AND r.cempres = ' || vempresa
            || '                                   AND R.CAGENTE = ' || vcagente
            || '                                   and r.fmovfin is null '
            || '                           CONNECT BY PRIOR r.cagente =(r.cpadre + 0) '
            || '                                  AND PRIOR r.cempres =(r.cempres + 0) '
            || '                                  and r.fmovfin is null '
            || '                                  AND r.cagente >= 0) rr, '
            || '                         agentes a '
            || '                    where rr.cagente = a.cagente ) )'
            || '  or (ama.TGRUPO_ORI is not null and ama.CGRUPO_ORI is not null and '
            || '          ama.TGRUPO_ORI in (select distinct(agg.CSUBGRUP) from agd_grupos agg, agd_grupos_usu aguu where '
            || '                               agg.cgrupo = ama.CGRUPO_ORI and agg.CSUBGRUP = aguu.CGRUPO '
            || '                                 and agg.cempres = ' || vempresa
            || ' and agg.cempres = aguu.cempres '
            || '                               and upper(aguu.CUSUARIO) like upper('''
            || vusuario || ''') '
            || '  ) ) or (ama.CUSUARI_ORI is not null and ( upper(ama.CUSUARI_ORI) like upper('''
            || vusuario || ''') ' || ' or ( ama.CUSUARI_ORI in '
            || '         (SELECT rr.cusuari '
            || '                   FROM (SELECT     u.cusuari, r.cagente '
            || '                                 FROM redcomercial r, usuarios u '
            || '                                WHERE '
            || '                                   r.fmovfin is null and r.cagente = u.cdelega'
            || '                           START WITH '
            || '                                   r.CTIPAGE =  ' || vctipage
            || '                                   AND r.cempres = ' || vempresa
            || '                                   AND R.CAGENTE = ' || vcagente
            || '                                   and r.fmovfin is null '
            || '                           CONNECT BY PRIOR r.cagente =(r.cpadre + 0) '
            || '                                  AND PRIOR r.cempres =(r.cempres + 0) '
            || '                                  and r.fmovfin is null '
            || '                                  AND r.cagente >= 0) rr, '
            || '                         agentes a '
            || '                    where rr.cagente = a.cagente ) )' || ') ' || ' ) '
            || ')) ';
      END IF;

      vqueryapu :=
  'SELECT
         ap.idapunte,
         ff_desvalorfijo(800031,' || vidioma || ', ap.cconapu) tconcep,
         agd.tclagd nsinies,
         ap.frecordatorio,
         ff_desvalorfijo(323,' || vidioma || ', ap.ctipapu),
         ''Tarea'' ttipapu,
         ap.falta,
         agd.ntramit,
         ff_desvalorfijo(800,' || vidioma || ', (select codtram.ctiptra from sin_codtramitacion codtram, sin_tramitacion tram where tram.nsinies = ' || pnsinies || ' and tram.ntramit = agd.ntramit and codtram.ctramit = tram.ctramit)) ttiptra,
         ap.tapunte ttexto,
         ff_desvalorfijo(29,' || vidioma || ', agm.cestapu) testado,
         ap.ttitapu ttitulo,
         decode(agm.cestapu,1,agm.FESTAPU,null) FFINALI,
         (select tusunom from usuarios usu where usu.cusuari = ap.cusualt) tusualt,
         decode(agm.cestapu,1,(select tusunom from usuarios usu where usu.cusuari = agm.cusualt),null) tusufin
  from agd_apunte ap, agd_agenda agd, agd_movapunte agm, agd_movagenda ama
      where ap.idapunte = agd.idapunte
         and agd.idapunte = agm.IDAPUNTE
         and ama.idapunte = ap.idapunte
         and ama.idagenda = agd.idagenda
         and ama.nmovagd = (SELECT MAX(m.nmovagd) FROM agd_movagenda m WHERE m.idapunte = ama.idapunte and  m.idagenda = ama.idagenda)
         and agm.NMOVAPU = (select max(m.nmovapu) from agd_movapunte m where m.idapunte = agd.idapunte ) ' || vwhereapu;

-- Ini IAXIS-34592 -- ECP -- 29/05/2019
         vquery := vqueryagd || ' UNION ' || vqueryapu;

         vquery := vquery || ' ORDER BY FALTA DESC';

         plstagenda := pac_iax_listvalores.f_opencursor(vquery, mensajes);

      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

         IF plstagenda%ISOPEN THEN
            CLOSE plstagenda;
         END IF;

         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);

         IF plstagenda%ISOPEN THEN
            CLOSE plstagenda;
         END IF;

         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);

         IF plstagenda%ISOPEN THEN
            CLOSE plstagenda;
         END IF;

         RETURN 1;
   END f_get_lstagdtareas;

   --Bug.: 18845 - 25/07/2011 - ICV - Se añade el ptgrupo
   FUNCTION f_get_grupo(pcusuario IN VARCHAR2, ptgrupo OUT NUMBER)
      RETURN VARCHAR2 IS
      vgrupo         VARCHAR2(200) := NULL;
   BEGIN
      BEGIN
         SELECT cgrupo
           INTO vgrupo
           FROM agd_grupos_usu
          WHERE cusuario = pcusuario;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            SELECT r.ctipage, r.cagente
              INTO vgrupo, ptgrupo
              FROM usuarios usu, redcomercial r
             WHERE usu.cusuari = pcusuario
               AND r.cempres = pac_md_common.f_get_cxtempresa
               AND r.fmovfin IS NULL
               AND r.cagente = usu.cdelega;
      END;

      RETURN vgrupo;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END;

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
      MENSAJES IN OUT T_IAX_MENSAJES,
      PTRESP IN VARCHAR2 default null, --CONF-347-01/12/2016-RCS
      pntramit IN NUMBER default null)
      RETURN NUMBER IS
      cur            sys_refcursor;
      vsquery        VARCHAR2(5000);
      vobjectname    VARCHAR2(500) := 'PAC_MD_AGENDA.f_set_agenda';
      vparam         VARCHAR2(4000)
         := 'parámetros - pidapunte: ' || pidapunte || ' pidagenda:' || pidagenda
            || ' pcclagd:' || pcclagd || ' ptclagd:' || ptclagd || ' pcconapu:' || pcconapu
            || ' pcestapu:' || pcestapu || ' pcgrupo:' || pcgrupo || ' ptgrupo:' || ptgrupo
            || ' pctipapu:' || pctipapu || ' pcperagd:' || pcperagd || ' pcambito:'
            || pcambito || ' pcpriori:' || pcpriori || ' pfapunte:' || pfapunte || ' pfalta:'
            || pfalta;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vidapunte      NUMBER;
      vgrupo         VARCHAR2(200);
      vtgrupo        NUMBER;
   BEGIN
      vpasexec := 2;
      vidapunte := pidapunte;
      vnumerr := pac_agenda.f_set_apunte(pidapunte, pidagenda, pcclagd, ptclagd, pcconapu,
                                         pcestapu, pcgrupo, ptgrupo, pttitapu, ptapunte,
                                         pctipapu, pcperagd, pcambito, pcpriori, pcusuari,
                                         pfapunte, pfestapu, pfalta, pfrecordatorio,
                                         vidapunte);

      IF vnumerr != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      --Bug.: 18845 - 25/07/2011 - Si estamos modificando y tenemos el usuario o grupo ori les pasamos los que tenemos sino pasamos los nuevos asignados
      IF pcusuari_ori IS NULL
         AND pcgrupo_ori IS NULL THEN
      vpasexec := 3;
--         vgrupo := f_get_grupo(pac_md_common.f_get_cxtusuario, vtgrupo);   --buscamos el grupo creador
         vnumerr := pac_agenda.f_set_agenda(vidapunte, pidagenda, pcusuari, pcgrupo, ptgrupo,
                                            pcclagd, ptclagd, pcperagd,
                                            pac_md_common.f_get_cxtusuario, vgrupo, vtgrupo,
                                            pac_md_common.f_get_cxtempresa,
                                            pac_md_common.f_get_cxtidioma,
                                            pntramit => pntramit ,PTRESP => PTRESP); --CONF-347-01/12/2016-RCS
      ELSE
      vpasexec := 4;
         vnumerr := pac_agenda.f_set_agenda(vidapunte, pidagenda, pcusuari, pcgrupo, ptgrupo,
                                            pcclagd, ptclagd, pcperagd, pcusuari_ori,
                                            pcgrupo_ori, ptgrupo_ori,
                                            pac_md_common.f_get_cxtempresa,
                                            pac_md_common.f_get_cxtidioma,
                                            pntramit => pntramit ,PTRESP => PTRESP); --CONF-347-01/12/2016-RCS
      END IF;

      -- bug 23101 ini bfp
      IF pcclagd = 0 THEN
      vpasexec := 5;
         vnumerr := pac_tramitadores.f_replica_apunte(vidapunte,
                                                      pac_md_common.f_get_cxtempresa,
                                                      pac_md_common.f_get_cxtidioma);
      END IF;

      -- bug 23101 fi bfp
      IF vnumerr != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      pidapunte_out := vidapunte;
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
   END f_set_agenda;

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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      cur            sys_refcursor;
      vsquery        VARCHAR2(5000);
      vobjectname    VARCHAR2(500) := 'PAC_MD_AGENDA.f_set_chat';
      vparam         VARCHAR2(1000)
         := 'parámetros - pidapunte: ' || pidapunte || ' pidagenda:' || pidagenda
            || ' pnmovagd:' || pnmovagd || ' pnmovchat:' || pnmovchat || ' pcusuari:'
            || pcusuari || ' pcgrupo:' || pcgrupo || ' ptgrupo:' || ptgrupo;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vcgrupo        VARCHAR2(20) := pcgrupo;
   BEGIN
      /*   IF vcgrupo IS NULL THEN
           vcgrupo := f_get_grupo(pcusuari);
        END IF;*/
      vnumerr := pac_agenda.f_set_chat(pidapunte, pidagenda, pnmovagd, pnmovchat, pttexto,
                                       pcusuari, vcgrupo, ptgrupo, pctipres,
                                       pac_md_common.f_get_cxtempresa,
                                       pac_md_common.f_get_cxtagente,
                                       pac_md_common.f_get_cxtidioma);

      IF vnumerr != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
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
   END f_set_chat;

   FUNCTION f_get_lstchat(
      pidagenda IN NUMBER,
      pidapunte IN NUMBER,
      pnmovagd IN NUMBER,
      pnmovchat IN NUMBER,
      pcusuari IN VARCHAR2,
      pcgrupo IN VARCHAR2,
      ptgrupo IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_LISTVALORES.f_get_grupo';
      vsquery        VARCHAR2(500);
      vnumerr        NUMBER;
   BEGIN
      vnumerr := pac_agenda.f_get_lstchat(pidagenda, pidapunte, pnmovagd, pnmovchat, pcusuari,
                                          pcgrupo, ptgrupo, pac_md_common.f_get_cxtidioma,
                                          vsquery, pac_md_common.f_get_cxtempresa);
      cur := pac_md_listvalores.f_opencursor(vsquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstchat;

   FUNCTION f_get_valoresgrupo(
      pcgrupo IN VARCHAR2,
      pctodos IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_LISTVALORES.f_get_grupo';
      vsquery        VARCHAR2(2000);
      vcont          NUMBER;
   BEGIN
      SELECT COUNT(1)
        INTO vcont
        FROM agd_grupos
       WHERE cgrupo = pcgrupo;

      --Si esta en aquesta taula no retornem cap valor
      IF vcont = 0 THEN
         vsquery :=
            ' SELECT distinct rc.cagente CVALOR , f_nombre(a.sperson,1,rc.cagente) TVALOR, '
            || ' decode(LENGTH(rc.cagente), 1,TO_CHAR(rc.cagente, ''0009''), 3,TO_CHAR(rc.cagente, ''0009''), 2,TO_CHAR(rc.cagente, ''0009''),rc.cagente) CAGENTE_VIS '
            || 'FROM redcomercial rc, agentes a ';

         IF pctodos = 1 THEN
            vsquery := vsquery || '  ' || 'WHERE rc.cempres = '
                       || pac_md_common.f_get_cxtempresa;
            vsquery := vsquery || ' and rc.cagente = a.cagente ';
            vsquery := vsquery || ' and rc.ctipage = ' || pcgrupo;
            vsquery :=
               vsquery
               || ' and rc.fmovfin is null and rc.cagente in (select cagente from redcomercial where fmovfin is null and  ctipage = '
               || pcgrupo;
            vsquery := vsquery || ' and cempres = ' || pac_md_common.f_get_cxtempresa || ' )';
         ELSE
            vsquery := vsquery || ' WHERE rc.cempres = ' || pac_md_common.f_get_cxtempresa;
            vsquery := vsquery || ' and rc.cagente = a.cagente  ';
            vsquery := vsquery || ' and rc.ctipage = ' || pcgrupo;
            vsquery :=
               vsquery
               || ' START WITH     rc.cagente = (select cdelega from usuarios where cusuari =   '
               || CHR(39) || pac_md_common.f_get_cxtusuario || CHR(39) || ' ) ';
            vsquery := vsquery || ' AND          rc.cempres = '
                       || pac_md_common.f_get_cxtempresa;
            -- Bug 0017744 - 25/02/2011 - JMF
            vsquery := vsquery
                       || ' CONNECT BY PRIOR  rc.cagente = rc.cpadre and rc.fmovfin is null';
         END IF;

         vsquery := vsquery || ' ORDER BY CVALOR, TVALOR ';
         cur := pac_md_listvalores.f_opencursor(vsquery, mensajes);
      ELSE
        if pcgrupo!='TODOS' THEN
         vsquery :=
               '  select g.cusuario CVALOR, u.tusunom TVALOR '
            || '    from agd_grupos_usu g, usuarios u '
            || '   where g.cgrupo =  ''' || pcgrupo || ''' and g.cempres = ' || pac_md_common.f_get_cxtempresa
            || '     and u.cusuari=g.cusuario '
            || 'order by CVALOR asc';
         cur := pac_md_listvalores.f_opencursor(vsquery, mensajes);
         ELSE
         vsquery :=
               '  SELECT distinct(CUSUARI) AS CVALOR,TUSUNOM AS TVALOR  '
            || '     FROM USUARIOS    '
            || '     WHERE CTIPUSU = 2 '
            || ' AND FBAJA IS NULL ';
         cur := pac_md_listvalores.f_opencursor(vsquery, mensajes);
         END IF;
      END IF;

      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_valoresgrupo;

     --XPL bug 17770 25/03/2011 inici
   /*************************************************************************
        Nos devuelve los diferentes filtros que nos llegan de la tabla agd_obs_config
        param in pparams     : Filtros separados por ';', tal como NSINIES;NTRAMIT o SSEGURO
        return                : Colección con todos los filtros
     *************************************************************************/
   FUNCTION f_get_params(pparams IN VARCHAR2)
      RETURN t_iax_info IS
      vobjectname    VARCHAR2(500) := 'pac_md_agenda.f_get_params';
      vparam         CLOB := 'parámetros - pparams : ';
      pos            NUMBER;
      tipo           VARCHAR2(4000);
      posdp          NUMBER;
      vtinfo         t_iax_info;
      vinfo          ob_iax_info;
   BEGIN
      vtinfo := t_iax_info();

      FOR i IN 1 .. LENGTH(pparams) LOOP
         posdp := INSTR(pparams, ',', 1, i);

         IF i = 1
            AND posdp = 0 THEN
            tipo := pparams;
         ELSE
            IF posdp > NVL(pos, 0) THEN
               tipo := SUBSTR(pparams, NVL(pos, 0) + 1,(posdp - NVL(pos, 0)) - 1);
            ELSE
               tipo := SUBSTR(pparams, NVL(pos, 0) + 1);
            END IF;
         END IF;

         IF tipo IS NOT NULL THEN
            vinfo := ob_iax_info();
            vtinfo.EXTEND;
            vinfo.nombre_columna := tipo;
            vtinfo(vtinfo.LAST) := vinfo;
         END IF;

         IF (posdp < NVL(pos, 0))
            OR(i = 1
               AND posdp = 0) THEN
            RETURN vtinfo;
         END IF;

         pos := posdp;
      END LOOP;

      RETURN vtinfo;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, 1, 'error no controlado', SQLERRM);
         RETURN NULL;
   END f_get_params;

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
      pparams IN t_iax_info,
      plstagdobs OUT sys_refcursor,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vsquery        VARCHAR2(5000);
      vobjectname    VARCHAR2(500) := 'PAC_md_AGENDA.f_get_lstagdobs';
      vparam         VARCHAR2(1000) := 'parámetros - pctipagd :' || pctipagd;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vquery         VARCHAR2(3000);
      vfiltro        VARCHAR2(50);
      vtinfo         t_iax_info;
      vwhere         VARCHAR2(1000);
      vctipagd       VARCHAR2(10) := ' ';
      vidioma        NUMBER := pac_md_common.f_get_cxtidioma;
      vtfiltro       VARCHAR2(200);
      vvalorfiltro   VARCHAR2(200);
   BEGIN
      --Comprobamos si existe el tipo de agenda, en caso contrario el cursor será nulo
      IF pctipagd IS NOT NULL THEN
         --Comprobamos que filtro especifico necesita el tipo de agenda
         SELECT NVL(tfiltro, '')
           INTO vfiltro
           FROM agd_obs_config
          WHERE ctipagd = pctipagd
            AND cempres = pac_md_common.f_get_cxtempresa;

         --Lo gestionamos para poder crear la where dinámica
         vtinfo := f_get_params(vfiltro);

         FOR i IN pparams.FIRST .. pparams.LAST LOOP
            FOR j IN vtinfo.FIRST .. vtinfo.LAST LOOP
               --Si los par?tros entrados por pantalla coinciden con los filtros parametrizados en la
               --tabla, iremos creando la where din?ca.
               IF UPPER(vtinfo(j).nombre_columna) LIKE UPPER(pparams(i).nombre_columna) THEN
                  IF pparams(i).valor_columna IS NOT NULL THEN
                     vwhere := vwhere || ' AND  ' || vtinfo(j).nombre_columna || ' = '''
                               || pparams(i).valor_columna || '''';
                  END IF;
               END IF;
            END LOOP;
         END LOOP;
      END IF;

      --IF pctipagd IS NOT NULL THEN
         --vwhere := vwhere || ' and ao.ctipagd = ' || pctipagd;
      --END IF;

      IF pidobs IS NOT NULL THEN
         vwhere := vwhere || ' and ao.idobs = ' || pidobs;
      END IF;

      --Una vez creado el filtro propio del tipo de agenda filtraremos por la visibilidad y devolveremos los campos
      --  4.0 0027525: La pantalla de [axisadm003] Consulta datos de un recibo tarda mucho en abrirse - Inicio
--      vwhere :=
--         vwhere || ' and ao.cempres = ' || pac_md_common.f_get_cxtempresa
--         || ' and (pac_agenda.f_obs_isvisible(' || pac_md_common.f_get_cxtempresa
--         || ',ao.ctipagd,ao.idobs) = 1 or ((ao.cprivobs = 1 or ao.cprivobs is null) and ao.cusualt = '''
--         || pac_md_common.f_get_cxtusuario || ''') OR ao.publico = 1) ';
--      vquery :=
--         'select /*+ rule +*/ ao.IDOBS, ao.publico,ao.CCONOBS, ff_desvalorfijo(nvl(aoc.cconobs,800031 ),'
--         || vidioma || ',ao.CCONOBS) TCONOBS,  CTIPOBS , ff_desvalorfijo(323,' || vidioma
--         || ',ctipobs) TTIPOBS,
--  TTITOBS ,  TOBS,FOBS, FRECORDATORIO,ao.CTIPAGD, ad.TTIPAGD, SSEGURO ,NRECIBO, CAGENTE, NSINIES, NTRAMIT,
--  CAMBITO, '''' TAMBITO, CPRIORI , '''' TPRIORI,CPRIVOBS, '''' TPRIVOBS, am.nmovobs, am.cestobs, ff_desvalorfijo(29,'
--         || vidioma || ', am.cestobs) testobs,  am.festobs, pac_agenda.f_get_entidad('
--         || pac_md_common.f_get_cxtempresa || ', ' || vidioma
--         || ', ao.idobs,ao.ctipagd,null,null) tentidad, ao.cusualt, ao.falta, decode(am.cestobs,1,am.festobs,null) ffinali
--  from agd_observaciones ao, agd_destiposagenda ad,  agd_movobs am, agd_obs_config aoc
--  where aoc.cempres = ao.cempres and ad.cempres = ao.cempres and ao.ctipagd = aoc.ctipagd
--  and ao.cempres = am.cempres
--  and ao.ctipagd = ad.ctipagd and ad.cidioma = '
--         || vidioma
--         || '
--   and am.idobs = ao.idobs and am.nmovobs = (select max(nmovobs) from agd_movobs amm where amm.idobs = ao.idobs) '
--         || vwhere || ' order by ao.idobs desc';
--INI  IAXIS 3482 SGM  07/05/2019  se agregan ao.TFILENAME, ao.IDDOCGEDOX para el link al fichero
      vwhere :=
         vwhere || ' and ao.cempres = ' || pac_md_common.f_get_cxtempresa
         || ' and (pac_agenda.f_obs_isvisible(' || pac_md_common.f_get_cxtempresa
         || ',ao.ctipagd,ao.idobs) = 1 or ((ao.cprivobs = 1 or ao.cprivobs is null) and ao.cusualt = '''
         || pac_md_common.f_get_cxtusuario || ''') OR ao.publico = 1) ';
      vquery :=
         'select ao.IDOBS, ao.publico,ao.CCONOBS, ff_desvalorfijo(nvl(aoc.cconobs,800031 ),'
         || vidioma || ',ao.CCONOBS) TCONOBS,  CTIPOBS , ff_desvalorfijo(323,' || vidioma;
--INI SGM 17/04/2019 IAXIS 3482 PODER INGRESAR ACUERDOS DE PAGO, MASIVAMENTE Y TRAZAR
          IF  (pctipagd = 2) then 
                   vquery := vquery ||  ',ctipobs) TTIPOBS,
          TTITOBS ,  am.TOBS,FOBS, FRECORDATORIO,ao.CTIPAGD,ao.TFILENAME, ao.IDDOCGEDOX, ad.TTIPAGD, SSEGURO ,NRECIBO, CAGENTE, NSINIES, NTRAMIT,
          CAMBITO, '''' TAMBITO, CPRIORI , '''' TPRIORI,CPRIVOBS, '''' TPRIVOBS, am.nmovobs, am.cestobs, ff_desvalorfijo(29,';
          ELSE
                  vquery := vquery ||  ',ctipobs) TTIPOBS,
          TTITOBS ,  ao.TOBS,FOBS, FRECORDATORIO,ao.CTIPAGD, ad.TTIPAGD, SSEGURO ,NRECIBO, CAGENTE, NSINIES, NTRAMIT,
          CAMBITO, '''' TAMBITO, CPRIORI , '''' TPRIORI,CPRIVOBS, '''' TPRIVOBS, am.nmovobs, am.cestobs, ff_desvalorfijo(29,';
          END IF;    
--INI SGM 17/04/2019 IAXIS 3482 PODER INGRESAR ACUERDOS DE PAGO, MASIVAMENTE Y TRAZAR
         vquery := vquery || vidioma || ', am.cestobs) testobs,  am.festobs, pac_agenda.f_get_entidad('
         || pac_md_common.f_get_cxtempresa || ', ' || vidioma
         || ', ao.idobs,ao.ctipagd,null,null) tentidad, ao.cusualt, ao.falta, decode(am.cestobs,1,am.festobs,null) ffinali, '
         || '(select tusunom from usuarios usu where usu.cusuari = ao.cusualt) tusualt, '
         || 'decode(am.cestobs,1,(select tusunom from usuarios usu where usu.cusuari = am.cusualt),null) tusufin
  from agd_observaciones ao, agd_destiposagenda ad,  agd_movobs am, agd_obs_config aoc
  where aoc.cempres = ao.cempres and ad.cempres = ao.cempres and ao.ctipagd = aoc.ctipagd
  and ao.cempres = am.cempres
  and ao.ctipagd = ad.ctipagd and ad.cidioma = '
         || vidioma;
--INI SGM 17/04/2019 IAXIS 3482 PODER INGRESAR ACUERDOS DE PAGO, MASIVAMENTE Y TRAZAR
       if  (pctipagd = 2) then 
         vquery := vquery ||
         '
   and am.idobs = ao.idobs and am.nmovobs in (select nmovobs from agd_movobs amm where amm.idobs = ao.idobs and amm.cempres = ao.cempres) ';       
       
       else
         vquery := vquery ||
         '
   and am.idobs = ao.idobs and am.nmovobs = (select max(nmovobs) from agd_movobs amm where amm.idobs = ao.idobs and amm.cempres = ao.cempres) ';
       end if;
--INI SGM 17/04/2019 IAXIS 3482 PODER INGRESAR ACUERDOS DE PAGO, MASIVAMENTE Y TRAZAR
         vquery := vquery || vwhere || ' order by ao.idobs desc';
p_control_error('sgm','3f_get_lstagdobs',vquery);         
      --  4.0 0027525: La pantalla de [axisadm003] Consulta datos de un recibo tarda mucho en abrirse - Final
      plstagdobs := pac_iax_listvalores.f_opencursor(vquery, mensajes);
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
   END f_get_lstagdobs;

   /*************************************************************************
        Devuelve la lista de los conceptos seg??l tipo de agenda
        del usuario, de su rol o del rol propietario de la agenda
        param in pctipagd     : Tipo de Agenda (p??a, recibo, siniestro...)
        param out plstconceptos       : Cursor con los conceptos a mostrar
        return                : 0/1 OK/KO
     *************************************************************************/
   FUNCTION f_get_lstconceptos(
      pctipagd IN NUMBER,
      pcmodo IN VARCHAR2,
      plstconceptos OUT sys_refcursor,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vsquery        VARCHAR2(5000);
      vobjectname    VARCHAR2(500) := 'PAC_MD_AGENDA.f_get_lstconceptos';
      vparam         VARCHAR2(1000) := 'par?tros - pctipagd :' || pctipagd || ' m=' || pcmodo;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_agenda.f_get_lstconceptos(pac_md_common.f_get_cxtempresa,
                                               pac_md_common.f_get_cxtidioma, pctipagd, pcmodo,
                                               vsquery);

      IF vnumerr != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      plstconceptos := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
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
   END f_get_lstconceptos;

   /*************************************************************************
          Devuelve la lista de los roles de la agenda, si nos pasan el tipo de agenda no devolveremos el rol
          propietario ya que no se podr?estionar este rol, siempre ser?isible
          pctipagd IN NUMBER,
          plstroles OUT sys_refcursor       : cursor que devolveremos
          return                : 0/1 OK/KO
       *************************************************************************/
   FUNCTION f_get_lstroles(
      pctipagd IN NUMBER,
      plstroles OUT sys_refcursor,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vsquery        VARCHAR2(5000);
      vobjectname    VARCHAR2(500) := 'PAC_MD_AGENDA.f_get_lstroles';
      vparam         VARCHAR2(1000) := 'par?tros - pctipagd :' || pctipagd;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_agenda.f_get_lstroles(pac_md_common.f_get_cxtempresa,
                                           pac_md_common.f_get_cxtidioma, pctipagd, vsquery);

      IF vnumerr != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      plstroles := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
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
   END f_get_lstroles;

    /*************************************************************************
      Devuelve la lista de los tipos de agenda
      param out pquery       : query que devolveremos
      return                : 0/1 OK/KO
   *************************************************************************/
   FUNCTION f_get_lsttiposagenda(
      plsttiposagenda OUT sys_refcursor,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vsquery        VARCHAR2(5000);
      vobjectname    VARCHAR2(500) := 'PAC_MD_AGENDA.f_get_lsttiposagenda';
      vparam         VARCHAR2(1000) := 'par?tros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_agenda.f_get_lsttiposagenda(pac_md_common.f_get_cxtempresa,
                                                 pac_md_common.f_get_cxtidioma, vsquery);

      IF vnumerr != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      plsttiposagenda := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
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
   END f_get_lsttiposagenda;

/*************************************************************************
      Guardarem la obs/apu i crearem un apunt.
      Passarem en un objecte els valors SSEGURO, NRECIBO...
      En el cas que s'afegis una nova entitat de l'axis a l'agenda nom?hauriem
      de modificar la capa de negoci i afegir el nou camp ja que vindria en aquest objecte desde java.
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
      pcestobs IN NUMBER,
      pfestobs IN DATE,
      pidobs_out OUT VARCHAR2
      return                : 0/1 OK/KO
   *************************************************************************/
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
      pttipagd t_iax_info,
      pvisionrol IN t_iax_agd_vision,
      pvisionusu IN t_iax_agd_vision,
      pidobs_out OUT VARCHAR2,
      pdescripcion IN VARCHAR2,
      ptfilename IN VARCHAR2,
      piddocgedox IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      cur            sys_refcursor;
      vsquery        VARCHAR2(5000);
      vobjectname    VARCHAR2(500) := 'PAC_MD_AGENDA.f_set_obs';
      vparam         VARCHAR2(1000)
         := 'par?tros - pidobs: ' || pidobs || ' cconobs:' || pcconobs || ' pctipobs:'
            || pctipobs || ' pfobs:' || pfobs || ' pfrecordatorio:' || pfrecordatorio
            || ' pctipagd:' || pctipagd || ' pcambito:' || pcambito || ' pcpriori:'
            || pcpriori || ' pcprivobs:' || pcprivobs || ' pcestobs:' || pcestobs
            || ' pfestobs:' || pfestobs || ' ppublico:' || ppublico;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vtext          VARCHAR2(200);
      vfiltro        VARCHAR2(200);
      vexec          VARCHAR2(4000);
      vset           VARCHAR2(4000);
      vtinfo         t_iax_info;
      v_cont         NUMBER;
      vcempres       NUMBER := pac_md_common.f_get_cxtempresa;
   BEGIN
      vnumerr := pac_agenda.f_set_obs(vcempres, pidobs, pcconobs, pctipobs, pttitobs, ptobs,
                                      pfobs, pfrecordatorio, pctipagd, pcambito, pcpriori,
                                      pcprivobs, ppublico, pcestobs, pfestobs, pidobs_out, pdescripcion, ptfilename, piddocgedox);

      IF vnumerr != 0 THEN
         RAISE e_object_error;
      END IF;

      IF pttipagd IS NOT NULL
         AND pttipagd.COUNT > 0 THEN
         IF pidobs_out IS NOT NULL THEN
            vpasexec := 2;

            SELECT tfiltro
              INTO vfiltro
              FROM agd_obs_config
             WHERE pctipagd = ctipagd
               AND cempres = vcempres;

            vpasexec := 3;
            vtinfo := f_get_params(vfiltro);

            --actualitzem sseguro, nrecibo...etc
            FOR i IN pttipagd.FIRST .. pttipagd.LAST LOOP
               FOR j IN vtinfo.FIRST .. vtinfo.LAST LOOP
                  --Si los par?tros entrados por pantalla coinciden con los filtros parametrizados en la
                  --tabla, iremos creando la where din?ca.
                  IF UPPER(vtinfo(j).nombre_columna) LIKE UPPER(pttipagd(i).nombre_columna) THEN
                     IF pttipagd(i).valor_columna IS NOT NULL THEN
                        vset := vset || ' ,  ' || vtinfo(j).nombre_columna || ' = '''
                                || pttipagd(i).valor_columna || '''';
                     END IF;
                  END IF;
               END LOOP;
            END LOOP;

            vpasexec := 4;

            IF vset IS NOT NULL THEN
               vexec := 'update agd_observaciones set ctipagd =' || pctipagd || vset
                        || '
                 where idobs =' || pidobs_out || ' and cempres  = ' || vcempres;
            END IF;

            EXECUTE IMMEDIATE vexec;

            vpasexec := 5;

            IF ppublico IS NOT NULL
               AND ppublico = 1 THEN
               DELETE      agd_obs_vision
                     WHERE cempres = vcempres
                       AND idobs = pidobs_out;
            ELSE
               IF pvisionrol IS NOT NULL
                  AND pvisionrol.COUNT > 0 THEN
                  /*  FOR i IN pvisionrol.FIRST .. pvisionrol.LAST LOOP
                       IF pvisionrol.EXISTS(i) THEN
                          SELECT COUNT(1)
                            INTO v_cont
                            FROM agd_obs_vision
                           WHERE cempres = vcempres
                             AND idobs = pidobs_out
                             AND ctipvision = pvisionrol(i).ctipvision
                             AND ttipvision = pvisionrol(i).ttipvision;

                          vpasexec := 6;

                          IF (v_cont = 0
                              AND pvisionrol(i).cvisible != 0)
                             OR(v_cont > 0) THEN
                             vnumerr := pac_agenda.f_set_vision(vcempres, pidobs_out,
                                                                pvisionrol(i).ctipvision,
                                                                pvisionrol(i).ttipvision,
                                                                pvisionrol(i).cvisible);

                             IF vnumerr != 0 THEN
                                RAISE e_object_error;
                             END IF;
                          END IF;
                       END IF;
                    END LOOP;*/
                  DELETE      agd_obs_vision
                        WHERE cempres = vcempres
                          AND idobs = pidobs_out
                          AND ctipvision = 1;

                  FOR i IN pvisionrol.FIRST .. pvisionrol.LAST LOOP
                     vpasexec := 9;

                     IF pvisionrol.EXISTS(i) THEN
                        vnumerr := pac_agenda.f_set_vision(vcempres, pidobs_out,
                                                           pvisionrol(i).ctipvision,
                                                           pvisionrol(i).ttipvision,
                                                           NVL(pvisionrol(i).cvisible, 0));

                        IF vnumerr != 0 THEN
                           RAISE e_object_error;
                        END IF;
                     END IF;

                     vpasexec := 10;
                  END LOOP;
               ELSE
                  DELETE      agd_obs_vision
                        WHERE cempres = vcempres
                          AND idobs = pidobs_out
                          AND ctipvision = 1;
               END IF;

               vpasexec := 7;

               IF pvisionusu IS NOT NULL
                  AND pvisionusu.COUNT > 0 THEN
                  vpasexec := 8;

                  DELETE      agd_obs_vision
                        WHERE cempres = vcempres
                          AND idobs = pidobs_out
                          AND ctipvision = 2;

                  FOR i IN pvisionusu.FIRST .. pvisionusu.LAST LOOP
                     vpasexec := 9;

                     IF pvisionusu.EXISTS(i) THEN
                        vnumerr := pac_agenda.f_set_vision(vcempres, pidobs_out,
                                                           pvisionusu(i).ctipvision,
                                                           pvisionusu(i).ttipvision,
                                                           NVL(pvisionusu(i).cvisible, 0));

                        IF vnumerr != 0 THEN
                           RAISE e_object_error;
                        END IF;
                     END IF;

                     vpasexec := 10;
                  END LOOP;
               ELSE
                  DELETE      agd_obs_vision
                        WHERE cempres = vcempres
                          AND idobs = pidobs_out
                          AND ctipvision = 2;
               END IF;
            END IF;
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
   END f_set_obs;

   /*************************************************************************
        devolvemos la entidad dependiendo de la parametrizaci??echa en la tabla
        agd_obs_config. Seg??l tipo de agenda nos devolver?POLIZA - NCERTIF, NRECIBO, Nombre del agente...
        param in pctipagd     : Tipo de Agenda (p??a, recibo, siniestro...)
        param in pparams       : Parametros para filtrar y su valor
        return                : 0/1 OK/KO
     *************************************************************************/
   FUNCTION f_get_entidad(
      pctipagd IN NUMBER,
      pparams IN t_iax_info,
      ptentidad OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vsquery        VARCHAR2(5000);
      vobjectname    VARCHAR2(500) := 'PAC_MD_AGENDA.f_get_entidad';
      vparam         VARCHAR2(1000) := 'par?tros - pctipagd :' || pctipagd;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vfiltro        VARCHAR2(500);
      vtfiltro       VARCHAR2(2000);
      vvalorfiltro   VARCHAR2(2000);
      vtinfo         t_iax_info;
   BEGIN
      IF pctipagd IS NOT NULL THEN
         --Comprobamos que filtro especifico necesita el tipo de agenda
         SELECT NVL(tfiltro, '')
           INTO vfiltro
           FROM agd_obs_config
          WHERE ctipagd = pctipagd
            AND cempres = pac_md_common.f_get_cxtempresa;

         --Lo gestionamos para poder crear la where din?ca
         vtinfo := f_get_params(vfiltro);

         FOR i IN pparams.FIRST .. pparams.LAST LOOP
            FOR j IN vtinfo.FIRST .. vtinfo.LAST LOOP
               --Si los par?tros entrados por pantalla coinciden con los filtros parametrizados en la
               --tabla, iremos creando la where din?ca.
               IF UPPER(vtinfo(j).nombre_columna) LIKE UPPER(pparams(i).nombre_columna) THEN
                  IF pparams(i).valor_columna IS NOT NULL THEN
                     IF vtfiltro IS NOT NULL THEN
                        vtfiltro := vtfiltro || '||'',''||';
                        vvalorfiltro := vvalorfiltro || '||'',''||';
                     END IF;

                     vtfiltro := vtfiltro || pparams(i).nombre_columna;
                     vvalorfiltro := vvalorfiltro || pparams(i).valor_columna;
                  END IF;
               END IF;
            END LOOP;
         END LOOP;
      END IF;

      ptentidad := pac_agenda.f_get_entidad(pac_md_common.f_get_cxtempresa,
                                            pac_md_common.f_get_cxtidioma, NULL, pctipagd,
                                            vtfiltro, vvalorfiltro);
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
          Devuelve la visi??e la observaci??          propietario ya que no se podr?estionar este rol, siempre ser?isible
          pidobs IN NUMBER,
          plstvision OUT sys_refcursor       : cursor que devolveremos
          return                : 0/1 OK/KO
       *************************************************************************/
   FUNCTION f_get_visionobs(
      pidobs IN NUMBER,
      pctipagd IN NUMBER,
      plstvisionrol OUT t_iax_agd_vision,
      plstvisionusu OUT t_iax_agd_vision,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vsquery        VARCHAR2(5000);
      vobjectname    VARCHAR2(500) := 'PAC_IAX_AGENDA.f_get_lstvision';
      vparam         VARCHAR2(1000) := 'par?tros - pidobs :' || pidobs;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      obvision       ob_iax_agd_vision := ob_iax_agd_vision();
      cur            sys_refcursor;
   BEGIN
      vnumerr := pac_agenda.f_get_lstvision(pac_md_common.f_get_cxtempresa, pidobs, pctipagd,
                                            1, pac_md_common.f_get_cxtidioma, vsquery);   --recuperamos los rols

      IF vnumerr != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      cur := pac_md_listvalores.f_opencursor(vsquery, mensajes);
      plstvisionrol := t_iax_agd_vision();

      LOOP
         FETCH cur
          INTO obvision.ctipvision, obvision.desctipvision, obvision.ttipvision,
               obvision.descttipvision, obvision.cvisible;

         EXIT WHEN cur%NOTFOUND;
         plstvisionrol.EXTEND;
         plstvisionrol(plstvisionrol.LAST) := obvision;
         obvision := ob_iax_agd_vision();
      END LOOP;

      IF pidobs IS NOT NULL THEN
         vnumerr := pac_agenda.f_get_lstvision(pac_md_common.f_get_cxtempresa, pidobs,
                                               pctipagd, 2, pac_md_common.f_get_cxtidioma,
                                               vsquery);   --recuperamos los usuarios

         IF vnumerr != 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
            RAISE e_object_error;
         END IF;

         cur := pac_md_listvalores.f_opencursor(vsquery, mensajes);
         plstvisionusu := t_iax_agd_vision();
         obvision := ob_iax_agd_vision();

         LOOP
            FETCH cur
             INTO obvision.ctipvision, obvision.desctipvision, obvision.ttipvision,
                  obvision.descttipvision, obvision.cvisible;

            EXIT WHEN cur%NOTFOUND;
            plstvisionusu.EXTEND;
            plstvisionusu(plstvisionusu.LAST) := obvision;
            obvision := ob_iax_agd_vision();
         END LOOP;
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
   END f_get_visionobs;

   /*************************************************************************
            Borramos un apunte/observacion
            pidobs IN NUMBER,
            return                : 0/1 OK/KO
         *************************************************************************/
   FUNCTION f_del_observacion(pidobs IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vsquery        VARCHAR2(5000);
      vobjectname    VARCHAR2(500) := 'PAC_MD_AGENDA.f_del_observacion';
      vparam         VARCHAR2(1000) := 'par?tros - pidobs :' || pidobs;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      cur            sys_refcursor;
      trobat         BOOLEAN := FALSE;
      vidobs         NUMBER := -1;
   BEGIN
      IF pidobs IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_agenda.f_del_observacion(pac_md_common.f_get_cxtempresa, pidobs);

      IF vnumerr != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
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
   END f_del_observacion;

   /*************************************************************************
          Devuelve la lista grupos
          return                : Cursor
       *************************************************************************/
   FUNCTION f_get_lstgrupos(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobjectname    VARCHAR2(200) := 'PAC_MD_AGENDA.f_get_lstgrupos';
      vsquery        VARCHAR2(500);
      vnumerr        NUMBER;
   BEGIN
      vnumerr := pac_agenda.f_get_lstgrupos(pac_md_common.f_get_cxtempresa,
                                            pac_md_common.f_get_cxtidioma, vsquery);

      IF vnumerr != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      cur := pac_md_listvalores.f_opencursor(vsquery, mensajes);
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
   FUNCTION f_get_lstmotrespuesta(pcclagd NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobjectname    VARCHAR2(200) := 'PAC_MD_AGENDA.f_get_lstMotrespuesta';
      vsquery        VARCHAR2(500);
      vnumerr        NUMBER;
   BEGIN
      vsquery := 'SELECT CTIPRES, TRESPUE FROM AGD_ACCIONES' || ' WHERE CCLAGD = ' || pcclagd
                 || ' AND CIDIOMA = ' || pac_md_common.f_get_cxtidioma
                 || ' ORDER BY TRESPUE ASC ';
      cur := pac_md_listvalores.f_opencursor(vsquery, mensajes);
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

   /*Funci??e retorna el valor a mostrar per pantalla.
   Si es un apunt de p??sa, retornar?pol + ncertif, si ?de rebut nrecibo i si ?sinistre el nsinies.
   XPL#14102011#
   */
   FUNCTION f_get_valorclagd(
      pcclagd IN VARCHAR2,
      ptclagd IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_info IS
      vsquery        VARCHAR2(5000);
      vobjectname    VARCHAR2(500) := 'PAC_IAX_AGENDA.valorclagd';
      vparam         VARCHAR2(1000)
                            := 'par?tros - pcclagd: ' || pcclagd || ' ptclagd: ' || ptclagd;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vquery         VARCHAR2(3000);
      cur            sys_refcursor;
      vtclagd        t_iax_info := t_iax_info();
      vobclagd       ob_iax_info;
      vnpoliza       VARCHAR2(100);
      vncertif       VARCHAR2(100);
   BEGIN
      IF pcclagd IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_agenda.f_get_valorclagd(pcclagd, ptclagd, vquery);

      IF vnumerr != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      cur := pac_md_listvalores.f_opencursor(vquery, mensajes);
      vtclagd := t_iax_info();
      vobclagd := ob_iax_info();

      IF pcclagd = 1 THEN
         LOOP
            FETCH cur
             INTO vnpoliza, vncertif;

            EXIT WHEN cur%NOTFOUND;
         END LOOP;

         vtclagd.EXTEND;
         vobclagd := ob_iax_info();
         vobclagd.nombre_columna := 'NPOLIZA';
         vobclagd.valor_columna := vnpoliza;
         vtclagd(vtclagd.LAST) := vobclagd;
         vtclagd.EXTEND;
         vobclagd := ob_iax_info();
         vobclagd.nombre_columna := 'NCERTIF';
         vobclagd.valor_columna := vncertif;
         vtclagd(vtclagd.LAST) := vobclagd;
      END IF;

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

    /*Funci que crear tasca de la solicitud de projecte
   XPL#24102011#
   */
   FUNCTION f_tarea_sol_proyecto(psseguro IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vsquery        VARCHAR2(5000);
      vobjectname    VARCHAR2(500) := 'PAC_MD_AGENDA.f_tarea_sol_proyecto';
      vparam         VARCHAR2(1000) := 'parmetros - psseguro: ' || psseguro;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_agenda.f_tarea_sol_proyecto(psseguro, pac_md_common.f_get_cxtempresa,
                                                 pac_md_common.f_get_cxtidioma);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
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
      vobjectname    VARCHAR2(500) := 'PAC_MD_AGENDA.f_valconclusiones';
      vparam         VARCHAR2(1000) := 'parametros - PNSINIES :' || PNSINIES;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      C_CONCLU NUMBER;

   BEGIN
    
      IF PNSINIES IS NOT NULL THEN
           --45 = A TIPO CONCLUSIONES Y 0 ESTADO PENDIENTE
           SELECT COUNT(*) INTO C_CONCLU FROM  agd_observaciones s, agd_movobs o  WHERE nsinies=PNSINIES and CCONOBS=45
           AND O.IDOBS=S.IDOBS
           AND O.nmovobs=(SELECT  MAX(nmovobs) FROM agd_movobs WHERE IDOBS=S.IDOBS)
           AND O.cestobs=0;
  
           IF C_CONCLU>0 THEN
            RETURN 2;
            ELSE 
            SELECT  NVL(SUBSTR((SELECT TDESCRIE FROM riesgos WHERE sseguro=(SELECT SSEGURO from sin_siniestro WHERE nsinies=PNSINIES)
             ),1,1500),' ') INTO TDESCRIE FROM DUAL;
           END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_valconclusiones;
   
   
END pac_md_agenda;

/