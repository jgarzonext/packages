--------------------------------------------------------
--  DDL for Function F_LIMITECONSORCIO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_LIMITECONSORCIO" (
      ppercent IN NUMBER,
      pnvalor1 IN OUT NUMBER,
      pnvalor2 IN OUT NUMBER
	)
RETURN NUMBER authid current_user IS
--
--
   nerror NUMBER := 0;
--
BEGIN
   pnvalor1 := 0;
   pnvalor2 := 0;
--
-- El porcentaje de entrada ha de estar informado y no
-- puede ser negativo.
--
   IF (ppercent is NULL OR ppercent < 0) THEN
      nerror := 200000;
      RETURN nerror;
   END IF;
--
-- Con climite = 1 se accede al conjunto de registros
-- en los que se tiene:
--   nminimo  Intervalo del porcentaje
--   nmaximo  Intervalo del porcentaje
--   nvalor1  Coeficiente multiplicador sobre la tasa
--   nvalor2  Prima mínima en porcentaje de la prima a valor total
--
   BEGIN
      SELECT nvalor1, nvalor2
      INTO   pnvalor1, pnvalor2
      FROM   limites
      WHERE  climite = 1
        AND  ppercent >= nminimo
        AND  (ppercent < nmaximo OR nmaximo IS NULL);
   EXCEPTION
      WHEN no_data_found THEN
         nerror := 103834; --Límite no encontrato en LIMITES
      WHEN too_many_rows THEN
         nerror := 200000; --Intervalos solapados en la tabla LIMITES
      WHEN others THEN
         nerror := 103514; --Error al leer de la tabla LIMITES
   END;
   RETURN nerror;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_LIMITECONSORCIO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_LIMITECONSORCIO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_LIMITECONSORCIO" TO "PROGRAMADORESCSI";
