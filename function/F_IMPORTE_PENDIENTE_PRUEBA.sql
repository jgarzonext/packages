--------------------------------------------------------
--  DDL for Function F_IMPORTE_PENDIENTE_PRUEBA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_IMPORTE_PENDIENTE_PRUEBA" (psseguro number,pfecha date) RETURN number IS
importe number;
cuenta number;
BEGIN
   --BUSCAR APORTACIONES EXTRAORDINARIAS-
   --BUSCAR APORTACIONES UNICAS Y PERIODICAS-
   BEGIN
      select count(*)
	  into cuenta
      from ctaseguro
      where sseguro = psseguro
      and nrecibo in (
                      select nrecibo
                      from ctaseguro
                      where sseguro = psseguro
                      and trunc(fvalmov) <= trunc(pfecha)
                      and cmovimi in (1,2,4))
      and cmovimi in (5,6,7,45,46)
      and cestado <> '2';
   EXCEPTION
      WHEN OTHERS THEN
	     cuenta := 0;
   END;
   --BUSCAR SI EXISTEN IMPORTES PENDIENTES DE ASIGNAR POR ENVIAR DEL DIA ANTERIOR-
   if cuenta = 0 then
      begin
   	     select count(*)
   	  	 into cuenta
	  	 from tmp_traspasos_ulk
	  	 where sseguro = psseguro
	  	 and cestado <> '3';
   	  exception
         when others then
	  	    cuenta := 0;
      end;
   end if;
   if cuenta = 0 then
      begin
	     select count(*)
		 into cuenta
	  	 from tmp_traspasos_ulk t,ctaseguro c
	     where t.sseguro = psseguro
	     and c.sseguro = psseguro
	     and t.ccesta = c.cesta
	     and t.cestado = '3' and c.cestado = '1';
      exception
         when others then
	     	   cuenta := 0;
      end;
   end if;
   if cuenta = 0 then
      begin
         select sum(iimppnd)
         into importe
         from imp_pendiente_asignar
         where sseguro = psseguro
         and cestado = '0';
      exception
         when others then
	        importe := 0;
      end;
   end if;
   RETURN importe;
END;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_IMPORTE_PENDIENTE_PRUEBA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_IMPORTE_PENDIENTE_PRUEBA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_IMPORTE_PENDIENTE_PRUEBA" TO "PROGRAMADORESCSI";
