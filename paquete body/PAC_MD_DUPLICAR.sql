--------------------------------------------------------
--  DDL for Package Body PAC_MD_DUPLICAR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_DUPLICAR" IS
/******************************************************************************
   NOMBRE:      PAC_MD_DUPLICAR
   PROPÓSITO:    Funcions per gestionar duplicació

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        17/06/2013   RCL                1. Creación del package.
   2.0
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*************************************************************************
     FUNCTION f_valida_dup_seguro
        Funció que valida si es possible duplicar una proposta
        param in     sseguroorig : número seguro
        param out     mensajes     : col·lecció de missatges
        return                 : 0 -> OK
                                  1 -> NO OK
   *************************************************************************/
   FUNCTION f_valida_dup_seguro(psseguroorig IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vparam         VARCHAR2(500) := 'psseguroorig: ' || psseguroorig;
      vobject        VARCHAR2(200) := 'PAC_MD_DUPLICAR.f_valida_dup_seguro';
      num_err        NUMBER := 0;
      vpasexec       NUMBER(5) := 1;
   BEGIN
      IF psseguroorig IS NULL THEN
         RAISE e_param_error;
      END IF;

      num_err := pac_duplicar.f_valida_dup_seguro(psseguroorig);

      IF num_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_valida_dup_seguro;
END pac_md_duplicar;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_DUPLICAR" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_DUPLICAR" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_DUPLICAR" TO "PROGRAMADORESCSI";
