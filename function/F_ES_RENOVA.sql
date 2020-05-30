--------------------------------------------------------
--  DDL for Function F_ES_RENOVA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_ES_RENOVA" (psseguro IN NUMBER, pfecha IN DATE)
   RETURN NUMBER AUTHID CURRENT_USER IS
/****************************************************************************
 F_ES_RENOVACION: NOS DICE SI UNA PÓLIZA HA HECHO ALGUNA RENOVACION DE
        CARTERA O NO( SI SIGUE SIENDO NUEVA PRODUCCIÓN),
                             ANTES DE UNA FECHA
        RETORNA:   0 SI ES CARTERA
                   1 SI ES NUEVA PRODUCCIÓN
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
               AND fefecto <= pfecha
               AND cmovseg + 0 = 2
               AND cmotmov IN(404, 406);   -- MOVIMIENTO DE CARTERA (SE PONE EL + 0 PARA ROMPER

   -- EL INDICE SI HUBIERA Y QUE ENTRE POR EL INDICE
   -- MOVSEG_PK)
   RETURN 0;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN 1;
END;

/

  GRANT EXECUTE ON "AXIS"."F_ES_RENOVA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_ES_RENOVA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_ES_RENOVA" TO "PROGRAMADORESCSI";
