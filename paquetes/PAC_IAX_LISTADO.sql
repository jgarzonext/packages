--------------------------------------------------------
--  DDL for Package PAC_IAX_LISTADO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_LISTADO" AS
/******************************************************************************
   NOMBRE:       PAC_IAX_LISTADO
   PROPÓSITO:    Contiene las funciones para el lanzamiento de listados a través de AXISCONNECT.

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        06/05/2009   JGM              1. Creación del package.
   2.0        06/05/2010   ICV              2. 0012746: APRB95 - lista de movimientos de saldo por cliente
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
      p_fitxer1 OUT VARCHAR2,
      p_fitxer2 OUT VARCHAR2,
      p_fitxer3 OUT VARCHAR2,
      p_fitxer4 OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Impresió
      param in out  psinterf
      param in      pcempres:  codi d'empresa
      param in      pdatasource
      param in      pcidioma
      param in      pcmapead
      param out     perror
      param out     mensajes    missatges d'error

      return                    0/1 -> Tot OK/error

      Bug 14067 - 13/04/2010 - AMC
   *************************************************************************/
   FUNCTION f_genera_report(
      psinterf IN NUMBER,
      pcempres IN NUMBER,
      pdatasource IN VARCHAR2,
      pcidioma IN NUMBER,
      pcmapead IN VARCHAR2,   --Bug.: 12746 - 06/05/2010 - ICV
      perror OUT VARCHAR2,
      preport OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_iax_listado;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_LISTADO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_LISTADO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_LISTADO" TO "PROGRAMADORESCSI";
