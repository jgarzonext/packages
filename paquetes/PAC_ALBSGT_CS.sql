--------------------------------------------------------
--  DDL for Package PAC_ALBSGT_CS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_ALBSGT_CS" authid current_user IS
/***************************************************************
    PAC_ALBSGT_cs: Especificación del paquete de las funciones
        para el cáculo de las preguntas relacionadas
        con productos
***************************************************************/
resultado NUMBER;
function f_continente_contenido
                    (ptablas IN VARCHAR2, psseguro IN NUMBER,
                     pnriesgo IN NUMBER, pfefecto IN DATE,
                     pnmovimi IN NUMBER, psseguro2 IN NUMBER ,
                     psproces    IN       NUMBER,
                     pnmovima    IN       NUMBER,
                     picapital   IN       NUMBER,
                     ptipo IN NUMBER)
         return NUMBER;
function f_capital_maquinaria
                    (ptablas IN VARCHAR2, psseguro IN NUMBER,
                     pnriesgo IN NUMBER, pfefecto IN DATE,
                     pnmovimi IN NUMBER, psseguro2 IN NUMBER,
                     psproces    IN       NUMBER,
                     pnmovima    IN       NUMBER,
                     picapital   IN       NUMBER)
         return NUMBER;
function f_responsabilidad_civil
                    (ptablas IN VARCHAR2, psseguro IN NUMBER,
                     pnriesgo IN NUMBER, pfefecto IN DATE,
                     pnmovimi IN NUMBER, psseguro2 IN NUMBER ,
                     psproces    IN       NUMBER,
                     pnmovima    IN       NUMBER,
                     picapital   IN       NUMBER
                     )
         return NUMBER;
function f_dias_obra
                    (ptablas IN VARCHAR2, psseguro IN NUMBER,
                     pnriesgo IN NUMBER, pfefecto IN DATE,
                     pnmovimi IN NUMBER, psseguro2 IN NUMBER,
                     psproces    IN       NUMBER,
                     pnmovima    IN       NUMBER,
                     picapital   IN       NUMBER
                      )
         return NUMBER;
function f_tipo_obra
                    (ptablas IN VARCHAR2, psseguro IN NUMBER,
                     pnriesgo IN NUMBER, pfefecto IN DATE,
                     pnmovimi IN NUMBER, psseguro2 IN NUMBER,
                     psproces    IN       NUMBER,
                     pnmovima    IN       NUMBER,
                     picapital   IN       NUMBER
                      )
         return NUMBER;
END pac_albsgt_cs;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_ALBSGT_CS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_ALBSGT_CS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_ALBSGT_CS" TO "PROGRAMADORESCSI";
