--------------------------------------------------------
--  DDL for Function F_PERSODAT1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_PERSODAT1" (psperson IN NUMBER, pcsexper OUT NUMBER,
pfnacimi OUT DATE, pcestado OUT NUMBER)
RETURN NUMBER authid current_user IS
/****************************************************************************
	F_persodat1: Obtenir el sexe, la data de naixement i l'estat
		de la persona entrada com a paràmetre.
	ALLIBMFM.
****************************************************************************/
BEGIN
	SELECT csexper, fnacimi, cestado
	INTO pcsexper, pfnacimi, pcestado
	FROM PERSONAS
	WHERE sperson = psperson;
	RETURN (0);
EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN 100534;	--Persona inexistent
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_PERSODAT1" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_PERSODAT1" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_PERSODAT1" TO "PROGRAMADORESCSI";
