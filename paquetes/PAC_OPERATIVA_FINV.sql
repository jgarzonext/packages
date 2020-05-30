--------------------------------------------------------
--  DDL for Package PAC_OPERATIVA_FINV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_OPERATIVA_FINV" IS
   /******************************************************************************
      NOMBRE:       PAC_OPERATIVA_FINV
      PROPÓSITO:
      REVISIONES:

      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
       1.0       -            -               1. Creación de package
       2.0       17/03/2009  RSC              2. Análisis adaptación productos indexados
       3.0       07/04/2009  RSC              3. Análisis adaptación productos indexados: PPJ Din, Pla estudiant
       4.0       17/09/2009  RSC              4. Bug 0010828: CRE - Revisión de los productos PPJ dinámico y Pla Estudiant (ajustes)
       5.0       25/09/2009  JGM              5. Bug 0011175
       6.0       16/06/2011  JTS              6. BUG 0018799
       7.0       21/10/2011  JGR              7. 19852: CRE998 - Impressió de compte assegurança  (nota 0095567)
       8.0       15/07/2014  AFM              8. 32058: GAP. Prima de Riesgo, gastos y comisiones prepagables

   ******************************************************************************/

   /******************************************************************************
       RSC 30-08-2007
       Package público para la generación de operativa de FINV
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

/******************************************************************************
   SHADDOW ACCOUNTS
 ******************************************************************************/
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

/******************************************************************************
     SHADDOW ACCOUNTS
   ******************************************************************************/
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
/******************************************************************************
     SHADDOW ACCOUNTS
   ******************************************************************************/
   FUNCTION ff_gastos_redistribucion_shw(
      psseguro IN seguros.sseguro%TYPE,
      fdesde IN DATE,
      fhasta IN DATE)
      RETURN NUMBER;

   FUNCTION ff_provmat(
      psesion IN NUMBER,
      psseguro IN NUMBER,
      ppfefecto IN NUMBER,
      pnnumlin IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

/******************************************************************************
     SHADDOW ACCOUNTS
   ******************************************************************************/
   FUNCTION ff_provshw(
      psesion IN NUMBER,
      psseguro IN NUMBER,
      ppfefecto IN NUMBER,
      pnnumlin IN NUMBER DEFAULT NULL)   -- Bug 19312 - RSC - 24/11/2011
      RETURN NUMBER;

   FUNCTION ff_valor_provision_fecha(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      ppfefecto IN NUMBER)
      RETURN NUMBER;

/******************************************************************************
     SHADDOW ACCOUNTS
   ******************************************************************************/
   FUNCTION ff_valor_provision_fecha_shw(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      ppfefecto IN NUMBER)
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

-- INI BUG: 32058
   FUNCTION f_cta_gastos_gestion(
      psseguro IN NUMBER,
      ppfefecto IN DATE,
      pmodo IN VARCHAR2,
      pcmovimi IN NUMBER,
      pnrecibo IN NUMBER DEFAULT NULL,
      pnsinies IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

/******************************************************************************
     SHADDOW ACCOUNTS
   ******************************************************************************/
   FUNCTION f_cta_gastos_gestion_shw(
      psseguro IN NUMBER,
      ppfefecto IN DATE,
      pmodo IN VARCHAR2,
      pcmovimi IN NUMBER,
      pnrecibo IN NUMBER DEFAULT NULL,
      pnsinies IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_cta_gastos_scobertura(
      psseguro IN NUMBER,
      pfefecto IN DATE,
      psproduc IN NUMBER,
      pmodo IN VARCHAR2,
      pcmovimi IN NUMBER,
      pipririe IN NUMBER DEFAULT NULL,
      pnrecibo IN NUMBER DEFAULT NULL,
      pnsinies IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

/******************************************************************************
     SHADDOW ACCOUNTS
   ******************************************************************************/
   FUNCTION f_cta_gastos_scobertura_shw(
      psseguro IN NUMBER,
      pfefecto IN DATE,
      psproduc IN NUMBER,
      pmodo IN VARCHAR2,
      pcmovimi IN NUMBER,
      pipririe IN NUMBER DEFAULT NULL,
      pnrecibo IN NUMBER DEFAULT NULL,
      pnsinies IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

-- FIN BUG: 32058
   FUNCTION f_cta_saldo_fondos(
      psseguro IN NUMBER,
      fdesde IN DATE,
      total_cestas IN OUT NUMBER,
      tcestasu IN OUT NUMBER,
      v_det_modinv IN OUT tt_det_modinv,
      pfunds IN t_iax_produlkmodinvfondo DEFAULT NULL)   -- Bug 36746/0211309 - APD - 17/09/2015
      RETURN NUMBER;

/******************************************************************************
     SHADDOW ACCOUNTS
   ******************************************************************************/
   FUNCTION f_cta_saldo_fondos_shw(
      psseguro IN NUMBER,
      fdesde IN DATE,
      total_cestas IN OUT NUMBER,
      tcestasu IN OUT NUMBER,
      v_det_modinv IN OUT tt_det_modinv,
      pfunds IN t_iax_produlkmodinvfondo DEFAULT NULL)   -- Bug 36746/0211309 - APD - 17/09/2015
      RETURN NUMBER;

   FUNCTION f_cta_saldo_fondos_cesta(
      psseguro IN NUMBER,
      fdesde IN DATE,
      pcesta IN NUMBER,
      tcesta_unidades IN OUT NUMBER,
      tcesta_importe IN OUT NUMBER,
      total_cestas IN OUT NUMBER)
      RETURN NUMBER;

/******************************************************************************
     SHADDOW ACCOUNTS
   ******************************************************************************/
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
      total_cestas IN OUT NUMBER,
      pnnumlin IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

/******************************************************************************
     SHADDOW ACCOUNTS
   ******************************************************************************/
   FUNCTION f_cta_provision_cesta_shw(
      psseguro IN NUMBER,
      fdesde IN DATE,
      fhasta IN DATE,
      pcesta IN NUMBER,
      tcesta_unidades IN OUT NUMBER,
      tcesta_importe IN OUT NUMBER,
      total_cestas IN OUT NUMBER,
      pnnumlin IN NUMBER DEFAULT NULL)
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
      seqgrupo IN NUMBER,
      pfunds IN t_iax_produlkmodinvfondo DEFAULT NULL)   -- Bug 36746/0211309 - APD - 17/09/2015
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
      seqgrupo IN NUMBER,
      pfunds IN t_iax_produlkmodinvfondo DEFAULT NULL)   -- Bug 36746/0211309 - APD - 17/09/2015
      RETURN NUMBER;

   /******************************************************************************
       RSC 03-09-2007.
       Genera los gastos de redistribución a nivel teórico en CTASEGURO.
       En el momento de ASIGNAR participaciones se pasarán a consolidado.
   ******************************************************************************/
   FUNCTION f_redistribuye_gastosredis(
      psseguro IN NUMBER,
      pfefecto IN DATE,
      seqgrupo IN NUMBER,
      pfunds IN t_iax_produlkmodinvfondo DEFAULT NULL)   -- Bug 36746/0211309 - APD - 17/09/2015
      RETURN NUMBER;

   /******************************************************************************
         SHADOW ACCOUNTS
        Genera los gastos de redistribución a nivel teórico en CTASEGURO_SHADOW.
        En el momento de ASIGNAR participaciones se pasarán a consolidado.
    ******************************************************************************/
   FUNCTION f_redistribuye_gastosredis_shw(
      psseguro IN NUMBER,
      pfefecto IN DATE,
      seqgrupo IN NUMBER,
      pfunds IN t_iax_produlkmodinvfondo DEFAULT NULL)   -- Bug 36746/0211309 - APD - 17/09/2015
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

   /********************************************************************************************
        JGM 22-09-2009.
        Devolverá una colección de objetos T_IAX_TABVALCES, rsultado de buscar en la tabla tabvalces
        para el ccesta igual al parámetro pccesta.

      param in  pcempres : Cod. Empresa
      param in  pccesta : Cod. de la cesta
      param in  pcidioma: idioma

    **********************************************************************************************/-- BUG - 23/02/2012 21546_108727- JLTS - Se eliminó la funcion PAC_OPERATIVA_FINV.f_get_tabvalces
   -- y se unió a PAC_MD_OPERATIVA_FINV.f_get_tabvalces
/*   FUNCTION f_get_tabvalces(
      pcempres IN NUMBER,
      pccesta IN NUMBER,
      pcidioma IN NUMBER,
      perror OUT NUMBER)
      RETURN t_iax_tabvalces;*/

   /*************************************************************************
      FUNCTION f_insert_reggastos
        PARAM IN ccodfon
        PARAM IN finicio
        PARAM IN ffin
        PARAM IN iimpmin
        PARAM IN iimpmax
        PARAM IN cdivisa
        PARAM IN pgastos
        PARAM IN iimpfij
        PARAM IN column9
        PARAM IN ctipcom
        PARAM IN cconcep
        PARAM IN ctipocalcul
        PARAM IN clave
        return : 0.- OK Otros.- Cod. Error
        --BUG18799 - JTS - 16/06/2011
   *************************************************************************/
   FUNCTION f_insert_reggastos(
      pccodfon IN NUMBER,
      pfinicio IN DATE,
      pffin IN DATE,
      piimpmin IN NUMBER,
      piimpmax IN NUMBER,
      pcdivisa IN NUMBER,
      ppgastos IN NUMBER,
      piimpfij IN NUMBER,
      pcolumn9 IN NUMBER,
      pctipcom IN NUMBER,
      pcconcep IN NUMBER,
      pctipocalcul IN NUMBER,
      pclave IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_get_gastos_hist
        PARAM IN pccodfon
        return : cursor
        --BUG18799 - JTS - 16/06/2011
   *************************************************************************/
   FUNCTION f_get_gastos_hist(pccodfon IN NUMBER, pcidioma IN NUMBER)
      RETURN sys_refcursor;

   /*************************************************************************
      FUNCTION f_get_gastos
        PARAM IN pccodfon
        return : cursor
        --BUG18799 - JTS - 16/06/2011
   *************************************************************************/
   FUNCTION f_get_gastos(pcempres IN NUMBER, pccodfon IN NUMBER, pcidioma IN NUMBER)
      RETURN sys_refcursor;

   /*************************************************************************
      FUNCTION f_op_pdtes_valorar
        PARAM IN psseguro
        return : NUMBER
        BUG0019852: CRE998 - Impressió de compte assegurança - JGR - 21/10/2011
        Retorna si ha de mostrar o no la icone de impresora.
        També retorna el literal que es comenta en el bug "Pòlissa amb operacions pedents de valorar"
   *************************************************************************/
   FUNCTION f_op_pdtes_valorar(
      pcempres IN NUMBER,
      psseguro IN NUMBER,
      pcidioma IN NUMBER,
      pliteral IN OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION ff_rendimiento(psseguro IN NUMBER, pnnumlin IN NUMBER)
      RETURN NUMBER;

/******************************************************************************
     SHADDOW ACCOUNTS
   ******************************************************************************/
   FUNCTION ff_rendimiento_shw(psseguro IN NUMBER, pnnumlin IN NUMBER)
      RETURN NUMBER;

   FUNCTION ffrendiment(psesion IN NUMBER, psseguro IN NUMBER, pfecha IN NUMBER)
      RETURN NUMBER;

   /******************************************************************************
  SHADDOW ACCOUNTS
******************************************************************************/
   FUNCTION ffrendiment_shw(psesion IN NUMBER, psseguro IN NUMBER, pfecha IN NUMBER)
      RETURN NUMBER;

   FUNCTION ffrend_trim(psesion IN NUMBER, psseguro IN NUMBER, pfecha IN NUMBER)
      RETURN NUMBER;

   /******************************************************************************
  SHADDOW ACCOUNTS
******************************************************************************/
   FUNCTION ffrend_trim_shw(psesion IN NUMBER, psseguro IN NUMBER, pfecha IN NUMBER)
      RETURN NUMBER;

/**************************************************************************************
1548/205293 f_ins_detalle_gasto  ACL
***************************************************************************************/
   FUNCTION f_ins_detalle_gasto(
      psseguro IN NUMBER,
      ppfefecto IN DATE,
      pfcontab IN DATE,
      pnnumlin IN NUMBER,
      pffecmov IN DATE,
      pffvalmov IN DATE,
      pcmovimi IN NUMBER,
      pimovimi IN NUMBER,
      pimovimi2 IN NUMBER,
      pnrecibo IN NUMBER,
      pccalint IN NUMBER,
      pcmovanu IN NUMBER,
      pnsinies IN NUMBER,
      psmovrec IN NUMBER,
      pcestado IN VARCHAR2,
      pmodo IN VARCHAR2 DEFAULT 'R',
      psproces IN NUMBER DEFAULT NULL,
      pnmovimi IN NUMBER DEFAULT NULL,
      pccapgar IN NUMBER DEFAULT NULL,
      pccapfal IN NUMBER DEFAULT NULL,
      psrecren IN NUMBER DEFAULT NULL,
      pigasext IN NUMBER DEFAULT NULL,
      pigasint IN NUMBER DEFAULT NULL,
      pipririe IN NUMBER DEFAULT NULL,
      pcesta IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

/**************************************************************************************
1548/205293 f_ins_detalle_gasto_shw  ACL
***************************************************************************************/
   FUNCTION f_ins_detalle_gasto_shw(
      psseguro IN NUMBER,
      ppfefecto IN DATE,
      pfcontab IN DATE,
      pnnumlin IN NUMBER,
      pffecmov IN DATE,
      pffvalmov IN DATE,
      pcmovimi IN NUMBER,
      pimovimi IN NUMBER,
      pimovimi2 IN NUMBER,
      pnrecibo IN NUMBER,
      pccalint IN NUMBER,
      pcmovanu IN NUMBER,
      pnsinies IN NUMBER,
      psmovrec IN NUMBER,
      pcestado IN VARCHAR2,
      pmodo IN VARCHAR2 DEFAULT 'R',
      psproces IN NUMBER DEFAULT NULL,
      pnmovimi IN NUMBER DEFAULT NULL,
      pccapgar IN NUMBER DEFAULT NULL,
      pccapfal IN NUMBER DEFAULT NULL,
      psrecren IN NUMBER DEFAULT NULL,
      pigasext IN NUMBER DEFAULT NULL,
      pigasint IN NUMBER DEFAULT NULL,
      pipririe IN NUMBER DEFAULT NULL,
      pcesta IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   /********************************************
     funcion que retorna el importe total de la bonificación rescatable
     param in psseguro : Cdigo seguro
     param in pccesta  : estado
     param in pfecha   : fecha
     param in pimppb   : valor de la bonificacion
     return            : NUMBER (1 se ha producido un error, 0 ha ido todo bien)
   ********************************************/
   FUNCTION f_get_imppb(
      psseguro IN seguros.sseguro%TYPE,
      pccesta IN NUMBER,
      pfecha IN DATE,
      pimppb OUT NUMBER)
      RETURN NUMBER;

   /********************************************
      funcion que retorna el importe total de la bonificación rescatable sombra
      param in psseguro : Cdigo seguro
      param in pccesta  : estado
      param in pfecha   : fecha
      param in pimppb   : valor de la bonificacion
      return            : NUMBER (1 se ha producido un error, 0 ha ido todo bien)
    ********************************************/
   FUNCTION f_get_imppb_shw(
      psseguro IN seguros.sseguro%TYPE,
      pccesta IN NUMBER,
      pfecha IN DATE,
      pimppb OUT NUMBER)
      RETURN NUMBER;

    /************************************************************************************
       Función que ejecutara el proceso switch de fondos
       params:
           in pccesta
          in funds
      Return boolean.
   ************************************************************************************/
   FUNCTION f_valida_cesta_switch(pccesta IN NUMBER, funds IN t_iax_produlkmodinvfondo)
      RETURN NUMBER;

-- Bug 36746/0211309 - APD - 17/09/2015 - se crea la funcion
   FUNCTION f_ejecutar_switch(psseguro IN NUMBER)
      RETURN NUMBER;

-- Bug 36746/0211309 - APD - 17/09/2015 - se crea la funcion
   FUNCTION f_get_lstfondosseg(
      pcempres IN NUMBER,
      psseguro IN NUMBER,
      pfecha IN DATE,
      psquery OUT VARCHAR2)
      RETURN NUMBER;

-- Bug 36746/0211309 - APD - 17/09/2015 - se crea la funcion
   FUNCTION f_valida_switch(
      pccodfonori IN NUMBER,
      pccodfondtn IN NUMBER,
      psseguro IN NUMBER,
      pfecha IN DATE)
      RETURN NUMBER;

-- Bug 36746/0211309 - APD - 17/09/2015 - se crea la funcion
   FUNCTION f_switch_fondos(
      pccodfonori IN NUMBER,
      pccodfondtn IN NUMBER,
      psseguro IN NUMBER,
      pfecha IN DATE,
      psproces IN OUT NUMBER,
      plineas IN OUT NUMBER,
      plineas_error IN OUT NUMBER)
      RETURN NUMBER;

   /**********************************************************************
     Nueva función, que utiliza las tablas PRODTRASREC y DETPRODTRASREC,
     Con tipo de movimiento de penalización = 8 - Redistribución de fondos.

     Se aplica en el momento de la resdistribución (movimientos 80, 81)).
   **********************************************************************/
   FUNCTION f_gastos_redistribucion(psseguro IN NUMBER, pfecha IN DATE, pgtosred OUT NUMBER)
      RETURN NUMBER;
END pac_operativa_finv;

/

  GRANT EXECUTE ON "AXIS"."PAC_OPERATIVA_FINV" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_OPERATIVA_FINV" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_OPERATIVA_FINV" TO "PROGRAMADORESCSI";
