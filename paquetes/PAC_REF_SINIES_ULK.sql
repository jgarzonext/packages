--------------------------------------------------------
--  DDL for Package PAC_REF_SINIES_ULK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_REF_SINIES_ULK" AUTHID CURRENT_USER IS

/******************************************************************************
  Package público para Siniestros de pólizas de ahorro.

******************************************************************************/
   type cursor_TYPE is ref cursor;
FUNCTION f_aperturar_siniestro(psseguro IN NUMBER, pnriesgo IN NUMBER, pfsinies IN DATE, pfnotifi IN DATE, ptsinies IN VARCHAR2, pcmotsin IN NUMBER, pcidioma IN NUMBER, pcidioma_user IN NUMBER DEFAULT F_IdiomaUser,
                                      oCODERROR OUT NUMBER, oMSGERROR OUT VARCHAR2)
RETURN NUMBER;

FUNCTION f_valida_permite_rescate_total(psseguro IN NUMBER, pcagente in number, pfrescate IN DATE, pcidioma_user IN NUMBER default F_IdiomaUser,
                              oCODERROR OUT NUMBER, oMSGERROR OUT VARCHAR2)
  RETURN NUMBER;
FUNCTION f_sim_rescate_total(psseguro in number, pcagente in number, pfrescate in date,
   pcidioma in number, pcidioma_user in number,  cavis out number, lavis out varchar2,oCODERROR OUT NUMBER,
   oMSGERROR OUT VARCHAR2)
  RETURN cursor_type;
FUNCTION f_sol_rescate_total(psseguro in number, pcagente in number, pfrescate in date,
   pcidioma in number, pcidioma_user in number, pirescate IN NUMBER,  oCODERROR OUT NUMBER, oMSGERROR OUT VARCHAR2,
   pccausin NUMBER DEFAULT 4)
  RETURN  number;
END Pac_Ref_Sinies_Ulk;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_REF_SINIES_ULK" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_REF_SINIES_ULK" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_REF_SINIES_ULK" TO "PROGRAMADORESCSI";
