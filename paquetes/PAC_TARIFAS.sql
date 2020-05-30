--------------------------------------------------------
--  DDL for Package PAC_TARIFAS
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE "PAC_TARIFAS" IS
   /******************************************************************************
      NOMBRE:     PAC_TARIFAS
      PROPÓSITO:  Funciones tarifas

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        XX/XX/XXXX   XXX                1. Creación del package.
      1.1        20/03/2009   JRH                2. 0009541: CRE - Incidència Cartera de Decesos
      1.2        27/03/2009   XCG                3. 009595: Se ha modificado la llamada a la funció F_CTIPGAR (dentro de la función F_TMPGARANCAR)
      2.0        17/04/2009   APD                4. Bug 9699 - primero se ha de buscar para la actividad en concreto
                                                    y si no se encuentra nada ir a buscar a PARGARANPRO para la actividad cero
      2.1        22/04/2009   YIL                5. Bug 9794 - Se añade un NVL en iprianu en f_tarifar_risc
      2.2        30/04/2009   YIL                6. Bug 9524 - Se cambia el orden by del cursor tmp_garancar de forma que tenga en cuenta el parámetro ORDEN_TARIF_CARTERA
      3.0        13/05/2009   AVT                7. 0009549: CRE - Reaseguro de ahorro.
      4.0        04/06/2009   RSC                8. Bug 10350: APR - Detalle garantías (tarificación)
                                                    Iniciamos ajustes en PAC_TARIFAS para tarificación de DETGARANSEG.
      5.0        01/07/2009   NMM                9. 10728.CEM - Asignación automática de sobreprima.
      6.0        19/01/2010   RSC               10. 0011735: APR - suplemento de modificación de capital /prima
      7.0        10/06/2010   RSC               11. 0013832: APRS015 - suplemento de aportaciones únicas
      8.0        14/04/2011   FAL               12. 0018172: CRT - Modificacion documentación
      9.0        28/12/2011   APD               13. 0020448: LCOL - UAT - TEC - Despeses d'expedició no es fraccionen
      10.0       03/01/2012   DRA               10. 0020498: LCOL_T001-LCOL - UAT - TEC - Beneficiaris de la p?lissa
      11.0       22/02/2012   APD               11. 0021121: MDP701 - TEC - DETALLE DE PRIMAS DE GARANTIAS
      12.0       08/03/2012   APD               12. 0021127: MDP_T001- TEC - PRIMA MÍNIMA
      13.0       21/03/2013   dlF               13. 0025870: AGM900 - Nuevo producto sobreprecio frutales 2013
      14.0       30/01/2015   AFM               14. 0034462: Suplementos de convenios (retroactivos)
      15.0       01/02/2016   FAL               15. 0039498: ERROR AL REGULARIZAR (bug hermano interno)
	  16.0       16/07/2019   CJMR              16. IAXIS-4779: 
   ******************************************************************************/
   FUNCTION f_clave(
      pcgarant IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pcactivi IN NUMBER,
      pccampo IN VARCHAR2,
      pclave OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_tarifar(
      psesion IN NUMBER,
      pcmanual IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pcont IN NUMBER,
      parms_transitorios IN OUT pac_parm_tarifas.parms_transitorios_tabtyb,
      piprianu IN OUT NUMBER,
      pipritar IN OUT NUMBER,
      prevcap IN OUT NUMBER,
      pcapitalcal OUT NUMBER,
      pdtocom OUT NUMBER,
      ptasa IN OUT NUMBER,
      pmensa IN OUT VARCHAR2,
      pmoneda IN NUMBER,
      pctarifa IN NUMBER,
      pnmovimi IN NUMBER,
      pnmovima IN NUMBER,
      -- Mantis 10728.NMM.i.01/07/2009.CEM - Asignación automática de sobreprima.
      p_iextrap OUT NUMBER /* Extraprima */,
      p_isobrep OUT NUMBER,                         /* Sobreprima */
                              /* Mantis 10728.NMM.f. */
      p_tregconcep OUT pac_parm_tarifas.tregconcep_tabtyp,
      -- Bug 21121 - APD - 22/02/2012
      paccion IN VARCHAR2 DEFAULT 'NP')   -- BUG 34462 - AFM 01/2015
      RETURN NUMBER;

   FUNCTION f_tarifar_risc(
      psproces IN NUMBER,
      ptablas IN VARCHAR2,
      pfuncion IN VARCHAR2,
      pmodo IN VARCHAR2,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      paplica_bonifica IN NUMBER,
      pbonifica IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfcarpro IN DATE,
      pfefecto IN DATE,
      pcmanual IN NUMBER,
      pcobjase IN NUMBER,
      pcforpag IN NUMBER,
      pidioma IN NUMBER,
      pmes IN NUMBER,
      panyo IN NUMBER,
      pmoneda IN NUMBER DEFAULT 2,
      parms_transitorios IN OUT pac_parm_tarifas.parms_transitorios_tabtyb,
      ptotal_prima OUT NUMBER,
      pmensa OUT VARCHAR2,
      paccion IN VARCHAR2 DEFAULT 'NP',
      pnmovimi IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_tarifar_126(
      psproces IN NUMBER,
      ptablas IN VARCHAR2,
      pfuncion IN VARCHAR2,
      pmodo IN VARCHAR2,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      paplica_bonifica IN NUMBER,
      pbonifica IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfcarpro IN DATE,   --pfemisio           IN   DATE,
      pfefecto IN DATE,
      pcmanual IN NUMBER,
      pcobjase IN NUMBER,
      pcforpag IN NUMBER,
      pidioma IN NUMBER,
      pmes IN NUMBER,
      panyo IN NUMBER,
      pmoneda IN NUMBER,
      pcclapri IN NUMBER,
      pprima_minima OUT NUMBER,
      ptotal_prima OUT NUMBER,
      pmensa OUT VARCHAR2,
      paccion IN VARCHAR2 DEFAULT 'NP',
      pnmovimi IN NUMBER DEFAULT NULL   --Bug 21127 - APD - 08/03/2012
                                     )
      RETURN NUMBER;

   FUNCTION f_insertar_preguntas_poliza(
      psesion IN NUMBER,
      psproces IN NUMBER,
      ptablas VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pnmovimi IN NUMBER,
      pfcarpro IN DATE,
      pmodo VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_insertar_preguntas_riesgo(
      psesion IN NUMBER,
      psproces IN NUMBER,
      ptablas VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pnmovimi IN NUMBER,
      pfcarpro IN DATE,
      pmodo VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_insertar_preguntas_garantia(
      psesion IN NUMBER,
      psproces IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      ptablas IN VARCHAR2,
      pfefecto IN DATE,
      pnmovimi IN NUMBER,
      pfiniefe IN DATE,
      pnmovima IN NUMBER,
      picapital IN NUMBER,
      paccion IN VARCHAR2 DEFAULT 'NP')
-- Bug 13832 - RSC - 10/06/2010 - APRS015 - suplemento de aportaciones únicas
   RETURN NUMBER;

   -- BUG20498:DRA:03/01/2012:Inici
   FUNCTION f_insertar_preguntas_clausulas(
      psesion IN NUMBER,
      psproces IN NUMBER,
      ptablas VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pnmovimi IN NUMBER,
      pfcarpro IN DATE,
      pmodo VARCHAR2)
      RETURN NUMBER;

   -- BUG20498:DRA:03/01/2012:Fi
   FUNCTION f_tmpgarancar(
      ptablas IN VARCHAR2,
      psproces IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      fecharef IN DATE := NULL)   --JRH Añadimos una fecha de referencia para simulaciones de renovación
      RETURN NUMBER;

   PROCEDURE continente_contenido(
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pcactivi IN NUMBER,
      cont IN NUMBER,
      parms_transitorios IN OUT pac_parm_tarifas.parms_transitorios_tabtyb);

   FUNCTION f_dto_vol(
      psesion IN NUMBER,
      psseguro IN NUMBER,
      pcgarant IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pccolect IN NUMBER,
      pctipseg IN NUMBER,
      pcactivi IN NUMBER,
      cont IN NUMBER,
      prima_total IN NUMBER,
      piprianu IN OUT NUMBER,
      mensa IN OUT VARCHAR2,
      parms_transitorios IN OUT pac_parm_tarifas.parms_transitorios_tabtyb)
      RETURN NUMBER;

   FUNCTION f_insertar_matriz(
      ptablas IN VARCHAR2,
      psproces IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfecha IN DATE)
      RETURN NUMBER;

   FUNCTION f_regul_prima_min(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      psproduc IN NUMBER,
      pfefecto IN DATE,
      pprima_total IN NUMBER,
      pprima_minima OUT NUMBER,
      pcclapri IN NUMBER,
      parms_transitorios IN OUT pac_parm_tarifas.parms_transitorios_tabtyb,
      psproces IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pcactivi IN NUMBER,
      pfuncion IN VARCHAR2)
      RETURN NUMBER;

   -- Bug 11735 - RSC - 19/01/2010 - APR - suplemento de modificación de capital /prima (afegim parámetre pmodali)
   FUNCTION f_tarifar_riesgo_tot(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pmoneda IN NUMBER,
      pfecha IN DATE,
      paccion IN VARCHAR2 DEFAULT 'NP',
      pmodali IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;

    --FUNCTION f_calcula_iconcepto(
     --  piprianu IN NUMBER,
    --   pidtocom IN NUMBER,
    --   pnvalcon IN NUMBER,
   --    ptot_recfrac IN NUMBER,
     --  pctipcon IN NUMBER,
    --   pcforpag IN NUMBER,
    --   pcbonifica IN NUMBER,
    --   oiconcep OUT NUMBER)
   --    RETURN NUMBER;

   /***********************************************************************
      Càlcul del concepte de rebut a aplicar en funció d'una determinada prima anual, forma de pagament i producte.
      param in pcconcep    : código del concepto que se desea calcular (VF 27)
      param in pfiniefe    : fecha inicio efecto de la cobertura (para prorrateo)
      param in pffinefe    : fecha fin efecto de la cobertura (para prorrateo)
      param in pcrecfra    : indica si existe recargo por fraccionamiento o no
      param in pcactivi    : código de la actividad
      param in pcgarant    : código de la garantia
      param in pcforpag    : código forma de pago
      param in piprianu    : prima anual
      param out oiconcep   : importe del concepto
      return               : 0/1 -> Ok/Error
   ***********************************************************************/
   FUNCTION f_calcula_concepto(
      pcconcep IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pfiniefe IN DATE,
      pffinefe IN DATE,
      pcrecfra IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pcforpag IN NUMBER,
      piprianu IN NUMBER,
      pidtocom IN NUMBER,
      pmode IN VARCHAR2,
      oiconcep OUT NUMBER)
      RETURN NUMBER;

   /***********************************************************************
      Càlcul del concepte de rebut a aplicar en funció d'una determinada prima anual, forma de pagament i producte.
      param in psseguro    : código del seguro
      param in pmode       : modo
      param in pcconcep    : código del concepto que se desea calcular (VF 27)
      param in pcrecfra    : indica si existe recargo por fraccionamiento o no
      param in pcgarant    : código de la garantia
      param in piprianu    : prima anual
      param out oiconcep   : importe del concepto
      return               : 0/1 -> Ok/Error
   ***********************************************************************/
   FUNCTION f_calcula_concepto(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pmode IN VARCHAR2,
      pcconcep IN NUMBER,
      pcrecfra IN NUMBER,
      pcgarant IN NUMBER,
      piprianu IN NUMBER,
      pidtocom IN NUMBER,
      oiconcep OUT NUMBER)
      RETURN NUMBER;

   /***********************************************************************
      Ens retorna informació anual de la pòlissa
      param in psseguro    : codi intern
      param in P_CONCEPTE  : Concepte que es desitja mostrar. Pot ser:
                             'PR_ANUAL_NETA' ---> Prima Anual Neta (iprianu de garanseg)
                             'PR_ANUAL'      ---> Prima Anual Neta + Consorci + IPS + CLEA
                             'CONSOR'        ---> Rec. Consorci
                             'IPS'           ---> Rec. IPS
                             'CLEA'          ---> Rec. CLEA/DGS
                             'FRACC'         ---> Rec. Fraccionament
      param in P_MODE      : 'POL' / 'EST'
      return               : Concepte anual
   ***********************************************************************/
   FUNCTION f_importes_anuales(
      p_sseguro IN NUMBER,
      p_concepte IN VARCHAR2,
      p_mode IN VARCHAR2 DEFAULT 'POL',
      p_nmovimi IN NUMBER DEFAULT NULL)
-- Bug 0025870 - dlF - 21/03/2013 - AGM900 - Nuevo producto sobreprecio frutales 2013
   RETURN NUMBER;

   /***********************************************************************
      Ens retorna informació anual de la pòlissa
      param in psseguro    : codi intern
      param in P_CONCEPTE  : Concepte que es desitja mostrar. Pot ser:
                             'PR_ANUAL_NETA' ---> Prima Anual Neta (iprianu de garanseg)
                             'PR_ANUAL'      ---> Prima Anual Neta + Consorci + IPS + CLEA
                             'CONSOR'        ---> Rec. Consorci
                             'IPS'           ---> Rec. IPS
                             'CLEA'          ---> Rec. CLEA/DGS
                             'FRACC'         ---> Rec. Fraccionament
      param in P_NRIESGO   :  codi risc
      param in P_MODE      : 'POL' / 'EST'
      return               : Concepte anual
   ***********************************************************************/
   FUNCTION f_importes_anuales_riesgo(
      p_sseguro IN NUMBER,
      p_concepte IN VARCHAR2,
      p_nriesgo IN NUMBER,
      p_mode IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

   /***********************************************************************
      Funcion que devuelve algunos parametros (valores) necesarios para calcular
      el importe del concepto
      param in psseguro    : código del seguro
      param in pmode       : modo
      param in pcconcep    : código del concepto que se desea calcular (VF 27)
      param in pcrecfra    : indica si existe recargo por fraccionamiento o no
      param in pcgarant    : código de la garantia
      param in piprianu    : prima anual
      param in piconcep   : importe del concepto
      param out ofefecto : fecha inicio efecto de la cobertura
      param out ofcaranu : fecha fin efecto de la cobertura
      param out osproduc : identificador del producto
      param out ocactivi : codigo de la actividad
      param out ocforpag : forma de pago del seguro
      return               : importe del concepto dividido entre la forma de pago si aplica (segun imprec.cfracci)
   ***********************************************************************/
   -- Bug 20448 - APD - 28/12/2011 - se crea la funcion
   FUNCTION f_param_concepto(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pmode IN VARCHAR2,
      pcconcep IN NUMBER,
      pcrecfra IN NUMBER,
      pcgarant IN NUMBER,
      piprianu IN NUMBER,
      pidtocom IN NUMBER,
      piconcep IN NUMBER,
      ofefecto OUT DATE,
      ofcaranu OUT DATE,
      osproduc OUT NUMBER,
      ocactivi OUT NUMBER,
      ocforpag OUT NUMBER)
      RETURN NUMBER;

   /***********************************************************************
      Funcion que devuelve informada la tabla de conceptos tregconcep para un campo de GARANFORMULA
      param in psproduc    : código del producto
      param in pcactivi    : Actividad
      param in pcgarant    : codigo de la garantia
      param in pccampo     : campo de garanformula
      param in pssesion    : secuencia de la sesion
      param in/out ptregconcep : tabla de conceptos
      return               : 0 (todo Ok); num_err (si hay algún error)
   ***********************************************************************/
   -- Bug 21121 - APD - 22/02/2012 - se crea la funcion
   FUNCTION f_dettarifar(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pccampo IN VARCHAR2,
      psesion IN NUMBER,
      pcont IN NUMBER,
      parms_transitorios IN pac_parm_tarifas.parms_transitorios_tabtyb,
      ptregconcep IN OUT pac_parm_tarifas.tregconcep_tabtyp)
      RETURN NUMBER;

   /***********************************************************************
      Funcion que aplica la prima mínima
   ***********************************************************************/
   -- Bug 21127 - APD - 06/03/2012 - se crea la funcion
   FUNCTION f_prima_minima(
      ptablas VARCHAR2,
      psseguro NUMBER,
      pnriesgo NUMBER,
      psproduc NUMBER,
      pfefecto DATE,
      parms_transitorios pac_parm_tarifas.parms_transitorios_tabtyb,
      psproces NUMBER,
      pcactivi NUMBER,
      pfuncion VARCHAR2,
      pcnivel NUMBER,
      pcposicion NUMBER,
      pnmovimi NUMBER,
      pmoneda NUMBER,   -- Bug 26923/0146769 - APD - 17/06/2013
      paccion VARCHAR2 DEFAULT NULL   -- BUG 0039498 - FAL - 01/02/2016
                                   )
      RETURN NUMBER;

   /***********************************************************************
      Funcion que calcula el BONUS/MALUS
   ***********************************************************************/
   -- Bug 21127 - APD - 08/03/2012 - se crea la funcion
   FUNCTION f_calcula_bonusmalus(
      ptablas VARCHAR2,
      psseguro NUMBER,
      pnriesgo NUMBER,
      psproduc NUMBER,
      pfefecto DATE,
      parms_transitorios pac_parm_tarifas.parms_transitorios_tabtyb,
      psproces NUMBER,
      pcactivi NUMBER,
      pfuncion VARCHAR2,
      pnmovimi NUMBER)
      RETURN NUMBER;

   FUNCTION f_insert_tmpdetprimas(
      psproces IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      pnmovimi IN NUMBER,
      pfiniefe IN DATE,
      pccampo VARCHAR2,
      pcconcep VARCHAR2,
      pnorden IN NUMBER,
      piconcep IN NUMBER)
      RETURN NUMBER;

   -- Bug 30171/173304 - 24/04/2014 - AMC
   FUNCTION f_factor_proteccion(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pnmovima IN NUMBER,
      pfefecto IN DATE,
      psproces IN NUMBER,
      pprima IN NUMBER,
      paccion IN VARCHAR2)
      RETURN NUMBER;

   /***********************************************************************
      Funcion que genera registros en la tabla tramosregul
   ***********************************************************************/
   -- BUG 34462 - AFM 01/2015
   FUNCTION f_generar_tabla_tramos(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pfefecto IN DATE,
      pctipo IN NUMBER,
      psproces IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_valor_act(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      pnmovimi IN NUMBER,
      pcampo IN VARCHAR2)
      RETURN NUMBER;

   PROCEDURE p_tratapre_detalle_garant(
      psproduc IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      psproces IN NUMBER,
      ptablas IN VARCHAR2);

   PROCEDURE p_trata_detalle_garant(
      psproduc IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      psproces IN NUMBER,
      ptablas IN VARCHAR2);
    
	--INI CJMR 4779
	PROCEDURE p_valida_garan(
      psseguro IN NUMBER);
	--FIN CJMR 4779
	  
END pac_tarifas;

/