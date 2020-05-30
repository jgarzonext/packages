--------------------------------------------------------
--  DDL for Function F_PARCONEXION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_PARCONEXION" 
(pCPARAME IN varchar2)
RETURN NUMBER
authid current_user
is
begin
  declare
    vNVALPAR number(8);
  begin
    select TVALPAR
    into   vNVALPAR
    from   PARCONEXION
    where  CPARAME = upper(pCPARAME);
    return vNVALPAR;
  exception
      when no_data_found then
        return null;
  end;
end;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_PARCONEXION" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_PARCONEXION" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_PARCONEXION" TO "PROGRAMADORESCSI";
