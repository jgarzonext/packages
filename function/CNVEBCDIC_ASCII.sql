--------------------------------------------------------
--  DDL for Function CNVEBCDIC_ASCII
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."CNVEBCDIC_ASCII" (ebcdic    IN VARCHAR2,
										   escala    IN NUMBER)
	   	  		  RETURN NUMBER IS
xnumero  VARCHAR2(32):=ebcdic;
ultimo   VARCHAR2(1):=SUBSTR(ebcdic, LENGTH(ebcdic), 1);
precision  NUMBER:=LENGTH(ebcdic);
sust     NUMBER;
numero   NUMBER;
negativo NUMBER;
BEGIN

   negativo := 1;

   IF ultimo IN ('}','J','K','L','M','N','O','P','Q','R') THEN
      sust := ascii(ultimo)-73;
	  IF sust > 9 THEN
	     sust := 0;
	  END IF;
      xnumero := substr(ebcdic, 1, precision-1) || TO_CHAR(sust);
   	  negativo := -1;
   ELSIF ultimo IN ('{','A','B','C','D','E','F','G','H','I') THEN
      sust := ascii(ultimo)-64;
	  IF sust > 9 THEN
	     sust := 0;
	  END IF;
      xnumero := substr(ebcdic, 1, precision-1) || TO_CHAR(sust);
   END IF;

   numero := to_number(xnumero)/power(10, escala)*negativo;

   RETURN numero;
END CNVEBCDIC_ASCII;

 
 

/

  GRANT EXECUTE ON "AXIS"."CNVEBCDIC_ASCII" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."CNVEBCDIC_ASCII" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."CNVEBCDIC_ASCII" TO "PROGRAMADORESCSI";
