--------------------------------------------------------
--  DDL for Function F_SALDOAGENTE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_SALDOAGENTE" (pcagente in NUMBER, pcempres in NUMBER, pisaldo in
								out NUMBER)
RETURN NUMBER authid current_user IS
/***********************************************************************
	F_SALDOAGENTE: Obtener el saldo de la cuenta corriente de un agente
	ALLIBADM - Sección correspondiente al módulo de recibos
	Modificació: Modificación del where del select.
	Modificació: S'ha afegit el cempres com a paràmetre de la funció.
***********************************************************************/
	err_num 	NUMBER:=0;
BEGIN
   SELECT SUM (iimport*DECODE(cdebhab,1,1,2,-1))
   INTO pisaldo
   FROM ctactes
   WHERE cestado = 1 AND cagente = pcagente AND cempres = pcempres;

   pisaldo := NVL(pisaldo, 0);

   return err_num;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      err_num:=100530;
      return err_num;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_SALDOAGENTE" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_SALDOAGENTE" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_SALDOAGENTE" TO "PROGRAMADORESCSI";
