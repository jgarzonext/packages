--------------------------------------------------------
--  DDL for Package PAC_LISTADO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_LISTADO" AS
/******************************************************************************
   NOMBRE:       pac_md_listado
   PROPÓSITO:    Contiene las funciones para el lanzamiento de listados a través de AXISCONNECT.

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        06/05/2009   JGM              1. Creación del package.
   2.0        06/05/2010   ICV              2. 0012746: APRB95 - lista de movimientos de saldo por cliente
   3.0        02/09/2019   Swapnil          3. Cambios de 4198    
******************************************************************************/

   /******************************************************************************
   F_GENERAR_LISTADO - Lanza el listado de comisiones de APRA
         p_cempres IN NUMBER,
         p_sproces IN NUMBER,
         p_cagente IN NUMBER,
         mensajes OUT t_iax_mensajes)
   Retorna 0 si OK 1 si KO
   ********************************************************************************/
   FUNCTION f_generar_listado(
      p_cempres IN NUMBER,
      p_sproces IN NUMBER,
      p_cagente IN NUMBER,
      p_codplan IN VARCHAR2,
      p_idioma IN NUMBER,
      pid OUT VARCHAR2)
      RETURN NUMBER;

   /******************************************************************************
      f_get_nombrereport - Recupera el nombre del report
      psinterf IN NUMBER,
      pdestino OUT varchar2
      Retorna 0 si OK 1 si KO

      Bug 14067 - 13/04/2010 - AMC
   ********************************************************************************/
   FUNCTION f_get_nombrereport(psinterf IN NUMBER, pdestino OUT VARCHAR2)
      RETURN NUMBER;

   PROCEDURE p_recupera_error(
      psinterf IN int_resultado.sinterf%TYPE,
      presultado OUT int_resultado.cresultado%TYPE,
      perror OUT int_resultado.terror%TYPE,
      pnerror OUT int_resultado.nerror%TYPE);

   -- bug 0028554 - 13/03/2014 - JMF: parametro opcional pdestcopia
   FUNCTION ff_crida_llistats(
      psinterf IN OUT NUMBER,
      pcempres IN NUMBER,
      pterminal IN VARCHAR2,
      pusuario IN VARCHAR2,
      ptpwd IN VARCHAR2,
      pid IN VARCHAR2,
      ptipodestino IN VARCHAR2,
      pplantillaorigen IN VARCHAR2,
      pdestino IN VARCHAR2,
      pdatasource IN VARCHAR2,
      perror OUT VARCHAR2,
      pdestcopia IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
	  
   /* CAMBIOS DE 4198 - START */      
      PROCEDURE PARSEAR(P_CLOB IN CLOB, P_PARSER IN OUT XMLPARSER.PARSER);
   /* CAMBIOS DE 4198 - End */	  
	  
END pac_listado;

/

  GRANT EXECUTE ON "AXIS"."PAC_LISTADO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_LISTADO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_LISTADO" TO "PROGRAMADORESCSI";
