--------------------------------------------------------
--  DDL for Function FUSION_CTACTES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FUSION_CTACTES" (cagen_origen IN NUMBER, cagen_desti IN NUMBER)
RETURN NUMBER authid current_user IS
	borrar		number;
	texto			varchar2(100);
	CURSOR c_origen IS
		SELECT cempres,cagente,nnumlin,cdebhab,cconcta,cestado,ndocume,
			 ffecmov,iimport,tdescrip,cmanual
		FROM CTACTES
		WHERE cagente = cagen_origen;
	CURSOR c_destino IS
		SELECT cempres,cagente,nnumlin,cdebhab,cconcta,cestado,ndocume,
			 ffecmov,iimport,tdescrip,cmanual
		FROM CTACTES
		WHERE cagente = cagen_desti;
BEGIN
	FOR orig IN c_origen LOOP
		FOR dest IN c_destino LOOP
			IF dest.cempres = orig.cempres THEN
				-- El agente destino ya tiene ctacte, por lo tanto,
				-- se devuelve error.
				RETURN 104565;
			END IF;
		END LOOP;
		BEGIN
			UPDATE CTACTES SET
			cagente = cagen_desti
			WHERE cagente = cagen_origen
			AND cempres = orig.cempres;
		EXCEPTION
			WHEN DUP_VAL_ON_INDEX THEN
				RETURN 104565;
			WHEN OTHERS THEN
				RETURN 104564;
		END;
	END LOOP;
	RETURN 0;
END;

 
 

/

  GRANT EXECUTE ON "AXIS"."FUSION_CTACTES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FUSION_CTACTES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FUSION_CTACTES" TO "PROGRAMADORESCSI";
