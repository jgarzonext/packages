--------------------------------------------------------
--  DDL for Function F_DESPRODUCTO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_DESPRODUCTO" (pccodram IN NUMBER, pcmodali IN NUMBER,
 pntexto IN NUMBER, pcidioma IN NUMBER, pttexto IN OUT VARCHAR2,
 pctipseg IN NUMBER := 0, pccolect IN NUMBER := 0)
RETURN NUMBER authid current_user IS
/***********************************************************************
    F_DESPRODUCTO: Obtención del Título o Rótulo de un Producto.
    ALLIBMFM
	Afegim la modalitat i el tipus de seguro
***********************************************************************/
    num_err        NUMBER;
    pctitulo    NUMBER;
BEGIN
    num_err := 100503;     -- Producte inexistent
    pttexto := NULL;
    num_err := 100537;    -- Titul del producte inexistent
    SELECT    DECODE(pntexto, 1, ttitulo, 2, trotulo)
    INTO    pttexto
    FROM    TITULOPRO
    WHERE    ctipseg = pctipseg
        AND cramo = pccodram
        AND cmodali = pcmodali
        AND ccolect = pccolect
        AND cidioma = pcidioma;
    RETURN 0;
EXCEPTION
    WHEN OTHERS THEN
        RETURN num_err;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_DESPRODUCTO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_DESPRODUCTO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_DESPRODUCTO" TO "PROGRAMADORESCSI";
