--------------------------------------------------------
--  DDL for Function F_FORMATIMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_FORMATIMP" (pimporte IN NUMBER, presul IN OUT CHAR)
RETURN NUMBER authid current_user IS
/************************************************************************
	FORMATIMP	Devuelve un importe NUMBER(13,2) con formato
			coma decimal y puntos separadores de miles
			A utilizar cuando no se pueda usar el formato que
			ofrece Developer
	ALLIBCTR
************************************************************************/
	cadena	VARCHAR2(500);
	decimal	VARCHAR2(5);
	numero	VARCHAR2(100);
	nocero	NUMBER;
BEGIN
		IF pimporte IS NULL THEN
			cadena:='';
		ELSE
			decimal:=RPAD(TO_CHAR(pimporte-FLOOR(pimporte)),3,'0');
			IF decimal='0' THEN
				decimal:='00';
			ELSE
				decimal:=SUBSTR(decimal,2,2);
			END IF;
			numero:=LPAD(TO_CHAR(FLOOR(pimporte)),11,'0');
			nocero:=0;
			FOR i IN 1..11 LOOP
				IF nocero=1 THEN
					cadena:=cadena||SUBSTR(numero,i,1);
					IF i=2 OR i=5 OR i=8 THEN
						cadena:=cadena||'.';
					END IF;
				ELSIF SUBSTR(numero,i,1)<>0 AND nocero=0 THEN
					nocero:=1;
					cadena:=SUBSTR(numero,i,1);
					IF i=2 OR i=5 OR i=8 THEN
						cadena:=cadena||'.';
					END IF;
				END IF;
			END LOOP;
			IF nocero=0 THEN
				cadena:='0';
			END IF;
			-- Añadimos los decimales
			cadena:=cadena||','||decimal;
		END IF;
		presul:=LPAD(cadena,17);
		RETURN 0;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_FORMATIMP" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_FORMATIMP" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_FORMATIMP" TO "PROGRAMADORESCSI";
