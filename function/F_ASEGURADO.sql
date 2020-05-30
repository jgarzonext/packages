--------------------------------------------------------
--  DDL for Function F_ASEGURADO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_ASEGURADO" (
   psseguro IN NUMBER,
   pnordtom IN NUMBER,
   ptnombre IN OUT VARCHAR2,
   pcidioma IN OUT NUMBER)
   RETURN NUMBER AUTHID CURRENT_USER IS
/***********************************************************************
 F_TOMADOR : Retorna el nombre y idioma del Tomador de la
  póliza a partir de su número.
 ALLIBCTR - Gestión de datos referentes a los seguros
 24-2-98 CPM (STRATEGY)
 01.0        09/08/2010   AVT  15638: CRE998 - Multiregistre cercador de pòlisses (Asegurat)
***********************************************************************/
BEGIN
-- SELECT f_nombre(t.sperson,1,s.cidioma),s.cidioma
   SELECT f_nombre(t.sperson, 1, s.cagente), s.cidioma
     INTO ptnombre, pcidioma
     FROM asegurados t, seguros s
    WHERE t.norden = pnordtom
      AND t.sseguro = psseguro
      AND s.sseguro = psseguro;

   RETURN 0;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      ptnombre := '**';
      RETURN 0;
   WHEN OTHERS THEN
      RETURN 100524;   -- Tomador inexistent
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_ASEGURADO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_ASEGURADO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_ASEGURADO" TO "PROGRAMADORESCSI";
