--------------------------------------------------------
--  DDL for Function F_PRIMAS_APORTADAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_PRIMAS_APORTADAS" (psseguro number, pfecha date) RETURN number IS
primas number;
BEGIN
begin
  select sum(nvl(imovimi,0))
  into primas
  from ctaseguro
  where cmovimi in (1,2,4)
  and sseguro = psseguro
  and trunc(fvalmov) <= trunc(pfecha);
exception
  when others then
    primas := 0;
end;
return primas;
END;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_PRIMAS_APORTADAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_PRIMAS_APORTADAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_PRIMAS_APORTADAS" TO "PROGRAMADORESCSI";
