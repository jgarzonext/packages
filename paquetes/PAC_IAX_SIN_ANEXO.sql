--------------------------------------------------------
--  DDL for Package PAC_IAX_SIN_ANEXO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_SIN_ANEXO" AS

      FUNCTION f_get_datos_sin(
      psprofes IN NUMBER,
      pnnumide IN VARCHAR2,
      ptnombre IN VARCHAR2,
      pnsinies IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;
END pac_iax_sin_anexo;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_SIN_ANEXO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_SIN_ANEXO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_SIN_ANEXO" TO "PROGRAMADORESCSI";
