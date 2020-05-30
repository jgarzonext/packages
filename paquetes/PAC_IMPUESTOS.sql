--------------------------------------------------------
--  DDL for Package PAC_IMPUESTOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IMPUESTOS" IS
/******************************************************************************
   NOMBRE:     PAC_IMPUESTOS
   PROP¿SITO:  Funciones del modelo de impuestos

   REVISIONES:
   Ver        Fecha        Autor             Descripci¿n
   ---------  ----------  ---------------  ------------------------------------
   1.0        XX/XX/XXXX   XXX                1. Creaci¿n del package.
   1.1        30/01/2009   JTS                2. Se corrigen fallos.
   2.0        09/06/2010   AMC                3. Se a¿aden nuevas funciones bug 14748
   3.0        21/11/2011   JMP                4. BUG 18423: LCOL000 - Multimoneda
   4.0        19/03/2012   JMF                0021655 MDP - TEC - C¿lculo del Consorcio
   5.0        16/11/2012   XVM                5. 0024656: MDP_T001-Ajustes finalies en implataci?n de Suplementos
******************************************************************************/
   FUNCTION f_insert_impempres(pcconcep IN NUMBER, pcempres IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_delete_impempres(pcconcep IN NUMBER, pcempres IN NUMBER)
      RETURN NUMBER;

/*************************************************************************
      Inserta los impuestos en la tabla imprec
      param in pcempres  : empresa
      param in pcconcep  : impuesto
      param in pnconcep  : secuencia de concepto
      param in pcforpag  : codigo formad pago
      param in pcramo    : codigo ramo
      param in psproduc  : codigo de modalidad
      param in pcactivi  : codigo de actividad
      param in pcgarant  : codigo de garantia
      param in pfinivig  : fecha inicio vigencia
      param in pctipcon  : c¿digo tipo concepto
      param in pnvalcon  : valor del concepto
      param in pcfracci  : fraccionar
      param in pcbonifi  : aplicar a prima con bonificaci¿n
      param in pcrecfra  : aplicar a prima con recargo fraccionamiento

      return             : numero de error
   *************************************************************************/
   FUNCTION f_insert_imprec(
      pcconcep IN NUMBER,
      pcempres IN NUMBER,
      pnconcep IN NUMBER,
      pcforpag IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pfinivig IN DATE,
      pctipcon IN NUMBER,
      pnvalcon IN NUMBER,
      pcfracci IN NUMBER,
      pcbonifi IN NUMBER,
      pcrecfra IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
      Calcula importe del concepto

      pnvalcon      IN NUMBER,                -- Valor del concepto.
      piconcep0     IN NUMBER,                -- Prima neta.
      piconcep21    IN NUMBER,                -- Prima devengada.
      pidto         IN NUMBER,                -- Descuento comercial.
      pidto21       IN NUMBER,                -- Descuento comercial (Bonificacion Anualizada).
      pidtocam      IN NUMBER,                -- Descuento campa¿a.
      picapital     IN NUMBER,                -- Capital (para impuestos sobre capital)
      ptotrecfracc  IN NUMBER,                -- Total Recargo de fraccionamiento
      pprecfra      IN NUMBER,                -- Porcentaje de recargo de fraccionamiento.
      pctipcon      IN NUMBER,                -- Tipo de concepto.
      pcforpag      IN NUMBER,                -- Forma de pago.
      pcfracci      IN NUMBER,                -- Fraccionamiento.
      pcbonifi      IN NUMBER,                -- No se utiliza por ahora (NULL).
      pcrecfra      IN NUMBER,                -- Recargo por fraccionamiento.
      oiconcep      OUT NUMBER,               -- Importe resultante para el concepto.
      pgastos       IN NUMBER DEFAULT NULL,   -- Gastos de emisi¿n. Concepto 14. derechos de registro
      pcderreg      IN NUMBER DEFAULT NULL,   -- si aplica derechos de registro en el calculo de impuestos
      piconcep0neto IN NUMBER DEFAULT NULL,   -- prima neta retenida (solo iconcep0), en el pincocep0, llega en icocep0 + inconcep50
      pfefecto      IN DATE   DEFAULT NULL,
      psseguro      IN NUMBER DEFAULT NULL,
      pnriesgo      IN NUMBER DEFAULT NULL,
      pcgarant      IN NUMBER DEFAULT NULL,
      pcmoneda      IN NUMBER DEFAULT NULL,
      pttabla       IN VARCHAR2 DEFAULT 'SEG' -- Tablas SEG=Reales, EST=Estudio
      --BUG 24656-XVM-16/11/2012.A¿adir paccion
      paccion       IN NUMBER DEFAULT NULL  Indica si estamos en suplemento o no. 0-Nueva Prod. 2-Suplemento

      return        : 0=Correcto, numero=C¿digo de error
      -- Bug 0021655 - 19/03/2012 - JMF
   *************************************************************************/
   FUNCTION f_calcula_impconcepto(
      pnvalcon IN NUMBER,
      piconcep0 IN NUMBER,
      piconcep21 IN NUMBER,
      pidto IN NUMBER,
      pidto21 IN NUMBER,
      pidtocam IN NUMBER,
      picapital IN NUMBER,
      ptotrecfracc IN NUMBER,
      pprecfra IN NUMBER,
      pctipcon IN NUMBER,
      pcforpag IN NUMBER,
      pcfracci IN NUMBER,
      pcbonifi IN NUMBER,
      pcrecfra IN NUMBER,
      oiconcep OUT NUMBER,
      pgastos IN NUMBER DEFAULT NULL,
      pcderreg IN NUMBER DEFAULT NULL,
      piconcep0neto IN NUMBER DEFAULT NULL,
      pfefecto IN DATE DEFAULT NULL,
      psseguro IN NUMBER DEFAULT NULL,
      pnriesgo IN NUMBER DEFAULT NULL,
      pcgarant IN NUMBER DEFAULT NULL,
      pcmoneda IN NUMBER DEFAULT NULL,
      pttabla IN VARCHAR2 DEFAULT 'SEG',
      paccion IN NUMBER DEFAULT 1,
      parbitri IN NUMBER DEFAULT NULL,
      pnmovimi IN NUMBER DEFAULT NULL,
      ptipomovimiento IN NUMBER DEFAULT NULL)   --BUG 0034505 - FAL - 17/03/2015
      RETURN NUMBER;

   FUNCTION f_calcula_impuestocapital(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnriesgo IN NUMBER,
      pmode IN VARCHAR2,
      pcampimp IN VARCHAR2,
      ototcapital OUT NUMBER,
      pcgarant IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   /*************************************************************************
      Borra los impuestos en la tabla imprec
      param in pcempres  : empresa
      param in pcconcep  : impuesto
      param in pnconcep  : secuencia de concepto
      param in pcforpag  : codigo formad pago
      param in pfinivig  : fecha inicio vigencia

      return             : numero de error

      Bug 14748 - 10/06/2010 - AMC
   *************************************************************************/
   FUNCTION f_del_imprec(
      pcconcep IN NUMBER,
      pcempres IN NUMBER,
      pnconcep IN NUMBER,
      pcforpag IN NUMBER,
      pfinivig IN DATE)
      RETURN NUMBER;

   /*************************************************************************
      Devuelve un reargo por fraccionamiento
      param in pcempres  : empresa
      param in pcconcep  : impuesto
      param in pnconcep  : secuencia de concepto
      param in pfinivig  : fecha inicio vigencia
      param out pctipcon : codigo tipo de concepto
      param out pnvalcon : valor del concepto
      param out pcbonifi : si aplica a prima con bonificacion
      param out pcfracci : fraccionar
      param out pcrecfra : si aplica a prima con recargo fraccionamiento
      return             : numero de error

      Bug 14748 - 13/09/2010 - AMC
   *************************************************************************/
   FUNCTION f_get_recargo(
      pcconcep IN NUMBER,
      pcempres IN NUMBER,
      pnconcep IN NUMBER,
      pfinivig IN DATE,
      pctipcon OUT NUMBER,
      pnvalcon OUT NUMBER,
      pcbonifi OUT NUMBER,
      pcfracci OUT NUMBER,
      pcrecfra OUT NUMBER)
      RETURN NUMBER;

/*************************************************************************
             FUNCTION f_reteica_provin
    Encontrar el valor reteica
    param in pcagente    : codigo agente
    param out pvalor  : devuelve el valor de la provincia para aplicar el reteica
 *************************************************************************/
   FUNCTION f_reteica_provin(pcagente IN NUMBER)
      RETURN NUMBER;

    /*************************************************************************
               FUNCTION f_reteica_poblac
      Encontrar el valor reteica
      param in pcagente    : codigo agente
      param out pvalor  : devuelve el valor de la poblacion para aplicar el reteica
   *************************************************************************/
   FUNCTION f_reteica_poblac(pcagente IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
         FUNCTION f_retefuente
      Encontrar el valor retefuente
      param in pcagente    : codigo agente
      param out pretefuente  : devuelve el valor del retefuente a buscar dentro de las vigencias
   *************************************************************************/
   FUNCTION f_retefuente(pcagente IN NUMBER)
      RETURN NUMBER;
END;

/

  GRANT EXECUTE ON "AXIS"."PAC_IMPUESTOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IMPUESTOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IMPUESTOS" TO "PROGRAMADORESCSI";
