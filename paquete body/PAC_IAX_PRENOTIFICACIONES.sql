--------------------------------------------------------
--  DDL for Package Body PAC_IAX_PRENOTIFICACIONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_PRENOTIFICACIONES" AS
/******************************************************************************
   NOMBRE:       PAC_IAX_PRENOTIFICACIONES
   PROPÓSITO:  Mantenimiento domiciliaciones.
   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        18/11/2011   JMF                1. 0020000: LCOL_A001-Prenotificaciones
 ******************************************************************************/
   FUNCTION f_domiciliar(
      psproces IN NUMBER,
      pcempres IN NUMBER,
      pfefecto IN DATE,
      pffeccob IN DATE,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      psprodom IN NUMBER,
      pccobban IN NUMBER,
      pcbanco IN NUMBER,
      pctipcta IN NUMBER,
      pfvtotar IN VARCHAR2,
      pcreferen IN VARCHAR2,
      pdfefecto IN DATE,
      sproces OUT NUMBER,
      nommap1 OUT VARCHAR2,
      nommap2 OUT VARCHAR2,
      nomdr OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER;
      vnok           NUMBER;
      vnko           NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pcempres=' || pcempres || ' psproces=' || psproces || ' psproduc=' || psproduc
            || ' pccobban=' || pccobban;
      vobject        VARCHAR2(200) := 'PAC_IAX_PRENOTIFICACIONES.F_DOMICILIAR';
   BEGIN
      mensajes := t_iax_mensajes();
      vnumerr := pac_md_prenotificaciones.f_domiciliar(psproces, pcempres, pfefecto, pffeccob,
                                                       pcramo, psproduc, psprodom, pccobban,
                                                       pcbanco, pctipcta, pfvtotar, pcreferen,
                                                       pdfefecto, vnok, vnko, sproces,
                                                       nommap1, nommap2, nomdr, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      --Se debe realizar el control de errores mediante  el PAC_IOBJ_MENSAJES.P_TRATARMENSAJE.
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 1;
   END f_domiciliar;

   FUNCTION f_get_domiciliacion(
      psproces IN NUMBER,
      pcempres IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pfefecto IN DATE,
      psprodom IN NUMBER,
      mensajes OUT t_iax_mensajes,
      pccobban IN NUMBER DEFAULT NULL,
      pcbanco IN NUMBER DEFAULT NULL,
      pctipcta IN NUMBER DEFAULT NULL,
      pfvtotar IN VARCHAR2 DEFAULT NULL,
      pcreferen IN VARCHAR2 DEFAULT NULL,
      pdfefecto IN DATE DEFAULT NULL)
      RETURN sys_refcursor IS
      vnumerr        NUMBER(8) := 0;
      vrefcursor     sys_refcursor;
   BEGIN
      mensajes := t_iax_mensajes();
      --LLAMADA A LA FUNCIÓN
      vrefcursor := pac_md_prenotificaciones.f_get_domiciliacion(psproces, pcempres, pcramo,
                                                                 psproduc, pfefecto, psprodom,
                                                                 pccobban, pcbanco, pctipcta,
                                                                 pfvtotar, pcreferen,
                                                                 pdfefecto, mensajes);
      RETURN vrefcursor;

      IF vrefcursor%ISOPEN THEN
         CLOSE vrefcursor;
      END IF;
   END f_get_domiciliacion;

   /*******************************************************************************
   FUNCION F_SET_PRODDOMIS
   Función que inserta los productos seleccionados para realizar la domiciliación en el proceso.
    Parámetros:
     Entrada :
       Pcempres   NUMBER : Identificador empresa
       Psproces   NUMBER : Id. proceso
       Psproduc   NUMBER : Id. producto
       Pseleccio  NUMBER : Valor seleccionado
     Salida :
       Mensajes   T_IAX_MENSAJES
   Retorna: un NUMBER con el id de error.
   ********************************************************************************/
   FUNCTION f_set_proddomis(
      pcempres IN NUMBER,
      psproces IN NUMBER,
      psproduc IN NUMBER,
      pseleccio IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pcempres=' || pcempres || ' psproces=' || psproces || ' psproduc=' || psproduc
            || ' pseleccio=' || pseleccio;
      vobject        VARCHAR2(200) := 'PAC_IAX_PRENOTIFICACIONES.F_SET_PRODDOMIS';
      vnumerr        NUMBER;
   BEGIN
      IF pcempres IS NULL
         OR psproces IS NULL
         OR psproduc IS NULL
         OR pseleccio IS NULL THEN
         RAISE e_param_error;
      END IF;

      /* Deberá realizar una llamada a la función de la capa md pac_md_domiciliaciones.f_set_prodDomis que insertará en la tabla de productos a pasar
       domiciliación tmp_domisaux.
      */
      vnumerr := pac_md_prenotificaciones.f_set_proddomis(pcempres, psproces, psproduc,
                                                          pseleccio, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      --Se debe realizar el control de errores mediante  el PAC_IOBJ_MENSAJES.P_TRATARMENSAJE.
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 1;
   END f_set_proddomis;

/*******************************************************************************
   FUNCION F_GET_PROCESO
   Función que recupera id. proceso que agrupa de los productos a domiciliar
    Parámetros:
     Entrada :
     Salida :
       psproces   NUMBER
       Mensajes   T_IAX_MENSAJES
   Retorna: un NUMBER con el código de error.
   ********************************************************************************/
   FUNCTION f_get_proceso(psproces OUT NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_PRENOTIFICACIONES.F_GET_PROCESO';
      vnumerr        NUMBER := 0;
   BEGIN
      vnumerr := pac_md_common.f_get_procesodom(psproces, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      --Retorna :  un NUMBER.
      RETURN vnumerr;
   EXCEPTION
      --Se debe realizar el control de errores mediante  el PAC_IOBJ_MENSAJES.P_TRATARMENSAJE.
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
   END f_get_proceso;

   FUNCTION f_domrecibos(
      pcempres IN NUMBER,
      psproces IN NUMBER,
      pruta OUT VARCHAR2,
      pfcobro IN DATE DEFAULT NULL,
      vtimp OUT t_iax_impresion,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vobj           VARCHAR2(900) := 'PAC_IAX_PRENOTIFICACIONES.F_DOMRECIBOS';
      vpar           VARCHAR2(900)
         := NULL || ' pcempres=' || pcempres || ' psproces=' || psproces || ' pruta=' || pruta
            || ' pfcobro=' || pfcobro;
      vnumerr        NUMBER;
   BEGIN
      vnumerr := pac_md_prenotificaciones.f_domrecibos(pcempres, psproces, pruta, pfcobro,
                                                       vtimp, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      --Se debe realizar el control de errores mediante  el PAC_IOBJ_MENSAJES.P_TRATARMENSAJE.
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000006, vpasexec, vpar);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000005, vpasexec, vpar);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000001, vpasexec, vpar,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_domrecibos;
END pac_iax_prenotificaciones;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_PRENOTIFICACIONES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_PRENOTIFICACIONES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_PRENOTIFICACIONES" TO "PROGRAMADORESCSI";
