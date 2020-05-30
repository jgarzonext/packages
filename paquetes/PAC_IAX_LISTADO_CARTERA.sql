--------------------------------------------------------
--  DDL for Package PAC_IAX_LISTADO_CARTERA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_LISTADO_CARTERA" IS
/******************************************************************************
   NOMBRE:     PAC_IAX_LISTADO_CARTERA
   PROPÓSITO:  Funciones para la obtención de listados de cartera

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        06/10/2010   SRA             1. Bug 0016137: Creación del package.
   2.0        30/12/2010   ICV             2. 0016137: CRT003 - Carga fichero cartera -> Listado cartera
******************************************************************************/

   -- BUG 0016137 - 05/10/2010 - SRA
   /*************************************************************************
      f_listado_compara_carteras                     : Para una fecha de cartera dada, se obtiene un listado de recibos de nueva producción
                                                     : y renovación emitidos en dicha fecha y compara sus importes diversos con los de la cartera
                                                     : anterior. Es posible filtrar por empresa o producto.
      pccompani in companipro.ccompani%type          : identificador de la compañía que oferta el producto en AXIS
      psproduc in seguros.sproduc%type               : identificador en AXIS del producto del cual se quiere obtener un listado
      pfechacartera in date                          : fecha de cartera del listado que se quiere generar
      mensajes in out t_iax_mensajes                 : variable que contiene mensajes de error y avisos
      return t_iax_comparacarteras                   : objeto que alberga el resultado del listado
   **************************************************************************/
   FUNCTION f_listado_compara_carteras(
      pccompani IN companipro.ccompani%TYPE,
      psproduc IN seguros.sproduc%TYPE,
      pfdesde IN DATE,
      pfhasta IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_comparacarteras;

   -- BUG 0016137 - 05/10/2010 - SRA
   /*************************************************************************
      f_listado_polizas_sincartera                   : Para una fecha de cartera dada, se obtiene un listado de pólizas que a fecha de renovación
                                                     : de cartera no han emitido recibo.
      pccompani in companipro.ccompani%type          : identificador de la compañía que oferta el producto en AXIS
      psproduc in seguros.sproduc%type               : identificador en AXIS del producto del cual se quiere obtener un listado
      pfechacartera in date                          : fecha de cartera del listado que se quiere generar
      mensajes in out t_iax_mensajes                 : variable que contiene mensajes de error y avisos
      return t_iax_comparacarteras                   : objeto que alberga el resultado del listado
   **************************************************************************/
   FUNCTION f_listado_polizas_sincartera(
      pccompani IN companipro.ccompani%TYPE,
      psproduc IN seguros.sproduc%TYPE,
      pfdesde IN DATE,
      pfhasta IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_comparacarteras;
END pac_iax_listado_cartera;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_LISTADO_CARTERA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_LISTADO_CARTERA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_LISTADO_CARTERA" TO "PROGRAMADORESCSI";
