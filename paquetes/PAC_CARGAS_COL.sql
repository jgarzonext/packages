--------------------------------------------------------
--  DDL for Package PAC_CARGAS_COL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_CARGAS_COL" authid current_user IS
/**************************************************
cestado = 0 -- Pendent de tractar les persones
        = 1 -- Persones tractades, pendent de tractar el moviment
        = 2 -- Pòlissa gravada (dades bàsiques abans de la 1ª emissió)
        = 3 -- Pòlissa_emesa moviment 1 (nova producció, aportació promotor), anem a cobrar
        = 4 -- Hem cobrat el primer rebut, anem a generar el moviment de l'asseg
        = 5 -- Moviment generat, anem a emetre
        = 6 -- Pòlissa emesa moviment 1 o 2 (si no existeix extra promotor és nova producció, sino
            -- és extra de l'assegurat
        = 7 -- Hem cobrat el segon rebut, pendent de generar la periòdica
***************************************************/
FUNCTION f_texte(plinia IN VARCHAR2, pseparador IN VARCHAR2, pordre IN NUMBER)
         RETURN VARCHAR2 ;
FUNCTION f_carga_col( psproces IN NUMBER,
                      pcempres IN NUMBER, pcramo IN NUMBER,   pcmodali IN NUMBER,
                      pctipseg IN NUMBER, pccolect IN NUMBER, psperson IN NUMBER ,
                      pcdomici IN NUMBER,
                      pfefecto IN DATE,   pnpoliza IN OUT NUMBER,  ptnatrie IN VARCHAR2,
                      pcoficin IN NUMBER, pcagente IN NUMBER, pfvencim IN DATE,
                      ppath IN VARCHAR2,   pnomfitx IN VARCHAR2,
                      psep  IN VARCHAR2, -- Separador de camps
                      pmoneda IN NUMBER, pcidioma IN NUMBER,
                      pcactivi IN NUMBER, pcobrar IN NUMBER)  RETURN NUMBER;
FUNCTION f_carrega_fitxer(psproces OUT NUMBER, pcempres IN NUMBER,
                          pcramo   IN NUMBER, pcmodali IN NUMBER,   pctipseg IN NUMBER,
                          pccolect IN NUMBER, psperson IN NUMBER,   pcdomici IN NUMBER,
                          pnpoliza IN NUMBER, pfefecto IN DATE,     pfvencim IN DATE,
                          pcobrar  IN NUMBER, pcactivi IN NUMBER,   pcoficin IN NUMBER,
                          pcagente IN NUMBER, ptnatrie IN VARCHAR2, ppath    IN VARCHAR2,
                          pnomfitx IN VARCHAR2,  psep  IN VARCHAR2
                          ) RETURN NUMBER ;
END;

 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_CARGAS_COL" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CARGAS_COL" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CARGAS_COL" TO "PROGRAMADORESCSI";
