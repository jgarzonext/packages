--------------------------------------------------------
--  DDL for Function F_TOMADOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_TOMADOR" (psseguro IN NUMBER, pnordtom IN NUMBER,
ptnombre IN OUT VARCHAR2, pcidioma IN OUT NUMBER)
RETURN NUMBER authid current_user IS
/***********************************************************************
	F_TOMADOR : Retorna el nombre y idioma del Tomador de la
		póliza a partir de su número.
	ALLIBCTR - Gestión de datos referentes a los seguros
***********************************************************************/

vcagente number;

BEGIN
    SELECT f_nombre (t.sperson, 1, s.cagente), s.cidioma
        INTO ptnombre, pcidioma
        FROM tomadores t, seguros s
       WHERE t.nordtom = (SELECT MIN(t2.nordtom)
                          from tomadores t2
                          WHERE t2.sseguro = t.sseguro
                            AND t2.nordtom >= pnordtom)
         AND t.sseguro = psseguro
         AND s.sseguro = psseguro;

	RETURN 0;

EXCEPTION
	WHEN no_data_found THEN
		ptnombre := '**';
		RETURN 0;
	WHEN others THEN
        P_TAB_ERROR(F_SYSDATE, F_USER, 'F_TOMADOR', 0, 'ERROR AL BUSCAR TOMADOR SSEGURO:'||PSSEGURO||' NORDTOM:'||PNORDTOM,SQLERRM);
		RETURN 100524;  -- Tomador inexistent
END;

/

  GRANT EXECUTE ON "AXIS"."F_TOMADOR" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_TOMADOR" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_TOMADOR" TO "PROGRAMADORESCSI";
