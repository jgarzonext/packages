--------------------------------------------------------
--  DDL for Function F_BUSCAPADRE2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_BUSCAPADRE2" (
   pcempres IN NUMBER,
   pcagente IN NUMBER,
   pctipage IN OUT NUMBER,
   pfbusca IN OUT DATE,
   pcpadre IN OUT NUMBER)
   RETURN NUMBER AUTHID CURRENT_USER IS
/*****************************************************************
   F_BUSCAPADRE2:  Es retorna el codi del pare del agent que es
      correspongui amb l'empresa, amb el tipus
      i el periode sol.licitat (pcpadre null i pctipage informat).
   ALLIBMFM
*****************************************************************/
   codi_error     NUMBER := 0;
BEGIN
   pcpadre := pac_redcomercial.f_busca_padre(pcempres, pcagente, pctipage, pfbusca);
   RETURN(codi_error);
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      codi_error := 102780;
      RETURN(codi_error);
   WHEN OTHERS THEN
      codi_error := 102780;
      RETURN(codi_error);
END;

/

  GRANT EXECUTE ON "AXIS"."F_BUSCAPADRE2" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_BUSCAPADRE2" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_BUSCAPADRE2" TO "PROGRAMADORESCSI";
