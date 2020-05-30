--------------------------------------------------------
--  DDL for Package PAC_DESCUENTOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_DESCUENTOS" AUTHID CURRENT_USER IS
   /******************************************************************************
      NOMBRE:     PAC_DESCUENTOS
      PROPÓSITO:  Funciones de cuadros de descuentos

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        29/02/2012   JRB               1. Creación del package.
   ******************************************************************************/

   /*************************************************************************
      Recupera un cuadro de descuentos
      param in pcdesc   : codigo de descuento
      param in ptdesc   : descripcion del cuadro
      param in pctipo     : codigo de tipo
      param in pcestado   : codigo de estado
      param in pffechaini : fecha inicio
      param in pffechafin : fecha fin
      param in pidioma    : codigo del idioma
      param out pquery    : select a ejecutar
      return              : codigo de error
   *************************************************************************/
   FUNCTION f_get_cuadrosdescuento(
      pcdesc IN NUMBER,
      ptdesc IN VARCHAR2,
      pctipo IN NUMBER,
      pcestado IN NUMBER,
      pffechaini IN DATE,
      pffechafin IN DATE,
      pidioma IN NUMBER,
      pquery OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_set_cab_descuento(
      pcdesc IN NUMBER,
      pctipo IN NUMBER,
      pcestado IN NUMBER,
      pfinivig IN DATE,
      pffinvig IN DATE)
      RETURN NUMBER;

   FUNCTION f_set_descdescuento(pcdesc IN NUMBER, pcidioma IN NUMBER, ptdesc IN VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
      Duplica un cuadro de descuentos
      param in pcdesc_ori   : codigo de descuento original
      param in pcdesc_nuevo : codigo de descuento nuevo
      param in ptdesc_nuevo : texto cuadro descuento
      param in pidioma        : codigo de idioma

      return : codigo de error
   *************************************************************************/
   FUNCTION f_duplicar_cuadro(
      pcdesc_ori IN NUMBER,
      pcdesc_nuevo IN NUMBER,
      ptdesc_nuevo IN VARCHAR2,
      pidioma IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_get_detalle_descuento(
      pcdesc IN NUMBER,
      pcagrprod IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      ptodos IN NUMBER,
      pfinivig IN DATE DEFAULT NULL,
      pffinvig IN DATE DEFAULT NULL,
      porderby IN NUMBER,
      pidioma IN NUMBER,
      pcmoddesc IN NUMBER,
      pquery OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_set_detalle_descuento(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pnivel IN NUMBER,
      pfinivig IN DATE,
      pcmoddesc IN NUMBER,
      pcdesc IN NUMBER,
      ppdesc IN NUMBER,
      pninialt IN NUMBER,
      pnfinalt IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_get_hist_cuadrodescuento(
      pcdesc IN NUMBER,
      pidioma IN NUMBER,
      pquery OUT VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
      Devuelve los cuadros de descuento con su % si lo tiene asignado
      param in psproduc   : codigo de producto
      param in pcactivi   : codigo de la actividad
      param in pcgarant   : codigo de la garantia
      param in pnivel     : codigo de nivel (1-Producto,2-Actividad,3-Garantia)
      param in pidioma    : codigo de idioma
      param out psquery   : consulta a ejecutar

      return : codigo de error
   *************************************************************************/
   FUNCTION f_get_porproducto(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pcnivel IN NUMBER,
      pcfinivig IN DATE,
      pcidioma IN NUMBER,
      psquery OUT VARCHAR2)
      RETURN NUMBER;

/****************************************************************
      Duplica el detalle de descuento a partir de un cdesc y una fecha
      param in pcdesc   : codigo de descuento
      param in pfinivi   : Fecha de inicio de vigencia      return : codigo de error
   *************************************************************************/
   FUNCTION f_dup_det_descuento(pcdesc IN NUMBER, pfinivig IN DATE)
      RETURN NUMBER;

   /*************************************************************************
      Duplica un cuadro de descuentos de un producto
      param in pcdesc_ori   : codigo de descuento original
      param in pcdesc_nuevo : codigo de descuento nuevo
      param in ptdesc_nuevo : texto cuadro descuento
      param in pidioma        : codigo de idioma

      return : codigo de error
   *************************************************************************/
   FUNCTION f_duplicar_cuadro_prod(pcsproduc IN NUMBER, pcfinivig IN DATE)
      RETURN NUMBER;
END pac_descuentos;

/

  GRANT EXECUTE ON "AXIS"."PAC_DESCUENTOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_DESCUENTOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_DESCUENTOS" TO "PROGRAMADORESCSI";
