--------------------------------------------------------
--  DDL for Function F_SALDO_FONDOUNI_ULK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_SALDO_FONDOUNI_ULK" (psseguro number,pfondo number,pfvalor date, unidades OUT NUMBER)
	   	  		  RETURN number IS
xunidades number;
xfvaloracion date;
saldo number;
preciounidad number;
sumaunidad number;
BEGIN
--gettimer.reset_timer;
saldo := 0;
begin
  select sum(nvl(nunidad,0))
  into sumaunidad
  from ctaseguro
  where sseguro = psseguro
  and fvalmov <= ultima_hora(pfvalor)
  and nvl(cesta,0) = pfondo;
exception
  when others then
    sumaunidad := 0;
end;
select max(fvalor)
into xfvaloracion
from tabvalces
where ccesta = pfondo
and fvalor <= ultima_hora(pfvalor);
	IF xfvaloracion IS NOT NULL THEN
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
	  saldo := sumaunidad * preciounidad;
	ELSE
	  saldo := 0;
	END IF;
--dbms_output.put_line('Seg='||to_char(psseguro)||', cesta='||to_char(pfondo)||' ('||to_char(gettimer.get_elapsed_time));
 unidades := sumaunidad;
return saldo;
END;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_SALDO_FONDOUNI_ULK" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_SALDO_FONDOUNI_ULK" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_SALDO_FONDOUNI_ULK" TO "PROGRAMADORESCSI";
