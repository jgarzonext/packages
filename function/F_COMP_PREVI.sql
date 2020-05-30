--------------------------------------------------------
--  DDL for Function F_COMP_PREVI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_COMP_PREVI" (
   psproces NUMBER,
   pcempres NUMBER,
   pcramo NUMBER,
   pcmodali NUMBER,
   pctipseg NUMBER,
   pccolect NUMBER,
   pdifpermesa NUMBER)
   RETURN NUMBER AUTHID CURRENT_USER IS
/*
    Función que realiza la comparación entre CSC y los datos de Caser y Winterthur
    cargados desde un fichero.

*/

   -- Se recuperan los registros con diferencias. Se supone que sólo existe un registro
   -- en vdetreciboscar para cada seguro.
   CURSOR dif IS
      SELECT   a.sseguro
          FROM reciboscar a, vdetreciboscar b, comp_previ c, seguros d
         WHERE a.nrecibo = b.nrecibo
           AND a.sseguro = d.sseguro
           AND((d.cramo = 24
                AND d.cmodali = 1
                AND d.ctipseg = 1
                AND d.ccolect = 3)
               OR   -- Winterthur: Multi Habitatge Col. Clients
                 (d.cramo = 24
                  AND d.cmodali = 1
                  AND d.ctipseg = 1
                  AND d.ccolect = 4)
               OR   -- Winterthur: Multi Habitatge Col. Empleats
                 (d.cramo = 25
                  AND d.cmodali = 1
                  AND d.ctipseg = 3
                  AND d.ccolect = 0)
               OR   -- Winterthur: Incendis Locals Comercials
                 (d.cramo = 25
                  AND d.cmodali = 1
                  AND d.ctipseg = 4
                  AND d.ccolect = 0)
               OR   -- Caser: Comerços
                 (d.cramo = 26
                  AND d.cmodali = 1
                  AND d.ctipseg = 3
                  AND d.ccolect = 0))   -- Caser: Immobles
           AND(d.cramo = NVL(pcramo, d.cramo)
               AND d.cmodali = NVL(pcmodali, d.cmodali)
               AND d.ctipseg = NVL(pctipseg, d.ctipseg)
               AND d.ccolect = NVL(pccolect, d.ccolect))
           AND a.sseguro = c.sseguro
           AND a.sproces = psproces
           AND a.cempres = pcempres
           AND(ABS(b.itotalr - c.pbruta) > NVL(pdifpermesa, 0)
               OR ABS(b.icomcia - c.comis) > NVL(pdifpermesa, 0))
      ORDER BY c.cramo, c.cmodali, c.ctipseg, c.ccolect;

-- INCENDIOS LOCALES COMERCIALES

   -- Se recuperan los registros que sólo existen en el fichero.
   CURSOR dif_fich IS
      SELECT a.sseguro
        FROM comp_previ a, seguros b
       WHERE a.sseguro = b.sseguro
         AND b.cempres = pcempres
         AND(b.cramo = NVL(pcramo, b.cramo)
             AND b.cmodali = NVL(pcmodali, b.cmodali)
             AND b.ctipseg = NVL(pctipseg, b.ctipseg)
             AND b.ccolect = NVL(pccolect, b.ccolect))
         AND a.sseguro NOT IN(SELECT DISTINCT c.sseguro
                                         FROM reciboscar c
                                        WHERE c.sproces = psproces);

   -- Se recuperan los registros que no existen en el fichero y sí en el previo.
   CURSOR dif_pre IS
      SELECT DISTINCT a.sseguro
                 FROM reciboscar a, seguros b
                WHERE a.sproces = psproces
                  AND a.sseguro = b.sseguro
                  AND a.cempres = pcempres
                  AND(b.cramo = NVL(pcramo, b.cramo)
                      AND b.cmodali = NVL(pcmodali, b.cmodali)
                      AND b.ctipseg = NVL(pctipseg, b.ctipseg)
                      AND b.ccolect = NVL(pccolect, b.ccolect))
                  AND a.sseguro NOT IN(SELECT c.sseguro
                                         FROM comp_previ c);

   xcramo         NUMBER;
   xcmodali       NUMBER;
   xctipseg       NUMBER;
   xccolect       NUMBER;
   xcontinente    NUMBER;
   xcontenido     NUMBER;
   xavmaqui       NUMBER;
   xdetalime      NUMBER;
   xpbruta        NUMBER;
   xpneta         NUMBER;
   xcomis         NUMBER;
   xdefec         DATE;
   xdvencim       DATE;
   xpolissa       VARCHAR2(15);
   error          NUMBER;
   xsseguro       NUMBER;
   xnomcli        VARCHAR2(80);
   xcidioma       NUMBER;
   comprobar      BOOLEAN := FALSE;
   cargarwin      BOOLEAN := FALSE;
   cargarcas      BOOLEAN := FALSE;
BEGIN
   -- Si se hace el previo de un determinado producto, se comprueba si es uno de los
   -- que se pueden comprobar. Si no es uno de estos, no se hace la comprobación.
   IF pcramo IS NOT NULL THEN
      IF ((pcramo = 24
           AND pcmodali = 1
           AND pctipseg = 1
           AND pccolect = 3)
          OR   -- Winterthur: Multi Habitatge Col. Clients
            (pcramo = 24
             AND pcmodali = 1
             AND pctipseg = 1
             AND pccolect = 4)
          OR   -- Winterthur: Multi Habitatge Col. Empleats
            (pcramo = 25
             AND pcmodali = 1
             AND pctipseg = 3
             AND pccolect = 0)) THEN   -- Winterthur: Incendis Locals Comercials
         cargarwin := TRUE;
      END IF;

      IF ((pcramo = 25
           AND pcmodali = 1
           AND pctipseg = 4
           AND NVL(pccolect, 0) = 0)
          OR   -- Caser: Comerços
            (pcramo = 26
             AND pcmodali = 1
             AND pctipseg = 3
             AND NVL(pccolect, 0) = 0)) THEN   -- Caser: Immobles
         cargarcas := TRUE;
      END IF;

      IF (cargarwin = TRUE)
         OR(cargarcas = TRUE) THEN
         comprobar := TRUE;
      ELSE
         comprobar := FALSE;
      END IF;
   ELSE
      comprobar := TRUE;
      cargarwin := TRUE;
      cargarcas := TRUE;
   END IF;

   IF comprobar = TRUE THEN
      IF cargarcas = TRUE THEN
         -- Se trata el fichero de Caser
         error := f_tratar_previ('C');

         IF error <> 0 THEN
            RETURN 111359;
         END IF;
      END IF;

      IF cargarwin = TRUE THEN
         -- Se trata el fichero de Winterthur
         error := f_tratar_previ('W');

         IF error <> 0 THEN
            RETURN 111359;
         END IF;
      END IF;

      -- Para cada registro diferente entre la información de los ficheros y el previo,
      -- se inserta un registro en dif_previ.
      FOR regdif IN dif LOOP
         BEGIN
            -- Se buscan los capitales calculados en el previo.
            SELECT   a.sseguro, SUM(a.icapital * DECODE(b.cvalpar, 1, 1, 0)),   -- 1: continente.
                     SUM(a.icapital * DECODE(b.cvalpar, 2, 1, 0)),   -- 2: contenido.
                     SUM(a.icapital * DECODE(b.cvalpar, 3, 1, 0)),   -- 3: averia maquinaria.
                     SUM(a.icapital * DECODE(b.cvalpar, 4, 1, 0))   -- 4: deterioro alimentos.
                INTO xsseguro, xcontinente,
                     xcontenido,
                     xavmaqui,
                     xdetalime
                FROM garancar a, pargaranpro b, seguros c
               WHERE a.sseguro = regdif.sseguro
                 AND a.sseguro = c.sseguro
                 AND a.sproces = psproces
                 AND b.cramo = c.cramo
                 AND b.cmodali = c.cmodali
                 AND b.ctipseg = c.ctipseg
                 AND b.ccolect = c.ccolect
                 AND b.cactivi = pac_seguros.ff_get_actividad(a.nriesgo, c.sseguro, 'CAR')
                 AND a.cgarant = b.cgarant
                 AND b.cpargar = 'TIPO'
            GROUP BY a.sseguro;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               BEGIN
                  SELECT   a.sseguro, SUM(a.icapital * DECODE(b.cvalpar, 1, 1, 0)),   -- 1: continente.
                           SUM(a.icapital * DECODE(b.cvalpar, 2, 1, 0)),   -- 2: contenido.
                           SUM(a.icapital * DECODE(b.cvalpar, 3, 1, 0)),   -- 3: averia maquinaria.
                           SUM(a.icapital * DECODE(b.cvalpar, 4, 1, 0))   -- 4: deterioro alimentos.
                      INTO xsseguro, xcontinente,
                           xcontenido,
                           xavmaqui,
                           xdetalime
                      FROM garancar a, pargaranpro b, seguros c
                     WHERE a.sseguro = regdif.sseguro
                       AND a.sseguro = c.sseguro
                       AND a.sproces = psproces
                       AND b.cramo = c.cramo
                       AND b.cmodali = c.cmodali
                       AND b.ctipseg = c.ctipseg
                       AND b.ccolect = c.ccolect
                       AND b.cactivi = 0
                       AND a.cgarant = b.cgarant
                       AND b.cpargar = 'TIPO'
                  GROUP BY a.sseguro;
               EXCEPTION
                  WHEN OTHERS THEN
                     xcontinente := 0;
                     xcontenido := 0;
                     xavmaqui := 0;
                     xdetalime := 0;
               END;
            WHEN OTHERS THEN
               xcontinente := 0;
               xcontenido := 0;
               xavmaqui := 0;
               xdetalime := 0;
         END;

         -- Se buscan las primas y comisiones del previo de cartera.
         SELECT a.itotalr, a.iprinet, a.icomcia, b.fefecto, b.fvencim
           INTO xpbruta, xpneta, xcomis, xdefec, xdvencim
           FROM vdetreciboscar a, reciboscar b
          WHERE b.sseguro = regdif.sseguro
            AND b.nrecibo = a.nrecibo
            AND b.sproces = psproces
            AND b.sproces = a.sproces;

         -- Se inserta un registro con las diferencias encontradas para poder generar el report.
         INSERT INTO dif_previ
                     (sproces, tipodif, cramo, cmodali, ctipseg, ccolect, polissa, sseguro,
                      nom_cli, continent, continent_f, contingut, contingut_f, avmaqui,
                      avmaqui_f, detalime, detalime_f, defec, defec_f, dvencim, dvencim_f,
                      pneta, pneta_f, pbruta, pbruta_f, comis, comis_f, bonifica)
            (SELECT psproces, 'D', cramo, cmodali, ctipseg, ccolect, polissa, sseguro, nom_cli,   -- D: diferencies.
                    xcontinente, continent, xcontenido, contingut, xavmaqui, avmaqui,
                    xdetalime, detalime, xdefec, defec, xdvencim, dvencim, xpneta, pneta,
                    xpbruta, pbruta, xcomis, comis, bonifica
               FROM comp_previ
              WHERE sseguro = regdif.sseguro);
      END LOOP;

      -- Se recuperan los registros que sólo existen en el fichero.
      FOR regfich IN dif_fich LOOP
         -- Se inserta un registro con los datos del fichero.
         INSERT INTO dif_previ
                     (sproces, tipodif, cramo, cmodali, ctipseg, ccolect, polissa, sseguro,
                      nom_cli, continent_f, contingut_f, avmaqui_f, detalime_f, defec_f,
                      dvencim_f, pneta_f, pbruta_f, comis_f, bonifica)
            (SELECT psproces, 'F', cramo, cmodali, ctipseg, ccolect, polissa, sseguro,
                    nom_cli,   -- F: fitxer
                            continent, contingut, avmaqui, detalime, defec, dvencim, pneta,
                    pbruta, comis, bonifica
               FROM comp_previ
              WHERE sseguro = regfich.sseguro);
      END LOOP;

      -- Recuperar los registros que se encuentran en Albor y no en los ficheros.
      FOR regpre IN dif_pre LOOP
         BEGIN
            -- Se buscan los capitales calculados en el previo.
            SELECT   a.sseguro, SUM(a.icapital * DECODE(b.cvalpar, 1, 1, 0)),   -- 1: continente.
                     SUM(a.icapital * DECODE(b.cvalpar, 2, 1, 0)),   -- 2: contenido.
                     SUM(a.icapital * DECODE(b.cvalpar, 3, 1, 0)),   -- 3: averia maquinaria.
                     SUM(a.icapital * DECODE(b.cvalpar, 4, 1, 0))   -- 4: deterioro alimentos.
                INTO xsseguro, xcontinente,
                     xcontenido,
                     xavmaqui,
                     xdetalime
                FROM garancar a, pargaranpro b, seguros c
               WHERE a.sseguro = regpre.sseguro
                 AND a.sseguro = c.sseguro
                 AND a.sproces = psproces
                 AND b.cramo = c.cramo
                 AND b.cmodali = c.cmodali
                 AND b.ctipseg = c.ctipseg
                 AND b.ccolect = c.ccolect
                 AND b.cactivi = pac_seguros.ff_get_actividad(a.nriesgo, c.sseguro, 'CAR')
                 AND a.cgarant = b.cgarant
                 AND b.cpargar = 'TIPO'
            GROUP BY a.sseguro;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               BEGIN
                  SELECT   a.sseguro, SUM(a.icapital * DECODE(b.cvalpar, 1, 1, 0)),   -- 1: continente.
                           SUM(a.icapital * DECODE(b.cvalpar, 2, 1, 0)),   -- 2: contenido.
                           SUM(a.icapital * DECODE(b.cvalpar, 3, 1, 0)),   -- 3: averia maquinaria.
                           SUM(a.icapital * DECODE(b.cvalpar, 4, 1, 0))   -- 4: deterioro alimentos.
                      INTO xsseguro, xcontinente,
                           xcontenido,
                           xavmaqui,
                           xdetalime
                      FROM garancar a, pargaranpro b, seguros c
                     WHERE a.sseguro = regpre.sseguro
                       AND a.sseguro = c.sseguro
                       AND a.sproces = psproces
                       AND b.cramo = c.cramo
                       AND b.cmodali = c.cmodali
                       AND b.ctipseg = c.ctipseg
                       AND b.ccolect = c.ccolect
                       AND b.cactivi = 0
                       AND a.cgarant = b.cgarant
                       AND b.cpargar = 'TIPO'
                  GROUP BY a.sseguro;
               EXCEPTION
                  WHEN OTHERS THEN
                     xcontinente := 0;
                     xcontenido := 0;
                     xavmaqui := 0;
                     xdetalime := 0;
               END;
            WHEN OTHERS THEN
               xcontinente := 0;
               xcontenido := 0;
               xavmaqui := 0;
               xdetalime := 0;
         END;

         BEGIN
            SELECT cramo, cmodali, ctipseg, ccolect
              INTO xcramo, xcmodali, xctipseg, xccolect
              FROM seguros
             WHERE sseguro = regpre.sseguro;
         END;

         -- Se recupera el número de contrato.
         SELECT polissa_ini
           INTO xpolissa
           FROM cnvpolizas
          WHERE sseguro = regpre.sseguro
            AND ram = xcramo
            AND moda = xcmodali
            AND tipo = xctipseg
            AND cole = xccolect;

         -- Se buscan las primas y comisiones del previo de cartera.
         SELECT a.itotalr, a.iprinet, a.icomcia, b.fefecto, b.fvencim
           INTO xpbruta, xpneta, xcomis, xdefec, xdvencim
           FROM vdetreciboscar a, reciboscar b
          WHERE b.sseguro = regpre.sseguro
            AND b.nrecibo = a.nrecibo
            AND b.sproces = psproces
            AND b.sproces = a.sproces;

         error := f_asegurado(regpre.sseguro, 1, xnomcli, xcidioma);

         IF error <> 0 THEN
            RETURN error;
         END IF;

         -- Se inserta un registro con las diferencias encontradas para poder generar el report.
         INSERT INTO dif_previ
                     (sproces, tipodif, cramo, cmodali, ctipseg, ccolect, polissa,
                      sseguro, nom_cli, continent, contingut, avmaqui, detalime,
                      defec, dvencim, pneta, pbruta, comis)
              VALUES (psproces, 'P', xcramo, xcmodali, xctipseg, xccolect, xpolissa,
                      regpre.sseguro, xnomcli,   -- P: previ
                                              xcontinente, xcontenido, xavmaqui, xdetalime,
                      xdefec, xdvencim, xpneta, xpbruta, xcomis);
      END LOOP;

      -- Borrar de Comp_Previ.
      DELETE FROM comp_previ;

      COMMIT;
   END IF;   -- comprobar = TRUE

   RETURN 0;
EXCEPTION
   WHEN OTHERS THEN
      -- Borrar datos de Comp_Previ Y Dif_Previ.
      DELETE      comp_previ;

      DELETE      dif_previ;

      COMMIT;
      RETURN 110474;   -- Error al realizar la comparación del previo de cartera.
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_COMP_PREVI" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_COMP_PREVI" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_COMP_PREVI" TO "PROGRAMADORESCSI";
