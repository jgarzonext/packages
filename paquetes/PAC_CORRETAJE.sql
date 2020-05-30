--------------------------------------------------------
--  DDL for Package PAC_CORRETAJE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE PAC_CORRETAJE AS
   /******************************************************************************
      NOMBRE:      PAC_CORRETAJE
      PROPÓSITO:   Contiene las funciones de gestión del Co-corretaje

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        28/09/2011   DRA               1. 0019069: LCOL_C001 - Co-corretaje
      2.0        21/11/2012   DRA               2. 0024802: LCOL_C001-LCOL: Anulaci?n de p?liza con co-corretaje
      3.0        29/11/2012   DCG               3. 0024782: LCOL_C001-Modificar la contabilidad teniendo en cuenta el co-corretaje
      4.0        12/02/2013   DRA               4. 0026036: LCOL: Interface de comisiones liquidadas
      5.0        04/03/2013   DRA               5. 0025924: LCOL: Excel de liquidaciones con co-corretaje
      6.0        18/03/2013   DCG               6. 0024866: Repasar incidencias QT para Fase 2
      7.0        08/07/2013   DCT               7. 0027048: LCOL_T010-Revision incidencias qtracker (V)
      8.0        10/04/2014   MMM               8. 0025872: Revision Qtrackers contabilidad
      9.0        19/072019    SGM               9. IAXIS 4156 iva comision   
   ******************************************************************************/

   -- 8.0 - 10/04/2014 - MMM - 0025872: Revision Qtrackers contabilidad - Inicio
   FUNCTION f_nmovimi_corr(psseguro IN NUMBER, pnmovimi IN NUMBER)
      RETURN NUMBER;

   -- 8.0 - 10/04/2014 - MMM - 0025872: Revision Qtrackers contabilidad - Fin
   FUNCTION f_tiene_corretaje(psseguro IN NUMBER, pnmovimi IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_pcomisi_cor(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pcagente IN NUMBER,
      pfretenc IN DATE,
      ppcomisi OUT NUMBER,
      ppretenc OUT NUMBER,
      ptablas IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_reparto_corretaje(psseguro IN NUMBER, pnmovimi IN NUMBER, pnrecibo IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_traspaso_corretaje(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnrecibo IN NUMBER,
      pcageini IN NUMBER,
      pcagefin IN NUMBER)
      RETURN NUMBER;

   -- BUG25924:DRA:04/03/2013:Inici
   FUNCTION f_segprima_corr(psseguro IN NUMBER, ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

   -- BUG25924:DRA:04/03/2013:Fi
   FUNCTION f_calcular_comision_corretaje(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pfefecto IN DATE,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pcactivi IN NUMBER,
      pcagente IN NUMBER,
      ptablas IN VARCHAR2,
      ppartici IN NUMBER,
      ppcomisi OUT NUMBER,
      ppretenc OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_gen_comision_corr(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnrecibo IN NUMBER,
      psigno IN NUMBER DEFAULT 1)
      RETURN NUMBER;

   -- BUG24782:DCG:29/11/2012:Inici
   FUNCTION f_impcor_agente(
      pimporte IN NUMBER,
      pcagente IN NUMBER,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER)
      RETURN NUMBER;

   -- BUG24782:DCG:29/11/2012:Fi

   -- BUG26036:DRA:12/02/2013:Inici
   FUNCTION ff_comis_corretaje(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pfefecto IN DATE,
      pcagente IN NUMBER,
      ppartici IN NUMBER,
      ptablas IN VARCHAR2)
      RETURN NUMBER;

   -- BUG26036:DRA:12/02/2013:Fi

   -- BUG25924:DRA:04/03/2013:Inici
   FUNCTION f_calcular_liqcom_corretaje(
      pnrecibo IN NUMBER,
      pfefecto IN DATE,
      pcagente IN NUMBER,
      ppcomisi OUT NUMBER,
      ppretenc OUT NUMBER)
      RETURN NUMBER;

-- BUG25924:DRA:04/03/2013:Fi

   -- BUG 0026253 - 04/03/2013 - FAL
   FUNCTION f_esagelider(psseguro IN NUMBER, pnmovimi IN NUMBER, pcagente IN NUMBER)
      RETURN NUMBER;

-- FI BUG 0026253

   -- BUG24866:DCG:18/03/2013:Inici
   FUNCTION f_impcorcomi_agente(
      pimporte IN NUMBER,
      pcagente IN NUMBER,
      pnrecibo IN NUMBER,
      pcestrec IN NUMBER,
      pcgarant IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

-- BUG24866:DCG:18/03/2013:Fi

   --INICIO BUG 27048 - DCT - 08/07/2013
   FUNCTION f_update_age_corretaje(psseguro IN NUMBER)
      RETURN NUMBER;

--FIN BUG 27048 - DCT - 08/07/2013

   --Bug 28043 - JLV 09/09/2013
   FUNCTION f_validapsu(p_seguro IN NUMBER, p_nmovimi IN NUMBER)
      RETURN NUMBER;
-- Fin Bug 28043 - JLV 09/09/2013

END pac_corretaje;

/

  GRANT EXECUTE ON "AXIS"."PAC_CORRETAJE" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CORRETAJE" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CORRETAJE" TO "PROGRAMADORESCSI";
