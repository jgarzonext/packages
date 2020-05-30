--------------------------------------------------------
--  DDL for Function F_VALIDAR_NIF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_VALIDAR_NIF" (
   pnnumnif IN VARCHAR2,
   psperson IN OUT NUMBER,
   caracter OUT VARCHAR2)
   RETURN NUMBER AUTHID CURRENT_USER IS
/****************************************************************************
   F_VALIDAR_NIF: Comprueba si el nif ya existe, si está repetido,
            si empieza por Z,...
      RETURN 0 => encuentra el NIF
      RETURN 1 => no encuentra el NIF
      RETURN 2 => NIF duplicado o repetido
      RETURN 3 => sólo han introducido una Z
      caracter := null  => NIF normal
      caracter := 'Z'   => NIF empieza por ZZ seguido de numeros
   ALIBMFM.
   REVISIONES:
      Ver        Fecha       Autor  Descripci?n
      ---------  ----------  -----  ------------------------------------
      1.0                           Creaci?n del package.
      2.0        15/04/2014  JMG    2. 0030819:172481 LCOL896-Soporte a cliente en Liberty (Abril 2014)
****************************************************************************/
   codi_nnumnif   VARCHAR2(10);
   primer_carac   VARCHAR2(1);
   aux            VARCHAR2(10);
   nif            VARCHAR2(10);
BEGIN
   caracter := NULL;
   primer_carac := SUBSTR(pnnumnif, 1, 1);

   IF primer_carac = 'Z' THEN
      IF LENGTH(pnnumnif) = 1 THEN   --nif que sólo es una Z
         RETURN 3;
      ELSE
         IF SUBSTR(pnnumnif, 1, 2) != 'ZZ' THEN
            caracter := 'Z';   --nif que empieza con ZZ y le siguen números
         ELSE
            caracter := NULL;
         END IF;
      END IF;
   END IF;

   BEGIN
      --Bug 30819 - 15/04/2012 - JMG -  Se aplica validación por per_personas.
      SELECT nnumide, sperson
        INTO codi_nnumnif, psperson
        FROM per_personas
       WHERE nnumide = pnnumnif
         AND(sperson = psperson
             OR psperson IS NULL);
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 1;   -- ese NIF no está dado de alta
      WHEN TOO_MANY_ROWS THEN
         RETURN 2;   -- NIF duplicado o repetido
   END;

   RETURN 0;
END;

/

  GRANT EXECUTE ON "AXIS"."F_VALIDAR_NIF" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_VALIDAR_NIF" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_VALIDAR_NIF" TO "PROGRAMADORESCSI";
