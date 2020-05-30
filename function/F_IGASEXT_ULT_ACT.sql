--------------------------------------------------------
--  DDL for Function F_IGASEXT_ULT_ACT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_IGASEXT_ULT_ACT" (psseguro IN NUMBER, pfecha IN DATE)
   RETURN NUMBER AUTHID CURRENT_USER IS
/******************************************************************************
   NOMBRE:       F_IGASEXT_ULT_ACT
   DESCRIPCION:  Busca el importe de gastos externos (comision) calculado en la última actualizacion antes de una fecha determinada.
   REVISIONES:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        27/01/2003  YIL(CSI)         CREACION DE LA FUNCIÓN
   2.0        15/07/2014  AFM              0032058: GAP. Prima de Riesgo, gastos y comisiones prepagables.
                                           Si es prepagable las comisiones se guardan en mvto 22 - ahorro 82 - PP, ULK
   PARAMETROS:
   INPUT:
          PSSEGUR(number) --> Clave del seguro
          PFECHA(date)    --> Fecha
   RETORNA VALUE:
          VALOR(FECHA)-----> FECHA
******************************************************************************/
   valor          NUMBER;
--v_fefecto      date;
BEGIN
   valor := NULL;

   BEGIN
      FOR regs IN (SELECT   igasext
                       FROM ctaseguro c, ctaseguro_libreta cl
                      WHERE c.sseguro = psseguro
                        AND c.sseguro = cl.sseguro
                        AND c.nnumlin = cl.nnumlin
                        AND c.cmovimi IN(0, 22, 82)
                        AND c.cmovanu <> 1   -- 1 = Anulado
                        AND c.fvalmov <= pfecha
                   ORDER BY c.fvalmov DESC, c.nnumlin DESC) LOOP
         valor := regs.igasext;
         EXIT;
      END LOOP;

      RETURN valor;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END;
END;

/

  GRANT EXECUTE ON "AXIS"."F_IGASEXT_ULT_ACT" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_IGASEXT_ULT_ACT" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_IGASEXT_ULT_ACT" TO "PROGRAMADORESCSI";
