--------------------------------------------------------
--  DDL for Package PAC_ALBSGT_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_ALBSGT_P" authid current_user IS
/***************************************************************
	PAC_ALBSGT_P: Especificación del paquete de las funciones
		para el cáculo de las preguntas relacionadas
		con productos
***************************************************************/
resultado NUMBER;
function f_continente_contenido
                    (ptablas IN VARCHAR2, psseguro IN NUMBER,
                     pnriesgo IN NUMBER, pfefecto IN DATE,
                     pnmovimi IN NUMBER, psseguro2 IN NUMBER ,ptipo IN NUMBER)
         return NUMBER;
END pac_albsgt_p;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_ALBSGT_P" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_ALBSGT_P" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_ALBSGT_P" TO "PROGRAMADORESCSI";
