--------------------------------------------------------
--  DDL for Package PAC_SIN_ANEXO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_SIN_ANEXO" IS
    /******************************************************************************
    NOMBRE:     PAC_SIN_ANEXO
    PROP¿SITO:  Cuerpo del paquete de las funciones para
       los m¿dulos del area de SINIESTROS

    REVISIONES:
    Ver        Fecha        Autor             Descripci¿n
    ---------  ----------  ---------------  ------------------------------------
    1.0        23/11/2016   IGIL         1. Creaci¿n del package.
    */

   FUNCTION f_get_datos_sin(
      psprofes IN NUMBER,
      pnnumide IN VARCHAR2,
      ptnombre IN VARCHAR2,
      pnsinies IN NUMBER,
      pcidioma IN NUMBER,
      ptselect OUT VARCHAR2)
      RETURN NUMBER;
END pac_sin_anexo;

/

  GRANT EXECUTE ON "AXIS"."PAC_SIN_ANEXO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_SIN_ANEXO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_SIN_ANEXO" TO "PROGRAMADORESCSI";
