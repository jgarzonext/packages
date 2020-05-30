--------------------------------------------------------
--  DDL for Package PAC_OPERATIVA_ULK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_OPERATIVA_ULK" AUTHID CURRENT_USER IS
   /******************************************************************************
       RSC 30-08-2007
       Package público para la generación de operativa de ULK
   ******************************************************************************/

   -- Constante a sumar al valor de provisión que nos resultará en el capital de fallecimiento
   k_extracapfall NUMBER := 601.01;

   TYPE rt_det_modinv IS RECORD(
      vccesta        NUMBER,
      vucesta        NUMBER,
      vvalcesta      NUMBER
   );

   TYPE tt_det_modinv IS TABLE OF rt_det_modinv
      INDEX BY PLS_INTEGER;

----------------------------------------------------------------------------

   -- Para el tfcon031
   TYPE rt_mov_modinv IS RECORD(
      vnmovimi       NUMBER,
      vfinicio       DATE,
      vcmodinv       NUMBER,
      vtmodinv       VARCHAR2(50)
   );

   TYPE tt_mov_modinv IS TABLE OF rt_mov_modinv
      INDEX BY BINARY_INTEGER;

----------------------------------------------------------------------------

   -- RSC 15/11/2007
   FUNCTION ff_primas_satisfechas(
      psseguro IN seguros.sseguro%TYPE,
      fdesde IN DATE,
      fhasta IN DATE)
      RETURN NUMBER;

/***********************************************************
    SHADOW ACCOUNTS
************************************************************/
   FUNCTION ff_primas_satisfechas_shw(
      psseguro IN seguros.sseguro%TYPE,
      fdesde IN DATE,
      fhasta IN DATE)
      RETURN NUMBER;

   FUNCTION ff_gastos_gestion_y_cobertura(
      psseguro IN seguros.sseguro%TYPE,
      fdesde IN DATE,
      fhasta IN DATE)
      RETURN NUMBER;

/***********************************************************
    SHADOW ACCOUNTS
************************************************************/
   FUNCTION ff_gastos_gestioncobertura_shw(
      psseguro IN seguros.sseguro%TYPE,
      fdesde IN DATE,
      fhasta IN DATE)
      RETURN NUMBER;

   FUNCTION ff_gastos_redistribucion(
      psseguro IN seguros.sseguro%TYPE,
      fdesde IN DATE,
      fhasta IN DATE)
      RETURN NUMBER;

----------------------------------------------------------------------------
   FUNCTION ff_valor_provision(psseguro IN NUMBER, ppfefecto IN NUMBER)
      RETURN NUMBER;

/***********************************************************
    SHADOW ACCOUNTS
************************************************************/
   FUNCTION ff_valor_provision_shw(psseguro IN NUMBER, ppfefecto IN NUMBER)
      RETURN NUMBER;

   FUNCTION ff_valor_provision_fecha(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      ppfefecto IN NUMBER)
      RETURN NUMBER;

/***********************************************************
    SHADOW ACCOUNTS
************************************************************/
   FUNCTION ff_valor_provision_fecha_shw(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      ppfefecto IN NUMBER)
      RETURN NUMBER;

   FUNCTION ff_cfallecimiento(psseguro IN NUMBER, ppfefecto IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_gastos_gestion_anual(
      psseguro IN NUMBER,
      v_provision IN NUMBER,
      ggesanual IN OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_gastos_redistribucion_anual(
      psseguro IN NUMBER,
      v_provision IN NUMBER,
      gredanual IN OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_cta_gastos_gestion(
      psseguro IN NUMBER,
      ppfefecto IN DATE,
      pmodo IN VARCHAR2,
      seqgrupo IN NUMBER)
      RETURN NUMBER;

/***********************************************************
    SHADOW ACCOUNTS
************************************************************/
   FUNCTION f_cta_gastos_gestion_shw(
      psseguro IN NUMBER,
      ppfefecto IN DATE,
      pmodo IN VARCHAR2,
      seqgrupo IN NUMBER)
      RETURN NUMBER;

-- RSC 06/11/2007 --------------------------------------------------------------
   FUNCTION ff_tarcobertura(psseguro IN NUMBER, ppfefecto IN NUMBER)
      RETURN NUMBER;

-- RSC 05/11/2007 --------------------------------------------------------------------
   FUNCTION f_cta_gastos_scobertura(
      psseguro IN NUMBER,
      pfefecto IN DATE,
      psproduc IN NUMBER,
      pmodo IN VARCHAR2,
      seqgrupo IN NUMBER)
      RETURN NUMBER;

 /***********************************************************
    SHADOW ACCOUNTS
************************************************************/
   FUNCTION f_cta_gastos_scobertura_shw(
      psseguro IN NUMBER,
      pfefecto IN DATE,
      psproduc IN NUMBER,
      pmodo IN VARCHAR2,
      seqgrupo IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_cta_gastos_redistribucion(
      psseguro IN NUMBER,
      fefecto IN DATE,
      v_provision IN NUMBER,
      gredanual IN NUMBER)
      RETURN NUMBER;

 /***********************************************************
    SHADOW ACCOUNTS
************************************************************/
   FUNCTION f_cta_gastos_redist_shw(
      psseguro IN NUMBER,
      fefecto IN DATE,
      v_provision IN NUMBER,
      gredanual IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_cta_saldo_fondos(
      psseguro IN NUMBER,
      fdesde IN DATE,
      total_cestas IN OUT NUMBER,
      tcestasu IN OUT NUMBER,
      v_det_modinv IN OUT tt_det_modinv)
      RETURN NUMBER;

 /***********************************************************
    SHADOW ACCOUNTS
************************************************************/
   FUNCTION f_cta_saldo_fondos_shw(
      psseguro IN NUMBER,
      fdesde IN DATE,
      total_cestas IN OUT NUMBER,
      tcestasu IN OUT NUMBER,
      v_det_modinv IN OUT tt_det_modinv)
      RETURN NUMBER;

   FUNCTION f_cta_saldo_fondos_cesta(
      psseguro IN NUMBER,
      fdesde IN DATE,
      pcesta IN NUMBER,
      tcesta_unidades IN OUT NUMBER,
      tcesta_importe IN OUT NUMBER,
      total_cestas IN OUT NUMBER)
      RETURN NUMBER;

/***********************************************************
    SHADOW ACCOUNTS
************************************************************/
   FUNCTION f_cta_saldo_fondos_cesta_shw(
      psseguro IN NUMBER,
      fdesde IN DATE,
      pcesta IN NUMBER,
      tcesta_unidades IN OUT NUMBER,
      tcesta_importe IN OUT NUMBER,
      total_cestas IN OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_cta_provision_cesta(
      psseguro IN NUMBER,
      fdesde IN DATE,
      fhasta IN DATE,
      pcesta IN NUMBER,
      tcesta_unidades IN OUT NUMBER,
      tcesta_importe IN OUT NUMBER,
      total_cestas IN OUT NUMBER)
      RETURN NUMBER;

/***********************************************************
    SHADOW ACCOUNTS
************************************************************/
   FUNCTION f_cta_provision_cesta_shw(
      psseguro IN NUMBER,
      fdesde IN DATE,
      fhasta IN DATE,
      pcesta IN NUMBER,
      tcesta_unidades IN OUT NUMBER,
      tcesta_importe IN OUT NUMBER,
      total_cestas IN OUT NUMBER)
      RETURN NUMBER;

   /******************************************************************************
       RSC 03-09-2007.
       Genera la redistribución de fondos a nivel teórico en CTASEGURO.
       El algoritmo consiste en recoger todas las unidades acumuladas en CTASEGURO
       en los fondos de la distribución anterior al suplemento y generar las ventas
       de los fondos. Posteriormente se debe generar la compra de participaciones
       de los fondos de la nueva distribución.

       En el momento de ASIGNAR participaciones se pasarán a consolidado.
   ******************************************************************************/
   FUNCTION f_redistribucion_fondos(psseguro IN NUMBER)
      RETURN NUMBER;

   /******************************************************************************
       RSC 03-09-2007.
       Genera los movimientos de venta por redistribución a nivel teórico en CTASEGURO.
       En el momento de ASIGNAR participaciones se pasarán a consolidado.
   ******************************************************************************/
   --FUNCTION f_redistribuye_venta(psseguro IN NUMBER, pdet_modinv IN tt_det_modinv, pimporte IN NUMBER, puniimporte IN NUMBER, pfefecto IN DATE) RETURN NUMBER;
   FUNCTION f_redistribuye_venta(
      psseguro IN NUMBER,
      pdet_modinv IN tt_det_modinv,
      pfefecto IN DATE,
      sivendecompra IN OUT NUMBER,
      seqgrupo IN NUMBER)
      RETURN NUMBER;

   /******************************************************************************
         SHADOW ACCOUNTS
         Genera los movimientos de venta por redistribución a nivel teórico en CTASEGURO_SHADOW.
         En el momento de ASIGNAR participaciones se pasarán a consolidado.
     ******************************************************************************/
   FUNCTION f_redistribuye_venta_shw(
      psseguro IN NUMBER,
      pdet_modinv IN tt_det_modinv,
      pfefecto IN DATE,
      sivendecompra IN OUT NUMBER,
      seqgrupo IN NUMBER)
      RETURN NUMBER;

   /******************************************************************************
       RSC 03-09-2007.
       Genera los movimientos de compra por redistribución a nivel teórico en CTASEGURO.
       En el momento de ASIGNAR participaciones se pasarán a consolidado.
   ******************************************************************************/
   --FUNCTION f_redistribuye_compra(psseguro IN NUMBER, pimporte IN NUMBER, pfefecto IN DATE) RETURN NUMBER;
   FUNCTION f_redistribuye_compra(
      psseguro IN NUMBER,
      pfefecto IN DATE,
      sivendecompra IN OUT NUMBER,
      seqgrupo IN NUMBER)
      RETURN NUMBER;

   /******************************************************************************
       SHADOW ACCOUNTS
       Genera los movimientos de compra por redistribución a nivel teórico en CTASEGURO_SHADOW.
       En el momento de ASIGNAR participaciones se pasarán a consolidado.
   ******************************************************************************/
   FUNCTION f_redistribuye_compra_shw(
      psseguro IN NUMBER,
      pfefecto IN DATE,
      sivendecompra IN OUT NUMBER,
      seqgrupo IN NUMBER)
      RETURN NUMBER;

   /******************************************************************************
       RSC 03-09-2007.
       Genera los gastos de redistribución a nivel teórico en CTASEGURO.
       En el momento de ASIGNAR participaciones se pasarán a consolidado.
   ******************************************************************************/
   FUNCTION f_redistribuye_gastosredis(psseguro IN NUMBER, pfefecto IN DATE, seqgrupo IN NUMBER)
      RETURN NUMBER;

/******************************************************************************
        SHADOW ACCOUNTS
        Genera los gastos de redistribución a nivel teórico en CTASEGURO_SHADOW.
        En el momento de ASIGNAR participaciones se pasarán a consolidado.
    ******************************************************************************/
   FUNCTION f_redistribuye_gastosredis_shw(
      psseguro IN NUMBER,
      pfefecto IN DATE,
      seqgrupo IN NUMBER)
      RETURN NUMBER;

   /*****************************************************************************************
       RSC 09-09-2007.
       Regenera las aportaciones no asignadas todavia ya que puede producirse la
       situación siguiente: Redistribución X --> Aportación (dist X) --> Redistribución Y.
       En este caso la Aportación con dist X se debe reconvertir a Aportación con dist Y.
   ******************************************************************************************/
   FUNCTION f_redistribuye_aportaciones(psseguro IN NUMBER, pfefecto IN DATE)
      RETURN NUMBER;

      /*****************************************************************************************
       SHADOW ACCOUNTS
       Regenera las aportaciones no asignadas todavia ya que puede producirse la
       situación siguiente: Redistribución X --> Aportación (dist X) --> Redistribución Y.
       En este caso la Aportación con dist X se debe reconvertir a Aportación con dist Y.
   ******************************************************************************************/
   FUNCTION f_redist_aportaciones_shw(psseguro IN NUMBER, pfefecto IN DATE)
      RETURN NUMBER;

   /*****************************************************************************************
       RSC 17-10-2007.
       Obtiene los códigos de modelos de inversión de la tabla segdisin2. No se guarda en
       ningun sitio los códigos de modelo pero sin embargo si guardamos todos los movimientos
       de las distribuciones de cestas. Por tanto podemos extraer los códigos de perfiles
       de inversión.

       Esta función se ha desarrollado para la libreria tfcon031.fmb.
   ******************************************************************************************/
   FUNCTION ff_get_movimis_segdisin2(psseguro IN NUMBER, pcidioma IN NUMBER)
      RETURN tt_mov_modinv;

   /********************************************************************************************
        RSC 22-01-2007.
        Si la distribución grabada en ESTSEGDISIN2 para el movimiendo "nmovimi" corresponde a algún
        modelo de inversión predefinido en la base de datos, retorna una variable con el modelo
        de inversión al cual hace referencia.

        (Esta función se ha desarrollado en el contexto de un suplemento de redistribución de cartera.
        La utilidad reside en la detección de una distribución predefinida en la base de datos cuando
        el usuario escoge manualmente una distribución LIBRE que justamente coincide con una predefinida
        y que por tanto es absurdo que sea LIBRE.)
    **********************************************************************************************/
   FUNCTION ff_get_segdisin2_nmovimi(psseguro IN NUMBER, nmovimi IN NUMBER, pcidioma IN NUMBER)
      RETURN tt_mov_modinv;
END pac_operativa_ulk;

/

  GRANT EXECUTE ON "AXIS"."PAC_OPERATIVA_ULK" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_OPERATIVA_ULK" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_OPERATIVA_ULK" TO "PROGRAMADORESCSI";
