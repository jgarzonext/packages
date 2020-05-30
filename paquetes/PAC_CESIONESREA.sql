--------------------------------------------------------
--  DDL for Package PAC_CESIONESREA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_CESIONESREA" 
IS
   /******************************************************************************
   NOMBRE:     PAC_CESIONESREA
   PROPÓSITO:  Conté les funcions de creació de cessions de reassegurança.
   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  -------- ------------------------------------
   1.0        XX/XX/XXXX   XXX     1. Creación del package.
   1.1        13/05/2009   AVT     2. 0009549: CRE - Reaseguro de ahorro.
   2.0        16/06/2009   ETM     3. 0010462: IAX - REA - Eliminar tabla FACPENDIENTES
   3.0        01/06/2009   NMM     4. 10344: CRE - Cesiones a reaseguro incorrectas.
   4.0        17/11/2009   JMF     4. 0012020 CRE - Ajustar reassegurança d'estalvi (PPJ)
   5.0        01/12/2009   NMM     6. 11845.CRE - Ajustar reassegurança d'estalvi.
   6.0        10/08/2010   RSC     7. 14775: AGA003 - Error en dades rebut plantilla Condicionat Particular AGA012
   7.0        19/10/2011   JRB     8. 19484 - Se añaden las funciones est para el reaseguro.
   8.0        07/03/2012   AVT     9. 21559 - LCOL999 Nova funció per pòlisses amb temporalitat
   9.0        03/10/2013   AGG     10. 28358 Nueva función para calcular el capital del cumulo
   10.0       09/10/2013   AGG     11. 28358 Cambiado el nombre a la función que devuelve el capital del cumulo porque no cabe en sgt_Term_form
   11.0       10/10/2013   AGG     11. 28358 Cambiado el tipo del parametro pfdnombre a la función que devuelve el capital del cumulo porque no cabe en
   sgt_Term_form
   12.0       17/11/2015   DCT     12. 38692 Añadir nueva función f_calcula_vto_poliza
   13.0       25/04/2016   JCP     13. BUG 41728-234063 --JCP 25/04/2016 Creacion funcion f_control_cesion
   14.0       02/09/2016   HRE     14. CONF-250: Se incluye manejo de contratos Q1, Q2, Q3
   15.0       09/11/2016   HRE     15. CONF-294: Se incluye funciones para cumulo por tomador y zona geografica.
   16.0       20/01/2017   HRE     16. CONF-479: Suplemento aumento de valor
   ******************************************************************************/
   FUNCTION f_garantarifa_rea(
         psproces IN NUMBER,
         psseguro IN NUMBER,
         pnmovimi IN NUMBER,
         pcramo IN NUMBER,
         pcmodali IN NUMBER,
         pctipseg IN NUMBER,
         pccolect IN NUMBER,
         psproduc IN NUMBER,
         pcactivi IN NUMBER,
         pfcarpro IN DATE,
         pfemisio IN DATE,
         pcmanual IN NUMBER,
         pcobjase IN NUMBER,
         pcforpag IN NUMBER,
         pcidioma IN NUMBER,
         pmoneda IN NUMBER)
      RETURN NUMBER;

   --BUG 19484 - 19/10/2011 - JRB - Se añaden las funciones est para el reaseguro.
   FUNCTION f_garantarifa_rea_est(
         psproces IN NUMBER,
         psseguro IN NUMBER,
         pnmovimi IN NUMBER,
         pcramo IN NUMBER,
         pcmodali IN NUMBER,
         pctipseg IN NUMBER,
         pccolect IN NUMBER,
         psproduc IN NUMBER,
         pcactivi IN NUMBER,
         pfcarpro IN DATE,
         pfemisio IN DATE,
         pcmanual IN NUMBER,
         pcobjase IN NUMBER,
         pcforpag IN NUMBER,
         pcidioma IN NUMBER,
         pmoneda IN NUMBER,
         ptablas IN VARCHAR2 DEFAULT 'EST')
      RETURN NUMBER;

   -----------------------------------------------------------------------
   -- Tarifica per SGT les garanties per obtenir la prima de reassegurança
   -- el capital i la capacitat del contracte (ple)
   -----------------------------------------------------------------------
   -----------------------------------------------------------------------
   FUNCTION f_traspas_cuafacul(
         psproces IN NUMBER,
         psseg_est IN NUMBER,
         psseguro IN NUMBER)
      RETURN NUMBER;

   -----------------------------------------------------------------------
   -- Traspassa el quadre de l'estudi a la pòlissa
   -----------------------------------------------------------------------
   FUNCTION f_reacumul(
         psseguro IN NUMBER,
         pnriesgo IN NUMBER,
         pscontra IN NUMBER,
         pnversio IN NUMBER,
         pfefecto IN DATE,
         psproduc IN NUMBER,
         pscumulo OUT NUMBER)
      RETURN NUMBER;

   -----------------------------------------------------------------------
   -- Traspassa el quadre de l'estudi a la pòlissa
   -----------------------------------------------------------------------
   FUNCTION f_reacumul_est(
         psseguro IN NUMBER,
         pnriesgo IN NUMBER,
         pscontra IN NUMBER,
         pnversio IN NUMBER,
         pfefecto IN DATE,
         psproduc IN NUMBER,
         pscumulo OUT NUMBER,
         ptablas IN VARCHAR2 DEFAULT 'EST')
      RETURN NUMBER;

   -----------------------------------------------------------------------
   -- Cúmuls automàtics
   -----------------------------------------------------------------------
   FUNCTION f_ple_cumul(
         psseguro IN NUMBER,
         pscumulo IN NUMBER,
         pcgarant IN NUMBER,
         pfefecto IN DATE,
         pcapcum OUT NUMBER,
         pipleno OUT NUMBER,
         picapaci OUT NUMBER)
      RETURN NUMBER;

   --BUG 19484 - 19/10/2011 - JRB - Se añaden las funciones est para el reaseguro.
   -----------------------------------------------------------------------
   -- Cúmuls automàtics
   -----------------------------------------------------------------------
   FUNCTION f_ple_cumul_est(
         psseguro IN NUMBER,
         pscumulo IN NUMBER,
         pcgarant IN NUMBER,
         pfefecto IN DATE,
         pcapcum OUT NUMBER,
         pipleno OUT NUMBER,
         picapaci OUT NUMBER,
         ptablas IN VARCHAR2 DEFAULT 'EST')
      RETURN NUMBER;

   ------------------------------------------------------------------------------
   -- Obtenim l'import sumat del tram 0 del cúmul
   ------------------------------------------------------------------------------
   FUNCTION f_ple_cumul_tot(
         psseguro IN NUMBER,
         pscumulo IN NUMBER,
         pcgarant IN NUMBER,
         pfefecto IN DATE,
         pscontra IN NUMBER,
         pnversio IN NUMBER,
         pcapcum_tot OUT NUMBER,
         pipleno_tot OUT NUMBER)
      RETURN NUMBER;

   --BUG 19484 - 19/10/2011 - JRB - Se añaden las funciones est para el reaseguro.
   ------------------------------------------------------------------------------
   -- Obtenim l'import sumat del tram 0 del cúmul
   ------------------------------------------------------------------------------
   FUNCTION f_ple_cumul_tot_est(
         psseguro IN NUMBER,
         pscumulo IN NUMBER,
         pcgarant IN NUMBER,
         pfefecto IN DATE,
         pscontra IN NUMBER,
         pnversio IN NUMBER,
         pcapcum_tot OUT NUMBER,
         pipleno_tot OUT NUMBER,
         ptablas IN VARCHAR2 DEFAULT 'EST')
      RETURN NUMBER;

   --
   -- total del cumulo per garanties que sumen juntes
   ------------------------------------------------------------------------------
   FUNCTION f_gar_rea(
         pcramo IN NUMBER,
         pcmodali IN NUMBER,
         pctipseg IN NUMBER,
         pccolect IN NUMBER,
         pcactivi IN NUMBER,
         pcgarant IN NUMBER,
         pcreaseg OUT NUMBER)
      RETURN NUMBER;

   ------------------------------------------------------------------------------
   -- Indica si una garantia es reassegura
   ------------------------------------------------------------------------------
   -- Bug 0014775 - RSC - 10/08/2010 - AGA003 - Error en dades rebut plantilla Condicionat Particular AGA012 (afegim pmodo)
   FUNCTION f_cessio_det(
         psproces IN NUMBER,
         psseguro IN NUMBER,
         pnrecibo IN NUMBER,
         pcactivi IN NUMBER,
         pcramo IN NUMBER,
         pcmodali IN NUMBER,
         pctipseg IN NUMBER,
         pccolect IN NUMBER,
         pfefecto IN DATE,
         pfvencim IN DATE,
         pnfactor IN NUMBER,
         pmoneda IN NUMBER,
         pcmotces IN NUMBER DEFAULT 1,
         pmodo IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;

   ------------------------------------------------------------------------------
   -- Crea les cessions de prima per detall de rebut
   -- pcmotces 1 - EMISSIÓ, 3- Regularització cúmul
   ------------------------------------------------------------------------------
   ------------------------------------------------------------------------------
   FUNCTION f_cesdet_anu(
         pnrecibo IN NUMBER)
      RETURN NUMBER;

   ------------------------------------------------------------------------------
   -- Anul·la la cessió del rebut
   ------------------------------------------------------------------------------
   ------------------------------------------------------------------------------
   FUNCTION f_cessio_det_per(
         psseguro IN NUMBER,
         pdataini IN DATE,
         pdatafi IN DATE,
         psproces IN NUMBER)
      RETURN NUMBER;

   ------------------------------------------------------------------------------
   -- Genera les cessions a reasegemi i detreasegemi per les pòlisses que es
   -- calcula la seva cessió anualitzada (cesionesrea) en el quadre d'amortització
   -- Aquest detall serà exactament pel periode de cessionesrea i amb els mateixos
   -- imports, és a dir que es copia dels cessionesrea del procés psproces
   ------------------------------------------------------------------------------
   ------------------------------------------------------------------------------
   FUNCTION f_cesdet_anu_per(
         psseguro IN NUMBER,
         pdata IN DATE,
         pmotces IN NUMBER)
      RETURN NUMBER;

   ------------------------------------------------------------------------------
   -- Anul·la les cessions de la pòlissa a partir de la data pdata amb el motiu
   -- pmotces (1- emissió (+)
   --          2- anul.l  (-)
   --          3- regularització cúmul (+)
   --          4- anul. regula. cumul (-)
   ------------------------------------------------------------------------------
   ------------------------------------------------------------------------------
   FUNCTION f_cesdet_anu_cum(
         pscumulo IN NUMBER,
         pdata IN DATE,
         pmotces IN NUMBER,
         pssegurono IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   ------------------------------------------------------------------------------
   -- Anul.la les cessions de totes les pòlisses del cúmul a partir de la data amb
   -- el motiu pmotces
   ------------------------------------------------------------------------------
   FUNCTION f_cesdet_recalcul(
         pscumulo IN NUMBER,
         pdata IN DATE,
         psproces IN NUMBER,
         pssegurono IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   ------------------------------------------------------------------------------
   -- Recalcula les cessions d'un cúmul després d'anul.lar una pòlissa o modificar
   -- un cúmul
   ------------------------------------------------------------------------------
   FUNCTION f_capces_ext(
         psseguro IN NUMBER,
         pnrecibo IN NUMBER,
         pnfactor IN NUMBER,
         pfefecte IN DATE,
         pfvencim IN DATE,
         pcmotces IN NUMBER,
         psproces IN NUMBER,
         psreaemi OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_ces_ext(
         psreaemi IN NUMBER,
         pnfactor IN NUMBER,
         pnrecibo_in IN NUMBER,
         pcgarant IN NUMBER,
         pnriesgo IN NUMBER,
         pmoneda IN NUMBER)
      RETURN NUMBER;

   --------------------------------------------------------------------
   -- Esborra l'anul.lació de les cessions del rebut. Es crida desde
   -- el càlcul de la prima mínima d'extorn, pq si s'anul.la el rebut
   -- per aquest motiu, no es vol anul.lar la cessió de l'extorn.
   --------------------------------------------------------------------
   -- Bug 0014775 - RSC - 10/08/2010 - AGA003 - Error en dades rebut plantilla Condicionat Particular AGA012 (afegim pmodo)
   FUNCTION f_borra_cesdet_anu(
         pnrecibo IN NUMBER,
         pmodo IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;

   ---------------------------------------------------------------------
   FUNCTION f_recalcula_cumul(
         pssegurono IN NUMBER,
         pfefecmov DATE,
         psproces  NUMBER,
         pcempres  NUMBER)
      RETURN NUMBER;

   -- recalcul de cels cessions d'un cumul excepte de les de ssegurono
   ---------------------------------------------------------------------
   FUNCTION f_captram_cumul(
         psseguro IN NUMBER,
         pscumulo IN NUMBER,
         pcgarant IN NUMBER,
         pfefecto IN DATE,
         pctramo IN NUMBER,
         pscontra IN NUMBER,
         pnversio IN NUMBER,
         pcapcum OUT NUMBER,
         piplenotot IN OUT NUMBER,
         picapital  IN NUMBER DEFAULT NULL)--BUG CONF-250  Fecha (02/09/2016) - HRE - se adiciona picapital
      RETURN NUMBER;

   --BUG 19484 - 19/10/2011 - JRB - Se añaden las funciones est para el reaseguro.
   -- recalcul de cels cessions d'un cumul excepte de les de ssegurono
   ---------------------------------------------------------------------
   FUNCTION f_captram_cumul_est(
         psseguro IN NUMBER,
         pscumulo IN NUMBER,
         pcgarant IN NUMBER,
         pfefecto IN DATE,
         pctramo IN NUMBER,
         pscontra IN NUMBER,
         pnversio IN NUMBER,
         pcapcum OUT NUMBER,
         piplenotot IN OUT NUMBER,
         ptablas IN VARCHAR2 DEFAULT 'EST')
      RETURN NUMBER;

   ----
   -- suma de capitals del tram per un cúmul
   ---------------------------------------------------------------------
   -----------------------------------------------------------------------------------
   -- Calcula el factor a aplicar a les cessions, però comparant'ho amb les primes
   -- dels rebuts, en lloc de fer-ho per dates. M.RB. Financera 12-03-2008
   -----------------------------------------------------------------------------------
   -- Bug 0012020 - 17/11/2009 - JMF Afegir risc com paràmetre.
   FUNCTION f_calcula_factor_rebut(
         psseguro IN NUMBER,
         pnrecibo IN NUMBER,
         pfefecto IN DATE,
         pcramo IN NUMBER,
         pcmodali IN NUMBER,
         pctipseg IN NUMBER,
         pccolect IN NUMBER,
         pcactivi IN NUMBER,
         pmoneda IN NUMBER,
         pnriesgo IN NUMBER,
         p_suma_cesionesrea OUT NUMBER,
         p_suma_iprimanu OUT NUMBER,
         p_factor_cessio OUT NUMBER)
      RETURN NUMBER;

   -----------------------------------------------------------------------------------
   -- Calcula el les cessions mensuals per productes d'estalvi on es reassegura el
   -- Capital en Risc. -- BUG 9549 - 12/05/2009 - AVT
   -----------------------------------------------------------------------------------
   PROCEDURE p_cesiones_ahorro(
         psproces IN NUMBER,
         pmes IN NUMBER,
         panyo IN NUMBER,
         psseguro IN NUMBER DEFAULT NULL);

   -----------------------------------------------------------------------------------
   -- Mantis 10344.01/06/2009.NMM. CRE - Cesiones a reaseguro incorrectas.
   -----------------------------------------------------------------------------------
   FUNCTION f_del_reasegemi(
         p_sseguro IN seguros.sseguro%TYPE,
         p_nmovimi IN movseguro.nmovimi%TYPE)
      RETURN NUMBER;

   -----------------------------------------------------------------------------
   -- Mantis 11845.12/2009.NMM.CRE - Ajustar reassegurança d'estalvi .
   -----------------------------------------------------------------------------
   FUNCTION producte_reassegurable(
         p_sproduc IN productos.sproduc%TYPE)
      RETURN NUMBER;

   -- Bug 19484 - JRB - 27/10/2011 - LCOL_T001: Retención por facultativo antes de emitir la propuesta
   FUNCTION f_buscactrrea_est(
         psseguro IN NUMBER,
         pnmovimi IN NUMBER,
         psproces IN NUMBER,
         pmotiu IN NUMBER,
         pmoneda IN NUMBER,
         porigen IN NUMBER DEFAULT 1,  -- 1- Ve d'emissió/renovació  2-Ve de q. d'amortització
         pfinici IN DATE DEFAULT NULL, -- Inici de cessió forçat
         pffin IN DATE DEFAULT NULL,
         ptablas IN VARCHAR2 DEFAULT 'EST') -- Fi de cessió forçat
      RETURN NUMBER;

   FUNCTION f_capital_cumul_est(
         pctiprea IN NUMBER,
         pscumulo IN NUMBER,
         pfecini IN DATE,
         pcgarant IN NUMBER,
         pcapital IN OUT NUMBER,
         ptablas IN VARCHAR2 DEFAULT 'EST')
      RETURN NUMBER;

   FUNCTION f_cessio_est(
         psproces IN NUMBER,
         pmotiu IN NUMBER,
         pmoneda IN NUMBER,
         pfdatagen IN DATE DEFAULT f_sysdate,
         pcgesfac IN NUMBER DEFAULT 0,
         ptablas IN VARCHAR2 DEFAULT 'EST') -- 19484 1-Fer o 0-No Facultatiu)
      RETURN NUMBER;

   -- Fin Bug 19484
   -- 21559 AVT 07/03/2012
   FUNCTION f_renovacion_anual_rea(
         psseguro IN NUMBER,
         pfcaranu IN DATE,
         ptablas IN VARCHAR2 DEFAULT NULL)
      RETURN DATE;

   --Bug:28358 AGG 03/10/2013
   FUNCTION f_capital(
         psesion IN NUMBER,
         psseguro IN NUMBER,
         pnriesgo IN NUMBER,
         pscontra IN NUMBER,
         pnversio IN NUMBER,
         pfefecto IN NUMBER,
         psproduc IN NUMBER,
         pngarantia IN NUMBER,
         ptablas IN VARCHAR2 DEFAULT 'EST')
      RETURN NUMBER;

   --INICIO - BUG38692 - DCT - 17/11/2015
   FUNCTION f_calcula_vto_poliza(
         pfrenova DATE,
         pnrenova NUMBER,
         pfefecto DATE,
         pcramo   NUMBER,
         pcmodali NUMBER,
         pctipseg NUMBER,
         pccolect NUMBER)
      RETURN DATE;
   --FIN - BUG38692 - DCT - 17/11/2015

   --INICIO BUG 41728-234063 --JCP 25/04/2016
   FUNCTION f_control_cesion(
         ptabla IN VARCHAR2 DEFAULT 'REA',
         pcempres IN NUMBER,
         psseguro IN NUMBER,
         pnmovimi IN NUMBER,
         pnriesgo IN NUMBER,
         psproces IN NUMBER DEFAULT 0,
         pgenera_ces OUT NUMBER)
      RETURN NUMBER;
   --FIN BUG 41728-234063 --JCP 25/04/2016
   --INI BUG CONF-250  Fecha (02/09/2016) - HRE - Contratos Q1, Q2, Q3
   FUNCTION f_porcentaje_tramos_manual(
         pctramo IN tramos.ctramo%TYPE,
         pscontra IN tramos.scontra%TYPE,
         pnversio IN tramos.nversio%TYPE--,
         )
      RETURN NUMBER;
   --FIN BUG CONF-250  - Fecha (02/09/2016) - HRE
   --INI BUG CONF-294 Fecha (09/11/2016) - HRE - Cumulos por tomador y zona geografica
   FUNCTION f_crea_cumul_tomador(pfefecto IN DATE, pctipcum IN NUMBER, pccumprod IN NUMBER,
                                 pscontra IN NUMBER, pnversio IN NUMBER, psseguro IN NUMBER,
                                 ptablas IN VARCHAR2,
                                 pscumulo OUT NUMBER)
   RETURN NUMBER;

   FUNCTION f_crea_cumul_zona(lasseg IN NUMBER, pfefecto IN DATE, pctipcum IN NUMBER,
                              pccumprod IN NUMBER, pscontra IN NUMBER, pnversio IN NUMBER,
                              psseguro IN NUMBER, pscumulo OUT NUMBER)
   RETURN NUMBER;

   FUNCTION f_get_scumulo(psseguro IN NUMBER, passeg IN NUMBER, pscontra IN NUMBER,
                          pnversio IN NUMBER, pccumprod IN NUMBER, pctipcum IN NUMBER,
                          pscumulo OUT NUMBER)
   RETURN NUMBER;
    /*************************************************************************
    FUNCTION f_captram_cumul_ret
    Permite obtener el valor de lo acumulado por aquellos movimientos de retenciones
    propias de contratos, es decir que no corresponde a retencion global.
    param in psseguro  : codigo del seguro
    param in pscumulo  : codigo del cumulo
    param in pcgarant   : codigo de la garantia
    param in pfefecto    : fecha de efecto
    param in pctramo  : tramo
    param in pscontra   : codigo de contrato de reaseguros
    param in pnversio    : version de contrato
    param in pmoninst        : moneda de instalacion
    param in pfcambio        : fecha para obtener la tasa de cambio
    param in ptablas    : tabla
    param out pcapcum : capital del cumulo
    param out piplenotot : pleno neto
    return             : number
  *************************************************************************/
   FUNCTION f_captram_cumul_ret(
         psseguro IN NUMBER,
         pscumulo IN NUMBER,
         pcgarant IN NUMBER,
         pfefecto IN DATE,
         pctramo IN NUMBER,
         pscontra IN NUMBER,
         pnversio IN NUMBER,
         pmoninst IN VARCHAR2,
         pfcambio IN DATE,
         pcapcum OUT NUMBER,
         piplenotot IN OUT NUMBER,
         ptablas IN VARCHAR2 DEFAULT 'EST')
         RETURN NUMBER;

   /*************************************************************************
    FUNCTION f_ple_cumul_qn
    Permite obtener el valor de lo acumulado en la retencion global sin tener
    en cuenta la retencion de los contratos.
    param in psseguro  : codigo del seguro
    param in pscumulo  : codigo del cumulo
    param in pcgarant  : codigo de la garantia
    param in pfefecto  : fecha de efecto
    param out pcapcum  :  capital del cumulo
    param out pipleno  : importe de la retencion
    param out picapaci : importe de la capacidad
    param in ptablas   : tabla
    return             : number
  *************************************************************************/
   FUNCTION f_ple_cumul_qn(
         psseguro IN NUMBER,
         pscumulo IN NUMBER,
         pcgarant IN NUMBER,
         pmoninst IN VARCHAR2,--BUG CONF-620  Fecha (01/03/2017) - HRE - Reaseguro moneda local
         pfefecto IN DATE,
         pcapcum OUT NUMBER,
         pipleno OUT NUMBER,
         picapaci OUT NUMBER,
         ptablas IN VARCHAR2 DEFAULT 'EST')
      RETURN NUMBER;
   --FIN BUG CONF-294  - Fecha (09/11/2016) - HRE

 --INI BUG CONF-479  Fecha (20/01/2017) - HRE - Suplemento de aumento de valor
  FUNCTION f_mantener_repartos_supl(
     pmotiu IN NUMBER,
     psproduc IN NUMBER,
     pscontra IN NUMBER,
     psseguro IN NUMBER,
     pnversio IN NUMBER,
     pcgarant IN NUMBER,
     ptramo IN NUMBER,
     pporce IN NUMBER,
     pcapces IN NUMBER,
     picapital IN NUMBER,
     ppcapces_out OUT NUMBER,
     pporce_out OUT NUMBER)
     RETURN NUMBER;
  --FIN BUG CONF-479  - Fecha (20/01/2017) - HRE
  
  --INI IAXIS BUG 13246 AABG: Para consultar las cesiones manuales de endosos
  FUNCTION f_mantener_repartos_supl_man(
     pmotiu IN NUMBER,
     psproduc IN NUMBER,
     pscontra IN NUMBER,
     psseguro IN NUMBER,
     pnversio IN NUMBER,
     pcgarant IN NUMBER,
     ptramo IN NUMBER,
     pporce IN NUMBER,
     pcapces IN NUMBER,
     picapital IN NUMBER,
     ppcapces_out OUT NUMBER,
     pporce_out OUT NUMBER,
     ppcapq_out OUT NUMBER,
     pporceq_out OUT NUMBER,
     psupl_out OUT NUMBER)
     RETURN NUMBER;
  --FIN IAXIS BUG 13246 AABG: Para consultar las cesiones manuales de endosos
  
   --INI BUG CONF-620  Fecha (01/03/2017) - HRE - Reaseguro moneda local
   /*************************************************************************
    FUNCTION f_capital_cumul_est_mon
    Permite obtener el capital del cumulo en moneda local
    param in pctiprea        : tipo de reaseguro
    param in pscumulo        : codigo del cumulo
    param in pfecini         : fecha inicial
    param in pcgarant        : garantia
    param in pmoninst        : moneda instalacion
    param in pfcambio        : fecha para obtener la tasa de cambio
    param in out pcapital    : capital del cumulo
    param out ptablas        : tipo de tabla
    return                   : number
   *************************************************************************/
   FUNCTION f_capital_cumul_est_mon(--hans cambio
         pctiprea IN NUMBER,
         pscumulo IN NUMBER,
         pfecini  IN DATE,
         pcgarant IN NUMBER,
         pmoninst IN VARCHAR2,
         pfcambio IN DATE,
         pcapital IN OUT NUMBER,
         ptablas  IN VARCHAR2 DEFAULT 'EST')
      RETURN NUMBER;
   /*************************************************************************
    FUNCTION f_capital_cumul_mon
    Permite buscar el capital del cumulo en moneda local
    param in pctiprea        : tipo de reaseguro
    param in pscumulo        : codigo del cumulo
    param in pfecini         : fecha inicial
    param in pcgarant        : garantia
    param in pmoninst        : moneda instalacion
    param in pfcambio        : fecha para obtener la tasa de cambio
    param in out pcapital    : capital del cumulo
    return                   : number
   *************************************************************************/
   FUNCTION f_capital_cumul_mon(
      pctiprea IN NUMBER,
      pscumulo IN NUMBER,
      pfecini  IN DATE,
      pcgarant IN NUMBER,
      pmoninst IN VARCHAR2,
      pfcambio IN DATE,
      pcapital IN OUT NUMBER)
   RETURN NUMBER;
   /*************************************************************************
    FUNCTION f_ple_cumul_est_mon
    Permite buscar el capital del cumulo en moneda local, para tramo 0(retencion)
    param in psseguro        : codigo seguro
    param in pscumulo        : codigo del cumulo
    param in pcgarant        : garantia
    param in pfefecto        : fecha efecto
    param in pmoninst        : moneda de instalacion
    param in pfcambio        : fecha para obtener la tasa de cambio
    param out pcapcum        : capital del cumulo
    param out pipleno        : importe del pleno(retencion)
    param out picapaci       : capacidad
    param in ptablas         : tablas
    return                   : number
   *************************************************************************/
   FUNCTION f_ple_cumul_est_mon(
      psseguro IN NUMBER,
      pscumulo IN NUMBER,
      pcgarant IN NUMBER,
      pfefecto IN DATE,
      pmoninst IN VARCHAR2,
      pfcambio IN DATE,
      pcapcum OUT NUMBER,
      pipleno OUT NUMBER,
      picapaci OUT NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'EST')
    RETURN NUMBER;
   /*************************************************************************
    FUNCTION f_ple_cumul_tot_est_mon
    Permite buscar el capital del cumulo en moneda local, para tramo 0(retencion)
    param in psseguro        : codigo seguro
    param in pscumulo        : codigo del cumulo
    param in pcgarant        : garantia
    param in pfefecto        : fecha efecto
    param in pscontra        : codigo contrato de reaseguro
    param in pscontra        : version contrato de reaseguro
    param in pmoninst        : moneda de instalacion
    param in pfcambio        : fecha para obtener la tasa de cambio
    param out pcapcum_tot        : capital del cumulo
    param out pipleno_tot        : importe del pleno(retencion)
    param in ptablas         : tablas
    return                   : number
   *************************************************************************/
   FUNCTION f_ple_cumul_tot_est_mon(
         psseguro IN NUMBER,
         pscumulo IN NUMBER,
         pcgarant IN NUMBER,
         pfefecto IN DATE,
         pscontra IN NUMBER,
         pnversio IN NUMBER,
         pmoninst IN VARCHAR2,
         pfcambio IN DATE,
         pcapcum_tot OUT NUMBER,
         pipleno_tot OUT NUMBER,
         ptablas IN VARCHAR2 DEFAULT 'EST')
      RETURN NUMBER;
   /*************************************************************************
    FUNCTION f_captram_cumul_est_mon
    Permite buscar el capital del tramo en moneda local
    param in psseguro        : codigo seguro
    param in pscumulo        : codigo del cumulo
    param in pcgarant        : garantia
    param in pfefecto        : fecha efecto
    param in pctramo         : codigo del tramo
    param in pscontra        : codigo contrato de reaseguro
    param in pnversio        : version contrato de reaseguro
    param in pmoninst        : moneda de instalacion
    param in pfcambio        : fecha para obtener la tasa de cambio
    param out pcapcum        : capital del tramo
    param in-out piplenotot  : pleno total
    param in ptablas         : tablas
    return                   : number
   *************************************************************************/
   FUNCTION f_captram_cumul_est_mon(
         psseguro IN NUMBER,
         pscumulo IN NUMBER,
         pcgarant IN NUMBER,
         pfefecto IN DATE,
         pctramo IN NUMBER,
         pscontra IN NUMBER,
         pnversio IN NUMBER,
         pmoninst IN VARCHAR2,
         pfcambio IN DATE,
         pcapcum OUT NUMBER,
         piplenotot IN OUT NUMBER,
         ptablas IN VARCHAR2 DEFAULT 'EST')
      RETURN NUMBER;
   --FIN BUG CONF-620  - Fecha (01/03/2017) - HRE

	   -- ERHF
   /*AGG 17/08/2015 procedimiento que realiza el calculo de cesiones de reaseguro*/
   FUNCTION f_calcula_cesiones(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      psproces IN NUMBER,
      pmotiu IN NUMBER,
      pmoneda IN NUMBER,
      pnpoliza IN NUMBER DEFAULT -1,
      pncertif IN NUMBER DEFAULT -1,
      porigen IN NUMBER DEFAULT 1,
      pfinici IN DATE DEFAULT NULL,
      pffin IN DATE DEFAULT NULL,
      ptablas IN VARCHAR2 DEFAULT 'EST')
      RETURN NUMBER;


    PROCEDURE traspaso_inf_cesionesreatoest(
      pcempres IN NUMBER,
      psseguro IN NUMBER,
      pcidioma IN NUMBER,
      psproces IN NUMBER,
      pmoneda IN NUMBER,
      pcgenera IN NUMBER,
      pnsinies IN NUMBER DEFAULT -1);


    PROCEDURE traspaso_inf_esttocesionesrea(
      pcempres IN NUMBER,
      psseguro IN NUMBER,
      pcidioma IN NUMBER,
      psproces IN NUMBER,
      pmoneda IN NUMBER,
      pmensaje OUT VARCHAR2); --OJSO

     FUNCTION f_cesdet_anu(pnrecibo IN NUMBER,  --INICIO (QT 24893 + Bug 41045) AGG 29/03/2016
   pcesmanual in number) --FIN (QT 24893 + Bug 41045) AGG 29/03/2016
      RETURN NUMBER;

  -- ERHF
END;

/

  GRANT EXECUTE ON "AXIS"."PAC_CESIONESREA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CESIONESREA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CESIONESREA" TO "PROGRAMADORESCSI";
