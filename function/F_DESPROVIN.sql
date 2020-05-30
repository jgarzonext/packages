--------------------------------------------------------
--  DDL for Function F_DESPROVIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_DESPROVIN" (pcprovin IN NUMBER,
                                        ptprovin IN OUT VARCHAR2,
                                        pcpais IN OUT NUMBER,
                                        ptpais OUT VARCHAR2,
                                        pcidioma IN NUMBER default f_usu_idioma)
RETURN NUMBER authid current_user IS
/***********************************************************************
    F_PROVPAIS: Retorna la descripción de la provincia, código de
país y descripción país.
    ALLIBMFM
***********************************************************************/
BEGIN


    SELECT tprovin,cpais
    INTO   ptprovin,pcpais
    FROM   PROVINCIAS
    WHERE  cprovin = pcprovin
    and    cpais = nvl(pcpais,cpais) ;

    SELECT tpais
    INTO   ptpais
    FROM   despaises
    WHERE  cpais = pcpais
    AND    cidioma = pcidioma ;




    RETURN 0;

EXCEPTION
    WHEN others THEN
        RETURN 102551;    -- Provincia o país inexistente
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_DESPROVIN" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_DESPROVIN" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_DESPROVIN" TO "PROGRAMADORESCSI";
