--------------------------------------------------------
--  DDL for Function F_FECHAINIFIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_FECHAINIFIN" (
   wseguro IN NUMBER,
   wfecha IN DATE,
   wfvencim IN DATE,
   wfcaranu IN DATE,
   wffinal OUT DATE,
   wfefeini OUT DATE,
   wprorrata OUT NUMBER,
   wcmodcom OUT NUMBER)
   RETURN NUMBER AUTHID CURRENT_USER IS
/******************************************************************************
   NOMBRE:       f_fechainifin
   PROPÓSITO:

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0                                     1. Creación de la función.
   2.0        04/11/2009   FAL             2. 0011497: CRE - Optimizar el cierre de provisiones. Que solo coja el recibo del certificado 0
   3.0        13/01/2010   JGR             3. 12539 - Errores en el cierre de provisiones de Diciembre (AXIS1501)
   4.0        28/10/2010   JGR             4. 16329 - CRE800 - Revisió processos de tancament
   5.0        19/12/2011   APD             5. 0020384: LCOL_C001: Ajuste de comisiones para los cierres
******************************************************************************/
   wnmovimi       NUMBER;
   wfcaranu_aux   DATE;
   wdias          NUMBER;
   num_err        NUMBER := 0;
   vproduc        seguros.sproduc%TYPE;
-- BUG 12539 - 13/01/2010 - JGR - Errores en el cierre de provisiones de Diciembre (AXIS1501)
   vfcarant       seguros.fcarant%TYPE;
   vfcarpro       seguros.fcarpro%TYPE;
-- Fi BUG 12539 - 13/01/2010 - JGR
   bfraccionario  NUMBER(1) := NULL;
   --Bug.: 21715 - 21/03/2012 - ICV
   v_dias_pror    NUMBER := 0;
   vcempres       NUMBER;
BEGIN
   wprorrata := 1;

   BEGIN
      --JGM - 18/09/2008 ---------------------------------------------------------
      SELECT sproduc, NVL(fcarant, fefecto),   -- BUG 12539 - 13/01/2010 - JGR - Errores en el cierre de provisiones de Diciembre (AXIS1501)
                                            fcarpro,
             cempres   -- BUG 12539 - 13/01/2010 - JGR - Errores en el cierre de provisiones de Diciembre (AXIS1501)
        INTO vproduc, vfcarant,   -- BUG 12539 - 13/01/2010 - JGR - Errores en el cierre de provisiones de Diciembre (AXIS1501)
                               vfcarpro,
             vcempres   -- BUG 12539 - 13/01/2010 - JGR - Errores en el cierre de provisiones de Diciembre (AXIS1501)
        FROM seguros
       WHERE sseguro = wseguro;

      num_err := f_parproductos(vproduc, 'FRACCIONARIO', bfraccionario);

      IF num_err <> 0 THEN
         RETURN(104349);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN(104349);
   END;

   IF NVL(bfraccionario, 0) <> 1 THEN
-----fi jgm ------------------------------------------------------
      BEGIN
         SELECT m.fefecto, m.nmovimi, DECODE(m.cmovseg, 0, 1, 2)
           INTO wfefeini, wnmovimi, wcmodcom
           FROM movseguro m
          WHERE m.sseguro = wseguro
            --AND m.fefecto = (SELECT MAX(t.fefecto) -- BUG 12539 - 13/01/2010 - JGR - sustituido por NMOVIMI para evitar duplicados
            AND m.nmovimi =   -- BUG 12539 - 13/01/2010 - JGR - Errores en el cierre de provisiones de Diciembre (AXIS1501)
                  (SELECT MAX
                             (t.nmovimi)   -- BUG 12539 - 13/01/2010 - JGR - Errores en el cierre de provisiones de Diciembre (AXIS1501)
                     FROM movseguro t
                    WHERE t.sseguro = m.sseguro
                      AND(t.cmovseg = 0
                          OR t.cmotmov IN(404, 406))   -- BUG 20384 - APD - 19/12/2011
                      AND t.fefecto <= wfecha)
            AND m.cmovseg IN(2, 0);
      EXCEPTION
         WHEN OTHERS THEN
            RETURN(104349);
      END;

      IF wfcaranu IS NOT NULL THEN
         BEGIN
            SELECT MIN(fefecto)
              INTO wfcaranu_aux
              FROM movseguro
             WHERE sseguro = wseguro
               AND nmovimi > wnmovimi
               AND cmovseg = 2;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               wfcaranu_aux := NULL;
            WHEN OTHERS THEN
               RETURN(104349);
         END;

         IF wfcaranu_aux IS NULL THEN
            wfcaranu_aux := wfcaranu;
         END IF;

         wffinal := wfcaranu_aux;

         IF wffinal != ADD_MONTHS(wfefeini, 12) THEN
            num_err := f_difdata(wfefeini, wfcaranu_aux, 3, 3, wdias);

            IF num_err != 0 THEN
               RETURN(num_err);
            END IF;

            --Bug.: 21715 - 21/03/2012 - ICV
            IF NVL(pac_parametros.f_parempresa_n(vcempres, 'DIAS_PROR_REAL'), 0) = 0 THEN
               v_dias_pror := 360;
            ELSE
               --Dias reales de la anualidad
               --el mod 4 solo no sirve para saber si es bisiesto, lo más facil es restar fechas del año
               v_dias_pror := TO_DATE('3112' || TO_CHAR(wfefeini, 'yyyy'), 'ddmmyyyy')
                              - TO_DATE('0101' || TO_CHAR(wfefeini, 'yyyy'), 'ddmmyyyy') + 1;
            END IF;

            wprorrata := wdias / v_dias_pror;
         END IF;
      ELSE
         wffinal := wfvencim;
      END IF;
   ------------ JGM - 18/09/2008 - si producto fraccionario ----
   ELSE
      BEGIN
         -- SELECT DISTINCT r.fefecto, r.fvencim - 1, 1   -- BUG 13564 09/03/2010 ASN
         --Cuando mira si el recibo está anulado, miremos que el fmovdia sea menor o igual que wfecha
         --b) realizar una join con movrecibo y recibos para que sólo seleccione los fmovdia sea menor o igual que wfecha. --BUG 41012 05/04/2016 JAJIMENEZ
         SELECT   MAX(r.fefecto), MAX(r.fvencim) - 1,
                  DECODE
                     (f_es_renova(sseguro, wfecha),
                      0, 2,
                      1)   -- JGR 4. 16329  - CRE800 - Revisió processos de tancament
             INTO wfefeini, wffinal,
                  wcmodcom
             FROM recibos r, movrecibo m
            WHERE r.nrecibo = m.nrecibo
              AND r.sseguro = wseguro
              AND r.ctiprec <> 5
              AND r.fefecto <= wfecha
              AND r.fvencim >= wfecha
              AND m.fmovdia <= wfecha
              -- AND r.esccero = 0 -- BUG 13564 09/03/2010 ASN
              AND NOT EXISTS(SELECT nrecibo
                               FROM movrecibo
                              WHERE nrecibo = r.nrecibo
                                AND fmovini <= wfecha
                                AND fmovfin IS NULL
                                AND fmovdia <= wfecha
                                AND cestrec = 2)
         GROUP BY DECODE(f_es_renova(sseguro, wfecha), 0, 2, 1);   -- BUG 20384 - APD - 09/01/2012
      EXCEPTION
         WHEN OTHERS THEN
            -- BUG 12539 - 13/01/2010 - JGR - Errores en el cierre de provisiones de Diciembre (AXIS1501)
            IF vfcarant IS NOT NULL
               AND vfcarpro IS NOT NULL THEN
               wfefeini := ADD_MONTHS(wfecha + 1, -1);
               wffinal := wfecha;

               -- BUG 20384 - APD - 19/12/2011
               IF f_es_renova(wseguro, wfecha) = 0 THEN
                  wcmodcom := 2;
               ELSE
                  wcmodcom := 1;
               END IF;
            -- fin BUG 20384 - APD - 19/12/2011
            ELSE
               RETURN(141069);   -- Error al buscar la fecha de cartera.
            END IF;
      -- Fi BUG 12539 - 13/01/2010 - JGR
      END;

      IF wffinal + 1 != ADD_MONTHS(wfefeini, 12) THEN   -- JGR 4. 16329   - CRE800 - Revisió processos de tancament
         num_err := f_difdata(wfefeini, wffinal, 3, 3, wdias);

         IF num_err != 0 THEN
            RETURN(num_err);
         END IF;

         --Bug.: 21715 - 21/03/2012 - ICV
         IF NVL(pac_parametros.f_parempresa_n(vcempres, 'DIAS_PROR_REAL'), 0) = 0 THEN
            v_dias_pror := 360;
         ELSE
            --Dias reales de la anualidad
            --el mod 4 solo no sirve para saber si es bisiesto, lo más facil es restar fechas del año
            v_dias_pror := TO_DATE('3112' || TO_CHAR(wfefeini, 'yyyy'), 'ddmmyyyy')
                           - TO_DATE('0101' || TO_CHAR(wfefeini, 'yyyy'), 'ddmmyyyy') + 1;
         END IF;

         wprorrata := wdias / v_dias_pror;
      END IF;
   END IF;

-----fi jgm ------------------------------------------------------
   RETURN(num_err);
END f_fechainifin;

/

  GRANT EXECUTE ON "AXIS"."F_FECHAINIFIN" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_FECHAINIFIN" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_FECHAINIFIN" TO "PROGRAMADORESCSI";
