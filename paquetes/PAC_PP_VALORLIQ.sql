--------------------------------------------------------
--  DDL for Package PAC_PP_VALORLIQ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_PP_VALORLIQ" 
AS
   num_err NUMBER;

   FUNCTION f_introducir_valorliq (
      pccodpla   IN       NUMBER,
      pfvalor    IN       DATE,
      pivalor    IN       NUMBER,
	  pcidioma	 IN		  NUMBER,
	  pproces 	 IN OUT	  NUMBER,
      pcerror    OUT      NUMBER
   )
      RETURN NUMBER;

   PROCEDURE p_cargar_valorliq (
	  pfitxer	 IN		  VARCHAR2,
      pcidioma   IN		  NUMBER,
	  pproces	 OUT	  NUMBER,
	  pcerror	 OUT	  NUMBER
   );

   PROCEDURE p_actualizar_tdc (
     psseguro  IN  NUMBER,
     pnnumlin  IN  NUMBER,
     pivalor   IN  NUMBER,
     pimovimi  IN  NUMBER,
     pproces   IN  NUMBER DEFAULT NULL,
     pcidioma  IN  NUMBER DEFAULT NULL
   );

END pac_pp_valorliq;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_PP_VALORLIQ" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PP_VALORLIQ" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PP_VALORLIQ" TO "PROGRAMADORESCSI";
