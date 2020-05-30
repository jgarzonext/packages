--------------------------------------------------------
--  DDL for Package PAC_MD_DESCUENTOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_DESCUENTOS" AUTHID CURRENT_USER IS
   /******************************************************************************
      NOMBRE:     PAC_MD_DESCUENTOS
      PROPÓSITO:  Funciones de cuadros de descuentos

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        01/03/2012   JRB               1. Creación del package.
   ******************************************************************************/

   /*************************************************************************
      Recupera un cuadro de descuentos
      param in pcdesc   : codigo de descuento
      param in ptdesc   : descripcion del cuadro
      param in pctipo     : codigo de tipo
      param in pcestado   : codigo de estado
      param in pffechaini : fecha inicio
      param in pffechafin : fecha fin
      param out pcuadros  : cuadros de descuento
      param out mensajes  : mensajes de error
      return              : codigo de error
   *************************************************************************/
   FUNCTION f_get_cuadrosdescuento(
      pcdesc IN NUMBER,
      ptdesc IN VARCHAR2,
      pctipo IN NUMBER,
      pcestado IN NUMBER,
      pffechaini IN DATE,
      pffechafin IN DATE,
      pcuadros OUT t_iax_cuadrodescuento,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

/*************************************************************************
      Recupera las descripciones de los descuentos
      param in pcdesc   : codigo de descuento
      param out pcuadros  : objeto con las descripciones
      param out mensajes  : mesajes de error
      return              : descripción del valor
   *************************************************************************/
   FUNCTION f_get_descdescuentos(
      pcdesc IN NUMBER,
      pcuadros OUT t_iax_desccuadrodescuento,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

    /*************************************************************************

      param in pcdesc   : codigo de descuento
      param in pcidioma     : codigo de idioma
      param in ptdesc   : descripcion del cuadro
      param out mensajes  : mesajes de error

      return : codigo de error
   *************************************************************************/
   FUNCTION f_set_obj_desccuadro(
      pcidioma IN NUMBER,
      pcdesc IN NUMBER,
      ptdesc IN VARCHAR2,
      pdescripciones IN OUT ob_iax_desccuadrodescuento,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

    /*************************************************************************

      param in pcdesc   : codigo de descuento
      param in pctipo     : codigo de tipo
      param in pcestado   : codigo de estado
      param in pfinivig   : fecha inicio vigencia
      param in pffinvig   : fecha fin vigencia
      param in pmodo      : codigo de modo
      param out mensajes  : mesajes de error

      return : codigo de error
   *************************************************************************/
   FUNCTION f_set_obj_cuadrodescuento(
      pcdesc IN NUMBER,
      pctipo IN NUMBER,
      pcestado IN NUMBER,
      pfinivig IN DATE,
      pffinvig IN DATE,
      pdescuento IN OUT ob_iax_cuadrodescuento,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

    /*************************************************************************
      Devuel un cuadro de descuento
      param in out pdescuento   : cuadro de descuento
      param out mensajes      : mesajes de error

      return : codigo de error
   *************************************************************************/
   FUNCTION f_set_traspaso_obj_bd(
      pdescuento IN OUT ob_iax_cuadrodescuento,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Duplica un cuadro de descuentos
      param in pcdesc_ori   : codigo de descuento original
      param in pcdesc_nuevo : codigo de descuento nuevo
      param in ptdesc_nuevo : texto cuadro descuento
      param out mensajes      : mesajes de error

      return : codigo de error
   *************************************************************************/
   FUNCTION f_duplicar_cuadro(
      pcdesc_ori IN NUMBER,
      pcdesc_nuevo IN NUMBER,
      ptdesc_nuevo IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Inicializa un cuadro de descuentos
      param out pcuadros  : cuadros de descuento
      param out mensajes  : mensajes de error
      return              : codigo de error
   *************************************************************************/
   FUNCTION f_get_cuadrodescuento(
      pcuadros OUT t_iax_cuadrodescuento,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_detalle_descuento(
      pcdesc IN NUMBER,
      pcagrprod IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      ptodos IN NUMBER,
      pcmoddesc IN NUMBER,
      pfinivig IN DATE DEFAULT NULL,
      pffinvig IN DATE DEFAULT NULL,
      porderby IN NUMBER,
      pt_descuento IN OUT t_iax_detdescuento,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_set_detalle_descuento(
      pcdesc IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pnivel IN NUMBER,
      pcmoddesc IN NUMBER,
      pfinivig IN DATE,
      ppdesc IN NUMBER,
      pninialt IN NUMBER,
      pnfinalt IN NUMBER,
      obdescuento IN OUT ob_iax_detdescuento,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_set_traspaso_detalle_obj_bd(
      t_detdescuento IN t_iax_detdescuento,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_hist_cuadrodescuento(
      pcdesc IN NUMBER,
      pdetdescuento OUT t_iax_cuadrodescuento,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

/*************************************************************************
      Devuelve los cuadros de descuento con su % si lo tiene asignado
      param in psproduc   : codigo de producto
      param in pcactivi   : codigo de la actividad
      param in pcgarant   : codigo de la garantia
      param in pnivel     : codigo de nivel (1-Producto,2-Actividad,3-Garantia)

      param out pt_descuento   : detalle cuadros descuento
      param out mensajes   : mensajes de error

      return : codigo de error
   *************************************************************************/
   FUNCTION f_get_porproducto(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pcnivel IN NUMBER,
      pcfinivig IN DATE,
      pt_descuento OUT t_iax_detdescuento,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

      /****************************************************************
      Duplica el detalle de descuento a partir de un cdesc y una fecha
      param in pcdesc   : codigo de descuento
      param in pfinivi   : Fecha de inicio de vigencia
      param out mensajes   : mensajes de error

      return : codigo de error
   *************************************************************************/
   FUNCTION f_dup_det_descuento(
      pcdesc IN NUMBER,
      pfinivig IN DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Recupera las fechas de vigencias de los cuadros
      param in pcdesc   : codigo de descuento
      param in pctipo     : codigo de tipo de consulta
      param out mensajes  : mensajes de error
      return              : codigo de error
   *************************************************************************/
   FUNCTION f_get_lsfechasvigencia(
      psproduc IN NUMBER,
      pctipo IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_duplicar_cuadro_prod(
      pcsproduc IN NUMBER,
      pfinivig IN DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_alturas(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pcdesc IN NUMBER,
      pcmoddesc IN NUMBER,
      pfinivig IN DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_del_altura(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pcdesc IN NUMBER,
      pcmoddesc IN NUMBER,
      pfinivig IN DATE,
      pninialt IN NUMBER,
      pnivel IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_md_descuentos;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_DESCUENTOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_DESCUENTOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_DESCUENTOS" TO "PROGRAMADORESCSI";
