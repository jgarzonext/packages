--------------------------------------------------------
--  DDL for Function F_DESCPROFES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_DESCPROFES" (
         PCPROFES  IN     VARCHAR2,
         PCIDIOMA  IN     NUMBER,
         PLONGITUD IN     NUMBER DEFAULT 100,
	 PTPROFES  IN OUT VARCHAR2
)
RETURN NUMBER authid current_user IS
/***********************************************************************
 Descripción de una profesión


		Faltan los números de error
***********************************************************************/
BEGIN
	IF plongitud < 1 THEN
		ptprofes := '***';
		RETURN 100000;
	END IF;
--
        IF pcprofes is null THEN
		ptprofes := '';
		RETURN 0;
        END IF;
--
	SELECT substr(tprofes,1,plongitud)
	INTO   ptprofes
	FROM   PROFESIONES
	WHERE  cprofes = pcprofes
          AND  cidioma = pcidioma;
--
	RETURN 0;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
		ptprofes := '**';
		RETURN 100001;
	WHEN OTHERS THEN
		ptprofes := '***';
		RETURN 100002;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_DESCPROFES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_DESCPROFES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_DESCPROFES" TO "PROGRAMADORESCSI";
