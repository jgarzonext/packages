--------------------------------------------------------
--  DDL for Package Body PAC_CARGAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_CARGAS" IS
------------------------------------------------------
   FUNCTION diames(fecha DATE)
      RETURN NUMBER IS
      auxo           CHAR;
      auxo1          CHAR;
      auxo2          CHAR;
      auxotot        NUMBER(4);
   BEGIN
      RETURN TO_NUMBER(TO_CHAR(fecha, 'MM') || TO_CHAR(fecha, 'DD'));
   END diames;

----------------------------------------------------------------------------------
   FUNCTION insertar_persona(
      nperson NUMBER,
      nnif VARCHAR2,
      nombre VARCHAR2,
      papelli VARCHAR2,
      sapelli VARCHAR2,
      sexo NUMBER,
      civil NUMBER,
      banco VARCHAR2,
      tipersona NUMBER,
      fecnacimi DATE,
      telefono VARCHAR2,
      profesion NUMBER,
      vinculacion NUMBER,
      numphos NUMBER,
      nifphos VARCHAR2,
      idioma CHAR,
      tidenti NUMBER)
      RETURN NUMBER IS
      -- TAULA PERSONAS
      psperson       NUMBER(10);
      pcidioma       NUMBER(2);
      pnnumnif       VARCHAR2(10);
      ptapelli       VARCHAR2(40);
      pcpertip       NUMBER(1);
      ptbuscar       VARCHAR2(223);
      pnnifdup       NUMBER(1) := 0;
      pnnifrep       NUMBER(2) := 0;
      pcprofes       VARCHAR2(5);
      pnnumsoe       VARCHAR2(12) := NULL;
      ptnombre       VARCHAR2(20);
      pcsexper       NUMBER(1);
      pfnacimi       DATE;
      pcestciv       NUMBER(1);
      pcestado       NUMBER(1) := NULL;
      pcbancar       seguros.cbancar%TYPE;
      ptsiglas       VARCHAR2(40) := NULL;
      ptnomtot       VARCHAR2(120);
      ptperobs       VARCHAR2(200) := NULL;
      pcnifrep       NUMBER(1) := 0;
      -- TAULA PERSONAS_ULK
      pcperhos       NUMBER(7);
      pcnifhos       VARCHAR2(13);
      pcvinclo       NUMBER;
      contadornif    NUMBER := 0;
      nprof          NUMBER;
      aux1           VARCHAR2(13);
      xnifphos       VARCHAR2(13);
      inicial        VARCHAR2(1);
      xidenti        NUMBER;
      xpais          NUMBER;
   BEGIN
      -- CONTROLO ELS REPETITS
      SELECT COUNT(*)
        INTO contadornif
        FROM personas
       WHERE nnumnif = nnif;

      IF contadornif = 0 THEN
         pnnifdup := 0;
         pnnifrep := 0;
      ELSE
         SELECT (MAX(nnifrep)) + 1
           INTO pnnifrep
           FROM personas
          WHERE nnumnif = nnif;
      END IF;

      pnnumnif := nnif;
      psperson := nperson;

      IF idioma = 'E'
         OR idioma = 'E' THEN
         pcidioma := 2;
      ELSE
         pcidioma := 1;   -- AGAFARÀ EL CATALÀ PER DEFECTE
      END IF;

      ptnombre := nombre;
      ptapelli := papelli || ' ' || sapelli;   -- LA UNIO DELS DOS COGNOMS
      ptnomtot := ptapelli || ', ' || ptnombre;
      ptsiglas := NULL;
      ptbuscar := LTRIM(RTRIM(ptapelli || ' ' || ptnombre || '#' || ptsiglas || '#' || ptnomtot));
      pcsexper := sexo;
      pcestciv := civil;
      pcbancar := banco;
      ptperobs := NULL;
      pcpertip := tipersona;
      pfnacimi := fecnacimi;
      ptperobs := telefono;

      IF LTRIM(RTRIM(profesion)) IS NULL THEN
         pcprofes := 0;
      ELSE
         SELECT COUNT(cprofes)
           INTO nprof
           FROM profesiones
          WHERE cprofes = profesion;

         IF nprof = 0 THEN
            pcprofes := 0;
         ELSE
            pcprofes := profesion;
         END IF;
      END IF;

      xidenti := tidenti;

      IF xidenti IN(1, 4, 5, 6) THEN
         xpais := 100;
      ELSIF xidenti IN(3, 7) THEN
         xpais := 0;
      ELSE
         xpais := NULL;
      END IF;

      INSERT INTO personas
                  (sperson, cidioma, nnumnif, tapelli, cpertip, tbuscar, nnifdup,
                   nnifrep, cprofes, nnumsoe, tnombre, csexper, fnacimi, cestciv,
                   cestado, cbancar, tsiglas, tnomtot, tperobs, cnifrep, tapelli1,
                   tapelli2, tidenti, cpais)
           VALUES (psperson, pcidioma, pnnumnif, ptapelli, pcpertip, ptbuscar, pnnifdup,
                   pnnifrep, pcprofes, pnnumsoe, ptnombre, pcsexper, pfnacimi, pcestciv,
                   pcestado, pcbancar, ptsiglas, ptnomtot, ptperobs, pcnifrep, papelli,
                   sapelli, xidenti, xpais);

      -- DADES I INSERT A PERSONAS_ULK
      BEGIN
         IF UPPER(SUBSTR(nifphos, 1, 1)) = 'D' THEN
            xnifphos := 'D' || LPAD(SUBSTR(nifphos, 2, 12), 12, '0');
         ELSE
            xnifphos := nifphos;
         END IF;

         INSERT INTO personas_ulk
                     (sperson, cperhos, cnifhos)
              VALUES (psperson, 9999999, xnifphos);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            aux1 := SUBSTR(nifphos, 1, 12) || TO_CHAR(TO_NUMBER(SUBSTR(nifphos, 13, 1)) + 1);

            UPDATE personas_ulk
               SET cnifhos = aux1
             WHERE cnifhos = xnifphos;

            INSERT INTO personas_ulk
                        (sperson, cperhos, cnifhos)
                 VALUES (psperson, numphos, xnifphos);
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN SQLCODE;
   END insertar_persona;

----------------------------------------------------------------------------------
   FUNCTION existeix_persona(
      pnnumnif VARCHAR2,
      pcpertip NUMBER,
      ptnombre VARCHAR2,
      ptapelli1 VARCHAR2,
      ptapelli2 VARCHAR2,
      xsexe NUMBER,
      xecivil NUMBER,
      pfnacimi DATE)
      RETURN NUMBER IS
      retorn         NUMBER;
   BEGIN
      SELECT sperson
        INTO retorn
        FROM personas
       WHERE nnumnif = pnnumnif
         AND cpertip = pcpertip;

      RETURN retorn;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 0;
      WHEN TOO_MANY_ROWS THEN
         BEGIN
            IF pcpertip = 1 THEN
               SELECT MIN(sperson)
                 INTO retorn
                 FROM personas
                WHERE nnumnif = pnnumnif
                  AND fnacimi = pfnacimi;

               RETURN retorn;
            ELSE
               SELECT MIN(sperson)
                 INTO retorn
                 FROM personas
                WHERE nnumnif = pnnumnif
                  AND tapelli1 = ptapelli1;
            END IF;

            RETURN retorn;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN 0;
            WHEN OTHERS THEN
               RETURN 0;
         END;
      WHEN OTHERS THEN
         RETURN 0;
   END existeix_persona;

--------------------------------------------------------------------------------------
   FUNCTION f_trobar_poblacio(
      pcpostal IN codpostal.cpostal%TYPE,   --3606 jdomingo 30/11/2007  canvi format codi postal
      pcprovin IN NUMBER,
      ptpoblac IN VARCHAR2,
      pcpoblac OUT NUMBER)
      RETURN NUMBER IS
--------------------------------------------------------------------------------------
      CURSOR cpob(
         vcpostal codpostal.cpostal%TYPE,   --3606 jdomingo 30/11/2007  canvi format codi postal
         vcprovin NUMBER) IS
         SELECT   cpoblac, tpoblac
             FROM poblaciones
            WHERE cprovin = vcprovin
              AND cpoblac IN(SELECT cpoblac
                               FROM codpostal
                              WHERE cpostal = vcpostal)
         ORDER BY cpoblac ASC;

      reg            cpob%ROWTYPE;
      pobrentada     VARCHAR2(30);
      vtpoblac       VARCHAR2(30);
      vtpoblac2      VARCHAR2(30);
      trobat         NUMBER := 0;   --0: no trobat; 1 trobat.
      num_err        NUMBER := 0;
   BEGIN
      num_err := f_strstd(ptpoblac, vtpoblac);

      OPEN cpob(pcpostal, pcprovin);

      FETCH cpob
       INTO reg;

      WHILE(trobat = 0
            AND cpob%FOUND) LOOP
         num_err := f_strstd(reg.tpoblac, pobrentada);

         IF vtpoblac = pobrentada THEN   ----Busquem Nom Identic
            trobat := 1;
            pcpoblac := reg.cpoblac;
         ELSE
            ----Eliminem articles: L', L'H, EL, LA, ELS, LES
            IF SUBSTR(vtpoblac, 1, 2) IN('L''') THEN
               vtpoblac2 := SUBSTR(vtpoblac, 3);
            ELSIF SUBSTR(vtpoblac, 1, 3) IN('EL ', 'LA ') THEN
               vtpoblac2 := SUBSTR(vtpoblac, 4);
            ELSIF SUBSTR(vtpoblac, 1, 4) IN('ELS ', 'LES ', 'LOS ', 'LAS ') THEN
               vtpoblac2 := SUBSTR(vtpoblac, 5);
            END IF;

            IF SUBSTR(pobrentada, 1, 2) IN('L''') THEN
               pobrentada := SUBSTR(pobrentada, 3);
            ELSIF SUBSTR(pobrentada, 1, 3) IN('EL ', 'LA ') THEN
               pobrentada := SUBSTR(pobrentada, 4);
            ELSIF SUBSTR(pobrentada, 1, 4) IN('ELS ', 'LES ', 'LOS ', 'LAS ') THEN
               pobrentada := SUBSTR(pobrentada, 5);
            END IF;

            ----
            IF vtpoblac2 = pobrentada THEN
               trobat := 1;
               pcpoblac := reg.cpoblac;
            END IF;
         END IF;

         FETCH cpob
          INTO reg;
      END LOOP;

      CLOSE cpob;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pcpoblac := NULL;

         CLOSE cpob;

         trobat := 0;
         RETURN -1;
   END f_trobar_poblacio;

--------------------------------------------------------------------------------------
   FUNCTION f_insertar_poblacio(
      pcpostal IN codpostal.cpostal%TYPE,   --3606 jdomingo 30/11/2007  canvi format codi postal
      pcprovin IN NUMBER,
      ptpoblac IN VARCHAR2)
      RETURN NUMBER IS
--------------------------------------------------------------------------------------
      pcpoblac       NUMBER;
   BEGIN
      ----No es controla la coherència entre codi postal i provincia
      ----doncs se suposa que ja s'ha fet anteriorment en els diferents processos
      ----que la criden.
      SELECT MAX(NVL(cpoblac, 90000)) + 1
        INTO pcpoblac
        FROM poblaciones
       WHERE cpoblac >= 90000;

      INSERT INTO poblaciones
                  (cprovin, cpoblac, tpoblac)
           VALUES (pcprovin, pcpoblac, ptpoblac);

      INSERT INTO codpostal
                  (cprovin, cpoblac, cpostal)
           VALUES (pcprovin, pcpoblac, pcpostal);

      RETURN pcpoblac;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_insertar_poblacio;

--------------------------------------------------------------------------------------
   FUNCTION f_comparar_direccio(
      psperson IN NUMBER,
      pcdomici OUT NUMBER,
      pcpostal IN codpostal.cpostal%TYPE,   --3606 jdomingo 30/11/2007  canvi format codi postal
      pcprovin IN NUMBER,
      ptnomvia IN VARCHAR2,
      pnnumvia IN VARCHAR2,
      ptcomple IN VARCHAR2,
      pcsiglas IN VARCHAR2)
      RETURN NUMBER IS
--------------------------------------------------------------------------------------
      CURSOR direc(psperson NUMBER) IS
         SELECT cpostal, cprovin, cpoblac, csiglas, tnomvia, nnumvia, tcomple, cdomici
           FROM direcciones
          WHERE sperson = psperson;

      regdir         direc%ROWTYPE;
      trobar         NUMBER := 0;
      xpostal        codpostal.cpostal%TYPE;   --3606 jdomingo 30/11/2007  canvi format codi postal
      xprovin        NUMBER;
      xpoblac        NUMBER;
      xcdomici       NUMBER;
      vadreca        VARCHAR2(100);

--------------------------------------------------------------------------------------
      FUNCTION direccio(
         pcadre IN VARCHAR2,
         vsigles IN VARCHAR2,
         vcarrer IN VARCHAR2,
         vnumero IN NUMBER,
         vcomple IN VARCHAR2)
         RETURN NUMBER IS
--------------------------------------------------------------------------------------
         vdomicili      VARCHAR2(100);
         vadreneta      VARCHAR2(100);
         retorn         NUMBER;
      BEGIN
         vdomicili := RTRIM((vcarrer) || TO_CHAR(vnumero) || RTRIM(vcomple));
         vdomicili := REPLACE(vdomicili, ' ', NULL);
         vdomicili := REPLACE(vdomicili, ',', NULL);
         vdomicili := REPLACE(vdomicili, 'º', NULL);
         vdomicili := REPLACE(vdomicili, 'ª', NULL);
         vdomicili := REPLACE(vdomicili, '-', NULL);
         vdomicili := REPLACE(vdomicili, '.', NULL);
         vdomicili := RTRIM(LTRIM(vdomicili));
         vadreneta := REPLACE(pcadre, ' ', NULL);
         vadreneta := REPLACE(vadreneta, ',', NULL);
         vadreneta := REPLACE(vadreneta, 'º', NULL);
         vadreneta := REPLACE(vadreneta, 'ª', NULL);
         vadreneta := REPLACE(vadreneta, '-', NULL);
         vadreneta := REPLACE(vadreneta, '.', NULL);
         vadreneta := UPPER(RTRIM(LTRIM(vadreneta)));

         IF vdomicili = vadreneta THEN
            retorn := 1;
         ELSE
            retorn := 0;
         END IF;

         RETURN retorn;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN -1;
      END;
--------
   BEGIN
      vadreca := LTRIM(RTRIM(ptnomvia || pnnumvia || ptcomple));

      OPEN direc(psperson);

      LOOP
         FETCH direc
          INTO regdir;

         EXIT WHEN direc%NOTFOUND;
         trobar := direccio(vadreca, regdir.csiglas, regdir.tnomvia, regdir.nnumvia,
                            regdir.tcomple);

         IF trobar = 1 THEN
            xcdomici := regdir.cdomici;
            xpoblac := regdir.cpoblac;
            xprovin := regdir.cprovin;
            xpostal := regdir.cpostal;

            IF xpostal <> pcpostal THEN
               trobar := 0;
            END IF;

            IF xprovin <> pcprovin THEN
               trobar := 0;
            END IF;
         END IF;

         EXIT WHEN trobar = 1;
      END LOOP;

      CLOSE direc;

      IF trobar = 1 THEN
         pcdomici := xcdomici;
         RETURN 0;
      ELSE
         pcdomici := NULL;
         RETURN 0;
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         pcdomici := -1;
         RETURN 0;
-- BUG -21546_108724- 07/02/2012 - JLTS - Cierre de posibles cursores abiertos, se adiciona WHEN OTHERS
      WHEN OTHERS THEN
         IF direc%ISOPEN THEN
            CLOSE direc;
         END IF;
   END f_comparar_direccio;

--------------------------------------------------------------------------------------
   PROCEDURE p_insertar_direccio(
      psproces IN NUMBER,
      psperson IN NUMBER,
      pcdomici IN NUMBER,
      pcpostal IN codpostal.cpostal%TYPE,   --3606 jdomingo 30/11/2007  canvi format codi postal
      pcprovin IN NUMBER,
      pcpoblac IN NUMBER,
      pcsiglas IN NUMBER,
      ptnomvia IN VARCHAR2,
      pnnumvia IN NUMBER,
      ptcomple IN VARCHAR2) IS
--------------------------------------------------------------------------------------
      num_err        NUMBER;
      vnnumnif       VARCHAR2(14);
      vnnumlin       NUMBER;
   BEGIN
      INSERT INTO direcciones
                  (sperson, cdomici, cpostal, cprovin, cpoblac, csiglas, tnomvia,
                   nnumvia, tcomple)
           VALUES (psperson, pcdomici, pcpostal, pcprovin, pcpoblac, pcsiglas, ptnomvia,
                   pnnumvia, ptcomple);

      IF pcprovin = 0
         OR pcprovin = 0
         OR pcpoblac = 0 THEN
         SELECT nnumnif
           INTO vnnumnif
           FROM personas
          WHERE sperson = psperson;

         num_err := f_proceslin(psproces, 'Direccio nula persona: ' || vnnumnif, psperson,
                                vnnumlin);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         SELECT nnumnif
           INTO vnnumnif
           FROM personas
          WHERE sperson = psperson;

         num_err := f_proceslin(psproces, 'Error insertant direccio: ' || SQLERRM, psperson,
                                vnnumlin);
         num_err := f_proceslin(psproces, 'Direccio nula persona: ' || vnnumnif, psperson,
                                vnnumlin);

         INSERT INTO direcciones
                     (sperson, cdomici, cpostal, cprovin, cpoblac, csiglas, tnomvia, nnumvia,
                      tcomple)
              VALUES (psperson, pcdomici, '',   --3606 jdomingo 30/11/2007  canvi format codi postal
                                             0, 0, pcsiglas, ptnomvia, pnnumvia,
                      ptcomple);
   END p_insertar_direccio;

--------------------------------------------------------------------------------------
   FUNCTION persona(
      psproces IN NUMBER,
      tpersona IN NUMBER,
      xtnif_asse IN NUMBER,
      xnif_asseg IN VARCHAR2,
      xnom IN VARCHAR2,
      xcognom1 IN VARCHAR2,
      xcognom2 IN VARCHAR2,
      xsexe IN NUMBER,
      xecivil IN NUMBER,
      xdnaix IN DATE,
      xtipvia IN NUMBER,
      xnomvia IN VARCHAR2,
      xnumero IN NUMBER,
      xcomplement IN VARCHAR2,
      xcpostal IN VARCHAR2,
      xnpoblac IN VARCHAR2,
      xnprovin IN VARCHAR2,
      psperson OUT NUMBER,
      pcdomici OUT NUMBER)
      RETURN NUMBER IS
--------------------------------------------------------------------------------------
   -- Taula direcciones
      ptdomici       VARCHAR2(70);
      pcpostal       codpostal.cpostal%TYPE;   --3606 jdomingo 30/11/2007  canvi format codi postal
      pcprovin       NUMBER(3);
      pcpoblac       NUMBER(5);
      pcsiglas       NUMBER;
      ptnomvia       VARCHAR2(40);
      pnnumvia       NUMBER(5);
      ptcomple       VARCHAR2(15);
      ptpoblac       VARCHAR(40);
      -- Taula Personas
      pnnumnif       VARCHAR2(10);
      pcpertip       NUMBER(1);
      ptnombre       VARCHAR2(20);
      pfnacimi       DATE;
      civil          NUMBER(1);
      sexo           NUMBER(1);
      ptperobs       VARCHAR2(200) := NULL;
      ptapelli1      VARCHAR2(40);
      ptapelli2      VARCHAR2(40);
      con            NUMBER;
      vinculacion    NUMBER;
      pcprofes       NUMBER := NULL;
      num_err        NUMBER;
-- Taula Personas_ulk
      pcperhos       NUMBER(7);
      pcnifhos       VARCHAR2(13);
      tabla          VARCHAR2(100);
      vnumlin        NUMBER;
   BEGIN
      pcpertip := tpersona;
      pnnumnif := xnif_asseg;
      num_err := f_strstd(UPPER(xnom), ptnombre);
      num_err := f_strstd(UPPER(xcognom1), ptapelli1);   --primer cognom
      num_err := f_strstd(UPPER(xcognom2), ptapelli2);   --segon cognom
      sexo := xsexe;
      civil := xecivil;
      pfnacimi := xdnaix;
      pcprofes := 0;
      vinculacion := NULL;
      con := existeix_persona(pnnumnif, pcpertip, ptnombre, ptapelli1, ptapelli2, xsexe,
                              xecivil, pfnacimi);

      IF con = 0 THEN   -- no existeix i s'ha de crear. Li passo totes les dades disponibles.
         -- -- Dades i insert de PERSONAS
         SELECT sperson.NEXTVAL
           INTO psperson
           FROM DUAL;

--      dbms_output.put_line('insertem persona: '||psperson);
         num_err := insertar_persona(psperson, pnnumnif, ptnombre, ptapelli1, ptapelli2, sexo,
                                     civil, NULL, pcpertip, pfnacimi, NULL, 0, NULL, NULL,
                                     NULL, 'C', xtnif_asse);

         IF num_err <> 0 THEN
            tabla := 'Error insertant persones: ' || TO_CHAR(num_err);
            num_err := f_proceslin(psproces, tabla, psperson, vnumlin);
            RETURN num_err;
         END IF;
      ELSE
         psperson := con;
      END IF;

      -- -- Dades i insert a DIRECCIONES
      pcsiglas := xtipvia;
      ptnomvia := UPPER(xnomvia);
      pnnumvia := xnumero;
      ptcomple := xcomplement;
      pcpostal := xcpostal;   --3606 jdomingo 30/11/2007  canvi format codi postal
--DBMS_OUTPUT.put_line('cpostal '||xcpostal);
      pcprovin := TO_NUMBER(SUBSTR(xcpostal, 1, 2));
--DBMS_OUTPUT.put_line('provincia '||pcprovin);
      num_err := f_strstd(UPPER(xnpoblac), ptpoblac);

      BEGIN
         SELECT cpoblac
           INTO pcpoblac
           FROM poblaciones
          WHERE cprovin = pcprovin
            AND cpoblac IN(SELECT cpoblac
                             FROM codpostal
                            WHERE cpostal = pcpostal);
      EXCEPTION
         WHEN TOO_MANY_ROWS THEN
            ----Hi ha mes d'una poblacio amb aquest codi postal. Ex.: CASTELLAR DEL VALLES
            ----i SANT FELIU DEL RACO
            num_err := f_trobar_poblacio(pcpostal, pcprovin, ptpoblac, pcpoblac);

            IF num_err <> 0 THEN
               num_err := f_proceslin(psproces, 'Error trobant la poblacio: ' || ptpoblac,
                                      psperson, vnumlin);
            ELSE
               IF pcpoblac IS NULL THEN
                  pcpoblac := f_insertar_poblacio(pcpostal, pcprovin, ptpoblac);
               END IF;
            END IF;
         WHEN NO_DATA_FOUND THEN
            ----Falta el codi postal o no correspon a la provincia
            --3606 jdomingo 30/11/2007  canvi format codi postal , i no cal to_char doncs
            num_err := f_proceslin(psproces,
                                   'Codi postal: ' || pcpostal
                                   || ' no trobat per la provincia: ' || TO_CHAR(pcprovin),
                                   psperson, vnumlin);
            pcpoblac := NULL;
         WHEN OTHERS THEN
            num_err := f_proceslin(psproces,
                                   'Error inesperat: ' || TO_CHAR(SQLCODE) || ' buscant: '
                                   || ptpoblac,
                                   psperson, vnumlin);
            pcpoblac := NULL;
      END;

--dbms_output.put_line('D1');
      IF pcpoblac IS NULL THEN   ----Per algun motiu no s'ha identificat la poblacio
         num_err := f_proceslin(psproces, 'Poblacio no trobada: ' || ptpoblac, psperson,
                                vnumlin);
         --3606 jdomingo 30/11/2007  canvi format codi postal    i no cal to_char doncs, i no es pot posar a 0
         num_err := f_proceslin(psproces,
                                'Codi postal: ' || pcpostal || ', Provincia: '
                                || TO_CHAR(pcprovin),
                                psperson, vnumlin);
         pcpostal := '';
         pcprovin := 0;
         pcpoblac := 0;
      END IF;

      ----
      BEGIN
         IF con <> 0 THEN   ----La persona no es nova.
--dbms_output.put_line('D2');
            num_err := f_comparar_direccio(psperson, pcdomici, pcpostal, pcprovin, ptnomvia,
                                           pnnumvia, ptcomple, pcsiglas);

            IF pcdomici IS NULL THEN   ----Direccio no trobada
               BEGIN
                  SELECT NVL(MAX(cdomici), 0) + 1
                    INTO pcdomici
                    FROM direcciones
                   WHERE sperson = psperson;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     pcdomici := 1;
               END;

               p_insertar_direccio(psproces, psperson, pcdomici, pcpostal, pcprovin, pcpoblac,
                                   pcsiglas, ptnomvia, pnnumvia, ptcomple);
            END IF;
         ELSE
--dbms_output.put_line('D3');
            pcdomici := 1;   --- Segur que serà la primera adreça
            p_insertar_direccio(psproces, psperson, pcdomici, pcpostal, pcprovin, pcpoblac,
                                pcsiglas, ptnomvia, pnnumvia, ptcomple);
         END IF;
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
--      dbms_output.put_line('Error amb persones: '||SQLERRM);
         RETURN -1;
   END persona;
END;

/

  GRANT EXECUTE ON "AXIS"."PAC_CARGAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CARGAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CARGAS" TO "PROGRAMADORESCSI";
