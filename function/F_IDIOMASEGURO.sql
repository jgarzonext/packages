--------------------------------------------------------
--  DDL for Function F_IDIOMASEGURO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_IDIOMASEGURO" (psseguro IN NUMBER, PTABLAS IN VARCHAR2 DEFAULT NULL)
RETURN NUMBER authid current_user IS
/***********************************************************************
	F_IDIOMASEGURO: Busca el idioma del seguro.
	ALLIBMFM
***********************************************************************/
xidioma NUMBER;
error   NUMBER;
dummy   VARCHAR2(200);
BEGIN
 if PTABLAS is null then
      BEGIN
      SELECT cidioma
        INTO xidioma
        FROM seguros
       WHERE sseguro = psseguro;
      EXCEPTION
        WHEN OTHERS THEN
          RETURN null;
      END;
      IF xidioma <> 0 THEN
        RETURN xidioma;
      ELSE -- el del tomador
        error := f_tomador(psseguro,1,dummy,xidioma);
        IF error <> 0 THEN
          RETURN null;
        END IF;
        RETURN xidioma;
      END IF;
 else
      BEGIN
      SELECT cidioma
        INTO xidioma
        FROM estseguros
       WHERE sseguro = psseguro;
      EXCEPTION
        WHEN OTHERS THEN
          RETURN null;
      END;
      IF xidioma <> 0 THEN
        RETURN xidioma;
      ELSE -- el del tomador
        error := f_esttomador(psseguro,1,dummy,xidioma);
        IF error <> 0 THEN
          RETURN null;
        END IF;
        RETURN xidioma;
      END IF;
 end if;

END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_IDIOMASEGURO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_IDIOMASEGURO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_IDIOMASEGURO" TO "PROGRAMADORESCSI";
