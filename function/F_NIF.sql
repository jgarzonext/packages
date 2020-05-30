--------------------------------------------------------
--  DDL for Function F_NIF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_NIF" (w_nif IN OUT VARCHAR2)
   RETURN NUMBER AUTHID CURRENT_USER IS
--*********************************************************
--   F_NIF  : Obte el nif o el cif amb la lletra correcta.
--            Si hi ha problema retorna un numero de error, si no 0.
--   Retorna:
--   0 - nif correcte.
--   101249 - nif/cif null.
--   101250 - longitud nif/cif incorrecte. --> 9902747
--   101251 - lletra nif/cif incorrecte. --> 9903641
--   101506 - digit cif incorrecte.
--   101657 - nif sense lletra.
--   MSR : Simplificacions i millora 29/01/2008
--   JTS : Adaptació nou format d'identificador de sistema 14/01/2009
--*********************************************************
   lletresnif CONSTANT VARCHAR2(23) := 'TRWAGMYFPDXBNJZSQVHLCKE';
   lletresinicialscif CONSTANT VARCHAR2(20) := 'ABCDEFGJHNPQRSUVWYZ';
   lletrescif CONSTANT VARCHAR2(10) := 'ABCDEFGHIJ';
   w_caracter     VARCHAR2(1);   -- Primer caràcter
   w_long         NUMBER;
   w_c            VARCHAR2(1);   -- Caràcter
   w_n            VARCHAR2(8);   -- Part numèrica
   w_x            VARCHAR2(1);   -- Càracter final per CIF
   w_a            VARCHAR2(1);
   -- Lletra de la validació del CIF
   w_d            VARCHAR2(1);
   -- Dígit de la validació del CIF
   w_r_aux        NUMBER;
   sw_nif         NUMBER;
   w_r            NUMBER;
   w_dif          NUMBER;
BEGIN
   w_caracter := UPPER(SUBSTR(w_nif, 1, 1));
    -- Els que comencen per ZZ o CF no es validen
    --Validem tots els NIF o CIF, idependentment com comencin, s'hauria de mirar per ctipdoc.
    --Bug 22787 Nota : 118838
   /* IF SUBSTR(w_nif, 1, 2) = 'ZZ'
       OR SUBSTR(w_nif, 1, 2) = 'CF' THEN
       RETURN 0;
    END IF;*/
   w_long := LENGTH(w_nif);

   IF w_long < 8
      OR w_long > 12 THEN
      -- Bug 22053 - MDS - 27/04/2012
      --RETURN 101250;   -- longitud nif incorrecta
      RETURN 9902747;   -- longitud nif incorrecta
   END IF;

   IF w_nif IS NULL
      OR w_nif = ' ' THEN
      RETURN 101249;   -- nif null
   END IF;

   IF w_caracter IN('K', 'L', 'M') THEN
      sw_nif := 4;   -- NIF Especials
      w_c := w_caracter;
      w_n := SUBSTR(w_nif, 2, 7);
      w_x := SUBSTR(w_nif, 9, 1);
   ELSIF w_caracter IN('X', 'T', 'Y', 'Z') THEN
      sw_nif := 3;   -- NIE
      w_c := w_caracter;
      w_n := LPAD(SUBSTR(w_nif, 2, 7), 7, '0');
      -- Nota: alguns NIE no ténen els 0 a l'esquerra
      w_x := SUBSTR(w_nif, 9, 1);
   ELSIF ASCII(w_caracter) >= 65
         AND ASCII(w_caracter) <= 90 THEN   -- Lletres
      sw_nif := 2;   -- CIF;
      w_c := w_caracter;
      w_n := SUBSTR(w_nif, 2, 7);
      w_x := SUBSTR(w_nif, 9, 1);
   ELSIF ASCII(w_caracter) >= 48
         AND ASCII(w_caracter) <= 57 THEN   -- Números
      sw_nif := 1;   -- NIF
      w_x := SUBSTR(w_nif, 9, 1);
      w_n := SUBSTR(w_nif, 1, 8);
   ELSE
      RETURN 101657;
   END IF;

   BEGIN
      IF sw_nif = 1
         OR sw_nif = 3 THEN   -- NIE i NIF es validen igual
         IF (LENGTH(w_n) <> 8
             AND sw_nif = 1)
            OR(LENGTH(w_n) <> 7
               AND sw_nif = 3) THEN
                     -- Bug 22053 - MDS - 27/04/2012
            -- Bug 22053 - MDS - 27/04/2012
            --RETURN 101250;
            RETURN 9902747;
         END IF;

         IF w_x IS NULL THEN
            -- Bug 22053 - MDS - 27/04/2012
            --RETURN 101250;   -- Falta el dígit de control final
            RETURN 9902747;   -- Falta el dígit de control final
         END IF;

         -- MSR 17/12/2008
         -- Y i Z es calculen de forma especial
         w_n := TO_NUMBER(CASE w_caracter
                             WHEN 'Z' THEN '2' || TO_CHAR(w_n)
                             WHEN 'Y' THEN '1' || TO_CHAR(w_n)
                             ELSE TO_CHAR(w_n)
                          END);

         IF SUBSTR(lletresnif, MOD(TO_NUMBER(w_n), 23) + 1, 1) <> w_x THEN
            -- Bug 22053 - MDS - 27/04/2012
               --RETURN 101251;
            RETURN 9903641;
         END IF;
      ELSE   -- CIF i NIF especial es validen igual
         IF LENGTH(w_n) <> 7 THEN
            -- Bug 22053 - MDS - 27/04/2012
                   --RETURN 101250;
            RETURN 9902747;
         END IF;

         IF w_x IS NULL THEN
            -- Bug 22053 - MDS - 27/04/2012
               --RETURN 101250;   -- Falta el dígit de control final
            RETURN 9902747;   -- Falta el dígit de control final
         END IF;

         w_r := 0;

         FOR i IN 1 .. 7 LOOP
            IF MOD(i, 2) = 0 THEN   -- posició parell
               w_r := w_r + TO_NUMBER(SUBSTR(w_n, i, 1));
            ELSE
               w_r_aux := TO_NUMBER(SUBSTR(w_n, i, 1)) * 2;
               w_r := w_r + TRUNC(w_r_aux / 10) + MOD(w_r_aux, 10);
            END IF;
         END LOOP;

         w_dif := 10 - MOD(w_r, 10);
         w_a := SUBSTR(lletrescif, w_dif, 1);
         w_d := SUBSTR(TO_CHAR(w_dif), -1);

         -- En cas de 10 agafem el 0, per la resta el número
         IF w_x <> w_a
            AND w_x <> w_d THEN
            -- Bug 22053 - MDS - 27/04/2012
            --RETURN 101251;   -- Ni número ni lletra coincideixen
            RETURN 9903641;   -- Ni número ni lletra coincideixen
         END IF;
      END IF;
   EXCEPTION
      WHEN VALUE_ERROR THEN
         RETURN 9903982;   -- No són números els que haurien de ser-ho
   END;

   RETURN 0;
END;

/

  GRANT EXECUTE ON "AXIS"."F_NIF" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_NIF" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_NIF" TO "PROGRAMADORESCSI";
