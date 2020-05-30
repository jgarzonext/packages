--------------------------------------------------------
--  DDL for Function F_CAPITAL_RIESGO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_CAPITAL_RIESGO" (psesion NUMBER, dummy NUMBER)
   RETURN NUMBER IS
   ultimodiamesanterior DATE;
   importe        NUMBER;
   salida         NUMBER;
   psseguro       NUMBER;
   pfecha         DATE;
   npfecha        NUMBER;
   paport         NUMBER;
   edad1          NUMBER;
   edad2          NUMBER;
BEGIN
--BUSCAR LOS PARAMETROS CON LOS QUE TRABAJARA LA FUNCION
-- I - JLB - OPTIMIZACION
--   SELECT valor
--     INTO psseguro
--     FROM sgt_parms_transitorios
--    WHERE sesion = psesion
--      AND parametro = 'SSEGURO';
   psseguro := pac_sgt.get(psesion, 'SSEGURO');
--   SELECT valor
--     INTO npfecha
--     FROM sgt_parms_transitorios
--    WHERE sesion = psesion
--      AND parametro = 'FECHA';
   npfecha := pac_sgt.get(psesion, 'FECHA');
   pfecha := TO_DATE(npfecha, 'yyyymmdd');
   --SELECT valor
   --  INTO paport
   --  FROM sgt_parms_transitorios
   -- WHERE sesion = psesion
   --   AND parametro = 'APORTACION';
   paport := pac_sgt.get(psesion, 'APORTACION');
--   SELECT valor
--     INTO edad1
--     FROM sgt_parms_transitorios
--    WHERE sesion = psesion
--      AND parametro = 'EDAD1';
   edad1 := pac_sgt.get(psesion, 'EDAD1');
--   SELECT valor
--     INTO edad2
--     FROM sgt_parms_transitorios
--    WHERE sesion = psesion
--      AND parametro = 'EDAD2';
   edad2 := pac_sgt.get(psesion, 'EDAD2');

   IF psseguro = 0 THEN   --Se trata de nueva producción
      importe := paport;
   ELSE   --Se trata de cartera
      ultimodiamesanterior := pfecha - TO_NUMBER(TO_CHAR(pfecha, 'dd'));
      importe := f_saldo_poliza_ulk(psseguro, pfecha);
   END IF;

   IF edad2 = 0 THEN   --poliza una cabeza
      salida := importe / 10;

      IF salida > 12020.24
         AND edad1 < 65 THEN
         salida := 12020.24;
      ELSIF salida > 601.01
            AND edad1 >= 65 THEN
         salida := 601.01;
      END IF;
   ELSE
      salida := importe * 3;

      IF salida > 30050.60
         AND edad1 < 65
         AND edad2 < 65 THEN
         salida := 30050.60;
      ELSIF salida > 601.01
            AND(edad1 >= 65
                OR edad2 >= 65) THEN
         salida := 601.01;
      END IF;
   END IF;

   RETURN salida;
END;

/

  GRANT EXECUTE ON "AXIS"."F_CAPITAL_RIESGO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_CAPITAL_RIESGO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_CAPITAL_RIESGO" TO "PROGRAMADORESCSI";
