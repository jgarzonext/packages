--------------------------------------------------------
--  DDL for Package Body PAC_PENSIONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_PENSIONES" AS
   /******************************************************************************
     NOMBRE:       PAC_PENSIONES
     PROPÓSITO:  Package para gestionar los planes de pensiones

     REVISIONES:
     Ver        Fecha        Autor             Descripción
     ---------  ----------  ---------------  ------------------------------------
     1.0        XX/XX/XXXX   XXX                1. Creación del package.
     2.0        10/01/2010   RSC                2. 0017223: Actualización lista ENTIDADES SNCE
     3.0        27/01/2011   DRA                3. 0017051: ENSA101 - Informes ISS: format PDF
     4.0        25/05/2011   APD                4. 0018636: ENSA101-Revisar maps sobre prestaciones
     5.0        22/06/2011   RSC                5. 0018851: ENSA102 - Parametrización básica de traspasos de Contribución definida
   ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   FUNCTION f_get_planpensiones(
      coddgs IN VARCHAR2,
      fon_coddgs IN VARCHAR2,
      pctipide IN NUMBER,
      pnnumide IN VARCHAR2,
      nnompla IN VARCHAR2,
      pcagente IN NUMBER,
      ccodpla IN NUMBER,
      pfdatos OUT sys_refcursor)
      RETURN NUMBER IS
      vtraza         NUMBER := 0;
      vquery         VARCHAR2(2000);
   BEGIN
      vquery :=
         ' SELECT   (SELECT tbanco ' || ' FROM bancos '
         || ' WHERE cbanco = NVL(TO_NUMBER(SUBSTR(rel.cbancar, 1, 2)), null)) cbanc, pla.icomges, '
         || ' pla.icomdep, pla.ccodpla, pla.coddgs, pla.ccodfon, pla.tnompla, pla.faltare, pla.fadmisi, '
         || ' ff_desvalorfijo(669, pac_md_common.f_get_cxtidioma, pla.cmodali) tmodali, '
         || ' ff_desvalorfijo(670, pac_md_common.f_get_cxtidioma, pla.csistem) tsistem, '
         || ' per.tnombre || '' '' || per.tapelli1 || '' '' || per.tapelli2 tfondo, pac_cbancar_seg.ff_formatccc(NVL(rel.ctipban, fon.ctipban), NVL(rel.cbancar, fon.cbancar)) cbancar, '
         || ' fon.ccodges, g.coddgs, d.ccoddep, f_nombre(g.sperson, 1, ' || NVL(pcagente, -1)
         || ') tcodges, ' || ' f_nombre(d.sperson, 1, ' || NVL(pcagente, -1) || ') tcoddep, '
         || ' f_nombre(g.sperson, 1, ' || NVL(pcagente, -1) || ') tnomges, '
         || ' pla.cmodali, pla.csistem, pla.ccomerc, '
         || ' pla.cmespag, pla.ctipren, pla.cperiod, pla.ivalorl, pla.clapla, pla.npartot, '
         || ' pla.coddgs, pla.fbajare,NVL(rel.ctipban, fon.ctipban) ctipban, fon.CODDGS, pla.clistblanc'
         || ' FROM planpensiones pla, fonpensiones fon, per_personas pers, per_detper per, gestoras g, depositarias d, relfondep rel'
         || ' WHERE fon.ccodfon(+) = pla.ccodfon ' || ' AND fon.ccodges = g.ccodges(+) '
         || ' AND d.ccoddep(+) = fon.ccoddep ' || ' AND pers.sperson(+) = fon.sperson '
         || ' AND pers.sperson = per.sperson(+) AND rel.ccodfon(+)= fon.ccodfon and rel.ctrasp(+) = 1';

      IF coddgs IS NOT NULL THEN
         vquery := vquery || ' AND upper(pla.coddgs) like ''' || '%' || UPPER(coddgs) || '%'
                   || ''' ';
      END IF;

      IF nnompla IS NOT NULL THEN
         vquery := vquery || ' AND upper(pla.tnompla) like ''' || '%' || UPPER(nnompla) || '%'
                   || ''' ';
      END IF;

      IF fon_coddgs IS NOT NULL THEN
         vquery := vquery || ' AND fon.coddgs like ''' || '%' || UPPER(fon_coddgs) || '%'
                   || ''' ';
      END IF;

      IF pctipide IS NOT NULL THEN
         vquery := vquery || ' AND pers.ctipide = ' || pctipide || ' ';
      END IF;

      IF pnnumide IS NOT NULL THEN
         --Bug 371152-21271 Busqueda de NIF minuscula KJSC 26/08/2015
         IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(),
                                              'NIF_MINUSCULAS'),
                0) = 1 THEN
            vquery := vquery || ' AND UPPER(pers.nnumide) = UPPER(''' || pnnumide || ''')';
         ELSE
            vquery := vquery || ' AND pers.nnumide = ''' || pnnumide || ''' ';
         END IF;
      END IF;

      IF ccodpla IS NOT NULL THEN
         vquery := vquery || ' AND pla.ccodpla = ' || ccodpla || ' ';
      END IF;

      vquery := vquery || ' and rownum<=201 ';
      vquery := vquery || ' ORDER BY pla.ccodpla ';

      OPEN pfdatos FOR vquery;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         -- BUG -21546_108724- 08/02/2012 - JLTS - Cierre de posibles cursores abiertos
         IF pfdatos%ISOPEN THEN
            CLOSE pfdatos;
         END IF;

         p_tab_error(f_sysdate, f_user, 'PAC_PENSIONES.f_get_planpensiones', vtraza, SQLCODE,
                     SQLERRM);
         RETURN 1;
   END f_get_planpensiones;

   FUNCTION f_get_fonpensiones(
      pccodfon IN NUMBER,
      pccodges IN NUMBER,
      pccoddep IN NUMBER,
      pctipide IN NUMBER,
      pnnumide IN VARCHAR2,
      nnomfon IN VARCHAR2,
      pcagente IN NUMBER,
      pfdatos OUT sys_refcursor)
      RETURN NUMBER IS
      vtraza         NUMBER := 0;
      vquery         VARCHAR2(2000);
   BEGIN
      vquery :=
         ' SELECT fon.ccodfon,fon.coddgs, fon.faltare, fon.fbajare, '
         || ' (SELECT tbanco FROM bancos WHERE cbanco = NVL(TO_NUMBER(SUBSTR(fon.cbancar, 1, 2)), 1)) tbanco, '
         || ' fon.ccomerc,fon.ccodges, '
         --nomgestora
         || ' (SELECT per_detper.tapelli1 || '' '' || per_detper.tapelli2 || '' ''|| per_detper.tnombre '
         || ' FROM per_detper, gestoras WHERE ccodges = fon.ccodges '
         || ' AND per_detper.sperson = gestoras.sperson '
         || ' AND per_detper.cagente = ff_agente_cpervisio(' || pcagente || ') '
         || ' ) tnombre1, fon.clafon, '
         --persona
         || ' fon.sperson, per.tnombre, per.tapelli1, per.tapelli2, '
         --persona titular
         || ' fon.spertit, ti.tnombre nombre_titular, ti.tapelli1 apelli1_titular,ti.tapelli2 apelli2_titular, fon.cdivisa,'
         || ' ges.coddgs, ' || ' fon.CBANCAR CBANCAR, ' || ' fon.NTOMO NTOMO, '
         || ' fon.NFOLIO NFOLIO, ' || ' fon.NHOJA NHOJA '
         || ' FROM fonpensiones fon, per_detper per, per_personas pers, depositarias d ,per_detper ti, gestoras ges'
         || ' WHERE d.ccoddep(+) = fon.ccoddep AND per.sperson = fon.sperson '
         || ' AND ges.ccodges = fon.ccodges ' || ' AND pers.sperson = per.sperson '
         || ' AND ti.sperson(+) = fon.spertit';

      IF pccodfon IS NOT NULL THEN
         vquery := vquery || ' AND fon.ccodfon = ' || pccodfon || ' ';
      END IF;

      IF pccodges IS NOT NULL THEN
         vquery := vquery || ' AND fon.ccodges = ' || pccodges || ' ';
      END IF;

      IF pccoddep IS NOT NULL THEN
         vquery := vquery || ' AND fon.ccoddep = ' || pccoddep || ' ';
      END IF;

      IF pctipide IS NOT NULL THEN
         vquery := vquery || ' AND pers.ctipide = ' || pctipide || ' ';
      END IF;

      IF pnnumide IS NOT NULL THEN
         vquery := vquery || ' AND upper(pers.nnumide) = upper(''' || pnnumide || ''') ';
      END IF;

      IF nnomfon IS NOT NULL THEN
         vquery :=
            vquery
            || ' AND upper(per.TNOMBRE ||'' ''||per.TAPELLI1||'' ''||per.TAPELLI2) like ''%'
            || UPPER(nnomfon) || '%''';
      END IF;

      vquery := vquery || ' and rownum<=201 ';
      vquery := vquery || ' ORDER BY fon.ccodfon ';

      OPEN pfdatos FOR vquery;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         -- BUG -21546_108724- 08/02/2012 - JLTS - Cierre de posibles cursores abiertos
         IF pfdatos%ISOPEN THEN
            CLOSE pfdatos;
         END IF;

         p_tab_error(f_sysdate, f_user, 'PAC_PENSIONES.f_get_fonpensiones', vtraza, SQLCODE,
                     SQLERRM);
         RETURN 1;
   END f_get_fonpensiones;

   FUNCTION f_get_codgestoras(
      pccodges IN NUMBER,
      pctipide IN NUMBER,
      pnnumide IN VARCHAR2,
      nnomges IN VARCHAR2,
      pcagente IN NUMBER,
      pfdatos OUT sys_refcursor)
      RETURN NUMBER IS
      vtraza         NUMBER := 0;
      vquery         VARCHAR2(2000);
   BEGIN
      /*JGM: Poner esta selectFET!*/
      vquery :=
         ' SELECT distinct ges.ccodges, ' || 'ges.coddgs, ' || 'ges.sperson, '
         || ' per.tnombre ,per.tapelli1 ,per.tapelli2 , ges.falta, ges.fbaja, '
         -- saco tnombre1
         || ' ges.cbanco, ges.coficin, '
         || ' ges.cdc, ges.ncuenta, ges.spertit,ti.TNOMBRE nombre_titular,ti.TAPELLI1 apelli_titular,ti.TAPELLI2 apelli2_titular,'
         || ' pers.ctipide, pers.nnumide ,ges.timeclose'
         || ' FROM per_detper per, per_personas pers, gestoras ges ,per_detper ti'
         || ' WHERE per.sperson = ges.sperson ' || ' AND pers.sperson = per.sperson '
         || ' AND ti.sperson(+) = ges.spertit';   --|| ' AND per.cagente = ff_agente_cpervisio('||pcagente||') ';

      IF pccodges IS NOT NULL THEN
         vquery := vquery || ' AND ges.ccodges = ' || pccodges || ' ';
      END IF;

      IF pctipide IS NOT NULL THEN
         vquery := vquery || ' AND pers.ctipide = ' || pctipide || ' ';
      END IF;

      IF pnnumide IS NOT NULL THEN
         vquery := vquery || ' AND upper(pers.nnumide) = upper(''' || pnnumide || ''') ';
      END IF;

      IF nnomges IS NOT NULL THEN
         vquery :=
            vquery
            || ' AND upper(per.TNOMBRE ||'' ''||per.TAPELLI1||'' ''||per.TAPELLI2) like ''%'
            || UPPER(nnomges) || '%''';
      END IF;

      vquery := vquery || ' ORDER BY ges.ccodges ';

      OPEN pfdatos FOR vquery;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         -- BUG -21546_108724- 08/02/2012 - JLTS - Cierre de posibles cursores abiertos
         IF pfdatos%ISOPEN THEN
            CLOSE pfdatos;
         END IF;

         p_tab_error(f_sysdate, f_user, 'PAC_PENSIONES.f_get_codgestoras', vtraza, SQLCODE,
                     SQLERRM);
         RETURN 1;
   END f_get_codgestoras;

   FUNCTION f_get_pdepositarias(
      pccodfon IN NUMBER,
      pccodaseg IN NUMBER,
      pccoddep IN NUMBER,
      pctipide IN NUMBER,
      pnnumide IN VARCHAR2,
      nnomdep IN VARCHAR2,
      pcagente IN NUMBER,
      pfdatos OUT sys_refcursor)
      RETURN NUMBER IS
      vtraza         NUMBER := 0;
      vquery         VARCHAR2(2000);
   BEGIN
      vquery :=
         ' SELECT dep.ccoddep, dep.falta, dep.fbaja, dep.sperson, pers.nnumide, '
         || ' nvl(trim(per.tnombre || '' '' || per.tapelli1 || '' '' || per.tapelli2),
                 f_axis_literales(9901257,f_usu_idioma)) tnombrecompleto, dep.cbanco, pers.ctipide,
         per.tnombre, nvl(trim(per.tapelli1),f_axis_literales(9901257,f_usu_idioma)) tapelli1, per.tapelli2  ';

      IF pccodaseg IS NOT NULL THEN
         vquery := vquery || ', rel2.ctipban, rel2.cbancar, rel2.ctrasp ';
      ELSIF pccodfon IS NOT NULL THEN
         vquery := vquery || ', rel.ctipban, rel.cbancar, rel.ctrasp ';
      ELSE
         vquery := vquery || ', null, null, null ';
      END IF;

      vquery := vquery || ' FROM per_detper per, per_personas pers,';

      IF pccodaseg IS NOT NULL THEN
         vquery := vquery || 'relasegdep rel2,';
      END IF;

      IF pccodfon IS NOT NULL THEN
         vquery := vquery || 'relfondep rel,';
      END IF;

      vquery := vquery || ' depositarias dep ' || ' WHERE per.sperson(+) = dep.sperson '
                || ' AND pers.sperson(+) = per.sperson ';

      IF pccodfon IS NOT NULL THEN
         vquery := vquery || ' AND rel.CCODDEP(+) = dep.CCODDEP ';
      END IF;

      IF pccodaseg IS NOT NULL THEN
         vquery := vquery || ' AND rel2.CCODDEP(+) = dep.CCODDEP ';
      END IF;

      --|| ' AND per.cagente = ff_agente_cpervisio('||pcagente||') ';
      IF pccodfon IS NOT NULL THEN
         vquery := vquery || ' AND rel.ccodfon =  ' || pccodfon || ' ';
      END IF;

      IF pccodaseg IS NOT NULL THEN
         vquery := vquery || ' AND rel2.ccodaseg =  ' || pccodaseg || ' ';
      END IF;

      IF pccoddep IS NOT NULL THEN
         vquery := vquery || ' AND dep.ccoddep = ' || pccoddep || ' ';
      END IF;

      IF pctipide IS NOT NULL THEN
         vquery := vquery || ' AND pers.ctipide = ' || pctipide || ' ';
      END IF;

      IF pnnumide IS NOT NULL THEN
         vquery := vquery || ' AND upper(pers.nnumide) = upper(''' || pnnumide || ''') ';
      END IF;

      IF nnomdep IS NOT NULL THEN
         vquery :=
            vquery
            || ' AND upper(per.TNOMBRE ||'' ''||per.TAPELLI1||'' ''||per.TAPELLI2) like ''%'
            || UPPER(nnomdep) || '%''';
      END IF;

      vquery := vquery || ' ORDER BY dep.ccoddep ';

      OPEN pfdatos FOR vquery;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         -- BUG -21546_108724- 08/02/2012 - JLTS - Cierre de posibles cursores abiertos
         IF pfdatos%ISOPEN THEN
            CLOSE pfdatos;
         END IF;

         p_tab_error(f_sysdate, f_user, 'PAC_PENSIONES.f_get_pdepositarias', vtraza, SQLCODE,
                     SQLERRM);
         RETURN 1;
   END f_get_pdepositarias;

   FUNCTION f_get_promotores(
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pnpoliza IN NUMBER,
      pccodpla IN NUMBER,
      pctipide IN NUMBER,
      pnnumide IN VARCHAR2,
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pfdatos OUT sys_refcursor)
      RETURN NUMBER IS
      vtraza         NUMBER := 0;
      vquery         VARCHAR2(2000);
   BEGIN
      vquery :=
         ' SELECT   prom.ccodpla, pla.tnompla, pers.nnumide, '
         || ' per.tnombre || '' '' || per.tapelli1 || '' '' || per.tapelli2 tnombre, prom.nvalparsp, '
         || ' prom.npoliza, prom.sperson, prom.cbancar, prom.ctipban '
         || ' FROM promotores prom, planpensiones pla, per_detper per, per_personas pers, seguros seg '
         || ' WHERE prom.ccodpla = pla.ccodpla ' || ' AND seg.npoliza = prom.npoliza '
         || ' AND per.sperson = prom.sperson ' || ' AND pers.sperson = per.sperson ';   --|| ' AND per.cagente = ff_agente_cpervisio('||pcagente||') ';

      IF pcramo IS NOT NULL THEN
         vquery := vquery || ' AND seg.cramo = ' || pcramo || ' ';
      END IF;

      IF psproduc IS NOT NULL THEN
         vquery := vquery || ' AND seg.sproduc = ' || psproduc || ' ';
      END IF;

      IF pnpoliza IS NOT NULL THEN
         vquery := vquery || ' AND seg.npoliza = ' || pnpoliza || ' ';
      END IF;

      IF pccodpla IS NOT NULL THEN
         vquery := vquery || ' AND prom.ccodpla = ' || pccodpla || ' ';
      END IF;

      IF pctipide IS NOT NULL THEN
         vquery := vquery || ' AND pers.ctipide = ' || pctipide || ' ';
      END IF;

      IF pnnumide IS NOT NULL THEN
         vquery := vquery || ' AND upper(pers.nnumide) = upper(''' || pnnumide || ''') ';
      END IF;

      IF psperson IS NOT NULL THEN
         vquery := vquery || ' AND prom.sperson = ' || psperson || ' ';
      END IF;

      vquery := vquery || ' ORDER BY prom.ccodpla ';

      OPEN pfdatos FOR vquery;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         -- BUG -21546_108724- 08/02/2012 - JLTS - Cierre de posibles cursores abiertos
         IF pfdatos%ISOPEN THEN
            CLOSE pfdatos;
         END IF;

         p_tab_error(f_sysdate, f_user, 'PAC_PENSIONES.f_get_promotores', vtraza, SQLCODE,
                     SQLERRM);
         RETURN 1;
   END f_get_promotores;

   FUNCTION f_del_promotores(pccodpla IN NUMBER, psperson IN NUMBER)
      RETURN NUMBER IS
      vtraza         NUMBER := 0;
   BEGIN
      DELETE      promotores prom
            WHERE prom.ccodpla = pccodpla
              AND prom.sperson = psperson;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PENSIONES.f_del_promotores', vtraza, SQLCODE,
                     SQLERRM);
         RETURN 1;
   END f_del_promotores;

   FUNCTION f_del_planpensiones(pccodpla IN NUMBER)
      RETURN NUMBER IS
      vtraza         NUMBER := 0;
      vnumerr        NUMBER;
   BEGIN
      FOR i IN (SELECT prom.sperson
                  FROM promotores prom
                 WHERE prom.ccodpla = pccodpla) LOOP
         vnumerr := f_del_promotores(pccodpla, i.sperson);

         IF vnumerr <> 0 THEN
            RETURN vnumerr;
         END IF;
      END LOOP;

      DELETE      planpensiones PLAN
            WHERE PLAN.ccodpla = pccodpla;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PENSIONES.f_del_planpensiones', vtraza, SQLCODE,
                     SQLERRM);
         RETURN 1;
   END f_del_planpensiones;

   FUNCTION f_del_fonpensiones(pccodfon IN NUMBER)
      RETURN NUMBER IS
      vtraza         NUMBER := 0;
      vnumerr        NUMBER;
   BEGIN
      FOR i IN (SELECT PLAN.ccodpla
                  FROM planpensiones PLAN
                 WHERE PLAN.ccodfon = pccodfon) LOOP
         vnumerr := f_del_planpensiones(i.ccodpla);

         IF vnumerr <> 0 THEN
            RETURN vnumerr;
         END IF;
      END LOOP;

      -- JGM 11/06/2010 - bug 14788 -- borro también las relaciones que tenía con depositarias
      DELETE      relfondep relfon
            WHERE relfon.ccodfon = pccodfon;

      DELETE      fonpensiones PLAN
            WHERE PLAN.ccodfon = pccodfon;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PENSIONES.f_del_fonpensiones', vtraza, SQLCODE,
                     SQLERRM);
         RETURN 1;
   END f_del_fonpensiones;

   FUNCTION f_del_codgestoras(pccodges IN NUMBER)
      RETURN NUMBER IS
      vtraza         NUMBER := 0;
      vnumerr        NUMBER;
   BEGIN
      FOR i IN (SELECT fon.ccodfon
                  FROM fonpensiones fon
                 WHERE fon.ccodges = pccodges) LOOP
         vnumerr := f_del_fonpensiones(i.ccodfon);

         IF vnumerr <> 0 THEN
            RETURN vnumerr;
         END IF;
      END LOOP;

      DELETE      gestoras ges
            WHERE ges.ccodges = pccodges;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PENSIONES.f_del_codgestoras', vtraza, SQLCODE,
                     SQLERRM);
         RETURN 1;
   END f_del_codgestoras;

   FUNCTION f_del_pdepositarias(pccodaseg NUMBER, pccodfon NUMBER, pccoddep NUMBER)
      RETURN NUMBER IS
      vtraza         NUMBER := 0;
      vnumerr        NUMBER;
      v_conta1       NUMBER := 0;
      v_conta2       NUMBER := 0;
   BEGIN
      -- JGM 11/06/2010 - bug 14788 -- no se permite el borrado si existen fondos/aseguradoras asociadas
      --excepto si estamos borrando solo la relacion
      IF pccodaseg IS NOT NULL THEN   --caso borrado relacion
         DELETE      relasegdep
               WHERE ccoddep = pccoddep
                 AND ccodaseg = pccodaseg;
      END IF;

      -- JGM 11/06/2010 - bug 14788 -- si esta informado lo único que borro es la relación poniendo a 0
      IF pccodfon IS NOT NULL THEN   --caso borrado relacion
         DELETE      relfondep dep
               WHERE dep.ccoddep = pccoddep
                 AND dep.ccodfon = pccodfon;
      END IF;

      -- JGM 11/06/2010 - bug 14788 -- si no esta informado me cargo la depositaria siempre que no haya relaciones
      -- si las hay ... ERROR...
      IF pccodfon IS NULL
         AND pccodaseg IS NULL THEN
         SELECT COUNT(*)
           INTO v_conta1
           FROM relasegdep
          WHERE ccoddep = pccoddep;

         SELECT COUNT(*)
           INTO v_conta2
           FROM relfondep
          WHERE ccoddep = pccoddep;

         IF v_conta1 + v_conta2 = 0 THEN
            --puedo borrar
            DELETE      depositarias dep
                  WHERE dep.ccoddep = pccoddep;
         ELSE
            RETURN 1;
         END IF;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PENSIONES.f_del_pdepositarias', vtraza, SQLCODE,
                     SQLERRM);
         RETURN 1;
   END f_del_pdepositarias;

   FUNCTION f_set_pdepositarias(
      pccodaseg NUMBER,
      pccodfon NUMBER,
      pccoddep NUMBER,
      pfalta DATE,
      pfbaja DATE,
      psperson NUMBER,
      pcctipban NUMBER,
      pccbancar VARCHAR2,
      pcctrasp NUMBER,
      pcbanco NUMBER,
      modo VARCHAR2 DEFAULT 'alta')
      RETURN NUMBER IS
      vtraza         NUMBER := 0;
      vnumseq        depositarias.ccoddep%TYPE;
   BEGIN
      IF pccoddep IS NULL THEN
         SELECT coddepositarias_seq.NEXTVAL
           INTO vnumseq
           FROM DUAL;

         INSERT INTO depositarias
                     (ccoddep, falta, fbaja, sperson, cbanco)
              VALUES (vnumseq, pfalta, pfbaja, psperson, pcbanco);

         -- JGM 11/06/2010 - bug 14788 -- si esta informado creo tambien la relación
         IF pccodaseg IS NOT NULL THEN
            INSERT INTO relasegdep
                        (ccodaseg, ccoddep, ctipban, cbancar, ctrasp)
                 VALUES (pccodaseg, vnumseq, pcctipban, pccbancar, NVL(pcctrasp, 1));   -- Bug 17223 - RSC - 10/01/2010 - Actualización lista ENTIDADES SNCE
         END IF;

         -- JGM 11/06/2010 - bug 14788 -- si esta informado creo tambien la relación
         IF pccodfon IS NOT NULL THEN
            INSERT INTO relfondep
                        (ccodfon, ccoddep, ctipban, cbancar, ctrasp)
                 VALUES (pccodfon, vnumseq, pcctipban, pccbancar, NVL(pcctrasp, 1));   -- Bug 17223 - RSC - 10/01/2010 - Actualización lista ENTIDADES SNCE
         END IF;
      ELSE
         UPDATE depositarias dep
            SET dep.falta = NVL(pfalta, dep.falta),
                dep.fbaja = NVL(pfbaja, dep.fbaja),
                dep.sperson = NVL(psperson, dep.sperson),
                dep.cbanco = NVL(pcbanco, dep.cbanco)
          WHERE dep.ccoddep = pccoddep;

         -- JGM 11/06/2010 - bug 14788 -- si esta informado intento INSERT y si peta es que ya existia y updateo
         IF pccodaseg IS NOT NULL THEN
            IF LOWER(modo) = 'modif' THEN   -- De otro modo podriamos hacer un insert cuando solo queremos actualizar
               -- por ejemplo la cuenta bancaria.
               UPDATE relasegdep
                  SET ctipban = NVL(pcctipban, ctipban),
                      cbancar = NVL(pccbancar, cbancar),
                      ctrasp = NVL(pcctrasp, ctrasp)
                WHERE ccoddep = pccoddep
                  AND ccodaseg = pccodaseg;
            ELSE
               BEGIN
                  INSERT INTO relasegdep
                              (ccodaseg, ccoddep, ctipban, cbancar, ctrasp)
                       VALUES (pccodaseg, pccoddep, pcctipban, pccbancar, NVL(pcctrasp, 1));
               EXCEPTION
                  WHEN OTHERS THEN
                     UPDATE relasegdep
                        SET ctipban = NVL(pcctipban, ctipban),
                            cbancar = NVL(pccbancar, cbancar),
                            ctrasp = NVL(pcctrasp, ctrasp)
                      WHERE ccoddep = pccoddep
                        AND ccodaseg = pccodaseg;
               END;
            END IF;
         END IF;

         -- JGM 11/06/2010 - bug 14788 -- si esta informado intento INSERT y si peta es que ya existia y updateo
         IF pccodfon IS NOT NULL THEN
            IF LOWER(modo) = 'modif' THEN   -- De otro modo podriamos hacer un insert cuando solo queremos actualizar
               -- por ejemplo la cuenta bancaria.
               UPDATE relfondep
                  SET ctipban = NVL(pcctipban, ctipban),
                      cbancar = NVL(pccbancar, cbancar),
                      ctrasp = NVL(pcctrasp, ctrasp)
                WHERE ccoddep = pccoddep
                  AND ccodfon = pccodfon;
            ELSE
               BEGIN
                  INSERT INTO relfondep
                              (ccodfon, ccoddep, ctipban, cbancar, ctrasp)
                       VALUES (pccodfon, pccoddep, pcctipban, pccbancar, pcctrasp);
               EXCEPTION
                  WHEN OTHERS THEN
                     UPDATE relfondep
                        SET ctipban = NVL(pcctipban, ctipban),
                            cbancar = NVL(pccbancar, cbancar),
                            ctrasp = NVL(pcctrasp, ctrasp)
                      WHERE ccoddep = pccoddep
                        AND ccodfon = pccodfon;
               END;
            END IF;
         END IF;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PENSIONES.f_set_pdepositarias', vtraza, SQLCODE,
                     SQLERRM);
         RETURN 1;
   END f_set_pdepositarias;

   FUNCTION f_set_codgestoras(
      pccodges NUMBER,
      pfalta DATE,
      pfbaja DATE,
      pcbanco NUMBER,
      pcoficin NUMBER,
      pcdc NUMBER,
      pncuenta VARCHAR2,
      psperson NUMBER,
      pspertit NUMBER,
      pcoddgs VARCHAR2,
      ptimeclose VARCHAR2,
      pccodges_out OUT NUMBER)
      RETURN NUMBER IS
      vtraza         NUMBER := 0;
      vnumseq        gestoras.ccodges%TYPE;
   BEGIN
      IF pccodges IS NULL THEN
         SELECT codgestoras_seq.NEXTVAL
           INTO vnumseq
           FROM DUAL;

         pccodges_out := vnumseq;

         INSERT INTO gestoras
                     (ccodges, falta, fbaja, cbanco, coficin, cdc,
                      ncuenta, sperson, spertit, coddgs, timeclose)   --,ccoddep
              VALUES (vnumseq, NVL(pfalta, f_sysdate), pfbaja, pcbanco, pcoficin, pcdc,
                      pncuenta, psperson, pspertit, pcoddgs, ptimeclose);   --, pccoddep);
      ELSE
         pccodges_out := pccodges;

         UPDATE gestoras ges
            SET ges.falta = pfalta,
                ges.fbaja = pfbaja,
                ges.cbanco = pcbanco,
                ges.coficin = pcoficin,
                ges.cdc = pcdc,
                ges.ncuenta = pncuenta,
                ges.sperson = psperson,
                ges.spertit = pspertit,
                ges.timeclose = ptimeclose
          WHERE ges.ccodges = pccodges;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PENSIONES.f_set_codgestoras', vtraza, SQLCODE,
                     SQLERRM);
         RETURN 1;
   END f_set_codgestoras;

   FUNCTION f_set_fonpensiones(
      pccodfon NUMBER,
      pfaltare DATE,
      psperson NUMBER,
      pspertit NUMBER,
      pfbajare DATE,
      pccomerc VARCHAR2,
      pccodges NUMBER,
      pclafon NUMBER,
      pcdivisa NUMBER,
      pcoddgs VARCHAR2,
      pcbancar VARCHAR2,
      pctipban NUMBER,
      pccodfon_out OUT NUMBER)
      -- JGM 11/06/2010 - bug 14788 -- la depositaria se creará si hace falta cuando se entre en el mantenimiento de depositaria
      -- o si estuviera asociado al fondo por el set de depositarias
   RETURN NUMBER IS
      vtraza         NUMBER := 0;
      vnumseq        fonpensiones.ccodfon%TYPE;
   BEGIN
      IF psperson IS NULL
         OR pccodges IS NULL THEN
         --Faltan parametros obligatorios
         RETURN 103135;
      ELSE
         IF pccodfon IS NULL THEN
            SELECT codfonpensiones_seq.NEXTVAL
              INTO vnumseq
              FROM DUAL;

            INSERT INTO fonpensiones
                        (ccodfon, faltare, sperson, spertit, fbajare,
                         ntomo, nfolio, nhoja, cbancar, ccomerc, ccodges, clafon, ctipban,
                         cdivisa, coddgs)
                 VALUES (vnumseq, NVL(pfaltare, f_sysdate), psperson, pspertit, pfbajare,
                         NULL, NULL, NULL, pcbancar, pccomerc, pccodges, pclafon, pctipban,
                         pcdivisa, pcoddgs);

            pccodfon_out := vnumseq;
         ELSE
            UPDATE fonpensiones fon
               SET fon.sperson = psperson,
                   fon.ccodges = pccodges,
                   fon.cbancar = pcbancar,
                   fon.ctipban = pctipban,
                   fon.fbajare = pfbajare,
                   fon.coddgs = pcoddgs
             WHERE fon.ccodfon = pccodfon;

            pccodfon_out := pccodfon;
         END IF;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PENSIONES.f_set_fonpensiones', vtraza, SQLCODE,
                     SQLERRM);
         RETURN 1;
   END f_set_fonpensiones;

   FUNCTION f_set_planpensiones(
      pccodpla NUMBER,
      ptnompla VARCHAR2,
      pfaltare DATE,
      pfadmisi DATE,
      pcmodali NUMBER,
      pcsistem NUMBER,
      pccodfon NUMBER,
      pccomerc VARCHAR2,
      picomdep NUMBER,
      picomges NUMBER,
      pcmespag NUMBER,
      pctipren NUMBER,
      pcperiod NUMBER,
      pivalorl NUMBER,
      pclapla NUMBER,
      pnpartot NUMBER,
      pcoddgs VARCHAR2,
      pfbajare DATE,
      pclistblanc NUMBER,
      pccodpla_out OUT NUMBER)
      RETURN NUMBER IS
      vtraza         NUMBER := 0;
      vnumseq        planpensiones.ccodpla%TYPE;
   BEGIN
      IF pccodpla IS NULL THEN
         SELECT codplanpensiones_seq.NEXTVAL
           INTO vnumseq
           FROM DUAL;

         pccodpla_out := vnumseq;

         INSERT INTO planpensiones
                     (ccodpla, tnompla, faltare, fadmisi,
                      cmodali, csistem, ccodfon, ccomerc, icomdep,
                      icomges, cmespag, ctipren, cperiod, ivalorl, clapla, npartot,
                      coddgs, fbajare, clistblanc)
              VALUES (vnumseq, ptnompla, NVL(pfaltare, f_sysdate), NVL(pfadmisi, f_sysdate),
                      NVL(pcmodali, 1), NVL(pcsistem, 1), pccodfon, pccomerc, picomdep,
                      picomges, pcmespag, pctipren, pcperiod, pivalorl, pclapla, pnpartot,
                      pcoddgs, pfbajare, pclistblanc);
      ELSE
         pccodpla_out := pccodpla;

         UPDATE planpensiones pla
            SET pla.tnompla = ptnompla,
                pla.coddgs = pcoddgs,
                pla.faltare = pfaltare,
                pla.fadmisi = pfadmisi,
                pla.cmodali = pcmodali,
                pla.csistem = pcsistem,
                pla.ccodfon = pccodfon
          WHERE pla.ccodpla = pccodpla;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PENSIONES.f_set_planpensiones', vtraza, SQLCODE,
                     SQLERRM);
         RETURN 806313;
   END f_set_planpensiones;

   /**************************************************************
        Funcion para insertar o actualizar los promotores
        param in pccodpla : codigo del plan
        param in psperson : código de la persona
        param in pnpoliza : código de la poliza
        param in pcbancar : código de cuenta bancaria
        param in pnvalparsp : Importe valor participación Servicios Pasados
        param in pctipban : tipo de cuenta

       bug 12362 - 24/12/2009 - AMC
   **************************************************************/
   FUNCTION f_set_promotores(
      pccodpla IN NUMBER,
      psperson IN NUMBER,
      pnpoliza IN NUMBER,
      pcbancar IN VARCHAR2,
      pnvalparsp IN NUMBER,
      pctipban IN NUMBER)
      RETURN NUMBER IS
      vtraza         NUMBER := 0;
   BEGIN
      BEGIN
         INSERT INTO promotores
                     (ccodpla, sperson, npoliza, cbancar, nvalparsp, ctipban)
              VALUES (pccodpla, psperson, pnpoliza, pcbancar, pnvalparsp, pctipban);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE promotores
               SET npoliza = pnpoliza,
                   cbancar = pcbancar,
                   nvalparsp = pnvalparsp,
                   ctipban = pctipban
             WHERE ccodpla = pccodpla
               AND sperson = psperson;
      END;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PENSIONES.f_set_promotores', vtraza, SQLCODE,
                     SQLERRM);
         RETURN 806313;
   END f_set_promotores;

   /*************************************************************************
    Función F_GET_CONSULTA_BENEFICIARIOS_FP
    Devuelve un VARCHAR2 con la select a ejecutar en el MAP

    Parametros
     1.   pformato. En CSV o en PDF
     2.   pscaumot. Tipo contingencia
     3.   panyo. Año
     4.   pcrelase. Relacion con el asegurado
          return             VARCHAR2
    *************************************************************************/
   FUNCTION f_get_consulta_benef_fp(
      pformato IN VARCHAR2,
      pscaumot IN NUMBER,
      panyo IN NUMBER,
      pcrelase IN NUMBER)
      RETURN VARCHAR2 IS
      numerr         NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(4000)
         := 'pformato=' || pformato || ' pscaumot=' || pscaumot || ' panyo=' || panyo
            || ' pcrelase=' || pcrelase;
      vobject        VARCHAR2(200) := 'PAC_PENSIONES.F_GET_CONSULTA_BENEFICIARIOS_FP';
      vsquery        VARCHAR2(20000);
   BEGIN
      IF pscaumot IS NULL
         OR panyo IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pformato = 'PDF' THEN
         vpasexec := 2;
         -- Bug 18636 - APD - 25/05/2011 - union entre sin_tramita_destinatario y pagosrenta tambien
         -- por nsinies, ntramit y ctipdes
         vsquery :=
            ' SELECT f_nombre (NVL (fonp.spersonges, NVL (part.spersonges, NVL (rend.spersonges, vital.spersonges))), 1) NOMGEST, '
            || panyo || ' ANYO,'
            || ' fonp.coddgs CFONS, fonp.nomfon TFONS, part.num PARTICIPE, ''F'' TIPPAG, NVL(rend.num, 0) BENEF,'
            || ' NVL(rend.imp, 0) IMPREN, NVL(vital.num, 0) VITA, NVL(vital.imp, 0) IMPVITA, 0 REMI'
            || ' FROM ( SELECT ges.sperson spersonges, fp.coddgs, dper.tapelli1 nomfon'
            || ' FROM gestoras ges, fonpensiones fp, per_personas per, per_detper dper, planpensiones pp,'
            || ' proplapen pr, productos p, seguros s WHERE per.sperson = fp.sperson'
            || ' AND ges.ccodges = fp.ccodges AND dper.cagente = ff_agente_cpervisio(s.cagente) AND dper.sperson = per.sperson'
            || ' AND p.sproduc = pr.sproduc AND pr.ccodpla = pp.ccodpla'
            || ' AND pp.ccodfon = fp.ccodfon AND s.sproduc = p.sproduc'
            || ' AND fp.ccodges = 1 AND p.cactivo = 1'
            || ' GROUP BY ges.sperson, fp.coddgs, dper.tapelli1) fonp, ('
            || ' SELECT ges.sperson spersonges, fp2.coddgs, COUNT(*) num'
            || ' FROM gestoras ges, fonpensiones fp2, planpensiones pp2, proplapen pr2, productos p2, seguros s2'
            || ' WHERE s2.sproduc = pr2.sproduc AND ges.ccodges = fp2.ccodges'
            || ' AND p2.sproduc = pr2.sproduc AND pr2.ccodpla = pp2.ccodpla'
            || ' AND pp2.ccodfon = fp2.ccodfon AND fp2.ccodges = 1 AND p2.cactivo = 1'
            || ' AND(p2.csubpro <> 3 OR(p2.csubpro = 3 AND s2.ncertif > 0))'
            || ' AND NOT EXISTS( SELECT 1'
            || ' FROM sin_siniestro si, sin_movsiniestro m WHERE m.nsinies = si.nsinies'
            || ' AND si.fsinies <= TO_DATE(''3112' || panyo || ''',''ddmmyyyy'')'
            || ' AND m.nmovsin = (SELECT MAX(ms.nmovsin) FROM sin_movsiniestro ms'
            || ' WHERE ms.nsinies = si.nsinies) AND m.cestsin NOT IN(2, 3)'
            || ' AND si.sseguro = s2.sseguro)'
            || ' AND 0 = F_VIGENTE(S2.sseguro, NULL, TO_DATE(''3112' || panyo
            || ''',''ddmmyyyy'')) GROUP BY ges.sperson, fp2.coddgs) part, ('
            || ' SELECT ges.sperson spersonges, fp2.coddgs, sum(decode(std.ctipcap,0,0,1)) num, SUM(pr.isinret) imp'
            || ' FROM gestoras ges, fonpensiones fp2, planpensiones pp2, proplapen pr2, productos p2,'
            || ' seguros s2, sin_siniestro si, sin_movsiniestro m, sin_tramitacion st,'
            || ' sin_tramita_destinatario std, pagosrenta pr'
            || ' WHERE s2.sproduc = pr2.sproduc AND ges.ccodges = fp2.ccodges'
            || ' AND p2.sproduc = pr2.sproduc AND pr2.ccodpla = pp2.ccodpla'
            || ' AND pp2.ccodfon = fp2.ccodfon  AND si.sseguro=s2.sseguro'
            || ' AND m.nsinies=si.nsinies AND st.nsinies = si.nsinies'
            || ' AND std.nsinies=st.nsinies AND std.ntramit=st.ntramit'
            || ' and pr.sperson = std.sperson and pr.nsinies = std.nsinies and pr.ntramit = std.ntramit and pr.ctipdes = std.ctipdes'
            || ' AND fp2.ccodges = 1 AND p2.cactivo = 1'
            || ' AND (p2.csubpro <> 3 OR (p2.csubpro = 3 AND s2.ncertif > 0))'
            || ' AND pr.sseguro = s2.sseguro AND pr.ffecpag between TO_DATE(''0101' || panyo
            || ''',''ddmmyyyy'') AND TO_DATE(''3112' || panyo || ''',''ddmmyyyy'')'
            || ' AND m.nmovsin = (SELECT MAX(ms.nmovsin) FROM sin_movsiniestro ms'
            || ' WHERE ms.nsinies = si.nsinies) AND si.sseguro = s2.sseguro'
            || ' AND (si.ccausin,si.cmotsin) IN (SELECT cm.ccausin, cm.cmotsin'
            || ' FROM sin_causa_motivo cm WHERE cm.scaumot = ' || pscaumot
            || ') AND std.crelase = ' || NVL(TO_CHAR(pcrelase), 'std.crelase')
            || ' group by ges.sperson, fp2.coddgs ) rend, ('
            || ' SELECT ges.sperson spersonges, fp2.coddgs, COUNT(*) num, SUM(stp.isinret) imp'
            || ' FROM gestoras ges, fonpensiones fp2, planpensiones pp2, proplapen pr2, productos p2,'
            || ' seguros s2, sin_siniestro si, sin_movsiniestro m, sin_tramitacion st,'
            || ' sin_tramita_destinatario std, sin_tramita_pago stp, sin_tramita_movpago stm'
            || ' WHERE s2.sproduc = pr2.sproduc AND ges.ccodges = fp2.ccodges'
            || ' AND p2.sproduc = pr2.sproduc AND pr2.ccodpla = pp2.ccodpla'
            || ' AND pp2.ccodfon = fp2.ccodfon AND si.sseguro = s2.sseguro'
            || ' AND m.nsinies = si.nsinies AND st.nsinies = si.nsinies'
            || ' AND std.nsinies = st.nsinies AND std.ntramit = st.ntramit'
            || ' AND fp2.ccodges = 1 AND p2.cactivo = 1 and stp.nsinies = st.nsinies'
            || ' and stp.ntramit = st.ntramit and stm.sidepag = stp.sidepag'
            || ' and stm.cestpag = 2 and stm.fefepag between TO_DATE(''0101' || panyo
            || ''',''ddmmyyyy'') and TO_DATE(''3112' || panyo || ''',''ddmmyyyy'')'
            || ' AND(p2.csubpro <> 3 OR (p2.csubpro = 3 AND s2.ncertif > 0))'
            || ' AND si.fsinies <= TO_DATE(''3112' || panyo || ''',''ddmmyyyy'')'
            || ' AND m.nmovsin = (SELECT MAX(ms.nmovsin) FROM sin_movsiniestro ms'
            || ' WHERE ms.nsinies = si.nsinies) AND m.cestsin NOT IN (2, 3)'
            || ' AND si.sseguro = s2.sseguro AND (si.ccausin,si.cmotsin) IN '
            || ' (select cm.ccausin, cm.cmotsin FROM sin_causa_motivo cm'
            || ' WHERE cm.scaumot = ' || pscaumot || ' ) AND std.crelase = '
            || NVL(TO_CHAR(pcrelase), 'std.crelase') || ' group by ges.sperson, fp2.coddgs'
            || ' ) vital WHERE part.coddgs(+) = fonp.coddgs'
            || ' AND rend.coddgs(+) = fonp.coddgs AND vital.coddgs(+) = fonp.coddgs '
            || ' ORDER BY fonp.coddgs';
      ELSIF pformato = 'CSV' THEN
         vpasexec := 3;
         vsquery :=
            ' SELECT fonp.coddgs CFONS, fonp.nomfon TFONS, part.num PARTICIPE, ''F'' TIPPAG, NVL(rend.num, 0) BENEF,'
            || ' NVL(rend.imp, 0) IMPREN, NVL(vital.num, 0) VITA, NVL(vital.imp, 0) IMPVITA, 0 REMI'
            || ' FROM ( SELECT fp.coddgs, dper.tapelli1 nomfon'
            || ' FROM fonpensiones fp, per_personas per, per_detper dper, planpensiones pp,'
            || ' proplapen pr, productos p, seguros s WHERE per.sperson = fp.sperson'
            || ' AND dper.cagente = ff_agente_cpervisio(s.cagente) AND dper.sperson = per.sperson AND p.sproduc = pr.sproduc'
            || ' AND pr.ccodpla = pp.ccodpla AND pp.ccodfon = fp.ccodfon'
            || ' AND s.sproduc = p.sproduc AND fp.ccodges = 1 AND p.cactivo = 1'
            || ' GROUP BY fp.coddgs, dper.tapelli1) fonp, ('
            || ' SELECT fp2.coddgs, COUNT(*) num'
            || ' FROM fonpensiones fp2, planpensiones pp2, proplapen pr2, productos p2, seguros s2'
            || ' WHERE s2.sproduc = pr2.sproduc AND p2.sproduc = pr2.sproduc'
            || ' AND pr2.ccodpla = pp2.ccodpla AND pp2.ccodfon = fp2.ccodfon'
            || ' AND fp2.ccodges = 1 AND p2.cactivo = 1'
            || ' AND(p2.csubpro <> 3 OR(p2.csubpro = 3 AND s2.ncertif > 0))'
            || ' AND NOT EXISTS( SELECT 1'
            || ' FROM sin_siniestro si, sin_movsiniestro m WHERE m.nsinies = si.nsinies'
            || ' AND si.fsinies <= TO_DATE(''3112' || panyo || ''',''ddmmyyyy'')'
            || ' AND m.nmovsin = (SELECT MAX(ms.nmovsin) FROM sin_movsiniestro ms'
            || ' WHERE ms.nsinies = si.nsinies) AND m.cestsin NOT IN(2, 3)'
            || ' AND si.sseguro = s2.sseguro)'
            || ' AND 0 = F_VIGENTE(S2.sseguro, NULL, TO_DATE(''3112' || panyo
            || ''',''ddmmyyyy'')) GROUP BY fp2.coddgs) part, ('
            || ' SELECT fp2.coddgs, sum(decode(std.ctipcap,0,0,1)) num, SUM(pr.isinret) imp'
            || ' FROM fonpensiones fp2, planpensiones pp2, proplapen pr2, productos p2,'
            || ' seguros s2, sin_siniestro si, sin_movsiniestro m, sin_tramitacion st,'
            || ' sin_tramita_destinatario std, pagosrenta pr'
            || ' WHERE s2.sproduc = pr2.sproduc AND p2.sproduc = pr2.sproduc'
            || ' AND pr2.ccodpla = pp2.ccodpla AND pp2.ccodfon = fp2.ccodfon'
            || ' AND si.sseguro=s2.sseguro AND m.nsinies=si.nsinies'
            || ' AND st.nsinies = si.nsinies AND std.nsinies=st.nsinies'
            || ' AND std.ntramit=st.ntramit and pr.sperson = std.sperson'
            || ' and pr.nsinies = std.nsinies and pr.ntramit = std.ntramit and pr.ctipdes = std.ctipdes'
            || ' AND fp2.ccodges = 1 AND p2.cactivo = 1'
            || ' AND (p2.csubpro <> 3 OR (p2.csubpro = 3 AND s2.ncertif > 0))'
            || ' AND pr.sseguro = s2.sseguro AND pr.ffecpag between TO_DATE(''0101' || panyo
            || ''',''ddmmyyyy'') AND TO_DATE(''3112' || panyo || ''',''ddmmyyyy'')'
            || ' AND m.nmovsin = (SELECT MAX(ms.nmovsin) FROM sin_movsiniestro ms'
            || ' WHERE ms.nsinies = si.nsinies) AND si.sseguro = s2.sseguro'
            || ' AND (si.ccausin,si.cmotsin) IN (SELECT cm.ccausin, cm.cmotsin'
            || ' FROM sin_causa_motivo cm WHERE cm.scaumot = ' || pscaumot
            || ') AND std.crelase = ' || NVL(TO_CHAR(pcrelase), 'std.crelase')
            || ' group by fp2.coddgs ) rend, ('
            || ' SELECT fp2.coddgs, COUNT(*) num, SUM(stp.isinret) imp'
            || ' FROM fonpensiones fp2, planpensiones pp2, proplapen pr2, productos p2,'
            || ' seguros s2, sin_siniestro si, sin_movsiniestro m, sin_tramitacion st,'
            || ' sin_tramita_destinatario std, sin_tramita_pago stp, sin_tramita_movpago stm'
            || ' WHERE s2.sproduc = pr2.sproduc AND p2.sproduc = pr2.sproduc'
            || ' AND pr2.ccodpla = pp2.ccodpla AND pp2.ccodfon = fp2.ccodfon'
            || ' AND si.sseguro = s2.sseguro AND m.nsinies = si.nsinies'
            || ' AND st.nsinies = si.nsinies AND std.nsinies = st.nsinies'
            || ' AND std.ntramit = st.ntramit AND fp2.ccodges = 1 AND p2.cactivo = 1'
            || ' and stp.nsinies = st.nsinies and stp.ntramit = st.ntramit'
            || ' and stm.sidepag = stp.sidepag and stm.cestpag = 2'
            || ' and stm.fefepag between TO_DATE(''0101' || panyo
            || ''',''ddmmyyyy'') and TO_DATE(''3112' || panyo || ''',''ddmmyyyy'')'
            || ' AND(p2.csubpro <> 3 OR (p2.csubpro = 3 AND s2.ncertif > 0))'
            || ' AND si.fsinies <= TO_DATE(''3112' || panyo || ''',''ddmmyyyy'')'
            || ' AND m.nmovsin = (SELECT MAX(ms.nmovsin) FROM sin_movsiniestro ms'
            || ' WHERE ms.nsinies = si.nsinies) AND m.cestsin NOT IN (2, 3)'
            || ' AND si.sseguro = s2.sseguro AND (si.ccausin,si.cmotsin) IN '
            || ' (select cm.ccausin, cm.cmotsin FROM sin_causa_motivo cm'
            || ' WHERE cm.scaumot = ' || pscaumot || ' ) AND std.crelase = '
            || NVL(TO_CHAR(pcrelase), 'std.crelase') || ' group by fp2.coddgs ) vital'
            || ' WHERE part.coddgs(+) = fonp.coddgs AND rend.coddgs(+) = fonp.coddgs'
            || ' AND vital.coddgs(+) = fonp.coddgs ORDER BY fonp.coddgs';
      -- Fin Bug 18636 - APD - 25/05/2011
      END IF;

      vpasexec := 5;
      RETURN vsquery;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec,
                     'PARAMETROS OBLIGATORIOS NO INFORMADOS ' || vparam, SQLERRM);
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, SQLERRM,
                     SUBSTR('vsquery ' || vsquery, 1, 2500));
         RETURN NULL;
   END f_get_consulta_benef_fp;

   FUNCTION f_get_fonpension(pccodfon IN NUMBER, fonpension IN OUT ob_iax_fonpensiones)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_PENSIONES.f_get_planpension';
      vparam         VARCHAR2(2000) := 'parámetros - ccodfon: ' || pccodfon;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER;
      vcont          NUMBER := 0;
   BEGIN
      fonpension := ob_iax_fonpensiones();

      SELECT fp.ccodfon, fp.faltare, fp.fbajare, fp.ccomerc,
             fp.ccodges, fp.clafon, fp.coddgs, fp.cdivisa,
             fp.cbancar, fp.ctipban, g.coddgs, gper.tapelli,
             per.tnombre || ' ' || per.tapelli1 || ' ' || per.tapelli2, fp.sperson
        INTO fonpension.ccodfon, fonpension.faltare, fonpension.fbajare, fonpension.ccomerc,
             fonpension.ccodges, fonpension.clafon, fonpension.coddgs, fonpension.cdivisa,
             fonpension.cbancar, fonpension.ctipban, fonpension.cgesdgs, fonpension.tcodges,
             fonpension.tfondo, fonpension.sperson
        FROM fonpensiones fp, gestoras g, personas gper, per_personas pers, per_detper per
       WHERE fp.ccodfon = pccodfon
         AND fp.ccodges = g.ccodges
         AND gper.sperson = g.sperson
         AND pers.sperson(+) = fp.sperson
         AND pers.sperson = per.sperson(+);

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, SQLERRM, vparam);
         RETURN 1000052;
   END;

   FUNCTION f_get_timeclose(pccodfon IN NUMBER, pccodges IN NUMBER)
      RETURN VARCHAR2 IS
      vtimeclose     VARCHAR2(10);
      vobjectname    VARCHAR2(500) := 'PAC_PENSIONES.f_get_timeclose';
      vparam         VARCHAR2(2000)
                           := 'parámetros - ccodfon: ' || pccodfon || 'pccodges: ' || pccodges;
      vpasexec       NUMBER(5) := 1;
   BEGIN
      BEGIN
         IF pccodfon IS NOT NULL THEN
            SELECT timeclose
              INTO vtimeclose
              FROM gestoras
             WHERE ccodges = (SELECT cmanager
                                FROM fondos
                               WHERE ccodfon = pccodfon);
         ELSIF pccodges IS NOT NULL THEN
            SELECT timeclose
              INTO vtimeclose
              FROM gestoras
             WHERE ccodges = pccodges;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            vtimeclose := NULL;
      END;

      IF NOT REGEXP_LIKE(vtimeclose, '(^[01]?[0-9]|^[2]?[0-3]):[0-5][0-9]') THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec,
                     f_axis_literales(1000243, pac_md_common.f_get_cxtidioma) || vparam,
                     SQLERRM);
         vtimeclose := NULL;
      END IF;

      RETURN vtimeclose;
   EXCEPTION
      WHEN OTHERS THEN
         vpasexec := 99;
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, SQLERRM);
         RETURN NULL;
   END f_get_timeclose;
END pac_pensiones;

/

  GRANT EXECUTE ON "AXIS"."PAC_PENSIONES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PENSIONES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PENSIONES" TO "PROGRAMADORESCSI";
