--------------------------------------------------------
--  DDL for Package PK_SINIESTROS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PK_SINIESTROS" AUTHID CURRENT_USER IS
   FUNCTION f_rescate(
      ptarea IN NUMBER,   -- 33-Rescate Parcial, 34-Rescate Total
      psseguro IN NUMBER,
      pidioma IN NUMBER,
      pimporte IN NUMBER,
      pffecmov IN DATE,
      pfvalmov IN DATE,
      pfcontab IN DATE,
      pcbancar IN VARCHAR2,
      pcbancar2 IN VARCHAR2,
      pnsinies OUT NUMBER,
      pctipban IN NUMBER DEFAULT NULL,
      pctipban2 IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION validar_aportacion_rescate(
      ptarea IN NUMBER,
      psseguro IN NUMBER,
      pfvalmov IN DATE,
      pimovimi IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_valorgrupo(psseguro IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_vivos_muertos(psseguro IN NUMBER, estado IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_grabvalorac(
      pnsinies IN NUMBER,
      pcgarant IN NUMBER,
      pfecha IN DATE,
      pivalora IN NUMBER,
      pipenali IN NUMBER,
      picapris IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_grabdestrescat(
      pnsinies IN NUMBER,
      psseguro IN NUMBER,
      pcbancar IN VARCHAR2,
      pcbancar2 IN VARCHAR2,
      pctipban IN NUMBER DEFAULT NULL,
      pctipban2 IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_regsinies(
      psseguro IN NUMBER,
      pcramo IN NUMBER,
      pffecmov IN DATE,
      ptsinies IN VARCHAR2,
      pccausin IN NUMBER,
      pcmotsin IN NUMBER,
      pfcontab IN DATE,
      pfvalmov IN DATE,
      pnriesgo IN NUMBER,
      pnsinies IN OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_regvalorac(
      pnsinies IN NUMBER,
      pcgarant IN NUMBER,
      pfecha IN DATE,
      pivalora IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_regdestinat(
      pnsinies IN NUMBER,
      psseguro IN NUMBER,
      ppagdes IN NUMBER,
      pctipdes IN NUMBER,
      pcpagdes IN NUMBER,
      pivalora IN NUMBER,
      pcactpro IN NUMBER,
      pcbancar IN VARCHAR2,
      pcbancar2 IN VARCHAR2,
      pctipban IN NUMBER DEFAULT NULL,
      pctipban2 IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_regpagosin(
      pnsinies IN NUMBER,
      psseguro IN NUMBER,
      pdes IN NUMBER,
      pffecmov IN DATE,
      pctipdes IN NUMBER,
      psperson IN NUMBER,
      pctippag IN NUMBER,
      pcestpag IN NUMBER,
      pcforpag IN NUMBER,
      pccodcon IN NUMBER,
      pcmanual IN NUMBER,
      pcimpres IN NUMBER,
      pfefepag IN DATE,
      pfordpag IN DATE,
      pnmescon IN DATE,
      ptcoddoc IN NUMBER,
      pisinret IN NUMBER,
      piconret IN NUMBER,
      piretenc IN NUMBER,
      piimpiva IN NUMBER,
      ppretenc IN NUMBER,
      pcptotal IN NUMBER,
      pfimpres IN DATE,
      moneda IN NUMBER,
      pmuerto IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_reparte_retenciones(
      siniestro IN NUMBER,
      psseguro IN NUMBER,
      pdes IN NUMBER,
      pfvalmov IN DATE,
      retencion IN NUMBER,
      importe IN NUMBER,
      moneda IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_anulacion(
      psseguro IN NUMBER,
      pfvalmov IN DATE,
      pnsinies IN NUMBER,
      pfcartera IN DATE,
      pcmovimi IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_bloqueada(psseguro IN NUMBER, pfvalmov IN DATE)
      RETURN NUMBER;

   FUNCTION f_pignorada(psseguro IN NUMBER, pfvalmov IN DATE, pimporte OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_desglosegarant(psidepag IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_provisio(
      pnsinies IN NUMBER,
      pcgarant IN NUMBER,
      pdata IN DATE,
      provisio OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_pagos(pnsinies IN NUMBER, pcgarant IN NUMBER, pdata IN DATE, pagos OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_valoracio(
      pnsinies IN NUMBER,
      pcgarant IN NUMBER,
      pdata IN DATE,
      valoracio OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_insctaseguro(
      psseguro IN NUMBER,
      pfcontab IN DATE,
      pffecmov IN DATE,
      pfvalmov IN DATE,
      cmovimi IN NUMBER,
      pimporte IN NUMBER,
      pnsinies IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_insctaseguro_shw(
      psseguro IN NUMBER,
      pfcontab IN DATE,
      pffecmov IN DATE,
      pfvalmov IN DATE,
      cmovimi IN NUMBER,
      pimporte IN NUMBER,
      pnsinies IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_desdiario(
      pnsinies IN NUMBER,
      pntramit IN NUMBER,
      pnlintra IN NUMBER,
      pcidioma IN NUMBER,
      pdesc OUT VARCHAR2)
      RETURN NUMBER;
END pk_siniestros;

/

  GRANT EXECUTE ON "AXIS"."PK_SINIESTROS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PK_SINIESTROS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PK_SINIESTROS" TO "PROGRAMADORESCSI";
