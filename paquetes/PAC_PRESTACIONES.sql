--------------------------------------------------------
--  DDL for Package PAC_PRESTACIONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_PRESTACIONES" AUTHID current_user IS
------------------------------------------------------------------------------------------
FUNCTION f_validar_poliza (pmodo IN NUMBER, psseguro IN NUMBER, pnpoliza IN NUMBER,
                                                             pncertif IN NUMBER) RETURN NUMBER ;

FUNCTION f_parte_abierto(psseguro IN NUMBER, psprestaplan OUT NUMBER, psperson OUT NUMBER)
   RETURN NUMBER;

FUNCTION f_causante_prestacion(pmodo IN NUMBER, psseguro IN NUMBER, psperson OUT NUMBER)
        RETURN NUMBER;

FUNCTION f_validar_causante_prestacion(psseguro IN NUMBER, psperson IN NUMBER
                            ) RETURN NUMBER;

FUNCTION f_nivel(psseguro IN NUMBER, psperson IN NUMBER, pnnivel OUT NUMBER
                            ) RETURN NUMBER;

FUNCTION f_validar_fecha(pmodo IN NUMBER, psseguro IN NUMBER,  psperson IN NUMBER,
                           pfaccion IN DATE) RETURN NUMBER;

FUNCTION f_calcula_participaciones(psseguro IN NUMBER, psperson IN NUMBER, pctipren IN NUMBER,
                                  pnivel IN NUMBER, pfaccion IN DATE, pctipjub IN NUMBER ,
								  pnparti_actual OUT NUMBER, pnparti_pos OUT NUMBER,
								  piparti_actual OUT NUMBER, piparti_pos OUT NUMBER) RETURN NUMBER;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_PRESTACIONES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PRESTACIONES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PRESTACIONES" TO "PROGRAMADORESCSI";
