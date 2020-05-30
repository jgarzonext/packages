--------------------------------------------------------
--  DDL for Package PAC_COMPANIAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_COMPANIAS" AS
      /******************************************************************************
        NOMBRE:       PAC_COMPANIAS
        PROPÃ“SITO: Funciones para gestionar compañias

      REVISIONES:
      Ver        Fecha        Autor       Descripción
      ---------  ----------  ---------  ------------------------------------
      1.0        09/07/2012  OASA        1. Creación del package.


   ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*************************************************************************
      FUNCTION f_get_tipiva
      Funcion que dado una compa?ia y una fecha retorna el % tipo de iva a la fecha
      param in pccompani   : Codigo compa?ia
      param in pfecha      : Fecha en activo
      return               : % Tipo de iva a aplicar
     *************************************************************************/
   FUNCTION f_get_tipiva(pccompani IN NUMBER, pfecha IN DATE)
      RETURN NUMBER;


   /*************************************************************************
      FUNCTION f_retefuente
      Encontrar el valor retefuente
      param in pccompani     : codigo agente
      param out pretefuente  : devuelve el valor del retefuente a buscar dentro de las vigencias
   *************************************************************************/
   FUNCTION f_retefuente(pccompani IN NUMBER)
     RETURN NUMBER;

 END pac_companias;

/

  GRANT EXECUTE ON "AXIS"."PAC_COMPANIAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_COMPANIAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_COMPANIAS" TO "PROGRAMADORESCSI";
