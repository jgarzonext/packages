--------------------------------------------------------
--  DDL for Function FF_TOMADOR_PER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FF_TOMADOR_PER" (psseguro IN SEGUROS.sseguro%TYPE, pnordtom IN TOMADORES.nordtom%TYPE)
RETURN VARCHAR2 authid current_user IS
/***********************************************************************
   Retorna el nombre de un tomador dado un SSEGURO y NORDTOM
***********************************************************************/
   w_tnombre  varchar2(100);
BEGIN
    SELECT TRIM(tapelli1)||' '||TRIM(tapelli2) || DECODE(tnombre, NULL, NULL, ', '||TRIM(tnombre))
    INTO     w_tnombre
    FROM     PER_DETPER p, TOMADORES t, SEGUROS s
    WHERE  p.sperson = t.sperson
    AND    t.nordtom = pnordtom
    AND    t.sseguro = psseguro
    AND    s.sseguro = psseguro
    AND    p.cagente = ff_agente_cpervisio(s.cagente);
    RETURN (w_tnombre);
EXCEPTION
    WHEN no_data_found THEN
        w_tnombre := '**';
        RETURN (w_tnombre);
    WHEN others THEN
        RETURN ('Tomador Inexistente');  -- Tomador inexistent
END;

/

  GRANT EXECUTE ON "AXIS"."FF_TOMADOR_PER" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FF_TOMADOR_PER" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FF_TOMADOR_PER" TO "PROGRAMADORESCSI";
