--------------------------------------------------------
--  DDL for Package Body PAC_MD_ACTIVIDADES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_ACTIVIDADES" AS
/******************************************************************************
   NOMBRE:       PAC_MD_ACTIVIDADES
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
      vobjectname    VARCHAR2(500) := 'pac_actividades.f_get_activiramo';
      vparam         VARCHAR2(500) := 'parámetros - pcramo: ' || pcramo;
      vpasexec       NUMBER := 1;
      vnumerr        NUMBER := 0;
      vnerror        NUMBER := 0;
   BEGIN
      --CONTROL DE PARAMETROS DE ENTRADA
      IF pcramo IS NULL THEN
         vparam := 'parametro - pcramo';
         RAISE e_param_error;
      END IF;

      --LLAMADA A LA  FUNCIÓN
      v_cursor := pac_actividades.f_get_activiramo(pcramo, vnerror);

      IF v_cursor IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnerror);
         RAISE e_object_error;
      END IF;

      RETURN v_cursor;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN NULL;
   END f_get_activiramo;
END pac_md_actividades;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_ACTIVIDADES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_ACTIVIDADES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_ACTIVIDADES" TO "PROGRAMADORESCSI";
