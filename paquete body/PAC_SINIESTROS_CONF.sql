--------------------------------------------------------
--  DDL for Package Body PAC_SINIESTROS_CONF
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "PAC_SINIESTROS_CONF" IS
   /******************************************************************************
   NOMBRE:     PAC_SINIESTROS_CONF
   PROP¿SITO:  Cuerpo del paquete de las funciones para SINIESTROS CONF

   REVISIONES:
   Ver        Fecha        Autor             Descripci¿n
   ---------  ----------  ---------------  ------------------------------------
   1.0        01/12/2016   IGIL             CONF-431 Cierre Siniestros Confianza
   2.0        22/05/2020   MPC              IAXIS-13164 Se modifica para que en cierre inserte la reexpresion correctamente en SIN_TRAMITA_RESERVADET.
   ****************************************************************************/
   PROCEDURE proceso_batch_cierre(
      pmodo IN NUMBER,
      pcempres IN NUMBER,
      pmoneda IN NUMBER,
      pcidioma IN NUMBER,
      pfperini IN DATE,
      pfperfin IN DATE,
      pfcierre IN DATE,
      pcerror OUT NUMBER,
      psproces OUT NUMBER,
      pfproces OUT DATE) IS
      vobj           VARCHAR2(200) := 'PAC_SINIESTROS_CONF.proceso_batch_cierre';
	  -- INI - CJAD - 03/SEP2019 - IAXIS4795 - Error cierre siniestros
	  vproc      VARCHAR2(200) := 'proceso_batch_cierre';
      -- FIN - CJAD - 03/SEP2019 - IAXIS4795 - Error cierre siniestros
	  vpas           NUMBER(4) := 0;
      vpar           VARCHAR2(999)
         := 'm=' || pmodo || ' e=' || pcempres || ' m=' || pmoneda || ' d=' || pcidioma
            || ' i=' || pfperini || ' f=' || pfperfin || ' c=' || pfcierre;
      num_err        NUMBER := 0;
      v_numlin       NUMBER;
      n_contaerr     NUMBER := 0;
      e_salida       EXCEPTION;
      v_cmonprod     eco_codmonedas.cmoneda%TYPE;
      v_cmoncia      monedas.cmonint%TYPE;
      v_cmultimon    parempresas.nvalpar%TYPE;
      vcmonres       VARCHAR2(10);
      v_nmovres      sin_tramita_reserva.nmovres%TYPE;
      v_num_err_report        NUMBER := 0;
      v_sproces_report        NUMBER;
   BEGIN
      vpas := 100;

      IF pcempres IS NULL
         OR pfperfin IS NULL THEN
         p_tab_error(f_sysdate, f_user, vobj, vpas, vpar, f_axis_literales(1000005, pcidioma));
         pcerror := 1;
         RAISE e_salida;
      END IF;

      vpas := 110;

      IF NVL(pmodo, 0) <> 2 THEN
         -- Si no es Definitivo, no hacemos nada.
         pcerror := 0;
         psproces := NULL;
         pfproces := NULL;
         RAISE e_salida;
      END IF;

      vpas := 120;
      v_cmultimon := NVL(pac_parametros.f_parempresa_n(pcempres, 'MULTIMONEDA'), 0);

      IF v_cmultimon = 0 THEN
         -- No es multimoneda, no hacemos nada.
         pcerror := 0;
         psproces := NULL;
         pfproces := NULL;
         RAISE e_salida;
      END IF;

      vpas := 130;
      v_cmoncia := pac_monedas.f_cmoneda_t(pac_parametros.f_parempresa_n(pcempres, 'MONEDAEMP'));
      vpas := 140;
      num_err := f_procesini(f_user, pcempres, 'SINIESTROS',
                             f_axis_literales(108528, pcidioma), psproces);
      COMMIT;

      IF num_err <> 0 THEN
         p_tab_error(f_sysdate, f_user, vobj, vpas, vpar,
                     num_err || ' ' || SQLCODE || ' ' || SQLERRM);
         pcerror := 1;
         RAISE e_salida;
      END IF;

      vpas := 150;
      n_contaerr := 0;
      vpas := 160;

         BEGIN

            pac_siniestros_conf.p_cierre_mensual(pmodo ,pcempres,pmoneda, pcidioma, pfperini, pfperfin,pfcierre, pcerror,  psproces, pfproces);

            IF TO_CHAR(pfperfin, 'MM') = '12' THEN
              pac_siniestros_conf.p_cierre_anual(pmodo ,pcempres,pmoneda, pcidioma, pfperini, pfperfin,pfcierre, pcerror,  psproces, pfproces);
            END IF;

            IF num_err <> 0 THEN
               RAISE ZERO_DIVIDE;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               n_contaerr := n_contaerr + 1;
               v_numlin := NULL;
               num_err := f_proceslin(psproces,
                                       vpas || ' error='
                                      || num_err || '-' || SQLCODE,
                                      0, v_numlin);
               -- Bug 0022379 - 01/06/2012 - JMF
               ROLLBACK;
         END;

         -- Bug 0022379 - 01/06/2012 - JMF
         COMMIT;

      vpas := 200;
      num_err := f_procesfin(psproces, n_contaerr);
      vpas := 210;

      IF n_contaerr = 0 THEN
         pfproces := f_sysdate;
         pcerror := 0;
      ELSE
         pcerror := 1;
      END IF;

      --INI BUG 0018975 ¿ Fecha (25/06/2015) - HRE - Se hace llamado a job que genera reporte LP
      v_num_err_report := f_procesini(f_user, pcempres, 'Reporte LP', 'Empresa:'||pcempres||'-Usuario:'||f_user, v_sproces_report);

      v_num_err_report := pac_jobs.f_ejecuta_job(NULL,
                                        'pac_reporte_lp.p_reporte_job(' || pcempres
                                        || ',' || chr(39) || f_user || chr(39) || ','
                                        || v_sproces_report || ');',
                                        NULL);

      --FIN BUG 0018975  - Fecha (25/06/2015) ¿ HRE
   EXCEPTION
      WHEN e_salida THEN
         NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobj, vpas, vpar,
                     num_err || ' ' || SQLCODE || ' ' || SQLERRM);
         pcerror := 1;
   END proceso_batch_cierre;
   PROCEDURE p_cierre_mensual(
      pmodo IN NUMBER,
      pcempres IN NUMBER,
      pmoneda IN NUMBER,
      pcidioma IN NUMBER,
      pfperini IN DATE,
      pfperfin IN DATE,
      pfcierre IN DATE,
      pcerror OUT NUMBER,
      psproces OUT NUMBER,
      pfproces OUT DATE) IS
      vobj           VARCHAR2(200) := 'PAC_SINIESTROS_CONF.p_cierre_mensual';
	  -- INI - CJAD - 03/SEP2019 - IAXIS4795 - Error cierre siniestros
	  vproc      VARCHAR2(200) := 'p_cierre_mensual';
      -- FIN - CJAD - 03/SEP2019 - IAXIS4795 - Error cierre siniestros
      vpas           NUMBER(4) := 0;
      vpar           VARCHAR2(999)
         := 'm=' || pmodo || ' e=' || pcempres || ' m=' || pmoneda || ' d=' || pcidioma
            || ' i=' || pfperini || ' f=' || pfperfin || ' c=' || pfcierre;
      num_err        NUMBER := 0;
      v_numlin       NUMBER;
      n_contaerr     NUMBER := 0;
      e_salida       EXCEPTION;
      v_cmonprod     eco_codmonedas.cmoneda%TYPE;
      v_cmoncia      monedas.cmonint%TYPE;
      v_cmultimon    parempresas.nvalpar%TYPE;
      vcmonres       VARCHAR2(10);
      v_nmovres      sin_tramita_reserva.nmovres%TYPE;
      v_num_err_report        NUMBER := 0;
      v_sproces_report        NUMBER;
      CURSOR c1 IS
         SELECT   c.nsinies, c.ntramit, c.ctipres, c.nmovres, c.cmonres, c.idres
             FROM seguros a, sin_siniestro b, sin_tramita_reserva c, productos d
            WHERE a.cempres = pcempres
              AND b.sseguro = a.sseguro
              AND c.nsinies = b.nsinies
              AND c.nmovres =
                    (SELECT MAX(c1.nmovres)
                       FROM sin_tramita_reserva c1
                      WHERE c1.nsinies = c.nsinies
                        AND c1.ntramit = c.ntramit
                        AND c1.ctipres = c.ctipres
                        -- INI - CJAD - 03/SEP2019 - IAXIS4795 - Error cierre siniestros
						AND NVL(c1.ireserva, 0) <> 0
						AND c1.cmonres <> v_cmoncia
						-- FIN - CJAD - 03/SEP2019 - IAXIS4795 - Error cierre siniestros
                        AND NVL(c1.ctipgas, -1) = NVL(c.ctipgas, -1)
                        AND NVL(c1.cgarant, -1) = NVL(c.cgarant, -1)
                        AND NVL(c1.fresini, TO_DATE('01/01/1900', 'dd/mm/yyyy')) =
                              NVL(c.fresini, TO_DATE('01/01/1900', 'dd/mm/yyyy'))
                        AND NVL(c1.fresfin, TO_DATE('01/01/1900', 'dd/mm/yyyy')) =
                                            NVL(c.fresfin, TO_DATE('01/01/1900', 'dd/mm/yyyy')))
              AND NVL(c.ireserva, 0) <> 0
              AND c.cmonres <> v_cmoncia
              AND d.sproduc = a.sproduc
              AND(c.fcambio IS NULL
                  OR(c.fmovres < pfcierre + 1 
                     AND c.fcambio IS NOT NULL))
         ORDER BY c.nsinies, c.ntramit, c.ctipres, c.nmovres;
   BEGIN
      vpas := 100;

      IF pcempres IS NULL
         OR pfperfin IS NULL THEN
         p_tab_error(f_sysdate, f_user, vobj, vpas, vpar, f_axis_literales(1000005, pcidioma));
         pcerror := 1;
         RAISE e_salida;
      END IF;

      vpas := 110;

      IF NVL(pmodo, 0) <> 2 THEN
         -- Si no es Definitivo, no hacemos nada.
         pcerror := 0;
         psproces := NULL;
         pfproces := NULL;
         RAISE e_salida;
      END IF;

      vpas := 120;
      v_cmultimon := NVL(pac_parametros.f_parempresa_n(pcempres, 'MULTIMONEDA'), 0);

      IF v_cmultimon = 0 THEN
         -- No es multimoneda, no hacemos nada.
         pcerror := 0;
         psproces := NULL;
         pfproces := NULL;
         RAISE e_salida;
      END IF;

      vpas := 130;
      v_cmoncia := pac_monedas.f_cmoneda_t(pac_parametros.f_parempresa_n(pcempres, 'MONEDAEMP'));
      vpas := 140;
      num_err := f_procesini(f_user, pcempres, 'SINIESTROS',
                             f_axis_literales(108528, pcidioma), psproces);
      COMMIT;

      IF num_err <> 0 THEN
         p_tab_error(f_sysdate, f_user, vobj, vpas, vpar,
                     num_err || ' ' || SQLCODE || ' ' || SQLERRM);
         pcerror := 1;
         RAISE e_salida;
      END IF;

      vpas := 150;
      n_contaerr := 0;
      vpas := 160;

      FOR f1 IN c1 LOOP
         BEGIN
		 -- INI - ML - 12/06/2019 - 4385 - SE QUITA CONDICIONAL INNECESARIO
         -- IF f1.cmonres != pac_parametros.f_parempresa_n(pcempres, 'MONEDAEMP') THEN
            vpas := 170;

            SELECT MAX(nmovres) + 1
              INTO v_nmovres
              FROM sin_tramita_reserva
             WHERE nsinies = f1.nsinies
               AND ntramit = f1.ntramit
               AND ctipres = f1.ctipres;

            vpas := 180;
			
			-- INI - CJAD - 03/SEP2019 - IAXIS4795 - Error cierre siniestros
			IF v_nmovres > 0 THEN
			BEGIN
				vpas := 270;
			-- FIN - CJAD - 03/SEP2019 - IAXIS4795 - Error cierre siniestros
				INSERT INTO sin_tramita_reserva
							(nsinies, ntramit, ctipres, nmovres, cgarant, ccalres, fmovres,
							 cmonres, ireserva, ipago, iingreso, irecobro, icaprie, ipenali,
							 fresini, fresfin, fultpag, sidepag, sproces, fcontab, cusualt, falta,
							 cusumod, fmodifi, iprerec, ctipgas, ireserva_moncia, ipago_moncia,
							 iingreso_moncia, irecobro_moncia, icaprie_moncia, ipenali_moncia,
							 iprerec_moncia, fcambio, idres, cmovres)
				   SELECT nsinies, ntramit, ctipres, v_nmovres nmovres, cgarant, ccalres, pfcierre,
						  cmonres, ireserva, ipago, iingreso, irecobro, icaprie, ipenali, fresini,
						  fresfin, fultpag, sidepag, psproces, fcontab, cusualt, falta, cusumod,
						  fmodifi, iprerec, ctipgas, ireserva_moncia, ipago_moncia,
						  iingreso_moncia, irecobro_moncia, icaprie_moncia, ipenali_moncia,
						  iprerec_moncia, fcambio, idres, 10
					 FROM sin_tramita_reserva
					WHERE nsinies = f1.nsinies
					  AND ntramit = f1.ntramit
					  AND ctipres = f1.ctipres
					  AND nmovres = f1.nmovres
					  AND idres = f1.idres;
			--IAXIS 13108 AABC cambios para sproces en la tabla de reservas 		  
			-- INI - CJAD - 03/SEP2019 - IAXIS4795 - Error cierre siniestros
			EXCEPTION
				WHEN dup_val_on_index THEN
					 p_traza_proceso(pcempres, 'TRAZA_CIERRE_PROP', psproces, vobj, vproc, NULL, vpas,
									'DUP_VAL_ON_INDEX: ' || '-' || SQLCODE || '-' || SQLERRM);
				WHEN no_data_found THEN
					 p_traza_proceso(pcempres, 'TRAZA_CIERRE_PROP', psproces, vobj, vproc, NULL, vpas,
									'NO_DATA_FOUND: ' || '-' || SQLCODE || '-' || SQLERRM);
				WHEN OTHERS THEN
					 p_traza_proceso(pcempres, 'TRAZA_CIERRE_PROP', psproces, vobj, vproc, NULL, vpas,
									'OTHERS: ' || '-' || SQLCODE || '-' || SQLERRM);
			-- FIN - CJAD - 03/SEP2019 - IAXIS4795 - Error cierre siniestros
			END;

            vpas := 190;
            num_err := pac_oper_monedas.f_contravalores_reserva(f1.nsinies, f1.ntramit,
                                                                f1.ctipres, v_nmovres, NULL,
                                                                pfperfin);
            --INI BUG 13164 22/05/2020 MPC Se corrige para que se inserte la reexpresion en la tabla sin_tramita_reservadet.
            --num_err := pac_siniestros.f_ins_reservadet(f1.nsinies, f1.idres, v_nmovres, pfperfin, 10, f1.cmonres, 1, null);
            num_err := pac_siniestros.f_ins_reservadet(f1.nsinies, f1.idres, f1.nmovres, pfperfin, 10, f1.cmonres, 1, null);
            --FIN BUG 13164 22/05/2020 MPC Se corrige para que se inserte la reexpresion en la tabla sin_tramita_reservadet.
            IF num_err <> 0 THEN
               RAISE ZERO_DIVIDE;
            END IF;
        END IF;
		-- FIN - ML - 12/06/2019 - 4385 - SE QUITA CONDICIONAL INNECESARIO
         EXCEPTION
            WHEN OTHERS THEN
               n_contaerr := n_contaerr + 1;
               v_numlin := NULL;
               num_err := f_proceslin(psproces,
                                      f1.nsinies || '-' || f1.ntramit || '-' || f1.ctipres
                                      || '-' || f1.nmovres || '-' || vpas || ' error='
                                      || num_err || '-' || SQLCODE,
                                      0, v_numlin);
			-- INI - ML - 12/06/2019 - 4385 - SE MUEVE ROLLBACK EN OTRO LUGAR
               --ROLLBACK;
			-- FIN - ML - 12/06/2019 - 4385 - SE MUEVE ROLLBACK EN OTRO LUGAR
         END;

	     -- INI - ML - 12/06/2019 - 4385 - SE MUEVE COMMIT EN OTRO LUGAR
         --COMMIT;
		 -- FIN - ML - 12/06/2019 - 4385 - SE MUEVE COMMIT EN OTRO LUGAR

      END LOOP;

	-- INI - ML - 12/06/2019 - 4385 - SE EJECUTA COMMIT SI NO EXISTE NINGUN ERROR, DE LO CONTRARIO SE REVIERTE CAMBIOS
      IF n_contaerr = 0 THEN
         pfproces := f_sysdate;
         pcerror := 0;
		 COMMIT;
      ELSE
         pcerror := 1;
		 ROLLBACK;
      END IF;
	-- FIN - ML - 12/06/2019 - 4385 - SE EJECUTA COMMIT SI NO EXISTE NINGUN ERROR, DE LO CONTRARIO SE REVIERTE CAMBIOS

   EXCEPTION
      WHEN e_salida THEN
         NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobj, vpas, vpar,
                     num_err || ' ' || SQLCODE || ' ' || SQLERRM);
         pcerror := 1;
   END p_cierre_mensual;
   PROCEDURE p_cierre_anual(
      pmodo IN NUMBER,
      pcempres IN NUMBER,
      pmoneda IN NUMBER,
      pcidioma IN NUMBER,
      pfperini IN DATE,
      pfperfin IN DATE,
      pfcierre IN DATE,
      pcerror OUT NUMBER,
      psproces OUT NUMBER,
      pfproces OUT DATE) IS
      vobj           VARCHAR2(200) := 'PAC_SINIESTROS_CONF.p_cierre_anual';
	  -- INI - CJAD - 03/SEP2019 - IAXIS4795 - Error cierre siniestros
	  vproc      VARCHAR2(200) := 'p_cierre_anual';
      -- FIN - CJAD - 03/SEP2019 - IAXIS4795 - Error cierre siniestros
      vpas           NUMBER(4) := 0;
      vpar           VARCHAR2(999)
         := 'm=' || pmodo || ' e=' || pcempres || ' m=' || pmoneda || ' d=' || pcidioma
            || ' i=' || pfperini || ' f=' || pfperfin || ' c=' || pfcierre;
      num_err        NUMBER := 0;
      v_numlin       NUMBER;
      n_contaerr     NUMBER := 0;
      e_salida       EXCEPTION;
      v_cmonprod     eco_codmonedas.cmoneda%TYPE;
      v_cmoncia      monedas.cmonint%TYPE;
      v_cmultimon    parempresas.nvalpar%TYPE;
      vcmonres       VARCHAR2(10);
      v_nmovres      sin_tramita_reserva.nmovres%TYPE;
      v_num_err_report        NUMBER := 0;
      v_sproces_report        NUMBER;
      CURSOR c_rdet IS
      SELECT *
        FROM SIN_TRAMITA_RESERVADET D
       WHERE D.NMOVRES = (SELECT MAX(D1.NMOVRES)
                            FROM SIN_TRAMITA_RESERVA D1
                           WHERE D1.NSINIES = D.NSINIES
                             AND D1.IDRES = D.IDRES)
        AND D.NMOVRESDET = (SELECT MAX(D2.NMOVRESDET)
                              FROM SIN_TRAMITA_RESERVADET D2
                             WHERE D2.NSINIES = D.NSINIES
                               AND D2.IDRES = D.IDRES
                               AND D2.NMOVRES = D.NMOVRES)
        AND D.ISALRES <> 0
       ORDER BY d.nsinies, d.idres;
   BEGIN
      vpas := 100;

      IF pcempres IS NULL
         OR pfperfin IS NULL THEN
         p_tab_error(f_sysdate, f_user, vobj, vpas, vpar, f_axis_literales(1000005, pcidioma));
         pcerror := 1;
         RAISE e_salida;
      END IF;

      vpas := 110;

      IF NVL(pmodo, 0) <> 2 THEN
         -- Si no es Definitivo, no hacemos nada.
         pcerror := 0;
         psproces := NULL;
         pfproces := NULL;
         RAISE e_salida;
      END IF;

      vpas := 120;
      v_cmultimon := NVL(pac_parametros.f_parempresa_n(pcempres, 'MULTIMONEDA'), 0);

      IF v_cmultimon = 0 THEN
         -- No es multimoneda, no hacemos nada.
         pcerror := 0;
         psproces := NULL;
         pfproces := NULL;
         RAISE e_salida;
      END IF;

      vpas := 130;
      v_cmoncia := pac_monedas.f_cmoneda_t(pac_parametros.f_parempresa_n(pcempres, 'MONEDAEMP'));
      vpas := 140;
      num_err := f_procesini(f_user, pcempres, 'SINIESTROS',
                             f_axis_literales(108528, pcidioma), psproces);
      COMMIT;

      IF num_err <> 0 THEN
         p_tab_error(f_sysdate, f_user, vobj, vpas, vpar,
                     num_err || ' ' || SQLCODE || ' ' || SQLERRM);
         pcerror := 1;
         RAISE e_salida;
      END IF;

      vpas := 150;
      n_contaerr := 0;
      vpas := 160;

      FOR rdet IN c_rdet LOOP
         BEGIN
            vpas := 170;
          INSERT INTO SIN_TRAMITA_RESERVADET (NSINIES,IDRES, NMOVRES, NMOVRESDET, CMONRES, CREEXPRESION, CTRASPASO,
                                              ISALRES, ISALRESAANT, ISALRESAACT, ICONSTRES ,IAUMENRES ,	ILIBERARES, IDISMIRES,
                                              FCAMBIO, ISALRES_MONCIA, ISALRESAANT_MONCIA , ISALRESAACT_MONCIA , ICONSTRES_MONCIA ,
                                              IAUMENRES_MONCIA, ILIBERARES_MONCIA ,	IDISMIRES_MONCIA )
                VALUES ( rdet.nsinies, rdet.idres, rdet.nmovres, rdet.nmovresdet+1, rdet.cmonres, 0, 1, rdet.isalres, rdet.isalres, 0, 0, 0, 0, 0,
                         rdet.fcambio, rdet.isalres_moncia, rdet.isalres_moncia, 0, 0, 0, 0, 0);


            IF num_err <> 0 THEN
               RAISE ZERO_DIVIDE;
            END IF;
         EXCEPTION
            -- INI - CJAD - 03/SEP2019 - IAXIS4795 - Error cierre siniestros
			WHEN dup_val_on_index THEN
				 p_traza_proceso(pcempres, 'TRAZA_CIERRE_PROP', psproces, vobj, vproc, NULL, vpas,
								 'DUP_VAL_ON_INDEX: ' || '-' || SQLCODE || '-' || SQLERRM);
			WHEN no_data_found THEN
				 p_traza_proceso(pcempres, 'TRAZA_CIERRE_PROP', psproces, vobj, vproc, NULL, vpas,
								 'NO_DATA_FOUND: ' || '-' || SQLCODE || '-' || SQLERRM);
			 -- FIN - CJAD - 03/SEP2019 - IAXIS4795 - Error cierre siniestros		 
            WHEN OTHERS THEN
               n_contaerr := n_contaerr + 1;
               v_numlin := NULL;
               num_err := f_proceslin(psproces,
                                      rdet.nsinies || '-' || rdet.idres
                                     || '-' || vpas || ' error='
                                      || num_err || '-' || SQLCODE,
                                      0, v_numlin);
				-- INI - CJAD - 03/SEP2019 - IAXIS4795 - Error cierre siniestros
				p_traza_proceso(pcempres, 'TRAZA_CIERRE_PROP', psproces, vobj, vproc, NULL, vpas,
								 'OTHERS: ' || '-' || SQLCODE || '-' || SQLERRM);
				-- FIN - CJAD - 03/SEP2019 - IAXIS4795 - Error cierre siniestros
               ROLLBACK;
         END;

         COMMIT;
      END LOOP;

   EXCEPTION
      WHEN e_salida THEN
         NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobj, vpas, vpar,
                     num_err || ' ' || SQLCODE || ' ' || SQLERRM);
         pcerror := 1;
   END p_cierre_anual;
END pac_siniestros_conf;

/
