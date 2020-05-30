--------------------------------------------------------
--  DDL for Package PAC_PP_OPE_ECO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_PP_OPE_ECO" AUTHID current_user
IS

  FUNCTION f_sup_aportacion (
      p_sseguro   IN     NUMBER,
      p_imovimi   IN     NUMBER,
      p_fvalor    IN     DATE,
	  p_nmovimi   OUT    NUMBER
   )
      RETURN NUMBER;

  FUNCTION f_emitir (
      p_sseguro   IN     NUMBER,
	  p_cidioma   IN	 NUMBER
  )
      RETURN NUMBER;

  FUNCTION f_upd_recibo (
      p_sseguro    IN     NUMBER,
	  p_nmovimi    IN     NUMBER,
	  p_cestrec	   IN     NUMBER,
	  p_nrecibo    IN OUT NUMBER
  )
      RETURN NUMBER;

  FUNCTION f_aportacion (
      p_sseguro    IN    NUMBER,
	  p_cidioma    IN    NUMBER,
	  p_imovimi    IN    NUMBER,
	  p_nrecibo    OUT   NUMBER,
	  p_cerror     OUT   NUMBER
  )
      RETURN NUMBER;

  FUNCTION f_anul_aport (
      p_sseguro    IN    NUMBER,
	  p_cidioma    IN    NUMBER,
	  p_nrecibo    IN    NUMBER,
	  p_imovimi    IN    NUMBER,
	  p_cerror	   OUT   NUMBER
  )
      RETURN NUMBER;

END PAC_PP_OPE_ECO;

 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_PP_OPE_ECO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PP_OPE_ECO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PP_OPE_ECO" TO "PROGRAMADORESCSI";
