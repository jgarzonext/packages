--------------------------------------------------------
--  DDL for Function F_TIPO_PRODUCTO_CS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_TIPO_PRODUCTO_CS" ( pcramo IN NUMBER,
				pcmodali IN NUMBER,
				pctipseg IN NUMBER,
				pccolect IN NUMBER,
				ptipoprod OUT VARCHAR2,
				pclase  OUT VARCHAR2)
RETURN NUMBER authid current_user IS
--
--
-- Librería
-- 	 Obtiene el tipo y clase de producto CS en función de los
--                     CRAMO,CMODALI,CTIPSEG y CCOLECT se usa inicialmente en CSV
--                     en la emisión de polizas
BEGIN
	BEGIN
		SELECT tipo_producto, clase
		INTO ptipoprod, pclase
		FROM tipos_producto
		WHERE cramo = pcramo     AND
		      cmodali = pcmodali AND
			  ctipseg = pctipseg AND
			  ccolect = pccolect;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN 101919;
	END;
	RETURN 0;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_TIPO_PRODUCTO_CS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_TIPO_PRODUCTO_CS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_TIPO_PRODUCTO_CS" TO "PROGRAMADORESCSI";
