--------------------------------------------------------
--  DDL for Function F_PERRECIBO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_PERRECIBO" (pcempres IN NUMBER, pfmovimi IN DATE,
		     pfmovdia IN DATE)
RETURN NUMBER authid current_user IS
--
-- Funció per calcular el periode comptable al que pertany un rebut
--
error    number :=0;
pfcierremes   date;
pfcierreanual date;
begin
  error := f_fechcierre(pcempres, pfmovimi, pfcierremes);
  error := f_fechcierre(pcempres,to_date('0212'||to_char(pfmovimi,'yyyy'),'ddmmyyyy'),pfcierreanual);
  IF (pfcierremes is null OR to_date(to_char(pfmovdia,'ddmmyyyy')||'000000','ddmmyyyyhh24miss')
	<= to_date(to_char(pfcierremes,'ddmmyyyy')||'000000','ddmmyyyyhh24miss')) THEN
    RETURN TO_NUMBER(TO_CHAR(pfmovimi,'YYYYMM'));
  ELSE
    IF pfcierreanual IS NOT NULL THEN
      IF (to_date(to_char(pfmovdia,'ddmmyyyy')||'000000','ddmmyyyyhh24miss')
	<= to_date(to_char(pfcierreanual,'ddmmyyyy')||'000000','ddmmyyyyhh24miss')
         AND to_char(pfmovdia,'yyyy') <> to_char(pfmovimi,'yyyy')) THEN
           RETURN TO_NUMBER(TO_CHAR(pfmovimi,'YYYY')||'12');
      END IF;
    END IF;
    RETURN TO_NUMBER(TO_CHAR(pfmovdia,'YYYYMM'));
  END IF;
end;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_PERRECIBO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_PERRECIBO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_PERRECIBO" TO "PROGRAMADORESCSI";
