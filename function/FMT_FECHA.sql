--------------------------------------------------------
--  DDL for Function FMT_FECHA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FMT_FECHA" (fecha IN VARCHAR2)
	   	  		  RETURN DATE IS
ffecha DATE;
xfecha VARCHAR2(12);
BEGIN
   /*
   IF SUBSTR(fecha, 2, 1) = '-' THEN
   	  IF SUBSTR(fecha, 6, 1) = '-' THEN
	  	 ffecha := TO_DATE(fecha, 'dd-mon-yy');
	  END IF;
   ELSIF SUBSTR(fecha, 3, 1) = '-' THEN
   	  IF SUBSTR(fecha, 7, 1) = '-' THEN
	  	 ffecha := TO_DATE(fecha, 'dd-mon-yy');
	  END IF;
   ELSE
   	   IF LENGTH(fecha) > 9 THEN
      	   ffecha := TO_DATE(fecha, 'dd/mm/yyyy');
	   ELSE
      	   ffecha := TO_DATE(fecha, 'dd/mm/yyyy');
	   END IF;
   END IF;
   */
		   xfecha := UPPER(fecha);
		   xfecha := REPLACE(xfecha, 'ENE', '01');
		   xfecha := REPLACE(xfecha, 'FEB', '02');
		   xfecha := REPLACE(xfecha, 'MAR', '03');
		   xfecha := REPLACE(xfecha, 'ABR', '04');
		   xfecha := REPLACE(xfecha, 'MAY', '05');
		   xfecha := REPLACE(xfecha, 'JUN', '06');
		   xfecha := REPLACE(xfecha, 'JUL', '07');
		   xfecha := REPLACE(xfecha, 'AGO', '08');
		   xfecha := REPLACE(xfecha, 'SEP', '09');
		   xfecha := REPLACE(xfecha, 'OCT', '10');
		   xfecha := REPLACE(xfecha, 'NOV', '11');
		   xfecha := REPLACE(xfecha, 'DIC', '12');
		   xfecha := REPLACE(xfecha, 'JAN', '01');
		   xfecha := REPLACE(xfecha, 'APR', '04');
		   xfecha := REPLACE(xfecha, 'AUG', '08');
		   xfecha := REPLACE(xfecha, 'DEC', '12');
   BEGIN
   		ffecha := TO_DATE(xfecha, 'dd-mon-yy');
   EXCEPTION WHEN OTHERS THEN
      BEGIN
      		ffecha := TO_DATE(xfecha, 'dd/mm/yy');
      EXCEPTION  WHEN OTHERS THEN
	  	BEGIN
      		ffecha := TO_DATE(xfecha, 'dd/mm/yyyy');
		EXCEPTION WHEN OTHERS THEN
		   RETURN NULL;
		END;
      END;
   END;

   RETURN ffecha;

END FMT_FECHA;

 
 

/

  GRANT EXECUTE ON "AXIS"."FMT_FECHA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FMT_FECHA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FMT_FECHA" TO "PROGRAMADORESCSI";
