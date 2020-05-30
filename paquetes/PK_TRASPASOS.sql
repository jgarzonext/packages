--------------------------------------------------------
--  DDL for Package PK_TRASPASOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PK_TRASPASOS" AS
   ---
   FUNCTION f_in_partic(
      pstras IN NUMBER,
      pctiptras IN NUMBER,
      psseguro IN NUMBER,
      pfvalmov IN OUT DATE,
      pfefecto IN OUT DATE,
      pimovimi IN OUT NUMBER,
      ppartras IN OUT NUMBER,
      pintern IN NUMBER,
      psseguro_or IN NUMBER,
      pautomatic IN NUMBER DEFAULT 1,
      pporcdcons IN NUMBER,
      pporcdecon IN NUMBER)
      RETURN NUMBER;

   ---
   FUNCTION f_out_partic(
      pstras IN NUMBER,
      pctiptras IN NUMBER,
      psseguro IN NUMBER,
      pfvalmov IN OUT DATE,
      pfefecto IN OUT DATE,
      pimovimi IN OUT NUMBER,
      ppartras IN OUT NUMBER,
      pintern IN NUMBER,
      psseguro_ds IN NUMBER,
      pautomatic IN NUMBER DEFAULT 1,
      pporcdcons IN NUMBER,
      pporcdecon IN NUMBER)
      RETURN NUMBER;

   ---
   FUNCTION f_in_benef(
      pstras IN NUMBER,
      pctiptras IN NUMBER,
      pspersonben IN NUMBER,
      psseguro IN NUMBER,
      pfvalmov IN DATE,
      pfefecto IN DATE,
      pimovimi IN OUT NUMBER,
      ppartras IN OUT NUMBER,
      pintern IN NUMBER,
      psseguro_or IN NUMBER,
      pautomatic IN NUMBER DEFAULT 1)
      RETURN NUMBER;

   ---
   FUNCTION f_out_benef(
      pstras IN NUMBER,
      pctiptras IN NUMBER,
      psprestaplan IN NUMBER,
      pspersonben IN NUMBER,
      psseguro IN NUMBER,
      pfvalmov IN DATE,
      pfefecto IN DATE,
      pimovimi IN OUT NUMBER,
      ppartras IN OUT NUMBER,
      pintern IN NUMBER,
      psseguro_ds IN NUMBER,
      pautomatic IN NUMBER DEFAULT 1)
      RETURN NUMBER;

   ---
   FUNCTION f_out(
      pstras IN NUMBER,
      pctiptras IN NUMBER,
      psseguro IN NUMBER,
      pfvalmov IN OUT DATE,
      pfefecto IN OUT DATE,
      pimovimi IN OUT NUMBER,
      ppartras IN OUT NUMBER,
      pnnumlin IN OUT NUMBER,
      pfcontab IN OUT DATE,
      pspersdest IN NUMBER,
      pepagsin IN NUMBER)
      RETURN NUMBER;

   ---
   FUNCTION f_in(
      pstras IN NUMBER,
      psseguro IN NUMBER,
      pfvalmov IN OUT DATE,
      pfefecto IN OUT DATE,
      pimovimi IN OUT NUMBER,
      pnnumlin IN OUT NUMBER,
      pfcontab IN OUT DATE,
      pnrecibo IN OUT NUMBER)
      RETURN NUMBER;

   ---
   FUNCTION f_tancar_presta(
      psprestaplan IN NUMBER,
      pspersonben IN NUMBER,
      psseguro IN NUMBER,
      pnsinies IN NUMBER)
      RETURN NUMBER;

   ---
   FUNCTION f_crear_presta(
      pstras IN NUMBER,
      psseguro IN NUMBER,
      psperson IN NUMBER,
      pfvalmov IN DATE,
      pfefecto IN DATE,
      bconfirmar IN BOOLEAN,
      psprestaplan OUT NUMBER,
      xprorat IN NUMBER)
      RETURN NUMBER;

   ---
   FUNCTION f_saldo_pp(psseguro IN NUMBER, pfvalmov IN DATE, ptipus IN NUMBER)
      RETURN NUMBER;

   ---
   FUNCTION f_traspaso_inverso(
      pcparoben IN NUMBER,
      pstras IN NUMBER,
      psseguro_ds IN NUMBER,
      psseguro_or IN NUMBER,
      pimovimi IN NUMBER,
      ppartras IN NUMBER,
      pctiptras IN NUMBER,
      pcinout IN NUMBER,
      pstrasin IN OUT NUMBER)
      RETURN NUMBER;
---
END pk_traspasos;

/

  GRANT EXECUTE ON "AXIS"."PK_TRASPASOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PK_TRASPASOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PK_TRASPASOS" TO "PROGRAMADORESCSI";
