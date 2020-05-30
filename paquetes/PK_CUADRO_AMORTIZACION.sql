--------------------------------------------------------
--  DDL for Package PK_CUADRO_AMORTIZACION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PK_CUADRO_AMORTIZACION" 
IS

 fvenc DATE;
 f1per DATE;

 TYPE t_amortizacion IS RECORD (
 	  			   	  		  famort    DATE,
							  interes   NUMBER,
							  capital   NUMBER,
							  pendiente NUMBER,
							  periodo   NUMBER
							 );
 TYPE t_cuadro IS TABLE OF t_amortizacion INDEX BY BINARY_INTEGER;
 cuadro t_cuadro;

 PROCEDURE CUADRO_AMORTIZACION (p_sseguro  IN NUMBER,
	   	  					    p_capital  IN NUMBER,
	   	  		  				p_interes  IN NUMBER,
								p_carencia IN NUMBER,
								p_fefecto  IN DATE,
								p_periodos IN NUMBER,
								p_frecuencia IN NUMBER);
PROCEDURE calcular_cuadro(p_sseguro IN NUMBER, p_fefecto IN DATE);
PROCEDURE pinta_cuadro;

FUNCTION capital_pendiente (p_sseguro IN NUMBER, p_fefecto IN DATE, p_fecha IN DATE)
	RETURN NUMBER;

PROCEDURE ver_mensajes(nerr IN NUMBER, result out t_amortizacion);

END pk_cuadro_amortizacion;

 
 

/

  GRANT EXECUTE ON "AXIS"."PK_CUADRO_AMORTIZACION" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PK_CUADRO_AMORTIZACION" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PK_CUADRO_AMORTIZACION" TO "PROGRAMADORESCSI";
