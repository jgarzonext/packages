--------------------------------------------------------
--  DDL for Function F_CONCEPTO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_CONCEPTO" (
   pcconcep IN NUMBER,
   pcempres IN NUMBER,
   pfinivig IN DATE,
   pcforpag IN NUMBER,
   pcramo IN NUMBER,
   pcmodali IN NUMBER,
   pctipseg IN NUMBER,
   pccolect IN NUMBER,
   pcactivi IN NUMBER,
   pcgarant IN NUMBER,
   pctipcon OUT NUMBER,
   pnvalcon OUT NUMBER,
   pcfracci OUT NUMBER,
   pcbonifi OUT NUMBER,
   pcrecfra OUT NUMBER,
   p_climit OUT NUMBER,
   p_cmoneda OUT NUMBER,
   pcderreg OUT NUMBER)   -- Bug 0020314 - FAL - 29/11/2011
   RETURN NUMBER AUTHID CURRENT_USER IS
   /******************************************************************************
   NOM:      F_CONCEPTO
   PROPÒSIT:
   REVISIONS:
   Ver        Data        Autor             Descripció
   ---------  ----------  ---------------  ------------------------------------
   1.0        ??            ??             ??
   2.0        01/08/2009    NMM            2. 10864: CEM - Taxa aplicable Consorci.
   3.0        07/04/2010    JMC            3. 13677 Mejora control error.
   4.0        28/11/2011    JMP            4. 18423: LCOL000 - Multimoneda
   ******************************************************************************/
   vcconcep       NUMBER;
   vnconcep       NUMBER;
   vcempres       NUMBER;
   vcforpag       NUMBER;
   vfinivig       DATE;
   vparamin       tab_error.terror%TYPE;
--------------------------------------------------------------------------------
--                            F_CONCEPTO
--------------------------------------------------------------------------------
BEGIN
   vparamin := 'Parametros:' || CHR(13) || 'pcconcep=' || pcconcep || CHR(13) || 'pcempres='
               || pcempres || CHR(13) || 'pfinivig=' || pfinivig || CHR(13) || 'pcforpag='
               || pcforpag || CHR(13) || 'pcramo=' || pcramo || CHR(13) || 'pcmodali='
               || pcmodali || CHR(13) || 'pctipseg=' || pctipseg || CHR(13) || 'pccolect='
               || pccolect || CHR(13) || 'pcactivi=' || pcactivi || CHR(13) || 'pcgarant='
               || pcgarant || CHR(13);

   BEGIN
      SELECT   ctipcon, nvalcon, cfracci, cbonifi, crecfra, cconcep, nconcep,
               cempres, finivig, MAX(cforpag), climite,   -- Bug 10864:NMM:01/08/2009:
                                                       cmoneda,
               cderreg   -- Bug 0020314 - FAL - 29/11/2011
          INTO pctipcon, pnvalcon, pcfracci, pcbonifi, pcrecfra, vcconcep, vnconcep,
               vcempres, vfinivig, vcforpag, p_climit,   -- Bug 10864:NMM:01/08/2009:
                                                      p_cmoneda,   -- BUG 18423: LCOL000 - Multimoneda
               pcderreg   -- Bug 0020314 - FAL - 29/11/2011
          FROM imprec
         WHERE cconcep = pcconcep
           AND cempres = pcempres
           AND finivig <= pfinivig
           AND(ffinvig > pfinivig
               OR ffinvig IS NULL)
           AND((NVL(cforpag, pcforpag) = pcforpag
                AND pcforpag IS NOT NULL)
               OR(pcforpag IS NULL
                  AND cforpag IS NULL))
           AND cramo = pcramo
           AND cmodali = pcmodali
           AND ctipseg = pctipseg
           AND ccolect = pccolect
           AND cactivi = pcactivi
           AND cgarant = pcgarant
      GROUP BY ctipcon, nvalcon, cfracci, cbonifi, crecfra, cconcep, nconcep, cempres, finivig,
               climite,   -- Bug 10864:NMM:01/08/2009:
                       cmoneda, cderreg   -- Bug 0020314 - FAL - 29/11/2011
                                       ;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         BEGIN
            SELECT   ctipcon, nvalcon, cfracci, cbonifi, crecfra, cconcep, nconcep,
                     cempres, finivig, MAX(cforpag), climite,   -- Bug 10864:NMM:01/08/2009:
                                                             cmoneda,
                     cderreg   -- Bug 0020314 - FAL - 29/11/2011
                INTO pctipcon, pnvalcon, pcfracci, pcbonifi, pcrecfra, vcconcep, vnconcep,
                     vcempres, vfinivig, vcforpag, p_climit,   -- Bug 10864:NMM:01/08/2009:
                                                            p_cmoneda,   -- BUG 18423: LCOL000 - Multimoneda
                     pcderreg   -- Bug 0020314 - FAL - 29/11/2011
                FROM imprec
               WHERE cconcep = pcconcep
                 AND cempres = pcempres
                 AND finivig <= pfinivig
                 AND(ffinvig > pfinivig
                     OR ffinvig IS NULL)
                 AND((NVL(cforpag, pcforpag) = pcforpag
                      AND pcforpag IS NOT NULL)
                     OR(pcforpag IS NULL
                        AND cforpag IS NULL))
                 AND cramo = pcramo
                 AND cmodali = pcmodali
                 AND ctipseg = pctipseg
                 AND ccolect = pccolect
                 AND cactivi = 0
                 AND cgarant = pcgarant
            GROUP BY ctipcon, nvalcon, cfracci, cbonifi, crecfra, cconcep, nconcep, cempres,
                     finivig, climite,   -- Bug 10864:NMM:01/08/2009:
                                      cmoneda, cderreg   -- Bug 0020314 - FAL - 29/11/2011
                                                      ;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               BEGIN
                  SELECT   ctipcon, nvalcon, cfracci, cbonifi, crecfra, cconcep,
                           nconcep, cempres, finivig, MAX(cforpag), climite,   -- Bug 10864:NMM:01/08/2009:
                                                                            cmoneda,
                           cderreg   -- Bug 0020314 - FAL - 29/11/2011
                      INTO pctipcon, pnvalcon, pcfracci, pcbonifi, pcrecfra, vcconcep,
                           vnconcep, vcempres, vfinivig, vcforpag, p_climit,   -- Bug 10864:NMM:01/08/2009:
                                                                            p_cmoneda,   -- BUG 18423: LCOL000 - Multimoneda
                           pcderreg   -- Bug 0020314 - FAL - 29/11/2011
                      FROM imprec
                     WHERE cconcep = pcconcep
                       AND cempres = pcempres
                       AND finivig <= pfinivig
                       AND(ffinvig > pfinivig
                           OR ffinvig IS NULL)
                       AND((NVL(cforpag, pcforpag) = pcforpag
                            AND pcforpag IS NOT NULL)
                           OR(pcforpag IS NULL
                              AND cforpag IS NULL))
                       AND cramo = pcramo
                       AND cmodali = pcmodali
                       AND ctipseg = pctipseg
                       AND ccolect = pccolect
                       AND cactivi = pcactivi
                       AND cgarant IS NULL
                  GROUP BY ctipcon, nvalcon, cfracci, cbonifi, crecfra, cconcep, nconcep,
                           cempres, finivig, climite,   -- Bug 10864:NMM:01/08/2009:
                                                     cmoneda,
                           cderreg   -- Bug 0020314 - FAL - 29/11/2011
                                  ;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     BEGIN
                        SELECT   ctipcon, nvalcon, cfracci, cbonifi, crecfra, cconcep,
                                 nconcep, cempres, finivig, MAX(cforpag), climite,   -- Bug 10864:NMM:01/08/2009:
                                                                                  cmoneda,
                                 cderreg   -- Bug 0020314 - FAL - 29/11/2011
                            INTO pctipcon, pnvalcon, pcfracci, pcbonifi, pcrecfra, vcconcep,
                                 vnconcep, vcempres, vfinivig, vcforpag, p_climit,   -- Bug 10864:NMM:01/08/2009:
                                                                                  p_cmoneda,   -- BUG 18423: LCOL000 - Multimoneda
                                 pcderreg   -- Bug 0020314 - FAL - 29/11/2011
                            FROM imprec
                           WHERE cconcep = pcconcep
                             AND cempres = pcempres
                             AND finivig <= pfinivig
                             AND(ffinvig > pfinivig
                                 OR ffinvig IS NULL)
                             AND((NVL(cforpag, pcforpag) = pcforpag
                                  AND pcforpag IS NOT NULL)
                                 OR(pcforpag IS NULL
                                    AND cforpag IS NULL))
                             AND cramo = pcramo
                             AND cmodali = pcmodali
                             AND ctipseg = pctipseg
                             AND ccolect = pccolect
                             AND cactivi = 0
                             AND cgarant IS NULL
                        GROUP BY ctipcon, nvalcon, cfracci, cbonifi, crecfra, cconcep, nconcep,
                                 cempres, finivig, climite,   -- Bug 10864:NMM:01/08/2009:
                                                           cmoneda,
                                 cderreg   -- Bug 0020314 - FAL - 29/11/2011
                                        ;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           BEGIN
                              SELECT   ctipcon, nvalcon, cfracci, cbonifi, crecfra,
                                       cconcep, nconcep, cempres, finivig, MAX(cforpag),
                                       climite, cmoneda,   -- Bug 10864:NMM:01/08/2009:
                                       cderreg   -- Bug 0020314 - FAL - 29/11/2011
                                  INTO pctipcon, pnvalcon, pcfracci, pcbonifi, pcrecfra,
                                       vcconcep, vnconcep, vcempres, vfinivig, vcforpag,
                                       p_climit,   -- Bug 10864:NMM:01/08/2009:
                                                p_cmoneda,   -- BUG 18423: LCOL000 - Multimoneda
                                       pcderreg   -- Bug 0020314 - FAL - 29/11/2011
                                  FROM imprec
                                 WHERE cconcep = pcconcep
                                   AND cempres = pcempres
                                   AND finivig <= pfinivig
                                   AND(ffinvig > pfinivig
                                       OR ffinvig IS NULL)
                                   AND((NVL(cforpag, pcforpag) = pcforpag
                                        AND pcforpag IS NOT NULL)
                                       OR(pcforpag IS NULL
                                          AND cforpag IS NULL))
                                   AND cramo = pcramo
                                   AND cmodali = pcmodali
                                   AND ctipseg = pctipseg
                                   AND ccolect = pccolect
                                   AND cactivi IS NULL
                                   AND cgarant IS NULL
                              GROUP BY ctipcon, nvalcon, cfracci, cbonifi, crecfra, cconcep,
                                       nconcep, cempres, finivig, climite, cmoneda,
                                       cderreg   -- Bug 0020314 - FAL - 29/11/2011
                                              ;
                           EXCEPTION
                              WHEN NO_DATA_FOUND THEN
                                 BEGIN
                                    SELECT   ctipcon, nvalcon, cfracci, cbonifi,
                                             crecfra, cconcep, nconcep, cempres,
                                             finivig, MAX(cforpag), climite,   -- Bug 10864:NMM:01/08/2009:
                                                                            cmoneda,
                                             cderreg   -- Bug 0020314 - FAL - 29/11/2011
                                        INTO pctipcon, pnvalcon, pcfracci, pcbonifi,
                                             pcrecfra, vcconcep, vnconcep, vcempres,
                                             vfinivig, vcforpag, p_climit,   -- Bug 10864:NMM:01/08/2009:
                                                                          p_cmoneda,   -- BUG 18423: LCOL000 - Multimoneda
                                             pcderreg   -- Bug 0020314 - FAL - 29/11/2011
                                        FROM imprec
                                       WHERE cconcep = pcconcep
                                         AND cempres = pcempres
                                         AND finivig <= pfinivig
                                         AND(ffinvig > pfinivig
                                             OR ffinvig IS NULL)
                                         AND((NVL(cforpag, pcforpag) = pcforpag
                                              AND pcforpag IS NOT NULL)
                                             OR(pcforpag IS NULL
                                                AND cforpag IS NULL))
                                         AND cramo = pcramo
                                         AND cmodali = pcmodali
                                         AND ctipseg = pctipseg
                                         AND ccolect IS NULL
                                         AND cactivi IS NULL
                                         AND cgarant IS NULL
                                    GROUP BY ctipcon, nvalcon, cfracci, cbonifi, crecfra,
                                             cconcep, nconcep, cempres, finivig, climite,   -- Bug 10864:NMM:01/08/2009:
                                             cmoneda, cderreg   -- Bug 0020314 - FAL - 29/11/2011
                                                             ;
                                 EXCEPTION
                                    WHEN NO_DATA_FOUND THEN
                                       BEGIN
                                          SELECT   ctipcon, nvalcon, cfracci, cbonifi,
                                                   crecfra, cconcep, nconcep, cempres,
                                                   finivig, MAX(cforpag), climite,   -- Bug 10864:NMM:01/08/2009:
                                                                                  cmoneda,
                                                   cderreg   -- Bug 0020314 - FAL - 29/11/2011
                                              INTO pctipcon, pnvalcon, pcfracci, pcbonifi,
                                                   pcrecfra, vcconcep, vnconcep, vcempres,
                                                   vfinivig, vcforpag, p_climit,   -- Bug 10864:NMM:01/08/2009:
                                                                                p_cmoneda,   -- BUG 18423: LCOL000 - Multimoneda
                                                   pcderreg   -- Bug 0020314 - FAL - 29/11/2011
                                              FROM imprec
                                             WHERE cconcep = pcconcep
                                               AND cempres = pcempres
                                               AND finivig <= pfinivig
                                               AND(ffinvig > pfinivig
                                                   OR ffinvig IS NULL)
                                               AND((NVL(cforpag, pcforpag) = pcforpag
                                                    AND pcforpag IS NOT NULL)
                                                   OR(pcforpag IS NULL
                                                      AND cforpag IS NULL))
                                               AND cramo = pcramo
                                               AND cmodali = pcmodali
                                               AND ctipseg IS NULL
                                               AND ccolect IS NULL
                                               AND cactivi IS NULL
                                               AND cgarant IS NULL
                                          GROUP BY ctipcon, nvalcon, cfracci, cbonifi, crecfra,
                                                   cconcep, nconcep, cempres, finivig, climite,   -- Bug 10864:NMM:01/08/2009:
                                                   cmoneda,
                                                   cderreg   -- Bug 0020314 - FAL - 29/11/2011
                                                          ;
                                       EXCEPTION
                                          WHEN NO_DATA_FOUND THEN
                                             BEGIN
                                                SELECT   ctipcon, nvalcon, cfracci,
                                                         cbonifi, crecfra, cconcep,
                                                         nconcep, cempres, finivig,
                                                         MAX(cforpag), climite,   -- Bug 10864:NMM:01/08/2009:
                                                                               cmoneda,
                                                         cderreg   -- Bug 0020314 - FAL - 29/11/2011
                                                    INTO pctipcon, pnvalcon, pcfracci,
                                                         pcbonifi, pcrecfra, vcconcep,
                                                         vnconcep, vcempres, vfinivig,
                                                         vcforpag, p_climit,   -- Bug 10864:NMM:01/08/2009:
                                                                            p_cmoneda,   -- BUG 18423: LCOL000 - Multimoneda
                                                         pcderreg   -- Bug 0020314 - FAL - 29/11/2011
                                                    FROM imprec
                                                   WHERE cconcep = pcconcep
                                                     AND cempres = pcempres
                                                     AND finivig <= pfinivig
                                                     AND(ffinvig > pfinivig
                                                         OR ffinvig IS NULL)
                                                     AND((NVL(cforpag, pcforpag) = pcforpag
                                                          AND pcforpag IS NOT NULL)
                                                         OR(pcforpag IS NULL
                                                            AND cforpag IS NULL))
                                                     AND cramo = pcramo
                                                     AND cmodali IS NULL
                                                     AND ctipseg IS NULL
                                                     AND ccolect IS NULL
                                                     AND cactivi IS NULL
                                                     AND cgarant IS NULL
                                                GROUP BY ctipcon, nvalcon, cfracci, cbonifi,
                                                         crecfra, cconcep, nconcep, cempres,
                                                         finivig, climite,   -- Bug 10864:NMM:01/08/2009:
                                                                          cmoneda,
                                                         cderreg   -- Bug 0020314 - FAL - 29/11/2011
                                                                ;
                                             EXCEPTION
                                                WHEN NO_DATA_FOUND THEN
                                                   BEGIN
                                                      SELECT   ctipcon, nvalcon, cfracci,
                                                               cbonifi, crecfra, cconcep,
                                                               nconcep, cempres, finivig,
                                                               MAX(cforpag), climite,   -- Bug 10864:NMM:01/08/2009:
                                                               cmoneda,
                                                               cderreg   -- Bug 0020314 - FAL - 29/11/2011
                                                          INTO pctipcon, pnvalcon, pcfracci,
                                                               pcbonifi, pcrecfra, vcconcep,
                                                               vnconcep, vcempres, vfinivig,
                                                               vcforpag, p_climit,   -- Bug 10864:NMM:01/08/2009:
                                                               p_cmoneda,   -- BUG 18423: LCOL000 - Multimoneda
                                                               pcderreg   -- Bug 0020314 - FAL - 29/11/2011
                                                          FROM imprec
                                                         WHERE cconcep = pcconcep
                                                           AND cempres = pcempres
                                                           AND finivig <= pfinivig
                                                           AND(ffinvig > pfinivig
                                                               OR ffinvig IS NULL)
                                                           AND((NVL(cforpag, pcforpag) =
                                                                                       pcforpag
                                                                AND pcforpag IS NOT NULL)
                                                               OR(pcforpag IS NULL
                                                                  AND cforpag IS NULL))
                                                           AND cramo IS NULL
                                                           AND cmodali IS NULL
                                                           AND ctipseg IS NULL
                                                           AND ccolect IS NULL
                                                           AND cactivi IS NULL
                                                           AND cgarant IS NULL
                                                      GROUP BY ctipcon, nvalcon, cfracci,
                                                               cbonifi, crecfra, cconcep,
                                                               nconcep, cempres, finivig,
                                                               climite,   -- Bug 10864:NMM:01/08/2009:
                                                                       cmoneda,
                                                               cderreg   -- Bug 0020314 - FAL - 29/11/2011
                                                                      ;
                                                   EXCEPTION
                                                      WHEN NO_DATA_FOUND THEN
                                                         RETURN 152821;
                                                      WHEN OTHERS THEN
                                                         p_tab_error(f_sysdate(), f_user(),
                                                                     'f_concepto', 1,
                                                                     TO_CHAR(SQLCODE),
                                                                     SUBSTR(vparamin
                                                                            || SQLERRM,
                                                                            1, 2500));
                                                         RETURN 152821;
                                                   END;   -- cramo=0
                                                WHEN OTHERS THEN
                                                   p_tab_error(f_sysdate(), f_user(),
                                                               'f_concepto', 2,
                                                               TO_CHAR(SQLCODE),
                                                               SUBSTR(vparamin || SQLERRM, 1,
                                                                      2500));
                                                   RETURN 152821;
                                             END;   -- pcramo
                                          WHEN OTHERS THEN
                                             p_tab_error(f_sysdate(), f_user(), 'f_concepto',
                                                         3, TO_CHAR(SQLCODE),
                                                         SUBSTR(vparamin || SQLERRM, 1, 2500));
                                             RETURN 152821;
                                       END;   -- pcmodali
                                    WHEN OTHERS THEN
                                       p_tab_error(f_sysdate(), f_user(), 'f_concepto', 4,
                                                   TO_CHAR(SQLCODE),
                                                   SUBSTR(vparamin || SQLERRM, 1, 2500));
                                       RETURN 152821;
                                 END;   -- pctipseg
                              WHEN OTHERS THEN
                                 p_tab_error(f_sysdate(), f_user(), 'f_concepto', 5,
                                             TO_CHAR(SQLCODE),
                                             SUBSTR(vparamin || SQLERRM, 1, 2500));
                                 RETURN 152821;
                           END;   -- pccolect
                        WHEN OTHERS THEN
                           p_tab_error(f_sysdate(), f_user(), 'f_concepto', 6,
                                       TO_CHAR(SQLCODE), SUBSTR(vparamin || SQLERRM, 1, 2500));
                           RETURN 152821;
                     END;   -- cactivi=0
                  WHEN OTHERS THEN
                     p_tab_error(f_sysdate(), f_user(), 'f_concepto', 7, TO_CHAR(SQLCODE),
                                 SUBSTR(vparamin || SQLERRM, 1, 2500));
                     RETURN 152821;
               END;   -- pcactivi
            WHEN OTHERS THEN
               p_tab_error(f_sysdate(), f_user(), 'f_concepto', 8, TO_CHAR(SQLCODE),
                           SUBSTR(vparamin || SQLERRM, 1, 2500));
               RETURN 152821;
         END;   -- cactivi=0, pcgarant
      WHEN OTHERS THEN
         p_tab_error(f_sysdate(), f_user(), 'f_concepto', 9, TO_CHAR(SQLCODE),
                     SUBSTR(vparamin || SQLERRM, 1, 2500));
         RETURN 152821;
   END;   -- pcactivi, pcgarant

   p_cmoneda := NVL(p_cmoneda, pac_parametros.f_parempresa_n(pcempres, 'MONEDAEMP'));
   RETURN(0);
EXCEPTION
   WHEN OTHERS THEN
      p_tab_error(f_sysdate(), f_user(), 'f_concepto', 10, TO_CHAR(SQLCODE),
                  SUBSTR(vparamin || SQLERRM, 1, 2500));
      RETURN 152820;   -- Error en la función f_concepto
END f_concepto;

/

  GRANT EXECUTE ON "AXIS"."F_CONCEPTO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_CONCEPTO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_CONCEPTO" TO "PROGRAMADORESCSI";
