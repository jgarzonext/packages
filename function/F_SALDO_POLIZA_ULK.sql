--------------------------------------------------------
--  DDL for Function F_SALDO_POLIZA_ULK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_SALDO_POLIZA_ULK" (psseguro number, pfvalor date, pfrescat date DEFAULT null)
	RETURN number authid current_user IS
xunidades number;
xfvaloracion date;
saldo number;
preciounidad number;
saldopos number;
saldoneg number;
fecha date:=pfvalor;
ctacte NUMBER;

cursor unidades is
  select cesta,sum(nvl(nunidad,0)) sumaunidad
  from ctaseguro
  where sseguro = psseguro
  and fvalmov <= ultima_hora(fecha)
  and nvl(cesta,0) > 0
  group by cesta;

BEGIN
saldo := 0;
    BEGIN
	   SELECT p.ccodfon
	     INTO ctacte
		 FROM productos_ulk p, seguros s
		WHERE p.cramo = s.cramo
		  AND p.cmodali = s.cmodali
		  AND p.ctipseg = s.ctipseg
		  AND p.ccolect = s.ccolect
		  AND s.sseguro = psseguro;
	EXCEPTION
	  WHEN OTHERS THEN
	     ctacte := null;
	END;

    for valor in unidades loop
      saldo := saldo + f_saldo_fondo_ulk(psseguro, valor.cesta, pfvalor, pfrescat);
    end loop;

       --SUMA DE MOVIMIENTOS NO ASIGNADOS A CESTA
	IF ctacte is null THEN
       begin
         select nvl(sum(imovimi),0)
         into saldoneg
         from ctaseguro
         where sseguro = psseguro
           and cmovimi BETWEEN 21 AND 29
       --  and cmovimi in (1,2,4)
       --  and cmovimi <> 0
         and nvl(cesta,0) = 0
         and fvalmov <= ultima_hora(fecha);
       exception
         when others then
           saldoneg := 0;
       end;

       begin
         select nvl(sum(imovimi),0)
         into saldopos
         from ctaseguro
         where sseguro = psseguro
         and cmovimi in (1,2,4)
         and nvl(cesta,0) = 0
         and fvalmov <= ultima_hora(fecha);
       exception
         when others then
           saldopos := 0;
       end;

	ELSE
		saldoneg := 0;
		saldopos := 0;
	END IF;

	return nvl(saldo,0) - nvl(saldoneg,0) + nvl(saldopos,0);

END F_SALDO_POLIZA_ULK;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_SALDO_POLIZA_ULK" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_SALDO_POLIZA_ULK" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_SALDO_POLIZA_ULK" TO "PROGRAMADORESCSI";
