--------------------------------------------------------
--  DDL for Package PAC_JREP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_JREP" AS
   /****************************************************************************
      NOMBRE:    PAC_JREP
      PROPÓSITO: Funciones para la ejecución dinamica del map (450)

      REVISIONES:
      Ver        Fecha       Autor            Descripción
      ---------  ----------  ---------------  ----------------------------------
      1.0        03/11/2011  JTS              1. Creación del paquete BUG 19227
   ****************************************************************************/

   /*************************************************************************
      FUNCTION f_query_jrep
      Recupera la select per a l'execució d'un JReport
      param in psproces  : ID del procés de la select a recuperar
      param in pctipo    : Tipus de select
      return             : Consulta
   *************************************************************************/
   FUNCTION f_query_jrep(psproces IN NUMBER, pctipo IN NUMBER)
      RETURN VARCHAR2;
END pac_jrep;
 

/

  GRANT EXECUTE ON "AXIS"."PAC_JREP" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_JREP" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_JREP" TO "PROGRAMADORESCSI";
