--------------------------------------------------------
--  DDL for Package PAC_MD_ACTIVIDADES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_ACTIVIDADES" AS
/******************************************************************************
   NOMBRE:       PAC_MD_ACTIVIDADES
   PROPÓSITO:  Mantenimiento actividades. gestión

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        13/01/2009   XCG                1. Creación del package. con una única función: F_GET_ACTIVIRAMO
 ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

/**************************************************************************
        Función que se retorna las actividades definidas de un ramo
        PARAM IN PCRAMO      : Código del Ramo
        PARAM OUT PRETCURSOR :SYS_REFCURSOR
        PARAM OUT mensajes    : Tratamiento del mensaje
   *************************************************************************/
   FUNCTION f_get_activiramo(pcramo IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;
END pac_md_actividades;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_ACTIVIDADES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_ACTIVIDADES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_ACTIVIDADES" TO "PROGRAMADORESCSI";
