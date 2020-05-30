--------------------------------------------------------
--  DDL for Package Body PAC_MD_SIN_IMPUESTOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_SIN_IMPUESTOS" AS
/******************************************************************************
   NOMBRE:    pac_md_sin_impuestos
   PROPÓSITO: Funciones para calculo de impuestos

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
    1.0       13/08/2013   NSS             Creacion
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*************************************************************************
      Abre un cursor con la sentencia suministrada
      param in squery    : consulta a executar
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_opencursor(squery IN VARCHAR2, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(4000) := SUBSTR(squery, 1, 1900);
      vobject        VARCHAR2(200) := 'pac_md_sin_impuestos.F_OpenCursor';
      terror         VARCHAR2(200) := 'No se puede recuperar la información';
   BEGIN
      OPEN cur FOR squery;

      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_opencursor;

   FUNCTION f_get_impuestos(
      pcconcep IN NUMBER,
      pccodimp IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
/************************************************************************************
         Devuelve la lista de impuestos que coinciden con los parametro indicados
************************************************************************************/
      vobjectname    VARCHAR2(500) := 'pac_md_sin_impuestos.f_get_impuestos';
      vparam         VARCHAR2(500) := ' pcconcep= ' || pcconcep || ' pccodimp= ' || pccodimp;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      cur            sys_refcursor;
      vquery         VARCHAR2(5000);
   BEGIN
      vnumerr := pac_sin_impuestos.f_get_impuestos(pcconcep, pccodimp,
                                                   pac_md_common.f_get_cxtempresa(),
                                                   pac_md_common.f_get_cxtidioma(), vquery);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      cur := f_opencursor(vquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           vnumerr, SQLCODE, SQLERRM);

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
      return             : 0/1
*************************************************************************/
      vobjectname    VARCHAR2(500) := 'pac_md_sin_impuestos.f_set_impuesto';
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
      vnumerr := pac_sin_impuestos.f_set_impuesto(pcconcep, pccodimp, pfdesde, pctipper,
                                                  pcregfiscal, pctipcal, pifijo, pcbasecal,
                                                  pcbasemin, pcbasemax, pnporcent, pimin,
                                                  pimax, pac_md_common.f_get_cxtempresa(),
                                                  pnordimp, pcsubtab);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_set_impuesto;

   FUNCTION f_del_impuesto(
      pcconcep IN NUMBER,
      pccodimp IN NUMBER,
      pnordimp IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
/*************************************************************************
         Elimina el calculo del impuesto
         param out mensajes : mesajes de error
         return             : number
*************************************************************************/
      vobjectname    VARCHAR2(500) := 'pac_md_sin_impuestos.f_del_impuesto';
      vparam         VARCHAR2(500)
         := 'parámetros - pcconcep=' || pcconcep || ' pccodimp: ' || pccodimp || ' pnordimp: '
            || pnordimp;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_sin_impuestos.f_del_impuesto(pcconcep, pccodimp, pnordimp,
                                                  pac_md_common.f_get_cxtempresa());
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_del_impuesto;

   FUNCTION f_get_impuesto(
      pcconcep IN NUMBER,
      pccodimp IN NUMBER,
      pnordimp IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
/************************************************************************************
         Devuelve los datos del impuesto indicado
************************************************************************************/
      vobjectname    VARCHAR2(500) := 'pac_md_sin_impuestos.f_get_impuesto';
      vparam         VARCHAR2(500)
         := ' pcconcep= ' || pcconcep || ' pccodimp= ' || pccodimp || ' pnordimp= '
            || pnordimp;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      cur            sys_refcursor;
      vquery         VARCHAR2(5000);
   BEGIN
      vnumerr := pac_sin_impuestos.f_get_impuesto(pcconcep, pccodimp, pnordimp,
                                                  pac_md_common.f_get_cxtempresa(),
                                                  pac_md_common.f_get_cxtidioma(), vquery);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      cur := f_opencursor(vquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           vnumerr, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_impuesto;

   FUNCTION f_get_lstimpuestos(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
/************************************************************************************
         Recupera los conceptos de recibo dados de alta para una empresa
************************************************************************************/
      vobjectname    VARCHAR2(500) := 'pac_md_sin_impuestos.f_get_lstimpuestos';
      vparam         VARCHAR2(500) := '  ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      cur            sys_refcursor;
      vquery         VARCHAR2(5000);
   BEGIN
      vnumerr := pac_sin_impuestos.f_get_lstimpuestos(pac_md_common.f_get_cxtempresa(),
                                                      pac_md_common.f_get_cxtidioma(), vquery);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      cur := f_opencursor(vquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           vnumerr, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstimpuestos;

   FUNCTION f_get_tdescri_subtab(pcsubtab IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
/************************************************************************************
         Devuelve el nombre de la subtabla si existe
************************************************************************************/
      vobjectname    VARCHAR2(500) := 'pac_md_sin_impuestos.f_get_tdescri_subtab';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vparam         NUMBER(5) := 'pcsubtab: ' || pcsubtab;
      cur            sys_refcursor;
      vquery         VARCHAR2(5000);
   BEGIN
      vnumerr := pac_sin_impuestos.f_get_tdescri_subtab(pcsubtab,
                                                        pac_md_common.f_get_cxtidioma(),
                                                        pac_md_common.f_get_cxtempresa(),
                                                        vquery);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      cur := f_opencursor(vquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           vnumerr, SQLCODE, SQLERRM);

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
/*************************************************************************
         Elimina el calculo del impuesto
         param out mensajes : mesajes de error
         return             : number
*************************************************************************/
      vobjectname    VARCHAR2(500) := 'pac_md_sin_impuestos.f_copia_impuesto';
      vparam         VARCHAR2(500)
                   := 'parámetros - pcconcep=' || pcconcep || ' pcconcep_ant=' || pcconcep_ant;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_sin_impuestos.f_copia_impuesto(pcconcep, pcconcep_ant);
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_copia_impuesto;

   FUNCTION f_get_lstconceptos(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
/************************************************************************************
         Recupera los conceptos de pago para una empresa
************************************************************************************/
      vobjectname    VARCHAR2(500) := 'pac_md_sin_impuestos.f_get_lstconceptos';
      vparam         VARCHAR2(500) := '  ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      cur            sys_refcursor;
      vquery         VARCHAR2(5000);
   BEGIN
      vnumerr := pac_sin_impuestos.f_get_lstconceptos(pac_md_common.f_get_cxtidioma(), vquery);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      cur := f_opencursor(vquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           vnumerr, SQLCODE, SQLERRM);

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
/************************************************************************************
         Devuelve la definición del reteica para los tipos de profesional de una localización en concreto
************************************************************************************/
      vobjectname    VARCHAR2(500) := 'pac_md_sin_impuestos.f_get_definiciones_reteica';
      vparam         VARCHAR2(500)
               := 'pcpais: ' || pcpais || 'pcprovin: ' || pcprovin || 'pcpoblac: ' || pcpoblac;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      cur            sys_refcursor;
      vquery         VARCHAR2(5000);
   BEGIN
      vnumerr :=
         pac_sin_impuestos.f_get_definiciones_reteica(pcpais, pcprovin, pcpoblac,
                                                      pac_md_common.f_get_cxtidioma(), vquery);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      cur := f_opencursor(vquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           vnumerr, SQLCODE, SQLERRM);

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
/*************************************************************************
         Elimina el calculo del impuesto
         param out mensajes : mesajes de error
         return             : number
*************************************************************************/
      vobjectname    VARCHAR2(500) := 'pac_md_sin_impuestos.f_set_valores_reteica';
      vparam         VARCHAR2(500)
         := 'pcpais=' || pcpais || ' pcprovin=' || pcprovin || ' pcprovin=' || pcprovin
            || ' pcpoblac=' || pcpoblac || ' pfdesde=' || pfdesde || ' pvalores_reteica='
            || pvalores_reteica;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_sin_impuestos.f_set_valores_reteica(pcpais, pcprovin, pcpoblac, pfdesde,
                                                         pvalores_reteica);
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_set_valores_reteica;
END pac_md_sin_impuestos;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_SIN_IMPUESTOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_SIN_IMPUESTOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_SIN_IMPUESTOS" TO "PROGRAMADORESCSI";
