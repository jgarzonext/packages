--------------------------------------------------------
--  DDL for Package Body PAC_SGT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_SGT" IS
   FUNCTION put(pnsesion IN NUMBER, ptparam IN VARCHAR2, pval IN NUMBER)
      RETURN NUMBER IS
   BEGIN
      v_parms_transitorios(pnsesion)(ptparam) := pval;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN SQLCODE;
   END put;

   FUNCTION get(pnsesion IN NUMBER, ptparam IN VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      RETURN v_parms_transitorios(pnsesion)(ptparam);
   EXCEPTION
      WHEN OTHERS THEN
         RAISE NO_DATA_FOUND;
   END get;

   FUNCTION del(pnsesion IN NUMBER)
      RETURN NUMBER IS
   BEGIN
      v_parms_transitorios(pnsesion).DELETE;
      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 0;
      WHEN OTHERS THEN
         RETURN SQLCODE;
   END del;

   FUNCTION del(pnsesion IN NUMBER, ptparam IN VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      v_parms_transitorios(pnsesion).DELETE(ptparam);
      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 0;
      WHEN OTHERS THEN
         RETURN SQLCODE;
   END del;
END pac_sgt;

/

  GRANT EXECUTE ON "AXIS"."PAC_SGT" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_SGT" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_SGT" TO "PROGRAMADORESCSI";
