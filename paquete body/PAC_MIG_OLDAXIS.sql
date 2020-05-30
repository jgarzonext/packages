--------------------------------------------------------
--  DDL for Package Body PAC_MIG_OLDAXIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MIG_OLDAXIS" IS
/******************************************************************************
   NOMBRE:    PAC_MIG_OLDAXIS
   PROPÓSITO: Funciones y procedimientos para migrar los datos proporcionados
              por OLDAXIS (cliente CRE) a las tablas de migración MIG_

   REVISIONES:
   Ver        Fecha       Autor          Descripción
   ---------  ----------  -------------  -------------------------------------
   1.0        01/09/2010  AFM            1.Creación del Package (inicialmente migración solo del módulo
                                           de siniestros: de SINIESTROS...a SIN_SINIESTROS)
******************************************************************************/

   -- Constants diverses
   k_separador CONSTANT VARCHAR2(1) := '|';   --CRE
   k_cempresa CONSTANT seguros.cempres%TYPE := 1;   --CRE
   k_unitramit CONSTANT VARCHAR2(5) := 'U000';   --CRE
   k_usutramit CONSTANT VARCHAR2(5) := 'T000';   --CRE

   -- INI BUG:13370 - 11-05-2010 - JMC - Creación función f_crea_pk
   /***************************************************************************
      FUNCTION f_crea_pk
      Dados unos campos de entrada, concatena estos con un K_SEPARADOR entre ellos.
      Se utiliza para generar una pk ficticias que se graban en mig_pk_emp_axis.
      param in p_campo1 : primer valor a concatenar.
      param in p_campo2 : segundo valor a concatenar.
      param in p_campo3 : tercer valor a concatenar.
      param in p_campo4 : cuarto valor a concatenar.
      param in p_campo5 : quinto valor a concatenar.
      param in p_campo6 : sexto valor a concatenar.
      param in p_campo7 : séptimo valor a concatenar.
      return             : 0 si valido, sino codigo error
   ***************************************************************************/
   FUNCTION f_crea_pk(
      p_campo1 IN VARCHAR2,
      p_campo2 IN VARCHAR2 DEFAULT NULL,
      p_campo3 IN VARCHAR2 DEFAULT NULL,
      p_campo4 IN VARCHAR2 DEFAULT NULL,
      p_campo5 IN VARCHAR2 DEFAULT NULL,
      p_campo6 IN VARCHAR2 DEFAULT NULL,
      p_campo7 IN VARCHAR2 DEFAULT NULL)
      RETURN mig_pk_emp_mig.pkemp%TYPE DETERMINISTIC IS
      v_pk           mig_pk_emp_mig.pkemp%TYPE;
   BEGIN
      v_pk := p_campo1;

      IF p_campo2 IS NOT NULL THEN
         v_pk := v_pk || k_separador || p_campo2;

         IF p_campo3 IS NOT NULL THEN
            v_pk := v_pk || k_separador || p_campo3;

            IF p_campo4 IS NOT NULL THEN
               v_pk := v_pk || k_separador || p_campo4;

               IF p_campo5 IS NOT NULL THEN
                  v_pk := v_pk || k_separador || p_campo5;
               END IF;
            END IF;
         END IF;
      END IF;

      IF p_campo6 IS NOT NULL THEN
         v_pk := v_pk || k_separador || p_campo6;
      END IF;

      IF p_campo7 IS NOT NULL THEN
         v_pk := v_pk || k_separador || p_campo7;
      END IF;

      RETURN v_pk;
   END f_crea_pk;

   -- FIN BUG:13370 - 11-05-2010 - JMC
   /***************************************************************************
      FUNCTION f_codigo_axis
      Dado un valor de un código de la empresa, nos devuelve el valor del
      código en AXIS
         param in pccodigo : Código a traducir.
         param in pcvalemp : Valor a traducir.
         return              : Valor traducido valido para AXIS
   ***************************************************************************/

   /*
       ESTA FUNCION NO ES NECESARIA: COMO YA ES AXIS LOS CODIGOS SON LOS MISMOS!!!!

      FUNCTION f_codigo_axis(pccodigo IN VARCHAR2, pcvalemp IN VARCHAR2)
         RETURN mig_codigos_emp.cvalaxis%TYPE IS
         v_cempres      mig_codigos_emp.cvalaxis%TYPE := k_cempres;   -- **** De moment sempre és 2
      BEGIN
         FOR r IN (SELECT cvalaxis
                     FROM mig_codigos_emp
                    WHERE ccodigo = pccodigo
                      AND cempres = v_cempres
                      AND((cvalemp = pcvalemp
                           AND pcvalemp IS NOT NULL)
                          OR(pcvalemp IS NULL
                             AND cvalemp = 'NULL'))) LOOP
            RETURN r.cvalaxis;
         END LOOP;

         raise_application_error(-20000,
                                 'Conversió de ' || pccodigo || ' ' || pcvalemp || ' no trobat.');
         RETURN NULL;   -- Aquest codi no s'executa mai
      END f_codigo_axis;
   */
      /***************************************************************************
         FUNCTION f_next_carga
         Asigna número de carga
            return         : Número de carga
      ***************************************************************************/
   FUNCTION f_next_carga
      RETURN NUMBER IS
      v_seq          NUMBER;
   BEGIN
      SELECT sncarga.NEXTVAL
        INTO v_seq
        FROM DUAL;

      RETURN v_seq;
   END f_next_carga;

   /***************************************************************************
      FUNCTION f_init_carga
      Insereix el registres d'inici de càrrega
         param in pid       : Identificador migración
         param in p_tab_org : taula origen
         param in p_tab_des : taula destí
         return             : el número de càrrega
                              (Excepció en cas d'error)
   ***************************************************************************/
   FUNCTION f_init_carga(
      pid IN mig_cargas.ID%TYPE DEFAULT NULL,   --BUG:12243 - 02-12-2009 - JMC - Se añade parametro pid
      p_tab_org IN mig_cargas_tab_mig.tab_org%TYPE,
      p_tab_des1 IN mig_cargas_tab_mig.tab_des%TYPE,
      p_tab_des2 IN mig_cargas_tab_mig.tab_des%TYPE DEFAULT NULL,
      p_tab_des3 IN mig_cargas_tab_mig.tab_des%TYPE DEFAULT NULL)
      RETURN mig_cargas.ncarga%TYPE IS
      PRAGMA AUTONOMOUS_TRANSACTION;
      v_ncarga       mig_cargas.ncarga%TYPE;
   BEGIN
      --Inicializamos la cabecera de la carga
      v_ncarga := f_next_carga;

      -- BUG 12243 - 02-12-2009 - JMC - Se añade parámetro pid
      INSERT INTO mig_cargas
                  (ncarga, cempres, finiorg, ffinorg, ID)
           VALUES (v_ncarga, TO_CHAR(k_cempresa), f_sysdate, NULL, pid);

      -- FIN BUG 12243 - 02-12-2009 - JMC
      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, p_tab_org, p_tab_des1, 1);

      IF p_tab_des2 IS NOT NULL THEN
         INSERT INTO mig_cargas_tab_mig
                     (ncarga, tab_org, tab_des, ntab)
              VALUES (v_ncarga, p_tab_org, p_tab_des2, 2);
      END IF;

      IF p_tab_des3 IS NOT NULL THEN
         INSERT INTO mig_cargas_tab_mig
                     (ncarga, tab_org, tab_des, ntab)
              VALUES (v_ncarga, p_tab_org, p_tab_des3, 3);
      END IF;

      COMMIT;
      RETURN v_ncarga;
   END;

   /***************************************************************************
      FUNCTION f_ins_mig_logs_emp
      Inserta registro en la tabla de logs de las cargas de las tablas CEM a
      tablas MIG
         param in pncarga : número de carga
         param in pmig_pk : valor primary key del registro de CEM
         param in ptipo   : tipo log (E=error, I=Información, W-Warning)
         param in ptexto  : Texto log
         return           : código error
   ***************************************************************************/
   FUNCTION f_ins_mig_logs_emp(
      pncarga IN NUMBER,
      pmig_pk IN VARCHAR2,
      ptipo IN VARCHAR2,
      ptexto IN VARCHAR2)
      RETURN NUMBER IS
      PRAGMA AUTONOMOUS_TRANSACTION;
      v_seq          NUMBER;
   BEGIN
      INSERT INTO mig_logs_emp
                  (ncarga, seqlog, fecha, mig_pk, tipo,
                   incid)
           VALUES (pncarga, sseqlogmig.NEXTVAL, f_sysdate, pmig_pk, ptipo,
                   SUBSTR(ptexto, 1, 500));

      COMMIT;
      RETURN 0;
--   EXCEPTION
--      WHEN OTHERS THEN
--         RETURN SQLCODE;
   END f_ins_mig_logs_emp;

   /***************************************************************************
      FUNCTION f_migra_beneficiarios
         param in pproducte : Código producto CEM a migrar.
         param in pid       : Identificador migración
         return            : 0 si valido, sino codigo error
   ***************************************************************************/

   /* grabar en MIG_SIN_TRAMITA_DEST (tabla NUEVA a crear) */

   /*
      FUNCTION f_migra_beneficiarios(
         pproducte IN VARCHAR2 DEFAULT NULL,
         pid IN VARCHAR2 DEFAULT NULL   --BUG:12243 - 02-12-2009 - JMC - Se añade parametro pid
                                     )
         RETURN NUMBER IS
         v_mig_benef    mig_clausuesp%ROWTYPE;
         v_ncarga       NUMBER;
         v_num_err      NUMBER;
         v_error        BOOLEAN := FALSE;
         v_warning      BOOLEAN := FALSE;
         v_estorg       mig_cargas.estorg%TYPE;
         v_ultim_suplenum NUMBER;
         v_pk           mig_seguros.mig_pk%TYPE;
      BEGIN

       FOR x IN
            (SELECT   a.*, s.nmovimi, s.fefecto, s.mig_pk pk_movseguro,
                      LEAD(beneftex, 1) OVER(PARTITION BY ramopcod, polizann, certipol, certisec, suplenum ORDER BY benefsec)
                                                                                      beneftex_1,
                      LEAD(beneftex, 2) OVER(PARTITION BY ramopcod, polizann, certipol, certisec, suplenum ORDER BY benefsec)
                                                                                      beneftex_2,
                      LEAD(beneftex, 3) OVER(PARTITION BY ramopcod, polizann, certipol, certisec, suplenum ORDER BY benefsec)
                                                                                      beneftex_3,
                      MIN(benefsec) OVER(PARTITION BY ramopcod, polizann, certipol, certisec, suplenum)
                                                                                    min_benefsec
                 FROM cem_beneficiarios DUAL a JOIN mig_movseguro s
                      ON s.mig_fk = f_muntarsegpk --(a.ramopcod, a.polizann, a.certipol, a.certisec)
                WHERE NOT EXISTS(SELECT '*'
                                   FROM mig_pk_emp_mig
                                  WHERE pkemp = f_crea_pk(a.ramopcod, a.polizann, a.certipol,
                                                          a.certisec, s.nmovimi, a.benefsec))
                  AND certisec <> 0
                  AND(ramopcod = pproducte
                      OR pproducte IS NULL)
                  AND suplenum = (SELECT MAX(b.suplenum)
                                    FROM cem_beneficiarios b
                                   WHERE b.ramopcod = a.ramopcod
                                     AND b.polizann = a.polizann
                                     AND b.certipol = a.certipol
                                     AND b.certisec = a.certisec)
                  AND s.nmovimi = (SELECT MAX(s2.nmovimi)
                                     FROM mig_movseguro s2
                                    WHERE s2.mig_fk =
                                             a.ramopcod || ':' || LPAD(a.polizann, 2, '0') || ':'
                                             || LPAD(a.certipol, 4, '0') || ':'
                                             || LPAD(a.certisec, 6, '0')
                                      AND cmotmov IN(100, 404))
            ORDER BY a.ramopcod, a.polizann, a.certipol, a.certisec, a.suplenum, a.benefsec) LOOP
            -- Només un beneficiari per pòlissa
            IF x.min_benefsec = x.benefsec THEN
               IF v_ncarga IS NULL THEN
                  v_ncarga := f_init_carga(pid, 'CEM_BENEFICIARIOS', 'MIG_CLAUSUESP');
               END IF;

               BEGIN
                  v_pk := f_muntarsegpk(x.ramopcod, x.polizann, x.certipol, x.certisec,
                                        x.suplenum);
                  v_pk := v_pk || ':' || LPAD(x.nmovimi, 4, '0');
                  SAVEPOINT svp;
                  v_mig_benef := NULL;
                  v_mig_benef.ncarga := v_ncarga;
                  v_mig_benef.cestmig := 1;
                  v_mig_benef.mig_pk := v_pk || ':' || LPAD(x.benefsec, 2, '0');
                  --v_mig_benef.mig_fk := v_pk;   -- MIG_MOVSEGURO
                  v_mig_benef.mig_fk := x.pk_movseguro;
                  v_mig_benef.sseguro := 0;
                  v_mig_benef.cclaesp := 1;
                  v_mig_benef.nordcla := 1;
                  v_mig_benef.nriesgo := 1;
                  v_mig_benef.nmovimi := x.nmovimi;
                  v_mig_benef.finiclau := x.fefecto;

                  BEGIN
                     v_mig_benef.sclagen := CASE
                                              WHEN x.textbcod = '001' THEN 56   --14
                                              ELSE NULL
                                           END;
                     v_mig_benef.tclaesp :=
                        CASE
                           WHEN x.textbcod = '000' THEN x.beneftex
                                                        || CASE
                                                           WHEN x.beneftex_1 IS NOT NULL THEN CHR
                                                                                                 (10)
                                                                                              || x.beneftex_1
                                                           ELSE NULL
                                                        END
                                                        || CASE
                                                           WHEN x.beneftex_2 IS NOT NULL THEN CHR
                                                                                                 (10)
                                                                                              || x.beneftex_2
                                                           ELSE NULL
                                                        END
                                                        || CASE
                                                           WHEN x.beneftex_3 IS NOT NULL THEN CHR
                                                                                                 (10)
                                                                                              || x.beneftex_3
                                                           ELSE NULL
                                                        END
                           ELSE NULL
                        END;

                     IF v_mig_benef.sclagen IS NOT NULL
                        OR TRIM(REPLACE(v_mig_benef.tclaesp, CHR(10), '')) IS NOT NULL THEN
                        INSERT INTO mig_clausuesp
                             VALUES v_mig_benef;

                        INSERT INTO mig_pk_emp_mig
                             VALUES (f_crea_pk(x.ramopcod, x.polizann, x.certipol, x.certisec,
                                               x.nmovimi, x.benefsec),
                                     v_ncarga, 1, v_mig_benef.mig_pk);
                     END IF;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        NULL;   -- En cas que no trobem el moviment és perquè és un dels que intencionadament no hem gravat
                  END;
               EXCEPTION
                  WHEN OTHERS THEN
                     v_num_err := f_ins_mig_logs_emp(v_ncarga, v_mig_benef.mig_pk, 'E',
                                                     SQLERRM || CHR(10)
                                                     || DBMS_UTILITY.format_error_backtrace);
                     v_error := TRUE;
                     ROLLBACK TO svp;
               END;
            END IF;
         END LOOP;



         -- Carga de la clausula por defecto en el caso de no tener ninguna.
         FOR x IN (SELECT a.*, a.ROWID xrowid
                     FROM mig_movseguro a
                    WHERE (mig_pk LIKE pproducte || '%'
                           OR pproducte IS NULL)
                      AND cestmig > 1
                      AND nmovimi = (SELECT MAX(nmovimi)
                                       FROM mig_movseguro b, codimotmov c
                                      WHERE c.cmotmov = b.cmotmov
                                        AND cmovseg <> 3
                                        AND b.mig_fk = a.mig_fk)
                      AND NOT EXISTS(SELECT '*'
                                       FROM mig_clausuesp
                                      WHERE ncarga = v_ncarga
                                        AND mig_fk = a.mig_pk)) LOOP
            BEGIN
               v_mig_benef := NULL;
               v_mig_benef.ncarga := v_ncarga;
               v_mig_benef.cestmig := 1;
               v_mig_benef.mig_pk := x.mig_pk;
               --v_mig_benef.mig_fk := v_pk;   -- MIG_MOVSEGURO
               v_mig_benef.mig_fk := x.mig_pk;
               v_mig_benef.sseguro := 0;
               v_mig_benef.cclaesp := 1;
               v_mig_benef.nordcla := 1;
               v_mig_benef.nriesgo := 1;
               v_mig_benef.nmovimi := x.nmovimi;
               v_mig_benef.finiclau := x.fefecto;
               v_mig_benef.sclagen := 56;

               INSERT INTO mig_clausuesp
                    VALUES v_mig_benef;

               INSERT INTO mig_pk_emp_mig
                    VALUES (v_mig_benef.mig_pk, v_ncarga, 1, v_mig_benef.mig_pk);
            EXCEPTION
               WHEN OTHERS THEN
                  v_num_err := f_ins_mig_logs_emp(v_ncarga, v_mig_benef.mig_pk, 'E',
                                                  '*' || SQLERRM || CHR(10)
                                                  || DBMS_UTILITY.format_error_backtrace);
                  v_error := TRUE;
                  ROLLBACK TO svp;
            END;
         END LOOP;

         v_estorg := CASE
                       WHEN v_error THEN 'ERROR'
                       WHEN v_warning THEN 'WARNING'
                       ELSE 'OK'
                    END;

         UPDATE mig_cargas
            SET ffinorg = f_sysdate,
                estorg = v_estorg
          WHERE ncarga = v_ncarga;

         COMMIT;
         RETURN CASE
            WHEN v_error THEN 99
            ELSE 0
         END;
      END;
   */
       -- INI BUG:12374 - 20-09-2010 - AFM - Función para migrar nuevo modelo siniestros y prestamoseg
      /***************************************************************************
         FUNCTION f_migra_sin_siniestros
            param in pproducte : Código producto CEM a migrar.
            param in pid       : Identificador migración
            return            : 0 si valido, sino codigo error
      ***************************************************************************/
   FUNCTION f_migra_sin_siniestros(
      pid IN VARCHAR2 DEFAULT NULL,
      p_numrows IN NUMBER DEFAULT NULL,
      p_txt_error OUT VARCHAR2)
      RETURN NUMBER IS
      num_err        NUMBER;
      v_ncarga       NUMBER := NULL;
      v_mig_siniestros mig_sin_siniestro%ROWTYPE;
      v_mig_movsin   mig_sin_movsiniestro%ROWTYPE;
      v_ncarga_movsin NUMBER;
      v_ultmovsin    NUMBER;
      --En el NUEVO MODELO DE SINIESTROS a partir de aquí todo va x TRAMITACION
      v_mig_tramit   mig_sin_tramitacion%ROWTYPE;
      v_ncarga_tramit NUMBER;
      v_mig_tramit_mov mig_sin_tramita_movimiento%ROWTYPE;
      v_ncarga_tramit_mov NUMBER;
      v_mig_tramit_age mig_sin_tramita_agenda%ROWTYPE;
      v_ncarga_tramit_age NUMBER;
      v_mig_tramit_res mig_sin_tramita_reserva%ROWTYPE;
      v_ncarga_tramit_res NUMBER;
      v_nmov_res     NUMBER := 0;
      v_imp_total_res NUMBER := 0;
      v_mig_tramit_pago mig_sin_tramita_pago%ROWTYPE;
      v_ncarga_tramit_pago NUMBER;
      v_mig_tramit_movpago mig_sin_tramita_movpago%ROWTYPE;
      v_ncarga_tramit_movpago NUMBER;
      v_mig_tramit_pago_g mig_sin_tramita_pago_gar%ROWTYPE;
      v_ncarga_tramit_pago_g NUMBER;
      v_nmov_pago_g  NUMBER := 0;
      v_norden       NUMBER := 0;
      v_mig_tramit_dest mig_sin_tramita_dest%ROWTYPE;
      v_ncarga_tramit_dest NUMBER;
      v_nmov_pago    NUMBER := 0;
      v_imp_aux      NUMBER := 0;
      v_cgarant      NUMBER := 0;
      v_error        BOOLEAN := FALSE;
      v_warning      BOOLEAN := FALSE;
      v_estorg       mig_cargas.estorg%TYPE;
      v_no_carga_resto NUMBER := 0;
      v_aux          VARCHAR2(400);
   BEGIN
      /***************** INI MIG_SIN_SINIESTRO ************************/
      FOR s IN (SELECT   a.*
                    FROM siniestros a
                   WHERE NOT EXISTS(SELECT 1   --No volver a migrar los siniestros migrados
                                      FROM mig_pk_emp_mig
                                     WHERE pkemp = f_crea_pk(a.nsinies))
                     AND EXISTS(SELECT cempres
                                  FROM seguros
                                 WHERE cempres = k_cempresa
                                   AND sseguro = a.sseguro)
                     AND(p_numrows IS NULL
                         OR(p_numrows IS NOT NULL
                            AND ROWNUM <= p_numrows))
                     AND EXISTS(SELECT 1
                                  FROM codiram
                                 WHERE cempres = 1
                                   AND cramo = a.cramo)
                --and a.cramo = 31
                --and a.nsinies in (23000899,23000887,23000894,23001043)
                ORDER BY a.nsinies) LOOP
         v_no_carga_resto := 0;
         DBMS_OUTPUT.put_line('Numero SINIESTRO-->' || s.nsinies);

         BEGIN
            IF v_ncarga IS NULL THEN
               v_ncarga := f_init_carga(pid, 'SINIESTROS', 'MIG_SIN_SINIESTRO');
            END IF;

            DBMS_OUTPUT.put_line('MIG_SIN_SINIESTRO-->ncarga:' || v_ncarga);
            v_mig_siniestros := NULL;
            v_mig_siniestros.ncarga := v_ncarga;
            v_mig_siniestros.cestmig := 1;
            v_mig_siniestros.mig_pk := f_crea_pk(s.nsinies);
            DBMS_OUTPUT.put_line('-->pk:' || v_mig_siniestros.mig_pk);
            v_mig_siniestros.mig_fk := f_crea_pk(s.sseguro);
            v_mig_siniestros.nsinies := s.nsinies;
            v_mig_siniestros.sseguro := s.sseguro;
            v_mig_siniestros.nriesgo := s.nriesgo;
            v_mig_siniestros.nmovimi := NVL(s.nmovimi, 0);   --Si 0 lo calculará PAC_MIG_AXIS
            v_mig_siniestros.fsinies := s.fsinies;
            v_mig_siniestros.fnotifi := s.fnotifi;
            v_mig_siniestros.ccausin := s.ccausin;

            --Transformamos el cmotsin viejo al nuevo cmotsin del nuevo modelo (solo CRE)
            IF s.cramo IN(23, 24)
               AND s.cmotsin = 2
               AND s.ccausin = 1 THEN
               v_mig_siniestros.cmotsin := 8;   --( de 2 a 8 Cirugia )
            ELSIF s.cramo = 2
                  AND s.cmotsin = 6
                  AND s.ccausin = 1 THEN
               v_mig_siniestros.cmotsin := 5;   --( de  6 a 5 Malaltía)
            ELSE
               v_mig_siniestros.cmotsin := s.cmotsin;
            END IF;

            v_mig_siniestros.cculpab := s.cculpab;   --VF_801
            v_mig_siniestros.nasegur := s.nasegur;   --producto 2 cabezas???
            v_mig_siniestros.tsinies := s.tsinies;
            v_mig_siniestros.cusualt := s.cusualt;
            v_mig_siniestros.falta := s.falta;
            v_mig_siniestros.cusumod := s.cusumod;
            v_mig_siniestros.fmodifi := s.fmodifi;
            v_mig_siniestros.ncuacoa := s.ncuacoa;
            v_mig_siniestros.nsincoa := s.nsincoa;
            v_mig_siniestros.cevento := NULL;   --No hay eventos en VIDA
            v_mig_siniestros.creclama := NULL;   --x.creclama VF_318 OJO;
            v_mig_siniestros.cmeddec := NULL;   --x.cmeddec  VF_319 OJO;
            v_mig_siniestros.ctipdec := NULL;   --x.ctipdec VF_321 OJO;
            v_mig_siniestros.tnomdec := NULL;   --x.tnomdec OJO;
            v_mig_siniestros.tape1dec := NULL;   --x.tape1dec OJO;
            v_mig_siniestros.tape2dec := NULL;   --x.tape2dec OJO;
            v_mig_siniestros.tteldec := NULL;   --x.tteldec  OJO;

--Campos nuevos de SIN_SINIESTRO:
--  DEC_SPERSON
--  CTIPIDE
--  NNUMIDE
--  CNIVEL
--  SPERSON2
            INSERT INTO mig_sin_siniestro
                 VALUES v_mig_siniestros;

            INSERT INTO mig_pk_emp_mig
                 VALUES (v_mig_siniestros.mig_pk, v_ncarga, 1, v_mig_siniestros.mig_pk);
         EXCEPTION
            WHEN OTHERS THEN
               p_txt_error := SQLERRM;
               v_no_carga_resto := ABS(SQLCODE);
               num_err := f_ins_mig_logs_emp(v_ncarga, v_mig_siniestros.mig_pk, 'E',
                                             SQLERRM || CHR(10)
                                             || DBMS_UTILITY.format_error_backtrace);
               v_error := TRUE;
               ROLLBACK;
         END;

         /***************** FIN MIG_SIN_SINIESTRO ************************/
         IF v_no_carga_resto <> 0 THEN
            RETURN v_no_carga_resto;
         END IF;

          /************************ INI MIG_SIN_MOVSINIESTRO *****************************/
         -- IF v_no_carga_resto = 0 THEN

         --PUEDEN HABER <> MOVIMIENTOS DE SINIESTRO O SOLO 1 PARA VIDA???????

         --contamos los movimientos del siniestro
         SELECT COUNT(1)
           INTO v_ultmovsin
           FROM movsiniestro a
          WHERE a.nsinies = s.nsinies;

         --NOTA: En esta tabla hay un campo NTRAMIT, pero no se usa
         FOR ms IN (SELECT   a.*
                        FROM movsiniestro a
                       WHERE a.nsinies = s.nsinies
                    ORDER BY a.nmovimi) LOOP
            BEGIN
               IF v_ncarga_movsin IS NULL THEN
                  v_ncarga_movsin := f_init_carga(pid, 'MOVSINIESTRO', 'MIG_SIN_MOVSINIESTRO');
               END IF;

               DBMS_OUTPUT.put_line('MIG_SIN_MOVSINIESTRO-->ncarga_movsin:' || v_ncarga_movsin);
               v_mig_movsin := NULL;
               v_mig_movsin.ncarga := v_ncarga_movsin;
               v_mig_movsin.cestmig := 1;
               v_mig_movsin.mig_pk := f_crea_pk(ms.nsinies, ms.nmovimi - 1);   --en el nuevo modelo los mov. empiezan por 0
               DBMS_OUTPUT.put_line('-->pk:' || v_mig_movsin.mig_pk);
               v_mig_movsin.mig_fk := f_crea_pk(ms.nsinies);
               v_mig_movsin.nsinies := ms.nsinies;
               v_mig_movsin.nmovsin := ms.nmovimi - 1;
               v_mig_movsin.cestsin := ms.cestado;   -- VF_6
               v_mig_movsin.festsin := ms.fmovimi;

               SELECT DECODE(ms.nmovimi,
                             v_ultmovsin, s.ccauest,
                             NULL)   --informar el scauest del siniestro
                 INTO v_mig_movsin.ccauest
                 FROM DUAL;   --solo en el ultimo movimiento

               v_mig_movsin.cunitra := k_unitramit;   -- unidad tramitación OJO
               v_mig_movsin.ctramitad := k_usutramit;   --codigo " OJO
               v_mig_movsin.cusualt := ms.cusumov;
               v_mig_movsin.falta := ms.fmovimi;

               INSERT INTO mig_sin_movsiniestro
                    VALUES v_mig_movsin;

               INSERT INTO mig_pk_emp_mig
                    VALUES (f_crea_pk(ms.nsinies, ms.nmovimi), v_ncarga_movsin, 1,
                            v_mig_movsin.mig_pk);
            EXCEPTION
               WHEN OTHERS THEN
                  p_txt_error := SQLERRM;
                  v_no_carga_resto := ABS(SQLCODE);
                  num_err := f_ins_mig_logs_emp(v_ncarga_movsin, v_mig_movsin.mig_pk, 'E',
                                                SQLERRM || CHR(10)
                                                || DBMS_UTILITY.format_error_backtrace);
                  v_error := TRUE;
                  ROLLBACK;
            END;
         END LOOP;

         --END IF;

         /************************ FIN MIG_SIN_MOVSINIESTRO *****************************/
         IF v_no_carga_resto <> 0 THEN
            RETURN v_no_carga_resto;
         END IF;

         /************************ INI MIG_SIN_TRAMITACION *****************************/

         --PARA PRODUCTOS DE VIDA SOLO EXISTE LA TRAMITACION GLOBAL (valor 0)
         FOR ts IN (SELECT   a.*
                        FROM tramitacionsini a
                       WHERE a.nsinies = s.nsinies
                    ORDER BY a.ntramit) LOOP
            BEGIN
               IF v_ncarga_tramit IS NULL THEN
                  v_ncarga_tramit := f_init_carga(pid, 'TRAMITACIONSINI',
                                                  'MIG_SIN_TRAMITACION');
               END IF;

               DBMS_OUTPUT.put_line('MIG_SIN_TRAMITACION-->ncarga_tramit:' || v_ncarga_tramit);
               v_mig_tramit := NULL;
               v_mig_tramit.ncarga := v_ncarga_tramit;
               v_mig_tramit.cestmig := 1;
               v_mig_tramit.mig_pk := f_crea_pk(ts.nsinies, ts.ntramit);
               DBMS_OUTPUT.put_line('-->pk:' || v_mig_tramit.mig_pk);
               v_mig_tramit.mig_fk := f_crea_pk(ts.nsinies);
               v_mig_tramit.nsinies := ts.nsinies;
               v_mig_tramit.ntramit := ts.ntramit;
               v_mig_tramit.ctramit := ts.ctramit;
               v_mig_tramit.ctcausin := NULL;   --OJO, el proceso de migración lo recuperará de SIN_CODTRAMITACION
                                                --utilizando el campo v_mig_tramit.CTRAMIT
                                                --CTCAUSIN: Tipo de Daño (no sirve??? MOVISINIESTRO.CCAUSIN: Naturaleza de Siniestro)
               v_mig_tramit.cinform := NVL(ts.cinform, 0);
               v_mig_tramit.cusualt := ts.cusualt;
               v_mig_tramit.falta := ts.falta;
               v_mig_tramit.cusumod := ts.cusumod;
               v_mig_tramit.fmodifi := ts.fmodifi;

               INSERT INTO mig_sin_tramitacion
                    VALUES v_mig_tramit;

               INSERT INTO mig_pk_emp_mig
                    VALUES (v_mig_tramit.mig_pk, v_ncarga_tramit, 1, v_mig_tramit.mig_pk);
            EXCEPTION
               WHEN OTHERS THEN
                  p_txt_error := SQLERRM;
                  v_no_carga_resto := ABS(SQLCODE);
                  num_err := f_ins_mig_logs_emp(v_ncarga_tramit, v_mig_tramit.mig_pk, 'E',
                                                SQLERRM || CHR(10)
                                                || DBMS_UTILITY.format_error_backtrace);
                  v_error := TRUE;
                  ROLLBACK;
            END;

            /************************ FIN MIG_SIN_TRAMITACION *****************************/
            IF v_no_carga_resto <> 0 THEN
               RETURN v_no_carga_resto;
            END IF;

            /************************ INI MIG_SIN_TRAMITA_MOVIMIENTO *****************************/

            --PARA VIDA SE CREARAN TANTOS MOVIMIENTOS DE TRAMITACION (no aparecerán en la pantalla
            --de siniestros porque su tramitación és única) COMO MOVIMIENTOS DE SINIESTROS HAY

            --IF v_no_carga_resto = 0 THEN
               /*
               FOR tsm IN (SELECT   a.*
                             FROM tramitacionsini a
                            WHERE a.nsinies = s.nsinies
                              AND a.ntramit = v_mig_tramit.ntramit
                         ORDER BY a.ntramit)
               LOOP
                 BEGIN
                    IF v_ncarga_tramit_mov IS NULL THEN
                       v_ncarga_tramit_mov := f_init_carga(pid, 'TRAMITACIONSINI', 'MIG_SIN_TRAMITA_MOVIMIENTO');
                    END IF;
               */
            FOR ms IN (SELECT   a.*
                           FROM movsiniestro a
                          WHERE a.nsinies = s.nsinies
                       ORDER BY a.nmovimi) LOOP
               BEGIN
                  IF v_ncarga_tramit_mov IS NULL THEN
                     v_ncarga_tramit_mov := f_init_carga(pid, 'MOVSINIESTRO',
                                                         'MIG_SIN_TRAMITA_MOVIMIENTO');
                  END IF;

                  DBMS_OUTPUT.put_line('MIG_SIN_TRAMITA_MOVIMIENTO-->ncarga_tramit_mov:'
                                       || v_ncarga_tramit_mov);
                  v_mig_tramit_mov := NULL;
                  v_mig_tramit_mov.ncarga := v_ncarga_tramit_mov;
                  v_mig_tramit_mov.cestmig := 1;
                  v_mig_tramit_mov.mig_pk := f_crea_pk(ms.nsinies, v_mig_tramit.ntramit,
                                                       ms.nmovimi - 1);
                  DBMS_OUTPUT.put_line('-->pk:' || v_mig_tramit_mov.mig_pk);
                  v_mig_tramit_mov.mig_fk := f_crea_pk(ms.nsinies, v_mig_tramit.ntramit);
                  v_mig_tramit_mov.nsinies := ms.nsinies;   --tsm.nsinies;
                  v_mig_tramit_mov.ntramit := v_mig_tramit.ntramit;   --tsm.ntramit;
                  v_mig_tramit_mov.nmovtra := ms.nmovimi - 1;   --los movimientos de tramitación empiezan por 0
                  v_mig_tramit_mov.cunitra := k_unitramit;   --unidad tramitador
                  v_mig_tramit_mov.ctramitad := k_usutramit;   --codigo tramitador
                  v_mig_tramit_mov.cesttra := ms.cestado;   --tsm.cestado; --VF_6???
                  v_mig_tramit_mov.csubtra := NVL(s.nsubest, 0);   --null; --subestado VF_665???? --En modelo OLDAXIS habia SUBESTADO ??
                  v_mig_tramit_mov.festtra := ms.fmovimi;   --tsm.falta;
                  v_mig_tramit_mov.cusualt := ms.cusumov;   --tsm.cusualt;
                  v_mig_tramit_mov.falta := ms.fmovimi;   --tsm.falta;

                  INSERT INTO mig_sin_tramita_movimiento
                       VALUES v_mig_tramit_mov;

                  INSERT INTO mig_pk_emp_mig
                       VALUES (f_crea_pk(ms.nsinies, ms.nmovimi), v_ncarga_tramit_mov, 1,
                               v_mig_tramit_mov.mig_pk);
               EXCEPTION
                  WHEN OTHERS THEN
                     p_txt_error := SQLERRM;
                     v_no_carga_resto := ABS(SQLCODE);
                     num_err := f_ins_mig_logs_emp(v_ncarga_tramit_mov,
                                                   v_mig_tramit_mov.mig_pk, 'E',
                                                   SQLERRM || CHR(10)
                                                   || DBMS_UTILITY.format_error_backtrace);
                     v_error := TRUE;
                     ROLLBACK;
               END;
            END LOOP;

            --END IF;
              /************************ FIN MIG_SIN_TRAMITA_MOVIMIENTO *****************************/
            IF v_no_carga_resto <> 0 THEN
               RETURN v_no_carga_resto;
            END IF;

              /************************ INI MIG_SIN_TRAMITA_AGENDA ****************************/
            --IF v_no_carga_resto = 0 THEN
            IF v_ncarga_tramit_age IS NULL THEN
               v_ncarga_tramit_age := f_init_carga(pid, 'AGENSINI', 'MIG_SIN_TRAMITA_AGENDA');
            END IF;

            DBMS_OUTPUT.put_line('MIG_SIN_TRAMITA_AGENDA-->ncarga_tramit_age:'
                                 || v_ncarga_tramit_age);

            FOR age IN (SELECT   c.*
                            FROM agensini c
                           WHERE c.nsinies = s.nsinies
                        ORDER BY nsinies, nmovage ASC) LOOP
               BEGIN
                  --POR CADA APUNTE EN LA AGENDA CREAMOS UN NUEVO REGISTRO EN MIG_SIN_TRAMITA_AGENDA
                  v_mig_tramit_age := NULL;
                  v_mig_tramit_age.ncarga := v_ncarga_tramit_age;
                  v_mig_tramit_age.cestmig := 1;
                  v_mig_tramit_age.mig_pk := f_crea_pk(age.nsinies, v_mig_tramit.ntramit,
                                                       age.nmovage);
                  DBMS_OUTPUT.put_line('-->pk:' || v_mig_tramit_age.mig_pk);
                  v_mig_tramit_age.mig_fk := f_crea_pk(age.nsinies, v_mig_tramit.ntramit);
                  v_mig_tramit_age.nsinies := age.nsinies;
                  v_mig_tramit_age.ntramit := v_mig_tramit.ntramit;
                  v_mig_tramit_age.nmovage := age.nmovage;
                  v_mig_tramit_age.fapunte := age.fapunte;
                  v_mig_tramit_age.ctipreg := age.ctipreg;
                  v_mig_tramit_age.fagenda := age.fagenda;
                  v_mig_tramit_age.ffinali := age.ffinali;
                  v_mig_tramit_age.cestado := age.cestado;
                  v_mig_tramit_age.tagenda := age.tagenda;
                  v_mig_tramit_age.cusuari := age.cusuari;
                  v_mig_tramit_age.fmovimi := age.fmovimi;
                  v_mig_tramit_age.capunte := age.capunte;
                  v_mig_tramit_age.csubtip := age.csubtip;
                  v_mig_tramit_age.sperson := age.sperson;
                  v_mig_tramit_age.sproces := age.sproces;
                  v_mig_tramit_age.cageext := age.cageext;

                  INSERT INTO mig_sin_tramita_agenda
                       VALUES v_mig_tramit_age;

                  INSERT INTO mig_pk_emp_mig
                       VALUES (f_crea_pk(age.nsinies, age.nmovage), v_ncarga_tramit_age, 1,
                               v_mig_tramit_age.mig_pk);
               EXCEPTION
                  WHEN OTHERS THEN
                     p_txt_error := SQLERRM;
                     v_no_carga_resto := ABS(SQLCODE);
                     num_err := f_ins_mig_logs_emp(v_ncarga_tramit_age,
                                                   v_mig_tramit_age.mig_pk, 'E',
                                                   SQLERRM || CHR(10)
                                                   || DBMS_UTILITY.format_error_backtrace);
                     v_error := TRUE;
                     ROLLBACK;
               END;
            END LOOP;

            --END IF;
              /************************ FIN MIG_SIN_TRAMITA_AGENDA ****************************/
            IF v_no_carga_resto <> 0 THEN
               RETURN v_no_carga_resto;
            END IF;

              /************************ INI MIG_SIN_TRAMITA_DEST ****************************/
            --IF v_no_carga_resto = 0 THEN
            IF v_ncarga_tramit_dest IS NULL THEN
               v_ncarga_tramit_dest := f_init_carga(pid, 'DESTINATARIOS',
                                                    'MIG_SIN_TRAMITA_DEST');
            END IF;

            DBMS_OUTPUT.put_line('MIG_SIN_TRAMITA_DEST-->ncarga_tramit_dest:'
                                 || v_ncarga_tramit_dest);

            FOR dest IN (SELECT   c.*
                             FROM destinatarios c
                            WHERE c.nsinies = s.nsinies
                         ORDER BY sperson, ctipdes ASC) LOOP
               BEGIN
                  --POR CADA DESTINATARIO DE PAGO CREAMOS UN NUEVO REGISTRO EN MIG_SIN_TRAMITA_DEST
                  v_mig_tramit_dest := NULL;
                  v_mig_tramit_dest.ncarga := v_ncarga_tramit_dest;
                  v_mig_tramit_dest.cestmig := 1;
                  v_mig_tramit_dest.mig_pk := f_crea_pk(dest.sperson, dest.nsinies,
                                                        dest.ctipdes);
                  DBMS_OUTPUT.put_line('-->pk:' || v_mig_tramit_dest.mig_pk);
                  v_mig_tramit_dest.mig_fk := f_crea_pk(dest.nsinies, v_mig_tramit.ntramit);
                  v_mig_tramit_dest.nsinies := dest.nsinies;
                  v_mig_tramit_dest.ntramit := v_mig_tramit.ntramit;   --tramitación GLOBAL para VIDA
                  v_mig_tramit_dest.sperson := dest.sperson;
                  v_mig_tramit_dest.ctipdes := dest.ctipdes;
                  v_mig_tramit_dest.ctipban := dest.ctipban;
                  v_mig_tramit_dest.cbancar := dest.cbancar;
                  v_mig_tramit_dest.cpagdes := dest.cpagdes;
                  v_mig_tramit_dest.cactpro := dest.cactpro;
                  v_mig_tramit_dest.pasigna := dest.pasigna;
                  v_mig_tramit_dest.cpaisre := dest.cpaisresid;
                  v_mig_tramit_dest.ctipcap := NULL;   --Por defecto 0-->Capital?? VF_205 que es esto??
                  v_mig_tramit_dest.cusualt := v_mig_tramit.cusualt;   --usuario???
                  v_mig_tramit_dest.falta := v_mig_tramit.falta;
                  v_mig_tramit_dest.cusumod := v_mig_tramit.cusumod;
                  v_mig_tramit_dest.fmodifi := v_mig_tramit.fmodifi;

                  INSERT INTO mig_sin_tramita_dest
                       VALUES v_mig_tramit_dest;

                  INSERT INTO mig_pk_emp_mig
                       VALUES (v_mig_tramit_dest.mig_pk, v_ncarga_tramit_dest, 1,
                               v_mig_tramit_dest.mig_pk);
               EXCEPTION
                  WHEN OTHERS THEN
                     p_txt_error := SQLERRM;
                     v_no_carga_resto := ABS(SQLCODE);
                     num_err := f_ins_mig_logs_emp(v_ncarga_tramit_dest,
                                                   v_mig_tramit_dest.mig_pk, 'E',
                                                   SQLERRM || CHR(10)
                                                   || DBMS_UTILITY.format_error_backtrace);
                     v_error := TRUE;
                     ROLLBACK;
               END;
            END LOOP;

            --END IF;
              /************************ FIN MIG_SIN_TRAMITA_DEST ****************************/
            IF v_no_carga_resto <> 0 THEN
               RETURN v_no_carga_resto;
            END IF;

            /************************ INI MIG_SIN_TRAMITA_RESERVA ****************************/
            --IF v_no_carga_resto = 0 THEN
            IF v_ncarga_tramit_res IS NULL THEN
               v_ncarga_tramit_res := f_init_carga(pid, 'VALORASINI',
                                                   'MIG_SIN_TRAMITA_RESERVA');
            END IF;

            DBMS_OUTPUT.put_line('MIG_SIN_TRAMITA_RESERVA-->ncarga_tramit_res:'
                                 || v_ncarga_tramit_res);
            v_nmov_res := 0;

            /*
            --SOLO CREAMOS EL REGISTRO DE RESERVA INICIAL POR GARANTIA DEL SINIESTRO ACTUAL
            --EL RESTO LOS CALCULAREMOS SEGUN PAGOS REALIZADOS

            --PROBLEMA:
            --Antes en OLDAXIS las RESERVAS (tabla VALORASINI) iban asociadas a SINIESTRO/GARANTIA
            --Ahora en iAXIS las RESERVAS (tabla SOL_TRAMITA_RESERVA) van asociadas a SINIESTRO/TRAMITACION/../..
            --¿¿¿Cómo se relacionaban antes las reservas con las tramitaciones???
            --¿¿¿En que número de tramitación debemos poner las diferentes reservas de las diferentes garantías???


            -->>HACER ESTO AL FINAL<<--

            --FINALMENTE CREAMOS TODOS LOS REGISTROS DE RESERVAS DEL MODELO VIEJO EN EL MODELO NUEVO

            --PROBLEMA PARA RELACIONAR PAGOS CON RESERVAS --> NO PASAMOS LA INFO DE PAGOS A RESERVAS
            --LO TRATAREMOS EN EL PACKAGE DE MIGRACION PARA PASARLO A LAS TABLAS SIN_XXX ADECUADAMENTE
            */
            FOR vs IN (SELECT   *
                           FROM valorasini v
                          WHERE v.nsinies = s.nsinies
                       --and v.fvalora = (select min(fvalora) from valorasini b
                       --                 where b.nsinies = v.nsinies and b.cgarant=v.cgarant)
                       ORDER BY v.cgarant, v.fvalora) LOOP
               BEGIN
                  --Creamos el primer movimiento de reserva (RESERVA INICIAL)
                  v_cgarant := vs.cgarant;   --f_codigo_axis('COBERCOD', c.cobercod);
                  v_mig_tramit_res := NULL;
                  v_mig_tramit_res.ncarga := v_ncarga_tramit_res;
                  v_mig_tramit_res.cestmig := 1;
                  v_mig_tramit_res.ctipres := 1;   --tipo de reserva VF_322 (=Indemnización)
                  v_mig_tramit_res.mig_pk := f_crea_pk(vs.cgarant, vs.nsinies,
                                                       TO_CHAR(vs.fvalora,
                                                               'DD/MM/YY-HH24:MI:SS'));
                  DBMS_OUTPUT.put_line('-->pk:' || v_mig_tramit_res.mig_pk);
                  v_mig_tramit_res.mig_fk := f_crea_pk(vs.nsinies, v_mig_tramit.ntramit);
                  v_mig_tramit_res.nsinies := vs.nsinies;
                  v_mig_tramit_res.ntramit := v_mig_tramit.ntramit;   --tramitación GLOBAL para VIDA
                  v_mig_tramit_res.nmovres := v_nmov_res;
                  v_mig_tramit_res.cgarant := vs.cgarant;
                  v_mig_tramit_res.ccalres := 0;   --calculo reserva (1-auto/manual-0)
                  v_mig_tramit_res.fmovres := vs.fvalora;
                  v_mig_tramit_res.cmonres := 'EUR';
                  v_mig_tramit_res.ireserva := vs.ivalora;
                  v_mig_tramit_res.icaprie := vs.icaprisc;
                  v_mig_tramit_res.ipenali := vs.ipenali;
                  v_mig_tramit_res.fresini := vs.fperini;
                  v_mig_tramit_res.fresfin := vs.fperfin;
                  v_mig_tramit_res.fultpag := vs.fultpag;
                  v_mig_tramit_res.cusualt := vs.cusualt;
                  v_mig_tramit_res.falta := vs.falta;
                  v_mig_tramit_res.cusumod := vs.cusumod;
                  v_mig_tramit_res.fmodifi := vs.fmodifi;
                  v_mig_tramit_res.ipago := NULL;   --PAGOSINI.campo????
                  v_mig_tramit_res.iingreso := NULL;
                  v_mig_tramit_res.irecobro := NULL;
                  v_mig_tramit_res.sidepag := NULL;   --es el de PAGOSINI??
                  v_mig_tramit_res.sproces := NULL;   --es el de PAGOSINI??
                  v_mig_tramit_res.fcontab := NULL;   --es el de PAGOSINI??
                  v_nmov_res := v_nmov_res + 1;

--Campos nuevos de SIN_TRAMITA_RESERVA:
--  IPREREC
                  INSERT INTO mig_sin_tramita_reserva
                       VALUES v_mig_tramit_res;

                  INSERT INTO mig_pk_emp_mig
                       VALUES (v_mig_tramit_res.mig_pk, v_ncarga_tramit_res, 1,
                               v_mig_tramit_res.mig_pk);
               EXCEPTION
                  WHEN OTHERS THEN
                     p_txt_error := SQLERRM;
                     num_err := f_ins_mig_logs_emp(v_ncarga_tramit_res,
                                                   v_mig_tramit_res.mig_pk, 'E',
                                                   SQLERRM || CHR(10)
                                                   || DBMS_UTILITY.format_error_backtrace);
                     v_error := TRUE;
                     ROLLBACK;
               END;
            END LOOP;

            --END IF;
              /************************ FIN MIG_SIN_TRAMITA_RESERVA *****************************/
            IF v_no_carga_resto <> 0 THEN
               RETURN v_no_carga_resto;
            END IF;

/************************ INI PAGOS *********************************/
            v_nmov_pago := 0;
            v_nmov_res := 0;

            IF v_ncarga_tramit_pago IS NULL THEN
               v_ncarga_tramit_pago := f_init_carga(pid, 'PAGOSINI', 'MIG_SIN_TRAMITA_PAGO');
            END IF;

            DBMS_OUTPUT.put_line('MIG_SIN_TRAMITA_PAGO-->ncarga_tramit_pago:'
                                 || v_ncarga_tramit_pago);

            FOR ps IN (SELECT   c.*
                           FROM pagosini c
                          WHERE c.nsinies = s.nsinies
                       ORDER BY sidepag ASC) LOOP
               -- IF v_no_carga_resto = 0 THEN
                      --v_cgarant := ps.cgarant; --f_codigo_axis('COBERCOD', c.cobercod);

               /************************ MIG_SIN_TRAMITA_PAGO *****************************/
                  --Creamos la cabecera del detalle del pago por cada detalle
                  --Creamos la cabecera del pago
               BEGIN
                  v_mig_tramit_pago := NULL;
                  v_mig_tramit_pago.ncarga := v_ncarga_tramit_pago;
                  v_mig_tramit_pago.cestmig := 1;
                  v_mig_tramit_pago.mig_pk := ps.sidepag;
                  DBMS_OUTPUT.put_line('-->PAGO pk:' || v_mig_tramit_pago.mig_pk);
                  --v_mig_siniestros.mig_pk || K_SEPARADOR
                  --   || v_mig_tramit.ntramit || K_SEPARADOR
                  --   || v_mig_tramit_pago_g.sidepag;
                  v_mig_tramit_pago.mig_fk := ps.sperson;   --no usar en PAC_MIG_AXIS para migrar OLDAXIS (ya tenemos SPERSON)
                  v_mig_tramit_pago.mig_fk2 := ps.nsinies || k_separador
                                               || v_mig_tramit.ntramit;
                  v_mig_tramit_pago.sidepag := ps.sidepag;
                  v_mig_tramit_pago.nsinies := ps.nsinies;
                  v_mig_tramit_pago.ntramit := v_mig_tramit.ntramit;
                  v_mig_tramit_pago.sperson := ps.sperson;
                  v_mig_tramit_pago.ctipdes := ps.ctipdes;   --VF_328
                  v_mig_tramit_pago.ctippag := ps.ctippag;   --VF_2;
                  v_mig_tramit_pago.cconpag := NVL(ps.cconpag, 1);   --VF_803 Concepto Pago Oblig-->Para vida -->Indemnización
                  v_mig_tramit_pago.ccauind := 1;   --VF_325; Causa Indeminización --> Defunción?
                  v_mig_tramit_pago.cforpag := ps.cforpag;   --VF_813;
                  v_mig_tramit_pago.fordpag := ps.fordpag;
                  v_mig_tramit_pago.cmonres := 'EUR';
                  v_mig_tramit_pago.isinret := ps.isinret;
                  v_mig_tramit_pago.iretenc := ps.iretenc;
                  v_mig_tramit_pago.iiva := ps.iimpiva;
                  v_mig_tramit_pago.iresrcm := ps.iresrcm;
                  v_mig_tramit_pago.iresred := ps.iresred;
                  v_mig_tramit_pago.nfacref := ps.nfacref;
                  v_mig_tramit_pago.ffacref := ps.ffacref;
                  v_mig_tramit_pago.ctransfer := ps.ctransfer;   --VF_922
                  v_mig_tramit_pago.cusualt := NVL(ps.cusuari, USER);
                  v_mig_tramit_pago.falta := SYSDATE;   --x.grabaann;

                  BEGIN
                     SELECT ctipban, cbancar,
                            'EUR'
                       INTO v_mig_tramit_pago.ctipban, v_mig_tramit_pago.cbancar,
                            v_mig_tramit_pago.cmonpag
                       FROM destinatarios c
                      WHERE c.nsinies = ps.nsinies
                        AND c.sperson = ps.sperson
                        AND c.ctipdes = ps.ctipdes;
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_txt_error := SQLERRM;
                        num_err := f_ins_mig_logs_emp(v_ncarga_tramit_pago,
                                                      v_mig_tramit_pago.mig_pk, 'W',
                                                      SQLERRM || CHR(10)
                                                      || DBMS_UTILITY.format_error_backtrace);
                  END;

                  v_mig_tramit_pago.isuplid := NULL;
                  v_mig_tramit_pago.ifranq := NULL;
                  v_mig_tramit_pago.isinretpag := NULL;
                  v_mig_tramit_pago.iretencpag := NULL;
                  v_mig_tramit_pago.iivapag := NULL;
                  v_mig_tramit_pago.isuplidpag := NULL;
                  v_mig_tramit_pago.ifranqpag := NULL;
                  v_mig_tramit_pago.iresrcmpag := NULL;
                  v_mig_tramit_pago.iresredpag := NULL;
                  v_mig_tramit_pago.fcambio := NULL;
                  v_mig_tramit_pago.cusumod := NULL;
                  v_mig_tramit_pago.fmodifi := NULL;

                  INSERT INTO mig_sin_tramita_pago
                       VALUES v_mig_tramit_pago;

                  INSERT INTO mig_pk_emp_mig
                       VALUES (v_mig_tramit_pago.mig_pk, v_ncarga_tramit_pago, 1,
                               v_mig_tramit_pago.mig_pk);
               EXCEPTION
                  WHEN OTHERS THEN
                     p_txt_error := SQLERRM;
                     v_no_carga_resto := ABS(SQLCODE);
                     num_err := f_ins_mig_logs_emp(v_ncarga_tramit_pago,
                                                   v_mig_tramit_pago.mig_pk, 'E',
                                                   SQLERRM || CHR(10)
                                                   || DBMS_UTILITY.format_error_backtrace);
                     v_error := TRUE;
                     --v_no_carga_resto := 1;
                     ROLLBACK;
               END;

               /************************ FIN MIG_SIN_TRAMITA_PAGO *****************************/
               IF v_no_carga_resto <> 0 THEN
                  RETURN v_no_carga_resto;
               END IF;

               /************************ MIG_SIN_TRAMITA_MOV_PAGO *****************************/
               --Creamos los movimientos del pago, de 1 a 3 dependiendo del estado
               IF v_ncarga_tramit_movpago IS NULL THEN
                  v_ncarga_tramit_movpago := f_init_carga(pid, 'PAGOSINI',
                                                          'MIG_SIN_TRAMITA_MOVPAGO');
               END IF;

               DBMS_OUTPUT.put_line('    MIG_SIN_TRAMITA_MOVPAGO-->ncarga_tramit_movpago:'
                                    || v_ncarga_tramit_movpago);

               --Creamos el movimiento inicial del pago
               BEGIN
                  v_mig_tramit_movpago := NULL;
                  v_mig_tramit_movpago.ncarga := v_ncarga_tramit_movpago;
                  v_mig_tramit_movpago.cestmig := 1;
                  v_mig_tramit_movpago.mig_pk := ps.sidepag || k_separador || v_nmov_pago;
                  DBMS_OUTPUT.put_line('   -->pk:' || v_mig_tramit_movpago.mig_pk);
                  v_mig_tramit_movpago.mig_fk := ps.sidepag;
                  v_mig_tramit_movpago.sidepag := ps.sidepag;
                  v_mig_tramit_movpago.nmovpag := v_nmov_pago;
                  v_mig_tramit_movpago.cestpag := ps.cestpag;   --0;
                  v_mig_tramit_movpago.fefepag := ps.fefepag;
                  v_mig_tramit_movpago.cestval := 0;   --1??
                  v_mig_tramit_movpago.fcontab := ps.fcontab;
                  v_mig_tramit_movpago.sproces := ps.sproces;
                  v_mig_tramit_movpago.cusualt := NVL(ps.cusuari, USER);
                  v_mig_tramit_movpago.falta := SYSDATE;   ---????
                  v_nmov_pago := v_nmov_pago + 1;

--Campos nuevos de SIN_TRAMITA_MOVPAGO:
--  CESTPAGANT
                  INSERT INTO mig_sin_tramita_movpago
                       VALUES v_mig_tramit_movpago;

                  INSERT INTO mig_pk_emp_mig
                       VALUES (v_mig_tramit_movpago.mig_pk, v_ncarga_tramit_movpago, 1,
                               v_mig_tramit_movpago.mig_pk);
               EXCEPTION
                  WHEN OTHERS THEN
                     p_txt_error := SQLERRM;
                     v_no_carga_resto := ABS(SQLCODE);
                     num_err := f_ins_mig_logs_emp(v_ncarga_tramit_movpago,
                                                   v_mig_tramit_movpago.mig_pk, 'E',
                                                   SQLERRM || CHR(10)
                                                   || DBMS_UTILITY.format_error_backtrace);
                     v_error := TRUE;
                     --v_no_carga_resto := 1;
                     ROLLBACK;
               END;

/*
                  --CREAMOS EL RESTO DE MOVIMIENTOS DEL PAGO DEPENDIENDO DEL ESTADO
                  --IF x.situcsin IN('PL', 'SC')   AND v_no_carga_resto = 0 THEN
                  --Situaciones del Pago: Pendiente de Liquidacion, Siniestro Cerrado
                     BEGIN
                        v_nmov_pago := v_nmov_pago + 1;
                        v_mig_tramit_movpago := NULL;
                        v_mig_tramit_movpago.ncarga := v_ncarga_tramit_movpago;
                        v_mig_tramit_movpago.cestmig := 1;
                        v_mig_tramit_movpago.mig_pk :=
                           v_mig_siniestros.mig_pk || K_SEPARADOR
                           || v_mig_tramit.ntramit || K_SEPARADOR
                           || v_mig_tramit_pago_g.sidepag || K_SEPARADOR
                           || v_nmov_pago;
                        v_mig_tramit_movpago.mig_fk :=
                           v_mig_tramit.mig_pk || K_SEPARADOR
                           || v_mig_tramit_pago_g.sidepag;
                        v_mig_tramit_movpago.sidepag := v_mig_tramit_pago_g.sidepag;
                        v_mig_tramit_movpago.nmovpag := v_nmov_pago;
                        v_mig_tramit_movpago.cestpag := 1;

                        v_mig_tramit_movpago.fefepag := ps.fefepag;
                        v_mig_tramit_movpago.cestval := 1;
                        v_mig_tramit_movpago.fcontab := ps.fcontab;
                        v_mig_tramit_movpago.sproces := ps.sproces;
                        v_mig_tramit_movpago.cusualt := ps.cusuari;
                        v_mig_tramit_movpago.falta := ps.fperini;---????

                        INSERT INTO mig_sin_tramita_movpago
                             VALUES v_mig_tramit_movpago;

                        INSERT INTO mig_pk_emp_mig
                             VALUES (v_mig_tramit_movpago.mig_pk, v_ncarga_tramit_movpago, 1,
                                     v_mig_tramit_movpago.mig_pk);
                     EXCEPTION
                        WHEN OTHERS THEN
                           num_err := f_ins_mig_logs_emp(v_ncarga_tramit_movpago,
                                                         v_mig_tramit_movpago.mig_pk, 'E',
                                                         SQLERRM || CHR(10)
                                                         || DBMS_UTILITY.format_error_backtrace);
                           v_error := TRUE;
                           v_no_carga_resto := 1;
                           ROLLBACK;
                     END;

                    -- IF x.situcsin IN('SC') AND v_no_carga_resto = 0 THEN --Siniestro Cerrado
                    BEGIN
                       v_nmov_pago := v_nmov_pago + 1;
                       v_mig_tramit_movpago := NULL;
                       v_mig_tramit_movpago.ncarga := v_ncarga_tramit_movpago;
                       v_mig_tramit_movpago.cestmig := 1;
                       v_mig_tramit_movpago.mig_pk :=
                          v_mig_siniestros.mig_pk || K_SEPARADOR
                          || v_mig_tramit.ntramit || K_SEPARADOR
                          || v_mig_tramit_pago_g.sidepag || K_SEPARADOR
                          || v_nmov_pago;
                       v_mig_tramit_movpago.mig_fk :=
                          v_mig_tramit.mig_pk || K_SEPARADOR
                          || v_mig_tramit_pago_g.sidepag;
                       v_mig_tramit_movpago.sidepag := v_mig_tramit_pago_g.sidepag;
                       v_mig_tramit_movpago.nmovpag := v_nmov_pago;
                       v_mig_tramit_movpago.cestpag := 2;

                     v_mig_tramit_movpago.fefepag := ps.fefepag;
                     v_mig_tramit_movpago.cestval := 1;
                     v_mig_tramit_movpago.fcontab := ps.fcontab;
                     v_mig_tramit_movpago.sproces := ps.sproces;
                     v_mig_tramit_movpago.cusualt := ps.cusuari;
                     v_mig_tramit_movpago.falta := ps.fperini;---????

                       INSERT INTO mig_sin_tramita_movpago
                            VALUES v_mig_tramit_movpago;

                       INSERT INTO mig_pk_emp_mig
                            VALUES (v_mig_tramit_movpago.mig_pk, v_ncarga_tramit_movpago,
                                    1, v_mig_tramit_movpago.mig_pk);
                    EXCEPTION
                       WHEN OTHERS THEN
                          num_err :=
                             f_ins_mig_logs_emp(v_ncarga_tramit_movpago,
                                                v_mig_tramit_movpago.mig_pk, 'E',
                                                SQLERRM || CHR(10)
                                                || DBMS_UTILITY.format_error_backtrace);
                          v_error := TRUE;
                          v_no_carga_resto := 1;
                          ROLLBACK;
                    END;
                     --END IF;
                  --END IF;
*/        /************************ FIN MIG_SIN_TRAMITA_MOV_PAGO *****************************/
               IF v_ncarga_tramit_pago_g IS NULL THEN
                  v_ncarga_tramit_pago_g := f_init_carga(pid, 'PAGOGARANTIA',
                                                         'MIG_SIN_TRAMITA_PAGO_GAR');
               END IF;

               DBMS_OUTPUT.put_line
                                   ('   MIG_SIN_TRAMITA_PAGOGARANTIA-->ncarga_tramit_garan:'
                                    || v_ncarga_tramit_pago_g);
               v_norden := 0;

               --Recuperamos la GARANTIA afectada para recalcular su RESERVA restando su PAGO
               FOR pg IN (SELECT   c.*
                              FROM pagogarantia c
                             WHERE c.sidepag = ps.sidepag
                          ORDER BY c.cgarant) LOOP
                  --BEGIN
                  --Este loop es pq no podemos asegurar que 1 sidepag afecta a solo 1 garantia por la PK de PAGOGARANTIA
                  --Se supone que todos los registros de PAGOSINI existen en PAGOGARANTIA (hay pagos sin garantia??,
                  --si los hay se debe calcular la reserva de los PAGOSINI que no tienen garantia afectada (sin garantia asociada)
                  --FINALMENTE no es necesario pq ya hemos migrado todos los registros de RESERVA de OLDAXIS
                  v_cgarant := pg.cgarant;   --f_codigo_axis('COBERCOD', c.cobercod);

                  /************************ MIG_SIN_TRAMITA_PAGO_G *****************************/
                  --Creamos el detalle del pago en la garantia recien creada
                  BEGIN
                     --INSERTAMOS EL PAGO EN MIG_SIN_TRAMITA_PAGO_GAR
                     v_mig_tramit_pago_g := NULL;
                     v_mig_tramit_pago_g.ncarga := v_ncarga_tramit_pago_g;
                     v_mig_tramit_pago_g.cestmig := 1;
                     v_mig_tramit_pago_g.ctipres := 1;
                     v_mig_tramit_pago_g.mig_pk :=
                        pg.sidepag || k_separador || v_mig_tramit_pago_g.ctipres
                        || k_separador || v_nmov_res;
                     DBMS_OUTPUT.put_line('   -->pk:' || v_mig_tramit_pago_g.mig_pk);
                     v_mig_tramit_pago_g.mig_fk := pg.sidepag;
                     v_mig_tramit_pago_g.sidepag := pg.sidepag;
                     v_mig_tramit_pago_g.nmovres := v_nmov_res;   --debe coincidir con el de la RESERVA??? comorr??
                     v_mig_tramit_pago_g.cgarant := v_cgarant;
                     v_mig_tramit_pago_g.fperini := pg.fperini;
                     v_mig_tramit_pago_g.fperfin := pg.fperfin;
                     v_mig_tramit_pago_g.cmonres := 'EUR';
                     v_mig_tramit_pago_g.isinret := pg.isinret;
                     v_mig_tramit_pago_g.iretenc := ps.iretenc;
                     v_mig_tramit_pago_g.pretenc := ps.pretenc;
                     v_mig_tramit_pago_g.iiva := pg.iimpiva;
                     v_mig_tramit_pago_g.ifranq := 0;
                     v_mig_tramit_pago_g.iresrcm := ps.iresrcm;
                     v_mig_tramit_pago_g.iresred := ps.iresred;
                     v_mig_tramit_pago_g.cusualt := NVL(f_user, USER);
                     v_mig_tramit_pago_g.falta := SYSDATE;
                     v_mig_tramit_pago_g.norden := v_norden;
                     v_mig_tramit_pago_g.isuplid := NULL;
                     v_mig_tramit_pago_g.cmonpag := NULL;
                     v_mig_tramit_pago_g.isinretpag := NULL;
                     v_mig_tramit_pago_g.iivapag := NULL;
                     v_mig_tramit_pago_g.isuplidpag := NULL;
                     v_mig_tramit_pago_g.iretencpag := NULL;
                     v_mig_tramit_pago_g.ifranqpag := NULL;
                     v_mig_tramit_pago_g.iresrcmpag := NULL;
                     v_mig_tramit_pago_g.iresredpag := NULL;
                     v_mig_tramit_pago_g.fcambio := NULL;
                     v_mig_tramit_pago_g.piva := NULL;
                     v_mig_tramit_pago_g.cusumod := NULL;
                     v_mig_tramit_pago_g.fmodifi := NULL;
                     v_nmov_res := v_nmov_res + 1;
                     v_norden := v_norden + 1;

--Campos nuevos de SIN_TRAMITA_PAGO_GAR:
--  CCONPAG
--  NORDEN
                     INSERT INTO mig_sin_tramita_pago_gar
                          VALUES v_mig_tramit_pago_g;

                     INSERT INTO mig_pk_emp_mig
                          VALUES (v_mig_tramit_pago_g.mig_pk, v_ncarga_tramit_pago_g, 1,
                                  v_mig_tramit_pago_g.mig_pk);
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_txt_error := SQLERRM;
                        v_no_carga_resto := ABS(SQLCODE);
                        num_err := f_ins_mig_logs_emp(v_ncarga_tramit_pago_g,
                                                      v_mig_tramit_pago_g.mig_pk, 'E',
                                                      SQLERRM || CHR(10)
                                                      || DBMS_UTILITY.format_error_backtrace);
                        v_error := TRUE;
                        ROLLBACK;
                  END;
               /************************ MIG_SIN_TRAMITA_PAGO_G *****************************/
               END LOOP;   --de pagogarantia

               IF v_no_carga_resto <> 0 THEN
                  RETURN v_no_carga_resto;
               END IF;
            END LOOP;   --de pagosini

            v_imp_aux := NULL;
/************************ FIN PAGO *****************************/
            COMMIT;   --x cada tramitacion
         /************************ FIN TRAMITACION *****************************/
         END LOOP;
      /************************ FIN SINIESTRO *****************************/
      --tabla PAGOSSINCES para qué sirve...se debe migrar?????
      END LOOP;

      v_estorg := CASE
                    WHEN v_error THEN 'ERROR'
                    WHEN v_warning THEN 'WARNING'
                    ELSE 'OK'
                 END;

      UPDATE mig_cargas
         SET ffinorg = f_sysdate,
             estorg = v_estorg
       WHERE ncarga IN(v_ncarga,
                       v_ncarga_movsin,
                       v_ncarga_tramit,
                       v_ncarga_tramit_mov,
                       v_ncarga_tramit_res,
                       v_ncarga_tramit_pago_g,
                       v_ncarga_tramit_pago,
                       v_ncarga_tramit_movpago);

      COMMIT;
      RETURN 0;
   END f_migra_sin_siniestros;

   /***************************************************************************
      PROCEDURE p_ejecutar_carga
      Traspasa los datos de las tablas ORIGEN DE DATOS a las intermedias MIG, segun el
      parametro pasado traspasa todas las tablas o solo las de un modulo
      determinado.
         param in ptipo     : modulo a migrar
         param in pproducte : Código producto a migrar.
         param in pid       : Identificador migración
   ***************************************************************************/
   PROCEDURE p_ejecutar_carga(pid IN VARCHAR2, p_numrows IN NUMBER DEFAULT NULL) IS
      num_err        NUMBER := 0;
      empresa        VARCHAR2(10);
      texto_error    VARCHAR2(300);
   BEGIN
      DBMS_OUTPUT.put_line('PID:' || pid);
      empresa := f_parinstalacion_n('EMPRESADEF');
      DBMS_OUTPUT.put_line('EMP:' || empresa);
      DBMS_OUTPUT.put_line('USER_BBDD:' || pac_parametros.f_parempresa_t(empresa, 'USER_BBDD'));
      --num_err := pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(empresa,'USER_BBDD'));
      --dbms_output.put_line ('CONTEXTO num_err:'||num_err);
      num_err := f_migra_sin_siniestros(pid, p_numrows, texto_error);
      DBMS_OUTPUT.put_line('SINIESTROS:' || num_err || '-' || texto_error);
   END p_ejecutar_carga;
END pac_mig_oldaxis;

/

  GRANT EXECUTE ON "AXIS"."PAC_MIG_OLDAXIS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MIG_OLDAXIS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MIG_OLDAXIS" TO "PROGRAMADORESCSI";
