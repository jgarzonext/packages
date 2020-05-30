--------------------------------------------------------
--  DDL for Function F_IMPORTPROVISIO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_IMPORTPROVISIO" (pnsinies IN NUMBER, data IN DATE)
RETURN NUMBER authid current_user IS
/***********************************************************************
Retorna l'import de la provisio pel sinistre a la data donada.
Nomes fa una crida a f_provisio i "inhibeix" el posible error
***********************************************************************/
provisio number;
error number;
begin
  error:=f_provisio(pnsinies,provisio,data);
  if error=0 then
    return provisio;
  else
    return 0;
  end if;
exception
  when others then
    return 0;
end;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_IMPORTPROVISIO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_IMPORTPROVISIO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_IMPORTPROVISIO" TO "PROGRAMADORESCSI";
