--------------------------------------------------------
--  DDL for Package Body PK_CAL_SINI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PK_CAL_SINI" IS
/****************************************************************************
   NOMBRE:       PAC_SIN
   PROPÓSITO:  Funciones para el cálculo de los siniestros

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ----------------------------------
   1.0        ???         ???               1. Creación del package.
   2.0        19/03/2009  JRB               2. Se añaden las fechas para identificar los pagos
   3.0        13/05/2009  JRB               3. Se modifica el estado de la transferencia para productos de baja
   4.0        04/11/2009  RSC               4. Bug 11771: CRE - Ajustes en simulación y contratación PPJ Dinámico/Pla Estudiant
   5.0        16/11/2009  RSC               5. Bug 11993: CRE - Ajustes PPJ Dinámico/Pla Estudiant
   6.0        22/02/2010  RSC               6. 0013296: CEM - Revisión módulo de rescates
   7.0        27/04/2010  DRA               7. 0014172: CEM800 - SUPLEMENTS: Error en el suplement de preguntes de pòlissa de la pòlissa 60115905.
   8.0        12/07/2010  JRH               8. 0015298: CEM210 - RESCATS: Simulació pagaments rendes per productes 2 CABEZAS
****************************************************************************/

   -- ****************************************************************
--  Carga preguntas
--   CPM 10/11/2004
--    Función que carga las preguntas para poder ejecutar la
--   formula indicada
-- ****************************************************************
   PROCEDURE carga_preguntas(
      psseguro IN NUMBER,
      pfecha IN DATE,
      pcgarant IN NUMBER,
      psesion IN NUMBER,
      pnriesgo IN NUMBER DEFAULT 1) IS
--------------------------------------------------------------------------
-- CRE_145 - 23/07/2008 - Añade las preguntas por póliza
-- PREGUNPOLSEG
-- ESTPREGUNPOLSEG
-- SOLPREGUNPOLSEG --> Esta tabla no existe y no la vamos a usar
--------------------------------------------------------------------------
      CURSOR c_preg_pol IS
         SELECT *
           FROM pregunpolseg
          WHERE sseguro = psseguro
            AND nmovimi = (SELECT MAX(nmovimi)
                             FROM pregunpolseg   -- BUG14172:DRA:27/04/2010
                            WHERE sseguro = psseguro
                              AND nmovimi <= (SELECT MAX(nmovimi)
                                                FROM movseguro
                                               WHERE sseguro = psseguro
                                                 AND fefecto <= pfecha));

      CURSOR c_preg_risc IS
         SELECT *
           FROM pregunseg
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND nmovimi = (SELECT MAX(nmovimi)
                             FROM pregunseg
                            WHERE sseguro = psseguro
                              AND nriesgo = pnriesgo
                              AND nmovimi <= (SELECT MAX(nmovimi)
                                                FROM movseguro
                                               WHERE sseguro = psseguro
                                                 AND fefecto <= pfecha));

      CURSOR c_preg_gar IS
         SELECT *
           FROM pregungaranseg
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND cgarant = pcgarant
            AND nmovimi = (SELECT MAX(nmovimi)
                             FROM pregungaranseg
                            WHERE sseguro = psseguro
                              AND nriesgo = pnriesgo
                              AND nmovimi <= (SELECT MAX(nmovimi)
                                                FROM movseguro
                                               WHERE sseguro = psseguro
                                                 AND fefecto <= pfecha));

      e              NUMBER;
   BEGIN
      -- INSERTAMOS LAS PREGUNTAS
      FOR preg_pol IN c_preg_pol LOOP
         e := graba_param(psesion, 'RESP' || preg_pol.cpregun, preg_pol.crespue);
      END LOOP;

      FOR preg_risc IN c_preg_risc LOOP
         e := graba_param(psesion, 'RESP' || preg_risc.cpregun, preg_risc.crespue);
      END LOOP;

      FOR preg_gar IN c_preg_gar LOOP
         e := graba_param(psesion, 'RESP' || preg_gar.cpregun, preg_gar.crespue);
      END LOOP;
   END carga_preguntas;

-- ****************************************************************
-- Valoración
-- ****************************************************************
-- Bug 8744 - 03/03/2009 - JRB - Se añaden los parámetros pfperini y pfperfin
   FUNCTION valo_pagos_sini(
      pfsinies IN DATE,   -- Fecha del siniestro
      psseguro IN NUMBER,   -- clave del seguro
      pnsinies IN NUMBER,   -- Nro de siniestro
      psproduc IN NUMBER,   -- Clave del Producto
      pcactivi IN NUMBER DEFAULT 0,   -- Actividad
      pcgarant IN NUMBER,   -- Garantía
      pccausin IN NUMBER,   -- Causa del Siniestro
      pcmotsin IN NUMBER,   -- Subcausa
      pfnotifi IN DATE,   -- Fecha de Notificacion
      pivalora OUT NUMBER,   -- Valoracion
      pipenali OUT NUMBER,   -- Penalizacion
      picapris OUT NUMBER,   -- Capital de riesgo
      pnriesgo IN NUMBER DEFAULT NULL,
      pfecval IN DATE DEFAULT f_sysdate,   --Data per calcul de la valoracio
      p_fperini IN DATE DEFAULT NULL,
      p_fperfin IN DATE DEFAULT NULL)
      RETURN NUMBER IS
      val            NUMBER;   -- Valor que retorna la formula
      xxformula      VARCHAR2(2000);   -- contiene la Formula a calcular
      xxsesion       NUMBER;   -- Nro de sesion que ejecuta la formula
      xfsinies       NUMBER;   -- Fecha valor del siniestro
      xfecefe        NUMBER;   -- Fecha Alta
      xfecval        NUMBER;   --Fecha de efecto de valoracion
      xfnotifi       NUMBER;   -- Fecha Notificacion
      e              NUMBER;   -- Error Retorno funciones
      xivalsin       NUMBER;
      xipenali       NUMBER;
      xicapris       NUMBER;
      xnriesgo       NUMBER;
      xs             VARCHAR2(2000);
      retorno        NUMBER;
      v_cursor       INTEGER;
      v_filas        NUMBER;
      xxfperini      NUMBER(8);
      xxfperfin      NUMBER(8);

      CURSOR cur_campo IS
         SELECT   DECODE(ccampo, 'ICAPRIS', 1, 'IVALSIN', 2, 'IPENALI', 3) orden, ccampo,
                  clave, cdestin
             FROM sinigaranformula
            WHERE sprcamosin IN(SELECT sprcamosin
                                  FROM prodcaumotsin
                                 WHERE sproduc = psproduc
                                   AND cgarant = pcgarant
                                   AND cactivi = pcactivi
                                   AND ccausin = pccausin
                                   AND cmotsin = pcmotsin)
              AND cdestin = 0
              AND ccampo IN('ICAPRIS', 'IVALSIN', 'IPENALI')
         ORDER BY 1;

--
      CURSOR cur_termino(wclave NUMBER) IS
         SELECT   parametro
             FROM sgt_trans_formula
            WHERE clave = wclave
         ORDER BY 1;

      vsproduc       NUMBER;
   BEGIN
      SELECT sproduc
        INTO vsproduc
        FROM seguros
       WHERE sseguro = psseguro;

      xfsinies := TO_NUMBER(TO_CHAR(pfsinies, 'yyyymmdd'));
      xfnotifi := TO_NUMBER(TO_CHAR(pfnotifi, 'yyyymmdd'));
      xxfperini := TO_NUMBER(TO_CHAR(p_fperini, 'yyyymmdd'));
      xxfperfin := TO_NUMBER(TO_CHAR(p_fperfin, 'yyyymmdd'));

      IF NVL(f_parproductos_v(vsproduc, 'ES_PRODUCTO_RENTAS'), 0) = 1 THEN
         /*
             -- RSC 21/10/2008 Lo hacemos asi para minimizar impacto
                 (en Ahorro esto funciona por tanto este cambio solo lo quiero para
                  rentas).

               Para RVI y RO FFECEFE debe ser la fecha de revisión anterior y si
               no ha renovado pues la de efecto de la póliza. Para el resto no
               afecta.
         */
         SELECT TO_NUMBER(TO_CHAR(NVL(sa.frevant, s.fefecto), 'YYYYMMDD'))
           INTO xfecefe
           FROM seguros_aho sa, seguros s
          WHERE sa.sseguro = s.sseguro
            AND s.sseguro = psseguro;
      ELSE
         xfecefe := TO_NUMBER(TO_CHAR(f_sysdate, 'YYYYMMDD'));
      END IF;

      xfecval := TO_NUMBER(TO_CHAR(pfecval, 'YYYYMMDD'));

      SELECT sgt_sesiones.NEXTVAL
        INTO xxsesion
        FROM DUAL;

      IF xxsesion IS NULL THEN
         ROLLBACK;
         RETURN 108418;
      END IF;

      IF pnriesgo IS NULL THEN
         BEGIN
            SELECT nriesgo
              INTO xnriesgo
              FROM siniestros
             WHERE nsinies = pnsinies;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 104755;   -- calve no esncontrada en siniestros
         END;
      ELSE
         xnriesgo := pnriesgo;
      END IF;

--
--dbms_output.put_line('XXSESION:'||XXSESION);
--
      e := graba_param(xxsesion, 'ORIGEN', 2);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := graba_param(xxsesion, 'SESION', xxsesion);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

-- Insertamos los parametros genericos para el calculo de un seguro.
      e := graba_param(xxsesion, 'FECEFE', xfecefe);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := graba_param(xxsesion, 'FNOTIFI', xfnotifi);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := graba_param(xxsesion, 'FSINIES', xfsinies);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := graba_param(xxsesion, 'SSEGURO', psseguro);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := graba_param(xxsesion, 'NSINIES', pnsinies);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := graba_param(xxsesion, 'SPRODUC', psproduc);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := graba_param(xxsesion, 'CACTIVI', pcactivi);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := graba_param(xxsesion, 'CGARANT', pcgarant);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := graba_param(xxsesion, 'CCAUSIN', pccausin);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := graba_param(xxsesion, 'CMOTSIN', pcmotsin);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := graba_param(xxsesion, 'NRIESGO', xnriesgo);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := graba_param(xxsesion, 'FVALORA', xfecval);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := graba_param(xxsesion, 'FPERINI', xxfperini);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := graba_param(xxsesion, 'FPERFIN', xxfperfin);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

--
      FOR reg IN cur_campo LOOP
         --dbms_output.put_line('Dentro del form'||reg.clave||' CCAMPO:'||REG.CCAMPO);
         BEGIN
            SELECT formula
              INTO xxformula
              FROM sgt_formulas
             WHERE clave = reg.clave;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN 108423;
            WHEN OTHERS THEN
               RETURN 108423;
         END;

         -- Cargo parametros predefinidos
         -- RSC 09/06/2008 Tarea 5507 Utilización de bind variables
         FOR term IN cur_termino(reg.clave) LOOP
            BEGIN
               IF (term.parametro <> 'IVALSIN'
                   AND term.parametro <> 'ICAPRIS') THEN   --Se esta calculando en este momento
                  BEGIN
                     SELECT 'BEGIN SELECT ' || tcampo || ' INTO :RETORNO  FROM ' || ttable
                            || ' WHERE ' || twhere || ' ; END;'
                       INTO xs
                       FROM sgt_carga_arg_prede
                      WHERE termino = term.parametro
                        AND ttable IS NOT NULL
                        AND cllamada = 'PK_CALC_SINI';
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN   --JRH 101/2008 Lo ponemos como en la simulación
                        SELECT 'BEGIN SELECT ' || tcampo || ' INTO :RETORNO  FROM ' || ttable
                               || ' WHERE ' || twhere || ' ; END;'
                          INTO xs
                          FROM sgt_carga_arg_prede
                         WHERE termino = term.parametro
                           AND ttable IS NOT NULL
                           AND cllamada = 'GENERICO';
                  END;

                  -- RSC 07/07/2008 Mejora propuesta por Sa Nostra (Patch SNVA_249b) Bind Variables
                  IF DBMS_SQL.is_open(v_cursor) THEN
                     DBMS_SQL.close_cursor(v_cursor);
                  END IF;

                  v_cursor := DBMS_SQL.open_cursor;
                  DBMS_SQL.parse(v_cursor, xs, DBMS_SQL.native);
                  DBMS_SQL.bind_variable(v_cursor, ':RETORNO', retorno);

                  IF INSTR(xs, ':FECEFE') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':FECEFE', xfecefe);
                  END IF;

                  IF INSTR(xs, ':NSINIES') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':NSINIES', pnsinies);
                  END IF;

                  IF INSTR(xs, ':FSINIES') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':FSINIES', xfsinies);
                  END IF;

                  IF INSTR(xs, ':FNOTIFI') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':FNOTIFI', xfnotifi);
                  END IF;

                  IF INSTR(xs, ':SSEGURO') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':SSEGURO', psseguro);
                  END IF;

                  IF INSTR(xs, ':SPRODUC') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':SPRODUC', psproduc);
                  END IF;

                  IF INSTR(xs, ':CACTIVI') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':CACTIVI', pcactivi);
                  END IF;

                  IF INSTR(xs, ':CGARANT') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':CGARANT', pcgarant);
                  END IF;

                  IF INSTR(xs, ':NRIESGO') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':NRIESGO', xnriesgo);
                  END IF;

                  IF INSTR(xs, ':FVALORA') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':FVALORA', xfecval);
                  END IF;

                  IF INSTR(xs, ':FECHA') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':FECHA', xfsinies);
                  END IF;

                  --JRH NDURPER Necesita NMOVIMI
                  DECLARE
                     nmovimi        NUMBER;
                  BEGIN
                     SELECT MAX(m.nmovimi)
                       INTO nmovimi
                       FROM movseguro m
                      WHERE m.sseguro = psseguro
                        AND TRUNC(m.fmovimi) <= TO_DATE(TO_CHAR(xfsinies), 'yyyymmdd');

                     IF INSTR(xs, ':NMOVIMI') > 0 THEN
                        DBMS_SQL.bind_variable(v_cursor, ':NMOVIMI', nmovimi);
                     END IF;
                  EXCEPTION
                     WHEN OTHERS THEN
                        IF INSTR(xs, ':NMOVIMI') > 0 THEN
                           DBMS_SQL.bind_variable(v_cursor, ':NMOVIMI', '1');
                        END IF;
                  END;

                  BEGIN
                     v_filas := DBMS_SQL.EXECUTE(v_cursor);
                     DBMS_SQL.variable_value(v_cursor, 'RETORNO', retorno);

                     IF DBMS_SQL.is_open(v_cursor) THEN
                        DBMS_SQL.close_cursor(v_cursor);
                     END IF;

                     IF retorno IS NULL THEN
                        RETURN 103135;
                     ELSE
                        e := graba_param(xxsesion, term.parametro, retorno);

                        IF e <> 0 THEN
                           RETURN 109843;
                        END IF;
                     END IF;
                  --dbms_output.put_line(term.parametro||':'||Retorno);
                  EXCEPTION
                     WHEN OTHERS THEN
                        --DBMS_OUTPUT.put_line(term.parametro||':'||0);
                        e := graba_param(xxsesion, term.parametro, 0);

                        IF e <> 0 THEN
                           RETURN 109843;
                        END IF;
                  END;
               END IF;
            --
            EXCEPTION
               WHEN OTHERS THEN
                  xs := NULL;
            END;
         END LOOP;

         --e := PAC_CALCULO_FORMULAS.calcula_terminos (xxsesion, reg.clave, 'PK_CALC_SINI', 0);
         carga_preguntas(psseguro, pfsinies, pcgarant, xxsesion);
    --
--dbms_output.put_line('CCAMPO:'||REG.CCAMPO||' clave Formula:'||reg.clave);
         val := pk_formulas.eval(xxformula, xxsesion);

--dbms_output.put_line('CCAMPO:'||REG.CCAMPO||' clave Formula:'||reg.clave);
         IF (val IS NULL
             OR val < 0) THEN
            p_tab_error(f_sysdate, f_user, 'pk_cal_sini.valo_pagos_sini', 1, xxsesion,
                        xxformula);
            RETURN 103135;
         ELSE
            IF reg.ccampo = 'ICAPRIS' THEN
               e := graba_param(xxsesion, 'ICAPRIS', val);
               xicapris := val;

               IF e <> 0 THEN
                  RETURN 109843;
               END IF;
            ELSIF reg.ccampo = 'IVALSIN' THEN
               e := graba_param(xxsesion, 'IVALSIN', val);
               xivalsin := val;

               IF e <> 0 THEN
                  RETURN 109843;
               END IF;
            ELSIF reg.ccampo = 'IPENALI' THEN
               e := graba_param(xxsesion, 'IPENALI', val);
               xipenali := val;

               IF e <> 0 THEN
                  RETURN 109843;
               END IF;
            END IF;
         END IF;
      END LOOP;   -- SINGARANFORMULA

--
      e := insertar_mensajes(0, psseguro, 0, 0, TO_NUMBER(TO_CHAR(pfsinies, 'yyyymmdd')),
                             pcactivi, pcgarant, xivalsin, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                             xxfperini, xxfperfin);

      IF e <> 0 THEN
         RETURN e;
      END IF;

-- Borro sgt_parms_transitorios
      e := borra_param(xxsesion);

      IF xivalsin IS NULL THEN
         pivalora := 0;
      ELSE
         pivalora := xivalsin;
      END IF;

      IF xipenali IS NULL THEN
         pipenali := 0;
      ELSE
         pipenali := xipenali;
      END IF;

      IF xicapris IS NULL THEN
         picapris := 0;
      ELSE
         picapris := xicapris;
      END IF;

      RETURN 0;
   END valo_pagos_sini;

-- ****************************************************************
-- Genera pagos del siniestro
-- ****************************************************************
-- Bug 8744 - 03/03/2009 - JRB - Se añaden los parámetro pfperini y pfperfin
   FUNCTION gen_pag_sini(
      pfsinies IN DATE,
      psseguro IN NUMBER,
      pnsinies IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER DEFAULT 0,
      pccausin IN NUMBER,   -- Causa del Siniestro
      pcmotsin IN NUMBER,   -- Subcausa
      pfnotifi IN DATE,   -- Fecha de Notificacion
      pnriesgo IN NUMBER DEFAULT NULL,
      p_fperini IN DATE DEFAULT NULL,   -- Fecha Inicio
      p_fperfin IN DATE DEFAULT NULL   -- Fecha Fin
                                    )
      RETURN NUMBER IS
-- Variables de asegurados
      xnroaseg       NUMBER;   -- Nro de Asegurados
-- Variables para mandar al calculo
      num_err        NUMBER;   -- Valor de retorno de funciones.
--
      xnriesgo       NUMBER;
      v_provisio     NUMBER;
   BEGIN
      DELETE FROM primas_consumidas
            WHERE nsinies = pnsinies;

      FOR dest IN (SELECT   DECODE(ctipdes, 6, 1, 2) orden, ctipdes, sperson
                       FROM destinatarios
                      WHERE nsinies = pnsinies
                   ORDER BY 1, 2) LOOP
--dbms_output.put_line('entramos en el cursor');
         IF dest.ctipdes = 1
            AND pnriesgo IS NULL THEN
--dbms_output.put_line('hacemos la select norden');
            BEGIN
               SELECT norden
                 INTO xnriesgo
                 FROM asegurados
                WHERE sperson = dest.sperson
                  AND sseguro = psseguro;
            EXCEPTION
               WHEN OTHERS THEN
                  xnriesgo := NULL;
            END;
         ELSE
            xnriesgo := pnriesgo;
         END IF;

--dbms_output.put_line('xnrisgo = '||xnriesgo);
 --
   --   IF DEST.CTIPDES <> 7 THEN
         FOR reg IN (SELECT DISTINCT cgarant
                                FROM valorasini
                               WHERE nsinies = pnsinies) LOOP
--dbms_output.put_line('para cada garantía');
            num_err := pac_sin.f_provisio_sini(pnsinies, reg.cgarant,
                                               GREATEST(pfsinies, TRUNC(f_sysdate)),
                                               v_provisio);

            --
         --   IF v_provisio IS NULL THEN v_provisio := 0; END IF;
--dbms_output.put_line('v_provisio ='||v_provisio);
            IF v_provisio IS NOT NULL THEN
             -- pk_cal_sini.borra_mensajes;
--dbms_output.put_line('calc_pagos_sini');
               num_err := pk_cal_sini.calc_pagos_sini(pnsinies, psproduc, pcactivi,
                                                      reg.cgarant, psseguro, pfsinies,
                                                      pccausin, pcmotsin, pfnotifi,
                                                      dest.sperson, dest.ctipdes, xnriesgo,
                                                      p_fperini, p_fperfin);

               IF num_err <> 0 THEN
                  RETURN num_err;
               END IF;
            END IF;
         END LOOP;
      --  END IF;
      END LOOP;

      RETURN 0;
   END gen_pag_sini;

-- ****************************************************************
-- Calcula los pagos del siniestro
-- ****************************************************************
-- Bug 8744 - 03/03/2009 - JRB - Se añaden los parámetros pfperini y pfperfin
   FUNCTION calc_pagos_sini(
      pnsinies IN NUMBER,   -- Nro. de Siniestro
      psproduc IN NUMBER,   -- SPRODUC
      pcactivi IN NUMBER,   -- Actividad
      pcgarant IN NUMBER,   -- Garantía
      psseguro IN NUMBER,   -- SSEGURO
      pfsinies IN DATE,   -- Fecha
      pccausin IN NUMBER,   -- Causa del Siniestro
      pcmotsin IN NUMBER,   -- Subcausa
      pfnotifi IN DATE,   -- Fecha de Notificacion
      psperdes IN NUMBER,   -- sperson del destinatario
      pctipdes IN NUMBER,   -- tipo de destinatario
      pnriesgo IN NUMBER DEFAULT NULL,
      p_fperini IN DATE DEFAULT NULL,   -- Fecha Inicio Pago
      p_fperfin IN DATE DEFAULT NULL   -- Fecha Fin Pago
                                    )
      RETURN NUMBER IS
      val            NUMBER;   -- Valor que retorna la formula
      xxformula      VARCHAR2(2000);   -- contiene la Formula a calcular
      xxsesion       NUMBER;   -- Nro de sesion que ejecuta la formula
      xfsinies       NUMBER;   -- Fecha de Entrada del siniestro
      xfecefe        NUMBER;
      xfnotifi       NUMBER;
      e              NUMBER;   -- Error Retorno funciones
      xivalsin       NUMBER;   -- Valoración del siniestro
      xipenali       NUMBER;   -- Penalización del siniestro
      xisinret       NUMBER;   -- Bruto
      xiresrcm       NUMBER;   -- Rendimientos
      xiresred       NUMBER;   -- Rendimientos Reducidos
      xiconret       NUMBER;   -- Base de Retención
      xpretenc       NUMBER;   -- % de Retención
      xiretenc       NUMBER;   -- Importe de Retención
      xiimpsin       NUMBER;   -- Importe Neto
      xsinacum       NUMBER;   -- Acumulado de Brutos
      xicapris       NUMBER;   -- Importe de Capital de Riesgo
      xnriesgo       NUMBER;
      xxcodigo       VARCHAR2(30);
      xs             VARCHAR2(2000);
      retorno        NUMBER;
      -- 07/07/2008
      v_cursor       INTEGER;
      v_filas        NUMBER;
      xfperini       NUMBER(8);
      xfperfin       NUMBER(8);

      CURSOR cur_campo(wcdestin NUMBER) IS
         --SELECT DECODE(ccampo,'ICAPRIS',1,'IVALSIN',2,'IPENALI',3,'ISINRET',4,
         --                     'IRESRCM',5,'IRESRED',6,'ICONRET',7,'PRETENC',8,
         --                     'IRETENC',9,'IIMPSIN',10) orden,
         --      ccampo, clave, cdestin,sprcamosin
         SELECT   DECODE(ccampo,
                         'ISINRET', 4,
                         'IRESRCM', 5,
                         'IRESRED', 6,
                         'ICONRET', 7,
                         'PRETENC', 8,
                         'IRETENC', 9,
                         'IIMPSIN', 10) orden,
                  ccampo, clave, cdestin, sprcamosin
             FROM sinigaranformula
            WHERE sprcamosin IN(SELECT sprcamosin
                                  FROM prodcaumotsin
                                 WHERE sproduc = psproduc
                                   AND cgarant = pcgarant
                                   AND cactivi = pcactivi
                                   AND ccausin = pccausin
                                   AND cmotsin = pcmotsin)
              AND cdestin = wcdestin
              AND ccampo IN('ICAPRIS', 'IVALSIN', 'IPENALI', 'ISINRET', 'IRESRCM', 'IRESRED',
                            'ICONRET', 'PRETENC', 'IRETENC', 'IIMPSIN')
         ORDER BY 1;

      CURSOR cur_termino(wclave NUMBER) IS
         SELECT   parametro
             FROM sgt_trans_formula
            WHERE clave = wclave
         ORDER BY 1;
   BEGIN
      xsinacum := 0;
      xfsinies := TO_NUMBER(TO_CHAR(pfsinies, 'yyyymmdd'));
      xfnotifi := TO_NUMBER(TO_CHAR(pfnotifi, 'yyyymmdd'));
      xfecefe := TO_NUMBER(TO_CHAR(f_sysdate, 'YYYYMMDD'));
      xfperini := TO_NUMBER(TO_CHAR(p_fperini, 'yyyymmdd'));
      xfperfin := TO_NUMBER(TO_CHAR(p_fperfin, 'yyyymmdd'));

      SELECT sgt_sesiones.NEXTVAL
        INTO xxsesion
        FROM DUAL;

      IF xxsesion IS NULL THEN
         ROLLBACK;
         RETURN 108418;
      END IF;

      IF pnriesgo IS NULL THEN
         BEGIN
            SELECT nriesgo
              INTO xnriesgo
              FROM siniestros
             WHERE nsinies = pnsinies;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 104755;   -- calve no esncontrada en siniestros
         END;
      ELSE
         xnriesgo := pnriesgo;
      END IF;

      -- Insertamos parametros genericos para el calculo de los pagos de un siniestro.
      e := graba_param(xxsesion, 'SESION', xxsesion);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := graba_param(xxsesion, 'FECEFE', xfecefe);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := graba_param(xxsesion, 'FNOTIFI', xfnotifi);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := graba_param(xxsesion, 'FSINIES', xfsinies);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := graba_param(xxsesion, 'SSEGURO', psseguro);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := graba_param(xxsesion, 'NSINIES', pnsinies);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := graba_param(xxsesion, 'SPRODUC', psproduc);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := graba_param(xxsesion, 'CACTIVI', pcactivi);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := graba_param(xxsesion, 'CGARANT', pcgarant);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := graba_param(xxsesion, 'ISINACU', xsinacum);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := graba_param(xxsesion, 'CCAUSIN', pccausin);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := graba_param(xxsesion, 'CMOTSIN', pcmotsin);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := graba_param(xxsesion, 'NRIESGO', xnriesgo);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := graba_param(xxsesion, 'FPERINI', xfperini);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := graba_param(xxsesion, 'FPERFIN', xfperfin);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      FOR reg IN cur_campo(pctipdes) LOOP
         e := graba_param(xxsesion, 'SPERDES', psperdes);

         IF e <> 0 THEN
            RETURN 109843;
         END IF;

         --
         BEGIN
            SELECT formula, codigo
              INTO xxformula, xxcodigo
              FROM sgt_formulas
             WHERE clave = reg.clave;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN 108423;
            WHEN OTHERS THEN
               RETURN 108423;
         END;

         -- Cargo parametros predefinidos
         -- RSC 09/06/2008 Tarea 5507 Utilización de bind variables
         -- 07/07/2008 Se rechaza el patch SNVA_249 Utilización de bind variables
         FOR term IN cur_termino(reg.clave) LOOP
            BEGIN
               BEGIN
                  SELECT 'BEGIN SELECT ' || tcampo || ' INTO :RETORNO  FROM ' || ttable
                         || ' WHERE ' || twhere || ' ; END;'
                    INTO xs
                    FROM sgt_carga_arg_prede
                   WHERE termino = term.parametro
                     AND ttable IS NOT NULL
                     AND cllamada = 'PK_CALC_SINI';
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN   --JRH 101/2008 Lo ponemos como en la simulación
                     SELECT 'BEGIN SELECT ' || tcampo || ' INTO :RETORNO  FROM ' || ttable
                            || ' WHERE ' || twhere || ' ; END;'
                       INTO xs
                       FROM sgt_carga_arg_prede
                      WHERE termino = term.parametro
                        AND ttable IS NOT NULL
                        AND cllamada = 'GENERICO';
               END;

               -- RSC 07/07/2008 Mejora propuesta por Sa Nostra (Patch SNVA_249b) Bind Variables
               IF DBMS_SQL.is_open(v_cursor) THEN
                  DBMS_SQL.close_cursor(v_cursor);
               END IF;

               v_cursor := DBMS_SQL.open_cursor;
               DBMS_SQL.parse(v_cursor, xs, DBMS_SQL.native);
               DBMS_SQL.bind_variable(v_cursor, ':RETORNO', retorno);

               IF INSTR(xs, ':NSINIES') > 0 THEN
                  DBMS_SQL.bind_variable(v_cursor, ':NSINIES', pnsinies);
               END IF;

               IF INSTR(xs, ':FECEFE') > 0 THEN
                  DBMS_SQL.bind_variable(v_cursor, ':FECEFE', xfecefe);
               END IF;

               IF INSTR(xs, ':FNOTIFI') > 0 THEN
                  DBMS_SQL.bind_variable(v_cursor, ':FNOTIFI', xfnotifi);
               END IF;

               IF INSTR(xs, ':FSINIES') > 0 THEN
                  DBMS_SQL.bind_variable(v_cursor, ':FSINIES', xfsinies);
               END IF;

               IF INSTR(xs, ':SSEGURO') > 0 THEN
                  DBMS_SQL.bind_variable(v_cursor, ':SSEGURO', psseguro);
               END IF;

               IF INSTR(xs, ':SPRODUC') > 0 THEN
                  DBMS_SQL.bind_variable(v_cursor, ':SPRODUC', psproduc);
               END IF;

               IF INSTR(xs, ':CACTIVI') > 0 THEN
                  DBMS_SQL.bind_variable(v_cursor, ':CACTIVI', pcactivi);
               END IF;

               IF INSTR(xs, ':CGARANT') > 0 THEN
                  DBMS_SQL.bind_variable(v_cursor, ':CGARANT', pcgarant);
               END IF;

               IF INSTR(xs, ':NRIESGO') > 0 THEN
                  DBMS_SQL.bind_variable(v_cursor, ':NRIESGO', xnriesgo);
               END IF;

               IF INSTR(xs, ':SPERDES') > 0 THEN
                  DBMS_SQL.bind_variable(v_cursor, ':SPERDES', psperdes);
               END IF;

               IF INSTR(xs, ':FECHA') > 0 THEN
                  DBMS_SQL.bind_variable(v_cursor, ':FECHA', xfsinies);
               END IF;

               --JRH NDURPER Necesita NMOVIMI
               DECLARE
                  nmovimi        NUMBER;
               BEGIN
                  SELECT MAX(m.nmovimi)
                    INTO nmovimi
                    FROM movseguro m
                   WHERE m.sseguro = psseguro
                     AND TRUNC(m.fmovimi) <= TO_DATE(TO_CHAR(xfsinies), 'yyyymmdd');

                  IF INSTR(xs, ':NMOVIMI') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':NMOVIMI', nmovimi);
                  END IF;
               EXCEPTION
                  WHEN OTHERS THEN
                     IF INSTR(xs, ':NMOVIMI') > 0 THEN
                        DBMS_SQL.bind_variable(v_cursor, ':NMOVIMI', '1');
                     END IF;
               END;

               BEGIN
                  v_filas := DBMS_SQL.EXECUTE(v_cursor);
                  DBMS_SQL.variable_value(v_cursor, 'RETORNO', retorno);

                  IF DBMS_SQL.is_open(v_cursor) THEN
                     DBMS_SQL.close_cursor(v_cursor);
                  END IF;

                  --dbms_output.put_line(term.parametro||':'||Retorno);
                  IF retorno IS NULL THEN
                     RETURN 103135;
                  ELSE
                     e := graba_param(xxsesion, term.parametro, retorno);

                     IF e <> 0 THEN
                        RETURN 109843;
                     END IF;
                  END IF;
               EXCEPTION
                  WHEN OTHERS THEN
                     p_tab_error(f_sysdate, getuser, 'PK_CAL_SINI.calc_pagos_sini', NULL,
                                 'Error al evaluar la formula', SQLERRM);
                     p_tab_error(f_sysdate, getuser, 'PK_CAL_SINI.calc_pagos_sini', NULL,
                                 'formula', xs);

                     IF DBMS_SQL.is_open(v_cursor) THEN
                        DBMS_SQL.close_cursor(v_cursor);
                     END IF;

--dbms_output.put_line(term.parametro||':'||0);
--DBMS_OUTPUT.put_line(SQLERRM);
                     e := graba_param(xxsesion, term.parametro, 0);

                     IF e <> 0 THEN
                        RETURN 109843;
                     END IF;
               END;
            --
            EXCEPTION
               WHEN OTHERS THEN
                  xs := NULL;
            END;
         END LOOP;

         --e := PAC_CALCULO_FORMULAS.calcula_terminos (xxsesion, reg.clave, 'PK_CALC_SINI', 1);
         carga_preguntas(psseguro, pfsinies, pcgarant, xxsesion);
         --
         val := pk_formulas.eval(xxformula, xxsesion);

         --
         IF val IS NULL THEN
            --commit;
            p_tab_error(f_sysdate, f_user, 'pk_cal_sini.calc_pagos_sini', 1, xxsesion,
                        xxformula);
            RETURN 103135;
         ELSE
            IF reg.ccampo = 'IVALSIN' THEN
               e := graba_param(xxsesion, 'IVALSIN', val);
               xivalsin := val;

               IF e <> 0 THEN
                  RETURN 109843;
               END IF;
            END IF;

            IF reg.ccampo = 'ICAPRIS' THEN
               e := graba_param(xxsesion, 'ICAPRIS', val);
               xicapris := val;

               IF e <> 0 THEN
                  RETURN 109843;
               END IF;
            END IF;

            IF reg.ccampo = 'IPENALI' THEN
               e := graba_param(xxsesion, 'IPENALI', val);
               xipenali := val;

               IF e <> 0 THEN
                  RETURN 109843;
               END IF;

               IF xipenali > 0 THEN
                  xivalsin := xivalsin - xipenali;
                  e := graba_param(xxsesion, 'IVALSIN', xivalsin);

                  IF e <> 0 THEN
                     RETURN 109843;
                  END IF;
               END IF;
            END IF;

            IF reg.ccampo = 'ISINRET' THEN
               e := graba_param(xxsesion, 'ISINRET', val);
               xisinret := val;

               IF e <> 0 THEN
                  RETURN 109843;
               END IF;

               xsinacum := xsinacum + val;
               e := graba_param(xxsesion, 'ISINACU', xsinacum);

               IF e <> 0 THEN
                  RETURN 109843;
               END IF;
            END IF;

            IF reg.ccampo = 'IRESRCM' THEN
               e := graba_param(xxsesion, 'IRESRCM', val);
               xiresrcm := val;

               IF e <> 0 THEN
                  RETURN 109843;
               END IF;
            END IF;

            IF reg.ccampo = 'IRESRED' THEN
               e := graba_param(xxsesion, 'IRESRED', val);
               xiresred := val;

               IF e <> 0 THEN
                  RETURN 109843;
               END IF;
            END IF;

            IF reg.ccampo = 'ICONRET' THEN
               e := graba_param(xxsesion, 'ICONRET', val);
               xiconret := val;

               IF e <> 0 THEN
                  RETURN 109843;
               END IF;
            END IF;

            IF reg.ccampo = 'PRETENC' THEN
               e := graba_param(xxsesion, 'PRETENC', val);
               xpretenc := val;

               IF e <> 0 THEN
                  RETURN 109843;
               END IF;
            END IF;

            IF reg.ccampo = 'IRETENC' THEN
               e := graba_param(xxsesion, 'IRETENC', val);
               xiretenc := val;

               IF e <> 0 THEN
                  RETURN 109843;
               END IF;
            END IF;

            IF reg.ccampo = 'IIMPSIN' THEN
               e := graba_param(xxsesion, 'IIMPSIN', val);
               xiimpsin := val;

               IF e <> 0 THEN
                  RETURN 109843;
               END IF;
            END IF;
         END IF;
      END LOOP;   -- SINGARANFORMULA

--dbms_output.put_line('inserta mensajes ?????????????????????????????????????????');
      --
      e := insertar_mensajes(1, psseguro, psperdes, pctipdes,
                             TO_NUMBER(TO_CHAR(pfsinies, 'yyyymmdd')), pcactivi, pcgarant,
                             xivalsin, xisinret, xiresrcm, xiresred, xiconret, xpretenc,
                             xiretenc, xiimpsin, 0, 0, 0, xfperini, xfperfin);

-- JLB - I - OPTIMI
      --DELETE      sgt_parms_transitorios
      --      WHERE sesion = xxsesion
     --         AND parametro IN('ISINRET', 'IRESRCM', 'IRESRED', 'ICONRET', 'PRETENC',
     --                          'PRETENC', 'IRETENC', 'IIMPSIN');
-- JLB - F - OPTIMI
      --
      IF e <> 0 THEN
         RETURN e;
      END IF;

      -- Borro sgt_parms_transitorios
      e := borra_param(xxsesion);
      RETURN 0;
   END calc_pagos_sini;

-- ****************************************************************
-- Graba mensajes
-- ****************************************************************
-- Bug 8744 - 03/03/2009 - JRB - Se añaden los parámetros pfperini y pfperfin
   FUNCTION insertar_mensajes(
      ptipo IN NUMBER,   -- Tipo 0-Valoración 1-Pago
      pseguro IN NUMBER,   -- Clave del Seguro
      psperson IN NUMBER,   -- Clave Persona
      pctipdes IN NUMBER,   -- Tipo destinatario
      pffecha IN NUMBER,   -- Fecha efecto
      pcactivi IN NUMBER,   -- Actividad
      pcgarant IN NUMBER,   -- Garantía
      pvalsin IN NUMBER,   -- Valoración del Siniestro
      pisinret IN NUMBER,   -- Bruto
      piresrcm IN NUMBER,   -- Rendimientos
      piresred IN NUMBER,   -- Rendimientos Reducidos
      piconret IN NUMBER,   -- Importe Base
      ppretenc IN NUMBER,   -- % de Retención
      piretenc IN NUMBER,   -- Importe de Retención
      piimpsin IN NUMBER,   -- Importe Neto
      picapris IN NUMBER,   -- Capital en riesgo de la valoracion
      pipenali IN NUMBER,   -- importe de penalización
      piprimas IN NUMBER,   -- primas satisfechas
      p_fperini IN NUMBER,   -- Fecha inicio pago
      p_fperfin IN NUMBER   -- Fecha fin pago
                         )
      RETURN NUMBER IS
   BEGIN
      gnvalor := gnvalor + 1;
      valores(gnvalor).ttipo := ptipo;
      valores(gnvalor).ssegu := pseguro;
      valores(gnvalor).perso := psperson;
      valores(gnvalor).desti := pctipdes;
      valores(gnvalor).ffecefe := pffecha;
      valores(gnvalor).ivalsin := pvalsin;
      valores(gnvalor).isinret := pisinret;
      valores(gnvalor).iresrcm := piresrcm;
      valores(gnvalor).iresred := piresred;
      valores(gnvalor).iconret := piconret;
      valores(gnvalor).pretenc := ppretenc;
      valores(gnvalor).iretenc := piretenc;
      valores(gnvalor).iimpsin := piimpsin;
      valores(gnvalor).cgarant := pcgarant;
      valores(gnvalor).cactivi := pcactivi;
      valores(gnvalor).icapris := picapris;
      valores(gnvalor).ipenali := pipenali;
      valores(gnvalor).iprimas := piprimas;
      valores(gnvalor).fperini := p_fperini;
      valores(gnvalor).fperfin := p_fperfin;
      RETURN 0;
   END insertar_mensajes;

-- ****************************************************************
-- Graba en pagosini
-- ****************************************************************
   FUNCTION insertar_pagos(pnsinies IN NUMBER)   -- Nro. de Siniestro
      RETURN NUMBER IS
      xsidepag       NUMBER;
      xctippag       NUMBER;
      xcconpag       NUMBER;
      xcestpag       NUMBER;
      xcforpag       NUMBER;
      xctransfer     NUMBER;
      xctransf       NUMBER;
      xsgt_sesiones  NUMBER;
      vfperini       DATE;
      vfperfin       DATE;

      -- xsperson        number;
      CURSOR dest(psgt_sesiones IN NUMBER) IS
         SELECT DISTINCT sperson
                    FROM pagos_tmp
                   WHERE sgt_sesiones = psgt_sesiones;

      num_err        NUMBER;
      nummy          NUMBER;

      CURSOR esvencrentas IS
         SELECT 1
           FROM siniestros s, seguros seg
          WHERE s.nsinies = pnsinies
            AND s.ccausin = 3
            AND seg.sseguro = s.sseguro
            AND NVL(f_parproductos_v(seg.sproduc, 'ES_PRODUCTO_RENTAS'), 0) = 1;

      --BUG 8744 - 13/05/2009 - JRB - Se añade para comprobar que es un producto de baja.
      v_sseguro      seguros.sseguro%TYPE;
      v_sproduc      seguros.sproduc%TYPE;
      v_cactivi      seguros.cactivi%TYPE;
      v_fnotifi      siniestros.fnotifi%TYPE;
      v_ivalora      valorasini.ivalora%TYPE;
      v_cramo        seguros.cramo%TYPE;
      v_cmodali      seguros.cmodali%TYPE;
      v_ctipseg      seguros.ctipseg%TYPE;
      v_ccolect      seguros.ccolect%TYPE;
      v_cvalpar      pargaranpro.cvalpar%TYPE;
      v_error        NUMBER;
   BEGIN
      xcforpag := 2;   -- Transferencia
      xctippag := 2;   -- Pago
      xcestpag := 0;   -- Pendiente
      xctransfer := 0;   -- NO TRANSFERIR
      xctransf := 0;   -- Pendiente de transferir

      OPEN esvencrentas;   --Si es un vencimiento de rentas se deja como pdte. de transferir.

      FETCH esvencrentas
       INTO nummy;

      IF esvencrentas%FOUND THEN
         xcestpag := 1;
      END IF;

      CLOSE esvencrentas;

      SELECT sgt_sesiones.NEXTVAL
        INTO xsgt_sesiones
        FROM DUAL;

 --dbms_output.put_line('pk_cal_sini.valores.count **********************='||Pk_Cal_Sini.VALORES.COUNT);
--
      FOR j IN 1 .. pk_cal_sini.valores.COUNT LOOP
         IF pk_cal_sini.valores(j).ttipo = 1 THEN
            IF pk_cal_sini.valores(j).desti = 7 THEN   -- Es tomador
               xcconpag := 0;   -- Pago Comercial
            ELSE
               xcconpag := 1;   -- Indemnización
            END IF;

            -- Bug 8744 - 03/03/2009 - JRB - Se añaden las fechas de inicio y fin del pago
            vfperini := TO_DATE(pk_cal_sini.valores(j).fperini, 'YYYYMMDD');
            vfperfin := TO_DATE(pk_cal_sini.valores(j).fperfin, 'YYYYMMDD');

            --BUG 8744 - 13/05/2009 - JRB - Se añade para comprobar que es un producto de baja y dejar pendiente de transferir.
            SELECT seg.sseguro, sproduc, cactivi, SIN.fnotifi, seg.cramo, seg.cmodali,
                   seg.ctipseg, seg.ccolect, seg.cactivi
              INTO v_sseguro, v_sproduc, v_cactivi, v_fnotifi, v_cramo, v_cmodali,
                   v_ctipseg, v_ccolect, v_cactivi
              FROM seguros seg, siniestros SIN
             WHERE SIN.nsinies = pnsinies
               AND seg.sseguro = SIN.sseguro;

            v_error := f_pargaranpro(v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_cactivi,
                                     pk_cal_sini.valores(j).cgarant, 'BAJA', v_cvalpar);

            IF v_cvalpar = 1 THEN
               xctransfer := 1;
               xctransf := 1;
               xcestpag := 1;
            END IF;

            --
            -- Bug 8744 - 03/03/2009 - JRB - Controla que el pago no sea 0
            IF pk_cal_sini.valores(j).perso IS NOT NULL THEN
               IF (NVL(pk_cal_sini.valores(j).iimpsin, 0) <> 0
                   OR(NVL(pk_cal_sini.valores(j).isinret, 0)
                      - NVL(pk_cal_sini.valores(j).iretenc, 0)) <> 0
                   OR NVL(pk_cal_sini.valores(j).iconret, 0) <> 0
                   OR NVL(pk_cal_sini.valores(j).iretenc, 0) <> 0
                   OR NVL(pk_cal_sini.valores(j).pretenc, 0) <> 0
                   OR NVL(pk_cal_sini.valores(j).iresrcm, 0) <> 0
                   OR NVL(pk_cal_sini.valores(j).iresred, 0) <> 0) THEN
                  --dbms_output.put_line('insert en pagos_tmp************************************');
                  BEGIN
                     INSERT INTO pagos_tmp
                                 (sgt_sesiones, nsinies, ctipdes,
                                  sperson,
                                  cgarant,
                                  fefepag,
                                  isinret,
                                  iconret,
                                  iretenc, iimpiva,
                                  pretenc,
                                  iimpsin,
                                  iresrcm,
                                  iresred, fperini, fperfin)
                          VALUES (xsgt_sesiones, pnsinies, pk_cal_sini.valores(j).desti,
                                  pk_cal_sini.valores(j).perso,
                                  pk_cal_sini.valores(j).cgarant,
                                  TO_DATE(pk_cal_sini.valores(j).ffecefe, 'YYYYMMDD'),
                                  NVL(pk_cal_sini.valores(j).isinret, 0),
                                  NVL(pk_cal_sini.valores(j).iconret, 0),
                                  NVL(pk_cal_sini.valores(j).iretenc, 0), 0,
                                  NVL(pk_cal_sini.valores(j).pretenc, 0),
                                  pk_cal_sini.valores(j).isinret
                                  - NVL(pk_cal_sini.valores(j).iretenc, 0),
                                  NVL(pk_cal_sini.valores(j).iresrcm, 0),
                                  NVL(pk_cal_sini.valores(j).iresred, 0), vfperini, vfperfin);
                  EXCEPTION
                     WHEN OTHERS THEN
                        RETURN 109022;   -- Errror en la inserción del pago
                  END;
               END IF;
            ELSE
               RETURN 102755;   -- eLEGIR DESTIANTARIO
            END IF;
         END IF;
      END LOOP;

--dbms_output.put_line('hacemos el loop de pagosini');
 -- Ahora hacemos el insert en PAGOGARANTÍA y en PAGOSINI agrupando por destinatario y garantía
      FOR i IN dest(xsgt_sesiones) LOOP
         -- RSC 26/06/2008 Tarea 6417 Incidencia siniestro PPA
         --dbms_output.put_line('dest ='||i.sperson);
         -- Bug 8744 - 03/03/2009 - JRB - Se añaden las fechas de inicio y fin del pago
         FOR regs IN (SELECT   p.ctipdes, p.sperson, p.pretenc, p.fefepag, p.fperini,
                               p.fperfin, SUM(p.isinret) isinret, SUM(p.iconret) iconret,
                               SUM(p.iretenc) iretenc, SUM(p.iimpsin) iimpsin,
                               SUM(p.iresrcm) iresrcm, SUM(p.iresred) iresred
                          FROM pagos_tmp p
                         WHERE p.sgt_sesiones = xsgt_sesiones
                           AND p.sperson = i.sperson
                      GROUP BY p.ctipdes, p.sperson, p.pretenc, p.fefepag, p.fperini,
                               p.fperfin) LOOP
            SELECT sidepag.NEXTVAL
              INTO xsidepag
              FROM DUAL;

            BEGIN
               INSERT INTO pagosini
                           (sidepag, nsinies, ctipdes, sperson, ctippag,
                            cconpag, cestpag, ctransfer, ctransf, cforpag, cptotal, cpagcoa,
                            fefepag, fordpag, isinret, iconret, iretenc,
                            pretenc, iimpiva, isiniva, iimpsin, spganul, nfacref, ffacref,
                            fcontab, sprocon, crefer, iresrcm, iresred, cmanual, cimpres,
                            fperini, fperfin)
                    VALUES (xsidepag, pnsinies, regs.ctipdes, regs.sperson, xctippag,
                            xcconpag, xcestpag, xctransfer, xctransf, xcforpag, 0, 0,
                            NULL, TRUNC(f_sysdate), regs.isinret, regs.iconret, regs.iretenc,
                            regs.pretenc, 0, regs.isinret, regs.iimpsin, NULL, NULL, NULL,
                            regs.fefepag, NULL, NULL, regs.iresrcm, regs.iresred, 1, 0,
                            regs.fperini, regs.fperfin);
            EXCEPTION
               WHEN OTHERS THEN
                  --DBMS_OUTPUT.put_line(SQLERRM);
                  RETURN 109022;   -- Error en la inserccion del apunte del pago;
            END;

            num_err := pac_sin.f_mantdiario_pagosini(pnsinies, 0, xsidepag, xcestpag,
                                                     i.sperson);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;

            BEGIN
               INSERT INTO pagogarantia
                           (cgarant, sidepag, isinret, fperini, fperfin, iimpiva)
                  (SELECT p.cgarant, xsidepag, isinret, fperini, fperfin, 0
                     FROM pagos_tmp p
                    WHERE p.sgt_sesiones = xsgt_sesiones
                      AND p.sperson = i.sperson
                      AND p.ctipdes = regs.ctipdes
                      AND p.pretenc = regs.pretenc
                      AND p.fefepag = regs.fefepag);
            EXCEPTION
               WHEN OTHERS THEN
                  --DBMS_OUTPUT.put_line(SQLERRM);
                  RETURN 109022;   -- Error en la inserccion del apunte del pago
            END;
         END LOOP;
      /*
      BEGIN
        --dbms_output.put_line('insert pagosini');
        INSERT INTO PAGOSINI
        (SIDEPAG,NSINIES,CTIPDES, SPERSON,CTIPPAG,CCONPAG,CESTPAG, ctransfer, ctransf,
         CFORPAG,CPTOTAL,CPAGCOA,FEFEPAG, FORDPAG,
             ISINRET,ICONRET, IRETENC,PRETENC, IIMPIVA,ISINIVA,
             IIMPSIN,SPGANUL,NFACREF,FFACREF,FCONTAB, SPROCON,CREFER,
         IRESRCM,IRESRED,CMANUAL,CIMPRES)
            (SELECT xsidepag, pnsinies, ctipdes, sperson, xctippag, xcconpag, xcestpag, xctransfer, xctransf,
                    xcforpag, 0, 0, NULL, TRUNC(f_sysdate),
                            SUM(isinret), SUM(iconret), SUM(iretenc), pretenc, 0, SUM(isinret),
                            SUM(iimpsin), NULL, NULL, NULL, fefepag, NULL, NULL,
                            SUM(iresrcm), SUM(iresred), 1, 0
             FROM pagos_tmp
             WHERE sgt_sesiones = xsgt_sesiones
               AND sperson = i.sperson
                   GROUP BY ctipdes, sperson, pretenc, fefepag);
       EXCEPTION
          WHEN OTHERS THEN
               --DBMS_OUTPUT.put_line(SQLERRM);
               RETURN 109022; -- Error en la inserccion del apunte del pago;
       END;

       num_err := pac_sin.f_mantdiario_pagosini(pnsinies, 0, xsidepag, xcestpag, i.sperson );
       IF num_err <> 0 THEN
          RETURN num_err;
       END IF;
       --
       BEGIN
          INSERT INTO PAGOGARANTIA
         (CGARANT,SIDEPAG,ISINRET,FPERINI,FPERFIN,IIMPIVA)
         (SELECT cgarant, xsidepag, isinret, NULL, NULL, 0
          FROM pagos_tmp
          WHERE sgt_sesiones = xsgt_sesiones
             AND sperson = i.sperson);
      EXCEPTION
          WHEN OTHERS THEN
             --DBMS_OUTPUT.put_line(SQLERRM);
             RETURN 109022; -- Error en la inserccion del apunte del pago
       END;
       */
      END LOOP;

      DELETE FROM pagos_tmp
            WHERE sgt_sesiones = xsgt_sesiones;

      borra_mensajes;
      RETURN 0;
   -- BUG -21546_108724- 09/02/2012 - JLTS - Cierre de posibles cursores abiertos, se adiciona EXCEPTION
   EXCEPTION
      WHEN OTHERS THEN
         IF esvencrentas%ISOPEN THEN
            CLOSE esvencrentas;
         END IF;

         RETURN 140999;
   END insertar_pagos;

-- ****************************************************************
-- Graba en la tabla de parametros transitorios parametros calculo
-- ****************************************************************
   FUNCTION graba_param(wnsesion IN NUMBER, wparam IN VARCHAR2, wvalor IN NUMBER)
      RETURN NUMBER IS
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
         -- I - JLB - OTIMI
      --   INSERT INTO sgt_parms_transitorios
      --               (sesion, parametro, valor)
      --        VALUES (wnsesion, wparam, wvalor);

      --      COMMIT;
      RETURN pac_sgt.put(wnsesion, wparam, wvalor);
   --    RETURN 0;
   EXCEPTION
--      WHEN DUP_VAL_ON_INDEX THEN
--         UPDATE sgt_parms_transitorios
--            SET valor = wvalor
--          WHERE sesion = wnsesion
--            AND parametro = wparam;

      --         COMMIT;
--         RETURN 0;
      WHEN OTHERS THEN
              --dbms_output.put_line(SQLERRM);
         --     COMMIT;
         RETURN 109843;
   -- F - JLB - OPTIMI
   END graba_param;

-- ****************************************************************
-- Borra parametros grabados en la sesion
-- ****************************************************************
   FUNCTION borra_param(wnsesion IN NUMBER)
      RETURN NUMBER IS
   BEGIN
      -- I - JLB - optimi
      --DELETE FROM sgt_parms_transitorios
      --      WHERE sesion = wnsesion;

      --RETURN 0;
      RETURN pac_sgt.del(wnsesion);
   -- F - JLB - optimi
   EXCEPTION
      WHEN OTHERS THEN
         --dbms_output.put_line(SQLERRM);
         RETURN -9;
   END borra_param;

-- ****************************************************************
--  Devuelve mensaje (modo previo)
-- ****************************************************************
   FUNCTION ver_mensajes(nerr IN NUMBER)
      RETURN VARCHAR2 IS
   BEGIN
      RETURN pk_cal_sini.valores(nerr).ttipo || ';' || pk_cal_sini.valores(nerr).ssegu || ';'
             || pk_cal_sini.valores(nerr).perso || ';' || pk_cal_sini.valores(nerr).desti
             || ';' || pk_cal_sini.valores(nerr).ffecefe || ';'
             || pk_cal_sini.valores(nerr).cactivi || ';' || pk_cal_sini.valores(nerr).cgarant
             || ';' || pk_cal_sini.valores(nerr).ivalsin || ';'
             || pk_cal_sini.valores(nerr).isinret || ';' || pk_cal_sini.valores(nerr).iresrcm
             || ';' || pk_cal_sini.valores(nerr).iresred || ';'
             || pk_cal_sini.valores(nerr).iconret || ';' || pk_cal_sini.valores(nerr).pretenc
             || ';' || pk_cal_sini.valores(nerr).iretenc || ';'
             || pk_cal_sini.valores(nerr).iimpsin || ';' || pk_cal_sini.valores(nerr).iprimas;
   END ver_mensajes;

-- ****************************************************************
--  Borra mensajes
-- ****************************************************************
   PROCEDURE borra_mensajes IS
   BEGIN
      valores.DELETE;
      gnvalor := 0;
   END borra_mensajes;

-- ****************************************************************
--  Retorna valores
-- ****************************************************************
   FUNCTION retorna_valores
      RETURN t_val IS
   BEGIN
      RETURN valores;
   END retorna_valores;

   FUNCTION f_simu_calc_sini(
      pfsinies IN DATE,
      pfnotifi IN DATE,
      psseguro IN NUMBER,
      pcactivi IN NUMBER,
      psproduc IN NUMBER,
      pcgarant IN NUMBER,
      pccausin IN NUMBER,
      pcmotsin IN NUMBER,
      picapital IN NUMBER DEFAULT NULL,
      pnriesgo IN NUMBER DEFAULT NULL,
      pfecval IN DATE DEFAULT NULL,
      pctipdes IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      /*
       {Cursor formulas de la valoracion: destinatario 0}
      */
      CURSOR cur_campo IS
         SELECT   DECODE(ccampo, 'ICAPRIS', 1, 'IVALSIN', 3, 'IPENALI', 2) orden, ccampo,
                  clave, cdestin
             FROM sinigaranformula
            WHERE sprcamosin IN(SELECT sprcamosin
                                  FROM prodcaumotsin
                                 WHERE sproduc = psproduc
                                   AND cgarant = pcgarant
                                   AND cactivi = pcactivi
                                   AND ccausin = pccausin
                                   AND cmotsin = pcmotsin)
              AND cdestin = 0
              AND ccampo IN('ICAPRIS', 'IVALSIN', 'IPENALI')
         ORDER BY 1;

      /*
       {cursor de formulas para el pago}
      */
      CURSOR cur_pago(wcdestin NUMBER) IS
         SELECT   DECODE(ccampo,
                         'ICAPRIS', 1,
                         'IPENALI', 2,
                         'IVALSIN', 3,
                         'ISINRET', 4,
                         'IRESRCM', 5,
                         'IRESRED', 6,
                         'ICONRET', 7,
                         'PRETENC', 8,
                         'IRETENC', 9,
                         'IIMPSIN', 10,
                         'IPRIMAS', 11) orden,
                  ccampo, clave, cdestin, sprcamosin
             FROM sinigaranformula
            WHERE sprcamosin IN(SELECT sprcamosin
                                  FROM prodcaumotsin
                                 WHERE sproduc = psproduc
                                   AND cgarant = pcgarant
                                   AND cactivi = pcactivi
                                   AND ccausin = pccausin
                                   AND cmotsin = pcmotsin)
              AND cdestin = wcdestin
              AND ccampo IN('ICAPRIS', 'IVALSIN', 'IPENALI', 'ISINRET', 'IRESRCM', 'IRESRED',
                            'ICONRET', 'PRETENC', 'IRETENC', 'IIMPSIN', 'IPRIMAS')
         ORDER BY 1;

--
      CURSOR cur_termino(wclave NUMBER) IS
         SELECT   parametro
             FROM sgt_trans_formula
            WHERE clave = wclave
         ORDER BY 1;

      CURSOR cur_aseg IS
         SELECT asegurados.norden, asegurados.sperson
           FROM asegurados, seguros
          WHERE asegurados.ffecmue IS NULL
            AND asegurados.sseguro = psseguro
            AND asegurados.ffecfin IS NULL
            AND asegurados.sseguro = seguros.sseguro
            -- Bug 15298 - JRH - 12/07/2010 - 0015298: CEM210 - RESCATS: Simulació pagaments rendes per productes 2 CABEZAS
            AND((NVL(f_parproductos_v(seguros.sproduc, 'FISCALIDAD_2_CABEZAS'), 0) =
                    1   --JRH Si 'FISCALIDAD_2_CABEZAS' =1 sólo e paga a un asegurado , el cursor debe devolver 1 registro
                 AND pccausin IN(3, 4, 5)
                 AND asegurados.norden = (SELECT MIN(as2.norden)
                                            FROM asegurados as2
                                           WHERE as2.sseguro = asegurados.sseguro
                                             AND as2.ffecmue IS NULL
                                             AND as2.ffecfin IS NULL))
                OR(NVL(f_parproductos_v(seguros.sproduc, 'FISCALIDAD_2_CABEZAS'), 0) <> 1)
                OR(NVL(f_parproductos_v(seguros.sproduc, 'FISCALIDAD_2_CABEZAS'), 0) = 1
                   AND pccausin NOT IN(3, 4, 5)));   -- BUG11183:DRA:22/09/2009

      w_error        NUMBER;
      w_fsinies      NUMBER;
      w_fnotifi      NUMBER;
      w_fecefe       NUMBER;
      w_fecval       NUMBER;
      w_sesion       NUMBER;
      w_nriesgo      NUMBER;
      w_retorno      NUMBER;
      w_val          NUMBER;
      w_ctipdes      NUMBER;
      w_ivalsin      NUMBER;
      w_icapris      NUMBER;
      w_ipenali      NUMBER;
      w_isinret      NUMBER;
      w_sinacum      NUMBER;
      w_iresred      NUMBER;
      w_iresrcm      NUMBER;
      w_iconret      NUMBER;
      w_pretenc      NUMBER;
      w_iretenc      NUMBER;
      w_iimpsin      NUMBER;
      w_nsinies      NUMBER := 0;
      w_formula      VARCHAR2(2000);
      w_xs           VARCHAR2(2000);
      w_codigo       VARCHAR2(2000);
      w_isinret_total NUMBER := 0;
      w_iresrcm_total NUMBER := 0;
      w_iresred_total NUMBER := 0;
      w_iconret_total NUMBER := 0;
      w_iretenc_total NUMBER := 0;
      w_iimpsin_total NUMBER := 0;
      xcuantos       NUMBER;
      w_iprimas      NUMBER;
      w_iprimas_total NUMBER := 0;
      -- 07/07/2008
      v_cursor       INTEGER;
      v_filas        NUMBER;
      vsproduc       NUMBER;
   BEGIN
      SELECT sproduc
        INTO vsproduc
        FROM seguros
       WHERE sseguro = psseguro;

      borra_mensajes;
      /*
      {convertimos las fechas a formato numerico}
      */
      w_fsinies := TO_NUMBER(TO_CHAR(pfsinies, 'yyyymmdd'));
      w_fnotifi := TO_NUMBER(TO_CHAR(pfnotifi, 'yyyymmdd'));

      IF NVL(f_parproductos_v(vsproduc, 'ES_PRODUCTO_RENTAS'), 0) = 1 THEN
         SELECT TO_NUMBER(TO_CHAR(NVL(sa.frevant, s.fefecto), 'YYYYMMDD'))
           INTO w_fecefe
           FROM seguros_aho sa, seguros s
          WHERE sa.sseguro = s.sseguro
            AND s.sseguro = psseguro;
      ELSE
         w_fecefe := TO_NUMBER(TO_CHAR(f_sysdate, 'YYYYMMDD'));
      END IF;

      w_fecval := TO_NUMBER(TO_CHAR(pfecval, 'YYYYMMDD'));

      SELECT sgt_sesiones.NEXTVAL
        INTO w_sesion
        FROM DUAL;

      IF w_sesion IS NULL THEN
         ROLLBACK;
         RETURN 108418;
      END IF;

      w_nriesgo := NVL(pnriesgo, 1);
      /*
      { Insertamos los parametros genericos para el calculo de un seguro.}
      */
      w_error := graba_param(w_sesion, 'ORIGEN', 2);

      IF w_error <> 0 THEN
         RETURN 109843;
      END IF;

      w_error := graba_param(w_sesion, 'SESION', w_sesion);

      IF w_error <> 0 THEN
         RETURN 109843;
      END IF;

      w_error := graba_param(w_sesion, 'FECEFE', w_fecefe);

      IF w_error <> 0 THEN
         RETURN 109843;
      END IF;

      w_error := graba_param(w_sesion, 'FNOTIFI', w_fnotifi);

      IF w_error <> 0 THEN
         RETURN 109843;
      END IF;

      w_error := graba_param(w_sesion, 'FSINIES', w_fsinies);

      IF w_error <> 0 THEN
         RETURN 109843;
      END IF;

      w_error := graba_param(w_sesion, 'SSEGURO', psseguro);

      IF w_error <> 0 THEN
         RETURN 109843;
      END IF;

      w_error := graba_param(w_sesion, 'NSINIES', w_nsinies);

      IF w_error <> 0 THEN
         RETURN 109843;
      END IF;

      w_error := graba_param(w_sesion, 'SPRODUC', psproduc);

      IF w_error <> 0 THEN
         RETURN 109843;
      END IF;

      w_error := graba_param(w_sesion, 'CACTIVI', pcactivi);

      IF w_error <> 0 THEN
         RETURN 109843;
      END IF;

      w_error := graba_param(w_sesion, 'CGARANT', pcgarant);

      IF w_error <> 0 THEN
         RETURN 109843;
      END IF;

      w_error := graba_param(w_sesion, 'CCAUSIN', pccausin);

      IF w_error <> 0 THEN
         RETURN 109843;
      END IF;

      w_error := graba_param(w_sesion, 'CMOTSIN', pcmotsin);

      IF w_error <> 0 THEN
         RETURN 109843;
      END IF;

      w_error := graba_param(w_sesion, 'NRIESGO', w_nriesgo);

      IF w_error <> 0 THEN
         RETURN 109843;
      END IF;

      w_error := graba_param(w_sesion, 'FVALORA', w_fecval);

      IF w_error <> 0 THEN
         RETURN 109843;
      END IF;

--DBMS_OUTPUT.PUT_LINE('********** INICIALITZEM LA VALORACION **********');
      /*
      {Calculamos las formulas de la valoracion}
      */
      FOR reg IN cur_campo LOOP
         BEGIN
            SELECT formula
              INTO w_formula
              FROM sgt_formulas
             WHERE clave = reg.clave;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN 108423;
            WHEN OTHERS THEN
               RETURN 108423;
         END;

         --DBMS_OUTPUT.PUT_LINE('Formula '||reg.clave);
         -- {Cargo parametros predefinidos}
         -- RSC 09/06/2008 Tarea 5507 Utilización de bind variables
         -- RSC 07/07/2008 Se rechaza el Patch SNVA_249 (Tarea 5507).
         -- Se incluye modificación propuesta.
         FOR term IN cur_termino(reg.clave) LOOP
            BEGIN
               IF (term.parametro <> 'IVALSIN'
                   AND term.parametro <> 'ICAPRIS') THEN
                  -- {Se esta calculando en este momento}
                  --dbms_output.put_line('term.parametro:'||term.parametro);
                  BEGIN
                     SELECT 'BEGIN SELECT ' || tcampo || ' INTO :RETORNO  FROM ' || ttable
                            || ' WHERE ' || twhere || ' ; END;'
                       INTO w_xs
                       FROM sgt_carga_arg_prede
                      WHERE termino = term.parametro
                        AND ttable IS NOT NULL
                        AND cllamada = 'PK_CALC_SINI';
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        --DBMS_OUTPUT.PUT_LINE('Termino'||term.parametro);
                        SELECT 'BEGIN SELECT ' || tcampo || ' INTO :RETORNO  FROM ' || ttable
                               || ' WHERE ' || twhere || ' ; END;'
                          INTO w_xs
                          FROM sgt_carga_arg_prede
                         WHERE termino = term.parametro
                           AND ttable IS NOT NULL
                           AND cllamada = 'GENERICO';
                  END;

                  -- RSC 07/07/2008 Mejora propuesta por Sa Nostra (Patch SNVA_249b) Bind Variables
                  IF DBMS_SQL.is_open(v_cursor) THEN
                     DBMS_SQL.close_cursor(v_cursor);
                  END IF;

                  v_cursor := DBMS_SQL.open_cursor;
                  DBMS_SQL.parse(v_cursor, w_xs, DBMS_SQL.native);
                  DBMS_SQL.bind_variable(v_cursor, ':RETORNO', w_retorno);

                  IF INSTR(w_xs, ':FECEFE') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':FECEFE', w_fecefe);
                  END IF;

                  IF INSTR(w_xs, ':NSINIES') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':NSINIES', w_nsinies);
                  END IF;

                  IF INSTR(w_xs, ':FSINIES') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':FSINIES', w_fsinies);
                  END IF;

                  IF INSTR(w_xs, ':FECHA') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':FECHA', w_fsinies);
                  END IF;

                  IF INSTR(w_xs, ':FNOTIFI') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':FNOTIFI', w_fnotifi);
                  END IF;

                  IF INSTR(w_xs, ':SSEGURO') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':SSEGURO', psseguro);
                  END IF;

                  IF INSTR(w_xs, ':SPRODUC') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':SPRODUC', psproduc);
                  END IF;

                  IF INSTR(w_xs, ':CACTIVI') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':CACTIVI', pcactivi);
                  END IF;

                  IF INSTR(w_xs, ':CGARANT') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':CGARANT', pcgarant);
                  END IF;

                  IF INSTR(w_xs, ':NRIESGO') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':NRIESGO', w_nriesgo);
                  END IF;

                  --JRH NDURPER Necesita NMOVIMI
                  DECLARE
                     nmovimi        NUMBER;
                  BEGIN
                     SELECT MAX(m.nmovimi)
                       INTO nmovimi
                       FROM movseguro m
                      WHERE m.sseguro = psseguro
                        AND TRUNC(m.fmovimi) <= TO_DATE(TO_CHAR(w_fsinies), 'yyyymmdd');

                     IF INSTR(w_xs, ':NMOVIMI') > 0 THEN
                        DBMS_SQL.bind_variable(v_cursor, ':NMOVIMI', nmovimi);
                     END IF;
                  EXCEPTION
                     WHEN OTHERS THEN
                        IF INSTR(w_xs, ':NMOVIMI') > 0 THEN
                           DBMS_SQL.bind_variable(v_cursor, ':NMOVIMI', '1');
                        END IF;
                  END;

                  BEGIN
                     v_filas := DBMS_SQL.EXECUTE(v_cursor);
                     DBMS_SQL.variable_value(v_cursor, 'RETORNO', w_retorno);

                     IF DBMS_SQL.is_open(v_cursor) THEN
                        DBMS_SQL.close_cursor(v_cursor);
                     END IF;

                     IF w_retorno IS NULL THEN
                        RETURN 103135;
                     ELSE
                        w_error := graba_param(w_sesion, term.parametro, w_retorno);

                        IF w_error <> 0 THEN
                           RETURN 109843;
                        END IF;
                     END IF;
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_tab_error(f_sysdate, getuser, 'PK_CAL_SINI.f_simu_calc_sini', NULL,
                                    'Error al evaluar la formula', SQLERRM);
                        p_tab_error(f_sysdate, getuser, 'PK_CAL_SINI.f_simu_calc_sini', NULL,
                                    'formula', w_xs);

                        IF DBMS_SQL.is_open(v_cursor) THEN
                           DBMS_SQL.close_cursor(v_cursor);
                        END IF;

--dbms_output.put_line('Err222:'||sqlerrm);
                        w_error := graba_param(w_sesion, term.parametro, 0);

                        IF w_error <> 0 THEN
                           RETURN 109843;
                        END IF;
                  END;
               END IF;
            EXCEPTION
               WHEN OTHERS THEN
                  --dbms_output.put_line('Err21:'||sqlerrm);
                  w_xs := NULL;
            END;
         END LOOP;

         --w_error := PAC_CALCULO_FORMULAS.calcula_terminos (w_sesion, reg.clave, 'PK_CALC_SINI', 0);
         carga_preguntas(psseguro, pfsinies, pcgarant, w_sesion);

         --

         -- Bug 11993 - 16/11/2009 - RSC - CRE - Ajustes PPJ Dinámico/Pla Estudiant
         IF picapital IS NOT NULL THEN
            w_error := graba_param(w_sesion, 'IVALSIN', picapital);
            w_ivalsin := picapital;

            IF w_error <> 0 THEN
               RETURN 109843;
            END IF;

            w_error := graba_param(w_sesion, 'ICAPRIS', picapital);
            w_icapris := picapital;

            IF w_error <> 0 THEN
               RETURN 109843;
            END IF;

            IF reg.ccampo = 'IPENALI' THEN
               -- Volvemos a evaluar la penalización ya que hemos modificado el ICAPRIS
               w_val := pk_formulas.eval(w_formula, w_sesion);
               w_error := graba_param(w_sesion, 'IPENALI', w_val);
               w_ipenali := w_val;

               IF w_error <> 0 THEN
                  RETURN 109843;
               END IF;
            ELSE
               w_val := pk_formulas.eval(w_formula, w_sesion);
            END IF;
         ELSE
            -- Fin Bug 11993
            w_val := pk_formulas.eval(w_formula, w_sesion);
         -- Bug 11993 - 16/11/2009 - RSC - CRE - Ajustes PPJ Dinámico/Pla Estudiant
         END IF;

         -- Fin Bug 11993
         IF (w_val IS NULL
             OR w_val < 0) THEN
            p_tab_error(f_sysdate, f_user, 'pk_cal_sini.f_simu_calc_sini', 1, reg.ccampo,
                        w_formula);
            RETURN 103135;
         ELSE
            IF picapital IS NULL THEN
               IF reg.ccampo = 'ICAPRIS' THEN
                  w_error := graba_param(w_sesion, 'ICAPRIS', w_val);
                  w_icapris := w_val;

                  IF w_error <> 0 THEN
                     RETURN 109843;
                  END IF;
               ELSIF reg.ccampo = 'IVALSIN' THEN
                  w_error := graba_param(w_sesion, 'IVALSIN', w_val);
                  w_ivalsin := w_val;

                  IF w_error <> 0 THEN
                     RETURN 109843;
                  END IF;
               ELSIF reg.ccampo = 'IPENALI' THEN
                  w_error := graba_param(w_sesion, 'IPENALI', w_val);
                  w_ipenali := w_val;

                  IF w_error <> 0 THEN
                     RETURN 109843;
                  END IF;
               END IF;
            END IF;
         END IF;
      END LOOP;

      --DBMS_OUTPUT.PUT_LINE('********** FINALIZAMOS LA VALORACION **********');

      /*
       {si el tipo de destinatario no esta informado miramos que tipo de dest. tiene el pago}
      */
      IF pctipdes IS NULL THEN
         BEGIN
            SELECT cdestin
              INTO w_ctipdes
              FROM destipermisin
             WHERE cdestin <> 0
               AND sprcamosin IN(SELECT sprcamosin
                                   FROM prodcaumotsin
                                  WHERE sproduc = psproduc
                                    AND cgarant = pcgarant
                                    AND cactivi = pcactivi
                                    AND ccausin = pccausin
                                    AND cmotsin = pcmotsin);
         EXCEPTION
            WHEN TOO_MANY_ROWS THEN
               RETURN 152494;
         END;
      ELSE
         w_ctipdes := pctipdes;
      END IF;

      -- CPM 20/12/05: Grabem el capital introduit per pantalla (rescat parcial)
      -- RSC 27/03/2008: Si se informa el importe del rescate parcial se da valor a las variables ICAPRIS, IVALSIN y IPENALI
      -- Bug 11993 - 16/11/2009 - RSC - CRE - Ajustes PPJ Dinámico/Pla Estudiant
      -- Traslladedm aquesta operativa una mica més a dalt.
      /*
      IF picapital IS NOT NULL THEN
         w_error := graba_param(w_sesion, 'IVALSIN', picapital);
         w_ivalsin := picapital;

         IF w_error <> 0 THEN
            RETURN 109843;
         END IF;

         w_error := graba_param(w_sesion, 'ICAPRIS', picapital);
         w_icapris := picapital;

         IF w_error <> 0 THEN
            RETURN 109843;
         END IF;

         -- Bug 11771 - 04/11/2009 - RSC - CRE - Ajustes en simulación y contratación PPJ Dinámico/Pla Estudiant
         -- Comentamos este código --
         --w_error := graba_param(w_sesion, 'IPENALI', 0);
         --w_ipenali := 0;
         --IF w_error <> 0 THEN
         --   RETURN 109843;
         --END IF;
         -- Fin Bug 11771
      END IF;
      */
      IF NVL(f_parproductos_v(vsproduc, 'FISCALIDAD_2_CABEZAS'), 0) = 1
         AND pccausin IN(3, 4, 5) THEN   --JRH Sólo hay un pago
         xcuantos := 1;

         DECLARE   --JRH El parámetro IPRIMAS lo necesitamos informado
            primasaportadas NUMBER;
         BEGIN
            SELECT SUM(iprima)
              INTO primasaportadas
              FROM primas_aportadas
             WHERE sseguro = psseguro
               AND fvalmov <= pfsinies;

            primasaportadas := NVL(primasaportadas, 0);
            w_error := pac_sin_formula.f_graba_param(w_sesion, 'IPRIMAS', primasaportadas);
         END;
      ELSE
         xcuantos := pac_rescates.f_vivo_o_muerto(psseguro, 1, pfsinies);

         DECLARE   --JRH El parámetro IPRIMAS lo necesitamos informado
            xfmuerte       DATE;
            primasaportadas NUMBER;
         BEGIN
            SELECT MAX(ffecmue)
              INTO xfmuerte
              FROM asegurados
             WHERE asegurados.sseguro = psseguro
               AND asegurados.ffecmue IS NOT NULL;

            SELECT NVL(SUM(CASE
                              WHEN fvalmov > NVL(xfmuerte, fvalmov) THEN iprima
                              ELSE ROUND(iprima
                                         / pac_rescates.f_vivo_o_muerto(psseguro, 1, fvalmov),
                                         5)
                           END),
                       0)
              INTO primasaportadas
              FROM primas_aportadas
             WHERE sseguro = psseguro
               AND fvalmov <= pfsinies;

            w_error := graba_param(w_sesion, 'IPRIMAS', primasaportadas);
         END;
      END IF;

      FOR aseg IN cur_aseg LOOP
--dbms_output.put_line('bucle pagos por asegurado aseg *******************************='||aseg.norden);
--DBMS_OUTPUT.PUT_LINE('W_SESION ='||W_SESION);
      /*
       {calculamos el pago }
      */
         FOR reg IN cur_pago(w_ctipdes) LOOP
            w_error := graba_param(w_sesion, 'SPERDES', aseg.sperson);

            IF w_error <> 0 THEN
               RETURN 109843;
            END IF;

            BEGIN
               SELECT formula, codigo
                 INTO w_formula, w_codigo
                 FROM sgt_formulas
                WHERE clave = reg.clave;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  RETURN 108423;
               WHEN OTHERS THEN
                  RETURN 108423;
            END;

            -- Cargo parametros predefinidos
            FOR term IN cur_termino(reg.clave) LOOP
--dbms_output.put_line('term.parametro_pagos:'||term.parametro);
               IF term.parametro <> 'FVALORA' THEN
                  BEGIN
                     BEGIN
                        SELECT 'BEGIN SELECT ' || tcampo || ' INTO :RETORNO  FROM ' || ttable
                               || ' WHERE ' || twhere || ' ; END;'
                          INTO w_xs
                          FROM sgt_carga_arg_prede
                         WHERE termino = term.parametro
                           AND ttable IS NOT NULL
                           AND cllamada = 'PK_CALC_SINI';
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN   --JRH Ponemos el NDF como en la simulación
--DBMS_OUTPUT.PUT_LINE('Termino'||term.parametro);
                           SELECT 'BEGIN SELECT ' || tcampo || ' INTO :RETORNO  FROM '
                                  || ttable || ' WHERE ' || twhere || ' ; END;'
                             INTO w_xs
                             FROM sgt_carga_arg_prede
                            WHERE termino = term.parametro
                              AND ttable IS NOT NULL
                              AND cllamada = 'GENERICO';
                     END;

--dbms_output.put_line('Par:'||term.parametro);

                     -- RSC 07/07/2008 Mejora propuesta por Sa Nostra (Patch SNVA_249b) Bind Variables
                     IF DBMS_SQL.is_open(v_cursor) THEN
                        DBMS_SQL.close_cursor(v_cursor);
                     END IF;

                     v_cursor := DBMS_SQL.open_cursor;
                     DBMS_SQL.parse(v_cursor, w_xs, DBMS_SQL.native);
                     DBMS_SQL.bind_variable(v_cursor, ':RETORNO', w_retorno);

                     IF INSTR(w_xs, ':NSINIES') > 0 THEN
                        DBMS_SQL.bind_variable(v_cursor, ':NSINIES', w_nsinies);
                     END IF;

                     IF INSTR(w_xs, ':FECEFE') > 0 THEN
                        DBMS_SQL.bind_variable(v_cursor, ':FECEFE', w_fecefe);
                     END IF;

                     IF INSTR(w_xs, ':FNOTIFI') > 0 THEN
                        DBMS_SQL.bind_variable(v_cursor, ':FNOTIFI', w_fnotifi);
                     END IF;

                     IF INSTR(w_xs, ':FSINIES') > 0 THEN
                        DBMS_SQL.bind_variable(v_cursor, ':FSINIES', w_fsinies);
                     END IF;

                     IF INSTR(w_xs, ':SSEGURO') > 0 THEN
                        DBMS_SQL.bind_variable(v_cursor, ':SSEGURO', psseguro);
                     END IF;

                     IF INSTR(w_xs, ':SPRODUC') > 0 THEN
                        DBMS_SQL.bind_variable(v_cursor, ':SPRODUC', psproduc);
                     END IF;

                     IF INSTR(w_xs, ':CACTIVI') > 0 THEN
                        DBMS_SQL.bind_variable(v_cursor, ':CACTIVI', pcactivi);
                     END IF;

                     IF INSTR(w_xs, ':CGARANT') > 0 THEN
                        DBMS_SQL.bind_variable(v_cursor, ':CGARANT', pcgarant);
                     END IF;

                     IF INSTR(w_xs, ':NRIESGO') > 0 THEN
                        DBMS_SQL.bind_variable(v_cursor, ':NRIESGO', aseg.norden);
                     END IF;

                     IF INSTR(w_xs, ':SPERDES') > 0 THEN
                        DBMS_SQL.bind_variable(v_cursor, ':SPERDES', aseg.sperson);
                     END IF;

                     IF INSTR(w_xs, ':FECHA') > 0 THEN
                        DBMS_SQL.bind_variable(v_cursor, ':FECHA', w_fsinies);
                     END IF;

                     --JRH NDURPER Necesita NMOVIMI
                     DECLARE
                        nmovimi        NUMBER;
                     BEGIN
                        SELECT MAX(m.nmovimi)
                          INTO nmovimi
                          FROM movseguro m
                         WHERE m.sseguro = psseguro
                           AND TRUNC(m.fmovimi) <= TO_DATE(TO_CHAR(w_fsinies), 'yyyymmdd');

                        IF INSTR(w_xs, ':NMOVIMI') > 0 THEN
                           DBMS_SQL.bind_variable(v_cursor, ':NMOVIMI', nmovimi);
                        END IF;
                     EXCEPTION
                        WHEN OTHERS THEN
                           IF INSTR(w_xs, ':NMOVIMI') > 0 THEN
                              DBMS_SQL.bind_variable(v_cursor, ':NMOVIMI', '1');
                           END IF;
                     END;

                     BEGIN
                        v_filas := DBMS_SQL.EXECUTE(v_cursor);
                        DBMS_SQL.variable_value(v_cursor, 'RETORNO', w_retorno);

                        IF DBMS_SQL.is_open(v_cursor) THEN
                           DBMS_SQL.close_cursor(v_cursor);
                        END IF;

                        IF w_retorno IS NULL THEN
                           RETURN 103135;
                        ELSE
                           w_error := graba_param(w_sesion, term.parametro, w_retorno);

                           IF w_error <> 0 THEN
                              RETURN 109843;
                           END IF;
                        END IF;
                     EXCEPTION
                        WHEN OTHERS THEN
                           p_tab_error(f_sysdate, getuser, 'PK_CAL_SINI.f_simu_calc_sini',
                                       NULL, 'Error al evaluar la formula', SQLERRM);
                           p_tab_error(f_sysdate, getuser, 'PK_CAL_SINI.f_simu_calc_sini',
                                       NULL, 'formula', w_xs);
--dbms_output.put_line('Err12:'||sqlerrm);
                           w_error := graba_param(w_sesion, term.parametro, 0);

                           IF w_error <> 0 THEN
                              RETURN 109843;
                           END IF;
                     END;
                  EXCEPTION
                     WHEN OTHERS THEN
                        --dbms_output.put_line('Err22:'||sqlerrm);
                        w_xs := NULL;
                  END;
               END IF;
            END LOOP;

            --ADOS
            w_error := graba_param(w_sesion, 'IVALSIN', w_icapris - w_ipenali);
            w_error := graba_param(w_sesion, 'ICAPRIS', w_icapris);
            w_error := graba_param(w_sesion, 'IPENALI', w_ipenali);
            w_error := graba_param(w_sesion, 'NDESTI', xcuantos);
            w_error := graba_param(w_sesion, 'FVALORA', w_fsinies);
            w_error := graba_param(w_sesion, 'PASIGNA', 100 / xcuantos);
            w_error := graba_param(w_sesion, 'NRIESGO', aseg.norden);
                 /*   declare
                    xfmuerte DATE;
                    primasaportadas NUMBER;
                    BEGIN

                      SELECT max(ffecmue)
                      INTO xfmuerte
                      FROM asegurados
                      WHERE asegurados.sseguro = psseguro
                         AND asegurados.ffecmue IS NOT NULL;

                       SELECT nvl(SUM (case WHEN fvalmov > nvl(xfmuerte,fvalmov)THEN iprima else round(iprima/pac_rescates.f_vivo_o_muerto(psseguro,1,fvalmov),5) end),0)
                       INTO primasaportadas
                       FROM primas_aportadas
                       WHERE sseguro = psseguro
                        AND fvalmov <= pfsinies;

                       w_error :=   graba_param (w_sesion, 'IPRIMAS', primasaportadas);

                    END;
            */
            carga_preguntas(psseguro, pfsinies, pcgarant, w_sesion);
            --
            w_val := pk_formulas.eval(w_formula, w_sesion);

            --
            IF w_val IS NULL THEN
               --commit;
               p_tab_error(f_sysdate, f_user, 'pk_cal_sini.calc_pagos_sini', 1, w_sesion,
                           w_formula);
               RETURN 103135;
            ELSE
               IF reg.ccampo = 'IVALSIN' THEN
                  w_error := graba_param(w_sesion, 'IVALSIN', w_val);
                  w_ivalsin := w_val;

                  IF w_error <> 0 THEN
                     RETURN 109843;
                  END IF;
               END IF;

               IF reg.ccampo = 'ICAPRIS' THEN
                  w_error := graba_param(w_sesion, 'ICAPRIS', w_val);
                  w_icapris := w_val;

                  IF w_error <> 0 THEN
                     RETURN 109843;
                  END IF;
               END IF;

               IF reg.ccampo = 'IPENALI' THEN
                  w_error := graba_param(w_sesion, 'IPENALI', w_val);
                  w_ipenali := w_val;

                  IF w_error <> 0 THEN
                     RETURN 109843;
                  END IF;

                  IF w_ipenali > 0 THEN
                     w_ivalsin := w_ivalsin - w_ipenali;
                     w_error := graba_param(w_sesion, 'IVALSIN', w_ivalsin);

                     IF w_error <> 0 THEN
                        RETURN 109843;
                     END IF;
                  END IF;
               END IF;

               IF reg.ccampo = 'ISINRET' THEN
                  w_error := graba_param(w_sesion, 'ISINRET', w_val);
                  w_isinret := w_val;

                  IF w_error <> 0 THEN
                     RETURN 109843;
                  END IF;

                  w_sinacum := w_sinacum + w_val;
                  w_error := graba_param(w_sesion, 'ISINACU', w_sinacum);

                  IF w_error <> 0 THEN
                     RETURN 109843;
                  END IF;
               END IF;

               IF reg.ccampo = 'IRESRCM' THEN
                  w_error := graba_param(w_sesion, 'IRESRCM', w_val);
                  w_iresrcm := w_val;

                  IF w_error <> 0 THEN
                     RETURN 109843;
                  END IF;
               END IF;

               IF reg.ccampo = 'IRESRED' THEN
                  w_error := graba_param(w_sesion, 'IRESRED', w_val);
                  w_iresred := w_val;

                  IF w_error <> 0 THEN
                     RETURN 109843;
                  END IF;
               END IF;

               IF reg.ccampo = 'ICONRET' THEN
                  w_error := graba_param(w_sesion, 'ICONRET', w_val);
                  w_iconret := w_val;

                  IF w_error <> 0 THEN
                     RETURN 109843;
                  END IF;
               END IF;

               IF reg.ccampo = 'PRETENC' THEN
                  w_error := graba_param(w_sesion, 'PRETENC', w_val);
                  w_pretenc := w_val;

                  IF w_error <> 0 THEN
                     RETURN 109843;
                  END IF;
               END IF;

               IF reg.ccampo = 'IRETENC' THEN
                  w_error := graba_param(w_sesion, 'IRETENC', w_val);
                  w_iretenc := w_val;

                  IF w_error <> 0 THEN
                     RETURN 109843;
                  END IF;
               END IF;

               IF reg.ccampo = 'IIMPSIN' THEN
                  w_error := graba_param(w_sesion, 'IIMPSIN', w_val);
                  w_iimpsin := w_val;

                  IF w_error <> 0 THEN
                     RETURN 109843;
                  END IF;
               END IF;

               IF reg.ccampo = 'IPRIMAS' THEN
                  w_error := graba_param(w_sesion, 'IPRIMAS', w_val);
                  w_iprimas := w_val;

                  IF w_error <> 0 THEN
                     RETURN 109843;
                  END IF;
               END IF;
            END IF;
         END LOOP;

         --dbms_output.put_line('w_isinret ***************************='||w_isinret);
         --dbms_output.put_line('w_iresrcm ***************************='||w_iresrcm);
         --dbms_output.put_line('w_iretenc ***************************='||w_iretenc);
         w_isinret_total := w_isinret_total + w_isinret;
         w_iresrcm_total := w_iresrcm_total + w_iresrcm;
         w_iresred_total := w_iresred_total + w_iresred;
         w_iconret_total := w_iconret_total + w_iconret;
         w_iretenc_total := w_iretenc_total + w_iretenc;
         w_iimpsin_total := w_iimpsin_total + w_iimpsin;
         w_iprimas_total := w_iprimas_total + w_iprimas;
      -- SINGARANFORMULA
      END LOOP;

      --
      w_error := insertar_mensajes(2, psseguro, NULL, pctipdes,
                                   TO_NUMBER(TO_CHAR(pfsinies, 'yyyymmdd')), pcactivi,
                                   pcgarant, w_ivalsin, w_isinret_total, w_iresrcm_total,
                                   w_iresred_total, w_iconret_total, w_pretenc,
                                   w_iretenc_total, w_iimpsin_total, w_icapris, w_ipenali,
                                   w_iprimas_total, NULL, NULL);
-- i - jlb -- OPTIMI
--      DELETE      sgt_parms_transitorios
--            WHERE sesion = w_sesion
--              AND parametro IN('ISINRET', 'IRESRCM', 'IRESRED', 'ICONRET', 'PRETENC',
--                               'PRETENC', 'IRETENC', 'IIMPSIN');
-- f - jlb -- OPTIMI
      -- Borro sgt_parms_transitorios
      w_error := borra_param(w_sesion);

      --
      IF w_error <> 0 THEN
         RETURN w_error;
      END IF;

      RETURN 0;
   END f_simu_calc_sini;

   FUNCTION f_imaximo_rescatep(
      psseguro IN NUMBER,
      pfsinies IN DATE,
      pccausin IN NUMBER,
      pimporte OUT NUMBER)
      RETURN NUMBER IS
      xxformula      VARCHAR2(2000);
      xxsesion       NUMBER;
      w_error        NUMBER;
      val            NUMBER;
      v_sproduc      NUMBER;
      nanyos         NUMBER;
      v_fefecto      DATE;
      v_frevant      DATE;
      v_fecha        DATE;
      vclave         NUMBER;
      v_ctipmov      NUMBER;
   BEGIN
      IF pccausin = 4 THEN   -- rescate total
         v_ctipmov := 3;
      ELSIF pccausin = 5 THEN   -- rescate parcial
         v_ctipmov := 2;
      END IF;

      -- Bug 13296 - RSC - 22/02/2010 - CEM - Revisión módulo de rescates

      -- RSC 12/12/2007 (añado la left join con seguros_aho)
      --SELECT s.sproduc, s.fefecto, NVL(sa.frevant, s.fefecto)
      --INTO v_sproduc, v_fefecto, v_frevant
      --FROM seguros s LEFT JOIN seguros_aho sa ON(s.sseguro = sa.sseguro)
      --WHERE s.sseguro = psseguro;
      --
      --IF NVL(f_parproductos_v(v_sproduc, 'EVOLUPROVMATSEG'), 0) = 1 THEN
      --   v_fecha := v_frevant;
      --ELSE
      --   v_fecha := v_fefecto;
      --END IF;

      --nanyos := TRUNC(MONTHS_BETWEEN(pfsinies, v_fecha) / 12);
      nanyos := calc_rescates.f_get_anyos_porcenpenali(psseguro,
                                                       TO_NUMBER(TO_CHAR(pfsinies, 'yyyymmdd')),
                                                       v_ctipmov);

      -- Fin Bug 13296
      BEGIN
         SELECT d.claveimaximo
           INTO vclave
           FROM prodtraresc p, seguros s, detprodtraresc d
          WHERE s.sseguro = psseguro
            AND s.sproduc = p.sproduc
            AND p.sidresc = d.sidresc
            AND p.ctipmov = v_ctipmov
            AND p.finicio <= pfsinies
            AND(p.ffin > pfsinies
                OR p.ffin IS NULL)
            AND d.niniran = (SELECT MIN(dp.niniran)
                               FROM detprodtraresc dp
                              WHERE dp.sidresc = d.sidresc
                                AND nanyos BETWEEN dp.niniran AND dp.nfinran);
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 180809;
      END;

      SELECT sgt_sesiones.NEXTVAL
        INTO xxsesion
        FROM DUAL;

      w_error := graba_param(xxsesion, 'SESION', xxsesion);

      IF w_error <> 0 THEN
         RETURN 109843;
      END IF;

      w_error := graba_param(xxsesion, 'FSINIES', TO_NUMBER(TO_CHAR(pfsinies, 'yyyymmdd')));

      IF w_error <> 0 THEN
         RETURN 109843;
      END IF;

      w_error := graba_param(xxsesion, 'SSEGURO', psseguro);

      IF w_error <> 0 THEN
         RETURN 109843;
      END IF;

      BEGIN
         SELECT formula
           INTO xxformula
           FROM sgt_formulas
          WHERE clave = vclave;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 108423;
      END;

      -- Evaluamos la fórmula
      pimporte := pk_formulas.eval(xxformula, xxsesion);

      IF (pimporte IS NULL
          OR pimporte < 0) THEN
         RETURN 180809;
      END IF;

      -- Borro sgt_parms_transitorios
      w_error := borra_param(xxsesion);

      IF w_error <> 0 THEN
         RETURN w_error;
      END IF;

      RETURN 0;
   END f_imaximo_rescatep;
END pk_cal_sini;

/

  GRANT EXECUTE ON "AXIS"."PK_CAL_SINI" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PK_CAL_SINI" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PK_CAL_SINI" TO "PROGRAMADORESCSI";
