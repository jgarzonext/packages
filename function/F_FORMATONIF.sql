--------------------------------------------------------
--  DDL for Function F_FORMATONIF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_FORMATONIF" (psperson IN NUMBER, pnformat IN NUMBER,
pnnumnif IN OUT VARCHAR2, pnnifdup IN OUT NUMBER, pnnifrep IN OUT NUMBER,
pcnifrep IN OUT NUMBER, ptnumnif OUT VARCHAR2)
   RETURN NUMBER AUTHID CURRENT_USER IS
/****************************************************************************
   F_FORMATONIF: Formatea el NIF de una persona con los códigos de
           duplicado y repetición
           (Se puede informar como parámetro de entrada psperson o
            pnnumnif,pnnifdup, pnnifrep, pcnifrep.
          pnformat = 1 => NIF/pnnifdup/pnnifrep*
          pnformat = 2 => NIF de personas repetidas que sean la misma
                    persona, se devuelve sin número de repetición
   ALLIBMFM.

   Se formatean también los CIF's que acaban con letra
****************************************************************************/
   primer_carac   VARCHAR2(1);
   format_nif     VARCHAR2(20);
   ppnnumnif      VARCHAR2(20);
   a              VARCHAR2(20) := NULL;
   b              VARCHAR2(10) := NULL;
   c              VARCHAR2(10) := NULL;
   d              VARCHAR2(10) := NULL;
   ultim_carac    VARCHAR2(1);
BEGIN
   IF psperson IS NOT NULL
      AND psperson <> 0 THEN
      BEGIN
         SELECT nnumnif, nnifdup, nnifrep, cnifrep
           INTO pnnumnif, pnnifdup, pnnifrep, pcnifrep
           FROM personas
          WHERE sperson = psperson;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 100534;   --Persona inexistente
      END;
   END IF;

-----Formateamos el NIF ó CIF------------------------------------------
-----------------------------------------------------------------------
   primer_carac := SUBSTR(pnnumnif, 1, 1);
   ultim_carac := SUBSTR(pnnumnif, 9, 1);

   IF SUBSTR(pnnumnif, 1, 2) = 'CF'
      OR SUBSTR(pnnumnif, 1, 2) = 'ZZ' THEN
      RETURN 0;
   END IF;

   IF ASCII(primer_carac) >= 65
      AND ASCII(primer_carac) <= 90 THEN   --es letra
      IF ASCII(ultim_carac) >= 48
         AND ASCII(ultim_carac) <= 57 THEN   --es número
         ppnnumnif := LPAD(SUBSTR(pnnumnif, 2), 8, '0');

         IF primer_carac = 'Z' THEN
            format_nif := 'Z' || '-'
                          || LTRIM(TO_CHAR(TO_NUMBER(SUBSTR(ppnnumnif, 1, 8)), '00G000G000'));
         ELSE
            format_nif := LTRIM(primer_carac || '-'
                                || LTRIM(TO_CHAR(TO_NUMBER(SUBSTR(ppnnumnif, 1, 8)),
                                                 '00G000G000')));
         END IF;
      ELSIF ASCII(ultim_carac) >= 65
            AND ASCII(ultim_carac) <= 90 THEN   --es letra
         ppnnumnif := LPAD(SUBSTR(pnnumnif, 2), 7, '0');
         format_nif := LTRIM(primer_carac || '-'
                             || LTRIM(TO_CHAR(TO_NUMBER(SUBSTR(ppnnumnif, 1, 7)), '0G000G000'))
                             || '-' || ultim_carac);
      END IF;
   ELSIF ASCII(primer_carac) >= 48
         AND ASCII(primer_carac) <= 57 THEN   --es número
      ppnnumnif := LPAD(pnnumnif, 9, '0');
      format_nif := LTRIM(TO_CHAR(TO_NUMBER(SUBSTR(ppnnumnif, 1, 8)), '00G000G000') || '-'
                          || SUBSTR(ppnnumnif, 9, 1));
   END IF;

----En función de pnformat hacemos el formato deseado------------------
-----------------------------------------------------------------------
   IF pnformat = 1
      OR pnformat = 2 THEN
      a := format_nif;

      IF pnnifdup = 0 THEN
         b := NULL;
      ELSE
         b := '/' || TO_CHAR(pnnifdup);
      END IF;

      IF pnnifrep = 0 THEN
         c := NULL;
      ELSE
         c := '/' || LPAD(TO_CHAR(pnnifrep), 2, '0');

         IF b IS NULL THEN
            b := '/' || b;
         END IF;
      END IF;

      IF pcnifrep = NULL THEN
         d := NULL;
      ELSIF pcnifrep = 0 THEN
         d := '*';
      ELSIF pcnifrep = 1 THEN
         d := NULL;

         IF pnformat = 2 THEN   ---Segundo formato
            c := NULL;

            IF b = '/' THEN
               b := NULL;
            END IF;
         END IF;
      END IF;

      ptnumnif := a || b || c || d;
   END IF;

   RETURN 0;
EXCEPTION
   WHEN OTHERS THEN
      RETURN 102843;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_FORMATONIF" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_FORMATONIF" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_FORMATONIF" TO "PROGRAMADORESCSI";
