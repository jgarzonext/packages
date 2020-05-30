--------------------------------------------------------
--  DDL for Package PAC_PARM_TARIFAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_PARM_TARIFAS" AUTHID CURRENT_USER AS
    /******************************************************************************
      NOMBRE:     PAC_PARM_TARIFAS
      PROPÓSITO:  Funciones de parámetros de tarificación

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        XX/XX/XXXX   XXX                1. Creación del package.
      2.0        08/07/2009   RSC                2. Bug 10350: APR - Detalle de Garantía (Tarificación)
      3.0        16/11/2011   JRH                3.0020149: LCOL_T001-Renovacion no anual (decenal)
      4.0        22/02/2012   APD                4.0021121: MDP701 - TEC - DETALLE DE PRIMAS DE GARANTIAS
   ******************************************************************************/

   -- Se añade el ctarman como parametro.
-- Se añade PREVALI como parámetro.
-- Se añade el nfactor como parametro y se inserta en sgt.
---------------------------------------------------------------------------------------------
   TYPE parametrostabtyp IS RECORD(
      sseguro        NUMBER,
      cgarant        NUMBER,
      icapital       NUMBER,
      iprianu        NUMBER,
      ipritar        NUMBER,
      cforpag        NUMBER,
      pinttec        NUMBER,
      pgasext        NUMBER,
      pgasint        NUMBER,
      pgaexex        NUMBER,
      pgaexin        NUMBER,
      contnte        NUMBER,
      conttdo        NUMBER,
      edad           NUMBER,
      sexo           NUMBER,
      sperson        NUMBER,
      nasegur        NUMBER,
      pdtocom        NUMBER,
      precarg        NUMBER,
      nriesgo        NUMBER,
      extrapr        NUMBER,
      cclarie        NUMBER,
      ilimite        NUMBER,
      scumulo        NUMBER,
      sperson2       NUMBER,
      qcontr         NUMBER,
      fecven         NUMBER,
      iimppre        NUMBER,
      pintpre        NUMBER,
      ncaren         NUMBER,
      nnumreci       NUMBER,
      cforamor       NUMBER,
      fcarult        NUMBER,
      fefecto        NUMBER,
      fecefe         NUMBER,
      fcarpro        NUMBER,
      ctarman        NUMBER,
      prevali        NUMBER,
      nfactor        NUMBER,
      origen         NUMBER,   -- 0-SOL, 1-EST, 2-SEG
      sproduc        NUMBER,
      fnacimi        NUMBER,
      caccion        NUMBER,   --0.-NP,1.-APO 2.-SUP
      aportext       NUMBER,
      fecmov         NUMBER,
      niterac        NUMBER,
      nmovimi        NUMBER,
      fefepol        NUMBER,
      sitarifa       NUMBER,   -- Bug 10350 - 25/06/2009 - Detalle de garantías (Tarificación)
      ndetgar        NUMBER,   -- Bug 10350 - 08/07/2009 - Detalle de garantías (Tarificación)
      ndurcobdgar    NUMBER,   -- Bug 10350 - 08/07/2009 - Detalle de garantías (Tarificación)
      crevalidgar    NUMBER,   -- Bug 10350 - 08/07/2009 - Detalle de garantías (Tarificación)
      finiefedgar    NUMBER,   -- Bug 10350 - 08/07/2009 - Detalle de garantías (Tarificación)
      pinttecdgar    NUMBER,   -- Bug 10350 - 08/07/2009 - Detalle de garantías (Tarificación)
      cunicadgar     NUMBER,   -- Bug 10350 - 16/07/2009 - Detalle de garantías (Tarificación)
      ctarifadgar    NUMBER,   -- Bug 10350 - 16/07/2009 - Detalle de garantías (Tarificación)
      sprocesdgar    NUMBER,   -- Bug 10350 - 16/07/2009 - Detalle de garantías (Tarificación)
      -- Bug 20149 - 16/11/2011 - JRH - 0020149: LCOL_T001-Renovacion no anual (decenal)
      tasa           NUMBER   -- JRH 0020149: LCOL_T001-Renovacion no anual (decenal)
   -- Fi Bug 20149 - 16/11/2011 - JRH
   );

   TYPE parms_transitorios_tabtyb IS TABLE OF parametrostabtyp
      INDEX BY BINARY_INTEGER;

   TYPE preg_resp IS RECORD(
      cpregun        NUMBER,
      crespue        NUMBER
   );

   TYPE preg_resp_tabtyp IS TABLE OF preg_resp
      INDEX BY BINARY_INTEGER;

   pregun_respue  preg_resp_tabtyp;   -- Declaración de tabla PL/SQL

   -- Bug 21121 - APD - 22/02/2012 - se crea el type TREGCONCEP
   TYPE tregconcep IS RECORD(
      ccampo         VARCHAR2(8),   -- Codigo del campo (tabla GARANFORMULA)
      cconcep        VARCHAR2(8),   -- Subconcepto (tabla CODCAMPO)
      norden         NUMBER,   -- Orden de ejecución
      valor          NUMBER,   --Importe del concepto
      valor2         NUMBER   -- Importe de la aplicación del concepto
   );

   TYPE tregconcep_tabtyp IS TABLE OF tregconcep
      INDEX BY BINARY_INTEGER;

   -- fin Bug 21121 - APD - 22/02/2012
---------------------------------------------------------------------------------------------
   -- Bug 21121 - APD - 22/02/2012 - se añade el parametro tregconcep
   PROCEDURE inserta_parametro(
      psesion IN NUMBER,
      pclave IN NUMBER,
      nreg IN NUMBER,
      parms_transitorios IN parms_transitorios_tabtyb,
      error IN OUT NUMBER,
      prim_tot IN NUMBER DEFAULT NULL,
      tregconcep IN tregconcep_tabtyp);

---------------------------------------------------------------------------------------------
   FUNCTION graba_param(psesion IN NUMBER, pparam IN VARCHAR2, pvalor IN NUMBER)
      RETURN NUMBER;

---------------------------------------------------------------------------------------------
   FUNCTION borra_param_sesion(psesion IN NUMBER)
      RETURN NUMBER;

---------------------------------------------------------------------------------------------
   PROCEDURE borra_parametro(psesion IN NUMBER, pclave IN NUMBER);

---------------------------------------------------------------------------------------------
   FUNCTION insertar_parametros_riesgo(
      psesion IN NUMBER,
      psseguro IN NUMBER,
      psperson IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pcactivi IN NUMBER,
      pedad IN NUMBER,
      psexo IN NUMBER,
      pnasegur IN NUMBER,
      cont IN NUMBER,
      pbusca IN VARCHAR2,
      parms_transitorios IN OUT parms_transitorios_tabtyb)
      RETURN NUMBER;

---------------------------------------------------------------------------------------------
   FUNCTION busca_valor_dinamico(
      pparametro IN VARCHAR2,
      psproduc IN NUMBER,
      psseguro IN NUMBER,
      pcactivi IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      pnmovimi IN NUMBER,
      porigen IN NUMBER,
      pfecefe IN NUMBER,
      pfecha IN NUMBER,   --JRH Tarea 6966,
      pndetgar IN NUMBER,   -- Bug 10350 - 08/07/2009 - RSC - Detalle de Garantía (Tarificación)
      retorno OUT NUMBER)
      RETURN NUMBER;

---------------------------------------------------------------------------------------------
   PROCEDURE cargar_preguntas(
      pnriesgo IN NUMBER,
      pramo IN NUMBER,
      pmodali IN NUMBER,
      ptipseg IN NUMBER,
      pcolect IN NUMBER,
      cont IN OUT NUMBER);

---------------------------------------------------------------------------------------------

   -- Bug 21121 - APD - 05/03/2012 - recupera el valor del parametro de una garantia
   FUNCTION val_gar(
      psesion IN NUMBER,
      pctipo IN NUMBER,
      pcgarant IN NUMBER,
      pnriesgo IN NUMBER DEFAULT 1)
      RETURN NUMBER;

---------------------------------------------------------------------------------------------

   -- Bug 21121 - APD - 13/04/2012 - recupera el valor del parametro de un detalle de una garantia
   FUNCTION val_detprimas(
      psesion IN NUMBER,
      pcgarant IN NUMBER,
      pcconcep IN VARCHAR2,
      pnriesgo IN NUMBER DEFAULT 1)
      RETURN NUMBER;

---------------------------------------------------------------------------------------------

   --BUG 24656-XVM-16/11/2012
   FUNCTION cap_consorci(psesion IN NUMBER, pcgarant IN NUMBER, pnriesgo IN NUMBER DEFAULT 1)
      RETURN NUMBER;

   --BUG 24657-XVM-27/11/2012
   FUNCTION f_suplforpago(psesion IN NUMBER, pcgarant IN NUMBER, pnriesgo IN NUMBER DEFAULT 1)
      RETURN NUMBER;
END;

/

  GRANT EXECUTE ON "AXIS"."PAC_PARM_TARIFAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PARM_TARIFAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PARM_TARIFAS" TO "PROGRAMADORESCSI";
