--------------------------------------------------------
--  DDL for Function FBUSCAPREDUC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FBUSCAPREDUC" (psesion  IN NUMBER,
         	  		         psproduc IN NUMBER,
					 pcactivi IN NUMBER,
					 pcgarant IN NUMBER,
					 pfecha   IN NUMBER,
					 pduraci  IN NUMBER)
  RETURN NUMBER authid current_user IS
/******************************************************************************
   NOMBRE:       FBUSCAPREDUC
   DESCRIPCION:  Retorna un % de Reducción
   PARAMETROS:
   INPUT: PSESION(number)  --> Nro. de sesión del evaluador de fórmulas
          PSPRODUC(number) --> Clave del producto
	  PCACTIVI(number) --> Actividad
	  PCGARANT(number) --> Clave de Garantia
	  PFECHA(number)   --> Fecha a aplicar la retención
          PDURACI(number)  --> Año de duración
   RETORNA VALUE:
          VALOR(NUMBER)-----> % DE DEDUCCIÓN
	                      NULL - No existe en la tabla ULPREDE
******************************************************************************/
VALOR  NUMBER;
XFECHA DATE;
BEGIN
   valor := NULL;
   XFECHA := TO_DATE(PFECHA,'YYYYMMDD');
   BEGIN
   		SELECT preduc
		INTO valor
		FROM ULPREDE UL, PRODUCTOS P
		WHERE ul.cramo   = p.cramo
		  AND ul.cmodali = p.cmodali
		  AND ul.ctipseg = p.ctipseg
		  AND ul.ccolect = p.ccolect
		  AND ul.cactivi = pcactivi
		  AND ul.cgarant = pcgarant
		  AND p.sproduc  = psproduc
		  AND finicio = (SELECT MAX(ul1.finicio)
		  	  		  	 FROM ULPREDE ul1, PRODUCTOS p1
						 WHERE p1.sproduc = psproduc
						   AND ul1.cramo   = p1.cramo
		                                   AND ul1.cmodali = p1.cmodali
		                                   AND ul1.ctipseg = p1.ctipseg
		                                   AND ul1.ccolect = p1.ccolect
						   AND ul1.cactivi = pcactivi
						   AND ul1.cgarant = pcgarant
						   AND ul1.finicio <= xfecha)
		  AND pduraci BETWEEN ul.nduraci AND ul.nperman;
		RETURN valor;
   EXCEPTION
     WHEN OTHERS THEN
	  BEGIN
   		SELECT preduc
		INTO valor
		FROM ULPREDE UL3, PRODUCTOS P1
		WHERE UL3.cramo   = p1.cramo
		  AND UL3.cmodali = p1.cmodali
		  AND UL3.ctipseg = p1.ctipseg
		  AND UL3.ccolect = p1.ccolect
		  AND UL3.cactivi = pcactivi
		  AND UL3.cgarant = 999
		  AND p1.sproduc  = psproduc
		  AND finicio = (SELECT MAX(ul2.finicio)
		  	  		  	 FROM ULPREDE UL2, PRODUCTOS P2
						 WHERE p2.sproduc = psproduc
						   AND ul2.cramo   = p2.cramo
		                                   AND ul2.cmodali = p2.cmodali
		                                   AND ul2.ctipseg = p2.ctipseg
		                                   AND ul2.ccolect = p2.ccolect
						   AND ul2.cactivi = pcactivi
						   AND ul2.cgarant = 999
						   AND ul2.finicio <= xfecha)
		  AND pduraci BETWEEN UL3.nduraci AND UL3.nperman;
		RETURN valor;
	  EXCEPTION
	    WHEN OTHERS THEN
		    RETURN NULL;
	  END;
   END;
EXCEPTION
  WHEN OTHERS THEN
	  RETURN NULL;
END Fbuscapreduc;
 
 

/

  GRANT EXECUTE ON "AXIS"."FBUSCAPREDUC" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FBUSCAPREDUC" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FBUSCAPREDUC" TO "PROGRAMADORESCSI";
