--------------------------------------------------------
--  DDL for Function F_FCONTABSINI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_FCONTABSINI" ( psseguro IN NUMBER,
		     pfmovdia IN DATE,
             pfcontab OUT DATE ) RETURN NUMBER authid current_user IS
  minmesabierto   DATE;
  maxmesabierto   DATE;
  vempresa		  NUMBER;
  FALTAN_PARAMETROS EXCEPTION;
BEGIN
  IF psseguro IS NULL OR pfmovdia IS NULL THEN
      RAISE FALTAN_PARAMETROS;
  END IF;

  BEGIN
    SELECT DISTINCT(cempres) INTO vempresa
    FROM SEGUROS
    WHERE sseguro=psseguro;  --búsqueda de la empresa
  EXCEPTION
   WHEN NO_DATA_FOUND THEN
    Pfcontab:=NULL;
    RETURN(-1);
  END;

-- FECHAS DE PRODUCCIÓN
    -- Primer día del mes abierto
    BEGIN
      SELECT MAX(fperfin) + 1  INTO minmesabierto
      FROM cierres
	  WHERE ctipo = 2
	    AND cempres = vempresa
	    AND fcierre < pfmovdia;
    EXCEPTION
      WHEN OTHERS THEN RETURN SQLCODE;
    END;

    -- Último día del mes abierto
    BEGIN
      SELECT LAST_DAY( MAX(fperfin) + 1 ) INTO maxmesabierto
      FROM cierres
	  WHERE ctipo = 2
 	    AND cempres = vempresa
	    AND fcierre < pfmovdia;
    EXCEPTION
      WHEN OTHERS THEN RETURN SQLCODE;
    END;

-- FECHAS DE MOVIMIENTO
    IF TRUNC(pfmovdia) BETWEEN minmesabierto AND maxmesabierto THEN
	  pfcontab := TRUNC(pfmovdia);
	ELSIF TRUNC(pfmovdia) > maxmesabierto THEN
	  pfcontab := maxmesabierto;
	ELSIF TRUNC(pfmovdia) < minmesabierto THEN
	  pfcontab := minmesabierto;
	END IF;

RETURN 0;
EXCEPTION
WHEN FALTAN_PARAMETROS THEN
    Pfcontab:=NULL;
    RETURN(-1);
END F_FContabSini;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_FCONTABSINI" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_FCONTABSINI" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_FCONTABSINI" TO "PROGRAMADORESCSI";
