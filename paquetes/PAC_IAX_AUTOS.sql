--------------------------------------------------------
--  DDL for Package PAC_IAX_AUTOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_AUTOS" AS
/******************************************************************************
   NOMBRE:       pac_iax_autos
   PROPÓSITO:  Funciones para realizar una conexión
               a base de datos de la capa de negocio

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        02/03/2009   XVM               1. Creación del package.
******************************************************************************/

   /*************************************************************************
      FUNCTION f_desversion
         Funcion que busca la descripcion de la version de un vehiculo
         param in pcversion : Codigo de la version
         return             : descripcion de la version
   *************************************************************************/
   FUNCTION f_desversion(pcversion IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2;

   /*************************************************************************
      FUNCTION f_desmodelo
         Funcion que busca la descripcion del modelo de un vehiculo
         param in pcmodelo : Codigo del modelo
         param in pcmarca : Codigo de la marca
         return            : descripcion del modelo
   *************************************************************************/
   FUNCTION f_desmodelo(pcmodelo IN VARCHAR2, pcmarca IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2;

   /*************************************************************************
      FUNCTION f_desmarca
         Funcion que busca la descripcion de la marca de un vehiculo
         param in pcmarca : Codigo de la marca
         return            : descripcion de la marca
   *************************************************************************/
   FUNCTION f_desmarca(pcmarca IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2;

   /*************************************************************************
      FUNCTION f_destipveh
         Funcion que busca la descripcion del tipo de un vehiculo
         param in pctipveh : Codigo del tipo de vehiculo
         param in pcidioma : Idioma de la descripcion
         return            : descripcion del tipo
   *************************************************************************/
   FUNCTION f_destipveh(pctipveh IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2;

   /*************************************************************************
      FUNCTION f_desclaveh
         Funcion que busca la descripcion de la clase de un vehiculo
         param in pcclaveh : Codigo de la clase de vehiculo
         param in pcidioma : Idioma de la descripcion
         return            : descripcion del tipo
   *************************************************************************/
   FUNCTION f_desclaveh(pcclaveh IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2;

   /*************************************************************************
      FUNCTION f_desuso
         Funcion que busca la descripcion del uso de un vehiculo
         param in pcuso : Codigo del uso de vehiculo
         param in pcidioma : Idioma de la descripcion
         return            : descripcion del uso
   *************************************************************************/
   FUNCTION f_desuso(pcuso IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2;

   /*************************************************************************
      FUNCTION f_dessubuso
         Funcion que busca la descripcion del subuso de un vehiculo
         param in pcuso : Codigo del subuso de vehiculo
         param in pcidioma : Idioma de la descripcion
         return            : descripcion del subuso
   *************************************************************************/
   FUNCTION f_dessubuso(pcsubuso IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2;
END pac_iax_autos;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_AUTOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_AUTOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_AUTOS" TO "PROGRAMADORESCSI";
