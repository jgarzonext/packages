--------------------------------------------------------
--  DDL for Function FF_PTABLAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FF_PTABLAS" (
 pmodo in varchar2
)
   RETURN varchar2 AUTHID CURRENT_USER
IS
BEGIN
  if pmodo = 'ALTA_POLIZA' then
    RETURN 'EST';
  else
    return 'POL';
  end if;

EXCEPTION
   WHEN OTHERS
   THEN
      p_tab_error (f_sysdate,
                   f_user,
                   'ff_ptablas',
                   1,
                   '-- pmodo =' || pmodo,
                   SQLERRM
                  );
      RETURN 'POL';
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."FF_PTABLAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FF_PTABLAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FF_PTABLAS" TO "PROGRAMADORESCSI";
