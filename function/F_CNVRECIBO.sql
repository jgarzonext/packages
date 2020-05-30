--------------------------------------------------------
--  DDL for Function F_CNVRECIBO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_CNVRECIBO" (PNSISTEMA IN NUMBER, PTREBUT_INI IN VARCHAR2, PNRECIBO
			OUT NUMBER) RETURN NUMBER
authid current_user IS
XSISTEMA	VARCHAR2(2);
XNRECIBO	NUMBER;
BEGIN
IF PNSISTEMA = 1 THEN
XSISTEMA := 'HP';
ELSIF PNSISTEMA = 2 THEN
XSISTEMA := 'IN';
ELSIF PNSISTEMA = 3 THEN
XSISTEMA := 'MU';
ELSE
RETURN 101901;	-- PAS INCORRECTE DE PAR�METRES A LA FUNCI�
END IF;
BEGIN
SELECT NRECIBO
INTO XNRECIBO
FROM CNVRECIBOS
WHERE SISTEMA = XSISTEMA AND
	REBUT_INI = PTREBUT_INI;
PNRECIBO := NVL(XNRECIBO, 0);
RETURN 0;
EXCEPTION
WHEN NO_DATA_FOUND THEN
	RETURN 102908;	-- REBUT NO TROBAT A LA TAULA CNVRECIBOS
WHEN OTHERS THEN
	RETURN 101916;	-- ERROR A LA BASE DE DADES
END;
END;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_CNVRECIBO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_CNVRECIBO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_CNVRECIBO" TO "PROGRAMADORESCSI";
