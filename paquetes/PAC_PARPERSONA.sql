--------------------------------------------------------
--  DDL for Package PAC_PARPERSONA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_PARPERSONA" AS
   /******************************************************************************
      NOMBRE:       PAC_PARPERSONA
      PROPÓSITO:  Funciones para gestionar los parametros de personas

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        30/01/2013   AMC                1. Creación del package.
      ******************************************************************************/
   FUNCTION f_get_detparam(
      pcodigo IN VARCHAR2,
      pcondicion IN VARCHAR2,
      pcidioma IN NUMBER,
      pnumerror IN OUT NUMBER)
      RETURN VARCHAR2;
END pac_parpersona;

/

  GRANT EXECUTE ON "AXIS"."PAC_PARPERSONA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PARPERSONA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PARPERSONA" TO "PROGRAMADORESCSI";
