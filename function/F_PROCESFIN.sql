--------------------------------------------------------
--  DDL for Function F_PROCESFIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_PROCESFIN" (psproces IN NUMBER, pnerror  IN NUMBER)
RETURN NUMBER AUTHID current_user IS
--
-- Descripción: Finaliza un proceso.
-- Parámetros :
--               psproces: nº de proceso a finalizar
--               pnerror : nº de errores en el proceso
--
   PRAGMA autonomous_transaction;

WFECHA  DATE;
WPROCES NUMBER;
BEGIN
-- Recuperamos la fecha
  SELECT SYSDATE
    INTO WFECHA
    FROM DUAL;
-- Validamos la existencia del proceso
  BEGIN
    SELECT SPROCES
      INTO WPROCES
      FROM PROCESOSCAB
     WHERE SPROCES = PSPROCES;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN 1;
    WHEN TOO_MANY_ROWS THEN
      RETURN 2;
  END;
-- Actualizamos la información del proceso
  UPDATE PROCESOSCAB
     SET FPROFIN = WFECHA,
         NERROR  = PNERROR
   WHERE SPROCES = PSPROCES;

  COMMIT;

  RETURN 0;
END;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_PROCESFIN" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_PROCESFIN" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_PROCESFIN" TO "PROGRAMADORESCSI";
