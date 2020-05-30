CREATE OR REPLACE PACKAGE BODY pac_coda
AS
/******************************************************************************
   NOMBRE:       AXIS.PAC_CODA
   PROPSITO:    Tratamiento de los ficheros CODA

   REVISIONES:
   Ver        Fecha        Autor             Descripcin
   ---------  ----------  ---------------  ------------------------------------
   1.0        12/02/2009   JTS                1. Creacin del package.
   2.0        25/06/2009   SMC                2. BUG 10500
   3.0        31/07/2009   ASN                3. Bug 10019
   4.0        16/09/2009   JTS                4. 11166: APR - Tratamiento de fichero CODA
   5.0        25/09/2009   XPL                5. 0011208: APR - pago parcial de recibos
   6.0        26/10/2009   XPL                6. 0011564: 0011564: APR - errore en al procesar lineas CODA
   7.0        10/12/2009   XPL                7. 0012214: coda file 26/10/09
   8.0        12/02/2009   FAL                8. 0013150: APR - Error al buscar polizas en el coda
   9.0        16/02/2010   ASN                9. 0013163: APR - la fecha de cobro en los recibos del CODA
  10.0        24/03/2010   FAL               10. 0013163: APR - la fecha de cobro en los recibos del CODA
  11.0        25/03/2010   XPL               11. 0013448: APR - APREXT02 - Modificacion del Coda
  12.0        16/04/2010   XPL               12. 0013925: APR902 - homogeneizar el uso de detmovrecibo
  13.0        04/06/2010   XPL               13. 14805: APR701 - Problemes amb el procs CODA
  14.0        31/05/2010   PFA               14. 14750: ENSA101 - Reproceso de procesos ya existentes
  15.0        29/06/2010   DRA               15. 0016130: CRT - Error informando el codigo de proceso en carga
  16.0        20/03/2013   AFM               16. 0025803: RSA001 - Ampliar los decimales que utiliza iAXIS
  17.0        14/05/2013   DCG               17. 0026959: RSA701-Informar correctamente los importes de los cobros parciales en multimoneda.
  18.0        25/06/2013   RCL               18. 0024697: Canvi mida camp sseguro
  19.0        24/05/2019   ECP               19. IAXIS-3592. Proceso de terminacin por no pago
  20.0        16/07/2019   JLTS              20. IAXIS-4153. Se ingresan los campos nreccaj y cmreca en la funcin f_get_detmovrecibos
  21.0        10/10/2019   ECP               21. IAXIS-5149. Verificacin por qu no se esta ejecutando el proceso de cancelacin por no pago.
  22.0        06/03/2020   ECP               22. IAXIS-13059. Error reincidente en detalle de cancelación combinado con recaudo
******************************************************************************/

   /*************************************************************************
      Extrae los datos del fichero CODA y los inserta en DEVBANREC_CODA
      param in  p_nombre    : nombre del fichero a leer
      param in  p_path      : path del fichero a leer
      param in out p_sproces   : Id. del proceso
      return                : 0.-    OK
                              otro.- error
   *************************************************************************/
   FUNCTION f_lee_fichero (
      p_nombre    IN       VARCHAR2,
      p_path      IN       VARCHAR2,
      p_cproces   IN       NUMBER,                 -- BUG16130:DRA:15/10/2010
      p_sproces   IN OUT   NUMBER
   )                              --Bug 14750-PFA-31/05/2010- psproces IN OUT
      RETURN NUMBER
   IS
      v_file          UTL_FILE.file_type;
      v_line          VARCHAR2 (150);
      v_indice        NUMBER (1)                 := 0;
      v_sdevolu       NUMBER (8);
      v_nnumlin       NUMBER (5);
      v_tnomfile      VARCHAR2 (100)             := p_nombre;
      v_fproces       DATE                       := f_sysdate;
      v_cusuario      VARCHAR2 (50)              := f_user;
      v_cbanco        NUMBER (3);
      v_tdestino      VARCHAR2 (26);
      v_cbancar1      VARCHAR2 (35);
      v_fultsald      DATE;
      v_ttitular      VARCHAR2 (35);
      v_nnumfile      NUMBER (4);
      v_csigno        NUMBER (1);
      v_iimporte      vdetrecibos.itotalr%TYPE;
                      -- 25803: RSA001 - Ampliar los decimales NUMBER(12, 3);
      v_fecmov        DATE;
      v_fefecto       DATE;
      v_cbancar2      VARCHAR2 (37);
      v_tpagador      VARCHAR2 (105);
      v_tdescrip      VARCHAR2 (105);
      v_nnumrec       VARCHAR2 (8);
      v_npoliza       VARCHAR2 (12);
      v_sseguro       NUMBER;
      v_nnumrec_tmp   NUMBER (10);
      v_digitc        NUMBER (2);
      v_ctiporeg      NUMBER (1);
      v_fmovrec       DATE;
      v_ctipban       NUMBER (1);
      v_context       VARCHAR2 (200);
      v_cempres       NUMBER (2);
      v_cdelega       NUMBER (8);
      v_reg0          NUMBER (1)                 := 0;
      v_reg1          NUMBER (1)                 := 0;
      v_reg21         NUMBER (1)                 := 0;
      v_reg23         NUMBER (1)                 := 0;
      v_reg32         NUMBER (1)                 := 0;
      v_error         NUMBER (9);
      v_numerr        NUMBER (9);
      v_nprolin       NUMBER;
      wfmovini        DATE;                  --BUG 0013163 - FAL - 24/03/2010
      wsmovrec        NUMBER;                --BUG 0013163 - FAL - 24/03/2010
      v_reference     VARCHAR2 (600);

      CURSOR c_recibos
      IS
         SELECT d.ROWID, d.nnumrec, d.fmovrec, d.cbanco, d.ctiporeg
           FROM devbanrec_coda d
          WHERE d.sdevolu = v_sdevolu AND d.nnumrec IS NOT NULL;

      FUNCTION p_guardardatos
         RETURN NUMBER
      IS
         v_count     NUMBER (4);
         v_nnumord   NUMBER (10);
      BEGIN
         IF v_nnumrec IS NOT NULL
         THEN
            IF v_csigno = 0
            THEN
               v_ctiporeg := 3;
            ELSE
               v_ctiporeg := 4;
            END IF;

            BEGIN
               SELECT SUBSTR (f_nombre (t.sperson, 1, s.cagente), 0, 34)
                 INTO v_tpagador
                 FROM tomadores t, seguros s
                WHERE s.sseguro = v_sseguro AND s.sseguro = t.sseguro;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  v_tdescrip := v_npoliza;
                  v_tpagador := NULL;

                  --v_nnumrec := NULL;
                  IF v_csigno = 0
                  THEN
                     v_ctiporeg := 1;
                  ELSE
                     v_ctiporeg := 2;
                  END IF;
            END;

            v_fmovrec := f_sysdate;
         ELSE
            SELECT COUNT (*)
              INTO v_count
              FROM vdetrecibos
             WHERE nrecibo IN (
                      SELECT mov.nrecibo
                        FROM movrecibo mov,
                             (SELECT   MAX (smovrec) smovrec, nrecibo
                                  FROM movrecibo
                                 WHERE nrecibo IN (
                                          SELECT nrecibo
                                            FROM recibos
                                           WHERE sseguro IN (
                                                    SELECT sseguro
                                                      FROM tomadores
                                                     WHERE sperson IN (
                                                              SELECT sperson
                                                                FROM per_detper
                                                               WHERE UPPER
                                                                        (LTRIM
                                                                            (RTRIM
                                                                                (   tapelli1
                                                                                 || '%'
                                                                                 || tapelli2
                                                                                 || '%'
                                                                                 || tnombre,
                                                                                 '%'
                                                                                ),
                                                                             ' '
                                                                            )
                                                                        ) LIKE
                                                                           '%'
                                                                        || v_tpagador
                                                                        || '%')))
                              GROUP BY nrecibo) sel
                       WHERE mov.smovrec = sel.smovrec AND mov.cestrec = 0)
               AND itotalr = v_iimporte;

            IF v_count = 1
            THEN
               SELECT nrecibo
                 INTO v_nnumrec
                 FROM vdetrecibos
                WHERE nrecibo IN (
                         SELECT mov.nrecibo
                           FROM movrecibo mov,
                                (SELECT   MAX (smovrec) smovrec, nrecibo
                                     FROM movrecibo
                                    WHERE nrecibo IN (
                                             SELECT nrecibo
                                               FROM recibos
                                              WHERE sseguro IN (
                                                       SELECT sseguro
                                                         FROM tomadores
                                                        WHERE sperson IN (
                                                                 SELECT sperson
                                                                   FROM per_detper
                                                                  WHERE UPPER
                                                                           (LTRIM
                                                                               (RTRIM
                                                                                   (   tapelli1
                                                                                    || '%'
                                                                                    || tapelli2
                                                                                    || '%'
                                                                                    || tnombre,
                                                                                    '%'
                                                                                   ),
                                                                                ' '
                                                                               )
                                                                           ) LIKE
                                                                              '%'
                                                                           || v_tpagador
                                                                           || '%')))
                                 GROUP BY nrecibo) sel
                          WHERE mov.smovrec = sel.smovrec AND mov.cestrec = 0)
                  AND itotalr = v_iimporte;

               IF v_csigno = 0
               THEN
                  v_ctiporeg := 3;
               ELSE
                  v_ctiporeg := 4;
               END IF;

               v_fmovrec := f_sysdate;
            ELSE
               IF v_csigno = 0
               THEN
                  v_ctiporeg := 1;
               ELSE
                  v_ctiporeg := 2;
               END IF;

               v_fmovrec := NULL;
            END IF;
         END IF;

         v_nnumord := NULL;

         SELECT MAX (nnumord) + 1
           INTO v_nnumord
           FROM devbanrec_coda dev
          WHERE dev.sdevolu = v_sdevolu
            AND dev.nnumlin = v_nnumlin
            AND RTRIM (LTRIM (dev.cbancar1)) = RTRIM (LTRIM (v_cbancar1));

         IF v_nnumord IS NULL
         THEN
            v_nnumord := 1;
         END IF;

         --p_tab_error(f_sysdate, f_user, 'PAC_CODA.F_LEE_FICHERO.P_GUARDARDATOS', 0, 'Insert',
         --            v_sdevolu || '#' || v_nnumlin || '#' || v_cbancar1 || '#' || v_nnumord);

         --XPL bug 0011564 26/10/2009 inici
         IF v_cbancar2 IS NOT NULL
         THEN
            IF v_cbancar2 = '0'
            THEN
               v_tdescrip := 'CHEQUE';

               IF v_csigno = '1'
               THEN
                  v_tdescrip := v_tdescrip || ' / Payment';
               END IF;
            END IF;

            BEGIN
               INSERT INTO devbanrec_coda
                           (sdevolu, nnumlin, tnomfile, fproces,
                            cusuario, cbanco, tdestino,
                            cbancar1, fultsald,
                            ttitular, nnumfile, csigno, iimporte,
                            fecmov, fefecto, cbancar2,
                            tpagador,
                            tdescrip, nnumrec,
                            ctiporeg, fmovrec, nnumord, referencia
                           )
                    VALUES (v_sdevolu, v_nnumlin, v_tnomfile, v_fproces,
                            v_cusuario, v_cbanco, v_tdestino,
                            RTRIM (LTRIM (v_cbancar1)), v_fultsald,
                            v_ttitular, v_nnumfile, v_csigno, v_iimporte,
                            v_fecmov, v_fefecto, v_cbancar2,
                            NVL (v_tpagador, v_tdescrip),
                            NVL (v_tdescrip, v_tpagador), v_nnumrec,
                            v_ctiporeg, v_fmovrec, v_nnumord, v_reference
                           );
-- XPL 04/06/2010,aadir columna referencia bug 14805: APR701 - Problemes amb el procs CODA
            EXCEPTION
               WHEN OTHERS
               THEN
                  p_tab_error
                         (f_sysdate,
                          f_user,
                          'PAC_CODA.F_LEE_FICHERO.P_GUARDARDATOS Insertando',
                          0,
                          SQLERRM,
                          SQLCODE
                         );
            END;
         END IF;

         --XPL bug 0011564 26/10/2009 fi
         v_tpagador := NULL;
         RETURN 0;
      EXCEPTION
         WHEN OTHERS
         THEN
            p_tab_error (f_sysdate,
                         f_user,
                         'PAC_CODA.F_LEE_FICHERO.P_GUARDARDATOS',
                         1,
                         SQLERRM,
                         SQLCODE
                        );
            p_tab_error (f_sysdate,
                         f_user,
                         'PAC_CODA.F_LEE_FICHERO.P_GUARDARDATOS',
                         2,
                            'sproces='
                         || v_fproces
                         || 'nomfile='
                         || v_tnomfile
                         || 'nnumrec='
                         || v_nnumrec,
                         0
                        );
            RETURN 108468;
      END p_guardardatos;
   BEGIN
      v_context := f_parinstalacion_t ('CONTEXT_USER');
      v_cempres :=
             pac_contexto.f_contextovalorparametro (v_context, 'IAX_EMPRESA');
      v_cdelega :=
              pac_contexto.f_contextovalorparametro (v_context, 'IAX_AGENTE');
      p_procesini (f_user, v_cempres, 'CODA', 'Ficheros CODA', v_sdevolu);
      p_sproces := v_sdevolu;
      v_file := UTL_FILE.fopen (p_path, p_nombre, 'r');

      WHILE v_indice = 0
      LOOP
         BEGIN
            v_nnumrec := NULL;
            UTL_FILE.get_line (v_file, v_line);

            --BUG 10500 - Smartinez - 25/06/2009
            IF SUBSTR (v_line, 0, 1) = '0'
            THEN
               IF v_reg0 = 1 AND v_reg21 = 1
               THEN
                  v_numerr := p_guardardatos;

                  IF v_numerr <> 0
                  THEN
                     RETURN v_numerr;
                  END IF;
               END IF;

               v_reg1 := 0;
               v_reg21 := 0;
               v_reg23 := 0;
               v_reg32 := 0;
               v_tdestino := LTRIM (RTRIM (SUBSTR (v_line, 35, 26), ' '), ' ');
               v_cbanco := SUBSTR (v_line, 12, 3);
               v_reg0 := 1;
            ELSIF SUBSTR (v_line, 0, 1) = '1'
            THEN
               IF SUBSTR (v_line, 2, 1) = '0' OR SUBSTR (v_line, 2, 1) = ' '
               THEN
                  v_cbancar1 := SUBSTR (v_line, 6, 12);
                  v_ctipban := 0;
               ELSIF SUBSTR (v_line, 2, 1) = '1'
               THEN
                  v_cbancar1 := SUBSTR (v_line, 6, 34);
                  v_ctipban := 1;
               ELSIF SUBSTR (v_line, 2, 1) = '2'
               THEN
                  v_cbancar1 := SUBSTR (v_line, 6, 31);
                  v_ctipban := 2;
               ELSIF SUBSTR (v_line, 2, 1) = '3'
               THEN
                  v_cbancar1 := SUBSTR (v_line, 6, 34);
                  v_ctipban := 3;
               END IF;

               v_fultsald := TO_DATE (SUBSTR (v_line, 59, 6), 'DDMMYY');
               v_ttitular := LTRIM (RTRIM (SUBSTR (v_line, 65, 26), ' '), ' ');
               v_nnumfile := SUBSTR (v_line, 126, 3);
               v_reg1 := 1;
            ELSIF SUBSTR (v_line, 0, 2) = '21'
            THEN
               IF v_reg21 = 1
               THEN
                  v_numerr := p_guardardatos;

                  IF v_numerr <> 0
                  THEN
                     RETURN v_numerr;
                  END IF;
               END IF;

               v_reg23 := 0;
               v_reg32 := 0;
               v_nnumlin := SUBSTR (v_line, 3, 4);
               v_csigno := SUBSTR (v_line, 32, 1);
               v_iimporte := SUBSTR (v_line, 33, 15) / 1000;
               v_reference := SUBSTR (v_line, 66, 116);
-- XPL 04/06/2010,aadir columna referencia bug 14805: APR701 - Problemes amb el procs CODA

               IF SUBSTR (v_line, 48, 6) = '000000'
               THEN
                  v_fecmov := NULL;
               ELSE
                  v_fecmov := TO_DATE (SUBSTR (v_line, 48, 6), 'DDMMYY');
               END IF;

               IF SUBSTR (v_line, 62, 1) = '1'
               THEN
                  v_nnumrec_tmp := SUBSTR (v_line, 66, 10);
                  v_digitc := SUBSTR (v_line, 76, 2);

                  BEGIN
                     v_nnumrec := LTRIM (RTRIM (SUBSTR (v_line, 99, 8)));
                     v_nnumrec := TO_NUMBER (v_nnumrec);
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        v_nnumrec := NULL;
                  END;

                  v_npoliza := LTRIM (RTRIM (SUBSTR (v_line, 84, 12)));

                  BEGIN
                     SELECT sseguro
                       INTO v_sseguro
                       FROM seguros
                      WHERE npoliza = TO_NUMBER (NVL (v_npoliza, -1));
                  EXCEPTION
                     WHEN NO_DATA_FOUND
                     THEN
                        BEGIN
                           SELECT sseguro
                             INTO v_sseguro
                             FROM recibos
                            WHERE nrecibo = TO_NUMBER (NVL (v_nnumrec, -1));
                        EXCEPTION
                           WHEN NO_DATA_FOUND
                           THEN
                              BEGIN
                                 SELECT MAX (sseguro)
                                   INTO v_sseguro
                                   FROM cnvpolizas
                                  WHERE polissa_ini = NVL (v_npoliza, -1);
                              EXCEPTION
                                 WHEN NO_DATA_FOUND
                                 THEN
                                    v_sseguro := NULL;
                              END;
                        END;
                     WHEN OTHERS
                     THEN
                        v_npoliza := NULL;
                        v_sseguro := NULL;
                  END;

                  IF v_nnumrec = 0
                  THEN
                     v_nnumrec := NULL;
                  END IF;
               END IF;

               --Fi BUG 10500 - Smartinez - 25/06/2009
               v_fefecto := TO_DATE (SUBSTR (v_line, 116, 6), 'DDMMYY');
               v_cbancar2 := '0';
               v_reg21 := 1;
            ELSIF SUBSTR (v_line, 0, 2) = '22'
            THEN
               v_tpagador := NVL (v_tpagador, v_npoliza);
               v_tdescrip := NVL (v_tdescrip, v_nnumrec);
            ELSIF SUBSTR (v_line, 0, 2) = '23'
            THEN
               IF v_ctipban = 0
               THEN
                  v_cbancar2 := SUBSTR (v_line, 11, 12);
               ELSIF v_ctipban = 1
               THEN
                  v_cbancar2 := SUBSTR (v_line, 11, 34);
               ELSIF v_ctipban = 2
               THEN
                  v_cbancar2 := SUBSTR (v_line, 11, 31);
               ELSIF v_ctipban = 3
               THEN
                  v_cbancar2 := SUBSTR (v_line, 11, 34);
               END IF;

               v_tpagador := LTRIM (RTRIM (SUBSTR (v_line, 48, 35), ' '), ' ');
               v_tpagador := NVL (v_tpagador, v_npoliza);
               v_reg23 := 1;
            ELSIF SUBSTR (v_line, 0, 2) = '32'
            THEN
               v_tdescrip :=
                           LTRIM (RTRIM (SUBSTR (v_line, 11, 105), ' '), ' ');
               v_tdescrip := NVL (v_tdescrip, v_nnumrec);
               v_reg32 := 1;
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               IF v_reg21 = 1
               THEN
                  v_numerr := p_guardardatos;
                  v_tpagador := NULL;

                  IF v_numerr <> 0
                  THEN
                     RETURN v_numerr;
                  END IF;
               END IF;

               v_indice := 1;
         END;
      END LOOP;

      UTL_FILE.fclose (v_file);

      FOR i IN c_recibos
      LOOP
         --BUG 0013163 - FAL - 24/03/2010 - Recupera fecha ini movimiento recibo del ultimo movimiento pendiente
         BEGIN
            SELECT fmovini, smovrec
              INTO wfmovini, wsmovrec
              FROM movrecibo
             WHERE nrecibo = i.nnumrec AND cestrec = 0 AND fmovfin IS NULL;
         EXCEPTION
            WHEN OTHERS
            THEN
               wfmovini := NULL;
               wsmovrec := NULL;
         END;

         --Fi BUG 0013163 - FAL - 24/03/2010
         IF i.ctiporeg IN (1, 2)
         THEN
            UPDATE devbanrec_coda
               SET fmovrec = NULL,
                   nnumrec = NULL,
                   tdescrip = tdescrip || ' // ' || nnumrec
             WHERE ROWID = i.ROWID;
         ELSIF i.ctiporeg = 3
         THEN                                              -- cobro del recibo
            --BUG 0013163 - FAL - 24/03/2010
            IF     wfmovini > v_fultsald
               AND wfmovini IS NOT NULL
               AND wsmovrec IS NOT NULL
            THEN
               UPDATE movrecibo
                  SET fmovini = v_fultsald
                WHERE smovrec = wsmovrec;
            END IF;

            --Fi BUG 0013163 - FAL - 24/03/2010
            v_error :=
               pac_gestion_rec.f_cobro_recibo (v_cempres,
                                               i.nnumrec,
                                               v_fultsald,
                                               NULL,   -- Bug 13163 (fultsald)
                                               NULL,
                                               i.cbanco,
                                               v_cdelega
                                              );
                                        -- Bug 10019 (aadimos ctipcob = NULL)

            IF v_error = 0
            THEN
               UPDATE devbanrec_coda
                  SET fmovrec = f_sysdate
                WHERE ROWID = i.ROWID;
            ELSE
               v_error :=
                  f_proceslin
                            (v_sdevolu,
                             f_axis_literales (v_error,
                                               pac_md_common.f_get_cxtidioma
                                              ),
                             i.nnumrec,
                             v_nprolin
                            );

               UPDATE devbanrec_coda
                  SET fmovrec = NULL,
                      nnumrec = NULL,
                      tdescrip = tdescrip || ' // ' || nnumrec,
                      ctiporeg = 1
                WHERE ROWID = i.ROWID;
            END IF;
         ELSIF i.ctiporeg = 4
         THEN
            --BUG 0013163 - FAL - 24/03/2010
            IF     wfmovini > v_fultsald
               AND wfmovini IS NOT NULL
               AND wsmovrec IS NOT NULL
            THEN
               UPDATE movrecibo
                  SET fmovini = v_fultsald
                WHERE smovrec = wsmovrec;
            END IF;

            --Fi BUG 0013163 - FAL - 24/03/2010
            v_error :=
               pac_gestion_rec.f_cobro_recibo (v_cempres,
                                               i.nnumrec,
                                               v_fultsald,
                                               NULL,   -- Bug 13163 (fultsald)
                                               NULL,
                                               i.cbanco,
                                               v_cdelega,
                                               NULL
                                              );
                                        -- Bug 10019 (aadimos ctipcob = NULL)

            IF v_error = 0
            THEN
               UPDATE devbanrec_coda
                  SET fmovrec = f_sysdate
                WHERE ROWID = i.ROWID;

               v_error :=
                  pac_gestion_rec.f_anula_recibo (i.nnumrec, v_fultsald, NULL);
                                                       -- Bug 13163 (fultsald)

               IF v_error = 0
               THEN
                  UPDATE devbanrec_coda
                     SET fmovrec = f_sysdate
                   WHERE ROWID = i.ROWID;
               ELSE
                  v_error :=
                     f_proceslin
                            (v_sdevolu,
                             f_axis_literales (v_error,
                                               pac_md_common.f_get_cxtidioma
                                              ),
                             i.nnumrec,
                             v_nprolin
                            );

                  UPDATE devbanrec_coda
                     SET fmovrec = NULL,
                         nnumrec = NULL,
                         tdescrip = tdescrip || ' // ' || nnumrec,
                         ctiporeg = 2
                   WHERE ROWID = i.ROWID;
               END IF;
            ELSE
               UPDATE devbanrec_coda
                  SET fmovrec = NULL,
                      nnumrec = NULL,
                      tdescrip = tdescrip || ' // ' || nnumrec,
                      ctiporeg = 2
                WHERE ROWID = i.ROWID;
            END IF;
         END IF;
      END LOOP;

      p_procesfin (v_sdevolu, 0);
      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         IF UTL_FILE.is_open (v_file)
         THEN
            UTL_FILE.fclose (v_file);
         END IF;

         p_procesfin (v_sdevolu, 1);
         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_CODA.F_LEE_FICHERO',
                      1,
                      ' Error ' || v_error || 'Error = ' || SQLERRM,
                      SQLCODE
                     );
         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_CODA.F_LEE_FICHERO',
                      1,
                      ' Error ',
                      p_path
                     );
         RETURN 108468;
   END f_lee_fichero;

   /*************************************************************************
      Obtiene la informacin de un proceso de extraccion de fichero CODA
      param in  p_sproces   : Id. del proceso
      param out p_tnomfile  : Nombre del fichero
      param out p_fproces   : Fecha del proceso
      param out p_icobrado  : Importe total de los recibos cobrados
      param out p_iimpago   : Importe total de los recibos impagados
      param out p_ipendcob  : Importe total de los recibos pendientes de pago
      param out p_ipenimp   : Importe total de los recibos pendientes de impagar
      param out p_tbanco    : Descripcin del banco
      return                : 0.-    OK
                              otro.- error
   *************************************************************************/
   FUNCTION f_get_datos_proceso (
      p_sproces    IN       NUMBER,
      p_tnomfile   OUT      VARCHAR2,
      p_fproces    OUT      DATE,
      p_icobrado   OUT      NUMBER,
      p_iimpago    OUT      NUMBER,
      p_ipendcob   OUT      NUMBER,
      p_ipenimp    OUT      NUMBER,
      p_tbanco     OUT      VARCHAR2
   )
      RETURN NUMBER
   IS
   BEGIN
      SELECT   tnomfile, fproces, cbanco, SUM (icobrado), SUM (iimpago),
               SUM (ipendcob), SUM (ipenimp)
          INTO p_tnomfile, p_fproces, p_tbanco, p_icobrado, p_iimpago,
               p_ipendcob, p_ipenimp
          FROM (SELECT   tnomfile, fproces, cbanco, SUM (iimporte) icobrado,
                         0 iimpago, 0 ipendcob, 0 ipenimp
                    FROM devbanrec_coda
                   WHERE sdevolu = p_sproces AND ctiporeg = 3
                GROUP BY tnomfile, fproces, cbanco
                UNION
                SELECT   tnomfile, fproces, cbanco, 0 icobrado,
                         SUM (iimporte) iimpago, 0 ipendcob, 0 ipenimp
                    FROM devbanrec_coda
                   WHERE sdevolu = p_sproces AND ctiporeg = 4
                GROUP BY tnomfile, fproces, cbanco
                UNION
                SELECT   tnomfile, fproces, cbanco, 0 icobrado, 0 iimpago,
                         SUM (iimporte) ipendcob, 0 ipenimp
                    FROM devbanrec_coda
                   WHERE sdevolu = p_sproces AND ctiporeg = 1
                GROUP BY tnomfile, fproces, cbanco
                UNION
                SELECT   tnomfile, fproces, cbanco, 0 icobrado, 0 iimpago,
                         0 ipendcob, SUM (iimporte) ipenimp
                    FROM devbanrec_coda
                   WHERE sdevolu = p_sproces AND ctiporeg = 2
                GROUP BY tnomfile, fproces, cbanco)
      GROUP BY tnomfile, fproces, cbanco;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_CODA.f_get_datos_proceso',
                      1,
                      'Error = ' || SQLERRM,
                      SQLCODE
                     );
         RETURN 152715;
   END f_get_datos_proceso;

   /*************************************************************************
      Obtiene los registros de un proceso de extraccion de fichero CODA segn
      los parmetros de entrada
      param in  p_sproces   : Id. del proceso
      param in  p_fechaini  : Fecha inicio
      param in  p_fechafin  : Fecha fin
      param in  p_ctipreg   : Tipo registro
      param in  p_nrecibo   : Numero de recibo
      param in  p_tnombre   : Nombre pagador
      param in  p_tdescrip  : Descripcion
      param in  p_cbanco    : Codigo del banco
      param out p_refcursor : Cursor resultante de la consulta
      return                : 0.-    OK
                              otro.- error
   *************************************************************************/
   FUNCTION f_get_coda (
      p_sproces     IN       NUMBER,
      p_fechaini    IN       DATE,
      p_fechafin    IN       DATE,
      p_ctipreg     IN       NUMBER,
      p_nrecibo     IN       NUMBER,
      p_tnombre     IN       VARCHAR2,
      p_tdescrip    IN       VARCHAR2,
      p_cbanco      IN       NUMBER,
      p_refcursor   OUT      sys_refcursor
   )
      RETURN NUMBER
   IS
      v_context   VARCHAR2 (100);
      v_cidioma   NUMBER (2);
   BEGIN
      v_context := f_parinstalacion_t ('CONTEXT_USER');
      v_cidioma :=
              pac_contexto.f_contextovalorparametro (v_context, 'IAX_IDIOMA');

      OPEN p_refcursor FOR
         SELECT   d.fproces, d.sdevolu, d.cbancar1, d.nnumlin, d.tpagador,
                  d.cbanco, d.nnumrec, d.ctiporeg, v.tatribu ttiporeg,
                  d.tdescrip,
                  DECODE (d.csigno,
                          0, d.iimporte,
                          (d.iimporte * (-1))
                         ) iimporte,
                  NVL (ag.cagecob, rg.cagecob) cagecob, d.nnumord, d.ipagado,
                  d.referencia, d.fultsald
             FROM devbanrec_coda d,
                  detvalores v,
                  agentescob ag,
                  recgestion rg
            WHERE d.sdevolu = NVL (p_sproces, d.sdevolu)
              AND d.fproces BETWEEN NVL (p_fechaini, d.fproces - 1)
                                AND NVL (p_fechafin, d.fproces + 1)
              AND d.ctiporeg = NVL (p_ctipreg, d.ctiporeg)
              AND (p_nrecibo IS NULL OR d.nnumrec = p_nrecibo)
              AND (   p_tnombre IS NULL
                   OR LOWER (d.tpagador) LIKE '%' || LOWER (p_tnombre) || '%'
                  )
              AND (   p_tdescrip IS NULL
                   OR LOWER (d.tdescrip) LIKE '%' || LOWER (p_tdescrip) || '%'
                  )
              AND d.cbanco = NVL (p_cbanco, d.cbanco)
              AND v.cvalor = 800015
              AND v.cidioma = v_cidioma
              AND v.catribu = d.ctiporeg
              AND d.nnumrec = ag.nrecibo(+)
              AND d.nnumrec = rg.nrecibo(+)
         ORDER BY d.sdevolu, d.cbancar1, d.nnumlin, d.nnumord;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         IF p_refcursor%ISOPEN
         THEN
            CLOSE p_refcursor;
         END IF;

         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_CODA.f_get_coda',
                      1,
                      'Error = ' || SQLERRM,
                      SQLCODE
                     );
         RETURN 152715;
   END f_get_coda;

   FUNCTION f_get_coda_detalle (
      p_sproces     IN       NUMBER,
      p_cbancar     IN       VARCHAR2,
      pnnumord      IN       NUMBER,
      pfultsald     IN       DATE,
      pnnumlin      IN       NUMBER,
      p_refcursor   OUT      sys_refcursor
   )
      RETURN NUMBER
   IS
      v_context   VARCHAR2 (100);
      v_cidioma   NUMBER (2);
   BEGIN
      v_context := f_parinstalacion_t ('CONTEXT_USER');
      v_cidioma :=
              pac_contexto.f_contextovalorparametro (v_context, 'IAX_IDIOMA');

      OPEN p_refcursor FOR
         SELECT   d.sdevolu, d.nnumlin, d.cbancar1, d.nrecibo, d.ctiporeg,
                  v.tatribu ttiporeg,
                  DECODE (d.csigno, 0, d.icoda, (d.icoda * (-1))) icoda,
                  d.nnumord, d.ipagado, d.ipendiente, d.fultsald, d.norden,
                  d.fmovrec
             FROM devbanrec_coda_detalle d, detvalores v
            WHERE d.sdevolu = NVL (p_sproces, d.sdevolu)
              AND v.cvalor = 800015
              AND v.cidioma = v_cidioma
              AND v.catribu = d.ctiporeg
              AND d.cbancar1 = p_cbancar
              AND d.nnumlin = pnnumlin
              AND d.fultsald = pfultsald
              AND d.nnumord = pnnumord
         ORDER BY d.norden;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         IF p_refcursor%ISOPEN
         THEN
            CLOSE p_refcursor;
         END IF;

         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_CODA.f_get_coda_detalle',
                      1,
                      'Error = ' || SQLERRM,
                      SQLCODE
                     );
         RETURN 152715;
   END f_get_coda_detalle;

   /*************************************************************************
      Obtiene todos los tomadores segun los parametros introducidos
      param in  p_tnombre   : Nombre del tomador
      param in  p_tdescrip  : Descripcion
      param in  p_numvia    : Numero de la via
      param in  p_cpostal   : Codigo postal
      param out p_refcursor : Cursor resultante de la consulta
      return                : 0.-    OK
                              otro.- error
   *************************************************************************/
   FUNCTION f_busca_tomadores (
      p_tnombre     IN       VARCHAR2,
      p_tdescrip    IN       VARCHAR2,
      p_numvia      IN       NUMBER,
      p_cpostal     IN       VARCHAR2,
      p_npoliza     IN       NUMBER,
      p_nrecibo     IN       NUMBER,
      p_refcursor   OUT      sys_refcursor
   )
      RETURN NUMBER
   IS
   BEGIN
      OPEN p_refcursor FOR
         SELECT   p.sperson,
                  p.tnombre || ' ' || p.tapelli1 || ' ' || p.tapelli2
                                                                     tnombre,
                  d.tnomvia || ' ' || d.nnumvia || ' ' || d.cpostal tdescrip
             FROM tomadores t,
                  per_detper p,
                  per_direcciones d,
                  seguros s,
                  recibos r,
                  movrecibo m
            WHERE s.sseguro = t.sseguro
              /*AND p.cagente = s.cagente   -- ff_agente_cpervisio(s.cagente)
              AND p.cagente = d.cagente*/
              AND t.sperson = p.sperson
              AND d.sperson = p.sperson
              AND d.cdomici = t.cdomici
              AND LOWER (tbuscar) LIKE
                                 '%' || LOWER (NVL (p_tnombre, tbuscar))
                                 || '%'
              AND LOWER (tnomvia) LIKE
                                '%' || LOWER (NVL (p_tdescrip, tnomvia))
                                || '%'
              AND NVL (nnumvia, 1) =
                     NVL (p_numvia, NVL (nnumvia, 1))
                                                  --FAL bug 0013150 12/02/2010
              AND cpostal = NVL (p_cpostal, cpostal)
              AND r.sseguro = s.sseguro
              AND r.fefecto >
                        ADD_MONTHS (f_sysdate, -24)
                                                  --XPL bug 0011564 26/10/2009
              AND s.npoliza = NVL (p_npoliza, s.npoliza)
              AND r.nrecibo = NVL (p_nrecibo, r.nrecibo)
              AND m.nrecibo = r.nrecibo
              AND m.fmovfin IS NULL
              AND m.cestrec IN (0, 1)
         /* AND s.cagente IN(SELECT cagente
                             FROM agentes_agente)*/
         GROUP BY p.sperson,
                  p.tnombre || ' ' || p.tapelli1 || ' ' || p.tapelli2,
                  d.tnomvia || ' ' || d.nnumvia || ' ' || d.cpostal;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         IF p_refcursor%ISOPEN
         THEN
            CLOSE p_refcursor;
         END IF;

         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_CODA.f_busca_tomadores',
                      1,
                      'Error = ' || SQLERRM,
                      SQLCODE
                     );
         RETURN 152715;
   END f_busca_tomadores;

   /*************************************************************************
      Obtiene los recibos en situacin pendiente de un tomador
      recibido por parmetro
      param in  p_sperson   : Id de persona
      param out p_refcursor : Cursor resultante de la consulta
      return                : 0.-    OK
                              otro.- error
   *************************************************************************/
   FUNCTION f_busca_recibos (
      p_sperson     IN       NUMBER,
      p_csigno      IN       NUMBER,
      pidioma       IN       NUMBER,
      p_refcursor   OUT      sys_refcursor
   )
      RETURN NUMBER
   IS
      vquery   VARCHAR2 (3000);
      vwhere   VARCHAR2 (3000);
   BEGIN
      IF p_csigno = 1
      THEN                                     --Impagats, han de ser extorns
         vwhere := ' and r.ctiprec = 9 ';
      END IF;

      vquery :=
            ' SELECT s.npoliza, r.nrecibo, r.fefecto, r.fvencim, v.itotalr,
                ff_desvalorfijo(8, '
         || pidioma
         || ', r.ctiprec) ttiprec, r.ctiprec,
                ff_desvalorfijo(1, '
         || pidioma
         || ', m.cestrec) testrec, m.cestrec
           FROM tomadores t, seguros s, recibos r, vdetrecibos v, movrecibo m
          WHERE t.sperson = '
         || p_sperson
         || '
            AND s.sseguro = t.sseguro
            AND t.sseguro = r.sseguro
            AND r.sseguro = r.sseguro
            AND r.nrecibo = v.nrecibo
            AND r.fefecto > ADD_MONTHS(f_sysdate, -24)
            AND m.nrecibo = r.nrecibo
            AND m.fmovfin IS NULL
            AND m.cestrec = 0 '
         || vwhere
         || '
         UNION
         SELECT s.npoliza, r.nrecibo, r.fefecto, r.fvencim, v.itotalr,
                ff_desvalorfijo(8, '
         || pidioma
         || ',r.ctiprec) ttiprec, r.ctiprec,
                ff_desvalorfijo(1, '
         || pidioma
         || ', m.cestrec) testrec, m.cestrec
           FROM tomadores t, seguros s, recibos r, vdetrecibos v, movrecibo m
          WHERE t.sperson = '
         || p_sperson
         || '
            AND s.sseguro = t.sseguro
            AND t.sseguro = r.sseguro
            AND r.sseguro = r.sseguro
            AND r.nrecibo = v.nrecibo
            AND r.fefecto > ADD_MONTHS(f_sysdate, -24)
            AND m.nrecibo = r.nrecibo
            AND m.smovrec = (SELECT MAX(mm.smovrec)
                               FROM movrecibo mm
                              WHERE mm.nrecibo = r.nrecibo
                                AND mm.cestrec = 1)
            AND m.cestrec = 1
            and rownum = 1 '
         || vwhere;

      OPEN p_refcursor FOR vquery;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         IF p_refcursor%ISOPEN
         THEN
            CLOSE p_refcursor;
         END IF;

         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_CODA.f_busca_recibos',
                      1,
                      'Error = ' || SQLERRM,
                      SQLCODE
                     );
         RETURN 152715;
   END f_busca_recibos;

   FUNCTION f_get_sumimpcobrados (pnrecibo IN NUMBER)
      RETURN NUMBER
   IS
      vobjectname   VARCHAR2 (500) := 'PAC_coda.f_get_sumimpcobrados';
      vparam        VARCHAR2 (500) := 'parmetros - NRECIBO:' || pnrecibo;
      pasexec       NUMBER (5)     := 1;
      vcount        NUMBER (5);
      vsmovrec      NUMBER;
      vnorden       NUMBER         := 0;
      vimporte      NUMBER;
   BEGIN
      SELECT MAX (smovrec)
        INTO vsmovrec
        FROM movrecibo
       WHERE nrecibo = pnrecibo AND cestrec = 0;

      SELECT SUM (iimporte)
        INTO vimporte
        FROM detmovrecibo
       WHERE nrecibo = pnrecibo AND smovrec = vsmovrec;

      RETURN vimporte;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      pasexec,
                      vparam,
                      'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM
                     );
         RETURN 0;
   --Error al llegir de la taula SIN_TRAMITA_DANO
   END f_get_sumimpcobrados;

   /*************************************************************************
      Cobra/impaga un recibo y lo asocia a la tabla de devoluciones,
      actualizando la tabla del CODA,
      con el nmero de recibo y su estado del registro.
      param in  p_sproces   : Id del proceso
      param in  p_nnumlin   : Numero de linea
      param in  p_cbancar1  : Cuenta bancaria destinataria
      param in  p_nrecibo   : Numeros de recibos
      param in  p_ok        : Confirmacin de accin
      param out p_redo      : Indica si se puede relanzar o no 0 ok 1 ko
      return                : 0.-    OK
                              otro.- error
   *************************************************************************/
   FUNCTION f_gestion_recibos (
      p_sproces    IN       NUMBER,
      p_nnumlin    IN       NUMBER,
      p_cbancar1   IN       VARCHAR2,
      p_nnumord    IN       NUMBER,
      p_nrecibo    IN       VARCHAR2,
      p_ok         IN       NUMBER DEFAULT NULL,
      p_redo       OUT      NUMBER
   )
      RETURN NUMBER
   IS
      v_rowid              ROWID;
      v_csigno             NUMBER (1);
      v_ctiporeg           NUMBER (1);
      v_nnumrec            NUMBER (8);
      v_cbanco             NUMBER (3);
      v_context            VARCHAR2 (20);
      v_cempres            NUMBER (3);
      v_cdelega            NUMBER (8);
      v_error              NUMBER (8);
      v_count              NUMBER (8);
      --
      v_index              NUMBER                   := 1;
      v_length             NUMBER;
      v_nrectmp            VARCHAR2 (20);
      v_act                CHAR;
      v_nnumord            NUMBER (3)               := 1;
      --Bug 9204-MCC-03/03/2009- Gestin recibos
      v_smovrec            movrecibo.smovrec%TYPE;
      v_impagos            NUMBER (10);
      v_flagimp            NUMBER                   := 0;
      v_imp                VARCHAR2 (500);
      v_import             NUMBER;
      vitotalr             NUMBER;
      vsdevolu             NUMBER;
      vnnumlin             NUMBER;
      vcbancar1            VARCHAR2 (34);
      vnnumord             NUMBER;
      v_sumaimpcobrados    NUMBER;
      pas                  NUMBER                   := 0;
      v_nnumordmax         NUMBER;
      v_importtotalpagat   NUMBER                   := 0;
      vimpcoda             NUMBER;
      v_fultsaldo          DATE;
      v_estreg             NUMBER;
      wfmovini             DATE;             --BUG 0013163 - FAL - 24/03/2010
      wsmovrec             NUMBER;           --BUG 0013163 - FAL - 24/03/2010
      v_referencia         VARCHAR2 (500);
      v_tpagador           VARCHAR2 (2000);
      v_icoda              NUMBER;
      v_norden             NUMBER;
      v_nordenpag          NUMBER;
      v_ipend              NUMBER;
      v_cont               NUMBER;
      v_imptemp            NUMBER;
      v_nrec               NUMBER;
      v_fefecto            DATE;

      CURSOR cur_recibos (vpnrecibo IN NUMBER)
      IS
         SELECT r.sseguro, r.nrecibo, r.fefecto + NVL (ndiaavis, 0) ffejecu,
                f_sysdate ffecalt, d.cactimp, 1 ctractat, 1 cmotivo,
                d.cmodelo ccarta, 0 nimpagad
           FROM recibos r, seguros s, prodreprec p, detprodreprec d
          WHERE r.sseguro = s.sseguro
            AND s.sproduc = p.sproduc
            AND p.finiefe <= r.fefecto
            AND (p.ffinefe IS NULL OR p.ffinefe > r.fefecto)
            AND d.sidprodp = p.sidprodp
            AND r.nrecibo = vpnrecibo;
     --FIN Bug 9204-MCC-03/03/2009- Gestin recibos
   --
   BEGIN
      v_norden := 0;
      pas := 1;
      v_context := f_parinstalacion_t ('CONTEXT_USER');
      v_cempres :=
             pac_contexto.f_contextovalorparametro (v_context, 'IAX_EMPRESA');
      v_cdelega :=
              pac_contexto.f_contextovalorparametro (v_context, 'IAX_AGENTE');

      IF p_sproces IS NULL OR p_nnumlin IS NULL OR p_cbancar1 IS NULL
      THEN
         RETURN 103135;
      END IF;

      SELECT ROWID, csigno, ctiporeg, nnumrec, cbanco, fefecto,
             referencia, iimporte, ctiporeg, fultsald
        INTO v_rowid, v_csigno, v_ctiporeg, v_nnumrec, v_cbanco, v_fefecto,
             v_referencia, v_icoda, v_ctiporeg, v_fultsaldo
        FROM devbanrec_coda
       WHERE sdevolu = p_sproces
         AND nnumlin = p_nnumlin
         AND RTRIM (LTRIM (cbancar1)) = RTRIM (LTRIM (p_cbancar1))
         AND nnumord = NVL (p_nnumord, 1);

      pas := 2;
      v_nnumord := p_nnumord;

      IF v_nnumrec IS NULL
      THEN
--
         pas := 3;
         v_length := LENGTH (p_nrecibo);
         pas := 4;

         WHILE v_index <= v_length
         LOOP
            v_act := SUBSTR (p_nrecibo, v_index, 1);
            pas := 5;

            IF v_act = ';' OR v_index = v_length
            THEN
--
               v_flagimp := 0;
               pas := 6;

               SELECT COUNT (*)
                 INTO v_count
                 FROM devbanrec_coda_detalle
                WHERE nrecibo = v_nrectmp;

               pas := 7;

               IF v_count = 0 OR (v_count > 0 AND NVL (p_ok, 0) = 1)
               THEN
                  pas := 88;

                  BEGIN
                     v_import := TO_NUMBER (v_imp);
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        v_import := TO_NUMBER (REPLACE (v_imp, '.', ','));
                  END;

                  SELECT COUNT (1), NVL (MAX (norden), 0) + 1
                    INTO v_cont, v_nordenpag
                    FROM devbanrec_coda_detalle
                   WHERE sdevolu = p_sproces
                     AND nnumlin = p_nnumlin
                     AND RTRIM (LTRIM (cbancar1)) = RTRIM (LTRIM (p_cbancar1))
                     AND nnumord = p_nnumord;

                  SELECT DECODE (v_csigno, 0, v_icoda, (v_icoda * (-1)))
                    INTO v_icoda
                    FROM DUAL;

                  pas := 99;

                  IF v_cont = 0
                  THEN
                     BEGIN
                        SELECT NVL (ipagado, 0)
                          INTO v_imptemp
                          FROM devbanrec_coda
                         WHERE sdevolu = p_sproces
                           AND nnumlin = p_nnumlin
                           AND RTRIM (LTRIM (cbancar1)) =
                                                    RTRIM (LTRIM (p_cbancar1))
                           AND nnumord = p_nnumord;
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           v_imptemp := 0;
                     END;

                     pas := 100;

                     IF v_imptemp > 0
                     THEN
                        v_ipend := NVL (v_icoda, 0) - NVL (v_imptemp, 0);

                        INSERT INTO devbanrec_coda_detalle
                                    (sdevolu, nnumlin,
                                     cbancar1, nnumord,
                                     fultsald, norden, csigno,
                                     nrecibo, icoda, ipagado, ipendiente,
                                     ctiporeg, fmovrec
                                    )
                             VALUES (p_sproces, p_nnumlin,
                                     RTRIM (LTRIM (p_cbancar1)), p_nnumord,
                                     v_fultsaldo, v_nordenpag, v_csigno,
                                     v_nrec, v_icoda, v_imptemp, v_ipend,
                                     v_ctiporeg, f_sysdate
                                    );

                        v_nordenpag := v_nordenpag + 1;
                     END IF;
                  END IF;

                  pas := 111;

                  SELECT NVL (SUM (ipagado), 0)
                    INTO v_ipend
                    FROM devbanrec_coda_detalle
                   WHERE sdevolu = p_sproces
                     AND nnumlin = p_nnumlin
                     AND RTRIM (LTRIM (cbancar1)) = RTRIM (LTRIM (p_cbancar1))
                     AND nnumord = p_nnumord;

                  v_ipend :=
                         NVL (v_icoda, 0)
                       - (NVL (v_ipend, 0) + NVL (v_import, 0));
                  pas := 122;

                  INSERT INTO devbanrec_coda_detalle
                              (sdevolu, nnumlin,
                               cbancar1, nnumord,
                               fultsald, norden, csigno, nrecibo,
                               icoda, ipagado, ipendiente, ctiporeg,
                               fmovrec
                              )
                       VALUES (p_sproces, p_nnumlin,
                               RTRIM (LTRIM (p_cbancar1)), p_nnumord,
                               v_fultsaldo, v_nordenpag, v_csigno, v_nrectmp,
                               v_icoda, v_import, v_ipend, v_ctiporeg,
                               f_sysdate
                              );

                  v_norden := v_nordenpag;
                  --

                  --  END IF;
                  pas := 9;

                  --BUG 0013163 - FAL - 24/03/2010 - Recupera fecha ini movimiento recibo del ultimo movimiento pendiente
                  BEGIN
                     SELECT fmovini, smovrec
                       INTO wfmovini, wsmovrec
                       FROM movrecibo
                      WHERE nrecibo = v_nrectmp
                        AND cestrec = 0
                        AND fmovfin IS NULL;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        wfmovini := NULL;
                        wsmovrec := NULL;
                  END;

                  --Fi BUG 0013163 - FAL - 24/03/2010
                  IF v_csigno = 0
                  THEN
                     ---   XPL 11208: APR - pago parcial de recibos afegir a detmovrecibo INICI---
                        --   IF NVL(p_ok, 0) <> 1 THEN
                     SELECT itotalr
                       INTO vitotalr
                       FROM vdetrecibos
                      WHERE nrecibo = v_nrectmp;

                     pas := 10;
                     pas := 11;
                     v_importtotalpagat := v_import + v_importtotalpagat;

                     IF vitotalr = v_import
                     THEN
                        pas := 12;
                        v_error :=
                           pac_coda.f_ins_detmovrecibo
                                               (NULL,
                                                NULL,
                                                v_nrectmp,
                                                v_import,
                                                v_fefecto,
                                                NULL, -- Bug 13163 (fultsaldo)
                                                f_user,
                                                p_sproces,
                                                p_nnumlin,
                                                p_cbancar1,
                                                p_nnumord
                                               );

                        --BUG 0013163 - FAL - 24/03/2010 - Recupera fecha ini movimiento recibo del ultimo movimiento pendiente
                        IF     wfmovini > v_fefecto
                           AND wfmovini IS NOT NULL
                           AND wsmovrec IS NOT NULL
                        THEN
                           UPDATE movrecibo
                              SET fmovini = v_fefecto
                            WHERE smovrec = wsmovrec;
                        END IF;

                        --Fi BUG 0013163 - FAL - 24/03/2010
                        v_error :=
                           pac_gestion_rec.f_cobro_recibo
                                                (v_cempres,
                                                 v_nrectmp,
                                                 v_fefecto,
                                                 NULL,
                                                 NULL,
                                                      -- Bug 13163 (fultsaldo)
                                                 v_cbanco,
                                                 v_cdelega,
                                                 0
                                                );
                                           -- Bug 10019 (aadimos ctipcob = 0)
                        pas := 13;
                     ELSIF v_import < vitotalr OR v_import > vitotalr
                     THEN
                        -- Bug 0013448 XPL 25/03/2010 S'afegeix l'or ja que si es paga ms de l'import al rebut tb el podem cobrar i fer
                        -- un apunt a detmovrecibo
                        v_error :=
                           pac_coda.f_ins_detmovrecibo
                                               (NULL,
                                                NULL,
                                                v_nrectmp,
                                                v_import,
                                                v_fefecto,
                                                NULL, -- Bug 13163 (fultsaldo)
                                                f_user,
                                                p_sproces,
                                                p_nnumlin,
                                                p_cbancar1,
                                                p_nnumord
                                               );
                        pas := 14;
                        v_sumaimpcobrados := f_get_sumimpcobrados (v_nrectmp);
                        pas := 15;

                        IF vitotalr <= v_sumaimpcobrados
                        THEN
                           -- Bug 0013448 XPL 25/03/2010 S'afegeix < ja que si es paga ms de l'import al rebut tb el podem cobrar
                           pas := 16;

                           --BUG 0013163 - FAL - 24/03/2010 - Recupera fecha ini movimiento recibo del ultimo movimiento pendiente
                           IF     wfmovini > v_fefecto
                              AND wfmovini IS NOT NULL
                              AND wsmovrec IS NOT NULL
                           THEN
                              UPDATE movrecibo
                                 SET fmovini = v_fefecto
                               WHERE smovrec = wsmovrec;
                           END IF;

                           pas := 166;
                           --Fi BUG 0013163 - FAL - 24/03/2010
                           v_error :=
                              pac_gestion_rec.f_cobro_recibo
                                                (v_cempres,
                                                 v_nrectmp,
                                                 v_fefecto,
                                                 NULL,
                                                 NULL,
                                                      -- Bug 13163 (fultsaldo)
                                                 v_cbanco,
                                                 v_cdelega,
                                                 0
                                                );
                                           -- Bug 10019 (aadimos ctipcob = 0)
                        END IF;
                     END IF;

                     pas := 17;

                     --   ELSE
                         --  v_error := 0;
                     --   END IF;
                     ---   XPL 11208: APR - pago parcial de recibos afegir a detmovrecibo FI---
                     IF v_error = 0
                     THEN
                        pas := 18;

                        UPDATE devbanrec_coda
                           SET fmovrec = f_sysdate
                         WHERE sdevolu = p_sproces
                           AND nnumlin = p_nnumlin
                           AND RTRIM (LTRIM (cbancar1)) =
                                                    RTRIM (LTRIM (p_cbancar1))
                           AND nnumord = v_nnumord;

                        UPDATE devbanrec_coda_detalle
                           SET fmovrec = f_sysdate,
                               nrecibo = v_nrectmp,
                               ipagado = v_import,
                               ctiporeg = 5
                         WHERE sdevolu = p_sproces
                           AND nnumlin = p_nnumlin
                           AND RTRIM (LTRIM (cbancar1)) =
                                                    RTRIM (LTRIM (p_cbancar1))
                           AND nnumord = v_nnumord
                           AND norden = v_norden;
                     ELSE
                        pas := 19;

                        DELETE      devbanrec_coda
                              WHERE sdevolu = p_sproces
                                AND nnumlin = p_nnumlin
                                AND RTRIM (LTRIM (cbancar1)) =
                                                    RTRIM (LTRIM (p_cbancar1))
                                AND nnumord > 1;

                        UPDATE devbanrec_coda
                           SET fmovrec = NULL,
                               nnumrec = NULL,
                               ctiporeg = 1
                         WHERE ROWID = v_rowid;

                        pas := 20;
                        p_redo := 1;
                        RETURN v_error;
                     END IF;

                     p_redo := 1;
                     pas := 21;
                  ELSE
                     pas := 22;

                     IF NVL (p_ok, 0) <> 1
                     THEN
                        --BUG 0013163 - FAL - 24/03/2010 - Recupera fecha ini movimiento recibo del ultimo movimiento pendiente
                        IF     wfmovini > v_fefecto
                           AND wfmovini IS NOT NULL
                           AND wsmovrec IS NOT NULL
                        THEN
                           UPDATE movrecibo
                              SET fmovini = v_fefecto
                            WHERE smovrec = wsmovrec;
                        END IF;

                        --Fi BUG 0013163 - FAL - 24/03/2010
                        v_error :=
                           pac_gestion_rec.f_cobro_recibo
                                                (v_cempres,
                                                 v_nrectmp,
                                                 v_fefecto,
                                                 NULL,
                                                 NULL,
                                                      -- Bug 13163 (fultsaldo)
                                                 v_cbanco,
                                                 v_cdelega,
                                                 0
                                                );
                                           -- Bug 10019 (aadimos ctipcob = 0)
                     ELSE
                        v_error := 0;
                     END IF;

                     pas := 23;

                     IF v_error = 0
                     THEN
                        UPDATE devbanrec_coda
                           SET fmovrec = f_sysdate
                         --nnumrec = v_nrectmp,
                         --ipagado = v_import,
                         --ctiporeg = 6
                        WHERE  sdevolu = p_sproces
                           AND nnumlin = p_nnumlin
                           AND RTRIM (LTRIM (cbancar1)) =
                                                    RTRIM (LTRIM (p_cbancar1))
                           AND nnumord = v_nnumord;

                        UPDATE devbanrec_coda_detalle
                           SET fmovrec = f_sysdate,
                               nrecibo = v_nrectmp,
                               ipagado = v_import,
                               ctiporeg = 6
                         WHERE sdevolu = p_sproces
                           AND nnumlin = p_nnumlin
                           AND RTRIM (LTRIM (cbancar1)) =
                                                    RTRIM (LTRIM (p_cbancar1))
                           AND nnumord = v_nnumord
                           AND norden = v_norden;

                        pas := 24;

                        IF NVL (p_ok, 0) <> 1
                        THEN
                           pas := 25;
                           v_error :=
                              pac_devolu.f_impaga_rebut
                                               (v_nrectmp,
                                                v_fefecto,
                                                NULL, -- Bug 13163 (fultsaldo)
                                                NULL
                                               );
                        ELSE
                           pas := 26;
                           v_error := 0;
                        END IF;

                        pas := 27;

                        IF v_error = 0
                        THEN
                           pas := 28;

                           UPDATE devbanrec_coda
                              SET fmovrec = f_sysdate
                            WHERE sdevolu = p_sproces
                              AND nnumlin = p_nnumlin
                              AND RTRIM (LTRIM (cbancar1)) =
                                                    RTRIM (LTRIM (p_cbancar1))
                              AND nnumord = v_nnumord;

                           UPDATE devbanrec_coda_detalle
                              SET fmovrec = f_sysdate,
                                  nrecibo = v_nrectmp,
                                  ipagado = v_import,
                                  ctiporeg = 6
                            WHERE sdevolu = p_sproces
                              AND nnumlin = p_nnumlin
                              AND RTRIM (LTRIM (cbancar1)) =
                                                    RTRIM (LTRIM (p_cbancar1))
                              AND nnumord = v_nnumord
                              AND norden = v_norden;
                        ELSE
                           pas := 29;

                           DELETE      devbanrec_coda
                                 WHERE sdevolu = p_sproces
                                   AND nnumlin = p_nnumlin
                                   AND RTRIM (LTRIM (cbancar1)) =
                                                    RTRIM (LTRIM (p_cbancar1))
                                   AND nnumord > 1;

                           pas := 30;

                           UPDATE devbanrec_coda
                              SET fmovrec = NULL,
                                  nnumrec = NULL,
                                  ctiporeg = 2
                            WHERE ROWID = v_rowid;

                           p_redo := 1;
                           RETURN v_error;
                        END IF;

                        pas := 31;

                        --Bug 9204-MCC-03/03/2009- Gestin de recibos
                        FOR c_reb IN cur_recibos (v_nrectmp)
                        LOOP
                           SELECT COUNT (*)
                             INTO v_impagos
                             FROM tmp_impagados ti
                            WHERE ti.sseguro = c_reb.sseguro
                              AND ti.nrecibo = c_reb.nrecibo
                              AND ti.ffejecu = c_reb.ffejecu;

                           pas := 32;

                           IF v_impagos = 0
                           THEN
                              pas := 33;

                              SELECT MAX (smovrec)
                                INTO v_smovrec
                                FROM movrecibo
                               WHERE nrecibo = c_reb.nrecibo;

                              pas := 34;

                              --AND fmovfin IS NULL;
                              INSERT INTO tmp_impagados
                                          (sseguro, nrecibo,
                                           ffejecu, ffecalt,
                                           cactimp, ctractat,
                                           ttexto, cmotivo, terror,
                                           ccarta, nimpagad, sdevolu,
                                           smovrec
                                          )
                                   VALUES (c_reb.sseguro, c_reb.nrecibo,
                                           c_reb.ffejecu, f_sysdate,
                                           c_reb.cactimp, c_reb.ctractat,
                                           NULL, c_reb.cmotivo, NULL,
                                           c_reb.ccarta, 0, p_sproces,
                                           v_smovrec
                                          );
                           END IF;
                        END LOOP;
                     --FIN Bug 9204-MCC-03/03/2009- Gestin de recibos
                     ELSE
                        pas := 35;

                        DELETE      devbanrec_coda
                              WHERE sdevolu = p_sproces
                                AND nnumlin = p_nnumlin
                                AND RTRIM (LTRIM (cbancar1)) =
                                                    RTRIM (LTRIM (p_cbancar1))
                                AND nnumord > 1;

                        pas := 35;

                        UPDATE devbanrec_coda
                           SET fmovrec = NULL,
                               nnumrec = NULL,
                               ctiporeg = 2
                         WHERE ROWID = v_rowid;

                        p_redo := 1;
                        RETURN v_error;
                     END IF;

                     pas := 36;
                     p_redo := 1;
                  END IF;
               ELSE
                  IF v_csigno = 0
                  THEN
                     p_redo := 0;
                     RETURN 9000878;
                  ELSE
                     p_redo := 0;
                     RETURN 9000876;
                  END IF;
               END IF;

               pas := 37;
               v_nrectmp := '';
               v_imp := '';
               --v_nnumord := v_nnumord + 1;
               v_norden := v_norden + 1;
            ELSIF v_flagimp = 1
            THEN
               v_imp := v_imp || v_act;
            ELSIF v_act = '_' AND v_flagimp = 0
            THEN
               v_flagimp := 1;
            ELSE
               v_nrectmp := v_nrectmp || v_act;
            END IF;

            pas := 38;
            v_index := v_index + 1;
         END LOOP;
--
      ELSE
         pas := 39;
         p_redo := 1;
         RETURN 9000877;
      END IF;

      SELECT SUM (iimporte)
        INTO vimpcoda
        FROM devbanrec_coda
       WHERE sdevolu = p_sproces
         AND nnumlin = p_nnumlin
         AND RTRIM (LTRIM (cbancar1)) = RTRIM (LTRIM (p_cbancar1))
         AND nnumord = p_nnumord;

      SELECT SUM (ipagado)
        INTO v_importtotalpagat
        FROM devbanrec_coda_detalle
       WHERE sdevolu = p_sproces
         AND nnumlin = p_nnumlin
         AND RTRIM (LTRIM (cbancar1)) = RTRIM (LTRIM (p_cbancar1))
         AND nnumord = p_nnumord;

      pas := 388;

      IF v_importtotalpagat = vimpcoda
      THEN
         v_estreg := 5;
      ELSE
         v_estreg := v_ctiporeg;
      END IF;

      UPDATE devbanrec_coda
         SET ctiporeg = v_estreg,
             ipagado = v_importtotalpagat
       WHERE sdevolu = p_sproces
         AND nnumlin = p_nnumlin
         AND RTRIM (LTRIM (cbancar1)) = RTRIM (LTRIM (p_cbancar1))
         AND nnumord = p_nnumord;

      pas := 40;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_CODA.f_gestion_recibos',
                      pas,
                      '  v_error = ' || v_error || 'Error = ' || SQLERRM,
                      SQLCODE
                     );
         RETURN 152715;
   END f_gestion_recibos;

   /*************************************************************************
      Obtiene los registros de un proceso de extraccion de fichero CODA segn
      los parmetros de entrada y genera un fichero en excel
      param in  p_sproces   : Id. del proceso
      param in  p_fechaini  : Fecha inicio
      param in  p_fechafin  : Fecha fin
      param in  p_ctipreg   : Tipo registro
      param in  p_nrecibo   : Numero de recibo
      param in  p_tnombre   : Nombre tomador
      param in  p_tdescrip  : Descripcion
      param in  p_cbanco    : Descripcin del banco
      param out p_ruta      : Ruta donde se ha guardado el excel
      return                : 0.-    OK
                              otro.- error
   *************************************************************************/
   FUNCTION f_excel_coda (
      p_sproces    IN       NUMBER,
      p_fechaini   IN       DATE,
      p_fechafin   IN       DATE,
      p_ctipreg    IN       NUMBER,
      p_nrecibo    IN       NUMBER,
      p_tnombre    IN       VARCHAR2,
      p_tdescrip   IN       VARCHAR2,
      p_cbanco     IN       NUMBER,
      p_ruta       OUT      VARCHAR2
   )
      RETURN NUMBER
   IS
      v_file       UTL_FILE.file_type;
      v_path       VARCHAR2 (100);
      v_path2      VARCHAR2 (100);
      v_name       VARCHAR2 (100);
      v_cur        sys_refcursor;
      v_error      NUMBER (8);
      v_sdevolu    NUMBER (8);
      v_cbancar1   VARCHAR2 (35);
      v_nnumlin    NUMBER (4);
      v_fproces    DATE;
      v_cbanco     NUMBER (3);
      v_tpagador   VARCHAR2 (35);
      v_ttatribu   VARCHAR2 (100);
      v_nnumrec    NUMBER (8);
      v_ctiporeg   NUMBER (1);
      v_tdescrip   VARCHAR2 (120);
      v_iimporte   devbanrec_coda.iimporte%TYPE;
                       --25803: RSA001 - Ampliar los decimales NUMBER(12, 2);
      v_cagecob    NUMBER (8);
   BEGIN
      v_error :=
         f_get_coda (p_sproces,
                     p_fechaini,
                     p_fechafin,
                     p_ctipreg,
                     p_nrecibo,
                     p_tnombre,
                     p_tdescrip,
                     p_cbanco,
                     v_cur
                    );

      IF v_error <> 0
      THEN
         IF v_cur%ISOPEN
         THEN
            CLOSE v_cur;
         END IF;

         RETURN v_error;
      END IF;

      v_path := f_parinstalacion_t ('INFORMES');
      v_path2 := f_parinstalacion_t ('INFORMES_C');
      v_name :=
            'CODA_FILE_'
         || p_sproces
         || '_'
         || TO_CHAR (f_sysdate, 'HH24MISS_DDMMYYYY')
         || '.csv';
      p_ruta := v_path2 || '\' || v_name;
      v_file := UTL_FILE.fopen (v_path, v_name, 'w');

      FETCH v_cur
       INTO v_fproces, v_sdevolu, v_cbancar1, v_nnumlin, v_tpagador, v_cbanco,
            v_nnumrec, v_ctiporeg, v_ttatribu, v_tdescrip, v_iimporte,
            v_cagecob;

      UTL_FILE.put_line
         (v_file,
          'FPROCES;SDEVOLU;CBANCAR1;NNUMLIN;TPAGADOR;TDESCRIP;CBANCO;NNUMREC;IIMPORTE;CTIPOREG;TTATRIBU;CAGECOB'
         );

      WHILE v_cur%FOUND
      LOOP
         UTL_FILE.put_line (v_file,
                               TO_CHAR (v_fproces, 'dd/mm/yyyy hh24:mi:ss')
                            || ';'
                            || v_sdevolu
                            || ';'
                            || v_cbancar1
                            || ';'
                            || v_nnumlin
                            || ';'
                            || v_tpagador
                            || ';'
                            || v_tdescrip
                            || ';'
                            || v_cbanco
                            || ';'
                            || v_nnumrec
                            || ';'
                            || v_iimporte
                            || ';'
                            || v_ctiporeg
                            || ';'
                            || v_ttatribu
                            || ';'
                            || v_cagecob
                           );

         FETCH v_cur
          INTO v_fproces, v_sdevolu, v_cbancar1, v_nnumlin, v_tpagador,
               v_cbanco, v_nnumrec, v_ctiporeg, v_ttatribu, v_tdescrip,
               v_iimporte, v_cagecob;
      END LOOP;

      CLOSE v_cur;

      UTL_FILE.fclose (v_file);
      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         IF v_cur%ISOPEN
         THEN
            CLOSE v_cur;
         END IF;

         IF UTL_FILE.is_open (v_file)
         THEN
            UTL_FILE.fclose (v_file);
         END IF;

         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_CODA.f_excel_coda',
                      1,
                      '  v_error = ' || v_error || 'Error = ' || SQLERRM,
                      SQLCODE
                     );
         RETURN 152715;
   END f_excel_coda;

   /*************************************************************************
      Obtiene la informacin de una lnea de la tabla de CODA
      param in  p_sproces   : Id. del proceso
      param in  p_nnumlin   : Numero de linea
      param in  p_cbancar1  : Cuenta bancaria destinataria
      param out p_nombre    : Nombre del pagador
      param out p_descrip   : Descripcin
      param out p_fecha     : Fecha de proceso
      param out p_importe   : Importe
      return                : 0.-    OK
                              otro.- error
   *************************************************************************/
   FUNCTION f_get_line_coda (
      p_sproces     IN       NUMBER,
      p_nnumlin     IN       NUMBER,
      p_cbancar1    IN       VARCHAR2,
      p_nnumord     IN       NUMBER,
      p_nombre      OUT      VARCHAR2,
      p_descrip     OUT      VARCHAR2,
      p_fecha       OUT      DATE,
      p_importe     OUT      NUMBER,
      p_reference   OUT      VARCHAR2
   )
      RETURN NUMBER
   IS
   BEGIN
      IF p_sproces IS NULL OR p_nnumlin IS NULL OR p_cbancar1 IS NULL
      THEN
         RETURN 103135;
      END IF;

      SELECT tpagador, tdescrip, fproces,
             DECODE (csigno, 0, iimporte, (iimporte * (-1))) - ipagado
                                                                     iimporte,
             referencia
        INTO p_nombre, p_descrip, p_fecha,
             p_importe,
             p_reference
        FROM devbanrec_coda
       WHERE sdevolu = p_sproces
         AND nnumlin = p_nnumlin
         AND RTRIM (LTRIM (cbancar1)) = RTRIM (LTRIM (p_cbancar1))
         AND nnumord = NVL (p_nnumord, 1);

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 152715;
   END f_get_line_coda;

   /*************************************************************************
      Descarta un registro CODA
      param in  p_sproces   : Id. del proceso
      param in  p_nnumlin   : Numero de linea
      param in  p_cbancar1  : Cuenta bancaria destinataria
      param out p_nnumord   : Numero de orden
      return                : 0.-    OK
                              otro.- error
      --BUG 11166 - JTS - 16/09/2009
   *************************************************************************/
   FUNCTION f_cancela_registro (
      p_sproces    IN   NUMBER,
      p_nnumlin    IN   NUMBER,
      p_cbancar1   IN   VARCHAR2,
      p_nnumord    IN   NUMBER
   )
      RETURN NUMBER
   IS
   BEGIN
      IF    p_sproces IS NULL
         OR p_nnumlin IS NULL
         OR p_cbancar1 IS NULL
         OR p_nnumord IS NULL
      THEN
         RETURN 103135;
      END IF;

      UPDATE devbanrec_coda
         SET ctiporeg = 7
       WHERE sdevolu = p_sproces
         AND nnumlin = p_nnumlin
         AND RTRIM (LTRIM (cbancar1)) = RTRIM (LTRIM (p_cbancar1))
         AND nnumord = p_nnumord;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_CODA.f_cancela_registro',
                      1,
                      SQLERRM,
                      SQLCODE
                     );
         RETURN 152715;
   END f_cancela_registro;

   /*************************************************************************
      reactivar un registro CODA
      param in  p_sproces   : Id. del proceso
      param in  p_nnumlin   : Numero de linea
      param in  p_cbancar1  : Cuenta bancaria destinataria
      param out p_nnumord   : Numero de orden
      return                : 0.-    OK
                              otro.- error
     --BUG 15816: CODA : doesn't allow undo a cancellation - XPL - 09/09/2010
   *************************************************************************/
   FUNCTION f_reactivar_registro (
      p_sproces    IN   NUMBER,
      p_nnumlin    IN   NUMBER,
      p_cbancar1   IN   VARCHAR2,
      p_nnumord    IN   NUMBER
   )
      RETURN NUMBER
   IS
   BEGIN
      IF    p_sproces IS NULL
         OR p_nnumlin IS NULL
         OR p_cbancar1 IS NULL
         OR p_nnumord IS NULL
      THEN
         RETURN 103135;
      END IF;

      UPDATE devbanrec_coda
         SET ctiporeg = 1
       WHERE sdevolu = p_sproces
         AND nnumlin = p_nnumlin
         AND RTRIM (LTRIM (cbancar1)) = RTRIM (LTRIM (p_cbancar1))
         AND nnumord = p_nnumord;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_CODA.f_reactivar_registro',
                      1,
                      SQLERRM,
                      SQLCODE
                     );
         RETURN 152715;
   END f_reactivar_registro;

---   XPL 11208: APR - pago parcial de recibos INICI creaci funcions---
   /*************************************************************************
       Obtiene el importe pendiente a pagar de un recibo
       param in  pnrecibo   : NUm recibo
       param in  psmovrec   : seq. mov. recibo
       param out p_importe   : Importe Pendiente
       return                : 0.-    OK
                               1.-    KO
    *************************************************************************/
   FUNCTION Ff_Importe_pendiente (
      pnrecibo    IN       NUMBER,
      psmovrec    IN       NUMBER,
      p_importe   OUT      NUMBER
   )
      RETURN NUMBER
   IS
      v_pasexec         NUMBER (8)     := 1;
      v_param           VARCHAR2 (200)
                  := 'psmovrec = ' || psmovrec || ' ppnrecibo = ' || pnrecibo;
      v_object          VARCHAR2 (200) := 'PAC_IAX_CODA.FF_IMPORTE_PENDIENTE';
      v_error           NUMBER (8)     := 0;
      vsmovrec          NUMBER;
      vitotalr          NUMBER;
      -- Bug 0026959 - DCG - 14/05/2013 - Ini
      vitotalr_monpol   NUMBER;
      vitotalr_prod     NUMBER;
      -- Bug 0026959 - DCG - 14/05/2013 - Fi
      vcestrec          NUMBER;
      v_sum_importe     NUMBER;
   BEGIN
      vsmovrec := psmovrec;

      IF psmovrec IS NULL
      THEN
         BEGIN
            SELECT MAX (smovrec)
              INTO vsmovrec
              FROM movrecibo
             WHERE nrecibo = pnrecibo AND cestrec = 0;
         EXCEPTION
            WHEN OTHERS
            THEN
               p_importe := 0;
               RETURN 0;
         END;
      END IF;

      SELECT cestrec
        INTO vcestrec
        FROM movrecibo
       WHERE nrecibo = pnrecibo AND smovrec = vsmovrec;

-- Bug 0026959 - DCG - 14/05/2013 - Ini
--      SELECT SUM(iimporte)
      SELECT NVL (SUM (iimporte_moncon), SUM (iimporte))
-- Bug 0026959 - DCG - 14/05/2013 - Fi
      INTO   p_importe
        FROM detmovrecibo
       WHERE nrecibo = pnrecibo AND smovrec = vsmovrec;

      SELECT itotalr
        INTO vitotalr_prod                   -- Bug 0026959 - DCG - 14/05/2013
        FROM vdetrecibos
       WHERE nrecibo = pnrecibo;


      -- Bug 0026959 - DCG - 14/05/2013 - Ini
      BEGIN
         SELECT itotalr
           INTO vitotalr_monpol
           FROM vdetrecibos_monpol
          WHERE nrecibo = pnrecibo;
      EXCEPTION
         WHEN OTHERS
         THEN
            vitotalr_monpol := 0;
      END;


      -- Bug 0026959 - DCG - 14/05/2013 - Fi
      IF vcestrec = 0 OR (p_importe IS NOT NULL AND p_importe != 0)
      THEN
         p_importe := vitotalr - NVL (p_importe, 0);
      ELSE
         p_importe := 0;
      END IF;

-- Inici Bug 0013448 XPL 25/03/2010 Per veure a la consulta de rebuts si tenim saldo positiu o no quan un rebut est cobrat
-- Bug 0026959 - DCG - 14/05/2013 - Ini
--      SELECT SUM(iimporte)
      SELECT NVL (SUM (b.iconcep_monpol), SUM (b.iconcep))
-- Bug 0026959 - DCG - 14/05/2013 - Fi
      INTO   v_sum_importe
        FROM detmovrecibo a, detmovrecibo_parcial b
       WHERE a.nrecibo = pnrecibo
         AND a.nrecibo = b.nrecibo
         AND a.smovrec = (SELECT MAX (b.smovrec)
                            FROM detmovrecibo b
                           WHERE b.nrecibo = a.nrecibo)
         AND a.norden = b.norden
         AND b.cconcep IN (0, 4, 14, 86);


         vitotalr := NVL (vitotalr_monpol, vitotalr_prod);


      p_importe := vitotalr - NVL (v_sum_importe, 0);




--Fi  Bug 0013448 XPL 25/03/2010
      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_importe := 0;
         RETURN 1;
   END ff_importe_pendiente;

   /*************************************************************************
      FUNCTION f_ins_dano
         Inserta a la taula SIN_TRAMITA_DANO dels parmetres informats.
         param in pnsinies  : nmero sinistre
         param in pntramit  : nmero tramitaci sinistre
         param in pndano    : nmero dany sinistre
         param in pctipdano : codi tipus dany
         param in ptdano    : descripci dany
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_ins_detmovrecibo (
      psmovrec    IN   NUMBER,
      pnorden     IN   NUMBER,
      pnrecibo    IN   NUMBER,
      piimporte   IN   NUMBER,
      pfmovimi    IN   DATE,
      pfefeadm    IN   DATE,
      pcusuari    IN   VARCHAR2,
      psdevolu    IN   NUMBER,
      pnnumnlin   IN   NUMBER,
      pcbancar1   IN   VARCHAR2,
      pnnumord    IN   NUMBER
   )
      RETURN NUMBER
   IS
      vobjectname   VARCHAR2 (500) := 'PAC_coda.f_ins_detmovrecibo';
      vparam        VARCHAR2 (500)
         :=    'parmetros - SMOVREC: '
            || psmovrec
            || ' NRECIBO:'
            || pnrecibo
            || ' NORDEN:'
            || pnorden
            || ' IIMPORTE:'
            || piimporte
            || ' FMOVIMI:'
            || pfmovimi;
      pasexec       NUMBER (5)     := 1;
      vcount        NUMBER (5);
      vsmovrec      NUMBER;
      vnorden       NUMBER         := 0;
      vfefeadm      DATE;
      viimporte     NUMBER;
      vcbancar      VARCHAR2 (34);
   BEGIN
      vsmovrec := psmovrec;
      viimporte := piimporte;
      vcbancar := pcbancar1;

      IF psmovrec IS NULL
      THEN
         SELECT MAX (smovrec)
           INTO vsmovrec
           FROM movrecibo
          WHERE nrecibo = pnrecibo AND cestrec = 0;
      END IF;

      SELECT MAX (NVL (norden, 0)) + 1
        INTO vnorden
        FROM detmovrecibo
       WHERE nrecibo = pnrecibo AND smovrec = vsmovrec;

      IF vnorden IS NULL
      THEN
         vnorden := 1;
      END IF;

      vfefeadm := pfefeadm;

      IF pfefeadm IS NULL
      THEN
         BEGIN
            SELECT fefecto
              INTO vfefeadm
              FROM devbanrec_coda
             WHERE sdevolu = psdevolu
               AND nnumlin = pnnumnlin
               AND cbancar1 = pcbancar1
               AND nnumord = pnnumord;
         EXCEPTION
            WHEN OTHERS
            THEN
               vfefeadm := NULL;
         END;
      END IF;

--S'afegeix ja que sempre ha de grabar un apunt a detmovrecibo i en el cas que sigui null l'import
--s'agafar el del rebut.
--Inici 16/04/2010#XPL#0013925: APR902 - homogeneizar el uso de detmovrecibo
      IF piimporte IS NULL
      THEN
         SELECT itotalr
           INTO viimporte
           FROM vdetrecibos
          WHERE nrecibo = pnrecibo;
      END IF;

      IF pcbancar1 IS NULL
      THEN
         BEGIN
            SELECT cbancar
              INTO vcbancar
              FROM recibos
             WHERE nrecibo = pnrecibo;
         EXCEPTION
            WHEN OTHERS
            THEN
               vcbancar := 0;
         END;
      END IF;

      IF vcbancar IS NULL
      THEN
         vcbancar := 0;
      END IF;

--FI 16/04/2010#XPL#0013925: APR902 - homogeneizar el uso de detmovrecibo
      BEGIN
         INSERT INTO detmovrecibo
                     (smovrec, norden, nrecibo, iimporte, fmovimi,
                      fefeadm, cusuari, sdevolu, nnumnlin, cbancar1,
                      nnumord
                     )
              VALUES (vsmovrec, vnorden, pnrecibo, viimporte, f_sysdate,
                      vfefeadm, f_user, psdevolu, pnnumnlin, vcbancar,
                      pnnumord
                     );
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX
         THEN
            UPDATE detmovrecibo
               SET sdevolu = psdevolu,
                   nrecibo = pnrecibo,
                   nnumord = pnnumord,
                   nnumnlin = pnnumnlin,
                   iimporte = viimporte,
                   cbancar1 = vcbancar
             WHERE smovrec = vsmovrec AND norden = vnorden;
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      pasexec,
                      vparam,
                      'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM
                     );
         RETURN 9000872;
   --Error al llegir de la taula SIN_TRAMITA_DANO
   END f_ins_detmovrecibo;
-- Ini IAXIS-13059 -- ECP -- 06/03/2020
   FUNCTION f_get_detmovrecibos (
      pnrecibo   IN       NUMBER,
      psmovrec   IN       NUMBER,
      psquery    OUT      VARCHAR2
   )
      RETURN NUMBER
   IS
      v_pasexec   NUMBER (8)      := 1;
      v_param     VARCHAR2 (200)
                  := 'psmovrec = ' || psmovrec || ' ppnrecibo = ' || pnrecibo;
      v_object    VARCHAR2 (200)  := 'pac_coda.f_get_detmovrecibos';
      v_error     NUMBER (8)      := 0;
      vsquery     VARCHAR2 (4000);
   BEGIN
   -- INI IAXIA-4995 -JLTS - 08/08/2019 Sse ajusta la consulta para que en pantalla se muestre correctamente
   --Ini IAXIS/3592 -- ECP --28/05/2019
   --Ini IAXIS-5149-- ECP --10/10/2019
      psquery :=
            'SELECT  c.tatribu, SUM (b.iconcep_monpol) iimporte, DECODE(SUM(SUM(b.iconcep_monpol)) OVER(), 0, 0, 1) esabonado, a.fmovimi, b.fcambio, a.sdevolu, a.nnumnlin, a.cbancar1, a.tdescrip, b.nreccaj, ff_desvalorfijo (552, 8, b.cmreca) tmrecadet FROM detmovrecibo a, detmovrecibo_parcial b, detvalores c WHERE a.nrecibo ='
         || pnrecibo
         || '
                    and a.smovrec = nvl('''
         || psmovrec
         || ''',a.smovrec) AND a.smovrec = b.smovrec AND a.nrecibo = b.nrecibo AND a.norden = b.norden AND b.cconcep IN (0, 50, 4,14,16,86) and b.cconcep = c.catribu and c.cvalor = 27 and c.cidioma = 8 and b.iconcep_monpol <> 0 and b.nreccaj is not null and b.cmreca is not null GROUP BY c.tatribu, b.cconcep, a.fmovimi, b.fcambio, a.sdevolu, a.nnumnlin, a.cbancar1, a.tdescrip, b.nreccaj, ff_desvalorfijo(552,8,b.cmreca) order by nreccaj desc';

       --Fin IAXIS-5149-- ECP --10/10/2019
         --Fin IAXIS/3592 -- ECP --28/05/2019
    -- FIN IAXIA-4995 -JLTS - 08/08/2019 Sse ajusta la consulta para que en pantalla se muestre correctamente
      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      v_object,
                      v_pasexec,
                      v_param,
                      'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM
                     );
         RETURN 9000872;
   END f_get_detmovrecibos;
   
   
   -- INi IAXIS-5149 -- ECP -- 13/01/2020
FUNCTION f_get_detmovrecibosc (
      pnrecibo   IN       NUMBER,
      psmovrec   IN       NUMBER,
      psquery    OUT      VARCHAR2
   )
      RETURN NUMBER
   IS
      v_pasexec   NUMBER (8)      := 1;
      v_param     VARCHAR2 (200)
                  := 'psmovrec = ' || psmovrec || ' ppnrecibo = ' || pnrecibo;
      v_object    VARCHAR2 (200)  := 'pac_coda.f_get_detmovrecibos';
      v_error     NUMBER (8)      := 0;
      vsquery     VARCHAR2 (4000);
   BEGIN
   
      psquery :=
            'SELECT  c.tatribu, SUM (b.iconcep_monpol) iimporte, DECODE(SUM(SUM(b.iconcep_monpol)) OVER(), 0, 0, 1) esabonado, a.fmovimi, b.fcambio, a.sdevolu, a.nnumnlin, a.cbancar1, a.tdescrip, b.nreccaj, ff_desvalorfijo (552, 8, b.cmreca) tmrecadet FROM detmovrecibo a, detmovrecibo_parcial b, detvalores c WHERE a.nrecibo ='
         || pnrecibo
         || ' AND a.smovrec = b.smovrec AND a.nrecibo = b.nrecibo AND a.norden = b.norden AND b.cconcep IN (0, 50, 4,14,16,86) and b.cconcep = c.catribu and c.cvalor = 27 and c.cidioma = 8 and b.iconcep_monpol <> 0  and b.nreccaj is null and b.cmreca is null GROUP BY c.tatribu, b.cconcep, a.fmovimi, b.fcambio, a.sdevolu, a.nnumnlin, a.cbancar1, a.tdescrip, b.nreccaj, ff_desvalorfijo(552,8,b.cmreca) order by nreccaj desc';
     
      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      v_object,
                      v_pasexec,
                      v_param,
                      'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM
                     );
         RETURN 9000872;
   END f_get_detmovrecibosc;
-- Fin IAXIS-5149 -- ECP -- 13/01/2020
-- Fin IAXIS-13059 -- ECP -- 06/03/2020
   
   

   /*************************************************************************
      Obtiene el importe pendiente a pagar de un recibo
      param in  pnrecibo   : Num recibo
      param in  psmovrec   : seq. mov. recibo
      return               : importe pendiente
     --BUG 40771 227859: reporte balance de polizas positivas
   *************************************************************************/
   FUNCTION ff_get_imppend_rec (pnrecibo IN NUMBER, psmovrec IN NUMBER)
      RETURN NUMBER
   IS
      v_pasexec   NUMBER (8)     := 1;
      v_param     VARCHAR2 (200)
                   := 'pnrecibo = ' || pnrecibo || ' psmovrec = ' || psmovrec;
      v_object    VARCHAR2 (200) := 'pac_coda.ff_get_imppend_rec';
      v_error     NUMBER (8)     := 0;
      v_importe   NUMBER;
   BEGIN
      --
      v_error :=
                pac_coda.ff_importe_pendiente (pnrecibo, psmovrec, v_importe);
      --
      RETURN v_importe;
   --
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      v_object,
                      v_pasexec,
                      v_param,
                      'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM
                     );
         RETURN NULL;
   END ff_get_imppend_rec;
END pac_coda;
/
