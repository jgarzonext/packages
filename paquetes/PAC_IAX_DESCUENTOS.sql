--------------------------------------------------------
--  DDL for Package PAC_IAX_DESCUENTOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_DESCUENTOS" AUTHID CURRENT_USER IS
   /******************************************************************************
      NOMBRE:     PAC_IAX_DESCUENTOS
      PROPÓSITO:  Funciones de cuadros de descuentos

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        01/03/2012   JRB               1. Creación del package.
   ******************************************************************************/
   obdescuento    ob_iax_cuadrodescuento;
   t_descuento    t_iax_detdescuento;

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
      mensajes OUT t_iax_mensajes)
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
      pmodo IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_set_cuadrodescuento(
      pcdesc IN NUMBER,
      pctipo IN NUMBER,
      pcestado IN NUMBER,
      pfinivig IN DATE,
      pffinvig IN DATE,
      pdescripciones IN t_iax_info,
      pmodo IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
        Devuel un cuadro de descuento
        param in pcdesc   : codigo de descuento
        param in pcuadrodescuento: cuadro de descuento
        param out mensajes      : mesajes de error

        return : codigo de error
     *************************************************************************/
   FUNCTION f_get_obj_cuadrodescuento(
      pcdesc IN NUMBER,
      pcuadrodescuento OUT ob_iax_cuadrodescuento,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Traspasa a la BD el objeto descuento
      param out mensajes      : mesajes de error

      return : codigo de error
   *************************************************************************/
   FUNCTION f_set_traspaso_obj_bd(mensajes OUT t_iax_mensajes)
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
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Devuel un cuadro de descuento
      param in pcdesc   : codigo de descuento
      param in pcuadrodescuento : cuadro de descuento
      param out mensajes      : mesajes de error

      return : codigo de error
   *************************************************************************/
   FUNCTION f_get_cuadrodescuento(
      pcdesc IN NUMBER,
      pfinivig IN DATE DEFAULT NULL,
      pffinvig IN DATE DEFAULT NULL,
      pcuadrodescuento OUT ob_iax_cuadrodescuento,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Actualiza el cdesc de un cuadro de descuento
      param in pcdesc_ori   : codigo de descuento original
      param in pcdesc_nuevo : nuevo codigo de descuento
      param out mensajes      : mesajes de error

      return : codigo de error
   *************************************************************************/
   FUNCTION f_act_cdesc(pcdesc IN NUMBER, mensajes OUT t_iax_mensajes)
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
      pt_descuento OUT t_iax_detdescuento,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_detdesc_alt(
      pcdesc IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pnivel IN NUMBER,
      pcmoddesc IN NUMBER,
      pfinivig IN DATE,
      pt_descuento OUT t_iax_detdescuento,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_canc_detdesc_alt(
      pcdesc IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pnivel IN NUMBER,
      pcmoddesc IN NUMBER,
      pfinivig IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_del_detdesc_alt(
      pcdesc IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pnivel IN NUMBER,
      pcmoddesc IN NUMBER,
      pfinivig IN DATE,
      pninialt IN NUMBER,
      pelimina IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_set_traspaso_detalle_obj_bd(mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_obj_detalle_descuento(
      pdetalledescuento OUT t_iax_detdescuento,
      mensajes OUT t_iax_mensajes)
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
      pnindice IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_detalle_descuento_obj(
      pcdesc IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pcmoddesc IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_detdescuento;

   FUNCTION f_get_hist_cuadrodescuento(
      pcdesc IN NUMBER,
      pdetdescuento OUT t_iax_cuadrodescuento,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_detalle_descuento_prod(
      pcdesc IN NUMBER,
      pcagrprod IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pfinivig IN DATE,
      pt_descuento OUT t_iax_detdescuento,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
       Devuelve el detalle de un cuadro de descuento al nivel indicado
       param in psproduc   : codigo de producto
       param in pcactivi   : codigo de la actividad
       param in pcgarant   : codigo de la garantia
       param in pnivel     : codigo de nivel (1-Producto,2-Actividad,3-Garantia)
       param out pt_descuento  :detalles
       param out mensajes      : mesajes de error

       return : codigo de error
    *************************************************************************/
   FUNCTION f_get_detalle_nivel(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pcnivel IN NUMBER,
      pcdesc IN NUMBER,
      pt_descuento OUT t_iax_detdescuento,
      mensajes OUT t_iax_mensajes)
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
      mensajes OUT t_iax_mensajes)
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
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_alturas(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pcdesc IN NUMBER,
      pcmoddesc IN NUMBER,
      pfinivig IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;
END pac_iax_descuentos;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_DESCUENTOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_DESCUENTOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_DESCUENTOS" TO "PROGRAMADORESCSI";
