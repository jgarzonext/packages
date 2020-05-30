--------------------------------------------------------
--  DDL for Function F_PLANTILLA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_PLANTILLA" (pcprogra IN VARCHAR2, pcempres IN NUMBER,
                      pfasiento IN DATE, psmodcon OUT NUMBER,
                      pcasiento OUT NUMBER)
RETURN NUMBER authid current_user IS
--
-- Devuelve el código  y tipo de la plantilla contable a utilizar.
--
-- Librería: ALLIBADM
--
BEGIN
 SELECT smodcon, casient
   INTO psmodcon, pcasiento
   FROM modconta
  WHERE cprogra = upper(pcprogra)
    AND cempres = pcempres
    AND pfasiento >= fini
    AND (pfasiento <  ffin OR ffin is null);
 RETURN 0;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 107810; -- No hay ninguna plantilla
  WHEN OTHERS THEN
    RETURN 107811; -- error en la lectura de la tabla de plantillas
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_PLANTILLA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_PLANTILLA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_PLANTILLA" TO "PROGRAMADORESCSI";
