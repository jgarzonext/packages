--------------------------------------------------------
--  DDL for Function F_PROVIMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_PROVIMP" (psseguro IN NUMBER,
                    pcobjase IN NUMBER,
                    pnriesgo IN NUMBER,
                    ptipprov IN NUMBER, -- valores: 1: fiscal
                                        --          2: real
                    pcprovreal OUT NUMBER,
                    pcprovcon  OUT NUMBER,
                    pcprovdgs  OUT NUMBER,
                    pcprovips  OUT NUMBER)
RETURN NUMBER authid current_user IS
/*
   Función que devuelve las provincias de un seguro. Se realizará en función
   de si se solicita la provincia real o la fiscal (donde liquida los impuestos)
*/
xcdomici   NUMBER;
xsperson   NUMBER;
begin
-- Validación de parámetros
 if psseguro is null             OR
    pnriesgo is null             OR
    pcobjase is null             OR
    ptipprov < 1 or ptipprov > 2
 then
   RETURN 101901;
 end if;
-- Tratamiento en función del tipo de objeto asegurado
 if pcobjase = 2
 then
   begin
     select decode(ptipprov,2,p.cprovin,decode(ccedcon,1,p.cprovin,98)),
            decode(ptipprov,2,p.cprovin,decode(cceddgs,1,p.cprovin,98)),
            decode(ptipprov,2,p.cprovin,decode(ccedips,1,p.cprovin,98)),
            decode(ptipprov,2,p.cprovin,98)
       into pcprovcon, pcprovdgs, pcprovips, pcprovreal
       from provincias p, sitriesgo r
      where sseguro   = psseguro
        and nriesgo   = pnriesgo
        and p.cprovin = r.cprovin;
   exception
     when others then
       RETURN 107572;
   end;
 elsif pcobjase = 1 or pcobjase = 3 or pcobjase = 4
 then
   -- Localizamos el primer domicilio disponible si no hay ninguno en tomadores
   begin
     select cdomici,sperson
       into xcdomici, xsperson
       from tomadores
      where sseguro = psseguro
        and nordtom = 1;
     if xcdomici is null
     then
       select min(cdomici)
         into xcdomici
         from direcciones
        where sperson = xsperson;
     end if;
     if xcdomici is null
     then
        RETURN 107574;  -- error al intentar localizar el domicilio del tomador
     end if;
   exception
     when others then
        RETURN 107573;  -- No hay primer tomador
   end;
   begin
     select decode(ptipprov,2,p.cprovin,decode(ccedcon,1,p.cprovin,98)),
            decode(ptipprov,2,p.cprovin,decode(cceddgs,1,p.cprovin,98)),
            decode(ptipprov,2,p.cprovin,decode(ccedips,1,p.cprovin,98)),
            decode(ptipprov,2,p.cprovin,98)
       into pcprovcon, pcprovdgs, pcprovips, pcprovreal
       from provincias p, direcciones d
      where d.sperson = xsperson
        and d.cdomici = xcdomici
        and d.cprovin = p.cprovin;
   exception
     when others then
       RETURN 107575;  -- error
   end;
 else
   RETURN 107576;
 end if;
 RETURN 0;
end;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_PROVIMP" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_PROVIMP" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_PROVIMP" TO "PROGRAMADORESCSI";
