--------------------------------------------------------
--  DDL for Package PAC_DINCARTERA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_DINCARTERA" IS
/******************************************************************************
   NOMBRE:      PAC_DINCARTERA
   PROP¿SITO:

   REVISIONES:
   Ver        Fecha        Autor             Descripci¿n
   ---------  ----------  ---------------  ------------------------------------
   1.0        03/12/2008                   1. Creaci¿n del package.
   1.1        16/12/2008
   1.2        18/12/2008     xpl          2. Estandaritzaci¿
   2.0        21/04/2009    YIL           3. Se elimina la funci¿n f_reval_par porque no se est¿ utilizando
   14.0       17/09/2009     RSC          16. Bug 0010828: CRE - Revisi¿n de los productos PPJ din¿mico y Pla Estudiant (ajustes)
   16.0       04/11/2009     AMC          18  Bug 0011685: CRE - Modificar el previo de cartera y la cartera para que se lancen a trav¿s de jobs
   17.0       31/12/2010     JMP          34. Bug 0017153: CRE - Permitir pasar la cartera a un colectivo entero o a un certificado
   18.0       17/10/2012     APD          0023940: LCOL_T010-LCOL - Certificado 0 renovable - Renovacion colectivos
   19.0       28/05/2013     DCT          0024704: LCOL - Descuentos comerciales sobre prima para p¿lizas de migraci¿n - Vida Individual
   20.0       04/07/2013     ECP          3. 0027539: LCOL_T010-LCOL - Revision incidencias qtracker (VII). Nota 148366
   21.0       22/04/2014     JTT          0029943: Se a¿ade la nueva funcion para tratar las PBs, f_tratamiento_pb
   22.0       06/05/2014     JTT          0029943: Tratamiento de las PBs, f_tratamiento_pb
   22.0       25/05/2015     BLA          004469/0205354: POS Se adiciona funci¿n F_MODIF_CMOVSEG_ANIVERSARIO
******************************************************************************/-- Bug 23940 - APD - 02/11/2012 - se crea la funcion
   FUNCTION f_modif_cmovseg_aniversario(psseguro IN NUMBER, pfcarpro IN DATE)
      RETURN NUMBER;

   -- Funci¿n que guarda en la tabla DETRECMOVSEGUROCOL los recibos generados
   -- en el proceso de cartera que se est¿ generando
   FUNCTION f_set_recibos_col(
      psproces IN NUMBER,
      psseguro IN NUMBER,
      pfefecto IN DATE,
      pnmovimi_0 IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   -- Bug 23940 - APD - 18/10/2012 - se crea la funcion
   FUNCTION f_agruparecibos(psproces IN NUMBER, psseguro IN NUMBER)
      RETURN NUMBER;

   FUNCTION p_cartera_psu(
      pmoneda IN NUMBER,
      pidioma IN NUMBER,
      pmes IN NUMBER,
      panyo IN NUMBER,
      p_sseguro IN NUMBER,
      p_cramo IN NUMBER,
      p_cmodali IN NUMBER,
      p_ctipseg IN NUMBER,
      p_ccolect IN NUMBER,
      p_ctarman IN NUMBER,
      p_ccobban IN NUMBER,
      p_nrenova IN NUMBER,
      p_ctipreb IN NUMBER,
      p_cforpag IN NUMBER,
      p_nduraci IN NUMBER,
      p_ndurcob IN NUMBER,
      p_cactivi IN OUT NUMBER,
      p_csubpro IN NUMBER,
      p_cobjase IN NUMBER,
      p_cagrpro IN NUMBER,
      p_fefecto IN DATE,
      p_fvencim IN DATE,
      p_fcarpro IN OUT DATE,
      p_fcaranu IN OUT DATE,
      p_nanuali IN OUT NUMBER,
      p_nfracci IN OUT NUMBER,
      p_fcarant IN OUT DATE,
      ppsproces IN NUMBER,
      indice IN OUT NUMBER,
      indice_error IN OUT NUMBER,
      pfemisio IN DATE,
      pcorrecte OUT NUMBER,
      p_sproduc IN NUMBER,
      p_nsuplem IN NUMBER,
      pcgarant_regu IN NUMBER,
      pnorden IN NUMBER,
      pcprimin IN NUMBER,
      piprimin IN NUMBER,
      pcclapri IN NUMBER,
      pnedamar IN NUMBER,
      pciedmar IN NUMBER,
      pempresa IN NUMBER,
      p_csituac IN NUMBER,
      pcreteni OUT NUMBER)   -- Bug 23940 - APD - 17/10/2012
      RETURN NUMBER;

---------------------------------------------------------------------------------------------
   FUNCTION p_cartera(
      pmoneda IN NUMBER,
      pidioma IN NUMBER,
      pmes IN NUMBER,
      panyo IN NUMBER,
      p_sseguro IN NUMBER,
      p_cramo IN NUMBER,
      p_cmodali IN NUMBER,
      p_ctipseg IN NUMBER,
      p_ccolect IN NUMBER,
      p_ctarman IN NUMBER,
      p_ccobban IN NUMBER,
      p_nrenova IN NUMBER,
      p_ctipreb IN NUMBER,
      p_cforpag IN NUMBER,
      p_nduraci IN NUMBER,
      p_ndurcob IN NUMBER,
      p_cactivi IN OUT NUMBER,
      p_csubpro IN NUMBER,
      p_cobjase IN NUMBER,
      p_cagrpro IN NUMBER,
      p_fefecto IN DATE,
      p_fvencim IN DATE,
      p_fcarpro IN OUT DATE,
      p_fcaranu IN OUT DATE,
      p_nanuali OUT NUMBER,
      p_nfracci OUT NUMBER,
      p_fcarant OUT DATE,
      ppsproces IN NUMBER,
      indice IN OUT NUMBER,
      indice_error IN OUT NUMBER,
      pfemisio IN DATE,
      pcorrecte OUT NUMBER,
      p_sproduc IN NUMBER,
      p_nsuplem IN NUMBER,
      pcgarant_regu IN NUMBER,
      pnorden IN NUMBER,
      pcprimin IN NUMBER,
      piprimin IN NUMBER,
      pcclapri IN NUMBER,
      pnedamar IN NUMBER,
      pciedmar IN NUMBER,
      pempresa IN NUMBER,
      p_csituac IN NUMBER,
       pfcartera IN DATE DEFAULT NULL) --JRH MSV-3
      RETURN NUMBER;

   FUNCTION cartera_producte(
      pempresa IN NUMBER,
      psproces_prod IN NUMBER,
      psproces IN NUMBER,
      pmes IN NUMBER,
      panyo IN NUMBER,
      pidioma IN NUMBER,
      pmoneda IN NUMBER,
      pfemisio IN DATE,
      indice OUT NUMBER,
      indice_error OUT NUMBER,
      psseguro IN NUMBER DEFAULT NULL,
      pnpoliza IN NUMBER DEFAULT NULL,
      pncertif IN NUMBER DEFAULT NULL,
      pskiprenova IN NUMBER DEFAULT NULL,
      prenovcero IN NUMBER DEFAULT 0,
      pfcartera IN DATE DEFAULT NULL)
      RETURN NUMBER;

---------------------------------------------------------------------------------------------
   FUNCTION f_garantarifa_sgt(
      pmodo IN VARCHAR2,
      psseguro IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pcobjase IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pctipo IN NUMBER,
      pnduraci IN NUMBER,
      conta_proces IN NUMBER,
      pcdurcob IN NUMBER,
      pfcarpro IN DATE,
      pmes IN VARCHAR2,
      panyo IN NUMBER,
      tipo IN NUMBER,
      pcagrpro IN NUMBER,
      pcmanual IN NUMBER,
      pcactivi IN NUMBER,
      num_risc IN NUMBER,
      pfemisio IN DATE,
      pfefecto IN DATE,   -- nununu
      movimiento OUT NUMBER,
      anulado OUT NUMBER,
      pmoneda IN NUMBER,
      parms_transitorios IN OUT pac_parm_tarifas.parms_transitorios_tabtyb,
      pbonifica IN NUMBER,
      paplica_bonifica IN NUMBER,
      psproduc IN NUMBER,
      pcforpag IN NUMBER,
      pidioma IN NUMBER,
      pcgarant_regu IN NUMBER,
      pnorden IN NUMBER,
      pcprimin IN NUMBER,
      piprimin IN NUMBER,
      pcclapri IN NUMBER,
      pnedamar IN NUMBER,
      pciedmar IN NUMBER,
      pfcaranu IN DATE)
      RETURN NUMBER;

---------------------------------------------------------------------------------------------
   PROCEDURE garantia_regularitzacio(
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pcprimin OUT NUMBER,
      piprimin OUT NUMBER,
      pcclapri OUT NUMBER,
      pcgarant_regu OUT NUMBER,
      pnorden OUT NUMBER);

---------------------------------------------------------------------------------------------
   FUNCTION f_anular(
      psseguro IN NUMBER,
      pfcaranu IN DATE,
      psproces IN NUMBER,
      pfcontab IN DATE,
      pfemisio IN DATE,
      pnmovimi OUT NUMBER,
      panulado OUT NUMBER,
      pmoneda IN NUMBER)
      RETURN NUMBER;

---------------------------------------------------------------------------------------------
   FUNCTION f_anuledad(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      pnmovimi IN NUMBER,
      pfiniefe IN DATE,
      pfcarpro IN DATE,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pcobjase IN NUMBER,
      pmodo IN VARCHAR2,
      ptablas IN VARCHAR2,
      pnedamar IN NUMBER,
      pciedmar IN NUMBER,
      estat_garan OUT VARCHAR2)
      RETURN NUMBER;

---------------------------------------------------------------------------------------------
 -- Bug 23940 - APD - 01/11/2012 - se a¿ade el parametro ptablas para poder hacer el traspaso
 -- de los registros de GARANCAR a ESTGARANSEG
 -- En este caso, cuando ptablas = 'EST' se pasa el sseguro de las EST para saber
 -- de qu¿ poliza REAL de las tablas CAR se debe coger la informaci¿n para pasarla
 -- a la p¿liza de las EST. Lo mismo con el nmovimi.
   FUNCTION f_traspasgar(
      psproces IN NUMBER,
      psseguro IN NUMBER,
      pdata IN DATE,
      pnmovimi IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT NULL,
      psseguro_est IN NUMBER DEFAULT NULL,
      pnmovimi_est IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

---------------------------------------------------------------------------------------------
   FUNCTION f_excepcionsegu(psseguro IN NUMBER, pcconcep IN NUMBER, pcvalor OUT NUMBER)
      RETURN NUMBER;

   PROCEDURE proceso_batch_cierre(
      pmodo IN NUMBER,
      pcempres IN NUMBER,
      pmoneda IN NUMBER,
      pcidioma IN NUMBER,
      pfperini IN DATE,
      pfperfin IN DATE,
      pfcierre IN DATE,
      pcerror OUT NUMBER,
      psproces OUT NUMBER,
      pfproces OUT DATE);

   /**** BUG 8339 *****************/
   FUNCTION f_insert_tmp_carteraux(
      pcempres IN NUMBER,
      psprocar IN NUMBER,
      psproduc IN NUMBER,
      pseleccio IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_get_prodcartera(
      pcempres IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      psprocar IN NUMBER,
      --Ini Bug 27539 --ECP--04/07/2013
      pmodo IN VARCHAR,
      --Fin Bug 27539 --ECP--04/07/2013
      pcidioma IN NUMBER,
      psquery OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_inicializa_cartera(
      pmodo IN VARCHAR2,
      pfperini IN DATE,
      pcempres IN NUMBER,
      ptexto IN VARCHAR2,
      pcidioma IN NUMBER,
      psproces OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_get_mes_cartera(
      pnpoliza IN NUMBER,
      pcidioma IN NUMBER,
      pcempres IN NUMBER,
      pcmodo IN VARCHAR2,
      psquery OUT VARCHAR2,
      psprocar IN NUMBER   -- Bug 29952/169064 - 11/03/2014 - AMC
                        )
      RETURN NUMBER;

   FUNCTION f_get_anyo_cartera(
      pcempres IN NUMBER,
      pnpoliza IN NUMBER,
      pnmes IN NUMBER,
      pnanyo OUT NUMBER,
      psprocar IN NUMBER   -- Bug 29952/169064 - 11/03/2014 - AMC
                        )
      RETURN NUMBER;

   FUNCTION f_ejecutar_cartera(
      psproces IN NUMBER,
      pmodo IN VARCHAR2,
      pcempres IN NUMBER,
      pnpoliza IN NUMBER,
      pfperini IN DATE,
      pfcartera IN DATE,
      pncertif IN NUMBER,
      pmoneda IN NUMBER,
      pcidioma IN NUMBER,
      psprocar IN NUMBER,
      prenuevan IN NUMBER,
      pmens OUT VARCHAR2,
      prenovcero IN NUMBER DEFAULT 0)
      RETURN NUMBER;

   /**** BUG 8339 *****************/
   PROCEDURE previ_cartera_tar(
      pcempres IN NUMBER,
      pmes IN NUMBER,
      panyo IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      -- BUG 8339 --pcramo IN NUMBER, pcmodali IN NUMBER, pctipseg IN NUMBER,
      -- BUG 8339 --pccolect IN NUMBER, pcactivi IN NUMBER,
      pcidioma IN NUMBER,
      psproces IN NUMBER,
      indice OUT NUMBER,
      indice_error OUT NUMBER,
      prenuevan IN NUMBER DEFAULT 0,
      pfcartera IN DATE DEFAULT NULL);

   -- Bug 10350 - 04/06/2009 - RSC - Detalle garant¿as (tarificaci¿n)
   FUNCTION f_garantarifa_sgt_det(
      pmodo IN VARCHAR2,
      psseguro IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pcobjase IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pctipo IN NUMBER,
      pnduraci IN NUMBER,
      conta_proces IN NUMBER,
      pcdurcob IN NUMBER,
      pfcarpro IN DATE,
      pmes IN VARCHAR2,
      panyo IN NUMBER,
      tipo IN NUMBER,
      pcagrpro IN NUMBER,
      pcmanual IN NUMBER,
      pcactivi IN NUMBER,
      num_risc IN NUMBER,
      pfemisio IN DATE,
      pfefecto IN DATE,   -- nununu
      movimiento OUT NUMBER,
      anulado OUT NUMBER,
      pmoneda IN NUMBER,
      parms_transitorios IN OUT pac_parm_tarifas.parms_transitorios_tabtyb,
      pbonifica IN NUMBER,
      paplica_bonifica IN NUMBER,
      psproduc IN NUMBER,
      pcforpag IN NUMBER,
      pidioma IN NUMBER,
      pcgarant_regu IN NUMBER,
      pnorden IN NUMBER,
      pcprimin IN NUMBER,
      piprimin IN NUMBER,
      pcclapri IN NUMBER,
      pnedamar IN NUMBER,
      pciedmar IN NUMBER,
      pfcaranu IN DATE)
      RETURN NUMBER;

    /*******************************************************************************
      PROCEDIMIENTO P_EJECUTAR_CARTERA

       psproces     NUMBER  : Id. del proceso
       pmodo        NUMBER  : Modo de ejecuciom
       pcempres     NUMBER  : Empresa
       pnpoliza     NUMBER  : Numero de poliza
       pfperini     DATE    : Fecha inicio
       pncertif     NUMBER  : Numero de certificado
       pmoneda      NUMBER  : Moneda
       pcidioma     NUMBER  : Idioma
       psprocar     NUMBER
       prenueva     NUMBER

       Bug 11685 - 04/11/2009 - AMC - Se crea el procedimiento p_ejecutar_cartera
   ********************************************************************************/
   PROCEDURE p_ejecutar_cartera(
      psproces IN NUMBER,
      pmodo IN VARCHAR2,
      pcempres IN NUMBER,
      pnpoliza IN NUMBER,
      pfperini IN DATE,
      pncertif IN NUMBER,
      pmoneda IN NUMBER,
      pcidioma IN NUMBER,
      psprocar IN NUMBER,
      prenuevan IN NUMBER);

   -- Bug 23940 - APD - 06/11/2012 - se crea la funcion
   FUNCTION f_act_cbloqueocol(psseguro IN NUMBER, pcbloqueocol IN NUMBER)
      RETURN NUMBER;

   -- Bug 23940 - APD - 06/11/2012 - se crea la funcion
   -- Funci¿n que valida si para un Colectivo administrado se ha hecho un suplemento de
   -- renovaci¿n o no
   FUNCTION f_suplemento_renovacion(psseguro IN NUMBER, ohaysuplem OUT NUMBER)
      RETURN NUMBER;

   -- Bug 23940 - APD - 06/11/2012 - se crea la funcion
   -- Funci¿n que indica si los botones en la pantalla de Gesti¿n de Renovaci¿n deben
   -- estar activados o desactivados
   FUNCTION f_botones_gestrenova(
      psseguro IN NUMBER,
      opermiteemitir OUT NUMBER,
      opermitepropret OUT NUMBER,
      opermitesuplemento OUT NUMBER,
      opermiterenovar OUT NUMBER)
      RETURN NUMBER;

   --BUG 24704 - INICIO - DCT - 28/05/2013
   FUNCTION f_renovacion_anual(psseguro IN NUMBER, pfcaranu IN DATE, psproduc IN NUMBER)
      RETURN NUMBER;

--BUG 24704 - FIN - DCT - 28/05/2013
-- JLB - I -  17/10/2013 -- bloqueo de cartera
/****************************************************************************
   f_cartera_bloqueada: Mira si para la cartera que si quiere ejecutar existe un proceso ya corriendo, total o parcial.
   Es decir si se lanza para una poliza, no se puede lanzar una cartera posteiormente para su ramo, y viceveresa.
   Return: 0 - no hay ningun proceso de cartera corriengo para la cartera que se quiere ejecutar
           1 - Existe alg¿n proceso de cartera que tiene conflicto con la cartera a ejecutar.
*****************************************************************************/
   FUNCTION f_cartera_bloqueada(
      psproces IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pcactivi IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER)
      RETURN NUMBER;

/****************************************************************************
   f_insert_carteraaux: Inserta un registro en carterauax y ejecuta commit,
*****************************************************************************/
   FUNCTION f_insert_carteraaux(
      psproces IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pcactivi IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pcbloqueo IN NUMBER,
      pfcartera IN DATE)
      RETURN NUMBER;

/****************************************************************************
   f_insert_carteraaux: Borra los registro en carterauax identificados por sproces y ejecuta commit,
*****************************************************************************/
   FUNCTION f_delete_carteraaux(psproces IN NUMBER)
      RETURN NUMBER;

-- JLB - F-  17/10/2013 -- reviso si la cartera se puede llamar

   /****************************************************************************
      f_tratamiento_pb: Realiza el tratamiento correspondiente segun el tipo de PB del producto.

       pcempres     : Empresa
       psseguro     : Sequencial del seguro
       pfefecto     : fecha de efecto
       pnmovimi     : Numero de movimiento de la poliza. Si es NULL la funcion busca el ultimo movimiento
       pmodo        : Modo de ejecuci¿n
             P - Previo
             R - Real
             A - Reproceso
       pnriesgo     : Numero de riesgo
       psprocpu     : Numero de proceso donde se calcula la primera PU

   *****************************************************************************/
   FUNCTION f_tratamiento_pb(
      pcempres IN NUMBER,
      psproduc IN NUMBER,
      psseguro IN NUMBER,
      pfefecto IN DATE,
      pnmovimi IN NUMBER,
      pmodo IN VARCHAR2,
      pnriesgo IN NUMBER,
      psprocpu IN NUMBER)
      RETURN NUMBER;

/****************************************************************************
   f_actualizar_franq

   Bug 26638/161264 - 0/04/2014 - AMC
*****************************************************************************/
   FUNCTION f_actualizar_franq(
      psproces IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pnriesgo IN NUMBER,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pfefecto IN DATE,
      pssegpol IN NUMBER,
      pcgrup IN NUMBER,
      pcsubgrup IN NUMBER,
      pcversion IN NUMBER,
      pcnivel IN NUMBER,
      pcvalor1 IN NUMBER,
      pimpvalor1 IN NUMBER,
      pcvalor2 IN NUMBER,
      pimpvalor2 IN NUMBER,
      pcimpmin IN NUMBER,
      pimpmin IN NUMBER,
      pcimpmax IN NUMBER,
      pimpmax IN NUMBER,
      psuplem IN BOOLEAN,
      psimul IN BOOLEAN,
      pcempres IN NUMBER,
      pcidioma IN NUMBER)
      RETURN NUMBER;

/****************************************************************************
   f_set_bonus_malus

   Bug 26638/161275 - 15/04/2014 - AMC
*****************************************************************************/
   FUNCTION f_set_bonus_malus(
      psproces IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      psproduc IN NUMBER,
      pfrenova IN DATE,
      pcempres IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_lanza_cartera(
      psproces IN NUMBER,
      pmodo IN VARCHAR2,
      pcempres IN NUMBER,
      pproductos IN VARCHAR2,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pfperini IN DATE,
      pfcartera IN DATE,
      pmoneda IN NUMBER,
      pcidioma IN NUMBER,
      psprocar IN NUMBER,
      pmens OUT VARCHAR2)
      RETURN NUMBER;
END pac_dincartera;

/

  GRANT EXECUTE ON "AXIS"."PAC_DINCARTERA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_DINCARTERA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_DINCARTERA" TO "PROGRAMADORESCSI";
