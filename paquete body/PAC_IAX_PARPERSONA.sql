--------------------------------------------------------
--  DDL for Package Body PAC_IAX_PARPERSONA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_PARPERSONA" AS
   /******************************************************************************
   NOMBRE:       PAC_IAX_PARPERSONA
   PROPÓSITO:  Funciones para gestionar los parametros de personas

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        30/01/2013   AMC                1. Creación del package.
   ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   FUNCTION f_get_detparam(
      pcodigo IN VARCHAR2,
      pcondicion IN VARCHAR2,
      pcidioma IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor AS
      cur            sys_refcursor;
      v_npasexec     NUMBER(8) := 1;
      v_tparam       VARCHAR2(1) := NULL;
      v_tobject      VARCHAR2(200) := 'PAC_IAX_PARPERSONA.f_get_detparam';
      v_v_terror     VARCHAR2(200) := 'Error recuperar parametros';
   BEGIN
      cur := pac_md_parpersona.f_get_detparam(pcodigo, pcondicion,
                                              NVL(pcidioma, pac_md_common.f_get_cxtidioma),
                                              mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_tobject, 1000006, v_npasexec, v_tparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_tobject, 1000001, v_npasexec, v_tparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_detparam;
END pac_iax_parpersona;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_PARPERSONA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_PARPERSONA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_PARPERSONA" TO "PROGRAMADORESCSI";
