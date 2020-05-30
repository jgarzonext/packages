--------------------------------------------------------
--  DDL for Package PAC_CAJA_CHEQUE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_CAJA_CHEQUE" AUTHID CURRENT_USER IS
   FUNCTION f_lee_cheques(
      sperson IN NUMBER,
      ncheque IN VARCHAR2,
      pseqcaja IN NUMBER,
      ptselect OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_set_estadocheques(pscaja IN NUMBER, pestado IN NUMBER, pfecha IN DATE)
      RETURN NUMBER;

   FUNCTION f_protestado(pscaja IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_cambiar_recibos(pscaja IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_insert_historico(
      seqcaja NUMBER,
      ncheque VARCHAR2,
      cstchq NUMBER,
      cstchq_ant NUMBER,
      festado DATE)
      RETURN NUMBER;

   FUNCTION f_genera_archivo_cheque(
      fini DATE,
      ffin DATE,
      pcregenera IN NUMBER,
      p_directorio OUT VARCHAR2)
      RETURN NUMBER;
END pac_caja_cheque;

/

  GRANT EXECUTE ON "AXIS"."PAC_CAJA_CHEQUE" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CAJA_CHEQUE" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CAJA_CHEQUE" TO "PROGRAMADORESCSI";
