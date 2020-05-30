--------------------------------------------------------
--  DDL for Function F_ACTIVO_RENTAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_ACTIVO_RENTAS" (psseguro number)
  RETURN NUMBER authid current_user IS
/****************************************************************************************
 Función f_activo_rentas
   A partir del sseguro busca el número de certificado del Host de Caixa Sabadell, busca
  en la tabla ACTIVOS la clave del activo asociada (activo vinculado a rentas) y da de alta en la tabla SEGUROS_ACT.
 Parámetros de entrada:
   psseguro --> Clave del seguro
 Parámetros de salida:
   retorno --> 0 O.K.
           --> 1 error en el acceso a la tabla SEGUROS_ULK
		   --> 2 error en el acceso a la tabla ACTIVOS
		   --> 3 Se ha encontrado más de un activo
		   --> 4 error en la inserción a la tabla SEGUROS_ACT
****************************************************************************************/
	   error      number:=0;
           xpolissa   number:=0;
	   xram	      number:=0;
	   xmoda      number:=0;
	   xtipo      number:=0;
	   xcole      number:=0;
           xagru      number:=0;
           xproduc    number:=0;
	   psactivo   number(6):=0;
begin
  begin
    select polissa_ini, ram, moda, tipo, cole
	into xpolissa,xram,xmoda,xtipo,xcole
	from cnvpolizas
	where sseguro = psseguro;
  exception
	  when no_data_found then
	    return 1;
  end;

  begin
    SELECT sproduc into xproduc from productos
     where cramo=xram and cmodali=xmoda
       and ctipseg = xtipo and ccolect=xcole;
  exception
      when no_data_found then
           return 1;
  end;

  error := f_parproductos(xproduc,'AGRACTIVOS',XAGRU);
  IF ERROR <> 0 THEN
     RETURN error;
  END IF;

  begin
    select sactivo
    into psactivo
    from ACTIVOS
    where to_number(polissa_ini)<= xpolissa
      and to_number(nvl(polissa_fi,'999999999999999'))>= xpolissa
      and cagrupa = nvl(xagru,0);
    exception
          when no_data_found then
		      return 2;
		  when too_many_rows then
		      return 3;
  end;

  begin
  insert into SEGUROS_ACT (sactivo, sseguro)
     values (psactivo, psseguro);
  exception
         when others then
		      return 4;
  end;
  return 0;
end;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_ACTIVO_RENTAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_ACTIVO_RENTAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_ACTIVO_RENTAS" TO "PROGRAMADORESCSI";
