--------------------------------------------------------
--  DDL for Function F_STRSTD1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_STRSTD1" (pnnumnif IN VARCHAR2, format_nif OUT VARCHAR2)
   RETURN NUMBER AUTHID CURRENT_USER IS
/****************************************************************************
   F_STRSTD1: LLena de ceros por la izquierda un NIF con longitud
           incorrecta.
   ALLIBMFM
****************************************************************************/
   ppnnumnif      VARCHAR2(20);
   primer_carac   VARCHAR2(1);
   LONG           NUMBER;
   ultim_carac    VARCHAR2(1);
BEGIN
   IF SUBSTR(pnnumnif, 1, 2) = 'CF'
      OR SUBSTR(pnnumnif, 1, 2) = 'ZZ' THEN
      format_nif := pnnumnif;
      RETURN 0;
   END IF;

   primer_carac := SUBSTR(pnnumnif, 1, 1);
   LONG := LENGTH(pnnumnif);
   ultim_carac := SUBSTR(pnnumnif, LONG, 1);

   IF ASCII(primer_carac) >= 65
      AND ASCII(primer_carac) <= 90 THEN   --es letra
      ppnnumnif := LPAD(SUBSTR(pnnumnif, 2), 8, '0');
      format_nif := LTRIM(primer_carac || ppnnumnif);
   ELSIF ASCII(primer_carac) >= 48
         AND ASCII(primer_carac) <= 57   --es número
         AND ASCII(ultim_carac) >= 65
         AND ASCII(ultim_carac) <= 90 THEN   --es letra
      format_nif := LPAD(pnnumnif, 9, 0);
   ELSIF ASCII(primer_carac) >= 48
         AND ASCII(primer_carac) <= 57   --es número
         AND ASCII(ultim_carac) >= 48
         AND ASCII(ultim_carac) <= 57 THEN   --es número
      format_nif := LPAD(pnnumnif, 8, '0');
   END IF;

   RETURN 0;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_STRSTD1" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_STRSTD1" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_STRSTD1" TO "PROGRAMADORESCSI";
