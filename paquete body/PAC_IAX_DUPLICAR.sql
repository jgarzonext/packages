--------------------------------------------------------
--  DDL for Package Body PAC_IAX_DUPLICAR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_DUPLICAR" IS
/******************************************************************************
   NOMBRE:      PAC_IAX_DUPLICAR
   PROPÓSITO: Funcions per gestionar duplicació

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
         param in    sseguroorig : número seguro
         param out   mensajes    : col·lecció de missatges
         return               : 0 -> OK
                              : 1 -> NO OK
   *************************************************************************/
   FUNCTION f_valida_dup_seguro(psseguroorig IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'psseguroorig: ' || psseguroorig;
      vobject        VARCHAR2(200) := 'PAC_IAX_DUPLICAR.f_valida_dup_seguro';
      nerror         NUMBER;
   BEGIN
      nerror := pac_md_duplicar.f_valida_dup_seguro(psseguroorig, mensajes);

      IF nerror = 1 THEN
         -- error
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
END pac_iax_duplicar;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_DUPLICAR" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_DUPLICAR" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_DUPLICAR" TO "PROGRAMADORESCSI";
