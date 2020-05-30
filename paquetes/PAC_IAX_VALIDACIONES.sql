--------------------------------------------------------
--  DDL for Package PAC_IAX_VALIDACIONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_VALIDACIONES" AS
/******************************************************************************
   NOMBRE:       PAC_IAX_VALIDACIONES
   PROPÓSITO:  Funciones de validaciones para el IAxis

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        23/11/2007   ACC                1. Creación del package.
   2.0        18/02/2009   AMC                2. Se añade la funcion f_valida_cuest_salud
   3.0        21/09/2009   DRA                3. 0011091: APR - error en la pantalla de simulacion
   4.0        22/09/2009   AMC                4. 11165: Se sustituñe  T_iax_saldodeutorseg por t_iax_prestamoseg
   5.0        27/06/2011   APD                5. 0018848: LCOL003 - Vigencia fecha de tarifa
   6.0        26/10/2011   ICV                6. 0019152: LCOL_T001- Beneficiari Nominats - LCOL_TEC-02_Emisión_Brechas01
   7.0        16/11/2011   JMC                7. 0019303: LCOL_T003-Analisis Polissa saldada/prorrogada. LCOL_TEC_ProductosBrechas04
   8.0        04/06/2012   ETM                8. 0021657: MDP - TEC - Pantalla Inquilinos y Avalistas
   9.0        03/09/2012   JMF                9.  0022701: LCOL: Implementación de Retorno
  10.0        15/02/2013   JDS               10. 025964: LCOL - AUT - Experiencia
  11.0        11/12/2013   JDS               11. 0029315: LCOL_T031-Revisi?n Q-Trackers Fase 3A III
  12.0        16/01/2014   MMS               12. 0027305: POSS518 (POSSF200)- Resolucion de Incidencias FASE 1-2: Tecnico - Conmutacion Pensional
******************************************************************************/

   /*************************************************************************
      Valida datos tomadores
      param out mensajes : mensajes de error
      return             : 0 todo correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_validatomadores(mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Valida datos asegurados
      param out mensajes : mensajes de error
      return             : 0 todo correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_validaasegurados(mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

-- JLB - I - INICIO
  /*************************************************************************
       Valida datos asegurados (datos  basicos, datos basics direccion )
       param out mensajes : mensajes de error
       return             : 0 todo correcto
                            1 ha habido un error
    *************************************************************************/
   FUNCTION f_validadatosasegurados(mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

-- JLB - F - INICIO

   /*************************************************************************
      Valida datos gestión y las preguntas a nivel de póliza
      param out mensajes : mensajes de error
      return             : 0 todo correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_validadatosgstpregpol(mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Valida la gestión de riesgos, que los datos de los distintos riesgos
      esten informados
      param out mensajes : mensajes de error
      return             : 0 todo correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_validagestionriesgos(mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Valida las preguntas del riesgo y sus garantias
      param out mensajes : mensajes de error
      return             : 0 todo correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_validadpreggarant(mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Valida las preguntas del riesgo y sus garantias de un riesgo concreto
      param out mensajes : mensajes de error
      return             : 0 todo correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_validadpreggarantriesgo(pnriesgo IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Valida las clausulas
      param out mensajes : mensajes de error
      return             : 0 todo correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_validaclausulas(mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Validación de garantias seleccionadas
      param in selgar    : 1 indica que se ha seleccionado garantia
                           0 indica que se ha deseleccionado la garantia
      param in nriego    : número de riesgo
      param in cgarant   : código garantia
      param out mensajes : mensajes de error
      return             : 0 la validación ha sido correcta
                           1 la validación no ha sido correcta
   *************************************************************************/
   FUNCTION f_validacion_cobliga(
      selgar IN NUMBER,
      nriesgo IN NUMBER,
      cgarant IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Validación de garantias seleccionadas el capital
      param in selgar    : 1 indica que se ha seleccionado garantia
                           0 indica que se ha deseleccionado la garantia
      param in nriego    : número de riesgo
      param in cgarant   : código garantia
      param out mensajes : mensajes de error
      return             : 0 la validación ha sido correcta
                           1 la validación no ha sido correcta
   *************************************************************************/
   FUNCTION f_validacion_capital(
      selgar IN NUMBER,
      nriesgo IN NUMBER,
      cgarant IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Validación de garantias para tarificar
      param in psolicit  : código de seguro
      param in pnriesgo  : número de riesgo
      param in pnmovimi  : número de novimiento
      param in psproduc  : código de producto
      param in pcactivi  : código de actividad
      param out mensajes : mensajes de error
      return             : 0 la validación ha sido correcta
                           1 la validación no ha sido correcta
   *************************************************************************/
   FUNCTION f_validar_garantias_al_tarifar(
      psolicit IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Valida datos gestion
      param out mensajes : mensajes de error
      return             : 0 la validación ha sido correcta
                           1 la validación no ha sido correcta
   *************************************************************************/
   FUNCTION f_validadatosgestion(mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Valida garantias
      param out mensajes : mensajes de error
      return             : 0 la validación ha sido correcta
                           1 la validación no ha sido correcta
   *************************************************************************/
   FUNCTION f_validagarantias(mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
     --bug 7643 Valida preguntas a nivel de póliza, riesgo y garantías
      param in  Psseguro  : Código de Seguro       Vendrá informado siempre
      param in  Pcactivi  : Código de Actividad    Vendrá informado siempre
      param in  Pnriesgo  : Código de Riesgo       Vendrá informado si son preguntas a nivel de riesgo o garantía
      param in  Pcgarant  : Código de Garantía     Vendrá informado si son preguntas a nivel de garantía
      param in  Pnmovimi  : Número de Movimiento   Vendrá informado si son preguntas a nivel de garantía
      param in  Pnmovima  : Movimiento de alta    Vendrá informado si son preguntas a nivel de garantía --bug 7643
      param in  ptablas   : Tablas
      param in preguntas : objeto preguntas
      param in nivelPreg : P póliza - R riesgo - G garantia
      param out mensajes : mensajes de error
      --param in pcgarant  : código de la garantia (puede se nula)
      return             : 0 la validación ha sido correcta
                           1 la validación no ha sido correcta
   *************************************************************************/
   FUNCTION f_validapreguntas(
      psseguro IN NUMBER,   --Bug 7643
      pactivi IN NUMBER,   --Bug 7643
      pnriesgo IN NUMBER,   --Bug 7643
      pcgarant IN NUMBER,   --Bug 7643
      pnmovimi IN NUMBER,   --Bug 7643
      pnmovima IN NUMBER,   --Bug 7643
      ptablas IN VARCHAR2,   -- BUG11091:DRA:21/09/2009
      preguntas IN t_iax_preguntas,
      nivelpreg IN VARCHAR2,
      mensajes OUT t_iax_mensajes
                                 --,pcgarant IN NUMBER DEFAULT NULL
   )
      RETURN NUMBER;

   /*************************************************************************
      Valida los datos del objeto riesgo
      param out mensajes : mensajes de error
      return             : 0 todo correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_validariesgos(mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

    /*************************************************************************
      Valida de que se ha impreso el cuestionario de salud
      param in ppulsado : 0 No pulsado, 1 pulsado
      param in pmodo : 'SIM', 'ALT' o 'SUP'
      param in psseguro : Código de Seguro
      param in pnriesgo : Código del riesgo
      param out mensajes : mensajes de error
      return             : 0 todo correcto
                           1 ha habido un error
   *************************************************************************/
   -- Bug 9051 - 18/02/2009 - AMC - Creacion de la funcion”
   FUNCTION f_valida_cuest_salud(
      ppulsado IN NUMBER,
      pmodo IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

--Bug 9099
/*************************************************************************
       Valida las preguntas de la garantia
       param in    psproduc  : código del producto
       param in    pcactivi  : código de la actividad
       param in    pcgarant  : código de la garantía
       param in    pnmovimi  : Número de movimiento
       param in    pcpregun  : Código de la pregunta
       param in    pcrespue  : Código de la respuesta
       param in    ptrespue  : Respuesta de la pregunta
       param in    psseguro  : Código seguro
       param in    Pnriesgo  : Riesgo
       param in    Pfefecto  : Fecha de efecto
       param in    Pnmovima  : Número de movimiento de alta
       param in    Ptablas   : Tipo de las tablas
       param out mensajes : mensajes de error
       return             : 0 todo correcto
                            1 ha habido un error
*************************************************************************/
   FUNCTION f_validapregungaran(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pnmovimi IN NUMBER,
      pcpregun IN NUMBER,
      pcrespue IN FLOAT,
      ptrespue IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,
      pnmovima IN NUMBER,
      ptablas IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

--Fin 9099

   --BUG 8613 - 160309 - ACC - Suplement Canvi d'agent
   /*************************************************************************
      Valida que el canvi d'agent estigui permés
      param in    pcagentini  : código agent inicial pòlissa
      param in    pcagentfin  : código agent a canviar pòlissa
      param in    pfecha      : data comprovació agent
      param out mensajes : mensajes de error
      return :  0 todo correcto
                1 ha habido un error
   *************************************************************************/
   FUNCTION f_validacanviagent(
      pcagentini IN NUMBER,
      pcagentfin IN NUMBER,
      pfecha IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

--Fi BUG 8613 - 160309 - ACC - Suplement Canvi d'agent

   /*************************************************************************
      Valida el perfil de inversión seleccionado
      param out mensajes : mensajes de error
      return             : 0 todo correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_validaperfilinv(mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    --BUG 9247-24022009-XVM
    FUNCTION f_valida_conductorinnominado
       Funció que valida un conductor.
       param in pnriesgo  : número risc
       param in pnorden   : número conductor
       param in pnedad    : edat
       param in pfcarnet  : data carnet
       param in psexo     : sexe
       param in pnpuntos  : número de punts
       param in  pexper_manual : Numero de años de experiencia del conductor.
       param in  pexper_cexper : Numero de años de experiencia que viene por interfaz.
       param out mensajes : missatges d'error
       return                : 1 -> Tot correcte
                               0 -> S'ha produit un error
    *************************************************************************/
   FUNCTION f_valida_conductorinnominado(
      pnriesgo IN NUMBER,
      pnorden IN NUMBER,
      pfnacimi IN DATE,
      pfcarnet IN DATE,
      psexo IN NUMBER,
      pnpuntos IN NUMBER,
      pexper_manual IN NUMBER,
      pexper_cexper IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Valida que el estado de los fondos de inversión asociados a una empresa
      se encuentren abiertos.

      param out mensajes : mensajes de error
      return             : 0 todo correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_valida_producto(mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
          Valida el saldo deutor
          param out mensajes : mesajes de error
          return             : 0 todo ha sido correcto
                               1 ha habido un error
       *************************************************************************/
   -- Bug 10702 - 22/07/2009 - XPL - Nueva pantalla para contratación y suplementos que permita seleccionar cuentas aseguradas.
   -- Bug 11165 - 16/09/2009 - AMC - Se sustituñe  T_iax_saldodeutorseg por t_iax_prestamoseg
   FUNCTION f_valida_prestamoseg(
      pnriesgo IN NUMBER,
      pprestamo OUT t_iax_prestamoseg,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_validagarantia
      Validaciones garantias
      Param IN psseguro: sseguro
      Param IN pnriesgo: nriesgo
      Param IN pcgarant: cgarant
      return : 0 Si todo ha ido bien, si no el código de error
   *************************************************************************/
   --BUG 16106 - 05/11/2010 - JTS
   FUNCTION f_validagarantia(
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_valida_simulacion
      Validaciones simulacion
      Param IN psseguro: sseguro
      Param IN pnmovimi: nmovimi
      Param IN ptablas: EST o REA
      return : 0 Si todo ha ido bien, si no el código de error
   *************************************************************************/
   -- Bug 18848 - APD - 27/06/2011 - se crea la funcion para validar una simulacion
   FUNCTION f_valida_simulacion(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      ptablas IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
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
   FUNCTION f_valida_reemplazo(
      psseguro IN NUMBER,
      psproduc IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

-- FIN BUG 19276, JBN, REEMPLAZOS

   --Bug.: 19152 - 26/10/2011 - ICV
    /*************************************************************************
      Función que valida benefeiciarios especiales
      param in ob_iax_benespeciales  : Identificador del seguro a reemplazaar
      param out mensajes : mensajes de error
      return             : 0 la validación ha sido correcta
                           1 la validación no ha sido correcta
   *************************************************************************/
   FUNCTION f_validar_beneident(benefesp IN ob_iax_benespeciales, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

/*************************************************************************
      Valida los datos del corretaje
      param out mensajes : mensajes de error
      return             : 0 todo correcto
                           <> 0 ha habido un error
   *************************************************************************/
   FUNCTION f_valida_corretaje(mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

--ini Bug: 19303 - JMC - 16/11/2011 - Automatización del seguro saldado y prorrogado
   /*************************************************************************
      Valida que una póliza pueda ser saldada o prorrogada.
      param out mensajes : mensajes de error
      return             : 0 todo correcto
                           <> 0 ha habido un error
   *************************************************************************/
   FUNCTION f_valida_sp(psseguro IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

--fin Bug: 19303 - JMC - 16/11/2011
-- BUG 21657--ETM --04/06/2012
   FUNCTION f_valida_inquiaval(mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Valida los datos del retorno
      param out mensajes : mensajes de error
      return             : 0 todo correcto
                           1 ha habido un error
   *************************************************************************/
   -- Bug 0022701 - 03/09/2012 - JMF
   FUNCTION f_valida_retorno(mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

    /*************************************************************************
      Valida datos conductores
      param out mensajes : mensajes de error
      return             : 0 todo correcto
                           1 ha habido un error
      Bug 25378/138739 - 27/02/2013 - AMC
   *************************************************************************/
   FUNCTION f_validaconductores(mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_validaasegurados_nomodifcar(psperson IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      f_valida_campo: valida si el valor de un campo en concreto contiene algún carácter no permitido
      param in pcempres    : Código empresa
      param in pcidcampo    : Campo a validar
      param in pcampo    : Texto introducido a validar
      return             : 0 validación correcta
                           <>0 validación incorrecta
   *************************************************************************/
   FUNCTION f_valida_campo(
      pcempres IN NUMBER,
      pcidcampo IN VARCHAR2,
      pcampo IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   -- Inicio Bug 27305 20140121 MMS
    /*************************************************************************
       f_valida_esclausulacertif0: Valida si una clausula pertenece al certificado 0 en un hijo y,
          por lo tanto, no se puede ni borrar ni modificar.
       param in pcempres    : Código empresa
       param in pcidcampo    : Campo a validar
       param in pcampo    : Texto introducido a validar
       return             : 0 validación correcta
                            <>0 validación incorrecta
    *************************************************************************/
   FUNCTION f_valida_esclausulacertif0(
      pnordcla IN NUMBER,
      ptclaesp IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

-- Fin Bug 27305

   -- Bug 31208/176812 - AMC - 06/06/2014
   FUNCTION f_validamodi_plan(pnriesgo IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

-- BUG 0033510 - FAL - 19/11/2014
   /*************************************************************************
      Valida exista al menos un titular y éste tenga todas las garantías contratadas por los dependientes
      param out mensajes : mensajes de error
      return :  0 todo correcto
                <>0 validación incorrecta
   *************************************************************************/
   FUNCTION f_validar_titular_salud(mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
-- FI BUG 0033510 - FAL - 19/11/2014

-- Inicio IAXIS-4207 - ACL - 04/06/2019 guilherme 
/*************************************************************************
    FUNCTION F_AGENTE_BLOCK
    Funcion que retorna 1 si el agente esta bloqueado por persona, 2 si esta bloqueado por codigo o 0 si esta bien

    param IN pcagente  : codigo del agente
    return             : number
   *************************************************************************/  
   FUNCTION F_AGENTE_BLOCK ( 
        pcagente   IN NUMBER, mensajes OUT t_iax_mensajes) 
    RETURN NUMBER;  
-- Fin IAXIS-4207 - ACL - 04/06/2019 guilherme 
END pac_iax_validaciones;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_VALIDACIONES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_VALIDACIONES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_VALIDACIONES" TO "PROGRAMADORESCSI";
