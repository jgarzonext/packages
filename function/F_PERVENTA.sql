--------------------------------------------------------
--  DDL for Function F_PERVENTA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_PERVENTA" (pctipo IN number,pfemisio IN DATE, pfefecto IN DATE,pcempres IN NUMBER)
RETURN NUMBER authid current_user IS
/****************************************************************************
	F_PERVENTA: Calcula la fecha a la cual se imputa la venta, según
			las fechas de efecto, de emisión y de cierre del
			período
	ALLIBADM.
	- En las anulaciones, tabién depende de la fecha de emision,
			 no se pone directamente la fecha de efecto
	- Si el efecto es de un periodo cerrado, se imputa la venta
			al último periodo sin cerrar.
****************************************************************************/
	periodo		number;
	pfcierremes	date;
	fper_sincerrar	date;
BEGIN
  BEGIN
	SELECT fcierre
	INTO pfcierremes
	FROM CIERRES
	WHERE fperini <= pfefecto
	  AND fperfin >= pfefecto
          AND ctipo = 1
	  AND cempres = pcempres;
  EXCEPTION
	WHEN NO_DATA_FOUND THEN
		pfcierremes := null;
  END;
  IF (trunc(pfemisio) <= trunc(pfcierremes) OR pfcierremes is null) THEN
	periodo := TO_NUMBER(TO_CHAR(pfefecto,'YYYYMM'));
  ELSE
    SELECT nvl(max(fperfin)+ 1,pfemisio)
    INTO fper_sincerrar
    FROM CIERRES
    WHERE cempres = pcempres
    AND ctipo   = 1;
    BEGIN
	SELECT nvl(min(to_char(a.fperfin,'yyyymm')),to_char(fper_sincerrar,'yyyymm'))
	INTO periodo
	FROM cierres a
	WHERE a.cempres = pcempres
	  AND a.fcierre = (SELECT  min(fcierre)
		   FROM cierres b
		   WHERE b.fcierre >= trunc(pfemisio)
		     AND b.cempres = pcempres
                     AND ctipo = 1)
                     AND to_char(a.fperfin,'yyyymm') >= to_char(pfefecto,'yyyymm')
                     AND ctipo = 1;
    EXCEPTION
	WHEN OTHERS THEN
		null;
    END;
  END IF;
  RETURN periodo;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_PERVENTA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_PERVENTA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_PERVENTA" TO "PROGRAMADORESCSI";
