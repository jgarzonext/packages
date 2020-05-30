--------------------------------------------------------
--  DDL for Function FRENTACOBRA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FRENTACOBRA" (nsesion  IN NUMBER,
                                        pseguro  IN NUMBER,
                                        pfecha   IN NUMBER)
  RETURN NUMBER authid current_user IS
/******************************************************************************
   NOMBRE:
   DESCRIPCION:  Importe de las Rentas cobradas de un seguro hasta una fecha.

   PARAMETROS:
   INPUT: NSESION(number) --> Nro. de sesión del evaluador de fórmulas
          PSEGURO(number) --> secuencia del seguro que se está consultando
		  PFECHA(number)  --> Fecha de consulta.
   RETORNA VALUE:
          NUMBER------------> Retorna el total de Aportaciones realizadas
******************************************************************************/
valor     NUMBER;
xprimas	  NUMBER;
xprimaMue NUMBER;
xsperson  NUMBER;
xfecha    DATE;
xffecmue  DATE;
BEGIN
   valor := NULL;
   xfecha:= TO_DATE(pfecha,'yyyymmdd');
   BEGIN
     SELECT ffecmue, sperson INTO xffecmue,xsperson
	   FROM asegurados
	  WHERE sseguro = pseguro
	    AND ffecmue IS NOT NULL;
   EXCEPTION
     WHEN OTHERS THEN
	      xffecmue := TO_DATE('01011950','ddmmyyyy');
   END;
-- Averigüo las Rentas pagadas a partir de la muerte
   BEGIN
     SELECT SUM(isinret - ibase)
       INTO xprimaMue
       FROM PAGOSRENTA PR, MOVPAGREN MV
      WHERE pr.sseguro = pseguro
        AND pr.ffecpag BETWEEN xffecmue AND  xfecha
	    AND pr.srecren = mv.srecren
	    AND mv.cestrec = 1
	    AND (pr.iretenc > 0 AND pr.ibase > 0)
		AND mv.fmovfin IS NULL;
    EXCEPTION
	  WHEN OTHERS THEN
	       XprimaMue := 0;
    END;
	-- Averiguo las rentas pagadas antes de la muerte hasta la muerte
	IF XSPERSON IS NOT NULL THEN
	   BEGIN
        SELECT SUM(isinret - ibase)
          INTO xprimas
          FROM PAGOSRENTA PR, MOVPAGREN MV
         WHERE pr.sseguro = pseguro
           AND pr.ffecpag BETWEEN TO_DATE('01011950','ddmmyyyy') AND  xffecmue
	       AND pr.srecren = mv.srecren
		   AND sperson <> xsperson
	       AND mv.cestrec = 1
	       AND (pr.iretenc > 0 AND pr.ibase > 0)
		   AND mv.fmovfin IS NULL;
       EXCEPTION
	     WHEN OTHERS THEN
	        XPRIMAS := 0;
       END;
     END IF;
	 --
	 RETURN XPRIMAS + xprimaMue;
	 --
EXCEPTION
  WHEN NO_DATA_FOUND THEN RETURN NULL;
  WHEN OTHERS THEN RETURN NULL;
END Frentacobra;
 
 

/

  GRANT EXECUTE ON "AXIS"."FRENTACOBRA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FRENTACOBRA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FRENTACOBRA" TO "PROGRAMADORESCSI";
