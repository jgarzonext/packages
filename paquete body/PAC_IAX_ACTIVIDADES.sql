--------------------------------------------------------
--  DDL for Package Body PAC_IAX_ACTIVIDADES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_ACTIVIDADES" AS
/******************************************************************************
   NOMBRE:       PAC_IAX_ACTIVIDADES
   PROPÓSITO:  Mantenimiento actividades. gestión

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        13/01/2009   XCG                1. Creación del package. con una única función: F_GET_ACTIVIRAMO (BUG 8510)
 ******************************************************************************/
/**************************************************************************
        Función que se retorna las actividades definidas de un ramo
        PARAM IN PCRAMO      : Código del Ramo
        PARAM OUT PRETCURSOR :SYS_REFCURSOR
        PARAM OUT mensajes    : Tratamiento del mensaje
   *************************************************************************/
   FUNCTION f_get_activiramo(pcramo IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      v_cursor       sys_refcursor;
   BEGIN
      --LLAMADA A LA  FUNCIÓN
      v_cursor := pac_md_actividades.f_get_activiramo(pcramo, mensajes);
      RETURN v_cursor;
   END f_get_activiramo;
END pac_iax_actividades;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_ACTIVIDADES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_ACTIVIDADES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_ACTIVIDADES" TO "PROGRAMADORESCSI";
