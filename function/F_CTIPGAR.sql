--------------------------------------------------------
--  DDL for Function F_CTIPGAR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_CTIPGAR" (psproduc IN NUMBER, pcgarant IN NUMBER, pcactivi IN NUMBER )
   RETURN NUMBER AUTHID CURRENT_USER IS
/**********************************************************************************
  función que nos indica de que tipo es una garantia, en el caso de no encontrar la
  garantia no devuelve un cero 0, que es un tipo de garantia inexistente.
  BUG9595   27/03/2009  XCG     Añadir un nuevo parametro de la actividad.
**********************************************************************************/
   c_ctipgar      NUMBER;
BEGIN
   BEGIN
      SELECT ctipgar
        INTO c_ctipgar
        FROM garanpro g
       WHERE sproduc = psproduc
         AND cgarant = pcgarant
         AND cactivi = pcactivi;   --BUG9595
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         --BUG9595
         BEGIN
            SELECT ctipgar
              INTO c_ctipgar
              FROM garanpro g
             WHERE sproduc = psproduc
               AND cgarant = pcgarant
               AND cactivi = 0;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               c_ctipgar := 0;
         END;
   --fi  --BUG9595
   END;

   RETURN c_ctipgar;
END f_ctipgar; 
 
 

/

  GRANT EXECUTE ON "AXIS"."F_CTIPGAR" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_CTIPGAR" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_CTIPGAR" TO "PROGRAMADORESCSI";
