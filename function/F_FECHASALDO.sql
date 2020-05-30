--------------------------------------------------------
--  DDL for Function F_FECHASALDO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_FECHASALDO" (psseguro in number,
                                          pfecha  IN DATE)
  RETURN date authid current_user IS
/******************************************************************************
   NOMBRE:       F_FECHASALDO
   DESCRIPCION:  Busca LA FECHA DEL ULTIMO REGISTRO DE SALDO ANTES DE  UNA fecha determinada.
   REVISIONES:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        15/1/2003	  YIL(CSI)   	    CREACION DE LA FUNCIÓN
   PARAMETROS:
   INPUT:
          PSSEGUR(number) --> Clave del seguro
          PFECHA(date)    --> Fecha
   RETORNA VALUE:
          VALOR(FECHA)-----> FECHA
******************************************************************************/
valor    DATE;
--v_fefecto	  date;

BEGIN

   valor := NULL;

   BEGIN
     FOR regs IN (SELECT FVALMOV
                  FROM ctaseguro c
                  WHERE c.sseguro = psseguro
                    AND c.cmovimi = 0
                    AND c.cmovanu <> 1  -- 1 = Anulado
                    AND c.fvalmov <= pfecha
                  order by c.fvalmov desc, c.nnumlin desc) LOOP

        valor := regs.FVALMOV;
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
   SELECT FVALMOV
     INTO VALOR
     FROM ctaseguro c
    WHERE c.sseguro = psseguro
      AND c.cmovimi = 0
      AND c.cmovanu <> 1  -- 1 = Anulado
      AND (c.fvalmov,c.nnumlin) = (SELECT max(cc.fvalmov), max(cc.nnumlin)
                       FROM ctaseguro cc
                      WHERE cc.sseguro = psseguro
                        AND cc.cmovimi = 0
                        AND cc.cmovanu <> 1 -- 1 = Anulado
                        AND cc.fvalmov<= PFECHA);
   RETURN VALOR;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
	      return null;
     WHEN OTHERS THEN
	       RETURN NULL;
   END;
   */

END ;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_FECHASALDO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_FECHASALDO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_FECHASALDO" TO "PROGRAMADORESCSI";
