CREATE OR REPLACE FUNCTION F_RECRIES(
   pctipreb IN NUMBER,
   psseguro IN NUMBER,
   pcagente IN NUMBER,
   pfemisio IN DATE,
   pfefecto IN DATE,
   pfvencimi IN DATE,
   pctiprec IN NUMBER,
   pnanuali IN NUMBER,
   pnfracci IN NUMBER,
   pccobban IN NUMBER,
   pcestimp IN NUMBER,
   psproces IN NUMBER,
   ptipomovimiento IN NUMBER,
   pmodo IN VARCHAR2,
   pcmodcom IN NUMBER,
   pfcaranu IN DATE,
   pnimport IN NUMBER,
   pcmovimi IN NUMBER,
   pcempres IN NUMBER,
   pnmovimi IN NUMBER,
   pcpoliza IN NUMBER,
   pnimport2 OUT NUMBER,
   pnordapo IN NUMBER DEFAULT NULL,
   pcgarant IN NUMBER DEFAULT NULL,
   pttabla IN VARCHAR2 DEFAULT NULL,
   pfuncion IN VARCHAR2 DEFAULT 'CAR',
   pcdomper IN NUMBER DEFAULT NULL,   -- BUG 21924 - MDS - 22/06/2012
   pmovorigen IN NUMBER DEFAULT NULL, -- BUG 34462 - AFM
   pnrecibo   IN NUMBER DEFAULT NULL)   
   RETURN NUMBER IS
   /****************************************************************************
      F_RECRIES: Calcula  el recibo del seguro.
            pctipreb = 1 => Por tomador   (Solo un recibo)
            pctipreb = 2 => Por asegurado (Tantos recibos como riesgos haya)
            pctipreb = 3 => Por colectivo (Un recibo al tomador) Luego se pasa un prceso
                                        que junta los recibos por póliza incluyendo los certificados.
            pctipreb = 4 => Rebut per aportant (taula aportaseg)
      ALLIBADM
      1.- Devuelve el error que se produce en insrecibo o detrecibo
      2.- Si fallan todos los riesgos (error 103108) no da error
      3.- Se añade el parametro PCMOVIMI para pasarselo a f_insrecibo.
          Nos indica si es producto es de ahorro(pcmovimi not null)
          o no lo es (pcmovimi = null)
      4.- Se distingue entre el modo real y modo pruebas(informe previo)
          Se añade el parametro pcempres
      5.- Desaparece el parámetro psmovseg.
          Se añade el parámetro pnmovimi
      6.- Cambios para el caso de un recibo por riesgo

      7.- El tratamiento de recibo por riesgo no funciona cuando se
               trata de la baja de riesgos. SAVEPOINT anula el cursor cuando
               se hace el rollback. Se añaden los delete's.
      8.- Se hacen dos cursores de riesgos, uno para modo P y otro para modo R
      9.- Se cambia el error 103138 por el error generado por f_detrecibo
          para obtener más información.
      10.- Se añade un nuevo modo = 'H' para la rehabilitación de garantias
                y riesgos. Se lee de garancar y se graba en recibos.
      11.- Se añaden los deletes sobre RECIBOS, MOVRECIBO, RECIBOSREDCOM y
           RECIBOSCAR (pmodo='P') cuando el recibo es por tomador y la función
           F_DETRECIBO no graba ningún concepto y devuelve valor 103108.
           Deberá borrar los datos de AGENTESCOB y AGENTESCOBCAR para ese recibo.
           En F_DETRECIBO se ha vuelto a incorporar la funcionalidad que avisa
           que no se grabaron conceptos y deje de grabar el concepto 99 .
      12.- S'afegeix la gestió dels col.lectius de vida, amb rebuts per aportant
      13.- Se añade el parámetro pcgarant para el caso pmodo = 'A' poder
                pasar la garantía asociada (ahora se graba siempre la 282)
      14.- Se añaden los parametros funcion y tabla para el calculo del primer recibo al tarifar,
                el parametro tabla indica a que tablas tiene que ir a buscar importes ('EST','SOL',NULLL),
                el parametro función indica si estoy tarifando (TAR) o en la cartera o previo de cartera (CAR)


      15.- 22/06/2012  MDS    6. 0021924: MDP - TEC - Nuevos campos en pantalla de Gestión (Tipo de retribución, Domiciliar 1º recibo, Revalorización franquicia)
      16.- 14/08/2012  DCG       0023183: LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
      17.- 21/03/2013  AFM    0025951: RSA003 - Módulo de cobranza
      18.- 04/06/2013  APD    0027057: LCOL_T031-Gestión prima mínima de extorno (relacionado con QT 7849)
      19.- 12/06/2013  dlF    0026872: Diferencia de calculo entre la solicitud y los recibos
      20.- 11/03/2015  dlF    0035178: diferencia de coste entre el calculo del suplemento y las condiciones particulares definitivas
      21.- 13/11/2019  DFR    IAXIS-7179: ERROR EN LA INSERCIÓN DEL EXTORNO  
      22.0 01/08/2020  ECP    IAXIS-3504. Gestión Pantallas Suplemento
      23.  19/01/2020  JLTS   IAXIS-3264: Baja de amparos
   ****************************************************************************/
   CURSOR riesgo_modor IS
      SELECT nriesgo
        FROM movseguro m, seguros s, riesgos r
       WHERE s.sseguro = r.sseguro
         AND m.sseguro = s.sseguro
         AND m.nmovimi = pnmovimi
         AND s.sseguro = psseguro
         AND TRUNC(r.fefecto) <= TRUNC(pfefecto)
         AND((r.fanulac IS NULL)
             OR(TRUNC(r.fanulac) > TRUNC(pfefecto)
                AND cmotmov <> 242)
             OR(TRUNC(r.fanulac) >= TRUNC(pfefecto)
                AND cmotmov = 242))
         AND pmodo <> 'H'   -- pmodo = 'R','A'
      UNION   -- Per mode H llegim de garancar
      SELECT DISTINCT (nriesgo)
                 FROM garancar
                WHERE sproces = psproces
                  AND finiefe <= pfefecto
                  AND(ffinefe > pfefecto
                      OR ffinefe IS NULL)
                  AND pmodo = 'H';

   CURSOR riesgo_modop(ptabla IN VARCHAR2) IS
      SELECT nriesgo
        FROM riesgos
       WHERE sseguro = psseguro
         AND TRUNC(fefecto) <= TRUNC(pfefecto)
         AND(fanulac IS NULL
             OR(TRUNC(fanulac) > TRUNC(pfefecto)))
      UNION
      SELECT nriesgo
        FROM estriesgos
       WHERE sseguro = psseguro
         AND TRUNC(fefecto) <= TRUNC(pfefecto)
         AND(fanulac IS NULL
             OR(TRUNC(fanulac) > TRUNC(pfefecto)))
         AND 'EST' LIKE ptabla
      UNION
      SELECT nriesgo
        FROM solriesgos
       WHERE ssolicit = psseguro
         AND 'SOL' LIKE ptabla;

   -- Cursor d'aportants
   -- si ens arriba un aportant concret, forcem a que no reparteixi l'import
   -- segons les proporcions que li toquen, sino un 100%
   /*
   CURSOR capo(psseguro NUMBER, pfefecto DATE, pnorden NUMBER) IS
      SELECT        DECODE(pnorden, NULL, ctipimp, 1) ctipimp,
                    DECODE(pnorden, NULL, pimport, 100) pimport,
                    DECODE(pnorden, NULL, iimport, 0) iimport, cforpag, norden, fcarpro,
                    fcarant, cbancar
               FROM aportaseg
              WHERE sseguro = psseguro
                AND finiefe <= pfefecto
                AND(ffinefe IS NULL
                    OR ffinefe > pfefecto)
                AND(norden = pnorden
                    OR pnorden IS NULL)
                AND cforpag IS NOT NULL
      FOR UPDATE OF fcarant, fcarpro;
   */
   --xcempres       NUMBER;
   num_err        NUMBER;
   num_recibo     NUMBER := pnrecibo;  -- IAXIS-7650 20/11/2019
   --almenosuno     NUMBER;
   error          NUMBER;
   texto          VARCHAR2(400);
   pnnumlin       NUMBER;
   xfmovim        DATE;
   xtipo          VARCHAR2(20);
   --lnrenova       NUMBER;
   --lfcarant_nou   DATE;
   --lfcarpro_nou   DATE;
   --lfvencim       DATE;
   v_idioma       NUMBER;
   --vesrentaprest  NUMBER;
   xsmovrec       NUMBER;
   vpasexec       NUMBER;
   lsproduc       seguros.sproduc%TYPE;
   -- Bug 26872 - 12-VI-2013 - dlF - Diferencia de calculo entre la solicitud y los recibos
   defectopoliza  seguros.fefecto%TYPE;
-- fin Bug -----------------------------------------------------------------
   v_copago       NUMBER;
   -- 24926 - I
   v_csubtiprec   recibos.csubtiprec%TYPE;
   vtomador       NUMBER;
   vsumcaja       NUMBER;
   v_seqcaja      NUMBER;
   v_nnumerr      NUMBER;
   vsproduc       NUMBER;
   vlisaldo       NUMBER;
   vlisaldo_prod  NUMBER;
   vpago          NUMBER;
   v_pnrefdeposito NUMBER;

   vcsubtiprec    NUMBER; -- IAXIS-7179 13/11/219
   
   v_recibo       NUMBER; --IAXIS-3504 08/01/2020
   -- INI - IAXIS-3264  - 19/01/2020
   v_continua NUMBER := 1;
   -- FIN - IAXIS-3264  - 19/01/2020
   -- Bug 0023183 - DCG - 14/08/2012 - LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
   FUNCTION f_dates_aportant(
      psseguro IN NUMBER,
      pnrenova IN NUMBER,
      pcforpag IN NUMBER,
      pfcarpro IN DATE,
      pfcarant_nou OUT DATE,
      pfcarpro_nou OUT DATE)
      RETURN NUMBER IS
      lmeses         NUMBER;
      ldia           VARCHAR2(2);
   BEGIN
      lmeses := 12 / pcforpag;
      ldia := SUBSTR(LPAD(pnrenova, 4, '0'), 3, 2);
      pfcarant_nou := pfcarpro;
      pfcarpro_nou := f_summeses(pfcarpro, lmeses, ldia);
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 141037;
   END f_dates_aportant;
BEGIN
   -- Bug 19096 - RSC - 03/08/2011 - LCOL - Parametrización básica producto Vida Individual Pagos Permanentes
   -- Añadimos 'RRIE'
   vpasexec := 1;

   BEGIN
      -- Bug 26872 - 12-VI-2013 - dlF - Diferencia de calculo entre la solicitud y los recibos
      SELECT sproduc, fefecto
        INTO lsproduc, defectopoliza   --efecto del contrato
        FROM seguros
       WHERE sseguro = psseguro;
-- fin Bug -----------------------------------------------------------------
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF pmodo IN('R', 'A', 'ANP', 'H', 'RRIE') THEN
      IF pctipreb IN(1, 3) THEN
         -- Un solo recibo al tomador, o un solo recibo por colectivo
         -- Si el tipo de recibo es por colectivo:
         -- Generamos el recibo con otra secuencia por que luego pasaremos un proceso que
         -- junte los recibos por poliza (incluyendo los certificados )
         IF pctipreb = 3 THEN
            xtipo := 'SI';
         ELSE
            xtipo := NULL;
         END IF;
         --
         -- Inicio IAXIS-7179 13/11/2019
         --
         IF ptipomovimiento IN (0, 1) THEN
           vcsubtiprec := ptipomovimiento;
         END IF;  
         --
         -- Fin IAXIS-7179 13/11/2019
         --
         num_err := f_insrecibo(psseguro, pcagente, pfemisio, pfefecto, pfvencimi, pctiprec,
                                pnanuali, pnfracci, pccobban, pcestimp, NULL, num_recibo,
                                pmodo, psproces, pcmovimi, pnmovimi, pfefecto, xtipo, NULL,
                                NULL, pttabla, pfuncion,
                                -- BUG 21924 - MDS - 22/06/2012
                                NULL, pcdomper, vcsubtiprec); -- IAXIS-7179 13/11/219

         vpasexec := 10;

         IF num_err <> 0 THEN
            --Devuelve el error de insrecibo
            RETURN num_err;
         -- RETURN 103136;   --Error en la funcion insrecibo
         ELSE
            -- Bug 26872 - 12-VI-2013 - dlF - Diferencia de calculo entre la solicitud y los recibos
            -- Los productos de sobreprecio de AGM no prorratean. Se pasa como efecto en los suplementos
            -- el efecto de la poliza
            num_err := f_detrecibo(psproces, psseguro, num_recibo, ptipomovimiento, pmodo,
                                   pcmodcom, pfemisio,
                                   CASE f_parproductos_v(lsproduc, 'NO_PRORRATEO_SUPLEM')
                                      WHEN 1 THEN defectopoliza
                                      ELSE pfefecto
                                   END,
                                   pfvencimi, pfcaranu, pnimport, NULL, pnmovimi, pcpoliza,
                                   pnimport2, NULL, NULL, NULL, NULL, pcgarant, pttabla,
                                   pfuncion, pmovorigen);   -- BUG 34462 - AFM

-- fin Bug -----------------------------------------------------------------
            IF pfemisio < pfefecto THEN
               xfmovim := pfefecto;
            ELSE
               xfmovim := pfemisio;
            END IF;

            vpasexec := 20;

            IF num_err = 103108 THEN   --Error controlado
               --no se ha grabado nada en detrecibo
               --no se emite recibo de ese riesgo
               num_err := pac_gestion_rec.f_borra_recibo(num_recibo);

               IF num_err <> 0 THEN
                  RETURN num_err;
               END IF;
            -- ROLLBACK TO A;
            ELSIF num_err <> 0
                  AND num_err <> 105154 THEN
               --Devuelve el error de detrecibo
               RETURN num_err;
            -- RETURN 103137;   --Error en la funcion detrecibo
            ELSIF num_err = 105154 THEN
               v_idioma := pac_parametros.f_parempresa_n(pcempres, 'IDIOMA_DEF');
               texto := f_axis_literales(num_err, v_idioma);
               num_recibo := NULL;
               pnnumlin := NULL;
               num_err := f_proceslin(psproces, texto, psseguro, pnnumlin);
            ELSE   -- si no hay error fusionamos los recibos no imprimibles
-- Bug 0023183 - DCG - 14/08/2012 - LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
               vpasexec := 30;

               --BUG 0023183: LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran: INICIO:  21/12/2012:  DCT  - Movimientos vigentes FMOVFIN IS NULL
               BEGIN
                  SELECT smovrec
                    INTO xsmovrec
                    FROM movrecibo
                   WHERE nrecibo = num_recibo
                     AND fmovfin IS NULL;
               EXCEPTION
                  WHEN OTHERS THEN
                     p_tab_error(f_sysdate, f_user, 'f_recries  num_recibo = ' || num_recibo,
                                 vpasexec, 'WHEN OTHERS RETURN 104043', SQLERRM);
                     RETURN 104043;
               END;

               --BUG 0023183: LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran: FIN:  21/12/2012:  DCT  - Movimientos vigentes FMOVFIN IS NULL
               error := f_insctacoas(num_recibo, 1, pcempres, xsmovrec, TRUNC(xfmovim));

               IF error != 0 THEN
                  RETURN error;
               END IF;

-- Fin Bug 0023183
               vpasexec := 40;
               -- Bug 27057/0145439 - APD - 04/06/2013 - se sustituye pfemisio por TRUNC(xfmovim) y se añade
               -- el parametro pmodo
               num_err := f_prima_minima_extorn(psseguro, num_recibo, 2, NULL, pccobban, 7,
                                                pcagente, TRUNC(xfmovim), NULL, pmodo);

               -- fin Bug 27057/0145439 - APD - 04/06/2013
               IF num_err <> 0 THEN
                  RETURN num_err;
               END IF;

               IF ptipomovimiento IN(21, 22) THEN
                  num_err := f_fusionsupcar(psseguro, num_recibo, pfefecto, pfemisio, 'R',
                                            psproces);

                  IF num_err <> 0 THEN
                     RETURN num_err;
                  END IF;
               END IF;
            END IF;
/*            -- Ini 0025951: RSA003 - Módulo de cobranza
            IF NVL(f_parproductos_v(lsproduc, 'HAYCTACLIENTE'), 0) = 1 THEN
               num_err := pac_ctacliente.f_ins_movrecctacli(pcempres, psseguro, pnmovimi,
                                                            num_recibo);

               IF num_err <> 0 THEN
                  RETURN num_err;
               END IF;
            END IF;
         -- Fin 0025951: RSA003 - Módulo de cobranza   Bug 31135   Se traslada a la f_vdetrecibos  */
         END IF;
      ELSIF pctipreb = 2 THEN   -- Un recibo por riesgo(asegurado)
         vpasexec := 50;

         BEGIN
            FOR rie IN riesgo_modor LOOP
               -- SAVEPOINT A;
               num_err := f_insrecibo(psseguro, pcagente, pfemisio, pfefecto, pfvencimi,
                                      pctiprec, pnanuali, pnfracci, pccobban, pcestimp,
                                      rie.nriesgo, num_recibo, pmodo, psproces, pcmovimi,
                                      pnmovimi, pfefecto, NULL, NULL, NULL, pttabla, pfuncion,   -- BUG 21924 - MDS - 22/06/2012
                                      NULL, pcdomper);
               vpasexec := 60;

               IF num_err <> 0 THEN
                  RETURN num_err;   --Error en la funcion insrecibo
               ELSE
                  num_err := f_detrecibo(psproces, psseguro, num_recibo, ptipomovimiento,
                                         pmodo, pcmodcom, pfemisio, pfefecto, pfvencimi,
                                         pfcaranu, pnimport, rie.nriesgo, pnmovimi, pcpoliza,
                                         pnimport2, NULL, NULL, NULL, NULL, pcgarant, pttabla,
                                         pfuncion, pmovorigen);   -- BUG 34462 - AFM
                  vpasexec := 70;

                  IF num_err <> 0 THEN
                     IF num_err = 103108 THEN   --Error controlado
                        --no se ha grabado nada en detrecibo
                        --no se emite recibo de ese riesgo
                        num_err := pac_gestion_rec.f_borra_recibo(num_recibo);

                        IF num_err <> 0 THEN
                           RETURN num_err;
                        END IF;
                     -- ROLLBACK TO A;
                     ELSIF num_err = 105154 THEN   -- Error. Nº. asegurados = 0.
                        v_idioma := pac_parametros.f_parempresa_n(pcempres, 'IDIOMA_DEF');
                        texto := f_axis_literales(num_err, v_idioma);
                        num_recibo := NULL;
                        pnnumlin := NULL;
                        num_err := f_proceslin(psproces, texto, psseguro, pnnumlin);
                     ELSE   --Error fatal
                        --Se cambia el error a retornar para obtener más información.
                        --RETURN 103138;  --Error para un riesgo en la función detrecibo
                        RETURN num_err;
                     END IF;
                  ELSE
                     vpasexec := 80;

                     -- 23460 AVT RSC 15/11/2012
                     IF pfemisio < pfefecto THEN
                        xfmovim := pfefecto;
                     ELSE
                        xfmovim := pfemisio;
                     END IF;

                     -- Bug 0023183 - DCG - 14/08/2012 - LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
                     --BUG 0023183: LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran: INICIO:  21/12/2012:  DCT  - Movimientos vigentes FMOVFIN IS NULL
                     BEGIN
                        SELECT smovrec
                          INTO xsmovrec
                          FROM movrecibo
                         WHERE nrecibo = num_recibo
                           AND fmovfin IS NULL;
                     EXCEPTION
                        WHEN OTHERS THEN
                           p_tab_error(f_sysdate, f_user,
                                       'f_recries  num_recibo = ' || num_recibo, vpasexec,
                                       'WHEN OTHERS RETURN 104043', SQLERRM);
                           RETURN 104043;
                     END;

                     --BUG 0023183: LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran: FIN:  21/12/2012:  DCT  - Movimientos vigentes FMOVFIN IS NULL
                     error := f_insctacoas(num_recibo, 1, pcempres, xsmovrec, TRUNC(xfmovim));

                     IF error != 0 THEN
                        RETURN error;
                     END IF;

-- Fin Bug 0023183
                     -- Bug 27057/0145439 - APD - 04/06/2013 - se sustituye pfemisio por TRUNC(xfmovim) y se añade
                     -- el parametro pmodo
                     num_err := f_prima_minima_extorn(psseguro, num_recibo, 2, NULL, pccobban,
                                                      7, pcagente, TRUNC(xfmovim), NULL, pmodo);
                     -- fin Bug 27057/0145439 - APD - 04/06/2013
                     vpasexec := 90;

                     IF num_err <> 0 THEN
                        RETURN num_err;
                     END IF;

                     -- si no hay error fusionamos los recibos no imprimibles
                     IF ptipomovimiento IN(21, 22) THEN
                        num_err := f_fusionsupcar(psseguro, num_recibo, pfefecto, pfemisio,
                                                  'R', psproces);

                        IF num_err <> 0 THEN
                           RETURN num_err;
                        END IF;
                     END IF;

                     /*-- Ini 0025951: RSA003 - Módulo de cobranza
                     IF NVL(f_parproductos_v(lsproduc, 'HAYCTACLIENTE'), 0) = 1 THEN
                        num_err := pac_ctacliente.f_ins_movrecctacli(pcempres, psseguro,
                                                                     pnmovimi, num_recibo);

                        IF num_err <> 0 THEN
                           RETURN num_err;
                        END IF;
                     END IF;

                     -- Fin 0025951: RSA003 - Módulo de cobranza Bug 31135  se traslada a la f_vdetrecibos */
                     num_recibo := NULL;
                  --Que calcule el siguiente;
                  END IF;
               END IF;
            END LOOP;
         EXCEPTION
            -- Se producirá una excepción ORA -01002 cuando haya un rollback
            -- en el bucle.
            WHEN OTHERS THEN
               --DBMS_OUTPUT.put_line(SQLERRM);
               RETURN 104952;   --Error en la función RECRIES
         END;
      ELSIF pctipreb = 4 THEN
         vpasexec := 100;

         BEGIN
            SELECT crespue
              INTO v_copago
              FROM pregunpolseg
             WHERE sseguro = psseguro
               AND cpregun = 535
               AND nmovimi = (SELECT MAX(p2.nmovimi)
                                FROM pregunpolseg p2
                               WHERE p2.sseguro = pregunpolseg.sseguro
                                 AND p2.cpregun = pregunpolseg.cpregun);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_copago := NULL;
         END;

         IF NVL(v_copago, 100) <> 0 THEN
            -- Bug 7854 - 11/02/2009 - RSC - Recibo del certificado cero.
            -- Recibo del Certificado 0
            num_err := f_insrecibo(psseguro, pcagente, pfemisio, pfefecto, pfvencimi,
                                   pctiprec, pnanuali, pnfracci, pccobban, pcestimp, NULL,
                                   num_recibo, pmodo, psproces, pcmovimi, pnmovimi, pfefecto,
                                   'CERTIF0', NULL, NULL, pttabla, pfuncion,   -- BUG 21924 - MDS - 22/06/2012
                                   NULL, pcdomper);
            vpasexec := 110;

            IF num_err <> 0 THEN
               RETURN num_err;   --Error en la funcion insrecibo
            ELSE
               num_err := f_detrecibo(psproces, psseguro, num_recibo, ptipomovimiento, pmodo,
                                      pcmodcom, pfemisio, pfefecto, pfvencimi, pfcaranu,
                                      pnimport, NULL, pnmovimi, pcpoliza, pnimport2, NULL, 1,
                                      NULL, NULL, pcgarant, pttabla, pfuncion, pmovorigen);   -- BUG 34462 - AFM
               vpasexec := 120;

               IF num_err <> 0 THEN
                  IF num_err = 103108 THEN   --Error controlado
                     --no se ha grabado nada en detrecibo
                     --no se emite recibo de ese riesgo
                     num_err := pac_gestion_rec.f_borra_recibo(num_recibo);

                     IF num_err <> 0 THEN
                        RETURN num_err;
                     END IF;
                  ELSIF num_err = 105154 THEN   -- Error. Nº. asegurados = 0.
                     v_idioma := pac_parametros.f_parempresa_n(pcempres, 'IDIOMA_DEF');
                     texto := f_axis_literales(num_err, v_idioma);
                     num_recibo := NULL;
                     pnnumlin := NULL;
                     num_err := f_proceslin(psproces, texto, psseguro, pnnumlin);
                  ELSE   --Error fatal
                     -- Se cambia el error a retornar para obtener más información.
                     --RETURN 103138;  --Error para un riesgo en la función detrecibo
                     RETURN num_err;
                  END IF;
               ELSE
                  vpasexec := 130;

                  -- 23460 AVT RSC 15/11/2012
                  IF pfemisio < pfefecto THEN
                     xfmovim := pfefecto;
                  ELSE
                     xfmovim := pfemisio;
                  END IF;

                  -- Bug 0023183 - DCG - 14/08/2012 - LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
                  --BUG 0023183: LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran: INICIO:  21/12/2012:  DCT  - Movimientos vigentes FMOVFIN IS NULL
                  BEGIN
                     SELECT smovrec
                       INTO xsmovrec
                       FROM movrecibo
                      WHERE nrecibo = num_recibo
                        AND fmovfin IS NULL;
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_tab_error(f_sysdate, f_user,
                                    'f_recries  num_recibo = ' || num_recibo, vpasexec,
                                    'WHEN OTHERS RETURN 104043', SQLERRM);
                        RETURN 104043;
                  END;

                  --BUG 0023183: LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran: FIN:  21/12/2012:  DCT  - Movimientos vigentes FMOVFIN IS NULL
                  error := f_insctacoas(num_recibo, 1, pcempres, xsmovrec, TRUNC(xfmovim));

                  IF error != 0 THEN
                     RETURN error;
                  END IF;

                  -- Fin Bug 0023183
                                 -- Bug 27057/0145439 - APD - 04/06/2013 - se sustituye pfemisio por TRUNC(xfmovim) y se añade
                                 -- el parametro pmodo
                  num_err := f_prima_minima_extorn(psseguro, num_recibo, 2, NULL, pccobban, 7,
                                                   pcagente, TRUNC(xfmovim), NULL, pmodo);
                  -- Bug 27057/0145439 - APD - 04/06/2013
                  vpasexec := 140;

                  IF num_err <> 0 THEN
                     RETURN num_err;
                  END IF;

                  -- si no hay error fusionamos los recibos no imprimibles
                  IF ptipomovimiento IN(21, 22) THEN
                     num_err := f_fusionsupcar(psseguro, num_recibo, pfefecto, pfemisio, 'R',
                                               psproces);

                     IF num_err <> 0 THEN
                        RETURN num_err;
                     END IF;
                  END IF;
               -- Insertem el rebut per aportant
               --BEGIN
               --   INSERT INTO aportarec
               --               (sseguro, norden, nrecibo)
               --        VALUES (psseguro, vapo.norden, num_recibo);
               --EXCEPTION
               --   WHEN OTHERS THEN
               --      RETURN 140613;
               --END;

               --IF pctiprec = 3 THEN
                  -- Si és un rebut de cartera, actualitzem les dates dels aportants
               --   UPDATE aportaseg
               --      SET fcarant = lfcarant_nou,
               --          fcarpro = lfcarpro_nou
               --    WHERE CURRENT OF capo;
               --END IF;

               --num_recibo := NULL;
               --Que calcule el siguiente;

               /* -- Ini 0025951: RSA003 - Módulo de cobranza
                  IF NVL(f_parproductos_v(lsproduc, 'HAYCTACLIENTE'), 0) = 1 THEN
                     num_err := pac_ctacliente.f_ins_movrecctacli(pcempres, psseguro,
                                                                  pnmovimi, num_recibo);

                     IF num_err <> 0 THEN
                        RETURN num_err;
                     END IF;
                  END IF;
               -- Fin 0025951: RSA003 - Módulo de cobranza Bug 31135  se traslada a la f_vdetrecibos  */
               END IF;
            END IF;
         END IF;

         IF NVL(v_copago, 0) <> 100 THEN
            -- Hay que ponerlo a NULL para que genere otro numero de recibo
            num_recibo := NULL;
            -- Bug 7854 - 11/02/2009 - RSC - Recibo del certificado cero.
            -- Recibo del Certificado N
            num_err := f_insrecibo(psseguro, pcagente, pfemisio, pfefecto, pfvencimi,
                                   pctiprec, pnanuali, pnfracci, pccobban, pcestimp, NULL,
                                   num_recibo, pmodo, psproces, pcmovimi, pnmovimi, pfefecto,
                                   'CERTIFN', NULL, NULL, pttabla, pfuncion,   -- BUG 21924 - MDS - 22/06/2012
                                   NULL, pcdomper);
            vpasexec := 150;

            IF num_err <> 0 THEN
               RETURN num_err;   --Error en la funcion insrecibo
            ELSE
               num_err := f_detrecibo(psproces, psseguro, num_recibo, ptipomovimiento, pmodo,
                                      pcmodcom, pfemisio, pfefecto, pfvencimi, pfcaranu,
                                      pnimport, NULL, pnmovimi, pcpoliza, pnimport2, NULL, 2,
                                      NULL, NULL, pcgarant, pttabla, pfuncion, pmovorigen);   -- BUG 34462 - AFM

               IF num_err <> 0 THEN
                  IF num_err = 103108 THEN   --Error controlado
                     --no se ha grabado nada en detrecibo
                     --no se emite recibo de ese riesgo
                     num_err := pac_gestion_rec.f_borra_recibo(num_recibo);

                     IF num_err <> 0 THEN
                        RETURN num_err;
                     END IF;
                  ELSIF num_err = 105154 THEN   -- Error. Nº. asegurados = 0.
                     v_idioma := pac_parametros.f_parempresa_n(pcempres, 'IDIOMA_DEF');
                     texto := f_axis_literales(num_err, v_idioma);
                     num_recibo := NULL;
                     pnnumlin := NULL;
                     num_err := f_proceslin(psproces, texto, psseguro, pnnumlin);
                  ELSE   --Error fatal
                     -- Se cambia el error a retornar para obtener más información.
                     --RETURN 103138;  --Error para un riesgo en la función detrecibo
                     RETURN num_err;
                  END IF;
               ELSE
                  vpasexec := 160;

                  -- 23460 AVT RSC 15/11/2012
                  IF pfemisio < pfefecto THEN
                     xfmovim := pfefecto;
                  ELSE
                     xfmovim := pfemisio;
                  END IF;

                  -- Bug 0023183 - DCG - 14/08/2012 - LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
                  --BUG 0023183: LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran: INICIO:  21/12/2012:  DCT  - Movimientos vigentes FMOVFIN IS NULL
                  BEGIN
                     SELECT smovrec
                       INTO xsmovrec
                       FROM movrecibo
                      WHERE nrecibo = num_recibo
                        AND fmovfin IS NULL;
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_tab_error(f_sysdate, f_user,
                                    'f_recries  num_recibo = ' || num_recibo, vpasexec,
                                    'WHEN OTHERS RETURN 104043', SQLERRM);
                        RETURN 104043;
                  END;

                  --BUG 0023183: LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran: FIN:  21/12/2012:  DCT  - Movimientos vigentes FMOVFIN IS NULL
                  error := f_insctacoas(num_recibo, 1, pcempres, xsmovrec, TRUNC(xfmovim));

                  IF error != 0 THEN
                     RETURN error;
                  END IF;

                  -- Fin Bug 0023183
                                 -- Bug 27057/0145439 - APD - 04/06/2013 - se sustituye pfemisio por TRUNC(xfmovim) y se añade
                                 -- el parametro pmodo
                  num_err := f_prima_minima_extorn(psseguro, num_recibo, 2, NULL, pccobban, 7,
                                                   pcagente, TRUNC(xfmovim), NULL, pmodo);
                  -- Bug 27057/0145439 - APD - 04/06/2013
                  vpasexec := 170;

                  IF num_err <> 0 THEN
                     RETURN num_err;
                  END IF;

                  -- si no hay error fusionamos los recibos no imprimibles
                  IF ptipomovimiento IN(21, 22) THEN
                     num_err := f_fusionsupcar(psseguro, num_recibo, pfefecto, pfemisio, 'R',
                                               psproces);

                     IF num_err <> 0 THEN
                        RETURN num_err;
                     END IF;
                  END IF;
                  /*-- Ini 0025951: RSA003 - Módulo de cobranza
                  IF NVL(f_parproductos_v(lsproduc, 'HAYCTACLIENTE'), 0) = 1 THEN
                     num_err := pac_ctacliente.f_ins_movrecctacli(pcempres, psseguro,
                                                                  pnmovimi, num_recibo);

                     IF num_err <> 0 THEN
                        RETURN num_err;
                     END IF;
                  END IF;
               -- Fin 0025951: RSA003 - Módulo de cobranza   Bug 31135   se traslada a la f_vdetrecibos*/

               -- Insertem el rebut per aportant
               --BEGIN
               --   INSERT INTO aportarec
               --               (sseguro, norden, nrecibo)
               --        VALUES (psseguro, vapo.norden, num_recibo);
               --EXCEPTION
               --   WHEN OTHERS THEN
               --      RETURN 140613;
               --END;

               --IF pctiprec = 3 THEN
                  -- Si és un rebut de cartera, actualitzem les dates dels aportants
               --   UPDATE aportaseg
               --      SET fcarant = lfcarant_nou,
               --          fcarpro = lfcarpro_nou
               --    WHERE CURRENT OF capo;
               --END IF;

               --num_recibo := NULL;
               --Que calcule el siguiente;
               END IF;
            END IF;
         END IF;
            --END IF;
         --END LOOP;
------------ FI DELS CANVIS
      END IF;

-- 24926 I  miro si es un recibo de ahorra para marcar el subestado
      v_csubtiprec := pac_parametros.f_parempresa_n(NVL(pac_md_common.f_get_cxtempresa,
                                                        f_parinstalacion_n('EMPRESADEF')),
                                                    'SUBTIPREC_AHORRO');

      IF v_csubtiprec IS NOT NULL THEN
         IF pac_adm.f_es_recibo_ahorro(num_recibo) = 1 THEN
            UPDATE recibos
               SET csubtiprec = v_csubtiprec
             WHERE nrecibo = num_recibo;
         END IF;
      ELSE
         IF (NVL(pac_parametros.f_parempresa_n(NVL(pac_md_common.f_get_cxtempresa,
                                                   f_parinstalacion_n('EMPRESADEF')),
                                               'SUBTIPREC_ERRONEO'),
                 0) = 0) AND NVL(f_parproductos_v(lsproduc,'DUMMY_REC'), 0) = 0 THEN -- IAXIS-7179 13/11/2019
            UPDATE recibos
               SET csubtiprec = pctiprec
             WHERE nrecibo = num_recibo;
         END IF;
      END IF;

-- 24926 F  miro si es un recibo de ahorra para marcar el subestado

      --Bug.: 20923 - 14/01/2012 - ICV - El envio a SAP pasa a realizarse en el p_emitir_propuesto o en cada proceso especifico

      -- 33886/215796 Racs inicio  realizar pago del recibo si tiene saldo a favor
      IF NVL(f_parproductos_v(lsproduc, 'HAYCTACLIENTE'), 0) = 2 THEN
         vtomador := pac_seguros.f_get_tomador_poliza(psseguro);

         IF (vtomador <> 0) THEN
            vsumcaja := pac_caja.f_get_suma_caja(0, vtomador, NULL);

            IF (vsumcaja > 0) THEN
               vpasexec := 180;
               v_nnumerr := pac_productos.f_get_sproduc(psseguro, vsproduc);

               IF v_nnumerr <> 0 THEN
                  p_tab_error(f_sysdate, f_user, 'f_recries', vpasexec,
                              'seguro= ' || psseguro || ' sproduct= ' || vsproduc,
                              'error ' || v_nnumerr);
               END IF;

               vpasexec := 190;
               v_nnumerr := pac_ctacliente.f_saldo_ctacliente(pac_md_common.f_get_cxtempresa,
                                                              vtomador, psseguro, vsproduc,
                                                              vlisaldo, vlisaldo_prod);

               IF v_nnumerr <> 0 THEN
                  p_tab_error(f_sysdate, f_user, 'f_recries', vpasexec,
                              'tomador ' || vtomador || 'seguro ' || psseguro || 'product '
                              || vsproduc || 'saldo' || vlisaldo || 'saldoprod'
                              || vlisaldo_prod,
                              'error ' || v_nnumerr);
               END IF;

               vpasexec := 200;

               IF ABS(vlisaldo_prod) <= vsumcaja THEN
                  vpago := ABS(vlisaldo_prod);
               END IF;

               IF ABS(vlisaldo_prod) > vsumcaja THEN
                  vpago := vsumcaja;
               END IF;

               SELECT seqmovecash.NEXTVAL
                 INTO v_pnrefdeposito
                 FROM DUAL;

               v_nnumerr :=
                  pac_ctacliente.f_apunte_pago_spl
                     (pcempres => pac_md_common.f_get_cxtempresa,
                      psseguro => TO_NUMBER(psseguro),
                      pimporte => TO_NUMBER(LTRIM(vpago, '0'), '999999999999.99'),
                      pseqcaja => v_seqcaja, pnrefdeposito => v_pnrefdeposito,

                      -- pntarget => SUBSTR(v_account_v, 1, 20),
                      --pcmedmov => 8,
                       --pcautoriza => p_sproces,
                       --pccomercio => x.nlinea,
                      pdsmop => SUBSTR
                                  (f_axis_literales(9908680, f_usu_idioma), 1, 125)   --, --> hacerlo con literales

                                                                                   --pfautori => v_dateval
                  );

               IF v_nnumerr <> 0 THEN
                  p_tab_error(f_sysdate, f_user, 'f_recries', vpasexec,
                              'sseguro ' || psseguro || 'importe ' || vpago || 'seqcaja '
                              || v_seqcaja,
                              'error ' || v_nnumerr);
               END IF;

               vpasexec := 210;
               v_nnumerr :=
                  pac_caja.f_insmvtocaja
                     (pcempres => pac_md_common.f_get_cxtempresa, pcusuari => f_user,
                      psperson => vtomador, pffecmov => f_sysdate, pctipmov => 0,
                      pimovimi => TO_NUMBER(LTRIM(vpago, '0'), '999999999999.99') * -1,
                      pcmoneop => pac_parametros.f_parempresa_n
                                                               (pac_md_common.f_get_cxtempresa,
                                                                'MONEDACONTAB'),
                      pseqcaja => v_seqcaja, pcmanual => 0);

               IF v_nnumerr <> 0 THEN
                  p_tab_error(f_sysdate, f_user, 'f_recries', vpasexec,
                              'psperson ' || vtomador || 'vpago ' || vpago || 'seqcaja '
                              || v_seqcaja,
                              'error ' || v_nnumerr);
               END IF;

               vpasexec := 220;
               v_nnumerr :=
                  pac_caja.f_inscajadatmedio
                     (v_seqcaja,   --pseqcaja IN NUMBER,
                      NULL,   --pncheque,
                      NULL,   --pcestchq, --el estado del cheque
                      NULL,   --pcbanco,
                      NULL,   --pccc, --el n¿mero de cuenta
                      NULL,   --pctiptar,
                      SUBSTR('000000', 1, 20),   --el n¿mero de la tarjeta de cr¿dito
                      NULL,   --pfcadtar, --cuando caduca la tarjeta de cr¿dito
                      TO_NUMBER(LTRIM(vpago, '0'), '999999999999.99') * -1,   --v_importe,
                      2,   --pcmedmov -->detvalores 481
                      pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,
                                                    'MONEDACONTAB'),
                      v_pnrefdeposito,   --NVL(pnrefdeposito, v_pnrefdeposito), -->referencia del dep¿sito
                      NULL,   --pcautoriza, -->codigo de autorizaci¿n si fuera tarjeta de cr¿dito
                      NULL,   --pnultdigtar, -->cuatro ¿ltimos d¿gitos de la tarjeta de cr¿dito
                      NULL,   --pncuotas, -->no aplica para msv
                      NULL,   --codigo de comecio no aplica para msv);
                      NULL,   --pdsbanco --banco si es que no est¿ listado y es un banco desconocido
                      NULL,   --pctipche, --tipos de cheque (cheque personal, cheque TII, cheque corporativo)
                      NULL,   --pctipched, --distintos tipos de cheques draft
                      NULL,   --pcrazon,
                      SUBSTR(f_axis_literales(9908680, f_usu_idioma), 1, 125),   --> hacerlo con literales
                      f_sysdate,   --Fecha en la cual se autoriza o se deniega el pago de un cheque a un cliente
                      NULL,   --pcestado, --Estado Reembolso en CajaMov
                      0,   --psseguro, -- Numero de seguro para asociacion de reembolosos
                      NULL,   --psseguro_d, --Numero de seguro para asociacion destino de dineros
                      NULL);

               IF v_nnumerr <> 0 THEN
                  p_tab_error(f_sysdate, f_user, 'f_recries', vpasexec,
                              'seqcaja ' || v_seqcaja || 'vpago ' || vpago || 'refdeposito '
                              || v_pnrefdeposito,
                              'error ' || v_nnumerr);
               END IF;

               vpasexec := 230;

               IF vlisaldo_prod > 0 THEN   -- Si el saldo ant es positivo, se paga parte o totalmente el recibo
                  num_err :=
                     pac_ctacliente.f_pagar_recibo_consaldo(pac_md_common.f_get_cxtempresa,
                                                            vtomador, psseguro, 1, num_recibo,
                                                            ABS(vpago), vlisaldo_prod);

                  IF num_err <> 0 THEN
                     p_tab_error(f_sysdate, f_user, 'f_recries', vpasexec,
                                 'tomador ' || vtomador || 'sseguro' || psseguro || 'recibo'
                                 || num_recibo || 'vpago' || vpago || 'saldo_prod '
                                 || vlisaldo_prod,
                                 'error ' || v_nnumerr);
                  END IF;
               END IF;
            END IF;
         END IF;
      END IF;

-- 33886/215796 Racs fin

      -- INI - IAXIS-3264  - JLTS - 15/01/2020
      v_continua := 1;
      IF pac_iax_produccion.issuplem THEN
        IF pac_iax_suplementos.lstmotmov IS NOT NULL ANd pac_iax_suplementos.lstmotmov.count > 0 THEN
           IF pac_iax_suplementos.lstmotmov(1).cmotmov = 239 AND 
             NVL (pac_parametros.f_parproducto_n (pac_iax_produccion.poliza.det_poliza.sproduc,'BAJA_AMP_DEV_TOT'),0) = 1 THEN
             -- Se ejecuta el proceso de baja de amparo para las comisiones
             vpasexec := 240;
             error := f_comis_baja_amp(psseguro,num_recibo);
             IF error <> 0 THEN
               p_tab_error(f_sysdate,
                           f_user,
                           'f_recries',
                           vpasexec,
                           'psseguro='||psseguro||' num_recibo='||num_recibo,
                           'SQLCODE = ' || SQLCODE || ' - ' || 'SQLERRM = ' ||
                           SQLERRM || 'v_error = ' || error);
               ROLLBACK;
               RETURN error;
             END IF;
             v_continua := 0;
          END IF;
        END IF;
      END IF;
      -- FIN - IAXIS-3264  - JLTS - 15/01/2020
      IF v_continua = 1 THEN
        -- INI - IAXIS-5040  - JLTS - 19/08/2019
        vpasexec := 250;
      --IAXIS-3504 -- ECP  -- 08/01/2020 -- ECP 
               begin
                 select nrecibo
                 into v_recibo
                 from recibos
                 where nrecibo = num_recibo;
                 exception when no_data_found then v_recibo:=0;
               end;
               if v_recibo <> 0 then
               error := f_comis_corre_coa(psseguro,num_recibo, 1); 
               IF error <> 0 THEN
                 p_tab_error(f_sysdate,
                             f_user,
                             'f_recries',
                             vpasexec,
                             'psseguro='||psseguro||' num_recibo='||num_recibo,
                             'SQLCODE = ' || SQLCODE || ' - ' || 'SQLERRM = ' ||
                             SQLERRM || 'v_error = ' || error);
                 ROLLBACK;
                 RETURN error;
               END IF;
               --IAXIS-3504 -- ECP  -- 08/01/2020 -- ECP 
        -- FIN - IAXIS-5040  - JLTS - 19/08/2019
        -- INI - IAXIS-4156  - SGM - 23/08/2019
        vpasexec := 260;
        error := f_intermediarios_iva(num_recibo);
        IF error <> 0 THEN
          p_tab_error(f_sysdate,
                      f_user,
                      'f_recries',
                      vpasexec,
                      'psseguro='||psseguro||' num_recibo='||num_recibo,
                      'SQLCODE = ' || SQLCODE || ' - ' || 'SQLERRM = ' ||
                      SQLERRM || 'v_error = ' || error);
          ROLLBACK;
          RETURN error;
        END IF;
	end if;
        -- FIN - IAXIS-4156  - SGM - 23/08/2019
      END IF; -- IAXIS-3264  - JLTS - 15/01/2020
      RETURN 0;
   ELSIF pmodo IN('P', 'PRIE') THEN
      IF pctipreb IN(1, 3) THEN
         -- Un solo recibo al tomador o por colectivo.
         IF pttabla = 'SOL' THEN
            num_recibo := psseguro;
         ELSE
            num_recibo := f_contador('04', pcempres);
         END IF;

         -- Si el tipo de recibo es por colectivo:
         -- Generamos el recibo con otra secuencia por que luego pasaremos un proceso que
         -- junte los recibos por poliza (incluyendo los certificados )
         IF pctipreb = 3 THEN
            xtipo := 'SI';
         ELSE
            xtipo := NULL;
         END IF;

         vpasexec := 270;
         num_err := f_insrecibo(psseguro, pcagente, pfemisio, pfefecto, pfvencimi, pctiprec,
                                pnanuali, pnfracci, pccobban, pcestimp, NULL, num_recibo,
                                pmodo, psproces, pcmovimi, pnmovimi, pfefecto, xtipo, NULL,
                                NULL, pttabla, pfuncion,   -- BUG 21924 - MDS - 22/06/2012
                                NULL, pcdomper);

         IF num_err <> 0 THEN
            RETURN num_err;
         -- RETURN 103136;
         END IF;

         -- Bug 35178 - 11-III-2013 - dlF - diferencia de coste entre el calculo del suplemento y las condiciones particulares definitivas
         -- Los productos de sobreprecio de AGM no prorratean.
         -- Se pasa como efecto en los suplementos el efecto de la poliza
         vpasexec := 280;
         --AGM-45-XVM-06/07/2016.Añadimos un case para la fecha de efecto
         num_err := f_detrecibo(psproces, psseguro, num_recibo, ptipomovimiento, pmodo,
                                pcmodcom, pfemisio, CASE f_parproductos_v(lsproduc, 'NO_PRORRATEO_SUPLEM')
                                      WHEN 1 THEN defectopoliza
                                      ELSE pfefecto
                                   END, pfvencimi, pfcaranu, pnimport,
                                NULL, pnmovimi, pcpoliza, pnimport2, NULL, NULL, NULL, NULL,
                                pcgarant, pttabla, pfuncion, pmovorigen);   -- BUG 34462 - AFM

         IF num_err = 103108 THEN   --Error controlado
            --no se ha grabado nada en detrecibocar
            --no se emite recibo de ese riesgo
            num_err := pac_gestion_rec.f_borra_recibo(num_recibo, 'P');

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;
         ELSIF num_err NOT IN(0, 105154) THEN
            --Devuelve el error de detrecibo
            RETURN num_err;
         -- RETURN 103137;   --Error en la funcion detrecibo
         ELSIF num_err = 105154 THEN
            v_idioma := pac_parametros.f_parempresa_n(pcempres, 'IDIOMA_DEF');
            texto := f_axis_literales(num_err, v_idioma);
            num_recibo := NULL;
            pnnumlin := NULL;
            num_err := f_proceslin(psproces, texto, psseguro, pnnumlin);
         ELSE   -- si no hay error fusionamos los recibos no imprimibles
            vpasexec := 290;

            IF ptipomovimiento IN(21, 22) THEN
               num_err := f_fusionsupcar(psseguro, num_recibo, pfefecto, pfemisio, 'P',
                                         psproces);

               IF num_err <> 0 THEN
                  RETURN num_err;
               END IF;
            END IF;
         END IF;
      ELSIF pctipreb = 2 THEN   -- Un recibo por riesgo(asegurado)
         BEGIN
            FOR rie IN riesgo_modop(pttabla) LOOP
               IF pttabla = 'SOL' THEN
                  num_recibo := psseguro;
               ELSE
                  num_recibo := f_contador('04', pcempres);
               END IF;

               vpasexec := 300;
               num_err := f_insrecibo(psseguro, pcagente, pfemisio, pfefecto, pfvencimi,
                                      pctiprec, pnanuali, pnfracci, pccobban, pcestimp,
                                      rie.nriesgo, num_recibo, pmodo, psproces, pcmovimi,
                                      pnmovimi, pfefecto, NULL, NULL, NULL, pttabla, pfuncion,   -- BUG 21924 - MDS - 22/06/2012
                                      NULL, pcdomper);

               IF num_err <> 0 THEN
                  RETURN num_err;
               END IF;

               vpasexec := 310;
               num_err := f_detrecibo(psproces, psseguro, num_recibo, ptipomovimiento, pmodo,
                                      pcmodcom, pfemisio, pfefecto, pfvencimi, pfcaranu,
                                      pnimport, rie.nriesgo, pnmovimi, pcpoliza, pnimport2,
                                      NULL, NULL, NULL, NULL, pcgarant, pttabla, pfuncion,
                                      pmovorigen);   -- BUG 34462 - AFM

               IF num_err <> 0 THEN
                  IF num_err = 103108 THEN   --Error controlado
                     --no se ha grabado nada en detrecibo
                     --no se emite recibo de ese riesgo
                     num_err := pac_gestion_rec.f_borra_recibo(num_recibo, 'P');

                     IF num_err <> 0 THEN
                        RETURN num_err;
                     END IF;
                  -- ROLLBACK TO A;
                  ELSIF num_err = 105154 THEN   -- Error. Nº. asegurados = 0.
                     v_idioma := pac_parametros.f_parempresa_n(pcempres, 'IDIOMA_DEF');
                     texto := f_axis_literales(num_err, v_idioma);
                     num_recibo := NULL;
                     pnnumlin := NULL;
                     num_err := f_proceslin(psproces, texto, psseguro, pnnumlin);
                  ELSE   --Error fatal
                     --Se cambia el error a retornar para obtener más información.
                     --RETURN 103138;  --Error para un riesgo en la función detrecibo
                     RETURN num_err;
                  END IF;
               ELSE
                  vpasexec := 320;

                  -- si no hay error fusionamos los recibos no imprimibles
                  IF ptipomovimiento IN(21, 22) THEN
                     num_err := f_fusionsupcar(psseguro, num_recibo, pfefecto, pfemisio, 'P',
                                               psproces);

                     IF num_err <> 0 THEN
                        RETURN num_err;
                     END IF;
                  END IF;

                  num_recibo := NULL;
               --Que calcule el siguiente;
               END IF;
            END LOOP;
-- sheila: Aqui miramos si el producto es colectivo y si lo es generamos un recibo
-- a nombre del tomador para la póliza.
         EXCEPTION
            -- Se producirá una excepción ORA -01002 cuando haya un rollback
            -- en el bucle.
            WHEN OTHERS THEN
               --DBMS_OUTPUT.put_line('err2 ' || SQLERRM);
               RETURN 104952;   --Error en la función RECRIES
         END;
      ELSIF pctipreb = 4 THEN
         -- Rebut per aportant
         -- veure si per forma de pagament li toca
         -- cridar a f_insrecibo amb cforpag i cbancar
         -- Necessitem nrenova per obtenir la data de propera cartera per cada aportant
         --BEGIN
         --   SELECT nrenova
         --     INTO lnrenova
         --    FROM seguros
         --    WHERE sseguro = psseguro;
         --EXCEPTION
         --   WHEN OTHERS THEN
         --      RETURN 101919;
         --END;

         --FOR vapo IN capo (psseguro, pfefecto, pnordapo) LOOP
            -- Cal veure si a aquest aportant li toca fer rebut
            -- En cas de nova producció o suplement sempre farem rebut
            -- en cas de renovació mirarem la data de propera cartera
            --IF    pctiprec <> 3
            --   OR vapo.fcarpro = pfefecto THEN
               -- s'ha de calcular la data de venciment del rebut, que serà
               -- la data de propera cartera nova de l'aportant
            --   IF pctiprec = 3 THEN
            --      num_err :=
            --         f_dates_aportant (psseguro, lnrenova, vapo.cforpag,
            --                           vapo.fcarpro, lfcarant_nou,
            --                           lfcarpro_nou);
            --      lfvencim := lfcarpro_nou;

         --      IF num_err <> 0 THEN
         --         RETURN num_err;
         --      END IF;
         --   ELSE
         --      lfvencim := pfvencimi;
         --   END IF;

         -- Bug 7854 - 11/02/2009 - RSC - Recibo del certificado cero.
             -- Recibo del Certificado 0

         --num_recibo := f_contador ('04', pcempres);
         IF pttabla = 'SOL' THEN
            num_recibo := psseguro;
         ELSE
            num_recibo := f_contador('04', pcempres);
         END IF;

         vpasexec := 330;
         num_err := f_insrecibo(psseguro, pcagente, pfemisio, pfefecto, pfvencimi, pctiprec,
                                pnanuali, pnfracci, pccobban, pcestimp, NULL, num_recibo,
                                pmodo, psproces, pcmovimi, pnmovimi, pfefecto, 'CERTIF0', NULL,
                                NULL, pttabla, pfuncion,   -- BUG 21924 - MDS - 22/06/2012
                                NULL, pcdomper);

         IF num_err <> 0 THEN
            RETURN num_err;   --Error en la funcion insrecibo
         ELSE
            num_err := f_detrecibo(psproces, psseguro, num_recibo, ptipomovimiento, pmodo,
                                   pcmodcom, pfemisio, pfefecto, pfvencimi, pfcaranu,
                                   pnimport, NULL, pnmovimi, pcpoliza, pnimport2, NULL, 1,
                                   NULL, NULL, pcgarant, pttabla, pfuncion, pmovorigen);   -- BUG 34462 - AFM
            vpasexec := 340;

            IF num_err <> 0 THEN
               IF num_err = 103108 THEN   --Error controlado
                  --no se ha grabado nada en detrecibo
                  --no se emite recibo de ese riesgo
                  num_err := pac_gestion_rec.f_borra_recibo(num_recibo, 'P');

                  IF num_err <> 0 THEN
                     RETURN num_err;
                  END IF;
               ELSIF num_err = 105154 THEN   -- Error. Nº. asegurados = 0.
                  v_idioma := pac_parametros.f_parempresa_n(pcempres, 'IDIOMA_DEF');
                  texto := f_axis_literales(num_err, v_idioma);
                  num_recibo := NULL;
                  pnnumlin := NULL;
                  num_err := f_proceslin(psproces, texto, psseguro, pnnumlin);
               ELSE   --Error fatal
                  --Se cambia el error a retornar para obtener más información.
                  --RETURN 103138;  --Error para un riesgo en la función detrecibo
                  RETURN num_err;
               END IF;
            ELSE
               vpasexec := 350;

               -- si no hay error fusionamos los recibos no imprimibles
               IF ptipomovimiento IN(21, 22) THEN
                  num_err := f_fusionsupcar(psseguro, num_recibo, pfefecto, pfemisio, 'P',
                                            psproces);

                  IF num_err <> 0 THEN
                     RETURN num_err;
                  END IF;
               END IF;
               --num_recibo := NULL;
            --Que calcule el siguiente;
            END IF;
         END IF;

         -- Bug 7854 - 11/02/2009 - RSC - Recibo del certificado cero.
         -- Recibo del Certificado N

         --num_recibo := f_contador ('04', pcempres);
         IF pttabla = 'SOL' THEN
            num_recibo := psseguro;
         ELSE
            num_recibo := f_contador('04', pcempres);
         END IF;

         vpasexec := 360;
         num_err := f_insrecibo(psseguro, pcagente, pfemisio, pfefecto, pfvencimi, pctiprec,
                                pnanuali, pnfracci, pccobban, pcestimp, NULL, num_recibo,
                                pmodo, psproces, pcmovimi, pnmovimi, pfefecto, 'CERTIFN', NULL,
                                NULL, pttabla, pfuncion,   -- BUG 21924 - MDS - 22/06/2012
                                NULL, pcdomper);

         IF num_err <> 0 THEN
            RETURN num_err;   --Error en la funcion insrecibo
         ELSE
            num_err := f_detrecibo(psproces, psseguro, num_recibo, ptipomovimiento, pmodo,
                                   pcmodcom, pfemisio, pfefecto, pfvencimi, pfcaranu,
                                   pnimport, NULL, pnmovimi, pcpoliza, pnimport2, NULL, 2,
                                   NULL, NULL, pcgarant, pttabla, pfuncion, pmovorigen);   -- BUG 34462 - AFM
            vpasexec := 370;

            IF num_err <> 0 THEN
               IF num_err = 103108 THEN   --Error controlado
                  --no se ha grabado nada en detrecibo
                  --no se emite recibo de ese riesgo
                  num_err := pac_gestion_rec.f_borra_recibo(num_recibo);

                  IF num_err <> 0 THEN
                     RETURN num_err;
                  END IF;
               ELSIF num_err = 105154 THEN   -- Error. Nº. asegurados = 0.
                  v_idioma := pac_parametros.f_parempresa_n(pcempres, 'IDIOMA_DEF');
                  texto := f_axis_literales(num_err, v_idioma);
                  num_recibo := NULL;
                  pnnumlin := NULL;
                  num_err := f_proceslin(psproces, texto, psseguro, pnnumlin);
               ELSE   --Error fatal
                  --Se cambia el error a retornar para obtener más información.
                  --RETURN 103138;  --Error para un riesgo en la función detrecibo
                  RETURN num_err;
               END IF;
            ELSE
               vpasexec := 380;

               -- si no hay error fusionamos los recibos no imprimibles
               IF ptipomovimiento IN(21, 22) THEN
                  num_err := f_fusionsupcar(psseguro, num_recibo, pfefecto, pfemisio, 'P',
                                            psproces);

                  IF num_err <> 0 THEN
                     RETURN num_err;
                  END IF;
               END IF;
               --num_recibo := NULL;
            --Que calcule el siguiente;
            END IF;
         END IF;
            --END IF;
         --END LOOP;
------------ FI DELS CANVIS
      END IF;

-- 24926 I  miro si es un recibo de ahorra para marcar el subestado
      v_csubtiprec := pac_parametros.f_parempresa_n(NVL(pac_md_common.f_get_cxtempresa,
                                                        f_parinstalacion_n('EMPRESADEF')),
                                                    'SUBTIPREC_AHORRO');

      IF v_csubtiprec IS NOT NULL THEN
         IF pac_adm.f_es_recibo_ahorro(num_recibo) = 1 THEN
            UPDATE recibos
               SET csubtiprec = v_csubtiprec
             WHERE nrecibo = num_recibo;
         END IF;
      ELSE
         IF (NVL(pac_parametros.f_parempresa_n(NVL(pac_md_common.f_get_cxtempresa,
                                                   f_parinstalacion_n('EMPRESADEF')),
                                               'SUBTIPREC_ERRONEO'),
                 0) = 0) THEN
            UPDATE recibos
               SET csubtiprec = pctiprec
             WHERE nrecibo = num_recibo;
         END IF;
      END IF;

-- 24926 F  miro si es un recibo de ahorra para marcar el subestado
      RETURN 0;
   END IF;
EXCEPTION
  WHEN OTHERS THEN 
     p_tab_error(f_sysdate,
                      f_user,
                      'f_recries',
                      vpasexec,
                      'psseguro='||psseguro||' num_recibo='||num_recibo,
                      'SQLCODE = ' || SQLCODE || ' - ' || 'SQLERRM = ' ||
                      SQLERRM || 'v_error = ' || error);
     ROLLBACK;
     RETURN error;
END f_recries;

/
