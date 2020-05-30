--------------------------------------------------------
--  DDL for Package Body PAC_IAX_REDCOMERCIAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_REDCOMERCIAL" IS
/******************************************************************************
   NOMBRE:       PAC_IAX_REDCOMERCIAL
   PROPSITO:    Funciones con todo lo referente a la Red Comercial de la capa IAX

   REVISIONES:
   Ver        Fecha        Autor             Descripcin
   ---------  ----------  ---------------  ------------------------------------
   1.0        16/09/2008   AMC              1. Creacin del package.
   2.0        19/10/2009   AMC              2. Bug 11444. Se quita el parametro pctipage a la funcion f_set_redcomarcial
   3.0        20/10/2011   JMC              3. 0019586: AGM003-Comisiones Indirectas a distintos niveles.
   4.0        08/11/2011   APD              4. 0019169: LCOL_C001 - Campos nuevos a aadir para Agentes.
   5.0        05/12/2011   APD              5. 0020287: LCOL_C001 - Tener en cuenta campo Subvencin
   6.0        21/05/2014   FAL              6. 0031489: TRQ003-TRQ: Gap de comercial. Liquidacin a nivel de Banco
   7.0        16/01/2019   ACL              7. TCS_1: En la funcin f_set_agente se agrega el campo claveinter para la tabla agentes.
   8.0        01/02/2019   ACL              8. TCS_1569B: Se agrega parmetros de impuestos en la funcion f_set_agente.
   9.0        21/02/2019   AP               9. TCS-7: Se agrega parametro de domicilio en la funcion f_set_redcomercial.
  10.0        27/02/2019   DFR             10. IAXIS-2415: FICHA RED COMERCIAL
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

/*************************************************************************
        Funcin que nos devolver la red comercial segn parmetros informados en el filtro
        Return: Sys_Refcursor
    *************************************************************************/
   FUNCTION f_get_agentes(
      pempresa IN NUMBER,
      pfecha IN DATE,
      pcagente IN NUMBER,
      pnomagente IN VARCHAR2,
      ptipagente IN NUMBER,
      pactivo IN NUMBER,
      pctipmed IN NUMBER,
      pagrupador IN NUMBER,
      pnnumide IN VARCHAR2,
      pcpostal IN VARCHAR2,
      ptelefono IN NUMBER,
      ptnomcom IN VARCHAR2,
      pfax IN NUMBER,
      pmail IN VARCHAR2,
      pcage00 IN NUMBER,
      pcage01 IN NUMBER,
      pcage02 IN NUMBER,
      pcage03 IN NUMBER,
      pcage04 IN NUMBER,
      pcage05 IN NUMBER,
      pcage06 IN NUMBER,
      pcage07 IN NUMBER,
      pcage08 IN NUMBER,
      pcage09 IN NUMBER,
      pcage10 IN NUMBER,
      pcage11 IN NUMBER,
      pcage12 IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := ' pempresa:' || pempresa || ' pfecha:' || pfecha || ' pcagente:' || pcagente
            || ' pnomagente:' || pnomagente || ' ptipagente:' || ptipagente || 'pactivo:'
            || pactivo;
      vobject        VARCHAR2(200) := 'PAC_IAX_REDCOMERCIAL.F_get_arbolredcomercial';
      cur            sys_refcursor;
   BEGIN
      IF pfecha IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 105308);
         RAISE e_param_error;
      END IF;

      cur := pac_md_redcomercial.f_get_agentes(pempresa, pfecha, pcagente, pnomagente,
                                               ptipagente, pactivo, pctipmed, pagrupador,
                                               pnnumide, pcpostal, ptelefono, ptnomcom, pfax,
                                               pmail, pcage00, pcage01, pcage02, pcage03,
                                               pcage04, pcage05, pcage06, pcage07, pcage08,
                                               pcage09, pcage10, pcage11, pcage12, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_agentes;

   /*************************************************************************
       Funcin que nos devolver la red comercial segn parmetros informados en el filtro
       Return: Sys_Refcursor
   *************************************************************************/
   FUNCTION f_get_arbolredcomercial(
      pempresa IN NUMBER,
      pfecha IN DATE,
      pcagente IN NUMBER,
      pnomagente IN VARCHAR2,
      ptipagente IN NUMBER,
      pactivo IN NUMBER,
      pcbusqueda IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := ' pempresa:' || pempresa || ' pfecha:' || pfecha || ' pcagente:' || pcagente
            || ' pnomagente:' || pnomagente || ' ptipagente:' || ptipagente || 'pactivo:'
            || pactivo || 'pcbusqueda:' || pcbusqueda;
      vobject        VARCHAR2(200) := 'PAC_IAX_REDCOMERCIAL.F_get_arbolredcomercial';
      cur            sys_refcursor;
   BEGIN
      IF pfecha IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000147);
         RAISE e_param_error;
      END IF;

      cur := pac_md_redcomercial.f_get_arbolredcomercial(pempresa, pfecha, pcagente,
                                                         pnomagente, ptipagente, pactivo,
                                                         pcbusqueda, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_arbolredcomercial;

   /*************************************************************************
       Funcin que har las llamadas a todas las funciones necesarias para poder cargar
       los objetos de agentes y contratos
       Return: NUMBER
   *************************************************************************/
   FUNCTION f_get_datosagente(
      pcagente IN NUMBER,
      contratos OUT t_iax_contratos,
      agente OUT ob_iax_agentes,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'pcagente:' || pcagente;
      vobject        VARCHAR2(200) := 'PAC_IAX_REDCOMERCIAL.F_get_arbolredcomercial';
      num_err        NUMBER;
   BEGIN
      IF pcagente IS NOT NULL THEN
         num_err := pac_md_redcomercial.f_get_datosagente(pcagente, contratos, agente,
                                                          mensajes);
      ELSE
         contratos := t_iax_contratos();
         agente := ob_iax_agentes;
      END IF;

      RETURN num_err;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN num_err;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN num_err;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN num_err;
   END f_get_datosagente;

   /*************************************************************************
    Funcin que har la llamada a la funcin para poder recuperar el histrico de la Red Comercial
    segn los parmetros de entrada como son el cdigo de agente y el de empresa.
    Return: t_iax_redcomercial
   *************************************************************************/
   FUNCTION f_get_redcomercial(
      pcagente IN NUMBER,
      pcempres IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_redcomercial IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'pcagente:' || pcagente || ' pcempres:' || pcempres;
      vobject        VARCHAR2(200) := 'PAC_IAX_REDCOMERCIAL.F_get_arbolredcomercial';
      redcomercial   t_iax_redcomercial;
   BEGIN
      redcomercial := pac_md_redcomercial.f_get_redcomercial(pcagente, pcempres, mensajes);
      RETURN redcomercial;
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
   END f_get_redcomercial;

   -- Bug 19169 - APD - 16/09/2011 - se aaden los nuevos campos de la tabla agentes y agentes_comp
    /*************************************************************************
      f_set_agente
        -- Bug 27949 Se quitan parmetros para ser usado en f_set_agente_comp
   *************************************************************************/
   FUNCTION f_set_agente(
      pcagente IN agentes.cagente%TYPE,
      pcretenc IN agentes.cretenc%TYPE,
      pctipiva IN agentes.ctipiva%TYPE,
      psperson IN agentes.sperson%TYPE,
      pccomisi IN agentes.ccomisi%TYPE,
      pcdesc IN NUMBER,
      pctipage IN agentes.ctipage%TYPE,
      pcactivo IN agentes.cactivo%TYPE,
      pcdomici IN agentes.cdomici%TYPE,
      pcbancar IN agentes.cbancar%TYPE,
      pncolegi IN agentes.ncolegi%TYPE,
      pfbajage IN agentes.fbajage%TYPE,
      pctipban IN agentes.ctipban%TYPE,
      pfinivigcom IN DATE,
      pffinvigcom IN DATE,
      pfinivigdesc IN DATE,
      pffinvigdesc IN DATE,
      pcsobrecomisi IN agentes.csobrecomisi%TYPE,
      pfinivigsobrecom IN DATE,
      pffinvigsobrecom IN DATE,
      ptalias IN agentes.talias%TYPE,
      pcliquido IN agentes.cliquido%TYPE,
      pccomisi_indirect IN agentes.ccomisi_indirect%TYPE,   -- Bug 20999 - APD - 25/01/2012
      pfinivigcom_indirect IN DATE,   -- Bug 20999 - APD - 25/01/2012
      pffinvigcom_indirect IN DATE,
      -- bug 21425/109832 - 21/03/2012 - AMC
      pctipmed IN agentes.ctipmed%TYPE,
      ptnomcom IN agentes.tnomcom%TYPE,
      pcdomcom IN agentes.cdomcom%TYPE,
      pctipretrib IN agentes.ctipretrib%TYPE,
      pcmotbaja IN agentes.cmotbaja%TYPE,
      pcbloqueo IN agentes.cbloqueo%TYPE,
      pnregdgs IN agentes.nregdgs%TYPE,
      pfinsdgs IN agentes.finsdgs%TYPE,
      pcrebcontdgs IN agentes.crebcontdgs%TYPE,
      pcoblccc IN NUMBER,
      pccodcon IN agentes.ccodcon%TYPE,
      pclaveinter IN  agentes.claveinter%TYPE,   -- TCS_1 - 15/01/2019 - ACL
      pcdescriiva  IN  agentes.cdescriiva%TYPE,   -- TCS_1569B - ACL - 01/02/2019
      pdescricretenc IN  agentes.descricretenc%TYPE,  -- TCS_1569B - ACL - 01/02/2019
      pdescrifuente  IN  agentes.descrifuente%TYPE,  -- TCS_1569B - ACL - 01/02/2019
      pcdescriica IN  agentes.cdescriica%TYPE,  -- TCS_1569B - ACL - 01/02/2019
      pctipint IN agentes_comp.ctipint%TYPE,
      --BUG 41764-233736
      pmodifica IN NUMBER,
      -- fin bug 21425/109832 - 21/03/2012 - AMC
      pcagente_out OUT agentes.cagente%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(5000)
         := 'pcagente:' || pcagente || ' pcretenc:' || pcretenc || ' pctipiva:' || pctipiva
            || ' psperson:' || psperson || ' pccomisi:' || pccomisi || ' pcdesc:' || pcdesc
            || ' pctipage:' || pctipage || ' pcactivo:' || pcactivo || ' pcdomici:'
            || pcdomici || ' pcbancar:' || pcbancar || ' pncolegi:' || pncolegi
            || ' pfbajage:' || TO_CHAR(pfbajage, 'dd/mm/yyyy') || ' pctipban:' || pctipban
            || 'pfinivigcom:' || TO_CHAR(pfinivigcom, 'dd/mm/yyyy') || 'pffinvigcom:'
            || TO_CHAR(pffinvigcom, 'dd/mm/yyyy') || 'pfinivigdesc:'
            || TO_CHAR(pfinivigdesc, 'dd/mm/yyyy') || 'pffinvigdesc:'
            || TO_CHAR(pffinvigdesc, 'dd/mm/yyyy') || 'pcsobrecomisi:' || pcsobrecomisi
            || 'pfinivigsobrecom:' || TO_CHAR(pfinivigsobrecom, 'dd/mm/yyyy')
            || 'pffinvigsobrecom:' || TO_CHAR(pffinvigsobrecom, 'dd/mm/yyyy') || 'ptalias:'
            || ptalias || 'pcliquido:' || pcliquido || 'pccomisi_indirect:'
            || pccomisi_indirect || 'pfinivigcom_indirect:'
            || TO_CHAR(pfinivigcom_indirect, 'dd/mm/yyyy') || 'pffinvigcom_indirect:'
            || TO_CHAR(pffinvigcom_indirect, 'dd/mm/yyyy') || ' pctipmed:' || pctipmed
            || ' ptnomcom:' || ptnomcom || ' pcdomcom:' || pcdomcom || ' pctipretrib:'
            || pctipretrib || ' pcmotbaja:' || pcmotbaja || ' pcbloqueo:' || pcbloqueo
            || ' pnregdgs:' || pnregdgs || ' pfinsdgs:' || pfinsdgs || ' pcrebcontdgs:'
            || pcrebcontdgs || 'pmodifica: '|| pmodifica || ' pcoblccc:' || pcoblccc
            || 'pclaveinter: ' || pclaveinter || 'pcdescriiva: ' || pcdescriiva || 'pdescricretenc: ' || pdescricretenc   -- TCS_1 - 15/01/2018 - ACL
            || 'pdescrifuente: ' || pdescrifuente || 'pcdescriica: ' || pcdescriica  --TCS_1569B - ACL - 01/02/2019
			;
      vobject        VARCHAR2(200) := 'PAC_IAX_REDCOMERCIAL.f_set_agente';
      verror         NUMBER;
   BEGIN
      -- Bug 19169 - APD - 16/09/2011 - se aaden los nuevos campos de la tabla agentes y agentes_comp
      verror := pac_md_redcomercial.f_set_agente(pcagente, pcretenc, pctipiva, psperson,
                                                 pccomisi, pcdesc, pctipage, pcactivo,
                                                 pcdomici, pcbancar, pncolegi, pfbajage,
                                                 pctipban, pfinivigcom, pffinvigcom,
                                                 pfinivigdesc, pffinvigdesc, pcsobrecomisi,
                                                 pfinivigsobrecom, pffinvigsobrecom, ptalias,
                                                 pcliquido, pccomisi_indirect,
                                                 pfinivigcom_indirect, pffinvigcom_indirect,

                                                 -- bug 21425/109832 - 21/03/2012 - AMC
                                                 pctipmed, ptnomcom, pcdomcom, pctipretrib,
                                                 pcmotbaja, pcbloqueo, pnregdgs, pfinsdgs,
                                                 pcrebcontdgs, pcoblccc, pccodcon, pclaveinter, -- TCS_1 - 15/01/2018 - ACL
                                                 pcdescriiva, pdescricretenc, pdescrifuente, pcdescriica, pctipint,  -- TCS_1569B - ACL - 01/02/2019
                                                 -- Fi bug 21425/109832 - 21/03/2012 - AMC
                                                   --BUG 41764-233736
                                                 pmodifica,
                                                 pcagente_out, mensajes);
      vpasexec := 2;

      IF verror IS NULL
         OR verror != 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN verror;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_set_agente;

   /*************************************************************************
       f_set_agente_comp
         -- Bug 27949 Funcin creada a partir de f_set_agente
    *************************************************************************/
   FUNCTION f_set_agente_comp(
      pcagente IN agentes_comp.cagente%TYPE,
      pctipadn IN agentes_comp.ctipadn%TYPE,
      pcagedep IN agentes_comp.cagedep%TYPE,
      pctipint IN agentes_comp.ctipint%TYPE,
      pcageclave IN agentes_comp.cageclave%TYPE,
      pcofermercan IN agentes_comp.cofermercan%TYPE,
      pfrecepcontra IN agentes_comp.frecepcontra%TYPE,
      pcidoneidad IN agentes_comp.cidoneidad%TYPE,
      pccompani IN agentes_comp.ccompani%TYPE,
      pcofipropia IN agentes_comp.cofipropia%TYPE,
      pcclasif IN agentes_comp.cclasif%TYPE,
      pnplanpago IN agentes_comp.nplanpago%TYPE,
      pnnotaria IN agentes_comp.nnotaria%TYPE,
      pcprovin IN agentes_comp.cprovin%TYPE,
      pcpoblac IN agentes_comp.cpoblac%TYPE,
      pnescritura IN agentes_comp.nescritura%TYPE,
      pfaltasoc IN agentes_comp.faltasoc%TYPE,
      ptgerente IN agentes_comp.tgerente%TYPE,
      ptcamaracomercio IN agentes_comp.tcamaracomercio%TYPE,
      pagrupador IN agentes_comp.agrupador%TYPE,
      pcactividad IN agentes_comp.cactividad%TYPE,
      pctipoactiv IN agentes_comp.ctipoactiv%TYPE,
      ppretencion IN agentes_comp.pretencion%TYPE,
      pcincidencia IN agentes_comp.cincidencia%TYPE,
      pcrating IN agentes_comp.crating%TYPE,
      ptvaloracion IN agentes_comp.tvaloracion%TYPE,
      pcresolucion IN agentes_comp.cresolucion%TYPE,
      pffincredito IN agentes_comp.ffincredito%TYPE,
      pnlimcredito IN agentes_comp.nlimcredito%TYPE,
      ptcomentarios IN agentes_comp.tcomentarios%TYPE,
      --nuevos campos
      pfultrev IN agentes_comp.fultrev%TYPE,
      pfultckc IN agentes_comp.fultckc%TYPE,
      pctipbang IN agentes_comp.ctipbang%TYPE,
      pcbanges IN agentes_comp.cbanges%TYPE,
      pcclaneg IN agentes_comp.cclaneg%TYPE,
      pctipage_liquida IN agentes_comp.ctipage_liquida%TYPE,   -- BUG 31489 - FAL - 21/05/2014
      --
      piobjetivo IN agentes_comp.iobjetivo%TYPE,
      pibonifica IN agentes_comp.ibonifica%TYPE,
      ppcomextr IN agentes_comp.pcomextr%TYPE,
      pctipcal IN agentes_comp.ctipcal%TYPE,
      pcforcal IN agentes_comp.cforcal%TYPE,
      pcmespag IN agentes_comp.cmespag%TYPE,
      ppcomextrov IN agentes_comp.pcomextrov%TYPE,
      pppersisten IN agentes_comp.ppersisten%TYPE,
      ppcompers IN agentes_comp.pcompers%TYPE,
      pctipcalb IN agentes_comp.ctipcalb%TYPE,
      pcforcalb IN agentes_comp.cforcalb%TYPE,
      pcmespagb IN agentes_comp.cmespagb%TYPE,
      ppcombusi IN agentes_comp.pcombusi%TYPE,
      pilimiteb IN agentes_comp.ilimiteb%TYPE,
      pccexpide IN agentes_comp.cexpide%TYPE,
      --AAC_INI-CONF_379-20160927
      pcorteprod in number,
      --AAC_FI-CONF_379-20160927
      pcagente_out OUT agentes_comp.cagente%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(3000)
         := 'pcagente:' || pcagente || 'pctipadn:' || pctipadn || 'pcagedep:' || pcagedep
            || 'pctipint:' || pctipint || 'pcageclave:' || pcageclave || 'pcofermercan:'
            || pcofermercan || 'pfrecepcontra:' || pfrecepcontra || 'pcidoneidad:'
            || pcidoneidad || 'pccompani:' || pccompani || 'pcofipropia:' || pcofipropia
            || 'pcclasif:' || pcclasif || 'pnplanpago:' || pnplanpago || 'pnnotaria:'
            || pnnotaria || 'pcprovin:' || pcprovin || 'pcpoblac:' || pcpoblac
            || 'pnescritura:' || pnescritura || 'pfaltasoc:'
            || TO_CHAR(pfaltasoc, 'dd/mm/yyyy') || 'ptgerente:' || ptgerente
            || 'ptcamaracomercio:' || ptcamaracomercio || ' pagrupador:' || pagrupador
            || ' pcactividad:' || pcactividad || ' pctipoactiv:' || pcactividad
            || ' ppretencion:' || ppretencion || ' pcincidencia:' || pcincidencia
            || ' pcrating:' || pcrating || ' ptvaloracion:' || ptvaloracion
            || ' pcresolucion:' || pcresolucion || ' pffincredito:' || pffincredito
            || ' pnlimcredito:' || pnlimcredito || ' ptcomentarios:' || ptcomentarios
            || ' pfultrev:' || pfultrev || ' pfultckc:' || pfultckc || ' pctipbang:'
            || pctipbang || ' pcbanges:' || pcbanges || ' pcclaneg:' || pcclaneg
             --AAC_INI-CONF_379-20160927
            || 'pcorteprod: '|| pcorteprod

            --AAC_FI-CONF_379-20160927
			;
      vobject        VARCHAR2(200) := 'PAC_IAX_REDCOMERCIAL.f_set_agente_comp';
      verror         NUMBER;
   BEGIN
      -- Bug 19169 - APD - 16/09/2011 - se aaden los nuevos campos de la tabla agentes y agentes_comp
      verror :=
         pac_md_redcomercial.f_set_agente_comp(pcagente, pctipadn, pcagedep, pctipint,
                                               pcageclave, pcofermercan, pfrecepcontra,
                                               pcidoneidad, pccompani, pcofipropia, pcclasif,
                                               pnplanpago, pnnotaria, pcprovin, pcpoblac,
                                               pnescritura, pfaltasoc, ptgerente,
                                               ptcamaracomercio, pagrupador, pcactividad,
                                               pctipoactiv, ppretencion, pcincidencia,
                                               pcrating, ptvaloracion, pcresolucion,
                                               pffincredito, pnlimcredito, ptcomentarios,
                                               pfultrev, pfultckc, pctipbang, pcbanges,
                                               pcclaneg, pctipage_liquida, piobjetivo,
                                               pibonifica, ppcomextr, pctipcal, pcforcal,
                                               pcmespag, ppcomextrov, pppersisten, ppcompers,   -- BUG 31489 - FAL - 21/05/2014
                                               pctipcalb, pcforcalb, pcmespagb, ppcombusi,
                                               pilimiteb, pccexpide,
                                               --AAC_INI-CONF_379-20160927
                                               pcorteprod,
                                               --AAC_FI-CONF_379-20160927
                                               pcagente_out, mensajes);
      vpasexec := 2;

      IF verror IS NULL
         OR verror != 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN verror;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_set_agente_comp;

   FUNCTION f_set_contrato(
      pcempres IN NUMBER,
      pcagente IN NUMBER,
      pncontrato IN NUMBER,
      pffircon IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'pcempres:' || pcempres || ' pcagente:' || pcagente || ' pncontrato:'
            || pncontrato || ' pffircon:' || TO_CHAR(pffircon, 'dd/mm/yyyy');
      vobject        VARCHAR2(200) := 'PAC_IAX_REDCOMERCIAL.f_set_contrato';
      verror         NUMBER;
   BEGIN
      verror := pac_md_redcomercial.f_set_contrato(pcempres, pcagente, pncontrato, pffircon,
                                                   mensajes);
      vpasexec := 2;

      IF verror IS NULL
         OR verror != 0 THEN
         /*
         if verror is not null then
            PAC_IOBJ_MENSAJES.CREA_NUEVO_MENSAJE(mensajes, 1, verror);
         end if;
         */
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN verror;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_set_contrato;

   -- Bug 18946 - APD - 16/11/2011 - se aaden los campos de vision por poliza
   -- cpolvisio, cpolnivel
/*************************************************************************
      Inserta la redcomercial
      param in pcempres  : cdigo de la empresa
      param in pcagente  : cdigo del agente
      param in pfecha    : fecha
      param in pcpadre   : codigo del padre
      param in pccomindt :
      param in pcprevisio : Cdigo del agente que nos indica el nivel de visin de personas
      param in pcprenivel : Nivel visin personas
      return             : 0 todo correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_set_redcomercial(
      pcempres IN NUMBER,
      pcagente IN NUMBER,
      pfecha IN DATE,
      pcpadre IN NUMBER,
      pccomindt IN NUMBER,
      pcprevisio IN NUMBER,
      pcprenivel IN NUMBER,
      pcageind IN NUMBER,   -- Bug : 19586 - 20/11/2011 - JMC
      pcpolvisio IN NUMBER,
      pcpolnivel IN NUMBER,
      pcenlace IN NUMBER,   --Bug 21672 - JTS - 29/05/2012
      pcdomiciage IN NUMBER, --TCS-7 21/02/2019 AP -- IAXIS-2415 27/02/2019
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'pcempres:' || pcempres || ' pcagente:' || pcagente || ' pfecha:'
            || TO_CHAR(pfecha, 'dd/mm/yyyy') || ' pcpadre:' || pcpadre || ' pccomindt:'
            || pccomindt || ' pcprevisio:' || pcprevisio || ' pcprenivel:' || pcprenivel
            || ' pcpolvisio:' || pcpolvisio || ' pcpolnivel:' || pcpolnivel || ' pcenlace:'
            || pcenlace|| ' pcdomiciage:' || pcdomiciage; -- IAXIS-2415 27/02/2019
      vobject        VARCHAR2(200) := 'PAC_IAX_REDCOMERCIAL.f_set_redcomercial';
      verror         NUMBER;
   BEGIN
      -- Bug 18946 - APD - 16/11/2011 - se aaden los campos de vision por poliza
      -- cpolvisio, cpolnivel
      verror :=
         pac_md_redcomercial.f_set_redcomercial(pcempres, pcagente, pfecha, pcpadre,
                                                pccomindt, pcprevisio, pcprenivel, pcageind,   -- Bug : 19586 - 20/11/2011 - JMC
                                                pcpolvisio, pcpolnivel, pcenlace, pcdomiciage, mensajes); --TCS-7 21/02/2019 AP -- IAXIS-2415 27/02/2019
      vpasexec := 2;

      IF verror IS NULL
         OR verror != 0 THEN
         /*
         if verror is not null then
            PAC_IOBJ_MENSAJES.CREA_NUEVO_MENSAJE(mensajes, 1, verror);
         end if;
         */
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN verror;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_set_redcomercial;

   /*************************************************************************
           Funcin que nos devolver lista pliza de un agente Return: Sys_Refcursor

           Bug 22313/115161 - 23/05/2012 - AMC
       *************************************************************************/
   FUNCTION f_get_polagente(
      pempresa IN NUMBER,
      pcagente IN NUMBER,
      pnpoliza IN NUMBER,
      pcpolcia IN VARCHAR2,
      psseguro IN NUMBER,
      pnnumidetom IN VARCHAR2,
      pspersontom IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      -- Bug 0013392 - 23/03/2010 - JMF
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := ' pempresa:' || pempresa || ' pcagente:' || pcagente;
      vobject        VARCHAR2(200) := 'PAC_IAX_REDCOMERCIAL.f_get_polagente';
      cur            sys_refcursor;
   BEGIN
      IF pempresa IS NULL
         OR pcagente IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 105308);
         RAISE e_param_error;
      END IF;

      cur :=
         pac_md_redcomercial.f_get_polagente(pempresa, pcagente, pnpoliza, pcpolcia, psseguro,
                                             pnnumidetom, pspersontom, pcramo, psproduc,   --Bug 22313/115161 - 23/05/2012 - AMC
                                             mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_polagente;

   /*************************************************************************
           Funcin que nos devolver lista recibos de un agente
           condicionada al estado del recibo (pendiente, gestion, etc).
           Return: Sys_Refcursor

            --Bug 22313/115161 - 23/05/2012 - AMC
       *************************************************************************/
   FUNCTION f_get_recagente(
      pempresa IN NUMBER,
      pcagente IN NUMBER,
      pcestrec IN NUMBER,
      pnpoliza IN NUMBER,
      pcpolcia IN VARCHAR2,
      pnrecibo IN NUMBER,
      pcreccia IN VARCHAR2,
      psseguro IN NUMBER,
      pnnumidetom IN VARCHAR2,
      pspersontom IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      -- Bug 0013392 - 23/03/2010 - JMF
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
           := ' pempresa:' || pempresa || ' pcagente:' || pcagente || ' pcestrec:' || pcestrec;
      vobject        VARCHAR2(200) := 'PAC_IAX_REDCOMERCIAL.f_get_recagente';
      cur            sys_refcursor;
   BEGIN
      IF pempresa IS NULL
         OR pcagente IS NULL
         OR pcestrec IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 105308);
         RAISE e_param_error;
      END IF;

      cur := pac_md_redcomercial.f_get_recagente(pempresa, pcagente, pcestrec, pnpoliza,
                                                 pcpolcia, pnrecibo, pcreccia, psseguro,
                                                 pnnumidetom, pspersontom, pcramo, psproduc,
                                                 mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_recagente;

   /*************************************************************************
      Devuelve el numero de agente dependiendo del tipo de agente
      param in pcempres  : cdigo de la empresa
      param in pctipage  : cdigo del tipo de agente
      param out pcontador : Numero de contador
      param out mensajes : Mensajes de error

      return             : 0 - Ok , 1 Ko

      bug 19049/89656 - 14/07/2011 - AMC
   *************************************************************************/
   FUNCTION f_get_contador_agente(
      pcempres IN NUMBER,
      pctipage IN NUMBER,
      pcontador OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_iax_redcomercial.f_get_contador_agente';
      vparam         VARCHAR2(2000)
                           := 'parmetros - pcempres:' || pcempres || ' pctipage:' || pctipage;
      vpasexec       NUMBER(5) := 1;
      verror         NUMBER;
   BEGIN
      IF pctipage IS NULL THEN
         RAISE e_param_error;
      END IF;

      verror := pac_md_redcomercial.f_get_contador_agente(pcempres, pctipage, pcontador,
                                                          mensajes);

      IF verror <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN verror;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_contador_agente;

   /*************************************************************************
    Funcin que recupera el objeto OB_IAX_PRODPARTICIPACION_AGENTE.
    Productos/actividad que contaran en la participacion de utilidades para el agente
      param in pcagente  : Cdigo del agente
      param in psproduc  : Cdigo del producto
      param in pcactivi : Cdigo de la actividad
      param out mensajes : Mensajes de error
    Return: OB_IAX_PRODPARTICIPACION_AGENTE
   *************************************************************************/
   -- Bug 19169 - APD - 16/09/2011 - se crea la funcion
   FUNCTION f_get_detprodparticipacion(
      pcagente IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN ob_iax_prodparticipacion_age IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
            := 'pcagente:' || pcagente || ' psproduc:' || psproduc || ' pcactivi:' || pcactivi;
      vobject        VARCHAR2(200) := 'PAC_IAX_REDCOMERCIAL.F_get_detprodparticipacion';
      prodparticipacion ob_iax_prodparticipacion_age;
   BEGIN
      prodparticipacion := pac_md_redcomercial.f_get_detprodparticipacion(pcagente, psproduc,
                                                                          pcactivi, mensajes);
      RETURN prodparticipacion;
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
   END f_get_detprodparticipacion;

   /*************************************************************************
    Funcin que recupera el objeto OB_IAX_SOPORTEARP_AGENTE.
    Informacion del importe que se le asigna a algunas ADN's por dar soporte administrativo
      param in pcagente  : Cdigo del agente
      param in pfinivig  : Fecha de inicio vigencia
      param out mensajes : Mensajes de error
    Return: OB_IAX_SOPORTEARP_AGENTE
   *************************************************************************/
   -- Bug 19169 - APD - 16/09/2011 - se crea la funcion
   FUNCTION f_get_detsoportearp(
      pcagente IN NUMBER,
      pfinivig IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN ob_iax_soportearp_agente IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'pcagente:' || pcagente || ' pfinivig:' || pfinivig;
      vobject        VARCHAR2(200) := 'PAC_IAX_REDCOMERCIAL.F_get_detsoportearp';
      soportearp     ob_iax_soportearp_agente;
   BEGIN
      soportearp := pac_md_redcomercial.f_get_detsoportearp(pcagente, pfinivig, mensajes);
      RETURN soportearp;
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
   END f_get_detsoportearp;

   /*************************************************************************
    Funcin que recupera el objeto OB_IAX_SUBVENCION_AGENTE.
    Informacion de la cantidad de subvencion que se le asigna al Intermediario o ADN
      param in pcagente  : Cdigo del agente
      param in psproduc  : Cdigo del producto
      param in pcactivi : Cdigo de la actividad
      param out mensajes : Mensajes de error
    Return: OB_IAX_SUBVENCION_AGENTE
   *************************************************************************/
   -- Bug 19169 - APD - 16/09/2011 - se crea la funcion
   FUNCTION f_get_detsubvencion(
      pcagente IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN ob_iax_subvencion_agente IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
            := 'pcagente:' || pcagente || ' psproduc:' || psproduc || ' pcactivi:' || pcactivi;
      vobject        VARCHAR2(200) := 'PAC_IAX_REDCOMERCIAL.F_get_detsubvencion';
      subvencion     ob_iax_subvencion_agente;
   BEGIN
      subvencion := pac_md_redcomercial.f_get_detsubvencion(pcagente, psproduc, pcactivi,
                                                            mensajes);
      RETURN subvencion;
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
   END f_get_detsubvencion;

/*************************************************************************
      Inserta un valor del producto de participacin de utilidades para el agente
      param in pcagente  : cdigo del agente
      param in psproduc    : Cdigo del producto
      param in pcactivi   : Cdigo de la actividad
      return             : 0 todo correcto
                           1 ha habido un error
   *************************************************************************/
-- Bug 19169 - APD - 16/09/2011 - se crea la funcion
   FUNCTION f_set_prodparticipacion(
      pcagente IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
           := ' pcagente:' || pcagente || ' psproduc:' || psproduc || ' pcactivi:' || pcactivi;
      vobject        VARCHAR2(200) := 'PAC_IAX_REDCOMERCIAL.f_set_prodparticipacion';
      verror         NUMBER;
   BEGIN
      verror := pac_md_redcomercial.f_set_prodparticipacion(pcagente, psproduc, pcactivi,
                                                            mensajes);
      vpasexec := 2;

      IF verror IS NULL
         OR verror != 0 THEN
         /*
         if verror is not null then
            PAC_IOBJ_MENSAJES.CREA_NUEVO_MENSAJE(mensajes, 1, verror);
         end if;
         */
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN verror;
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
   END f_set_prodparticipacion;

/*************************************************************************
      Inserta un valor del Soporte por ARP
      param in pcmodo ; 1.-Alta; 2.-Modif
      param in pcagente  : cdigo del agente
      param in piimporte    : Importe que se le asigna a algunas ADN's por dar soporte administrativo
      param in pfinivig   : Fecha inicio vigencia
      param in pffinvig   : Fecha fin vigencia
      return             : 0 todo correcto
                           1 ha habido un error
   *************************************************************************/
-- Bug 19169 - APD - 16/09/2011 - se crea la funcion
   FUNCTION f_set_soportearp(
      pcmodo IN NUMBER,
      pcagente IN NUMBER,
      piimporte IN NUMBER,
      pfinivig IN DATE,
      pffinvig IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := ' pcmodo:' || pcmodo || ' pcagente:' || pcagente || ' piimporte:' || piimporte
            || ' pfinivig:' || pfinivig || ' pffinvig:' || pffinvig;
      vobject        VARCHAR2(200) := 'PAC_IAX_REDCOMERCIAL.f_set_soportearp';
      verror         NUMBER;
   BEGIN
      verror := pac_md_redcomercial.f_set_soportearp(pcmodo, pcagente, piimporte, pfinivig,
                                                     pffinvig, mensajes);
      vpasexec := 2;

      IF verror IS NULL
         OR verror != 0 THEN
         /*
         if verror is not null then
            PAC_IOBJ_MENSAJES.CREA_NUEVO_MENSAJE(mensajes, 1, verror);
         end if;
         */
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN verror;
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
   END f_set_soportearp;

/*************************************************************************
      Inserta una subvencin
      param in pcmodo ; 1.-Alta; 2.-Modif
      param in pcagente  : cdigo del agente
      param in psproduc    : Cdigo del producto
      param in pcactivi   : Cdigo de la actividad
      param in piimporte   : Importe de la subvencin
      return             : 0 todo correcto
                           1 ha habido un error
   *************************************************************************/
-- Bug 19169 - APD - 16/09/2011 - se crea la funcion
   FUNCTION f_set_subvencion(
      pcmodo IN NUMBER,
      pcagente IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      piimporte IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := ' pcmodo:' || pcmodo || ' pcagente:' || pcagente || ' psproduc:' || psproduc
            || ' pcactivi:' || pcactivi || ' piimporte:' || piimporte;
      vobject        VARCHAR2(200) := 'PAC_IAX_REDCOMERCIAL.f_set_subvencion';
      verror         NUMBER;
   BEGIN
      verror := pac_md_redcomercial.f_set_subvencion(pcmodo, pcagente, psproduc, pcactivi,
                                                     piimporte, mensajes);
      vpasexec := 2;

      IF verror IS NULL
         OR verror != 0 THEN
         /*
         if verror is not null then
            PAC_IOBJ_MENSAJES.CREA_NUEVO_MENSAJE(mensajes, 1, verror);
         end if;
         */
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN verror;
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
   END f_set_subvencion;

/*************************************************************************
      Elimina un registro del producto de participacin de utilidades para el agente
      param in pcagente  : cdigo del agente
      param in psproduc    : Cdigo del producto
      param in pcactivi   : Cdigo de la actividad
      return             : 0 todo correcto
                           1 ha habido un error
   *************************************************************************/
-- Bug 19169 - APD - 16/09/2011 - se crea la funcion
   FUNCTION f_del_prodparticipacion(
      pcagente IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
           := ' pcagente:' || pcagente || ' psproduc:' || psproduc || ' pcactivi:' || pcactivi;
      vobject        VARCHAR2(200) := 'PAC_IAX_REDCOMERCIAL.f_del_prodparticipacion';
      verror         NUMBER;
   BEGIN
      verror := pac_md_redcomercial.f_del_prodparticipacion(pcagente, psproduc, pcactivi,
                                                            mensajes);
      vpasexec := 2;

      IF verror IS NULL
         OR verror != 0 THEN
         /*
         if verror is not null then
            PAC_IOBJ_MENSAJES.CREA_NUEVO_MENSAJE(mensajes, 1, verror);
         end if;
         */
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN verror;
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
   END f_del_prodparticipacion;

/*************************************************************************
      Elimina un registro del Soporte por ARP
      param in pcagente  : cdigo del agente
      param in pfinivig    : Fecha inicio vigencia
      return             : 0 todo correcto
                           1 ha habido un error
   *************************************************************************/
-- Bug 19169 - APD - 16/09/2011 - se crea la funcion
   FUNCTION f_del_soportearp(pcagente IN NUMBER, pfinivig IN DATE, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := ' pcagente:' || pcagente || ' pfinivig:' || pfinivig;
      vobject        VARCHAR2(200) := 'PAC_IAX_REDCOMERCIAL.f_del_soportearp';
      verror         NUMBER;
   BEGIN
      verror := pac_md_redcomercial.f_del_soportearp(pcagente, pfinivig, mensajes);
      vpasexec := 2;

      IF verror IS NULL
         OR verror != 0 THEN
         /*
         if verror is not null then
            PAC_IOBJ_MENSAJES.CREA_NUEVO_MENSAJE(mensajes, 1, verror);
         end if;
         */
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN verror;
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
   END f_del_soportearp;

/*************************************************************************
      Elimina un registro de una subvencin
      param in pcagente  : cdigo del agente
      param in psproduc    : Cdigo del producto
      param in pcactivi    : Cdigo de la actividad
      return             : 0 todo correcto
                           1 ha habido un error
   *************************************************************************/
-- Bug 19169 - APD - 16/09/2011 - se crea la funcion
   FUNCTION f_del_subvencion(
      pcagente IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
           := ' pcagente:' || pcagente || ' psproduc:' || psproduc || ' pcactivi:' || pcactivi;
      vobject        VARCHAR2(200) := 'PAC_IAX_REDCOMERCIAL.f_del_subvencion';
      verror         NUMBER;
   BEGIN
      verror := pac_md_redcomercial.f_del_subvencion(pcagente, psproduc, pcactivi, mensajes);
      vpasexec := 2;

      IF verror IS NULL
         OR verror != 0 THEN
         /*
         if verror is not null then
            PAC_IOBJ_MENSAJES.CREA_NUEVO_MENSAJE(mensajes, 1, verror);
         end if;
         */
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN verror;
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
   END f_del_subvencion;

   /*************************************************************************
      Funcin que nos devolver el histrico de las vigencias de las comisiones/sobrecomisiones del agente
      param in pcagente  : cdigo del agente
      param in pctipo    : Tipo de la comision
      param in pccomind  : Indica si la comision es indirecta (1) o no (0)
      Return: Sys_Refcursor
    *************************************************************************/
-- Bug 19169 - APD - 16/09/2011 - se crea la funcion
   FUNCTION f_get_comisionvig_agente(
      pcagente IN NUMBER,
      pctipo IN NUMBER,
      pccomind IN NUMBER,   -- Bug 20999 - APD - 26/01/2012
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      -- Bug 0013392 - 23/03/2010 - JMF
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
               := ' pcagente:' || pcagente || ' pctipo:' || pctipo || ' pccomind:' || pccomind;
      vobject        VARCHAR2(200) := 'PAC_IAX_REDCOMERCIAL.f_get_comisionvig_agente';
      cur            sys_refcursor;
   BEGIN
      IF pcagente IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 105308);
         RAISE e_param_error;
      END IF;

      cur := pac_md_redcomercial.f_get_comisionvig_agente(pcagente, pctipo, pccomind, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_comisionvig_agente;

   /*************************************************************************
      Funcin que nos devolver el histrico de las vigencias de las comisiones/sobrecomisiones del agente
      param in pcagente  : cdigo del agente
      param in pctipo    : Tipo de la comision
      Return: Sys_Refcursor
    *************************************************************************/
-- Bug 19169 - APD - 16/09/2011 - se crea la funcion
   FUNCTION f_get_descuentovig_agente(
      pcagente IN NUMBER,
      pctipo IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      -- Bug 0013392 - 23/03/2010 - JMF
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := ' pcagente:' || pcagente || ' pctipo:' || pctipo;
      vobject        VARCHAR2(200) := 'PAC_IAX_REDCOMERCIAL.f_get_descuentovig_agente';
      cur            sys_refcursor;
   BEGIN
      IF pcagente IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 105308);
         RAISE e_param_error;
      END IF;

      cur := pac_md_redcomercial.f_get_descuentovig_agente(pcagente, pctipo, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_descuentovig_agente;

-- Bug 19169 - APD - 16/09/2011 - se crea la funcion
   FUNCTION ff_desagente(
      pcagente IN NUMBER,
      pformato IN NUMBER DEFAULT 0,
      mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := ' pcagente:' || pcagente || ' pformato:' || pformato;
      vobject        VARCHAR2(200) := 'PAC_IAX_REDCOMERCIAL.ff_desagente';
      verror         NUMBER;
      vdesagente     VARCHAR2(200);
   BEGIN
      vdesagente := pac_md_redcomercial.ff_desagente(pcagente, pac_md_common.f_get_cxtidioma,
                                                     pformato, mensajes);
      vpasexec := 2;

      IF vdesagente IS NULL THEN
         /*
         if verror is not null then
            PAC_IOBJ_MENSAJES.CREA_NUEVO_MENSAJE(mensajes, 1, verror);
         end if;
         */
         RAISE e_object_error;
      END IF;

      RETURN vdesagente;
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
   END ff_desagente;

-- Bug 20287 - APD - 05/12/2011 - se crea la funcion
   FUNCTION f_traspasar_subvencion(
      pcagente IN NUMBER,
      pnplanpago IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
                                   := ' pcagente:' || pcagente || ' pnplanpago:' || pnplanpago;
      vobject        VARCHAR2(200) := 'PAC_IAX_REDCOMERCIAL.f_traspasar_subvencion';
      verror         NUMBER;
   BEGIN
      verror := pac_md_redcomercial.f_traspasar_subvencion(pcagente, pnplanpago, mensajes);
      vpasexec := 2;

      IF verror IS NULL
         OR verror != 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN verror;
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
   END f_traspasar_subvencion;

   /*************************************************************************
     Funcin que nos devolver los contactos de un agente
     param in pcagente  : cdigo del agente
     Return: Sys_Refcursor

     Bug 21450/108261 - 24/02/2012 - AMC
   *************************************************************************/
   FUNCTION f_get_contactosage(pcagente IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'pcagente:' || pcagente;
      vobject        VARCHAR2(200) := 'PAC_IAX_REDCOMERCIAL.f_get_contactosage';
      verror         NUMBER;
      vquery         VARCHAR2(2000);
      cur            sys_refcursor;
   BEGIN
      IF pcagente IS NULL THEN
         RAISE e_param_error;
      END IF;

      cur := pac_md_redcomercial.f_get_contactosage(pcagente, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_contactosage;

   /*************************************************************************
     Funcin que nos devolver un contacto del agente
     param in pcagente : cdigo del agente
     param in pnorden  : n orden
     Return: ob_iax_age_contactos

     Bug 21450/108261 - 24/02/2012 - AMC
    *************************************************************************/
   FUNCTION f_get_contactoage(
      pcagente IN NUMBER,
      pnorden IN NUMBER,
      pcontacto OUT ob_iax_age_contactos,
      mensajes OUT t_iax_mensajes)
      RETURN ob_iax_age_contactos IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'pcagente:' || pcagente || ' pnorden:' || pnorden;
      vobject        VARCHAR2(200) := 'PAC_IAX_REDCOMERCIAL.f_get_contactoage';
      contacto       ob_iax_age_contactos;
      vnumerr        NUMBER;
   BEGIN
      IF pcagente IS NULL
         OR pnorden IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_redcomercial.f_get_contactoage(pcagente, pnorden, pcontacto, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN contacto;
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
   END f_get_contactoage;

   /*************************************************************************
    FUNCTION f_set_age_contacto
    Funcion que guarda el contacto de un agente
    param in pcagente   : Cdigo agente
    param in pctipo     : Cdigo del tipo de contacto
    param in pnorden    : N orden
    param in pnombre    : Nombre del contacto
    param in pcargo     : Cdigo del cargo
    param in piddomici  : Cdigo del domicilio
    param in ptelefono  : Telefono
    param in ptelefono2 : Telefono 2
    param in pfax       : Fax
    param in pemail     : Email
    return             : 0 - ok - Codi error

    Bug 21450/108261 - 27/02/2012 - AMC
   *************************************************************************/
   FUNCTION f_set_age_contacto(
      pcagente IN NUMBER,
      pctipo IN NUMBER,
      pnorden IN NUMBER,
      pnombre IN VARCHAR2,
      pcargo IN VARCHAR2,
      piddomici IN NUMBER,
      ptelefono IN NUMBER,
      ptelefono2 IN NUMBER,
      pfax IN NUMBER,
      pweb IN VARCHAR2,
      pemail IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'pcagente:' || pcagente || ' pnorden:' || pnorden || ' pctipo:' || pctipo
            || ' pnombre:' || pnombre || ' pcargo:' || pcargo || 'piddomici:' || piddomici
            || ' ptelefono:' || ptelefono || ' ptelefono2:' || ptelefono2 || ' pfax:' || pfax
            || ' pweb:' || pweb || ' pemail:' || pemail;
      vobject        VARCHAR2(200) := 'PAC_IAX_REDCOMERCIAL.f_set_age_contacto';
      vnumerr        NUMBER;
   BEGIN
      IF pcagente IS NULL
         OR pctipo IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_redcomercial.f_set_age_contacto(pcagente, pctipo, pnorden, pnombre,
                                                        pcargo, piddomici, ptelefono,
                                                        ptelefono2, pfax, pweb, pemail,
                                                        mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
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
   END f_set_age_contacto;

   /*************************************************************************
    FUNCTION f_del_age_contacto
    Funcion que borra el contacto de un agente
    param in pcagente   : Cdigo agente
    param in pnorden    : N orden
    return             : 0 - ok - Codi error

    Bug 21450/108261 - 27/02/2012 - AMC
   *************************************************************************/
   FUNCTION f_del_age_contacto(
      pcagente IN NUMBER,
      pnorden IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'pcagente:' || pcagente || ' pnorden:' || pnorden;
      vobject        VARCHAR2(200) := 'PAC_IAX_REDCOMERCIAL.f_del_age_contacto';
      vnumerr        NUMBER;
   BEGIN
      IF pcagente IS NULL
         OR pnorden IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_redcomercial.f_del_age_contacto(pcagente, pnorden, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
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
   END f_del_age_contacto;

    /*************************************************************************
     Funcin que inserta o actualiza los datos de un documento asociado a un agente
     param in pcagente   : Cdigo agente
     param in pfcaduca   : Fecha de caducidad
     param in ptobserva  : Observaciones
     param in piddocgedox : Identificador del documento
     param in ptamano : Tamao del documento

     Bug 21543/108711 - AMC - 02/03/2012
   *************************************************************************/
   FUNCTION f_set_docagente(
      pcagente IN NUMBER,
      pfcaduca IN DATE,
      ptobserva IN VARCHAR2,
      ptfilename IN VARCHAR2,
      piddocgedox IN NUMBER,
      ptamano IN VARCHAR2,
      ptdesc IN VARCHAR2 DEFAULT NULL,
      pidcat IN NUMBER DEFAULT NULL,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parmetros - pcagente: ' || pcagente || ' - pfcaduca: '
            || TO_CHAR(pfcaduca, 'DD/MM/YYYY') || ' - ptobserva: ' || ptobserva
            || ' - ptfilename: ' || ptfilename || ' - piddocgedox: ' || piddocgedox
            || ' - ptdesc: ' || ptdesc || ' - pidcat: ' || pidcat;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_set_docpersona';
      viddocgedox    NUMBER;
      vtamano        VARCHAR2(50);
   BEGIN
      IF pcagente IS NULL THEN
         RAISE e_param_error;
      END IF;

      viddocgedox := piddocgedox;

      IF viddocgedox IS NOT NULL THEN
         vnumerr := pac_md_redcomercial.f_set_docagente(pcagente, pfcaduca, ptobserva,
                                                        viddocgedox, ptamano, mensajes);
      ELSE
         vnumerr := pac_md_gedox.f_set_documagegedox(pcagente,
                                                     pac_md_common.f_get_cxtusuario(),
                                                     pfcaduca, ptobserva, ptamano, ptfilename,
                                                     viddocgedox, ptdesc, pidcat, mensajes);

         IF vnumerr <> 0 THEN
            RAISE e_object_error;
         END IF;

         IF viddocgedox IS NOT NULL THEN
            vnumerr := pac_md_gedox.f_get_tamanofit(viddocgedox, vtamano, mensajes);

            IF vnumerr <> 0 THEN
               RAISE e_object_error;
            END IF;
         END IF;

         vnumerr := pac_md_redcomercial.f_set_docagente(pcagente, pfcaduca, ptobserva,
                                                        viddocgedox, vtamano, mensajes);

         IF vnumerr <> 0 THEN
            RAISE e_object_error;
         END IF;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_docagente;

   /*************************************************************************
       FUNCTION funcin que recupera la informacin de los datos de un documento asociado al agente
       param in pcagente    : Agente
       param in piddocgedox  : documento gedox
       pobdocpersona out ob_iax_docagente : Objeto de documentos de agentes
       return           : cdigo de error

       Bug 21543/108711 - AMC - 02/03/2012
    *************************************************************************/
   FUNCTION f_get_docagente(
      pcagente IN NUMBER,
      piddocgedox IN NUMBER,
      pobdocagente OUT ob_iax_docagente,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      cpais          NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                := 'parmetros - pcagente = ' || pcagente || ' piddocgedox = ' || piddocgedox;
      vobject        VARCHAR2(200) := 'PAC_IAX_REDCOMERCIAL.f_get_docagente';
   BEGIN
      IF pcagente IS NULL
         OR piddocgedox IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_redcomercial.f_get_docagente(pcagente, piddocgedox, pobdocagente,
                                                     mensajes);

      IF vnumerr <> 0 THEN
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
   END f_get_docagente;

     /*************************************************************************
      FUNCTION funcin que recupera los documentos asociados al agente
      param in pcagente    : Agente
      pobdocagente out t_iax_docagente : Objeto de documentos de agentes
      return           : cdigo de error

      Bug 21543/108711 - AMC - 02/03/2012
   *************************************************************************/
   FUNCTION f_get_documentacion(
      pcagente IN NUMBER,
      ptdocagente OUT t_iax_docagente,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000) := 'parmetros - pcagente = ' || pcagente;
      vobject        VARCHAR2(200) := 'PAC_IAX_REDCOMERCIAL.f_get_documentacion';
   BEGIN
      IF pcagente IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_redcomercial.f_get_documentacion(pcagente, ptdocagente, mensajes);

      IF vnumerr <> 0 THEN
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
   END f_get_documentacion;

   FUNCTION f_get_niveles(pcempres IN NUMBER, pcidioma IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'pcempres:' || pcempres || ', pcidioma:' || pcidioma;
      vobject        VARCHAR2(200) := 'PAC_IAX_REDCOMERCIAL.f_get_niveles';
      cur            sys_refcursor;
   BEGIN
      cur := pac_md_redcomercial.f_get_niveles(pcempres, pcidioma, mensajes);
      RETURN cur;
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
   END f_get_niveles;

   FUNCTION f_busca_padre(
      pcempres IN NUMBER,
      pcagente IN NUMBER,
      pctipage IN NUMBER,
      pfbusca IN DATE,
      ptagente OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
          := 'pcempres:' || pcempres || ', pcagente:' || pcagente || ', pctipage:' || pctipage;
      vobject        VARCHAR2(200) := 'PAC_MD_REDCOMERCIAL.f_busca_padre';
      vcagente       NUMBER;
   BEGIN
      vcagente := pac_md_redcomercial.f_busca_padre(pcempres, pcagente, pctipage, pfbusca,
                                                    ptagente, mensajes);
      RETURN vcagente;
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
   END f_busca_padre;

   /******************************************************************************
    FUNCION: f_get_retencion
    Funcion que devielve el tipo de retenci??egun la letra del cif.
    Param in psperson
    Param out pcretenc
    Param out mensajes
    Retorno 0- ok 1-ko

    Bug 24514/128686 - 15/11/2012 - AMC
   ******************************************************************************/
   FUNCTION f_get_retencion(
      psperson IN NUMBER,
      pcretenc OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := 'psperson:' || psperson;
      vobject        VARCHAR2(200) := 'PAC_IAX_REDCOMERCIAL.f_get_retencion';
      vnumerr        NUMBER;
   BEGIN
      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_redcomercial.f_get_retencion(psperson, pcretenc, mensajes);
      RETURN vnumerr;
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
   END f_get_retencion;

/******************************************************************************
    FUNCION: F_GET_CORREO
    recuperarn datos tambin de MENSAJES_CORREO y DESMENSAJE_CORREO
    Param in pcagente
    Param out mensajes
    Retorno 0- ok 1-ko

   ******************************************************************************/
   FUNCTION f_get_correo(
      pcagente IN NUMBER,
      ptcorreo OUT agentes_comp.tcorreo%TYPE,
      pcenvcor OUT agentes_comp.cenvcorreo%TYPE,
      pmsjcorreo OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'pcagente:' || pcagente;
      vobject        VARCHAR2(200) := 'PAC_IAX_REDCOMERCIAL.f_get_correo';
      vcagente       NUMBER;
   BEGIN
      vcagente := pac_md_redcomercial.f_get_correo(pcagente, ptcorreo, pcenvcor, pmsjcorreo,
                                                   mensajes);

      IF vcagente = 0 THEN
         RETURN 0;
      ELSE
         RETURN 1;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END;

    /******************************************************************************
    FUNCION: F_SET_CORREO
    recuperarn datos tambin de MENSAJES_CORREO y DESMENSAJE_CORREO
    Param in pcagente
    Param out mensajes
    Retorno 0- ok 1-ko

   ******************************************************************************/
   FUNCTION f_set_correo(
      pcagente IN NUMBER,
      ptcorreo IN agentes_comp.tcorreo%TYPE,
      pcenvcor IN agentes_comp.cenvcorreo%TYPE,
      correo IN VARCHAR2,
      envio IN NUMBER,
      codigo IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'pcagente:' || pcagente;
      vobject        VARCHAR2(200) := 'PAC_IAX_REDCOMERCIAL.f_set_correo';
      vcagente       NUMBER;
   BEGIN
      vcagente := pac_md_redcomercial.f_set_correo(pcagente, ptcorreo, pcenvcor, correo,
                                                   envio, codigo, mensajes);

      IF vcagente = 0 THEN
         RETURN 0;
      ELSE
         RETURN 1;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END;
   
   --Inicio tarefa 4077 - Borduchi
   FUNCTION f_get_users(
       sperson IN number,
       idioma IN NUMBER,
       mensajes OUT t_iax_mensajes)
       RETURN sys_refcursor
       IS
        vpasexec       NUMBER(8) := 1;
        vparam         VARCHAR2(2000) := 'sperson:' || sperson || ' idioma:' || idioma;
        vobject        VARCHAR2(200) := 'PAC_IAX_REDCOMERCIAL.f_get_users';
        list_users sys_refcursor;
    BEGIN
        list_users := pac_md_redcomercial.f_get_users(sperson, idioma, mensajes);
        RETURN list_users;
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
    END;
    --Fin tarefa 4077 - Borduchi
END pac_iax_redcomercial;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_REDCOMERCIAL" TO "AXIS00";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_REDCOMERCIAL" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_REDCOMERCIAL" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_REDCOMERCIAL" TO "PROGRAMADORESCSI";
