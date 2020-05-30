--------------------------------------------------------
--  DDL for Function F_CALCUL_TMPCAMPA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_CALCUL_TMPCAMPA" (pcempres IN NUMBER, pcpromoc IN NUMBER, pfinicio IN DATE, pffin IN DATE)
   RETURN NUMBER authid current_user IS

   num_err NUMBER;
   num_err2 NUMBER;
   lsproces NUMBER;
   --
   l_prima_ant  NUMBER;
   l_prima_act  NUMBER;
   l_primaanual NUMBER;
   l_acu_inc    NUMBER;
   l_suspes     NUMBER;
   l_quants     NUMBER := 0;
   l_iprianu    NUMBER;
   l_quants_anu NUMBER := 0;
   --
   NOUTIT NUMBER := 0;
   ACUMNOUTIT  NUMBER := 0;

   EXTRA   NUMBER := 0;
   DEVOL   NUMBER := 0;
   TRASPAS NUMBER := 0;
   lper    NUMBER := 0;
   ACUMEXTRA  NUMBER := 0;
   ACUMDEVOL  NUMBER := 0;
   ACUMTRASP  NUMBER := 0;
   ACUMEXTRAPROT  NUMBER := 0;
   ACUMDEVOLPROT  NUMBER := 0;
   ACUMTRASPPROT  NUMBER := 0;
   ACUMNUMPROT    NUMBER := 0;
   acunumpol      NUMBER := 0;
   acumper        NUMBER := 0;
   NI             NUMBER := 0;
   TOT            NUMBER := 0;
   tot_amb_per    NUMBER := 0;
   TOTprot        NUMBER := 0;
   lfinicio       DATE;

   -- cursor de oficines
   CURSOR c_zo IS
      SELECT f_zona_ofi(2,coficin) zona, coficin
      FROM oficinas;

   -- Cursor de polisses per oficina
   CURSOR c_pol(wcoficin NUMBER, wcpromoc NUMBER)  IS /* Campanya PP = 11, campanya PPA = 12 */
      SELECT s.sseguro, s.cramo, s.cmodali, s.ctipseg, s.ccolect
      FROM seguros s, historicooficinas h
      WHERE wcpromoc = 11     -- Campanya PP
        AND s.cramo = 1
        AND s.cmodali = 1
        AND ctipseg >0
        AND s.ccolect = 0
        AND s.sseguro = h.sseguro
        AND h.ffin IS NULL
        AND h.coficin = wcoficin
     UNION
      SELECT s.sseguro, s.cramo, s.cmodali, s.ctipseg, s.ccolect
      FROM seguros s, historicooficinas h
      WHERE wcpromoc = 12     -- Campanya PPA
        AND s.cramo = 2
        AND s.cmodali = 2
        AND ctipseg = 3
        AND s.ccolect = 1
        AND s.sseguro = h.sseguro
        AND h.ffin IS NULL
        AND h.coficin = wcoficin ;

   CURSOR CNTIT (VOFICIN NUMBER,Vpfinicio DATE,Vpffin DATE, wcpromoc NUMBER) IS
      SELECT COUNT(s.sseguro) vnous
      FROM seguros s, asegurados a, HISTORICOOFICINAS H
      WHERE s.sseguro = a.sseguro
         AND CRAMO = 1
         AND CMODALI = 1
         AND CTIPSEG > 0
         AND CCOLECT = 0
         AND s.fefecto >= Vpfinicio
         AND s.fefecto < Vpffin
         AND a.norden = 1
         AND H.SSEGURO = S.SSEGURO
         AND H.COFICIN = VOFICIN
         AND H.FFIN IS NULL
         AND NOT EXISTS ( SELECT s2.sseguro
                          FROM asegurados a2, seguros s2
                          WHERE a2.sseguro = s2.sseguro
                           AND S2.CRAMO = 1
                           AND S2.CMODALI = 1
                     	   AND S2.CTIPSEG > 0
                           AND S2.CCOLECT = 0
                           AND a2.sperson = a.sperson
                           AND a2.norden = 1
                           AND s2.fefecto < s.fefecto
                           AND s2.csituac IN (0,4,5)
                        );
BEGIN
   num_err := f_procesini(F_USER, pcempres, 'TMP_CAMPA', 'Càlcul dades llistat campanya',
                          lsproces);
   IF num_err <> 0 THEN
      ROLLBACK;
      RETURN num_err;
   ELSE
      COMMIT;
   END IF;
   num_Err := 0;
   -- Insertem la capçalera del proces
   INSERT INTO cab_tmp_campa (sproces ,fcalcul ,fcalsal )
          VALUES (lsproces, pffin,TRUNC(LAST_DAY(ADD_MONTHS(pffin,-1))) );
   -- Insertem per zona i oficina el nº de contractes i el saldo
   -- de totes les pòlisses vigents a data pffin
   BEGIN
      INSERT INTO tmp_campa (sproces, cpromoc, czona, coficin, ncontratos, isaldo)
             SELECT lsproces, pcpromoc, zona, coficin, COUNT(sseguro), SUM(imovimi)
             FROM
                (
                SELECT f_zona_ofi(s.cempres, h.coficin) zona,
                       h.coficin,s.sseguro,c.imovimi
                FROM seguros s, ctaseguro c, historicooficinas h
                WHERE s.cramo = 1
                  AND s.cmodali = 1
                  AND s.ctipseg >0
                  AND s.ccolect = 0
                  --AND (s.fanulac > pffin OR s.fanulac IS NULL )
                  --AND (s.fvencim > pffin OR s.fvencim IS NULL )
                  AND h.sseguro = s.sseguro
                  AND h.ffin IS NULL
                  AND s.sseguro = c.sseguro
                  AND c.cmovimi = 0 -- Saldo
                  AND TRUNC(c.fvalmov) = TRUNC(LAST_DAY(ADD_MONTHS(pffin,-1)))
                )
             GROUP BY zona, coficin;
      COMMIT;
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         num_Err2 := f_procesfin(lsproces, 999);
         RETURN num_err;
   END;
   -- Insertem per zona i oficina el nº de contractes i el saldo
   -- de totes les pòlisses vigents a l'any anterior a data pffin
   BEGIN
      INSERT INTO tmp_campa (sproces, cpromoc, czona, coficin, ncontratos_ant, isaldo_ant)
             SELECT lsproces, pcpromoc, zona, coficin, COUNT(sseguro), SUM(imovimi)
             FROM
                (
                 SELECT f_zona_ofi(s.cempres, h.coficin) zona,
                        h.coficin,
                        s.sseguro, c.imovimi
                 FROM seguros s, ctaseguro c, historicooficinas h
                 WHERE s.cramo = 1
                   AND s.cmodali = 1
                   AND s.ctipseg >0
                   AND s.ccolect = 0
                   --AND (s.fanulac > ADD_MONTHS(pffin,-12) OR s.fanulac IS NULL )
                   --AND (s.fvencim > ADD_MONTHS(pffin,-12) OR s.fvencim IS NULL )
                   AND h.sseguro = s.sseguro
                   AND h.ffin IS NULL
                   AND s.sseguro = c.sseguro
                   AND c.cmovimi = 0 -- Saldo
                   AND TRUNC(c.fvalmov) = TRUNC(LAST_DAY(ADD_MONTHS(pffin,-13)))
                )
             GROUP BY zona, coficin;
      COMMIT;
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         num_Err2 := f_procesfin(lsproces, 888);
         RETURN num_err;
   END;

   FOR v_zo IN c_zo LOOP
      l_acu_inc := 0;   -- Periodica
      acumextra := 0;   -- Extres
      acumdevol := 0;   -- Devol
      acumtrasp := 0;   -- Traspas
      acumper   := 0;   -- Periòdiques
      ACUMNUMPROT := 0;
      acunumpol   := 0; -- Nº contractes
      acumextraprot := 0;   -- Extres
      acumdevolprot := 0;   -- Devol
      acumtraspprot := 0;   -- Traspas
      l_iprianu := 0;       -- Prima anual
      l_quants_anu := 0;    -- Quantes pòlisses amb prima anual.
      FOR v_pol IN c_pol(v_zo.coficin, pcpromoc) LOOP

         ---------------------------------------------------------------------
         ------------ INCREMENTS DE PERIODICA      ---------------------------
         ---------------------------------------------------------------------
         -- Veure si està suspesa
         l_suspes := 0;
         BEGIN
            SELECT DECODE(fsusapo,NULL,0,1) INTO l_suspes
            FROM seguros_aho
            WHERE sseguro = v_pol.sseguro;
         EXCEPTION
            WHEN  NO_DATA_FOUND THEN
               l_suspes := 0;
         END;
         IF l_suspes = 0 THEN
            BEGIN
               SELECT g.iprianu INTO l_prima_act
               FROM seguros s, garanseg g
               WHERE s.sseguro = v_pol.sseguro
                 AND s.sseguro = g.sseguro
                 AND g.finiefe <= TRUNC(SYSDATE)
                 AND (g.ffinefe > TRUNC(SYSDATE) OR g.ffinefe IS NULL)
                 AND g.cgarant = 48;
            EXCEPTION
               WHEN OTHERS THEN
                  l_prima_act := 0;
            END;
            BEGIN
               SELECT g.iprianu INTO l_primaANUAL
               FROM seguros s, garanseg g
               WHERE s.sseguro = v_pol.sseguro
                 AND s.sseguro = g.sseguro
                 AND  g.ffinefe IS NULL
                 AND g.cgarant = 48;
            EXCEPTION
               WHEN OTHERS THEN
                  l_primaANUAL := 0;
            END;

            IF l_primaanual <> 0 THEN
               l_iprianu := l_iprianu + l_primaANUAL;
               l_quants_anu := l_quants_anu + 1;
            END IF;

            BEGIN
               SELECT finicio INTO lfinicio
               FROM codipromociones
               WHERE cpromoc = pcpromoc;

               SELECT g.iprianu INTO l_prima_ant
               FROM seguros s, garanseg g
               WHERE s.sseguro = v_pol.sseguro
                 AND s.sseguro = g.sseguro
                 AND g.finiefe < lfinicio
                 AND (g.ffinefe >= lfinicio OR g.ffinefe IS NULL)
                 AND g.cgarant = 48;
            EXCEPTION
               WHEN OTHERS THEN
                  --l_prima_act := 0; --Si no hy ha anterior es Nou tit i no el tenim en compte
                  l_prima_ant := 0;
            END;
            IF l_prima_act - l_prima_ant >= 960 THEN
               --l_acu_inc := l_acu_inc + l_prima_act - l_prima_ant;
               l_acu_inc := l_acu_inc + 1;
            END IF;
         END IF;
         ---------------------------------------
         ------- Aportacions extres ------------
         --------------------------------------
         EXTRA  := 0;
         DEVOL  := 0;
         TRASPAS:= 0;
         lper   := 0;
         BEGIN
            SELECT SUM(NVL(c.imovimi,0))
            INTO extra
            FROM CTASEGURO c
            WHERE C.sseguro = v_pol.sseguro
            AND c.fvalmov  BETWEEN pfinicio AND pffin
            AND c.cmovimi = 1
            AND c.cmovanu = 0;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               EXTRA := 0;
         END;

         BEGIN
            SELECT SUM(NVL(IMOVIMI,0))
            INTO traspas
            FROM CTASEGURO c,TRASPLAINOUT t
            WHERE C.sseguro = v_pol.sseguro
              AND c.sseguro = t.sseguro
              AND c.nnumlin = t.nnumlin
              AND t.ctiptras = 1
              AND t.cestado = 4
              AND NOT EXISTS (SELECT 1
                              FROM proplapen
                              WHERE ccodpla = t.ccodpla )
              AND c.fvalmov BETWEEN pfinicio AND pffin
              AND c.cmovimi in (8);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               TRASPAS := 0;
         END;

         BEGIN
            SELECT SUM(NVL(imovimi,0))
            INTO devol
            FROM CTASEGURO c
            WHERE C.sseguro = v_pol.sseguro
            AND c.fvalmov BETWEEN pfinicio AND pffin
            AND c.cmovimi IN (49,52);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               DEVOL := 0;
         END;
         -- Suma de periòdiques
         BEGIN
            SELECT SUM(NVL(imovimi,0))
            INTO lper
            FROM CTASEGURO c
            WHERE C.sseguro = v_pol.sseguro
            AND c.fvalmov BETWEEN pfinicio AND pffin
            AND c.cmovimi =2;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               lper := 0;
         END;

         ACUMEXTRA := ACUMEXTRA + NVL(EXTRA,0);
         ACUMTRASP := ACUMTRASP + NVL(TRASPAS,0);
         ACUMDEVOL := ACUMDEVOL + NVL(DEVOL,0);
         acumper   := acumper   + NVL(lper,0);
         --- Protegit
         IF v_pol.cramo = 1 AND v_pol.cmodali=1 AND v_pol.ctipseg=4 AND v_pol.ccolect = 0 THEN
            ACUMEXTRAPROT := ACUMEXTRAprot + NVL(EXTRA,0);
            ACUMTRASPPROT := ACUMTRASPprot + NVL(TRASPAS,0);
            ACUMDEVOLPROT := ACUMDEVOLprot + NVL(DEVOL,0);
            IF NVL(EXTRA,0) <>0 OR NVL(TRASPAS,0)<>0 OR NVL(DEVOL,0) <> 0 THEN
               acumnumprot   := acumnumprot + 1;
            END IF;
         END IF;
         ----------------------------------------------------------------
         ------ Acumular nº de pòlisses
         ----------------------------------------------------------------
         IF NVL(EXTRA,0) <>0 OR NVL(TRASPAS,0)<>0 OR NVL(DEVOL,0) <> 0 OR lper <> 0 THEN
            acunumpol := acunumpol + 1;
         END IF;
         ----------------
         --- Fi extres
         --------------
         l_quants := l_quants +1;
         IF l_quants >= 100 THEN
            COMMIT;
            l_quants := 0;
         END IF;
      END LOOP;
      IF l_acu_inc <> 0 THEN
         ---------------------------------------------------------------------
         ------------ INCREMENTS DE PERIODICA      ---------------------------
         ---------------------------------------------------------------------
         INSERT INTO tmp_campa (sproces, cpromoc, czona, coficin, iincper)
                VALUES (lsproces,pcpromoc,v_zo.zona, v_zo.coficin, l_acu_inc);
      END IF;
      IF l_iprianu <> 0 THEN
         ---------------------------------------------------------------------
         ------------ CONTRACTES AMB PERIODICA      ---------------------------
         ---------------------------------------------------------------------
         INSERT INTO tmp_campa (sproces, cpromoc, czona, coficin, ncontper, iperanu)
                VALUES (lsproces,pcpromoc,v_zo.zona, v_zo.coficin, l_quants_anu, l_iprianu);

      END IF;
      TOT:=ACUMEXTRA+ACUMTRASP-ACUMDEVOL;
      IF TOT <> 0 THEN
         ---------------------------------------------------------------------
         ------------ APORTACIONS EXTRES      ---------------------------
         ---------------------------------------------------------------------
         INSERT INTO tmp_campa (sproces, cpromoc, czona, coficin, iextnet)
                VALUES (lsproces, pcpromoc, v_zo.zona, v_zo.coficin, TOT);
      END IF;
      totprot := ACUMEXTRAPROT+ACUMTRASPPROT-ACUMDEVOLPROT;
      IF totprot <> 0 THEN
         ---------------------------------------------------------------------
         ------------ APORTACIONS EXTRES  PROT    ---------------------------
         ---------------------------------------------------------------------
         INSERT INTO tmp_campa (sproces, cpromoc, czona, coficin,isaldoprot,ncontraprot )
                VALUES (lsproces, pcpromoc, v_zo.zona, v_zo.coficin, TOTprot,acumnumprot);
      END IF;
      tot_amb_per :=acumextra + acumtrasp - acumdevol + acumper;
      IF TOT_AMB_PER <> 0 THEN
         ---------------------------------------------------------------------
         --------------- APORTACIONS EXTRES + PERIÔDIQUES ACUMULADES
         ---------------------------------------------------------------------
         INSERT INTO tmp_campa (sproces, cpromoc, czona, coficin,iaportot, nnumpol )
                VALUES (lsproces, pcpromoc, v_zo.zona, v_zo.coficin, TOT_amb_per, acunumpol);
      END IF;
      -----------------------------------
      ---------- NOUS TITULARS ----------
      ----------------------------------
      FOR REG IN cntit(v_zo.COFICIN,pfinicio,pffin, pcpromoc) LOOP
         IF reg.vnous <> 0 THEN
            INSERT INTO tmp_campa (sproces, cpromoc, czona, coficin,nnuevos)
                   VALUES (lsproces, pcpromoc, v_zo.zona, v_zo.coficin, reg.vnous);
         END IF;
      END LOOP;
      NI := NI + 1;
      IF NI >= 10 THEN
         COMMIT;
         NI := 0;
      END IF;
   END LOOP;
   COMMIT;

-----------
----------
   -- PUNTS ACONSEGUITS
   BEGIN
      INSERT INTO tmp_campa (sproces, cpromoc, czona, coficin, npuntos)
         SELECT lsproces, pcpromoc, zona, coficin, SUM(npuntos)
         FROM (
             SELECT f_zona_ofi(s.cempres, h.coficin) zona, h.coficin, d.npuntos
             FROM seguros s, historicooficinas h, detctaempleados d, detctaseg ds
             WHERE d.cpromoc = pcpromoc
               AND d.cpromoc = ds.cpromoc
               AND d.sperson = ds.sperson
               AND d.nnumlim = ds.nnumlim
               AND d.nlindet = ds.nlindet
               AND ds.norden = 1
               AND ds.sseguro = s.sseguro
               AND s.sseguro = h.sseguro
               AND h.ffin IS NULL
               AND NVL(d.cinvalid,0) = 0
             )
          GROUP BY zona, coficin;
      COMMIT;
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         num_Err2 := f_procesfin(lsproces, 444);
         RETURN num_err;
   END;
   num_Err := f_procesfin(lsproces, 0);
   COMMIT;
   RETURN 0;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_CALCUL_TMPCAMPA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_CALCUL_TMPCAMPA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_CALCUL_TMPCAMPA" TO "PROGRAMADORESCSI";
