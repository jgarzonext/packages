--------------------------------------------------------
--  DDL for Package PAC_TRASPASO_CARTERA_AGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_TRASPASO_CARTERA_AGE" AS
/******************************************************************************
   NAME:       PAC_TRASPASO_CARTERA_AGE
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        16/11/2009  DRA              1. Created this package.
   2.0        31/03/2011  DRA              2. 0018078: LCOL - Analisis Traspaso de Cartera
******************************************************************************/
   FUNCTION f_traspasar_cartera(
      pcageini IN NUMBER,
      pcagefin IN NUMBER,
      pctiptra IN VARCHAR2,
      psseguro IN NUMBER,
      pnrecibo IN NUMBER,
      psproces_in IN NUMBER,
      ptipotras IN NUMBER,
      pcomis IN t_iax_gstcomision,
      pcmotraspaso IN traspacarage.cmotraspaso%TYPE,
      ptobserv IN traspacarage.tobserv%TYPE,
      psproces_out OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_get_listtraspasos(pcageini IN NUMBER, pcagefin IN NUMBER, pfefecto IN DATE)
      RETURN VARCHAR2;

   FUNCTION f_get_listdettrasp(psproces IN NUMBER)
      RETURN VARCHAR2;
END pac_traspaso_cartera_age;

/

  GRANT EXECUTE ON "AXIS"."PAC_TRASPASO_CARTERA_AGE" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_TRASPASO_CARTERA_AGE" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_TRASPASO_CARTERA_AGE" TO "PROGRAMADORESCSI";
