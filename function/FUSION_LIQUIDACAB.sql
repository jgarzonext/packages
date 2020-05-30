--------------------------------------------------------
--  DDL for Function FUSION_LIQUIDACAB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FUSION_LIQUIDACAB" (cagen_origen IN NUMBER, cagen_desti IN NUMBER)
RETURN NUMBER authid current_user IS
	borrar		number;
	texto			varchar2(100);
	CURSOR c_origen IS
		SELECT cagente,nliqmen,fliquid,fmovimi,fcontab,cempres,sproliq
		FROM LIQUIDACAB
		WHERE cagente = cagen_origen;
	CURSOR c_destino IS
		SELECT cagente,nliqmen,fliquid,fmovimi,fcontab,cempres,sproliq
		FROM LIQUIDACAB
		WHERE cagente = cagen_desti;
BEGIN
	FOR orig IN c_origen LOOP
		FOR dest IN c_destino LOOP
			IF dest.cempres = orig.cempres THEN
				-- El agente destino ya tiene liquidaciones, por lo tanto,
				-- se devuelve error.
				RETURN 104557;
			END IF;
		END LOOP;
		BEGIN
			UPDATE LIQUIDACAB SET
			cagente = cagen_desti
			WHERE cagente = cagen_origen
			AND cempres = orig.cempres;
		EXCEPTION
			WHEN DUP_VAL_ON_INDEX THEN
				RETURN 104557;
			WHEN OTHERS THEN
				RETURN 100528;
		END;
		BEGIN
			UPDATE LIQUIDALIN SET
			cagente = cagen_desti
			WHERE cagente = cagen_origen
			AND cempres = orig.cempres
			AND nliqmen = orig.nliqmen;
		EXCEPTION
			WHEN DUP_VAL_ON_INDEX THEN
				RETURN 104561;
			WHEN OTHERS THEN
				RETURN 100560;
		END;
	END LOOP;
	RETURN 0;
END;

 
 

/

  GRANT EXECUTE ON "AXIS"."FUSION_LIQUIDACAB" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FUSION_LIQUIDACAB" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FUSION_LIQUIDACAB" TO "PROGRAMADORESCSI";
