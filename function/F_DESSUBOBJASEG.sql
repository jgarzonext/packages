--------------------------------------------------------
--  DDL for Function F_DESSUBOBJASEG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_DESSUBOBJASEG" (pcobjaseg IN NUMBER, pcsubobjaseg IN NUMBER,
  pcidioma IN NUMBER, pttexto IN OUT VARCHAR2)
RETURN NUMBER authid current_user IS
/***********************************************************************
	F_DESSUBOBJASEG: Retorna la descripción del subobjaseg.
***********************************************************************/
BEGIN
  select tsubobjaseg
    into pttexto
    from subobjaseg
    where cidioma = pcidioma and
      cobjaseg = pcobjaseg and
      csubobjaseg = pcsubobjaseg;
  RETURN 0;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 1;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_DESSUBOBJASEG" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_DESSUBOBJASEG" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_DESSUBOBJASEG" TO "PROGRAMADORESCSI";
