--------------------------------------------------------
--  DDL for Function FBUSCASALDO_SHW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FBUSCASALDO_SHW" (
   nsesion IN NUMBER,
   pssegur IN NUMBER,
   pffecha IN NUMBER)
   RETURN NUMBER AUTHID CURRENT_USER IS
/******************************************************************************
 NOMBRE: FBUSCASALDO
 DESCRIPCION: Busca el saldo en cuenta seguro a una fecha determinada.
 REVISIONES:
 Ver Date Author Description
 --------- ---------- --------------- ------------------------------------
 1.0 25/5/2001 AFM(STRATEGY) CREACION DE LA FUNCIÓN
 PARAMETROS:
 INPUT: NSESION(number) --> Nro. de sesión del evaluador de fórmulas
 PSSEGUR(number) --> Clave del seguro
 PFECHA(date) --> Fecha
 RETORNA VALUE:
 VALOR(NUMBER)-----> Importe
******************************************************************************/
   valor          NUMBER;
   pfecha         DATE;
BEGIN
   valor := NULL;
   pfecha := TO_DATE(pffecha, 'yyyymmdd');

   BEGIN
      FOR regs IN (SELECT   imovimi
                       FROM ctaseguro_shadow
                      WHERE sseguro = pssegur
                        AND cmovimi = 0
                        AND cmovanu <> 1
                        AND fvalmov <= pfecha
                   ORDER BY fvalmov DESC, nnumlin DESC) LOOP
         valor := regs.imovimi;
         EXIT;
      END LOOP;

      RETURN valor;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END;
END fbuscasaldo_shw;

/

  GRANT EXECUTE ON "AXIS"."FBUSCASALDO_SHW" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FBUSCASALDO_SHW" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FBUSCASALDO_SHW" TO "PROGRAMADORESCSI";
