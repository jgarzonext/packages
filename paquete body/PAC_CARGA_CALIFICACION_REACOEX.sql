--------------------------------------------------------
--  DDL for Package Body PAC_CARGA_CALIFICACION_REACOEX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_CARGA_CALIFICACION_REACOEX" AS

   /**********************************************************************
        Función que modifica la tabla ext para cargar un fichero
        param in p_nombre : Nombre fichero
        param in p_path : Nombre Path
        retorna 0 si ha ido bien, sino num_err.
   ***********************************************************************/
   FUNCTION f_carga_calificacion_reacoex(p_nombre  IN VARCHAR2,
                                         p_path    IN VARCHAR2,
                                         p_cproces IN NUMBER,
                                         psproces  IN OUT NUMBER)
      RETURN NUMBER IS
      v_tnomfich     VARCHAR2(100);
      vefecto        DATE;
      vestado_califi NUMBER;
      vfinscrip      DATE;
      vanyoactualiz  DATE;
      vsperson       NUMBER;
      vccompani      NUMBER;
      vccalifi       NUMBER;
      v_ofc_rep      VARCHAR2(1);
      vpasexec       NUMBER := 1;
      vnum_err       NUMBER := 0;
      valida         NUMBER := 0;
      errorini      EXCEPTION;
      e_errdatos    EXCEPTION;
      e_param_error EXCEPTION;
      vobj        VARCHAR2(100) := 'PAC_CARGA_CALIFICACION_REACOEX.f_carga_calificacion_reacoex';
      v_numlineaf NUMBER := 0;

      PROCEDURE p_controlar_error(p_traza  NUMBER,
                                  p_estado NUMBER,
                                  v_msg    VARCHAR2) IS
      BEGIN
         vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces,
                                                                    p_nombre,
                                                                    f_sysdate,
                                                                    NULL,
                                                                    p_estado,
                                                                    p_cproces,
                                                                    NULL,
                                                                    v_msg);

         IF vnum_err <> 0
         THEN
            -- Si fallan esta funciones de gesti¢n salimos del programa
            p_tab_error(f_sysdate,
                        f_user,
                        vobj,
                        p_traza,
                        vnum_err,
                        'Error llamando pac_gestion_procesos.f_set_carga_ctrl_cabecera' ||
                        p_traza);
            RAISE errorini;
         END IF;

      END p_controlar_error;

   BEGIN
      v_tnomfich := SUBSTR(p_nombre, 1, INSTR(p_nombre, '.') - 1);
      SELECT sproces.nextval INTO psproces FROM dual;

      p_controlar_error(2, 3, NULL);

      --Modificamos los logs
      EXECUTE IMMEDIATE 'alter table INT_CALIFICACION_REACOEX_CONF ACCESS PARAMETERS (records delimited by 0x''0A''
                   logfile ' || chr(39) || p_nombre ||
                        '.log' || chr(39) || '
                   badfile ' || chr(39) || p_nombre ||
                        '.bad' || chr(39) || '
                   discardfile ' || chr(39) ||
                        p_nombre || '.dis' || chr(39) || '
                   fields terminated by '';'' lrtrim
                   MISSING FIELD VALUES ARE NULL
                   REJECT ROWS WITH ALL NULL FIELDS
                   (  Consecutivo          ,
                      Compania          ,
                      Pais           ,
                      Calificacion_1             ,
                      Calificacion_2           ,
                      Calificacion_3             ,
                      Calificacion_4      ,
                      Ofc_Rep            ,
                      Actualizacion

                  ))';
      vpasexec := 2;

      --Cargamos el fichero
      EXECUTE IMMEDIATE 'ALTER TABLE INT_CALIFICACION_REACOEX_CONF LOCATION (''' ||
                        p_nombre || ''')';
      --
      vpasexec := 3;
      --
      BEGIN
         FOR c_datos IN (SELECT * FROM int_calificacion_reacoex_conf)
         LOOP
            v_numlineaf    := v_numlineaf + 1;
            vccalifi       := 0;
            vestado_califi := 0;
            valida         := 0;
            --
            BEGIN
               IF c_datos.compania IS NOT NULL
               THEN
                  SELECT sperson,
                         ccompani
                    INTO vsperson,
                         vccompani
                    FROM companias
                   WHERE ctipcom = 0
                     AND 95 <=
                         utl_match.jaro_winkler_similarity(tcompani,
                                                           c_datos.compania);
               END IF;
               --
            EXCEPTION
               WHEN OTHERS THEN

                  vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces   => psproces,
                                                                          pnlinea    => v_numlineaf,
                                                                          pctipo     => 21,
                                                                          pidint     => v_numlineaf,
                                                                          pidext     => v_numlineaf,
                                                                          pcestado   => 5,
                                                                          pcvalidado => NULL,
                                                                          psseguro   => NULL,
                                                                          pidexterno => NULL,
                                                                          pncarga    => NULL,
                                                                          pnsinies   => NULL,
                                                                          pntramit   => NULL,
                                                                          psperson   => NULL,
                                                                          pnrecibo   => NULL);

                  -- El codigo de compañia reaseguradora no coinciden
                  vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea_error(psproces  => psproces,
                                                                                pnlinea   => v_numlineaf,
                                                                                pnerror   => v_numlineaf,
                                                                                pctipo    => 1,
                                                                                pcerror   => 9909154,
                                                                                ptmensaje => 9909154);
                  p_tab_error(f_sysdate,
                              f_user,
                              'PAC_CARGA_CALIFICACION_REACOEX.F_CARGA_CALIFICACION_REACOEX',
                              vpasexec,
                              'codigo de compañia: ' ||
                              dbms_utility.format_error_backtrace,
                              SQLERRM);
                  vccompani := NULL;
                  vsperson  := NULL;
                  valida    := -1;
            END;
            --

            vefecto := last_day(TO_DATE(SUBSTR(p_nombre, 1, 6) || '01',
                                        'YYYYMMDD'));

            --
            BEGIN
               IF INSTR(UPPER(c_datos.actualizacion), 'INSCRITO') = 1
               THEN
                  vestado_califi := 1;
                  vfinscrip      := TO_DATE(SUBSTR(c_datos.actualizacion, 10, 10), 'dd/MM/YYYY');
                  vanyoactualiz  := NULL;
               END IF;
               --
               IF INSTR(UPPER(c_datos.actualizacion), 'ACTUALIZADO') = 1
               THEN
                  vestado_califi := 2;
                  vfinscrip      := NULL;
                  vanyoactualiz  := to_date('01'||'01'||SUBSTR(c_datos.actualizacion, 13, 4));--SUBSTR(c_datos.actualizacion, 13, 4);
               END IF;
               --
               IF INSTR(UPPER(c_datos.actualizacion), 'SUSPENDIDO') = 1
               THEN
                  vestado_califi := 3;
                  vfinscrip      := NULL;
                  vanyoactualiz  := NULL;
               END IF;
               --
               IF vestado_califi = 0
               THEN
                  vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces   => psproces,
                                                                          pnlinea    => v_numlineaf,
                                                                          pctipo     => 21,
                                                                          pidint     => v_numlineaf,
                                                                          pidext     => v_numlineaf,
                                                                          pcestado   => 5,
                                                                          pcvalidado => NULL,
                                                                          psseguro   => NULL,
                                                                          pidexterno => NULL,
                                                                          pncarga    => NULL,
                                                                          pnsinies   => NULL,
                                                                          pntramit   => NULL,
                                                                          psperson   => NULL,
                                                                          pnrecibo   => NULL);

                  -- Los datos del estado de calificacion no coinciden
                  vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea_error(psproces  => psproces,
                                                                                pnlinea   => v_numlineaf,
                                                                                pnerror   => v_numlineaf,
                                                                                pctipo    => 1,
                                                                                pcerror   => 9909155,
                                                                                ptmensaje => 9909155);
                  p_tab_error(f_sysdate,
                              f_user,
                              'PAC_CARGA_CALIFICACION_REACOEX.F_CARGA_CALIFICACION_REACOEX',
                              vpasexec,
                              'estado de calificacion: ' ||
                              dbms_utility.format_error_backtrace,
                              SQLERRM);
                  vestado_califi := NULL;
                  valida         := -1;
               END IF;
               --
            EXCEPTION
               WHEN OTHERS THEN
                  vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces   => psproces,
                                                                          pnlinea    => v_numlineaf,
                                                                          pctipo     => 21,
                                                                          pidint     => v_numlineaf,
                                                                          pidext     => v_numlineaf,
                                                                          pcestado   => 5,
                                                                          pcvalidado => NULL,
                                                                          psseguro   => NULL,
                                                                          pidexterno => NULL,
                                                                          pncarga    => NULL,
                                                                          pnsinies   => NULL,
                                                                          pntramit   => NULL,
                                                                          psperson   => NULL,
                                                                          pnrecibo   => NULL);

                  -- Los datos del estado de calificacion no coinciden
                  vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea_error(psproces  => psproces,
                                                                                pnlinea   => v_numlineaf,
                                                                                pnerror   => v_numlineaf,
                                                                                pctipo    => 1,
                                                                                pcerror   => 9909155,
                                                                                ptmensaje => 9909155);
                  p_tab_error(f_sysdate,
                              f_user,
                              'PAC_CARGA_CALIFICACION_REACOEX.F_CARGA_CALIFICACION_REACOEX',
                              vpasexec,
                              'estado de calificacion: ' ||
                              dbms_utility.format_error_backtrace,
                              SQLERRM);
                  vestado_califi := NULL;
                  valida         := -1;
            END;
            --
            BEGIN
               IF UPPER(c_datos.ofc_rep) = 'X'
               THEN
                  v_ofc_rep := 'S';
               ELSIF c_datos.ofc_rep IS NULL
               THEN
                  v_ofc_rep := 'N';
               END IF;
               --
            EXCEPTION
               WHEN OTHERS THEN
                  vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces   => psproces,
                                                                          pnlinea    => v_numlineaf,
                                                                          pctipo     => 21,
                                                                          pidint     => v_numlineaf,
                                                                          pidext     => v_numlineaf,
                                                                          pcestado   => 5,
                                                                          pcvalidado => NULL,
                                                                          psseguro   => NULL,
                                                                          pidexterno => NULL,
                                                                          pncarga    => NULL,
                                                                          pnsinies   => NULL,
                                                                          pntramit   => NULL,
                                                                          psperson   => NULL,
                                                                          pnrecibo   => NULL);

                  -- Error oficina de representacion
                  vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea_error(psproces  => psproces,
                                                                                pnlinea   => v_numlineaf,
                                                                                pnerror   => v_numlineaf,
                                                                                pctipo    => 1,
                                                                                pcerror   => 9909563,
                                                                                ptmensaje => 9909563);
                  p_tab_error(f_sysdate,
                              f_user,
                              'PAC_CARGA_CALIFICACION_REACOEX.F_CARGA_CALIFICACION_REACOEX',
                              vpasexec,
                              'Oficina de representacion: ' ||
                              dbms_utility.format_error_backtrace,
                              SQLERRM);
                  v_ofc_rep := NULL;
                  valida    := -1;
            END;
            --

            IF vccompani IS NOT NULL AND
               vsperson IS NOT NULL AND
               v_ofc_rep IS NOT NULL AND
               vestado_califi IS NOT NULL
            THEN
               BEGIN

                  IF c_datos.calificacion_1 IS NOT NULL
                  THEN
                     SELECT catribu
                       INTO vccalifi
                       FROM detvalores
                      WHERE cvalor = 800100
                        AND cidioma = f_idiomauser
                        AND 95 <=
                            utl_match.jaro_winkler_similarity(tatribu,
                                                              c_datos.calificacion_1);

                     INSERT INTO compcalificacion
                        (sperson, centicalifi, fefecto, ccompani, ccalifi,
                         falta, cusualta, ofc_repres, cestado_califi,
                         finscrip, anyoactualiz)
                     VALUES
                        (vsperson, 1, vefecto, vccompani, vccalifi,
                         f_sysdate, f_user, v_ofc_rep, vestado_califi,
                         vfinscrip, vanyoactualiz);

                     UPDATE companias
                        SET ccalifi     = vccalifi,
                            centicalifi = 1,
                            nanycalif = TO_NUMBER(TO_CHAR(vanyoactualiz, 'YYYY'))
                      WHERE ccompani = vccompani;
                      --

                  END IF;

                  IF c_datos.calificacion_2 IS NOT NULL
                  THEN
                     SELECT catribu
                       INTO vccalifi
                       FROM detvalores
                      WHERE cvalor = 800100
                        AND cidioma = f_idiomauser
                        AND 95 <=
                            utl_match.jaro_winkler_similarity(tatribu,
                                                              c_datos.calificacion_2);

                     INSERT INTO compcalificacion
                        (sperson, centicalifi, fefecto, ccompani, ccalifi,
                         falta, cusualta, ofc_repres, cestado_califi,
                         finscrip, anyoactualiz)
                     VALUES
                        (vsperson, 4, vefecto, vccompani, vccalifi,
                         f_sysdate, f_user, v_ofc_rep, vestado_califi,
                         vfinscrip, vanyoactualiz);
                     --
                     UPDATE companias
                        SET ccalifi     = vccalifi,
                            centicalifi = 4,
                            nanycalif = TO_NUMBER(TO_CHAR(vanyoactualiz, 'YYYY'))
                      WHERE ccompani = vccompani;

                  END IF;
                  IF c_datos.calificacion_3 IS NOT NULL
                  THEN
                     SELECT catribu
                       INTO vccalifi
                       FROM detvalores
                      WHERE cvalor = 800100
                        AND cidioma = f_idiomauser
                        AND 95 <=
                            utl_match.jaro_winkler_similarity(tatribu,
                                                              c_datos.calificacion_3);

                     INSERT INTO compcalificacion
                        (sperson, centicalifi, fefecto, ccompani, ccalifi,
                         falta, cusualta, ofc_repres, cestado_califi,
                         finscrip, anyoactualiz)
                     VALUES
                        (vsperson, 3, vefecto, vccompani, vccalifi,
                         f_sysdate, f_user, v_ofc_rep, vestado_califi,
                         vfinscrip, vanyoactualiz);
                     --
                     UPDATE companias
                        SET ccalifi     = vccalifi,
                            centicalifi = 3,
                            nanycalif = TO_NUMBER(TO_CHAR(vanyoactualiz, 'YYYY'))
                      WHERE ccompani = vccompani;

                  END IF;

                  IF c_datos.calificacion_4 IS NOT NULL
                  THEN
                     SELECT catribu
                       INTO vccalifi
                       FROM detvalores
                      WHERE cvalor = 800100
                        AND cidioma = f_idiomauser
                        AND 95 <=
                            utl_match.jaro_winkler_similarity(tatribu,
                                                              c_datos.calificacion_4);

                     INSERT INTO compcalificacion
                        (sperson, centicalifi, fefecto, ccompani, ccalifi,
                         falta, cusualta, ofc_repres, cestado_califi,
                         finscrip, anyoactualiz)
                     VALUES
                        (vsperson, 2, vefecto, vccompani, vccalifi,
                         f_sysdate, f_user, v_ofc_rep, vestado_califi,
                         vfinscrip, vanyoactualiz);
                     --
                     UPDATE companias
                        SET ccalifi     = vccalifi,
                            centicalifi = 2,
                            nanycalif = TO_NUMBER(TO_CHAR(vanyoactualiz, 'YYYY'))
                      WHERE ccompani = vccompani;

                  END IF;

                  IF vccalifi = 0
                  THEN

                     vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces   => psproces,
                                                                             pnlinea    => v_numlineaf,
                                                                             pctipo     => 21,
                                                                             pidint     => v_numlineaf,
                                                                             pidext     => v_numlineaf,
                                                                             pcestado   => 5,
                                                                             pcvalidado => NULL,
                                                                             psseguro   => NULL,
                                                                             pidexterno => NULL,
                                                                             pncarga    => NULL,
                                                                             pnsinies   => NULL,
                                                                             pntramit   => NULL,
                                                                             psperson   => NULL,
                                                                             pnrecibo   => NULL);

                     -- Los datos de calificacion no coinciden
                     vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea_error(psproces  => psproces,
                                                                                   pnlinea   => v_numlineaf,
                                                                                   pnerror   => v_numlineaf,
                                                                                   pctipo    => 1,
                                                                                   pcerror   => 9909153,
                                                                                   ptmensaje => 9909153);
                     valida   := -1;

                  END IF;

               EXCEPTION
                  WHEN dup_val_on_index THEN

                     IF c_datos.calificacion_1 IS NOT NULL
                     THEN

                        UPDATE compcalificacion
                           SET ccompani       = vccompani,
                               ccalifi        = vccalifi,
                               falta          = f_sysdate,
                               cusualta       = f_user,
                               ofc_repres     = v_ofc_rep,
                               cestado_califi = vestado_califi,
                               finscrip       = vfinscrip,
                               anyoactualiz   = vanyoactualiz
                         WHERE sperson = vsperson
                           AND centicalifi = 1
                           AND fefecto = vefecto;
                         --
                         UPDATE companias
                            SET ccalifi     = vccalifi,
                                centicalifi = 1,
                                nanycalif   = TO_NUMBER(TO_CHAR(vanyoactualiz, 'YYYY'))
                          WHERE ccompani    = vccompani;

                     END IF;

                     IF c_datos.calificacion_2 IS NOT NULL
                     THEN

                        UPDATE compcalificacion
                           SET ccompani       = vccompani,
                               ccalifi        = vccalifi,
                               falta          = f_sysdate,
                               cusualta       = f_user,
                               ofc_repres     = v_ofc_rep,
                               cestado_califi = vestado_califi,
                               finscrip       = vfinscrip,
                               anyoactualiz   = vanyoactualiz
                         WHERE sperson = vsperson
                           AND centicalifi = 4
                           AND fefecto = vefecto;
                         --
                         UPDATE companias
                            SET ccalifi     = vccalifi,
                                centicalifi = 4,
                                nanycalif   = TO_NUMBER(TO_CHAR(vanyoactualiz, 'YYYY'))
                          WHERE ccompani    = vccompani;

                     END IF;

                     IF c_datos.calificacion_3 IS NOT NULL
                     THEN

                        UPDATE compcalificacion
                           SET ccompani       = vccompani,
                               ccalifi        = vccalifi,
                               falta          = f_sysdate,
                               cusualta       = f_user,
                               ofc_repres     = v_ofc_rep,
                               cestado_califi = vestado_califi,
                               finscrip       = vfinscrip,
                               anyoactualiz   = vanyoactualiz
                         WHERE sperson = vsperson
                           AND centicalifi = 3
                           AND fefecto = vefecto;
                         --
                         UPDATE companias
                            SET ccalifi     = vccalifi,
                                centicalifi = 3,
                                nanycalif   = TO_NUMBER(TO_CHAR(vanyoactualiz, 'YYYY'))
                          WHERE ccompani    = vccompani;

                     END IF;

                     IF c_datos.calificacion_4 IS NOT NULL
                     THEN

                        UPDATE compcalificacion
                           SET ccompani       = vccompani,
                               ccalifi        = vccalifi,
                               falta          = f_sysdate,
                               cusualta       = f_user,
                               ofc_repres     = v_ofc_rep,
                               cestado_califi = vestado_califi,
                               finscrip       = vfinscrip,
                               anyoactualiz   = vanyoactualiz
                         WHERE sperson = vsperson
                           AND centicalifi = 2
                           AND fefecto = vefecto;
                         --
                         UPDATE companias
                            SET ccalifi     = vccalifi,
                                centicalifi = 2,
                                nanycalif   = TO_NUMBER(TO_CHAR(vanyoactualiz, 'YYYY'))
                          WHERE ccompani    = vccompani;

                     END IF;

                  WHEN OTHERS THEN
                     vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces   => psproces,
                                                                             pnlinea    => v_numlineaf,
                                                                             pctipo     => 21,
                                                                             pidint     => v_numlineaf,
                                                                             pidext     => v_numlineaf,
                                                                             pcestado   => 5,
                                                                             pcvalidado => NULL,
                                                                             psseguro   => NULL,
                                                                             pidexterno => NULL,
                                                                             pncarga    => NULL,
                                                                             pnsinies   => NULL,
                                                                             pntramit   => NULL,
                                                                             psperson   => NULL,
                                                                             pnrecibo   => NULL);

                     -- Los datos de calificacion no coinciden
                     vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea_error(psproces  => psproces,
                                                                                   pnlinea   => v_numlineaf,
                                                                                   pnerror   => v_numlineaf,
                                                                                   pctipo    => 1,
                                                                                   pcerror   => 9909153,
                                                                                   ptmensaje => 9909153);
                     valida   := -1;

               END;

               IF valida = 0
               THEN
                  vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces   => psproces,
                                                                          pnlinea    => v_numlineaf,
                                                                          pctipo     => 21,
                                                                          pidint     => v_numlineaf,
                                                                          pidext     => v_numlineaf,
                                                                          pcestado   => 4,
                                                                          pcvalidado => NULL,
                                                                          psseguro   => NULL,
                                                                          pidexterno => NULL,
                                                                          pncarga    => NULL,
                                                                          pnsinies   => NULL,
                                                                          pntramit   => NULL,
                                                                          psperson   => NULL,
                                                                          pnrecibo   => NULL);

                  vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea_error(psproces  => psproces,
                                                                                pnlinea   => v_numlineaf,
                                                                                pnerror   => v_numlineaf,
                                                                                pctipo    => 4,
                                                                                pcerror   => 9901197,
                                                                                ptmensaje => 9901197);

               END IF;
               --
               COMMIT;
            END IF;
            --

         END LOOP;
      END;

      RETURN 0;
      p_controlar_error(2, 4, NULL);

   EXCEPTION

      WHEN OTHERS THEN
         vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces   => psproces,
                                                                 pnlinea    => v_numlineaf,
                                                                 pctipo     => 21,
                                                                 pidint     => v_numlineaf,
                                                                 pidext     => v_numlineaf,
                                                                 pcestado   => 5,
                                                                 pcvalidado => NULL,
                                                                 psseguro   => NULL,
                                                                 pidexterno => NULL,
                                                                 pncarga    => NULL,
                                                                 pnsinies   => NULL,
                                                                 pntramit   => NULL,
                                                                 psperson   => NULL,
                                                                 pnrecibo   => NULL);

         vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea_error(psproces  => psproces,
                                                                       pnlinea   => v_numlineaf,
                                                                       pnerror   => v_numlineaf,
                                                                       pctipo    => 1,
                                                                       pcerror   => 9904148,
                                                                       ptmensaje => 9904148);
         p_tab_error(f_sysdate,
                     f_user,
                     'PAC_CARGA_CALIFICACION_REACOEX.F_CARGA_CALIFICACION_REACOEX',
                     vpasexec,
                     'Error creando la tabla: ' ||
                     dbms_utility.format_error_backtrace,
                     SQLERRM || dbms_utility.format_error_backtrace);
         RETURN 107914;

   END f_carga_calificacion_reacoex;

END pac_carga_calificacion_reacoex;

/

  GRANT EXECUTE ON "AXIS"."PAC_CARGA_CALIFICACION_REACOEX" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CARGA_CALIFICACION_REACOEX" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CARGA_CALIFICACION_REACOEX" TO "PROGRAMADORESCSI";
