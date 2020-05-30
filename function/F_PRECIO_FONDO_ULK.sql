--------------------------------------------------------
--  DDL for Function F_PRECIO_FONDO_ULK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_PRECIO_FONDO_ULK" (psseguro number,pfondo number,pfvalor date)
	   	  		  RETURN number IS
xunidades number;
xfvaloracion date;
saldo number;
preciounidad number;
sumaunidad number;
BEGIN
gettimer.reset_timer;
saldo := 0;
begin
  select sum(nvl(nunidad,0))
  into sumaunidad
  from ctaseguro
  where sseguro = psseguro
  and fvalmov <= ultima_hora(pfvalor)
  and cesta = pfondo;
exception
  when others then
    sumaunidad := 0;
end;
select max(fvalor)
into xfvaloracion
from tabvalces
where ccesta = pfondo
and fvalor <= ultima_hora(pfvalor);
begin
  select iuniact
  into preciounidad
  from tabvalces
  where ccesta = pfondo
  and fvalor BETWEEN primera_hora(xfvaloracion) AND ultima_hora(xfvaloracion);
exception
  when others then
    preciounidad := 0;
end;
dbms_output.put_line('cesta='||to_char(pfondo)||' ('||to_char(gettimer.get_elapsed_time));
return preciounidad;
END;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_PRECIO_FONDO_ULK" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_PRECIO_FONDO_ULK" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_PRECIO_FONDO_ULK" TO "PROGRAMADORESCSI";
