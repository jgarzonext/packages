--------------------------------------------------------
--  DDL for Function F_SITUACION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_SITUACION" (psseguro in number, pfefecto in date, psituacion OUT number)
         return number is
error       number := 0;
situacion   number;
w_cuenta    number;
aux_efecto date;
aux_vencim date;
-- Esta función NO devuelve CSITUAC
-- devolverá 'inexistente' para una fecha anterior a la del primer movto (emisión)
-- devolverá 'inexistente' para una fecha anterior a la del efecto (aunque esté emitida)
cursor movs (csseguro in number, cfefecto in date) is
 select * from movseguro
  where sseguro = csseguro
    and fefecto <= trunc(cfefecto)
	and femisio < cfefecto+1
    and cmovseg not in (6,52)  -- no se tienen en cuenta los movimientos anulados o rechazados
--order by fefecto desc, nmovimi desc;
  order by  nmovimi desc; -- no se ordena por fefecto porque los movimientos de anulación
                          -- pueden tener efecto anterior a otros movimientos y entonces
						  -- no se detecta que está anulada
begin
psituacion := 0;
begin
select fefecto, fvencim into aux_efecto, aux_vencim
  from seguros
 where sseguro = psseguro;
exception
 when no_data_found then
      return 100500;
 when others then
      return sqlcode;
end;
if aux_efecto > pfefecto then
   return 0;
end if;
if aux_vencim <= pfefecto then
   psituacion := 3;
   return 0;
end if;
w_cuenta := 0; --Inicializamos variable
for i in movs (psseguro, pfefecto)
loop
  w_cuenta := w_cuenta + 1;
  if i.cmovseg = 0 then
     if i.femisio is null then
        psituacion := 0; -- Prop. alta (no vigente)
        return 0;
     else
        exit;
     end if;
  else
     if i.cmovseg = 3 then
        psituacion := 2; -- Anulada
        return 0;
--     elsif i.cmovseg = ??
--        como distingimos las suspendidas de las vigentes?
     else
        exit;
     end if;
  end if;
end loop;
if w_cuenta = 0 then --Si no hay registros en movseguro no es vigente
   psituacion := 0;
   return 0;
else
   psituacion := 1; -- Vigente
    return 0;
end if;
end;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_SITUACION" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_SITUACION" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_SITUACION" TO "PROGRAMADORESCSI";
