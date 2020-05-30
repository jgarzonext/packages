--------------------------------------------------------
--  DDL for Package Body PAC_IAX_BUREAU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_BUREAU" IS
 /*****************************************************************************
      NAME:       PAC_IAX_BUREAU
      PURPOSE:   Funciones que gestionan el m¿¿dulo de BUREAU

      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      1.0        22/03/2016   LROA            1. Creaci¿¿n del package.
   ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;
   mensajes       t_iax_mensajes := NULL;
   gidioma        NUMBER := pac_md_common.f_get_cxtidioma;
   gempres        NUMBER := pac_md_common.f_get_cxtempresa;
   gusuari        VARCHAR2(20) := pac_md_common.f_get_cxtusuario;

  FUNCTION f_get_bureau(psseguro IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'psseguro= ' || psseguro;
      vobject        VARCHAR2(200) := 'PAC_IAX_BUREAU.f_get_bureau';
      cur            sys_refcursor;
   BEGIN
      cur := pac_md_bureau.f_get_bureau(psseguro, mensajes);
      RETURN cur;
   EXCEPTION
     --
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
  END f_get_bureau;

  FUNCTION f_genera_ficha(psseguro IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      nerror         NUMBER;
      vnumerr        NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(4000)
         := 'psseguro: ' || psseguro;
      vobject        VARCHAR2(200) := 'pac_iax_bureau.f_genera_ficha';
   BEGIN
      vnumerr :=
         pac_md_bureau.f_genera_ficha(psseguro,mensajes);

       IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
    EXCEPTION
      --
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
RETURN 1;

  END f_genera_ficha;

  FUNCTION f_anula_ficha(pfbureau IN NUMBER  , pnsuplem IN NUMBER , pnmovimi IN NUMBER,    mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
 nerror         NUMBER;
      vnumerr        NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(4000)
         := 'pfbureau: ' || pfbureau || 'pnsuplem: ' || pnsuplem|| 'pnmovimi: ' || pnmovimi;
      vobject        VARCHAR2(200) := 'pac_iax_bureau.f_anula_ficha';
   BEGIN
      vnumerr :=
         pac_md_bureau.f_anula_ficha(pfbureau,pnsuplem, pnmovimi,mensajes);

          IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
    EXCEPTION
      --
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
RETURN 1;

  END f_anula_ficha;

  FUNCTION f_valida_pol(psseguro IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
       nerror         NUMBER;
      vnumerr        NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(4000)
         := 'psseguro: ' || psseguro;
      vobject        VARCHAR2(200) := 'pac_iax_bureau.f_valida_pol';
   BEGIN
      vnumerr :=
         pac_md_bureau.f_valida_pol(psseguro,mensajes);
      RETURN vnumerr;
    EXCEPTION
      --
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
RETURN 1;
  END f_valida_pol;

  FUNCTION  f_asocia_doc(psseguro IN NUMBER, pnsuplem IN NUMBER , pnmovimi IN NUMBER,  piddoc IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
         nerror         NUMBER;
      vnumerr        NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(4000)
         := 'psseguro: ' || psseguro || 'pnsuplem: ' || pnsuplem|| 'pnmovimi: ' || pnmovimi  || 'piddoc: '|| piddoc ;
      vobject        VARCHAR2(200) := 'pac_iax_bureau.f_asocia_doc';
   BEGIN
      vnumerr :=
         pac_md_bureau.f_asocia_doc(psseguro, pnsuplem , pnmovimi, piddoc,mensajes);
      RETURN vnumerr;
    EXCEPTION
      --
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
RETURN 1;
  END f_asocia_doc;

END PAC_IAX_BUREAU;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_BUREAU" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_BUREAU" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_BUREAU" TO "PROGRAMADORESCSI";
