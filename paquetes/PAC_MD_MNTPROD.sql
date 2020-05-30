--------------------------------------------------------
--  DDL for Package PAC_MD_MNTPROD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_MNTPROD" AS
/******************************************************************************
   NOMBRE:       PAC_MD_MNTPROD
   PROPÓSITO: Funciones para mantenimiento productos

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        02/04/2008   ACC                1. Creación del package.
   2.0        07/01/2009   XCG                2. Modificación del package. (8510)
   3.0        29/06/2009   AMC                3. Se añaden nuevas funciones bug 10557
   4.0        05/05/2010   AMC                4. Bug 14284. Se añaden nuevas funciones.
   5.0        27/05/2010   AMC                5. Se añade la función f_del_garantia bug 14723
   6.0        04/06/2010   PFA                6. 14588: CRT001 - Añadir campo compañia productos
   7.0        04/06/2010   AMC                7. Se añaden nuevas funciones bug 14748
   8.0        16/06/2010   AMC                8. Se añaden nuevas funciones bug 15023
   9.0        21/06/2010   AMC                9. Se añaden nuevas funciones bug 15148
   10.0       29/06/2010   AMC                10. Se añaden nuevas funciones bug 15149
   11.0       23/07/2010   PFA                11. 15513: MDP - Alta de productos
   12.0       15/12/2010   LCF                12. 16684: Anyadir ccompani para productos especiales
   13.0       17/05/2012   MDS                13. 0022253: LCOL - Duración del cobro como campo desplegable
   14.0       23/01/2014   AGG                15. 0027306: POSS518 (POSSF200)- Resolucion de Incidencias FASE 1-2: Tecnico - VI - Temporales anuales renovables
   15.0       18/02/2014   DEV                15. 0029920: POSFC100-Taller de Productos
   16.0       25/09/2014   JTT                16. 0032367: Añadimos el 'Codigo contable' en el bloque de Administracion
                                                  0032620: Añadimos el 'Tipo de provision' en el bloque Datos tecnicos
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

-- Bug 14588 - 07/06/2010 - PFA
   /**************************************************************************
     Inserta un nuevo registro en la tabla companipro. Si existe, lo actualiza
     param in psproduc     : Codigo del producto
     param in pccompani    : Codigo de la compania
     param in pcagencorr   : Codigo del agente en la compania/producto
     param in psproducesp  : Codigo del producto especifico
   **************************************************************************/
   FUNCTION f_insert_companipro(
      psproduc IN NUMBER,
      pccompani IN NUMBER,
      pcagencorr IN VARCHAR2,
      psproducesp IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /**************************************************************************
     Borra un registro de la tabla companipro.
     param in psproduc     : Codigo del producto
     param in pccompani    : Codigo de la compania
   **************************************************************************/
   FUNCTION f_delete_companipro(
      psproduc IN NUMBER,
      pccompani IN NUMBER,
      psproducesp IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   --Fi Bug 14588 - 07/06/2010 - PFA

   /*************************************************************************
      Recupera el objeto con la información del producto
      param in pcempresa   : código empresa
      param in pcramo      : código ramo
      param in pcagrpro    : código agrupación producto
      param in pcactivo    : activo
      param out mensajes   : mensajes de error
   *************************************************************************/
   FUNCTION f_get_consulta(
      pcempresa IN NUMBER,
      pcramo IN NUMBER,
      pcagrpro IN NUMBER,
      pcactivo IN NUMBER,
      pccompani IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

      /*************************************************************************
      Recupera el objeto con la información del producto filtrado
      param in pcempresa   : código empresa
      param in pcramo      : código ramo
      param in pcagrpro    : código agrupación producto
      param in pcactivo    : activo
      param out mensajes   : mensajes de error
   *************************************************************************/
   FUNCTION f_get_consulta_filtrado(
      pcempresa IN NUMBER,
      pcramo IN NUMBER,
      pcagrpro IN NUMBER,
      pcactivo IN NUMBER,
      pccompani IN NUMBER,   --BUG 14588 - PFA -  CRT001 - Añadir campo compañia productos
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Duplica el productos especificado como "origen", en un nuevo producto
      identificado como "destino". La salida del duplicado (script o ejecución
      directa en base de datos se puede especificar mediante el parámetro de
      entrada "psalida".
      param in  pramorig    : Ramo origen
      param in  pmodaliorig : Modalidad origen
      param in  ptipsegorig : Tipo seguro origen
      param in  pcolectorig : Colectividad origen
      param in  pramdest    : Ramo destino
      param in  pmodalidest : Modalidad destino
      param in  ptipsegdest : Tipo seguro destino
      param in  pcolectdest : Colectividad destino
      param in  psalida     : Tipo de salida 0/1 ' Script / BD
      param out mensajes    : mensajes de error
      retorno: 0 -> Todo ha ido bien
               <>0 -> Error al duplicar producto.
   *************************************************************************/
   FUNCTION f_duplicarprod(
      pramorig IN NUMBER,
      pmodaliorig IN NUMBER,
      ptipsegorig IN NUMBER,
      pcolectorig IN NUMBER,
      pramdest IN NUMBER,
      pmodalidest IN NUMBER,
      ptipsegdest IN NUMBER,
      pcolectdest IN NUMBER,
      psalida IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /************************************************************************
      Recupera información del producto -->>
   *************************************************************************/

   /*************************************************************************
      Recupera el objeto con la información del producto
      param in psproduc  : código producto
      param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_get_producto(psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_producto;

   -- Bug 14588 - 07/06/2010 - PFA
   /*************************************************************************
      Recupera los datos de las compañias para ese producto
      param in psproduc  : código producto
      param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_get_companipro(psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_companiprod;

   -- Fi Bug 14588 - 07/06/2010 - PFA

   /*************************************************************************
      Recupera el objeto con la información del producto
      recupera titulos del producto
      param in psproduc  : código producto
      param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_get_prodtitulo(psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_prodtitulo;

   /*************************************************************************
      Recupera los datos generales del producto
      param in psproduc  : código producto
      param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_get_datosgenerales(psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_producto;

   /*************************************************************************
      Recupera el objeto con la información del producto
      datos de gestión
      param in psproduc  : código producto
      param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_get_gestion(psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_prodgestion;

   /*************************************************************************
      Recupera el objeto con la información del producto
      datos gestión duraciones
      param in psproduc  : código producto
      param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_get_durperiod(psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_proddurperiodo;

   /*************************************************************************
      Recupera el objeto con la información del producto
      datos administración
      param in psproduc  : código producto
      param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_get_admprod(psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_prodadministracion;

   /*************************************************************************
      Recupera el objeto con la información del producto
      formas de pago
      param in psproduc  : código producto
      param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_get_forpago(psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_prodformapago;

   /*************************************************************************
      Recupera el objeto con la información del producto
      datos tecnicos
      param in psproduc  : código producto
      param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_get_dattecn(psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_proddatostecnicos;

   /*************************************************************************
      Recupera el objeto con la información del producto
      unit linked
      param in psproduc  : código producto
      param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_get_unitulk(psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_productosulk;

   /*************************************************************************
      Recupera el objeto con la información del producto
      datos rentas
      param in psproduc  : código producto
      param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_get_datrent(psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_productosren;

   /*************************************************************************
      Recupera las garantias del producto y actividad
      param in psproduc  : código del producto
      param in pcactivi  : código actividad
      param out mensajes : mensajes de error
      return             : objecto garantias
   *************************************************************************/
   FUNCTION f_get_garantias(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_prodgarantias;

   /*************************************************************************
      Recupera el objeto con la información del producto
      preguntas por productos
      param in psproduc  : código producto
      param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_get_pregunpro(psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_prodpreguntas;

   /*************************************************************************
      Recupera el objeto con los parametros del producto
      param in psproduc  : código producto
      param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_get_parampro(psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_prodparametros;

   /*************************************************************************
      Recupera el objeto con los beneficiarios del producto
      param in psproduc  : código producto
      param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_get_benefpro(psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_prodbeneficiarios;

   /*************************************************************************
      Recupera el objeto con la información del producto
      actividades
      param in psproduc  : código producto
      param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_get_activid(psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_prodactividades;

   /************************************************************************
      Recupera información del producto actividades -->>
   *************************************************************************/

   /*************************************************************************
      Recupera el objeto con la información del producto
      parámetros actividades
      param in psproduc  : código producto
      param in pcactivi  : código acticividad
      param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_get_paractividad(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_prodparactividad;

   /*************************************************************************
      Recupera el objeto con la información del producto
      preguntas actividades
      param in psproduc  : código producto
      param in pcactivi  : código acticividad
      param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_get_pregunacti(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_prodpregunacti;

   /*************************************************************************
      Recupera el objeto con la información del producto
      recargo fraccionamiento actividades
      param in psproduc  : código producto
      param in pcactivi  : código acticividad
      param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_get_recfraccacti(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_prodrecfraccacti;

   /************************************************************************
      <<-- Recupera información del producto actividades
   *************************************************************************/

   /************************************************************************
      Recupera información de la garantia -->>
   *************************************************************************/

   /*************************************************************************
      Recupera el cursor con la información de la tabla GARANPRO
      param in psproduc  : código producto
      param in pcactivi  : código actividad
      param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_get_datosgeneralesgaran(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_prodgarantias;

   /*************************************************************************
      Recupera el objeto con la información de la garantia
      datos de gestión
      param in psproduc  : código producto
      param in pcactivi  : código de la actividad
      param in pcgarant  : código de la garantia
      param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_get_gestiongaran(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_prodgardatgestion;

   /*************************************************************************
       Recupera el objeto con la información de los impuestos de una garantia
       param in psproduc  : código producto
       param in pcactivi  : código actividad
       param in pgarant  : código garantía
       param out mensajes : mensajes de error
    *************************************************************************/
   FUNCTION f_get_impuestosgaran(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_prodgarimpuestos;

   /*************************************************************************
       Recupera el objeto con la información de los datos técnicos de una garantia
       param in psproduc  : código producto
       param in pcactivi  : código actividad
       param in pgarant  : código garantía
       param out mensajes : mensajes de error
    *************************************************************************/
   FUNCTION f_get_datostecngaran(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_prodgardattecnicos;

   /*************************************************************************
       Recupera el objeto con la información de las incompatibilidades de una garantia
       param in psproduc  : código producto
       param in pcactivi  : código actividad
       param in pgarant  : código garantía
       param out mensajes : mensajes de error
    *************************************************************************/
   FUNCTION f_get_incompatigaran(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_prodincompgaran;

   /*************************************************************************
      Recupera los cumulos de la garantia del producto
      param in psproduc  : código del producto
      param in pcactivi  : código actividad
      param in pcgarant  : código garantia
      param out mensajes : mensajes de error
      return             : objecto beneficiarios
   *************************************************************************/
   FUNCTION f_get_cumulosgaran(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_prodcumgaran;

   /*************************************************************************
        Recupera el objeto con la información de las formulas de una garantia
        param in psproduc  : código producto
        param in pcactivi  : código actividad
        param in pgarant  : código garantía
        param out mensajes : mensajes de error
     *************************************************************************/
   FUNCTION f_get_formulasgaran(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_prodgarformulas;

   /*************************************************************************
      Recupera la información de la tabla pregunprogaran
      param in psproduc  : código producto
      param in pcactivi  : código actividad
      param in pcgarant  : código garantia
      param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_get_pregungaran(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_prodpregunprogaran;

   /*************************************************************************
       Recupera el objeto con los parametros de la garantia
       Psproduc    NUMBER    IN        Código producto
       Pcactivi    NUMBER    IN        Código de actividad
       Pcgarant    NUMBER    IN        Código garantia
       param out mensajes : mensajes de error
    *************************************************************************/
   FUNCTION f_get_paramgaran(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_prodparagaranpro;

   /************************************************************************
      <<-- Recupera información de la garantia
   *************************************************************************/

   /************************************************************************
      Recupera información del producto datos unit linked -->>
   *************************************************************************/

   /*************************************************************************
      Recupera el objeto con la información del producto
      datos unit linked modelos inversión
      param in psproduc  : código producto
      param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_get_modelosinv(psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_produlkmodelosinv;

   /*************************************************************************
      Recupera el objeto con la información del producto
      datos unit linked fondos inversión
      param in psproduc  : código producto
      param in pcmodinv  : código modelo inversión
      param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_get_modinvfondo(
      psproduc IN NUMBER,
      pcmodinv IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_produlkmodinvfondo;

   /************************************************************************
      <<-- Recupera información del producto datos unit linked
   *************************************************************************/

   /************************************************************************
      Recupera información del producto datos rentas -->>
   *************************************************************************/

   /*************************************************************************
      Recupera el objeto con la información del producto
      datos rentas formulas
      param in psproduc  : código producto
      param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_get_rentasformula(psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_prodrentasformula;

   /*************************************************************************
      Recupera el objeto con la información del producto
      datos rentas formas de pago
      param in psproduc  : código producto
      param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_get_forpagren(psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_prodforpagren;

   /************************************************************************
      <<-- Recupera información del producto datos rentas
   *************************************************************************/

   /************************************************************************
      <<-- Recupera información del producto
   *************************************************************************/

   /*************************************************************************
      Valida los datos generales
      param in psproduc    : código del producto
      param in pcramo      : código del ramo
      param in pcmodali    : código de la modalidad
      param in pctipseg    : código del tipo de seguro
      param in pccolect    : código de colectividad
      param in pcactivo    : indica si el producto está activo
      param in pctermfin   : contratable desde el terminal financiero, 0.-Si, 1.-No
      param in pctiprie    : tipo de riesgo
      param in pcobjase    : Tipo de objeto asegurado
      param in pcsubpro    : Código de subtipo de producto
      param in pnmaxrie    : maximo riesgo
      param in pc2cabezas  : c2cabezas
      param in pcagrpro    : Codigo agrupación de producto
      param in pcdivisa    : Clave de Divisa
      param in pTitulos    : Colección t_iax_prodtitulo
      param out mensajes   : mensajes de error
      return 0 bien numerror error
   *************************************************************************/
   FUNCTION f_validadatosgenerales(
      psproduc IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pcactivo IN NUMBER,
      pctermfin IN NUMBER,
      pctiprie IN NUMBER,
      pcobjase IN NUMBER,
      pcsubpro IN NUMBER,
      pnmaxrie IN NUMBER,
      pc2cabezas IN NUMBER,
      pcagrpro IN NUMBER,
      pcdivisa IN NUMBER,
      pcompani IN NUMBER,
      ptitulos IN t_iax_prodtitulo,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Realiza las inserciones, modificaciones y validaciones
      param in psproduc    : código del producto
      param in pcramo      : código del ramo
      param in pcmodali    : código de la modalidad
      param in pctipseg    : código del tipo de seguro
      param in pccolect    : código de colectividad
      param in pcactivo    : indica si el producto está activo
      param in pctermfin   : contratable desde el terminal financiero, 0.-Si, 1.-No
      param in pctiprie    : tipo de riesgo
      param in pcobjase    : Tipo de objeto asegurado
      param in pcsubpro    : Código de subtipo de producto
      param in pnmaxrie    : maximo riesgo
      param in pc2cabezas  : c2cabezas
      param in pcagrpro    : Codigo agrupación de producto
      param in pcdivisa    : Clave de Divisa
      param in pTitulos    : Colección t_iax_prodtitulo
      param out mensajes   : mensajes de error
      return number 0 bien 1 error
   *************************************************************************/
   FUNCTION f_set_datosgenerales(
      psproduc IN OUT NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pcactivo IN NUMBER,
      pctermfin IN NUMBER,
      pctiprie IN NUMBER,
      pcobjase IN NUMBER,
      pcsubpro IN NUMBER,
      pnmaxrie IN NUMBER,
      pc2cabezas IN NUMBER,
      pcagrpro IN NUMBER,
      pcdivisa IN NUMBER,
      ptitulos IN t_iax_prodtitulo,
      pcprprod IN NUMBER,
      pcompani IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Valida los datos de gestión de un producto
      param in psproduc   : código del producto
      param in cduraci    : código de la duración
      param in ctempor    : Permite temporal
      param in ndurcob    : Duración pagos
      param in cdurmin    : Duración mínima
      param in nvtomin    : Tipo
      param in cdurmax    : duración máxima póliza
      param in nvtomax    : Número años máximo para el vto.
      param in ctipefe    : Tipo de efecto
      param in nrenova    : renovación
      param in cmodnre    : Fecha de renovación
      param in cprodcar   : Si ha pasado cartera
      param in crevali    : Código de revalorización
      param in prevali    : Porcentaje revalorización
      param in irevali    : Importe revalorización
      param in ctarman    : tarificación puede ser manual
      param in creaseg    : creaseg
      param in creteni    : Indicador de propuesta
      param in cprorra    : tipo prorrateo
      param in cprimin    : tipo de prima minima
      param in iprimin    : importe mínimo prima de recibo en emisión
      param in cclapri    : Fórmula prima mínima
      param in ipminfra   : Prima mínima fraccionada
      param in nedamic    : Edad mín ctr
      param in ciedmic    : Edad real
      param in nedamac    : Edad máx. ctr
      param in ciedmac    : Edad Real. Check por defecto = 0 ( sino es actuarial)
      param in nedamar    : Edad máx. ren
      param in ciedmar    : Edad Real
      param in nedmi2c    : Edad mín ctr 2º aseg.
      param in ciemi2c    : Edad real
      param in nedma2c    : Edad máx. ctr 2º aseg.
      param in ciema2c    : Edad Real
      param in nedma2r    : Edad máx. ren 2º aseg.
      param in ciema2r    : Real o Actuarial
      param in nsedmac    : Suma Máx. Edades
      param in cisemac    : Real
      param in cvinpol    : Póliza vinculada
      param in cvinpre    : Préstamo vinculado
      param in ccuesti    : Cuestionario Salud
      param in cctacor    : Libreta
      return              : 0 si ha ido bien
                           error si ha ido mal
   *************************************************************************/
   FUNCTION f_validagestion(
      psproduc IN NUMBER,
      pcduraci IN NUMBER,
      pctempor IN NUMBER,
      pndurcob IN NUMBER,
      pcdurmin IN NUMBER,
      pnvtomin IN NUMBER,
      pcdurmax IN NUMBER,
      pnvtomax IN NUMBER,
      pctipefe IN NUMBER,
      pnrenova IN NUMBER,
      pcmodnre IN NUMBER,
      pcprodcar IN NUMBER,
      pcrevali IN NUMBER,
      pprevali IN NUMBER,
      pirevali IN NUMBER,
      pctarman IN NUMBER,
      pcreaseg IN NUMBER,
      pcreteni IN NUMBER,
      pcprorra IN NUMBER,
      pcprimin IN NUMBER,
      piprimin IN NUMBER,
      pcclapri IN NUMBER,
      pipminfra IN NUMBER,
      pnedamic IN NUMBER,
      pciedmic IN NUMBER,
      pnedamac IN NUMBER,
      pciedmac IN NUMBER,
      pnedamar IN NUMBER,
      pciedmar IN NUMBER,
      pnedmi2c IN NUMBER,
      pciemi2c IN NUMBER,
      pnedma2c IN NUMBER,
      pciema2c IN NUMBER,
      pnedma2r IN NUMBER,
      pciema2r IN NUMBER,
      pnsedmac IN NUMBER,
      pcisemac IN NUMBER,
      pcvinpol IN NUMBER,
      pcvinpre IN NUMBER,
      pccuesti IN NUMBER,
      pcctacor IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Valida los datos de gestión de un producto
      param in psproduc   : código del producto
      param in cduraci    : código de la duración
      param in ctempor    : Permite temporal
      param in ndurcob    : Duración pagos
      param in cdurmin    : Duración mínima
      param in nvtomin    : Tipo
      param in cdurmax    : duración máxima póliza
      param in nvtomax    : Número años máximo para el vto.
      param in ctipefe    : Tipo de efecto
      param in nrenova    : renovación
      param in cmodnre    : Fecha de renovación
      param in cprodcar   : Si ha pasado cartera
      param in crevali    : Código de revalorización
      param in prevali    : Porcentaje revalorización
      param in irevali    : Importe revalorización
      param in ctarman    : tarificación puede ser manual
      param in creaseg    : creaseg
      param in creteni    : Indicador de propuesta
      param in cprorra    : tipo prorrateo
      param in cprimin    : tipo de prima minima
      param in iprimin    : importe mínimo prima de recibo en emisión
      param in cclapri    : Fórmula prima mínima
      param in ipminfra   : Prima mínima fraccionada
      param in nedamic    : Edad mín ctr
      param in ciedmic    : Edad real
      param in nedamac    : Edad máx. ctr
      param in ciedmac    : Edad Real. Check por defecto = 0 ( sino es actuarial)
      param in nedamar    : Edad máx. ren
      param in ciedmar    : Edad Real
      param in nedmi2c    : Edad mín ctr 2º aseg.
      param in ciemi2c    : Edad real
      param in nedma2c    : Edad máx. ctr 2º aseg.
      param in ciema2c    : Edad Real
      param in nedma2r    : Edad máx. ren 2º aseg.
      param in ciema2r    : Real o Actuarial
      param in nsedmac    : Suma Máx. Edades
      param in cisemac    : Real
      param in cvinpol    : Póliza vinculada
      param in cvinpre    : Préstamo vinculado
      param in ccuesti    : Cuestionario Salud
      param in cctacor    : Libreta
      return              : 0 si ha ido bien
                           error si ha ido mal
   *************************************************************************/
   FUNCTION f_set_gestion(
      psproduc IN NUMBER,
      pcduraci IN NUMBER,
      pctempor IN NUMBER,
      pndurcob IN NUMBER,
      pcdurmin IN NUMBER,
      pnvtomin IN NUMBER,
      pcdurmax IN NUMBER,
      pnvtomax IN NUMBER,
      pctipefe IN NUMBER,
      pnrenova IN NUMBER,
      pcmodnre IN NUMBER,
      pcprodcar IN NUMBER,
      pcrevali IN NUMBER,
      pprevali IN NUMBER,
      pirevali IN NUMBER,
      pctarman IN NUMBER,
      pcreaseg IN NUMBER,
      pcreteni IN NUMBER,
      pcprorra IN NUMBER,
      pcprimin IN NUMBER,
      piprimin IN NUMBER,
      pcclapri IN NUMBER,
      pipminfra IN NUMBER,
      pnedamic IN NUMBER,
      pciedmic IN NUMBER,
      pnedamac IN NUMBER,
      pciedmac IN NUMBER,
      pnedamar IN NUMBER,
      pciedmar IN NUMBER,
      pnedmi2c IN NUMBER,
      pciemi2c IN NUMBER,
      pnedma2c IN NUMBER,
      pciema2c IN NUMBER,
      pnedma2r IN NUMBER,
      pciema2r IN NUMBER,
      pnsedmac IN NUMBER,
      pcisemac IN NUMBER,
      pcvinpol IN NUMBER,
      pcvinpre IN NUMBER,
      pccuesti IN NUMBER,
      pcctacor IN NUMBER,
      pcpreaviso IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
       Modifica o inserta un periodo
       param in psproduc   : código del producto
       param in Pfinicio   : fecha inicio
       param in pndurper   : duracion
       param in PndurperOld: duracion anterior
       param out mensajes  : mensajes de error
       return              : 0 si ha ido bien
                             1 si ha ido mal
    *************************************************************************/
   FUNCTION f_set_durperiod(
      psproduc IN NUMBER,
      pfinicio IN DATE,
      pndurper IN NUMBER,
      pndurperold IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
       Borra las duraciones permitidas para un producto
       param in psproduc   : código del producto
       param in Pfinicio   : fecha inicio
       param in pndurper   : duracion
       param out mensajes  : mensajes de error
       return              : 0 si ha ido bien
                             1 si ha ido mal
   *************************************************************************/
   FUNCTION f_del_durperiod(
      psproduc IN NUMBER,
      pfinicio IN DATE,
      pndurper IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Realiza las  modificaciones y validaciones de los datos de admnistración del producto
      param in psproduc    : código del producto
      param in Pctipges    : Gestión del seguro.
      param in pcreccob    : 1er recibo
      param in pctipreb    : Recibo por.
      param in pccalcom    : Cálculo comisión
      param in pctippag    : Cobro
      param in pcmovdom    : Domiciliar el primer recibo
      param in pcfeccob    : Acepta fecha de cobro
      param in pcrecfra    : Recargo Fraccionamiento
      param in piminext    : Prima mínima extorno
      param in pndiaspro   : Días acumulables
      param in pcnv_spr    : Identificador del cliente para el producto en contabilidad
      param out mensajes   : mensajes de error
      retorna un cero si todo va bien  y un uno en caso contrario
   *************************************************************************/
   FUNCTION f_set_admprod(
      psproduc IN NUMBER,
      pctipges IN NUMBER,
      pcreccob IN NUMBER,
      pctipreb IN NUMBER,
      pccalcom IN NUMBER,
      pctippag IN NUMBER,
      pcmovdom IN NUMBER,
      pcfeccob IN NUMBER,
      pcrecfra IN NUMBER,
      piminext IN NUMBER,
      pndiaspro IN NUMBER,
      pcnv_spr IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Realiza validaciones e inserta/modifica formas de pago del producto
      param in psproduc  : código producto
      param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_set_forpago(
      psproduc IN NUMBER,
      pcforpag IN NUMBER,
      ptforpag IN VARCHAR2,
      pcobliga IN NUMBER,
      pprecarg IN NUMBER,
      pcpagdef IN NUMBER,
      pcrevfpg IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Inserta o modifica los impuestos de una garantia
      param in psproduc    : código del producto
      param in pcactivi    : código de la actividad
      param in pcgarant    : código de la garantía
      param in pcimpcon    : aplica consorcio 0/1
      param in pcimpdgs    : aplica la DGS 0/1
      param in pcimpips    : aplica IPS 0/1
      param in pcimparb    : se calcula arbitrios 0/1
      param in pcimpfng    :
      param out mensajes   : mensajes de error
      return               : 0 si ha ido bien
                            numero error si ha ido mal
   *************************************************************************/
   FUNCTION f_set_impuestosgaran(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pcimpcon IN NUMBER,
      pcimpdgs IN NUMBER,
      pcimpips IN NUMBER,
      pcimparb IN NUMBER,
      pcimpfng IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Inserta o modifica la formula de una garantia
      param in psproduc    : código del producto
      param in pcactivi    : código de la actividad
      param in pcgarant    : código de la garantía
      param in pccampo     : código del campo
      param in pclave      : clave fórmula
      param out mensajes   : mensajes de error
      return               : 0 si ha ido bien
                            numero error si ha ido mal
   *************************************************************************/
   FUNCTION f_set_prodgarformulas(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pccampo IN VARCHAR2,
      pclave IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
       Devuelve la descripción de un cuadro de interés
       param in ncodint    : Código del cuadro
       param out mensajes  : mensajes de error
       return              : Descripción del cuadro de interes
   *************************************************************************/
   FUNCTION f_get_descripncodint(pncodint IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN VARCHAR2;

   /*************************************************************************
       Devuelve los diferentes tipos de interés que tiene asignado el producto
       param in psproduc    : código del producto
       param out mensajes   : mensajes de error
       return               : Descripción del cuadro de interes
   *************************************************************************/
   FUNCTION f_get_tipintprod(psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_intertecprod;

    /*************************************************************************
       Devuelve las vigencias para un cuadro en concreto y un tipo de interes
       param in ncodint     : Código del cuadro
       param in pctipo      : tipo de interes
       param out mensajes   : mensajes de error
       return               : Objeto con las viencias
   *************************************************************************/
   FUNCTION f_get_intertecmov(
      pncodint IN NUMBER,
      pctipo IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_intertecprod;

   /*************************************************************************
       Devuelve los tramos que tiene para un cuadro y un tipo de interés en concreto
       param in PNCODINT    : Código del cuadro
       param in PCTIPO      : Código del tipo de interés
       param in PFINICIO    : Fecha de la vigencia
       param out mensajes   : mensajes de error
       return               : Tramos que tiene para un cuadro y un tipo de interés en concreto
   *************************************************************************/
   FUNCTION f_get_intertecmovdet(
      pncodint IN NUMBER,
      pctipo IN NUMBER,
      pfinicio IN DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_intertecmovdetprod;

   /*************************************************************************
       Devuelve los diferentes códigos de interés que tiene un cuadro a una fecha
       param in PNCODINT    : Código del cuadro
       param out mensajes   : mensajes de error
       return               : Cursor con los diferentes códigos de interes que tiene un cuadro a una fecha
   *************************************************************************/
   FUNCTION f_get_cuadrointeresprod(pncodint IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_intertecprod;

   /*************************************************************************
       función que modificará los datos técnicos de un producto en concreto
       param in Psproduc  : Código del producto.
       PARAM IN pnniggar  : Indica si los gastos están a nivel de garantía Parámetro de entrada
       PARAM IN pnniigar  : Indicador de si el interés técnico está a nivel de garantía. Parámetro de entrada
       PARAM IN pcmodint  : Intereses tecnicos modificables en póliza.
       PARAM IN pcintrev  : Por defecto en renovación aplicar el interés del producto
       PARAM IN pncodint  : Código del cuadro de interés que se ha escogido para el producto
       param IN out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_set_dattecn(
      psproduc IN NUMBER,
      pnniggar IN NUMBER,
      pnniigar IN NUMBER,
      pcmodint IN NUMBER,
      pcintrev IN NUMBER,
      pncodint IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
        función que recupera la descripción de un cuadro de interés
        PARAM IN PNCODINT  : Código del cuadro de interés que se ha escogido para el producto
        PARAM IN PCIDIOMA  : Código del Idioma
        PARAM IN TNCODINT  : Descripción del cuadro de interés
        param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_get_ncodint(
      pncodint IN NUMBER,
      pcidioma IN NUMBER,
      ptncodint IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
         función que se encargará de borrar un cuadro de interés técnico
         PARAM IN PNCODINT  : Código del cuadro de interés que se ha escogido para el producto
         param out mensajes : mensajes de error
    *************************************************************************/
   FUNCTION f_del_intertec(pncodint IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

    /*************************************************************************
    función que se encargará de borrar una vigencia de un cuadro de interés técnico
    PARAM IN PNCODINT   : Código del cuadro de interés que se ha escogido para el producto
    PARAM IN PCTIPO     : Código del tipo de interés.
    PARAM IN PFINICIO   : Fecha inicio vigencia del tramo.
   *************************************************************************/
   FUNCTION f_del_intertecmov(
      pncodint IN NUMBER,
      pctipo IN NUMBER,
      pfinicio IN DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

    /*************************************************************************
        Función que se encargará de borrar una vigencia de un cuadro de interés técnico
        PARAM IN PNCODINT  : Código del cuadro de interés
        PARAM IN PCTIPO    : Código del tipo de interés.
        PARAM IN PFINICIO  : Fecha inicio vigencia del tramo.
        PARAM IN PNDESDE   : importe/edad desde
        PARAM OUT mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_del_intertecmovdet(
      pncodint IN NUMBER,
      pctipo IN NUMBER,
      pfinicio IN DATE,
      pndesde IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    función que se encargará de recuperar la información de una vigencia en concreto para un cuadro de interés.
    PARAM IN PNCODINT   : Código del cuadro de interés que se ha escogido para el producto
    PARAM IN PCTIPO     : Código del tipo de interés.
    PARAM IN PFINICIO   : Fecha inicio vigencia del tramo.
    PARAM OUT PFFIN
    PARAM OUT PCTRAMTIP
    param out mensajes  : mensajes de error
   *************************************************************************/
   FUNCTION f_getreg_intertecmov(
      pncodint IN NUMBER,
      pctipo IN NUMBER,
      pfinicio IN DATE,
      pffin OUT DATE,
      pctramtip OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    función que se encarga de validar y grabar una nueva vigencia para un cuadro de interés.
    PARAM IN PNCODINT   : Código del cuadro de interés que se ha escogido para el producto
    PARAM IN PCTIPO     : Código del tipo de interés.
    PARAM IN PFINICIO   : Fecha inicio vigencia del tramo.
    PARAM IN PFFIN      : Fecha fin
    PARAM IN PCTRAMTIP  : Código del concepto del tramo
    param out mensajes  : mensajes de error
   *************************************************************************/
   FUNCTION f_set_intertecmov(
      pncodint IN NUMBER,
      pctipo IN NUMBER,
      pfinicio IN DATE,
      pffin IN DATE,
      pctramtip IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   función que nos sirve para recuperar un registro de un tramo en concreto
   PARAM IN PNCODINT    : Código del cuadro de interés que se ha escogido para el producto
   PARAM IN PCTIPO      : Código del tipo de interés.
   PARAM IN PFINICIO    : Fecha inicio vigencia del tramo.
   PARAM IN NDESDE      : Inicio deL tramo
   PARAM OUT NHASTA     : Fin del tramo
   PARAM OUT PNINTTEC   : Porcentaje de interes
   PARAM OUT MENSAJES   : mensajes de error
   *************************************************************************/
   FUNCTION f_getreg_intertecmovdet(
      pncodint IN NUMBER,
      pctipo IN NUMBER,
      pfinicio IN DATE,
      pndesde IN NUMBER,
      pnhasta OUT NUMBER,
      pninttec OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   función que modifica o da de alta un nuevo tramo
   PARAM IN PNCODINT    : Código del cuadro de interés que se ha escogido para el producto
   PARAM IN PCTIPO      : Código del tipo de interés.
   PARAM IN PFINICIO    : Fecha inicio vigencia del tramo.
   PARAM IN NDESDE      : Inicio deL tramo
   PARAM OUT NHASTA     : Fin del tramo
   PARAM OUT PNINTTEC   : Porcentaje de interes
   PARAM OUT MENSAJES   : mensajes de error
   *************************************************************************/
   FUNCTION f_set_intertecmovdet(
      pncodint IN NUMBER,
      pctipo IN NUMBER,
      pfinicio IN DATE,
      pndesde IN NUMBER,
      pnhasta IN NUMBER,
      pninttec IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

/*******BUG8510-07/01/2008-XCG Afegir funcions************************/
 /*************************************************************************
        Función que INSERTA las actividades seleccionadas previamente.
        PARAM IN PCRAMO   : Código del Ramo del producto
        PARAM IN PCMODALI : Código de la Modalidad del producto
        PARAM IN PCTIPSEG : Código del tipo de Seguro del producto
        PARAM IN PCCOLECT : Código del la Colectividad del producto
        PARAM IN PSPRODUC : Código del Identificador del producto
        PARAM IN PCACTIVI : Código de la Actividad
        PARAM IN OUT MENSAJE : mensajes de error
        RETURN NUMBER(0: operación correcta sino num error)
   *************************************************************************/
   FUNCTION f_set_actividades(
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

/*************************************************************************
        Función que retorna un objeto con el recargo del fraccionamiento asignado a una actividad de producto.
        PARAM IN PCRAMO        : Código del Ramo del producto
        PARAM IN PCMODALI      : Código de la Modalidad del producto
        PARAM IN PCTIPSEG      : Código del tipo de Seguro del producto
        PARAM IN PCCOLECT      : Código del la Colectividad del producto
        PARAM IN PSPRODUC      : Código del Identificador del producto
        PARAM IN PCACTIVI      : Código de la Actividad
        PARAM IN OUT PREACTIVI : Tipo T_IAX_PRODRECFRACCACTI, recargo de fraccionamiento, según forma de pago,
                                 de una actividad
        PARAM IN OUT MENSAJE : TIPO T_IAX_MENSAJES mensajes de error
        RETURN NUMBER(0: operación correcta sino num error)
   *************************************************************************/
   FUNCTION f_get_recactividad(
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      preactivi IN OUT t_iax_prodrecfraccacti,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

/*************************************************************************
        Función que retorna un objeto con las preguntas definidas a nivel de una actividad de producto.
        PARAM IN PCRAMO      : Código del Ramo del producto
        PARAM IN PCMODALI    : Código de la Modalidad del producto
        PARAM IN PCTIPSEG    : Código del tipo de Seguro del producto
        PARAM IN PCCOLECT    : Código del la Colectividad del producto
        PARAM IN PSPRODUC    : Código del Identificador del producto
        PARAM IN PCACTIVI    : Código de la Actividad
        PARAM IN  PPREGACTIVI  : Tipo T_IAX_PRODPREGUNACTI, Preuntas definidas a nivel de actividad
        PARAM IN OUT MENSAJE : TIPO T_IAX_MENSAJES mensajes de error
        RETURN NUMBER(0: operación correcta sino num error)
   *************************************************************************/
   FUNCTION f_get_pregactividad(
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      ppregactivi IN OUT t_iax_prodpregunacti,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

/*************************************************************************
        Función que retorna un objeto con las actividades de un producto.
        PARAM IN PCRAMO      : Código del Ramo del producto
        PARAM IN PCMODALI    : Código de la Modalidad del producto
        PARAM IN PCTIPSEG    : Código del tipo de Seguro del producto
        PARAM IN PCCOLECT    : Código del la Colectividad del producto
        PARAM IN PSPRODUC    : Código del Identificador del producto
        PARAM IN PCACTIVI    : Código de la Actividad
        PARAM IN PPRODACTIVI : Tipo T_IAX_PRODACTIVIDADES
        PARAM IN OUT MENSAJE : TIPO T_IAX_MENSAJES mensajes de error
        RETURN NUMBER(0: operación correcta sino num error)
   *************************************************************************/
   FUNCTION f_get_actividades(
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pprodactivi IN OUT t_iax_prodactividades,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

/*************************************************************************
        Función que inserta datos de la forma de pago y recargo por actividad.
        PARAM IN PCRAMO      : Código del Ramo del producto
        PARAM IN PCMODALI    : Código de la Modalidad del producto
        PARAM IN PCTIPSEG    : Código del tipo de Seguro del producto
        PARAM IN PCCOLECT    : Código del la Colectividad del producto
        PARAM IN PSPRODUC    : Código del Identificador del producto
        PARAM IN PCACTIVI    : Código de la Actividad
        PARAM IN PCFORPAG    : Código de la forma de pago
        PARAM IN PPRECARG    : Porcentage del recargo
        PARAM IN OUT MENSAJE : TIPO T_IAX_MENSAJES mensajes de error
        RETURN NUMBER(0: operación correcta sino num error)
   *************************************************************************/
   FUNCTION f_set_recactividad(
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcforpag IN NUMBER,
      pprecarg IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

/*************************************************************************
        Función que se utiliza para comprobar si existen pólizas de una actividad definida en un producto
        PARAM IN PSPRODUC    : Código del Identificador del producto
        PARAM IN PCACTIVI    : Código de la Actividad
        PARAM OUT NERROR     : Código de error
        PARAM IN OUT MENSAJE : TIPO T_IAX_MENSAJES mensajes de error
        RETURN NUMBER(0: operación correcta sino num error)
   *************************************************************************/
   FUNCTION f_exist_actpol(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

/*************************************************************************
        Función que inserta preguntas por producto y actividad.
        PARAM IN PCRAMO      : Código del Ramo del producto
        PARAM IN PCMODALI    : Código de la Modalidad del producto
        PARAM IN PCTIPSEG    : Código del tipo de Seguro del producto
        PARAM IN PCCOLECT    : Código del la Colectividad del producto
        PARAM IN PSPRODUC    : Código del Identificador del producto
        PARAM IN PCACTIVI    : Código de la Actividad
        PARAM IN PCPREGUN    : Código de pregunta
        PARAM IN PCPRETIP    : Código tipo de respuesta (manual,automática) valor fijo: 787
        PARAM IN PNPREORD    : Número de orden en el que se pregunta
        PARAM IN PTPREFOR    : Fórmula para plantear la pregunta
        PARAM IN PCPREOBL    : Obligatorio (Sí-1,No-0)
        PARAM IN PNPREIMP    : Orden de impresión
        PARAM IN PCRESDEF    : Respuesta por defecto
        PARAM IN PCOFERSN    : Código: Aparece en ofertas? (Sí-1,No-0)
        PARAM IN PTVALOR     : Fórmula para validar la respuesta
        PARAM IN OUT MENSAJE : TIPO T_IAX_MENSAJES mensajes de error
        RETURN NUMBER(0: operación correcta sino num error)
 *************************************************************************/
   FUNCTION f_set_pregactividad(
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcpregun IN NUMBER,
      pcpretip IN NUMBER,
      pnpreord IN NUMBER,
      ptprefor IN VARCHAR2,
      pcpreobl IN NUMBER,
      pnpreimp IN NUMBER,
      pcresdef IN NUMBER,
      pcofersn IN NUMBER,
      ptvalfor IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

/*************************************************************************
        Función que se utiliza para borrar la actividad definida en un producto
        PARAM IN PSPRODUC    : Código del Identificador del producto
        PARAM IN PCACTIVI    : Código de la Actividad
        PARAM OUT NERROR     : Código de error
        PARAM IN OUT MENSAJE : TIPO T_IAX_MENSAJES mensajes de error
        RETURN NUMBER(0: operación correcta sino num error)
   *************************************************************************/
   FUNCTION f_borrar_actividades(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

/*************************************************************************
        Función que duplica actividad.
        PARAM IN PCRAMO      : Código del Ramo del producto
        PARAM IN PCMODALI    : Código de la Modalidad del producto
        PARAM IN PCTIPSEG    : Código del tipo de Seguro del producto
        PARAM IN PCCOLECT    : Código del la Colectividad del producto
        PARAM IN PSPRODUC    : Código del Identificador del producto
        PARAM IN PCACTIVI    : Código de la Actividad
        PARAM IN PCACTIVIC   : Código de la Actividad destino
        PARAM IN OUT MENSAJE : TIPO T_IAX_MENSAJES mensajes de error
        RETURN NUMBER        : Código de error (0: operación correcta sino 1)
  **********************************************************************/
   FUNCTION f_duplicar_actividades(
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcactivic IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

/*******FI BUG8510***********************/

   /*************************************************************************
         Función para asignar cláusulas de beneficiario al producto
         PARAM IN PSPRODUC    : Código del Identificador del producto
         PARAM IN PSCLABEN    : Código de la clausula
         PARAM OUT MENSAJES   : Mensajes de error
         RETURN NUMBER        : Código de error (0: operación correcta sino 1)

         Bug 10557   29/06/2009  AMC
   **********************************************************************/
   FUNCTION f_set_benefpro(psproduc IN NUMBER, psclaben IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
         Función para asignar una cláusula de beneficiario por defecto al producto
         PARAM IN PSPRODUC    : Código del Identificador del producto
         PARAM IN PSCLABEN    : Código de la clausula
         RETURN NUMBER        : Código de error (0: operación correcta sino 1)

         Bug 10557   29/06/2009  AMC
   **********************************************************************/
   FUNCTION f_set_benefdefecto(
      psproduc IN NUMBER,
      psclaben IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
         Función que retorna las cláusulas de beneficirio no asignadas a un producto
         PARAM IN PSPRODUC    : Código del Identificador del producto
         PARAM OUT MENSAJES   : Mensajes de error
         RETURN NUMBER        : Código de error (0: operación correcta sino 1)

         Bug 10557   29/06/2009  AMC
   **********************************************************************/
   FUNCTION f_get_benef_noasig(psproduc IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

     /*************************************************************************
         Función que se utiliza para desasignar una cláusula del producto
         PARAM IN PSPRODUC    : Código del Identificador del producto
         PARAM IN PSCLABEN    : Código de la clausula
         PARAM OUT PNERROR    : Código del error
         PARAM OUT MENSAJES   : Mensajes de error
         RETURN NUMBER        : Código de error (0: operación correcta sino 1)

         Bug 10557   29/06/2009  AMC
   **********************************************************************/
   FUNCTION f_del_benefpro(
      psproduc IN NUMBER,
      psclaben IN NUMBER,
      pnerror OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
          Función que asigna una garantia a un producto
          PARAM IN PSPRODUC    : Código del Identificador del producto
          PARAM IN PCGARANT    : Código de la garantia
          PARAM IN PCACTIVI    : Código de la actividad
          PARAM IN PNORDEN     : Numero de orden
          PARAM IN PCTIPGAR    : Código de tipo de garantia
          PARAM IN PCTIPCAR    : Código de tipo de capital
          PARAM IN OUT MENSAJES   : Mensajes de error
          RETURN NUMBER

          Bug 14284   26/04/2010  AMC
    **********************************************************************/
   FUNCTION f_set_garantiaprod(
      psproduc IN NUMBER,
      pcgarant IN NUMBER,
      pcactivi IN NUMBER,
      pnorden IN NUMBER,
      pctipgar IN NUMBER,
      pctipcap IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
         Función que devuelve la lista de parametro por garantia
         PARAM IN PCIDIOMA    : Código de idioma
         PARAM IN OUT MENSAJES   : Mensajes de error
         RETURN sys_refcursor

         Bug 14284   29/04/2010  AMC
   **********************************************************************/
   FUNCTION f_get_pargarantia(pcidioma IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
         Función que retorna el tipo de respuesta y la lista de valores de un parametro
         PARAM IN PCPARGAR    : codigo del parametro
         PARAM IN PCIDIOMA    : Código del idioma
         PARAM OUT PCTIPO     : tipo de respuesta
         PARAM OUT PLISTRESP  : lista de posibles respuestas
         PARAM IN OUT MENSAJES   : Mensajes de error
         RETURN sys_refcursor

         Bug 14284   29/04/2010  AMC
   **********************************************************************/
   FUNCTION f_get_valpargarantia(
      pcpargar IN VARCHAR2,
      pcidioma IN NUMBER,
      pctipo OUT NUMBER,
      plistresp OUT sys_refcursor,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Inicializa las listas de capitales de una garantia
      param in psproduc  : codigo del producto
      param in pcgarant  : codigo de la garantia
      param in pcactivi  : codigo de la actividad
      param out pcapitales :coleccion con los capitales
      param out mensajes : mensajes de error
      return             : 0 todo ha sido correcto
                           1 ha habido un error

     Bug 14284 - 05/05/2010 - AMC
   *************************************************************************/
   FUNCTION f_inicializa_capital(
      psproduc IN NUMBER,
      pcgarant IN NUMBER,
      pcactivi IN NUMBER,
      pcapitales OUT t_iax_prodgaranprocap,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Baja la lista de capitales a BB.DD
      param in psproduc  : codigo del producto
      param in pcgarant  : codigo de la garantia
      param in pcactivi  : codigo de la actividad
      param in pcapitales : lista de capitales a guardar
      param out          : mensajes de error
      return             : 0 todo ha sido correcto
                           1 ha habido un error

     Bug 14284 - 05/05/2010 - AMC
   *************************************************************************/
   FUNCTION f_set_capitales(
      psproduc IN NUMBER,
      pcgarant IN NUMBER,
      pcactivi IN NUMBER,
      pcapitales IN t_iax_prodgaranprocap,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
         Función que actualiza los datos generales de la garantia
         param in psproduc  : codigo del producto
         param in pcgarant  : codigo de la garantia
         param in pcactivi  : codigo de la actividad
         param in pnorden   : numero de orden
         param in pctipgar  : codigo tipo de garantia
         param in pctipcap  : codigo tipo de capital
         param in pcgardep  : codigo garantia dependiente
         param in pcpardep  : codigo parametro dependiente
         param in pcvalpar  : valor parametro dependiente
         param in pctarjet
         param in pcbasica
         param in picapmax  : importe capital maximo
         param in pccapmax  : codigo capital maximo
         param in pcformul  : codigo de formula
         param in pcclacap  :
         param in picaprev  : capital de revision
         param in ppcapdep  :
         param in piprimin  : prima minima
         param in piprimax  : capital maximo
         param in picapmin  : capital minimo
         param in out mensajes : mensajes de error
         RETURN number

         Bug 14284   07/05/2010  AMC
   **********************************************************************/
   FUNCTION f_set_datosgen(
      psproduc IN NUMBER,
      pcgarant IN NUMBER,
      pcactivi IN NUMBER,
      pnorden IN NUMBER,
      pctipgar IN NUMBER,
      pctipcap IN NUMBER,
      pcgardep IN NUMBER,
      pcpardep IN VARCHAR2,
      pcvalpar IN NUMBER,
      pctarjet IN NUMBER,
      pcbasica IN NUMBER,
      picapmax IN NUMBER,
      pccapmax IN NUMBER,
      pcformul IN NUMBER,
      pcclacap IN NUMBER,
      picaprev IN NUMBER,
      ppcapdep IN NUMBER,
      piprimin IN NUMBER,
      piprimax IN NUMBER,
      pccapmin IN NUMBER,
      picapmin IN NUMBER,
      pcclamin IN NUMBER,
      pcmoncap IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /**********************************************************************
         Función que borrar una garantia asignada a un producto
         param in psproduc  : codigo del producto
         param in pcgarant  : codigo de la garantia
         param in pcactivi  : código de la actividad
         param in mensajes  : mensajes de error
         RETURN number

         Bug 14723 -  25/05/2010 - AMC
   **********************************************************************/
   FUNCTION f_del_garantia(
      psproduc IN NUMBER,
      pcgarant IN NUMBER,
      pcactivi IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
         Función que actualiza los datos generales de la garantia
         param in psproduc  : codigo del producto
         param in pcgarant  : codigo de la garantia
         param in pcactivi  : codigo de la actividad
         param in pciedmic  : Ind. si se valida la 0-edad actuarial 1-edad real. Edad Min. Ctnr.
         param in pnedamic  : Edad mínima de contratación
         param in pciedmac  : Ind. si se valida la 0-edad actuarial 1-edad real. Edad Max. Ctnr.
         param in pnedamac, : Edad máxima de contratación
         param in pciedmar  : Ind. si se valida la 0-edad actuarial 1-edad real. Edad Max. Renov.
         param in pnedamar  : Edad máxima de renovación
         param in pciemi2c  : Ind. si se valida la 0-edad actuarial 1-edad real. Cuando se informa Edad Min. Ctnr. 2ºAsegurado
         param in pnedmi2c, : Edad Min. Ctnr. 2ºAsegurado
         param in pciema2c, : Ind. si se valida la 0-edad actuarial 1-edad real. Cuando se informa Edad Max. Ctnr. 2ºAsegurado
         param in pnedma2c  : Edad Max. Ctnr. 2ºAsegurado
         param in pciema2r  : Ind. si se valida la 0-edad actuarial 1-edad real. Cuando se informa Edad Max. Renov. 2ºAsegurado
         param in pnedma2r  : Edad Max. Renov. 2ºAsegurado
         param in pcreaseg
         param in pcrevali  : Tipo de revalorización
         param in pctiptar  : Tipo de tarifa (lista de valores)
         param in pcmodrev  : Se puede modificar la revalorización
         param in pcrecarg  : Se puede añadir un recargo
         param in pcdtocom  : Admite descuento comercial
         param in pctecnic
         param in pcofersn
         param in pcextrap  : Se puede modificar la extraprima
         param in pcderreg
         param in pprevali  : Porcentaje de revalorización
         param in pirevali  : Importe de revalorización
         param in pcrecfra
         param in pctarman
         param in pnedamrv : Edad máxima de revalorización
         param in pciedmrv : Ind. si se valida la 0-edad actuarial 1-edad real. Edad Max. Revalorización
         param out mensajes : mensajes de error
         RETURN number

         Bug 14748   04/06/2010  AMC
   **********************************************************************/
   FUNCTION f_set_datosges(
      psproduc IN NUMBER,
      pcgarant IN NUMBER,
      pcactivi IN NUMBER,
      pciedmic IN NUMBER,
      pnedamic IN NUMBER,
      pciedmac IN NUMBER,
      pnedamac IN NUMBER,
      pciedmar IN NUMBER,
      pnedamar IN NUMBER,
      pciemi2c IN NUMBER,
      pnedmi2c IN NUMBER,
      pciema2c IN NUMBER,
      pnedma2c IN NUMBER,
      pciema2r IN NUMBER,
      pnedma2r IN NUMBER,
      pcreaseg IN NUMBER,
      pcrevali IN NUMBER,
      pctiptar IN NUMBER,
      pcmodrev IN NUMBER,
      pcrecarg IN NUMBER,
      pcdtocom IN NUMBER,
      pctecnic IN NUMBER,
      pcofersn IN NUMBER,
      pcextrap IN NUMBER,
      pcderreg IN NUMBER,
      pprevali IN NUMBER,
      pirevali IN NUMBER,
      pcrecfra IN NUMBER,
      pctarman IN NUMBER,
      pnedamrv IN NUMBER,
      pciedmrv IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Recupera las garantias que peden ser incompatibles
      param in psproduc     : código del producto
      param in pcactivi     : código de la actividad
      param in pcgarant     : código de la garantia
      param in out mensajes   : mensajes de error
      RETURN sys_refcursor

      -- Bug 15023 - 16/06/2010 - AMC
   *************************************************************************/
   FUNCTION f_get_lstgarincompatibles(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
         Función que inserta en incompgaran
         PARAM IN PSPRODUC     : codigo del producto
         PARAM IN PCGARANT    : codigo de la garantia
         PARAM IN PCGARANT    : codigo de la garantia incompatible
         PARAM IN PCACTIVI    : codigo de la actividad
         PARAM IN OUT MENSAJES   : mensajes de error

         RETURN NUMBER

         Bug 15023   16/06/2010  AMC
   **********************************************************************/
   FUNCTION f_set_incompagar(
      psproduc IN NUMBER,
      pcgarant IN NUMBER,
      pcgarinc IN NUMBER,
      pcactivi IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
         Función que borra de incompgaran
         PARAM IN PSPRODUC     : codigo del producto
         PARAM IN PCGARANT    : codigo de la garantia
         PARAM IN PCGARANT    : codigo de la garantia incompatible
         PARAM IN PCACTIVI    : codigo de la actividad
         PARAM IN OUT MENSAJES   : mensajes de error

         RETURN NUMBER

         Bug 15023   16/06/2010  AMC
   **********************************************************************/
   FUNCTION f_del_incompagar(
      psproduc IN NUMBER,
      pcgarant IN NUMBER,
      pcgarinc IN NUMBER,
      pcactivi IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
          Función que actualiza los datos tecnicos de la garantia
          param in psproduc  : codigo del producto
          param in pcgarant  : codigo de la garantia
          param in pcactivi  : codigo de la actividad
          param in pcramdgs  : código del ramo de la dgs
          param in pctabla   : código de la tabla de mortalidad
          param in precseg   : % recargo de seguridad
          param in nparben   : participación en beneficios
          param in cprovis   : Tipo de provision
          param in out mensajes   : mensajes de error

          RETURN number

          Bug 15148 - 21/06/2010 - AMC
    **********************************************************************/
   FUNCTION f_set_datostec(
      psproduc IN NUMBER,
      pcgarant IN NUMBER,
      pcactivi IN NUMBER,
      pcramdgs IN NUMBER,
      pctabla IN NUMBER,
      pprecseg IN NUMBER,
      pnparben IN NUMBER,
      pcprovis IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Borra la formula de una garantia
      param in psproduc    : código del producto
      param in pcactivi    : código de la actividad
      param in pcgarant    : código de la garantía
      param in pccampo     : código del campo
      param in pclave      : clave fórmula
      param out mensajes   : mensajes de error
      return               : 0 si ha ido bien
                            numero error si ha ido mal

      Bug 15149 - 29/06/2010 - AMC
   *************************************************************************/
   FUNCTION f_del_prodgarformulas(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pccampo IN VARCHAR2,
      pclave IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
         Inserta un nuevo producto en la tabla PRODUCTOS
         param in pcramo    : codigo del ramo
         param in pcmodali  : codigo de la modalidad
         param in pctipseg  : codigo del tipo de seguro
         param in pccolect  : codigo de colectividad
         param in pcagrpro  : codigo agrupacion de producto
         param in pttitulo  : titulo del producto
         param in ptrotulo  : abreviacion del titulo
         param in pcsubpro  : codigo de subtipo de producto
         param in pctipreb  : recibo por.
         param in pctipges  : gestion del seguro
         param in pctippag  : cobro
         param in pcduraci  : codigo de la duración
         param in pctarman  : tarificacion puede ser manual
         param in pctipefe  : tipo de efecto
         param out psproduct_out  : codigo del producto insertado
         param out mensajes  : mensajes de error

         Bug 15513 - 23/07/2010 - PFA
   *************************************************************************/
   FUNCTION f_alta_producto(
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pcagrpro IN NUMBER,
      pttitulo IN VARCHAR2,
      ptrotulo IN VARCHAR2,
      pcsubpro IN NUMBER,
      pctipreb IN NUMBER,
      pctipges IN NUMBER,
      pctippag IN NUMBER,
      pcduraci IN NUMBER,
      pctarman IN NUMBER,
      pctipefe IN NUMBER,
      psproduc_copy IN NUMBER,
      pparproductos IN NUMBER,
      psproduc_out OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

          /*************************************************************************
         Función que retorna els documentos d'un producte
         param in psproduc  : codigo del producto

         RETURN sys_refcursor

         Bug 14284   29/04/2010  AMC
   **********************************************************************/
   FUNCTION f_get_documentos(psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
            Función que retorna las duraciones de cobro de un producto
            param in psproduc  : codigo del producto

            RETURN t_iax_durcobroprod

            Bug 22253   17/05/2012   MDS
      **********************************************************************/
   FUNCTION f_get_durcobroprod(psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_durcobroprod;

   /*************************************************************************
      Recupera los datos de los planes de pensiones para ese producto
      param in psproduc  : código producto
      param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_get_planpensiones(psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_planpensiones;

   /*************************************************************************
      Recupera los datos de la tabla int_codigos_emp para ese producto
      param in psproduc  : código producto
      param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_get_interficies(psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_interficies;

   /**************************************************************************
     Assigna un pla de pensió per un producte. Si existe, lo actualiza
     param in psproduc     : Codigo del producto
     param in pccodpla    : Codigo del plan de pensión
   **************************************************************************/
   FUNCTION f_set_planpension(
      psproduc IN NUMBER,
      pccodpla IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
         Función que busca en la tabla int_codigos_emp
         PARAM IN CCODIGO     : codigo de la interfaz
         PARAM IN CVALAXIS    : valor del campo en axis
         PARAM IN CVALEMP    : valor del campo en la empresa
         PARAM OUT MENSAJES   : mensajes de error

         RETURN NUMBER

         Bug 15023   01/11/2013  LPP
   **********************************************************************/
   FUNCTION f_get_interficie(
      pccodigo IN VARCHAR2,
      pcvalaxis IN VARCHAR2,
      pcvalemp IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_interficies;

   /*************************************************************************
         Función que mantiene la tabla int_codigos_emp
         PARAM IN CCODIGO     : codigo de la interfaz
         PARAM IN CVALAXIS    : valor del campo en axis
         PARAM IN CVALEMP    : valor del campo en la empresa
         PARAM IN CVALDEF    : valor del campo en axis, por si cvalaxis tiene mas de un valor
         PARAM IN CVALAXISDEF : valor del campo en la empresa, por si cvalaxisdef tiene mas de un valor
         PARAM OUT MENSAJES   : mensajes de error

         RETURN NUMBER

         Bug 15023   01/11/2013  LPP
   **********************************************************************/
   FUNCTION f_set_interficie(
      pccodigo IN VARCHAR2,
      pcvalaxis IN VARCHAR2,
      pcvalemp IN VARCHAR2,
      pcvaldef IN VARCHAR2,
      pcvalaxisdef IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
         Función que borra de la tabla int_codigos_emp
         PARAM IN CCODIGO     : codigo de la interfaz
         PARAM IN CVALAXIS    : valor del campo en axis
         PARAM OUT MENSAJES   : mensajes de error

         RETURN NUMBER

         Bug 15023   01/11/2013  LPP
   **********************************************************************/
   FUNCTION f_del_interficie(
      pccodigo IN VARCHAR2,
      pcvalaxis IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

      /**************************************************************************
      función que graba el fondo correspondiente a  un modelo de inversión recibido por parámetro para un idioma.
      param in psproduc      :
      param in pccodfon     :
      param in pinvers     :
      param in pcmodinv     :
      param in pmaxcont     :
      **************************************************************************/
   /* FUNCTION f_set_modinvfondo(
     psproduc IN NUMBER,
    pccodfon IN NUMBER,
    pinvers IN NUMBER,
    pcmodinv IN NUMBER,
    pmaxcont IN NUMBER,
    mensajes IN OUT T_IAX_MENSAJES
    ) RETURN NUMBER;
     */

   /**************************************************************************
    ffunción que recupera los fondos asociados al modelo que se ha recibido por parámetro.
    param in psproduc      :
    param in pcmodinv      :
    param in pmodelo      :
    param in mensajes      :
    **************************************************************************/
   FUNCTION f_get_modelinv(
      psproduc IN NUMBER,
      pcmodinv IN NUMBER,
      pmodelo IN t_iax_produlkmodelosinv,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /**************************************************************************
    función que graba el modelo recibido por parámetro para un idioma.
    param in psproduc      :
    param in pcmodinv     :
    param in pmodelo     :
    param in mensajes     :
    **************************************************************************/
   FUNCTION f_set_modelinv(
      psproduc IN NUMBER,
      pcmodinv IN NUMBER,
      pcidioma IN NUMBER,
      ptmodinv IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

      /**************************************************************************
       función que recupera los fondos asociados a un modelo de inversión.
       param in psproduc      :
       param in pcmodinv     :
       param in mensajes     :
       **************************************************************************/
   /*  FUNCTION  f_get_modinvfondo(
       psproduc IN NUMBER,
      pcmodinv IN NUMBER,
       mensajes IN OUT T_IAX_MENSAJES
     )RETURN T_IAX_PRODULKMODINVFONDO;*/
       /**************************************************************************
       función que recupera los fondos asociados y no asociados a un modelo de inversión.
       param in psproduc      :
       param in pcmodinv     :
       param in mensajes     :
       **************************************************************************/
   FUNCTION f_get_modinvfondos(
      psproduc IN NUMBER,
      pcmodinv IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_produlkmodinvfondo;

   /**************************************************************************
   función que recupera los fondos asociados y no asociados a un modelo de inversión.
   param in psproduc      :
   param in pcmodinv     :
   param in mensajes     :
   **************************************************************************/
   FUNCTION f_get_modinvfondos2(
      psproduc IN NUMBER,
      pcmodinv IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_produlkmodinvfondo;

   /**************************************************************************
   función que modifica o inserta los fondos asociados y no asociados a un modelo de inversión.
   param in psproduc      :
   param in pcmodinv     :
   param in mensajes     :
   **************************************************************************/
   FUNCTION f_set_modinvfondos(
      psproduc IN NUMBER,
      pcmodinv IN NUMBER,
      pfondo IN t_iax_produlkmodinvfondo,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /**************************************************************************
    función que borra el fondo correspondiente a  un modelo de inversión recibido por parámetro
    param in pccodfon    :
    param in pinvers    :
    param in out mensajes    :
    **************************************************************************/
   FUNCTION f_del_modinvfondos(
      pccodfon IN NUMBER,
      pcmodinv IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_modinvfondosseg(pcmodinv IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN t_iax_produlkmodinvfondo;
END pac_md_mntprod;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_MNTPROD" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_MNTPROD" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_MNTPROD" TO "PROGRAMADORESCSI";
