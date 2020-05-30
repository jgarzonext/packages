--------------------------------------------------------
--  DDL for Function F_OBTEN_CMODCON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_OBTEN_CMODCON" (psperson NUMBER)
   RETURN NUMBER IS

/******************************************************************************
 Funció que calcula el cdomici que li correspon a una persona.
******************************************************************************/
   codi_contac    NUMBER:=0;
BEGIN
   IF psperson IS NOT NULL THEN
      SELECT nvl(MAX (cmodcon),0)
        INTO codi_contac
        FROM (SELECT MAX (cmodcon) cmodcon
                FROM contactos
               WHERE sperson = psperson
              UNION
              SELECT MAX (cmodcon) cmodcon
                FROM hiscontactos
               WHERE sperson = psperson);
   END IF;

   RETURN codi_contac+1;
END f_obten_cmodcon;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_OBTEN_CMODCON" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_OBTEN_CMODCON" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_OBTEN_CMODCON" TO "PROGRAMADORESCSI";
