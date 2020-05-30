--------------------------------------------------------
--  DDL for Function F_CFORPAG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_CFORPAG" (psseguro in number, pnmovimi in number) RETURN number IS
/***************************************************************************************
    Devuelve la forma de pago que tenía el seguro en ese movimiento

******************************************************************************************/
  v_cforpag   number;
BEGIn
	 begin
      select cforpag
      into v_cforpag
      from historicoseguros
      where sseguro =  psseguro
      and nmovimi = pnmovimi;

      return v_cforpag;
	 exception
	 	  when no_data_found then
	 	     select cforpag
	 	     into v_cforpag
         from seguros
         where sseguro =  psseguro;

         return v_cforpag;
	 end;
exception
   when others then
      return null;
end;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_CFORPAG" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_CFORPAG" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_CFORPAG" TO "PROGRAMADORESCSI";
