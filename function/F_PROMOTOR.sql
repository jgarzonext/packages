--------------------------------------------------------
--  DDL for Function F_PROMOTOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_PROMOTOR" (psseguro IN NUMBER, ptnombre IN OUT VARCHAR2)
RETURN NUMBER AUTHID current_user IS
/***********************************************************************
  F_promotor : RETORNA EL nombre del promotor
  a partir del número de póliza
***********************************************************************/
BEGIN

    SELECT f_nombre(t.sperson,1,s.cidioma)
    INTO    ptnombre
    FROM     PROMOTORES  t, SEGUROS s, PLANPENSIONES PP, PROPLAPEN Pro
    WHERE s.sproduc = pro.sproduc
          AND pro.ccodpla = pp.ccodpla
          AND t.ccodpla = pp.ccodpla
          AND s.sseguro = psseguro
          AND NVL(t.npoliza,s.npoliza) = s.npoliza;

    RETURN 0;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ptnombre := '**';
        RETURN 0;
    WHEN OTHERS THEN
        RETURN 100524;  -- promotor nexistent
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_PROMOTOR" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_PROMOTOR" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_PROMOTOR" TO "PROGRAMADORESCSI";
