--------------------------------------------------------
--  DDL for Function F_ESTDESRIESGO1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_ESTDESRIESGO1" (
   psseguro IN NUMBER,
   pnriesgo IN NUMBER,
   pcobjase IN NUMBER,
   ptriesgo OUT VARCHAR2,
   plongitud IN NUMBER DEFAULT 50)
   RETURN NUMBER AUTHID CURRENT_USER IS
/*****************************************************************
   F_ESTDESRIESGO1
   Descripción del riesgo en función del tipo de objeto
   asegurado. Devuelve una sola linea.
   Se toma como base la f_estdesriesgo.
******************************************************************

******************************************************************
   Posibles valores de "pcobjase"
   1-Persona
   2-Domicilio
   3-Descripción
   4-Innominado
   5-Auto
******************************************************************/
   num_err        NUMBER := 0;
   wlongitud      NUMBER := plongitud;
   wcobjase       NUMBER := pcobjase;
   wsperson       NUMBER;
   ptlin1         VARCHAR2(200);
   ptlin2         VARCHAR2(200);
   ptlin3         VARCHAR2(200);
   wtnatrie       VARCHAR2(300);
   wcmarca        VARCHAR2(5);
   wcmodelo3      VARCHAR2(3);
   wcmodelo8      VARCHAR2(8);
   wcversion3     VARCHAR2(3);
   wcversion11    VARCHAR2(11);
   wcmatric       VARCHAR2(12);
   wtmarca        VARCHAR2(40);
   wtmodelo       VARCHAR2(40);
   wtversion      VARCHAR2(40);
   wtvarian       VARCHAR2(40);
   wtriesgo       VARCHAR2(130);
   wsseguro       NUMBER;
   wnriesgo       NUMBER(3);
   wcsubpro       NUMBER;
   texto          VARCHAR2(100);
   texto1         VARCHAR2(100);
   texto2         VARCHAR2(100);
   v_cempres      estseguros.cempres%TYPE;   -- BUG17255:DRA:25/07/2011
BEGIN
   --
   --Validación parámetros
   --
   IF wlongitud < 1 THEN
      wlongitud := 1;
   ELSIF wlongitud > 300 THEN
      wlongitud := 300;
   END IF;

   -- BUG17255:DRA:25/07/2011:Inici
   BEGIN
      SELECT cempres
        INTO v_cempres
        FROM estseguros
       WHERE sseguro = psseguro;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         v_cempres := f_parinstalacion_n('EMPRESADEF');
   END;

   -- BUG17255:DRA:25/07/2011:Fi
   IF wcobjase IS NULL THEN
      BEGIN
         SELECT cobjase
           INTO wcobjase
           FROM estseguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 101903;   --Seguro no encontrado en la tabla SEGUROS
      END;
   END IF;

   ptriesgo := '*';

   IF wcobjase = 1 THEN
      BEGIN
         SELECT sperson
           INTO wsperson
           FROM estriesgos
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 102819;   --Riesgo no encontrado
      END;

      ptriesgo := SUBSTR(f_nombre_est(wsperson, 1, psseguro), 1, wlongitud);
      RETURN 0;
   END IF;

   IF wcobjase = 2 THEN
      BEGIN
         SELECT sperson
           INTO wsperson
           FROM estriesgos
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 102819;   --Riesgo no encontrado
      END;

      IF wsperson IS NOT NULL THEN
         ptriesgo := SUBSTR(f_nombre_est(wsperson, 1, psseguro), 1, wlongitud);
      ELSE
         num_err := f_estdireccion(2, psseguro, pnriesgo, 1, ptlin1, ptlin2, ptlin3);
         ptriesgo := SUBSTR(ptlin1 || ' ' || ptlin2 || ' ' || ptlin3, 1, wlongitud);
      END IF;

      RETURN 0;
   END IF;

   IF wcobjase IN(3, 4) THEN
      BEGIN
         SELECT tnatrie
           INTO wtnatrie
           FROM estriesgos
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 102819;   --Riesgo no encontrado
      END;

      IF LENGTH(wtnatrie) > wlongitud THEN
         IF wlongitud > 3 THEN
            ptriesgo := SUBSTR(wtnatrie, 1, wlongitud - 3) || '...';
         ELSE
            ptriesgo := SUBSTR(wtnatrie, 1, wlongitud);
         END IF;
      ELSE
         ptriesgo := SUBSTR(wtnatrie, 1, wlongitud);
      END IF;

      RETURN 0;
   END IF;

   IF wcobjase = 5 THEN
      --INICIO Bug 26241 - 27/02/2013 - DCT
      BEGIN
         SELECT triesgo
           INTO ptlin1
           FROM estautriesgos
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo;

         ptriesgo := ptlin1;
         RETURN 0;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 152509;   --102819;                 --Riesgo no encontrado
      END;

      --FIN Bug 26241 - 27/02/2013 - DCT

      -- Fi Bug 0014888
      RETURN 0;
   END IF;

   ptriesgo := '*** ¿PCOBJASE? ***';
   RETURN 0;
END;

/

  GRANT EXECUTE ON "AXIS"."F_ESTDESRIESGO1" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_ESTDESRIESGO1" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_ESTDESRIESGO1" TO "PROGRAMADORESCSI";
