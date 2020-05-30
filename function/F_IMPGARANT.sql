--------------------------------------------------------
--  DDL for Function F_IMPGARANT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_IMPGARANT" (
   recibo IN NUMBER,
   concepto IN VARCHAR2,
   garantia IN NUMBER,
   riesgo IN NUMBER DEFAULT NULL)
   RETURN NUMBER AUTHID CURRENT_USER IS
   importe        NUMBER;
   simporte       NUMBER;
   nconcepto      NUMBER;

   TYPE conc IS TABLE OF NUMBER
      INDEX BY BINARY_INTEGER;

   TYPE signo IS TABLE OF NUMBER
      INDEX BY BINARY_INTEGER;

   tconc          conc;
   tsigno         signo;
BEGIN
   tsigno.DELETE;
   tconc.DELETE;

   IF concepto = 'PRIMA TOTAL' THEN
      tconc(1) := 0;
      tsigno(1) := 1;
      tconc(2) := 1;
      tsigno(2) := 1;
      tconc(3) := 8;
      tsigno(3) := 1;
      tconc(4) := 2;
      tsigno(4) := 1;
      tconc(5) := 3;
      tsigno(5) := 1;
      tconc(6) := 4;
      tsigno(6) := 1;
      tconc(7) := 6;
      tsigno(7) := 1;
      tconc(8) := 7;
      tsigno(8) := 1;
      tconc(9) := 14;
      tsigno(9) := 1;
      tconc(10) := 5;
      tsigno(10) := 1;
   ELSIF concepto = 'PRIMA TARIFA' THEN
      tconc(1) := 0;
      tsigno(1) := 1;
      tconc(2) := 1;
      tsigno(2) := 1;
   ELSIF concepto = 'REC FPAGO' THEN
      tconc(1) := 8;
      tsigno(1) := 1;
   ELSIF concepto = 'CONSORCIO' THEN
      tconc(1) := 2;
      tsigno(1) := 1;
      tconc(2) := 3;
      tsigno(2) := 1;
   ELSIF concepto = 'IMPUESTO' THEN
      tconc(1) := 4;
      tsigno(1) := 1;
      tconc(2) := 6;
      tsigno(2) := 1;
      tconc(3) := 7;
      tsigno(3) := 1;
      tconc(4) := 14;
      tsigno(4) := 1;
   ELSIF concepto = 'CLEA' THEN
      tconc(1) := 5;
      tsigno(1) := 1;
   ELSIF concepto = 'COMISION' THEN
      tconc(1) := 11;
      tsigno(1) := 1;
      --bug 30303 - No se están contabilizando las comisiones indirectas (AGM)
      tconc(2) := 17;
      tsigno(2) := 1;
   /*ELSIF concepto = 'COMISION IND' THEN
      tconc(1) := 17;
      tsigno(1) := 1;*/
   ELSIF concepto = 'IRPF' THEN
      tconc(1) := 12;
      tsigno(1) := 1;
   ELSIF concepto = 'LIQUIDO' THEN
      tconc(1) := 0;
      tsigno(1) := 1;
      tconc(2) := 1;
      tsigno(2) := 1;
      tconc(3) := 8;
      tsigno(3) := 1;
      tconc(4) := 2;
      tsigno(4) := -1;
      tconc(5) := 3;
      tsigno(5) := -1;
      tconc(6) := 4;
      tsigno(6) := -1;
      tconc(7) := 6;
      tsigno(7) := -1;
      tconc(8) := 7;
      tsigno(8) := -1;
      tconc(9) := 14;
      tsigno(9) := -1;
      tconc(10) := 5;
      tsigno(10) := -1;
      tconc(11) := 11;
      tsigno(11) := -1;
      tconc(12) := 12;
      tsigno(12) := -1;
   ELSIF concepto = 'DEVENGADA' THEN
      tconc(1) := 21;
      tsigno(1) := 1;
   ELSIF concepto = 'COMDEVEN' THEN
      tconc(1) := 15;
      tsigno(1) := 1;
   ELSIF concepto = 'COMISION CIA' THEN
      tconc(1) := 30;
      tsigno(1) := 1;
   ELSIF concepto = 'LIQUIDO_COMISIONES' THEN
      tconc(1) := 0;
      tsigno(1) := 1;
      tconc(2) := 1;
      tsigno(2) := 1;
      tconc(3) := 2;
      tsigno(3) := 1;
      tconc(4) := 3;
      tsigno(4) := 1;
      tconc(5) := 4;
      tsigno(5) := 1;
      tconc(6) := 5;
      tsigno(6) := 1;
      tconc(7) := 6;
      tsigno(7) := 1;
      tconc(8) := 7;
      tsigno(8) := 1;
      tconc(9) := 8;
      tsigno(9) := 1;
      tconc(10) := 14;
      tsigno(10) := 1;
      tconc(11) := 26;
      tsigno(11) := 1;
      tconc(12) := 86;
      tsigno(12) := 1;
      tconc(13) := 11;
      tsigno(13) := -1;
      tconc(14) := 12;
      tsigno(14) := -1;
      tconc(15) := 13;
      tsigno(15) := -1;
   ELSE
      tconc(1) := -1;
      tsigno(1) := 1;
   END IF;

   simporte := 0;

   FOR i IN 1 .. tconc.COUNT LOOP
      BEGIN
         SELECT NVL(SUM(NVL(iconcep_monpol, iconcep) * tsigno(i)), 0)
           INTO importe
           FROM detrecibos
          WHERE nrecibo = recibo
            AND cconcep = tconc(i)
            AND cgarant = garantia
            AND NVL(nriesgo, -1) = NVL(NVL(riesgo, nriesgo), -1);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            importe := 0;
      END;

      simporte := simporte + ROUND(importe, 2);
   END LOOP;

   RETURN simporte;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN 0;
   WHEN OTHERS THEN
      RETURN NULL;
END f_impgarant;

/

  GRANT EXECUTE ON "AXIS"."F_IMPGARANT" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_IMPGARANT" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_IMPGARANT" TO "PROGRAMADORESCSI";
