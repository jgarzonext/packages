--------------------------------------------------------
--  DDL for Function F_ULTRENOVA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_ULTRENOVA" (
   psseguro IN NUMBER,
   pfecha IN DATE,
   pfrenova OUT DATE,
   pnmovimi OUT NUMBER)
   RETURN NUMBER AUTHID CURRENT_USER IS
/************************************************************************************************
   F_ULTRENOVA Calcula la última fecha de renovación y el número de movimiento
               anterior a la fecha introducida.
***********************************************************************************************/

--Bug.: 10709 - ICV - 16/07/09 - Se elige la fecha de impuestos dependiendo de parametro.
BEGIN
/*
  SELECT max(nvl(h1.frevant, h1.fefecto)), max(h1.nmovimi)
  INTO pfrenova,pnmovimi
  FROM historicoseguros h1
  WHERE h1.sseguro = psseguro
    AND h1.fefecto = (SELECT MAX(h2.fefecto)
                      FROM historicoseguros h2
                      WHERE h2.sseguro = h1.sseguro
                        AND h2.fefecto <= pfecha);
  RETURN 0;
EXCEPTION
  WHEN OTHERS THEN


   BEGIN*/--Fin bug. 10709
   SELECT MAX(m.fefecto), MAX(m.nmovimi)
     INTO pfrenova, pnmovimi
     FROM movseguro m
    WHERE m.sseguro = psseguro
      AND m.fefecto = (SELECT MAX(t.fefecto)
                         FROM movseguro t
                        WHERE t.sseguro = m.sseguro
                          AND t.cmovseg IN(2, 0)
                          AND t.fefecto <= pfecha)
      AND m.cmovseg IN(2, 0);

   RETURN 0;
EXCEPTION
   WHEN OTHERS THEN
      RETURN(104349);
END f_ultrenova;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_ULTRENOVA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_ULTRENOVA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_ULTRENOVA" TO "PROGRAMADORESCSI";
