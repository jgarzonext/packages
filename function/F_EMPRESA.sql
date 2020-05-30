--------------------------------------------------------
--  DDL for Function F_EMPRESA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_EMPRESA" (psseguro IN NUMBER, pnrecibo IN NUMBER, pcramo IN NUMBER,
	 pcempres IN OUT NUMBER, pcusuari IN VARCHAR2 DEFAULT ' ')
RETURN NUMBER authid current_user IS
/****************************************************************************
			    Afegir paràmetre
			    opcional (per defecte).
			    En el cas de buscar la empresa
			    pel nombre de rebut, aquesta la agafo directament per
			    la taula RECIBOS.
****************************************************************************/
error    NUMBER;
xseguro  NUMBER;
xcramo   NUMBER;
xcempres NUMBER;
BEGIN
BEGIN
IF pcusuari <> ' ' THEN
error := 102610;		-- Usuari no trobat a la taula USUARIOS
SELECT cempres
INTO xcempres
FROM usuarios
WHERE cusuari = pcusuari;
pcempres := xcempres;
RETURN 0;
ELSE
error := 101901;              -- Paso incorrecto de parámetros a la función
IF psseguro is null AND pnrecibo is null AND pcramo is null THEN
RETURN error;
ELSE
IF psseguro is not null THEN
IF pnrecibo is not null OR pcramo is not null THEN
RETURN error;
END IF;
ELSE
IF pnrecibo is not null THEN
IF pcramo is not null THEN
RETURN error;
END IF;
END IF;
END IF;
END IF;
error := 101902;		         -- Recibo no encontrado en la tabla RECIBOS
IF pnrecibo is not null THEN
SELECT cempres
INTO xcempres
FROM RECIBOS
WHERE nrecibo = pnrecibo;
pcempres := xcempres;
RETURN 0;
END IF;
error := 101903;                -- Seguro no encontrado en la tabla SEGUROS
IF psseguro is not null THEN
SELECT cramo
INTO xcramo
FROM SEGUROS
WHERE sseguro = psseguro;
END IF;
error := 101904;               -- Ramo no encontrado en la tabla CODIRAM
IF pcramo is not null THEN
SELECT cempres
INTO pcempres
FROM CODIRAM
WHERE cramo = pcramo;
ELSE
SELECT cempres
INTO pcempres
FROM CODIRAM
WHERE cramo = xcramo;
END IF;
RETURN 0;
END IF;
EXCEPTION
WHEN others THEN
RETURN error;
END;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_EMPRESA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_EMPRESA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_EMPRESA" TO "PROGRAMADORESCSI";
