--------------------------------------------------------
--  DDL for Package PAC_CAMBIOCARTERA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_CAMBIOCARTERA" authid current_user IS
--------------------------------------------------------------
FUNCTION cambiocartera(pmodo IN VARCHAR2, psproduc IN NUMBER, pcactivi IN NUMBER,
                       psseguro IN NUMBER,pcramo IN NUMBER, pcmodali IN NUMBER,
                       pctipseg IN NUMBER, pccolect IN NUMBER,
                       pfcaranu IN DATE, pnsuplem IN NUMBER, pcumple OUT NUMBER,
                       pcactivides OUT NUMBER)
         RETURN NUMBER ;

FUNCTION garanties_noves(psproduc_des IN NUMBER, pcactivi_des IN NUMBER,
                         psseguro IN NUMBER,
                         pnmovimi IN NUMBER, pfcaranu IN DATE) RETURN NUMBER ;
FUNCTION  comprobar_condicion(psseguro IN NUMBER, psperson IN NUMBER,pcramo IN NUMBER,
                              pcmodali IN NUMBER, pctipseg IN NUMBER,pccolect IN NUMBER,
                              pcactivi IN NUMBER, pcclave IN NUMBER, plimit IN NUMBER,
                              pfcaranu IN DATE, pdcambio IN VARCHAR2,
                              pcumple OUT NUMBER) RETURN NUMBER ;

END;

 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_CAMBIOCARTERA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CAMBIOCARTERA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CAMBIOCARTERA" TO "PROGRAMADORESCSI";
