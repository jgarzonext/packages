--------------------------------------------------------
--  DDL for Package PAC_CODIGOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_CODIGOS" AUTHID CURRENT_USER AS
   /******************************************************************************
    NOMBRE:      PAC_CODIGOS
    PROPÓSITO:   Package de codigos

    REVISIONES:
    Ver        Fecha        Autor             Descripción
    ---------  ----------  ---------------  ------------------------------------
    1.0        --/--/----   ---                1. Creación del package.
    ******************************************************************************/
   FUNCTION f_get_tipcodigos(pcempres IN NUMBER, pcidioma IN NUMBER, pquery OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_get_idiomas_activos(pcempres IN NUMBER, pcidioma IN NUMBER, pquery OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_set_codsproduc(
      pcempres IN NUMBER,
      pcidioma IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pccolect IN NUMBER,
      pctipseg IN NUMBER,
      pcodigo OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_set_codcgarant(pcempres IN NUMBER, pcidioma IN NUMBER, pcodigo OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_set_codpregun(pcempres IN NUMBER, pcidioma IN NUMBER, pcodigo OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_set_codramo(pcempres IN NUMBER, pcidioma IN NUMBER, pcodigo OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_set_codactivi(
      pcramo IN NUMBER,
      pcempres IN NUMBER,
      pcidioma IN NUMBER,
      pcodigo OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_set_codliterales(
      ptlitera_1 IN VARCHAR2,
      ptlitera_2 IN VARCHAR2,
      ptlitera_3 IN VARCHAR2,
      ptlitera_4 IN VARCHAR2,
      ptlitera_5 IN VARCHAR2,
      ptlitera_6 IN VARCHAR2,
      ptlitera_7 IN VARCHAR2,
      ptlitera_8 IN VARCHAR2,
      ptlitera_9 IN VARCHAR2,
      ptlitera_10 IN VARCHAR2,
      pcempres IN NUMBER,
      pcidioma IN NUMBER,
      pcodigo OUT VARCHAR2)
      RETURN NUMBER;
END pac_codigos;

/

  GRANT EXECUTE ON "AXIS"."PAC_CODIGOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CODIGOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CODIGOS" TO "PROGRAMADORESCSI";
