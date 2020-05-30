--------------------------------------------------------
--  DDL for Package Body PAC_IAX_RENTAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_RENTAS" AS
/******************************************************************************
   NOMBRE:       PAC_IAX_RENTAS
   PROPÓSITO: Nuevo paquete de la capa IAX que tendrá las funciones para la gestión de pagos renta.
              Controlar todos posibles errores con PAC_IOBJ_MNSAJES.P_TRATARMENSAJE


   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        16/06/2009   JGM                1. Creación del package.
   2.0        16/06/2009   JGM                1. Actualización Generacion Rentas
   3.0        11/02/2010   AMC                3. 0011392: CRE - Añadir a la consulta de pólizas las rentas.
   4.0        20/04/2010   ICV                4. 0012914: CEM - Reimprimir listados de pagos de rentas
   5.0        15/03/2010   JTS                5. 0013477 ENSA101 - Nueva pantalla de Gestión Pagos Rentas

******************************************************************************/

   /*F_get_ProdRentas
   Nueva función de la capa IAX que devolverá los productos parametrizados con prestación rentas

   Parámetros

   1. pcempres IN NUMBER
   2. pcramo IN NUMBER
   3. psproduc IN NUMBER
   4. mensajes OUT T_IAX_MENSAJES

   */
   FUNCTION f_get_prodrentas(
      pcempres IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      t_ren          sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pcempres=' || pcempres;
      vobject        VARCHAR2(200) := 'PAC_IAX_RENTAS.F_get_ProdRentas';
   BEGIN
      IF pcempres IS NULL THEN
         RAISE e_param_error;
      END IF;

      t_ren := pac_md_rentas.f_get_prodrentas(pcempres, pcramo, psproduc, mensajes);
      RETURN t_ren;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN t_ren;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN t_ren;
   END f_get_prodrentas;

/*
F_SetObjetoProdRenta:
Nueva función de la capa IAX que se encargará de insertar los productos seleccionados de los que se quiere generar pagos renta.

1. psproduc IN NUMBER
2. pcselecc IN NUMBER
3. mensajes OUT T_IAX_MENSAJES

*/
   FUNCTION f_setobjetoprodrenta(
      psproduc IN NUMBER,
      pcselecc IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_retorn       NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psproduc=' || psproduc || ' pcselec=' || pcselecc;
      vobject        VARCHAR2(200) := 'PAC_IAX_RENTAS.F_SetObjetoProdRenta';
   BEGIN
      IF psproduc IS NULL
         OR pcselecc IS NULL THEN
         RAISE e_param_error;
      END IF;

      v_retorn := pac_md_rentas.f_setobjetoprodrenta(psproduc, pcselecc, mensajes);
      RETURN v_retorn;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN -1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN -1;
   END f_setobjetoprodrenta;

/*_set_Rentas
Nueva función de la capa IAX que se encargará de generar los pagos renta.

1. pempresa IN NUMBER
2. pfecha IN DATE
3. pctipo IN NUMBER
4. mensajes OUT T_IAX_MENSAJES

*/
   FUNCTION f_set_rentas(
      pcempres IN NUMBER,
      pfecha IN DATE,
      pctipo IN NUMBER,
      psproces IN NUMBER,   --Bug.: 12914 - ICV - 03/05/2010
      nommap1 OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      n_ren          NUMBER(2) := 1;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pcempres=' || pcempres || ' pfecha=' || TO_CHAR(pfecha, 'DD/MM/YYYY')
            || ' pctipo=' || TO_CHAR(pctipo);
      vobject        VARCHAR2(200) := 'PAC_IAX_RENTAS.F_set_RENTAS';
      v_error        NUMBER(1) := 0;
   BEGIN
      --Ini Bug.: 12914 - ICV - 03/05/2010
      IF psproces IS NULL
         AND pcempres IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9901148);
         RETURN -1;
      END IF;

      /*IF pcempres IS NULL
         OR pctipo IS NULL
         OR pfecha IS NULL THEN
         RAISE e_param_error;
      END IF;*/
      n_ren := pac_md_rentas.f_set_rentas(pcempres, pfecha, pctipo, psproces, nommap1,
                                          mensajes);

      --Fin Bug.: 12914
      IF n_ren = 0 THEN
         COMMIT;
      END IF;

      RETURN n_ren;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN -1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN -1;
   END f_set_rentas;

/*-- BUG 0007352 -  05/02/2009 - jgarciam (JGM)
Función para ejecutar on-line un cierre programado o un previo.*/

   /*************************************************************************
     Nueva función que seleccionará información sobre los pagos renta dependiendo de los parámetros de entrada.
     param in pcempres  :Codigo de empresa
     param in pcramo    :Codigo de ramo
     param in psproduc  :Codigo de producto
     param in pnpoliza  :Codigo de poliza
     param in pncertif  :Codigo de certificado
     param out    mensajes OUT T_IAX_MENSAJES
     Retorno Sys_Refcursor

     Bug 11392  11/02/2010  AMC
   *************************************************************************/
   FUNCTION f_get_consultapagos(
      pcempres IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      t_pag          sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pcempres=' || pcempres || ' pcramo=' || pcramo || ' psproduc=' || psproduc
            || ' pnpoliza=' || pnpoliza || ' pncertif=' || pncertif;
      vobject        VARCHAR2(200) := 'PAC_IAX_RENTAS.F_get_ConsultaPagos';
   BEGIN
      IF pcempres IS NULL THEN
         RAISE e_param_error;
      END IF;

      t_pag := pac_md_rentas.f_get_consultapagos(pcempres, pcramo, psproduc, pnpoliza,
                                                 pncertif, mensajes);
      RETURN t_pag;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           SQLCODE, SQLERRM);
         RETURN NULL;
   END f_get_consultapagos;

   /*************************************************************************
    función que recuperará la edad de un asegurado.

    param in  psseguro IN Codigo del seguro
    param in  pnriesgo IN Codigo del riesgo
    param in  pedadaseg OUT Edad del asegurado
    param out mensajes OUT T_IAX_MENSAJES

    Retorno :  0 --> Ok
               1 --> Error

    Bug 11392  11/02/2010  AMC
   *************************************************************************/
   FUNCTION f_edadaseg(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pedadaseg OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psseguro=' || psseguro || ' pnriesgo=' || pnriesgo;
      vobject        VARCHAR2(200) := 'PAC_IAX_RENTAS.F_edadaseg';
      vresult        NUMBER;
   BEGIN
      IF psseguro IS NULL
         OR pnriesgo IS NULL THEN
         RAISE e_param_error;
      END IF;

      vresult := pac_md_rentas.f_edadaseg(psseguro, pnriesgo, pedadaseg, mensajes);
      RETURN vresult;
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
   END f_edadaseg;

   /*************************************************************************
    función que recuperará los datos de renta de una póliza.

    param in  psseguro IN Codigo del seguro
    param out mensajes OUT T_IAX_MENSAJES

    Retorno :  sys_refcursor

    Bug 11392  11/02/2010  AMC
   *************************************************************************/
   FUNCTION f_get_dat_renta(psseguro IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psseguro=' || psseguro;
      vobject        VARCHAR2(200) := 'PAC_IAX_RENTAS.F_get_dat_renta';
      vresult        sys_refcursor;
   BEGIN
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      vresult := pac_md_rentas.f_get_dat_renta(psseguro, mensajes);
      RETURN vresult;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           SQLCODE, SQLERRM);
         RETURN NULL;
   END f_get_dat_renta;

   /*************************************************************************
    función que recuperará los pagos renta de una póliza.

    param in  psseguro IN Codigo del seguro
    param out mensajes OUT T_IAX_MENSAJES

    Retorno :  sys_refcursor

    Bug 11392  11/02/2010  AMC
   *************************************************************************/
   FUNCTION f_get_pagos_renta(psseguro IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psseguro=' || psseguro;
      vobject        VARCHAR2(200) := 'PAC_IAX_RENTAS.f_get_pagos_renta';
      vresult        sys_refcursor;
   BEGIN
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      vresult := pac_md_rentas.f_get_pagos_renta(psseguro, mensajes);
      RETURN vresult;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           SQLCODE, SQLERRM);
         RETURN NULL;
   END f_get_pagos_renta;

   /*************************************************************************
    función que recuperará el detalle del pago renta de una póliza.

    param in  psseguro IN Codigo del seguro
    param in  psrecren IN
    param out mensajes OUT T_IAX_MENSAJES

    Retorno :  sys_refcursor

    Bug 11392  11/02/2010  AMC
   *************************************************************************/
   FUNCTION f_get_detpago_renta(
      psseguro IN NUMBER,
      psrecren IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psseguro=' || psseguro || ' psrecren=' || psrecren;
      vobject        VARCHAR2(200) := 'PAC_IAX_RENTAS.F_get_detpago_renta';
      vresult        sys_refcursor;
   BEGIN
      IF psseguro IS NULL
         OR psrecren IS NULL THEN
         RAISE e_param_error;
      END IF;

      vresult := pac_md_rentas.f_get_detpago_renta(psseguro, psrecren, mensajes);
      RETURN vresult;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           SQLCODE, SQLERRM);
         RETURN NULL;
   END f_get_detpago_renta;

   /*************************************************************************
    función que recuperará los datos de renta de un pago renta

    param in  psrecren IN
    param out mensajes OUT T_IAX_MENSAJES

    Retorno :  sys_refcursor

    Bug 11392  11/02/2010  AMC
   *************************************************************************/
   FUNCTION f_get_dat_polren(psrecren IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psrecren=' || psrecren;
      vobject        VARCHAR2(200) := 'PAC_IAX_RENTAS.F_get_dat_polren';
      vresult        sys_refcursor;
   BEGIN
      IF psrecren IS NULL THEN
         RAISE e_param_error;
      END IF;

      vresult := pac_md_rentas.f_get_dat_polren(psrecren, mensajes);
      RETURN vresult;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           SQLCODE, SQLERRM);
         RETURN NULL;
   END f_get_dat_polren;

   /*************************************************************************
    función que recuperará los movimientos del recibo de un pago renta.

    param in  psrecren IN
    param out mensajes OUT T_IAX_MENSAJES

    Retorno :  sys_refcursor

    Bug 11392  11/02/2010  AMC
   *************************************************************************/
   FUNCTION f_get_mov_recren(psrecren IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psrecren=' || psrecren;
      vobject        VARCHAR2(200) := 'PAC_IAX_RENTAS.F_get_mov_recren';
      vresult        sys_refcursor;
   BEGIN
      IF psrecren IS NULL THEN
         RAISE e_param_error;
      END IF;

      vresult := pac_md_rentas.f_get_mov_recren(psrecren, mensajes);
      RETURN vresult;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           SQLCODE, SQLERRM);
         RETURN NULL;
   END f_get_mov_recren;

   /*************************************************************************
    Funció F_CALC_RENTAS

    param in psrecren
    param in psseguro
    param in pctipcalc -- 0-Real o 1-Previo Ins tmp. o 2-Recalcula 3-Previo
    param in pctipban
    param out mensajes OUT T_IAX_MENSAJES
    Retorno :  number

    --BUG 13477 - JTS - 15/03/2010
   *************************************************************************/
   FUNCTION f_calc_rentas(
      psrecren IN NUMBER,
      psseguro IN NUMBER,
      pctipcalc IN NUMBER,
      pctipban IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(2) := 1;
      vparam         VARCHAR2(200)
         := 'psrecren=' || psrecren || ' psseguro=' || psseguro || ' pctipcalc=' || pctipcalc
            || ' pctipban=' || pctipban;
      vobject        VARCHAR2(200) := 'PAC_IAX_RENTAS.F_calc_rentas';
      vresult        NUMBER;
   BEGIN
      IF psrecren IS NULL
         OR psseguro IS NULL
         OR pctipcalc IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vresult := pac_md_rentas.f_calc_rentas(psrecren, psseguro, pctipcalc, pctipban, mensajes);
      vpasexec := 3;

      IF vresult = 0 THEN
         COMMIT;
      ELSE
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, vresult, vpasexec, vparam);
         RETURN 1;
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
                                           SQLCODE, SQLERRM);
         RETURN 1;
   END f_calc_rentas;

   /*************************************************************************
    Funció F_ACT_PAGO

    param in psrecren
    param in pibase
    param in ppretenc
    param in pisinret
    param in piretenc
    param in piconret
    param in pctipban
    param in pnctacor
    param out mensajes OUT T_IAX_MENSAJES
    Retorno :  number

    --BUG 13477 - JTS - 15/03/2010
   *************************************************************************/
   FUNCTION f_act_pago(
      psrecren IN NUMBER,
      pibase IN NUMBER,
      ppretenc IN NUMBER,
      pisinret IN NUMBER,
      piretenc IN NUMBER,
      piconret IN NUMBER,
      pctipban IN NUMBER,
      pnctacor IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(2) := 1;
      vparam         VARCHAR2(200)
         := 'psrecren=' || psrecren || ' pibase=' || pibase || ' ppretenc=' || ppretenc
            || ' pisinret=' || pisinret || ' piretenc=' || piretenc || ' piconret='
            || piconret || ' pctipban=' || pctipban || ' pnctacor=' || pnctacor;
      vobject        VARCHAR2(200) := 'PAC_IAX_RENTAS.F_act_pago';
      vresult        NUMBER;
   BEGIN
      IF psrecren IS NULL
         OR pibase IS NULL
         OR ppretenc IS NULL
         OR pisinret IS NULL
         OR piretenc IS NULL
         OR piconret IS NULL
         OR pctipban IS NULL
         OR pnctacor IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vresult := pac_md_rentas.f_act_pago(psrecren, pibase, ppretenc, pisinret, piretenc,
                                          piconret, pctipban, pnctacor, mensajes);
      vpasexec := 3;

      IF vresult != 0 THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, vresult, vpasexec, vparam);
         RETURN 1;
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
                                           SQLCODE, SQLERRM);
         RETURN 1;
   END f_act_pago;

   /*************************************************************************
    Funció f_get_consultapagosrenta

    param in pcempres
    param in psproduc
    param in pnpoliza
    param in pncertif
    param in pcestado
    param out otpagorenta
    param out mensajes OUT T_IAX_MENSAJES
    Retorno :  number

    --BUG 13477 - JTS - 15/03/2010
   *************************************************************************/
   FUNCTION f_get_consultapagosrenta(
      pcempres IN NUMBER,
      psproduc IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pcestado IN NUMBER,
      otpagorenta OUT t_iax_pagorenta,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(2) := 1;
      vparam         VARCHAR2(200)
         := 'pcempres=' || pcempres || ' psproduc=' || psproduc || ' pnpoliza=' || pnpoliza
            || ' pncertif=' || pncertif || ' pcestado=' || pcestado;
      vobject        VARCHAR2(200) := 'PAC_IAX_RENTAS.f_get_consultapagosrenta';
      vnumerr        NUMBER;
   BEGIN
      IF pcempres IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vnumerr := pac_md_rentas.f_get_consultapagosrenta(pcempres, psproduc, pnpoliza, pncertif,
                                                        pcestado, otpagorenta, mensajes);
      vpasexec := 3;

      IF vnumerr != 0 THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, vnumerr, vpasexec, vparam);
         RETURN 1;
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
                                           SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_consultapagosrenta;

   /*************************************************************************
    Funció f_get_cab_renta

    param in psrecren
    param out oocabrenta
    param out mensajes OUT T_IAX_MENSAJES
    Retorno :  number

    --BUG 13477 - JTS - 15/03/2010
   *************************************************************************/
   FUNCTION f_get_cab_renta(
      psrecren IN NUMBER,
      oocabrenta OUT ob_iax_cabrenta,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(2) := 1;
      vparam         VARCHAR2(200) := 'psrecren=' || psrecren;
      vobject        VARCHAR2(200) := 'PAC_MD_RENTAS.f_get_cab_renta';
      vnumerr        NUMBER;
   BEGIN
      IF psrecren IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vnumerr := pac_md_rentas.f_get_cab_renta(psrecren, oocabrenta, mensajes);
      vpasexec := 3;

      IF vnumerr != 0 THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, vnumerr, vpasexec, vparam);
         RETURN 1;
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
                                           SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_cab_renta;

   /*************************************************************************
    Funció f_get_pagorenta

    param in psrecren
    param out oopagorenta
    param out mensajes OUT T_IAX_MENSAJES
    Retorno :  number

    --BUG 13477 - JTS - 15/03/2010
   *************************************************************************/
   FUNCTION f_get_pagorenta(
      psrecren IN NUMBER,
      oopagorenta OUT ob_iax_pagorenta,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(2) := 1;
      vparam         VARCHAR2(200) := 'psrecren=' || psrecren;
      vobject        VARCHAR2(200) := 'PAC_IAX_RENTAS.f_get_pagorenta';
      vnumerr        NUMBER;
   BEGIN
      IF psrecren IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vnumerr := pac_md_rentas.f_get_pagorenta(psrecren, oopagorenta, mensajes);
      vpasexec := 3;

      IF vnumerr != 0 THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, vnumerr, vpasexec, vparam);
         RETURN 1;
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
                                           SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_pagorenta;

   /*************************************************************************
    Funció f_act_pagorenta

    param in psrecren
    param in pctipban
    param in pcuenta
    param in pbase
    param in pporcentaje
    param in pbruto
    param in pretencion
    param in pneto
    param in pestpag
    param in pfechamov
    param out mensajes OUT T_IAX_MENSAJES
    Retorno :  number

    --BUG 13477 - JTS - 15/03/2010
   *************************************************************************/
   FUNCTION f_act_pagorenta(
      psrecren IN NUMBER,
      pctipban IN NUMBER,
      pcuenta IN VARCHAR2,
      pbase IN NUMBER,
      pporcentaje IN NUMBER,
      pbruto IN NUMBER,
      pretencion IN NUMBER,
      pneto IN NUMBER,
      pestpag IN NUMBER,
      pfechamov IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(2) := 1;
      vparam         VARCHAR2(500)
         := 'psrecren=' || psrecren || 'pctipban=' || pctipban || ' pcuenta=' || pcuenta
            || ' pbase=' || pbase || ' pporcentaje=' || pporcentaje || ' pbruto=' || pbruto
            || 'ppretencion=' || pretencion || ' pneto=' || pneto || ' pestpag=' || pestpag
            || ' pfechamov=' || pfechamov;
      vobject        VARCHAR2(200) := 'PAC_IAX_RENTAS.f_act_pagorenta';
      vnumerr        NUMBER := 0;
   BEGIN
      IF psrecren IS NULL
         OR(pctipban IS NULL
            AND pcuenta IS NULL
            AND pbase IS NULL
            AND pporcentaje IS NULL
            AND pbruto IS NULL
            AND pretencion IS NULL
            AND pneto IS NULL)
         OR(pfechamov IS NOT NULL
            AND pestpag IS NULL) THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vnumerr := pac_md_rentas.f_act_pagorenta(psrecren, pctipban, pcuenta, pbase, pporcentaje,
                                               pbruto, pretencion, pneto, pestpag, pfechamov,
                                               mensajes);
      vpasexec := 3;

      IF vnumerr = 0 THEN
         COMMIT;
      ELSE
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, vnumerr, vpasexec, vparam);
         RETURN 1;
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
                                           SQLCODE, SQLERRM);
         RETURN 1;
   END f_act_pagorenta;

   /*************************************************************************
    Funció f_bloq_proxpagos

    param in psseguro
    param out mensajes OUT T_IAX_MENSAJES
    Retorno :  number

    --BUG 13477 - JTS - 15/03/2010
   *************************************************************************/
   FUNCTION f_bloq_proxpagos(psseguro IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(2) := 1;
      vparam         VARCHAR2(50) := 'psseguro=' || psseguro;
      vobject        VARCHAR2(200) := 'PAC_IAX_RENTAS.f_act_pagorenta';
      vnumerr        NUMBER := 0;
   BEGIN
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vnumerr := pac_md_rentas.f_bloq_proxpagos(psseguro, mensajes);
      vpasexec := 3;

      IF vnumerr = 0 THEN
         COMMIT;
      ELSE
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, vnumerr, vpasexec, vparam);
         RETURN 1;
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
                                           SQLCODE, SQLERRM);
         RETURN 1;
   END f_bloq_proxpagos;

   /*************************************************************************
    Funció f_bloq_proxpagos

    param pfecha -- Fecha en que se ha informado la muerte
    param in psseguro -- Clave del Seguro
    param in psrecren --Por si se quiere precisar a un recibo
    param out mensajes OUT T_IAX_MENSAJES
    Retorno :  number

    --BUG 13477 - JTS - 15/03/2010
   *************************************************************************/
   FUNCTION f_anula_rec(
      pfecha IN DATE,   -- Fecha en que se ha informado la muerte
      pseguro IN NUMBER,   -- Clave del Seguro
      psrecren IN NUMBER DEFAULT NULL,   --Por si se quiere precisar a un recibo
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(2) := 1;
      vparam         VARCHAR2(50)
                  := 'pfecha=' || pfecha || ' pseguro=' || pseguro || ' psrecren=' || psrecren;
      vobject        VARCHAR2(200) := 'PAC_IAX_RENTAS.f_anula_rec';
      vnumerr        NUMBER := 0;
   BEGIN
      IF pseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vnumerr := pac_md_rentas.f_anula_rec(pfecha, pseguro, psrecren, mensajes);
      vpasexec := 3;

      IF vnumerr != 0 THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, vnumerr, vpasexec, vparam);
         RETURN 1;
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
                                           SQLCODE, SQLERRM);
         RETURN 1;
   END f_anula_rec;

   /*************************************************************************
    Funció f_actualiza_tipocalcul

    param in psseguro
    param in ptipocalcul
    param out mensajes OUT T_IAX_MENSAJES
    Retorno :  number

   *************************************************************************/
   FUNCTION f_actualiza_tipocalcul(
      psseguro IN NUMBER,
      ptipocalcul IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(2) := 1;
      vparam         VARCHAR2(50) := 'psseguro=' || psseguro || ' ptipocalcul=' || ptipocalcul;
      vobject        VARCHAR2(200) := 'PAC_IAX_RENTAS.f_actualiza_tipocalcul';
      vnumerr        NUMBER := 0;
   BEGIN
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vnumerr := pac_md_rentas.f_actualiza_tipocalcul(psseguro, NVL(ptipocalcul,1), mensajes);
      vpasexec := 3;

      IF vnumerr != 0 THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, vnumerr, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           SQLCODE, SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_actualiza_tipocalcul;
END pac_iax_rentas;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_RENTAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_RENTAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_RENTAS" TO "PROGRAMADORESCSI";
