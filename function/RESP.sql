--------------------------------------------------------
--  DDL for Function RESP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."RESP" (psesion IN NUMBER, resp IN NUMBER)
   RETURN NUMBER AUTHID CURRENT_USER IS
   --pvalor         NUMBER;
   param          VARCHAR2(10);
BEGIN
   param := 'RESP' || resp;
   -- I - JLB
    -- SELECT valor
    --   INTO pvalor
    --   FROM sgt_parms_transitorios
    --  WHERE sesion = psesion
    --    AND parametro = param;
   RETURN pac_sgt.get(psesion, param);
  --  RETURN(pvalor);
-- F - JLB
EXCEPTION
   WHEN OTHERS THEN
      RETURN NULL;
END;

/

  GRANT EXECUTE ON "AXIS"."RESP" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."RESP" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."RESP" TO "PROGRAMADORESCSI";
