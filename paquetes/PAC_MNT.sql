--------------------------------------------------------
--  DDL for Package PAC_MNT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MNT" AUTHID CURRENT_USER IS
------------------------------------------------------------------------------------------
   FUNCTION f_ins_empresas(
      pcempres IN NUMBER,
      pctipemp IN NUMBER,
      psperson IN NUMBER,
      ptempres IN VARCHAR2,
      pnnumnif IN VARCHAR2,
      piminliq IN NUMBER,
      pncarenc IN NUMBER,
      pncardom IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_update_empresas(
      pcempres IN NUMBER,
      pctipemp IN NUMBER,
      psperson IN NUMBER,
      ptempres IN VARCHAR2,
      pnnumnif IN VARCHAR2,
      piminliq IN NUMBER,
      pncarenc IN NUMBER,
      pncardom IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_del_empresas(pcempres IN NUMBER)
      RETURN NUMBER;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_MNT" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MNT" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MNT" TO "PROGRAMADORESCSI";
