--------------------------------------------------------
--  DDL for Package Body PAC_TFV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_TFV" AS
/******************************************************************************
   NOMBRE:     PAC_TFV
   PROPÓSITO:

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        10/07/2009   DCT                1. 0010612: CRE - Error en la generació de pagaments automàtics.
                                                 Canviar vista personas por tablas personas y anadir filtro de visión de agente
   2.0        03/11/2009   APD                2. 0011595: CEM - Siniestros. Adaptación al nuevo módulo de siniestros
   3.0        27/05/2010   DRA                3. 0011288: CRE - Modificación de propuestas retenidas
******************************************************************************/
-----------------------------------------------------------------------------
-- VARIABLES PRIVADAS
-----------------------------------------------------------------------------
   vn_ok_code     NUMBER := 0;
   vn_dup_ind     NUMBER := -1;   -- ORA-00001: restricción única (.) violada

  -----------------------------------------------------------------------------
  -- CUERPOS PRIVADOS
  -----------------------------------------------------------------------------
---- 24/11/2003.Funcion que inserta datos en la tabla ESTSEGUROS
---- 08/01/2004. Si ya están insertados los actualiza
   FUNCTION f_insert_estseguros(
      psseguro IN NUMBER,
      pssegpol IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pnsuplem IN NUMBER,
      pcempres IN NUMBER,
      pcagrpro IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pcobjase IN NUMBER,
      pctarman IN NUMBER,
      pfefecto IN DATE,
      pcrecman IN NUMBER,
      pcsituac IN NUMBER,
      pnanuali IN NUMBER,
      pcreafac IN NUMBER,
      pctiprea IN NUMBER,
      pcasegur IN NUMBER,
      pcagente IN NUMBER,
      pctipreb IN NUMBER,
      pcactivi IN NUMBER,
      psproduc IN NUMBER,
      pnrenova IN NUMBER)
      RETURN NUMBER IS
   BEGIN
      INSERT INTO estseguros
                  (sseguro, ssegpol, cramo, cmodali, ctipseg, ccolect, nsuplem,
                   cempres, cagrpro, npoliza, ncertif, cobjase, ctarman, fefecto,
                   crecman, csituac, nanuali, creafac, ctiprea, casegur, cagente,
                   ctipreb, cactivi, sproduc, nrenova)
           VALUES (psseguro, pssegpol, pcramo, pcmodali, pctipseg, pccolect, pnsuplem,
                   pcempres, pcagrpro, pnpoliza, pncertif, pcobjase, pctarman, pfefecto,
                   pcrecman, pcsituac, pnanuali, pcreafac, pctiprea, pcasegur, pcagente,
                   pctipreb, pcactivi, psproduc, pnrenova);

      RETURN vn_ok_code;
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         BEGIN
            UPDATE estseguros
               SET ssegpol = pssegpol,
                   cramo = pcramo,
                   cmodali = pcmodali,
                   ctipseg = pctipseg,
                   ccolect = pccolect,
                   nsuplem = pnsuplem,
                   cempres = pcempres,
                   cagrpro = pcagrpro,
                   npoliza = pnpoliza,
                   ncertif = pncertif,
                   cobjase = pcobjase,
                   ctarman = pctarman,
                   fefecto = pfefecto,
                   crecman = pcrecman,
                   csituac = pcsituac,
                   nanuali = pnanuali,
                   creafac = pcreafac,
                   ctiprea = pctiprea,
                   casegur = pcasegur,
                   cagente = pcagente,
                   ctipreb = pctipreb,
                   cactivi = pcactivi,
                   sproduc = psproduc,
                   nrenova = pnrenova
             WHERE sseguro = psseguro;

            RETURN vn_ok_code;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 103865;
         END;
      WHEN OTHERS THEN
         RETURN 108468;   --Error al insertar
   END f_insert_estseguros;

----------------------------------------------------------------------------
----24/11/2003.Funcion que inserta datos en la tabla ESTTOMADORES
---- 08/01/2004. Si ya están insertados los actualiza
----------------------------------------------------------------------------
   FUNCTION f_insert_esttomadores(
      pnordtom IN NUMBER,
      psperson IN NUMBER,
      pcdomici IN NUMBER,
      psseguro IN NUMBER)
      RETURN NUMBER IS
   BEGIN
      INSERT INTO esttomadores
                  (nordtom, sperson, cdomici, sseguro)
           VALUES (pnordtom, psperson, pcdomici, psseguro);

      RETURN vn_ok_code;
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         BEGIN
            UPDATE esttomadores
               SET sperson = psperson,
                   cdomici = pcdomici
             WHERE sseguro = psseguro
               AND nordtom = pnordtom;

            RETURN vn_ok_code;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 103865;
         END;
      WHEN OTHERS THEN
         RETURN 108468;   --Error al insertar
   END f_insert_esttomadores;

----------------------------------------------------------------------------
---- 24/11/2003.Funcion que inserta datos en la tabla ESTASEGURATS
---- 08/01/2004. Si ya están insertados los actualiza
----------------------------------------------------------------------------
   FUNCTION f_insert_estassegurats(
      psseguro IN NUMBER,
      psperson IN NUMBER,
      pnorden IN NUMBER,
      pcdomici IN NUMBER,
      pffecini IN DATE)
      RETURN NUMBER IS
   BEGIN
      INSERT INTO estassegurats
                  (sseguro, sperson, norden, cdomici, ffecini)
           VALUES (psseguro, psperson, pnorden, pcdomici, pffecini);

      RETURN vn_ok_code;
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         BEGIN
            UPDATE estassegurats
               SET norden = pnorden,
                   cdomici = pcdomici,
                   ffecini = pffecini
             WHERE sseguro = psseguro
               AND sperson = psperson;

            RETURN vn_ok_code;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 103865;
         END;
      WHEN OTHERS THEN
         RETURN 108468;   --Error al insertar
   END f_insert_estassegurats;

----------------------------------------------------------------------------
---- 24/11/2003.Funcion que actualiza datos en la tabla ESTSEGUROS
----------------------------------------------------------------------------
   FUNCTION f_update_estseguros(
      pcasegur IN NUMBER,
      pcactivi IN NUMBER,
      pcidioma IN NUMBER,
      pfefecto IN DATE,
      pcagente IN NUMBER,
      pctipcom IN NUMBER,
      pcforpag IN NUMBER,
      pnfracci IN NUMBER,
      pcduraci IN NUMBER,
      pcreccob IN NUMBER,
      pctipreb IN NUMBER,
      pcreteni IN NUMBER,
      pcbancar IN VARCHAR2,
      pccobban IN NUMBER,
      pccompani IN NUMBER,
      pcagencorr IN VARCHAR2,
      pnpolcoa IN VARCHAR2,
      pnrenova IN NUMBER,
      pcrecfra IN NUMBER,
      pcrevali IN NUMBER,
      psseguro IN NUMBER,
      pctipban IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
   BEGIN
      UPDATE estseguros
         SET casegur = pcasegur,
             cactivi = pcactivi,
             cidioma = pcidioma,
             fefecto = pfefecto,
             cagente = pcagente,
             ctipcom = pctipcom,
             cforpag = pcforpag,
             nfracci = pnfracci,
             cduraci = pcduraci,
             creccob = pcreccob,
             ctipreb = pctipreb,
             creteni = pcreteni,
             cbancar = pcbancar,
             ccobban = pccobban,
             ccompani = pccompani,
             cagencorr = pcagencorr,
             npolcoa = pnpolcoa,
             nrenova = pnrenova,
             crecfra = pcrecfra,
             crevali = pcrevali,
             ctipban = pctipban
       WHERE sseguro = psseguro;

      RETURN vn_ok_code;
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         RETURN vn_dup_ind;
      WHEN OTHERS THEN
         RETURN 108469;   --Error al actualizar
   END f_update_estseguros;

----------------------------------------------------------------------------
---- 24/11/2003.Funcion que inserta datos en la tabla ESTRIESGOS
---- 08/01/2004. Si ya están insertados los actualiza
----------------------------------------------------------------------------
   FUNCTION f_insert_estriesgos(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovima IN NUMBER,
      pfefecto IN DATE,
      ptnatrie IN VARCHAR2,
      psperson IN NUMBER,
      pcdomici IN NUMBER,
      pspermin IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
   BEGIN
      INSERT INTO estriesgos
                  (sseguro, nriesgo, nmovima, fefecto, tnatrie, sperson, cdomici,
                   spermin)
           VALUES (psseguro, pnriesgo, pnmovima, pfefecto, ptnatrie, psperson, pcdomici,
                   pspermin);

      RETURN vn_ok_code;
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         BEGIN
            UPDATE estriesgos
               SET nmovima = pnmovima,
                   fefecto = pfefecto,
                   tnatrie = ptnatrie,
                   cdomici = pcdomici,
                   sperson = psperson,
                   spermin = pspermin
             WHERE sseguro = psseguro
               AND nriesgo = pnriesgo;

            RETURN vn_ok_code;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 103865;
         END;
      WHEN OTHERS THEN
         RETURN 108468;   --Error al insertar
   END f_insert_estriesgos;

----------------------------------------------------------------------------
---- 24/11/2003.Funcion que inserta datos en la tabla ESTSITRIESGO
---- 08/01/2004. Si ya están insertados los actualiza

   -- Bug 12668 - 17/02/2010 - AMC - Se anaden los campos para la normalización de la dirección
----------------------------------------------------------------------------
   FUNCTION f_insert_estsitriesgo(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      ptdomici IN VARCHAR2,
      pcprovin IN NUMBER,
      pcpostal IN codpostal.cpostal%TYPE,   --3606 jdomingo 29/11/2007  canvi format codi postal
      pcpoblac IN NUMBER,
      pcsiglas IN NUMBER,
      ptnomvia IN VARCHAR2,
      pnnumvia IN NUMBER,
      ptcomple IN VARCHAR2,
      pcciudad IN NUMBER,
      pfgisx IN FLOAT,
      pfgisy IN FLOAT,
      pfgisz IN FLOAT,
      pcvalida IN NUMBER)
      RETURN NUMBER IS
   BEGIN
      INSERT INTO estsitriesgo
                  (sseguro, nriesgo, tdomici, cprovin, cpostal, cpoblac, csiglas,
                   tnomvia, nnumvia, tcomple, cciudad, fgisx, fgisy, fgisz, cvalida)
           VALUES (psseguro, pnriesgo, ptdomici, pcprovin, pcpostal, pcpoblac, pcsiglas,
                   ptnomvia, pnnumvia, ptcomple, pcciudad, pfgisx, pfgisy, pfgisz, pcvalida);

      RETURN vn_ok_code;
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         BEGIN
            UPDATE estsitriesgo
               SET tdomici = ptdomici,
                   cprovin = pcprovin,
                   cpostal = pcpostal,
                   cpoblac = pcpoblac,
                   csiglas = pcsiglas,
                   tnomvia = ptnomvia,
                   nnumvia = pnnumvia,
                   tcomple = ptcomple,
                   cciudad = pcciudad,
                   fgisx = pfgisx,
                   fgisy = pfgisy,
                   fgisz = pfgisz,
                   cvalida = pcvalida
             WHERE sseguro = psseguro
               AND nriesgo = pnriesgo;

            RETURN vn_ok_code;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 103865;
         END;
      WHEN OTHERS THEN
         RETURN 108468;   --Error al insertar
   END f_insert_estsitriesgo;

----------------------------------------------------------------------------
---- 24/11/2003.Funcion que inserta datos en la tabla ESTPREGUNSEG
---- 08/01/2004. Si ya están insertados los actualiza
----------------------------------------------------------------------------
   FUNCTION f_insert_estpregunseg(
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pcactivi IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pcpregun IN NUMBER,
      pcrespue IN FLOAT,
      ptrespue IN VARCHAR2)
      RETURN NUMBER IS
      vcpregun       NUMBER;
   BEGIN
      -- O esta en preguntas actividad o bien en preguntas producto
      -- SELECT *
      -- INTO  vcpregun
      -- FROM  (
      --       SELECT
      --             cpregun
      --       FROM  pregunpro
      --       WHERE cramo    = pcramo
      --       AND   cmodali  = pcmodali
      --       AND   ccolect  = pccolect
      --       AND   ctipseg  = pctipseg
      --       AND   cpretip  = 2
      --          UNION
      --       SELECT
      --             cpregun
      --       FROM  pregunproactivi
      --       WHERE cramo    = pcramo
      --       AND   cmodali  = pcmodali
      --       AND   ccolect  = pccolect
      --       AND   ctipseg  = pctipseg
      --       AND   cactivi  = NVL(pcactivi,0)
      --       AND   cpretip  = 2
      --       );
      INSERT INTO estpregunseg
                  (sseguro, nriesgo, nmovimi, cpregun, crespue, trespue)
           VALUES (psseguro, pnriesgo, pnmovimi, pcpregun, pcrespue, ptrespue);

      RETURN vn_ok_code;
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         BEGIN
            UPDATE estpregunseg
               SET crespue = pcrespue,
                   trespue = ptrespue
             WHERE sseguro = psseguro
               AND nriesgo = pnriesgo
               AND nmovimi = pnmovimi
               AND cpregun = pcpregun;

            RETURN vn_ok_code;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 103865;
         END;
      WHEN OTHERS THEN
         RETURN 108468;   --Error al insertar
   END f_insert_estpregunseg;

----------------------------------------------------------------------------
---- 24/11/2003.Funcion que inserta datos en la tabla ESTGARANSEG
---- 08/01/2004. Si ya están insertados los actualiza
----------------------------------------------------------------------------
   FUNCTION f_insert_estgaranseg(
      pcgarant IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      psseguro IN NUMBER,
      pfiniefe IN DATE,
      pnorden IN NUMBER,
      pcrevali IN NUMBER,
      picapital IN NUMBER,
      piprianu IN NUMBER,
      pipritar IN NUMBER,
      pftarifa IN DATE,
      pitarifa IN NUMBER)
      RETURN NUMBER IS
   BEGIN
      INSERT INTO estgaranseg
                  (cgarant, nriesgo, nmovimi, sseguro, finiefe, norden, crevali,
                   icapital, iprianu, ipritar, ftarifa, itarifa, ipritot, icaptot)
           VALUES (pcgarant, pnriesgo, pnmovimi, psseguro, pfiniefe, pnorden, pcrevali,
                   picapital, piprianu, pipritar, pftarifa, pitarifa, piprianu, picapital);

      RETURN vn_ok_code;
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         BEGIN
            UPDATE estgaranseg
               SET norden = pnorden,
                   crevali = pcrevali,
                   icapital = picapital,
                   iprianu = piprianu,
                   ipritar = pipritar,
                   ftarifa = pftarifa,
                   itarifa = pitarifa,
                   ipritot = piprianu,
                   icaptot = picapital
             WHERE cgarant = pcgarant
               AND nriesgo = pnriesgo
               AND nmovimi = pnmovimi
               AND sseguro = psseguro
               AND finiefe = pfiniefe;

            RETURN vn_ok_code;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 103865;
         END;
      WHEN OTHERS THEN
         RETURN 108468;   --Error al insertar
   END f_insert_estgaranseg;

----------------------------------------------------------------------------

   ----------------------------------------------------------------------------
---- 24/11/2003.Funcion que inserta datos en la tabla ESTCLAUBENSEG
---- 08/01/2004. Si ya están insertados los actualiza
----------------------------------------------------------------------------
   FUNCTION f_insert_estclaubenseg(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      psclaben IN NUMBER,
      pfiniclau IN DATE)
      RETURN NUMBER IS
   BEGIN
      INSERT INTO estclaubenseg
                  (sseguro, nriesgo, nmovimi, sclaben, finiclau)
           VALUES (psseguro, pnriesgo, pnmovimi, psclaben, pfiniclau);

      RETURN vn_ok_code;
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         BEGIN
            UPDATE estclaubenseg
               SET finiclau = pfiniclau
             WHERE sseguro = psseguro
               AND nriesgo = pnriesgo
               AND nmovimi = pnmovimi
               AND sclaben = psclaben;

            RETURN vn_ok_code;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 103865;
         END;
      WHEN OTHERS THEN
         RETURN 108468;   --Error al insertar
   END f_insert_estclaubenseg;

----------------------------------------------------------------------------
---- 24/11/2003.Funcion que inserta datos en la tabla ESTCLAUSUSEG
---- 08/01/2004. Si ya están insertados los actualiza
----------------------------------------------------------------------------
   FUNCTION f_insert_estclaususeg(
      psseguro IN NUMBER,
      psclagen IN NUMBER,
      pfiniclau IN DATE,
      pffinclau IN DATE,
      pnmovimi IN NUMBER)
      RETURN NUMBER IS
   BEGIN
      INSERT INTO estclaususeg
                  (sseguro, sclagen, finiclau, ffinclau, nmovimi)
           VALUES (psseguro, psclagen, pfiniclau, pffinclau, pnmovimi);

      RETURN vn_ok_code;
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         BEGIN
            UPDATE estclaususeg
               SET finiclau = pfiniclau,
                   ffinclau = pffinclau
             WHERE sseguro = psseguro
               AND sclagen = psclagen
               AND nmovimi = pnmovimi;

            RETURN vn_ok_code;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 103865;
         END;
      WHEN OTHERS THEN
         RETURN 108468;   --Error al insertar
   END f_insert_estclaususeg;

----------------------------------------------------------------------------
---- 24/11/2003.Funcion que inserta datos en la tabla ESTCLAUSUESP
---- 08/01/2004. Si ya están insertados los actualiza
----------------------------------------------------------------------------
   FUNCTION f_insert_estclausuesp(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pcclaesp IN NUMBER,
      pnordcla IN NUMBER,
      pfiniclau IN DATE,
      psclagen IN NUMBER,
      ptclaesp IN VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      INSERT INTO estclausuesp
                  (sseguro, nriesgo, nmovimi, cclaesp, nordcla, finiclau, sclagen,
                   tclaesp)
           VALUES (psseguro, pnriesgo, pnmovimi, pcclaesp, pnordcla, pfiniclau, psclagen,
                   ptclaesp);

      RETURN vn_ok_code;
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         BEGIN
            UPDATE estclausuesp
               SET finiclau = pfiniclau,
                   sclagen = psclagen,
                   tclaesp = ptclaesp
             WHERE sseguro = psseguro
               AND nriesgo = pnriesgo
               AND nmovimi = pnmovimi
               AND cclaesp = pcclaesp
               AND nordcla = pnordcla;

            RETURN vn_ok_code;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 103865;
         END;
      WHEN OTHERS THEN
         RETURN 108468;   --Error al insertar
   END f_insert_estclausuesp;

----------------------------------------------------------------------------
---- 24/11/2003.Funcion que inserta datos en la tabla ESTCLAUPARESP
---- 08/01/2004. Si ya están insertados los actualiza
----------------------------------------------------------------------------
   FUNCTION f_insert_estclauparesp(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      psclagen IN NUMBER,
      pnparame IN NUMBER,
      pcclaesp IN NUMBER,
      pnordcla IN NUMBER,
      pctippar IN NUMBER,
      ptvalor IN VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      INSERT INTO estclauparesp
                  (sseguro, nriesgo, nmovimi, sclagen, nparame, cclaesp, nordcla,
                   ctippar, tvalor)
           VALUES (psseguro, pnriesgo, pnmovimi, psclagen, pnparame, pcclaesp, pnordcla,
                   pctippar, ptvalor);

      RETURN vn_ok_code;
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         BEGIN
            UPDATE estclauparesp
               SET cclaesp = pcclaesp,
                   nordcla = pnordcla,
                   ctippar = pctippar,
                   tvalor = ptvalor
             WHERE sseguro = psseguro
               AND nriesgo = pnriesgo
               AND nmovimi = pnmovimi
               AND sclagen = psclagen
               AND nparame = pnparame;

            RETURN vn_ok_code;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 103865;
         END;
      WHEN OTHERS THEN
         RETURN 108468;   --Error al insertar
   END f_insert_estclauparesp;

  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
--- TABLAS SOL ---
   FUNCTION f_insert_solseguros(
      pssolicit IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pcagente IN NUMBER,
      pfalta IN DATE,
      pcobjase IN NUMBER,
      pcsubpro IN NUMBER,
      pcactivi IN NUMBER,
      pcestat IN NUMBER,
      pcduraci IN NUMBER,
      pcforpag IN NUMBER,
      pcusuari IN VARCHAR2,
      psproduc IN NUMBER)
      RETURN NUMBER IS
   BEGIN
      INSERT INTO solseguros
                  (ssolicit, cramo, cmodali, ctipseg, ccolect, cagente, falta,
                   cobjase, csubpro, cactivi, cestat, cduraci, cforpag, cusuari,
                   sproduc)
           VALUES (pssolicit, pcramo, pcmodali, pctipseg, pccolect, pcagente, pfalta,
                   pcobjase, pcsubpro, pcactivi, pcestat, pcduraci, pcforpag, pcusuari,
                   psproduc);

      RETURN vn_ok_code;
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         BEGIN
            UPDATE solseguros
               SET cramo = pcramo,
                   cmodali = pcmodali,
                   ctipseg = pctipseg,
                   ccolect = pccolect,
                   cagente = pcagente,
                   falta = pfalta,
                   cobjase = pcobjase,
                   csubpro = pcsubpro,
                   cactivi = pcactivi,
                   cestat = pcestat,
                   cduraci = pcduraci,
                   cforpag = pcforpag,
                   cusuari = pcusuari
             WHERE ssolicit = pssolicit;

            RETURN vn_ok_code;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 103865;
         END;
      WHEN OTHERS THEN
         RETURN 108468;   --Error al insertar
   END f_insert_solseguros;

----------------------------------------------------------------------------
---- 04/02/2004.Funcion que actualiza datos en la tabla SOLSEGUROS
----------------------------------------------------------------------------
   FUNCTION f_update_solseguros(
      pcasegur IN NUMBER,
      pcactivi IN NUMBER,
      pcagente IN NUMBER,
      pcforpag IN NUMBER,
      pcduraci IN NUMBER)
      RETURN NUMBER IS
   BEGIN
      UPDATE solseguros
         SET cagente = pcagente,
             cduraci = pcduraci,
             cactivi = pcactivi,
             cforpag = pcforpag;

      RETURN vn_ok_code;
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         RETURN vn_dup_ind;
      WHEN OTHERS THEN
         RETURN 108469;   --Error al actualizar
   END f_update_solseguros;

----------------------------------------------------------------------------
---- 04/02/2004.Funcion que inserta datos en la tabla SOLRIESGOS
---- 04/02/2004. Si ya están insertados los actualiza
----------------------------------------------------------------------------
   FUNCTION f_insert_solriesgos(pssolicit IN NUMBER, pnriesgo IN NUMBER, ptnatrie IN VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      INSERT INTO solriesgos
                  (ssolicit, nriesgo, tnatrie)
           VALUES (pssolicit, pnriesgo, ptnatrie);

      RETURN vn_ok_code;
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         BEGIN
            UPDATE solriesgos
               SET tnatrie = ptnatrie
             WHERE ssolicit = pssolicit
               AND nriesgo = pnriesgo;

            RETURN vn_ok_code;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 103865;
         END;
      WHEN OTHERS THEN
         RETURN 108468;   --Error al insertar
   END f_insert_solriesgos;

----------------------------------------------------------------------------
---- 16/02/2004.Funcion que calcula la tarifa
----------------------------------------------------------------------------
   FUNCTION f_pre_calcular_tarifa(psseguro IN NUMBER, pnriesgo IN NUMBER, psproces OUT NUMBER)
      RETURN NUMBER IS
      num_err        NUMBER;
   BEGIN
      DELETE      tmp_garancar
            WHERE sseguro = psseguro
              AND nriesgo = pnriesgo;

      DELETE      preguncar
            WHERE sseguro = psseguro
              AND nriesgo = pnriesgo;

      DELETE      pregungarancar
            WHERE sseguro = psseguro
              AND nriesgo = pnriesgo;

      SELECT starifa.NEXTVAL
        INTO psproces
        FROM DUAL;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
--p_control_error(null, 'planes', sqlerrm);
         RETURN -1;
   END f_pre_calcular_tarifa;

----------------------------------------------------------------------------
---- 16/02/2004.Funcion traspaso tablas para tarifar
----------------------------------------------------------------------------
   FUNCTION f_traspaso_tablas(
      psseguro IN NUMBER,
      psproces IN NUMBER,
      psproduc IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      piprianu IN NUMBER DEFAULT NULL,
      pprecarg IN NUMBER DEFAULT NULL,
      pirecarg IN NUMBER DEFAULT NULL,
      pipritar IN NUMBER DEFAULT NULL,
      ptasa IN NUMBER DEFAULT NULL,
      pirevali IN NUMBER DEFAULT NULL,
      pprevali IN NUMBER DEFAULT NULL,
      pidtocom IN NUMBER DEFAULT NULL,
      pdtocom IN NUMBER DEFAULT NULL,
      pifranqu IN NUMBER DEFAULT NULL,
      pctipfra IN NUMBER DEFAULT NULL,
      pcformul IN NUMBER DEFAULT NULL,
      piextrap IN NUMBER DEFAULT NULL,
      picapital IN NUMBER DEFAULT NULL,
      ppctarifa IN NUMBER DEFAULT NULL,
      pcrevali IN NUMBER DEFAULT NULL,
      pnorden IN NUMBER DEFAULT NULL,
      pctarifa IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      v_ipritar      NUMBER;
      v_nriesgo      NUMBER;
      regseguros     estseguros%ROWTYPE;
   BEGIN
      SELECT *
        INTO regseguros
        FROM estseguros
       WHERE estseguros.sseguro = psseguro;

      -- Averiguamos primero cual es la IPRITAR
      IF regseguros.ctarman IN(1, 3) THEN
         v_ipritar := piprianu - NVL(pidtocom, 0) - NVL(pirecarg, 0);
      ELSE
         v_ipritar := pipritar;
      END IF;

      BEGIN
         -- Insertamos en TMPGARANCAR
         -- Bug 9892 - 27/04/2009 - AMC -- Se anade el campo cactivi en garancar
         INSERT INTO tmp_garancar
                     (cgarant, nriesgo, nmovi_ant, sseguro, finiefe, norden,
                      crevali, ctarifa, icapital, precarg, iextrap, iprianu, ffinefe,
                      cformul, ctipfra, ifranqu, irecarg, ipritar, pdtocom, idtocom,
                      prevali, irevali, itarifa, itarrea, ipritot, icaptot, ftarifa, nmovima,
                      nfactor, nlinea, sproces,
                      cactivi)
              VALUES (pcgarant, pnriesgo, 1, regseguros.sseguro, regseguros.fefecto, pnorden,
                      pcrevali, ppctarifa, picapital, pprecarg, piextrap, piprianu, NULL,
                      pcformul, pctipfra, pifranqu, pirecarg, v_ipritar, pdtocom, pidtocom,
                      pprevali, pirevali, ptasa, NULL, NULL, NULL, regseguros.fefecto, 1,
                      1, NULL, psproces,
                      pac_seguros.ff_get_actividad(regseguros.sseguro, pnriesgo, 'EST'));

         RETURN psseguro + NVL(SQL%ROWCOUNT, 0);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE tmp_garancar
               SET norden = pnorden,
                   crevali = pcrevali,
                   ctarifa = pctarifa,
                   icapital = picapital,
                   precarg = pprecarg,
                   iextrap = piextrap,
                   iprianu = piprianu,
                   cformul = pcformul,
                   ctipfra = pctipfra,
                   ifranqu = pifranqu,
                   irecarg = pirecarg,
                   ipritar = pipritar,
                   pdtocom = pdtocom,
                   idtocom = pidtocom,
                   prevali = pprevali,
                   irevali = pirevali,
                   itarifa = ptasa,
                   ftarifa = regseguros.fefecto,
                   nmovima = 1,
                   nfactor = 1,
                   cactivi = pac_seguros.ff_get_actividad(regseguros.sseguro, pnriesgo, 'EST')
             WHERE sseguro = regseguros.sseguro
               AND cgarant = pcgarant
               AND nriesgo = pnriesgo
               AND nmovi_ant = 1
               AND sproces = psproces;

            RETURN 0;
         WHEN OTHERS THEN
            RETURN 111930;   --errro al insertar en tmp_garancar
      END;

      --Fi Bug 9892 - 27/04/2009 - AMC -- Se anade el campo cactivi en garancar
      RETURN 0;
   END f_traspaso_tablas;

----------------------------------------------------------------------------
---- 16/02/2004.Funcion TARIFA llama al pac_Tarifar
----------------------------------------------------------------------------
   FUNCTION f_tarifar(
      psseguro IN NUMBER,
      psproces IN NUMBER,
      psproduc IN NUMBER,
      pcclapri IN NUMBER,
      pnriesgo IN NUMBER,
      piprimin OUT NUMBER,
      piprianu OUT NUMBER,
      pmensa OUT VARCHAR2)
      RETURN NUMBER IS
      num_err        NUMBER;
      regseguros     estseguros%ROWTYPE;
   BEGIN
      SELECT *
        INTO regseguros
        FROM estseguros
       WHERE estseguros.sseguro = psseguro;

      num_err := pac_tarifas.f_tarifar_126(psproces, 'EST', 'TAR', 'P', regseguros.cramo,
                                           regseguros.cmodali, regseguros.ctipseg,
                                           regseguros.ccolect, psproduc, regseguros.cactivi,
                                           NULL, NULL,
                                           --no aplica bonificaciones en la introduccion
                                           regseguros.sseguro, pnriesgo, regseguros.fefecto,
                                           regseguros.fefecto, 0, regseguros.cobjase,
                                           regseguros.cforpag, 2, NULL, NULL,

-- JLB - I - BUG 18423 COjo la moneda del producto
                                          --        1,
                                           pac_monedas.f_moneda_producto(regseguros.sproduc),

-- JLB - F - BUG 18423 COjo la moneda del producto
                                           pcclapri, piprimin, piprianu, pmensa);
      RETURN num_err;
   END f_tarifar;

----------------------------------------------------------------------------
---- 16/02/2004. Función que despues de tarifar vuelve
-- a traspasar las tablas tmp a est.
----------------------------------------------------------------------------
   FUNCTION f_traspaso_tmp_a_estgaranseg(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      piprianu IN NUMBER DEFAULT NULL,
      pprecarg IN NUMBER DEFAULT NULL,
      pirecarg IN NUMBER DEFAULT NULL,
      pipritar IN NUMBER DEFAULT NULL,
      ptasa IN NUMBER DEFAULT NULL,
      pirevali IN NUMBER DEFAULT NULL,
      pprevali IN NUMBER DEFAULT NULL,
      pidtocom IN NUMBER DEFAULT NULL,
      pdtocom IN NUMBER DEFAULT NULL,
      pifranqu IN NUMBER DEFAULT NULL,
      pctipfra IN NUMBER DEFAULT NULL,
      pcformul IN NUMBER DEFAULT NULL,
      piextrap IN NUMBER DEFAULT NULL,
      picapital IN NUMBER DEFAULT NULL,
      ppctarifa IN NUMBER DEFAULT NULL,
      pcrevali IN NUMBER DEFAULT NULL,
      pnorden IN NUMBER DEFAULT NULL,
      pctarifa IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      v_ipritar      NUMBER;
      regseguros     estseguros%ROWTYPE;
   BEGIN
      SELECT *
        INTO regseguros
        FROM estseguros
       WHERE estseguros.sseguro = psseguro;

      IF regseguros.ctarman IN(1, 3) THEN
         v_ipritar := piprianu - NVL(pidtocom, 0) - NVL(pirecarg, 0);
      ELSE
         v_ipritar := pipritar;
      END IF;

      BEGIN
         -- Insertamos en ESTGARANSEG
         INSERT INTO estgaranseg
                     (cgarant, nriesgo, nmovimi, sseguro, finiefe, norden, crevali,
                      ctarifa, icapital, precarg, iextrap, iprianu, ffinefe, cformul,
                      ctipfra, ifranqu, irecarg, ipritar, pdtocom, idtocom, prevali,
                      irevali, itarifa, itarrea, ipritot, icaptot, ftarifa)
              VALUES (pcgarant, pnriesgo, 1, psseguro, regseguros.fefecto, pnorden, pcrevali,
                      pctarifa, picapital, pprecarg, piextrap, piprianu, NULL, pcformul,
                      pctipfra, pifranqu, pirecarg, v_ipritar, pdtocom, pidtocom, pprevali,
                      pirevali, ptasa, NULL, piprianu, picapital, regseguros.fefecto);
      EXCEPTION
         WHEN OTHERS THEN
            RETURN -1;
      END;

      RETURN 0;
   END f_traspaso_tmp_a_estgaranseg;

   FUNCTION f_aportacion(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pimovimi IN NUMBER,
      pfvalor IN DATE,
      pmovimi OUT NUMBER)
      RETURN NUMBER IS
      suplemento     NUMBER;
      num_err        NUMBER;
      num_movimi     NUMBER;
      aux_conta      NUMBER;
      pnorden        NUMBER;
      pctarifa       NUMBER;
      pcformul       NUMBER;
      movimiento     NUMBER;
      fecha          DATE;
      ttexto         VARCHAR(100);
      fondocuenta    NUMBER;
      linea          NUMBER(4);
   BEGIN
      --Se genera un movimiento de seguro de suplemento
      SELECT (NVL(MAX(nsuplem), 0) + 1)
        INTO suplemento
        FROM movseguro
       WHERE sseguro = psseguro;

      num_err := f_movseguro(psseguro, NULL, 500, 1, pfvalor, NULL, suplemento, 0, NULL,
                             num_movimi);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      num_err := f_dupgaran(psseguro, pfvalor, num_movimi);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      --Miramos si ya tenia alguna aportacion extraordinaria
      --como garantia
      BEGIN
         SELECT COUNT(*)
           INTO aux_conta
           FROM garanseg
          WHERE sseguro = psseguro
            AND nmovimi = num_movimi
            AND cgarant = 282;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 101959;
      END;

      IF aux_conta = 0 THEN
         BEGIN
            SELECT norden, ctarifa, cformul
              INTO pnorden, pctarifa, pcformul
              FROM garanpro, seguros
             WHERE seguros.sseguro = psseguro
               AND garanpro.cramo = seguros.cramo
               AND garanpro.cmodali = seguros.cmodali
               AND garanpro.ctipseg = seguros.ctipseg
               AND garanpro.ccolect = seguros.ccolect
               AND garanpro.cgarant = 282;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 101959;
         END;

         BEGIN
            INSERT INTO garanseg
                        (cgarant, sseguro, nriesgo, finiefe, norden, crevali, ctarifa,
                         icapital, precarg, iprianu, iextrap, ffinefe, cformul, ctipfra,
                         ifranqu, irecarg, ipritar, pdtocom, idtocom, prevali, irevali,
                         itarifa, nmovimi, itarrea, ipritot, icaptot)
                 VALUES (282, psseguro, 1, pfvalor, pnorden, 4, pctarifa,
                         pimovimi, NULL, 0, NULL, NULL, pcformul, NULL,
                         NULL, 0, 0, NULL, 0, NULL, NULL,
                         NULL, num_movimi, NULL, 0, pimovimi);
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 101959;
         END;
      ELSE   --- Si ya existe la garantia 282
         BEGIN
            UPDATE garanseg
               SET icapital = pimovimi,
                   icaptot = pimovimi
             WHERE sseguro = psseguro
               AND nmovimi = num_movimi
               AND cgarant = 282;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 101959;
         END;
      END IF;

      --Cambiamos el numero de suplemento en SEGUROS y la situacion
      BEGIN
         UPDATE seguros
            SET nsuplem = suplemento,
                csituac = 5
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 101992;
      END;

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      pmovimi := num_movimi;
      RETURN 0;
   END f_aportacion;

-- cONTROL DE PRESTACIONES
   FUNCTION f_saldo_presta_posterior(psseguro IN NUMBER, fecha_hasta IN DATE, tipo IN NUMBER)
      RETURN NUMBER IS
/***************************************************************************
   F_SALDO: Calcula el saldo de la cuenta seguro
      sI EL TIPO es 1 entonces devuelve el importe
      si es 0 devuelvo las participaciones

****************************************************************************/
      divisa         NUMBER;
      fecha_saldo    DATE;
      saldo_ant      NUMBER;   --NUMBER(14, 2);
      una_parti      NUMBER(25, 6);
      psaldo         NUMBER(25, 6);
      pparti         NUMBER(25, 6);
      saldo_actual   NUMBER(25, 6);
      parti_ant      NUMBER(25, 6);
      parti_actual   NUMBER;   --NUMBER(16, 6);
      imp_movimi     NUMBER(25, 6);
      codi_movimi    NUMBER(2);
      valor_parti    NUMBER(25, 6);
      pnnumlin       NUMBER(8);

      CURSOR c_saldo IS
         SELECT   cmovimi, imovimi, nparpla, nnumlin
             FROM ctaseguro
            WHERE sseguro = psseguro
              AND fvalmov > fecha_hasta
              AND cmovimi NOT IN(53, 47)
         ORDER BY TO_DATE(TO_CHAR(fvalmov, 'DD/MM/YYYY HH24:MI:SS'), 'DD/MM/YYYY HH24:MI:SS'),
                  nnumlin;
   BEGIN
-------Calculamos el saldo ----------------------------------------
      saldo_actual := 0;
      parti_actual := 0;

      OPEN c_saldo;

      LOOP
         FETCH c_saldo
          INTO codi_movimi, imp_movimi, valor_parti, pnnumlin;

         EXIT WHEN c_saldo%NOTFOUND;

         IF codi_movimi > 10 THEN
            valor_parti := -valor_parti;
         ELSIF codi_movimi = 0 THEN
            valor_parti := 0;
         END IF;

         parti_actual := NVL(parti_actual, 0) + NVL(valor_parti, 0);
      END LOOP;

      CLOSE c_saldo;

      pparti := parti_actual;
      --- *** Calculamos el importe del saldo
      valor_parti := f_valor_participlan(fecha_hasta, psseguro, divisa);
      psaldo := ROUND(pparti * valor_parti, 2);

      IF tipo = 1 THEN
         IF valor_parti = -1 THEN
            RETURN(-1);
         END IF;

         RETURN(psaldo);
      ELSE
         RETURN(pparti);
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         -- BUG -21546_108724- 06/02/2012 - JLTS - Cierre de posibles cursores abiertos
         IF c_saldo%ISOPEN THEN
            CLOSE c_saldo;
         END IF;

         RETURN -1;
   END f_saldo_presta_posterior;

   FUNCTION f_saldo_presta_actual(psseguro IN NUMBER, fecha_hasta IN DATE, tipo IN NUMBER)
      RETURN NUMBER IS
/***************************************************************************
   F_SALDO: Calcula el saldo de la cuenta seguro
      sI EL TIPO es 1 entonces devuelve el importe
      si es 0 devuelvo las participaciones

****************************************************************************/
      divisa         NUMBER;
      fecha_saldo    DATE;
      saldo_ant      NUMBER;   --NUMBER(14, 2);
      una_parti      NUMBER(25, 6);
      psaldo         NUMBER(25, 6);
      pparti         ctaseguro.nparpla%TYPE;   --NUMBER(25, 6); 26100
      saldo_actual   NUMBER(25, 6);
      parti_ant      ctaseguro.nparpla%TYPE;   --NUMBER(25, 6);
      parti_actual   ctaseguro.nparpla%TYPE;   --NUMBER(16, 6);
      imp_movimi     ctaseguro.imovimi%TYPE;   --NUMBER(25, 6);
      codi_movimi    ctaseguro.cmovimi%TYPE;   --NUMBER(2);
      valor_parti    ctaseguro.nparpla%TYPE;   --NUMBER(25, 6);
      pnnumlin       ctaseguro.nnumlin%TYPE;   --NUMBER(8);

      CURSOR c_saldo IS
         SELECT   cmovimi, imovimi, nparpla, nnumlin
             FROM ctaseguro
            WHERE sseguro = psseguro
              AND(TO_CHAR(fvalmov, 'YYYYMMDD') <= TO_CHAR(fecha_hasta, 'YYYYMMDD')
                  OR(cmovimi = 8
                     AND TO_CHAR(ADD_MONTHS(fvalmov, 6), 'YYYYMMDD') <=
                                                               TO_CHAR(fecha_hasta, 'YYYYMMDD')))
         ORDER BY TO_DATE(TO_CHAR(fvalmov, 'DD/MM/YYYY HH24:MI:SS'), 'DD/MM/YYYY HH24:MI:SS'),
                  nnumlin;
   BEGIN
-------Calculamos el saldo ----------------------------------------
      saldo_actual := 0;
      parti_actual := 0;

      OPEN c_saldo;

      LOOP
         FETCH c_saldo
          INTO codi_movimi, imp_movimi, valor_parti, pnnumlin;

         EXIT WHEN c_saldo%NOTFOUND;

         IF codi_movimi > 10 THEN
            valor_parti := -valor_parti;
         ELSIF codi_movimi = 0 THEN
            valor_parti := 0;
         END IF;

         parti_actual := NVL(parti_actual, 0) + NVL(valor_parti, 0);
      END LOOP;

      CLOSE c_saldo;

      pparti := parti_actual;

      SELECT parti_actual - NVL(SUM(nparpla), 0)
        INTO pparti
        FROM ctaseguro
       WHERE sseguro = psseguro
         AND cmovimi = 47
         AND TO_CHAR(fvalmov, 'YYYYMMDD') > TO_CHAR(fecha_hasta, 'YYYYMMDD');

      --- *** Calculamos el importe del saldo
      valor_parti := f_valor_participlan(fecha_hasta, psseguro, divisa);
      psaldo := ROUND(pparti * valor_parti, 2);

      IF tipo = 1 THEN
         IF valor_parti = -1 THEN
            RETURN(-1);
         END IF;

         RETURN(psaldo);
      ELSE
         RETURN(pparti);
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         -- BUG -21546_108724- 06/02/2012 - JLTS - Cierre de posibles cursores abiertos
         IF c_saldo%ISOPEN THEN
            CLOSE c_saldo;
         END IF;

         RETURN -1;
   END f_saldo_presta_actual;

   FUNCTION f_calcula_importe_anual(psseguro IN NUMBER, pano IN NUMBER, psperson IN NUMBER)
      RETURN NUMBER IS
      impctaseguro   NUMBER(25, 10);
      importeanual   trasplainout.iimpanu%TYPE;   --NUMBER(25, 10);
      importe_maximo planedades.iimporte%TYPE;   --NUMBER(25, 10); 26100
      fecha_ini      DATE;
      fecha_fin      DATE;
      edad           NUMBER;
      divisa         NUMBER;
      error          NUMBER;
      vagente_poliza seguros.cagente%TYPE;
      vcempres       seguros.cempres%TYPE;
      -- vALORES DE RETORNO
      --   -1 : Ha superado el limite de aportaciones anuales
      --  -2 : No se ha informado la edad.
      /***************************************
         18-7-2006. Ref. 1448. La edad se calcula a final de ano. Se calcula la edad real en lugar de la edad actuarial

   ***********************************************/
   BEGIN
      SELECT TO_DATE('3112' || pano, 'ddmmyyyy')
        INTO fecha_fin
        FROM DUAL;

      -- *** Bucamos el total de los movimientos realizados este ano
      SELECT SUM(DECODE(GREATEST(ctaseguro.cmovimi, 10), 10, NVL(imovimi, 0), -NVL(imovimi, 0)))
        INTO impctaseguro
        FROM ctaseguro, riesgos, seguros
       WHERE ctaseguro.sseguro = riesgos.sseguro
         AND seguros.sseguro = ctaseguro.sseguro
         AND ctaseguro.cmovanu <> 1
         AND NVL(f_parproductos_v(seguros.sproduc, 'APORTMAXIMAS'), 0) = 1
         --  AND (CTASEGURO.CTIPAPOR <> 'SP' OR CTASEGURO.CTIPAPOR IS NULL)
         AND(NVL(ctaseguro.ctipapor, 'X') <> 'SP')
         AND riesgos.fanulac IS NULL
         AND riesgos.sperson = psperson
         AND TO_DATE(TO_CHAR(pano, '9999'), 'YYYY') = TO_DATE(TO_CHAR(fvalmov, 'yyyy'), 'YYYY')
--      AND    SEGUROS.csituac = 0
/*  Toni Torres 2/08/2005
Tambien deben contemplarse las polizas anuladas. En caso de traspasos entre nuestros fondos, si solo
seleccionamos pp operativos provoca error por superar el máximo de aportaciones.
*/
--      AND    CTASEGURO.cmovimi NOT IN (0, 54);
         AND ctaseguro.cmovimi IN(1, 2);

/* Toni Torres 29/11/2005
Solo de sumar las aportaciones que se han hecho durante el ano,
*/

      -- *** Buscamos si también hicimos alguna entrada este ano
      BEGIN
         SELECT SUM(NVL(iimpanu, 0))
           INTO importeanual
           FROM trasplainout, ctaseguro, riesgos, seguros
          WHERE cinout = 1
            AND trasplainout.cestado IN(3, 4)
            AND ctaseguro.sseguro = trasplainout.sseguro
            AND ctaseguro.nnumlin = trasplainout.nnumlin
            AND TO_DATE(TO_CHAR(pano, '0000'), 'YYYY') =
                                                      TO_DATE(TO_CHAR(fvalmov, 'yyyy'), 'YYYY')
            AND seguros.sseguro = ctaseguro.sseguro
            AND csituac = 0
            AND trasplainout.cexterno = 1
            AND trasplainout.sseguro = riesgos.sseguro
            AND riesgos.sperson = psperson;
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      SELECT productos.cdivisa
        INTO divisa
        FROM seguros, productos
       WHERE productos.cramo = seguros.cramo
         AND productos.cmodali = seguros.cmodali
         AND productos.ctipseg = seguros.ctipseg
         AND productos.ccolect = seguros.ccolect
         AND seguros.sseguro = psseguro;

      --Bug10612 - 10/07/2009 - DCT (canviar vista personas)
      --- **** Calculamos las aportaciones máximas de este ano;
      SELECT p.fnacimi
        INTO fecha_ini
        FROM riesgos, per_personas p
       WHERE sseguro = psseguro
         AND p.sperson = riesgos.sperson;

      /*SELECT fnacimi
        INTO fecha_ini
        FROM riesgos, personas
       WHERE sseguro = psseguro
         AND personas.sperson = riesgos.sperson;*/

      --FI Bug10612 - 10/07/2009 - DCT (canviar vista personas)

      -- fecha_ini  :=
         --        TO_DATE ('01/01/' || TO_CHAR (fecha_ini, 'YYYY'), 'DD/MM/YYYY');
      -- error      := F_Difdata (fecha_ini, fecha_fin, 2, 1, edad);
      error := f_difdata(fecha_ini, fecha_fin, 1, 1, edad);

      BEGIN
         SELECT iimporte
           INTO importe_maximo
           FROM planedades
          WHERE TO_CHAR(nano) = (SELECT TO_CHAR(f_sysdate, 'YYYY')
                                   FROM DUAL)
            AND ntipo = 1
            AND edad BETWEEN nedadini AND nedadfin;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            --PRINT_MESSAGE ( 'STOP',109297,NULL );
            RETURN(-2);
      END;

      IF NVL(importe_maximo, 0) <(NVL(importeanual, 0) + NVL(impctaseguro, 0)) THEN
         RETURN(-1);
      ELSE
         RETURN(0);
      END IF;
   END f_calcula_importe_anual;

   FUNCTION f_crea_parte_prestaciones(
      psseguro IN NUMBER,
      psperson IN NUMBER,
      pfcontin IN DATE,
      pctipren IN NUMBER,
      pctipjub IN NUMBER,
      pnivel IN NUMBER,
      ppartis IN NUMBER,
      ppartisret IN NUMBER,
      ptippresta IN NUMBER DEFAULT NULL,
      pimpcap IN NUMBER DEFAULT NULL,
      pfcap IN DATE DEFAULT NULL,
      pimprenta IN NUMBER DEFAULT NULL,
      pfrenta IN DATE DEFAULT NULL,
      pnif IN VARCHAR2 DEFAULT NULL,
      pnombre IN VARCHAR2 DEFAULT NULL,
      ptelf IN VARCHAR2 DEFAULT NULL,
      pparte OUT NUMBER)
      RETURN NUMBER IS
      -- ******** Crea un parte de prestaciones
      parte          NUMBER;
      ccc            seguros.cbancar%TYPE;
      xctipban       seguros.ctipban%TYPE;
      nparant2007    NUMBER;
      nparpos2006    NUMBER;
      nparret        NUMBER;
      cerror         NUMBER;
      lerror         VARCHAR2(100);
   BEGIN
      SELECT sprestaplan.NEXTVAL
        INTO parte
        FROM DUAL;

      IF pac_fisc_pp_2007.f_part_pres(psseguro, pfcontin, nparant2007, nparpos2006, nparret,
                                      cerror, lerror) != 0 THEN
         nparant2007 := 0;
         nparpos2006 := 0;
      END IF;

      INSERT INTO prestaplan
                  (sprestaplan, sseguro, sperson, ctipren, ctipjub, faccion, nnivel,
                   fcreacion, cestado, nsinies, nparti, nparret, npartrasret, solnif,
                   solnombre, soltel)
           VALUES (parte, psseguro, psperson, pctipren, NVL(pctipjub, 0), pfcontin, pnivel,
                   f_sysdate, 1, NULL, ppartis, ppartisret, NULL, pnif,
                   pnombre, ptelf);

      SELECT cbancar, ctipban
        INTO ccc, xctipban
        FROM seguros
       WHERE sseguro = psseguro;

      pparte := parte;

      -- SI LA CONTINGENCIA NO ES MUERTE PONEMOS EL BENEFICIARIO
      IF pctipren <> 3 THEN   -- No es Muerte
         INSERT INTO benefprestaplan
                     (sprestaplan, sperson, nparpla, ctipcap, nporcen, nparfin, nparant2007,
                      nparpos2006)
              VALUES (pparte, psperson, ppartis, ptippresta, 100, NULL, nparant2007,
                      nparpos2006);

         IF ptippresta IN(1, 3) THEN
            -- > Prestación en forma de capital o mixto
            INSERT INTO planbenefpresta
                        (sprestaplan, sperson, ctipcap, cperiod, finicio, importe, cestado,
                         npartot, cbancar,
                         nparant2007,
                         nparpos2006, ctipban)
                 VALUES (parte, psperson, 1, NULL, pfcap, pimpcap, 1,
                         DECODE(ptippresta, 3, NULL, ppartis), ccc,
                         DECODE(ptippresta, 3, NULL, nparant2007),
                         DECODE(ptippresta, 3, NULL, nparpos2006), xctipban);
         END IF;

         IF ptippresta IN(2, 3) THEN   --> Prestación en forma de Renta o Mixto
            INSERT INTO planbenefpresta
                        (sprestaplan, sperson, ctipcap, cperiod, finicio, importe, cestado,
                         cbancar, ctipban)
                 VALUES (parte, psperson, 2, 12, pfrenta, pimprenta, 1,
                         ccc, xctipban);
         END IF;

         IF ptippresta IN(4) THEN   --> Prestación Vitalicia
            INSERT INTO planbenefpresta
                        (sprestaplan, sperson, ctipcap, cestado, cbancar, ctipban)
                 VALUES (parte, psperson, 4, 1, ccc, xctipban);
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN -1;   ---> No se ha podido crear el parte de prestaciones.
   END f_crea_parte_prestaciones;

-- tRASPASOS
   FUNCTION f_crea_traspaso_salida_interno(
      psseguro_desde IN NUMBER,
      psseguro_hasta IN NUMBER,
      pimporte IN NUMBER,
      pctiptras IN NUMBER,
      pfsolici IN DATE,
      pmemo IN VARCHAR2,
      pstras OUT NUMBER)
      RETURN NUMBER IS
      sectras        NUMBER;
      codplan        NUMBER;
      poliza         NUMBER;
      certif         NUMBER;
      cuenta         seguros.cbancar%TYPE;
      imptras        NUMBER;
      qtras          NUMBER;
      xctipban       seguros.ctipban%TYPE;
   BEGIN
      SELECT proplapen.ccodpla, seguros.npoliza, seguros.ncertif, fonpensiones.cbancar,
             fonpensiones.ctipban
        INTO codplan, poliza, certif, cuenta,
             xctipban
        FROM seguros, proplapen, planpensiones, fonpensiones
       WHERE seguros.sseguro = psseguro_hasta
         AND seguros.sproduc = proplapen.sproduc
         AND proplapen.ccodpla = planpensiones.ccodpla
         AND planpensiones.ccodfon = fonpensiones.ccodfon;

      SELECT stras.NEXTVAL
        INTO sectras
        FROM DUAL;

      /*
      Toni Torres - 4/8/2005
      Si es un traspaso de salida total guardar el importe a NULL, para que en el listado de operaciones
      pendientes de consolidar aparezcan las participaciones en lugar del importe a traspasar
      */
      IF (pctiptras = 1) THEN
         imptras := NULL;
      ELSE
         SELECT COUNT(1)
           INTO qtras
           FROM trasplainout t
          WHERE t.sseguro = psseguro_desde
            AND t.cestado IN(1, 2)
            AND t.ctiptras = 1
            AND t.cinout = 2;

         IF NVL(qtras, 0) > 0 THEN
            RETURN 108298;
         END IF;

         imptras := pimporte;
      END IF;

      INSERT INTO trasplainout
                  (stras, cinout, sseguro, fsolici, ccodpla, tpolext, cbancar, cestado,
                   ctiptras, tmemo, iimporte, iimptemp, iimpanu, fantigi, ncertext, ctipban)
           VALUES (sectras, 2, psseguro_desde, pfsolici, codplan, poliza, cuenta, 1,
                   pctiptras, pmemo, NULL, imptras, NULL, NULL, certif, xctipban);

      -- > Devuelve por OUT el número de traspaso creado.
      pstras := sectras;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN -1;   ---> No se ha podido crear el traspaso
   END;

-- Traspaso de Entrada Externo
   FUNCTION f_crea_traspas_entrada_externo(
      psseguro_destino IN NUMBER,
      pccodpla_origen IN NUMBER DEFAULT NULL,
      ptnompla_externo IN VARCHAR DEFAULT NULL,
      pimporte IN NUMBER DEFAULT NULL,
      pctiptras IN NUMBER,
      pfsolici IN DATE,
      pmemo IN VARCHAR2,
      pstras OUT NUMBER)
      RETURN NUMBER IS
      sectras        NUMBER;
      codplan        NUMBER;
      poliza         NUMBER;
      certif         NUMBER;
      cuenta         seguros.cbancar%TYPE;
      xctipban       seguros.ctipban%TYPE;
   BEGIN
      BEGIN
         SELECT fonpensiones.cbancar, fonpensiones.ctipban
           INTO cuenta, xctipban
           FROM planpensiones, fonpensiones
          WHERE planpensiones.ccodpla = pccodpla_origen
            AND planpensiones.ccodfon = fonpensiones.ccodfon;
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      SELECT stras.NEXTVAL
        INTO sectras
        FROM DUAL;

      INSERT INTO trasplainout
                  (stras, cinout, sseguro, fsolici, ccodpla, cbancar, cestado,
                   ctiptras, tmemo, iimporte, iimptemp, iimpanu, fantigi, tcodpla, cexterno,
                   ctipban)
           VALUES (sectras, 1, psseguro_destino, pfsolici, pccodpla_origen, cuenta, 1,
                   pctiptras, pmemo, NULL, pimporte, NULL, NULL, ptnompla_externo, 1,
                   xctipban);

      -- > Devuelve por OUT el número de traspaso creado.
      pstras := sectras;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN -1;   ---> No se ha podido crear el traspaso
   END;

   FUNCTION f_rollback
      RETURN NUMBER IS
      terror         VARCHAR2(100);
   BEGIN
      ROLLBACK;
      terror := 'Correcto :' || SQLERRM;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         terror := 'Error:';
         RETURN -1;
   END f_rollback;

   FUNCTION f_commit
      RETURN NUMBER IS
      terror         VARCHAR2(100);
   BEGIN
      COMMIT;
      terror := 'Correcto :';
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         terror := 'Error:';
         RETURN -1;
   END f_commit;

   FUNCTION f_historico_seguros(psseguro IN NUMBER, pmovimi OUT NUMBER)
      RETURN NUMBER IS
      err            NUMBER;
   BEGIN
      SELECT MAX(nmovimi)
        INTO pmovimi
        FROM movseguro
       WHERE sseguro = psseguro;

      err := f_act_hisseg(psseguro, pmovimi);

      IF err <> 0 THEN
         RETURN err;
      END IF;

      RETURN 0;
   END f_historico_seguros;

   FUNCTION f_suplemento(
      psseguro IN NUMBER,
      pmotivo IN NUMBER,
      pfvalor IN DATE,
      pnummovimi OUT NUMBER)
      RETURN NUMBER IS
      num_err        NUMBER;
      num_movimi     NUMBER;
      suplemento     NUMBER;
   BEGIN
      SELECT (NVL(MAX(nsuplem), 0) + 1)
        INTO suplemento
        FROM movseguro
       WHERE sseguro = psseguro;

      num_err := f_movseguro(psseguro, NULL, pmotivo, 1, pfvalor, NULL, suplemento,
--                  pmovimi + 1,
                             0, NULL, num_movimi);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      pnummovimi := num_movimi;
      num_err := f_dupgaran(psseguro, f_sysdate, num_movimi);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      --Cambiamos el numero de suplemento en SEGUROS y la situacion
      BEGIN
         UPDATE seguros
            SET csituac = 0
          WHERE sseguro = psseguro;

         UPDATE movseguro
            SET femisio = f_sysdate
          WHERE sseguro = psseguro
            AND nmovimi = num_movimi;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN -1;
      END;

      RETURN 0;
   END f_suplemento;

   FUNCTION f_crea_domicilio(
      psperson IN NUMBER,
      pctipdir IN NUMBER,
      pcpostal IN codpostal.cpostal%TYPE,   --3606 jdomingo 29/11/2007  canvi format codi postal
      pcprovin IN NUMBER,
      pcpoblac IN NUMBER,
      pcsiglas IN NUMBER,
      ptnomvia IN VARCHAR2,
      pnnumvia IN NUMBER,
      ptcomple IN VARCHAR2,
      pcidioma IN NUMBER,
      pcdomici OUT NUMBER)
      RETURN NUMBER IS
      domici         NUMBER;
      nomvia         VARCHAR2(30);
   BEGIN
      domici := f_obten_cdomici(psperson);

      SELECT tdenom
        INTO nomvia
        FROM destipos_via
       WHERE csiglas = pcsiglas
         AND cidioma = pcidioma;

      INSERT INTO direcciones
                  (sperson, cdomici, cpostal, cprovin, cpoblac, csiglas, tnomvia,
                   nnumvia, tcomple, ctipdir)
           VALUES (psperson, domici, pcpostal, pcprovin, pcpoblac, pcsiglas, ptnomvia,
                   pnnumvia, ptcomple, pctipdir);

      pcdomici := domici;
      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN -1;
   END f_crea_domicilio;

   FUNCTION f_aportaciones_anuales_pp(
      psseguro IN NUMBER,
      pano IN NUMBER,
      phasta IN DATE DEFAULT NULL)
      RETURN NUMBER IS
      impctaseguro   NUMBER(25, 10);
      importeanual   NUMBER(25, 10);
      importe_maximo NUMBER(25, 10);
      error          NUMBER;
      terror         VARCHAR2(200);
   BEGIN
      -- *** Bucamos el total de los movimientos realizados este ano
      -- *** solo para esta póliza
-- MSR Optimitzat
      SELECT SUM(NVL(ctaseguro.imovimi, 0))
        INTO impctaseguro
        FROM ctaseguro
       WHERE ctaseguro.cmovanu = 0
         AND ctaseguro.sseguro = psseguro
         AND ctaseguro.fvalmov >= TO_DATE(TO_CHAR(pano), 'YYYY')
         AND ctaseguro.fvalmov < NVL(TRUNC(phasta) + 1, TO_DATE(TO_CHAR(pano + 1), 'YYYY'))
         AND ctaseguro.cmovimi IN(1, 2);

      -- *** Buscamos si también hicimos alguna entrada este ano
-- MSR Optimitzat
      SELECT SUM(NVL(trasplainout.iimpanu, 0))
        INTO importeanual
        FROM trasplainout, ctaseguro
       WHERE trasplainout.cinout = 1
         AND trasplainout.cestado IN(3, 4)
         AND ctaseguro.sseguro = trasplainout.sseguro
         AND ctaseguro.nnumlin = trasplainout.nnumlin
         AND ctaseguro.fvalmov >= TO_DATE(TO_CHAR(pano), 'YYYY')
         AND ctaseguro.fvalmov < NVL(TRUNC(phasta) + 1, TO_DATE(TO_CHAR(pano + 1), 'YYYY'))
         AND ctaseguro.sseguro = psseguro;

      RETURN NVL(importeanual, 0) + NVL(impctaseguro, 0);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN -1;
   END f_aportaciones_anuales_pp;

   FUNCTION f_saldo_3112_pp(psseguro IN NUMBER, pano IN NUMBER)
      RETURN NUMBER IS
      impctaseguro   NUMBER(25, 10);
      importeanual   NUMBER(25, 10);
      importe_maximo NUMBER(25, 10);
      error          NUMBER;
   BEGIN
      -- *** Bucamos el total de los movimientos realizados este ano
      -- *** solo para esta póliza
      SELECT SUM(NVL(imovimi, 0))
        INTO impctaseguro
        FROM ctaseguro, riesgos, seguros
       WHERE ctaseguro.sseguro = riesgos.sseguro
         AND seguros.sseguro = ctaseguro.sseguro
         AND ctaseguro.cmovanu = 0
         AND seguros.sseguro = psseguro
         AND TO_DATE(TO_CHAR(pano, '9999'), 'YYYY') <=
                                                      TO_DATE(TO_CHAR(fvalmov, 'yyyy'), 'YYYY')
         AND ctaseguro.cmovimi IN(1, 2);

      RETURN NVL(impctaseguro, 0);
   END f_saldo_3112_pp;

   FUNCTION f_sup_fpago(
      psseguro IN NUMBER,
      pfsuplem IN DATE,
      pcforpag_nou IN NUMBER,
      pcforpag_ant IN NUMBER,
      pgrabar IN NUMBER,
      pfcarpro OUT DATE,
      pfcaranu OUT DATE)
      RETURN NUMBER IS
      error          NUMBER;
      fecha_carpro   DATE;
      fecha_recibo   DATE;
      fecha_caranu   DATE;
      grupo          NUMBER;
      ant_carpro     DATE;
      ant_caranu     DATE;
   -- Devuelve y graba ( si el pgrabar = 1 ) lasnuevas fechas de cartera en función de la nueva forma de pago.
   BEGIN
      error := 0;

      IF pcforpag_nou = 0 THEN
         pfcarpro := NULL;
         pfcaranu := NULL;
      ELSE
         pfcarpro := ADD_MONTHS(TO_DATE('01' || TO_CHAR(f_sysdate, 'mmyyyy'), 'ddmmyyyy'), 1);
         pfcaranu := ADD_MONTHS(TO_DATE('01' || TO_CHAR(f_sysdate, 'mmyyyy'), 'ddmmyyyy'), 13);
      END IF;

      IF pgrabar = 1 THEN
         UPDATE seguros
            SET fcarpro = pfcarpro,
                fcaranu = pfcaranu,
                nrenova = DECODE(pfcaranu, NULL, NULL, TO_CHAR(pfcaranu, 'mm') || '01'),
                cforpag = pcforpag_nou
          WHERE seguros.sseguro = psseguro;
      END IF;

        /*SELECT FCARPRO, FCARANU
        INTO
        ant_carpro, ant_caranu
        FROM SEGUROS
        WHERE SEGUROS.SSEGURO = psseguro;

        IF ant_carpro IS NULL AND ant_caranu IS NULL THEN
           fecha_carpro := TO_DATE('01' || TO_CHAR(ADD_MONTHS(pfsuplem,1),'mmyyyy'),'ddmmyyyy');
          fecha_caranu := ADD_MONTHS(fecha_carpro,12);

          IF pgrabar = 1 THEN
             UPDATE SEGUROS SET fcarpro = FECHA_CARPRO
                                                               ,fcaranu = FECHA_CARANU
                                                   ,nrenova = TO_CHAR(fecha_caranu,'mm') ||'01'
                                                   ,cforpag = pcforpag_nou
              WHERE SEGUROS.sseguro = psseguro;
         END IF;
         error := 0;
         pfcarpro := fecha_carpro;
         pfcaranu := fecha_caranu;
        ELSIF pcforpag_nou = 0 THEN--> Forma de pag única

             UPDATE SEGUROS SET fcarpro = NULL
                                                   ,cforpag = pcforpag_nou
              WHERE SEGUROS.sseguro = psseguro;
            error := 0;
            pfcarpro := NULL;
            pfcaranu := ant_caranu;

        ELSE


          ERROR := Pac_Canviforpag.F_FCARPRO_FINAL (  Psseguro, pfsuplem
                                                                                      , pcforpag_nou, pcforpag_ant
                                                                                      , FECHA_CARPRO
                                                                                      , FECHA_RECIBO );
           IF ERROR =0 AND PGRABAR = 1 THEN
               UPDATE SEGUROS SET fcarpro = fecha_carpro
                                                      ,cforpag = pcforpag_nou
              WHERE SEGUROS.sseguro = psseguro;
          END IF;
          pfcarpro := fecha_carpro;
          pfcaranu := ant_caranu;
        END IF;
      */
      IF error = 0 THEN
         RETURN 0;
      ELSE
         RETURN error;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN -99;
   END f_sup_fpago;

-- Suplemento de cuenta
   FUNCTION f_sup_ccc(psseguro IN NUMBER, pccc IN VARCHAR2, pctipban IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
   BEGIN
      UPDATE seguros
         SET cbancar = pccc,
             ctipban = pctipban
       WHERE sseguro = psseguro;

         /*FOR REGISTRO IN ( SELECT SPRESTAPLAN, NSINIES , RIESGOS.SPERSON
                                                  FROM PRESTAPLAN, RIESGOS
                                                    WHERE RIESGOS.SSEGURO = PRESTAPLAN.SSEGURO
                                         AND RIESGOS.FANULAC IS NULL
                                                    AND RIESGOS.SSEGURO = psseguro ) LOOP

               UPDATE DESTINATARIOS
             SET CBANCAR = pccc
             WHERE SPERSON = REGISTRO.SPERSON
             AND NSINIES = REGISTRO.NSINIES ;

             UPDATE PLANBENEFPRESTA
             SET CBANCAR = pccc
             WHERE SPRESTAPLAN = REGISTRO.SPRESTAPLAN
             AND SPERSON = REGISTRO.SPERSON;

         END LOOP;
      */
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN -1;
   END f_sup_ccc;

-- Suplemento de cuenta corriente para el pago de la prestación
-- Actualiza todas las cuentas para un parte de prestaciones de un beneficiario.
   FUNCTION f_sup_ccc_prestacion(
      psprestaplan IN NUMBER,
      psperson IN NUMBER,
      pccc IN VARCHAR2,
      pctipban IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      v_cempres      NUMBER;
   BEGIN
      -- BUG 11595 - 03/11/2009 - APD - Adaptación al nuevo módulo de siniestros
      -- Se anade el sseguro en la select del FOR ya que se necesita para buscar la
      -- empresa de la poliza
      FOR registro IN (SELECT sprestaplan, nsinies, riesgos.sperson, riesgos.sseguro
                         FROM prestaplan, riesgos
                        WHERE riesgos.sseguro = prestaplan.sseguro
                          AND riesgos.fanulac IS NULL
                          AND prestaplan.sprestaplan = psprestaplan) LOOP
         -- BUG 11595 - 03/11/2009 - APD - Adaptación al nuevo módulo de siniestros
         SELECT cempres
           INTO v_cempres
           FROM seguros
          WHERE sseguro = registro.sseguro;

         IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'MODULO_SINI'), 0) = 0 THEN
            UPDATE destinatarios
               SET cbancar = pccc,
                   ctipban = pctipban
             WHERE sperson = registro.sperson
               AND nsinies = registro.nsinies;
         ELSE
            UPDATE sin_tramita_destinatario
               SET cbancar = pccc,
                   ctipban = pctipban
             WHERE sperson = registro.sperson
               AND nsinies = registro.nsinies;
         END IF;

         -- Fin BUG 11595 - 03/11/2009 - APD - Adaptación al nuevo módulo de siniestros
         UPDATE planbenefpresta
            SET cbancar = pccc,
                ctipban = pctipban
          WHERE sprestaplan = registro.sprestaplan
            AND sperson = registro.sperson;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN -1;
   END f_sup_ccc_prestacion;

-- Cambio del importe de la prestación.
   FUNCTION f_sup_importe_prestacion(
      psprestaplan IN NUMBER,
      psperson IN NUMBER,
      pctipcap IN NUMBER,
      pimporte IN NUMBER)
      RETURN NUMBER IS
   BEGIN
      UPDATE planbenefpresta
         SET importe = pimporte
       WHERE sprestaplan = psprestaplan
         AND sperson = psperson
         AND ctipcap = pctipcap;

      IF SQL%ROWCOUNT = 1 THEN
         RETURN 0;
      ELSE
         RETURN -2;   --> Se ha modificado más de un registro o ninguno.
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN -1;   --> Error no controlado
   END;

   -- Funció obsoleta. Es manté per compatibilitat però ha estat substituida per IMPRESION_LIBRETA.GENERAR
   FUNCTION generar_impresion_libreta(
      psseguro IN NUMBER,
      pfreimp IN DATE DEFAULT NULL,
      psesion OUT NUMBER)
      RETURN NUMBER IS
   BEGIN
      -- Ref. 2421 MSR
      RETURN(impresion_libreta.generar(psseguro, pfreimp, psesion));
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_TFV.generar_impresion_libreta', 1,
                     'psSeguro =' || psseguro || ' pfreimp=' || pfreimp, SQLERRM);
         RETURN -1;
   END generar_impresion_libreta;

   -- Funció obsoleta. Es manté per compatibilitat però ha estat substituida per IMPRESION_LIBRETA.GUARDAR
   FUNCTION guardar_impresion_libreta(
      psseguro IN NUMBER,
      psesion IN NUMBER,
      pcodlin IN NUMBER,
      ppagina IN NUMBER,
      plinea IN NUMBER)
      RETURN NUMBER IS
   BEGIN
      -- Ref. 2421 MSR
      RETURN impresion_libreta.guardar(psseguro, psesion, pcodlin, ppagina, plinea);
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_TFV.guardar_impresion_libreta', 1,
                     'psSeguro =' || psseguro || ' psesion=' || psesion || ' pcodlin='
                     || pcodlin || ' ppagina=' || ppagina || ' plinea=' || plinea,
                     SQLERRM);
         RETURN -1;
   END;

   FUNCTION f_control_cumul(psseguro IN NUMBER, pnriesgo IN NUMBER, pfecha IN DATE)
      RETURN NUMBER IS
-- Definimos variables
      num_err        NUMBER;
      mens           NUMBER;
      v_sproduc      NUMBER;
      formul         VARCHAR2(60);
      pcont          NUMBER;
      xicapital      NUMBER;
      xsperson       NUMBER;
      xsperson2      NUMBER;
      parms_transitorios pac_parm_tarifas.parms_transitorios_tabtyb;
      apto           CHAR;
      v_nmovimi      NUMBER;
      nivel          VARCHAR2(2);
      texdocu        VARCHAR2(100);
      xhayerr        NUMBER(1);
      sqle           VARCHAR2(200);
      pnnumlin       NUMBER;
      v_ssegpol      NUMBER;
   BEGIN
      BEGIN
         SELECT sproduc, ssegpol
           INTO v_sproduc, v_ssegpol
           FROM estseguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 101903;   --seguro no encontrado en la tabla seguros
      --perror := 1;
      --terror := 'Error inesperado. No encuentra la póliza';
      END;

      xsperson := 0;
      xsperson2 := 0;

      FOR per IN (SELECT sperson
                    FROM estriesgos   --estassegurats
                   WHERE sseguro = psseguro
                     AND nriesgo = pnriesgo) LOOP
         --  IF per.norden = 1 THEN
         xsperson := per.sperson;
      -- ELSE
        --  xsperson2 := per.sperson;
      -- END IF;
      END LOOP;

      IF xsperson IS NULL THEN
         RETURN 108307;   --faltan asegurados
      END IF;

      --
      xicapital := 0;
      pcont := 1;
      parms_transitorios(pcont).sperson := xsperson;
      parms_transitorios(pcont).sperson2 := xsperson2;
      parms_transitorios(pcont).icapital := xicapital;
      parms_transitorios(pcont).qcontr := 1;
      parms_transitorios(pcont).sseguro := psseguro;
      parms_transitorios(pcont).sproduc := v_sproduc;

      -- BUG11288:DRA:27/05/2010:Inici
      DELETE FROM estmotreten_rev
            WHERE sseguro = psseguro;

      -- BUG11288:DRA:27/05/2010:Fi
      DELETE FROM estmotretencion
            WHERE sseguro = psseguro;

      DELETE FROM motretencion
            WHERE sseguro = v_ssegpol
              AND nmovimi = 1;

      mens := pk_cumul_rie_vida.buscar_cumulo(v_sproduc, pfecha, pcont, parms_transitorios);

      IF mens > 0 THEN
         FOR i IN 1 .. mens LOOP
            formul := pk_cumul_rie_vida.ver_mensajes(i);
            apto := SUBSTR(formul, 1, 1);   -- mensaje(i).contr

            IF apto = 0 THEN   -- Se controla si es apto(0/1)
               num_err := pac_emision_mv.f_retener_poliza('EST', psseguro, 1, 1, 2, 2, pfecha);
               NULL;
            ELSIF apto = 1 THEN   -- NO ES APTO
               -- Puede ser que haya sobrepasado el límite o simplemente que necesite
               -- una revisión médica

               --               nivel  := SUBSTR (formul, -1);
               nivel := SUBSTR(formul, -2);

               IF SUBSTR(nivel, 1, 1) = ';' THEN   -- el nivel de pruebas puede ser numerico de 1 posicion o de 2 posiciones GMM8513/2006/02/06
                  nivel := SUBSTR(formul, -1);
               END IF;

               IF nivel = 'E' THEN   -- exceso límite
                  RETURN 151890;
               ELSE
                  -- grabamos una pregunta automática a nivel de garantía
                  BEGIN
                     INSERT INTO estpregunseg
                                 (cpregun, sseguro, nriesgo, nmovimi, crespue, trespue)
                          VALUES (2, psseguro, pnriesgo, 1, nivel, NULL);
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                        UPDATE estpregunseg
                           SET crespue = nivel
                         WHERE sseguro = psseguro
                           AND nriesgo = pnriesgo
                           AND nmovimi = 1
                           AND cpregun = 2;
                     WHEN OTHERS THEN
                        p_tab_error(f_sysdate, f_user, 'PAC_TFV.f_control_cumul', 1,
                                    'insert pregungaranseg  sseguro =' || psseguro
                                    || ' nriesgo =' || pnriesgo || 'nivel =' || nivel,
                                    SQLERRM);
                        RETURN 110174;   -- error al insertar en pregungaranseg
                  END;

                  -- Se retiene la póliza (PENDIENTE DE EVALUACIÓN) y se inserta en motretencion
                  num_err := pac_emision_mv.f_retener_poliza('EST', psseguro, 1, 1, 3, 2,
                                                             pfecha);
               --else
                 -- return 151891; -- error al calcular el cúmulo;
               END IF;
            ELSE
               p_tab_error(f_sysdate, f_user, 'PAC_TFV.f_control_cumul', 2,
                           'ERROR AL CALCULAR EL CUMULO  sseguro =' || psseguro
                           || ' nriesgo =' || pnriesgo || 'nivel =' || nivel,
                           formul);
               RETURN 151891;   -- error al calcular el cúmulo
            END IF;
         END LOOP;   -- Fin loop mensajes

         pk_cumul_rie_vida.borra_mensajes;
      END IF;

      RETURN 0;
   END f_control_cumul;

   FUNCTION f_cumulos_pp(psseguro IN NUMBER, ptexto OUT VARCHAR2)
      RETURN NUMBER IS
      numseg         NUMBER;
      anual          NUMBER;
      importe        NUMBER;
   BEGIN
      FOR reg IN (SELECT   ntipo, r.sperson, r.spermin,
                           DECODE(ntipo,
                                  1, 'APORT.P.PENS',
                                  2, 'APORT.P.P.MI',
                                  3, 'AP.PP.FAM.MI',
                                  4, 'APORT.PP.PRO') "DESCTIPO",
                           fedadaseg(1, r.sperson,
                                     TO_NUMBER(TO_CHAR(f_sysdate, 'YYYYMMDD')), 1) "EDAD",
                           p.iimporte "IMPORTE"
                      FROM planedades p, riesgos r
                     WHERE r.sseguro = psseguro
                       AND fedadaseg(1, r.sperson, TO_NUMBER(TO_CHAR(f_sysdate, 'YYYYMMDD')),
                                     1) BETWEEN nedadini AND nedadfin
                       AND nano = TO_CHAR(f_sysdate, 'YYYY')
                  ORDER BY ntipo) LOOP
         numseg := 0;
         anual := 0;

         IF reg.spermin IS NULL
            AND reg.ntipo = 1 THEN   --> Aportante normal
            SELECT COUNT(1)
              INTO numseg
              FROM riesgos, seguros
             WHERE riesgos.sseguro = seguros.sseguro
               AND riesgos.fanulac IS NULL
               AND seguros.csituac = 0
               AND riesgos.spermin IS NULL
               AND seguros.cagrpro = 11
               AND riesgos.sperson = reg.sperson;

            anual := f_calcula_importe_anual_pp(NULL, TO_CHAR(f_sysdate, 'YYYY'), psseguro);
         ELSIF reg.spermin IS NOT NULL
               AND reg.sperson IS NOT NULL
               AND reg.spermin <> reg.sperson
               AND reg.ntipo = 3 THEN   --> Aportante al minusvalido
            SELECT COUNT(1)
              INTO numseg
              FROM riesgos, seguros
             WHERE riesgos.sseguro = seguros.sseguro
               AND riesgos.fanulac IS NULL
               AND seguros.csituac = 0
               AND riesgos.spermin IS NOT NULL
               AND seguros.cagrpro = 11
               AND riesgos.sperson = reg.sperson
               AND riesgos.spermin <> riesgos.sperson;

            anual := f_calcula_importe_anual_pp(NULL, TO_CHAR(f_sysdate, 'YYYY'), psseguro);
         ELSIF reg.spermin = reg.sperson
               AND reg.ntipo = 2 THEN   --> Minusvalido
            SELECT COUNT(1)
              INTO numseg
              FROM riesgos, seguros
             WHERE riesgos.sseguro = seguros.sseguro
               AND riesgos.fanulac IS NULL
               AND seguros.csituac = 0
               AND seguros.cagrpro = 11
               AND riesgos.sperson = reg.sperson
               AND riesgos.spermin = riesgos.sperson;

            anual := f_calcula_importe_anual_pp(NULL, TO_CHAR(f_sysdate, 'YYYY'), psseguro);
         ELSIF reg.ntipo = 4 THEN   --> Contratos del promotor
            SELECT COUNT(1)
              INTO numseg
              FROM riesgos, seguros, parproductos
             WHERE riesgos.sseguro = seguros.sseguro
               AND riesgos.fanulac IS NULL
               AND seguros.csituac = 0
               AND parproductos.sproduc = seguros.sproduc
               AND cparpro = 'PPEMPLEO'
               AND seguros.cagrpro = 11
               AND cvalpar = 1
               AND riesgos.sperson = reg.sperson;

            IF numseg > 0 THEN
               anual := f_calcula_importe_anual_pp(NULL, TO_CHAR(f_sysdate, 'YYYY'), psseguro,
                                                   'P');
            END IF;
         END IF;

         IF NVL(numseg, 0) = 0 THEN
            importe := 0;
         ELSE
            importe := reg.importe;
         END IF;

         ptexto := ptexto || reg.desctipo || ';' || numseg || ';'
                   || TO_CHAR(anual, 'FM999G999G990D00') || ';'
                   || TO_CHAR(importe, 'FM999G999G990D00') || '|';
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN -1;
   END f_cumulos_pp;

   FUNCTION f_idioma_seguro(psseguro IN NUMBER)
      RETURN NUMBER IS
      idioma         NUMBER;
      vagente_poliza seguros.cagente%TYPE;
      vcempres       seguros.cempres%TYPE;
   BEGIN
      --Bug10612 - 10/07/2009 - DCT (canviar vista personas)
      --Conseguimos el vagente_poliza y la empresa de la póliza a partir del psseguro
      SELECT cagente, cempres
        INTO vagente_poliza, vcempres
        FROM seguros
       WHERE sseguro = psseguro;

      SELECT DECODE(seguros.cidioma, 0, d.cidioma, seguros.cidioma)
        INTO idioma
        FROM seguros, tomadores, per_detper d
       WHERE seguros.sseguro = tomadores.sseguro
         AND seguros.sseguro = psseguro
         AND d.sperson = tomadores.sperson
         AND d.cagente = ff_agente_cpervisio(vagente_poliza, f_sysdate, vcempres);

      /*SELECT DECODE(seguros.cidioma, 0, personas.cidioma, seguros.cidioma)
        INTO idioma
        FROM seguros, tomadores, personas
       WHERE seguros.sseguro = tomadores.sseguro
         AND tomadores.sperson = personas.sperson
         AND seguros.sseguro = psseguro;*/

      --FI Bug10612 - 10/07/2009 - DCT (canviar vista personas)
      RETURN idioma;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 2;
   END f_idioma_seguro;

   FUNCTION f_ultima_fval(psseguro IN NUMBER)
      RETURN DATE IS
      fecha          DATE;
   BEGIN
      -- Devuelve última día del valor liquidativo informado para un contrato.
      SELECT MAX(fvalora)
        INTO fecha
        FROM valparpla, proplapen, seguros
       WHERE seguros.sseguro = psseguro
         AND seguros.sproduc = proplapen.sproduc
         AND proplapen.ccodpla = valparpla.ccodpla;

      RETURN fecha;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_ultima_fval;

   FUNCTION f_perfil_usuario(
      puser IN VARCHAR2,
      pcdelega IN NUMBER,
      pctipemp IN NUMBER,
      pcategoria IN NUMBER)
      RETURN NUMBER IS
      /****************************************************************************************
        Comprobaremos el perfil que debemos asignar al usuario.
       -- Si pctipemp = 2 (empleado Seguros) ==> perfil DEPARTAMENTO
       -- Si pctipemp = 1 (empleado Sa Nostra) y pcategoria = 1 ==> perfil DIRECTOR OFICINA
       -- Si pctipemp = 1 (empleado Sa Nostra) y pcategoria = 2 ==> perfil SUBDIRECTOR
       -- Si pctipemp = 1 (empleado Sa Nostra) y pcategoria = 3 ==> perfil INTERVENTOR
       -- Si pctipemp = 1 (empleado Sa Nostra) y pCATEGORIA = 0 ==> perfil TEMINALISTA
       -- Si pctipemp NOT IN (1,2) (OTROS) -- NO AUTORIZADO (ERROR)

          Además comprobamos si el CDELEGA (oficina) del usuario ha cambiado. Si ha cambiado la actualizamos

      *****************************************************************************************/
      PRAGMA AUTONOMOUS_TRANSACTION;
      v_cdelega_ant  NUMBER;
      traza          NUMBER;
      insertar       BOOLEAN;
      v_cconfwiz     VARCHAR2(30);
      v_cconacc      VARCHAR2(30);
      v_cconsupl     VARCHAR2(30);
      x_cconfwiz     VARCHAR2(30);
      x_cconacc      VARCHAR2(30);
      x_cconsupl     VARCHAR2(30);
   BEGIN
      BEGIN
         traza := 1;

         SELECT cdelega
           INTO v_cdelega_ant
           FROM usuarios
          WHERE cusuari = UPPER(puser);

         traza := 2;

         IF v_cdelega_ant IS NULL
            OR v_cdelega_ant <> pcdelega THEN
            UPDATE usuarios
               SET cdelega = pcdelega
             WHERE cusuari = UPPER(puser);
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 151318;   --usuario no existe
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'pac_tfv.f_perfil_usuario', traza,
                        'error no controlat', SQLERRM);
            RETURN 140999;   -- error al leer de la tabla usuarios
      END;

      insertar := FALSE;

      -- Actualizamos si corresponde el perfil de usuario
      IF pctipemp = 1
         AND pcategoria = 0 THEN   -- terminalista
         v_cconfwiz := 'CONFIG_TF';
         v_cconacc := 'ACCIONES_TF';
         v_cconsupl := 'SUPL_TF';
      ELSIF pctipemp = 1
            AND pcategoria = 1 THEN   -- director de oficina
         v_cconfwiz := 'CONFIG_TF';
         v_cconacc := 'DIRECTOR_OFICINA';
         v_cconsupl := 'SUPL_DIRECTOR';
      ELSIF pctipemp = 1
            AND pcategoria = 2 THEN   -- subdirector
         v_cconfwiz := 'CONFIG_TF';
         v_cconacc := 'ACCIONES_SUBDIR';
         v_cconsupl := 'SUPL_SUBDIRECTOR';
      ELSIF pctipemp = 1
            AND pcategoria = 3 THEN   -- interventor
         v_cconfwiz := 'CONFIG_TF';
         v_cconacc := 'ACCIONES_INTERVENTOR';
         v_cconsupl := 'SUPL_INTERVENTOR';
      ELSIF pctipemp = 2 THEN
         v_cconfwiz := 'CONFIG_DPTO';
         v_cconacc := 'ACCIONES_DPTO';
         v_cconsupl := 'SUPL_DPTO';
      ELSE
         RETURN 101901;   --paso incorrecto de parámetros a la función
      END IF;

      BEGIN
         traza := 3;

         SELECT cconfwiz, cconacc, cconsupl
           INTO x_cconfwiz, x_cconacc, x_cconsupl
           FROM pds_config_user
          WHERE cuser = UPPER(puser);

         IF NVL(x_cconfwiz, '1') <> v_cconfwiz
            OR NVL(x_cconacc, '1') <> v_cconacc
            OR NVL(x_cconsupl, '1') <> v_cconsupl THEN
            UPDATE pds_config_user
               SET cconfwiz = v_cconfwiz,
                   cconacc = v_cconacc,
                   cconsupl = v_cconsupl
             WHERE cuser = UPPER(puser);
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            insertar := TRUE;
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'pac_tfv.f_perfil_usuario', traza,
                        'error no controlat', SQLERRM);
            RETURN 140999;   -- error no controlado
      END;

      IF insertar THEN
         BEGIN
            traza := 4;

            INSERT INTO pds_config_user
                        (cuser, cconfwiz, cconacc, cconform, cconfmen, cconsupl)
                 VALUES (puser, v_cconfwiz, v_cconacc, NULL, NULL, v_cconsupl);
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'pac_tfv.f_perfil_usuario', traza,
                           'error no controlat', SQLERRM);
               RETURN 140999;   -- error no controlado
         END;
      END IF;

      COMMIT;
      RETURN 0;
   END f_perfil_usuario;

   FUNCTION f_aportaciones_pp(psseguro IN NUMBER, pano IN NUMBER)
      RETURN NUMBER IS
      impctaseguro   NUMBER(25, 10);
   BEGIN
      -- *** Bucamos la suma de las AporPromotor + AporPartícipe   +SUM(NVL(iaporsp,0))
      SELECT SUM(NVL(iaporpart, 0)) + SUM(NVL(iaporprom, 0)) + SUM(NVL(iaporprima, 0))
        INTO impctaseguro
        FROM fis_detcierrecobro
       WHERE sseguro = psseguro
         AND pfiscal = pano;

      RETURN NVL(impctaseguro, 0);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN -1;
   END f_aportaciones_pp;
END pac_tfv;

/

  GRANT EXECUTE ON "AXIS"."PAC_TFV" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_TFV" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_TFV" TO "PROGRAMADORESCSI";
