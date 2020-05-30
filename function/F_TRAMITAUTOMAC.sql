--------------------------------------------------------
--  DDL for Function F_TRAMITAUTOMAC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_TRAMITAUTOMAC" ( pnsinies in number )
  return number authid current_user is
  aux      number;
  vcaseta  number;
  vcideasc number;
  vcramo   number;
begin
  -- Tramitació genèrica
  aux := f_insert_tramita ( pnsinies, 0 );
  if aux <> 0 then
    return 0;
  end if;
  -- Convenis
  select caseta, cideasc, cramo
    into vcaseta, vcideasc, vcramo
    from siniestros
    where nsinies = pnsinies;
  if vcideasc = 1 then
    aux := f_insert_tramita ( pnsinies, 1 );
    if aux <> 0 then
      return 0;
    end if;
    aux := f_insert_tramita ( pnsinies, 2 );
    if aux <> 0 then
      return 0;
    end if;
  end if;
  if vcaseta = 1 then
    aux := f_insert_tramita ( pnsinies, 9 );
    if aux <> 0 then
      return 0;
    end if;
  end if;
  return 0;
end f_tramitautomac;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_TRAMITAUTOMAC" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_TRAMITAUTOMAC" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_TRAMITAUTOMAC" TO "PROGRAMADORESCSI";
