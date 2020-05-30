--------------------------------------------------------
--  DDL for Package PAC_IAX_RIESGO_FINANCIERO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_RIESGO_FINANCIERO" AS

   FUNCTION f_calcula_riesgo(
      sperson IN NUMBER,
      fefecto IN DATE,
      monto IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

      FUNCTION F_GET_RIESGOS_CALCULADOS(sperson IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;
END pac_iax_riesgo_financiero;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_RIESGO_FINANCIERO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_RIESGO_FINANCIERO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_RIESGO_FINANCIERO" TO "PROGRAMADORESCSI";
