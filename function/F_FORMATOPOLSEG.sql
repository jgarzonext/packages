--------------------------------------------------------
--  DDL for Function F_FORMATOPOLSEG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_FORMATOPOLSEG" (PSSEGURO IN NUMBER) RETURN VARCHAR2 authid current_user IS
/***************************************************************************
    F_FORMATOPOLSEG : FORMATEA EL NÚMERO DE PÓLIZA Y CERTIFICADO ASOCIADO A
                      UN SSEGURO.
    18/12/2008 RSC
****************************************************************************/
    SALIDA    VARCHAR2(25);

    VNPOLIZA  NUMBER;
    VNCERTIF  NUMBER;
BEGIN
    SELECT npoliza, ncertif INTO VNPOLIZA, VNCERTIF
    FROM seguros
    WHERE sseguro = PSSEGURO;

    SALIDA := F_FORMATOPOL (VNPOLIZA, VNCERTIF,1);

    RETURN SALIDA;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_FORMATOPOLSEG" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_FORMATOPOLSEG" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_FORMATOPOLSEG" TO "PROGRAMADORESCSI";
