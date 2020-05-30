--------------------------------------------------------
--  DDL for Package PAC_LLIBSIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_LLIBSIN" AUTHID CURRENT_USER IS
   -- reaseguro
   FUNCTION datos_rea_sin(
      ramo IN NUMBER,
      moda IN NUMBER,
      tips IN NUMBER,
      cole IN NUMBER,
      sseg IN NUMBER,
      w_ctiprea OUT NUMBER,
      pmerr IN OUT VARCHAR2)
      RETURN NUMBER;

   -- reaseguro
   FUNCTION datos_rea_gar(
      ramo IN NUMBER,
      moda IN NUMBER,
      tips IN NUMBER,
      cole IN NUMBER,
      cgar IN NUMBER,
      acti IN NUMBER,
      w_ctiprea OUT NUMBER,
      pmerr IN OUT VARCHAR2)
      RETURN NUMBER;

   -- reaseguro
   FUNCTION busca_plocal(
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      w_plocal OUT NUMBER,
      w_nsegcon OUT NUMBER,
      w_nsegver OUT NUMBER)
      RETURN NUMBER;

   -- reaseguro
   FUNCTION busca_plocal_proteccio(
      w_nsegcon IN NUMBER,
      w_nsegver IN NUMBER,
      w_plocpro OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_libsin(
      psproces IN NUMBER,
      pempres IN NUMBER,
      pdata IN DATE,
      pmerr OUT VARCHAR2   --, pmodo      IN       NUMBER
                        )
      RETURN NUMBER;

   PROCEDURE proceso_batch_cierre(
      pmodo IN NUMBER,
      pcempres IN NUMBER,
      pcidioma IN NUMBER,
      pfcierre IN DATE,
      pcerror OUT NUMBER,
      psproces OUT NUMBER,
      pfproces OUT DATE);

   -- reaseguro
   FUNCTION busca_pcedido(scon IN NUMBER, nver IN NUMBER, wpcedido OUT NUMBER)
      RETURN NUMBER;

   -- reaseguro
   FUNCTION f_pnoreaseguro(
      sseg IN NUMBER,
      nrie IN NUMBER,
      cgar IN NUMBER,
      fecha IN DATE,
      pnostre OUT NUMBER,
      ppcedido OUT NUMBER)
      RETURN NUMBER;

   -- tancament
   FUNCTION actualitza_provisions_anuals(
      wempresa IN NUMBER,
      wdata_ini IN DATE,
      wdata_fin IN DATE)
      RETURN NUMBER;

   -- tancament
   FUNCTION actualitza_provisions_mensuals(
      wempresa IN NUMBER,
      wdata_ini IN DATE,
      wdata_fin IN DATE)
      RETURN NUMBER;

   -- coaseguro
   FUNCTION datos_coa_sin(
      sseg IN NUMBER,
      ncua IN NUMBER,
      w_ctipcoa OUT NUMBER,
      w_ploc OUT NUMBER)
      RETURN NUMBER;

   -- coaseguro
   FUNCTION valida_aplica_coa(
      w_ctipcoa IN NUMBER,
      nsin IN NUMBER,
      w_cpagcoa OUT NUMBER,
      apl_coa_prov OUT BOOLEAN,
      apl_coa_pag OUT BOOLEAN)
      RETURN NUMBER;

   PROCEDURE p_ajusta_reservas31d(pcempres IN NUMBER, pperfin IN DATE);
END;

/

  GRANT EXECUTE ON "AXIS"."PAC_LLIBSIN" TO "PROGRAMADORESCSI";
  GRANT EXECUTE ON "AXIS"."PAC_LLIBSIN" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_LLIBSIN" TO "CONF_DWH";
