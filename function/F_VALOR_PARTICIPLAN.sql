--------------------------------------------------------
--  DDL for Function F_VALOR_PARTICIPLAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_VALOR_PARTICIPLAN" ( FECHA DATE, pSSEGURO NUMBER, TIPDIVISA OUT NUMBER  ) RETURN NUMBER AUTHID CURRENT_USER IS
  -- ************************************
  -- Esta función devuelve el importe del valor de la partición del plan
  -- asociado al producto según el día introducido ( FECHA )
  -- y el valor de la divisa del producto
  -- en función a la póliza
  -- En el caso de que sean pesetas, lo redondea para que no haya decimales.
  -- En caso de error devuelve -1
  -- ************************************
  VALOR NUMBER(25,9);
  DIVISA NUMBER(1);
BEGIN
  SELECT PRODUCTOS.CDIVISA,
         ( IVALORP )
  INTO  DIVISA
       ,VALOR
  FROM PRODUCTOS, SEGUROS, VALPARPLA, PROPLAPEN
  WHERE SEGUROS.SSEGURO = pSSEGURO
  AND SEGUROS.CRAMO = PRODUCTOS.CRAMO
  AND SEGUROS.CMODALI = PRODUCTOS.CMODALI
  AND SEGUROS.CTIPSEG = PRODUCTOS.CTIPSEG
  AND SEGUROS.CCOLECT = PRODUCTOS.CCOLECT
  AND PROPLAPEN.SPRODUC = PRODUCTOS.SPRODUC
  AND PROPLAPEN.CCODPLA = VALPARPLA.CCODPLA
-- MSR
  AND FVALORA = TRUNC(FECHA) ;
--  AND TO_CHAR(FECHA,'YYYYMMDD') = TO_CHAR(FVALORA,'YYYYMMDD');
  TIPDIVISA := DIVISA;

  RETURN ( VALOR );
EXCEPTION
  WHEN OTHERS THEN
     RETURN ( -1 );
END; 
 
 

/

  GRANT EXECUTE ON "AXIS"."F_VALOR_PARTICIPLAN" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_VALOR_PARTICIPLAN" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_VALOR_PARTICIPLAN" TO "PROGRAMADORESCSI";
