--------------------------------------------------------
--  DDL for Function F_DESPROVISION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_DESPROVISION" (pcprovis IN NUMBER, pcidioma IN NUMBER,
pttexto IN OUT VARCHAR2)
RETURN NUMBER authid current_user IS
/***********************************************************************
	F_DESGARANTIA: Retorna la descripción de las provisiones.
***********************************************************************/
BEGIN
	SELECT	tlprovis
	INTO	pttexto
	FROM	desprovisiones
	WHERE	cidioma = pcidioma
		AND cprovis = pcprovis;
	RETURN 0;
EXCEPTION
	WHEN others THEN
	     RETURN 107554;	-- Provisión inexistente
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_DESPROVISION" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_DESPROVISION" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_DESPROVISION" TO "PROGRAMADORESCSI";
