--------------------------------------------------------
--  DDL for Package PAC_IAX_EVENTOS_SIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_EVENTOS_SIN" AS
/******************************************************************************
   NOMBRE:    PAC_IAX_EVENTOS_SIN
   PROPÓSITO: Funciones para la gestión de los eventos de un siniestro.

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        10/12/2009   AMC               1. Creación del package.
******************************************************************************/

   /*************************************************************************
    Función f_get_eventos
    Recupera los eventos
    param in pcevento  : codigo del evento
    param in ptevento  : texto del evento
    param in pfinicio  : fecha inicio
    param in pffinal   : fecha fin
    param out peventos : lista de eventos
    param out mensajes : mensajes de error
    return   0 - ok , 1 - ko

    -- Bug 12211 - 10/12/2009 - AMC
   *************************************************************************/
   FUNCTION f_get_eventos(
      pcevento IN VARCHAR2,
      ptevento IN VARCHAR2,
      pfinicio IN DATE,
      pffinal IN DATE,
      peventos OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Función f_get_evento
      Recupera lun evento
      param in pcevento  : codigo del evento
      param out pcevento_out
      param out PFINIEVE    : fecha inicio evento
      param out PFFINEVE    : fecha fin evento
      param out pdeseventos : lista de eventos
      param out mensajes    : mensajes de error
      return   0 - ok , 1 - ko

      -- Bug 12211 - 10/12/2009 - AMC
     *************************************************************************/
   FUNCTION f_get_evento(
      pcevento IN VARCHAR2,
      pcevento_out OUT VARCHAR2,   --se deja preparado por si alguna vez se tiene que devolver
      pfinieve OUT DATE,
      pffineve OUT DATE,
      pdeseventos OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    Función f_set_codevento
    Función para insertar/modificar un evento
    param in pcevento  : codigo del evento
    param in PFINIEVE  : fecha inicio evento
    param in PFFINEVE  : fecha fin evento
    param out mensajes : mensajes de error
    return   0 - ok , 1 - ko

    -- Bug 12211 - 10/12/2009 - AMC
   *************************************************************************/
   FUNCTION f_set_codevento(
      pcevento IN VARCHAR2,
      pfinieve IN DATE,
      pffineve IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
     Función f_del_evento
     Función para borrar un evento
     param in pcevento  : codigo del evento
     param out mensajes : mensajes de error
     return   0 - ok , 1 - ko

     -- Bug 12211 - 10/12/2009 - AMC
    *************************************************************************/
   FUNCTION f_del_evento(pcevento IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
     Función f_set_desevento
     Función para insertar/actualizar la descripción de un evento
     param in pcevento  : codigo del evento
     param in pttiteve  : titulo del evento
     param in ptevento  : Descripción del evento
     param in pcidioma  : Codigo del idioma
     param out mensajes : mensajes de error
     return   0 - ok , 1 - ko

     -- Bug 12211 - 10/12/2009 - AMC
   *************************************************************************/
   FUNCTION f_set_desevento(
      pcevento IN VARCHAR2,
      pttiteve IN VARCHAR2,
      ptevento IN VARCHAR2,
      pcidioma IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_iax_eventos_sin;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_EVENTOS_SIN" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_EVENTOS_SIN" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_EVENTOS_SIN" TO "PROGRAMADORESCSI";
