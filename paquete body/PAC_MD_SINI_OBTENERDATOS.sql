--------------------------------------------------------
--  DDL for Package Body PAC_MD_SINI_OBTENERDATOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_SINI_OBTENERDATOS" AS
/******************************************************************************
   NOMBRE:    PAC_MD_SINI_OBTENERDATOS
   PROPÓSITO: Funciones para la gestión de siniestros

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        27/12/2007   JAS                1. Creación del package.
   2.0        22/09/2009   DRA                2. 0011183: CRE - Suplemento de alta de asegurado ya existente
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /***********************************************************************
      Recupera los datos generales de un determinado siniestro, sin completar los subojetos PAGOS, DOCUMENTACION, ETC
      param in  pnsinies  : número de siniestro
      param out mensajes  : mensajes de error
      return              : OB_IAX_SINIESTROS con la información general del siniestro
                            NULL -> Se ha producido un error
   ***********************************************************************/
   FUNCTION f_get_datsiniestro(pnsinies IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_siniestros IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_SINI_OBTENERDATOS.F_Get_DatSiniestro';
      vparam         VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vobsini        ob_iax_siniestros := ob_iax_siniestros();
      vcramo         NUMBER;
   BEGIN
      --Comprovació dels parámetres d'entrada
      IF pnsinies IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;

      --Recuperem les dades generals del sinistre
      FOR cur_sini IN (SELECT *
                         FROM siniestros s
                        WHERE s.nsinies = pnsinies) LOOP
         vpasexec := 5;
         vobsini.nsinies := cur_sini.nsinies;
         vobsini.sseguro := cur_sini.sseguro;
         vobsini.nriesgo := cur_sini.nriesgo;
         vobsini.fsinies := TRUNC(cur_sini.fsinies);
         vobsini.hsinies := TO_CHAR(cur_sini.fsinies, 'HH24:MI');
         vobsini.fnotifi := cur_sini.fnotifi;
         vobsini.ctrami := cur_sini.ctraint;
         vobsini.cestsin := cur_sini.cestsin;
         vobsini.tsinies := cur_sini.tsinies;
         vobsini.cmotsin := cur_sini.cmotsin;
         vobsini.ccausin := cur_sini.ccausin;
         vobsini.cculpab := cur_sini.cculpab;
         vobsini.nsubest := cur_sini.nsubest;
      END LOOP;

      --Recuperació de descripcions
      vpasexec := 7;
      vobsini.testsin := pac_md_listvalores.f_getdescripvalores(6, vobsini.cestsin, mensajes);
      vobsini.tculpab := pac_md_listvalores.f_getdescripvalores(801, vobsini.cculpab, mensajes);
      vobsini.tsubest := pac_md_listvalores.f_getdescripvalores(665, vobsini.nsubest, mensajes);
      vpasexec := 9;

      SELECT p.cramo
        INTO vcramo
        FROM productos p, seguros s
       WHERE s.sseguro = vobsini.sseguro
         AND s.sproduc = p.sproduc;

      vpasexec := 11;

      IF vobsini.ccausin IS NOT NULL
         AND vobsini.cmotsin IS NOT NULL THEN
         vnumerr := pac_sin.f_desmotsini(vcramo, vobsini.ccausin, vobsini.cmotsin,
                                         pac_md_common.f_get_cxtidioma, vobsini.tmotsin);
      END IF;

      IF vobsini.ccausin IS NOT NULL THEN
         vnumerr := pac_sin.f_descausasini(vobsini.ccausin, pac_md_common.f_get_cxtidioma,
                                           vobsini.tcausin);
      END IF;

      --Comprovem si s'ha produït algun error en la recuperació de descripcions
      IF (vnumerr <> 0)
         OR(vobsini.testsin IS NULL
            AND vobsini.cestsin IS NOT NULL)
         OR(vobsini.tcausin IS NULL
            AND vobsini.ccausin IS NOT NULL)
         OR(vobsini.tculpab IS NULL
            AND vobsini.cculpab IS NOT NULL)
         OR(vobsini.tmotsin IS NULL
            AND vobsini.cmotsin IS NOT NULL) THEN
         vpasexec := 13;
         RAISE e_object_error;
      END IF;

      vobsini.triesgo := pac_md_obtenerdatos.f_desriesgos('POL', vobsini.sseguro,
                                                          vobsini.nriesgo, mensajes);

      IF vobsini.triesgo IS NULL THEN
         vpasexec := 15;
         RAISE e_object_error;
      END IF;

      IF pac_md_log.f_log_consultas('pnsinies = ' || pnsinies,
                                    'PAC_MD_SINI_OBTENERDATOS.F_GET_DATSINIESTRO', 2, 4,
                                    mensajes) <> 0 THEN
         RETURN NULL;
      END IF;

      RETURN vobsini;
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
   END f_get_datsiniestro;

   /***********************************************************************
      Recupera las valoraciones de un determinado siniestro
      param in  pnsinies  : número de siniestro
      param out mensajes  : mensajes de error
      return              : T_IAX_GARANSINI con la información de las valoraciones del siniestro
                            NULL -> Se ha producido un error
   ***********************************************************************/
   FUNCTION f_get_valorasini(pnsinies IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_garansini IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_SINI_OBTENERDATOS.F_Get_ValoraSini';
      vparam         VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      v_t_obvalora   t_iax_garansini := t_iax_garansini();
   BEGIN
      --Comprovació dels parámetres d'entrada
      IF pnsinies IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;

      --Recuperem els pagaments del sinistre
      FOR cur_valora IN (SELECT   v.*, g.tgarant
                             FROM valorasini v, garangen g
                            WHERE v.nsinies = pnsinies
                              AND v.fvalora = (SELECT MAX(v2.fvalora)
                                                 FROM valorasini v2
                                                WHERE v2.nsinies = v.nsinies
                                                  AND v2.cgarant = v.cgarant)
                              AND v.cgarant = g.cgarant
                              AND g.cidioma = pac_md_common.f_get_cxtidioma
                         ORDER BY v.cgarant) LOOP
         vpasexec := 5;
         v_t_obvalora.EXTEND;
         v_t_obvalora(v_t_obvalora.LAST) := ob_iax_garansini();
         --Recuperació de les dades de la valoració.
         v_t_obvalora(v_t_obvalora.LAST).nsinies := cur_valora.nsinies;
         v_t_obvalora(v_t_obvalora.LAST).cgarant := cur_valora.cgarant;
         v_t_obvalora(v_t_obvalora.LAST).tgarant := cur_valora.tgarant;
         v_t_obvalora(v_t_obvalora.LAST).fvalora := cur_valora.fvalora;
         v_t_obvalora(v_t_obvalora.LAST).ivalora := cur_valora.ivalora;
         v_t_obvalora(v_t_obvalora.LAST).icaprisc := cur_valora.icaprisc;
         v_t_obvalora(v_t_obvalora.LAST).ipenali := cur_valora.ipenali;
         v_t_obvalora(v_t_obvalora.LAST).fperini := cur_valora.fperini;
         v_t_obvalora(v_t_obvalora.LAST).fperfin := cur_valora.fperfin;
         v_t_obvalora(v_t_obvalora.LAST).cusualt := cur_valora.cusualt;
         v_t_obvalora(v_t_obvalora.LAST).falta := cur_valora.falta;
         v_t_obvalora(v_t_obvalora.LAST).cusumod := cur_valora.cusumod;
         v_t_obvalora(v_t_obvalora.LAST).fmodifi := cur_valora.fmodifi;
      END LOOP;

      RETURN v_t_obvalora;
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
   END f_get_valorasini;

   /***********************************************************************
      Recupera los datos de los pagos de un determinado siniestro
      param in  pnsinies  : número de siniestro
      param out mensajes  : mensajes de error
      return              : OB_IAX_PAGOS con la información de los pagos del siniestro
                            NULL -> Se ha producido un error
   ***********************************************************************/
   FUNCTION f_get_pagos(pnsinies IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_pagosini IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_SINI_OBTENERDATOS.F_Get_Pagos';
      vparam         VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      v_cagente      seguros.cagente%TYPE;
      v_t_obpagos    t_iax_pagosini := t_iax_pagosini();
   BEGIN
      --Comprovació dels parámetres d'entrada
      IF pnsinies IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;

      --Recuperem els pagaments del sinistre
      FOR cur_pagos IN (SELECT   *
                            FROM (SELECT p.*
                                    FROM tomadores t, siniestros s, pagosini p
                                   WHERE t.sperson = p.sperson
                                     AND t.sseguro = s.sseguro
                                     AND s.nsinies = p.nsinies
                                     AND p.nsinies = pnsinies
                                  UNION
                                  SELECT p.*
                                    FROM asegurados a, siniestros s, pagosini p
                                   WHERE a.sperson = p.sperson
                                     AND a.sseguro = s.sseguro
                                     AND a.norden = s.nasegur   -- BUG11183:DRA:22/09/2009
                                     AND s.nsinies = p.nsinies
                                     AND p.nsinies = pnsinies)
                        ORDER BY sidepag DESC) LOOP
         vpasexec := 5;
         v_t_obpagos.EXTEND;
         v_t_obpagos(v_t_obpagos.LAST) := ob_iax_pagosini();
         v_t_obpagos(v_t_obpagos.LAST).sidepag := cur_pagos.sidepag;
         v_t_obpagos(v_t_obpagos.LAST).ctipdes := cur_pagos.ctipdes;
         v_t_obpagos(v_t_obpagos.LAST).sperson := cur_pagos.sperson;
         v_t_obpagos(v_t_obpagos.LAST).ctippag := cur_pagos.ctippag;
         v_t_obpagos(v_t_obpagos.LAST).cestpag := cur_pagos.cestpag;
         v_t_obpagos(v_t_obpagos.LAST).fefepag := cur_pagos.fefepag;
         v_t_obpagos(v_t_obpagos.LAST).fordpag := cur_pagos.fordpag;
         v_t_obpagos(v_t_obpagos.LAST).ipago := cur_pagos.isinret;

         SELECT t.ctipide, t.nnumide
           INTO v_t_obpagos(v_t_obpagos.LAST).ctipide, v_t_obpagos(v_t_obpagos.LAST).nnumide
           FROM per_personas t
          WHERE t.sperson = cur_pagos.sperson;

         SELECT cagente
           INTO v_cagente
           FROM seguros seg, siniestros SIN
          WHERE seg.sseguro = SIN.sseguro
            AND SIN.nsinies = pnsinies;

         v_t_obpagos(v_t_obpagos.LAST).tnombre := f_nombre(cur_pagos.sperson, 1, v_cagente);   -- BUG 9529 - LPS - 30/04/2009
         --Recuperació de descripcions
         vpasexec := 7;
         v_t_obpagos(v_t_obpagos.LAST).ttipdes :=
                        pac_md_listvalores.f_getdescripvalores(10, cur_pagos.ctipdes, mensajes);
         v_t_obpagos(v_t_obpagos.LAST).ttippag :=
                         pac_md_listvalores.f_getdescripvalores(2, cur_pagos.ctippag, mensajes);
         v_t_obpagos(v_t_obpagos.LAST).testpag :=
                         pac_md_listvalores.f_getdescripvalores(3, cur_pagos.cestpag, mensajes);
         v_t_obpagos(v_t_obpagos.LAST).ttipide :=
            pac_md_listvalores.f_getdescripvalores(672, v_t_obpagos(v_t_obpagos.LAST).ctipide,
                                                   mensajes);

         --Comprovem si s'ha produït algun error en la recuperació de descripcions
         IF (v_t_obpagos(v_t_obpagos.LAST).ttipdes IS NULL
             AND cur_pagos.ctipdes IS NOT NULL)
            OR(v_t_obpagos(v_t_obpagos.LAST).ttippag IS NULL
               AND cur_pagos.ctippag IS NOT NULL)
            OR(v_t_obpagos(v_t_obpagos.LAST).testpag IS NULL
               AND cur_pagos.cestpag IS NOT NULL)
            OR(v_t_obpagos(v_t_obpagos.LAST).ttipide IS NULL
               AND v_t_obpagos(v_t_obpagos.LAST).ctipide IS NOT NULL) THEN
            vpasexec := 9;
            RAISE e_object_error;
         END IF;
      END LOOP;

      RETURN v_t_obpagos;
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
   END f_get_pagos;

   /***********************************************************************
      Recupera los datos de un determinado siniestro
      param in  pnsinies  : número de siniestro
      param out mensajes  : mensajes de error
      return              : OB_IAX_SINIESTROS con la información del siniestro
                            NULL -> Se ha producido un error
   ***********************************************************************/
   FUNCTION f_get_siniestro(pnsinies IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_siniestros IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_SINI_OBTENERDATOS.F_Get_Siniestro';
      vparam         VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vobsini        ob_iax_siniestros;
      v_t_obvalorasini t_iax_garansini;
      v_t_obdocum    t_iax_documentacion;
      v_t_obpagos    t_iax_pagosini;
   BEGIN
      vobsini := ob_iax_siniestros();
      vobsini.pagos := t_iax_pagosini();
      vobsini.garantias := t_iax_garansini();
      vobsini.documentacion := t_iax_documentacion();

      --Comprovació dels parámetres d'entrada
      IF pnsinies IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      --Recuperem les dades generals del sinistre
      vobsini := f_get_datsiniestro(pnsinies, mensajes);

      IF vobsini IS NULL THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 5;
      --Recuperem els pagaments associats al sinistre
      v_t_obpagos := f_get_pagos(pnsinies, mensajes);

      IF v_t_obpagos IS NULL THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 7;
      --Recuperem les valoracions associades al siniestre
      v_t_obvalorasini := f_get_valorasini(pnsinies, mensajes);

      IF v_t_obvalorasini IS NULL THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 9;
      --Recuperem la documentació associado al sinistre (PENDENT)

      --Preparació de l'objecte complet de sinistres
      vobsini.pagos := v_t_obpagos;
      vobsini.garantias := v_t_obvalorasini;
      vobsini.documentacion := t_iax_documentacion();
      RETURN vobsini;
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
   END f_get_siniestro;
END pac_md_sini_obtenerdatos;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_SINI_OBTENERDATOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_SINI_OBTENERDATOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_SINI_OBTENERDATOS" TO "PROGRAMADORESCSI";
