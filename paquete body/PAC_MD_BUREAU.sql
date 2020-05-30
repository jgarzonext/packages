--------------------------------------------------------
--  DDL for Package Body PAC_MD_BUREAU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_BUREAU" IS
/******************************************************************************
   NOMBRE:        PAC_MD_BUREAU
   PROP¿¿¿¿¿SITO:    Funciones para gestionar intermediarios

   REVISIONES:
   Ver        Fecha        Autor             Descripcion
   ---------  ----------  ---------------  ------------------------------------
   1.0        08/02/2016   GROA             1. Creacion del package.
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*************************************************************************
     FUNCTION f_get_bureau
          return                 : 0 -> OK
                                  1 -> NO OK
   *************************************************************************/
  FUNCTION f_get_bureau(psseguro IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'psseguro= ' || psseguro;
      vobject        VARCHAR2(200) := 'PAC_MD_BUREAU.f_get_bureau';
      cur       sys_refcursor;
  BEGIN
    --cur := pac_bureau.f_get_bureau(,);
    cur := pac_bureau.f_get_bureau(psseguro);
      RETURN cur;

    RETURN NULL;
    EXCEPTION

WHEN e_param_error THEN
PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(MENSAJES, VOBJECT,1000005, VPASEXEC, VPARAM);
RETURN null;

WHEN e_object_error THEN
pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject,1000006, vpasexec, vparam);
RETURN null;

WHEN OTHERS THEN
pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject,1000001, vpasexec, vparam,
NULL,SQLCODE,SQLERRM);
RETURN null;
  END f_get_bureau;
   /*************************************************************************
     FUNCTION f_genera_ficha
        Funcion que permite generar fichas
        return                 : 0 -> OK
                                  1 -> NO OK
   *************************************************************************/
  FUNCTION f_genera_ficha(psseguro IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
       nerror         NUMBER;
      vnumerr        NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(4000) := 'psseguro: ' || psseguro;
      vobject        VARCHAR2(200) := 'pac_md_bureau.f_genera_ficha';
  BEGIN
      vnumerr :=
         pac_bureau.f_genera_ficha(psseguro);
    IF vnumerr <> 0 THEN
         ROLLBACK;
         RAISE e_object_error;
      ELSE
         COMMIT;
      END IF;

      RETURN 0;

  EXCEPTION
WHEN e_param_error THEN
pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject,1000005, vpasexec, vparam);
RETURN 1;

WHEN e_object_error THEN
pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject,1000006, vpasexec, vparam);
RETURN 1;

WHEN OTHERS THEN
pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject,1000001, vpasexec, vparam,
NULL,SQLCODE,SQLERRM);
RETURN 1;

 END f_genera_ficha;
 /*************************************************************************
     FUNCTION f_anula_ficha
        Funcion que permite anular fichas
        return                 : 0 -> OK
                                  1 -> NO OK
   *************************************************************************/
  FUNCTION f_anula_ficha(pfbureau IN NUMBER  , pnsuplem IN NUMBER , pnmovimi IN NUMBER,  mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
    nerror         NUMBER;
      vnumerr        NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(4000) := 'pfbureau: ' || pfbureau || 'pnsuplem: ' || pnsuplem|| 'pnmovimi: ' || pnmovimi;
      vobject        VARCHAR2(200) := 'pac_md_bureau.f_anula_ficha';
  BEGIN
      vnumerr :=
         pac_bureau.f_anula_ficha(pfbureau,pnsuplem ,pnmovimi);

          IF vnumerr <> 0 THEN
         ROLLBACK;
         RAISE e_object_error;
      ELSE
         COMMIT;
      END IF;

      RETURN 0;
RETURN 0;
  EXCEPTION
WHEN e_param_error THEN
pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject,1000005, vpasexec, vparam);
RETURN 1;

WHEN e_object_error THEN
pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject,1000006, vpasexec, vparam);
RETURN 1;

WHEN OTHERS THEN
pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject,1000001, vpasexec, vparam,
NULL,SQLCODE,SQLERRM);
RETURN 1;
  END f_anula_ficha;
 /*************************************************************************
     FUNCTION f_valida_pol
        Funcion que permite validar polizas
        return                 : 0 -> OK
                                  1 -> NO OK
   *************************************************************************/
  FUNCTION f_valida_pol(psseguro IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
     nerror         NUMBER;
      vnumerr        NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(4000) := 'psseguro: ' || psseguro;
      vobject        VARCHAR2(200) := 'pac_md_bureau.f_anula_ficha';
  BEGIN
      vnumerr :=
         pac_bureau.f_valida_pol(psseguro);
RETURN vnumerr;
  EXCEPTION
WHEN e_param_error THEN
pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject,1000005, vpasexec, vparam);
RETURN 1;

WHEN e_object_error THEN
pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject,1000006, vpasexec, vparam);
RETURN 1;

WHEN OTHERS THEN
pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject,1000001, vpasexec, vparam,
NULL,SQLCODE,SQLERRM);
RETURN 1;
  END f_valida_pol;
 /*************************************************************************
     FUNCTION f_asocia_doc
        Funcion que permite asociar documentos
        return                 : 0 -> OK
                                  1 -> NO OK
   *************************************************************************/
  FUNCTION f_asocia_doc(psseguro IN NUMBER  , pnsuplem IN NUMBER , pnmovimi IN NUMBER,  piddoc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
   nerror         NUMBER;
      vnumerr        NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(4000) := 'psseguro: ' || psseguro || 'pnsuplem: ' || pnsuplem ||'pnmovimi: ' || pnmovimi || 'piddoc: ' || piddoc;
      vobject        VARCHAR2(200) := 'pac_md_bureau.f_anula_ficha';
  BEGIN
      vnumerr :=
         pac_bureau.f_asocia_doc(psseguro, pnsuplem,pnmovimi,piddoc);
RETURN 0;
  EXCEPTION
WHEN e_param_error THEN
pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject,1000005, vpasexec, vparam);
RETURN 1;

WHEN e_object_error THEN
pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject,1000006, vpasexec, vparam);
RETURN 1;

WHEN OTHERS THEN
pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject,1000001, vpasexec, vparam,
NULL,SQLCODE,SQLERRM);
RETURN 1;
  END f_asocia_doc;

END PAC_MD_BUREAU;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_BUREAU" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_BUREAU" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_BUREAU" TO "PROGRAMADORESCSI";
