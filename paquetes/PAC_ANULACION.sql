--------------------------------------------------------
--  DDL for Package PAC_ANULACION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_ANULACION" IS
   /******************************************************************************
      NOMBRE:       PAC_ANULACION
      PROP¿SITO: Funciones para anular

      REVISIONES:
      Ver        Fecha        Autor             Descripci¿n
      ---------  ----------  --------------  ------------------------------------
      1.0        19/12/2007  JAS              1. Creaci¿n del package.
      1.1        01/06/2007  MSR              2. Afegir funci¿ F_VALIDA_PERMITE_ANULAR_POLIZA
      1.2        01/06/2007  MSR              3. Modificar funci¿ F_ANULACION_POLIZA
      1.3        02/03/2009  DCM              4. Modificaciones Bug 8850
      2.0        14/05/2009  APD              5. Bug 9639: se crea la funcion f_esta_prog_anulproxcar
      2.2        19/05/2009  JTS              7. Bug 9914 - ANULACI¿N DE P¿LIZA - Baja inmediata
      3.0        27/05/2009  RSC              8. 0007926 APR - Fecha de vencimiento a nivel de garant¿a
      4.0        26/02/2009  ICV              9. 0013068: CRE - Grabar el motivo de la anulaci¿n al anular la p¿liza
      5.0        13/12/2010  ICV             10. 0016775: CRT101 - Baja de p¿lizas
      6.0        31/10/2011  APD             11. 0019557: LCOL_T001-Despeses expedici¿
      7.0        22/11/2011  RSC             12. 0020241: LCOL_T004-Parametrizaci¿n de Rescates (retiros)
      8.0        05/12/2011  JMF             13. 0020414: LCOL_T001-Despeses d'expedici¿ no prorrategen al extornar-se.
      9.0        11/07/2012  APD             14. 0022826: LCOL_T010-Recargo por anulaci¿n a corto plazo
     10.0        25/07/2012  AVT             15. 0022686: LCOL_A004-Cumulos anulados anteriormente a la alta de polizas
     11.0        27/09/2012  APD             16. 0023817: LCOL - Anulaci¿n de colectivos
     17.0        15/11/2012  DRA             17. 0024271: LCOL_T010-LCOL - SUPLEMENTO DE TRASLADO DE VIGENCIA
     18.0        14/12/2012  JDS             18. 0023183: LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
     19.0        12/07/2013  JGR             19. 0027644: No se ha de prorratear los conceptos de 14 y 86 en los recibos de tiempo transcurrido - QT-8596
     20.0        11/07/2014  DCT             20. 0032009: LCOL_PROD-LCOL_T031-Revisi¿n Fase 3A Producci¿n
     21.0        02/12/2014  RDD             21. 0028974: MSV0003-Desarrollo de Comisiones (COM04-Commercial Network Management)
   ******************************************************************************/

   /*
    {Declaraci¿n de tipos}
   */
   TYPE rrecibos IS RECORD(
      nrecibo        NUMBER,
      fmovini        DATE,
      fefecto        DATE,
      fvencim        DATE
   );

   TYPE recibos_pend IS TABLE OF rrecibos
      INDEX BY BINARY_INTEGER;

   TYPE recibos_cob IS TABLE OF rrecibos
      INDEX BY BINARY_INTEGER;

   /*
    { Funciones y procedimientos}
   */
   FUNCTION f_anulada_al_emitir(psseguro IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_anulacion_automatica(psseguro IN NUMBER, pfanulac IN DATE)
      RETURN NUMBER;

   -- Bug 22826 - APD - 11/07/2012 - se a¿ade el parametro paplica_penali
   FUNCTION f_anula_poliza(
      psseguro IN NUMBER,
      pcmotmov IN NUMBER,
      pcmoneda IN NUMBER,
      pfanulac IN DATE,
      pcextorn IN NUMBER,
      pcanular_rec IN NUMBER,
      pcagente IN NUMBER,
      rpend IN recibos_pend,
      rcob IN recibos_cob,
      psproduc IN NUMBER DEFAULT NULL,
      pcnotibaja IN NUMBER DEFAULT NULL,
      pcsituac IN NUMBER DEFAULT 2,
      pccauanul IN NUMBER DEFAULT NULL,
      paplica_penali IN NUMBER DEFAULT 0,
      pimpextorsion IN NUMBER DEFAULT 0)
      RETURN NUMBER;

   FUNCTION f_anula_poliza_vto(
      psseguro IN NUMBER,
      pcmotven IN NUMBER,
      pfanulac IN DATE,
      pcmotmov IN NUMBER DEFAULT 221,
      pnsuplem IN NUMBER DEFAULT NULL,
      pfcaranu IN DATE DEFAULT NULL,
      pcnotibaja IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_esta_anulada_vto(psseguro IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_es_desanulable(psseguro IN NUMBER, psproduc IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

--BUG10772-22/07/2009-JMF: CRE - Desanul¿lar programacions al venciment/propera cartera
   FUNCTION f_desanula_poliza_vto(
      psseguro IN NUMBER,
      pfanulac IN DATE,
      pnsuplem IN NUMBER DEFAULT NULL,
      psproduc IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_fecha_anulacion(psseguro IN NUMBER, pnriesgo IN NUMBER)
      RETURN DATE;

/*--
--  NOTA : Par¿metres rpend i rcob  NO S'UTILITZEN : Enviar-los sempre a NULL.
--
   FUNCTION f_anulacion_poliza(
      psseguro IN NUMBER,
      pcmotmov IN NUMBER,
      pcmoneda IN NUMBER,
      pfanulac IN DATE,
      pcextorn IN NUMBER,
      pcanular_rec IN NUMBER,
      pcagente IN NUMBER,
      rpend IN VARCHAR2,
      rcob IN VARCHAR2,
      psproduc IN NUMBER DEFAULT NULL,
      pcnotibaja IN NUMBER DEFAULT NULL)
      RETURN NUMBER;*/

   --SNV 07/02/2005
   --Se a¿ade el procedimiento para realizar anulaciones de polizas por vencimiento.
   PROCEDURE p_baja_automatico_vto(
      psproduc IN NUMBER,
      psseguro IN NUMBER,
      pfvencim IN DATE,
      psproces OUT NUMBER);

   --INICIO 32009 - DCT - 11/07/2014
   PROCEDURE p_baja_automatico_solicitudes(
      psproduc IN NUMBER,
      psseguro IN NUMBER,
      pfcancel IN DATE,
      psproces OUT NUMBER,
      poriduplic IN NUMBER DEFAULT NULL);

   --FIN 32009 - DCT - 11/07/2014
   FUNCTION f_anulacion_reemplazo(
      psseguro IN NUMBER,
      psreempl IN NUMBER,
      pcagente IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   /**********************************************************************************************
    Llista amb tots els rebuts d'una p¿lissa.
    Par¿metres entrada:
       psSeguro : Identificador de l'asseguran¿a   (obligatori)
       pFAnulac : Data d'anulaci¿ de la p¿lissa    (obligatori)
       pValparcial : Valida parcialmente              (opcional)  -- tarea 8435
                     1 posici¿ = 0 o 1
                     2 posici¿ = 1 no valida dies anulaci¿ (11)
                     3 posici¿ = 1 ...
    Torna :
       0 si es permet anular la p¿lissa, altrament torna un codi d'error
   **********************************************************************************************/
   FUNCTION f_valida_permite_anular_poliza(
      psseguro IN seguros.sseguro%TYPE,
      pfanulac IN seguros.fanulac%TYPE,
      pvalparcial IN NUMBER DEFAULT 0,
      panumasiva IN NUMBER DEFAULT 0)   -- tarea 8435
      RETURN NUMBER;

   FUNCTION f_baja_rec_pend(
      pfanulac IN DATE,
      rpend IN recibos_pend,
      pskipextanul IN NUMBER DEFAULT 0,
      pnmovimi IN NUMBER DEFAULT NULL,
      pcmotmov IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_extorn_rec_cobrats(
      psseguro IN NUMBER,
      pcagente IN NUMBER,
      pnmovimi IN NUMBER,
      pfanulac IN DATE,
      pcmoneda IN NUMBER,
      prcob IN recibos_cob,
      paplica_penali IN NUMBER DEFAULT 0,
      pimpextorsion IN NUMBER DEFAULT 0,
      pnmovimiaux IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_esta_prog_anulproxcar
      Verifica si est¿ programada la anulaci¿n.
      param in psseguro   : c¿digo del seguro
      return             : NUMBER -->  1.- si esta programada la anulaci¿n.
                                       0 .- No est¿ programada la anulaci¿n.
   *************************************************************************/
   FUNCTION f_esta_prog_anulproxcar(psseguro IN NUMBER)
      RETURN NUMBER;

--BUG 9914 - JTS - 19/05/2009
/*************************************************************************
   FUNCTION f_marcado
   param in pnrecibo  : Num. recibo
   param in pfanulac  : Fecha de anulacion
   return             : NUMBER -->  1.- Se tiene que anular
                                    0.- No se tiene que anular
*************************************************************************/
   FUNCTION f_marcado(pnrecibo IN NUMBER, pfanulac IN DATE)
      RETURN NUMBER;

/*************************************************************************
   FUNCTION f_recibos
   param in psseguro  : Num. seguro
   param in pfanulac  : Fecha de anulacion
   param out perror   : Numero de error
   param in pcestrec  : 0.- Pendiente, 1.- Cobrado
   return             : sys_refcursor
*************************************************************************/-- Bug 23807 - APD - 08/10/2012
   -- se a¿ade el parametro pbajacol = 0.Se est¿ realizando la baja de un certificado normal
   -- 1.Se est¿ realizando la baja del certificado 0
   FUNCTION f_recibos(
      psseguro IN NUMBER,
      pfanulac IN DATE,
      pctipocon IN NUMBER,
      pcidioma IN NUMBER,
      perror OUT NUMBER,
      pextahorro IN NUMBER DEFAULT 1,
      pbajacol IN NUMBER DEFAULT 0)
      RETURN sys_refcursor;

   FUNCTION f_recibos_anulados_mov(precibos IN VARCHAR2)
      RETURN NUMBER;   --rdd

/*************************************************************************
   FUNCTION f_recibos_anulables
   param in precibos  : Recibos
   param out perror   : Numero de error
   return             : sys_refcursor
*************************************************************************/
   FUNCTION f_recibos_anulables(precibos IN VARCHAR2, perror OUT NUMBER)
      RETURN sys_refcursor;

--
--  NOTA : Par¿metres rpend i rcob  NO S'UTILITZEN : Enviar-los sempre a NULL.
--
--   MSR 2007/06/01   Modificar funci¿ F_ANULACION_POLIZA. Ref 1880.
   FUNCTION f_anulacion_poliza(
      psseguro IN NUMBER,
      pcmotmov IN NUMBER,
      pcmoneda IN NUMBER,
      pfanulac IN DATE,
      pcextorn IN NUMBER,
      pcanular_rec IN NUMBER,
      pcagente IN NUMBER,
      rpend IN VARCHAR2,
      rcob IN VARCHAR2,
      psproduc IN NUMBER DEFAULT NULL,
      pcnotibaja IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

--Fi BUG 9914 - JTS - 19/05/2009

   /*************************************************************************
      FUNCTION f_anula_vto_cartera
        Indica si una garant¿a determinada vence o ha vencido a una fecha
        determinada.

      param in psseguro  : Identificador de seguro.
      param in pfecha    : Fecha de corte para el vencimiento
      return             : NUMBER (0 --> OK)
   *************************************************************************/
   -- Bug 7926 - 27/05/2009 - RSC - Fecha de vencimiento a nivel de garant¿a
   FUNCTION f_anula_vto_cartera(psseguro IN NUMBER, pcgarant IN NUMBER, pfecha IN DATE)
      RETURN NUMBER;

   /*************************************************************************
       FUNCTION f_anula_vto_garantias
         Realiza el vencimiento de aquellas garant¿as que hayan vencido.

       param in psseguro  : Identificador de seguro.
       param in pfecha    : Fecha de corte para el vencimiento
       param in psproces  : Marcador de proceso.
       return             : NUMBER (0 --> OK)
    *************************************************************************/-- Bug 7926 - 27/05/2009 - RSC - Fecha de vencimiento a nivel de garant¿a
   FUNCTION f_anula_vto_garantias(psseguro IN NUMBER, pfecha IN DATE, psproces IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
      PROCEDURE de baja de garant¿as para ser llamado desde procesos nocturnos.

      param in psseguro  : Identificador de seguro.
      param in pfecha    : Fecha de corte para el vencimiento
      param in psproces  : Marcador de proceso.
   *************************************************************************/
   -- Bug 7926 - 27/05/2009 - RSC - Fecha de vencimiento a nivel de garant¿a
   PROCEDURE p_baja_automatica_gars(psseguro IN NUMBER, pfecha IN DATE, psproces IN NUMBER);

   --Ini Bug.: 16775 - ICV - 30/11/2010
   /***********************************************************************
      Funci¿n que realiza una solicitud de Anulaci¿n.
      param in psseguro  : c¿digo de seguro
      param in pctipanul  : tipo anulaci¿n
      param in pnriesgo  : n¿mero de riesgo
      param in pfanulac  : fecha anulaci¿n
      param in ptobserv  : Observaciones.
      param in pTVALORD  : Descripci¿n del motivio.
      param in pcmotmov  : Causa anulacion.
      return             : 0.- proceso correcto
                           1.- error
   ***********************************************************************/
   FUNCTION f_set_solanulac(
      psseguro IN NUMBER,
      pctipanul IN NUMBER,
      pnriesgo IN NUMBER,
      pfanulac IN DATE,
      ptobserv IN VARCHAR2,
      ptvalord IN VARCHAR2,
      pcmotmov IN NUMBER)
      RETURN NUMBER;

   --Ini Bug.: 19276 - jbn - Reemplazos
   /***********************************************************************
     Funci¿n que anula la p¿liza a reemplazar a fecha de efecto de la
     nueva p¿liza, genera extorno de los recibos si corresponde y anula
     recibos pendientes con fecha de efecto posterior a la fecha
     de efecto del reemplazo
    1.   psseguro: Identificador del seguro (IN)
    2.   pcmotmov: Motivo de anulaci¿n de la p¿liza (IN)
    3.   pcmoneda: C¿digo de moneda (IN)
    4.   pfanulac: Fecha de anulaci¿n (IN)
    5.   pcextorn: Indica si se debe procesar el extorno (IN)
    6.   pcanular_rec: Indica si se deben anular recibos (IN)
    7.   pcagente: C¿digo del agente (IN)
    8.   rpend: Lista de recibos pendientes (de momento no se utiliza en el c¿digo) (IN)
    9.   rcob: Lista de recibos cobrados (de momento no se utiliza en el c¿digo) (IN)
    10.  psproduc: Identificador del producto (IN)
    11.  pcnotibaja (IN)
    12.  pcsituac (IN)
    13.  pccauanul: Causa de anulaci¿n de la p¿liza (IN)

      return             : 0.- proceso correcto
                           1.- error
   ***********************************************************************/
   FUNCTION f_anula_poliza_reemplazo(
      psseguro IN NUMBER,
      pcmotmov IN NUMBER,
      pcmoneda IN NUMBER,
      pfanulac IN DATE,
      pcextorn IN NUMBER,
      pcanular_rec IN NUMBER,
      pcagente IN NUMBER,
      rpend IN VARCHAR2,
      rcob IN VARCHAR2,
      psproduc IN NUMBER DEFAULT NULL,
      pcnotibaja IN NUMBER DEFAULT NULL,
      pcsituac IN NUMBER DEFAULT 2,
      pccauanul IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

--fi Bug.: 19276 - jbn - Reemplazos

   /***********************************************************************
     Funcion para determinar si se debe realizar o no el retorno de un recibo a extornar
    1.   psseguro: Identificador del seguro (IN)
    2.   pnmovimi: Numero de movimiento (IN)
    3.   psproduc: Identificador del producto (IN)
    4.   pcconcep: Concepto del recibo a extornar (IN)
    5.   pfanulac: Fecha de anulaci¿n
      return             : NUMBER (0 --> OK)
   ***********************************************************************/
   -- Bug 19557 - APD - 31/10/2011- se crea la funcion
   -- BUG 0020414 - 05/12/2011 - JMF: a¿adir pnfactor
   FUNCTION f_concep_retorna_anul(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      psproduc IN NUMBER,
      pcconcep IN NUMBER,
      pfanulac IN DATE,
      pnfactor IN OUT NUMBER,
      pcmotmov IN NUMBER DEFAULT NULL   -- 19. 0027644 - QT-8596
                                     )
      RETURN NUMBER;

   /***********************************************************************
     Funcion para determinar si se debe mostrar o no el check Anulacion a corto plazo
    1.   psproduc: Identificador del producto (IN)
    2.   pcmotmov: Motivo de movimiento (IN)
    3.   psseguro: Identificador de la poliza (IN)
    4.   pcvisible: Devuelve 0 si no es visible, 1 si si es visible (OUT)
      return             : NUMBER (0 --> OK)
   ***********************************************************************/
   -- Bug 22826 - APD - 12/07/2012- se crea la funcion
   -- Bug 23817 - APD - 04/10/2012 - se a¿ade el parametro psseguro
   FUNCTION f_aplica_penali_visible(
      psproduc IN NUMBER,
      pcmotmov IN NUMBER,
      psseguro IN NUMBER,
      pcvisible OUT NUMBER)
      RETURN NUMBER;

   -- BUG: 22686 - AVT -25/07/2012 es fa visible la funci¿ existent per poder-la utilitzar des de la f_cessio
   FUNCTION f_baja_rea(psseguro IN NUMBER, pfanulac IN DATE, pcmoneda IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_recibos_colectivo
      Funcion para recuperar los recibos de un colectivo (los recibos
      del certificado 0 m¿s todos los recibos de todos sus certificados
      teniendo en cuenta la agrupacion de recibos)
      param in psseguro  : Num. seguro
      param in pfanulac  : Fecha de anulacion
      param out perror   : Numero de error
      param in pcestrec  : 0.- Pendiente, 1.- Cobrado
      return             : sys_refcursor
   *************************************************************************/
   -- Bug 23817 - APD - 27/09/2012 - se crea la funcion
   FUNCTION f_recibos_colectivo(
      psseguro IN NUMBER,
      pfanulac IN DATE,
      pctipocon IN NUMBER,
      pcidioma IN NUMBER,
      perror OUT NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
                                       FUNCTION F_CALCUL_EXTORN_RECIBOS_MANUAL
      Funcion que realiza el c¿lculo del extorno aplicado a partir del importe
      introducido por el usuario.
      param in psseguro  : Num. seguro
      param in pnrecibo  : Num recibo extorno
      param in pimpextorsion : Importe introducido por el usuario
      return   RESULT   : 0 - ok / 1 - ko
   *************************************************************************/
   -- 23183  JDS 14/12/2012  creaci¿n de funci¿n
   FUNCTION f_calcul_extorn_recibos_manual(
      pseguro IN NUMBER,
      pnrecibo IN NUMBER,
      pimpextorsion IN NUMBER)
      RETURN NUMBER;

    /*********************************************
    Funcion que devuelve si el padre de un recibo esta cobrado
    Bug 37028/214287 - 23/09/2015 - AMC
   **********************************************/
   FUNCTION f_padre_cobrado(pnrecibo NUMBER)
      RETURN NUMBER;
END pac_anulacion;

/

  GRANT EXECUTE ON "AXIS"."PAC_ANULACION" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_ANULACION" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_ANULACION" TO "PROGRAMADORESCSI";
