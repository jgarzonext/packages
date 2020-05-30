--------------------------------------------------------
--  DDL for Package PAC_VALIDACIONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_VALIDACIONES" IS
/******************************************************************************
   NOMBRE:      PAC_VALIDACIONES
   PROPÓSITO: Funciones para las validaciónes

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        27/06/2011   APD             1. Creación del package.
   2.0        17/11/2011   JMC             2. 0019303: LCOL_T003-Analisis Polissa saldada/prorrogada. LCOL_TEC_ProductosBrechas04
   3.0        04/03/2013   AEG             3. 0024685: (POSDE600)-Desarrollo-GAPS Tecnico-Id 5 -- N?mero de p?liza manual
   4.0        25/11/2013   JSV             4. 0028455: LCOL_T031- TEC - Revisión Q-Trackers Fase 3A II
   5.0        16/01/2014   MMS             5. 0027305: POSS518 (POSSF200)- Resolucion de Incidencias FASE 1-2: Tecnico - Conmutacion Pensional
******************************************************************************/

   /*************************************************************************
      FUNCTION f_vigencia_simul
         Valida el periodo de vigencia de una simulacion
         param in psseguro     : secuencia seguro
         param in pnmovimi     : numero de movimiento
         return                : 0 -> Tot correcte
                                 codi error -> S'ha produit un error
   *************************************************************************/
   -- Bug 18848 - APD - 27/06/2011 - se crea la funcion
   FUNCTION f_vigencia_simul(psseguro IN NUMBER, pnmovimi IN NUMBER DEFAULT 1)
      RETURN NUMBER;

   -- INICIO BUG 19276, JBN, REEMPLAZOS
   /*************************************************************************
      Función nueva que valida si una póliza puede ser reemplazada
      param in PSSEGURO    : Identificador del seguro a reemplazaar
      param in PSPRODUC    : Identificador del producto de la póliza nueva
      param out mensajes : mensajes de error
      return             : 0 la validación ha sido correcta
                           1 la validación no ha sido correcta
   *************************************************************************/
   FUNCTION f_valida_reemplazo(psseguro IN NUMBER, psproduc IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
      valida si una póliza puede ser reemplazada
      param in PSSEGURO    : Identificador del seguro a reemplazaar
      param in PSPRODUC    : Fecha de efecto de la póliza
      param out mensajes : mensajes de error
      return             : 0 la validación ha sido correcta
                           1 la validación no ha sido correcta
   *************************************************************************/
   FUNCTION f_valida_gestion_reemplazo(psseguro IN NUMBER, pfefecto IN DATE)
      RETURN NUMBER;

-- FIN BUG 19276, JBN, REEMPLAZOS
-- INICIO BUG 19303 - JMC - 17/11/2011 - Saldar / Prorrogar póliza.
   /*************************************************************************
      valida si una póliza está en situación de ser saldada o prorrogada.
      param in PSSEGURO    : Identificador del seguro a reemplazaar
      param out mensajes : mensajes de error
      return             : 0 la validación ha sido correcta
                           1 la validación no ha sido correcta
   *************************************************************************/
   FUNCTION f_valida_sp(psseguro IN NUMBER)
      RETURN NUMBER;

-- FIN BUG 19303 - JMC - 17/11/2011

   /*************************************************************************
      -- BUG 25143 - XVM - 20/12/2012
      f_valida_campo: valida si el valor de un campo en concreto contiene algún carácter no permitido
      param in pcempres    : Código empresa
      param in pcidcampo    : Campo a validar
      param in pcampo    : Texto introducido a validar
      return             : 0 validación correcta
                           <>0 validación incorrecta
   *************************************************************************/
   FUNCTION f_valida_campo(pcempres IN NUMBER, pcidcampo IN VARCHAR2, pcampo IN VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
        Bug: 24685 2013-02-06 AEG
        Función que valida numeracion de poliza manual. Preimpresos.
        mensajes : mensajes de error
        return             : 0 la validaciÃ³n ha sido correcta
                             1 la validaciÃ³n no ha sido correcta
     *************************************************************************/
   FUNCTION f_valida_polizamanual(
      ptipasignum NUMBER,
      pnpolizamanual NUMBER,
      psseguro NUMBER,
      psproduc NUMBER,
      pcempres NUMBER,
      pcagente NUMBER,
      ptablas VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
        Bug: 24685 2013-02-06 AEG
        Función que valida numeracion de poliza manual. Preimpresos.
        mensajes : mensajes de error
        return             : 0 la validaciÃ³n ha sido correcta
                             1 la validaciÃ³n no ha sido correcta
     *************************************************************************/
   FUNCTION f_valida_npreimpreso(
      pnpreimpreso NUMBER,
      psseguro NUMBER,
      psproduc NUMBER,
      pcempres NUMBER,
      pcagente NUMBER,
      ptablas VARCHAR2)
      RETURN NUMBER;

-- Bug 28455/0159543 - JSV - 25/11/2013
--   FUNCTION f_validaasegurados_nomodifcar(psperson IN NUMBER)
   FUNCTION f_validaasegurados_nomodifcar(
      psperson IN NUMBER,
      psseguro IN NUMBER,
      pssegpol IN NUMBER)
      RETURN NUMBER;

-- Inicio BUG 27305 MMS 20140116
  /*************************************************************************
      FUNCTION f_esclausulacertif0
         Valida si una clausula pertenece al certificado 0 en un hijo y,
         por lo tanto, no se puede ni borrar ni modificar.
         param in psseguro     : secuencia seguro
         param in pnmovimi     : numero de movimiento
         return                : 0 -> Tot correcte
                                 1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_esclausulacertif0(
      psseguro IN NUMBER,
      pmode IN VARCHAR2,
      pnordcla IN NUMBER,
      ptclaesp IN VARCHAR2)
      RETURN NUMBER;

   -- Bug 31208/176812 - AMC - 06/06/2014
   FUNCTION f_validamodi_plan(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER   -- Bug 31686/179633 - 16/07/2014 - AMC
                        )
      RETURN NUMBER;

-- BUG 0033510 - FAL - 19/11/2014
   /*************************************************************************
      Valida exista al menos un titular y éste tenga todas las garantías contratadas por los dependientes
      param IN psseguro: sseguro
      param IN pnmovimi: nmovimi
      return :  0 todo correcto
                <>0 validación incorrecta
   *************************************************************************/
   FUNCTION f_validar_titular_salud(psseguro IN NUMBER, pnmovimi IN NUMBER)
      RETURN NUMBER;
-- FI BUG 0033510 - FAL - 19/11/2014
END pac_validaciones;

/

  GRANT EXECUTE ON "AXIS"."PAC_VALIDACIONES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_VALIDACIONES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_VALIDACIONES" TO "PROGRAMADORESCSI";
