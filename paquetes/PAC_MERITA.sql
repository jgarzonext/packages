--------------------------------------------------------
--  DDL for Package PAC_MERITA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MERITA" authid current_user IS

   FUNCTION f_permerita (pctipo IN NUMBER,pfemisio IN DATE, pfefecto IN DATE,pcempres IN NUMBER)
            RETURN NUMBER ;

   PROCEDURE proceso_batch_cierre(pmodo IN NUMBER, pcempres IN NUMBER, pmoneda IN NUMBER,
                                  pcidioma IN NUMBER,pfperfin IN DATE,pfcierre IN DATE,
                                  pcerror OUT NUMBER, psproces OUT NUMBER, pfproces OUT DATE);

   FUNCTION f_rebut_meritat(pcempres IN NUMBER, pnrecibo IN NUMBER,pmeritat OUT NUMBER)
           RETURN NUMBER;

   FUNCTION f_anulacio_sense_efecte(pfefecto IN DATE, pfanulac IN DATE, pnrecibo IN NUMBER,
                                 pnperven IN NUMBER,
                                 pfmovdia_anula IN DATE , pfcierre IN DATE,
                                 pfcierre_ant IN DATE, panyven IN NUMBER,
                                 pmesven IN NUMBER)
         RETURN NUMBER;
   FUNCTION f_merita_gar (pcramo IN NUMBER, pcmodali IN NUMBER, pctipseg IN NUMBER,
                       pccolect IN NUMBER,pcactivi IN NUMBER, pcgarant IN NUMBER)
         RETURN NUMBER;

   --FUNCTION actualiza_perven(pcempres IN NUMBER, pfperini IN DATE, pfperfin IN DATE)
   --         RETURN NUMBER;

END;

 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_MERITA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MERITA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MERITA" TO "PROGRAMADORESCSI";
