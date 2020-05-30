--------------------------------------------------------
--  DDL for Function FUSION_REDCOMERCIAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FUSION_REDCOMERCIAL" (cagen_origen IN NUMBER, cagen_desti IN NUMBER)
RETURN NUMBER authid current_user IS
	borrar	number;
	CURSOR c_origen IS
		SELECT cempres,cagente,fmovini,fmovfin,ctipage,cpadre
		FROM REDCOMERCIAL
		WHERE cagente = cagen_origen;
	CURSOR c_destino IS
		SELECT cempres,cagente,fmovini,fmovfin,ctipage,cpadre
		FROM REDCOMERCIAL
		WHERE cagente = cagen_desti;
BEGIN
	FOR orig IN c_origen LOOP
		borrar := 0;
		FOR dest IN c_destino LOOP
			IF dest.cempres = orig.cempres AND
			   dest.fmovini = orig.fmovini THEN
				BEGIN
					borrar:= 1;
					DELETE FROM REDCOMERCIAL
					WHERE cagente = orig.cagente
					AND cempres = orig.cempres
					AND fmovini = orig.fmovini;
				EXCEPTION
					WHEN OTHERS THEN
						RETURN 103870;
				END;
			END IF;
		END LOOP;
		IF borrar = 0 THEN   --lo añadimos en destino
			BEGIN
				UPDATE REDCOMERCIAL SET
				cagente = cagen_desti
				WHERE cagente = cagen_origen
				AND cempres = orig.cempres
				AND fmovini = orig.fmovini;
			EXCEPTION
				WHEN DUP_VAL_ON_INDEX THEN
					RETURN 104559;
				WHEN OTHERS THEN
					RETURN 104558;
			END;
		END IF;
	END LOOP;
	RETURN 0;
END;

 
 

/

  GRANT EXECUTE ON "AXIS"."FUSION_REDCOMERCIAL" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FUSION_REDCOMERCIAL" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FUSION_REDCOMERCIAL" TO "PROGRAMADORESCSI";
