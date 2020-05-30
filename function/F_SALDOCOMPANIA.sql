--------------------------------------------------------
--  DDL for Function F_SALDOCOMPANIA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_SALDOCOMPANIA" (pccompani in NUMBER, pcempres in NUMBER, pisaldo in out NUMBER)
RETURN NUMBER authid current_user IS
/***********************************************************************
	F_SALDOAGENTE: Obtener el saldo de la cuenta corriente de una compañía.
***********************************************************************/
	err_num 	NUMBER;
BEGIN
	err_num:=0;
	SELECT SUM (iimport*DECODE(cdebhab,1,1,2,-1))
	INTO pisaldo
	FROM ctactescia
	WHERE cestado = 1 AND ccompani = pccompani AND cempres = pcempres;
	pisaldo := NVL(pisaldo, 0);
	return err_num;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
		err_num:=100530;
		return err_num;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_SALDOCOMPANIA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_SALDOCOMPANIA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_SALDOCOMPANIA" TO "PROGRAMADORESCSI";
