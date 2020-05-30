--------------------------------------------------------
--  DDL for Package PAC_SUP_DIFERIDOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_SUP_DIFERIDOS" AUTHID CURRENT_USER
IS
/******************************************************************************
      NOMBRE:      PAC_SUP_DIFERIDOS  (Entorno AXIS)
      PROPÓSITO:   Package con proposito de negocio para el lanzamiento programado
                   de suplementos, ya sean automáticos o diferidos. Este tipo de
                   suplementos en principio se lanzarán desde cartera.

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        07/04/2009     RSC              1. -- Bug 9153 - Suplementos automáticos - Creación del package.
      2.0        27/04/2009     RSC              2. Suplemento de cambio de forma de pago diferido
      3.0        05/11/2010     APD              3. 16095 - Implementacion y parametrizacion producto GROUPLIFE
      4.0        03/12/2012     APD              4. 0024278: LCOL_T010 - Suplementos diferidos - Cartera - colectivos
      5.0        11/03/2013     APD              5. 0026070: LCOL_T010-LCOL - Revision incidencias qtracker (V)
      6.0        18/01/2016     MRB              6. 0039258: ENTORNO AXIS QT_22561 LCOL
                                                             (22561 + 39258)/: MRB - 18/01/2016
                                                             Al realizar un suplemento en el certificado cero de un colectivo,
                                                             se generan los suplementos diferidos para el resto de certificados
                                                             de dicho colectivo.
                                                             Cálculo de FCARANU en los casos de CSITUAC = 4 y CRETENI 0 y 2.
                                                             Propuestas retenidas o pendientes de EMITIR, que por este motivo
                                                             no tienen el campo FCARANU informado. Esto provoca el error :
                                                             Se ha producido un error en la emisión de la póliza 'nnnnnnn
                                                             póngase en contacto con el departamento de Vida.
                                                             Se crea nueva función f_calcula_fcaranu
   ******************************************************************************/

   -- Bug 9153 - 07/04/2009 - RSC - Suplementos automáticos
   FUNCTION iniciarsuple
      RETURN NUMBER;

   -- Fin Bug 9153

   /***********************************************************************
      Función que nos indicará si para un determinado contrado se debe evaluar
      si se ha de lanzar o no un suplemento automático.

      param in psseguro  : Código de seguro
      return             : Number (1--> SI, 0 --> No).
   ***********************************************************************/
   -- Bug 9153 - 07/04/2009 - RSC - Suplementos automáticos
   FUNCTION f_eval_automaticos (psseguro IN NUMBER)
      RETURN NUMBER;

   -- Fin Bug 9153

   /***********************************************************************
      Evalua si se ejecutará un suplemento automático para un determinado
      contrado y fecha de cartera.

      param in psseguro  : Código de seguro
      param in pfecha    : Fecha de suplemento (fecha de carte del producto)
      param in psproces  : Identificador de proceso para dejar trazas informativas.
      return             : Number (0--> OK, 1 --> Error).
   ***********************************************************************/
   -- Bug 9153 - 14/05/2009 - RSC - Suplementos automáticos
   FUNCTION f_eval_autodif_cartera (
      psseguro    IN   NUMBER,
      pfcarpro    IN   DATE,
      pfcartera   IN   DATE,
      pcidioma    IN   NUMBER
   )
      RETURN VARCHAR2;

   /***********************************************************************
      Función que inicia el proceso de evaluación de suplementos automáticos
      para un deteminado contrato a una fecha.

      param in psseguro  : Código de seguro
      param in pfecha    : Fecha de suplemento (fecha de carte del producto)
      param in psproces  : Identificador de proceso para dejar trazas informativas.
      param in pcmotmov  : Motivo suplemento opcional
      return             : Number (0--> OK, 1 --> Error).
   ***********************************************************************/
   -- Bug 9153 - 07/04/2009 - RSC - Suplementos automáticos
   -- Bug 0011348: Afegir parametre opcional motiu.
   FUNCTION f_gen_supl_automaticos (
      psseguro   IN   NUMBER,
      pfecha     IN   DATE,
      psproces   IN   NUMBER,
      pcmotmov   IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER;

   -- Fin Bug 9153

   /***********************************************************************
      Función específica para el lanzamiento de un suplemento automático a
      nivel de negocio.

      param in psseguro  : Código de seguro
      param in psproduc  : Código de producto.
      param in pnorden   : Código de orden.
      param in pfecha    : Fecha de suplemento.
      param in pcmotmov  : Código de motivo de movimiento.
      param in pnriesgo  : Importe de operación.
      param in pcgarant  : Código de garantía.
      param in psproces  : Identificador de proceso para dejar trazas informativas.
      return             : Number (0--> OK, 1 --> Error).
   ***********************************************************************/
   -- Bug 9153 - 07/04/2009 - RSC - Suplementos automáticos
   FUNCTION f_supl_automatic (
      psseguro   IN   NUMBER,
      psproduc   IN   NUMBER,
      pnorden    IN   NUMBER,
      pfecha     IN   DATE,
      pcmotmov   IN   NUMBER,
      pnriesgo   IN   NUMBER,
      pcgarant   IN   NUMBER,
      psproces   IN   NUMBER,
      pcemite    IN   NUMBER DEFAULT 1
   )                                          -- Bug 16095 - APD - 05/11/2010
      RETURN NUMBER;

   -- Fin Bug 9153

   /***********************************************************************
      Función que nos indicará si para un determinado contrato se debe evaluar
      un suplemento diferido a una fecha.

      param in psseguro  : Código de seguro
      return             : Number (1--> SI, 0 --> No).
   ***********************************************************************/
   -- Bug 9905 - 24/04/2009 - RSC - Suplemento de cambio de forma de pago diferido
   FUNCTION f_eval_diferidos (psseguro IN NUMBER, pfecha IN DATE)
      RETURN NUMBER;

   -- Bug 9905

   /***********************************************************************
      Función que nos indicará si para un determinado contrato se debe evaluar
      un suplemento diferido a futuro respecto una fecha.

      param in psseguro  : Código de seguro
      return             : Number (1--> SI, 0 --> No).
   ***********************************************************************/
   -- Bug 9905 - 24/04/2009 - RSC - Suplemento de cambio de forma de pago diferido
   FUNCTION f_eval_diferidos_futuro (psseguro IN NUMBER, pfecha IN DATE)
      RETURN NUMBER;

   /***********************************************************************
      Evalua si se ejecutará un suplemento diferido para un determinado
      contrado y fecha de cartera.

      param in psseguro  : Código de seguro
      param in pfecha    : Fecha de suplemento (fecha de carte del producto)
      param in psproces  : Identificador de proceso para dejar trazas informativas.
      return             : Number (0--> OK, 1 --> Error).
   ***********************************************************************/
   -- Bug 9153 - 14/05/2009 - RSC - Suplementos automáticos
   /*
   FUNCTION f_eval_diferidos_cartera(psseguro  IN NUMBER,
                                     pfcarpro  IN DATE,
                                     pfcartera IN DATE,
                                     pcidioma  IN NUMBER)
      RETURN VARCHAR2;
   */

   /***********************************************************************
      Función que inicia el proceso de evaluación de suplementos diferidos
      para un deteminado contrato a una fecha.

      param in psseguro  : Código de seguro
      param in pfecha    : Fecha de suplemento (fecha de carte del producto)
      param in psproces  : Identificador de proceso para dejar trazas informativas.
      return             : Number (0--> OK, 1 --> Error).
   ***********************************************************************/
   -- Bug 9905 - 24/04/2009 - RSC - Suplemento de cambio de forma de pago diferido
   FUNCTION f_gen_supl_diferidos (
      psseguro   IN   NUMBER,
      pfecha     IN   DATE,
      psproces   IN   NUMBER
   )
      RETURN NUMBER;

   -- Fin Bug 9905

   /***********************************************************************
      Función específica para el lanzamiento de un suplemento automático a
      nivel de negocio.

      param in psseguro  : Código de seguro
      param in psproduc  : Código de producto.
      param in pnorden   : Código de orden.
      param in pfecha    : Fecha de suplemento.
      param in pcmotmov  : Código de motivo de movimiento.
      param in pnriesgo  : Importe de operación.
      param in pcgarant  : Código de garantía.
      param in psproces  : Identificador de proceso para dejar trazas informativas.
      return             : Number (0--> OK, 1 --> Error).
   ***********************************************************************/
   -- Bug 9905 - 24/04/2009 - RSC - Suplemento de cambio de forma de pago diferido
   FUNCTION f_supl_diferidos (
      psseguro       IN   NUMBER,
      pfecha         IN   DATE,
      pcmotmov       IN   NUMBER,
      pnriesgo       IN   NUMBER,
      pcgarant       IN   NUMBER,
      psproces       IN   NUMBER,
      pvalida_supl   IN   NUMBER DEFAULT 1
   )                                          -- Bug 26070 - APD - 11/03/2013
      RETURN NUMBER;

   -- Fin Bug 9905

   /***********************************************************************
      Evalua si se ejecutará un suplemento diferido para un determinado
      contrado y fecha de cartera.

      param in psseguro  : Código de seguro
      param in pfecha    : Fecha de suplemento (fecha de carte del producto)
      param in psproces  : Identificador de proceso para dejar trazas informativas.
      return             : Number (0--> OK, 1 --> Error).
   ***********************************************************************/
   -- Bug 9153 - 14/05/2009 - RSC - Suplementos automáticos
   FUNCTION f_eval_genera_map (
      pempres      IN       NUMBER,
      psproces     IN       NUMBER,
      pfcartera    IN       DATE,
      pgeneramap   IN OUT   NUMBER
   )
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_propaga_suplemento
      Funcion que, dado un suplemento en una poliza Colectiva (ncertif = 0),
      propaga ese suplemento (como suplemento diferido) a sus certificados
      (ncertif <> 0).
      param in psseguro  : Identificador de la poliza colectiva (ncertif = 0)
      param in pcmotmov  : codigo de movimiento del suplemento
      param in pnmovimi  : numero de movimiento del suplemento
      param in pfefecto  : fecha de efecto del suplemento
      return             : NUMBER (1 se ha producido un error, 0 ha ido todo bien)
   *************************************************************************/
   -- Bug 24278 - APD - 19/11/2012 - se crea la funcion
   FUNCTION f_propaga_suplemento (
      psseguro   IN   NUMBER,
      pcmotmov   IN   NUMBER,
      pnmovimi   IN   NUMBER,
      pfefecto   IN   DATE
   )
      RETURN NUMBER;

/*******************************************************************************
   Proceso que ejecuta los suplementos diferidos/automaticos
   pcempres PARAM IN: Empresa
   psproduc  PARAM IN : Producto
   psseguro PARAM IN : Seguro
   pfecha PARAM IN : Fecha referencia para ejecutar el suplemento
   psproces PARAM OUT : Proceso generado.
********************************************************************************/-- Bug 24278 - APD - 20/11/2012 - se crea la funcion
   PROCEDURE p_ejecuta_suplemento (
      pcempres   IN       NUMBER,
      psproduc   IN       NUMBER,
      psseguro   IN       NUMBER,
      pfecha     IN       DATE,
      pnmovimi   IN       NUMBER,
      psproces   IN OUT   NUMBER
   );

-- Bug 24278 - APD - 03/11/2012 - se crea la funcion
/*******************************************************************************
   Funcion que ejecuta los suplementos diferidos/automaticos programados para
   un colectivo para un movimiento determinado
   psseguro PARAM IN : Seguro
   pnmovimi PARAM IN : Movimiento del suplemento
   psproces PARAM OUT : Proceso generado.
********************************************************************************/
   FUNCTION f_ejecuta_supl_certifs (
      psseguro   IN       NUMBER,
      pnmovimi   IN       NUMBER,
      psproces   IN OUT   NUMBER
   )
      RETURN NUMBER;

-- Bug 24278 - APD - 10/12/2012 - se crea la funcion
/*******************************************************************************
   Funcion que pregunta si se existe algun suplemento que se debe propagar
   ptablas PARAM IN : EST o REA
   psseguro PARAM IN : Seguro
   pnmovimi PARAM IN : Movimiento del suplemento
   pcmotmov PARAM IN : Motivo
   pcidioma PARAM IN : Idioma
   opropaga PARAM OUT: 0.-No se propaga ningún suplemento
                       1.-Si se propaga algún suplemento
   otexto PARAM OUT : Texto de la pregunta que se le realiza al usuario
                      (solo para el caso cvalpar = 2)
********************************************************************************/
   FUNCTION f_pregunta_propaga_suplemento (
      ptablas    IN       VARCHAR2,
      psseguro   IN       NUMBER,
      pnmovimi   IN       NUMBER,
      pcmotmov   IN       NUMBER,
      pcidioma   IN       NUMBER,
      opropaga   OUT      NUMBER,
      otexto     OUT      VARCHAR2
   )
      RETURN NUMBER;

-- Bug 24278 - APD - 11/12/2012 - se crea la funcion
/*******************************************************************************
   Funcion que actualiza el valor del campo detmovseguro.cpropagasupl
   ptablas PARAM IN : EST o REA
   psseguro PARAM IN : Seguro
   pnmovimi PARAM IN : Movimiento del suplemento
   pcmotmov PARAM IN : Motivo
   pcpropagasupl PARAM IN : Valor que indica si se propaga el suplemento a sus certificado
                            en funcion de la decision del usuario
********************************************************************************/
   FUNCTION f_set_propaga_suplemento (
      ptablas         IN   VARCHAR2,
      psseguro        IN   NUMBER,
      pnmovimi        IN   NUMBER,
      pcmotmov        IN   NUMBER,
      pcpropagasupl   IN   NUMBER
   )
      RETURN NUMBER;

-- Bug 24278 - JMC - 04/01/2013 - se crea las funciones
/*******************************************************************************
   Funcion que es una adaptación de PK_NUEVA_PRODUCCION.f_valida_dependencias_k,
   se utiliza en el suplemento diferido de cambio de garantias, para calcular los
   capitales dependientes.
   psseguro PARAM IN : Seguro
   pnriesgo PARAM IN : Nº de riesgo
   pnmovimi PARAM IN : Movimiento del suplemento
   pcgarant PARAM IN : Código de garantia
   psproduc PARAM IN : Código producto
   pcactivi PARAM IN : Código actividad
   pnmovima PARAM IN : Número de movimiento del alta
********************************************************************************/
   FUNCTION f_sup_dif_valida_dependencias (
      psseguro   IN   NUMBER,
      pnriesgo   IN   NUMBER,
      pnmovimi   IN   NUMBER,
      pcgarant   IN   NUMBER,
      psproduc   IN   NUMBER,
      pcactivi   IN   NUMBER,
      pnmovima   IN   NUMBER DEFAULT 1
   )
      RETURN NUMBER;

/*******************************************************************************
   Funcion puente para poder llamar a la función pac_albsgt.f_tprefor, desde los
   suplementos diferidos, cuando se trata de evaluar las preguntas semi-automáticas
   ptprefor PARAM IN : Formula
   ptablas PARAM IN :  Tablas
   psseguro PARAM IN : Seguro
   pnriesgo PARAM IN : Nº de riesgo
   pfiniefe PARAM IN : fecha inicial efecto
   pnmovimi PARAM IN : Número movimiento
   pcgarant PARAM IN : Código de garantia
********************************************************************************/
   FUNCTION f_sup_dif_cal_pregar_semi (
      ptprefor   IN   VARCHAR2,
      ptablas    IN   VARCHAR2,
      psseguro   IN   NUMBER,
      pnriesgo   IN   NUMBER,
      pfiniefe   IN   DATE,
      pnmovimi   IN   NUMBER,
      pcgarant   IN   NUMBER
   )
      RETURN NUMBER;

   FUNCTION f_diferir_spl_renovavigen (
      psseguro   IN   NUMBER,
      pfecsupl   IN   DATE DEFAULT NULL,
      pnmovimi   IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER;

-- INICIO (22561 + 39258)/: MRB - 18/01/2016
   FUNCTION f_calcula_fcaranu (psseguro IN NUMBER)
      RETURN DATE;
-- FIN (22561 + 39258)/: MRB - 18/01/2016
END pac_sup_diferidos;

/

  GRANT EXECUTE ON "AXIS"."PAC_SUP_DIFERIDOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_SUP_DIFERIDOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_SUP_DIFERIDOS" TO "PROGRAMADORESCSI";
