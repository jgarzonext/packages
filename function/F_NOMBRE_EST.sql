--------------------------------------------------------
--  DDL for Function F_NOMBRE_EST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_NOMBRE_EST" (
   psperson IN estper_personas.sperson%TYPE,
   pnformat IN NUMBER,
   psseguro IN estseguros.sseguro%TYPE DEFAULT NULL)
   RETURN VARCHAR2 IS
/****************************************************************************
    F_NOMBRE: DEVUELVE EL NOMBRE DE UNA PERSONA FORMATEADO, SEGÚN EL
            FORMATO DESEADO.
            PNFORMAT = 1 => < APELLIDOS, NOMBRE >
            PNFORMAT = 2 => < NIF   APELLIDOS, NOMBRE >
    ALLIBMFM.
    MODIFICO EL FORMAT 2, PER FER-LO UNA MICA
    MÉS ESPAIAT.
    Las personas van por empresa.
****************************************************************************/
   pnombre        VARCHAR2(405);
   pnombre2       VARCHAR2(410);
   letra1         VARCHAR2(1);
   pnnumnif       VARCHAR2(14);
BEGIN
   IF pnformat = 3 THEN
   BEGIN
      SELECT DECODE(pd.tnombre,
                    NULL, NULL,
                    pd.tnombre || ' ' || pd.tapelli1 || ' ' || pd.tapelli2),
             nnumide
        INTO pnombre,
             pnnumnif
        FROM estper_personas p, estper_detper pd
       WHERE p.sperson = psperson
         AND p.sperson = pd.sperson
         --AND p.swpubli = 1
         AND(pd.cagente = p.cagente
             OR p.cagente IS NULL);
             EXCEPTION
WHEN NO_DATA_FOUND THEN
SELECT DECODE(pd.tnombre,
                    NULL, NULL,
                    pd.tnombre || ' ' || pd.tapelli1 || ' ' || pd.tapelli2),
             nnumide
INTO pnombre,
     pnnumnif
FROM estpersonas pd
WHERE sperson = psperson
AND ROWNUM = 1;
END;
   ELSE
   BEGIN
      SELECT LTRIM(RTRIM(pd.tapelli1))
             || DECODE(pd.tnombre, NULL, NULL, ', ' || LTRIM(RTRIM(pd.tnombre))),
             nnumide
        INTO pnombre,
             pnnumnif
        FROM estper_personas p, estper_detper pd
       WHERE p.sperson = psperson
         AND p.sperson = pd.sperson
         --AND p.swpubli = 1
         AND(pd.cagente = p.cagente
             OR p.cagente IS NULL);
             EXCEPTION
WHEN NO_DATA_FOUND THEN
SELECT LTRIM(RTRIM(pd.tapelli1))
             || DECODE(pd.tnombre, NULL, NULL, ', ' || LTRIM(RTRIM(pd.tnombre))),
             nnumide
INTO pnombre,
             pnnumnif
FROM estpersonas pd
WHERE sperson = psperson
AND ROWNUM = 1;
END;
   END IF;

   IF pnformat IN(1, 3) THEN
      RETURN pnombre;
   ELSIF pnformat = 2 THEN
      IF pnnumnif IS NOT NULL THEN
         --letra1 := SUBSTR (pnnumnif, 1, 1);
         IF SUBSTR(pnnumnif, 1, 2) = 'ZZ' THEN
            pnombre2 := '            ' || pnombre;
         ELSE
            pnombre2 := pnnumnif || '   ' || pnombre;
         END IF;
      END IF;

      RETURN pnombre2;
   END IF;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN('**');
END;

/

  GRANT EXECUTE ON "AXIS"."F_NOMBRE_EST" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_NOMBRE_EST" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_NOMBRE_EST" TO "PROGRAMADORESCSI";
