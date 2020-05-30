--------------------------------------------------------
--  DDL for Function PRIMA_CONSUMIDA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."PRIMA_CONSUMIDA" (psseguro   IN NUMBER,
                                                      pnnumlin   IN NUMBER,
                                                     pfecha     IN DATE,
                                           pnriesgo   IN NUMBER DEFAULT NULL)
                       RETURN NUMBER IS
 consumida NUMBER;
 prih DATE;
 ulth DATE;
BEGIN
   prih := primera_hora(pfecha);
   ulth := ultima_hora(pfecha);
   SELECT NVL(SUM(ipricons), 0)
     INTO consumida
     FROM primas_consumidas
    WHERE sseguro = psseguro
      AND nnumlin = pnnumlin
      AND nriesgo = nvl(pnriesgo,nriesgo)
      AND fecha <= prih;
--      AND fecha between prih and ulth;
   RETURN consumida;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       RETURN 0;
     WHEN OTHERS THEN
       dbms_output.put_line(sqlerrm);
       RETURN Null;
END PRIMA_CONSUMIDA; 
 
 

/

  GRANT EXECUTE ON "AXIS"."PRIMA_CONSUMIDA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PRIMA_CONSUMIDA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PRIMA_CONSUMIDA" TO "PROGRAMADORESCSI";
