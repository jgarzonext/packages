--------------------------------------------------------
--  DDL for Function F_SALDO_POLIZA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_SALDO_POLIZA" (psseguro number, pfvalor date)
	RETURN number IS
saldopos number;
fecha date:=pfvalor;
BEGIN
       begin
         select nvl(sum(imovimi),0)
         into saldopos
         from ctaseguro
         where sseguro = psseguro
         and cmovimi = 0
         and trunc(fvalmov) = trunc(fecha);
       exception
         when others then
           saldopos := 0;
       end;
	return nvl(saldopos,0);
END F_SALDO_POLIZA;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_SALDO_POLIZA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_SALDO_POLIZA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_SALDO_POLIZA" TO "PROGRAMADORESCSI";
