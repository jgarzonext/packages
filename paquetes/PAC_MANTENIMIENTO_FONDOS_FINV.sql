--------------------------------------------------------
--  DDL for Package PAC_MANTENIMIENTO_FONDOS_FINV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MANTENIMIENTO_FONDOS_FINV" AUTHID CURRENT_USER
IS
   /******************************************************************************
      NOMBRE:       PAC_MANTENIMIENTO_FONDOS_FINV
      PROPÓSITO:
      REVISIONES:

      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
       1.0       -            -               1. Creación de package
       2.0       17/03/2009  RSC              2. Análisis adaptación productos indexados
       3.0       17/09/2009  RSC              3. Bug 0010828: CRE - Revisión de los productos PPJ dinámico y Pla Estudiant (ajustes)
       4.0       07/06/2011  JMF              4. 0018741 Job de carga de valor liquidativo diario
       5.0       28/06/2011  RSC              5. 0018851: ENSA102 - Parametrización básica de traspasos de Contribución definida
       6.0       30/11/2011  RSC              6. 0020309: LCOL_T004-Parametrización Fondos
       7.0       06/10/215   JCP              7. 0033665: MSV, Cambio funcion f_set_fondo
       8.0       07/10/2015  YDA              8. 0033665: Creación de la función f_asign_dividends
   ******************************************************************************/

   /******************************************************************************
     RSC 11/12/2007
     Función destinada a realizar las valoraciones de siniestros y rescates asignados
     a una poliza en el momento de la asignación.
   ******************************************************************************/
   FUNCTION f_genera_valsiniestros(
      pfvalmov        IN       DATE,
      psproces        IN OUT   NUMBER,
      nerrores        IN OUT   NUMBER,
      pcidioma_user   IN       NUMBER
   )
      RETURN NUMBER;

   /******************************************************************************
     RSC 11/12/2007
     Función que determina si a una fecha determinada estan valoradas todas las cestas vigentes
   ******************************************************************************/
   FUNCTION f_cestas_valoradas(
      pfasig     IN   DATE,
      pcempres   IN   NUMBER,
      pccodfon   IN   NUMBER DEFAULT NULL,
      psseguro   IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER;

   /******************************************************************************
       RSC 20-08-2007
       Package para realizar el mantenimiento (valoración y asignación de valores
       liquidativos a los fondos y las pólizas relacionadas) de fondos y cestas.
   ******************************************************************************/

   /******************************************************************************
    RSC 28-08-2007
    Procedimiento que calcula el importe (imovimi) de entradas todavia sin asignar
    (ya sean compras o ventas). Devuelve el importe en valor absoluto, indicando
    el importe absoluto sin tener en cuenta si se trata de compras o ventas.
   ******************************************************************************/
   PROCEDURE f_get_importes_asignar (
      seguro     IN       NUMBER,
      pfefecto   IN       DATE,
      importes   OUT      NUMBER
   );

   /******************************************************************************
    SHADOW ACCOUNTS

    Procedimiento que calcula el importe (imovimi) de entradas todavia sin asignar
    (ya sean compras o ventas). Devuelve el importe en valor absoluto, indicando
    el importe absoluto sin tener en cuenta si se trata de compras o ventas.
   ******************************************************************************/
   PROCEDURE f_get_importes_asignar_shw (
      seguro     IN       NUMBER,
      pfefecto   IN       DATE,
      importes   OUT      NUMBER
   );

   /***************************************************************************************
     Esta función se encargará de asignar las unidades de los movimientos que se han generado
     por un suplemento de redistribución de cartera (la segunda fase de la redistribución).
     Esta función se llamará en el momento de asignar las participaciones a los movimientos
     realizados en el día, por tanto, al llamar a la función F_ASIGN_UNIDADES del mismo Packaged.
   ***************************************************************************************/
   FUNCTION f_redist_asign_unidades(
      pfvalmov        IN       DATE,
      psproces        IN OUT   NUMBER,
      nerrores        IN OUT   NUMBER,
      pcidioma_user   IN       NUMBER,
      pcempres        IN       NUMBER,
      psseguro        IN       NUMBER DEFAULT NULL,
-- Bug 10828 - RSC - 15/09/2009 - CRE - Revisión de los productos PPJ dinámico y Pla Estudiant (ajustes)
      pfunds          IN       t_iax_produlkmodinvfondo DEFAULT NULL
   )                                  -- Bug 36746/0211309 - APD - 17/09/2015
      RETURN NUMBER;

   /***************************************************************************************
     SHADOW ACCOUNTS

     Esta función se encargará de asignar las unidades de los movimientos que se han generado
     por un suplemento de redistribución de cartera (la segunda fase de la redistribución).
     Esta función se llamará en el momento de asignar las participaciones a los movimientos
     realizados en el día, por tanto, al llamar a la función F_ASIGN_UNIDADES del mismo Packaged.
   ***************************************************************************************/
   FUNCTION f_redist_asign_unidades_shw(
      pfvalmov        IN       DATE,
      psproces        IN OUT   NUMBER,
      nerrores        IN OUT   NUMBER,
      pcidioma_user   IN       NUMBER,
      pcempres        IN       NUMBER,
      psseguro        IN       NUMBER DEFAULT NULL,
-- Bug 10828 - RSC - 15/09/2009 - CRE - Revisión de los productos PPJ dinámico y Pla Estudiant (ajustes)
      pfunds          IN       t_iax_produlkmodinvfondo DEFAULT NULL
   )                                  -- Bug 36746/0211309 - APD - 17/09/2015
      RETURN NUMBER;

   /***************************************************************************************
      Esta función realizará la asignación de participaciones a los movimientos realizados en
      el día sobre las pólizas Unit Linked y que por tanto no tienen calculadas.
    ***************************************************************************************/-- Bug 0018741 - JMF - 07/06/2011
   FUNCTION f_asign_unidades(
      pfvalmov        IN   DATE,
      pcidioma_user   IN   NUMBER,
      pcempres        IN   NUMBER,
      p_cesta         IN   NUMBER DEFAULT NULL,
      psseguro        IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER;

   /***************************************************************************************
       SHADOW ACCOUNTS
       Esta función realizará la asignación de participaciones a los movimientos realizados en
       el día sobre las pólizas Unit Linked y que por tanto no tienen calculadas.
     ***************************************************************************************/-- Bug 0018741 - JMF - 07/06/2011
   FUNCTION f_asign_unidades_shw(
      pfvalmov        IN   DATE,
      pcidioma_user   IN   NUMBER,
      pcempres        IN   NUMBER,
      p_cesta         IN   NUMBER DEFAULT NULL,
      psseguro        IN   NUMBER DEFAULT NULL
   )                                          -- Bug 18851 - RSC - 23/06/2011
      RETURN NUMBER;

    /******************************************************************************
    RSC 24-08-2007
    Función de carga de valores liquidativos
   ******************************************************************************/
   FUNCTION p_insertar_vliquidativo(
      linea      IN   VARCHAR2,
      pcempres   IN   NUMBER,
      pfvalor    IN   DATE
   )
      RETURN NUMBER;

    /******************************************************************************
    RSC 23-08-2007
    Actualización de los valores principales de fondo relacionado con el FONOPER2
    (alulk052)
   ******************************************************************************/
   PROCEDURE p_actualizar_fondo(
      fvalora     IN   DATE,
      pfonoper2   IN   fonoper2%ROWTYPE
   );

    /******************************************************************************
    RSC 22-08-2007
    Obtención del valor liquidativo registrado en tmp_vliquidativos2 para una
    determinada cesta y fecha. (alulk018_cs y alulk052)
   ******************************************************************************/
   FUNCTION f_precio_uniactual(codigo IN NUMBER, fecha IN DATE)
      RETURN NUMBER;

   /******************************************************************************
    RSC 22-08-2007
    Generación de la valoración de fondos y cestas a una fecha dada.
   ******************************************************************************/
   -- Bug 0018741 - JMF - 07/06/2011
   FUNCTION f_valorar(
      fvalora     IN   DATE,
      pcempres    IN   NUMBER,
      p_ccodfon   IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER;

   /******************************************************************************
    RSC 22-08-2007
    Proposición de valores de compra (a Invertir en el fondo) y venta (venta de unidades
    del fondo). Estos valores se calculan a partir de las aportaciones realizadas en una
    fecha dada.
   ******************************************************************************/
   --PROCEDURE p_proponer_valores(codfon IN NUMBER, ceston IN NUMBER, fvalora IN DATE, iuniact IN OUT NUMBER, iimpcmp IN OUT NUMBER, nunivnt IN OUT NUMBER);
   PROCEDURE p_proponer_valores(
      codfon    IN       NUMBER,
      fvalora   IN       DATE,
      iimpcmp   IN OUT   NUMBER,
      nunivnt   IN OUT   NUMBER
   );

   /******************************************************************************
    RSC 22-08-2007
    Grabación de la valoración de la cesta en la tabla TABVALCES.
   ******************************************************************************/
   PROCEDURE p_historico_cesta (cesta IN NUMBER, fecha IN DATE);

   --PROCEDURE f_insertar_valoraciones_fondos (pfecha IN date);

   /******************************************************************************
    RSC 20-08-2007
    Abrir los fondos de inversión a una fecha determinada (registra en FONESTADO)
   ******************************************************************************/
   FUNCTION p_modifica_estadofondos(
      pcempres   IN   NUMBER,
      pfvalor    IN   DATE,
      pestado    IN   VARCHAR2
   )
      RETURN NUMBER;

   /******************************************************************************
    RSC 20-08-2007
    Devuelve el estado general de los fondos de inversión a una fecha dada:
        Si todos abierto --> return abierto
        Si alguno cerrado --> return cerrado
        Si todos cerrados --> return cerrado
        Sino --> return cerrado.
   ******************************************************************************/
   FUNCTION f_cambio_aestado(
      pcempres   IN       NUMBER,
      fvalor     IN       DATE,
      paestado   OUT      VARCHAR2
   )
      RETURN VARCHAR2;

   /******************************************************************************
    Devuelve el estado general de los fondos de inversión a una fecha dada.
        Si todos abierto --> return abierto
        Si alguno cerrado --> return cerrado
        Si todos cerrados --> return cerrado
        Sino --> return cerrado.
   ******************************************************************************/
   FUNCTION f_get_estado(pcempres IN NUMBER, fvalor IN DATE)
      RETURN VARCHAR2;

   /******************************************************************************
    RSC 25-09-2007
    Función de carga de valores liquidativos del directorio e:\Interfases\in del
    servidor.
   ******************************************************************************/
   FUNCTION f_carga_fichero_vliquidativo(
      pdirname           VARCHAR2,
      pnom_fitxer        VARCHAR2,
      pcempres      IN   NUMBER,
      pfvalor       IN   DATE
   )
      RETURN NUMBER;

   FUNCTION f_proponer_entradas_salidas(
      pfvalor          IN       DATE,
      pcesta           IN       NUMBER,
      pentradas        OUT      NUMBER,
      psalidas         OUT      NUMBER,
      pcompras         OUT      NUMBER,
      pentunidades     OUT      NUMBER,
      psalunidades     OUT      NUMBER,
      psaldocesta      OUT      NUMBER,
      pvliquid         OUT      NUMBER,
      pvliquidcmp      OUT      NUMBER,
      pvliquidvtashw   OUT      NUMBER,
      pvliquidcmpshw   OUT      NUMBER
   )
      RETURN NUMBER;

   /***************************************************************************
      RSC 15/01/2008
      Función para el cálculo de las entradas y salidas de una cesta consolidadas
      a fecha de la ultima fecha de asignación de participaciones anterior a la
      fecha de emisión pasada por parámetro.
    ***************************************************************************/
   FUNCTION f_entsal_consolidado(
      pfvalor        IN       DATE,
      pcesta         IN       NUMBER,
      pcramo         IN       ramos.cramo%TYPE,
      psproduc       IN       productos.sproduc%TYPE,
      pcagente       IN       seguros.cagente%TYPE,
      pentradas      OUT      NUMBER,
      psalidas       OUT      NUMBER,
      pcompras       OUT      NUMBER,
      pentunidades   OUT      NUMBER,
      psalunidades   OUT      NUMBER,
      psaldocesta    OUT      NUMBER,
      pvliquid       OUT      NUMBER
   )
      RETURN NUMBER;

   /***************************************************************************
      SHADOW ACCOUNTS

      Función para el cálculo de las entradas y salidas de una cesta consolidadas
      a fecha de la ultima fecha de asignación de participaciones anterior a la
      fecha de emisión pasada por parámetro.
    ***************************************************************************/
   FUNCTION f_entsal_consolidado_shw(
      pfvalor        IN       DATE,
      pcesta         IN       NUMBER,
      pcramo         IN       ramos.cramo%TYPE,
      psproduc       IN       productos.sproduc%TYPE,
      pcagente       IN       seguros.cagente%TYPE,
      pentradas      OUT      NUMBER,
      psalidas       OUT      NUMBER,
      pcompras       OUT      NUMBER,
      pentunidades   OUT      NUMBER,
      psalunidades   OUT      NUMBER,
      psaldocesta    OUT      NUMBER,
      pvliquid       OUT      NUMBER
   )
      RETURN NUMBER;

   /*******************************************************************************
     Finalidad de esta función:
     En caso de anulación de aportación, en Unit Linked la fvalmov puede resultar
     con una fecha anterior a la del dia (ya que se deben valorar con la fecha de
     la aportación o la fecha de la redistribución en caso de haber una redistribu-
     ción por en medio). En este caso esta anulación de aportación no se contabilizaria
     por la función f_proporner_entradas_salidas ya que esa función solo tiene en cuenta
     el campo fvalmov del dia (on-line). Esta función pretende resolver este problema.
   *******************************************************************************/
   FUNCTION ff_entsal_anulaciones(pfefecto IN DATE, pcesta IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_proponer_ent_sal(
      pfvalor            IN       DATE,
      pcesta             IN       NUMBER,
      pentradas          OUT      NUMBER,
      pentradas_teo      OUT      NUMBER,
      psalidas           OUT      NUMBER,
      psalidas_teo       OUT      NUMBER,
      pentunidades       OUT      NUMBER,
      pentunidades_teo   OUT      NUMBER,
      psalunidades       OUT      NUMBER,
      psalunidades_teo   OUT      NUMBER,
      pcompras           OUT      NUMBER,
      pvliquid           OUT      NUMBER,
      pvliquidcmp        OUT      NUMBER,
      pvliquidvtashw     OUT      NUMBER,
      pvliquidcmpshw     OUT      NUMBER,
      pentrada_penali    OUT      NUMBER
   )
      RETURN NUMBER;

   /******************************************************************************
    Devuelve el estado general de un fondos de inversión a una fecha dada.
        Si todos abierto --> return abierto
        Si alguno cerrado --> return cerrado
        Si todos cerrados --> return cerrado
        Sino --> return cerrado.
   ******************************************************************************/
   FUNCTION f_get_estado_fondo(
      pcempres   IN   NUMBER,
      fvalor     IN   DATE,
      pcesta     IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER;

   -- Bug 0018741 - JMF - 07/06/2011
   /*************************************************************************
      FUNCTION f_carga_valliqdiario
      Carga de valor liquidativo diario (Se llama desde un job).
      p_cesta in : Codigo cesta opcional (si es vacio seran todas)
      p_fecha in : Fecha opcional (si es vacio sera la del dia)
      return               : 0 OK - codigo error
   *************************************************************************/
   FUNCTION f_carga_valliqdiario(
      p_cesta   IN   NUMBER DEFAULT NULL,
      p_fecha   IN   DATE DEFAULT NULL
   )
      RETURN NUMBER;

   /******************************************************************************
      función que graba o actualiza la tabla fondos

      param in:       pcempres
      param in out:   pccodfon
      param in:       ptfonabv
      param in:       ptfoncmp
      param in:       pcmoneda
      param in:       pcmanager
      param in:       pnmaxuni
      param in:       pigasttran
      param in:       pfinicio
      param in:       pcclsfon
      param in:       pctipfon
      param in out:   mensajes

     ******************************************************************************/
   FUNCTION f_set_fondo(
      pcempres      IN       NUMBER,
      pccodfon      IN OUT   NUMBER,
      ptfonabv      IN       VARCHAR2,
      ptfoncmp      IN       VARCHAR2,
      pcmoneda      IN       NUMBER,
      pcmanager     IN       NUMBER,
      pnmaxuni      IN       NUMBER,
      pigasttran    IN       NUMBER,
      pfinicio      IN       DATE,
      pcclsfon      IN       NUMBER,
      pctipfon      IN       NUMBER,
      pcmodabo      IN       NUMBER,
      pndayaft      IN       NUMBER,
      pnperiodbon   IN       NUMBER,
      pcdividend    IN       NUMBER,                       --JCP 33665/215220
      mensajes      IN OUT   t_iax_mensajes
   )
      RETURN NUMBER;

   /******************************************************************************
      función que graba o actualiza el estado de un fondo.

      param in:       pccodfon
      param in :      pfecha
      param in:       ptfonabv
      param in out:   mensajes

     ******************************************************************************/
   FUNCTION f_set_estado_fondo(
      pccodfon   IN       NUMBER,
      pfecha     IN       DATE,
      pcestado   IN       VARCHAR2,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN NUMBER;

   FUNCTION f_valora_siniestros_fnd(
      pfvalmov    IN       DATE,
      pcesta      IN       NUMBER,
      psseguro    IN       NUMBER,
      psproces    IN OUT   NUMBER,
      pnerrores   IN OUT   NUMBER,
      pcidioma    IN       NUMBER,
      pccausin    IN       NUMBER
   )
      RETURN NUMBER;

   FUNCTION f_asign_dividends(
      pmodo           IN       VARCHAR2,
      pccodfon        IN       NUMBER,
      pfvigencia      IN       DATE,
      pfvalmov        IN       DATE,
      piimpdiv        IN       NUMBER,
      psproces        IN OUT   NUMBER,
      plineas         IN OUT   NUMBER,
      plineas_error   IN OUT   NUMBER
   )
      RETURN NUMBER;
END pac_mantenimiento_fondos_finv;

/

  GRANT EXECUTE ON "AXIS"."PAC_MANTENIMIENTO_FONDOS_FINV" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MANTENIMIENTO_FONDOS_FINV" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MANTENIMIENTO_FONDOS_FINV" TO "PROGRAMADORESCSI";
