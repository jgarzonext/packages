--------------------------------------------------------
--  DDL for Package PAC_ACTIVIDADES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_ACTIVIDADES" AS
/******************************************************************************
   NOMBRE:       PAC_ACTIVIDADES
   PROPÓSITO:  Mantenimiento actividades. gestión

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        29/12/2008   XCG                1. Creación del package. con una única función: F_GET_ACTIVIRAMO (BUG 8510)
 ******************************************************************************/
/**************************************************************************
        Función que se retorna las actividades definidas de un ramo
        PARAM IN PCRAMO      : Código del Ramo
        PARAM IN PCACTIVI    : Código de la Actividad
        PARAM OUT PRETCURSOR :SYS_REFCURSOR
        PARAM OUT NERROR     : Código de error
        PARAM OUT mensaje    : Código de error (0: operación correcta sino 1)
   *************************************************************************/
   FUNCTION f_get_activiramo(pcramo IN NUMBER, nerror OUT NUMBER)
      RETURN sys_refcursor;
END pac_actividades;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_ACTIVIDADES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_ACTIVIDADES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_ACTIVIDADES" TO "PROGRAMADORESCSI";
