--------------------------------------------------------
--  DDL for Package PAC_CARGAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_CARGAS" authid current_user IS
   FUNCTION DIAMES(fecha date) RETURN NUMBER;
   FUNCTION insertar_persona (NPERSON NUMBER, NNIF VARCHAR2, NOMBRE VARCHAR2, PAPELLI VARCHAR2,
                              SAPELLI VARCHAR2, SEXO NUMBER, CIVIL NUMBER, BANCO VARCHAR2,
                              TIPERSONA NUMBER, FECNACIMI DATE, TELEFONO VARCHAR2, PROFESION NUMBER,
                              VINCULACION NUMBER, NUMPHOS NUMBER, NIFPHOS VARCHAR2,IDIOMA CHAR,
                              TIDENTI NUMBER) RETURN  NUMBER ;
   FUNCTION existeix_persona(pnnumnif VARCHAR2,pcpertip NUMBER, ptnombre VARCHAR2, ptapelli1 VARCHAR2,
                             ptapelli2 VARCHAR2, xSexe NUMBER, xEcivil NUMBER, pfnacimi DATE) RETURN NUMBER;
   FUNCTION f_trobar_poblacio(pcpostal IN codpostal.cpostal%TYPE, --3606 jdomingo 30/11/2007  canvi format codi postal
   pcprovin IN NUMBER, ptpoblac IN VARCHAR2, pcpoblac OUT NUMBER) RETURN NUMBER;
   FUNCTION f_insertar_poblacio (pcpostal IN codpostal.cpostal%TYPE, --3606 jdomingo 30/11/2007  canvi format codi postal
   pcprovin in NUMBER, ptpoblac in VARCHAR2) RETURN NUMBER;
   FUNCTION f_comparar_direccio(psperson IN NUMBER, pcdomici OUT NUMBER,
                                pcpostal IN codpostal.cpostal%TYPE, --3606 jdomingo 30/11/2007  canvi format codi postal
                                pcprovin IN number,
                                ptnomvia IN VARCHAR2, pnnumvia IN VARCHAR2,
                                ptcomple IN VARCHAR2, pcsiglas IN VARCHAR2) RETURN NUMBER;
   FUNCTION persona (psproces    IN NUMBER,   tpersona IN NUMBER,  xtnif_asse IN NUMBER,
                     xnif_asseg  IN VARCHAR2, xnom     IN VARCHAR2,xcognom1   IN VARCHAR2,
                     xcognom2    IN VARCHAR2, xsexe    IN NUMBER,  xecivil    IN NUMBER,
                     xDNaix      IN DATE,     xtipvia  IN NUMBER,  xnomvia    IN VARCHAR2,
                     xNumero     IN NUMBER,   xcomplement IN VARCHAR2,
                     xcpostal    IN VARCHAR2, xnpoblac IN VARCHAR2, xnprovin IN VARCHAR2,
                     psperson   OUT NUMBER,   pcdomici OUT NUMBER  ) RETURN NUMBER;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_CARGAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CARGAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CARGAS" TO "PROGRAMADORESCSI";
