--------------------------------------------------------
--  DDL for Function F_RECRIESEXTRA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_RECRIESEXTRA" (
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
   pnrecibo OUT NUMBER)
   RETURN NUMBER AUTHID CURRENT_USER IS
/****************************************************************************
  F_RECRIESEXTRA:

    Creacion de la rutina de grabacion de recibos
      cuyo unico importe generado es el del concepto 26
      (conceptos extraordinarios)
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
                AND cmotmov = 242));

   CURSOR riesgo_modop IS
      SELECT nriesgo
        FROM riesgos
       WHERE sseguro = psseguro
         AND TRUNC(fefecto) <= TRUNC(pfefecto)
         AND(fanulac IS NULL
             OR(TRUNC(fanulac) > TRUNC(pfefecto)));

   num_err        NUMBER;
   num_recibo     NUMBER;
   almenosuno     NUMBER;
   error          NUMBER;
   texto          VARCHAR2(400);
   pnnumlin       NUMBER;
   w_nmovimi      movseguro.nmovimi%TYPE;
   v_idioma       NUMBER;
BEGIN
   pnrecibo := NULL;

   IF pmodo = 'R'
      OR pmodo = 'A' THEN
      IF pctipreb = 1 THEN   -- Un solo recibo al tomador
         num_err := f_insrecibo(psseguro, pcagente, pfemisio, pfefecto, pfvencimi, pctiprec,
                                pnanuali, pnfracci, pccobban, pcestimp, NULL, num_recibo,
                                pmodo, psproces, pcmovimi, w_nmovimi, pfefecto);

         IF num_err <> 0 THEN
            -- Devuelve el error de insrecibo
            RETURN num_err;
         ELSE
            num_err := f_detreciboextra(psproces, psseguro, num_recibo, ptipomovimiento,
                                        pmodo, pcmodcom, pfemisio, pfefecto, pfvencimi,
                                        pfcaranu, pnimport, NULL, pnmovimi, pcpoliza,
                                        pnimport2);

            IF num_err <> 0
               AND num_err <> 105154 THEN
               -- Devuelve el error de detrecibo
               RETURN num_err;
            ELSIF num_err = 105154 THEN
               v_idioma := pac_parametros.f_parempresa_n(pcempres, 'IDIOMA_DEF');
               texto := f_axis_literales(num_err, v_idioma);
               num_recibo := NULL;
               pnnumlin := NULL;
               num_err := f_proceslin(psproces, texto, psseguro, pnnumlin);
            ELSE   -- si no hay error fusionamos los recibos no imprimibles
               IF ptipomovimiento IN(21, 22) THEN
                  num_err := f_fusionsupcar(psseguro, num_recibo, pfefecto, pfemisio, 'R',
                                            psproces);

                  IF num_err <> 0 THEN
                     RETURN num_err;
                  END IF;
               END IF;
            END IF;
         END IF;
      ELSIF pctipreb = 2 THEN   -- Un recibo por riesgo(asegurado)
         BEGIN
            FOR rie IN riesgo_modor LOOP
               num_err := f_insrecibo(psseguro, pcagente, pfemisio, pfefecto, pfvencimi,
                                      pctiprec, pnanuali, pnfracci, pccobban, pcestimp,
                                      rie.nriesgo, num_recibo, pmodo, psproces, pcmovimi,
                                      w_nmovimi, pfefecto);

               IF num_err <> 0 THEN
                  RETURN num_err;   --Error en la funcion insrecibo
               ELSE
                  num_err := f_detreciboextra(psproces, psseguro, num_recibo, ptipomovimiento,
                                              pmodo, pcmodcom, pfemisio, pfefecto, pfvencimi,
                                              pfcaranu, pnimport, rie.nriesgo, pnmovimi,
                                              pcpoliza, pnimport2);

                  IF num_err <> 0 THEN
                     IF num_err = 103108 THEN   --Error controlado
                        --no se ha grabado nada en detrecibo
                        --no se emite recibo de ese riesgo
                        BEGIN
                           DELETE      movrecibo
                                 WHERE nrecibo = num_recibo;

                           DELETE      recibosredcom
                                 WHERE nrecibo = num_recibo;

                           DELETE      recibos
                                 WHERE nrecibo = num_recibo;
                        EXCEPTION
                           WHEN OTHERS THEN
                              RETURN 105155;
                        END;
                     ELSIF num_err = 105154 THEN   -- Error. Nº. asegurados = 0.
                        v_idioma := pac_parametros.f_parempresa_n(pcempres, 'IDIOMA_DEF');
                        texto := f_axis_literales(num_err, v_idioma);
                        num_recibo := NULL;
                        pnnumlin := NULL;
                        num_err := f_proceslin(psproces, texto, psseguro, pnnumlin);
                     ELSE   --Error fatal
                        RETURN 103138;   --Error para un riesgo en la función detrecibo
                     END IF;
                  ELSE
                     -- si no hay error fusionamos los recibos no imprimibles
                     IF ptipomovimiento IN(21, 22) THEN
                        num_err := f_fusionsupcar(psseguro, num_recibo, pfefecto, pfemisio,
                                                  'R', psproces);

                        IF num_err <> 0 THEN
                           RETURN num_err;
                        END IF;
                     END IF;

                     num_recibo := NULL;
                  --Que calcule el siguiente;
                  END IF;
               END IF;
            END LOOP;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 104952;   --Error en la función RECRIES
         END;
      END IF;

      RETURN 0;
   ELSIF pmodo = 'P' THEN
      IF pctipreb = 1 THEN   -- Un solo recibo al tomador
         num_recibo := f_contador('04', pcempres);
         num_err := f_insrecibo(psseguro, pcagente, pfemisio, pfefecto, pfvencimi, pctiprec,
                                pnanuali, pnfracci, pccobban, pcestimp, NULL, num_recibo,
                                pmodo, psproces, pcmovimi, pnmovimi, pfefecto);

         IF num_err <> 0 THEN
            RETURN num_err;
         -- RETURN 103136;
         END IF;

         num_err := f_detreciboextra(psproces, psseguro, num_recibo, ptipomovimiento, pmodo,
                                     pcmodcom, pfemisio, pfefecto, pfvencimi, pfcaranu,
                                     pnimport, NULL, pnmovimi, pcpoliza, pnimport2);

         IF num_err <> 0
            AND num_err <> 105154 THEN
            -- Devuelve el error de detrecibo
            RETURN num_err;
         ELSIF num_err = 105154 THEN
            v_idioma := pac_parametros.f_parempresa_n(pcempres, 'IDIOMA_DEF');
            texto := f_axis_literales(num_err, v_idioma);
            num_recibo := NULL;
            pnnumlin := NULL;
            num_err := f_proceslin(psproces, texto, psseguro, pnnumlin);
         ELSE   -- si no hay error fusionamos los recibos no imprimibles
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
            FOR rie IN riesgo_modop LOOP
               num_recibo := f_contador('04', pcempres);
               num_err := f_insrecibo(psseguro, pcagente, pfemisio, pfefecto, pfvencimi,
                                      pctiprec, pnanuali, pnfracci, pccobban, pcestimp,
                                      rie.nriesgo, num_recibo, pmodo, psproces, pcmovimi,
                                      pnmovimi, pfefecto);

               IF num_err <> 0 THEN
                  RETURN num_err;
               END IF;

               num_err := f_detreciboextra(psproces, psseguro, num_recibo, ptipomovimiento,
                                           pmodo, pcmodcom, pfemisio, pfefecto, pfvencimi,
                                           pfcaranu, pnimport, rie.nriesgo, pnmovimi, pcpoliza,
                                           pnimport2);

               IF num_err <> 0 THEN
                  IF num_err = 103108 THEN   --Error controlado
                     --no se ha grabado nada en detrecibo
                     --no se emite recibo de ese riesgo
                     BEGIN
                        DELETE      reciboscar
                              WHERE nrecibo = num_recibo;
                     EXCEPTION
                        WHEN OTHERS THEN
                           RETURN 105158;
                     END;
                  ELSIF num_err = 105154 THEN   -- Error. Nº. asegurados = 0.
                     v_idioma := pac_parametros.f_parempresa_n(pcempres, 'IDIOMA_DEF');
                     texto := f_axis_literales(num_err, v_idioma);
                     num_recibo := NULL;
                     pnnumlin := NULL;
                     num_err := f_proceslin(psproces, texto, psseguro, pnnumlin);
                  ELSE   --Error fatal
                     RETURN 103138;   --Error para un riesgo en la función detrecibo
                  END IF;
               ELSE
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
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 104952;   --Error en la función RECRIES
         END;
      END IF;

      pnrecibo := num_recibo;
      RETURN 0;
   END IF;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_RECRIESEXTRA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_RECRIESEXTRA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_RECRIESEXTRA" TO "PROGRAMADORESCSI";
