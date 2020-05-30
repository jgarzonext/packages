--------------------------------------------------------
--  DDL for Function F_PERSONA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_PERSONA" (ppersona IN VARCHAR2, ptipus IN NUMBER,
                         -- 1: NIF; 2: SPERSON
pnif IN OUT VARCHAR2, psperson IN OUT NUMBER, pnom IN OUT VARCHAR2,
resultat IN OUT NUMBER)
RETURN NUMBER authid current_user IS
/***********************************************************************
    F_PERSONA: Busca si existe una persona en la tabla. Retorna
        nombre y apellido.
    ALLIBMFM
***********************************************************************/
BEGIN
IF ptipus = 1 THEN
    SELECT    nnumide,
        sperson,
        f_nombre(sperson, 1, null),
        count(*)
    INTO    pnif,
        psperson,
        pnom,
        resultat
    FROM    per_personas
    WHERE nnumide = ppersona
    GROUP BY nnumide,
        sperson,
        f_nombre(sperson, 1, null);
ELSE
    SELECT    nnumide,
        sperson,
        f_nombre(sperson, 1, null),
        count(*)
    INTO    pnif,
        psperson,
        pnom,
        resultat
    FROM    per_personas
    WHERE sperson = to_number(ppersona)
    GROUP BY nnumide,
        sperson,
        f_nombre(sperson, 1, null);
END IF;
RETURN 0;
EXCEPTION
    WHEN too_many_rows THEN
        RETURN 102882;    --Persona duplicada
    WHEN others THEN
        RETURN 100534;    --Persona inexistent
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_PERSONA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_PERSONA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_PERSONA" TO "PROGRAMADORESCSI";
