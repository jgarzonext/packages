--------------------------------------------------------
--  DDL for Package PAC_MD_PREAVISOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_PREAVISOS" AUTHID CURRENT_USER AS
   /******************************************************************************
      NOMBRE:       PAC_MD_PREAVISOS
      PROPÓSITO:    Funcionalidad para el módulo de preavisos

      REVISIONES:
      Ver        Fecha       Autor  Descripción
      ---------  ----------  -----  ------------------------------------
      1.0        10/04/2012  JTS    Creación del package. (BUG 21756)
   ****************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   FUNCTION f_buscarecibos(
      pcempres IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pdomiciliados IN NUMBER,
      pmediador IN NUMBER,
      ppfinanciero IN NUMBER,
      ppcomercial IN NUMBER,
      ptomador IN NUMBER,
      pfinici IN DATE,
      pfinal IN DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_compruebamediador(pmediador IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_realizapreaviso(
      plistrecibos VARCHAR2,
      osproces IN OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_md_preavisos;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_PREAVISOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_PREAVISOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_PREAVISOS" TO "PROGRAMADORESCSI";
