--------------------------------------------------------
--  DDL for Package Body PK_RENTAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PK_RENTAS" IS
   /****************************************************************************
      NOM:       PK_RENTAS
      PROPÒSIT:  Gestió de les Rendes

      REVISIONS:
      Ver        Data        Autor             Descripció
      ---------  ----------  ---------------  ----------------------------------
      1.0        ??/??/????
      2.0        06/2009     NMM               0010240: CRE - Ajustes en pagos de renta extraordinarias .
      3.0        08/07/2009  DCT               1. BUG 0010612: CRE - Error en la generació de pagaments automàtics.
                                                  Canviar vista personas por tablas personas y añadir filtro de visión de agente.
      4.0        16/06/2009   JGM              2. Actualización Generacion Rentas
      5.0        05/11/2009  APD               3. Bug 11595: CEM - Siniestros. Adaptación al nuevo módulo de siniestros
      6.0        22/01/2010  RSC               4. 0012822 - CEM: RT - Tratamiento fiscal rentas a 2 cabezas
      7.0        11/02/2010  AMC               7. 0011392: CRE - Añadir a la consulta de pólizas las rentas.
      8.0        20/04/2010  JRH               8. 0013859: CRE998 - Migración rentas de Passius Caixabank
      9.0        20/04/2010  ICV               9. 0012914: CEM - Reimprimir listados de pagos de rentas
     10.0        03/06/2010  JGR              10. 0014658: CRE998- Parametrizar día de pago en Rentas Irregulares + cambios de jrh
     11.0        22/06/2010  JRH              11. 0014185: ENSA101 - Proceso de carga del fichero (beneficio definido)
     12.0        19/06/2010  JRH              12. 0012137: CEM - RT - Verificación producto RT
     13.0       10/08/2010   JRH              13. BUG 15669 : Campos nuevos. Se añade el pnsinies mntramit y ctipdes en prestaren. Se deja preparado que se pueda insertar ctipban en los pagos (o incluso el siniestro, tramite, tipo destinatario).
     14.0       05/09/2010   JRH              14. BUG 0016217: Mostrar cuadro de capitales para la pólizas de rentas
     15.0        26/11/2010  SRA              15. Bug 0016830: CRE805 - Rendes flexibles - revisió de incidències
     16.0       13/12/2010   JRH              16. BUG 0016217: Mostrar cuadro de capitales para la pólizas de rentas
     17.0       15/12/2010   APD              17. BUG 0017005: CEM800 - Ajustes modelos fiscales
     18.0       08/02/2011   ETM              18. BUG 17589: 2010: Modelo 189
     19.0       14/02/2011   JRH              19. 0017247: ENSA103 - Instalar els web-services als entorns CSI
     20.0       11/03/2011   RSC              20. 0017247: ENSA103 - Instalar els web-services als entorns CSI
     21.0       15/03/2010   JTS              21. BUG 0013477: ENSA101 - Nueva pantalla de Gestión Pagos Rentas
     22.0       29/03/2011   JMF              22. BUG 0013477 ENSA101 - Nueva pantalla de Gestión Pagos Rentas
     23.0       10/05/2011   SRA              23. 0018498: CIV401 - Renta vitalícia: impressió de la simulació
     24.0       14/10/2011   JMF              24. 0019649: CRE800 - Pagament renda irregular
     25.0       15/12/2011   JMP              25. 0018423: LCOL705 - Multimoneda
     26.0       03/2013      NMM              26. 24735: (POSDE600)-Desarrollo-GAPS Tecnico-Id 33 - Mesadas Extras diferentes a la propia (preguntas)
     27.0       08/01/2014   LPP              27. 0028409: ENSA998-ENSA - Implementación de historico de prestaciones
   ****************************************************************************/
   FUNCTION f_insertplanrentas(psseguro IN NUMBER, pnmovimi IN NUMBER)
      RETURN NUMBER IS
      v_ctipgar      NUMBER;
      xcgarant       NUMBER;
      xanys          NUMBER;
      psproduc       NUMBER;
      xfefecto       DATE;
      xcactivi       NUMBER;
      vcforpag       NUMBER;
      vicapren       NUMBER;
      ntraza         NUMBER;
      error          EXCEPTION;
      xcramo         NUMBER;
      xcmodali       NUMBER;
      xctipseg       NUMBER;
      xccolect       NUMBER;
      xclave         NUMBER;
      fechainicio    DATE;
      incremento     NUMBER;
      finbucle       NUMBER;
      e              NUMBER;
      vfrevant       DATE;
      xfefectoren    DATE;
      ttexto         VARCHAR2(400);
   --
   BEGIN
      ntraza := 0;

      IF (psseguro IS NULL)
         OR(pnmovimi IS NULL) THEN
         RAISE error;
      END IF;

      SELECT s.fefecto, s.sproduc, s.cactivi
        INTO xfefecto, psproduc, xcactivi
        FROM seguros s, productos p
       WHERE sseguro = psseguro
         AND p.sproduc = s.sproduc;

      IF NVL(f_parproductos_v(psproduc, 'PLAN_RENTAS'), 0) = 0 THEN
         RAISE error;
      END IF;

      ntraza := 1;

      SELECT cramo, cmodali, ctipseg, ccolect
        INTO xcramo, xcmodali, xctipseg, xccolect
        FROM productos
       WHERE sproduc = psproduc;

      ntraza := 2;

      SELECT cforpag, icapren
        INTO vcforpag, vicapren
        FROM seguros_ren
       WHERE sseguro = psseguro;

      ntraza := 3;
      xcgarant := pac_calc_comu.f_cod_garantia(psproduc, 8, NULL, v_ctipgar);   --garantia asociada a rentas

      IF xcgarant IS NULL THEN
         RAISE error;
      END IF;

      ntraza := 4;
      xanys := pac_calc_comu.ff_get_duracion('SEG', psseguro);

      IF xanys IS NULL THEN
         RAISE error;
      END IF;

      ntraza := 5;

      SELECT clave   --Buscamos la fórmula para el cálculo de la renta
        INTO xclave
        FROM garanformula
       WHERE cramo = xcramo
         AND ccampo = 'ICAPCAL'
         AND cmodali = xcmodali
         AND ctipseg = xctipseg
         AND ccolect = xccolect
         AND cactivi = xcactivi
         AND cgarant = xcgarant;

      ntraza := 7;

      SELECT f1paren   --Primer pago de la renta
        INTO xfefectoren
        FROM seguros_ren
       WHERE sseguro = psseguro;

      SELECT frevant
        INTO vfrevant
        FROM seguros_aho
       WHERE sseguro = psseguro;

      IF vfrevant IS NOT NULL THEN
         xfefectoren := vfrevant;   --Cogemos la fecha de última revisión de la póliza si estamos en el proceso de revisión
      END IF;

      ntraza := 8;
      fechainicio := xfefectoren;
      /*IF NVL(f_parproductos_v(psproduc, 'FECHAREV'),0) = 3 THEN
        incremento:=1; --Si revisa cada año el interes
      else
        incremento:=xanys; --Sino el incremento es la duración. Sólo grabamos un registro
      end if;
      */
      incremento := 1;
      ntraza := 9;
      finbucle := xanys / incremento;
      ntraza := 10;

      --Borramos la tabla para ese  NMOVIMI
      DELETE      planrentas
            WHERE sseguro = psseguro
              AND nmovimi = pnmovimi;

      FOR j IN 1 .. finbucle LOOP   -- Anualitats
         DECLARE
            val            NUMBER;
            fecinianu      DATE;
            fecfinanu      DATE;
            ppx_inter1     NUMBER;
            ppx_inter2     NUMBER;
            fecinimens     DATE;
            fecfinmens     DATE;
            acumulado      NUMBER := 0;
            importe        NUMBER := 0;
         BEGIN
            ntraza := 11;
            fecinianu := ADD_MONTHS(fechainicio,((j * incremento) - incremento) * 12);
            fecfinanu := ADD_MONTHS(fechainicio,(j * incremento) * 12);
            e := pac_calculo_formulas.calc_formul(fecinianu, psproduc, xcactivi, NULL, 1,
                                                  psseguro, xclave, val, pnmovimi, NULL, 2,
                                                  xfefecto, 'R');

            IF e <> 0 THEN
               RAISE error;
            END IF;

            ntraza := 14;
            ppx_inter1 := pac_inttec.ff_int_producto(psproduc, 7, xfefecto,
                                                     xanys * 100000 + 100 + vcforpag);   --JRH Se supone que estos cambian en la anualidad
            ntraza := 15;
            ppx_inter2 := pac_inttec.ff_int_producto(psproduc, 8, xfefecto,
                                                     xanys * 100000 + 100 + vcforpag);

            FOR l IN 1 ..(vcforpag * incremento) LOOP   -- Mensualitats períodes
               fecinimens := ADD_MONTHS(fecinianu,(l - 1) *(12 / vcforpag));
               fecfinmens := ADD_MONTHS(fecinianu, l *(12 / vcforpag));
               importe := ROUND(val /(vcforpag * incremento), 2);   --Importe por mes/perido

               IF (l =(vcforpag * incremento)) THEN   --En el ultimo periodo ponemos la cantidad para que de  el total de la anualidad
                  importe := val - acumulado;
               ELSE
                  acumulado := acumulado + importe;
               END IF;

               INSERT INTO planrentas
                           (sseguro, nmovimi, fechaini, fechafin, importerenta, inter1,
                            inter2, estado)
                    VALUES (psseguro, pnmovimi, fecinimens, fecfinmens, importe, ppx_inter1,
                            ppx_inter2, 0);

               ntraza := 15;
            END LOOP;
         END;
      END LOOP;

      RETURN(0);
   EXCEPTION
      WHEN error THEN
         p_tab_error(f_sysdate, f_user, 'pk_rentas.F_InsertPlanrentas', ntraza,
                     'ptablas = ' || 'SEG' || ' psseguro =' || psseguro || ' pnriesgo =' || 1,
                     'Error en proceso:' || SQLERRM);
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pkrentas.F_InsertPlanrentas', ntraza,
                     'ptablas = ' || 'SEG' || ' psseguro =' || psseguro || ' pnriesgo =' || 1,
                     SQLERRM);
         RETURN NULL;
   END f_insertplanrentas;

   FUNCTION f_buscarentabruta(
      psesion IN NUMBER,
      psseguro IN NUMBER,
      pfecha IN NUMBER,
      porigen IN NUMBER,
      ptiporen IN VARCHAR2 DEFAULT 'R'   -- Tipo de renta
                                      )
      RETURN NUMBER IS
      ntraza         NUMBER;
      pclaren        NUMBER;
      xerror         NUMBER;
      ptablas        VARCHAR2(100);
      importe        NUMBER;
      tipoacceso     NUMBER;
      fechapago      DATE;
      psproduc       NUMBER;
      pctrev         NUMBER;
      fallec         NUMBER := 0;
      fechapagini    DATE;
      mesesextra     VARCHAR2(24);
      vvalor         VARCHAR2(4);
      vmes           NUMBER;
      ttexto         VARCHAR2(400);

      CURSOR fall1 IS
         SELECT 1
           FROM estassegurats
          WHERE sseguro = psseguro
            AND ffecmue IS NOT NULL
            AND ffecmue < TO_DATE(pfecha, 'yyyymmdd')
            AND((ffecfin IS NULL)
                OR(ffecfin IS NOT NULL
                   AND ffecfin > TO_DATE(pfecha, 'yyyymmdd')));   --activo a la fechsa

      CURSOR fall2 IS
         SELECT 1
           FROM asegurados
          WHERE sseguro = psseguro
            AND ffecmue IS NOT NULL
            AND ffecmue < TO_DATE(pfecha, 'yyyymmdd')
            AND((ffecfin IS NULL)
                OR(ffecfin IS NOT NULL
                   AND ffecfin > TO_DATE(pfecha, 'yyyymmdd')));   --activo a la fechsa
   BEGIN
      fechapagini := TO_DATE(pfecha, 'yyyymmdd');
      ntraza := 1;

      /*                    -- BUG 14182 - FAL - 25/05/2010 - recupera sproduc en funcion de porigen
      SELECT sproduc
        INTO psproduc
        FROM seguros
       WHERE sseguro = psseguro;
      */
      IF porigen NOT IN(0, 1) THEN
         SELECT sproduc
           INTO psproduc
           FROM seguros
          WHERE sseguro = psseguro;
      ELSIF porigen = 0 THEN
         SELECT sproduc
           INTO psproduc
           FROM solseguros
          WHERE sseguro = psseguro;
      ELSIF porigen = 1 THEN
         SELECT sproduc
           INTO psproduc
           FROM estseguros
          WHERE sseguro = psseguro;
      END IF;

      -- Fi BUG 14182 - FAL - 25/05/2010
      tipoacceso := NVL(f_parproductos_v(psproduc, 'PLAN_RENTAS'), 0);

      IF ptiporen = 'R'
         OR ptiporen = 'E' THEN
         IF porigen = 0 THEN
            ptablas := 'SOL';

            SELECT ibruren, NVL(pdoscab, 100), nmesextra
              INTO importe, pctrev, mesesextra
              FROM solseguros_ren
             WHERE ssolicit = psseguro;

            pctrev := 100;
         ELSIF porigen = 1 THEN
            ptablas := 'EST';

            SELECT ibruren, NVL(pdoscab, 100), nmesextra
              INTO importe, pctrev, mesesextra
              FROM estseguros_ren
             WHERE sseguro = psseguro;

            ntraza := 4;

            OPEN fall1;

            FETCH fall1
             INTO fallec;

            IF fall1%NOTFOUND THEN
               pctrev := 100;   --Si no hay fallecidos siempre es 100
            END IF;

            CLOSE fall1;
         ELSE
            ptablas := 'SEG';

            SELECT ibruren, NVL(pdoscab, 100), nmesextra
              INTO importe, pctrev, mesesextra
              FROM seguros_ren
             WHERE sseguro = psseguro;

            OPEN fall2;

            FETCH fall2
             INTO fallec;

            IF fall2%NOTFOUND THEN
               pctrev := 100;   --Si no hay fallecidos siempre es 100
            END IF;

            CLOSE fall2;
         END IF;
      ELSIF ptiporen = 'I' THEN
         SELECT importe
           INTO importe
           FROM planrentasirreg
          WHERE sseguro = psseguro
            AND nmovimi = (SELECT MAX(nmovimi)
                             FROM planrentasirreg
                            WHERE sseguro = psseguro
                              AND mes = TO_NUMBER(TO_CHAR(fechapagini, 'mm'))
                              AND anyo = TO_NUMBER(TO_CHAR(fechapagini, 'yyyy')))
            AND mes = TO_NUMBER(TO_CHAR(fechapagini, 'mm'))
            AND anyo = TO_NUMBER(TO_CHAR(fechapagini, 'yyyy'));

         -- Mantis 10240.01/07/2009.NMM.CRE - Ajustes en pagos de renta extraordinarias.i.
         SELECT NVL(pdoscab, 100)
           INTO pctrev
           FROM seguros_ren
          WHERE sseguro = psseguro;

         -- Mantis 10240.f.

         -- BUG 13859-  04/2009 - JRH  - 0013859: CRE998 - Migración rentas de Passius Caixabank
         OPEN fall2;

         FETCH fall2
          INTO fallec;

         IF fall2%NOTFOUND THEN
            pctrev := 100;   --Si no hay fallecidos siempre es 100
         END IF;

         CLOSE fall2;
      -- Fi BUG 13859-  04/2009 - JRH
      END IF;

      IF tipoacceso = 0
         OR porigen <> 2 THEN   --Acceso a seguros_ren. El 2 es porque de momento no existe una tabla planrentas
         NULL;   --JRH Dejamos el valor de IBRUREN en seguros_ren
      ELSE   --Acceso al plan de rentas por fecha de pago. De momento LRC en tablas SEG.
         --JRH De momento, la fecha de la renta siempre está un mes por delante de la de efecto (se rige a un mes más)
         fechapago := ADD_MONTHS(fechapagini, 1);

         BEGIN
            SELECT importerenta
              INTO importe
              FROM planrentas
             WHERE sseguro = psseguro
               AND fechaini <= fechapago
               AND fechafin > fechapago
               AND nmovimi = (SELECT MAX(a.nmovimi)
                                FROM planrentas a
                               WHERE a.sseguro = psseguro
                                 AND a.fechaini <= fechapago
                                 AND a.fechafin > fechapago);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               BEGIN
                  SELECT importerenta   --Si no la encontramos es que se rige por la misma fecha de efecto de la póliza
                    INTO importe
                    FROM planrentas
                   WHERE sseguro = psseguro
                     AND fechaini <= fechapagini
                     AND fechafin > fechapagini
                     AND nmovimi = (SELECT MAX(a.nmovimi)
                                      FROM planrentas a
                                     WHERE a.sseguro = psseguro
                                       AND a.fechaini <= fechapagini
                                       AND a.fechafin > fechapagini);
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     IF porigen = 0 THEN
                        SELECT ibruren, NVL(pdoscab, 100)
                          INTO importe, pctrev
                          FROM solseguros_ren
                         WHERE ssolicit = psseguro;
                     ELSIF porigen = 1 THEN
                        SELECT ibruren, NVL(pdoscab, 100)
                          INTO importe, pctrev
                          FROM estseguros_ren
                         WHERE sseguro = psseguro;
                     ELSE
                        SELECT ibruren, NVL(pdoscab, 100)
                          INTO importe, pctrev
                          FROM seguros_ren
                         WHERE sseguro = psseguro;
                     END IF;
               END;
         END;
      END IF;

      RETURN(importe * NVL(pctrev, 100) / 100);
   EXCEPTION
      WHEN OTHERS THEN
         -- BUG -21546_108724- 04/02/2012 - JLTS - Cierre de posibles cursores abiertos
         IF fall1%ISOPEN THEN
            CLOSE fall1;
         END IF;

         IF fall2%ISOPEN THEN
            CLOSE fall2;
         END IF;

         p_tab_error(f_sysdate, f_user, 'pkrentas.F_BUSCARENTABRUTA', ntraza,
                     'ptablas = ' || ptablas || ' psseguro =' || psseguro || ' pnriesgo =' || 1,
                     SQLERRM);
         RETURN NULL;
   END;

   FUNCTION f_buscaprduccion(
      psesion IN NUMBER,
      psseguro IN NUMBER,
      pfecha IN NUMBER,
      porigen IN NUMBER)
      RETURN NUMBER IS
      xanys          NUMBER;
      v_ctipgar      NUMBER;
      psproduc       NUMBER;
      xfnacimi       DATE;
      xfefecto       DATE;
      xcactivi       NUMBER;
      xpreducc       NUMBER;
      xcgarant       NUMBER;
      ptablas        VARCHAR2(30);
      pnmovimi       NUMBER;
      ntraza         NUMBER;
      pclaren        NUMBER;
      xerror         NUMBER;
   BEGIN
       /*
          -- RSC 20/10/2008 ---------------------------------------------------
          Tratamiento especial para el caso de simulaciones (SOL):

          Esta función tiene una operativa diferente para el caso de las simulaciones.
          En la renovación nos interesa obtener por un lado la edad del asegurado
          en el efecto de la póliza (que no en la fecha de renovación (la que será frevant)).
          Por eso a la función, desde SIMULACION_RENTAS, se le pasa la fecha de efecto de
          la póliza como parámetro.
          Por otra parte al ir a buscar el porcentage de reducción nos interesa pasarle
          la fecha de revisión (la que será frevant). Esta fecha si podemos ir a buscarla
          a SOLSEGUROS.

          Para el resto de casos (ORIGEN = 'EST'(1) or 'SEG'(2)) el funcionamiento
          de la función opera diferente. Nos interesa obtener la edad del asegurado
          en la fecha de efecto de la póliza pero al ir a buscar la reducción
          debemos pasar la fecha de efecto del pago de renta (parámetro de entrada).
      */
      IF porigen = 0 THEN
         ptablas := 'SOL';

         SELECT s.falta, s.sproduc, s.cactivi
           INTO xfefecto, psproduc, xcactivi
           FROM solseguros s
          WHERE ssolicit = psseguro;

         ntraza := 1;

         SELECT MAX(nmovimi)
           INTO pnmovimi
           FROM solpregunseg p2
          WHERE p2.ssolicit = psseguro
            AND p2.cpregun = 111
            AND p2.nriesgo = 1;

         ntraza := 2;

         -- Bug 12822 - RSC - 21/01/2010 - CEM: RT - Tratamiento fiscal rentas a 2 cabezas
         IF NVL(f_parproductos_v(psproduc, 'FISCALIDAD_2_CABEZAS'), 0) = 1 THEN
            SELECT fnacimi
              INTO xfnacimi
              FROM solasegurados
             WHERE ssolicit = psseguro
               AND norden = 1;
         ELSE
            -- Fin Bug 12822
            SELECT MAX(fnacimi)
              INTO xfnacimi
              FROM solasegurados
             WHERE ssolicit = psseguro;
         END IF;
      ELSIF porigen = 1 THEN
         ptablas := 'EST';

         SELECT s.fefecto, s.sproduc, s.cactivi
           INTO xfefecto, psproduc, xcactivi
           FROM estseguros s
          WHERE sseguro = psseguro;

         ntraza := 3;

         SELECT MAX(nmovimi)
           INTO pnmovimi
           FROM estpregunseg p2
          WHERE p2.sseguro = psseguro
            AND p2.cpregun = 111
            AND p2.nriesgo = 1;

         ntraza := 4;

         -- Bug10612 - 08/07/2009 - DCT (Añadir vagente_poliza y canviar vista personas)
         -- Bug 12822 - RSC - 21/01/2010 - CEM: RT - Tratamiento fiscal rentas a 2 cabezas
         IF NVL(f_parproductos_v(psproduc, 'FISCALIDAD_2_CABEZAS'), 0) = 1 THEN
            SELECT p.fnacimi
              INTO xfnacimi
              -- Ini bug 18498 - SRA - 10/05/2011
            FROM   estassegurats a, estper_personas p, estseguros s
             -- Fin bug 18498 - SRA - 10/05/2011
            WHERE  s.sseguro = psseguro
               AND a.sseguro = s.sseguro
                -- AND a.ffecmue IS NULL
               --  AND a.ffecfin IS NULL
               AND p.sperson = a.sperson
               AND a.norden = 1;
         ELSE
            -- Fin Bug 12822
            SELECT MAX(p.fnacimi)
              INTO xfnacimi
              FROM estper_personas p, estassegurats a, estseguros s
             WHERE s.sseguro = psseguro
               AND a.sseguro = s.sseguro
               AND a.ffecmue IS NULL
               AND a.ffecfin IS NULL
               AND p.sperson = a.sperson;
         END IF;
      -- FI Bug10612 - 08/07/2009 - DCT (Añadir vagente_poliza y canviar vista personas)
      ELSE
         ptablas := 'SEG';
         ntraza := 6;

         SELECT MAX(nmovimi)
           INTO pnmovimi
           FROM pregunseg p2
          WHERE p2.sseguro = psseguro
            AND p2.cpregun = 111
            AND p2.nriesgo = 1;

         ntraza := 7;

         SELECT s.fefecto, s.sproduc, s.cactivi
           INTO xfefecto, psproduc, xcactivi
           FROM seguros s
          WHERE sseguro = psseguro;

         ntraza := 8;

         -- Bug10612 - 08/07/2009 - DCT (Añadir vagente_poliza y canviar vista personas)
         -- Bug 12822 - RSC - 21/01/2010 - CEM: RT - Tratamiento fiscal rentas a 2 cabezas
         IF NVL(f_parproductos_v(psproduc, 'FISCALIDAD_2_CABEZAS'), 0) = 1 THEN
            SELECT p.fnacimi
              INTO xfnacimi
              FROM asegurados a, per_personas p, seguros s
             WHERE s.sseguro = psseguro
               AND a.sseguro = s.sseguro
               --AND a.ffecmue IS NULL
               --AND a.ffecfin IS NULL
               AND p.sperson = a.sperson
               AND a.norden = 1;
         ELSE
            -- Fin Bug 12822
            SELECT MAX(p.fnacimi)
              INTO xfnacimi
              FROM per_personas p, asegurados a, seguros s
             WHERE s.sseguro = psseguro
               AND a.sseguro = s.sseguro
               AND a.ffecmue IS NULL
               AND a.ffecfin IS NULL
               AND p.sperson = a.sperson;
         END IF;
      --FI Bug10612 - 08/07/2009 - DCT (Añadir vagente_poliza y canviar vista personas)
      END IF;

      -- JLB - Esto ya no se utiliza, xanys se recalcula mas abajo, la pregunta 111 no esta siempre en el producto
      --   ntraza := 9;
      --  xanys := pac_albsgt_snv.f_obtvalor_preg_riesg(ptablas, psseguro, 1, pnmovimi, 111);
      ntraza := 10;
      xcgarant := pac_calc_comu.f_cod_garantia(psproduc, 3, NULL, v_ctipgar);
      ntraza := 11;

      BEGIN
         SELECT cclaren
           INTO pclaren
           FROM producto_ren
          WHERE sproduc = psproduc;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            pclaren := 0;
      END;

      IF pclaren = 0 THEN   --JRH IMP Si es vitalicia edad
         -- CPM 21/12/06: Se coge la edad en la que se constituyó la póliza (o sea el efecto)
         --xerror := F_Difdata (xfnacimi,trunc(xfefecto), 1, 1, xanys);
         IF porigen = 0 THEN   -- RSC 20/10/2008
            xerror := f_difdata(xfnacimi, TO_DATE(pfecha, 'yyyymmdd'), 1, 1, xanys);
         ELSE
            xerror := f_difdata(xfnacimi, TRUNC(xfefecto), 1, 1, xanys);
         END IF;
      ELSE   --JRH IMP Si no es vitalicia duración
         xanys := pac_calc_comu.ff_get_duracion(ptablas, psseguro);
      END IF;

      ntraza := 12;

      -- RSC 25/09/2008 Para el umbral 01/01/2005 - 01/01/2007 si se toma la fecha de revisión
      --xpreducc := NVL(Fbuscapreduc (1, psproduc, xcactivi, xcgarant, pfecha, xanys),0);
      -- RSC 20/10/2008 Para calcular la reducción de un pago de renta se debe pasar
      -- la fecha del pago de renta.
      IF porigen = 0 THEN   -- RSC 20/10/2008
         xpreducc := NVL(fbuscapreduc(1, psproduc, xcactivi, xcgarant,
                                      TO_NUMBER(TO_CHAR(xfefecto, 'yyyymmdd')), xanys),
                         0);
      ELSE
         xpreducc := NVL(fbuscapreduc(1, psproduc, xcactivi, xcgarant, pfecha, xanys), 0);
      END IF;

      RETURN(xpreducc);
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pkrentas.FBUSCAPRDUCCION', ntraza,
                     'ptablas = ' || ptablas || ' psseguro =' || psseguro || ' pnriesgo ='
                     || 1,
                     SQLERRM);
         RETURN NULL;
   END;

-- BUG 14185-  06/2010 - JRH  - 0014185: ENSA101 - Proceso de carga del fichero (beneficio definido)

   -- ****************************************************************
--  FUNCTION f_calc_prestacion_pol
--         Funció que genera les prestacions d'una pòlissa
--       param in pproceso : Proceso
--       param in psseguro : Clave seguro
--       param in psperson  : Persona
--       param in psproduc :  Producto
--       param in prealpre :  -- 0-Real o 1-Previo Ins tmp. o 2-Recalcula 3-Previo
--       param in pf1paren : fecha primer pago
--       param in pfppren : Fecha próxima renta
--       param in pfecha : Fecha pago
--       param in pfefecto : Efecto póliza
--       param in pcbancar: Cuenta
--       param in ptiporen: Tipo renta ('R'egurlar,'E'xtra)
--       param in pnsinies : Siniestro
--         return            : 1 -> Tot correcte
--                             0 -> S'ha produit un error
-- ****************************************************************
   FUNCTION f_calc_prestacion_pol(
      pproceso IN NUMBER,   -- Nro. Proceso o Nro. Recibo
      pseguros IN NUMBER,   -- SSEGURO
      psperson IN NUMBER,   -- SPERSON 1er. Asegurado
      psproduc IN NUMBER,   -- SPRODUC
      prealpre IN NUMBER,   -- 0-Real o 1-Previo Ins tmp. o 2-Recalcula 3-Previo
      pf1pren IN DATE,
      pfppren IN DATE,   -- Fecha Proximo pago de renta
      pfefecto IN DATE,   -- Fecha
      pctabanc IN VARCHAR2,   -- Cuenta Bancaria
      ptiporen IN VARCHAR2,   -- Tipo de renta
      pnsinies IN VARCHAR2,
      pctipban IN NUMBER,
      pntramit IN NUMBER,
      pctipdes IN NUMBER,
      crevali IN NUMBER,
      prevali IN NUMBER,
      irevali IN NUMBER,
      pnpresta IN NUMBER)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'PK_RENTAS.f_calc_prestacion_pol';
      vparam         VARCHAR2(200)
         := 'p=' || pproceso || ' s=' || pseguros || ' e=' || psperson || ' p=' || psproduc
            || ' r=' || prealpre || ' 1=' || pf1pren || ' p=' || pfppren || ' e=' || pfefecto
            || ' c=' || pctabanc || ' t=' || ptiporen || ' s=' || pnsinies || ' t='
            || pctipban || ' n=' || pntramit || ' c=' || pctipdes || ' r=' || crevali || ' p='
            || prevali || ' i=' || irevali;
      val            NUMBER;   -- Valor que retorna la formula
      vformula       VARCHAR2(2000);   -- contiene la Formula a calcular
      vsesion        NUMBER;   -- Nro de sesion que ejecuta la formula
      vf1pren        NUMBER;   -- Primer pago renta
      vfppren        NUMBER;   -- Fecha pago
      vfecefe        NUMBER;   -- Fecha efecto de la póliza
      e              NUMBER;   -- Error Retorno funciones
      viretren       NUMBER;
      vibasren       NUMBER;
      visinren       NUMBER;
      viconren       NUMBER;
      vpretren       NUMBER;
      vtiporen       NUMBER;
      n_empresa      NUMBER;
      n_imp_aoa      NUMBER;
      f_cambio       DATE;

      --
           -- Bug 9970 - 04/05/2009 - AMC - Se unifica PRETREN y PRETENC
      CURSOR cur_campo(psprodu IN NUMBER) IS
         SELECT   DECODE(ccampo,
                         'ISINREN', 1,
                         'IBASREN', 2,
                         'PRETREN', 3,
                         'IRETREN', 4,
                         'ICONREN', 5,
                         'PREDUC', 6) orden,
                  ccampo, clave
             FROM rentasformula
            WHERE sproduc = psproduc
              AND ccampo IN('ISINREN', 'IBASREN', 'PRETREN', 'IRETREN', 'ICONREN', 'PREDUC')
         ORDER BY 1;

      vidpago        NUMBER;
      vpass          NUMBER;
      vxmaxmov       NUMBER;

      CURSOR cur_termino(wclave NUMBER) IS
         SELECT   parametro
             FROM sgt_trans_formula
            WHERE clave = wclave
         ORDER BY 1;

      xs             VARCHAR2(2000);
      v_cursor       INTEGER;
      retorno        NUMBER;
      v_filas        NUMBER;
------------------------------ calc_rentas ----------------------------------
   BEGIN
      vpass := 1;
      vf1pren := TO_NUMBER(TO_CHAR(pf1pren, 'yyyymmdd'));
      vfppren := TO_NUMBER(TO_CHAR(pfppren, 'yyyymmdd'));
      vfecefe := TO_NUMBER(TO_CHAR(pfefecto, 'yyyymmdd'));
      vpass := 2;

      SELECT sgt_sesiones.NEXTVAL
        INTO vsesion
        FROM DUAL;

      IF vsesion IS NULL THEN
         ROLLBACK;
         RETURN 108418;
      END IF;

      IF ptiporen = 'R' THEN
         vtiporen := 1;
      ELSIF ptiporen = 'I' THEN
         vtiporen := 2;
      ELSE
         vtiporen := 3;
      END IF;

      --
      e := graba_param(vsesion, 'SESION', vsesion);

      IF e = -9 THEN
         RETURN -9;
      END IF;

      -- Insertamos los parametros genericos para el calculo de un seguro.
      vpass := 2.1;
      e := graba_param(vsesion, 'FPAGREN', vfppren);

      IF e = -9 THEN
         RETURN -9;
      END IF;

      vpass := 2.1;
      e := graba_param(vsesion, 'NSINIES', pnsinies);

      IF e = -9 THEN
         RETURN -9;
      END IF;

      vpass := 2.1;
      e := graba_param(vsesion, 'NTRAMIT', pntramit);

      IF e = -9 THEN
         RETURN -9;
      END IF;

      vpass := 2.1;
      e := graba_param(vsesion, 'CTIPDES', pctipdes);

      IF e = -9 THEN
         RETURN -9;
      END IF;

      vpass := 2.2;
      e := graba_param(vsesion, 'SPERSON', psperson);

      IF e = -9 THEN
         RETURN -9;
      END IF;

--      vpass := 2.3;
--      e := graba_param(vsesion, 'SPERSON2', psperson2);

      --      IF e = -9 THEN
--         RETURN -9;
--      END IF;
      vpass := 2.4;
      e := graba_param(vsesion, 'FEFECTO', vfecefe);

      IF e = -9 THEN
         RETURN -9;
      END IF;

      vpass := 2.5;
      e := graba_param(vsesion, 'F1PAREN', vf1pren);

      IF e = -9 THEN
         RETURN -9;
      END IF;

      vpass := 2.6;
      e := graba_param(vsesion, 'SSEGURO', pseguros);

      IF e = -9 THEN
         RETURN -9;
      END IF;

      vpass := 2.7;
      e := graba_param(vsesion, 'SPRODUC', psproduc);

      IF e = -9 THEN
         RETURN -9;
      END IF;

      vpass := 2.8;
      e := graba_param(vsesion, 'ORIGEN', 2);

      IF e = -9 THEN
         RETURN -9;
      END IF;

      vpass := 2.9;
      e := graba_param(vsesion, 'TIPORENTA', vtiporen);

      IF e = -9 THEN
         RETURN -9;
      END IF;

      vpass := 3;
      e := graba_param(vsesion, 'NORDEN', 1);

      IF e = -9 THEN
         RETURN -9;
      END IF;

      vpass := 3;
      e := graba_param(vsesion, 'NPRESTA', pnpresta);

      IF e = -9 THEN
         RETURN -9;
      END IF;

      --
      FOR reg IN cur_campo(psproduc) LOOP
         BEGIN
            SELECT formula
              INTO vformula
              FROM sgt_formulas
             WHERE clave = reg.clave;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN 108423;
            WHEN OTHERS THEN
               RETURN 108423;
         END;

         FOR term IN cur_termino(reg.clave) LOOP
            BEGIN
               IF term.parametro NOT IN('NRIESGO', 'SSEGURO', 'SPERSON', 'NSINIES', 'NTRAMIT',
                                        'CTIPDES') THEN   --Se esta calculando en este momento
                  BEGIN
                     SELECT 'BEGIN SELECT ' || tcampo || ' INTO :RETORNO  FROM ' || ttable
                            || ' WHERE ' || twhere || ' ; END;'
                       INTO xs
                       FROM sgt_carga_arg_prede
                      WHERE termino = term.parametro
                        AND ttable IS NOT NULL
                        AND cllamada = 'PAC_SIN_FORMULA';
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN   --JRH 101/2008 Lo ponemos como en la simulación
                        SELECT 'BEGIN SELECT ' || tcampo || ' INTO :RETORNO  FROM ' || ttable
                               || ' WHERE ' || twhere || ' ; END;'
                          INTO xs
                          FROM sgt_carga_arg_prede
                         WHERE termino = term.parametro
                           AND ttable IS NOT NULL
                           AND cllamada = 'GENERICO';
                  END;

                  -- RSC 07/07/2008 Mejora propuesta por Sa Nostra (Patch SNVA_249b) Bind Variables
                  IF DBMS_SQL.is_open(v_cursor) THEN
                     DBMS_SQL.close_cursor(v_cursor);
                  END IF;

                  v_cursor := DBMS_SQL.open_cursor;
                  DBMS_SQL.parse(v_cursor, xs, DBMS_SQL.native);
                  DBMS_SQL.bind_variable(v_cursor, ':RETORNO', retorno);

                  IF INSTR(xs, ':NSINIES') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':NSINIES', pnsinies);
                  END IF;

                  IF INSTR(xs, ':NTRAMIT') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':NTRAMIT', pntramit);
                  END IF;

                  IF INSTR(xs, ':CTIPDES') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':CTIPDES', pctipdes);
                  END IF;

                  IF INSTR(xs, ':FSINIES') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':FSINIES', vfppren);
                  END IF;

                  IF INSTR(xs, ':SSEGURO') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':SSEGURO', pseguros);
                  END IF;

                  IF INSTR(xs, ':NRIESGO') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':NRIESGO', 1);
                  END IF;

                  IF INSTR(xs, ':SPERSON') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':SPERSON', psperson);
                  END IF;

                  IF INSTR(xs, ':FECHA') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':FECHA', vfppren);
                  END IF;

                  IF INSTR(xs, ':NPRESTA') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':NPRESTA', pnpresta);
                  END IF;

                  BEGIN
                     v_filas := DBMS_SQL.EXECUTE(v_cursor);
                     DBMS_SQL.variable_value(v_cursor, 'RETORNO', retorno);

                     IF DBMS_SQL.is_open(v_cursor) THEN
                        DBMS_SQL.close_cursor(v_cursor);
                     END IF;

                     IF retorno IS NULL THEN
                        p_tab_error(f_sysdate, f_user, 'PAC_SIN_FORMULA.f_cal_valora', 1,
                                    vsesion, 'Formula:' || xs);
                        RETURN 103135;
                     ELSE
                        e := graba_param(vsesion, term.parametro, retorno);

                        IF e <> 0 THEN
                           RETURN 109843;
                        END IF;
                     END IF;
                  --dbms_output.put_line(term.parametro||':'||Retorno);
                  EXCEPTION
                     WHEN OTHERS THEN
                        --DBMS_OUTPUT.put_line(term.parametro||':'||0);
                        e := graba_param(vsesion, term.parametro, 0);

                        IF e <> 0 THEN
                           RETURN 109843;
                        END IF;
                  END;
               END IF;
            --
            EXCEPTION
               WHEN OTHERS THEN
                  xs := NULL;
            END;
         END LOOP;

         vpass := 8;
         val := pk_formulas.eval(vformula, vsesion);

         IF val IS NULL THEN
            RETURN 103135;
         ELSE
            IF reg.ccampo = 'IRETREN' THEN
               e := graba_param(vsesion, 'IRETREN', val);
               viretren := val;

               IF e = -9 THEN
                  RETURN -9;
               END IF;
            END IF;

            IF reg.ccampo = 'IBASREN' THEN
               e := graba_param(vsesion, 'IBASREN', val);
               vibasren := val;

               IF e = -9 THEN
                  RETURN -9;
               END IF;
            END IF;

            IF reg.ccampo = 'ISINREN' THEN
               e := graba_param(vsesion, 'IBRUREN', val);

               IF e = -9 THEN
                  RETURN -9;
               END IF;

               e := graba_param(vsesion, 'ISINREN', val);
               visinren := val;

               IF e = -9 THEN
                  RETURN -9;
               END IF;
            END IF;

            vpass := 9;

            IF reg.ccampo = 'ICONREN' THEN
               e := graba_param(vsesion, 'ICONREN', val);
               viconren := val;

               IF e = -9 THEN
                  RETURN -9;
               END IF;
            END IF;

            IF reg.ccampo = 'PRETREN' THEN
               e := graba_param(vsesion, 'PRETREN', val);
               vpretren := val;

               IF e = -9 THEN
                  RETURN -9;
               END IF;
            END IF;
         END IF;
      END LOOP;   -- RentasFormula

      --
      vpass := 10;
      n_empresa := pac_contexto.f_contextovalorparametro(f_parinstalacion_t('CONTEXT_USER'),
                                                         'IAX_EMPRESA');

      --En ENSA las rentas de todos los productos las ponen en USD, por lo que para los productos en KWZ hay que hacer el contravalor.
      IF NVL(pac_parametros.f_parempresa_n(n_empresa, 'MULTIMONEDA'), 0) = 1
         AND NVL(pac_parametros.f_parlistado_n(n_empresa, 'MONEDAINFORME'), 0) = 1
         AND pac_monedas.f_moneda_producto(psproduc) = 7 THEN
         f_cambio := pac_eco_tipocambio.f_fecha_max_cambio('USD', 'AOA', f_sysdate);
         visinren := pac_eco_tipocambio.f_importe_cambio('USD', 'AOA', f_cambio, visinren);
         viconren := pac_eco_tipocambio.f_importe_cambio('USD', 'AOA', f_cambio, viconren);
         vibasren := pac_eco_tipocambio.f_importe_cambio('USD', 'AOA', f_cambio, vibasren);
      END IF;

      IF prealpre = 0 THEN   -- 0. Real
         e := insertar_pagos(pseguros, psperson, pfppren, visinren, vpretren, viretren,
                             viconren, vibasren, pctabanc, 0, pproceso, vidpago, pctipban,
                             pnsinies, pntramit, pctipdes);

         -- Mantis 10240.#6.i.06/2009.NMM.Si és paga Extra dupliquem el registre.
         IF ptiporen = 'E' THEN
            e := insertar_pagos(pseguros, psperson, pfppren, visinren, vpretren, viretren,
                                viconren, vibasren, pctabanc, 0, pproceso, vidpago, pctipban,
                                pnsinies, pntramit, pctipdes);
         END IF;

         -- Mantis 10240.#6.f.
         IF e <> 0 THEN
            RETURN e;
         END IF;
      ELSIF prealpre = 1
            OR prealpre = 3 THEN   -- 1.Previo Inserta TMP 3.Ins. Mensajes
         vpass := 12;

         -- Mantis 10240.#6.i.06/2009.NMM.Si és paga Extra s'hauria de duplicar el registre a tmp_pagosrenta,
         -- però no podem perquè té de clau primària stmppare, sseguro, sperson, ffecpag. Així
         -- que de moment multipliquem els camps d'import x2.
         IF ptiporen = 'E' THEN
            e := insertar_mensajes(pseguros, psperson, 1, vpretren,
                                   TO_NUMBER(TO_CHAR(pfppren, 'yyyymmdd')), 2 * viretren,
                                   2 * vibasren, 2 * viconren, 2 * visinren, pctabanc,
                                   prealpre, pproceso, pctipban, pnsinies, pntramit, pctipdes,
                                   pnpresta);
         ELSE
            e := insertar_mensajes(pseguros, psperson, 1, vpretren,
                                   TO_NUMBER(TO_CHAR(pfppren, 'yyyymmdd')), viretren,
                                   vibasren, viconren, visinren, pctabanc, prealpre, pproceso,
                                   pctipban, pnsinies, pntramit, pctipdes, pnpresta);
         END IF;

         -- Mantis 10240.#6.f.
         IF e <> 0 THEN
            RETURN e;
         END IF;
      ELSE   -- 2. Recalcular uno existente
         vpass := 13;

         BEGIN
            UPDATE pagosrenta
               SET isinret = visinren,
                   pretenc = vpretren,
                   iretenc = viretren,
                   iconret = viconren,
                   ibase = vibasren
             WHERE sseguro = pseguros
               AND srecren = pproceso;

            IF NVL
                  (pac_parametros.f_parempresa_n
                      (pac_contexto.f_contextovalorparametro
                                                           (f_parinstalacion_t('CONTEXT_USER'),
                                                            'IAX_EMPRESA'),
                       'MULTIMONEDA'),
                   0) = 1 THEN
               e := pac_oper_monedas.f_contravalores_pagosrenta(pproceso, pseguros);
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 109845;
         END;
      END IF;

      vpass := 14;
      /*SELECT nriesgo --Falla en el caso de dos cabezas si venimos con el otro asegurado. De momento en rentas podemos poner nriesgo=1.
        INTO xnriesgo
        FROM riesgos
       WHERE sseguro = pseguros
         AND sperson = psperson;*/
      vpass := 15;

      IF ptiporen = 'E' THEN
         vpass := 17;

         -- Mantis 10240.#6.i.06/2009.NMM.Només s'insertarà en el cas de Real.
         IF prealpre = 0 THEN
            SELECT NVL(MAX(nmovimi), 1)
              INTO vxmaxmov
              FROM planrentasextra
             WHERE sseguro = pseguros
               AND nriesgo = 1;

            INSERT INTO planrentasextra
                        (sseguro, nriesgo, nmovimi, fpago, ipago, cestado, srecren)
                 VALUES (pseguros, 1,(vxmaxmov + 1), pfppren, visinren, 0, vidpago);

            IF NVL
                  (pac_parametros.f_parempresa_n
                      (pac_contexto.f_contextovalorparametro
                                                           (f_parinstalacion_t('CONTEXT_USER'),
                                                            'IAX_EMPRESA'),
                       'MULTIMONEDA'),
                   0) = 1 THEN
               e := pac_oper_monedas.f_contravalores_planrentasextr(pseguros, 1,
                                                                    (vxmaxmov + 1));
            END IF;
         END IF;
      -- Mantis 10240.#6.f.
      END IF;

      vpass := 19;
      -- Borro sgt_parms_transitorios
      e := borra_param(vsesion);
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pk_rentas.f_calc_prestacion_pol', vpass,
                     'sale por others', SQLERRM);
         RETURN 1;
------------------------------ calc_rentas ----------------------------------
   END f_calc_prestacion_pol;

-- ****************************************************************
--  FUNCTION f_gen_prestaciones_poliza
--         Funció que genera les prestacions d'una pòlissa
--       param in psseguro : Clave seguro
--       param in psperson  : Persona
--       param in pfecha : Fecha pago
--       param in pf1paren : fecha primer pago
--       param in pfppren : Fecha próxima renta
--       param in pcforpag : Forma de pagi
--       param in pfefecto : Efecto póliza
--       param in pcbancar: Cuenta
--       param in psproduc :  Producto
--       param in prealpre :  -- 0-Real o 1-Previo Ins tmp. o 2-Recalcula 3-Previo
--       param in pproceso : Proceso
--       param in p_nmesextra : Mesos amb paga extra.
--       param in pnsinies : Siniestro
--         return            : 1 -> Tot correcte
--                             0 -> S'ha produit un error
-- ****************************************************************
   FUNCTION f_gen_prestaciones_poliza(
      psseguro IN NUMBER,   -- Clave seguro
      psperson IN NUMBER,
      pfecha IN DATE,   -- Fecha pago
      pf1paren IN DATE,
      pfppren IN DATE,
      pcforpag IN NUMBER,
      pfefecto IN DATE,   -- Fecha
      pcbancar IN VARCHAR2,   -- CCC
      psproduc IN NUMBER,   -- Clave producto
      prealpre IN NUMBER,   -- 0-Real o 1-Previo Ins tmp. o 2-Recalcula 3-Previo
      pproceso IN NUMBER,
      p_nmesextra IN VARCHAR2,   -- Mesos amb paga extra.
      pnsinies IN VARCHAR2,
      pctipban IN NUMBER,
      pntramit IN NUMBER,
      pctipdes IN NUMBER,
      crevali IN NUMBER,
      prevali IN NUMBER,
      irevali IN NUMBER,
      pnpresta IN NUMBER)
      RETURN NUMBER IS
      -- Variables de asegurados
      -- Variables para mandar al calculo
      vppren         DATE;
      xnum           NUMBER;   -- Valor de retorno calculo renta.
      vdd1pag        NUMBER;
      v_tiporen      VARCHAR2(20);
---------------------------- gen_calc_pol -----------------------------------
   BEGIN
      vppren := pfppren;

      -- Bucle de pagos que realizará hasta la fecha de petición
      WHILE vppren <= pfecha LOOP
         IF INSTR('|' || p_nmesextra || '|',
                  '|' || TRIM(LEADING '0' FROM TO_CHAR(vppren, 'MM')) || '|') <> 0 THEN
            v_tiporen := 'E';
         ELSE
            v_tiporen := 'R';
         END IF;

         xnum := f_calc_prestacion_pol(pproceso, psseguro, psperson, psproduc, prealpre,
                                       pf1paren, vppren, pfefecto, pcbancar, v_tiporen,
                                       pnsinies, pctipban, pntramit, pctipdes, crevali,
                                       prevali, irevali, pnpresta);

         --DBMS_OUTPUT.put_line('5________xnum:' || xnum);
         IF xnum <> 0 THEN
            --DBMS_OUTPUT.put_line('6________xnum:' || xnum);
            ROLLBACK;
            RETURN xnum;
         END IF;

         vppren := ADD_MONTHS(vppren, NVL(12 / pcforpag, 0));   --JRH IMP (He puesto 12 entre)
      END LOOP;

      IF prealpre = 0 THEN
         -- BUG 0015669 - 08/2010 - JRH  -  Alta prestacions en forma de renda (PL)
         UPDATE prestaren
            SET fppren = vppren
          WHERE sseguro = psseguro
            AND sperson = psperson
            AND ntramit = pntramit
            AND ctipdes = pctipdes
            AND nsinies = pnsinies
            AND npresta = pnpresta;

         -- fi BUG 0015669 - 08/2010 - JRH
         COMMIT;
      END IF;

      RETURN(0);
---------------------------- gen_calc_pol -----------------------------------
   END f_gen_prestaciones_poliza;

-- BUG 14185-  06/2010 - JRH

   -- ****************************************************************
  -- calc_rentas
-- Genera el recibo de renta para una fecha 0-Modo Real 1-Modo Previo

   --         Funció que genera les prestacions d'una pòlissa
--       param in pproceso : Proceso
--       param in psseguro : Clave seguro
--       param in psperson  : Persona
--       param in psperson2  : Persona2
--       param in pnroaseg : Número asegurado
--       param in pibruren : Importe renta
--       param in pfppren : Fecha próxima renta
--       param in pfefecto : Fecha efecto
--       param in pf1pren :Fecha Primer pago
--       param in pctabanc: Cuenta
--       param in ptiporen :  Tipo renta
--       param in prealpre :  -- 0-Real o 1-Previo Ins tmp. o 2-Recalcula 3-Previo
--         return            : 1 -> Tot correcte
--                             0 -> S'ha produit un error
-- ****************************************************************
-- ****************************************************************
   FUNCTION calc_rentas(
      pproceso IN NUMBER,   -- Nro. Proceso o Nro. Recibo
      pseguros IN NUMBER,   -- SSEGURO
      psperson IN NUMBER,   -- SPERSON 1er. Asegurado
      psperson2 IN NUMBER,   -- SPERSON 2on. Asegurado
      pnroaseg IN NUMBER,   -- Nro. de Asegurados 1 o 2
      psproduc IN NUMBER,   -- SPRODUC
      pibruren IN NUMBER,   -- BRUTO RENTA
      prealpre IN NUMBER,   -- 0-Real o 1-Previo Ins tmp. o 2-Recalcula 3-Previo
      pf1pren IN DATE,   -- Fecha 1er. pago de Renta
      pfppren IN DATE,   -- Fecha Proximo pago de renta
      pfefecto IN DATE,   -- Fecha
      pctabanc IN VARCHAR2,   -- Cuenta Bancaria
      ptiporen IN VARCHAR2,   -- Tipo de renta
      pctipban IN NUMBER)
      RETURN NUMBER IS
      val            NUMBER;   -- Valor que retorna la formula
      xxformula      VARCHAR2(2000);   -- contiene la Formula a calcular
      xxsesion       NUMBER;   -- Nro de sesion que ejecuta la formula
      xf1pren        NUMBER;   -- Primer pago renta
      xfppren        NUMBER;   -- Fecha pago
      xfecefe        NUMBER;   -- Fecha efecto de la póliza
      xfesmort       NUMBER;   -- Fecha para ver si esta muerto
      xsperson       NUMBER(10);   -- Clave del 1er. asegurado
      e              NUMBER;   -- Error Retorno funciones
      xiretren       NUMBER;
      xibasren       NUMBER;
      xisinren       NUMBER;
      xiconren       NUMBER;
      xpretren       NUMBER;
      xcodsigui      NUMBER;
      estamort       NUMBER;
      xnewdata       DATE;
      xdia1pag       NUMBER;
      xdiappag       NUMBER;
      xhacerrec      NUMBER;
      xnctacor       VARCHAR2(40);
      xnctacor1      VARCHAR2(40);
      xnctacor2      VARCHAR2(40);
      -- RSC 18/11/2008
      xtratado       NUMBER := 0;
      xnriesgo       NUMBER;
      xmaxmov        NUMBER;
      xpass          NUMBER;
      vtiporen       NUMBER;

      --
           -- Bug 9970 - 04/05/2009 - AMC - Se unifica PRETREN y PRETENC
      CURSOR cur_campo(psprodu IN NUMBER) IS
         SELECT   DECODE(ccampo,
                         'ISINREN', 1,
                         'IBASREN', 2,
                         'PRETREN', 3,
                         'IRETREN', 4,
                         'ICONREN', 5,
                         'PREDUC', 6) orden,
                  ccampo, clave
             FROM rentasformula
            WHERE sproduc = psproduc
              AND ccampo IN('ISINREN', 'IBASREN', 'PRETREN', 'IRETREN', 'ICONREN', 'PREDUC')
         ORDER BY 1;

      idpago         NUMBER;
------------------------------ calc_rentas ----------------------------------
   BEGIN
      xpass := 1;
      xf1pren := TO_NUMBER(TO_CHAR(pf1pren, 'yyyymmdd'));
      xfppren := TO_NUMBER(TO_CHAR(pfppren, 'yyyymmdd'));
      xfecefe := TO_NUMBER(TO_CHAR(pfefecto, 'yyyymmdd'));
      xpass := 2;

      SELECT sgt_sesiones.NEXTVAL
        INTO xxsesion
        FROM DUAL;

      IF xxsesion IS NULL THEN
         ROLLBACK;
         RETURN 108418;
      END IF;

      IF ptiporen = 'R' THEN
         vtiporen := 1;
      ELSIF ptiporen = 'I' THEN
         vtiporen := 2;
      ELSE
         vtiporen := 3;
      END IF;

      --
      e := graba_param(xxsesion, 'SESION', xxsesion);

      IF e = -9 THEN
         RETURN -9;
      END IF;

      -- Insertamos los parametros genericos para el calculo de un seguro.
      xpass := 2.1;
      e := graba_param(xxsesion, 'FPAGREN', xfppren);

      IF e = -9 THEN
         RETURN -9;
      END IF;

      xpass := 2.2;
      e := graba_param(xxsesion, 'SPERSON', psperson);

      IF e = -9 THEN
         RETURN -9;
      END IF;

      xpass := 2.3;
      e := graba_param(xxsesion, 'SPERSON2', psperson2);

      IF e = -9 THEN
         RETURN -9;
      END IF;

      xpass := 2.4;
      e := graba_param(xxsesion, 'FEFECTO', xfecefe);

      IF e = -9 THEN
         RETURN -9;
      END IF;

      xpass := 2.5;
      e := graba_param(xxsesion, 'F1PAREN', xf1pren);

      IF e = -9 THEN
         RETURN -9;
      END IF;

      xpass := 2.6;
      e := graba_param(xxsesion, 'SSEGURO', pseguros);

      IF e = -9 THEN
         RETURN -9;
      END IF;

      xpass := 2.7;
      e := graba_param(xxsesion, 'SPRODUC', psproduc);

      IF e = -9 THEN
         RETURN -9;
      END IF;

      xpass := 2.8;
      e := graba_param(xxsesion, 'ORIGEN', 2);

      IF e = -9 THEN
         RETURN -9;
      END IF;

      xpass := 2.9;
      e := graba_param(xxsesion, 'TIPORENTA', vtiporen);

      IF e = -9 THEN
         RETURN -9;
      END IF;

      xpass := 3;

      -- Busco la cuenta corriente donde se tiene que realizar el abono para cada asegurado
      -- Si no existe en SEG_ASECCARGO se mueve la del seguro.
      FOR xnorden IN 1 .. pnroaseg LOOP
         IF xnorden = 1 THEN
            xsperson := psperson;
         ELSE
            xsperson := psperson2;
         END IF;

         BEGIN
            SELECT nctacor
              INTO xnctacor
              FROM seg_aseccargo
             WHERE sseguro = pseguros
               AND sperson = xsperson;
         EXCEPTION
            WHEN OTHERS THEN
               xnctacor := NULL;
         END;

         IF xnorden = 1 THEN
            IF xnctacor IS NULL THEN
               xnctacor1 := pctabanc;
            ELSE
               xnctacor1 := xnctacor;
            END IF;
         ELSE
            IF xnctacor IS NULL THEN
               xnctacor2 := pctabanc;
            ELSE
               xnctacor2 := xnctacor;
            END IF;
         END IF;
      END LOOP;

      --
      xnctacor := NULL;
      xsperson := NULL;
      xpass := 4;

      --
      FOR xnorden IN 1 .. pnroaseg LOOP
         xpass := 5;
         estamort := 0;   -- Por defecto el asegurado esta vivo
         e := graba_param(xxsesion, 'NORDEN', xnorden);

         IF e = -9 THEN
            RETURN -9;
         END IF;

         IF xnorden = 1 THEN
            xsperson := psperson;
            estamort := gestmort1;
            xnctacor := xnctacor1;
         ELSE
            xsperson := psperson2;
            estamort := gestmort2;
            xnctacor := xnctacor2;
         END IF;

           -- RSC 18/11/2008 ---------------------------
           --xhacerrec := 0; -- Por defecto hace recibo.
         --
         xpass := 6;

         IF gnrecren = 0 THEN   -- Un recibo por asegurado
            IF estamort = 1 THEN
               IF gcmunrec = 0 THEN   -- Nuevo Recibo
                  IF xsperson = psperson THEN
                     xsperson := psperson2;
                     xnctacor := xnctacor2;
                  ELSE
                     xsperson := psperson;
                     xnctacor := xnctacor1;
                  END IF;

                  xhacerrec := 0;
               ELSE
                  xhacerrec := 1;   --JRH IMP Creo que aquí viene un 0
               END IF;
            END IF;
         ELSE   -- Un solo recibo al Primer asegurado
            IF estamort = 0 THEN   -- Como trata perimero a aseg 1, si este esta vivo se cuelga el pago de este
               xhacerrec := 0;
            END IF;
---------------------------------------------------------------------------
         END IF;

         xpass := 7;

         IF xhacerrec = 0
            AND xtratado = 0 THEN   -- 18/11/2008
            xtratado := 1;   -- Ya hemos insertado el pago de renta (no debe insertar nada mas)

            FOR reg IN cur_campo(psproduc) LOOP
               BEGIN
                  SELECT formula
                    INTO xxformula
                    FROM sgt_formulas
                   WHERE clave = reg.clave;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     RETURN 108423;
                  WHEN OTHERS THEN
                     RETURN 108423;
               END;

               xpass := 8;
               val := pk_formulas.eval(xxformula, xxsesion);

               IF val IS NULL THEN
                  RETURN 103135;
               ELSE
                  IF reg.ccampo = 'IRETREN' THEN
                     e := graba_param(xxsesion, 'IRETREN', val);
                     xiretren := val;

                     IF e = -9 THEN
                        RETURN -9;
                     END IF;
                  END IF;

                  IF reg.ccampo = 'IBASREN' THEN
                     e := graba_param(xxsesion, 'IBASREN', val);
                     xibasren := val;

                     IF e = -9 THEN
                        RETURN -9;
                     END IF;
                  END IF;

                  IF reg.ccampo = 'ISINREN' THEN
                     e := graba_param(xxsesion, 'IBRUREN', val);

                     IF e = -9 THEN
                        RETURN -9;
                     END IF;

                     e := graba_param(xxsesion, 'ISINREN', val);
                     xisinren := val;

                     IF e = -9 THEN
                        RETURN -9;
                     END IF;
                  END IF;

                  xpass := 9;

                  IF reg.ccampo = 'ICONREN' THEN
                     e := graba_param(xxsesion, 'ICONREN', val);
                     xiconren := val;

                     IF e = -9 THEN
                        RETURN -9;
                     END IF;
                  END IF;

                  IF reg.ccampo = 'PRETREN' THEN
                     e := graba_param(xxsesion, 'PRETREN', val);
                     xpretren := val;

                     IF e = -9 THEN
                        RETURN -9;
                     END IF;
                  END IF;
               END IF;
            END LOOP;   -- RentasFormula

            --
            xpass := 10;

            IF prealpre = 0 THEN   -- 0. Real
               e := insertar_pagos(pseguros, xsperson, pfppren, xisinren, xpretren, xiretren,
                                   xiconren, xibasren, xnctacor, estamort, pproceso, idpago,
                                   pctipban);

               -- Mantis 10240.#6.i.06/2009.NMM.Si és paga Extra dupliquem el registre.
               IF ptiporen = 'E' THEN
                  e := insertar_pagos(pseguros, xsperson, pfppren, xisinren, xpretren,
                                      xiretren, xiconren, xibasren, xnctacor, estamort,
                                      pproceso, idpago, pctipban);
               END IF;

               -- Mantis 10240.#6.f.
               IF NVL(f_parproductos_v(psproduc, 'PLAN_RENTAS'), 0) <> 0 THEN   -- JRH Asociamos a planrentas el pago realizado. Esto habría de hacerse más adelante de otra manera.
                  UPDATE planrentas
                     SET estado = 0,
                         srecren = idpago
                   WHERE sseguro = pseguros
                     AND fechaini <= TO_DATE(xfppren, 'yyyymmdd')
                     AND fechafin > TO_DATE(xfppren, 'yyyymmdd')
                     AND nmovimi = (SELECT MAX(a.nmovimi)
                                      FROM planrentas a
                                     WHERE a.sseguro = pseguros
                                       AND a.fechaini <= TO_DATE(xfppren, 'yyyymmdd')
                                       AND a.fechafin > TO_DATE(xfppren, 'yyyymmdd'));
               END IF;

               xpass := 11;

               IF e <> 0 THEN
                  RETURN e;
               END IF;
            ELSIF prealpre = 1
                  OR prealpre = 3 THEN   -- 1.Previo Inserta TMP 3.Ins. Mensajes
               xpass := 12;

               -- Mantis 10240.#6.i.06/2009.NMM.Si és paga Extra s'hauria de duplicar el registre a tmp_pagosrenta,
               -- però no podem perquè té de clau primària stmppare, sseguro, sperson, ffecpag. Així
               -- que de moment multipliquem els camps d'import x2.
               IF ptiporen = 'E' THEN
                  e := insertar_mensajes(pseguros, xsperson, xnorden, xpretren,
                                         TO_NUMBER(TO_CHAR(pfppren, 'yyyymmdd')),
                                         2 * xiretren, 2 * xibasren, 2 * xiconren,
                                         2 * xisinren, xnctacor, prealpre, pproceso, pctipban);
               ELSE
                  e := insertar_mensajes(pseguros, xsperson, xnorden, xpretren,
                                         TO_NUMBER(TO_CHAR(pfppren, 'yyyymmdd')), xiretren,
                                         xibasren, xiconren, xisinren, xnctacor, prealpre,
                                         pproceso, pctipban);
               END IF;

               -- Mantis 10240.#6.f.
               IF e <> 0 THEN
                  RETURN e;
               END IF;
            ELSE   -- 2. Recalcular uno existente
               xpass := 13;

               BEGIN
                  UPDATE pagosrenta
                     SET isinret = xisinren,
                         pretenc = xpretren,
                         iretenc = xiretren,
                         iconret = xiconren,
                         ibase = xibasren
                   WHERE sseguro = pseguros
                     AND srecren = pproceso;

                  IF NVL
                        (pac_parametros.f_parempresa_n
                            (pac_contexto.f_contextovalorparametro
                                                           (f_parinstalacion_t('CONTEXT_USER'),
                                                            'IAX_EMPRESA'),
                             'MULTIMONEDA'),
                         0) = 1 THEN
                     e := pac_oper_monedas.f_contravalores_pagosrenta(pproceso, pseguros);
                  END IF;
               EXCEPTION
                  WHEN OTHERS THEN
                     RETURN 109845;
               END;
            END IF;

            xpass := 14;
            /*SELECT nriesgo --Falla en el caso de dos cabezas si venimos con el otro asegurado. De momento en rentas podemos poner nriesgo=1.
              INTO xnriesgo
              FROM riesgos
             WHERE sseguro = pseguros
               AND sperson = psperson;*/
            xnriesgo := 1;
            xpass := 15;

            IF ptiporen = 'I' THEN
               xpass := 16;

               IF prealpre = 0 THEN
                  UPDATE planrentasirreg
                     SET srecren =
                            NVL
                               (idpago, 0)   --pproceso  --JRH IMP 06/2010 No el proceso, ha de ir  el srecren!!!!
                   WHERE sseguro = pseguros
                     AND nriesgo = xnriesgo
                     AND nmovimi = (SELECT MAX(nmovimi)
                                      FROM planrentasirreg
                                     WHERE sseguro = pseguros
                                       AND nriesgo = xnriesgo)
                     AND mes = TO_NUMBER(TO_CHAR(pfppren, 'mm'))
                     AND anyo = TO_NUMBER(TO_CHAR(pfppren, 'yyyy'));
               END IF;
            ELSIF ptiporen = 'E' THEN
               xpass := 17;

               -- Mantis 10240.#6.i.06/2009.NMM.Només s'insertarà en el cas de Real.
               IF prealpre = 0 THEN
                  SELECT NVL(MAX(nmovimi), 1)
                    INTO xmaxmov
                    FROM planrentasextra
                   WHERE sseguro = pseguros
                     AND nriesgo = xnriesgo;

                  INSERT INTO planrentasextra
                              (sseguro, nriesgo, nmovimi, fpago, ipago, cestado, srecren)
                       VALUES (pseguros, xnriesgo,(xmaxmov + 1), pfppren, xisinren, 0, idpago);

                  IF NVL
                        (pac_parametros.f_parempresa_n
                            (pac_contexto.f_contextovalorparametro
                                                           (f_parinstalacion_t('CONTEXT_USER'),
                                                            'IAX_EMPRESA'),
                             'MULTIMONEDA'),
                         0) = 1 THEN
                     e := pac_oper_monedas.f_contravalores_planrentasextr(pseguros, xnriesgo,
                                                                          (xmaxmov + 1));
                  END IF;
               END IF;
            -- Mantis 10240.#6.f.
            END IF;

            xpass := 18;
         END IF;   -- Estamort
      END LOOP;   -- Asegurados

      xpass := 19;
      -- Borro sgt_parms_transitorios
      e := borra_param(xxsesion);
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pk_rentas.calc_rentas', xpass, 'sale por others',
                     SQLERRM);
------------------------------ calc_rentas ----------------------------------
   END calc_rentas;

-- ****************************************************************
--gen_rec_pol
-- Genera pagos de una póliza

   --         Param in pfecha : fecha
--         Param in pseguro : seguro
-- return 0 o <>0 si hay error
-- ****************************************************************
   FUNCTION gen_rec_pol(pfecha IN DATE, pseguro IN NUMBER)
      RETURN NUMBER IS
      -- Variables Buscar Producto
      xsproduc       NUMBER;   -- Clave del producto
      xnrecren       NUMBER;
      -- Variables
      xxfppren       DATE;
      -- Variables de asegurados
      xnroaseg       NUMBER;   -- Nro de Asegurados
      xsperson       NUMBER(10);   -- Clave 1er asegurado
      xsperson2      NUMBER(10);   -- Clave 2on. asegurado
      -- Variables para mandar al calculo
      xnum           NUMBER;   -- Valor de retorno calculo renta.
      --
      xdd1pag        NUMBER;
      xddppag        NUMBER;
      xfmort1        DATE;
      xfmort2        DATE;
   BEGIN
      xsperson := 0;
      xsperson2 := 0;
      xnroaseg := 0;

      FOR aseg IN (SELECT   sperson, norden, ffecmue
                       FROM asegurados
                      WHERE sseguro = pseguro
                   ORDER BY norden) LOOP
         IF aseg.norden = 1 THEN
            xsperson := aseg.sperson;
            xfmort1 := aseg.ffecmue;
            xnroaseg := 1;
         ELSE
            xsperson2 := aseg.sperson;
            xfmort2 := aseg.ffecmue;
            xnroaseg := 2;
         END IF;
      END LOOP;

      IF xnroaseg = 0 THEN
         RETURN 108307;
      END IF;

      gcestmre_pol := NULL;
      gcblopag := NULL;

      -- Busca los datos de la póliza
      -- RSC 03/07/2008 Se modifica una condición de la select de este cursor.
      -- La situación es como sigue: Se ha detectado que no se puede hacer el proceso de revisión antes
      -- que el de pago de renta por que si no, nos encontramos con casos en que al realizar la revisión,
      -- el 12ª pago de renta se hace con el nuevo interés. Por eso, no se debe permitir realizar la
      -- revisión de interés si la FPPREN (SEGUROS_REN) <= FECHA_REVISION (SEGUROS_AHO). Esta condición
      -- ya se ha añadido en PRODUCCION_COMU.p_revision_renovacion (proceso de revisión).
      --
      -- Por otra parte, se debe proteger el pago de la renta para que NO se realice si la fecha del pago
      -- de renta es mayor que la fecha de revisión de interés del periodo. Esta protección se debe añadir
      -- ya que el proceso de revisión podría fallar durante algun periodo largo (llámese X), y durante
      -- todo ese periodo (hasta que funcione) no se debe generar el pago de la renta, ya que no tendría el
      -- interés que le toca.
      -- En otras palabras, la fecha de pago de la renta siempre debe ser menor a la fecha de revisión
      -- de interés ademas de ser menor de la fecha que se pasa por parámetro.
      --
      -- Nótese además, que este razonamiento solo es válido en el supuesto que el proceso de genración de
      -- pagos sea anterior al proceso de renovación de interés.
      --
      FOR ren IN
         (SELECT   sr.sseguro, sr.fppren, sr.ibruren, sr.cforpag, sr.f1paren, sr.cestmre,
                   s.fefecto, s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.cbancar, sr.cblopag,
                   s.ctipban
              FROM seguros_aho aho, seguros_ren sr, seguros s
             WHERE fppren <= pfecha
               AND sr.sseguro = pseguro
               AND s.sseguro = pseguro
               AND sr.sseguro = s.sseguro
               AND s.csituac = 0
               AND s.creteni = 0
               AND ffinren IS NULL
               AND aho.sseguro = sr.sseguro
               AND((aho.frevisio IS NULL)
                   OR(aho.frevisio IS NOT NULL
                      AND((fppren <= aho.frevisio
                           AND NVL(f_parproductos_v(s.sproduc, 'REVISAR_ANTES_RENTA'), 0) = 0)   --JRH REVISAR_ANTES_RENTA indica si se genera la renta con el nuevo valor de la revisión o con el valor anterior a esta
                          OR(fppren < aho.frevisio
                             AND NVL(f_parproductos_v(s.sproduc, 'REVISAR_ANTES_RENTA'), 0) = 1))))
          ORDER BY fppren) LOOP
         IF xsproduc IS NULL THEN
            SELECT p.sproduc, pr.nrecren, pr.cmunrec, pr.cestmre
              INTO xsproduc, gnrecren, gcmunrec, gcestmre
              FROM productos p, producto_ren pr
             WHERE p.cramo = ren.cramo
               AND p.cmodali = ren.cmodali
               AND p.ctipseg = ren.ctipseg
               AND p.ccolect = ren.ccolect
               AND p.sproduc = pr.sproduc;
         END IF;

         --
         gcestmre_pol := ren.cestmre;
         gcblopag := ren.cblopag;
         xxfppren := ren.fppren;
         xdd1pag := TO_NUMBER(TO_CHAR(ren.f1paren, 'dd'));

         WHILE xxfppren <= pfecha LOOP
            gestmort1 := 0;
            gestmort2 := 0;

            -- Actualizo indicador global de muerte 2on. asegurado
            IF xfmort1 IS NULL THEN
               gestmort1 := 0;
            ELSE
               IF xxfppren >= xfmort1 THEN
                  gestmort1 := 1;
               ELSE
                  gestmort1 := 0;
               END IF;
            END IF;

            -- Actualizo indicador global de muerte 2on. asegurado
            IF xfmort2 IS NULL THEN
               gestmort2 := 0;
            ELSE
               IF xxfppren >= xfmort2 THEN
                  gestmort2 := 1;
               ELSE
                  gestmort2 := 0;
               END IF;
            END IF;

            xnum := calc_rentas(0, ren.sseguro, xsperson, xsperson2, xnroaseg, xsproduc,
                                ren.ibruren, 0, ren.f1paren, xxfppren, ren.fefecto,
                                ren.cbancar, 'R', ren.ctipban);

            IF xnum <> 0 THEN
               ROLLBACK;
               RETURN xnum;
            END IF;

            xxfppren := ADD_MONTHS(xxfppren, NVL(12 / ren.cforpag, 0));
            xddppag := TO_NUMBER(TO_CHAR(xxfppren, 'dd'));

            IF xddppag > xdd1pag THEN
               xxfppren := TO_DATE(xdd1pag || TO_CHAR(xxfppren, 'mmyyyy'), 'ddmmyyyy');
            END IF;
         END LOOP;

         --
         UPDATE seguros_ren
            SET fppren = xxfppren
          WHERE sseguro = pseguro;

         COMMIT;
      --
      END LOOP;

      RETURN 0;
   END gen_rec_pol;

-- ****************************************************************
-- gen_rec_renta
-- Busca todas las polizas que hay que generar pagos

   --         Param in pfecha : fecha
--         Param in pcidioma : idioma
--         Param in pctipo : tipo -- 0-Real,1-Previo Ins.Tabla, 3-Previo Mens.
--         Param in psproduc : producto
--         Param in pusuario : cCódigo Usuario
--         Param in pseqtip1 : secencia -- Si pctipo=1 numero secuencia.
--         Param in pcempres : empresa
--         Param in psproces : proceso
--         Param out pnerror : Código error
-- return 0 o <>0 si hay error
-- ****************************************************************
   PROCEDURE gen_rec_rentas(
      pfecha IN DATE,   -- Fecha Pago
      pcidioma IN NUMBER,   -- Idioma
      pctipo IN NUMBER,   -- 0-Real,1-Previo Ins.Tabla, 3-Previo Mens.
      psproduc IN NUMBER,   -- Sequence del producto
      pusuario IN VARCHAR2,   -- Nombre Usuario
      pseqtip1 IN NUMBER,   -- Si pctipo=1 numero secuencia.
      pcempres IN NUMBER,
      psproces IN NUMBER,
      pnerror OUT NUMBER) IS
      -- Variables Producto
      xcramo         NUMBER;
      xcmodali       NUMBER;
      xctipseg       NUMBER;
      xccolect       NUMBER;
      -- Variables grabar procesos
      xnproc         NUMBER;   -- Nro de Proceso
      xnumlin        NUMBER;   -- Numero de linea
      num_err        NUMBER;   -- Valor de retorno procesos
      xnerror        NUMBER;   -- Numero de errores del proceso
      xferror        NUMBER;   -- Se a producido error en una iteración
      texto          VARCHAR2(200);
      -- Variables de asegurados
      xnroaseg       NUMBER;   -- Nro de Asegurados
      xsperson       NUMBER(10);   -- Clave 1er asegurado
      xsperson2      NUMBER(10);   -- Clave 2on. asegurado
      -- Variables para mandar al calculo
      xnum           NUMBER;   -- Valor de retorno calculo renta.
      xxfppren       DATE;   -- Fecha próxima renta
      xxfecha        DATE;   --
      -- Variables de control
      xffecpag1      DATE;
      xffecpag2      DATE;
      xhaypag        NUMBER;   -- Generico. Esta calculado el recibo
      xhaypag1       NUMBER;   -- Esta calculado el recibo 1er. asegurado
      xhaypag2       NUMBER;   -- Esta calculado el recibo 2on. asegurado
      xhaymort       NUMBER;   -- Indicador de que hay muerto
      xhaymort1      NUMBER;   -- Indicador de que está muerto 1er. asegurado
      xhaymort2      NUMBER;   -- Indicador de que está muerto 2on. asegurado
      vfultpag       DATE;
      xnmeses        NUMBER;
      xmesultpago    NUMBER;
      vvalor         VARCHAR2(50);
      vhay           NUMBER;
      vnewfppren     DATE;
      vmeses         NUMBER;
      vdia           NUMBER;
      vanyo          NUMBER;
      ttexto         VARCHAR2(400);

      CURSOR c_prod IS
         SELECT   pr.sproduc, pr.cramo, pr.cmodali, pr.ctipseg, pr.ccolect, pren.nrecren,
                  pren.cmunrec, pren.cestmre
             FROM productos pr, producto_ren pren
            WHERE pr.cprprod = 1   --JRH IMP Cambiarlo a 10
              AND pr.sproduc BETWEEN NVL(psproduc, 0) AND NVL(psproduc, 9999999999)
              AND pr.sproduc = pren.sproduc
         ORDER BY cramo, cmodali, ctipseg, ccolect;
   ----------------------------- gen_rec_rentas --------------------------------
   BEGIN
      xnerror := 0;
      num_err := 0;
      valores.DELETE;
      gnvalor := 0;
      gnpoliz := 0;

      --Bug.: 0012914 - 20/04/2010 - ICV - Reimprimir listados de pagos de rentas
      -- Para cabecera de Procesos
      /*IF psproduc = 0
         OR psproduc IS NULL THEN
         IF pctipo = 0 THEN
            num_err := f_procesini(pusuario, pcempres, 'GENERENTAS',
                                   'Generación de Rentas Todos prod. ' || pfecha, xnproc);
         ELSE
            num_err := f_procesini(pusuario, pcempres, 'PREVRENTAS',
                                   'Proceso Previo Rentas Todos prod. ' || pfecha, xnproc);
         END IF;
      ELSE
         SELECT cramo, cmodali, ctipseg, ccolect
           INTO xcramo, xcmodali, xctipseg, xccolect
           FROM productos
          WHERE sproduc = psproduc;

         IF pctipo = 0 THEN
            num_err := f_procesini(pusuario, pcempres, 'GENERENTAS',
                                   2 || ' ' || 'Generación de Rentas por Producto' || ' '
                                   || pfecha || ' ' || xcramo || '-' || xcmodali || '-'
                                   || xctipseg || '-' || xccolect,
                                   xnproc);
         ELSE
            num_err := f_procesini(pusuario, pcempres, 'PREVRENTAS',
                                   2 || ' ' || 'Previo Rentas por Producto' || ' ' || pfecha
                                   || ' ' || xcramo || '-' || xcmodali || '-' || xctipseg
                                   || '-' || xccolect,
                                   xnproc);
         END IF;
      END IF;

      -- RSC 18/08/2008 Asignamos el numero de proceso a la variable de salida*/
      --psproces := xnproc;
      IF pctipo = 1 THEN
         gstmppagren := pseqtip1;
      END IF;

      --
      IF num_err <> 0 THEN
         xnerror := 1;
         ttexto := f_axis_literales(num_err, pcidioma);
         xnumlin := NULL;
         num_err := f_proceslin(psproces, texto, 0, xnumlin);
         COMMIT;
      ELSE
         COMMIT;

         FOR prod IN c_prod LOOP
            gcmunrec := prod.cmunrec;
            gcestmre := prod.cestmre;
            gnrecren := prod.nrecren;

            -- Busca todas las pólizas del/los productos de petición que les corresponda pago
            -- para la fecha determinada
            -- Busca los datos de la póliza
            -- RSC 03/07/2008 Se modifica una condición de la select de este cursor.
            -- La situación es como sigue: Se ha detectado que no se puede hacer el proceso de revisión antes
            -- que el de pago de renta por que si no, nos encontramos con casos en que al realizar la revisión,
            -- el 12ª pago de renta se hace con el nuevo interés. Por eso, no se debe permitir realizar la
            -- revisión de interés si la FPPREN (SEGUROS_REN) <= FECHA_REVISION (SEGUROS_AHO). Esta condición
            -- ya se ha añadido en PRODUCCION_COMU.p_revision_renovacion (proceso de revisión).
            --
            -- Por otra parte, se debe proteger el pago de la renta para que NO se realice si la fecha del pago
            -- de renta es mayor que la fecha de revisión de interés del periodo. Esta protección se debe añadir
            -- ya que el proceso de revisión podría fallar durante algun periodo largo (llámese X), y durante
            -- todo ese periodo (hasta que funcione) no se debe generar el pago de la renta, ya que no tendría el
            -- interés que le toca.
            -- En otras palabras, la fecha de pago de la renta siempre debe ser menor a la fecha de revisión
            -- de interés ademas de ser menor de la fecha que se pasa por parámetro.
            --
            -- Nótese además, que este razonamiento solo es válido en el supuesto que el proceso de genración de
            -- pagos sea anterior al proceso de renovación de interés.
            --
            FOR ren IN
               (SELECT sr.sseguro, sr.fppren, sr.ibruren, sr.cforpag, sr.f1paren, sr.cestmre,
                       s.fefecto, s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.cbancar,
                       sr.cblopag, 'R' tiporenta, aho.frevant frevisio, sr.nmesextra,
                       s.ctipban
                  FROM seguros_aho aho, seguros_ren sr, seguros s
                 WHERE fppren <= pfecha
                   AND sr.sseguro = s.sseguro
                   AND s.csituac = 0
                   AND s.creteni = 0
                   AND s.cramo = prod.cramo
                   AND s.cmodali = prod.cmodali
                   AND s.ctipseg = prod.ctipseg
                   AND s.ccolect = prod.ccolect
                   AND ffinren IS NULL
                   AND aho.sseguro = sr.sseguro
                   AND((aho.frevisio IS NULL)
                       OR(aho.frevisio IS NOT NULL
                          AND(   --JRH REVISAR_ANTES_RENTA indica si se genera la renta con el nuevo valor de la revisión o con el valor anterior a esta
                              (fppren <= aho.frevisio
                               AND NVL(f_parproductos_v(s.sproduc, 'REVISAR_ANTES_RENTA'), 0) =
                                                                                              0)
                              OR(fppren < aho.frevisio
                                 AND NVL(f_parproductos_v(s.sproduc, 'REVISAR_ANTES_RENTA'), 0) =
                                                                                              1))))
                   -- 10.0   03/06/2010  JGR  0014658: CRE998- Parametrizar día de pago en Rentas Irregulares - INI
                   AND NOT EXISTS(SELECT 1
                                    FROM planrentasirreg p
                                   WHERE p.sseguro = s.sseguro)
                -- 10.0   03/06/2010  JGR  0014658: CRE998- Parametrizar día de pago en Rentas Irregulares - FIN
                UNION
                -- Cursor de rentas irregulares
                SELECT s.sseguro,

                       -- 10.0   03/06/2010  JGR  0014658: CRE998- Parametrizar día de pago en Rentas Irregulares - INI
                       f_valida_date
                          (LPAD

                              -- Ini Bug 16830 - SRA - 26/11/2010: consultamos la respuesta dada por el usuario sobre qué día pagará la renta,
                              -- si no hay respuesta utilizamos el parámetro de producto
                           (   DECODE
                                    (NVL(pac_preguntas.ff_buscapregunseg(s.sseguro, 1, 9004,
                                                                         NULL, NULL),
                                         f_parproductos_v(s.sproduc, 'DIAPAGORENTA')),
                                     NULL, 1,
                                     0, 1,
                                     NVL(pac_preguntas.ff_buscapregunseg(s.sseguro, 1, 9004,
                                                                         NULL, NULL),
                                         f_parproductos_v(s.sproduc, 'DIAPAGORENTA'))),

                               -- Fin Bug 16830 - SRA - 26/11/2010
                               2, '0')
                           -- 10.0   03/06/2010  JGR  0014658: CRE998- Parametrizar día de pago en Rentas Irregulares - FIN
                           || LPAD(p.mes, 2, '0') || p.anyo) fppren,
                       NULL ibruren, s.cforpag, NULL f1paren, NULL cestmre, s.fefecto, s.cramo,
                       s.cmodali, s.ctipseg, s.ccolect, s.cbancar, NULL cblopag, 'I' tiporenta,
                       NULL frevisio, NULL nmesextra, s.ctipban
                  FROM seguros s, planrentasirreg p
                 WHERE s.creteni = 0
                   AND s.csituac = 0
                   AND s.cramo = prod.cramo
                   AND s.cmodali = prod.cmodali
                   AND s.ctipseg = prod.ctipseg
                   AND s.ccolect = prod.ccolect
                   AND p.sseguro = s.sseguro
                   -- ini Bug 0019649 - JMF - 14/10/2011
                   AND p.nmovimi = (SELECT MAX(p1.nmovimi)
                                      FROM planrentasirreg p1
                                     WHERE p1.sseguro = p.sseguro
                                       AND p1.nriesgo = p.nriesgo)
                   -- fin Bug 0019649 - JMF - 14/10/2011
                    -- 10.0   03/06/2010  JGR  0014658: CRE998- Parametrizar día de pago en Rentas Irregulares - INI
                   AND f_valida_date
                           (LPAD(DECODE(
                                        -- Ini Bug 16830 - SRA - 26/11/2010
                                        NVL(pac_preguntas.ff_buscapregunseg(s.sseguro, 1, 9004,
                                                                            NULL, NULL),
                                            f_parproductos_v(s.sproduc, 'DIAPAGORENTA')),
                                        NULL, 1,
                                        0, 1,
                                        NVL(pac_preguntas.ff_buscapregunseg(s.sseguro, 1, 9004,
                                                                            NULL, NULL),
                                            f_parproductos_v(s.sproduc, 'DIAPAGORENTA'))),

                                 -- FiN Bug 16830 - SRA - 26/11/2010
                                 2, '0')
                            -- 10.0   03/06/2010  JGR  0014658: CRE998- Parametrizar día de pago en Rentas Irregulares - FIN
                            || LPAD(p.mes, 2, '0') || p.anyo) <= pfecha
                   AND p.srecren IS NULL) LOOP
               xferror := 0;
               gnpoliz := gnpoliz + 1;
               gcestmre_pol := ren.cestmre;
               gcblopag := ren.cblopag;
               -- S'elimina codi tractament rendes 'E', i union de la select.#6.
               p_tab_error(f_sysdate, f_user, 'PK_RENTAS.gen_rec_rentas', 1,
                           'prod.sproduc : ' || prod.sproduc || ' ren.nmesextra : '
                           || ren.nmesextra || ' ren.fppren' || ren.fppren,
                           SQLERRM);
               num_err := gen_calc_pol(ren.sseguro, pfecha, ren.fppren, ren.ibruren,
                                       ren.cforpag, ren.f1paren, ren.fefecto, ren.cbancar,
                                       prod.sproduc, pctipo, psproces, ren.tiporenta,
                                       ren.nmesextra, ren.ctipban);

               IF num_err <> 0 THEN
                  ttexto := f_axis_literales(num_err, pcidioma);
                  xnumlin := NULL;
                  num_err := f_proceslin(psproces, texto, ren.sseguro, xnumlin);

                  IF num_err = 0 THEN
                     COMMIT;
                  END IF;

                  xferror := 1;
                  xnerror := xnerror + 1;
               END IF;
            END LOOP;   -- Seguros

            -- Bug 0013477 - JMF - 29/03/2011: Afegir sinistre tancat.
            FOR ren IN (SELECT sr.sseguro, sr.fppren, sr.ibruren, sr.cforpag, sr.f1paren,
                               s.fefecto, s.cramo, s.cmodali, s.ctipseg, s.ccolect, sr.cbancar,
                               'R' tiporenta, sr.nmesextra, sr.nsinies, sr.sperson, sr.ntramit,
                               sr.ctipdes, sr.ctipban, sr.cblopag, sr.crevali, sr.prevali,
                               sr.irevali, sr.npresta
                          FROM prestaren sr, seguros s, sin_movsiniestro m
                         WHERE fppren <= pfecha
                           AND sr.sseguro = s.sseguro
                           -- AND s.csituac = 0 --JRH 27/12/2011 Cambio (algunas pólizas pueden estar anuladas por prestación)
                           -- AND s.creteni = 0
                           AND s.cramo = prod.cramo
                           AND s.cmodali = prod.cmodali
                           AND s.ctipseg = prod.ctipseg
                           AND s.ccolect = prod.ccolect
                           AND s.ccobban IS NOT NULL
                           AND NVL(sr.cestado, 0) = 0
                           AND((sr.fuparen IS NULL)
                               OR(sr.fuparen IS NOT NULL
                                  AND sr.fuparen >= pfecha))
                           AND ffinren IS NULL
                           AND m.nsinies = sr.nsinies
                           AND m.nmovsin = (SELECT MAX(m1.nmovsin)
                                              FROM sin_movsiniestro m1
                                             WHERE m1.nsinies = sr.nsinies)
                           AND m.cestsin IN(0, 1, 4)) LOOP   --JRH De momento dejamos todas estas opciones
               xferror := 0;
               gnpoliz := gnpoliz + 1;
               gcblopag := ren.cblopag;
               gcestmre_pol := NULL;
               num_err := f_gen_prestaciones_poliza(ren.sseguro, ren.sperson, pfecha,
                                                    ren.f1paren, ren.fppren, ren.cforpag,
                                                    ren.fefecto, ren.cbancar, prod.sproduc,
                                                    pctipo, psproces, ren.nmesextra,
                                                    ren.nsinies, ren.ctipban, ren.ntramit,
                                                    ren.ctipdes, ren.crevali, ren.prevali,
                                                    ren.irevali, ren.npresta);

               IF num_err <> 0 THEN
                  ttexto := f_axis_literales(num_err, pcidioma);
                  xnumlin := NULL;
                  num_err := f_proceslin(psproces, texto, ren.sseguro, xnumlin);

                  IF num_err = 0 THEN
                     COMMIT;
                  END IF;

                  xferror := 1;
                  xnerror := xnerror + 1;
               END IF;
            END LOOP;   -- Seguros
         END LOOP;   -- Productos

         IF gnpoliz = 0 THEN   -- RSC 18/08/2008
            ttexto := f_axis_literales(102903, pcidioma);
            xnumlin := NULL;
            num_err := f_proceslin(psproces, texto, 0, xnumlin);

            IF num_err = 0 THEN
               COMMIT;
            END IF;

            xnerror := 0;
         ELSE   -- Se han procesado nvalor
            ttexto := f_axis_literales(104359, pcidioma);
            texto := texto || ' ' || gnpoliz;
            num_err := f_proceslin(psproces, texto, 0, xnumlin);

            IF num_err = 0 THEN
               COMMIT;
            END IF;

            xnerror := 0;
         END IF;
      END IF;

      -- num_err := f_procesfin(xnproc, xnerror);
      pnerror := xnerror;
      COMMIT;
   ----------------------------- gen_rec_rentas --------------------------------
   END gen_rec_rentas;

-- ****************************************************************
--  gen_calc_pol
-- Generar pagos de una póliza

   --       param in pproceso : Proceso
--       param in psseguro : Clave seguro
--       param in psperson  : Persona
--       param in psperson2  : Persona2
--       param in pnroaseg : Número asegurado
--       param in pibruren : Importe renta
--       param in pfppren : Fecha próxima renta
--       param in pfefecto : Fecha efecto
--       param in pf1pren :Fecha Primer pago
--       param in pctabanc: Cuenta
--       param in ptiporen :  Tipo renta
--       param in prealpre :  -- 0-Real o 1-Previo Ins tmp. o 2-Recalcula 3-Previo
--         return            : 1 -> Tot correcte
--                             0 -> S'ha produit un error
-- ****************************************************************
   FUNCTION gen_calc_pol(
      psseguro IN NUMBER,   -- Clave seguro
      pfecha IN DATE,   -- Fecha pago
      pfppren IN DATE,   -- Fecha proximo pago
      pibruren IN NUMBER,   -- Importe bruto renta
      pcforpag IN NUMBER,   -- Forma pago renta
      pf1paren IN DATE,   -- Fecha inicio renta
      pfefecto IN DATE,   -- Fecha
      pcbancar IN VARCHAR2,   -- CCC
      psproduc IN NUMBER,   -- Clave producto
      prealpre IN NUMBER,   -- 0-Real o 1-Previo Ins tmp. o 2-Recalcula 3-Previo
      pproceso IN NUMBER,   -- Nro. proceso
      ptiporen IN OUT VARCHAR2,   -- Tipo de renta
      p_nmesextra IN VARCHAR2,   -- Mesos amb paga extra.
      pctipban IN NUMBER)
      RETURN NUMBER IS
      -- Variables de asegurados
      xnroaseg       NUMBER;   -- Nro de Asegurados
      xsperson       NUMBER(10);   -- Clave 1er asegurado
      xfmort1        DATE;   -- Fecha en que deja de estar activo el 1er. Aseg.
      xsperson2      NUMBER(10);   -- Clave 2on. asegurado
      xfmort2        DATE;   -- Fecha en que deja de estar activo el 2on. Aseg.
      -- Variables para mandar al calculo
      xxfppren       DATE;
      xnum           NUMBER;   -- Valor de retorno calculo renta.
      xdd1pag        NUMBER;
      xddppag        NUMBER;
      -- #6.
      w_tiporen      VARCHAR2(1) := ptiporen;
---------------------------- gen_calc_pol -----------------------------------
   BEGIN
      xsperson := 0;
      xsperson2 := 0;
      xnroaseg := 0;

      FOR aseg IN (SELECT   sperson, norden, ffecmue
                       FROM asegurados
                      WHERE sseguro = psseguro
                   ORDER BY norden) LOOP
         IF aseg.norden = 1 THEN
            xsperson := aseg.sperson;
            xfmort1 := aseg.ffecmue;
            xnroaseg := 1;
         ELSE
            xsperson2 := aseg.sperson;
            xfmort2 := aseg.ffecmue;
            xnroaseg := 2;
         END IF;
      END LOOP;

      IF xnroaseg = 0 THEN
         RETURN 108307;
      END IF;

      IF ptiporen = 'R' THEN
         xdd1pag := TO_NUMBER(TO_CHAR(pf1paren, 'dd'));
         xxfppren := pfppren;

         -- Bucle de pagos que realizará hasta la fecha de petición
         WHILE xxfppren <= pfecha LOOP
            gestmort1 := 0;
            gestmort2 := 0;

            -- Actualizo indicador global de muerte 2on. asegurado
            IF xfmort1 IS NULL THEN
               gestmort1 := 0;
            ELSE
               IF xxfppren >= xfmort1 THEN
                  gestmort1 := 1;
               ELSE
                  gestmort1 := 0;
               END IF;
            END IF;

            -- Actualizo indicador global de muerte 2on. asegurado
            IF xfmort2 IS NULL THEN
               gestmort2 := 0;
            ELSE
               IF xxfppren >= xfmort2 THEN
                  gestmort2 := 1;
               ELSE
                  gestmort2 := 0;
               END IF;
            END IF;

            -- Mantis 10240.#6.i.06/2009.NMM.Mirarem si el mes que estem tractant
            -- té alguna renda Extra.Si arribem aqui sabem que ptiporen = 'R'
            IF INSTR('|' || p_nmesextra || '|',
                     '|' || TRIM(LEADING '0' FROM TO_CHAR(xxfppren, 'MM')) || '|') <> 0 THEN
               w_tiporen := 'E';
            ELSE
               w_tiporen := 'R';
            END IF;

            -- Mantis 10240.#6.Fi.06/2009.NMM.

            --   Llamo a la función que calcula recibos
            --p_tab_error(f_sysdate, f_user, 'PK_RENTAS', 1,
            --            'psseguro : ' || psseguro || ' psproduc : ' || psproduc, SQLERRM);
            xnum := calc_rentas(pproceso, psseguro, xsperson, xsperson2, xnroaseg, psproduc,
                                pibruren, prealpre, pf1paren, xxfppren, pfefecto, pcbancar,
                                w_tiporen, pctipban);

            IF xnum <> 0 THEN
               ROLLBACK;
               RETURN xnum;
            END IF;

            xxfppren := ADD_MONTHS(xxfppren, NVL(12 / pcforpag, 0));   --JRH IMP (He puesto 12 entre)
            xddppag := TO_NUMBER(TO_CHAR(xxfppren, 'dd'));

            IF xddppag > xdd1pag THEN
               xxfppren := f_valida_date(xdd1pag || TO_CHAR(xxfppren, 'mmyyyy'));
            -- xxfppren := TO_DATE(xdd1pag || TO_CHAR(xxfppren, 'mmyyyy'), 'ddmmyyyy'); -- 10.0   JGR  0014658
            END IF;
         END LOOP;
      ELSIF ptiporen = 'I' THEN
         gestmort1 := 0;
         gestmort2 := 0;
         xdd1pag := 1;
         xxfppren := pfppren;

         -- Actualizo indicador global de muerte 2on. asegurado
         IF xfmort1 IS NULL THEN
            gestmort1 := 0;
         ELSE
            IF xxfppren >= xfmort1 THEN
               gestmort1 := 1;
            ELSE
               gestmort1 := 0;
            END IF;
         END IF;

         -- Actualizo indicador global de muerte 2on. asegurado
         IF xfmort2 IS NULL THEN
            gestmort2 := 0;
         ELSE
            IF xxfppren >= xfmort2 THEN
               gestmort2 := 1;
            ELSE
               gestmort2 := 0;
            END IF;
         END IF;

         -- Llamo a la función que calcula recibos
         xnum := calc_rentas(pproceso, psseguro, xsperson, xsperson2, xnroaseg, psproduc,
                             pibruren, prealpre, pf1paren, xxfppren, pfefecto, pcbancar,
                             ptiporen, pctipban);

         IF xnum <> 0 THEN
            ROLLBACK;
            RETURN xnum;
         END IF;

         IF pcforpag = 0 THEN
            xxfppren := ADD_MONTHS(xxfppren, 12);   --JRH IMP (He puesto 12 entre)
         ELSE
            xxfppren := ADD_MONTHS(xxfppren, NVL(12 / pcforpag, 1));   --JRH IMP (He puesto 12 entre)
         END IF;

         xddppag := TO_NUMBER(TO_CHAR(xxfppren, 'dd'));
      --No hace falta hacerlo para una renta irregular
      -- IF xddppag > xdd1pag THEN
      --    xxfppren := TO_DATE(xdd1pag || TO_CHAR(xxfppren, 'mmyyyy'), 'ddmmyyyy');
      -- END IF;
      END IF;

      IF prealpre = 0 THEN
         UPDATE seguros_ren
            SET fppren = xxfppren
          WHERE sseguro = psseguro;

         COMMIT;
      END IF;

      RETURN(0);
---------------------------- gen_calc_pol -----------------------------------
   END gen_calc_pol;

   FUNCTION f_distribuir_inversion(
      pcempres IN NUMBER,
      psseguro IN NUMBER,
      pnnumlin IN NUMBER,
      pccalint IN NUMBER,
      psrecren IN NUMBER,
      pisinret IN NUMBER,
      pcmovimi IN NUMBER,
      pcmovimi_detalle IN NUMBER)
      RETURN NUMBER IS
      -- Bug 17247 - RSC - 11/03/2011 - ENSA103 - Instalar els web-services als entorns CSI
      vacumpercent   NUMBER := 0;
      xidistrib      NUMBER;
      vacumrounded   NUMBER := 0;
      viuniact       tabvalces.iuniact%TYPE;
      v_fcontab      ctaseguro.fcontab%TYPE;
      v_fefecto      ctaseguro.ffecmov%TYPE;
      v_fvalmov      ctaseguro.fvalmov%TYPE;
      v_seqgrupo     NUMBER;
      vfdiahabil     DATE;
      xnnumlin       ctaseguro.nnumlin%TYPE;
      num_err        axis_literales.slitera%TYPE;
      v_cempres      seguros.cempres%TYPE;
      v_cmultimon    parempresas.nvalpar%TYPE;

      CURSOR cur_segdisin2_act(seguro NUMBER) IS
         SELECT sseguro, ccesta, pdistrec, pdistuni, pdistext
           FROM segdisin2
          WHERE sseguro = seguro
            AND nmovimi = (SELECT MAX(nmovimi)
                             FROM segdisin2
                            WHERE sseguro = seguro
                              AND ffin IS NULL)
            AND ffin IS NULL;
   -- Fin Bug 17247
   BEGIN
      SELECT cempres
        INTO v_cempres
        FROM seguros
       WHERE sseguro = psseguro;

      v_cmultimon := NVL(pac_parametros.f_parempresa_n(v_cempres, 'MULTIMONEDA'), 0);   -- BUG 18423 - 29/12/2011 - JMP - Multimoneda

      SELECT fcontab, ffecmov, fvalmov
        INTO v_fcontab, v_fefecto, v_fvalmov
        FROM ctaseguro
       WHERE sseguro = psseguro
         AND nnumlin = NVL(pnnumlin + 1, 1);

      -- Bug 17247 - RSC - 11/03/2011
      IF pcmovimi = 10 THEN
         v_fefecto := TRUNC(f_sysdate);   -- Las anulaciones de prestación realizadas deben tener fecha efecto f_sysdate.
                                          -- aunque tengan una fvalor anterior. De esta manera las podremos controlar
                                          -- en entradas/salidas.
      END IF;

      -- Fin Bug 17247

      -- Comprobamos si los fondos están cerrados en el
      -- momento de la generación del pago de renta.
      IF pcmovimi <> 10 THEN
         -- Bug 20309 - RSC - 20/12/2011 - LCOL_T004-Parametrización Fondos
         --IF TO_NUMBER(TO_CHAR(v_fefecto, 'd')) IN(6, 7) THEN
         IF NVL(pac_parametros.f_parempresa_n(pcempres, 'HABIL_FIN_SEMANA'), 0) = 0 THEN
            IF TRIM(TO_CHAR(v_fefecto, 'DAY', ' NLS_DATE_LANGUAGE=''AMERICAN'' ')) IN
                                                                        ('SATURDAY', 'SUNDAY') THEN
               v_fefecto := f_diahabil(0, TRUNC(v_fefecto), NULL);
            END IF;
         END IF;
      END IF;

      -- Bug 20309 - RSC - 20/12/2011 - LCOL_T004-Parametrización Fondos
      --IF TO_NUMBER(TO_CHAR(v_fvalmov, 'd')) IN(6, 7) THEN
      IF NVL(pac_parametros.f_parempresa_n(pcempres, 'HABIL_FIN_SEMANA'), 0) = 0 THEN
         IF TRIM(TO_CHAR(v_fvalmov, 'DAY', ' NLS_DATE_LANGUAGE=''AMERICAN'' ')) IN
                                                                        ('SATURDAY', 'SUNDAY') THEN
            v_fvalmov := f_diahabil(0, TRUNC(v_fvalmov), NULL);
         END IF;
      END IF;

      -- Verificació de fons tancats / oberts
      IF pac_mantenimiento_fondos_finv.f_get_estado_fondo(pcempres, v_fvalmov) = 107742 THEN
         -- Obtenemos el siguiente dia habil
         IF pcmovimi <> 10 THEN
            v_fefecto := f_diahabil(0, TRUNC(v_fefecto), NULL);
         END IF;

         v_fvalmov := f_diahabil(0, TRUNC(v_fvalmov), NULL);
      ELSE
         -- Obtenemos el siguiente dia habil o la misma fecha si ya es habil!
         -- (Esto se debe hacer ya que si el fondo no se abre por defecto se considera
         -- abierto y se colarian rescates en dias no habiles!)
         IF pcmovimi <> 10 THEN
            v_fefecto := f_diahabil(13, TRUNC(v_fefecto), NULL);
         END IF;

         v_fvalmov := f_diahabil(13, TRUNC(v_fvalmov), NULL);
      END IF;

      -- esta función parte del supuesto que previamente ya existe el movimiento
      -- general creado
      SELECT MAX(nnumlin) + 1
        INTO xnnumlin
        FROM ctaseguro
       WHERE sseguro = psseguro;

      FOR valor IN cur_segdisin2_act(psseguro) LOOP
         vacumpercent := vacumpercent + (pisinret * valor.pdistrec) / 100;
         xidistrib := ROUND(vacumpercent - vacumrounded, 2);
         vacumrounded := vacumrounded + ROUND(vacumpercent - vacumrounded, 2);

         BEGIN
            SELECT iuniact
              INTO viuniact
              FROM tabvalces
             WHERE ccesta = valor.ccesta
               AND TRUNC(fvalor) = v_fvalmov;

            BEGIN
               INSERT INTO ctaseguro
                           (sseguro, fcontab, nnumlin, ffecmov, fvalmov,
                            cmovimi, imovimi, imovim2, nrecibo, ccalint, cmovanu, nsinies,
                            smovrec, cesta, nunidad, cestado, fasign,
                            srecren)
                    VALUES (psseguro, v_fcontab, xnnumlin, v_fefecto, TRUNC(v_fvalmov),
                            pcmovimi_detalle, xidistrib, NULL, NULL, pccalint, 0, NULL,
                            NULL, valor.ccesta, xidistrib / viuniact, '2', TRUNC(v_fvalmov),
                            psrecren);

               -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
               IF v_cmultimon = 1 THEN
                  num_err := pac_oper_monedas.f_update_ctaseguro_monpol(psseguro, v_fcontab,
                                                                        xnnumlin,
                                                                        TRUNC(v_fvalmov));

                  IF num_err <> 0 THEN
                     RETURN num_err;
                  END IF;
               END IF;
            -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  RETURN 104879;   -- Registre duplicat a CTASEGURO
               WHEN OTHERS THEN
                  RETURN 102555;   -- Error al insertar a la taula CTASEGURO
            END;

            -- Para la impresión de libreta (para que los movimientos generales también tenga actualizada
            -- la fecha de asignación. Actualizamos el movimiento general anterior
            UPDATE ctaseguro
               SET cestado = '2',
                   fasign = TRUNC(f_sysdate),
                   ffecmov = v_fefecto,
                   fvalmov = v_fvalmov
             WHERE sseguro = psseguro
               AND cmovimi = pcmovimi
               AND ccalint = pccalint
               AND nnumlin < xnnumlin;

            -- BUG 18423 - 29/12/2011 - JMP - Multimoneda
            IF v_cmultimon = 1 THEN
               FOR reg IN (SELECT sseguro, fcontab, nnumlin, fvalmov
                             FROM ctaseguro
                            WHERE sseguro = psseguro
                              AND cmovimi = pcmovimi
                              AND ccalint = pccalint
                              AND nnumlin < xnnumlin) LOOP
                  num_err := pac_oper_monedas.f_update_ctaseguro_monpol(reg.sseguro,
                                                                        reg.fcontab,
                                                                        reg.nnumlin,
                                                                        reg.fvalmov);

                  IF num_err <> 0 THEN
                     RETURN num_err;
                  END IF;
               END LOOP;
            END IF;

            -- FIN BUG 18423 - 29/12/2011 - JMP - Multimoneda
            -- Incrementamos numero de linea (por movimiento 58)
            xnnumlin := xnnumlin + 1;

            -- Aumentamos/Descontamos las participaciones asignadas al fondo en contratos
            UPDATE fondos
               SET fondos.nparasi = NVL(fondos.nparasi, 0) +(xidistrib / viuniact)
             WHERE fondos.ccodfon = valor.ccesta;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               --Inserta registres a cuenta seguro.
               BEGIN
                  INSERT INTO ctaseguro
                              (sseguro, fcontab, nnumlin, ffecmov, fvalmov,
                               cmovimi, imovimi, imovim2, nrecibo, ccalint, cmovanu, nsinies,
                               smovrec, cesta, cestado, srecren)
                       VALUES (psseguro, v_fcontab, xnnumlin, v_fefecto, TRUNC(v_fvalmov),
                               pcmovimi_detalle, xidistrib, NULL, NULL, pccalint, 0, NULL,
                               NULL, valor.ccesta, '1', psrecren);

                  -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                  IF v_cmultimon = 1 THEN
                     num_err := pac_oper_monedas.f_update_ctaseguro_monpol(psseguro,
                                                                           v_fcontab,
                                                                           xnnumlin,
                                                                           TRUNC(v_fvalmov));

                     IF num_err <> 0 THEN
                        RETURN num_err;
                     END IF;
                  END IF;

                  -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
                  xnnumlin := xnnumlin + 1;
               EXCEPTION
                  WHEN DUP_VAL_ON_INDEX THEN
                     RETURN 104879;   -- Registre duplicat a CTASEGURO
                  WHEN OTHERS THEN
                     RETURN 102555;   -- Error al insertar a la taula CTASEGURO
               END;

               -- Para la impresión de libreta (para que los movimientos generales también tenga actualizada
               -- la fecha de asignación. Actualizamos el movimiento general anterior
               UPDATE ctaseguro
                  SET ffecmov = v_fefecto,
                      fvalmov = v_fvalmov
                WHERE sseguro = psseguro
                  AND cmovimi = pcmovimi
                  AND ccalint = pccalint
                  AND nnumlin < xnnumlin;

               -- BUG 18423 - 29/12/2011 - JMP - Multimoneda
               IF v_cmultimon = 1 THEN
                  FOR reg IN (SELECT sseguro, fcontab, nnumlin, fvalmov
                                FROM ctaseguro
                               WHERE sseguro = psseguro
                                 AND cmovimi = pcmovimi
                                 AND ccalint = pccalint
                                 AND nnumlin < xnnumlin) LOOP
                     num_err := pac_oper_monedas.f_update_ctaseguro_monpol(reg.sseguro,
                                                                           reg.fcontab,
                                                                           reg.nnumlin,
                                                                           reg.fvalmov);

                     IF num_err <> 0 THEN
                        RETURN num_err;
                     END IF;
                  END LOOP;
               END IF;
         -- FIN BUG 18423 - 29/12/2011 - JMP - Multimoneda
         END;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pk_rentas.f_distribuir_inversion', 1, 'WHEN OTHERS',
                     SQLERRM);
         RETURN -1;
   END f_distribuir_inversion;

   FUNCTION f_distribuir_inversion_shw(
      pcempres IN NUMBER,
      psseguro IN NUMBER,
      pnnumlin IN NUMBER,
      pccalint IN NUMBER,
      psrecren IN NUMBER,
      pisinret IN NUMBER,
      pcmovimi IN NUMBER,
      pcmovimi_detalle IN NUMBER)
      RETURN NUMBER IS
      -- Bug 17247 - RSC - 11/03/2011 - ENSA103 - Instalar els web-services als entorns CSI
      vacumpercent   NUMBER := 0;
      xidistrib      NUMBER;
      vacumrounded   NUMBER := 0;
      viuniact       tabvalces.iuniact%TYPE;
      v_fcontab      ctaseguro_shadow.fcontab%TYPE;
      v_fefecto      ctaseguro_shadow.ffecmov%TYPE;
      v_fvalmov      ctaseguro_shadow.fvalmov%TYPE;
      v_seqgrupo     NUMBER;
      vfdiahabil     DATE;
      xnnumlin       ctaseguro_shadow.nnumlin%TYPE;
      num_err        axis_literales.slitera%TYPE;
      v_cempres      seguros.cempres%TYPE;
      v_cmultimon    parempresas.nvalpar%TYPE;

      CURSOR cur_segdisin2_act(seguro NUMBER) IS
         SELECT sseguro, ccesta, pdistrec, pdistuni, pdistext
           FROM segdisin2
          WHERE sseguro = seguro
            AND nmovimi = (SELECT MAX(nmovimi)
                             FROM segdisin2
                            WHERE sseguro = seguro
                              AND ffin IS NULL)
            AND ffin IS NULL;
   -- Fin Bug 17247
   BEGIN
      SELECT cempres
        INTO v_cempres
        FROM seguros
       WHERE sseguro = psseguro;

      v_cmultimon := NVL(pac_parametros.f_parempresa_n(v_cempres, 'MULTIMONEDA'), 0);   -- BUG 18423 - 29/12/2011 - JMP - Multimoneda

      SELECT fcontab, ffecmov, fvalmov
        INTO v_fcontab, v_fefecto, v_fvalmov
        FROM ctaseguro_shadow
       WHERE sseguro = psseguro
         AND nnumlin = NVL(pnnumlin + 1, 1);

      -- Bug 17247 - RSC - 11/03/2011
      IF pcmovimi = 10 THEN
         v_fefecto := TRUNC(f_sysdate);   -- Las anulaciones de prestación realizadas deben tener fecha efecto f_sysdate.
                                          -- aunque tengan una fvalor anterior. De esta manera las podremos controlar
                                          -- en entradas/salidas.
      END IF;

      -- Fin Bug 17247

      -- Comprobamos si los fondos están cerrados en el
      -- momento de la generación del pago de renta.
      IF pcmovimi <> 10 THEN
         -- Bug 20309 - RSC - 20/12/2011 - LCOL_T004-Parametrización Fondos
         --IF TO_NUMBER(TO_CHAR(v_fefecto, 'd')) IN(6, 7) THEN
         IF NVL(pac_parametros.f_parempresa_n(pcempres, 'HABIL_FIN_SEMANA'), 0) = 0 THEN
            IF TRIM(TO_CHAR(v_fefecto, 'DAY', ' NLS_DATE_LANGUAGE=''AMERICAN'' ')) IN
                                                                        ('SATURDAY', 'SUNDAY') THEN
               v_fefecto := f_diahabil(0, TRUNC(v_fefecto), NULL);
            END IF;
         END IF;
      END IF;

      -- Bug 20309 - RSC - 20/12/2011 - LCOL_T004-Parametrización Fondos
      --IF TO_NUMBER(TO_CHAR(v_fvalmov, 'd')) IN(6, 7) THEN
      IF NVL(pac_parametros.f_parempresa_n(pcempres, 'HABIL_FIN_SEMANA'), 0) = 0 THEN
         IF TRIM(TO_CHAR(v_fvalmov, 'DAY', ' NLS_DATE_LANGUAGE=''AMERICAN'' ')) IN
                                                                        ('SATURDAY', 'SUNDAY') THEN
            v_fvalmov := f_diahabil(0, TRUNC(v_fvalmov), NULL);
         END IF;
      END IF;

      -- Verificació de fons tancats / oberts
      IF pac_mantenimiento_fondos_finv.f_get_estado_fondo(pcempres, v_fvalmov) = 107742 THEN
         -- Obtenemos el siguiente dia habil
         IF pcmovimi <> 10 THEN
            v_fefecto := f_diahabil(0, TRUNC(v_fefecto), NULL);
         END IF;

         v_fvalmov := f_diahabil(0, TRUNC(v_fvalmov), NULL);
      ELSE
         -- Obtenemos el siguiente dia habil o la misma fecha si ya es habil!
         -- (Esto se debe hacer ya que si el fondo no se abre por defecto se considera
         -- abierto y se colarian rescates en dias no habiles!)
         IF pcmovimi <> 10 THEN
            v_fefecto := f_diahabil(13, TRUNC(v_fefecto), NULL);
         END IF;

         v_fvalmov := f_diahabil(13, TRUNC(v_fvalmov), NULL);
      END IF;

      -- esta función parte del supuesto que previamente ya existe el movimiento
      -- general creado
      SELECT MAX(nnumlin) + 1
        INTO xnnumlin
        FROM ctaseguro_shadow
       WHERE sseguro = psseguro;

      FOR valor IN cur_segdisin2_act(psseguro) LOOP
         vacumpercent := vacumpercent + (pisinret * valor.pdistrec) / 100;
         xidistrib := ROUND(vacumpercent - vacumrounded, 2);
         vacumrounded := vacumrounded + ROUND(vacumpercent - vacumrounded, 2);

         BEGIN
            SELECT iuniactvtashw
              INTO viuniact
              FROM tabvalces
             WHERE ccesta = valor.ccesta
               AND TRUNC(fvalor) = v_fvalmov;

            BEGIN
               INSERT INTO ctaseguro_shadow
                           (sseguro, fcontab, nnumlin, ffecmov, fvalmov,
                            cmovimi, imovimi, imovim2, nrecibo, ccalint, cmovanu, nsinies,
                            smovrec, cesta, nunidad, cestado, fasign,
                            srecren)
                    VALUES (psseguro, v_fcontab, xnnumlin, v_fefecto, TRUNC(v_fvalmov),
                            pcmovimi_detalle, xidistrib, NULL, NULL, pccalint, 0, NULL,
                            NULL, valor.ccesta, xidistrib / viuniact, '2', TRUNC(v_fvalmov),
                            psrecren);

               -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
               IF v_cmultimon = 1 THEN
                  num_err := pac_oper_monedas.f_update_ctaseguro_shw_monpol(psseguro,
                                                                            v_fcontab,
                                                                            xnnumlin,
                                                                            TRUNC(v_fvalmov));

                  IF num_err <> 0 THEN
                     RETURN num_err;
                  END IF;
               END IF;
            -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  RETURN 104879;   -- Registre duplicat a CTASEGURO
               WHEN OTHERS THEN
                  RETURN 102555;   -- Error al insertar a la taula CTASEGURO
            END;

            -- Para la impresión de libreta (para que los movimientos generales también tenga actualizada
            -- la fecha de asignación. Actualizamos el movimiento general anterior
            UPDATE ctaseguro_shadow
               SET cestado = '2',
                   fasign = TRUNC(f_sysdate),
                   ffecmov = v_fefecto,
                   fvalmov = v_fvalmov
             WHERE sseguro = psseguro
               AND cmovimi = pcmovimi
               AND ccalint = pccalint
               AND nnumlin < xnnumlin;

            -- BUG 18423 - 29/12/2011 - JMP - Multimoneda
            IF v_cmultimon = 1 THEN
               FOR reg IN (SELECT sseguro, fcontab, nnumlin, fvalmov
                             FROM ctaseguro_shadow
                            WHERE sseguro = psseguro
                              AND cmovimi = pcmovimi
                              AND ccalint = pccalint
                              AND nnumlin < xnnumlin) LOOP
                  num_err := pac_oper_monedas.f_update_ctaseguro_shw_monpol(reg.sseguro,
                                                                            reg.fcontab,
                                                                            reg.nnumlin,
                                                                            reg.fvalmov);

                  IF num_err <> 0 THEN
                     RETURN num_err;
                  END IF;
               END LOOP;
            END IF;

            -- FIN BUG 18423 - 29/12/2011 - JMP - Multimoneda
            -- Incrementamos numero de linea (por movimiento 58)
            xnnumlin := xnnumlin + 1;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               --Inserta registres a cuenta seguro.
               BEGIN
                  INSERT INTO ctaseguro_shadow
                              (sseguro, fcontab, nnumlin, ffecmov, fvalmov,
                               cmovimi, imovimi, imovim2, nrecibo, ccalint, cmovanu, nsinies,
                               smovrec, cesta, cestado, srecren)
                       VALUES (psseguro, v_fcontab, xnnumlin, v_fefecto, TRUNC(v_fvalmov),
                               pcmovimi_detalle, xidistrib, NULL, NULL, pccalint, 0, NULL,
                               NULL, valor.ccesta, '1', psrecren);

                  -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                  IF v_cmultimon = 1 THEN
                     num_err :=
                        pac_oper_monedas.f_update_ctaseguro_shw_monpol(psseguro, v_fcontab,
                                                                       xnnumlin,
                                                                       TRUNC(v_fvalmov));

                     IF num_err <> 0 THEN
                        RETURN num_err;
                     END IF;
                  END IF;

                  -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
                  xnnumlin := xnnumlin + 1;
               EXCEPTION
                  WHEN DUP_VAL_ON_INDEX THEN
                     RETURN 104879;   -- Registre duplicat a CTASEGURO
                  WHEN OTHERS THEN
                     RETURN 102555;   -- Error al insertar a la taula CTASEGURO
               END;

               -- Para la impresión de libreta (para que los movimientos generales también tenga actualizada
               -- la fecha de asignación. Actualizamos el movimiento general anterior
               UPDATE ctaseguro_shadow
                  SET ffecmov = v_fefecto,
                      fvalmov = v_fvalmov
                WHERE sseguro = psseguro
                  AND cmovimi = pcmovimi
                  AND ccalint = pccalint
                  AND nnumlin < xnnumlin;

               -- BUG 18423 - 29/12/2011 - JMP - Multimoneda
               IF v_cmultimon = 1 THEN
                  FOR reg IN (SELECT sseguro, fcontab, nnumlin, fvalmov
                                FROM ctaseguro_shadow
                               WHERE sseguro = psseguro
                                 AND cmovimi = pcmovimi
                                 AND ccalint = pccalint
                                 AND nnumlin < xnnumlin) LOOP
                     num_err := pac_oper_monedas.f_update_ctaseguro_shw_monpol(reg.sseguro,
                                                                               reg.fcontab,
                                                                               reg.nnumlin,
                                                                               reg.fvalmov);

                     IF num_err <> 0 THEN
                        RETURN num_err;
                     END IF;
                  END LOOP;
               END IF;
         -- FIN BUG 18423 - 29/12/2011 - JMP - Multimoneda
         END;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pk_rentas.f_distribuir_inversion_shw', 1,
                     'WHEN OTHERS', SQLERRM);
         RETURN -1;
   END f_distribuir_inversion_shw;

-- ****************************************************************
-- Cambia el estado de un recibo ya existente
-- ****************************************************************
   FUNCTION cambia_estado_recibo(
      psrecren IN NUMBER,   -- Clave del Recibo
      pfmovini IN DATE,   -- Fecha del nuevo movimiento
      pcestrec IN NUMBER)   -- Nuevo Estado
      RETURN NUMBER IS
      sihay          NUMBER;
      xcestrec       NUMBER;
      xsmovpag       NUMBER;
      xfmovini       DATE;
      vsseguro       NUMBER;
      visinret       NUMBER;
      xnnumlin       NUMBER;
      xnnumlinshw    NUMBER;
      vffecpag       DATE;
      num_err        NUMBER;
      xcodsigui      NUMBER;
      --xcestrec       NUMBER;
      pnsinies       sin_siniestro.nsinies%TYPE;
      vtipopago      NUMBER;
      vemitido       NUMBER;
      vsinterf       NUMBER;
      vempresa       seguros.cempres%TYPE;
      verror         NUMBER;
      vterminal      VARCHAR2(200);
      perror         VARCHAR2(2000);
      -- Bug 17247 - RSC - 11/03/2011 - ENSA103 - Instalar els web-services als entorns CSI
      v_seqgrupo     ctaseguro.ccalint%TYPE;
      v_sproduc      seguros.sproduc%TYPE;
      -- Fin bug 17247
      n_mov6         NUMBER(1);   -- existe movimiento 6-remesado -- Bug 0013477 - JMF - 29/03/2011
   BEGIN
      sihay := 0;

      -- Bug 0013477 - JMF - 29/03/2011
      -- Bug 17247 - RSC - 11/03/2011 - ENSA103 - Instalar els web-services als entorns CSI
      BEGIN
         SELECT m.fmovini, m.cestrec, m.smovpag, p.sseguro, p.isinret, p.ffecpag, sproduc,
                cempres
           INTO xfmovini, xcestrec, xsmovpag, vsseguro, visinret, vffecpag, v_sproduc,
                vempresa
           FROM movpagren m, pagosrenta p, seguros s
          WHERE p.srecren = psrecren
            AND m.fmovfin IS NULL
            AND m.srecren = p.srecren
            AND s.sseguro = p.sseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 111282;
         WHEN OTHERS THEN
            RETURN 111282;
      END;

      IF pcestrec = xcestrec
         AND TRUNC(pfmovini) = TRUNC(xfmovini) THEN
         -- Si no hay cambios, no hacemos el cambio de estado.
         RETURN 0;
      END IF;

      -- Fin Bug 17247

      -- Valido Estados
      IF xcestrec IN(0, 6) THEN   -- Es pendiente
         -- Miro si el nuevo estado es compatible
         IF pcestrec IN(0, 6) THEN
            RETURN 0;
         ELSIF pcestrec = 1 THEN
            NULL;   -- JRH 08/2008 A pagado se deja
         ELSIF pcestrec = 5 THEN
            NULL;   -- JRH 08/2008 A bloqueado  se deja
         ELSIF pcestrec = 2 THEN
            NULL;   -- JRH 08/2008 A anulado  se deja
         ELSE
            RETURN 101915;   -- Estado no permitido
         END IF;   -- Pendiente
      ELSIF xcestrec = 1 THEN   -- Esta pagado
         -- Miro si el nuevo estado es compatible
              -- RSC 11/08/2008 Se suaviza el cambio de estado de los pagos de renta. Desde
              -- Departamento se encargarán de forma manual de gestionar la recuperación del
              -- importe de las rentas pagadas. En SIS deberán retroceder el pago de la renta
              -- y después anularla. Para retroceder en SIS debemos permitir pasar de pagado
              -- a pendiente o pendiente y bloqueado.
         IF pcestrec = 1 THEN
            RETURN 0;   -- Pagado
         ELSIF pcestrec = 0 THEN
            NULL;   -- JRH 08/2008Se permite anular el pago
         ELSE
            RETURN 101915;   -- Estado no permitido
         END IF;
      ELSIF xcestrec = 2 THEN   -- Esta anulado
         -- Miro si el nuevo estado es compatible
         IF pcestrec = 1 THEN
            RETURN 101915;   -- Pagado
         ELSIF pcestrec IN(0, 6) THEN
            NULL;   -- Se permite pasar a pendiente
         ELSIF pcestrec = 2 THEN
            RETURN 0;   -- Anulado
         ELSE
            RETURN 101915;   -- Estado no permitido
         END IF;
      ELSIF xcestrec = 5 THEN   -- Esta pendiente y bloqueado
         -- Miro si el nuevo estado es compatible
         IF pcestrec = 1 THEN
            RETURN 101915;   -- Pagado
         ELSIF pcestrec IN(0, 6, 2) THEN
            NULL;   -- a pendiente s epuede
         ELSE
            RETURN 101915;   -- Estado no permitido
         END IF;
      ELSE
         RETURN 110300;
      END IF;

      --
      IF pfmovini < TRUNC(xfmovini) THEN
         RETURN 102430;
      END IF;   -- Fecha ult.mvto.> fecha movim.

      -- Actualizo Fecha fin del último movimiento.
      BEGIN
         UPDATE movpagren
            SET fmovfin = pfmovini
          WHERE srecren = psrecren
            AND fmovfin IS NULL;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 111282;
      END;

      -- Inserto nuevo movimiento
      BEGIN
         INSERT INTO movpagren
                     (srecren, smovpag, cestrec, fmovini, fmovfin, fefecto)
              VALUES (psrecren, xsmovpag + 1, pcestrec, pfmovini, NULL, f_sysdate);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            RETURN 109846;
         WHEN OTHERS THEN
            RETURN 109846;
      END;

      --JRH 08/2008
      --De momento sólo insertamos un movimiento contrario en CTASEGURO en el caso de pagado a pdte. de pago.
      --En los demás casos no hace falta generar CTASEGURO, pq sólo permitimos ANULAR recibos pdtes.
      IF xcestrec = 1
         AND pcestrec = 0 THEN
         --
         SELECT MAX(nnumlin)
           INTO xnnumlin
           FROM ctaseguro
          WHERE sseguro = vsseguro;

         IF pac_ctaseguro.f_tiene_ctashadow(vsseguro, NULL) = 1 THEN
            SELECT MAX(nnumlin)
              INTO xnnumlinshw
              FROM ctaseguro_shadow
             WHERE sseguro = vsseguro;
         END IF;

         -- Bug 17247 - RSC - 11/03/2011 - ENSA103 - Instalar els web-services als entorns CSI
         IF NVL(f_parproductos_v(v_sproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1 THEN
            SELECT scagrcta.NEXTVAL
              INTO v_seqgrupo
              FROM DUAL;
         ELSE
            v_seqgrupo := 0;
         END IF;

         -- Buscamos la fecha valor del pago de renta que anulamos.
         -- Esto aplica tanto a indexado como no!
         BEGIN
            SELECT c1.fvalmov
              INTO vffecpag
              FROM ctaseguro c1
             WHERE c1.sseguro = vsseguro
               AND c1.cmovimi = 53
               AND c1.srecren = psrecren
               AND c1.nnumlin = (SELECT MAX(nnumlin)
                                   FROM ctaseguro c2
                                  WHERE c2.sseguro = c1.sseguro
                                    AND c2.cmovimi = c1.cmovimi
                                    AND c2.srecren = c1.srecren);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN   -- Por que noe stá pagado
               vffecpag := f_sysdate;
         END;

         -- Fin Bug 17247
         num_err :=
            pk_transferencias.insertar_ctaseguro
               (vsseguro, f_sysdate, NVL(xnnumlin + 1, 1), f_sysdate, vffecpag,   --fecha de valor F_Sysdate,
                10,   --JRH Anulación de prestación
                visinret, NULL, NULL,   --En lugar del recibo
                v_seqgrupo,   -- Bug 17247 - RSC - 11/03/2011 - ENSA103 - Instalar els web-services als entorns CSI
                0, NULL, NULL, NULL,
                --vienen de fmovcta
                f_sysdate, f_sysdate, psrecren);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;

         IF pac_ctaseguro.f_tiene_ctashadow(vsseguro, NULL) = 1 THEN
            num_err :=
               pk_transferencias.insertar_ctaseguro_shw
                  (vsseguro, f_sysdate, NVL(xnnumlinshw + 1, 1), f_sysdate, vffecpag,   --fecha de valor F_Sysdate,
                   10,   --JRH Anulación de prestación
                   visinret, NULL, NULL,   --En lugar del recibo
                   v_seqgrupo,   -- Bug 17247 - RSC - 11/03/2011 - ENSA103 - Instalar els web-services als entorns CSI
                   0, NULL, NULL, NULL,
                   --vienen de fmovcta
                   f_sysdate, f_sysdate, psrecren);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;
         END IF;

         -- Bug 17247 - RSC - 11/03/2011 - ENSA103 - Instalar els web-services als entorns CSI
         IF NVL(f_parproductos_v(v_sproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1 THEN
            num_err := f_distribuir_inversion(vempresa, vsseguro, xnnumlin, v_seqgrupo,
                                              psrecren, visinret, 10, 90);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;

            IF pac_ctaseguro.f_tiene_ctashadow(vsseguro, NULL) = 1 THEN
               num_err := f_distribuir_inversion_shw(vempresa, vsseguro, xnnumlinshw,
                                                     v_seqgrupo, psrecren, visinret, 10, 90);

               IF num_err <> 0 THEN
                  RETURN num_err;
               END IF;
            END IF;
         END IF;

         -- Fin Bug 17247
         UPDATE pagosrenta
            SET nremesa = NULL,
                fremesa = NULL
          WHERE srecren = psrecren;   -- Se deja sin número de remesa
      ELSIF xcestrec IN(0, 6)
            AND pcestrec = 1 THEN   --Si lo dejamos para pagar
         UPDATE pagosrenta   --Lo dejamos preparado para remesar
            SET ffecanu = NULL,
                cmotanu = NULL,
                nremesa = NULL,
                fremesa = NULL
          WHERE srecren = psrecren;
      ELSIF xcestrec = 2
            AND pcestrec IN(0) THEN
         UPDATE pagosrenta   --Lo dejamos preparado para remesar
            SET ffecanu = NULL,
                cmotanu = NULL
          WHERE srecren = psrecren;
      ELSIF xcestrec IN(0, 6)
            AND pcestrec = 2 THEN
         UPDATE pagosrenta   --Lo anulamos. Lo dicho, el movimiento contrario ya se ha generado al pasar a pdte. el recibo si estaba pagado antes.
            SET ffecanu = f_sysdate,
                cmotanu = 1
          WHERE srecren = psrecren;
      END IF;

      -- ini Bug 0013477 - JMF - 29/03/2011
      IF NVL(pac_parametros.f_parempresa_n(vempresa, 'GESTIONA_COBPAG'), 0) = 1 THEN
         SELECT NVL(MAX(1), 0)
           INTO n_mov6
           FROM movpagren
          WHERE srecren = psrecren
            AND cestrec = 6;
      END IF;

      -- fin Bug 0013477 - JMF - 29/03/2011
      IF NVL(pac_parametros.f_parempresa_n(vempresa, 'GESTIONA_COBPAG'), 0) = 1
         AND(pcestrec = 2   --Anulaciones
             OR(pcestrec = 0
                AND xcestrec = 5
                AND n_mov6 = 0)   -- de bloqueo a pendiente no remesado anteriormente
                               ) THEN
         BEGIN
            SELECT nsinies
              INTO pnsinies
              FROM prestaren
             WHERE sseguro = vsseguro
               AND ROWNUM = 1;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               pnsinies := NULL;
            WHEN OTHERS THEN
               pnsinies := NULL;
         END;

         IF pnsinies IS NOT NULL THEN
            vtipopago := 2;   --Prestación
         ELSE
            vtipopago := 3;   --Renta
         END IF;

         verror := pac_user.f_get_terminal(pac_md_common.f_get_cxtusuario, vterminal);
         verror := pac_con.f_emision_pagorec(vempresa, 1, vtipopago, psrecren,(xsmovpag + 1),
                                             vterminal, vemitido, vsinterf, perror, f_user);

         IF verror <> 0
            OR TRIM(perror) IS NOT NULL THEN   --JRH IMP ?
            --Mira si borraar pagorentas y movpagren porque se tiene que hacer un commit para que loo vea el sap
            IF verror = 0 THEN
               verror := 151323;
            END IF;

            p_tab_error(f_sysdate, f_user, 'pk_rentas.f_movpago', 1, 'error no controlado',
                        perror || ' ' || verror);
            RETURN verror;
         END IF;
      END IF;

      -- Fi BUG 17247-  02/2011 - JRH
      RETURN 0;
   END cambia_estado_recibo;

-- ****************************************************************
--insertar_mensajes
-- Graba recibos y movimientos
--      param in pseguro : -- Clave del Seguro
--      param in psperson :   -- Clave Persona
--      param in pnorden:   -- Nro Orden
--      param in ppretren :  -- % de Retención
--      param in pfppren : -- Fecha efecto
--      param in piretren :   -- Importe de Retención
--      param in pibasren :  -- Importe Base
--      param in piconren :   -- Importe con Retención (NETO)
--      param in pisinren :   -- Importe sin Retención (BRUTO)
--      param in pcbancar :   -- CCC donde se ingresa el pago
--      param in pctipo :  -- 1-Ins.Temporal 3-Mensajes
--      psproces IN NUMBER : Proceso
--      param in pctipban : Tipban
-- retorna 0 o <> 0 si hay error
-- ****************************************************************
   FUNCTION insertar_mensajes(
      pseguro IN NUMBER,   -- Clave del Seguro
      psperson IN NUMBER,   -- Clave Persona
      pnorden IN NUMBER,   -- Nro Orden
      ppretren IN NUMBER,   -- % de Retención
      pfppren IN NUMBER,   -- Fecha efecto
      piretren IN NUMBER,   -- Importe de Retención
      pibasren IN NUMBER,   -- Importe Base
      piconren IN NUMBER,   -- Importe con Retención (NETO)
      pisinren IN NUMBER,   -- Importe sin Retención (BRUTO)
      pcbancar IN VARCHAR2,   -- CCC donde se ingresa el pago
      pctipo IN NUMBER,   -- 1-Ins.Temporal 3-Mensajes
      psproces IN NUMBER,
      pctipban IN NUMBER,
      pnsinies IN VARCHAR2 DEFAULT NULL,
      pntramit IN NUMBER DEFAULT NULL,
      pctipdes IN NUMBER DEFAULT NULL,   -- Proceso
      pnpresta IN NUMBER DEFAULT 1)
      RETURN NUMBER IS
      fppren         DATE;
      -- JLB - 18/06/2013 - ENSA
      vstmppare      tmp_pagosrenta.stmppare%TYPE;
      n_err          NUMBER;
   BEGIN
      IF pctipo = 1 THEN
         BEGIN
            fppren := TO_DATE(pfppren, 'YYYYMMDD');

            -- JLB - I -  18/06/2013 - ENSA
            SELECT stmppagren.NEXTVAL
              INTO vstmppare
              FROM DUAL;

            -- JLB - F -  18/06/2013 - ENSA
              -- Bug 0013477 - JMF - 29/03/2011: Afegir ctipban
              -- Bug 18286 - APD - 26/04/2011 - Se añaden los campos nsinies, ntramit, ctipdes
            INSERT INTO tmp_pagosrenta
                        (stmppare, sseguro, sperson, ffecpag, isinret, pretenc, iretenc,
                         iconret, ibase, nctacor, sproces, ctipban, nsinies, ntramit,
                         ctipdes, npresta)
                 VALUES (vstmppare,   --gstmppagren,    -- JLB - 18/06/2013 - ENSA
                                   pseguro, psperson, fppren, pisinren, ppretren, piretren,
                         piconren, pibasren, pcbancar, psproces, pctipban, pnsinies, pntramit,
                         pctipdes, pnpresta);

            IF NVL
                  (pac_parametros.f_parempresa_n
                      (pac_contexto.f_contextovalorparametro
                                                           (f_parinstalacion_t('CONTEXT_USER'),
                                                            'IAX_EMPRESA'),
                       'MULTIMONEDA'),
                   0) = 1 THEN
               n_err := pac_oper_monedas.f_contravalores_tmp_pagosrenta(vstmppare, pseguro,
                                                                        psperson, fppren);
            END IF;

            COMMIT;
            RETURN 0;
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               RETURN 109844;
            WHEN OTHERS THEN
               RETURN 109844;
         END;
      ELSE
         gnvalor := gnvalor + 1;
         valores(gnvalor).ssegu := pseguro;
         valores(gnvalor).perso := psperson;
         valores(gnvalor).asegu := pnorden;
         valores(gnvalor).pretren := ppretren;
         valores(gnvalor).ffecefe := pfppren;
         valores(gnvalor).iretren := piretren;
         valores(gnvalor).ibasren := pibasren;
         valores(gnvalor).iconren := piconren;
         valores(gnvalor).isinren := pisinren;
         RETURN 0;
      END IF;
   END insertar_mensajes;

-- ****************************************************************
--insertar_pagos
-- Graba recibos y movimientos
--      param in pseguro : -- Clave del Seguro
--      param in psperson :   -- Clave Persona
--      param in pnorden:   -- Nro Orden
--      param in ppretren :  -- % de Retención
--      param in pfppren : -- Fecha efecto
--      param in piretren :   -- Importe de Retención
--      param in pibasren :  -- Importe Base
--      param in piconren :   -- Importe con Retención (NETO)
--      param in pisinren :   -- Importe sin Retención (BRUTO)
--      param in pcbancar :   -- CCC donde se ingresa el pago
--      param in pctipo :  -- 1-Ins.Temporal 3-Mensajes
--      psproces IN NUMBER : Proceso
--      param in pctipban : Tipban
--      param out idpago: código del pago
-- retorna 0 o <> 0 si hay error
-- ****************************************************************
   FUNCTION insertar_pagos(
      pseguro IN NUMBER,   -- Clave del Seguro
      psperson IN NUMBER,   -- Clave Persona
      pfppren IN DATE,   -- Fecha Efecto
      pisinren IN NUMBER,   -- Importe sin Retención (BRUTO)
      ppretren IN NUMBER,   -- % de Retención
      piretren IN NUMBER,   -- Importe de Retención
      piconren IN NUMBER,   -- Importe con Retención (NETO)
      pibasren IN NUMBER,   -- Base de Retención
      pcbancar IN VARCHAR2,   -- CCC donde se ingresa el pago
      pestmort IN NUMBER,   -- 0-Esta vivo 1-Esta muerto
      pproceso IN NUMBER DEFAULT NULL,
      idpago OUT NUMBER,
      pctipban IN NUMBER,
      pnsinies IN VARCHAR2 DEFAULT NULL,
      pntramit IN NUMBER DEFAULT NULL,
      pctipdes IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      xcodsigui      NUMBER;
      xcestrec       NUMBER;
      vtipopago      NUMBER;
      vemitido       NUMBER;
      vsinterf       NUMBER;
      vempresa       seguros.cempres%TYPE;
      verror         NUMBER;
      vterminal      VARCHAR2(200);
      perror         VARCHAR2(2000);
   BEGIN
      SELECT ssrecren.NEXTVAL
        INTO xcodsigui
        FROM DUAL;

      -- BUG 17247-  02/2011 - JRH  - 0017247: Envio pagos SAP
      SELECT cempres   --de momento vamos a seguros
        INTO vempresa
        FROM seguros
       WHERE sseguro = pseguro;

      BEGIN
         gnvalor := gnvalor + 1;

         -- Bug 0013477 - JMF - 29/03/2011: Afegir ctipban
         -- Bug 18286 - APD - 26/04/2011 - Se añaden los campos nsinies, ntramit, ctipdes
         INSERT INTO pagosrenta
                     (srecren, sseguro, sperson, ffecefe, ffecpag, ffecanu, cmotanu, isinret,
                      pretenc, iretenc, iconret, ibase, nctacor, nremesa, fremesa, proceso,
                      ctipban, nsinies, ntramit, ctipdes)
              VALUES (xcodsigui, pseguro, psperson, f_sysdate, pfppren, NULL, NULL, pisinren,
                      ppretren, piretren, piconren, pibasren, pcbancar, NULL, NULL, pproceso,
                      pctipban, pnsinies, pntramit, pctipdes);

         IF NVL(pac_parametros.f_parempresa_n(vempresa, 'MULTIMONEDA'), 0) = 1 THEN
            verror := pac_oper_monedas.f_contravalores_pagosrenta(xcodsigui, pseguro);
         END IF;
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            p_tab_error(f_sysdate, f_user, 'pkrentas.insertarpagos', 1,
                        'ptablas = ' || 0 || ' psseguro =' || pseguro || ' pnriesgo =' || 1,
                        'WDI');
            RETURN 109844;
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'pkrentas.insertarpagos', 1,
                        'ptablas = ' || 0 || ' psseguro =' || pseguro || ' pnriesgo =' || 1,
                        SQLERRM);
            RETURN 109844;
      END;

      --
      xcestrec := 0;

      --
      IF pestmort = 1 THEN
         IF gcestmre_pol IS NULL THEN
            xcestrec := gcestmre;
         ELSE
            xcestrec := gcestmre_pol;
         END IF;
      ELSE
         IF gcblopag IS NULL THEN
            xcestrec := 0;
         ELSE
            xcestrec := gcblopag;
         END IF;
      END IF;

      --
      -- IF GCBLOPAG IS NULL THEN
      --   IF PESTMORT = 0 THEN
      --      XCESTREC := 0;
      --   ELSE
      --      IF gcestmre_pol IS NULL THEN
      --         XCESTREC := gcestmre;
      --      ELSE
      --         XCESTREC := gcestmre_pol;
      --      END IF;
      --   END IF;
      -- ELSE
      --   XCESTREC := GCBLOPAG;
      -- END IF;
      --
      BEGIN
         INSERT INTO movpagren
                     (srecren, smovpag, cestrec, fmovini, fmovfin, fefecto)
              VALUES (xcodsigui, 1, xcestrec, pfppren, NULL, f_sysdate);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            p_tab_error(f_sysdate, f_user, 'pkrentas.insertarpagos', 1,
                        'ptablas = ' || 0 || ' psseguro =' || pseguro || ' pnriesgo =' || 1,
                        SQLERRM);
            RETURN 109846;
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'pkrentas.insertarpagos', 1,
                        'ptablas = ' || 0 || ' psseguro =' || pseguro || ' pnriesgo =' || 1,
                        SQLERRM);
            RETURN 109846;
      END;

      IF NVL(pac_parametros.f_parempresa_n(vempresa, 'GESTIONA_COBPAG'), 0) = 1
         AND xcestrec = 0 THEN   --Solo pdte., no los bloqueados
         IF pnsinies IS NOT NULL THEN
            vtipopago := 2;   --Prestación
         ELSE
            vtipopago := 3;   --Renta
         END IF;

         verror := pac_user.f_get_terminal(pac_md_common.f_get_cxtusuario, vterminal);
         verror := pac_con.f_emision_pagorec(vempresa, 1, vtipopago, xcodsigui, 1, vterminal,
                                             vemitido, vsinterf, perror, f_user);

         --DBMS_OUTPUT.put_line('___________verror:' || verror);
         --DBMS_OUTPUT.put_line('___________perror:' || perror);
         IF verror <> 0
            OR TRIM(perror) IS NOT NULL THEN   --JRH IMP ?
            --Mira si borraar pagorentas y movpagren porque se tiene que hacer un commit para que loo vea el sap
            --DBMS_OUTPUT.put_line('________2');
            IF verror = 0 THEN
               verror := 151323;
            END IF;

            p_tab_error(f_sysdate, f_user, 'pk_rentas.f_inserta_pago', 1,
                        'error no controlado', perror || ' ' || verror);
            RETURN verror;
         ELSE
            UPDATE movpagren
               SET fmovfin = pfppren
             WHERE srecren = xcodsigui
               AND smovpag = 1;

            -- DBMS_OUTPUT.put_line('________1');

            -- poner aquí el cambio de estado
            INSERT INTO movpagren
                        (srecren, smovpag, cestrec, fmovini, fmovfin, fefecto)
                 VALUES (xcodsigui, 2, 6, pfppren, NULL, f_sysdate);   -- 6 nuevo estado de emitido : Remesado
         -- DBMS_OUTPUT.put_line('________2');
         END IF;
      END IF;

      -- Fi BUG 17247-  02/2011 - JRH
      idpago := xcodsigui;
      RETURN 0;
   END insertar_pagos;

-- ****************************************************************
-- Graba en la tabla de parametros transitorios parametros calculo
-- ****************************************************************
   FUNCTION graba_param(wnsesion IN NUMBER, wparam IN VARCHAR2, wvalor IN NUMBER)
      RETURN NUMBER IS
   BEGIN
      -- i -- jlb - OPTIMIZACION
      RETURN pac_sgt.put(wnsesion, wparam, wvalor);
      /*
      INSERT INTO sgt_parms_transitorios
                  (sesion, parametro, valor)
           VALUES (wnsesion, wparam, wvalor);

      RETURN 0;
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         UPDATE sgt_parms_transitorios
            SET valor = wvalor
          WHERE sesion = wnsesion
            AND parametro = wparam;

         RETURN 0;
      WHEN OTHERS THEN
         RETURN -9;
     */
   END graba_param;

-- ****************************************************************
-- Borra parametros grabados en la sesion
-- ****************************************************************
   FUNCTION borra_param(wnsesion IN NUMBER)
      RETURN NUMBER IS
   BEGIN
        -- I - JLB - OPTIMI
      --  DELETE FROM sgt_parms_transitorios
      ---        WHERE sesion = wnsesion;
      RETURN pac_sgt.del(wnsesion);
    -- RETURN 0;
   -- F - JLB - OPTIMI
   EXCEPTION
      WHEN OTHERS THEN
         RETURN -9;
   END borra_param;

-- ****************************************************************
--  Devuelve mensaje (modo previo)
-- ****************************************************************
   FUNCTION ver_mensajes(nerr IN NUMBER)
      RETURN VARCHAR2 IS
   BEGIN
      RETURN pk_rentas.valores(nerr).ssegu || ';' || pk_rentas.valores(nerr).perso || ';'
             || pk_rentas.valores(nerr).asegu || ';' || pk_rentas.valores(nerr).ffecefe || ';'
             || pk_rentas.valores(nerr).isinren || ';' || pk_rentas.valores(nerr).ibasren
             || ';' || pk_rentas.valores(nerr).pretren || ';'
             || pk_rentas.valores(nerr).iretren || ';' || pk_rentas.valores(nerr).iconren;
   END ver_mensajes;

-- ****************************************************************
--  Borra mensajes
-- ****************************************************************
   PROCEDURE borra_mensajes IS
   BEGIN
      valores.DELETE;
      gnvalor := 0;
   END borra_mensajes;

-- ****************************************************************
--  Borra tmp_pagosrenta
-- ****************************************************************
   PROCEDURE borra_tmp_pagosrenta IS
   BEGIN
      DELETE FROM tmp_pagosrenta;

      COMMIT;
   END borra_tmp_pagosrenta;

-- ******************************************************************
-- Captura aquellas pólizas que llegan al vto de las aportaciones de
-- primas periódicas y deben empezar a generar recibos de rentas.
-- ******************************************************************
/*FUNCTION vto_aportaciones ( pfefecto IN DATE,
                            pusuario IN VARCHAR2,
                      pcidioma IN NUMBER)
RETURN NUMBER IS
        xf1paren DATE;   -- Fecha Pago 1era. Renta
        xfuparen DATE;   -- Fecha Pago ultima Renta
        xibruren NUMBER; -- Importe Bruto de la Renta
      xprovmat NUMBER; -- Importe Provisión Matematica
      XNNUMLIN NUMBER; -- Numero de linea CtaSeguro
-- Variables grabar procesos
        XNPROC    NUMBER; -- Nro de Proceso
        XNUMLIN   NUMBER; -- Numero de linea
        num_err   NUMBER; -- Valor de retorno procesos
        xnerror   NUMBER; -- Numero de errores del proceso
        xferror   NUMBER; -- Se a producido error en una iteración
        texto     VARCHAR2(200);

CURSOR cur_prod IS
  SELECT cpa1ren, npa1ren, cclaren, nnumren, cramo, cmodali, ctipseg, ccolect, sproduc,
         cduraci
    FROM PRODUCTOS
   WHERE cprprod = 1
     AND ctipren = 0;
BEGIN
num_err := F_Procesini(PUSUARIO,2,'VTOAPORREN',2||' '||'Vto. Aportaciones Rentas'||
                    ' '||pfefecto, xnproc);
IF num_err <> 0 THEN
  xnerror := 1;
  P_Literal2(num_err,pcidioma,texto);
  xnumlin := NULL;
  num_err := F_Proceslin(xnproc,texto,0,xnumlin);
  COMMIT;
  RETURN 1;
ELSE
  COMMIT;
  xnerror := 0;
  xferror :=0;
  FOR prod IN cur_prod
  LOOP
      FOR fec IN (SELECT SP.SSEGURO, SP.F1PAREN, SP.FPPREN, S.FEFECTO, S.CBANCAR
                    FROM  SEGUROS_REN SP, SEGUROS S
                   WHERE SP.F1PAREN <= pfefecto
                 AND SP.FPPREN IS NULL
                   AND SP.SSEGURO = S.SSEGURO
                AND S.CRAMO   = prod.cramo        AND S.CMODALI = prod.cmodali
                 AND S.CTIPSEG = prod.ctipseg    AND S.CCOLECT = prod.ccolect
                AND S.CSITUAC = 0)
      LOOP
-- Calculo según parametrización del producto la fecha 1er. Pago de la Renta.
      IF    prod.cpa1ren = 0 THEN xf1paren := fec.f1paren;
      ELSIF prod.cpa1ren = 1 THEN xf1paren := fec.f1paren + NVL(prod.npa1ren,0);
      ELSIF prod.cpa1ren = 2 THEN xf1paren := ADD_MONTHS(fec.f1paren,NVL(prod.npa1ren,0));
         ELSIF prod.cpa1ren = 3 THEN xf1paren := ADD_MONTHS(fec.f1paren,(NVL(prod.npa1ren,0)*12));
         ELSIF prod.cpa1ren = 4 THEN xf1paren := fec.fefecto + NVL(prod.npa1ren,0);
         ELSIF prod.cpa1ren = 5 THEN xf1paren := ADD_MONTHS(fec.fefecto,NVL(prod.npa1ren,0));
         ELSIF prod.cpa1ren = 6 THEN xf1paren := ADD_MONTHS(fec.fefecto,(NVL(prod.npa1ren,0)*12));
         ELSIF prod.cpa1ren = 7 THEN xf1paren := fec.fefecto;
      END IF;
-- Calculo según parametrización del producto la fecha fin de la Renta = Fecha Vto. Póliza.
      IF    prod.cclaren = 0 THEN xfuparen := NULL; --TO_DATE('31122999','ddmmyyyy');
      ELSIF prod.cclaren = 1 THEN xfuparen := ADD_MONTHS(xf1paren,(NVL(prod.nnumren,0)*12));
      ELSIF prod.cclaren = 2 THEN xfuparen := ADD_MONTHS(xf1paren,NVL(prod.nnumren,0));
      END IF;
-- Calculo del Importe Bruto de la Renta.
       xferror := 0;
       xibruren := Pk_Provmatematicas.f_provmat(1,fec.sseguro,pfefecto,4,0);
      IF XIBRUREN <= 0 OR XIBRUREN IS NULL THEN
          ROLLBACK;
          P_Literal2(107507,pcidioma,texto);
          xnumlin := NULL;
          num_err := F_Proceslin(xnproc,texto,fec.sseguro,xnumlin);
          IF num_err = 0 THEN COMMIT; END IF;
          xferror := 1; xnerror := xnerror + 1;
      END IF;
-- Calculo la Provisión Matematica a día F1PAGO - 1 y la grabo en CTASEGURO.
       IF xferror = 0 THEN
         xprovmat := Pk_Provmatematicas.f_provmat(1,fec.sseguro,(xf1paren - 1),1,0);
        IF xprovmat <= 0 OR xprovmat IS NULL THEN
             ROLLBACK;
             P_Literal2(107507,pcidioma,texto);
             xnumlin := NULL;
             num_err := F_Proceslin(xnproc,texto,fec.sseguro,xnumlin);
             IF num_err = 0 THEN COMMIT; END IF;
             xferror := 1; xnerror := xnerror + 1;
        ELSE
           BEGIN
             SELECT MAX(NNUMLIN)+1 INTO XNNUMLIN FROM CTASEGURO WHERE SSEGURO=fec.sseguro;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN XNNUMLIN := 1;
            WHEN OTHERS        THEN XNNUMLIN := 1;
          END;
--
            BEGIN
               INSERT INTO CTASEGURO (SSEGURO,FCONTAB,NNUMLIN,FFECMOV,FVALMOV,CMOVIMI,
                          IMOVIMI,CCALINT,IMOVIM2,NRECIBO,NSINIES,CMOVANU,SMOVREC,CESTA,
                          NUNIDAD,CESTADO,FASIGN,NPARPLA,CESTPAR,IEXCESO,SPERMIN,SIDEPAG)
                VALUES (fec.sseguro,(xf1paren - 1),XNNUMLIN,(xf1paren - 1),(xf1paren - 1),0,
                       xprovmat,0,NULL,NULL,NULL,0,NULL,0,
                     0,0,NULL,NULL,NULL,NULL,NULL,NULL);
             EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN   NULL;
               WHEN OTHERS           THEN
                 ROLLBACK;
                    P_Literal2(102555,pcidioma,texto);
                    xnumlin := NULL;
                    num_err := F_Proceslin(xnproc,texto,fec.sseguro,xnumlin);
                    IF num_err = 0 THEN COMMIT; END IF;
                    xferror := 1; xnerror := xnerror + 1;
             END;
         END IF;
      END IF;
--
       IF xferror = 0 THEN
        BEGIN
           INSERT INTO SEGUROS_REN(sseguro,f1paren,fuparen,cforpag,ibruren,
                                  fppren,ffinren, cmotivo, cmodali, ibrure2)
                VALUES (fec.sseguro,xf1paren,xfuparen,1,xibruren,xf1paren,
                     NULL,NULL,NULL,NULL);
         EXCEPTION
           WHEN DUP_VAL_ON_INDEX THEN
           BEGIN
              UPDATE SEGUROS_REN SET   f1paren = xf1paren,
                                  fuparen = xfuparen,
                                  ibruren = xibruren,
                                      fppren  = xf1paren
            WHERE sseguro = fec.sseguro;
             EXCEPTION
                WHEN OTHERS THEN
                   ROLLBACK;
                   P_Literal2(102361,pcidioma,texto);
                   xnumlin := NULL;
                   num_err := F_Proceslin(xnproc,texto,fec.sseguro,xnumlin);
                   IF num_err = 0 THEN COMMIT; END IF;
                   xferror := 1; xnerror := xnerror + 1;
             END;
           WHEN OTHERS THEN
            ROLLBACK;
              P_Literal2(109846,pcidioma,texto);
              xnumlin := NULL;
              num_err := F_Proceslin(xnproc,texto,fec.sseguro,xnumlin);
              IF num_err = 0 THEN COMMIT; END IF;
              xferror := 1; xnerror := xnerror + 1;
        END;
-- Actualizo Fecha vencimiento del Seguro.
         IF PROD.CDURACI <> 4 THEN
        BEGIN
             UPDATE SEGUROS SET   fvencim = xfuparen
            WHERE sseguro = fec.sseguro;
         EXCEPTION
           WHEN OTHERS THEN
            ROLLBACK;
              P_Literal2(102361,pcidioma,texto);
              xnumlin := NULL;
              num_err := F_Proceslin(xnproc,texto,fec.sseguro,xnumlin);
              IF num_err = 0 THEN COMMIT; END IF;
              xferror := 1; xnerror := xnerror + 1;
       END;
        END IF;
      END IF;
      IF xferror = 0 THEN
          P_Literal2(110089,pcidioma,texto);
          xnumlin := NULL;
          num_err := F_Proceslin(xnproc,texto,fec.sseguro,xnumlin);
          COMMIT;
          xferror := 1; xnerror := xnerror + 1;
      ELSE
         xferror := 0;
      END IF;
     END LOOP;
  END LOOP;
--
  IF xnerror = 0 THEN
     P_Literal2(102903,pcidioma,texto);
     xnumlin := NULL;
     num_err := F_Proceslin(xnproc,texto,0,xnumlin);
     IF num_err = 0 THEN COMMIT; END IF;
     xnerror := 0;
  END IF;
  num_err := F_Procesfin(xnproc,xnerror);
  COMMIT;
  RETURN 0;
END IF;

END vto_aportaciones;
*/
   FUNCTION vto_aportaciones(pfefecto IN DATE, pusuario IN VARCHAR2, pcidioma IN NUMBER)
      RETURN NUMBER IS
      xnnumlin       NUMBER;   -- Numero de linea CtaSeguro
      -- Variables grabar procesos
      xnproc         NUMBER;   -- Nro de Proceso
      xnumlin        NUMBER;   -- Numero de linea
      xnumlinshw     NUMBER;   -- Numero de linea
      num_err        NUMBER;   -- Valor de retorno procesos
      xnerror        NUMBER;   -- Numero de errores del proceso
      xferror        NUMBER;   -- Se ha producido error en una iteración
      texto          VARCHAR2(200);
      ttexto         VARCHAR2(400);

      CURSOR cur_prod IS
         SELECT cpa1ren, npa1ren, cclaren, nnumren, cramo, cmodali, ctipseg, ccolect, sproduc,
                cduraci
           FROM productos
          WHERE   --cprprod = 1
                --AND ctipren = 0;
                NVL(f_parproductos_v(productos.sproduc, 'PREST_RENTA'), 0) = 1;
   BEGIN
      num_err := f_procesini(pusuario, 2, 'VTOAPORREN',
                             2 || ' ' || 'Vto. Aportaciones Rentas' || ' ' || pfefecto,
                             xnproc);

      IF num_err <> 0 THEN
         xnerror := 1;
         ttexto := f_axis_literales(num_err, pcidioma);
         xnumlin := NULL;
         num_err := f_proceslin(xnproc, texto, 0, xnumlin);
         COMMIT;
         RETURN 1;
      ELSE
         COMMIT;
         xnerror := 0;
         xferror := 0;

         FOR prod IN cur_prod LOOP
            FOR fec IN
               (SELECT s.sseguro, s.fvencim f1paren, NULL fppren, s.fefecto, s.cactivi,
                       s.cforpag, s.sproduc, s.cempres
                  FROM seguros s, seguros_aho a
                 WHERE s.fvencim <= pfefecto
                   AND s.sproduc = prod.sproduc
                   AND s.csituac = 0
                   AND NOT EXISTS(SELECT 1
                                    FROM seguros_ren r
                                   WHERE r.sseguro = s.sseguro)   --JRH Que no esté insertada la renta
                   AND a.sseguro = s.sseguro
                   AND a.cfprest = 1)   -- Prestación de renta
                                     LOOP
               DECLARE
                  xprovmat       NUMBER;
                  xibruren       NUMBER;   -- Importe Bruto de la Renta
                  xibrurenmin    NUMBER;
                  v_ctipgar      NUMBER;
                  v_garant       NUMBER;
                  v_garantmin    NUMBER;
                  xnumlin        NUMBER;   -- Numero de linea
                  xnnumlinshw    NUMBER;   -- Numero de linea
                  nerror         NUMBER;
                  vclave         NUMBER;
                  vtraza         NUMBER;
                  ocoderror      NUMBER;
                  xf1paren       DATE;   -- Fecha Pago 1era. Renta
                  xfuparen       DATE;   -- Fecha Pago ultima Renta
                  pnduraci       NUMBER;
                  pforpagren     NUMBER;
                  pforpag        NUMBER;
                  excep          EXCEPTION;
               BEGIN
                  xprovmat := pac_provmat_formul.f_calcul_formulas_provi(fec.sseguro,
                                                                         (fec.f1paren - 1),
                                                                         'IPROVAC');

                  IF xprovmat <= 0
                     OR xprovmat IS NULL THEN
                     nerror := 107507;
                     RAISE excep;
                  END IF;

                  -- Hacemos un primer insert en seguros_ren
                  INSERT INTO seguros_ren
                              (sseguro, f1paren, fuparen, cforpag, ibruren, icapren)   --JRH IMP
                       VALUES (fec.sseguro, f_sysdate, f_sysdate, 0, 0, xprovmat);

                  vtraza := 1;

                  SELECT ndurper
                    INTO pnduraci
                    FROM seguros_aho
                   WHERE sseguro = fec.sseguro;

                  vtraza := 5;

                  BEGIN
                     SELECT cforpag
                       INTO pforpagren
                       FROM forpagren
                      WHERE sproduc = fec.sproduc;
                  EXCEPTION
                     WHEN OTHERS THEN
                        pforpagren := 12;   --Mensual de momento
                  END;

                  vtraza := 6;
                  v_garant := pac_calc_comu.f_cod_garantia(fec.sproduc, 8, NULL, v_ctipgar);   --Renta

                  IF (v_garant IS NULL) THEN
                     nerror := 180588;
                     RAISE excep;
                  END IF;

                  SELECT clave
                    INTO vclave
                    FROM garanformula
                   WHERE cgarant = v_garant
                     AND ccampo = 'ICAPCAL'
                     AND cramo = prod.cramo
                     AND cmodali = prod.cmodali
                     AND ctipseg = prod.ctipseg
                     AND ccolect = prod.ccolect
                     AND cactivi = fec.cactivi;

                  vtraza := 8;
                  vtraza := 6;
                  nerror := pac_calculo_formulas.calc_formul(fec.f1paren - 1, fec.sproduc,
                                                             fec.cactivi, v_garant, 1,
                                                             fec.sseguro, vclave, xibruren,
                                                             NULL, NULL, 2, fec.fefecto, 'R');

                  IF nerror <> 0 THEN
                     RAISE excep;
                  END IF;

                  IF xibruren <= 0
                     OR xibruren IS NULL THEN
                     nerror := 107507;
                     RAISE excep;
                  END IF;

                  UPDATE garanseg
                     SET icapital = xibruren,
                         icaptot = xibruren
                   WHERE sseguro = fec.sseguro
                     AND cgarant = v_garant;

                  v_garantmin := pac_calc_comu.f_cod_garantia(fec.sproduc, 9, NULL, v_ctipgar);   --Renta mín

                  IF (v_garantmin IS NULL) THEN
                     nerror := 180588;
                     RAISE excep;
                  END IF;

                  SELECT clave
                    INTO vclave
                    FROM garanformula
                   WHERE cgarant = v_garantmin
                     AND ccampo = 'ICAPCAL'
                     AND cramo = prod.cramo
                     AND cmodali = prod.cmodali
                     AND ctipseg = prod.ctipseg
                     AND ccolect = prod.ccolect
                     AND cactivi = fec.cactivi;

                  vtraza := 8;
                  vtraza := 6;
                  nerror := pac_calculo_formulas.calc_formul(fec.f1paren - 1, fec.sproduc,
                                                             fec.cactivi, v_garantmin, 1,
                                                             fec.sseguro, vclave, xibrurenmin,
                                                             NULL, NULL, 2, fec.fefecto, 'R');

                  IF nerror <> 0 THEN
                     RAISE excep;
                  END IF;

                  IF xibrurenmin <= 0
                     OR xibrurenmin IS NULL THEN
                     nerror := 107507;
                     RAISE excep;
                  END IF;

                  UPDATE garanseg
                     SET icapital = xibrurenmin,
                         icaptot = xibrurenmin
                   WHERE sseguro = fec.sseguro
                     AND cgarant = v_garantmin;

                  vtraza := 8;
                  pac_ref_contrata_rentas.f_actualizar_segurosren(fec.sproduc, fec.fefecto,
                                                                  pnduraci, fec.f1paren,
                                                                  fec.cforpag, xprovmat, 0,   --Si % cap fallec
                                                                  NULL, NULL, NULL, 100,
                                                                  pforpagren, fec.sseguro,
                                                                  ocoderror, 'SEG');

                  IF ocoderror <> 0 THEN
                     nerror := ocoderror;
                     RAISE excep;
                  END IF;

                  UPDATE seguros_ren
                     SET ibruren = xibruren,
                         icapren = xprovmat
                   WHERE sseguro = fec.sseguro;

                  vtraza := 9;

                  SELECT fuparen, f1paren
                    INTO xfuparen, xf1paren
                    FROM seguros_ren
                   WHERE sseguro = fec.sseguro;

                  vtraza := 10;

                  BEGIN
                     SELECT MAX(nnumlin) + 1
                       INTO xnnumlin
                       FROM ctaseguro
                      WHERE sseguro = fec.sseguro;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        xnnumlin := 1;
                     WHEN OTHERS THEN
                        xnnumlin := 1;
                  END;

                  IF pac_ctaseguro.f_tiene_ctashadow(fec.sseguro, NULL) = 1 THEN
                     BEGIN
                        SELECT MAX(nnumlin) + 1
                          INTO xnnumlinshw
                          FROM ctaseguro_shadow
                         WHERE sseguro = fec.sseguro;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           xnnumlinshw := 1;
                        WHEN OTHERS THEN
                           xnnumlinshw := 1;
                     END;
                  END IF;

                  --
                  BEGIN
                     INSERT INTO ctaseguro
                                 (sseguro, fcontab, nnumlin, ffecmov,
                                  fvalmov, cmovimi, imovimi, ccalint, imovim2, nrecibo,
                                  nsinies, cmovanu, smovrec, cesta, nunidad, cestado, fasign,
                                  nparpla, cestpar, iexceso, spermin, sidepag)
                          VALUES (fec.sseguro,(xf1paren - 1), xnnumlin,(xf1paren - 1),
                                  (xf1paren - 1), 0, xprovmat, 0, NULL, NULL,
                                  NULL, 0, NULL, 0, 0, 0, NULL,
                                  NULL, NULL, NULL, NULL, NULL);

                     -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                     IF NVL(pac_parametros.f_parempresa_n(fec.cempres, 'MULTIMONEDA'), 0) = 1 THEN
                        nerror := pac_oper_monedas.f_update_ctaseguro_monpol(fec.sseguro,
                                                                             (xf1paren - 1),
                                                                             xnnumlin,
                                                                             (xf1paren - 1));

                        IF nerror <> 0 THEN
                           ROLLBACK;
                           ttexto := f_axis_literales(nerror, pcidioma);
                           xnumlin := NULL;
                           num_err := f_proceslin(xnproc, texto, fec.sseguro, xnumlin);

                           IF num_err = 0 THEN
                              COMMIT;
                           END IF;

                           xferror := 1;
                           xnerror := xnerror + 1;
                        END IF;
                     END IF;

                     IF pac_ctaseguro.f_tiene_ctashadow(fec.sseguro, NULL) = 1 THEN
                        INSERT INTO ctaseguro_shadow
                                    (sseguro, fcontab, nnumlin,
                                     ffecmov, fvalmov, cmovimi, imovimi, ccalint, imovim2,
                                     nrecibo, nsinies, cmovanu, smovrec, cesta, nunidad,
                                     cestado, fasign, nparpla, cestpar, iexceso, spermin,
                                     sidepag)
                             VALUES (fec.sseguro,(xf1paren - 1), xnnumlinshw,
                                     (xf1paren - 1),(xf1paren - 1), 0, xprovmat, 0, NULL,
                                     NULL, NULL, 0, NULL, 0, 0,
                                     0, NULL, NULL, NULL, NULL, NULL,
                                     NULL);

                        -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                        IF NVL(pac_parametros.f_parempresa_n(fec.cempres, 'MULTIMONEDA'), 0) =
                                                                                              1 THEN
                           nerror :=
                              pac_oper_monedas.f_update_ctaseguro_shw_monpol(fec.sseguro,
                                                                             (xf1paren - 1),
                                                                             xnnumlinshw,
                                                                             (xf1paren - 1));

                           IF nerror <> 0 THEN
                              ROLLBACK;
                              ttexto := f_axis_literales(nerror, pcidioma);
                              xnnumlinshw := NULL;
                              num_err := f_proceslin(xnproc, texto, fec.sseguro, xnnumlinshw);

                              IF num_err = 0 THEN
                                 COMMIT;
                              END IF;

                              xferror := 1;
                              xnerror := xnerror + 1;
                           END IF;
                        END IF;
                     END IF;
                  -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                        NULL;
                     WHEN OTHERS THEN
                        nerror := 102555;
                        RAISE excep;
                  END;

                  -- Actualizo Fecha vencimiento del Seguro.
                  IF prod.cduraci <> 4 THEN
                     BEGIN
                        UPDATE seguros
                           SET fvencim = xfuparen
                         WHERE sseguro = fec.sseguro;
                     EXCEPTION
                        WHEN OTHERS THEN
                           nerror := 102361;
                           RAISE excep;
                     END;
                  END IF;

                  COMMIT;
               EXCEPTION
                  WHEN excep THEN
                     ROLLBACK;
                     ttexto := f_axis_literales(nerror, pcidioma);
                     xnumlin := NULL;
                     num_err := f_proceslin(xnproc, texto, fec.sseguro, xnumlin);

                     IF num_err = 0 THEN
                        COMMIT;
                     END IF;

                     xferror := 1;
                     xnerror := xnerror + 1;
                  WHEN OTHERS THEN
                     ROLLBACK;
                     xnumlin := NULL;
                     num_err := f_proceslin(xnproc, 'Traza:' || vtraza || ' - ' || SQLERRM,
                                            fec.sseguro, xnumlin);

                     IF num_err = 0 THEN
                        COMMIT;
                     END IF;

                     xferror := 1;
                     xnerror := xnerror + 1;
               END;
            END LOOP;
         END LOOP;

         --
         IF xnerror = 0 THEN
            ttexto := f_axis_literales(102903, pcidioma);
            xnumlin := NULL;
            num_err := f_proceslin(xnproc, texto, 0, xnumlin);

            IF num_err = 0 THEN
               COMMIT;
            END IF;

            xnerror := 0;
         END IF;

         num_err := f_procesfin(xnproc, xnerror);
         COMMIT;
         RETURN 0;
      END IF;
   END vto_aportaciones;

-- ******************************************************************
-- Anula aquellas pólizas que llegan al vto de la renta.
-- ******************************************************************
   FUNCTION vto_rentas(pfefecto IN DATE)   -- Fecha
      RETURN NUMBER IS
      num_err        NUMBER;
      xnmovim        NUMBER;
   BEGIN
      FOR ren IN (SELECT   sseguro, fppren, fuparen
                      FROM seguros_ren
                     WHERE fppren > fuparen
                       AND fuparen IS NOT NULL
                       AND ffinren IS NULL
                  ORDER BY fuparen) LOOP
         num_err := f_anulaseg(ren.sseguro, NULL, ren.fuparen, 501, NULL, 3, xnmovim);
      END LOOP;

      RETURN 0;
   END vto_rentas;

-- ****************************************************************
-- anula_rec
-- Busca los recibos que se han pagado para extornar o generados
-- para in pfecha: Fecha
--param in pseguro: Seguro
-- param in secren : srecren
-- ****************************************************************
   FUNCTION anula_rec(
      pfecha IN DATE,   -- Fecha en que se ha informado la muerte
      pseguro IN NUMBER,   -- Clave del Seguro
      psrecren IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      xpfecha        NUMBER;
      xppfecha       DATE;
      -- Variables Buscar Producto
      xsproduc       NUMBER;   -- Clave del producto
      xnrecren       NUMBER;
      -- Variables de asegurados
      xnroaseg       NUMBER;   -- Nro de Asegurados
      xsperson       NUMBER(10);   -- Clave 1er asegurado
      xsperson2      NUMBER(10);   -- Clave 2on. asegurado
      -- Variables para mandar al calculo
      estamort       NUMBER;   -- 0=Vivos 2 aseg., 1=Vivo 1er aseg, 2=Vivo 2on aseg, 3=Muertos 2 aseg.
      xfppren        DATE;
      xibruren       NUMBER;
      xf1paren       DATE;
      xfefecto       DATE;
      xcramo         NUMBER;
      xcmodali       NUMBER;
      xctipseg       NUMBER;
      xccolect       NUMBER;
      xcbancar       seguros.cbancar%TYPE;
      xsrecren       NUMBER;   -- Clave de la sequence de Recibos.
      xnum           NUMBER;   -- Valor de retorno calculo renta.
      xnnumlin       NUMBER := NULL;
      xnnumlinshw    NUMBER := NULL;
      w_data         DATE;
      num_err        NUMBER;
      vctipban       NUMBER;
      -- Bug 17247 - RSC - 11/03/2011 - ENSA103 - Instalar els web-services als entorns CSI
      v_seqgrupo     ctaseguro.ccalint%TYPE;
      v_sproduc      seguros.sproduc%TYPE;
      v_cempres      seguros.cempres%TYPE;
      vffecpag       DATE;
   -- Fin bug 17247
   BEGIN
      xsperson := 0;
      xsperson2 := 0;
      xnroaseg := 0;

      -- Busca Asegurados
      FOR aseg IN (SELECT   sperson, norden
                       FROM asegurados
                      WHERE sseguro = pseguro
                   ORDER BY norden) LOOP
         IF aseg.norden = 1 THEN
            xsperson := aseg.sperson;
            xnroaseg := 1;
         ELSE
            xsperson2 := aseg.sperson;
            xnroaseg := 2;
         END IF;
      END LOOP;

      IF xsperson = 0 THEN
         RETURN 108307;
      END IF;

      -- Miro quien esta muerto
      estamort := 0;
      xppfecha := pfecha + 1;
      xpfecha := TO_NUMBER(TO_CHAR(xppfecha, 'yyyymmdd'));
      estamort := ffallaseg(1, xsperson, xsperson2, pseguro, xpfecha);

      -- Busco datos del seguro
      BEGIN
         SELECT sr.fppren, sr.ibruren, sr.f1paren, s.fefecto, s.cramo, s.cmodali, s.ctipseg,
                s.ccolect, s.cbancar, s.ctipban, s.sproduc,
                s.cempres   -- Bug 17247 - RSC - 11/03/2011
           INTO xfppren, xibruren, xf1paren, xfefecto, xcramo, xcmodali, xctipseg,
                xccolect, xcbancar, vctipban, v_sproduc,
                v_cempres   -- Bug 17247 - RSC - 11/03/2011
           FROM seguros_ren sr, seguros s
          WHERE sr.sseguro = pseguro
            AND s.sseguro = pseguro
            AND s.csituac = 0;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 101919;
         WHEN OTHERS THEN
            RETURN 101919;
      END;

      -- Busco datos producto
      SELECT sproduc, nrecren
        INTO xsproduc, xnrecren
        FROM productos
       WHERE cramo = xcramo
         AND cmodali = xcmodali
         AND ctipseg = xctipseg
         AND ccolect = xccolect;

      --
      IF xnrecren = 1 THEN
         xsperson2 := 0;
         xnroaseg := 1;
      END IF;

      --
      FOR pag IN (SELECT p.srecren, p.sseguro, p.sperson, p.ffecpag, p.isinret, p.pretenc,
                         p.iretenc, p.iconret, p.ibase, m.fmovini, m.fmovfin, m.fefecto,
                         m.cestrec, m.smovpag, p.ctipban
                    FROM pagosrenta p, movpagren m
                   WHERE p.sseguro = pseguro
                     AND m.srecren = p.srecren
                     AND p.ffecpag >= pfecha
                     AND((p.srecren = psrecren
                          AND psrecren IS NOT NULL)
                         OR(psrecren IS NULL))
                     AND(m.fmovfin IS NULL
                         AND(m.cestrec = 0
                             OR m.cestrec = 1))) LOOP
         BEGIN
            SELECT TRUNC(fmovini)
              INTO w_data
              FROM movpagren
             WHERE srecren = pag.srecren
               AND fmovfin IS NULL
               AND cestrec = 0;
         EXCEPTION
            WHEN OTHERS THEN
               w_data := f_sysdate;
         END;

         IF xsperson = pag.sperson THEN   -- Registro del 1er asegurado
            IF estamort = 0
               OR estamort = 1 THEN   -- Esta vivo (2 asegurados)
               IF pag.cestrec = 0 THEN   -- Si no esta pagada se recalcula la renta
                  xnum := calc_rentas(pag.srecren, pseguro, xsperson, xsperson2, xnroaseg,
                                      xsproduc, xibruren, 2, xf1paren, xfppren, xfefecto,
                                      xcbancar, 'R', vctipban);

                  IF xnum = 0 THEN
                     --COMMIT;
                     NULL;
                  ELSE
                     RETURN xnum;
                  END IF;
               ELSIF pag.cestrec = 1 THEN   --Si está pagado insertamos en ctaseguro
                  xnnumlin := NULL;

                  BEGIN   --Anulamos
                     UPDATE pagosrenta   -- Actualizamos Cabecera de recibo
                        SET cmotanu = 1,
                            ffecanu = pfecha
                      WHERE sseguro = pseguro
                        AND srecren = pag.srecren;
                  EXCEPTION
                     WHEN OTHERS THEN
                        RETURN 109845;
                  END;

                  BEGIN
                     UPDATE movpagren   -- Actualizamos el último Movimientos
                        SET fmovfin = pag.fmovini
                      WHERE srecren = pag.srecren
                        AND smovpag = pag.smovpag;
                  EXCEPTION
                     WHEN OTHERS THEN
                        RETURN 109846;
                  END;

                  BEGIN
                     INSERT INTO movpagren   -- Generamos el Movimientos de anulación
                                 (srecren, smovpag, cestrec, fmovini, fmovfin, fefecto)
                          VALUES (pag.srecren,(pag.smovpag + 1), 2, pag.fmovini, NULL, pfecha);
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                        RETURN 109846;
                     WHEN OTHERS THEN
                        RETURN 109846;
                  END;

                  UPDATE ctaseguro
                     SET cmovanu = 1
                   WHERE sseguro = pag.sseguro
                     AND srecren = pag.srecren;

                  IF pac_ctaseguro.f_tiene_ctashadow(pag.sseguro, NULL) = 1 THEN
                     UPDATE ctaseguro_shadow
                        SET cmovanu = 1
                      WHERE sseguro = pag.sseguro
                        AND srecren = pag.srecren;
                  END IF;

                  SELECT MAX(nnumlin)
                    INTO xnnumlin
                    FROM ctaseguro
                   WHERE sseguro = pag.sseguro;

                  IF pac_ctaseguro.f_tiene_ctashadow(pag.sseguro, NULL) = 1 THEN
                     SELECT MAX(nnumlin)
                       INTO xnnumlinshw
                       FROM ctaseguro_shadow
                      WHERE sseguro = pag.sseguro;
                  END IF;

                  -- Bug 17247 - RSC - 11/03/2011 - ENSA103 - Instalar els web-services als entorns CSI
                  IF NVL(f_parproductos_v(v_sproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1 THEN
                     SELECT scagrcta.NEXTVAL
                       INTO v_seqgrupo
                       FROM DUAL;
                  ELSE
                     v_seqgrupo := 0;
                  END IF;

                  -- Buscamos la fecha valor del pago de renta que anulamos.
                  -- Esto aplica tanto a indexado como no!
                  BEGIN
                     SELECT c1.fvalmov
                       INTO vffecpag
                       FROM ctaseguro c1
                      WHERE c1.sseguro = pag.sseguro
                        AND c1.cmovimi = 53
                        AND c1.srecren = pag.srecren
                        AND c1.nnumlin = (SELECT MAX(nnumlin)
                                            FROM ctaseguro c2
                                           WHERE c2.sseguro = c1.sseguro
                                             AND c2.cmovimi = c1.cmovimi
                                             AND c2.srecren = c1.srecren);
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN   -- Por que noe stá pagado
                        vffecpag := f_sysdate;
                  END;

                  -- Fin Bug 17247
                  num_err :=
                     pk_transferencias.insertar_ctaseguro
                        (pag.sseguro, f_sysdate, NVL(xnnumlin + 1, 1), f_sysdate, vffecpag,   -- Bug 17247 - RSC - 11/03/2011
                         10,   --JRH Anulación de prestación
                         pag.isinret, NULL, NULL,   --En lugar del recibo
                         v_seqgrupo,   -- Bug 17247 - RSC - 11/03/2011 - ENSA103 - Instalar els web-services als entorns CSI
                         0, NULL, NULL, NULL,
                         --vienen de fmovcta
                         GREATEST(w_data, f_sysdate), f_sysdate, pag.srecren);

                  IF num_err <> 0 THEN
                     RETURN num_err;
                  END IF;

                  IF pac_ctaseguro.f_tiene_ctashadow(pag.sseguro, NULL) = 1 THEN
                     num_err :=
                        pk_transferencias.insertar_ctaseguro_shw
                           (pag.sseguro, f_sysdate, NVL(xnnumlinshw + 1, 1), f_sysdate,
                            vffecpag,   -- Bug 17247 - RSC - 11/03/2011
                            10,   --JRH Anulación de prestación
                            pag.isinret, NULL, NULL,   --En lugar del recibo
                            v_seqgrupo,   -- Bug 17247 - RSC - 11/03/2011 - ENSA103 - Instalar els web-services als entorns CSI
                            0, NULL, NULL, NULL,
                            --vienen de fmovcta
                            GREATEST(w_data, f_sysdate), f_sysdate, pag.srecren);

                     IF num_err <> 0 THEN
                        RETURN num_err;
                     END IF;
                  END IF;

                  -- Bug 17247 - RSC - 11/03/2011 - ENSA103 - Instalar els web-services als entorns CSI
                  IF NVL(f_parproductos_v(v_sproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1 THEN
                     num_err := f_distribuir_inversion(v_cempres, pag.sseguro, xnnumlin,
                                                       v_seqgrupo, pag.srecren, pag.isinret,
                                                       10, 90);

                     IF num_err <> 0 THEN
                        RETURN num_err;
                     END IF;

                     IF pac_ctaseguro.f_tiene_ctashadow(pag.sseguro, NULL) = 1 THEN
                        num_err := f_distribuir_inversion_shw(v_cempres, pag.sseguro,
                                                              xnnumlinshw, v_seqgrupo,
                                                              pag.srecren, pag.isinret, 10,
                                                              90);

                        IF num_err <> 0 THEN
                           RETURN num_err;
                        END IF;
                     END IF;
                  END IF;
               -- Fin Bug 17247
               END IF;
            ELSIF estamort = 2 THEN   -- Esta muerto (2 asegurados)
               IF pag.cestrec IN(0, 1) THEN   --
                  BEGIN
                     UPDATE pagosrenta   -- Actualizamos Cabecera de recibo
                        SET cmotanu = 1,
                            ffecanu = pfecha
                      WHERE sseguro = pseguro
                        AND srecren = pag.srecren;
                  EXCEPTION
                     WHEN OTHERS THEN
                        RETURN 109845;
                  END;

                  IF pag.cestrec = 1 THEN   --Si está pagado insertamos en ctaseguro
                     xnnumlin := NULL;

                     UPDATE ctaseguro
                        SET cmovanu = 1
                      WHERE sseguro = pag.sseguro
                        AND srecren = pag.srecren;

                     IF pac_ctaseguro.f_tiene_ctashadow(pag.sseguro, NULL) = 1 THEN
                        UPDATE ctaseguro_shadow
                           SET cmovanu = 1
                         WHERE sseguro = pag.sseguro
                           AND srecren = pag.srecren;
                     END IF;

                     SELECT MAX(nnumlin)
                       INTO xnnumlin
                       FROM ctaseguro
                      WHERE sseguro = pag.sseguro;

                     IF pac_ctaseguro.f_tiene_ctashadow(pag.sseguro, NULL) = 1 THEN
                        SELECT MAX(nnumlin)
                          INTO xnnumlinshw
                          FROM ctaseguro_shadow
                         WHERE sseguro = pag.sseguro;
                     END IF;

                     -- Bug 17247 - RSC - 11/03/2011 - ENSA103 - Instalar els web-services als entorns CSI
                     IF NVL(f_parproductos_v(v_sproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1 THEN
                        SELECT scagrcta.NEXTVAL
                          INTO v_seqgrupo
                          FROM DUAL;
                     ELSE
                        v_seqgrupo := 0;
                     END IF;

                     -- Buscamos la fecha valor del pago de renta que anulamos.
                     -- Esto aplica tanto a indexado como no!
                     BEGIN
                        SELECT c1.fvalmov
                          INTO vffecpag
                          FROM ctaseguro c1
                         WHERE c1.sseguro = pag.sseguro
                           AND c1.cmovimi = 53
                           AND c1.srecren = pag.srecren
                           AND c1.nnumlin = (SELECT MAX(nnumlin)
                                               FROM ctaseguro c2
                                              WHERE c2.sseguro = c1.sseguro
                                                AND c2.cmovimi = c1.cmovimi
                                                AND c2.srecren = c1.srecren);
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN   -- Por que noe stá pagado
                           vffecpag := f_sysdate;
                     END;

                     -- Fin Bug 17247
                     num_err :=
                        pk_transferencias.insertar_ctaseguro
                                                    (pag.sseguro, f_sysdate,
                                                     NVL(xnnumlin + 1, 1), f_sysdate, vffecpag,   -- Bug 17247 - RSC - 11/03/2011
                                                     10,   --JRH Anulación de prestación
                                                     pag.isinret, NULL, NULL,   --En lugar del recibo
                                                     v_seqgrupo,   -- Bug 17247 - RSC - 11/03/2011
                                                     0, NULL, NULL, NULL,

                                                     --vienen de fmovcta
                                                     GREATEST(w_data, f_sysdate), f_sysdate,
                                                     pag.srecren);

                     IF num_err <> 0 THEN
                        RETURN num_err;
                     END IF;

                     IF pac_ctaseguro.f_tiene_ctashadow(pag.sseguro, NULL) = 1 THEN
                        num_err :=
                           pk_transferencias.insertar_ctaseguro_shw
                                                   (pag.sseguro, f_sysdate,
                                                    NVL(xnnumlinshw + 1, 1), f_sysdate,
                                                    vffecpag,   -- Bug 17247 - RSC - 11/03/2011
                                                    10,   --JRH Anulación de prestación
                                                    pag.isinret, NULL, NULL,   --En lugar del recibo
                                                    v_seqgrupo,   -- Bug 17247 - RSC - 11/03/2011
                                                    0, NULL, NULL, NULL,

                                                    --vienen de fmovcta
                                                    GREATEST(w_data, f_sysdate), f_sysdate,
                                                    pag.srecren);

                        IF num_err <> 0 THEN
                           RETURN num_err;
                        END IF;
                     END IF;

                     -- Bug 17247 - RSC - 11/03/2011 - ENSA103 - Instalar els web-services als entorns CSI
                     IF NVL(f_parproductos_v(v_sproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1 THEN
                        num_err := f_distribuir_inversion(v_cempres, pag.sseguro, xnnumlin,
                                                          v_seqgrupo, pag.srecren,
                                                          pag.isinret, 10, 90);

                        IF num_err <> 0 THEN
                           RETURN num_err;
                        END IF;

                        IF pac_ctaseguro.f_tiene_ctashadow(pag.sseguro, NULL) = 1 THEN
                           num_err := f_distribuir_inversion_shw(v_cempres, pag.sseguro,
                                                                 xnnumlinshw, v_seqgrupo,
                                                                 pag.srecren, pag.isinret, 10,
                                                                 90);

                           IF num_err <> 0 THEN
                              RETURN num_err;
                           END IF;
                        END IF;
                     END IF;
                  -- Fin Bug 17247
                  END IF;

                  BEGIN
                     UPDATE movpagren   -- Actualizamos el último Movimientos
                        SET fmovfin = pag.fmovini
                      WHERE srecren = pag.srecren
                        AND smovpag = pag.smovpag;
                  EXCEPTION
                     WHEN OTHERS THEN
                        RETURN 109846;
                  END;

                  BEGIN
                     INSERT INTO movpagren   -- Generamos el Movimientos de anulación
                                 (srecren, smovpag, cestrec, fmovini, fmovfin, fefecto)
                          VALUES (pag.srecren,(pag.smovpag + 1), 2, pag.fmovini, NULL, pfecha);
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                        RETURN 109846;
                     WHEN OTHERS THEN
                        RETURN 109846;
                  END;
               --COMMIT;
               END IF;
            END IF;   -- estamort
         ELSE   -- Registro del 2on. asegurado
            IF estamort = 0
               OR estamort = 2 THEN   -- Esta vivo (2 asegurados) Se recalcula Renta.
               IF pag.cestrec = 0 THEN   -- Si no esta pagada se recalcula la renta
                  xnum := calc_rentas(pag.srecren, pseguro, xsperson, xsperson2, xnroaseg,
                                      xsproduc, xibruren, 2, xf1paren, xfppren, xfefecto,
                                      xcbancar, 'R', vctipban);

                  IF xnum = 0 THEN
                     --COMMIT;
                     NULL;
                  ELSE
                     RETURN xnum;
                  END IF;
               ELSIF pag.cestrec = 1 THEN   --Si está pagado insertamos en ctaseguro
                  BEGIN
                     UPDATE pagosrenta   -- Actualizamos Cabecera de recibo
                        SET cmotanu = 1,
                            ffecanu = pfecha
                      WHERE sseguro = pseguro
                        AND srecren = pag.srecren;
                  EXCEPTION
                     WHEN OTHERS THEN
                        RETURN 109845;
                  END;

                  BEGIN
                     UPDATE movpagren   -- Actualizamos el último Movimientos
                        SET fmovfin = pag.fmovini
                      WHERE srecren = pag.srecren
                        AND smovpag = pag.smovpag;
                  EXCEPTION
                     WHEN OTHERS THEN
                        RETURN 109846;
                  END;

                  BEGIN
                     INSERT INTO movpagren   -- Generamos el Movimientos de anulación
                                 (srecren, smovpag, cestrec, fmovini, fmovfin, fefecto)
                          VALUES (pag.srecren,(pag.smovpag + 1), 2, pag.fmovini, NULL, pfecha);
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                        RETURN 109846;
                     WHEN OTHERS THEN
                        RETURN 109846;
                  END;

                  xnnumlin := NULL;

                  UPDATE ctaseguro
                     SET cmovanu = 1
                   WHERE sseguro = pag.sseguro
                     AND srecren = pag.srecren;

                  IF pac_ctaseguro.f_tiene_ctashadow(pag.sseguro, NULL) = 1 THEN
                     UPDATE ctaseguro_shadow
                        SET cmovanu = 1
                      WHERE sseguro = pag.sseguro
                        AND srecren = pag.srecren;
                  END IF;

                  SELECT MAX(nnumlin)
                    INTO xnnumlin
                    FROM ctaseguro
                   WHERE sseguro = pag.sseguro;

                  IF pac_ctaseguro.f_tiene_ctashadow(pag.sseguro, NULL) = 1 THEN
                     SELECT MAX(nnumlin)
                       INTO xnnumlinshw
                       FROM ctaseguro_shadow
                      WHERE sseguro = pag.sseguro;
                  END IF;

                  -- Bug 17247 - RSC - 11/03/2011 - ENSA103 - Instalar els web-services als entorns CSI
                  IF NVL(f_parproductos_v(v_sproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1 THEN
                     SELECT scagrcta.NEXTVAL
                       INTO v_seqgrupo
                       FROM DUAL;
                  ELSE
                     v_seqgrupo := 0;
                  END IF;

                  -- Buscamos la fecha valor del pago de renta que anulamos.
                  -- Esto aplica tanto a indexado como no!
                  BEGIN
                     SELECT c1.fvalmov
                       INTO vffecpag
                       FROM ctaseguro c1
                      WHERE c1.sseguro = pag.sseguro
                        AND c1.cmovimi = 53
                        AND c1.srecren = pag.srecren
                        AND c1.nnumlin = (SELECT MAX(nnumlin)
                                            FROM ctaseguro c2
                                           WHERE c2.sseguro = c1.sseguro
                                             AND c2.cmovimi = c1.cmovimi
                                             AND c2.srecren = c1.srecren);
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN   -- Por que noe stá pagado
                        vffecpag := f_sysdate;
                  END;

                  -- Fin Bug 17247
                  num_err :=
                     pk_transferencias.insertar_ctaseguro
                                                    (pag.sseguro, f_sysdate,
                                                     NVL(xnnumlin + 1, 1), f_sysdate, vffecpag,   -- Bug 17247 - RSC - 11/03/2011
                                                     10,   --JRH Anulación de prestación
                                                     pag.isinret, NULL, NULL,   --En lugar del recibo
                                                     v_seqgrupo,   -- Bug 17247 - RSC - 11/03/2011
                                                     0, NULL, NULL, NULL,

                                                     --vienen de fmovcta
                                                     GREATEST(w_data, f_sysdate), f_sysdate,
                                                     pag.srecren);

                  IF num_err <> 0 THEN
                     RETURN num_err;
                  END IF;

                  IF pac_ctaseguro.f_tiene_ctashadow(pag.sseguro, NULL) = 1 THEN
                     num_err :=
                        pk_transferencias.insertar_ctaseguro_shw
                                                   (pag.sseguro, f_sysdate,
                                                    NVL(xnnumlinshw + 1, 1), f_sysdate,
                                                    vffecpag,   -- Bug 17247 - RSC - 11/03/2011
                                                    10,   --JRH Anulación de prestación
                                                    pag.isinret, NULL, NULL,   --En lugar del recibo
                                                    v_seqgrupo,   -- Bug 17247 - RSC - 11/03/2011
                                                    0, NULL, NULL, NULL,

                                                    --vienen de fmovcta
                                                    GREATEST(w_data, f_sysdate), f_sysdate,
                                                    pag.srecren);

                     IF num_err <> 0 THEN
                        RETURN num_err;
                     END IF;
                  END IF;

                  -- Bug 17247 - RSC - 11/03/2011 - ENSA103 - Instalar els web-services als entorns CSI
                  IF NVL(f_parproductos_v(v_sproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1 THEN
                     num_err := f_distribuir_inversion(v_cempres, pag.sseguro, xnnumlin,
                                                       v_seqgrupo, pag.srecren, pag.isinret,
                                                       10, 90);

                     IF num_err <> 0 THEN
                        RETURN num_err;
                     END IF;

                     IF pac_ctaseguro.f_tiene_ctashadow(pag.sseguro, NULL) = 1 THEN
                        num_err := f_distribuir_inversion_shw(v_cempres, pag.sseguro,
                                                              xnnumlinshw, v_seqgrupo,
                                                              pag.srecren, pag.isinret, 10,
                                                              90);

                        IF num_err <> 0 THEN
                           RETURN num_err;
                        END IF;
                     END IF;
                  END IF;
               -- Fin Bug 17247
               END IF;
            ELSIF estamort = 1 THEN   -- Esta muerto (2 asegurados).
               IF pag.cestrec IN(0, 1) THEN   --
                  BEGIN
                     UPDATE pagosrenta   -- Actualizamos Cabecera de recibo
                        SET cmotanu = 1,
                            ffecanu = pfecha
                      WHERE sseguro = pseguro
                        AND srecren = pag.srecren;
                  EXCEPTION
                     WHEN OTHERS THEN
                        RETURN 109845;
                  END;

                  IF pag.cestrec = 1 THEN   --Si está pagado insertamos en ctaseguro
                     xnnumlin := NULL;

                     UPDATE ctaseguro
                        SET cmovanu = 1
                      WHERE sseguro = pag.sseguro
                        AND srecren = pag.srecren;

                     IF pac_ctaseguro.f_tiene_ctashadow(pag.sseguro, NULL) = 1 THEN
                        UPDATE ctaseguro_shadow
                           SET cmovanu = 1
                         WHERE sseguro = pag.sseguro
                           AND srecren = pag.srecren;
                     END IF;

                     SELECT MAX(nnumlin)
                       INTO xnnumlin
                       FROM ctaseguro
                      WHERE sseguro = pag.sseguro;

                     IF pac_ctaseguro.f_tiene_ctashadow(pag.sseguro, NULL) = 1 THEN
                        SELECT MAX(nnumlin)
                          INTO xnnumlinshw
                          FROM ctaseguro_shadow
                         WHERE sseguro = pag.sseguro;
                     END IF;

                     -- Bug 17247 - RSC - 11/03/2011 - ENSA103 - Instalar els web-services als entorns CSI
                     IF NVL(f_parproductos_v(v_sproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1 THEN
                        SELECT scagrcta.NEXTVAL
                          INTO v_seqgrupo
                          FROM DUAL;
                     ELSE
                        v_seqgrupo := 0;
                     END IF;

                     -- Buscamos la fecha valor del pago de renta que anulamos.
                     -- Esto aplica tanto a indexado como no!
                     BEGIN
                        SELECT c1.fvalmov
                          INTO vffecpag
                          FROM ctaseguro c1
                         WHERE c1.sseguro = pag.sseguro
                           AND c1.cmovimi = 53
                           AND c1.srecren = pag.srecren
                           AND c1.nnumlin = (SELECT MAX(nnumlin)
                                               FROM ctaseguro c2
                                              WHERE c2.sseguro = c1.sseguro
                                                AND c2.cmovimi = c1.cmovimi
                                                AND c2.srecren = c1.srecren);
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN   -- Por que noe stá pagado
                           vffecpag := f_sysdate;
                     END;

                     -- Fin Bug 17247
                     num_err :=
                        pk_transferencias.insertar_ctaseguro
                                                    (pag.sseguro, f_sysdate,
                                                     NVL(xnnumlin + 1, 1), f_sysdate, vffecpag,   -- Bug 17247 - RSC - 11/03/2011
                                                     10,   --JRH Anulación de prestación
                                                     pag.isinret, NULL, NULL,   --En lugar del recibo
                                                     v_seqgrupo,   -- Bug 17247 - RSC - 11/03/2011
                                                     0, NULL, NULL, NULL,

                                                     --vienen de fmovcta
                                                     GREATEST(w_data, f_sysdate), f_sysdate,
                                                     pag.srecren);

                     IF num_err <> 0 THEN
                        RETURN num_err;
                     END IF;

                     IF pac_ctaseguro.f_tiene_ctashadow(pag.sseguro, NULL) = 1 THEN
                        num_err :=
                           pk_transferencias.insertar_ctaseguro_shw
                                                   (pag.sseguro, f_sysdate,
                                                    NVL(xnnumlinshw + 1, 1), f_sysdate,
                                                    vffecpag,   -- Bug 17247 - RSC - 11/03/2011
                                                    10,   --JRH Anulación de prestación
                                                    pag.isinret, NULL, NULL,   --En lugar del recibo
                                                    v_seqgrupo,   -- Bug 17247 - RSC - 11/03/2011
                                                    0, NULL, NULL, NULL,

                                                    --vienen de fmovcta
                                                    GREATEST(w_data, f_sysdate), f_sysdate,
                                                    pag.srecren);

                        IF num_err <> 0 THEN
                           RETURN num_err;
                        END IF;
                     END IF;

                     -- Bug 17247 - RSC - 11/03/2011 - ENSA103 - Instalar els web-services als entorns CSI
                     IF NVL(f_parproductos_v(v_sproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1 THEN
                        num_err := f_distribuir_inversion(v_cempres, pag.sseguro, xnnumlin,
                                                          v_seqgrupo, pag.srecren,
                                                          pag.isinret, 10, 90);

                        IF num_err <> 0 THEN
                           RETURN num_err;
                        END IF;
                     END IF;

                     IF pac_ctaseguro.f_tiene_ctashadow(pag.sseguro, NULL) = 1 THEN
                        IF NVL(f_parproductos_v(v_sproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1 THEN
                           num_err := f_distribuir_inversion_shw(v_cempres, pag.sseguro,
                                                                 xnnumlinshw, v_seqgrupo,
                                                                 pag.srecren, pag.isinret, 10,
                                                                 90);

                           IF num_err <> 0 THEN
                              RETURN num_err;
                           END IF;
                        END IF;
                     END IF;
                  -- Fin Bug 17247
                  END IF;

                  BEGIN
                     UPDATE movpagren   -- Actualizamos el último Movimientos
                        SET fmovfin = pag.fmovini
                      WHERE srecren = pag.srecren
                        AND smovpag = pag.smovpag;
                  EXCEPTION
                     WHEN OTHERS THEN
                        RETURN 109846;
                  END;

                  BEGIN
                     INSERT INTO movpagren   -- Generamos el Movimientos de anulación
                                 (srecren, smovpag, cestrec, fmovini, fmovfin, fefecto)
                          VALUES (pag.srecren,(pag.smovpag + 1), 2, pag.fmovini, NULL, pfecha);
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                        RETURN 109846;
                     WHEN OTHERS THEN
                        RETURN 109846;
                  END;
               --JRH IMP Se lo quito ahora COMMIT;
               END IF;
            END IF;   -- estamort
         END IF;   -- asegurados
      END LOOP;

      RETURN 0;
   END anula_rec;

-- *************************************************************************
--desanula_rec
-- Busca los recibos que se han anulado para desanularlos y recalcula Rentas
-- para in pfecha: Fecha
--param in pseguro: Seguro
-- param in secren : srecren
-- *************************************************************************
   FUNCTION desanula_rec(
      pfecha IN DATE,   -- Fecha en que se ha realizado suplemento
      pseguro IN NUMBER,
      psrecren IN NUMBER DEFAULT NULL)   -- Clave del Seguro
      RETURN NUMBER IS
      xpfecha        NUMBER;
      xppfecha       DATE;
      -- Variables Buscar Producto
      xsproduc       NUMBER;   -- Clave del producto
      xnrecren       NUMBER;
      -- Variables de asegurados
      xnroaseg       NUMBER;   -- Nro de Asegurados
      xsperson       NUMBER(10);   -- Clave 1er asegurado
      xsperson2      NUMBER(10);   -- Clave 2on. asegurado
      -- Variables para mandar al calculo
      estamort       NUMBER;   -- 0=Vivos 2 aseg., 1=Vivo 1er aseg, 2=Vivo 2on aseg, 3=Muertos 2 aseg.
      xfppren        DATE;
      xibruren       NUMBER;
      xf1paren       DATE;
      xfefecto       DATE;
      xcramo         NUMBER;
      xcmodali       NUMBER;
      xctipseg       NUMBER;
      xccolect       NUMBER;
      xcbancar       seguros.cbancar%TYPE;
      xsrecren       NUMBER;   -- Clave de la sequence de Recibos.
      xnum           NUMBER;   -- Valor de retorno calculo renta.
      vctipban       NUMBER;
   BEGIN
      xsperson := 0;
      xsperson2 := 0;
      xnroaseg := 0;

      -- Busca Asegurados
      FOR aseg IN (SELECT   sperson, norden
                       FROM asegurados
                      WHERE sseguro = pseguro
                   ORDER BY norden) LOOP
         IF aseg.norden = 1 THEN
            xsperson := aseg.sperson;
            xnroaseg := 1;
         ELSE
            xsperson2 := aseg.sperson;
            xnroaseg := 2;
         END IF;
      END LOOP;

      IF xsperson = 0 THEN
         RETURN 108307;
      END IF;

      -- Busco datos del seguro
      BEGIN
         SELECT sr.fppren, sr.ibruren, sr.f1paren, s.fefecto, s.cramo, s.cmodali, s.ctipseg,
                s.ccolect, s.cbancar, s.ctipban
           INTO xfppren, xibruren, xf1paren, xfefecto, xcramo, xcmodali, xctipseg,
                xccolect, xcbancar, vctipban
           FROM seguros_ren sr, seguros s
          WHERE sr.sseguro = pseguro
            AND s.sseguro = pseguro
            AND s.csituac = 0;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 101919;
         WHEN OTHERS THEN
            RETURN 101919;
      END;

      -- Busco datos producto
      SELECT sproduc, nrecren
        INTO xsproduc, xnrecren
        FROM productos
       WHERE cramo = xcramo
         AND cmodali = xcmodali
         AND ctipseg = xctipseg
         AND ccolect = xccolect;

      --
      IF xnrecren = 1 THEN
         xsperson2 := 0;
         xnroaseg := 1;
      END IF;

      --
      FOR pag IN (SELECT p.srecren, p.sseguro, p.sperson, p.ffecpag, p.isinret, p.pretenc,
                         p.iretenc, p.iconret, p.ibase, m.fmovini, m.fmovfin, m.fefecto,
                         m.cestrec, m.smovpag
                    FROM pagosrenta p, movpagren m
                   WHERE p.sseguro = pseguro
                     AND m.srecren = p.srecren
                     AND p.ffecpag >= pfecha
                     AND((p.srecren = psrecren
                          AND psrecren IS NOT NULL)
                         OR(psrecren IS NULL))
                     AND(m.fmovfin IS NULL
                         AND m.cestrec = 2)) LOOP
         BEGIN
            DELETE FROM movpagren
                  WHERE smovpag = pag.smovpag
                    AND srecren = pag.srecren;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 109846;
         END;

         --
         BEGIN
            UPDATE movpagren
               SET fmovfin = NULL
             WHERE smovpag =(pag.smovpag - 1)
               AND srecren = pag.srecren;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 109846;
         END;

         --
         BEGIN
            UPDATE pagosrenta   -- Actualizamos Cabecera de recibo
               SET cmotanu = NULL,
                   ffecanu = NULL
             WHERE sseguro = pseguro
               AND srecren = pag.srecren;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 109845;
         END;
      END LOOP;

       --COMMIT;
      --
      FOR pag IN (SELECT p.srecren, p.sseguro, p.sperson, p.ffecpag, p.isinret, p.pretenc,
                         p.iretenc, p.iconret, p.ibase, m.fmovini, m.fmovfin, m.fefecto,
                         m.cestrec, m.smovpag
                    FROM pagosrenta p, movpagren m
                   WHERE p.sseguro = pseguro
                     AND m.srecren = p.srecren
                     AND p.ffecpag >= pfecha
                     AND((p.srecren = psrecren
                          AND psrecren IS NOT NULL)
                         OR(psrecren IS NULL))
                     AND(m.fmovfin IS NULL
                         AND m.cestrec = 0)) LOOP
         xnum := calc_rentas(pag.srecren, pseguro, xsperson, xsperson2, xnroaseg, xsproduc,
                             xibruren, 2, xf1paren, xfppren, xfefecto, xcbancar, 'R',
                             vctipban);

         IF xnum <> 0 THEN
            RETURN xnum;
         END IF;
      END LOOP;

       --JRH Se lo quito ahora COMMIT;
      --
      RETURN 0;
   END desanula_rec;

-- ****************************************************************
-- Busca los recibos que se han pagado para extornar o generados
-- ****************************************************************
   FUNCTION siniestro_ren(
      pfecsini IN DATE,   -- Fecha del siniestro
      pfmuerte IN DATE,   -- Fecha de muerte
      psperson IN NUMBER,   -- Persona que muere
      pseguro IN NUMBER)   -- Clave del Seguro
      RETURN NUMBER IS
      -- Variables para mandar al calculo
      xcbancar       seguros.cbancar%TYPE;
      xsrecren       NUMBER;   -- Clave de la sequence de Recibos.
      cempresa       seguros.cempres%TYPE;
      n_err          NUMBER;
   BEGIN
      -- Busco datos del seguro
      BEGIN
         SELECT cbancar, cempresa
           INTO xcbancar, cempresa
           FROM seguros
          WHERE sseguro = pseguro
            AND csituac = 0;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 101919;
         WHEN OTHERS THEN
            RETURN 101919;
      END;

      --
      -- Bug 18286 - APD - 26/04/2011 - Se añaden los campos nsinies, ntramit, ctipdes
      FOR pag IN (SELECT p.srecren, p.sseguro, p.sperson, p.ffecpag, p.isinret, p.pretenc,
                         p.iretenc, p.iconret, p.ibase, m.fmovini, m.fmovfin, m.fefecto,
                         m.cestrec, m.smovpag, p.nsinies, p.ntramit, p.ctipdes
                    FROM pagosrenta p, movpagren m
                   WHERE p.sseguro = pseguro
                     AND p.sperson = psperson
                     AND m.srecren = p.srecren
                     AND p.ffecpag > pfmuerte
                     AND(m.fmovfin IS NULL
                         AND(m.cestrec = 0
                             OR m.cestrec = 1))) LOOP
         IF pag.cestrec = 0 THEN   -- Si no esta pagado el recibo se anula
            BEGIN
               UPDATE pagosrenta   -- Actualizamos Cabecera de recibo
                  SET cmotanu = 1,
                      ffecanu = pfecsini
                WHERE sseguro = pseguro
                  AND srecren = pag.srecren;
            EXCEPTION
               WHEN OTHERS THEN
                  RETURN 109845;
            END;

            BEGIN
               UPDATE movpagren   -- Actualizamos el último Movimientos
                  SET fmovfin = pag.fmovini
                WHERE srecren = pag.srecren
                  AND smovpag = pag.smovpag;
            EXCEPTION
               WHEN OTHERS THEN
                  RETURN 109846;
            END;

            BEGIN
               INSERT INTO movpagren   -- Generamos el Movimientos de anulación
                           (srecren, smovpag, cestrec, fmovini, fmovfin, fefecto)
                    VALUES (pag.srecren,(pag.smovpag + 1), 2, pag.fmovini, NULL, pfecsini);
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  RETURN 109846;
               WHEN OTHERS THEN
                  RETURN 109846;
            END;

            COMMIT;
         ELSE   -- Si esta pagado se genera un recibo de devolución
            SELECT ssrecren.NEXTVAL
              INTO xsrecren
              FROM DUAL;

            BEGIN
               -- Generamos el Recibo de extorno con un movimiento pendiente de extorno.
               -- Bug 18286 - APD - 26/04/2011 - Se añaden los campos nsinies, ntramit, ctipdes
               INSERT INTO pagosrenta
                           (srecren, sseguro, sperson, ffecefe, ffecpag, ffecanu,
                            cmotanu, isinret, pretenc, iretenc, iconret,
                            ibase, nctacor, nremesa, fremesa, nsinies, ntramit,
                            ctipdes)
                    VALUES (xsrecren, pseguro, pag.sperson, pfecsini, pag.ffecpag, NULL,
                            NULL, pag.isinret, pag.pretenc, pag.iretenc, pag.iconret,
                            pag.ibase, xcbancar, NULL, NULL, pag.nsinies, pag.ntramit,
                            pag.ctipdes);

               IF NVL(pac_parametros.f_parempresa_n(cempresa, 'MULTIMONEDA'), 0) = 1 THEN
                  n_err := pac_oper_monedas.f_contravalores_pagosrenta(xsrecren, pseguro);
               END IF;
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  RETURN 109844;
               WHEN OTHERS THEN
                  RETURN 109844;
            END;

            BEGIN
               INSERT INTO movpagren
                           (srecren, smovpag, cestrec, fmovini, fmovfin, fefecto)
                    VALUES (xsrecren, 1, 3, pag.fmovini, NULL, f_sysdate);
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  RETURN 109846;
               WHEN OTHERS THEN
                  RETURN 109846;
            END;

            COMMIT;
         END IF;   -- cestrec
      END LOOP;

      RETURN 0;
   END siniestro_ren;

   FUNCTION f_calc_ptipoint(
      psproduc IN NUMBER,
      reserva_bruta IN NUMBER,
      pfecha IN DATE,
      pinteres OUT NUMBER,
      pnduraint IN NUMBER,
      psseguro IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      w_pintec       NUMBER;
   BEGIN
      IF psseguro IS NULL THEN
         BEGIN
            SELECT ninttec
              INTO pinteres
              FROM intertecprod ip, intertecmov im, intertecmovdet it
             WHERE ip.sproduc = psproduc
               AND ip.ncodint = im.ncodint
               AND im.ctipo = pnduraint
               AND im.finicio <= pfecha
               AND(im.ffin >= pfecha
                   OR im.ffin IS NULL)
               AND im.ncodint = it.ncodint
               AND im.finicio = it.finicio
               AND im.ctipo = it.ctipo
               AND it.ndesde <= reserva_bruta
               AND it.nhasta >= reserva_bruta;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 104742;
         END;
      ELSE
         BEGIN
            SELECT ninttec
              INTO pinteres
              FROM intertecseg isg, intertecprod ip, intertecmov im, intertecmovdet it
             WHERE ip.sproduc = psproduc
               AND ip.ncodint = im.ncodint
               AND im.ctipo = pnduraint
               AND isg.sseguro = psseguro
               AND isg.nmovimi = (SELECT MAX(i.nmovimi)
                                    FROM intertecseg i
                                   WHERE i.sseguro = psseguro)
               AND im.finicio <= isg.fefemov
               AND(im.ffin >= isg.fefemov
                   OR im.ffin IS NULL)
               AND im.ncodint = it.ncodint
               AND im.finicio = it.finicio
               AND im.ctipo = it.ctipo
               AND it.ndesde <= reserva_bruta
               AND it.nhasta >= reserva_bruta;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 104742;
         END;
      END IF;

      RETURN 0;
   END f_calc_ptipoint;

   /*------------------------------------------------------------------------------
     CPM 25/5/2005 : F_BUSCA_ACTIVO
     Funció que tria l'actiu que se li ha d'assignar a una pòlissa de rentas.
     Es retorna la clave i el codi, pot haver diversos actius amb la mateixa clau
     (que ens indica la cotització).
   ------------------------------------------------------------------------------*/
   FUNCTION f_busca_activo(
      psseguro IN NUMBER,
      piadquisi OUT NUMBER,
      ptcodact OUT VARCHAR2,
      ptablas IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER IS
      xcactivo       NUMBER;
      xfrenova       DATE;
   BEGIN
      IF ptablas = 'EST' THEN
         SELECT cactivo,
                        --   tcodact,
                        fefecto
           INTO xcactivo,
                         --ptcodact,
                         xfrenova
           FROM (SELECT   a.cactivo,
                                    --a.tcodact,
                                    s.fefecto
                     FROM activos a, estseguros_ren r, estseguros s
                    WHERE s.sseguro = psseguro
                      AND r.sseguro = psseguro
                 ORDER BY ABS(a.fcierre - ADD_MONTHS(s.fefecto, r.nduraint * 12)))
          WHERE ROWNUM = 1;
      ELSIF ptablas = 'SOL' THEN
         SELECT cactivo,
                        --tcodact,
                        fefecto
           INTO xcactivo,
                         --ptcodact,
                         xfrenova
           FROM (SELECT   a.cactivo,
                                    --a.tcodact,
                                    f_sysdate fefecto
                     FROM activos a, solseguros_ren r
                    WHERE r.ssolicit = psseguro
                 ORDER BY ABS(a.fcierre - ADD_MONTHS(f_sysdate, r.nduraint * 12)))
          WHERE ROWNUM = 1;
      ELSE
         xfrenova := TO_DATE(frenovacion(1, psseguro, 2), 'yyyymmdd');

         SELECT cactivo
           --   , tcodact
         INTO   xcactivo
           --,ptcodact
         FROM   (SELECT   a.cactivo
                     --,a.tcodact
                 FROM     activos a, seguros_ren s
                    WHERE s.sseguro = psseguro
                 ORDER BY ABS(a.fcierre - ADD_MONTHS(xfrenova, s.nduraint * 12)))
          WHERE ROWNUM = 1;
      END IF;

      SELECT iactvent
        INTO piadquisi
        FROM (SELECT   *
                  FROM activosventas
                 WHERE factvent < xfrenova
                   AND cactivo = xcactivo
              ORDER BY factvent DESC)
       WHERE ROWNUM = 1;

      RETURN xcactivo;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_busca_activo;

   /*------------------------------------------------------------------------------
     CPM 25/5/2005 : F_RENTA_NETA
     Funció que calcula la renta neta
   ------------------------------------------------------------------------------*/
   FUNCTION f_renta_neta(
      psseguro IN NUMBER,
      psperson IN NUMBER,
      pfecha IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER IS
      ineta          NUMBER;
      ibruta         NUMBER;
      xsproduc       NUMBER;
      xpretenc       NUMBER;
      xpreducc       NUMBER;
      xerror         NUMBER;
      xanys          NUMBER;
      xfefecto       DATE;
      xcgarant       NUMBER;
      xcactivi       NUMBER;
      xfnacimi       DATE;
      pclaren        NUMBER;
      vcempres       seguros.cempres%TYPE;
      vagente_poliza seguros.cagente%TYPE;
   BEGIN
      -- Busquem l'import brut
      IF ptablas = 'SOL' THEN
         SELECT r.ibruren, f_sysdate, s.sproduc, s.cactivi, g.cgarant, p.crespue
           INTO ibruta, xfefecto, xsproduc, xcactivi, xcgarant, xanys
           FROM solseguros_ren r, solseguros s, garanpro g, solpregunseg p
          WHERE r.ssolicit = psseguro
            AND p.ssolicit = r.ssolicit
            AND p.cpregun = 111
            AND p.nriesgo = 1
            AND s.ssolicit = r.ssolicit
            AND g.sproduc = s.sproduc
            AND f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.cactivi, g.cgarant,
                                'TIPO') = 8;
      ELSIF ptablas = 'EST' THEN
         SELECT r.ibruren, s.fefecto, s.sproduc, s.cactivi, g.cgarant, p.crespue
           INTO ibruta, xfefecto, xsproduc, xcactivi, xcgarant, xanys
           FROM estseguros_ren r, estseguros s, garanpro g, estpregunseg p
          WHERE r.sseguro = psseguro
            AND p.sseguro = r.sseguro
            AND p.cpregun = 111
            AND p.nriesgo = 1
            AND p.nmovimi = (SELECT MAX(nmovimi)
                               FROM estpregunseg p2
                              WHERE p2.sseguro = r.sseguro
                                AND p2.cpregun = 111
                                AND p2.nriesgo = 1)
            AND s.sseguro = r.sseguro
            AND g.sproduc = s.sproduc
            AND f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.cactivi, g.cgarant,
                                'TIPO') = 8;
      ELSE
         SELECT r.ibruren, s.fefecto, s.sproduc, s.cactivi, g.cgarant, p.crespue
           INTO ibruta, xfefecto, xsproduc, xcactivi, xcgarant, xanys
           FROM seguros_ren r, seguros s, garanpro g, pregunseg p
          WHERE r.sseguro = psseguro
            AND p.sseguro = r.sseguro
            AND p.cpregun = 111
            AND p.nriesgo = 1
            AND p.nmovimi = (SELECT MAX(nmovimi)
                               FROM pregunseg p2
                              WHERE p2.sseguro = r.sseguro
                                AND p2.cpregun = 111
                                AND p2.nriesgo = 1)
            AND s.sseguro = r.sseguro
            AND g.sproduc = s.sproduc
            AND f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.cactivi, g.cgarant,
                                'TIPO') = 8;
      END IF;

      -- Busquem la retenció
      IF psperson IS NULL THEN
         BEGIN
            SELECT pretenc
              INTO xpretenc
              FROM paisprete
             WHERE cpais = f_parinstalacion_n('PAIS_DEF')
               AND sproduc = xsproduc
               AND cprovin = 0   -- SHA -- Bug 38224/216445 --11/11/2015
               AND finicio = (SELECT MAX(finicio)
                                FROM paisprete
                               WHERE cpais = f_parinstalacion_n('PAIS_DEF')   --JRH IMP uhhhhh,
                                 AND sproduc = xsproduc
                                 AND cprovin = 0   -- SHA -- Bug 38224/216445 --11/11/2015
                                 AND finicio <= TO_DATE(pfecha, 'yyyymmdd'));
         EXCEPTION
            WHEN OTHERS THEN
               xpretenc := 0;
         END;
      ELSE
         xpretenc := NVL(fbuscapreten(1, psperson, xsproduc, pfecha), 0);
      END IF;

      --P_Control_Error ('ren','ren','ANTES ANYS'||xanys);

      -- Busquem la reducció
      -- CPM 25/11/05:Es vol l'edat real i no l'actuarial
      BEGIN
         IF ptablas = 'SOL' THEN
            SELECT fnacimi
              INTO xfnacimi
              FROM solriesgos
             WHERE ssolicit = psseguro
               AND nriesgo = 1;
         ELSE
            -- Bug10612 - 08/07/2009 - DCT (Añadir vagente_poliza y canviar vista personas)
            SELECT p.fnacimi
              INTO xfnacimi
              FROM per_personas p
             WHERE p.sperson = psperson;
         /*SELECT fnacimi
           INTO xfnacimi
           FROM personas
          WHERE sperson = psperson;*/

         -- FI Bug10612 - 08/07/2009 - DCT (Añadir vagente_poliza y canviar vista personas)
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN NULL;
      END;

      SELECT cclaren
        INTO pclaren
        FROM producto_ren
       WHERE sproduc = xsproduc;

      IF pclaren = 0 THEN   --JRH IMP Si es vitalicia edad
         -- CPM 21/12/06: Se coge la edad en la que se constituyó la póliza (o sea el efecto)
         xerror := f_difdata(xfnacimi, TRUNC(xfefecto), 1, 1, xanys);
      ELSE   --JRH IMP Si no es vitalicia duración
         xanys := pac_calc_comu.ff_get_duracion(ptablas, psseguro);
      END IF;

      --P_Control_Error ('ren','ren','FECHA'||xfnacimi||' ANYS'||xanys);
        -- Fi CPM
      xpreducc := NVL(fbuscapreduc(1, xsproduc, xcactivi, xcgarant, pfecha, xanys), 0);
      --P_Control_Error ('ren','ren','FECHA'||xfnacimi||' ANYS'||xanys||' Reten='||xpreducc);
      ineta := ibruta - ibruta * xpretenc / 100 *(1 - xpreducc / 100);
      RETURN ineta;
   END f_renta_neta;

   /*------------------------------------------------------------------------------
     CPM 25/5/2005 : F_RESCAT_NET
     Funció que calcula el rescat net de retenció
   ------------------------------------------------------------------------------*/
   FUNCTION f_rescat_net(
      psproduc IN NUMBER,
      psperson IN NUMBER,
      pfecha IN NUMBER,
      prescat IN NUMBER,
      prkm IN NUMBER)
      RETURN NUMBER IS
      ineta          NUMBER;
      xpretenc       NUMBER;
   BEGIN
      -- Busquem la retenció
      IF psperson IS NULL THEN
         BEGIN
            SELECT pretenc
              INTO xpretenc
              FROM paisprete
             WHERE cpais = f_parinstalacion_n('PAIS_DEF')
               AND sproduc = psproduc
               AND cprovin = 0   -- SHA -- Bug 38224/216445 --11/11/2015
               AND finicio = (SELECT MAX(finicio)
                                FROM paisprete
                               WHERE cpais = f_parinstalacion_n('PAIS_DEF')
                                 AND sproduc = psproduc
                                 AND cprovin = 0   -- SHA -- Bug 38224/216445 --11/11/2015
                                 AND finicio <= TO_DATE(pfecha, 'yyyymmdd'));
         EXCEPTION
            WHEN OTHERS THEN
               xpretenc := 0;
         END;
      ELSE
         xpretenc := NVL(fbuscapreten(1, psperson, psproduc, pfecha), 0);
      END IF;

      ineta := prescat - prkm * xpretenc / 100;
      RETURN ineta;
   END f_rescat_net;

   --JRH 01/2008 Estado de un pago a una fecha
   FUNCTION f_ult_estado_pago(psrecren IN NUMBER, pfecha IN DATE DEFAULT f_sysdate)
      RETURN NUMBER IS
      CURSOR ultestado IS
         SELECT   cestrec
             FROM movpagren
            WHERE srecren = psrecren
              AND TRUNC(fmovini) <= TRUNC(pfecha)
         ORDER BY fmovini DESC, smovpag DESC;

      v_estado       NUMBER;
   BEGIN
      OPEN ultestado;

      FETCH ultestado
       INTO v_estado;

      CLOSE ultestado;

      RETURN v_estado;
   -- BUG -21546_108724- 04/02/2012 - JLTS - Cierre de posibles cursores abiertos, se adiciona EXCEPTION
   EXCEPTION
      WHEN OTHERS THEN
         IF ultestado%ISOPEN THEN
            CLOSE ultestado;
         END IF;
   END f_ult_estado_pago;

   /*------------------------------------------------------------------------------
     CPM 25/5/2005 : F_RESCAT_NET
     Funció que calcula el coeficient aplicat en un rescat, tenint en compte les
     cotitzacions dels Bonos
   ------------------------------------------------------------------------------*/
   FUNCTION f_coef_rescate(psseguro IN NUMBER, pfecha IN NUMBER)
      RETURN NUMBER IS
      xcactivo       NUMBER;
      xiadqui        NUMBER;
      xventa         NUMBER;
      icoef          NUMBER;
      nfec_aux       NUMBER;
      ntraza         NUMBER;
   BEGIN
      ntraza := 1;

      SELECT TO_NUMBER(TO_CHAR(ADD_MONTHS(fintgar, nduraint * 12), 'yyyymmdd'))
        INTO nfec_aux
        FROM seguros_ren
       WHERE sseguro = psseguro;

      IF nfec_aux = pfecha THEN
         icoef := 1;
      ELSE
         ntraza := 2;

         SELECT 1   --cactivo--, iadqact
           INTO xcactivo   --, xiadqui
           FROM seguros_act
          WHERE sseguro = psseguro;

         ntraza := 3;

         SELECT iactvent
           INTO xventa
           FROM (SELECT   *
                     FROM activosventas
                    WHERE factvent < TO_DATE(pfecha, 'yyyymmdd')
                      AND cactivo = xcactivo
                 ORDER BY factvent DESC)
          WHERE ROWNUM = 1;

         ntraza := 3;
         icoef := xventa / xiadqui;

         IF icoef > 1 THEN
            icoef := 1;
         END IF;
      END IF;

      RETURN icoef;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         -- Es una simulació.
         RETURN 1;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pk_rentas.f_coef_rescate', ntraza,
                     'error no controlado. Sseguro=' || psseguro || 'pfecha=' || pfecha,
                     SQLERRM);
         RETURN 1;
   END f_coef_rescate;

   FUNCTION f_prov_sini(psseguro IN NUMBER)
      RETURN NUMBER IS   --Nos da la provisión a la muerte de un asegurado
      xireserva_mort NUMBER := 0;
      xffecmue       DATE;
   BEGIN
      BEGIN
         SELECT ffecmue
           INTO xffecmue
           FROM asegurados
          WHERE sseguro = psseguro
            AND ffecmue IS NOT NULL;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            xffecmue := NULL;
         WHEN OTHERS THEN
            RETURN NULL;
      END;

      IF xffecmue IS NOT NULL THEN
-- RSC 22/10/2008 -----------------------------------------------------------
-- Vamos a buscarlo al siniestro si existe un siniestro de fallecimiento abierto
-- Si no, o no está valorado pues lo calculamos con la función de provisión.
         -- BUG 11595 - 03/11/2009 - APD - Adaptación al nuevo módulo de siniestros
         -- se añade la UNION con las tablas nuevas de siniestros
         FOR reg IN (SELECT   TO_CHAR(s.nsinies) nsinies, cestsin, s.nasegur, s.fsinies,
                              v.ivalora, seg.sproduc, seg.cactivi
                         FROM siniestros s, valorasini v, seguros seg
                        WHERE s.sseguro = psseguro
                          AND s.nsinies = v.nsinies
                          AND seg.sseguro = s.sseguro
                          AND s.ccausin = 1   -- muerte
                          AND s.cmotsin = 4   -- baja 1 titular
                          AND s.cestsin = 0   -- pendiente o finalizado
                          AND v.cgarant = 1   -- cobertura de muerte
                          AND v.fvalora = (SELECT MAX(fvalora)
                                             FROM valorasini vv
                                            WHERE vv.nsinies = v.nsinies)
                          AND NVL(pac_parametros.f_parempresa_n(seg.cempres, 'MODULO_SINI'), 0) =
                                                                                              0
                     UNION
                     SELECT   s.nsinies, m.cestsin, s.nasegur, s.fsinies, v.ireserva,
                              seg.sproduc, seg.cactivi
                         FROM sin_siniestro s, sin_movsiniestro m, sin_tramitacion t,
                              sin_tramita_reserva v, seguros seg
                        WHERE s.sseguro = psseguro
                          AND s.nsinies = t.nsinies
                          AND t.nsinies = v.nsinies
                          AND t.ntramit = v.ntramit
                          AND s.nsinies = m.nsinies
                          AND m.nmovsin = (SELECT MAX(nmovsin)
                                             FROM sin_movsiniestro
                                            WHERE nsinies = m.nsinies)
                          AND seg.sseguro = s.sseguro
                          AND s.ccausin = 1   -- muerte
                          AND s.cmotsin = 4   -- baja 1 titular
                          AND m.cestsin = 0   -- pendiente o finalizado
                          AND v.cgarant = 1   -- cobertura de muerte
                          AND v.fmovres = (SELECT MAX(fmovres)
                                             FROM sin_tramita_reserva vv
                                            WHERE vv.nsinies = v.nsinies)
                          AND NVL(pac_parametros.f_parempresa_n(seg.cempres, 'MODULO_SINI'), 0) =
                                                                                              1
                     ORDER BY nsinies DESC) LOOP
            xireserva_mort := reg.ivalora;
         END LOOP;

-----------------------------------------------------------------------------

         -- Calculamos la provisión a fecha de fallecimiento
         IF xireserva_mort = 0 THEN
            xireserva_mort := pac_provmat_formul.f_calcul_formulas_provi(psseguro, xffecmue,
                                                                         'IPROVAC');
         END IF;
      END IF;

      RETURN ROUND((xireserva_mort / 2), 2);
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pk_rentas.f_prov_sini', 1,
                     'error no controlado. Sseguro=' || psseguro, SQLERRM);
         RETURN 1;
   END f_prov_sini;

   /*------------------------------------------------------------------------------
     CPM 25/5/2005 : F_CALC_RESCATE
     Funció que calcula el valor del rescat, cridant la formula del GFI
   ------------------------------------------------------------------------------*/
   FUNCTION f_calc_rescate(
      psseguro IN NUMBER,
      pfecha IN NUMBER,
      psproduc IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'SOL')
      RETURN NUMBER IS
      num_err        NUMBER;
      x_icapris      NUMBER;
      w_cgarant      NUMBER;

      /*
       {Cursor formulas de la valoracion: destinatario 0}
      */
      -- BUG 11595 - 03/11/2009 - APD - Adaptación al nuevo módulo de siniestros
      -- se añade la UNION con las tablas nuevas de siniestros
      CURSOR cur_campo(p_cempres NUMBER) IS
         SELECT   1 orden, ccampo, clave, cdestin
             FROM sinigaranformula
            WHERE sprcamosin IN(SELECT sprcamosin
                                  FROM prodcaumotsin
                                 WHERE sproduc = psproduc
                                   AND cgarant = w_cgarant
                                   AND cactivi = 0
                                   AND ccausin = 4
                                   AND cmotsin = 0)
              AND cdestin = 0
              AND ccampo = 'ICAPRIS'
              AND NVL(pac_parametros.f_parempresa_n(p_cempres, 'MODULO_SINI'), 0) = 0
         UNION
         SELECT   1 orden, f.ccampo, f.cclave clave, d.ctipdes cdestin
             FROM sin_for_causa_motivo f, sin_det_causa_motivo d, sin_causa_motivo cm,
                  sin_gar_causa_motivo g
            WHERE f.scaumot = d.scaumot
              AND f.ctipdes = d.ctipdes
              AND d.scaumot = cm.scaumot
              AND g.scaumot = cm.scaumot
              AND g.sproduc = psproduc
              AND g.cgarant = w_cgarant
              AND g.cactivi = 0
              AND cm.ccausin = 4
              AND cm.cmotsin = 0
              AND d.ctipdes = 0
              AND f.ccampo = 'ICAPRIS'
              AND NVL(pac_parametros.f_parempresa_n(p_cempres, 'MODULO_SINI'), 0) = 1
         ORDER BY 1;

      /*
       {cursor de formulas para el pago}
      */

      --
      CURSOR cur_termino(wclave NUMBER) IS
         SELECT   parametro
             FROM sgt_trans_formula
            WHERE clave = wclave
         ORDER BY 1;

      w_fsinies      NUMBER;
      w_fnotifi      NUMBER;
      w_fecefe       NUMBER;
      w_fecval       NUMBER;
      w_sesion       NUMBER;
      w_error        NUMBER;
      w_formula      VARCHAR2(2000);
      w_xs           VARCHAR2(2000);
      w_retorno      NUMBER;
      w_val          NUMBER;
      -- RSC 09/06/2008
      x_cllamada     VARCHAR2(100);
      -- 07/07/2008
      v_cursor       INTEGER;
      v_filas        NUMBER;
      -- 09/11/2009
      v_cempres      NUMBER;
   BEGIN
      -- BUG 11595 - 09/11/2009 - APD - Adaptación al nuevo módulo de siniestros
      SELECT cempres
        INTO v_cempres
        FROM seguros
       WHERE sseguro = psseguro;

      IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'MODULO_SINI'), 0) = 0 THEN
         BEGIN
            SELECT cgarant
              INTO w_cgarant
              FROM prodcaumotsin x
             WHERE x.ccausin = 4
               AND sproduc = psproduc;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               w_cgarant := 48;
         END;
      ELSE
         BEGIN
            SELECT cgarant
              INTO w_cgarant
              FROM sin_gar_causa
             WHERE ccausin = 4
               AND sproduc = psproduc;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               w_cgarant := 48;
         END;
      END IF;

      /*
      {convertimos las fechas a formato numerico}
      */
      w_fsinies := pfecha;
      w_fnotifi := pfecha;
      w_fecefe := TO_NUMBER(TO_CHAR(f_sysdate, 'YYYYMMDD'));
      w_fecval := pfecha;

      SELECT sgt_sesiones.NEXTVAL
        INTO w_sesion
        FROM DUAL;

      IF w_sesion IS NULL THEN
         ROLLBACK;
         RETURN 108418;
      END IF;

      /*
      { Insertamos los parametros genericos para el calculo de un seguro.}
      */
      w_error := graba_param(w_sesion, 'SESION', w_sesion);

      IF w_error <> 0 THEN
         RETURN 109843;
      END IF;

      w_error := graba_param(w_sesion, 'FECEFE', w_fecefe);

      IF w_error <> 0 THEN
         RETURN 109843;
      END IF;

      w_error := graba_param(w_sesion, 'FNOTIFI', w_fnotifi);

      IF w_error <> 0 THEN
         RETURN 109843;
      END IF;

      w_error := graba_param(w_sesion, 'FSINIES', w_fsinies);

      IF w_error <> 0 THEN
         RETURN 109843;
      END IF;

      w_error := graba_param(w_sesion, 'SSEGURO', psseguro);

      IF w_error <> 0 THEN
         RETURN 109843;
      END IF;

      w_error := graba_param(w_sesion, 'SPRODUC', psproduc);

      IF w_error <> 0 THEN
         RETURN 109843;
      END IF;

      w_error := graba_param(w_sesion, 'CACTIVI', 0);

      IF w_error <> 0 THEN
         RETURN 109843;
      END IF;

      w_error := graba_param(w_sesion, 'CGARANT', w_cgarant);

      IF w_error <> 0 THEN
         RETURN 109843;
      END IF;

      w_error := graba_param(w_sesion, 'CCAUSIN', 3);

      IF w_error <> 0 THEN
         RETURN 109843;
      END IF;

      w_error := graba_param(w_sesion, 'CMOTSIN', 0);

      IF w_error <> 0 THEN
         RETURN 109843;
      END IF;

      w_error := graba_param(w_sesion, 'FVALORA', w_fecval);

      IF w_error <> 0 THEN
         RETURN 109843;
      END IF;

      /*
      {Calculamos las formulas de la valoracion}
      */
      -- BUG 11595 - 03/11/2009 - APD - Adaptación al nuevo módulo de siniestros
      -- se añade la empresa al curso para saber si se deben utilizar las tablas nuevas
      -- o antiguas de siniestros
      FOR reg IN cur_campo(v_cempres) LOOP   --
         BEGIN
            SELECT formula
              INTO w_formula
              FROM sgt_formulas
             WHERE clave = reg.clave;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN 108423;
            WHEN OTHERS THEN
               RETURN 108423;
         END;

         -- {Cargo parametros predefinidos}
         -- RSC 09/06/2008 Tarea 5507 Utilización de bind variables
         FOR term IN cur_termino(reg.clave) LOOP
            BEGIN
               IF (term.parametro <> 'IVALSIN'
                   AND term.parametro <> 'ICAPRIS') THEN
                  -- {Se esta calculando en este momento}
                  BEGIN
                     SELECT 'BEGIN SELECT ' || tcampo || ' INTO :RETORNO  FROM ' || ttable
                            || ' WHERE ' || twhere || ' ; END;'
                       INTO w_xs
                       FROM sgt_carga_arg_prede
                      WHERE termino = term.parametro
                        AND ttable IS NOT NULL
                        AND cllamada = DECODE(ptablas, 'SOL', 'SOLICITUDES', 'GENERICO');
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        SELECT 'BEGIN SELECT ' || tcampo || ' INTO :RETORNO  FROM ' || ttable
                               || ' WHERE ' || twhere || ' ; END;'
                          INTO w_xs
                          FROM sgt_carga_arg_prede
                         WHERE termino = term.parametro
                           AND ttable IS NOT NULL
                           AND cllamada = 'GENERICO';
                  END;

                  IF DBMS_SQL.is_open(v_cursor) THEN
                     DBMS_SQL.close_cursor(v_cursor);
                  END IF;

                  v_cursor := DBMS_SQL.open_cursor;
                  DBMS_SQL.parse(v_cursor, w_xs, DBMS_SQL.native);
                  DBMS_SQL.bind_variable(v_cursor, ':RETORNO', w_retorno);

                  IF INSTR(w_xs, ':FECEFE') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':FECEFE', w_fecefe);
                  END IF;

                  IF INSTR(w_xs, ':FSINIES') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':FSINIES', w_fsinies);
                  END IF;

                  IF INSTR(w_xs, ':FECHA') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':FECHA', w_fsinies);
                  END IF;

                  IF INSTR(w_xs, ':FNOTIFI') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':FNOTIFI', w_fnotifi);
                  END IF;

                  IF INSTR(w_xs, ':SSEGURO') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':SSEGURO', psseguro);
                  END IF;

                  IF INSTR(w_xs, ':SPRODUC') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':SPRODUC', psproduc);
                  END IF;

                  IF INSTR(w_xs, ':CACTIVI') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':CACTIVI', 0);
                  END IF;

                  IF INSTR(w_xs, ':CGARANT') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':CGARANT', w_cgarant);
                  END IF;

                  IF INSTR(w_xs, ':NRIESGO') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':NRIESGO', 1);
                  END IF;

                  --
                  BEGIN
                     v_filas := DBMS_SQL.EXECUTE(v_cursor);
                     DBMS_SQL.variable_value(v_cursor, 'RETORNO', w_retorno);

                     IF DBMS_SQL.is_open(v_cursor) THEN
                        DBMS_SQL.close_cursor(v_cursor);
                     END IF;

                     IF w_retorno IS NULL THEN
                        RETURN 103135;
                     ELSE
                        w_error := graba_param(w_sesion, term.parametro, w_retorno);

                        IF w_error <> 0 THEN
                           RETURN 109843;
                        END IF;
                     END IF;
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_tab_error(f_sysdate, getuser, 'PK_RENTAS', NULL,
                                    'Error al evaluar la formula', SQLERRM);
                        p_tab_error(f_sysdate, getuser, 'PK_RENTAS', NULL, 'formula', w_xs);

                        IF DBMS_SQL.is_open(v_cursor) THEN
                           DBMS_SQL.close_cursor(v_cursor);
                        END IF;

                        w_error := graba_param(w_sesion, term.parametro, 0);

                        IF w_error <> 0 THEN
                           RETURN 109843;
                        END IF;
                  END;
               END IF;
            --
            EXCEPTION
               WHEN OTHERS THEN
                  w_xs := NULL;
            END;
         END LOOP;

         -- RSC 09/06/2008
         --select DECODE(ptablas,'SOL','SOLICITUDES','GENERICO') into x_cllamada from dual;
         --w_error := PAC_CALCULO_FORMULAS.calcula_terminos (w_sesion, reg.clave, x_cllamada, 0);

         --
         w_val := pk_formulas.eval(w_formula, w_sesion);

         IF (w_val IS NULL
             OR w_val < 0) THEN
            RETURN 103135;
         ELSE
            IF reg.ccampo = 'ICAPRIS' THEN
               w_error := graba_param(w_sesion, 'ICAPRIS', w_val);
               x_icapris := w_val;

               IF w_error <> 0 THEN
                  RETURN 109843;
               END IF;
            END IF;
         END IF;
      END LOOP;

      -- Borro sgt_parms_transitorios
      w_error := borra_param(w_sesion);
      RETURN x_icapris;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pk_rentas.f_calc_rescate', 1, 'error no controlado',
                     SQLERRM);
         RETURN -1;
   END f_calc_rescate;

   --JRH 08/2008
   --Insertamos una versión del sreceren PAGOSRENTA en  HISPAGOSRENTA para hacer auditoría
   --Devuelve 0 si todo ha ido bien y <>0 en caso contrario
   FUNCTION insertar_historico(psrecren IN NUMBER)
      RETURN NUMBER IS
      num_err        NUMBER;
      v_numsec       NUMBER;
   BEGIN
      SELECT MAX(numseq)
        INTO v_numsec
        FROM hispagosrenta
       WHERE srecren = psrecren;

      v_numsec := NVL(v_numsec, 0) + 1;

      -- Bug 18286 - APD - 26/04/2011 - Se añaden los campos nsinies, ntramit, ctipdes, ctipban
      INSERT INTO hispagosrenta
                  (srecren, numseq, fecha, usuario, sseguro, sperson, ffecefe, ffecpag,
                   ffecanu, cmotanu, isinret, pretenc, iretenc, iconret, ibase, pintgar,
                   pparben, nctacor, nremesa, fremesa, proceso, ctipban, nsinies, ntramit,
                   ctipdes)
         SELECT srecren, v_numsec, f_sysdate, f_user, sseguro, sperson, ffecefe, ffecpag,
                ffecanu, cmotanu, isinret, pretenc, iretenc, iconret, ibase, pintgar, pparben,
                nctacor, nremesa, fremesa, proceso, ctipban, nsinies, ntramit, ctipdes
           FROM pagosrenta
          WHERE srecren = psrecren;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pk_rentas.insertar_historico', 1,
                     'error no controlado', SQLERRM);
         RETURN 180882;
   END insertar_historico;

   FUNCTION f_haypagaextra(psproduc IN NUMBER, pmesextra IN VARCHAR2)
      RETURN NUMBER IS
      vvalor         VARCHAR2(50);
   BEGIN
      IF pmesextra <> 1 THEN
         SELECT SUBSTR(nmesextra, INSTR(nmesextra, '|', 1, pmesextra - 1) + 1,
                       LENGTH(pmesextra))
           INTO vvalor
           FROM producto_ren
          WHERE sproduc = psproduc
            AND cclaren = 0;
      ELSE
         SELECT SUBSTR(nmesextra, 1, 1)
           INTO vvalor
           FROM producto_ren
          WHERE sproduc = psproduc
            AND cclaren = 0;
      END IF;

      IF vvalor = pmesextra THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, NVL(f_user, f_user), 'pk_rentas.f_HayPagaExtra', 1,
                     'Error no controlat. Params: psproduc:' || psproduc || ' pmesextra:'
                     || pmesextra,
                     SQLERRM);
         RETURN NULL;
   END f_haypagaextra;

   FUNCTION f_llenarnmesesextra(
      penero IN NUMBER,
      pfebrero IN NUMBER,
      pmarzo IN NUMBER,
      pabril IN NUMBER,
      pmayo IN NUMBER,
      pjunio IN NUMBER,
      pjulio IN NUMBER,
      pagosto IN NUMBER,
      pseptiembre IN NUMBER,
      poctubre IN NUMBER,
      pnoviembre IN NUMBER,
      pdiciembre IN NUMBER)
      RETURN VARCHAR2 IS
      vcadena        VARCHAR2(50);
   BEGIN
      IF penero = 1 THEN
         vcadena := vcadena || 1 || '|';
      ELSE
         vcadena := vcadena || '|';
      END IF;

      IF pfebrero = 1 THEN
         vcadena := vcadena || 2 || '|';
      ELSE
         vcadena := vcadena || '|';
      END IF;

      IF pmarzo = 1 THEN
         vcadena := vcadena || 3 || '|';
      ELSE
         vcadena := vcadena || '|';
      END IF;

      IF pabril = 1 THEN
         vcadena := vcadena || 4 || '|';
      ELSE
         vcadena := vcadena || '|';
      END IF;

      IF pmayo = 1 THEN
         vcadena := vcadena || 5 || '|';
      ELSE
         vcadena := vcadena || '|';
      END IF;

      IF pjunio = 1 THEN
         vcadena := vcadena || 6 || '|';
      ELSE
         vcadena := vcadena || '|';
      END IF;

      IF pjulio = 1 THEN
         vcadena := vcadena || 7 || '|';
      ELSE
         vcadena := vcadena || '|';
      END IF;

      IF pagosto = 1 THEN
         vcadena := vcadena || 8 || '|';
      ELSE
         vcadena := vcadena || '|';
      END IF;

      IF pseptiembre = 1 THEN
         vcadena := vcadena || 9 || '|';
      ELSE
         vcadena := vcadena || '|';
      END IF;

      IF poctubre = 1 THEN
         vcadena := vcadena || 10 || '|';
      ELSE
         vcadena := vcadena || '|';
      END IF;

      IF pnoviembre = 1 THEN
         vcadena := vcadena || 11 || '|';
      ELSE
         vcadena := vcadena || '|';
      END IF;

      IF pdiciembre = 1 THEN
         vcadena := vcadena || 12;
      ELSE
         vcadena := vcadena || '|';
      END IF;

      RETURN vcadena;
   END f_llenarnmesesextra;

   -- NMM.24735.03/2013.i
   -- Funció que omple els imports dels mesos que tenen paga extra
   FUNCTION f_ompleimesosextra(
      pgener IN NUMBER,
      pfebrer IN NUMBER,
      pmars IN NUMBER,
      pabril IN NUMBER,
      pmaig IN NUMBER,
      pjuny IN NUMBER,
      pjuliol IN NUMBER,
      pagost IN NUMBER,
      psetembre IN NUMBER,
      poctubre IN NUMBER,
      pnovembre IN NUMBER,
      pdesembre IN NUMBER)
      RETURN VARCHAR2 IS
      vcadena        VARCHAR2(50);
   BEGIN
      IF pgener <> 0 THEN
         vcadena := vcadena || pgener || '|';
      ELSE
         vcadena := vcadena || '|';
      END IF;

      IF pfebrer <> 0 THEN
         vcadena := vcadena || pfebrer || '|';
      ELSE
         vcadena := vcadena || '|';
      END IF;

      IF pmars <> 0 THEN
         vcadena := vcadena || pmars || '|';
      ELSE
         vcadena := vcadena || '|';
      END IF;

      IF pabril <> 0 THEN
         vcadena := vcadena || pabril || '|';
      ELSE
         vcadena := vcadena || '|';
      END IF;

      IF pmaig <> 0 THEN
         vcadena := vcadena || pmaig || '|';
      ELSE
         vcadena := vcadena || '|';
      END IF;

      IF pjuny <> 0 THEN
         vcadena := vcadena || pjuny || '|';
      ELSE
         vcadena := vcadena || '|';
      END IF;

      IF pjuliol <> 0 THEN
         vcadena := vcadena || pjuliol || '|';
      ELSE
         vcadena := vcadena || '|';
      END IF;

      IF pagost <> 0 THEN
         vcadena := vcadena || pagost || '|';
      ELSE
         vcadena := vcadena || '|';
      END IF;

      IF psetembre <> 0 THEN
         vcadena := vcadena || psetembre || '|';
      ELSE
         vcadena := vcadena || '|';
      END IF;

      IF poctubre <> 0 THEN
         vcadena := vcadena || poctubre || '|';
      ELSE
         vcadena := vcadena || '|';
      END IF;

      IF pnovembre <> 0 THEN
         vcadena := vcadena || pnovembre || '|';
      ELSE
         vcadena := vcadena || '|';
      END IF;

      IF pdesembre <> 0 THEN
         vcadena := vcadena || pdesembre || '|';
      ELSE
         vcadena := vcadena || '|';
      END IF;

      RETURN vcadena;
   END f_ompleimesosextra;

   -- NMM.24735.03/2013.f

   /* JGM - Bug --10297 -- F_get_ProdRentas
   Nueva función de la capa lógica que devolverá los productos parametrizados con prestación rentas.

   Parámetros
   1. pcempres IN NUMBER
   2. pcramo IN NUMBER
   3. psproduc IN NUMBER
   4. pidioma IN NUMBER
   5. psquery OUT VARCHAR2*/
   FUNCTION f_get_prodrentas(
      pcempres IN NUMBER,
      pcramo IN VARCHAR2,
      psproduc IN NUMBER,   -- Sequence del producto
      pcidioma IN NUMBER,   -- Idioma
      psquery OUT VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      psquery :=
         'SELECT p.sproduc, f_desproducto_t(P.cramo,P.cmodali,P.ctipseg,P.ccolect,1,'
         || TO_CHAR(pcidioma) || ') TTITULO '
         || 'FROM producto_ren N, productos P, codiram R '
         || 'WHERE N.sproduc = P.sproduc and ' || 'P.cramo = R.cramo and ' || 'R.cempres = '
         || TO_CHAR(pcempres) || ' and ' || 'R.cramo= NVL(' || NVL(TO_CHAR(pcramo), 'NULL')
         || ',R.cramo) and ' || 'P.sproduc= NVL(' || NVL(TO_CHAR(psproduc), 'NULL')
         || ',P.sproduc)';
      RETURN 0;
   END;

   /*************************************************************************
      Función que seleccionará información sobre los pagos renta dependiendo de los parámetros de entrada
      param in pcempres    : Id. de empresa
      param in pcramo      : Id. de ramo
      param in psproduc    : Id. de producto
      param in pnpoliza    : Id. de póliza
      param in pncertif    : Num. de certificado
      param in pcidioma    : Cod. idioma
      param out psquery    : Query a ejecutar
      return               : 0 -> Todo correcto
                             1 -> Se ha producido un error

     Bug 10499  02/07/2009  AMC
   *************************************************************************/
   FUNCTION f_get_consultapagos(
      pcempres IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pcidioma IN NUMBER,
      psquery OUT VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      psquery :=
         'select s.ncertif, s.npoliza, f_nombre(ff_sperson_tomador(s.sseguro),1,s.cagente) tomad,'
         || ' f_nombre(r.sperson, 1, s.cagente) asegur, s.fefecto,' || ' ff_desvalorfijo (61,'
         || pcidioma || ', s.csituac) situac,s.sseguro'
         || ' from seguros s, riesgos R, seguros_ren G, pagosrenta P'
         || ' where r.sseguro = s.sseguro'
         || ' and r.nriesgo = (select min(nriesgo) from riesgos where sseguro = r.sseguro)'
         || ' and s.cempres =' || pcempres || ' and s.sproduc = NVL('
         || NVL(TO_CHAR(psproduc), 'NULL') || ', s.sproduc)' || ' and s.cramo = NVL('
         || NVL(TO_CHAR(pcramo), 'NULL') || ', s.cramo)' || ' and s.npoliza = NVL('
         || NVL(TO_CHAR(pnpoliza), 'NULL') || ', s.npoliza)' || ' and s.ncertif = NVL('
         || NVL(TO_CHAR(pncertif), 'NULL') || ', s.ncertif)' || ' and s.sseguro = G.sseguro'
         || ' and s.sseguro = P.sseguro' || ' and 1 = (SELECT COUNT(*)' || ' FROM PRODUCTOS'
         || ' WHERE CRAMO = s.CRAMO' || ' AND CMODALI = s.CMODALI'
         || ' AND CCOLECT = s.CCOLECT' || ' AND CTIPSEG = s.CTIPSEG' || ' AND CPRPROD = 1)'
         || ' and P.srecren = (select max(srecren) from pagosrenta where sseguro = P.sseguro)';
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PK_RENTAS.F_get_ConsultaPagos', 1,
                     'ERROR NO CONTROLADO', SQLERRM);
         RETURN 1;
   END f_get_consultapagos;

   /*************************************************************************
      Función que recuperará la edad de un asegurado
      param in psseguro      : Id. de seguro
      param in pnriesgo      : Id. de riesgo
      param out pedad        : Edad asegurado
      return                 : 0 -> Todo correcto
                               1 -> Se ha producido un error

     Bug 10499  02/07/2009  AMC
   *************************************************************************/
   FUNCTION f_edadaseg(psseguro IN NUMBER, pnriesgo IN NUMBER, pedad OUT NUMBER)
      RETURN NUMBER IS
      vsperson       NUMBER;
   BEGIN
      BEGIN
         SELECT sperson
           INTO vsperson
           FROM riesgos
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            BEGIN
               SELECT sperson
                 INTO vsperson
                 FROM asegurados
                WHERE sseguro = psseguro;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  RETURN 109617;   --Persona no trobada
            END;
      END;

      pedad := fedadaseg(0, vsperson, TO_CHAR(f_sysdate, 'YYYYMMDD'), 2, 2);
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PK_RENTAS.f_edadaseg', 1, 'ERROR NO CONTROLADO',
                     SQLERRM);
         RETURN 1;
   END f_edadaseg;

   /*************************************************************************
      Función que recuperará los datos de renta de una póliza
      param in psseguro      : Id. de seguro
      param in pcidioma      : Cod. de idioma
      param out psquery      : Query a ejecutar
      return                 : 0 -> Todo correcto
                               1 -> Se ha producido un error

     Bug 10499  02/07/2009  AMC
   *************************************************************************/
   FUNCTION f_get_dat_renta(psseguro IN NUMBER, pcidioma IN NUMBER, psquery OUT VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      psquery :=
         'select R.sseguro, ibruren, add_months(fintgar,(nduraint*12)) fdura,'
         || ' ptipoint, P.pinttec, R.f1paren, R.fppren,' || ' R.fuparen, ff_desvalorfijo(17,'
         || pcidioma || ', R.cforpag) forpag, R.ffinren,'
         || ' M.tmotmov, A.fcompra, A.ipreadq, A.tactivo'
         || ' from seguros_ren R, productos P, seguros S, motmovseg M, activos A, seguros_act T'
         || ' where R.sseguro = S.sseguro' || ' and S.sproduc = P.sproduc'
         || ' and R.cmotivo = M.cmotmov(+)' || ' and  M.cidioma(+) =' || pcidioma
         || ' and A.sactivo(+) = T.sactivo' || ' and T.sseguro(+) = R.sseguro'
         || ' and R.sseguro =' || psseguro;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PK_RENTAS.F_get_dat_renta', 1, 'ERROR NO CONTROLADO',
                     SQLERRM);
         RETURN 1;
   END f_get_dat_renta;

/*************************************************************************
      Función que recuperará los pagos renta de una póliza
      param in psseguro      : Id. de seguro
      param in pcidioma      : Cod. de idioma
      param out psquery      : Query a ejecutar
      return                 : 0 -> Todo correcto
                               1 -> Se ha producido un error

     Bug 10499  02/07/2009  AMC
   *************************************************************************/
   FUNCTION f_get_pagos_renta(psseguro IN NUMBER, pcidioma IN NUMBER, psquery OUT VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      psquery :=
         'select P.srecren, ffecefe, ffecpag, isinret,' || ' ff_desvalorfijo(230,' || pcidioma
         || ', cestrec) estado,' || ' f_nombre(sperson, 1, cagente) benefi'
         || ' from pagosrenta P, seguros S, movpagren M' || ' where S.sseguro = ' || psseguro
         || ' and P.sseguro = S.sseguro' || ' and P.srecren = M.srecren'
         || ' and M.smovpag = (select max(smovpag) from movpagren where srecren = M.srecren)';
      --Bug.: 12914 - 20/04/2010 - ICV - Reimprimir listados de pagos de rentas
      psquery := psquery || ' order by p.FFECPAG desc ';
      --Fin Bug.: 12914
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PK_RENTAS.F_get_pagos_renta', 1,
                     'ERROR NO CONTROLADO', SQLERRM);
         RETURN 1;
   END f_get_pagos_renta;

   /*************************************************************************
      Función que recuperará el detalle del pago renta de una póliza
      param in psseguro      : Id. de seguro
      param in psrecren      : Id del recibo del pago de la renta
      param in pcidioma      : Cod. de idioma
      param out psquery      : Query a ejecutar
      return                 : 0 -> Todo correcto
                               1 -> Se ha producido un error

     Bug 10499  02/07/2009  AMC
   *************************************************************************/
   FUNCTION f_get_detpago_renta(
      psseguro IN NUMBER,
      psrecren IN NUMBER,
      pcidioma IN NUMBER,
      psquery OUT VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      psquery :=
         'select P.srecren, ffecefe, ffecpag, isinret,' || ' ff_desvalorfijo(230,' || pcidioma
         || ', cestrec) estado,' || ' f_nombre(sperson, 1, cagente) benefi,'
         || ' P.iconret, P.iretenc, P.nctacor, P.ibase, P.pretenc, P.ffecanu,'
         || ' ff_desvalorfijo(690,' || pcidioma || ', cmotanu) motanul, P.fremesa,P.nremesa'
         || ' from pagosrenta P, seguros S, movpagren M' || ' where S.sseguro = ' || psseguro
         || ' and P.sseguro = S.sseguro' || ' and P.srecren = M.srecren'
         || ' and M.smovpag = (select max(smovpag) from movpagren where srecren = M.srecren)'
         || ' and P.srecren = ' || psrecren;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PK_RENTAS.F_get_detpago_renta', 1,
                     'ERROR NO CONTROLADO', SQLERRM);
         RETURN 1;
   END f_get_detpago_renta;

   /*************************************************************************
      Función que recuperará el detalle del pago renta de una póliza
      param in psrecren      : Id del recibo del pago de la renta
      param in pcidioma      : Cod. de idioma
      param out psquery      : Query a ejecutar
      return                 : 0 -> Todo correcto
                               1 -> Se ha producido un error

     Bug 10499  02/07/2009  AMC
   *************************************************************************/
   FUNCTION f_get_dat_polren(psrecren IN NUMBER, pcidioma IN NUMBER, psquery OUT VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      psquery := 'select S.npoliza, S.fefecto fefectopol,'
                 || ' f_nombre(ff_sperson_tomador(s.sseguro),1,s.cagente) tomador,'
                 || ' f_nombre(P.sperson, 1, cagente) benefi, P.iconret, P.ffecpag, P.srecren'
                 || ' from pagosrenta P, seguros S' || ' where P.srecren = ' || psrecren
                 || ' and P.sseguro = S.sseguro';
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PK_RENTAS.F_get_dat_polren', 1,
                     'ERROR NO CONTROLADO', SQLERRM);
         RETURN 1;
   END f_get_dat_polren;

/*************************************************************************
      Función que recuperará los movimientos del recibo de un pago renta
      param in psrecren      : Id del recibo del pago de la renta
      param in pcidioma      : Cod. de idioma
      param out psquery      : Query a ejecutar
      return                 : 0 -> Todo correcto
                               1 -> Se ha producido un error

     Bug 10499  02/07/2009  AMC
   *************************************************************************/
   FUNCTION f_get_mov_recren(psrecren IN NUMBER, pcidioma IN NUMBER, psquery OUT VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      psquery := 'select M.smovpag, ff_desvalorfijo(230,' || pcidioma
                 || ', M.cestrec) estado,' || ' M.fmovini, M.fmovfin, M.fefecto'
                 || ' from movpagren M' || ' where M.srecren = ' || psrecren;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PK_RENTAS.F_get_mov_recren', 1,
                     'ERROR NO CONTROLADO', SQLERRM);
         RETURN 1;
   END f_get_mov_recren;

/*************************************************************************
      Función validará las fechas calculadas y las corregirá si es posible
      param in pfecha      : fecha a validar
      return               : fecha correcta

     Bug 0014658  03/06/2010  JGR  CRE998- Parametrizar día de pago en Rentas Irregulares
   *************************************************************************/
   FUNCTION f_valida_date(pfecha IN VARCHAR2)
      RETURN DATE IS
      vfecha         VARCHAR2(8) := LPAD(pfecha, 8, '0');
      vfecha_ok      DATE;
      vdd            VARCHAR2(2);
      vmm            VARCHAR2(2);
      vyy            VARCHAR2(4);
   BEGIN
      IF vfecha IS NOT NULL THEN
         vdd := SUBSTR(vfecha, 1, 2);
         vmm := SUBSTR(vfecha, 3, 2);
         vyy := SUBSTR(vfecha, 5, 4);

         IF vdd > '30'
            AND vmm IN('04', '06', '09', '11') THEN
            vdd := '30';
         ELSIF vdd > '28'
               AND vmm IN('02') THEN
            IF ADD_MONTHS(TO_DATE('0101' || vyy, 'ddmmyyyy'), 12)
               - TO_DATE('0101' || vyy, 'ddmmyyyy') = 366 THEN   --> BISIESTO
               vdd := '29';
            ELSE
               vdd := '28';
            END IF;
         ELSIF vdd = '00' THEN
            vdd := '01';
         END IF;

         BEGIN
            vfecha_ok := TO_DATE(vdd || vmm || vyy, 'DDMMYYYY');
         EXCEPTION
            WHEN OTHERS THEN
               vfecha_ok := NULL;
         END;
      ELSE
         vfecha_ok := NULL;
      END IF;

      RETURN vfecha_ok;
   END f_valida_date;

/*************************************************************************
      Funció que calcula el rendiment del capital mobiliari d'un rescat
      (Aquest funció realment la va afegir J.Ramiro)
      param in psseguro      : seguro
      param in pnpagos       : n.pagos
      param in prescat       : rescat
      param in pfecha        : data proces
      param in pnriesgo      : risc
      param in pcmotsin      : Indicamos si es rescate total o parcial , y el valor del rescate total en
      param in piresctot     : caso de que sea un parcial
      param in ptablas       : tablas
      return                 : 0 -> Todo correcto
                               1 -> Se ha producido un error
     Bug 0014658  03/06/2010  JGR  CRE998- Parametrizar día de pago en Rentas Irregulares
   *************************************************************************/
   FUNCTION f_rkm_rescate(
      psseguro IN NUMBER,
      pnpagos IN NUMBER,
      prescat IN NUMBER,
      pfecha IN NUMBER,
      pnriesgo IN NUMBER,
      -- BUG 14414-  06/2010 - JRH  - 0014414: CEM301 - RVI - Fiscalidad en rescates en pólizas a 2 cabezas
      pcmotsin IN NUMBER DEFAULT 4,   --Indicamos si es rescate total o parcial , y el valor del rescate total en
      piresctot IN NUMBER DEFAULT NULL,   --caso de que sea un parcial
      -- Fi BUG 14414-  06/2010 - JRH
      ptablas IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER IS
      --(JAS)12.04.07 - Cursor que, donada una pòlissa, agrupa els pagaments per dates d'efecte del pagament.
      CURSOR cur_pagos_pol(vcr_sseguro IN NUMBER) IS
         SELECT   SUM(p.isinret) isinret, TRUNC(p.ffecefe) ffecefe
             FROM pagosrenta p
            WHERE p.sseguro = vcr_sseguro
              AND pk_rentas.f_ult_estado_pago(p.srecren) = 1   --JRH Los pagados
         GROUP BY TRUNC(p.ffecefe);

      ineta          NUMBER;
      ibruta         NUMBER;
      iprima         NUMBER;
      ibruta_reducc  NUMBER;
      xsproduc       NUMBER;
      xpretenc       NUMBER;
      xpreducc       NUMBER;
      xerror         NUMBER;
      xanys          NUMBER;
      xfefecto       DATE;
      xcgarant       NUMBER;
      xcactivi       NUMBER;
      xfnacimi       DATE;
      pclaren        NUMBER;
      origen         NUMBER;
      numpag         NUMBER;
      pfrescat       DATE;
      xmuerto        NUMBER;
      xfmuerte       DATE;
      xcuantos       NUMBER;
      numaseg        NUMBER := 1;
      imprescate     NUMBER := prescat;
      vporcentparc   NUMBER;
      vfiscalidad    NUMBER;
      vsproduc       productos.sproduc%TYPE;
   BEGIN
      pfrescat := TO_DATE(pfecha, 'YYYYMMDD');

      IF pcmotsin = 5
         AND NVL(piresctot, 0) <> 0 THEN   --Proporción del rescate parcial para calcular el RCM
         vporcentparc := prescat / piresctot;
      ELSE
         vporcentparc := 1;
      END IF;

      -- Busquem l'import brut
      IF ptablas = 'SOL' THEN
         origen := 0;

         SELECT NVL(r.icapren, 0)
           INTO iprima   --JRH IMP Mirar si hay 2 y dividir por dos
           FROM solseguros_ren r
          WHERE ssolicit = psseguro;

         xfefecto := TRUNC(f_sysdate);
         xmuerto := 0;
         xfmuerte := NULL;

         SELECT sproduc
           INTO vsproduc   --JRH IMP Mirar si hay 2 y dividir por dos
           FROM solseguros
          WHERE ssolicit = psseguro;

         vfiscalidad := NVL(f_parproductos_v(vsproduc, 'FISCALIDAD_2_CABEZAS'), 0);

         IF vfiscalidad = 0 THEN
            BEGIN
               SELECT COUNT(*)
                 INTO xcuantos
                 FROM solasegurados asegurados
                WHERE asegurados.ssolicit = psseguro;
            END;

            SELECT COUNT(DISTINCT norden)
              INTO numaseg
              FROM solasegurados asegurados
             WHERE asegurados.ssolicit = psseguro;

            IF numaseg > 2 THEN
               numaseg := 2;
            END IF;
         ELSE
            numaseg := 1;
         END IF;
      ELSIF ptablas = 'EST' THEN
         origen := 1;

         SELECT NVL(r.icapren, 0)
           INTO iprima
           FROM estseguros_ren r
          WHERE sseguro = psseguro;

         SELECT s.fefecto, s.sproduc
           INTO xfefecto, vsproduc
           FROM estseguros s
          WHERE sseguro = psseguro;

         vfiscalidad := NVL(f_parproductos_v(vsproduc, 'FISCALIDAD_2_CABEZAS'), 0);

         IF vfiscalidad = 0 THEN
            xmuerto := 0;

            BEGIN
               SELECT ffecmue
                 INTO xfmuerte
                 FROM estassegurats asegurados
                WHERE asegurados.sseguro = psseguro
                  AND asegurados.ffecmue IS NOT NULL;
            END;

            BEGIN
               SELECT COUNT(*)
                 INTO xcuantos
                 FROM estassegurats asegurados
                WHERE asegurados.sseguro = psseguro
                  AND asegurados.ffecmue IS NOT NULL;
            END;

            SELECT COUNT(DISTINCT sperson)
              INTO numaseg
              FROM estassegurats asegurados
             WHERE asegurados.sseguro = psseguro
               AND ffecfin IS NOT NULL;

            IF numaseg > 2 THEN
               numaseg := 2;
            END IF;
         ELSE
            SELECT COUNT(DISTINCT sperson)
              INTO numaseg
              FROM estassegurats
             WHERE estassegurats.sseguro = psseguro
               AND norden = 1
               AND estassegurats.ffecmue IS NOT NULL;

            IF numaseg = 1 THEN
               numaseg := 0;   --El rcm vale 0
            ELSE
               numaseg := 1;
            END IF;
         END IF;
      ELSE
         origen := 2;

         SELECT NVL(r.icapren, 0)
           INTO iprima
           FROM seguros_ren r
          WHERE sseguro = psseguro;

         SELECT s.fefecto, s.sproduc
           INTO xfefecto, vsproduc
           FROM seguros s
          WHERE sseguro = psseguro;

         vfiscalidad := NVL(f_parproductos_v(vsproduc, 'FISCALIDAD_2_CABEZAS'), 0);

         IF vfiscalidad = 0 THEN
            IF pac_rescates.f_vivo_o_muerto(psseguro, 2, pfrescat) > 0
               AND pac_rescates.f_vivo_o_muerto(psseguro, 1, pfrescat) > 0 THEN
               xmuerto := 1;

               BEGIN
                  SELECT ffecmue
                    INTO xfmuerte
                    FROM asegurados
                   WHERE asegurados.sseguro = psseguro
                     AND asegurados.ffecmue IS NOT NULL;
               END;
            ELSE
               xmuerto := 0;
               xfmuerte := NULL;
            END IF;

            xcuantos := pac_rescates.f_vivo_o_muerto(psseguro, 1, pfrescat);

            SELECT COUNT(DISTINCT sperson)
              INTO numaseg
              FROM asegurados
             WHERE asegurados.sseguro = psseguro;

            IF numaseg > 2 THEN
               numaseg := 2;
            END IF;
         ELSE
            SELECT COUNT(DISTINCT sperson)
              INTO numaseg
              FROM asegurados
             WHERE asegurados.sseguro = psseguro
               AND norden = 1
               AND asegurados.ffecmue IS NOT NULL;

            IF numaseg = 1 THEN
               numaseg := 0;   --El rcm vale 0
            ELSE
               numaseg := 1;
            END IF;
         END IF;
      END IF;

      IF numaseg = 0 THEN
         RETURN 0;
      END IF;

      ibruta := f_buscarentabruta(1, psseguro, pfecha, origen, 'R');

      IF pnpagos IS NOT NULL THEN
         numpag := pnpagos;
      ELSE
         BEGIN
            SELECT COUNT(srecren)
              INTO numpag
              FROM pagosrenta
             WHERE sseguro = psseguro
               AND pk_rentas.f_ult_estado_pago(pagosrenta.srecren) = 1;   --JRH Los pagados;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN NULL;
         END;
      END IF;

      IF ptablas IN('SOL', 'EST') THEN
         xpreducc := f_buscaprduccion(1, psseguro, TO_CHAR(xfefecto, 'yyyymmdd'), origen);
         ineta := prescat - iprima / numaseg + (ibruta * numpag) * xpreducc /(100 * numaseg);
      ELSE
         --I(JAS)12.04.07 - Modifiquem el càlcul del rendiment del capital mobiliari d'un rescat en funció de si és tracta d'un cas "real" o no.
         --Fins ara es calculava sempre igual en tots els casos. En el cas "real", per cada pagament realitzat cal aplicar un porcentatge
         --de reducció diferent en funció de la data d'efecte del pagament (i no un únic porcentage de reducció per tots els pagaments en funció
         --de la data d'efecte de la pòlissa). D'aquesta manera, cada pagament pot tenir la seva fiscalitat en funció de la data d'efecte d'aquest
         ibruta_reducc := 0;
         ineta := 0;

         -- Cursor amb el número de pagaments de la pòlissa, realitzats en cada data efecte diferent (a efectes pràctics per cada any).
         FOR cur IN cur_pagos_pol(psseguro) LOOP
            -- Càlcul del percentage de reducció aplicable a cada pagament en funció de la seva data d'efecte.
            xpreducc := f_buscaprduccion(1, psseguro, TO_CHAR(cur.ffecefe, 'yyyymmdd'),
                                         origen);

            -- Acumulació del import brut reduït, aplicant a cada pagament, el seu percentatge de reducció.
            --Segons la data de fallec. posem un 50 o 100% (perque aquest % la l'apliquem a
            --l'hora de generar la renta
            IF xfmuerte IS NOT NULL THEN
               IF cur.ffecefe < xfmuerte THEN
                  ibruta_reducc := ibruta_reducc
                                   + (cur.isinret *(100 - xpreducc) / 100) / numaseg;
               ELSE
                  ibruta_reducc := ibruta_reducc +(cur.isinret *(100 - xpreducc) / 100);
               END IF;
            ELSE
               ibruta_reducc := ibruta_reducc + (cur.isinret *(100 - xpreducc) / 100)
                                                / numaseg;
               imprescate := prescat / numaseg;
            END IF;

            --Aqui el isinret
            ineta := ineta + cur.isinret;
         END LOOP;

         IF xfmuerte IS NULL THEN
            imprescate := prescat / numaseg;
         END IF;

         ineta := imprescate + vporcentparc *(ineta / numaseg)
                  - vporcentparc *(iprima / numaseg) - vporcentparc * ibruta_reducc;
      --F(JAS)
      END IF;

      RETURN ineta;
   END f_rkm_rescate;

-- BUG 16217 - 09/2010 - JRH  -  Cuadro de provisiones
    /*************************************************************************

       f_gen_evoluprovmatseg

       Cálculo del cuadro de rescates

       param in psseguro          : Sseguro
       param in pnmovimi          : Número movimiento
       param in  ptablas : 1 EST, 2 SEG
       return                     : 0 o diferente de 0 si hay error
   *************************************************************************/
   FUNCTION f_gen_evoluprovmatseg(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      ptablas IN NUMBER DEFAULT 2)
      RETURN NUMBER IS
      vfechaini      DATE;
      vfechafin      DATE;
      vfecharef      DATE;
      vsproduc       seguros.sproduc%TYPE;
      vfefecto       seguros.fefecto%TYPE;
      vcactivi       seguros.cactivi%TYPE;
      vclave         sgt_formulas.clave%TYPE;
      vcgarant       garanpro.cgarant%TYPE;
      vfrevant       DATE;
      vfrevisio      DATE;
      vfecvto        DATE;
      vtipo          NUMBER;
      vnumerr        NUMBER;
      vtraza         NUMBER;
      vvalor         NUMBER;
      v_anyos        NUMBER;
      v_contador     NUMBER;
      verrorobj      EXCEPTION;
      vtext          VARCHAR2(100);
      vnmovimi       NUMBER;
      vcapfall       NUMBER;
      vclave2        NUMBER;

      PROCEDURE insert_evoluprovmatseg(
         porigen IN NUMBER,
         psseguro IN evoluprovmatseg.sseguro%TYPE,
         pnmovimi IN evoluprovmatseg.nmovimi%TYPE,
         pnanyo IN evoluprovmatseg.nanyo%TYPE,
         pfprovmat IN evoluprovmatseg.fprovmat%TYPE,
         piprovmat IN evoluprovmatseg.iprovmat%TYPE,
         picapfall IN evoluprovmatseg.icapfall%TYPE,
         pprescate IN evoluprovmatseg.prescate%TYPE,
         ppinttec IN evoluprovmatseg.pinttec%TYPE,
         piprovest IN evoluprovmatseg.iprovest%TYPE,
         pcrevisio IN evoluprovmatseg.crevisio%TYPE,
         pprima IN NUMBER) IS
         v_sproduc      seguros.sproduc%TYPE;
         v_xpenali      NUMBER;
         v_xtippenali   NUMBER;
         vnum_err       NUMBER;
         v_nduraci      NUMBER;
         v_pinttec      NUMBER;
         psseguroini    NUMBER;
      BEGIN
         --dbms_output.put_line('41');
         IF porigen = 1 THEN
            SELECT sproduc, nduraci, ssegpol
              INTO v_sproduc, v_nduraci, psseguroini
              FROM estseguros
             WHERE sseguro = psseguro;

--dbms_output.put_line('42');
         -- EST
            DELETE FROM estevoluprovmatseg
                  WHERE sseguro = psseguro
                    AND nmovimi = pnmovimi
                    AND nanyo = pnanyo;

--dbms_output.put_line('43');
         --vnum_err := f_penalizacion(3, pnanyo, v_sproduc, psseguro, pfprovmat, v_xpenali,
          --                          v_xtippenali, 'EST', 2);
            v_xpenali := calc_rescates.fporcenpenali(-1, psseguro,
                                                     TO_CHAR(pfprovmat, 'YYYYMMDD'), 4, 1);
            v_pinttec := pac_inttec.ff_int_seguro('EST', psseguro, pfprovmat);

            --ff_int_producto(v_sproduc, 2, pfprovmat, v_nduraci);

            -- v_pinttec := pac_inttec

            --dbms_output.put_line('44');
            INSERT INTO estevoluprovmatseg
                        (sseguro, nmovimi, nanyo, fprovmat, iprovmat, icapfall,
                         prescate, pinttec, iprovest,
                         ivalres, iprima)
                 VALUES (psseguro, pnmovimi, pnanyo, pfprovmat, piprovmat, picapfall,
                         v_xpenali, v_pinttec, piprovest,
                         ROUND((piprovmat -((v_xpenali / 100) * piprovmat)), 2), pprima);
         ELSE
            SELECT sproduc, nduraci
              INTO v_sproduc, v_nduraci
              FROM seguros
             WHERE sseguro = psseguro;

--dbms_output.put_line('45');
            DELETE FROM evoluprovmatseg
                  WHERE sseguro = psseguro
                    AND nmovimi = pnmovimi
                    AND nanyo = pnanyo;

--dbms_output.put_line('46');
         --vnum_err := f_penalizacion(3, pnanyo, v_sproduc, psseguro, pfprovmat, v_xpenali,
          --                          v_xtippenali, 'SEG', 2);
            v_xpenali := calc_rescates.fporcenpenali(-1, psseguro,
                                                     TO_CHAR(pfprovmat, 'YYYYMMDD'), 4);
                --     dbms_output.put_line('47');
            --    v_pinttec := pac_inttec.ff_int_producto(v_sproduc, 2, pfprovmat, v_nduraci);
            v_pinttec := pac_inttec.ff_int_seguro('SEG', psseguro, pfprovmat);

--dbms_output.put_line('48');
            INSERT INTO evoluprovmatseg
                        (sseguro, nmovimi, nanyo, fprovmat, iprovmat, icapfall,
                         prescate, pinttec, iprovest,
                         ivalres, iprima)
                 VALUES (psseguro, pnmovimi, pnanyo, pfprovmat, piprovmat, picapfall,
                         v_xpenali, v_pinttec, piprovest,
                         ROUND((piprovmat -((v_xpenali / 100) * piprovmat)), 2), pprima);
         --    dbms_output.put_line('49');
         END IF;
      END insert_evoluprovmatseg;

      -- Fin Bug 14598
      PROCEDURE insert_evolu(
         porigen IN NUMBER,
         psseguro IN evoluprovmatseg.sseguro%TYPE,
         pnmovimi IN evoluprovmatseg.nmovimi%TYPE,
         pnanyo IN OUT NUMBER,
         pfecha_inicio_mes IN DATE,
         pfecharev IN DATE,
         psaldomes IN NUMBER,
         paportcons IN NUMBER,
         picapfall IN NUMBER) IS
         v_contador     NUMBER;
      BEGIN
         IF porigen = 1 THEN
            SELECT COUNT(*)
              INTO v_contador
              FROM estevoluprovmatseg
             WHERE sseguro = psseguro
               AND nmovimi = pnmovimi
               AND nanyo = pnanyo;
         -- dbms_output.put_line('21');
         ELSE
            SELECT COUNT(*)
              INTO v_contador
              FROM evoluprovmatseg
             WHERE sseguro = psseguro
               AND nmovimi = pnmovimi
               AND nanyo = pnanyo;
         -- dbms_output.put_line('22');
         END IF;

         IF v_contador = 0 THEN
            --IF TO_NUMBER(TO_CHAR(pfecha_inicio_mes, 'MM')) =
              --                                             TO_NUMBER(TO_CHAR(pfecharev, 'MM'))
             --  AND TO_NUMBER(TO_CHAR(pfecha_inicio_mes, 'YYYY')) <=
              --                                            TO_NUMBER(TO_CHAR(pfecharev, 'YYYY')) THEN
               -- dbms_output.put_line('23');
            insert_evoluprovmatseg(porigen, psseguro, pnmovimi, pnanyo, pfecha_inicio_mes,
                                   psaldomes, picapfall, NULL, NULL, NULL, NULL, paportcons);
           --pnanyo := pnanyo + 1;
         --  END IF;
         END IF;
      END insert_evolu;
   BEGIN
      vtraza := 0;

      IF ptablas = 1 THEN
         vtraza := 11;

         SELECT sproduc, fefecto, cactivi, fvencim
           INTO vsproduc, vfefecto, vcactivi, vfecvto
           FROM estseguros
          WHERE sseguro = psseguro;

         SELECT frevant, frevisio
           INTO vfrevant, vfrevisio
           FROM estseguros_aho
          WHERE sseguro = psseguro;

         IF pnmovimi IS NOT NULL THEN
            vnmovimi := pnmovimi;
         ELSE
            SELECT MAX(nmovimi)
              INTO vnmovimi
              FROM estdetmovseguro
             WHERE sseguro = psseguro;
         END IF;

         vtipo := 1;
      ELSE
         vtraza := 12;

         SELECT sproduc, fefecto, cactivi, fvencim
           INTO vsproduc, vfefecto, vcactivi, vfecvto
           FROM seguros
          WHERE sseguro = psseguro;

         SELECT frevant, frevisio
           INTO vfrevant, vfrevisio
           FROM seguros_aho
          WHERE sseguro = psseguro;

         vtipo := 2;

         IF pnmovimi IS NOT NULL THEN
            vnmovimi := pnmovimi;
         ELSE
            SELECT MAX(nmovimi)
              INTO vnmovimi
              FROM movseguro
             WHERE sseguro = psseguro;
         END IF;
      END IF;

      vtraza := 2;
      vfechaini := NVL(vfrevant, vfefecto);
      vfechafin := NVL(vfrevisio, vfecvto);

      IF vfechaini IS NULL THEN
         vtext := 'Fecha inicial es nula';
         RAISE verrorobj;
      END IF;

      IF vfechafin IS NULL THEN
         vtext := 'Fecha final es nula';
         RAISE verrorobj;
      END IF;

      IF vnmovimi IS NULL THEN
         vtext := 'Número de movimiento es nulo';
         RAISE verrorobj;
      END IF;

      vtraza := 3;
      vfecharef := vfechafin;

      IF vfecharef < vfechaini THEN
         vtext := 'Fecha final menor a incial';
         RAISE verrorobj;
      END IF;

      SELECT gf.clave, gf.cgarant
        INTO vclave, vcgarant
        FROM garanformula gf, productos p
       WHERE p.sproduc = vsproduc
         AND gf.cramo = p.cramo
         AND gf.cmodali = p.cmodali
         AND gf.ccolect = p.ccolect
         AND gf.ctipseg = p.ctipseg
         AND gf.cactivi = vcactivi
         AND gf.ccampo = 'IPROVAC'
         AND NVL(f_pargaranpro_v(p.cramo, p.cmodali, p.ctipseg, p.ccolect, vcactivi,
                                 gf.cgarant, 'CALCULA_PROVI'),
                 0) = 1;

      IF vclave IS NULL THEN
         vtext := 'Clave es nula';
         RAISE verrorobj;
      END IF;

      IF vcgarant IS NULL THEN
         vtext := 'Garantía es nula';
         RAISE verrorobj;
      END IF;

      SELECT gf.clave
        INTO vclave2
        FROM garanformula gf, productos p
       WHERE p.sproduc = vsproduc
         AND gf.cramo = p.cramo
         AND gf.cmodali = p.cmodali
         AND gf.ccolect = p.ccolect
         AND gf.ctipseg = p.ctipseg
         AND gf.cactivi = vcactivi
         AND gf.ccampo = 'ICFALLAC'
         AND NVL(f_pargaranpro_v(p.cramo, p.cmodali, p.ctipseg, p.ccolect, vcactivi,
                                 gf.cgarant, 'CALCULA_PROVI'),
                 0) = 1;

      IF vclave2 IS NULL THEN
         vtext := 'Clave2 es nula';
         RAISE verrorobj;
      END IF;

      vtraza := 4;

      LOOP
         -- dbms_output.put_line('1vFechaRef:='||vFechaRef);
           --    dbms_output.put_line('1vfechaINI:='||vfechaINI);
             --SELECT TRUNC((vfecharef - vfechaini) / 365.25) + 1
              -- INTO v_anyos
              -- FROM DUAL;
         v_anyos := FLOOR(MONTHS_BETWEEN(vfecharef, vfechaini) / 12) + 1;

         IF TO_CHAR(vfechaini, 'DDMM') <> TO_CHAR(vfechafin, 'DDMM') THEN
            IF vfecharef = vfechaini THEN
               v_anyos := 0;
            END IF;
         END IF;

-- BUG 16217 - 12/2010 - JRH  -  Cuadro de provisiones
         --  dbms_output.put_line('______________v_anyos:'||v_anyos);
         vnumerr := pac_calculo_formulas.calc_formul(vfecharef, vsproduc, vcactivi, vcgarant,
                                                     1, psseguro, vclave, vvalor, NULL, NULL,
                                                     vtipo, NVL(vfrevisio, vfefecto), 'R',
                                                     NULL);

-- Fi BUG 16217 - 12/2010 - JRH
         IF vvalor IS NULL THEN
            vtext := 'Importe es nulo';
            RAISE verrorobj;
         END IF;

         --  dbms_output.put_line('______________v_anyos:'||v_anyos);
         vnumerr := pac_calculo_formulas.calc_formul(vfecharef, vsproduc, vcactivi, vcgarant,
                                                     1, psseguro, vclave2, vcapfall, NULL,
                                                     NULL, vtipo, NVL(vfrevisio, vfefecto),
                                                     'R', NULL);

         IF vcapfall IS NULL THEN
            vtext := 'Importe es nulo';
            RAISE verrorobj;
         END IF;

         IF vtipo = 1 THEN
            DELETE FROM estevoluprovmatseg
                  WHERE sseguro = psseguro
                    AND nmovimi = vnmovimi
                    AND nanyo = v_anyos;

            IF NVL(vvalor, 0) <> 0
               OR NVL(vcapfall, 0) <> 0 THEN
               IF vfefecto <> vfecharef THEN
                  insert_evolu(vtipo, psseguro, vnmovimi, v_anyos, vfecharef, vfechafin,
                               vvalor, 0, vcapfall);
               END IF;
            END IF;
         ELSE
            -- dbms_output.put_line('______________:'||vvalor);
            DELETE FROM evoluprovmatseg
                  WHERE sseguro = psseguro
                    AND nmovimi = vnmovimi
                    AND nanyo = v_anyos;

            --dbms_output.put_line('20');
            --v_contador := 1;
            IF NVL(vvalor, 0) <> 0
               OR NVL(vcapfall, 0) <> 0 THEN
               IF vfefecto <> vfecharef THEN
                  insert_evolu(vtipo, psseguro, vnmovimi, v_anyos, vfecharef, vfechafin,
                               vvalor, 0, vcapfall);
               END IF;
            END IF;
         END IF;

         vtraza := 5;
          -- dbms_output.put_line('vFechaRef:='||vFechaRef);
         --   dbms_output.put_line('vfechaINI:='||vfechaINI);
         vtraza := 6;

         IF vfecharef <= vfechaini THEN
            EXIT;
         END IF;

         IF MONTHS_BETWEEN(vfecharef, vfechaini) > 12 THEN
            vfecharef := ADD_MONTHS(vfecharef, -12);
         ELSIF MONTHS_BETWEEN(vfecharef, vfechaini) BETWEEN 0 AND 12 THEN
            IF MONTHS_BETWEEN(vfecharef, vfechaini) = 0 THEN
               EXIT;
            END IF;

            vfecharef := vfechaini;
         ELSE
            EXIT;
         END IF;
--         IF vfecharef < vfechaini THEN
--            EXIT;
--         END IF;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_formul_cem. f_gen_evoluprovmatseg', vtraza,
                     'psseguro: ' || psseguro || ' - pnmovimi: ' || vnmovimi || '- ptablas: '
                     || ' vtext:' || vtext || ptablas,
                     SQLCODE || '-' || SQLERRM);
         RETURN -1;
   END f_gen_evoluprovmatseg;

-- Fi BUG 16217 - 09/2010 - JRH

   -- BUG 17005 - 15/12/2010 - APD  -  Se crea la funcion f_capitaliza_rvi
    /*************************************************************************

       f_capitaliza_rvi

       Cálculo de la capitalización aplicada en el modelo fiscal 189

       param in psegurosren       : sseguro
       param in pfcalcul          : Fecha fin anualidad
       return                     : 0 o diferente de 0 si hay error
   *************************************************************************/
   FUNCTION f_capitaliza_rvi(psseguro IN NUMBER, pfcalcul IN DATE)
      RETURN NUMBER IS
      vtraza         NUMBER;
      vinteresanu    NUMBER;
      vfnacimi       DATE;
      vintermedio    NUMBER;
      vicapitali     NUMBER;
      vibruren       NUMBER;
      vcforpag       NUMBER;
      vanual         NUMBER;
   BEGIN
      vtraza := 1;

      -- Se obtiene todo el registro existente en SEGUROS_REN
      SELECT ibruren, cforpag   -- BUG 17589-  02/2011 - ETM  - CEM -BUG 17589: 2010: Modelo 189
        INTO vibruren, vcforpag
        FROM seguros_ren
       WHERE sseguro = psseguro;

      vtraza := 2;
      vinteresanu := vtramo(0, 1770, TO_NUMBER(TO_CHAR(pfcalcul, 'YYYY')));   -- Interés legal dinero anualidad
      vtraza := 3;

      BEGIN
         SELECT fnacimi
           INTO vfnacimi   -- Fecha de nacimiento del tomador
           FROM per_personas
          WHERE sperson = ff_sperson_tomador(psseguro);
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'pk_rentas.f_capitaliza_rvi', vtraza,
                        'psseguro: ' || psseguro || ' - pfcalcul: '
                        || TO_CHAR(pfcalcul, 'dd/mm/yyyy'),
                        SQLCODE || '-' || SQLERRM);
            RETURN NULL;
      END;

      vintermedio := TRUNC((pfcalcul - vfnacimi) / 365.25);   -- Cálculo del valor intermedio
      vicapitali := GREATEST((70 -(vintermedio - 19)) / 100, 0.1);   -- Interés capitalización
      vanual := vibruren * vcforpag / vinteresanu;
      RETURN vicapitali * vanual;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pk_rentas.f_capitaliza_rvi', vtraza,
                     'psseguro: ' || psseguro || ' - pfcalcul: '
                     || TO_CHAR(pfcalcul, 'dd/mm/yyyy'),
                     SQLCODE || '-' || SQLERRM);
         RETURN NULL;
   END f_capitaliza_rvi;

-- Fin BUG 17005 - 15/12/2010 - APD

   /*************************************************************************
      Function f_act_pago
      param in psrecren      : Id del recibo del pago de la renta
      param in pibase
      param in ppretenc
      param in pisinret
      param in piretenc
      param in piconret
      param in pctipban
      param in pnctacor
      return                 : 0 -> Todo correcto
                               9901068 -> Se ha producido un error
     --BUG 13477 - JTS - 15/03/2010
   *************************************************************************/
   FUNCTION f_act_pago(
      psrecren IN NUMBER,
      pibase IN NUMBER,
      ppretenc IN NUMBER,
      pisinret IN NUMBER,
      piretenc IN NUMBER,
      piconret IN NUMBER,
      pctipban IN NUMBER,
      pnctacor IN NUMBER)
      RETURN NUMBER IS
      n_err          NUMBER;
   BEGIN
      UPDATE pagosrenta
         SET ibase = pibase,
             pretenc = ppretenc,
             isinret = pisinret,
             iretenc = piretenc,
             iconret = piconret,
             ctipban = pctipban,
             nctacor = pnctacor
       WHERE srecren = psrecren;

      IF NVL
            (pac_parametros.f_parempresa_n
                   (pac_contexto.f_contextovalorparametro(f_parinstalacion_t('CONTEXT_USER'),
                                                          'IAX_EMPRESA'),
                    'MULTIMONEDA'),
             0) = 1 THEN
         n_err := pac_oper_monedas.f_contravalores_pagosrenta(psrecren, NULL);
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PK_RENTAS.f_act_pago', 1, 'ERROR NO CONTROLADO',
                     SQLCODE || ' - ' || SQLERRM);
         RETURN 9901068;
   END f_act_pago;

   /*************************************************************************
    Funció f_get_consultapagos

    param in pcempres
    param in psproduc
    param in pnpoliza
    param in pncertif
    param in pcestado
    param out psquery
    Retorno :  number

    --BUG 13477 - JTS - 15/03/2010
   *************************************************************************/
   FUNCTION f_get_consultapagosrenta(
      pcempres IN NUMBER,
      psproduc IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pcestado IN NUMBER,
      psquery OUT VARCHAR2)
      RETURN NUMBER IS
      vpasexec       NUMBER(1) := 1;
   BEGIN
      psquery :=
         'select pr.SRECREN, pr.SSEGURO, pr.SPERSON, pr.FFECEFE, pr.FFECPAG, pr.FFECANU, pr.CMOTANU, pr.ISINRET, pr.PRETENC, pr.IRETENC, '
         || ' pr.ICONRET, pr.IBASE, pr.PINTGAR, pr.PPARBEN, pr.NCTACOR, pr.NREMESA, pr.FREMESA, pr.CTIPBAN, pr.PROCESO, pr.NSINIES, pr.NTRAMIT, pr.CTIPDES, '
         || ' mp.cestrec, ff_desvalorfijo(230,pac_md_common.f_get_cxtidioma,mp.cestrec) testrec, '
         || 'tc.ttipo ttipban, mm.tmotmov tmotanu, '
         || 't.sperson pertom, s.npoliza, s.ncertif '
         || 'from pagosrenta pr, seguros s, movpagren mp, tipos_cuentades tc, '
         || 'seguros_ren sr, motmovseg mm, tomadores t ' || 'where s.sseguro = pr.sseguro '
         || 'and mp.srecren = pr.srecren ' || 'and mp.fmovfin is null '
         || 'and tc.CTIPBAN(+) = pr.ctipban '
         || 'and tc.cidioma(+) = pac_md_common.f_get_cxtidioma '
         || 'and s.sseguro = sr.sseguro (+) ' || 'and sr.CMOTIVO = mm.CMOTMOV (+) '
         || 'and mm.cidioma(+) = pac_md_common.f_get_cxtidioma '
         || 'and t.sseguro=s.sseguro and t.nordtom=(select min(t1.nordtom) from tomadores t1 where t1.sseguro=t.sseguro) ';
      vpasexec := 2;

      IF pcempres IS NOT NULL THEN
         psquery := psquery || ' and s.cempres =' || pcempres;
      END IF;

      vpasexec := 3;

      IF psproduc IS NOT NULL THEN
         psquery := psquery || ' and s.sproduc =' || psproduc;
      END IF;

      vpasexec := 3;

      IF pnpoliza IS NOT NULL THEN
         psquery := psquery || ' and s.npoliza =' || pnpoliza;
      END IF;

      vpasexec := 4;

      IF pncertif IS NOT NULL THEN
         psquery := psquery || ' and s.ncertif =' || pncertif;
      END IF;

      vpasexec := 5;

      IF pcestado IS NOT NULL THEN
         psquery := psquery || ' and mp.CESTREC =' || pcestado;
      END IF;

      vpasexec := 6;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PK_RENTAS.f_get_consultapagos', vpasexec,
                     'ERROR NO CONTROLADO', SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_get_consultapagosrenta;

   /*************************************************************************
    Funció f_act_pagorenta

    param in psrecren
    param in pctipban
    param in pcuenta
    param in pbase
    param in pporcentaje
    param in pbruto
    param in pretencion
    param in pneto
    param in pestpag
    param in pfechamov
    Retorno :  number

    --BUG 13477 - JTS - 15/03/2010
   *************************************************************************/
   FUNCTION f_act_pagorenta(
      psrecren IN NUMBER,
      pctipban IN NUMBER,
      pcuenta IN VARCHAR2,
      pbase IN NUMBER,
      pporcentaje IN NUMBER,
      pbruto IN NUMBER,
      pretencion IN NUMBER,
      pneto IN NUMBER)
      RETURN NUMBER IS
      vpasexec       NUMBER(1) := 1;
      n_err          NUMBER;
   BEGIN
      vpasexec := 2;

      UPDATE pagosrenta
         SET ctipban = NVL(pctipban, ctipban),
             nctacor = NVL(pcuenta, nctacor),
             ibase = NVL(pbase, ibase),
             pretenc = NVL(pporcentaje, pretenc),
             isinret = NVL(pbruto, isinret),
             iretenc = NVL(pretencion, iretenc),
             iconret = NVL(pneto, iconret)
       WHERE srecren = psrecren;

      IF NVL
            (pac_parametros.f_parempresa_n
                   (pac_contexto.f_contextovalorparametro(f_parinstalacion_t('CONTEXT_USER'),
                                                          'IAX_EMPRESA'),
                    'MULTIMONEDA'),
             0) = 1 THEN
         n_err := pac_oper_monedas.f_contravalores_pagosrenta(psrecren, NULL);
      END IF;

      vpasexec := 3;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PK_RENTAS.f_act_pagorenta', vpasexec,
                     'ERROR NO CONTROLADO', SQLCODE || ' - ' || SQLERRM);
         RETURN 9901068;
   END f_act_pagorenta;

   /*************************************************************************
    Funció f_act_pagorenta

    param in pseguro
    Retorno :  number

    --BUG 13477 - JTS - 15/03/2010
   *************************************************************************/
   FUNCTION f_bloq_proxpagos(psseguro IN NUMBER)
      RETURN NUMBER IS
      vpasexec       NUMBER(1) := 1;
      v_agr          productos.cagrpro%TYPE;
      vbloqpag_old   seguros_ren.cblopag%TYPE;
      vbloqpag_new   seguros_ren.cblopag%TYPE;
   BEGIN
      vpasexec := 2;

      SELECT MAX(b.cagrpro)
        INTO v_agr
        FROM productos b, seguros a
       WHERE b.sproduc = a.sproduc
         AND a.sseguro = psseguro;

      IF v_agr = 10 THEN
         -- Rentes
         vpasexec := 3;

         SELECT cblopag
           INTO vbloqpag_old
           FROM seguros_ren
          WHERE sseguro = psseguro;

         vpasexec := 4;

         IF vbloqpag_old = 0 THEN
            vbloqpag_new := 5;
         ELSIF vbloqpag_old = 5 THEN
            vbloqpag_new := 0;
         ELSE
            RAISE NO_DATA_FOUND;
         END IF;

         vpasexec := 5;

         UPDATE seguros_ren
            SET cblopag = vbloqpag_new
          WHERE sseguro = psseguro;
      ELSIF v_agr = 11 THEN
         -- Pla de Pensions
         BEGIN
            vpasexec := 6;

            SELECT cblopag
              INTO vbloqpag_old
              FROM prestaren
             WHERE sseguro = psseguro
               AND cestado = 0;
         EXCEPTION
            WHEN TOO_MANY_ROWS THEN
               -- Se debe canviar el estado del pago de forma individual
               RETURN 9901978;
         END;

         vpasexec := 7;

         IF vbloqpag_old = 0 THEN
            vbloqpag_new := 5;
         ELSIF vbloqpag_old = 5 THEN
            vbloqpag_new := 0;
         ELSE
            RAISE NO_DATA_FOUND;
         END IF;

         vpasexec := 8;

         UPDATE prestaren
            SET cblopag = vbloqpag_new
          WHERE sseguro = psseguro
            AND cestado = 0;
      ELSE
         vpasexec := 9;
         -- Bloqueo/Desbloqueo de este tipo de pólizas no permitida
         RETURN 9901114;
      END IF;

      vpasexec := 10;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PK_RENTAS.f_bloq_proxpagos', vpasexec,
                     'ERROR NO CONTROLADO', SQLCODE || ' - ' || SQLERRM);
         RETURN 9901074;
   END f_bloq_proxpagos;
END pk_rentas;

/

  GRANT EXECUTE ON "AXIS"."PK_RENTAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PK_RENTAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PK_RENTAS" TO "PROGRAMADORESCSI";
