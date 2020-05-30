--------------------------------------------------------
--  DDL for Function CNVEBCDIC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."CNVEBCDIC" (n NUMBER, d NUMBER, l NUMBER)
	   	  		  RETURN varchar2 IS
v VARCHAR2(18);
m NUMBER;
ud NUMBER;
type lets is table of varchar2(1) index by binary_integer;
letra lets;
BEGIN
   letra(1) := '}';
   letra(2) := 'J';
   letra(3) := 'K';
   letra(4) := 'L';
   letra(5) := 'M';
   letra(6) := 'N';
   letra(7) := 'O';
   letra(8) := 'P';
   letra(9) := 'Q';
   letra(10) := 'R';
   m := trunc(n * power(10, d));
   v := substr(to_char(m, '099999999999999999'),2,18);
   IF n < 0 THEN
      ud := TO_NUMBER(substr(v,18,1))+1;
      v := substr(v,1,17)||letra(ud);
   END IF;

   RETURN SUBSTR(v,18-l+1, l);

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       RETURN Null;
     WHEN OTHERS THEN
       RETURN Null;
END CNVEBCDIC;

 
 

/

  GRANT EXECUTE ON "AXIS"."CNVEBCDIC" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."CNVEBCDIC" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."CNVEBCDIC" TO "PROGRAMADORESCSI";
