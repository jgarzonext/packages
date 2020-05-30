--------------------------------------------------------
--  DDL for Function F_TOMADOR_MV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_TOMADOR_MV" (
   psseguro IN NUMBER,
   pnordtom IN NUMBER,
   ptnombre IN OUT VARCHAR2,
   pcidioma IN OUT NUMBER,
   ppersona IN OUT NUMBER,
   pdomici IN OUT NUMBER)
   RETURN NUMBER AUTHID CURRENT_USER IS
/***********************************************************************

***********************************************************************/
BEGIN
   -- Bug10612 - 06/07/2009 - DCT (Canviar vista personas por tablas personas y añadir filtro de visión de agente)
   SELECT UPPER(LTRIM(RTRIM(SUBSTR(d.tnombre, 0, 20))) || ' '
                || LTRIM(RTRIM(SUBSTR(d.tapelli1, 0, 40))) || ' '
                || LTRIM(RTRIM(SUBSTR(d.tapelli2, 0, 20)))),
          DECODE(s.cidioma, NULL, d.cidioma, 0, d.cidioma, s.cidioma), t.sperson, t.cdomici
     INTO ptnombre,
          pcidioma, ppersona, pdomici
     FROM per_personas p, per_detper d, asegurados t, seguros s
    WHERE p.sperson = t.sperson
      AND t.norden = pnordtom
      AND t.sseguro = psseguro
      AND s.sseguro = psseguro
      AND d.sperson = p.sperson
      AND d.cagente = ff_agente_cpervisio(s.cagente, f_sysdate, s.cempres);

   /*SELECT UPPER(LTRIM(RTRIM(p.tnombre)) || ' ' || LTRIM(RTRIM(p.tapelli1)) || ' '
                || LTRIM(RTRIM(p.tapelli2))),
          DECODE(s.cidioma, NULL, p.cidioma, 0, p.cidioma, s.cidioma), t.sperson, t.cdomici
     INTO ptnombre,
          pcidioma, ppersona, pdomici
     FROM personas p, asegurados t, seguros s
    WHERE p.sperson = t.sperson
      AND t.norden = pnordtom
      AND t.sseguro = psseguro
      AND s.sseguro = psseguro;*/

   -- FI Bug10612 - 06/07/2009 - DCT (Canviar vista personas por tablas personas y añadir filtro de visión de agente)
   RETURN 0;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      ptnombre := '**';
      RETURN 0;
   WHEN OTHERS THEN
      RETURN 100524;   -- Tomador inexistent
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_TOMADOR_MV" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_TOMADOR_MV" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_TOMADOR_MV" TO "PROGRAMADORESCSI";
