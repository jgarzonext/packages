--------------------------------------------------------
--  DDL for Package PAC_PROVNOTEC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_PROVNOTEC" AUTHID CURRENT_USER IS
   FUNCTION f_commit_calcul_pppc(
      cempres IN NUMBER,
      aux_factual IN DATE,
      psproces IN NUMBER,
      pcidioma IN NUMBER,
      pcmoneda IN NUMBER,
      pmodo IN VARCHAR2 DEFAULT 'R')
      RETURN NUMBER;

   /*************************************************************************
        Recupera el porcentaje de anulación
        param in pmesini     : inicio de vigencia
        param in pmesfin    : fin  de vigencia
        param in pporcjudi : indica si se ha de buscar el porcentaje de las primas reclamadas judicialmente
     *************************************************************************/
   FUNCTION f_calc_porc_anula_pppc(
      pcempres IN NUMBER,
      aux_factual IN DATE,
      pcramo IN NUMBER,
      pmesini IN NUMBER,
      pmesfin IN NUMBER,
      pporcjudi IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_commit_calcul_pppc_sam(
      cempres IN NUMBER,
      aux_factual IN DATE,
      psproces IN NUMBER,
      pcidioma IN NUMBER,
      pcmoneda IN NUMBER,
      pmodo IN VARCHAR2 DEFAULT 'R')
      RETURN NUMBER;

   -- Calcular fecha provision
   FUNCTION f_fecprov(
      p_pro IN NUMBER,
      p_seg IN NUMBER,
      p_mov IN NUMBER,
      p_efe IN DATE,
      p_act IN DATE)
      RETURN DATE;
END;

/

  GRANT EXECUTE ON "AXIS"."PAC_PROVNOTEC" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PROVNOTEC" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PROVNOTEC" TO "PROGRAMADORESCSI";
