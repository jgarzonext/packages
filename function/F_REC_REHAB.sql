--------------------------------------------------------
--  DDL for Function F_REC_REHAB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_REC_REHAB" (psseguro  IN NUMBER, pnmovimi IN NUMBER, pnrecibo OUT NUMBER)
RETURN NUMBER authid current_user IS
  -- MSR 5/6/2007
  -- Antiga funció F_REC_REHAB inclosa dins el package i renombrada com F_RECIBOS
  -- La funció es manté per compatibilitat però s'hauria d'esborrar
BEGIN
  RETURN (PAC_REHABILITA.F_RECIBOS (psseguro, pnmovimi, pnrecibo) );
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_REC_REHAB" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_REC_REHAB" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_REC_REHAB" TO "PROGRAMADORESCSI";
