--------------------------------------------------------
--  DDL for Package PAC_PROPIO_FORMUL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_PROPIO_FORMUL" AUTHID CURRENT_USER IS
 /******************************************************************************
      NOMBRE:     PAC_PROPIO_FORMUL
      PROPÓSITO:  Funciones propias de calculos de Riesgo y Ahorro

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        XX/XX/XXXX   XXX                1. Creación del package.
      1.1        30/01/2009   JRH                2. Bug-8782 Revisión cálculo capital garantizado en productos de Ahorro
      1.2        01/03/2009   JRH                3. Bug 7959 Decesos
   ******************************************************************************/
--Calcula la prov. matemática y el cap. garantizado de una póliza del producto FDA.
   FUNCTION f_calfeda(
      psesion IN NUMBER,
      psseguro IN NUMBER,
      pfecha IN DATE,
      pfonprov IN NUMBER DEFAULT 0   -- 0 = Capital Garantizado
                                     -- 1 = Provisión matemàtica
                                  )
      RETURN NUMBER;

   FUNCTION f_prueb(
      psesion IN NUMBER,
      psseguro IN NUMBER,
      pfecha IN DATE,
      pfonprov IN NUMBER DEFAULT 0   -- 0 = Capital Garantizado
                                     -- 1 = Provisión matemàtica
                                  )
      RETURN NUMBER;

--Calcula la PB de una póliza del producto FDA a fin de año
--Generalmente pfecha es fin de año: Ej:31/12/2008
   FUNCTION f_calpb(psseguro IN NUMBER, pfecha IN DATE)
      RETURN NUMBER;

   --Proceso que genera la PB de las pólizas de un producto. Devuelve 0 si todo ha ido bien, o el número de pólizas para las
   --que el proceso ha ido mal.
   --Generalmente pfecha es fin de año: Ej:31/12/2008
   -- Proceso, modo ('R' o 'P'),producto, fecha e idiomas son obligatorios.
   FUNCTION f_procpb(
      psproces IN NUMBER,
      psmodo IN NUMBER,
      psproduc IN NUMBER,
      pfecha IN DATE,
      pcidioma IN NUMBER,
      psseguro IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
      -- BUG 7959 - 03/2009 - JRH  - Decesos
       Calcula varios conceptos según el parametro de entrada pmodo.
      Sesión ,seguro y pModo parámetros de entrada.
      Devuelve según modo:
      0-> Factor de Tasa para los capitales de Sepelio o Fallecimiento.
      1-> Provisión de la cobertura que se calcula.
      2-> Capital de Fallecimeinto del producto de Decesos.
      return             : Provisión, null si hay error.
   *************************************************************************/
   FUNCTION f_pdecesosf(psesion IN NUMBER, psseguro IN NUMBER, pfecha IN DATE, pmodo IN NUMBER)
      RETURN NUMBER;

    /*************************************************************************
      -- BUG 7959 - 03/2009 - JRH  - Decesos
      Calcula la provisión total de una póliza de decesos.
      Sesión y seguro de parámetros de entrada.
      return             : Provisión, null si hay error.
   *************************************************************************/
   FUNCTION f_pdecesos(psesion IN NUMBER, psseguro IN NUMBER, pfecha IN DATE)
      RETURN NUMBER;

   FUNCTION f_cpsaldodeu(
      psesion IN NUMBER,
      porigen IN NUMBER,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER)
      RETURN NUMBER;

   -- BUG 7959 - 13/10/2009 - RSC - Operaciones con fondos
   FUNCTION fechaultcambprima281(
      psesion NUMBER,
      pseguro IN NUMBER,
      priesgo IN NUMBER,
      importeprimper OUT NUMBER)
      RETURN NUMBER;

   FUNCTION fechaultcambprima500(
      psesion NUMBER,
      pseguro IN NUMBER,
      pfecha IN NUMBER,
      priesgo IN NUMBER)
      RETURN NUMBER;

   FUNCTION fechaultcambprima508(
      psesion NUMBER,
      pseguro IN NUMBER,
      pfecha IN NUMBER,
      priesgo IN NUMBER)
      RETURN NUMBER;

   FUNCTION fechaultcambprima526(
      psesion NUMBER,
      pseguro IN NUMBER,
      pfecha IN NUMBER,
      priesgo IN NUMBER)
      RETURN NUMBER;

   FUNCTION fechaultcambprima266(
      psesion NUMBER,
      pseguro IN NUMBER,
      pfecha IN NUMBER,
      priesgo IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_cesperado(psesion IN NUMBER, psseguro IN NUMBER, pfecha IN NUMBER)
      RETURN NUMBER;

   FUNCTION ff_cfallec(psesion IN NUMBER, psseguro IN NUMBER, ppfefecto IN NUMBER)
      RETURN NUMBER;

-- Fin Bug 7959

   -- BUG-15443
   FUNCTION ff_cbaja(
      psesion IN NUMBER,
      pcmotsin IN NUMBER,
      pfsinies IN NUMBER,
      pfperini IN NUMBER,
      pfperfin IN NUMBER,
      pndiafrq IN NUMBER,
      pntramo IN NUMBER)
      RETURN NUMBER;

-- Fin BUG-15443

   /*************************************************************************
      Devuelve el capital pendiente
      Param IN psesion: Sesión
      Param IN psseguro: Seguro
      Param IN pfsinies : Fecha del siniestro

      BUG 16169 - 18/10/2010 - AMC
   *************************************************************************/
   FUNCTION f_get_cappendiente(psesion IN NUMBER, psseguro IN NUMBER, pfsinies IN NUMBER)
      RETURN NUMBER;
END pac_propio_formul;

/

  GRANT EXECUTE ON "AXIS"."PAC_PROPIO_FORMUL" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PROPIO_FORMUL" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PROPIO_FORMUL" TO "PROGRAMADORESCSI";
