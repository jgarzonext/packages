--------------------------------------------------------
--  DDL for Function F_CPERTIP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_CPERTIP" (pnnumnif IN VARCHAR2)
   RETURN NUMBER AUTHID CURRENT_USER IS
/****************************************************************************
   F_CPERTIP: Indica el tipo de persona (física o jurídica) en función
         del NIF.
           Devuelve:
            1 => Si es NIF (física)
            2 => Si es CIF (jurídica)
            0 => Cualquier otro caso (Ej. NIF incorrecto, NIF que
                          empiece por ZZ)
   ALLIBMFM.
****************************************************************************/
   primer_carac   VARCHAR2(1);
   noveno_carac   VARCHAR2(1);
BEGIN
   primer_carac := SUBSTR(pnnumnif, 1, 1);
   noveno_carac := SUBSTR(pnnumnif, 9, 1);

   IF ASCII(primer_carac) >= 65
      AND ASCII(primer_carac) <= 90 THEN   --es letra
      IF SUBSTR(pnnumnif, 1, 2) = 'ZZ' THEN
         RETURN 0;
      ELSE
         IF ASCII(noveno_carac) >= 48
            AND ASCII(noveno_carac) <= 57 THEN   --es numero
            RETURN 2;
         ELSE
            RETURN 0;
         END IF;
      END IF;
   ELSIF ASCII(primer_carac) >= 48
         AND ASCII(primer_carac) <= 57 THEN   --es número
      IF ASCII(noveno_carac) >= 65
         AND ASCII(noveno_carac) <= 90 THEN   --es letra
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   END IF;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_CPERTIP" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_CPERTIP" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_CPERTIP" TO "PROGRAMADORESCSI";
