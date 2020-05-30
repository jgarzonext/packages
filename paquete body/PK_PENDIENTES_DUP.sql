--------------------------------------------------------
--  DDL for Package Body PK_PENDIENTES_DUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PK_PENDIENTES_DUP" AS
   /******************************************************************************
      NOMBRE:       PK_PENDIENTES_DUP
      PROPÓSITO:

      REVISIONES:
      Ver        Fecha       Autor    Descripción
      ---------  ----------  -----    ------------------------------------
      1.0                             Creación del package.
      2.0        02/11/2009  APD      11595: CEM - Siniestros. Adaptación al nuevo módulo de siniestros
   ******************************************************************************/
----
   FUNCTION importdivisa(moneda IN VARCHAR2, import IN NUMBER)
      RETURN NUMBER IS
      impretorn      NUMBER;
   BEGIN
      IF moneda = 'PTA'
         OR moneda = '???' THEN
         impretorn := ROUND(import);   ----Sense decimals
      ELSIF moneda = 'EUR' THEN
         impretorn := ROUND(import * 100);   ----Amb decimals
      END IF;

      RETURN impretorn;
   END importdivisa;

----
   FUNCTION buscarppla18(ssegur IN NUMBER)
      RETURN NUMBER IS
      ntramo         NUMBER;
      vbuscar        NUMBER;
      valor          NUMBER;
      fecha          NUMBER;
      ftope          DATE;
      altre          NUMBER := 0;
      dian           VARCHAR(2);
      mesn           VARCHAR(2);
      anyn           VARCHAR(2);
      diaac          VARCHAR(2);
      mesac          VARCHAR(2);
      anyac          VARCHAR(2);
      sexe           personas.csexper%TYPE;   --       sexe           NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   BEGIN
      ----Trobem l'edat i el sexe del 2n Assegurat.
      SELECT b.csexper, TO_CHAR(b.fnacimi, 'DD') dian, TO_CHAR(b.fnacimi, 'DD') mesn,
             TO_CHAR(b.fnacimi, 'DD') anyn
        INTO sexe, dian, mesn,
             anyn
        FROM riesgos a, personas b
       WHERE a.sseguro = ssegur
         AND a.nriesgo = 2
         AND b.sperson = a.sperson;

      ----
      IF sexe = 0 THEN   --HOME
         ntramo := 195;
      ELSE   ---DONA
         ntramo := 196;
      END IF;

      ----
      ---- Calculem l'edat
      diaac := TO_CHAR(f_sysdate, 'dd');
      mesac := TO_CHAR(f_sysdate, 'mm');
      anyac := TO_CHAR(f_sysdate, 'yyyy');

      IF TO_NUMBER(mesac) < TO_NUMBER(mesn) THEN
         altre := -1;
      ELSIF TO_NUMBER(mesac) = TO_NUMBER(mesn) THEN
         IF TO_NUMBER(diaac) < TO_NUMBER(dian) THEN
            altre := -1;
         END IF;
      END IF;

      vbuscar := TO_NUMBER(anyac) - TO_NUMBER(anyn) + altre;
      ----
      -----
      ftope := TO_DATE(f_sysdate, 'dd/mm/yy');   ----Data d'efecte de la pòlissa.
      valor := NULL;

      ----Busquem al detall el vigent.
      FOR r IN (SELECT   orden, desde, NVL(hasta, desde) hasta, valor
                    FROM sgt_det_tramos
                   WHERE tramo = (SELECT detalle_tramo
                                    FROM sgt_vigencias_tramos
                                   WHERE tramo = ntramo
                                     AND fecha_efecto =
                                               (SELECT MAX(fecha_efecto)
                                                  FROM sgt_vigencias_tramos
                                                 WHERE tramo = ntramo
                                                   AND fecha_efecto <= ftope))
                ORDER BY orden) LOOP
         IF vbuscar BETWEEN r.desde AND r.hasta THEN
            ----RETURN R.valor;
            RETURN 1;
         END IF;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 0;
      WHEN OTHERS THEN
         RETURN 0;
   END buscarppla18;

-----
   FUNCTION distingirprestacions(
      ssegur IN NUMBER,
      diacontab IN DATE,
      numli NUMBER,
      codmov NUMBER)
      RETURN NUMBER IS
      CURSOR cctaseguro(csseguro NUMBER, cfcontab DATE, cnumlin NUMBER) IS
         SELECT imovimi, nsinies, sidepag
           FROM ctaseguro
          WHERE sseguro = csseguro
            AND TRUNC(fcontab) = TRUNC(cfcontab)
            AND nnumlin = cnumlin;

      rcctaseguro    cctaseguro%ROWTYPE;
      vtipcap        irpf_prestaciones.ctipcap%TYPE;   --       vtipcap        NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      vsprestaplan   prestaplan.sprestaplan%TYPE;
      retorn         NUMBER;
   BEGIN
      IF cctaseguro%ISOPEN THEN
         CLOSE cctaseguro;
      END IF;

      OPEN cctaseguro(ssegur, diacontab, numli);

      FETCH cctaseguro
       INTO rcctaseguro;

      ----
      SELECT ctipcap, sprestaplan
        INTO vtipcap, vsprestaplan
        FROM irpf_prestaciones
       WHERE sidepag = rcctaseguro.sidepag;

      IF vtipcap = 2 THEN   ----Periodica
         retorn := 5;
      ELSE   ----Parcial o total
         BEGIN
            SELECT ctipcap
              INTO vtipcap
              FROM benefprestaplan
             WHERE sprestaplan = vsprestaplan;

            IF vtipcap = 1 THEN   ----Total
               retorn := -3;
            ELSE   ----Parcial
               retorn := 3;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               retorn := 30;
         END;
      END IF;

      ----
      RETURN retorn;
   ----
   EXCEPTION
      WHEN OTHERS THEN
         CLOSE cctaseguro;

         RETURN 3;
   END distingirprestacions;

------
   PROCEDURE calcular_imports(ssegur IN NUMBER, diacontab IN DATE, numli NUMBER, codmov NUMBER) IS
      CURSOR cctaseguro(csseguro NUMBER, cfcontab DATE, cnumlin NUMBER) IS
         SELECT imovimi, nsinies, sidepag
           FROM ctaseguro
          WHERE sseguro = csseguro
            AND fcontab = cfcontab
            AND nnumlin = cnumlin;

      rcctaseguro    cctaseguro%ROWTYPE;
      v_cempres      seguros.cempres%TYPE;   --       v_cempres      NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   BEGIN
      IF cctaseguro%ISOPEN THEN
         CLOSE cctaseguro;
      END IF;

      OPEN cctaseguro(ssegur, diacontab, numli);

      FETCH cctaseguro
       INTO rcctaseguro;

      -- BUG 11595 - 02/11/2009 - APD - Adaptación al nuevo módulo de siniestros
      SELECT cempres
        INTO v_cempres
        FROM seguros
       WHERE sseguro = ssegur;

      -- Fin BUG 11595 - 02/11/2009 - APD - Adaptación al nuevo módulo de siniestros

      ----
      IF codmov IN(3, 9) THEN   -----Rescats totals, parcials, venciments i sinistres
         -----Penalització
         BEGIN
            SELECT imovimi
              INTO penal
              FROM ctaseguro
             WHERE sseguro = ssegur
               AND TRUNC(fcontab) = TRUNC(diacontab)
               AND cmovimi = '27';
         EXCEPTION
            WHEN OTHERS THEN
               penal := 0;
         END;

         brut := rcctaseguro.imovimi + penal;

         -- BUG 11595 - 02/11/2009 - APD - Adaptación al nuevo módulo de siniestros
         IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'MODULO_SINI'), 0) = 0 THEN
            ----Retenció (Almenys pels rescats).
            BEGIN
--       SELECT IRETEN
--       INTO Reten
--       FROM ULRETEN
--       WHERE SSEGURO = SSEGUR
--       AND NSINIES = RCctaseguro.nsinies;
               SELECT SUM(iretenc)
                 INTO reten
                 FROM pagosini
                WHERE nsinies = rcctaseguro.nsinies;
            EXCEPTION
               WHEN OTHERS THEN
                  reten := 0;
            END;
         ELSE
            ----Retenció (Almenys pels rescats).
            BEGIN
               SELECT SUM(iretenc)
                 INTO reten
                 FROM sin_tramita_pago
                WHERE nsinies = rcctaseguro.nsinies;
            EXCEPTION
               WHEN OTHERS THEN
                  reten := 0;
            END;
         END IF;

         -- Fin BUG 11595 - 02/11/2009 - APD - Adaptación al nuevo módulo de siniestros
         liquid := brut - reten - penal;
      ELSIF codmov IN(27) THEN   -----Traspàs de sortida
         NULL;
      ELSIF codmov IN(53) THEN   -----Prestació
         brut := rcctaseguro.imovimi;

         -- BUG 11595 - 02/11/2009 - APD - Adaptación al nuevo módulo de siniestros
         IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'MODULO_SINI'), 0) = 0 THEN
            ----Retenció (Almenys pels rescats).
            BEGIN
--       SELECT IRETEN
--       INTO Reten
--       FROM ULRETEN
--       WHERE SSEGURO = SSEGUR
--       AND NSINIES = RCctaseguro.nsinies;
               SELECT SUM(iretenc)
                 INTO reten
                 FROM pagosini
                WHERE nsinies = rcctaseguro.nsinies;
            EXCEPTION
               WHEN OTHERS THEN
                  reten := 0;
            END;
         ELSE
            ----Retenció (Almenys pels rescats).
            BEGIN
               SELECT SUM(iretenc)
                 INTO reten
                 FROM sin_tramita_pago
                WHERE nsinies = rcctaseguro.nsinies;
            EXCEPTION
               WHEN OTHERS THEN
                  reten := 0;
            END;
         END IF;

         -- Fin BUG 11595 - 02/11/2009 - APD - Adaptación al nuevo módulo de siniestros
         liquid := brut - reten;
      END IF;

      CLOSE cctaseguro;
   EXCEPTION
      WHEN OTHERS THEN
         brut := 0;
         reten := 0;
         penal := 0;
         liquid := 0;
   END;

------
   FUNCTION numsequencia(vseguro IN seguros.sseguro%TYPE)
      RETURN NUMBER IS
      vsecuencia     NUMBER;
   BEGIN
/**********
   BEGIN
     SELECT contador
       INTO vsecuencia
      FROM contador_pendientes_dup
      WHERE sseguro = vseguro;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
           vsecuencia := 0;
         INSERT INTO contador_pendientes_dup values (vseguro, 0);
   END;
   vsecuencia := vsecuencia + 1;
PK_ENV_COMU.traza(PK_AUTOM.trazas, pk_autom.depurar, TO_CHAR(vsecuencia));
    ----
   UPDATE contador_pendientes_dup SET contador = vsecuencia
   WHERE sseguro = vseguro;
   RETURN vsecuencia;
*********/
      NULL;
   END numsequencia;

------
   PROCEDURE lee IS
   BEGIN
      IF NOT seg_cv%ISOPEN THEN
         OPEN seg_cv;
      END IF;

      ----IF VTValors.Exists(1) then
      ----  VTValors.DELETE;
      ----END IF;
      sortir := FALSE;

      FETCH seg_cv
       INTO regpila;

      IF seg_cv%NOTFOUND THEN
         ------RegPila.sseguro := -1;
         CLOSE seg_cv;

         sortir := TRUE;
      ELSE
         enviar := TRUE;
         pk_env_comu.traza(pk_autom.trazas, pk_autom.depurar, TO_CHAR(regpila.sseguro));
         fecmov := regpila.ffecmov;
         impmov := regpila.iimpmov;
         codmov := regpila.ccodmov;
         coment := regpila.coment;
         tratamiento;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pk_Pendientes_Dup.Lee', 1, 'Error no controlado',
                     SQLERRM);
   END lee;

------
   PROCEDURE tratamiento IS
      incrmnt        NUMBER;
      j              NUMBER;
      com            NUMBER;
      ncert          NUMBER;
      impanterior    NUMBER;
      vfvalmov       DATE;
      tprest         NUMBER;
      diacontab      DATE;
      numli          NUMBER;
      maskpta        VARCHAR2(15) := '999G999G999G999';
      maskeur        VARCHAR2(18) := '999G999G999G999D99';
      maskcom        VARCHAR2(18);
   BEGIN
      -- Datos de Seguros
      SELECT sseguro,
             cramo,
             cmodali,
             ctipseg,
             ccolect,
             npoliza,
             cidioma,
             fefecto,
             fanulac,
             DECODE(fanulac, NULL, 'A', 'V'),
             fvencim,
             DECODE(cforpag, 1, 'A', 2, 'S', 3, 'C', 4, 'T', 6, 'B', 12, 'M', 0, 'U'),
             cbancar
        INTO regseg
        FROM seguros
       WHERE sseguro = regpila.sseguro;

      -- Determinar moneda
      BEGIN
         SELECT DECODE(cmoneda, 2, 'PTA', 3, 'EUR', '???')
           INTO moneda
           FROM tipos_producto
          WHERE cramo = regseg.cramo
            AND cmodali = regseg.cmodali
            AND ctipseg = regseg.ctipseg
            AND ccolect = regseg.ccolect;
      EXCEPTION
         WHEN OTHERS THEN
            moneda := '???';
      END;

      IF moneda = 'PTA'
         OR moneda = '???' THEN
         maskcom := maskpta;
      ELSE
         maskcom := maskeur;
      END IF;

      ----Genera el núm de seqüencia
      ---numsequencia(RegPila.sseguro);
      ----------
      IF regpila.ccodmov = 0 THEN
         DECLARE
            vcmovimi       NUMBER;
         BEGIN
            SELECT DECODE(cmovimi, 1, 1, 2, 2, 8, 23, -1)
              INTO vcmovimi
              FROM ctaseguro
             WHERE nrecibo = TO_NUMBER(SUBSTR(regpila.coment, 4, 9));

            regpila.ccodmov := vcmovimi;
         EXCEPTION
            WHEN OTHERS THEN
               RAISE noenviar;
               NULL;
         END;
      END IF;

      IF regpila.indint = 0 THEN
         IF regpila.ccodmov <= 0 THEN   ----Error
            pk_env_comu.traza(pk_autom.trazas, pk_autom.depurar, 'ERROR: CCOD no determinat');
            RAISE noenviar;
         ELSIF regpila.ccodmov = 4 THEN   ----PM i Drets.
            nreg := 1;

            ----Estudiar cridar nova funció que crida l'increment
            --Per a productes d'estalvi i PIG:
            --L'increment ha de ser el corresponent entre les dues últimes anotacions de saldo
            --Per a plans de pensions:
            --Com que el saldo s'envia l'1/7 i l'1/1 l'increment corresponendrà a l'existent cada mig any
            DECLARE
               ultimdia       DATE;
               penultimdia    DATE;
               ultimport      ctaseguro.imovimi%TYPE;   /* NUMBER(13, 2); */
               penultimport   ctaseguro.imovimi%TYPE;   --                penultimport   NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---

               CURSOR dia(ssegur NUMBER, dia DATE) IS
                  SELECT   fvalmov, imovimi
                      FROM ctaseguro
                     WHERE sseguro = ssegur
                       AND cmovimi = 0
                       AND TRUNC(fvalmov) = TRUNC(dia)
                  ORDER BY fvalmov DESC;
            BEGIN
               OPEN dia(regpila.sseguro, regpila.ffecmov);

               FETCH dia
                INTO ultimdia, ultimport;

               IF regseg.cramo = 1 THEN   ----Plans de pensions
                  CLOSE dia;

                  ----
                  IF TO_CHAR(ultimdia, 'DDMM') = '3006'
                     OR TO_CHAR(ultimdia, 'DDMM') = '3112' THEN
                     penultimdia := ADD_MONTHS(ultimdia, -6);

                     BEGIN
                        ----
                        SELECT imovimi
                          INTO penultimport
                          FROM ctaseguro
                         WHERE sseguro = regpila.sseguro
                           AND cmovimi = 0
                           AND fvalmov = penultimdia;
                     ----
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           penultimport := 0;
                     END;
                  ELSE
                     RAISE noenviar;
                  END IF;
               ELSE
                  FETCH dia
                   INTO penultimdia, penultimport;

                  IF dia%NOTFOUND THEN
                     penultimdia := ADD_MONTHS(ultimdia, -1);
                     penultimport := 0;
                  END IF;

                  CLOSE dia;
               END IF;

               ----
               BEGIN
                  SELECT SUM(DECODE(cmovimi,
                                    2, 1,
                                    1, 1,
                                    8, 1,
                                    31, -1,
                                    33, -1,
                                    34, -1,
                                    53, -1,
                                    47, -1,
                                    49, -1,
                                    52, -1,
                                    0)
                             * imovimi)
                    INTO incrmnt
                    FROM ctaseguro
                   WHERE sseguro = regpila.sseguro
                     AND fvalmov <= ultimdia
                     AND fvalmov > penultimdia;
               END;

               IF ultimport <> regpila.iimpmov THEN
                  pk_env_comu.traza(pk_autom.trazas, pk_autom.depurar,
                                    'Saldos no coincidents');
               END IF;

               incrmnt := ultimport - penultimport - incrmnt;
            ----
            END;

            vtvalors(1).impmov := importdivisa(moneda, regpila.iimpmov);
            vtvalors(1).codmov := regpila.ccodmov;
            vtvalors(1).coment := SUBSTR(TO_CHAR(incrmnt, maskcom), 1, 56);
----------------
         ELSIF regpila.ccodmov = 10 THEN   ----Rendes
            j := 1;
            vtvalors(j).impmov := importdivisa(moneda, regpila.iimpmov);
            vtvalors(j).codmov := regpila.ccodmov;
            vtvalors(j).coment := NULL;
--------------------
            j := j + 1;
            ----Genera el núm de seqüencia
            --numsequencia(RegPila.sseguro);
            reten := TO_NUMBER(SUBSTR(regpila.coment, 6, 13));
            vtvalors(j).impmov := 0;
            vtvalors(j).codmov := 20;
            p_modelcarta(54, 11, regseg.cidioma, valorfijo);
            vtvalors(j).coment := SUBSTR(valorfijo, 1, 56) || ' '
                                  || TRIM(TO_CHAR(reten, maskcom));
--------------------
            j := j + 1;
            ----Genera el núm de seqüencia
            --numsequencia(RegPila.sseguro);
            liquid := TO_NUMBER(SUBSTR(regpila.coment, 20, 13));
            vtvalors(j).impmov := 0;
            vtvalors(j).codmov := 20;
            p_modelcarta(54, 12, regseg.cidioma, valorfijo);
            vtvalors(j).coment := SUBSTR(valorfijo, 1, 56) || ' '
                                  || TRIM(TO_CHAR(liquid, maskcom));
--------------------
            nreg := j;
         ELSIF regpila.ccodmov IN(3, 9) THEN   ----Rescat total o parcial sinsitre i venciment.
            diacontab := TO_DATE(SUBSTR(regpila.coment, 4, 10), 'DD/MM/YYYY');
            numli := TO_NUMBER(SUBSTR(regpila.coment, 15, 6));
            -----
            calcular_imports(regpila.sseguro, diacontab, numli, regpila.ccodmov);
            -----
            j := 1;
            vtvalors(j).impmov := importdivisa(moneda, brut);
            vtvalors(j).codmov := regpila.ccodmov;
            vtvalors(j).coment := NULL;
            -----
            j := j + 1;

            ----Genera el núm de seqüencia
            --numsequencia(RegPila.sseguro);
            IF penal <> 0 THEN
               vtvalors(j).impmov := 0;
               vtvalors(j).codmov := 20;
               p_modelcarta(54, 10, regseg.cidioma, valorfijo);
               vtvalors(j).coment := SUBSTR(valorfijo, 1, 56) || ' '
                                     || TRIM(TO_CHAR(penal, maskcom));
               j := j + 1;
            ----Genera el núm de seqüencia
            --numsequencia(RegPila.sseguro);
            END IF;

            -------
            vtvalors(j).impmov := 0;
            vtvalors(j).codmov := 20;
            p_modelcarta(54, 11, regseg.cidioma, valorfijo);
            vtvalors(j).coment := SUBSTR(valorfijo, 1, 56) || ' '
                                  || TRIM(TO_CHAR(reten, maskcom));
            -------
            j := j + 1;
            ----Genera el núm de seqüencia
            --numsequencia(RegPila.sseguro);
            vtvalors(j).impmov := 0;
            vtvalors(j).codmov := 20;
            p_modelcarta(54, 12, regseg.cidioma, valorfijo);
            vtvalors(j).coment := SUBSTR(valorfijo, 1, 56) || ' '
                                  || TRIM(TO_CHAR(liquid, maskcom));
            ------Si cal afegir moviment de cancelació l'afegim
            nreg := j;
         ELSIF regpila.ccodmov = 20 THEN
            IF regpila.aclcod = 7 THEN   --Conversió de moneda
               vtvalors(1).impmov := 0;
               vtvalors(1).codmov := regpila.ccodmov;
               p_modelcarta(54, 7, regseg.cidioma, valorfijo);
               vtvalors(1).coment := SUBSTR(valorfijo, 1, 56);
               nreg := 1;
            ELSIF regpila.aclcod = 8 THEN   --Renovació Pla18
               vtvalors(1).impmov := 0;
               vtvalors(1).codmov := regpila.ccodmov;
               p_modelcarta(54, 8, regseg.cidioma, valorfijo);
               vtvalors(1).coment := SUBSTR(valorfijo, 1, 56);
               -----
                ----Genera el núm de seqüencia
                --numsequencia(RegPila.sseguro);
               vtvalors(2).impmov := 0;
               vtvalors(2).codmov := regpila.ccodmov;
               p_modelcarta(54, 9, regseg.cidioma, valorfijo);
               valorfijo := REPLACE(valorfijo, '#1#', buscarppla18(regpila.sseguro));
               valorfijo := REPLACE(valorfijo, '#2#',
                                    TO_CHAR(ADD_MONTHS(regpila.ffecmov, 12) - 1));
               vtvalors(2).coment := SUBSTR(valorfijo, 1, 56);
               nreg := 2;
            ELSIF regpila.aclcod = 6 THEN   --Primer periode PIG
               vtvalors(1).impmov := 0;
               vtvalors(1).codmov := regpila.ccodmov;
               p_modelcarta(54, 2, regseg.cidioma, valorfijo);
               vtvalors(1).coment := SUBSTR(valorfijo, 1, 56);
               -----
                ----Genera el núm de seqüencia
                --numsequencia(RegPila.sseguro);
               vtvalors(2).impmov := 0;
               vtvalors(2).codmov := regpila.ccodmov;
               p_modelcarta(54, 6, regseg.cidioma, valorfijo);
               valorfijo := REPLACE(coment, '#1#', SUBSTR(regpila.coment, 4, 10));
               valorfijo := REPLACE(coment, '#2#', TO_CHAR(regpila.iimpmov));
               vtvalors(2).coment := SUBSTR(valorfijo, 1, 56);
               nreg := 2;
            END IF;
         ELSIF regpila.ccodmov = 16 THEN   --Partícip passa a beneficiari
            vtvalors(1).impmov := 0;
            vtvalors(1).codmov := '16';
            vtvalors(1).coment := NULL;
            ----Genera el núm de seqüencia
            --numsequencia(RegPila.sseguro);
            vtvalors(2).impmov := 0;
            vtvalors(2).codmov := '20';
            p_modelcarta(54, 1, regseg.cidioma, valorfijo);
            vtvalors(2).coment := SUBSTR(valorfijo, 1, 56);
            nreg := 2;
         ELSIF regpila.ccodmov = 53 THEN   --Prestacions
            j := 1;
            vtvalors(j).impmov := importdivisa(moneda, regpila.iimpmov);
            tprest := distingirprestacions(regpila.sseguro, diacontab, numli, regpila.ccodmov);
            vtvalors(j).codmov := ABS(tprest);
            vtvalors(j).coment := NULL;
            nreg := j;
         ELSIF regpila.ccodmov = 27 THEN   --Traspassos de sortida
            ----Esbrinar si el traspàs és total o parcial.
            j := 1;
            vtvalors(j).impmov := importdivisa(moneda, regpila.iimpmov);
            vtvalors(j).codmov := regpila.ccodmov;
            vtvalors(j).coment := NULL;
            nreg := j;
         ELSE
            vtvalors(1).impmov := importdivisa(moneda, regpila.iimpmov);
            vtvalors(1).codmov := regpila.ccodmov;
            vtvalors(1).coment := NULL;
            nreg := 1;
         END IF;
      ELSE
         p_modelcarta(54, regpila.indint, regseg.cidioma, valorfijo);
         coment := SUBSTR(valorfijo, 1, 56);
         --------
         -----#1#: Data inici
         -----#2#: Data final
         -----#3#: Interès
         -----#4#: TAE
         -----#5#: ????
         --------
         coment := REPLACE(coment, '#1#', SUBSTR(regpila.coment, 18, 10));
         coment := REPLACE(coment, '#2#', SUBSTR(regpila.coment, 29, 10));
         coment := REPLACE(coment, '#3#', TO_CHAR(impmov, '99D99'));
         coment := REPLACE(coment, '#4#', TO_CHAR(impmov - 0.85, '99D99'));
         ------coment := REPLACE(coment, '#5#', TO_CHAR(ADD_MONTHS(fecmov,12)-1,'dd/mm/yyyy'));
         vtvalors(1).impmov := 0;
         vtvalors(1).codmov := 20;
         vtvalors(1).coment := coment;
         -------
         nreg := 1;
      END IF;

-------------
-- Lectura del numero de certificado
      BEGIN
         SELECT LPAD(polissa_ini, 13, '0')
           INTO num_certificado
           FROM cnvpolizas
          WHERE npoliza = regseg.npoliza;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            num_certificado := '0000000000000';
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'Pk_Pendientes_Dup.Tratamiento', 1,
                        'Error no controlado',
                        '(CnvPolizas) 1sseguro = ' || TO_CHAR(regseg.sseguro) || ' - '
                        || SQLERRM);
      END;

      pk_env_comu.traza(pk_autom.trazas, pk_autom.depurar, num_certificado);

      IF moneda IS NULL THEN
         moneda := '???';
      END IF;

      IF moneda = 'PTA'
         OR moneda = '???' THEN
         -- Determinar código de subproducto
         BEGIN
            SELECT producte_mu, NVL(numpol, 0)
              INTO subproducto, regseg.npoliza
              FROM cnvproductos
             WHERE TO_NUMBER(num_certificado) BETWEEN NVL(npolini, 0)
                                                  AND NVL(npolfin, 9999999999999)
               AND cramo = regseg.cramo
               AND cmodal = regseg.cmodali
               AND ctipseg = regseg.ctipseg
               AND ccolect = regseg.ccolect;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               subproducto := 0;
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'Pk_Pendientes_Dup.Tratamiento', 2,
                           'Error no controlado',
                           '(CnvProductos 1) sseguro = ' || TO_CHAR(regseg.sseguro) || ' - '
                           || SQLERRM);
         END;
      ELSIF moneda = 'EUR' THEN
         -- Determinar código de subproducto
         BEGIN
            SELECT producte_mu, NVL(numpol, 0)
              INTO subproducto, regseg.npoliza
              FROM cnvproductos
             WHERE TO_NUMBER(num_certificado) BETWEEN NVL(npolini, 0) AND NVL(npolfin,
                                                                              99999999)
               AND cramo_e = regseg.cramo
               AND cmodali_e = regseg.cmodali
               AND ctipseg_e = regseg.ctipseg
               AND ccolect_e = regseg.ccolect;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               subproducto := 0;
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'Pk_Pendientes_Dup.Tratamiento', 3,
                           'Error no controlado',
                           '(CnvProductos 1) sseguro = ' || TO_CHAR(regseg.sseguro) || ' - '
                           || SQLERRM);
         END;
      END IF;

      IF subproducto = 91 THEN
         compania := 'G038';
      ELSIF subproducto = 92 THEN
         compania := 'G069';
      ELSE
         compania := 'C569';
      END IF;

      -- Datos de Personas_ulk
      BEGIN
         SELECT sperson,
                cperhos,
                cnifhos
           INTO personaulk
           FROM personas_ulk
          WHERE sperson = (SELECT sperson
                             FROM asegurados
                            WHERE sseguro = regseg.sseguro
                              AND norden = 1);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            pk_env_comu.traza(pk_autom.trazas, pk_autom.depurar, 'NO TE PERSONA 1');
            personaulk.sperson := 0;
            personaulk.cperhos := 0;
            personaulk.cnifhos := NULL;
      END;

      -- Datos de Personas_ulk 2
      BEGIN
         SELECT sperson,
                cperhos,
                cnifhos
           INTO personaulk2
           FROM personas_ulk
          WHERE sperson = (SELECT sperson
                             FROM asegurados
                            WHERE sseguro = regseg.sseguro
                              AND norden = 2);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            pk_env_comu.traza(pk_autom.trazas, pk_autom.depurar, 'NO TE PERSONA 2');
            personaulk2.sperson := 0;
            personaulk2.cperhos := NULL;
            personaulk2.cnifhos := NULL;
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'Pk_Pendientes_Dup.Tratamiento', 4,
                        'Error no controlado',
                        '(PersonaULK2) 1sseguro = ' || TO_CHAR(regseg.sseguro) || ' - '
                        || SQLERRM);
      END;

----- DBMS_OUTPUT.PUT_LINE('PERSONAULK2');
  -- Oficina
      BEGIN
         SELECT coficin
           INTO cod_oficina
           FROM historicooficinas
          WHERE sseguro = regseg.sseguro
            AND finicio = (SELECT MAX(finicio)
                             FROM historicooficinas
                            WHERE sseguro = regseg.sseguro
                              AND finicio <= regseg.fefecto);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            cod_oficina := 0;
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'Pk_Pendientes_Dup.Tratamiento', 5,
                        'Error no controlado',
                        '(HistOficinas) 1sseguro = ' || TO_CHAR(regseg.sseguro) || ' - '
                        || SQLERRM);
      END;
   EXCEPTION
      WHEN noenviar THEN
         pk_env_comu.traza(pk_autom.trazas, pk_autom.depurar,
                           'No enviar: ' || TO_CHAR(regpila.sseguro));
         enviar := FALSE;
      WHEN OTHERS THEN
         pk_env_comu.traza(pk_autom.trazas, pk_autom.depurar,
                           '(tratamiento) sseguro = ' || TO_CHAR(regpila.sseguro) || ' - '
                           || SQLERRM);
         enviar := FALSE;
   END tratamiento;

----
   PROCEDURE close_seg(seg_cv IN OUT if_seguros.segcurtyp) AS
   BEGIN
      CLOSE seg_cv;
   END close_seg;

--------
   PROCEDURE marcar_pila IS
   BEGIN
      UPDATE pila_pendientes_dup
         SET fecha_envio = f_sysdate
       WHERE fecha_envio IS NULL
         AND TRUNC(ffecmov) <= TRUNC(f_sysdate);

      COMMIT;
   END marcar_pila;

------
   PROCEDURE actualitza(i NUMBER) IS
   BEGIN
----  secuencia := numsequencia(RegPila.sseguro);
      impmov := vtvalors(i).impmov;
      codmov := vtvalors(i).codmov;
      coment := vtvalors(i).coment;
   EXCEPTION
      WHEN OTHERS THEN
         impmov := 0;
         codmov := 0;
         coment := 'error';
         pk_env_comu.traza(pk_autom.trazas, pk_autom.depurar, SQLERRM);
   END actualitza;

------
   FUNCTION fin
      RETURN BOOLEAN IS
      fins           BOOLEAN := FALSE;
   BEGIN
      IF sortir = TRUE THEN
         fins := TRUE;
      END IF;

      RETURN fins;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pk_Pendientes_Dup.Fin', 1, 'Error no controlado',
                     '(fin) sseguro = ' || TO_CHAR(regpila.sseguro) || ' - ' || SQLERRM);
   END fin;
END pk_pendientes_dup;

/

  GRANT EXECUTE ON "AXIS"."PK_PENDIENTES_DUP" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PK_PENDIENTES_DUP" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PK_PENDIENTES_DUP" TO "PROGRAMADORESCSI";
