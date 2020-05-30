--------------------------------------------------------
--  DDL for Function F_DUPPREGUNSEG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_DUPPREGUNSEG" (psseguro IN NUMBER, pmovimi IN NUMBER)
   RETURN NUMBER AUTHID CURRENT_USER IS
/************************************************************************
    F_DUPPREGUNSEG        Duplica las preguntas activas con el nuevo nº de
                movimiento

    Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ----------------------------------
      1.0        01/07/2009    JRH            Bug 10692: CEM - Revisar el proceso de revisión de interés

*************************************************************************/
   nerror         NUMBER;
   vnum           NUMBER;
BEGIN
   INSERT INTO pregunseg
               (sseguro, nriesgo, cpregun, crespue, nmovimi, trespue)
      SELECT sseguro, nriesgo, cpregun, crespue, pmovimi, trespue
        FROM pregunseg
       WHERE sseguro = psseguro
         AND nmovimi <> pmovimi
         AND nmovimi = (SELECT MAX(nmovimi)
                          FROM pregunseg seg1
                         WHERE seg1.sseguro = psseguro
                           AND seg1.nmovimi <> pmovimi);

   --BUG 10069 - JRH - 01/07/2009 Duplicamos las preguntas de póliza
   SELECT COUNT(*)
     INTO vnum
     FROM pregunpolseg
    WHERE sseguro = psseguro
      AND nmovimi = pmovimi;

   IF vnum = 0 THEN
      INSERT INTO pregunpolseg
                  (sseguro, cpregun, crespue, nmovimi, trespue)
         SELECT sseguro, cpregun, crespue, pmovimi, trespue
           FROM pregunpolseg
          WHERE sseguro = psseguro
            AND nmovimi <> pmovimi
            AND nmovimi = (SELECT MAX(nmovimi)
                             FROM pregunpolseg seg1
                            WHERE seg1.sseguro = psseguro
                              AND seg1.nmovimi <> pmovimi);
   END IF;

--Fi BUG 10069 - JRH - 01/07/2009
   RETURN 0;
EXCEPTION
   WHEN OTHERS THEN
      RETURN 110420;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_DUPPREGUNSEG" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_DUPPREGUNSEG" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_DUPPREGUNSEG" TO "PROGRAMADORESCSI";
