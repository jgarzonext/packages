--------------------------------------------------------
--  DDL for Function F_SALDO_POLIZAUNI_ULK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_SALDO_POLIZAUNI_ULK" (psseguro number, pfvalor date, nunidades OUT NUMBER)
	RETURN number IS
xunidades number;
xfvaloracion date;
saldo number;
preciounidad number;
saldopos number;
saldoneg number;
fecha date:=pfvalor;

cursor unidades is
  select cesta,sum(nvl(nunidad,0)) sumaunidad
  from ctaseguro
  where sseguro = psseguro
  and fvalmov <= ultima_hora(fecha)
  and nvl(cesta,0) > 0
  group by cesta;

BEGIN
saldo := 0;

for valor in unidades loop
--dbms_output.put_line('fecha='||to_char(fecha)||', cesta='||to_char(valor.cesta)||', uni='||to_char(valor.sumaunidad));
  begin
    select max(fvalor)
    into xfvaloracion
    from tabvalces
    where ccesta = valor.cesta
    and fvalor <= ultima_hora(fecha);

--dbms_output.put_line('xfecha='||to_char(xfvaloracion));

    select iuniact
    into preciounidad
    from tabvalces
    where ccesta = valor.cesta
    and fvalor  between primera_hora(xfvaloracion) and ultima_hora(xfvaloracion);
  exception
    when no_data_found then
      saldo := saldo;
  end;
  saldo := saldo + valor.sumaunidad * preciounidad;
end loop;

--SUMA DE MOVIMIENTOS POSITIVOS NO ASIGNADOS A CESTA
begin
  select nvl(sum(imovimi),0)
  into saldopos
  from ctaseguro
  where sseguro = psseguro
    and cmovimi BETWEEN 1 AND 9
--  and cmovimi < 10
--  and cmovimi <> 0
--  and cesta is null
  and fvalmov <= ultima_hora(fecha);
exception
  when others then
    saldopos := 0;
end;

--SUMA DE MOVIMIENTOS NEGATIVOS NO ASIGNADOS A CESTA
begin
  select nvl(sum(imovimi),0)
  into saldoneg
  from ctaseguro
  where sseguro = psseguro
  and cmovimi > 10
--  and cesta is null
  and fvalmov <= ultima_hora(fecha);
exception
  when others then
    saldoneg := 0;
end;
nunidades := xunidades;
return nvl(saldo,0) + nvl(saldopos,0) - nvl(saldoneg,0);
END F_SALDO_POLIZAUNI_ULK;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_SALDO_POLIZAUNI_ULK" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_SALDO_POLIZAUNI_ULK" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_SALDO_POLIZAUNI_ULK" TO "PROGRAMADORESCSI";
