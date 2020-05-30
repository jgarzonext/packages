--------------------------------------------------------
--  DDL for Package Body PAC_LISTADOS_WM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_LISTADOS_WM" IS
-- 1.0        16/06/2010  SRA              1. 0014874: WM - Llistats: creación del package
-- 2.0        28/09/2010  SRA              2. 0016143: WM - Modificaciones listados mediadores
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   -- recupera el nombre del primer asegurado, filtrando aquellos que están no vigentes
   FUNCTION f_primer_asegurado(p_sseguro IN asegurados.sseguro%TYPE)
      RETURN VARCHAR2 IS
      v_tasegurado   VARCHAR2(70);
   BEGIN
      SELECT tasegurado
        INTO v_tasegurado
        FROM (SELECT   f_nombre(a.sperson, 1) tasegurado
                  FROM asegurados a
                 WHERE a.sseguro = p_sseguro
                   AND a.ffecfin IS NULL
              ORDER BY a.norden, ffecini)
       WHERE ROWNUM = 1;

      RETURN v_tasegurado;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_primer_asegurado;

   FUNCTION f_ultrenova_dir(psseguro IN NUMBER, pfecha IN DATE)
      RETURN DATE IS
      xfrenova       DATE;
      xnmovimi       NUMBER;
      xerr           NUMBER := 0;
   BEGIN
      xerr := f_ultrenova(psseguro, pfecha, xfrenova, xnmovimi);

      IF xerr = 0 THEN
         RETURN xfrenova;
      ELSE
         RETURN TO_DATE(NULL);
      END IF;
   END;

   PROCEDURE p_listado_cartera(
      p_finicar IN DATE,
      p_ffincar IN DATE,
      p_cagente IN NUMBER,
      p_tlistacartera OUT t_iax_listadocartera_wm,
      mensajes IN OUT t_iax_mensajes) IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500)
         := 'finicar = ' || p_finicar || ', ffincar = ' || p_ffincar || ', pcagente = '
            || p_cagente;
      vobject        VARCHAR2(200) := 'pac_listados_wm.p_listado_cartera';
      nindice        NUMBER := 0;
      v_dinicar      DATE;
      v_tinicar      VARCHAR2(10);
      v_dfincar      DATE;
      v_tfincar      VARCHAR2(10);
      v_nerror       NUMBER;
      -- Bug 16143 - 28/09/2010 - SRA
      v_bhaycartera  BOOLEAN := FALSE;
      v_cagente      NUMBER;

      CURSOR c_cartera IS
         SELECT DISTINCT r.cagente AS cagente, f_desagente_t(s.cagente) tagente,
                         s.npoliza AS npoliza, r.nrecibo, INITCAP(tp.ttitulo) AS ttitulo,
                         r.femisio, r.fefecto, f_nombre(t.sperson, 1) AS ttomador,
                         DECODE(r.ctipcoa,
                                1,(dr.icombru + dr.icedcbr) -(dr.icomret + dr.icedcrt),
                                dr.icombru - dr.icomret) icomisinet,   --Com.neta
                         itotalr
                         - DECODE(r.ctipcoa,
                                  1,(dr.icombru + icedcbr) -(dr.icomret + dr.icedcrt),
                                  dr.icombru - dr.icomret) iliqrec,
                         NVL(dr.iprinet, 0) /* + NVL(dr.itotimp, 0)*/ ipritot,   --   Prima total = Prima neta + impostos)
                                                                              dr.itotalr,
                         s.cramo
                    FROM recibos r, seguros s, titulopro tp, tomadores t,   --, personas p,
                                                                         detvalores dv,
                         vdetrecibos dr
                   WHERE s.sseguro = r.sseguro
                     AND tp.cramo = s.cramo
                     AND tp.cmodali = s.cmodali
                     AND tp.ctipseg = s.ctipseg
                     AND tp.ccolect = s.ccolect
                     AND tp.cidioma = pac_md_common.f_get_cxtidioma
                     AND s.sseguro = t.sseguro
                     AND t.nordtom = 1
                     -- AND t.sperson = p.sperson
                     AND r.ctiprec = dv.catribu
                     AND r.nrecibo = dr.nrecibo
                     AND dv.cidioma = pac_md_common.f_get_cxtidioma
                     AND dv.cvalor = 8
                     AND s.cempres = pac_md_common.f_get_cxtempresa
--                     AND(r.cagente = v_cagente
  --                       OR v_cagente IS NULL)
                     AND r.cagente IN(SELECT a.cagente
                                        FROM (SELECT     LEVEL nivel, cagente
                                                    FROM redcomercial r2
                                                   WHERE r2.fmovfin IS NULL
                                              START WITH r2.cagente = v_cagente
                                                     AND r2.cempres =
                                                               pac_md_common.f_get_cxtempresa
                                                                                             ()
                                                     AND r2.fmovfin IS NULL
                                              CONNECT BY PRIOR r2.cagente =(r2.cpadre + 0)
                                                     AND PRIOR r2.cempres =(r2.cempres + 0)
                                                     AND r2.fmovfin IS NULL
                                                     AND r2.cagente >= 0) rr,
                                             agentes a
                                       WHERE rr.cagente = a.cagente)
                     AND(r.femisio >= v_dinicar
                         OR v_dinicar IS NULL)
                     AND(r.femisio <= v_dfincar
                         OR v_dfincar IS NULL)
                ORDER BY r.cagente, s.npoliza, r.femisio;
   BEGIN
      vpasexec := 1;

      IF p_cagente IS NULL THEN
         v_cagente := pac_md_persona.ff_agente_cpolvisio(pac_md_common.f_get_cxtagente);
      ELSE
         v_cagente := pac_md_persona.ff_agente_cpolvisio(p_cagente);
      END IF;

      vpasexec := 2;
      p_tlistacartera := t_iax_listadocartera_wm();
      vpasexec := 3;
      v_tinicar := TO_CHAR(p_finicar, 'dd/mm/yyyy');

      IF v_tinicar IS NOT NULL THEN
         v_dinicar := TO_DATE(v_tinicar || ' 00:00:00', 'dd/mm/yyyy hh24:mi:ss');
      END IF;

      vpasexec := 4;
      v_tfincar := TO_CHAR(p_ffincar, 'dd/mm/yyyy');

      IF v_tfincar IS NOT NULL THEN
         v_dfincar := TO_DATE(v_tfincar || ' 23:59:59', 'dd/mm/yyyy hh24:mi:ss');
         v_dfincar := LAST_DAY(v_dfincar);
      END IF;

      vpasexec := 5;

      FOR i IN c_cartera LOOP
         vpasexec := 6;
         -- Bug 16143 - 28/09/2010 - SRA
         v_bhaycartera := TRUE;
         nindice := nindice + 1;
         p_tlistacartera.EXTEND;
         p_tlistacartera(nindice) := ob_iax_listadocartera_wm();
         p_tlistacartera(nindice).cagente := i.cagente;
         p_tlistacartera(nindice).tagente := i.tagente;
         p_tlistacartera(nindice).npoliza := i.npoliza;
         p_tlistacartera(nindice).ttitulo := i.ttitulo;
         v_nerror := f_desramo(pccodram => i.cramo, pcidioma => pac_md_common.f_get_cxtidioma,
                               ptdescri => p_tlistacartera(nindice).tramo);
         p_tlistacartera(nindice).ttomador := i.ttomador;
         p_tlistacartera(nindice).nrecibo := i.nrecibo;
         p_tlistacartera(nindice).fefecto := i.fefecto;
         p_tlistacartera(nindice).femisio := i.femisio;
         vpasexec := 5;
         p_tlistacartera(nindice).icomisinet := i.icomisinet;
         p_tlistacartera(nindice).iliqrec := i.iliqrec;
         p_tlistacartera(nindice).ipritot := i.ipritot;
         p_tlistacartera(nindice).itotalr := i.itotalr;
      END LOOP;

         -- Bug 16143 - 28/09/2010 - SRA
      --   IF NOT v_bhaycartera THEN
        --    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9901500);
        -- END IF;
      vpasexec := 6;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
   END p_listado_cartera;

   PROCEDURE p_listado_polizas(
      p_finicar IN DATE,
      p_ffincar IN DATE,
      p_cagente IN NUMBER,
      p_tlistapolizas OUT t_iax_listadopolizas_wm,
      mensajes IN OUT t_iax_mensajes) IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500)
         := 'finicar = ' || p_finicar || ', ffincar = ' || p_ffincar || ', pcagente = '
            || p_cagente;
      vobject        VARCHAR2(200) := 'pac_listados_wm.p_listado_polizas';
      nindice        NUMBER := 0;
      v_dinicar      DATE;
      v_tinicar      VARCHAR2(10);
      v_dfincar      DATE;
      v_tfincar      VARCHAR2(10);
      v_cagente      NUMBER;

      CURSOR c_polizas IS
         SELECT   s.npoliza, s.fefecto, s.fvencim, s.femisio, s.ctipcom,
                                                                        /*MAX(LTRIM(RTRIM(p.tapelli))
                                                                            || DECODE(p.tnombre,
                                                                                      NULL, NULL,
                                                                                      ', ' || LTRIM(RTRIM(p.tnombre)))) OVER(PARTITION BY p.sperson)
                                                                                                                                         AS*/
                  NULL tnasegu, tp.ttitulo, s.iprianu, s.pdispri, ag.cagente,
                  f_desagente_t(ag.cagente) tagente, 0 pcomisi, s.sseguro, s.cidioma, s.cramo,
                  DECODE(f_es_renova(s.sseguro, TRUNC(f_sysdate)), 0, 2, 1) cmodcom,
                  ag.ccomisi, s.fcarant
             FROM seguros s, /*asegurados a,*/ titulopro tp, agentes ag
            WHERE   --(s.cagente = v_cagente
                    -- OR v_cagente IS NULL)
                  s.cagente IN(SELECT a.cagente
                                 FROM (SELECT     LEVEL nivel, cagente
                                             FROM redcomercial r2
                                            WHERE r2.fmovfin IS NULL
                                       START WITH r2.cagente = v_cagente
                                              AND r2.cempres = pac_md_common.f_get_cxtempresa
                                                                                             ()
                                              AND r2.fmovfin IS NULL
                                       CONNECT BY PRIOR r2.cagente =(r2.cpadre + 0)
                                              AND PRIOR r2.cempres =(r2.cempres + 0)
                                              AND r2.fmovfin IS NULL
                                              AND r2.cagente >= 0) rr,
                                      agentes a
                                WHERE rr.cagente = a.cagente)
              AND s.csituac = 0
              AND s.cduraci = 0
              AND s.cempres = pac_md_common.f_get_cxtempresa
              --AND s.sseguro = a.sseguro
              AND tp.cramo = s.cramo
              AND tp.cmodali = s.cmodali
              AND tp.ctipseg = s.ctipseg
              AND tp.ccolect = s.ccolect
              AND tp.cidioma = pac_md_common.f_get_cxtidioma
              AND s.ctipcom = 0   --comissió habitual
              --     AND c1.cramo = s.cramo
                --   AND c1.cmodali = s.cmodali
                  -- AND c1.ctipseg = s.ctipseg
                  -- AND c1.ccolect = s.ccolect
                  -- AND c1.ccomisi = ag.ccomisi
                  -- AND c1.cmodcom = DECODE(f_es_renova(s.sseguro, TRUNC(f_sysdate)), 0, 2, 1)
              AND s.cagente = ag.cagente
              --AND S.SSEGURO = a.sseguro
--              AND(s.fefecto >= v_dinicar
--                  OR v_dinicar IS NULL)
--              AND(s.fefecto <= v_dfincar
--                  OR v_dfincar IS NULL)
         UNION ALL
         SELECT   s.npoliza, s.fefecto, s.fvencim, s.femisio, s.ctipcom,                                                       /*
                                                                         MAX(LTRIM(RTRIM(p.tapelli))
                                                                             || DECODE(p.tnombre,
                                                                                       NULL, NULL,
                                                                                       ', ' || LTRIM(RTRIM(p.tnombre)))) OVER(PARTITION BY p.sperson)
                                                                                                                                           AS*/ NULL
                                                                                       tnasegu,
                  tp.ttitulo, s.iprianu, s.pdispri, ag.cagente,
                  f_desagente_t(ag.cagente) tagente, c2.pcomisi pcomisi, s.sseguro, s.cidioma,
                  s.cramo, DECODE(f_es_renova(s.sseguro, TRUNC(f_sysdate)), 0, 2, 1) cmodcom,
                  ag.ccomisi, s.fcarant
             FROM seguros s, /*asegurados a,*/ titulopro tp, agentes ag,   /*personas p,*/
                                                                        comisionsegu c2
            WHERE (   --s.cagente = v_cagente
                      --OR v_cagente IS NULL)
                   s.cagente IN(SELECT a.cagente
                                  FROM (SELECT     LEVEL nivel, cagente
                                              FROM redcomercial r2
                                             WHERE r2.fmovfin IS NULL
                                        START WITH r2.cagente = v_cagente
                                               AND r2.cempres =
                                                               pac_md_common.f_get_cxtempresa
                                                                                             ()
                                               AND r2.fmovfin IS NULL
                                        CONNECT BY PRIOR r2.cagente =(r2.cpadre + 0)
                                               AND PRIOR r2.cempres =(r2.cempres + 0)
                                               AND r2.fmovfin IS NULL
                                               AND r2.cagente >= 0) rr,
                                       agentes a
                                 WHERE rr.cagente = a.cagente))
              AND s.csituac = 0
              AND s.cduraci = 0
              --AND s.sseguro = a.sseguro
              AND tp.cramo = s.cramo
              AND tp.cmodali = s.cmodali
              AND tp.ctipseg = s.ctipseg
              AND tp.ccolect = s.ccolect
              AND tp.cidioma = pac_md_common.f_get_cxtidioma
              AND s.ctipcom = 90   -- comisión especial seguro
              AND c2.sseguro = s.sseguro
              AND c2.cmodcom = DECODE(f_es_renova(s.sseguro, TRUNC(f_sysdate)), 0, 2, 1)
              AND s.cagente = ag.cagente
              /* AND a.sperson = p.sperson
                 AND a.norden IN(SELECT MIN(a2.norden)
                                   FROM asegurados a2
                                  WHERE a2.sseguro = a.sseguro)*/
--              AND(s.fefecto >= v_dinicar
--                  OR v_dinicar IS NULL)
--              AND(s.fefecto <= v_dfincar
--                  OR v_dfincar IS NULL)
         UNION ALL
         SELECT   s.npoliza, s.fefecto, s.fvencim, s.femisio, s.ctipcom,
                                                                        /*MAX(LTRIM(RTRIM(p.tapelli))
                                                                             || DECODE(p.tnombre,
                                                                                       NULL, NULL,
                                                                                       ', ' || LTRIM(RTRIM(p.tnombre)))) OVER(PARTITION BY p.sperson)
                                                                                                                                           AS*/
                  NULL tnasegu, tp.ttitulo, s.iprianu, s.pdispri, ag.cagente,
                  f_desagente_t(ag.cagente) tagente, 0 pcomisi, s.sseguro, s.cidioma, s.cramo,
                  DECODE(f_es_renova(s.sseguro, TRUNC(f_sysdate)), 0, 2, 1) cmodcom,
                  ag.ccomisi, s.fcarant
             FROM seguros s, /* asegurados a,*/ titulopro tp, agentes ag
            WHERE   --(s.cagente = v_cagente
                  --OR v_cagente IS NULL)
                  s.cagente IN(SELECT a.cagente
                                 FROM (SELECT     LEVEL nivel, cagente
                                             FROM redcomercial r2
                                            WHERE r2.fmovfin IS NULL
                                       START WITH r2.cagente = v_cagente
                                              AND r2.cempres = pac_md_common.f_get_cxtempresa
                                                                                             ()
                                              AND r2.fmovfin IS NULL
                                       CONNECT BY PRIOR r2.cagente =(r2.cpadre + 0)
                                              AND PRIOR r2.cempres =(r2.cempres + 0)
                                              AND r2.fmovfin IS NULL
                                              AND r2.cagente >= 0) rr,
                                      agentes a
                                WHERE rr.cagente = a.cagente)
              AND s.csituac = 0
              AND s.cduraci = 0
              AND s.cempres = pac_md_common.f_get_cxtempresa
              --AND s.sseguro = a.sseguro
              AND tp.cramo = s.cramo
              AND tp.cmodali = s.cmodali
              AND tp.ctipseg = s.ctipseg
              AND tp.ccolect = s.ccolect
              AND s.ctipcom = 99   -- sin comisión
              AND tp.cidioma = pac_md_common.f_get_cxtidioma
              AND s.cagente = ag.cagente
              /*AND a.sperson = p.sperson
                AND a.norden IN(SELECT MIN(a2.norden)
                                  FROM asegurados a2
                                 WHERE a2.sseguro = a.sseguro)*/
--              AND(s.fefecto >= v_dinicar
--                  OR v_dinicar IS NULL)
--              AND(s.fefecto <= v_dfincar
--                  OR v_dfincar IS NULL)
         ORDER BY fefecto, /*ttitulo,*/ npoliza;

      FUNCTION f_user_alta(p_sseguro IN asegurados.sseguro%TYPE)
         RETURN VARCHAR2 IS
         v_cusualt      VARCHAR2(20);
      BEGIN
         SELECT cusumov
           INTO v_cusualt
           FROM movseguro
          WHERE sseguro = p_sseguro
            AND nmovimi = 1
            AND cmotmov = 100;

         RETURN v_cusualt;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN NULL;
      END f_user_alta;
   BEGIN
      vpasexec := 1;

      IF p_cagente IS NULL THEN
         v_cagente := pac_md_persona.ff_agente_cpolvisio(pac_md_common.f_get_cxtagente);
      ELSE
         v_cagente := pac_md_persona.ff_agente_cpolvisio(p_cagente);
      END IF;

      vpasexec := 2;
      p_tlistapolizas := t_iax_listadopolizas_wm();
      vpasexec := 3;
      v_tinicar := TO_CHAR(p_finicar, 'dd/mm/yyyy');

      IF v_tinicar IS NOT NULL THEN
         v_dinicar := TO_DATE(v_tinicar || ' 00:00:00', 'dd/mm/yyyy hh24:mi:ss');
      END IF;

      vpasexec := 4;
      v_tfincar := TO_CHAR(p_ffincar, 'dd/mm/yyyy');

      IF v_tfincar IS NOT NULL THEN
         v_dfincar := TO_DATE(v_tfincar || ' 23:59:59', 'dd/mm/yyyy hh24:mi:ss');
      END IF;

      FOR i IN c_polizas LOOP
         DECLARE
            v_triesgo1     VARCHAR2(60);
            v_triesgo2     VARCHAR2(60);
            v_triesgo3     VARCHAR2(60);
            v_nerror       NUMBER := 0;
            v_cidioma      seguros.cidioma%TYPE := 0;
            v_dfrenova     DATE;
         BEGIN
            vpasexec := 5;
            v_dfrenova := f_ultrenova_dir(i.sseguro, v_dfincar);

            IF v_dfrenova BETWEEN v_dinicar AND v_dfincar THEN
               vpasexec := 6;
               nindice := nindice + 1;
               p_tlistapolizas.EXTEND;
               p_tlistapolizas(nindice) := ob_iax_listadopolizas_wm();
               p_tlistapolizas(nindice).npoliza := i.npoliza;
               p_tlistapolizas(nindice).fefecto := i.fefecto;
               p_tlistapolizas(nindice).fvencim := i.fvencim;
               p_tlistapolizas(nindice).femisio := i.femisio;
               --v_nerror := f_asegurado(i.sseguro, 1, p_tlistapolizas(nindice).tnasegu, v_cidioma);
               p_tlistapolizas(nindice).tnasegu := f_primer_asegurado(i.sseguro);
               vpasexec := 7;
               v_nerror := f_desriesgo(i.sseguro, 1, i.fefecto, i.cidioma, v_triesgo1,
                                       v_triesgo2, v_triesgo3);
               p_tlistapolizas(nindice).triesgo :=
                                   v_triesgo1 || ' ' || v_triesgo2 || ' ' || v_triesgo3 || ' ';
               p_tlistapolizas(nindice).ttitulo := i.ttitulo;
               vpasexec := 8;
               v_nerror := f_desramo(pccodram => i.cramo,
                                     pcidioma => pac_md_common.f_get_cxtidioma,
                                     ptdescri => p_tlistapolizas(nindice).tramo);
               p_tlistapolizas(nindice).iprianu := i.iprianu;
               p_tlistapolizas(nindice).pdispri := i.pdispri;

               IF i.ctipcom = 0 THEN
                  DECLARE
                     nerror         NUMBER;
                     vppretenc      NUMBER;
                  BEGIN
                     nerror := f_pcomisi(i.sseguro, i.cmodcom, f_sysdate,
                                         p_tlistapolizas(nindice).pcomisi, vppretenc, NULL,
                                         NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'CAR',
                                         NVL(i.fcarant, i.fefecto));
                  END;
               END IF;

               -- p_tlistapolizas(nindice).pcomisi := i.pcomisi;
               p_tlistapolizas(nindice).cagente := i.cagente;
               p_tlistapolizas(nindice).tagente := i.tagente;
               p_tlistapolizas(nindice).cusualt := f_user_alta(i.sseguro);
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               vparam := vparam || ', última póliza tratada: ' || i.npoliza;
               RAISE;
         END;
      END LOOP;

      vpasexec := 7;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
   END p_listado_polizas;

   PROCEDURE p_listado_siniestros(
      p_finicar IN DATE,
      p_ffincar IN DATE,
      p_cagente IN NUMBER,
      p_tlistasiniestros IN OUT t_iax_listadosiniestros_wm,
      mensajes IN OUT t_iax_mensajes) IS
      vpasexec       NUMBER(8) := 1;
      vparam         tab_error.terror%TYPE;
      vobject        VARCHAR2(200) := 'pac_listados_wm.p_listado_siniestros';
      nindice        NUMBER := 0;
      v_dinicar      DATE;
      v_tinicar      VARCHAR2(10);
      v_dfincar      DATE;
      v_tfincar      VARCHAR2(10);
      v_cidioma      NUMBER := pac_md_common.f_get_cxtidioma;
      v_cagente      NUMBER;

      CURSOR c_siniestros IS
         SELECT DISTINCT s.sseguro, s.npoliza, s.cramo, s.cagente,
                         f_desagente_t(s.cagente) tagente, s.fefecto, si.nsinies, si.fsinies,
                         si.falta fentrad,
                         DECODE(smov.cestsin, 1, smov.festsin, NULL) AS fcierre, cs.tcausin,
                         ds.tmotsin, t.ctramit, t.ntramit, ttramit, v.cgarant,
                         NULL AS tgarant,
                         FIRST_VALUE(v.ireserva) OVER(PARTITION BY v.nsinies, v.ntramit, v.cgarant ORDER BY v.fmovres)
                                                                                   AS ivalori,   -- importe de la primera valoración que se ha hecho del siniestro
                         FIRST_VALUE(v.ireserva) OVER(PARTITION BY v.nsinies, v.ntramit, v.cgarant ORDER BY v.fmovres DESC)
                                                                                   AS ivalorf   -- importe de la última valoración que se ha hecho del siniestro
                    FROM seguros s, /*asegurados a,*/ sin_siniestro si, sin_descausa cs,
                         sin_desmotcau ds, sin_tramitacion t, sin_tramita_reserva v,
                         sin_movsiniestro smov, sin_destramitacion destrami
                   WHERE si.sseguro = s.sseguro
                     AND(si.fnotifi BETWEEN v_dinicar AND v_dfincar
                         OR
                           -- reaperturado
                         (  EXISTS(SELECT 'x'
                                     FROM sin_movsiniestro mov
                                    WHERE mov.nsinies = si.nsinies
                                      AND mov.festsin BETWEEN v_dinicar AND v_dfincar
                                      AND mov.nmovsin =
                                            (SELECT MIN(nmovsin)
                                               FROM sin_movsiniestro mov2
                                              WHERE mov2.cestsin = 4   --reaperturado
                                                AND mov2.nsinies = mov.nsinies))))
                     AND si.ccausin = cs.ccausin
                     AND cs.cidioma = v_cidioma
                     AND ds.cidioma = v_cidioma
                     AND destrami.cidioma = v_cidioma
                     AND destrami.ctramit = t.ctramit
                     AND si.cmotsin = ds.cmotsin
                     AND si.ccausin = ds.ccausin
                     --  AND s.cramo = ds.cramo
                     AND si.nsinies = t.nsinies
                     AND smov.nsinies = si.nsinies
                     AND s.cempres = pac_md_common.f_get_cxtempresa
                     AND smov.nmovsin = (SELECT MAX(nmovsin)
                                           FROM sin_movsiniestro mov2
                                          WHERE mov2.nsinies = smov.nsinies)
                     AND t.nsinies = v.nsinies
                     AND t.ntramit = v.ntramit
                     -- AND(s.cagente = v_cagente
                       --   OR v_cagente IS NULL)
                     AND s.cagente IN(SELECT a.cagente
                                        FROM (SELECT     LEVEL nivel, cagente
                                                    FROM redcomercial r2
                                                   WHERE r2.fmovfin IS NULL
                                              START WITH r2.cagente = v_cagente
                                                     AND r2.cempres =
                                                               pac_md_common.f_get_cxtempresa
                                                                                             ()
                                                     AND r2.fmovfin IS NULL
                                              CONNECT BY PRIOR r2.cagente =(r2.cpadre + 0)
                                                     AND PRIOR r2.cempres =(r2.cempres + 0)
                                                     AND r2.fmovfin IS NULL
                                                     AND r2.cagente >= 0) rr,
                                             agentes a
                                       WHERE rr.cagente = a.cagente)
                ORDER BY s.npoliza, si.nsinies, t.ctramit, v.cgarant;

      FUNCTION f_user_alta_sini(p_nsinies IN sin_siniestro.nsinies%TYPE)
         RETURN VARCHAR2 IS
         v_cusualt      VARCHAR2(20);
      BEGIN
         SELECT cusualt
           INTO v_cusualt
           FROM sin_siniestro
          WHERE nsinies = p_nsinies;

         RETURN v_cusualt;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN NULL;
      END f_user_alta_sini;
   BEGIN
      vpasexec := 1;

      -- el agente llega a nulo siempre
      IF p_cagente IS NULL THEN
         v_cagente := pac_md_persona.ff_agente_cpolvisio(pac_md_common.f_get_cxtagente);
      ELSE
         v_cagente := pac_md_persona.ff_agente_cpolvisio(p_cagente);
      END IF;

      p_tlistasiniestros := t_iax_listadosiniestros_wm();
      vpasexec := 2;
      vparam := 'p_finicar: ' || p_finicar || ', p_ffincar: ' || p_ffincar || ', p_cagente: '
                || p_cagente;
      vpasexec := 3;
      v_tinicar := TO_CHAR(p_finicar, 'dd/mm/yyyy');

      IF v_tinicar IS NOT NULL THEN
         v_dinicar := TO_DATE(v_tinicar || ' 00:00:00', 'dd/mm/yyyy hh24:mi:ss');
      END IF;

      vpasexec := 4;
      v_tfincar := TO_CHAR(p_ffincar, 'dd/mm/yyyy');

      IF v_tfincar IS NOT NULL THEN
         v_dfincar := TO_DATE(v_tfincar || ' 23:59:59', 'dd/mm/yyyy hh24:mi:ss');
      END IF;

      vpasexec := 5;
      vpasexec := 6;

      FOR i IN c_siniestros LOOP
         DECLARE
            v_nresul       NUMBER;
         BEGIN
            nindice := nindice + 1;
            p_tlistasiniestros.EXTEND;
            p_tlistasiniestros(nindice) := ob_iax_listadosiniestros_wm();
            p_tlistasiniestros(nindice).npoliza := i.npoliza;
            v_nresul := f_desramo(pccodram => i.cramo, pcidioma => v_cidioma,
                                  ptdescri => p_tlistasiniestros(nindice).tramo);
            p_tlistasiniestros(nindice).cagente := i.cagente;
            p_tlistasiniestros(nindice).tagente := i.tagente;
            p_tlistasiniestros(nindice).fefecto := i.fefecto;
            p_tlistasiniestros(nindice).nsinies := i.nsinies;
            p_tlistasiniestros(nindice).fsinies := i.fsinies;
            p_tlistasiniestros(nindice).fentrad := i.fentrad;
            p_tlistasiniestros(nindice).fcierre := i.fcierre;
            p_tlistasiniestros(nindice).ntramit := i.ntramit;
            p_tlistasiniestros(nindice).ttramit := i.ttramit;
            p_tlistasiniestros(nindice).tcausin := i.tcausin;
            p_tlistasiniestros(nindice).tmotsin := i.tmotsin;
            v_nresul := f_desgarantia(i.cgarant, v_cidioma,
                                      p_tlistasiniestros(nindice).tgarant);
            p_tlistasiniestros(nindice).tasegurado := f_primer_asegurado(i.sseguro);
            p_tlistasiniestros(nindice).ivalori := NVL(i.ivalori, 0);

            SELECT SUM(DECODE(pi.ctippag, 2, NVL(pi.isinret, 0), 3, -NVL(pi.isinret, 0), 0))
                   + SUM(DECODE(pi.ctippag, 7, -NVL(pi.isinret, 0), 8, NVL(pi.isinret, 0), 0))
              INTO p_tlistasiniestros(nindice).ipagost
              FROM sin_tramita_pago pi, sin_tramita_pago_gar pg
             WHERE pi.nsinies = i.nsinies
               AND pi.ntramit = i.ntramit
               AND pi.sidepag = pg.sidepag
               AND pg.cgarant = i.cgarant;

            p_tlistasiniestros(nindice).ipagost := NVL(p_tlistasiniestros(nindice).ipagost, 0);

            SELECT NVL(SUM(pi.isinret * DECODE(pi.ctippag, 8, -1, 1)), 0)
              INTO p_tlistasiniestros(nindice).irecobro
              FROM sin_tramita_pago pi, sin_tramita_pago_gar pg
             WHERE pi.nsinies = i.nsinies
               AND pi.cestado = 2
               AND pi.ctippag IN(7, 8)
               AND pi.ntramit = i.ntramit
               AND pi.sidepag = pg.sidepag
               AND pg.cgarant = i.cgarant;

            p_tlistasiniestros(nindice).irecobro :=
                                                   NVL(p_tlistasiniestros(nindice).irecobro, 0);
            p_tlistasiniestros(nindice).ivalorf :=
                    GREATEST(NVL(i.ivalorf, 0) - NVL(p_tlistasiniestros(nindice).ipagost, 0),
                             0);
            p_tlistasiniestros(nindice).cusualt := f_user_alta_sini(i.nsinies);
         END;
      END LOOP;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
   END p_listado_siniestros;
END pac_listados_wm;

/

  GRANT EXECUTE ON "AXIS"."PAC_LISTADOS_WM" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_LISTADOS_WM" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_LISTADOS_WM" TO "PROGRAMADORESCSI";
