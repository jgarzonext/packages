--------------------------------------------------------
--  DDL for Function F_BORRAIMPZERO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_BORRAIMPZERO" (
   pnrecibo IN NUMBER,
   pmodo IN VARCHAR2,
   psproces IN NUMBER,
   phagrabat IN NUMBER)
   RETURN NUMBER AUTHID CURRENT_USER IS
   error          NUMBER;
   xiprinet       NUMBER;
   xitotpri       NUMBER;
   xitotalr       NUMBER;
--
--  ALLIBADM. ESBORRA TOTES LES DADES D' UN REBUT
-- SI TOTS ELS SEUS IMPORTS SÓN ZERO. ES POT DONAR EL CAS SI ALGUN IMPORT ÉS
-- DIFERENT DE ZERO I DESPRÉS ES MULTIPLICA PER NASEGUR = 0, PEL CAS DE
-- COL.LECTIUS INNOMINATS.
--
-- SI REBEM PHAGRABAT = 1, VOL DIR QUE ÉS EL CAS DE QUÈ S' HAN GRABAT DETALLS
-- DEL REBUT, I HEM DE COMPROBAR SI L' HEM D' ESBORRAR O NO. EN CANVI, SI
-- REBEM PHAGRABAT = 2, ÉS EL CAS DE QUÈ NO S' HAN GRABAT DETALLS I L' ÚNIC
-- QUE S' HA DE FER ÉS ESBORRAR LA CAPÇALERA DEL REBUT (RECIBOS) (NO ÉS UN
-- ERROR).
--
--
BEGIN
   IF pmodo = 'R' THEN
      BEGIN
         SELECT iprinet, itotpri, itotalr
           INTO xiprinet, xitotpri, xitotalr
           FROM vdetrecibos
          WHERE nrecibo = pnrecibo;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;
         WHEN OTHERS THEN
            RETURN 103920;   -- ERROR AL LLEGIR DE VDETRECIBOS
      END;

      IF NVL(xiprinet, 0) = 0
         AND NVL(xitotpri, 0) = 0
         AND NVL(xitotalr, 0) = 0 THEN
         BEGIN
            -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
            DELETE FROM vdetrecibos_monpol
                  WHERE nrecibo = pnrecibo;

            -- FIN BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
            DELETE FROM vdetrecibos
                  WHERE nrecibo = pnrecibo;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 105157;   -- ERROR A L' ESBORRAR DE VDETRECIBOS
         END;

         BEGIN
            DELETE      detrecibos
                  WHERE nrecibo = pnrecibo;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 105156;   -- ERROR A L' ESBORRAR DE DETRECIBOS
         END;

         BEGIN
            DELETE      movrecibo
                  WHERE nrecibo = pnrecibo;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 104768;   -- ERROR A L' ESBORRAR DE MOVRECIBO
         END;

         BEGIN
            DELETE      recibosredcom
                  WHERE nrecibo = pnrecibo;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 105201;   -- ERROR A L' ESBORRAR DE RECIBOSREDCOM
         END;

         BEGIN
            DELETE      recibos
                  WHERE nrecibo = pnrecibo;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 105155;   -- ERROR A L' ESBORRAR DE RECIBOS
         END;

         IF phagrabat = 1 THEN
            RETURN 105154;   -- REBUT ESBORRAT A LA FUNCIÓ DE CÀLCUL DE
         -- REBUTS PER NOMBRE D' ASSEGURATS = 0 DE LA PÒLISSA
         ELSIF phagrabat = 2 THEN
            RETURN 0;   -- HA ESBORRAT LES DADES DEL REBUT, PERÒ NO TENIA
         ELSE   -- DETALLS
            RETURN 101901;   -- PAS DE PARÀMETRES INCORRECTE A LA FUNCIÓ
         END IF;
      ELSE
         RETURN 0;   -- NO HA HAGUT CAP ERROR I EL REBUT NO S' HA ESBORRAT
      END IF;
   ELSIF pmodo = 'P'
         OR pmodo = 'N' THEN
      BEGIN
         SELECT iprinet, itotpri, itotalr
           INTO xiprinet, xitotpri, xitotalr
           FROM vdetreciboscar
          WHERE sproces = psproces
            AND nrecibo = pnrecibo;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;
         WHEN OTHERS THEN
            RETURN 104441;   -- ERROR A L' ESBORRAR DE VDETRECIBOSCAR
      END;

      IF NVL(xiprinet, 0) = 0
         AND NVL(xitotpri, 0) = 0
         AND NVL(xitotalr, 0) = 0 THEN
         BEGIN
            -- BUG 18423 - 30/11/2011 - JMP - LCOL000 - Multimoneda
            DELETE      vdetreciboscar_monpol
                  WHERE sproces = psproces
                    AND nrecibo = pnrecibo;

            -- BUG 18423 - 30/11/2011 - JMP - LCOL000 - Multimoneda
            DELETE      vdetreciboscar
                  WHERE sproces = psproces
                    AND nrecibo = pnrecibo;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 105160;   -- ERROR A L' ESBORRAR DE VDETRECIBOSCAR
         END;

         BEGIN
            DELETE      detreciboscar
                  WHERE sproces = psproces
                    AND nrecibo = pnrecibo;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 105159;   -- ERROR A L' ESBORRAR DE DETRECIBOSCAR
         END;

         BEGIN
            DELETE      reciboscar
                  WHERE sproces = psproces
                    AND nrecibo = pnrecibo;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 105158;   -- ERROR A L' ESBORRAR DE RECIBOSCAR
         END;

         IF phagrabat = 1 THEN
            RETURN 105154;   -- REBUT ESBORRAT A LA FUNCIÓ DE CÀLCUL DE
         -- REBUTS PER NOMBRE D' ASSEGURATS = 0 DE LA PÒLISSA
         ELSIF phagrabat = 2 THEN
            RETURN 0;   -- HA ESBORRAT LES DADES DEL REBUT, PERÒ NO TENIA
         ELSE   -- DETALLS
            RETURN 101901;   -- PAS DE PARÀMETRES INCORRECTE A LA FUNCIÓ
         END IF;
      ELSE
         RETURN 0;   -- NO HA HAGUT CAP ERROR I EL REBUT NO S' HA ESBORRAT
      END IF;
   ELSE
      RETURN 101901;   -- PAS DE PARÀMETRES INCORRECTE A LA FUNCIÓ
   END IF;
END;

/

  GRANT EXECUTE ON "AXIS"."F_BORRAIMPZERO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_BORRAIMPZERO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_BORRAIMPZERO" TO "PROGRAMADORESCSI";
