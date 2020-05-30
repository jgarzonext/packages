--------------------------------------------------------
--  DDL for Function F_BAJACU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_BAJACU" (psseguro IN NUMBER, pfinici IN DATE)
   RETURN NUMBER AUTHID CURRENT_USER IS
/***********************************************************************
   F_BAJACU: Aquesta funció cambia la composició d'un cúmul a
                REARIESGOS quan s'anul.la una pòlissa.
                El crida el programa de Baixa de Pòlisses (f_anulaseg).
                Els paràmetres son:
                   - seguro anul.lat.
                   - data de l'anul.lació.
   ALLIBREA
REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  -------  -------------------------------------
      1.0        XX/XX/XXXX   XXX     1. Creación de la función.
      1.1        15/06/2010   AVT     2. 0015007: CEM800 - Anul·lacions: error en el tractament de cúmuls
      3.0        14/02/2012   JMF     3. 0021242: CCAT998-CEM - Anulación pol vto 60160497
      4.0        25/06/2013   RCL     4. 0024697: Canvi mida camp sseguro
***********************************************************************/

   -- ini Bug 0021242 - 14/02/2012 - JMF
   vpas           NUMBER := 0;
   vobj           VARCHAR2(200) := 'f_bajacu';
   vpar           VARCHAR2(500) := ' s=' || psseguro || ' i=' || pfinici;
   -- fin Bug 0021242 - 14/02/2012 - JMF
   codi_error     NUMBER := 0;
   --Inici BUG 24697 - 25/06/2013 - RCL
   w_sseguro      NUMBER;
   --Fi BUG 24697 - 25/06/2013 - RCL
   w_scumulo      NUMBER(6);
   vsseguro       reariesgos.sseguro%TYPE;   --BUG9219 23/03/2009 XCG Comprovar generació de cúmuls

   -- 15007 AVT 15-06-2010 s'afegeixen les condicions de la select al cursor
   -- Bug 26830 - APD - 02/05/2013 - se modifica la condicion
   -- AND freafin <= fini AND freafin IS NULL
    -- por
    -- AND(freafin <= fini OR freafin IS NULL)
   CURSOR cur_rea(seg IN NUMBER, fini IN DATE) IS
      SELECT *
        FROM reariesgos
       WHERE sseguro = seg
         AND scumulo IS NOT NULL   --= w_scumulo
         AND(freafin <= fini
             OR freafin IS NULL);
BEGIN
   vpas := 1000;
--   AQUI ES BUSCA SI LA PÓLISSA PERTANY A UN CÙMUL ACTIU...
   -- 15007 AVT 15-06-2010 s'afegeixen les condicions al cursor
   /*
   BEGIN
      SELECT scumulo
        INTO w_scumulo
        FROM reariesgos
       WHERE sseguro = psseguro
         AND scumulo IS NOT NULL
         AND freaini <= pfinici
         AND freafin IS NULL;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN(0);
      WHEN TOO_MANY_ROWS THEN
         codi_error := 107094;
         RETURN(codi_error);
   END; */

   --   AQUI ANUL.LEM EL CÙMUL ANTIC I DONEM D'ALTA EL NOU...
   vpas := 1010;

   FOR reg IN cur_rea(psseguro, pfinici) LOOP
      w_sseguro := reg.sseguro;
      w_scumulo := reg.scumulo;

      BEGIN
         vpas := 1020;

         UPDATE reariesgos
            SET freafin = pfinici
          WHERE scumulo = w_scumulo
            AND sseguro = w_sseguro
            AND freafin IS NULL;
      EXCEPTION
         WHEN OTHERS THEN
            -- Bug 0021242 - 14/02/2012 - JMF
            p_tab_error(f_sysdate, f_user, vobj, vpas,
                        vpar || ' cum=' || w_scumulo || ' seg=' || w_sseguro,
                        SQLCODE || ' ' || SQLERRM);
            codi_error := 107095;
            RETURN(codi_error);
      END;

      IF w_sseguro <> psseguro THEN
--BUG9219 23/03/2009 XCG Comprovar generació de cúmuls

         --BUG9219 23/03/2009 XCG Comprovar generació de cúmuls
         BEGIN
            vpas := 1030;

            SELECT sseguro
              INTO vsseguro
              FROM reariesgos
             WHERE sseguro = w_sseguro
               AND nriesgo = reg.nriesgo
               AND freaini = pfinici
               AND cgarant = NVL(reg.cgarant, cgarant)
               AND scumulo = reg.scumulo
               AND scontra = reg.scontra
               AND freafin = NULL
               AND nversio = reg.nversio;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               BEGIN
                  vpas := 1040;

                  INSERT INTO reariesgos
                              (sseguro, nriesgo, freaini, cgarant, scumulo,
                               scontra, freafin, nversio)
                       VALUES (w_sseguro, reg.nriesgo, pfinici, reg.cgarant, reg.scumulo,
                               reg.scontra, NULL, reg.nversio);
               EXCEPTION
                  WHEN OTHERS THEN
                     -- Bug 0021242 - 14/02/2012 - JMF
                     p_tab_error(f_sysdate, f_user, vobj, vpas,
                                 vpar || ' seg=' || w_sseguro || ' rie=' || reg.nriesgo
                                 || ' gar=' || reg.cgarant || ' cum=' || reg.scumulo
                                 || ' con=' || reg.scontra || ' ver=' || reg.nversio,
                                 SQLCODE || ' ' || SQLERRM);
                     codi_error := 107096;
                     RETURN(codi_error);
               END;
            WHEN OTHERS THEN
               -- Bug 0021242 - 14/02/2012 - JMF
               p_tab_error(f_sysdate, f_user, vobj, vpas,
                           vpar || ' seg=' || w_sseguro || ' rie=' || reg.nriesgo || ' gar='
                           || reg.cgarant || ' cum=' || reg.scumulo || ' con=' || reg.scontra
                           || ' ver=' || reg.nversio,
                           SQLCODE || ' ' || SQLERRM);
               NULL;
         END;
--FI BUG9219
      END IF;
   END LOOP;

   RETURN(0);
END;

/

  GRANT EXECUTE ON "AXIS"."F_BAJACU" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_BAJACU" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_BAJACU" TO "PROGRAMADORESCSI";
