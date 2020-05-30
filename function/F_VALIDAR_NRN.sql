--------------------------------------------------------
--  DDL for Function F_VALIDAR_NRN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_VALIDAR_NRN" (p_nrn IN VARCHAR2, p_fnacimi IN DATE,
p_fcsexper IN NUMBER)
   RETURN NUMBER IS
--**************************************************************************
--   JTS 16/01/2009
--   F_VALIDAR_NRN : Valida l'NRN que reb per paràmetre
--   Retorna:
--   0 - nrn ok
--   9000783 - nrn ko
--   9000764 - longitud incorrecta
--   9000765 - no es numéric
--   9000766 - data de naixement incorrecte
--   9000767 - sexe incorrecte
--*************************************************************************
   v_fnacimi      VARCHAR2(6);
   v_numbase      VARCHAR2(9);
   v_digitsc      VARCHAR2(2);
   v_digcalc      VARCHAR2(2);
   v_tmp          NUMBER;
BEGIN
   IF LENGTH(p_nrn) != 11 THEN
      RETURN 9000764;   --Longitud incorrecta
   END IF;

   BEGIN
      v_tmp := TO_NUMBER(p_nrn);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 9000765;   --No és numèric
   END;

   IF p_fnacimi IS NOT NULL
      AND p_fcsexper IS NOT NULL THEN
      v_fnacimi := TO_CHAR(p_fnacimi, 'YYMMDD');

      IF SUBSTR(p_nrn, 1, 6) != v_fnacimi THEN
         RETURN 9000766;   --Data de naixement no coincideix
      END IF;

      v_numbase := SUBSTR(p_nrn, 1, 9);

      IF (MOD(v_numbase, 2) = 0
          AND p_fcsexper = 1)
         OR(MOD(v_numbase, 2) = 1
            AND p_fcsexper = 2) THEN
         RETURN 9000767;   --Control de sexe incorrecte
      END IF;

      v_digitsc := SUBSTR(p_nrn, 10, 2);

      IF TO_NUMBER(TO_CHAR(p_fnacimi, 'YYYY')) < 2000 THEN
         v_digcalc := LPAD(97 - MOD(v_numbase, 97), 2, '0');
      ELSE
         v_digcalc := LPAD(97 - MOD(2 || v_numbase, 97), 2, '0');
      END IF;

      IF v_digitsc <> v_digcalc THEN
         RETURN 9000783;   --Dígits de control ko
      END IF;
   END IF;

   RETURN 0;   --Ok
EXCEPTION
   WHEN OTHERS THEN
      RETURN SQLCODE;
END f_validar_nrn;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_VALIDAR_NRN" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_VALIDAR_NRN" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_VALIDAR_NRN" TO "PROGRAMADORESCSI";
