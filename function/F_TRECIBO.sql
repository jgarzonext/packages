--------------------------------------------------------
--  DDL for Function F_TRECIBO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_TRECIBO" (
   pnrecibo IN NUMBER,
   pcidioma IN NUMBER,
   ptlin1 OUT VARCHAR2,
   ptlin2 OUT VARCHAR2,
   ptlin3 OUT VARCHAR2,
   ptlin4 OUT VARCHAR2,
   ptlin5 OUT VARCHAR2,
   ptlin6 OUT VARCHAR2,
   ptlin7 OUT VARCHAR2,
   ptlin8 OUT VARCHAR2)
   RETURN NUMBER AUTHID CURRENT_USER IS
/***********************************************************************************************
    Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   2.0        01/04/2009  XCG                1. Modificació de la funció. Utilizar la función ff_get_actividad para buscar la actividad BUG9614
   3.0        03/11/2011  JMF                3. 0019791: LCOL_A001-Modificaciones de fase 0 en la consulta de recibos
***********************************************************************************************/

   /***************************************************************************
   F_TRECIBO: Devuelve el texto de los recibos
   ALLIBADM.
   Desaparece la función f_imprecibos4 y se
                sustituye por una SELECT en la tabla VDETRECIBOS.
      Se distingue el texto4 según cobjase del seguro
      Se añade en la línea 8 el nº de póliza antiguo
Se añade la actividad en la linea 3 si es un convenio.
se modifica que la asistencia dental y medica esta incluida
Se incorpora el tratamiento de los capitales revalorizados y las
cestas de UNIT LINK.
Se incorpora a la llamada de la función f_desproducto los
parametros ctipseg y ccolect para que la definición del producto sea la correcta
****************************************************************************/
   wfefecto       DATE;
   wfvencim       DATE;
   wsseguro       NUMBER;
   wnpoliza       NUMBER;
   wcramo         NUMBER;
   wncertif       NUMBER;
   wcmodali       NUMBER;
   wctipseg       NUMBER;
   wccolect       NUMBER;
   wnriesgo       NUMBER;
   wcobjase       NUMBER;
   wctiprec       NUMBER;
   wcempres       NUMBER;
   wcagente       NUMBER;
   wcdelega       NUMBER;
   wfemisio       DATE;
   wcactivi       NUMBER;
   wnmovimi       NUMBER;
   xcapcontinente NUMBER;
   xcapcontenido  NUMBER;
   wctipcoa       NUMBER;
   wcrevali       NUMBER;
   xcgestor       NUMBER;
   xtagente       VARCHAR2(20);
   xasistmed      BOOLEAN;
   xasistdent     BOOLEAN;
   error          NUMBER;
   pitotprima     NUMBER;
   pitotcon       NUMBER;
   pirecarg       NUMBER;
   pitotimp       NUMBER;
   pitotrec       NUMBER;
   ptriesgo1      VARCHAR2(200);
   ptriesgo2      VARCHAR2(200);
   ptriesgo3      VARCHAR2(200);
   texto1         VARCHAR2(400);
   texto2         VARCHAR2(400);
   texto3         VARCHAR2(400);
   poliz_format   VARCHAR2(20);
   xrecibo        VARCHAR2(100);
   xpoliza        VARCHAR2(30);
   titulo         VARCHAR2(40);
   texto4         VARCHAR2(400);
   primeuro       NUMBER;
   texto5         VARCHAR2(400);
   texto6         VARCHAR2(400);
   coneuro        NUMBER;
   texto7         VARCHAR2(400);
   receuro        NUMBER;
   texto8         VARCHAR(400);
   impeuro        NUMBER;
   texto9         VARCHAR2(400);
   texto10        VARCHAR2(400);
   texto10b       VARCHAR2(400);
   periodo        VARCHAR2(40);
   ant_npoliza    VARCHAR2(15);
   ptlin7_a       VARCHAR2(58);
   ptlin7_b       VARCHAR2(22);
   texto11        VARCHAR2(20);
   dummy          NUMBER;
BEGIN
   IF pnrecibo IS NOT NULL
      AND pcidioma IS NOT NULL THEN
      BEGIN
         SELECT r.fefecto, r.fvencim, s.sseguro, s.npoliza, s.ncertif, s.cramo, s.cmodali,
                s.ctipseg, s.ccolect, r.nriesgo, s.cobjase, r.ctiprec, r.cempres, r.cagente,
                r.femisio, r.cdelega, pac_seguros.ff_get_actividad(s.sseguro, r.nriesgo),
                r.nmovimi, r.ctipcoa, s.crevali
           INTO wfefecto, wfvencim, wsseguro, wnpoliza, wncertif, wcramo, wcmodali,
                wctipseg, wccolect, wnriesgo, wcobjase, wctiprec, wcempres, wcagente,
                wfemisio, wcdelega, wcactivi,
                wnmovimi, wctipcoa, wcrevali
           FROM seguros s, recibos r
          WHERE r.nrecibo = pnrecibo
            AND r.sseguro = s.sseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 102838;   --Recibo no encontrado en la tabla RECIBOS
         WHEN OTHERS THEN
            RETURN 102367;   -- Error al llegir de la taula RECIBOS
      END;

      BEGIN
         SELECT itotpri, itotcon, itotrec - itotdto, itotimp, itotalr
           INTO pitotprima, pitotcon, pirecarg, pitotimp, pitotrec
           FROM vdetrecibos
          WHERE nrecibo = pnrecibo;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 103936;   -- Rebut no trobat a VDETRECIBOS
         WHEN OTHERS THEN
            RETURN 103920;   -- Error al llegir de VDETRECIBOS
      END;

      BEGIN
         SELECT polissa_ini
           INTO ant_npoliza
           FROM cnvpolizas
          WHERE sseguro = wsseguro;
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

-- (YSR) Solamente esta incluida si no se ha dado de baja.
      BEGIN
         SELECT sseguro
           INTO dummy
           FROM garanseg
          WHERE sseguro = wsseguro
            AND nriesgo = NVL(wnriesgo, 1)
            AND cgarant = 94
            AND ffinefe IS NULL;   -- Assistència Mèdica

         xasistmed := TRUE;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            xasistmed := FALSE;
         WHEN OTHERS THEN
            RETURN 103500;   -- Error al llegir de GARANSEG
      END;

-- (YSR) Solamente esta incluida si no se ha dado de baja.
      BEGIN
         SELECT sseguro
           INTO dummy
           FROM garanseg
          WHERE sseguro = wsseguro
            AND nriesgo = NVL(wnriesgo, 1)
            AND cgarant = 95
            AND ffinefe IS NULL;   -- Assistència Dental

         xasistdent := TRUE;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            xasistdent := FALSE;
         WHEN OTHERS THEN
            RETURN 103500;   -- Error al llegir de GARANSEG
      END;

      error := f_desriesgo(wsseguro, wnriesgo, wfefecto, pcidioma, ptriesgo1, ptriesgo2,
                           ptriesgo3);
      ptriesgo1 := SUBSTR(ptriesgo1, 1, 40);
      ptriesgo2 := SUBSTR(ptriesgo2, 1, 40);
      ptriesgo3 := SUBSTR(ptriesgo3, 1, 40);

      IF error = 0 THEN
         BEGIN
--1ª Línea------------------------------------------
            texto1 := f_axis_literales(103006, pcidioma);
            texto2 := f_axis_literales(102828, pcidioma);
            texto3 := f_axis_literales(102829, pcidioma);
            poliz_format := f_formatopol(wnpoliza, wncertif, 1);
            error := f_periode(pnrecibo, periodo);

            IF error <> 0 THEN
               RETURN error;
            END IF;

            xrecibo := texto1 || ' ' || TO_CHAR(pnrecibo) || ' ' || texto2 || ' ' || periodo;
            xpoliza := texto3 || ' ' || poliz_format;
            ptlin1 := RPAD(xrecibo, 57, ' ') || RPAD(xpoliza, 23, ' ');
--2ª Línea------------------------------------------------------
            error := f_desproducto(wcramo, wcmodali, 1, pcidioma, titulo, wctipseg, wccolect);

            IF error <> 0 THEN
               RETURN error;
            END IF;

            xcgestor := f_gestor(wcempres, wcagente, wfemisio);
            xtagente := wcagente || ' / ' || xcgestor || ' / ' || wcdelega;
            ptlin2 := RPAD(titulo, 57, ' ') || RPAD(xtagente, 23, ' ');

   --3ª Línea-------------------------------------------------------
-- (YSR) en los recibos de convenios debe salir la actividad de la poliza
            IF (wcempres = 2
                AND wcramo = 42)
               OR(wcempres = 3
                  AND wcramo = 51) THEN
               error := f_desactivi(wcactivi, wcramo, pcidioma, texto4);

               IF error <> 0 THEN
                  RETURN error;
               END IF;
            ELSE
               IF wcobjase = 1 THEN
                  texto4 := f_axis_literales(101028, pcidioma);   --Asegurado
               ELSE
                  texto4 := f_axis_literales(105395, pcidioma);   --Situación de riesgo
               END IF;
            END IF;

            texto5 := f_axis_literales(102831, pcidioma);
            error := f_cambio(2, 1, pitotprima, primeuro);

            IF error <> 0 THEN
               RETURN error;
            END IF;

            ptlin3 := RPAD(texto4, 40, ' ') || texto5 || TO_CHAR(pitotprima, '9999G999G990')
                      || ' '
                      || LPAD(('(' || LTRIM(TO_CHAR(primeuro, '9G999G990D00')) || ')'), 13,
                              ' ');
--4ª Línea-------------------------------------------------------
            texto6 := f_axis_literales(102832, pcidioma);
            error := f_cambio(2, 1, pitotcon, coneuro);

            IF error <> 0 THEN
               RETURN error;
            END IF;

            IF pitotcon <> 0 THEN
               ptlin4 := RPAD(ptriesgo1, 40, ' ') || texto6
                         || TO_CHAR(pitotcon, '9999g999g990') || ' '
                         || LPAD(('(' || LTRIM(TO_CHAR(coneuro, '9g999g990d00')) || ')'), 13,
                                 ' ');
            ELSE
               ptlin4 := RPAD(ptriesgo1, 40, ' ');
            END IF;

--5ª Línea-------------------------------------------------------
            texto7 := f_axis_literales(102833, pcidioma);
            error := f_cambio(2, 1, pirecarg, receuro);

            IF error <> 0 THEN
               RETURN error;
            END IF;

            IF pirecarg <> 0 THEN
               ptlin5 := RPAD(NVL(ptriesgo2, ' '), 40, ' ') || texto7
                         || TO_CHAR(pirecarg, '9999g999g990') || ' '
                         || LPAD(('(' || LTRIM(TO_CHAR(receuro, '9g999g990d00')) || ')'), 13,
                                 ' ');
            ELSE
               ptlin5 := RPAD(NVL(ptriesgo2, ' '), 40, ' ');
            END IF;

--6ª Línea-------------------------------------------------------
            texto8 := f_axis_literales(102834, pcidioma);
            error := f_cambio(2, 1, pitotimp, impeuro);

            IF error <> 0 THEN
               RETURN error;
            END IF;

            IF pitotimp <> 0 THEN
               ptlin6 := RPAD(NVL(ptriesgo3, ' '), 40, ' ') || texto8
                         || TO_CHAR(pitotimp, '9999g999g990') || ' '
                         || LPAD(('(' || LTRIM(TO_CHAR(impeuro, '9g999g990d00')) || ')'), 13,
                                 ' ');
            ELSE
               ptlin6 := RPAD(NVL(ptriesgo3, ' '), 40, ' ');
            END IF;

--7ª Línea-------------------------------------------------------
            IF wcramo = 41
               AND wcmodali = 1
               AND wccolect = 0
               AND(wctipseg = 0
                   OR wctipseg = 1) THEN
               IF wctiprec IN(9, 13) THEN   -- Es un extorn o Retorn (bug 0019791)
                  ptlin7_a := NULL;
               ELSE
                  -- No és un extorn
                  IF xasistmed THEN
                     texto10 := f_axis_literales(105284, pcidioma);
                     ptlin7_a := texto10;   -- Assistència Mèdica Inclosa
                  ELSE
                     ptlin7_a := NULL;
                  END IF;
               END IF;
            ELSE   -- No és de Segunda Generación
               IF wcrevali <> 0 THEN
                  error := f_capreval(wsseguro, wnmovimi, wctipcoa, xcapcontinente,
                                      xcapcontenido);

                  IF error <> 0 THEN
                     RETURN error;
                  END IF;
               END IF;

               IF xcapcontinente <> 0
                  OR xcapcontenido <> 0 THEN
                  texto10 := f_axis_literales(107616, pcidioma);   -- Continente
                  texto10b := f_axis_literales(107617, pcidioma);   -- Contenido
                  ptlin7_a := texto10 || TO_CHAR(xcapcontinente, '9999999g999g990') || '   '
                              || texto10b || TO_CHAR(xcapcontenido, '9999999g999g990');
               ELSE
                  ptlin7_a := NULL;
               END IF;
            END IF;

            IF ant_npoliza IS NOT NULL THEN
               texto11 := f_axis_literales(104778, pcidioma);
               ptlin7_b := texto11 || ' ' || ant_npoliza;
            ELSE
               ptlin7_b := NULL;
            END IF;

            ptlin7 := RPAD(NVL(ptlin7_a, ' '), 58, ' ') || ptlin7_b;

--8ª Línea-------------------------------------------------------
            IF wcramo = 41
               AND wcmodali = 1
               AND wccolect = 0
               AND(wctipseg = 0
                   OR wctipseg = 1) THEN
               IF wctiprec IN(9, 13) THEN   -- Es un extorn o Retorn (bug 0019791)
                  ptlin8 := NULL;
               ELSE   -- No és un extorn
                  IF xasistdent THEN
                     texto9 := f_axis_literales(105283, pcidioma);
                     ptlin8 := texto9;   -- Assistència Dental     Inclosa
                  ELSE
                     ptlin8 := NULL;
                  END IF;
               END IF;
            ELSE   -- No és de Segunda Generación
               IF pitotcon <> 0 THEN
                  texto9 := f_axis_literales(107641, pcidioma);   -- Info del Consorci
                  ptlin8 := texto9;
               ELSE
                  IF wcramo = 35 THEN
                     error := f_litlink(wsseguro, pcidioma, ptlin8);
                  ELSE
                     ptlin8 := NULL;
                  END IF;
               END IF;
            END IF;

            RETURN 0;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 102840;   -- Error construïnt les línies a f_trecibo
         END;
      ELSE
         RETURN error;
      END IF;
   ELSE
      RETURN 101901;   -- Pas incorrecte de paràmetres a la funció
   END IF;
END;
 

/

  GRANT EXECUTE ON "AXIS"."F_TRECIBO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_TRECIBO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_TRECIBO" TO "PROGRAMADORESCSI";
