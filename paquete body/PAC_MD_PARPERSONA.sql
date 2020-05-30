--------------------------------------------------------
--  DDL for Package Body PAC_MD_PARPERSONA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_PARPERSONA" AS
   /******************************************************************************
        NOMBRE:       PAC_MD_PARPERSONA
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
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor AS
      cur            sys_refcursor;
      v_npasexec     NUMBER(8) := 1;
      v_tparam       VARCHAR2(1) := NULL;
      v_tobject      VARCHAR2(200) := 'PAC_MD_PARPERSONA.f_get_detparam';
      v_v_terror     VARCHAR2(200) := 'Error recuperar parametros';
      v_tsquery      VARCHAR2(500);
      vnumerror      NUMBER;
   BEGIN
      v_tsquery := pac_parpersona.f_get_detparam(pcodigo, pcondicion, pcidioma, vnumerror);

      IF vnumerror <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerror);
         RAISE e_object_error;
      END IF;

      cur := pac_md_listvalores.f_opencursor(v_tsquery, mensajes);
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
END pac_md_parpersona;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_PARPERSONA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_PARPERSONA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_PARPERSONA" TO "PROGRAMADORESCSI";
