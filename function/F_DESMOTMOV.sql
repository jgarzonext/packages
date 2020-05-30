--------------------------------------------------------
--  DDL for Function F_DESMOTMOV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_DESMOTMOV" (pcmotmov IN NUMBER, pcidioma IN NUMBER,
ptmotmov IN OUT VARCHAR2)
RETURN NUMBER authid current_user IS
/*********************************************************************
	F_DESMOTMOV	Descripción motivo de movimiento
	ALLIBCTR
**********************************************************************/
BEGIN
	BEGIN
		SELECT tmotmov
		INTO ptmotmov
		FROM motmovseg
		WHERE cmotmov=pcmotmov
		AND cidioma=pcidioma;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN(101728); -- Error al acceder a la tabla
	END;
	RETURN(0);
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_DESMOTMOV" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_DESMOTMOV" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_DESMOTMOV" TO "PROGRAMADORESCSI";
