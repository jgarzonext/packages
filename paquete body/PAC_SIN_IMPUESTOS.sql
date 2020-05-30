--------------------------------------------------------
--  DDL for Package Body PAC_SIN_IMPUESTOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_SIN_IMPUESTOS" AS
/******************************************************************************
   NOMBRE:    pac_sin_impuestos
   PROPÓSITO: Funciones para calculo de impuestos

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
    1.0       13/08/2013   NSS             Creacion
******************************************************************************/
   FUNCTION f_get_impuestos(
      pcconcep IN NUMBER,
      pccodimp IN NUMBER,
      pcempres IN NUMBER,
      pcidioma IN NUMBER,
      ptselect OUT VARCHAR2)
      RETURN NUMBER IS
      vtraza         NUMBER := 0;
      vobject        VARCHAR2(200) := 'pac_sin_impuestos.f_get_impuestos';
      vparam         VARCHAR2(200)
         := 'pcconcep: ' || pcconcep || ' pccodimp: ' || pccodimp || ' pcempres: ' || pcempres
            || ' pcidioma: ' || pcidioma;
   BEGIN
      vtraza := 1;
      ptselect :=
         'SELECT i.ccodimp, v_impuesto.tdesimp AS tcodimp, i.ctipper, v_persona.tatribu AS ttipper, i.cregfiscal,
                 v_regfiscal.tatribu AS tregfiscal, i.nordimp , i.ctipcal, i.cbasemin, i.nporcen, v_cbasecal.tatribu AS tbasecal,
				 v_conceppa.cvalemp AS tconcep
            FROM sin_imp_calculo i,
                 (SELECT d.ccodimp, d.tdesimp
                    FROM sin_imp_desimpuesto d
                   WHERE cidioma = '
         || pcidioma
         || ') v_impuesto,
                 (SELECT tatribu, catribu
                    FROM detvalores
                   WHERE cidioma = '
         || pcidioma
         || '
                     AND cvalor = 85) v_persona,
                 (SELECT tatribu, catribu
                    FROM detvalores
                   WHERE cidioma = '
         || pcidioma
         || '
                     AND cvalor = 1045) v_regfiscal,
                 (SELECT tatribu, catribu
                    FROM detvalores
                   WHERE cidioma = '
         || pcidioma
         || '
                     AND cvalor = 1097) v_cbasecal,
                 (SELECT cvalaxis, cvalemp
                    FROM int_codigos_emp
                   WHERE ccodigo = ''CONCEPTO_PAGO'') v_conceppa
           WHERE v_impuesto.ccodimp = i.ccodimp
             AND v_persona.catribu = i.ctipper
             AND v_regfiscal.catribu (+) = i.cregfiscal
             AND v_cbasecal.catribu(+) = i.cbasecal
             AND v_conceppa.cvalaxis(+) = i.cconcep';

      IF pcconcep IS NOT NULL THEN
         ptselect := ptselect || ' AND i.cconcep = ' || pcconcep;
      END IF;

      IF pccodimp IS NOT NULL THEN
         ptselect := ptselect || ' AND i.ccodimp = ' || pccodimp;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vtraza, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_get_impuestos;

   FUNCTION f_set_impuesto(
      pcconcep IN NUMBER,
      pccodimp IN NUMBER,
      pfdesde IN DATE,
      pctipper IN NUMBER,
      pcregfiscal IN NUMBER,
      pctipcal IN NUMBER,
      pifijo IN NUMBER,
      pcbasecal IN NUMBER,
      pcbasemin IN NUMBER,
      pcbasemax IN NUMBER,
      pnporcent IN NUMBER,
      pimin IN NUMBER,
      pimax IN NUMBER,
      pcempres IN NUMBER,
      pnordimp IN NUMBER,
      pcsubtab IN NUMBER)
      RETURN NUMBER IS
      /*************************************************************************
        Graba una linea de detalle en SIN_IMP_IMPUESTOS y SIN_IMP_CALCULO
        return              : NUMBER 0(ok) / 1(error)
      *************************************************************************/
      vobjectname    VARCHAR2(500) := 'pac_sin_impuestos.f_set_impuesto';
      vparam         VARCHAR2(500)
         := 'parámetros - pcconcep: ' || pcconcep || ' - pccodimp: ' || pccodimp
            || ' - pfdesde: ' || pfdesde || ' - pctipper: ' || pctipper || ' - pcregfiscal: '
            || pcregfiscal || ' - pctipcal: ' || pctipcal || ' - pifijo: ' || pifijo
            || ' - pcbasecal: ' || pcbasecal || ' - pcbasemin: ' || pcbasemin
            || ' - pcbasemax: ' || pcbasemax || ' - pnporcent: ' || pnporcent || ' - pimin: '
            || pimin || ' - pimax: ' || pimax || ' - pnordimp: ' || pnordimp
            || ' - pcsubtab: ' || pcsubtab;
      vpasexec       NUMBER := 0;
      vnordimp       NUMBER := 0;
      vccodimp       NUMBER := 0;
   BEGIN
      IF pnordimp IS NOT NULL THEN
         UPDATE sin_imp_calculo
            SET ctipper = pctipper,
                cregfiscal = pcregfiscal,
                fvigor = pfdesde,
                cbasecal = pcbasecal,
                cbasemin = pcbasemin,
                cbasemax = pcbasemax,
                nporcen = pnporcent,
                imin = pimin,
                imax = pimax,
                ifijo = pifijo,
                csubtab = pcsubtab,
                ctipcal = pctipcal
          WHERE ccodimp = pccodimp
            AND nordimp = pnordimp
            AND cconcep = pcconcep;
      ELSE
         SELECT MAX(nordimp + 1)
           INTO vnordimp
           FROM sin_imp_calculo
          WHERE cconcep = pcconcep
            AND ccodimp = pccodimp;

         IF vnordimp IS NULL THEN
            vnordimp := 1;
         END IF;

         INSERT INTO sin_imp_calculo
                     (cconcep, ccodimp, nordimp, ctipper, cregfiscal, fvigor, cbasecal,
                      cbasemin, cbasemax, nporcen, imin, imax, ifijo, csubtab, ctipcal)
              VALUES (pcconcep, pccodimp, vnordimp, pctipper, pcregfiscal, pfdesde, pcbasecal,
                      pcbasemin, pcbasemax, pnporcent, pimin, pimax, pifijo, pcsubtab, pctipcal);
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_sin_impuestos.f_set_impuesto', vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_set_impuesto;

   FUNCTION f_del_impuesto(
      pcconcep IN NUMBER,
      pccodimp IN NUMBER,
      pnordimp IN NUMBER,
      pcempres IN NUMBER)
      RETURN NUMBER IS
      /*************************************************************************
        Elimina una linea de detalle en SIN_IMP_CALCULO
        return              : NUMBER 0(ok) / 1(error)
      *************************************************************************/
      vobjectname    VARCHAR2(500) := 'pac_sin_impuestos.f_del_impuesto';
      vparam         VARCHAR2(500)
         := 'parámetros - pcconcep=' || pcconcep || ' pccodimp: ' || pccodimp || ' pnordimp: '
            || pnordimp || ' pcempres: ' || pcempres;
      vpasexec       NUMBER := 0;
   BEGIN
      DELETE FROM sin_imp_calculo
            WHERE ccodimp = pccodimp
              AND cconcep = pcconcep
              AND nordimp = pnordimp;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_sin_impuestos.f_del_impuesto', vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_del_impuesto;

   FUNCTION f_get_impuesto(
      pcconcep IN NUMBER,
      pccodimp IN NUMBER,
      pnordimp IN NUMBER,
      pcempres IN NUMBER,
      pcidioma IN NUMBER,
      ptselect OUT VARCHAR2)
      RETURN NUMBER IS
      vtraza         NUMBER := 0;
      vobject        VARCHAR2(200) := 'pac_sin_impuestos.f_get_impuesto';
      vparam         VARCHAR2(200)
         := 'parámetros - pcconcep=' || pcconcep || ' pccodimp: ' || pccodimp || ' pnordimp: '
            || pnordimp || ' pcempres: ' || pcempres;
   BEGIN
      vtraza := 1;
      ptselect :=
         'SELECT i.ccodimp, i.fvigor, i.ctipper, i.cregfiscal, i.cbasecal, i.cbasemin, i.cbasemax, i.nporcen, i.imin, i.imax, i.ifijo,
                 v.tatribu as tconcep, i.csubtab, sd.tsubtabla, i.ctipcal
            FROM sin_imp_calculo i,
                 (SELECT catribu, tatribu
                    FROM detvalores
                   WHERE cvalor = 1138
                     AND cidioma = '
         || pcidioma
         || ') v,
                 (SELECT csubtabla, tsubtabla from sgt_subtabs_des sd where cidioma = '
         || pcidioma || ' and cempres = ' || pcempres || ') sd
           WHERE i.ccodimp = ' || pccodimp || ' AND i.nordimp = ' || pnordimp
         || ' AND i.cconcep = ' || pcconcep || ' AND v.catribu = ' || pcconcep
         || ' AND sd.csubtabla (+) = i.csubtab';
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vtraza, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_get_impuesto;

   FUNCTION f_get_lstimpuestos(pcempres IN NUMBER, pcidioma IN NUMBER, ptselect OUT VARCHAR2)
      RETURN NUMBER IS
      vtraza         NUMBER := 0;
      vobject        VARCHAR2(200) := 'pac_sin_impuestos.f_get_lstimpuestos';
      vparam         VARCHAR2(200)
         := 'parámetros - pcempres=' || pcempres || ' pcidioma: ' || pcidioma || ' ptselect: '
            || ptselect;
   BEGIN
      vtraza := 1;
      ptselect :=
         'SELECT c.ccodimp, d.tdesimp
                      FROM sin_imp_codimpuesto c, sin_imp_desimpuesto d
                     WHERE c.ccodimp = d.ccodimp
                       AND d.cidioma = '
         || pcidioma || ' ORDER by c.nordcal';
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vtraza, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_get_lstimpuestos;

   FUNCTION f_get_tdescri_subtab(
      pcsubtab IN NUMBER,
      pcidioma IN NUMBER,
      pcempres IN NUMBER,
      ptselect OUT VARCHAR2)
      RETURN NUMBER IS
      vtraza         NUMBER := 0;
      vobject        VARCHAR2(200) := 'pac_sin_impuestos.f_get_tdescri_subtab';
      vparam         VARCHAR2(200)
         := 'parámetros - pcsubtab=' || pcsubtab || ' pcidioma: ' || pcidioma || ' pcempres: '
            || pcempres;
   BEGIN
      vtraza := 1;
      ptselect :=
         'SELECT s.csubtabla, sd.tsubtabla AS tdescri
                   FROM sgt_subtabs s, sgt_subtabs_des sd
                   WHERE s.csubtabla = '
         || pcsubtab || ' AND sd.cidioma = ' || pcidioma || ' AND s.cempres = ' || pcempres
         || ' AND s.csubtabla = sd.csubtabla
                     AND s.cempres = sd.cempres ';
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vtraza, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_get_tdescri_subtab;

   FUNCTION f_copia_impuesto(pcconcep IN NUMBER, pcconcep_ant IN NUMBER)
      RETURN NUMBER IS
      vtraza         NUMBER := 0;
      vobject        VARCHAR2(200) := 'pac_sin_impuestos.f_copia_impuesto';
      vparam         VARCHAR2(200)
                               := 'pcconcep: ' || pcconcep || 'pcconcep_ant: ' || pcconcep_ant;
      vcconcep       NUMBER;
   BEGIN
      vtraza := 1;

      BEGIN
         SELECT DISTINCT cconcep
                    INTO vcconcep
                    FROM sin_imp_calculo
                   WHERE cconcep = pcconcep;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            FOR impu IN (SELECT cconcep, ccodimp, nordimp, ctipper, cregfiscal, fvigor,
                                ctipcal, cbasecal, cbasemin, cbasemax, nporcen, imin, imax,
                                ifijo, csubtab
                           FROM sin_imp_calculo
                          WHERE cconcep = pcconcep_ant) LOOP
               vtraza := 2;

               INSERT INTO sin_imp_calculo
                           (cconcep, ccodimp, nordimp, ctipper,
                            cregfiscal, fvigor, cbasecal, cbasemin,
                            cbasemax, nporcen, imin, imax, ifijo,
                            csubtab, ctipcal)
                    VALUES (pcconcep, impu.ccodimp, impu.nordimp, impu.ctipper,
                            impu.cregfiscal, impu.fvigor, impu.cbasecal, impu.cbasemin,
                            impu.cbasemax, impu.nporcen, impu.imin, impu.imax, impu.ifijo,
                            impu.csubtab, impu.ctipcal);

               vtraza := 3;
            END LOOP;

            COMMIT;
            RETURN 0;
      END;

      RETURN 9905919;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vtraza, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_copia_impuesto;

   FUNCTION f_destinatario(
      psperson IN per_personas.sperson%TYPE,
      pcagente IN agentes.cagente%TYPE,
      pfecha IN DATE,
      psgestio IN sin_tramita_gestion.sgestio%TYPE,
      pctipper OUT per_personas.ctipper%TYPE,
      pcregfiscal OUT per_regimenfiscal.cregfiscal%TYPE,
      pcprofes OUT per_detper.cprofes%TYPE,
      pcpais OUT paises.cpais%TYPE,
      pcprovin OUT provincias.cprovin%TYPE,
      pcpoblac OUT poblaciones.cpoblac%TYPE)
      RETURN NUMBER IS
      vtraza         NUMBER := 0;
      vobject        VARCHAR2(200) := 'pac_sin_impuestos.f_profesional';
      vparam         VARCHAR2(200)
         := 'parametros psperson:' || psperson || ' pcagente:' || pcagente || ' pfecha:'
            || pfecha || ' psgestio:' || psgestio;
   /*************************************************************************
     Devuelve los datos fiscales del destinatario para calculo de retenciones
    *************************************************************************/
   BEGIN
      vtraza := 1;

      SELECT ctipper, cregfiscal
        INTO pctipper, pcregfiscal
        FROM (SELECT per.ctipper, f.cregfiscal
                FROM per_personas per, per_regimenfiscal f
               WHERE per.sperson = psperson
                 AND f.sperson = per.sperson
                 AND f.fefecto = (SELECT MAX(f1.fefecto)
                                    FROM per_regimenfiscal f1
                                   WHERE f1.sperson = f.sperson
                                     AND f1.fefecto <= pfecha)
                 AND per.swpubli = 1
              UNION
              SELECT per.ctipper, f.cregfiscal
                FROM per_personas per, per_regimenfiscal f
               WHERE per.sperson = psperson
                 AND f.sperson = per.sperson
                 AND f.fefecto = (SELECT MAX(f1.fefecto)
                                    FROM per_regimenfiscal f1
                                   WHERE f1.sperson = f.sperson
                                     AND f1.fefecto <= pfecha
                                     AND f1.cagente = ff_agente_cpervisio(pcagente))
                 AND f.cagente = ff_agente_cpervisio(pcagente)
                 AND per.swpubli = 0);

      vtraza := 2;

      SELECT cprofes
        INTO pcprofes
        FROM (SELECT d.cprofes
                FROM per_detper d, per_personas per
               WHERE d.sperson = per.sperson
                 AND d.sperson = psperson
                 AND per.swpubli = 1
              UNION
              SELECT d.cprofes
                FROM per_detper d, per_personas per
               WHERE d.sperson = per.sperson
                 AND d.sperson = psperson
                 AND d.cagente = ff_agente_cpervisio(pcagente)
                 AND per.swpubli = 0);

      IF psgestio IS NOT NULL THEN
         vtraza := 3;

         SELECT l.cpais, l.cprovin, l.cpoblac
           INTO pcpais, pcprovin, pcpoblac
           FROM sin_tramita_gestion g, sin_tramita_localiza l
          WHERE g.nsinies = l.nsinies
            AND g.ntramit = l.ntramit
            AND g.nlocali = l.nlocali
            AND g.sgestio = psgestio;
      ELSE
         vtraza := 4;

         SELECT cprovin, cpoblac
           INTO pcprovin, pcpoblac
           FROM (SELECT cprovin, cpoblac
                   FROM per_direcciones d, per_personas per
                  WHERE d.sperson = per.sperson
                    AND d.sperson = psperson
                    AND d.cdomici = (SELECT MIN(d1.cdomici)
                                       FROM per_direcciones d1
                                      WHERE d1.sperson = d.sperson)
                    AND per.swpubli = 1
                 UNION
                 SELECT cprovin, cpoblac
                   FROM per_direcciones d, per_personas per
                  WHERE d.sperson = per.sperson
                    AND d.sperson = psperson
                    AND d.cdomici = (SELECT MIN(d1.cdomici)
                                       FROM per_direcciones d1
                                      WHERE d1.sperson = d.sperson)
                    AND d.cagente = ff_agente_cpervisio(pcagente)
                    AND per.swpubli = 0);

         vtraza := 5;

         SELECT cpais
           INTO pcpais
           FROM provincias
          WHERE cprovin = pcprovin;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vtraza, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_destinatario;

   FUNCTION f_calc_tot_imp(
      pfecha IN DATE,
      psidepag IN sin_tramita_pago.sidepag%TYPE,
      psgestio IN sin_tramita_gestion.sgestio%TYPE,
      pctipgas IN sin_tramita_reserva.ctipgas%TYPE,
      pcconcep IN NUMBER,
      pisinret IN NUMBER,
      pctipper IN per_personas.ctipper%TYPE,
      pcregfiscal IN per_regimenfiscal.cregfiscal%TYPE,
      pcprofes IN per_detper.cprofes%TYPE,
      pcpais IN paises.cpais%TYPE,
      pcprovin IN provincias.cprovin%TYPE,
      pcpoblac IN poblaciones.cpoblac%TYPE,
      psimplog IN OUT sin_imp_calculo_log.simplog%TYPE,
      ptot_imp OUT NUMBER)
      RETURN NUMBER IS
      vtraza         NUMBER := 0;
      vobject        VARCHAR2(200) := 'pac_sin_impuestos.f_calc_tot_imp';
      vparam         VARCHAR2(200)
         := 'parametros pfecha:' || pfecha || ' psidepag:' || psidepag || ' psgestio:'
            || psgestio || ' pctipgas:' || pctipgas || ' pcconcep:' || pcconcep
            || ' pisinret:' || pisinret || ' pctipper:' || pctipper || ' pcregfiscal:'
            || pcregfiscal || ' pcprofes:' || pcprofes || ' pcpais:' || pcpais || ' pcprovin:'
            || pcprovin || ' pcpoblac:' || pcpoblac || ' psimplog:' || psimplog;
      vimporte       NUMBER;
      vnerror        NUMBER;
   /*************************************************************************
     Calcula todos los impuestos aplicables a un pago
    *************************************************************************/
   BEGIN
      -- primero borramos los calculos anteriores
      IF psimplog IS NULL THEN
         -- es el primer calculo. Borramos todo el log
         DELETE      sin_imp_calculo_log_det
               WHERE simplog = (SELECT simplog
                                  FROM sin_imp_calculo_log
                                 WHERE (NVL(sgestio, -1) = NVL(psgestio, -2))
                                    OR(NVL(sidepag, -1) = NVL(psidepag, -2)));

         DELETE      sin_imp_calculo_log
               WHERE (NVL(sgestio, -1) = NVL(psgestio, -2))
                  OR(NVL(sidepag, -1) = NVL(psidepag, -2));

         -- Creamos un log nuevo
         SELECT simplog.NEXTVAL
           INTO psimplog
           FROM DUAL;

         INSERT INTO sin_imp_calculo_log
                     (simplog, sidepag, sgestio, isinret, ctipper, cregfiscal, cpais,
                      cprovin, cpoblac)
              VALUES (psimplog, psidepag, psgestio, pisinret, pctipper, pcregfiscal, pcpais,
                      pcprovin, pcpoblac);
      ELSE   -- calculo de reserva para gestiones. No es el primer tipo de gasto que calculamos
         DELETE      sin_imp_calculo_log_det
               WHERE simplog = (SELECT simplog
                                  FROM sin_imp_calculo_log
                                 WHERE (NVL(sgestio, -1) = NVL(psgestio, -2))
                                    OR(NVL(sidepag, -1) = NVL(psidepag, -2)))
                 AND ctipgas = pctipgas;
      END IF;

      ptot_imp := 0;

      FOR i IN (SELECT   ccodimp, csumres
                    FROM sin_imp_codimpuesto
                ORDER BY nordcal) LOOP
         vimporte := 0;
         vnerror := f_calc_impuesto(psimplog, pfecha, i.ccodimp, i.csumres, pcconcep,
                                    pctipgas, pisinret, pctipper, pcregfiscal, pcprofes,
                                    pcpais, pcprovin, pcpoblac, vimporte);

         IF vnerror <> 0 THEN
            RETURN vnerror;
         END IF;

         ptot_imp := ptot_imp + vimporte;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vtraza, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_calc_tot_imp;

   FUNCTION f_calc_impuesto(
      psimplog IN sin_imp_calculo_log.simplog%TYPE,
      pfecha IN DATE,
      pccodimp IN sin_imp_codimpuesto.ccodimp%TYPE,
      pcsumres IN sin_imp_codimpuesto.csumres%TYPE,
      pcconcep IN NUMBER,
      pctipgas IN sin_tramita_reserva.ctipgas%TYPE,
      pisinret IN NUMBER,
      pctipper IN per_personas.ctipper%TYPE,
      pcregfiscal IN per_regimenfiscal.cregfiscal%TYPE,
      pcprofes IN per_detper.cprofes%TYPE,
      pcpais IN paises.cpais%TYPE,
      pcprovin IN provincias.cprovin%TYPE,
      pcpoblac IN poblaciones.cpoblac%TYPE,
      ptotal OUT NUMBER)
      RETURN NUMBER IS
      vtraza         NUMBER := 0;
      vobject        VARCHAR2(200) := 'pac_sin_impuestos.f_calc_impuesto';
      vparam         VARCHAR2(200)
         := 'param psimplog:' || psimplog || ' pfecha:' || pfecha || ' pccodimp:' || pccodimp
            || ' pcsumres:' || pcsumres || ' pcconcep:' || pcconcep || ' pctipgas:'
            || pctipgas || ' pisinret:' || pisinret || ' pctipper:' || pctipper
            || ' pcregfiscal:' || pcregfiscal || ' pcprofes:' || pcprofes || ' pcpais:'
            || pcpais || ' pcprovin:' || pcprovin || ' pcpoblac:' || pcpoblac;
      vctipcal       NUMBER;
      visinret       NUMBER;
      vccodimp       NUMBER;
      vibase         NUMBER;
      vnerror        NUMBER := 0;
      vcbasecal      NUMBER;
      vnporcen       NUMBER;
      vifijo         NUMBER;
/*************************************************************************
  Calcula un impuesto
 *************************************************************************/
   BEGIN
      -- seleccionamos el tipo de calculo
      vtraza := 1;

      BEGIN
         SELECT ctipcal, cbasecal, nporcen, ifijo
           INTO vctipcal, vcbasecal, vnporcen, vifijo
           FROM sin_imp_calculo
          WHERE cconcep = pcconcep
            AND ccodimp = pccodimp
            AND ctipper = pctipper
            AND cregfiscal = pcregfiscal
            AND fvigor = (SELECT MAX(fvigor)
                            FROM sin_imp_calculo
                           WHERE cconcep = pcconcep
                             AND ccodimp = pccodimp
                             AND ctipper = pctipper
                             AND cregfiscal = pcregfiscal
                             AND fvigor <= pfecha);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            SELECT ctipcal, cbasecal, nporcen, ifijo
              INTO vctipcal, vcbasecal, vnporcen, vifijo
              FROM sin_imp_calculo
             WHERE cconcep = pcconcep
               AND ccodimp = pccodimp
               AND ctipper = pctipper
               AND cregfiscal IS NULL
               AND fvigor = (SELECT MAX(fvigor)
                               FROM sin_imp_calculo
                              WHERE cconcep = pcconcep
                                AND ccodimp = pccodimp
                                AND ctipper = pctipper
                                AND cregfiscal IS NULL
                                AND fvigor <= pfecha);
      END;

      -- LOG
      INSERT INTO sin_imp_calculo_log_det
                  (simplog, ctipgas, ccodimp, ctipcal)
           VALUES (psimplog, NVL(pctipgas, 0), pccodimp, vctipcal);

      -- CALCULO DEL IMPUESTO
      vtraza := 2;

      SELECT isinret, ccodimp
        INTO visinret, vccodimp
        FROM sin_imp_basecalculo
       WHERE cbasecal = vcbasecal;

      IF visinret IS NOT NULL THEN
         vibase := pisinret;
      ELSE
         vtraza := 3;

         SELECT nvalimp
           INTO vibase
           FROM sin_imp_calculo_log_det
          WHERE simplog = psimplog
            AND ccodimp = vccodimp
            AND NVL(ctipgas, -1) = NVL(pctipgas, -1);
      END IF;

      IF vctipcal = 1 THEN   -- Calculo lineal
         ptotal := vibase + vifijo;
      ELSIF vctipcal = 2 THEN   -- Porcentual
         ptotal := vibase * vnporcen / 100;
      ELSIF vctipcal = 3 THEN   -- Porcentual tabla reteica
         SELECT valor
           INTO vnporcen
           FROM sin_imp_tbl t1
          WHERE ctabla = vctipcal
            AND ccod1 = pcpais
            AND ccod2 = pcprovin
            AND ccod3 = pcpoblac
            AND ccod4 = pcprofes
            AND fdesde = (SELECT MAX(fdesde)
                            FROM sin_imp_tbl t2
                           WHERE t2.ccod1 = t1.ccod1
                             AND t2.ccod2 = t1.ccod2
                             AND t2.ccod3 = t1.ccod3
                             AND t2.ccod4 = t1.ccod4
                             AND t2.fdesde <= f_sysdate);

         ptotal := vibase * vnporcen / 100;
      END IF;

      ptotal := ptotal * pcsumres;

      -- LOG
      UPDATE sin_imp_calculo_log_det
         SET ibase = vibase,
             nporcen = vnporcen,
             ifijo = vifijo,
             nvalimp = ptotal,
             nerror = vnerror
       WHERE simplog = psimplog
         AND NVL(ctipgas, -1) = NVL(pctipgas, -1)
         AND ccodimp = pccodimp;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vtraza, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);

         IF vtraza = 1 THEN
            vnerror := 9905928;   -- No se encontro el tipo de calculo para el impuesto
         ELSIF vtraza = 2 THEN
            vnerror := 9905929;   -- No se encontro la base de calculo
         ELSIF vtraza = 3 THEN
            vnerror := 9905930;   -- No se encontro el impuesto de referencia
         END IF;

         UPDATE sin_imp_calculo_log_det
            SET nerror = vnerror
          WHERE simplog = psimplog
            AND NVL(ctipgas, -1) = NVL(pctipgas, -1)
            AND ccodimp = pccodimp;

         RETURN vnerror;
   END f_calc_impuesto;

   FUNCTION f_get_impuestos_calculados(psimplog IN NUMBER, pquery IN OUT VARCHAR2)
      RETURN NUMBER IS
      vtraza         NUMBER := 0;
      vobject        VARCHAR2(200) := 'pac_sin_impuestos.f_get_impuestos_calculados';
      vparam         VARCHAR2(200) := 'psimplog: ' || psimplog;
   BEGIN
      vtraza := 1;
      pquery :=
         'SELECT ccodimp, ctipcal, nporcen, ifijo, nvalimp
                   FROM sin_imp_calculo_log_det
                  WHERE simplog = '
         || psimplog;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vtraza, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_get_impuestos_calculados;

   FUNCTION f_get_lstconceptos(pcidioma IN NUMBER, ptselect OUT VARCHAR2)
      RETURN NUMBER IS
      vtraza         NUMBER := 0;
      vobject        VARCHAR2(200) := 'pac_sin_impuestos.f_get_lstconceptos';
      vparam         VARCHAR2(200)
                          := 'parámetros - pcidioma=' || pcidioma || ' ptselect: ' || ptselect;
   BEGIN
      vtraza := 1;
      ptselect :=
         'SELECT catribu, tatribu
          FROM detvalores
         WHERE cvalor = 1138
           AND cidioma = '
         || pcidioma;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vtraza, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_get_lstconceptos;

/*************************************************************************
  Devuelve la agrupacion para impuestos a partir del concepto del pago
 *************************************************************************/
   FUNCTION f_get_cconcep(pcconpag IN NUMBER, pcconcep OUT NUMBER)
      RETURN NUMBER IS
      vtraza         NUMBER := 0;
      vobject        VARCHAR2(200) := 'pac_sin_impuestos.f_get_cconcep';
      vparam         VARCHAR2(200) := 'parámetros - pcconpag=' || pcconpag;
   BEGIN
      vtraza := 1;

      SELECT cconcep
        INTO pcconcep
        FROM sin_imp_conceptos
       WHERE cconpag = pcconpag;

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         p_tab_error(f_sysdate, f_user, vobject, vtraza, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vtraza, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_get_cconcep;

/*************************************************************************
  Devuelve la definición del reteica para los tipos de profesional de una localización en concreto
 *************************************************************************/
   FUNCTION f_get_definiciones_reteica(
      pcpais IN NUMBER,
      pcprovin IN NUMBER,
      pcpoblac IN NUMBER,
      pcidioma IN NUMBER,
      ptselect OUT VARCHAR2)
      RETURN NUMBER IS
      vtraza         NUMBER := 0;
      vobject        VARCHAR2(200) := 'pac_sin_impuestos.f_get_cconcep';
      vparam         VARCHAR2(200)
         := 'parámetros - pcpais=' || pcpais || ' pcprovin=' || pcprovin || ' pcpoblac='
            || pcpoblac || ' pcidioma=' || pcidioma;
   BEGIN
      vtraza := 1;
      ptselect :=
         'SELECT catribu as ctipprof, tatribu as ttipprof, def.valor , def.fdesde
                  FROM   detvalores,
                       ( SELECT t.valor, t.ccod4, t.fdesde
                         FROM   sin_imp_tbl t,
                               (SELECT t1.ccod4, MAX(t1.fdesde) as fdesde
                                FROM   sin_imp_tbl t1
                                WHERE  t1.ccod1 = '
         || pcpais || ' AND    t1.ccod2 = ' || pcprovin || ' AND    t1.ccod3 = ' || pcpoblac
         || ' GROUP BY t1.ccod4) t2
                         WHERE  t.ccod1 = ' || pcpais || ' AND    t.ccod2 = ' || pcprovin
         || ' AND    t.ccod3 = ' || pcpoblac
         || ' AND    t.fdesde = t2.fdesde
                         AND    t.ccod4 = t2.ccod4
                       ) def
                  WHERE cvalor = 724
                    AND cidioma = '
         || pcidioma || ' AND def.ccod4(+) = catribu ';
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vtraza, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_get_definiciones_reteica;

   FUNCTION f_set_valores_reteica(
      pcpais IN NUMBER,
      pcprovin IN NUMBER,
      pcpoblac IN NUMBER,
      pfdesde IN DATE,
      pvalores_reteica IN VARCHAR2)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_SINIESTROS.f_set_valores_reteica';
      vparam         VARCHAR2(4000)
         := 'pcpais=' || pcpais || ' pcprovin=' || pcprovin || ' pcprovin=' || pcprovin
            || ' pcpoblac=' || pcpoblac || ' pfdesde=' || pfdesde || ' pvalores_reteica='
            || pvalores_reteica;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      lv_appendstring VARCHAR2(4000);
      lv_resultstring VARCHAR2(4000);
      lv_count       NUMBER;
      vctipprof      NUMBER;
      vpreteica      NUMBER;
      vresto         VARCHAR2(4000);
   BEGIN
      --Comprovació dels parámetres d'entrada
      IF pcpais IS NULL
         OR pcprovin IS NULL
         OR pcpoblac IS NULL
         OR pfdesde IS NULL
         OR pvalores_reteica IS NULL THEN
         RETURN 103135;
      END IF;

      vpasexec := 3;

      IF pvalores_reteica IS NOT NULL THEN
         lv_appendstring := pvalores_reteica;

         BEGIN
            LOOP
               EXIT WHEN NVL(INSTR(lv_appendstring, ','), -99) < 0;
               lv_resultstring := SUBSTR(lv_appendstring, 1,(INSTR(lv_appendstring, ',') - 1));
               lv_count := INSTR(lv_appendstring, ',') + 1;
               lv_appendstring := SUBSTR(lv_appendstring, lv_count, LENGTH(lv_appendstring));
               vpasexec := 2;

               SELECT TO_NUMBER(SUBSTR(lv_resultstring, 1, INSTR(lv_resultstring, '#') - 1))
                 INTO vctipprof
                 FROM DUAL;

               vpasexec := 3;

               SELECT SUBSTR(REPLACE(lv_resultstring, '.', ','),
                             INSTR(REPLACE(lv_resultstring, '.', ','), '#') + 1)
                 INTO vpreteica
                 FROM DUAL;

               vpasexec := 4;

               BEGIN
                  INSERT INTO sin_imp_tbl
                              (ctabla, ccod1, ccod2, ccod3, ccod4, valor, fdesde)
                       VALUES (3, pcpais, pcprovin, pcpoblac, vctipprof, vpreteica, pfdesde);
               EXCEPTION
                  WHEN DUP_VAL_ON_INDEX THEN
                     UPDATE sin_imp_tbl
                        SET valor = vpreteica
                      WHERE ctabla = 3
                        AND ccod1 = pcpais
                        AND ccod2 = pcprovin
                        AND ccod3 = pcpoblac
                        AND ccod4 = vctipprof
                        AND fdesde = pfdesde;
               END;
            END LOOP;
         END;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_set_valores_reteica;
END pac_sin_impuestos;

/

  GRANT EXECUTE ON "AXIS"."PAC_SIN_IMPUESTOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_SIN_IMPUESTOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_SIN_IMPUESTOS" TO "PROGRAMADORESCSI";
