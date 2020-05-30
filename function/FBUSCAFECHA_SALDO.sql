--------------------------------------------------------
--  DDL for Function FBUSCAFECHA_SALDO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FBUSCAFECHA_SALDO" (nsesion  IN NUMBER,
                                                pssegur  IN NUMBER,
                                                pffecha  IN NUMBER)
  RETURN DATE authid current_user IS
/******************************************************************************
   NOMBRE:       FBUSCAFECHA_SALDO
   DESCRIPCION:  Busca el saldo en cuenta seguro a una fecha determinada.
   REVISIONES:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        25/5/2001   AFM(STRATEGY)    CREACION DE LA FUNCIÓN
   PARAMETROS:
   INPUT: NSESION(number) --> Nro. de sesión del evaluador de fórmulas
          PSSEGUR(number) --> Clave del seguro
          PFECHA(date)    --> Fecha
   RETORNA VALUE:
          VALOR(NUMBER)-----> Importe
******************************************************************************/
valor    date;
pfecha   date;

BEGIN

   valor := NULL;
   pfecha := to_date(pffecha,'yyyymmdd');

   BEGIN
     FOR regs IN (SELECT FVALMOV
                  FROM ctaseguro
                  WHERE sseguro = pssegur
                    AND cmovimi = 0
                    AND cmovanu <> 1
                    AND fvalmov <= pfecha
                  order by fvalmov desc, nnumlin desc) LOOP

        valor := regs.FVALMOV;
        EXIT;
     END LOOP;
     RETURN VALOR;
   EXCEPTION
     WHEN OTHERS THEN
      RETURN NULL;
   END;
END FBUSCAFECHA_SALDO;
 
 

/

  GRANT EXECUTE ON "AXIS"."FBUSCAFECHA_SALDO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FBUSCAFECHA_SALDO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FBUSCAFECHA_SALDO" TO "PROGRAMADORESCSI";
