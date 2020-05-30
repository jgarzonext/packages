--------------------------------------------------------
--  DDL for Package PAC_CALC_PROV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_CALC_PROV" authid current_user
IS
   FUNCTION f_calculo_prov (
      psesion    IN   NUMBER,
      psseguro   IN   NUMBER,
      pfecha     IN   DATE,
      pFonProv   IN   NUMBER DEFAULT 0  -- 0 = Capital Garantizado
                                        -- 1 = Provisión matemàtica
   )
      RETURN NUMBER;



   FUNCTION f_calc_coefprov ( psesion    IN   NUMBER,
                                psseguro   IN   NUMBER,
                                pfecha     IN   DATE
                                )
      RETURN NUMBER;


   FUNCTION f_calc_isi_pp (
      psesion    IN   NUMBER,
      psseguro   IN   NUMBER,
      pfecha     IN   DATE
   )
      RETURN NUMBER;

  FUNCTION f_calc_isi_pu (
      psesion    IN   NUMBER,
      psseguro   IN   NUMBER,
      pfecha     IN   DATE
   )
      RETURN NUMBER;

  FUNCTION f_calc_isi (
      psesion    IN   NUMBER,
      psseguro   IN   NUMBER,
      pfecha     IN   DATE
   )
      RETURN NUMBER;

END pac_calc_prov;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_CALC_PROV" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CALC_PROV" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CALC_PROV" TO "PROGRAMADORESCSI";
