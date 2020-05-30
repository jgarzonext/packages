--------------------------------------------------------
--  DDL for Package PAC_ZONA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_ZONA" authid current_user IS
/***************************************************************
	PAC_ZONA: Cabecera de las funciones de zonas

***************************************************************/
FUNCTION f_zona (zonificacion IN NUMBER,
		provincia IN NUMBER,
		poblacion IN NUMBER,
 		cp IN NUMBER,
 		fefecto IN DATE,
                fcuando IN DATE,
                pczona OUT NUMBER,
                pszona OUT NUMBER)
  RETURN NUMBER;
  -- Retorna la zona de la localitzacio donada
  -- fefecto: Fecha a tener en cuenta para buscar la zona activa
  -- fcuando: Fecha para simular que la búsqueda se está haciendo un dia en concreto
--------------------------------------------------------------------
FUNCTION f_zonif (pcactpro IN NUMBER, psseguro IN NUMBER, pzonif OUT NUMBER)
  RETURN NUMBER;
  -- Retorna la zonificacio donats una polissa i una activitat profesional
--------------------------------------------------------------------
FUNCTION f_szonif (pcactpro IN NUMBER,
		psseguro IN NUMBER,
		pszonif OUT NUMBER)
  RETURN NUMBER;
  -- Retorna la zonificacio asignada per una activitat prof.
  -- i una polissa donada
--------------------------------------------------------------------
FUNCTION F_Copiazonif (pszonif IN NUMBER, ptcat IN VARCHAR2,
                       ptesp IN VARCHAR2, PUSUARIO IN VARCHAR2)
  RETURN NUMBER;
  -- Esta función permite crear una zonificación completa
  -- a partir de otra ya existente. Copiará los datos que hay en las tablas
  -- CODZONIF,HISZONIF,DESZONIF,CODZONAS,DESZONAS y DETZONAS de una
  -- zonificación a otra. Quedará en estado '1.En construcción'
--------------------------------------------------------------------
FUNCTION F_COPIAZONIFH (PSZONIF IN NUMBER, PSZONIFH IN NUMBER,
                        PUSUARIO IN VARCHAR2)
 RETURN NUMBER;
 --Esta función permite copiar una versión de zonificación. La nueva
 --versión estará en estado '1.
--------------------------------------------------------------------
FUNCTION F_zonagarantia (PSZONIF IN NUMBER, PCPOSTAL IN codpostal.cpostal%TYPE, --3606 jdomingo 29/11/2007  canvi format codi postal
                         PCPOBLAC IN NUMBER,
                         PCPROVIN IN NUMBER, PSPRODUC IN NUMBER, PCACTIVI IN NUMBER,
                         PCGARANT IN NUMBER, PFEFECTO IN DATE, PFCUANDO IN DATE,
                         PCPERMIS OUT NUMBER)
RETURN NUMBER;
   --	Comprobará que un código postal, población o provincia determinada esté
   --                   en una zona de contratación permitida para una garantia a una fecha
   --                   determinada */
    -- fefecto: Fecha a tener en cuenta para buscar la zona activa
    -- fcuando: Fecha para simular que la búsqueda se está haciendo un dia en concreto
--------------------------------------------------------------------------------------------
FUNCTION f_zona2 (zonificacion IN NUMBER,
		 		  provincia IN NUMBER,
				  poblacion IN NUMBER,
 				  cp IN NUMBER,
 				  fefecto IN DATE,
                  fcuando IN DATE)
  RETURN NUMBER;
  -- la función devuleve en el return el código de zona.
  -- fefecto: Fecha a tener en cuenta para buscar la zona activa
  -- fcuando: Fecha para simular que la búsqueda se está haciendo un dia en concreto
--------------------------------------------------------------------
END Pac_Zona;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_ZONA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_ZONA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_ZONA" TO "PROGRAMADORESCSI";
