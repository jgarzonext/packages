--------------------------------------------------------
--  DDL for Function F_REHABILITA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_REHABILITA" (psseguro IN NUMBER, pcmotmov IN NUMBER, pcagente IN NUMBER,
                       pnmovimi OUT NUMBER)
RETURN NUMBER IS
BEGIN
  -- MSR 5/6/2007
  -- Antiga funció F_REHABILITA inclosa dins el package
  -- La funció es manté per compatibilitat però s'hauria d'esborrar
  RETURN(PAC_REHABILITA.F_REHABILITA(psseguro, pcmotmov, pcagente, pnmovimi));
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_REHABILITA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_REHABILITA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_REHABILITA" TO "PROGRAMADORESCSI";
