--------------------------------------------------------
--  DDL for Package PAC_MD_VALIDACIONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_VALIDACIONES" AS
/******************************************************************************
   NOMBRE:       PAC_MD_VALIDACIONES
   PROPÓSITO:  Funciones de validaciones para el IAxis

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        09/10/2007   ACC                1. Creación del package.
   2.0        28/01/2008   ACC                2. Reorganización package.
   3.0        27/05/2009   ETM                3. 0010231: APR - Límite de aportaciones en productos fiscales
   4.0        21/09/2009   DRA                4. 0011091: APR - error en la pantalla de simulacion
   5.0        15/10/2009   FAL                5. 0011330: CRE - Bajas a al próximo recibo
   6.0        11/03/2010   DRA                6. 0013360: MODIFICACIONS RENDES VITALICIES
   7.0        22/03/2010   ICV                7. 0013640: CRE202 - Nuevo control en fecha vencimiento producto PPJ Garantit
   8.0        30/06/2010   ICV                8. 0015145: GRC - Capital garantía múltiplo
   9.0        17/05/2011   APD                9. 0018362: LCOL003 - Parámetros en cláusulas y visualización cláusulas automáticas
  10.0        27/06/2011   APD               10. 0018848: LCOL003 - Vigencia fecha de tarifa
  11.0        27/09/2011   DRA               11. 0019069: LCOL_C001 - Co-corretaje
  12.0        16/11/2011   JMC               12. 0019303: LCOL_T003-Analisis Polissa saldada/prorrogada. LCOL_TEC_ProductosBrechas04
  13.0        10/12/2011   RSC               13. 0020163: LCOL_T004-Completar parametrización de los productos de Vida Individual (2ª parte)
  14.0        23/01/2012   APD               14. 0020995: LCOL - UAT - TEC - Incidencias de Contratacion
  15.0        30/01/2012   APD               15. 0020995: LCOL - UAT - TEC - Incidencias de Contratacion
  42.0        23/01/2013   MMS               42. 0025584: f_controledad agregamos el parametro pnedamar
  16.0        04/03/2013   AEG               16. 0024685: (POSDE600)-Desarrollo-GAPS Tecnico-Id 5 -- N?mero de p?liza manual
  17.0        25/11/2013   JSV               17. 0028455: LCOL_T031- TEC - Revisión Q-Trackers Fase 3A II
  18.0        11/12/2013   JDS               18. 0029315: LCOL_T031-Revisi?n Q-Trackers Fase 3A III
  19.0        16/01/2014   MMS               19. 0027305: POSS518 (POSSF200)- Resolucion de Incidencias FASE 1-2: Tecnico - Conmutacion Pensional
  20.0        06/05/2014   ECP               20. 0031204: LCOL896-Soporte a cliente en Liberty (Mayo 2014) /0012459: Error en beneficiarios al duplicar Solicitudes
******************************************************************************/

   /*************************************************************************
      Valida que la edad mínima y máxima de contratación según la fecha de nacimiento
      param in pfnacimi  : fecha nacimiento
      param in pfecha    : fecha efecto
      param in psproduc  : código de producto
      param out mensajes : mensajes de error
      return             : 0 todo correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_controledad(
      pfnacimi IN DATE,
      pfecha IN DATE,
      psproduc IN NUMBER,
      pnedamac IN NUMBER,   -- Bug 0025584 - MMS - 23/01/2013
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Valida si una periodicidad de pago está permitida en un producto
      param in gestion   : datos gestión
      param in psproduc  : código de producto
      param out mensajes : mensajes de error
      return             : 0 todo correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_periodpag(
      gestion IN ob_iax_gestion,
      psproduc IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Valida la edad mínima y máxima de contratación según la parametrización del producto
      param in asegurs   : objeto asegurados
      param in psproduc  : código producto
      param in pfefecto  : fecha efecto
      param out mensajes : mensajes de error
      return             : 0 la validación ha sido correcta
                           1 la validación no ha sido correcta
   *************************************************************************/
   FUNCTION f_valida_edad_prod(
      asegurs ob_iax_asegurados,
      psproduc IN NUMBER,
      pfefecto IN DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Valida la duración y fecha de vencimiento de la póliza según la parametrización del producto
      param out mensajes : mensajes de error
      return             : 0 todo correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_valida_duracion(pdetpoliza IN ob_iax_detpoliza, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
         Función que valida que la fecha de efecto de una póliza
         param in gestion   : datos gestión
         param in psproduc  : código de producto
         param out mensajes : mensajes de error
         return             : 0 la validación ha sido correcta
                              1 la validación no ha sido correcta
   *************************************************************************/
   FUNCTION f_valida_fefecto(
      pgestion IN ob_iax_gestion,
      psproduc IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
         Función que valida que el conjunto polissa_ini - sproduc no esté repetido.
         param in gestion   : datos gestión
         param in psproduc  : código de producto
         param out mensajes : mensajes de error
         return             : 0 la validación ha sido correcta
                              1 la validación no ha sido correcta
   *************************************************************************/
   FUNCTION f_valida_polissaini(
      pgestion IN ob_iax_gestion,
      psproduc IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Validación de garantias seleccionadas
      param in psseguro  : código seguro
      param in pnriesgo  : número de riesgo
      param in pnmovimi  : movimiento seguro
      param in pcgarant  : código garantia
      param in psproduc  : código producto
      param in pcactivi  : código actividad
      param in pnmovima  : movimiento alta
      param in paccion   : SEL selecciona garantia
                           DESEL garantia deseleccionada
      param out mensajes : mensajes de error
      return             : 0 la validación ha sido correcta
                           1 la validación no ha sido correcta
   *************************************************************************/
   FUNCTION f_validacion_cobliga(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pcgarant IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pnmovima IN NUMBER,
      paccion IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Validación de garantias seleccionadas el capital
      param in psseguro  : código seguro
      param in pnriesgo  : número de riesgo
      param in pnmovimi  : movimiento seguro
      param in pcgarant  : código garantia
      param in psproduc  : código producto
      param in pcactivi  : código actividad
      param in pnmovima  : movimiento alta
      param in paccion   : SEL selecciona garantia
                           DESEL garantia deseleccionada
      param out mensajes : mensajes de error
      return             : 0 la validación ha sido correcta
                           1 la validación no ha sido correcta
   *************************************************************************/
   FUNCTION f_validacion_capital(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pcgarant IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pnmovima IN NUMBER,
      paccion IN VARCHAR2,
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
      Validación de una póliza del mismo producto, por persona.
      param in psproduc  : código de producto
      param in psperson  : código de persona
      param in psseguro  : código de seguro
      param out mensajes : mensajes de error
      return             : cantidad de seguros de la persona sperson
   *************************************************************************/
   FUNCTION f_valida_producto_unico(
      psproduc IN NUMBER,
      psperson IN NUMBER,
      psseguro IN NUMBER,
-- BUG 11330 - 15/10/2009 - FAL - Añadir pfefecto para filtrar no se cuenten pólizas con vencimiento programado a fecha anterior al efecto de la nueva póliza
      pfefecto IN DATE,
-- FI BUG 11330  - 15/10/2009 – FAL
 -- JLB - 26301 - I - RSA - Validación póliza partner
      pcagente IN NUMBER,
      pcpolcia IN VARCHAR2,
-- JLB - 26301 - F - RSA - Validación póliza partner
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Validación de NO pólizas pendientes.
      param in psproduc  : código de producto
      param in psperson  : código de persona
      param in psseguro  : código de seguro
      param out mensajes : mensajes de error
      return             : cantidad de seguros de la persona sperson
   *************************************************************************/
   FUNCTION f_valida_no_pol_pendientes(
      psproduc IN NUMBER,
      psperson IN NUMBER,
      psseguro IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Valida si la duración está permitida en la parametrización del producto
      param in psproduc  : código de producto
      param in pndurper  : duración periodo
      param in pfecha    : fecha efecto
      return             : 0 todo correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_durper(
      psproduc IN NUMBER,
      pndurper IN NUMBER,
      pfecha IN DATE,
      mensajes IN OUT t_iax_mensajes)   -- BUG13360:DRA:11/03/2010
      RETURN NUMBER;

   /*************************************************************************
      Valida que exista el agente
      param in  pcagente : código de agente
      param in  pid_prod : identificador del producto (ramo,mod.,tip.,col.)
      param out mensajes : mensajes de error
      return             : 0 la validación ha sido correcta
                           1 la validación no ha sido correcta
   *************************************************************************/
   FUNCTION f_valida_agente(
      pcagente IN NUMBER,
      psproduc IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Valida los códigos de las direcciones
      param in  pcpostal : código postal
      param in  pcpoblac : código de población
      param in  pcprovin : código de la provincia
      param in pcpais    : código del pais
      param out mensajes : mensajes de error
      return             : 0 la validación ha sido correcta
                           1 la validación no ha sido correcta
   *************************************************************************/
   FUNCTION f_valida_codigosdireccion(
      pcpostal IN VARCHAR2,
      pcpoblac IN NUMBER,
      pcprovin IN NUMBER,
      pcpais IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Valida si el agente tiene acceso al producto
      return             : 0 la validación ha sido correcta
                           1 la validación no ha sido correcta
   *************************************************************************/
   FUNCTION f_valida_acces_prod(
      psproduc IN productos.sproduc%TYPE,
      pcagente IN agentes.cagente%TYPE,
      pctipo IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

--bug 7643
/*************************************************************************
       Valida las preguntas a nivel de póliza, riesgo y garantías
       param in  Psseguro  : Código de Seguro       Vendrá informado siempre
       param in  Pcactivi  : Código de Actividad    Vendrá informado siempre
       param in  Pfefecto  : Fecha de Efecto        Vendrá informado siempre
       param in  Pnriesgo  : Código de Riesgo       Vendrá informado si son preguntas a nivel de riesgo o garantía
       param in  Pcgarant  : Código de Garantía     Vendrá informado si son preguntas a nivel de garantía
       param in  Pnmovimi  : Número de Movimiento   Vendrá informado si son preguntas a nivel de garantía
       param in  Pnmovima  :  Movimiento de alta    Vendrá informado si son preguntas a nivel de garantía
       param in  Picapital : Capital                Vendrá informado si son preguntas a nivel de garantía
       param in  ptablas   : Tablas
       param in  preguntas : Objeto preguntas
       param in  prgPar    : Parámetro preguntas
       param out mensajes  : mensajes de error
       return              : 0 la validación ha sido correcta
                             1 la validación no ha sido correcta
    *************************************************************************/
   FUNCTION f_validapreguntas(
      psseguro IN NUMBER,
      pcactivi IN NUMBER,
      pfefecto IN DATE,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      pnmovimi IN NUMBER,
      pnmovima IN NUMBER,
      picapital IN NUMBER,
      ptablas IN VARCHAR2,   -- BUG11091:DRA:21/09/2009
      preguntas IN t_iax_preguntas,
      prgpar IN t_iaxpar_preguntas,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

--Fin bug 7643

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
   -- Bug 9051 - 18/02/2009 - AMC
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

--Fin Bug 9099

   /*************************************************************************
       --BUG 9007 - 10/02/2009 - JTS
       Valida la prima mínima de un seguro por riesgo
       param in  P_sproduc  : Código de Producto
       param in  P_sseguro  : Código de Seguro
       param in  P_nriesgo  : Código de Riesgo
       param out mensajes   : mensajes de error
       return               : 0 la validación ha sido correcta
                              1 la validación no ha sido correcta
   *************************************************************************/
   FUNCTION f_validacion_primaminfrac(
      psproduc IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      --pprima IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

     /*************************************************************************
       --BUG 9513 - 01/04/2009 - LPS
       Valida la prima mínima de un seguro por riesgo
       param in  P_sproduc  : Código de Producto
       param in  P_sseguro  : Código de Seguro
       param in  P_nriesgo  : Código de Riesgo
       param in  P_prima    : importe de la prima
       param out mensajes   : mensajes de error
       return               : 0 la validación ha sido correcta
                              1 la validación no ha sido correcta
   *************************************************************************/
   FUNCTION f_validacion_primamin(
      psproduc IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      --pprima IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

--BUG 8613 - 160309 - ACC - Suplement Canvi d'agent
   /*************************************************************************
      Valida que el canvi d'agent estigui permés
      param in    pcagentini : código agent inicial pòlissa
      param in    pcagentfin : código agent a canviar pòlissa
      param in    pfecha     : data comprovació agent
      param in out mensajes  : mensajes de error
      return :  0 todo correcto
                1 ha habido un error
   *************************************************************************/
   FUNCTION f_validacanviagent(
      pcagentini IN NUMBER,
      pcagentfin IN NUMBER,
      pfecha IN DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

--Fi BUG 8613 - 160309 - ACC - Suplement Canvi d'agent

   /*************************************************************************
      Valida los datos de gestión en cuanto a certificado 0.
      param out mensajes : mensajes de error
      return             : 0 todo correcto
                           1 ha habido un error
   *************************************************************************/
   -- Bug 8286 - 27/02/2009 - RSC - Adaptación iAxis a productos colectivos con certificados
   FUNCTION f_valida_gestioncertifs(
      pgestion IN ob_iax_gestion,
      ppoliza IN ob_iax_detpoliza,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

-- Fin Bug 8286

   --BUG 9709 - 06/04/2009 - LPS - Validación del limite del % de crecimiento geométrico
   /*************************************************************************
      Valida el límite del porcentaje de crecimiento geométrico
      param in    psproduc  : código agent inicial pòlissa
      param in    prevali   : código agent a canviar pòlissa
      param out   mensajes  : mensajes de error
      return :  0 todo correcto
                1 ha habido un error
   *************************************************************************/
   FUNCTION f_valida_limrevalgeom(
      psproduc IN NUMBER,
      pprevali IN NUMBER,
      mensajes OUT t_iax_mensajes,
      pcrevali IN NUMBER DEFAULT 2)   -- Bug 20163 - 10/12/2011 - RSC
      RETURN NUMBER;

      /*************************************************************************
      Valida que el estado de los fondos de inversión asociados a una empresa
      se encuentren abiertos.

      param out mensajes : mensajes de error
      return             : 0 todo correcto
                           1 ha habido un error
   *************************************************************************/
   -- Bug 10040 - 12/05/2009 - RSC - Ajustes productos PPJ Dinámico y Pla Estudiant
   FUNCTION f_valida_finversion(ppoliza IN ob_iax_detpoliza, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   -- Fin Bug 10040

   /*************************************************************************
       Comprobación de al menos haya una garantía dependiente seleccionada
       si existe una garantía padre seleccionada.

       param in  P_sproduc  : Código de Producto
       param in  P_sseguro  : Código de Seguro
       param in  P_nriesgo  : Código de Riesgo
       param out mensajes   : mensajes de error
       return               : 0 la validación ha sido correcta
                              1 la validación no ha sido correcta
   *************************************************************************/
   -- Bug 10113 - 18/05/2009 - RSC - Ajustes FlexiLife nueva emisión
   FUNCTION f_valida_dependencia_basica(
      psproduc IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

-- Fin Bug 10113
/*************************************************************************
   FUNCTION f_validaposttarif
   Validaciones despues de tarifar
   Param IN psproduc: producto
   Param IN psseguro: sseguro
   Param IN pnriesgo: nriesgo
   Param IN pfefecto: Fecha
   return : 0 Si todo ha ido bien, si no el código de error

*************************************************************************/
   --BUG 10231 - 27/05/2009 - ETM -Límite de aportaciones en productos fiscales --INI
   FUNCTION f_validaposttarif(
      psproduc IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

--BUG 10231 - 27/05/2009 - ETM -Límite de aportaciones en productos fiscales --FIN
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
      psaldo OUT t_iax_prestamoseg,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   --Ini Bug.: 13640 - ICV - 17/03/2010
    /*************************************************************************
          Valida la data de venciment pels productes d'estalvi.
          param out mensajes : mesajes de error
          return             : 0 todo ha sido correcto
                               1 ha habido un error
    *************************************************************************/
   FUNCTION f_valida_fvencim_aho(
      pfnacimi IN DATE,
      pffecini IN DATE,
      pfvencim IN DATE,
      ptramo IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

--Fin Bug.: 13640

   --Bug.: 15145 - 30/06/2010 - ICV
   /*************************************************************************
         Valida varios parámetros de capitales de garantías
         param in psproduc  : código de producto
         param in pcgarant  : garantía
         param in picapital  : capital
         param in ptipo  : 1 para Nueva Producción.
         param out mensajes : mensajes de error
         return             : 0 todo correcto
                              1 ha habido un error
      *************************************************************************/
   FUNCTION f_valida_capitales_gar(
      psproduc IN seguros.sproduc%TYPE,
      pcgarant IN NUMBER,
      picapital IN NUMBER,
      ptipo IN NUMBER,
      pfecha IN DATE,
      porigen IN NUMBER DEFAULT 2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

--Fin Bug.: 15145 - 30/06/2010

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
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

--Inicio Bug:17041 --JBN
/*************************************************************************
      Valida la edad mínima de contratación según la parametrización del producto
      param in tomadores   : objeto tomadores
      param in psproduc  : código producto
      param in pfefecto  : fecha efecto
      param out mensajes : mensajes de error
      return             : 0 la validación ha sido correcta
                           1 la validación no ha sido correcta
   *************************************************************************/
   FUNCTION f_valida_edad_tomador(
      tomadores t_iax_tomadores,
      psproduc IN NUMBER,
      pfefecto IN DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

--Fin Bug:17041 --JBN

   -- Bug 18362 - APD - 17/05/2011 - se crea la funcion para validar los parametros de clausulas
   FUNCTION f_valida_claupar(
      psseguro IN NUMBER,
      pcactivi IN NUMBER,
      pfefecto IN DATE,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pnmovima IN NUMBER,
      ptablas IN VARCHAR2,
      psclagen IN NUMBER,
      pnparame IN NUMBER,
      pclaupar IN t_iax_clausupara,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   -- Bug 18848 - APD - 27/06/2011 - se crea la funcion para validar una simulacion
   FUNCTION f_valida_simulacion(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      ptablas IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Valida los datos de gestión  para lel reemplazo
      param out mensajes : mensajes de error
      return             : 0 todo correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_valida_gestion_reemplazo(
      reemplazos IN t_iax_reemplazos,
      pgestion IN ob_iax_gestion,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

-- FIN BUG 19276, JBN, REEMPLAZOS

   /*************************************************************************
      Valida los datos del corretaje
      param out mensajes : mensajes de error
      return             : 0 todo correcto
                           <> 0 ha habido un error
   *************************************************************************/
   FUNCTION f_valida_corretaje(poliza IN ob_iax_detpoliza, mensajes IN OUT t_iax_mensajes)
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

   --Bug.: 20995 - 23/01/2012 - APD
    /*************************************************************************
      Función que valida que no existan repetidos en benefeiciarios especiales
      param in ctipo : 1.- Beneficiarios de riesgo, 2.- Beneficiarios de garantia
      param in sperson : Identificador del beneficiario que no debe estar repetido
      param in norden : Orden del beneficiario que no debe estar repetido
      param in sperson_tit : Identificador del beneficiario de contingencia
      param in ob_iax_benespeciales  : Objeto de beneficiario
      param out mensajes : mensajes de error
      return             : 0 la validación ha sido correcta
                           1 la validación no ha sido correcta
   *************************************************************************/
   FUNCTION f_benef_repetido(
      pctipo IN NUMBER,
      --Ini 31204/12459 --ECP--06/05/2014
      pcgarant IN NUMBER,
      --Fin 31204/12459 --ECP--06/05/2014
      psperson IN NUMBER,
      pnorden IN NUMBER,
      psperson_tit IN NUMBER,
      benefesp IN ob_iax_benespeciales,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   --Bug.: 20995 - 30/01/2012 - APD
    /*************************************************************************
      Función que suma los porcentajes de participacion de los beneficiarios especiales contingentes
      param in ctipo : 1.- Beneficiarios de riesgo, 2.- Beneficiarios de garantia
      param in sperson : Identificador del beneficiario contingente
      param in ob_iax_benespeciales  : Objeto de beneficiario
      param out particip : suma del porcentaje de participacion
                mensajes : mensajes de error
      return             : 0 la validación ha sido correcta
                           1 la validación no ha sido correcta
   *************************************************************************/
   FUNCTION f_suma_particip_benef_conting(
      pctipo IN NUMBER,
      psperson IN NUMBER,
      benefesp IN ob_iax_benespeciales,
      pparticip OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
        Función que valida importes fijos de las franquicias
        mensajes : mensajes de error
        return             : 0 la validaciÃ³n ha sido correcta
                             1 la validaciÃ³n no ha sido correcta
     *************************************************************************/
   FUNCTION f_valida_importefijo_franq(
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      franq IN t_iax_bf_proactgrup,
      pbonfranseg IN t_iax_bonfranseg,
      pifranqu IN NUMBER,
      pvalorfranquicias OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_valida_franquicias_libres(
      pnriesgo IN NUMBER,
      pbonfranseg IN t_iax_bonfranseg,
      mensajes IN OUT t_iax_mensajes)
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
      ptablas VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
        Bug: 24685 2013-02-06 AEG
        Función que valida numeracion de poliza manual. Preimpresos.
        mensajes : mensajes de error
        return             : 0 la validaciÃ³n ha sido correcta
                             1 la validaciÃ³n no ha sido correcta
     *************************************************************************/
   FUNCTION f_valida_npreimpreso(
      ptipasignum NUMBER,
      pnpreimpreso NUMBER,
      psseguro NUMBER,
      psproduc NUMBER,
      pcempres NUMBER,
      pcagente NUMBER,
      ptablas VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

-- Bug 28455/0159543 - JSV - 25/11/2013
--   FUNCTION f_validaasegurados_nomodifcar(psperson IN NUMBER, mensajes IN OUT t_iax_mensajes)
   FUNCTION f_validaasegurados_nomodifcar(
      psperson IN NUMBER,
      psseguro IN NUMBER,
      pssegpol IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
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
      psseguro IN NUMBER,
      pmode IN VARCHAR2,
      pnordcla IN NUMBER,
      ptclaesp IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

-- Fin Bug 27305

   -- Bug 31208/176812 - AMC - 06/06/2014
   FUNCTION f_validamodi_plan(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,   -- Bug 31686/179633 - 16/07/2014 - AMC
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

-- BUG 0033510 - FAL - 19/11/2014
   /*************************************************************************
      Valida exista al menos un titular y éste tenga todas las garantías contratadas por los dependientes
      param IN psseguro: sseguro
      param IN pnmovimi: nmovimi
      param out mensajes : mensajes de error
      return :  0 todo correcto
                <>0 validación incorrecta
   *************************************************************************/
   FUNCTION f_validar_titular_salud(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;
-- FI BUG 0033510 - FAL - 19/11/2014
END pac_md_validaciones;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_VALIDACIONES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_VALIDACIONES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_VALIDACIONES" TO "PROGRAMADORESCSI";
