CREATE OR REPLACE PACKAGE "PAC_AVISOS"
AS
   /******************************************************************************
    NOMBRE:      pac_avisos
    PROP¿SITO:   Package de avisos

    REVISIONES:
    Ver        Fecha        Autor             Descripci¿n
    ---------  ----------  ---------------  ------------------------------------
    1.0        --/--/----   ---                1. Creaci¿n del package.
    2.0        19/10/2011   RSC                2. 0019412: LCOL_T004: Completar parametrizaci¿n de los productos de Vida Individual
    3.0        10/04/2011   ETM                3.0019412: LCOL_T004: Completar parametrizaci¿n de los productos de Vida Individual
    4.0        22/11/2011   RSC                4.0020241: LCOL_T004-Parametrizaci¿n de Rescates (retiros)
    5.0        26/06/2012   DRA                5.0021927: MDP - TEC - Parametrizaci¿n producto de Hogar (MHG) - Nueva producci¿n
    6.0        28/06/2012   FAL                6.0021905: MDP - TEC - Parametrizaci¿n de productos del ramo de Accidentes - Nueva producci¿n
    7.0        04/10/2012   MDS                7.0023822: MDP_S001-SIN - Aviso de referencia externa (Id=23696)
    8.0        23/01/2013   ETM                8.0024745: (POSPG600)-Parametrizacion-Tecnico-Baja de un amparo afectado por un siniestro (PAC_AVISOS)
    9.0        13/01/2015   YDA                9.0039787: Se modifica la funci¿n f_valida_bene_accepted para que valide el campo pctipben
    10.0       23/08/2019   JLTS              10.IAXIS-5100: Se adiciona la función f_valida_rango_dian_rc_rd
   ******************************************************************************/
   FUNCTION f_oficinagestion(psseguro IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_benefirrevocable(
      psseguro   IN   NUMBER,
      pnriesgo   IN   NUMBER,
      pcpregun   IN   NUMBER,
      pnmovimi   IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER;

   FUNCTION f_accion(
      pscorreo    IN   NUMBER,
      psseguro    IN   NUMBER,
      pnriesgo    IN   NUMBER,
      pcidioma    IN   NUMBER,
      paccion     IN   VARCHAR2,
      pcmotmov    IN   NUMBER,
      pcpregun    IN   NUMBER,
      pcoficina   IN   VARCHAR2,
      pcterm      IN   VARCHAR2,
      pnmovimi    IN   NUMBER
   )
      RETURN NUMBER;

   PROCEDURE p_preanulacion_solicitudes(
      psproduc   IN       NUMBER,
      psseguro   IN       NUMBER,
      pfecha     IN       DATE,
      psproces   OUT      NUMBER
   );

       /*************************************************************************
      Devuelve la lista de los avisos a ejecutar
      param in pcempres     : Empresa
      param in pcform     : Formulario
      param in pcmodo     : Modo
      param in pccfgavis     : Perfil del usuario para ver los avisos
      param in pcramo     : ramo
      param in psproduc     : producto
      param in pcidioma     : idioma
      param out pquery  : Query con los avisos
      return                : 0/1 OK/KO
   *************************************************************************/
   FUNCTION f_get_avisos(
      pcempres     IN       NUMBER,
      pcform       IN       VARCHAR2,
      pcmodo       IN       VARCHAR2,
      pccfgavis    IN       VARCHAR2,
      pcramo       IN       NUMBER,
      psproduc     IN       NUMBER,
      pcidioma     IN       NUMBER,
      pcmsgwinfo   IN       VARCHAR2,
      psquery      OUT      VARCHAR2
   )
      RETURN NUMBER;

/*
   Cl¿usulas especiales (segundas hojas): Cuando una p¿liza tenga cl¿usulas especiales
que afectan a la cobertura (el aviso se mostrar¿ siempre que la p¿liza tenga cl¿usulas de este tipo)
deber¿ mostrarse aviso de su existencia para que el tramitador pueda consultar dichas cl¿usulas
 (aviso de p¿liza)

*/
   FUNCTION f_aviso_clausuesp(
      psseguro    IN       NUMBER,
      pnsinies    IN       VARCHAR2,
      pnriesgo    IN       NUMBER,
      pcidioma    IN       NUMBER,
      ptmensaje   OUT      VARCHAR2
   )
      RETURN NUMBER;

           /*
      P¿liza anulada al efecto [SIN-294]: Cuando se da un parte para una p¿liza vigente
         y posteriormente esta p¿liza se anula a fecha efecto, el sistema deber¿ generar un
         aviso al tramitador global conforme se ha anulado la p¿liza con fecha anterior a la
          fecha del siniestro y deber¿ quedar registrado en la cabecera de avisos. (aviso de p¿liza)
   RETURN 0(ok),1(error),2(warning)
   */
   FUNCTION f_aviso_polanulefecto(
      psseguro    IN       NUMBER,
      pnsinies    IN       VARCHAR2,
      pcidioma    IN       NUMBER,
      ptmensaje   OUT      VARCHAR2
   )
      RETURN NUMBER;

   /*
    Mostrar un aviso de si hay +/- N d¿as entre la fecha ocurrencia del
    siniestro y la fecha efecto de p¿liza (siniestros prematuros).
    RETURN 0(ok),1(error),2(warning)
    */
   FUNCTION f_aviso_carencia(
      psseguro    IN       NUMBER,
      pnsinies    IN       VARCHAR2,
      pndias      IN       NUMBER,
      pcidioma    IN       NUMBER,
      ptmensaje   OUT      VARCHAR2
   )
      RETURN NUMBER;

      /*
   Ocurrencia anterior a fecha de grabaci¿n de p¿liza.(aviso de p¿liza)
   RETURN 0(ok),1(error),2(warning)
   */
   FUNCTION f_aviso_sini_ant_a_emision(
      psseguro    IN       NUMBER,
      pnsinies    IN       VARCHAR2,
      pcidioma    IN       NUMBER,
      ptmensaje   OUT      VARCHAR2
   )
      RETURN NUMBER;

/*
      En la apertura y la consulta de siniestros, el sistema deber¿ informar
      en el apartado de avisos de cabecera que existen aperturas rechazadas
      en los 3 meses anteriores. (aviso de p¿liza)
      RETURN 0(ok),1(error),2(warning)
      */
   FUNCTION f_aviso_aperturas_rechazadas(
      psseguro    IN       NUMBER,
      pcidioma    IN       NUMBER,
      ptmensaje   OUT      VARCHAR2
   )
      RETURN NUMBER;

   /*
        Aviso de duplicidad de siniestros por fecha, causa y p¿liza
        RETURN 0(ok),1(error),2(warning)
        */
   FUNCTION f_aviso_duplicidad_sini(
      pnsinies    IN       VARCHAR2,
      pcidioma    IN       NUMBER,
      ptmensaje   OUT      VARCHAR2
   )
      RETURN NUMBER;

    /*
   Se mostrar¿ un aviso cuando la p¿liza es coasegurada (Aviso de p¿liza)
   RETURN 0(ok),1(error),2(warning)
   */
   FUNCTION f_aviso_pol_es_coasegurada(
      psseguro    IN       NUMBER,
      pcidioma    IN       NUMBER,
      ptmensaje   OUT      VARCHAR2
   )
      RETURN NUMBER;

     /*
   Siniestro anterior rehabilitaci¿n de p¿liza (aviso de p¿liza)
   RETURN 0(ok),1(error),2(warning)
   */
   FUNCTION f_aviso_pol_rehabilitacion(
      pnsinies    IN       VARCHAR2,
      pcidioma    IN       NUMBER,
      ptmensaje   OUT      VARCHAR2
   )
      RETURN NUMBER;

   /*
     Prima pendiente para el periodo
     RETURN 0(ok),1(error),2(warning)
     */
   FUNCTION f_aviso_prima_pendiente(
      pnsinies    IN       VARCHAR2,
      pcidioma    IN       NUMBER,
      ptmensaje   OUT      VARCHAR2
   )
      RETURN NUMBER;

   /*
   Recibo fraccionado
   RETURN 0(ok),1(error),2(warning)
   */
   FUNCTION f_aviso_recibos_fraccionado(
      psseguro    IN       NUMBER,
      pcidioma    IN       NUMBER,
      ptmensaje   OUT      VARCHAR2
   )
      RETURN NUMBER;

   /*
   se intente dar de baja un amparo afectado por un siniestro a una fecha posterior
   a la ocurrencia del siniestro, pero dentro de la misma anualidad, el sistema deber¿
   permitir tramitar la baja, sin embargo, generar¿ un aviso a siniestros
   RETURN 0(ok),1(error),2(warning)
   */
   FUNCTION f_aviso_garantia_baja(
      pnsinies    IN       VARCHAR2,
      pcidioma    IN       NUMBER,
      ptmensaje   OUT      VARCHAR2
   )
      RETURN NUMBER;

   -- Bug 19412/95066 - RSC - 19/10/2011
   FUNCTION f_aviso_asegurado(pcidioma IN NUMBER, ptmensaje OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_aviso_tomador(pcidioma IN NUMBER, ptmensaje OUT VARCHAR2)
      RETURN NUMBER;

-- Fin bug 19412
   -- Bug 19412/94886 - RSC - 19/10/2011
   FUNCTION f_aviso_fvencim_fraccionado(
      pcforpag    IN       NUMBER,
      pcduraci    IN       NUMBER,
      pfefecto    IN       DATE,
      pfvencim    IN       DATE,
      pcidioma    IN       NUMBER,
      ptmensaje   OUT      VARCHAR2
   )
      RETURN NUMBER;

-- Bug 19412/94886

   -- Bug 19412/94886 - RSC - 19/10/2011
   FUNCTION f_aviso_ndurcob(
      pndurcob    IN       NUMBER,
      pcidioma    IN       NUMBER,
      ptmensaje   OUT      VARCHAR2
   )
      RETURN NUMBER;

-- Bug 19412/94886
/*************************************************************************
        FUNCTION f_aviso_ndurcob_lim
        Funci¿n de pagos limitados 70 a¿os y 80 a¿os: si NDURCOB = 1 la revalorizaci¿n no puede ser 10
        pndurcob in number
        pprevali in number
        pcidioma  in number: codigo idioma
        ptmensaje out: Texto de error
        RETURN 0(ok),return 1 (ko)
   *************************************************************************/
   -- Bug 19412/97521 - ETM - 10/11/2011
   FUNCTION f_aviso_ndurcob_lim(
      pprevali    IN       NUMBER,
      pcidioma    IN       NUMBER,
      ptmensaje   OUT      VARCHAR2
   )
      RETURN NUMBER;

   -- No se permite la anulaci¿n a esa fecha si tiene recibos pendientes anteriores a la fecha de anulaci¿n
   FUNCTION f_aviso_rec_pend(
      psseguro    IN       NUMBER,
      pfanulac    IN       DATE,
      pctipanul   IN       NUMBER,
      pcidioma    IN       NUMBER,
      ptmensaje   OUT      VARCHAR2
   )
      RETURN NUMBER;

   FUNCTION f_benefobligatori(
      pnriesgo_beneident   IN       NUMBER,
      pcidioma             IN       NUMBER,
      ptmensaje            OUT      VARCHAR2
   )
      RETURN NUMBER;

   /*************************************************************************
        FUNCTION f_aviso_importe_reserva
        Funci¿n que valida que el importe de la reserva no sea superior a la provisi¿n de la p¿liza
        psseguro in number
        pfechasini in date
        pireserva  in number
        ptmensaje out: Texto de error
        RETURN 0(ok),RETURN 1(ko)

        Bug 20880/103300 - 12/01/2012 - AMC
   *************************************************************************/
   FUNCTION f_aviso_importe_reserva(
      psseguro    IN       NUMBER,
      pfresini    IN       DATE,
      picaprie    IN       NUMBER,
      pcidioma    IN       NUMBER,
      ptmensaje   OUT      VARCHAR2
   )
      RETURN NUMBER;

   /*************************************************************************
        FUNCTION f_noidentifica_sistema
        Funci¿n que valida que no se selecciona un tomador con ctipide el
        identificador del sistema

        pcidioma in number
        ptmensaje out: Texto de error
        RETURN 0(ok),RETURN 1(ko)
   *************************************************************************/
   FUNCTION f_noidentifica_sistema(pcidioma IN NUMBER, ptmensaje OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_validacion_psu(
      psseguro          IN       NUMBER,
      pnriesgo          IN       NUMBER,
      pnmovimi          IN       NUMBER,
      pcidioma          IN       NUMBER,
      parfix_ccontrol   IN       NUMBER,
      ptmensaje         OUT      VARCHAR2
   )
      RETURN NUMBER;

   -- BUG 21905 - FAL - 27/06/2012
   FUNCTION f_aviso_asegurado_no_mujer(
      pcidioma    IN       NUMBER,
      ptmensaje   OUT      VARCHAR2
   )
      RETURN NUMBER;

   -- Ini Bug 23822 - MDS - 04/10/2012
   FUNCTION f_refer_externa_existe(
      pnsinies    IN       NUMBER,
      pcidioma    IN       NUMBER,
      ptmensaje   OUT      VARCHAR2
   )
      RETURN NUMBER;

-- Fin Bug 23822 - MDS - 04/10/2012

   -- FI BUG 21905
   /*************************************************************************
        FUNCTION f_aviso_carta_rechazo
        Funci¿n que valida si se ha emitido una carta de rechazo en los ultimos 90 dias

        psseguro in number
        pcidioma in number
        ptmensaje out: Texto de error
       RETURN 0(ok),RETURN 1(ko)

       0024273: MDP_S001-SIN - Carta de rechazo de alta de siniestro.
   *************************************************************************/
   FUNCTION f_aviso_carta_rechazo(
      psseguro    IN       NUMBER,
      pcidioma    IN       NUMBER,
      ptmensaje   OUT      VARCHAR2
   )
      RETURN NUMBER;

   /*************************************************************************
        FUNCTION f_aviso_no_tramitador
        Funci¿n que valida si el siniestro no tiene tramitador asignado

        pnsinies in varchar2
        pcidioma in number
        ptmensaje out: Texto de error
       RETURN 0(ok),RETURN 1(ko)

       0024304: Aviso 'Siniestro sin tramitador'
   *************************************************************************/
   FUNCTION f_aviso_no_tramitador(
      pnsinies    IN       VARCHAR2,
      pcidioma    IN       NUMBER,
      ptmensaje   OUT      VARCHAR2
   )
      RETURN NUMBER;

   /*************************************************************************
        FUNCTION
        Funci¿n que valida la informaci¿n introducida suplemento prorroga vigencia
        ptmensaje out: Texto de error
        RETURN 0(ok),RETURN 1(ko)
        BUG 0026035 - 18/02/2013 - JMF
   *************************************************************************/
   FUNCTION f_val_prorrogavigencia(
      psseguro    IN       NUMBER,
      pfefecto    IN       DATE,
      pcduraci    IN       NUMBER,
      pfrenova    IN       DATE,
      pcforpag    IN       NUMBER,
      pctipcob    IN       NUMBER,
      pcidioma    IN       NUMBER,
      ptmensaje   OUT      VARCHAR2
   )
      RETURN NUMBER;

   --Bug 24745/0135666 -- ETM --23/01/2013
   /*************************************************************************
          FUNCTION f_valida_bajagaran
          Funci¿n q comprueba si se puden dar de baja garantias cuando hay siniestros en la poliza
          psseguro in number
          pnriesgo in number
          pnmovimi  in number
          pcidioma  in number
          ptmensaje out: Texto de error
          RETURN 0(ok),return 1 (ko)
     *************************************************************************/
   FUNCTION f_valida_bajagaran(
      psseguro    IN       NUMBER,
      pnriesgo    IN       NUMBER,
      pnmovimi    IN       NUMBER,
      pcidioma    IN       NUMBER,
      ptmensaje   OUT      VARCHAR2
   )
      RETURN NUMBER;

   RETURN   NUMBER;

--fin  --Bug 24745/0135666  -- ETM --23/01/2013
   /*************************************************************************
        FUNCTION
        Funci¿n que valida la informaci¿n introducida suplemento renovaci¿n vigencia
        ptmensaje out: Texto de error
        RETURN 0(ok),RETURN 1(ko)
        BUG 0026035 - 18/02/2013 - JMF
   *************************************************************************/
   FUNCTION f_val_renovavigencia(
      psseguro    IN       NUMBER,
      pfefecto    IN       DATE,
      pcduraci    IN       NUMBER,
      pfrenova    IN       DATE,
      pcforpag    IN       NUMBER,
      pctipcob    IN       NUMBER,
      pcidioma    IN       NUMBER,
      ptmensaje   OUT      VARCHAR2
   )
      RETURN NUMBER;

   -- Bug 27539/0149064 - APD - 17/07/2013
   FUNCTION f_valida_retorno(pcidioma IN NUMBER, ptmensaje OUT VARCHAR2)
      RETURN NUMBER;

   -- Bug 27539/0149064 - APD - 17/07/2013
   FUNCTION f_valida_corretaje(pcidioma IN NUMBER, ptmensaje OUT VARCHAR2)
      RETURN NUMBER;

   -- Bug 31165 - NSS - 29/04/2014
   FUNCTION f_aviso_pol_bloqueada(
      psseguro    IN       NUMBER,
      pcidioma    IN       NUMBER,
      ptmensaje   OUT      VARCHAR2
   )
      RETURN NUMBER;

   -- Bug 31165 - NSS - 29/04/2014
   FUNCTION f_aviso_ben_oneroso(
      psseguro    IN       NUMBER,
      pcidioma    IN       NUMBER,
      ptmensaje   OUT      VARCHAR2
   )
      RETURN NUMBER;

/* bug 31872/177857:NSS:08/07/2014

        Se mostrar¿ un aviso cuando la p¿liza es reasegurada (Aviso de p¿liza)
        RETURN 0(ok),1(error)
        */
   FUNCTION f_aviso_pol_es_reasegurada(
      psseguro    IN       NUMBER,
      pcidioma    IN       NUMBER,
      ptmensaje   OUT      VARCHAR2
   )
      RETURN NUMBER;

   FUNCTION f_aviso_servicio(
      pcservicio   IN       VARCHAR2,
      pcidioma     IN       NUMBER,
      ptmensaje    OUT      VARCHAR2
   )
      RETURN NUMBER;

   FUNCTION f_hay_franquicia(
      psseguro    IN       NUMBER,
      pnriesgo    IN       NUMBER,
      pnmovimi    IN       NUMBER,
      pcidioma    IN       NUMBER,
      ptmensaje   OUT      VARCHAR2
   )
      RETURN NUMBER;

/*************************************************************************
      ini 34866/206900 -- JR -- 18/06/2015

      FUNCTION f_valida_bene_accepted
      Funci¿n que valida retorna un aviso para la pantalla AXISCTR177 / AXISCTR006
      De manera que para MSV, el valor 'Accepted' solo se puede seleccionar
      si no estamos en nueva produccion. Este aviso se parametriza unicamente
      para el modo 'ALTA_POLIZA'.

      pctipben  in  NUMBER   :
      ptmensaje out VARCHAR2 : Texto de aviso si el tipo es beneficiario aceptado
     RETURN 0(ok),RETURN 1(ko)

     206900: Aviso 'Beneficiario aceptado no se permite durante nueva producci¿n'
   *************************************************************************/
   FUNCTION f_valida_bene_accepted(
      pctipben    IN       benespseg.ctipben%TYPE,
      pcidioma    IN       idiomas.cidioma%TYPE,
      ptmensaje   OUT      axis_literales.tlitera%TYPE
   )
      RETURN NUMBER;
-- fin 34866/206900 -- JR -- 18/06/2015

  FUNCTION f_aviso_sini_en_suspension(
    psseguro IN NUMBER,
    pnsinies IN VARCHAR2,
    pcidioma IN NUMBER,
    ptmensaje OUT VARCHAR2)
    RETURN NUMBER;
    
/*************************************************************************
      -- INI -IAXIS-5100 - JLTS - 22/08/2019

      FUNCTION f_valida_rango_dian_RC_RD
      Función que permite validar que no se puedan crear más de un registro de resoluciones
      para el Rango Dian de RC(802), grupo RD y con las misma sucursal.

		pnresol  : Resolución de la Dian
    pcramo   : Ramo 
    pCGRUPO  : Grupo
    pSUCURSAL: agente de tipo sucursal o agencia
    RETURN 0(ok),RETURN 1(ko)

    500000: Aviso 'No se puede crear más de una configuración para RC - Grupo RD - sucursal'
   *************************************************************************/

  FUNCTION f_valida_rango_dian_rc_rd(pnresol   rango_dian.nresol%TYPE,
                                     pcramo    rango_dian.cramo%TYPE,
                                     pcgrupo   rango_dian.cgrupo%TYPE,
                                     psucursal rango_dian.cagente%TYPE,
                                     pcidioma  IN idiomas.cidioma%TYPE,
                                     ptmensaje OUT VARCHAR2) RETURN NUMBER;
  -- FIN -IAXIS-5100 - JLTS - 22/08/2019



END pac_avisos;
/

  GRANT EXECUTE ON "AXIS"."PAC_AVISOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_AVISOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_AVISOS" TO "PROGRAMADORESCSI";
