create or replace FUNCTION          "F_CONSORCIO" (
   psperson IN NUMBER)
   RETURN NUMBER IS
/***********************************************************************
 F_CONSORCIO : Retorna 0 si no es consorcio y 1 si es consorcio
 Consulta a partir de su sperson.
 01.0        26/04/2019   AP  IAXIS 3670 Ajuste Validaciones Consorcios-UT
***********************************************************************/
consorcio1	NUMBER := 0;
consorcio2	NUMBER := 0;

BEGIN
          BEGIN
            SELECT COUNT(P.SPERSON)
            INTO consorcio1
            FROM PER_PERSONAS P
            WHERE P.ctipide = 0 AND P.sperson = psperson;
          EXCEPTION WHEN OTHERS THEN
                consorcio1 :=0;
          END;
          ---
          BEGIN
            SELECT COUNT(F.SPERSON)
            INTO consorcio2
            FROM FIN_GENERAL F
            WHERE F.SPERSON = psperson AND F.CTIPSOCI IN (9,10);
		  EXCEPTION WHEN OTHERS THEN
                consorcio2 :=0;
          END;

		  IF consorcio1 = 0 AND consorcio2 = 0 THEN 
			RETURN 0; -- NO ES CONSORCIO
		  ELSE
			RETURN 1; -- SI ES CONSORCIO
		  END IF;
          
EXCEPTION
   WHEN OTHERS THEN
      RETURN 0;
END;
/