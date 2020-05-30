--------------------------------------------------------
--  DDL for Function F_RECPRIMA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_RECPRIMA" (psseguro IN NUMBER, pfecini IN DATE, pfecfin IN DATE)
RETURN NUMBER authid current_user IS
/***********************************************************************
	F_RECPRIMA: Calcula la prima de una póliza partiendo de sus recibos.
	ALLIBCTR
***********************************************************************/
	pipseg	NUMBER;
BEGIN
	SELECT sum(decode(ctiprec,8,0-v.itotpri,9,0-v.itotpri,v.itotpri))
        INTO pipseg
        FROM  VDETRECIBOS v, RECIBOS r, movrecibo m
        WHERE v.nrecibo = r.nrecibo
	AND v.nrecibo = m.nrecibo
        AND r.fefecto < pfecfin
        AND r.fefecto >= pfecini
        AND r.sseguro = psseguro
        AND pfecfin >= m.fmovini
        AND pfecfin <= NVL(m.fmovfin,pfecfin + 2)
        AND CESTREC <> 2;
        RETURN pipseg;
EXCEPTION
	WHEN others THEN
		RETURN 0;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_RECPRIMA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_RECPRIMA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_RECPRIMA" TO "PROGRAMADORESCSI";
