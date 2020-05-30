--------------------------------------------------------
--  DDL for Package PAC_GARAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_GARAN" AUTHID CURRENT_USER IS
/***************************************************************************
 PAC_GARAN: Package per omplir les valoracions.
 ALLIBP01 - Package de procediments de B.D.
***************************************************************************/
   TYPE lista IS RECORD(
      norden         NUMBER,
      sseguro        NUMBER,
      cgarant        NUMBER(4),
      tgarant        VARCHAR2(40),
      icapital       NUMBER,   --NUMBER(13, 2),
      franquicia     NUMBER   --NUMBER(13, 2)
   );

   TYPE lista_ref IS REF CURSOR
      RETURN lista;

   TYPE lista_tab IS TABLE OF lista
      INDEX BY BINARY_INTEGER;

   PROCEDURE QUERY(resultset IN OUT lista_ref);

   var_seguro     NUMBER;
   var_idioma     NUMBER;
   var_riesgo     NUMBER;
   var_fecha      DATE;

   PROCEDURE omplir_valora(
      pseguro IN NUMBER,
      pidioma IN NUMBER,
      pnriesgo IN NUMBER,
      pfecha IN DATE);
END;

/

  GRANT EXECUTE ON "AXIS"."PAC_GARAN" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_GARAN" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_GARAN" TO "PROGRAMADORESCSI";
