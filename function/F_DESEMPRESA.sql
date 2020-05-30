--------------------------------------------------------
--  DDL for Function F_DESEMPRESA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_DESEMPRESA" (pcempres IN NUMBER, pnpoliza IN NUMBER, ptempres IN
		OUT VARCHAR2)
RETURN NUMBER authid current_user IS
/***********************************************************************
	F_DESEMPRESA: Descripción de la Empresa.
	ALLIBMFM

	 Añadir búsqueda de empresa con certificado = 0.
	S' ha de buscar un certificat que existeixi
	per a la pòlissa entrada.
***********************************************************************/
	xcempres	NUMBER;
	xncertif		NUMBER;
BEGIN
ptempres := NULL;
IF pcempres IS NULL THEN
	IF pnpoliza IS NOT NULL THEN
	  BEGIN
	    SELECT NVL(min(ncertif), 0)
	    INTO xncertif
	    FROM seguros
	    WHERE npoliza = pnpoliza;
	  EXCEPTION
	    WHEN others THEN
		RETURN 101903;		-- Assegurança no trobada a SEGUROS
	  END;
	  BEGIN
	    SELECT 	r.cempres
	    INTO	xcempres
	    FROM	CODIRAM r, SEGUROS s
	    WHERE 	r.cramo = s.cramo
			AND s.npoliza = pnpoliza
AND s.ncertif = xncertif;
	  EXCEPTION
	    WHEN no_data_found THEN
		RETURN 101903;		-- Assegurança no trobada a SEGUROS
	    WHEN others THEN
		RETURN 101919;		-- Error al llegir de SEGUROS
	  END;
	ELSE
	  RETURN 101901;			-- Pas de paràmetres incorrecte a funció
	END IF;
END IF;
BEGIN
	SELECT tempres
	INTO   ptempres
	FROM   empresas
	WHERE  cempres = nvl(pcempres, xcempres);
EXCEPTION
	WHEN no_data_found THEN
	  RETURN 100501;		-- Empresa inexistent
	WHEN others THEN
	  RETURN 103290;		-- Error al llegir de EMPRESAS
END;
RETURN 0;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_DESEMPRESA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_DESEMPRESA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_DESEMPRESA" TO "PROGRAMADORESCSI";
