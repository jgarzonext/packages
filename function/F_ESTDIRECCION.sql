--------------------------------------------------------
--  DDL for Function F_ESTDIRECCION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_ESTDIRECCION" (
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
   *******************************************************************/
   codi_error     NUMBER := 0;
   wtdomici       estper_direcciones.tdomici%TYPE;
   wcpostal       estper_direcciones.cpostal%TYPE;   -- canvi format codi postal
   wcpoblac       estper_direcciones.cpoblac%TYPE;
   wcprovin       estper_direcciones.cprovin%TYPE;
   vpoblacio      poblaciones.tpoblac%TYPE;
   vprovincia     provincias.tprovin%TYPE;
   vcpais         paises.cpais%TYPE;
   vtpais         paises.tpais%TYPE;
   wlin3          VARCHAR2(40);
   codi_error2    NUMBER;
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
      SELECT tdomici, cpostal, cpoblac, cprovin
        INTO wtdomici, wcpostal, wcpoblac, wcprovin
        FROM estper_direcciones
       WHERE sperson = ps1
         AND cdomici = ps2;
   ELSE
      SELECT tdomici, cpostal, cpoblac, cprovin
        INTO wtdomici, wcpostal, wcpoblac, wcprovin
        FROM estsitriesgo
       WHERE sseguro = ps1
         AND nriesgo = ps2;
   END IF;

   IF pcformat = 1 THEN
      ptlin1 := wtdomici;
      codi_error2 := f_despoblac(wcpoblac, wcprovin, vpoblacio);

      IF TRIM(wcpostal) = ''
         OR wcpostal IS NULL THEN   -- canvi format codi postal
         ptlin2 := vpoblacio;
      ELSE   -- canvi format codi postal
         ptlin2 := wcpostal || ' ' || vpoblacio;
      END IF;

      codi_error2 := f_desprovin(wcprovin, vprovincia, vcpais, vtpais);

      --  No tornem la provincia entre parèntesis, i el pais el
      --  tornem en majúscules i independentment de la provincia
      IF vprovincia = vpoblacio THEN
         wlin3 := NULL;
      ELSE
         -- wlin3 := '('||vprovincia||')';
         wlin3 := vprovincia || ' ';
      END IF;

      IF vcpais <> 100 THEN
         -- wlin3 := wlin3||vtpais;
         wlin3 := wlin3 || UPPER(vtpais);
      END IF;

      ptlin3 := wlin3;
   END IF;

   IF pcformat = 2 THEN
      IF TRIM(wcpostal) = ''
         OR wcpostal IS NULL THEN   -- canvi format codi postal
         ptlin1 := wtdomici;
      ELSE   -- canvi format codi postal
         ptlin1 := wtdomici || ' (' || wcpostal || ')';
      END IF;

      ptlin2 := NULL;
      ptlin3 := NULL;
   END IF;

   RETURN(codi_error);
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_ESTDIRECCION" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_ESTDIRECCION" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_ESTDIRECCION" TO "PROGRAMADORESCSI";
