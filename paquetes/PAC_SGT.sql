--------------------------------------------------------
--  DDL for Package PAC_SGT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_SGT" AUTHID CURRENT_USER IS
   TYPE t_parametros IS TABLE OF NUMBER
      INDEX BY VARCHAR2(30);

   TYPE t_sesiones IS TABLE OF t_parametros
      INDEX BY BINARY_INTEGER;

   v_parms_transitorios t_sesiones;

   FUNCTION put(pnsesion IN NUMBER, ptparam IN VARCHAR2, pval IN NUMBER)
      RETURN NUMBER;

   FUNCTION get(pnsesion IN NUMBER, ptparam IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION del(pnsesion IN NUMBER)
      RETURN NUMBER;

   FUNCTION del(pnsesion IN NUMBER, ptparam IN VARCHAR2)
      RETURN NUMBER;
END pac_sgt;

/

  GRANT EXECUTE ON "AXIS"."PAC_SGT" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_SGT" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_SGT" TO "PROGRAMADORESCSI";
