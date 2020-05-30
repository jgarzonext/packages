--------------------------------------------------------
--  DDL for Package Body PAC_IAX_SIN_IMPUESTOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_SIN_IMPUESTOS" AS
/******************************************************************************
   NOMBRE:    pac_iax_sin_impuestos
   PROPÓSITO: Funciones para calculo de impuestos

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
    1.0       13/08/2013   NSS             Creacion
*/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   FUNCTION f_get_impuestos(
      pcconcep IN NUMBER,
      pccodimp IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vobject        VARCHAR2(500) := 'pac_iax_sin_impuestos.f_get_impuestos';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vparam         VARCHAR2(500) := ' pcconcep= ' || pcconcep || ' pccodimp= ' || pccodimp;
   BEGIN
      cur := pac_md_sin_impuestos.f_get_impuestos(pcconcep, pccodimp, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_impuestos;

   FUNCTION f_set_impuesto(
      pcconcep IN NUMBER,
      pccodimp IN NUMBER,
      pfdesde IN DATE,
      pctipper IN NUMBER,
      pcregfiscal IN NUMBER,
      pctipcal IN NUMBER,
      pifijo IN NUMBER,
      pcbasecal IN NUMBER,
      pcbasemin IN NUMBER,
      pcbasemax IN NUMBER,
      pnporcent IN NUMBER,
      pimin IN NUMBER,
      pimax IN NUMBER,
      pnordimp IN NUMBER,
      pcsubtab IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      /*************************************************************************
         Graba el calculo del impuesto
         param out mensajes : mesajes de error
         return             : number
      *************************************************************************/
      vobjectname    VARCHAR2(500) := 'pac_iax_sin_impuestos.f_get_impuestos';
      vparam         VARCHAR2(500)
         := 'parámetros - pcconcep: ' || pcconcep || ' - pccodimp: ' || pccodimp
            || ' - pfdesde: ' || pfdesde || ' - pctipper: ' || pctipper || ' - pcregfiscal: '
            || pcregfiscal || ' - pctipcal: ' || pctipcal || ' - pifijo: ' || pifijo
            || ' - pcbasecal: ' || pcbasecal || ' - pcbasemin: ' || pcbasemin
            || ' - pcbasemax: ' || pcbasemax || ' - pnporcent: ' || pnporcent || ' - pimin: '
            || pimin || ' - pimax: ' || pimax || ' - pnordimp: ' || pnordimp
            || ' - pcsubtab: ' || pcsubtab;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_sin_impuestos.f_set_impuesto(pcconcep, pccodimp, pfdesde, pctipper,
                                                     pcregfiscal, pctipcal, pifijo, pcbasecal,
                                                     pcbasemin, pcbasemax, pnporcent, pimin,
                                                     pimax, pnordimp, pcsubtab, mensajes);

      IF vnumerr != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_impuesto;

   FUNCTION f_del_impuesto(
      pcconcep IN NUMBER,
      pccodimp IN NUMBER,
      pnordimp IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'pac_iax_sin_impuestos.f_del_impuesto';
      vparam         VARCHAR2(500)
         := 'parámetros - pcconcep=' || pcconcep || ' pccodimp: ' || pccodimp || ' pnordimp: '
            || pnordimp;
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(5) := 1;
   BEGIN
      vnumerr := pac_md_sin_impuestos.f_del_impuesto(pcconcep, pccodimp, pnordimp, mensajes);

      IF vnumerr != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_del_impuesto;

   FUNCTION f_get_impuesto(
      pcconcep IN NUMBER,
      pccodimp IN NUMBER,
      pnordimp IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vobject        VARCHAR2(500) := 'pac_iax_sin_impuestos.f_get_impuesto';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vparam         VARCHAR2(500)
         := ' pcconcep= ' || pcconcep || ' pccodimp= ' || pccodimp || ' pnordimp= '
            || pnordimp;
   BEGIN
      cur := pac_md_sin_impuestos.f_get_impuesto(pcconcep, pccodimp, pnordimp, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_impuesto;

   FUNCTION f_get_lstimpuestos(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vobject        VARCHAR2(500) := 'pac_iax_sin_impuestos.f_get_lstimpuestos';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vparam         VARCHAR2(500) := ' ';
   BEGIN
      cur := pac_md_sin_impuestos.f_get_lstimpuestos(mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstimpuestos;

   FUNCTION f_get_tdescri_subtab(pcsubtab IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vobject        VARCHAR2(500) := 'pac_iax_sin_impuestos.f_get_tdescri_subtab';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vparam         VARCHAR2(500) := ' pcsubtab= ' || pcsubtab;
   BEGIN
      cur := pac_md_sin_impuestos.f_get_tdescri_subtab(pcsubtab, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_tdescri_subtab;

   FUNCTION f_copia_impuesto(
      pcconcep IN NUMBER,
      pcconcep_ant IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'pac_iax_sin_impuestos.f_copia_impuesto';
      vparam         VARCHAR2(500)
                  := 'parámetros - pcconcep=' || pcconcep || ' pcconcep_ant: ' || pcconcep_ant;
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(5) := 1;
   BEGIN
      vnumerr := pac_md_sin_impuestos.f_copia_impuesto(pcconcep, pcconcep_ant, mensajes);

      IF vnumerr != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_copia_impuesto;

   FUNCTION f_get_lstconceptos(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vobject        VARCHAR2(500) := 'pac_iax_sin_impuestos.f_get_lstconceptos';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vparam         VARCHAR2(500) := ' ';
   BEGIN
      cur := pac_md_sin_impuestos.f_get_lstconceptos(mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstconceptos;

   FUNCTION f_get_definiciones_reteica(
      pcpais IN NUMBER,
      pcprovin IN NUMBER,
      pcpoblac IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vobject        VARCHAR2(500) := 'pac_iax_sin_impuestos.f_get_definiciones_reteica';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vparam         VARCHAR2(500)
         := 'parámetros - pcpais=' || pcpais || ' pcprovin: ' || pcprovin || ' pcpoblac: '
            || pcpoblac;
   BEGIN
      cur := pac_md_sin_impuestos.f_get_definiciones_reteica(pcpais, pcprovin, pcpoblac,
                                                             mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_definiciones_reteica;

   FUNCTION f_set_valores_reteica(
      pcpais IN NUMBER,
      pcprovin IN NUMBER,
      pcpoblac IN NUMBER,
      pfdesde IN DATE,
      pvalores_reteica IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_SINIESTROS.f_set_valores_reteica';
      vparam         VARCHAR2(4000)
         := 'pcpais=' || pcpais || ' pcprovin=' || pcprovin || ' pcprovin=' || pcprovin
            || ' pcpoblac=' || pcpoblac || ' pfdesde=' || pfdesde || ' pvalores_reteica='
            || pvalores_reteica;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_sin_impuestos.f_set_valores_reteica(pcpais, pcprovin, pcpoblac,
                                                            pfdesde, pvalores_reteica,
                                                            mensajes);

      IF vnumerr != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_valores_reteica;
END pac_iax_sin_impuestos;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_SIN_IMPUESTOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_SIN_IMPUESTOS" TO "PROGRAMADORESCSI";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_SIN_IMPUESTOS" TO "R_AXIS";
