/* Formatted on 2019/08/07 23:48 (Formatter Plus v4.8.8) */
--------------------------------------------------------
--  DDL for Package Body PAC_PROPIO_ALBSGT_CONF
--------------------------------------------------------

CREATE OR REPLACE PACKAGE BODY pac_propio_albsgt_conf
IS
   /******************************************************************************
      NOMBRE:     pac_propio_albsgt_conf
      PROPÓSITO:  Cuerpo del paquete de las funciones para
                  el cáculo de las preguntas relacionadas con
                  productos de LCOL
      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        20/07/2011   JLTS            1. XXXXXX: CONF - Parametrización básica producto Vida Individual Pagos Permanentes
      2.0        12/09/2011   DRA             2. 0018351: LCOL003 - Documentación requerida en contratación y suplementos
      3.0        07/11/2011   JRH             3. 0019612: LCOL_T004: Formulación productos Vida Individual
      4.0        08/11/2011   RSC             4. 0019808: LCOL_T004-Parametrización de suplementos
      5.0        09/12/2011   RSC             5. 0019312: LCOL_T004 - Parametrización Anulaciones
      6.0        12/12/2011   RSC             6. 0020163: LCOL_T004-Completar parametrización de los productos de Vida Individual (2ª parte)
      7.0        16/12/2011   RSC             7. 0020163: LCOL_T004-Completar parametrización de los productos de Vida Individual (2ª parte)
      8.0        21/12/2011   RSC             8. 0019612: LCOL_T004: Formulación productos Vida Individual
      9.0        14/01/2012   JRH             9. 0020671: LCOL_T001-LCOL - UAT - TEC: Contrataci?n
      10.0       27/02/2012   RSC             10.0021167: LCOL_T001-LCOL - UAT - TEC: Incidencias del proceso de Cartera
      11.0       02/05/2012   RSC             11.0021863: LCOL_F001-LCOL - Incidencias Reservas
      12.0       25/09/2012   DCG             12.0023130: LCOL_F002-Provisiones para polizas estatales
      13.0       24/10/2012   DRA             13.0023853: LCOL - PRIMAS MÍNIMAS PACTADAS POR PÓLIZA Y POR COBRO
      14.0       07/11/2012   DCT             14.0024058: LCOL - 0024058: LCOL_T010-LCOL - Parametrizaci?n de productos Vida Grupo
      15.0       23/01/2012   ECP             15.0025583: LCOL - Revision incidencias qtracker (IV)
      16.0       25/02/2013   MRB             16.0025890: lcol - Modificar F_AUTOS_ANTIGUEDAD
                 27/02/2013   MRB             F_COPIA_PREGUNTA
                 27/02/2013   MRB             F_BUSCAFRAN -- PCQUE   0 => Movimiento actual
                                                                     1 => Movimiento inmediatamente anterior
                                                                   404 => Movimiento inmediatamente anterior de cartera
                 04/03/2013   MRB             Canvis a F_AUTOS_ANTIGUEDAD (Dilluns matí) i modIficació XEMA
                 07/03/2013   MRB             Afegeixo modificacióm J.L.Vázquez F_RESPUE_RETORNO
                 13/03/2013   MRB             Substitució F_AUTOS_ANTIGUEDAD Y F_DISCRIMINANTE
                 19/03/2013   MRB             F_SUCURSAL
                 20/03/2013   MRB             F_FACTOR_DISPOSI - F_FACTOR_DEDUCI
      17.0       02/04/2013   FAL             17. 0025739: LCOL_T031-LCOL - Fase 3 - (Id 176-10) - Parametrizaci?n producto PESADOS INDIVIDUAL (6039)
                 05/04/2013   MRB             Modificación f_autos_antiguedad (Moviment zero)
                 09/04/2013   MRB             F_MAX_SUBTAB
      18.0       11/04/2013   APD             0026662: LCOL - AUT - Plan de beneficios
      19.0       14/05/2013   APD             0026738: LCOL - AUT - Pregunta de descuento por campaña
      20.0       30/05/2013   ECP             0026923: LCOL - TEC - Revisión Q-Trackers Fase 3A. Nota 145435
      21.0       01/07/2013   APD             0026923: LCOL - TEC - Revisión Q-Trackers Fase 3A. Nota 147980
      22.0       18/07/2013   DCT             0027539: LCOL_T010-LCOL - Revision incidencias qtracker (VII)
      23.0       21/08/2013   JDS             0027539: LCOL_T010-LCOL - Revision incidencias qtracker (VII)
      24.0       02/09/2013   JSV             0025900: LCOL - Parametrización AUTOS TS/TU -TAXIS INDIVIDUAL CON Y SIN R.C. (6038)
      25.0       03/09/2013   JSV             0028041: LCOL_F3B-Tarificacion Autos Colectivo AWL
      26.0       02/10/2013   JSV             0025896: LCOL - Parametrización AUTOS MT - MOTOS (6034)
      27.0       05/10/2013   MRB             0025899: LCOL - Parametrización AUTOS AUT - AUTOS TASA UNICA (6037)
      28.0       07/10/2013   DCT             0028027: LCOL_PROD-0008983: Solucion de Fondo a Disminucion del valor del reaseguro en la renovaci?n de la poliza 43, 1153 y 1622
      29.0       12/11/2013   JMG             0028832: LCOL_PROD-0009923: Solución definitiva vigencia del seguro
      30.0       04/01/2014   JLTS            0029553: LCOL_PROD_0010783: Nota interna 162538. Solución alternativa para ftaxeda en la funcion f_arrastra_tasa
      31.0       25/03/2014   JSV             0030700: LCOL_T031-Revisión Q-Trackers Fase 3A Puesta en producción
      32.0       16/04/2014   JSV             0030842: LCOL_T010-Revision incidencias qtracker (2014/04)
      33.0       11/06/2014   SSM             1051/176803: LCOL_T031-Revisión Q-Trackers Fase 3A Producción
      34.0       09/12/2014   JLTS            33752/0193820_QT0015717: 0015627: 0015519: ADN 45 - Póliza 34701 - Emite colecitvo y la póliza le queda en propuesta de suplemento
                                              Se modifica la funcion f_respue_retorno y se adiciona la condición   IF ptablas = 'EST' THEN
      35.0       13/02/2015   CAM             0016913:LCOL_LIB060 Optimización Procesos de Vida Grupo Función f_edad_promedio para Certificado Cero
      36.0       08/09/2016   NMM             36. Función f_capacidad_contrato.
      37.0       24/10/2016   LPP             Añado función f_respues_recibo_por que da la respuesta en función del tipo colectivo a la pregunta Recibo por
      38.0       22/01/2017   VCG             0001813: Nota Técnica, funcionalidad parámetro Experiencia - Ramo Cumplimiento
      39.0       29/01/2017   VCG             0001836: Error pantalla axisctr207 Amparos , no permite continuar con la expedición
      40.0       05/02/2017   VCG             0001834: Nota Técnica, error Fecha Constitución Persona Jurídica
      41.0       06/02/2017   VCG             0001853: Nota Técnica, Error Scoring -Factor de Descuento
      42.0       09/02/2017   VCG             0001855: Nota Técnica, error Contragarantía en suplementos
      43.0       16/02/2017   VCG             0001888: Error Nota Técnica, Capacidad Financiera (pantallas axisctr207)
      44.0       31/05/2019   ECP             IAXIS-3628. Actualización de nota técnica a Marzo 2019
      45.0       05/08/2019   ECP             IAXIS-4082. Convenio Grandes Beneficiarios - RCE Derivado de Contratos
      46.0       26/02/2020   ECP             IAXIS-6224. Endosos con prima (0) no generan Recibo, aplica para Cumplimiento y RC
     ******************************************************************************/
   /*************************************************************************
      FUNCTION f_capacidad_contrato

      param in psseguro  : Identificador seguro
      param in pctiprea  : tipo reaseguro
      param in mensajes  : t_iax_mensajes
      return             : number
   *************************************************************************/
   FUNCTION f_capacidad_contrato (
      ptablas     IN   VARCHAR2,
      psseguro    IN   NUMBER,
      pnriesgo    IN   NUMBER,
      pfefecto    IN   DATE,
      pnmovimi    IN   NUMBER,
      cgarant     IN   NUMBER,
      psproces    IN   NUMBER,
      pnmovima    IN   NUMBER,
      picapital   IN   NUMBER
   )
      RETURN NUMBER
   IS
      --
      vcramo      NUMBER;
      vsproduc    NUMBER;
      vcmodali    NUMBER;
      vctipseg    NUMBER;
      vcactivi    NUMBER;
      vcrespue    NUMBER;
      vresult     NUMBER;
      --
      w_scontra   NUMBER;
      w_nversio   NUMBER;
      w_ipleno    NUMBER;
      w_icapaci   NUMBER;
      w_cdetces   NUMBER;
      --
      wobject     VARCHAR2 (4000)
                             := 'PAC_PROPIO_ALBSGT_CONF.f_capacidad_contrato';
      wparam      VARCHAR2 (4000)
         :=    '1.-'
            || ptablas
            || ';2.-'
            || psseguro
            || ';3.-'
            || pnriesgo
            || ';4.-'
            || pfefecto
            || ';5.-'
            || pnmovimi
            || ';6.-'
            || cgarant
            || ';7.-'
            || psproces
            || ';8.-'
            || pnmovima
            || ';9.-'
            || picapital;
      --
      vnumerr     NUMBER;
   --
   BEGIN
      --
      SELECT cramo, sproduc, cmodali, ctipseg, cactivi
        INTO vcramo, vsproduc, vcmodali, vctipseg, vcactivi
        FROM estseguros
       WHERE sseguro = psseguro;

      --
      SELECT crespue
        INTO vcrespue
        FROM estpregunseg
       WHERE sseguro = psseguro AND cpregun = 2880;

      --
      vnumerr :=
         f_buscacontrato (psseguro       => psseguro,
                          fpolefe        => pfefecto,
                          w_cempres      => f_empres,
                          w_cgarant      => NULL,
                          w_cramo        => vcramo,
                          w_cmodali      => vcmodali,
                          w_ctipseg      => vctipseg,
                          w_ccolect      => 0,
                          w_cactivi      => vcactivi,
                          pmotiu         => NULL,
                          w_scontra      => w_scontra,
                          w_nversio      => w_nversio,
                          w_ipleno       => w_ipleno,
                          w_icapaci      => w_icapaci,
                          w_cdetces      => w_cdetces
                         );
      --
      vresult :=
         pac_subtablas.f_vsubtabla (p_in_nsesion        => -1,
                                    p_in_csubtabla      => 8000045,
                                    p_in_cquery         => 33,
                                    p_in_cval           => 1,
                                    p_in_ccla1          => vsproduc,
                                    p_in_ccla2          => vcrespue
                                   );

      --
      IF NVL (vresult, 0) = 1
      THEN
         RETURN w_icapaci;
      END IF;

      --
      RETURN 0;
   --
   EXCEPTION
      WHEN OTHERS
      THEN
         --
         RETURN NULL;
   --
   END f_capacidad_contrato;

   --
   FUNCTION f_edad_riesgo (
      ptablas     IN   VARCHAR2,
      psseguro    IN   NUMBER,
      pnriesgo    IN   NUMBER,
      pfefecto    IN   DATE,
      pnmovimi    IN   NUMBER,
      cgarant     IN   NUMBER,
      psproces    IN   NUMBER,
      pnmovima    IN   NUMBER,
      picapital   IN   NUMBER
   )
      RETURN NUMBER
   IS
      v_fnacimi    DATE;
      v_ssegpol    NUMBER;
      v_fefecto    DATE;
      v_fecha      DATE;
      v_edad       NUMBER;
      v_fcaranu    DATE;
      num_err      NUMBER;
      /* Bug 10539 - RSC - 25/06/2009 - Pólizas con error en el cálculo de la edad*/
      n_retafrac   NUMBER (1);
      v_cursor     NUMBER;
      ss           VARCHAR2 (3000);
      funcion      VARCHAR2 (40);
      v_filas      NUMBER;
      p_sproduc    seguros.sproduc%TYPE;
   /* Fin Bug 10539*/
   BEGIN
      IF ptablas = 'EST'
      THEN
         /* Estamos en nueva produccion o suplementos*/
         /* Es la fecha efecto del riesgo, tanto para nueva producción como para suplementos*/
         BEGIN
            /* Añadimos: , s.fcaranu*/
            SELECT fnacimi, ssegpol, r.fefecto, s.fcaranu
              INTO v_fnacimi, v_ssegpol, v_fefecto, v_fcaranu
              FROM estriesgos r, estper_personas p, estseguros s
             WHERE r.sseguro = psseguro
               AND s.sseguro = r.sseguro
               AND r.sperson = p.sperson
               AND r.nriesgo = pnriesgo;
         EXCEPTION
            WHEN OTHERS
            THEN
               RETURN NULL;
         END;

         IF pfefecto = v_fcaranu
         THEN
            v_fecha := pfefecto;
         ELSE
            /* Fin Bug 11664*/
            BEGIN
               SELECT MAX (fefecto)
                 INTO v_fecha
                 FROM movseguro
                WHERE sseguro = v_ssegpol AND cmovseg = 2;

               IF (v_fecha IS NULL) OR (v_fecha < v_fefecto)
               THEN
                  v_fecha := v_fefecto;
               END IF;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  v_fecha := v_fefecto;
            END;
         END IF;

         num_err := f_difdata (v_fnacimi, v_fecha, 1, 1, v_edad);
      ELSIF ptablas = 'SOL'
      THEN
         /* Estamos en nueva produccion o suplementos*/
         BEGIN
            SELECT fnacimi, s.falta
              INTO v_fnacimi, v_fefecto
              FROM solriesgos r, solseguros s
             WHERE r.ssolicit = psseguro
               AND s.ssolicit = r.ssolicit
               AND r.nriesgo = pnriesgo;
         EXCEPTION
            WHEN OTHERS
            THEN
               RETURN NULL;
         END;

         num_err := f_difdata (v_fnacimi, v_fefecto, 1, 1, v_edad);
      ELSE
         /* Bug 10539 - RSC - 25/06/2009 - Pólizas con error en el cálculo de la edad*/
         SELECT sproduc
           INTO p_sproduc
           FROM seguros
          WHERE sseguro = psseguro;

         /* Fin Bug 10539*/
           /* Estamos cartera*/
         BEGIN
            /*Bug10612 - 08/07/2009 - DCT (canviar vista personas)*/
            SELECT p.fnacimi, r.fefecto, s.fcaranu
              INTO v_fnacimi, v_fefecto, v_fcaranu
              FROM riesgos r, per_personas p, seguros s
             WHERE r.sseguro = psseguro
               AND s.sseguro = r.sseguro
               AND r.sperson = p.sperson
               AND r.nriesgo = pnriesgo;
         /*SELECT fnacimi, r.fefecto, s.fcaranu
           INTO v_fnacimi, v_fefecto, v_fcaranu
           FROM riesgos r, personas p, seguros s
          WHERE r.sseguro = psseguro
            AND s.sseguro = r.sseguro
            AND r.sperson = p.sperson
            AND r.nriesgo = pnriesgo;*/
         /*Bug10612 - 08/07/2009 - DCT (canviar vista personas)*/
         EXCEPTION
            WHEN OTHERS
            THEN
               RETURN NULL;
         END;

         /* Bug 10539 - RSC - 25/06/2009 - Pólizas con error en el cálculo de la edad*/
         IF NVL (f_parproductos_v (p_sproduc, 'FRACCIONARIO'), 0) = 1
         THEN
            SELECT MAX (tvalpar)
              INTO funcion
              FROM detparpro
             WHERE cparpro = 'F_PRFRACCIONARIAS'
               AND cidioma = 2
               AND cvalpar =
                      (SELECT cvalpar
                         FROM parproductos
                        WHERE sproduc = p_sproduc
                          AND cparpro = 'F_PRFRACCIONARIAS');

            IF funcion IS NOT NULL
            THEN
               ss := 'begin :n_retafrac := ' || funcion || '; end;';

               IF DBMS_SQL.is_open (v_cursor)
               THEN
                  DBMS_SQL.close_cursor (v_cursor);
               END IF;

               v_cursor := DBMS_SQL.open_cursor;
               DBMS_SQL.parse (v_cursor, ss, DBMS_SQL.native);

               IF INSTR (ss, ':psseguro') > 0
               THEN
                  DBMS_SQL.bind_variable (v_cursor, ':psseguro', psseguro);
               END IF;

               IF INSTR (ss, ':pfecha') > 0
               THEN
                  DBMS_SQL.bind_variable (v_cursor, ':pfecha', pfefecto);
               END IF;

               IF INSTR (ss, ':n_retafrac') > 0
               THEN
                  DBMS_SQL.bind_variable (v_cursor, ':n_retafrac', num_err);
               END IF;

               v_filas := DBMS_SQL.EXECUTE (v_cursor);
               DBMS_SQL.variable_value (v_cursor, 'n_retafrac', n_retafrac);

               IF DBMS_SQL.is_open (v_cursor)
               THEN
                  DBMS_SQL.close_cursor (v_cursor);
               END IF;
            END IF;
         END IF;

         /* Fin Bug 10539*/
         /* Bug 10539 - RSC - 25/06/2009 - Pólizas con error en el cálculo de la edad*/
           /* Añadimos: AND n_retafrac IS NULL) OR n_retafrac = 1*/
         IF (pfefecto = v_fcaranu AND n_retafrac IS NULL) OR n_retafrac = 1
         THEN
            /* si es cartera utilizamos la fecha de efecto (que será la fcaranu de la póliza)*/
            v_fecha := pfefecto;
         ELSE
            BEGIN
               SELECT MAX (fefecto)
                 INTO v_fecha
                 FROM movseguro
                WHERE sseguro = psseguro AND cmovseg = 2;

               IF (v_fecha IS NULL) OR (v_fecha < v_fefecto)
               THEN
                  v_fecha := v_fefecto;
               END IF;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  v_fecha := v_fefecto;
            END;
         END IF;

         num_err := f_difdata (v_fnacimi, v_fecha, 1, 1, v_edad);
      /*v_edad := TRUNC(MONTHS_BETWEEN(v_fecha, (ADD_MONTHS(v_fnacimi, -6) + 1)) / 12);*/
      END IF;

      RETURN v_edad;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 22222;
   END f_edad_riesgo;

   FUNCTION f_aportacion (
      ptablas     IN   VARCHAR2,
      psseguro    IN   NUMBER,
      pnriesgo    IN   NUMBER,
      pfefecto    IN   DATE,
      pnmovimi    IN   NUMBER,
      cgarant     IN   NUMBER,
      psproces    IN   NUMBER,
      pnmovima    IN   NUMBER,
      picapital   IN   NUMBER
   )
      RETURN NUMBER
   IS
      v_capital   NUMBER;
      v_pipc      NUMBER;
      v_prevali   NUMBER;
      /* BUG 18423 - I - 27/12/2011 - JLB - LCOL000 - Multimoneda*/
      vmoneda     monedas.cmoneda%TYPE;
   /* BUG 18423 - F - 27/12/2011 - JLB - LCOL000 - Multimoneda*/
   BEGIN
      IF ptablas = 'EST'
      THEN
         SELECT NVL (icapital, 0)
           INTO v_capital
           FROM tmp_garancar t, estseguros e
          WHERE t.sseguro = psseguro
            AND e.sseguro = t.sseguro
            AND sproces = psproces
            AND t.nriesgo = pnriesgo
            AND t.nmovi_ant = pnmovimi
            AND f_pargaranpro_v (e.cramo,
                                 e.cmodali,
                                 e.ctipseg,
                                 e.ccolect,
                                 e.cactivi,
                                 t.cgarant,
                                 'TIPO'
                                ) = 3;                         -- PRIMA AHORRO
      ELSIF ptablas = 'SOL'
      THEN
         SELECT NVL (icapital, 0)
           INTO v_capital
           FROM tmp_garancar t, solseguros e
          WHERE t.sseguro = psseguro
            AND e.ssolicit = t.sseguro
            AND sproces = psproces
            AND t.nriesgo = pnriesgo
            AND t.nmovi_ant = pnmovimi
            AND f_pargaranpro_v (e.cramo,
                                 e.cmodali,
                                 e.ctipseg,
                                 e.ccolect,
                                 e.cactivi,
                                 t.cgarant,
                                 'TIPO'
                                ) = 3;                         -- PRIMA AHORRO
      ELSE
         BEGIN
            SELECT pipc
              INTO v_pipc
              FROM ipc
             WHERE nmes = 0 AND nanyo = TO_CHAR (pfefecto, 'yyyy');
         EXCEPTION
            WHEN OTHERS
            THEN
               v_pipc := NULL;
         END;

         SELECT NVL (icapital, 0),
                DECODE (s.crevali,
                        2, s.prevali,
                        5, DECODE (ptablas, 'CAR', v_pipc, 0),       --v_pipc,
                        0
                       )
                        /* BUG 18423 - I - 27/12/2011 - JLB - LCOL000 - Multimoneda*/
         ,
                pac_monedas.f_moneda_producto (sproduc)
           /* BUG 18423 - F - 27/12/2011 - JLB - LCOL000 - Multimoneda*/
         INTO   v_capital,
                v_prevali
                         /* BUG 18423 - I - 27/12/2011 - JLB - LCOL000 - Multimoneda*/
         ,
                vmoneda
           /* BUG 18423 - F - 27/12/2011 - JLB - LCOL000 - Multimoneda*/
         FROM   garanseg g, seguros s
          WHERE g.sseguro = psseguro
            AND s.sseguro = g.sseguro
            AND g.nriesgo = pnriesgo
            AND g.nmovimi = pnmovimi
            AND f_pargaranpro_v (s.cramo,
                                 s.cmodali,
                                 s.ctipseg,
                                 s.ccolect,
                                 s.cactivi,
                                 g.cgarant,
                                 'TIPO'
                                ) = 3;                         -- PRIMA AHORRO

         IF ptablas = 'CAR' AND v_prevali IS NOT NULL AND v_prevali <> 0
         THEN
            v_capital := f_round (v_capital * (1 + v_prevali / 100),
                                  /* BUG 18423 - I - 27/12/2011 - JLB - LCOL000 - Multimoneda*/
                                  /*1*/
                                  vmoneda
                                         /* BUG 18423 - F - 27/12/2011 - JLB - LCOL000 - Multimoneda*/
                        );
         END IF;
      END IF;

      RETURN v_capital;
   EXCEPTION
      WHEN OTHERS
      THEN
         /*DBMS_OUTPUT.put_line('error aportacion ' || SQLERRM);*/
         RETURN 0;
   END f_aportacion;

   FUNCTION f_aportextr (
      ptablas     IN   VARCHAR2,
      psseguro    IN   NUMBER,
      pnriesgo    IN   NUMBER,
      pfefecto    IN   DATE,                                  -- No s'utilitza
      pnmovimi    IN   NUMBER,
      cgarant     IN   NUMBER,
      psproces    IN   NUMBER,
      pnmovima    IN   NUMBER,                                -- No s'utilitza
      picapital   IN   NUMBER                                 -- No s'utilitza
   )
      RETURN NUMBER
   IS
      v_capital   NUMBER;
   BEGIN
      IF ptablas = 'EST'
      THEN
         BEGIN
            SELECT NVL (icapital, 0)
              INTO v_capital
              FROM tmp_garancar t, estseguros e
             WHERE t.sseguro = psseguro
               AND e.sseguro = t.sseguro
               AND sproces = psproces
               AND t.nriesgo = pnriesgo
               AND t.nmovi_ant = pnmovimi
               AND f_pargaranpro_v (e.cramo,
                                    e.cmodali,
                                    e.ctipseg,
                                    e.ccolect,
                                    e.cactivi,
                                    t.cgarant,
                                    'TIPO'
                                   ) = 4;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               v_capital := 0;
         /*SELECT nvl(icapital,0)
          INTO v_capital
          FROM TMP_GARANCAR t, estseguros e
          WHERE t.sseguro = psseguro
           and e.sseguro = t.sseguro
            AND sproces = psproces
            AND t.nriesgo = pnriesgo
            AND t.nmovi_ant = pnmovimi
            AND f_pargaranpro_v(e.cramo, e.cmodali, e.ctipseg, e.ccolect, e.cactivi,
                                t.cgarant, 'TIPO') = 3; -- PRIMA EXTRAORDINARIA*/
         END;
      ELSIF ptablas = 'SOL'
      THEN
         BEGIN
            SELECT NVL (icapital, 0)
              INTO v_capital
              FROM tmp_garancar t, solseguros e
             WHERE t.sseguro = psseguro
               AND e.ssolicit = t.sseguro
               AND sproces = psproces
               AND t.nriesgo = pnriesgo
               AND t.nmovi_ant = pnmovimi
               AND f_pargaranpro_v (e.cramo,
                                    e.cmodali,
                                    e.ctipseg,
                                    e.ccolect,
                                    e.cactivi,
                                    t.cgarant,
                                    'TIPO'
                                   ) = 4;              -- PRIMA EXTRAORDINARIA
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               v_capital := 0;
                    /*JRH 08/2008 Aquí lo hacemos así*/
/* SELECT nvl(icapital,0)
   INTO v_capital
   FROM TMP_GARANCAR t, solseguros e
   WHERE t.sseguro = psseguro
    and e.ssolicit = t.sseguro
     AND sproces = psproces
     AND t.nriesgo = pnriesgo
     AND t.nmovi_ant = pnmovimi
     AND f_pargaranpro_v(e.cramo, e.cmodali, e.ctipseg, e.ccolect, e.cactivi,
                         t.cgarant, 'TIPO') = 3; -- PRIMA AHORRO*/
         END;
      ELSE
         BEGIN
            SELECT NVL (icapital, 0)
              INTO v_capital
              FROM garanseg g, seguros s
             WHERE g.sseguro = psseguro
               AND s.sseguro = g.sseguro
               AND g.nriesgo = pnriesgo
               AND g.nmovimi = pnmovimi                          /*JRH IMP 1*/
               AND f_pargaranpro_v (s.cramo,
                                    s.cmodali,
                                    s.ctipseg,
                                    s.ccolect,
                                    s.cactivi,
                                    g.cgarant,
                                    'TIPO'
                                   ) = 4;              -- PRIMA EXTRAORDINARIA
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               v_capital := 0;
                             /*JRH 08/2008 Aquí lo hacemos así*/
         /*SELECT nvl(icapital,0)
           INTO v_capital
           FROM GARANSEG G, SEGUROS s
           WHERE g.sseguro = psseguro
            AND s.sseguro = g.sseguro
             AND g.nriesgo = pnriesgo
             AND g.nmovimi = pnmovimi
             AND f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.cactivi,
                                 g.cgarant, 'TIPO') = 3; -- PRIMA AHORRO*/
         END;
      END IF;

      RETURN v_capital;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 0;
   END f_aportextr;

   FUNCTION f_primasriesgo (
      ptablas     IN   VARCHAR2,
      psseguro    IN   NUMBER,
      pnriesgo    IN   NUMBER,
      pfefecto    IN   DATE,                                  -- No s'utilitza
      pnmovimi    IN   NUMBER,
      cgarant     IN   NUMBER,
      psproces    IN   NUMBER,
      pnmovima    IN   NUMBER,                                -- No s'utilitza
      picapital   IN   NUMBER                                 -- No s'utilitza
   )
      RETURN NUMBER
   IS
      /********************
         Suma de las primas de las coberturas adicionales de fallecimiento y accidentes
           para los productos de ahorro
      **********************/
      v_prima   NUMBER;
   BEGIN
      IF ptablas = 'EST'
      THEN
         SELECT NVL (SUM (f_prima_forpag (ptablas,
                                          1,
                                          3,
                                          psseguro,
                                          pnriesgo,
                                          cgarant,
                                          NVL (t.ipritar, 0),
                                          pnmovimi
                                         )
                         ),
                     0
                    )
           INTO v_prima
           FROM tmp_garancar t, estseguros e
          WHERE t.sseguro = psseguro
            AND e.sseguro = t.sseguro
            AND sproces = psproces
            AND t.nriesgo = pnriesgo
            AND t.nmovi_ant = pnmovimi
            AND f_pargaranpro_v (e.cramo,
                                 e.cmodali,
                                 e.ctipseg,
                                 e.ccolect,
                                 e.cactivi,
                                 t.cgarant,
                                 'TIPO'
                                ) IN (6, 7);     -- fallecimiento y accidentes
      ELSIF ptablas = 'SOL'
      THEN
         SELECT NVL (SUM (f_prima_forpag (ptablas,
                                          1,
                                          3,
                                          psseguro,
                                          pnriesgo,
                                          cgarant,
                                          NVL (t.ipritar, 0),
                                          pnmovimi
                                         )
                         ),
                     0
                    )
           INTO v_prima
           FROM tmp_garancar t, solseguros e
          WHERE t.sseguro = psseguro
            AND e.ssolicit = t.sseguro
            AND sproces = psproces
            AND t.nriesgo = pnriesgo
            AND t.nmovi_ant = pnmovimi
            AND f_pargaranpro_v (e.cramo,
                                 e.cmodali,
                                 e.ctipseg,
                                 e.ccolect,
                                 e.cactivi,
                                 t.cgarant,
                                 'TIPO'
                                ) IN (6, 7);     -- fallecimiento y accidentes
      ELSE
         SELECT NVL (SUM (f_prima_forpag (ptablas,
                                          1,
                                          3,
                                          psseguro,
                                          pnriesgo,
                                          cgarant,
                                          NVL (t.ipritar, 0),
                                          pnmovimi
                                         )
                         ),
                     0
                    )
           INTO v_prima
           FROM tmp_garancar t, seguros e
          WHERE t.sseguro = psseguro
            AND e.sseguro = t.sseguro
            AND sproces = psproces
            AND t.nriesgo = pnriesgo
            AND t.nmovi_ant = pnmovimi
            AND f_pargaranpro_v (e.cramo,
                                 e.cmodali,
                                 e.ctipseg,
                                 e.ccolect,
                                 e.cactivi,
                                 t.cgarant,
                                 'TIPO'
                                ) IN (6, 7);     -- fallecimiento y accidentes
      END IF;

      RETURN v_prima;
   EXCEPTION
      WHEN OTHERS
      THEN
         /*DBMS_OUTPUT.put_line('error primas riesgo ' || SQLERRM);*/
         RETURN 0;
   END f_primasriesgo;

   FUNCTION f_fefecto_migracion (
      ptablas     IN   VARCHAR2,
      psseguro    IN   NUMBER,
      pnriesgo    IN   NUMBER,
      pfefecto    IN   DATE,
      pnmovimi    IN   NUMBER,
      cgarant     IN   NUMBER,
      psproces    IN   NUMBER,
      pnmovima    IN   NUMBER,
      picapital   IN   NUMBER
   )
      RETURN NUMBER
   IS
      num_err        NUMBER;
      v_mortalitat   NUMBER;
      vresp4044      pregunseg.trespue%TYPE;
      vresp4044_n    NUMBER;
      v_comisi       NUMBER;
   BEGIN
      IF ptablas = 'EST'
      THEN
         /* 1.- Obtenemos la decada en la que estamos*/
         BEGIN
            SELECT e.trespue
              INTO vresp4044
              FROM estpregunpolseg e
             WHERE e.sseguro = psseguro
               AND e.nmovimi = pnmovimi
               AND e.cpregun = 4044;

            IF vresp4044 IS NULL
            THEN
               SELECT TO_CHAR (s.fefecto, 'DD/MM/YYYY')
                 INTO vresp4044
                 FROM estseguros s
                WHERE s.sseguro = psseguro;
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               SELECT TO_CHAR (s.fefecto, 'DD/MM/YYYY')
                 INTO vresp4044
                 FROM estseguros s
                WHERE s.sseguro = psseguro;
         END;
      ELSE
         BEGIN
            SELECT e.trespue
              INTO vresp4044
              FROM pregunpolseg e
             WHERE e.sseguro = psseguro
               AND e.nmovimi = pnmovimi
               AND e.cpregun = 4044;

            IF vresp4044 IS NULL
            THEN
               SELECT TO_CHAR (s.fefecto, 'DD/MM/YYYY')
                 INTO vresp4044
                 FROM seguros s
                WHERE s.sseguro = psseguro;
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               SELECT TO_CHAR (s.fefecto, 'DD/MM/YYYY')
                 INTO vresp4044
                 FROM seguros s
                WHERE s.sseguro = psseguro;
         END;
      END IF;

      vresp4044_n :=
           TO_NUMBER (TO_CHAR (TO_DATE (vresp4044, 'DD/MM/YYYY'), 'YYYYMMDD'));
      RETURN vresp4044_n;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_propio_albsgt_conf.f_fefecto_migracion',
                      99,
                         ' - ptablas  '
                      || ptablas
                      || ' - psseguro '
                      || psseguro
                      || ' - pnriesgo '
                      || pnriesgo
                      || ' - pfefecto '
                      || pfefecto
                      || ' - pnmovimi '
                      || pnmovimi
                      || ' - cgarant '
                      || cgarant
                      || ' - psproces '
                      || psproces
                      || ' - pnmovima '
                      || pnmovima
                      || ' - picapital '
                      || picapital,
                      SQLERRM
                     );
         RETURN NULL;
   END f_fefecto_migracion;

   FUNCTION f_imc (
      ptablas     IN   VARCHAR2,
      psseguro    IN   NUMBER,
      pnriesgo    IN   NUMBER,
      pfefecto    IN   DATE,
      pnmovimi    IN   NUMBER,
      cgarant     IN   NUMBER,
      psproces    IN   NUMBER,
      pnmovima    IN   NUMBER,
      picapital   IN   NUMBER
   )
      RETURN NUMBER
   IS
      /* Calculamos el Índice de masa corporal --*/
      vimc     NUMBER;
      vresp7   NUMBER;
      vresp8   NUMBER;
   BEGIN
      IF ptablas = 'EST'
      THEN
         /* Buscamos la preguna de ALTURA (en centímetros)*/
         BEGIN
            SELECT e.crespue
              INTO vresp7
              FROM estpregunseg e
             WHERE e.sseguro = psseguro
               AND e.nmovimi = pnmovimi
               AND e.cpregun = 7
               AND e.nriesgo = pnriesgo;
         EXCEPTION
            WHEN OTHERS
            THEN
               vresp7 := 0;
         END;

         /* Buscamos la pregunta del peso (en kilos)*/
         BEGIN
            SELECT e.crespue
              INTO vresp8
              FROM estpregunseg e
             WHERE e.sseguro = psseguro
               AND e.nmovimi = pnmovimi
               AND e.cpregun = 8
               AND e.nriesgo = pnriesgo;
         EXCEPTION
            WHEN OTHERS
            THEN
               vresp8 := 0;
         END;
      ELSE
         /* Bug 9907 - 27/04/2009 - JRH - Inclusión de preguntas de comisión y gastos en Productos de baja*/
         BEGIN
            SELECT e.crespue
              INTO vresp7
              FROM pregunseg e
             WHERE e.sseguro = psseguro
               AND e.nmovimi = pnmovimi
               AND e.cpregun = 7
               AND e.nriesgo = pnriesgo;
         EXCEPTION
            WHEN OTHERS
            THEN
               vresp7 := 0;
         END;

         /* Buscamos la pregunta del peso (en kilos)*/
         BEGIN
            SELECT e.crespue
              INTO vresp8
              FROM pregunseg e
             WHERE e.sseguro = psseguro
               AND e.nmovimi = pnmovimi
               AND e.cpregun = 8
               AND e.nriesgo = pnriesgo;
         EXCEPTION
            WHEN OTHERS
            THEN
               vresp8 := 0;
         END;
      END IF;

      vimc := ROUND (vresp8 / POWER ((vresp7 / 100), 2), 2);
      RETURN vimc;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 0;
   END f_imc;

   FUNCTION f_decada_nivelada (
      ptablas     IN   VARCHAR2,
      psseguro    IN   NUMBER,
      pnriesgo    IN   NUMBER,
      pfefecto    IN   DATE,
      pnmovimi    IN   NUMBER,
      cgarant     IN   NUMBER,
      psproces    IN   NUMBER,
      pnmovima    IN   NUMBER,
      picapital   IN   NUMBER
   )
      RETURN NUMBER
   IS
      num_err       NUMBER;
      v_fefecto     estseguros.fefecto%TYPE;
      v_crespue     estpregunpolseg.crespue%TYPE;
      vresp4044     estpregunpolseg.trespue%TYPE;
      vesnivelada   NUMBER;                                       /*JRH IMP*/
      vsproduc      NUMBER;
   BEGIN
      IF ptablas = 'EST'
      THEN
         /* 1.- Obtenemos la decada en la que estamos*/
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

      vresp4044 :=
         f_fefecto_migracion (ptablas,
                              psseguro,
                              pnriesgo,
                              pfefecto,
                              pnmovimi,
                              cgarant,
                              psproces,
                              pnmovima,
                              picapital
                             );
      v_fefecto := TO_DATE (vresp4044, 'YYYYMMDD');
      /*      IF vsproduc IN(6006, 6005) THEN   --JRH Pendiente de Análisis*/
      /*         vesnivelada := 10;*/
      /*      ELSIF vsproduc IN(6013, 6012) THEN*/
      /*         vesnivelada := 8;*/
      /*      ELSE*/
      /*         vesnivelada := 1;*/
      /*      END IF;*/
      vesnivelada := NVL (f_parproductos_v (vsproduc, 'PER_REV_NO_ANUAL'), 1);

      SELECT   TRUNC (  TRUNC (MONTHS_BETWEEN (pfefecto, v_fefecto) / 12)
                      / vesnivelada
                     )
             + 1
        INTO v_crespue
        FROM DUAL;

      RETURN v_crespue;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_propio_albsgt_conf.f_decada_nivelada',
                      99,
                         ' - ptablas  '
                      || ptablas
                      || ' - psseguro '
                      || psseguro
                      || ' - pnriesgo '
                      || pnriesgo
                      || ' - pfefecto '
                      || pfefecto
                      || ' - pnmovimi '
                      || pnmovimi
                      || ' - cgarant '
                      || cgarant
                      || ' - psproces '
                      || psproces
                      || ' - pnmovima '
                      || pnmovima
                      || ' - picapital '
                      || picapital,
                      SQLERRM
                     );
         RETURN NULL;
   END f_decada_nivelada;

   FUNCTION f_edad_decada_nivelada (
      ptablas     IN   VARCHAR2,
      psseguro    IN   NUMBER,
      pnriesgo    IN   NUMBER,
      pfefecto    IN   DATE,
      pnmovimi    IN   NUMBER,
      cgarant     IN   NUMBER,
      psproces    IN   NUMBER,
      pnmovima    IN   NUMBER,
      picapital   IN   NUMBER
   )
      RETURN NUMBER
   IS
      num_err       NUMBER;
      p_sproduc     seguros.sproduc%TYPE;
      v_fcarpro     seguros.fcarpro%TYPE;
      vresp4027     pregunseg.crespue%TYPE;
      vresp4044     pregunpolseg.trespue%TYPE;
      v_fnacimi     DATE;
      v_ssegpol     NUMBER;
      v_fefecto     DATE;
      v_edad        NUMBER;
      vesnivelada   NUMBER;                                       /*JRH IMP*/
      vsproduc      NUMBER;
      v_sexo        NUMBER;
   BEGIN
      IF ptablas = 'EST'
      THEN
         SELECT sproduc
           INTO vsproduc
           FROM estseguros s
          WHERE s.sseguro = psseguro;

         BEGIN
            SELECT fnacimi, ssegpol, s.fefecto, p.csexper
              INTO v_fnacimi, v_ssegpol, v_fefecto, v_sexo
              FROM estriesgos r, estper_personas p, estseguros s
             WHERE r.sseguro = psseguro
               AND s.sseguro = r.sseguro
               AND r.sperson = p.sperson
               AND r.nriesgo = pnriesgo;
         EXCEPTION
            WHEN OTHERS
            THEN
               RETURN NULL;
         END;

         vresp4044 :=
            f_fefecto_migracion (ptablas,
                                 psseguro,
                                 pnriesgo,
                                 pfefecto,
                                 pnmovimi,
                                 cgarant,
                                 psproces,
                                 pnmovima,
                                 picapital
                                );
         v_fefecto := TO_DATE (vresp4044, 'YYYYMMDD');
         vesnivelada :=
                      NVL (f_parproductos_v (vsproduc, 'PER_REV_NO_ANUAL'), 1);

         SELECT   TRUNC (  TRUNC (MONTHS_BETWEEN (pfefecto, v_fefecto) / 12)
                         / vesnivelada
                        )
                + 1
           INTO vresp4027
           FROM DUAL;

         /* edad al inicio de la decada*/
         num_err :=
            f_difdata (v_fnacimi,
                       ADD_MONTHS (v_fefecto,
                                   (vresp4027 - 1) * 12 * vesnivelada
                                  ),
                       1,
                       1,
                       v_edad
                      );
      /* Inicia póliza a los 18 años, la tarifa de expedición es 20 años*/
      ELSE
         SELECT sproduc
           INTO vsproduc
           FROM seguros s
          WHERE s.sseguro = psseguro;

         BEGIN
            SELECT p.fnacimi, s.fefecto, p.csexper
              INTO v_fnacimi, v_fefecto, v_sexo
              FROM riesgos r, per_personas p, seguros s
             WHERE r.sseguro = psseguro
               AND s.sseguro = r.sseguro
               AND r.sperson = p.sperson
               AND r.nriesgo = pnriesgo;
         EXCEPTION
            WHEN OTHERS
            THEN
               RETURN NULL;
         END;

         vresp4044 :=
            f_fefecto_migracion (ptablas,
                                 psseguro,
                                 pnriesgo,
                                 pfefecto,
                                 pnmovimi,
                                 cgarant,
                                 psproces,
                                 pnmovima,
                                 picapital
                                );
         v_fefecto := TO_DATE (vresp4044, 'YYYYMMDD');
         vesnivelada :=
                      NVL (f_parproductos_v (vsproduc, 'PER_REV_NO_ANUAL'), 1);

         /*         IF vsproduc IN(6006, 6005) THEN   --JRH Pendiente de Análisis*/
         /*            vesnivelada := 10;*/
         /*         ELSIF vsproduc IN(6013, 6012) THEN*/
         /*            vesnivelada := 8;*/
         /*         ELSE*/
         /*            vesnivelada := 1;*/
           /*         END IF;*/
         SELECT   TRUNC (  TRUNC (MONTHS_BETWEEN (pfefecto, v_fefecto) / 12)
                         / vesnivelada
                        )
                + 1
           INTO vresp4027
           FROM DUAL;

         /* edad al inicio de la decada*/
         num_err :=
            f_difdata (v_fnacimi,
                       ADD_MONTHS (v_fefecto,
                                   (vresp4027 - 1) * 12 * vesnivelada
                                  ),
                       1,
                       1,
                       v_edad
                      );
      /* Termina la primera década, tiene 28 años, renueva con tarifa de 30 años*/
      /* Termina segunda década, tiene 38 años, renueva con tarifa de 38 años.*/
      END IF;

      /*IF v_sexo = 2
         AND vsproduc IN(6012, 6013)
         AND cgarant = 6901 THEN
         v_edad := v_edad - 4;
      END IF;*/
      IF v_edad < 20
      THEN
         v_edad := 20;
      END IF;

      RETURN v_edad;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_propio_albsgt_conf.f_edad_decada_nivelada',
                      99,
                         ' - ptablas  '
                      || ptablas
                      || ' - psseguro '
                      || psseguro
                      || ' - pnriesgo '
                      || pnriesgo
                      || ' - pfefecto '
                      || pfefecto
                      || ' - pnmovimi '
                      || pnmovimi
                      || ' - cgarant '
                      || cgarant
                      || ' - psproces '
                      || psproces
                      || ' - pnmovima '
                      || pnmovima
                      || ' - picapital '
                      || picapital,
                      SQLERRM
                     );
         RETURN NULL;
   END f_edad_decada_nivelada;

   /* BUG18351:DRA:12/09/2011:Inici*/
   FUNCTION f_doc_requerida (
      ptablas    IN   VARCHAR2,
      pcactivi   IN   NUMBER,
      psseguro   IN   NUMBER,
      pnmovimi   IN   NUMBER
   )
      RETURN NUMBER
   IS
      /**/
      vretorno   NUMBER;
      vnmovimi   NUMBER;
   BEGIN
      IF NVL (pnmovimi, 0) = 0
      THEN
         IF ptablas = 'EST'
         THEN
            SELECT MAX (nmovimi)
              INTO vnmovimi
              FROM estgaranseg
             WHERE sseguro = psseguro;
         ELSE
            SELECT MAX (nmovimi)
              INTO vnmovimi
              FROM garanseg
             WHERE sseguro = psseguro;
         END IF;
      ELSE
         vnmovimi := pnmovimi;
      END IF;

      IF vnmovimi = 1
      THEN
         vretorno := 1;
      ELSE
         vretorno := 0;
      END IF;

      RETURN vretorno;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 0;
   END f_doc_requerida;

   /* BUG18351:DRA:12/09/2011:Fi*/
   FUNCTION f_extraprima_ocupacion (
      ptablas     IN   VARCHAR2,
      psseguro    IN   NUMBER,
      pnriesgo    IN   NUMBER,
      pfefecto    IN   DATE,
      pnmovimi    IN   NUMBER,
      cgarant     IN   NUMBER,
      psproces    IN   NUMBER,
      pnmovima    IN   NUMBER,
      picapital   IN   NUMBER
   )
      RETURN NUMBER
   IS
      num_err         NUMBER;
      vresp4004       pregunseg.crespue%TYPE;
      vresp60         pregunseg.crespue%TYPE;
      v_extraprima1   NUMBER;
      v_extraprima2   NUMBER;
      v_cramo         seguros.cramo%TYPE;
      v_cmodali       seguros.cmodali%TYPE;
      v_ctipseg       seguros.ctipseg%TYPE;
      v_ccolect       seguros.ccolect%TYPE;
      v_cactivi       seguros.cactivi%TYPE;
   BEGIN
      IF ptablas = 'EST'
      THEN
         SELECT cramo, cmodali, ctipseg, ccolect, cactivi
           INTO v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_cactivi
           FROM estseguros
          WHERE sseguro = psseguro;

         BEGIN
            SELECT e.crespue
              INTO vresp4004
              FROM estpregunseg e
             WHERE e.sseguro = psseguro
               AND e.nmovimi = pnmovimi
               AND e.cpregun = 4004
               AND e.nriesgo = pnriesgo;
         EXCEPTION
            WHEN OTHERS
            THEN
               vresp4004 := 0;
         END;

         BEGIN
            SELECT e.crespue
              INTO vresp60
              FROM estpregunseg e
             WHERE e.sseguro = psseguro
               AND e.nmovimi = pnmovimi
               AND e.cpregun = 60
               AND e.nriesgo = pnriesgo;
         EXCEPTION
            WHEN OTHERS
            THEN
               vresp60 := 0;
         END;
      ELSE
         SELECT cramo, cmodali, ctipseg, ccolect, cactivi
           INTO v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_cactivi
           FROM seguros
          WHERE sseguro = psseguro;

         BEGIN
            SELECT e.crespue
              INTO vresp4004
              FROM pregunseg e
             WHERE e.sseguro = psseguro
               AND e.nmovimi = pnmovimi
               AND e.cpregun = 4004
               AND e.nriesgo = pnriesgo;
         EXCEPTION
            WHEN OTHERS
            THEN
               vresp4004 := 0;
         END;

         BEGIN
            SELECT e.crespue
              INTO vresp60
              FROM pregunseg e
             WHERE e.sseguro = psseguro
               AND e.nmovimi = pnmovimi
               AND e.cpregun = 60
               AND e.nriesgo = pnriesgo;
         EXCEPTION
            WHEN OTHERS
            THEN
               vresp60 := 0;
         END;
      END IF;

      SELECT iextrap
        INTO v_extraprima1
        FROM profesionprod
       WHERE cramo = v_cramo
         AND cmodali = v_cmodali
         AND ctipseg = v_ctipseg
         AND ccolect = v_ccolect
         AND cactivi = v_cactivi
         AND cprofes = vresp4004;

      SELECT iextrap
        INTO v_extraprima2
        FROM profesionprod
       WHERE cramo = v_cramo
         AND cmodali = v_cmodali
         AND ctipseg = v_ctipseg
         AND ccolect = v_ccolect
         AND cactivi = v_cactivi
         AND cprofes = vresp60;

      RETURN NVL (GREATEST (v_extraprima1, v_extraprima2), 0);
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_propio_albsgt_conf.f_extraprima_ocupacion',
                      99,
                         ' - ptablas  '
                      || ptablas
                      || ' - psseguro '
                      || psseguro
                      || ' - pnriesgo '
                      || pnriesgo
                      || ' - pfefecto '
                      || pfefecto
                      || ' - pnmovimi '
                      || pnmovimi
                      || ' - cgarant '
                      || cgarant
                      || ' - psproces '
                      || psproces
                      || ' - pnmovima '
                      || pnmovima
                      || ' - picapital '
                      || picapital,
                      SQLERRM
                     );
         RETURN NULL;
   END f_extraprima_ocupacion;

   FUNCTION f_extraprima_zona (
      ptablas     IN   VARCHAR2,
      psseguro    IN   NUMBER,
      pnriesgo    IN   NUMBER,
      pfefecto    IN   DATE,
      pnmovimi    IN   NUMBER,
      cgarant     IN   NUMBER,
      psproces    IN   NUMBER,
      pnmovima    IN   NUMBER,
      picapital   IN   NUMBER
   )
      RETURN NUMBER
   IS
      num_err        NUMBER;
      vresp4007      pregunseg.crespue%TYPE;
      vresp4009      pregunseg.crespue%TYPE;
      v_extraprima   NUMBER;
   BEGIN
      IF ptablas = 'EST'
      THEN
         BEGIN
            SELECT e.crespue
              INTO vresp4007
              FROM estpregunseg e
             WHERE e.sseguro = psseguro
               AND e.nmovimi = pnmovimi
               AND e.cpregun = 4007
               AND e.nriesgo = pnriesgo;
         EXCEPTION
            WHEN OTHERS
            THEN
               vresp4007 := 0;
         END;

         BEGIN
            SELECT e.crespue
              INTO vresp4009
              FROM estpregunseg e
             WHERE e.sseguro = psseguro
               AND e.nmovimi = pnmovimi
               AND e.cpregun = 4009
               AND e.nriesgo = pnriesgo;
         EXCEPTION
            WHEN OTHERS
            THEN
               vresp4009 := 0;
         END;
      ELSE
         BEGIN
            SELECT e.crespue
              INTO vresp4007
              FROM pregunseg e
             WHERE e.sseguro = psseguro
               AND e.nmovimi = pnmovimi
               AND e.cpregun = 4007
               AND e.nriesgo = pnriesgo;
         EXCEPTION
            WHEN OTHERS
            THEN
               vresp4007 := 0;
         END;

         BEGIN
            SELECT e.crespue
              INTO vresp4009
              FROM pregunseg e
             WHERE e.sseguro = psseguro
               AND e.nmovimi = pnmovimi
               AND e.cpregun = 4009
               AND e.nriesgo = pnriesgo;
         EXCEPTION
            WHEN OTHERS
            THEN
               vresp4009 := 0;
         END;
      END IF;

      SELECT GREATEST (pac_subtablas.f_vsubtabla (NULL, 914, 3, 2, vresp4007),
                       pac_subtablas.f_vsubtabla (NULL, 914, 3, 2, vresp4009)
                      )
        INTO v_extraprima
        FROM DUAL;

      RETURN NVL (v_extraprima, 0);
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_propio_albsgt_conf.f_extraprima_zona',
                      99,
                         ' - ptablas  '
                      || ptablas
                      || ' - psseguro '
                      || psseguro
                      || ' - pnriesgo '
                      || pnriesgo
                      || ' - pfefecto '
                      || pfefecto
                      || ' - pnmovimi '
                      || pnmovimi
                      || ' - cgarant '
                      || cgarant
                      || ' - psproces '
                      || psproces
                      || ' - pnmovima '
                      || pnmovima
                      || ' - picapital '
                      || picapital,
                      SQLERRM
                     );
         RETURN NULL;
   END f_extraprima_zona;

   FUNCTION f_extraprima_deporte (
      ptablas     IN   VARCHAR2,
      psseguro    IN   NUMBER,
      pnriesgo    IN   NUMBER,
      pfefecto    IN   DATE,
      pnmovimi    IN   NUMBER,
      cgarant     IN   NUMBER,
      psproces    IN   NUMBER,
      pnmovima    IN   NUMBER,
      picapital   IN   NUMBER
   )
      RETURN NUMBER
   IS
      num_err        NUMBER;
      vresp4005      pregunseg.crespue%TYPE;
      v_extraprima   NUMBER;
   BEGIN
      IF ptablas = 'EST'
      THEN
         BEGIN
            SELECT e.crespue
              INTO vresp4005
              FROM estpregunseg e
             WHERE e.sseguro = psseguro
               AND e.nmovimi = pnmovimi
               AND e.cpregun = 4005
               AND e.nriesgo = pnriesgo;
         EXCEPTION
            WHEN OTHERS
            THEN
               vresp4005 := 0;
         END;
      ELSE
         BEGIN
            SELECT e.crespue
              INTO vresp4005
              FROM pregunseg e
             WHERE e.sseguro = psseguro
               AND e.nmovimi = pnmovimi
               AND e.cpregun = 4005
               AND e.nriesgo = pnriesgo;
         EXCEPTION
            WHEN OTHERS
            THEN
               vresp4005 := 0;
         END;
      END IF;

      SELECT pac_subtablas.f_vsubtabla (NULL, 913, 3, 2, vresp4005)
        INTO v_extraprima
        FROM DUAL;

      RETURN NVL (v_extraprima, 0);
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_propio_albsgt_conf.f_extraprima_deporte',
                      99,
                         ' - ptablas  '
                      || ptablas
                      || ' - psseguro '
                      || psseguro
                      || ' - pnriesgo '
                      || pnriesgo
                      || ' - pfefecto '
                      || pfefecto
                      || ' - pnmovimi '
                      || pnmovimi
                      || ' - cgarant '
                      || cgarant
                      || ' - psproces '
                      || psproces
                      || ' - pnmovima '
                      || pnmovima
                      || ' - picapital '
                      || picapital,
                      SQLERRM
                     );
         RETURN NULL;
   END f_extraprima_deporte;

   FUNCTION f_extraprima_salud (
      ptablas     IN   VARCHAR2,
      psseguro    IN   NUMBER,
      pnriesgo    IN   NUMBER,
      pfefecto    IN   DATE,
      pnmovimi    IN   NUMBER,
      cgarant     IN   NUMBER,
      psproces    IN   NUMBER,
      pnmovima    IN   NUMBER,
      picapital   IN   NUMBER
   )
      RETURN NUMBER
   IS
      v_fnacimi      DATE;
      v_ssegpol      NUMBER;
      v_fefecto      DATE;
      v_fecha        DATE;
      v_edad         NUMBER;
      v_fcaranu      DATE;
      v_fcarpro      DATE;
      num_err        NUMBER;
      vresp4032      pregunseg.crespue%TYPE;
      v_extraprima   NUMBER;
   BEGIN
      IF ptablas = 'EST'
      THEN
         BEGIN
            SELECT e.crespue
              INTO vresp4032
              FROM estpregunseg e
             WHERE e.sseguro = psseguro
               AND e.nmovimi = pnmovimi
               AND e.cpregun = 4032
               AND e.nriesgo = pnriesgo;
         EXCEPTION
            WHEN OTHERS
            THEN
               vresp4032 := 0;
         END;
      ELSE
         BEGIN
            SELECT e.crespue
              INTO vresp4032
              FROM pregunseg e
             WHERE e.sseguro = psseguro
               AND e.nmovimi = pnmovimi
               AND e.cpregun = 4032
               AND e.nriesgo = pnriesgo;
         EXCEPTION
            WHEN OTHERS
            THEN
               vresp4032 := 0;
         END;
      END IF;

      /* Bug 19612 - RSC - 21/12/2011 - LCOL_T004: Formulación productos Vida Individual*/
      SELECT pac_subtablas.f_vsubtabla (NULL, 915, 3, 1, vresp4032)
        INTO v_extraprima
        FROM DUAL;

      RETURN NVL (v_extraprima, 0);
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_propio_albsgt_conf.f_extraprima_salud',
                      99,
                         ' - ptablas  '
                      || ptablas
                      || ' - psseguro '
                      || psseguro
                      || ' - pnriesgo '
                      || pnriesgo
                      || ' - pfefecto '
                      || pfefecto
                      || ' - pnmovimi '
                      || pnmovimi
                      || ' - cgarant '
                      || cgarant
                      || ' - psproces '
                      || psproces
                      || ' - pnmovima '
                      || pnmovima
                      || ' - picapital '
                      || picapital,
                      SQLERRM
                     );
         RETURN NULL;
   END f_extraprima_salud;

   /* c1 es la comisión al inicio de la década*/
   FUNCTION f_comision_c1 (
      ptablas     IN   VARCHAR2,
      psseguro    IN   NUMBER,
      pnriesgo    IN   NUMBER,
      pfefecto    IN   DATE,
      pnmovimi    IN   NUMBER,
      cgarant     IN   NUMBER,
      psproces    IN   NUMBER,
      pnmovima    IN   NUMBER,
      picapital   IN   NUMBER
   )
      RETURN NUMBER
   IS
      v_fnacimi       DATE;
      v_ssegpol       NUMBER;
      v_fefecto       DATE;
      v_fecha         DATE;
      v_edad          NUMBER;
      v_fcaranu       DATE;
      v_fcarpro       DATE;
      num_err         NUMBER;
      vresp4027       pregunseg.crespue%TYPE;
      vresp4044       pregunpolseg.trespue%TYPE;
      v_comisi        NUMBER;
      vcmodcon        NUMBER;
      ppretenc        NUMBER;
      vsproduc        NUMBER;
      vesnivelada     NUMBER;
      verror          NUMBER;
      /*  Bug 19612 - RSC - 09/12/2011 - LCOL_T004: Formulación productos Vida Individual*/
      v_no_nivelada   NUMBER;
      v_nanuali       NUMBER;
   /*  Fin Bug 19612*/
   BEGIN
      IF ptablas = 'EST'
      THEN
         /* 1.- Obtenemos la decada en la que estamos*/
         SELECT sproduc, nanuali
           INTO vsproduc, v_nanuali
           FROM estseguros s
          WHERE s.sseguro = psseguro;

         vresp4044 :=
            f_fefecto_migracion (ptablas,
                                 psseguro,
                                 pnriesgo,
                                 pfefecto,
                                 pnmovimi,
                                 cgarant,
                                 psproces,
                                 pnmovima,
                                 picapital
                                );
         v_fefecto := TO_DATE (vresp4044, 'YYYYMMDD');
         vesnivelada :=
                      NVL (f_parproductos_v (vsproduc, 'PER_REV_NO_ANUAL'), 1);

         SELECT   TRUNC (  TRUNC (MONTHS_BETWEEN (pfefecto, v_fefecto) / 12)
                         / vesnivelada
                        )
                + 1
           INTO vresp4027
           FROM DUAL;

         v_no_nivelada :=
            pac_propio_albsgt_conf.f_prima_nivelada_gar (ptablas,
                                                         psseguro,
                                                         pnriesgo,
                                                         pfefecto,
                                                         pnmovimi,
                                                         cgarant,
                                                         psproces,
                                                         pnmovima,
                                                         picapital
                                                        );

         IF v_no_nivelada = 0
         THEN
            SELECT TRUNC (MONTHS_BETWEEN (pfefecto, v_fefecto) / 12) + 1
              INTO v_nanuali
              FROM DUAL;

            IF v_nanuali <=
                      NVL (f_parproductos_v (vsproduc, 'PER_REV_NO_ANUAL'), 1)
            THEN
               vcmodcon := 1;
            ELSE
               vcmodcon := 2;
            END IF;

            verror :=
               f_pcomisi (psseguro,
                          vcmodcon,
                          f_sysdate,
                          v_comisi,
                          ppretenc,
                          NULL,
                          NULL,
                          NULL,
                          NULL,
                          NULL,
                          NULL,
                          cgarant,
                          ptablas,
                          'TAR',
                          v_fefecto,
                          v_nanuali
                         );
         ELSE
            IF vresp4027 = 1
            THEN
               vcmodcon := 1;
            ELSE
               vcmodcon := 2;
            END IF;

            verror :=
               f_pcomisi (psseguro,
                          vcmodcon,
                          f_sysdate,
                          v_comisi,
                          ppretenc,
                          NULL,
                          NULL,
                          NULL,
                          NULL,
                          NULL,
                          NULL,
                          cgarant,
                          ptablas,
                          'TAR',
                          v_fefecto,
                          
                          /* Bug 19612 - JRH - 07/11/2011 - 0019612: LCOL_T004: Formulación productos Vida Individual. Anualidad por parámetro.*/
                          (vresp4027 - 1) * vesnivelada + 1
                         /* Fi Bug 19612 - JRH - 07/11/2011*/
                         );
         END IF;

         IF verror <> 0
         THEN
            RAISE NO_DATA_FOUND;
         END IF;
      ELSE
         SELECT sproduc, nanuali
           INTO vsproduc, v_nanuali
           FROM seguros s
          WHERE s.sseguro = psseguro;

         vresp4044 :=
            f_fefecto_migracion (ptablas,
                                 psseguro,
                                 pnriesgo,
                                 pfefecto,
                                 pnmovimi,
                                 cgarant,
                                 psproces,
                                 pnmovima,
                                 picapital
                                );
         v_fefecto := TO_DATE (vresp4044, 'YYYYMMDD');
         vesnivelada :=
                      NVL (f_parproductos_v (vsproduc, 'PER_REV_NO_ANUAL'), 1);

         SELECT   TRUNC (  TRUNC (MONTHS_BETWEEN (pfefecto, v_fefecto) / 12)
                         / vesnivelada
                        )
                + 1
           INTO vresp4027
           FROM DUAL;

         /* Bug 20671 - JRH - 20/01/2012 - 20671 : Ponemoss todo esto también en las SEG*/
         v_no_nivelada :=
            pac_propio_albsgt_conf.f_prima_nivelada_gar (ptablas,
                                                         psseguro,
                                                         pnriesgo,
                                                         pfefecto,
                                                         pnmovimi,
                                                         cgarant,
                                                         psproces,
                                                         pnmovima,
                                                         picapital
                                                        );

         IF v_no_nivelada = 0
         THEN
            SELECT TRUNC (MONTHS_BETWEEN (pfefecto, v_fefecto) / 12) + 1
              INTO v_nanuali
              FROM DUAL;

            IF v_nanuali <=
                      NVL (f_parproductos_v (vsproduc, 'PER_REV_NO_ANUAL'), 1)
            THEN
               vcmodcon := 1;
            ELSE
               vcmodcon := 2;
            END IF;

            verror :=
               f_pcomisi (psseguro,
                          vcmodcon,
                          f_sysdate,
                          v_comisi,
                          ppretenc,
                          NULL,
                          NULL,
                          NULL,
                          NULL,
                          NULL,
                          NULL,
                          cgarant,
                          ptablas,
                          'CAR',
                          v_fefecto,
                          v_nanuali
                         );
         ELSE
            IF vresp4027 = 1
            THEN
               vcmodcon := 1;
            ELSE
               vcmodcon := 2;
            END IF;

            verror :=
               f_pcomisi (psseguro,
                          vcmodcon,
                          f_sysdate,
                          v_comisi,
                          ppretenc,
                          NULL,
                          NULL,
                          NULL,
                          NULL,
                          NULL,
                          NULL,
                          cgarant,
                          ptablas,
                          'CAR',
                          v_fefecto,
                          
                          /* Bug 19612 - JRH - 07/11/2011 - 0019612: LCOL_T004: Formulación productos Vida Individual. Anualidad por parámetro.*/
                          (vresp4027 - 1) * vesnivelada + 1
                         /* Fi Bug 19612 - JRH - 07/11/2011*/
                         );
         END IF;

         IF verror <> 0
         THEN
            RAISE NO_DATA_FOUND;
         END IF;
      END IF;

      /* Fi Bug 20671 - JRH - 20/01/2012*/
      RETURN NVL (v_comisi, 0);
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_propio_albsgt_conf.f_comision_c1',
                      99,
                         ' - ptablas  '
                      || ptablas
                      || ' - psseguro '
                      || psseguro
                      || ' - pnriesgo '
                      || pnriesgo
                      || ' - pfefecto '
                      || pfefecto
                      || ' - pnmovimi '
                      || pnmovimi
                      || ' - cgarant '
                      || cgarant
                      || ' - psproces '
                      || psproces
                      || ' - pnmovima '
                      || pnmovima
                      || ' - picapital '
                      || picapital,
                      SQLERRM
                     );
         RETURN NULL;
   END f_comision_c1;

   /* c2 es la comisión en la anualidad siguiente al inicio de la década*/
   FUNCTION f_comision_c2_c (
      ptablas     IN   VARCHAR2,
      psseguro    IN   NUMBER,
      pnriesgo    IN   NUMBER,
      pfefecto    IN   DATE,
      pnmovimi    IN   NUMBER,
      cgarant     IN   NUMBER,
      psproces    IN   NUMBER,
      pnmovima    IN   NUMBER,
      picapital   IN   NUMBER
   )
      RETURN NUMBER
   IS
      v_fnacimi       DATE;
      v_ssegpol       NUMBER;
      v_fefecto       DATE;
      v_fecha         DATE;
      v_edad          NUMBER;
      v_fcaranu       DATE;
      v_fcarpro       DATE;
      num_err         NUMBER;
      vresp4027       pregunseg.crespue%TYPE;
      vresp4044       pregunpolseg.trespue%TYPE;
      v_comisi        NUMBER;
      vesnivelada     NUMBER;
      vsproduc        NUMBER;
      verror          NUMBER;
      vcmodcon        NUMBER;
      ppretenc        NUMBER;
      /*  Bug 19612 - RSC - 09/12/2011 - LCOL_T004: Formulación productos Vida Individual*/
      v_no_nivelada   NUMBER;
      v_nanuali       NUMBER;
   /*  Fin Bug 19612*/
   BEGIN
      IF ptablas = 'EST'
      THEN
         /* 1.- Obtenemos la decada en la que estamos*/
         SELECT sproduc
           INTO vsproduc
           FROM estseguros s
          WHERE s.sseguro = psseguro;

         vresp4044 :=
            f_fefecto_migracion (ptablas,
                                 psseguro,
                                 pnriesgo,
                                 pfefecto,
                                 pnmovimi,
                                 cgarant,
                                 psproces,
                                 pnmovima,
                                 picapital
                                );
         v_fefecto := TO_DATE (vresp4044, 'YYYYMMDD');
         vesnivelada :=
                      NVL (f_parproductos_v (vsproduc, 'PER_REV_NO_ANUAL'), 1);

         SELECT   TRUNC (  TRUNC (MONTHS_BETWEEN (pfefecto, v_fefecto) / 12)
                         / vesnivelada
                        )
                + 1
           INTO vresp4027
           FROM DUAL;

         v_no_nivelada :=
            pac_propio_albsgt_conf.f_prima_nivelada_gar (ptablas,
                                                         psseguro,
                                                         pnriesgo,
                                                         pfefecto,
                                                         pnmovimi,
                                                         cgarant,
                                                         psproces,
                                                         pnmovima,
                                                         picapital
                                                        );

         IF v_no_nivelada = 0
         THEN
            SELECT TRUNC (MONTHS_BETWEEN (pfefecto, v_fefecto) / 12) + 1
              INTO v_nanuali
              FROM DUAL;

            IF v_nanuali <=
                      NVL (f_parproductos_v (vsproduc, 'PER_REV_NO_ANUAL'), 1)
            THEN
               vcmodcon := 1;
            ELSE
               vcmodcon := 2;
            END IF;

            /*         v_comisi := ff_pcomisi(psseguro, NULL, NULL, NULL, NULL, NULL, NULL, NULL, cgarant,*/
              /*                                (vresp4027 - 1) * vesnivelada + 2, NULL, 1);*/
            verror :=
               f_pcomisi (psseguro,
                          vcmodcon,
                          f_sysdate,
                          v_comisi,
                          ppretenc,
                          NULL,
                          NULL,
                          NULL,
                          NULL,
                          NULL,
                          NULL,
                          cgarant,
                          ptablas,
                          'TAR',
                          v_fefecto,
                          /* Bug 19612 - JRH - 07/11/2011 - 0019612: LCOL_T004: Formulación productos Vida Individual. Anualidad por parámetro.*/
                          v_nanuali
                         /* Fi Bug 19612 - JRH - 07/11/2011*/
                         );
         ELSE
            IF vresp4027 = 1
            THEN
               vcmodcon := 1;
            ELSE
               vcmodcon := 2;
            END IF;

            verror :=
               f_pcomisi (psseguro,
                          vcmodcon,
                          f_sysdate,
                          v_comisi,
                          ppretenc,
                          NULL,
                          NULL,
                          NULL,
                          NULL,
                          NULL,
                          NULL,
                          cgarant,
                          ptablas,
                          'TAR',
                          v_fefecto,
                          
                          /* Bug 19612 - JRH - 07/11/2011 - 0019612: LCOL_T004: Formulación productos Vida Individual. Anualidad por parámetro.*/
                          (vresp4027 - 1) * vesnivelada + 2
                         /* Fi Bug 19612 - JRH - 07/11/2011*/
                         );
         END IF;

         IF verror <> 0
         THEN
            RAISE NO_DATA_FOUND;
         END IF;
      ELSE
         SELECT sproduc
           INTO vsproduc
           FROM seguros s
          WHERE s.sseguro = psseguro;

         vresp4044 :=
            f_fefecto_migracion (ptablas,
                                 psseguro,
                                 pnriesgo,
                                 pfefecto,
                                 pnmovimi,
                                 cgarant,
                                 psproces,
                                 pnmovima,
                                 picapital
                                );
         v_fefecto := TO_DATE (vresp4044, 'YYYYMMDD');
         vesnivelada :=
                      NVL (f_parproductos_v (vsproduc, 'PER_REV_NO_ANUAL'), 1);

         SELECT   TRUNC (  TRUNC (MONTHS_BETWEEN (pfefecto, v_fefecto) / 12)
                         / vesnivelada
                        )
                + 1
           INTO vresp4027
           FROM DUAL;

         v_no_nivelada :=
            pac_propio_albsgt_conf.f_prima_nivelada_gar (ptablas,
                                                         psseguro,
                                                         pnriesgo,
                                                         pfefecto,
                                                         pnmovimi,
                                                         cgarant,
                                                         psproces,
                                                         pnmovima,
                                                         picapital
                                                        );

         IF v_no_nivelada = 0
         THEN
            SELECT TRUNC (MONTHS_BETWEEN (pfefecto, v_fefecto) / 12) + 1
              INTO v_nanuali
              FROM DUAL;

            IF v_nanuali <=
                      NVL (f_parproductos_v (vsproduc, 'PER_REV_NO_ANUAL'), 1)
            THEN
               vcmodcon := 1;
            ELSE
               vcmodcon := 2;
            END IF;

            verror :=
               f_pcomisi (psseguro,
                          vcmodcon,
                          f_sysdate,
                          v_comisi,
                          ppretenc,
                          NULL,
                          NULL,
                          NULL,
                          NULL,
                          NULL,
                          NULL,
                          cgarant,
                          ptablas,
                          'CAR',
                          v_fefecto,
                          /* Bug 19612 - JRH - 07/11/2011 - 0019612: LCOL_T004: Formulación productos Vida Individual. Anualidad por parámetro.*/
                          v_nanuali
                         /* Fi Bug 19612 - JRH - 07/11/2011*/
                         );
         ELSE
            IF vresp4027 = 1
            THEN
               vcmodcon := 1;
            ELSE
               vcmodcon := 2;
            END IF;

            /*         v_comisi := ff_pcomisi(psseguro, NULL, NULL, NULL, NULL, NULL, NULL, NULL, cgarant,*/
            /*                                (vresp4027 - 1) * vesnivelada + 2, NULL, 2);*/
              /**/
            verror :=
               f_pcomisi (psseguro,
                          vcmodcon,
                          f_sysdate,
                          v_comisi,
                          ppretenc,
                          NULL,
                          NULL,
                          NULL,
                          NULL,
                          NULL,
                          NULL,
                          cgarant,
                          ptablas,
                          'CAR',
                          v_fefecto,
                          
                          /* Bug 19612 - JRH - 07/11/2011 - 0019612: LCOL_T004: Formulación productos Vida Individual. Anualidad por parámetro.*/
                          (vresp4027 - 1) * vesnivelada + 2
                         /* Fi Bug 19612 - JRH - 07/11/2011*/
                         );
         END IF;

         IF verror <> 0
         THEN
            RAISE NO_DATA_FOUND;
         END IF;
      END IF;

      RETURN NVL (v_comisi, 0);
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_propio_albsgt_conf._f_tabla_mortalidad',
                      99,
                         ' - ptablas  '
                      || ptablas
                      || ' - psseguro '
                      || psseguro
                      || ' - pnriesgo '
                      || pnriesgo
                      || ' - pfefecto '
                      || pfefecto
                      || ' - pnmovimi '
                      || pnmovimi
                      || ' - cgarant '
                      || cgarant
                      || ' - psproces '
                      || psproces
                      || ' - pnmovima '
                      || pnmovima
                      || ' - picapital '
                      || picapital,
                      SQLERRM
                     );
         RETURN NULL;
   END f_comision_c2_c;

   FUNCTION f_tabla_mortalidad (
      ptablas     IN   VARCHAR2,
      psseguro    IN   NUMBER,
      pnriesgo    IN   NUMBER,
      pfefecto    IN   DATE,
      pnmovimi    IN   NUMBER,
      cgarant     IN   NUMBER,
      psproces    IN   NUMBER,
      pnmovima    IN   NUMBER,
      picapital   IN   NUMBER
   )
      RETURN NUMBER
   IS
      num_err        NUMBER;
      v_mortalitat   NUMBER;
      vresp4044      pregunseg.trespue%TYPE;
      vresp4044_n    NUMBER;
      v_comisi       NUMBER;
      vsproduc       NUMBER;
   BEGIN
      /* BUG 20671-  01/2012 - JRH  -  0020671: LCOL_T001-LCOL - UAT - TEC: Contrataci?n El Latin Vida siempre tabla 1*/
      IF ptablas = 'EST'
      THEN
         /* 1.- Obtenemos la decada en la que estamos*/
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

      IF NVL (f_parproductos_v (vsproduc, 'PROD_TARIF'), 0) IN (6012, 6013)
      THEN
         v_mortalitat := 1;             /*JRH El Latin Vida siempre tabla 1*/
      ELSE
         /* Fi BUG 20671-  01/2012 - JRH  -  0020671: LCOL_T001-LCOL - UAT - TEC: Contrataci?n*/
         vresp4044_n :=
            f_fefecto_migracion (ptablas,
                                 psseguro,
                                 pnriesgo,
                                 pfefecto,
                                 pnmovimi,
                                 cgarant,
                                 psproces,
                                 pnmovima,
                                 picapital
                                );

         SELECT pac_subtablas.f_vsubtabla (NULL, 936, 2, 1, vresp4044_n)
           INTO v_mortalitat
           FROM DUAL;
      END IF;

      RETURN v_mortalitat;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_propio_albsgt_conf.f_tabla_mortalidad',
                      99,
                         ' - ptablas  '
                      || ptablas
                      || ' - psseguro '
                      || psseguro
                      || ' - pnriesgo '
                      || pnriesgo
                      || ' - pfefecto '
                      || pfefecto
                      || ' - pnmovimi '
                      || pnmovimi
                      || ' - cgarant '
                      || cgarant
                      || ' - psproces '
                      || psproces
                      || ' - pnmovima '
                      || pnmovima
                      || ' - picapital '
                      || picapital,
                      SQLERRM
                     );
         RETURN NULL;
   END f_tabla_mortalidad;

   FUNCTION f_fecha_efecto (
      ptablas     IN   VARCHAR2,
      psseguro    IN   NUMBER,
      pnriesgo    IN   NUMBER,
      pfefecto    IN   DATE,
      pnmovimi    IN   NUMBER,
      cgarant     IN   NUMBER,
      psproces    IN   NUMBER,
      pnmovima    IN   NUMBER,
      picapital   IN   NUMBER
   )
      RETURN NUMBER
   IS
      num_err     NUMBER;
      v_fefecto   estseguros.fefecto%TYPE;
   BEGIN
      IF ptablas = 'EST'
      THEN
         BEGIN
            SELECT fefecto
              INTO v_fefecto
              FROM estseguros s
             WHERE s.sseguro = psseguro;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               v_fefecto := pfefecto;
         END;
      ELSE
         BEGIN
            SELECT fefecto
              INTO v_fefecto
              FROM seguros s
             WHERE s.sseguro = psseguro;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               v_fefecto := pfefecto;
         END;
      END IF;

      RETURN TO_NUMBER (TO_CHAR (NVL (v_fefecto, pfefecto), 'YYYYMMDD'));
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_propio_albsgt_conf.f_fecha_efecto',
                      99,
                         ' - ptablas  '
                      || ptablas
                      || ' - psseguro '
                      || psseguro
                      || ' - pnriesgo '
                      || pnriesgo
                      || ' - pfefecto '
                      || pfefecto
                      || ' - pnmovimi '
                      || pnmovimi
                      || ' - cgarant '
                      || cgarant
                      || ' - psproces '
                      || psproces
                      || ' - pnmovima '
                      || pnmovima
                      || ' - picapital '
                      || picapital,
                      SQLERRM
                     );
         RETURN NULL;
   END f_fecha_efecto;

   /* Bug 19612 - JRH - 07/11/2011 - 0019612: LCOL_T004: Formulación productos Vida Individual*/
   FUNCTION f_capital_inicial (
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
      num_err        NUMBER;
      v_mortalitat   NUMBER;
      vresp4070      pregunseg.crespue%TYPE;
      vresp4055      pregunseg.crespue%TYPE;
      vresp4054      estpregungaranseg.trespue%TYPE;
      vresp4044      pregunseg.trespue%TYPE;
      vresp4044_n    NUMBER;
      vcapital_ant   NUMBER;
      v_comisi       NUMBER;
      v_fefecto      DATE;
      v_sproduc      seguros.sproduc%TYPE;
      vcrevali       seguros.crevali%TYPE;
      vprevali       seguros.prevali%TYPE;
      vanualidad     NUMBER;
      vtraza         NUMBER;
      /* Bug 20995 - RSC - 16/02/2012 - LCOL - UAT - TEC - Incidencias de Contratacion*/
      v_ssegpol      estseguros.ssegpol%TYPE;
   /* Fin bug 20995*/
   BEGIN
      IF ptablas = 'EST'
      THEN
         vtraza := 1;

         /* Bug 20995 - RSC - 16/02/2012 - LCOL - UAT - TEC - Incidencias de Contratacion*/
         SELECT sproduc, crevali, prevali, ssegpol
           INTO v_sproduc, vcrevali, vprevali, v_ssegpol
           FROM estseguros
          WHERE sseguro = psseguro;

         /* Fin bug 20995*/
         vtraza := 2;
         vresp4044 :=
            f_fefecto_migracion (ptablas,
                                 psseguro,
                                 pnriesgo,
                                 pfefecto,
                                 pnmovimi,
                                 pcgarant,
                                 psproces,
                                 pnmovima,
                                 picapital
                                );

         IF vresp4044 IS NULL
         THEN
            RAISE NO_DATA_FOUND;
         END IF;

         v_fefecto := TO_DATE (vresp4044, 'YYYYMMDD');
         /*Esta es la verdadera fecha efecto de la póliza*/
         vtraza := 3;

         IF pnmovimi = 1
         THEN  /*Para nmovmi 1 (NP) buscamos pregunta manual del capital ini*/
            BEGIN
               SELECT e.crespue
                 INTO vresp4070
                 FROM estpregungaranseg e
                WHERE e.sseguro = psseguro
                  AND e.nmovimi = NVL (pnmovimi, e.nmovimi)
                  AND e.cgarant = pcgarant
                  AND e.nriesgo = NVL (pnriesgo, e.nriesgo)
                  AND e.cpregun = 4070;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  vresp4070 := NULL;
            END;

            vtraza := 4;

            BEGIN            /*La fecha del ultimo cambio de capital migrado*/
               SELECT e.trespue                                    /*JRH IMP*/
                 INTO vresp4054
                 FROM estpregungaranseg e
                WHERE e.sseguro = psseguro
                  AND e.nmovimi = NVL (pnmovimi, e.nmovimi)
                  AND e.cgarant = pcgarant
                  AND e.nriesgo = NVL (pnriesgo, e.nriesgo)
                  AND e.cpregun = 4054;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  vresp4054 := NULL;
            END;

            vtraza := 5;

            BEGIN             /*El último valor del capital cambiado migrado*/
               SELECT e.crespue
                 INTO vresp4055
                 FROM estpregungaranseg e
                WHERE e.sseguro = psseguro
                  AND e.nmovimi = NVL (pnmovimi, e.nmovimi)
                  AND e.cgarant = pcgarant
                  AND e.nriesgo = NVL (pnriesgo, e.nriesgo)
                  AND e.cpregun = 4055;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  vresp4055 := NULL;
            END;

            vtraza := 6;
            vresp4070 := vresp4070;

            /*De momento estamos el capital inicial migrado*/
            /*Capital inicial devuelta po rl afunción*/
            IF    NVL (vresp4070, 0) <> 0
               /*Si el capital / capitales están está migrado*/
               OR vresp4054 IS NOT NULL
               OR NVL (vresp4055, 0) <> 0
            THEN
               IF vresp4054 IS NOT NULL
               THEN
                  /*Si ha habido cambio en el capital  inicial de  migración*/
                  /*PArtimos del vresp4055 que tiene el último valor cambiado*/
                  vanualidad :=
                     TRUNC (  MONTHS_BETWEEN (TO_DATE (vresp4054,
                                                       'DD/MM/YYYY'),
                                              v_fefecto
                                             )
                            / 12
                           );
                  vtraza := 7;

                  IF vcrevali = 10
                  THEN
                     /*vresp4070 := vresp4055 / POWER(1 +((vprevali / 100) * vanualidad), vanualidad);   --Capital inicial devuelto po la función*/
                     vresp4070 :=
                          vresp4055
                        / POWER (1 + ((vprevali / 100) * vanualidad * 12), 1);
                  /*Capital inicial devuelto po la función*/
                  ELSIF vcrevali = 11
                  THEN
                     /*vresp4070 := vresp4055 / POWER(1 +((vprevali / 100) * vanualidad), vanualidad);   --Capital inicial devuelto po la función*/
                     vresp4070 :=
                          vresp4055
                        / POWER (1 + ((vprevali / 100) * vanualidad * 12), 1);
                  /*Capital inicial devuelto po la función*/
                  ELSE
                     vresp4070 :=
                         vresp4055 / POWER (1 + (vprevali / 100), vanualidad);
                  /*Capital inicial devuelto po la función*/
                  END IF;
               END IF;
            ELSE
               /*Si no existen capitales iniciales migrados le ponemos el valor al capital ini el de la garantia actual*/
               vresp4070 := picapital;
            /*Capital inicial devuelto po la función*/
            END IF;
         ELSE                                                   /*Suplemento*/
            BEGIN
               SELECT e.icapital                   /*Buscamos capital actual*/
                 INTO vcapital_ant
                 FROM garanseg e
                WHERE e.sseguro = v_ssegpol
                  /* Bug 20995 - RSC - 16/02/2012 - LCOL - UAT - TEC - Incidencias de Contratacion*/
                  AND e.nmovimi =
                         (SELECT MAX (e2.nmovimi)
                            FROM garanseg e2
                           WHERE e2.sseguro = e.sseguro
                             AND e2.nriesgo = e.nriesgo
                             AND e2.cgarant = e.cgarant)
                  AND e.cgarant = pcgarant
                  AND e.nriesgo = NVL (pnriesgo, e.nriesgo);
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  vcapital_ant := 0;
            END;

            vtraza := 8;

            IF vcapital_ant <> picapital
            THEN                /*Si se cambia, este es el nuevo capital ini*/
               vresp4070 := picapital;
               /*Si cambia el capital este será el ultimo pero hemos de actualizarlo*/
               vanualidad := TRUNC (MONTHS_BETWEEN (pfefecto, v_fefecto) / 12);

               IF vcrevali = 10
               THEN
                  /*vresp4070 := picapital / POWER(1 +((vprevali / 100) * vanualidad), vanualidad);*/
                  vresp4070 :=
                       picapital
                     / POWER (1 + ((vprevali / 100) * vanualidad * 12), 1);
               ELSIF vcrevali = 11
               THEN
                  /*vresp4070 := picapital / POWER(1 +((vprevali / 100) * vanualidad), vanualidad);*/
                  vresp4070 :=
                       picapital
                     / POWER (1 + ((vprevali / 100) * vanualidad * 12), 1);
               ELSE
                  vresp4070 :=
                         picapital / POWER (1 + (vprevali / 100), vanualidad);
               END IF;

               vtraza := 10;
            ELSE
               BEGIN
                  /* Bug 21167 - RSC - 27/02/2012 - Sustituimos 4071 por 4074!!!*/
                  SELECT e.crespue
                    INTO vresp4070
                    FROM pregungaranseg e
                   WHERE e.sseguro = v_ssegpol
                     /* Bug 20995 - RSC - 16/02/2012 - LCOL - UAT - TEC - Incidencias de Contratacion*/
                     AND e.nmovimi =
                            (SELECT MAX (e2.nmovimi)
                               FROM pregungaranseg e2
                              WHERE e2.sseguro = e.sseguro
                                AND e2.nriesgo = e.nriesgo
                                AND e2.cgarant = e.cgarant
                                AND e2.cpregun = e.cpregun)
                     AND e.cgarant = pcgarant
                     AND e.nriesgo = NVL (pnriesgo, e.nriesgo)
                     AND e.cpregun = 4074;
               /*Si no, me quedo con el valor anterior (actual) de la pregunta*/
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     vresp4070 := 0;
               END;
            END IF;
         END IF;

         vtraza := 11;
      ELSE
         BEGIN    /*Valor de la pregunta*/
             /* Bug 21167 - RSC - 27/02/2012 - Sustituimos 4071 por 4074!!!*/
            SELECT e.crespue
              INTO vresp4070
              FROM pregungaranseg e
             WHERE e.sseguro = psseguro
               AND e.nmovimi =
                      (SELECT MAX (e2.nmovimi)
                         FROM pregungaranseg e2
                        WHERE e2.sseguro = e.sseguro
                          AND e2.nriesgo = e.nriesgo
                          AND e2.cgarant = e.cgarant
                          AND e2.cpregun = e.cpregun)
               AND e.cgarant = pcgarant
               AND e.nriesgo = NVL (pnriesgo, e.nriesgo)
               AND e.cpregun = 4074;
         /*Si no, me quedo con el valor anterior (actual)*/
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               vresp4070 := 0;
         END;
      END IF;

      vtraza := 12;
      RETURN vresp4070;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_propio_albsgt_conf.f_capital_inicial',
                      vtraza,
                         ' - ptablas  '
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
                      SQLERRM
                     );
         RETURN NULL;
   END f_capital_inicial;

   /* Fi  Bug 19612 - JRH - 07/11/2011*/
   /* Bug 19808 - RSC - 08/11/2011 - LCOL_T004-Parametrización de suplementos*/
   FUNCTION f_sexo_riesgo (
      ptablas     IN   VARCHAR2,
      psseguro    IN   NUMBER,
      pnriesgo    IN   NUMBER,
      pfefecto    IN   DATE,
      pnmovimi    IN   NUMBER,
      cgarant     IN   NUMBER,
      psproces    IN   NUMBER,
      pnmovima    IN   NUMBER,
      picapital   IN   NUMBER
   )
      RETURN NUMBER
   IS
      v_fnacimi   DATE;
      v_ssegpol   NUMBER;
      v_fefecto   DATE;
      v_fecha     DATE;
      v_edad      NUMBER;
      v_fcaranu   DATE;
      v_csexo     NUMBER (1);
   BEGIN
      IF ptablas = 'EST'
      THEN
         /* Estamos en nueva produccion o suplementos*/
         BEGIN
            SELECT p.csexper
              INTO v_csexo
              FROM estriesgos r, estper_personas p, estseguros s
             WHERE r.sseguro = psseguro
               AND s.sseguro = r.sseguro
               AND r.sperson = p.sperson
               AND r.nriesgo = pnriesgo;
         EXCEPTION
            WHEN OTHERS
            THEN
               RETURN NULL;
         END;
      ELSIF ptablas = 'SOL'
      THEN
         /* Estamos en nueva produccion o suplementos*/
         BEGIN
            SELECT csexper
              INTO v_csexo
              FROM solriesgos r, solseguros s
             WHERE r.ssolicit = psseguro
               AND s.ssolicit = r.ssolicit
               AND r.nriesgo = pnriesgo;
         EXCEPTION
            WHEN OTHERS
            THEN
               RETURN NULL;
         END;
      ELSE
         /* Estamos cartera*/
         BEGIN
            SELECT p.csexper
              INTO v_csexo
              FROM riesgos r, per_personas p, seguros s
             WHERE r.sseguro = psseguro
               AND s.sseguro = r.sseguro
               AND r.sperson = p.sperson
               AND r.nriesgo = pnriesgo;
         EXCEPTION
            WHEN OTHERS
            THEN
               RETURN NULL;
         END;
      END IF;

      RETURN v_csexo;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 22222;
   END f_sexo_riesgo;

   /* Fin Bug 19808*/
   /* Bug 20163/98005 - RSC - 17/11/2011*/
   FUNCTION f_fechavto (
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
      v_fnacimi            per_personas.fnacimi%TYPE;
      v_fefecto            seguros.fefecto%TYPE;
      v_fvencim            seguros.fvencim%TYPE;
      v_sproduc            seguros.sproduc%TYPE;
      v_edad_efecto        NUMBER;
      v_temporadas         NUMBER;
      v_fecha_renovacion   DATE;
      v_edad_ftemporada    NUMBER;
      v_nedamar            garanpro.nedamar%TYPE;
      v_fvencim_gar        seguros.fvencim%TYPE;
      v_nrenova            seguros.nrenova%TYPE;
      v_cdurmin            productos.cdurmin%TYPE;
      /* Bug 21808 - RSC - 28/06/2012 - LCOL - UAT - Revisión de Listados Producción*/
      vresp4044            pregunpolseg.crespue%TYPE;
      /* Fin Bug 21808*/
      /* Bug 35293/201350 - 27/03/2015*/
      v_respue4043         NUMBER;
   BEGIN
      IF ptablas = 'EST'
      THEN
         BEGIN
            SELECT fnacimi, s.fefecto, s.sproduc, s.fvencim, s.nrenova
              INTO v_fnacimi, v_fefecto, v_sproduc, v_fvencim, v_nrenova
              FROM estriesgos r, estper_personas p, estseguros s
             WHERE r.sseguro = psseguro
               AND s.sseguro = r.sseguro
               AND r.sperson = p.sperson
               AND r.nriesgo = pnriesgo;
         EXCEPTION
            WHEN OTHERS
            THEN
               RETURN NULL;
         END;
      ELSE
         BEGIN
            SELECT p.fnacimi, s.fefecto, s.sproduc, s.fvencim, s.nrenova
              INTO v_fnacimi, v_fefecto, v_sproduc, v_fvencim, v_nrenova
              FROM riesgos r, per_personas p, seguros s
             WHERE r.sseguro = psseguro
               AND s.sseguro = r.sseguro
               AND r.sperson = p.sperson
               AND r.nriesgo = pnriesgo;
         EXCEPTION
            WHEN OTHERS
            THEN
               RETURN NULL;
         END;
      END IF;

      /* Bug 21808 - RSC - 28/06/2012 - LCOL - UAT - Revisión de Listados Producción*/
      vresp4044 :=
         f_fefecto_migracion (ptablas,
                              psseguro,
                              pnriesgo,
                              pfefecto,
                              pnmovimi,
                              pcgarant,
                              psproces,
                              pnmovima,
                              picapital
                             );
      v_fefecto := TO_DATE (vresp4044, 'YYYYMMDD');

      /* Fin Bug 21808*/
      BEGIN
         SELECT cdurmin
           INTO v_cdurmin
           FROM productos p
          WHERE sproduc = v_sproduc;
      EXCEPTION
         WHEN OTHERS
         THEN
            RETURN 101919;       /* Error al leer datos de la tabla seguros*/
      END;

      /* Bug 35293/201350 - 27/03/2015*/
      v_respue4043 :=
         f_tabla_mortalidad (ptablas,
                             psseguro,
                             pnriesgo,
                             pfefecto,
                             pnmovimi,
                             pcgarant,
                             psproces,
                             pnmovima,
                             picapital
                            );

      IF v_cdurmin = 9
      THEN
         IF v_sproduc = 6013 AND pcgarant IN (10, 701, 714)
         THEN
            SELECT nedamar
              INTO v_nedamar
              FROM garanpro
             WHERE sproduc = v_sproduc AND cgarant = pcgarant;

            IF v_sproduc IN (6007, 6008)
            THEN
               v_fvencim := ADD_MONTHS (v_fnacimi, v_nedamar * 12);
            END IF;

            v_edad_ftemporada :=
               fedad (NULL,
                      TO_NUMBER (TO_CHAR (v_fnacimi, 'YYYYMMDD')),
                      TO_NUMBER (TO_CHAR (v_fvencim, 'YYYYMMDD')),
                      1
                     );

            IF v_edad_ftemporada > v_nedamar
            THEN
               v_fvencim_gar := ADD_MONTHS (v_fnacimi, 12 * v_nedamar);
            ELSE
               v_fvencim_gar := v_fvencim;
            END IF;

            IF v_fvencim_gar IS NOT NULL
            THEN
               IF v_fvencim_gar <
                     TO_DATE (   TO_CHAR (v_fvencim_gar, 'YYYY')
                              || LPAD (v_nrenova, 4, '0'),
                              'YYYYMMDD'
                             )
               THEN
                  v_fvencim_gar :=
                     TO_DATE (   TO_CHAR (v_fvencim_gar, 'YYYY')
                              || LPAD (v_nrenova, 4, '0'),
                              'YYYYMMDD'
                             );
               ELSE
                  v_fvencim_gar :=
                     TO_DATE (   (  TO_NUMBER (TO_CHAR (v_fvencim_gar, 'YYYY'))
                                  + 1
                                 )
                              || LPAD (v_nrenova, 4, '0'),
                              'YYYYMMDD'
                             );
               END IF;
            END IF;
         /* Bug 35293/201350 - 27/03/2015*/
         ELSIF v_sproduc IN (6005, 6006) AND v_respue4043 = 2
         THEN
            SELECT   nedamar
                   - NVL (f_parproductos_v (v_sproduc, 'PER_REV_NO_ANUAL'),
                          10)
              INTO v_nedamar
              FROM garanpro
             WHERE sproduc = v_sproduc AND cgarant = pcgarant;

            v_fvencim := ADD_MONTHS (v_fnacimi, v_nedamar * 12);
            v_edad_ftemporada :=
               fedad (NULL,
                      TO_NUMBER (TO_CHAR (v_fnacimi, 'YYYYMMDD')),
                      TO_NUMBER (TO_CHAR (v_fvencim, 'YYYYMMDD')),
                      1
                     );

            IF v_edad_ftemporada > v_nedamar
            THEN
               v_fvencim_gar := ADD_MONTHS (v_fnacimi, 12 * v_nedamar);
            ELSE
               v_fvencim_gar := v_fvencim;
            END IF;
         /* Bug 35293/201350 - 27/03/2015*/
         /*
         IF v_nrenova IS NOT NULL THEN
            IF v_fvencim_gar IS NOT NULL THEN
               IF v_fvencim_gar < TO_DATE(TO_CHAR(v_fvencim_gar, 'YYYY')
                                          || LPAD(v_nrenova, 4, '0'),
                                          'YYYYMMDD') THEN
                  v_fvencim_gar := TO_DATE(TO_CHAR(v_fvencim_gar, 'YYYY')
                                           || LPAD(v_nrenova, 4, '0'),
                                           'YYYYMMDD');
               ELSE
                  v_fvencim_gar := TO_DATE((TO_NUMBER(TO_CHAR(v_fvencim_gar, 'YYYY')) + 1)
                                           || LPAD(v_nrenova, 4, '0'),
                                           'YYYYMMDD');
               END IF;
            END IF;
         END IF;*/
         ELSE
            IF v_sproduc IN (6005, 6006)
            THEN
               SELECT   nedamar
                      - NVL (f_parproductos_v (v_sproduc, 'PER_REV_NO_ANUAL'),
                             10
                            )
                 INTO v_nedamar
                 FROM garanpro
                WHERE sproduc = v_sproduc AND cgarant = pcgarant;
            ELSE
               SELECT nedamar
                 INTO v_nedamar
                 FROM garanpro
                WHERE sproduc = v_sproduc AND cgarant = pcgarant;
            END IF;

            v_edad_efecto :=
               fedad (NULL,
                      TO_NUMBER (TO_CHAR (v_fnacimi, 'YYYYMMDD')),
                      TO_NUMBER (TO_CHAR (v_fefecto, 'YYYYMMDD')),
                      1
                     );
            v_temporadas :=
               TRUNC (  (v_nedamar - v_edad_efecto)
                      / NVL (f_parproductos_v (v_sproduc, 'PER_REV_NO_ANUAL'),
                             10
                            )
                     );

            IF v_temporadas > 0
            THEN
               v_fecha_renovacion :=
                  ADD_MONTHS (v_fnacimi,
                                12
                              * (  v_edad_efecto
                                 + (  v_temporadas
                                    * NVL
                                         (f_parproductos_v (v_sproduc,
                                                            'PER_REV_NO_ANUAL'
                                                           ),
                                          10
                                         )
                                   )
                                )
                             );
            ELSE
               v_fecha_renovacion :=
                  ADD_MONTHS (v_fnacimi,
                                12
                              * (  v_edad_efecto
                                 + NVL (f_parproductos_v (v_sproduc,
                                                          'PER_REV_NO_ANUAL'
                                                         ),
                                        10
                                       )
                                )
                             );
            END IF;

            v_edad_ftemporada :=
               fedad (NULL,
                      TO_NUMBER (TO_CHAR (v_fnacimi, 'YYYYMMDD')),
                      TO_NUMBER (TO_CHAR (v_fecha_renovacion, 'YYYYMMDD')),
                      1
                     );

            IF v_edad_ftemporada <= v_nedamar
            THEN
               /* Bug 35293/203734 - 04/05/2015*/
                 /*v_fvencim_gar := ADD_MONTHS(v_fecha_renovacion,
                                             12
                                             * NVL(f_parproductos_v(v_sproduc,
                                                                    'PER_REV_NO_ANUAL'),
                                                   10));*/
               v_fvencim_gar := v_fecha_renovacion;
            ELSE
               v_fvencim_gar := v_fecha_renovacion;
            END IF;

            IF v_nrenova IS NOT NULL
            THEN
               IF v_fvencim_gar IS NOT NULL
               THEN
                  IF v_fvencim_gar <
                        TO_DATE (   TO_CHAR (v_fvencim_gar, 'YYYY')
                                 || LPAD (v_nrenova, 4, '0'),
                                 'YYYYMMDD'
                                )
                  THEN
                     v_fvencim_gar :=
                        TO_DATE (   TO_CHAR (v_fvencim_gar, 'YYYY')
                                 || LPAD (v_nrenova, 4, '0'),
                                 'YYYYMMDD'
                                );
                  ELSE
                     v_fvencim_gar :=
                        TO_DATE (   (  TO_NUMBER (TO_CHAR (v_fvencim_gar,
                                                           'YYYY'
                                                          )
                                                 )
                                     + 1
                                    )
                                 || LPAD (v_nrenova, 4, '0'),
                                 'YYYYMMDD'
                                );
                  END IF;
               END IF;
            END IF;
         END IF;
      ELSE
         SELECT nedamar
           INTO v_nedamar
           FROM garanpro
          WHERE sproduc = v_sproduc AND cgarant = pcgarant;

         IF v_sproduc IN (6007, 6008)
         THEN
            v_fvencim := ADD_MONTHS (v_fnacimi, v_nedamar * 12);
         END IF;

         v_edad_ftemporada :=
            fedad (NULL,
                   TO_NUMBER (TO_CHAR (v_fnacimi, 'YYYYMMDD')),
                   TO_NUMBER (TO_CHAR (v_fvencim, 'YYYYMMDD')),
                   1
                  );

         IF v_edad_ftemporada > v_nedamar
         THEN
            v_fvencim_gar := ADD_MONTHS (v_fnacimi, 12 * v_nedamar);
         ELSE
            v_fvencim_gar := v_fvencim;
         END IF;
      END IF;

      RETURN TO_NUMBER (TO_CHAR (v_fvencim_gar, 'YYYYMMDD'));
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_propio_albsgt_conf.f_fechavto',
                      1,
                         'ptablas = '
                      || ptablas
                      || ' psseguro = '
                      || psseguro
                      || ' pnriesgo = '
                      || pnriesgo
                      || ' pfefecto = '
                      || pfefecto
                      || ' pnmovimi = '
                      || pnmovimi
                      || ' pcgarant = '
                      || pcgarant
                      || ' psproces = '
                      || psproces
                      || ' pnmovima = '
                      || pnmovima
                      || ' picapital = '
                      || picapital,
                      SQLERRM
                     );
         RETURN NULL;
   END f_fechavto;

   FUNCTION f_version_condicionado (
      ptablas     IN   VARCHAR2,
      psseguro    IN   NUMBER,
      pnriesgo    IN   NUMBER,
      pfefecto    IN   DATE,
      pnmovimi    IN   NUMBER,
      pcgarant    IN   NUMBER,
      psproces    IN   NUMBER,
      pnmovima    IN   NUMBER,
      picapital   IN   NUMBER,
      pnpoliza    IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      v_fechaini    DATE;
      v_fechaini2   DATE;
      vsproduc      productos.sproduc%TYPE;
      v_ccondicio   condicionadoprod.ccondicio%TYPE;
      v_select      condicionadoprod.tversion%TYPE;
      vn_versio     condicionadoprod.nversio%TYPE;
      cur           PLS_INTEGER;
      fdbk          PLS_INTEGER;
      vactcondi     NUMBER;
      v_fcaranu     DATE;
      v_fefecto     DATE;
      vnpoliza      NUMBER;         /* Bug 27768/0156835 - APD - 29/10/2013*/

      CURSOR versiones (pc_sproduc IN NUMBER, pc_fecha IN DATE)
      IS
         SELECT   *
             FROM condicionadoprod
            WHERE sproduc = pc_sproduc
              AND (    finiefe <= pc_fecha
                   AND (ffinefe >= pc_fecha OR ffinefe IS NULL)
                  )
         ORDER BY nversio DESC;                                           /**/
   BEGIN
      /* Bug 27768/0156835 - APD - 29/10/2013*/
      /* Si el producto admite certificados y no es el certificado 0,*/
          /* se debe arrastrar la respuesta del certificado 0*/
      IF     NVL
                (f_parproductos_v
                                (pac_iax_produccion.poliza.det_poliza.sproduc,
                                 'ADMITE_CERTIFICADOS'
                                ),
                 0
                ) = 1
         AND NOT f_alta_certificado (ptablas, psseguro)
      THEN
         v_ccondicio :=
            pac_propio_albsgt_conf.f_arrastra_pregunta (NVL (ptablas, 'SEG'),
                                                        psseguro,
                                                        pnriesgo,
                                                        pfefecto,
                                                        pnmovimi,
                                                        pcgarant,
                                                        psproces,
                                                        pnmovima,
                                                        picapital,
                                                        pnpoliza,
                                                        4777
                                                       );
      ELSE
         /* el producto no admite certificados o si admite y es el certificado 0*/
           /* fin Bug 27768/0156835 - APD - 29/10/2013*/
         IF ptablas = 'EST'
         THEN
            /*{evaluamos la formula, sino son tablas temporales no lo haresmo}*/
            /*1) miraremos si es una poliza migrada*/
            /*Bug 26267/152149 - 12/09/2013 - AMC*/
            BEGIN
               SELECT sproduc
                 INTO vsproduc
                 FROM estseguros
                WHERE sseguro = psseguro;
            EXCEPTION
               WHEN OTHERS
               THEN
                  RETURN NULL;
            END;

            vactcondi :=
                 pac_parametros.f_parproducto_n (vsproduc, 'ACT_CONDICIONADO');

            IF vactcondi = 0
            THEN
               BEGIN
                  /* JMC 02/03/2013 INI*/
                  /*            SELECT TO_DATE(crespue, 'YYYYMMDD')*/
                  /*              INTO v_fechaini*/
                  /*              FROM estpregunpolseg*/
                  /*             WHERE cpregun = 4046*/
                  /*               AND sseguro = psseguro*/
                  /*               AND nmovimi = pnmovimi;*/
                  SELECT TO_DATE (trespue, 'DD/MM/YYYY')
                    INTO v_fechaini
                    FROM estpregunpolseg
                   WHERE cpregun = 4044
                     AND sseguro = psseguro
                     AND nmovimi = pnmovimi;
               /* JMC 02/03/2013 FIN*/
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     NULL;                   /* la obtendremos de la póliza*/
                  WHEN OTHERS
                  THEN
                     RETURN NULL;     /* la fecha de migració es incorrecte*/
               END;

               /*2) obtendremos el producto*/
               BEGIN
                  SELECT fefecto, sproduc
                    INTO v_fechaini2, vsproduc
                    FROM estseguros
                   WHERE sseguro = psseguro;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     RETURN NULL;
               END;

               v_fechaini := NVL (v_fechaini, v_fechaini2);
            ELSE
               SELECT fcaranu, fefecto
                 INTO v_fcaranu, v_fefecto
                 FROM estseguros
                WHERE sseguro = psseguro;

               IF pfefecto = v_fcaranu
               THEN
                  v_fechaini := pfefecto;
               ELSE
                  BEGIN
                     SELECT MAX (fefecto)
                       INTO v_fechaini
                       FROM movseguro
                      WHERE sseguro = psseguro AND cmovseg = 2;

                     IF (v_fechaini IS NULL) OR (v_fechaini < v_fefecto)
                     THEN
                        v_fechaini := v_fefecto;
                     END IF;
                  END;
               END IF;
            END IF;

            /*Fi Bug 26267/152149 - 12/09/2013 - AMC*/
            BEGIN
               SELECT ccondicio
                 INTO v_ccondicio
                 FROM condicionadoprod
                WHERE sproduc = vsproduc
                  AND (    finiefe <= v_fechaini
                       AND (ffinefe >= v_fechaini OR ffinefe IS NULL)
                      );
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  RETURN NULL;
               WHEN TOO_MANY_ROWS
               THEN
                  /*L HEMOS LIADO DENEBMOS OBTENER LA VERSION.*/
                  FOR c IN versiones (vsproduc, v_fechaini)
                  LOOP
                     IF c.nversio = 0
                     THEN
                        /* si llegqamos a la ulñtima version (version por defecto) retornamos esta como buena.*/
                        RETURN c.ccondicio;
                     END IF;

                     IF c.tversion IS NOT NULL
                     THEN
                        BEGIN
                           cur := DBMS_SQL.open_cursor;              /*nunu*/
                           DBMS_SQL.parse (cur,
                                           REPLACE (c.tversion,
                                                    ':psseguro',
                                                    psseguro
                                                   ),
                                           DBMS_SQL.native
                                          );
                           DBMS_SQL.define_column (cur, 1, vn_versio);
                           /*    DBMS_OUTPUT.put_line(c.tversion);*/
                           /*definición de la columna*/
                           fdbk := DBMS_SQL.EXECUTE (cur);

                           /*ejecución de la consulta*/
                           IF DBMS_SQL.fetch_rows (cur) > 0
                           THEN
                              /*posisción en el primer registro de la select*/
                              DBMS_SQL.COLUMN_VALUE (cur, 1, vn_versio);

                              BEGIN
                                 SELECT ccondicio
                                   INTO v_ccondicio
                                   FROM condicionadoprod
                                  WHERE sproduc = vsproduc
                                    AND (    finiefe <= v_fechaini
                                         AND (   ffinefe >= v_fechaini
                                              OR ffinefe IS NULL
                                             )
                                        )
                                    AND nversio = vn_versio;

                                 RETURN v_ccondicio;
                              EXCEPTION
                                 WHEN NO_DATA_FOUND
                                 THEN
                                    NULL;
                              END;
                           /*volcado del valor de la consulta en la variable*/
                           ELSE
                              vn_versio := 0;
                           /*teoricamente aqui nunca entrará (nvl)*/
                           END IF;

                           DBMS_SQL.close_cursor (cur);
                        /*cerramos el cursor de la consulta*/
                        EXCEPTION
                           WHEN OTHERS
                           THEN
                              /*DBMS_OUTPUT.put_line(SQLERRM);*/
                              IF DBMS_SQL.is_open (cur)
                              THEN
                                 /*Cerramos el cursor si esta abierto.*/
                                 DBMS_SQL.close_cursor (cur);
                              END IF;
                        END;
                     END IF;
                  END LOOP;
            END;
         ELSE
                 /* qt 21585 a lo mejor no llega a nulo !!! IF ptablas IS NULL THEN*/
            /*Bug 26267/152149 - 12/09/2013 - AMC*/
            BEGIN
               SELECT sproduc, fcaranu
                 INTO vsproduc, v_fcaranu
                 FROM seguros
                WHERE sseguro = psseguro;
            EXCEPTION
               WHEN OTHERS
               THEN
                  RETURN NULL;
            END;

            vactcondi :=
                 pac_parametros.f_parproducto_n (vsproduc, 'ACT_CONDICIONADO');

            IF vactcondi = 0 OR (vactcondi = 1 AND pfefecto <> v_fcaranu)
            THEN
               BEGIN
                  SELECT crespue
                    INTO v_ccondicio
                    FROM pregunpolseg
                   WHERE cpregun = 4777
                     AND sseguro = psseguro
                     AND nmovimi =
                                (SELECT MAX (nmovimi)
                                   FROM pregunpolseg
                                  WHERE cpregun = 4777 AND sseguro = psseguro);
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     BEGIN
                        SELECT crespue
                          INTO v_ccondicio
                          FROM pregunpolseg
                         WHERE cpregun = 4777
                           AND sseguro = psseguro
                           AND nmovimi = pnmovimi;
                     EXCEPTION
                        WHEN NO_DATA_FOUND
                        THEN
                           NULL;
                     END;
               END;
            ELSE
               v_fechaini := pfefecto;

               BEGIN
                  SELECT ccondicio
                    INTO v_ccondicio
                    FROM condicionadoprod
                   WHERE sproduc = vsproduc
                     AND (    finiefe <= v_fechaini
                          AND (ffinefe >= v_fechaini OR ffinefe IS NULL)
                         );
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     RETURN NULL;
                  WHEN TOO_MANY_ROWS
                  THEN
                     /*L HEMOS LIADO DENEBMOS OBTENER LA VERSION.*/
                     FOR c IN versiones (vsproduc, v_fechaini)
                     LOOP
                        IF c.nversio = 0
                        THEN
                           /* si llegqamos a la ulñtima version (version por defecto) retornamos esta como buena.*/
                           RETURN c.ccondicio;
                        END IF;

                        IF c.tversion IS NOT NULL
                        THEN
                           BEGIN
                              cur := DBMS_SQL.open_cursor;           /*nunu*/
                              DBMS_SQL.parse (cur,
                                              REPLACE (c.tversion,
                                                       ':psseguro',
                                                       psseguro
                                                      ),
                                              DBMS_SQL.native
                                             );
                              DBMS_SQL.define_column (cur, 1, vn_versio);
                              /*    DBMS_OUTPUT.put_line(c.tversion);*/
                              /*definición de la columna*/
                              fdbk := DBMS_SQL.EXECUTE (cur);

                              /*ejecución de la consulta*/
                              IF DBMS_SQL.fetch_rows (cur) > 0
                              THEN
                                 /*posisción en el primer registro de la select*/
                                 DBMS_SQL.COLUMN_VALUE (cur, 1, vn_versio);

                                 BEGIN
                                    SELECT ccondicio
                                      INTO v_ccondicio
                                      FROM condicionadoprod
                                     WHERE sproduc = vsproduc
                                       AND (    finiefe <= v_fechaini
                                            AND (   ffinefe >= v_fechaini
                                                 OR ffinefe IS NULL
                                                )
                                           )
                                       AND nversio = vn_versio;

                                    RETURN v_ccondicio;
                                 EXCEPTION
                                    WHEN NO_DATA_FOUND
                                    THEN
                                       NULL;
                                 END;
                              /*volcado del valor de la consulta en la variable*/
                              ELSE
                                 vn_versio := 0;
                              /*teoricamente aqui nunca entrará (nvl)*/
                              END IF;

                              DBMS_SQL.close_cursor (cur);
                           /*cerramos el cursor de la consulta*/
                           EXCEPTION
                              WHEN OTHERS
                              THEN
                                 /*DBMS_OUTPUT.put_line(SQLERRM);*/
                                 IF DBMS_SQL.is_open (cur)
                                 THEN
                                    /*Cerramos el cursor si esta abierto.*/
                                    DBMS_SQL.close_cursor (cur);
                                 END IF;
                           END;
                        END IF;
                     END LOOP;
               END;
            END IF;
         /*Fi Bug 26267/152149 - 12/09/2013 - AMC*/
         END IF;
      END IF;                    /* fin Bug 27768/0156835 - APD - 29/10/2013*/

      RETURN v_ccondicio;
   END f_version_condicionado;

   FUNCTION f_fecha_renovacion (
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
      v_fechaini2   DATE;
      v_fechaini    DATE;
      v_fvencim     DATE;
      v_fcaranu     DATE;
      v_arenova     NUMBER;
      vsproduc      productos.sproduc%TYPE;
      i             NUMBER                   := 1;
   BEGIN
      BEGIN
         BEGIN
            SELECT TO_DATE (crespue, 'YYYYMMDD')
              INTO v_fechaini
              FROM pregunpolcar
             WHERE cpregun = 4046
               AND sseguro = psseguro
               AND nmovimi = NVL (pnmovimi, 1)
               AND sproces = psproces;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               NULL;                         /* la obtendremos de la póliza*/
            WHEN OTHERS
            THEN
               RETURN NULL;           /* la fecha de migració es incorrecte*/
         END;
      END;

      /*  if v_fechaini=0 then*/
      /* v_fechaini:= NULL;*/
      /*  end if;*/
      IF ptablas = 'EST'
      THEN
         /*2) obtendremos el producto*/
         BEGIN
            SELECT fefecto, sproduc, fvencim, NVL (fefecto, pfefecto)
              INTO v_fechaini2, vsproduc, v_fvencim, v_fcaranu
              FROM estseguros
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS
            THEN
               RETURN NULL;
         END;
      /* Bug 20671 - JRH - 20/01/2012 - 20671 : Ponemoss  un else*/
      /* JRH 20671 ELSIF ptablas IS NULL THEN*/
      /* Bug 20671 - JRH - 20/01/2012 - 20671*/
      ELSE
         /*2) obtendremos el producto*/
         /* Bug 28832 - JMG - 12/11/2013 - Se realiza modificación de campo fcaranu incluyendo nvl*/
         BEGIN
            SELECT fefecto, sproduc, fvencim, NVL (fcaranu, fefecto)
              INTO v_fechaini2, vsproduc, v_fvencim, v_fcaranu
              FROM seguros
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS
            THEN
               RETURN NULL;
         END;
      END IF;

      v_fechaini := NVL (v_fechaini, v_fechaini2);
      v_arenova :=
         NVL (pac_parametros.f_parproducto_n (vsproduc, 'PER_REV_NO_ANUAL'),
              1);

      IF v_arenova = 150
      THEN
         RETURN TO_NUMBER (TO_CHAR (v_fvencim, 'YYYYMMDD'));
      ELSE
         WHILE ADD_MONTHS (v_fechaini, v_arenova * i * 12) <= v_fcaranu
         LOOP
            i := i + 1;                                                  /**/
         END LOOP;

         IF TO_CHAR (ADD_MONTHS (v_fechaini, v_arenova * i * 12), 'MMDD') =
                                                                        '0229'
         THEN
            RETURN TO_NUMBER (TO_CHAR (  ADD_MONTHS (v_fechaini,
                                                     v_arenova * i * 12
                                                    )
                                       - 1,
                                       'YYYYMMDD'
                                      )
                             );
         ELSE
            RETURN TO_NUMBER (TO_CHAR (ADD_MONTHS (v_fechaini,
                                                   v_arenova * i * 12
                                                  ),
                                       'YYYYMMDD'
                                      )
                             );
         END IF;
      END IF;
   END f_fecha_renovacion;

   /* Bug 20163 - RSC - 02/12/2011 -  LCOL_T004-Completar parametrización de los productos de Vida Individual (2ª parte)*/
   FUNCTION f_calcula_revaloriza (
      ptablas     IN   VARCHAR2,
      psseguro    IN   NUMBER,
      pnriesgo    IN   NUMBER,
      pfefecto    IN   DATE,
      pnmovimi    IN   NUMBER,
      pcgarant    IN   NUMBER,
      psproces    IN   NUMBER,
      pnmovima    IN   NUMBER,
      picapital   IN   NUMBER,
      pmodo       IN   NUMBER DEFAULT 1
   )
      RETURN NUMBER
   IS
      v_fechaini2   DATE;
      v_fechaini    DATE;
      v_fvencim     DATE;
      v_fcaranu     DATE;
      v_arenova     NUMBER;
      i             NUMBER                           := 1;
      vsproduc      productos.sproduc%TYPE;
      vresp4071     estpregungaranseg.crespue%TYPE;
      v_importe     NUMBER                           := 0;
      v_crevali     seguros.crevali%TYPE;
      v_prevali     seguros.prevali%TYPE;
      v_nanuali     seguros.nanuali%TYPE;
      v_capital     garanseg.icapital%TYPE;
      v_sproduc     seguros.sproduc%TYPE;
      /* Bug 20163 - RSC - 12/12/2011 - LCOL_T004-Completar parametrización de los productos de Vida Individual (2ª parte)*/
      vresp4044     estpregungaranseg.crespue%TYPE;
      v_fefecto     DATE;
      /* Fin Bug 20163*/
      vresp4072     estpregungaranseg.crespue%TYPE;
      v_primer      NUMBER                           := 1;
   BEGIN
      IF ptablas = 'EST'
      THEN
         SELECT nanuali, sproduc
           INTO v_nanuali, v_sproduc
           FROM estseguros e
          WHERE e.sseguro = psseguro;

         SELECT crevali, prevali
           INTO v_crevali, v_prevali
           FROM estgaranseg
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND cgarant = pcgarant
            AND nmovimi = pnmovimi;
      ELSE
         SELECT nanuali, sproduc
           INTO v_nanuali, v_sproduc
           FROM seguros e
          WHERE e.sseguro = psseguro;

         SELECT crevali, prevali
           INTO v_crevali, v_prevali
           FROM garanseg
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND cgarant = pcgarant
            AND nmovimi = pnmovimi;
      END IF;

      IF ptablas IN ('EST', 'CAR')
      THEN
         vresp4071 :=
            f_capital_inicial (ptablas,
                               psseguro,
                               pnriesgo,
                               pfefecto,
                               pnmovimi,
                               pcgarant,
                               psproces,
                               pnmovima,
                               picapital
                              );

         IF vresp4071 IS NULL
         THEN
            RAISE NO_DATA_FOUND;
         END IF;

         IF v_crevali = 11
         THEN
            /* Bug 20163 - RSC - 16/12/2011 (Eliminamos * anuali)*/
            v_importe := (v_prevali / 100) * vresp4071 * 12;
         ELSIF v_crevali = 10
         THEN
            vresp4044 :=
               f_fefecto_migracion (ptablas,
                                    psseguro,
                                    pnriesgo,
                                    pfefecto,
                                    pnmovimi,
                                    pcgarant,
                                    psproces,
                                    pnmovima,
                                    picapital
                                   );
            v_fefecto := TO_DATE (vresp4044, 'YYYYMMDD');
            /*SELECT TRUNC(MONTHS_BETWEEN(pfefecto, v_fefecto) / 12) + 1*/
            /*INTO v_nanuali*/
            /*FROM DUAL;*/
            /* partiendo de la pregunta 4071 'Capital inicial calculado' y dependiendo*/
            /* de la altura debe tener en cuenta que revaloriza lineal cada año y en la*/
              /* renovación revaloriza sobre el capital alcanzado en ese momento.*/
            v_capital := vresp4071;

            FOR i IN 0 .. v_nanuali
            LOOP
               IF     MOD (i,
                           f_parproductos_v (v_sproduc, 'PER_REV_NO_ANUAL')
                          ) = 0
                  AND i <> 0
               THEN
                  v_capital := v_capital + v_importe;
                  v_importe := (v_prevali / 100) * v_capital * 12;
               ELSE
                  v_capital := v_capital + v_importe;

                  IF v_primer = 1
                  THEN
                     v_importe := (v_prevali / 100) * v_capital * 12;
                  END IF;

                  v_primer := 0;
               END IF;
            END LOOP;
         END IF;

         IF pmodo = 1
         THEN
            RETURN v_importe;
         ELSE
            RETURN v_capital;
         END IF;
      ELSE
         BEGIN    /*Valor de la pregunta*/
             /* Bug 21167 - RSC - 27/02/2012 - Sustituimos 4071 por 4074!!!*/
            SELECT e.crespue
              INTO vresp4072
              FROM pregungaranseg e
             WHERE e.sseguro = psseguro
               AND e.nmovimi =
                      (SELECT MAX (e2.nmovimi)
                         FROM pregungaranseg e2
                        WHERE e2.sseguro = e.sseguro
                          AND e2.nriesgo = e.nriesgo
                          AND e2.cgarant = e.cgarant
                          AND e2.cpregun = e.cpregun)
               AND e.cgarant = pcgarant
               AND e.nriesgo = NVL (pnriesgo, e.nriesgo)
               AND e.cpregun = 4072;
         /*Si no, me quedo con el valor anterior (actual)*/
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               vresp4072 := 0;
         END;

         RETURN vresp4072;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_propio_albsgt_conf.f_calcula_revaloriza',
                      1,
                         'ptablas = '
                      || ptablas
                      || ' psseguro = '
                      || psseguro
                      || ' pnriesgo = '
                      || pnriesgo
                      || ' pfefecto = '
                      || pfefecto
                      || ' pnmovimi = '
                      || pnmovimi
                      || ' pcgarant = '
                      || pcgarant
                      || ' psproces = '
                      || psproces
                      || ' pnmovima = '
                      || pnmovima
                      || ' picapital = '
                      || picapital,
                      SQLERRM
                     );
         RETURN NULL;
   END f_calcula_revaloriza;

   /* Fin Bug 20163*/
   /* Bug 20163 - RSC - 02/12/2011 -  LCOL_T004-Completar parametrización de los productos de Vida Individual (2ª parte)*/
   FUNCTION f_prima_nivelada_gar (
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
      v_tabla     pregungaranseg.crespue%TYPE;
      v_cramo     seguros.cramo%TYPE;
      v_cmodali   seguros.cmodali%TYPE;
      v_ctipseg   seguros.ctipseg%TYPE;
      v_ccolect   seguros.ccolect%TYPE;
      v_cactivi   seguros.cactivi%TYPE;
   BEGIN
      IF ptablas = 'EST'
      THEN
         SELECT cramo, cmodali, ctipseg, ccolect, cactivi
           INTO v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_cactivi
           FROM estseguros e
          WHERE e.sseguro = psseguro;
      ELSE
         SELECT cramo, cmodali, ctipseg, ccolect, cactivi
           INTO v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_cactivi
           FROM seguros e
          WHERE e.sseguro = psseguro;
      END IF;

      v_tabla :=
         f_tabla_mortalidad (ptablas,
                             psseguro,
                             pnriesgo,
                             pfefecto,
                             pnmovimi,
                             pcgarant,
                             psproces,
                             pnmovima,
                             picapital
                            );

      IF    (    NVL (f_pargaranpro_v (v_cramo,
                                       v_cmodali,
                                       v_ctipseg,
                                       v_ccolect,
                                       v_cactivi,
                                       pcgarant,
                                       'REC_SUP_PM_GAR'
                                      ),
                      0
                     ) = 2
             AND v_tabla = 1
            )
         OR NVL (f_pargaranpro_v (v_cramo,
                                  v_cmodali,
                                  v_ctipseg,
                                  v_ccolect,
                                  v_cactivi,
                                  pcgarant,
                                  'REC_SUP_PM_GAR'
                                 ),
                 3
                ) = 3
      THEN
         /* Si lo tiene definido a 2 y la tabla de mortalidad es la 84-88 entonces el recibo irá por diferencia de prima.*/
         /* Si no tiene el parametro 'REC_SUP_PM_GAR' definido se considerará recibo por diferencia de prima.*/
           /* Si lo tiene definido a 3 se considera por diferencia de prima.*/
         RETURN 0;
      ELSE
         RETURN 1;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_propio_albsgt_conf.f_prima_nivelada_gar',
                      1,
                         'ptablas = '
                      || ptablas
                      || ' psseguro = '
                      || psseguro
                      || ' pnriesgo = '
                      || pnriesgo
                      || ' pfefecto = '
                      || pfefecto
                      || ' pnmovimi = '
                      || pnmovimi
                      || ' pcgarant = '
                      || pcgarant
                      || ' psproces = '
                      || psproces
                      || ' pnmovima = '
                      || pnmovima
                      || ' picapital = '
                      || picapital,
                      SQLERRM
                     );
         RETURN NULL;
   END f_prima_nivelada_gar;

   /* Fin Bug 20163*/
   /*Inicio del bug  20498#c101492*/
   FUNCTION f_beneficiario_oneroso (
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
      v_resultado   NUMBER := 0;
   BEGIN
      IF ptablas = 'EST'
      THEN
         BEGIN
            SELECT 1
              INTO v_resultado
              FROM estbenespseg
             WHERE ctipben = 2 AND sseguro = psseguro AND nmovimi = pnmovimi;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               v_resultado := 0;                          /* no es oneroso;*/
            WHEN TOO_MANY_ROWS
            THEN
               v_resultado := 1;         /* son onerosos; y hay más de uno.*/
         END;
      ELSE
         BEGIN
            SELECT 1
              INTO v_resultado
              FROM benespseg
             WHERE ctipben = 2 AND sseguro = psseguro AND nmovimi = pnmovimi;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               v_resultado := 0;                          /* no es oneroso;*/
            WHEN TOO_MANY_ROWS
            THEN
               v_resultado := 1;         /* son onerosos; y hay más de uno.*/
            WHEN OTHERS
            THEN
               v_resultado := 0;             /* OTRAS TABLAS NO CONTROLADAS*/
         END;
      END IF;

      RETURN v_resultado;
   END f_beneficiario_oneroso;

   /*Fin bug 20498#c101492*/
   FUNCTION f_fecha_tasa_cambio (
      ptablas     IN   VARCHAR2,
      psseguro    IN   NUMBER,
      pnriesgo    IN   NUMBER,
      pfefecto    IN   DATE,
      pnmovimi    IN   NUMBER,
      pcgarant    IN   NUMBER,
      psproces    IN   NUMBER,
      pnmovima    IN   NUMBER,
      picapital   IN   NUMBER,
      pcmonori    IN   VARCHAR2 DEFAULT 'COP',
      pcmondes    IN   VARCHAR2 DEFAULT 'USD'
   )
      RETURN NUMBER
   IS
      v_resultado   NUMBER;
      vresp4056     pregunpolseg.crespue%TYPE;
      v_fefecto     estriesgos.fefecto%TYPE;
      v_fecha       movseguro.fefecto%TYPE;
      v_fcaranu     seguros.fcaranu%TYPE;
      v_ssegpol     estseguros.ssegpol%TYPE;
   BEGIN
      IF ptablas = 'EST'
      THEN
         IF pnmovimi = 1
         THEN
            BEGIN
               SELECT ssegpol, r.fefecto
                 INTO v_ssegpol, v_fefecto
                 FROM estriesgos r, estseguros s
                /* FROM estriesgos r, estper_personas p, estseguros s    -- Bug 25739 - FAL - 2/4/2013. Per autos no aplica filtrar per sperson. I no es recupera res de personas. No cal join amb per_personas*/
               WHERE  r.sseguro = psseguro
                  AND s.sseguro = r.sseguro
                  /* AND r.sperson = p.sperson  -- Bug 25739 - FAL - 2/4/2013.*/
                  AND r.nriesgo = pnriesgo;
            EXCEPTION
               WHEN OTHERS
               THEN
                  RETURN NULL;
            END;

            BEGIN
               SELECT MIN (finiefe)
                 INTO v_fefecto
                 FROM estgaranseg
                WHERE sseguro = psseguro
                  AND nriesgo = pnriesgo
                  AND cgarant = pcgarant
                  AND nmovimi = pnmovimi;
            EXCEPTION
               WHEN OTHERS
               THEN
                  RETURN NULL;
            END;

            BEGIN
               SELECT MAX (fefecto)
                 INTO v_fecha
                 FROM movseguro
                WHERE sseguro = v_ssegpol AND cmovseg = 2;

               IF (v_fecha IS NULL) OR (v_fecha < v_fefecto)
               THEN
                  v_fecha := v_fefecto;
               END IF;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  v_fecha := v_fefecto;
            END;

            v_resultado :=
               TO_NUMBER
                   (TO_CHAR (pac_eco_tipocambio.f_fecha_max_cambio (pcmonori,
                                                                    pcmondes,
                                                                    v_fecha
                                                                   ),
                             'yyyymmdd'
                            )
                   );
         ELSE
            /* Bug 20995 -RSC - 16/02/2012 - LCOL - UAT - TEC - Incidencias de Contratacion*/
            BEGIN
               SELECT ssegpol
                 INTO v_ssegpol
                 /*FROM estriesgos r, estper_personas p, estseguros s    -- Bug 25739 - FAL - 2/4/2013. Per autos no aplica filtrar per sperson. I no es recupera res de personas. No cal join amb per_personas*/
               FROM   estriesgos r, estseguros s
                WHERE r.sseguro = psseguro
                  AND s.sseguro = r.sseguro
                  /* AND r.sperson = p.sperson          -- Bug 25739 - FAL - 2/4/2013.*/
                  AND r.nriesgo = pnriesgo;
            EXCEPTION
               WHEN OTHERS
               THEN
                  RETURN NULL;
            END;

            /* Fin Bug 20995*/
            BEGIN
               SELECT e.crespue
                 INTO vresp4056
                 FROM pregunpolseg e
                WHERE e.sseguro = v_ssegpol
                  /* Bug 20995 -RSC - 16/02/2012 - LCOL - UAT - TEC - Incidencias de Contratacion*/
                  AND e.nmovimi =
                         (SELECT MAX (e2.nmovimi)
                            FROM pregunpolseg e2
                           WHERE e2.sseguro = e.sseguro
                             AND e2.cpregun = e.cpregun)
                  AND e.cpregun = 4056;

               /*Si no, me quedo con el valor anterior (actual) de la pregunta*/
               v_resultado := vresp4056;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  BEGIN
                     SELECT ssegpol, r.fefecto
                       INTO v_ssegpol, v_fefecto
                       /* FROM estriesgos r, estper_personas p, estseguros s   -- Bug 25739 - FAL - 2/4/2013. Per autos no aplica filtrar per sperson. I no es recupera res de personas. No cal join amb per_personas*/
                     FROM   estriesgos r, estseguros s
                      WHERE r.sseguro = psseguro
                        AND s.sseguro = r.sseguro
                        /*AND r.sperson = p.sperson   -- Bug 25739 - FAL - 2/4/2013.*/
                        AND r.nriesgo = pnriesgo;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        RETURN NULL;
                  END;

                  BEGIN
                     SELECT MIN (finiefe)
                       INTO v_fefecto
                       FROM estgaranseg
                      WHERE sseguro = psseguro
                        AND nriesgo = pnriesgo
                        AND cgarant = pcgarant
                        AND nmovimi = pnmovimi;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        RETURN NULL;
                  END;

                  BEGIN
                     SELECT MAX (fefecto)
                       INTO v_fecha
                       FROM movseguro
                      WHERE sseguro = v_ssegpol AND cmovseg = 2;

                     IF (v_fecha IS NULL) OR (v_fecha < v_fefecto)
                     THEN
                        v_fecha := v_fefecto;
                     END IF;
                  EXCEPTION
                     WHEN NO_DATA_FOUND
                     THEN
                        v_fecha := v_fefecto;
                  END;

                  v_resultado :=
                     TO_NUMBER
                        (TO_CHAR
                            (pac_eco_tipocambio.f_fecha_max_cambio (pcmonori,
                                                                    pcmondes,
                                                                    v_fecha
                                                                   ),
                             'yyyymmdd'
                            )
                        );
            END;
         END IF;
      ELSE
         BEGIN
            SELECT r.fefecto, s.fcaranu
              INTO v_fefecto, v_fcaranu
              /*FROM riesgos r, per_personas p, seguros s     -- Bug 25739 - FAL - 2/4/2013. Per autos no aplica filtrar per sperson. I no es recupera res de personas. No cal join amb per_personas*/
            FROM   riesgos r, seguros s
             WHERE r.sseguro = psseguro
               AND s.sseguro = r.sseguro
               /* AND r.sperson = p.sperson             -- Bug 25739 - FAL - 2/4/2013*/
               AND r.nriesgo = pnriesgo;
         EXCEPTION
            WHEN OTHERS
            THEN
               RETURN NULL;
         END;

         BEGIN
            SELECT MIN (finiefe)
              INTO v_fefecto
              FROM garanseg
             WHERE sseguro = psseguro
               AND nriesgo = pnriesgo
               AND cgarant = pcgarant
               AND nmovimi = pnmovimi;
         EXCEPTION
            WHEN OTHERS
            THEN
               RETURN NULL;
         END;

         IF pfefecto = v_fcaranu
         THEN
            v_fecha := pfefecto;
         ELSE
            BEGIN
               SELECT MAX (fefecto)
                 INTO v_fecha
                 FROM movseguro
                WHERE sseguro = psseguro AND cmovseg = 2;

               IF (v_fecha IS NULL) OR (v_fecha < v_fefecto)
               THEN
                  v_fecha := v_fefecto;
               END IF;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  v_fecha := v_fefecto;
            END;
         END IF;

         v_resultado :=
            TO_NUMBER
                   (TO_CHAR (pac_eco_tipocambio.f_fecha_max_cambio (pcmonori,
                                                                    pcmondes,
                                                                    v_fecha
                                                                   ),
                             'yyyymmdd'
                            )
                   );
      END IF;

      RETURN v_resultado;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_propio_albsgt_conf.f_fecha_tasa_cambio',
                      1,
                         'ptablas = '
                      || ptablas
                      || ' psseguro = '
                      || psseguro
                      || ' pnriesgo = '
                      || pnriesgo
                      || ' pfefecto = '
                      || pfefecto
                      || ' pnmovimi = '
                      || pnmovimi
                      || ' pcgarant = '
                      || pcgarant
                      || ' psproces = '
                      || psproces
                      || ' pnmovima = '
                      || pnmovima
                      || ' picapital = '
                      || picapital
                      || ' pcmonori = '
                      || pcmonori
                      || ' pcmondes = '
                      || pcmondes,
                      SQLERRM
                     );
         RETURN NULL;
   END f_fecha_tasa_cambio;

   FUNCTION f_tasa_cambio (
      ptablas     IN   VARCHAR2,
      psseguro    IN   NUMBER,
      pnriesgo    IN   NUMBER,
      pfefecto    IN   DATE,
      pnmovimi    IN   NUMBER,
      pcgarant    IN   NUMBER,
      psproces    IN   NUMBER,
      pnmovima    IN   NUMBER,
      picapital   IN   NUMBER,
      pcmonori    IN   VARCHAR2 DEFAULT 'COP',
      pcmondes    IN   VARCHAR2 DEFAULT 'USD'
   )
      RETURN NUMBER
   IS
      v_itasa       NUMBER;
      vresp4056     estpregunpolseg.crespue%TYPE;
      vresp4056_d   DATE;
   BEGIN
      SELECT TO_DATE (crespue, 'YYYYMMDD')
        INTO vresp4056_d
        FROM pregungarancar
       WHERE cpregun = 4056
         AND sseguro = psseguro
         AND nmovimi = NVL (pnmovimi, 1)
         AND nriesgo = pnriesgo
         AND cgarant = pcgarant
         AND sproces = psproces;

      v_itasa := pac_eco_tipocambio.f_cambio (pcmonori, pcmondes, vresp4056_d);
      RETURN v_itasa;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_propio_albsgt_conf.f_fecha_tasa_cambio',
                      1,
                         'ptablas = '
                      || ptablas
                      || ' psseguro = '
                      || psseguro
                      || ' pnriesgo = '
                      || pnriesgo
                      || ' pfefecto = '
                      || pfefecto
                      || ' pnmovimi = '
                      || pnmovimi
                      || ' pcgarant = '
                      || pcgarant
                      || ' psproces = '
                      || psproces
                      || ' pnmovima = '
                      || pnmovima
                      || ' picapital = '
                      || picapital,
                      SQLERRM
                     );
         RETURN NULL;
   END f_tasa_cambio;

   /* Bug 20725 - RSC - 16/02/2012 - 0020725: LCOL_T001-LCOL - UAT - TEC - Simulacion*/
   FUNCTION f_capital_decada_nivelada (
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
      num_err         NUMBER;
      v_mortalitat    NUMBER;
      vresp4027       pregunseg.crespue%TYPE;
      vresp4070       pregunseg.crespue%TYPE;
      vresp4071       pregungaranseg.crespue%TYPE;
      vresp4055       pregunseg.crespue%TYPE;
      vresp4054       estpregungaranseg.trespue%TYPE;
      vresp4044       pregunseg.trespue%TYPE;
      vresp4044_n     NUMBER;
      vcapital_ant    NUMBER;
      v_comisi        NUMBER;
      v_fefecto       DATE;
      v_sproduc       seguros.sproduc%TYPE;
      vcrevali        seguros.crevali%TYPE;
      vprevali        seguros.prevali%TYPE;
      vanualidad      NUMBER;
      vtraza          NUMBER;
      v_ssegpol       estseguros.ssegpol%TYPE;
      vesnivelada     NUMBER;
      v_fecha_reval   DATE;
      vresp4072       estpregungaranseg.crespue%TYPE;
      vresp           NUMBER;
   BEGIN
      IF ptablas = 'EST'
      THEN
         vtraza := 1;

         SELECT sproduc, crevali, prevali, ssegpol
           INTO v_sproduc, vcrevali, vprevali, v_ssegpol
           FROM estseguros
          WHERE sseguro = psseguro;

         vesnivelada :=
                     NVL (f_parproductos_v (v_sproduc, 'PER_REV_NO_ANUAL'), 1);
         vtraza := 2;
/*--------------------------------------------------------*/
         vresp4071 :=
            f_capital_inicial (ptablas,
                               psseguro,
                               pnriesgo,
                               pfefecto,
                               pnmovimi,
                               pcgarant,
                               psproces,
                               pnmovima,
                               picapital
                              );

         IF vresp4071 IS NULL
         THEN
            RAISE NO_DATA_FOUND;
         END IF;

         IF vesnivelada = 150
         THEN
            RETURN vresp4071;
         END IF;

/*---------------------------------------------------------------------*/
         vtraza := 3;
         vresp4027 :=
            f_decada_nivelada (ptablas,
                               psseguro,
                               pnriesgo,
                               pfefecto,
                               pnmovimi,
                               pcgarant,
                               psproces,
                               pnmovima,
                               picapital
                              );

         IF vresp4027 IS NULL
         THEN
            RAISE NO_DATA_FOUND;
         END IF;

         vtraza := 4;

         IF v_sproduc = 6013
         THEN
            vresp4072 := picapital;
         END IF;

         vtraza := 8;

         IF vcrevali = 10
         THEN                                                /* Solo el 6013*/
            vresp := vresp4072;
         ELSE
            vresp :=
                 vresp4071
               * POWER (1 + (vprevali / 100), (vresp4027 - 1) * vesnivelada);
         /*Capital inicial devuelto po la función*/
         END IF;
      ELSE
         vtraza := 1;

         SELECT sproduc, crevali, prevali
           INTO v_sproduc, vcrevali, vprevali
           FROM seguros
          WHERE sseguro = psseguro;

         vesnivelada :=
                     NVL (f_parproductos_v (v_sproduc, 'PER_REV_NO_ANUAL'), 1);
         vtraza := 2;
/*--------------------------------------------------------*/
         vresp4071 :=
            f_capital_inicial (ptablas,
                               psseguro,
                               pnriesgo,
                               pfefecto,
                               pnmovimi,
                               pcgarant,
                               psproces,
                               pnmovima,
                               picapital
                              );

         IF vresp4071 IS NULL
         THEN
            RAISE NO_DATA_FOUND;
         END IF;

         IF vesnivelada = 150
         THEN
            RETURN vresp4071;
         END IF;

/*---------------------------------------------------------------------*/
         vtraza := 3;
         vresp4027 :=
            f_decada_nivelada (ptablas,
                               psseguro,
                               pnriesgo,
                               pfefecto,
                               pnmovimi,
                               pcgarant,
                               psproces,
                               pnmovima,
                               picapital
                              );

         IF vresp4027 IS NULL
         THEN
            RAISE NO_DATA_FOUND;
         END IF;

         vtraza := 4;

         IF v_sproduc = 6013
         THEN
            vresp4072 := picapital;
         END IF;

         vtraza := 8;

         IF vcrevali = 10
         THEN                                                /* Solo el 6013*/
            vresp := vresp4072;
         ELSE
            vresp :=
                 vresp4071
               * POWER (1 + (vprevali / 100), (vresp4027 - 1) * vesnivelada);
         /*Capital inicial devuelto po la función*/
         END IF;
      END IF;

      RETURN vresp;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_propio_albsgt_conf.f_capital_decada_nivelada',
                      vtraza,
                         ' - ptablas  '
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
                      SQLERRM
                     );
         RETURN NULL;
   END f_capital_decada_nivelada;

   /* Bug 21863 - RSC - 02/05/2012 - LCOL_F001-LCOL - Incidencias Reservas*/
   FUNCTION f_calc_prima_inicial (
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
      v_error             NUMBER;
      ntraza              NUMBER;
      vresp4044           pregunseg.crespue%TYPE;
      v_fefecto           DATE;
      v_edad_efecto       NUMBER;
      v_tabla_mort        pregunseg.crespue%TYPE;
      v_ndurcob           seguros.ndurcob%TYPE;
      v_prevali           seguros.prevali%TYPE;
      v_tasa              NUMBER;
      v_gastos_adq        NUMBER;
      v_anualidad_riesg   NUMBER;
      v_gastos_admin      NUMBER;
      v_gastos_com        NUMBER;
      v_comisc1           NUMBER;
      v_capital           garanseg.icapital%TYPE;
      vresp               NUMBER;
      v_sexo              per_personas.csexper%TYPE;
      vproducto           NUMBER;
   BEGIN
      IF ptablas = 'EST'
      THEN
         SELECT sproduc
           INTO vproducto
           FROM estseguros
          WHERE sseguro = psseguro;
      ELSE
         SELECT sproduc
           INTO vproducto
           FROM seguros
          WHERE sseguro = psseguro;
      END IF;

      ntraza := 2;
      /* Capital inicial*/
      v_capital :=
         pac_propio_albsgt_conf.f_capital_inicial (ptablas,
                                                   psseguro,
                                                   pnriesgo,
                                                   pfefecto,
                                                   pnmovimi,
                                                   pcgarant,
                                                   psproces,
                                                   pnmovima,
                                                   picapital
                                                  );
      /* Fecha migración*/
      vresp4044 :=
         pac_propio_albsgt_conf.f_fefecto_migracion (ptablas,
                                                     psseguro,
                                                     pnriesgo,
                                                     pfefecto,
                                                     pnmovimi,
                                                     pcgarant,
                                                     psproces,
                                                     pnmovima,
                                                     picapital
                                                    );
      v_fefecto := TO_DATE (vresp4044, 'YYYYMMDD');
      /* Edad efecto*/
      v_edad_efecto :=
         pac_propio_albsgt_conf.f_edad_decada_nivelada (ptablas,
                                                        psseguro,
                                                        pnriesgo,
                                                        v_fefecto,
                                                        pnmovimi,
                                                        pcgarant,
                                                        psproces,
                                                        pnmovima,
                                                        picapital
                                                       );

      IF ptablas = 'EST'
      THEN
         BEGIN
            SELECT p.csexper
              INTO v_sexo
              FROM estriesgos r, estper_personas p, estseguros s
             WHERE r.sseguro = psseguro
               AND s.sseguro = r.sseguro
               AND r.sperson = p.sperson
               AND r.nriesgo = pnriesgo;
         EXCEPTION
            WHEN OTHERS
            THEN
               RETURN NULL;
         END;
      ELSE
         BEGIN
            SELECT p.csexper
              INTO v_sexo
              FROM riesgos r, per_personas p, seguros s
             WHERE r.sseguro = psseguro
               AND s.sseguro = r.sseguro
               AND r.sperson = p.sperson
               AND r.nriesgo = pnriesgo;
         EXCEPTION
            WHEN OTHERS
            THEN
               RETURN NULL;
         END;
      END IF;

      IF v_sexo = 2 AND pcgarant = 6901
      THEN
         v_edad_efecto := v_edad_efecto - 4;
      END IF;

      IF v_edad_efecto < 20
      THEN
         v_edad_efecto := 20;
      END IF;

      /* Tabla de mortalidad*/
      v_tabla_mort :=
         pac_propio_albsgt_conf.f_tabla_mortalidad (ptablas,
                                                    psseguro,
                                                    pnriesgo,
                                                    pfefecto,
                                                    pnmovimi,
                                                    pcgarant,
                                                    psproces,
                                                    pnmovima,
                                                    picapital
                                                   );

      IF ptablas = 'EST'
      THEN
         SELECT ndurcob, prevali
           INTO v_ndurcob, v_prevali
           FROM estseguros
          WHERE sseguro = psseguro;
      ELSE
         SELECT ndurcob, prevali
           INTO v_ndurcob, v_prevali
           FROM seguros
          WHERE sseguro = psseguro;
      END IF;

      IF vproducto = 6012
      THEN
         SELECT pac_subtablas.f_vsubtabla (NULL,
                                           1014,
                                           3333333,
                                           1,
                                           v_ndurcob,
                                           v_tabla_mort,
                                           pcgarant,
                                           v_edad_efecto,
                                           1,
                                           v_prevali,
                                           1
                                          )
           INTO v_tasa
           FROM DUAL;
      ELSE
         SELECT pac_subtablas.f_vsubtabla (NULL,
                                           1015,
                                           333333,
                                           1,
                                           v_tabla_mort,
                                           pcgarant,
                                           v_edad_efecto,
                                           1,
                                           v_prevali,
                                           1
                                          )
           INTO v_tasa
           FROM DUAL;
      END IF;

      /* GASTOS_RIESG_ADQ*/
      SELECT pac_subtablas.f_vsubtabla (NULL,
                                        1000,
                                        333333,
                                        1,
                                        vproducto,
                                        NVL (v_ndurcob, 0),
                                        v_tabla_mort,
                                        pcgarant,
                                        1,
                                        1
                                       )
        INTO v_gastos_adq
        FROM DUAL;

      /* ANUALIDAD_RIESG*/
      v_anualidad_riesg := 1;

      /* GASTOS_RIESG_ADMIN*/
      SELECT pac_subtablas.f_vsubtabla (NULL,
                                        1000,
                                        333333,
                                        1,
                                        vproducto,
                                        NVL (v_ndurcob, 0),
                                        v_tabla_mort,
                                        pcgarant,
                                        1,
                                        0
                                       )
        INTO v_gastos_admin
        FROM DUAL;

      /* GASTOS_COM_1*/
      v_comisc1 :=
         pac_propio_albsgt_conf.f_comision_c1 (ptablas,
                                               psseguro,
                                               pnriesgo,
                                               pfefecto,
                                               pnmovimi,
                                               pcgarant,
                                               psproces,
                                               pnmovima,
                                               picapital
                                              );
      v_gastos_com := (1 / (1 - (v_comisc1 / 100) - v_gastos_admin));
      /* Tasa*/
      v_tasa := ((v_tasa + v_gastos_adq) / v_anualidad_riesg) * v_gastos_com;
      RETURN (v_tasa * v_capital);
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_propio_albsgt_conf.f_calc_prima_inicial',
                      ntraza,
                         ' - ptablas  '
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
                      SQLERRM
                     );
         RETURN NULL;
   END f_calc_prima_inicial;

   /* BUG22843:DRA:16/07/2012:Inici*/
   /* BUG24058:DCT: 07/11/2012: Inici - Calcular la edad promedio del colectivo mirando los certificados que culegan del 0*/
   /* BUG16913:CAM: 13/02/2015: Optimización Procesos de Vida Grupo Función f_edad_promedio para Certificado Cero*/
   FUNCTION f_edad_promedio (
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
      v_error      NUMBER;
      ntraza       NUMBER;
      v_edad_tot   NUMBER  := 0;
      v_num_tom    NUMBER;
      v_fnacimi    DATE;
      v_npoliza    NUMBER;
      visaltacol   BOOLEAN := FALSE;
      v_ncertif    NUMBER;
   BEGIN
      IF pac_iax_produccion.isaltacol
      THEN
         visaltacol := TRUE;
      ELSE
         IF ptablas = 'EST'
         THEN
            SELECT npoliza, ncertif
              INTO v_npoliza, v_ncertif
              FROM estseguros
             WHERE sseguro = psseguro;
         ELSE
            SELECT npoliza, ncertif
              INTO v_npoliza, v_ncertif
              FROM seguros
             WHERE sseguro = psseguro;
         END IF;

         IF v_ncertif = 0
         THEN
            visaltacol := TRUE;
         END IF;
      END IF;

      /* BUG 0024058/0129071 - FAL - 08/11/2012*/
      IF visaltacol
      THEN                /* alta certificados, debe iterar sobre asegurados*/
       /* FI BUG 0024058/0129071 - FAL - 08/11/2012*/
       /* Bug 28479/156751 - 24/10/2013 - AMC*/
         BEGIN
            SELECT npoliza
              INTO v_npoliza
              FROM seguros
             WHERE sseguro = psseguro;

            SELECT COUNT (1)
              INTO v_num_tom
              FROM tomadores
             WHERE sseguro IN (SELECT sseguro
                                 FROM seguros
                                WHERE npoliza = v_npoliza AND ncertif <> 0);

            /*sseguro = psseguro);*/
            /* INI BUG 16913 – 13/02/2015 - CAMM - Se deja en comentario y se reemplaza por la sentencia SELECT a continuacion.*/
            /*FOR pol IN (SELECT sseguro
                          FROM seguros
                         WHERE npoliza = v_npoliza
                           AND ncertif <> 0) LOOP
               FOR tom IN (SELECT fnacimi
                             INTO v_fnacimi
                             FROM per_personas p, tomadores t
                            WHERE t.sseguro = pol.sseguro
                              AND p.sperson = t.sperson) LOOP
                  v_edad_tot := v_edad_tot
                                + fedad(-1, TO_NUMBER(TO_CHAR(tom.fnacimi, 'YYYYMMDD')),
                                        TO_NUMBER(TO_CHAR(f_sysdate, 'YYYYMMDD')), 1);
               END LOOP;
            END LOOP;*/
            SELECT SUM (DECODE (fnacimi,
                                NULL, -1,
                                TRUNC (MONTHS_BETWEEN (f_sysdate, fnacimi)
                                       / 12)
                               )
                       )
              INTO v_edad_tot
              FROM per_personas p, tomadores t
             WHERE t.sseguro IN (SELECT sseguro
                                   FROM seguros
                                  WHERE npoliza = v_npoliza AND ncertif <> 0)
               AND p.sperson = t.sperson;
         /* FIN BUG 16913 - 13/02/2015 - CAM*/
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               v_num_tom := 1;
               v_edad_tot := 0;
         END;
      /* Fi Bug 28479/156751 - 24/10/2013 - AMC*/
      ELSE                                                 /* alta colectivo*/
         IF ptablas = 'EST'
         THEN
            SELECT npoliza
              INTO v_npoliza
              FROM estseguros
             WHERE sseguro = psseguro;

            SELECT COUNT (1)
              INTO v_num_tom
              FROM estassegurats
             WHERE sseguro IN (SELECT sseguro
                                 FROM estseguros
                                WHERE npoliza = v_npoliza AND ncertif <> 0);

            /*sseguro = psseguro);*/
            /* INI BUG 16913 – 13/02/2015 - CAMM - Se deja en comentario y se reemplaza por la sentencia SELECT a continuacion.*/
              /*FOR pol IN (SELECT sseguro
                            FROM estseguros
                           WHERE npoliza = v_npoliza
                             AND ncertif <> 0) LOOP
                 FOR aseg IN (SELECT fnacimi
                                INTO v_fnacimi
                                FROM estper_personas p, estassegurats t
                               WHERE t.sseguro = pol.sseguro
                                 AND p.sperson = t.sperson) LOOP
                    v_edad_tot := v_edad_tot
                                  + fedad(-1, TO_NUMBER(TO_CHAR(aseg.fnacimi, 'YYYYMMDD')),
                                          TO_NUMBER(TO_CHAR(f_sysdate, 'YYYYMMDD')), 1);
                 END LOOP;
              END LOOP;*/
            SELECT SUM (DECODE (fnacimi,
                                NULL, -1,
                                TRUNC (MONTHS_BETWEEN (f_sysdate, fnacimi)
                                       / 12)
                               )
                       )
              INTO v_edad_tot
              FROM estper_personas p, estassegurats t
             WHERE t.sseguro IN (SELECT sseguro
                                   FROM estseguros
                                  WHERE npoliza = v_npoliza AND ncertif <> 0)
               AND p.sperson = t.sperson;
         /* FIN BUG 16913 - 13/02/2015 - CAM*/
         ELSE
            SELECT npoliza
              INTO v_npoliza
              FROM seguros
             WHERE sseguro = psseguro;

            SELECT COUNT (1)
              INTO v_num_tom
              FROM asegurados
             WHERE sseguro IN (SELECT sseguro
                                 FROM seguros
                                WHERE npoliza = v_npoliza AND ncertif <> 0);

            /*sseguro = psseguro);*/
            /* INI BUG 16913 – 13/02/2015 - CAMM - Se deja en comentario y se reemplaza por la sentencia SELECT a continuacion.*/
              /*FOR pol IN (SELECT sseguro
                            FROM seguros
                           WHERE npoliza = v_npoliza
                             AND ncertif <> 0) LOOP
                 FOR aseg IN (SELECT fnacimi
                                INTO v_fnacimi
                                FROM per_personas p, asegurados t
                               WHERE t.sseguro = pol.sseguro
                                 AND p.sperson = t.sperson) LOOP
                    v_edad_tot := v_edad_tot
                                  + fedad(-1, TO_NUMBER(TO_CHAR(aseg.fnacimi, 'YYYYMMDD')),
                                          TO_NUMBER(TO_CHAR(f_sysdate, 'YYYYMMDD')), 1);
                 END LOOP;
              END LOOP;*/
            SELECT SUM (DECODE (fnacimi,
                                NULL, -1,
                                TRUNC (MONTHS_BETWEEN (f_sysdate, fnacimi)
                                       / 12)
                               )
                       )
              INTO v_edad_tot
              FROM per_personas p, asegurados t
             WHERE t.sseguro IN (SELECT sseguro
                                   FROM seguros
                                  WHERE npoliza = v_npoliza AND ncertif <> 0)
               AND p.sperson = t.sperson;
         /* FIN BUG 16913 - 13/02/2015 - CAM*/
         END IF;
      END IF;

      RETURN (ROUND (v_edad_tot / v_num_tom, 2));
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_propio_albsgt_conf.f_edad_promedio',
                      ntraza,
                         ' - ptablas  '
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
                      SQLERRM
                     );
         RETURN NULL;
   END f_edad_promedio;

   /* BUG22843:DRA:16/07/2012:Fi*/
   /* BUG24058:DCT: 07/11/2012: Fi - Calcular la edad promedio del colectivo mirando los certificados que culegan del 0*/
   /* Bug 22839 - RSC - 17/07/2012 - LCOL - Funcionalidad Certificado 0*/
   FUNCTION f_arrastra_pregunta (
      ptablas      IN   VARCHAR2,
      psseguro     IN   NUMBER,
      pnriesgo     IN   NUMBER,
      pfefecto     IN   DATE,
      pnmovimi     IN   NUMBER,
      pcgarant     IN   NUMBER,
      psproces     IN   NUMBER,
      pnmovima     IN   NUMBER,
      picapital    IN   NUMBER,
      pnpoliza     IN   NUMBER,
      pcpregun     IN   NUMBER DEFAULT NULL,
      pnriesgocp   IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      v_crespue   estpregunpolseg.crespue%TYPE;
      v_trespue   estpregunpolseg.trespue%TYPE;
      v_npoliza   seguros.npoliza%TYPE;
      v_ctippre   NUMBER;
   BEGIN
      v_npoliza := pnpoliza;

      /*Bug 36217/209003 - 02/07/2015 - AMC*/
      /* Se comenta la igualdad AND p2.cpregun = p.cpregun a la hora de buscar el max(nmovimi)*/
      /* ya que para preguntas que se han eliminado estaba recuperando valores erroneos*/
      BEGIN
         SELECT crespue, trespue
           INTO v_crespue, v_trespue
           FROM seguros s, pregunpolseg p
          WHERE s.npoliza = v_npoliza
            AND s.ncertif = 0
            AND s.sseguro = p.sseguro
            AND p.nmovimi = (SELECT MAX (p2.nmovimi)
                               FROM pregunpolseg p2
                              WHERE p2.sseguro = p.sseguro
                                                          /*AND p2.cpregun = p.cpregun--BUG 36217/209215*/
                           )
            AND p.cpregun = pcpregun;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            BEGIN
               SELECT crespue, trespue
                 INTO v_crespue, v_trespue
                 FROM seguros s, pregunseg p
                WHERE s.npoliza = v_npoliza
                  AND s.ncertif = 0
                  AND s.sseguro = p.sseguro
                  AND p.nriesgo = NVL (pnriesgocp, pnriesgo)
                  AND p.nmovimi =
                         (SELECT MAX (p2.nmovimi)
                            FROM pregunseg p2
                           WHERE p2.sseguro = p.sseguro
                             /*AND p2.cpregun = p.cpregun--BUG 36217/209215*/
                             AND p2.nriesgo = p.nriesgo)
                  AND p.cpregun = pcpregun;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  BEGIN
                     SELECT crespue, trespue
                       INTO v_crespue, v_trespue
                       FROM seguros s, pregungaranseg p
                      WHERE s.npoliza = v_npoliza
                        AND s.ncertif = 0
                        AND s.sseguro = p.sseguro
                        AND p.nriesgo = NVL (pnriesgocp, pnriesgo)
                        AND p.cgarant = pcgarant
                        AND p.nmovimi =
                               (SELECT MAX (p2.nmovimi)
                                  FROM pregungaranseg p2
                                 WHERE p2.sseguro = p.sseguro
                                   /*AND p2.cpregun = p.cpregun--BUG 36217/209215*/
                                   AND p2.nriesgo = p.nriesgo
                                   AND p2.cgarant = p.cgarant)
                        AND p.cpregun = pcpregun;
                  EXCEPTION
                     WHEN NO_DATA_FOUND
                     THEN
                        RETURN NULL;
                  END;
            END;
      END;

      SELECT ctippre
        INTO v_ctippre
        FROM codipregun
       WHERE cpregun = pcpregun;

      IF v_trespue IS NOT NULL AND v_ctippre = 4
      THEN                                      /*la respuesta es una fecha-*/
         BEGIN
            v_crespue := TO_NUMBER (REPLACE (v_trespue, '/', ''));
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;
      END IF;

      RETURN v_crespue;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_propio_albsgt_conf.f_arrastra_pregunta',
                      1,
                         'ptabla = '
                      || ptablas
                      || ' psseguro = '
                      || psseguro
                      || ' pnriesgo = '
                      || pnriesgo
                      || ' pfefecto = '
                      || pfefecto
                      || ' pnmovimi = '
                      || pnmovimi
                      || ' pcgarant = '
                      || pcgarant
                      || ' psproces = '
                      || psproces
                      || ' pnmovima = '
                      || pnmovima
                      || ' picapital = '
                      || picapital
                      || ' pnpoliza = '
                      || pnpoliza
                      || ' pcpregun = '
                      || pcpregun,
                      SQLERRM
                     );
         RETURN NULL;
   END f_arrastra_pregunta;

   /* Fin Bug 22839*/
   FUNCTION f_hereda_pregunta (
      ptablas         IN   VARCHAR2,
      psseguro        IN   NUMBER,
      pnriesgo        IN   NUMBER,
      pfefecto        IN   DATE,
      pnmovimi        IN   NUMBER,
      pcgarant        IN   NUMBER,
      psproces        IN   NUMBER,
      pnmovima        IN   NUMBER,
      picapital       IN   NUMBER,
      pnpoliza        IN   NUMBER,
      pcpregun_orig   IN   NUMBER DEFAULT NULL,
      pcgarant_orig   IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      /**/
      v_crespue   estpregunpolseg.crespue%TYPE;
      num_err     NUMBER;
   BEGIN
      IF pcgarant_orig IS NOT NULL
      THEN
         num_err :=
            pac_preguntas.f_get_pregungaranseg (psseguro,
                                                pcgarant_orig,
                                                pnriesgo,
                                                pcpregun_orig,
                                                ptablas,
                                                v_crespue
                                               );
      ELSE
         num_err :=
            pac_preguntas.f_get_pregunseg (psseguro,
                                           pnriesgo,
                                           pcpregun_orig,
                                           NVL (ptablas, 'SEG'),
                                           v_crespue
                                          );
      END IF;

      RETURN v_crespue;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_propio_albsgt_conf.f_hereda_pregunta',
                      1,
                         'ptablas = '
                      || ptablas
                      || ' psseguro = '
                      || psseguro
                      || ' pnriesgo = '
                      || pnriesgo
                      || ' pfefecto = '
                      || pfefecto
                      || ' pnmovimi = '
                      || pnmovimi
                      || ' pcgarant = '
                      || pcgarant
                      || ' psproces = '
                      || psproces
                      || ' pnmovima = '
                      || pnmovima
                      || ' picapital = '
                      || picapital
                      || ' pnpoliza = '
                      || pnpoliza,
                      SQLERRM
                     );
         RETURN NULL;
   END f_hereda_pregunta;

   /* BUG 22781 - FAL - 10/07/2012*/
   FUNCTION f_num_asegur (
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
      v_num_aseg   NUMBER := 0;
      ntraza       NUMBER;
   BEGIN
      IF ptablas = 'EST'
      THEN
         SELECT COUNT (DISTINCT sperson)
           INTO v_num_aseg
           FROM estassegurats
          WHERE sseguro = psseguro;
      ELSE
         SELECT COUNT (DISTINCT sperson)
           INTO v_num_aseg
           FROM asegurados
          WHERE sseguro = psseguro;
      END IF;

      RETURN v_num_aseg;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_propio_albsgt_conf.f_num_asegur',
                      ntraza,
                         ' - ptablas  '
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
                      SQLERRM
                     );
         RETURN NULL;
   END f_num_asegur;

   FUNCTION f_porcen_valor_aseg (
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
      num_err         NUMBER                      := 0;
      v_crespue4087   pregunpolseg.crespue%TYPE;
      ntraza          NUMBER;
   BEGIN
      num_err :=
         pac_preguntas.f_get_pregunpolseg (psseguro,
                                           4087,
                                           NVL (ptablas, 'SEG'),
                                           v_crespue4087
                                          );

      IF num_err = 120135
      THEN                                             /* no_data_found then*/
         v_crespue4087 := 100;
      END IF;

      RETURN v_crespue4087;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_propio_albsgt_conf.f_porcen_valor_aseg',
                      ntraza,
                         ' - ptablas  '
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
                      SQLERRM
                     );
         RETURN NULL;
   END f_porcen_valor_aseg;

   /* FI BUG 22781*/
   /* BUG 22781/0121275 - FAL - 28/08/2012*/
   FUNCTION f_num_aseg_mayor_12 (
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
      v_edad_ries           NUMBER;
      v_num_aseg_mayor_12   NUMBER           := 0;
      ntraza                NUMBER;
      tmpdpoliza            ob_iax_detpoliza := NULL;
      ries                  t_iax_riesgos;                /* ob_iax_riesgos*/
      mensajes              t_iax_mensajes;
      w_edad                NUMBER;
   BEGIN
      IF ptablas = 'EST'
      THEN
         /*
         FOR aseg IN (SELECT DISTINCT r.sperson, r.nriesgo, r.fefecto
                                 FROM estassegurats e, estriesgos r
                                WHERE e.sseguro = psseguro
                                  AND e.sseguro = r.sseguro
                                  AND e.sperson = r.sperson) LOOP
            v_edad_ries := f_edad_riesgo(ptablas, psseguro, aseg.nriesgo, aseg.fefecto, NULL,
                                         NULL, NULL, NULL, NULL);

            IF NVL(v_edad_ries, 22222) <> 22222
               AND v_edad_ries >= 12 THEN
               v_num_aseg_mayor_12 := v_num_aseg_mayor_12 + 1;
            END IF;
         END LOOP;
         */
         tmpdpoliza := pac_iobj_prod.f_getpoliza (mensajes);
         ries := pac_iobj_prod.f_partpolriesgos (tmpdpoliza, mensajes);

         IF ries IS NOT NULL
         THEN
            IF ries.COUNT > 0
            THEN
               FOR v_ries IN ries.FIRST .. ries.LAST
               LOOP
                  IF ries.EXISTS (v_ries)
                  THEN
                     IF ries (v_ries).riespersonal IS NOT NULL
                     THEN
                        IF ries (v_ries).riespersonal.COUNT > 0
                        THEN
                           FOR v_riesperson IN
                              ries (v_ries).riespersonal.FIRST .. ries
                                                                      (v_ries).riespersonal.LAST
                           LOOP
                              IF ries (v_riesperson).riespersonal.EXISTS
                                                                (v_riesperson)
                              THEN
                                 w_edad :=
                                    fedadaseg
                                       (NULL,
                                        ries (v_ries).riespersonal
                                                                 (v_riesperson).sperson,
                                        TO_CHAR (f_sysdate, 'yyyymmdd'),
                                        2,
                                        1
                                       );

                                 IF     w_edad IS NOT NULL
                                    AND w_edad NOT IN (-1, -2)
                                    AND w_edad >= 12
                                 THEN
                                    v_num_aseg_mayor_12 :=
                                                      v_num_aseg_mayor_12 + 1;
                                 END IF;
                              END IF;
                           END LOOP;
                        END IF;
                     END IF;
                  END IF;
               END LOOP;
            END IF;
         END IF;
      ELSE
         FOR aseg IN (SELECT DISTINCT r.sperson, r.nriesgo, r.fefecto
                                 FROM asegurados e, riesgos r
                                WHERE e.sseguro = psseguro
                                  AND e.sseguro = r.sseguro
                                  AND e.sperson = r.sperson)
         LOOP
            v_edad_ries :=
               f_edad_riesgo (ptablas,
                              psseguro,
                              aseg.nriesgo,
                              aseg.fefecto,
                              NULL,
                              NULL,
                              NULL,
                              NULL,
                              NULL
                             );

            IF NVL (v_edad_ries, 22222) <> 22222 AND v_edad_ries >= 12
            THEN
               v_num_aseg_mayor_12 := v_num_aseg_mayor_12 + 1;
            END IF;
         END LOOP;
      END IF;

      RETURN v_num_aseg_mayor_12;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_propio_albsgt_conf.f_num_aseg_mayor_12',
                      ntraza,
                         ' - ptablas  '
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
                      SQLERRM
                     );
         RETURN NULL;
   END f_num_aseg_mayor_12;

   FUNCTION f_num_aseg_menor_12 (
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
      v_edad_ries           NUMBER;
      v_num_aseg_menor_12   NUMBER           := 0;
      ntraza                NUMBER;
      tmpdpoliza            ob_iax_detpoliza := NULL;
      ries                  t_iax_riesgos;                /* ob_iax_riesgos*/
      mensajes              t_iax_mensajes;
      w_edad                NUMBER;
   BEGIN
      IF ptablas = 'EST'
      THEN
         /*
            FOR aseg IN (SELECT DISTINCT r.sperson, r.nriesgo, r.fefecto
                                    FROM estassegurats e, estriesgos r
                                   WHERE e.sseguro = psseguro
                                     AND e.sseguro = r.sseguro
                                     AND e.sperson = r.sperson) LOOP
               v_edad_ries := f_edad_riesgo(ptablas, psseguro, aseg.nriesgo, aseg.fefecto, NULL,
                                            NULL, NULL, NULL, NULL);

               IF NVL(v_edad_ries, 22222) <> 22222
                  AND v_edad_ries < 12 THEN
                  v_num_aseg_menor_12 := v_num_aseg_menor_12 + 1;
               END IF;
            END LOOP;
         */
         tmpdpoliza := pac_iobj_prod.f_getpoliza (mensajes);
         ries := pac_iobj_prod.f_partpolriesgos (tmpdpoliza, mensajes);

         IF ries IS NOT NULL
         THEN
            IF ries.COUNT > 0
            THEN
               FOR v_ries IN ries.FIRST .. ries.LAST
               LOOP
                  IF ries.EXISTS (v_ries)
                  THEN
                     IF ries (v_ries).riespersonal IS NOT NULL
                     THEN
                        IF ries (v_ries).riespersonal.COUNT > 0
                        THEN
                           FOR v_riesperson IN
                              ries (v_ries).riespersonal.FIRST .. ries
                                                                      (v_ries).riespersonal.LAST
                           LOOP
                              IF ries (v_riesperson).riespersonal.EXISTS
                                                                (v_riesperson)
                              THEN
                                 w_edad :=
                                    fedadaseg
                                       (NULL,
                                        ries (v_ries).riespersonal
                                                                 (v_riesperson).sperson,
                                        TO_CHAR (f_sysdate, 'yyyymmdd'),
                                        2,
                                        1
                                       );

                                 IF     w_edad IS NOT NULL
                                    AND w_edad NOT IN (-1, -2)
                                    AND w_edad < 12
                                 THEN
                                    v_num_aseg_menor_12 :=
                                                      v_num_aseg_menor_12 + 1;
                                 END IF;
                              END IF;
                           END LOOP;
                        END IF;
                     END IF;
                  END IF;
               END LOOP;
            END IF;
         END IF;
      ELSE
         FOR aseg IN (SELECT DISTINCT r.sperson, r.nriesgo, r.fefecto
                                 FROM asegurados e, riesgos r
                                WHERE e.sseguro = psseguro
                                  AND e.sseguro = r.sseguro
                                  AND e.sperson = r.sperson)
         LOOP
            v_edad_ries :=
               f_edad_riesgo (ptablas,
                              psseguro,
                              aseg.nriesgo,
                              aseg.fefecto,
                              NULL,
                              NULL,
                              NULL,
                              NULL,
                              NULL
                             );

            IF NVL (v_edad_ries, 22222) <> 22222 AND v_edad_ries < 12
            THEN
               v_num_aseg_menor_12 := v_num_aseg_menor_12 + 1;
            END IF;
         END LOOP;
      END IF;

      RETURN v_num_aseg_menor_12;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_propio_albsgt_conf.f_num_aseg_menor_12',
                      ntraza,
                         ' - ptablas  '
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
                      SQLERRM
                     );
         RETURN NULL;
   END f_num_aseg_menor_12;

   /* FI BUG 22781/0121275 - FAL - 28/08/2012*/
   /* BUG 22843/0121278 - FAL - 30/08/2012*/
   FUNCTION f_arrastra_pregunta_plan (
      ptablas     IN   VARCHAR2,
      psseguro    IN   NUMBER,
      pnriesgo    IN   NUMBER,
      pfefecto    IN   DATE,
      pnmovimi    IN   NUMBER,
      pcgarant    IN   NUMBER,
      psproces    IN   NUMBER,
      pnmovima    IN   NUMBER,
      picapital   IN   NUMBER,
      pcpregun    IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      w_resp_4089     pregunpolseg.crespue%TYPE;
      v_crespue       estpregunpolseg.crespue%TYPE;
      v_npoliza       estseguros.npoliza%TYPE;
      numerr          NUMBER;
      ntraza          NUMBER;
      v_crespue4783   pregunpolseg.crespue%TYPE;
      visaltacol      BOOLEAN                        := FALSE;
      v_ncertif       NUMBER;
   BEGIN
      IF pac_iax_produccion.isaltacol
      THEN
         visaltacol := TRUE;
      ELSE
         BEGIN
            IF ptablas = 'EST'
            THEN
               SELECT npoliza, ncertif
                 INTO v_npoliza, v_ncertif
                 FROM estseguros
                WHERE sseguro = psseguro;
            ELSE
               SELECT npoliza, ncertif
                 INTO v_npoliza, v_ncertif
                 FROM seguros
                WHERE sseguro = psseguro;
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               NULL;
         END;

         IF v_ncertif = 0
         THEN
            visaltacol := TRUE;
         END IF;
      END IF;

      BEGIN
         IF ptablas = 'EST'
         THEN
            SELECT npoliza
              INTO v_npoliza
              FROM estseguros
             WHERE sseguro = psseguro;
         ELSE
            SELECT npoliza
              INTO v_npoliza
              FROM seguros
             WHERE sseguro = psseguro;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            v_npoliza := pac_iax_produccion.poliza.det_poliza.npoliza;
      END;

      numerr :=
         pac_preguntas.f_get_pregunpolseg (psseguro,
                                           4089,
                                           NVL (ptablas, 'SEG'),
                                           w_resp_4089
                                          );

      /* Bug 22839 - RSC - 03/10/2012 - LCOL_T010-LCOL - Funcionalidad Certificado 0*/
      IF numerr = 120135
      THEN
         w_resp_4089 := 1;
      END IF;

      IF visaltacol
      THEN
         v_crespue := NULL;
      ELSE
         v_crespue :=
            f_arrastra_pregunta (NVL (ptablas, 'SEG'),
                                 psseguro,
                                 pnriesgo,
                                 pfefecto,
                                 pnmovimi,
                                 pcgarant,
                                 psproces,
                                 pnmovima,
                                 picapital,
                                 v_npoliza,
                                 pcpregun,
                                 w_resp_4089
                                );
      END IF;

      RETURN v_crespue;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_propio_albsgt_conf.f_arrastra_pregunta_plan',
                      ntraza,
                         ' - ptablas  '
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
                      SQLERRM
                     );
         RETURN NULL;
   END f_arrastra_pregunta_plan;

   /*- m. r.b. Parametrització 6031 16/01/2013*/
   FUNCTION f_smmlv (
      ptablas     IN   VARCHAR2,
      psseguro    IN   NUMBER,
      pnriesgo    IN   NUMBER,
      pfefecto    IN   DATE,
      pnmovimi    IN   NUMBER,
      pcgarant    IN   NUMBER,
      psproces    IN   NUMBER,
      pnmovima    IN   NUMBER,
      picapital   IN   NUMBER,
      pcmonori    IN   VARCHAR2 DEFAULT 'SMV',
      pcmondes    IN   VARCHAR2 DEFAULT 'COP',
      pcpregun    IN   NUMBER DEFAULT 4823
   )
      RETURN NUMBER
   IS
      v_cmondes   VARCHAR2 (3);
      v_sproduc   NUMBER;
      v_itasa     NUMBER;
      v_trespue   VARCHAR2 (10);
      num_err     NUMBER;
   BEGIN
      IF ptablas = 'EST'
      THEN
         SELECT sproduc
           INTO v_sproduc
           FROM estseguros s
          WHERE s.sseguro = psseguro;
      ELSE
         SELECT sproduc
           INTO v_sproduc
           FROM seguros s
          WHERE s.sseguro = psseguro;
      END IF;

      v_cmondes := pac_monedas.f_moneda_producto_char (v_sproduc);

      IF v_trespue IS NULL
      THEN
         num_err :=
            pac_preguntas.f_get_pregungaranseg (psseguro,
                                                pcgarant,
                                                pnriesgo,
                                                pcpregun,
                                                ptablas,
                                                v_trespue
                                               );
      END IF;

      IF v_trespue IS NULL
      THEN
         v_trespue :=
            TO_CHAR (pac_eco_tipocambio.f_fecha_max_cambio (pcmonori,
                                                            v_cmondes,
                                                            pfefecto
                                                           ),
                     'YYYYMMDD'
                    );
      END IF;

      v_itasa :=
         pac_eco_tipocambio.f_cambio (pcmonori,
                                      pcmondes,
                                      TO_DATE (v_trespue, 'YYYYMMDD')
                                     );
      RETURN v_itasa;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_propio_albsgt_conf.f_smmlv',
                      1,
                         'ptablas = '
                      || ptablas
                      || ' psseguro = '
                      || psseguro
                      || ' pnriesgo = '
                      || pnriesgo
                      || ' pfefecto = '
                      || pfefecto
                      || ' pnmovimi = '
                      || pnmovimi
                      || ' pcgarant = '
                      || pcgarant
                      || ' psproces = '
                      || psproces
                      || ' pnmovima = '
                      || pnmovima
                      || ' picapital = '
                      || picapital,
                      SQLERRM
                     );
         RETURN NULL;
   END f_smmlv;

   FUNCTION ftaxeda (
      psession   IN   NUMBER,
      psseguro   IN   NUMBER,
      pnriesgo   IN   NUMBER,
      pnmovimi   IN   NUMBER,
      pcgarant   IN   NUMBER,
      pcpregun   IN   NUMBER,
      pccolumn   IN   NUMBER,
      pedad      IN   NUMBER,
      porigen    IN   NUMBER DEFAULT 1
   )
      RETURN NUMBER
   IS
      /**/
      num_err     NUMBER;
      v_taxa      NUMBER;
      v_sep_ori   VARCHAR2 (1);
      v_sep_dtn   VARCHAR2 (1);
   BEGIN
      /*IF NVL(pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa(),
                                           'SISTEMA_NUMERICO_BD'),
             ',.') = '.,' THEN
         v_sep_ori := ',';
         v_sep_dtn := '.';
      ELSE
         v_sep_ori := '.';
         v_sep_dtn := ',';
      END IF;*/
      IF porigen = 1
      THEN
         SELECT nvalor    /*TO_NUMBER(REPLACE(tvalor, v_sep_ori, v_sep_dtn))*/
           INTO v_taxa
           FROM estpregungaransegtab
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND nmovimi = pnmovimi
            AND cgarant = pcgarant
            AND cpregun = pcpregun
            AND ccolumna = pccolumn
            AND nlinea =
                   (SELECT MAX (nlinea)
                      FROM estpregungaransegtab
                     WHERE sseguro = psseguro
                       AND nriesgo = pnriesgo
                       AND nmovimi = pnmovimi
                       AND cgarant = pcgarant
                       AND cpregun = pcpregun
                       AND pedad >= nvalor
                       AND ccolumna = 1)
            AND nlinea =
                   (SELECT MIN (nlinea)
                      FROM estpregungaransegtab
                     WHERE sseguro = psseguro
                       AND nriesgo = pnriesgo
                       AND nmovimi = pnmovimi
                       AND cgarant = pcgarant
                       AND cpregun = pcpregun
                       AND pedad <= nvalor
                       AND ccolumna = 2);
      ELSE
         SELECT nvalor   /* TO_NUMBER(REPLACE(tvalor, v_sep_ori, v_sep_dtn))*/
           INTO v_taxa
           FROM pregungaransegtab
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND nmovimi =
                   (SELECT MAX (nmovimi)
                      FROM pregungaransegtab
                     WHERE sseguro = psseguro
                       AND nriesgo = pnriesgo
                       AND cgarant = pcgarant
                       AND cpregun = pcpregun)
            AND cgarant = pcgarant
            AND cpregun = pcpregun
            AND ccolumna = pccolumn
            AND nlinea =
                   (SELECT MAX (nlinea)
                      FROM pregungaransegtab
                     WHERE sseguro = psseguro
                       AND nriesgo = pnriesgo
                       AND nmovimi =
                              (SELECT MAX (nmovimi)
                                 FROM pregungaransegtab
                                WHERE sseguro = psseguro
                                  AND nriesgo = pnriesgo
                                  AND cgarant = pcgarant
                                  AND cpregun = pcpregun)
                       AND cgarant = pcgarant
                       AND cpregun = pcpregun
                       AND pedad >= nvalor
                       AND ccolumna = 1)
            AND nlinea =
                   (SELECT MIN (nlinea)
                      FROM pregungaransegtab
                     WHERE sseguro = psseguro
                       AND nriesgo = pnriesgo
                       AND nmovimi =
                              (SELECT MAX (nmovimi)
                                 FROM pregungaransegtab
                                WHERE sseguro = psseguro
                                  AND nriesgo = pnriesgo
                                  AND cgarant = pcgarant
                                  AND cpregun = pcpregun)
                       AND cgarant = pcgarant
                       AND cpregun = pcpregun
                       AND pedad <= nvalor
                       AND ccolumna = 2);
      END IF;

      RETURN v_taxa;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN NULL;
   END ftaxeda;

   FUNCTION f_arrastra_tasa (
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
      w_edad        NUMBER;
      /*origen        number;*/
      wsseguro      seguros.sseguro%TYPE;
      w_tasa_edad   NUMBER;
      numerr        NUMBER;
      w_resp_4089   pregunpolseg.crespue%TYPE;

      /* BUG 29553_0162538 - JLTS - 04/01/2014 - Inicio*/
      FUNCTION ftaxeda_alternativo (
         pedad      NUMBER,
         psseguro   NUMBER,
         pnriesgo   NUMBER,
         pngarant   NUMBER,
         pcpregun   NUMBER
      )
         RETURN NUMBER
      IS
         v_columna1    NUMBER;
         v_columna2    NUMBER;
         v_columna3    NUMBER;
         /*         pedad          NUMBER := 71;*/
         /*         psseguro       NUMBER := 28731;*/
         /*         pnriesgo       NUMBER := 1;*/
         /*         pcgarant       NUMBER := 6901;*/
         /*         pcpregun       NUMBER := 4091;*/
         v_resultado   NUMBER;
      BEGIN
         FOR regs IN (SELECT DISTINCT nlinea
                                 FROM pregungaransegtab
                                WHERE sseguro = psseguro
                                  AND nriesgo = pnriesgo
                                  AND nmovimi =
                                         (SELECT MAX (nmovimi)
                                            FROM pregungaransegtab
                                           WHERE sseguro = psseguro
                                             AND nriesgo = pnriesgo
                                             AND cgarant = pcgarant
                                             AND cpregun = pcpregun)
                                  AND cgarant = pcgarant
                                  AND cpregun = pcpregun
                             ORDER BY nlinea)
         LOOP
            SELECT (SELECT nvalor
                      FROM pregungaransegtab
                     WHERE sseguro = psseguro
                       AND nriesgo = pnriesgo
                       AND nmovimi =
                              (SELECT MAX (nmovimi)
                                 FROM pregungaransegtab
                                WHERE sseguro = psseguro
                                  AND nriesgo = pnriesgo
                                  AND cgarant = pcgarant
                                  AND cpregun = pcpregun)
                       AND cgarant = pcgarant
                       AND cpregun = pcpregun
                       AND nlinea = regs.nlinea
                       AND ccolumna = 1) columna1,
                   (SELECT nvalor
                      FROM pregungaransegtab
                     WHERE sseguro = psseguro
                       AND nriesgo = pnriesgo
                       AND nmovimi =
                              (SELECT MAX (nmovimi)
                                 FROM pregungaransegtab
                                WHERE sseguro = psseguro
                                  AND nriesgo = pnriesgo
                                  AND cgarant = pcgarant
                                  AND cpregun = pcpregun)
                       AND cgarant = pcgarant
                       AND cpregun = pcpregun
                       AND nlinea = regs.nlinea
                       AND ccolumna = 2) columna2,
                   (SELECT nvalor
                      FROM pregungaransegtab
                     WHERE sseguro = psseguro
                       AND nriesgo = pnriesgo
                       AND nmovimi =
                              (SELECT MAX (nmovimi)
                                 FROM pregungaransegtab
                                WHERE sseguro = psseguro
                                  AND nriesgo = pnriesgo
                                  AND cgarant = pcgarant
                                  AND cpregun = pcpregun)
                       AND cgarant = pcgarant
                       AND cpregun = pcpregun
                       AND nlinea = regs.nlinea
                       AND ccolumna = 3) columna3
              INTO v_columna1,
                   v_columna2,
                   v_columna3
              FROM DUAL;

            IF pedad >= v_columna1 AND pedad <= v_columna2
            THEN
               v_resultado := v_columna3;
            END IF;
         END LOOP;

         RETURN v_resultado;
      END ftaxeda_alternativo;
   /* BUG 29553_0162538 - JLTS - 04/01/2014 - Fin*/
   BEGIN
      w_edad :=
         f_edad_riesgo (NVL (ptablas, 'SEG'),
                        psseguro,
                        pnriesgo,
                        pfefecto,
                        pnmovimi,
                        pcgarant,
                        psproces,
                        pnmovima,
                        picapital
                       );

      BEGIN
         IF ptablas = 'EST'
         THEN
            SELECT sseguro
              INTO wsseguro
              FROM seguros
             WHERE npoliza = (SELECT npoliza
                                FROM estseguros
                               WHERE sseguro = psseguro) AND ncertif = 0;
         ELSE
            SELECT sseguro
              INTO wsseguro
              FROM seguros
             WHERE npoliza = (SELECT npoliza
                                FROM seguros
                               WHERE sseguro = psseguro) AND ncertif = 0;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            SELECT sseguro
              INTO wsseguro
              FROM seguros
             WHERE npoliza = pac_iax_produccion.poliza.det_poliza.npoliza
               AND ncertif = 0;
      END;

      numerr :=
         pac_preguntas.f_get_pregunpolseg (psseguro,
                                           4089,
                                           NVL (ptablas, 'SEG'),
                                           w_resp_4089
                                          );

      IF numerr = 120135
      THEN
         w_resp_4089 := 1;
      END IF;

      /* BUG 29553_0162538 - JLTS - 04/01/2014 - Ini*/
      /*w_tasa_edad := ftaxeda(NULL, wsseguro, w_resp_4089, pnmovimi, pcgarant, 4091, 3, w_edad,*/
      /*                       2);*/
      w_tasa_edad :=
           ftaxeda_alternativo (w_edad, wsseguro, w_resp_4089, pcgarant, 4091);
      /* BUG 29553_0162538 - JLTS - 04/01/2014 - fin*/
      RETURN w_tasa_edad;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_propio_albsgt_conf.f_arrastra_tasa',
                      1,
                         'ptablas = '
                      || ptablas
                      || ' psseguro = '
                      || psseguro
                      || ' pnriesgo = '
                      || pnriesgo
                      || ' pfefecto = '
                      || pfefecto
                      || ' pnmovimi = '
                      || pnmovimi
                      || ' pcgarant = '
                      || pcgarant
                      || ' psproces = '
                      || psproces
                      || ' pnmovima = '
                      || pnmovima
                      || ' picapital = '
                      || picapital,
                      SQLERRM
                     );
         RETURN NULL;
   END f_arrastra_tasa;

   FUNCTION f_respue_si_contributivo (
      ptablas     IN   VARCHAR2,
      psseguro    IN   NUMBER,
      pnriesgo    IN   NUMBER,
      pfefecto    IN   DATE,
      pnmovimi    IN   NUMBER,
      pcgarant    IN   NUMBER,
      psproces    IN   NUMBER,
      pnmovima    IN   NUMBER,
      picapital   IN   NUMBER,
      pcpregun    IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      vsproduc    productos.sproduc%TYPE;
      w_valpar    parproductos.cvalpar%TYPE;
      v_cobjase   seguros.cobjase%TYPE;
   BEGIN
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

      SELECT cobjase
        INTO v_cobjase
        FROM productos
       WHERE sproduc = vsproduc;

      IF NVL (f_parproductos_v (vsproduc, 'CONTRIB_NO_CONTRIB'), 0) IN (1, 3)
      THEN
         w_valpar := 1;
      ELSE
         w_valpar := 0;
      END IF;

      /*BUG 27539/149362 - INICIO - DCT - 18/09/2013*/
      IF pcpregun = 9008 AND v_cobjase IN (3, 4)
      THEN
         w_valpar := 1;
      END IF;

      /*BUG 27539/149362 - FIN - DCT - 18/09/2013*/
      IF pcpregun = 535 AND w_valpar = 1
      THEN
         RETURN 100;
      ELSIF pcpregun = 535 AND w_valpar = 0
      THEN
         RETURN 0;
      ELSIF pcpregun = 4794 AND w_valpar = 1
      THEN
         RETURN 1;
      ELSIF pcpregun = 4794 AND w_valpar = 0
      THEN
         RETURN 0;
      ELSIF pcpregun = 4790 AND w_valpar = 1
      THEN
         RETURN 1;
      ELSIF pcpregun = 4790 AND w_valpar = 0
      THEN
         RETURN 2;
      ELSIF pcpregun = 4078 AND w_valpar = 1
      THEN
         RETURN 2;
      ELSIF pcpregun = 4078 AND w_valpar = 0
      THEN
         RETURN 1;
      ELSIF pcpregun = 4092 AND w_valpar = 1
      THEN
         RETURN 1;
      ELSIF pcpregun = 4092 AND w_valpar = 0
      THEN
         RETURN 2;
      /* BUG 22843/0123300 - FAL - 17/9/2012*/
      ELSIF pcpregun = 4002 AND w_valpar = 1
      THEN
         RETURN 1;
      /* FI BUG 22843/0123300*/
      ELSIF pcpregun = 4002 AND w_valpar = 0
      THEN
         RETURN 2;
      /* Bug 27420/147232 - 21/06/2013 - AMC*/
      ELSIF pcpregun = 9008 AND w_valpar = 1
      THEN
         RETURN 2;
      ELSIF pcpregun = 9008 AND w_valpar = 0
      THEN
         RETURN 1;
      /* Fi Bug 27420/147232 - 21/06/2013 - AMC*/
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_propio_albsgt_conf.f_respue_si_contributivo',
                      1,
                         'ptablas = '
                      || ptablas
                      || ' psseguro = '
                      || psseguro
                      || ' pnriesgo = '
                      || pnriesgo
                      || ' pfefecto = '
                      || pfefecto
                      || ' pnmovimi = '
                      || pnmovimi
                      || ' pcgarant = '
                      || pcgarant
                      || ' psproces = '
                      || psproces
                      || ' pnmovima = '
                      || pnmovima
                      || ' picapital = '
                      || picapital,
                      SQLERRM
                     );
         RETURN NULL;
   END f_respue_si_contributivo;

   /* FI BUG 22843/0121278 - FAL - 30/08/2012*/
   FUNCTION f_sucursal_user (
      ptablas     IN   VARCHAR2,
      psseguro    IN   NUMBER,
      pnriesgo    IN   NUMBER,
      pfefecto    IN   DATE,
      pnmovimi    IN   NUMBER,
      pcgarant    IN   NUMBER,
      psproces    IN   NUMBER,
      pnmovima    IN   NUMBER,
      picapital   IN   NUMBER,
      pnpoliza    IN   NUMBER
   )
      RETURN NUMBER
   IS
      v_cagente   NUMBER;
      ntraza      NUMBER;
   BEGIN
      ntraza := 1;

      SELECT     cagente
            INTO v_cagente
            FROM redcomercial
           WHERE ctipage = 2 AND ROWNUM = 1
      START WITH cagente = pac_user.ff_get_cagente (f_user)
      CONNECT BY PRIOR cpadre = cagente;

      ntraza := 2;
      RETURN v_cagente;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_propio_albsgt_conf.f_sucursal_user',
                      ntraza,
                         ' - ptablas  '
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
                      || picapital
                      || ' - pnpoliza '
                      || pnpoliza,
                      SQLERRM
                     );
         RETURN NULL;
   END f_sucursal_user;

   FUNCTION f_porcen_pu (
      ptablas     IN   VARCHAR2,
      psseguro    IN   NUMBER,
      pnriesgo    IN   NUMBER,
      pfefecto    IN   DATE,
      pnmovimi    IN   NUMBER,
      pcgarant    IN   NUMBER,
      psproces    IN   NUMBER,
      pnmovima    IN   NUMBER,
      picapital   IN   NUMBER,
      pcpregun    IN   NUMBER
   )
      RETURN NUMBER
   IS
      /**/
      v_crespue   estpregunpolseg.crespue%TYPE;
      num_err     NUMBER;
   BEGIN
      num_err :=
         pac_preguntas.f_get_pregunpolseg (psseguro,
                                           pcpregun,
                                           NVL (ptablas, 'SEG'),
                                           v_crespue
                                          );

      IF NVL (v_crespue, 0) > 0
      THEN
         RETURN 1;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_propio_albsgt_conf.f_porcen_pu',
                      1,
                         'ptablas = '
                      || ptablas
                      || ' psseguro = '
                      || psseguro
                      || ' pnriesgo = '
                      || pnriesgo
                      || ' pfefecto = '
                      || pfefecto
                      || ' pnmovimi = '
                      || pnmovimi
                      || ' pcgarant = '
                      || pcgarant
                      || ' psproces = '
                      || psproces
                      || ' pnmovima = '
                      || pnmovima
                      || ' picapital = '
                      || picapital,
                      SQLERRM
                     );
         RETURN NULL;
   END f_porcen_pu;

   FUNCTION ftsmmlv (
      psession   IN   NUMBER,
      psseguro   IN   NUMBER,
      pnriesgo   IN   NUMBER,
      pcgarant   IN   NUMBER,
      pmonori    IN   VARCHAR2,
      pmondtn    IN   VARCHAR2,
      pfefecto   IN   NUMBER,
      porigen    IN   NUMBER DEFAULT 1
   )
      RETURN NUMBER
   IS
      v_itasa     NUMBER;
      v_trespue   NUMBER;
      v_tablas    VARCHAR2 (3);
      num_err     NUMBER;
   BEGIN
      v_tablas := 'TMP';
      num_err :=
         pac_preguntas.f_get_pregungaranseg (psseguro,
                                             pcgarant,
                                             pnriesgo,
                                             4823,
                                             v_tablas,
                                             v_trespue
                                            );

      IF v_trespue IS NULL
      THEN
         IF porigen = 1
         THEN
            v_tablas := 'EST';
         ELSE
            v_tablas := 'SEG';
         END IF;

         num_err :=
            pac_preguntas.f_get_pregungaranseg (psseguro,
                                                pcgarant,
                                                pnriesgo,
                                                4823,
                                                v_tablas,
                                                v_trespue
                                               );

         IF v_trespue IS NULL
         THEN
            v_trespue := pfefecto;
         END IF;
      END IF;

      v_itasa :=
         pac_eco_tipocambio.f_cambio
                   (pmonori,
                    pmondtn,
                    pac_eco_tipocambio.f_fecha_max_cambio (pmonori,
                                                           pmondtn,
                                                           TO_DATE (v_trespue,
                                                                    'YYYYMMDD'
                                                                   )
                                                          )
                   );
      RETURN v_itasa;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_propio_albsgt_conf.ftsmmlv',
                      1,
                         'pmonori = '
                      || pmonori
                      || ' pmondtn = '
                      || pmondtn
                      || ' pfefecto = '
                      || pfefecto,
                      SQLERRM
                     );
         RETURN NULL;
   END ftsmmlv;

   /* BUG 22843/123300 - FAL - 17/09/2012*/
   FUNCTION f_cartera (
      ptablas     IN   VARCHAR2,
      psseguro    IN   NUMBER,
      pnriesgo    IN   NUMBER,
      pfefecto    IN   DATE,
      pnmovimi    IN   NUMBER,
      cgarant     IN   NUMBER,
      psproces    IN   NUMBER,
      pnmovima    IN   NUMBER,
      picapital   IN   NUMBER
   )
      RETURN NUMBER
   IS
   BEGIN
      RETURN 1;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_propio_albsgt_conf.f_cartera',
                      1,
                         'ptablas = '
                      || ptablas
                      || ' psseguro = '
                      || psseguro
                      || ' pfefecto = '
                      || pfefecto,
                      SQLERRM
                     );
         RETURN NULL;
   END f_cartera;

   /* FI BUG 22843/123300*/
   /* Bug 0023130 - DCG - 25/09/2012 - LCOL_F002-Provisiones para polizas estatales*/
   /* BUG 24657 - MDS - 23/11/2012
      FUNCTION f_registro_pres(
         ptablas IN VARCHAR2,
         pcactivi IN NUMBER,
         psseguro IN NUMBER,
         pnmovimi IN NUMBER)
         RETURN NUMBER IS
         --
         num_err        NUMBER;
         v_valor        NUMBER := 0;
         v_resp_4820    estpregunseg.crespue%TYPE;
      BEGIN
         num_err := pac_preguntas.f_get_pregunpolseg(psseguro, 4820, ptablas, v_resp_4820);

         IF v_resp_4820 = 1 THEN
            v_valor := 1;
         END IF;

         RETURN v_valor;
      END f_registro_pres;
   */
   /* Fin Bug 0023130*/
   FUNCTION f_arrastra_capital (
      ptablas     IN   VARCHAR2,
      psseguro    IN   NUMBER,
      pnriesgo    IN   NUMBER,
      pfefecto    IN   DATE,
      pnmovimi    IN   NUMBER,
      pcgarant    IN   NUMBER,
      psproces    IN   NUMBER,
      pnmovima    IN   NUMBER,
      picapital   IN   NUMBER,
      pcpregun    IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      w_resp_4089      pregunpolseg.crespue%TYPE;
      v_crespue        estpregunpolseg.crespue%TYPE;
      v_npoliza        estseguros.npoliza%TYPE;
      numerr           NUMBER;
      ntraza           NUMBER;
      v_crespue4783    pregunpolseg.crespue%TYPE;
      v_sproduc        productos.sproduc%TYPE;
      v_cgardep        garanpro.cgardep%TYPE;
      v_pcapdep        garanpro.pcapdep%TYPE;
      v_ctipcap        garanpro.ctipcap%TYPE;
      v_crespue_4081   pregungaranseg.crespue%TYPE;
      v_icapmax        garanpro.icapmax%TYPE;
      visaltacol       BOOLEAN                        := FALSE;
      v_ncertif        NUMBER;
      vresp4816        pregunpolseg.crespue%TYPE;
      v_crespue_4085   pregungaranseg.crespue%TYPE;
      v_crespue_4965   pregungaranseg.crespue%TYPE;
      /* INI BUG 18205 - 27/05/2015 - CAM - Se incluye nueva variable para deducir el numero de pregunta que se debe arrastrar al Cert Individual*/
      v_arrastra_pre   preguntas.cpregun%TYPE;
   /* FIN BUG 18205 - 27/05/2015 - CAM*/
   BEGIN
      IF pac_iax_produccion.isaltacol
      THEN
         visaltacol := TRUE;
      ELSE
         BEGIN
            IF ptablas = 'EST'
            THEN
               SELECT npoliza, ncertif
                 INTO v_npoliza, v_ncertif
                 FROM estseguros
                WHERE sseguro = psseguro;
            ELSE
               SELECT npoliza, ncertif
                 INTO v_npoliza, v_ncertif
                 FROM seguros
                WHERE sseguro = psseguro;
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               NULL;
         END;

         IF v_ncertif = 0
         THEN
            visaltacol := TRUE;
         END IF;
      END IF;

      BEGIN
         IF ptablas = 'EST'
         THEN
            SELECT npoliza, sproduc
              INTO v_npoliza, v_sproduc
              FROM estseguros
             WHERE sseguro = psseguro;
         ELSE
            SELECT npoliza, sproduc
              INTO v_npoliza, v_sproduc
              FROM seguros
             WHERE sseguro = psseguro;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            v_npoliza := pac_iax_produccion.poliza.det_poliza.npoliza;
      END;

      /*Pregunta Tipo de negocio*/
      IF ptablas = 'EST'
      THEN
         BEGIN
            SELECT e.crespue
              INTO vresp4816
              FROM estpregunpolseg e
             WHERE e.sseguro = psseguro
               AND e.nmovimi = pnmovimi
               AND e.cpregun = 4816;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               vresp4816 := NULL;
         END;
      ELSE
         BEGIN
            SELECT e.crespue
              INTO vresp4816
              FROM pregunpolseg e
             WHERE e.sseguro = psseguro
               AND e.nmovimi = pnmovimi
               AND e.cpregun = 4816;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               vresp4816 := NULL;
         END;
      END IF;

      /*Pregunta tipo de valor asegurado*/
      numerr :=
         pac_preguntas.f_get_pregunpolseg (psseguro,
                                           4783,
                                           NVL (ptablas, 'SEG'),
                                           v_crespue4783
                                          );
      /*Si respuesta de tipo valor asegurado es Valor Informado obtenemos el valor asegurado fijo (Puede estar informado o no)*/
      /*      IF v_crespue4783 = 5 THEN*/
      /*         numerr := pac_preguntas.f_get_pregunpolseg(psseguro, 4965, NVL(ptablas, 'SEG'),*/
      /*                                                    v_crespue_4965);*/
      /*         IF numerr <> 0 THEN*/
      /*            v_crespue_4965 := NULL;*/
      /*         END IF;*/
      /*      END IF;*/
      /*Pregunta Plan del colectivo*/
      numerr :=
         pac_preguntas.f_get_pregunpolseg (psseguro,
                                           4089,
                                           NVL (ptablas, 'SEG'),
                                           w_resp_4089
                                          );

      /* Bug 22839 - RSC - 03/10/2012 - LCOL_T010-LCOL - Funcionalidad Certificado 0*/
      IF numerr = 120135
      THEN
         w_resp_4089 := 1;
      END IF;

      /* INI BUG 18205 - 27/05/2015 - CAM - Se deduce el numero de pregunta que se debe arrastrar al Cert Individual con el tipo de valor asegurado*/
      IF v_crespue4783 = 4
      THEN
         v_arrastra_pre := 4081;
      ELSE
         v_arrastra_pre := 4965;
      END IF;

      /* FIN BUG 18205 - 27/05/2015 - CAM*/
      IF visaltacol
      THEN
         v_crespue := NULL;
      ELSE
         /* INI BUG 18205 - 27/05/2015 - CAM - Se envia como parametro v_arrastra_pre que es el numero de pregunta que se va a arrastrar al certificado individual*/
         v_crespue :=
            f_arrastra_pregunta (NVL (ptablas, 'SEG'),
                                 psseguro,
                                 pnriesgo,
                                 pfefecto,
                                 pnmovimi,
                                 pcgarant,
                                 psproces,
                                 pnmovima,
                                 picapital,
                                 v_npoliza,
                                 v_arrastra_pre,
                                 w_resp_4089
                                );
      /* FIN BUG 18205 - 27/05/2015 - CAM*/
      END IF;

      IF    visaltacol
         OR (v_sproduc IN (6024, 6027) AND vresp4816 = 7)
         OR (NOT visaltacol AND v_crespue4783 = 5 AND v_crespue IS NULL)
      THEN      /* alta de colectivo || colectivo vida y tipo negocio = Vida*/
         SELECT cgardep, pcapdep, ctipcap, icapmax
           INTO v_cgardep, v_pcapdep, v_ctipcap, v_icapmax
           FROM garanpro
          WHERE sproduc = v_sproduc AND cgarant = pcgarant;

         IF v_cgardep IS NOT NULL AND v_pcapdep = -999
         THEN
            RETURN v_icapmax;
         ELSE
            IF v_cgardep IS NOT NULL
            THEN
               /*En caso de ser Valor informado, obtengo el valor de Valor asegurado fijo, si no hay null*/
                 /* -- INI BUG 18205 - 27/05/2015 - CAM - Si el tipo de valor asegurado es diferente de Planes, se debe usar
                  Valor asegurado fijo, adicionalmente se estaba consultando pregungarancar cuando el parametro de tablas
                 era igual a EST lo cual es incorrecto, se cambio por la tabla estpregungaranseg */
               IF v_crespue4783 <> 4
               THEN
                  IF ptablas = 'EST'
                  THEN
                     BEGIN
                        SELECT crespue
                          INTO v_crespue_4965
                          FROM estpregungaranseg
                         /*FROM pregungarancar*/
                        WHERE  sseguro = psseguro
                           AND cpregun = 4965
                           AND cgarant = v_cgardep
                           AND nmovimi = pnmovimi
                           AND nriesgo = pnriesgo;
                     EXCEPTION
                        WHEN NO_DATA_FOUND
                        THEN
                           v_crespue_4965 := NULL;
                     END;
                  ELSE
                     BEGIN
                        SELECT crespue
                          INTO v_crespue_4965
                          FROM pregungaranseg
                         WHERE sseguro = psseguro
                           AND cpregun = 4965
                           AND cgarant = v_cgardep
                           AND nmovimi = pnmovimi
                           AND nriesgo = pnriesgo;
                     EXCEPTION
                        WHEN NO_DATA_FOUND
                        THEN
                           v_crespue_4965 := NULL;
                     END;
                  END IF;
               ELSE
                  IF ptablas = 'EST'
                  THEN
                     BEGIN
                        SELECT crespue
                          INTO v_crespue_4081
                          /*FROM pregungarancar*/
                        FROM   estpregungaranseg
                         WHERE sseguro = psseguro
                           AND cpregun = 4081
                           AND cgarant = v_cgardep
                           AND nmovimi = pnmovimi
                           AND nriesgo = pnriesgo;
                     EXCEPTION
                        WHEN NO_DATA_FOUND
                        THEN
                           numerr :=
                              pac_call.f_valor_asegurado_basica
                                                              (pnriesgo,
                                                               v_cgardep,
                                                               4081,
                                                               v_crespue_4081
                                                              );

                           IF numerr <> 0
                           THEN
                              RETURN NULL;
                           END IF;
                     END;
                  ELSE
                     BEGIN
                        SELECT crespue
                          INTO v_crespue_4081
                          FROM pregungaranseg
                         WHERE sseguro = psseguro
                           AND cpregun = 4081
                           AND cgarant = v_cgardep
                           AND nmovimi = pnmovimi
                           AND nriesgo = pnriesgo;
                     EXCEPTION
                        WHEN NO_DATA_FOUND
                        THEN
                           v_crespue_4081 := NULL;
                     END;
                  END IF;
               END IF;

               /* -- FIN BUG 18205 - 27/05/2015 - CAM*/
               IF ptablas = 'EST'
               THEN
                  BEGIN
                     SELECT crespue
                       INTO v_crespue_4085
                       FROM estpregungaranseg
                      WHERE sseguro = psseguro
                        AND cpregun = 4085
                        AND cgarant = pcgarant
                        AND nmovimi = pnmovimi
                        AND nriesgo = pnriesgo;
                  EXCEPTION
                     WHEN NO_DATA_FOUND
                     THEN
                        v_crespue_4085 := NULL;
                  END;
               ELSE
                  BEGIN
                     SELECT crespue
                       INTO v_crespue_4085
                       FROM pregungaranseg
                      WHERE sseguro = psseguro
                        AND cpregun = 4085
                        AND cgarant = pcgarant
                        AND nmovimi = pnmovimi
                        AND nriesgo = pnriesgo;
                  EXCEPTION
                     WHEN NO_DATA_FOUND
                     THEN
                        v_crespue_4085 := NULL;
                  END;
               END IF;

               IF v_pcapdep IS NOT NULL OR v_crespue_4085 IS NOT NULL
               THEN
                  /* INI BUG 18205 - 27/05/2015 - CAM - Tipo de Valor Asegurado Diferente de Planes*/
                  IF     v_crespue4783 <> 4
                     /* FIN BUG 18205 - 27/05/2015 - CAM*/
                     AND v_crespue_4965 IS NOT NULL
                     AND pcpregun = 4965
                  THEN
                     RETURN (  v_crespue_4965
                             * (NVL (v_crespue_4085, v_pcapdep) / 100)
                            );
                  ELSIF     v_crespue4783 = 4
                        AND v_crespue_4081 IS NOT NULL
                        AND pcpregun = 4081
                  THEN
                     RETURN (  v_crespue_4081
                             * (NVL (v_crespue_4085, v_pcapdep) / 100)
                            );
                  ELSE
                     RETURN NULL;
                  END IF;
               END IF;
            END IF;
         END IF;
      ELSE
         numerr :=
            pac_preguntas.f_get_pregunpolseg (psseguro,
                                              4089,
                                              NVL (ptablas, 'SEG'),
                                              w_resp_4089
                                             );

         /* Bug 22839 - RSC - 03/10/2012 - LCOL_T010-LCOL - Funcionalidad Certificado 0*/
         IF numerr = 120135
         THEN
            w_resp_4089 := 1;
         END IF;

         IF visaltacol
         THEN
            v_crespue := NULL;
         ELSE
            /* INI BUG 18205 - 27/05/2015 - CAM - Se envia como parametro v_arrastra_pre que es el numero de pregunta que se va a arrastrar al certificado individual*/
            v_crespue :=
               f_arrastra_pregunta (NVL (ptablas, 'SEG'),
                                    psseguro,
                                    pnriesgo,
                                    pfefecto,
                                    pnmovimi,
                                    pcgarant,
                                    psproces,
                                    pnmovima,
                                    picapital,
                                    v_npoliza,
                                    v_arrastra_pre,
                                    w_resp_4089
                                   );
         /* FIN BUG 18205 - 27/05/2015 - CAM*/
         END IF;

         numerr :=
            pac_preguntas.f_get_pregunpolseg (psseguro,
                                              4783,
                                              NVL (ptablas, 'SEG'),
                                              v_crespue4783
                                             );

         /* Planes no aplica valor informado*/
         IF v_crespue4783 = 4 AND NVL (v_crespue, 0) <> 0
         THEN
            v_crespue := NULL;
         END IF;
      END IF;

      RETURN v_crespue;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_propio_albsgt_conf.f_arrastra_pregunta_plan',
                      ntraza,
                         ' - ptablas  '
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
                      SQLERRM
                     );
         RETURN NULL;
   END f_arrastra_capital;

   /* Bug 24152 - RSC - 23/10/2012 - LCOL_T010-LCOL - Resolucion de incidencias de parametrizacion*/
   FUNCTION f_alta_certificado_doc (
      ptablas    IN   VARCHAR2,
      pcactivi   IN   NUMBER,
      psseguro   IN   NUMBER,
      pnmovimi   IN   NUMBER
   )
      RETURN NUMBER
   IS
      /**/
      num_err       NUMBER;
      v_valor       NUMBER                      := 0;
      v_resp_4820   estpregunseg.crespue%TYPE;
      v_npoliza     seguros.npoliza%TYPE;
      vsseguro      seguros.sseguro%TYPE;
   BEGIN
      IF ptablas = 'EST'
      THEN
         SELECT npoliza, ssegpol
           INTO v_npoliza, vsseguro
           FROM estseguros
          WHERE sseguro = psseguro;
      ELSE
         SELECT npoliza, sseguro
           INTO v_npoliza, vsseguro
           FROM seguros
          WHERE sseguro = psseguro;
      END IF;

      IF    pac_seguros.f_get_escertifcero (v_npoliza) > 0
         OR pac_seguros.f_get_escertifcero (NULL, vsseguro) = 0
      THEN                                           /* Alta de certificado.*/
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   END f_alta_certificado_doc;

   /* BUG 24657 - MDS - 23/11/2012
      FUNCTION f_alta_cero_doc(
         ptablas IN VARCHAR2,
         pcactivi IN NUMBER,
         psseguro IN NUMBER,
         pnmovimi IN NUMBER)
         RETURN NUMBER IS
         --
         num_err        NUMBER;
         v_valor        NUMBER := 0;
         v_resp_4820    estpregunseg.crespue%TYPE;
         v_npoliza      seguros.npoliza%TYPE;
         vsseguro       seguros.sseguro%TYPE;
      BEGIN
         IF ptablas = 'EST' THEN
            SELECT npoliza, ssegpol
              INTO v_npoliza, vsseguro
              FROM estseguros
             WHERE sseguro = psseguro;
         ELSE
            SELECT npoliza, sseguro
              INTO v_npoliza, vsseguro
              FROM seguros
             WHERE sseguro = psseguro;
         END IF;

         IF pac_seguros.f_get_escertifcero(v_npoliza) = 0
            OR pac_seguros.f_get_escertifcero(NULL, vsseguro) > 0 THEN   -- Alta de certificado 0
            RETURN 1;
         ELSE
            RETURN 0;
         END IF;
      END f_alta_cero_doc;
      */
   /* BUG 24657 - MDS - 23/11/2012
      FUNCTION f_alta_cerocertif_doc(
         ptablas IN VARCHAR2,
         pcactivi IN NUMBER,
         psseguro IN NUMBER,
         pnmovimi IN NUMBER)
         RETURN NUMBER IS
         --
         num_err        NUMBER;
         v_valor        NUMBER := 0;
         v_resp_4820    estpregunseg.crespue%TYPE;
      BEGIN
         IF f_alta_certificado_doc(ptablas, pcactivi, psseguro, pnmovimi) = 1
            OR f_alta_cero_doc(ptablas, pcactivi, psseguro, pnmovimi) = 1 THEN
            RETURN 1;
         ELSE
            RETURN 0;
         END IF;
      END f_alta_cerocertif_doc;
   */ -- Fin Bug 24152

   /* BUG23853:DRA:24/10/2012:Inici*/
   FUNCTION f_prima_minima (
      ptablas     IN   VARCHAR2,
      psseguro    IN   NUMBER,
      pnriesgo    IN   NUMBER,
      pfefecto    IN   DATE,
      pnmovimi    IN   NUMBER,
      pcgarant    IN   NUMBER,
      psproces    IN   NUMBER,
      pnmovima    IN   NUMBER,
      picapital   IN   NUMBER,
      pnpoliza    IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      /**/
      num_err     NUMBER;
      v_valor     NUMBER                 := 0;
      v_sproduc   seguros.sproduc%TYPE;
      v_crespue   NUMBER;
   BEGIN
      num_err :=
         pac_preguntas.f_get_pregunpolseg (psseguro, 4821, ptablas,
                                           v_crespue);

      IF v_crespue IS NULL
      THEN
         v_sproduc := pac_iax_produccion.poliza.det_poliza.sproduc;
         v_valor :=
             pac_parametros.f_parproducto_n (v_sproduc, 'VALOR_PRIMA_MINIMA');
      ELSE
         v_valor := v_crespue;
      END IF;

      RETURN v_valor;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_propio_albsgt_conf.f_prima_minima',
                      1,
                      'ptablas = ' || ptablas || ' psseguro = ' || psseguro,
                      SQLERRM
                     );
         RETURN NULL;
   END f_prima_minima;

   /* BUG23853:DRA:24/10/2012:Fi*/
   /* BUG25119:AMJ:14/12/2012:Inici*/
   FUNCTION f_tabla_mortalidad_reempl (
      ptablas     IN   VARCHAR2,
      psseguro    IN   NUMBER,
      pnriesgo    IN   NUMBER,
      pfefecto    IN   DATE,
      pnmovimi    IN   NUMBER,
      cgarant     IN   NUMBER,
      psproces    IN   NUMBER,
      pnmovima    IN   NUMBER,
      picapital   IN   NUMBER
   )
      RETURN NUMBER
   IS
      vresp4043   pregunseg.trespue%TYPE;
      v_sseguro   reemplazos.sseguro%TYPE;
      v_srempl    reemplazos.sreempl%TYPE;
      v_maxmov    movseguro.nmovimi%TYPE;
   BEGIN
      IF ptablas = 'EST'
      THEN
         SELECT sseguro
           INTO v_sseguro
           FROM estseguros
          WHERE sseguro = psseguro;

         BEGIN
            SELECT r.sreempl
              INTO v_srempl
              FROM estreemplazos r
             WHERE r.sseguro = v_sseguro;
         EXCEPTION
            WHEN OTHERS
            THEN                   /* BUG:25119  AMJ 22/01/2012 NOTA: 135816*/
               v_srempl := NULL;
         END;

         IF v_srempl IS NOT NULL
         THEN
            SELECT ps.crespue
              INTO vresp4043
              FROM pregunseg ps
             WHERE ps.sseguro = v_srempl
               AND ps.cpregun = 4043
               AND ps.nriesgo = pnriesgo
               AND ps.nmovimi =
                      (SELECT MAX (nmovimi)
                         FROM pregunseg ps1
                        WHERE ps1.sseguro = ps.sseguro
                          AND ps.cpregun = ps1.cpregun
                          AND ps.nriesgo = ps1.nriesgo);
         ELSE
            vresp4043 :=
               pac_propio_albsgt_conf.f_tabla_mortalidad (ptablas,
                                                          psseguro,
                                                          pnriesgo,
                                                          pfefecto,
                                                          pnmovimi,
                                                          cgarant,
                                                          psproces,
                                                          pnmovima,
                                                          picapital
                                                         );
         END IF;
      /*  BUG: 25119 AMJ  22/01/2013
      LCOL_T001-Modificar la funci?n para informar pregunta Tabla de mortalidad para seguros prorrogado, saldado
         -- se emplaza la respuesta en la nueva poliza.
         IF vresp4043 IS NOT NULL THEN
            UPDATE estpregunseg ps
               SET ps.crespue = vresp4043
             WHERE ps.sseguro = v_srempl
               AND ps.nriesgo = pnriesgo
               AND ps.cpregun = 4043
               AND ps.nmovimi = v_maxmov;
        END IF; */
      ELSE
         BEGIN
            SELECT r.sreempl
              INTO v_srempl
              FROM reemplazos r
             WHERE r.sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS
            THEN                   /* BUG:25119  AMJ 22/01/2012 NOTA: 135816*/
               v_srempl := NULL;
         END;

         IF v_srempl IS NOT NULL
         THEN
            SELECT ps.crespue
              INTO vresp4043
              FROM pregunseg ps
             WHERE ps.sseguro = v_srempl
               AND ps.cpregun = 4043
               AND ps.nriesgo = pnriesgo
               AND ps.nmovimi =
                      (SELECT MAX (nmovimi)
                         FROM pregunseg ps1
                        WHERE ps1.sseguro = ps.sseguro
                          AND ps.cpregun = ps1.cpregun
                          AND ps.nriesgo = ps1.nriesgo);
         ELSE
            vresp4043 :=
               pac_propio_albsgt_conf.f_tabla_mortalidad (ptablas,
                                                          psseguro,
                                                          pnriesgo,
                                                          pfefecto,
                                                          pnmovimi,
                                                          cgarant,
                                                          psproces,
                                                          pnmovima,
                                                          picapital
                                                         );
         END IF;
      /* BUG: 25119 AMJ  22/01/2013
      LCOL_T001-Modificar la funci?n para informar pregunta Tabla de mortalidad para seguros prorrogado, saldado y convertibilidad
       -- se emplaza la respuesta en la nueva poliza.
       IF vresp4043 IS NOT NULL THEN
          UPDATE pregunseg ps
             SET ps.crespue = vresp4043
           WHERE ps.sseguro = v_srempl
             AND ps.nriesgo = pnriesgo
             AND ps.cpregun = 4043
             AND ps.nmovimi = v_maxmov;
      END IF; */
      END IF;

      /* si la poliza no existe*/
      RETURN vresp4043;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_propio_albsgt_conf.f_tabla_mortalidad_reempl',
                      99,
                         ' - ptablas  '
                      || ptablas
                      || ' - psseguro '
                      || psseguro
                      || ' - pnriesgo '
                      || pnriesgo
                      || ' - pfefecto '
                      || pfefecto
                      || ' - pnmovimi '
                      || pnmovimi
                      || ' - cgarant '
                      || cgarant
                      || ' - psproces '
                      || psproces
                      || ' - pnmovima '
                      || pnmovima
                      || ' - picapital '
                      || picapital,
                      SQLERRM
                     );
         RETURN NULL;
   END f_tabla_mortalidad_reempl;

   /* BUG25119:AMJ:14/12/2012:Fi*/
   /* Bug 0023860 - JMF - 17/12/2012*/
   FUNCTION f_prima_manual_anualizada (
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
      num_err     NUMBER;
      vresp4822   pregunseg.crespue%TYPE;
      v_frenova   estseguros.frenova%TYPE;
      v_ssegpol   estseguros.ssegpol%TYPE;
      v_fefecto   estseguros.fefecto%TYPE;
      v_fcaranu   estseguros.fcaranu%TYPE;
      v_cprorra   productos.cprorra%TYPE;
      v_cforpag   estseguros.cforpag%TYPE;
      v_fecha     DATE;
      v_prima     NUMBER;
   BEGIN
      IF ptablas = 'EST'
      THEN
         SELECT frenova, ssegpol, fefecto, fcaranu, b.cprorra,
                a.cforpag
           INTO v_frenova, v_ssegpol, v_fefecto, v_fcaranu, v_cprorra,
                v_cforpag
           FROM estseguros a, productos b
          WHERE a.sseguro = psseguro AND b.sproduc = a.sproduc;

         BEGIN
            SELECT e.crespue
              INTO vresp4822
              FROM estpregungaranseg e
             WHERE e.sseguro = psseguro
               AND e.nmovimi = pnmovimi
               AND e.cpregun = 4822
               AND e.nriesgo = pnriesgo
               AND e.cgarant = pcgarant;
         EXCEPTION
            WHEN OTHERS
            THEN
               vresp4822 := NULL;
         END;

         IF pfefecto = v_fcaranu
         THEN
            v_fecha := pfefecto;
         ELSE
            BEGIN
               SELECT MAX (fefecto)
                 INTO v_fecha
                 FROM movseguro
                WHERE sseguro = v_ssegpol AND cmovseg = 2;

               IF (v_fecha IS NULL) OR (v_fecha < v_fefecto)
               THEN
                  v_fecha := v_fefecto;
               END IF;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  v_fecha := v_fefecto;
            END;
         END IF;
      ELSE
         SELECT frenova, fefecto, fcaranu, b.cprorra, a.cforpag
           INTO v_frenova, v_fefecto, v_fcaranu, v_cprorra, v_cforpag
           FROM seguros a, productos b
          WHERE a.sseguro = psseguro AND b.sproduc = a.sproduc;

         BEGIN
            SELECT e.crespue
              INTO vresp4822
              FROM pregungaranseg e
             WHERE e.sseguro = psseguro
               AND e.nmovimi = pnmovimi
               AND e.cpregun = 4822
               AND e.nriesgo = pnriesgo
               AND e.cgarant = pcgarant;
         EXCEPTION
            WHEN OTHERS
            THEN
               vresp4822 := NULL;
         END;

         IF pfefecto = v_fcaranu
         THEN
            v_fecha := pfefecto;
         ELSE
            BEGIN
               SELECT MAX (fefecto)
                 INTO v_fecha
                 FROM movseguro
                WHERE sseguro = psseguro AND cmovseg = 2;

               IF (v_fecha IS NULL) OR (v_fecha < v_fefecto)
               THEN
                  v_fecha := v_fefecto;
               END IF;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  v_fecha := v_fefecto;
            END;
         END IF;
      END IF;

      /*> ini PRORRATEO  <--*/
      DECLARE
         v_ini       DATE   := v_fecha;
         v_fin       DATE   := v_frenova;
         xcprorra    NUMBER := v_cprorra;
         xcforpag    NUMBER := v_cforpag;
         fanyoprox   DATE;
         xcmodulo    NUMBER;
         difdias     NUMBER;
         difdias2    NUMBER;
         divisor2    NUMBER;
         facnet      NUMBER;
      BEGIN
         fanyoprox := ADD_MONTHS (v_ini, 12);

         IF xcprorra = 2
         THEN                                                   /* Mod. 360*/
            xcmodulo := 3;
         ELSE                                                    /* Mod. 365*/
            xcmodulo := 1;
         END IF;

         num_err := f_difdata (v_ini, v_fin, 3, 3, difdias);
         num_err := f_difdata (v_ini, v_fin, xcmodulo, 3, difdias2);
         num_err := f_difdata (v_ini, fanyoprox, xcmodulo, 3, divisor2);

         IF xcforpag <> 0
         THEN
            /* Hi ha prorrata, prorratejem mòdul 365*/
            IF difdias2 > divisor2
            THEN
               facnet := divisor2 / difdias2;
            ELSE
               facnet := 1;
            END IF;
         ELSE
            facnet := 1;
         END IF;

         v_prima := vresp4822 * facnet;
      END;

      /*> fin PRORRATEO  <--*/
      RETURN v_prima;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_propio_albsgt_conf.f_Prima_manual_anualizada',
                      99,
                         ' - ptablas  '
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
                      SQLERRM
                     );
         RETURN NULL;
   END f_prima_manual_anualizada;

/*------------------------------------------------------------------------*/
/* Nou F_DISCRIMINANTE  13/03/2013*/
/*------------------------------------------------------------------------*/
   FUNCTION f_discriminante (
      ptablas     IN   VARCHAR2,
      psseguro    IN   NUMBER,
      pnriesgo    IN   NUMBER,
      pfefecto    IN   DATE,
      pnmovimi    IN   NUMBER,
      cgarant     IN   NUMBER,
      psproces    IN   NUMBER,
      pnmovima    IN   NUMBER,
      picapital   IN   NUMBER,
      pcpregun    IN   NUMBER
   )
      RETURN NUMBER
   IS
      v_csexo         per_personas.csexper%TYPE;
      v_cocupacion    per_detper.cocupacion%TYPE;
      v_fnacimi       DATE;
      v_antiguedad    NUMBER;
      v_ssegpol       NUMBER;
      v_fefecto       DATE;
      v_fecha         DATE;
      v_edad          NUMBER;
      v_fcaranu       DATE;
      num_err         NUMBER;
      n_retafrac      NUMBER (1);
      v_cursor        NUMBER;
      ss              VARCHAR2 (3000);
      funcion         VARCHAR2 (40);
      v_filas         NUMBER;
      p_sproduc       seguros.sproduc%TYPE;
      v_contatot      NUMBER;
      v_conta         NUMBER;
      v_vinculacion   NUMBER;
      /* Modificat 05/03/2013 MRB*/
      w_spereal       NUMBER;

      /* Bug 26923/146905 - APD - 27/06/2013 - el cursor debe ser de conductores no de tomadores*/
      CURSOR c_estautconductores
      IS
         SELECT a.sseguro, a.sperson
           FROM estautconductores a
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND nmovimi = pnmovimi
            AND cprincipal = 1;

      /* fin Bug 26923/146905 - APD - 27/06/2013*/
      /* Bug 26923/146905 - APD - 27/06/2013 - el cursor debe ser de conductores no de tomadores*/
      CURSOR c_autconductores
      IS
         SELECT sperson
           FROM autconductores
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND nmovimi = pnmovimi
            AND cprincipal = 1;
   /* fin Bug 26923/146905 - APD - 27/06/2013*/
   BEGIN
/*-----------------------------------------------------------------*/
    /*-------------- DISCRIMINANTE EDAD CONDUCTOR ---------------------*/
      IF pcpregun = 4904
      THEN
         IF ptablas = 'EST'
         THEN
            /* Estamos en nueva produccion o suplementos*/
            /* Es la fecha efecto del riesgo, tanto para nueva producción como para suplementos*/
            BEGIN
               /* Añadimos: , s.fcaranu*/
               SELECT p.fnacimi, s.ssegpol, a.fefecto, s.fcaranu
                 INTO v_fnacimi, v_ssegpol, v_fefecto, v_fcaranu
                 FROM estautconductores r,
                      estper_personas p,
                      estseguros s,
                      estriesgos a
                WHERE r.sseguro = psseguro
                  AND s.sseguro = r.sseguro
                  AND p.sperson = r.sperson
                  AND r.nriesgo = pnriesgo
                  AND a.sseguro = psseguro
                  /* Modificat 05/03/2013 MRB*/
                  AND a.nriesgo = r.nriesgo
                  AND r.cprincipal = 1;
            EXCEPTION
               WHEN OTHERS
               THEN
                  p_tab_error (f_sysdate,
                               f_user,
                               'pac_propio_albsgt_conf.DISCRIMINANTES',
                               2,
                                  'p_sseguro = '
                               || psseguro
                               || ' nriesgo = '
                               || pnriesgo
                               || ' - ptablas  '
                               || ptablas
                               || ' PCPREGUN'
                               || pcpregun,
                               SQLERRM
                              );
                  RETURN NULL;
            END;

            /**/
            IF pfefecto = v_fcaranu
            THEN
               v_fecha := pfefecto;
            ELSE
               /* Fin Bug 11664*/
               BEGIN
                  SELECT MAX (fefecto)
                    INTO v_fecha
                    FROM movseguro
                   WHERE sseguro = v_ssegpol AND cmovseg = 2;

                  IF (v_fecha IS NULL) OR (v_fecha < v_fefecto)
                  THEN
                     v_fecha := v_fefecto;
                  END IF;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     v_fecha := v_fefecto;
               END;
            /**/
            END IF;

            /**/
            num_err := f_difdata (v_fnacimi, v_fecha, 1, 1, v_edad);
         ELSE
            /* Hay que ir a las tablas REALES (PTABLAS NULL O DIFERENT DE EST)*/
            BEGIN
               /**/
               SELECT p.fnacimi, a.fefecto, s.fcaranu
                 INTO v_fnacimi, v_fefecto, v_fcaranu
                 FROM autconductores r, per_personas p, seguros s, riesgos a
                WHERE r.sseguro = psseguro
                  AND s.sseguro = r.sseguro
                  AND p.sperson = r.sperson
                  AND r.nriesgo = pnriesgo
                  AND a.sseguro = psseguro
                  /* Modificat 05/03/2013 MRB*/
                  AND a.nriesgo = r.nriesgo
                  AND r.nmovimi = pnmovimi
                  AND r.cprincipal = 1;
            EXCEPTION
               WHEN OTHERS
               THEN
                  p_tab_error (f_sysdate,
                               f_user,
                               'pac_propio_albsgt_conf.DISCRIMINANTES',
                               3,
                                  'p_sseguro = '
                               || psseguro
                               || ' nriesgo = '
                               || pnriesgo
                               || ' - ptablas  '
                               || ptablas
                               || ' PCPREGUN'
                               || pcpregun,
                               SQLERRM
                              );
                  RETURN NULL;
            END;

            /**/
            IF pfefecto = v_fcaranu
            THEN
               v_fecha := pfefecto;
            ELSE
               BEGIN
                  SELECT MAX (fefecto)
                    INTO v_fecha
                    FROM movseguro
                   WHERE sseguro = psseguro AND cmovseg = 2;

                  /**/
                  IF (v_fecha IS NULL) OR (v_fecha < v_fefecto)
                  THEN
                     v_fecha := v_fefecto;
                  END IF;
               /**/
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     v_fecha := v_fefecto;
               END;
            END IF;

            /**/
            num_err := f_difdata (v_fnacimi, v_fecha, 1, 1, v_edad);
         END IF;

         /**/
         RETURN v_edad;
/*------------------------------------------------------------------*/
/*-------------- DISCRIMINANTE GÉNERO (SEXO) -----------------------*/
      ELSIF pcpregun = 4905
      THEN                                   /* Discriminante Género (Sexo).*/
         IF ptablas = 'EST'
         THEN
            /* Estamos en nueva produccion o suplementos*/
            BEGIN
               SELECT p.csexper
                 INTO v_csexo
                 FROM estautconductores r, estper_personas p, estseguros s
                WHERE r.sseguro = psseguro
                  AND s.sseguro = r.sseguro
                  AND p.sperson = r.sperson
                  /* Modificat 05/03/2013 MRB*/
                  AND r.nriesgo = pnriesgo
                  AND r.cprincipal = 1;
            EXCEPTION
               WHEN OTHERS
               THEN
                  p_tab_error (f_sysdate,
                               f_user,
                               'pac_propio_albsgt_conf.DISCRIMINANTES',
                               2,
                                  'p_sseguro = '
                               || psseguro
                               || ' nriesgo = '
                               || pnriesgo
                               || ' - ptablas  '
                               || ptablas
                               || ' PCPREGUN'
                               || pcpregun,
                               SQLERRM
                              );
                  RETURN NULL;
            END;
         /**/
         ELSE
            /* Tenimque anar per les taules REALS*/
            BEGIN
               SELECT p.csexper
                 INTO v_csexo
                 FROM autconductores r, per_personas p, seguros s
                WHERE r.sseguro = psseguro
                  AND s.sseguro = r.sseguro
                  AND p.sperson = r.sperson
                  /* Modificat 05/03/2013 MRB*/
                  AND r.nriesgo = pnriesgo
                  AND r.nmovimi = pnmovimi
                  AND r.cprincipal = 1;
            EXCEPTION
               WHEN OTHERS
               THEN
                  p_tab_error (f_sysdate,
                               f_user,
                               'pac_propio_albsgt_conf.DISCRIMINANTES',
                               3,
                                  'p_sseguro = '
                               || psseguro
                               || ' nriesgo = '
                               || pnriesgo
                               || ' - ptablas  '
                               || ptablas
                               || ' PCPREGUN'
                               || pcpregun,
                               SQLERRM
                              );
                  RETURN NULL;
            END;
         END IF;

         /**/
         RETURN v_csexo;
/*---------------------------------------------------------------------*/
/*-------------- DISCRIMINANTE OCUPACION --------------------------*/
      ELSIF pcpregun = 4906
      THEN                                       /* Discriminante Ocupación.*/
         IF ptablas = 'EST'
         THEN
            /* Estamos en nueva produccion o suplementos*/
            BEGIN
               SELECT d.cocupacion
                 INTO v_cocupacion
                 FROM estautconductores r,
                      estper_personas p,
                      estseguros s,
                      estper_detper d
                WHERE r.sseguro = psseguro
                  AND s.sseguro = r.sseguro
                  AND p.sperson = r.sperson
                  AND r.nriesgo = pnriesgo
                  /* Modificat 05/03/2013 MRB*/
                  AND d.sperson = p.sperson
                  AND r.cprincipal = 1;
            EXCEPTION
               WHEN OTHERS
               THEN
                  p_tab_error (f_sysdate,
                               f_user,
                               'pac_propio_albsgt_conf.DISCRIMINANTES',
                               2,
                                  'p_sseguro = '
                               || psseguro
                               || ' nriesgo = '
                               || pnriesgo
                               || ' - ptablas  '
                               || ptablas
                               || ' PCPREGUN'
                               || pcpregun,
                               SQLERRM
                              );
                  RETURN NULL;
            END;
         /**/
         ELSE
            /* Tenim que anar per les taules REALS*/
            BEGIN
               SELECT d.cocupacion
                 INTO v_cocupacion
                 /* Modificat 05/03/2013 MRB*/
               FROM   autconductores r,
                      per_personas p,
                      seguros s,
                      per_detper d
                WHERE r.sseguro = psseguro
                  AND s.sseguro = r.sseguro
                  AND p.sperson = r.sperson
                  AND r.nriesgo = pnriesgo
                  /* Modificat 05/03/2013 MRB*/
                  AND d.sperson = p.sperson
                  AND r.nmovimi = pnmovimi
                  AND r.cprincipal = 1;
            EXCEPTION
               WHEN OTHERS
               THEN
                  p_tab_error (f_sysdate,
                               f_user,
                               'pac_propio_albsgt_conf.DISCRIMINANTES',
                               3,
                                  'p_sseguro = '
                               || psseguro
                               || ' nriesgo = '
                               || pnriesgo
                               || ' - ptablas  '
                               || ptablas
                               || ' PCPREGUN'
                               || pcpregun,
                               SQLERRM
                              );
                  RETURN NULL;
            END;
         END IF;

         /**/
         RETURN v_cocupacion;
/*---------------------------------------------------------------*/
      ELSIF pcpregun = 4908
      THEN                                     /* Discriminante VINCULACION.*/
         IF ptablas = 'EST'
         THEN
            v_contatot := 0;

            /* Bug 26923/146905 - APD - 27/06/2013 - se añade el IF pnmovimi = 1*/
            IF pnmovimi = 1
            THEN
               /* Estamos en nueva produccion*/
               FOR reg IN c_estautconductores
               LOOP
                  /* Modificat 05/03/2013 MRB*/
                  BEGIN
                     SELECT spereal
                       INTO w_spereal
                       FROM estper_personas
                      WHERE sperson = reg.sperson;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        p_tab_error
                             (f_sysdate,
                              f_user,
                              'pac_propio_albsgt_conf.DISCRIMINANTES_VINCUL',
                              64,
                                 'p_sseguro = '
                              || psseguro
                              || ' nriesgo = '
                              || pnriesgo
                              || ' - ptablas  '
                              || ptablas
                              || ' PCPREGUN'
                              || pcpregun,
                              SQLERRM
                             );
                        w_spereal := NULL;
                  END;

                  /**/
                  BEGIN
                     SELECT ssegpol
                       INTO v_ssegpol
                       FROM estseguros
                      WHERE sseguro = psseguro;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        p_tab_error
                             (f_sysdate,
                              f_user,
                              'pac_propio_albsgt_conf.DISCRIMINANTES_VINCUL',
                              65,
                                 'p_sseguro = '
                              || psseguro
                              || ' nriesgo = '
                              || pnriesgo
                              || ' - ptablas  '
                              || ptablas
                              || ' PCPREGUN'
                              || pcpregun,
                              SQLERRM
                             );
                        v_ssegpol := NULL;
                  END;

                  /**/
                  SELECT COUNT (*)
                    INTO v_conta
                    FROM seguros s
                   WHERE s.sseguro IN (SELECT sseguro
                                         FROM tomadores
                                        /* Modificat 05/03/2013 MRB*/
                                       WHERE  sperson = w_spereal)
                     AND s.sseguro != v_ssegpol
                     AND s.csituac IN (0, 5);

                  v_contatot := v_contatot + v_conta;
               END LOOP;
            /* Bug 26923/146905 - APD - 27/06/2013 - se añade el ELSE*/
            ELSE
               /* Estamos en suplementos*/
               num_err :=
                  pac_preguntas.f_get_pregunseg (psseguro,
                                                 pnriesgo,
                                                 pcpregun,
                                                 ptablas,
                                                 v_contatot
                                                );

               IF num_err <> 0
               THEN
                  p_tab_error (f_sysdate,
                               f_user,
                               'pac_propio_albsgt_conf.DISCRIMINANTES',
                               66,
                                  'p_sseguro = '
                               || psseguro
                               || ' nriesgo = '
                               || pnriesgo
                               || ' - ptablas  '
                               || ptablas
                               || ' PCPREGUN'
                               || pcpregun,
                               SQLERRM
                              );
                  RETURN NULL;
               END IF;
            END IF;

            /* fin Bug 26923/146905 - APD - 27/06/2013*/
              /**/
            IF v_contatot > 0
            THEN
               /* Ini bug 26923 -- ECP-- 30/05/2013*/
                 /*v_vinculacion := 1;*/
               v_vinculacion := v_contatot;
            /* Fin bug 26923 -- ECP-- 30/05/2013*/
            ELSE
               v_vinculacion := 0;
            END IF;
         /**/
         ELSE
            /* Estamos en cartera*/
            v_contatot := 0;

            /* NO SON TABLAS EST*/
            FOR reg IN c_autconductores
            LOOP
               SELECT COUNT (*)
                 INTO v_conta
                 FROM seguros s
                WHERE s.sseguro IN (SELECT sseguro
                                      FROM tomadores
                                     WHERE sperson = reg.sperson)
                  AND s.sseguro != psseguro
                  AND s.csituac IN (0, 5);

               v_contatot := v_contatot + v_conta;
            END LOOP;

            /**/
            IF v_contatot > 0
            THEN
               /* Ini bug 27748 -- MRB-- 26/07/2013*/
                 /*v_vinculacion := 1;*/
               v_vinculacion := v_contatot;
            /* Fin bug 27748 -- MRB-- 26/07/2013*/
            ELSE
               v_vinculacion := 0;
            END IF;
         /**/
         /*  -- BUG 27748 -- MRB 26/07/2013
         IF v_contatot > 0 THEN
            v_vinculacion := 1;
         ELSE
            v_vinculacion := 0;
         END IF;
         */
         /**/
         END IF;

         /**/
         RETURN v_vinculacion;
/*---------------------------------------------------------------*/
      END IF;    /* Del primer if de cpregun*/
     /*---------------------------------------------------------------------*/
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 22222;
   END f_discriminante;

/*------------------------------------------------------------------------*/
   FUNCTION f_preg_subtab (
      ptablas      IN   VARCHAR2,
      psseguro     IN   NUMBER,
      pnriesgo     IN   NUMBER,
      pfefecto     IN   DATE,
      pnmovimi     IN   NUMBER,
      cgarant      IN   NUMBER,
      psproces     IN   NUMBER,
      pnmovima     IN   NUMBER,
      picapital    IN   NUMBER,
      pcpregun     IN   NUMBER,
      /* 0028041/0152073 - JSV 03/09/2013*/
      pcsubtabla   IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      v_sproduc       NUMBER;
      v_torna         NUMBER;
      /*BUG 0027923 - INICIO - DCT - 12/09/2013 - LCOL_F3BTEC-MTF3B - LCOL_TEC23 - Definici?n de condiciones en Certificado 0*/
      visaltacol      BOOLEAN                     := FALSE;
      v_npoliza       seguros.npoliza%TYPE;
      numerr          NUMBER;
      w_resp_4089     pregunpolseg.crespue%TYPE;
      v_crespue       pregunpolseg.crespue%TYPE;
      vadmitecertif   NUMBER;
   /*BUG 0027923 - FIN - DCT - 12/09/2013 - LCOL_F3BTEC-MTF3B - LCOL_TEC23 - Definici?n de condiciones en Certificado 0*/
   BEGIN
      /*BUG 0027923 - INICIO - DCT - 12/09/2013 - LCOL_F3BTEC-MTF3B - LCOL_TEC23 - Definici?n de condiciones en Certificado 0*/
      visaltacol := f_alta_certificado (ptablas, psseguro);

      IF ptablas = 'EST'
      THEN
         BEGIN
            SELECT sproduc
              INTO v_sproduc
              FROM estseguros
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS
            THEN
               v_sproduc := NULL;
         END;
      ELSE
         BEGIN
            SELECT sproduc
              INTO v_sproduc
              FROM seguros
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS
            THEN
               v_sproduc := NULL;
         END;
      END IF;

      IF v_sproduc IS NOT NULL
      THEN
         vadmitecertif :=
                 NVL (f_parproductos_v (v_sproduc, 'ADMITE_CERTIFICADOS'), 0);
      ELSE
         vadmitecertif := 0;
      END IF;

      IF visaltacol OR vadmitecertif = 0
      THEN
         IF ptablas = 'EST'
         THEN
            BEGIN
               SELECT sproduc
                 INTO v_sproduc
                 FROM estseguros
                WHERE sseguro = psseguro;
            EXCEPTION
               WHEN OTHERS
               THEN
                  v_sproduc := NULL;
            END;
         ELSE
            BEGIN
               SELECT sproduc
                 INTO v_sproduc
                 FROM seguros
                WHERE sseguro = psseguro;
            EXCEPTION
               WHEN OTHERS
               THEN
                  v_sproduc := NULL;
            END;
         END IF;

         /**/
         IF v_sproduc IS NULL
         THEN
            v_torna := NULL;
         ELSE
            IF pcpregun = 4909
            THEN
               v_torna :=
                  pac_subtablas.f_vsubtabla (NULL,
                                             /* 0028041/0152073 - JSV 03/09/2013 - INI*/
                                             /*60310766,*/
                                             NVL (pcsubtabla, 60310766),
                                             333,
                                             4,
                                             v_sproduc,
                                             cgarant,
                                             99
                                            );
            ELSIF pcpregun = 4910
            THEN
               v_torna :=
                  pac_subtablas.f_vsubtabla (NULL,
                                             /* 0028041/0152073 - JSV 03/09/2013 - INI*/
                                             /*60310766,*/
                                             NVL (pcsubtabla, 60310766),
                                             333,
                                             2,
                                             v_sproduc,
                                             cgarant,
                                             99
                                            );
            ELSIF pcpregun = 4911
            THEN
               v_torna :=
                  pac_subtablas.f_vsubtabla (NULL,
                                             /* 0028041/0152073 - JSV 03/09/2013 - INI*/
                                             /*60310766,*/
                                             NVL (pcsubtabla, 60310766),
                                             333,
                                             3,
                                             v_sproduc,
                                             cgarant,
                                             99
                                            );
            ELSIF pcpregun = 4914
            THEN
               v_torna :=
                  pac_subtablas.f_vsubtabla (NULL,
                                             /* 0028041/0152073 - JSV 03/09/2013 - INI*/
                                             /*60310764,*/
                                             NVL (pcsubtabla, 60310764),
                                             333,
                                             2,
                                             v_sproduc,
                                             cgarant,
                                             99
                                            );
            ELSIF pcpregun = 4915
            THEN
               v_torna :=
                  pac_subtablas.f_vsubtabla (NULL,
                                             /* 0028041/0152073 - JSV 03/09/2013 - INI*/
                                             /*60310764,*/
                                             NVL (pcsubtabla, 60310764),
                                             333,
                                             3,
                                             v_sproduc,
                                             cgarant,
                                             99
                                            );
            ELSE
               v_torna := NULL;
            END IF;
         END IF;
      ELSE
         BEGIN
            IF ptablas = 'EST'
            THEN
               SELECT npoliza
                 INTO v_npoliza
                 FROM estseguros
                WHERE sseguro = psseguro;
            ELSE
               SELECT npoliza
                 INTO v_npoliza
                 FROM seguros
                WHERE sseguro = psseguro;
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               v_npoliza := pac_iax_produccion.poliza.det_poliza.npoliza;
         END;

         numerr :=
            pac_preguntas.f_get_pregunpolseg (psseguro,
                                              4089,
                                              NVL (ptablas, 'SEG'),
                                              w_resp_4089
                                             );

         IF numerr = 120135
         THEN
            w_resp_4089 := 1;
         END IF;

         v_torna :=
            f_arrastra_pregunta (NVL (ptablas, 'SEG'),
                                 psseguro,
                                 pnriesgo,
                                 pfefecto,
                                 pnmovimi,
                                 cgarant,
                                 psproces,
                                 pnmovima,
                                 picapital,
                                 v_npoliza,
                                 pcpregun,
                                 w_resp_4089
                                );

         /* Bug 31686/179438 - 17/07/2014 - AMC*/
         IF v_torna IS NULL
         THEN
            IF pcpregun = 4914
            THEN
               v_torna :=
                  pac_subtablas.f_vsubtabla (NULL,
                                             NVL (pcsubtabla, 60310764),
                                             333,
                                             2,
                                             v_sproduc,
                                             cgarant,
                                             99
                                            );
            ELSIF pcpregun = 4915
            THEN
               v_torna :=
                  pac_subtablas.f_vsubtabla (NULL,
                                             NVL (pcsubtabla, 60310764),
                                             333,
                                             3,
                                             v_sproduc,
                                             cgarant,
                                             99
                                            );
            END IF;
         END IF;
      /* Fi Bug 31686/179438 - 17/07/2014 - AMC*/
      END IF;

      RETURN v_torna;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'EXC GEN pac_propio_albsgt_conf.f_preg_subtab',
                      9,
                         'p_sseguro torna NULL = '
                      || psseguro
                      || ' pfefecto '
                      || pfefecto
                      || ' nriesgo = '
                      || pnriesgo
                      || ' - ptablas  '
                      || ptablas
                      || ' psproduc = '
                      || v_sproduc
                      || ' PCPREGUN'
                      || pcpregun,
                      SQLERRM
                     );
         RETURN 22222;
   /**/
   END f_preg_subtab;

/*------------------------------------------------------------------------*/
/*----------------------------------------------------------------------------------*/
/* Modificación de J.L.Vázquez*/
   FUNCTION f_respue_retorno (
      ptablas     IN   VARCHAR2,
      psseguro    IN   NUMBER,
      pnriesgo    IN   NUMBER,
      pfefecto    IN   DATE,
      pnmovimi    IN   NUMBER,
      pcgarant    IN   NUMBER,
      psproces    IN   NUMBER,
      pnmovima    IN   NUMBER,
      picapital   IN   NUMBER,
      pnpoliza    IN   NUMBER
   )
      RETURN NUMBER
   IS
      vobj             VARCHAR2 (200)
                                 := 'pac_propio_albsgt_conf.f_respue_retorno';
      vpar             VARCHAR2 (500)
         :=    't = '
            || ptablas
            || ' s = '
            || psseguro
            || ' r = '
            || pnriesgo
            || ' e = '
            || pfefecto
            || ' m = '
            || pnmovimi
            || ' g = '
            || pcgarant
            || ' p = '
            || psproces
            || ' a = '
            || pnmovima
            || ' c = '
            || picapital;
      vpas             NUMBER                            := 1;
      vnumerr          NUMBER;
      vsproduc         estseguros.sproduc%TYPE;
      vcagente         estseguros.cagente%TYPE;
      vfefecto         estseguros.fefecto%TYPE;
      vnpoliza         estseguros.npoliza%TYPE;
      vncertif         estseguros.ncertif%TYPE;
      vidconvenio      rtn_mntconvenio.idconvenio%TYPE;
      v_sperson        per_personas.sperson%TYPE;
      v_ret            NUMBER (1);
      v_tom_sperson    per_personas.sperson%TYPE;
      v_tom_nnumide    per_personas.nnumide%TYPE;
      v_tom_ctipper    per_personas.ctipper%TYPE;
      v_tom_ctipide    per_personas.ctipide%TYPE;
      v_tom_tapelli1   per_detper.tapelli1%TYPE;
      v_tom_tapelli2   per_detper.tapelli2%TYPE;
      v_tom_tnombre1   per_detper.tnombre1%TYPE;
      v_tom_tnombre2   per_detper.tnombre2%TYPE;
      v_visaltacol     BOOLEAN;
      e_salida         EXCEPTION;
   BEGIN
      vpas := 100;
      vnumerr :=
         pac_call.f_datos_seguro (vcagente,
                                  vsproduc,
                                  vfefecto,
                                  vnpoliza,
                                  vncertif
                                 );

      IF vnumerr = 1
      THEN
         RAISE NO_DATA_FOUND;
      END IF;

      IF vnpoliza IS NULL
      THEN
         /*Si vnpoliza es nulo, quiere decir que el objeto póliza esta vacio*/
           /*estamos en una carga, obtenemos los datos de las tablas EST*/
         IF ptablas = 'EST'
         THEN
            SELECT cagente, sproduc, fefecto, npoliza, ncertif
              INTO vcagente, vsproduc, vfefecto, vnpoliza, vncertif
              FROM estseguros
             WHERE sseguro = psseguro;
         ELSE
            SELECT cagente, sproduc, fefecto, npoliza, ncertif
              INTO vcagente, vsproduc, vfefecto, vnpoliza, vncertif
              FROM seguros
             WHERE sseguro = psseguro;
         END IF;
      END IF;

      v_visaltacol := FALSE;

      IF pac_iax_produccion.isaltacol
      THEN
         v_visaltacol := TRUE;
      ELSE
         IF vncertif = 0
         THEN
            v_visaltacol := TRUE;
         END IF;
      END IF;

      IF NOT v_visaltacol AND NVL (vncertif, 0) > 0
      THEN                     /* BUG 0025815 recupera convenio retorno. JLV*/
    /*IF NVL(vncertif, 0) > 0 THEN*/
      /* Buscamos el valor del certificado padre*/
         vpas := 110;
         v_ret :=
            pac_propio_albsgt_conf.f_arrastra_pregunta (ptablas,
                                                        psseguro,
                                                        pnriesgo,
                                                        pfefecto,
                                                        pnmovimi,
                                                        pcgarant,
                                                        psproces,
                                                        pnmovima,
                                                        picapital,
                                                        vnpoliza,
                                                        4817
                                                       );
      ELSE
         /* Calculamos si tendra convenio o no*/
         vpas := 120;
         vnumerr :=
            pac_call.f_datos_tomador (1,
                                      v_tom_sperson,
                                      v_tom_ctipper,
                                      v_tom_ctipide,
                                      v_tom_nnumide,
                                      v_tom_tapelli1,
                                      v_tom_tapelli2,
                                      v_tom_tnombre1,
                                      v_tom_tnombre2
                                     );

         IF vnumerr = 1
         THEN
            RAISE NO_DATA_FOUND;
         END IF;

         vpas := 130;

         /* Bug  33752/0193820  - JLTS - 09/12/2014 -- 34. Se adiciona la condición  IF ptablas = 'EST' THEN*/
         IF ptablas = 'EST'
         THEN
            v_sperson := pac_persona.f_sperson_spereal (v_tom_sperson);

            IF v_sperson IS NULL
            THEN
               RAISE NO_DATA_FOUND;
            END IF;
         ELSE
            v_sperson := v_tom_sperson;
         END IF;

         vpas := 140;
         vnumerr :=
            pac_retorno.f_busca_convenioretorno (psseguro,
                                                 vsproduc,
                                                 vfefecto,
                                                 vcagente,
                                                 vidconvenio,
                                                 v_sperson
                                                );
         vpas := 150;

         IF vnumerr = 0 AND vidconvenio IS NOT NULL
         THEN
            v_ret := 1;
         ELSIF vnumerr = 0 AND vidconvenio IS NULL
         THEN
            v_ret := 0;
         ELSE
            v_ret := NULL;
         END IF;
      END IF;

      vpas := 160;
      RETURN v_ret;
   EXCEPTION
      WHEN e_salida
      THEN
         RETURN NULL;
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobj,
                      vpas,
                      vpar || ' tom=' || v_tom_sperson,
                      vnumerr || ' ' || SQLCODE || '-' || SQLERRM
                     );
         RETURN NULL;
   END f_respue_retorno;

/*----------------------------------------------------------------------------------*/
/* Bug  0025583  - ECP - 23/01/2012*/
   FUNCTION f_arrastra_pregunta_carencia (
      ptablas     IN   VARCHAR2,
      psseguro    IN   NUMBER,
      pnriesgo    IN   NUMBER,
      pfefecto    IN   DATE,
      pnmovimi    IN   NUMBER,
      pcgarant    IN   NUMBER,
      psproces    IN   NUMBER,
      pnmovima    IN   NUMBER,
      picapital   IN   NUMBER,
      pcpregun    IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      v_resp_4802   pregunpolseg.crespue%TYPE;
      v_crespue     estpregunpolseg.crespue%TYPE;
      v_npoliza     estseguros.npoliza%TYPE;
      numerr        NUMBER;
      ntraza        NUMBER;
   BEGIN
      IF (ptablas = 'EST')
      THEN
         BEGIN
            SELECT e.crespue
              INTO v_resp_4802
              FROM estpregungaranseg e
             WHERE e.sseguro = psseguro
               AND e.nmovimi = pnmovimi
               AND e.cpregun = pcpregun
               AND e.nriesgo = pnriesgo
               AND e.cgarant = 10;
         EXCEPTION
            WHEN OTHERS
            THEN
               v_resp_4802 := 0;
         END;
      ELSE
         BEGIN
            SELECT e.crespue
              INTO v_resp_4802
              FROM estpregungaranseg e
             WHERE e.sseguro = psseguro
               AND e.nmovimi = pnmovimi
               AND e.cpregun = pcpregun
               AND e.nriesgo = pnriesgo
               AND e.cgarant = 10;
         EXCEPTION
            WHEN OTHERS
            THEN
               v_resp_4802 := 0;
         END;
      END IF;

      RETURN v_resp_4802;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_propio_albsgt_conf.f_arrastra_pregunta_carencia',
                      ntraza,
                         ' - ptablas  '
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
                      SQLERRM
                     );
         RETURN NULL;
   END f_arrastra_pregunta_carencia;

/*------------------------------------------------------------------------*/
/* Nou F_AUTOS_ANTIGUEDAD  13/03/2013*/
/*------------------------------------------------------------------------*/
   FUNCTION f_autos_antiguedad (
      ptablas     IN   VARCHAR2,
      psseguro    IN   NUMBER,
      pnriesgo    IN   NUMBER,
      pfefecto    IN   DATE,
      pnmovimi    IN   NUMBER,
      pcgarant    IN   NUMBER,
      psproces    IN   NUMBER,
      pnmovima    IN   NUMBER,
      picapital   IN   NUMBER,
      pcpregun    IN   NUMBER
   )
      RETURN NUMBER
   IS
      w_param            VARCHAR2 (2000)
         :=    'ptablas = '
            || ptablas
            || '   psseguro= '
            || psseguro
            || '   pnriesgo= '
            || pnriesgo
            || ' pfefecto =   '
            || pfefecto
            || ' pnmovimi=   '
            || pnmovimi
            || '   pcgarant='
            || pcgarant
            || ' psproces=  '
            || psproces
            || '   pnmovima= '
            || pnmovima
            || '  picapital=  '
            || picapital
            || '   pcpregun='
            || pcpregun;
      w_exper_manual     autconductores.exper_manual%TYPE;
      w_sperson          autconductores.sperson%TYPE;
      w_anysantiguedad   NUMBER;
      w_torna            NUMBER;
      w_sperson_ant      autconductores.sperson%TYPE;
      /* SPERSON REAL del Conductor del Movimiento Anterior*/
      w_crespue_ant      pregunseg.crespue%TYPE;
      w_crespue_error    NUMBER;
      /**/
      w_spereal          estper_personas.spereal%TYPE;
      /* SPERSON REAL CONDUCTOR para acceder a las tablas REALES*/
      w_ssegpol          estseguros.ssegpol%TYPE;
                            /* SSEGURO REAL para acceder a las tablas REALES*/
/**/
      w_fefecto          estseguros.fefecto%TYPE;
      /*  Bug 26923/147980 - APD - 01/07/2013*/
      w_fcaranu          estseguros.fcaranu%TYPE;
      /*  Bug 26923/147980 - APD - 01/07/2013*/
      w_fecha            estseguros.fefecto%TYPE;
                                     /*  Bug 26923/147980 - APD - 01/07/2013*/
/**/
   BEGIN
      /**/
      w_torna := 0;

      /**/
      IF ptablas = 'EST'
      THEN
         /**/
         BEGIN
            /*  Bug 26923/147980 - APD - 01/07/2013*/
                /* Añadimos: s.fefecto , s.fcaranu*/
            SELECT s.ssegpol, s.fefecto, s.fcaranu
              INTO w_ssegpol, w_fefecto, w_fcaranu
              FROM estseguros s
             WHERE s.sseguro = psseguro;
         /*  fin Bug 26923/147980 - APD - 01/07/2013*/
         /**/
         /**/
         EXCEPTION
            WHEN OTHERS
            THEN
               w_ssegpol := 0;
         END;

         /**/
         BEGIN
            SELECT exper_manual, sperson
              INTO w_exper_manual, w_sperson
              FROM estautconductores
             WHERE sseguro = psseguro
               AND nriesgo = pnriesgo
               AND nmovimi = pnmovimi  /*Bug 34371/197570 - 09/02/2015 - AMC*/
               AND cprincipal = 1;
         /**/
         /**/
         EXCEPTION
            WHEN OTHERS
            THEN
               p_tab_error (f_sysdate,
                            f_user,
                            'pac_propio_albsgt_conf.f_autos_antiguedad',
                            97,
                               w_param
                            || ' w_fecha '
                            || w_fecha
                            || '  w_spereal '
                            || w_spereal,
                            SQLERRM
                           );
               w_exper_manual := 0;
               w_sperson := 0;
         END;

         /**/
         BEGIN
            SELECT spereal
              INTO w_spereal
              FROM estper_personas
             WHERE sperson = w_sperson;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               w_spereal := NULL;
            WHEN OTHERS
            THEN
               w_spereal := NULL;
         END;

         /**/
         IF w_spereal IS NULL
         THEN
            w_anysantiguedad := 0;
         ELSE
            BEGIN
               /*  Bug 26923/147980 - APD - 01/07/2013*/
               /* mismo codigo que en f_edad_riesgo*/
               IF pfefecto = w_fcaranu
               THEN
                  w_fecha := pfefecto;
               ELSE
                  BEGIN
                     SELECT MAX (fefecto)
                       INTO w_fecha
                       FROM movseguro
                      WHERE sseguro = w_ssegpol AND cmovseg = 2;

                     IF (w_fecha IS NULL) OR (w_fecha < w_fefecto)
                     THEN
                        w_fecha := w_fefecto;
                     END IF;
                  EXCEPTION
                     WHEN NO_DATA_FOUND
                     THEN
                        w_fecha := w_fefecto;
                  END;
               END IF;

               /*  fin Bug 26923/147980 - APD - 01/07/2013*/
               /*SELECT TRUNC(MONTHS_BETWEEN(TO_DATE(fantiguedad, 'YYYYMMDD'), pfefecto) / 12)*/
               /* Modificat M.R.B. 05/03/2013*/
               /*  Bug 26923/147980 - APD - 01/07/2013 - se sustituye pfefecto por w_fecha*/
               SELECT ABS (TRUNC (MONTHS_BETWEEN (w_fecha, fantiguedad) / 12))
                 INTO w_anysantiguedad
                 FROM per_antiguedad
                WHERE sperson = w_spereal AND cestado = 0;
            /**/
            /**/
            EXCEPTION
               WHEN OTHERS
               THEN
                  p_tab_error (f_sysdate,
                               f_user,
                               'pac_propio_albsgt_conf.f_autos_antiguedad',
                               98,
                                  w_param
                               || ' w_fecha '
                               || w_fecha
                               || '  w_spereal '
                               || w_spereal,
                               SQLERRM
                              );
                  w_anysantiguedad := 0;
            END;
         END IF;

         /**/
         /* Bug 26923/147980 - APD - 01/07/2013 - se comenta ya que ahora no se necesita.*/
         /*
                  BEGIN
                     SELECT sperson
                       INTO w_sperson_ant
                       FROM autconductores
                      WHERE sseguro = w_ssegpol
                        AND nriesgo = pnriesgo
                        AND nmovimi = (SELECT MAX(nmovimi)
                                         FROM autconductores
                                        WHERE sseguro = w_ssegpol
                                          AND nriesgo = pnriesgo)
                        AND cprincipal = 1;
                     --
                  --
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        w_sperson_ant := NULL;
                        p_tab_error(f_sysdate, f_user, 'NO DATA FOUND AUTCONDUCTORES ', 505,
                                    'AUTCONDUCTORES W_SSEGPOL = ' || w_ssegpol || ' NRIESGO = '
                                    || pnriesgo,
                                    SQLERRM);
                     WHEN OTHERS THEN
                        p_tab_error(f_sysdate, f_user, 'WHEN OTHERS AUTCONDUCTORES ', 506,
                                    'AUTCONDUCTORES W_SSEGPOL = ' || w_ssegpol || ' NRIESGO = '
                                    || pnriesgo,
                                    SQLERRM);
                        w_sperson_ant := NULL;
                  END;
         */
         /* fin Bug 26923/147980 - APD - 01/07/2013*/
         /**/
         w_crespue_error := 0;

         /**/
         /* Bug 26923/147980 - APD - 01/07/2013 - en el suplemento se debe recalcular*/
         /*
                  IF w_sperson_ant IS NOT NULL
                     AND w_sperson_ant = w_spereal
                     AND pnmovimi != 1 THEN
                     -- És un suplement i no han canviat el conductor principal (No s'ha de recalcular)
                     -- i per això arrossego el valor de la pregunta en el moviment anterior.
                     -- S'ha afegit el tema de pnmovimi != 1, per que quan es guardava la pòlissa, al
                     -- tornar-la a recuperar, es creia que era un suplement i no recalculava la pregunta.
                     BEGIN
                        SELECT crespue
                          INTO w_crespue_ant
                          FROM pregunseg
                         WHERE sseguro = w_ssegpol
                           AND nriesgo = pnriesgo
                           AND cpregun = pcpregun
                           AND nmovimi = (SELECT MAX(nmovimi)
                                            FROM pregunseg
                                           WHERE sseguro = w_ssegpol
                                             AND nriesgo = pnriesgo
                                             AND cpregun = pcpregun);

                        w_torna := w_crespue_ant;
                     EXCEPTION
                        WHEN OTHERS THEN
                           p_tab_error(f_sysdate, f_user,
                                       'EXCEPTION pac_propio_albsgt_conf.f_autos_antiguedad', 4,
                                       'p_sseguro = ' || psseguro || ' pfefecto ' || pfefecto
                                       || ' nriesgo = ' || pnriesgo || ' - ptablas  ' || ptablas,
                                       SQLERRM);
                           w_torna := 0;
                           w_crespue_error := 1;
                     END;
                  --
                  ELSE
         */
         /**/
         IF w_anysantiguedad > w_exper_manual
         THEN
            w_torna := w_anysantiguedad;
         ELSE
            w_torna := w_exper_manual;
         END IF;
      /*         END IF;
      */ -- fin Bug 26923/147980 - APD - 01/07/2013
      /**/
      /* EL PTABLAS ÉS DIFERENT DE EST (Cartera o Retarificació Pólissa retinguda per PSU).*/
      ELSIF ptablas = 'CAR'
      THEN                                                   -- Es una cartera
         BEGIN
            /*  Bug 26923/147980 - APD - 01/07/2013*/
                /* Añadimos: s.fefecto , s.fcaranu*/
            SELECT s.fefecto, s.fcaranu
              INTO w_fefecto, w_fcaranu
              FROM seguros s
             WHERE s.sseguro = psseguro;
         /*  fin Bug 26923/147980 - APD - 01/07/2013*/
         /**/
         /**/
         EXCEPTION
            WHEN OTHERS
            THEN
               w_ssegpol := 0;
         END;

         BEGIN
            IF NVL (psproces, 0) != 0
            THEN
               SELECT exper_manual,          /* Bug 26638 - 14/04/2014 - AMC*/
                                   sperson
                 /* Sumem 1 per que agafem el moviment anterior a la cartera que estem fent*/
               INTO   w_exper_manual, w_sperson
                 FROM autconductorescar              /* SOBRE LAS TABLAS CAR*/
                WHERE sseguro = psseguro
                  AND nriesgo = pnriesgo
                  /* AND nmovimi = pnmovimi   --Bug 34371/197570 - 09/02/2015 - AMC*/
                  AND nmovimi IN (
                         SELECT MAX (nmovimi)
                           FROM autconductorescar
                          WHERE sseguro = psseguro
                            AND sproces = psproces
                            AND cprincipal = 1)
                  AND nriesgo = pnriesgo
                  AND cprincipal = 1
                  AND sproces = psproces;
            ELSE
               SELECT exper_manual,          /* Bug 26638 - 14/04/2014 - AMC*/
                                   sperson
                 /* Sumem 1 per que agafem el moviment anterior a la cartera que estem fent*/
               INTO   w_exper_manual, w_sperson
                 FROM autconductorescar              /* SOBRE LAS TABLAS CAR*/
                WHERE sseguro = psseguro
                  AND nriesgo = pnriesgo
                  /*AND nmovimi = pnmovimi   --Bug 34371/197570 - 09/02/2015 - AMC*/
                  AND nmovimi IN (
                         SELECT MAX (nmovimi)
                           FROM autconductorescar
                          WHERE sproces IN (SELECT MAX (sproces)
                                              FROM autconductorescar
                                             WHERE sseguro = psseguro)
                            AND sseguro = psseguro
                            AND nriesgo = pnriesgo
                            AND cprincipal = 1)
                  AND cprincipal = 1
                  AND sproces IN (SELECT MAX (sproces)
                                    FROM autconductorescar
                                   WHERE sseguro = psseguro);
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               p_tab_error (f_sysdate,
                            f_user,
                            'pac_propio_albsgt_conf.f_autos_antiguedad',
                            99,
                            w_param,
                            SQLERRM
                           );
               w_exper_manual := 1;
               w_sperson := 0;
         END;

         /*  Bug 26923/147980 - APD - 01/07/2013*/
         /* mismo codigo que en f_edad_riesgo*/
         IF pfefecto = w_fcaranu
         THEN
            /* si es cartera utilizamos la fecha de efecto (que será la fcaranu de la póliza)*/
            w_fecha := pfefecto;
         ELSE
            BEGIN
               SELECT MAX (fefecto)
                 INTO w_fecha
                 FROM movseguro
                WHERE sseguro = psseguro AND cmovseg = 2;

               IF (w_fecha IS NULL) OR (w_fecha < w_fefecto)
               THEN
                  w_fecha := w_fefecto;
               END IF;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  w_fecha := w_fefecto;
            END;
         END IF;

         /*  fin Bug 26923/147980 - APD - 01/07/2013*/
         /**/
         BEGIN
            /*  Bug 26923/147980 - APD - 01/07/2013 - se sustituye pfefecto por w_fecha*/
            /* INI Bug 36319/18921 --ECP-- 16/06/2015  se cambia  ABS(TRUNC(MONTHS_BETWEEN(TO_DATE(fantiguedad, 'YYYYMMDD'), w_fecha) / 12))por*/
            SELECT ABS (TRUNC (MONTHS_BETWEEN (fantiguedad, w_fecha) / 12))
              /* FIN Bug 36319/18921 --ECP-- 16/06/2015*/
            INTO   w_anysantiguedad
              FROM per_antiguedad
             WHERE sperson = w_sperson AND cestado = 0;
         EXCEPTION
            WHEN OTHERS
            THEN
               p_tab_error (f_sysdate,
                            f_user,
                            'pac_propio_albsgt_conf.f_autos_antiguedad',
                            100,
                               w_param
                            || ' w_fecha '
                            || w_fecha
                            || ' w_sperson '
                            || w_sperson,
                            SQLERRM
                           );
               w_anysantiguedad := 0;
         END;

         /**/
         IF w_anysantiguedad > w_exper_manual
         THEN
            w_torna := w_anysantiguedad;
         ELSE
            w_torna := w_exper_manual;
         END IF;
      /**/
      ELSE                                    /* ptablas no és ni EST ni CAR*/
                                         /*>>>>>*/
         BEGIN
            SELECT exper_manual, sperson
              INTO w_exper_manual, w_sperson
              FROM autconductores
             WHERE sseguro = psseguro
               AND nriesgo = pnriesgo
               AND nmovimi = pnmovimi
               AND cprincipal = 1;
         EXCEPTION
            WHEN OTHERS
            THEN
               w_exper_manual := 0;
               w_sperson := 0;
         END;

         /**/
         BEGIN
            SELECT ABS (TRUNC (MONTHS_BETWEEN (pfefecto, fantiguedad) / 12))
              INTO w_anysantiguedad
              FROM per_antiguedad
             WHERE sperson = w_sperson AND cestado = 0;
         EXCEPTION
            WHEN OTHERS
            THEN
               w_anysantiguedad := 0;
         END;

         /**/
         IF w_anysantiguedad > w_exper_manual
         THEN
            w_torna := w_anysantiguedad;
         ELSE
            w_torna := w_exper_manual;
         END IF;
      /**/
      END IF;

      /**/
      RETURN w_torna;
   /**/
   END;

/*------------------------------------------------------------------------*/
/*------------------------------------------------------------------------*/
/*------------------------------------------------------------------------*/
   FUNCTION f_autos_siniestros (
      ptablas     IN   VARCHAR2,
      psseguro    IN   NUMBER,
      pnriesgo    IN   NUMBER,
      pfefecto    IN   DATE,
      pnmovimi    IN   NUMBER,
      pcgarant    IN   NUMBER,
      psproces    IN   NUMBER,
      pnmovima    IN   NUMBER,
      picapital   IN   NUMBER,
      pcpregun    IN   NUMBER
   )
      RETURN NUMBER
   IS
      /**/
      w_siniestros   NUMBER                    := 0;
      w_fecmovimi    DATE;
      w_ssegpol      estseguros.ssegpol%TYPE;
   /**/
   BEGIN
      /**/
      /**/
      /* Bug 26737/142770 - 24/04/2013 - AMC - Quitamos la select*/
      /**/
          /**/
      IF ptablas = 'EST' AND pnmovimi = 0
      THEN
         w_siniestros := 0;      /* Si es una pòlissa nova, no hi ha stres.*/
      ELSIF ptablas = 'EST'
      THEN   -- Si es un Spto, arrastramos la pregunta del movimiento anterior
         BEGIN
            /* Bug 26737/142770 - 24/04/2013 - AMC*/
            SELECT crespue
              INTO w_siniestros
              FROM estpregunseg
             WHERE sseguro = psseguro
               AND nriesgo = pnriesgo
               AND cpregun = pcpregun
               AND nmovimi =
                      (SELECT MAX (nmovimi)
                         FROM estpregunseg
                        WHERE sseguro = psseguro
                          AND nriesgo = pnriesgo
                          AND cpregun = pcpregun);
         /* Fi Bug 26737/142770 - 24/04/2013 - AMC*/
         EXCEPTION
            WHEN OTHERS
            THEN
               w_siniestros := 0;
         END;
      /**/
      ELSE
         /* És una cartera*/
         /* Busquem la data en que es va fer l'última cartera anterior*/
         BEGIN
            SELECT TRUNC (a.fmovimi)
              INTO w_fecmovimi
              FROM movseguro a
             WHERE a.sseguro = psseguro
               AND a.nmovimi =
                         (SELECT MAX (b.nmovimi)
                            FROM movseguro b
                           WHERE b.sseguro = psseguro AND b.cmovseg IN (2, 0));
         /* Para igualarlo con la f_ultrenova.*/
         /*AND(cmotmov = 404*/
         /*    OR cmotmov = 100));*/
         EXCEPTION
            WHEN OTHERS
            THEN
               w_fecmovimi := TRUNC (f_sysdate);
         END;

         /**/
         SELECT COUNT (0)
           INTO w_siniestros
           FROM sin_siniestro a, sin_movsiniestro b
          WHERE a.sseguro = psseguro
            AND TRUNC (a.falta) BETWEEN w_fecmovimi AND TRUNC (f_sysdate)
            AND b.nsinies = a.nsinies
            AND b.nmovsin =
                   (SELECT MAX (c.nmovsin)
                      FROM sin_movsiniestro c
                     WHERE c.nsinies = a.nsinies
                       AND TRUNC (c.festsin) BETWEEN w_fecmovimi
                                                 AND TRUNC (f_sysdate))
            AND b.cestsin NOT IN (2, 3);
      END IF;

      /**/
      RETURN w_siniestros;
   /**/
   END;

/*------------------------------------------------------------------------*/
   FUNCTION f_copia_pregunta (
      ptablas     IN   VARCHAR2,
      psseguro    IN   NUMBER,
      pnriesgo    IN   NUMBER,
      pfefecto    IN   DATE,
      pnmovimi    IN   NUMBER,
      pcgarant    IN   NUMBER,
      psproces    IN   NUMBER,
      pnmovima    IN   NUMBER,
      picapital   IN   NUMBER,
      pcpregun    IN   NUMBER
   )
      RETURN NUMBER
   IS
      /**/
      w_torna       NUMBER                    := 0;
      w_fecmovimi   DATE;
      w_ssegpol     estseguros.ssegpol%TYPE;
   /**/
   BEGIN
      /**/
      BEGIN
         SELECT ssegpol
           INTO w_ssegpol
           FROM estseguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS
         THEN
            w_ssegpol := 0;
      END;

      /**/
      IF ptablas = 'EST' AND pnmovimi = 0
      THEN
         w_torna := NULL;
      /* Si es una pòlissa nova, no hi ha pregunta anterior.*/
      ELSIF ptablas = 'EST'
      THEN   -- Si es un Spto, arrastramos la pregunta del movimiento anterior
         BEGIN
            SELECT crespue
              INTO w_torna
              FROM pregunseg
             WHERE sseguro = w_ssegpol
               AND nriesgo = pnriesgo
               AND cpregun = pcpregun
               AND nmovimi =
                      (SELECT MAX (nmovimi)
                         FROM pregunseg
                        WHERE sseguro = w_ssegpol
                          AND nriesgo = pnriesgo
                          AND cpregun = pcpregun);
         EXCEPTION
            WHEN OTHERS
            THEN
               BEGIN
                  SELECT crespue
                    INTO w_torna
                    FROM pregunpolseg
                   WHERE sseguro = w_ssegpol
                     /*AND nriesgo = pnriesgo*/
                     AND cpregun = pcpregun
                     AND nmovimi =
                            (SELECT MAX (nmovimi)
                               FROM pregunpolseg
                              WHERE sseguro = w_ssegpol
                                                       /*AND nriesgo = pnriesgo*/
                                    AND cpregun = pcpregun);
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     BEGIN
                        SELECT crespue
                          INTO w_torna
                          FROM pregungaranseg
                         WHERE sseguro = w_ssegpol
                           AND nriesgo = pnriesgo
                           AND cpregun = pcpregun
                           AND cgarant = NVL (cgarant, 0)
                           AND nmovimi =
                                  (SELECT MAX (nmovimi)
                                     FROM pregunseg
                                    WHERE sseguro = w_ssegpol
                                      AND nriesgo = pnriesgo
                                      AND cgarant = NVL (pcgarant, 0)
                                      AND cpregun = pcpregun);
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           w_torna := NULL;
                     END;                      /* De begin de PREGUNGARANSEG*/
               END;                              /* De begin de PREGUNPOLSEG*/
         END;                                       /* De begin de PREGUNSEG*/
                                             /**/
      ELSE
         /* És una cartera*/
         w_torna := NULL;
      END IF;

      /**/
      RETURN w_torna;
   /**/
   END f_copia_pregunta;

/*------------------------------------------------------------------------*/
/*------------------------------------------------------------------------*/
   FUNCTION f_buscabonfran (
      ptablas     IN   VARCHAR2,
      psseguro    IN   NUMBER,
      pnriesgo    IN   NUMBER,
      pfefecto    IN   DATE,
      pnmovimi    IN   NUMBER,
      pcgarant    IN   NUMBER,
      psproces    IN   NUMBER,
      pnmovima    IN   NUMBER,
      picapital   IN   NUMBER,
      pcgrup      IN   NUMBER,
      pcque       IN   NUMBER
   )
      RETURN VARCHAR2
   IS
      /**/
      /* PCQUE   0 => Movimiento actual  (pregunta 4930)*/
      /*         1 => Movimiento inmediatamente anterior ( 4931)*/
      /*       404 => Movimiento inmediatamente anterior de cartera (4936)*/
      /**/
        /**/
      w_respue        VARCHAR2 (24);
      w_ssegpol       estseguros.ssegpol%TYPE;
      w_nmovimi_ant   NUMBER;
      w_nmovimi_car   NUMBER;
      vtraza          NUMBER;
   /**/
   BEGIN
      vtraza := 0;

      BEGIN
         SELECT ssegpol
           INTO w_ssegpol
           FROM estseguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS
         THEN
            w_ssegpol := NULL;
      END;

      /**/
      BEGIN
         vtraza := 1;

         SELECT MAX (nmovimi)
           INTO w_nmovimi_ant
           FROM movseguro
          WHERE sseguro = NVL (w_ssegpol, psseguro) AND nmovimi < pnmovimi;
      EXCEPTION
         WHEN OTHERS
         THEN
            w_nmovimi_ant := NULL;
      END;

      /**/
      BEGIN
         vtraza := 2;

         SELECT MAX (nmovimi)
           INTO w_nmovimi_car
           FROM movseguro
          WHERE sseguro = NVL (w_ssegpol, psseguro)
            AND cmotmov = 404
            AND cmovseg != 52                        /* Que no este anulado.*/
            AND nmovimi < pnmovimi;
      EXCEPTION
         WHEN OTHERS
         THEN
            w_nmovimi_car := NULL;
      END;

      vtraza := 3;
      p_tab_error (f_sysdate,
                   f_user,
                   'pac_propio_albsgt_conf.f_buscabonfran',
                   0,
                      ' --> psseguro= '
                   || psseguro
                   || '  ptablas'
                   || ptablas
                   || '  ptablas'
                   || ptablas
                   || '  pnriesgo'
                   || pnriesgo
                   || '  pfefecto'
                   || pfefecto
                   || '  pnmovimi'
                   || pnmovimi
                   || '  pcgarant'
                   || pcgarant
                   || '  psproces'
                   || psproces
                   || '  pnmovima'
                   || pnmovima
                   || '  picapital'
                   || picapital
                   || '  pcgrup'
                   || pcgrup
                   || '  PCQUE'
                   || pcque
                   || ' w_ssegpol= '
                   || w_ssegpol
                   || ' w_nmovimi_an= '
                   || w_nmovimi_ant
                   || ' w_nmovimi_car '
                   || w_nmovimi_car
                   || '  pcque'
                   || pcque
                   || ' ptablas '
                   || ptablas,
                   ' ENTRAMOS!!!  '
                  );

      /**/
      IF pcque = 0
      THEN                                              /* Movimiento actual*/
         vtraza := 4;

         IF ptablas = 'EST'
         THEN
            vtraza := 5;

            BEGIN
               SELECT    LPAD (cgrup, 6, 0)
                      || LPAD (cversion, 6, 0)
                      || LPAD (csubgrup, 6, 0)
                      || LPAD (cnivel, 6, 0)
                 INTO w_respue
                 FROM estbf_bonfranseg
                WHERE sseguro = psseguro
                  AND nriesgo = pnriesgo
                  AND nmovimi = pnmovimi
                  AND cgrup = pcgrup;
            EXCEPTION
               WHEN OTHERS
               THEN
                  p_tab_error (f_sysdate,
                               f_user,
                               'pac_propio_albsgt_conf.f_buscabonfran',
                               vtraza,
                                  ' --> psseguro= '
                               || psseguro
                               || '  ptablas'
                               || ptablas
                               || '  ptablas'
                               || ptablas
                               || '  pnriesgo'
                               || pnriesgo
                               || '  pfefecto'
                               || pfefecto
                               || '  pnmovimi'
                               || pnmovimi
                               || '  pcgarant'
                               || pcgarant
                               || '  psproces'
                               || psproces
                               || '  pnmovima'
                               || pnmovima
                               || '  picapital'
                               || picapital
                               || '  pcgrup'
                               || pcgrup
                               || '  pcque'
                               || pcque
                               || ' w_ssegpol= '
                               || w_ssegpol
                               || ' w_nmovimi_an= '
                               || w_nmovimi_ant
                               || ' w_nmovimi_car '
                               || w_nmovimi_car
                               || '  pcque'
                               || pcque
                               || ' ptablas '
                               || ptablas,
                               'Error = ' || SQLERRM
                              );
                  w_respue := '999999888888777777666666';
            END;
         /*Bug 26638/161264 - 09/04/2014 - AMC*/
         ELSIF ptablas = 'CAR'
         THEN
            vtraza := 6;

            BEGIN
               SELECT    LPAD (cgrup, 6, 0)
                      || LPAD (cversion, 6, 0)
                      || LPAD (csubgrup, 6, 0)
                      || LPAD (cnivel, 6, 0)
                 INTO w_respue
                 FROM bf_bonfransegcar
                WHERE sproces = psproces
                  AND sseguro = psseguro
                  AND nriesgo = pnriesgo
                  AND nmovimi IN (
                         SELECT MAX (nmovimi)
                           FROM bf_bonfransegcar
                          WHERE sproces = psproces
                            AND sseguro = psseguro
                            AND nriesgo = pnriesgo
                            AND cgrup = pcgrup)
                  AND cgrup = pcgrup;
            EXCEPTION
               WHEN OTHERS
               THEN
                  p_tab_error (f_sysdate,
                               f_user,
                               'pac_propio_albsgt_conf.f_buscabonfran',
                               vtraza,
                                  ' --> psseguro= '
                               || psseguro
                               || '  ptablas'
                               || ptablas
                               || '  ptablas'
                               || ptablas
                               || '  pnriesgo'
                               || pnriesgo
                               || '  pfefecto'
                               || pfefecto
                               || '  pnmovimi'
                               || pnmovimi
                               || '  pcgarant'
                               || pcgarant
                               || '  psproces'
                               || psproces
                               || '  pnmovima'
                               || pnmovima
                               || '  picapital'
                               || picapital
                               || '  pcgrup'
                               || pcgrup
                               || '  pcque'
                               || pcque
                               || ' w_ssegpol= '
                               || w_ssegpol
                               || ' w_nmovimi_an= '
                               || w_nmovimi_ant
                               || ' w_nmovimi_car '
                               || w_nmovimi_car
                               || '  pcque'
                               || pcque
                               || ' ptablas '
                               || ptablas,
                               'Error = ' || SQLERRM
                              );
                  w_respue := '999999888888777777666666';
            END;
         ELSE
            vtraza := 7;

            /* Bug 32009/0188167 - APD - 25/09/2014 - se sustituye NVL(w_ssegpol, psseguro) por*/
            /* psseguro ya que se puede dar el caso que existe el mismo sseguro en las tablas*/
            /* Reales y en las tablas EST. Ademas aqui no tiene sentido ir por w_ssegpol ya que*/
            /* se esta en las ptablas REALES por lo que el psseguro que le llega ya es el de*/
              /* las tablas REALES*/
            BEGIN
               SELECT    LPAD (cgrup, 6, 0)
                      || LPAD (cversion, 6, 0)
                      || LPAD (csubgrup, 6, 0)
                      || LPAD (cnivel, 6, 0)
                 INTO w_respue
                 FROM bf_bonfranseg
                WHERE sseguro = psseguro          /*NVL(w_ssegpol, psseguro)*/
                  AND nriesgo = pnriesgo
                  AND nmovimi = pnmovimi
                  AND cgrup = pcgrup;
            EXCEPTION
               WHEN OTHERS
               THEN
                  p_tab_error (f_sysdate,
                               f_user,
                               'pac_propio_albsgt_conf.f_buscabonfran',
                               vtraza,
                                  ' --> psseguro= '
                               || psseguro
                               || '  ptablas'
                               || ptablas
                               || '  ptablas'
                               || ptablas
                               || '  pnriesgo'
                               || pnriesgo
                               || '  pfefecto'
                               || pfefecto
                               || '  pnmovimi'
                               || pnmovimi
                               || '  pcgarant'
                               || pcgarant
                               || '  psproces'
                               || psproces
                               || '  pnmovima'
                               || pnmovima
                               || '  picapital'
                               || picapital
                               || '  pcgrup'
                               || pcgrup
                               || '  pcque'
                               || pcque
                               || ' w_ssegpol= '
                               || w_ssegpol
                               || ' w_nmovimi_an= '
                               || w_nmovimi_ant
                               || ' w_nmovimi_car '
                               || w_nmovimi_car
                               || '  pcque'
                               || pcque
                               || ' ptablas '
                               || ptablas,
                               'Error = ' || SQLERRM
                              );
                  w_respue := '999999888888777777666666';
            END;
         /* fin Bug 32009/0188167 - APD - 25/09/2014*/
         END IF;                                      -- DE IF PTABLAS = 'EST'

         /**/
         vtraza := 8;
      ELSIF pcque = 2
      THEN
         /* Movimiento inmediatamente anterior --< No hay que ir a las CAR !!*/
         vtraza := 9;
         /*Bug 26638/161264 - 09/04/2014 - AMC*/
         /*         IF ptablas = 'CAR' THEN*/
         /**/
         /*            -- Si estamos en cartera*/
         /*            vtraza := 10;*/
         /*            BEGIN*/
         /*               SELECT LPAD(cgrup, 6, 0) || LPAD(cversion, 6, 0) || LPAD(csubgrup, 6, 0)*/
         /*                      || LPAD(cnivel, 6, 0)*/
         /*                 INTO w_respue*/
         /*                 FROM bf_bonfransegcar*/
         /*                WHERE sproces = psproces*/
         /*                  AND sseguro = psseguro*/
         /*                  AND nriesgo = pnriesgo*/
         /*                  AND nmovimi IN(SELECT MAX(nmovimi)*/
         /*                                   FROM bf_bonfransegcar*/
         /*                                  WHERE sproces = psproces*/
         /*                                    AND sseguro = psseguro*/
         /*                                    AND nriesgo = pnriesgo*/
         /*                                    AND cgrup = pcgrup)*/
         /*                  AND sseguro = psseguro*/
         /*                  AND nriesgo = pnriesgo*/
         /*                  AND cgrup = pcgrup;*/
         /*            EXCEPTION*/
         /*               WHEN OTHERS THEN*/
         /*                  p_tab_error(f_sysdate, f_user, 'pac_propio_albsgt_conf.f_buscabonfran',*/
         /*                              vtraza,*/
         /*                              ' --> psseguro= ' || psseguro || '  ptablas' || ptablas*/
         /*                              || '  ptablas' || ptablas || '  pnriesgo' || pnriesgo*/
         /*                              || '  pfefecto' || pfefecto || '  pnmovimi' || pnmovimi*/
         /*                              || '  pcgarant' || pcgarant || '  psproces' || psproces*/
         /*                              || '  pnmovima' || pnmovima || '  picapital' || picapital*/
         /*                              || '  pcgrup' || pcgrup || '  pcque' || pcque || ' w_ssegpol= '*/
         /*                              || w_ssegpol || ' w_nmovimi_an= ' || w_nmovimi_ant*/
         /*                              || ' w_nmovimi_car ' || w_nmovimi_car || '  pcque' || pcque*/
         /*                              || ' ptablas ' || ptablas,*/
         /*                              'Error = ' || SQLERRM);*/
         /*                  w_respue := '999999888888777777666666';*/
         /*            END;*/
           /*         ELSE*/
         vtraza := 11;

         BEGIN
            SELECT    LPAD (cgrup, 6, 0)
                   || LPAD (cversion, 6, 0)
                   || LPAD (csubgrup, 6, 0)
                   || LPAD (cnivel, 6, 0)
              INTO w_respue
              FROM bf_bonfranseg
             WHERE sseguro = NVL (w_ssegpol, psseguro)
               AND nriesgo = pnriesgo
               AND nmovimi = NVL (w_nmovimi_ant, 9999)
               AND cgrup = pcgrup;
         EXCEPTION
            WHEN OTHERS
            THEN
               p_tab_error (f_sysdate,
                            f_user,
                            'pac_propio_albsgt_conf.f_buscabonfran',
                            vtraza,
                               ' --> psseguro= '
                            || psseguro
                            || '  ptablas'
                            || ptablas
                            || '  ptablas'
                            || ptablas
                            || '  pnriesgo'
                            || pnriesgo
                            || '  pfefecto'
                            || pfefecto
                            || '  pnmovimi'
                            || pnmovimi
                            || '  pcgarant'
                            || pcgarant
                            || '  psproces'
                            || psproces
                            || '  pnmovima'
                            || pnmovima
                            || '  picapital'
                            || picapital
                            || '  pcgrup'
                            || pcgrup
                            || '  pcque'
                            || pcque
                            || ' w_ssegpol= '
                            || w_ssegpol
                            || ' w_nmovimi_an= '
                            || w_nmovimi_ant
                            || ' w_nmovimi_car '
                            || w_nmovimi_car
                            || '  pcque'
                            || pcque
                            || ' ptablas '
                            || ptablas,
                            'Error = ' || SQLERRM
                           );
               w_respue := '999999888888777777666666';
         END;
      /*       END IF;*/
      ELSE
         /*Movimiento de cartera anteriro pcque = 404 No hay que ir a las car!!!!!!*/
         vtraza := 12;
         /*         IF ptablas = 'CAR' THEN*/
         /*            vtraza := 13;*/
         /*            BEGIN*/
         /*               SELECT LPAD(cgrup, 6, 0) || LPAD(cversion, 6, 0) || LPAD(csubgrup, 6, 0)*/
         /*                      || LPAD(cnivel, 6, 0)*/
         /*                 INTO w_respue*/
         /*                 FROM bf_bonfransegcar*/
         /*                WHERE sproces = psproces*/
         /*                  AND sseguro = psseguro*/
         /*                  AND nriesgo = pnriesgo*/
         /*                  AND nmovimi IN(SELECT MAX(nmovimi)*/
         /*                                   FROM bf_bonfransegcar*/
         /*                                  WHERE sproces = psproces*/
         /*                                    AND sseguro = psseguro*/
         /*                                    AND nriesgo = pnriesgo*/
         /*                                    AND cgrup = pcgrup)*/
         /*                  AND cgrup = pcgrup;*/
         /*            EXCEPTION*/
         /*               WHEN OTHERS THEN*/
         /*                  p_tab_error(f_sysdate, f_user, 'pac_propio_albsgt_conf.f_buscabonfran',*/
         /*                              vtraza,*/
         /*                              ' --> psseguro= ' || psseguro || '  ptablas' || ptablas*/
         /*                              || '  ptablas' || ptablas || '  pnriesgo' || pnriesgo*/
         /*                              || '  pfefecto' || pfefecto || '  pnmovimi' || pnmovimi*/
         /*                              || '  pcgarant' || pcgarant || '  psproces' || psproces*/
         /*                              || '  pnmovima' || pnmovima || '  picapital' || picapital*/
         /*                              || '  pcgrup' || pcgrup || '  pcque' || pcque || ' w_ssegpol= '*/
         /*                              || w_ssegpol || ' w_nmovimi_an= ' || w_nmovimi_ant*/
         /*                              || ' w_nmovimi_car ' || w_nmovimi_car || '  pcque' || pcque*/
         /*                              || ' ptablas ' || ptablas,*/
         /*                              'Error = ' || SQLERRM);*/
         /*                  w_respue := '999999888888777777666666';*/
         /*            END;*/
           /*         ELSE*/
         vtraza := 14;

         BEGIN
            SELECT    LPAD (cgrup, 6, 0)
                   || LPAD (cversion, 6, 0)
                   || LPAD (csubgrup, 6, 0)
                   || LPAD (cnivel, 6, 0)
              INTO w_respue
              FROM bf_bonfranseg
             WHERE sseguro = NVL (w_ssegpol, psseguro)
               AND nriesgo = pnriesgo
               /* Bug 36436/208071 - 25/06/2015*/
               /* AND nmovimi = NVL(w_nmovimi_car, 9999)*/
               AND nmovimi =
                      (SELECT MAX (nmovimi)
                         FROM bf_bonfranseg
                        WHERE sseguro = NVL (w_ssegpol, psseguro)
                          AND nriesgo = pnriesgo)
               AND cgrup = pcgrup;
         EXCEPTION
            WHEN OTHERS
            THEN
               p_tab_error (f_sysdate,
                            f_user,
                            'pac_propio_albsgt_conf.f_buscabonfran',
                            vtraza,
                               ' --> psseguro= '
                            || psseguro
                            || '  ptablas'
                            || ptablas
                            || '  ptablas'
                            || ptablas
                            || '  pnriesgo'
                            || pnriesgo
                            || '  pfefecto'
                            || pfefecto
                            || '  pnmovimi'
                            || pnmovimi
                            || '  pcgarant'
                            || pcgarant
                            || '  psproces'
                            || psproces
                            || '  pnmovima'
                            || pnmovima
                            || '  picapital'
                            || picapital
                            || '  pcgrup'
                            || pcgrup
                            || '  pcque'
                            || pcque
                            || ' w_ssegpol= '
                            || w_ssegpol
                            || ' w_nmovimi_an= '
                            || w_nmovimi_ant
                            || ' w_nmovimi_car '
                            || w_nmovimi_car
                            || '  pcque'
                            || pcque
                            || ' ptablas '
                            || ptablas,
                            'Error = ' || SQLERRM
                           );
               w_respue := '999999888888777777666666';
         END;
      /*         END IF;*/
      END IF;

      vtraza := 99;
      /**/
      RETURN w_respue;
   /**/
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_propio_albsgt_conf.f_buscabonfran',
                      vtraza,
                         ' --> psseguro= '
                      || psseguro
                      || '  ptablas'
                      || ptablas
                      || '  ptablas'
                      || ptablas
                      || '  pnriesgo'
                      || pnriesgo
                      || '  pfefecto'
                      || pfefecto
                      || '  pnmovimi'
                      || pnmovimi
                      || '  pcgarant'
                      || pcgarant
                      || '  psproces'
                      || psproces
                      || '  pnmovima'
                      || pnmovima
                      || '  picapital'
                      || picapital
                      || '  pcgrup'
                      || pcgrup
                      || '  pcque'
                      || pcque
                      || ' w_ssegpol= '
                      || w_ssegpol
                      || ' w_nmovimi_an= '
                      || w_nmovimi_ant
                      || ' w_nmovimi_car '
                      || w_nmovimi_car
                      || '  pcque'
                      || pcque
                      || ' ptablas '
                      || ptablas,
                      'Error = ' || SQLERRM
                     );
   END f_buscabonfran;

/*------------------------------------------------------------------------*/
   FUNCTION f_autos_continuidad (
      ptablas     IN   VARCHAR2,
      psseguro    IN   NUMBER,
      pnriesgo    IN   NUMBER,
      pfefecto    IN   DATE,
      pnmovimi    IN   NUMBER,
      pcgarant    IN   NUMBER,
      psproces    IN   NUMBER,
      pnmovima    IN   NUMBER,
      picapital   IN   NUMBER,
      pcpregun    IN   NUMBER
   )
      RETURN VARCHAR2
   IS
      w_exper_manual     autconductores.exper_manual%TYPE;
      w_sperson          autconductores.sperson%TYPE;
      w_anysantiguedad   NUMBER;
      w_torna            VARCHAR2 (500);
      w_sperson_ant      autconductores.sperson%TYPE;
      /* SPERSON REAL del Conductor del Movimiento Anterior*/
      w_crespue_ant      pregunseg.crespue%TYPE;
      w_crespue_error    NUMBER;
      /**/
      w_spereal          estper_personas.spereal%TYPE;
      /* SPERSON REAL CONDUCTOR para acceder a las tablas REALES*/
      w_ssegpol          estseguros.ssegpol%TYPE;
                           /* SSEGURO REAL para acceder a las tablas REALES*/
/**/
/**/
      w_ciaant           NUMBER;
      w_ffinciant        DATE;
      vflanzam           DATE;
      w_fefecto          DATE;
      w_cversion         NUMBER;
      w_anyo             NUMBER;
      vcont              NUMBER;
      w_cmatric          VARCHAR2 (100);
   BEGIN
      /**/
      w_torna := 0;
      p_tab_error (f_sysdate,
                   f_user,
                   'EXCEPTION pac_propio_albsgt_conf.f_autos_continuidad',
                   526,
                      'NO SSEGPOL p_sseguro = '
                   || psseguro
                   || ' pfefecto '
                   || pfefecto
                   || ' nriesgo = '
                   || pnriesgo
                   || ' - ptablas  '
                   || ptablas,
                   SQLERRM
                  );

      /**/
      IF ptablas = 'EST'
      THEN
         /**/
         BEGIN
            SELECT ssegpol, NVL (pfefecto, fefecto)
              INTO w_ssegpol, w_fefecto
              FROM estseguros
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS
            THEN
               w_ssegpol := 0;
         END;

         /**/
         BEGIN
            SELECT ciaant, ffinciant, cversion, anyo
              INTO w_ciaant, w_ffinciant, w_cversion, w_anyo
              FROM estautriesgos
             WHERE sseguro = psseguro
               AND nriesgo = pnriesgo
               AND nmovimi = pnmovimi;
         EXCEPTION
            WHEN OTHERS
            THEN
               w_ciaant := NULL;
               w_ffinciant := f_sysdate;
         END;

         p_tab_error (f_sysdate,
                      f_user,
                      'EXCEPTION pac_propio_albsgt_conf.f_autos_continuidad',
                      526,
                         'NO SSEGPOL  w_ciaant = '
                      || w_ciaant
                      || ' w_ffinciant '
                      || w_ffinciant
                      || ' w_cversion = '
                      || w_cversion
                      || ' - w_anyo  '
                      || w_anyo,
                      SQLERRM
                     );

         IF pcpregun = 4013
         THEN
            w_torna := TO_CHAR (w_ffinciant, 'DDMMYYYY');
         ELSIF pcpregun = 4060
         THEN
            w_torna := w_ciaant;
         ELSIF pcpregun = 4010
         THEN
            BEGIN
               IF     w_anyo IS NOT NULL
                  AND (   (TO_NUMBER (TO_CHAR (f_sysdate, 'YYYY')) - w_anyo <=
                                                                             6
                          )
                       OR w_ciaant IN (1, 2)
                      )
                  AND (    (   (w_fefecto = w_ffinciant)
                            OR (    w_ffinciant > f_sysdate
                                AND   TO_NUMBER (TO_CHAR (w_ffinciant,
                                                          'YYYYMMDD'
                                                         )
                                                )
                                    - TO_NUMBER (TO_CHAR (w_fefecto,
                                                          'YYYYMMDD'
                                                         )
                                                ) < 30
                               )
                           )
                       AND w_fefecto >= f_sysdate
                      )
               THEN
                  w_torna := 1;
               ELSE
                  w_torna := 0;
               END IF;
            EXCEPTION
               WHEN OTHERS
               THEN
                  w_torna := 0;
            END;
         END IF;
      ELSE
         /*------------- Tema de Cartera que está a la espera de saber si trabajaremos con tablas CAR.*/
         BEGIN
            SELECT NVL (pfefecto, fefecto)
              INTO w_fefecto
              FROM seguros
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS
            THEN
               p_tab_error
                     (f_sysdate,
                      f_user,
                      'EXCEPTION pac_propio_albsgt_conf.f_autos_continuidad',
                      526,
                         'NO SSEGPOL p_sseguro = '
                      || psseguro
                      || ' pfefecto '
                      || pfefecto
                      || ' nriesgo = '
                      || pnriesgo
                      || ' - ptablas  '
                      || ptablas,
                      SQLERRM
                     );
         END;

         /**/
         BEGIN
            SELECT ciaant, ffinciant, cversion, anyo, cmatric
              INTO w_ciaant, w_ffinciant, w_cversion, w_anyo, w_cmatric
              FROM autriesgos
             WHERE sseguro = psseguro
               AND nriesgo = pnriesgo
               AND nmovimi = pnmovimi;
         EXCEPTION
            WHEN OTHERS
            THEN
               w_ciaant := NULL;
               w_ffinciant := f_sysdate;
         END;

         IF pcpregun = 4013
         THEN
            w_torna := TO_CHAR (w_ffinciant, 'DDMMYYYY');
         ELSIF pcpregun = 4060
         THEN
            w_torna := w_ciaant;
         ELSE
            SELECT COUNT (1)
              INTO vcont
              FROM aut_mig_matriculas
             WHERE cmatric = w_cmatric;

            BEGIN
               IF     w_anyo IS NOT NULL
                  AND (   (TO_NUMBER (TO_CHAR (f_sysdate, 'YYYY')) - w_anyo <=
                                                                             6
                          )
                       OR vcont > 0
                      )
                  AND (    (   (w_fefecto = w_ffinciant)
                            OR (    w_ffinciant > f_sysdate
                                AND   TO_NUMBER (TO_CHAR (w_ffinciant,
                                                          'YYYYMMDD'
                                                         )
                                                )
                                    - TO_NUMBER (TO_CHAR (w_fefecto,
                                                          'YYYYMMDD'
                                                         )
                                                ) < 30
                               )
                           )
                       AND w_fefecto >= f_sysdate
                      )
               THEN
                  w_torna := 1;
               ELSE
                  w_torna := 0;
               END IF;
            EXCEPTION
               WHEN OTHERS
               THEN
                  w_torna := 0;
            END;
         END IF;
      /**/
      END IF;

      p_tab_error (f_sysdate,
                   f_user,
                   'EXCEPTION pac_propio_albsgt_conf.f_autos_continuidad',
                   526,
                   ' pcpregun = ' || pcpregun || ' - w_torna  ' || w_torna,
                   SQLERRM
                  );
      /**/
      RETURN w_torna;
   /**/
   END f_autos_continuidad;

/*------------------------------------------------------------------------*/
   FUNCTION f_sucursal (
      ptablas     IN   VARCHAR2,
      psseguro    IN   NUMBER,
      pnriesgo    IN   NUMBER,
      pfefecto    IN   DATE,
      pnmovimi    IN   NUMBER,
      pcgarant    IN   NUMBER,
      psproces    IN   NUMBER,
      pnmovima    IN   NUMBER,
      picapital   IN   NUMBER,
      pcpregun    IN   NUMBER
   )
      RETURN NUMBER
   IS
      /**/
      w_fefecto    seguros.fefecto%TYPE;
      w_cagente    seguros.cagente%TYPE;
      w_cempres    seguros.cempres%TYPE;
      w_error      NUMBER;
      w_sucursal   NUMBER;
      w_ctipage    NUMBER                 := 2;                /*> Sucursal*/
      w_ctipage2   NUMBER                 := 3;
                           /*>  ADN*/
   /* Buscamos primero la sucursal y si no encuentra buscamos el ADn */
   /**/
   BEGIN
      /**/
      w_error := 0;

      /**/
      IF ptablas = 'EST'
      THEN
         /* Bug 26923/146905 - APD - 27/06/2013 - se añade el IF pnmovimi = 1*/
         IF pnmovimi = 1
         THEN
            /* Estamos en nueva produccion*/
            /**/
            BEGIN
               SELECT cagente, NVL (pfefecto, fefecto), cempres
                 INTO w_cagente, w_fefecto, w_cempres
                 FROM estseguros
                WHERE sseguro = psseguro;
            EXCEPTION
               WHEN OTHERS
               THEN
                  w_cagente := 0;
                  w_fefecto := NULL;
                  w_cempres := NULL;
            END;
         /* Bug 26923/146905 - APD - 27/06/2013 - se añade el ELSE*/
         ELSE
            /* Estamos en suplementos*/
            w_error :=
               pac_preguntas.f_get_pregunseg (psseguro,
                                              pnriesgo,
                                              pcpregun,
                                              ptablas,
                                              w_sucursal
                                             );

            IF w_error <> 0
            THEN
               p_tab_error (f_sysdate,
                            f_user,
                            'EXCEPTION pac_propio_albsgt_conf.f_sucursal',
                            527,
                               'NO EN PREGUNSEG p_sseguro = '
                            || psseguro
                            || ' pfefecto '
                            || pfefecto
                            || ' nriesgo = '
                            || pnriesgo
                            || ' - ptablas  '
                            || ptablas
                            || ' pcpregun = '
                            || pcpregun,
                            SQLERRM
                           );
               RETURN NULL;
            END IF;
         END IF;
      /* fin Bug 26923/146905 - APD - 27/06/2013*/
      /**/
      ELSE
         /**/
         BEGIN
            SELECT cagente, NVL (pfefecto, fefecto), cempres
              INTO w_cagente, w_fefecto, w_cempres
              FROM seguros
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS
            THEN
               w_cagente := 0;
               w_fefecto := NULL;
               w_cempres := NULL;
         END;
      /**/
      END IF;

      /**/
      /* Bug 26923/146905 - APD - 27/06/2013 - se añade el IF w_sucursal IS NULL*/
      /* buscamos el padre de tipo Sucursal*/
      IF w_sucursal IS NULL
      THEN
         w_error :=
            f_buscapadre (w_cempres,
                          w_cagente,
                          w_ctipage,
                          w_fefecto,
                          w_sucursal
                         );

         IF w_sucursal IS NULL
         THEN
            w_sucursal := 0;
         END IF;
      END IF;

      /**/
      /* Buscamos el tipo ADN*/
      IF w_sucursal = 0
      THEN
         w_error :=
            f_buscapadre (w_cempres,
                          w_cagente,
                          w_ctipage2,
                          w_fefecto,
                          w_sucursal
                         );

         /**/
         IF w_sucursal IS NULL
         THEN
            w_sucursal := 0;
         END IF;
      END IF;

      /**/
      RETURN w_sucursal;
   /**/
   END f_sucursal;

/*------------------------------------------------------------------------*/
   FUNCTION f_factor_disposi (
      ptablas      IN   VARCHAR2,
      psseguro     IN   NUMBER,
      pnriesgo     IN   NUMBER,
      pfefecto     IN   DATE,
      pnmovimi     IN   NUMBER,
      pcgarant     IN   NUMBER,
      psproces     IN   NUMBER,
      pnmovima     IN   NUMBER,
      picapital    IN   NUMBER,
      /* 0028041/0152073 - JSV 03/09/2013*/
      pcsubtabla   IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      /**/
      w_fefecto   seguros.fefecto%TYPE;
      w_sproduc   seguros.sproduc%TYPE;
      w_factor    NUMBER;

      /**/
      CURSOR c_estautdisriesgos
      IS
         SELECT *
           FROM estautdisriesgos
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND nmovimi = pnmovimi;

      /**/
      CURSOR c_autdisriesgos
      IS
         SELECT *
           FROM autdisriesgos
          WHERE sseguro = psseguro AND nriesgo = pnriesgo
                AND nmovimi = pnmovimi;
   /**/
   BEGIN
      /**/
      IF ptablas = 'EST'
      THEN
         /**/
         BEGIN
            SELECT sproduc
              INTO w_sproduc
              FROM estseguros
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS
            THEN
               w_sproduc := NULL;
         END;

         /**/
         w_factor := 1;

         FOR reg IN c_estautdisriesgos
         LOOP
            /**/
            IF reg.cpropdisp = '1'
            THEN
               w_factor :=
                    w_factor
                  * NVL
                       (pac_subtablas.f_vsubtabla (NULL,
                                                   /* 0028041/0152073 - JSV 03/09/2013 - INI*/
                                                   /*60319997,*/
                                                   NVL (pcsubtabla, 60319997),
                                                   3333,
                                                   1,
                                                   w_sproduc,
                                                   17,
                                                   pcgarant,
                                                   TO_NUMBER (reg.cdispositivo)
                                                  ),
                        1
                       );
            ELSE
               w_factor :=
                    w_factor
                  * NVL
                       (pac_subtablas.f_vsubtabla (NULL,
                                                   /* 0028041/0152073 - JSV 03/09/2013 - INI*/
                                                   /*60319997,*/
                                                   NVL (pcsubtabla, 60319997),
                                                   3333,
                                                   2,
                                                   w_sproduc,
                                                   17,
                                                   pcgarant,
                                                   TO_NUMBER (reg.cdispositivo)
                                                  ),
                        1
                       );
            END IF;
         /**/
         END LOOP;
      /**/
      ELSE
         /**/
         BEGIN
            SELECT sproduc
              INTO w_sproduc
              FROM seguros
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS
            THEN
               w_sproduc := NULL;
         END;

         /**/
         w_factor := 1;

         FOR reg IN c_autdisriesgos
         LOOP
            /**/
            IF reg.cpropdisp = '1'
            THEN
               w_factor :=
                    w_factor
                  * NVL (pac_subtablas.f_vsubtabla (NULL,
                                                    /* 0028041/0152073 - JSV 03/09/2013 - INI*/
                                                    /*60319997,*/
                                                    NVL (pcsubtabla, 60319997),
                                                    3333,
                                                    1,
                                                    w_sproduc,
                                                    17,
                                                    pcgarant,
                                                    reg.cdispositivo
                                                   ),
                         1
                        );
            ELSE
               w_factor :=
                    w_factor
                  * NVL (pac_subtablas.f_vsubtabla (NULL,
                                                    /* 0028041/0152073 - JSV 03/09/2013 - INI*/
                                                    /*60319997,*/
                                                    NVL (pcsubtabla, 60319997),
                                                    3333,
                                                    2,
                                                    w_sproduc,
                                                    17,
                                                    pcgarant,
                                                    reg.cdispositivo
                                                   ),
                         1
                        );
            END IF;
         /**/
         END LOOP;
      /**/
      END IF;

      /**/
      RETURN w_factor;
   /**/
   END f_factor_disposi;

/*------------------------------------------------------------------------*/
   FUNCTION f_factor_deduci (
      ptablas      IN   VARCHAR2,
      psseguro     IN   NUMBER,
      pnriesgo     IN   NUMBER,
      pfefecto     IN   DATE,
      pnmovimi     IN   NUMBER,
      pcgarant     IN   NUMBER,
      psproces     IN   NUMBER,
      pnmovima     IN   NUMBER,
      picapital    IN   NUMBER,
      /* 0028041/0152073 - JSV 03/09/2013*/
      pcsubtabla   IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      /**/
      w_fefecto   seguros.fefecto%TYPE;
      w_sproduc   seguros.sproduc%TYPE;
      w_factor    NUMBER;

      /**/
      CURSOR c_estbf
      IS
         SELECT a.*
           FROM estbf_bonfranseg a
          WHERE a.sseguro = psseguro
            AND a.nriesgo = pnriesgo
            AND a.nmovimi = pnmovimi
            AND a.cgrup IN (
                   SELECT b.codgrup
                     FROM bf_progarangrup b, bf_codgrup c
                    WHERE b.cempres = 12
                      AND b.sproduc = w_sproduc
                      AND b.cgarant = pcgarant
                      AND c.cempres = 12
                      AND c.cgrup = a.cgrup
                      AND c.ctipgrup = 2);

      /*
            CURSOR c_estbf IS
               SELECT *
                 FROM estbf_bonfranseg
                WHERE sseguro = psseguro
                  AND nriesgo = pnriesgo
                  AND nmovimi = pnmovimi;
      */
      /**/
      CURSOR c_bf
      IS
         SELECT a.*
           FROM bf_bonfranseg a
          WHERE a.sseguro = psseguro
            AND a.nriesgo = pnriesgo
            AND a.nmovimi = pnmovimi
            AND a.cgrup IN (
                   SELECT b.codgrup
                     FROM bf_progarangrup b, bf_codgrup c
                    WHERE b.cempres = 12
                      AND b.sproduc = w_sproduc
                      AND b.cgarant = pcgarant
                      AND c.cempres = 12
                      AND c.cgrup = a.cgrup
                      AND c.ctipgrup = 2);
   /*
         CURSOR c_bf IS
            SELECT *
              FROM bf_bonfranseg
             WHERE sseguro = psseguro
               AND nriesgo = pnriesgo
               AND nmovimi = pnmovimi;
   */
   /**/
   BEGIN
      /**/
      IF ptablas = 'EST'
      THEN
         /**/
         BEGIN
            SELECT sproduc
              INTO w_sproduc
              FROM estseguros
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS
            THEN
               w_sproduc := NULL;
         END;

         /**/
         w_factor := 1;

         FOR reg IN c_estbf
         LOOP
            /**/
            w_factor :=
                 w_factor
               * NVL (pac_subtablas.f_vsubtabla (NULL,
                                                 /* 0028041/0152073 - JSV 03/09/2013 - INI*/
                                                 /*60319997,*/
                                                 NVL (pcsubtabla, 60319997),
                                                 /* 0028041/0152073 - JSV 03/09/2013 - FIN*/
                                                 3333333,
                                                 1,
                                                 w_sproduc,
                                                 18,
                                                 pcgarant,
                                                 reg.cgrup,
                                                 reg.csubgrup,
                                                 reg.cversion,
                                                 reg.cnivel
                                                ),
                      1
                     );
         /**/
         END LOOP;
      /**/
      ELSE
         /**/
         BEGIN
            SELECT sproduc
              INTO w_sproduc
              FROM seguros
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS
            THEN
               w_sproduc := NULL;
         END;

         /**/
         w_factor := 1;

         FOR reg IN c_bf
         LOOP
            /**/
            w_factor :=
                 w_factor
               * NVL (pac_subtablas.f_vsubtabla (NULL,
                                                 /* 0028041/0152073 - JSV 03/09/2013 - INI*/
                                                 /*60319997,*/
                                                 NVL (pcsubtabla, 60319997),
                                                 3333333,
                                                 1,
                                                 w_sproduc,
                                                 18,
                                                 pcgarant,
                                                 reg.cgrup,
                                                 reg.csubgrup,
                                                 reg.cversion,
                                                 reg.cnivel
                                                ),
                      1
                     );
         /**/
         END LOOP;
      /**/
      END IF;

      /**/
      RETURN w_factor;
   /**/
   END f_factor_deduci;

/*------------------------------------------------------------------------*/
   FUNCTION f_max_subtab (pcempres IN NUMBER)
      RETURN NUMBER
   IS
      /**/
      w_torna   NUMBER;
   /**/
   BEGIN
      w_torna := 0;

      /**/
      BEGIN
         SELECT MAX (sdetalle)
           INTO w_torna
           FROM sgt_subtabs_det
          WHERE cempres = pcempres;

         /**/
         w_torna := w_torna + 1;
      /**/
      EXCEPTION
         WHEN OTHERS
         THEN
            w_torna := 0;
            p_tab_error (f_sysdate,
                         f_user,
                         'EXCEPTION pac_propio_albsgt_conf.f_max_subtab',
                         50,
                         'NO MAX EN SGTSUBTABS pcempres = ' || pcempres,
                         SQLERRM
                        );
      END;

      RETURN w_torna;
   END f_max_subtab;

/*------------------------------------------------------------------------*/
/* BUG 26643 SPRODUC 10/04/2013  per que cridi F_AUTOS_ANTIGUEDAD*/
/* Tema de que el TERMINO es de 30 DÍGITS només.*/
/*------------------------------------------------------------------------*/
   FUNCTION fant (
      ptablas     IN   VARCHAR2,
      psseguro    IN   NUMBER,
      pnriesgo    IN   NUMBER,
      pfefecto    IN   DATE,
      pnmovimi    IN   NUMBER,
      pcgarant    IN   NUMBER,
      psproces    IN   NUMBER,
      pnmovima    IN   NUMBER,
      picapital   IN   NUMBER,
      pcpregun    IN   NUMBER
   )
      RETURN NUMBER
   IS
      w_torna   NUMBER;
   BEGIN
      w_torna :=
         f_autos_antiguedad (ptablas,
                             psseguro,
                             pnriesgo,
                             pfefecto,
                             pnmovimi,
                             pcgarant,
                             psproces,
                             pnmovima,
                             picapital,
                             pcpregun
                            );
      RETURN w_torna;
   END;

/*------------------------------------------------------------------------*/
/* Bug 26662 - APD - 11/04/2013 -se crea la funcion*/
   FUNCTION f_garant_planbenef (
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
      /**/
      vparam     VARCHAR2 (2000)
         :=    'ptablas = '
            || ptablas
            || ' - psseguro '
            || psseguro
            || ' - pnriesgo = '
            || pnriesgo
            || ' - pfefecto  '
            || pfefecto
            || ' - pnmovimi  '
            || pnmovimi
            || ' - pcgarant  '
            || pcgarant
            || ' - psproces  '
            || psproces
            || ' - pnmovima  '
            || pnmovima
            || ' - picapital  '
            || picapital;
      vcplan     codplanbenef.cplan%TYPE;
      vcempres   NUMBER;
      vtraza     NUMBER;
   BEGIN
      vtraza := 1;

      IF ptablas = 'EST'
      THEN
         vtraza := 2;

         SELECT cempres
           INTO vcempres
           FROM estseguros
          WHERE sseguro = psseguro;
      ELSE
         vtraza := 3;

         SELECT cempres
           INTO vcempres
           FROM seguros
          WHERE sseguro = psseguro;
      END IF;

      vtraza := 4;
      vcplan :=
         pac_planbenef.f_get_planbenef (ptablas, psseguro, pnriesgo, pnmovimi);
      vtraza := 5;

      IF vcplan IS NOT NULL
      THEN
         IF pac_planbenef.f_garant_planbenef (vcempres, vcplan, 1, pcgarant) =
                                                                            1
         THEN
            RETURN 1;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_propio_albsgt_conf.f_garant_planbenef',
                      vtraza,
                      vparam,
                      SQLERRM
                     );
         RETURN 0;
   /**/
   END f_garant_planbenef;

/*------------------------------------------------------------------------*/
/* Bug 26662 - APD - 11/04/2013 -se crea la funcion*/
   FUNCTION f_capital_planbenef (
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
      /**/
      vparam      VARCHAR2 (2000)
         :=    'ptablas = '
            || ptablas
            || ' - psseguro '
            || psseguro
            || ' - pnriesgo = '
            || pnriesgo
            || ' - pfefecto  '
            || pfefecto
            || ' - pnmovimi  '
            || pnmovimi
            || ' - pcgarant  '
            || pcgarant
            || ' - psproces  '
            || psproces
            || ' - pnmovima  '
            || pnmovima
            || ' - picapital  '
            || picapital;
      vcplan      codplanbenef.cplan%TYPE;
      vcapital    codplanbenef.nvalor%TYPE   := NULL;
      vcempres    NUMBER;
      vtraza      NUMBER;
      vcramo      NUMBER;
      vcactivi    NUMBER;
      vccolect    NUMBER;
      vcmodali    NUMBER;
      vctipseg    NUMBER;
      /* Bug 30700/0170689 - JSV - 25/03/2014 - INI*/
      w_cgarant   NUMBER;
      vcgarant    NUMBER;
      w_pca       NUMBER;
   /* Bug 30700/0170689 - JSV - 25/03/2014 - FIN*/
   BEGIN
      vtraza := 1;

      IF ptablas = 'EST'
      THEN
         vtraza := 2;

         SELECT cempres, cramo, cactivi, ccolect, cmodali, ctipseg
           INTO vcempres, vcramo, vcactivi, vccolect, vcmodali, vctipseg
           FROM estseguros
          WHERE sseguro = psseguro;
      ELSE
         vtraza := 3;

         SELECT cempres, cramo, cactivi, ccolect, cmodali, ctipseg
           INTO vcempres, vcramo, vcactivi, vccolect, vcmodali, vctipseg
           FROM seguros
          WHERE sseguro = psseguro;
      END IF;

      vtraza := 4;
      vcplan :=
         pac_planbenef.f_get_planbenef (ptablas, psseguro, pnriesgo, pnmovimi);
      vtraza := 5;

      IF vcplan IS NOT NULL
      THEN
         vcapital :=
            pac_planbenef.f_capital_planbenef (vcempres, vcplan, 2, pcgarant);

         IF vcapital = picapital
         THEN
            /* Bug 30700/0170689 - JSV - 25/03/2014 - INI*/
            BEGIN
               SELECT cgardep, (pcapdep / 100)
                 INTO w_cgarant, w_pca
                 FROM garanpro
                WHERE cgarant = pcgarant
                  AND cmodali = vcmodali
                  AND ccolect = vccolect
                  AND cramo = vcramo
                  AND ctipseg = vctipseg
                  AND cactivi = vcactivi;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  w_cgarant := NULL;
                  w_pca := NULL;
            END;

            IF w_cgarant IS NULL
            THEN
               vcgarant := pcgarant;
            ELSE
               vcgarant := w_cgarant;
            END IF;

            /* Bug 30700/0170689 - JSV - 25/03/2014 - FIN*/
            /* misma select que en pac_mdpar_productos,f_get_garanprocap*/
            SELECT MIN (a.icapital)
              INTO vcapital
              FROM (SELECT icapital
                      FROM garanprocap p
                     WHERE p.cramo = vcramo
                       AND p.cgarant = vcgarant
                       AND p.cactivi = vcactivi
                       AND p.ccolect = vccolect
                       AND p.cmodali = vcmodali
                       AND p.ctipseg = vctipseg
                    UNION ALL
                    SELECT icapital
                      FROM garanprocap p
                     WHERE p.cramo = vcramo
                       AND p.cgarant = vcgarant
                       AND p.cactivi = vcactivi
                       AND p.ccolect = vccolect
                       AND p.cmodali = vcmodali
                       AND p.ctipseg = vctipseg
                       AND NOT EXISTS (
                              SELECT 1 cdefecto
                                FROM garanprocap p1
                               WHERE p1.cramo = vcramo
                                 AND p1.cgarant = vcgarant
                                 AND p1.cactivi = vcactivi
                                 AND p1.ccolect = vccolect
                                 AND p1.cmodali = vcmodali
                                 AND p1.ctipseg = vctipseg)) a;

            /* Bug 30700/0170689 - JSV - 25/03/2014 - INI*/
            IF w_cgarant IS NOT NULL AND w_pca IS NOT NULL
            THEN
               vcapital := vcapital * w_pca;
            END IF;
         /* Bug 30700/0170689 - JSV - 25/03/2014 - FIN*/
         ELSE
            vcapital := picapital;
         END IF;
      ELSE
         vcapital := picapital;
      END IF;

      RETURN vcapital;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_propio_albsgt_conf.f_capital_planbenef',
                      vtraza,
                      vparam,
                      SQLERRM
                     );
         RETURN NULL;
   /**/
   END f_capital_planbenef;

/*------------------------------------------------------------------------*/
/* Bug 26738 - APD - 06/05/2013 -se crea la funcion*/
   FUNCTION f_dto_campanya (
      ptablas     IN   VARCHAR2,
      psseguro    IN   NUMBER,
      pnriesgo    IN   NUMBER,
      pfefecto    IN   DATE,
      pnmovimi    IN   NUMBER,
      pcgarant    IN   NUMBER,
      psproces    IN   NUMBER,
      pnmovima    IN   NUMBER,
      picapital   IN   NUMBER,
      pcpregun    IN   NUMBER
   )
      RETURN NUMBER
   IS
      /**/
      vparam            VARCHAR2 (2000)
         :=    'ptablas = '
            || ptablas
            || ' - psseguro '
            || psseguro
            || ' - pnriesgo = '
            || pnriesgo
            || ' - pfefecto  '
            || pfefecto
            || ' - pnmovimi  '
            || pnmovimi
            || ' - pcgarant  '
            || pcgarant
            || ' - psproces  '
            || psproces
            || ' - pnmovima  '
            || pnmovima
            || ' - picapital  '
            || picapital
            || ' - pcpregun  '
            || pcpregun;
      vnumerror         NUMBER;
      vtraza            NUMBER;
      vpdto             detdtosespeciales.pdto%TYPE   := NULL;
      vcempres          NUMBER;
      vsproduc          NUMBER;
      vcintermediario   NUMBER;
      vcsucursal        NUMBER;
      vfefecto          DATE;
      vcdpto            NUMBER;
      vcciudad          NUMBER;
      vcagrtipo         aut_versiones.cagrtipo%TYPE;
   BEGIN
      vtraza := 1;

      IF ptablas = 'EST'
      THEN
         vtraza := 2;

         /* Bug 26923/146905 - APD - 27/06/2013 - se añade el IF pnmovimi = 1*/
         IF pnmovimi = 1
         THEN
            /* Estamos en nueva produccion*/
            SELECT s.cempres, s.sproduc, s.cagente,
                   pac_redcomercial.f_busca_padre (s.cempres,
                                                   s.cagente,
                                                   2,
                                                   NULL
                                                  ),
                   s.fefecto
              INTO vcempres, vsproduc, vcintermediario,
                   vcsucursal,
                   vfefecto
              FROM estseguros s
             WHERE s.sseguro = psseguro;

            vtraza := 3;

            SELECT d.cprovin, d.cpoblac
              INTO vcdpto, vcciudad
              FROM estautconductores c, estper_direcciones d
             WHERE c.sperson = d.sperson
               AND c.cdomici = d.cdomici
               AND c.sseguro = psseguro
               AND c.nriesgo = pnriesgo
               AND c.nmovimi = pnmovimi
               AND c.cprincipal = 1;

            vtraza := 4;

            SELECT v.cagrtipo
              INTO vcagrtipo
              FROM estautriesgos r, aut_versiones v
             WHERE r.cversion = v.cversion
               AND r.sseguro = psseguro
               AND r.nriesgo = pnriesgo
               AND r.nmovimi = pnmovimi;
         /* Bug 26923/146905 - APD - 27/06/2013 - se añade el ELSE*/
         ELSE
            /* Estamos en suplementos*/
            vnumerror :=
               pac_preguntas.f_get_pregunseg (psseguro,
                                              pnriesgo,
                                              pcpregun,
                                              ptablas,
                                              vpdto
                                             );

            IF vnumerror <> 0
            THEN
               p_tab_error
                          (f_sysdate,
                           f_user,
                           'EXCEPTION pac_propio_albsgt_conf.f_dto_campanya',
                           527,
                              'NO EN PREGUNSEG p_sseguro = '
                           || psseguro
                           || ' pfefecto '
                           || pfefecto
                           || ' nriesgo = '
                           || pnriesgo
                           || ' - ptablas  '
                           || ptablas
                           || ' pcpregun = '
                           || pcpregun,
                           SQLERRM
                          );
               RETURN NULL;
            END IF;
         END IF;
      /* fin Bug 26923/146905 - APD - 27/06/2013*/
      ELSE
         vtraza := 5;

         SELECT s.cempres, s.sproduc, s.cagente,
                pac_redcomercial.f_busca_padre (s.cempres, s.cagente, 2, NULL),
                s.fefecto
           INTO vcempres, vsproduc, vcintermediario,
                vcsucursal,
                vfefecto
           FROM seguros s
          WHERE sseguro = psseguro;

         vtraza := 6;

         SELECT d.cprovin, d.cpoblac
           INTO vcdpto, vcciudad
           FROM autconductores c, per_direcciones d
          WHERE c.sperson = d.sperson
            AND c.cdomici = d.cdomici
            AND c.sseguro = psseguro
            AND c.nriesgo = pnriesgo
            AND c.nmovimi = pnmovimi
            AND c.cprincipal = 1;

         vtraza := 7;

         SELECT v.cagrtipo
           INTO vcagrtipo
           FROM autriesgos r, aut_versiones v
          WHERE r.cversion = v.cversion
            AND r.sseguro = psseguro
            AND r.nriesgo = pnriesgo
            AND r.nmovimi = pnmovimi;
      END IF;

      /* Bug 26923/146905 - APD - 27/06/2013 - se añade el IF w_sucursal IS NULL*/
      IF vpdto IS NULL
      THEN
         vtraza := 8;

         BEGIN
            SELECT pdto
              INTO vpdto
              FROM coddtosespeciales c, detdtosespeciales d
             WHERE c.cempres = d.cempres
               AND c.ccampanya = d.ccampanya
               AND c.finicio <= vfefecto
               AND (c.ffin IS NULL OR c.ffin >= vfefecto)
               AND d.cempres = vcempres
               AND d.sproduc = vsproduc
               AND d.cdpto = vcdpto
               AND d.cciudad = vcciudad
               AND d.cagrupacion = vcagrtipo
               AND d.csucursal = vcsucursal
               AND d.cintermediario = vcintermediario;
         EXCEPTION
            WHEN OTHERS
            THEN
               vtraza := 9;
               vpdto := NULL;
         END;
      END IF;

      RETURN vpdto;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_propio_albsgt_conf.f_dto_campanya',
                      vtraza,
                      vparam,
                      SQLERRM
                     );
         RETURN NULL;
   /**/
   END f_dto_campanya;

/*------------------------------------------------------------------------*/
   FUNCTION f_tasa_unica (
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
      /**/
      w_sproduc      seguros.sproduc%TYPE;
      w_cversion     autriesgos.cversion%TYPE;
      w_subtabla     sgt_subtabs_det.csubtabla%TYPE;
      w_755          NUMBER;
      w_tarifa       estgaranseg.ftarifa%TYPE;
      w_respue       NUMBER;
      w_harenovado   NUMBER;
      w_ctipveh      NUMBER;
      w_marca        NUMBER;
      w_agrtipo      NUMBER;
      w_clase        NUMBER;
      w_uso          NUMBER;
      w_any          NUMBER;
      w_provin       NUMBER;
      w_poblac       NUMBER;
      w_error        NUMBER                           := 0;
      w_tasa_unica   NUMBER;
      w_ssegpol      NUMBER;
      w_param        VARCHAR2 (4000)
         :=    ' ptablas= '
            || ptablas
            || 'psseguro= '
            || psseguro
            || 'pnriesgo= '
            || pnriesgo
            || 'pfefecto= '
            || pfefecto
            || 'pnmovimi= '
            || pnmovimi
            || 'pcgarant= '
            || pcgarant
            || 'psproces= '
            || psproces
            || 'pnmovima= '
            || pnmovima
            || 'picapital= '
            || picapital;

/*------------------------------------------------------------------------*/
      PROCEDURE p_seguros (
         p_tablas    IN       VARCHAR2,
         p_sseguro   IN       NUMBER,
         p_sproduc   OUT      NUMBER
      )
      IS
      BEGIN
         IF ptablas = 'EST'
         THEN
            /**/
            BEGIN
               SELECT sproduc
                 INTO p_sproduc
                 FROM estseguros
                WHERE sseguro = p_sseguro;
            EXCEPTION
               WHEN OTHERS
               THEN
                  p_sproduc := NULL;
            END;
         /**/
         ELSE
            /**/
            BEGIN
               SELECT sproduc
                 INTO p_sproduc
                 FROM seguros
                WHERE sseguro = p_sseguro;
            EXCEPTION
               WHEN OTHERS
               THEN
                  p_sproduc := NULL;
            END;
         /**/
         END IF;
      /**/
      END;

/*------------------------------------------------------------------------*/
      PROCEDURE p_autriesgos (
         p_tablas     IN       VARCHAR2,
         p_sseguro    IN       NUMBER,
         p_nriesgo    IN       NUMBER,
         p_nmovimi    IN       NUMBER,
         p_cversion   OUT      VARCHAR2,
         p_anyo       OUT      NUMBER,
         p_cuso       OUT      NUMBER
      )
      IS
      BEGIN
         IF ptablas = 'EST'
         THEN
            BEGIN
               SELECT cversion, anyo, TO_NUMBER (cuso)
                 INTO p_cversion, p_anyo, p_cuso
                 FROM estautriesgos
                WHERE sseguro = p_sseguro
                  AND nriesgo = p_nriesgo
                  AND nmovimi = p_nmovimi;
            EXCEPTION
               WHEN OTHERS
               THEN
                  p_cversion := NULL;
                  p_anyo := NULL;
                  p_cuso := NULL;
            END;
         ELSE
            BEGIN
               SELECT cversion, anyo, TO_NUMBER (cuso)
                 INTO p_cversion, p_anyo, p_cuso
                 FROM autriesgos
                WHERE sseguro = p_sseguro
                  AND nriesgo = p_nriesgo
                  AND nmovimi = p_nmovimi;
            EXCEPTION
               WHEN OTHERS
               THEN
                  p_cversion := NULL;
                  p_anyo := NULL;
                  p_cuso := NULL;
            END;
         END IF;
      /**/
      END;

/*------------------------------------------------------------------------*/
      PROCEDURE p_autversiones (
         p_sseguro       IN       NUMBER,
         p_nriesgo       IN       NUMBER,
         p_nmovimi       IN       NUMBER,
         p_cversion      IN       VARCHAR2,
         p_ctipveh       OUT      NUMBER,
         p_cmarca        OUT      NUMBER,
         p_cagrtiponum   OUT      NUMBER
      )
      IS
         /**/
         w_cagrtipo   aut_versiones.cagrtipo%TYPE;
      /**/
      BEGIN
         /**/
         BEGIN
            SELECT TO_NUMBER (ctipveh), TO_NUMBER (cmarca), cagrtipo
              INTO p_ctipveh, p_cmarca, w_cagrtipo
              FROM aut_versiones
             WHERE cversion = p_cversion;
         EXCEPTION
            WHEN OTHERS
            THEN
               p_cmarca := NULL;
               w_cagrtipo := NULL;
               p_cagrtiponum := NULL;
         END;

         /**/
         IF w_cagrtipo IS NOT NULL
         THEN
            BEGIN
               SELECT cagrtiponum
                 INTO p_cagrtiponum
                 FROM aut_codagrtipo
                WHERE cagrtipo = w_cagrtipo;
            EXCEPTION
               WHEN OTHERS
               THEN
                  p_cagrtiponum := NULL;
            END;
         END IF;

         w_param := w_param || 'w_cagrtipo ' || w_cagrtipo;
      /**/
      END;

/*------------------------------------------------------------------------*/
      PROCEDURE p_autconductores (
         p_tablas    IN       VARCHAR2,
         p_sseguro   IN       NUMBER,
         p_nriesgo   IN       NUMBER,
         p_nmovimi   IN       NUMBER,
         p_cprovin   OUT      NUMBER,
         p_cpoblac   OUT      NUMBER
      )
      IS
         /**/
         w_sperson   autconductores.sperson%TYPE;
         w_cdomici   autconductores.cdomici%TYPE;
      /**/
      BEGIN
         /**/
         IF p_tablas = 'EST'
         THEN
            BEGIN
               SELECT sperson, cdomici
                 INTO w_sperson, w_cdomici
                 FROM estautconductores
                WHERE sseguro = p_sseguro
                  AND nriesgo = p_nriesgo
                  AND nmovimi = p_nmovimi
                  AND cprincipal = 1;
            EXCEPTION
               WHEN OTHERS
               THEN
                  w_sperson := NULL;
                  w_cdomici := NULL;
            END;
         ELSE
            BEGIN
               SELECT sperson, cdomici
                 INTO w_sperson, w_cdomici
                 FROM autconductores
                WHERE sseguro = p_sseguro
                  AND nriesgo = p_nriesgo
                  AND nmovimi = p_nmovimi
                  AND cprincipal = 1;
            EXCEPTION
               WHEN OTHERS
               THEN
                  w_sperson := NULL;
                  w_cdomici := NULL;
            END;
         END IF;

         /**/
         IF w_sperson IS NOT NULL
         THEN
            IF p_tablas = 'EST'
            THEN
               BEGIN
                  SELECT cprovin, cpoblac
                    INTO p_cprovin, p_cpoblac
                    FROM estper_direcciones
                   WHERE sperson = w_sperson AND cdomici = w_cdomici;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     p_cprovin := NULL;
                     p_cpoblac := NULL;
               END;
            ELSE
               BEGIN
                  SELECT cprovin, cpoblac
                    INTO p_cprovin, p_cpoblac
                    FROM per_direcciones
                   WHERE sperson = w_sperson AND cdomici = w_cdomici;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     p_cprovin := NULL;
                     p_cpoblac := NULL;
               END;
            END IF;
         END IF;

         w_param := w_param || 'w_sperson ' || w_sperson;
      /**/
      END;

      PROCEDURE p_pregunseg (
         p_tablas    IN       VARCHAR2,
         p_sseguro   IN       NUMBER,
         p_nriesgo   IN       NUMBER,
         p_nmovimi   IN       NUMBER,
         p_pregun    IN       NUMBER,
         p_crespue   OUT      NUMBER
      )
      IS
      /**/
      BEGIN
         /**/
         IF p_tablas = 'EST'
         THEN
            BEGIN
               SELECT crespue
                 INTO p_crespue
                 FROM estpregunseg
                WHERE sseguro = p_sseguro
                  AND nriesgo = p_nriesgo
                  AND nmovimi = p_nmovimi
                  AND cpregun = p_pregun;
            EXCEPTION
               WHEN OTHERS
               THEN
                  p_crespue := NULL;
            END;
         ELSE
            BEGIN
               SELECT crespue
                 INTO p_crespue
                 FROM pregunseg
                WHERE sseguro = p_sseguro
                  AND nriesgo = p_nriesgo
                  AND nmovimi = p_nmovimi
                  AND cpregun = p_pregun;
            EXCEPTION
               WHEN OTHERS
               THEN
                  p_crespue := NULL;
            END;
         END IF;
      /**/
      END;
/*------------------------------------------------------------------------*/
/* Programa principal*/
/*------------------------------------------------------------------------*/
   BEGIN
      p_seguros (ptablas, psseguro, w_sproduc);

      IF w_sproduc IS NULL
      THEN
         w_error := 1;
      END IF;

      w_param := w_param || 'w_sproduc ' || w_sproduc;
      /**/
      p_autriesgos (ptablas,
                    psseguro,
                    pnriesgo,
                    pnmovimi,
                    w_cversion,
                    w_any,
                    w_uso
                   );

      IF w_cversion IS NULL OR w_any IS NULL OR w_uso IS NULL
      THEN
         w_error := 1;
      END IF;

      w_param :=
            w_param
         || ' w_cversion '
         || w_cversion
         || ' w_any '
         || w_any
         || ' w_uso '
         || w_uso;
      /**/
      p_autversiones (psseguro,
                      pnriesgo,
                      pnmovimi,
                      w_cversion,
                      w_clase,
                      w_marca,
                      w_agrtipo
                     );

      IF w_clase IS NULL OR w_marca IS NULL OR w_agrtipo IS NULL
      THEN
         w_error := 1;
      END IF;

      w_param :=
            w_param
         || ' w_clase '
         || w_clase
         || ' w_marca '
         || w_marca
         || ' w_agrtipo '
         || w_agrtipo;
      /**/
      p_autconductores (ptablas,
                        psseguro,
                        pnriesgo,
                        pnmovimi,
                        w_provin,
                        w_poblac
                       );

      IF w_provin IS NULL OR w_poblac IS NULL
      THEN
         w_error := 1;
      END IF;

      w_param :=
               w_param || ' w_provin ' || w_provin || ' w_poblac ' || w_poblac;

      /* BUG 0025900/0151944 - JSV (02/09/2013) - INI*/
      IF w_sproduc IN (6038)
      THEN
         p_pregunseg (ptablas, psseguro, pnriesgo, pnmovimi, 4960, w_respue);
      ELSIF w_sproduc = 6039
      THEN
         p_pregunseg (ptablas, psseguro, pnriesgo, pnmovimi, 4919, w_respue);
      END IF;

      /* BUG 0025900/0151944 - JSV (02/09/2013) - FIN*/
      IF w_respue IS NULL AND w_sproduc != 6037
      THEN
         w_error := 1;
      END IF;

      w_param := w_param || ' w_respue ' || w_respue;

      /**/
      IF ptablas = 'EST'
      THEN
         BEGIN
            SELECT ssegpol
              INTO w_ssegpol
              FROM estseguros
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               w_ssegpol := NULL;
         END;

         w_harenovado := f_es_renovacion (w_ssegpol);
      ELSE
         w_harenovado := f_es_renovacion (psseguro);
      END IF;

      IF w_harenovado = 0
      THEN
         /* Es renovación*/
         w_harenovado := 2;
      ELSE
         /*- Estamos en NP*/
         w_harenovado := 1;
      END IF;

      /**/
      /* BUG 0025900/0151944 - JSV (02/09/2013) - INI*/
      /*      IF w_sproduc = 6039 THEN*/
      /*         w_subtabla := 60399998;*/
      /*      ELSE*/
      /*         w_subtabla := NULL;*/
      /*      END IF;*/
      w_subtabla := NULL;

      IF w_sproduc IS NOT NULL
      THEN
         w_subtabla := w_sproduc * 10000;
         w_subtabla := w_subtabla + 9998;
      END IF;

      w_param := w_param || ' w_subtabla ' || w_subtabla;

      /* BUG 0025900/0151944 - JSV (02/09/2013) - FIN*/
      /**/
      IF ptablas = 'EST'
      THEN
         BEGIN
            SELECT 1
              INTO w_755
              FROM estgaranseg
             WHERE sseguro = psseguro
               AND nriesgo = pnriesgo
               AND nmovimi = pnmovimi
               AND cgarant = 755
               AND NVL (cobliga, 0) != 0;
         EXCEPTION
            WHEN OTHERS
            THEN
               w_755 := 0;
         END;
      ELSE
         BEGIN
            SELECT 1
              INTO w_755
              FROM garanseg
             WHERE sseguro = psseguro
               AND nriesgo = pnriesgo
               AND nmovimi = pnmovimi
               AND cgarant = 755;
         EXCEPTION
            WHEN OTHERS
            THEN
               w_755 := 0;
         END;
      END IF;

      /*--- Recupera la fecha de tarifa para controlar las versiones de subtablas.*/
      /*--- Se eliminan los bloques Begin y se cambian por IF pues al ser un MIN no genera excepcion*/
      IF ptablas = 'EST'
      THEN
         SELECT MIN (ftarifa)
           INTO w_tarifa
           FROM estgaranseg
          WHERE sseguro = psseguro AND nriesgo = pnriesgo
                AND nmovimi = pnmovimi;

         IF w_tarifa IS NULL
         THEN
            w_tarifa := f_sysdate;
         END IF;
      ELSE
         SELECT MIN (ftarifa)
           INTO w_tarifa
           FROM tmp_garancar
          WHERE sseguro = psseguro AND nriesgo = pnriesgo;

         IF w_tarifa IS NULL
         THEN
            SELECT MIN (ftarifa)
              INTO w_tarifa
              FROM garanseg
             WHERE sseguro = psseguro
               AND nriesgo = pnriesgo
               AND nmovimi = pnmovimi;

            IF w_tarifa IS NULL
            THEN
               w_tarifa := f_sysdate;
            END IF;
         END IF;
      END IF;

      IF w_error = 0
      THEN
         /* Mirem si hi ha registres per aquest DPTO/POBLACIÓ*/
         /*w_tasa_unica := NVL(pac_subtablas.f_vsubtabla(NULL, w_subtabla, 33, 1, w_provin,*/
         /*                                              w_poblac),*/
         /*                    0);*/
         /*IF w_tasa_unica != 0 THEN*/
         /* MRB 05/10/2013*/
         IF w_sproduc = 6037
         THEN
            /* Se cambio parametro de session -1 para cargar la fecha de tarifa*/
            /* y controlar la version de las tasas SSM*/
            w_tasa_unica :=
               NVL (pac_subtablas.f_vsubtabla (-1,
                                               w_subtabla,
                                               33333334,
                                               1,
                                               w_provin,
                                               w_poblac,
                                               w_harenovado,
                                               w_marca,
                                               w_clase,
                                               w_agrtipo,
                                               w_uso,
                                               w_any,
                                               NULL,
                                               NULL,
                                               w_tarifa
                                              ),
                    0
                   );
            p_tab_error (f_sysdate,
                         f_user,
                         'pac_propio_albsgt_conf.f_tasa_unica',
                         4,
                         'w_tasa_unica:' || w_tasa_unica,
                         SQLERRM
                        );
         ELSE
            w_tasa_unica :=
               NVL (pac_subtablas.f_vsubtabla (-1,
                                               w_subtabla,
                                               3333333433,
                                               1,
                                               w_provin,
                                               w_poblac,
                                               w_harenovado,
                                               w_marca,
                                               w_clase,
                                               w_agrtipo,
                                               w_uso,
                                               w_any,
                                               w_respue,
                                               w_755,
                                               w_tarifa
                                              ),
                    0
                   );
         END IF;

         IF w_tasa_unica = 0
         THEN
            /* Si no hi ha registres per DPTO/POBLACIO, busquem a nivell NACIONAL*/
            w_provin := 99999999;
            w_poblac := 99999999;

            /* MRB 05/10/2013*/
            IF w_sproduc = 6037
            THEN
               w_tasa_unica :=
                  NVL (pac_subtablas.f_vsubtabla (-1,
                                                  w_subtabla,
                                                  33333334,
                                                  1,
                                                  w_provin,
                                                  w_poblac,
                                                  w_harenovado,
                                                  w_marca,
                                                  w_clase,
                                                  w_agrtipo,
                                                  w_uso,
                                                  w_any,
                                                  NULL,
                                                  NULL,
                                                  w_tarifa
                                                 ),
                       0
                      );
               p_tab_error (f_sysdate,
                            f_user,
                            'pac_propio_albsgt_conf.f_tasa_unica',
                            14,
                            'w_tasa_unica:' || w_tasa_unica,
                            SQLERRM
                           );
            ELSIF w_sproduc = 6039
            THEN
               /* Bug 39652/0023147 - JRB - 30/12/2015 - Quitamos el NVL, si tampoco hay registros a nivel nacional, no habrá encontrado tarifa para el amparo producto PI bug 39652*/
               w_tasa_unica :=
                  pac_subtablas.f_vsubtabla (-1,
                                             w_subtabla,
                                             3333333433,
                                             1,
                                             w_provin,
                                             w_poblac,
                                             w_harenovado,
                                             w_marca,
                                             w_clase,
                                             w_agrtipo,
                                             w_uso,
                                             w_any,
                                             w_respue,
                                             w_755,
                                             w_tarifa
                                            );
            ELSE
               w_tasa_unica :=
                  NVL (pac_subtablas.f_vsubtabla (-1,
                                                  w_subtabla,
                                                  3333333433,
                                                  1,
                                                  w_provin,
                                                  w_poblac,
                                                  w_harenovado,
                                                  w_marca,
                                                  w_clase,
                                                  w_agrtipo,
                                                  w_uso,
                                                  w_any,
                                                  w_respue,
                                                  w_755,
                                                  w_tarifa
                                                 ),
                       0
                      );
            END IF;
         END IF;
      ELSE
         w_tasa_unica := NULL;
      END IF;

        /**/
        /*     IF w_tasa_unica IS NULL THEN
      p_tab_error(f_sysdate, f_user, 'pac_propio_albsgt_conf.f_tasa_unica', 526,
      'w_tasa_unica is null => ptablas= ' || ptablas || 'psseguro= '
      || psseguro || 'pnriesgo= ' || pnriesgo || 'pfefecto= ' || pfefecto
      || 'pnmovimi= ' || pnmovimi || 'pcgarant= ' || pcgarant || 'psproces= '
      || psproces || 'pnmovima= ' || pnmovima || 'picapital= ' || picapital,
      SQLERRM);
      END IF;
      */
      IF NVL (w_tasa_unica, 0) = 0
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_propio_albsgt_conf.f_tasa_unica',
                      526,
                      'w_tasa_unica is null ',
                      w_param
                     );
      END IF;

      RETURN w_tasa_unica;
   /**/
   END f_tasa_unica;

   /* Bug 26923/0146905 - APD - 03/07/2013 - se crea la funcion*/
   FUNCTION f_agente (
      ptablas     IN   VARCHAR2,
      psseguro    IN   NUMBER,
      pnriesgo    IN   NUMBER,
      pfefecto    IN   DATE,
      pnmovimi    IN   NUMBER,
      pcgarant    IN   NUMBER,
      psproces    IN   NUMBER,
      pnmovima    IN   NUMBER,
      picapital   IN   NUMBER,
      pcpregun    IN   NUMBER
   )
      RETURN NUMBER
   IS
      /**/
      w_cagente   seguros.cagente%TYPE;
      w_error     NUMBER;
   /**/
   BEGIN
      /**/
      w_error := 0;

      /**/
      IF ptablas = 'EST'
      THEN
         /* Bug 26923/146905 - APD - 27/06/2013 - se añade el IF pnmovimi = 1*/
         IF pnmovimi = 1
         THEN
            /* Estamos en nueva produccion*/
            /**/
            BEGIN
               SELECT cagente
                 INTO w_cagente
                 FROM estseguros
                WHERE sseguro = psseguro;
            EXCEPTION
               WHEN OTHERS
               THEN
                  w_cagente := 0;
            END;
         /* Bug 26923/146905 - APD - 27/06/2013 - se añade el ELSE*/
         ELSE
            /* Estamos en suplementos*/
            w_error :=
               pac_preguntas.f_get_pregunseg (psseguro,
                                              pnriesgo,
                                              pcpregun,
                                              ptablas,
                                              w_cagente
                                             );

            IF w_error <> 0
            THEN
               p_tab_error (f_sysdate,
                            f_user,
                            'EXCEPTION pac_propio_albsgt_conf.f_agente',
                            527,
                               'NO EN PREGUNSEG p_sseguro = '
                            || psseguro
                            || ' pfefecto '
                            || pfefecto
                            || ' nriesgo = '
                            || pnriesgo
                            || ' - ptablas  '
                            || ptablas
                            || ' pcpregun = '
                            || pcpregun,
                            SQLERRM
                           );
               RETURN NULL;
            END IF;
         END IF;
      /* fin Bug 26923/146905 - APD - 27/06/2013*/
      /**/
      ELSE
         /**/
         BEGIN
            SELECT cagente
              INTO w_cagente
              FROM seguros
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS
            THEN
               w_cagente := 0;
         END;
      /**/
      END IF;

      /**/
      IF w_cagente IS NULL
      THEN
         w_cagente := 0;
      END IF;

      /**/
      RETURN w_cagente;
   /**/
   END f_agente;

/*------------------------------------------------------------------------*/
   FUNCTION f_cmoto (
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
      /**/
      w_torna   NUMBER;
   /**/
   BEGIN
      w_torna :=
         f_clas_motos (ptablas,
                       psseguro,
                       pnriesgo,
                       pfefecto,
                       pnmovimi,
                       pcgarant,
                       psproces,
                       pnmovima,
                       picapital
                      );
      RETURN w_torna;
   END;

/*------------------------------------------------------------------------*/
   FUNCTION f_clas_motos (
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
      /**/
      w_sproduc      seguros.sproduc%TYPE;
      w_cversion     autriesgos.cversion%TYPE;
      w_subtabla     sgt_subtabs_det.csubtabla%TYPE;
      w_755          NUMBER;
      w_respue       NUMBER;
      w_harenovado   NUMBER;
      w_ctipveh      NUMBER;
      w_marca        NUMBER;
      w_agrtipo      NUMBER;
      w_clase        NUMBER;
      w_uso          NUMBER;
      w_any          NUMBER;
      w_provin       NUMBER;
      w_poblac       NUMBER;
      w_error        NUMBER                           := 0;
      w_valoracce    NUMBER;
      w_valorvehi    NUMBER;
      w_clas_moto    NUMBER;
      w_version      NUMBER;

/*------------------------------------------------------------------------*/
      PROCEDURE p_seguros (
         p_tablas    IN       VARCHAR2,
         p_sseguro   IN       NUMBER,
         p_sproduc   OUT      NUMBER
      )
      IS
      BEGIN
         IF ptablas = 'EST'
         THEN
            /**/
            BEGIN
               SELECT sproduc
                 INTO p_sproduc
                 FROM estseguros
                WHERE sseguro = p_sseguro;
            EXCEPTION
               WHEN OTHERS
               THEN
                  p_sproduc := NULL;
            END;
         /**/
         ELSE
            /**/
            BEGIN
               SELECT sproduc
                 INTO p_sproduc
                 FROM seguros
                WHERE sseguro = p_sseguro;
            EXCEPTION
               WHEN OTHERS
               THEN
                  p_sproduc := NULL;
            END;
         /**/
         END IF;
      /**/
      END;

/*------------------------------------------------------------------------*/
      PROCEDURE p_autriesgos (
         p_tablas      IN       VARCHAR2,
         p_sseguro     IN       NUMBER,
         p_nriesgo     IN       NUMBER,
         p_nmovimi     IN       NUMBER,
         p_cversion    OUT      VARCHAR2,
         p_anyo        OUT      NUMBER,
         p_cuso        OUT      NUMBER,
         p_valorvehi   OUT      NUMBER
      )
      IS
      BEGIN
         IF ptablas = 'EST'
         THEN
            BEGIN
               SELECT cversion, anyo, TO_NUMBER (cuso), NVL (ivehicu, 0)
                 INTO p_cversion, p_anyo, p_cuso, p_valorvehi
                 FROM estautriesgos
                WHERE sseguro = p_sseguro
                  AND nriesgo = p_nriesgo
                  AND nmovimi = p_nmovimi;
            EXCEPTION
               WHEN OTHERS
               THEN
                  p_cversion := NULL;
                  p_anyo := NULL;
                  p_cuso := NULL;
                  p_valorvehi := 0;
            END;
         ELSE
            BEGIN
               SELECT cversion, anyo, TO_NUMBER (cuso), NVL (ivehicu, 0)
                 INTO p_cversion, p_anyo, p_cuso, p_valorvehi
                 FROM autriesgos
                WHERE sseguro = p_sseguro
                  AND nriesgo = p_nriesgo
                  AND nmovimi = p_nmovimi;
            EXCEPTION
               WHEN OTHERS
               THEN
                  p_cversion := NULL;
                  p_anyo := NULL;
                  p_cuso := NULL;
                  p_valorvehi := 0;
            END;
         END IF;
      /**/
      END;

      PROCEDURE p_accesorios (
         p_tablas      IN       VARCHAR2,
         p_sseguro     IN       NUMBER,
         p_nriesgo     IN       NUMBER,
         p_nmovimi     IN       NUMBER,
         p_valoracce   OUT      VARCHAR2
      )
      IS
      BEGIN
         IF ptablas = 'EST'
         THEN
            BEGIN
               SELECT NVL (SUM (NVL (a.ivalacc, 0)), 0)
                 INTO p_valoracce
                 FROM estautdetriesgos a
                WHERE a.sseguro = p_sseguro
                  AND a.nriesgo = p_nriesgo
                  AND a.nmovimi = p_nmovimi
                  AND a.ctipacc = 4;
            EXCEPTION
               WHEN OTHERS
               THEN
                  p_valoracce := NULL;
            END;
         ELSE
            BEGIN
               BEGIN
                  SELECT NVL (SUM (NVL (a.ivalacc, 0)), 0)
                    INTO p_valoracce
                    FROM autdetriesgos a
                   WHERE a.sseguro = p_sseguro
                     AND a.nriesgo = p_nriesgo
                     AND a.nmovimi = p_nmovimi
                     AND a.ctipacc = 4;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     p_valoracce := NULL;
               END;
            EXCEPTION
               WHEN OTHERS
               THEN
                  p_valoracce := NULL;
            END;
         END IF;
      /**/
      END;

/*------------------------------------------------------------------------*/
/*------------------------------------------------------------------------*/
      PROCEDURE p_autversiones (
         p_sseguro       IN       NUMBER,
         p_nriesgo       IN       NUMBER,
         p_nmovimi       IN       NUMBER,
         p_cversion      IN       VARCHAR2,
         p_ctipveh       OUT      NUMBER,
         p_cmarca        OUT      NUMBER,
         p_cagrtiponum   OUT      NUMBER
      )
      IS
         /**/
         w_cagrtipo   aut_versiones.cagrtipo%TYPE;
      /**/
      BEGIN
         /**/
         BEGIN
            SELECT TO_NUMBER (ctipveh), TO_NUMBER (cmarca), cagrtipo
              INTO p_ctipveh, p_cmarca, w_cagrtipo
              FROM aut_versiones
             WHERE cversion = p_cversion;
         EXCEPTION
            WHEN OTHERS
            THEN
               p_cmarca := NULL;
               w_cagrtipo := NULL;
               p_cagrtiponum := NULL;
         END;

         /**/
         IF w_cagrtipo IS NOT NULL
         THEN
            BEGIN
               SELECT cagrtiponum
                 INTO p_cagrtiponum
                 FROM aut_codagrtipo
                WHERE cagrtipo = w_cagrtipo;
            EXCEPTION
               WHEN OTHERS
               THEN
                  p_cagrtiponum := NULL;
            END;
         END IF;
      /**/
      END;
/*------------------------------------------------------------------------*/
/*------------------------------------------------------------------------*/
/* Programa principal*/
/*------------------------------------------------------------------------*/
   BEGIN
      p_seguros (ptablas, psseguro, w_sproduc);

      IF w_sproduc IS NULL
      THEN
         w_error := 1;
      END IF;

      /**/
      p_autriesgos (ptablas,
                    psseguro,
                    pnriesgo,
                    pnmovimi,
                    w_cversion,
                    w_any,
                    w_uso,
                    w_valorvehi
                   );

      IF    w_cversion IS NULL
         OR w_any IS NULL
         OR w_uso IS NULL
         OR w_valorvehi IS NULL
      THEN
         w_error := 1;
      END IF;

      /**/
      p_autversiones (psseguro,
                      pnriesgo,
                      pnmovimi,
                      w_cversion,
                      w_clase,
                      w_marca,
                      w_agrtipo
                     );

      IF w_clase IS NULL OR w_marca IS NULL OR w_agrtipo IS NULL
      THEN
         w_error := 1;
      END IF;

      p_accesorios (ptablas, psseguro, pnriesgo, pnmovimi, w_valoracce);

      /* MRB - 27/08/2014 - Bug: 32579*/
      IF w_sproduc IN (6034, 6043, 6048)
      THEN
         w_subtabla := 60349999;
      ELSE
         w_subtabla := NULL;
      END IF;

      /**/
      w_version := TO_NUMBER (SUBSTR (w_cversion, 6, 3));

      IF w_error = 0
      THEN
         /* JSV - (02/10/2013) - 0025896/0154460*/
         /* Bug 0036217/00205693 - 10/06/2015 - VCG- se quita el nvl*/
         w_clas_moto :=
            pac_subtablas.f_vsubtabla (NULL,
                                       w_subtabla,
                                       33334,
                                       1,
                                       w_sproduc,
                                       w_marca,
                                       w_clase,
                                       w_version,
                                         NVL (w_valorvehi, 0)
                                       + NVL (w_valoracce, 0)
                                      );
      ELSE
         w_clas_moto := NULL;
      END IF;

      /**/
      RETURN w_clas_moto;
   /**/
   END f_clas_motos;

/*------------------------------------------------------------------------*/
/*------------------------------------------------------------------------*/
/*BUG: 0028027 - INICIO - DCT - 04/10/2013 - LCOL_PROD-0008983: Solucion de Fondo a Disminucion del valor del reaseguro en la renovaci?n de la poliza 43, 1153 y 1622*/
   FUNCTION f_rarea (psseguro IN NUMBER, pfcaranu IN DATE)
      RETURN NUMBER
   IS
      v_ret         DATE;
      v_seguroini   estseguros.ssegpol%TYPE;
      v_tablas      VARCHAR2 (10);
   BEGIN
      BEGIN
         SELECT ssegpol                      /* Queremos el sseguro original*/
           INTO v_seguroini
           FROM estseguros
          WHERE sseguro = psseguro;

         v_tablas := 'EST';
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            v_seguroini := psseguro;
            v_tablas := NULL;
      END;

      /* Se utiliza para la formulación porque el nombre es muy largo*/
      v_ret :=
         pac_cesionesrea.f_renovacion_anual_rea (psseguro, pfcaranu, v_tablas);
      p_tab_error (f_sysdate,
                   f_user,
                   'pac_propio_albsgt_conf.f_rarea',
                   1,
                      ' - v_tablas  '
                   || v_tablas
                   || ' - psseguro '
                   || psseguro
                   || ' - pnriesgo '
                   || ' - pfcaranu '
                   || pfcaranu
                   || ' - v_ret = '
                   || v_ret,
                   0
                  );
      RETURN TO_NUMBER (TO_CHAR (v_ret, 'YYYYMMDD'));
   END f_rarea;

/*BUG: 0028027 - FIN - DCT - 04/10/2013 - LCOL_PROD-0008983: Solucion de Fondo a Disminucion del valor del reaseguro en la renovaci?n de la poliza 43, 1153 y 1622*/
/*------------------------------------------------------------------------*/
/*BUG 0027923 - INICIO - DCT - 12/09/2013 - LCOL_F3BTEC-MTF3B - LCOL_TEC23 - Definici?n de condiciones en Certificado 0*/
   FUNCTION f_alta_certificado (ptablas IN VARCHAR2, psseguro IN NUMBER)
      RETURN BOOLEAN
   IS
      v_sproduc    seguros.sproduc%TYPE;
      visaltacol   BOOLEAN                := FALSE;
      v_npoliza    seguros.npoliza%TYPE;
      v_ncertif    seguros.ncertif%TYPE;
   BEGIN
      IF ptablas = 'EST'
      THEN
         BEGIN
            SELECT sproduc
              INTO v_sproduc
              FROM estseguros
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS
            THEN
               v_sproduc := NULL;
         END;
      ELSE
         BEGIN
            SELECT sproduc
              INTO v_sproduc
              FROM seguros
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS
            THEN
               v_sproduc := NULL;
         END;
      END IF;

      IF NVL (f_parproductos_v (v_sproduc, 'ADMITE_CERTIFICADOS'), 0) = 0
      THEN
         visaltacol := FALSE;
      ELSE
         IF pac_iax_produccion.isaltacol
         THEN
            visaltacol := TRUE;
         ELSE
            IF ptablas = 'EST'
            THEN
               BEGIN
                  SELECT npoliza, ncertif
                    INTO v_npoliza, v_ncertif
                    FROM estseguros
                   WHERE sseguro = psseguro;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     v_npoliza := NULL;
                     v_ncertif := NULL;
               END;
            ELSE
               BEGIN
                  SELECT npoliza, ncertif
                    INTO v_npoliza, v_ncertif
                    FROM seguros
                   WHERE sseguro = psseguro;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     v_npoliza := NULL;
                     v_ncertif := NULL;
               END;
            END IF;

            IF v_ncertif = 0
            THEN
               visaltacol := TRUE;
            END IF;
         END IF;
      END IF;

      RETURN visaltacol;
   END f_alta_certificado;

   /*BUG 0027923 - FIN - DCT - 12/09/2013 - LCOL_F3BTEC-MTF3B - LCOL_TEC23 - Definici?n de condiciones en Certificado 0*/
   FUNCTION f_factor_disposi_pac (
      ptablas      IN   VARCHAR2,
      psseguro     IN   NUMBER,
      pnriesgo     IN   NUMBER,
      pfefecto     IN   DATE,
      pnmovimi     IN   NUMBER,
      pcgarant     IN   NUMBER,
      psproces     IN   NUMBER,
      pnmovima     IN   NUMBER,
      picapital    IN   NUMBER,
      /* 0028041/0152073 - JSV 03/09/2013*/
      pcsubtabla   IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      /**/
      w_fefecto   seguros.fefecto%TYPE;
      w_sproduc   seguros.sproduc%TYPE;
      w_factor    NUMBER;

      /**/
      CURSOR c_estautdisriesgos
      IS
         SELECT *
           FROM estautdisriesgos
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND nmovimi = pnmovimi;

      /**/
      CURSOR c_autdisriesgos
      IS
         SELECT *
           FROM autdisriesgos
          WHERE sseguro = psseguro AND nriesgo = pnriesgo
                AND nmovimi = pnmovimi;
   /**/
   BEGIN
      /**/
      IF ptablas = 'EST'
      THEN
         /**/
         BEGIN
            SELECT sproduc
              INTO w_sproduc
              FROM estseguros
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS
            THEN
               w_sproduc := NULL;
         END;

         /**/
         w_factor := 1;

         FOR reg IN c_estautdisriesgos
         LOOP
            /**/
            w_factor :=
                 w_factor
               * NVL (pac_subtablas.f_vsubtabla (NULL,
                                                 NVL (pcsubtabla, 70310119),
                                                 3333,
                                                 1,
                                                 w_sproduc,
                                                 pcgarant,
                                                 TO_NUMBER (reg.cdispositivo),
                                                 reg.cpropdisp
                                                ),
                      1
                     );
         /**/
         END LOOP;
      /**/
      ELSE
         /**/
         BEGIN
            SELECT sproduc
              INTO w_sproduc
              FROM seguros
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS
            THEN
               w_sproduc := NULL;
         END;

         /**/
         w_factor := 1;

         FOR reg IN c_autdisriesgos
         LOOP
            /**/
            IF reg.cpropdisp = '1'
            THEN
               w_factor :=
                    w_factor
                  * NVL (pac_subtablas.f_vsubtabla (NULL,
                                                    /* 0028041/0152073 - JSV 03/09/2013 - INI*/
                                                    /*60319997,*/
                                                    NVL (pcsubtabla, 70310119),
                                                    3333,
                                                    1,
                                                    w_sproduc,
                                                    pcgarant,
                                                    reg.cdispositivo,
                                                    reg.cpropdisp
                                                   ),
                         1
                        );
            ELSE
               w_factor :=
                    w_factor
                  * NVL (pac_subtablas.f_vsubtabla (NULL,
                                                    /* 0028041/0152073 - JSV 03/09/2013 - INI*/
                                                    /*60319997,*/
                                                    NVL (pcsubtabla, 70310119),
                                                    3333,
                                                    2,
                                                    w_sproduc,
                                                    pcgarant,
                                                    reg.cdispositivo,
                                                    reg.cpropdisp
                                                   ),
                         1
                        );
            END IF;
         /**/
         END LOOP;
      /**/
      END IF;

      /**/
      RETURN w_factor;
   /**/
   END f_factor_disposi_pac;

   FUNCTION f_factor_deduci_pac (
      ptablas      IN   VARCHAR2,
      psseguro     IN   NUMBER,
      pnriesgo     IN   NUMBER,
      pfefecto     IN   DATE,
      pnmovimi     IN   NUMBER,
      pcgarant     IN   NUMBER,
      psproces     IN   NUMBER,
      pnmovima     IN   NUMBER,
      picapital    IN   NUMBER,
      /* 0028041/0152073 - JSV 03/09/2013*/
      pcsubtabla   IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      /**/
      w_fefecto   seguros.fefecto%TYPE;
      w_sproduc   seguros.sproduc%TYPE;
      w_factor    NUMBER;

      /**/
      CURSOR c_estbf
      IS
         SELECT a.*
           FROM estbf_bonfranseg a
          WHERE a.sseguro = psseguro
            AND a.nriesgo = pnriesgo
            AND a.nmovimi = pnmovimi
            AND a.cgrup IN (
                   SELECT b.codgrup
                     FROM bf_progarangrup b, bf_codgrup c
                    WHERE b.cempres = 12
                      AND b.sproduc = w_sproduc
                      AND b.cgarant = pcgarant
                      AND c.cempres = 12
                      AND c.cgrup = a.cgrup
                      AND c.ctipgrup = 2);

      CURSOR c_bf
      IS
         SELECT a.*
           FROM bf_bonfranseg a
          WHERE a.sseguro = psseguro
            AND a.nriesgo = pnriesgo
            AND a.nmovimi = pnmovimi
            AND a.cgrup IN (
                   SELECT b.codgrup
                     FROM bf_progarangrup b, bf_codgrup c
                    WHERE b.cempres = 12
                      AND b.sproduc = w_sproduc
                      AND b.cgarant = pcgarant
                      AND c.cempres = 12
                      AND c.cgrup = a.cgrup
                      AND c.ctipgrup = 2);
   /**/
   BEGIN
      /**/
      IF ptablas = 'EST'
      THEN
         /**/
         BEGIN
            SELECT sproduc
              INTO w_sproduc
              FROM estseguros
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS
            THEN
               w_sproduc := NULL;
         END;

         /**/
         w_factor := 1;

         FOR reg IN c_estbf
         LOOP
            /**/
            w_factor :=
                 w_factor
               * NVL (pac_subtablas.f_vsubtabla (NULL,
                                                 /* 0028041/0152073 - JSV 03/09/2013 - INI*/
                                                 /*60319997,*/
                                                 NVL (pcsubtabla, 70310118),
                                                 /* 0028041/0152073 - JSV 03/09/2013 - FIN*/
                                                 333333,
                                                 1,
                                                 w_sproduc,
                                                 pcgarant,
                                                 reg.cgrup,
                                                 reg.csubgrup,
                                                 reg.cversion,
                                                 reg.cnivel
                                                ),
                      1
                     );
         /**/
         END LOOP;
      /**/
      ELSE
         /**/
         BEGIN
            SELECT sproduc
              INTO w_sproduc
              FROM seguros
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS
            THEN
               w_sproduc := NULL;
         END;

         /**/
         w_factor := 1;

         FOR reg IN c_bf
         LOOP
            /**/
            w_factor :=
                 w_factor
               * NVL (pac_subtablas.f_vsubtabla (NULL,
                                                 /* 0028041/0152073 - JSV 03/09/2013 - INI*/
                                                 /*60319997,*/
                                                 NVL (pcsubtabla, 70310118),
                                                 333333,
                                                 1,
                                                 w_sproduc,
                                                 pcgarant,
                                                 reg.cgrup,
                                                 reg.csubgrup,
                                                 reg.cversion,
                                                 reg.cnivel
                                                ),
                      1
                     );
         /**/
         END LOOP;
      /**/
      END IF;

      /**/
      RETURN w_factor;
   /**/
   END f_factor_deduci_pac;

   /* Bug 30842/0172773 - 16/04/2014*/
   FUNCTION ftpcegr (psesion IN NUMBER, psproduc IN NUMBER, pcgarant IN NUMBER)
      RETURN NUMBER
   IS
      vcresdef   NUMBER;
      vsproduc   NUMBER;
      vresp      NUMBER;
      vretorno   NUMBER;
   BEGIN
      /* Buscamos la respuesta*/
      vresp := resp (psesion, 4085);

      /* Buscamos la respuesta por defecto*/
      BEGIN
         SELECT cresdef
           INTO vcresdef
           FROM pregunprogaran
          WHERE sproduc = psproduc AND cpregun = 4085 AND cgarant = pcgarant;
      EXCEPTION
         WHEN OTHERS
         THEN
            vcresdef := 0;
      END;

      SELECT DECODE (GREATEST (NVL (vresp, 0), vcresdef), vcresdef, 0, 1)
        INTO vretorno
        FROM DUAL;

      RETURN vretorno;
   END ftpcegr;

   FUNCTION f_modpi (
      psesion    IN   NUMBER,
      ptablas    IN   VARCHAR2,
      psseguro   IN   NUMBER,
      pnmovimi   IN   NUMBER
   )
      RETURN NUMBER
   IS
      num_err        NUMBER;
      v_mortalitat   NUMBER;
      vresp4919      pregunseg.trespue%TYPE;
      vcmodalidad    NUMBER;
      vcversion      aut_versiones.cversion%TYPE;
      vctipveh       aut_versiones.ctipveh%TYPE;
   BEGIN
      IF ptablas = 'EST'
      THEN
         SELECT cversion
           INTO vcversion
           FROM estautriesgos
          WHERE sseguro = psseguro
                                  /*  AND nriesgo = pnriesgo*/
                AND nmovimi = pnmovimi;
      ELSE
         SELECT cversion
           INTO vcversion
           FROM autriesgos
          WHERE sseguro = psseguro
                                  /*  AND nriesgo = pnriesgo*/
                AND nmovimi = pnmovimi;
      END IF;

      IF vcversion IS NOT NULL
      THEN
         SELECT ctipveh
           INTO vctipveh
           FROM aut_versiones
          WHERE cversion = vcversion;

         IF vctipveh = 23 OR vctipveh = 25 OR vctipveh = 51
         THEN
            RETURN 0;                                         /*modalidad 0*/
         ELSE
            IF ptablas = 'EST'
            THEN
               BEGIN
                  SELECT e.crespue
                    INTO vresp4919
                    FROM estpregunseg e
                   WHERE e.sseguro = psseguro
                     AND e.nmovimi = pnmovimi
                     AND e.cpregun = 4919;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     NULL;
               END;
            ELSE
               BEGIN
                  SELECT e.trespue
                    INTO vresp4919
                    FROM pregunseg e
                   WHERE e.sseguro = psseguro
                     AND e.nmovimi = pnmovimi
                     AND e.cpregun = 4919;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     NULL;
               END;
            END IF;
         END IF;
      END IF;

      SELECT DECODE (vresp4919,
                     1, 1,
                     2, 1,
                     3, 1,
                     4, 1,
                     5, 2,
                     6, 2,
                     7, 2,
                     8, 2,
                     9, 2,
                     0
                    )
        INTO vcmodalidad
        FROM DUAL;

      RETURN vcmodalidad;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_propio_albsgt_conf.f_cmodalidad_pi',
                      99,
                         ' - ptablas  '
                      || ptablas
                      || ' - psseguro '
                      || psseguro
                      || ' - pnmovimi '
                      || pnmovimi
                      || ' - vcmodalidad '
                      || vcmodalidad,
                      SQLERRM
                     );
         RETURN NULL;
   END f_modpi;

   /* Bug 31686/178163 - 26/06/2014 - AMC*/
   FUNCTION f_m6047 (
      psesion    IN   NUMBER,
      psseguro   IN   NUMBER,
      pnriesgo   IN   NUMBER,
      pnmovimi   IN   NUMBER
   )
      RETURN NUMBER
   IS
      vcversion   aut_versiones.cversion%TYPE;
      vctipveh    aut_versiones.ctipveh%TYPE;
      vresp4919   NUMBER;
   BEGIN
      SELECT cversion
        INTO vcversion
        FROM estautriesgos
       WHERE sseguro = psseguro AND nriesgo = pnriesgo AND nmovimi = pnmovimi;

      IF vcversion IS NOT NULL
      THEN
         SELECT ctipveh
           INTO vctipveh
           FROM aut_versiones
          WHERE cversion = vcversion;

         IF vctipveh = 23 OR vctipveh = 25 OR vctipveh = 51
         THEN
            RETURN 1;
         ELSE
            BEGIN
               SELECT e.crespue
                 INTO vresp4919
                 FROM estpregunseg e
                WHERE e.sseguro = psseguro
                  AND e.nmovimi = pnmovimi
                  AND e.nriesgo = pnriesgo
                  AND e.cpregun = 4919;
            EXCEPTION
               WHEN OTHERS
               THEN
                  NULL;
            END;

            /* PU(9),PIM(5),PID(6),PE(7),PES(8)*/
            IF vresp4919 IN (5, 6, 7, 8, 9)
            THEN
               RETURN 3;
            END IF;

            /* CN(2),DU(4),UT(1),VOL(3)*/
            IF vresp4919 IN (1, 2, 3, 4)
            THEN
               RETURN 4;
            END IF;

            RETURN NULL;
         END IF;
      ELSE
         RETURN NULL;
      END IF;

      RETURN NULL;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_propio_albsgt_conf.f_mod6047',
                      99,
                         '- psseguro:'
                      || psseguro
                      || ' - pnmovimi:'
                      || pnmovimi
                      || ' - pnriesgo:'
                      || pnriesgo,
                      SQLERRM
                     );
         RETURN NULL;
   END f_m6047;

   /* Bug 31686/178163 - 30/06/2014 - AMC*/
   FUNCTION f_pgara (
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
      vpas          NUMBER                        := 0;
      v_con_rcco    NUMBER;
      v_con_exe     NUMBER;
      vcversion     aut_versiones.cversion%TYPE;
      vctipveh      aut_versiones.ctipveh%TYPE;
      vccla         NUMBER;
      vresp4919     NUMBER;
      vsseguro_0    NUMBER;
      vparam        VARCHAR2 (1000)
         :=    'ptablas'
            || ptablas
            || ' psseguro:'
            || psseguro
            || ' pnriesgo:'
            || pnriesgo
            || ' pnmovimi:'
            || pnmovimi
            || ' pcgarant:'
            || pcgarant
            || ' psproces '
            || psproces
            || '  pnmovima '
            || pnmovima
            || '  picapital '
            || picapital;
      vnmovimi_0    NUMBER;            /*Bug 32705/191671 - 12/11/2014 - AMC*/
      numerr        NUMBER;
      w_resp_4089   NUMBER;
   BEGIN
      vpas := 1;
      numerr :=
         pac_preguntas.f_get_pregunpolseg (psseguro,
                                           4089,
                                           NVL (ptablas, 'SEG'),
                                           w_resp_4089
                                          );
      vpas := 2;

      IF ptablas = 'EST'
      THEN
         SELECT cversion
           INTO vcversion
           FROM estautriesgos
          WHERE sseguro = psseguro
            /*AND nriesgo = NVL(w_resp_4089, 1)*/
            AND nriesgo = NVL (pnriesgo, 1)                       /*qt 19342*/
            AND nmovimi = pnmovimi;
      ELSE
         SELECT cversion
           INTO vcversion
           FROM autriesgos
          WHERE sseguro = psseguro
            /*AND nriesgo = NVL(w_resp_4089, 1)*/
            AND nriesgo = NVL (pnriesgo, 1)                       /*qt 19342*/
            AND nmovimi = pnmovimi;
      END IF;

      vpas := 3;

      /* Buscamos la clase de vehiculo*/
      SELECT ctipveh
        INTO vctipveh
        FROM aut_versiones
       WHERE cversion = vcversion;

      vpas := 4;

      /* Buscamos el sseguro de caratula*/
      IF ptablas = 'EST'
      THEN
         SELECT sseguro
           INTO vsseguro_0
           FROM seguros
          WHERE npoliza = (SELECT npoliza
                             FROM estseguros
                            WHERE sseguro = psseguro) AND ncertif = 0;
      ELSE
         SELECT sseguro
           INTO vsseguro_0
           FROM seguros
          WHERE npoliza = (SELECT npoliza
                             FROM seguros
                            WHERE sseguro = psseguro) AND ncertif = 0;
      END IF;

      vpas := 5;

      /*Bug 32705/191671 - 12/11/2014 - AMC*/
      /* Último movimiento de caratula*/
      SELECT MAX (nmovimi)
        INTO vnmovimi_0
        FROM garanseg
       WHERE sseguro = vsseguro_0 AND ffinefe IS NULL;

      vpas := 6;

      /* Si estamos en un remolque cogemos la columna 3.*/
      IF vctipveh = 23 OR vctipveh = 25 OR vctipveh = 51
      THEN
         vpas := 7;

         SELECT ccla3
           INTO vccla
           FROM subtabs_seg_det
          WHERE sseguro = vsseguro_0
            AND nriesgo = NVL (w_resp_4089, 1)
            AND cgarant = pcgarant
            AND nmovimi = vnmovimi_0   /*Bug 32705/191671 - 12/11/2014 - AMC*/
            AND cpregun = 9137;

         RETURN vccla;
      ELSE
         vpas := 8;

         /* Si la clase del vehiculo no es remolque, miramos que linea tiene y si tiene contratada la RCCO y EXE.*/
         IF ptablas = 'EST'
         THEN
            vpas := 9;

            /* Miramos si tiene contratada la RCC0*/
            SELECT COUNT (1)
              INTO v_con_rcco
              FROM estgaranseg g, estpregungaranseg p
             WHERE g.sseguro = psseguro
               AND g.nriesgo = pnriesgo
               AND g.nmovimi = pnmovimi
               AND g.cgarant = 786
               AND g.cobliga = 1
               AND p.sseguro = psseguro
               AND p.nriesgo = pnriesgo
               AND p.nmovimi = pnmovimi
               AND p.cgarant = 786
               AND p.cpregun = 9094
               AND p.crespue = 1;

            vpas := 10;

            /* Miramos si tiene contratada la EXE*/
            SELECT COUNT (1)
              INTO v_con_exe
              FROM estgaranseg g, estpregungaranseg p
             WHERE g.sseguro = psseguro
               AND g.nriesgo = pnriesgo
               AND g.nmovimi = pnmovimi
               AND g.cgarant = 774
               AND g.cobliga = 1
               AND p.sseguro = psseguro
               AND p.nriesgo = pnriesgo
               AND p.nmovimi = pnmovimi
               AND p.cgarant = 774
               AND p.cpregun = 9094
               AND p.crespue = 1;

            vpas := 11;

            SELECT e.crespue
              INTO vresp4919
              FROM estpregunseg e
             WHERE e.sseguro = psseguro
               AND e.nmovimi = pnmovimi
               AND e.nriesgo = pnriesgo               /* NVL(w_resp_4089, 1)*/
               AND e.cpregun = 4919;

            vpas := 12;
         ELSE
            vpas := 13;

            /* Miramos si tiene contratada la RCCO*/
            SELECT COUNT (1)
              INTO v_con_rcco
              FROM garanseg g, pregungaranseg p
             WHERE g.sseguro = psseguro
               AND g.nriesgo = pnriesgo
               AND g.nmovimi = pnmovimi
               AND g.cgarant = 786
               AND p.sseguro = psseguro
               AND p.nriesgo = pnriesgo
               AND p.nmovimi = pnmovimi
               AND p.cgarant = 786
               AND p.cpregun = 9094
               AND p.crespue = 1;

            vpas := 14;

            /* Miramos si tiene contratada la EXE*/
            SELECT COUNT (1)
              INTO v_con_exe
              FROM garanseg g, pregungaranseg p
             WHERE g.sseguro = psseguro
               AND g.nriesgo = pnriesgo
               AND g.nmovimi = pnmovimi
               AND g.cgarant = 774
               AND p.sseguro = psseguro
               AND p.nriesgo = pnriesgo
               AND p.nmovimi = pnmovimi
               AND p.cgarant = 786
               AND p.cpregun = 9094
               AND p.crespue = 1;

            vpas := 15;

            SELECT e.crespue
              INTO vresp4919
              FROM pregunseg e
             WHERE e.sseguro = psseguro
               AND e.nmovimi = pnmovimi
               AND e.nriesgo = pnriesgo                /*NVL(w_resp_4089, 1)*/
               AND e.cpregun = 4919;

            vpas := 16;
         END IF;

         vpas := 17;

         /* Si hemos contratado la RCCO y la linea de vehículo es PU(9),PIM(5),PID(6),PE(7),PES(8)*/
         IF v_con_rcco = 1 AND vresp4919 IN (5, 6, 7, 8, 9)
         THEN
            vpas := 18;

            SELECT ccla1
              INTO vccla
              FROM subtabs_seg_det
             WHERE sseguro = vsseguro_0
               AND nriesgo = NVL (w_resp_4089, 1)
               AND cgarant = pcgarant
               AND nmovimi = vnmovimi_0
               /*Bug 32705/191671 - 12/11/2014 - AMC*/
               AND cpregun = 9137;

            RETURN vccla;
         /* Si hemos contratado la EXE y la linea de vehículo es PU(9),PIM(5),PID(6),PE(7),PES(8)*/
         ELSIF v_con_exe = 1 AND vresp4919 NOT IN (5, 6, 7, 8, 9)
         THEN
            vpas := 19;

            SELECT ccla2
              INTO vccla
              FROM subtabs_seg_det
             WHERE sseguro = vsseguro_0
               AND nriesgo = NVL (w_resp_4089, 1)
               AND cgarant = pcgarant
               AND nmovimi = vnmovimi_0
               /*Bug 32705/191671 - 12/11/2014 - AMC*/
               AND cpregun = 9137;

            RETURN vccla;
         /* Cogemremos la columana 4 cuando :*/
         /* Si:*/
         /* Tiene contratada la RCCO y no la EXE y la linea de vehículo es  CN , DU, UT, VOL*/
         /* Tiene contratada la EXE y no la RCCO y la linea de vehículo es PU, PIM, PID, PE,PES*/
         /* No teien contratada ni la EXE ni la RCCO.*/
         ELSE
            vpas := 20;

            SELECT ccla4
              INTO vccla
              FROM subtabs_seg_det
             WHERE sseguro = vsseguro_0
               AND nriesgo = NVL (w_resp_4089, 1)
               AND cgarant = pcgarant
               AND nmovimi = vnmovimi_0
               /*Bug 32705/191671 - 12/11/2014 - AMC*/
               AND cpregun = 9137;

            RETURN vccla;
         END IF;
      END IF;

      vpas := 99;
      /* Si no ha entrado por ningún if ... malo... no ha ido bien!!!*/
      p_tab_error (f_sysdate,
                   f_user,
                   'pac_propio_albsgt_conf.f_pgara',
                   vpas,
                   vparam,
                   SQLERRM
                  );
      RETURN NULL;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_propio_albsgt_conf.f_pgara',
                      vpas,
                      vparam,
                      SQLERRM
                     );
         RETURN NULL;
   END f_pgara;

   FUNCTION f_moawl (
      psesion    IN   NUMBER,
      psseguro   IN   NUMBER,
      pnriesgo   IN   NUMBER,
      pnmovimi   IN   NUMBER
   )
      RETURN NUMBER
   IS
      vcversion   aut_versiones.cversion%TYPE;
      vctipveh    aut_versiones.ctipveh%TYPE;
   BEGIN
      BEGIN
         SELECT cversion
           INTO vcversion
           FROM estautriesgos
          WHERE sseguro = psseguro AND nriesgo = pnriesgo
                AND nmovimi = pnmovimi;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            RETURN NULL;
      END;

      IF vcversion IS NOT NULL
      THEN
         SELECT ctipveh
           INTO vctipveh
           FROM aut_versiones
          WHERE cversion = vcversion;

         IF vctipveh IN (1, 2, 6, 8, 20, 21)
         THEN
            RETURN 1;
         ELSIF vctipveh IN (3, 4, 7, 12, 22, 23, 25, 26)
         THEN
            RETURN 2;
         ELSIF vctipveh IN (17, 18, 19)
         THEN
            RETURN 3;
         END IF;
      ELSE
         RETURN NULL;
      END IF;

      RETURN NULL;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_propio_albsgt_conf.f_moAWL',
                      99,
                         '- psseguro:'
                      || psseguro
                      || ' - pnmovimi:'
                      || pnmovimi
                      || ' - pnriesgo:'
                      || pnriesgo,
                      SQLERRM
                     );
         RETURN NULL;
   END f_moawl;

/*------------------------------------------------------------------------*/
/* BUG 32570 MW - 6043 - MRB 03/09/2014*/
/*------------------------------------------------------------------------*/
   FUNCTION f_agrup_vehi (
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
      /**/
      w_cversion     autriesgos.cversion%TYPE;
      w_agrtiponum   NUMBER;
      w_error        NUMBER                     := 0;

/*------------------------------------------------------------------------*/
      PROCEDURE p_autriesgos (
         p_tablas     IN       VARCHAR2,
         p_sseguro    IN       NUMBER,
         p_nriesgo    IN       NUMBER,
         p_nmovimi    IN       NUMBER,
         p_cversion   OUT      VARCHAR2
      )
      IS
      BEGIN
         IF ptablas = 'EST'
         THEN
            BEGIN
               SELECT cversion
                 INTO p_cversion
                 FROM estautriesgos
                WHERE sseguro = p_sseguro
                  AND nriesgo = p_nriesgo
                  AND nmovimi = p_nmovimi;
            EXCEPTION
               WHEN OTHERS
               THEN
                  p_cversion := NULL;
            END;
         ELSE
            BEGIN
               SELECT cversion
                 INTO p_cversion
                 FROM autriesgos
                WHERE sseguro = p_sseguro
                  AND nriesgo = p_nriesgo
                  AND nmovimi = p_nmovimi;
            EXCEPTION
               WHEN OTHERS
               THEN
                  p_cversion := NULL;
            END;
         END IF;
      /**/
      END;

/*------------------------------------------------------------------------*/
      PROCEDURE p_autversiones (
         p_sseguro       IN       NUMBER,
         p_nriesgo       IN       NUMBER,
         p_nmovimi       IN       NUMBER,
         p_cversion      IN       VARCHAR2,
         p_cagrtiponum   OUT      NUMBER
      )
      IS
         /**/
         w_cagrtipo   aut_versiones.cagrtipo%TYPE;
      /**/
      BEGIN
         /**/
         BEGIN
            SELECT cagrtipo
              INTO w_cagrtipo
              FROM aut_versiones
             WHERE cversion = p_cversion;
         EXCEPTION
            WHEN OTHERS
            THEN
               w_cagrtipo := NULL;
         END;

         /**/
         IF w_cagrtipo IS NOT NULL
         THEN
            BEGIN
               SELECT cagrtiponum
                 INTO p_cagrtiponum
                 FROM aut_codagrtipo
                WHERE cagrtipo = w_cagrtipo;
            EXCEPTION
               WHEN OTHERS
               THEN
                  p_cagrtiponum := NULL;
            END;
         END IF;
      /**/
      END;
/*------------------------------------------------------------------------*/
/* Cuerpo principal de f_agrup_vehi*/
/*------------------------------------------------------------------------*/
   BEGIN
      /**/
      p_autriesgos (ptablas, psseguro, pnriesgo, pnmovimi, w_cversion);

      /**/
      IF w_cversion IS NULL
      THEN
         w_error := 1;
      ELSE
         /**/
         p_autversiones (psseguro,
                         pnriesgo,
                         pnmovimi,
                         w_cversion,
                         w_agrtiponum
                        );

         /**/
         IF w_agrtiponum IS NULL
         THEN
            w_error := 1;
         END IF;
      END IF;

      /**/
      IF w_error = 1
      THEN
         w_agrtiponum := NULL;
      END IF;

      /**/
      RETURN w_agrtiponum;
   /**/
   END f_agrup_vehi;

/*------------------------------------------------------------------------*/
/* BUG 32570 - MRB - 04/09/2014*/
   FUNCTION f_arrastra_pretabcolum (
      ptablas     IN   VARCHAR2,
      psseguro    IN   NUMBER,
      pnriesgo    IN   NUMBER,
      pfefecto    IN   DATE,
      pnmovimi    IN   NUMBER,
      pcgarant    IN   NUMBER,
      psproces    IN   NUMBER,
      pnmovima    IN   NUMBER,
      picapital   IN   NUMBER,
      pcpregun    IN   NUMBER,
      pnval       IN   NUMBER DEFAULT 1
   )
      RETURN NUMBER
   IS
      v_crespue    estpregunpolseg.crespue%TYPE;
      v_npoliza    estseguros.npoliza%TYPE;
      numerr       NUMBER;
      ntraza       NUMBER;
      visaltacol   BOOLEAN                        := FALSE;
      v_ncertif    NUMBER;
      v_sproduc    NUMBER;
      v_agrup      NUMBER;
   BEGIN
      /**/
      BEGIN
         /**/
         IF ptablas = 'EST'
         THEN
            SELECT npoliza, ncertif
              INTO v_npoliza, v_ncertif
              FROM estseguros
             WHERE sseguro = psseguro;
         ELSE
            SELECT npoliza, ncertif
              INTO v_npoliza, v_ncertif
              FROM seguros
             WHERE sseguro = psseguro;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            v_npoliza := pac_iax_produccion.poliza.det_poliza.npoliza;
            v_sproduc := pac_iax_produccion.poliza.det_poliza.sproduc;
      END;

      IF pac_seguros.f_soycertifcero (v_sproduc, v_npoliza, psseguro) = 1
      THEN                                         /* No es el certificado 0*/
         v_agrup :=
            pac_propio_albsgt_conf.f_agrup_vehi (ptablas,
                                                 psseguro,
                                                 pnriesgo,
                                                 pfefecto,
                                                 pnmovimi,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL
                                                );
         /* Se manda -1 en sesión para que coja el f_sysdate*/
         v_crespue :=
            NVL (pac_subtablas_seg.f_cero_seg (-1,
                                               psseguro,
                                               pnriesgo,
                                               pcgarant,
                                               pnmovimi,
                                               pcpregun,
                                               3,
                                               pnval,
                                               ptablas,
                                               v_agrup
                                              ),
                 0
                );
      ELSE
         v_crespue := NULL;
      END IF;

      RETURN v_crespue;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_propio_albsgt_conf.f_arrastra_pretabcolum',
                      ntraza,
                         ' - ptablas  '
                      || ptablas
                      || ' - psseguro '
                      || psseguro
                      || ' - pnriesgo '
                      || pnriesgo
                      || ' - pfefecto '
                      || pfefecto
                      || ' - pnmovimi '
                      || pnmovimi
                      || ' - pcpregun '
                      || pcpregun
                      || ' - pnval '
                      || pnval,
                      SQLERRM
                     );
         RETURN NULL;
   END f_arrastra_pretabcolum;

   /*Bug 34366/196533 - 27/01/2015 - AMC*/
   FUNCTION f_factorg (
      ptablas     IN   VARCHAR2,
      psseguro    IN   NUMBER,
      pnriesgo    IN   NUMBER,
      pfefecto    IN   DATE,
      pnmovimi    IN   NUMBER,
      pcgarant    IN   NUMBER,
      psproces    IN   NUMBER,
      pnmovima    IN   NUMBER,
      picapital   IN   NUMBER,
      pnpoliza    IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      vfactorg   NUMBER;
      ntraza     NUMBER;
      vtabla     NUMBER;
   BEGIN
      IF     NVL
                (f_parproductos_v
                                (pac_iax_produccion.poliza.det_poliza.sproduc,
                                 'ADMITE_CERTIFICADOS'
                                ),
                 0
                ) = 1
         AND NOT f_alta_certificado (ptablas, psseguro)
      THEN
         ntraza := 1;
         vfactorg :=
            f_arrastra_pregunta_plan (NVL (ptablas, 'SEG'),
                                      psseguro,
                                      pnriesgo,
                                      pfefecto,
                                      pnmovimi,
                                      pcgarant,
                                      psproces,
                                      pnmovima,
                                      picapital,
                                      9212
                                     );
      ELSE
         ntraza := 2;

         IF pac_iax_produccion.poliza.det_poliza.sproduc = 6041
         THEN
            vtabla := 60419995;
         ELSE
            vtabla := 60319995;
         END IF;

         vfactorg :=
            pac_subtablas.f_vsubtabla
                                 (NULL,
                                  vtabla,
                                  3,
                                  1,
                                  pac_iax_produccion.poliza.det_poliza.sproduc
                                 );
      END IF;

      RETURN vfactorg;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_propio_albsgt_conf.f_factorg',
                      ntraza,
                         ' - ptablas  '
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
                      || ' - pnmovima '
                      || pnmovima
                      || ' - pnpoliza '
                      || pnpoliza,
                      SQLERRM
                     );
         RETURN NULL;
   END f_factorg;

   /*Bug 34345/196823 - 29/01/2015 - AMC*/
   FUNCTION f_notas_tecnicas_nuevas (
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
      vsproduc       NUMBER;
      num_err        NUMBER;
      v_mortalitat   NUMBER;
      vresp4044_n    NUMBER;
      ntraza         NUMBER;
   BEGIN
      ntraza := 1;

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

      ntraza := 2;
      vresp4044_n :=
         f_fefecto_migracion (ptablas,
                              psseguro,
                              pnriesgo,
                              pfefecto,
                              pnmovimi,
                              pcgarant,
                              psproces,
                              pnmovima,
                              picapital
                             );
      ntraza := 3;

      SELECT pac_subtablas.f_vsubtabla (NULL, 60600002, 2, 1, vresp4044_n)
        INTO v_mortalitat
        FROM DUAL;

      RETURN v_mortalitat;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_propio_albsgt_conf.f_notas_tecnicas_nuevas',
                      ntraza,
                         ' - ptablas  '
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
                      || ' - pnmovima '
                      || pnmovima,
                      SQLERRM
                     );
         RETURN NULL;
   END f_notas_tecnicas_nuevas;

/*------------------------------------------------------------------------*/
/* BUG 0035517 - FAL - 29/04/2015*/
   FUNCTION f_nriesgo_aseg_pcpal (
      ptablas     IN   VARCHAR2,
      psseguro    IN   NUMBER,
      pnriesgo    IN   NUMBER,
      pfefecto    IN   DATE,
      pnmovimi    IN   NUMBER,
      cgarant     IN   NUMBER,
      psproces    IN   NUMBER,
      pnmovima    IN   NUMBER,
      picapital   IN   NUMBER
   )
      RETURN NUMBER
   IS
      w_nriesgo_ase_pcpal   NUMBER;
   BEGIN
      w_nriesgo_ase_pcpal := NULL;

      BEGIN
         IF ptablas = 'EST'
         THEN
            SELECT nriesgo
              INTO w_nriesgo_ase_pcpal
              FROM estpregunseg
             WHERE sseguro = psseguro
               AND cpregun = 4796
               AND crespue = 1
               AND nmovimi = pnmovimi;
         ELSIF ptablas = 'SOL'
         THEN
            SELECT nriesgo
              INTO w_nriesgo_ase_pcpal
              FROM solpregunseg
             WHERE ssolicit = psseguro
               AND cpregun = 4796
               AND crespue = 1
               AND nmovimi = pnmovimi;
         ELSE
            SELECT nriesgo
              INTO w_nriesgo_ase_pcpal
              FROM pregunseg
             WHERE sseguro = psseguro
               AND cpregun = 4796
               AND crespue = 1
               AND nmovimi = pnmovimi;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            w_nriesgo_ase_pcpal := NULL;
      END;

      RETURN w_nriesgo_ase_pcpal;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_propio_albsgt_conf.f_nriesgo_aseg_pcpal',
                      99,
                         '- psseguro:'
                      || psseguro
                      || ' - pnmovimi:'
                      || pnmovimi
                      || ' - pnriesgo:'
                      || pnriesgo,
                      SQLERRM
                     );
         RETURN NULL;
   END f_nriesgo_aseg_pcpal;

   /*Bug 37029/210540 - 22/07/2015*/
   FUNCTION f_reparte_peso (
      ptablas     IN   VARCHAR2,
      psseguro    IN   NUMBER,
      pnriesgo    IN   NUMBER,
      pfefecto    IN   DATE,
      pnmovimi    IN   NUMBER,
      cgarant     IN   NUMBER,
      psproces    IN   NUMBER,
      pnmovima    IN   NUMBER,
      picapital   IN   NUMBER
   )
      RETURN NUMBER
   IS
      vsumpeso            NUMBER := 0;
      vrestopeso          NUMBER := 0;
      vsumpesorepartido   NUMBER := 0;
      vnumgaran           NUMBER := 0;
      vres9224            NUMBER := 0;
      vnumrepar           NUMBER := 0;
      vpas                NUMBER := 0;
   BEGIN
      vpas := 1;

      IF ptablas = 'EST'
      THEN
         SELECT SUM (crespue)
           INTO vsumpeso
           FROM estpregungaranseg
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND nmovimi = pnmovimi
            AND cpregun = 9095;

         vpas := 2;
         vrestopeso := 100 - vsumpeso;
         vpas := 3;

         SELECT COUNT (1)
           INTO vnumgaran
           FROM estpregungaranseg
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND nmovimi = pnmovimi
            AND cpregun = 9095;
      ELSE
         SELECT SUM (crespue)
           INTO vsumpeso
           FROM pregungaranseg
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND nmovimi = pnmovimi
            AND cpregun = 9095;

         vpas := 2;
         vrestopeso := 100 - vsumpeso;
         vpas := 3;

         SELECT COUNT (1)
           INTO vnumgaran
           FROM pregungaranseg
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND nmovimi = pnmovimi
            AND cpregun = 9095;
      END IF;

      vpas := 4;

      SELECT COUNT (1)
        INTO vnumrepar
        FROM pregungarancar
       WHERE sproces = psproces
         AND sseguro = psseguro
         AND nriesgo = pnriesgo
         AND nmovimi = pnmovimi
         AND cpregun = 9224;

      vpas := 5;

      SELECT SUM (crespue)
        INTO vsumpesorepartido
        FROM pregungarancar
       WHERE sproces = psproces
         AND sseguro = psseguro
         AND nriesgo = pnriesgo
         AND nmovimi = pnmovimi
         AND cpregun = 9224;

      IF (vnumgaran - vnumrepar) = 1
      THEN
         vres9224 := vrestopeso - vsumpesorepartido;
      ELSE
         SELECT vrestopeso / vnumgaran
           INTO vres9224
           FROM DUAL;

         vres9224 := ROUND (vres9224, 2);
      END IF;

      RETURN vres9224;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_propio_albsgt_conf.f_reparte _peso',
                      vpas,
                         '- psseguro:'
                      || psseguro
                      || ' - pnmovimi:'
                      || pnmovimi
                      || ' - pnriesgo:'
                      || pnriesgo,
                      SQLERRM
                     );
         RETURN NULL;
   END f_reparte_peso;

   FUNCTION f_respues_recibo_por (
      ptablas     IN   VARCHAR2,
      psseguro    IN   NUMBER,
      pnriesgo    IN   NUMBER,
      pfefecto    IN   DATE,
      pnmovimi    IN   NUMBER,
      cgarant     IN   NUMBER,
      psproces    IN   NUMBER,
      pnmovima    IN   NUMBER,
      picapital   IN   NUMBER,
      pcpregun    IN   NUMBER
   )
      RETURN NUMBER
   IS
      n_crespue   NUMBER;
   BEGIN
      IF ptablas = 'EST'
      THEN
         SELECT crespue
           INTO n_crespue
           FROM estpregunpolseg
          WHERE sseguro = psseguro AND cpregun = 4092 AND nmovimi = pnmovimi;
      ELSE
         SELECT crespue
           INTO n_crespue
           FROM pregunpolseg
          WHERE sseguro = psseguro AND cpregun = 4092 AND nmovimi = pnmovimi;
      END IF;

      IF n_crespue = 1 AND pcpregun = 535
      THEN
         RETURN 100;
      ELSIF n_crespue = 2 AND pcpregun = 535
      THEN
         RETURN 0;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_propio_albsgt_conf.f_respues_recibo_por',
                      1,
                         '- ptablas:'
                      || ptablas
                      || '- psseguro:'
                      || psseguro
                      || ' - pnmovimi:'
                      || pnmovimi
                      || ' - pnriesgo:'
                      || pnriesgo,
                      SQLERRM
                     );
         RETURN NULL;
   END f_respues_recibo_por;

   FUNCTION f_valida_comisiones (
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
      pcpregun         VARCHAR2
   )
      RETURN NUMBER
   IS
      CURSOR c_est_seguro
      IS
         SELECT ctipcom
           FROM estseguros
          WHERE sseguro = psseguro;

      v_ctipcom   estseguros.ctipcom%TYPE;
      vpas        NUMBER                    := 0;
   BEGIN
      OPEN c_est_seguro;

      FETCH c_est_seguro
       INTO v_ctipcom;

      CLOSE c_est_seguro;

      IF v_ctipcom = 92
      THEN
         RETURN 0;
      END IF;

      RETURN 9909209;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_propio_albsgt_conf.f_valida_comision _peso',
                      vpas,
                         '- psseguro:'
                      || psseguro
                      || ' - pnmovimi:'
                      || pnmovimi
                      || ' - pnriesgo:'
                      || pnriesgo,
                      SQLERRM
                     );
         RETURN 9909209;
   END f_valida_comisiones;

   FUNCTION f_valida_comisiones_unif (
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
      pcpregun         VARCHAR2
   )
      RETURN NUMBER
   IS
      CURSOR c_est_seguro
      IS
         SELECT ctipcom, cactivi
           FROM estseguros
          WHERE sseguro = psseguro;

      v_ctipcom   estseguros.ctipcom%TYPE;
      v_cactivi   estseguros.cactivi%TYPE;
      vpas        NUMBER                    := 0;
      mensaje     NUMBER                    := 0;
      n_respue    NUMBER                    := 0;
      num_err     NUMBER                    := 0;
   BEGIN
      OPEN c_est_seguro;

      FETCH c_est_seguro
       INTO v_ctipcom, v_cactivi;

      CLOSE c_est_seguro;

      IF (v_ctipcom = 92)
      THEN
         num_err :=
            pac_preguntas.f_get_pregunpolseg (psseguro,
                                              2913,
                                              NVL (ptablas, 'EST'),
                                              n_respue
                                             );


p_tab_error (f_sysdate,
                   f_user,
                   'comisio listval',
                   2,
                   n_respue||' '||psseguro,
                   'n_respue--> ' ||n_respue
                  );
         IF NVL (n_respue, 0) = 0
         THEN
            mensaje := 89906045;
         ELSE
            mensaje := 0;
         END IF;
      ELSE
         mensaje := 9909209;
      END IF;

      IF mensaje = 0
      THEN
--aca validamos que si la actividad no es particular la pregunta de grandes beneficiarios no puede ser contestada
         IF v_cactivi <> 1
         THEN
            num_err :=
               pac_preguntas.f_get_pregunpolseg (psseguro,
                                                 2913,
                                                 NVL (ptablas, 'EST'),
                                                 n_respue
                                                );

            IF (NVL (n_respue, 0) > 0 OR (v_ctipcom = 92))
            THEN
               mensaje := 89906045;
            ELSE
               mensaje := 0;
            END IF;
         END IF;
      END IF;

      RETURN mensaje;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_propio_albsgt_conf.f_valida_comision _peso',
                      vpas,
                         '- psseguro:'
                      || psseguro
                      || ' - pnmovimi:'
                      || pnmovimi
                      || ' - pnriesgo:'
                      || pnriesgo,
                      SQLERRM
                     );
         RETURN 9909209;
   END f_valida_comisiones_unif;

   FUNCTION f_valida_comision_rce (
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
      pcpregun         VARCHAR2
   )
      RETURN NUMBER
   IS
      CURSOR c_est_seguro
      IS
         SELECT ctipcom
           FROM estseguros
          WHERE sseguro = psseguro;

      v_ctipcom    estseguros.ctipcom%TYPE;
      vpas         NUMBER                      := 0;
      wresp_2912   pregunpolseg.crespue%TYPE;
      werr         NUMBER                      := 0;
   BEGIN
      OPEN c_est_seguro;

      FETCH c_est_seguro
       INTO v_ctipcom;

      CLOSE c_est_seguro;

      IF v_ctipcom = 90
      THEN
         werr :=
            pac_preguntas.f_get_pregunpolseg (psseguro,
                                              2912,
                                              NVL (ptablas, 'EST'),
                                              wresp_2912
                                             );

         IF werr = 0
         THEN
            IF NVL (wresp_2912, 0) != 0
            THEN
               RETURN 0;
            ELSE
               RETURN 9909268;
            END IF;
         END IF;
      END IF;

      RETURN 9909209;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_propio_albsgt_conf.f_valida_comision _peso',
                      vpas,
                         '- psseguro:'
                      || psseguro
                      || ' - pnmovimi:'
                      || pnmovimi
                      || ' - pnriesgo:'
                      || pnriesgo,
                      SQLERRM
                     );
         RETURN 9909209;
   END f_valida_comision_rce;

   FUNCTION f_recuperar_vsubtabla (
      ptablas          IN   VARCHAR2,
      psseguro         IN   NUMBER,
      pnriesgo         IN   NUMBER,
      pfefecto         IN   DATE,
      pnmovimi         IN   NUMBER,
      cgarant          IN   NUMBER,
      psproces         IN   NUMBER,
      pnmovima         IN   NUMBER,
      picapital        IN   NUMBER,
      p_in_nsesion     IN   NUMBER,
      p_in_csubtabla   IN   sgt_subtabs_det.csubtabla%TYPE,
      p_in_cquery      IN   VARCHAR2,
      p_in_cval        IN   NUMBER,
      p_in_ccla1       IN   sgt_subtabs_det.ccla1%TYPE,
      p_in_ccla2       IN   sgt_subtabs_det.ccla2%TYPE DEFAULT NULL,
      p_in_ccla3       IN   sgt_subtabs_det.ccla3%TYPE DEFAULT NULL,
      p_in_ccla4       IN   sgt_subtabs_det.ccla4%TYPE DEFAULT NULL,
      p_in_ccla5       IN   sgt_subtabs_det.ccla5%TYPE DEFAULT NULL,
      p_in_ccla6       IN   sgt_subtabs_det.ccla6%TYPE DEFAULT NULL,
      p_in_ccla7       IN   sgt_subtabs_det.ccla7%TYPE DEFAULT NULL,
      p_in_ccla8       IN   sgt_subtabs_det.ccla8%TYPE DEFAULT NULL,
      p_in_ccla9       IN   sgt_subtabs_det.ccla9%TYPE DEFAULT NULL,
      p_in_ccla10      IN   sgt_subtabs_det.ccla10%TYPE DEFAULT NULL,
      p_in_v_fecha     IN   DATE DEFAULT NULL
   )
      RETURN NUMBER
   IS
   BEGIN
      RETURN pac_subtablas.f_vsubtabla (p_in_nsesion,
                                        p_in_csubtabla,
                                        p_in_cquery,
                                        p_in_cval,
                                        p_in_ccla1,
                                        p_in_ccla2,
                                        p_in_ccla3,
                                        p_in_ccla4,
                                        p_in_ccla5,
                                        p_in_ccla6,
                                        p_in_ccla7,
                                        p_in_ccla8,
                                        p_in_ccla9,
                                        p_in_ccla10,
                                        p_in_v_fecha
                                       );
   END;

   FUNCTION f_recuperar_tasa_convenio (
      ptablas          IN   VARCHAR2,
      psseguro         IN   NUMBER,
      pnriesgo         IN   NUMBER,
      pfefecto         IN   DATE,
      pnmovimi         IN   NUMBER,
      cgarant          IN   NUMBER,
      psproces         IN   NUMBER,
      pnmovima         IN   NUMBER,
      picapital        IN   NUMBER,
      p_in_nsesion     IN   NUMBER,
      p_in_csubtabla   IN   sgt_subtabs_det.csubtabla%TYPE,
      p_in_cquery      IN   VARCHAR2,
      p_in_cval        IN   NUMBER,
      p_in_ccla1       IN   sgt_subtabs_det.ccla1%TYPE,
      p_in_ccla2       IN   sgt_subtabs_det.ccla2%TYPE DEFAULT NULL,
      p_in_ccla3       IN   sgt_subtabs_det.ccla3%TYPE DEFAULT NULL,
      p_in_ccla4       IN   sgt_subtabs_det.ccla4%TYPE DEFAULT NULL,
      p_in_ccla5       IN   sgt_subtabs_det.ccla5%TYPE DEFAULT NULL,
      p_in_ccla6       IN   sgt_subtabs_det.ccla6%TYPE DEFAULT NULL,
      p_in_ccla7       IN   sgt_subtabs_det.ccla7%TYPE DEFAULT NULL,
      p_in_ccla8       IN   sgt_subtabs_det.ccla8%TYPE DEFAULT NULL,
      p_in_ccla9       IN   sgt_subtabs_det.ccla9%TYPE DEFAULT NULL,
      p_in_ccla10      IN   sgt_subtabs_det.ccla10%TYPE DEFAULT NULL,
      p_in_v_fecha     IN   DATE DEFAULT NULL
   )
      RETURN NUMBER
   IS
      v_nnumide       NUMBER;
      v_cactivi       VARCHAR2 (50);
      vriesgos        t_iax_riesgos;
      aseg            t_iax_asegurados;
      mensajes        t_iax_mensajes;
      v_pspersonton   NUMBER;
      
      v_cpregun_2912  NUMBER:= 2912;                  -- IAXIS-4082 -- ECP -- 24/10/2019
      
   BEGIN
      vriesgos :=
         pac_iobj_prod.f_partpolriesgos
                                       (pac_iax_produccion.poliza.det_poliza,
                                        mensajes
                                       );

      IF vriesgos IS NOT NULL
      THEN
         IF vriesgos.COUNT > 0
         THEN
            FOR vrie IN vriesgos.FIRST .. vriesgos.LAST
            LOOP
               IF vriesgos.EXISTS (vrie)
               THEN
                  aseg :=
                     pac_iobj_prod.f_partriesasegurado (vriesgos (vrie),
                                                        mensajes
                                                       );

                  IF aseg IS NOT NULL
                  THEN
                     IF aseg.COUNT > 0
                     THEN
                        FOR vaseg IN aseg.FIRST .. aseg.LAST
                        LOOP
                           IF aseg.EXISTS (vaseg)
                           THEN
                              v_pspersonton := aseg (vaseg).spereal;
                           END IF;
                        END LOOP;
                     END IF;
                  END IF;
               END IF;
            END LOOP;
         END IF;
      END IF;
      --Ini IAXIS-4082 -- ECP -- 24/10/2019
      IF NVL
            (pac_mdpar_productos.f_get_parproducto
                                 ('CONV_CONTRATANTE',
                                  pac_iax_produccion.poliza.det_poliza.sproduc
                                 ),
             0
            ) = 0
      THEN
      SELECT DISTINCT (nnumide)
                 INTO v_nnumide
                 FROM per_personas
                WHERE sperson = v_pspersonton;
                else
                  
       IF pac_iax_produccion.poliza.det_poliza.preguntas IS NOT NULL
         THEN
            IF pac_iax_produccion.poliza.det_poliza.preguntas.COUNT > 0
            THEN
               FOR i IN
                  pac_iax_produccion.poliza.det_poliza.preguntas.FIRST .. pac_iax_produccion.poliza.det_poliza.preguntas.LAST
               LOOP
                
                  IF v_cpregun_2912 =
                        pac_iax_produccion.poliza.det_poliza.preguntas (i).cpregun
                  THEN
                     v_nnumide := pac_iax_produccion.poliza.det_poliza.preguntas (i).trespue;
                  END IF;
               
               END LOOP;
            END IF;
         END IF;     
         end if;        
         --Fin IAXIS-4082 -- ECP -- 24/10/2019       

      SELECT cactivi
        INTO v_cactivi
        FROM estseguros
       WHERE sseguro = psseguro;
p_tab_error(f_sysdate, f_user, 'tasa covenio', 2, SQLCODE, 'v_nnumide'||v_nnumide||'tasa-->'||pac_subtablas.f_vsubtabla (p_in_nsesion,
                                             p_in_csubtabla,
                                             p_in_cquery,
                                             p_in_cval,
                                             p_in_ccla1,
                                             NVL (v_cactivi, 1),
                                             v_nnumide,
                                             p_in_ccla4,
                                             p_in_ccla5,
                                             p_in_ccla6,
                                             p_in_ccla7,
                                             p_in_ccla8,
                                             p_in_ccla9,
                                             p_in_ccla10,
                                             p_in_v_fecha
                                            ));
      RETURN NVL (pac_subtablas.f_vsubtabla (p_in_nsesion,
                                             p_in_csubtabla,
                                             p_in_cquery,
                                             p_in_cval,
                                             p_in_ccla1,
                                             NVL (v_cactivi, 1),
                                             v_nnumide,
                                             p_in_ccla4,
                                             p_in_ccla5,
                                             p_in_ccla6,
                                             p_in_ccla7,
                                             p_in_ccla8,
                                             p_in_ccla9,
                                             p_in_ccla10,
                                             p_in_v_fecha
                                            ),
                  0
                 );
   END;

   --Función interna que nos devuelve el tomador de la póliza, o si el tomador es una UTE/consorcio nos devuelve el líder del mismo
   PROCEDURE p_tomador_o_lider (
      ptablas    IN       VARCHAR2,
      psseguro   IN       NUMBER,
      pctipper   OUT      NUMBER,
      psperson   OUT      NUMBER,
      pcpais     OUT      NUMBER
   )
   IS
      n_error       NUMBER;
      n_consorcio   NUMBER;
   BEGIN
      SELECT sperson
        INTO psperson
        FROM esttomadores
       WHERE sseguro = psseguro AND nordtom = 1;

      SELECT COUNT (*)
        INTO n_consorcio
        FROM estper_parpersonas
       WHERE cparam = 'PER_ASO_JURIDICA'
         AND nvalpar IN (1, 2)
         AND sperson = psperson
         AND ROWNUM = 1;

      IF n_consorcio > 0
      THEN
         --Seleccionamos la persona real que es la UTE/consorcio
         SELECT spereal
           INTO psperson
           FROM esttomadores t, estper_personas p
          WHERE t.sseguro = psseguro AND t.sperson = p.sperson AND nordtom = 1;

         --Cogemos al líder del consorcio para calcular
         BEGIN
            SELECT sperson
              INTO psperson
              FROM per_personas_rel
             WHERE ctipper_rel IN (0, 3) AND sperson = psperson
                   AND islider = 1;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               SELECT sperson
                 INTO psperson
                 FROM per_personas_rel p
                WHERE ctipper_rel IN (0, 3)
                  AND sperson = psperson
                  AND pparticipacion = (SELECT MAX (pparticipacion)
                                          FROM per_personas_rel pr
                                         WHERE pr.sperson = p.sperson);
         END;

         --Buscamos el país del líder y el tipo de persona
         SELECT p.ctipper, d.cpais
           INTO pctipper, pcpais
           FROM per_personas p, per_detper d
          WHERE p.sperson = psperson AND p.sperson = d.sperson AND ROWNUM = 1;
      ELSE
         --1 Natural, 2 Jurídica
         SELECT p.ctipper, spereal, cpais
           INTO pctipper, psperson, pcpais
           FROM esttomadores t, estper_personas p, estper_detper d
          WHERE p.sseguro = psseguro
            AND t.sperson = p.sperson
            AND p.sperson = d.sperson
            AND nordtom = 1;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_control_error ('LPP',
                          'pac_propio_albsgt_conf.p_tomador_o_lider',
                          SQLERRM
                         );
   END p_tomador_o_lider;

   FUNCTION f_anyo_vinc_cons_carg (
      ptablas     IN   VARCHAR2,
      psseguro    IN   NUMBER,
      pnriesgo    IN   NUMBER,
      pfefecto    IN   DATE,
      pnmovimi    IN   NUMBER,
      cgarant     IN   NUMBER,
      psproces    IN   NUMBER,
      pnmovima    IN   NUMBER,
      picapital   IN   NUMBER,
      ptipo       IN   NUMBER
   )
      RETURN NUMBER
   IS
      n_ctipper   NUMBER;
      n_anyo      NUMBER;
      n_sperson   NUMBER;
      n_cpais     NUMBER;
   BEGIN
      p_tomador_o_lider (ptablas, psseguro, n_ctipper, n_sperson, n_cpais);

      --Ini-Qtracker 0001813-VCG-22/01/2018- Se elimina la pregunta 6551
      /* IF ptipo = 1 AND n_ctipper = 1 THEN       --Año vinculación cliente

         BEGIN
           SELECT TO_CHAR(FCONSTI, 'YYYY')
             INTO n_anyo
             FROM FIN_GENERAL
            WHERE SPERSON = n_sperson
              AND FCONSTI IS NOT NULL;

            /*   SELECT NVL(MIN(TO_CHAR(FEMISIO, 'YYYY')), TO_CHAR(SYSDATE, 'YYYY'))
                 INTO n_anyo
                 FROM SEGUROS S, TOMADORES T
                WHERE T.SSEGURO = S.SSEGURO
                  AND T.SPERSON = n_sperson;*/
        /* EXCEPTION
           WHEN NO_DATA_FOUND THEN
              return TO_CHAR(SYSDATE, 'YYYY');
         END;

         RETURN n_anyo;*/
       --Se modifica la pregunta 6550 para que aplique igual para persona natural y juridica
      IF ptipo IN (1, 2) AND n_ctipper = 1
      THEN                                         --Año constitución empresa
         SELECT NVL (MIN (TO_CHAR (fconsti, 'YYYY')),
                     TO_CHAR (SYSDATE, 'YYYY')
                    )
           INTO n_anyo
           FROM fin_general
          WHERE sperson = n_sperson;

         RETURN n_anyo;
      --Fin-Qtracker 0001813-VCG-22/01/2018
      --Ini-Qtracker 0001834-VCG-05/02/2018
      ELSIF ptipo IN (1, 2) AND n_ctipper = 2
      THEN                                          --Año constitución empresa
         SELECT NVL (TO_CHAR (fnacimi, 'YYYY'), TO_CHAR (SYSDATE, 'YYYY'))
           INTO n_anyo
           FROM per_personas
          WHERE sperson = n_sperson;

         RETURN n_anyo;
      --Fin-Qtracker 0001834-VCG-05/02/2018
      ELSIF ptipo = 3
      THEN                                                --Año cargue negocio
         RETURN TO_CHAR (SYSDATE, 'YYYY');
      END IF;

      RETURN NULL;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END f_anyo_vinc_cons_carg;

   FUNCTION f_tipo_contragarantia (
      ptablas     IN   VARCHAR2,
      psseguro    IN   NUMBER,
      pnriesgo    IN   NUMBER,
      pfefecto    IN   DATE,
      pnmovimi    IN   NUMBER,
      cgarant     IN   NUMBER,
      psproces    IN   NUMBER,
      pnmovima    IN   NUMBER,
      picapital   IN   NUMBER,
      ptipo       IN   NUMBER
   )
      RETURN NUMBER
   IS
      n_sperson       NUMBER;
      n_exento        NUMBER;
      n_cumulo        NUMBER;
      n_contragaran   NUMBER := 100000000;
   BEGIN
      IF ptipo = 1
      THEN
         SELECT spereal
           INTO n_sperson
           FROM estper_personas
          WHERE sperson IN (SELECT t.sperson
                              FROM esttomadores t
                             WHERE t.sseguro = psseguro AND nordtom = 1);

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

         IF n_exento = 1
         THEN
            RETURN 2;
         ELSE
            IF n_cumulo < n_contragaran
            THEN
               RETURN 2;
            ELSE
               RETURN 3;
            END IF;
         END IF;
      ELSE
         SELECT spereal
           INTO n_sperson
           FROM estper_personas
          WHERE sperson IN (SELECT t.sperson
                              FROM esttomadores t
                             WHERE t.sseguro = psseguro AND nordtom = 1);

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

         --Validamos que el tomador esté exento de contragarantías o tenga un cúmulo inferior a 100.000.000 para escoger la opción EXCEPTUADO de la pregunta 2702 por defecto
         IF n_exento = 1
         THEN
            RETURN 110;
         ELSE
            IF n_cumulo < n_contragaran
            THEN
               RETURN 110;
            ELSE
               RETURN 100;
            END IF;
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 100;
   END f_tipo_contragarantia;

   FUNCTION f_calc_capfinan (
      ptablas     IN   VARCHAR2,
      psseguro    IN   NUMBER,
      pnriesgo    IN   NUMBER,
      pfefecto    IN   DATE,
      pnmovimi    IN   NUMBER,
      cgarant     IN   NUMBER,
      psproces    IN   NUMBER,
      pnmovima    IN   NUMBER,
      picapital   IN   NUMBER,
      ptipo       IN   NUMBER
   )
      RETURN NUMBER
   IS
      n_cupo           NUMBER;
      n_patrimonio     NUMBER;
      existe_infofin   NUMBER;
      n_cupo_patr      NUMBER;
      n_scoring        NUMBER;
      n_sfinanci       NUMBER;
      n_retorno        NUMBER;
      n_sperson        NUMBER;
      n_ctipper        NUMBER;
      n_cpais          NUMBER;
      n_icupog         NUMBER;
      n_factor         NUMBER;
      num_err          NUMBER;
      v_ncapfin        NUMBER;              --Qtracker 0001836-VCG-29/01/2018
      cpregun_6553     preguntas.cpregun%TYPE   := 6553;
      cpregun_6554     preguntas.cpregun%TYPE   := 6554;
      cpregun_6555     preguntas.cpregun%TYPE   := 6555;
      n_scoring_2      NUMBER;              --Qtracker 0001853-VCG-12/02/2018
      ppreguntas       t_iax_preguntas;
   BEGIN
      p_tomador_o_lider (ptablas, psseguro, n_ctipper, n_sperson, n_cpais);

      SELECT MAX (sfinanci)
        INTO n_sfinanci
        FROM fin_general
       WHERE sperson = n_sperson;

      --Si no tiene nada, devolvemos el maximo recargo posible
      IF n_sfinanci IS NULL AND ptipo = 4
      THEN
         IF n_ctipper = 1
         THEN
            RETURN 100;
         ELSE
            RETURN 100;
         END IF;
      ELSIF n_sfinanci IS NULL
      THEN
         RETURN NULL;
      END IF;

      IF n_ctipper = 1 AND ptipo = 3
      THEN                                      --SCORING para persona natural
         BEGIN
            SELECT NVL (nscore, 0)
              INTO n_scoring
              FROM fin_endeudamiento
             WHERE sfinanci = n_sfinanci;

            RETURN n_scoring;
         EXCEPTION
            WHEN OTHERS
            THEN
               RETURN 0;
         END;
      ELSIF n_ctipper = 1 AND ptipo = 1
      THEN
         --CUPO para persona natural(si tiene CUPO y SCORING, prima sobre el SCORING)
                --Ini-Qtracker 0001836-VCG-29/01/2018--Se modifica la consulta a la pregunta capacidad financiera
         BEGIN
            SELECT ncapfin
              INTO v_ncapfin
              FROM fin_indicadores a
             WHERE a.sfinanci = n_sfinanci
               AND a.nmovimi = (SELECT MAX (nmovimi)
                                  FROM fin_indicadores b
                                 WHERE a.sfinanci = b.sfinanci);
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               v_ncapfin := 0;
            WHEN OTHERS
            THEN
               v_ncapfin := 0;
         END;
      --Fin-Qtracker 0001836-VCG-29/01/2018--Se modifica la consulta a la pregunta capacidad financiera
      ELSIF n_ctipper = 1 AND ptipo = 2
      THEN
--PATRIMONIO para persona natural(si tiene CUPO y SCORING, prima sobre el SCORING)
         BEGIN
            /* SELECT ICUPOG
               INTO n_cupo
               FROM FIN_ENDEUDAMIENTO
              WHERE SFINANCI = n_sfinanci
                AND ICUPOG IS NOT NULL;*/
            SELECT NVL (NVL (nvalpar, tvalpar), 0)
              INTO n_patrimonio
              FROM fin_parametros a
             WHERE a.sfinanci = n_sfinanci
               AND a.nmovimi = (SELECT MAX (nmovimi)
                                  FROM fin_indicadores b
                                 WHERE a.sfinanci = b.sfinanci)
               AND a.cparam = 'PATRI_ANO_ACTUAL';

            RETURN n_patrimonio;
         EXCEPTION
            WHEN OTHERS
            THEN
               RETURN NULL;
         END;
      ELSIF n_ctipper = 2 AND ptipo = 1 AND NVL (n_cpais, 1) <> 170
      THEN                                    --CUPO para empresas extranjeras
           --Para empresas extranjeras, la capacidad financiera será la máxima
         --Ini-Qtracker 0001836-VCG-29/01/2018--Se modifica la consulta a la pregunta capacidad financiera
         SELECT ncapfin
           INTO v_ncapfin
           FROM fin_indicadores a
          WHERE a.sfinanci = n_sfinanci
            AND a.nmovimi = (SELECT MAX (nmovimi)
                               FROM fin_indicadores b
                              WHERE a.sfinanci = b.sfinanci);

         RETURN NVL (v_ncapfin, -1);
      ELSIF n_ctipper = 2 AND ptipo = 1 AND n_cpais = 170
      THEN                                     --CUPO para empresas nacionales
         BEGIN
            SELECT ncapfin
              INTO v_ncapfin
              FROM fin_indicadores a
             WHERE a.sfinanci = n_sfinanci
               AND a.nmovimi = (SELECT MAX (nmovimi)
                                  FROM fin_indicadores b
                                 WHERE a.sfinanci = b.sfinanci);
         --Ini-1888-VCG-16/02/2018
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               v_ncapfin := 0;
            WHEN OTHERS
            THEN
               v_ncapfin := 0;
         END;

         --Fin-1888-VCG-16/02/2018
         RETURN v_ncapfin;
      --Fin-Qtracker 0001836-VCG-29/01/2018--Se modifica la consulta a la pregunta capacidad financiera
      ELSIF n_ctipper = 2 AND ptipo = 2 AND NVL (n_cpais, 1) <> 170
      THEN                              --PATRIMONIO para empresas extranjeras
         --Para empresas extranjeras, la capacidad financiera será la máxima
         RETURN 1;
      ELSIF n_ctipper = 2 AND ptipo = 2 AND n_cpais = 170
      THEN                               --PATRIMONIO para empresas nacionales
         BEGIN
            SELECT NVL (NVL (nvalpar, tvalpar), 0)
              INTO n_retorno
              FROM fin_parametros a
             WHERE a.sfinanci = n_sfinanci
               AND a.nmovimi = (SELECT MAX (nmovimi)
                                  FROM fin_indicadores b
                                 WHERE a.sfinanci = b.sfinanci)
               AND a.cparam = 'PATRI_ANO_ACTUAL';
         EXCEPTION
            WHEN OTHERS
            THEN
               n_retorno := 1;
         END;

         RETURN n_retorno;
-- Ini IAXIS-3628. ECP -- 31/05/2019
      ELSIF ptipo IN (1)
      THEN                                              --CAPACIDAD FINANCIERA
         --Buscamos el tipo de contragarantía
         --num_err:=pac_preguntas.f_get_pregunseg(psseguro, 1, 6553, 'EST',n_cupo);
         --num_err:=pac_preguntas.f_get_pregunseg(psseguro, 1, 6554, 'EST',n_patrimonio);
         --num_err:=pac_preguntas.f_get_pregunseg(psseguro, 1, 6555, 'EST',n_scoring);
         IF     pac_iax_produccion.poliza.det_poliza.riesgos IS NOT NULL
            AND pac_iax_produccion.poliza.det_poliza.riesgos.COUNT > 0
         THEN
            FOR vrisc IN
               pac_iax_produccion.poliza.det_poliza.riesgos.FIRST .. pac_iax_produccion.poliza.det_poliza.riesgos.LAST
            LOOP
               ppreguntas := t_iax_preguntas ();

               IF     pac_iax_produccion.poliza.det_poliza.riesgos (vrisc).preguntas IS NOT NULL
                  AND pac_iax_produccion.poliza.det_poliza.riesgos (vrisc).preguntas.COUNT >
                                                                             0
               THEN
                  FOR vpregun IN
                     pac_iax_produccion.poliza.det_poliza.riesgos (vrisc).preguntas.FIRST .. pac_iax_produccion.poliza.det_poliza.riesgos
                                                                                               (vrisc
                                                                                               ).preguntas.LAST
                  LOOP
                     IF cpregun_6553 =
                           pac_iax_produccion.poliza.det_poliza.riesgos
                                                                       (vrisc).preguntas
                                                                     (vpregun).cpregun
                     THEN
                        n_cupo :=
                           NVL
                              (pac_iax_produccion.poliza.det_poliza.riesgos
                                                                        (vrisc).preguntas
                                                                      (vpregun).crespue,
                               0
                              );
                     END IF;

                     --Ini-Qtracker 0001836-VCG-29/01/2018--Se elimina la pregunta 6554-Patrimonio
                     /* IF cpregun_6554 = pac_iax_produccion.poliza.det_poliza.riesgos(vrisc).preguntas(vpregun).cpregun
                     THEN
                        n_patrimonio := NVL(pac_iax_produccion.poliza.det_poliza.riesgos(vrisc).preguntas(vpregun).crespue,0);
                     END IF;*/
                     --Fin-Qtracker 0001836-VCG-29/01/2018--Se elimina la pregunta 6554-Patrimonio
                     IF cpregun_6555 =
                           pac_iax_produccion.poliza.det_poliza.riesgos (vrisc).preguntas
                                                                      (vpregun).cpregun
                     THEN
                        n_scoring :=
                           NVL
                              (pac_iax_produccion.poliza.det_poliza.riesgos
                                                                        (vrisc).preguntas
                                                                      (vpregun).crespue,
                               0
                              );
                     END IF;
                  END LOOP;
               END IF;
            END LOOP;
         END IF;

         --Ini-Qtracker 0001836-VCG-29/01/2018--Se modifica la consulta de la Tasa por Cupo/Patrimonio
         IF (n_cupo <> 0)
         THEN
            n_cupo_patr := n_cupo;
            --Fin-Qtracker 0001836-VCG-29/01/2018--Se modifica la consulta de la Tasa por Cupo/Patrimonio
            n_factor :=
               pac_subtablas.f_vsubtabla
                  (p_in_nsesion        => -1,
                   p_in_csubtabla      => 8000005,
                   p_in_cquery         => 314,
                   p_in_cval           => 1,
                   p_in_ccla1          => pac_iax_produccion.poliza.det_poliza.sproduc,
                   p_in_ccla2          => n_cupo_patr,
                   p_in_ccla3          => n_cupo_patr
                  );
            RETURN n_factor;
         ELSIF (n_scoring <> 0)
         THEN                                       --Qt0001853-VCG-12/02/2018
            n_factor :=
               pac_subtablas.f_vsubtabla
                  (p_in_nsesion        => -1,
                   p_in_csubtabla      => 8000006,
                   p_in_cquery         => 325,
                   p_in_cval           => 1,
                   p_in_ccla1          => pac_iax_produccion.poliza.det_poliza.sproduc,
                   p_in_ccla2          => n_scoring,
                   p_in_ccla3          => n_scoring
                  );
            RETURN n_factor;
         ELSE
            IF n_ctipper = 1
            THEN
               RETURN 150;
            ELSE
               RETURN 110;
            END IF;
         END IF;
      ELSIF ptipo IN (4)
      THEN                                              --CAPACIDAD FINANCIERA
         RETURN 100;
      END IF;
   -- Fin IAXIS-3628. ECP -- 31/05/2019
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 99;
   END f_calc_capfinan;

   FUNCTION f_es_consorcio (
      ptablas     IN   VARCHAR2,
      psseguro    IN   NUMBER,
      pnriesgo    IN   NUMBER,
      pfefecto    IN   DATE,
      pnmovimi    IN   NUMBER,
      cgarant     IN   NUMBER,
      psproces    IN   NUMBER,
      pnmovima    IN   NUMBER,
      picapital   IN   NUMBER
   )
      RETURN NUMBER
   IS
      n_sperson     NUMBER;
      n_consorcio   NUMBER;
   BEGIN
      SELECT sperson
        INTO n_sperson
        FROM esttomadores
       WHERE sseguro = psseguro AND nordtom = 1;

      SELECT 1
        INTO n_consorcio
        FROM estper_parpersonas
       WHERE cparam = 'PER_ASO_JURIDICA'
         AND nvalpar IN (1, 2)
         AND sperson = n_sperson
         AND ROWNUM = 1;

      RETURN 1;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN 0;
      WHEN OTHERS
      THEN
         RETURN 0;
   END f_es_consorcio;

   FUNCTION f_suma_preguntas_trdm (
      ptablas     IN   VARCHAR2,
      psseguro    IN   NUMBER,
      pnriesgo    IN   NUMBER,
      pfefecto    IN   DATE,
      pnmovimi    IN   NUMBER,
      pcgarant    IN   NUMBER,
      psproces    IN   NUMBER,
      pnmovima    IN   NUMBER,
      picapital   IN   NUMBER,
      pcpregun    IN   NUMBER
   )
      RETURN NUMBER
   IS
      v_crespue   NUMBER;
      n_respue    NUMBER := 0;
      n_total     NUMBER := 0;
      num_err     NUMBER;
   BEGIN
      IF pcpregun = 6595
      THEN
         num_err :=
            pac_preguntas.f_get_pregunseg (psseguro,
                                           pnriesgo,
                                           6593,
                                           NVL (ptablas, 'SEG'),
                                           n_respue
                                          );
         n_total := n_total + n_respue;
         num_err :=
            pac_preguntas.f_get_pregunseg (psseguro,
                                           pnriesgo,
                                           6594,
                                           NVL (ptablas, 'SEG'),
                                           n_respue
                                          );
         n_total := n_total + n_respue;
      ELSIF pcpregun = 6605
      THEN
         num_err :=
            pac_preguntas.f_get_pregunseg (psseguro,
                                           pnriesgo,
                                           6596,
                                           NVL (ptablas, 'SEG'),
                                           n_respue
                                          );
         n_total := n_total + n_respue;
         num_err :=
            pac_preguntas.f_get_pregunseg (psseguro,
                                           pnriesgo,
                                           6597,
                                           NVL (ptablas, 'SEG'),
                                           n_respue
                                          );
         n_total := n_total + n_respue;
         num_err :=
            pac_preguntas.f_get_pregunseg (psseguro,
                                           pnriesgo,
                                           6598,
                                           NVL (ptablas, 'SEG'),
                                           n_respue
                                          );
         n_total := n_total + n_respue;
         num_err :=
            pac_preguntas.f_get_pregunseg (psseguro,
                                           pnriesgo,
                                           6599,
                                           NVL (ptablas, 'SEG'),
                                           n_respue
                                          );
         n_total := n_total + n_respue;
         num_err :=
            pac_preguntas.f_get_pregunseg (psseguro,
                                           pnriesgo,
                                           6600,
                                           NVL (ptablas, 'SEG'),
                                           n_respue
                                          );
         n_total := n_total + n_respue;
         num_err :=
            pac_preguntas.f_get_pregunseg (psseguro,
                                           pnriesgo,
                                           6601,
                                           NVL (ptablas, 'SEG'),
                                           n_respue
                                          );
         n_total := n_total + n_respue;
         num_err :=
            pac_preguntas.f_get_pregunseg (psseguro,
                                           pnriesgo,
                                           6602,
                                           NVL (ptablas, 'SEG'),
                                           n_respue
                                          );
         n_total := n_total + n_respue;
         num_err :=
            pac_preguntas.f_get_pregunseg (psseguro,
                                           pnriesgo,
                                           6603,
                                           NVL (ptablas, 'SEG'),
                                           n_respue
                                          );
         n_total := n_total + n_respue;
         num_err :=
            pac_preguntas.f_get_pregunseg (psseguro,
                                           pnriesgo,
                                           6604,
                                           NVL (ptablas, 'SEG'),
                                           n_respue
                                          );
         n_total := n_total + n_respue;
      ELSIF pcpregun = 6608
      THEN
         num_err :=
            pac_preguntas.f_get_pregunseg (psseguro,
                                           pnriesgo,
                                           6606,
                                           NVL (ptablas, 'SEG'),
                                           n_respue
                                          );
         n_total := n_total + n_respue;
         num_err :=
            pac_preguntas.f_get_pregunseg (psseguro,
                                           pnriesgo,
                                           6607,
                                           NVL (ptablas, 'SEG'),
                                           n_respue
                                          );
         n_total := n_total + n_respue;
      END IF;

      RETURN n_total;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN 0;
      WHEN OTHERS
      THEN
         RETURN 0;
   END f_suma_preguntas_trdm;

   FUNCTION f_calc_val_ind_trdm (
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
      v_crespue   NUMBER;
      n_respue    NUMBER := 0;
      n_total     NUMBER := 0;
      n_capital   NUMBER := 0;
      n_tasa      NUMBER := 0;
      num_err     NUMBER;
   BEGIN
      num_err :=
         pac_preguntas.f_get_pregunseg (psseguro,
                                        pnriesgo,
                                        6595,
                                        NVL (ptablas, 'SEG'),
                                        n_respue
                                       );
      n_capital := n_capital + n_respue;
      num_err :=
         pac_preguntas.f_get_pregunseg (psseguro,
                                        pnriesgo,
                                        6605,
                                        NVL (ptablas, 'SEG'),
                                        n_respue
                                       );
      n_capital := n_capital + n_respue;
      num_err :=
         pac_preguntas.f_get_pregunseg (psseguro,
                                        pnriesgo,
                                        6608,
                                        NVL (ptablas, 'SEG'),
                                        n_respue
                                       );
      n_capital := n_capital + n_respue;
      num_err :=
         pac_preguntas.f_get_pregunseg (psseguro,
                                        pnriesgo,
                                        6618,
                                        NVL (ptablas, 'SEG'),
                                        n_tasa
                                       );
      n_total := n_capital * n_tasa / 100;
      RETURN n_total;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN 0;
      WHEN OTHERS
      THEN
         RETURN 0;
   END f_calc_val_ind_trdm;

   FUNCTION f_tasa_rc (
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
      n_respue   NUMBER;
      num_err    NUMBER;
      n_return   NUMBER := 0;
   BEGIN
      num_err :=
         pac_preguntas.f_get_pregunseg (psseguro,
                                        pnriesgo,
                                        2876,
                                        NVL (ptablas, 'SEG'),
                                        n_respue
                                       );

      IF n_respue = 6
      THEN
         n_return := 0.10;
      ELSIF n_respue IN (7, 8, 9, 10)
      THEN
         n_return := 1.20;
      ELSIF n_respue = 11
      THEN
         n_return := 0.60;
      ELSIF n_respue = 12
      THEN
         n_return := 0.10;
      ELSIF n_respue = 13
      THEN
         n_return := 1.20;
      ELSIF n_respue = 14
      THEN
         n_return := 0.10;
      ELSIF n_respue = 15
      THEN
         n_return := 0.10;
      END IF;

      RETURN n_return;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN 0;
      WHEN OTHERS
      THEN
         RETURN 0;
   END f_tasa_rc;

   -- IAXIS-4082 -- ECP -- 05/08/2019
   FUNCTION f_recupera_comision (
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
      num_err     NUMBER;
      v_pcomisi   NUMBER;
      v_tasa      NUMBER;
      v_tasa_d    NUMBER;
      v_sproduc   NUMBER;
      v_cagente   NUMBER;
      v_trespue   pregunpolseg.trespue%TYPE;
      v_crespue   pregunpolseg.crespue%TYPE;
      v_cactivi   NUMBER;
   BEGIN
      IF ptablas = 'EST'
      THEN
         BEGIN
            SELECT sproduc, cagente, cactivi
              INTO v_sproduc, v_cagente, v_cactivi
              FROM estseguros
             WHERE sseguro = psseguro;
         END;

         BEGIN
            SELECT trespue
              INTO v_trespue
              FROM estpregunpolseg
             WHERE sseguro = psseguro AND cpregun = 2912
                   AND nmovimi = pnmovimi;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               v_trespue := '0';
         END;

                --Ini IAXIS-6224 -- ECP --26/02/2020
         BEGIN
            SELECT NVL (pcomisi, 0)
              INTO v_pcomisi
              FROM estcomisionsegu
             WHERE sseguro = psseguro
              AND nmovimi = pnmovimi;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               BEGIN
                  SELECT   CASE a.ctipage
                              WHEN 2
                                 THEN 30
                              ELSE MIN (pcomisi)
                           END
                      INTO v_pcomisi
                      FROM comisionprod c, agentes a
                     WHERE c.ccomisi = a.ccomisi
                       AND a.cagente = v_cagente
                       AND c.sproduc = v_sproduc
                       AND c.finivig =
                              (SELECT MAX (finivig)
                                 FROM comisionvig v
                                WHERE v.ccomisi = a.ccomisi
                                  AND v.finivig <= f_sysdate)
                  GROUP BY a.ctipage;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     v_pcomisi := 0;
               END;
         END;
      ELSE
         BEGIN
            SELECT sproduc, cagente, cactivi
              INTO v_sproduc, v_cagente, v_cactivi
              FROM seguros
             WHERE sseguro = psseguro;
         END;

         BEGIN
            SELECT trespue
              INTO v_trespue
              FROM pregunpolseg
             WHERE sseguro = psseguro AND cpregun = 2912
                   AND nmovimi = pnmovimi;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               v_trespue := '0';
         END;

         BEGIN
            SELECT NVL (pcomisi, 0)
              INTO v_pcomisi
              FROM comisionsegu
             WHERE sseguro = psseguro
               AND nmovimi = pnmovimi;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               BEGIN
                  SELECT MIN (NVL (pcomisi, 0))
                    INTO v_pcomisi
                    FROM comisionprod c, agentes a
                   WHERE c.ccomisi = a.ccomisi
                     AND a.cagente = v_cagente
                     AND c.sproduc = v_sproduc
                     AND c.finivig =
                            (SELECT MAX (finivig)
                               FROM comisionvig v
                              WHERE v.ccomisi = a.ccomisi
                                AND v.finivig <= f_sysdate);
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     v_pcomisi := 0;
               END;
         END;
      END IF;
--Fin IAXIS-6224 -- ECP --26/02/2020
      IF v_cactivi = 1 and v_trespue <> '0'
      THEN
       
                    
         BEGIN
            SELECT MIN (NVL (pcomisi, 0))
              INTO v_pcomisi
              FROM convcomesptom a, convcomespage b, convcomisesp c
             WHERE a.sperson = (SELECT b.sperson
                                  FROM per_personas b
                                 WHERE b.nnumide = v_trespue)
               AND a.idconvcomesp = c.idconvcomesp
               AND a.idconvcomesp = b.idconvcomesp
               AND b.cagente = v_cagente
                and cmodcom = 1;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               BEGIN
                  SELECT NVL (pcomisi, 0)
                    INTO v_pcomisi
                    FROM estcomisionsegu
                   WHERE sseguro = psseguro;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     BEGIN
                        SELECT   CASE a.ctipage
                                    WHEN 2
                                       THEN 30
                                    ELSE MIN (pcomisi)
                                 END
                            INTO v_pcomisi
                            FROM comisionprod c, agentes a
                           WHERE c.ccomisi = a.ccomisi
                             AND a.cagente = v_cagente
                             AND c.sproduc = v_sproduc
                             AND c.finivig =
                                    (SELECT MAX (finivig)
                                       FROM comisionvig v
                                      WHERE v.ccomisi = a.ccomisi
                                        AND v.finivig <= f_sysdate)
                        GROUP BY a.ctipage;
                     EXCEPTION
                        WHEN NO_DATA_FOUND
                        THEN
                           v_pcomisi := 0;
                     END;
               END;
         END;
        
        
                     
      END IF;
 
      RETURN (v_pcomisi);
   END f_recupera_comision;

   FUNCTION f_tasa_convenio_rc (
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
      num_err     NUMBER;
      v_tasa      NUMBER;
      v_tasa_d    NUMBER;
      v_sproduc   NUMBER;
      v_cagente   NUMBER;
      v_trespue   pregunpolseg.trespue%TYPE;
      v_crespue   pregunpolseg.crespue%TYPE;
      v_cactivi   NUMBER;
   BEGIN
     
      IF ptablas = 'EST'
      THEN
         SELECT sproduc, cagente, cactivi
           INTO v_sproduc, v_cagente, v_cactivi
           FROM estseguros
          WHERE sseguro = psseguro;

         BEGIN
            SELECT trespue
              INTO v_trespue
              FROM estpregunpolseg
             WHERE sseguro = psseguro AND cpregun = 2912
                   AND nmovimi = pnmovimi;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               v_trespue := '0';
         END;
      ELSE
         SELECT sproduc, cagente, cactivi
           INTO v_sproduc, v_cagente, v_cactivi
           FROM seguros
          WHERE sseguro = psseguro;

         BEGIN
            SELECT trespue
              INTO v_trespue
              FROM pregunpolseg
             WHERE sseguro = psseguro AND cpregun = 2912
                   AND nmovimi = pnmovimi;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               v_trespue := '0';
         END;
      END IF;

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
            AND ccla4 = pcgarant;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            BEGIN
               SELECT crespue
                 INTO v_tasa
                 FROM estpregungaranseg
                WHERE sseguro = psseguro
                  AND nriesgo = pnriesgo
                  AND cgarant = cgarant
                  and nmovimi = pnmovimi
                  AND cpregun = 8001;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  v_tasa := 0;
            END;
      END;
      v_tasa := v_tasa/100;
     
      RETURN v_tasa;
   END f_tasa_convenio_rc;
-- IAXIS-4082 -- ECP -- 05/08/2019
--IAXIS-4785 -- ECP -- 16/08/2019
 
FUNCTION f_recargo_com (
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
   v_recargo   NUMBER;
   v_cpregun   NUMBER;
BEGIN
   IF pnmovimi > 1
   THEN
      update estpregungaranseg
      set crespue = 0
      where sseguro = psseguro
      and nriesgo = pnriesgo
      and cgarant = pcgarant
      and nmovimi = pnmovimi
      and cpregun = 6623;
      
      v_recargo := 0;
     
   END IF;

   RETURN v_recargo;
END f_recargo_com;
   --IAXIS-4785 -- ECP -- 16/08/2019
END pac_propio_albsgt_conf;
/
