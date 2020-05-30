--------------------------------------------------------
--  DDL for Function F_FECHVENTA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_FECHVENTA" 
RETURN NUMBER authid current_user IS
/****************************************************************************
	F_FECHVENTA: Graba en MOVSEGURO el mes y el año al cual se imputa la
			 venta
	ALLIBADM
	Se cambia la select de registros a calcular fecha venta, segun
			la fecha de emision
	Cambian los parámetros de f_perventa .
****************************************************************************/
	CURSOR c_movimi IS
		SELECT sseguro, fefecto, nmovimi, cmovseg, cmotmov,
			 fmovimi, femisio
		FROM MOVSEGURO
		WHERE nmesven is null
		AND nanyven is null
		AND fefecto > to_date('31-12-1997','dd/mm/yyyy')
		AND femisio is not null;
	error 		number:= 0;
	pcempres		number;
	num_err		number;
	pfcierremes		date;
	pnanyven		number;
	pnmesven		number;
	registros		number;
	periodo		number;
BEGIN
	-- Seleccionamos los movimientos que no tienen informado el mes y el año de
	-- la venta
	FOR reg IN c_movimi LOOP
		-- Calculamos la fecha de cierre correspondiente al período
		-- al cual pertenece el efecto del seguro
		BEGIN
			SELECT cempres INTO pcempres
			FROM SEGUROS
			WHERE sseguro = reg.sseguro;
		EXCEPTION
			WHEN OTHERS THEN
				error :=100501;
				exit;
		END;
		-- Buscamos la fecha de emisión del movimiento
		-- Como no la tenemos ponemos la fecha del movimiento
		-- Se pone la fecha de emisión del movimiento
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
	IF error = 0 THEN
		commit;
	END IF;
	END LOOP;
	RETURN error;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_FECHVENTA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_FECHVENTA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_FECHVENTA" TO "PROGRAMADORESCSI";
