--------------------------------------------------------
--  DDL for Function GET_VAL_TABLA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."GET_VAL_TABLA" (
   numsesion IN NUMBER,
   tabla IN VARCHAR2,
   ctermino IN VARCHAR2)
   RETURN NUMBER AUTHID CURRENT_USER IS
   valor          NUMBER;
BEGIN
   valor := NULL;

   IF tabla = 'GENTE' THEN
      /* LEER DATOS DE LA TABLA GENTE   */
      DECLARE
         fnac           DATE;
         fcarnet        DATE;
         cpers          NUMBER;
         fecefe         DATE;
      BEGIN
           -- I - JLB  - OPTIMIZACION
         --     SELECT valor
         --       INTO cpers
         --       FROM sgt_parms_transitorios
         --      WHERE sesion = numsesion
         --        AND parametro = 'PERSONA';
         cpers := pac_sgt.get(numsesion, 'PERSONA');
  --       SELECT TO_DATE(valor, 'yyyymmdd')
  --         INTO fecefe
  --         FROM sgt_parms_transitorios
  ---        WHERE sesion = numsesion
--          AND parametro = 'FECEFE';
         fecefe := TO_DATE(pac_sgt.get(numsesion, 'FECEFE'), 'yyyymmdd');
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            valor := 0;
      END;
   ELSIF tabla = 'YYY' THEN
      NULL;
   /* LEER DATOS DE LA TABLA ADECUADA   */
   END IF;

   RETURN valor;
END;

/

  GRANT EXECUTE ON "AXIS"."GET_VAL_TABLA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."GET_VAL_TABLA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."GET_VAL_TABLA" TO "PROGRAMADORESCSI";
