--------------------------------------------------------
--  DDL for Package PAC_PLAN_CONTAB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_PLAN_CONTAB" authid current_user IS
FUNCTION f_plan_contab(pcempres IN NUMBER, ppath IN VARCHAR2 ,pfecha IN DATE, pcidioma IN NUMBER ) RETURN NUMBER;
FUNCTION f_recibos_emitidos (pcempres IN NUMBER, ppath IN VARCHAR2 ,ptfitxer IN VARCHAR2, pfecha IN DATE  , pcidioma IN NUMBER) RETURN NUMBER ;
FUNCTION f_recibos_cobrados(pcempres IN NUMBER, ppath IN VARCHAR2 ,ptfitxer IN VARCHAR2, pfecha IN DATE   , pcidioma IN NUMBER) RETURN NUMBER ;
FUNCTION f_recibos_pendientes(pcempres IN NUMBER, ppath IN VARCHAR2 ,ptfitxer IN VARCHAR2, pfecha IN DATE , pcidioma IN NUMBER) RETURN NUMBER ;
FUNCTION f_recibos_extornados (pcempres IN NUMBER, ppath IN VARCHAR2 ,ptfitxer IN VARCHAR2, pfecha IN DATE, pcidioma IN NUMBER) RETURN NUMBER ;
FUNCTION f_recibos_anulados (pcempres IN NUMBER, ppath IN VARCHAR2 ,ptfitxer IN VARCHAR2, pfecha IN DATE  , pcidioma IN NUMBER) RETURN NUMBER ;
FUNCTION f_saldos (ppath IN VARCHAR2 ,ptfitxer IN VARCHAR2, pfecha IN DATE  , pcidioma IN NUMBER) RETURN NUMBER ;
FUNCTION f_retenciones (ppath IN VARCHAR2 ,ptfitxer IN VARCHAR2, pfecha IN DATE  , pcidioma IN NUMBER) RETURN NUMBER;
END Pac_Plan_Contab;

 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_PLAN_CONTAB" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PLAN_CONTAB" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PLAN_CONTAB" TO "PROGRAMADORESCSI";
