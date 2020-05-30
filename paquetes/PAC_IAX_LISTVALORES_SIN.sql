create or replace PACKAGE        "PAC_IAX_LISTVALORES_SIN" AS
/******************************************************************************
   NOMBRE:       PAC_IAX_LISTVALORES_SIN
   PROPÓSITO:  Funciones para recuperar valores

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        20/02/2009   XVM                 1. Creación del package.
   2.0        01/10/2009   DCT                 1. Bug 10393 Crear parametrización de documentacion a solicitar por producto/causa/motivo
   3.0        21/10/2009   DCT                 1. Bug 10211 Procesos cambio estado siniestro/tramitación
   4.0        10/12/2009   AMC                 4. Bug 0012211: Mant. Eventos
   5.0        14/01/2010   AMC                 5. Bug 12605 - Destinatarios siniestros según parametrización
   6.0        05/03/2010   AMC                 6. Bug 13312 se añade la funcion f_get_lsctestmov
   7.0        30/10/2010   JRH                 7. BUG 15669 : Campos nuevos
   8.0        16/03/2011   JMF                 8. 0017970: ENSA101- Campos pantallas de siniestros y mejoras
   9.0        01/07/2011   APD                 9. 0018913: CRE998 - Afegir motiu de Rescats
  10.0        26/03/2012   JMF                 0021196: LCOL_S001-SIN - Cambio de tramitador
  11.0        29/03/2019   Swapnil             11.0 Cambio de IAXIS-2168
******************************************************************************/

   -- BUG 9020 - 10/03/2009 - XVM - Nou model de dades del Sinistre, llistat pels sinistres
   FUNCTION f_get_lstcreclama(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   FUNCTION f_get_lstcmeddec
      Recupera codi medi declaració
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcmeddec(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   FUNCTION f_get_lstctipdec
      Recupera tipo declarant
      param out mensajes : missatges d'error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstctipdec(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   FUNCTION f_get_lstctipreg
      Recupera tipus registre
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstctipreg(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   FUNCTION f_get_lstcestage
      Recupera codi estat agencia
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcestage(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   FUNCTION f_get_lstcmonda
      Recupera abreviatura moneda
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcmonda(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   FUNCTION f_get_lstctcausin
      Recupera codi tipus dany
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstctcausin(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   FUNCTION f_get_lstctipdes
      Recupera tipus destinatari
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstctipdes(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   FUNCTION f_get_lstctippag
      Recupera tipus pagament
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstctippag(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   FUNCTION f_get_lstcforpag
      Recupera tipus forma pagament
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcforpag(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   FUNCTION f_get_lstctipban
      Recupera tipus de compte bancari
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstctipban(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

/*************************************************************************
   FUNCTION f_get_causasini
      Recupera les possibles causes de sinistres de pòlisses d'un determinat producte
      param in psproduc  : codi del producte
      param in psseguro  : codi del segur
      param in pcactivi  : codi de l'activitat
      param in pnriesgo  : codi del risc
      param in pfsinies  : data d'ocurrència del sinistre
      param out mensajes : missatges d'error
      return             : refcursor
*************************************************************************/
   FUNCTION f_get_causasini(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
	  /*Cambios de IAXIS-2168 : Start*/
      psseguro IN NUMBER,
      /*Cambios de IAXIS-2168 : End*/
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

/*************************************************************************
   FUNCTION F_Get_MotivosSini
      Recupera llista amb els motius de sinistres per producte
      param in psproduc  : codi del producte
      param in pccausa   : codi de la causa del sinistre
      param in psseguro  : codi del segur
      param in pcactivi  : codi de l'activitat
      param in pnriesgo  : codi del risc
      param in pfsinies  : data d'ocurrència del sinistre
      param out mensajes : missatges d'error
      return             : refcursor
*************************************************************************/
-- Bug 0012822 - 09/02/2010 - JMF: Afegir paràmetre seguro.
   FUNCTION f_get_motivossini(
      psproduc IN NUMBER,
      pccausa IN NUMBER,
      pcactivi IN NUMBER,
      psseguro IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   FUNCTION f_get_lstctramit
      Recupera codi tramitació
      param out mensajes : missatges d'error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstctramit(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   FUNCTION f_get_lstcculpab
      Recupera la cupabilitat
      param out mensajes : missatges d'error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcculpab(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   FUNCTION f_get_lstcsiglas
      Recupera les sigles de la via
      param out mensajes : missatges d'error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcsiglas(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   FUNCTION f_get_lstcinform
      Recupera informes
      param  out mensajes : missatges d'error
      return              : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcinform(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   FUNCTION f_get_lstcmanual
      Recupera registre manual
      param  out mensajes : missatges d'error
      return              : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcmanual(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   FUNCTION f_get_lstctipres
      Recupera tipus reserva
      param  out mensajes : missatges d'error
      return              : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstctipres(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   FUNCTION f_get_lstcestval
      Recupera estat validació pagament
      param  out mensajes : missatges d'error
      return              : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcestval(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   FUNCTION f_get_lstcconpag
      Recupera concepte pagament
      param  out mensajes : missatges d'error
      return              : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcconpag(
      psproduc IN NUMBER DEFAULT NULL,   --BUG 27909:NSS:04/09/2013
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   FUNCTION f_get_lstccauind
      Recupera causa indemnització
      param in out mensajes : missatges d'error
      return                : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstccauind(pctippag IN NUMBER,
                             mensajes OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR;

   /*************************************************************************
   FUNCTION f_get_lstccinform
      Recupera tramitació informativa
      param in out mensajes : missatges d'error
      return                : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstccinform(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

/*************************************************************************
   FUNCTION f_get_tiptrami
   Recupera els tipus de tramitacions d'un determinat producte
   param in psseguro  : codi del seguro
   param in pcactivi  : codi de l'activitat
   param in pccausin  : codi de la causa del sinistre
   param in pmotsin   : codi de motiu del sinistre
   param in psproduc  : codi del producte
   param in pmodo     : mode 'ALTA' o 'MODIF' del siniestre
   param in pcestsin  : estado del siniestro.
   param out mensajes : missatges d'error
   return             : refcursor

   Bug 15153 - 28/06/2010 - AMC - Se añade el parametro pmodo
   CONF-513  - 20/12/2016 - OGQ - Se añade el parametro pcestsin
*************************************************************************/
   FUNCTION f_get_tiptrami(
      psseguro IN NUMBER,
      pcactivi IN NUMBER,
      pccausin IN NUMBER,
      pmotsin IN NUMBER,
      psproduc IN NUMBER,
      pmodo IN VARCHAR2,
      pctramte IN NUMBER,
      pcestsin IN NUMBER DEFAULT NULL,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   FUNCTION f_get_lstccestsin
      Recupera estat sinistre
      param in out mensajes : missatges d'error
      return                : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstccestsin(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   FUNCTION f_get_lstccsubtra
      Recupera subestat tramitació
      param in out mensajes : missatges d'error
      return                : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstccsubtra(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

/*************************************************************************
   FUNCTION f_get_tcompania
   Recupera els tipus de tramitacions d'un determinat producte
   param out mensajes : missatges d'error
   return             : refcursor

*************************************************************************/
   FUNCTION f_get_tcompania(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   FUNCTION f_get_lstcestper
      Recupera estat persona
      param in out mensajes : missatges d'error
      return                : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcestper(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

/*************************************************************************
       Recupera las actividades profesionales
       param out mensajes : mensajes de error
       return : ref cursor

          30/03/2009   XPL                 Sinistres.  Bug: 9020
*************************************************************************/
   FUNCTION f_get_lstcactprof(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

/*************************************************************************
   FUNCTION f_get_cunitra
   Recupera les unitats tramitadores amb les seves descripcions
   param in pcempres  : codi empresa
   param out mensajes : missatges d'error
   return             : refcursor
*************************************************************************/
   FUNCTION f_get_cunitra(pcempres IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

/*************************************************************************
   FUNCTION f_get_ctramitad
   Recupera els tramidors amb les seves descripcions
   param in pcempres     : codi empresa
   param in pctramitpad  : codi tramitador pare
   param out mensajes    : missatges d'error
   return                : refcursor
*************************************************************************/
   FUNCTION f_get_ctramitad(
      pcempres IN NUMBER,
      pctramitpad IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

    /*************************************************************************
      Recupera las Causas Siniestro de sin_codmotcau
      param out mensajes : mensajes de error
      return : ref cursor

      20/05/2009   AMC                 Sinistres.  Bug: 8816
   *************************************************************************/
   FUNCTION f_get_lstcassin_codmotcau(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera los Motivos Siniestro de sin_codmotcau
      param out mensajes : mensajes de error
      return : ref cursor

      20/05/2009   AMC                 Sinistres.  Bug: 8816
   *************************************************************************/
   FUNCTION f_get_lstmotsin_codmotcau(pccausin IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
       Recupera los Motivos Movimientos
       param out mensajes : mensajes de error
       return : ref cursor

       20/05/2009   AMC                 Sinistres.  Bug: 8816
    *************************************************************************/
   FUNCTION f_get_lstmotmovi(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
       Recupera los Códigos Movimiento Cuenta Seguro
       param out mensajes : mensajes de error
       return : ref cursor

       20/05/2009   AMC                 Sinistres.  Bug: 8816
    *************************************************************************/
   FUNCTION f_get_lstcodctaseguro(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
       Recupera los Tipo Destinatario
       param out mensajes : mensajes de error
       return : ref cursor

       20/05/2009   AMC                 Sinistres.  Bug: 8816
    *************************************************************************/
   FUNCTION f_get_lsttipdestinatario(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
       Recupera los Modelos fiscales
       param out mensajes : mensajes de error
       return : ref cursor

       20/05/2009   AMC                 Sinistres.  Bug: 8816
    *************************************************************************/
   FUNCTION f_get_lstmodfiscales(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
       Recupera los elementos
       param out mensajes : mensajes de error
       return : ref cursor

       20/05/2009   AMC                 Sinistres.  Bug: 8816
    *************************************************************************/
   FUNCTION f_get_lstelemento(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
       Recupera las formulas
       param out mensajes : mensajes de error
       return : ref cursor

       20/05/2009   AMC                 Sinistres.  Bug: 8816
    *************************************************************************/
   FUNCTION f_get_lstformula(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
       Recupera las causas y motivos por producto
       param out mensajes : mensajes de error
       return : ref cursor

       20/05/2009   AMC                 Sinistres.  Bug: 8816
    *************************************************************************/
   FUNCTION f_get_lstproductossin(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
       Recupera a los profesionales
       param out mensajes : mensajes de error
       return : ref cursor

       29/05/2012   JLTS                 Sinistres.  Bug: 21838
    *************************************************************************/
   FUNCTION f_get_lstprofesionales(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
       Recupera las actividades del producto escogido
       param in psproduc : código del producto
       param out mensajes : mensajes de error
       return : ref cursor

       20/05/2009   AMC                 Sinistres.  Bug: 8816
    *************************************************************************/
   FUNCTION f_get_lstactiviprodsin(psproduc IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
       Recupera las garantias del producto y actividad escogidos
       param in psproduc : código del producto
       param in pcactivi : código de la actividad
       param out mensajes : mensajes de error
       return : ref cursor

       20/05/2009   AMC                 Sinistres.  Bug: 8816
    *************************************************************************/
   FUNCTION f_get_lstgaransin(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
       Recupera las garantias del producto y actividad escogidos
       param in psproduc : código del producto
       param in pcactivi : código de la actividad
       param in pcgarant : código de la garantia
       param out mensajes : mensajes de error
       return : ref cursor

       20/05/2009   AMC                 Sinistres.  Bug: 8816
    *************************************************************************/
   FUNCTION f_get_lsttramisin(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera los estados de las causas de un siniestro
      param in pcestsin : código estado
      param out mensajes : mensajes de error
      return : ref cursor

      29/07/2009   XVM                 Sinistres.  Bug: 10211
   *************************************************************************/
   FUNCTION f_get_lstestado(pcestsin IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera los estados de las causas de una tramitación
      param in pcestsin : código estado
      param out mensajes : mensajes de error
      return : ref cursor

   -- BUG 0021196 - 26/03/2012 - JMF
   *************************************************************************/
   FUNCTION f_get_lstestadotra(pcestsin IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera la lista de causas
      param out mensajes : mensajes de error
      return : ref cursor

      29/07/2009   XVM                 Sinistres.  Bug: 8820
   *************************************************************************/
   FUNCTION f_get_lstcausas(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

    /*************************************************************************
   FUNCTION f_get_lstcdocume
      Recupera codi del document i el títol del document
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcdocume(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   FUNCTION f_get_lstesttra
      Recupera llista estats tramitació
      param in  pcesttra : estado tramitación
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstesttra(pcesttra IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
    Función f_get_lsteventos
    Recupera el listado de eventos
    param out mensajes   : mensajes de error
    return              : sys_refcursor

    -- Bug 12211 - 10/12/2009 - AMC
   *************************************************************************/
   FUNCTION f_get_lsteventos(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
    Función f_get_lsttipdes
    Recupera el listado de los tipos de destinatarios
    param in psproduc : código del producto
    param in pcactivi : codigo de la actividad
    param in pctramit : código del tipo de tramitación
    param in pccausin : código de la causa del siniestro
    param in pcmotsin : código del motivo del siniestro
    param in psseguro : código de seguro
    param out mensajes   : mensajes de error
    return              : sys_refcursor

    -- Bug 12605 - 14/01/2010- AMC
   *************************************************************************/
   FUNCTION f_get_listtipdes(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pctramit IN NUMBER,
      pccausin IN NUMBER,
      pcmotsin IN NUMBER,
      psseguro IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
    Función f_get_lsctestmov
    Recupera el listado del estado del pago dependiendo del estado anterior
    param in pestvalant : Estado de la validacion anterior
    param in pestpagant : Estado del pago anterior
    param in pestval: Estado de la validacion actual
    param out mensajes   : mensajes de error
    return              : sys_refcursor

    -- Bug 13312 - 05/03/2010 - AMC
   *************************************************************************/
   FUNCTION f_get_lsctestmov(
      pestvalant IN NUMBER,
      pestpagant IN NUMBER,
      pestval IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

 -- Bug 0015669 - JRH - 30/09/2010 - Alta prestaciones
/*************************************************************************
    Función f_get_lstEstadoPrest
    Recupera el listado de estados de una prestación
    param out mensajes   : mensajes de error
    return              : sys_refcursor


   *************************************************************************/
   FUNCTION f_get_lstestadoprest(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

/*************************************************************************
    Función f_get_lstEstPagosPrest
    Recupera el listado de estado de pagos de una prestación
    param out mensajes   : mensajes de error
    return              : sys_refcursor


   *************************************************************************/
   FUNCTION f_get_lstestpagosprest(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

/*************************************************************************
    Función f_get_lstDurPrest
    Recupera el listado de duraciones de prestación
    param out mensajes   : mensajes de error
    return              : sys_refcursor


   *************************************************************************/
   FUNCTION f_get_lstdurprest(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
    Función f_get_lstTipCap
    Recupera el listado de formas de pago de prestación
    param in  pnsinies   : siniestro -- Bug 0017970 - 16/03/2011 - JMF
    param out mensajes   : mensajes de error
    return              : sys_refcursor


   *************************************************************************/
   FUNCTION f_get_lsttipcap(pnsinies IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

    /*************************************************************************
    Función f_get_lstTipRelAse
    Recupera el listado de formas de relación con el asegurados
    param out mensajes   : mensajes de error
    return              : sys_refcursor


   *************************************************************************/
   FUNCTION f_get_lsttiprelase(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

    /*************************************************************************
    Función f_get_lstNivelSini
    Recupera el listado de niveles de siniestro
    param out mensajes   : mensajes de error
    return              : sys_refcursor


   *************************************************************************/
   FUNCTION f_get_lstnivelsini(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

     /*************************************************************************
    Función f_get_lstPersonasCaus
    Recupera el listado de causantes del siniestro
    param in psseguro : Código seguro
    param in pccausin : Causa siniestro
    param in pcmotsin : Motivo siniestro
    param in pcnivel :  Nivel siniestro
    param out mensajes   : mensajes de error
    return              : sys_refcursor


   *************************************************************************/
   FUNCTION f_get_lstpersonascaus(
      psseguro IN NUMBER,
      pccausin IN NUMBER,
      pcmotsin NUMBER,
      pcnivel IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

-- Fi Bug 0015669 - JRH - 30/09/2010

   /*************************************************************************
       Recupera los Motivos de Rescate de sin_desmotresccau
       param  in psseguro : identificador del seguro
       param  in pccausin : código de la causa del siniestro
       param out mensajes : mensajes de error
       return : ref cursor
    *************************************************************************/
   -- Bug 18913 - APD - 01/07/2011 - se crea la función
   FUNCTION f_get_lstmotresc(
      psseguro IN NUMBER,
      pccausin IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   FUNCTION f_get_lstcconpag_dep
      Recupera concepte pagament (dependiendo del tipo de pago)
      param  in  ctippag  : tipo de pago
      param  out mensajes : missatges d'error
      return              : ref cursor
      bug 21720:ASN:20/03/2012 - creacion
   *************************************************************************/
   FUNCTION f_get_lstcconpag_dep(
      pctippag IN NUMBER,
      psproduc IN NUMBER DEFAULT NULL,   --BUG 27909:NSS:04/09/2013
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera los estados de las causas de un tramite
      param in pcestado : código estado
      param out mensajes : mensajes de error
      return : ref cursor

   -- BUG 0022108 - 19/06/2012 - JMF
   *************************************************************************/
   FUNCTION f_get_lstestadotramite(pcestado IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
       Recupera los subtipos de tipos de tramitación (valores dependientes)
       param  in pcempres : Código Empresa
       param  in pctramit : Código Tramitación
       param out mensajes : mensajes de error
       return : ref cursor
       -- BUG 0023536 - 04/10/2012 - JMF
    *************************************************************************/
   FUNCTION f_get_lstsubtiptra(
      pcempres IN NUMBER,
      pctramit IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      f_get_lispignorados
       Recupera beneficiarios de las pignoraciones
         param  in psseguro : identificador del seguro
         param out mensajes : mensajes de error
         return             : ref cursor
    *************************************************************************/-- Bug 27766 - 10/12/2013 - se crea la funcion
   FUNCTION f_get_lispignorados(psseguro IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      f_get_beneficiarios_nominales
       Recupera beneficiarios nominales
         param  in psseguro : identificador del seguro
         param  in pfsinies : Fecha de siniestro
         param out mensajes : mensajes de error
         return             : ref cursor
    *************************************************************************/-- Bug 27766 - 10/12/2013 - se crea la funcion
   FUNCTION f_get_beneficiarios_nominales(
      psseguro IN NUMBER,
      pfsinies IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera los asegurados innominados
      param  in pnsinies : Código Siniestro
      param  in pntramit : Código Tramitación
      param out mensajes : mensajes de error
      return : ref cursor
      -- BUG 35676 - 24/04/2015 - RFA
   *************************************************************************/
   FUNCTION f_get_aseginnominado(
      pnsinies IN NUMBER,
      pntramit IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_lstgarantias_cap(
      psseguro IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_procesos_tramitador(
      pctramitad IN VARCHAR2,
      pctipo IN NUMBER,
      pctramit IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

    /*************************************************************************
      f_get_lstsoldoc
         pnsinies  in
         param out mensajes : mensajes de error
         return             : ref cursor
    *************************************************************************/-- Bug 27766 - 10/12/2013 - se crea la funcion
   FUNCTION f_get_lstsoldoc(pnsinies IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

    /*************************************************************************
      f_get_lsttramit
         pnsinies  in
         param out mensajes : mensajes de error
         return             : ref cursor
    *************************************************************************/-- Bug 27766 - 10/12/2013 - se crea la funcion
   FUNCTION f_get_lsttramit(pnsinies IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      f_get_lstpagos
         pnsinies  in varchar2
         pntramit in number
         param out mensajes : mensajes de error
         return             : ref cursor
    *************************************************************************/-- Bug 27766 - 10/12/2013 - se crea la funcion
   FUNCTION f_get_lstpagos(pnsinies IN VARCHAR2, pntramit IN NUMBER,  mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;
      
   /*************************************************************************
         Funciones : f_get_lstcontingencia, f_get_lstriesgos
         Autor: AB 09/05/2019
         Consulta de datos para las listas de contingencia y riesgo de siniestros
         return             : ref cursor
         Bug 3603 
    *************************************************************************/
   FUNCTION f_get_lstcontingencia ( mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;
      
   FUNCTION f_get_lstriesgos ( mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

/*************************************************************************
         Funciones : f_get_lstclaseproceso
         Autor: EA 21/02/2020
         Consulta de datos para las listas de Clase de proceso de siniestros
         return             : ref cursor
         Bug o tarea 3603 
    *************************************************************************/
   FUNCTION f_get_lstclaseproceso ( mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;
/*************************************************************************
         Funciones : f_get_lstinstanciaproceso
         Autor: EA 21/02/2020
         Consulta de datos para las listas de Instancia del Proceso de siniestros
         return             : ref cursor
         Bug o tarea 3603 
    *************************************************************************/
   FUNCTION f_get_lstinstanciaproceso ( mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;
/*************************************************************************
         Funciones : f_get_lstcontingenciafallo
         Autor: EA 21/02/2020
         Consulta de datos para las listas de Fallo de siniestros
         return             : ref cursor
         Bug o tarea 3603 
    *************************************************************************/
   FUNCTION f_get_lstcontingenciafallo ( mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;
/*************************************************************************
         Funciones : f_get_lstcalifmotivo
         Autor: EA 21/02/2020
         Consulta de datos para las listas de Calificación Motivos de siniestros
         return             : ref cursor
         Bug o tarea 3603 
    *************************************************************************/
   FUNCTION f_get_lstcalifmotivo ( mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;
/*************************************************************************
         Funciones : f_get_lstoralproceso
         Autor: EA 21/02/2020
         Consulta de datos para las listas de ¿El proceso se llevara a cabo de manera Oral? de siniestros
         return             : ref cursor
         Bug o tarea 12959 
    *************************************************************************/
   FUNCTION f_get_lstoralproceso ( mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

END pac_iax_listvalores_sin;