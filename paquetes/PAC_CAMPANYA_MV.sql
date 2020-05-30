--------------------------------------------------------
--  DDL for Package PAC_CAMPANYA_MV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_CAMPANYA_MV" AUTHID CURRENT_USER IS

   FUNCTION F_Campanya_Mv (pcpromoc IN NUMBER, pfecha_par IN NUMBER)
    RETURN NUMBER;
   FUNCTION f_campa_acumulada (pcpromoc IN NUMBER, pdata IN DATE ) RETURN NUMBER;

END Pac_Campanya_Mv;

 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_CAMPANYA_MV" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CAMPANYA_MV" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CAMPANYA_MV" TO "PROGRAMADORESCSI";
