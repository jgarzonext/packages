--------------------------------------------------------
--  DDL for Function F_ESTTOMADOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_ESTTOMADOR" (
   psseguro   IN       NUMBER,
   pnordtom   IN       NUMBER,
   ptnombre   IN OUT   VARCHAR2,
   pcidioma   IN OUT   NUMBER
)
   RETURN NUMBER AUTHID CURRENT_USER

IS
/***********************************************************************
F_TOMADOR : Retorna el nombre y idioma del Tomador de la
póliza a partir de su número.
ALLIBCTR - Gestión de datos referentes a los seguros
***********************************************************************/
   vsperson estper_personas.sperson%type;
BEGIN

   SELECT p.sperson,
          DECODE (s.cidioma, NULL, p.cidioma, 0, p.cidioma, s.cidioma),
          LTRIM (RTRIM (tapelli1))||LTRIM (RTRIM (tapelli2))
          || DECODE (tnombre, NULL, NULL, ', ' || LTRIM (RTRIM (tnombre)))
   INTO vsperson,
        Pcidioma,
        PTNOMBRE
   FROM estpersonas p, esttomadores t, estseguros s
   WHERE p.sperson = t.sperson
        and t.sseguro = psseguro
        and s.sseguro = psseguro
        and t.nordtom = nvl( pnordtom, 1);

    RETURN 0;

EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      ptnombre := '**';
      RETURN 0;
   WHEN OTHERS
   THEN
      RETURN 100524;                                    -- Tomador inexistent
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_ESTTOMADOR" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_ESTTOMADOR" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_ESTTOMADOR" TO "PROGRAMADORESCSI";
