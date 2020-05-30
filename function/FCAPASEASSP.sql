--------------------------------------------------------
--  DDL for Function FCAPASEASSP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FCAPASEASSP" (nsesion  IN NUMBER,
                       pseguro  IN NUMBER,
                       pfecha IN NUMBER)
  RETURN NUMBER authid current_user IS
/******************************************************************************
   NOMBRE:
   DESCRIPCION:  Capital ASEGURADO a una fecha determinada (PRODUCTO ASSP).
   PARAMETROS:
   INPUT: NSESION(number) --> Nro. de sesión del evaluador de fórmulas
          PSEGURO(number) --> secuencia del seguro que se está consultando
    PFECHA(number)  --> Fecha de consulta.
   RETORNA VALUE:
          NUMBER------------> Retorna el capital asegurado
******************************************************************************/
valor     number;
xfecha    date;
xfecefe   date;
BEGIN
   valor := NULL;
   xfecefe := NULL;
   BEGIN
     xfecha := to_date(pfecha, 'yyyymmdd');
     VALOR := PK_CUADRO_AMORTIZACION.CAPITAL_PENDIENTE(PSEGURO,XFECEFE,XFECHA);
     RETURN VALOR;
   EXCEPTION
    WHEN OTHERS THEN RETURN 0;
   END;
END FCAPASEASSP;
 
 

/

  GRANT EXECUTE ON "AXIS"."FCAPASEASSP" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FCAPASEASSP" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FCAPASEASSP" TO "PROGRAMADORESCSI";
