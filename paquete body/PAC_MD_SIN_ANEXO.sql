--------------------------------------------------------
--  DDL for Package Body PAC_MD_SIN_ANEXO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_SIN_ANEXO" AS
      /******************************************************************************
      NOMBRE:     PAC_MD_SINIESTROS
      PROP¿SITO:  Funciones para la gesti¿n de siniestros.

      REVISIONES:
      Ver        Fecha        Autor             Descripci¿n
      ---------  ----------  ---------------  ------------------------------------
      1.0        23/11/2016   IGIL            1. Creaci¿n del package.
*/
/************************************************************************************
         Devuelve la lista de profesionales que coinciden con los parametro indicados
************************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;
      FUNCTION f_get_datos_sin(
      psprofes IN NUMBER,
      pnnumide IN VARCHAR2,
      ptnombre IN VARCHAR2,
      pnsinies IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS

      vobjectname    VARCHAR2(500) := 'PAC_MD_SIN_ANEXO.F_GET_DATOS_SIN';
      vparam         VARCHAR2(500)
         := ' psprofes= ' || psprofes || ' pnnumide= ' || pnnumide || ' ptnombre=' || ptnombre
            || ' pnsinies=' || pnsinies;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vcursor        sys_refcursor;
      vsquery         VARCHAR2(5000);
   BEGIN
      vnumerr := pac_sin_anexo.f_get_datos_sin(psprofes, pnnumide, ptnombre, pnsinies,
                                              pac_md_common.f_get_cxtidioma(), vsquery);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      vcursor  := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           vnumerr, SQLCODE, SQLERRM);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
   END f_get_datos_sin;
END pac_md_sin_anexo;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_SIN_ANEXO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_SIN_ANEXO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_SIN_ANEXO" TO "PROGRAMADORESCSI";
