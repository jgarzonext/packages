--------------------------------------------------------
--  DDL for Function FF_DESVALORFIJO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FF_DESVALORFIJO" (pcvalor IN NUMBER, pcidioma IN NUMBER,
pcatribu IN NUMBER)
RETURN VARCHAR2 IS
/***********************************************************************
 Ff_DESVALORFIJO: Obtener la descripción de un Valor Fijo en
  función del idioma del usuario.

***********************************************************************/
 vttexto detvalores.tatribu%TYPE;
 
BEGIN
 SELECT tatribu
 INTO vttexto
 FROM DETVALORES
 WHERE catribu = pcatribu
  AND cidioma = pcidioma
  AND cvalor = pcvalor;
 RETURN vttexto;
EXCEPTION
 WHEN OTHERS THEN
  RETURN null; -- Valor fixe inexistent
END; 
 
 

/

  GRANT EXECUTE ON "AXIS"."FF_DESVALORFIJO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FF_DESVALORFIJO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FF_DESVALORFIJO" TO "PROGRAMADORESCSI";
