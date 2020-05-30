--------------------------------------------------------
--  DDL for Function PRIMERA_HORA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."PRIMERA_HORA" (fecha IN DATE)
	   	  		  RETURN DATE IS
ph DATE;
BEGIN
--   IF fecha IS NULL THEN RETURN sysdate; END IF;
   ph := to_date(to_char(fecha,'yyyymmdd')||' 000000', 'yyyymmdd hh24:mi:ss');
   RETURN ph;
 EXCEPTION
   WHEN OTHERS THEN
      dbms_output.put_line('fecha='||to_char(fecha)||' - '||sqlerrm);
	  RETURN sysdate;
END PRIMERA_HORA;

 
 

/

  GRANT EXECUTE ON "AXIS"."PRIMERA_HORA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PRIMERA_HORA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PRIMERA_HORA" TO "PROGRAMADORESCSI";
