--------------------------------------------------------
--  DDL for Function F_PCOMISI_AGENTE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_PCOMISI_AGENTE" (
   psseguro IN NUMBER,
   pcagente IN NUMBER,
   pcmodcom IN NUMBER,
   pfretenc IN DATE,
   ppcomisi OUT NUMBER,
   ppretenc OUT NUMBER,
   pcramo IN NUMBER DEFAULT NULL,
   pcmodali IN NUMBER DEFAULT NULL,
   pctipseg IN NUMBER DEFAULT NULL,
   pccolect IN NUMBER DEFAULT NULL,
   pcactivi IN NUMBER DEFAULT NULL,
   pcgarant IN NUMBER DEFAULT NULL,
   pfecha IN DATE DEFAULT f_sysdate)
   RETURN NUMBER IS
   /******************************************************************************
      NOMBRE:     F_PCOMISI_AGENTE
      PROPÓSITO:  Funcion de calculo de porcentaje de comision indirecta

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      2.0        11/02/2011  JMP              BUG 0015137: Tener en cuenta la fecha de vigencia
   ******************************************************************************/
   num_error      NUMBER := 0;
   xctipcom       NUMBER := 0;
   xcramo         NUMBER := 0;
   xcmodali       NUMBER := 0;
   xctipseg       NUMBER := 0;
   xccolect       NUMBER := 0;
   xcactivi       NUMBER := 0;
   xcretenc       NUMBER := 0;
   xccomisi       NUMBER := 0;
   w_ccampanya    detcampanya.ccampanya%TYPE;
   w_nversio      detcampanya.nversio%TYPE;
BEGIN
   IF pcmodcom IS NULL
      OR pfretenc IS NULL THEN
      RETURN 100900;   -- se han entrado valores nulos en parámetros OBLIGATORIOS
   END IF;

   IF psseguro IS NOT NULL THEN
      BEGIN
         SELECT ctipcom, cramo, cmodali, ctipseg, ccolect, cactivi
           INTO xctipcom, xcramo, xcmodali, xctipseg, xccolect, xcactivi
           FROM seguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 100500;   -- sseguro no encontrado
      END;
   ELSE
      xctipcom := 0;
      xcramo := pcramo;
      xcmodali := pcmodali;
      xccolect := pccolect;
      xctipseg := pctipseg;
      xcactivi := pcactivi;
   END IF;

   BEGIN
      SELECT cretenc, ccomisi
        INTO xcretenc, xccomisi
        FROM agentes
       WHERE cagente = pcagente;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 100504;   -- Agent inexistent
   END;

   IF xctipcom = 99 THEN   -- Forzada a 0
      ppcomisi := 0;
   ELSIF xctipcom = 0 THEN   -- La habitual
      BEGIN
--
-- Si hay campañas recuperamos el % de la campaña. Si no existe, damos error
--
         SELECT ccampanya, NVL(nversio, 0)
           INTO w_ccampanya, w_nversio
           FROM detcampanya
          WHERE cactivi = xcactivi
            AND cgarant = pcgarant
            AND sproduc IN(SELECT sproduc
                             FROM productos
                            WHERE cramo = xcramo
                              AND cmodali = xcmodali
                              AND ctipseg = xctipseg
                              AND ccolect = xccolect)
            AND NVL(finicam, f_sysdate - 1) <= f_sysdate
            AND f_sysdate <= NVL(ffincam, f_sysdate + 1);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            w_nversio := -1;
         WHEN OTHERS THEN
            w_nversio := -1;
      END;

--
-- Si hay una campaña informada, buscamos su comision
--
      IF w_nversio >= 0 THEN
         BEGIN
            SELECT pcomisi
              INTO ppcomisi
              FROM comisioncamp
             WHERE cramo = xcramo
               AND cmodali = xcmodali
               AND ctipseg = xctipseg
               AND ccolect = xccolect
               AND cactivi = xcactivi
               AND cgarant = pcgarant
               AND ccomisi = xccomisi
               AND cmodcom = pcmodcom
               AND ccampanya = w_ccampanya
               AND nversion = w_nversio;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN 110986;
            WHEN OTHERS THEN
               RETURN 110986;
         END;
      ELSE
         BEGIN
            SELECT pcomisi
              INTO ppcomisi
              FROM comisiongar
             WHERE cramo = xcramo
               AND cmodali = xcmodali
               AND ctipseg = xctipseg
               AND ccolect = xccolect
               AND cactivi = xcactivi
               AND cgarant = pcgarant
               AND ccomisi = xccomisi
               AND cmodcom = pcmodcom
               -- BUG 15137 - 11/02/2011 - JMP - Tener en cuenta la fecha de vigencia
               AND finivig = (SELECT MAX(finivig)
                                FROM comisiongar
                               WHERE cramo = xcramo
                                 AND cmodali = xcmodali
                                 AND ctipseg = xctipseg
                                 AND ccolect = xccolect
                                 AND cactivi = xcactivi
                                 AND cgarant = pcgarant
                                 AND ccomisi = xccomisi
                                 AND cmodcom = pcmodcom
                                 AND finivig <= pfecha);
         -- FIN BUG 15137 - 11/02/2011 - JMP
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               BEGIN
                  SELECT pcomisi
                    INTO ppcomisi
                    FROM comisionacti
                   WHERE cramo = xcramo
                     AND cmodali = xcmodali
                     AND ccolect = xccolect
                     AND ctipseg = xctipseg
                     AND cmodcom = pcmodcom
                     AND ccomisi = xccomisi
                     AND cactivi = xcactivi
                     -- BUG 15137 - 11/02/2011 - JMP - Tener en cuenta la fecha de vigencia
                     AND finivig = (SELECT MAX(finivig)
                                      FROM comisionacti
                                     WHERE cramo = xcramo
                                       AND cmodali = xcmodali
                                       AND ccolect = xccolect
                                       AND ctipseg = xctipseg
                                       AND cmodcom = pcmodcom
                                       AND ccomisi = xccomisi
                                       AND cactivi = xcactivi
                                       AND finivig <= pfecha);
               -- FIN BUG 15137 - 11/02/2011 - JMP
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     BEGIN
                        SELECT pcomisi
                          INTO ppcomisi
                          FROM comisionprod
                         WHERE cramo = xcramo
                           AND cmodali = xcmodali
                           AND ctipseg = xctipseg
                           AND ccolect = xccolect
                           AND cmodcom = pcmodcom
                           AND ccomisi = xccomisi
                           -- BUG 15137 - 11/02/2011 - JMP - Tener en cuenta la fecha de vigencia
                           AND finivig = (SELECT MAX(finivig)
                                            FROM comisionprod
                                           WHERE cramo = xcramo
                                             AND cmodali = xcmodali
                                             AND ctipseg = xctipseg
                                             AND ccolect = xccolect
                                             AND cmodcom = pcmodcom
                                             AND ccomisi = xccomisi
                                             AND finivig <= pfecha);
                     -- FIN BUG 15137 - 11/02/2011 - JMP
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           RETURN 100933;   -- Comissió inexistent
                        WHEN OTHERS THEN
                           RETURN 103216;   --Error al llegir la taula COMISIONPROD
                     END;
                  WHEN OTHERS THEN
                     RETURN 103628;   -- Error al llegir la taula COMISIONACTI
               END;
            WHEN OTHERS THEN
               RETURN 110824;   -- Error leyendo la tabla COMISIONGAR
         END;
      END IF;
   --ELSIF xctipcom = 90 THEN   --Comissió especial
   ELSIF xctipcom IN(90, 92) THEN   --Comissió especial  -- BUG 25214 - FAL - 25/01/2013
      BEGIN
         SELECT pcomisi
           INTO ppcomisi
           FROM comisionsegu
          WHERE sseguro = psseguro
            AND cmodcom = pcmodcom
            AND nmovimi = (SELECT MAX(nmovimi)
                             FROM comisionsegu
                            WHERE sseguro = psseguro);   -- Bug 30642/169851 - 20/03/2014 - AMC
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 100933;   -- Comissió inexistent
         WHEN OTHERS THEN
            RETURN 103627;   --Error al llegir la taula COMISIONSEGU
      END;
   ELSE
      RETURN 100947;   -- valor no válido en SEGUROS (ctipcom)
   END IF;

   BEGIN
      SELECT pretenc
        INTO ppretenc
        FROM retenciones
       WHERE cretenc = xcretenc
         AND TRUNC(pfretenc) >= TRUNC(finivig)
         AND TRUNC(pfretenc) < TRUNC(NVL(ffinvig, pfretenc + 1));

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 100726;   -- retención no encontrada
   END;

   RETURN(0);
END f_pcomisi_agente;

/

  GRANT EXECUTE ON "AXIS"."F_PCOMISI_AGENTE" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_PCOMISI_AGENTE" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_PCOMISI_AGENTE" TO "PROGRAMADORESCSI";
