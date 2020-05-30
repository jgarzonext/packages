--------------------------------------------------------
--  DDL for Package PAC_MD_IMPUESTOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_IMPUESTOS" AS
/******************************************************************************
   NOMBRE:     PAC_MD_IMPUESTOS
   PROPÓSITO:  Funciones del modelo de impuestos

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        10/12/2008   JTS                1. Creación del package.
   2.0        09/06/2010   AMC                2. Se añaden nuevas funciones bug 14748
******************************************************************************/

   /*************************************************************************
      Recupera los impuestos de una empresa
      param in pcempres  : empresa a consultar
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_impempres(pcempres IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Inserta impuestos para una empresa
      param in pcempres  : empresa
      param in pcconcep  : impuesto a insertar
      param out mensajes : mesajes de error
      return             : numero de error
   *************************************************************************/
   FUNCTION f_set_impempres(
      pcempres IN NUMBER,
      pcconcep IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Borra impuestos para una empresa
      param in pcempres  : empresa
      param in pcconcep  : impuesto a borrar
      param out mensajes : mesajes de error
      return             : numero de error
   *************************************************************************/
   FUNCTION f_del_impempres(
      pcempres IN NUMBER,
      pcconcep IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Recupera los impuestos segun los parámetros de entrada
      param in pcempres  : empresa
      param in pcconcep  : impuesto
      param in pnconcep  :
      param in pcforpag  ;
      param in psproduc  :
      param in pcramo    :
      param in pcactivi  :
      param in pcgarant  :
      param in pfinivig  :
      param in pffinvig  :
      param out mensajes : mesajes de error
      return ref cursor  :
   *************************************************************************/
   FUNCTION f_get_imprec(
      pcempres IN NUMBER,
      pcconcep IN NUMBER,
      pnconcep IN NUMBER,
      pcforpag IN NUMBER,
      psproduc IN NUMBER,
      pcramo IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pfinivig IN DATE,
      pffinvig IN DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

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
      param in pctipcon  : código tipo concepto
      param in pnvalcon  : valor del concepto
      param in pcfracci  : fraccionar
      param in pcbonifi  : aplicar a prima con bonificación
      param in pcrecfra  : aplicar a prima con recargo fraccionamiento
      param out mensajes : mesajes de error
      return             : numero de error
   *************************************************************************/
   FUNCTION f_set_imprec(
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
      pcrecfra IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Recupera los conceptos de recibo que se consideran impuestos o recargos
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_cconcep(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera los conceptos de recibo dados de alta para una empresa
      que se consideran impuestos o recargos
      param  in pcempres : empresa
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_cconcep_emp(pcempres IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera las formas de pago para un producto
      param  in psproduc : producto
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_cforpag(psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Borra los impuestos en la tabla imprec
      param in pcempres  : empresa
      param in pcconcep  : impuesto
      param in pnconcep  : secuencia de concepto
      param in pcforpag  : codigo formad pago
      param in pfinivig  : fecha inicio vigencia
      param in mensajes  : mensajes de error
      return             : numero de error

      Bug 14748 - 10/06/2010 - AMC
   *************************************************************************/
   FUNCTION f_del_imprec(
      pcconcep IN NUMBER,
      pcempres IN NUMBER,
      pnconcep IN NUMBER,
      pcforpag IN NUMBER,
      pfinivig IN DATE,
      mensajes IN OUT t_iax_mensajes)
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
      param in out mensajes  : mensajes de error

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
      pcrecfra OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_md_impuestos;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_IMPUESTOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_IMPUESTOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_IMPUESTOS" TO "PROGRAMADORESCSI";
