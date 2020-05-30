--------------------------------------------------------
--  DDL for Function F_RECPEN_PP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_RECPEN_PP" ( psseguro IN NUMBER , ptipo IN NUMBER)
RETURN NUMBER AUTHID CURRENT_USER IS
   RECPEN NUMBER;
   IMPRECPEN NUMBER;
BEGIN
   -- Devuelve el n�mero de recibos pendientes si el tipo = 1
   -- o el importe si el tipo = 2;
   SELECT DECODE(COUNT(*),0,NULL,COUNT(*))
   ,DECODE(SUM(ITOTALR),0,NULL,SUM(ITOTALR))
   INTO RECPEN, IMPRECPEN
   --, :IP_IMPRECPEN
   FROM MOVRECIBO, VDETRECIBOS,RECIBOS
   WHERE RECIBOS.SSEGURO = PSSEGURO
   AND MOVRECIBO.NRECIBO = RECIBOS.NRECIBO
   AND MOVRECIBO.NRECIBO = VDETRECIBOS.NRECIBO
   AND MOVRECIBO.FMOVFIN IS NULL
   AND MOVRECIBO.CESTREC = 0
   AND MOVRECIBO.CESTANT <> 0 ;

   IF PTIPO = 1 THEN
      RETURN NVL(RECPEN,0);
   ELSIF PTIPO = 2 THEN
      RETURN NVL(IMPRECPEN,0);
  ELSE
      --- No se ha informado el tipo
      RETURN -1;
  END IF;

   EXCEPTION
   WHEN OTHERS THEN
    RETURN - 2;

END;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_RECPEN_PP" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_RECPEN_PP" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_RECPEN_PP" TO "PROGRAMADORESCSI";