--------------------------------------------------------
--  DDL for Package Body PAC_IAX_COA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_COA" IS
/******************************************************************************
 NAME: pac_iax_coa
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        29/05/2012                    1. Created this package body.
   2.0        29/05/2012    AVT             2. 0022076: LCOL_A004-Mantenimientos de cuenta tecnica del reaseguro y del coaseguro
   3.0        27/11/2012    AVT             3. 24894: Qtracker: 0005427: No existe DATA en axiscoa001 Consulta Cuentas Coaseguro
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;
   e_param_err_null EXCEPTION;

---------------------------------------------------------------------------------------------------------------------------------

   /*************************************************************************
   Funci¿n que actualiza el estado de movimiento concreto de una cuenta de coaseguro
   *************************************************************************/
   -- Bug 32034 - SHA - 18/08/2014 - se crea la funcion
   FUNCTION f_set_estado_ctacoa(
      pccompani IN NUMBER,
      pcompapr IN NUMBER,
      pctipcoa IN NUMBER,
      pcempres IN NUMBER,
      psproces IN NUMBER,
      pcmovimi IN NUMBER,
      pfcierre IN DATE,
      pestadonew IN NUMBER,
      pestadoold IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vobject        VARCHAR2(500) := 'PAC_COA.f_set_estado_ctacoa';
      vparam         VARCHAR2(500)
         := 'params : pccompani : ' || pccompani || ', pcompapr : ' || pcompapr
            || ', pctipcoa : ' || pctipcoa || ' , pcempres : ' || pcempres || ', psproces : '
            || psproces || ', pfcierre : ' || pfcierre || ', pestadonew : ' || pestadonew
            || ', pestadoold : ' || pestadoold || ', pcmovimi : ' || pcmovimi;
      vnumerr        NUMBER := 0;
   BEGIN
      vnumerr := pac_md_coa.f_set_estado_ctacoa(pccompani, pcompapr, pctipcoa, pcempres,
                                                psproces, pcmovimi, pfcierre, pestadonew,
                                                pestadoold, mensajes);

      IF vnumerr = 0 THEN
         COMMIT;
      ELSE
         ROLLBACK;
      END IF;

      RETURN vnumerr;
   EXCEPTION
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
         RETURN 1;
   END f_set_estado_ctacoa;

   /***************************************************************************************************
   Funci¿n que setea a Pendiente el estado de aquellos movimientos de cuenta de coaseguro con estado 4
   ****************************************************************************************************/
   -- Bug 32034 - SHA - 18/08/2014 - se crea la funcion
   FUNCTION f_reset_estado(pcempres IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_object       VARCHAR2(500) := 'PAC_COA.f_reset_estado';
      v_param        VARCHAR2(500) := 'params : pcempres : ' || pcempres;
      v_pasexec      NUMBER(5) := 0;
      vnumerr        NUMBER := 0;
      v_ttexto       VARCHAR2(1000);
      vidioma        NUMBER;
   BEGIN
      vidioma := pac_md_common.f_get_cxtidioma;
      vnumerr := pac_md_coa.f_reset_estado(pcempres, mensajes);

      IF vnumerr = 0 THEN
         COMMIT;
      ELSE
         ROLLBACK;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_reset_estado;

   /*************************************************************************
   Funci¿n que devuelve el detalle por poliza de las cuentas t¿cnicas de coaseguro
   *************************************************************************/
   -- Bug 24462 - SHA - 14/01/2014 - se crea la funcion
   FUNCTION f_get_ctacoaseguro_det(
      pccompani IN NUMBER,
      pfcierre IN DATE,
      pciaprop IN NUMBER,
      ptipocoaseguro IN NUMBER,
      pcempres IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pcestado IN NUMBER,
      psseguro IN NUMBER,
      pcinverfas IN NUMBER,   -- Bug 32034 - SHA - 11/08/2014
      psproces IN NUMBER,   -- Bug 32034 - SHA - 11/08/2014
      pliquidable IN NUMBER,   -- Bug 32034 - SHA - 11/08/2014
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'par¿metros - pccompani:' || pccompani || ' - pfcierre:' || pfcierre
            || ' - pciaprop:' || pciaprop || ' - ptipocoaseguro:' || ptipocoaseguro
            || ' - pcinverfas:' || pcinverfas || ' - psproces:' || psproces
            || ' - pliquidable:' || pliquidable;
      vobject        VARCHAR2(50) := 'pac_iax_coa.f_get_ctacoaseguro';
      vcursor        sys_refcursor;
   BEGIN
      vcursor := pac_md_coa.f_get_ctacoaseguro_det(pccompani, pfcierre, pciaprop,
                                                   ptipocoaseguro, pcempres, pcramo, psproduc,
                                                   pnpoliza, pncertif, pcestado, psseguro,
                                                   pcinverfas, psproces, pliquidable,
                                                   mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
   END f_get_ctacoaseguro_det;

   /*************************************************************************
   Funci¿n que devuelve las cuentas t¿cnicas de coaseguro
   *************************************************************************/
   -- Bug 22076 - AVT - 29/05/2012 - se crea la funcion
   FUNCTION f_get_ctacoaseguro(
      pcempres IN NUMBER,
      pccompani IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pfcierre IN DATE,
      psseguro IN NUMBER,
      pcestado IN NUMBER,
      pciaprop IN NUMBER,
      ptipocoaseguro IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pcinverfas IN NUMBER,   -- Bug 32034 - SHA - 11/08/2014
      psproces IN NUMBER,   -- Bug 32034 - SHA - 11/08/2014
      pfcierredesde IN DATE,
      pfcierrehasta IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(400)
         := 'par¿metros - pcempres:' || pcempres || ' - pccompani:' || pccompani
            || ' - pcramo:' || pcramo || ' - psproduc:' || psproduc || ' - pfcierre:'
            || pfcierre || ' - psseguro:' || psseguro || ' - pcestado:' || pcestado
            || ' - pciaprop:' || pciaprop || ' - ptipocoaseguro:' || ptipocoaseguro
            || ' - pnpoliza:' || pnpoliza || ' - pncertif:' || pncertif || ' - pcinverfas:'
            || pcinverfas || ' - psproces:' || psproces || ' - pfcierredesde:' || pfcierredesde
            || ' - pfcierrehasta:' || pfcierrehasta;
      vobject        VARCHAR2(50) := 'pac_iax_coa.f_get_ctacoaseguro';
      vcursor        sys_refcursor;
   BEGIN
      vcursor := pac_md_coa.f_get_ctacoaseguro(pcempres, pccompani, pcramo, psproduc,
                                               pfcierre, psseguro, pcestado, pciaprop,
                                               ptipocoaseguro, pnpoliza, pncertif, pcinverfas,
                                               psproces, pfcierredesde, pfcierrehasta, mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
   END f_get_ctacoaseguro;

   /*************************************************************************
   Funci¿n que devuelve la cabecera de la cuenta t¿cnica de coaseguro consultada
   *************************************************************************/
   -- Bug 22076 - AVT - 29/05/2012 - se crea la funcion
   FUNCTION f_get_cab_ctacoa(
      pcempres IN NUMBER,
      pccompapr IN NUMBER,
      pccompani IN NUMBER,
      psseguro IN NUMBER,
      pfcierre IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'par¿metros - pcempres:' || pcempres || ' - pccompani:' || pccompani
            || ' - psseguro:' || psseguro || ' - pfcierre:' || pfcierre;
      vobject        VARCHAR2(50) := 'pac_iax_coa.f_get_cab_ctacoa';
      vcursor        sys_refcursor;
   BEGIN
      -- 24894 AVT 27/11/2012 control de dades a null
      IF pcempres IS NULL
         OR pccompani IS NULL
         OR psseguro IS NULL
       --  OR pfcierre IS NULL
         THEN
         RAISE e_param_err_null;
      END IF;

      -- 24894 AVT 27/11/2012  fi
      vcursor := pac_md_coa.f_get_cab_ctacoa(pcempres, pccompapr, pccompani, psseguro,
                                             pfcierre, mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_err_null THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 9904581, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
   END f_get_cab_ctacoa;

   /*************************************************************************
   Funci¿n que devuelve las cuentas t¿cnicas de la coaseguradora consultada
   *************************************************************************/
   -- Bug 22076 - AVT - 29/05/2012 - se crea la funcion
   FUNCTION f_get_mov_ctacoa(
      pcempres IN NUMBER,
      pccompapr IN NUMBER,
      pccompani IN NUMBER,
      psseguro IN NUMBER,
      pfcierre IN DATE,
      pcestado IN NUMBER,   -- Bug 32034 - SHA - 11/08/2014
      psproces IN NUMBER,   -- Bug 32034 - SHA - 11/08/2014
      pliquidable IN NUMBER,   -- Bug 32034 - SHA - 11/08/2014
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'par¿metros - pcempres:' || pcempres || ' - pccompani:' || pccompani
            || ' - psseguro:' || psseguro || ' - pfcierre:' || pfcierre || ' - pcestado:'
            || pcestado || ' - psproces:' || psproces || ' - pliquidable:' || pliquidable;
      vobject        VARCHAR2(50) := 'pac_iax_coa.f_get_mov_ctacoa';
      vcursor        sys_refcursor;
   BEGIN
      -- 24894 AVT 27/11/2012 control de dades a null
      IF pcempres IS NULL
         OR pccompani IS NULL
         OR psseguro IS NULL
       --  OR pfcierre IS NULL
         THEN
         RAISE e_param_err_null;
      END IF;

      -- 24894 AVT 27/11/2012  fi
      vcursor := pac_md_coa.f_get_mov_ctacoa(pcempres, pccompapr, pccompani, psseguro,
                                             pfcierre, pcestado, psproces, pliquidable,
                                             mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_err_null THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 9904581, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
   END f_get_mov_ctacoa;

   /*************************************************************************
   Funci¿n que elimina un movimiento manual de la cuenta t¿cnica del coaseguro
   *************************************************************************/
   -- Bug 22076 - AVT - 29/05/2012 - se crea la funcion
   FUNCTION f_del_mov_ctacoa(
      pcempres IN NUMBER,
      pccompani IN NUMBER,
      psseguro IN NUMBER,
      pfcierre IN DATE,
      pnnumlin IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800)
         := ' pcempres:' || pcempres || ' - pccompani:' || pccompani || ' - psseguro:'
            || psseguro || ' - pfcierre:' || pfcierre || ' - pnnumlin:' || pnnumlin;
      vobject        VARCHAR2(50) := 'pac_iax_coa.f_del_mov_ctacoa';
      vnumerr        NUMBER := 0;
   BEGIN
      -- 24894 AVT 27/11/2012 control de dades a null
      IF pcempres IS NULL
         OR pccompani IS NULL
         OR psseguro IS NULL
         OR pfcierre IS NULL
         OR pnnumlin IS NULL THEN
         RAISE e_param_error;
      END IF;

      -- 24894 AVT 27/11/2012  fi
      vnumerr := pac_md_coa.f_del_mov_ctacoa(pcempres, pccompani, psseguro, pfcierre, pnnumlin,
                                             mensajes);

      IF vnumerr = 0 THEN
         COMMIT;
      ELSE
         ROLLBACK;
      END IF;

      RETURN vnumerr;
   EXCEPTION
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
         RETURN 1;
   END f_del_mov_ctacoa;

   /*************************************************************************
   Funci¿n que apunta en la tabla de liquidaci¿n los importes pendientes de la cuenta t¿cnica del coaseguro.
   *************************************************************************/
   -- Bug 22076 - AVT - 24/05/2012 - se crea la funcion
   FUNCTION f_liquida_ctatec_coa(
      pcempres IN empresas.cempres%TYPE DEFAULT pac_md_common.f_get_cxtempresa,
      pccompani IN NUMBER,
      pccompapr IN NUMBER,
      pfcierre IN DATE,
      pfcierredesde IN DATE,
      pfcierrehasta IN DATE,
      pctipcoa IN NUMBER,
      psproces_ant IN NUMBER,
      psproces_nou IN NUMBER,
      indice OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800)
         := ' pcempres:' || pcempres || ' - pccompani:' || pccompani || ' - pccompapr:'
            || pccompapr || ' - pfcierre:' || pfcierre || ' - pfcierredesde:' || pfcierredesde
            || ' - pfcierrehasta:' || pfcierrehasta || ' - pctipcoa:' || pctipcoa
            || ' - psproces_ant:' || psproces_ant || ' - psproces_nou:' || psproces_nou;
      vobject        VARCHAR2(50) := 'pac_iax_coa.f_liquida_ctatec_coa';
      vnumerr        NUMBER := 0;
   BEGIN
--      -- Control parametros entrada
--      IF psproces IS NULL THEN
--         RAISE e_param_error;
--      END IF;

      -- 24891 AVT 27/11/2012 control de dades a null
      IF pcempres IS NULL
--         OR pccompapr IS NULL
         OR (pfcierre IS NULL
             AND
             (pfcierredesde IS NULL AND pfcierrehasta IS NULL)
             )
         OR pctipcoa IS NULL
         OR psproces_ant IS NULL
         OR psproces_nou IS NULL THEN
         RAISE e_param_error;
      END IF;

      -- 24891 AVT 27/11/2012  fi
      vnumerr := pac_md_coa.f_liquida_ctatec_coa(pcempres, pccompani, pccompapr, pfcierre,
                                                 pfcierredesde, pfcierrehasta, pctipcoa,
                                                 psproces_ant, psproces_nou, indice, mensajes);


      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
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
         RETURN 1;
   END f_liquida_ctatec_coa;

   /*************************************************************************
       Funci¿n que insertar¿ o modificar¿ un movimiento de cuenta t¿cnica en funci¿n del pmodo
   *************************************************************************/
   -- Bug 22076 - AVT - 25/05/2012 - se crea la funcion
   FUNCTION f_set_mov_ctacoa(
      pcempres IN NUMBER,
      pccompani IN NUMBER,
      pnnumlin IN NUMBER,
      pctipcoa IN NUMBER,
      pcdebhab IN NUMBER,
      psseguro IN NUMBER,
      pnrecibo IN NUMBER,
      psidepag IN NUMBER,
      pfcierre IN DATE,
      pcmovimi IN NUMBER,
      pcimport IN NUMBER,
      pimovimi IN NUMBER,
      pfcambio IN DATE,
      pcestado IN NUMBER,
      ptdescri IN VARCHAR2,
      ptdocume IN VARCHAR2,
      pmodo IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800)
         := 'params pcempres : ' || pcempres || 'pccompani : ' || pccompani || ', pnnumlin : '
            || pnnumlin || ', pctipcoa : ' || pctipcoa || ' , psseguro : ' || psseguro
            || ', pnrecibo : ' || pnrecibo || ', psidepag : ' || psidepag || ', pfcierre : '
            || pfcierre || ', pcmovimi : ' || pcmovimi || ' , pimovimi : ' || pimovimi
            || ' pmodo:' || pmodo;
      vobject        VARCHAR2(50) := 'pac_iax_coa.f_set_mov_ctacoa';
      vnumerr        NUMBER := 0;
   BEGIN
      vnumerr := pac_md_coa.f_set_mov_ctacoa(pcempres, pccompani, pnnumlin, pctipcoa,
                                             pcdebhab, psseguro, pnrecibo, psidepag, pfcierre,
                                             pcmovimi, pcimport, pimovimi, pfcambio, pcestado,
                                             ptdescri, ptdocume, pmodo, mensajes);

      IF vnumerr = 0 THEN
         COMMIT;
      ELSE
         ROLLBACK;
      END IF;

      RETURN vnumerr;
   EXCEPTION
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
         RETURN 1;
   END f_set_mov_ctacoa;

---------------------------------------------------------------------------------------------------------------------------------
   /*******************************************************************************
   FUNCION F_REGISTRA_PROCESO
   Esta funci¿n nos devolver¿ el c¿digo de proceso real para la liquidaci¿n del coaseguro
    Par¿metros:
     Entrada :
       Pfperini NUMBER  : Fecha Inicio
       Pcempres NUMBER  : Empresa
     Salida :
       Mensajes   T_IAX_MENSAJES
   Retorna : NUMBER con el n¿mero de proceso.
   ********************************************************************************/
   FUNCTION f_registra_proceso(
      pfperfin IN DATE,
      pcempres IN NUMBER,
      pnproceso OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pfperfin = ' || pfperfin || 'pcempres=' || pcempres;
      vobject        VARCHAR2(200) := 'PAC_IAX_COA.F_REGISTRA_PROCESO';
      vnumerr        NUMBER := 0;
   BEGIN
      -- Control parametros entrada
      IF pfperfin IS NULL
         OR pcempres IS NULL THEN
         RAISE e_param_error;
      END IF;

      /*Deber¿ llamar a la funci¿n de la capa MD, pac_md_coa.f_registra_proceso
      Esta funci¿n nos devolver¿ el c¿digo de proceso real para el previo o cartera.
      Este proceso solo se obtendr¿ en el momento lanzar el previo de cartera o cartera.
      */
      vnumerr := pac_md_coa.f_registra_proceso(pfperfin, pcempres, pnproceso, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      --Retorna : un NUMBER.
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
         RETURN 1;
   END f_registra_proceso;
---------------------------------------------------------------------------------------------------------------------------------

/*******************************************************************************
FUNCION F_GET_REMESA_DET
Esta funci¿n nos devolver¿ la consulta de remesas

********************************************************************************/
   -- Bug 22076 - AVT - 04/10/2012 - se crea la funcion
function F_GET_REMESA_DET(    --ramiro
  PCCOMPANI  in number,
  PCSUCURSAL in number,
  PFCIERRE  in date,
  PCIAPROP in number,
  PCTIPCOA in number,
  PCEMPRES in number,
  PCRAMO in number,
  PSPRODUC in number,
  PNPOLCIA in number,
  PCESTADO in number,
  PSSEGURO in number,
  PSMOVCOA IN NUMBER,
  MENSAJES OUT T_IAX_MENSAJES)
  return sys_refcursor  is
  VPASEXEC       number(8) := 1;
  vparam         VARCHAR2(200) :=  PCCOMPANI||','||PCSUCURSAL||','||PFCIERRE||','||PCIAPROP||','||
  PCTIPCOA||','||PCEMPRES||','||PCRAMO||','||PSPRODUC||','||PNPOLCIA||','||PCESTADO||','||psseguro;
  VOBJECT        varchar2(200) := 'PAC_IAX_COA.F_GET_REMESA_DET';
  VNUMERR        number := 0;
  vcursor            sys_refcursor;--ramiro

begin

vcursor := pac_md_coa.f_get_remesa_det (PCCOMPANI, PCSUCURSAL, PFCIERRE, PCIAPROP, PCTIPCOA, PCEMPRES, PCRAMO, PSPRODUC, PNPOLCIA, PCESTADO, psseguro,PSMOVCOA, mensajes);
      return vcursor;



EXCEPTION

WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         return VCURSOR;

WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         return VCURSOR;


end F_GET_REMESA_DET; --ramiro


 /*******************************************************************************
FUNCION F_SET_REMESA_DET
Esta funci¿n nos devolver¿ la consulta de remesas

********************************************************************************/
   -- Bug 22076 - AVT - 04/10/2012 - se crea la funcion
   function F_SET_REMESA_DET(    --ramiro
     pcempres IN NUMBER,
      pccompani IN NUMBER,
      pnnumlin IN NUMBER,
      pctipcoa IN NUMBER,
      pcdebhab IN NUMBER,
      psseguro IN NUMBER,
      pnrecibo IN NUMBER,
      psidepag IN NUMBER,
      pfcierre IN DATE,
      pcmovimi IN NUMBER,
      pcimport IN NUMBER,
      pimovimi IN NUMBER,
      pfcambio IN DATE,
      pcestado IN NUMBER,
      ptdescri IN VARCHAR2,
      ptdocume IN VARCHAR2,
      PMODO in number,
      PNPOLCIA in number,
      PCSUCURSAL in number,
      PMONEDA in number,
      psmvcoa in number,
      MENSAJES OUT T_IAX_MENSAJES)
      return NUMBER IS --ramiro
      VPASEXEC       number(8) := 1;
      VPARAM         varchar2(200) :=  PCEMPRES||','||PCCOMPANI||','||PNNUMLIN||','||PNPOLCIA||','||
      pcsucursal||','||pcestado||','||pfcierre||','||pcmovimi||','||pctipcoa||','||pimovimi||','||pmodo;
      VOBJECT        varchar2(200) := 'PAC_IAX_COA.F_SET_REMESA_DET';
      VNUMERR        number := 0;
BEGIN

VNUMERR := PAC_MD_COA.F_SET_REMESA_CTACOA (PCEMPRES, PCCOMPANI, PNNUMLIN, PCTIPCOA, PCDEBHAB,
                                           PSSEGURO, PNRECIBO, PSIDEPAG, PFCIERRE, PCMOVIMI,
                                           PCIMPORT, PIMOVIMI, PFCAMBIO, PCESTADO, PTDESCRI,
                                           PTDOCUME, PMODO, PNPOLCIA, PCSUCURSAL, PMONEDA,
                                           psmvcoa,MENSAJES
                                           );

  IF vnumerr <> 0 THEN

  raise e_object_error;

  end if;

commit;
return vnumerr;

EXCEPTION
WHEN e_object_error THEN
 ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, vnumerr, vpasexec, vparam);

         RETURN 1;
 WHEN OTHERS THEN
 ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, vnumerr, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         return 1;

END F_SET_REMESA_DET;


END pac_iax_coa;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_COA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_COA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_COA" TO "PROGRAMADORESCSI";
