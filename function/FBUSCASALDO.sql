--------------------------------------------------------
--  DDL for Function FBUSCASALDO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FBUSCASALDO" (nsesion  IN NUMBER,
                                          pssegur  IN NUMBER,
                                          pffecha  IN NUMBER)
  RETURN NUMBER authid current_user IS
/******************************************************************************
   NOMBRE:       FBUSCASALDO
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
valor    number;
pfecha   date;

BEGIN

   valor := NULL;
   pfecha := to_date(pffecha,'yyyymmdd');

   BEGIN
     FOR regs IN (SELECT imovimi
                  FROM ctaseguro
                  WHERE sseguro = pssegur
                    AND cmovimi = 0
                    AND cmovanu <> 1
                    AND fvalmov <= pfecha
                  order by fvalmov desc, nnumlin desc) LOOP

        valor := regs.imovimi;
        EXIT;
     END LOOP;
     RETURN VALOR;
   EXCEPTION
     WHEN OTHERS THEN
      RETURN NULL;
   END;

   -- RSC 09/05/2008 Tarea 5645
   /*
   BEGIN
   SELECT imovimi
     INTO VALOR
     FROM ctaseguro
    WHERE sseguro = pssegur
      AND cmovimi = 0
      AND cmovanu <> 1 -- 1 = Anulado
      AND (fvalmov, nnumlin) = (SELECT max(fvalmov), max(nnumlin)
                       FROM ctaseguro
                      WHERE sseguro = pssegur
                        AND cmovimi = 0
                        AND cmovanu <> 1 -- 1 = Anulado
                        AND fvalmov<= PFECHA);
   RETURN VALOR;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
	       RETURN NULL;
     WHEN OTHERS THEN
	       RETURN NULL;
   END;
   */
END FBUSCASALDO;
 
 

/

  GRANT EXECUTE ON "AXIS"."FBUSCASALDO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FBUSCASALDO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FBUSCASALDO" TO "PROGRAMADORESCSI";
