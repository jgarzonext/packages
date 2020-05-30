--------------------------------------------------------
--  DDL for Package Body PK_085E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PK_085E" AS
   FUNCTION f_ultimdia
      RETURN DATE IS
      vdia           DATE;
   BEGIN
      SELECT TRUNC(dultima)
        INTO vdia
        FROM tmp_ctrl_patrimoni;

      ---
      RETURN vdia;
   END f_ultimdia;

----
   PROCEDURE inicialitzar IS
   BEGIN
      avui := f_sysdate;
      ultimdia := f_ultimdia;
   END inicialitzar;

----
   PROCEDURE contracte IS
   BEGIN
      polini := LPAD(rcontra.polissa_ini, 13, '0');
      nomesmov := FALSE;
      nomesrend := FALSE;

      ---
      BEGIN
         SELECT producte_mu, DECODE(cramo, 1, 2, 9)
           INTO subprod, tiporeg
           FROM cnvproductos
          WHERE TO_NUMBER(polini) BETWEEN NVL(TO_NUMBER(npolini), 0)
                                      AND NVL(TO_NUMBER(npolfin), 99999999999999)
            AND cramo = rcontra.ram
            AND cmodal = rcontra.moda
            AND ctipseg = rcontra.tipo
            AND ccolect = rcontra.cole;
      EXCEPTION
         WHEN OTHERS THEN
            subprod := '00';
            tiporeg := 0;
      END;

      ---
      BEGIN
         SELECT coficin
           INTO oficina
           FROM historicooficinas
          WHERE sseguro = rcontra.sseguro
            AND ffin IS NULL;
      EXCEPTION
         WHEN OTHERS THEN
            oficina := 0;
      END;
   ---
   END contracte;

----
   PROCEDURE ctaseg(psseguro IN NUMBER) IS
      quants         NUMBER;
   BEGIN
      IF NOT cctas%ISOPEN THEN
         OPEN cctas(psseguro, ultimdia, avui);
      END IF;

      FETCH cctas
       INTO rcta;

      IF cctas%NOTFOUND THEN
         CLOSE cctas;

         nomesmov := TRUE;
      ELSE
         IF rcta.tipope IS NOT NULL THEN
            SELECT COUNT(*)
              INTO quants
              FROM tmp_patrimoni_enviats
             WHERE sseguro = psseguro
               AND fcontab = rcta.fcontab
               AND nnumlin = rcta.nnumlin;

            ---
            IF quants = 0 THEN
               noperaci := TO_CHAR(psseguro) || TO_CHAR(rcta.nnumlin);
               tipope := rcta.tipope;
               import1 := ABS(rcta.imovimi);
               timport1 := TO_CHAR(import1 * 1000000, 'fm09999999999999999');

               IF rcta.imovimi < 0
                  OR rcta.cmovimi IN(49, 51, 52, 53, 54) THEN
                  sigimp1 := 'P';
               ELSE
                  sigimp1 := '0';
               END IF;

               fecoper := rcta.fcontab;
               fecvalo := rcta.fvalmov;
               fecini := rcta.fcontab;
               enviar := TRUE;

               INSERT INTO tmp_patrimoni_enviats
                           (sseguro, fcontab, nnumlin, srecren, diaenv)
                    VALUES (psseguro, rcta.fcontab, rcta.nnumlin, NULL, avui);
            ELSIF quants = 1 THEN
               enviar := FALSE;
            END IF;
         ELSE
            enviar := FALSE;
         END IF;
      END IF;
   END ctaseg;

----
   PROCEDURE crendes(psseguro IN NUMBER) IS
      quants         NUMBER;
   BEGIN
      IF NOT cren%ISOPEN THEN
         OPEN cren(psseguro, ultimdia, avui);
      END IF;

      FETCH cren
       INTO rrend;

      IF cren%NOTFOUND THEN
         CLOSE cren;

         nomesrend := TRUE;
      ELSE
         SELECT COUNT(*)
           INTO quants
           FROM tmp_patrimoni_enviats
          WHERE sseguro = psseguro
            AND srecren = rrend.srecren;

         ---
         IF quants = 0 THEN
            noperaci := TO_CHAR(psseguro) || TO_CHAR(rrend.srecren);
            tipope := rrend.tipope;
            import1 := rrend.isinret;
            timport1 := TO_CHAR(import1 * 1000000, 'fm09999999999999999');
            sigimp1 := '0';
            enviar := TRUE;
            fecoper := rrend.ffecpag;
            fecvalo := rrend.ffecefe;
            fecini := rrend.ffecpag;

            ------Rendes dels productes d'estalvi s'envien amb
            ------el codi tipope = 2 com els plans de pensio
            IF rcontra.ram <> 9 THEN
               tiporeg := 2;
            END IF;

            INSERT INTO tmp_patrimoni_enviats
                        (sseguro, fcontab, nnumlin, srecren, diaenv)
                 VALUES (psseguro, NULL, NULL, rrend.srecren, avui);
         ELSIF quants = 1 THEN
            enviar := FALSE;
         END IF;
      END IF;
   END crendes;

----
   PROCEDURE finalitzar IS
   BEGIN
      UPDATE tmp_ctrl_patrimoni
         SET dultima = avui;

      ---
      DELETE      tmp_patrimoni_enviats
            WHERE diaenv < TRUNC(avui);

      ---
      COMMIT;
   ---
   END finalitzar;
END pk_085e;

/

  GRANT EXECUTE ON "AXIS"."PK_085E" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PK_085E" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PK_085E" TO "PROGRAMADORESCSI";
