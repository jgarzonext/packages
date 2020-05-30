--------------------------------------------------------
--  DDL for Function F_FITXER_BORDERO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_FITXER_BORDERO" (
   pcempres IN NUMBER,
   pidioma IN NUMBER,
   ptipo IN NUMBER,
   pmes IN NUMBER,
   pany IN NUMBER,
   pscontra IN NUMBER,
   psfacult IN NUMBER)
   RETURN NUMBER AUTHID CURRENT_USER IS
/***********************************************************************
   F_fitxer_bordero        : Crea el fitxer del bordero de reassegurança.
   paràmetres: ptipo  1.tancament definitiu (VA A REASEGURO)
                      2.tancament provisional (VA A REASEGUROAUX)
************************************************************************/
   TYPE t_cursor IS REF CURSOR;

   c_rea          t_cursor;
   v_sel          VARCHAR2(4000);
   v_tempres      VARCHAR2(40);
   v_producte     VARCHAR2(40);
   v_cia          VARCHAR2(40);
   v_tram         VARCHAR2(30);
   v_movim        VARCHAR2(30);
   v_pol_ini      NUMBER;
   v_pol_cert     VARCHAR2(15);
   v_tgarant      VARCHAR2(40);
   v_data         DATE;
   v_nom          VARCHAR2(65);
   v_nacim        DATE;
   v_nif          VARCHAR2(14);
   v_vencim_pol   DATE;
   v_edat         NUMBER;
   v_sex          NUMBER;
   v_tsex         VARCHAR2(40);
   num_err        NUMBER;
   linia          VARCHAR2(1000);
   fitxer         UTL_FILE.file_type;
   lpath          VARCHAR2(200);
   lfrom          VARCHAR2(20);
   ltfitxer       VARCHAR2(20);
   pmensa         VARCHAR2(100);

   TYPE tipus_rea IS RECORD(
      cempres        reaseguro.cempres%TYPE,
      scontra        reaseguro.scontra%TYPE,
      nversio        reaseguro.nversio%TYPE,
      ctramo         reaseguro.ctramo%TYPE,
      ccompani       reaseguro.ccompani%TYPE,
      sseguro        reaseguro.sseguro%TYPE,
      nriesgo        reaseguro.nriesgo%TYPE,
      cgarant        reaseguro.cgarant%TYPE,
      fefecto        reaseguro.fefecto%TYPE,
      fvencim        reaseguro.fvencim%TYPE,
      cgenera        reaseguro.cgenera%TYPE,
      icapces        reaseguro.icapces%TYPE,
      icesion        reaseguro.icesion%TYPE,
      pporcen        reaseguro.pporcen%TYPE,
      nsinies        reaseguro.nsinies%TYPE,
      nrecibo        reaseguro.nrecibo%TYPE,
      idtosel        reaseguro.idtosel%TYPE,
--    ipritarrea  REASEGURO.ipritarrea%TYPE,
      psobreprima    reaseguro.psobreprima%TYPE
   );

   vrea           tipus_rea;
BEGIN
   lpath := f_parinstalacion_t('PATH_ALTRE');

   IF lpath IS NULL THEN
      --DBMS_OUTPUT.put_line(112443);
      NULL;
   END IF;

   IF ptipo = 1 THEN
      lfrom := 'reaseguro';
   ELSE
      lfrom := 'reaseguroaux';
   END IF;

   v_data := LAST_DAY(TO_DATE('01/' || LPAD(pmes, 2, '0') || '/' || pany, 'dd/mm/yyyy'));
   v_sel := 'SELECT cempres, scontra,nversio,ctramo,ccompani,sseguro, '
            || 'nriesgo,cgarant,fefecto,fvencim,cgenera,icapces,icesion, '
            || 'pporcen,nsinies,nrecibo,idtosel,psobreprima ' || ' FROM ' || lfrom
            || ' WHERE cempres = ' || pcempres || ' AND trunc(fcierre) = '''
            || LAST_DAY(TO_DATE('01/' || LPAD(pmes, 2, '0') || '/' || pany, 'dd/mm/yyyy'))
            || '''';

   IF pscontra IS NOT NULL THEN
      v_sel := v_sel || ' and scontra = ' || pscontra;
   END IF;

   IF psfacult IS NOT NULL THEN
      v_sel := v_sel || ' AND sfacult = ' || psfacult;
   END IF;

   --DBMS_OUTPUT.put_line(v_sel);
   BEGIN
      --DBMS_OUTPUT.put_line(91);
      ltfitxer := 'BORDERO.txt';
      --DBMS_OUTPUT.put_line(92);
      fitxer := UTL_FILE.fopen(lpath, ltfitxer, 'w');
      --DBMS_OUTPUT.put_line(93);
      linia := 'Cia Asseguradora;Data liquidació;Producte;Contracte; '
               || 'Cia Reasseguradora;Pòlissa_ini;Polissa;Rebut;Risc;Garantia;Descripció; '
               || 'Efecte Pòlissa;Venciment Pòlissa;Venciment Cessió;Moviment; '
               || 'Capital;Porcentatge;Prima cedida;Sinistre;Assegurat; '
               || 'Data Neixement;NIF;Sexe;Edat;Descompte sel;Sobre prima;';
      UTL_FILE.put_line(fitxer, linia);

      --DBMS_OUTPUT.put_line(94);
      OPEN c_rea FOR v_sel;

      --DBMS_OUTPUT.put_line(95);
      LOOP
         --DBMS_OUTPUT.put_line(96);
         FETCH c_rea
          INTO vrea;

         EXIT WHEN c_rea%NOTFOUND;

         --busquem les descripcions i altres camps necessaris.
         -- empresa asseguradora
         BEGIN
            SELECT tempres
              INTO v_tempres
              FROM empresas
             WHERE cempres = pcempres;
         EXCEPTION
            WHEN OTHERS THEN
--               NULL;
               RETURN 1;
         END;

         -- descripció del producte
         BEGIN
            SELECT t.ttitulo
              INTO v_producte
              FROM titulopro t, seguros s
             WHERE s.sseguro = vrea.sseguro
               AND t.cramo = s.cramo
               AND t.cmodali = s.cmodali
               AND t.ccolect = s.ccolect
               AND t.ctipseg = s.ctipseg
               AND t.cidioma = pidioma;
         EXCEPTION
            WHEN OTHERS THEN
--               NULL;
               RETURN 2;
         END;

           -- descripció del tram (si es 0 a pinyó posem 'PROPI',
         -- sino busquem a valors fixes)
         IF vrea.ctramo = 0 THEN
            v_tram := 'propi';
         ELSE
            BEGIN
               SELECT tatribu
                 INTO v_tram
                 FROM detvalores
                WHERE cvalor = 105
                  AND catribu = vrea.ctramo
                  AND cidioma = pidioma;
            EXCEPTION
               WHEN OTHERS THEN
--               NULL;
                  RETURN 3;
            END;
         END IF;

         -- Cia reasseguradora
         BEGIN
            SELECT tcompani
              INTO v_cia
              FROM companias
             WHERE ccompani = vrea.ccompani;
         EXCEPTION
            WHEN OTHERS THEN
--               NULL;
               RETURN 4;
         END;

         -- polissa ini, num.polissa i certificat, venciment pòlissa
         BEGIN
            SELECT c.polissa_ini, s.npoliza || ' - ' || s.ncertif, fvencim
              INTO v_pol_ini, v_pol_cert, v_vencim_pol
              FROM cnvpolizas c, seguros s
             WHERE s.sseguro = c.sseguro
               AND s.sseguro = vrea.sseguro;
         EXCEPTION
            WHEN OTHERS THEN
--               NULL;
               RETURN 5;
         END;

         -- Descripció de la garantia
         BEGIN
            SELECT tgarant
              INTO v_tgarant
              FROM garangen
             WHERE cgarant = vrea.cgarant
               AND cidioma = pidioma;
         EXCEPTION
            WHEN OTHERS THEN
--               NULL;
               RETURN 6;
         END;

         -- Descripció del moviment de cessió
         BEGIN
            SELECT tatribu
              INTO v_movim
              FROM detvalores
             WHERE cvalor = 128
               AND catribu = vrea.cgenera
               AND cidioma = pidioma;
         EXCEPTION
            WHEN OTHERS THEN
               --DBMS_OUTPUT.put_line(SQLERRM);
               --DBMS_OUTPUT.put_line(vrea.cgenera);
               RETURN 7;
         END;

         -- Dades del assegurat
         BEGIN
            --Bug10612 - 07/07/2009 - DCT (canviar vista personas)
            SELECT SUBSTR(d.tapelli1, 0, 40) || ' ' || SUBSTR(d.tapelli2, 0, 20) || ' , '
                   || SUBSTR(d.tnombre, 0, 20),
                   p.nnumide, p.fnacimi, p.csexper
              INTO v_nom,
                   v_nif, v_nacim, v_sex
              FROM per_personas p, per_detper d, seguros s, asegurados a
             WHERE s.sseguro = a.sseguro
               AND a.sperson = p.sperson
               AND s.sseguro = vrea.sseguro
               AND d.sperson = p.sperson
               AND d.cagente = ff_agente_cpervisio(s.cagente, f_sysdate, s.cempres);
             /*SELECT p.tapelli||' , '||p.tnombre, p.nnumnif,p.fnacimi, p.csexper
             INTO v_nom, v_nif, v_nacim, v_sex
             FROM PERSONAS p, SEGUROS s, ASEGURADOS a
             WHERE s.sseguro = a.sseguro AND
         a.sperson = p.sperson AND
                   s.sseguro = vrea.sseguro;*/

         --FI Bug10612 - 07/07/2009 - DCT (canviar vista personas)
         EXCEPTION
            WHEN OTHERS THEN
--               NULL;
               RETURN 8;
         END;

         --Descripció del sexe de l'assegurat
         BEGIN
            SELECT tatribu
              INTO v_tsex
              FROM detvalores
             WHERE cvalor = 11
               AND catribu = v_sex
               AND cidioma = pidioma;
         EXCEPTION
            WHEN OTHERS THEN
--               NULL;
               RETURN 9;
         END;

         --Calculem l'edat(ACTUARIAL) de l'assegurat
         num_err := f_difdata(v_nacim, F_SYSDATE, 2, 1, v_edat);
         v_edat := NVL(v_edat, 0);
         linia := v_tempres || ';' || v_data || ';' || v_producte || ';' || v_tram || ';'
                  || v_cia || ';' || v_pol_ini || ';' || v_pol_cert || ';' || vrea.nrecibo
                  || ';' || vrea.nriesgo || ';' || vrea.cgarant || ';' || v_tgarant || ';'
                  || vrea.fefecto || ';' || v_vencim_pol || ';' || vrea.fvencim || ';'
                  || v_movim || ';' || vrea.icapces || ';' || vrea.pporcen || ';'
                  || vrea.icesion || ';' || vrea.nsinies || ';' || v_nom || ';' || v_nacim
                  || ';' || v_nif || ';' || v_tsex || ';' || v_edat || ';' || vrea.idtosel
                  || ';' || vrea.psobreprima;
         UTL_FILE.put_line(fitxer, linia);
      END LOOP;

      --DBMS_OUTPUT.put_line(97);
      CLOSE c_rea;

      --DBMS_OUTPUT.put_line(98);
      UTL_FILE.fclose(fitxer);
   --DBMS_OUTPUT.put_line(99);
   EXCEPTION
      WHEN OTHERS THEN
         -- BUG 21546_108724 - 07/02/2012 - JLTS - Cierre de posibles cursores abiertos
         IF c_rea%ISOPEN THEN
            CLOSE c_rea;
         END IF;

         --DBMS_OUTPUT.put_line(' Error global ' || SQLERRM);
         pmensa := ' Error global ' || SQLERRM;
         --DBMS_OUTPUT.put_line(999);
         UTL_FILE.fclose(fitxer);
         RETURN 11;
   END;

   RETURN 0;
END;

/

  GRANT EXECUTE ON "AXIS"."F_FITXER_BORDERO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_FITXER_BORDERO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_FITXER_BORDERO" TO "PROGRAMADORESCSI";
