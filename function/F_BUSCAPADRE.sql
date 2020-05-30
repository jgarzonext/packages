--------------------------------------------------------
--  DDL for Function F_BUSCAPADRE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_BUSCAPADRE" (
   pcempres IN NUMBER,
   pcagente IN NUMBER,
   pctipage IN OUT NUMBER,
   pfbusca IN OUT DATE,
   pcpadre IN OUT NUMBER)
   RETURN NUMBER AUTHID CURRENT_USER IS
   codi_error     NUMBER := 0;
BEGIN
   pcpadre := pac_redcomercial.f_busca_padre(pcempres, pcagente, pctipage, pfbusca);
   RETURN 0;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      codi_error := 102780;
      RETURN(codi_error);
   WHEN OTHERS THEN
      codi_error := 102780;
      RETURN(codi_error);
END;

/

  GRANT EXECUTE ON "AXIS"."F_BUSCAPADRE" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_BUSCAPADRE" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_BUSCAPADRE" TO "PROGRAMADORESCSI";
