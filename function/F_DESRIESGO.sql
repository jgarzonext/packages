--------------------------------------------------------
--  DDL for Function F_DESRIESGO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_DESRIESGO" (
   psseguro IN NUMBER,
   pnriesgo IN NUMBER,
   pfriesgo IN DATE,
   pcidioma IN NUMBER,
   ptriesgo1 OUT VARCHAR2,
   ptriesgo2 OUT VARCHAR2,
   ptriesgo3 OUT VARCHAR2,
   pnmovimi IN NUMBER DEFAULT NULL   -- Bug 26923/148935 - 11/07/2013 - AMC
                                  )
   RETURN NUMBER AUTHID CURRENT_USER IS
/****************************************************************************
   F_DESRIESGO: Descripción del riesgo en función del tipo de producto.
          pnriesgo es opcional  y pfriesgo es obligatorio cuando
          el parámetro pnriesgo no está informado.
   ALLIBMFM.

    Controlem que hi hagi el risc quan tenim una direcció
    Controlem el risc personal quan tenim un producte per
          direccions
    Tenim en compte el cobjase = 4 (Innominados)
          Desapareix el csubpro = 2 com innominat
    Desaparece el campo seguros.nasegur
    Tenim en compte el camp riesgos.nasegur

    Aumentamos la longitud de las variables ptlin1,
    ptlin2 y ptlin3, ya que tambien se ha aumentado la longitud
    del campo tdomici de la tabla sitriesgo.
****************************************************************************/
   wsseguro       NUMBER;
   wnriesgo       NUMBER(3);
   wcobjase       NUMBER;
   wcsubpro       NUMBER;
   wsperson       NUMBER;
   wtnatrie       VARCHAR2(300);
   x_matricula    VARCHAR2(12);
   x_versio       VARCHAR2(11);
   x_marca        VARCHAR2(40);
   x_modelo       VARCHAR2(40);
   texto          VARCHAR2(400);
   texto1         VARCHAR2(400);
   texto2         VARCHAR2(400);
   ptlin1         VARCHAR2(400);
   ptlin2         VARCHAR2(400);
   ptlin3         VARCHAR2(400);
   longitud       NUMBER;
   num_err        NUMBER;
   contador       NUMBER := 0;
   paso           NUMBER := 0;   -- dra 27-8-08: bug mantis 7372
   vcagente       NUMBER;

   CURSOR c_nriesgo IS
      SELECT   nriesgo
          FROM riesgos
         WHERE sseguro = psseguro
           AND fefecto <= pfriesgo
           AND(fanulac IS NULL
               OR fanulac > pfriesgo)
           AND sperson IS NOT NULL
      ORDER BY nriesgo;

   num_riesgo1    NUMBER;
   num_riesgo2    NUMBER;
   num_riesgo3    NUMBER;
   v_cempres      seguros.cempres%TYPE;   -- BUG17255:DRA:25/07/2011
   vnmovimi       NUMBER;   -- Bug 26923/148935 - 11/07/2013 - AMC
BEGIN
   paso := 1;

   IF pnriesgo IS NOT NULL THEN   --pnriesgo está informado
      paso := 2;

      BEGIN
         SELECT cobjase, cagente, cempres
           INTO wcobjase, vcagente, v_cempres
           FROM seguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 101903;   --Seguro no encontrado en la tabla SEGUROS
      END;

      paso := 3;

      IF wcobjase = 1 THEN   --personal
         paso := 4;

         BEGIN
            SELECT sperson
              INTO wsperson
              FROM riesgos
             WHERE sseguro = psseguro
               AND nriesgo = pnriesgo;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN 102819;   --Riesgo no encontrado
         END;

         ptriesgo1 := SUBSTR(f_nombre(wsperson, 1, vcagente), 1, 40);
         ptriesgo2 := NULL;
         ptriesgo3 := NULL;
         RETURN 0;
      ELSIF wcobjase = 2 THEN   ---domicilio
         paso := 5;

         BEGIN
            SELECT sperson
              INTO wsperson
              FROM riesgos
             WHERE sseguro = psseguro
               AND nriesgo = pnriesgo;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN 102819;   --Riesgo no encontrado
         END;

         IF wsperson IS NOT NULL THEN
            ptriesgo1 := SUBSTR(f_nombre(wsperson, 1, vcagente), 1, 40);
            ptriesgo2 := NULL;
            ptriesgo3 := NULL;
         ELSE
            num_err := f_direccion(2, psseguro, pnriesgo, 1, ptlin1, ptlin2, ptlin3);
            ptriesgo1 := SUBSTR(ptlin1, 1, 60);
            ptriesgo2 := SUBSTR(ptlin2, 1, 60);
            ptriesgo3 := SUBSTR(ptlin3, 1, 60);
         END IF;

         RETURN 0;
      ELSIF wcobjase = 3
            OR wcobjase = 4 THEN   ---descripción
         paso := 6;

         BEGIN
            SELECT tnatrie
              INTO wtnatrie
              FROM riesgos
             WHERE sseguro = psseguro
               AND nriesgo = pnriesgo;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN 102819;   --Riesgo no encontrado
         END;

         ptriesgo1 := SUBSTR(wtnatrie, 1, 100);
         ptriesgo2 := SUBSTR(wtnatrie, 101, 100);
         longitud := LENGTH(wtnatrie);

         IF longitud <= 300 THEN
            ptriesgo3 := SUBSTR(wtnatrie, 201, 100);
         ELSE
            ptriesgo3 := SUBSTR(wtnatrie, 201, 97) || '...';
         END IF;

         RETURN 0;
      -- Afegim la descripció pels riscos de autos
      ELSIF wcobjase = 5 THEN   --autos
         paso := 7;

         --INICIO Bug 26241 27/02/2013 - DCT
         BEGIN
            -- Bug 26923/148935 - 11/07/2013 - AMC
            IF pnmovimi IS NOT NULL THEN
               vnmovimi := pnmovimi;
            ELSE
               SELECT MAX(nmovimi)
                 INTO vnmovimi
                 FROM autriesgos
                WHERE sseguro = psseguro
                  AND nriesgo = pnriesgo;
            END IF;

            SELECT triesgo
              INTO ptlin1
              FROM autriesgos
             WHERE sseguro = psseguro
               AND nriesgo = pnriesgo
               AND nmovimi = vnmovimi;

            --Fi  Bug 26923/148935 - 11/07/2013 - AMC
            ptriesgo1 := ptlin1;
            ptriesgo2 := NULL;
            ptriesgo3 := NULL;
            RETURN 0;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN 152509;   --102819;                 --Riesgo no encontrado
         END;

         --FIN Bug 26241 27/02/2013 - DCT
         paso := 8;
         -- Fi Bug 0014888
         RETURN 0;
      END IF;
   END IF;

   paso := 9;

   IF pnriesgo IS NULL THEN   --pnriesgo no está informado
      paso := 10;

      IF pfriesgo IS NULL THEN
         RETURN 102818;   --La fecha de vigor del riesgo no está informada
      ELSE
         paso := 11;

         BEGIN
            SELECT seguros.cobjase, productos.csubpro, seguros.cagente, seguros.cempres
              INTO wcobjase, wcsubpro, vcagente, v_cempres
              FROM productos, seguros
             WHERE seguros.sseguro = psseguro
               AND productos.cramo = seguros.cramo
               AND productos.cmodali = seguros.cmodali
               AND productos.ctipseg = seguros.ctipseg
               AND productos.ccolect = seguros.ccolect;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN 101903;   --Seguro no encontrado en la tabla SEGUROS
         END;

         IF wcsubpro = 1
            OR wcsubpro = 3
            OR wcsubpro = 5 THEN   --individual o dos cabezas
            paso := 12;

            IF wcobjase = 1 THEN   --personal
               paso := 13;

               BEGIN
                  SELECT sperson
                    INTO wsperson
                    FROM riesgos
                   WHERE sseguro = psseguro
                     AND fefecto <= pfriesgo
                     AND(fanulac IS NULL
                         OR fanulac > pfriesgo)
                     AND sperson IS NOT NULL;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     RETURN 102819;   --Riesgo no encontrado
               END;

               ptriesgo1 := SUBSTR(f_nombre(wsperson, 1, vcagente), 1, 40);
               ptriesgo2 := NULL;
               ptriesgo3 := NULL;
               RETURN 0;
            ELSIF wcobjase = 2 THEN   --domicilio
               paso := 14;

               BEGIN
                  SELECT riesgos.sseguro, riesgos.nriesgo
                    INTO wsseguro, wnriesgo
                    FROM sitriesgo, riesgos
                   WHERE riesgos.sseguro = psseguro
                     AND fefecto <= pfriesgo
                     AND(fanulac IS NULL
                         OR fanulac > pfriesgo)
                     AND sitriesgo.sseguro = riesgos.sseguro
                     AND sitriesgo.nriesgo = riesgos.nriesgo;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     RETURN 102819;   --Riesgo no encontrado
               END;

               paso := 15;
               num_err := f_direccion(2, psseguro, wnriesgo, 1, ptlin1, ptlin2, ptlin3);
               ptriesgo1 := SUBSTR(ptlin1, 1, 60);
               ptriesgo2 := SUBSTR(ptlin2, 1, 60);
               ptriesgo3 := SUBSTR(ptlin3, 1, 60);
               RETURN 0;
            ELSIF wcobjase = 3
                  OR wcobjase = 4 THEN   --descripción
               paso := 16;

               BEGIN
                  SELECT tnatrie
                    INTO wtnatrie
                    FROM riesgos
                   WHERE sseguro = psseguro
                     AND fefecto <= pfriesgo
                     AND(fanulac IS NULL
                         OR fanulac > pfriesgo)
                     AND tnatrie IS NOT NULL;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     RETURN 102819;   --Riesgo no encontrado
               END;

               ptriesgo1 := SUBSTR(wtnatrie, 1, 100);
               ptriesgo2 := SUBSTR(wtnatrie, 101, 100);
               longitud := LENGTH(wtnatrie);

               IF longitud <= 300 THEN
                  ptriesgo3 := SUBSTR(wtnatrie, 201, 100);
               ELSE
                  ptriesgo3 := SUBSTR(wtnatrie, 201, 97) || '...';
               END IF;

               RETURN 0;
            -- Afegim la descripció pels riscos de autos
            ELSIF wcobjase = 5 THEN   --autos
               paso := 17;

               SELECT COUNT(a.sseguro)
                 INTO contador
                 FROM riesgos r, autriesgos a
                WHERE r.sseguro = psseguro
                  AND r.fefecto <= pfriesgo
                  AND(r.fanulac IS NULL
                      OR r.fanulac > pfriesgo)
                  AND a.sseguro = r.sseguro
                  AND a.nriesgo = r.nriesgo;

               texto1 := f_axis_literales(102825, pcidioma);
               texto2 := f_axis_literales(9001795, pcidioma);
               ptriesgo1 := texto1;
               ptriesgo2 := TO_CHAR(contador) || ' ' || texto2;
               ptriesgo3 := NULL;
               RETURN 0;
            END IF;
/*       ELSIF wcsubpro = 2  THEN   --innominado
            p_literal(102821, pcidioma, texto);  -- Riesgos
            ptriesgo1 := to_char(wnasegur)||' '||texto;
            ptriesgo2 := null;
            ptriesgo3 := null;
            RETURN 0;
*/
         ELSIF wcsubpro = 2 THEN   --Colectivo simple
            IF wcobjase = 1 THEN
               paso := 19;

               SELECT COUNT(*)
                 INTO contador
                 FROM riesgos
                WHERE sseguro = psseguro
                  AND fefecto <= pfriesgo
                  AND(fanulac IS NULL
                      OR fanulac > pfriesgo)
                  AND sperson IS NOT NULL;

               -- Se cogen los 3 primeros riesgos vigentes
               OPEN c_nriesgo;

               FETCH c_nriesgo
                INTO num_riesgo1;

               FETCH c_nriesgo
                INTO num_riesgo2;

               FETCH c_nriesgo
                INTO num_riesgo3;

               CLOSE c_nriesgo;

               paso := 20;

               BEGIN
                  SELECT sperson
                    INTO wsperson
                    FROM riesgos
                   WHERE sseguro = psseguro
                     AND fefecto <= pfriesgo
                     AND(fanulac IS NULL
                         OR fanulac > pfriesgo)
                     AND sperson IS NOT NULL
                     AND nriesgo = num_riesgo1;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     RETURN 102819;   --Riesgo no encontrado
               END;

               ptriesgo1 := SUBSTR(f_nombre(wsperson, 1, vcagente), 1, 40);
               paso := 21;

               BEGIN
                  SELECT sperson
                    INTO wsperson
                    FROM riesgos
                   WHERE sseguro = psseguro
                     AND fefecto <= pfriesgo
                     AND(fanulac IS NULL
                         OR fanulac > pfriesgo)
                     AND sperson IS NOT NULL
                     AND nriesgo = num_riesgo2;

                  ptriesgo2 := SUBSTR(f_nombre(wsperson, 1, vcagente), 1, 40);
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     ptriesgo2 := NULL;
               END;

               paso := 22;

               BEGIN
                  SELECT sperson
                    INTO wsperson
                    FROM riesgos
                   WHERE sseguro = psseguro
                     AND TRUNC(fefecto) <= TRUNC(pfriesgo)
                     AND(fanulac IS NULL
                         OR fanulac > pfriesgo)
                     AND sperson IS NOT NULL
                     AND nriesgo = num_riesgo3;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     ptriesgo3 := NULL;
               END;

               paso := 23;

               IF contador = 3 THEN
                  ptriesgo3 := SUBSTR(f_nombre(wsperson, 1, vcagente), 1, 40);
               ELSIF contador > 3 THEN
                  texto1 := f_axis_literales(102822, pcidioma);   --'y'
                  texto2 := f_axis_literales(102823, pcidioma);   --'asegurados más'
                  ptriesgo3 := texto1 || ' ' || TO_CHAR(contador - 2) || ' ' || texto2;
               END IF;

               RETURN 0;
            ELSIF wcobjase = 2 THEN   ---domicilio
               paso := 24;

               SELECT COUNT(*)
                 INTO contador
                 FROM sitriesgo, riesgos
                WHERE riesgos.sseguro = psseguro
                  AND fefecto <= pfriesgo
                  AND(fanulac IS NULL
                      OR fanulac > pfriesgo)
                  AND sitriesgo.sseguro = riesgos.sseguro
                  AND sitriesgo.nriesgo = riesgos.nriesgo;

               texto := f_axis_literales(102824, pcidioma);
               ptriesgo1 := TO_CHAR(contador) || ' ' || texto;
               ptriesgo2 := NULL;
               ptriesgo3 := NULL;
               RETURN 0;
            ELSIF wcobjase = 3 THEN   ---Descripción
               paso := 25;

               SELECT COUNT(*)
                 INTO contador
                 FROM riesgos
                WHERE sseguro = psseguro
                  AND fefecto <= pfriesgo
                  AND(fanulac IS NULL
                      OR fanulac > pfriesgo)
                  AND tnatrie IS NOT NULL;

               texto1 := f_axis_literales(102825, pcidioma);
               texto2 := f_axis_literales(102826, pcidioma);
               ptriesgo1 := texto1;
               ptriesgo2 := TO_CHAR(contador) || ' ' || texto2;
               ptriesgo3 := NULL;
               RETURN 0;
            --   Tenim en compte el nasegur
            ELSIF wcobjase = 4 THEN   --- Innominats
               paso := 26;

               SELECT SUM(NVL(nasegur, 1))
                 INTO contador
                 FROM riesgos
                WHERE sseguro = psseguro
                  AND fefecto <= pfriesgo
                  AND(fanulac IS NULL
                      OR fanulac > pfriesgo)
                  AND tnatrie IS NOT NULL;

               texto1 := f_axis_literales(102825, pcidioma);
               texto2 := f_axis_literales(102826, pcidioma);
               ptriesgo1 := texto1;
               ptriesgo2 := TO_CHAR(contador) || ' ' || texto2;
               ptriesgo3 := NULL;
               RETURN 0;
            --ELSIF wcsubpro = 4 THEN  --Colectivos individualizados
            -- Afegim la descripció pels riscos de autos
            ELSIF wcobjase = 5 THEN   --autos
               paso := 27;

               SELECT COUNT(a.sseguro)
                 INTO contador
                 FROM riesgos r, autriesgos a
                WHERE r.sseguro = psseguro
                  AND r.fefecto <= pfriesgo
                  AND(r.fanulac IS NULL
                      OR r.fanulac > pfriesgo)
                  AND a.sseguro = r.sseguro
                  AND a.nriesgo = r.nriesgo;

               texto1 := f_axis_literales(102825, pcidioma);
               texto2 := f_axis_literales(9001795, pcidioma);
               ptriesgo1 := texto1;
               ptriesgo2 := TO_CHAR(contador) || ' ' || texto2;
               ptriesgo3 := NULL;
               RETURN 0;
            END IF;
         END IF;
      END IF;
   END IF;

   paso := 29;
EXCEPTION
   WHEN OTHERS THEN
      -- BUG 21546_108724 - 08/02/2012 - JLTS - Cierre de posibles cursores abiertos
      IF c_nriesgo%ISOPEN THEN
         CLOSE c_nriesgo;
      END IF;

      -- dra 27-8-08: bug mantis 7372
      p_tab_error(f_sysdate, f_user, 'f_desriesgo', paso, 'Error en WHEN OTHERS',
                  SQLERRM || ' (psseguro =' || psseguro || ')');
      RETURN 102827;   --Error en la función f_desriesgo
END;

/

  GRANT EXECUTE ON "AXIS"."F_DESRIESGO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_DESRIESGO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_DESRIESGO" TO "PROGRAMADORESCSI";
