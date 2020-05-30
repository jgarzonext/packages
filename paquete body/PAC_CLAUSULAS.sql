--------------------------------------------------------
--  DDL for Package Body PAC_CLAUSULAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_CLAUSULAS" IS
   /******************************************************************************
    NOMBRE:    PAC_ALCTR126
    PROPÓSITO: Funciones para traspaso de informacion entre las tablas reales y las de estudio

    REVISIONES:
    Ver        Fecha        Autor     Descripción
    ---------  ----------  --------  ------------------
    1.0        XX/XX/XXXX   XXX      1. Creación del package.
    2.0        13/01/2010   RSC      2. 16726: APR - clauses definition
    3.0        17/05/2011   APD      3. 0018362: LCOL003 - Parámetros en cláusulas y visualización cláusulas automáticas
    4.0        10/01/2012   DRA      4. 0020498: LCOL_T001-LCOL - UAT - TEC - Beneficiaris de la p?lissa
    5.0        30/01/2013   JMF      0025583: LCOL - Revision incidencias qtracker (IV)
    6.0        30/10/2013   JSV      6. 0027768: LCOL_F3B-Fase 3B - Parametrizaci?n B?sica AWS
    7.0        19/05/2016   VCG      7. 0042659: bug cliente incidencia 0042500 - AXISCTR008 - RCP Individual - Cláusulas Automáticas
   ******************************************************************************/

   -- Genera en las tablas EST - las clausulas genéricas
   --   la automáticas asociadas a respuestas de preguntas  (con o sin parámetros)
   -- Si el riesgo es NULO, trata todos los riesgos definidos
   -- Puede llamarse varias veces (tanto si existen previamente como si no)
   FUNCTION f_ins_clausulas(
      psseguro IN estseguros.sseguro%TYPE,
      pnriesgo IN estriesgos.nriesgo%TYPE,
      pnmovimi IN movseguro.nmovimi%TYPE,
      pfefecto IN estgaranseg.finiefe%TYPE,
      pcidioma IN NUMBER DEFAULT 2)
      RETURN NUMBER IS
      -- Bug 16726 - RSC - 13/01/2010 - APR - clauses definition
      v_bloq_aut     NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'psseguro=' || psseguro || 'pnriesgo=' || pnriesgo || 'pnmovimi=' || pnmovimi
            || 'pfefecto=' || pfefecto || 'pcidioma=' || pcidioma;
      vnumerr        NUMBER;
      vobject        VARCHAR2(200) := 'PAC_CLAUSULAS.f_ins_clausulas';
      -- Fin Bug 16726
      vcount         NUMBER;   -- Bug 27539/151777 - 30/08/2013 - AMC
      isaltacol      BOOLEAN;
      v_sproduc      estseguros.sproduc%TYPE;
      vnpoliza       estseguros.npoliza%TYPE;
      v_escertif0    NUMBER;
      v_existe       NUMBER;
      v_admite_cert  NUMBER;
      vsseguro       estseguros.sseguro%TYPE;

      CURSOR c_clausulas(
         pc_sseguro estseguros.sseguro%TYPE,
         pc_nriesgo estriesgos.nriesgo%TYPE,
         pc_nmovimi movseguro.nmovimi%TYPE) IS
         SELECT 'GAR' tipo, p.sclagen, r.nriesgo, p.sclapro, cclaucolec
           FROM clausupro p, clausugar c, estriesgos r
          WHERE p.sclapro = c.sclapro
            AND p.cramo = c.cramo   -- Bug 27048/158119 - 07/11/2013
            AND p.cmodali = c.cmodali
            AND p.ctipseg = c.ctipseg
            AND p.ccolect = c.ccolect   -- Fi Bug 27048/158119 - 07/11/2013
            AND r.nriesgo = NVL(pc_nriesgo, r.nriesgo)
            AND(c.cgarant, r.nriesgo) IN(SELECT cgarant, nriesgo
                                           FROM estgaranseg
                                          WHERE sseguro = pc_sseguro
                                            AND nriesgo = NVL(pc_nriesgo, nriesgo)
                                            -- Bug 27768/15197 - JSV - 30/10/2013
                                            AND((NVL(cobliga, 0) = 1
                                                 AND NVL(c.caccion, 0) = 1)
                                                OR(NVL(cobliga, 0) = 0
                                                   AND NVL(c.caccion, 0) = 0))
                                            AND nmovimi = pc_nmovimi)
            AND(r.sseguro, c.cramo, c.cmodali, c.ctipseg, c.ccolect) IN(
                                     SELECT x.sseguro, x.cramo, x.cmodali, x.ctipseg,
                                            x.ccolect
                                       FROM estseguros x
                                      WHERE x.sseguro = pc_sseguro)
         UNION
         SELECT 'PRE' tipo, p.sclagen, r.nriesgo, p.sclapro, cclaucolec
           FROM clausupreg c, clausupro p, estriesgos r
          WHERE (c.cpregun, c.crespue) IN(
                   SELECT cpregun, crespue
                     FROM estpregunseg
                    WHERE sseguro = pc_sseguro
                      AND nriesgo = r.nriesgo
                      AND nmovimi = pc_nmovimi
                   UNION
                   SELECT cpregun, crespue   -- BUG20498:DRA:10/01/2012
                     FROM estpregunpolseg
                    WHERE sseguro = pc_sseguro
                      AND nmovimi = pc_nmovimi
                   UNION
                   SELECT pg.cpregun, pg.crespue
                     FROM estpregungaranseg pg, estgaranseg gs
                    WHERE pg.sseguro = pc_sseguro
                      AND pg.nriesgo = r.nriesgo
                      AND pg.nmovimi = pc_nmovimi
                      AND pg.cgarant = gs.cgarant   --Bug 27048/158949-14/11/2013-AMC
                      AND pg.sseguro = gs.sseguro
                      AND pg.nriesgo = gs.nriesgo
                      AND pg.nmovimi = gs.nmovimi
                      AND gs.cobliga = 1)
            AND r.nriesgo = NVL(pc_nriesgo, r.nriesgo)
            AND c.sclapro = p.sclapro
            AND(r.sseguro, p.cramo, p.cmodali, p.ctipseg, p.ccolect) IN(
                                SELECT x2.sseguro, x2.cramo, x2.cmodali, x2.ctipseg,
                                       x2.ccolect
                                  FROM estseguros x2
                                 WHERE x2.sseguro = pc_sseguro);

   -- BUG AMA-203 - FAL - 16/06/2016
   CURSOR c_claesp(p_sseguro estseguros.sseguro%TYPE,
                   p_nriesgo estriesgos.nriesgo%TYPE,
                   p_nmovimi movseguro.nmovimi%TYPE) IS
      SELECT * FROM estclausuesp
            WHERE sseguro = p_sseguro
              AND nriesgo = NVL(p_nriesgo, nriesgo)
              AND nmovimi = p_nmovimi
              AND cclaesp NOT IN(4, 3)
      ORDER BY nordcla;

   TYPE list_claesp IS TABLE OF c_claesp%ROWTYPE
      INDEX BY BINARY_INTEGER;

   l_list_claesp      list_claesp;
   v_index              number:= 1;
   -- FI BUG AMA-203 - FAL - 16/06/2016

   BEGIN

      -- BUG AMA-203 - FAL - 16/06/2016 - Antes de borrar salvamos las especificas
      FOR reg_claesp IN c_claesp(psseguro, pnriesgo, pnmovimi) LOOP
        l_list_claesp(v_index).nmovimi := reg_claesp.nmovimi;
        l_list_claesp(v_index).sseguro := reg_claesp.sseguro;
        l_list_claesp(v_index).cclaesp := reg_claesp.cclaesp;
        l_list_claesp(v_index).nordcla := reg_claesp.nordcla;
        l_list_claesp(v_index).nriesgo := reg_claesp.nriesgo;
        l_list_claesp(v_index).finiclau := reg_claesp.finiclau;
        l_list_claesp(v_index).sclagen := reg_claesp.sclagen;
        l_list_claesp(v_index).tclaesp := reg_claesp.tclaesp;
        l_list_claesp(v_index).ffinclau := reg_claesp.ffinclau;
        v_index:= v_index + 1;
      END LOOP;

      DELETE FROM estclausuesp x  -- Borramos también las especificas para evitar que quede un nordcla erroneo
            WHERE sseguro = psseguro
              AND nriesgo = NVL(pnriesgo, nriesgo)
              AND nmovimi = pnmovimi
              AND cclaesp NOT IN(4, 3);
      -- FI BUG AMA-203 - FAL - 16/06/2016

      -- Las automáticas se borran, para que se recalculen cada vez
      --- menos las asociadas a entradas manuales ya informadas
      DELETE FROM estclausuesp x
            WHERE sseguro = psseguro
              AND nriesgo = NVL(pnriesgo, nriesgo)
              AND nmovimi = pnmovimi
              AND cclaesp IN(4, 3)
              AND NOT EXISTS(SELECT 1
                               FROM estclauparesp r
                              WHERE r.sseguro = x.sseguro
                                AND r.nmovimi = x.nmovimi
                                AND r.cclaesp = x.cclaesp
                                AND r.nordcla = x.nordcla
                                AND r.nriesgo = x.nriesgo);

      -- Bug 27768/15197 - JSV - 30/10/2013
      SELECT e.sproduc, e.npoliza, ssegpol
        INTO v_sproduc, vnpoliza, vsseguro
        FROM estseguros e
       WHERE e.sseguro = psseguro;

      isaltacol := FALSE;
      v_admite_cert := NVL(f_parproductos_v(v_sproduc, 'ADMITE_CERTIFICADOS'), 0);

      IF v_admite_cert = 1 THEN
         v_existe := pac_seguros.f_get_escertifcero(vnpoliza);
         v_escertif0 := pac_seguros.f_get_escertifcero(NULL, vsseguro);

         IF v_escertif0 > 0 THEN
            isaltacol := TRUE;
         ELSE
            IF v_existe <= 0 THEN
               isaltacol := TRUE;
            END IF;
         END IF;
      END IF;

      <<l_clausulas>>
      FOR reg_clausulas IN c_clausulas(psseguro, pnriesgo, pnmovimi) LOOP
         -- Bug 27768/15197 - JSV - 30/10/2013
         IF (v_admite_cert = 1
             AND pac_iax_produccion.isaltacol
             AND NVL(reg_clausulas.cclaucolec, 3) IN(1, 3))
            OR(v_admite_cert = 1
               AND NOT isaltacol
               AND NVL(reg_clausulas.cclaucolec, 3) IN(2, 3))
            OR v_admite_cert = 0 THEN
            -- Bug 16726 - RSC - 13/01/2010 - APR - clauses definition
            SELECT COUNT(*)
              INTO v_bloq_aut
              FROM estclausubloq
             WHERE sseguro = psseguro
               AND nmovimi = pnmovimi
               AND nriesgo = reg_clausulas.nriesgo
               AND sclagen = reg_clausulas.sclagen;

            -- Fin Bug 16726

            -- de momento, sólo inserta las automáticas sin parámetros de respuestas a preguntas
            IF reg_clausulas.tipo = 'PRE' THEN
               -- Bug 16726 - RSC - 13/01/2010 - APR - clauses definition
               IF v_bloq_aut = 0 THEN
                  -- Fin Bug 16726

                  -- Bug 27539/151777 - 30/08/2013 - AMC
                  IF NVL(pnriesgo, 0) = 0 THEN
                     SELECT COUNT(1)
                       INTO vcount
                       FROM estclausuesp
                      WHERE sseguro = psseguro
                        AND nriesgo = 0
                        AND sclagen = reg_clausulas.sclagen
                        AND nmovimi = pnmovimi;
                  END IF;

                  IF vcount = 0 THEN
                     -- BUG20498:DRA:13/01/2012:Inici
                     BEGIN
                        INSERT INTO estclausuesp
                                    (sseguro, cclaesp, finiclau, ffinclau,
                                     nordcla,
                                     sclagen, nriesgo, nmovimi)
                             VALUES (psseguro, 4, pfefecto, NULL,
                                     (SELECT NVL(MAX(nordcla), 0) + 1
                                        FROM estclausuesp
                                       WHERE sseguro = psseguro
                                         AND nmovimi = pnmovimi),
                                     reg_clausulas.sclagen, NVL(pnriesgo, 0), pnmovimi);
                     -- BUG20498:DRA:13/01/2012:Fi
                     EXCEPTION
                        WHEN DUP_VAL_ON_INDEX THEN
                           -- Las que no hayan borrado, porque ya han sido informadas por el usario provoca
                           -- error de clave primaria, y se conservan
                           NULL;
                     END;
                  -- Bug 16726 - RSC - 13/01/2010 - APR - clauses definition
                  END IF;
               -- Fi Bug 27539/151777 - 30/08/2013 - AMC
               END IF;
            -- Fin Bug 16726
            ELSIF reg_clausulas.tipo = 'GAR' THEN
               -- Bug 16726 - RSC - 13/01/2010 - APR - clauses definition
               IF v_bloq_aut = 0 THEN
                  -- Fin Bug 16726
                  BEGIN
                     INSERT INTO estclausuesp
                                 (sseguro, cclaesp, finiclau, ffinclau,
                                  nordcla,
                                  sclagen, nriesgo, nmovimi)
                          VALUES (psseguro, 3, pfefecto, NULL,
                                  (SELECT NVL(MAX(nordcla), 0) + 1
                                     FROM estclausuesp
                                    WHERE sseguro = psseguro
                                      AND nmovimi = pnmovimi),
                                  reg_clausulas.sclagen, reg_clausulas.nriesgo, pnmovimi);
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                        -- Las que no hayan borrado, porque ya han sido informadas por el usario provoca
                        -- error de clave primaria, y se conservan
                        NULL;
                  END;
               -- Bug 16726 - RSC - 13/01/2010 - APR - clauses definition
               END IF;
            -- Fin Bug 16726
            END IF;
         END IF;
      END LOOP l_clausulas;

      -- BUG AMA-203 - FAL - 16/06/2016 - Reinsertamos tmb las especificas con nordcla correlativo
      IF l_list_claesp is not null then
        IF l_list_claesp.count > 0 then
          FOR i IN l_list_claesp.FIRST .. l_list_claesp.LAST LOOP

              BEGIN
                 INSERT INTO estclausuesp
                             (sseguro, cclaesp, finiclau, ffinclau,
                              nordcla,
                              sclagen, nriesgo, nmovimi, tclaesp)
                      VALUES (l_list_claesp(i).sseguro, l_list_claesp(i).cclaesp, l_list_claesp(i).finiclau, l_list_claesp(i).ffinclau,
                              (SELECT NVL(MAX(nordcla), 0) + 1
                                 FROM estclausuesp
                                WHERE sseguro = psseguro
                                  AND nmovimi = pnmovimi
                                  and nriesgo = nvl(pnriesgo, nriesgo)),
                              l_list_claesp(i).sclagen, l_list_claesp(i).nriesgo, l_list_claesp(i).nmovimi,
                              l_list_claesp(i).tclaesp);

              EXCEPTION
                 WHEN DUP_VAL_ON_INDEX THEN
                    NULL;
              END;

          END LOOP;
        END IF;
      END IF;
      -- FI BUG AMA-203 - FAL - 16/06/2016

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 112330;
   END f_ins_clausulas;

   -- en las tablas EST - las clausulas genéricas - Valida que se hayan completados todas
   --   la automáticas asociadas a respuestas de preguntas  (con o sin parámetros)
   --
   -- Si el riesgo es NULO, trata todos los riesgos definidos
   FUNCTION f_valida_clausulas(
      psseguro estseguros.sseguro%TYPE,
      pnriesgo estriesgos.nriesgo%TYPE,
      pcidioma IN NUMBER DEFAULT 2)
      RETURN NUMBER IS
      -- Comproba que totes els parametres estiguin informats de les clausulas amb parametres
      CURSOR c_param_clau(
         pc_sseguro IN estclausuesp.sseguro%TYPE,
         pc_nriesgo estclausuesp.nriesgo%TYPE) IS
         SELECT 1
           FROM clausupara cp, estclausuesp cb
          WHERE cb.sseguro = pc_sseguro
            AND(cb.nriesgo = pc_nriesgo)
            AND cb.cclaesp IN(3, 4)
            AND cb.sclagen = cp.sclagen
            AND NOT EXISTS(SELECT 1
                             FROM estclauparesp r
                            WHERE r.sseguro = cb.sseguro
                              AND r.nmovimi = cb.nmovimi
                              AND r.cclaesp = cb.cclaesp
                              AND r.nordcla = cb.nordcla
                              AND r.nriesgo = cb.nriesgo
                              AND r.nparame = cp.nparame
                              AND r.tvalor IS NOT NULL);
   BEGIN

      --- falta incloure-hi les clausulas amb parametres
      <<l_param_clau>>
      FOR reg_param_clau IN c_param_clau(psseguro, pnriesgo) LOOP
         RETURN 104090;
      END LOOP l_param_clau;

      RETURN 0;
   END f_valida_clausulas;

   -- Bug 18362 - APD - 17/05/2011 - se crea la funcion
   -- se insertan las clausulas automàticas de garantias / preguntas al objecte de ob_iax_clausulas
   -- BUG 21546_108727- 23/02/2012 - JLTS - Se quita la utilizacion del objeto mensajes
   FUNCTION f_ins_clauobj(poliza IN OUT ob_iax_detpoliza)
      RETURN NUMBER IS
      -- Bug 16726 - RSC - 13/01/2010 - APR - clauses definition
      v_bloq_aut     NUMBER;

      -- Fin Bug 16726
      CURSOR c_clausulas(
         pc_sseguro estseguros.sseguro%TYPE,
         pc_nriesgo estriesgos.nriesgo%TYPE,
         Pc_Nmovimi Movseguro.Nmovimi%Type) Is
         SELECT 'GAR' tipo, p.sclagen, r.nriesgo, p.sclapro, cclaucolec, p.norden
           FROM clausupro p, clausugar c, estriesgos r
          WHERE p.sclapro = c.sclapro
            AND p.cramo = c.cramo   -- Bug 27048/158119 - 07/11/2013
            AND p.cmodali = c.cmodali
            AND p.ctipseg = c.ctipseg
            AND p.ccolect = c.ccolect   -- Fi Bug 27048/158119 - 07/11/2013
            AND r.nriesgo = NVL(pc_nriesgo, r.nriesgo)
            AND c.cgarant IN(SELECT cgarant
                               FROM estgaranseg
                              WHERE sseguro = pc_sseguro
                                AND nriesgo = NVL(pc_nriesgo, nriesgo)
                                -- Bug 27768/15197 - JSV - 30/10/2013
                                AND((NVL(cobliga, 0) = 1
                                     AND NVL(c.caccion, 0) = 1)
                                    OR(NVL(cobliga, 0) = 0
                                       AND NVL(c.caccion, 0) = 0))
                                AND nmovimi = pc_nmovimi)
            AND(r.sseguro, c.cramo, c.cmodali, c.ctipseg, c.ccolect) IN(
                                     SELECT x.sseguro, x.cramo, x.cmodali, x.ctipseg,
                                            x.ccolect
                                       FROM estseguros x
                                      WHERE x.sseguro = pc_sseguro)
         Union
         SELECT 'PRE' tipo, p.sclagen, r.nriesgo, p.sclapro, cclaucolec, p.norden
           FROM clausupreg c, clausupro p, estriesgos r
          WHERE (c.cpregun, c.crespue) IN(SELECT cpregun, crespue
                                            FROM estpregunseg
                                           WHERE sseguro = pc_sseguro
                                             AND nriesgo = r.nriesgo
                                             AND nmovimi = pc_nmovimi
                                          UNION
                                          SELECT cpregun, crespue   -- BUG20498:DRA:10/01/2012
                                            FROM estpregunpolseg
                                           WHERE sseguro = pc_sseguro
                                             AND nmovimi = pc_nmovimi
                                          UNION
                                          SELECT cpregun, crespue
                                            FROM estpregungaranseg z1
                                           WHERE sseguro = pc_sseguro
                                             -- Bug 0025862 - 30/01/2013 - JMF
                                             AND EXISTS(
                                                   SELECT 1
                                                     FROM estgaranseg z2
                                                    WHERE z2.sseguro = z1.sseguro
                                                      AND z2.nriesgo = z1.nriesgo
                                                      AND z2.cgarant = z1.cgarant
                                                      AND z2.nmovimi = z1.nmovimi
                                                      AND z2.cobliga = 1)
                                             AND nriesgo = r.nriesgo
                                             AND nmovimi = pc_nmovimi)
            AND r.nriesgo = NVL(pc_nriesgo, r.nriesgo)
            AND c.sclapro = p.sclapro
            AND(r.sseguro, p.cramo, p.cmodali, p.ctipseg, p.ccolect) IN(
                                SELECT x2.sseguro, x2.cramo, x2.cmodali, x2.ctipseg,
                                       x2.ccolect
                                  FROM estseguros x2
                                 Where X2.Sseguro = Pc_Sseguro)
            order by norden;

      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vnumerr        NUMBER;
      vobject        VARCHAR2(200) := 'PAC_CLAUSULAS.F_Ins_clauobj';
      vnriesgo       riesgos.nriesgo%TYPE := NULL;
      v_tclatit      VARCHAR2(32000);   -- BUG 25583:NSS:09/02/2013
      vcparams       NUMBER;
      vexiste        BOOLEAN;
      vnpos          NUMBER;

      -- elimina todas las clausulas automaticas del objeto
      -- según las preguntas y garantias seleccionadas
      FUNCTION elimina_clausulas_aut
         RETURN NUMBER IS
      BEGIN
         IF poliza.clausulas IS NULL THEN
            RETURN -1;
         END IF;

         IF poliza.clausulas.COUNT = 0 THEN
            RETURN -1;
         END IF;

         FOR vclau IN poliza.clausulas.FIRST .. poliza.clausulas.LAST LOOP
            IF poliza.clausulas.EXISTS(vclau) THEN
               IF poliza.clausulas(vclau).ctipo IN(2, 3) THEN
                  vexiste := FALSE;

                  FOR reg_clausulas IN c_clausulas(poliza.sseguro, vnriesgo, poliza.nmovimi) LOOP
                     IF reg_clausulas.sclagen = poliza.clausulas(vclau).sclagen THEN
                        vexiste := TRUE;
                        EXIT;
                     END IF;
                  END LOOP;

                  IF NOT vexiste THEN
                     poliza.clausulas.DELETE(vclau);
                  END IF;
               END IF;
            END IF;
         END LOOP;

         RETURN 0;
      END elimina_clausulas_aut;

      FUNCTION existclau(psclagen IN NUMBER)
         RETURN NUMBER IS
      BEGIN
         IF poliza.clausulas IS NULL THEN
            RETURN -1;
         END IF;

         IF poliza.clausulas.COUNT = 0 THEN
            RETURN -1;
         END IF;

         FOR vclau IN poliza.clausulas.FIRST .. poliza.clausulas.LAST LOOP
            IF poliza.clausulas.EXISTS(vclau) THEN
               IF poliza.clausulas(vclau).sclagen = psclagen THEN
                  RETURN vclau;
               END IF;
            END IF;
         END LOOP;

         RETURN -1;
      END existclau;

      -- BUG9107:DRA:18-02-2009: Buscamos el NORDCLA mayor
      FUNCTION max_nordcla
         RETURN NUMBER IS
         v_max          NUMBER := 0;
      BEGIN
         IF poliza.clausulas IS NULL THEN
            RETURN 0;
         END IF;

         IF poliza.clausulas.COUNT = 0 THEN
            RETURN 0;
         END IF;

         FOR vclau IN poliza.clausulas.FIRST .. poliza.clausulas.LAST LOOP
            IF poliza.clausulas.EXISTS(vclau) THEN
               IF poliza.clausulas(vclau).cidentity > v_max THEN
                  v_max := poliza.clausulas(vclau).cidentity;
               END IF;
            END IF;
         END LOOP;

         RETURN v_max;
      END max_nordcla;
   BEGIN
      IF poliza.clausulas IS NULL THEN
         poliza.clausulas := t_iax_clausulas();
      END IF;

      -- Se borran las clausulas automaticas que ahora no deben salir
      -- porque no se ha seleccionado la pregunta o garantia de la cual
      -- dependen
      vnumerr := elimina_clausulas_aut;

      <<l_clausulas>>
      FOR reg_clausulas IN c_clausulas(poliza.sseguro, vnriesgo, poliza.nmovimi) LOOP
         -- Bug 27768/15197 - JSV - 30/10/2013
         IF (pac_mdpar_productos.f_get_parproducto('ADMITE_CERTIFICADOS',
                                                   f_sproduc_ret(poliza.cramo, poliza.cmodali,
                                                                 poliza.ctipseg,
                                                                 poliza.ccolect)) = 1
             AND pac_iax_produccion.isaltacol
             AND NVL(reg_clausulas.cclaucolec, 3) IN(1, 3))
            OR(pac_mdpar_productos.f_get_parproducto('ADMITE_CERTIFICADOS',
                                                     f_sproduc_ret(poliza.cramo,
                                                                   poliza.cmodali,
                                                                   poliza.ctipseg,
                                                                   poliza.ccolect)) = 1
               AND NOT pac_iax_produccion.isaltacol
               AND NVL(reg_clausulas.cclaucolec, 3) IN(2, 3))
            OR(pac_mdpar_productos.f_get_parproducto('ADMITE_CERTIFICADOS',
                                                     f_sproduc_ret(poliza.cramo,
                                                                   poliza.cmodali,
                                                                   poliza.ctipseg,
                                                                   poliza.ccolect)) = 0) THEN
            vexiste := FALSE;

            SELECT COUNT(*)
              INTO v_bloq_aut
              FROM estclausubloq
             WHERE sseguro = poliza.sseguro
               AND nmovimi = poliza.nmovimi
               AND nriesgo = reg_clausulas.nriesgo
               AND sclagen = reg_clausulas.sclagen;

            vnpos := existclau(reg_clausulas.sclagen);

            -- inserta una nova clausula
            IF vnpos = -1 THEN
               -- de momento, sólo inserta las automáticas sin parámetros de respuestas a preguntas
               IF reg_clausulas.tipo = 'PRE' THEN
                  -- Bug 16726 - RSC - 13/01/2010 - APR - clauses definition
                  IF v_bloq_aut = 0 THEN
                     -- Fin Bug 16726
                     poliza.clausulas.EXTEND;
                     poliza.clausulas(poliza.clausulas.LAST) := ob_iax_clausulas();
                     -- detvalores(64).catribu = 4.-Ligada a pregunta --> ob_iax_clausulas.ctipo = 2.-especial pregunta
                     poliza.clausulas(poliza.clausulas.LAST).ctipo := 2;   --preguntes
                     poliza.clausulas(poliza.clausulas.LAST).finiclau :=
                                                                        poliza.gestion.fefecto;
                     poliza.clausulas(poliza.clausulas.LAST).ffinclau := NULL;
                     poliza.clausulas(poliza.clausulas.LAST).cidentity := max_nordcla() + 1;
                     poliza.clausulas(poliza.clausulas.LAST).sclagen := reg_clausulas.sclagen;
                     -- BUG20498:DRA:10/01/2012:Inici
                     vnumerr := f_desclausula(reg_clausulas.sclagen, 1,
                                              poliza.gestion.cidioma, v_tclatit);
                     poliza.clausulas(poliza.clausulas.LAST).tclaesp := v_tclatit;
                     -- BUG20498:DRA:10/01/2012:Fi
                  -- Bug 16726 - RSC - 13/01/2010 - APR - clauses definition
                  END IF;
               -- Fin Bug 16726
               ELSIF reg_clausulas.tipo = 'GAR' THEN
                  -- Bug 16726 - RSC - 13/01/2010 - APR - clauses definition
                  IF v_bloq_aut = 0 THEN
                     -- Fin Bug 16726
                     poliza.clausulas.EXTEND;
                     poliza.clausulas(poliza.clausulas.LAST) := ob_iax_clausulas();
                     -- detvalores(64).catribu = 3.-Ligada a garantia --> ob_iax_clausulas.ctipo = 3.-especial garantia
                     poliza.clausulas(poliza.clausulas.LAST).ctipo := 3;   --garantias
                     poliza.clausulas(poliza.clausulas.LAST).tclaesp := '';
                     poliza.clausulas(poliza.clausulas.LAST).finiclau :=
                                                                        poliza.gestion.fefecto;
                     poliza.clausulas(poliza.clausulas.LAST).ffinclau := NULL;
                     poliza.clausulas(poliza.clausulas.LAST).cidentity := max_nordcla() + 1;
                     poliza.clausulas(poliza.clausulas.LAST).sclagen := reg_clausulas.sclagen;
                  -- Bug 16726 - RSC - 13/01/2010 - APR - clauses definition
                  END IF;
               -- Fin Bug 16726
               END IF;
            ELSE
               -- BUG20498:DRA:10/01/2012:Inici
               vnumerr := f_desclausula(poliza.clausulas(vnpos).sclagen, 1,
                                        poliza.gestion.cidioma, v_tclatit);
               poliza.clausulas(vnpos).tclaesp := v_tclatit;
            -- BUG20498:DRA:10/01/2012:Fi
            END IF;
         END IF;
      END LOOP l_clausulas;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 9902013;   -- No se ha podido recuperar las cláusulas automáticas
   END f_ins_clauobj;

   -- BUG20067:DRA:08/11/2011:Inici
   /***********************************************************************
      Devuelve la descripción de una clausula con parametros
      param in  sclaben  : código de la clausula
      param in  sseguro  : sseguro de la pòliza
      param out mensajes : mensajes de error
      return             : descripción garantia
   ***********************************************************************/
   FUNCTION f_get_descclausulapar(psclagen IN NUMBER, psseguro IN NUMBER, pcidioma IN NUMBER)
      RETURN VARCHAR2 IS
      dclausu        VARCHAR2(600);
      v_result       VARCHAR2(4000);
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
            := 'psclagen=' || psclagen || ' psseguro=' || psseguro || ' pcidioma=' || pcidioma;
      vobject        VARCHAR2(200) := 'PAC_CLAUSULAS.F_Get_DescClausulaBen';
      pcparams       NUMBER;
      -- Bug 0025583 - 04/02/2013 - JMF
      vtclatex       clausugen.tclatex%TYPE;
   BEGIN
      --Inicialitzacions
      vpasexec := 2;

      SELECT COUNT(1)
        INTO pcparams
        FROM clauparaseg cp
       WHERE cp.sseguro = psseguro
         AND cp.sclagen = psclagen
         AND cp.nriesgo = 0
         AND cp.nmovimi = (SELECT MAX(cp1.nmovimi)
                             FROM clauparaseg cp1
                            WHERE cp1.sseguro = cp.sseguro
                              AND cp1.sclagen = cp.sclagen);

      IF pcparams = 0 THEN
         vpasexec := 3;

         SELECT tclatex
           INTO v_result
           FROM clausugen
          WHERE sclagen = psclagen
            AND cidioma = pcidioma;

         dclausu := SUBSTR(v_result, 1, 600);
      ELSE
         vpasexec := 4;

         SELECT tclatex
           INTO vtclatex
           FROM clausugen
          WHERE sclagen = psclagen
            AND cidioma = pcidioma;

         vpasexec := 5;

         FOR cur IN (SELECT cp.nparame, cp.tparame
                       FROM clauparaseg cp
                      WHERE cp.sseguro = psseguro
                        AND cp.sclagen = psclagen
                        AND cp.nriesgo = 0
                        AND cp.nmovimi = (SELECT MAX(cp1.nmovimi)
                                            FROM clauparaseg cp1
                                           WHERE cp1.sseguro = cp.sseguro
                                             AND cp1.sclagen = cp.sclagen)) LOOP
            vpasexec := 6;
            vtclatex := REPLACE(vtclatex, '#' || cur.nparame || '#', cur.tparame);
         END LOOP;

         vpasexec := 7;
         -- Bug 0025583 - 04/02/2013 - JMF
         v_result := SUBSTR(vtclatex, 1, 4000);
      END IF;

      RETURN v_result;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN NULL;
   END f_get_descclausulapar;
-- BUG20067:DRA:08/11/2011:Fi
END pac_clausulas;

/

  GRANT EXECUTE ON "AXIS"."PAC_CLAUSULAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CLAUSULAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CLAUSULAS" TO "PROGRAMADORESCSI";
