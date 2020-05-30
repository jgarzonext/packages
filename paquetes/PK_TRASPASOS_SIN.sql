--------------------------------------------------------
--  DDL for Package PK_TRASPASOS_SIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PK_TRASPASOS_SIN" AS
   FUNCTION  F_CREA_SINIESTRO (psseguro IN NUMBER, pstras IN NUMBER, pfvalmov IN DATE,
      ptipdestinat IN NUMBER, pimovimi IN NUMBER, pspersdest IN NUMBER,
      ptipsinistre IN NUMBER, PNSINIES OUT NUMBER, PSIDEPAG OUT NUMBER,
      paccpag IN NUMBER) RETURN NUMBER;
   FUNCTION F_REGSINIES (psseguro IN NUMBER, pcramo IN NUMBER, pfecha IN DATE,
      ptsinies IN VARCHAR2, pnsinies OUT NUMBER,pcausa IN NUMBER) RETURN NUMBER;
   FUNCTION F_REGPAGOSIN (pnsinies IN NUMBER,pctipdes IN NUMBER,psperson IN NUMBER,
                 pctippag IN NUMBER,pcestpag IN NUMBER,pcforpag IN NUMBER,
                 pccodcon IN NUMBER,pcmanual IN NUMBER,pcimpres IN NUMBER,
                 pfefepag IN DATE,pfordpag IN DATE,pnmescon IN NUMBER,
                 ptcoddoc IN NUMBER,pisinret IN NUMBER,piconret IN NUMBER,
                 piretenc IN NUMBER,piimpiva IN NUMBER,ppretenc IN NUMBER,
                 pcptotal IN NUMBER,pfimpres IN DATE,Psidepag IN OUT NUMBER) RETURN NUMBER;
   FUNCTION F_REGDESTINAT (pnsinies IN NUMBER, psperson IN NUMBER,
                 pctipdes IN NUMBER, pcpagdes IN NUMBER,
                 pivalora IN NUMBER, pcactpro IN NUMBER) RETURN NUMBER;
   FUNCTION F_REGVALORAC (pnsinies IN NUMBER, pcgarant IN NUMBER, pfecha IN DATE,
      pivalora IN NUMBER) RETURN NUMBER;
   FUNCTION F_ACEPTAR_PAGO (psidepag IN NUMBER,pnsinies IN NUMBER,ford IN DATE,
      cptotal IN NUMBER, fechapago IN DATE, psseguro IN NUMBER,pmoneda IN NUMBER,
      paccpag IN NUMBER)
      RETURN NUMBER;
   FUNCTION F_CIERRA_SINIESTRO(pnsinies NUMBER) RETURN NUMBER;
END Pk_Traspasos_Sin;
 
 

/

  GRANT EXECUTE ON "AXIS"."PK_TRASPASOS_SIN" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PK_TRASPASOS_SIN" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PK_TRASPASOS_SIN" TO "PROGRAMADORESCSI";
