--------------------------------------------------------
--  DDL for Function F_DESSPRODUC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_DESSPRODUC" (psproduc IN NUMBER,
 pntexto IN NUMBER, pcidioma IN NUMBER, pttexto IN OUT VARCHAR2)
RETURN NUMBER authid current_user IS
/***********************************************************************
	F_DESPRODUCTO: Obtención del Título o Rótulo de un Producto.
	ALLIBMFM
	Afegim la modalitat i el tipus de seguro
***********************************************************************/
	num_err		NUMBER;
BEGIN
	num_err := 100503; 	-- Producte inexistent
	pttexto := NULL;
	num_err := 100537;	-- Titul del producte inexistent
	SELECT	DECODE(pntexto, 1, ttitulo, 2, trotulo)
	INTO	pttexto
	FROM	TITULOPRO T,PRODUCTOS P
	WHERE	t.ctipseg = p.ctipseg
		AND t.cramo = p.cramo
		AND t.cmodali = p.cmodali
		AND t.ccolect = p.ccolect
		AND t.cidioma = pcidioma
		AND p.sproduc = psproduc;
	RETURN 0;
EXCEPTION
	WHEN OTHERS THEN
		RETURN num_err;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_DESSPRODUC" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_DESSPRODUC" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_DESSPRODUC" TO "PROGRAMADORESCSI";
