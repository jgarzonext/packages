--------------------------------------------------------
--  DDL for Function F_BUSCTAENV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_BUSCTAENV" (PERSON IN NUMBER,CTA IN OUT VARCHAR2) RETURN NUMBER
authid current_user IS
/***********************************************************************
	F_BUSCTAENV: RETORNA EL NUMERO DE CUENTA DESTINO PARA UNA TRANSFERENCIA
	ALLIBADM
***********************************************************************/
BEGIN
    SELECT CBANCAR INTO CTA
    FROM AGENTES
    WHERE CAGENTE = PERSON;
    RETURN 0;
    EXCEPTION
     WHEN NO_DATA_FOUND THEN
        RETURN  101955;
     WHEN OTHERS THEN
        RETURN 104473;
END F_BUSCTAENV;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_BUSCTAENV" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_BUSCTAENV" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_BUSCTAENV" TO "PROGRAMADORESCSI";
