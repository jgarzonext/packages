--------------------------------------------------------
--  DDL for Function F_CAPFALL_ULT_ACT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_CAPFALL_ULT_ACT" (psseguro in number,
                                               pfecha  IN DATE)
  RETURN number authid current_user IS
/******************************************************************************
   -- RSC 13/05/2008 Tarea 5645
   NOMBRE:       F_CAPFALL_ULT_ACT
   DESCRIPCION:  Busca el capital de fallecimiento calculado en la última actualizacion antes de una fecha determinada.
   REVISIONES:
   Ver        Date          Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        13/05/2008    RSC(CSI)         CREACION DE LA FUNCIÓN
   PARAMETROS:
   INPUT:
          PSSEGUR(number) --> Clave del seguro
          PFECHA(date)    --> Fecha
   RETORNA VALUE:
          VALOR(FECHA)-----> FECHA
******************************************************************************/
valor    number;
--v_fefecto      date;

BEGIN

   valor := NULL;

   BEGIN
     FOR regs IN (SELECT ccapfal
                  FROM ctaseguro c, ctaseguro_libreta cl
                  WHERE c.sseguro = psseguro
                    and c.sseguro = cl.sseguro
                    and c.nnumlin = cl.nnumlin
                    AND c.cmovimi = 0
                    AND c.cmovanu <> 1  -- 1 = Anulado
                    AND c.fvalmov<= PFECHA
                  order by c.fvalmov desc, c.nnumlin desc) LOOP

        valor := regs.ccapfal;
        EXIT;
     END LOOP;
     RETURN VALOR;
   EXCEPTION
     WHEN OTHERS THEN
      RETURN NULL;
   END;
END ;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_CAPFALL_ULT_ACT" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_CAPFALL_ULT_ACT" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_CAPFALL_ULT_ACT" TO "PROGRAMADORESCSI";
