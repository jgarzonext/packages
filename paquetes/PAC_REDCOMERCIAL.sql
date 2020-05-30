--------------------------------------------------------
--  DDL for Package PAC_REDCOMERCIAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_REDCOMERCIAL" IS
   -- F.1
   FUNCTION calcul_redcomseg(
      pcemp IN NUMBER,
      pcage IN NUMBER,
      psseg IN NUMBER,
      pfini IN DATE,
      pffin IN DATE)
      RETURN NUMBER;

   -- F.2
   FUNCTION cambio_redcom_seguro(
      psseg IN NUMBER,
      pcemp IN NUMBER,
      pcage IN NUMBER,
      pfmov IN DATE,
      pfanulac IN DATE)
      RETURN NUMBER;

   -- F.3
   FUNCTION cambio_seguredcom(pcage IN NUMBER, pcemp IN NUMBER, fini_nueva IN DATE)
      RETURN NUMBER;

   -- Bug 21421 - APD - 28/02/2012 - se crea la funcion
   FUNCTION cambio_recibosredcom(pcage IN NUMBER, pcemp IN NUMBER, fini_nueva IN DATE)
      RETURN NUMBER;

   -- fin Bug 21421 - APD - 28/02/2012
   -- F.5
   FUNCTION actualiza_anulacion_seguredcom(psseg IN NUMBER, pfanul IN DATE)
      RETURN NUMBER;

   -- F.6
   FUNCTION valida_agenterehabilitacion(
      pcage_ant IN NUMBER,
      pcemp IN NUMBER,
      frehab IN DATE,
      pcage_nou IN NUMBER,
      pcorrecto OUT NUMBER)
      RETURN NUMBER;

   -- F.7
   FUNCTION rehabilitacion_seguro(
      psseg IN NUMBER,
      pcage_act IN NUMBER,
      pcemp IN NUMBER,
      frehab IN DATE,
      pcage_ant IN NUMBER)
      RETURN NUMBER;

   -- F.8
   FUNCTION valida_fechacambio_tipo(pcage IN NUMBER, pfcambio IN DATE, pcorrecto OUT NUMBER)
      RETURN NUMBER;

   -- F.9
   FUNCTION actualiza_tipoagente(pcage IN NUMBER, pctip_nou IN NUMBER, fmov IN DATE)
      RETURN NUMBER;

   -- F.10
   FUNCTION valida_fechabaja_agente(pcage IN NUMBER, pfbaja IN DATE, pcorrecto OUT NUMBER)
      RETURN NUMBER;

   -- F.11
   FUNCTION fin_agente(pcage IN NUMBER, pfbaja IN DATE)
      RETURN NUMBER;

   -- F.12
   FUNCTION rehabilita_agente(pcage IN NUMBER)
      RETURN NUMBER;

   -- F.13
   FUNCTION agente_valido(
      pcage IN NUMBER,
      pcemp IN NUMBER,
      fini IN DATE,
      ffin IN DATE,
      pcorrecto OUT NUMBER)
      RETURN NUMBER;

   -- F.14
   FUNCTION valida_cambiofechainicio(
      pcage IN NUMBER,
      pcemp IN NUMBER,
      fini_nueva IN DATE,
      pcorrecto OUT NUMBER)
      RETURN NUMBER;

   -- F.15
   FUNCTION cambia_fechainicio_redcom(pcage IN NUMBER, pcemp IN NUMBER, fini_nueva IN DATE)
      RETURN NUMBER;

   -- F.16
   FUNCTION cambio_padre(pcage IN NUMBER, pcemp IN NUMBER, padre_nuevo IN NUMBER)
      RETURN NUMBER;

   -- F.17
   FUNCTION valida_fechainicial(
      pcage IN NUMBER,
      pcemp IN NUMBER,
      fini IN DATE,
      ppadre IN NUMBER,
      pcorrecto OUT NUMBER)
      RETURN NUMBER;

   -- F.18
   FUNCTION nuevo_padre(
      pcage IN NUMBER,
      pcemp IN NUMBER,
      padre_nuevo IN NUMBER,
      fini_nueva IN DATE)
      RETURN NUMBER;

   -- F.19
   FUNCTION valida_borraultimoredcom(pcage IN NUMBER, pcemp IN NUMBER, pcorrecto OUT NUMBER)
      RETURN NUMBER;

   -- F.20
   FUNCTION borra_ultimoredcom(pcage IN NUMBER, pcemp IN NUMBER)
      RETURN NUMBER;

   -- F.21
   FUNCTION ff_buscanivelredcom(psseguro IN NUMBER, pfecha IN DATE, pnivel IN NUMBER)
      RETURN agentes.cagente%TYPE;

   -- F.22
   FUNCTION f_valida_agente(pcagente IN agentes.cagente%TYPE)
      RETURN NUMBER;

   -- F.23
   FUNCTION f_valida_agente_redcom(pcagente IN agentes.cagente%TYPE, pempresa IN NUMBER)
      RETURN NUMBER;

   -- F.24
   -- Bug 19169 - APD - 16/09/2011 - se a真aden los nuevos campos de la tabla agentes y agentes_comp
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
      -- bug 21425/109832 - 21/03/2012 - AMC
      pffinvigcom_indirect IN DATE,   -- Bug 20999 - APD - 25/01/2012
      pctipmed IN agentes.ctipmed%TYPE,
      ptnomcom IN agentes.tnomcom%TYPE,
      pcdomcom IN agentes.cdomcom%TYPE,
      pctipretrib IN agentes.ctipretrib%TYPE,
      pcmotbaja IN agentes.cmotbaja%TYPE,
      pcbloqueo IN agentes.cbloqueo%TYPE,
      pnregdgs IN agentes.nregdgs%TYPE,
      pfinsdgs IN agentes.finsdgs%TYPE,
      pcrebcontdgs IN agentes.crebcontdgs%TYPE,
      -- fin bug 21425/109832 - 21/03/2012 - AMC
      pcoblccc IN NUMBER,
      pccodcon IN agentes.ccodcon%TYPE,
	  pclaveinter IN  agentes.claveinter%TYPE,  -- TCS_1 - 15/01/2019 - ACL
	  pcdescriiva  IN  agentes.cdescriiva%TYPE,   -- TCS_1569B - ACL - 01/02/2019
      pdescricretenc IN  agentes.descricretenc%TYPE,	 -- TCS_1569B - ACL - 01/02/2019
      pdescrifuente  IN  agentes.descrifuente%TYPE,		 -- TCS_1569B - ACL - 01/02/2019
      pcdescriica IN  agentes.cdescriica%TYPE,		 -- TCS_1569B - ACL - 01/02/2019
      pmodifica IN NUMBER,
      pcagente_out IN OUT agentes.cagente%TYPE)
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
      pctipage_liquida IN agentes_comp.ctipage_liquida%TYPE,
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
      pccexpide IN agentes_comp.cexpide%TYPE,  -- BUG 31489 - FAL - 21/05/2014
	  --AAC_INI-CONF_379-20160927
	  pcorteprod	IN	agentes_comp.corteprod %TYPE
	  --AAC_FI-CONF_379-20160927
	  )
      RETURN NUMBER;

   -- F.25
   FUNCTION f_set_contrato(
      pcempres IN NUMBER,
      pcagente IN NUMBER,
      pncontrato IN NUMBER,
      pffircon IN DATE)
      RETURN NUMBER;

-- Bug 18946 - APD - 16/11/2011 - se a真aden los campos de vision por poliza
      -- cpolvisio, cpolnivel
   /*************************************************************************
      Inserta la redcomercial
      param in pcempres  : c真digo de la empresa
      param in pcagente  : c真digo del agente
      param in pfecha    : fecha
      param in pcpadre   : codigo del padre
      param in pccomindt :
      param in pcprevisio : C真digo del agente que nos indica el nivel de visi真n de personas
      param in pcprenivel : Nivel visi真n personas
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
      pcageind IN NUMBER,
      pcpolvisio IN NUMBER,
      pcpolnivel IN NUMBER,
      pcenlace IN NUMBER,   --Bug 21672 - JTS - 29/05/2012 -- IAXIS-2415 27/02/2019
      pcdomiciage NUMBER ) -- IAXIS-2415 27/02/2019
      RETURN NUMBER;

   -- dra 22-12-2008: bug mantis 8323
   FUNCTION ff_desagente(pcagente IN NUMBER, pcidioma IN NUMBER, pformato IN NUMBER DEFAULT 0)
      RETURN VARCHAR2;

     /*****************************************************************
       f_buscatipage:
       Aquesta funci真 t真 el prop真sit:
       a)     Es retorna el codi d del agent que es
           correspongui amb l'empresa, amb el tipus de agent
           i el periode sol.licitat ( pctipage informat).
           La idea principal es per exemple obtenir el nodo arrel
        b) En cas d'error torna un n真mero negatiu
           -1 : Par真metre obligatori 真s a NULL
           -2 : Depende de m真s de un agente
           -3 : No se ha encontrado el agente del que depende
           -4 : Error en la tabla REDCOMERCIAL
           -5 : La tabla REDCOMERCIAL no tiene estructura de arbol
   *****************************************************************/
   FUNCTION f_buscatipage(pcempres IN NUMBER, pctipage IN NUMBER, pfbusca IN DATE DEFAULT NULL)
      RETURN NUMBER;

   /*************************************************************************
      Devuelve el numero de agente dependiendo del tipo de agente
      param in pcempres  : c真digo de la empresa
      param in pctipage  : c真digo del tipo de agente
      param out pcontador : Numero de contador

      return             : 0 - Ok , 1 Ko

      bug 19049/89656 - 14/07/2011 - AMC
   *************************************************************************/
   FUNCTION f_get_contador_agente(pcempres IN NUMBER, pctipage IN NUMBER, pcontador OUT NUMBER)
      RETURN NUMBER;

   /*************************************************************************
      Funci真n que guardar la comisi真n/sobrecomisi真n del agente
      param in pcagente  : c真digo del agente
      param in pccomisi    : C真digo de la comisi真n
      param in pfinivig    : Fecha inicio vigencia
      param in pffinvig    : Fecha fin vigencia
      param in pccomind  : Indica si la comision es indirecta (1) o no (0)
      return             : 0 todo correcto
                           numero de error si ha habido un error
    *************************************************************************/
-- Bug 19169 - APD - 16/09/2011 - se crea la funcion
   FUNCTION f_set_comisionvig_agente(
      pcagente IN NUMBER,
      pccomisi IN NUMBER,
      pfinivig IN DATE,
      pffinvig IN DATE DEFAULT NULL,
      pccomind IN NUMBER DEFAULT 0)   -- Bug 20999 - APD - 26/01/2012
      RETURN NUMBER;

   /*************************************************************************
      Funci真n que guardar la descuento del agente
      param in pcagente  : c真digo del agente
      param in pcdesc    : C真digo de la descuento
      param in pfinivig    : Fecha inicio vigencia
      param in pffinvig    : Fecha fin vigencia
      return             : 0 todo correcto
                           numero de error si ha habido un error
    *************************************************************************/
   FUNCTION f_set_descuentovig_agente(
      pcagente IN NUMBER,
      pcdesc IN NUMBER,
      pfinivig IN DATE,
      pffinvig IN DATE DEFAULT NULL)
      RETURN NUMBER;

/*************************************************************************
      Inserta un valor del producto de participaci真n de utilidades para el agente
      param in pcagente  : c真digo del agente
      param in psproduc    : C真digo del producto
      param in pcactivi   : C真digo de la actividad
      return             : 0 todo correcto
                           numero de error si ha habido un error
   *************************************************************************/
-- Bug 19169 - APD - 16/09/2011 - se crea la funcion
   FUNCTION f_set_prodparticipacion(pcagente IN NUMBER, psproduc IN NUMBER, pcactivi IN NUMBER)
      RETURN NUMBER;

/*************************************************************************
      Inserta un valor del Soporte por ARP
      param in pcmodo ; 1.-Alta; 2.-Modif
      param in pcagente  : c真digo del agente
      param in piimporte    : Importe que se le asigna a algunas ADN's por dar soporte administrativo
      param in pfinivig   : Fecha inicio vigencia
      param in pffinvig   : Fecha fin vigencia
      return             : 0 todo correcto
                           numero de error si ha habido un error
   *************************************************************************/
-- Bug 19169 - APD - 16/09/2011 - se crea la funcion
   FUNCTION f_set_soportearp(
      pcmodo IN NUMBER,
      pcagente IN NUMBER,
      piimporte IN NUMBER,
      pfinivig IN DATE,
      pffinvig IN DATE)
      RETURN NUMBER;

/*************************************************************************
      Inserta una subvenci真n
      param in pcmodo ; 1.-Alta; 2.-Modif
      param in pcagente  : c真digo del agente
      param in psproduc    : C真digo del producto
      param in pcactivi   : C真digo de la actividad
      param in piimporte   : Importe de la subvenci真n
      return             : 0 todo correcto
                           numero de error si ha habido un error
   *************************************************************************/
-- Bug 19169 - APD - 16/09/2011 - se crea la funcion
   FUNCTION f_set_subvencion(
      pcmodo IN NUMBER,
      pcagente IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      piimporte IN NUMBER)
      RETURN NUMBER;

/*************************************************************************
      Elimina un registro del producto de participaci真n de utilidades para el agente
      param in pcagente  : c真digo del agente
      param in psproduc    : C真digo del producto
      param in pcactivi   : C真digo de la actividad
      return             : 0 todo correcto
                           numero de error ha habido un error
   *************************************************************************/
-- Bug 19169 - APD - 16/09/2011 - se crea la funcion
   FUNCTION f_del_prodparticipacion(pcagente IN NUMBER, psproduc IN NUMBER, pcactivi IN NUMBER)
      RETURN NUMBER;

/*************************************************************************
      Elimina un registro del Soporte por ARP
      param in pcagente  : c真digo del agente
      param in pfinivig    : Fecha inicio vigencia
      return             : 0 todo correcto
                           numero de error ha habido un error
   *************************************************************************/
-- Bug 19169 - APD - 16/09/2011 - se crea la funcion
   FUNCTION f_del_soportearp(pcagente IN NUMBER, pfinivig IN DATE)
      RETURN NUMBER;

/*************************************************************************
      Elimina un registro de una subvenci真n
      param in pcagente  : c真digo del agente
      param in psproduc    : C真digo del producto
      param in pcactivi    : C真digo de la actividad
      return             : 0 todo correcto
                           numero de error ha habido un error
   *************************************************************************/
-- Bug 19169 - APD - 16/09/2011 - se crea la funcion
   FUNCTION f_del_subvencion(pcagente IN NUMBER, psproduc IN NUMBER, pcactivi IN NUMBER)
      RETURN NUMBER;

/*************************************************************************
      Traspasa los registros de subvencion_agente a ctactes
      param in pcagente  : c真digo del agente
      param in pnplanpago    : Indica los meses a los que se aplica la subvenci真n en la liquidaci真n
      return             : 0 todo correcto
                           numero de error ha habido un error
   *************************************************************************/
-- Bug 20287 - APD - 05/12/2011 - se crea la funcion
   FUNCTION f_traspasar_subvencion(pcagente IN NUMBER, pnplanpago IN NUMBER)
      RETURN NUMBER;

/*************************************************************************
      Retorna el agente padre del agente que se especifica
      O retorna el agente padre el tipo que se especifica del agente
      return             : null error
                           ID agente padre
   *************************************************************************/
-- Bug 20071 - JTS - 23/12/2011 - se crea la funcion
   FUNCTION f_busca_padre(
      pcempres IN NUMBER,
      pcagente IN NUMBER,
      pctipage IN NUMBER,
      pfbusca IN DATE)
      RETURN NUMBER;

   /*************************************************************************
      Retorna el tipo de iva y de retencion de un regiment fiscal
      param in  psperson
      param in pcagente
      param out piva
      param out pretenc
      return             : 0 - ok , 1 - Ko

      Bug 20916/103702 - 13/01/2012 - AMC
   *************************************************************************/
   FUNCTION f_get_ivaagente(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      piva OUT NUMBER,
      pretenc OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_get_desnivel(pctipage IN NUMBER, pcempres IN NUMBER, pcidioma IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_get_niveles(pcempres IN NUMBER, pcidioma IN NUMBER)
      RETURN sys_refcursor;

   FUNCTION f_get_ageniveles(pcempres IN NUMBER, pcidioma IN NUMBER)
      RETURN sys_refcursor;

   /*************************************************************************
      Sincronizaci真n de recibos (de una p真liza, o un recibo) de un agente
      con una aplicaci真n externa
      param in pcagente
      param in psseguro
      param in pnrecibo
      return             : 0 - ok , 1 - Ko

      Bug 21597 - 08/03/2012 - MDS
   *************************************************************************/
   FUNCTION f_sincroniza_recibos(pcagente IN NUMBER, psseguro IN NUMBER, pnrecibo IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
      Funcion que valida el cambio de estado de un agente
      param in pcempres
      param in pcagente
      param in pctipage
      param in pcestant : estado actual del agente (equivale al estado anterior)
      param in pcestact : estado al cual se quiere pasar el agente (equivale al estado actual)
      return             : 0 - ok , 1 - Ko
   *************************************************************************/
   --Bug 21682 - APD - 25/04/2012
   FUNCTION f_valida_estado(
      pcempres IN NUMBER,
      pcagente IN agentes.cagente%TYPE,
      pctipage IN agentes.ctipage%TYPE,
--      pcestant IN agentes.cactivo%TYPE,
      pcestact IN agentes.cactivo%TYPE,
      pctipmed IN agentes.ctipmed%TYPE,
      pnregdgs IN agentes.nregdgs%TYPE)
      RETURN NUMBER;

   /******************************************************************************
    FUNCION: f_get_retencion
    Funcion que devielve el tipo de retenci真n segun la letra del cif.
    Param in psperson
    Param in pcidioma
    Param out pcidioma
    Param out pcidioma
    Retorno 0- ok 1-ko

    Bug 24514/128686 - 15/11/2012 - AMC
   ******************************************************************************/
   FUNCTION f_get_retencion(
      psperson IN NUMBER,
      pcidioma IN NUMBER,
      pcempres IN NUMBER,
      pcretenc OUT NUMBER,
      pmensaje OUT VARCHAR2)
      RETURN NUMBER;

   /******************************************************************************
       FUNCION: f_valida_regfiscal
       Funcion que valida si el tipo de iva y regimen fiscal son introducidos correctamente.
       Param in pcempres
       Param in pcidioma
       Param in psperson
       Param in pctipage
       Param in pctipiva
       Param in pctipint
       Param out
       Retorno 0- ok 1-ko

       Bug 27598-135742 - 28/01/2013 - ICG
   ******************************************************************************/
   FUNCTION f_valida_regfiscal(
      pcempres IN NUMBER,
      pcidioma IN NUMBER,
      psperson IN NUMBER,
      pctipage IN NUMBER,
      pctipiva IN NUMBER,
      pctipint IN NUMBER,
      pmensaje OUT VARCHAR2)
      RETURN NUMBER;
END;

/

  GRANT EXECUTE ON "AXIS"."PAC_REDCOMERCIAL" TO "AXIS00";
  GRANT EXECUTE ON "AXIS"."PAC_REDCOMERCIAL" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_REDCOMERCIAL" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_REDCOMERCIAL" TO "PROGRAMADORESCSI";
