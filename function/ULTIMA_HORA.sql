--------------------------------------------------------
--  DDL for Function ULTIMA_HORA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."ULTIMA_HORA" (fecha IN DATE)
	   	  		  RETURN DATE IS
uh DATE;
BEGIN
--   IF fecha IS NULL THEN RETURN sysdate; END IF;
   uh := to_date(to_char(fecha,'yyyymmdd')||' 235959', 'yyyymmdd hh24:mi:ss');
   RETURN uh;
 EXCEPTION
   WHEN OTHERS THEN
      dbms_output.put_line('fecha='||to_char(fecha)||' - '||sqlerrm);
	  RETURN sysdate;
END ULTIMA_HORA;

 
 

/

  GRANT EXECUTE ON "AXIS"."ULTIMA_HORA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."ULTIMA_HORA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."ULTIMA_HORA" TO "PROGRAMADORESCSI";
