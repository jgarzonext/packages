--------------------------------------------------------
--  DDL for Function F_CNVPOLIZA_IN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_CNVPOLIZA_IN" (producte IN NUMBER,
                producte_dos  IN NUMBER,
                poliza IN NUMBER, moneda IN NUMBER)
  RETURN NUMBER IS
/************************************************************
  F_CNVPOLIZA_IN: Devuelve el sseguro de una póliza dado su num. póliza
                  de HOST.
				  Moneda = 2 --> PTS (según tabla DIVISAS)
				  Moneda = 3 --> EUR (según tabla DIVISAS)
				  Devolverá '-1' en caso de ERROR.
*************************************************************/
pcramo NUMBER;
pcmodali NUMBER;
pctipseg NUMBER;
pccolect NUMBER;
psseguro NUMBER;
BEGIN
   SELECT CRAMO,CMODAL,CTIPSEG,CCOLECT
   INTO pcramo,pcmodali,pctipseg,pccolect
   FROM CNVPRODUCTOS
   WHERE PRODUCTE = producte
   AND PRODUCTE_MU = producte_dos
   AND CMONEDA = moneda
   AND poliza BETWEEN NVL(NPOLINI,0) AND NVL(NPOLFIN,poliza + 1);
   SELECT SSEGURO
   INTO psseguro
   FROM CNVPOLIZAS
   WHERE RAM = pcramo
   AND MODA = pcmodali
   AND TIPO = pctipseg
   AND COLE = pccolect
   AND POLISSA_INI = poliza;
   return psseguro;
EXCEPTION
   WHEN OTHERS THEN
      return -1;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_CNVPOLIZA_IN" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_CNVPOLIZA_IN" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_CNVPOLIZA_IN" TO "PROGRAMADORESCSI";
