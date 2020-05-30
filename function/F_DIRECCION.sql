--------------------------------------------------------
--  DDL for Function F_DIRECCION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_DIRECCION" (
   pctipo IN NUMBER,
   ps1 IN NUMBER,
   ps2 IN NUMBER,
   pcformat IN NUMBER,
   ptlin1 OUT VARCHAR2,
   ptlin2 OUT VARCHAR2,
   ptlin3 OUT VARCHAR2)
   RETURN NUMBER AUTHID CURRENT_USER IS
/*******************************************************************
F_DIRECCION: Retorna una adreça formatejada segons "pcformat",
deixant-la a "ptlin1","ptlin2" i "ptlin3".
Per obtindre l'adreça tenim un codi de persona i
codi de domicili o bé un codi d'assegurança i un
numero de risc.
   ALLIBMFM
          Se aumenta la longitud del campo wtdomici.
     Afegim el codi de error 3 pel cas de que la
         persona no tingui domicili
          Substuir el codi cpais=100 per cpais=nvl(f_parinstalacion_n('PAIS_DEF'),0)
*******************************************************************/
   codi_error     NUMBER := 0;
   wtdomici       per_direcciones.tdomici%TYPE;
   wcpostal       codpostal.cpostal%TYPE;   -- canvi format codi postal
   wcpoblac       poblaciones.cpoblac%TYPE;
   wcprovin       provincias.cprovin%TYPE;
   vpoblacio      poblaciones.tpoblac%TYPE;
   vprovincia     provincias.tprovin%TYPE;
   vcpais         NUMBER(3);
   vtpais         paises.tpais%TYPE;
   wlin3          VARCHAR2(40);
   codi_error2    NUMBER;
   --
   vptlin1        VARCHAR2(4000);
   vptlin2        VARCHAR2(4000);
   vptlin3        VARCHAR2(4000);
--
BEGIN
   IF pctipo NOT BETWEEN 1 AND 2 THEN
      codi_error := 1;
      RETURN(codi_error);
   END IF;

   IF pcformat NOT BETWEEN 1 AND 2 THEN
      codi_error := 2;
      RETURN(codi_error);
   END IF;

   IF pctipo = 1 THEN
      BEGIN
         SELECT tdomici, cpostal, cpoblac, cprovin
           INTO wtdomici, wcpostal, wcpoblac, wcprovin
           FROM per_direcciones
          WHERE sperson = ps1
            AND cdomici = ps2;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            p_tab_error(f_sysdate, f_user, 'F_DIRECCION', 0,
                        'SELECT DIRECCIONES WHERE SPERSON=' || ps1 || ' CDOMICI=' || ps2,
                        SQLERRM);
            RETURN NULL;
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'F_DIRECCION', 0,
                        'SELECT DIRECCIONES WHERE SPERSON=' || ps1 || ' CDOMICI=' || ps2,
                        'WHEN OTHERS ' || SQLERRM);
            RETURN NULL;
      END;
   ELSE
      BEGIN
         SELECT tdomici, cpostal, cpoblac, cprovin
           INTO wtdomici, wcpostal, wcpoblac, wcprovin
           FROM sitriesgo
          WHERE sseguro = ps1
            AND nriesgo = ps2;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'F_DIRECCION', 0,
                        'SELECT SITRIESGO WHERE sseguro=' || ps1 || ' nriesgo=' || ps2,
                        'WHEN OTHERS ' || SQLERRM);
            RETURN NULL;
      END;
   END IF;

   IF pcformat = 1 THEN
      vptlin1 := wtdomici;
      codi_error2 := f_despoblac(wcpoblac, wcprovin, vpoblacio);

      IF TRIM(wcpostal) = ''
         OR wcpostal IS NULL THEN   --   canvi format codi postal
         vptlin2 := vpoblacio;
      ELSE
         vptlin2 := wcpostal || ' ' || vpoblacio;   --  canvi format codi postal
      END IF;

      codi_error2 := f_desprovin(wcprovin, vprovincia, vcpais, vtpais);

-- No tornem la provincia entre parèntesis, i el pais el tornem en majúscules i independentment de la provincia
      IF vprovincia = vpoblacio THEN
         wlin3 := NULL;
      ELSE
--              wlin3 := '('||vprovincia||')';
         wlin3 := vprovincia || ' ';
      END IF;

      IF vcpais <> NVL(f_parinstalacion_n('PAIS_DEF'), 0) THEN
--                 wlin3 := wlin3||vtpais;
         wlin3 := wlin3 || UPPER(vtpais);
      END IF;

      vptlin3 := wlin3;
   END IF;

   IF pcformat = 2 THEN
      IF TRIM(wcpostal) = ''
         OR wcpostal IS NULL THEN   --  canvi format codi postal
         vptlin1 := wtdomici;
      ELSE
         vptlin1 := wtdomici || ' (' || wcpostal || ')';   --   canvi format codi postal
      END IF;

      vptlin2 := NULL;
      vptlin3 := NULL;
   END IF;

   ptlin1 := SUBSTR(vptlin1, 1, 200);
   ptlin2 := SUBSTR(vptlin2, 1, 200);
   ptlin3 := SUBSTR(vptlin3, 1, 200);
   RETURN(codi_error);
END;

/

  GRANT EXECUTE ON "AXIS"."F_DIRECCION" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_DIRECCION" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_DIRECCION" TO "PROGRAMADORESCSI";
