--------------------------------------------------------
--  DDL for Function F_OBJASE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_OBJASE" (IP_COBJASEG IN VARCHAR2, IP_CSUBOBJASEG IN VARCHAR2,
IP_COBJASE IN OUT NUMBER, IP_TFUNCIO IN OUT VARCHAR2, IP_CCLARIE IN OUT NUMBER)
RETURN NUMBER IS
BEGIN
  if IP_CSUBOBJASEG is null then
    select cobjase, tfuncio, cclarie
      into ip_cobjase, ip_tfuncio, ip_cclarie
      from codiobjaseg
      where cobjaseg = ip_cobjaseg;
  else
    select cobjase, tfuncio, cclarie
      into ip_cobjase, ip_tfuncio, ip_cclarie
      from codisubobjaseg
      where csubobjaseg = ip_csubobjaseg;
  end if;
  RETURN 0;
  EXCEPTION
    WHEN too_many_rows THEN
      RETURN 1;
    WHEN others THEN
      RETURN 1;
END;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_OBJASE" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_OBJASE" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_OBJASE" TO "PROGRAMADORESCSI";
