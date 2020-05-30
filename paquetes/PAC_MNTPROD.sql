--------------------------------------------------------
--  DDL for Package PAC_MNTPROD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MNTPROD" AS
/******************************************************************************
   NOMBRE:       PAC_MNTPROD
   PROPÓSITO:  Mantenimiento productos. gestión

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        14/04/2008   JRB                1. Creación del package.
   2.0        29/12/2008   XCG                2. Modificació package. (8510) afegir i/o modificar funcions
   3.0        29/06/2009   AMC                3. Se añaden nuevas funciones bug 10557
   4.0        05/05/2010   AMC                4. Bug 14284. Se añaden nuevas funciones.
   5.0        27/05/2010   AMC                5. Se añade la función f_del_garantia bug 14723
   6.0        07/06/2010   PFA                6. Se cran las funciones f_insert_companipro , f_delete_companipro -- BUG 14750
   7.0        04/06/2010   AMC                7. Se añaden nuevas funciones bug 14748
   8.0        16/06/2010   AMC                8. Se añaden nuevas funciones bug 15023
   9.0        21/06/2010   AMC                9. Se añaden nuevas funciones bug 15148
   10.0       29/06/2010   AMC                10. Se añaden nuevas funciones bug 15149
   11.0       23/07/2010   PFA                11. 15513: MDP - Alta de productos
   12.0       15/12/2010   LCF                12. 16684: Anyadir ccompani para productos especiales
   13.0       08/05/2012   APD                13. 0022049: MDP - TEC - Visualizar garantías y sub-garantias
   14.0       17/05/2012   MDS                14. 0022253: LCOL - Duración del cobro como campo desplegable
   15.0       23/01/2014   AGG                15. 0027306: POSS518 (POSSF200)- Resolucion de Incidencias FASE 1-2: Tecnico - VI - Temporales anuales renovables
   16.0       18/02/2014   DEV                16. 0029920: POSFC100-Taller de Productos
   17.0       25/09/2014   JTT                17. 0032620: Añadimos el parametro cprovis a la funcion f_set_datostec
                                                  0032367: Añadimos el parametro cnv_spr a la funcion F_set_admprod i F_valida_admprod
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

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
      psproducesp IN NUMBER)
      RETURN NUMBER;

   /**************************************************************************
     Borra un registro de la tabla companipro.
     param in psproduc     : Codigo del producto
     param in pccompani    : Codigo de la compania
   **************************************************************************/
   FUNCTION f_delete_companipro(psproduc IN NUMBER, pccompani IN NUMBER, psproducesp IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
       Valida los datos generales de un producto
       param in psproduc   : código del producto
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
       return              : 0 si ha ido bien
                             numero error si ha ido mal
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
      pcompani IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
      Inserta o modifica los datos de un producto
      param in psproduc   : código del producto
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
      return              : 0 si ha ido bien
                            numero error si ha ido mal
   *************************************************************************/
   FUNCTION f_set_datosgenerales(
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
      pcprprod IN NUMBER,
      pcompani IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
      Inserta o modifica la descripción del producto
      param in pcramo      : código del ramo
      param in pcmodali    : código de la modalidad
      param in pctipseg    : código del tipo de seguro
      param in pccolect    : código de colectividad
      param in pcidioma    : código de idioma
      param in ptrotulo    : Abreviación del título
      param in pttitulo    : Título del producto
      return               : 0 si ha ido bien
                            numero error si ha ido mal
   *************************************************************************/
   FUNCTION f_set_prodtitulo(
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pcidioma IN NUMBER,
      ptrotulo IN VARCHAR2,
      pttitulo IN VARCHAR2)
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
      pcctacor IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
       Graba los datos de gestión de un producto
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
      pcpreaviso IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
      Realiza las validaciones de los datos de administración del producto
      param in pcempres    : código de la empresa.
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
      retorna un cero si todo va bien  y un uno en caso contrario
   *************************************************************************/
   FUNCTION f_valida_admprod(
      pcempres IN NUMBER,
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
      pcnv_spr IN VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
      Realiza las  modificaciones de los datos de administración del producto
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
      pcnv_spr IN VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
      Valida la forma de pago
      param in psproduc   : código del producto
      param in pcforpag   : código de la forma de pago
      param in pcobliga   : código de obligatoriedad
      param in pprecarg   : código precarg
      param in pcpagdef   : código pago por defecto
      param in pcrevfpg   : código revfpg
      return              : 0 si ha ido bien
                            numero error si ha ido mal
   *************************************************************************/
   FUNCTION f_validaforpago(
      psproduc IN NUMBER,
      pcforpag IN NUMBER,
      pcobliga IN NUMBER,
      pprecarg IN NUMBER,
      pcpagdef IN NUMBER,
      pcrevfpg IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
      Modifica las forma de pago de un producto
      param in psproduc   : código del producto
      param in pcforpag   : código de la forma de pago
      param in pcobliga   : código de obligatoriedad
      param in pprecarg   : código precarg
      param in pcpagdef   : código pago por defecto
      param in pcrevfpg   : código revfpg
      return              : 0 si ha ido bien
                            numero error si ha ido mal
   *************************************************************************/
   FUNCTION f_setforpago(
      psproduc IN NUMBER,
      pcforpag IN NUMBER,
      pcobliga IN NUMBER,
      pprecarg IN NUMBER,
      pcpagdef IN NUMBER,
      pcrevfpg IN NUMBER)
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
      pcimpfng IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
       Inserta o modifica la formula de una garantia
       param in Psproduc      : código del producto
       param in Pcactivi    : código de la actividad
       param in Pcgarant    : código de la garantía
       param in Pccampo    : código del campo
       param in Pclave    : clave fórmula
       return               : 0 si ha ido bien
                             numero error si ha ido mal
   *************************************************************************/
   FUNCTION f_set_prodgarformulas(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pccampo IN VARCHAR2,
      pclave IN NUMBER)
      RETURN NUMBER;

/*************************************************************************
    Función que validará los datos técnicos de un producto en concreto
    PARAM IN Psproduc: Código del producto
    PARAM IN pnniggar: Indicar de si los gastos están a nivel de garantía
    PARAM IN pnniigar: Indicador de si el interés técnico está a nivel de garantía
    PARAM IN pcmodint: Intereses tecnicos modificables en póliza.
    PARAM IN pcintrev: Por defecto en renovación aplicar el interés del producto
    PARAM IN pncodint: Código del cuadro de interés que se ha escogido para el producto
    RETURN  :0 si todo ha ido bien,número de error en caso contrario
*************************************************************************/
   FUNCTION f_validadattecn(
      psproduc IN NUMBER,
      pnniggar IN NUMBER,
      pnniigar IN NUMBER,
      pcmodint IN NUMBER,
      pcintrev IN NUMBER,
      pncodint IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
   Función que modificará los datos técnicos de un producto en concreto
   PARAM IN Psproduc: Código del producto. Parámetro de entrada
   PARAM IN pnniggar: Indicar de si los gastos están a nivel de garantía Parámetro de entrada
   PARAM IN pnniigar: Indicador de si el interés técnico está a nivel de garantía. Parámetro de entrada
   PARAM IN pcmodint: Intereses tecnicos modificables en póliza.
   PARAM IN pcintrev: Por defecto en renovación aplicar el interés del producto
   PARAM IN pncodint: Código del cuadro de interés que se ha escogido para el producto
   RETURN  :0 si todo ha ido bien,número de error en caso contrario
   *************************************************************************/
   FUNCTION f_set_dattecn(
      psproduc IN NUMBER,
      pnniggar IN NUMBER,
      pnniigar IN NUMBER,
      pcmodint IN NUMBER,
      pcintrev IN NUMBER,
      pncodint IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
   Función que se encargará de borrar un cuadro de interés técnico
   PARAM IN PNCODINT  : Código del cuadro de interés
   PARAM OUT mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_del_intertec(pncodint IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
    Función que se encargará de borrar una vigencia de un cuadro de interés técnico
    PARAM IN PNCODINT  : Código del cuadro de interés
    PARAM IN PCTIPO    : Código del tipo de interés.
    PARAM IN PFINICIO  : Fecha inicio vigencia del tramo.
    PARAM OUT mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_del_intertecmov(pncodint IN NUMBER, pctipo IN NUMBER, pfinicio IN DATE)
      RETURN NUMBER;

   FUNCTION f_del_intertecmovdet(
      pncodint IN NUMBER,
      pctipo IN NUMBER,
      pfinicio IN DATE,
      pndesde IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
        Función que validará la inserción o modificación de una vigencia
        PARAM IN PNCODINT  : Código del cuadro de interés
        PARAM IN PCTIPO    : Código del tipo de interés.
        PARAM IN PFINICIO  : Fecha inicio vigencia del tramo.
        PARAM IN PFFIN     : Fecha fin vigencia del tramo.
        PARAM IN PCTRAMTIP : Concepto del tramo
   *************************************************************************/
   FUNCTION f_valida_intertecmov(
      pncodint IN NUMBER,
      pctipo IN NUMBER,
      pfinicio IN DATE,
      pffin IN DATE,
      pctramtip IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
        Función que insertar o modifica los valores de una vigencia para un cuadro de interes
        PARAM IN PNCODINT  : Código del cuadro de interés
        PARAM IN PCTIPO    : Código del tipo de interés.
        PARAM IN PFINICIO  : Fecha inicio vigencia del tramo.
        PARAM IN PFFIN     : Fecha fin vigencia del tramo.
        PARAM IN PCTRAMTIP : Concepto del tramo
   *************************************************************************/
   FUNCTION f_set_intertecmov(
      pncodint IN NUMBER,
      pctipo IN NUMBER,
      pfinicio IN DATE,
      pffin IN DATE,
      pctramtip IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
        Función que valida los datos de un tramo de interes.
        PARAM IN PNCODINT : Código del cuadro de interés
        PARAM IN PCTIPO   : Código del tipo de interés
        PARAM IN PFINICIO : Fecha inicio vigencia del tramo
        PARAM IN PNDESDE  : Importe/Edad Desde
        PARAM IN PNHASTA  : Importe/Edad Hasta
        PARAM IN PNINTTEC : Porcentaje
   *************************************************************************/
   FUNCTION f_valida_intertecmovdet(
      pncodint IN NUMBER,
      pctipo IN NUMBER,
      pfinicio IN DATE,
      pndesde IN NUMBER,
      pnhasta IN NUMBER,
      pninttec IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
         Función que INSERTA/MODIFICA los datos de un tramo de interes.
         PARAM IN PNCODINT : Código del cuadro de interés
         PARAM IN PCTIPO   : Código del tipo de interés
         PARAM IN PFINICIO : Fecha inicio vigencia del tramo
         PARAM IN PNDESDE  : Importe/Edad Desde
         PARAM IN PNHASTA  : Importe/Edad Hasta
         PARAM IN PNINTTEC : Porcentaje
    *************************************************************************/
   FUNCTION f_set_intertecmovdet(
      pncodint IN NUMBER,
      pctipo IN NUMBER,
      pfinicio IN DATE,
      pndesde IN NUMBER,
      pnhasta IN NUMBER,
      pninttec IN NUMBER)
      RETURN NUMBER;

    /*******BUG8510-29/12/2008-XCG Afegir funcions***************************/
   /*************************************************************************
          Función que INSERTA las actividades seleccionadas previamente.
          PARAM IN PCRAMO   : Código del Ramo del producto
          PARAM IN PCMODALI : Código de la Modalidad del producto
          PARAM IN PCTIPSEG : Código del tipo de Seguro del producto
          PARAM IN PCCOLECT : Código del la Colectividad del producto
          PARAM IN PSPRODUC : Código del Identificador del producto
          PARAM IN PCACTIVI : Código de la Actividad
          RETURN NUMBER     : número de error (0: operación correcta sino num error)
     *************************************************************************/
   FUNCTION f_set_actividades(
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER)
      RETURN NUMBER;

/*************************************************************************
        Función que retorna un objeto con el recargo del fraccionamiento asignado a una actividad de producto.
        PARAM IN PCRAMO      : Código del Ramo del producto
        PARAM IN PCMODALI    : Código de la Modalidad del producto
        PARAM IN PCTIPSEG    : Código del tipo de Seguro del producto
        PARAM IN PCCOLECT    : Código del la Colectividad del producto
        PARAM IN PSPRODUC    : Código del Identificador del producto
        PARAM IN PCACTIVI    : Código de la Actividad
        PARAM IN PCIDIOMA    : Código del Idioma
        PARAM OUT PRETCURSOR : SYS_REFCURSOR
        RETURN NUMBER        : número de error (0: operación correcta sino num error)
   *************************************************************************/
   FUNCTION f_get_recactividad(
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcidioma IN NUMBER,
      pretcursor IN OUT sys_refcursor)
      RETURN NUMBER;

/*************************************************************************
        Función que retorna un objeto con las preguntas definidas a nivel de una actividad de producto.
        PARAM IN PCRAMO      : Código del Ramo del producto
        PARAM IN PCMODALI    : Código de la Modalidad del producto
        PARAM IN PCTIPSEG    : Código del tipo de Seguro del producto
        PARAM IN PCCOLECT    : Código del la Colectividad del producto
        PARAM IN PSPRODUC    : Código del Identificador del producto
        PARAM IN PCACTIVI    : Código de la Actividad
        PARAM IN PCIDIOMA    : Código del Idioma
        PARAM OUT PRETCURSOR : SYS_REFCURSOR
        RETURN NUMBER        : número de error (0: operación correcta sino num error)
   *************************************************************************/
   FUNCTION f_get_pregactividad(
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcidioma IN NUMBER,
      pretcursor IN OUT sys_refcursor)
      RETURN NUMBER;

/*************************************************************************
        Función que retorna un objeto con las actividades de un producto.
        PARAM IN PCRAMO      : Código del Ramo del producto
        PARAM IN PCMODALI    : Código de la Modalidad del producto
        PARAM IN PCTIPSEG    : Código del tipo de Seguro del producto
        PARAM IN PCCOLECT    : Código del la Colectividad del producto
        PARAM IN PSPRODUC    : Código del Identificador del producto
        PARAM IN PCACTIVI    : Código de la Actividad
        PARAM IN PCIDIOMA    : Código del Idioma
        PARAM OUT PRETCURSOR : SYS_REFCURSOR
        RETURN NUMBER        : número de error (0: operación correcta sino num error)
   *************************************************************************/
   FUNCTION f_get_actividades(
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcidioma IN NUMBER,
      pretcursor IN OUT sys_refcursor)
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
        PARAM OUT NERROR     : Código de error
        RETURN NUMBER        : número de error (0: operación correcta sino 1)
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
      nerror OUT NUMBER)
      RETURN NUMBER;

/*************************************************************************
        Función que se utiliza para comprobar si existen pólizas de una actividad definida en un producto
        PARAM IN PSPRODUC    : Código del Identificador del producto
        PARAM IN PCACTIVI    : Código de la Actividad
        PARAM OUT NERROR     : Código de error
        RETURN NUMBER        : número de error (0: operación correcta sino 1)
   *************************************************************************/
   FUNCTION f_exist_actpol(psproduc IN NUMBER, pcactivi IN NUMBER, nerror OUT NUMBER)
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
        PARAM OUT NERROR     : Código de error
        RETURN NUMBER        : número de error (0: operación correcta sino 1)
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
      nerror OUT NUMBER)
      RETURN NUMBER;

/*************************************************************************
        Función que se utiliza para borrar la actividad definida en un producto
        PARAM IN PSPRODUC    : Código del Identificador del producto
        PARAM IN PCACTIVI    : Código de la Actividad
        PARAM OUT NERROR     : Código de error
        RETURN NUMBER        : Código de error (0: operación correcta sino 1)
   *************************************************************************/
   FUNCTION f_borrar_actividades(psproduc IN NUMBER, pcactivi IN NUMBER, nerror OUT NUMBER)
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
        RETURN NUMBER        : Código de error (0: operación correcta sino 1)
  **********************************************************************/
   FUNCTION f_duplicar_actividades(
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcactivic IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
         Función para asignar cláusulas de beneficiario al producto
         PARAM IN PSPRODUC    : Código del Identificador del producto
         PARAM IN PSCLABEN    : Código de la clausula
         RETURN NUMBER        : Código de error (0: operación correcta sino 1)

         Bug 10557   29/06/2009  AMC
   **********************************************************************/
   FUNCTION f_set_benefpro(psproduc IN NUMBER, psclaben IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
          Función para asignar una cláusula de beneficiario por defecto al producto
          PARAM IN PSPRODUC    : Código del Identificador del producto
          PARAM IN PSCLABEN    : Código de la clausula
          RETURN NUMBER        : Código de error (0: operación correcta sino 1)

          Bug 10557   29/06/2009  AMC
    **********************************************************************/
   FUNCTION f_set_benefdefecto(psproduc IN NUMBER, psclaben IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
         Función que se utiliza para desasignar una cláusula del producto
         PARAM IN PSPRODUC    : Código del Identificador del producto
         PARAM IN PSCLABEN    : Código de la clausula
         PARAM OUT PNERROR    : Código del error
         RETURN NUMBER        : Código de error (0: operación correcta sino 1)

         Bug 10557   29/06/2009  AMC
   **********************************************************************/
   FUNCTION f_del_benefpro(psproduc IN NUMBER, psclaben IN NUMBER, pnerror OUT NUMBER)
      RETURN NUMBER;

/*************************************************************************
        Función que retorna las cláusulas de beneficirio no asignadas a un producto
        PARAM IN PSPRODUC    : Código del Identificador del producto
        PARAM IN PCIDIOMA    : Código del idioma
        RETURN sys_refcursor

        Bug 10557   29/06/2009  AMC
  **********************************************************************/
   FUNCTION f_get_benef_noasig(psproduc IN NUMBER, pcidioma IN NUMBER)
      RETURN sys_refcursor;

   /*************************************************************************
          Función que asigna una garantia a un producto
          PARAM IN PSPRODUC    : Código del Identificador del producto
          PARAM IN PCGARANT    : Código de la garantia
          PARAM IN PCACTIVI    : Código de la actividad
          PARAM IN PNORDEN     : Numero de orden
          PARAM IN PCTIPGAR    : Código de tipo de garantia
          PARAM IN PCTIPCAR    : Código de tipo de capital
          RETURN NUMBER

          Bug 14284   26/04/2010  AMC
    **********************************************************************/
   FUNCTION f_set_garantiaprod(
      psproduc IN NUMBER,
      pcgarant IN NUMBER,
      pcactivi IN NUMBER,
      pnorden IN NUMBER,
      pctipgar IN NUMBER,
      pctipcap IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
          Función que retorna los parametros de codipargar
          PARAM IN PCIDIOMA    : Código del idioma
          RETURN sys_refcursor

          Bug 14284   29/04/2010  AMC
    **********************************************************************/
   FUNCTION f_get_pargarantia(pcidioma IN NUMBER)
      RETURN sys_refcursor;

   /*************************************************************************
         Función que retorna la lista de valores de un parametro
         PARAM IN PCPARGAR    : codigo del parametro
         PARAM IN PCIDIOMA    : Código del idioma
         RETURN sys_refcursor

         Bug 14284   29/04/2010  AMC
   **********************************************************************/
   FUNCTION f_get_valpargarantia(pcpargar IN VARCHAR2, pcidioma IN NUMBER)
      RETURN sys_refcursor;

   /*************************************************************************
         Función que retorna el tipo de respuesta del parametro
         PARAM IN PCPARGAR    : codigo del parametro
         RETURN NUMBER

         Bug 14284   29/04/2010  AMC
   **********************************************************************/
   FUNCTION f_get_ctipoparam(pcpargar IN VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
         Función que inserta en garanprocap
         PARAM IN PCRAMO      : codigo de ramo
         PARAM IN PCMODALI    : codigo de modalidad
         PARAM IN PCTIPSEG    : codigo de tipo de seguro
         PARAM IN PCCOLECT    : codigo de colectivo
         PARAM IN PCGARANT    : codigo de la garantia
         PARAM IN PCACTIVI    : codigo de la actividad
         PARAM IN PNORDEN     : numero de orden
         PARAM IN PICAPITAL   : importe del capital
         PARAM IN PCDEFECTO   : por defecto 0-No/1-Si
         RETURN NUMBER

         Bug 14284   05/05/2010  AMC
   **********************************************************************/
   FUNCTION f_set_capital(
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pcgarant IN NUMBER,
      pcactivi IN NUMBER,
      pnorden IN NUMBER,
      picapital IN NUMBER,
      pcdefecto IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
         Función que borrar los capitales de un garantia en garanprocap
         PARAM IN PCRAMO      : codigo de ramo
         PARAM IN PCMODALI    : codigo de modalidad
         PARAM IN PCTIPSEG    : codigo de tipo de seguro
         PARAM IN PCCOLECT    : codigo de colectivo
         PARAM IN PCGARANT    : codigo de la garantia
         PARAM IN PCACTIVI    : codigo de la actividad
         RETURN NUMBER

         Bug 14284   05/05/2010  AMC
   **********************************************************************/
   FUNCTION f_del_capitales(
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pcgarant IN NUMBER,
      pcactivi IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
         Función que retorna la lista de capitales de una garantia
         param in psproduc  : codigo del producto
         param in pcgarant  : codigo de la garantia
         param in pcactivi  : codigo de la actividad
         RETURN sys_refcursor

         Bug 14284   05/05/2010  AMC
   **********************************************************************/
   FUNCTION f_get_listcapitales(psproduc IN NUMBER, pcgarant IN NUMBER, pcactivi IN NUMBER)
      RETURN sys_refcursor;

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
      pcmoncap IN NUMBER)
      RETURN NUMBER;

    /*************************************************************************
         Función que borrar una garantia asignada a un producto
         param in psproduc  : código del producto
         param in pcactivi  : código de la actividad
         param in pcgarant  : código de la garantia
         RETURN number

         Bug 14723 - 25/05/2010 - AMC
   **********************************************************************/
   FUNCTION f_del_garantia(psproduc IN NUMBER, pcactivi IN NUMBER, pcgarant IN NUMBER)
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
      pciedmrv IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
         Función que inserta en incompgaran
         PARAM IN PSPRODUC     : codigo del producto
         PARAM IN PCGARANT    : codigo de la garantia
         PARAM IN PCGARANT    : codigo de la garantia incompatible
         PARAM IN PCACTIVI    : codigo de la actividad

         RETURN NUMBER

         Bug 15023   16/06/2010  AMC
   **********************************************************************/
   FUNCTION f_set_incompagar(
      psproduc IN NUMBER,
      pcgarant IN NUMBER,
      pcgarinc IN NUMBER,
      pcactivi IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
         Función que borra de incompgaran
         PARAM IN PSPRODUC     : codigo del producto
         PARAM IN PCGARANT    : codigo de la garantia
         PARAM IN PCGARANT    : codigo de la garantia incompatible
         PARAM IN PCACTIVI    : codigo de la actividad

         RETURN NUMBER

         Bug 15023   16/06/2010  AMC
   **********************************************************************/
   FUNCTION f_del_incompagar(
      psproduc IN NUMBER,
      pcgarant IN NUMBER,
      pcgarinc IN NUMBER,
      pcactivi IN NUMBER)
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
         param in cprovis   : Tipo de provison

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
      pcprovis IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
       Borra la formula de una garantia
       param in Psproduc      : código del producto
       param in Pcactivi    : código de la actividad
       param in Pcgarant    : código de la garantía
       param in Pccampo    : código del campo
       param in Pclave    : clave fórmula
       return               : 0 si ha ido bien
                             numero error si ha ido mal

       Bug 15149 - 29/06/2010 - AMC
   *************************************************************************/
   FUNCTION f_del_prodgarformulas(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pccampo IN VARCHAR2,
      pclave IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
         Inserta un nuevo producto en la tabla PRODUCTOS
         param in pcramo    : codigo del ramo
         param in pcmodali  : codigo de la modalidad
         param in pctipseg  : codigo del tipo de seguro
         param in pccolect  : codigo de colectividad
         param in pcagrpro  : codigo agrupacion de producto
         param in pcidioma  : codigo de idioma.
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

         Bug 15513 - 23/07/2010 - PFA
   *************************************************************************/
   FUNCTION f_alta_producto(
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pcagrpro IN NUMBER,
      pcidioma IN NUMBER,
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
      psproduc_out IN OUT NUMBER)
      RETURN NUMBER;

       /*************************************************************************
         Función que retorna els documentos d'un producte
         param in psproduc  : codigo del producto

         RETURN sys_refcursor

         Bug 14284   29/04/2010  AMC
   **********************************************************************/
   FUNCTION f_get_documentos(psproduc IN NUMBER, pcidioma IN NUMBER)
      RETURN sys_refcursor;

       /*************************************************************************
         Función que actualiza los datos de la tabla GARANPRORED a partir
         del campo CGARPADRE de la tabla GARANPRO
         param in psproduc  : codigo del producto
         param in pcactivi  : codigo de la actividad
         param in pcgarant  : codigo de la garantia
         param in pfmovini  : fecha inicial del movimiento
         RETURN NUMBER (0.-Todo Ok; num_err si ha habido algun error)
   **********************************************************************/
   -- Bug 22049 - APD - 30/04/2012 - se crea la funcion
   FUNCTION f_act_garanprored(
      psproduc IN NUMBER DEFAULT NULL,
      pcactivi IN NUMBER DEFAULT NULL,
      pcgarant IN NUMBER DEFAULT NULL,
      pfmovini IN DATE DEFAULT f_sysdate)
      RETURN NUMBER;

   /**************************************************************************
     Assigna un pla de pensió per un producte. Si existe, lo actualiza
     param in psproduc     : Codigo del producto
     param in pccodpla    : Codigo del plan de pensión
   **************************************************************************/
   FUNCTION f_set_planpension(psproduc IN NUMBER, pccodpla IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
            Función que retorna las duraciones de cobro de un producto
            param in psproduc  : codigo del producto

            RETURN sys_refcursor

            Bug 22253   17/05/2012   MDS
      **********************************************************************/
   FUNCTION f_get_durcobroprod(psproduc IN NUMBER)
      RETURN sys_refcursor;

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
   función que graba el modelo recibido por parámetro para un idioma.
   param in pcramo     :
   param in pccolect    :
   param in pcmodali    :
   param in pctipseg    :
   param in pcmodinv    :
   param in ptmodinv    :
   param in out mensajes    :
   **************************************************************************/
   FUNCTION f_set_modelinv(
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pccolect IN NUMBER,
      pctipseg IN NUMBER,
      pcmodinv IN NUMBER,
      pcidioma IN NUMBER,
      ptmodinv IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /**************************************************************************
     función que graba el fondo correspondiente a  un modelo de inversión recibido por parámetro para un idioma.
     param in psproduc     :
     param in pccodfon    :
     param in pinvers    :
     param in pmaxcont    :
     param in out mensajes    :
     **************************************************************************/
   FUNCTION f_set_modinvfondo(
      psproduc IN NUMBER,
      pccodfon IN NUMBER,
      ppinvers IN NUMBER,
      pcmodinv IN NUMBER,
      ppmaxcont IN NUMBER,
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
END pac_mntprod;

/

  GRANT EXECUTE ON "AXIS"."PAC_MNTPROD" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MNTPROD" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MNTPROD" TO "PROGRAMADORESCSI";
