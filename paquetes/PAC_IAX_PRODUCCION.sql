CREATE OR REPLACE PACKAGE "PAC_IAX_PRODUCCION" IS

   /*******************************************************************************
      NOMBRE:       PAC_IAX_PRODUCCION
      PROPÓSITO: Funciones para contración

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ----------  ------------------------------------
      1.0        22/11/2007   ACC                1. Creación del package.
      2.0        30/11/2007   ACC                2. Incluye metodos para consultar una póliza
      3.0        04/03/2009   DRA                3. 0009296: IAX - Implementar el circuit de recobrament de rebuts en l'emissió de pòlisses pendents d'emetre
      4.0        12/02/2009   RSC                4. Preguntas semiautomáticas
      5.0        27/02/2009   RSC                5. Adaptación iAxis a productos colectivos con certificados
      6.0        11/03/2009   RSC                6. Análisis adaptación productos indexados
      7.0        01/04/2009   SBG                7. S'afegeix paràmetre p_filtroprod a funció f_consultapoliza
      18.0       25/06/2009   RSC                17. 0010101: APR - Detalle de garantía (Consulta)
      20.0       13-08-2009:  XPL                20. 0010093, se añade el cramo, consulta polizas
      21.0       01-09-2009:  XPL                21. 11008, CRE - Afegir camps de cerca en la pantalla de selecció de certificat 0.
      22.0       17/09/2009   AMC                22. 11165: Se sustituñe  T_iax_saldodeutorseg por t_iax_prestamoseg
      23.0       19/01/2010   RSC                23. 0011735: APR - suplemento de modificación de capital /prima
      24.0       28/01/2010   DRA                24. 0010464: CRE - L'anul·lació de propostes pendents d'emetre no tira enderrera correctament el moviment anul·lat.
      25.0       27/04/2010   JRH                25. 0014285: CEM-Se añade interes y fppren
      26.0       22/03/2010   RSC                26. 0011735: APR - suplemento de modificación de capital /prima
      27.0       12/05/2010   AMC                27. Bug 14443 - Se añade la función f_get_domicili_prenedor
      28.0       26/05/2010   DRA                28. 0011288: CRE - Modificación de propuestas retenidas
      29.0       17/06/2010   RSC                29. 0013832: APRS015 - suplemento de aportaciones únicas
      30.0       30/07/2010   XPL                30. 14429: AGA005 - Primes manuals pels productes de Llar, CTARMAN
      31.0       05/08/2010   VCL                31. 0015468: GRC - Búsqueda de pólizas. Añadir Nº Solicitud
      32.0       22/11/2010   JBN                32. 0016410: JBN - CRT003 - Clausulas con parametros
      33.0       01/02/2011   FAL                33. 0017307: CRT003 - Traspaso de genérico a especifico
      34.0       14/04/2011   DRA                34. 0018024: CRT - Parametrizar comision de seguro
      35.0       27/04/2011   JMC                35. 0016730: CRT902 - Aplicar visibilidad oficina en consultas masivas
      36.0       20/05/2011   ICV                36. 0018610: CRT901 - Nuevo requerimiento nota informativa
      37.0       15/06/2011   ETM                37. 0018802: LCOL003 - Permitir modificar la data de renovació (mmdd) en contratació
      38.0       05/09/2011   ICV                38. 0019287: ENSA102-Seleccionar cobrador bancario desde la pantalla de gestión
      39.0       12/09/2011   LCF                39. 0019420: CRT003 - Suplementos de Tomador, asegurado y riesgos personales
      40.0       13/09/2011   DRA                40. 0018682: AGM102 - Producto SobrePrecio- Definicin y Parametrizacin
      41.0       21/10/2011   ICV                41. 0019152: LCOL_T001- Beneficiari Nominats - LCOL_TEC-02_Emisión_Brechas01
      42.0       27/09/2011   DRA                42. 0019069: LCOL_C001 - Co-corretaje
      43.0       03/01/2012   JMF                43. 0020761 LCOL_A001- Quotes targetes
      44.0       09/01/2012   DRA                44. 0020498: LCOL_T001-LCOL - UAT - TEC - Beneficiaris de la p?lissa
      45.0       01/03/2012   DRA                45. 0021467: AGM- Quitar en la descripción de riesgos el plan y al final se muestran caracteres raros
      46.0       08/03/2012   JMF                0021592: MdP - TEC - Gestor de Cobro
      47.0       17/04/2012   ETM                47.0021924: MDP - TEC - Nuevos campos en pantalla de Gestión (Tipo de retribución, Domiciliar 1º recibo, Revalorización franquicia)
      48.0       23/04/2011   MDS                48. 0021907: MDP - TEC - Descuentos y recargos (técnico y comercial) a nivel de póliza/riesgo/garantía
      49.0       18/06/2012   MDS                48. 0021924: MDP - TEC - Nuevos campos en pantalla de Gestión (Tipo de retribución, Domiciliar 1º recibo, Revalorización franquicia)
      50.0       04/06/2012   ETM                50. 0021657: MDP - TEC - Pantalla Inquilinos y Avalistas
      51.0       18/07/2012   MDS                51. 0022824: LCOL_T010-Duplicado de propuestas
      52.0       01/08/2012   FPG                52. 0023075: LCOL_T010-Figura del pagador
      53.0       14/08/2012   DCG                53. 0023183: LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
      54.0       03/09/2012   JMF                54. 0022701: LCOL: Implementación de Retorno
      55.0       01/10/2012   DRA                55. 0022839: LCOL_T010-LCOL - Funcionalidad Certificado 0
      56.0       17/12/2012   DRA                56. 0024793: MDP_T001-Analizar resto de productos de alquiler a implementar como nueva producci?n o migraci?n.
      57.0       20/12/2012   MDS                57. 0024717: (POSPG600)-Parametrizacion-Tecnico-Descripcion en listas Tipos Beneficiarios RV - Cambiar descripcion en listas Tipos Beneficiar
      58.0       07/02/2013   JDS                58. 0025583: LCOL - Revision incidencias qtracker (IV)
      59.0       08/03/2013   JMC           59. 0026261: LCOL_T010-LCOL - Revision incidencias qtracker (IV)
      60.0       11/03/2013   AEG           60. 0024685: (POSDE600)-Desarrollo-GAPS Tecnico-Id 5 -- N?mero de p?liza manual
      61.0       25/02/2013   NMM           61. 24735: (POSDE600)-Desarrollo-GAPS Tecnico-Id 33 - Mesadas Extras diferentes a la propia (preguntas)
      62.0       21/03/2013   ECP           62. 0025859: LCOL_T031-LCOL - AUT - Pantalla conductores (axisctr061) Id 428. Nota 141027
      63.0       10/04/2013   MMS           63. 0025584: POSDE600-(POSDE600)-Desarrollo-GAPS Tecnico-Id 6 - Tipo de duracion de poliza ‘hasta edad’ y edades permitidas por producto. Agregamos NEDAMAR a f_grabardatosgestion
      64.0       26/02/2014   JDS           64. 0030173: LCOL999-Optimizar pantalla de garantias
      65.0       14/04/2014   FAL           65. 0029965: RSA702 - GAPS renovación
      66.00      14/05/2014   FAC           66. 0027305: POSS518 (POSSF200)- Resolucion de Incidencias FASE 1-2: Tecnico - Conmutacion Pensional
      67.0       02/06/2014   ELP           67. 0027500: Nueva operativa de mandatos RSA
      68.0       16/10/2014   MMS           68. 0032676: COLM004-Fecha fin de vigencia de mandato. Campo no obligatorio a informar en la pantallas que se informa la fecha de firma
      69.0       27/07/2015   IGIL          69. 0036596: MSV - Alta , baja y modificacion de citas medicas
      70.0       11/04/2016   JMT           70. 0026373: ENSA998-Envio Automatico de email para os contribuintes
      71.0       17/03/2016   JAEG          71. 41143/229973: Desarrollo Diseño técnico CONF_TEC-01_VIGENCIA_AMPARO
      72.0       17/06/2016   VCG           72. AMA-187-Realizar el desarrollo del GAP 114
      73.0       07/03/2016   JAEG          73. 40927/228750: Desarrollo Diseño técnico CONF_TEC-03_CONTRAGARANTIAS
      74.0       12/09/2016   ASDQ          74. CONF-209-GAP_GTEC50 - Productos multimoneda
      75.0       23/01/2018   JLTS          75  CONF-1243 QT_724: Grabar datos de fechas para Vigencia Amparos (SUPLEMENTO 918)
	  76.0       27/02/2019   ACL    		TCS_827 Se agrega la función f_consultapoliza_contrag.
	  77.0       19/03/2019   CJMR          77. IAXIS-3194: Adición de nuevos campo de búsqueda
	  78.0       22/03/2019   CJMR          78. IAXIS-3195: Adición de nuevos campo de búsqueda
	  79.0       09/04/2019   CJMR          79. IAXIS-3396: Se agrega campo para ajustar cambios de fechas de vigencias
    80.0       21/01/2020   JLTS          80. IAXIS-10627. Se ajustó la función f_leecorretaje incluyendo el parámetro NMOVIMI
   ******************************************************************************/
   poliza ob_iax_poliza;

   --Objeto póliza
   vempresa NUMBER;

   --Código empresa
   vproducto NUMBER;

   --Código producto
   vmodalidad NUMBER;

   --Código modalidad
   vccolect NUMBER;

   --Código de Colectividad del Producto
   vcramo NUMBER;

   --Código de Ramo del Producto
   vctipseg NUMBER;

   --Código de Tipo de Seguro del Producto
   gidioma NUMBER := pac_iax_common.f_get_cxtidioma();

   --Código idioma
   vagente NUMBER;

   --Código agente
   vsolicit NUMBER;

   --Código solicitud
   vssegpol NUMBER;

   --Código corresponde con el sseguro de la tabla SEGUROS cuando el estudio ha pasado a póliza
   vnmovimi NUMBER;

   --Código movimiento
   vfefecto DATE;

   --Fecha efecto
   vfvencim DATE;

   --Fecha vencimiento


   vfefeplazo DATE;

   vfvencplazo DATE;

   vpmode VARCHAR2(3);

   --Indica si se trabaja con SOL EST POL
   vsseguro NUMBER;

   --Códio de seguro de un suplemento (uso exclusivo en modo suplemento)
   issuplem BOOLEAN := FALSE;

   --Indica si se esta tratando un suplemento
   issimul BOOLEAN := FALSE;

   --Indica que estamos tratando una simulación
   issave BOOLEAN := FALSE;

   --per si ha gravat i no sha de netejar
   isneedtom BOOLEAN := TRUE;

   --indica si s'ha de guardar el prenador o no
   isnewsol BOOLEAN := FALSE;

   --per determinar si alguns missatges s'han de mostrar
   isconsult BOOLEAN := FALSE;

   --indica que estem consulta una pòlissa ACC 13122008
   ismodifprop BOOLEAN := FALSE;

   --Indica si se esta modificando una propuesta retenida.
   -- Bug 11735 - RSC - 19/01/2010 - APR - suplemento de modificación de capital /prima
   isaltagar BOOLEAN := FALSE;

   --Indica si se trata de un alta de garantías
   imodifgar BOOLEAN := FALSE;

   --Indica si se trata de una modificación de garantías
   -- Fin Bug 11735

   -- Bug 11735 - RSC - 22/03/2010 - APR - suplemento de modificación de capital /prima
   isbajagar BOOLEAN := FALSE;

   --Indica si se trata de un baja de garantías
   -- Fin Bug 11735

   -- Bug 16106 - RSC - 21/09/2010 - APR - Ajustes e implementación para el alta de colectivos
   isaltacol BOOLEAN := FALSE;

   -- Indica si es alta de colectivo (alta del certificado 0)
   -- Fin Bug 16106

   -- Bug 18610 - ICV - 20/05/2011
   isnotainfor BOOLEAN := FALSE;

   iscambioplan BOOLEAN := FALSE;

   --Bug 27505/148735 - 19/07/2013 - AMC
   vcaseid NUMBER;

-- Inicio IAXIS-3398 31/07/2019 Marcelo Ozawa   
   veditmotmov NUMBER;
-- Fin IAXIS-3398 31/07/2019 Marcelo Ozawa

   --Indica si se esta tratando un suplemento

   /*************************************************************************
      Define con que tablas se trabajará
      param in pmode     : mode en que se debe trabajar
      param out mensajes : mensajes de error
   *************************************************************************/

   PROCEDURE define_mode(pmode    IN VARCHAR2,
                         mensajes OUT t_iax_mensajes);

   /*************************************************************
   Funciones de uso interno
   -- Crea los objetos necesarios
   FUNCTION F_InicializaObjetos RETURN T_IAX_MENSAJES;

   -- Llena los objetos con los datos necesarios
   FUNCTION F_LlenaDatosObjetos RETURN T_IAX_MENSAJES;

   -- Crea una solicitud
   FUNCTION F_Crea_Solicitud(ssolit OUT NUMBER) RETURN T_IAX_MENSAJES;

   *************************************************************/
   /*************************************************************************
   Inicializa el package para emisión de pólizas
   param in pmode     : mode en que debe trabajar la aplicación
   param in pproducto : código del producto seleccionado
   param out          : mensajes de error
   return             : 0 todo ha sido correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_inicializa(pmode     IN VARCHAR2,
                         pproducto NUMBER,
                         pcagente  NUMBER,
                         pmodopant IN VARCHAR2 DEFAULT NULL, --Bug.: 18610 - ICV - 20/05/2011
                         pssolicit OUT NUMBER, --JRH 04/2008 Tarea ESTPERSONAS
                         purl      OUT VARCHAR2,
                         mensajes  OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   Indica si estamos en modo suplemento
   return : 1 indicando que es suplemento
   0 no estamos en modo suplemento
   *************************************************************************/
   FUNCTION f_get_essuplemento RETURN NUMBER;

   /*************************************************************************
   Establece la fecha efecto de
   return : 1 se ha producido un error
   0 ha sido correcto
   *************************************************************************/
   FUNCTION f_set_fechaefecto(pfefecto IN DATE,
                              mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   Graba la información del objeto poliza a la base de datos
   param out  : mensajes de error
   return     : 0 todo ha sido correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_grabarobjetodb(mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   Inserta un nuevo tomador al objeto poliza
   param in sperson   : código de persona a insertar
   param out mensajes : mensajes de error
   param out ppregun  : Pregunta sobre asegurado
   return             : 0 todo ha sido correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_inserttomadores(psperson IN NUMBER,
                              mensajes OUT t_iax_mensajes,
                              ppregun  OUT NUMBER) RETURN NUMBER;

   /*************************************************************************
   Inserta un nuevo asegurado al objeto poliza
   param in sperson   : código de persona a insertar
   param out mensajes : mensajes de error
   return             : 0 todo ha sido correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_insertasegurado(sperson      IN NUMBER,
                              pfecretroact IN DATE,
                              mensajes     OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   Lee los datos de la poliza del tomador
   param out mensajes : mensajes de error
   return             : objeto tomadores
   *************************************************************************/
   FUNCTION f_leetomadores(mensajes OUT t_iax_mensajes) RETURN t_iax_tomadores;

   /*************************************************************************
   Lee los datos de la poliza del último tomador
   param out mensajes : mensajes de error
   return             : objeto tomadores
   *************************************************************************/
   FUNCTION f_leeulttomadores(mensajes OUT t_iax_mensajes)
      RETURN ob_iax_tomadores;

   /*************************************************************************
   Elimina el tomador del objeto tomadores
   param in sperson   : código de personas
   param out mensajes : mensajes de error
   return             : 0 todo correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_eliminatomador(sperson  IN NUMBER,
                             mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   Elimina el tomador del objeto tomadores
   param in sperson   : código de personas
   param out mensajes : mensajes de error
   return             : 0 todo correcto
   1 ha habido un error
   -- Bug 23075 - FPG - 30/07/2012 - LCOL_T010-Figura del pagador
   -- Incluir cexistepagador
   *************************************************************************/
   FUNCTION f_grabartomadores(sperson        IN NUMBER,
                              cdomici        IN NUMBER,
                              isaseg         IN NUMBER,
                              mensajes       OUT t_iax_mensajes,
                              cexistepagador IN NUMBER DEFAULT NULL,
                              cagrupa        IN NUMBER DEFAULT NULL) --IAXIS-2085 03/04/2019 AP
      RETURN NUMBER;

   /*************************************************************************
   Cambia el código de persona de un tomador o de un asegurado
   param in spersonAct   : código de persona a sustituir
   param in spersonPos   : código de persona que sustituye
   param in tipo         : tipo de persona a cambiar T tomador A asegurado
   param out mensajes : mensajes de error
   return             : 0 todo correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_cambiarpersonatomase(spersonact IN NUMBER,
                                   spersonpos IN NUMBER,
                                   tipo       IN VARCHAR2,
                                   mensajes   OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Devuelve el objeto tomador segun su sperson
   param in sperson   : código de persona
   param out mensajes : mensajes de error
   return             : objeto tomador
   *************************************************************************/
   FUNCTION f_get_tomador(sperson  IN NUMBER,
                          mensajes OUT t_iax_mensajes) RETURN ob_iax_tomadores;

   /*************************************************************************
   Devuelve el objeto asegurado segun su sperson
   param in sperson   : código de persona
   param out mensajes : mensajes de error
   return             : objeto tomador
   *************************************************************************/
   FUNCTION f_get_asegurado(sperson  IN NUMBER,
                            mensajes OUT t_iax_mensajes)
      RETURN ob_iax_asegurados;

   /*************************************************************************
   Devuelve el objeto gestor cobro segun su sperson
   param in sperson   : código de persona
   param out mensajes : mensajes de error
   return             : objeto gestor cobro
   *************************************************************************/
   -- BUG 0021592 - 08/03/2012 - JMF
   FUNCTION f_get_gestorcobro(sperson  IN NUMBER,
                              mensajes OUT t_iax_mensajes)
      RETURN ob_iax_gescobros;

   /*************************************************************************
   Recuperar información de los asegurados
   param in  pnriesgo : número riesgo
   param in  psproduc : codi producte
   param out mensajes : mensajes de error
   return             : objeto asegurados
   *************************************************************************/
   FUNCTION f_leeasegurados(pnriesgo IN NUMBER, --BUG9727-19052009-XVM
                            psproduc IN NUMBER,
                            mensajes OUT t_iax_mensajes)
      RETURN t_iax_asegurados;

   /*************************************************************************
   Recuperar información del último asegurado
   param out mensajes : mensajes de error
   param in  pnriesgo : número riesgo
   return             : objeto asegurados
   *************************************************************************/
   FUNCTION f_leeultasegurado(mensajes OUT t_iax_mensajes,
                              pnriesgo IN NUMBER DEFAULT 1)
      RETURN ob_iax_asegurados;

   /*************************************************************************
   Elimina el tomador del objeto tomadores
   param in sperson   : código de personas
   param out mensajes : mensajes de error
   return             : 0 todo correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_eliminaasegurado(sperson  IN NUMBER,
                               mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   Graba la información del asegurado
   param in sperson   : código de personas
   param in cvincle   : código de vinculo
   param IN pcparen   : cod. de parentesco asegurado. mnustes 34583/206992
   param out mensajes : mensajes de error
   return             : 0 todo correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_grabaasegurados(sperson      IN NUMBER,
                              cvincle      IN NUMBER,
                              pfecretroact IN DATE,
                              pcdomici     IN NUMBER,
                              pcparen      IN asegurados.cparen%TYPE,
                              mensajes     OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   Lee datos gestion
   param out mensajes : mensajes de error
   return             : objeto datos gestion
   *************************************************************************/
   FUNCTION f_leedatosgestion(mensajes OUT t_iax_mensajes)
      RETURN ob_iax_gestion;

   /*************************************************************************
      Grabar datos gestion
      param in pfefecto  : fecha efecto
      param in pcduraci  : código duración
      param in pnduraci  : duración
      param in pfvencim  : fecha vencimiento
      param in pcforpag  : forma de pago
      param in pctipcob  : código tipo de cobro
      param in pctipcom  : código tipo comisión
      param in pcdtocom  : código descuento comercial
      param in pcidioma  : código idioma
      param out mensajes : mensajes de error
      param in pcbancar default null : cuenta bancaria
      param in pcsubage default null : código subagente
      return             : 0 todo correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_grabardatosgestion(pfefecto IN DATE,
                                 pcduraci IN NUMBER,
                                 pnduraci IN NUMBER,
                                 pfvencim IN DATE,
                                 pcforpag IN NUMBER,
                                 pctipcob IN NUMBER
                                 -- SBG 04/2008
                                ,
                                 ppolissa_ini IN VARCHAR2,
                                 pctipcom     IN NUMBER,
                                 pdtocom      IN NUMBER,
                                 pcidioma     IN NUMBER,
                                 pcpolcia     IN VARCHAR2, -- BUG 14585 - PFA - Anadir campo poliza compania
                                 mensajes     OUT t_iax_mensajes,
                                 pcbancar     IN VARCHAR2 DEFAULT NULL,
                                 pncuotar     IN NUMBER DEFAULT NULL, -- BUG 0020761 - 03/01/2012 - JMF
                                 pcsubage     IN NUMBER DEFAULT NULL
                                 --JRH 03/2008 Añado datos de producto financieros
                                ,
                                 pndurper    NUMBER DEFAULT NULL,
                                 ppcapfall   NUMBER DEFAULT NULL,
                                 ppdoscab    NUMBER DEFAULT NULL,
                                 pcforpagren NUMBER DEFAULT NULL
                                 -- Mantis 7919.#6.12/2008
                                ,
                                 pndurcob IN NUMBER,
                                 pcrecfra IN NUMBER
                                 -- Mantis 8613.acc
                                ,
                                 pcagente IN NUMBER,
                                 -- Bug 14285 - 26/04/2010 - JRH - 0014285: CEM303 - Informar fecha de primer pago de renta en la contratación e interés
                                 pinttec IN NUMBER DEFAULT NULL,
                                 pfppren IN DATE DEFAULT NULL
                                 -- Fi Bug 14285 - 26/04/2010 - JRH
                                 -- Bug 16106 - 01/10/2010 - JRH - Poner cfprest
                                ,
                                 pcfprest IN NUMBER DEFAULT NULL --JRH Forma de prestación
                                 -- Fi Bug 16106 - 01/10/2010 - JRH
                                 --BUG 18802 ETM--INI
                                ,
                                 pnrenova   IN NUMBER DEFAULT NULL,
                                 pccobban   IN NUMBER DEFAULT NULL, --Bug 19287 - 05/09/2011 - ICV))
                                 pccompani  IN NUMBER DEFAULT NULL, --Bug 19287 - 05/09/2011 - LCF))
                                 pcpromotor IN NUMBER DEFAULT NULL, --Bug 19372/91763 - 12/09/2011 - AMC
                                 pctiprea   IN NUMBER DEFAULT NULL, --Bug 18981/96013 - 03/11/2011 - JRB
                                 pcreafac   IN NUMBER DEFAULT NULL, --Bug 18981/96013 - 03/11/2011 - JRB
                                 pcreatip   IN NUMBER DEFAULT NULL, --Bug 18981/96013 - 03/11/2011 - JRB
                                 pcmoneda   IN NUMBER,
                                 -- BUG 21924 - 16/04/2012 - ETM
                                 pctipretr    IN NUMBER DEFAULT NULL,
                                 pcindrevfran IN NUMBER DEFAULT NULL,
                                 pprecarg     IN NUMBER DEFAULT NULL,
                                 ppdtotec     IN NUMBER DEFAULT NULL,
                                 ppreccom     IN NUMBER DEFAULT NULL,
                                 --fin BUG 21924 - 16/04/2012 - ETM
                                 pcdomper IN NUMBER DEFAULT NULL, -- BUG 21924 - MDS - 18/06/2012
                                 pfrenova IN DATE DEFAULT NULL, -- BUG 0023117 - FAL - 26/07/2012
                                 -- BUG 24685 2013-02-06 AEG
                                 pctipasignum   NUMBER DEFAULT NULL,
                                 pnpolizamanual NUMBER DEFAULT NULL,
                                 pnpreimpreso   NUMBER DEFAULT NULL,
                                 -- fin BUG 24685 2013-02-06 AEG
                                 pnedamar NUMBER DEFAULT NULL, -- Bug 25584 MMS 20130410
                                 -- BUG 27500
                                 pnumfolio      IN NUMBER DEFAULT NULL,
                                 pfmandato      IN DATE DEFAULT NULL,
                                 psucursal      IN VARCHAR2 DEFAULT NULL,
                                 phaymandatprev IN NUMBER DEFAULT NULL, --FIN BUG 18802 ETM
                                 pffinvig       IN DATE DEFAULT NULL, -- Bug 32676 - 20141016 - MMS -- Agregammos ffinvin
                                 pfefeplazo     IN DATE DEFAULT NULL, -- BUG 41143/229973 - 17/03/2016 - JAEG
                                 pfvencplazo    IN DATE DEFAULT NULL -- BUG 41143/229973 - 17/03/2016 - JAEG

                                 ) RETURN NUMBER;

   /*************************************************************************
   Establece la actividad de la póliza
   param in pcactivi  : código de actividad
   param out mensajes : mensajes de error
   return             : 0 todo ha sido correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_set_actividad(pcactivi IN NUMBER,
                            mensajes OUT t_iax_mensajes) RETURN NUMBER;

   -- INI BUG CONF-1243 QT_724 - 23/01/2018 - Grabar datos de fechas para Vigencia Amparos (SUPLEMENTO 918)
   /*************************************************************************
   Recupera la fecha inicial de efecto de la poliza (garantía)
   param out mensajes : mensajes de error
   return             : código de actividad
   *************************************************************************/
   FUNCTION f_get_finiefe(mensajes OUT t_iax_mensajes) RETURN DATE;
   -- FIN BUG CONF-1243 QT_724

   /*************************************************************************
   Recupera la actividad de la póliza
   param out mensajes : mensajes de error
   return             : código de actividad
   *************************************************************************/
   FUNCTION f_get_actividad(mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   Recupera el producto de la póliza
   param out mensajes : mensajes de error
   return             : código del producto
   *************************************************************************/
   FUNCTION f_get_producto(mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   Retorna el idioma por defecto de la póliza
   param out mensajes : mensajes de error
   return             : number -> idioma por defecto de la póliza
   *************************************************************************/
   FUNCTION f_get_idiomadef(mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   Lee los datos de la póliza (preguntas)
   param out mensajes : mensajes de error
   return             : objeto preguntas
   *************************************************************************/
   FUNCTION f_leepreguntaspoliza(mensajes OUT t_iax_mensajes)
      RETURN t_iax_preguntas;

   /*************************************************************************
   Grabar preguntas póliza
   param in cpregun   : Código de la pregunta
   param in crespue   : código de la respuesta
   param in trespue   : texto de la respuesta
   param in trespue   : texto de la respuesta
   param out mensajes : mensajes de error
   return             : 0 todo correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_grabapreguntaspoliza(cpregun  IN NUMBER,
                                   crespue  IN FLOAT,
                                   trespue  IN VARCHAR2,
                                   mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   Recupera las cuentas corrientes del primer tomador
   param out mensajes : mensajes de error
   return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_tomadorccc(psperson OUT NUMBER,
                             mensajes OUT t_iax_mensajes) RETURN SYS_REFCURSOR;

   /*************************************************************************
   Recupera los riesgos de la póliza para gestionarlos
   param out mensajes : mensajes de error
   return             : objeto gestion riesgos
   *************************************************************************/
   FUNCTION f_get_gestriesgos(mensajes OUT t_iax_mensajes)
      RETURN t_iax_gestriesgos;

   /*************************************************************************
   Recupera la prima de un riesgo
   param in nriesgo   : número de riesgo
   param out mensajes : mensajes de error
   return             : objeto gestion riesgos
   *************************************************************************/
   FUNCTION f_get_gestriesgo(nriesgo  IN NUMBER,
                             mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   Recupera el riesgo indicado
   param in nriesgo   : número de riesgo
   param out mensajes : mensajes de error
   return             : objeto riesgo
   *************************************************************************/
   FUNCTION f_get_riesgo(nriesgo  IN NUMBER,
                         mensajes OUT t_iax_mensajes) RETURN ob_iax_riesgos;

   /*************************************************************************
   Recupera la descripción de un riesgo
   param in pnriesgo   : número de riesgo
   param out mensajes  : mensajes de error
   return              : descripción riesgo
   *************************************************************************/
   FUNCTION f_get_descriesgo(pnriesgo IN NUMBER,
                             mensajes OUT t_iax_mensajes) RETURN VARCHAR2;

   /*************************************************************************
   Elimina un riesgo
   param in pnriesgo   : número de riesgo
   param out mensajes  : mensajes de error
   return              : 0 todo ha sido correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_eliminariesgo(pnriesgo IN NUMBER,
                            mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   Recupera los beneficiarios de la póliza
   param in nriesgo   : número de riesgo
   param out mensajes : mensajes de error
   return             : objeto gestion riesgos
   *************************************************************************/
   FUNCTION f_get_claubeneficiario(nriesgo  IN NUMBER,
                                   mensajes OUT t_iax_mensajes)
      RETURN ob_iax_beneficiarios;

   /*************************************************************************
   Grabar beneficiarios
   param in nriesgo  : número de riesgo
   param in tipo     : 1 clausula especial  2 clausula beneficiario
   param in sclaben  : código de la clausula
   param in tclaben  : texto clausula especial
   param out mensajes : mensajes de error
   return             : 0 todo correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_grababeneficiarios(nriesgo  IN NUMBER,
                                 tipo     IN NUMBER,
                                 sclaben  IN NUMBER,
                                 tclaesp  IN VARCHAR2,
                                 mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   Recuperar información de las preguntas
   param in nriesgo  : número de riesgo
   param out mensajes : mensajes de error
   return             : objeto preguntas
   *************************************************************************/
   FUNCTION f_leepreguntasriesgo(pnriesgo IN NUMBER,
                                 mensajes OUT t_iax_mensajes)
      RETURN t_iax_preguntas;

   /*************************************************************************
   Grabar información de las preguntas
   param in nriesgo   : número de riesgo
   param in cpregun   : Código de la pregunta
   param in crespue   : código de la respuesta
   param in trespue   : texto de la respuesta
   param out mensajes : mensajes de error
   return             : 0 todo correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_grabarpreguntasriesgo(nriesgo  IN NUMBER,
                                    cpregun  IN NUMBER,
                                    crespue  IN FLOAT,
                                    trespue  IN VARCHAR2,
                                    mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   Recuperar información de las garantias
   param in nriesgo  : número de riesgo
   param out mensajes : mensajes de error
   return             : objeto garantias
   *************************************************************************/
   FUNCTION f_leegarantias(pnriesgo  IN NUMBER,
                           pcpartida IN NUMBER,
                           mensajes  OUT t_iax_mensajes)
      RETURN t_iax_garantias;

   /*************************************************************************
   Grabar información de las garantias
   param in nriesgo   : número de riesgo
   param in cgarant   : código garantia
   param in selgar    : 1 indica que se ha seleccionado garantia
   0 indica que se ha deseleccionado la garantia
   param in icapital  : importe de capital
   param in crevali   : tipo de revalorización
   param in prevali   : porcentaje de revalorización
   param in irevali   : importe de revalorización
   param out mensajes : mensajes de error
   return             : 0 todo correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_grabargarantias(nriesgo  IN NUMBER,
                              cgarant  IN NUMBER,
                              selgar   IN NUMBER,
                              icapital IN NUMBER,
                              crevali  IN NUMBER,
                              prevali  IN NUMBER,
                              irevali  IN NUMBER,
                              mensajes OUT t_iax_mensajes,
                              ipritar  IN NUMBER DEFAULT NULL) RETURN NUMBER;

   /*************************************************************************
   Recupera información del capital de la garantia
   param in nriesgo   : número de riesgo
   param in cgarant   : código garantia
   return             : importe capital o nulo
   *************************************************************************/
   FUNCTION f_get_captitalgarantia(nriesgo IN NUMBER,
                                   cgarant IN NUMBER) RETURN NUMBER;

   /*************************************************************************
   Recupera la información de las primas a nivel de riesgo
   param in nriesgo   : número de riesgo
   param out mensajes : mensajes de error
   return             : objeto primas
   *************************************************************************/
   FUNCTION f_get_primasgaranttot(nriesgo  IN NUMBER,
                                  mensajes OUT t_iax_mensajes)
      RETURN ob_iax_primas;

   /*************************************************************************
   Establece revalorización a todas las garantias seleccionadas
   param in nriesgo   : número de riesgo
   param in crevali   : tipo de revalorizacion
   param in prevali   : porcentaje de revalorizacion
   param in irevali   : importe de revalorización
   param out mensajes : mensajes de error
   return             : 0 todo correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_set_revalriesgo(nriesgo  IN NUMBER,
                              crevali  IN NUMBER,
                              prevali  IN NUMBER,
                              irevali  IN NUMBER,
                              mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   Recupera la revalorización de la garantias seleccionada
   param in nriesgo   : número de riesgo
   param in cgarant   : código de garantia
   param out crevali  : tipo de revalorizacion
   param out prevali  : porcentaje de revalorizacion
   param out mensajes : mensajes de error
   return             : 0 todo correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_get_revalvalor(nriesgo  IN NUMBER,
                             cgarant  IN NUMBER,
                             crevali  OUT NUMBER,
                             prevali  OUT NUMBER,
                             mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   Recupera la forma de pagament
   param out mensajes : mensajes de error
   return             : forma de pagament o nulo si ha habido errores
   *************************************************************************/
   FUNCTION f_get_garforpag(mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   Establece forma de pagament
   param in cforpag   : forma de pagament
   param out mensajes : mensajes de error
   return             : 0 todo correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_set_garforpag(cforpag  IN NUMBER,
                            mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   Graba la revalorización de la garantias seleccionada
   param in nriesgo   : número de riesgo
   param in cgarant   : código de garantia
   param in crevali   : tipo de revalorizacion
   param in precarg   : sobreprima
   param in prevali   : porcentaje de revalorizacion
   param in Pdtocom   : descuento comercial
   param in iextrap   : extraprima
   param in pdtotec   : Porcentaje descuento técnico -- bug 21907
   param in preccom   : Porcentaje recargo comercial -- bug 21907
   param out mensajes : mensajes de error
   return             : 0 todo correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_grabatiprevalval(nriesgo  IN NUMBER,
                               cgarant  IN NUMBER,
                               crevali  IN NUMBER,
                               prevali  IN NUMBER,
                               precarg  IN NUMBER,
                               pdtocom  IN NUMBER,
                               iextrap  IN NUMBER,
                               pdtotec  IN NUMBER, -- bug 21907
                               preccom  IN NUMBER, -- bug 21907
                               mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   Tarifica el riesgo indicado
   (para ello se debe guardar toda la información a la base de datos)
   param in nriesgo   : número de riesgo
   param out mensajes : mensajes de error
   return             : 0 todo correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_tarificar(nriesgo  IN NUMBER,
                        mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   Recupera las clausulas que el usuario a seleccionado o bien automaticas
   a nivel de producto
   param out mensajes : mensajes de error
   return             : 0 todo correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_leeclausulasprod(mensajes OUT t_iax_mensajes)
      RETURN t_iax_clausulas;

   /*************************************************************************
   Recupera las clausulas que el usuario a seleccionado o bien automaticas (multiples)
   a nivel de producto
   param out mensajes : mensajes de error
   return             : 0 todo correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_leeclausulasprodmult(psclagen IN NUMBER DEFAULT NULL,
                                   pnordcla IN NUMBER DEFAULT NULL,
                                   mensajes OUT t_iax_mensajes)
      RETURN t_iax_clausulas;

   /*************************************************************************
   Graba las clausulas de producto indicadas por el usuario
   param in  sclagen  : código clausula producto
   param in  selclau  : 1 indica que se ha seleccionado clausula
   0 indica que se ha deseleccionado la clausula
   param out mensajes : mensajes de error
   return             : 0 todo correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_grabaclausulas(sclagen  IN NUMBER,
                             selclau  IN NUMBER,
                             mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   Graba las clausulas de producto indicadas por el usuario
   param in  sclagen  : codigo clausula producto generica
   param in  selclau  : 1 indica que se ha seleccionado clausula
   0 indica que se ha deseleccionado la clausula
   param out mensajes : mensajes de error
   return             : 0 todo correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_grabaclausulasmult(sclagen  IN NUMBER,
                                 selclau  IN NUMBER,
                                 pnordcla IN NUMBER,
                                 mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   Recupera las clausulas especificas indicadas por el usuario
   param out mensajes : mensajes de error
   return             : 0 todo correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_leeclausulasesp(pnriesgo IN NUMBER, -- Bug 27539/151777 - 02/09/2013 - AMC
                              pmodo    IN VARCHAR2, -- Bug 27305/0174597- 14/05/2014 - FAC
                              mensajes OUT t_iax_mensajes)
      RETURN t_iax_clausulas;

   /*************************************************************************
   Graba las clausulas especificas indicadas por el usuario
   param in  tclauesp : texto de la clausula especial
   param out mensajes : mensajes de error
   return             : 0 todo correcto
   1 ha habido un error
   bug 24657/131225 - 04/12/2012 -AMC
   *************************************************************************/
   FUNCTION f_grabaclausulasesp(pcidentity IN NUMBER, --bug 24657/131225 - 04/12/2012 -AMC
                                tclauesp   IN VARCHAR2,
                                mensajes   OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   Elimina la clausula especifica indicada por el usuario
   param in  cidentity  : indentificativo clausula especial
   param out mensajes : mensajes de error
   return             : 0 todo correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_eliminaclausulaesp(cidentity IN NUMBER,
                                 mensajes  OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   Recupera los motivos los que la póliza ha quedado retenida
   param out mensajes : mensajes de error
   return             : objeto motivos retención
   *************************************************************************/
   FUNCTION f_get_mvtretencion(mensajes OUT t_iax_mensajes)
      RETURN t_iax_polmvtreten;

   /*************************************************************************
   Recupera la documentación necesaria para poder cumplimentar la póliza
   param out mensajes : mensajes de error
   return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_documentacion(mensajes OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR;

   /*************************************************************************
   Recupera la primas por garantia
   param in  nriesgo  : número riesgo
   param in  cgarant  : código de garantia
   param out mensajes : mensajes de error
   return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_detailprimasgarant(nriesgo  IN NUMBER,
                                     cgarant  IN NUMBER,
                                     mensajes OUT t_iax_mensajes)
      RETURN ob_iax_primas;

   /*************************************************************************
   Graba la información de la póliza como una propuesta dejandola retenida
   con el tipo 1 de reteción de la tabla de valores 708
   param out onpoliza  : poliza retenida
   param out osseguro  : sseguro de la poliza
   param out mensajes  : mensajes de error
   return              : 0 todo correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_grabarpropuesta(onpoliza OUT NUMBER,
                              osseguro OUT NUMBER,
                              mensajes OUT t_iax_mensajes,
                              p_grabar IN NUMBER DEFAULT NULL -- CONF-172
                              ) RETURN NUMBER;

   /*************************************************************************
   Se retiene una póliza por motivos de retención pendientes de autorización
   param out onpoliza  : poliza retenida
   param out osseguro  : sseguro de la poliza
   param out mensajes  : mensajes de error
   return              : 0 todo correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_retenerpropuesta(onpoliza OUT NUMBER,
                               osseguro OUT NUMBER,
                               mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   Emite la póliza
   param out mensajes : mensajes de error
   param out onpoliza : número de póliza
   param out osseguro : sseguro
   return             : 0 todo correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_emitir(mensajes OUT t_iax_mensajes,
                     onpoliza OUT NUMBER,
                     osseguro OUT NUMBER) RETURN NUMBER;

   /*************************************************************************
   Recupera la información de la gestión de comisión
   param out mensajes : mensajes de error
   return             : objeto gestión de comisión
   *************************************************************************/
   FUNCTION f_leegestioncomision(pctipcom IN NUMBER,
                                 mensajes OUT t_iax_mensajes) -- BUG 0025214 - FAL - 09/01/2013
    RETURN t_iax_gstcomision;

   /*************************************************************************
   Graba la información de gestión de comisiones de la póliza
   param in  cmodcom  : modalidad de la comisión
   param out mensajes : mensajes de error
   return             : 0 todo correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_grabagestioncomision(pcmodcom IN NUMBER,
                                   pcomisi  IN NUMBER,
                                   pninialt IN NUMBER DEFAULT NULL, -- Inicio de la altura
                                   pnfinalt IN NUMBER DEFAULT NULL,
                                   mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   Recupera la información de las preguntas de garantía
   param in nriesgo   : número de riesgo
   param in cgarant   : código de garantia
   param out mensajes : mensajes de error
   return             : objeto preguntas
   *************************************************************************/
   FUNCTION f_get_preggarant(nriesgo  IN NUMBER,
                             cgarant  IN NUMBER,
                             mensajes OUT t_iax_mensajes)
      RETURN t_iax_preguntas;

   /*************************************************************************
   Grabar información de las preguntas a nivel de garantia
   param in nriesgo   : número de riesgo
   param in cgarant   : código de garantia
   param in cpregun   : Código de la pregunta
   param in crespue   : código de la respuesta
   param in trespue   : texto de la respuesta
   param out mensajes : mensajes de error
   return             : 0 todo correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_grabapreguntasgarantia(nriesgo  IN NUMBER,
                                     cgarant  IN NUMBER,
                                     cpregun  IN NUMBER,
                                     crespue  IN FLOAT,
                                     trespue  IN VARCHAR2,
                                     mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Recupera las primas a nivel de póliza
   param out mensajes : mensajes de error
   return             : objeto de primas
   *************************************************************************/
   FUNCTION f_get_primaspoliza(mensajes OUT t_iax_mensajes)
      RETURN ob_iax_primas;

   /*************************************************************************
   Antes de emitir la propuesta debe pasar por una serie de controles para saber
   la propuesta debe quedar retenida o no:
   *************************************************************************/
   FUNCTION f_control_emision(mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   Borra los registros de las tablas est
   *************************************************************************/
   PROCEDURE limpiartemporales;

   /************************************************************************
   FI EMISIO
   ************************************************************************/
   /************************************************************************
   INICI CONSULTA
   ************************************************************************/
   -- BUG 9017 - 01/04/2009 - SBG - S'afegeix paràmetre p_filtroprod
   /*************************************************************************
   Devuelve las pólizas que cumplan con el criterio de selección
   param in psproduc     : código de producto
   param in pnpoliza     : número de póliza
   param in pncert       : número de cerificado por defecto 0
   param in pnnumide     : número identidad persona
   param in psnip        : número identificador externo
   param in pbuscar      : nombre+apellidos a buscar de la persona
   param in ptipopersona : tipo de persona
   1 tomador
   2 asegurado
   param in pcmodo       : modo. Para pignoraciones vale 1
   param in p_filtroprod : Tipo de productos requeridos:
   'TF'         ---> Contratables des de Front-Office
   'REEMB'      ---> Productos de salud
   'APOR_EXTRA' ---> Con aportaciones extra
   'SIMUL'      ---> Que puedan tener simulación
   'RESCA'      ---> Que puedan tener rescates
   'SINIS'      ---> Que puedan tener siniestros
   null         ---> Todos los productos
   param out mensajes    : mensajes de error
   return                : ref cursor
   *************************************************************************/
   --13-08-2009:  XPL BUG 0010093, se añade el cramo, consulta polizas
   FUNCTION f_consultapoliza(pramo            IN NUMBER,
                             psproduc         IN NUMBER,
                             pnpoliza         IN NUMBER,
                             pncert           IN NUMBER DEFAULT -1,
                             pnnumide         IN VARCHAR2,
                             psnip            IN VARCHAR2,
                             pbuscar          IN VARCHAR2,
                             pnsolici         IN NUMBER, --bug15468 05/08/2010 VCL Añadir camp número solicitud
                             ptipopersona     IN NUMBER,
                             pcagente         IN NUMBER, --BUG 11313 - JTS - 29/10/2009
                             pcmatric         IN VARCHAR2, --BUG19605:LCF:19/02/2010
                             pcpostal         IN VARCHAR2, --BUG19605:LCF:19/02/2010
                             ptdomici         IN VARCHAR2, --BUG19605:LCF:19/02/2010
                             ptnatrie         IN VARCHAR2, --BUG19605:LCF:19/02/2010
                             pcsituac         IN NUMBER, --BUG19605:LCF:19/02/2010
                             p_filtroprod     IN VARCHAR2,
                             pcpolcia         IN VARCHAR2, -- BUG 14585 - PFA - Anadir campo poliza compania
                             pccompani        IN NUMBER, -- BUG 17160 - JBN - Anadir campo compani
                             pcactivi         IN NUMBER, -- BUG18024:DRA:14/04/2011
                             pcestsupl        IN NUMBER, -- BUG18024:DRA:14/04/2011
                             pnpolrelacionada IN NUMBER,
                             pnpolini         IN VARCHAR2, --BUG19715:XPL:06/12/2011
                             mensajes         OUT t_iax_mensajes,
                             pfilage          IN NUMBER, -- BUG 16730: JMC : 26/04/2011
                             pcsucursal       IN NUMBER DEFAULT NULL, -- Bug 22839/126886 - 29/10/2012 - AMC
                             pcadm            IN NUMBER DEFAULT NULL, -- Bug 22839/126886 - 29/10/2012 - AMC
                             pcmotor          IN VARCHAR2 DEFAULT NULL, -- Bug 25177/133016 - 07/01/2013 - AMC
                             pcchasis         IN VARCHAR2 DEFAULT NULL, -- Bug 25177/133016 - 07/01/2013 - AMC
                             pnbastid         IN VARCHAR2 DEFAULT NULL, -- Bug 25177/133016 - 07/01/2013 - AMC
                             pcmodo           IN NUMBER DEFAULT NULL, -- Bug 27766 10/12/2013
                             pncontrato       IN VARCHAR2 DEFAULT NULL,
                             pfemiini         IN DATE DEFAULT NULL,       -- CJMR 22/03/2019 IAXIS-3195
                             pfemifin         IN DATE DEFAULT NULL,       -- CJMR 22/03/2019 IAXIS-3195
                             pfefeini         IN DATE DEFAULT NULL,       -- CJMR 22/03/2019 IAXIS-3195
                             pfefefin         IN DATE DEFAULT NULL,       -- CJMR 22/03/2019 IAXIS-3195
                             pcusuari         IN VARCHAR2 DEFAULT NULL,   -- CJMR 22/03/2019 IAXIS-3195
                             pnnumidease      IN VARCHAR2 DEFAULT NULL,   -- CJMR 22/03/2019 IAXIS-3195
                             pbuscarase       IN VARCHAR2 DEFAULT NULL)   -- CJMR 22/03/2019 IAXIS-3195
      RETURN SYS_REFCURSOR;

   -- FINAL BUG 9017 - 01/04/2009 - SBG
   /*************************************************************************
   Llena el objeto poliza con la información
   param in sseguro   : número de seguro
   param out mensajes : mensajes de error
   return             : 0 todo correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_set_consultapoliza(sseguro  IN NUMBER,
                                 mensajes OUT t_iax_mensajes,
                                 pmode    IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

   /***********************************************************************
   Recupera datos genéricos la póliza
   param in psseguro  : código de seguro
   param in pmode     : indica si es el EST POL
   param out mensajes : mensajes de error
   return             : OB_IAX_GENPOLIZA objeto con datos de consulta de la póliza
   NULL si error;

   ***********************************************************************/
   FUNCTION f_get_datpoliza(psseguro IN NUMBER,
                            mensajes OUT t_iax_mensajes,
                            pmode    IN VARCHAR2 DEFAULT NULL)
      RETURN ob_iax_genpoliza;

   /***********************************************************************
   Recupera los recibos de la póliza
   param out mensajes : mensajes de error
   return             : objeto detalle de la poliza
   ***********************************************************************/
   FUNCTION f_get_recibos(mensajes OUT t_iax_mensajes) RETURN t_iax_detrecibo;

   /***********************************************************************
   Recupera los movimientos de la póliza
   param out mensajes : mensajes de error
   return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_mvtpoliza(mensajes OUT t_iax_mensajes) RETURN SYS_REFCURSOR;

   /***********************************************************************
   Cobro de un recibo
   param in pctipcob  : tipo cobro VF 552
   param in pnrecibo  : número de recibo
   param in pcbancar  : cuenta bancaria
   param in pctipban  : tipo cuenta bancaria
   param out mensajes : mensajes de error
   return             : O todo correcto
   1 ha habido un error
   ***********************************************************************/
   FUNCTION f_set_cobrorec(psseguro IN NUMBER,
                           pnmovimi IN NUMBER,
                           pctipcob IN NUMBER,
                           pctipban IN NUMBER,
                           pcbancar IN VARCHAR2,
                           mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   Recupera el riesgo indicado para la consulta
   param in nriesgo   : número de riesgo
   param out mensajes : mensajes de error
   return             : objeto riesgo
   *************************************************************************/
   FUNCTION f_get_riesgoconsulta(nriesgo  IN NUMBER,
                                 mensajes OUT t_iax_mensajes)
      RETURN ob_iax_riesgos;

   /*************************************************************************
   Lee los datos de la póliza (preguntas) para la consulta
   param out mensajes : mensajes de error
   return             : objeto preguntas
   *************************************************************************/
   FUNCTION f_get_pregunpolizaconsulta(mensajes OUT t_iax_mensajes)
      RETURN t_iax_preguntas;

   /*************************************************************************
   Recupera las clausulas que el usuario a seleccionado o bien automaticas
   a nivel de producto par la consulta
   param out mensajes : mensajes de error
   return             : 0 todo correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_get_clausulasprodconsulta(mensajes OUT t_iax_mensajes)
      RETURN t_iax_clausulas;

   /*************************************************************************
   Recuperar información de las garantias
   param in pnriesgo  : número de riesgo
   param in pcgarant  : código garantia
   param out mensajes : mensajes de error
   return             : objeto garantias
   *************************************************************************/
   FUNCTION f_get_detallegarantia(pnriesgo IN NUMBER,
                                  pcgarant IN NUMBER,
                                  pndetgar IN NUMBER,
                                  mensajes OUT t_iax_mensajes)
      RETURN ob_iax_garantias;

   /*************************************************************************
   Recuperar información de mas datos las garantias (detalle de garantías)
   param in pnriesgo  : número de riesgo
   param in pcgarant  : código garantia
   param out mensajes : mensajes de error
   return             : objeto garantias
   *************************************************************************/
   -- Bug 10101 - RSC - 28/07/2009 - Detalle de garantías (Consulta de póliza)
   FUNCTION f_get_masdatosdetgarantia(pnriesgo IN NUMBER,
                                      pcgarant IN NUMBER,
                                      pndetgar IN NUMBER,
                                      mensajes OUT t_iax_mensajes)
      RETURN ob_iax_masdatosgar;

   /*************************************************************************
   Recuperar información de el riesgo asegurado
   param in pnriesgo  : número de riesgo
   param out mensajes : mensajes de error
   return             : objeto garantias
   *************************************************************************/
   FUNCTION f_get_detalleriesgoaseg(pnriesgo IN NUMBER,
                                    mensajes OUT t_iax_mensajes)
      RETURN t_iax_asegurados;

   /************************************************************************
   FI CONSULTA
   ************************************************************************/
   /************************************************************************
   RETENCIÓN PÓLIZAS
   ************************************************************************/
   /*************************************************************************
   Llena el objeto retención polizas con la información de las retenidas
   param in psproduc  : código de producto
   param in pnpoliza  : número de póliza
   param in pnsolici  : número de solicitud
   param in pncertif  : número de certificado
   param in pnnumide  : número de identificación persona
   param in psnip     : identificador externo de persona DEFAULT NULL
   param in pnombre   : texto a buscar como tomador
   param in pcsituac  : situación de la póliza
   param out mensajes : mensajes de error
   return             : objeto poliza retenidas
   *************************************************************************/
   FUNCTION f_get_polizasreten(pcagente     IN NUMBER,
                               pcramo       IN NUMBER,
                               psproduc     IN NUMBER,
                               pnpoliza     IN NUMBER,
                               pnsolici     IN NUMBER,
                               pncertif     IN NUMBER DEFAULT -1,
                               pnnumide     IN VARCHAR2,
                               psnip        IN VARCHAR2 DEFAULT NULL,
                               pnombre      IN VARCHAR2,
                               pcsituac     IN NUMBER,
                               pcmatric     IN VARCHAR2, --BUG19605:LCF:19/02/2010
                               pcpostal     IN VARCHAR2, --BUG19605:LCF:19/02/2010
                               ptdomici     IN VARCHAR2, --BUG19605:LCF:19/02/2010
                               ptnatrie     IN VARCHAR2, --BUG19605:LCF:19/02/2010
                               p_filtroprod IN VARCHAR2,
                               mensajes     OUT t_iax_mensajes,
                               pcsucursal   IN NUMBER DEFAULT NULL, -- Bug 22839/126886 - 29/10/2012 - AMC
                               pcadm        IN NUMBER DEFAULT NULL, -- Bug 22839/126886 - 29/10/2012 - AMC)
                               pcmotor      IN VARCHAR2 DEFAULT NULL, -- Bug 25177/133016 - 28/12/2012 - AMC
                               pcchasis     IN VARCHAR2 DEFAULT NULL, -- Bug 25177/133016 - 28/12/2012 - AMC
                               pnbastid     IN VARCHAR2 DEFAULT NULL, -- Bug 25177/133016 - 28/12/2012 - AMC
                               pcpolcia     IN VARCHAR2 DEFAULT NULL, -- Bug 0029965 - 14/04/2014 - FAL
                               pfretend     IN DATE DEFAULT NULL, -- Bug 0029965 - 14/04/2014 - FAL
                               pfretenh     IN DATE DEFAULT NULL, -- Bug 0029965 - 14/04/2014 - FAL
                               pcactivi     IN NUMBER DEFAULT NULL,    -- CJMR 19/03/2019 IAXIS-3194
                               pnnumidease  IN VARCHAR2 DEFAULT NULL,  -- CJMR 19/03/2019 IAXIS-3194
                               pnombrease   IN VARCHAR2 DEFAULT NULL)  -- CJMR 19/03/2019 IAXIS-3194

    RETURN t_iax_polizasreten;

   /*************************************************************************
   Llena el objeto motivos de retención de polizas con la información
   de la póliza seleccionada
   param in psseguro  : código de póliza
   param out mensajes : mensajes de error
   return             : objeto motivos retención póliza
   *************************************************************************/
   FUNCTION f_get_polmvtreten(psseguro IN NUMBER,
                              mensajes OUT t_iax_mensajes)
      RETURN t_iax_polmvtreten;

   /*************************************************************************
   Llena el objeto el o los motivos de retención de polizas con la información
   de la póliza seleccionada y movimiento. Si el movimiento es informado con un NULO, retorna
   todos los motivos de retención de la póliza.
   param in psseguro  : código de póliza
   param in pnmovimi  : número del movimiento de la póliza
   param out mensajes : mensajes de error
   return             : objeto motivos retención póliza
   *************************************************************************/
   FUNCTION f_get_motretenmov(psseguro IN NUMBER,
                              pnmovimi IN NUMBER,
                              mensajes OUT t_iax_mensajes)
      RETURN t_iax_polmvtreten;

   /*************************************************************************
   Valida si se puede anular una propuesta de póliza retenida
   param in psseguro  : código de póliza
   param out mensajes : mensajes de error
   return             : 0 -> No se puede anular la propuesta
   1 -> Si se permite anular la propuesta
   *************************************************************************/
   FUNCTION f_permite_anularpropuesta(psseguro IN NUMBER,
                                      pnmovimi IN NUMBER, -- BUG10464:DRA:16/06/2009
                                      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Rechaza la propuesta de póliza retenida
   param in psseguro  : código de póliza
   param in pnsuplem  : Contador del número de suplementos
   param in pcmotmov  : código motivo de movimiento
   param in ptobserva : observaciones
   param out mensajes : mensajes de error
   return             : 0 todo correcto
   1 ha habido errores
   *************************************************************************/
   FUNCTION f_anularpropuesta(psseguro  IN NUMBER,
                              pnsuplem  IN NUMBER,
                              pcmotmov  IN NUMBER,
                              ptobserva IN VARCHAR2,
                              mensajes  OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   Devuelve la fecha de aceptación de la póliza retenida
   return  : fecha aceptación
   *************************************************************************/
   FUNCTION f_get_fechaceptar RETURN DATE;

   /*************************************************************************
   Emitir la propuesta de póliza retenida
   param in psseguro  : código de póliza
   param in pnmovimi  : número de movimiento
   param in  pfefecto : fecha de efecto en que se emite la propuesta
   param out onpoliza : número de pòlissa assignat a la proposta emessa
   param out mensajes : mensajes de error
   return             : 0 todo correcto
   1 ha habido errores
   *************************************************************************/
   FUNCTION f_emitirpropuesta(psseguro IN NUMBER,
                              pnmovimi IN NUMBER,
                              onpoliza OUT NUMBER,
                              mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /*
   /*************************************************************************
   Emitir la propuesta de póliza retenida
   param in  psseguro : código de póliza
   param in  pnmovimi : número de movimiento
   param out mensajes : mensajes de error
   return             : 0 todo correcto
   1 ha habido errores
   *************************************************************************
   FUNCTION F_EmitirPropuesta(psseguro IN  NUMBER,
   pnmovimi IN  NUMBER,
   pfefecto IN  DATE,
   mensajes OUT T_IAX_MENSAJES) RETURN NUMBER;

   */
   /*************************************************************************
   Editar la propuesta de póliza retenida y aceptada
   param in  psseguro : código de póliza
   param out mensajes : mensajes de error
   return             : 0 todo correcto
   1 ha habido errores
   *************************************************************************/
   FUNCTION f_editarpropuesta(psseguro IN NUMBER,
                              osseguro OUT NUMBER, -- BUG11288:DRA:21/06/2010
                              onmovimi OUT NUMBER, -- BUG11288:DRA:21/06/2010
                              mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   Editar la propuesta de póliza retenida no aceptada todavía
   param in  psseguro : código de póliza
   param out mensajes : mensajes de error
   return             : 0 todo correcto
   1 ha habido errores
   *************************************************************************/
   FUNCTION f_editarpropuestaretenida(psseguro IN NUMBER,
                                      osseguro OUT NUMBER, -- BUG11288:DRA:21/06/2010
                                      onmovimi OUT NUMBER, -- BUG11288:DRA:21/06/2010
                                      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /************************************************************************
   FI RETENCIÓN PÓLIZAS
   ************************************************************************/
   /************************************************************************
   INICI DOCUMENTACIÓN NECESARIA
   ************************************************************************/
   /*************************************************************************
   Recupera la documentación necesaria adjuntada para la póliza en el
   movimiento de alta.
   param out mensajes       : mensajes de error
   return    T_IAX_DOCUMNEC : Documentación necesaria ya adjuntada para la póliza.
   *************************************************************************/
   FUNCTION f_leedocumalta(mensajes OUT t_iax_mensajes) RETURN t_iax_documnec;

   /*************************************************************************
   Grabar información de la documentación necessaria.
   param in  pcdocument     : código del documento.
   param in  pnversion      : número de la versión del documento.
   param in  pcmotomov      : código del tipo de movimiento de póliza.
   param in  pcselec        : indicador de selección (1) o deselección (0) de la documentación
   param out mensajes       : mensajes de error
   return    NUMBER         : 0    -> Grabación realizada correctamente.
   : <> 0 -> Error grabando
   *************************************************************************/
   FUNCTION f_grabadocummov(pcdocument IN NUMBER,
                            pnversion  IN NUMBER,
                            pcmotmov   IN NUMBER,
                            pcselec    IN NUMBER,
                            mensajes   OUT t_iax_mensajes) RETURN NUMBER;

   /************************************************************************
   FI DOCUMENTACIÓN NECESARIA
   ************************************************************************/
   --JRH 03/2008
   /*************************************************************************
   Lee los datos del riesgo (rentas irregulares)
   param out mensajes : mensajes de error
   return             : objeto preguntas
   *************************************************************************/
   FUNCTION f_leerentasirregulares(nriesgo  IN NUMBER,
                                   mensajes OUT t_iax_mensajes)
      RETURN t_iax_rentairr;

   /*************************************************************************
   Grabar información de un registro de renta irregular
   param in nriesgo   : número de riesgo
   param in anyo    : año
   iy los importes de cada mes
   param out mensajes : mensajes de error
   return             : 0 todo correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_grabarrentairregular(nriesgo  IN NUMBER,
                                   anyo     IN NUMBER,
                                   pmes1    IN NUMBER,
                                   pmes2    IN NUMBER,
                                   pmes3    IN NUMBER,
                                   pmes4    IN NUMBER,
                                   pmes5    IN NUMBER,
                                   pmes6    IN NUMBER,
                                   pmes7    IN NUMBER,
                                   pmes8    IN NUMBER,
                                   pmes9    IN NUMBER,
                                   pmes10   IN NUMBER,
                                   pmes11   IN NUMBER,
                                   pmes12   IN NUMBER,
                                   mensajes OUT t_iax_mensajes) RETURN NUMBER;

   --JRH 03/2008
   /*************************************************************************
   Incializa a null las rentas irregulares de un riesgo
   param out mensajes : mensajes de error
   return             : 0 todo correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_inicrentasirregulares(nriesgo  IN NUMBER,
                                    mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   JRH 07/2008
   Nos indica si hay garantía con revalorizción diferente que la de la póliza
   param in psseguro  : Póliza
   param in pnriesgo    : número de riesgo
   param out mensajes : mensajes de error
   return             : 0 = Si las garantías tienen igual revalorización
   1 = Si alguna garantía tiene diferente revalorización
   *************************************************************************/
   FUNCTION f_gar_reval_dif(psseguro IN NUMBER,
                            pnriesgo IN NUMBER,
                            mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   LPS 07/2008
   Nos devuelve la fecha de vencimiento, a partir del nduraci y la fefecto.
   param in pfefecto : Fecha de efecto
   param in pnduraci: duaracion
   param out vfvencim : fecha de vencimiento
   param out mensajes : mensajes de error
   return             : 0 = Si todo correcto
   cod_err = Si ha habido algún error.
   *************************************************************************/
   FUNCTION f_set_nduraci(pfefecto IN DATE,
                          pnduraci IN NUMBER,
                          pcduraci IN NUMBER, -- Bug 19412 - RSC - 26/10/2011
                          vfvencim OUT DATE,
                          pndurcob OUT NUMBER -- Mantis 7919.#6.
                         ,
                          mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   Devuelve el número de riesgos que hay en la colección de riesgos.
   param in out     : mensajes de error
   return NUMBER, número de riesgos
   *************************************************************************/
   FUNCTION f_existriesgo(mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   Graba un nuevo riesgo o lo modifica en el objeto persistente
   param in pnriesgo  : número de riesgo
   param in ptdomici  : domicilio
   param in pcpostal  : código postal
   param in pcpoblac  : código de población
   param in pcprovin  : código de provincia
   param in pcpais    : código de país
   param in pcsiglas  : tipo de vía
   param in ptnomvia  : descripción vía
   param in pnnumvia  : número vía
   param in ptcomple  : descripción complementaria
   param in pcciudad  : código ciudad para chile
   param in pfgisx    : coordenada gis x (gps)
   param in pfgisy    : coordenada gis y (gps)
   param in pfgisz    : coordenada gis z (gps)
   param in pcvalida  : Código validación dirección. Valor fijo 1006
   param out mensajes : mensajes de error
   return             : 0 todo correcto
   1 ha habido un error
   -- Bug 12668 - 16/02/2010 - AMC - Normalización de la dirección
   -- Bug 20893/111636 - 02/05/2012 - AMC
   *************************************************************************/
   FUNCTION f_grabariedomicilio(pnriesgo     IN NUMBER,
                                ptdomici     IN VARCHAR2,
                                pcpostal     IN VARCHAR2,
                                pcpoblac     IN NUMBER,
                                pcprovin     IN NUMBER,
                                pcpais       IN NUMBER,
                                pcsiglas     IN NUMBER,
                                ptnomvia     IN VARCHAR2,
                                pnnumvia     IN NUMBER,
                                ptcomple     IN VARCHAR2,
                                pcciudad     IN NUMBER,
                                pfgisx       IN FLOAT,
                                pfgisy       IN FLOAT,
                                pfgisz       IN FLOAT,
                                pcvalida     IN NUMBER,
                                piddirrie    IN NUMBER,
                                piddomicis   IN VARCHAR2,
                                pcviavp      IN NUMBER,
                                pclitvp      IN NUMBER,
                                pcbisvp      IN NUMBER,
                                pcorvp       IN NUMBER,
                                pnviaadco    IN NUMBER,
                                pclitco      IN NUMBER,
                                pcorco       IN NUMBER,
                                pnplacaco    IN NUMBER,
                                pcor2co      IN NUMBER,
                                pcdet1ia     IN NUMBER,
                                ptnum1ia     IN VARCHAR2,
                                pcdet2ia     IN NUMBER,
                                ptnum2ia     IN VARCHAR2,
                                pcdet3ia     IN NUMBER,
                                ptnum3ia     IN VARCHAR2,
                                piddomici    IN NUMBER,
                                plocalidad   IN VARCHAR2,
                                pfdefecto    IN NUMBER,
                                pdescripcion IN VARCHAR2,
                                mensajes     OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   Graba un nuevo riesgo o lo modifica en el objeto persistente
   param in pnriesgo       : número de riesgo
   param in ptdescripcion  : descripción del riesgo
   param in pnasegur       : número de asegurados
   param in pnedadcol      : Edad de un riesgo de un colectivo inominado
   param in psexcol        : Sexo de un riesgo de un colectivo inominado
   param out mensajes      : mensajes de error
   return                  : 0 todo correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_grabariedescripcion(pnriesgo      IN NUMBER,
                                  ptdescripcion IN VARCHAR2,
                                  pnasegur      IN VARCHAR2,
                                  pnedadcol     IN NUMBER,
                                  psexcol       IN NUMBER,
                                  mensajes      OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Devuelve la colección de riesgos que tiene la póliza
   param out mensajes : mensajes de error
   return             : colección de riesgos
   *************************************************************************/
   FUNCTION f_leeriesgos(mensajes OUT t_iax_mensajes) RETURN t_iax_riesgos;

   -- JLTS
   /*************************************************************************
      Devuelve la colección de riesgos que tiene la póliza
      param out mensajes : mensajes de error
      return             : colección de agensegu
   *************************************************************************/

   FUNCTION f_leeagensegu(mensajes OUT t_iax_mensajes) RETURN t_iax_agensegu;
   -- JLTS

   --CONF-274-25/11/2016-JLTS Ini
   /*************************************************************************
      FUNCTION f_set_reinicio
      param in pscontgar : Contragarantías
      param in pcactivo  : Activo
      param in mensajes  : t_iax_mensajes
      return             : NUMBER
   *************************************************************************/
   FUNCTION f_set_reinicio(psseguro NUMBER,
                           pfinicio DATE,
                           pffinal  DATE,
                           pttexto  VARCHAR2,
                           pcmotmov NUMBER,
                           pnmovimi NUMBER,
                           mensajes OUT t_iax_mensajes) RETURN NUMBER;
   --CONF-274-25/11/2016-JLTS Fin
   /*************************************************************************
   Realiza la llamada a la capa MD para el cobro de los recibos de un seguro
   param out mensajes : mensajes de error
   return             : number   0 -> OK  1 --> Error
   *************************************************************************/
   FUNCTION f_cobro_recibos(psolicit IN NUMBER,
                            pnmovimi IN NUMBER,
                            pctipcob IN NUMBER,
                            pctipban IN NUMBER,
                            pcbancar IN VARCHAR2,
                            mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   Devuelve si debemos mostrar una pantalla para volver a recobrar un seguro
   param out mensajes : mensajes de error
   return             : number   0 -> OK  1 --> Error
   *************************************************************************/
   FUNCTION f_cobro_retenido(psolicit IN NUMBER,
                             pnmovimi IN NUMBER,
                             mensajes IN OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   Recupera las cuentas corrientes de un tomador concreto del seguro
   param out mensajes : mensajes de error
   sperson  : sperson real
   return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_ccc_seguro(psseguro IN NUMBER,
                             pnordtom IN NUMBER,
                             psperson OUT NUMBER,
                             mensajes OUT t_iax_mensajes) RETURN SYS_REFCURSOR;

   /***********************************************************************
   Devuelve el valor de la revalorización de una póliza.
   param in ptablas   : Tablas ('EST' - temporales, 'SEG' - reales, 'SOL' - solicitudes)
   param in psseguro  : Número interno de seguro
   param out prevali  : Porcentaje o valor de revalorización
   param out pcrevali : Tipo de revalorización
   mensajes : mensajes de error
   return             : number
   ***********************************************************************/
   FUNCTION f_get_reval_poliza(ptablas  IN VARCHAR2 DEFAULT 'SEG',
                               psseguro IN NUMBER,
                               prevali  OUT NUMBER,
                               pcrevali OUT NUMBER,
                               mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /***********************************************************************
   Devuelve un objeto con los datos de gestión de una póliza.
   param in psseguro  : Número interno de seguro
   param in ptablas   : Tablas ('EST' - temporales, 'SEG' - reales, 'SOL' - solicitudes)
   param out mensajes : mensajes de error
   return             : ob_iax_poliza
   ***********************************************************************/
   FUNCTION f_get_datos_cobro(psseguro IN NUMBER,
                              mensajes OUT t_iax_mensajes)
      RETURN ob_iax_gestion;

   /*************************************************************************
   Devuelve los meses que tienen paga extraordinaria
   param in : numero de seguro
   param out mensajes : mensajes de error
   return             : objeto nmesextra
   *************************************************************************/
   FUNCTION f_get_mesesextra(psseguro   IN NUMBER,
                             pcmodextra OUT NUMBER,
                             mensajes   OUT t_iax_mensajes)
      RETURN ob_iax_nmesextra;

   /*************************************************************************
   Funcion que crea un objeto ob_iax_nmesextra y lo asigna a la poliza del contexto
   param in : los 12 meses del año
   param out mensajes : mensajes de error
   return             : 0 ok
   <> 0 ko
   *************************************************************************/
   FUNCTION f_set_nmesextra(pnmes1   IN NUMBER,
                            pnmes2   IN NUMBER,
                            pnmes3   IN NUMBER,
                            pnmes4   IN NUMBER,
                            pnmes5   IN NUMBER,
                            pnmes6   IN NUMBER,
                            pnmes7   IN NUMBER,
                            pnmes8   IN NUMBER,
                            pnmes9   IN NUMBER,
                            pnmes10  IN NUMBER,
                            pnmes11  IN NUMBER,
                            pnmes12  IN NUMBER,
                            mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   Funció que crea un objecte ob_iax_nmesextra i l' assigna a la pòlissa del contexte
   param in : els 12 mesos de l'any
   param out mensajes : missatges d'error
   return             : 0 ok
   <> 0 ko
   *************************************************************************/
   -- 24735.NMM.
   FUNCTION f_set_imesextra(pimes1   IN NUMBER,
                            pimes2   IN NUMBER,
                            pimes3   IN NUMBER,
                            pimes4   IN NUMBER,
                            pimes5   IN NUMBER,
                            pimes6   IN NUMBER,
                            pimes7   IN NUMBER,
                            pimes8   IN NUMBER,
                            pimes9   IN NUMBER,
                            pimes10  IN NUMBER,
                            pimes11  IN NUMBER,
                            pimes12  IN NUMBER,
                            mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /***********************************************************************
   Función que indica si para un producto se debe mostrar la lista de pólizas con certificado cero
   param in psproduc  : código de producto
   param out mensajes : mensajes de error
   return             : number  0 -> No mostrar  1 --> Sí mostrar
   ***********************************************************************/
   FUNCTION f_mostrar_certificadoscero(psproduc IN NUMBER,
                                       mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Recupera las pólizas de colectivos con certificado cero para el producto indicado
   param in psproduc  : código de producto
   param in pnpoliza  : num. poliza
   param in pbuscar  : texto a buscar por nombre de tomador
   param out mensajes : mensajes de error
   return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_certificadoscero(psproduc   IN NUMBER,
                                   pnpoliza   IN NUMBER, --BUG11008-01092009-XPL
                                   pnsolici   IN NUMBER, -- Bug 34409/196980 - 16/04/2015 - POS
                                   pbuscar    IN VARCHAR2, --BUG11008-01092009-XPL
                                   pcintermed IN NUMBER, --BUG22839/125740:DCT:21/10/2012
                                   pcsucursal IN NUMBER, --BUG22839/125740:DCT:21/10/2012
                                   pcadm      IN NUMBER, --BUG22839/125740:DCT:21/10/2012
                                   pmodo      IN VARCHAR2, -- Bug 30360/174025 - 09/05/2014 - AMC
                                   mensajes   OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR;

   /***********************************************************************
   Función que asigna el número de póliza del tomador del colectivo, al certificado que se crea nuevo,
   modificando una de las variables del tipo persistente de la contratación.
   param in pnpoliza  : número de póliza
   param out mensajes : mensajes de error
   return             : number  0 -> Ok  1 --> Error
   ***********************************************************************/
   FUNCTION f_set_npoliza(pnpoliza IN NUMBER,
                          mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   Obtiene datos gestion del certificado 0
   param out mensajes : mensajes de error
   return             : objeto datos gestion
   *************************************************************************/
   FUNCTION f_get_datosgestion(mensajes OUT t_iax_mensajes)
      RETURN ob_iax_detpoliza;
  -- INI BUG CONF-1337_QT_1998- 04/04/2018 - Grabar datos de fechas
   /*************************************************************************
     Función que ajusta los datos de fechas de la póliza (garantía)
      param in psseguro      : código del seguro
      param in out mensajes  : colección de mensajes
      return                 : 0 todo ha ido bien
                               1 se ha producido un error
   *************************************************************************/
   FUNCTION f_actualiza_fechas(psseguro IN SEGUROS.SSEGURO%TYPE,
                               pfefecto IN DATE,
                               pfiniefe IN DATE,
                               pfvencim IN DATE,
                               pfefeplazo IN DATE,
                               pfvencplazo IN DATE,
							   pcmotmov    IN NUMBER,  -- IAXIS-3396 CJMR 09/04/2019
							   pndias      IN NUMBER DEFAULT NULL,   -- IAXIS-3394 CJMR 22/04/2019
							   pnmeses     IN NUMBER DEFAULT NULL,   -- IAXIS-3394 CJMR 22/04/2019
							   pnanios     IN NUMBER DEFAULT NULL) RETURN NUMBER;   -- IAXIS-3394 CJMR 22/04/2019
  -- FIN BUG CONF-1337_QT_1998- 04/04/2018

   FUNCTION f_admitecertificados(mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   Recupera la información de un modelo de inversión seleccionado
   param in pnmodelo  : número de modelo de inversión
   param out mensajes : mensajes de error
   return             : type T_IAX_DISTRIBUCION
   *************************************************************************/
   FUNCTION f_leemodeloinversionfinv(pnmodelo IN NUMBER,
                                     mensajes OUT t_iax_mensajes)
      RETURN ob_iax_produlkmodelosinv;

   /*************************************************************************
   Devuelve la colección de SALDOS DEUTORS DEL RIESGO DE LA POLIZA PASADO POR PARAM.
   param in  pnriesgo : riesgo
   param out mensajes : mensajes de error
   return             : colección de saldo deutors
   *************************************************************************/
   -- Bug 11165 - 16/09/2009 - AMC - Se sustituñe  T_iax_saldodeutorseg por t_iax_prestamoseg
   FUNCTION f_leedatosprestamoseg(pnriesgo IN NUMBER,
                                  mensajes OUT t_iax_mensajes)
      RETURN t_iax_prestamoseg;

   /*************************************************************************
   Graba en el objeto el saldo deutor
   pnriesgo IN NUMBER,
   selsaldo IN NUMBER,
   pidcuenta IN VARCHAR2,
   pctipcuenta IN NUMBER,
   pttipcuenta IN VARCHAR2,
   pctipban IN NUMBER,
   pttipban IN VARCHAR2,
   pctipimp IN NUMBER,
   pttipimp IN VARCHAR2,
   pisaldo IN NUMBER,
   pporcen IN NUMBER,
   pilimite IN NUMBER,
   picapmax IN NUMBER,
   param out mensajes : mensajes de error
   return             : colección de saldo deutors
   *************************************************************************/
   -- Bug 11165 - 16/09/2009 - AMC - Se sustituñe  T_iax_saldodeutorseg por t_iax_prestamoseg
   FUNCTION f_set_prestamoseg(pnriesgo     IN NUMBER,
                              selsaldo     IN NUMBER,
                              pidcuenta    IN VARCHAR2,
                              pctipcuenta  IN NUMBER,
                              pctipban     IN NUMBER,
                              pctipimp     IN NUMBER,
                              pisaldo      IN NUMBER,
                              pporcen      IN NUMBER,
                              pilimite     IN NUMBER,
                              picapmax     IN NUMBER,
                              pcmoneda     IN VARCHAR2,
                              picapmaxpol  IN NUMBER,
                              picapase     IN NUMBER,
                              pdescripcion IN VARCHAR2,
                              pfiniprest   IN DATE,
                              pffinprest   IN DATE,
                              mensajes     OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   Calcula el Capital asegurado
   pctipimp IN NUMBER,
   pisaldo IN NUMBER,
   pporcen IN NUMBER,
   pilimite IN NUMBER,
   picapmax IN NUMBER,
   param out mensajes : mensajes de error
   return             : colección de saldo deutors
   *************************************************************************/
   FUNCTION f_calcula_capase(pctipimp IN NUMBER,
                             pisaldo  IN NUMBER,
                             pporcen  IN NUMBER,
                             pilimite IN NUMBER,
                             picapmax IN NUMBER,
                             picapase OUT NUMBER,
                             mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   Obtiene det poliza
   param out mensajes : mensajes de error
   return             : objeto datos gestion
   *************************************************************************/
   FUNCTION f_get_detpoliza(mensajes OUT t_iax_mensajes)
      RETURN ob_iax_detpoliza;

   /*************************************************************************
   Prepara el objeto de saldodeutor si venimos de simulación
   param out mensajes : mensajes de error
   return             : objeto datos gestion
   *************************************************************************/
   -- Bug 11165 - 16/09/2009 - AMC - Se sustituñe  T_iax_saldodeutorseg por t_iax_prestamoseg
   FUNCTION f_simul_prestamoseg(mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   Recuperar información de las garantias
   param in nriesgo  : número de riesgo
   param in pmodalidad  : Modalidad de la función (Alta / Modificación / Baja)
   param out mensajes : mensajes de error
   return             : objeto garantias
   *************************************************************************/
   FUNCTION f_leegarantias_alt(pnriesgo   IN NUMBER,
                               pmodalidad IN NUMBER,
                               pcmodo     IN VARCHAR2,
                               mensajes   OUT t_iax_mensajes)
      RETURN t_iax_garantias;

   /*************************************************************************
   Actualitzar les primes manualts iprianu,ipritot i ipritar
   param in  nriesgo
   param in  cgarant
   param in  ipritar
   param in  ipritot
   param out mensajes  : mensajes de error
   return              : 0 todo correcto
   1 ha habido un error
   --30/07/2010#XPL#14429: AGA005 - Primes manuals pels productes de Llar
   *************************************************************************/
   FUNCTION f_actualitzarcapitales(nriesgo  IN NUMBER,
                                   cgarant  IN NUMBER,
                                   ipritar  IN NUMBER,
                                   ipritot  IN NUMBER,
                                   mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   Actualitzar el camp ctarman
   param in  nriesgo
   param in  cgarant
   param in  ctarman
   param out mensajes  : mensajes de error
   return              : 0 todo correcto
   1 ha habido un error
   --30/07/2010#XPL#14429: AGA005 - Primes manuals pels productes de Llar
   *************************************************************************/
   FUNCTION f_actualitzarctarman(nriesgo  IN NUMBER,
                                 cgarant  IN NUMBER,
                                 ctarman  IN NUMBER,
                                 mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   Recupera la direccion del tomador
   param out  psitriesgo
   param out mensajes  : mensajes de error
   return              : 0 todo correcto
   1 ha habido un error
   Bug 14443 - 12/05/2010 - AMC
   *************************************************************************/
   FUNCTION f_get_domicili_prenedor(psitriesgo OUT ob_iax_sitriesgos,
                                    mensajes   OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Grabar información de las garantias
   param in nriesgo   : número de riesgo
   param in cgarant   : código garantia
   param in selgar    : 1 indica que se ha seleccionado garantia
   0 indica que se ha deseleccionado la garantia
   param in icapital  : importe de capital
   param in crevali   : tipo de revalorización
   param in prevali   : porcentaje de revalorización
   param in irevali   : importe de revalorización
   param out mensajes : mensajes de error
   return             : 0 todo correcto
   1 ha habido un error
   *************************************************************************/
   -- Bug 13832 - 17/06/2010 - RSC - APRS015 - suplemento de aportaciones únicas
   FUNCTION f_grabardetgarantias(nriesgo  IN NUMBER,
                                 cgarant  IN NUMBER,
                                 selgar   IN NUMBER,
                                 icapital IN NUMBER,
                                 crevali  IN NUMBER,
                                 prevali  IN NUMBER,
                                 irevali  IN NUMBER,
                                 mensajes OUT t_iax_mensajes,
                                 ipritar  IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   -- FIn Bug 13832
   FUNCTION f_set_desglosegar(psseguro      IN NUMBER,
                              pcgarant      IN NUMBER,
                              pnriesgo      IN NUMBER,
                              pnmovimi      IN NUMBER,
                              pnorden       IN NUMBER,
                              pcconcepto    IN NUMBER,
                              ptdescripcion IN VARCHAR2,
                              picapital     IN NUMBER,
                              pnseq_out     OUT NUMBER,
                              mensajes      OUT t_iax_mensajes) RETURN NUMBER;

   FUNCTION f_get_garantias_bd(pnriesgo IN NUMBER,
                               mensajes OUT t_iax_mensajes) RETURN NUMBER;

   FUNCTION f_del_desglosegar(psseguro IN NUMBER,
                              pcgarant IN NUMBER,
                              pnriesgo IN NUMBER,
                              pnmovimi IN NUMBER,
                              pnorden  IN NUMBER,
                              mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   Lee datos reglaseseg
   param out mensajes : mensajes de error
   return             : objeto datos gestion
   *************************************************************************/
   -- Bug 16106 - RSC - 23/09/2010 - APR - Ajustes e implementación para el alta de colectivos
   FUNCTION f_leedatosreglasseg(mensajes OUT t_iax_mensajes)
      RETURN ob_iax_reglasseg;

   /*************************************************************************
   Lee datos gestion
   param out mensajes : mensajes de error
   return             : objeto datos gestion
   *************************************************************************/
   FUNCTION f_leedatosreglassegtramos(mensajes OUT t_iax_mensajes)
      RETURN t_iax_reglassegtramos;

   /*************************************************************************
   Grabar datos reglasseg
   return             : 0 todo correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_grabardatosreglasseg(pcapmaxemp IN NUMBER,
                                   pcapminemp IN NUMBER,
                                   pcapmaxtra IN NUMBER,
                                   pcapmintra IN NUMBER,
                                   mensajes   OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Grabar datos reglassegtramos
   return             : 0 todo correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_grabardatosreglassegtramos(pnumbloq IN NUMBER,
                                         pedadini IN NUMBER,
                                         pedadfin IN NUMBER,
                                         pt1emp   IN NUMBER,
                                         pt1trab  IN NUMBER,
                                         pt2emp   IN NUMBER,
                                         pt2trab  IN NUMBER,
                                         pt3emp   IN NUMBER,
                                         pt3trab  IN NUMBER,
                                         pt4emp   IN NUMBER,
                                         pt4trab  IN NUMBER,
                                         mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Alta datos reglassegtramos
   return             : 0 todo correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_altareglassegtramos(pnumbloq IN NUMBER,
                                  mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   Alta datos reglasseg
   return             : 0 todo correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_altareglasseg(pnriesgo IN NUMBER,
                            pcgarant IN NUMBER,
                            mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   Graba capitales ob_iax_reglasseg
   return             : 0 todo correcto
   1 ha habido un error
   *************************************************************************
   FUNCTION f_grabasigtramos(
   pcapmaxemp IN NUMBER,
   pcapminemp IN NUMBER,
   pcapmaxtra IN NUMBER,
   pcapmintra IN NUMBER,
   mensajes OUT t_iax_mensajes)
   RETURN NUMBER;

   */
   -- Fin Bug 16106
   /*************************************************************************
   Recupera la forma de pagament de la prestación selecionada
   param out mensajes : mensajes de error
   return             : forma de pagament o nulo si ha habido errores
   *************************************************************************/
   FUNCTION f_get_fprestaseg(mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /***********************************************************************
   Función que nos marcará si estamos en el alta de un colectivo o no
   param out mensajes : mensajes de error
   return             : number  0 -> Ok  1 --> Error
   ***********************************************************************/
   FUNCTION f_set_isaltacolect(mensajes OUT t_iax_mensajes) RETURN NUMBER;

   -- INIT BUG 16410 JBN
   /*************************************************************************
   Recupera las clausulas que el usuario a seleccionado o bien automaticas
   a nivel de producto
   param out mensajes : mensajes de error
   return             : 0 todo correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_getclausulaparam(sclagen  IN NUMBER,
                               mensajes OUT t_iax_mensajes)
      RETURN ob_iaxpar_clausulas;

   /*************************************************************************
   Recupera las clausulas que el usuario a seleccionado o bien automaticas
   a nivel de producto
   param out mensajes : mensajes de error
   return             : 0 todo correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_getclausulaparammult(sclagen  IN NUMBER,
                                   pnordcla IN NUMBER,
                                   mensajes OUT t_iax_mensajes)
      RETURN ob_iaxpar_clausulas;

   /*************************************************************************
   Graba los parametros de unaclausulas de producto indicadas por el usuario
   param in  sclagen  : código clausula producto generica
   param in  selclau  : 1 indica que se ha seleccionado clausula
   0 indica que se ha deseleccionado la clausula
   param out mensajes : mensajes de error
   return             : 0 todo correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_grabaclausula(sclagen  IN NUMBER,
                            nparame  IN NUMBER,
                            tclagen  IN VARCHAR2,
                            mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   Graba los parametros de una clausulas de producto indicadas por el usuario
   param in  sclagen  : codigo clausula producto generica
   param in  selclau  : 1 indica que se ha seleccionado clausula
   0 indica que se ha deseleccionado la clausula
   param out mensajes : mensajes de error
   return             : 0 todo correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_grabaclausulamult(sclagen  IN NUMBER,
                                nordcla  IN NUMBER,
                                nparame  IN NUMBER,
                                tclagen  IN VARCHAR2,
                                mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   Recupera una clausulas que el usuario a seleccionado o bien automaticas
   a nivel de producto
   param in  psclagen:   Código de la clausula
   param out mensajes : mensajes de error
   return             : 0 todo correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_leeclausulaprod(psclagen IN NUMBER,
                              mensajes OUT t_iax_mensajes)
      RETURN ob_iax_clausulas;

   /*************************************************************************
   Borra una clausula que el usuario a deseleccionado
   param in  psclagen:   Código de la clausula
   param out mensajes : mensajes de error
   return             : 0 todo correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_delclausulaprod(psclagen IN NUMBER,
                              mensajes OUT t_iax_mensajes) RETURN NUMBER;

   -- FIN BUG 16410 JBN
   /*************************************************************************
   Borra una clausula que el usuario a deseleccionado
   param in  psclagen:   Codigo de la clausula
   param out mensajes : mensajes de error
   return             : 0 todo correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_delclausulaprodmult(psclagen IN NUMBER,
                                  pnordcla IN NUMBER,
                                  mensajes OUT t_iax_mensajes) RETURN NUMBER;

   -- Bug 17307 - FAL - 01/02/2011 - CRT003 - Traspaso de genérico a especifico
   /*************************************************************************
   Crea una propuesta de póliza de un producto especifico
   param in  psseguro : código de póliza
   param out mensajes : mensajes de error
   return             : 0 todo correcto
   1 ha habido errores
   *************************************************************************/
   FUNCTION f_crearpropuesta(psseguro    IN NUMBER, -- poliza del generico
                             psproducesp IN NUMBER, -- producto especifico con el q crear la propuesta
                             osseguro    OUT NUMBER, -- poliza del especifico
                             mensajes    OUT t_iax_mensajes) RETURN NUMBER;

   -- Fi Bug 17307
   /*************************************************************************
   FUNCTION f_url_prodexterno
   Obtiene una url
   param in pproducto     : codigo producto
   param in ptipo         : tipo
   param in pidpoliza     : idpoliza
   param in out mensajes  : mensajes de error
   return                 : URL
   *************************************************************************/
   -- Bug 18058 - 28/03/2011 - JTS - Se crea la función
   FUNCTION f_url_prodexterno(pproducto IN NUMBER,
                              ptipo     IN VARCHAR2,
                              pidpoliza IN VARCHAR2,
                              purl      OUT VARCHAR2,
                              mensajes  OUT t_iax_mensajes) RETURN NUMBER;

   -- INI bug 18024 JBN
   FUNCTION f_grabarcomisiones(pctipcom IN NUMBER,
                               mensajes OUT t_iax_mensajes) RETURN NUMBER;

   -- FI bug 18024 JBN
   --BUG 18802 --15/06/2011--ETM--Se crea la funcion
   /*************************************************************************
   FUNCTION  F_SET_NRENOVA
   Obtiene el valor del campo renova
   param in pfefecto     : campo fecha
   param out pnrenova         : devuelve el campo pnrenova
   param out mensajes  : mensajes de error
   return             : 0 todo correcto
   1 ha habido errores
   *************************************************************************/
   FUNCTION f_set_nrenova(pfefecto IN DATE,
                          pnrenova OUT NUMBER,
                          mensajes OUT t_iax_mensajes) RETURN NUMBER;

   --fin bug 18802--ETM
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
   param out mensajes               : mensajes de error
   return                           : 0 todo correcto
   1 ha habido un error
   BUG 18351 - 11/05/2011 - JMP - Se crea la función
   *************************************************************************/
   FUNCTION f_grabardocrequerida(pseqdocu   IN NUMBER,
                                 psproduc   IN NUMBER,
                                 psseguro   IN NUMBER,
                                 pcactivi   IN NUMBER,
                                 pnmovimi   IN NUMBER,
                                 pnriesgo   IN NUMBER,
                                 pninqaval  IN NUMBER,
                                 pcdocume   IN NUMBER,
                                 pctipdoc   IN NUMBER,
                                 pcclase    IN NUMBER,
                                 pnorden    IN NUMBER,
                                 ptdescrip  IN VARCHAR2,
                                 ptfilename IN VARCHAR2,
                                 padjuntado IN NUMBER,
                                 psperson   IN NUMBER,
                                 pctipben   IN NUMBER,
                                 mensajes   OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   F_LEEDOCREQUERIDA
   Devuelve un objeto T_IAX_DOCREQUERIDA con la documentación
   requerida para los parámetros informados.
   param in psproduc                : código de producto
   param in psseguro                : número secuencial de seguro
   param in pcactivi                : código de actividad
   param in pnmovimi                : número de movimiento
   param out mensajes               : mensajes de error
   return                           : el objeto T_IAX_DOCREQUERIDA
   BUG 18351 - 10/05/2011 - JMP - Se crea la función
   *************************************************************************/
   FUNCTION f_leedocrequerida(psproduc IN NUMBER,
                              psseguro IN NUMBER,
                              pcactivi IN NUMBER,
                              pnmovimi IN NUMBER,
                              mensajes OUT t_iax_mensajes)
      RETURN t_iax_docrequerida;

   -- BUG21467:DRA:01/03/2012:Inici
   FUNCTION f_get_datos_host(porigen  IN VARCHAR2 DEFAULT 'ALTA_POLIZA',
                             mensajes OUT t_iax_mensajes) RETURN NUMBER;

   -- BUG21467:DRA:01/03/2012:Fi
   -- BUG19478 Inici
   /*************************************************************************
   Comprova que existeixi el prenador
   param in sperson : codigo de persona
   param in out     : mensajes de error
   return           : 0 no existe
   1 existe
   *************************************************************************/
   FUNCTION f_existtom(sperson  IN NUMBER,
                       mensajes IN OUT t_iax_mensajes) RETURN NUMBER;

   -- BUG19478 Fi
   -- INICIO BUG 19276, JBN, REEMPLAZOS
   /*************************************************************************
   Crea una propuesta de póliza de un producto especifico a partir de una poliza de remplazo
   param in  psseguros : código de  las pólizas separados por , (coma)
   param out mensajes : mensajes de error
   return             : 0 todo correcto
   1 ha habido errores
   *************************************************************************/
   FUNCTION f_crearpropuesta_reemp(psseguros IN VARCHAR2, -- poliza del generico
                                   pmode     IN VARCHAR2,
                                   pproducto NUMBER,
                                   pcagente  NUMBER,
                                   pmodopant IN VARCHAR2 DEFAULT NULL, --Bug.: 18610 - ICV - 20/05/2011
                                   pssolicit OUT NUMBER,
                                   purl      OUT VARCHAR2,
                                   mensajes  OUT t_iax_mensajes) RETURN NUMBER;

   -- FI BUG 19276, JBN, REEMPLAZOS
   -- inif bug 19420
   /*************************************************************************
   Recuperar información de  las personas del riesgo
   param in pnriesgo  : número de riesgo
   param out mensajes : mensajes de error
   return             : objeto garantias
   *************************************************************************/
   FUNCTION f_get_detalleriesgopersonal(pnriesgo IN NUMBER,
                                        mensajes OUT t_iax_mensajes)
      RETURN t_iax_personas;

   /*************************************************************************
   Crea cuadro facultativo
   param in psseguro  : código de póliza
   param in pnmovimi  : movimiento de póliza
   param out mensajes : mensajes de error
   return             : 0 -> No se puede anular la propuesta
   1 -> Si se permite anular la propuesta
   *************************************************************************/
   FUNCTION f_crear_facul(psseguro IN NUMBER,
                          pnmovimi IN NUMBER, -- BUG10464:DRA:16/06/2009
                          mensajes OUT t_iax_mensajes) RETURN NUMBER;

   --Ini Bug.: 19152
   /*************************************************************************
   Función que inicializa el objeto de BENEIDENTIFICADOS riesgo
   param in pnriesgo  : número de riesgo
   param in psperson  : Código de personas
   param out mensajes : mensajes de error
   return             : number
   *************************************************************************/
   FUNCTION f_insert_beneident_r(pnriesgo IN NUMBER,
                                 psperson IN NUMBER,
                                 pnorden  OUT NUMBER,
                                 mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   Función que devuelve el objeto de BENEIDENTIFICADOS riesgo
   param in pnriesgo  : número de riesgo
   param in pnorden  :
   param out mensajes : mensajes de error
   return             : ob_iax_beneidentificados
   *************************************************************************/
   FUNCTION f_get_beneident_r(pnriesgo IN NUMBER,
                              pnorden  IN NUMBER,
                              mensajes OUT t_iax_mensajes)
      RETURN ob_iax_beneidentificados;

   /*************************************************************************
   Función que para actualizar el objeto OB_IAX_BENEIDENTIFICADOS riesgo
   param in pnriesgo  : número de riesgo
   param in pnorden  : orden dentro del objeto
   param in psperson_tit :
   param in pctipben :
   param in pcparen:
   param in ppparticip :
   param out mensajes : mensajes de error
   return             : number
   *************************************************************************/
   FUNCTION f_set_beneident_r(pnriesgo     IN NUMBER,
                              pnorden      IN NUMBER,
                              psperson_tit IN NUMBER,
                              pctipben     IN NUMBER,
                              pcparen      IN NUMBER,
                              ppparticip   IN NUMBER,
                              pcestado     IN NUMBER DEFAULT NULL, -- Bug 24717 - MDS - 20/12/2012 : Añadir campo cestado
                              pctipcon     IN NUMBER, -- Bug 34866/206821 - JAL- 10/06/2015
                              mensajes     OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   Función que elimina un objeto de la colección
   param in pnriesgo  : número de riesgo
   param in pnorden  :
   param out mensajes : mensajes de error
   return             : number
   *************************************************************************/
   FUNCTION f_eliminar_beneident_r(pnriesgo IN NUMBER,
                                   pnorden  IN NUMBER,
                                   mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   Función que inicializa el objeto de OB_iax_benespeciales_gar
   param in pnriesgo  : número de riesgo
   param in pcgarant  : Código de garantía
   param out mensajes : mensajes de error
   return             : number
   *************************************************************************/
   FUNCTION f_insert_benesp_gar(pnriesgo IN NUMBER,
                                pcgarant IN NUMBER,
                                mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   Función que inicializa el objeto de OB_iax_beneidentificados Garantía
   param in pnriesgo  : número de riesgo
   param in pcgarant  : Código de garantía
   param in psperson  : Código de persona
   param out mensajes : mensajes de error
   return             : number
   *************************************************************************/
   FUNCTION f_insert_beneident_g(pnriesgo IN NUMBER,
                                 pcgarant IN NUMBER,
                                 psperson IN NUMBER,
                                 pnorden  OUT NUMBER,
                                 mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   Función que devuelve el objeto de BENEIDENTIFICADOS garantía
   param in pnriesgo  : número de riesgo
   param in pnorden :
   param out mensajes : mensajes de error
   return             : ob_iax_beneidentificados
   *************************************************************************/
   FUNCTION f_get_beneident_g(pnriesgo IN NUMBER,
                              pnorden  IN NUMBER,
                              pcgarant IN NUMBER,
                              mensajes OUT t_iax_mensajes)
      RETURN ob_iax_beneidentificados;

   /*************************************************************************
   Función que para actualizar el objeto OB_IAX_BENEIDENTIFICADOS garantía
   param in pnriesgo  : número de riesgo
   param in pnorden  : orden dentro del objeto
   param in psperson_tit :
   param in pctipben :
   param in pcparen:
   param in ppparticip :
   param in pcgarant
   param out mensajes : mensajes de error
   return             : number
   *************************************************************************/
   FUNCTION f_set_beneident_g(pnriesgo     IN NUMBER,
                              pnorden      IN NUMBER,
                              psperson_tit IN NUMBER,
                              pctipben     IN NUMBER,
                              pcparen      IN NUMBER,
                              ppparticip   IN NUMBER,
                              pcgarant     IN NUMBER,
                              pcestado     IN NUMBER DEFAULT NULL, -- Bug 24717 - MDS - 20/12/2012 : Añadir campo cestado
                              pctipcon     IN NUMBER, -- Bug 34866/206821 - JAL- 10/06/2015
                              mensajes     OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   Función que elimina un objeto de la colección
   param in pnriesgo  : número de riesgo
   param in pnorden  :
   pcgarant IN NUMBER :
   param out mensajes : mensajes de error
   return             : number
   *************************************************************************/
   FUNCTION f_eliminar_beneident_g(pnriesgo IN NUMBER,
                                   pnorden  IN NUMBER,
                                   pcgarant IN NUMBER,
                                   mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   Función que elimina un objeto de la colección
   param in pnriesgo  : número de riesgo
   param in pnorden  :
   pcgarant IN NUMBER :
   param out mensajes : mensajes de error
   return             : number
   *************************************************************************/
   FUNCTION f_eliminar_gar_beneident(pnriesgo IN NUMBER,
                                     pcgarant IN NUMBER,
                                     mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Función que devuelve una colección de T_IAX_BENEIDENTIFICADOS
   param in pnriesgo  : número de riesgo
   param in pcgarant :
   param out mensajes : mensajes de error
   return             : ob_iax_beneidentificados
   *************************************************************************/
   FUNCTION f_get_beneident_tit(pnriesgo IN NUMBER,
                                psperson IN NUMBER,
                                pcgarant IN NUMBER,
                                mensajes OUT t_iax_mensajes)
      RETURN t_iax_beneidentificados;

   /*************************************************************************
   Función que devuelve una lista de garantías seleccionadas para beneficiario
   param in psseguro  : número de seguro
   param out mensajes : mensajes de error
   return             : sys_refcursor
   *************************************************************************/
   FUNCTION f_get_garantias_benidgar(psseguro IN NUMBER,
                                     mensajes OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR;

   /*************************************************************************
   Función que comprueba que la garantía este seleccionada en caso de beneficiario especial por garantía, si no lo está la borra
   param in psseguro  : número de seguro
   param out mensajes : mensajes de error
   return             : number
   *************************************************************************/
   FUNCTION f_comprobar_benidgar(psseguro IN NUMBER,
                                 pnriesgo IN NUMBER,
                                 pcgarant IN NUMBER,
                                 mensajes OUT t_iax_mensajes) RETURN NUMBER;

   -- BUG19069:DRA:27/09/2011:Inici
   -- INI -IAXIS-10627 -21/01/2020
   FUNCTION f_leecorretaje(pnmovimi IN NUMBER DEFAULT NULL,
		                       mensajes OUT t_iax_mensajes) RETURN t_iax_corretaje;
   -- FIN -IAXIS-10627 -21/01/2020

   FUNCTION f_insertcorretaje(pcagente IN NUMBER,
                              pcomisi  IN NUMBER,
                              ppartici IN NUMBER,
                              islider  IN NUMBER,
                              pnordage IN NUMBER,
                              mensajes OUT t_iax_mensajes) RETURN NUMBER;

   FUNCTION f_existcorr(pcagente IN NUMBER,
                        mensajes IN OUT t_iax_mensajes) RETURN NUMBER;

   FUNCTION f_grabacorretaje(pcagente IN NUMBER,
                             pcomisi  IN NUMBER,
                             ppartici IN NUMBER,
                             islider  IN NUMBER,
                             mensajes OUT t_iax_mensajes) RETURN NUMBER;

   FUNCTION f_modifcorretaje(pcagente IN NUMBER,
                             pcomisi  IN NUMBER,
                             ppartici IN NUMBER,
                             islider  IN NUMBER,
                             pnordage IN NUMBER,
                             mensajes OUT t_iax_mensajes) RETURN NUMBER;

   FUNCTION f_eliminacorretaje(pnordage IN NUMBER,
                               mensajes OUT t_iax_mensajes) RETURN NUMBER;

   FUNCTION f_get_corretaje(pcagente IN NUMBER,
                            mensajes OUT t_iax_mensajes)
      RETURN ob_iax_corretaje;

   FUNCTION f_get_direc_corretaje(pcagente IN NUMBER,
                                  ptablas  IN VARCHAR2,
                                  corret   IN OUT ob_iax_corretaje,
                                  mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   -- BUG19069:DRA:27/09/2011:Fi
   -- Ini bug 19303 - JMC - 21/11/2011
   /*************************************************************************
   FUNCTION f_crearpropuesta_sp
   Función que generara una póliza del producto SALDAR o PRORROGAR, tomando
   los datos de una póliza origen
   psseguro in number: código del seguro origen
   piprima_np in number:
   picapfall_np in number: capital fallecimiento de la nueva póliza
   pfvencim_np in date: fecha vencimiento de la nueva póliza
   pmode in number: Modo
   pfecha in date: fecha efecto nueva póliza.
   psolicit out number: Número solicitud.
   purl out varchar2:
   pmensa in out varchar2: mensajes de error.
   return number: retorno de la función f_crearpropuesta_sp
   *************************************************************************/
   FUNCTION f_crearpropuesta_sp(psseguro     IN NUMBER,
                                piprima_np   IN NUMBER,
                                picapfall_np IN NUMBER,
                                pfvencim_np  IN DATE,
                                pmode        IN VARCHAR2,
                                pfecha       IN DATE,
                                pssolicit    OUT NUMBER,
                                purl         OUT VARCHAR2,
                                pmensa       OUT t_iax_mensajes) RETURN NUMBER;

   -- Fin bug 19303 - JMC - 21/11/2011
   /***************************************************************************
   -- BUG 0020761 - 03/01/2012 - JMF
   Dado tipo cuenta nos dice si es tarjeta o no.
   param in  pctipban:  numero de la póliza.
   return: NUMBER (0=No, 1=Si).
   ***************************************************************************/
   FUNCTION f_get_tarjeta(pctipban IN NUMBER,
                          mensajes OUT t_iax_mensajes) RETURN NUMBER;

   -- BUG20498:DRA:09/01/2012:Inici
   FUNCTION f_grabapreguntasclausula(mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   -- BUG20498:DRA:09/01/2012:Fi
   /*************************************************************************
   Graba los datos del gestor al objeto gescobro
   param in sperson   : codigo de personas
   param in cdomici   : codigo de domicilio
   param out mensajes : mensajes de error
   return             : 0 todo correcto
   1 ha habido un error
   *************************************************************************/
   -- BUG 0021592 - 08/03/2012 - JMF
   FUNCTION f_grabargescobro(p_sperson IN NUMBER,
                             p_cdomici IN NUMBER,
                             mensajes  OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   Elimina el gestor de cobro del objeto gestores de cobro
   param in p_sperson   : codigo de persona
   param out mensajes : mensajes de error
   return             : 0 todo correcto
   1 ha habido un error
   *************************************************************************/
   -- BUG 0021592 - 08/03/2012 - JMF
   FUNCTION f_eliminagescobro(p_sperson IN NUMBER,
                              mensajes  OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   Lee los datos gestor de cobro de la poliza
   param out mensajes : mensajes de error
   return             : objeto gestor cobro
   *************************************************************************/
   -- BUG 0021592 - 08/03/2012 - JMF
   FUNCTION f_leegescobro(mensajes OUT t_iax_mensajes) RETURN t_iax_gescobros;

   --bfp bug 21947 ini
   FUNCTION f_grabagestioncomisiongar(nriesgo  IN NUMBER,
                                      pcgarant IN NUMBER,
                                      pfiniefe IN DATE,
                                      pcmodcom IN NUMBER,
                                      pcomisi  IN NUMBER,
                                      pninialt IN NUMBER DEFAULT NULL, -- Inicio de la altura
                                      pnfinalt IN NUMBER DEFAULT NULL,
                                      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_leegaransegcom(nriesgo  IN NUMBER,
                             mensajes OUT t_iax_mensajes)
      RETURN t_iax_garansegcom;

   --bfp bug 21947 fi
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
   mensajes : mensajes de error
   return             : number
   ***********************************************************************/
   FUNCTION f_get_dtorec_riesgo(ptablas  IN VARCHAR2 DEFAULT 'EST',
                                psseguro IN NUMBER,
                                pnriesgo IN NUMBER,
                                pdtocom  OUT NUMBER,
                                precarg  OUT NUMBER,
                                pdtotec  OUT NUMBER,
                                preccom  OUT NUMBER,
                                mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   Establece porcentaje descuento comercial a un riesgo, y propaga los cambios a sus garantías
   param in psseguro    : Numero interno de seguro
   param in pnriesgo    : Numero interno de riesgo
   param in pdtocom     : Porcentaje descuento comercial
   param in pdiferencia : Diferencia de porcentajes a propagar
   param out mensajes   : mensajes de error
   return               : 0 todo correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_set_pdtocom_riesgogaran(psseguro    IN NUMBER,
                                      pnriesgo    IN NUMBER,
                                      pdtocom     IN NUMBER,
                                      pdiferencia IN NUMBER DEFAULT NULL,
                                      mensajes    OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Establece porcentaje recargo técnico a un riesgo, y propaga los cambios a sus garantías
   param in psseguro    : Numero interno de seguro
   param in pnriesgo    : Numero interno de riesgo
   param in precarg     : Porcentaje recargo técnico
   param in pdiferencia : Diferencia de porcentajes a propagar
   param out mensajes   : mensajes de error
   return               : 0 todo correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_set_precarg_riesgogaran(psseguro    IN NUMBER,
                                      pnriesgo    IN NUMBER,
                                      precarg     IN NUMBER,
                                      pdiferencia IN NUMBER DEFAULT NULL,
                                      mensajes    OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Establece porcentaje descuento técnico a un riesgo, y propaga los cambios a sus garantías
   param in psseguro    : Numero interno de seguro
   param in pnriesgo    : Numero interno de riesgo
   param in pdtotec     : Porcentaje descuento técnico
   param in pdiferencia : Diferencia de porcentajes a propagar
   param out mensajes   : mensajes de error
   return               : 0 todo correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_set_pdtotec_riesgogaran(psseguro    IN NUMBER,
                                      pnriesgo    IN NUMBER,
                                      pdtotec     IN NUMBER,
                                      pdiferencia IN NUMBER DEFAULT NULL,
                                      mensajes    OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Establece porcentaje recargo comercial a un riesgo, y propaga los cambios a sus garantías
   param in psseguro    : Numero interno de seguro
   param in pnriesgo    : Numero interno de riesgo
   param in preccom     : Porcentaje recargo comercial
   param in pdiferencia : Diferencia de porcentajes a propagar
   param out mensajes   : mensajes de error
   return               : 0 todo correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_set_preccom_riesgogaran(psseguro    IN NUMBER,
                                      pnriesgo    IN NUMBER,
                                      preccom     IN NUMBER,
                                      pdiferencia IN NUMBER DEFAULT NULL,
                                      mensajes    OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Establece porcentaje a: 1.descuento comercial a un riesgo
   2.recargo técnico a un riesgo,
   3.descuento técnico a un riesgo,
   4.recargo comercial a un riesgo,
   y propaga los cambios a sus garantías en cada caso.
   param in psseguro    : Numero interno de seguro
   param in pnriesgo    : Numero interno de riesgo
   param in pdtocom     : Porcentaje descuento comercial (1)
   param in precarg     : Porcentaje recargo técnico (2)
   param in pdtotec     : Porcentaje descuento técnico (3)
   param in preccom     : Porcentaje recargo comercial (4)
   param in pdiferencia : Diferencia de porcentajes a propagar
   param out mensajes   : mensajes de error
   return               : 0 todo correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_set_porcrecarg_riesgogar(psseguro    IN NUMBER,
                                       pnriesgo    IN NUMBER,
                                       pdtocom     IN NUMBER,
                                       precarg     IN NUMBER,
                                       pdtotec     IN NUMBER,
                                       preccom     IN NUMBER,
                                       pdiferencia IN NUMBER DEFAULT NULL,
                                       mensajes    OUT t_iax_mensajes)
      RETURN NUMBER;

   --  Fin Bug 21907 - MDS - 23/04/2012
   FUNCTION f_get_preguntab_riesgo(pnriesgo IN NUMBER,
                                   pcpregun IN NUMBER,
                                   mensajes OUT t_iax_mensajes)
      RETURN t_iax_preguntastab;

   FUNCTION f_get_preguntab_gar(pcpregun IN NUMBER,
                                nriesgo  IN NUMBER,
                                cgarant  IN NUMBER,
                                mensajes OUT t_iax_mensajes)
      RETURN t_iax_preguntastab;

   FUNCTION f_grabarpreguntastab(ptipo      IN VARCHAR2,
                                 pnriesgo   IN NUMBER,
                                 pcpregun   IN NUMBER,
                                 pcgarant   IN NUMBER,
                                 ptcolumnas IN t_iax_info,
                                 mensajes   OUT t_iax_mensajes) RETURN NUMBER;

   FUNCTION f_del_preguntastab(ptipo    IN VARCHAR2,
                               pnriesgo IN NUMBER,
                               pcpregun IN NUMBER,
                               pcgarant IN NUMBER,
                               pnlinea  IN NUMBER,
                               mensajes OUT t_iax_mensajes) RETURN NUMBER;

   FUNCTION f_get_preguntab(ptipo    IN VARCHAR2,
                            pnriesgo IN NUMBER,
                            pcgarant IN NUMBER,
                            pcpregun IN NUMBER,
                            mensajes OUT t_iax_mensajes)
      RETURN t_iax_preguntastab;

   FUNCTION f_get_preguntab_pol(pcpregun IN NUMBER,
                                mensajes OUT t_iax_mensajes)
      RETURN t_iax_preguntastab;

   /*************************************************************************
   Grabar el capital recomendado para cada garantia
   param in sseguro  : numero de seguro
   param in nriesgo  : numero de riesgo
   param out mensajes : mensajes de error
   return             : 0 todo correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_act_cap_recomend(pnriesgo IN NUMBER,
                               mensajes OUT t_iax_mensajes) RETURN NUMBER;

   --BUG 21657--ETM--04/06/2012 --
   FUNCTION f_leeinquiaval(pctipfig IN NUMBER,
                           mensajes OUT t_iax_mensajes) RETURN t_iax_inquiaval;

   FUNCTION f_existeinquiaval(psperson IN NUMBER,
                              pctipfig IN NUMBER,
                              mensajes OUT t_iax_mensajes) RETURN NUMBER;

   FUNCTION f_insertinquiaval(psseguro      IN NUMBER,
                              psperson      IN NUMBER,
                              pnmovimi      IN NUMBER,
                              pnriesgo      IN NUMBER,
                              pctipfig      IN NUMBER,
                              pcdomici      IN NUMBER,
                              piingrmen     IN NUMBER,
                              piingranual   IN NUMBER,
                              pffecini      IN DATE,
                              pffecfin      IN DATE,
                              pctipcontrato IN NUMBER,
                              pcsitlaboral  IN NUMBER,
                              pcsupfiltro   IN NUMBER,
                              mensajes      OUT t_iax_mensajes) RETURN NUMBER;

   FUNCTION f_eliminainquiaval(psperson IN NUMBER,
                               pctipfig IN NUMBER,
                               mensajes OUT t_iax_mensajes) RETURN NUMBER;

   FUNCTION f_grabarinquiaval(psseguro      IN NUMBER,
                              psperson      IN NUMBER,
                              pnmovimi      IN NUMBER,
                              pnriesgo      IN NUMBER,
                              pctipfig      IN NUMBER,
                              pcdomici      IN NUMBER,
                              piingrmen     IN NUMBER,
                              piingranual   IN NUMBER,
                              pffecini      IN DATE,
                              pffecfin      IN DATE,
                              pctipcontrato IN NUMBER,
                              pcsitlaboral  IN NUMBER,
                              pcsupfiltro   IN NUMBER,
                              mensajes      OUT t_iax_mensajes) RETURN NUMBER;

   FUNCTION f_get_inquiaval(psperson IN NUMBER,
                            pctipfig IN NUMBER,
                            mensajes OUT t_iax_mensajes)
      RETURN ob_iax_inquiaval;

   --FIN BUG 21657--ETM--04/06/2012
   -- 18/07/2012 - MDS - 0022824: LCOL_T010-Duplicado de propuestas
   FUNCTION f_dup_seguro(psseguroorig   IN NUMBER,
                         pfefecto       IN DATE,
                         pobservaciones IN VARCHAR2,
                         pssegurodest   OUT NUMBER,
                         pnsolicidest   OUT NUMBER,
                         pnpolizadest   OUT NUMBER,
                         pncertifdest   OUT NUMBER,
                         ptipotablas    IN NUMBER DEFAULT NULL,
                         pcagente       IN NUMBER DEFAULT NULL, --RAMIRO
                         mensajes       OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   FUNCTION  f_set_frenova
   Obtiene el valor del campo frenova
   param in pfefecto     : campo fecha
   param out pnrenova         : devuelve el campo pnrenova
   param out mensajes  : mensajes de error
   return             : 0 todo correcto
   1 ha habido errores
   *************************************************************************/
   FUNCTION f_set_frenova(pfefecto IN DATE,
                          pcduraci IN NUMBER,
                          pfrenova OUT DATE,
                          mensajes OUT t_iax_mensajes) RETURN NUMBER;

   -- Bug 0023183 - DCG - 14/08/2012 - LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
   /*************************************************************************
   FUNCTION  f_grabaCuadroCoaseguro
   Graba el cuadro de coaseguro
   param in pctlocal   : % Local
   param in pccompan   : Compa??
   param in polizaori  : P??a Origen
   param out mensajes  : mensajes de error
   return              : 0 todo correcto
   1 ha habido errores
   *************************************************************************/
   FUNCTION f_grabacuadrocoaseguro(ptipocoa  IN NUMBER, --JRH nuevo. El tipo de coaseguro.
                                   pctlocal  IN NUMBER,
                                   pccompan  IN NUMBER,
                                   polizaori IN VARCHAR2,
				   pendoso  in number default null,
                                   mensajes  OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   FUNCTION  f_grabaDetCuadroCoaseguro
   Graba el detalle del cuadro de coaseguro
   param in ccompan    : Compa??
   param in pcescoa    : % Reparto
   param in pcomcoa    : % Otros gastos
   param in pcomcon    : % Comisi??       param in pcomgas    : % Gastos
   param in pcesion    : % cesi??obre la totalidad cedida
   param out mensajes  : mensajes de error
   return              : 0 todo correcto
   1 ha habido errores
   *************************************************************************/
   FUNCTION f_grabadetcuadrocoaseguro(pccompan IN NUMBER,
                                      pcescoa  IN NUMBER,
                                      pcomcoa  IN NUMBER,
                                      pcomcon  IN NUMBER,
                                      pcomgas  IN NUMBER,
                                      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_borrardetcuadrocoaseguro(pccompan IN NUMBER,
                                       mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Lee los datos del cuadro de coaseguro
   param out mensajes : mensajes de error
   return             : objeto tomadores
   *************************************************************************/
   FUNCTION f_leedetcoaseguro(mensajes OUT t_iax_mensajes)
      RETURN ob_iax_coacuadro;

   -- Bug 0022701 - 03/09/2012 - JMF
   FUNCTION f_leeretorno(mensajes OUT t_iax_mensajes) RETURN t_iax_retorno;

   -- Bug 0022701 - 03/09/2012 - JMF
   FUNCTION f_existbenefretn(psperson IN NUMBER,
                             mensajes IN OUT t_iax_mensajes) RETURN NUMBER;

   -- Bug 0022701 - 03/09/2012 - JMF
   FUNCTION f_get_direc_retorno(psperson IN NUMBER,
                                pcagente IN NUMBER,
                                ptablas  IN VARCHAR2,
                                retrn    IN OUT ob_iax_retorno,
                                mensajes IN OUT t_iax_mensajes) RETURN NUMBER;

   -- Bug 0022701 - 03/09/2012 - JMF
   -- BUG 0023965 - 15/10/2012 - JMF
   FUNCTION f_insertretorno(psperson    IN NUMBER,
                            pretorno    IN NUMBER,
                            pidconvenio IN NUMBER,
                            mensajes    OUT t_iax_mensajes) RETURN NUMBER;

   -- Bug 0022701 - 03/09/2012 - JMF
   -- BUG 0023965 - 15/10/2012 - JMF
   FUNCTION f_grabaretorno(psperson    IN NUMBER,
                           pretorno    IN NUMBER,
                           pidconvenio IN NUMBER,
                           mensajes    OUT t_iax_mensajes) RETURN NUMBER;

   -- Bug 0022701 - 03/09/2012 - JMF
   FUNCTION f_modifretorno(psperson IN NUMBER,
                           pretorno IN NUMBER,
                           mensajes OUT t_iax_mensajes) RETURN NUMBER;

   -- Bug 0022701 - 03/09/2012 - JMF
   FUNCTION f_eliminaretorno(psperson IN NUMBER,
                             mensajes OUT t_iax_mensajes) RETURN NUMBER;

   -- Bug 0022701 - 03/09/2012 - JMF
   FUNCTION f_inicializa_retorno(mensajes OUT t_iax_mensajes)
      RETURN t_iax_retorno;

   -- Fin Bug 0023183
   FUNCTION f_get_franquicias(pnriesgo  IN NUMBER,
                              pcpartida IN NUMBER,
                              pcgarant  IN NUMBER,
                              pselgar   IN NUMBER,
                              mensajes  OUT t_iax_mensajes)
      RETURN t_iax_bf_proactgrup;

   FUNCTION f_set_franquicia(nriesgo    IN NUMBER,
                             pcgrup     IN NUMBER,
                             pcsubgrup  IN NUMBER,
                             pcversion  IN NUMBER,
                             pcnivel    IN NUMBER,
                             pcvalor1   IN NUMBER,
                             pimpvalor1 IN NUMBER,
                             pcvalor2   IN NUMBER,
                             pimpvalor2 IN NUMBER,
                             pcimpmin   IN NUMBER,
                             pimpmin    IN NUMBER,
                             pcimpmax   IN NUMBER,
                             pimpmax    IN NUMBER,
                             mensajes   OUT t_iax_mensajes) RETURN NUMBER;

   FUNCTION f_get_franquicias_garantia(pnriesgo  IN NUMBER,
                                       pcpartida IN NUMBER,
                                       pcgarant  IN NUMBER,
                                       mensajes  OUT t_iax_mensajes)
      RETURN t_iax_bf_proactgrup;

   FUNCTION f_set_franqgar_manual(nriesgo  IN NUMBER,
                                  cgarant  IN NUMBER,
                                  pctipfra IN NUMBER,
                                  pifranq  IN NUMBER,
                                  mensajes OUT t_iax_mensajes) RETURN NUMBER;

   -- BUG22839:DRA:26/09/2012:Inici
   FUNCTION f_es_col_admin(psseguro       IN NUMBER,
                           ptablas        IN VARCHAR2 DEFAULT 'SEG',
                           es_col_admin   OUT NUMBER,
                           es_certif_cero OUT NUMBER,
                           mensajes       OUT t_iax_mensajes) RETURN NUMBER;

   FUNCTION f_emitir_col_admin(psseguro        IN NUMBER,
                               pcontinuaemitir OUT NUMBER,
                               mensajes        OUT t_iax_mensajes,
                               ppasapsu        IN NUMBER DEFAULT 1,
                               pskipfusion     IN NUMBER DEFAULT 0)
      RETURN NUMBER;

   FUNCTION f_abrir_suplemento(psseguro IN NUMBER,
                               mensajes OUT t_iax_mensajes) RETURN NUMBER;

   -- BUG22839:DRA:26/09/2012:Fi
   FUNCTION f_validar_franquicias(pnriesgo IN NUMBER,
                                  mensajes OUT t_iax_mensajes) RETURN NUMBER;

   FUNCTION f_get_franquicias_consulta(pnriesgo  IN NUMBER,
                                       pcpartida IN NUMBER,
                                       mensajes  OUT t_iax_mensajes)
      RETURN t_iax_bf_proactgrup;

   -- BUG24793:DRA:17/12/2012:Inici
   FUNCTION f_leeinquiaval_rie(pnriesgo IN NUMBER,
                               pctipfig IN NUMBER,
                               mensajes OUT t_iax_mensajes)
      RETURN t_iax_inquiaval;

   -- BUG24793:DRA:17/12/2012:Inici
   /***********************************************************************
   Funciónn que nos retornaeá si un sseguro es el certificado cero ó no
   param in sseguro : codigo interno del seguro
   return             : number  0 -> Ok  1 --> no  -1 --> error
   ***********************************************************************/
   FUNCTION f_isaltacertificero(psseguro IN NUMBER,
                                mensajes OUT t_iax_mensajes) RETURN NUMBER;

   -- BUG 26253 - FAL - 05/03/2013
   FUNCTION f_es_age_lider(psseguro     IN NUMBER,
                           pnmovimi     IN NUMBER,
                           es_age_lider OUT NUMBER,
                           mensajes     OUT t_iax_mensajes) RETURN NUMBER;

   -- FI BUG 26253
   FUNCTION f_hay_franq_bonusmalus(pfranquicias OUT NUMBER,
                                   pbonusmalus  OUT NUMBER,
                                   mensajes     OUT t_iax_mensajes)
      RETURN NUMBER;

   --Ini Bug 25859 -- ECP --21/03/2013
   /*************************************************************************
   Recuperar informacion del  primer asegurado
   param out mensajes : mensajes de error
   param in  pnriesgo : numero riesgo
   return             : objeto asegurados
   *************************************************************************/
   FUNCTION f_leeprimasegurado(mensajes OUT t_iax_mensajes,
                               pnriesgo IN NUMBER DEFAULT 1)
      RETURN ob_iax_asegurados;

   --Fin Bug 25859 -- ECP --21/03/2013
   /*************************************************************************
   Comprueba si hay un cambio de plan
   param out mensajes : mensajes de error
   return             : 0-Ok,1-Error
   -- Bug 27505/148735 - 19/08/2013 - AMC
   *************************************************************************/
   FUNCTION f_haycambioplan(mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /***********************************************************************
   Funcion que inicializa el caso de bpm en la póliza
   param in pnnumcaso  : numero de caso
   param in pncaso_bpm: Numero de caso BPM
   param in pnsolici_bpm: Numero de solicitud BPM
   param out mensajes : mensajes de error
   return             : number  0 -> Ok  1 --> Error
   Bug 28263/153355 - 01/10/2013 - AMC
   ***********************************************************************/
   FUNCTION f_set_casobpm(pnnumcaso    IN NUMBER,
                          pncaso_bpm   IN NUMBER,
                          pnsolici_bpm IN NUMBER,
                          mensajes     OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   Recupera el objeto ob_iax_bpm (casos bpm) de la poliza
   param out mensajes : mensajes de error
   return             : objeto casos  BPM
   *************************************************************************/
   FUNCTION f_get_casosbmp(mensajes OUT t_iax_mensajes) RETURN ob_iax_bpm;

   FUNCTION f_get_histriesgos(psseguro IN NUMBER,
                              pnriesgo IN NUMBER,
                              mensajes OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR;

   FUNCTION f_get_folio(pcbancar      IN mandatos.cbancar%TYPE,
                        pnumfolio     OUT mandatos_seguros.numfolio%TYPE,
                        pfechamandato OUT mandatos_seguros.fechamandato%TYPE,
                        psucursal     OUT mandatos_seguros.sucursal%TYPE,
                        mensajes      OUT t_iax_mensajes) RETURN NUMBER;

   -- Bug 30365/167876 - 22/05/2014 - AMC
   FUNCTION f_inibeneficiarios(pnriesgo IN NUMBER,
                               mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   Informa un fondo inv al modelo libre.
   param in pmodelo
   param in pccodfon
   param in pcmodabo
   param in ppinv
   param out mensajes : mensajes de error
   return             : objeto casos  BPM
   *************************************************************************/
   FUNCTION f_set_modeloinv_fondo(pnmodelo IN NUMBER,
                                  pccodfon IN NUMBER,
                                  pcmodabo IN NUMBER,
                                  ppinvers IN NUMBER,
                                  mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   elimina un fondo inv al modelo libre.
   param in pmodelo
   param in pccodfon
   param in pcmodabo
   param in ppinv
   param out mensajes : mensajes de error
   return             : objeto casos  BPM
   *************************************************************************/
   FUNCTION f_elimina_modeloinv_fondo(pnmodelo IN NUMBER,
                                      pccodfon IN NUMBER,
                                      pcmodabo IN NUMBER,
                                      ppinvers IN NUMBER,
                                      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   -- BUG 0033510 - FAL - 19/11/2014
   /*************************************************************************
   Tarifica todos los riesgos
   (para ello se debe guardar toda la información a la base de datos)
   param out mensajes : mensajes de error
   return             : 0 todo correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_tarificar_todos_riesgos(mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   -- FI BUG 0033510 - FAL - 19/11/2014
   /*************************************************************************
   Lee los datos del riesgo (asegurados mes para el movimiento de regularización)
   param out mensajes : mensajes de error
   return             : objeto preguntas
   *************************************************************************/
   FUNCTION f_lee_aseguradosmes(nriesgo  IN NUMBER,
                                mensajes OUT t_iax_mensajes)
      RETURN ob_iax_aseguradosmes;

   /*************************************************************************
   Grabar informacion de un registro de aseguradosmes para un suplemento de regularización
   param in nriesgo   : numero de riesgo
   param in anyo    : año
   iy los importes de cada mes
   param out mensajes : mensajes de error
   return             : 0 todo correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_grabaraseguradosmes(pnriesgo IN NUMBER,
                                  pmes1    IN NUMBER,
                                  pmes2    IN NUMBER,
                                  pmes3    IN NUMBER,
                                  pmes4    IN NUMBER,
                                  pmes5    IN NUMBER,
                                  pmes6    IN NUMBER,
                                  pmes7    IN NUMBER,
                                  pmes8    IN NUMBER,
                                  pmes9    IN NUMBER,
                                  pmes10   IN NUMBER,
                                  pmes11   IN NUMBER,
                                  pmes12   IN NUMBER,
                                  mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   Incializa a null los asegurados por mes de un riesgo
   param out mensajes : mensajes de error
   return             : error
   *************************************************************************/
   FUNCTION f_iniciaseguradosmes(pnriesgo IN NUMBER,
                                 mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /***********************************************************************
   Graba el convenio y valida en la propuesta (pantalla de datos de gestión o simulación).
   param in pversion  :  Versión
   param out  mensajes : mensajes de error
   return             : number
   ***********************************************************************/
   FUNCTION f_set_grabarconvempvers(pidversion    IN NUMBER,
                                    pidconv       IN NUMBER,
                                    ptcodconv     IN VARCHAR2,
                                    pcestado      IN NUMBER,
                                    pcperfil      IN NUMBER,
                                    ptdescri      IN VARCHAR2,
                                    pcorganismo   IN NUMBER,
                                    pcvida        IN NUMBER,
                                    pnversion     IN NUMBER,
                                    pcestadovers  IN NUMBER,
                                    pnversion_ant IN NUMBER,
                                    ptestado      IN VARCHAR2,
                                    ptperfil      IN VARCHAR2,
                                    ptorganismo   IN VARCHAR2,
                                    ptestadovers  IN VARCHAR2,
                                    ptvida        IN VARCHAR2,
                                    ptobserv      IN VARCHAR2,
                                    mensajes      OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Grabar informacion de las preguntas
   param in nriesgo  : numero de riesgo
   param in cpregun  : Codigo de la pregunta
   param in cgarant  : codigo de la garantia
   param out mensajes : mensajes de error
   return             : 0 todo correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_grabarpreguntastab_carga(ptipo    IN VARCHAR2,
                                       pnriesgo IN NUMBER,
                                       pcpregun IN NUMBER,
                                       pcgarant IN NUMBER,
                                       pnmovimi IN NUMBER,
                                       mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Borrar informacion de las preguntas
   param in nriesgo  : numero de riesgo
   param in cpregun  : Codigo de la pregunta
   param in cgarant  : codigo de la garantia
   param out mensajes : mensajes de error
   return             : 0 todo correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_borrarpreguntastab_carga(ptipo    IN VARCHAR2,
                                       pnriesgo IN NUMBER,
                                       pcpregun IN NUMBER,
                                       pcgarant IN NUMBER,
                                       pnmovimi IN NUMBER,
                                       mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_connect_undw_if01(pnriesgo IN NUMBER,
                                mensajes OUT t_iax_mensajes)
      RETURN ob_iax_underwrt_if01;

   FUNCTION f_connect_undw_if02(pnriesgo IN NUMBER,
                                mensajes OUT t_iax_mensajes) RETURN NUMBER;

   FUNCTION f_get_citasmedicas(mensajes OUT t_iax_mensajes)
      RETURN t_iax_citamedica;

   FUNCTION f_insert_citasmedicas(psseguro  IN NUMBER,
                                  pnriesgo  IN NUMBER,
                                  pnmovimi  IN NUMBER,
                                  pnomaseg  IN VARCHAR2,
                                  psperaseg IN NUMBER,
                                  pspermed  IN NUMBER,
                                  pnommedi  IN VARCHAR2,
                                  pceviden  IN NUMBER,
                                  pteviden  IN VARCHAR2,
                                  pcodevid  IN VARCHAR2,
                                  pfeviden  IN VARCHAR2,
                                  pcestado  IN NUMBER,
                                  ptestado  IN VARCHAR2,
                                  pieviden  IN NUMBER,
                                  pcpago    IN NUMBER,
                                  pctipevi  IN NUMBER,
                                  pcais     IN NUMBER,
                                  mensajes  OUT t_iax_mensajes) RETURN NUMBER;

   FUNCTION f_editar_citasmedicas(psseguro  IN NUMBER,
                                  pnriesgo  IN NUMBER,
                                  pnmovimi  IN NUMBER,
                                  pnomaseg  IN VARCHAR2,
                                  psperaseg IN NUMBER,
                                  pspermed  IN NUMBER,
                                  pnommedi  IN VARCHAR2,
                                  pceviden  IN NUMBER,
                                  pteviden  IN VARCHAR2,
                                  pcodevid  IN VARCHAR2,
                                  pfeviden  IN VARCHAR2,
                                  pcestado  IN NUMBER,
                                  ptestado  IN VARCHAR2,
                                  pnorden   IN NUMBER,
                                  pieviden  IN NUMBER,
                                  pcpago    IN NUMBER,
                                  pnorden_r IN NUMBER,
                                  pctipevi  IN NUMBER,
                                  mensajes  OUT t_iax_mensajes) RETURN NUMBER;

   FUNCTION f_eliminar_citasmedicas(pnorden  IN NUMBER,
                                    mensajes OUT t_iax_mensajes) RETURN NUMBER;

   FUNCTION f_get_listasegura(mensajes OUT t_iax_mensajes)
      RETURN t_iax_asegurados;

   -- 36596/211429
   FUNCTION f_get_psu_retenidas(mensajes OUT t_iax_mensajes)
      RETURN t_iax_psu_retenidas;

   FUNCTION f_eliminar_citas_ais(mensajes OUT t_iax_mensajes) RETURN NUMBER;

   FUNCTION f_val_tomador_cbancar(psseguro IN NUMBER,
                                  psperson IN NUMBER,
                                  mensajes OUT t_iax_mensajes) RETURN NUMBER;

   -- BUG 0026373 - JMT - 04/04/2016
   /*************************************************************************
       FUNCTION  f_leedatoscontacto
       lee los datos de contacto
       param out mensajes : mensajes de error
       param in  npoliza :  numero poliza
       param in ncertif  : numero certificado
       return              : obtejo datos de contacto
   *************************************************************************/

   FUNCTION f_leedatoscontacto(npoliza  IN NUMBER,
                               ncertif  IN NUMBER,
                               mensajes OUT t_iax_mensajes)
      RETURN t_iax_datos_contacto;

   -- BUG 0026373 - JMT - 07/04/2016
   /*************************************************************************
       FUNCTION  f_guardadatoscontacto
       Guarda el tipo de notificacion elegido en los datos de contacto
       param out mensajes : mensajes de error
       param in  npoliza :  numero poliza
       param in ncertif  : numero certificado
       param in spersona : numero de persona
       param in tipopers : tipo de persona
       param in lmail    : permite contacto por mail (0-no, 1-si)
       param in ltel     : permite contacto por telefono (0-no, 1-si)
       return              : number
   *************************************************************************/

   FUNCTION f_guardadatoscontacto(npoliza  IN NUMBER,
                                  ncertif  IN NUMBER,
                                  spersona IN NUMBER,
                                  tipopers IN NUMBER,
                                  lmail    IN NUMBER,
                                  ltel     IN NUMBER,
                                  mensajes OUT t_iax_mensajes) RETURN NUMBER;

   -- INI BUG 41143/229973 - 17/03/2016 - JAEG
   /*************************************************************************
      Grabar informacion de las vigencias de garantias
      param in nriesgo   : numero de riesgo
      param in cgarant   : codigo garantia
      param in pfinivig  : Fecha inicio vigencia garantía
      param in pffinvig  : Fecha Fin vigencia garantía
      param out mensajes : mensajes de error
      return             : 0 todo correcto - 1 ha habido un error
   *************************************************************************/
   FUNCTION f_grabargarantiasvigencia(nriesgo  IN NUMBER,
                                      cgarant  IN NUMBER,
                                      pfinivig IN DATE,
                                      pffinvig IN DATE,
                                      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_get_contragaran

      param in mensajes  : t_iax_mensajes
      return             : t_iax_contragaran
   *************************************************************************/
   FUNCTION f_get_contragaran(mensajes OUT t_iax_mensajes)
      RETURN t_iax_contragaran;

   /*************************************************************************
      FUNCTION f_set_contragaran

      param in pscontgar : Contragarantías
      param in pcactivo  : Activo
      param in mensajes  : t_iax_mensajes
      return             : NUMBER
   *************************************************************************/
   FUNCTION f_set_contragaran(pscontgar IN NUMBER,
                              pcactivo  IN NUMBER,
                              mensajes  OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_refresh_contragaran

      param in mensajes  : t_iax_mensajes
      return             : NUMBER
   *************************************************************************/
   FUNCTION f_refresh_contragaran(mensajes OUT t_iax_mensajes) RETURN NUMBER;
   -- INI BUG 41143/229973 - 17/03/2016 - JAEG
   /*************************************************************************
      Grabar informacion si cobra prima la garantia
      param in nriesgo   : numero de riesgo
      param in cgarant   : codigo garantia
      param in pccobprima: Cobra prima
      param out mensajes : mensajes de error
      return             : 0 todo correcto - 1 ha habido un error
   *************************************************************************/
   FUNCTION f_grabargarantiascobprima(nriesgo    IN NUMBER,
                                      cgarant    IN NUMBER,
                                      pccobprima IN NUMBER,
                                      mensajes   OUT t_iax_mensajes)
      RETURN NUMBER;
   -- FIN BUG 41143/229973 - 17/03/2016 - JAEG

   FUNCTION f_borrar_simulaciones(psseguro IN NUMBER,
                                  mensajes OUT t_iax_mensajes) RETURN NUMBER;
   -- INI BUG 40871 ASDQ

   FUNCTION f_importe_cambio(p_moneda_inicial IN eco_tipocambio.cmonori%TYPE,
                             p_moneda_final   IN OUT eco_tipocambio.cmondes%TYPE,
                             p_fecha          IN eco_tipocambio.fcambio%TYPE,
                             p_importe        IN NUMBER,
                             p_redondear      IN NUMBER DEFAULT 1,
                             p_cambio         OUT NUMBER) RETURN NUMBER;
   -- FIN BUG 40871 ASDQ
   -- INI BUG CONF-114 - 21/09/2016 - JAEG
   /*************************************************************************
   Graba detalle del riesgo
   param in pnriesgo       : numero de riesgo
   param in ptdescripcion  : detalle del riesgo
   param out mensajes      : mensajes de error
   return                  : 0 todo correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_grabariedetalle(pnriesgo      IN NUMBER,
                              ptdescripcion IN VARCHAR2,
                              mensajes      OUT t_iax_mensajes) RETURN NUMBER;
   -- FIN BUG CONF-114 - 21/09/2016 - JAEG

   -- Ini  TCS_827 - ACL - 17/02/2019 
   /*************************************************************************
   Consulta las pólizas válidas
   param out mensajes      : mensajes de error
   return                  : 0 todo correcto
   1 ha habido un error
   *************************************************************************/
     FUNCTION f_consultapoliza_contrag(pramo            IN NUMBER,
                             psproduc         IN NUMBER,
                             pnpoliza         IN NUMBER,
                             pncert           IN NUMBER DEFAULT -1,
                             pnnumide         IN VARCHAR2,
                             psnip            IN VARCHAR2,
                             pbuscar          IN VARCHAR2,
                             pnsolici         IN NUMBER, 
                             ptipopersona     IN NUMBER,
                             pcagente         IN NUMBER, 
                             pcmatric         IN VARCHAR2, 
                             pcpostal         IN VARCHAR2, 
                             ptdomici         IN VARCHAR2, 
                             ptnatrie         IN VARCHAR2, 
                             pcsituac         IN NUMBER,
                             p_filtroprod     IN VARCHAR2,
                             pcpolcia         IN VARCHAR2, 
                             pccompani        IN NUMBER, 
                             pcactivi         IN NUMBER, 
                             pcestsupl        IN NUMBER, 
                             pnpolrelacionada IN NUMBER,
                             pnpolini         IN VARCHAR2, 
                             mensajes         OUT t_iax_mensajes,
                             pfilage          IN NUMBER, 
                             pcsucursal       IN NUMBER DEFAULT NULL, 
                             pcadm            IN NUMBER DEFAULT NULL, 
                             pcmotor          IN VARCHAR2 DEFAULT NULL, 
                             pcchasis         IN VARCHAR2 DEFAULT NULL, 
                             pnbastid         IN VARCHAR2 DEFAULT NULL, 
                             pcmodo           IN NUMBER DEFAULT NULL,
                             pncontrato       IN VARCHAR2 DEFAULT NULL)
      RETURN SYS_REFCURSOR;
	-- Fin  TCS_827 - ACL - 17/02/2019 
    --INI BUG 3324  Interacción del Rango DIAN con la póliza (No. Certificado)   
       /***********************************************************************
   Busca el certificado dian de la póliza ligado al movimiento
   ***********************************************************************/   
   FUNCTION f_get_certdian(psseguro IN NUMBER,
                           pnrecibo  IN NUMBER,
                           mensajes  OUT t_iax_mensajes) RETURN VARCHAR2;


	  /*   Graba un nuevo riesgo o lo modifica en el objeto persistente
   param in pnriesgo       : número de riesgo
   param in ptdescripcion  : descripción del riesgo
   param in pnasegur       : número de asegurados
   param in pnedadcol      : Edad de un riesgo de un colectivo inominado
   param in psexcol        : Sexo de un riesgo de un colectivo inominado
   param out mensajes      : mensajes de error
   return                  : 0 todo correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_grabariedescripcionin(pnriesgo      IN NUMBER,
                                  ptdescripcion IN VARCHAR2,
                                  pnasegur      IN VARCHAR2,
                                  pnedadcol     IN NUMBER,
                                  psexcol       IN NUMBER,
                                  mensajes      OUT t_iax_mensajes)
      RETURN NUMBER;    

END pac_iax_produccion;
/