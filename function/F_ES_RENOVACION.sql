--------------------------------------------------------
--  DDL for Function F_ES_RENOVACION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_ES_RENOVACION" (psseguro IN NUMBER)
   RETURN NUMBER AUTHID CURRENT_USER IS
/****************************************************************************
   F_ES_RENOVACION: Nos dice si una póliza ha hecho alguna renovacion de
              cartera o no( si sigue siendo nueva producción)
   ALLIBADM
   2.0 : SMF   20149  se modifica la función para que solo tenga en cuenta los cmovseg =2 que
                      corresponde. 404 : renovación de cartera
****************************************************************************/
   seguro         NUMBER;
BEGIN
   SELECT DISTINCT sseguro
              INTO seguro
              FROM movseguro
             WHERE sseguro = psseguro
               AND cmovseg + 0 = 2   -- movimiento de cartera (se pone el + 0 para romper
               AND cmotmov IN(404, 406);   --20149 carteras de renovación

   -- el indice si hubiera y que entre poe el indice
   -- MOVSEG_PK)
   RETURN 0;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN 1;
END;

/

  GRANT EXECUTE ON "AXIS"."F_ES_RENOVACION" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_ES_RENOVACION" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_ES_RENOVACION" TO "PROGRAMADORESCSI";
