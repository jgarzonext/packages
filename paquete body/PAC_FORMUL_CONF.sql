--------------------------------------------------------
--  DDL for Package Body PAC_FORMUL_CONF
--------------------------------------------------------

CREATE OR REPLACE PACKAGE BODY pac_formul_conf
AS
/******************************************************************************
   NAME:       pac_formul_conf
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        02/09/2016    HRE            1. Created this package body.--Nuevo paquete de negocio que contiene las funciones de formulacion de confianza
   2.0        23/01/2017    VCG             0001813: Nota Técnica, funcionalidad parámetro Experiencia - Ramo Cumplimiento
   3.0        05/02/2018    VCG            0001834: Nota Técnica, error Fecha Constitución Persona Jurídica
   4.0        10/06/2019    ECP            IAXIS-3628. Nota Técnica
   5.0        10/09/2019    CJMR           IAXIS-4205: Error de tarifas en Endosos RC
   6.0        11/10/2019    ECP            IAXIS-4082. Convenio Grandes Beneficiarios - RCE Derivado de Contratos
******************************************************************************/
   e_param_error    EXCEPTION;
   e_object_error   EXCEPTION;                  -- IAXIS-4205 CJMR 10/09/2019

   FUNCTION f_aplica_q3 (
      p_nsesion   IN   NUMBER,
      psseguro    IN   NUMBER,
      pscontra    IN   NUMBER,
      pnversio    IN   NUMBER,
      pctramo     IN   NUMBER
   )
      RETURN NUMBER
   IS
      vpasexec         NUMBER         := 1;
      vparam           VARCHAR2 (800)
         :=    'parametros - psseguro :'
            || psseguro
            || ' pscontra : '
            || pscontra
            || ' pnversio : '
            || pnversio
            || ' pctramo : '
            || pctramo;
      vobject          VARCHAR2 (50)  := 'pac_formul_conf.f_aplica_q3';
      v_error          NUMBER         := 0;
      v_consorcio_q3   NUMBER;
      v_persona_q3     NUMBER;
      v_q3             NUMBER         := 0;

      CURSOR cur_tomadores
      IS
         SELECT sperson
           FROM tomadores
          WHERE sseguro = psseguro
         UNION ALL
         SELECT spereal sperson
           FROM estper_personas
          WHERE sperson = (SELECT sperson
                             FROM esttomadores
                            WHERE sseguro = psseguro);

      CURSOR cur_consorcio_q3 (psperson per_personas.sperson%TYPE)
      IS
         SELECT NVL (COUNT (0), 0)
           FROM per_parpersonas
          WHERE cparam = 'PER_APLICA_Q3'
            AND nvalpar = 1
            AND sperson IN (
                   SELECT ppr.sperson_rel
                     FROM per_parpersonas par, per_personas_rel ppr
                    WHERE par.sperson = ppr.sperson
                      AND cparam = 'PER_ASO_JURIDICA'
                      AND nvalpar IN (1, 2)
                      AND ppr.sperson = psperson);

      CURSOR cur_per_q3 (psperson per_personas.sperson%TYPE)
      IS
         SELECT NVL (COUNT (0), 0)
           FROM per_parpersonas
          WHERE cparam = 'PER_APLICA_Q3' AND nvalpar = 1
                AND sperson = psperson;
   --
   BEGIN
      p_control_error ('pac_formul_conf', 'f_aplica_q3', 'paso 1');

      FOR rg_tomadores IN cur_tomadores
      LOOP
         p_control_error ('pac_formul_conf',
                          'f_aplica_q3',
                             'paso 2, rg_tomadores.sperson:'
                          || rg_tomadores.sperson
                         );

         OPEN cur_per_q3 (rg_tomadores.sperson);

         FETCH cur_per_q3
          INTO v_persona_q3;

         CLOSE cur_per_q3;

         p_control_error ('pac_formul_conf',
                          'f_aplica_q3',
                          'paso 3, v_persona_q3:' || v_persona_q3
                         );

         IF (v_persona_q3 > 0)
         THEN                                 --cliente individual o consorcio
            v_q3 := 1;
            EXIT;
         ELSE                             --cualquier integrante del consorcio
            p_control_error ('pac_formul_conf',
                             'f_aplica_q3',
                                'paso 4, rg_tomadores.sperson:'
                             || rg_tomadores.sperson
                            );

            OPEN cur_consorcio_q3 (rg_tomadores.sperson);

            FETCH cur_consorcio_q3
             INTO v_persona_q3;

            CLOSE cur_consorcio_q3;

            --
            p_control_error ('pac_formul_conf',
                             'f_aplica_q3',
                                'paso 5, rg_tomadores.sperson:'
                             || rg_tomadores.sperson
                             || ' v_persona_q3:'
                             || v_persona_q3
                            );

            IF (v_persona_q3 > 0)
            THEN
               v_q3 := 1;
               EXIT;
            ELSE
               v_q3 := 0;
            END IF;
         END IF;
      END LOOP;

      p_control_error ('pac_formul_conf',
                       'f_aplica_q3',
                       'paso 6, v_q3:' || v_q3
                      );
      RETURN v_q3;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_formul_conf.f_aplica_q3',
                      1,
                      SQLERRM,
                      NULL
                     );
         RETURN NULL;
   END f_aplica_q3;

   FUNCTION f_tiene_cumulo (p_nsesion IN NUMBER, p_sseguro IN NUMBER)
      RETURN NUMBER
   IS
      v_cumulo   NUMBER;
   BEGIN
      SELECT COUNT (0)
        INTO v_cumulo
        FROM cumulos
       WHERE sperson IN (SELECT sperson
                           FROM tomadores
                          WHERE sseguro = p_sseguro);

      RETURN v_cumulo;
   END;

   /*****************************************************************************
   Funcion f_prima_rcmedica: Devuelve la prima de la garantía RC Medica
      ptabla:
      psseguro :Seguro
      return: Provisión de riesgo
   *****************************************************************************/
   FUNCTION f_prima_rcmedica_v (
      psseguro   IN   NUMBER,
      pnmovimi   IN   NUMBER,
      pnriesgo   IN   NUMBER,
      pcapital   IN   NUMBER
   )
      RETURN NUMBER
   IS
      CURSOR c1
      IS
         SELECT nvalor
           FROM (SELECT nvalor
                   FROM estpregunsegtab
                  WHERE sseguro = psseguro
                    AND cpregun = 6581
                    AND nmovimi = pnmovimi
                    AND nriesgo = pnriesgo
                 UNION
                 SELECT nvalor
                   FROM estpregunsegtab
                  WHERE sseguro = psseguro
                    AND cpregun = 6581
                    AND nmovimi = pnmovimi
                    AND nriesgo = pnriesgo);

      n_importe   NUMBER;
      n_clase     NUMBER;
   BEGIN
      n_importe := 0;

      FOR r1 IN c1
      LOOP
         n_clase :=
            pac_subtablas.f_vsubtabla (p_in_nsesion        => -1,
                                       p_in_csubtabla      => 8000003,
                                       p_in_cquery         => 3,
                                       p_in_cval           => 1,
                                       p_in_ccla1          => r1.nvalor
                                      );
         n_importe :=
              n_importe
            + NVL (pac_subtablas.f_vsubtabla (p_in_nsesion        => -1,
                                              p_in_csubtabla      => 8000009,
                                              p_in_cquery         => 314,
                                              p_in_cval           => 1,
                                              p_in_ccla1          => n_clase,
                                              p_in_ccla2          => pcapital,
                                              p_in_ccla3          => pcapital
                                             ),
                   0
                  );
      END LOOP;

      RETURN n_importe;
   END f_prima_rcmedica_v;

           /*****************************************************************************
   Funcion f_prima_rcmedica: Devuelve la prima de la garanta RC Medica
      ptabla:
      psseguro :Seguro
      return: Provisin de riesgo
   *****************************************************************************/
   FUNCTION f_prima_rcmedica (
      psseguro   IN   NUMBER,
      pnmovimi   IN   NUMBER,
      pnriesgo   IN   NUMBER,
      pcapital   IN   NUMBER
   )
      RETURN NUMBER
   IS
      vprima       NUMBER;
      vcapital     NUMBER;
      vid_clasif   NUMBER;
   BEGIN
      IF pcapital < 20000000
      THEN
         vcapital := 20000000;
      ELSIF pcapital > 5000000000
      THEN
         vcapital := 5000000000;
      ELSE
         vcapital := pcapital;
      END IF;

      SELECT nvalor
        INTO vid_clasif
        FROM estpregunsegtab
       WHERE sseguro = psseguro
         AND cpregun = 6581
         AND nmovimi = pnmovimi
         AND nriesgo = pnriesgo;

      SELECT NVL (prima, 0)
        INTO vprima
        FROM tarifa_rc_medica
       WHERE id_clasif = vid_clasif
         AND vcapital BETWEEN rango_desde AND rango_hasta;

      RETURN vprima;
   END f_prima_rcmedica;

   /*****************************************************************************
   Funcion f_prima_rcclinica: Devuelve la prima de la garantía RC Clinica
      ptabla:
      psseguro :Seguro
      return: Provisión de riesgo
   *****************************************************************************/
   FUNCTION f_prima_rcclinica_v (
      psseguro   IN   NUMBER,
      pnmovimi   IN   NUMBER,
      pnriesgo   IN   NUMBER,
      pcapital   IN   NUMBER
   )
      RETURN NUMBER
   IS
      CURSOR c1
      IS
         SELECT   *
             FROM estpregunsegtab
            WHERE sseguro = psseguro
              AND cpregun = 6585
              AND nmovimi = pnmovimi
              AND nriesgo = pnriesgo
         ORDER BY nlinea ASC, ccolumna ASC;

      n_importe       NUMBER;
      n_clase         NUMBER;
      n_asegs         NUMBER;
      n_paramed       NUMBER;
      n_camas         NUMBER;
      n_adic_plo      NUMBER;
      n_danyo_moral   NUMBER;
      n_dto           NUMBER;
   BEGIN
      n_importe := 0;

      FOR r1 IN c1
      LOOP
         IF r1.ccolumna = 1
         THEN
            n_clase := r1.nvalor;
         ELSIF r1.ccolumna = 2
         THEN
            n_asegs := r1.nvalor;
         ELSIF r1.ccolumna = 3
         THEN
            n_importe :=
                 n_importe
               + (  pac_subtablas.f_vsubtabla (p_in_nsesion        => -1,
                                               p_in_csubtabla      => 8000009,
                                               p_in_cquery         => 314,
                                               p_in_cval           => 1,
                                               p_in_ccla1          => n_clase,
                                               p_in_ccla2          => pcapital,
                                               p_in_ccla3          => pcapital
                                              )
                  * n_asegs
                 );
         END IF;
      END LOOP;

      SELECT NVL (MAX (crespue), 0)
        INTO n_paramed
        FROM estpregunseg
       WHERE sseguro = psseguro
         AND cpregun = 6586
         AND nmovimi = pnmovimi
         AND nriesgo = pnriesgo;

      n_importe :=
           n_importe
         + (  pac_subtablas.f_vsubtabla (p_in_nsesion        => -1,
                                         p_in_csubtabla      => 8000040,
                                         p_in_cquery         => 14,
                                         p_in_cval           => 1,
                                         p_in_ccla1          => pcapital,
                                         p_in_ccla2          => pcapital
                                        )
            * n_paramed
           );
      n_dto :=
           pac_subtablas.f_vsubtabla (p_in_nsesion        => -1,
                                      p_in_csubtabla      => 8000041,
                                      p_in_cquery         => 24,
                                      p_in_cval           => 1,
                                      p_in_ccla1          => n_paramed,
                                      p_in_ccla2          => n_paramed
                                     )
         * n_importe
         / 100;

      SELECT NVL (MAX (crespue), 0)
        INTO n_camas
        FROM estpregunseg
       WHERE sseguro = psseguro
         AND cpregun = 6589
         AND nmovimi = pnmovimi
         AND nriesgo = pnriesgo;

      n_importe :=
           n_importe
         + (  pac_subtablas.f_vsubtabla (p_in_nsesion        => -1,
                                         p_in_csubtabla      => 8000040,
                                         p_in_cquery         => 14,
                                         p_in_cval           => 2,
                                         p_in_ccla1          => pcapital,
                                         p_in_ccla2          => pcapital
                                        )
            * n_camas
           );
      n_adic_plo :=
           pac_subtablas.f_vsubtabla (p_in_nsesion        => -1,
                                      p_in_csubtabla      => 8000040,
                                      p_in_cquery         => 14,
                                      p_in_cval           => 3,
                                      p_in_ccla1          => pcapital,
                                      p_in_ccla2          => pcapital
                                     )
         * pcapital
         / 100;
      n_danyo_moral := n_importe * 0.2;
      n_importe :=
           NVL (n_importe, 0)
         + NVL (n_adic_plo, 0)
         + NVL (n_danyo_moral, 0)
         - NVL (n_dto, 0);
      RETURN n_importe;
   END f_prima_rcclinica_v;

   FUNCTION f_prima_rcclinica (
      psseguro   IN   NUMBER,
      pnmovimi   IN   NUMBER,
      pnriesgo   IN   NUMBER,
      pcapital   IN   NUMBER
   )
      RETURN NUMBER
   IS
      CURSOR c1
      IS
         SELECT   nlinea, ccolumna, nvalor
             FROM estpregunsegtab
            WHERE sseguro = psseguro
              AND nmovimi = pnmovimi
              AND nriesgo = pnriesgo
              AND cpregun = 6585
         ORDER BY nlinea ASC, ccolumna ASC;

      vprima            NUMBER;
      vprima_producto   NUMBER;
      vprima_total      NUMBER;
      vid_clasif        NUMBER;
      nasegu            NUMBER;
      vcapital          NUMBER;
      vprima_9906       NUMBER;
      vprima_9905       NUMBER;
      vprima_9904       NUMBER;
      vprima_9903       NUMBER;
      vprima_9900       NUMBER;
      vprima_9901       NUMBER;
      vprima_9902       NUMBER;
      ntraza            NUMBER := 0;
   BEGIN
      vprima_total := 0;
      ntraza := 1;

      FOR r1 IN c1
      LOOP
         IF r1.ccolumna = 1
         THEN
            vid_clasif := r1.nvalor;
            ntraza := 11;
         ELSIF r1.ccolumna = 2
         THEN
            nasegu := r1.nvalor;
            ntraza := 22;
         ELSIF r1.ccolumna = 3
         THEN
            IF r1.nvalor < 20000000
            THEN
               vcapital := 20000000;
            ELSIF r1.nvalor > 5000000000
            THEN
               vcapital := 5000000000;
            ELSE
               vcapital := r1.nvalor;
            END IF;

            ntraza := 33;

            SELECT NVL (prima, 0)
              INTO vprima
              FROM tarifa_rc_medica
             WHERE id_clasif = vid_clasif
               AND vcapital BETWEEN rango_desde AND rango_hasta;

            vprima_producto := vprima * nasegu;
            vprima_total := vprima_total + vprima_producto;
            ntraza := 44;
         END IF;
      END LOOP;

      ntraza := 2;

      SELECT NVL (crespue, 0)
        INTO vprima_9906
        FROM estpregunseg
       WHERE sseguro = psseguro
         AND cpregun = 9906
         AND nmovimi = pnmovimi
         AND nriesgo = pnriesgo;

      ntraza := 2;

      SELECT NVL (crespue, 0)
        INTO vprima_9905
        FROM estpregunseg
       WHERE sseguro = psseguro
         AND cpregun = 9905
         AND nmovimi = pnmovimi
         AND nriesgo = pnriesgo;

      ntraza := 3;

      SELECT NVL (crespue, 0)
        INTO vprima_9904
        FROM estpregunseg
       WHERE sseguro = psseguro
         AND cpregun = 9904
         AND nmovimi = pnmovimi
         AND nriesgo = pnriesgo;

      ntraza := 4;

      SELECT NVL (crespue, 0)
        INTO vprima_9903
        FROM estpregunseg
       WHERE sseguro = psseguro
         AND cpregun = 9903
         AND nmovimi = pnmovimi
         AND nriesgo = pnriesgo;

      ntraza := 5;

      SELECT NVL (crespue, 0)
        INTO vprima_9900
        FROM estpregunseg
       WHERE sseguro = psseguro
         AND cpregun = 9900
         AND nmovimi = pnmovimi
         AND nriesgo = pnriesgo;

      ntraza := 6;

      SELECT NVL (crespue, 0)
        INTO vprima_9901
        FROM estpregunseg
       WHERE sseguro = psseguro
         AND cpregun = 9901
         AND nmovimi = pnmovimi
         AND nriesgo = pnriesgo;

      ntraza := 7;

      SELECT NVL (crespue, 0)
        INTO vprima_9902
        FROM estpregunseg
       WHERE sseguro = psseguro
         AND cpregun = 9902
         AND nmovimi = pnmovimi
         AND nriesgo = pnriesgo;

      ntraza := 8;
      vprima_total :=
           vprima_total
         + vprima_9903
         + vprima_9904
         + vprima_9905
         + vprima_9906
         + vprima_9900
         + vprima_9901
         + vprima_9902;
      ntraza := 9;
      RETURN vprima_total;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_formul_conf.f_prima_rcclinica',
                      ntraza,
                      NULL,
                      SQLERRM
                     );
         RETURN 0;
   END f_prima_rcclinica;

   --Devuelve el cálculo de la tasa RAI, que es una parte del cálculo de la tasa de algunos productos(GU, ...)
   FUNCTION f_tasa_rai (
      psseguro   IN   NUMBER,
      pnmovimi   IN   NUMBER,
      pnriesgo   IN   NUMBER
   )
      RETURN NUMBER
   IS
      CURSOR c_integra
      IS
         SELECT DISTINCT sperson_rel, pparticipacion / 100 pparticipacion,
                         ctipper, cpais,
                         DECODE (cramo, 806, 0, 805, 0, 1) aplica_exp
                    FROM per_personas_rel r,
                         esttomadores t,
                         estper_personas p,
                         estper_detper d,
                         estseguros s
                   WHERE t.sseguro = psseguro
                     AND p.spereal = r.sperson
                     AND t.sperson = p.sperson
                     AND t.sseguro = s.sseguro
                     AND t.sperson = d.sperson
                     AND ctipper_rel = 0;

      n_cupo          NUMBER;
      n_patrimonio    NUMBER;
      n_cupo_patr     NUMBER;
      n_scoring       NUMBER;
      n_sfinanci      NUMBER;
      n_sperson       NUMBER;
      n_ctipper       NUMBER;
      n_cpais         NUMBER;
      n_anyo          NUMBER;
      n_experiencia   NUMBER;
      n_tasa_cap      NUMBER;
      n_tasa_exp      NUMBER;
      n_rai_int       NUMBER;
      n_rai           NUMBER := 0;
   BEGIN
      FOR r_integra IN c_integra
      LOOP
         n_ctipper := r_integra.ctipper;
         n_cpais := r_integra.cpais;
         n_sperson := r_integra.sperson_rel;
         n_tasa_cap := NULL;

         SELECT MAX (sfinanci)
           INTO n_sfinanci
           FROM fin_general
          WHERE sperson = n_sperson;

         IF n_sfinanci IS NULL
         THEN
            IF r_integra.ctipper = 1
            THEN
               n_tasa_cap := 150;
            ELSE
               n_tasa_cap := 110;
            END IF;
         ELSIF n_ctipper = 1
         THEN                                                --persona natural
            BEGIN
                --Primero buscamos el scoring de la persona natural
                /*SELECT NSCORE, ICUPOG
                  INTO n_scoring, n_cupo
               FROM FIN_ENDEUDAMIENTO
               WHERE SFINANCI = n_sfinanci
                 AND (NSCORE IS NOT NULL OR ICUPOG IS NOT NULL);*/
               SELECT NVL (nscore, 0), NVL (icupog, 0)
                 INTO n_scoring, n_cupo
                 FROM fin_endeudamiento
                WHERE sfinanci = n_sfinanci;
            EXCEPTION
               WHEN OTHERS
               THEN
                  --Si no tiene SCORING, lo ponemos a 0
                  n_scoring := 0;
                  n_cupo := NULL;
                  n_patrimonio := NULL;
            END;

            IF n_cupo IS NOT NULL
            THEN
               BEGIN
                  --Si la persona tiene CUPO y PATRIMONIO, prima sobre el SCORING
                  SELECT NVL (NVL (nvalpar, tvalpar), 0)
                    INTO n_patrimonio
                    FROM fin_parametros a
                   WHERE a.sfinanci = n_sfinanci
                     AND a.nmovimi = (SELECT MAX (nmovimi)
                                        FROM fin_indicadores b
                                       WHERE a.sfinanci = b.sfinanci)
                     AND a.cparam = 'PATRI_ANO_ACTUAL';

                  n_scoring := 0;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     n_cupo := NULL;
                     n_patrimonio := NULL;
               END;
            ELSE
               n_cupo := NULL;
               n_patrimonio := NULL;
            END IF;
         ELSIF n_ctipper = 2 AND NVL (n_cpais, 1) <> 170
         THEN                                 --CUPO para empresas extranjeras
            --Para empresas extranjeras, la capacidad financiera será la máxima
            n_tasa_cap := 110;
         ELSIF n_ctipper = 2 AND n_cpais = 170
         THEN                                  --CUPO para empresas nacionales
            p_control_error ('LPP', 'n_cupo', n_cupo);

            BEGIN
               SELECT NVL (icupog, 0)
                 INTO n_cupo
                 FROM fin_indicadores a
                WHERE a.sfinanci = n_sfinanci
                  AND a.nmovimi = (SELECT MAX (nmovimi)
                                     FROM fin_indicadores b
                                    WHERE a.sfinanci = b.sfinanci);
            EXCEPTION
               WHEN OTHERS
               THEN
                  n_cupo := -1;
            END;

            p_control_error ('LPP', 'n_cupo', n_cupo);

            BEGIN
               SELECT NVL (NVL (nvalpar, tvalpar), 0)
                 INTO n_patrimonio
                 FROM fin_parametros a
                WHERE a.sfinanci = n_sfinanci
                  AND a.nmovimi = (SELECT MAX (nmovimi)
                                     FROM fin_indicadores b
                                    WHERE a.sfinanci = b.sfinanci)
                  AND a.cparam = 'PATRI_ANO_ACTUAL';
            EXCEPTION
               WHEN OTHERS
               THEN
                  n_patrimonio := 1;
            END;

            p_control_error ('LPP', 'n_patrimonio', n_patrimonio);
         END IF;

         IF n_tasa_cap IS NULL
         THEN
            IF n_cupo IS NOT NULL
            THEN
               n_cupo_patr := CEIL (n_cupo / n_patrimonio);
               n_tasa_cap :=
                  pac_subtablas.f_vsubtabla (p_in_nsesion        => -1,
                                             p_in_csubtabla      => 8000005,
                                             p_in_cquery         => 14,
                                             p_in_cval           => 1,
                                             p_in_ccla1          => n_cupo_patr,
                                             p_in_ccla2          => n_cupo_patr
                                            );
            ELSIF n_scoring IS NOT NULL
            THEN
               n_tasa_cap :=
                  pac_subtablas.f_vsubtabla (p_in_nsesion        => -1,
                                             p_in_csubtabla      => 8000006,
                                             p_in_cquery         => 14,
                                             p_in_cval           => 1,
                                             p_in_ccla1          => n_scoring,
                                             p_in_ccla2          => n_scoring
                                            );
            ELSE
               IF n_ctipper = 1
               THEN
                  n_tasa_cap := 150;
               ELSE
                  n_tasa_cap := 110;
               END IF;
            END IF;
         END IF;

         --Comenzamos con el cálculo de la tasa según EXPERIENCIA
         n_anyo := TO_CHAR (SYSDATE, 'YYYY');

           --Ini-Qtracker 0001813-VCG-22/01/2018-Se elimina la pregunta 6551
           --Se modifica la pregunta 6550 para que aplique igual para persona natural y juridica con la fecha de constitucion de la persona
         /* IF n_ctipper = 1 THEN       --Año vinculación cliente

            BEGIN
              SELECT TO_CHAR(FCONSTI, 'YYYY')
                INTO n_anyo
                FROM FIN_GENERAL
               WHERE SPERSON = n_sperson
                 AND FCONSTI IS NOT NULL;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                SELECT NVL(MIN(TO_CHAR(FEMISIO, 'YYYY')), TO_CHAR(SYSDATE, 'YYYY'))
                  INTO n_anyo
                  FROM SEGUROS S, TOMADORES T
                 WHERE T.SSEGURO = S.SSEGURO
                   AND T.SPERSON = n_sperson;
            END;*/
          --Natural-Juridica
         IF n_ctipper = 1
         THEN                                       --Año constitución empresa
            SELECT NVL (MIN (TO_CHAR (fconsti, 'YYYY')),
                        TO_CHAR (SYSDATE, 'YYYY')
                       )
              INTO n_anyo
              FROM fin_general
             WHERE sperson = n_sperson;
         END IF;

         --Ini-Qtracker 0001834-VCG-05/02/2018-Se modifica consulta para juridica
         IF n_ctipper = 2
         THEN                                       --Año constitución empresa
            SELECT NVL (TO_CHAR (fnacimi, 'YYYY'), TO_CHAR (SYSDATE, 'YYYY'))
              INTO n_anyo
              FROM per_personas
             WHERE sperson = n_sperson;
         END IF;

         --Fin-Qtracker 0001834-VCG-05/02/2018-Se modifica consulta para juridica
         n_experiencia := TO_CHAR (SYSDATE, 'YYYY') - n_anyo;
         n_tasa_exp :=
            NVL (pac_subtablas.f_vsubtabla (p_in_nsesion        => -1,
                                            p_in_csubtabla      => 8000004,
                                            p_in_cquery         => 24,
                                            p_in_cval           => 1,
                                            p_in_ccla1          => n_experiencia,
                                            p_in_ccla2          => n_experiencia
                                           ),
                 0
                );

         IF r_integra.aplica_exp = 1
         THEN
            n_rai_int :=
                     n_tasa_exp * n_tasa_cap * r_integra.pparticipacion / 100;
         ELSE
            n_rai_int := n_tasa_cap * r_integra.pparticipacion;
         END IF;

         p_control_error ('LPP', 'n_experiencia', n_experiencia);
         p_control_error ('LPP', 'n_tasa_exp', n_tasa_exp);
         p_control_error ('LPP', 'n_tasa_cap', n_tasa_cap);
         p_control_error ('LPP', 'n_rai_int', n_rai_int);
         n_rai := n_rai + n_rai_int;
      END LOOP;

      p_control_error ('LPP', 'n_rai', n_rai);
      RETURN n_rai / 100;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_control_error ('LPP', 'pac_formul_conf.f_tasa_rai', SQLERRM);
         RETURN 0;
   END f_tasa_rai;

   /*****************************************************************************
   Funcion f_prima_rcmedica: Devuelve la prima de la garantía RC Medica
      ptabla:
      psseguro :Seguro
      return: Provisión de riesgo
   *****************************************************************************/
   FUNCTION f_capita_nota (
      psseguro   IN   NUMBER,
      pnmovimi   IN   NUMBER,
      pnriesgo   IN   NUMBER
   )
      RETURN NUMBER
   IS
      v_icapital   NUMBER;
      v_cmoncia    parempresas.nvalpar%TYPE;
      cdivisa      NUMBER;
      v_sseguro    NUMBER;
      v_cempres    NUMBER;
      vpasexec     NUMBER (8)                 := 1;
      vparam       VARCHAR2 (1)               := NULL;
      vobject      VARCHAR2 (200)       := 'PAC_FORMULAS_CONF.f_capital_nota';
      mensajes     t_iax_mensajes;
   BEGIN
      --ACA VALIDAMOS SI ES EL PRODUCTO ES MONEDA EXTARNJERA PARA REALIZAR LA VALIDACION CON EL CAMBIO.
      BEGIN
         SELECT NVL (cdivisa, 8)
           INTO cdivisa
           FROM estseguros s, productos p
          WHERE s.sproduc = p.sproduc AND sseguro = psseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            RAISE e_param_error;
      END;

      v_cmoncia :=
               NVL (pac_parametros.f_parempresa_n (v_cempres, 'MONEDAEMP'), 8);
      v_icapital := 0;

      IF     pac_iax_produccion.poliza.det_poliza.riesgos IS NOT NULL
         AND pac_iax_produccion.poliza.det_poliza.riesgos.COUNT > 0
      THEN
         FOR j IN
            pac_iax_produccion.poliza.det_poliza.riesgos.FIRST .. pac_iax_produccion.poliza.det_poliza.riesgos.LAST
         LOOP
            IF     pac_iax_produccion.poliza.det_poliza.riesgos (j).garantias IS NOT NULL
               AND pac_iax_produccion.poliza.det_poliza.riesgos (j).garantias.COUNT >
                                                                             0
            THEN
               FOR z IN
                  pac_iax_produccion.poliza.det_poliza.riesgos (j).garantias.FIRST .. pac_iax_produccion.poliza.det_poliza.riesgos
                                                                                        (j
                                                                                        ).garantias.LAST
               LOOP
                  v_icapital :=
                       v_icapital
                     + NVL
                          (pac_iax_produccion.poliza.det_poliza.riesgos (j).garantias
                                                                           (z).icapital,
                           0
                          );
               END LOOP;
            END IF;
         END LOOP;
      END IF;

      IF cdivisa <> v_cmoncia
      THEN
         v_icapital :=
            NVL
               (pac_eco_tipocambio.f_importe_cambio
                                          (pac_monedas.f_cmoneda_t (cdivisa),
                                           pac_monedas.f_cmoneda_t (v_cmoncia),
                                           SYSDATE,
                                           v_icapital
                                          ),
                0
               );
      END IF;

      RETURN v_icapital;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 0;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 0;
   END f_capita_nota;

-- Ini IAXIS-3628 -- ECP -- 26/07/2019
   FUNCTION f_tasa_suplemento (
      psseguro   IN   NUMBER,
      pnriesgo   IN   NUMBER,
      pnmovimi   IN   NUMBER,
      pcgarant   IN   NUMBER
   )
      RETURN NUMBER
   IS
      v_itarifa        NUMBER                           := 0;
      v_sseguro        NUMBER                           := 0;
      v_recargo        NUMBER                           := 0;
      v_crespue_6623   estpregungaranseg.crespue%TYPE;
      v_crespue_6549   estpregungaranseg.crespue%TYPE;
   BEGIN
      SELECT sseguro
        INTO v_sseguro
        FROM seguros
       WHERE npoliza = (SELECT npoliza
                          FROM estseguros
                         WHERE sseguro = psseguro);

      BEGIN
         SELECT gs.itarifa
           INTO v_itarifa
           FROM seguros s, garanseg gs
          WHERE s.sseguro = gs.sseguro
            AND s.sseguro = v_sseguro
            AND gs.nriesgo = pnriesgo
            AND gs.cgarant = pcgarant
            AND gs.nmovimi = 1;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            v_itarifa := 0;
      END;

      BEGIN
         SELECT NVL (a.crespue, 0)
           INTO v_crespue_6623
           FROM estpregungaranseg a
          WHERE a.sseguro = psseguro
            AND a.cpregun = 6623
            AND a.nriesgo = pnriesgo
            AND a.cgarant = pcgarant
            AND a.nmovimi = pnmovimi;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            BEGIN
               SELECT NVL (a.crespue, 0)
                 INTO v_crespue_6623
                 FROM pregungaranseg a
                WHERE a.sseguro = psseguro
                  AND a.cpregun = 6623
                  AND a.nriesgo = pnriesgo
                  AND a.cgarant = pcgarant
                  AND a.nmovimi =
                         (SELECT MAX (b.nmovimi)
                            FROM pregunseg b
                           WHERE b.sseguro = a.sseguro
                             AND b.cpregun = a.cpregun
                             AND b.nriesgo = a.nriesgo
                             AND b.nmovimi <= pnmovimi);
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  NULL;
            END;
      END;

      BEGIN
         SELECT NVL (a.crespue, 0)
           INTO v_crespue_6549
           FROM estpregungaranseg a
          WHERE a.sseguro = psseguro
            AND a.cpregun = 6549
            AND a.nriesgo = pnriesgo
            AND a.cgarant = pcgarant
            AND a.nmovimi = pnmovimi;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            BEGIN
               SELECT NVL (a.crespue, 0)
                 INTO v_crespue_6549
                 FROM pregungaranseg a
                WHERE a.sseguro = psseguro
                  AND a.cpregun = 6549
                  AND a.nriesgo = pnriesgo
                  AND a.cgarant = pcgarant
                  AND a.nmovimi =
                         (SELECT MAX (b.nmovimi)
                            FROM pregunseg b
                           WHERE b.sseguro = a.sseguro
                             AND b.cpregun = a.cpregun
                             AND b.nriesgo = a.nriesgo
                             AND b.nmovimi <= pnmovimi);
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  NULL;
            END;
      END;

      /* p_tab_error (f_sysdate,
                    f_user,
                    'tar',
                    1,
                    psseguro,
                       SQLCODE
                    || ' - '
                    || SQLERRM
                    || ' v_crespue_6623 -->'
                    || v_crespue_6623
                    || ' v_crespue_6549-->'
                    || v_crespue_6549
                   );*/
      v_recargo := v_crespue_6623 - v_crespue_6549;

      /* p_tab_error (f_sysdate,
                    f_user,
                    'tar',
                    2,
                    psseguro,
                    SQLCODE || ' - ' || SQLERRM || ' v_recargo -->'
                    || v_recargo
                   );*/
      IF pnmovimi > 1
      THEN
         v_itarifa := v_itarifa * (1 + v_recargo / 100);
      ELSE
         v_itarifa := 0;
      END IF;

      
      RETURN v_itarifa;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN 0;
      WHEN OTHERS
      THEN
         RETURN 0;
   END f_tasa_suplemento;

-- Ini IAXIS-3628 -- ECP -- 26/07/2019
   --IAXIS-3628 -- ECP -- 10/06/2019
   FUNCTION f_tasa_referencia (
      psseguro   IN   NUMBER,
      pnmovimi   IN   NUMBER,
      pnriesgo   IN   NUMBER
   )
      RETURN NUMBER
   IS
      v_crespue   pregunseg.crespue%TYPE;
      v_sproduc   seguros.sproduc%TYPE;
      v_cactivi   seguros.cactivi%TYPE;
      v_factor    NUMBER                   := 1;
      vobject     VARCHAR2 (100)       := 'pac_formul_conf.f_tasa_referencia';
      vpasexec    NUMBER                   := 0;
      vparam      VARCHAR2 (400)
         :=    'psseguro-->'
            || psseguro
            || 'pnmovimi-->'
            || pnmovimi
            || 'pnriesgo-->'
            || pnriesgo;
   BEGIN
      BEGIN
         SELECT sproduc, cactivi
           INTO v_sproduc, v_cactivi
           FROM seguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            SELECT sproduc, cactivi
              INTO v_sproduc, v_cactivi
              FROM estseguros
             WHERE sseguro = psseguro;
      END;

      BEGIN
         SELECT a.crespue
           INTO v_crespue
           FROM estpregunseg a
          WHERE a.sseguro = psseguro
            AND a.cpregun = 2880
            AND a.nriesgo = pnriesgo
            AND a.nmovimi = pnmovimi;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            BEGIN
               SELECT a.crespue
                 INTO v_crespue
                 FROM pregunseg a
                WHERE a.sseguro = psseguro
                  AND a.cpregun = 2880
                  AND a.nriesgo = pnriesgo
                  AND a.nmovimi =
                         (SELECT MAX (b.nmovimi)
                            FROM pregunseg b
                           WHERE b.sseguro = a.sseguro
                             AND b.cpregun = a.cpregun
                             AND b.nriesgo = a.nriesgo
                             AND b.nmovimi <= pnmovimi);
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  BEGIN
                     SELECT a.crespue
                       INTO v_crespue
                       FROM estpregunseg a
                      WHERE a.sseguro = psseguro
                        AND a.cpregun = 5882
                        AND a.nriesgo = pnriesgo
                        AND a.nmovimi = pnmovimi;
                  EXCEPTION
                     WHEN NO_DATA_FOUND
                     THEN
                        BEGIN
                           SELECT a.crespue
                             INTO v_crespue
                             FROM pregunseg a
                            WHERE a.sseguro = psseguro
                              AND a.cpregun = 5882
                              AND a.nriesgo = pnriesgo
                              AND a.nmovimi =
                                     (SELECT MAX (b.nmovimi)
                                        FROM pregunseg b
                                       WHERE b.sseguro = a.sseguro
                                         AND b.cpregun = a.cpregun
                                         AND b.nriesgo = a.nriesgo
                                         AND b.nmovimi <= pnmovimi);
                        EXCEPTION
                           WHEN NO_DATA_FOUND
                           THEN
                              BEGIN
                                 SELECT a.crespue
                                   INTO v_crespue
                                   FROM estpregunseg a
                                  WHERE a.sseguro = psseguro
                                    AND a.cpregun = 5876
                                    AND a.nriesgo = pnriesgo
                                    AND a.nmovimi = pnmovimi;
                              EXCEPTION
                                 WHEN NO_DATA_FOUND
                                 THEN
                                    BEGIN
                                       SELECT a.crespue
                                         INTO v_crespue
                                         FROM pregunseg a
                                        WHERE a.sseguro = psseguro
                                          AND a.cpregun = 5876
                                          AND a.nriesgo = pnriesgo
                                          AND a.nmovimi =
                                                 (SELECT MAX (b.nmovimi)
                                                    FROM pregunseg b
                                                   WHERE b.sseguro = a.sseguro
                                                     AND b.cpregun = a.cpregun
                                                     AND b.nriesgo = a.nriesgo
                                                     AND b.nmovimi <= pnmovimi);
                                    EXCEPTION
                                       WHEN NO_DATA_FOUND
                                       THEN
                                          v_crespue := 0;
                                    END;
                              END;
                        END;
                  END;
            END;
      END;

      vpasexec := 1;

      IF v_sproduc = 80011
      THEN
         v_factor :=
            NVL (pac_subtablas.f_vsubtabla (p_in_nsesion        => -1,
                                            p_in_csubtabla      => 8000047,
                                            p_in_cquery         => 3,
                                            p_in_cval           => 1,
                                            p_in_ccla1          => v_sproduc
                                           ),
                 100
                );
      ELSE
         v_factor :=
            NVL (pac_subtablas.f_vsubtabla (p_in_nsesion        => -1,
                                            p_in_csubtabla      => 8000047,
                                            p_in_cquery         => 333,
                                            p_in_cval           => 1,
                                            p_in_ccla1          => v_sproduc,
                                            p_in_ccla2          => v_cactivi,
                                            p_in_ccla3          => v_crespue
                                           ),
                 100
                );
      END IF;

      IF v_factor < 0
      THEN
         v_factor := 100 + v_factor;
      END IF;

      vpasexec := 2;
           RETURN v_factor;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                         SQLCODE
                      || ' - '
                      || SQLERRM
                      || ' '
                      || v_factor
                      || ' v_crespue-->'
                      || v_crespue
                      || ' v_cactivi-->'
                      || v_cactivi
                      || ' v_sproduc-->'
                      || v_sproduc
                     );
   END f_tasa_referencia;

--IAXIS-3628 -- ECP -- 10/06/2019
-- Ini IAXIS-3628 --- ECP -- 01/08/2019
   FUNCTION f_capital_suplemento (
      psseguro   IN   NUMBER,
      pnriesgo   IN   NUMBER,
      pnmovimi   IN   NUMBER,
      pcgarant   IN   NUMBER
   )
      RETURN NUMBER
   IS
      v_cap_ant        NUMBER                           := 0;
      v_cap_act        NUMBER                           := 0;
      v_sseguro        NUMBER                           := 0;
      v_recargo        NUMBER                           := 0;
      v_crespue_2893   estpregungaranseg.crespue%TYPE;
      v_crespue_2883   estpregungaranseg.crespue%TYPE;
      v_crespue_2892   estpregungaranseg.crespue%TYPE;
      v_capital        NUMBER;
   BEGIN
      SELECT sseguro
        INTO v_sseguro
        FROM seguros
       WHERE npoliza = (SELECT npoliza
                          FROM estseguros
                         WHERE sseguro = psseguro);

      BEGIN
         SELECT gs.icapital
           INTO v_cap_ant
           FROM garanseg gs
          WHERE gs.sseguro = v_sseguro
            AND gs.nriesgo = pnriesgo
            AND gs.cgarant = pcgarant
            AND gs.ffinefe IS NULL;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            v_cap_ant := 0;
      END;

/*p_tab_error (f_sysdate,
                   f_user,
                   'tar',
                   1,
                   psseguro,
                      SQLCODE
                   || ' - '
                   || SQLERRM
                   || ' v_cap_ant -->'
                   || v_cap_ant
                   || ' v_sseguro-->'
                   || v_sseguro
                   || ' psseguro-->'
                   || psseguro
                   || ' pnriesgo-->'
                   || pnriesgo
                   || ' pcgarant-->'
                   || pcgarant
                   || ' pnmovimi-->'
                   || pnmovimi
                  );*/
      BEGIN
         SELECT NVL (a.crespue, 0)
           INTO v_crespue_2893
           FROM estpregungaranseg a
          WHERE a.sseguro = psseguro
            AND a.cpregun = 2893
            AND a.nriesgo = pnriesgo
            AND a.cgarant = pcgarant
            AND a.nmovimi = pnmovimi;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            v_crespue_2893 := 0;
      END;

      BEGIN
         SELECT NVL (a.crespue, 0)
           INTO v_crespue_2883
           FROM estpregunseg a
          WHERE a.sseguro = psseguro
            AND a.cpregun = 2883
            AND a.nriesgo = pnriesgo
            AND a.nmovimi = pnmovimi;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            v_crespue_2883 := 0;
      END;

      BEGIN
         SELECT NVL (a.crespue, 0)
           INTO v_crespue_2892
           FROM estpregungaranseg a
          WHERE a.sseguro = psseguro
            AND a.cpregun = 2892
            AND a.nriesgo = pnriesgo
            AND a.cgarant = pcgarant
            AND a.nmovimi = pnmovimi;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            v_crespue_2892 := 0;
      END;

      IF v_crespue_2893 <> 0
      THEN
         v_cap_act := v_crespue_2893;
      ELSE
         v_cap_act := v_crespue_2883 * v_crespue_2892 / 100;
      END IF;

      /*  p_tab_error (f_sysdate,
                     f_user,
                     'tar',
                     1,
                     psseguro,
                        SQLCODE
                     || ' - '
                     || SQLERRM
                     || ' v_crespue_2893 -->'
                     || v_crespue_2893
                     || ' v_crespue_2892-->'
                     || v_crespue_2892
                     || ' v_crespue_2883-->'
                     || v_crespue_2883
                    );*/
      IF pnmovimi = 1
      THEN
         v_capital := v_cap_act;
      ELSE
         v_capital := v_cap_act - v_cap_ant;

         IF v_capital = 0
         THEN
            v_capital := v_cap_act;
         END IF;

        
      END IF;

      RETURN v_capital;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN 0;
      WHEN OTHERS
      THEN
         RETURN 0;
   END f_capital_suplemento;

-- Ini IAXIS-3628 -- ECP -- 01/08/2019
-- Ini IAXIS-4802 --ECP --11/10/2019
   FUNCTION f_tasa_convenio_rc (
      psseguro   IN   NUMBER,
      pnriesgo   IN   NUMBER,
      pnmovimi   IN   NUMBER
   )
      RETURN NUMBER
   IS
      -- INI IAXIS-4205 CJMR 10/09/2019
      vobject     VARCHAR2 (200)      := 'PAC_FORMUL_CONF.F_TASA_CONVENIO_RC';
      vparam      VARCHAR2 (200)
         :=    'psseguro:'
            || psseguro
            || ', pnriesgo:'
            || pnriesgo
            || ', pnmovimi:'
            || pnmovimi;
      -- FIN IAXIS-4205 CJMR 10/09/2019
      num_err     NUMBER;
      v_tasa      NUMBER;
      v_tasa_d    NUMBER;
      v_sproduc   NUMBER;
      v_cagente   NUMBER;
      v_trespue   pregunpolseg.trespue%TYPE;
      v_crespue   pregunpolseg.crespue%TYPE;
      v_cactivi   NUMBER;
      vpasexec    NUMBER(8) := 1;  -- IAXIS-4205 CJMR 19/12/2019
   BEGIN
--   -- INI IAXIS-4205 CJMR 10/09/2019
--      num_err := pac_preguntas.f_get_pregunpolseg_t (psseguro, 2912, 'EST', v_trespue );

      --      IF num_err = 120135 THEN
--        p_tab_error (f_sysdate, f_user, vobject, 1, 'num_err:' || num_err || ', v_trespue' || v_trespue, 'No existe respuesta para pregunta 2912');
--      ELSIF num_err <> 0 THEN
--        RAISE e_object_error;
--      END IF;
--      p_tab_error (f_sysdate,
--                   f_user,
--                   'f_tasa_convenio_rc',
--                   1,
--                   1,
--                      SQLCODE
--                   || ' - '
--                   || SQLERRM
--                   || ' v_sproduc-->'
--                   || v_sproduc
--                   || ' v_cactivi-->'
--                   || v_cactivi
--                   || ' v_trespue-->'
--                   || v_trespue
--                   || ' v_crespue-->'
--                   || v_crespue
--                   || ' v_tasa-->'
--                   || v_tasa
--                  );

      --      IF v_trespue IS NOT NULL THEN
--p_tab_error (f_sysdate,
--                   f_user,
--                   'f_tasa_convenio_rc',
--                   1,
--                   1,
--                      SQLCODE
--                   || ' - '
--                   || SQLERRM
--                   || ' v_sproduc-->'
--                   || v_sproduc
--                   || ' v_cactivi-->'
--                   || v_cactivi
--                   || ' v_trespue-->'
--                   || v_trespue
--                   || ' v_crespue-->'
--                   || v_crespue
--                   || ' v_tasa-->'
--                   || v_tasa
--                  );
--          BEGIN
--            SELECT sproduc, cactivi
--            INTO v_sproduc, v_cactivi
--            FROM estseguros
--            WHERE sseguro = psseguro;
--          EXCEPTION
--            WHEN OTHERS THEN
--                SELECT sproduc, cactivi
--                INTO v_sproduc, v_cactivi
--                FROM seguros
--                WHERE sseguro = psseguro;
--          END;

      --          v_tasa := pac_subtablas.f_vsubtabla(-1, 9000007, 3333, 1, v_sproduc, v_cactivi, v_trespue, 7050);
--p_tab_error (f_sysdate,
--                   f_user,
--                   'f_tasa_convenio_rc',
--                   1,
--                   1,
--                      SQLCODE
--                   || ' - '
--                   || SQLERRM
--                   || ' v_sproduc-->'
--                   || v_sproduc
--                   || ' v_cactivi-->'
--                   || v_cactivi
--                   || ' v_trespue-->'
--                   || v_trespue
--                   || ' v_crespue-->'
--                   || v_crespue
--                   || ' v_tasa-->'
--                   || v_tasa
--                  );
--          BEGIN
--             UPDATE estpregungaranseg
--                SET crespue = v_tasa
--              WHERE sseguro = psseguro
--                AND cpregun = 8001
--                AND cgarant = 7050
--                AND nriesgo = pnriesgo
--                and nmovimi = pnmovimi;

      --             COMMIT;
--          END;
--         p_tab_error (f_sysdate,
--                   f_user,
--                   'f_tasa_convenio_rc',
--                   1,
--                   1,
--                      SQLCODE
--                   || ' - '
--                   || SQLERRM
--                   || ' v_sproduc-->'
--                   || v_sproduc
--                   || ' v_cactivi-->'
--                   || v_cactivi
--                   || ' v_trespue-->'
--                   || v_trespue
--                   || ' v_crespue-->'
--                   || v_crespue
--                   || ' v_tasa-->'
--                   || v_tasa
--                  );
--      ELSE
--          num_err := 0;

      --          num_err := pac_preguntas.f_get_pregungaranseg(psseguro, 7050, pnriesgo, 8001, 'EST', v_tasa );

      --          IF num_err = 120135 THEN
--            num_err := pac_preguntas.f_get_pregungaranseg(psseguro, 7050, pnriesgo, 8001, 'SEG', v_tasa );

      --            IF num_err <> 0 THEN
--                RAISE e_object_error;
--            END IF;

      --          ELSIF num_err <> 0 THEN
--            RAISE e_object_error;
--          END IF;
--          p_tab_error (f_sysdate,
--                   f_user,
--                   'f_tasa_convenio_rc',
--                   1,
--                   1,
--                      SQLCODE
--                   || ' - '
--                   || SQLERRM
--                   || ' v_sproduc-->'
--                   || v_sproduc
--                   || ' v_cactivi-->'
--                   || v_cactivi
--                   || ' v_trespue-->'
--                   || v_trespue
--                   || ' v_crespue-->'
--                   || v_crespue
--                   || ' v_tasa-->'
--                   || v_tasa
--                  );
--      END IF ;
--   -- FIN IAXIS-4205 CJMR 10/09/2019

      -- IAXIS-4205 CJMR 10/09/2019
      

      SELECT sproduc, cagente, cactivi
        INTO v_sproduc, v_cagente, v_cactivi
        FROM estseguros
       WHERE sseguro = psseguro;

      vpasexec := 2;
      
      BEGIN
         SELECT trespue
           INTO v_trespue
           FROM estpregunpolseg
          WHERE sseguro = psseguro AND cpregun = 2912 AND nmovimi = pnmovimi;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            v_trespue := '0';
      END;

      vpasexec := 3;
      
      BEGIN
         SELECT a.nval1
           INTO v_tasa
           FROM sgt_subtabs_det a
          WHERE a.csubtabla = 9000007
            AND a.cversubt = (SELECT MAX (b.cversubt)
                                FROM sgt_subtabs_ver b
                               WHERE b.csubtabla = a.csubtabla)
            AND ccla1 = v_sproduc
            AND ccla2 = v_cactivi
            AND ccla3 = v_trespue
            AND ccla4 = 7050;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            BEGIN
            -- INI IAXIS-4205 CJMR 19/12/2019
                 vpasexec := 4;
                 SELECT crespue
                   INTO v_tasa
                   FROM estpregungaranseg
                  WHERE sseguro = psseguro AND cpregun = 8001 AND nmovimi = pnmovimi;
               
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                   vpasexec := 5;
                   SELECT cresdef
                     INTO v_tasa
                     FROM pregunprogaran
                    WHERE sproduc = v_sproduc
                      AND cgarant = cgarant
                      AND cpregun = 8001
                      and cactivi = v_cactivi;
--                  v_tasa := 0;
            -- FIN IAXIS-4205 CJMR 19/12/2019
            END;
      END;
      
      p_tab_error (f_sysdate, f_user, vobject, vpasexec, 1,
                      SQLCODE || ' - ' || SQLERRM || 
                      ' v_sproduc-->' || v_sproduc || 
                      ' v_cactivi-->' || v_cactivi || 
                      ' v_trespue-->' || v_trespue || 
                      ' v_crespue-->' || v_crespue || 
                      ' v_tasa-->' || v_tasa);
      
      BEGIN
         vpasexec := 6;
         UPDATE estpregungaranseg
            SET crespue = v_tasa
          WHERE sseguro = psseguro
            AND cpregun = 8001
            AND cgarant = 7050
            AND nriesgo = pnriesgo
            AND nmovimi = pnmovimi;
            
           
      END;

      v_tasa := v_tasa / 100;
     
      -- INI IAXIS-4205 CJMR 10/09/2019
      RETURN v_tasa; -- / 100; CJMR 25/11/2019 la división ya se realiza en un paso anterior
   EXCEPTION
      WHEN e_object_error
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                      SQLCODE || ' - ' || SQLERRM
                     );
         RETURN NULL;
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                      SQLCODE || ' - ' || SQLERRM
                     );
         RETURN NULL;
   -- FIN IAXIS-4205 CJMR 10/09/2019
   END f_tasa_convenio_rc;
-- Ini IAXIS-4802 --ECP --11/10/2019 Se debe dejar así porque está generando error al calcular la Tarifa
END pac_formul_conf;
/