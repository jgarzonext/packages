--------------------------------------------------------
--  DDL for Package PAC_CALCULO_FORMULAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_CALCULO_FORMULAS" AUTHID CURRENT_USER IS
   /******************************************************************************
      NOMBRE:       Pac_Calculo_Formulas
      PROPÓSITO: Cálculo / Evaluación de fórmulas

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        --/--/----   ---             1. Creación del package.
      2.0          22/12/2009   RSC           2. 0010690: APR - Provisiones en productos de cartera (PORTFOLIO)
      3.0        16/11/2012   RSC             3. 0024656: MDP_T001-Ajustes finalies en implataci?n de Suplementos
      4.0        13/03/2013   ECP             4. 0026092: LCOL_T031-LCOL - Fase 3 - (176-11) - Parametrizaci?n PSU's. Nota 140055
   ******************************************************************************/

   --  28-3-2007. Se añaden los parámetros pfecefe y pmodo (para porder hacer previos de cierres).
   -- Bug 10690 - RSC - 22/12/2009 - APR - Provisiones en productos de cartera (PORTFOLIO)
   -- Añadimos pndetgar

   --BUG 24656-XVM-16/11/2012.Añadir paccion
   --paccion       IN NUMBER DEFAULT NULL  Indica si estamos en suplemento o no. 0-Nueva Prod. 2-Suplemento
   FUNCTION calc_formul(
      pfecha IN DATE,   -- Fecha
      psproduc IN NUMBER,   -- SPRODUC
      pcactivi IN NUMBER,   -- Actividad
      pcgarant IN NUMBER,   -- Garantía
      pnriesgo IN NUMBER,   -- Riesgo
      psseguro IN NUMBER,   -- SSEGURO
      pclave IN NUMBER,   -- Clave de la Formula
      resultado OUT NUMBER,   -- Importe P.M.
      pnmovimi IN NUMBER DEFAULT NULL,   -- Movimiento
      psesion IN NUMBER DEFAULT NULL,   -- Sesion
      porigen IN NUMBER DEFAULT 2,
      pfecefe IN DATE DEFAULT NULL,   -- fecha de tarifa
      pmodo IN VARCHAR2 DEFAULT 'R',   --'R'REAL, 'P' PREVIO
      pndetgar IN NUMBER DEFAULT NULL,
      paccion IN NUMBER DEFAULT 1,
      -- Ini Bug 26092 --ECP-- 13/03/2013
      origenpsu IN NUMBER DEFAULT NULL,
      -- Fin Bug 26092 --ECP-- 13/03/2013
      pnrecibo IN NUMBER DEFAULT NULL,   -- BUG31548:DRA:23/09/2014
      pnsinies IN NUMBER DEFAULT NULL)   -- BUG31548:DRA:23/09/2014
      RETURN NUMBER;

   FUNCTION graba_param(wnsesion IN NUMBER, wparam IN VARCHAR2, wvalor IN NUMBER)
      RETURN NUMBER;

   FUNCTION borra_param(wnsesion IN NUMBER)
      RETURN NUMBER;
END pac_calculo_formulas;

/

  GRANT EXECUTE ON "AXIS"."PAC_CALCULO_FORMULAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CALCULO_FORMULAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CALCULO_FORMULAS" TO "PROGRAMADORESCSI";
