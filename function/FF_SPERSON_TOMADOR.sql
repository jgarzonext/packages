--------------------------------------------------------
--  DDL for Function FF_SPERSON_TOMADOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FF_SPERSON_TOMADOR" (
  psseguro IN NUMBER,
  ptablas  in varchar2 default null,
  pnordtom in number default null
  )
RETURN number AUTHID current_user IS
  xsperson tomadores.sperson%type;
BEGIN

 if ptablas is null then
         if pnordtom is not null then
            select sperson
              into xsperson
            from tomadores
            where sseguro = psseguro
              and nordtom = pnordtom;
          else
          select sperson
            into xsperson
          from tomadores
          where sseguro = psseguro
            and nordtom = ( select min( nordtom) from tomadores where sseguro = psseguro  );
          end if;
  else
         if pnordtom is not null then
            select sperson
              into xsperson
            from esttomadores
            where sseguro = psseguro
              and nordtom = pnordtom;
          else
          select sperson
            into xsperson
          from esttomadores
          where sseguro = psseguro
            and nordtom = ( select min( nordtom) from esttomadores where sseguro = psseguro  );
          end if;
  end if;
  return  xsperson;

exception when others then
  return null;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."FF_SPERSON_TOMADOR" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FF_SPERSON_TOMADOR" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FF_SPERSON_TOMADOR" TO "PROGRAMADORESCSI";
