--------------------------------------------------------
--  DDL for Package PAC_CARTAS_IMPAGADOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_CARTAS_IMPAGADOS" 
AS
/******************************************************************************
   NOMBRE:      pac_cartas_impagados
   PROPÓSITO: Funciones para la impresión de cartas de impagos

   REVISIONES:
   Ver        Fecha        Autor  Descripción
   ---------  ----------  ------  ------------------------------------
   1.0        08/06/2009   JTS     1.0 Creación del package
   2.0        23/04/2012   JMF    0022030: MDP_A001-Devoluciones: impresion y gestion de cartas
******************************************************************************/

   /*************************************************************************
      Obtiene el codigo de plantilla a imprimir para una carta de impago dada
      param in psgescarta  : Código de carta
      param out pccodplan  : Código de plantilla
      return               : Number 0.- OK Otro.- KO
   *************************************************************************/
   FUNCTION f_get_codplantilla (psgescarta IN NUMBER, pccodplan OUT VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
      Marca la carta de impago como impresa
      param in psgescarta  : Código de carta
      param in p_sdevolu   : ID. devolucion
      return               : Number 0.- OK Otro.- KO
      -- Bug 0022030 - 23/04/2012 - JMF
   *************************************************************************/
   FUNCTION f_marcar_gescarta (psgescarta IN NUMBER, p_sdevolu IN NUMBER)
      RETURN NUMBER;
END pac_cartas_impagados;

/

  GRANT EXECUTE ON "AXIS"."PAC_CARTAS_IMPAGADOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CARTAS_IMPAGADOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CARTAS_IMPAGADOS" TO "PROGRAMADORESCSI";
