--------------------------------------------------------
--  DDL for Package Body PAC_MD_AGE_PROPIEDADES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_AGE_PROPIEDADES" IS
   /******************************************************************************
        NOMBRE:       PAC_MD_AGE_PROPIEDADES
        PROPOSITO: Funciones para gestionar los parametros de los agentes

        REVISIONES:
        Ver        Fecha        Autor             DescripciÃ³n
        ---------  ----------  ---------------  ------------------------------------
        1.0        08/03/2012  AMC               1. Creación del package.

     ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*************************************************************************
   Inserta el parà metre per agent
   param in pcagente  : Codi agent
   param in pcparam    : Codi parametre
   param in pnvalpar   : Resposta numérica
   param in ptvalpar   : Resposta text
   param in pfvalpar   : Resposta data
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_ins_paragente(
      pcagente IN NUMBER,
      pcparam IN VARCHAR2,
      pnvalpar IN NUMBER,
      ptvalpar IN VARCHAR2,
      pfvalpar IN DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parámetros  - pcagente: ' || pcagente || ' - pcparam: ' || pcparam
            || ' - pnvalpar: ' || pnvalpar || ' - ptvalpar: ' || ptvalpar || ' - pfvalpar: '
            || pfvalpar;
      vobject        VARCHAR2(200) := 'PAC_MD_AGE_PROPIEDADES.f_ins_paragente';
   BEGIN
      IF pcagente IS NULL
         OR pcparam IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_age_propiedades.f_ins_paragente(pcagente, pcparam, pnvalpar, ptvalpar,
                                                     pfvalpar);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
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
   END f_ins_paragente;

   /*************************************************************************
        Esborra el parà metre per agente
        param in pcagente   : Codi agent
        param in pcparam    : Codi parametre
        return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_del_paragente(
      pcagente IN NUMBER,
      pcparam IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                         := 'parmetros  - pcagente: ' || pcagente || ' - pcparam: ' || pcparam;
      vobject        VARCHAR2(200) := 'PAC_MD_AGE_PROPIEDADES.f_del_paragente';
   BEGIN
      IF pcagente IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_age_propiedades.f_del_paragente(pcagente, pcparam);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
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
   END f_del_paragente;

   /*************************************************************************
       Obté la select amb els parà metres per agent
       param in pcagente    : Codi agent
       param in ptots      : 0.- Només retorna els parà metres contestats
                             1.- Retorna tots els parà metres
       param out pcur      : Cursor
       return              : 0.- OK, 1.- KO
    *************************************************************************/
   FUNCTION f_get_paragente(
      pcagente IN NUMBER,
      ptots IN NUMBER,
      pcur OUT sys_refcursor,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                             := 'parámetros - pcagente: ' || pcagente || ' - ptots: ' || ptots;
      vobject        VARCHAR2(200) := 'PAC_MD_AGE_PROPIEDADES.F_GET_PARAGENTE';
      squery         VARCHAR2(5000);
   BEGIN
      IF pcagente IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_age_propiedades.f_get_paragente(pcagente, pac_md_common.f_get_cxtidioma,
                                                     ptots, squery);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      pcur := pac_md_listvalores.f_opencursor(squery, mensajes);
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
   END f_get_paragente;

   /*************************************************************************
        Obté la select amb els parà metres per agente
        pcparam IN NUMBER,
        param out pobparagente
        return              : 0.- OK, 1.- KO
    *************************************************************************/
   FUNCTION f_get_obparagente(
      pcparam IN VARCHAR2,
      pobparagente OUT ob_iax_par_agentes,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parmetros - psperson: ' || pcparam;
      vobject        VARCHAR2(200) := 'PAC_MD_AGE_PROPIEDADES.F_GET_OBPARAGENTE';
      squery         VARCHAR2(5000);
      pcur           sys_refcursor;
   BEGIN
      IF pcparam IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_persona.f_get_obparpersona(pcparam, pac_md_common.f_get_cxtidioma, squery);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      pcur := pac_md_listvalores.f_opencursor(squery, mensajes);
      pobparagente := ob_iax_par_agentes();

      LOOP
         FETCH pcur
          INTO pobparagente.cutili, pobparagente.cparam, pobparagente.ctipo,
               pobparagente.tparam, pobparagente.cvisible, pobparagente.tvalpar,
               pobparagente.nvalpar, pobparagente.fvalpar, pobparagente.resp;

         EXIT WHEN pcur%NOTFOUND;
         pobparagente := ob_iax_par_agentes();
      END LOOP;

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
   END f_get_obparagente;

    /*************************************************************************
   Funcio per comprobar si una propietat es visible per l'agent
      pcagente IN NUMBER,
      pcvisible in texto, funcion para comprobar la visivilidad

   return              : 0.- No visible, 1.- Visible
   *************************************************************************/
   FUNCTION f_get_compvisible(
      pcagente IN NUMBER,
      pcvisible IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                       := 'parmetros - pcagente: ' || pcagente || ' - pcvisible:' || pcvisible;
      vobject        VARCHAR2(200) := 'PAC_MD_AGE_PROPIEDADES.F_GET_COMPVISIBLE';
   BEGIN
      IF pcagente IS NULL
         OR pcvisible IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_age_propiedades.f_get_compvisible(pcagente, pcvisible);
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_compvisible;
END pac_md_age_propiedades;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_AGE_PROPIEDADES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_AGE_PROPIEDADES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_AGE_PROPIEDADES" TO "PROGRAMADORESCSI";
