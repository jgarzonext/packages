--------------------------------------------------------
--  DDL for Package PAC_COASEGURO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_COASEGURO" IS
/******************************************************************************
   NOMBRE:        pac_coaseguro
   PROPÓSITO:     proceso batch mensual que realiza el Cierre de Coaseguro.

   REVISIONES:
   Ver        Fecha       Autor      Descripción
   ---------  ----------  ---------  ------------------------------------
   1.0        XX/XX/XXXX  XXX        1. Creación del package.
   2.0        06/10/2011  JGR        2. 0019088: LCOL_F001-Parametrizacion de los cierres
   3.0        23/08/2012  JMF        0023188 LCOL_T020-COA-Circuit de Tancament de Coasseguran
******************************************************************************/
   PROCEDURE proceso_batch_cierre(
      pmodo IN NUMBER,
      pcempres IN NUMBER,
      pmoneda IN NUMBER,
      pcidioma IN NUMBER,
      pfperini IN DATE,
      pfperfin IN DATE,
      pfcierre IN DATE,
      pcerror OUT NUMBER,
      psproces OUT NUMBER,
      pfproces OUT DATE);

   -- Bug 0023188 - 23/08/2012 - JMF: afegir empresa
   FUNCTION cierre_coaseguro(
      pcempres IN NUMBER,
      pdefi IN NUMBER,
      pmes IN NUMBER,
      pany IN NUMBER,
      pproces IN NUMBER,
      psql OUT VARCHAR2,
      psmovcoa OUT NUMBER)
      RETURN NUMBER;
END;

/

  GRANT EXECUTE ON "AXIS"."PAC_COASEGURO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_COASEGURO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_COASEGURO" TO "PROGRAMADORESCSI";
