--------------------------------------------------------
--  DDL for Package PAC_PREAVISOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_PREAVISOS" AUTHID CURRENT_USER AS
   /******************************************************************************
      NOMBRE:       PAC_PREAVISOS
      PROPÓSITO:    Funcionalidad para el módulo de preavisos

      REVISIONES:
      Ver        Fecha       Autor  Descripción
      ---------  ----------  -----  ------------------------------------
      1.0        10/04/2012  JTS    Creación del package. (BUG 21756)
   ****************************************************************************/
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
      pfinal IN DATE)
      RETURN VARCHAR2;

   FUNCTION f_nuevopreaviso(pcuser IN VARCHAR, osproces IN OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_insertapreaviso(
      psproces IN NUMBER,
      pnrecibo IN NUMBER,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_actualizapreaviso(psproces IN NUMBER, pnrecibo IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_compruebamediador(pmediador IN NUMBER)
      RETURN NUMBER;
END pac_preavisos;

/

  GRANT EXECUTE ON "AXIS"."PAC_PREAVISOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PREAVISOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PREAVISOS" TO "PROGRAMADORESCSI";
