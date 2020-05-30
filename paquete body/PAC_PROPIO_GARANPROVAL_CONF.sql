/* Formatted on 2020/04/27 16:15 (Formatter Plus v4.8.8) */
--------------------------------------------------------
--  DDL for Package Body PAC_PROPIO_GARANPROVAL_CONF
--------------------------------------------------------

CREATE OR REPLACE PACKAGE BODY pac_propio_garanproval_conf
IS
/******************************************************************************
   NOMBRE    : PAC_PROPIO_GARANPROVAL_CONF
   ARCHIVO   : PAC_PROPIO_GARANPROVAL_CNF.PKB
   PROPÓSITO : Package con funciones propias de la funcionalidad de
                Avisos de CONF.

   REVISIONES:
   Ver    Fecha      Autor     Descripción
   ------ ---------- --------- ------------------------------------------------
   1.0    02-09-2016 LPASTOR   Creación del package.
                               Creación de función F_VAL_CAPMIN
   2.0     06/07/2019    ECP   IAIS-3628 . Nota Técnica
   3.0    05/08/2019    CJMR   IAXIS-4200: Validación de preguntas
   4.0    27/04/2020    ECP    IAXIS-3394   Traslado de Vigencia    
   5.0    27/05/2020    ECP    IAXIS-13888. Gestión Agenda.
   ******************************************************************************/
   FUNCTION f_val_capmin (
      ptablas    IN   VARCHAR2,
      psseguro   IN   NUMBER,
      pnriesgo   IN   NUMBER,
      pnmovimi   IN   NUMBER,
      pcgarant   IN   NUMBER,
      pcactivi   IN   NUMBER,
      pcgardep   IN   NUMBER,
      pporcent   IN   NUMBER
   )
      RETURN NUMBER
   IS
      nicapital   NUMBER;
      nicapmin    NUMBER;
      vnumerr     NUMBER;
      vpasexec    NUMBER (8)     := 1;
      vparam      VARCHAR2 (200)
         :=    'ptablas= '
            || ptablas
            || ' psseguro= '
            || psseguro
            || ' pnriesgo= '
            || pnriesgo
            || 'pnmovimi= '
            || pnmovimi
            || 'pcgarant= '
            || pcgarant
            || 'pcactivi= '
            || pcactivi;
      vobject     VARCHAR2 (200) := 'pac_propio_garanproval_conf.f_val_capmin';
   BEGIN
      --Buscamos el capital de la garantia que queremos validar (pcgarant)
      --y calculamos el porcentaje del capital de la que depende (pcgardep)
      IF ptablas = 'EST'
      THEN
         SELECT icapital
           INTO nicapital
           FROM estgaranseg
          WHERE sseguro = psseguro
            AND nmovimi = pnmovimi
            AND nriesgo = pnriesgo
            AND cgarant = pcgarant;

         SELECT icapital * NVL (pporcent, 100) / 100
           INTO nicapmin
           FROM estgaranseg
          WHERE sseguro = psseguro
            AND nmovimi = pnmovimi
            AND nriesgo = pnriesgo
            AND cgarant = pcgardep;
      ELSE
         SELECT icapital
           INTO nicapital
           FROM garanseg
          WHERE sseguro = psseguro
            AND nmovimi = pnmovimi
            AND nriesgo = pnriesgo
            AND cgarant = pcgarant;

         SELECT icapital * NVL (pporcent, 100) / 100
           INTO nicapmin
           FROM garanseg
          WHERE sseguro = psseguro
            AND nmovimi = pnmovimi
            AND nriesgo = pnriesgo
            AND cgarant = pcgardep;
      END IF;

      --Si el capital puesto es inferior al porcentaje mínimo de la garantía de la cual depende, devolvemos error
      IF nicapital < nicapmin
      THEN
         RETURN 9905720;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         p_tab_error (f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 140999;                                -- Error no controlado
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                      f_axis_literales (SQLCODE)
                     );
         RETURN vnumerr;
   END f_val_capmin;

   FUNCTION f_val_capmax (
      ptablas    IN   VARCHAR2,
      psseguro   IN   NUMBER,
      pnriesgo   IN   NUMBER,
      pnmovimi   IN   NUMBER,
      pcgarant   IN   NUMBER,
      pcactivi   IN   NUMBER,
      pcgardep   IN   NUMBER,
      pporcent   IN   NUMBER
   )
      RETURN NUMBER
   IS
      nicapital   NUMBER;
      nicapmax    NUMBER;
      vnumerr     NUMBER;
      vpasexec    NUMBER (8)     := 1;
      vparam      VARCHAR2 (200)
         :=    'ptablas= '
            || ptablas
            || ' psseguro= '
            || psseguro
            || ' pnriesgo= '
            || pnriesgo
            || 'pnmovimi= '
            || pnmovimi
            || 'pcgarant= '
            || pcgarant
            || 'pcactivi= '
            || pcactivi;
      vobject     VARCHAR2 (200) := 'pac_propio_garanproval_conf.f_val_capmax';
   BEGIN
      IF NOT (    pac_iax_produccion.issuplem
              AND pac_iax_suplementos.lstmotmov (1).cmotmov = 918
             )
      THEN                                        --IAXIS-4205 CJMR 12/08/2019
         --Buscamos el capital de la garantia que queremos validar (pcgarant)
         --y calculamos el porcentaje del capital de la que depende (pcgardep)
         IF ptablas = 'EST'
         THEN
            SELECT icapital
              INTO nicapital
              FROM estgaranseg
             WHERE sseguro = psseguro
               AND nmovimi = pnmovimi
               AND nriesgo = pnriesgo
               AND cgarant = pcgarant;

            SELECT icapital * NVL (pporcent, 100) / 100
              INTO nicapmax
              FROM estgaranseg
             WHERE sseguro = psseguro
               AND nmovimi = pnmovimi
               AND nriesgo = pnriesgo
               AND (   (    cgarant IN (7758, 7759, 7760, 7761)
                        AND pcgardep = -8064
                        AND icapital IS NOT NULL
                       )
                    OR cgarant = pcgardep
                   );
         ELSE
            SELECT icapital
              INTO nicapital
              FROM garanseg
             WHERE sseguro = psseguro
               AND nmovimi = pnmovimi
               AND nriesgo = pnriesgo
               AND cgarant = pcgarant;

            SELECT icapital * NVL (pporcent, 100) / 100
              INTO nicapmax
              FROM garanseg
             WHERE sseguro = psseguro
               AND nmovimi = pnmovimi
               AND nriesgo = pnriesgo
               AND (   (    cgarant IN (7758, 7759, 7760, 7761)
                        AND pcgardep = -8064
                        AND icapital IS NOT NULL
                       )
                    OR cgarant = pcgardep
                   );
         END IF;

         --Si el capital puesto es inferior al porcentaje mínimo de la garantía de la cual depende, devolvemos error
         IF nicapital > nicapmax
         THEN
            RETURN 110199;
         END IF;
      END IF;                                     --IAXIS-4205 CJMR 12/08/2019

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         p_tab_error (f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 140999;                                -- Error no controlado
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                      f_axis_literales (SQLCODE)
                     );
         RETURN vnumerr;
   END f_val_capmax;

   FUNCTION f_salario_min_legal_vigente (
      ptablas     IN   VARCHAR2,
      psseguro    IN   NUMBER,
      pnriesgo    IN   NUMBER,
      pfefecto    IN   DATE,
      pnmovimi    IN   NUMBER,
      pcgarant    IN   NUMBER,
      psproces    IN   NUMBER,
      pnmovima    IN   NUMBER,
      picapital   IN   NUMBER
   )
      RETURN NUMBER
   IS
      vsproduc        NUMBER;
      vobj            VARCHAR2 (200)
                       := 'pac_propio_albsgt_pos.f_salario_min_legal_vigente';
      vpar            VARCHAR2 (1000)
         := SUBSTR (   ' - ptablas  '
                    || ptablas
                    || ' - psseguro '
                    || psseguro
                    || ' - pnriesgo '
                    || pnriesgo
                    || ' - pfefecto '
                    || pfefecto
                    || ' - pnmovimi '
                    || pnmovimi
                    || ' - pcgarant '
                    || pcgarant
                    || ' - psproces '
                    || psproces
                    || ' - pnmovima '
                    || pnmovima
                    || ' - picapital '
                    || picapital,
                    1,
                    1000
                   );
      vmonedaseguro   VARCHAR2 (3);
      vismlv          NUMBER;
   BEGIN
      p_control_error ('LPP', 'SALARIO=', 1);

      IF ptablas = 'EST'
      THEN
         SELECT sproduc
           INTO vsproduc
           FROM estseguros s
          WHERE s.sseguro = psseguro;
      ELSE
         SELECT sproduc
           INTO vsproduc
           FROM seguros s
          WHERE s.sseguro = psseguro;
      END IF;

      vmonedaseguro :=
         NVL (pac_monedas.f_moneda_seguro_char (NVL (ptablas, 'SEG'),
                                                psseguro),
              pac_monedas.f_moneda_producto_char (vsproduc)
             );
      vismlv :=
         pac_eco_tipocambio.f_importe_cambio
                       ('SMV',
                        vmonedaseguro,
                        pac_eco_tipocambio.f_fecha_max_cambio ('SMV',
                                                               vmonedaseguro,
                                                               pfefecto
                                                              ),
                        1
                       );
      p_control_error ('LPP', 'SALARIO=', 2);
      RETURN 689454;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate, f_user, vobj, 99, vpar, SQLERRM);
         RETURN NULL;
   END f_salario_min_legal_vigente;

   FUNCTION f_val_preg_incom (
      ptablas    IN   VARCHAR2,
      psseguro   IN   NUMBER,
      pnriesgo   IN   NUMBER,
      pnmovimi   IN   NUMBER,
      pcgarant   IN   NUMBER,
      pcactivi   IN   NUMBER,
      ppreginc   IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      n_cont   NUMBER          := 0;
      vobj     VARCHAR2 (200)  := 'pac_propio_albsgt_pos.f_val_preg_incom';
      vpar     VARCHAR2 (1000)
         := SUBSTR (   ' - ptablas  '
                    || ptablas
                    || ' - psseguro '
                    || psseguro
                    || ' - pnriesgo '
                    || pnriesgo
                    || ' - pnmovimi '
                    || pnmovimi
                    || ' - pcgarant '
                    || pcgarant,
                    1,
                    1000
                   );
   BEGIN
      IF ptablas = 'EST'
      THEN
         --Solo validaremos cuando está seleccionada la garantía
         SELECT COUNT (*)
           INTO n_cont
           FROM estgaranseg
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND cgarant = pcgarant
            AND cobliga = 1;

         IF n_cont > 0
         THEN
            SELECT COUNT (*)
              INTO n_cont
              FROM estpregungaranseg
             WHERE sseguro = psseguro
               AND nmovimi = pnmovimi
               AND nriesgo = pnriesgo
               AND cgarant = pcgarant
               AND crespue IS NOT NULL
               AND (   (    cpregun IN (2892, 2893, 4212, 4965)
                        AND ppreginc IS NULL
                       )
                    OR (cpregun IN (4211, 4965) AND ppreginc = 4211)
                   );
         ELSE
            RETURN 0;
         END IF;
      ELSE
         SELECT COUNT (*)
           INTO n_cont
           FROM pregungaranseg
          WHERE sseguro = psseguro
            AND nmovimi = pnmovimi
            AND nriesgo = pnriesgo
            AND cgarant = pcgarant
            AND crespue IS NOT NULL
            AND (   (cpregun IN (2892, 2893, 4212, 4965) AND ppreginc IS NULL
                    )
                 OR (cpregun IN (4211, 4965) AND ppreginc = 4211)
                );
      END IF;

      IF n_cont = 0 AND ppreginc IS NULL
      THEN
         RETURN 9910270;
      ELSIF n_cont > 1 AND ppreginc IS NULL
      THEN
         RETURN 9910019;
      ELSIF n_cont = 0 AND ppreginc = 4211
      THEN
         RETURN 9910469;
      ELSIF n_cont > 1 AND ppreginc = 4211
      THEN
         RETURN 9910470;
      ELSE
         RETURN 0;
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         p_tab_error (f_sysdate, f_user, vobj, 1, vpar, SQLERRM);
         RETURN 140999;                                -- Error no controlado
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobj,
                      2,
                      vpar,
                      f_axis_literales (SQLCODE)
                     );
         RETURN SQLCODE;
   END f_val_preg_incom;

   FUNCTION f_val_vigencia (
      ptablas    IN   VARCHAR2,
      psseguro   IN   NUMBER,
      pnriesgo   IN   NUMBER,
      pnmovimi   IN   NUMBER,
      pcgarant   IN   NUMBER,
      pcactivi   IN   NUMBER
   )
      RETURN NUMBER
   IS
      f_finivig   DATE;
      f_ffinvig   DATE;
      f_fefecto   DATE;
      f_fvencim   DATE;
      vobj        VARCHAR2 (200)  := 'pac_propio_albsgt_pos.f_val_vigencia';
      vpar        VARCHAR2 (1000)
         := SUBSTR (   ' - ptablas  '
                    || ptablas
                    || ' - psseguro '
                    || psseguro
                    || ' - pnriesgo '
                    || pnriesgo
                    || ' - pnmovimi '
                    || pnmovimi
                    || ' - pcgarant '
                    || pcgarant,
                    1,
                    1000
                   );
   BEGIN
      IF ptablas = 'EST'
      THEN
         SELECT fefecto, fvencim
           INTO f_fefecto, f_fvencim
           FROM estseguros
          WHERE sseguro = psseguro;

         BEGIN
            SELECT finivig, ffinvig
              INTO f_finivig, f_ffinvig
              FROM estgaranseg
             WHERE sseguro = psseguro AND cgarant = pcgarant AND cobliga = 1;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               --Si no está seleccionada, no validamos nada
               RETURN 0;
         END;
      ELSE
         SELECT fefecto, fvencim
           INTO f_fefecto, f_fvencim
           FROM seguros
          WHERE sseguro = psseguro;

         SELECT finivig, ffinvig
           INTO f_finivig, f_ffinvig
           FROM garanseg
          WHERE sseguro = psseguro AND cgarant = pcgarant;
      END IF;

      IF f_fefecto <> f_finivig OR f_fvencim <> f_ffinvig
      THEN
         RETURN 9910229;
      ELSE
         RETURN 0;
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         p_control_error ('LPP',
                          'pac_propio_garanproval_conf.f_val_vigencia1',
                          SQLERRM
                         );
         p_tab_error (f_sysdate, f_user, vobj, 1, vpar, SQLERRM);
         RETURN 140999;                                 -- Error no controlado
      WHEN OTHERS
      THEN
         p_control_error ('LPP',
                          'pac_propio_garanproval_conf.f_val_vigencia2',
                          SQLERRM
                         );
         p_tab_error (f_sysdate,
                      f_user,
                      vobj,
                      2,
                      vpar,
                      f_axis_literales (SQLCODE)
                     );
         RETURN SQLCODE;
   END f_val_vigencia;

   FUNCTION f_valida_dto (
      ptablas    IN   VARCHAR2,
      psseguro   IN   NUMBER,
      pnriesgo   IN   NUMBER,
      pnmovimi   IN   NUMBER,
      pcgarant   IN   NUMBER,
      pcactivi   IN   NUMBER
   )
      RETURN NUMBER
   IS
      vobj        VARCHAR2 (200)  := 'pac_propio_albsgt_pos.f_val_rec_tarif';
      vpar        VARCHAR2 (1000)
         := SUBSTR (   ' - ptablas  '
                    || ptablas
                    || ' - psseguro '
                    || psseguro
                    || ' - pnriesgo '
                    || pnriesgo
                    || ' - pnmovimi '
                    || pnmovimi
                    || ' - pcgarant '
                    || pcgarant,
                    1,
                    1000
                   );
      n_sproduc   NUMBER;
      n_capital   NUMBER;
      n_error     NUMBER;
      n_resp      NUMBER;
   BEGIN
      n_error :=
         pac_preguntas.f_get_pregunseg (psseguro,
                                        pnriesgo,
                                        6556,
                                        NVL (ptablas, 'SEG'),
                                        n_resp
                                       );

      IF ptablas = 'EST'
      THEN
         SELECT SUM (icapital)
           INTO n_capital
           FROM estgaranseg
          WHERE sseguro = psseguro AND nmovimi = pnmovimi AND cobliga = 1;

         IF n_capital > 500000000 AND n_resp BETWEEN 40 AND 100
         THEN
            RETURN 9909874;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         p_control_error ('LPP',
                          'pac_propio_garanproval_conf.f_valida_dto1',
                          SQLERRM
                         );
         p_tab_error (f_sysdate, f_user, vobj, 1, vpar, SQLERRM);
         RETURN 140999;                                 -- Error no controlado
      WHEN OTHERS
      THEN
         p_control_error ('LPP',
                          'pac_propio_garanproval_conf.f_valida_dto2',
                          SQLERRM
                         );
         p_tab_error (f_sysdate,
                      f_user,
                      vobj,
                      2,
                      vpar,
                      f_axis_literales (SQLCODE)
                     );
         RETURN SQLCODE;
   END f_valida_dto;

   FUNCTION f_gar_migraciones (
      ptablas    IN   VARCHAR2,
      psseguro   IN   NUMBER,
      pnriesgo   IN   NUMBER,
      pnmovimi   IN   NUMBER,
      pcgarant   IN   NUMBER,
      pcactivi   IN   NUMBER
   )
      RETURN NUMBER
   IS
      n_cont   NUMBER;
      vobj     VARCHAR2 (200)  := 'pac_propio_albsgt_pos.f_gar_migraciones';
      vpar     VARCHAR2 (1000)
         := SUBSTR (   ' - ptablas  '
                    || ptablas
                    || ' - psseguro '
                    || psseguro
                    || ' - pnriesgo '
                    || pnriesgo
                    || ' - pnmovimi '
                    || pnmovimi
                    || ' - pcgarant '
                    || pcgarant,
                    1,
                    1000
                   );
   BEGIN
      IF ptablas = 'EST'
      THEN
         SELECT COUNT (*)
           INTO n_cont
           FROM estgaranseg
          WHERE sseguro = psseguro AND cgarant = pcgarant AND cobliga = 1;

         IF n_cont = 0
         THEN
            RETURN 0;
         END IF;

         IF pnmovimi = 1
         THEN
            RETURN 9910278;
         ELSE
            SELECT COUNT ('G')
              INTO n_cont
              FROM garanseg
             WHERE sseguro = (SELECT ssegpol
                                FROM estseguros
                               WHERE sseguro = psseguro)
                   AND cgarant = pcgarant;

            IF n_cont = 0
            THEN
               RETURN 9910278;
            END IF;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         p_control_error ('LPP',
                          'pac_propio_garanproval_conf.f_gar_migraciones1',
                          SQLERRM
                         );
         p_tab_error (f_sysdate, f_user, vobj, 1, vpar, SQLERRM);
         RETURN 140999;                                 -- Error no controlado
      WHEN OTHERS
      THEN
         p_control_error ('LPP',
                          'pac_propio_garanproval_conf.f_gar_migraciones2',
                          SQLERRM
                         );
         p_tab_error (f_sysdate,
                      f_user,
                      vobj,
                      2,
                      vpar,
                      f_axis_literales (SQLCODE)
                     );
         RETURN SQLCODE;
   END f_gar_migraciones;

   FUNCTION f_val_rec_tarif (
      ptablas    IN   VARCHAR2,
      psseguro   IN   NUMBER,
      pnriesgo   IN   NUMBER,
      pnmovimi   IN   NUMBER,
      pcgarant   IN   NUMBER,
      pcactivi   IN   NUMBER
   )
      RETURN NUMBER
   IS
      n_total   NUMBER;
      vobj      VARCHAR2 (200)  := 'pac_propio_garanproval_conf.f_val_rec_tarif';
      vpar      VARCHAR2 (1000)
         := SUBSTR (   ' - ptablas  '
                    || ptablas
                    || ' - psseguro '
                    || psseguro
                    || ' - pnriesgo '
                    || pnriesgo
                    || ' - pnmovimi '
                    || pnmovimi
                    || ' - pcgarant '
                    || pcgarant,
                    1,
                    1000
                   );
   BEGIN
   --Ini IAXIS-13888- ECP -- 27/05/2020
         IF ptablas = 'EST'
      THEN
      if pnmovimi = 1 then
      begin
         SELECT MAX(iconcep)
           INTO n_total
           FROM estdetprimas a
          WHERE a.sseguro = psseguro
            AND a.nmovimi = pnmovimi
            AND a.nriesgo = pnriesgo
            AND a.cgarant = pcgarant
            AND a.ccampo = 'TASA'
            AND a.cconcep = 'RECTARIF'
            AND a.falta =
                   (SELECT MAX (b.falta)
                      FROM estdetprimas b
                     WHERE b.sseguro = a.sseguro
                       AND b.nmovimi = a.nmovimi
                       AND b.nriesgo = a.nriesgo
                       AND b.cgarant = a.cgarant
                       AND b.ccampo = a.ccampo
                       AND b.cconcep = a.cconcep);
       exception when no_data_found then n_total := 0;
       end;
      END IF;
      end if;
      

      
      IF n_total > 0
      THEN
         IF n_total >= 100
         THEN
            RETURN 9910212;
         ELSE
      
            RETURN 0;
         END IF;
      else
      p_tab_error (f_sysdate, f_user, vobj, 3, vpar, 'n_total-->' || n_total);
       return 0;
      END IF;
      --Fin  IAXIS-13888- ECP -- 27/05/2020
      return 0;
   
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         p_control_error ('LPP',
                          'pac_propio_garanproval_conf.f_val_rec_tarif1',
                          SQLERRM
                         );
         p_tab_error (f_sysdate, f_user, vobj, 1, vpar, SQLERRM);
         RETURN 140999;                                 -- Error no controlado
      WHEN OTHERS
      THEN
         p_control_error ('LPP',
                          'pac_propio_garanproval_conf.f_val_rec_tarif2',
                          SQLERRM||' '||vpar
                         );
         p_tab_error (f_sysdate,
                      f_user,
                      vobj,
                      2,
                      vpar,
                      f_axis_literales (SQLCODE)
                     );
                      --Fin IAXIS-3394-- ECP -- 27/04/2020
         RETURN SQLCODE;
   END f_val_rec_tarif;

   -- INI IAXIS-4200 CJMR 05/08/2019
   FUNCTION f_val_preg_val_contrato_rc (
      ptablas    IN   VARCHAR2,
      psseguro   IN   NUMBER,
      pnriesgo   IN   NUMBER,
      pnmovimi   IN   NUMBER,
      pcgarant   IN   NUMBER,
      pcactivi   IN   NUMBER
   )
      RETURN NUMBER
   IS
      vobj            VARCHAR2 (200)
                  := 'pac_propio_garanproval_conf.f_val_preg_val_contrato_rc';
      vpar            VARCHAR2 (1000)
         := SUBSTR (   ' - ptablas  '
                    || ptablas
                    || ' - psseguro '
                    || psseguro
                    || ' - pnriesgo '
                    || pnriesgo
                    || ' - pnmovimi '
                    || pnmovimi
                    || ' - pcgarant '
                    || pcgarant,
                    1,
                    1000
                   );
      v_crespue2883   FLOAT;
      v_crespue4211   FLOAT;
      n_error         NUMBER;
   BEGIN
      n_error :=
         pac_preguntas.f_get_pregunseg (psseguro,
                                        pnriesgo,
                                        2883,
                                        NVL (ptablas, 'SEG'),
                                        v_crespue2883
                                       );
      n_error :=
         pac_preguntas.f_get_pregunseg (psseguro,
                                        pnriesgo,
                                        4211,
                                        NVL (ptablas, 'SEG'),
                                        v_crespue4211
                                       );

      IF (NVL (v_crespue4211, 0) = 0 AND NVL (v_crespue2883, 0) = 0)
      THEN
         p_tab_error (f_sysdate, f_user, vobj, 3, 'HAY ERROR', SQLERRM);
         RETURN 89907045;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         p_tab_error (f_sysdate, f_user, vobj, 1, vpar, SQLERRM);
         RETURN 140999;                                -- Error no controlado
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobj,
                      2,
                      vpar,
                      f_axis_literales (SQLCODE)
                     );
         RETURN SQLCODE;
   END f_val_preg_val_contrato_rc;
-- FIN IAXIS-4200 CJMR 05/08/2019
END pac_propio_garanproval_conf;
/