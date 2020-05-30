--------------------------------------------------------
--  DDL for Package Body PAC_IAX_SIN_ANEXO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_SIN_ANEXO" AS
   /******************************************************************************
      NOMBRE:      PAC_IAX_SINIESTROS
      PROP¿SITO: Funciones para la gesti¿n de siniestros

      REVISIONES:

      Ver        Fecha        Autor             Descripci¿n
      ---------  ----------  ---------------  ------------------------------------
      1.0        17/02/2009   XPL i XV         1. Creaci¿n del package.
*/
      FUNCTION f_get_datos_sin(
      psprofes IN NUMBER,
      pnnumide IN VARCHAR2,
      ptnombre IN VARCHAR2,
      pnsinies IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vobject        VARCHAR2(500) := 'PAC_IAX_SIN_ANEXO.f_get_datos_sin';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vparam         VARCHAR2(500)
         := ' psprofes= ' || psprofes || ' pnnumide= ' || pnnumide || ' ptnombre=' || ptnombre
            || ' pnsinies= ' || pnsinies;
   BEGIN
      cur := pac_md_sin_anexo.f_get_datos_sin(psprofes, pnnumide, ptnombre, pnsinies, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_datos_sin;
END pac_iax_sin_anexo;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_SIN_ANEXO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_SIN_ANEXO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_SIN_ANEXO" TO "PROGRAMADORESCSI";
