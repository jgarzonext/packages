/* Formatted on 2020/02/24 14:19 (Formatter Plus v4.8.8) */
--------------------------------------------------------
--  DDL for Package Body PAC_PROPIO_ALBVAL_CONF
--------------------------------------------------------

CREATE OR REPLACE PACKAGE BODY pac_propio_albval_conf
IS
   /******************************************************************************
      NOMBRE:    PAC_PROPIO_ALBVAL_CONF
      PROPSITO: Validacin de preguntas y garantas.
      REVISIONES:
      Ver        Fecha       Autor  Descripcin
      ---------  ----------  -----  ------------------------------------
      1.0        25/11/2016  LPP    Creacin
      2.0        22/01/2018   VCG   0001813: Nota Tcnica, funcionalidad parmetro Experiencia - Ramo Cumplimiento
      3.0        06/02/2018   VCG   0001855: Nota Tcnica, error Contragaranta en suplementos
      4.0        15/02/2018   VCG   0001870: Error suplementos (nota tcnica) al momento de realizar un tercer suplemento
      5.0        05/08/2019   ECP   IAXIS-4802. Convenio Grandes Beneficiarios - RCE Derivado de Contratos
     6.0        20/08/2019   CJMR  IAXIS-4200. Ajustes. Garanta permite prima manual = 0
     7.0        22/08/2019   ECP   IAXIS-4985. TArifa de Endosos
     8.0        24/02/2020   ECP   IAXIS-4985. TArifa de Endosos
   ******************************************************************************/
   FUNCTION f_val_preg_no_modif_sup (
      ptablas     IN   VARCHAR2,
      psseguro    IN   NUMBER,
      pnriesgo    IN   NUMBER,
      pfefecto    IN   DATE,
      pnmovimi    IN   NUMBER,
      pcgarant    IN   NUMBER,
      psproces    IN   NUMBER,
      pnmovima    IN   NUMBER,
      picapital   IN   NUMBER,
      pcrespue    IN   NUMBER,
      ptrespue    IN   VARCHAR2,
      pcpregun    IN   NUMBER
   )
      RETURN NUMBER
   IS
      n_preg_est   NUMBER;
      n_preg       NUMBER;
      n_err        NUMBER;
      n_sseguro    NUMBER;
   BEGIN
      SELECT ssegpol
        INTO n_sseguro
        FROM estseguros
       WHERE sseguro = psseguro;

      n_err :=
         pac_preguntas.f_get_pregungaranseg (n_sseguro,
                                             pcgarant,
                                             pnriesgo,
                                             pcpregun,
                                             'EST',
                                             n_preg_est
                                            );
      --Buscamos el valor actual de la pregunta
      n_err :=
         pac_preguntas.f_get_pregungaranseg (n_sseguro,
                                             pcgarant,
                                             pnriesgo,
                                             pcpregun,
                                             'SOL',
                                             n_preg
                                            );

      IF n_preg <> n_preg_est
      THEN
         RETURN 9910020;
      ELSE
         RETURN 0;
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN NULL;
   END f_val_preg_no_modif_sup;

   FUNCTION f_val_porcen_contragar (
      ptablas     IN   VARCHAR2,
      psseguro    IN   NUMBER,
      pnriesgo    IN   NUMBER,
      pfefecto    IN   DATE,
      pnmovimi    IN   NUMBER,
      cgarant     IN   NUMBER,
      psproces    IN   NUMBER,
      pnmovima    IN   NUMBER,
      picapital   IN   NUMBER,
      pcrespue    IN   NUMBER,
      ptrespue    IN   VARCHAR2
   )
      RETURN NUMBER
   IS
      n_contra   NUMBER;
      n_error    NUMBER;
   BEGIN
      --Buscamos el tipo de contragaranta
      n_error :=
         pac_preguntas.f_get_pregunseg (psseguro,
                                        pnriesgo,
                                        2702,
                                        ptablas,
                                        n_contra
                                       );

      IF n_contra = 2 AND TO_NUMBER (pcrespue) <> 110
      THEN               --Para el tipo Exceptuado el porcentaje ha de ser 110
         RETURN 9909807;
      ELSIF n_contra = 3 AND TO_NUMBER (pcrespue) <> 100
      THEN                   --Para el tipo Pagare el porcentaje ha de ser 100
         RETURN 9909808;
      ELSIF n_contra = 1 AND TO_NUMBER (pcrespue) = 0
      THEN                 --Para el tipo Real se permite cualquier porcentaje
         RETURN 9910276;
      ELSE
         RETURN 0;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END f_val_porcen_contragar;

   FUNCTION f_val_exento_contragar (
      ptablas     IN   VARCHAR2,
      psseguro    IN   NUMBER,
      pnriesgo    IN   NUMBER,
      pfefecto    IN   DATE,
      pnmovimi    IN   NUMBER,
      cgarant     IN   NUMBER,
      psproces    IN   NUMBER,
      pnmovima    IN   NUMBER,
      picapital   IN   NUMBER,
      pcrespue    IN   NUMBER,
      ptrespue    IN   VARCHAR2
   )
      RETURN NUMBER
   IS
      n_sperson   NUMBER;
      n_exento    NUMBER;
      n_cumulo    NUMBER;
      n_suplem    NUMBER;                                        --QT-0001855
   BEGIN
      IF pcrespue = 2
      THEN
         SELECT spereal
           INTO n_sperson
           FROM estper_personas
          WHERE sperson IN (SELECT t.sperson
                              FROM esttomadores t
                             WHERE t.sseguro = psseguro AND nordtom = 1);

         --Ini-qt-0001855-VCG-06/02/2018-Se valida que no sea alta poliza
         BEGIN
            SELECT nsuplem
              INTO n_suplem
              FROM estseguros
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS
            THEN
               n_suplem := 0;
         END;

         p_control_error ('1',
                          'pac_propio.f_val_exento_contragar',
                          'n_suplem:= ' || n_suplem
                         );

         IF n_suplem >= 0
         THEN
            BEGIN
               SELECT nvalpar
                 INTO n_exento
                 FROM per_parpersonas
                WHERE sperson = n_sperson AND cparam = 'PER_EXCENTO_CONTGAR';
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  BEGIN
                     SELECT nvalpar
                       INTO n_exento
                       FROM estper_parpersonas
                      WHERE sperson = n_sperson
                        AND cparam = 'PER_EXCENTO_CONTGAR';
                  EXCEPTION
                     WHEN NO_DATA_FOUND
                     THEN
                        n_exento := 0;
                  END;
            END;

            n_cumulo := NVL (pac_isqlfor_conf.f_cumulo_persona (n_sperson), 0);

            --Validamos que el tomador est exento de contragarantas o tenga un cmulo inferior a 100.000.000 para poder escoger la opcin EXCEPTUADO de la pregunta 2702
            IF n_exento IN (1, 0) AND n_cumulo < 100000000
            THEN            --QT-0001855-VCG-12/02/2018-Se modifica validacion
               RETURN 0;
            ELSIF n_exento IN (0, 1) AND n_cumulo > 100000000
            THEN            --QT-0001855-VCG-12/02/2018-Se adiciona validacion
               RETURN 0;
            ELSE            --QT-0001855-VCG-12/02/2018-Se adiciona validacion
               RETURN 9909809;
            --La persona no se encuentra exento de contragaranta
            END IF;
         END IF;
      END IF;

      --Fin-qt-0001855-VCG-06/02/2018
      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END f_val_exento_contragar;

   FUNCTION f_val_gest_comer (
      ptablas     IN   VARCHAR2,
      psseguro    IN   NUMBER,
      pnriesgo    IN   NUMBER,
      pfefecto    IN   DATE,
      pnmovimi    IN   NUMBER,
      cgarant     IN   NUMBER,
      psproces    IN   NUMBER,
      pnmovima    IN   NUMBER,
      picapital   IN   NUMBER,
      pcrespue    IN   NUMBER,
      ptrespue    IN   VARCHAR2
   )
      RETURN NUMBER
   IS
      n_sproduc   NUMBER;
      n_capital   NUMBER;
   BEGIN
      SELECT sproduc
        INTO n_sproduc
        FROM estseguros
       WHERE sseguro = psseguro;

      IF n_sproduc = 8033 AND TO_NUMBER (pcrespue) NOT BETWEEN 0 AND 40
      THEN
         RETURN 9909874;
      ELSIF n_sproduc <> 8033 AND TO_NUMBER (pcrespue) NOT BETWEEN 0 AND 30
      THEN
         RETURN 9909873;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END f_val_gest_comer;

   --Ini-Qtracker 0001813-VCG-22/01/2018- Se elimina la pregunta 6551
   /* FUNCTION f_val_anyo_cargue(
        ptablas IN VARCHAR2,
        psseguro IN NUMBER,
        pnriesgo IN NUMBER,
        pfefecto IN DATE,
        pnmovimi IN NUMBER,
        cgarant IN NUMBER,
        psproces IN NUMBER,
        pnmovima IN NUMBER,
        picapital IN NUMBER,
        pcrespue IN NUMBER,
        ptrespue IN VARCHAR2)
        RETURN NUMBER IS

      n_ctipper  NUMBER;

    BEGIN

      --1 Natural, 2 Jurdica
      SELECT P.CTIPPER
        INTO n_ctipper
        FROM ESTTOMADORES T, ESTPER_PERSONAS P
       WHERE P.SSEGURO = psseguro
         AND T.SPERSON = P.SPERSON
         AND NORDTOM=1;
      IF n_ctipper = 1 AND (pcrespue > 2100 or pcrespue<1900) THEN       --Ao vinculacin cliente debe estar informado
        RETURN 9909875;
      END IF;

      RETURN 0;

    EXCEPTION
      WHEN OTHERS THEN
        return null;
    END f_val_anyo_cargue;*/
   --Fin-Qtracker 0001813-VCG-22/01/2018- Se elimina la pregunta 6551
   FUNCTION f_valida_dto (
      ptablas     IN   VARCHAR2,
      psseguro    IN   NUMBER,
      pnriesgo    IN   NUMBER,
      pfefecto    IN   DATE,
      pnmovimi    IN   NUMBER,
      cgarant     IN   NUMBER,
      psproces    IN   NUMBER,
      pnmovima    IN   NUMBER,
      picapital   IN   NUMBER,
      pcrespue    IN   NUMBER,
      ptrespue    IN   VARCHAR2
   )
      RETURN NUMBER
   IS
      v_crespue   NUMBER;
      n_exento    NUMBER;
      num_err     NUMBER;
   BEGIN
      num_err :=
         pac_preguntas.f_get_pregunseg (psseguro,
                                        pnriesgo,
                                        6549,
                                        NVL (ptablas, 'SEG'),
                                        v_crespue
                                       );

      --Descuento   Usuarios
      --<=15% Suscriptores en General
      -->15% - <=25%   Asistentes Tcnicos
      -->25% - <=40%   Directores Tcnicos
      -->40% - <=90%   Gerente Tcnico de Lnea
      IF v_crespue NOT BETWEEN 0 AND 15
      THEN
         RETURN 9910275;
      ELSE
         RETURN 0;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END f_valida_dto;

   FUNCTION f_valida_consorcio (
      ptablas     IN   VARCHAR2,
      psseguro    IN   NUMBER,
      pnriesgo    IN   NUMBER,
      pfefecto    IN   DATE,
      pnmovimi    IN   NUMBER,
      pcgarant    IN   NUMBER,
      psproces    IN   NUMBER,
      pnmovima    IN   NUMBER,
      picapital   IN   NUMBER,
      pcrespue    IN   NUMBER,
      ptrespue    IN   VARCHAR2,
      pcpregun    IN   NUMBER
   )
      RETURN NUMBER
   IS
      n_consorcio   NUMBER;
      n_sperson     NUMBER;
      n_err         NUMBER;
   BEGIN
      IF ptablas = 'EST'
      THEN
         SELECT sperson
           INTO n_sperson
           FROM esttomadores
          WHERE sseguro = psseguro AND nordtom = 1;

         BEGIN
            SELECT 1
              INTO n_consorcio
              FROM estper_parpersonas
             WHERE cparam = 'PER_ASO_JURIDICA'
               AND nvalpar IN (1, 2)
               AND sperson = n_sperson
               AND ROWNUM = 1;
         EXCEPTION
            WHEN OTHERS
            THEN
               n_consorcio := 0;
         END;
      ELSE
         SELECT sperson
           INTO n_sperson
           FROM tomadores
          WHERE sseguro = psseguro AND nordtom = 1;

         BEGIN
            SELECT 1
              INTO n_consorcio
              FROM per_parpersonas
             WHERE cparam = 'PER_ASO_JURIDICA'
               AND nvalpar IN (1, 2)
               AND sperson = n_sperson
               AND ROWNUM = 1;
         EXCEPTION
            WHEN OTHERS
            THEN
               n_consorcio := 0;
         END;
      END IF;

      IF n_consorcio = 1 AND pcrespue = 0
      THEN
         RETURN 9910287;
      ELSIF n_consorcio = 0 AND pcrespue IN (1, 2)
      THEN
         RETURN 9910286;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN NULL;
         RETURN 0;
   END f_valida_consorcio;

   FUNCTION f_valida_minimo (
      ptablas     IN   VARCHAR2,
      psseguro    IN   NUMBER,
      pnriesgo    IN   NUMBER,
      pfefecto    IN   DATE,
      pnmovimi    IN   NUMBER,
      cgarant     IN   NUMBER,
      psproces    IN   NUMBER,
      pnmovima    IN   NUMBER,
      picapital   IN   NUMBER,
      pcrespue    IN   NUMBER,
      ptrespue    IN   VARCHAR2,
      pminimo     IN   NUMBER
   )
      RETURN NUMBER
   IS
   BEGIN
      IF pcrespue < pminimo
      THEN
         RETURN 9910453;
      ELSE
         RETURN 0;
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN 0;
   END f_valida_minimo;

-- Ini IAXIS- 4082  -- ECP -- 05/08/2019
   FUNCTION f_val_nit_contratante (
      ptablas     IN   VARCHAR2,
      psseguro    IN   NUMBER,
      pnriesgo    IN   NUMBER,
      pfefecto    IN   DATE,
      pnmovimi    IN   NUMBER,
      cgarant     IN   NUMBER,
      psproces    IN   NUMBER,
      pnmovima    IN   NUMBER,
      picapital   IN   NUMBER,
      pcrespue    IN   NUMBER,
      ptrespue    IN   VARCHAR2
   )
      RETURN NUMBER
   IS
      n_persona   NUMBER;
      v_existe    NUMBER;
      v_sproduc   NUMBER;
      v_cactivi   NUMBER;
      v_cagente   NUMBER;

      CURSOR c_personas
      IS
         SELECT COUNT (sperson)
           FROM per_personas
          WHERE nnumide = ptrespue;
   BEGIN
      BEGIN
         SELECT sproduc, cactivi, cagente
           INTO v_sproduc, v_cactivi, v_cagente
           FROM estseguros
          WHERE sseguro = psseguro;
      END;

      IF v_cactivi = 1
      THEN
         BEGIN
            SELECT 1
              INTO v_existe
              FROM convcomesptom a, convcomespage b
             WHERE a.sperson = (SELECT b.sperson
                                  FROM per_personas b
                                 WHERE b.nnumide = ptrespue)
               AND a.idconvcomesp = b.idconvcomesp
               AND b.cagente = v_cagente;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               v_existe := 0;
         END;

         p_tab_error (f_sysdate,
                      f_user,
                      'f_val_nit_contratante',
                      1,
                      1,
                         SQLCODE
                      || ' - '
                      || SQLERRM
                      || ' v_existe-->'
                      || v_existe
                      || ' ptrespue-->'
                      || ptrespue
                      || ' v_cagente-->'
                      || v_cagente
                      || ' v_cactivi-->'
                      || v_cactivi
                      || ' v_sproduc-->'
                      || v_sproduc
                     );

         IF v_existe = 0
         THEN
            RETURN 9909269;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END f_val_nit_contratante;

-- Fin IAXIS- 4082  -- ECP -- 05/08/2019
   FUNCTION f_val_preg_valor (
      ptablas     IN   VARCHAR2,
      psseguro    IN   NUMBER,
      pnriesgo    IN   NUMBER,
      pfefecto    IN   DATE,
      pnmovimi    IN   NUMBER,
      pcgarant    IN   NUMBER,
      psproces    IN   NUMBER,
      pnmovima    IN   NUMBER,
      picapital   IN   NUMBER,
      pcrespue    IN   NUMBER,
      ptrespue    IN   VARCHAR2,
      pcpregun    IN   NUMBER
   )
      RETURN NUMBER
   IS
      v_param   NUMBER := 0;                   --  IAXIS-4200 CJMR 20/08/2019
   BEGIN
       -- INI IAXIS-4200 CJMR 20/08/2019
      --IF pcrespue <= 0 THEN
      v_param :=
         NVL
            (pac_parametros.f_pargaranpro_n
                        (pac_iax_produccion.poliza.det_poliza.sproduc,
                         pac_iax_produccion.poliza.det_poliza.gestion.cactivi,
                         pcgarant,
                         'PRIMA_MANUAL_0'
                        ),
             0
            );

      IF pcrespue <= 0 AND v_param = 0 AND pac_iax_produccion.poliza.det_poliza.sproduc NOT in (8063, 80004, 80005, 80006, 80008, 80010, 80041, 80042, 80043, 80038)

      THEN
         -- FIN IAXIS-4200 CJMR 20/08/2019
         RETURN 89906166;
      ELSE
         RETURN 0;
      END IF;
   END f_val_preg_valor;

   -- Ini IAXIS-4985 -- ECP -- 24/02/2020
    -- Ini IAXIS-4985 -- ECP -- 22/08/2019
   FUNCTION f_val_preg_recargo (
      ptablas     IN   VARCHAR2,
      psseguro    IN   NUMBER,
      pnriesgo    IN   NUMBER,
      pfefecto    IN   DATE,
      pnmovimi    IN   NUMBER,
      pcgarant    IN   NUMBER,
      psproces    IN   NUMBER,
      pnmovima    IN   NUMBER,
      picapital   IN   NUMBER,
      pcrespue    IN   NUMBER,
      ptrespue    IN   VARCHAR2,
      pcpregun    IN   NUMBER
   )
      RETURN NUMBER
   IS
      v_recargo     NUMBER;
      v_recargo_a   NUMBER;
      v_cont        NUMBER;
   BEGIN
      IF pcpregun = 6623
      THEN
         IF pnmovimi > 1
         THEN
            BEGIN
               SELECT a.crespue
                 INTO v_recargo
                 FROM estpregungaranseg a
                WHERE a.sseguro = psseguro
                  AND a.nriesgo = pnriesgo
                  AND a.cgarant = pcgarant
                  AND a.cpregun = pcpregun
                  AND a.nmovimi = pnmovimi;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  v_recargo := 0;
            END;

            BEGIN
               SELECT a.crespue
                 INTO v_recargo_a
                 FROM pregungaranseg a
                WHERE a.sseguro = (SELECT ssegpol
                                     FROM estseguros
                                    WHERE sseguro = psseguro)
                  AND a.nriesgo = pnriesgo
                  AND a.cgarant = pcgarant
                  AND a.cpregun = pcpregun
                  AND a.nmovimi =
                         (SELECT MAX (b.nmovimi)
                            FROM pregungaranseg b
                           WHERE b.sseguro = b.sseguro
                             AND b.nriesgo = b.nriesgo
                             AND b.cgarant = b.cgarant
                             AND b.cpregun = b.cpregun
                             AND b.nmovimi < pnmovimi);
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  v_recargo_a := 0;
            END;

            

            IF (v_recargo_a - v_recargo) = 0
            THEN
               BEGIN
                  UPDATE estpregungaranseg a
                     SET crespue = 0
                   WHERE a.sseguro = psseguro
                     AND a.nriesgo = pnriesgo
                     AND a.cgarant = pcgarant
                     AND a.cpregun = pcpregun
                     AND a.nmovimi = pnmovimi;

                  p_tab_error (f_sysdate,
                               f_user,
                               'f_val_preg_recargo',
                               1,
                               1,
                                  SQLCODE
                               || ' - ENTRA -'
                               || SQLERRM
                               || ' v_recargo-->'
                               || v_recargo
                               || ' v_recargo_a-->'
                               || v_recargo_a
                               || ' pnmovimi-->'
                               || pnmovimi
                               || ' pcpregun-->'
                               || pcpregun
                               || ' pcgarant-->'
                               || pcgarant
                               || ' psseguro-->'
                               || psseguro
                               || ' pnriesgo-->'
                               || pnriesgo
                              );
               END;
            END IF;

            RETURN 0;
         ELSE
            RETURN 0;
         END IF;
      ELSE
         RETURN 0;
      END IF;
   END f_val_preg_recargo;
-- Fin IIni IAXIS-4985 -- ECP -- 24/02/2020
END pac_propio_albval_conf;
/