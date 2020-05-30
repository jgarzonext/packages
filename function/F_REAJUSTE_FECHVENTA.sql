--------------------------------------------------------
--  DDL for Function F_REAJUSTE_FECHVENTA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_REAJUSTE_FECHVENTA" (pfechini IN DATE, pfechfin IN DATE,
					pfcierremes IN DATE, pcempres IN NUMBER,
					pmodo IN VARCHAR2)
RETURN NUMBER authid current_user IS
/****************************************************************************
	F_REAJUSTE_FECHVENTA: Graba en MOVSEGURO el mes y el año al cual se imputa la
			 venta
			- Si pmodo = 'I' (insertar), 'M' (modificar), 'B' (borrar)
	ALLIBADM
****************************************************************************/
	mesvenini	number;
	anyvenini	number;
	mesvenfin	number;
	anyvenfin	number;
	CURSOR c_movimi_insert IS
		SELECT movseguro.sseguro, movseguro.fefecto, movseguro.nmovimi,
			 cmovseg, cmotmov,movseguro.fmovimi,movseguro.femisio
		FROM MOVSEGURO,SEGUROS
		WHERE seguros.cempres = pcempres
		AND movseguro.sseguro = seguros.sseguro
		AND movseguro.femisio >= to_date(to_char(pfcierremes,'yyyymmdd')||'000000','yyyymmddhh24miss')
		AND movseguro.nmesven >= DECODE(movseguro.nanyven,anyvenini,mesvenini,1)
		AND movseguro.nanyven >= anyvenini;
	CURSOR c_movimi_modif IS
		SELECT movseguro.sseguro, movseguro.fefecto, movseguro.nmovimi,
			 cmovseg, cmotmov,movseguro.fmovimi,movseguro.femisio
		FROM MOVSEGURO,SEGUROS
		WHERE seguros.cempres = pcempres
		AND movseguro.sseguro = seguros.sseguro
		AND movseguro.nmesven >= DECODE(movseguro.nanyven,anyvenini,mesvenini,1)
		AND movseguro.nanyven >= anyvenini;
	error 		number:= 0;
	num_err		number;
	pnanyven		number;
	pnmesven		number;
	registros		number;
	periodo		number;
BEGIN
	mesvenini := to_char(pfechini,'mm');
	anyvenini := to_char(pfechini,'yyyy');
	mesvenfin := to_char(pfechfin,'mm');
	anyvenfin := to_char(pfechfin,'yyyy');
	IF mesvenini <> mesvenfin OR anyvenini <> anyvenfin THEN
		RETURN 101901;  -- Paso incorrecto de parámetros a la función
	END IF;
	-- Seleccionamos los movimientos que no tienen informado el mes y el año de
	-- la venta
	IF pmodo = 'I' THEN
		FOR reg IN c_movimi_insert LOOP
			periodo := f_perventa(reg.cmovseg,trunc(reg.femisio),trunc(reg.fefecto),pcempres);
			pnanyven := ROUND(periodo/100,0);
			pnmesven := periodo - ROUND(periodo/100,0)*100;
			-- Grabamos el mes y el año en el registro de MOVSEGURO
			BEGIN
				UPDATE MOVSEGURO SET
				nmesven = pnmesven,
				nanyven = pnanyven
				WHERE sseguro = reg.sseguro
				AND nmovimi = reg.nmovimi;
			EXCEPTION
				WHEN OTHERS THEN
					error := 105235;
					exit;
			END;
		END LOOP;
	ELSIF pmodo = 'M' OR pmodo = 'B' THEN
		FOR reg IN c_movimi_modif LOOP
			periodo := f_perventa(reg.cmovseg,trunc(reg.femisio),trunc(reg.fefecto),pcempres);
			pnanyven := ROUND(periodo/100,0);
			pnmesven := periodo - ROUND(periodo/100,0)*100;
			-- Grabamos el mes y el año en el registro de MOVSEGURO
			BEGIN
				UPDATE MOVSEGURO SET
				nmesven = pnmesven,
				nanyven = pnanyven
				WHERE sseguro = reg.sseguro
				AND nmovimi = reg.nmovimi;
			EXCEPTION
				WHEN OTHERS THEN
					error := 105235;
					exit;
			END;
		END LOOP;
	END IF;
	RETURN error;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_REAJUSTE_FECHVENTA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_REAJUSTE_FECHVENTA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_REAJUSTE_FECHVENTA" TO "PROGRAMADORESCSI";
