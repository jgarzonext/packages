--------------------------------------------------------
--  DDL for Function F_CAGENTE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_CAGENTE" (psseguro IN NUMBER, pnmovimi IN NUMBER DEFAULT NULL, pfecha IN DATE DEFAULT NULL) RETURN NUMBER IS
/***************************************************************************************
    Devuelve la oficina que tenia el seguro en ese movimiento

******************************************************************************************/
  v_cagente NUMBER;
BEGIN

 IF PNMOVIMI IS NOT NULL THEN
	 BEGIN
      SELECT cagente
      INTO v_cagente
      FROM historicoseguros
      WHERE sseguro =  psseguro
      AND nmovimi = pnmovimi;

      RETURN v_cagente;
	 EXCEPTION
	 	  WHEN NO_DATA_FOUND THEN
	 	     SELECT cagente
	 	     INTO v_cagente
         FROM seguros
         WHERE sseguro =  psseguro;

         RETURN v_cagente;
	 END;

 ELSIF PFECHA IS NOT NULL THEN
		 SELECT CAGESEG INTO v_cagente FROM seguredcom WHERE SSEGURO = psseguro
		AND TRUNC(FMOVINI) <= TRUNC(pfecha)
		 AND ( TRUNC(FMOVFIN) > TRUNC(pfecha) OR TRUNC(FMOVFIN) IS NULL ) ;

		 RETURN v_cagente;

END IF;
EXCEPTION
   WHEN OTHERS THEN
      RETURN NULL;
END;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_CAGENTE" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_CAGENTE" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_CAGENTE" TO "PROGRAMADORESCSI";
