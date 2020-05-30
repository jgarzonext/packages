--------------------------------------------------------
--  DDL for Package PAC_MULTIDIOMA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MULTIDIOMA" AUTHID CURRENT_USER IS
   /******************************************************************************
      NOMBRE:    PAC_MULTIDIOMA
      PROPÓSITO: Funciones para idiomas

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        13/09/2010  DRA              1. 0014712: ENSA101- Certificat de pertanyença
   ******************************************************************************/
   FUNCTION f_numlet(
      nidioma IN NUMBER,   -- El texto retornado dependerá del idioma.
      np_nume IN NUMBER,   -- Número que se quiere traducir.
      moneda IN VARCHAR2,   -- Sería conveniente leer de tabla datos referentes a la moneda (decimales, etc.)
      ctexto IN OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION ff_numlet(
      nidioma IN NUMBER,   -- El texto retornado dependerá del idioma.
      np_nume IN NUMBER,   -- Número que se quiere traducir.
      moneda IN VARCHAR2)   -- Sería conveniente leer de tabla datos referentes a la moneda (decimales, etc.)
      RETURN VARCHAR2;
END pac_multidioma;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_MULTIDIOMA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MULTIDIOMA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MULTIDIOMA" TO "PROGRAMADORESCSI";
