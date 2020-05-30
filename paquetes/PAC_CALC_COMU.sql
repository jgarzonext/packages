--------------------------------------------------------
--  DDL for Package PAC_CALC_COMU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_CALC_COMU" IS
   /******************************************************************************
      NAME:       PAC_CALC_COMU
      PURPOSE:

      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      1.0        ??/??/????  ???              1. Created this package body.
      2.0        01/07/2009  NMM              0010470: CEM - ESCUT - Profesiones sobreprimas y extraprimas
      3.0        20/07/2009  JRH              Bug 10876: CEM - PPA - Ajustar formulación a histórico de intereses y gastos
      4.0        14/12/2009  APD              Bug 12277: Hay que adaptar el calculo de la fecha de revisión para las rentas vitacilicias de CEM
      5.0        22/12/2010  APD              Bug 16768: APR - Implementación y parametrización del producto GROUPLIFE (II)
      6.0        23/04/2011  MDS              Bug 21907: MDP - TEC - Descuentos y recargos (técnico y comercial) a nivel de póliza/riesgo/garantía
      7.0        19/06/2012  JRH             20. 0022504: MDP_T001- TEC - Capital Recomendado
     15.0        23/01/2013  MMS             15. 0025584: (f_calcula_fvencim_nduraci) Agregamos el cálculo de la fecha de vencimiento para CDURACI=7. Agregamos el parámetro de pnedamar
   ******************************************************************************/
   FUNCTION f_calcula_nrenova(psproduc IN NUMBER, pfefecto IN DATE, pnrenova OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_calcula_fvencim_nduraci(
      psproduc IN NUMBER,
      pfnacimi IN DATE,
      pfefecto IN DATE,
      pcduraci IN NUMBER,
      pnduraci IN OUT NUMBER,
      pfvencim IN OUT DATE,
      pnpoliza IN NUMBER DEFAULT NULL,   -- Bug 16768 - APD - 22/11/2010 - se añade el parametro pnpoliza
      pnrenova IN NUMBER DEFAULT NULL,   -- Bug 19412 - RSC - 26/10/2011
      pnedamar IN NUMBER DEFAULT NULL,   -- Bug 0025584 - MMS - 23/01/2013
	  pncertif IN NUMBER DEFAULT NULL)	 /*PRBMANT-24 - AAC - 28/06/2016*/
      RETURN NUMBER;

   FUNCTION f_cod_garantia(
      psproduc IN NUMBER,
      ptipo IN NUMBER,
      ppropietario IN NUMBER,
      pctipgar OUT NUMBER)
      RETURN NUMBER;

   FUNCTION ff_capital_min_garantia(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcforpag IN NUMBER,
      pcgarant IN NUMBER)
      RETURN NUMBER;

   FUNCTION ff_capital_max_garantia(psproduc IN NUMBER, pcactivi IN NUMBER, pcgarant IN NUMBER)
      RETURN NUMBER;

   FUNCTION ff_capital_gar_tipo(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      ptipo IN NUMBER,
      pnmovimi IN NUMBER DEFAULT NULL,
      propietario IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION ff_get_fvencim_producto(psproduc IN NUMBER, pfnacimi IN DATE, pfefecto IN DATE)
      RETURN DATE;

   FUNCTION ff_get_cap_garanpro(
      psproduc IN NUMBER,
      ptipo IN NUMBER,
      ppropietario IN NUMBER,
      pcforpag IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_get_reval_producto(psproduc IN NUMBER, pcrevali OUT NUMBER)
      RETURN NUMBER;

   FUNCTION ff_get_duracion(ptablas IN VARCHAR2, psseguro IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_get_reval_poliza(
      ptablas IN VARCHAR2 DEFAULT 'SEG',
      psseguro IN NUMBER,
      pcrevali OUT NUMBER)
      RETURN NUMBER;

   --
   --  MSR 14/8/2007
   -- Funció FF_PRIMA_INICIAL
   -- Donat un sseguro torna la prima inicial
   --
   FUNCTION ff_prima_inicial(
      psseguro IN seguros.sseguro%TYPE,
      pcforpag IN seguros.cforpag%TYPE,
      pnriesgo IN riesgos.nriesgo%TYPE)
      RETURN NUMBER;

   --
   --  MSR 28/9/2007
   -- Funció FF_PRIMA_SATISFECHA
   -- Donat un sseguro torna la prima satisfeta
   --
   FUNCTION ff_prima_satisfecha(psseguro IN seguros.sseguro%TYPE)
      RETURN NUMBER;

   --
   --  RSC 22/01/2008
   -- Funció: ff_prima_satisfecha_fecha
   -- Donat un sseguro torna la prima satisfeta fins a una data
   --
   FUNCTION ff_prima_satisfecha_fecha(psseguro IN seguros.sseguro%TYPE, pfecha IN DATE)
      RETURN NUMBER;

   -- MSR 05/11/2007
   -- Valida si a una persona està donat de baixa
   --
   --  Paràmetres
   --    sSeguro     Obligatori
   --    sPerson     Opcional.
   --                   Si psPerson està informat torna 1 si està de baixa, altrament torna 0
   --                   Si psPerson NO està informat torna 0 si cap està de baixa, 1 si és el primer titular, 2 si és el segon i 3 si ambdós
   --    pFecha      Opcional. Si s'informa la data de finalització o mort a de ser anterior a la data enviada.
   FUNCTION ff_baixa_titular(
      psseguro IN seguros.sseguro%TYPE,
      psperson IN NUMBER,
      pfecha IN DATE DEFAULT NULL)
      RETURN NUMBER;

   -- MSR 05/11/2007
   -- Valida si falta el NIE
   --
   --  Paràmetres
   --    sSeguro     Obligatori
   --    sPerson     Opcional.
   --                   Si psPerson està informat torna 1 falta el NIE, altrament torna 0
   --                   Si psPerson NO està informat torna 0 si no en falta cap, 1 si falta el del primer titular, 2 si falta el del segon i 3 si falten ambdós
   --    pFecha      Opcional. Si s'informa la data de caducitat ha de ser anterior o igual a la data per no tornar que falta el NIE
   FUNCTION ff_falta_nie(
      psseguro IN seguros.sseguro%TYPE,
      psperson IN NUMBER,
      pfecha IN DATE DEFAULT NULL)
      RETURN NUMBER;

   -- MSR 05/11/2007
   -- Valida si falta el NIE
   --
   --  Paràmetres
   --    sSeguro     Obligatori
   --    pTipus      Obligatori.
   --        Si pTipus = 1 torna 0 si és OK i 1 si hi ha desquadrement
   --        Si pTipus = 2 torna l'import del desquadrement o 0 si no n'hi ha
   FUNCTION ff_desquadrament(psseguro IN seguros.sseguro%TYPE, ptipus IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_calcula_fcaranu(
      psproduc IN NUMBER,
      pcforpag IN NUMBER,
      pfefecto IN DATE,
      pnrenova IN NUMBER,
      ofcaranu OUT DATE)
      RETURN NUMBER;

   -- Bug 12277 - APD - 15/12/2009 - se añade a la función el parametro pmodo
   -- que indicará si venimos de Nueva Produccion (1) o una Revision (2)
   FUNCTION f_calcula_frevisio(
      psproduc IN NUMBER,
      pnduraci IN NUMBER,
      pndurper IN NUMBER,
      pfefecto IN DATE,
      pfrevisio OUT DATE,
      pmodo IN NUMBER DEFAULT 1)
      RETURN NUMBER;

------------------------------------------------------------------------------
-- Mantis 7919.#6.i.12/2008.
------------------------------------------------------------------------------
   FUNCTION f_calcula_ndurcob(psproduc IN NUMBER, pnduraci IN NUMBER, pndurcob OUT NUMBER)
      RETURN NUMBER;

 ------------------------------------------------------------------------------
 -- Mantis 7919.#6.f.12/2008.
 ------------------------------------------------------------------------------
------------------------------------------------------------------------------
 -- Mantis 10470.#6.i.07/2009.JAJ.CEM - ESCUT - Profesiones sobreprimas y extraprimas
 ------------------------------------------------------------------------------
   FUNCTION ff_get_infoprofesion(
      p_fecha IN DATE,
      p_cempres IN NUMBER,
      p_cramo IN NUMBER,
      p_cmodali IN NUMBER,
      p_ctipseg IN NUMBER,
      p_ccolect IN NUMBER,
      p_cactivi IN NUMBER,
      p_cgarant IN NUMBER,
      p_tipo IN VARCHAR2,
      p_cprofes IN NUMBER,
      po_sobreprima OUT NUMBER,
      p_cgruppro IN NUMBER DEFAULT 0)
      RETURN NUMBER;

------------------------------------------------------------------------------
-- Mantis 10470.#6.i.07/2009.JAJ.CEM - ESCUT - Profesiones sobreprimas y extraprimas
------------------------------------------------------------------------------

   --  Ini Bug 21907 - MDS - 23/04/2012
   /***********************************************************************
      Devuelve los valores de descuentos y recargos de un riesgo
      param in ptablas   : Tablas ('EST' - temporales, 'SEG' - reales)
      param in psseguro  : Numero interno de seguro
      param in pnriesgo  : Numero interno de riesgo
      param out pdtocom  : Porcentaje descuento comercial
      param out precarg  : Porcentaje recargo técnico
      param out pdtotec  : Porcentaje descuento técnico
      param out preccom  : Porcentaje recargo comercial
      return             : number
   ***********************************************************************/
   FUNCTION f_get_dtorec_riesgo(
      ptablas IN VARCHAR2 DEFAULT 'EST',
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      ppdtocom OUT NUMBER,
      pprecarg OUT NUMBER,
      ppdtotec OUT NUMBER,
      ppreccom OUT NUMBER)
      RETURN NUMBER;

--  Fin Bug 21907 - MDS - 23/04/2012

   -- Bug 20504 - JRH - 19/06/2012 - Cálculo capital orientativo
    /***********************************************************************
       Devuelve el capital recomendado
       param in ptablas   : Tablas ('EST' - temporales, 'SEG' - reales)
       param in psseguro  : Numero interno de seguro
       param in pcactivi  : Numero interno de actividad
       param in pnriesgo  : Numero interno de riesgo
       param in pcgarant  : Numero interno de garatía
       param in pfefecto  : Fecha Movimiento
       param in pnmovmi  : Número movmiento
       param out pcaprec  : Importe
       return             : number
    ***********************************************************************/
   FUNCTION f_act_cap_recomend(
      ptablas IN VARCHAR2 DEFAULT 'EST',
      psseguro IN NUMBER,
      pcactivi IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      pfefecto IN DATE,
      pnmovimi IN NUMBER,
      pcaprec OUT NUMBER)
      RETURN NUMBER;
-- Fi Bug 20504 - JRH - 19/06/2012
END pac_calc_comu;

/

  GRANT EXECUTE ON "AXIS"."PAC_CALC_COMU" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CALC_COMU" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CALC_COMU" TO "PROGRAMADORESCSI";
