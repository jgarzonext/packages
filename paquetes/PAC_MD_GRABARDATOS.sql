--------------------------------------------------------
--  DDL for Package PAC_MD_GRABARDATOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_GRABARDATOS" AS
/******************************************************************************
   NAME:       PAC_MD_GRABARDATOS
   PURPOSE: Grabar la información de la poliza en la base de datos

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        14/09/2007   ACC              1. Creación del package.
   2.0        16/09/2009   AMC              2. 11165: Se sustituñe  T_iax_saldodeutorseg por t_iax_prestamoseg
   3.0        14/01/2010   RSC              3. 0011735: APR - suplemento de modificación de capital /prima
   4.0        05/05/2010   RSC              4. 0011735: APR - suplemento de modificación de capital /prima
   5.0        08/06/2010   RSC              5. 0013832: APRS015 - suplemento de aportaciones únicas
   6.0        27/09/2011   DRA              6. 0019069: LCOL_C001 - Co-corretaje
   7.0        01/03/2012   APD              7. 0021121: MDP701 - TEC - DETALLE DE PRIMAS DE GARANTIAS
   8.0        08/03/2012   JMF              0021592: MdP - TEC - Gestor de Cobro
   9.0        04/06/2012   ETM              9. 0021657: MDP - TEC - Pantalla Inquilinos y Avalistas
  10.0        14/08/2012   DCG             10. 0023183: LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
  12.0        03/09/2012   JMF              0022701: LCOL: Implementación de Retorno
  13.0        03/2013      NMM             12. 24735: (POSDE600)-Desarrollo-GAPS Tecnico-Id 33 - Mesadas Extras diferentes a la propia (preguntas)
  14.0        26/07/2013   SHA              14. 27014: LCOL - Revisión QT's Documentación Autos F3a - Se crea la funcion f_grabarprimasgaranseg
  15.0        04/11/2013   RCL              15. 0028263: LCOL899-Proceso Emisi?n Vida Grupo - Desarrollo modificaciones de iAxis para BPM
  16.0        02/06/2014   ELP              16. 0027500: Nueva operativa de mandatos
  17.0        25/06/2014   FBL             17. 0028974: MSV0003-Desarrollo de Comisiones (COM04-Commercial Network Management)
  18.0        23/01/2018   JLTS            18. BUG CONF-1243 QT_724 - 23/01/2018 - Grabar datos de fechas para Vigencia Amparos (SUPLEMENTO 918)
******************************************************************************/

   /*************************************************************************
      Define con que tablas se trabajará
      param in pmode     : modo a trabajar
      param out mensajes : mesajes de error
   *************************************************************************/
   PROCEDURE define_mode(pmode IN VARCHAR2, mensajes IN OUT t_iax_mensajes);

   /*************************************************************************
      Inicializa ejecución package
      param in pmode     : modo a trabajar
      param in pssolicit : código de seguro
      param in pnmovimi  : número de movimientos
      param out mensajes : mesajes de error
      return             : 0 todo ha sido correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_inicializa(
      pmode IN VARCHAR2,
      pssolicit IN NUMBER,
      pnmovimi IN NUMBER DEFAULT 1,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Grabar los datos de la poliza
      param in poliza    : objeto detalle póliza
      param out mensajes : mesajes de error
      return             : 0 todo ha sido correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_grabardatospoliza(poliza IN ob_iax_detpoliza, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Grabar los datos del tomador
      param in tomador   : objeto tomador
      param out mensajes : mesajes de error
      return             : 0 todo ha sido correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_grabartomadores(tomador IN t_iax_tomadores, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Grabar las preguntas de la póliza
      param in tomador   : objeto preguntas
      param out mensajes : mesajes de error
      return             : 0 todo ha sido correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_grabarpreguntes(preg IN t_iax_preguntas, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

    /*************************************************************************
       Grabar los datos de gestión
       param in gestion   : objeto gestion
       param out mensajes : mesajes de error
       return             : 0 todo ha sido correcto
                            1 ha habido un error
    *************************************************************************/
--    FUNCTION F_GrabarDatosGestion(gestion IN OB_IAX_GESTION,
--                                  mensajes  IN OUT T_IAX_MENSAJES) RETURN NUMBER;

   /*************************************************************************
      Grabar los riesgos de la poliza
      param in riesgo    : objeto riesgos
      param out mensajes : mesajes de error
      return             : 0 todo ha sido correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_grabarriesgos(riesgo IN t_iax_riesgos, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Grabar un riesgo de la poliza
      param in riesgo    : objeto riesgos
      param out mensajes : mesajes de error
      return             : 0 todo ha sido correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_grabarriesgo(
      riesgo IN ob_iax_riesgos,
      pnriesgo IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Grabar las cláusulas de la poliza
      param in clausula  : objeto clausula
      param out mensajes : mesajes de error
      return             : 0 todo ha sido correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_grabarclausulas(clausula IN t_iax_clausulas, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Grabar la gestión de comisiones de la póliza
      param in gstcomi  : objeto gestión de comisiones
      param out mensajes : mesajes de error
      return             : 0 todo ha sido correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_grabargstcomision(gstcomi IN t_iax_gstcomision, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

/*************************************************************************
    Grabar información del riesgo -->>
*************************************************************************/

   /*************************************************************************
      Grabar riesgo personal de la poliza
      param in personas  : objeto personas
      param in riesgo    : objeto de riesgo
      param out mensajes : mesajes de error
      return             : 0 todo ha sido correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_grabarriesgopersonal(
      personas IN t_iax_personas,
      riesgo IN ob_iax_riesgos,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Grabar información del riesgo direcciones
      param in direc     : objeto direcciones
      param in pnriesgo  : número de riesgo
      param out mensajes : mesajes de error
      return             : 0 todo ha sido correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_grabarriesgodirecciones(
      direc IN t_iax_direcciones,
      pnriesgo IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Grabar información de los asegurados
      param in aseg      : objeto direcciones
      param in pnriesgo  : número de riesgo
      param out mensajes : mesajes de error
      return             : 0 todo ha sido correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_grabarasegurados(
      aseg IN t_iax_asegurados,
      pnriesgo IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Grabar información de las preguntas
      param in pregun    : objeto preguntas
      param in pnriesgo  : número de riesgo
      param out mensajes : mesajes de error
      return             : 0 todo ha sido correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_grabarpreguntasriesgo(
      pregun IN t_iax_preguntas,
      pnriesgo IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Grabar información de las garantias
      param in garan     : objeto garantias
      param in pnriesgo  : número de riesgo
      param out mensajes : mesajes de error
      return             : 0 todo ha sido correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_grabargarantias(
      garan IN t_iax_garantias,
      pnriesgo IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Actualitza la data efecte dels riscos
      param in psseguro  : codi seguro
      param in pfefecto  : data efecte
      param out mensajes : mesajes de error
      return             : 0 todo ha sido correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_actualizafefectoriesgo(
      psseguro IN NUMBER,
      pfefecto IN DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
     Grabar información de las preguntas de garantias -->>
   *************************************************************************/

   /*************************************************************************
      Grabar información de las preguntas de garantias
      param in pregun    : objeto preguntas
      param in pnriesgo  : número de riesgo
      param in pcgarant  : código de garantia
      param out mensajes : mesajes de error
      return             : 0 todo ha sido correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_grabarpreguntasgarantia(
      pregun IN t_iax_preguntas,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Grabar información de la garantia
      param in garan     : objeto garantia
      param in pnriesgo  : número de riesgo
      param out mensajes : mesajes de error
      return             : 0 todo ha sido correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_grabargarantia(
      garan IN ob_iax_garantias,
      pnriesgo IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   -- INI BUG CONF-1243 QT_724 - 23/01/2018 - Grabar datos de fechas para Vigencia Amparos (SUPLEMENTO 918)
   /*************************************************************************
      Cargar y grabar la informaci??e la garantia con los datos modificados
      por vigencia amparo
      param in riesgo     : objeto riesgo
      param out mensajes : mesajes de error
      return             : 0 todo ha sido correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_grabargardat_vigamparo(
      psproduc IN SEGUROS.Sproduc%TYPE,
      pcactivi IN seguros.cactivi%TYPE,
      riesgos IN OUT t_iax_riesgos,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;
   -- FIN BUG CONF-1243 QT_724
   /*************************************************************************
    <<-- Grabar información de las preguntas de garantias
   **************************************************************************/

   /*************************************************************************
      Grabar información de beneficiarios
      param in benef     : objeto beneficiarios
      param in pnriesgo  : número de riesgo
      param out mensajes : mesajes de error
      return             : 0 todo ha sido correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_grabarbeneficiarios(
      benef IN ob_iax_beneficiarios,
      pnriesgo IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Grabar información de beneficiarios nominales
      param in benef     : objeto beneficiarios nominales
      param in pnriesgo  : número de riesgo
      param out mensajes : mesajes de error
      return             : 0 todo ha sido correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_grabarbenenominales(
      benef IN ob_iax_benenominales,
      pnriesgo IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Grabar información detalle de automoviles
      param in autries   : objeto riesgos automoviles
      param in pnriesgo  : número de riesgo
      param out mensajes : mesajes de error
      return             : 0 todo ha sido correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_grabarriesgoauto(
      autries IN t_iax_autriesgos,
      riesgo IN ob_iax_riesgos,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
         Grabar información del detalle riesgo automovil -->>
   *************************************************************************/

   /*************************************************************************
      Grabar información de los conductores
      param in autries   : objeto riesgos automoviles conductores
      param in pnriesgo  : número de riesgo
      param out mensajes : mesajes de error
      return             : 0 todo ha sido correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_grabarconductores(
      conduc IN t_iax_autconductores,
      pnriesgo IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Grabar información de accesorios
      param in autacc    : objeto riesgos automoviles accesorios
      param in pnriesgo  : número de riesgo
      param out mensajes : mesajes de error
      return             : 0 todo ha sido correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_grabaraccesoriosauto(
      autacc IN t_iax_autaccesorios,
      pnriesgo IN NUMBER,
      pcversion IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
              <<-- Grabar información del detalle riesgo automovil
   **************************************************************************/

   /*************************************************************************
       <<-- Grabar información del riesgo
   *************************************************************************/

   --JRH 03/2008
    /*************************************************************************
      Grabar tabla de intereses técnicos
      param in   poliza: Objeto póliza
      param out mensajes : mesajes de error
      return             : 0 todo ha sido correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_grabar_inttec(poliza IN ob_iax_detpoliza, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   --JRH 03/2008
    /*************************************************************************
      Grabar tabla penalizaciones
      param out mensajes : mesajes de error
      param in   poliza: Objeto póliza
      return             : 0 todo ha sido correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_grabar_penalizacion(poliza IN ob_iax_detpoliza, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   --JRH 03/2008
    /*************************************************************************
      Grabar tabla EST rentas irregulares
      param in   pNRiesgo: Riesgo
      param in   rentaIrr: Objeto rentas irregulares
      param out mensajes : mesajes de error
      return             : 0 todo ha sido correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_grabar_rentasirreg(
      pnriesgo IN NUMBER,
      rentairr IN t_iax_rentairr,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Grabar riesgo direccion de la poliza
      param in sitriesgo  : objeto sitriesgos
      param in riesgo    : objeto de riesgo
      param out mensajes : mesajes de error
      return             : 0 todo ha sido correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_grabarriesgodireccion(
      sitriesgo IN ob_iax_sitriesgos,
      riesgo IN ob_iax_riesgos,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Grabar riesgo descripcion de la poliza
      param in sitriesgo  : objeto sitriesgos
      param in riesgo    : objeto de riesgo
      param out mensajes : mesajes de error
      return             : 0 todo ha sido correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_grabarriesgodescripcion(
      descripcion IN ob_iax_descripcion,
      riesgo IN ob_iax_riesgos,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Grabar los meses que tienen paga extra
      param in psseguro  : numero de seguro
      param in pmesesextra  : objeto con los meses con paga extra
      param out mensajes : mesajes de error
      return             : 0 todo ha sido correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_grabarmesextra(
      psseguro IN NUMBER,
      pmesesextra IN ob_iax_nmesextra,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   -- NMM.24735.03/2013.i
   /*************************************************************************
      Grava els imports dels mesos que tenen paga extra
      param in psseguro      : num. d seguro
      param in pimesosextra  : objeto con los meses con paga extra
      param out mensajes     : missatges d'error
      return                 : 0 Tot Ok
                               1 Error
   *************************************************************************/
   FUNCTION f_gravaimesextra(
      psseguro IN NUMBER,
      pimesesextra IN ob_iax_nmesextra,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Grabar la distribución (perfil de inversión) de la poliza
      param in distribucion  : objeto ob_iax_produlkmodelosinv
      param in pfefecto  : Date con el efecto de la póliza
      param out mensajes : mesajes de error
      return             : 0 todo ha sido correcto
                           1 ha habido un error
   *************************************************************************/
   -- Bug 9031 - 11/03/2009 - RSC - Axis: Análisis adaptación productos indexados
   FUNCTION f_grabardistribucion(
      distribucion IN ob_iax_produlkmodelosinv,
      pfefecto IN DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Grabar los el saldo deutor a las tablas
      param in saldodeutors  : col. t_iax_saldodeutorseg
      param in riesgo  : num. riesgo
      param out mensajes : mesajes de error
      return             : 0 todo ha sido correcto
                           1 ha habido un error
   *************************************************************************/
   -- Bug 10702 - 22/07/2009 - XPL - Nueva pantalla para contratación y suplementos que permita seleccionar cuentas aseguradas.
   -- Bug 11165 - 16/09/2009 - AMC - Se sustituñe  T_iax_saldodeutorseg por t_iax_prestamoseg
   FUNCTION f_grabarriesprestamos(
      prestamo IN t_iax_prestamoseg,
      pnriesgo IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

/*************************************************************************
      Grabar los el cuadro de prestamos
      param in saldodeutors  : col. t_iax_prestcuadroseg
      param out mensajes : mesajes de error
      return             : 0 todo ha sido correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_grabarprestcuadroseg(
      pprestcuadroseg IN t_iax_prestcuadroseg,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

    /*************************************************************************
      Grabar información de la garantia (suplementos economicos APRA).
      param in garan     : objeto garantia
      param in pnriesgo  : número de riesgo
      param out mensajes : mesajes de error
      return             : 0 todo ha sido correcto
                           1 ha habido un error

      Nota: FUNCION PROPIA DE APRA.
   *************************************************************************/
   -- Bug 11735 - RSC - 14/01/2010 - APR - suplemento de modificación de capital /prima
   FUNCTION f_grabargarantia_alta(
      garan IN ob_iax_garantias,
      pnriesgo IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Grabar información de la garantia (suplementos economicos APRA).
      param in garan     : objeto garantia
      param in pnriesgo  : número de riesgo
      param out mensajes : mesajes de error
      return             : 0 todo ha sido correcto
                           1 ha habido un error

      Nota: FUNCION PROPIA DE APRA.
   *************************************************************************/
   FUNCTION f_grabargarantia_modif_supl(
      garan IN ob_iax_garantias,
      pnriesgo IN NUMBER,
      mensajes IN OUT t_iax_mensajes,
      -- Bug 13832 - RSC - 08/06/2010 - APRS015 - suplemento de aportaciones únicas
      pcmotmov IN NUMBER)
      -- Fin Bug 13832
   RETURN NUMBER;

   /*************************************************************************
      Grabar información de la garantia (suplementos economicos APRA).
      param in garan     : objeto garantia
      param in pnriesgo  : número de riesgo
      param out mensajes : mesajes de error
      return             : 0 todo ha sido correcto
                           1 ha habido un error

      Nota: FUNCION PROPIA DE APRA.
   *************************************************************************/
   -- Bug 11735 - RSC - 05/05/2010 - APR - suplemento de modificación de capital /prima
   FUNCTION f_grabargarantia_baja(
      garan IN ob_iax_garantias,
      pnriesgo IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

    /*************************************************************************
      Grabar información de la garantia (suplementos economicos APRA).
      param in garan     : objeto garantia
      param in pnriesgo  : número de riesgo
      param out mensajes : mesajes de error
      return             : 0 todo ha sido correcto
                           1 ha habido un error

      Nota: FUNCION PROPIA DE APRA.
   *************************************************************************/
   -- Bug 13832 - RSC - 09/06/2010 - APRS015 - suplemento de aportaciones únicas
   FUNCTION f_grabargarantia_modif(
      garan IN ob_iax_garantias,
      pnriesgo IN NUMBER,
      mensajes IN OUT t_iax_mensajes,
      pcmotmov IN NUMBER)
      RETURN NUMBER;

   -- Fin Bug 13832

   /*************************************************************************
      Grabar información de la garantia (suplementos economicos APRA).
      param in garan     : objeto garantia
      param in pnriesgo  : número de riesgo
      param out mensajes : mesajes de error
      return             : 0 todo ha sido correcto
                           1 ha habido un error

      Nota: FUNCION PROPIA DE APRA.
   *************************************************************************/
   -- Bug 13832 - RSC - 09/06/2010 - APRS015 - suplemento de aportaciones únicas
   FUNCTION f_grabargarantia_extra(
      garan IN ob_iax_garantias,
      pnriesgo IN NUMBER,
      mensajes IN OUT t_iax_mensajes,
      pcmotmov IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_grabardesglosegarantia(
      desglose IN t_iax_desglose_gar,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Grabar las reglas
      param in reglas  : objeto ob_iax_reglasseg
      param out mensajes : mesajes de error
      return             : 0 todo ha sido correcto
                           1 ha habido un error
   *************************************************************************/
   -- Bug 16106 - RSC - 23/09/2010 - APR - Ajustes e implementación para el alta de colectivos
   FUNCTION f_grabarreglasseg(reglas IN ob_iax_reglasseg, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   -- Fin bug 16106
/*************************************************************************
         F_GRABARDOCREQUERIDA
      Llama a la función PAC_DOCREQUERIDA.F_GRABARDOCREQUERIDA para insertar
      un registro en la tabla ESTDOCREQUERIDA, ESTDOCREQUERIDA_RIESGO o
      ESTDOCREQUERIDA_INQAVAL, dependiendo de la clase de documento que
      estamos insertando.
      param in pseqdocu                : número secuencial de documento
      param in psproduc                : código de producto
      param in psseguro                : número secuencial de seguro
      param in pcactivi                : código de actividad
      param in pnmovimi                : número de movimiento
      param in pnriesgo                : número de riesgo
      param in pninqaval               : número de inquilino/avalista
      param in pcdocume                : código de documento
      param in pctipdoc                : tipo de documento
      param in pcclase                 : clase de documento
      param in pnorden                 : número de orden documento
      param in ptdescrip               : descripción del documento
      param in ptfilename              : nombre del fichero
      param in padjuntado              : indicador de fichero adjuntado
      param in pciddocgedox            : numero id en GEDOX
      param in out mensajes            : mensajes de error
      return                           : 0 todo correcto
                                         1 ha habido un error
   BUG 18351 - 11/05/2011 - JMP - Se crea la función
   *************************************************************************/
   FUNCTION f_grabardocrequerida(
      pseqdocu IN NUMBER,
      psproduc IN NUMBER,
      psseguro IN NUMBER,
      pcactivi IN NUMBER,
      pnmovimi IN NUMBER,
      pnriesgo IN NUMBER,
      pninqaval IN NUMBER,
      pcdocume IN NUMBER,
      pctipdoc IN NUMBER,
      pcclase IN NUMBER,
      pnorden IN NUMBER,
      ptdescrip IN VARCHAR2,
      ptfilename IN VARCHAR2,
      padjuntado IN NUMBER,
      psperson IN NUMBER,
      pctipben IN NUMBER,
      mensajes IN OUT t_iax_mensajes,
      pciddocgedox IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

    -- Ini bug 19276, jbn, 19276
   /*************************************************************************
      Grabar los reemplazos de una poliza
      param in tomador   : Lista de  tomadores
      param out mensajes : mesajes de error
      return             : 0 todo ha sido correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_grabarreemplazos(reemplazos IN t_iax_reemplazos, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   -- BUG19069:DRA:27/09/2011:Inici
   FUNCTION f_grabarcorretaje(corretaje IN t_iax_corretaje, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

-- BUG19069:DRA:27/09/2011:Fi

   /*************************************************************************
      Grabar el detalle de primas (DETPRIMAS de GARANSEG)
      param in detprimas   : Lista de detalle de primas
      param in nriesgo   : Riesgo
      param in cgarant   : Codigo de la garantia
      param in finiefe   : Fecha inicio efecto garantia
      param out mensajes : mesajes de error
      return             : 0 todo ha sido correcto
                           1 ha habido un error
   *************************************************************************/
   -- Bug 21121 - APD - 01/03/2012 - se crea la funcion
   FUNCTION f_grabardetprimas(
      detprimas IN t_iax_detprimas,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      pfiniefe IN DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Grabar primas por garant?(PRIMAS de GARANSEG)
      param in primas   : Objeto primas
      param in nriesgo   : Numero de riesgo
      param in cgarant   : Codigo de la garantia
      param in finiefe   : Fecha inicio efecto garantia
      param out mensajes : mesajes de error
      return             : 0 todo ha sido correcto
                           1 ha habido un error
   *************************************************************************/
   -- Bug 27014 - SHA - 26/07/2013 - se crea la funcion
   FUNCTION f_grabarprimasgaranseg(
      primas IN ob_iax_primas,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      pfiniefe IN DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Grabar los datos del gestor de cobro
      param in gestorcobro: objeto gestor cobro
      param out mensajes : mesajes de error
      return             : 0 todo ha sido correcto
                           1 ha habido un error
   *************************************************************************/
   -- BUG 0021592 - 08/03/2012 - JMF
   FUNCTION f_grabargescobro(gestorcobro IN t_iax_gescobros, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   -- bfp bug 21947 ini
   FUNCTION f_grabargaransegcom(
      pcomisgar IN t_iax_garansegcom,
      pnriesgo IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

--bfp bug 21947 fi
    --BUG 21657 --ETM --04/06/2012
   FUNCTION f_grabarinquiaval(pinquival IN t_iax_inquiaval, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   -- Bug 0023183 - DCG - 14/08/2012 - LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
    /*************************************************************************
      Grabar tabla coacuadro y coacedido
      param in  coacuadro: Objeto cuadro coaseguro
      param out mensajes : mesajes de error
      return             : 0 todo ha sido correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_grabardetcoaseguro(
      pcoacuadro IN ob_iax_coacuadro,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   -- Bug 0022701 - 03/09/2012 - JMF
   FUNCTION f_grabarretorno(retorno IN t_iax_retorno, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_grabarfranquicias(
      bonfranseg t_iax_bonfranseg,
      pnriesgo IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_grabardispositivosauto(
      autdisp IN t_iax_autdispositivos,
      pnriesgo IN NUMBER,
      pcversion IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

    /*************************************************************************
      Grabar el caso bpm
      param in pnnumcaso : numero de caso bpm
      param out mensajes : mesajes de error
      return             : 0 todo ha sido correcto
                           1 ha habido un error

      Bug 28263/153355 - 01/10/2013 - AMC
   *************************************************************************/
   FUNCTION f_grabar_caso_bpmseg(pnnumcaso IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   -- Nueva función 28974 - FBL - 25/06/2014 MSV Bug 0028974
   -- Inserta en la tabla de detalle de comisiones el detalle de cada una de las comisiones definidas para la póliza.
   /*FUNCTION f_grabarcomisionmovimiento(
      p_cempres IN NUMBER,
      p_sseguro IN NUMBER,
      p_cgarant IN NUMBER,
      p_nriesgo IN NUMBER,
      p_nmovimi IN NUMBER,
      p_fecha IN DATE,
      p_modo IN VARCHAR2,
      p_ipricom IN NUMBER,
      p_cmodcom IN NUMBER,
      p_sproces IN NUMBER,
      p_mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;*/
   FUNCTION f_grabar_mandatos_seguros(
      poliza IN ob_iax_detpoliza,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

      --JRH 03/2008
    /*************************************************************************
      Grabar tabla EST los asegurados del mes en el suplemento de regularizaci??      param in   pNRiesgo: Riesgo
      param in   rentaIrr: Objeto rentas irregulares
      param out mensajes : mesajes de error
      return             : 0 todo ha sido correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_grabar_aseguradosmes(
      pnriesgo IN NUMBER,
      pobasegmes IN ob_iax_aseguradosmes,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

    /*************************************************************************
      Grabar tabla EST la versi??e convenio de la p??a
      param in   pNRiesgo: Riesgo
      param in   rentaIrr: Objeto rentas irregulares
      param out mensajes : mesajes de error
      return             : 0 todo ha sido correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_grabar_convempvers(
      pconvempvers IN ob_iax_convempvers,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

  -- CONF-274-25/11/2016-JLTS- Ini
  /*************************************************************************
     Grabar tabla EST la versión de reinicio de la póliza
     param in   pNRiesgo: Riesgo
     param in   rentaIrr: Objeto rentas irregulares
     param out mensajes : mesajes de error
     return             : 0 todo ha sido correcto
                          1 ha habido un error
  *************************************************************************/
  FUNCTION f_grabar_reinicio(pssegpol NUMBER ,psseguro NUMBER, pfinicio DATE, pffinal DATE,
                             pttexto VARCHAR2, pcmotmov NUMBER,
                             pnmovimi NUMBER, mensajes OUT t_iax_mensajes)
    RETURN NUMBER;
  -- CONF-274-25/11/2016-JLTS- Fin
END pac_md_grabardatos;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_GRABARDATOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_GRABARDATOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_GRABARDATOS" TO "PROGRAMADORESCSI";
