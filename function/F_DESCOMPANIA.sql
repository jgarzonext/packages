--------------------------------------------------------
--  DDL for Function F_DESCOMPANIA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_DESCOMPANIA" (pccompani IN NUMBER, ptcompani IN OUT VARCHAR2)
RETURN NUMBER authid current_user IS
/***********************************************************************
    F_DESCOMPANIA: Descripción de la Compañía. La busca en PERSONAS.

***********************************************************************/
psperson    VARCHAR2(10);
psperson2   NUMBER(6);
pnif        VARCHAR2(10);
presul      NUMBER;
codi_error  NUMBER;
BEGIN

    SELECT sperson
    INTO   psperson
    FROM   COMPANIAS
    WHERE  ccompani = pccompani;

    ptcompani := f_nombre(psperson,1);

    RETURN 0;
EXCEPTION
    WHEN others THEN
        ptcompani := NULL;
        RETURN 100508;     -- Compañía inexistent
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_DESCOMPANIA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_DESCOMPANIA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_DESCOMPANIA" TO "PROGRAMADORESCSI";
