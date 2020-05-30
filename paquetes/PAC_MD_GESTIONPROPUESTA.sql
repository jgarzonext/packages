--------------------------------------------------------
--  DDL for Package PAC_MD_GESTIONPROPUESTA
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE "PAC_MD_GESTIONPROPUESTA" AS
/******************************************************************************
   NOMBRE:       PAC_IAX_GESTIONPROPUESTA
   PROPÓSITO:  Funciones para gestionar las propuestas retenidas en la capa intermedia

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        06/10/2008   APD                1. Creación del package.
   2.0        03/03/2009   DRA                2. BUG0009297: IAX - Gestió de propostes - Revisió punts pendents
   3.0        01/10/2009   JRB                3. BUG0011196: Gestión de propuestas retenidas
   11.0       12/11/2009   JTS                11. 10093: CRE - Afegir filtre per RAM en els cercadors
   12.0       22/02/2010   ICV                12. 0009605: AGA - Buscadores
   13.0       02/11/2010   XPL                13. 16352: CRT702 - Módulo de Propuestas de Suplementos, -- BUG16352:XPL:02112010 INICI
   14.0       14/08/2013   RCL                14. 0027262: LCOL - Fase Mejoras - Autorizaci??asiva de propuestas retenidas
   15.0       22/11/2013   RCL                15. 0027048: LCOL_T010-Revision incidencias qtracker (V)
   16.0       03/04/2014   JSV                16. 0030448: LCOL_T010-Revision incidencias qtracker (2014/03)
   17.0       14/04/2014   FAL                17. 0029965: RSA702 - GAPS renovación
   18.0       20/03/2019   CJMR               18. IAXIS-3160: Adición de nuevos campo de búsqueda
   ******************************************************************************/

   /*************************************************************************
      Recupera todas las propuestas retenidas
      param in psproduc  : Código del producto
      param in pnpoliza  : Nº de poliza
      param in pnsolici  : Solicitud
      param in pfcancel  : Fecha de cancelación
      param in pnumide   : Documento idenficación persona
      param in pnombre   : Tomador
      param in psnip     : Identificador externo
      param out mensajes : mesajes de error
      pcmatric in varchar2
      pcpostal in varchar2
      pTNATRIE in varchar2
      pTDOMICI in varchar2
      return             : T_IAX_POLIZASRETEN
   *************************************************************************/
   FUNCTION f_get_polizasreten(
      psproduc IN NUMBER,
      pnpoliza IN seguros.npoliza%TYPE,
      pnsolici IN NUMBER,
      pfcancel IN DATE,
      pnnumide IN VARCHAR2,
      pnombre IN VARCHAR2,
      psnip IN VARCHAR2,
      pcmotret IN NUMBER,
      pcestgest IN NUMBER,
      pcramo IN NUMBER,
      pcagente IN NUMBER,
      pctipo IN VARCHAR2,
      pcmatric IN VARCHAR2,
      pcpostal IN VARCHAR2,
      ptnatrie IN VARCHAR2,
      ptdomici IN VARCHAR2,
      pcnivelbpm IN NUMBER,
      mensajes OUT t_iax_mensajes,
      pcsucursal IN NUMBER DEFAULT NULL,   -- Bug 22839/126886 - 29/10/2012 - AMC
      pcadm IN NUMBER DEFAULT NULL,   -- Bug 22839/126886 - 29/10/2012 - AMC
      pcmotor IN VARCHAR2 DEFAULT NULL,   -- Bug 25177/133016 - 28/12/2012 - AMC
      pcchasis IN VARCHAR2 DEFAULT NULL,   -- Bug 25177/133016 - 28/12/2012 - AMC
      pnbastid IN VARCHAR2 DEFAULT NULL,   -- Bug 25177/133016 - 28/12/2012 - AMC
      pmodo IN VARCHAR2 DEFAULT NULL,
      pccontrol IN NUMBER DEFAULT NULL,
      pcpolcia IN VARCHAR2 DEFAULT NULL,   -- Bug 0029965 - 14/04/2014 - FAL
      pfretend IN DATE DEFAULT NULL,   -- Bug 0029965 - 14/04/2014 - FAL
      pfretenh IN DATE DEFAULT NULL,   -- Bug 0029965 - 14/04/2014 - FAL
      pcactivi IN NUMBER DEFAULT NULL,       -- CJMR 20/03/2019 IAXIS-3160
      pnnumidease IN VARCHAR2 DEFAULT NULL,  -- CJMR 20/03/2019 IAXIS-3160
      pnombrease IN VARCHAR2 DEFAULT NULL,   -- CJMR 20/03/2019 IAXIS-3160
      ppolretpsu OUT t_iax_polretenpsu)
      RETURN t_iax_polizasreten;

   /*************************************************************************
      Recupera los motivos de retención de las propuestas
      param in psseguro  : Código seguro
      param in pnmovimi  : Número de movimiento
      param out mensajes : mesajes de error
      return             : T_IAX_POLMVTRETEN
   *************************************************************************/
   FUNCTION f_get_motretenmov(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_polmvtreten;

   /*************************************************************************
      Recupera la fecha de efecto de la propuesta y las observaciones a mostrar
      param in psseguro  : Código seguro
      param out pfefecto  : Fecha efecto
      param out pobserv  : Observaciones
      param out mensajes : mesajes de error
      return             : NUMBER (1 se ha producido un error, 0 ha ido todo bien)
   *************************************************************************/
   FUNCTION f_get_infopropreten(
      psseguro IN NUMBER,
      pfefecto OUT DATE,
      pobserv OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Acepta la propuesta retenida
      param in psseguro  : Código seguro
      param in pnmovimi  : Número de movimiento
      param in pfefecto  : Fecha efecto
      param out mensajes : mesajes de error
      return             : NUMBER (1 se ha producido un error, 0 ha ido todo bien)
   *************************************************************************/
   FUNCTION f_aceptarpropuesta(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pfefecto IN DATE,
      ptobserv IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Rechaza la propuesta retenida
      param in psseguro  : Código seguro
      param in pnmovimi  : Número de movimiento
      param in pcmotmov  : Código motivo rechazo
      param in pnsuplem  : Código suplemento
      param in ptobserva  : Observaciones
      param out mensajes : mesajes de error
      return             : NUMBER (1 se ha producido un error, 0 ha ido todo bien)
   *************************************************************************/
   FUNCTION f_rechazarpropuesta(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pcmotmov IN NUMBER,
      pnsuplem IN NUMBER,
      ptobserva IN VARCHAR2,
      ptpostpper IN psu_retenidas.postpper%TYPE,
      pcperpost IN psu_retenidas.perpost%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Acepta las propuestas retenidas
   param in p_cautrec:
   param in p_npoliza: Numero de poliza
   param in ptobserv: Observaciones
   param in p_controls: CCONTROLS de las psu's
   param out mensajes : mesajes de error
   return : NUMBER (1 se ha producido un error, 0 ha ido todo bien)
   *************************************************************************/
   FUNCTION f_aceptarpropuesta_masivo(
      p_cautrec IN NUMBER,
      p_npoliza IN NUMBER,
      ptobserv IN VARCHAR2,
      p_controls IN t_lista_id,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Rechaza las propuestas retenida masivamente
   param in p_npoliza : Numero de poliza
   param in pcmotmov  : Código motivo rechazo
   param in ptobserv  : Observaciones
   param in p_controls: CCONTROLS de las psu's
   param out mensajes : mesajes de error
   return             : NUMBER (1 se ha producido un error, 0 ha ido todo bien)
   *************************************************************************/
   FUNCTION f_rechazarpropuesta_masivo(
      p_npoliza IN NUMBER,
      pcmotmov IN NUMBER,
      ptobserv IN VARCHAR2,
      p_controls IN t_lista_id,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Recupera la fecha actual/nueva de cancelación de la propuesta
      param in psseguro  : Código seguro
      param in psproduc  : Código producto
      param out pfcancel  : Fecha actual de cancelación
      param out pfcancelnueva  : Nueva fecha de cancelación
      param out mensajes : mesajes de error
      return             : NUMBER (1 se ha producido un error, 0 ha ido todo bien)
   *************************************************************************/
   FUNCTION f_get_fechacancel(
      psseguro IN NUMBER,
      psproduc IN NUMBER,
      pfcancel OUT DATE,
      pfcancelnueva OUT DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Cambia la fecha de cancelación de la propuesta a la nueva fecha
      param in psseguro  : Código seguro
      param in pnmovimi  : Número movimiento
      param out pfcancelnueva  : Nueva fecha de cancelación
      param out mensajes : mesajes de error
      return             : NUMBER (1 se ha producido un error, 0 ha ido todo bien)
   *************************************************************************/
   FUNCTION f_cambio_fcancel(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pfcancelnueva IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Limpia los datos temporales de la modificación de propuesta
      param in psseguro  : Código seguro
   *************************************************************************/
   PROCEDURE limpiartemporales(psseguro IN NUMBER);

   /*************************************************************************
      Habilita la modificación de la propuesta retenida
      param in psseguro  : Código seguro
      param in pcmodo  : Modo de trabajo
      param in pcform  : Nombre formulario
      param in pccampo  : Nombre del botón pulsado
      param out oestsseguro  : Código seguro temporal
      param out onmovimi  : Número movimiento
      param out mensajes : mesajes de error
      return             : NUMBER (1 se ha producido un error, 0 ha ido todo bien)
   *************************************************************************/
   FUNCTION f_inicializar_modificacion(
      psseguro IN NUMBER,
      pcmodo IN VARCHAR2,
      pcform IN VARCHAR2,
      pccampo IN VARCHAR2,
      oestsseguro OUT NUMBER,
      onmovimi OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Graba las modificaciones realizadas a la propuesta
      param in psseguro  : Código seguro
      return             : NUMBER (1 se ha producido un error, 0 ha ido todo bien)
   *************************************************************************/
   FUNCTION f_grabar_alta_poliza(psseguro IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Mira si se puede asignar el número de póliza al emitir
      return             : NUMBER (1 se ha producido un error, 0 ha ido todo bien)
   *************************************************************************/
   FUNCTION f_get_npolizaenemision(pcont OUT NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Recupera la fecha de efecto
      param in psseguro  : Código seguro
      param out pfefecto : Fecha de efecto
      param out mensajes : mesajes de error
      return             : NUMBER (1 se ha producido un error, 0 ha ido todo bien)
   *************************************************************************/
   FUNCTION f_get_fefecto(psseguro IN NUMBER, pfefecto OUT DATE, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Comprueba si se puede modificar la fecha de efecto o no
      param in psseguro  : Código seguro
      param out mensajes : mesajes de error
      return             : NUMBER (0 --> NO se puede modificar la Fecha de efecto)
                                  (1 --> SI se puede modificar la Fecha de efecto)
   *************************************************************************/
   FUNCTION f_permite_cambio_fefecto(psseguro IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Valida que la fecha de efecto sea correcta
      param in psseguro  : Código seguro
      param in pfefecto  : Fecha de efecto
      param out mensajes : mesajes de error
      return             : NUMBER (1 se ha producido un error, 0 ha ido todo bien)
   *************************************************************************/
   FUNCTION f_valida_fefecto(psseguro IN NUMBER, pfefecto IN DATE, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Habilita la modificación de la propuesta retenida
      param in psseguro  : Código seguro
      param in pnriesgo  : Número del riesgo
      param in pnmovimi  : Número movimiento
      param in pcmotret  : Número motivo retención
      param in pnmotret  : Número retención
      param in pcestgest : Código estado gestión
      param in ptodos    : Todos 0 por defecto
      param out mensajes : mesajes de error
      return             : NUMBER (1 se ha producido un error, 0 ha ido todo bien)
   *************************************************************************/
   FUNCTION f_act_estadogestion(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pcmotret IN NUMBER,
      pnmotret IN NUMBER,
      pcestgest IN NUMBER,
      ptodos IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

--BUG16352:XPL:02112010 INICI
   /***********************************************************************
        Recupera las solicitudes según los filtros introducidos
        psseguro IN NUMBER,
        pnmovimi IN NUMBER,
        pnriesgo IN NUMBER,
        param out mensajes : mensajes de error
        return             : ref cursor
     ***********************************************************************/
   FUNCTION f_get_solicitudsuplementos(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnriesgo IN NUMBER,
      psolicitudes OUT sys_refcursor,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Graba las modificaciones realizadas a la propuesta
      param in psseguro  : CÃ³digo seguro
      return             : NUMBER (1 se ha producido un error, 0 ha ido todo bien)
   *************************************************************************/
   FUNCTION f_actualizar_sol_suplemento(
      psseguro IN NUMBER,
      psolici IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

--BUG16352:XPL:02112010 FI
   /*************************************************************************
      Actualiza el estado de la solicitud del suplemento
      param in psseguro  : Cdigo seguro
      param in pnmovimi  : Num. Movimiento
      param in pnriesgo  : N. riesgo
      param in pcestsupl  : Estado suplemento
      return             : NUMBER (1 se ha producido un error, 0 ha ido todo bien)
   *************************************************************************/
   FUNCTION f_set_actualizarestado_supl(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnriesgo IN NUMBER,
      pcmotmov IN NUMBER,
      pcgarant IN NUMBER,
      pcpregun IN NUMBER,
      pcestado IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_emision_masiva_marcar(
      ppolizas IN t_iax_info,
      pcestado IN NUMBER,
      psproces_in IN NUMBER,
      psproces_out OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_emision_masiva_job(psproces IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_emision_masiva(psproces IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   -- Bug 30448/0171427
   FUNCTION f_lanzajob_autmasiva(
      p_sproces IN NUMBER,
      p_cautrec IN NUMBER,
      p_npoliza IN NUMBER,
      ptobserv IN VARCHAR2,
      ptaux IN VARCHAR2)
      RETURN NUMBER;

	 /*************************************************************************
      Recupera movimiento de tabla est para reinicio de poliza   21/06/2017
      param in psseguro  : Código seguro
      param in pcmotmov : Motivo de movimiento
	  param out outnmovimi : Movimiento a retornar
      param out mensajes : mesajes de error
      return             : NUMBER (1 se ha producido un error, 0 ha ido todo bien)
   *************************************************************************/
    FUNCTION f_get_rei_nmovimi(psseguro IN NUMBER, pcmotmov IN NUMBER,outnmovimi OUT NUMBER,  mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

END pac_md_gestionpropuesta;

/