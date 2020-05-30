--------------------------------------------------------
--  DDL for Package PAC_QUERY_TAB_ERROR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_QUERY_TAB_ERROR" IS
   TYPE outrec_type IS RECORD(
      ferror         TIMESTAMP ( 6 ),
      cusuari        VARCHAR2(20),
      tobjeto        VARCHAR2(500),
      ntraza         NUMBER,
      tdescrip       VARCHAR2(500),
      terror         VARCHAR2(2500)
   );

   TYPE outrecset IS TABLE OF outrec_type;

   FUNCTION f_row
      RETURN outrecset PIPELINED;
END pac_query_tab_error;

/

  GRANT EXECUTE ON "AXIS"."PAC_QUERY_TAB_ERROR" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_QUERY_TAB_ERROR" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_QUERY_TAB_ERROR" TO "PROGRAMADORESCSI";
