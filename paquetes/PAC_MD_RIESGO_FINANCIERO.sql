--------------------------------------------------------
--  DDL for Package PAC_MD_RIESGO_FINANCIERO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_RIESGO_FINANCIERO" AS
   /******************************************************************************
      NOMBRE:       PAC_MD_CAJA_CHEQUE
      PROP¿SITO:  Funciones que gestionan el m¿dulo de CAJA

      REVISIONES:
      Ver        Fecha        Autor             Descripci¿n
      ---------  ----------  ---------------  ------------------------------------
      1.0        25/02/2013   AFM                1. Creaci¿n del package.
   ******************************************************************************/
   /*************************************************************************
      Obtiene los ficheros pendientes de pagar por el partner
      param in sperson  : Codigo de agente
      param out mensajes : mensajes de error
      return             : 0 si todo ha ido bien o 1
   *************************************************************************/
  /* FUNCTION f_lee_cheques(sperson IN NUMBER, ncheque IN VARCHAR2,pseqcaja IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;*/

         /*************************************************************************
      Edita el estado y la fecha de los cheques
      param in pscaja : Codigo de cheque
      param in pestado: estado del cheque
      param in pfecha: Fecha del cheque
      param out mensajes : mensajes de error
   *************************************************************************/
    FUNCTION f_calcula_riesgo(
      sperson IN NUMBER,
      fefecto IN DATE,
      monto IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

       FUNCTION F_GET_RIESGOS_CALCULADOS(sperson IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;


END pac_md_riesgo_financiero;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_RIESGO_FINANCIERO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_RIESGO_FINANCIERO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_RIESGO_FINANCIERO" TO "PROGRAMADORESCSI";
