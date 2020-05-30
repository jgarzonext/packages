--------------------------------------------------------
--  DDL for Function F_CAPITALES_PP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_CAPITALES_PP" (psseguro IN NUMBER, pfecha IN DATE)
   RETURN NUMBER IS
   -- PRAGMA autonomous_transaction;

   --> El parametro pfecha indica hasta que fecha valor calculamos los datos.
   promotor       NUMBER;   --> Sperson del promtor
   aporpromomes   NUMBER := 0;
   partipromomes  NUMBER := 0;
   aporpartimesvol NUMBER := 0;
   partipartimesvol NUMBER := 0;
   aporpartimesobl NUMBER := 0;
   partipartimesobl NUMBER := 0;
   aporpromoano   NUMBER := 0;
   partipromoano  NUMBER := 0;
   aporpartianovol NUMBER := 0;
   partipartianovol NUMBER := 0;
   aporpartianoobl NUMBER := 0;
   partipartianoobl NUMBER := 0;
   spaporpromomes NUMBER := 0;
   sppartipromomes NUMBER := 0;
   spaporpromoanosi NUMBER := 0;
   sppartipromoanosi NUMBER := 0;
   spaporpromoanono NUMBER := 0;
   sppartipromoanono NUMBER := 0;
   spnofin        NUMBER := 0;
   derotros       NUMBER := 0;
   maxfecha       DATE;
   riesgo         NUMBER;
   fechaultimo    DATE;
   gbparacpromotor NUMBER := 0;
   gbparacspfin   NUMBER := 0;
   gbparacspnofin NUMBER := 0;
   gbparacparvol  NUMBER := 0;
   gbparacparobl  NUMBER := 0;
BEGIN
   SELECT sperson
     INTO riesgo
     FROM riesgos
    WHERE riesgos.sseguro = psseguro
      AND riesgos.fanulac IS NULL;

   --Bug10612 - 07/07/2009 - DCT (canviar vista personas)
   SELECT promotores.sperson
     INTO promotor
     FROM per_personas p, proplapen, seguros, promotores
    WHERE seguros.sseguro = psseguro
      AND seguros.sproduc = proplapen.sproduc
      AND promotores.ccodpla = proplapen.ccodpla
      AND p.sperson = promotores.sperson;

   /*SELECT PROMOTORES.SPERSON INTO PROMOTOR
   FROM PERSONAS, PROPLAPEN, SEGUROS, PROMOTORES
   WHERE SEGUROS.SSEGURO = psseguro
   AND SEGUROS.SPRODUC = PROPLAPEN.SPRODUC
   AND PROMOTORES.CCODPLA = PROPLAPEN.CCODPLA
   AND PERSONAS.SPERSON = PROMOTORES.SPERSON;*/

   --FI Bug10612 - 07/07/2009 - DCT (canviar vista personas)
   SELECT MAX(fvalora)
     INTO maxfecha
     FROM valparpla, proplapen, seguros
    WHERE sseguro = psseguro
      AND seguros.sproduc = proplapen.sproduc
      AND TRUNC(fvalora) <= TRUNC(pfecha)
      AND proplapen.ccodpla = valparpla.ccodpla;

   FOR r IN (SELECT   fvalmov, cmovimi, imovimi, nparpla, spermin, cmovanu, ctipapor
                 FROM ctaseguro
                WHERE sseguro = psseguro
                  -- AND TRUNC(FVALMOV) >= TO_DATE('0101' ||TO_CHAR(MAXFECHA,'YYYY')-1,'DDMMYYYY')
                  AND(TRUNC(fvalmov) <= maxfecha
                      OR ctipapor = 'SP')
                  AND cmovimi IN(1, 2)
             ORDER BY fvalmov, nnumlin) LOOP
      -- Aportaciones totales
      IF r.cmovimi IN(1, 2)
         AND NVL(r.cmovanu, 0) = 0 THEN
         IF r.spermin IS NOT NULL THEN   ---> Vamos a mirar quien ha hecho la aportación.
            IF r.spermin = promotor THEN   --> Aportacion realizada por el promotor.
               IF r.ctipapor = 'SP' THEN   --> Aportación servicios pasados
                  gbparacspfin := gbparacspfin + NVL(r.nparpla, 0);
               ELSE
                  gbparacpromotor := gbparacpromotor + NVL(r.nparpla, 0);
               END IF;
            END IF;
         ELSE   --> Aportación realizada por el partícipe
            IF r.ctipapor = 'O' THEN
               gbparacparobl := gbparacparobl + NVL(r.nparpla, 0);
            ELSE
               gbparacparvol := gbparacparvol + NVL(r.nparpla, 0);
            END IF;
         END IF;
      END IF;

      -- aPORTACIONES ANUALES
      IF r.cmovimi IN(1, 2)
         AND NVL(r.cmovanu, 0) = 0
         AND TO_CHAR(r.fvalmov, 'YYYY') = TO_CHAR(maxfecha, 'YYYY') THEN
         IF TO_CHAR(r.fvalmov, 'MM') = TO_CHAR(maxfecha, 'MM') THEN   --> Mensuales Ejercicio actual
            IF r.spermin IS NOT NULL THEN   ---> Vamos a mirar quien ha hecho la aportación.
               IF r.spermin = promotor THEN   --> Aportacion realizada por el promotor.
                  IF r.ctipapor = 'SP' THEN   --> Aportación servicios pasados
                     spaporpromomes := spaporpromomes + NVL(r.imovimi, 0);
                     sppartipromomes := sppartipromomes + NVL(r.nparpla, 0);
                  ELSE
                     aporpromomes := aporpromomes + NVL(r.imovimi, 0);
                     partipromomes := partipromomes + NVL(r.nparpla, 0);
                  END IF;
               END IF;
            ELSE   --> Aportación realizada por el partícipe
               IF r.ctipapor = 'O' THEN
                  aporpartimesobl := aporpartimesobl + NVL(r.imovimi, 0);
                  partipartimesobl := partipartimesobl + NVL(r.nparpla, 0);
               ELSE
                  aporpartimesvol := aporpartimesvol + NVL(r.imovimi, 0);
                  partipartimesvol := partipartimesvol + NVL(r.nparpla, 0);
               END IF;
            END IF;
         END IF;

         --> Ejercicio actual
         IF r.spermin IS NOT NULL THEN   ---> Vamos a mirar quien ha hecho la aportación.
            IF r.spermin = promotor THEN   --> Aportacion realizada por el promotor.
               IF r.ctipapor = 'SP' THEN   --> Aportación servicios pasados
                  spaporpromoanosi := spaporpromoanosi + NVL(r.imovimi, 0);
                  sppartipromoanosi := sppartipromoanosi + NVL(r.nparpla, 0);
               ELSE
                  aporpromoano := aporpromoano + NVL(r.imovimi, 0);
                  partipromoano := partipromoano + NVL(r.nparpla, 0);
               END IF;
            END IF;
         ELSE   --> Aportación realizada por el partícipe
            IF r.ctipapor = 'O' THEN
               aporpartianoobl := aporpartianoobl + NVL(r.imovimi, 0);
               partipartianoobl := partipartianoobl + NVL(r.nparpla, 0);
            ELSE
               aporpartianovol := aporpartianovol + NVL(r.imovimi, 0);
               partipartianovol := partipartianovol + NVL(r.nparpla, 0);
            END IF;
         END IF;
      END IF;
   END LOOP;

   -- Buscamos derechos de otros planes
   SELECT SUM(f_saldo_pp(seguros.sseguro, maxfecha, 1))
     INTO derotros
     FROM riesgos, seguros
    WHERE riesgos.sseguro = seguros.sseguro
      AND riesgos.fanulac IS NULL
      AND riesgos.sperson = riesgo
      AND seguros.cagrpro = 11
      AND seguros.csituac <> 2
      AND seguros.sseguro <> psseguro;

   BEGIN
      INSERT INTO planseguros
                  (sseguro, apmespromotor, apmessp, apmesparvol, apmesparobl,
                   apejepromotor, apejespfin, apejespnofin, apejeparvol, apejeparobl,
                   paracpromotor, paracspfin, paracparvol, paracparobl,
                   dchosconsol, dchosplanes, fechacalculo)
           VALUES (psseguro, aporpromomes, spaporpromomes, aporpartimesvol, aporpartimesobl,
                   aporpromoano, spaporpromoanosi, 0, aporpartianovol, aporpartianoobl,
                   gbparacpromotor, gbparacspfin, gbparacparvol, gbparacparobl,
                   f_saldo_pp(psseguro, maxfecha, 1), NVL(derotros, 0), TRUNC(maxfecha));
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
          -- Si el mes que estamos calculando es Enero y el último cálculo es 31/12 del año anterior
         --entonces traspasamos los datos del Ejercico al Ejercicio Anterior.
         SELECT fechacalculo
           INTO fechaultimo
           FROM planseguros
          WHERE sseguro = psseguro;

         IF TO_CHAR(fechaultimo, 'DDMM') = '3112' THEN
            UPDATE planseguros
               SET apejeantpromotor = apejepromotor,
                   apejeantspfin = apejespfin,
                   apejeantspnofin = apejespnofin,
                   apejeantparvol = apejeparvol,
                   apejeantparobl = apejeparobl,
                   parantpromotor = paracpromotor,
                   parantspfin = paracspfin,
                   parantspnofin = paracspnofin,
                   parantparvol = paracparvol,
                   parantparobl = paracparobl,
                   dchosconant = NVL(dchosconsol, 0)
             WHERE sseguro = psseguro;
         END IF;

         -- Ahora actualizamos los datos del ejercicio
         UPDATE planseguros
            SET apmespromotor = aporpromomes,
                apmessp = spaporpromomes,
                apmesparvol = aporpartimesvol,
                apmesparobl = aporpartimesobl,
                apejepromotor = aporpromoano,
                apejespfin = spaporpromoanosi,
                apejeparvol = aporpartianovol,
                apejeparobl = aporpartianoobl,
                paracpromotor = gbparacpromotor,
                paracspfin = gbparacspfin,
                paracparvol = gbparacparvol,
                paracparobl = gbparacparobl,
                dchosconsol = f_saldo_pp(psseguro, maxfecha, 1),
                dchosplanes = NVL(derotros, 0),
                fechacalculo = TRUNC(maxfecha)
          WHERE sseguro = psseguro;
   END;

   COMMIT;
   RETURN 0;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN -2;   --> No se han encontrado datos.
   WHEN OTHERS THEN
      RETURN -1;   --> Error
END f_capitales_pp;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_CAPITALES_PP" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_CAPITALES_PP" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_CAPITALES_PP" TO "PROGRAMADORESCSI";
