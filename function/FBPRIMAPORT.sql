--------------------------------------------------------
--  DDL for Function FBPRIMAPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FBPRIMAPORT" (nsesion  IN NUMBER,
                                        pseguro  IN NUMBER,
                                        pfecha   IN NUMBER)
  RETURN NUMBER authid current_user IS
/******************************************************************************
   NOMBRE:
   DESCRIPCION:  Importe de las apotaciones realizadas de un seguro hasta una fecha.

   PARAMETROS:
   INPUT: NSESION(number) --> Nro. de sesión del evaluador de fórmulas
          PSEGURO(number) --> secuencia del seguro que se está consultando
		  PFECHA(number)  --> Fecha de consulta.
   RETORNA VALUE:
          NUMBER------------> Retorna el total de Aportaciones realizadas
******************************************************************************/
valor     number;
xprimas	  number;
xfecha    date;
BEGIN
   valor := NULL;
   xfecha:= to_Date(pfecha,'yyyymmdd');
-- Averigüo todas las primas aportadas.
   BEGIN
     SELECT sum(iprima)
       INTO xprimas
       FROM PRIMAS_APORTADAS
      WHERE sseguro = pseguro
        AND fvalmov <= xfecha;
	  RETURN XPRIMAS;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN RETURN NULL;
     WHEN OTHERS THEN RETURN NULL;
   END;
END FBPRIMAPORT;
 
 

/

  GRANT EXECUTE ON "AXIS"."FBPRIMAPORT" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FBPRIMAPORT" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FBPRIMAPORT" TO "PROGRAMADORESCSI";
