--------------------------------------------------------
--  DDL for Package PAC_EVENTOS_SIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_EVENTOS_SIN" AS
/******************************************************************************
   NOMBRE:    PAC_EVENTOS_SIN
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
    param in pcidioma  : codigo del idioma
    param out peventos : lista de eventos
    return             :  0 - ok , 1 - ko.

    -- Bug 12211 - 10/12/2009 - AMC
   *************************************************************************/
   FUNCTION f_get_eventos(
      pcevento IN VARCHAR2,
      ptevento IN VARCHAR2,
      pfinicio IN DATE,
      pffinal IN DATE,
      pcidioma IN NUMBER,
      peventos OUT sys_refcursor)
      RETURN NUMBER;

/*************************************************************************
    Función f_get_desevento
    Devuelve la query a ejecutar
    param in pcevento  : codigo del evento
    param out psquery  : consulta ha ejecutar
    return             :  0 - ok , 1 - ko.

    -- Bug 12211 - 10/12/2009 - AMC
   *************************************************************************/
   FUNCTION f_get_desevento(pcevento IN VARCHAR2, psquery OUT VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
    Función f_get_codevento
    Devuelve las fecha de inicio y fin del evento
    param in pcevento       : codigo del evento
    param out pcevento_out  : codigo del evento
    param out pfinieve      : fecha inicio evento
    param out pffineve      : fecha fin evento
    return                  :  0 - ok , 1 - ko.

    -- Bug 12211 - 10/12/2009 - AMC
   *************************************************************************/
   FUNCTION f_get_codevento(
      pcevento IN VARCHAR2,
      pcevento_out OUT VARCHAR2,
      pfinieve OUT DATE,
      pffineve OUT DATE)
      RETURN NUMBER;

   /*************************************************************************
     Función f_set_codevento
     Función para insertar un evento
     param in pcevento  : codigo del evento
     param in PFINIEVE  : fecha inicio evento
     param in PFFINEVE  : fecha fin evento
     return   0 - ok , 1 - ko

     -- Bug 12211 - 10/12/2009 - AMC
    *************************************************************************/
   FUNCTION f_set_codevento(pcevento IN VARCHAR2, pfinieve IN DATE, pffineve IN DATE)
      RETURN NUMBER;

   /*************************************************************************
     Función f_del_evento
     Función para borrar un evento
     param in pcevento  : codigo del evento
     param out mensajes : mensajes de error
     return   0 - ok , 1 - ko

     -- Bug 12211 - 10/12/2009 - AMC
   *************************************************************************/
   FUNCTION f_del_evento(pcevento IN VARCHAR2)
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
      pcidioma IN NUMBER)
      RETURN NUMBER;
END pac_eventos_sin;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_EVENTOS_SIN" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_EVENTOS_SIN" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_EVENTOS_SIN" TO "PROGRAMADORESCSI";
