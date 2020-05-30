--------------------------------------------------------
--  DDL for Function F_SUMMESES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_SUMMESES" (PFECHA IN DATE, MESES IN NUMBER, DIA IN VARCHAR2) RETURN DATE
authid current_user IS
/***************************************************************************
	F_SUMMESES : SUMA EXACTAMENTE LOS MESES, ES DECIR, LA FECHA QUEDA CON
			 EL MISMO DIA QUE LA FECHA INICIAL, EXCEPTO SI ESE DIA
			 NO EXISTE. EN ESTE CASO SE PONE EL ÚLTIMO DÍA DEL MES
	ALLIBCTR.
	3-2-1999 YIL.
****************************************************************************/
	FSUMA	DATE;
	TSUMA	VARCHAR2(10);
	FECHA	DATE;
BEGIN
	FSUMA := ADD_MONTHS(PFECHA,MESES);
	TSUMA := TO_CHAR(FSUMA,'MM/YYYY');
	BEGIN
		FECHA := TO_DATE(DIA||'/'||TSUMA,'DD/MM/YYYY');
	EXCEPTION
		WHEN OTHERS THEN
			FECHA := LAST_DAY(TO_DATE('1'||'/'||TSUMA,'DD/MM/YYYY'));
	END;
	RETURN FECHA;
END;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_SUMMESES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_SUMMESES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_SUMMESES" TO "PROGRAMADORESCSI";
