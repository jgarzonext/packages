--------------------------------------------------------
--  DDL for Function F_INSERT_TRAMITA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_INSERT_TRAMITA" ( pnsinies in number, pctramit in number)
  return number authid current_user is
  vntramit number;
  VCTRAINT varchar2(20);
begin
  BEGIN
    select nvl(max(ntramit)+1,1)
      into vntramit
      from tramitacionsini
      where nsinies = pnsinies;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        VNTRAMIT := 1;
  END;
  BEGIN
    select ctraint
      into vctraint
      from siniestros
      where nsinies = pnsinies;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        VCTRAINT := NULL;
  END;
  insert into tramitacionsini ( nsinies, ntramit, ctramit, cestado, ctraint)
    values ( pnsinies, vntramit, pctramit, 0, vctraint);
  return 0;
  exception
    when others then
      return sqlcode;
end f_insert_tramita;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_INSERT_TRAMITA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_INSERT_TRAMITA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_INSERT_TRAMITA" TO "PROGRAMADORESCSI";
