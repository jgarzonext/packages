--------------------------------------------------------
--  DDL for Package Body PAC_PROPIO_ALBSGT_MSV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_PROPIO_ALBSGT_MSV" IS
   /****************************************************************************************************
      NOMBRE:     PAC_PROPIO_ALBSGT_MSV
      PROPÓSITO:  Cuerpo del paquete de las funciones para
                  el cáculo de las preguntas relacionadas con
                  productos de MSV

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        15/10/2013   CML             1. Cálculo de la edad del asegurado 1 a una fecha dada
                                              3. Cálculo de la edad del asegurado 2 a una fecha dada
                                              2. Cálculo de la edad del tomador a una fecha dada
   ******************************************************************************************************/
   FUNCTION f_edad_asegurado1(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,
      pnmovimi IN NUMBER,
      cgarant IN NUMBER,
      psproces IN NUMBER,
      pnmovima IN NUMBER,
      picapital IN NUMBER)
      RETURN NUMBER IS
      v_fnacimi      DATE;
      v_edad         NUMBER;
      ntraza         NUMBER := 0;
   BEGIN
      ntraza := 1;

      IF ptablas = 'EST' THEN
         ntraza := 2;

         BEGIN
            SELECT p.fnacimi
              INTO v_fnacimi
              FROM estassegurats a, estper_personas p
             WHERE a.sseguro = psseguro
               AND a.sperson = p.sperson
               AND a.norden = 1;
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         ntraza := 3;
         v_edad := TRUNC((pfefecto - v_fnacimi) / 365.25);
      ELSIF ptablas = 'SOL' THEN
         ntraza := 4;

         BEGIN
            SELECT a.fnacimi
              INTO v_fnacimi
              FROM solseguros s, solasegurados a
             WHERE s.ssolicit = psseguro
               AND s.ssolicit = a.ssolicit
               AND a.norden = 1;
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         ntraza := 5;
         v_edad := TRUNC((pfefecto - v_fnacimi) / 365.25);
      ELSE
         ntraza := 6;

         BEGIN
            SELECT p.fnacimi
              INTO v_fnacimi
              FROM asegurados a, per_personas p
             WHERE a.sseguro = psseguro
               AND a.sperson = p.sperson
               AND a.norden = 1;
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         ntraza := 7;
         v_edad := TRUNC((pfefecto - v_fnacimi) / 365.25);
      END IF;

      ntraza := 8;
      RETURN v_edad;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 22222;
   END f_edad_asegurado1;

--------------------------------------------------------------------------
   FUNCTION f_edad_asegurado2(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,
      pnmovimi IN NUMBER,
      cgarant IN NUMBER,
      psproces IN NUMBER,
      pnmovima IN NUMBER,
      picapital IN NUMBER)
      RETURN NUMBER IS
      v_fnacimi      DATE;
      v_edad         NUMBER;
      ntraza         NUMBER := 0;
   BEGIN
      ntraza := 1;

      IF ptablas = 'EST' THEN
         ntraza := 2;

         BEGIN
            SELECT p.fnacimi
              INTO v_fnacimi
              FROM estassegurats a, estper_personas p
             WHERE a.sseguro = psseguro
               AND a.sperson = p.sperson
               AND a.norden = 2;
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         ntraza := 3;
         v_edad := TRUNC((pfefecto - v_fnacimi) / 365.25);
      ELSIF ptablas = 'SOL' THEN
         ntraza := 4;

         BEGIN
            SELECT a.fnacimi
              INTO v_fnacimi
              FROM solseguros s, solasegurados a
             WHERE s.ssolicit = psseguro
               AND s.ssolicit = a.ssolicit
               AND a.norden = 2;
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         ntraza := 5;
         v_edad := TRUNC((pfefecto - v_fnacimi) / 365.25);
      ELSE
         ntraza := 6;

         BEGIN
            SELECT p.fnacimi
              INTO v_fnacimi
              FROM asegurados a, per_personas p
             WHERE a.sseguro = psseguro
               AND a.sperson = p.sperson
               AND a.norden = 2;
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         ntraza := 7;
         v_edad := TRUNC((pfefecto - v_fnacimi) / 365.25);
      END IF;

      ntraza := 8;
      RETURN v_edad;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 22222;
   END f_edad_asegurado2;

--------------------------------------------------------------------------
   FUNCTION f_edad_tomador(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,
      pnmovimi IN NUMBER,
      cgarant IN NUMBER,
      psproces IN NUMBER,
      pnmovima IN NUMBER,
      picapital IN NUMBER)
      RETURN NUMBER IS
      v_fnacimi      DATE;
      v_edad         NUMBER;
   BEGIN
      IF ptablas = 'EST' THEN
         BEGIN
            SELECT fnacimi
              INTO v_fnacimi
              FROM esttomadores t, estper_personas p
             WHERE t.sseguro = psseguro
               AND t.sperson = p.sperson
               AND t.nordtom = 1;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN NULL;
         END;

         v_edad := TRUNC((pfefecto - v_fnacimi) / 365.25);
      ELSIF ptablas = 'SOL' THEN
           -- Estamos en nueva produccion o suplementos
         /*  BEGIN
              SELECT fnacimi
                INTO v_fnacimi
                FROM soltomadores t, per_personas p
               WHERE t.ssolicit = psseguro
                 AND p.sperson = p.sperson;
           EXCEPTION
              WHEN OTHERS THEN
                 RETURN NULL;
           END;

           v_edad := TRUNC ((pfefecto - v_fnacimi) / 365.25);
           */
         v_edad := 0;
      ELSE
         BEGIN
            SELECT p.fnacimi
              INTO v_fnacimi
              FROM tomadores t, per_personas p
             WHERE t.sseguro = psseguro
               AND t.sperson = p.sperson
               AND t.nordtom = 1;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN NULL;
         END;

         v_edad := TRUNC((pfefecto - v_fnacimi) / 365.25);
      END IF;

      RETURN v_edad;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 22222;
   END f_edad_tomador;
--------------------------------------------------------------------------
END pac_propio_albsgt_msv; 

/

  GRANT EXECUTE ON "AXIS"."PAC_PROPIO_ALBSGT_MSV" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PROPIO_ALBSGT_MSV" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PROPIO_ALBSGT_MSV" TO "PROGRAMADORESCSI";
