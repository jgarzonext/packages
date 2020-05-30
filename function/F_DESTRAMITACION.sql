--------------------------------------------------------
--  DDL for Function F_DESTRAMITACION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_DESTRAMITACION" (
	pcoditram	IN	NUMBER,
	pcidioma	IN	NUMBER,
	plongitud	IN	NUMBER DEFAULT 50
)
RETURN VARCHAR2 authid current_user IS
/*****************************************************************
	F_DESTRAMITACION
	Descripción del tipo de tramitación
*****************************************************************/
destramit varchar2(40);
begin
  begin
    select ttramit
	into destramit
	from DESTRAMITACION
	where ctramit = pcoditram
	and cidioma = pcidioma;
	exception
	   when others then
	        destramit := ' ';
  end;
  return(destramit);
end;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_DESTRAMITACION" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_DESTRAMITACION" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_DESTRAMITACION" TO "PROGRAMADORESCSI";
