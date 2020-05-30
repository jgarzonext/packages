--------------------------------------------------------
--  DDL for Package Body PAC_CODIGOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_CODIGOS" AS
   /******************************************************************************
    NOMBRE:      PAC_CODIGOS
    PROPÓSITO:   Package de codigos

    REVISIONES:
    Ver        Fecha        Autor             Descripción
    ---------  ----------  ---------------  ------------------------------------
    1.0        --/--/----   ---                1. Creación del package.
    2.0        15/03/2012   MDS                2. 0019941: IAX999-IAX - Mnt. de Productos (Codigos internos) - CRT
    ******************************************************************************/
   FUNCTION f_get_tipcodigos(pcempres IN NUMBER, pcidioma IN NUMBER, pquery OUT VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      pquery := 'select * from cfg_cod_codigos where cempres = ' || pcempres
                || ' and
      cidioma = ' || pcidioma || ' and cactivo = 1';
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_codigos.f_get_tipcodigos',
                     'pcempres:' || pcempres || ' pcidioma:' || pcidioma, 1, SQLERRM);
         RETURN 111715;   --Error en la definición de la consulta
   END f_get_tipcodigos;

   FUNCTION f_get_idiomas_activos(pcempres IN NUMBER, pcidioma IN NUMBER, pquery OUT VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      pquery := 'select cidioma, tidioma from idiomas where cvisible = 1 order by tidioma asc';
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_codigos.f_get_idiomas_activos',
                     'pcempres:' || pcempres || ' pcidioma:' || pcidioma, 1, SQLERRM);
         RETURN 111715;   --Error en la definición de la consulta
   END f_get_idiomas_activos;

   FUNCTION f_set_codsproduc(
      pcempres IN NUMBER,
      pcidioma IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pccolect IN NUMBER,
      pctipseg IN NUMBER,
      pcodigo OUT VARCHAR2)
      RETURN NUMBER IS
      vcount         NUMBER;
      vcramo         NUMBER;
      trobat         BOOLEAN := FALSE;
      vret           NUMBER;
      verror         NUMBER;   -- Bug 19941 - MDS - 15/03/2011
   BEGIN
      SELECT cramo
        INTO vcramo
        FROM codiram
       WHERE cempres = pcempres
         AND ROWNUM = 1;

      SELECT COUNT(1)
        INTO vcount
        FROM productos
       WHERE cramo = pcramo
         AND cmodali = pcmodali
         AND ccolect = pccolect
         AND ctipseg = pctipseg;

      IF (vcount = 0) THEN
         SELECT COUNT(1)
           INTO vcount
           FROM codiram
          WHERE cramo = pcramo;

         IF vcount = 0 THEN
            BEGIN
               INSERT INTO codiram
                           (cramo, cempres, cgtarif, ctipcal)
                    VALUES (pcramo, pcempres, 1, 0);
            EXCEPTION
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user, 'pac_codigos.f_set_codsproduc EXISTE EL RAM',
                              'pcramo : ' || pcramo || 'pcmodali:' || pcmodali || 'pccolect:'
                              || pccolect || 'pctipseg' || 'pcempres:' || pcempres
                              || ' pcidioma:' || pcidioma,
                              1, SQLERRM);
            END;
         END IF;

         SELECT sproduc.NEXTVAL
           INTO pcodigo
           FROM DUAL;

         SELECT COUNT(1)
           INTO vcount
           FROM productos
          WHERE sproduc = pcodigo;

         IF vcount > 0 THEN
            WHILE trobat = FALSE LOOP
               pcodigo := pcodigo - 1;

               SELECT COUNT(1)
                 INTO vcount
                 FROM productos
                WHERE sproduc = pcodigo;

               IF vcount = 0 THEN
                  trobat := TRUE;
               END IF;

               IF pcodigo = 0 THEN
                  trobat := TRUE;
                  RETURN 111715;
               END IF;
            END LOOP;
         END IF;

         INSERT INTO productos
                     (ctipseg, ccolect, cramo, cmodali, cagrpro, csubpro, cactivo, ctipreb,
                      ctipges, creccob, ctippag, cpagdef, cduraci, ctempor, ctarman, ctipefe,
                      cgarsin, cvalman, ctiprie, cvalfin, cobjase, cprotec, sclaben, nedamic,
                      nedamac, nedamar, pinttec, pgasint, pgasext, iprimin, ndurcob, crecfra,
                      creteni, cimppri, cimptax, cimpcon, ccuesti, ctipcal, cimpefe, cmodelo,
                      ccalcom, creaseg, prevali, irevali, crevali, cramdgs, ctipimp, crevfpg,
                      cmovdom, sproduc, cctacor, cvinpol, cdivisa, ctipren, cclaren, nnumren,
                      cparben, ciedmac, ciedmic, ciedmar, nsedmac, cisemac, pgaexin, pgaexex,
                      cprprod, nvtomax, nvtomin, cdurmax, cligact, cpa1ren, npa1ren, tposian,
                      ciema2c, ciemi2c, ciema2r, nedma2c, nedmi2c, nedma2r, scuecar, cprorra,
                      ccompani, cprimin, cclapri, cvinpre, cdurmin, ipminfra, ndiaspro,
                      nrenova, nmaxrie, csufijo, cfeccob, nnumpag, nrecren, iminext, ccarpen,
                      csindef, ctipres, nniggar, nniigar, nparben, nbns, ctramo, cagrcon,
                      cmodnre, ctermfin)
            SELECT pctipseg, pccolect, pcramo, pcmodali, cagrpro, csubpro, cactivo, ctipreb,
                   ctipges, creccob, ctippag, cpagdef, cduraci, ctempor, ctarman, ctipefe,
                   cgarsin, cvalman, ctiprie, cvalfin, cobjase, cprotec, sclaben, nedamic,
                   nedamac, nedamar, pinttec, pgasint, pgasext, iprimin, ndurcob, crecfra,
                   creteni, cimppri, cimptax, cimpcon, ccuesti, ctipcal, cimpefe, cmodelo,
                   ccalcom, creaseg, prevali, irevali, crevali, cramdgs, ctipimp, crevfpg,
                   cmovdom, pcodigo, cctacor, cvinpol, cdivisa, ctipren, cclaren, nnumren,
                   cparben, ciedmac, ciedmic, ciedmar, nsedmac, cisemac, pgaexin, pgaexex,
                   cprprod, nvtomax, nvtomin, cdurmax, cligact, cpa1ren, npa1ren, tposian,
                   ciema2c, ciemi2c, ciema2r, nedma2c, nedmi2c, nedma2r, scuecar, cprorra,
                   ccompani, cprimin, cclapri, cvinpre, cdurmin, ipminfra, ndiaspro, nrenova,
                   nmaxrie, csufijo, cfeccob, nnumpag, nrecren, iminext, ccarpen, csindef,
                   ctipres, nniggar, nniigar, nparben, nbns, ctramo, cagrcon, cmodnre,
                   ctermfin
              FROM productos
             WHERE cramo = vcramo
               AND ROWNUM = 1;

         INSERT INTO titulopro
                     (cramo, cmodali, ctipseg, ccolect, cidioma,
                      ttitulo, trotulo)
              VALUES (pcramo, pcmodali, pctipseg, pccolect, pcidioma,
                      pcodigo || '-ALTA PRODUCTO LISTENER', 'PROD.LISTENER');

         -- Ini Bug 19941 - MDS - 15/03/2011
         verror := 0;
      ELSE
         verror := 9903453;
      -- Fin Bug 19941 - MDS - 15/03/2011
      END IF;

      vret := pac_log.f_log_actividad('AXISMNT014', f_sysdate, f_user, 1, NULL, 'SPRODUC',
                                      pcodigo,
                                      'Empresa : ' || pcempres || ' Listener ' || ' Listener ',
                                      NULL, pcidioma, NULL);
      --RETURN 0;
      RETURN verror;
   EXCEPTION
      WHEN OTHERS THEN
         pcodigo := NULL;
         p_tab_error(f_sysdate, f_user, 'pac_codigos.f_set_codsproduc',
                     'pcramo : ' || pcramo || 'pcmodali:' || pcmodali || 'pccolect:'
                     || pccolect || 'pctipseg' || 'pcempres:' || pcempres || ' pcidioma:'
                     || pcidioma,
                     1, SQLERRM);
         RETURN 111715;   --Error en la definición de la consulta
   END f_set_codsproduc;

   FUNCTION f_set_codcgarant(pcempres IN NUMBER, pcidioma IN NUMBER, pcodigo OUT VARCHAR2)
      RETURN NUMBER IS
      vcount         NUMBER;
      vcramo         NUMBER;
      trobat         BOOLEAN := FALSE;
      vdataprecicion NUMBER;
      vret           NUMBER;
   BEGIN
      SELECT data_precision
        INTO vdataprecicion
        FROM all_tab_columns
       WHERE table_name = 'CODIGARAN'
         AND column_name = 'CGARANT';

      SELECT MAX(cgarant) + 1
        INTO pcodigo
        FROM codigaran;

      IF LENGTH(pcodigo) > vdataprecicion THEN
         WHILE trobat = FALSE LOOP
            pcodigo := pcodigo - 1;

            SELECT COUNT(1)
              INTO vcount
              FROM codigaran
             WHERE cgarant = pcodigo;

            IF vcount = 0 THEN
               trobat := TRUE;
            END IF;

            IF pcodigo = 0 THEN
               trobat := TRUE;
               RETURN 111715;
            END IF;
         END LOOP;
      END IF;

      IF (pcodigo IS NOT NULL) THEN
         BEGIN
            INSERT INTO codigaran
                        (cgarant)
                 VALUES (pcodigo);

            INSERT INTO garangen
                        (cidioma, cgarant, tgarant, trotgar)
                 VALUES (pcidioma, pcodigo, pcodigo || '-CGARANT LISTENER', 'CGARANT.LISTENER');
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               p_tab_error(f_sysdate, f_user, 'pac_codigos.f_set_codgaran EXISTE el cgarant',
                           pcempres || ' pcidioma:' || pcidioma, 1, SQLERRM);
         END;
      END IF;

      vret := pac_log.f_log_actividad('AXISMNT014', f_sysdate, f_user, 1, NULL, 'CGARANT',
                                      pcodigo, 'Empresa : ' || pcempres || ' Listener ', NULL,
                                      pcidioma, NULL);
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pcodigo := NULL;
         p_tab_error(f_sysdate, f_user, 'pac_codigos.f_set_codgaran',
                     'pcempres:' || pcempres || ' pcidioma:' || pcidioma, 1, SQLERRM);
         RETURN 111715;   --Error en la definición de la consulta
   END f_set_codcgarant;

   FUNCTION f_set_codpregun(pcempres IN NUMBER, pcidioma IN NUMBER, pcodigo OUT VARCHAR2)
      RETURN NUMBER IS
      vcount         NUMBER;
      vcramo         NUMBER;
      trobat         BOOLEAN := FALSE;
      vdataprecicion NUMBER;
      vret           NUMBER;
   BEGIN
      SELECT data_precision
        INTO vdataprecicion
        FROM all_tab_columns
       WHERE table_name = 'CODIPREGUN'
         AND column_name = 'CPREGUN';

      SELECT MAX(cpregun) + 1
        INTO pcodigo
        FROM codipregun;

      IF LENGTH(pcodigo) > vdataprecicion THEN
         WHILE trobat = FALSE LOOP
            pcodigo := pcodigo - 1;

            SELECT COUNT(1)
              INTO vcount
              FROM codipregun
             WHERE cpregun = pcodigo;

            IF vcount = 0 THEN
               trobat := TRUE;
            END IF;

            IF pcodigo = 0 THEN
               trobat := TRUE;
               RETURN 111715;
            END IF;
         END LOOP;
      END IF;

      IF (pcodigo IS NOT NULL) THEN
         BEGIN
            INSERT INTO codipregun
                        (cpregun, ctippre)
                 VALUES (pcodigo, 3);

            INSERT INTO preguntas
                        (cpregun, cidioma, tpregun)
                 VALUES (pcodigo, pcidioma, pcodigo || '-CPREGUN LISTENER');
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               p_tab_error(f_sysdate, f_user,
                           'pac_codigos.f_set_CODIPREGUN EXISTE el CPREGUN',
                           pcempres || ' pcidioma:' || pcidioma, 1, SQLERRM);
         END;
      END IF;

      vret := pac_log.f_log_actividad('AXISMNT014', f_sysdate, f_user, 1, NULL, 'CPREGUN',
                                      pcodigo, 'Empresa : ' || pcempres || ' Listener ', NULL,
                                      pcidioma, NULL);
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pcodigo := NULL;
         p_tab_error(f_sysdate, f_user, 'pac_codigos.f_set_CODIPREGUN',
                     'pcempres:' || pcempres || ' pcidioma:' || pcidioma, 1, SQLERRM);
         RETURN 111715;   --Error en la definición de la consulta
   END f_set_codpregun;

   FUNCTION f_set_codramo(pcempres IN NUMBER, pcidioma IN NUMBER, pcodigo OUT VARCHAR2)
      RETURN NUMBER IS
      vcount         NUMBER;
      vcount2        NUMBER;
      vcramo         NUMBER;
      trobat         BOOLEAN := FALSE;
      vdataprecicion NUMBER;
      vret           NUMBER;
   BEGIN
      SELECT data_precision
        INTO vdataprecicion
        FROM all_tab_columns
       WHERE table_name = 'CODIRAM'
         AND column_name = 'CRAMO';

      SELECT MAX(cramo) + 1
        INTO pcodigo
        FROM codiram;

      IF LENGTH(pcodigo) > vdataprecicion THEN
         WHILE trobat = FALSE LOOP
            pcodigo := pcodigo - 1;

            SELECT COUNT(1)
              INTO vcount
              FROM codiram
             WHERE cramo = pcodigo;

            IF vcount = 0 THEN
               trobat := TRUE;
            END IF;

            IF pcodigo = 0 THEN
               trobat := TRUE;
               RETURN 111715;
            END IF;
         END LOOP;
      END IF;

      WHILE trobat = FALSE LOOP
         SELECT COUNT(1)
           INTO vcount
           FROM contadores
          WHERE ccontad = '01' || pcodigo;

         SELECT COUNT(1)
           INTO vcount2
           FROM contadores
          WHERE ccontad = '02' || pcodigo;

         vcount := NVL(vcount, 0) + NVL(vcount2, 0);

         IF vcount = 0 THEN
            trobat := TRUE;
         ELSE
            pcodigo := TO_NUMBER(pcodigo) + 1;
         END IF;
      END LOOP;

      IF (pcodigo IS NOT NULL) THEN
         BEGIN
            INSERT INTO codiram
                        (cramo, cempres, cgtarif, ctipcal)
                 VALUES (pcodigo, pcempres, 1, 0);

            INSERT INTO ramos
                        (cidioma, cramo, tramo)
                 VALUES (pcidioma, pcodigo, pcodigo || '-CRAMO LISTENER');
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'pac_codigos.f_set_CODIRAMO EXISTE el CRAMO',
                           pcempres || ' pcidioma:' || pcidioma, 1, SQLERRM);
         END;
      END IF;

      vret := pac_log.f_log_actividad('AXISMNT014', f_sysdate, f_user, 1, NULL, 'CRAMO',
                                      pcodigo, 'Empresa : ' || pcempres || ' Listener ', NULL,
                                      pcidioma, NULL);
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pcodigo := NULL;
         p_tab_error(f_sysdate, f_user, 'pac_codigos.f_set_CODIRAMO',
                     'pcempres:' || pcempres || ' pcidioma:' || pcidioma, 1, SQLERRM);
         RETURN 111715;   --Error en la definición de la consulta
   END f_set_codramo;

   FUNCTION f_set_codactivi(
      pcramo IN NUMBER,
      pcempres IN NUMBER,
      pcidioma IN NUMBER,
      pcodigo OUT VARCHAR2)
      RETURN NUMBER IS
      vcount         NUMBER;
      vcramo         NUMBER;
      trobat         BOOLEAN := FALSE;
      vdataprecicion NUMBER;
      vret           NUMBER;
   BEGIN
      SELECT data_precision
        INTO vdataprecicion
        FROM all_tab_columns
       WHERE table_name = 'CODIACTSEG'
         AND column_name = 'CACTIVI';

      SELECT NVL(MAX(cactivi), 0) + 1
        INTO pcodigo
        FROM codiactseg
       WHERE cramo = pcramo;

      IF LENGTH(pcodigo) > vdataprecicion THEN
         WHILE trobat = FALSE LOOP
            pcodigo := pcodigo - 1;

            SELECT COUNT(1)
              INTO vcount
              FROM codiactseg
             WHERE cactivi = pcodigo
               AND cramo = pcramo;

            IF vcount = 0 THEN
               trobat := TRUE;
            END IF;

            IF pcodigo = 0 THEN
               trobat := TRUE;
               RETURN 111715;
            END IF;
         END LOOP;
      END IF;

      IF (pcodigo IS NOT NULL) THEN
         BEGIN
            INSERT INTO codiactseg
                        (cramo, cactivi, cclarie)
                 VALUES (pcramo, pcodigo, 0);

            INSERT INTO activisegu
                        (cidioma, cactivi, cramo, ttitulo,
                         tactivi)
                 VALUES (pcidioma, pcodigo, pcramo, pcodigo || '- CACTIVI LISTENER',
                         'CACTIVI LISTENER');
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               p_tab_error(f_sysdate, f_user, 'pac_codigos.f_set_CACTIVI EXISTE el CACTIVI',
                           pcempres || ' pcidioma:' || pcidioma, 1, SQLERRM);
         END;
      END IF;

      vret := pac_log.f_log_actividad('AXISMNT014', f_sysdate, f_user, 1, NULL, 'CACTIVI',
                                      pcodigo, 'Empresa : ' || pcempres || ' Listener ', NULL,
                                      pcidioma, NULL);
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pcodigo := NULL;
         p_tab_error(f_sysdate, f_user, 'pac_codigos.f_set_CACTIVI',
                     'pcempres:' || pcempres || ' pcidioma:' || pcidioma, 1, SQLERRM);
         RETURN 111715;   --Error en la definición de la consulta
   END f_set_codactivi;

   FUNCTION f_set_codliterales(
      ptlitera_1 IN VARCHAR2,
      ptlitera_2 IN VARCHAR2,
      ptlitera_3 IN VARCHAR2,
      ptlitera_4 IN VARCHAR2,
      ptlitera_5 IN VARCHAR2,
      ptlitera_6 IN VARCHAR2,
      ptlitera_7 IN VARCHAR2,
      ptlitera_8 IN VARCHAR2,
      ptlitera_9 IN VARCHAR2,
      ptlitera_10 IN VARCHAR2,
      pcempres IN NUMBER,
      pcidioma IN NUMBER,
      pcodigo OUT VARCHAR2)
      RETURN NUMBER IS
      vret           NUMBER;
      vcount         NUMBER;
      vcramo         NUMBER;
      trobat         BOOLEAN := FALSE;
      vdataprecicion NUMBER;
   BEGIN
      SELECT data_precision
        INTO vdataprecicion
        FROM all_tab_columns
       WHERE table_name = 'AXIS_CODLITERALES'
         AND column_name = 'SLITERA';

      SELECT MAX(slitera) + 1
        INTO pcodigo
        FROM axis_codliterales;

      IF LENGTH(pcodigo) > vdataprecicion THEN
         WHILE trobat = FALSE LOOP
            pcodigo := pcodigo - 1;

            SELECT COUNT(1)
              INTO vcount
              FROM axis_codliterales
             WHERE slitera = pcodigo;

            IF vcount = 0 THEN
               trobat := TRUE;
            END IF;

            IF pcodigo = 0 THEN
               trobat := TRUE;
               RETURN 111715;
            END IF;
         END LOOP;
      END IF;

      IF (pcodigo IS NOT NULL) THEN
         BEGIN
            INSERT INTO axis_codliterales
                        (slitera, clitera)
                 VALUES (pcodigo, 1);

            IF ptlitera_1 IS NOT NULL THEN
               BEGIN
                  INSERT INTO axis_literales
                              (cidioma, slitera, tlitera)
                       VALUES (1, pcodigo, ptlitera_1);
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;
               END;
            END IF;

            IF ptlitera_2 IS NOT NULL THEN
               BEGIN
                  INSERT INTO axis_literales
                              (cidioma, slitera, tlitera)
                       VALUES (2, pcodigo, ptlitera_2);
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;
               END;
            END IF;

            IF ptlitera_3 IS NOT NULL THEN
               BEGIN
                  INSERT INTO axis_literales
                              (cidioma, slitera, tlitera)
                       VALUES (3, pcodigo, ptlitera_3);
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;
               END;
            END IF;

            IF ptlitera_4 IS NOT NULL THEN
               BEGIN
                  INSERT INTO axis_literales
                              (cidioma, slitera, tlitera)
                       VALUES (4, pcodigo, ptlitera_4);
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;
               END;
            END IF;

            IF ptlitera_5 IS NOT NULL THEN
               BEGIN
                  INSERT INTO axis_literales
                              (cidioma, slitera, tlitera)
                       VALUES (5, pcodigo, ptlitera_5);
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;
               END;
            END IF;

            IF ptlitera_6 IS NOT NULL THEN
               BEGIN
                  INSERT INTO axis_literales
                              (cidioma, slitera, tlitera)
                       VALUES (6, pcodigo, ptlitera_6);
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;
               END;
            END IF;

            IF ptlitera_7 IS NOT NULL THEN
               BEGIN
                  INSERT INTO axis_literales
                              (cidioma, slitera, tlitera)
                       VALUES (7, pcodigo, ptlitera_7);
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;
               END;
            END IF;

            IF ptlitera_8 IS NOT NULL THEN
               BEGIN
                  INSERT INTO axis_literales
                              (cidioma, slitera, tlitera)
                       VALUES (8, pcodigo, ptlitera_8);
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;
               END;
            END IF;

            IF ptlitera_9 IS NOT NULL THEN
               BEGIN
                  INSERT INTO axis_literales
                              (cidioma, slitera, tlitera)
                       VALUES (9, pcodigo, ptlitera_9);
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;
               END;
            END IF;

            IF ptlitera_10 IS NOT NULL THEN
               BEGIN
                  INSERT INTO axis_literales
                              (cidioma, slitera, tlitera)
                       VALUES (10, pcodigo, ptlitera_10);
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;
               END;
            END IF;
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               p_tab_error(f_sysdate, f_user, 'pac_codigos.f_set_CACTIVI EXISTE el CACTIVI',
                           pcempres || ' pcidioma:' || pcidioma, 1, SQLERRM);
         END;
      END IF;

      vret := pac_log.f_log_actividad('AXISMNT014', f_sysdate, f_user, 1, NULL, 'SLITERA',
                                      pcodigo, 'Empresa : ' || pcempres || ' Listener ', NULL,
                                      pcidioma, NULL);
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pcodigo := NULL;
         p_tab_error(f_sysdate, f_user, 'pac_codigos.f_set_CACTIVI',
                     'pcempres:' || pcempres || ' pcidioma:' || pcidioma, 1, SQLERRM);
         RETURN 111715;
   --Error en la definición de la consulta
   END f_set_codliterales;
END pac_codigos;

/

  GRANT EXECUTE ON "AXIS"."PAC_CODIGOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CODIGOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CODIGOS" TO "PROGRAMADORESCSI";
