--------------------------------------------------------
--  DDL for Package PAC_ALBSGT_MV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_ALBSGT_MV" authid current_user IS
/***************************************************************
	PAC_ALBSGT_cs: Especificación del paquete de las funciones
		para el cáculo de las preguntas relacionadas
		con productos
***************************************************************/
resultado NUMBER;
function f_aportacion
                    (ptablas IN VARCHAR2, psseguro IN NUMBER,
                     pnriesgo IN NUMBER, pfefecto IN DATE,
                     pnmovimi IN NUMBER, cgarant IN NUMBER ,
                     psproces    IN       NUMBER,
                     pnmovima    IN       NUMBER,
                     picapital   IN       NUMBER)
         return NUMBER;
function f_aportextr
                    (ptablas IN VARCHAR2, psseguro IN NUMBER,
                     pnriesgo IN NUMBER, pfefecto IN DATE,
                     pnmovimi IN NUMBER, cgarant IN NUMBER,
                     psproces    IN       NUMBER,
                     pnmovima    IN       NUMBER,
                     picapital   IN       NUMBER)
         return NUMBER;
function f_irevali
                    (ptablas IN VARCHAR2, psseguro IN NUMBER,
                     pnriesgo IN NUMBER, pfefecto IN DATE,
                     pnmovimi IN NUMBER, cgarant IN NUMBER ,
                     psproces    IN       NUMBER,
                     pnmovima    IN       NUMBER,
                     picapital   IN       NUMBER
                     )
         return NUMBER;
function f_prevali
                    (ptablas IN VARCHAR2, psseguro IN NUMBER,
                     pnriesgo IN NUMBER, pfefecto IN DATE,
                     pnmovimi IN NUMBER, cgarant IN NUMBER ,
                     psproces    IN       NUMBER,
                     pnmovima    IN       NUMBER,
                     picapital   IN       NUMBER
                     )
		 return NUMBER;
function f_frenova
                    (ptablas IN VARCHAR2, psseguro IN NUMBER,
                     pnriesgo IN NUMBER, pfefecto IN DATE,
                     pnmovimi IN NUMBER, cgarant IN NUMBER ,
                     psproces    IN       NUMBER,
                     pnmovima    IN       NUMBER,
                     picapital   IN       NUMBER
                     )
		 return NUMBER;
function f_ndiaspro
                    (ptablas IN VARCHAR2, psseguro IN NUMBER,
                     pnriesgo IN NUMBER, pfefecto IN DATE,
                     pnmovimi IN NUMBER, cgarant IN NUMBER ,
                     psproces    IN       NUMBER,
                     pnmovima    IN       NUMBER,
                     picapital   IN       NUMBER
                     )
         return NUMBER;
function f_psuplem
                    (ptablas IN VARCHAR2, psseguro IN NUMBER,
                     pnriesgo IN NUMBER, pfefecto IN DATE,
                     pnmovimi IN NUMBER, cgarant IN NUMBER ,
                     psproces    IN       NUMBER,
                     pnmovima    IN       NUMBER,
                     picapital   IN       NUMBER
                     )
         return NUMBER;
function f_prevali_ESTIMAT
                    (ptablas IN VARCHAR2, psseguro IN NUMBER,
                     pnriesgo IN NUMBER, pfefecto IN DATE,
                     pnmovimi IN NUMBER, cgarant IN NUMBER ,
                     psproces    IN       NUMBER,
                     pnmovima    IN       NUMBER,
                     picapital   IN       NUMBER
                     )
         return NUMBER;
function f_edad_riesgo
                    (ptablas IN VARCHAR2, psseguro IN NUMBER,
                     pnriesgo IN NUMBER, pfefecto IN DATE,
                     pnmovimi IN NUMBER, cgarant IN NUMBER,
                     psproces    IN       NUMBER,
                     pnmovima    IN       NUMBER,
                     picapital   IN       NUMBER)
 return NUMBER ;
END pac_albsgt_mv;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_ALBSGT_MV" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_ALBSGT_MV" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_ALBSGT_MV" TO "PROGRAMADORESCSI";
