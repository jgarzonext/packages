--------------------------------------------------------
-- Archivo creado  - jueves-octubre-24-2019   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Function FF_DESFRANQUICIA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "FF_DESFRANQUICIA" (PCGRUP IN NUMBER, PCIDIOMA IN NUMBER) RETURN VARCHAR2 IS 

    vttexto bf_desgrup.tgrup%TYPE;
    
BEGIN
    
    SELECT  tgrup
    INTO    vttexto
    FROM    bf_desgrup
    WHERE cidioma = pcidioma
      AND cgrup = pcgrup;
    
    RETURN vttexto;
    
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END FF_DESFRANQUICIA;

/
