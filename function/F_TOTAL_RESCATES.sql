--------------------------------------------------------
--  DDL for Function F_TOTAL_RESCATES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_TOTAL_RESCATES" (psseguro number,pfecha date) RETURN number IS
importe number;
BEGIN

  begin
    select sum(iimpmov)
    into importe
    from rescates
    where sseguro = psseguro
    and cestado = '1'
    and trunc(finiefe) <= trunc(pfecha);
  exception
    when others then
      importe := 0;
  end;

  return importe;

END;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_TOTAL_RESCATES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_TOTAL_RESCATES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_TOTAL_RESCATES" TO "PROGRAMADORESCSI";
