--------------------------------------------------------
--  DDL for Function F_ESTDESRIESGO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_ESTDESRIESGO" (
   psseguro IN NUMBER,
   pnriesgo IN NUMBER,
   pfriesgo IN DATE,
   pcidioma IN NUMBER,
   ptriesgo1 OUT VARCHAR2,
   ptriesgo2 OUT VARCHAR2,
   ptriesgo3 OUT VARCHAR2)
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
****************************************************************************/
   wsseguro       NUMBER;
   wnriesgo       NUMBER(3);
   wcobjase       NUMBER;
   wcsubpro       NUMBER;
   wsperson       NUMBER;
   wtnatrie       VARCHAR2(300);
   wcagente       NUMBER;
   x_matricula    VARCHAR2(12);
   x_versio       VARCHAR2(11);
   x_marca        VARCHAR2(40);
   x_modelo       VARCHAR2(40);
   texto          VARCHAR2(400);
   texto1         VARCHAR2(400);
   texto2         VARCHAR2(400);
   ptlin1         VARCHAR2(40);
   ptlin2         VARCHAR2(40);
   ptlin3         VARCHAR2(40);
   longitud       NUMBER;
   num_err        NUMBER;
   contador       NUMBER := 0;

   CURSOR c_nriesgo IS
      SELECT   nriesgo
          FROM estriesgos
         WHERE sseguro = psseguro
           AND fefecto <= pfriesgo
           AND(fanulac IS NULL
               OR fanulac > pfriesgo)
           AND sperson IS NOT NULL
      ORDER BY nriesgo;

   num_riesgo1    NUMBER;
   num_riesgo2    NUMBER;
   num_riesgo3    NUMBER;
   v_cempres      estseguros.cempres%TYPE;   -- BUG17255:DRA:25/07/2011
BEGIN
   -- BUG17255:DRA:25/07/2011:Inici
   BEGIN
      SELECT cempres
        INTO v_cempres
        FROM estseguros
       WHERE sseguro = psseguro;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         v_cempres := f_parinstalacion_n('EMPRESADEF');
   END;

   -- BUG17255:DRA:25/07/2011:Fi
   IF pnriesgo IS NOT NULL THEN   --pnriesgo está informado
      BEGIN
         SELECT cobjase, cagente, cempres
           INTO wcobjase, wcagente, v_cempres
           FROM estseguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 101903;   --Seguro no encontrado en la tabla SEGUROS
      END;

      IF wcobjase = 1 THEN   --personal
         BEGIN
            SELECT sperson
              INTO wsperson
              FROM estriesgos
             WHERE sseguro = psseguro
               AND nriesgo = pnriesgo;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN 102819;   --Riesgo no encontrado
         END;

         ptriesgo1 := SUBSTR(f_nombre_est(wsperson, 1, wcagente), 1, 40);
         ptriesgo2 := NULL;
         ptriesgo3 := NULL;
         RETURN 0;
      ELSIF wcobjase = 2 THEN   ---domicilio
         BEGIN
            SELECT sperson
              INTO wsperson
              FROM estriesgos
             WHERE sseguro = psseguro
               AND nriesgo = pnriesgo;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN 102819;   --Riesgo no encontrado
         END;

         IF wsperson IS NOT NULL THEN
            ptriesgo1 := SUBSTR(f_nombre_est(wsperson, 1, wcagente), 1, 40);
            ptriesgo2 := NULL;
            ptriesgo3 := NULL;
         ELSE
            num_err := f_estdireccion(2, psseguro, pnriesgo, 1, ptlin1, ptlin2, ptlin3);
            ptriesgo1 := SUBSTR(ptlin1, 1, 40);
            ptriesgo2 := SUBSTR(ptlin2, 1, 40);
            ptriesgo3 := SUBSTR(ptlin3, 1, 40);
         END IF;

         RETURN 0;
      ELSIF wcobjase = 3
            OR wcobjase = 4 THEN   ---descripción
         BEGIN
            SELECT tnatrie
              INTO wtnatrie
              FROM estriesgos
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
         --INICIO Bug 26241 27/02/2013 - DCT
         BEGIN
            SELECT SUBSTR(triesgo, 1, 40)
              INTO ptlin1
              FROM estautriesgos
             WHERE sseguro = psseguro
               AND nriesgo = pnriesgo
               AND nmovimi = (SELECT MAX(nmovimi)
                                FROM estautriesgos
                               WHERE sseguro = psseguro
                                 AND nriesgo = pnriesgo);

            ptriesgo1 := ptlin1;
            ptriesgo2 := NULL;
            ptriesgo3 := NULL;
            RETURN 0;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN 152509;   --102819;                 --Riesgo no encontrado
         END;

         --FIN Bug 26241 27/02/2013 - DCT

         -- Fi Bug 0014888
         RETURN 0;
      END IF;
   END IF;

   IF pnriesgo IS NULL THEN   --pnriesgo no está informado
      IF pfriesgo IS NULL THEN
         RETURN 102818;   --La fecha de vigor del riesgo no está informada
      ELSE
         BEGIN
            SELECT estseguros.cobjase, productos.csubpro, estseguros.cagente,
                   estseguros.cempres
              INTO wcobjase, wcsubpro, wcagente,
                   v_cempres
              FROM productos, estseguros
             WHERE estseguros.sseguro = psseguro
               AND productos.cramo = estseguros.cramo
               AND productos.cmodali = estseguros.cmodali
               AND productos.ctipseg = estseguros.ctipseg
               AND productos.ccolect = estseguros.ccolect;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN 101903;   --Seguro no encontrado en la tabla SEGUROS
         END;

         IF wcsubpro = 1 THEN   --individual
            IF wcobjase = 1 THEN   --personal
               BEGIN
                  SELECT sperson
                    INTO wsperson
                    FROM estriesgos
                   WHERE sseguro = psseguro
                     AND fefecto <= pfriesgo
                     AND(fanulac IS NULL
                         OR fanulac > pfriesgo)
                     AND sperson IS NOT NULL;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     RETURN 102819;   --Riesgo no encontrado
               END;

               ptriesgo1 := SUBSTR(f_nombre_est(wsperson, 1, wcagente), 1, 40);
               ptriesgo2 := NULL;
               ptriesgo3 := NULL;
               RETURN 0;
            ELSIF wcobjase = 2 THEN   --domicilio
               BEGIN
                  SELECT estriesgos.sseguro, estriesgos.nriesgo
                    INTO wsseguro, wnriesgo
                    FROM estsitriesgo, estriesgos
                   WHERE estriesgos.sseguro = psseguro
                     AND fefecto <= pfriesgo
                     AND(fanulac IS NULL
                         OR fanulac > pfriesgo)
                     AND estsitriesgo.sseguro = estriesgos.sseguro
                     AND estsitriesgo.nriesgo = estriesgos.nriesgo;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     RETURN 102819;   --Riesgo no encontrado
               END;

               num_err := f_estdireccion(2, psseguro, wnriesgo, 1, ptlin1, ptlin2, ptlin3);
               ptriesgo1 := SUBSTR(ptlin1, 1, 40);
               ptriesgo2 := SUBSTR(ptlin2, 1, 40);
               ptriesgo3 := SUBSTR(ptlin3, 1, 40);
               RETURN 0;
            ELSIF wcobjase = 3
                  OR wcobjase = 4 THEN   --descripción
               BEGIN
                  SELECT tnatrie
                    INTO wtnatrie
                    FROM estriesgos
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
               SELECT COUNT(a.sseguro)
                 INTO contador
                 FROM estriesgos r, estautriesgos a
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
               SELECT COUNT(*)
                 INTO contador
                 FROM estriesgos
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

               BEGIN
                  SELECT sperson
                    INTO wsperson
                    FROM estriesgos
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

               ptriesgo1 := SUBSTR(f_nombre_est(wsperson, 1, wcagente), 1, 40);

               BEGIN
                  SELECT sperson
                    INTO wsperson
                    FROM estriesgos
                   WHERE sseguro = psseguro
                     AND fefecto <= pfriesgo
                     AND(fanulac IS NULL
                         OR fanulac > pfriesgo)
                     AND sperson IS NOT NULL
                     AND nriesgo = num_riesgo2;

                  ptriesgo2 := SUBSTR(f_nombre_est(wsperson, 1, wcagente), 1, 40);
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     ptriesgo2 := NULL;
               END;

               BEGIN
                  SELECT sperson
                    INTO wsperson
                    FROM estriesgos
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

               IF contador = 3 THEN
                  ptriesgo3 := SUBSTR(f_nombre_est(wsperson, 1, wcagente), 1, 40);
               ELSIF contador > 3 THEN
                  texto1 := f_axis_literales(102822, pcidioma);   --'y'
                  texto2 := f_axis_literales(102823, pcidioma);   --'asegurados más'
                  ptriesgo3 := texto1 || ' ' || TO_CHAR(contador - 2) || ' ' || texto2;
               END IF;

               RETURN 0;
            ELSIF wcobjase = 2 THEN   ---domicilio
               SELECT COUNT(*)
                 INTO contador
                 FROM estsitriesgo, estriesgos
                WHERE estriesgos.sseguro = psseguro
                  AND fefecto <= pfriesgo
                  AND(fanulac IS NULL
                      OR fanulac > pfriesgo)
                  AND estsitriesgo.sseguro = estriesgos.sseguro
                  AND estsitriesgo.nriesgo = estriesgos.nriesgo;

               texto := f_axis_literales(102824, pcidioma);
               ptriesgo1 := TO_CHAR(contador) || ' ' || texto;
               ptriesgo2 := NULL;
               ptriesgo3 := NULL;
               RETURN 0;
            ELSIF wcobjase = 3
                  OR wcobjase = 4 THEN   ---Descripción
               SELECT COUNT(*)
                 INTO contador
                 FROM estriesgos
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
               SELECT COUNT(a.sseguro)
                 INTO contador
                 FROM estriesgos r, estautriesgos a
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
EXCEPTION
   WHEN OTHERS THEN
      -- BUG 21546_108724 - 09/02/2012 - JLTS - Cierre de posibles cursores abiertos
      IF c_nriesgo%ISOPEN THEN
         CLOSE c_nriesgo;
      END IF;

      p_tab_error(f_sysdate, f_user, 'f_estdesriesgo', 99, 'Error en WHEN OTHERS',
                  SQLERRM || ' (psseguro =' || psseguro || ')');
      RETURN 102827;   --Error en la función f_desriesgo
END;

/

  GRANT EXECUTE ON "AXIS"."F_ESTDESRIESGO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_ESTDESRIESGO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_ESTDESRIESGO" TO "PROGRAMADORESCSI";
