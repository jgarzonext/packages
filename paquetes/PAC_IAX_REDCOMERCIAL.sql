--------------------------------------------------------
--  DDL for Package PAC_IAX_REDCOMERCIAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_REDCOMERCIAL" IS
/******************************************************************************
   NOMBRE:       PAC_IAX_REDCOMERCIAL
   PROPSITO:    Funciones con todo lo referente a la Red Comercial de la capa IAX

   REVISIONES:
   Ver        Fecha        Autor             Descripcin
   ---------  ----------  ---------------  ------------------------------------
   1.0        16/09/2008   AMC              1. Creacin del package.
   2.0        19/10/2009   AMC              2. Bug 11444. Se quita el parametro pctipage a la funcion f_set_redcomarcial.
   3.0        20/10/2011   JMC              3. 0019586: AGM003-Comisiones Indirectas a distintos niveles.
   4.0        08/11/2011   APD              4. 0019169: LCOL_C001 - Campos nuevos a aadir para Agentes.
   5.0        05/12/2011   APD              5. 0020287: LCOL_C001 - Tener en cuenta campo Subvencin
   6.0        21/05/2014   FAL              6. 0031489: TRQ003-TRQ: Gap de comercial. Liquidacin a nivel de Banco
   7.0        16/01/2019   ACL              7. TCS_1: En la funcin f_set_agente se agrega el campo claveinter para la tabla agentes.
   8.0        01/02/2019   ACL              8. TCS_1569B: Se agrega campos de impuestos en la funcion f_set_agente.
   9.0        21/02/2019   AP               9. TCS-7: Se agrega parametro de domicilio en la funcion f_set_redcomercial.
  10.0        27/02/2019   DFR             10. IAXIS-2415: FICHA RED COMERCIAL
******************************************************************************/
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
      RETURN sys_refcursor;

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
      RETURN sys_refcursor;

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
      RETURN NUMBER;

   /*************************************************************************
    Funcin que har la llamada a la funcin para poder recuperar el histrico de la Red Comercial
    segn los parmetros de entrada como son el cdigo de agente y el de empresa.
    Return: t_iax_redcomercial
   *************************************************************************/
   FUNCTION f_get_redcomercial(
      pcagente IN NUMBER,
      pcempres IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_redcomercial;

   -- Bug 19169 - APD - 16/09/2011 - se aaden los nuevos campos de la tabla agentes y agentes_comp
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
      pdescricretenc IN  agentes.descricretenc%TYPE,	-- TCS_1569B - ACL - 01/02/2019
      pdescrifuente  IN  agentes.descrifuente%TYPE,		-- TCS_1569B - ACL - 01/02/2019
      pcdescriica IN  agentes.cdescriica%TYPE,		-- TCS_1569B - ACL - 01/02/2019
      pctipint IN agentes_comp.ctipint%TYPE,
      -- fin bug 21425/109832 - 21/03/2012 - AMC
      --BUG 41764-233736
      pmodifica IN NUMBER,
      pcagente_out OUT agentes.cagente%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

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
      RETURN NUMBER;

   FUNCTION f_set_contrato(
      pcempres IN NUMBER,
      pcagente IN NUMBER,
      pncontrato IN NUMBER,
      pffircon IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

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
      RETURN NUMBER;

   /*************************************************************************
           Funcin que nos devolver lista pliza de un agente Return: Sys_Refcursor

       Bug 22313/115161 - 23/05/2012 - AMC
       *************************************************************************/-- Bug 0013392 - 23/03/2010 - JMF
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
      RETURN sys_refcursor;

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
      RETURN sys_refcursor;

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
      RETURN NUMBER;

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
      RETURN ob_iax_prodparticipacion_age;

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
      RETURN ob_iax_soportearp_agente;

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
      RETURN ob_iax_subvencion_agente;

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
      RETURN NUMBER;

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
      RETURN NUMBER;

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
      RETURN NUMBER;

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
      RETURN NUMBER;

/*************************************************************************
      Elimina un registro del Soporte por ARP
      param in pcagente  : cdigo del agente
      param in pfinivig    : Fecha inicio vigencia
      return             : 0 todo correcto
                           1 ha habido un error
   *************************************************************************/
-- Bug 19169 - APD - 16/09/2011 - se crea la funcion
   FUNCTION f_del_soportearp(pcagente IN NUMBER, pfinivig IN DATE, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

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
      RETURN NUMBER;

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
      RETURN sys_refcursor;

      /*************************************************************************
      Funcin que nos devolver el histrico de las vigencias de las descuentos del agente
      param in pcagente  : cdigo del agente
      param in pctipo    : Tipo de la comision
      Return: Sys_Refcursor
    *************************************************************************/
-- Bug 19169 - APD - 16/09/2011 - se crea la funcion
   FUNCTION f_get_descuentovig_agente(
      pcagente IN NUMBER,
      pctipo IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

-- Bug 19169 - APD - 16/09/2011 - se crea la funcion
   FUNCTION ff_desagente(
      pcagente IN NUMBER,
      pformato IN NUMBER DEFAULT 0,
      mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2;

-- Bug 20287 - APD - 05/12/2011 - se crea la funcion
   FUNCTION f_traspasar_subvencion(
      pcagente IN NUMBER,
      pnplanpago IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Funcin que nos devolver los contactos de un agente
      param in pcagente  : cdigo del agente
      Return: Sys_Refcursor

      Bug 21450/108261 - 24/02/2012 - AMC
    *************************************************************************/
   FUNCTION f_get_contactosage(pcagente IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

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
      RETURN ob_iax_age_contactos;

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
      RETURN NUMBER;

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
      RETURN NUMBER;

   FUNCTION f_get_niveles(pcempres IN NUMBER, pcidioma IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

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
      RETURN NUMBER;

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
      RETURN NUMBER;

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
      RETURN NUMBER;

   FUNCTION f_busca_padre(
      pcempres IN NUMBER,
      pcagente IN NUMBER,
      pctipage IN NUMBER,
      pfbusca IN DATE,
      ptagente OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

    /******************************************************************************
    FUNCION: f_get_retencion
    Funcion que devielve el tipo de retencin segun la letra del cif.
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
      RETURN NUMBER;

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
      RETURN NUMBER;

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
      RETURN NUMBER;
	  
	  --Inicio tarefa 4077 - Borduchi   
    FUNCTION f_get_users(
       sperson IN NUMBER,
       idioma IN NUMBER,
       mensajes OUT t_iax_mensajes)
       RETURN sys_refcursor;
    --Fin tarefa 4077 - Borduchi
END pac_iax_redcomercial;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_REDCOMERCIAL" TO "AXIS00";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_REDCOMERCIAL" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_REDCOMERCIAL" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_REDCOMERCIAL" TO "PROGRAMADORESCSI";
