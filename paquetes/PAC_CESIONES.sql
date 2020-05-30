--------------------------------------------------------
--  DDL for Package PAC_CESIONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_CESIONES" IS
   FUNCTION f_ces_qn(pnnumlin IN NUMBER, pmotiu IN NUMBER, pfacult IN NUMBER, pnmovigen IN NUMBER,
                                      psproduc IN NUMBER, pctiprea IN NUMBER, pctipre_seg IN NUMBER,--
                                      psproces NUMBER, v_base_rea number, pfdatagen IN DATE,
                                      ptablas IN VARCHAR2 DEFAULT 'EST'
                                       )
   RETURN NUMBER;

   FUNCTION f_insert_ces(pp_capces IN NUMBER, pp_tramo IN NUMBER, pp_facult IN NUMBER,
     pp_cesio IN NUMBER, pp_local IN NUMBER,pp_porce IN NUMBER, pp_sproduc IN NUMBER,--
     registre cesionesaux%ROWTYPE, pmotiu NUMBER, psproces NUMBER, pnmovigen IN NUMBER,
     psperson NUMBER, ptipper VARCHAR2,--BUG CONF-298  Fecha (23/03/2017) - HRE - cumulos
     pctrampa NUMBER DEFAULT NULL, pcutoff VARCHAR2 DEFAULT NULL, --BUG CONF-910  Fecha (12/07/2017) - HRE - Cutoff
     pp_cgesfac IN NUMBER DEFAULT 0

     )
   RETURN NUMBER;

   FUNCTION f_cessio(psproces IN NUMBER,
                    pmotiu IN NUMBER,
                    pmoneda IN NUMBER,
                    pfdatagen IN DATE DEFAULT f_sysdate,
                    pcgesfac IN NUMBER DEFAULT 0,      -- AQUÍ S'HAURÀ DE CONTROLAR SI VENIM DE L'EMISSIÓ
                    ptablas IN VARCHAR2 DEFAULT 'EST') -- 19484 1-Fer o 0-No Facultatiu)
   RETURN NUMBER;

   --
   PROCEDURE cabfacul(regaux1 cesionesaux%ROWTYPE, ptablas IN VARCHAR2 DEFAULT 'EST');

   FUNCTION f_facult(psseguro IN NUMBER, pnriesgo IN NUMBER, pccalif1 IN VARCHAR2,
                     pccalif2 IN NUMBER, pcgarant IN NUMBER, pscontra IN NUMBER, pnversio IN NUMBER,
                     pfinicuf IN DATE, pscumulo IN NUMBER, pfdatagen IN DATE, ptrovat OUT NUMBER,
                     pcestado OUT NUMBER, pfacult OUT NUMBER, pifacced OUT NUMBER)
    RETURN NUMBER;
	
	--INI IAXIS BUG 13246 AABG: Funcion para calcular el facultativo  
 FUNCTION f_obtener_fac(
   psseguro IN NUMBER,
   pnversio IN NUMBER,
   pmotiu IN NUMBER,
   psproduc IN NUMBER,
   pscontra IN NUMBER,
   ppcapces_out IN OUT NUMBER
 )
 RETURN NUMBER;    
 --FIN IAXIS BUG 13246 AABG: Funcion para calcular el facultativo
 
 --INI IAXIS BUG 13246 AABG: Funcion para validar el facultativo  
 FUNCTION f_existe_fac(
   psseguro IN NUMBER,
   pnversio IN NUMBER,
   pmotiu IN NUMBER,
   psproduc IN NUMBER,
   pscontra IN NUMBER,
   p_respuesta OUT NUMBER
 )
 RETURN NUMBER;    
 --FIN IAXIS BUG 13246 AABG: Funcion para validar el facultativo   

END pac_cesiones;

/

  GRANT EXECUTE ON "AXIS"."PAC_CESIONES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CESIONES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CESIONES" TO "PROGRAMADORESCSI";
