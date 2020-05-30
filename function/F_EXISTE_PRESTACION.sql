--------------------------------------------------------
--  DDL for Function F_EXISTE_PRESTACION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_EXISTE_PRESTACION" (p_sseguro in number) return NUMBER authid current_user is
  n_ret  number;
begin

  select decode(count(1),0,0,1)
   into  n_ret
   from  prestaplan
   where cestado=2
   and   sseguro=p_sseguro;

  return n_ret;
end;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_EXISTE_PRESTACION" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_EXISTE_PRESTACION" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_EXISTE_PRESTACION" TO "PROGRAMADORESCSI";
