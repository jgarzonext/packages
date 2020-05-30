--------------------------------------------------------
--  DDL for Package Body PAC_MD_RENTAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_RENTAS" AS
      /******************************************************************************
      NOMBRE:       PAC_MD_RENTAS
      PROPÓSITO: Nuevo paquete de la capa MD que tendrá las funciones para la gestión de pagos renta.
                 Controlar todos posibles errores con PAC_IOBJ_MNSAJES.P_TRATARMENSAJE

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        16/06/2009   JGM                1. Creación del package.
      2.0        16/06/2009   JGM                2. Actualización Generacion Rentas
      3.0        11/02/2010   AMC                3. 0011392: CRE - Añadir a la consulta de pólizas las rentas.
      4.0        20/04/2010   ICV                4. 0012914: CEM - Reimprimir listados de pagos de rentas
      5.0        15/03/2010   JTS                5. 0013477 ENSA101 - Nueva pantalla de Gestión Pagos Rentas
      6.0        09/05/2011   SRA                6. 0018494: Incidencia en la pantalla de estados de una renta
      7.0        21-10-2011   JGR                7. 0018944: LCOL_P001 - PER - Tarjetas (nota 0095276) en desarrollo AXIS3181
      8.0        08/01/2014   LPP                8. 0028409: ENSA998-ENSA - Implementación de historico de prestaciones
      /*******************************************************************************
      FUNCION  F_get_ProdRentas
      Nueva función de la capa MD que devolverá los productos parametrizados con prestación rentas.

      Parámetros:
   1. pcempres IN NUMBER
   2. pcramo IN NUMBER
   3. psproduc IN NUMBER
   4. mensajes OUT T_IAX_MENSAJES


      Retorna : REF CURSOR.
      ********************************************************************************/
   reg            vtab_prodren;

   FUNCTION f_get_prodrentas(
      pcempres IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
                := 'Pcempres=' || pcempres || ' Pcramo=' || pcramo || ' Psproduc=' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_MD_RENTAS.F_get_ProdRentas';
      vquery         VARCHAR2(5000);
      vnumerr        NUMBER := 0;
      v_result       sys_refcursor;
      vidioma        NUMBER(1);
   BEGIN
      -- Control parametros entrada
      IF pcempres IS NULL THEN
         RAISE e_param_error;
      END IF;

      vidioma := pac_md_common.f_get_cxtidioma;

      IF vidioma != 0 THEN
         --Esta  función deberá seleccionar aquellos productos que pasan cartera, para ello llamará a la función pac_dincatera.f_get_prodcartera..
         vnumerr := pk_rentas.f_get_prodrentas(pcempres, pcramo, psproduc, vidioma, vquery);

         IF vnumerr <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);   -- error interno.
            RAISE e_object_error;
         END IF;

         v_result := pac_md_listvalores.f_opencursor(vquery, mensajes);
         RETURN v_result;
      ELSE
         RETURN NULL;
      END IF;
   EXCEPTION
      --Se debe realizar el control de errores mediante  el PAC_IOBJ_MENSAJES.P_TRATARMENSAJE.
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_prodrentas;

/*
F_SetObjetoProdRenta:
Nueva función de la capa IAX que se encargará de insertar los productos seleccionados de los que se quiere generar pagos renta.

1.    psproduc IN NUMBER
2.    pcselecc IN NUMBER
3.    mensajes OUT T_MD_MENSAJES

*/
   FUNCTION f_setobjetoprodrenta(
      psproduc IN NUMBER,
      pcselecc IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'Psproduc=' || psproduc || ' Pseleccio=' || pcselecc;
      vobject        VARCHAR2(200) := 'PAC_MD_RENTAS.F_SetObjetoProdRentaA';
      vnumerr        NUMBER := 0;
      acaba          BOOLEAN := FALSE;
      v_indice       NUMBER(3) := 1;
   BEGIN
      IF psproduc IS NULL
         OR pcselecc IS NULL THEN
         RAISE e_param_error;
      END IF;

      --Este código llamará a isertar ...
      --primero lo busco
      WHILE v_indice <= reg.COUNT
       AND acaba = FALSE LOOP
         IF reg(v_indice).sproduc = psproduc THEN
            -- ya existe
            acaba := TRUE;
            reg(v_indice).cselecc := pcselecc;
         END IF;

         v_indice := v_indice + 1;
      END LOOP;

      -- ... o updatear la tabla virtual
      IF acaba = FALSE THEN
         -- no lo he encontrado y lo inserto
         DECLARE
            contador       NUMBER := reg.COUNT;
         BEGIN
            reg(contador + 1).sproduc := psproduc;
            reg(contador + 1).cselecc := pcselecc;
         END;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      --Se debe realizar el control de errores mediante  el PAC_IOBJ_MENSAJES.P_TRATARMENSAJE.
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_setobjetoprodrenta;

   FUNCTION f_set_rentas(
      pcempres IN NUMBER,
      pfecha IN DATE,
      pctipo IN NUMBER,
      psproces IN NUMBER,
      nommap1 OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pcempres=' || pcempres || ' pfecha=' || TO_CHAR(pfecha, 'DD/MM/YYYY')
            || ' pctipo=' || pctipo;
      vobject        VARCHAR2(200) := 'PAC_MD_RENTAS.F_set_Rentas';
      vnumerr        NUMBER := 0;
      acaba          BOOLEAN := FALSE;
      v_indice       NUMBER(3) := 1;
      vidioma        NUMBER(1);
      vusuari        VARCHAR2(20);
      v_secuencia    tmp_pagosrenta.stmppare%TYPE;
      v_dias_rent    NUMBER;
      vproces        NUMBER;
      vprocesini     NUMBER;
      vprocesfin     NUMBER;
      v_result       VARCHAR2(200);
      v_genera_map   BOOLEAN := FALSE;
      fecha_comparada DATE;
      v_missatge     VARCHAR2(200);
      v_dias         NUMBER(3);
      vejecutarep    NUMBER;
      --ICV
      xnerror        NUMBER := 0;
      n_error        NUMBER := 0;
      ttexto         VARCHAR2(400);
   BEGIN
      v_genera_map := FALSE;

      IF psproces IS NULL
         AND(pcempres IS NULL
             OR pfecha IS NULL
             OR pctipo IS NULL) THEN
         RAISE e_param_error;
      END IF;

      vidioma := NVL(pac_md_common.f_get_cxtidioma, 1);
      vusuari := pac_md_common.f_get_cxtusuario;

      --Bug.: 12914 - 20/04/2010 - ICV - Reimprimir listados de pagos de rentas
      IF psproces IS NOT NULL THEN
         v_genera_map := TRUE;
      ELSE
         SELECT stmppagren.NEXTVAL
           INTO v_secuencia
           FROM DUAL;

         IF pctipo = 1 THEN   --previo de pagos renta
            v_dias := 365;
            fecha_comparada := f_sysdate + v_dias;
         ELSE   -- real de pagos renta (pctipo=0)
            v_secuencia := 0;
            v_dias := NVL(pac_parametros.f_parempresa_n(pcempres, 'DIAS_POST_RENT'), 0);
            fecha_comparada := f_sysdate + v_dias;
         END IF;

         IF pfecha > fecha_comparada THEN
            v_missatge := pac_iobj_mensajes.f_get_descmensaje(109208,
                                                              pac_md_common.f_get_cxtidioma);

            IF v_dias > 0 THEN
               v_missatge :=
                  v_missatge || '+' || TO_CHAR(v_dias) || ' '
                  || pac_iobj_mensajes.f_get_descmensaje(9002204,
                                                         pac_md_common.f_get_cxtidioma);
            END IF;

            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 109208, v_missatge);   -- La fecha no puede ser superior a la actual
            RAISE e_object_error;
         END IF;

         IF pctipo = 0 THEN
            vnumerr := f_procesini(vusuari, pcempres, 'GENERENTAS',
                                   'Generación de Rentas.' || pfecha, vproces);
         ELSE
            vnumerr := f_procesini(vusuari, pcempres, 'PREVRENTAS',
                                   'Proceso Previo Rentas.' || pfecha, vproces);
         END IF;

         WHILE v_indice <= reg.COUNT LOOP
            IF reg(v_indice).cselecc = 1 THEN
               v_genera_map := TRUE;
               pk_rentas.gen_rec_rentas(pfecha, vidioma, pctipo, reg(v_indice).sproduc,
                                        vusuari, v_secuencia, pcempres, vproces, xnerror);

               IF xnerror = 1 THEN
                  n_error := 1;
               END IF;
            /*IF vprocesini IS NULL THEN
               vprocesini := vproces;
            END IF;*/
            END IF;

            v_indice := v_indice + 1;
         END LOOP;

         vnumerr := f_procesfin(vproces, n_error);
      --vprocesfin := vproces;
      END IF;

      IF v_genera_map = TRUE
                            --AND pctipo = 1 Siempre sale el map
      THEN
         v_result := pac_md_map.f_ejecuta('334',
                                          TO_CHAR(vidioma) || '|'
                                          || TO_CHAR(NVL(vproces, psproces)),
                                          vejecutarep, mensajes);
         nommap1 := v_result;

         IF psproces IS NULL THEN
            ttexto := f_axis_literales(9001242, vidioma);
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, NULL, ttexto || ' ' || vproces);
         END IF;
      ELSE
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 1000405);   -- error interno.
      END IF;

      RETURN 0;
   EXCEPTION
      --Se debe realizar el control de errores mediante  el PAC_IOBJ_MENSAJES.P_TRATARMENSAJE.
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_rentas;

   /*************************************************************************
     Nueva función que seleccionará información sobre los pagos renta dependiendo de los parámetros de entrada.
     param in pcempres IN NUMBER
     param in IN NUMBER opc
     param in psproduc IN NUMBER opc
     param in pnpoliza IN NUMBER opc
     param in pncertif IN NUMBER opc
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
      vresult        NUMBER;
      t_pag          sys_refcursor;
      pidioma        NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pcempres=' || pcempres || ' pcramo=' || pcramo || ' psproduc=' || psproduc
            || ' pnpoliza=' || pnpoliza || ' pncertif=' || pncertif;
      vobject        VARCHAR2(200) := 'PAC_MD_RENTAS.F_get_ConsultaPagos';
      psquery        VARCHAR2(2000);
   BEGIN
      IF pcempres IS NULL THEN
         RAISE e_param_error;
      END IF;

      pidioma := pac_md_common.f_get_cxtidioma;
      vresult := pk_rentas.f_get_consultapagos(pcempres, pcramo, psproduc, pnpoliza, pncertif,
                                               pidioma, psquery);

      IF vresult <> 0 THEN
         RAISE e_object_error;
      END IF;

      t_pag := pac_md_listvalores.f_opencursor(psquery, mensajes);
      vresult := pac_log.f_log_consultas(psquery, 'PAC_MD_RENTAS.F_get_ConsultaPagos', 2, 0,
                                         f_sysdate, f_user);

      IF vresult <> 0 THEN
         RAISE e_object_error;
      END IF;

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
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
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
      vobject        VARCHAR2(200) := 'PAC_MD_RENTAS.F_edadaseg';
      vresult        NUMBER;
   BEGIN
      IF psseguro IS NULL
         OR pnriesgo IS NULL THEN
         RAISE e_param_error;
      END IF;

      vresult := pk_rentas.f_edadaseg(psseguro, pnriesgo, pedadaseg);

      IF vresult <> 0 THEN
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
                                           SQLCODE, SQLERRM);
         RETURN 1;
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
      vobject        VARCHAR2(200) := 'PAC_MD_RENTAS.F_get_dat_renta';
      vresult        NUMBER;
      vidioma        NUMBER;
      psquery        VARCHAR2(2000);
      t_dat          sys_refcursor;
   BEGIN
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      vidioma := pac_md_common.f_get_cxtidioma;
      vresult := pk_rentas.f_get_dat_renta(psseguro, vidioma, psquery);

      IF vresult <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vresult);   -- error interno.
         RAISE e_object_error;
      END IF;

      t_dat := pac_md_listvalores.f_opencursor(psquery, mensajes);
      RETURN t_dat;
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
      vobject        VARCHAR2(200) := 'PAC_MD_RENTAS.f_get_pagos_renta';
      vresult        NUMBER;
      vidioma        NUMBER;
      psquery        VARCHAR2(2000);
      t_dat          sys_refcursor;
   BEGIN
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      vidioma := pac_md_common.f_get_cxtidioma;
      vresult := pk_rentas.f_get_pagos_renta(psseguro, vidioma, psquery);

      IF vresult <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vresult);   -- error interno.
         RAISE e_object_error;
      END IF;

      t_dat := pac_md_listvalores.f_opencursor(psquery, mensajes);
      RETURN t_dat;
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
      vobject        VARCHAR2(200) := 'PAC_MD_RENTAS.F_get_detpago_renta';
      vresult        NUMBER;
      vidioma        NUMBER;
      psquery        VARCHAR2(2000);
      t_dat          sys_refcursor;
   BEGIN
      IF psseguro IS NULL
         OR psrecren IS NULL THEN
         RAISE e_param_error;
      END IF;

      vidioma := pac_md_common.f_get_cxtidioma;
      vresult := pk_rentas.f_get_detpago_renta(psseguro, psrecren, vidioma, psquery);

      IF vresult <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vresult);   -- error interno.
         RAISE e_object_error;
      END IF;

      t_dat := pac_md_listvalores.f_opencursor(psquery, mensajes);
      RETURN t_dat;
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
      vobject        VARCHAR2(200) := 'PAC_MD_RENTAS.F_get_dat_polren';
      vresult        NUMBER;
      vidioma        NUMBER;
      psquery        VARCHAR2(2000);
      t_dat          sys_refcursor;
   BEGIN
      IF psrecren IS NULL THEN
         RAISE e_param_error;
      END IF;

      vidioma := pac_md_common.f_get_cxtidioma;
      vresult := pk_rentas.f_get_dat_polren(psrecren, vidioma, psquery);

      IF vresult <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vresult);   -- error interno.
         RAISE e_object_error;
      END IF;

      t_dat := pac_md_listvalores.f_opencursor(psquery, mensajes);
      RETURN t_dat;
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
      vobject        VARCHAR2(200) := 'PAC_MD_RENTAS.F_get_mov_recren';
      vresult        NUMBER;
      vidioma        NUMBER;
      psquery        VARCHAR2(2000);
      t_dat          sys_refcursor;
   BEGIN
      IF psrecren IS NULL THEN
         RAISE e_param_error;
      END IF;

      vidioma := pac_md_common.f_get_cxtidioma;
      vresult := pk_rentas.f_get_mov_recren(psrecren, vidioma, psquery);

      IF vresult <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vresult);   -- error interno.
         RAISE e_object_error;
      END IF;

      t_dat := pac_md_listvalores.f_opencursor(psquery, mensajes);
      RETURN t_dat;
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
      vobject        VARCHAR2(200) := 'PAC_MD_RENTAS.F_calc_rentas';
      vresult        NUMBER;
      vsperson1      asegurados.sperson%TYPE;
      vsperson2      asegurados.sperson%TYPE;
      vnumasseg      NUMBER;
      vsproduc       seguros.sproduc%TYPE;
      vcbancar       seguros.cbancar%TYPE;
      vibruren       seguros_ren.ibruren%TYPE;
      vf1parren      seguros_ren.f1paren%TYPE;
      vfppren        seguros_ren.fppren%TYPE;
      v_cagrprd      productos.cagrpro%TYPE;

      CURSOR cur_ass IS
         SELECT sperson, ROWNUM
           FROM asegurados
          WHERE TRUNC(f_sysdate) BETWEEN ffecini AND NVL(ffecfin, TRUNC(f_sysdate))
            AND sseguro = psseguro;
   BEGIN
      IF psrecren IS NULL
         OR psseguro IS NULL
         OR pctipcalc IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;

      FOR i IN cur_ass LOOP
         IF i.ROWNUM = 1 THEN
            vsperson1 := i.sperson;
         ELSE
            vsperson2 := i.sperson;
         END IF;

         vnumasseg := i.ROWNUM;
      END LOOP;

      vpasexec := 3;

      IF vnumasseg IS NULL THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 4;

      BEGIN
         SELECT a.sproduc, a.cbancar, b.cagrpro
           INTO vsproduc, vcbancar, v_cagrprd
           FROM seguros a, productos b
          WHERE a.sseguro = psseguro
            AND b.sproduc = a.sproduc;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RAISE e_object_error;
      END;

      IF v_cagrprd = 10 THEN
         -- Rentes
         vpasexec := 5;

         BEGIN
            SELECT ibruren, f1paren, fppren
              INTO vibruren, vf1parren, vfppren
              FROM seguros_ren
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RAISE e_object_error;
         END;

         vpasexec := 6;
         vresult := pk_rentas.calc_rentas(psrecren, psseguro, vsperson1, vsperson2, vnumasseg,
                                          vsproduc, vibruren, pctipcalc, vf1parren, vfppren,
                                          TRUNC(f_sysdate), vcbancar, 'R', pctipban);
         vpasexec := 7;

         IF vresult != 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 99011065);
            RAISE e_object_error;
         END IF;
      ELSIF v_cagrprd = 11 THEN
         -- Pla de Pensions
         DECLARE
            -- Deberia existir solo 1 prestacion activa.
            CURSOR c1 IS
               SELECT DISTINCT sr.f1paren, sr.fppren, sr.nsinies, sr.ntramit, sr.ctipdes,
                               crevali, prevali, irevali, sr.npresta
                          FROM pagosrenta pag, prestaren sr
                         WHERE pag.srecren = psrecren
                           -- Bug 18286 - APD - 26/04/2011 - union entre prestaren y pagosrenta tambien
                           -- por nsinies, ntramit y ctipdes
                           AND sr.nsinies = pag.nsinies
                           AND sr.ntramit = pag.ntramit
                           AND sr.ctipdes = pag.ctipdes
                           -- fin Bug 18286 - APD - 26/04/2011
                           AND sr.sseguro = pag.sseguro
                           AND sr.sperson = pag.sperson
                           AND sr.f1paren <= f_sysdate
                           AND((sr.ffinren IS NOT NULL
                                AND sr.ffinren > f_sysdate)
                               OR(sr.ffinren IS NULL));

            r1             c1%ROWTYPE;
         BEGIN
            OPEN c1;

            FETCH c1
             INTO r1;

            IF c1%FOUND THEN
               vresult :=
                  pk_rentas.f_calc_prestacion_pol
                     (psrecren,   -- pproceso IN NUMBER,   -- Nro. Proceso o Nro. Recibo
                      psseguro,   -- pseguros IN NUMBER,   -- SSEGURO
                      vsperson1,   -- psperson IN NUMBER,   -- SPERSON 1er. Asegurado
                      vsproduc,   -- psproduc IN NUMBER,   -- SPRODUC
                      pctipcalc,   -- prealpre IN NUMBER,   -- 0-Real o 1-Previo Ins tmp. o 2-Recalcula 3-Previo
                      r1.f1paren,   -- pf1pren IN DATE,
                      r1.fppren,   -- pfppren IN DATE,   -- Fecha Proximo pago de renta
                      TRUNC(f_sysdate),   -- pfefecto IN DATE,   -- Fecha
                      vcbancar,   -- pctabanc IN VARCHAR2,   -- Cuenta Bancaria
                      'R',   -- ptiporen IN VARCHAR2,   -- Tipo de renta
                      r1.nsinies,   -- pnsinies IN VARCHAR2,
                      pctipban,   -- pctipban IN NUMBER,
                      r1.ntramit,   -- pntramit IN NUMBER,
                      r1.ctipdes,   -- pctipdes IN NUMBER,
                      r1.crevali,   -- crevali IN NUMBER,
                      r1.prevali,   -- prevali IN NUMBER,
                      r1.irevali,   -- irevali IN NUMBER
                      r1.npresta);
            END IF;

            CLOSE c1;
         -- BUG -21546_108724- 09/02/2012 - JLTS - Cierre de posibles cursores abiertos, se adiciona EXCEPTION
         EXCEPTION
            WHEN OTHERS THEN
               IF c1%ISOPEN THEN
                  CLOSE c1;
               END IF;
         END;
      ELSE
         -- Acció no permessa per l'usuari
         RETURN 9000790;
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
      vobject        VARCHAR2(200) := 'PAC_MD_RENTAS.F_act_pago';
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
      vresult := pk_rentas.insertar_historico(psrecren);
      vpasexec := 3;

      IF vresult != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vresult);   -- error interno.
         RAISE e_object_error;
      END IF;

      vpasexec := 4;
      vresult := pk_rentas.f_act_pago(psrecren, pibase, ppretenc, pisinret, piretenc, piconret,
                                      pctipban, pnctacor);
      vpasexec := 5;

      IF vresult != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vresult);   -- error interno.
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
      otpagorenta IN OUT t_iax_pagorenta,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(2) := 1;
      vparam         VARCHAR2(200)
         := 'pcempres=' || pcempres || ' psproduc=' || psproduc || ' pnpoliza=' || pnpoliza
            || ' pncertif=' || pncertif || ' pcestado=' || pcestado;
      vobject        VARCHAR2(200) := 'PAC_MD_RENTAS.f_get_consultapagosrenta';
      vsquery        VARCHAR2(2500);
      vcur           sys_refcursor;
      vnumerr        NUMBER;

      TYPE reg_resultado IS RECORD(
         srecren        pagosrenta.srecren%TYPE,
         sseguro        seguros.sseguro%TYPE,
         sperson        tomadores.sperson%TYPE,
         ffecefe        pagosrenta.ffecefe%TYPE,
         ffecpag        pagosrenta.ffecpag%TYPE,
         ffecanu        pagosrenta.ffecanu%TYPE,
         cmotanu        pagosrenta.cmotanu%TYPE,
         isinret        pagosrenta.isinret%TYPE,
         pretenc        pagosrenta.pretenc%TYPE,
         iretenc        pagosrenta.iretenc%TYPE,
         iconret        pagosrenta.iconret%TYPE,
         ibase          pagosrenta.ibase%TYPE,
         pintgar        pagosrenta.pintgar%TYPE,
         pparben        pagosrenta.pparben%TYPE,
         nctacor        seguros.cbancar%TYPE,   -- 7.0 21-10-2011 JGR - 0018944: LCOL_P001 - PER - Tarjetas (nota 0095276) en desarrollo AXIS3181
         nremesa        pagosrenta.nremesa%TYPE,
         fremesa        pagosrenta.fremesa%TYPE,
         ctipban        seguros.ctipban%TYPE,   -- 7.0 21-10-2011 JGR - 0018944: LCOL_P001 - PER - Tarjetas (nota 0095276) en desarrollo AXIS3181
         proceso        pagosrenta.proceso%TYPE,
         -- Ini bug 18494 - SRA - 09/05/2011
         nsinies        pagosrenta.nsinies%TYPE,
         ntramit        pagosrenta.ntramit%TYPE,
         ctipdes        pagosrenta.ctipdes%TYPE,
         cestrec        movpagren.cestrec%TYPE,
         testrec        VARCHAR2(100),
         ttipban        VARCHAR2(100),
         tmotanu        desmotivoanul.tmotanu%TYPE,
         pertom         tomadores.sperson%TYPE,
         npoliza        seguros.npoliza%TYPE,
         ncertif        seguros.ncertif%TYPE
      -- Fin bug 18494 - SRA - 09/05/2011
      );

      t_resultado    reg_resultado;
      n_total        NUMBER := 0;
   BEGIN
      IF pcempres IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vnumerr := pk_rentas.f_get_consultapagosrenta(pcempres, psproduc, pnpoliza, pncertif,
                                                    pcestado, vsquery);

      IF vnumerr != 0 THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 3;
      vcur := pac_md_listvalores.f_opencursor(vsquery, mensajes);

      IF NOT vcur%ISOPEN THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 4;

      FETCH vcur
       INTO t_resultado;

      otpagorenta := t_iax_pagorenta();
      vpasexec := 5;

      WHILE vcur%FOUND LOOP
         n_total := n_total + 1;
         otpagorenta.EXTEND;
         otpagorenta(otpagorenta.LAST) := ob_iax_pagorenta();
         otpagorenta(otpagorenta.LAST).srecren := t_resultado.srecren;
         otpagorenta(otpagorenta.LAST).sseguro := t_resultado.sseguro;
         otpagorenta(otpagorenta.LAST).sperson := t_resultado.sperson;

         BEGIN
            SELECT f_nombre(t_resultado.sperson, 1, s.cagente),
                   f_nombre(t_resultado.pertom, 1, s.cagente)
              INTO otpagorenta(otpagorenta.LAST).tnombre,
                   otpagorenta(otpagorenta.LAST).tnomtom
              FROM seguros s
             WHERE sseguro = t_resultado.sseguro;
         EXCEPTION
            WHEN OTHERS THEN
               otpagorenta(otpagorenta.LAST).tnombre := '';
               otpagorenta(otpagorenta.LAST).tnomtom := '';
         END;

         --otpagorenta(otpagorenta.LAST).tnombre :=pac_isqlfor.f_nompersona(t_resultado.sperson);
         --otpagorenta(otpagorenta.LAST).tnomtom := pac_isqlfor.f_nompersona(t_resultado.pertom);
         otpagorenta(otpagorenta.LAST).ffecefe := t_resultado.ffecefe;
         otpagorenta(otpagorenta.LAST).ffecpag := t_resultado.ffecpag;
         otpagorenta(otpagorenta.LAST).ffecanu := t_resultado.ffecanu;
         otpagorenta(otpagorenta.LAST).cmotanu := t_resultado.cmotanu;
         otpagorenta(otpagorenta.LAST).tmotanu := t_resultado.tmotanu;
         otpagorenta(otpagorenta.LAST).ctipban := t_resultado.ctipban;
         otpagorenta(otpagorenta.LAST).ttipban := t_resultado.ttipban;
         otpagorenta(otpagorenta.LAST).nctacor := t_resultado.nctacor;
         otpagorenta(otpagorenta.LAST).isinret := t_resultado.isinret;
         otpagorenta(otpagorenta.LAST).pretenc := t_resultado.pretenc;
         otpagorenta(otpagorenta.LAST).iretenc := t_resultado.iretenc;
         otpagorenta(otpagorenta.LAST).iconret := t_resultado.iconret;
         otpagorenta(otpagorenta.LAST).ibase := t_resultado.ibase;
         otpagorenta(otpagorenta.LAST).pintgar := t_resultado.pintgar;
         otpagorenta(otpagorenta.LAST).pparben := t_resultado.pparben;
         otpagorenta(otpagorenta.LAST).nremesa := t_resultado.nremesa;
         otpagorenta(otpagorenta.LAST).fremesa := t_resultado.fremesa;
         otpagorenta(otpagorenta.LAST).cestrec := t_resultado.cestrec;
         otpagorenta(otpagorenta.LAST).testrec := t_resultado.testrec;
         otpagorenta(otpagorenta.LAST).npoliza := t_resultado.npoliza;
         otpagorenta(otpagorenta.LAST).ncertif := t_resultado.ncertif;

         FETCH vcur
          INTO t_resultado;
      END LOOP;

      vpasexec := 6;

      CLOSE vcur;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         IF vcur%ISOPEN THEN
            CLOSE vcur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         IF vcur%ISOPEN THEN
            CLOSE vcur;
         END IF;

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
      oocabrenta IN OUT ob_iax_cabrenta,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(2) := 1;
      vparam         VARCHAR2(200) := 'psrecren=' || psrecren;
      vobject        VARCHAR2(200) := 'PAC_MD_RENTAS.f_get_cab_renta';

      CURSOR cur_ass(pc_seg IN NUMBER) IS
         SELECT   sperson, ROWNUM
             FROM asegurados
            WHERE TRUNC(f_sysdate) BETWEEN ffecini AND NVL(ffecfin, TRUNC(f_sysdate))
              AND sseguro = pc_seg
         ORDER BY norden;

      CURSOR cur_dades IS
         SELECT s.npoliza, s.ncertif, s.fefecto, s.ctipban, tc.ttipo ttipban, s.cbancar,
                tom.sperson tsperson, pac_isqlfor.f_nompersona(tom.sperson) nom_tomador,
                sr.ibruren, sr.f1paren, sr.fppren, s.fvencim,
                ff_desvalorfijo(113, pac_md_common.f_get_cxtidioma, sr.cforpag) tforpag,
                sr.ffinren, sr.cmotivo, mm.tmotmov tmotanu, s.sseguro
           FROM seguros s, seguros_ren sr, tomadores tom, tipos_cuentades tc, motmovseg mm,
                pagosrenta pag
          WHERE sr.sseguro = pag.sseguro
            AND s.sseguro = sr.sseguro(+)
            AND s.sseguro = tom.sseguro
            AND tc.ctipban(+) = s.ctipban
            AND tc.cidioma(+) = pac_md_common.f_get_cxtidioma
            AND sr.cmotivo = mm.cmotmov(+)
            AND mm.cidioma(+) = pac_md_common.f_get_cxtidioma
            AND pag.srecren = psrecren
         UNION
         SELECT s.npoliza, s.ncertif, s.fefecto, s.ctipban, tc.ttipo ttipban, s.cbancar,
                tom.sperson tsperson, pac_isqlfor.f_nompersona(tom.sperson) nom_tomador,
                sr.ibruren, sr.f1paren, NULL fppren, s.fvencim,
                ff_desvalorfijo(113, pac_md_common.f_get_cxtidioma, sr.cforpag) tforpag,
                sr.ffinren, sr.cmotivo, mm.tmotmov tmotanu, s.sseguro
           FROM seguros s, prestaren sr, tomadores tom, tipos_cuentades tc, motmovseg mm,
                pagosrenta pag
          WHERE sr.sseguro = pag.sseguro
            AND sr.sperson = pag.sperson
            -- Bug 18286 - APD - 26/04/2011 - union entre prestaren y pagosrenta tambien
            -- por nsinies, ntramit y ctipdes
            AND sr.nsinies = pag.nsinies
            AND sr.ntramit = pag.ntramit
            AND sr.ctipdes = pag.ctipdes
            -- fin Bug 18286 - APD - 26/04/2011
            AND s.sseguro = sr.sseguro(+)
            AND s.sseguro = tom.sseguro
            AND tc.ctipban(+) = s.ctipban
            AND tc.cidioma(+) = pac_md_common.f_get_cxtidioma
            AND sr.cmotivo = mm.cmotmov(+)
            AND mm.cidioma(+) = pac_md_common.f_get_cxtidioma
            AND pag.srecren = psrecren;
   BEGIN
      IF psrecren IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vpasexec := 3;
      oocabrenta := ob_iax_cabrenta();

      FOR i IN cur_dades LOOP
         oocabrenta.npoliza := i.npoliza;
         oocabrenta.ncertif := i.ncertif;
         oocabrenta.fefecto := i.fefecto;
         oocabrenta.ttipban := i.ttipban;
         oocabrenta.cbancar := i.cbancar;
         oocabrenta.tomador := i.nom_tomador;
         oocabrenta.primeraseg := NULL;
         oocabrenta.nedadprimeraseg := NULL;
         oocabrenta.segundoaseg := NULL;
         oocabrenta.nedadsedungoaseg := NULL;

         FOR x IN cur_ass(i.sseguro) LOOP
            IF x.ROWNUM = 1 THEN
               oocabrenta.primeraseg := pac_isqlfor.f_nompersona(x.sperson);
               oocabrenta.nedadprimeraseg :=
                  TRUNC((MONTHS_BETWEEN(f_sysdate,
                                        TO_DATE(pac_isqlfor.f_dades_persona(x.sperson, 2),
                                                'dd/mm/yyyy'))
                         / 12));
            ELSE
               oocabrenta.segundoaseg := pac_isqlfor.f_nompersona(x.sperson);
               oocabrenta.nedadsedungoaseg :=
                  TRUNC((MONTHS_BETWEEN(f_sysdate,
                                        TO_DATE(pac_isqlfor.f_dades_persona(x.sperson, 2),
                                                'dd/mm/yyyy'))
                         / 12));
            END IF;
         END LOOP;

         oocabrenta.ibruren := i.ibruren;
         oocabrenta.fprimerpago := i.f1paren;
         oocabrenta.fproxgen := i.fppren;
         oocabrenta.fvencim := i.fvencim;
         oocabrenta.tformapago := i.tforpag;
         oocabrenta.ffinrenta := i.ffinren;
         oocabrenta.tmotivo := i.tmotanu;
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
      oopagorenta IN OUT ob_iax_pagorenta,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(2) := 1;
      vparam         VARCHAR2(200) := 'psrecren=' || psrecren;
      vobject        VARCHAR2(200) := 'PAC_MD_RENTAS.f_get_pagorenta';

      CURSOR cur_pagorenta IS
         SELECT pr.*, mp.cestrec,
                ff_desvalorfijo(230, pac_md_common.f_get_cxtidioma, mp.cestrec) testrec,
                tc.ttipo ttipban, mm.tmotmov tmotanu, mp.fmovini
           FROM pagosrenta pr, movpagren mp, tipos_cuentades tc, seguros_ren sr, motmovseg mm
          WHERE mp.srecren = pr.srecren
            AND mp.fmovfin IS NULL
            AND tc.ctipban(+) = pr.ctipban
            AND tc.cidioma(+) = pac_md_common.f_get_cxtidioma
            AND pr.sseguro = sr.sseguro(+)
            AND sr.cmotivo = mm.cmotmov(+)
            AND mm.cidioma(+) = pac_md_common.f_get_cxtidioma
            AND pr.srecren = psrecren;
   BEGIN
      IF psrecren IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      oopagorenta := ob_iax_pagorenta();

      FOR i IN cur_pagorenta LOOP
         oopagorenta.srecren := i.srecren;
         oopagorenta.sseguro := i.sseguro;
         oopagorenta.sperson := i.sperson;
         oopagorenta.tnombre := pac_isqlfor.f_nompersona(i.sperson);
         oopagorenta.ffecefe := i.ffecefe;
         oopagorenta.ffecpag := i.ffecpag;
         oopagorenta.ffecanu := i.ffecanu;
         oopagorenta.cmotanu := i.cmotanu;
         oopagorenta.tmotanu := i.tmotanu;
         oopagorenta.ctipban := i.ctipban;
         oopagorenta.ttipban := i.ttipban;
         oopagorenta.nctacor := i.nctacor;
         oopagorenta.isinret := i.isinret;
         oopagorenta.pretenc := i.pretenc;
         oopagorenta.iretenc := i.iretenc;
         oopagorenta.iconret := i.iconret;
         oopagorenta.ibase := i.ibase;
         oopagorenta.pintgar := i.pintgar;
         oopagorenta.pparben := i.pparben;
         oopagorenta.nremesa := i.nremesa;
         oopagorenta.fremesa := i.fremesa;
         oopagorenta.cestrec := i.cestrec;
         oopagorenta.testrec := i.testrec;
         oopagorenta.fmovini := i.fmovini;
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
      vobject        VARCHAR2(200) := 'PAC_MD_RENTAS.f_act_pagorenta';
      vnumerr        NUMBER := 0;
      vempresa       seguros.cempres%TYPE;
      n_mov6         NUMBER(1);
      xfmovini       movpagren.fmovini%TYPE;
      xcestrec       movpagren.cestrec%TYPE;
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

      BEGIN
         SELECT m.fmovini, m.cestrec
           INTO xfmovini, xcestrec
           FROM movpagren m, pagosrenta p, seguros s
          WHERE p.srecren = psrecren
            AND m.fmovfin IS NULL
            AND m.srecren = p.srecren
            AND s.sseguro = p.sseguro;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 111282;
      END;

      IF pestpag = xcestrec
         AND TRUNC(pfechamov) = TRUNC(xfmovini) THEN
         -- Si no hay cambios, no hacemos el cambio de estado.
         NULL;
      ELSE
         IF pfechamov IS NOT NULL THEN
            --JRH
            SELECT MAX(cempres)
              INTO vempresa
              FROM seguros s, pagosrenta p
             WHERE s.sseguro = p.sseguro
               AND p.srecren = psrecren;

            -- Fin Bug 17247
            IF NVL(pac_parametros.f_parempresa_n(vempresa, 'GESTIONA_COBPAG'), 0) = 1 THEN
               --El estado a cambiar sólo puede ser a 5,2 o 0 en el caso de que noexiste_movpagren=6

               -- ini Bug 0013477 - JMF - 29/03/2011
               SELECT NVL(MAX(1), 0)
                 INTO n_mov6
                 FROM movpagren
                WHERE srecren = psrecren
                  AND cestrec = 6;

               IF ((NVL(pestpag, -1) = 0
                    AND n_mov6 = 0)
                   OR NVL(pestpag, -1) IN(2)) THEN
                  NULL;   -- casos correctos
               ELSE
                  RETURN 110300;   -- Cambio de estado no permitido
               END IF;
            -- fin Bug 0013477 - JMF - 29/03/2011
            ELSE
               IF NVL(pestpag, -1) NOT IN(0, 1, 2, 5) THEN
                  -- PERMITIDOS: 0 -> Pdte., 1 -> Pagado, 2 -> Anulado, 5 -> Bloqueado
                  RETURN 110300;   -- Cambio de estado no permitido
               END IF;
            END IF;

            --- FIN NNNN
            vnumerr := pk_rentas.cambia_estado_recibo(psrecren, pfechamov, pestpag);
         END IF;
      END IF;

      vpasexec := 3;

      IF vnumerr != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      vpasexec := 4;
      vnumerr := pk_rentas.f_act_pagorenta(psrecren, pctipban, pcuenta, pbase, pporcentaje,
                                           pbruto, pretencion, pneto);
      vpasexec := 5;

      IF vnumerr != 0 THEN
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
      vobject        VARCHAR2(200) := 'PAC_MD_RENTAS.f_act_pagorenta';
      vnumerr        NUMBER := 0;
   BEGIN
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vnumerr := pk_rentas.f_bloq_proxpagos(psseguro);
      vpasexec := 3;

      IF vnumerr != 0 THEN
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
                                           SQLCODE, SQLERRM);
         RETURN 1;
   END f_bloq_proxpagos;

-- ****************************************************************
-- f_anula_rec
-- Busca los recibos que se han pagado para extornar o generados
-- para in pfecha: Fecha
--param in pseguro: Seguro
-- param in secren : srecren
    --BUG 13477 - JTS - 15/03/2010
-- ****************************************************************
   FUNCTION f_anula_rec(
      pfecha IN DATE,   -- Fecha en que se ha informado la muerte
      pseguro IN NUMBER,   -- Clave del Seguro
      psrecren IN NUMBER DEFAULT NULL,   --Por si se quiere precisar a un recibo
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(2) := 1;
      vparam         VARCHAR2(50)
                  := 'pfecha=' || pfecha || ' pseguro=' || pseguro || ' psrecren=' || psrecren;
      vobject        VARCHAR2(200) := 'PAC_MD_RENTAS.f_anula_rec';
      vnumerr        NUMBER := 0;
   BEGIN
      IF pseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vnumerr := pk_rentas.anula_rec(pfecha, pseguro, psrecren);
      vpasexec := 3;

      IF vnumerr != 0 THEN
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
      vobject        VARCHAR2(200) := 'PAC_MD_RENTAS.f_actualiza_tipocalcul';
      vnumerr        NUMBER := 0;
   BEGIN
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;

      UPDATE estseguros_ren
         SET tipocalcul = ptipocalcul
       WHERE sseguro = psseguro;

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
   END f_actualiza_tipocalcul;
END pac_md_rentas;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_RENTAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_RENTAS" TO "PROGRAMADORESCSI";
  GRANT EXECUTE ON "AXIS"."PAC_MD_RENTAS" TO "R_AXIS";
