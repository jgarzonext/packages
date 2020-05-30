--------------------------------------------------------
--  DDL for Function F_BUSCACOBBAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_BUSCACOBBAN" (
   pcramo IN NUMBER,
   pcmodali IN NUMBER,
   pctipseg IN NUMBER,
   pccolect IN NUMBER,
   pcagente IN NUMBER,
   pcbancar IN VARCHAR2,
   pctipban IN NUMBER,
   pnerror OUT NUMBER)
   RETURN NUMBER AUTHID CURRENT_USER IS
   --
   error          NUMBER;
   xccobban       NUMBER;
   trobat         BOOLEAN := FALSE;
   xcempresa      NUMBER;
   xcbanco        NUMBER;
   xdata          DATE;
   xxctipage      NUMBER;

   CURSOR cur_cobbancario IS
      SELECT   ccobban
          FROM cobbancario
         WHERE cbaja = 0   --> SOLO LAS QUE NO ESTÁN DE BAJA
      ORDER BY nprisel;

   CURSOR cur_cobbancariosel IS
      SELECT   cramo, cmodali, ctipseg, ccolect, cagente, cempres, cbanco, ctipage
          FROM cobbancariosel
         WHERE ccobban = xccobban
      ORDER BY norden;

   reg_cobsel     cur_cobbancariosel%ROWTYPE;
BEGIN
   IF pcramo IS NOT NULL
      AND pcmodali IS NOT NULL
      AND pctipseg IS NOT NULL
      AND pccolect IS NOT NULL
      AND pcagente IS NOT NULL
                              -- AND pcbancar IS NOT NULL --MAL 25549/134464
   THEN
      error := f_empresa(NULL, NULL, pcramo, xcempresa);

      IF error <> 0 THEN
         RETURN(error);
      END IF;

      -- Modif. JAMVER 08/01/2008
      IF pctipban = 1 THEN   -- Española
         xcbanco := TO_NUMBER(SUBSTR(pcbancar, 1, 4));
      ELSIF pctipban = 2 THEN   -- IBAN
         -- BUG13303:DRA:22/02/2010:Inici
         -- xcbanco := TO_NUMBER(SUBSTR(pcbancar, 7, 2));
         xcbanco := TO_NUMBER(SUBSTR(pcbancar, 8, 1));
      -- BUG13303:DRA:22/02/2010:Fin
      ELSIF pctipban = 3 THEN   -- Andorrana
         xcbanco := TO_NUMBER(SUBSTR(pcbancar, 1, 2));
      ELSIF pctipban = 5 THEN   -- Angola
         xcbanco := NULL;
      ELSE   -- Andorrana por defecto
         xcbanco := TO_NUMBER(SUBSTR(pcbancar, 1, 2));
      END IF;

      xdata := f_sysdate;

      -- Se busca el Cobrador
      OPEN cur_cobbancario;

      FETCH cur_cobbancario
       INTO xccobban;

      WHILE cur_cobbancario%FOUND
       AND NOT(trobat) LOOP
         OPEN cur_cobbancariosel;

         FETCH cur_cobbancariosel
          INTO reg_cobsel;

         WHILE cur_cobbancariosel%FOUND
          AND NOT(trobat) LOOP
            trobat := TRUE;

            IF reg_cobsel.cempres IS NOT NULL THEN
               IF reg_cobsel.cempres <> xcempresa THEN
                  trobat := FALSE;
               END IF;
            END IF;

            IF reg_cobsel.cramo IS NOT NULL THEN
               IF reg_cobsel.cramo <> pcramo THEN
                  trobat := FALSE;
               END IF;
            END IF;

            IF reg_cobsel.cmodali IS NOT NULL THEN
               IF reg_cobsel.cmodali <> pcmodali THEN
                  trobat := FALSE;
               END IF;
            END IF;

            IF reg_cobsel.ctipseg IS NOT NULL THEN
               IF reg_cobsel.ctipseg <> pctipseg THEN
                  trobat := FALSE;
               END IF;
            END IF;

            IF reg_cobsel.ccolect IS NOT NULL THEN
               IF reg_cobsel.ccolect <> pccolect THEN
                  trobat := FALSE;
               END IF;
            END IF;

            IF reg_cobsel.cagente IS NOT NULL THEN
               error := f_buscapadre(xcempresa, pcagente, xxctipage, xdata,
                                     reg_cobsel.cagente);

               IF error = 0 THEN
                  IF xxctipage <> reg_cobsel.ctipage THEN
                     trobat := FALSE;
                  END IF;
               ELSE
                  pnerror := error;
                  RETURN(NULL);
               END IF;
            END IF;

            IF reg_cobsel.cbanco IS NOT NULL
               AND xcbanco IS NOT NULL THEN
               IF reg_cobsel.cbanco <> xcbanco THEN
                  trobat := FALSE;
               END IF;
            END IF;

            IF NOT trobat THEN
               FETCH cur_cobbancariosel
                INTO reg_cobsel;
            END IF;
         END LOOP;

         CLOSE cur_cobbancariosel;

         IF NOT trobat THEN
            FETCH cur_cobbancario
             INTO xccobban;
         END IF;
      END LOOP;

      CLOSE cur_cobbancario;

      IF trobat THEN
         pnerror := 0;
         RETURN(xccobban);
      ELSE
         pnerror := 0;
         RETURN NULL;
      END IF;
   ELSE
      pnerror := 101901;   -- Paso incorrecto de parámetros a la función
      RETURN(NULL);
   END IF;
-- BUG 21546_108724 - 08/02/2012 - JLTS - Cierre de posibles cursores abiertos, se adiciona EXCEPTION
EXCEPTION
   WHEN OTHERS THEN
      IF cur_cobbancario%ISOPEN THEN
         CLOSE cur_cobbancario;
      END IF;

      IF cur_cobbancariosel%ISOPEN THEN
         CLOSE cur_cobbancariosel;
      END IF;

      pnerror := 140999;   -- Error no controlado
      RETURN NULL;
END f_buscacobban;

/

  GRANT EXECUTE ON "AXIS"."F_BUSCACOBBAN" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_BUSCACOBBAN" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_BUSCACOBBAN" TO "PROGRAMADORESCSI";
