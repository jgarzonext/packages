--------------------------------------------------------
--  DDL for Package PAC_MDOBJ_PROD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MDOBJ_PROD" AS
/******************************************************************************
   NOMBRE:       PAC_MDOBJ_PROD
   PROPÓSITO:  Funciones de tratamiento objetos produccion

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        07/03/2008   ACC                1. Creación del package.
   2.0        11/05/2009   DRA                2. 0009263: CRE - Comisión de Comercialización
   3.0        17/12/2009   JMF                3. 0010908 CRE - ULK - Parametrització del suplement automàtic d'actualització de patrimoni
   4.0        30/07/2010   XPL                4. 14429: AGA005 - Primes manuals pels productes de Llar
   5.0        19/12/2011   APD                5. 0020448: LCOL - UAT - TEC - Despeses d'expedició no es fraccionen
   6.0        19/06/2012   JRH                6. 0022504: MDP_T001- TEC - Capital Recomendado
   7.0        14/08/2012   DCG                7. 0023183: LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
******************************************************************************/

   /*************************************************************************
      Recarrega las garanties despues de tarificar
      param in/out garant    : objeto garantia
      param in     pssolicit : código solicitud
      param in     pnmovimi  : número movimiento
      param in     pmode     : modo SOL EST POL
      param in     pnriesgo  : número de riesgo
   *************************************************************************/
   PROCEDURE p_get_garaftertargar(
      garant IN OUT ob_iax_garantias,
      pssolicit IN NUMBER,
      pnmovimi IN NUMBER,
      pmode IN VARCHAR2,
      pnriesgo IN NUMBER);

   /*************************************************************************
      Recarrega los detalles de las garanties despues de tarificar
      param in/out garantmasdatos    : objeto masdatosgar
      param in     pcgarant : código garantia
      param in     pssolicit : código solicitud
      param in     pmode     : modo EST POL
      param in     pnriesgo  : número de riesgo
   *************************************************************************/
   PROCEDURE p_get_garaftertardatosgar(
      garantmasdatos IN OUT ob_iax_masdatosgar,
      pcgarant IN NUMBER,
      pssolicit IN NUMBER,
      pmode IN VARCHAR2,
      pnriesgo IN NUMBER);

   /*************************************************************************
      Recupera de la base de dades las primas de las garantias
      param in/out prima     : objeto prima
      param in     pssolicit : código solicitud
      param in     pnmovimi  : número movimiento
      param in     pmode     : modo SOL EST POL
      param in     pnriesgo  : número de riesgo
      param in     pcgarant  : código de garantia
   *************************************************************************/
   PROCEDURE p_get_prigarant(
      prima IN OUT ob_iax_primas,
      pssolicit IN NUMBER,
      pnmovimi IN NUMBER,
      pmode IN VARCHAR2,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      pndetgar IN NUMBER,
      pctarman IN NUMBER);   --30/07/2010#XPL#14429: AGA005 - Primes manuals pels productes de Llar

   /*************************************************************************
      Recupera las preguntas de riesgo automaticas
      param in/out riesgo    : objeto riesgo
      param in     pssolicit : código solicitud
      param in     pnmovimi  : número movimiento
      param in     pmode     : modo SOL EST POL
   *************************************************************************/
   PROCEDURE p_get_pregauto(
      riesgo IN OUT ob_iax_riesgos,
      pssolicit IN NUMBER,
      pnmovimi IN NUMBER,
      pmode IN VARCHAR2);

   /*************************************************************************
      Recarrega las garantias despues de tarificar
      param in/out riesgo    : objeto riesgo
      param in     pssolicit : código solicitud
      param in     pnmovimi  : número movimiento
      param in     pmode     : modo SOL EST POL
   *************************************************************************/
   PROCEDURE p_get_garaftertarrie(
      riesgo IN OUT ob_iax_riesgos,
      pssolicit IN NUMBER,
      pnmovimi IN NUMBER,
      pmode IN VARCHAR2);

   /*************************************************************************
      Recupera la descripción del riesgo según el tipo riesgo
      param in/out riesgo    : objeto riesgo
      param in     psseguro : codigo seguro
      param in     vcobjase  : código de objeto asegurado
   *************************************************************************/
   PROCEDURE p_descriesgo(
      riesgo IN OUT ob_iax_riesgos,
      pcobjase IN NUMBER,
      psseguro IN NUMBER,
      pmode VARCHAR2 DEFAULT 'EST');

   /*************************************************************************
      Concatena la dirección
      param in/out direccion : objeto dirección
      param in psseguro : codigo seguro
      param in pnriesgo : numero de riesgo
      param out    odirec    : parametro de salida con la dirección concatenada
   *************************************************************************/
   PROCEDURE p_get_direccion(
      direccion IN OUT ob_iax_direcciones,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      odirec OUT VARCHAR2,
      pmode VARCHAR2 DEFAULT 'EST');

   /*************************************************************************
      Descripción automóbil
      param in/out autorie   : objeto automovil riesgo
      param in psseguro : codigo seguro
      param in pnriesgo : numero de riesgo
      param out    odesc     : parametro de salida con la descripción del
                               riesgo
   *************************************************************************/
   PROCEDURE p_get_descripcionauto(
      autorie IN OUT ob_iax_autriesgos,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      odesc OUT VARCHAR2,
      pmode VARCHAR2 DEFAULT 'EST');

   /*************************************************************************
      Preguntes automàtiques a nivell de garantia
      param in out priesgo   : objecte risc
      param in     pssolicit : sseguro de la pòlissa
      param in     pnmovimi  : nmovimi de la pòlissa
      param in     pmode     : el valor de com recuperar les dades (EST o POL)
   *************************************************************************/
   PROCEDURE p_get_pregautoriegar(
      priesgo IN OUT ob_iax_riesgos,
      pssolicit IN NUMBER,
      pnmovimi IN NUMBER,
      pmode VARCHAR2 DEFAULT 'EST');

   /*************************************************************************
      Preguntes automàtiques a nivell de garantia
      param in out pgaran    : objecte garantia
      param in     pssolicit : sseguro de la pòlissa
      param in     pnmovimi  : nmovimi de la pòlissa
      param in     pmode     : el valor de com recuperar les dades (EST o POL)
      param in     pnriesgo  : codi del risc
   *************************************************************************/
   PROCEDURE p_get_pregautogar(
      pgaran IN OUT ob_iax_garantias,
      pssolicit IN NUMBER,
      pnmovimi IN NUMBER,
      pmode VARCHAR2 DEFAULT 'EST',
      pnriesgo IN NUMBER);

   --ACC 171200208
    /*************************************************************************
       Recupera si es poden recuperar les primes a nivell de poliza
       param in     det_poliza : objecta de la pòlissa
    *************************************************************************/
   FUNCTION f_get_needtarificarpol(det_poliza IN ob_iax_detpoliza)
      RETURN NUMBER;

   --ACC 171200208

   --bug 7535 ACC 17022009
    /*************************************************************************
       Comprova si tots el riscos estan tarificats i si ho estan deixa el
       indicador de pòlissa con a tarficat o bé com a no tarificat
       param in out     det_poliza : objecte de la pòlissa
    *************************************************************************/
   PROCEDURE p_check_needtarificarpol(det_poliza IN OUT ob_iax_detpoliza);

   --bug 7535 ACC 17022009

   -- BUG9263:DRA:11/05/2009:Inici
   /*************************************************************************
      Recupera las preguntas de póliza automaticas
      param in/out detpoliza : objeto detalle póliza
      param in     pssolicit : código solicitud
      param in     pnmovimi  : número movimiento
      param in     pmode     : modo SOL EST POL
   *************************************************************************/
   PROCEDURE p_get_pregautopol(
      detpoliza IN OUT ob_iax_detpoliza,
      pssolicit IN NUMBER,
      pnmovimi IN NUMBER,
      pmode IN VARCHAR2);

-- BUG9263:DRA:11/05/2009:Fi

   -- ini Bug 0010908 - 17/12/2009 - JMF
   /*************************************************************************
      Prestams a nivell de pòlissa
      param in out pprestamoseg : objecte prestams
      param in     psseguro     : sseguro de la pòlissa
      param in     pnmovimi     : nmovimi de la pòlissa
      param in     pnriesgo     : codi del risc
      param in     ptablas      : el valor de com recuperar les dades (EST)
   *************************************************************************/
   PROCEDURE p_get_prestamoseg(
      pprestamoseg IN OUT t_iax_prestamoseg,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnriesgo IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'EST');

   -- fin Bug 0010908 - 17/12/2009 - JMF
   PROCEDURE p_get_prestcuadroseg(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pctapres IN VARCHAR2,
      pprestcuadroseg IN OUT t_iax_prestcuadroseg,
      ptablas IN VARCHAR2 DEFAULT 'EST');

   -- ini Bug 0010908 - 17/12/2009 - JMF
   /*************************************************************************
      Tablas generadas por preguntas automáticas
      param in out priesgo      : objecte risc
      param in     psseguro     : sseguro de la pòlissa
      param in     pnmovimi     : nmovimi de la pòlissa
      param in     ptablas      : el valor de com recuperar les dades (EST)
   *************************************************************************/
   PROCEDURE p_get_tablaspregauto(
      priesgo IN OUT ob_iax_riesgos,
      pssolicit IN NUMBER,
      pnmovimi IN NUMBER,
      pmode VARCHAR2 DEFAULT 'EST');

-- fin Bug 0010908 - 17/12/2009 - JMF

   /***********************************************************************
      Càlculo del importe del impuesto segun la forma de pago si se debe fraccionar el importe
      param in psseguro    : código del seguro
      param in pmode       : modo
      param in pcconcep    : código del concepto que se desea calcular (VF 27)
      param in pcrecfra    : indica si existe recargo por fraccionamiento o no
      param in pcgarant    : código de la garantia
      param in piprianu    : prima anual
      param in piconcep   : importe del concepto
      return               : importe del concepto dividido entre la forma de pago si aplica (segun imprec.cfracci)
   ***********************************************************************/
   -- Bug 20448 - APD - 19/12/2011 - se crea la funcion
   FUNCTION f_importe_impuesto(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pmode IN VARCHAR2,
      pcconcep IN NUMBER,
      pcrecfra IN NUMBER,
      pcgarant IN NUMBER,
      piprianu IN NUMBER,
      pidtocom IN NUMBER,
      piconcep IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
      Detalle de primas a nivell de garantia
      param in out pgaran    : objecte garantia
      param in     pssolicit : sseguro de la pòlissa
      param in     pnmovimi  : nmovimi de la pòlissa
      param in     pmode     : el valor de com recuperar les dades (EST o POL)
      param in     pnriesgo  : codi del risc
   *************************************************************************/
   -- Bug 21121 - APD - 02/03/2012 - se crea la funcion
   PROCEDURE p_get_detprimas(
      pgaran IN OUT ob_iax_garantias,
      pssolicit IN NUMBER,
      pnmovimi IN NUMBER,
      pmode VARCHAR2 DEFAULT 'EST',
      pnriesgo IN NUMBER);

   /*************************************************************************
       Grabar el capital recomendado para cada garantia
       param in sseguro  : numero de seguro
       param in nriesgo  : numero de riesgo
       param out mensajes : mensajes de error
       return             : 0 todo correcto
                            1 ha habido un error
    *************************************************************************/
   FUNCTION f_act_cap_recomend(
      -- Bug 20504 - JRH - 19/06/2012 - Cálculo capital orientativo
      pnriesgo IN NUMBER,
      -- Fi Bug 20504 - JRH - 19/06/2012
      pobgaran IN OUT ob_iax_garantias,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   --bfp bug 21947 ini
   PROCEDURE p_get_garansegcom(
      riesgo IN OUT ob_iax_riesgos,
      pssolicit IN NUMBER,
      pnmovimi IN NUMBER,
      pmode IN VARCHAR2);

-- Bug 0023183 - DCG - 14/08/2012 - LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
   /*************************************************************************
      Tablas de coacuadro
      param in out pdetpoliza   : detpoliza
      param in     pssolicit    : modalidad comisión
      param in     pnmovimi     : inicio de altura
      param in     pmode        : fin de altura
   *************************************************************************/
   PROCEDURE p_get_coacuadro(
      pdetpoliza IN OUT ob_iax_detpoliza,
      pssolicit IN NUMBER,
      pnmovimi IN NUMBER,
      pmode VARCHAR2);
-- Fin Bug 0023183
END pac_mdobj_prod;

/

  GRANT EXECUTE ON "AXIS"."PAC_MDOBJ_PROD" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MDOBJ_PROD" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MDOBJ_PROD" TO "PROGRAMADORESCSI";
