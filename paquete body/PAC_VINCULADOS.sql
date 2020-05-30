--------------------------------------------------------
--  DDL for Package Body PAC_VINCULADOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_VINCULADOS" IS
   /*****************************************************************************
      NAME:       pac_vinculados
      PURPOSE:

      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      1.0        XX/XX/XXXX   XXX             1. Creación del package.
      2.0        21/10/2009   APD             2. Bug 0011301: CRE080 - FOREIGNS DE PRESTAMOSEG
   *****************************************************************************/
   FUNCTION f_cap_prestcuadroseg(
      p_in_sseguro IN prestcuadroseg.sseguro%TYPE,
      p_in_fecha IN prestcuadroseg.fefecto%TYPE,
      p_in_nmovimi IN prestcuadroseg.nmovimi%TYPE DEFAULT NULL)
      RETURN prestcuadroseg.icappend%TYPE IS
--- Devolverá el capital pendiente en dicho intervalo asociado al seguro indicado
--
--- Selecciona alquel cuadro cuintervalo cuyo intervalo incluye la fecha pedida (FINICUASEG -- FFINCUASEG)
---- Y dentro del cuadro, seleecona el capital pendiente cuya fecha efecto sea la máxima que cumpla:
---   fefecto <= p_in_fecha
--
-- Si p_in_fecha NULA, selecciona la fecha del sistema (fecha actual)
      w_ret_icappend prestcuadroseg.icappend%TYPE;
   BEGIN
      w_ret_icappend := NULL;

      SELECT pcs.icappend
        INTO w_ret_icappend
        FROM prestcuadroseg pcs
       WHERE pcs.sseguro = p_in_sseguro
         AND(pcs.finicuaseg, pcs.nmovimi) = (SELECT MAX(pcsx.finicuaseg), MAX(pcsx.nmovimi)
                                               FROM prestcuadroseg pcsx
                                              WHERE pcsx.sseguro = pcs.sseguro
                                                AND pcsx.finicuaseg <=
                                                                     NVL(p_in_fecha, f_sysdate)
                                                AND pcsx.nmovimi =
                                                                NVL(p_in_nmovimi, pcsx.nmovimi))
         AND pcs.fefecto = (SELECT MAX(pcsy.fefecto)
                              FROM prestcuadroseg pcsy
                             WHERE pcsy.sseguro = pcs.sseguro
                               AND pcsy.fefecto <= NVL(p_in_fecha, f_sysdate)
                               AND pcs.nmovimi = pcsy.nmovimi);

      RETURN w_ret_icappend;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN w_ret_icappend;
   END f_cap_prestcuadroseg;

   FUNCTION f_insertar_cuadro(
      ptablas IN VARCHAR2,
      psproces IN NUMBER,
      psseguro IN NUMBER,
      pfecha IN DATE)
      RETURN NUMBER IS
/******************************************************************************

 ******************************************************************************/
      v_ctapres      VARCHAR2(20);
      v_icapital_ini NUMBER;
      v_primera_fecha DATE;
      v_ultima_fecha DATE;
      -- v_finicial          date;
      v_primera_fin  DATE;
      fecha_ini      DATE;
      fecha_fin      DATE;
      v_nmovimi      NUMBER;
      v_icapital     NUMBER;
      v_iinteres     NUMBER;
      v_icappend     NUMBER;
      v_icappend_nou NUMBER;
      v_fvencim      DATE;
      v_pporcen      NUMBER;
      v_fefepol      DATE;
      v_fvencimpol   DATE;
      sup_fvencim    DATE;
      cont           NUMBER;
      v_falta        DATE;   -- Bug 11301 - APD - 21/10/2009
   BEGIN
      IF ptablas <> 'SOL' THEN
         --p_yil_error(null, 'tar', 'entramos cuadro');
         DELETE FROM estprestcuadroseg
               WHERE sseguro = psseguro;

         --p_yil_error(null, 'cuadro', 'antes select');
         SELECT MAX(nmovi_ant)
           INTO v_nmovimi
           FROM tmp_garancar
          WHERE sseguro = psseguro
            AND sproces = psproces;

         --p_yil_error(null, 'cuadro', 'nmovimi = '||v_nmovimi);
         IF v_nmovimi IS NULL THEN
            p_tab_error(f_sysdate, f_user, 'pac_vinculados.f_insertar_cuadro', 1,
                        'v_nmovimi is null',
                        'SSEGURO =' || psseguro || ' PFECHA=' || pfecha || ' ptablas = '
                        || ptablas || ' sproces =' || psproces);
            RETURN 103502;   -- error al leer de garancar
         END IF;

         -- Bug 11301 - APD - 21/10/2009 - se añade la union ps.falta = pr.falta
         -- y se añade en la select la columna ps.falta
         BEGIN
            SELECT s.fefecto, s.fvencim, pr.ctapres, ps.icapini * pporcen / 100, pr.pporcen,
                   ps.falta
              INTO v_fefepol, v_fvencimpol, v_ctapres, v_icapital_ini, v_pporcen,
                   v_falta
              FROM estseguros s, estprestamoseg pr, prestamos ps
             WHERE s.sseguro = psseguro
               AND s.sseguro = pr.sseguro
               AND ffinprest IS NULL
               AND ps.ctapres = pr.ctapres
               AND ps.falta = pr.falta;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'pac_vinculados.f_insertar_cuadro', 2,
                           'error al leer de seguros SSEGURO =' || psseguro || ' PFECHA='
                           || pfecha || ' ptablas = ' || ptablas || ' sproces =' || psproces,
                           SQLERRM);
               RETURN 101919;   -- error al leer de la tabla estseguros
         END;

         SELECT MIN(fvencim)
           INTO v_primera_fecha
           FROM prestcuadro pp
          WHERE pp.ctapres = v_ctapres
            AND pp.ffincua IS NULL
            AND pp.fvencim <= pfecha;

         IF v_nmovimi > 1 THEN   -- estamos en un suplemento
            SELECT MIN(fvencim)
              INTO sup_fvencim
              FROM prestcuadroseg
             WHERE sseguro = (SELECT ssegpol
                                FROM estseguros
                               WHERE sseguro = psseguro)
               AND fvencim > pfecha;
         END IF;

         --p_yil_error(null, 'cuadro', 'sup_fvencim ='||sup_fvencim);
         v_ultima_fecha := v_fvencimpol;

         --p_yil_error(null, 'cuadro', 'PRIMERA FECHA ='||V_PRIMERA_FECHA);
         IF v_primera_fecha IS NULL THEN   -- la fecha inicial es menor al primer vencimiento
            --p_yil_error(null, 'cuadro', 'PRIMER REGISTRO');
            fecha_ini := pfecha;
            fecha_fin := LEAST(NVL(sup_fvencim, ADD_MONTHS(fecha_ini, 12)), v_ultima_fecha);
            --p_yil_error(null, 'cuadro', 'fecha fin ='||fecha_fin);
            v_icappend := v_icapital_ini;

            -- Bug 11301 - APD - 21/10/2009 - se añade la columna FALTA en el insert
            INSERT INTO estprestcuadroseg
                        (ctapres, sseguro, nmovimi, finicuaseg, ffincuaseg, fefecto, fvencim,
                         icapital, iinteres, icappend, falta)
                 VALUES (v_ctapres, psseguro, v_nmovimi, pfecha, NULL, fecha_ini, fecha_fin,
                         0, 0, v_icappend, v_falta);

            fecha_ini := fecha_fin;
            cont := 1;
         --p_yil_error(null, 'cuadro', 'fecha_fin ='||fecha_fin);
         ELSE
            -- fecha_ant :=
            fecha_ini := pfecha;
            fecha_fin := LEAST(NVL(sup_fvencim, ADD_MONTHS(fecha_ini, 12)), v_ultima_fecha);

            IF fecha_fin = v_ultima_fecha THEN
               v_icappend := v_icapital_ini;

               -- Bug 11301 - APD - 21/10/2009 - se añade la columna FALTA en el insert
               INSERT INTO estprestcuadroseg
                           (ctapres, sseguro, nmovimi, finicuaseg, ffincuaseg, fefecto,
                            fvencim, icapital, iinteres, icappend, falta)
                    VALUES (v_ctapres, psseguro, v_nmovimi, pfecha, NULL, fecha_ini,
                            fecha_fin, 0, 0, v_icappend, v_falta);
            END IF;

            cont := 0;
         END IF;

         WHILE fecha_fin < v_ultima_fecha LOOP
            IF cont > 0 THEN
               --p_yil_error(null, 'cuadro', 'ENTRAMOS EN LOOP');
               fecha_fin := LEAST(ADD_MONTHS(fecha_ini, 12), v_ultima_fecha);
            END IF;

            BEGIN
               -- Bug 11301 - APD - 21/10/2009 - se añade en la select la columna ps.falta
               SELECT MAX(icapital * v_pporcen / 100), MAX(iinteres * v_pporcen / 100),
                      MIN(icappend * v_pporcen / 100), MAX(fvencim), falta
                 INTO v_icapital, v_iinteres,
                      v_icappend_nou, v_fvencim, v_falta
                 FROM prestcuadro
                WHERE ctapres = v_ctapres
                  AND ffincua IS NULL
                  AND fvencim = (SELECT MAX(fvencim)
                                   FROM prestcuadro
                                  WHERE ctapres = v_ctapres
                                    AND ffincua IS NULL
                                    AND fvencim <= fecha_ini);

               IF v_fvencim IS NULL THEN
                  v_icapital := 0;
                  v_iinteres := 0;
               ELSE
                  v_icappend := v_icappend_nou;
               END IF;
            END;

            -- Bug 11301 - APD - 21/10/2009 - se añade la columna FALTA en el insert
            INSERT INTO estprestcuadroseg
                        (ctapres, sseguro, nmovimi, finicuaseg, ffincuaseg, fefecto, fvencim,
                         icapital, iinteres, icappend, falta)
                 VALUES (v_ctapres, psseguro, v_nmovimi, pfecha, NULL, fecha_ini, fecha_fin,
                         v_icapital, v_iinteres, v_icappend, v_falta);

            --p_yil_error(null, 'cuadro', 'DESPUES INSERT');
            fecha_ini := fecha_fin;
            cont := cont + 1;
         END LOOP;

         COMMIT;
      ELSE   -- Añadido para el caso de simulacion.
         DELETE FROM solprestcuadroseg
               WHERE ssolici = psseguro;

         BEGIN
            SELECT s.falta, s.fvencim, ps.icapital * pporcen / 100, pporcen
              INTO v_fefepol, v_fvencimpol, v_icapital_ini, v_pporcen
              FROM solseguros s, solprestamos ps
             WHERE s.ssolicit = psseguro
               AND s.ssolicit = ps.ssolici;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'pac_vinculados.f_insertar_cuadro', 2,
                           'error al leer de seguros SSEGURO =' || psseguro || ' PFECHA='
                           || pfecha || ' ptablas = ' || ptablas || ' sproces =' || psproces,
                           SQLERRM);
               RETURN 101919;   -- error al leer de la tabla estseguros
         END;

         SELECT MIN(fvencim)
           INTO v_primera_fecha
           FROM solprestcuadro
          WHERE ssolici = psseguro
            AND fvencim <= pfecha;

         v_ultima_fecha := v_fvencimpol;

         IF v_primera_fecha IS NULL THEN   -- la fecha inicial es menor al primer vencimiento
            fecha_ini := pfecha;
            fecha_fin := LEAST(ADD_MONTHS(fecha_ini, 12), v_ultima_fecha);
            v_icappend := v_icapital_ini;

            INSERT INTO solprestcuadroseg
                        (ssolici, fefecto, fvencim, icapital, icappend)
                 VALUES (psseguro, fecha_ini, fecha_fin, 0, v_icappend);

            --p_yil_error(null, 'cuadro', '1er insert v_primera_fecha nula');
            fecha_ini := fecha_fin;
            cont := 1;
         ELSE
            fecha_ini := pfecha;
            fecha_fin := LEAST(ADD_MONTHS(fecha_ini, 12), v_ultima_fecha);

            IF fecha_fin = v_ultima_fecha THEN
               v_icappend := v_icapital_ini;

               INSERT INTO solprestcuadroseg
                           (ssolici, fefecto, fvencim, icapital, icappend)
                    VALUES (psseguro, fecha_ini, fecha_fin, 0, v_icappend);
            --p_yil_error(null, 'cuadro', '1er insert fecha_fin = v_ultima_ficha');
            END IF;

            cont := 0;
         END IF;

         WHILE fecha_fin < v_ultima_fecha LOOP
            IF cont > 0 THEN
               fecha_fin := LEAST(ADD_MONTHS(fecha_ini, 12), v_ultima_fecha);
            END IF;

            BEGIN
               SELECT MAX(icapital * v_pporcen / 100), MIN(icapend * v_pporcen / 100),
                      MAX(fvencim)
                 INTO v_icapital, v_icappend_nou,
                      v_fvencim
                 FROM solprestcuadro
                WHERE ssolici = psseguro
                  AND fvencim = (SELECT MAX(fvencim)
                                   FROM solprestcuadro
                                  WHERE ssolici = psseguro
                                    AND fvencim <= fecha_ini);

               --p_yil_error(null, 'cuadro', 'psseguro='||to_char(psseguro));
                  --p_yil_error(null, 'cuadro', 'fecha_ini='||to_char(fecha_ini,'yyyymmdd'));
               --p_yil_error(null, 'cuadro', 'v_pporcen='||to_char(v_pporcen));
               IF v_fvencim IS NULL THEN
                  v_icapital := 0;
                  v_iinteres := 0;
               ELSE
                  v_icappend := v_icappend_nou;
               END IF;
            END;

            INSERT INTO solprestcuadroseg
                        (ssolici, fefecto, fvencim, icapital, icappend)
                 VALUES (psseguro, fecha_ini, fecha_fin, v_icapital, v_icappend);

            fecha_ini := fecha_fin;
            cont := cont + 1;
         END LOOP;

         COMMIT;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_vinculados.f_insertar_cuadro', 4,
                     'when others SSEGURO =' || psseguro || ' PFECHA=' || pfecha
                     || ' ptablas = ' || ptablas || ' sproces =' || psproces,
                     SQLERRM);
--p_yil_error(null, 'tar', 'others '||sqlerrm);
         RETURN 151589;   -- error al insertar elcuadro de amortización
   END f_insertar_cuadro;
END pac_vinculados;

/

  GRANT EXECUTE ON "AXIS"."PAC_VINCULADOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_VINCULADOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_VINCULADOS" TO "PROGRAMADORESCSI";
