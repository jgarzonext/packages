--------------------------------------------------------
--  DDL for Function F_ROUND_FORPAG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_ROUND_FORPAG" (import IN NUMBER, pforpag IN NUMBER,
moneda IN NUMBER DEFAULT NULL, psproduc IN NUMBER)
RETURN NUMBER authid current_user IS
/***********************************************************************
	F_ROUND_FORPAG: Redondeamos el importe pasado según la forma de
		pago.
	ALLIBMFM
	- Se controla la forma de pago única
	- Se incluye el producto: si es de ahorro, no tene
***********************************************************************/
	aux_imp  NUMBER;
	forpag   NUMBER;
    lmoneda  NUMBER;
BEGIN

    lmoneda := NVL(moneda, F_PARINSTALACION_N('MONEDAINST'));

    if nvl(f_parproductos_v(psproduc, 'REDONDEOFP_12'),0) = 3  THEN --JRH IMP No redondeamos
	   return import;
	end if;

	IF pforpag = 0 THEN
		forpag := 1;
	ELSE
		forpag := pforpag;
	END IF;
	if nvl(f_parproductos_v(psproduc, 'REDONDEOFP_12'),0) = 1 and pforpag <> 0 THEN
	   forpag := 12;
	end if;

	aux_imp := f_round( (import / forpag), lmoneda);
	RETURN (aux_imp * forpag);
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_ROUND_FORPAG" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_ROUND_FORPAG" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_ROUND_FORPAG" TO "PROGRAMADORESCSI";
