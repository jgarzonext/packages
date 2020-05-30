--------------------------------------------------------
--  DDL for Function F_FUSIONAGENTES_NUEVO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_FUSIONAGENTES_NUEVO" (cagent_origen IN NUMBER, cagent_desti IN NUMBER)
RETURN NUMBER AUTHID current_user IS
BEGIN
	-- Insertamos en AGENTES un registro con los mismos datos que
	-- el agente origen
	BEGIN
		INSERT INTO AGENTES
		(cagente,cretenc,ctipiva,sperson,ccomisi,ctipage,cactivo,cdomici,
		cbancar,ncolegi,fbajage,csoprec)
		(SELECT cagent_desti cagente,cretenc,ctipiva,sperson,ccomisi,ctipage,
		cactivo,cdomici,cbancar,ncolegi,fbajage,csoprec
		FROM AGENTES
		WHERE cagente = cagent_origen);
	EXCEPTION
		WHEN DUP_VAL_ON_INDEX THEN
			RETURN 104555;  --Registros duplicados
		WHEN OTHERS THEN
			RETURN 104554;  --Error al insertar
	END;
	--Insertamos en CONTRATOSAGE los registros con los mismos datos que
	--el agente origen.
	BEGIN
		INSERT INTO CONTRATOSAGE
		(cempres,cagente,ncontrato,ffircon)
		(SELECT cempres,cagent_desti cagente,ncontrato,ffircon
		FROM CONTRATOSAGE
		WHERE cagente = cagent_origen);
	EXCEPTION
		WHEN DUP_VAL_ON_INDEX THEN
			RETURN 104556;  --Registros duplicados
		WHEN OTHERS THEN
			RETURN 103027;  --Error al insertar
	END;
	--Insertamos en LIQUIDACAB los registros con los mismos datos que
	--el agente origen.
	BEGIN
		INSERT INTO LIQUIDACAB
		(cagente,nliqmen,fliquid,fmovimi,fcontab,cempres,sproliq)
		(SELECT cagent_desti cagente,nliqmen,fliquid,fmovimi,fcontab,
		 cempres,sproliq
		FROM LIQUIDACAB
		WHERE cagente = cagent_origen);
	EXCEPTION
		WHEN DUP_VAL_ON_INDEX THEN   --Registros duplicados
			RETURN 104557;
		WHEN OTHERS THEN
			RETURN 100528;  --Error al insertar
	END;
	-- Modificamos todas las tablas en las que aparece el agente origen
	-- con el agente destino
	BEGIN
		UPDATE REDCOMERCIAL SET
		cagente = cagent_desti
		WHERE cagente = cagent_origen;
	EXCEPTION
		WHEN DUP_VAL_ON_INDEX THEN
			RETURN 104559;   --Registros duplicados
		WHEN OTHERS THEN
			RETURN 104558;   --Error al modificar
	END;
	BEGIN
		UPDATE LIQUIDALIN SET
		cagente = cagent_desti
		WHERE cagente = cagent_origen;
	EXCEPTION
		WHEN DUP_VAL_ON_INDEX THEN
			RETURN 104561;   --Registros duplicados
		WHEN OTHERS THEN
			RETURN 104560;  --Error al modificar
	END;
	BEGIN
		UPDATE COBBANCARIOSEL SET
		cagente = cagent_desti
		WHERE cagente = cagent_origen;
	EXCEPTION
		WHEN DUP_VAL_ON_INDEX THEN   --Registros duplicados
			RETURN 104563;
		WHEN OTHERS THEN
			RETURN 104562;  --Error al modificar
	END;
	BEGIN
		UPDATE CTACTES SET
		cagente = cagent_desti
		WHERE cagente = cagent_origen;
	EXCEPTION
		WHEN DUP_VAL_ON_INDEX THEN  --Registros duplicados
			RETURN 104565;
		WHEN OTHERS THEN
			RETURN 104564;  --Error al modificar
	END;
	BEGIN
		UPDATE ESTSEGUROS SET
		cagente = cagent_desti
		WHERE cagente = cagent_origen;
	EXCEPTION
		WHEN DUP_VAL_ON_INDEX THEN
			RETURN 104567;  --Registros duplicados
		WHEN OTHERS THEN
			RETURN 104566;  --Error al modificar
	END;
	BEGIN
		UPDATE RECIBOS SET
		cagente = cagent_desti
		WHERE cagente = cagent_origen;
	EXCEPTION
		WHEN DUP_VAL_ON_INDEX THEN
			RETURN 104568;  --Registros duplicados
		WHEN OTHERS THEN
			RETURN 102358;  --Error al modificar
	END;
	BEGIN
		UPDATE RECIBOSCAR SET
		cagente = cagent_desti
		WHERE cagente = cagent_origen;
	EXCEPTION
		WHEN DUP_VAL_ON_INDEX THEN
			RETURN 104569;  --Registros duplicados
		WHEN OTHERS THEN
			RETURN 102520;  --Error al modificar
	END;
	BEGIN
		UPDATE RECIBOSREDCOM SET
		cagente = cagent_desti
		WHERE cagente = cagent_origen;
	EXCEPTION
		WHEN DUP_VAL_ON_INDEX THEN  --Registros duplicados
			RETURN 104571;
		WHEN OTHERS THEN
			RETURN 103910;  --Error al modificar
	END;
	BEGIN
		UPDATE SEGUROS SET
		cagente = cagent_desti
		WHERE cagente = cagent_origen;
	EXCEPTION
		WHEN DUP_VAL_ON_INDEX THEN  --Registros duplicados
			RETURN 104570;
		WHEN OTHERS THEN
			RETURN 102361;  --Error al modificar
	END;
	BEGIN
		UPDATE TRASPACAR SET
		cageini = cagent_desti
		WHERE cageini = cagent_origen;
	EXCEPTION
		WHEN DUP_VAL_ON_INDEX THEN  --Registros duplicados
			RETURN 104573;
		WHEN OTHERS THEN
			RETURN 104572;  --Error al modificar
	END;
	BEGIN
		UPDATE TRASPACAR SET
		cagefin = cagent_desti
		WHERE cagefin = cagent_origen;
	EXCEPTION
		WHEN DUP_VAL_ON_INDEX THEN  --Registros duplicados
			RETURN 104573;
		WHEN OTHERS THEN
			RETURN 104572;  --Error al modificar
	END;

	--Modificamos tambien las tablas HISTORICOSEGUROS y SEGUREDCOM
	BEGIN
		UPDATE historicoseguros SET
		cagente = cagent_desti
		WHERE cagente = cagent_origen;
	EXCEPTION
		 WHEN DUP_VAL_ON_INDEX THEN --Registros duplicados
		 	  RETURN 104573;
	     WHEN OTHERS THEN
		     RETURN 104572;
	END;

	BEGIN
	    UPDATE seguredcom SET
		cageseg = cagent_desti
		WHERE cageseg = cagent_origen;
	EXCEPTION
		WHEN DUP_VAL_ON_INDEX THEN --Registros duplicados
		     RETURN 104573;
		WHEN OTHERS THEN
		     RETURN 104572;
	 END;


	BEGIN
	    UPDATE segurosredcom SET
		cagente = cagent_desti
		WHERE cagente = cagent_origen;
	EXCEPTION
		WHEN DUP_VAL_ON_INDEX THEN --Registros duplicados
		     RETURN 104573;
		WHEN OTHERS THEN
		     RETURN 104572;
	 END;


	--Borramos de AGENTE, CONTRATOSAGE, LIQUIDACAB los registros con
	--el cgente del origen
	BEGIN
		DELETE FROM LIQUIDACAB
		WHERE cagente = cagent_origen;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN 104576; -- Error al borrar
	END;
	BEGIN
		DELETE FROM CONTRATOSAGE
		WHERE cagente = cagent_origen;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN 104575;  -- Error al borrar
	END;

	--SN se elimina  la tabla PRODNETASALDO
	BEGIN
	   DELETE prodnetasaldo
		WHERE cagente = cagent_origen;
	EXCEPTION
		WHEN DUP_VAL_ON_INDEX THEN
			 dbms_output.put_line('prodneta : ' || SQLERRM);
			RETURN 100001;
		WHEN OTHERS THEN
			RETURN 100002;
	END;

--Realizamos el borrado de la talba TF_OFICINAS que se utiliza en el TERMINAL
   DELETE TF_OFICINAS
   WHERE cagente = cagent_origen;

--   DELETE SEGUROSREDCOM
--   WHERE cagente = cagent_origen;

	BEGIN
		DELETE FROM AGENTES
		WHERE cagente = cagent_origen;
	EXCEPTION
		WHEN OTHERS THEN
			 dbms_output.put_line('error : ' || SQLERRM);
			RETURN 104574;  -- Error al borrar
	END;
	RETURN 0;
END;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_FUSIONAGENTES_NUEVO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_FUSIONAGENTES_NUEVO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_FUSIONAGENTES_NUEVO" TO "PROGRAMADORESCSI";
