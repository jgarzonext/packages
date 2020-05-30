--------------------------------------------------------
--  DDL for Function F_BUSCACALIFI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_BUSCACALIFI" (psseguro IN NUMBER, pspleno IN NUMBER,
		pccalif1 OUT VARCHAR2, pccalif2 OUT NUMBER, pipleno OUT NUMBER)
RETURN NUMBER authid current_user IS
/****************************************************************************
	F_BUSCACALIFI : Devuelve el ipleno y la calificacion de un riesgo
			segun el seguro y el spleno
	ALLIBREA. Reaseguro
****************************************************************************/
	tipocalif	number;
	wcactivi	number;
BEGIN
	IF psseguro IS NULL OR pspleno IS NULL THEN
		RETURN 101911; -- Paso incorrecto de parámetros a la función
	END IF;
	BEGIN
		SELECT ctipcal INTO tipocalif
		FROM CODIPLENOS
		WHERE spleno = pspleno;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			RETURN 104711; -- Código de pleno inexistente
		WHEN OTHERS THEN
			RETURN 104712; -- Error al leer CODIPLENOS
	END;
	IF tipocalif = 1 THEN  -- tipo de calificacion por actividad
		-- Buscamos la actividad correspondiente al seguro
		BEGIN
			SELECT cactivi INTO wcactivi
			FROM SEGUROS
			WHERE sseguro = psseguro;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				RETURN 100500; -- Póliza inexistente
			WHEN OTHERS THEN
				RETURN 101919; -- Error al leer SEGUROS
		END;
		-- Buscamos la calificacion por la actividad
		BEGIN
			SELECT p.ccalif1, p.ccalif2, p.ipleno
			INTO pccalif1, pccalif2, pipleno
			FROM PLENOS p,CALIFIRIESGO c
			WHERE c.spleno = pspleno
			AND c.ndesde <= wcactivi
			AND (c.nhasta >= wcactivi OR c.nhasta is null)
			AND p.spleno = c.spleno
			AND p.ccalif1 = c.ccalif1
			AND p.ccalif2 = c.ccalif2;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				RETURN  104717;   -- No hay calificación para la activ.
							-- de este seguro
			WHEN OTHERS THEN
				RETURN 104718;  -- Error al buscar la calificación del pleno
		END;
	ELSE
		RETURN 104719;  -- El tipo de calificación no es por actividad
	END IF;
	RETURN 0;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_BUSCACALIFI" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_BUSCACALIFI" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_BUSCACALIFI" TO "PROGRAMADORESCSI";
