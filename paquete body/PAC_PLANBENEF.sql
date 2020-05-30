--------------------------------------------------------
--  DDL for Package Body PAC_PLANBENEF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_PLANBENEF" AS
/******************************************************************************
   NOMBRE:       PAC_PLANBENEF
   PROPÓSITO:  Funciones necesarias para guardar/obtener informacion de los
               descuentos por plan de beneficios

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        10/04/2013   APD               1. Creación del package.
   2.0        10/04/2013   APD               2. 0026662: LCOL - AUT - Plan de beneficios
   3.0        18/06/2013   APD               3. 0026923: LCOL - TEC - Revisión Q-Trackers Fase 3A
   4.0        06/11/2013   JSV               4. 0027768: LCOL_F3B-Fase 3B - Parametrizaci?n B?sica AWS
******************************************************************************/
--------------------------------------------------------------------------
--------------------------------------------------------------------------
   FUNCTION f_autos_siniestros(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,
      pnmovimi IN NUMBER,
      pcgarant IN NUMBER,
      psproces IN NUMBER,
      pnmovima IN NUMBER,
      picapital IN NUMBER,
      pcpregun IN NUMBER)
      RETURN NUMBER IS
      --
      w_traza        NUMBER;
      w_siniestros   NUMBER := 0;
      w_fecmovimi    DATE;
      w_ssegpol      estseguros.ssegpol%TYPE;
   --
   BEGIN
      --
      --

      -- Bug 26737/142770 - 24/04/2013 - AMC - Quitamos la select

      --
      --
      w_traza := 1;

      IF ptablas = 'EST'
         AND pnmovimi = 0 THEN
         w_traza := 2;
         w_siniestros := 0;   -- Si es una pòlissa nova, no hi ha stres.
      ELSIF ptablas = 'EST' THEN   -- Si es un Spto, arrastramos la pregunta del movimiento anterior
         w_traza := 3;

         BEGIN
            -- Bug 26737/142770 - 24/04/2013 - AMC
            SELECT crespue
              INTO w_siniestros
              FROM estpregunseg
             WHERE sseguro = psseguro
               AND nriesgo = pnriesgo
               AND cpregun = pcpregun
               AND nmovimi = (SELECT MAX(nmovimi)
                                FROM estpregunseg
                               WHERE sseguro = psseguro
                                 AND nriesgo = pnriesgo
                                 AND cpregun = pcpregun);
         -- fi Bug 26737/142770 - 24/04/2013 - AMC
         EXCEPTION
            WHEN OTHERS THEN
               w_siniestros := 0;
         END;
      --
      ELSE
         w_traza := 4;

         -- És una cartera
         -- Busquem la data en que es va fer l'última cartera anterior
         BEGIN
            SELECT TRUNC(a.fmovimi)
              INTO w_fecmovimi
              FROM movseguro a
             WHERE a.sseguro = psseguro
               AND a.nmovimi = (SELECT MAX(b.nmovimi)
                                  FROM movseguro b
                                 WHERE b.sseguro = psseguro
                                   AND b.cmovseg IN(2, 0));
         -- Para igualarlo con la f_ultrenova.
         --AND(cmotmov = 404
         --    OR cmotmov = 100));
         EXCEPTION
            WHEN OTHERS THEN
               w_fecmovimi := TRUNC(f_sysdate);
         END;

         w_traza := 5;

         --
         SELECT COUNT(0)
           INTO w_siniestros
           FROM sin_siniestro a, sin_movsiniestro b
          WHERE a.sseguro = psseguro
            AND TRUNC(a.falta) BETWEEN w_fecmovimi AND TRUNC(f_sysdate)
            AND b.nsinies = a.nsinies
            AND b.nmovsin = (SELECT MAX(c.nmovsin)
                               FROM sin_movsiniestro c
                              WHERE c.nsinies = a.nsinies
                                AND TRUNC(c.festsin) BETWEEN w_fecmovimi AND TRUNC(f_sysdate))
            AND b.cestsin NOT IN(2, 3)
            AND a.nriesgo = pnriesgo;   --Bug 26638/160933 - 11/12/2013 - AMC
      END IF;

      --
      RETURN w_siniestros;
   --
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_planbenef.f_autos_siniestros', w_traza,
                     'p_sseguro = ' || psseguro || ' pfefecto ' || pfefecto || ' nriesgo = '
                     || pnriesgo || ' - ptablas  ' || ptablas,
                     SQLERRM);
         RETURN w_siniestros;
   END f_autos_siniestros;

   /*************************************************************************
      FUNCTION f_get_planbenef
         Función que devuelve el codigo del plan de beneficio
         param in ptablas   : Modo de acceso ('EST','CAR','POL')
         param in psseguro  : Identificador del seguro
         param in pnriesgo  : Identificador del riesgo
         param in pnmovimi  : Numero de movimiento
         return             : Codigo del plan de beneficios
   *************************************************************************/
   FUNCTION f_get_planbenef(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_planbenef.f_get_planbenef';
      vparam         VARCHAR2(500)
         := 'parámetros - ptablas: ' || ptablas || ' - psseguro: ' || psseguro
            || ' - pnriesgo: ' || pnriesgo || ' - pnmovimi: ' || pnmovimi;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vsproduc       NUMBER;
      vfefecto       estseguros.fefecto%TYPE;
      vantiguedad    NUMBER;
      vnsiniestros   NUMBER;
      --vcplan         NUMBER;
      vcagrtipo      aut_versiones.cagrtipo%TYPE;
      vcagrtiponum   aut_codagrtipo.cagrtiponum%TYPE;
      vanyo          NUMBER;
      vcplan         codplanbenef.cplan%TYPE := NULL;
      vcsubtabla     sgt_subtabs_det.csubtabla%TYPE;
      vcsubtabla_esp sgt_subtabs_det.csubtabla%TYPE;   -- Bug 27652 - APD - 16/07/2013
      vfrenova       DATE;
      vnmovimi       NUMBER;
      salir          EXCEPTION;
      vsproces       NUMBER;   -- Bug 26923/0147980 - APD - 02/07/2013
      vtprefor       pregunpro.tprefor%TYPE;   -- Bug 26923/0147980 - APD - 02/07/2013
      vcdpto         NUMBER;   -- Bug 27652 - APD - 16/07/2013
      vcciudad       NUMBER;   -- Bug 27652 - APD - 16/07/2013
      vcrespue       NUMBER;   -- Bug 27768/0156835 - APD - 28/10/2013
      vcrespue_0     NUMBER;   -- Bug 27768/0156835 - APD - 28/10/2013
      vsseguro_0     NUMBER;   -- Bug 27768/0156835 - APD - 28/10/2013
      vnpoliza       NUMBER;   -- Bug 27768/0156835 - APD - 28/10/2013
      vncertif       NUMBER;   -- Bug 27768/0156835 - APD - 28/10/2013
   BEGIN
      vpasexec := 1;

      -- Bug 27768/0156835 - APD - 28/10/2013
      IF ptablas = 'EST' THEN
         BEGIN
            SELECT sproduc, fefecto, npoliza, ncertif
              INTO vsproduc, vfefecto, vnpoliza, vncertif
              FROM estseguros
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS THEN
               vsproduc := NULL;
         END;
      ELSE
         BEGIN
            SELECT sproduc, npoliza, ncertif
              INTO vsproduc, vnpoliza, vncertif
              FROM seguros
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS THEN
               vsproduc := NULL;
         END;
      END IF;

--Bug 27768/157944 - JSV - 06/11/2013
--      vnumerr := pac_preguntas.f_get_pregunpolseg(psseguro, 9107, ptablas, vcrespue);
      vnumerr := pac_preguntas.f_get_pregunseg(psseguro, pnriesgo, 9107, NVL(ptablas, 'POL'),
                                               vcrespue);

      -- Si el producto admite certificados y existe el 0 y no soy el 0, obtener
      -- la respuesta de la pregunta 9107 del certificado 0
      IF NVL(f_parproductos_v(vsproduc, 'ADMITE_CERTIFICADOS'), 0) = 1
         AND pac_seguros.f_get_escertifcero(vnpoliza) <> 0
         AND vncertif <> 0 THEN
         BEGIN
            SELECT sseguro
              INTO vsseguro_0
              FROM seguros
             WHERE npoliza = vnpoliza
               AND ncertif = 0;
         EXCEPTION
            WHEN OTHERS THEN
               vsseguro_0 := NULL;
         END;

--Bug 27768/157944 - JSV - 06/11/2013
         --vnumerr := pac_preguntas.f_get_pregunpolseg(vsseguro_0, 9107, 'POL', vcrespue_0);
         vnumerr := pac_preguntas.f_get_pregunseg(vsseguro_0, pnriesgo, 9107, 'POL',
                                                  vcrespue_0);
      END IF;

      -- fin Bug 27768/0156835 - APD - 28/10/2013

      -- Bug 27768/0156835 - APD - 28/10/2013
      -- Si se ha especificado en la pregunta que no
      -- debe aplicar plan de beneficios, la funcion debe devolver null
      IF NVL(vcrespue, 1) = 0
         OR NVL(vcrespue_0, 1) = 0 THEN
         vcplan := NULL;
      ELSE
         IF ptablas = 'EST' THEN
            BEGIN
               SELECT sproduc, fefecto
                 INTO vsproduc, vfefecto
                 FROM estseguros
                WHERE sseguro = psseguro;
            EXCEPTION
               WHEN OTHERS THEN
                  vsproduc := NULL;
            END;

            vnumerr := f_ultrenova(psseguro, TRUNC(f_sysdate), vfrenova, vnmovimi);

            IF vnumerr <> 0 THEN
               RAISE salir;
            END IF;

            -- Bug 26923/0146951 - APD - 18/06/2013 - si vfrenova es nula se le pasa la fefecto
            -- Bug 26923/0147980 - APD - 02/07/2013 - la antiguedad se busca a partir de la funcion
            -- tprefor de la pregunta automatica 4907
            BEGIN
               SELECT tprefor
                 INTO vtprefor
                 FROM pregunpro
                WHERE cpregun = 4907
                  AND sproduc = vsproduc;
            EXCEPTION
               WHEN OTHERS THEN
                  vtprefor := NULL;
            END;

            IF vtprefor IS NOT NULL THEN
               vnumerr := pac_albsgt.f_tprefor(vtprefor, ptablas, psseguro, pnriesgo,
                                               NVL(vfrenova, vfefecto), pnmovimi, 0,
                                               vantiguedad, vsproces, 1, 0);
/*
         vantiguedad := pac_planbenef.f_autos_antiguedad(ptablas, psseguro, pnriesgo,
                                                         NVL(vfrenova, vfefecto), pnmovimi,
                                                         NULL, NULL, NULL, NULL, 4907);
*/
            ELSE
               vantiguedad := 0;
            END IF;

            -- fin Bug 26923/0147980 - APD - 02/07/2013
            -- fin Bug 26923/0146951 - APD - 18/06/2013
            -- Bug 26923/0146951 - APD - 18/06/2013 - si vfrenova es nula se le pasa la fefecto
            vnsiniestros := pac_planbenef.f_autos_siniestros(ptablas, psseguro, pnriesgo,
                                                             NVL(vfrenova, vfefecto), pnmovimi,
                                                             NULL, NULL, NULL, NULL, 4926);

            -- fin Bug 26923/0146951 - APD - 18/06/2013
            BEGIN
               SELECT cagrtipo
                 INTO vcagrtipo
                 FROM estautriesgos r, aut_versiones v
                WHERE r.cversion = v.cversion
                  AND r.sseguro = psseguro
                  AND r.nriesgo = pnriesgo
                  AND r.nmovimi = pnmovimi;
            EXCEPTION
               WHEN OTHERS THEN
                  vcagrtipo := NULL;
            END;

            BEGIN
               SELECT anyo
                 INTO vanyo
                 FROM estautriesgos r
                WHERE r.sseguro = psseguro
                  AND r.nriesgo = pnriesgo
                  AND r.nmovimi = pnmovimi;
            EXCEPTION
               WHEN OTHERS THEN
                  vanyo := NULL;
            END;

            BEGIN
               SELECT d.cprovin, d.cpoblac
                 INTO vcdpto, vcciudad
                 FROM estautconductores c, estper_direcciones d
                WHERE c.sperson = d.sperson
                  AND c.cdomici = d.cdomici
                  AND c.sseguro = psseguro
                  AND c.nriesgo = pnriesgo
                  AND c.nmovimi = pnmovimi
                  AND c.cprincipal = 1;
            EXCEPTION
               WHEN OTHERS THEN
                  vcdpto := NULL;
                  vcciudad := NULL;
            END;
         ELSIF ptablas = 'CAR' THEN
            BEGIN
               SELECT sproduc
                 INTO vsproduc
                 FROM seguros
                WHERE sseguro = psseguro;
            EXCEPTION
               WHEN OTHERS THEN
                  vsproduc := NULL;
            END;

            vnumerr := f_ultrenova(psseguro, TRUNC(f_sysdate), vfrenova, vnmovimi);

            IF vnumerr <> 0 THEN
               RAISE salir;
            END IF;

            -- Bug 26923/0147980 - APD - 02/07/2013 - la antiguedad se busca a partir de la funcion
            -- tprefor de la pregunta automatica 4907
            BEGIN
               SELECT tprefor
                 INTO vtprefor
                 FROM pregunpro
                WHERE cpregun = 4907
                  AND sproduc = vsproduc;
            EXCEPTION
               WHEN OTHERS THEN
                  vtprefor := NULL;
            END;

            IF vtprefor IS NOT NULL THEN
               vnumerr := pac_albsgt.f_tprefor(vtprefor, ptablas, psseguro, pnriesgo,
                                               vfrenova, pnmovimi, 0, vantiguedad, vsproces,
                                               1, 0);
/*
         vantiguedad := pac_planbenef.f_autos_antiguedad(ptablas, psseguro, pnriesgo, vfrenova,
                                                         pnmovimi, NULL, NULL, NULL, NULL,
                                                         4907);
*/
            ELSE
               vantiguedad := 0;
            END IF;

            -- fin Bug 26923/0147980 - APD - 02/07/2013
            vnsiniestros := pac_planbenef.f_autos_siniestros(ptablas, psseguro, pnriesgo,
                                                             vfrenova, pnmovimi, NULL, NULL,
                                                             NULL, NULL, 4926);

            SELECT MAX(nmovimi)
              INTO vnmovimi
              FROM autriesgoscar
             WHERE sseguro = psseguro
               AND nriesgo = pnriesgo;

            BEGIN
               -- Bug 26638/160974 - 19/12/2013 - AMC
               SELECT cagrtipo
                 INTO vcagrtipo
                 FROM autriesgoscar r, aut_versiones v
                WHERE r.cversion = v.cversion
                  AND r.sseguro = psseguro
                  AND r.nriesgo = pnriesgo
                  AND r.nmovimi = NVL(pnmovimi, vnmovimi);
            EXCEPTION
               WHEN OTHERS THEN
                  vcagrtipo := NULL;
            END;

            BEGIN
               -- Bug 26638/160974 - 19/12/2013 - AMC
               SELECT anyo
                 INTO vanyo
                 FROM autriesgoscar r
                WHERE r.sseguro = psseguro
                  AND r.nriesgo = pnriesgo
                  AND r.nmovimi = NVL(pnmovimi, vnmovimi);
            EXCEPTION
               WHEN OTHERS THEN
                  vanyo := NULL;
            END;

            BEGIN
               SELECT d.cprovin, d.cpoblac
                 INTO vcdpto, vcciudad
                 FROM autconductores c, per_direcciones d
                WHERE c.sperson = d.sperson
                  AND c.cdomici = d.cdomici
                  AND c.sseguro = psseguro
                  AND c.nriesgo = pnriesgo
                  AND c.nmovimi = NVL(pnmovimi, vnmovimi)
                  AND c.cprincipal = 1;
            EXCEPTION
               WHEN OTHERS THEN
                  vcdpto := NULL;
                  vcciudad := NULL;
            END;
         ELSE
            BEGIN
               SELECT sproduc
                 INTO vsproduc
                 FROM seguros
                WHERE sseguro = psseguro;
            EXCEPTION
               WHEN OTHERS THEN
                  vsproduc := NULL;
            END;

            vnumerr := f_ultrenova(psseguro, TRUNC(f_sysdate), vfrenova, vnmovimi);

            IF vnumerr <> 0 THEN
               RAISE salir;
            END IF;

            -- Bug 26923/0147980 - APD - 02/07/2013 - la antiguedad se busca a partir de la funcion
            -- tprefor de la pregunta automatica 4907
            BEGIN
               SELECT tprefor
                 INTO vtprefor
                 FROM pregunpro
                WHERE cpregun = 4907
                  AND sproduc = vsproduc;
            EXCEPTION
               WHEN OTHERS THEN
                  vtprefor := NULL;
            END;

            IF vtprefor IS NOT NULL THEN
               vnumerr := pac_albsgt.f_tprefor(vtprefor, ptablas, psseguro, pnriesgo,
                                               vfrenova, pnmovimi, 0, vantiguedad, vsproces,
                                               1, 0);
/*
         vantiguedad := pac_planbenef.f_autos_antiguedad(ptablas, psseguro, pnriesgo, vfrenova,
                                                         pnmovimi, NULL, NULL, NULL, NULL,
                                                         4907);
*/
            ELSE
               vantiguedad := 0;
            END IF;

            -- fin Bug 26923/0147980 - APD - 02/07/2013
            vnsiniestros := pac_planbenef.f_autos_siniestros(ptablas, psseguro, pnriesgo,
                                                             vfrenova, pnmovimi, NULL, NULL,
                                                             NULL, NULL, 4926);

            BEGIN
               SELECT cagrtipo
                 INTO vcagrtipo
                 FROM autriesgos r, aut_versiones v
                WHERE r.cversion = v.cversion
                  AND r.sseguro = psseguro
                  AND r.nriesgo = pnriesgo
                  AND r.nmovimi = pnmovimi;
            EXCEPTION
               WHEN OTHERS THEN
                  vcagrtipo := NULL;
            END;

            BEGIN
               SELECT anyo
                 INTO vanyo
                 FROM autriesgos r
                WHERE r.sseguro = psseguro
                  AND r.nriesgo = pnriesgo
                  AND r.nmovimi = pnmovimi;
            EXCEPTION
               WHEN OTHERS THEN
                  vanyo := NULL;
            END;

            BEGIN
               SELECT d.cprovin, d.cpoblac
                 INTO vcdpto, vcciudad
                 FROM autconductores c, per_direcciones d
                WHERE c.sperson = d.sperson
                  AND c.cdomici = d.cdomici
                  AND c.sseguro = psseguro
                  AND c.nriesgo = pnriesgo
                  AND c.nmovimi = pnmovimi
                  AND c.cprincipal = 1;
            EXCEPTION
               WHEN OTHERS THEN
                  vcdpto := NULL;
                  vcciudad := NULL;
            END;
         END IF;

         IF vcagrtipo IS NOT NULL THEN
            BEGIN
               SELECT cagrtiponum
                 INTO vcagrtiponum
                 FROM aut_codagrtipo
                WHERE cagrtipo = vcagrtipo;
            EXCEPTION
               WHEN OTHERS THEN
                  vcagrtiponum := NULL;
            END;
         END IF;

         /* bug 26737/142770 - 02/05/2013 - AMC
         IF vsproduc = 6031 THEN
            vcsubtabla := 60318000;
         END IF; */

         -- Bug 27652 - APD - 16/07/2013
         vcsubtabla_esp := NVL(pac_parametros.f_parproducto_n(vsproduc, 'PLANBENEFICIOS_ESP'),
                               -1);
         -- fin Bug 27652 - APD - 16/07/2013
         vcsubtabla := NVL(pac_parametros.f_parproducto_n(vsproduc, 'PLANBENEFICIOS'), -1);

         -- Fi bug 26737/142770 - 02/05/2013 - AMC

         -- Bug 27652 - APD - 16/07/2013 - primero se busca a nivel de Especiales
         IF vcsubtabla_esp <> -1 THEN
            -- sgt_subtabs_det.ccla1 = vantiguedad
            -- sgt_subtabs_det.ccla2 >= vnsiniestros
            -- sgt_subtabs_det.ccla3 = vcdpto
            -- sgt_subtabs_det.ccla4 = vcciudad
            -- sgt_subtabs_det.ccla5 = vcagrtiponum
            -- sgt_subtabs_det.ccla6 <= vanyo
            --IF vcsubtabla <> -1 THEN
            -- Bug 32009/0181425 - APD - 05/09/2014 - para Especiales se debe acceder a la antigüedad por
            -- igualdad, ya que la idea es que si no encuentra registros en la tabla de especiales se
            -- busque el plan en la tabla de generales
            vcplan := pac_subtablas.f_vsubtabla(-1, vcsubtabla_esp, '343332', 1,
                                                NVL(vantiguedad, 0), vnsiniestros, vcdpto,
                                                vcciudad, vcagrtiponum, vanyo);
            -- fin Bug 32009/0181425 - APD - 05/09/2014
         --END IF;
         END IF;

         -- fin Bug 27652 - APD - 16/07/2013

         -- Bug 27652 - APD - 16/07/2013 - si el plan es null se debe es porque o no hay
         -- parproducto a nivel de especiales o no hay parametrizacion en la subtabla
         IF vcplan IS NULL THEN
            -- fin Bug 27652 - APD - 16/07/2013
               -- sgt_subtabs_det.ccla1 <= vantiguedad
               -- sgt_subtabs_det.ccla2 >= vnsiniestros
               -- sgt_subtabs_det.ccla3 = vcagrtiponum
               -- sgt_subtabs_det.ccla4 <= vanyo
            IF vcsubtabla <> -1 THEN
               vcplan := pac_subtablas.f_vsubtabla(-1, vcsubtabla, '2432', 1,
                                                   NVL(vantiguedad, 0), vnsiniestros,
                                                   vcagrtiponum, vanyo);
            END IF;
         END IF;
      END IF;   -- fin Bug 27768/0156835 - APD - 28/10/2013

      RETURN vcplan;
   EXCEPTION
      WHEN salir THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     f_axis_literales(vnumerr));
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN NULL;
   END f_get_planbenef;

   /*************************************************************************
      FUNCTION f_garant_planbenef
         Función que indica si una garantia pertenece a un plan de beneficio
         param in pcempres : Codigo de empresa
         param in pcplan : Codigo del plan de beneficio
         param in pcaccion : Acción sobre la que se aplica el descuento del plan (v.f. 1130)
         param in cgarant : Codigo de garantia
         return             : 0 -> La garantia no pertenece al plan de beneficio
                              1 -> La garantia si pertenece al plan de beneficio
                              num_err -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_garant_planbenef(
      pcempres IN NUMBER,
      pcplan IN NUMBER,
      pcaccion IN NUMBER,
      pcgarant IN NUMBER)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_planbenef.f_garant_planbenef';
      vparam         VARCHAR2(500)
         := 'parámetros - pcempres: ' || pcempres || ' - pcplan: ' || pcplan
            || ' - pcaccion: ' || pcaccion || ' - pcgarant: ' || pcgarant;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vcont          NUMBER;
   BEGIN
      vpasexec := 1;

      SELECT COUNT(1)
        INTO vcont
        FROM codplanbenef
       WHERE cempres = pcempres
         AND cplan = pcplan
         AND caccion = pcaccion
         AND cgarant = pcgarant;

      IF vcont <> 0 THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 140999;   --Error no controlado
   END f_garant_planbenef;

   /*************************************************************************
      FUNCTION f_capital_planbenef
         Función que devuelve el capital de una garantia de un plan de beneficio
         param in pcempres : Codigo de empresa
         param in pcplan : Codigo del plan de beneficio
         param in pcaccion : Acción sobre la que se aplica el descuento del plan (v.f. 1130)
         param in cgarant : Codigo de garantia
         return             : Capital de la garantia
   *************************************************************************/
   FUNCTION f_capital_planbenef(
      pcempres IN NUMBER,
      pcplan IN NUMBER,
      pcaccion IN NUMBER,
      pcgarant IN NUMBER)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_planbenef.f_capital_planbenef';
      vparam         VARCHAR2(500)
         := 'parámetros - pcempres: ' || pcempres || ' - pcplan: ' || pcplan
            || ' - pcaccion: ' || pcaccion || ' - pcgarant: ' || pcgarant;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vnvalor        codplanbenef.nvalor%TYPE;
   BEGIN
      vpasexec := 1;

      SELECT nvalor
        INTO vnvalor
        FROM codplanbenef
       WHERE cempres = pcempres
         AND cplan = pcplan
         AND caccion = pcaccion
         AND cgarant = pcgarant;

      RETURN vnvalor;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN NULL;
   END f_capital_planbenef;

   -- Bug 26638/160974 - 19/12/2013 - AMC
   FUNCTION f_set_planbeneficios(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      psproces IN NUMBER,
      ptablas IN VARCHAR2)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_planbenef.f_set_planBeneficios';
      vparam         VARCHAR2(500)
         := 'parámetros - psseguro: ' || psseguro || ' - pnriesgo: ' || pnriesgo
            || ' - pnmovimi: ' || pnmovimi || ' - psproces:' || psproces || ' - ptablas:'
            || ptablas;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vcplan         NUMBER;
      vcount         NUMBER;
      vcrespue       NUMBER;
      vfiniefe       DATE;
      vcmodali       NUMBER;
      vccolect       NUMBER;
      vcramo         NUMBER;
      vctipseg       NUMBER;
      vcactivi       NUMBER;
      --   vcrevali       NUMBER;
      --   vprevali       NUMBER;
      vicapital      NUMBER;
      --  vicapmax       NUMBER;
      vsproduc       NUMBER;
      vcempres       NUMBER;
      vnmovimi       NUMBER;
      vfcarpro       DATE;
      vnorden        garanpro.norden%TYPE;
      vctipgar       garanpro.ctipgar%TYPE;
      vctipcap       garanpro.ctipcap%TYPE;
      vctiptar       garanpro.ctiptar%TYPE;
      vcgardep       garanpro.cgardep%TYPE;
      vcpardep       garanpro.cpardep%TYPE;
      vpcapdep       garanpro.pcapdep%TYPE;
      vicapmax       garanpro.icapmax%TYPE;
      vicapmin       garanpro.icapmin%TYPE;
      vcformul       garanpro.cformul%TYPE;
      vcrevali       garanpro.crevali%TYPE;
      virevali       garanpro.irevali%TYPE;
      vprevali       garanpro.prevali%TYPE;
      vicaprev       garanpro.icaprev%TYPE;
      vcmodtar       garanpro.cmodtar%TYPE;
      vcextrap       garanpro.cextrap%TYPE;
      vcrecarg       garanpro.crecarg%TYPE;
      vcmodrev       garanpro.cmodrev%TYPE;
      vcdtocom       garanpro.cdtocom%TYPE;
      vcimpcon       garanpro.cimpcon%TYPE;
      vcimpdgs       garanpro.cimpdgs%TYPE;
      vcimpips       garanpro.cimpips%TYPE;
      vcimpfng       garanpro.cimpfng%TYPE;
      vcimparb       garanpro.cimparb%TYPE;
      vcreaseg       garanpro.creaseg%TYPE;
      vcderreg       garanpro.cderreg%TYPE;
      vcdetalle      garanpro.cdetalle%TYPE;
      vcmoncap       garanpro.cmoncap%TYPE;
      vcclacap       garanpro.cclacap%TYPE;
      vcclamin       garanpro.cclamin%TYPE;
      vcvisniv       garanpro.cvisniv%TYPE;
      vcgarpadre     garanpro.cgarpadre%TYPE;
      vctarifa       garanpro.ctarifa%TYPE;
      vctarman       garanpro.ctarman%TYPE;
   BEGIN
      IF ptablas = 'CAR' THEN
         vcplan := pac_planbenef.f_get_planbenef('CAR', psseguro, pnriesgo, pnmovimi);

         IF vcplan IS NOT NULL THEN
            SELECT cempres
              INTO vcempres
              FROM seguros
             WHERE sseguro = psseguro;

            SELECT MAX(nmovimi)
              INTO vnmovimi
              FROM garanseg
             WHERE sseguro = psseguro
               AND nriesgo = pnriesgo;

            FOR c IN (SELECT cgarant
                        FROM codplanbenef
                       WHERE cplan = vcplan
                         AND caccion = 1
                         AND cempres = vcempres) LOOP
               -- Bug 34371/196553 - 28/01/2015 - AMC
               /* SELECT COUNT(1)
                  INTO vcount
                  FROM tmp_garancar
                 WHERE cgarant = c.cgarant
                   AND nriesgo = pnriesgo
                   AND sseguro = psseguro;

                IF vcount = 0 THEN*/
               SELECT fefecto, cmodali, ccolect, cramo, ctipseg, cactivi, sproduc,
                      fcarpro, prevali, ctarman
                 INTO vfiniefe, vcmodali, vccolect, vcramo, vctipseg, vcactivi, vsproduc,
                      vfcarpro, vprevali, vctarman
                 FROM seguros
                WHERE sseguro = psseguro;

               SELECT norden, ctipgar, ctipcap, ctiptar, cgardep, cpardep, pcapdep,
                      icapmax, icapmin, cformul, crevali, irevali, icaprev, cmodtar,
                      cextrap, crecarg, cmodrev, cdtocom, cimpcon, cimpdgs, cimpips,
                      cimpfng, cimparb, creaseg, cderreg, cdetalle, cmoncap, cclacap,
                      cclamin, cvisniv, cgarpadre
                 INTO vnorden, vctipgar, vctipcap, vctiptar, vcgardep, vcpardep, vpcapdep,
                      vicapmax, vicapmin, vcformul, vcrevali, virevali, vicaprev, vcmodtar,
                      vcextrap, vcrecarg, vcmodrev, vcdtocom, vcimpcon, vcimpdgs, vcimpips,
                      vcimpfng, vcimparb, vcreaseg, vcderreg, vcdetalle, vcmoncap, vcclacap,
                      vcclamin, vcvisniv, vcgarpadre
                 FROM garanpro
                WHERE cmodali = vcmodali
                  AND ccolect = vccolect
                  AND cramo = vcramo
                  AND cgarant = c.cgarant
                  AND ctipseg = vctipseg
                  AND cactivi = vcactivi;

               IF vctipcap = 1 THEN
                  vicapital := vicapmax;
               ELSIF vctipcap = 2 THEN
                  vicapital := pac_parametros.f_pargaranpro_n(vsproduc, vcactivi, c.cgarant,
                                                              'VALORDEFCAPITALGARAN');
               ELSIF vctipcap = 7 THEN
                  IF vcplan IS NOT NULL THEN
                     vicapital := pac_planbenef.f_capital_planbenef(vcempres, vcplan, 2,
                                                                    c.cgarant);
                  END IF;

                  IF vicapital IS NULL THEN
                     -- indica que el capital es fitxe i sha de mostrar el valor del capital
                     BEGIN
                        SELECT icapital
                          INTO vicapital
                          FROM garanprocap
                         WHERE cramo = vcramo
                           AND cmodali = vcmodali
                           AND ctipseg = vctipseg
                           AND ccolect = vccolect
                           AND cgarant = c.cgarant
                           AND cdefecto = 1;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           BEGIN
                              SELECT icapital
                                INTO vicapital
                                FROM garanprocap g
                               WHERE cramo = vcramo
                                 AND cmodali = vcmodali
                                 AND ctipseg = vctipseg
                                 AND ccolect = vccolect
                                 AND cgarant = c.cgarant
                                 AND norden = (SELECT MIN(g2.norden)
                                                 FROM garanprocap g2
                                                WHERE g.cramo = g2.cramo
                                                  AND g.cmodali = g2.cmodali
                                                  AND g.ctipseg = g2.ctipseg
                                                  AND g.ccolect = g2.ccolect
                                                  AND g.cgarant = g2.cgarant);
                           EXCEPTION
                              WHEN OTHERS THEN
                                 vicapital := 0;
                           END;
                        WHEN OTHERS THEN
                           vicapital := 0;
                     END;
                  END IF;
               END IF;

               BEGIN
                  INSERT INTO tmp_garancar
                              (sseguro, cgarant, nriesgo, finiefe, norden, ctarifa,
                               icapital, cformul, sproces, crevali, prevali, irevali,
                               cderreg, nmovima, nmovi_ant,
                               ftarifa, ctarman)
                       VALUES (psseguro, c.cgarant, pnriesgo, vfiniefe, vnorden, vctarifa,
                               vicapital, vcformul, psproces, vcrevali, vprevali, virevali,
                               vcderreg, NVL(pnmovimi, vnmovimi), NVL(pnmovimi, vnmovimi),
                               vfcarpro, vctarman);
               EXCEPTION
                  WHEN DUP_VAL_ON_INDEX THEN
                     NULL;
               END;

               BEGIN
                  INSERT INTO garanseg_aux
                              (cgarant, nriesgo, nmovimi, sseguro,
                               finiefe, norden, icapital, icaptot, ctarman, prevali,
                               ftarifa, crevali, precarg, iextrap, iprianu, ifranqu, irecarg,
                               ipritar, pdtocom, idtocom, itarifa, ipritot, pdtotec, preccom,
                               idtotec, ireccom)
                       VALUES (c.cgarant, pnriesgo, NVL(pnmovimi, vnmovimi), psseguro,
                               vfiniefe, vnorden, vicapital, vicapital, vctarman, vprevali,
                               vfcarpro, 0, 0, 0, 0, 0, 0,
                               0, 0, 0, 0, 0, 0, 0,
                               0, 0);
               EXCEPTION
                  WHEN DUP_VAL_ON_INDEX THEN
                     NULL;
               END;

               BEGIN
                  INSERT INTO pregungarancar
                              (sseguro, nriesgo, cgarant, nmovimi, cpregun,
                               sproces, crespue, nmovima, finiefe)
                       VALUES (psseguro, pnriesgo, c.cgarant, NVL(pnmovimi, vnmovimi), 4940,
                               psproces, 1, NVL(pnmovimi, vnmovimi), vfiniefe);
               EXCEPTION
                  WHEN DUP_VAL_ON_INDEX THEN
                     UPDATE pregungarancar
                        SET crespue = 1
                      WHERE cgarant = c.cgarant
                        AND nriesgo = pnriesgo
                        AND nmovimi = NVL(pnmovimi, vnmovimi)
                        AND sseguro = psseguro
                        AND cpregun = 4940
                        AND sproces = psproces;
               END;
            --END IF;
            -- Fi Bug 34371/196553 - 28/01/2015 - AMC
            END LOOP;
         ELSE
            FOR c IN (SELECT cgarant
                        FROM codplanbenef
                       WHERE cplan = vcplan
                         AND caccion = 1
                         AND cempres = vcempres) LOOP
               SELECT crespue
                 INTO vcrespue
                 FROM pregungarancar
                WHERE cgarant = c.cgarant
                  AND nriesgo = pnriesgo
                  AND nmovimi = pnmovimi
                  AND sseguro = psseguro
                  AND cpregun = 4940
                  AND sproces = psproces;

               SELECT MAX(nmovimi)
                 INTO vnmovimi
                 FROM garanseg
                WHERE sseguro = psseguro
                  AND nriesgo = pnriesgo
                  AND cgarant = c.cgarant;

               IF vcrespue = 1 THEN
                  UPDATE pregungarancar
                     SET crespue = 0
                   WHERE cgarant = c.cgarant
                     AND nriesgo = pnriesgo
                     AND nmovimi = NVL(pnmovimi, vnmovimi)
                     AND sseguro = psseguro
                     AND cpregun = 4940
                     AND sproces = psproces;
               END IF;
            END LOOP;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_set_planbeneficios;
END pac_planbenef;

/

  GRANT EXECUTE ON "AXIS"."PAC_PLANBENEF" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PLANBENEF" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PLANBENEF" TO "PROGRAMADORESCSI";
