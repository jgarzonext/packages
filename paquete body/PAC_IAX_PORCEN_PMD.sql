--------------------------------------------------------
--  DDL for Package Body PAC_IAX_PORCEN_PMD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_PORCEN_PMD" AS
      /******************************************************************************
        NOMBRE:       PAC_IAX_PORCEN_PMD
        COMPANIAS
      PROP脫SITO: Funciones para gestionar PMD

      REVISIONES:
      Ver        Fecha        Autor       Descripci贸n
      ---------  ----------  ---------  ------------------------------------
      1.0        11/03/2014  AGG        1. Creaci贸n del package.
   ******************************************************************************/

   /*************************************************************************
      Nueva funci贸n que se encarga de borrar un registro de ctto_tramo_producto
      return              : 0 Ok. 1 Error
     *************************************************************************/
   FUNCTION f_del_ctto_tramo_producto(
      pid IN ctto_tramo_producto.ID%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_result       NUMBER := 1;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'par醡etros - pid = ' || pid;
      vobject        VARCHAR2(200) := 'PAC_IAX_PORCEN_PMD.f_del_ctto_tramo_producto';
      v_fich         VARCHAR2(400);
      vnumerr        NUMBER := 0;
   BEGIN
      IF pid IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_porcen_pmd.f_del_ctto_tramo_producto(pid, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN -1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN -1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN -1;
   END f_del_ctto_tramo_producto;

   /*************************************************************************
      Nueva funci贸n que se encarga de borrar un registro de porcen_tramo_ctto
      return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_del_porcen_tramo_ctto(
      pidcabecera IN porcen_tramo_ctto.idcabecera%TYPE,
      pid IN porcen_tramo_ctto.ID%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_result       NUMBER := 1;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
                           := 'par醡etros - pid = ' || pid || ' pidcabecera = ' || pidcabecera;
      vobject        VARCHAR2(200) := 'PAC_IAX_PORCEN_PMD.f_del_porcen_tramo_ctto';
      v_fich         VARCHAR2(400);
      vnumerr        NUMBER := 0;
   BEGIN
      IF pid IS NULL
         AND pidcabecera IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_porcen_pmd.f_del_porcen_tramo_ctto(pidcabecera, pid, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN -1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN -1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN -1;
   END f_del_porcen_tramo_ctto;

   /*************************************************************************
    Nueva funci贸n que se encarga de insertar un registro de ctto_tramo_producto
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_set_ctto_tramo_producto(
      pscontra IN ctto_tramo_producto.scontra%TYPE,
      pnversio IN ctto_tramo_producto.nversio%TYPE,
      pctramo IN ctto_tramo_producto.ctramo%TYPE,
      pcramo IN ctto_tramo_producto.cramo%TYPE,
      psproduc IN ctto_tramo_producto.sproduc%TYPE,
      pctto_tramo_producto_new OUT ctto_tramo_producto.ID%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_result       NUMBER(1) := 1;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'par醡etros - pscontra:' || pscontra || ' pnversio: ' || pnversio || ' pctramo: '
            || pctramo || ' pcramo: ' || pcramo || ' psproduc: ' || psproduc;
      vobject        VARCHAR2(200) := 'pac_iax_porcen_pmd.f_set_ctto_tramo_producto';
      v_nerror       NUMBER;
      v_host         VARCHAR2(10);
      vcterminal     usuarios.cterminal%TYPE;
      vsinterf       NUMBER;
      vterror        VARCHAR(2000);
      vid            NUMBER;
      vcid           ctto_tramo_producto.ID%TYPE;
      vnumerr        NUMBER := 0;
   BEGIN
      vnumerr := pac_md_porcen_pmd.f_set_ctto_tramo_producto(vcid, pscontra, pnversio,
                                                             pctramo, pcramo, psproduc,
                                                             mensajes);
      COMMIT;
      pctto_tramo_producto_new := vcid;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN -1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN -1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN -1;
   END f_set_ctto_tramo_producto;

   /*************************************************************************
    Nueva funci贸n que se encarga de recuperar un registro de la tabla ctto_tramo_producto
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_get_ctto_tramo_producto(
      pid IN ctto_tramo_producto.ID%TYPE,
      pscontra IN ctto_tramo_producto.scontra%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN ob_iax_ctto_tramo_producto IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'par醡etros - pid = ' || pid;
      vobject        VARCHAR2(200) := 'PAC_IAX_PORCEN_TRAMO_CTTO.f_get_ctto_tramo_producto';
      v_result       ob_iax_ctto_tramo_producto;
   BEGIN
      v_result := pac_md_porcen_pmd.f_get_ctto_tramo_producto(pid, pscontra, mensajes);
      RETURN v_result;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN v_result;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN v_result;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN v_result;
   END f_get_ctto_tramo_producto;

   /*************************************************************************
     Nueva funci贸n que se encarga de recuperar los registros de ctto_tramo_producto
     return              : 0 Ok. 1 Error
    *************************************************************************/
   FUNCTION f_get_cttostramosproductos(
      pscontra IN ctto_tramo_producto.scontra%TYPE,
      pnversio IN NUMBER,
      pnramo IN NUMBER,
      pntramo IN NUMBER,
      pnproduc IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_ctto_tramo_producto IS
      vtcttotramoproducto t_iax_ctto_tramo_producto := t_iax_ctto_tramo_producto();
      vobcttotramoproducto ob_iax_ctto_tramo_producto := ob_iax_ctto_tramo_producto();
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_PORCEN_PMD.f_get_cttostramosproductos';
      v_result       t_iax_ctto_tramo_producto;
   BEGIN
      vpasexec := 1;
      v_result := pac_md_porcen_pmd.f_get_cttostramosproductos(pscontra, pnversio, pnramo,
                                                               pntramo, pnproduc, mensajes);
      RETURN v_result;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_cttostramosproductos;

    /*************************************************************************
    Funci髇 que se encarga de recuperar el porcentaje de la cuota
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_get_porcen_tramo_ctto(
      pidcabecera IN porcen_tramo_ctto.idcabecera%TYPE,
      pid IN porcen_tramo_ctto.ID%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN ob_iax_porcen_tramo_ctto IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
                            := 'par醡etros - pidcabecera = ' || pidcabecera || ' pid: ' || pid;
      vobject        VARCHAR2(200) := 'PAC_IAX_PORCEN_PMD.f_get_porcen_tramo_ctto';
      v_result       ob_iax_porcen_tramo_ctto := ob_iax_porcen_tramo_ctto();
   BEGIN
      vpasexec := 1;
      v_result := pac_md_porcen_pmd.f_get_porcen_tramo_ctto(pidcabecera, pid, mensajes);
      RETURN v_result;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN v_result;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN v_result;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN v_result;
   END f_get_porcen_tramo_ctto;

   /*************************************************************************
     Funci髇 que se encarga de recuperar los porcentajes de las cuotas
     return              : 0 Ok. 1 Error
    *************************************************************************/
   FUNCTION f_get_porcentajes_tramo_ctto(
      pidcabecera IN porcen_tramo_ctto.ID%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_porcen_tramo_ctto IS
      v_result       t_iax_porcen_tramo_ctto := t_iax_porcen_tramo_ctto();
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_PORCEN_PMD.f_get_porcentajes_tramos_ctto';
   BEGIN
      vpasexec := 1;
      v_result := pac_md_porcen_pmd.f_get_porcentajes_tramo_ctto(pidcabecera, mensajes);
      RETURN v_result;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_porcentajes_tramo_ctto;

   /*************************************************************************
    Funci髇 que se encarga de insertar un registro en porcen_tramo
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_set_porcen_tramo_ctto(
      pidcabecera IN porcen_tramo_ctto.idcabecera%TYPE,
      pid IN porcen_tramo_ctto.ID%TYPE,
      pporcen IN porcen_tramo_ctto.porcen%TYPE,
      pfpago IN porcen_tramo_ctto.fpago%TYPE,
      pporcen_tramo_ctto_new OUT porcen_tramo_ctto.ID%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_result       NUMBER(1) := 1;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'par醡etros - pidcabecera:' || pidcabecera || ' pid: ' || pid || ' pporcen: '
            || pporcen;
      vobject        VARCHAR2(200) := 'PAC_IAX_PORCEN_PMD.f_set_porcen_tramo_ctto';
      vcid           porcen_tramo_ctto.ID%TYPE;
      vnumerr        NUMBER := 0;
   BEGIN
      IF pidcabecera IS NULL THEN
         RAISE e_param_error;
      ELSE
         vcid := pid;
      END IF;

      vnumerr := pac_md_porcen_pmd.f_set_porcen_tramo_ctto(pidcabecera, pid, pporcen, pfpago,
                                                           0, mensajes);
      COMMIT;
      pporcen_tramo_ctto_new := vcid;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN -1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN -1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN -1;
   END f_set_porcen_tramo_ctto;

   /*************************************************************************
    Funci髇 que se encarga de copiar la configuraci髇 de un contrato a partir de
    la configuraci髇 de otro del mismo ramo
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_copiar_config_producto(
      pcramo IN ctto_tramo_producto.cramo%TYPE,
      psproduc IN ctto_tramo_producto.sproduc%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_result       NUMBER(1) := 1;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
                              := 'par醡etros - pcramo:' || pcramo || ' psproduc: ' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_IAX_PORCEN_PMD. f_copiar_config_producto';
      vnumerr        NUMBER := 0;
   BEGIN
      IF pcramo IS NULL
         OR psproduc IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_porcen_pmd.f_copiar_config_producto(pcramo, psproduc, mensajes);
      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN -1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN -1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN -1;
   END f_copiar_config_producto;

    /*************************************************************************
    Funci髇 que se encarga de copiar la configuraci髇 de un contrato a partir de
    la configuraci髇 de otro del mismo ramo
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_replicar_cuotas(
      pscontra IN ctto_tramo_producto.scontra%TYPE,
      pctramo IN ctto_tramo_producto.ctramo%TYPE,
      pcramo IN ctto_tramo_producto.cramo%TYPE,
      psproduc IN ctto_tramo_producto.sproduc%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_result       NUMBER(1) := 1;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'par醡etros - pscontra:' || pscontra || ' pctramo: ' || pctramo || ' pcramo: '
            || pcramo || ' psproduc: ' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_IAX_PORCEN_PMD.f_replicar_cuotas';
      vnumerr        NUMBER := 0;
   BEGIN
      IF pcramo IS NULL
         OR psproduc IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_porcen_pmd.f_replicar_cuotas(pscontra, pctramo, pcramo, psproduc,
                                                     mensajes);
      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN -1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN -1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN -1;
   END f_replicar_cuotas;
END pac_iax_porcen_pmd;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_PORCEN_PMD" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_PORCEN_PMD" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_PORCEN_PMD" TO "PROGRAMADORESCSI";
