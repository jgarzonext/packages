--------------------------------------------------------
--  DDL for Function FF_BUSCAPADRE2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FF_BUSCAPADRE2" (
   pcempres IN NUMBER,
   pcagente IN NUMBER,
   pctipage IN NUMBER,
   pfbusca IN DATE)
RETURN NUMBER AUTHID CURRENT_USER IS
/*****************************************************************
   FF_BUSCAPADRE2:  Es retorna el codi del pare del agent que es
      correspongui amb l'empresa, amb el tipus
      i el periode sol.licitat (pcpadre null i pctipage informat).
   ALLIBMFM
*****************************************************************/
   xcagente       NUMBER;
   xctipage       NUMBER;
   xcpadre        NUMBER;
   codi_error     NUMBER := 0;
   trovat         NUMBER(1);
   wpadre         NUMBER;
   wtipage        NUMBER(2);
   pcpadre        NUMBER := NULL;
   wfbusca        DATE;
BEGIN
   IF pcempres IS NULL
      OR pcagente IS NULL
      OR(pcpadre IS NULL
         AND pctipage IS NULL)
      OR(pcpadre IS NOT NULL
         AND pctipage IS NOT NULL) THEN
      codi_error := 102780;
      RETURN(codi_error);
   END IF;

   IF pfbusca IS NULL THEN
      wfbusca := f_sysdate;
   END IF;

-- cas a):   pctipage NOT NULL  pcpadre IS NULL (a devolver)
-- -------
   IF pcpadre IS NULL THEN
      --      LECTURA DEL REGISTRE INICIAL
      -- Triem també el tipus
      SELECT cpadre, ctipage
        INTO wpadre, xctipage
        FROM redcomercial
       WHERE cagente = pcagente
         AND cempres = pcempres
         AND fmovini <= NVL(pfbusca, wfbusca)
         AND(fmovfin > NVL(pfbusca, wfbusca)
             OR fmovfin IS NULL);

      -- Mirem si ja és del tipus que busquem
      -- Tenim en compte el grup del tipus
      IF pctipage = 9
         AND xctipage = 9 THEN
         pcpadre := pcagente;
         trovat := 1;
      ELSIF pctipage = 4
            AND xctipage = 4 THEN
         pcpadre := pcagente;
         trovat := 1;
      ELSIF pctipage = 7
            AND xctipage = 7 THEN
         pcpadre := pcagente;
         trovat := 1;
      ELSIF pctipage = 6
            AND xctipage = 6 THEN
         pcpadre := pcagente;
         trovat := 1;
      ELSE
         trovat := 0;
      END IF;

      --LECTURA DE LA CADENA
      WHILE trovat = 0
       AND codi_error = 0 LOOP
         BEGIN
            SELECT cagente, ctipage, cpadre
              INTO xcagente, xctipage, xcpadre
              FROM redcomercial
             WHERE cagente = wpadre
               AND cempres = pcempres
               AND fmovini <= NVL(pfbusca, wfbusca)
               AND(fmovfin > NVL(pfbusca, wfbusca)
                   OR fmovfin IS NULL);

            -- Tenim en compte el grup del tipus
            IF pctipage = 9
               AND xctipage = 9 THEN
               pcpadre := xcagente;
               trovat := 1;
            ELSIF pctipage = 7
                  AND xctipage = 7 THEN
               pcpadre := xcagente;
               trovat := 1;
            ELSIF pctipage = 4
                  AND xctipage = 4 THEN
               pcpadre := xcagente;
               trovat := 1;
            ELSIF pctipage = 6
                  AND xctipage = 6 THEN
               pcpadre := xcagente;
               trovat := 1;
            ELSE
               IF xcpadre IS NOT NULL THEN
                  -- Controlem que la red comercial estigui bé
                  IF xcagente = xcpadre THEN
                     trovat := 1;
                     codi_error := 104358;
                  --Error en la tabla REDCOMERCIAL
                  ELSE
                     wpadre := xcpadre;
                  END IF;
               ELSE
                  pcpadre := NULL;
                  trovat := 1;
               END IF;
            END IF;
         EXCEPTION
            WHEN TOO_MANY_ROWS THEN
               codi_error := 104357;   --Depende de más de un agente
            WHEN NO_DATA_FOUND THEN
               codi_error := 104350;   --No se ha encontrado el agente del que depende
            WHEN OTHERS THEN
               codi_error := 104358;   --Error en la tabla REDCOMERCIAL
         END;
      END LOOP;
   END IF;

   RETURN(pcpadre);
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      codi_error := 102780;
      RETURN(codi_error);
   WHEN OTHERS THEN
      codi_error := 102780;
      RETURN(codi_error);
END;

/

  GRANT EXECUTE ON "AXIS"."FF_BUSCAPADRE2" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FF_BUSCAPADRE2" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FF_BUSCAPADRE2" TO "PROGRAMADORESCSI";
