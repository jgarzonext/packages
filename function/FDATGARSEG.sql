--------------------------------------------------------
--  DDL for Function FDATGARSEG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FDATGARSEG" (nsesion  IN NUMBER,
                                       pseguro  IN NUMBER,
                                       pfecha   IN NUMBER,
									   pmodo    IN NUMBER,
									   pgarant  IN NUMBER,
									   pnriesgo  IN NUMBER  default 1)
  RETURN NUMBER authid current_user IS
/******************************************************************************
   NOMBRE:
   DESCRIPCION:  Importe de garantías de un seguro a una fecha.
   PARAMETROS:
   INPUT: NSESION(number) --> Nro. de sesión del evaluador de fórmulas
          PSEGURO(number) --> secuencia del seguro que se está consultando
		  PFECHA(number)  --> Fecha de consulta.
		  PMODO (number)  --> 1 Capital Total asegurado.    ICAPTOT
		                      2 Prima total anual.          IPRITOT
		  PGARANT(number) --> Código de la garantía.
		  PNRIESGO(NUMBER) --> Núemro de riesgo
   RETORNA VALUE:
          NUMBER------------> Retorna el capital asegurado
******************************************************************************/
valor     number;
xfecha    date;
BEGIN
   valor := NULL;
   BEGIN
     xfecha := to_date(pfecha, 'yyyymmdd');
     SELECT DECODE(PMODO,1,ICAPTOT,2,IPRITOT,0) INTO VALOR
	   FROM GARANSEG
	  WHERE SSEGURO = PSEGURO
	    AND CGARANT = PGARANT
		AND NRIESGO = PNRIESGO
		AND FINIEFE <= xFECHA AND (FFINEFE IS NULL OR FFINEFE > xFECHA);
     RETURN VALOR;
   EXCEPTION
    WHEN OTHERS THEN RETURN 0;
   END;
END FDATGARSEG;
 
 

/

  GRANT EXECUTE ON "AXIS"."FDATGARSEG" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FDATGARSEG" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FDATGARSEG" TO "PROGRAMADORESCSI";
