--------------------------------------------------------
--  DDL for Package PAC_ALBSGT_JGR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_ALBSGT_JGR" AUTHID CURRENT_USER
IS

/***************************************************************
   PAC_ALBSGT: Especificación del paquete de las funciones
      de las interficies
***************************************************************/
   cerror   NUMBER;

   FUNCTION f_tprefor (
      ptprefor    IN       VARCHAR2,
      ptablas     IN       VARCHAR2,
      psseguro    IN       NUMBER,
      pnriesgo    IN       NUMBER,
      pfefecto    IN       DATE,
      pnmovimi    IN       NUMBER,
      pcgarant    IN       NUMBER,
      resultat    OUT      NUMBER,
      psproces    IN       NUMBER,
      pnmovima    IN       NUMBER DEFAULT 1,
      picapital   IN       NUMBER DEFAULT 0
   )
      RETURN NUMBER;
END pac_albsgt_jgr;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_ALBSGT_JGR" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_ALBSGT_JGR" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_ALBSGT_JGR" TO "PROGRAMADORESCSI";
