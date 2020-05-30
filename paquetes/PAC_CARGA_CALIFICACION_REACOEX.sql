--------------------------------------------------------
--  DDL for Package PAC_CARGA_CALIFICACION_REACOEX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_CARGA_CALIFICACION_REACOEX" AS

   FUNCTION F_CARGA_CALIFICACION_REACOEX (p_nombre  IN VARCHAR2,
                                         p_path    IN VARCHAR2,
                                         p_cproces IN NUMBER,
                                         psproces  IN OUT NUMBER)
      RETURN NUMBER;

END PAC_CARGA_CALIFICACION_REACOEX;

/

  GRANT EXECUTE ON "AXIS"."PAC_CARGA_CALIFICACION_REACOEX" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CARGA_CALIFICACION_REACOEX" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CARGA_CALIFICACION_REACOEX" TO "PROGRAMADORESCSI";
