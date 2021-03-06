--------------------------------------------------------
--  DDL for Function F_SOLINSRECIBO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_SOLINSRECIBO" (PSSOLICIT IN NUMBER, PNRECIBO IN NUMBER, PSPROCES IN NUMBER) RETURN
         NUMBER authid current_user IS
/****************************************************************************
****************************************************************************/
 XCEMPRES	NUMBER;
 XCAGENTE   NUMBER;
BEGIN
  BEGIN
    SELECT CEMPRES, CAGENTE
      INTO XCEMPRES, XCAGENTE
      FROM SOLSEGUROS S, CODIRAM C
     WHERE S.CRAMO    = C.CRAMO
       AND S.SSOLICIT = PSSOLICIT;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
	 RETURN 101903;		-- ASSEGURAN�A NO TROBADA A SEGUROS
     WHEN OTHERS THEN
	 RETURN 101919;		-- ERROR AL LLEGIR DE SEGUROS
   END;
   IF PNRECIBO IS NOT NULL AND PNRECIBO <> 0 AND
      PSPROCES IS NOT NULL AND PSPROCES <> 0 THEN
     BEGIN
       INSERT INTO RECIBOSCAR
               (SPROCES, NRECIBO, SSEGURO, CAGENTE, FEMISIO, FEFECTO, FVENCIM,
         	CTIPREC, CESTAUX, NANUALI, NFRACCI, CCOBBAN, CESTIMP, CEMPRES,
                CDELEGA, NRIESGO, NCUACOA, CTIPCOA,CESTSOP)
            VALUES
               (PSPROCES, PNRECIBO, PSSOLICIT, XCAGENTE, F_SYSDATE, F_SYSDATE,
                F_SYSDATE, 0, NULL, NULL, NULL, NULL, NULL, XCEMPRES, NULL,
                NULL, NULL, NULL, NULL);
     EXCEPTION
       WHEN DUP_VAL_ON_INDEX THEN
         RETURN 103355;		-- REGISTRE DUPLICAT A RECIBOSCAR
       WHEN OTHERS THEN
         RETURN 103848;		-- ERROR A L' INSERIR A RECIBOSCAR
     END;
     RETURN 0;
   ELSE
     RETURN 101901;		-- PAS INCORRECTE DE PAR�METRES A LA FUNCI�
   END IF;
END;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_SOLINSRECIBO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_SOLINSRECIBO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_SOLINSRECIBO" TO "PROGRAMADORESCSI";
