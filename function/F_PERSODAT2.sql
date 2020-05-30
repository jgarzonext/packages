--------------------------------------------------------
--  DDL for Function F_PERSODAT2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_PERSODAT2" (psperson IN NUMBER, pcsexper OUT NUMBER,
pfnacimi OUT DATE, pcestado OUT NUMBER, pcsujeto OUT NUMBER, pcpais OUT NUMBER)
RETURN NUMBER AUTHID current_user IS
/****************************************************************************
    F_persodat2: Obtenir el sexo, la fecha de nacimiento, el estado  y el tipo de sujeto
        de la persona entrada com a paràmetre.
    CSI
****************************************************************************/
BEGIN
    SELECT csexper, fnacimi, cestado, null, cpais
    INTO pcsexper, pfnacimi, pcestado,  pcsujeto, pcpais
    FROM PERSONAS
    WHERE sperson = psperson;
    RETURN (0);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 100534;    --Persona inexistent
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_PERSODAT2" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_PERSODAT2" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_PERSODAT2" TO "PROGRAMADORESCSI";
