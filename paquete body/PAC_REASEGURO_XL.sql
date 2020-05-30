--------------------------------------------------------
--  DDL for Package Body PAC_REASEGURO_XL
--------------------------------------------------------

create or replace PACKAGE BODY pac_reaseguro_xl IS
	 /******************************************************************************
    NOMBRE:      PAC_REASEGURO_XL
    PROPÓSITO:   Proceso batch mensual que realiza liquidación al Reaseguro XL
    REVISIONES:
    Ver  Fecha       Autor  Descripción
    ---  ----------  -----  ------------------------------------
    1.0  --/--/----  ---    1. Creación del package.
    2.0  01/12/2011  JGR    2. 0020023: Reaseguro XL
    3.0  22/02/2012  JMF    3. 0021411: calculo del XL
    4.0  27/02/2012  AVT    4. 0021411: LCOL_A002-Error en el calculo del XL.
    5.0  12/03/2012  JMF    5. 0021638 MdP - TEC - Indices de revalorización nuevos (IPCV, BEC, ...)
    6.0  25/05/2012  AVT    6. 0022076: LCOL_A004-Mantenimientos de cuenta tecnica del reaseguro y del coaseguro
    7.0  02/07/2012  JMF    7. 0022683: LCOL_A002-Qtracker: 4600: La cesi?n de siniestros XL no es correcta (C?LCULO)
    8.0  18/09/2012  AVT    8. 0022076: LCOL_A004-Mantenimientos de cuenta tecnica del reaseguro y del coaseguro (S'AJUSTA EL FRACCIONAMENT PMD)
    9.0  28/09/2012  AVT    9. 0022076: LCOL_A004-Mantenimientos de cuenta tecnica del reaseguro y del coaseguro (Treure la PMD del cursor de sinistres)
   10.0  18/10/2012  AVT   10. 0022376: LCOL_A004-Listados de reaseguro/coaseguro - Fase 2   (falta guardar comptes a nivell de sinistre)
   11.0  11/01/2013  AVT   11. 0022678: LCOL_A002-Qtracker: 0004601: Error en cuenta tecnica de XL
   12.0  11/01/2013  AVT   12. 0024463: LCOL_A004-Companyies Vida/No Vida de LCOL als Tancaments REA
   13.0  11/03/2013  KBR   13. 0026327: LCOL_F002-Errores en la contabilización de Reaseguro
   14.0  20/03/2013  KBR   14. 0025822: RSA003 - Se debe incluir la historificación de los impuestos y rating en las cias reaseguradoras
   15.0  17/04/2013  KBR   15. 0022678: LCOL_A002-Qtracker: 0004601: Ajustamos cálculo del % para que considere si el siniestro supera la cap. máxima
   16.0  22/05/2013  KBR   16. 0022678: LCOL_A002-Qtracker: 0004601: Evitar divisor por cero cuando no exista parte protegida
   17.0  06/06/2013  KBR   17. 0022678: LCOL_A002-Qtracker: 0004601: Error en pagos de cuenta técnica
   18.0  28/06/2013  KBR   18. 0022678: LCOL_A002-Qtracker: Gestión de contratos XL por Eventos.
   19.0  18/07/2013  KBR   19. 0022678: LCOL_A002-Qtracker: 0004600: La cesión de siniestros XL no es correcta.
   20.0  24/07/2013  ETM   20. 0025860/149606: (POSDE400)-Desarrollo-GAPS Reaseguro, Coaseguro -Id 81 - Monitorizacion tasas variables/comisiones (Fase 1)
   21.0  22/08/2013  KBR   21. 0027847: LCOL_A004-Qtracker: 0008669: Error en XL por Eventos (eliminar agrupación por garantía)
   22.0  10/09/2013  DCT   22. 0023830: LCOL_A004 Ajustar el Manteniment dels Comptes de Reasseguranca (Nota: 22076/0123753)
   23.0  18/09/2013  KBR   23. 0022678: LCOL_A002-Qtracker: 0004601: Error en cuenta tecnica de XL (Ajustes en cierre XL)
   24.0  11/12/2013  KBR   24. 0027683: LCOL_A004-Qtracker: 8622 (9207, 9272): Cesion siniestro contrato no proporcional por evento XL
   25.0  11/12/2013  KBR   25. 0027751: LCOL_A004-Qtracker: 0008640: REA-LCOL_ADM-08_Contratos_Reaseguro CLF3A-1915 Validar la cesion de siniestros contrato XL autos
   26.0  13/12/2013  KBR   26. 0028777: Incidencia 28761: POSREA Reaseguro facultativo (Ajustes en cierre de reaseguro XL)
   27.0  19/11/2013  KBR   27. 0022678: LCOL_A002-Qtracker: Gestión de contratos XL por Siniestros/Eventos.
   28.0  03/12/2013  KBR   28. 0027683: LCOL_A004-Qtracker: 8622 (9207, 9272): Cesion siniestro contrato no proporcional por evento XL
   29.0  09/12/2013  KBR   29. 0028991: (POSPG400)-Parametrización de los siniestros en Cúmulo.
   30.0  13/12/2013  KBR   30. 0029342: LCOL_A004-Qtracker: 0010468 y 0010469 XL por Eventos y riesgo (Autos)
   31.0  19/12/2013  DCT   31. 0023830: LCOL_A004 Ajustar el Manteniment dels Comptes de Reasseguranca (Nota: 22076/0123753)
   32.0  24/12/2013  AVT   32. 0029484: LCOL_A004-Qtracker: 0010693: NO GENERA CIERRE PREVIO-PROGRAMADO REASEGURO XL
   33.0  14/01/2014  KBR   33. 0022683: LCOL_A002-Qtracker: 4600: La cesi?n de siniestros XL no es correcta (C?LCULO)
   34.0  13/02/2014  DCT   34. 0022683: LCOL_A002-Qtracker: 4600: La cesi?n de siniestros XL no es correcta (C?LCULO)
   35.0  14/02/2014  DCT   35. 0028492: LCOLF3BREA-Revisi?n de los contratos de REASEGURO F3B (TASA FIJA de ajuste para LCOL)
   36.0  18/02/2014  AGG   36. 0026663: POSPG400-(POSPG400)- Parametrizacion Reaseguro, Coaseguro - Parametrizacion contratos
   37.0  05/03/2014  DCT   37. 0028492: LCOLF3BREA-Revisi?n de los contratos de REASEGURO F3B
   38.0  10/03/2014  KBR   38. 0026663: 0028991: (POSPG400)-Parametrizacion - Multitramos y Reinstalamientos
   39.0  08/04/2014  AGG   39. Se saca la funcion p_traza_proceso, para que sea un procedimiento generico
   40.0  26/05/2014  KBR   40. Gap 13 - Pagos irregulares de la PMD
   41.0  10/06/2014  KBR   41. 0031730: LCOL_A002-Qtracker: 0012919: No muestra movimientos realizados en siniestros realizados despues de un cierre definitivo reasegur
   42.0  13/06/2014  AGG   42.
   43.0  26/06/2014  KBR   43. 0028854: LCOL_A004-Qtracker: 9859 / 9855: Generar planilla de siniestros pagados/pendientes contrato no proporcional
   44.0  30/06/2014  SHA   44. 0030203: LCOL_A004-Qtracker: 8993, 8995, 9865, 8987, 8991 Liquidaci?n de saldos
   45.0  08/07/2014  SHA   45. 0028475: LCOL_A004-Qtracker: 9549: Revision del reporte de la Cuenta T?cnica Reaseguro Automatio Cedido- Contratos No Proporcionales
   46.0  22/07/2014  KBR   46. 0028475: LCOL_A004-Qtracker: 9549: Revision del reporte de la Cuenta T?cnica Reaseguro Automatio Cedido- Contratos No Proporcionales
   47.0  09/09/2014  KBR   47. 0028475: LCOL_A004-Qtracker: 9549: Revision del reporte de la Cuenta T?cnica Reaseguro Automatio Cedido- Contratos No Proporcionales
   48.0  15/10/2014  KBR   48. 0028475: LCOL_A004-Qtracker: 9549: Revision del reporte de la Cuenta T?cnica Reaseguro Automatio Cedido- Contratos No Proporcionales
   49.0  04/11/2014  KBR   49. 0028475: LCOL_A004-Qtracker: 9549: Revision del reporte de la Cuenta T?cnica Reaseguro Automatio Cedido- Contratos No Proporcionales
   50.0  06/11/2014  KBR   50. 0033322: QT 0015300: Distribución de siniestros XL INNOMINADO
   51.0  11/11/2014  SHA   51. 0028475: LCOL_A004-Qtracker: 9549: Revision del reporte de la Cuenta T?cnica Reaseguro Automatio Cedido- Contratos No Proporcionales
   52.0  27/11/2014  KBR   52. 0033681: LCOL_A004-0015675: Validar la cesion de prima a contratos no proporcionales- prima reinstalamento
   53.0  28/11/2014  KBR   53. 0033322: QT 0015300: Distribución de siniestros XL INNOMINADO
   54.0  25/05/2015  CJMR  54. 0033158: Actualización campo CCORRED en los cierres de Reaseguro
   55.0  23/12/2019  INFORCOL 55.0 Reaseguro Fase 1 Sprint 3 Ajustes para reaseguro NO proporcional
   56.0  30/12/2019  INFORCOL 56.0 Reaseguro Fase 1 Sprint 3 Ajustes para reaseguro NO proporcional
   ******************************************************************************/
	 pcerror  NUMBER := 0;
	 psproces NUMBER;
	 pfproces DATE;

	 TYPE t_registro IS VARRAY(23000) OF c_reg%ROWTYPE;

	 FUNCTION f_insertxl_movctatecnica(p_ctadet IN NUMBER, p_movsin IN c_reg%ROWTYPE, p_nnumlin IN NUMBER,
																		 p_concept IN NUMBER, p_cia IN NUMBER, p_import IN NUMBER,
																		 p_pproces IN NUMBER, p_cestado IN NUMBER, p_pcempres IN NUMBER,
																		 p_pcierre IN DATE, p_ccorred IN NUMBER) -- 25/05/2015  CJMR  0033158: Actualización campo CCORRED en los cierres de Reaseguro
		RETURN NUMBER IS
			vobj      VARCHAR2(200) := 'PAC_REASEGURO_XL.f_insertxl_movctatecnica';
			v_numero  NUMBER;
			v_cdebhab NUMBER;
			v_nerror  NUMBER := 0;
			v_traza   NUMBER := 0;
			v_plsql   VARCHAR2(500);
	 BEGIN
			-- detall a nivell de sinistre
			IF NVL(p_ctadet, 0) = 1 THEN
				 v_traza := 1;
			
				 SELECT COUNT(1)
					 INTO v_numero
					 FROM movctaaux
					WHERE scontra = p_movsin.scontra
						AND nversio = p_movsin.nversio
						AND ctramo = p_movsin.ctramo
						AND ccompani = p_cia
						AND cconcep = p_concept
						AND (sproduc = p_movsin.sproduc OR NVL(sproduc, 0) = 0)
						AND nsinies = p_movsin.nsinies;
			ELSE
				 v_traza := 2;
			
				 SELECT COUNT(1)
					 INTO v_numero
					 FROM movctaaux
					WHERE scontra = p_movsin.scontra
						AND nversio = p_movsin.nversio
						AND ctramo = p_movsin.ctramo
						AND ccompani = p_cia
						AND cconcep = p_concept
						AND (sproduc = p_movsin.sproduc OR NVL(sproduc, 0) = 0);
			END IF;
	 
			-->> Prestaciones pagadas  (liquidadas al XL o de pagos aceptados al proporcional)
			IF v_numero > 0 THEN
				 -- detall a nivell de sinistre
				 IF NVL(p_ctadet, 0) = 1 THEN
						BEGIN
							 v_traza := 3;
						
							 UPDATE movctaaux
									SET iimport = iimport + p_import
								WHERE scontra = p_movsin.scontra
									AND nversio = p_movsin.nversio
									AND ctramo = p_movsin.ctramo
									AND ccompani = p_cia
									AND cconcep = p_concept
									AND (sproduc = p_movsin.sproduc OR NVL(sproduc, 0) = 0)
									AND NVL(ccompapr, 0) = NVL(p_movsin.ccompapr, 0)
									AND nsinies = p_movsin.nsinies;
						EXCEPTION
							 WHEN OTHERS THEN
									v_nerror := 105801;
									v_plsql  := SUBSTR(SQLERRM, 1, 500);
									p_tab_error(f_sysdate, f_user, vobj, v_traza, 'Err UPDATE movctaaux - cconcep = ' || p_concept,
															' v_iliqrea=' || p_import || ' v_scontra=' || p_movsin.scontra || ' v_nversio=' ||
															 p_movsin.nversio || ' v_ctramo=' || p_movsin.ctramo || ' compa.ccompani=' || p_cia ||
															 ' sini.nsin:' || p_movsin.nsinies || ' SQLERRM = ' || v_plsql);
						END;
				 ELSE
						BEGIN
							 v_traza := 4;
						
							 UPDATE movctaaux
									SET iimport = iimport + p_import
								WHERE scontra = p_movsin.scontra
									AND nversio = p_movsin.nversio
									AND ctramo = p_movsin.ctramo
									AND ccompani = p_cia
									AND cconcep = p_concept
									AND NVL(ccompapr, 0) = NVL(p_movsin.ccompapr, 0)
									AND (sproduc = p_movsin.sproduc OR NVL(sproduc, 0) = 0);
						EXCEPTION
							 WHEN OTHERS THEN
									v_nerror := 105801;
									v_plsql  := SUBSTR(SQLERRM, 1, 500);
									p_tab_error(f_sysdate, f_user, vobj, v_traza, 'Err UPDATE movctaaux - cconcep = ' || p_concept,
															' v_iliqrea=' || p_import || ' v_scontra=' || p_movsin.scontra || ' v_nversio=' ||
															 p_movsin.nversio || ' v_ctramo=' || p_movsin.ctramo || ' compa.ccompani=' || p_cia ||
															 ' SQLERRM = ' || v_plsql);
						END;
				 END IF;
			ELSE
				 -- detall a nivell de sinistre
				 --KBR 11/12/2013
				 IF p_import <> 0 THEN
						BEGIN
							 v_traza := 5;
						
							 --30203-178381: SHA 30/06/2014
							 SELECT cdebhab
								 INTO v_cdebhab
								 FROM tipoctarea
								WHERE cconcep = p_concept
									AND cempres = p_pcempres;
						
							 INSERT INTO movctaaux
									(ccompani, nversio, scontra, ctramo, nnumlin, fmovimi, fefecto, cconcep, cdebhab, iimport,
									 cestado, sproces, scesrea, cempres, fcierre, sproduc, nsinies, ccompapr, cevento, ccorred) -- 25/05/2015  CJMR  0033158: Actualización campo CCORRED en los cierres de Reaseguro
							 VALUES
									(p_cia, p_movsin.nversio, p_movsin.scontra, p_movsin.ctramo, p_nnumlin,
									 LAST_DAY(TO_DATE('01/' || TO_CHAR(p_movsin.fsinies, 'mm') || '/' ||
																		 TO_CHAR(p_movsin.fsinies, 'yyyy'), 'dd/mm/yyyy')),
									 LAST_DAY(TO_DATE('01/' || TO_CHAR(p_movsin.fsinies, 'mm') || '/' ||
																		 TO_CHAR(p_movsin.fsinies, 'yyyy'), 'dd/mm/yyyy')), p_concept, v_cdebhab,
									 p_import, p_cestado, p_pproces, NULL, p_pcempres, p_pcierre, p_movsin.sproduc,
									 DECODE(NVL(p_ctadet, 0), 1, p_movsin.nsinies, 0), p_movsin.ccompapr, p_movsin.cevento,
									 p_ccorred); -- 25/05/2015  CJMR  0033158: Actualización campo CCORRED en los cierres de Reaseguro
						EXCEPTION
							 WHEN dup_val_on_index THEN
									v_nerror := 105800;
									v_plsql  := SUBSTR(SQLERRM, 1, 500);
									p_tab_error(f_sysdate, f_user, vobj, v_traza,
															'Err DUPLICADO INSERT movctaaux - cconcep = ' || p_concept,
															' v_scontra=' || p_movsin.scontra || ' v_nversio=' || p_movsin.nversio ||
															 ' v_ctramo=' || p_movsin.ctramo || ' compa.ccompani=' || p_cia || ' SQLERRM = ' ||
															 v_plsql);
							 WHEN OTHERS THEN
									v_nerror := 105802;
									v_plsql  := SUBSTR(SQLERRM, 1, 500);
									p_tab_error(f_sysdate, f_user, vobj, v_traza, 'Err INSERT movctaaux - cconcep = ' || p_concept,
															' v_scontra=' || p_movsin.scontra || ' v_nversio=' || p_movsin.nversio ||
															 ' v_ctramo=' || p_movsin.ctramo || ' compa.ccompani=' || p_cia || ' SQLERRM = ' ||
															 v_plsql);
						END;
				 END IF;
			END IF;
	 
			RETURN v_nerror;
	 END; --f_insertxl_movctatecnica

	 ---------
	 FUNCTION f_xl_siniestros_con_cumulo(p_pcempres IN NUMBER, p_pdefi IN NUMBER, p_pipc IN NUMBER,
																			 p_pmes IN NUMBER, p_pany IN NUMBER, p_pfcierre IN DATE,
																			 p_pproces IN NUMBER, p_pscesrea OUT NUMBER, p_pfperini IN DATE,
																			 p_pfperfin IN DATE, o_plsql OUT VARCHAR2) RETURN NUMBER IS
			CURSOR c_sincum(p_fechacorte IN DATE) IS
				 SELECT cumulo, cramo, SUM(isinret) totalcum_ret, SUM(ireserva) totalevto_res --KBR 14/01/2014
					 FROM (SELECT DISTINCT s.cempres, s.ccompani ccompapr, s.sproduc, cr.scumulo cumulo, si.fsinies fsin,
																	si.fnotifi fnot, si.sseguro sseg, si.nriesgo nrie,
																	TO_CHAR(si.fsinies, 'mm') mes_sin, TO_CHAR(si.fsinies, 'yyyy') anyo_sin,
																	si.ncuacoa ncua, s.cramo cramo,
																	SUM(DECODE(NVL(ps.sidepag, 0), 0, 0,
																							DECODE(ps.ctippag, 8, NVL(pg.isinretpag, 0), 2, NVL(pg.isinretpag, 0),
																											NVL(-pg.isinretpag, 0)))) isinret, 0 ireserva --KBR 14/01/2014
										FROM sin_tramita_pago ps, sin_siniestro si, sin_tramita_pago_gar pg, sin_tramita_movpago pm,
												 seguros s, reariesgos cr -- 29484 AVT 23/12/2013
									 WHERE ps.nsinies(+) = si.nsinies
										 AND si.sseguro = s.sseguro
										 AND EXISTS
									 (SELECT 1 FROM cesionesrea cr WHERE cr.sseguro = s.sseguro)
										 AND ps.sidepag = pg.sidepag(+)
										 AND ps.sidepag = pm.sidepag(+)
												-- Parámetro de empresa que especifíca el estado del pago para su tramitación
										 AND pm.cestpag = NVL(pac_parametros.f_parempresa_n(p_pcempres, 'EDO_PAGO_PROCESA_REA'), 2)
												-- No Anulaciones
										 AND NOT EXISTS (SELECT 1
														FROM sin_tramita_movpago pm2
													 WHERE pm2.sidepag = pm.sidepag
														 AND pm2.cestpag = 8)
												--
										 AND si.falta <= p_fechacorte
										 AND cempres = p_pcempres
										 AND si.cevento IS NULL
										 AND cr.sseguro = s.sseguro
										 AND (cr.freafin <= p_fechacorte OR cr.freafin IS NULL)
									 GROUP BY s.cempres, s.ccompani, s.sproduc, cr.scumulo, si.fsinies, si.fnotifi, si.sseguro,
														si.nriesgo, TO_CHAR(si.fsinies, 'mm'), TO_CHAR(si.fsinies, 'yyyy'), si.ncuacoa, s.cramo
									UNION ALL
									SELECT DISTINCT s.cempres, s.ccompani ccompapr, s.sproduc, cr.scumulo cumulo, si.fsinies fsin,
																	si.fnotifi fnot, si.sseguro sseg, si.nriesgo nrie,
																	TO_CHAR(si.fsinies, 'mm') mes_sin, TO_CHAR(si.fsinies, 'yyyy') anyo_sin,
																	si.ncuacoa ncua, s.cramo cramo, 0 isinret,
																	NVL(sr.ireserva_moncia, 0) + (CASE
																																		WHEN NVL(sr.ipago_moncia, 0) < 0 THEN
																																		 0
																																		ELSE
																																		 NVL(sr.ipago_moncia, 0)
																																 END) ireserva --KBR 14/01/2014
										FROM sin_siniestro si, seguros s, sin_tramita_reserva sr, reariesgos cr --29484 AVT 23/12/2013
									 WHERE si.sseguro = s.sseguro
										 AND EXISTS
									 (SELECT 1 FROM cesionesrea cr WHERE cr.sseguro = s.sseguro)
										 AND si.falta <= p_fechacorte
										 AND si.cevento IS NULL
										 AND cempres = p_pcempres
										 AND si.nsinies = sr.nsinies
                                                                                 --IAXIS-13057 AABC quitar la reserva ULAE
                                                                                 AND sr.ctipres <> 5
                                                                                 --IAXIS-13057 AABC quitar la reserva ULAE
										 AND (NVL(ipago, 0) = 0 OR
												 sr.sidepag IN (SELECT sidepag
																					 FROM sin_tramita_movpago stm
																					WHERE stm.sidepag = sr.sidepag
																						AND stm.cestpag IN (0, 1, 8,
																																DECODE(NVL(pac_parametros.f_parempresa_n(p_pcempres,
																																																					'EDO_PAGO_PROCESA_REA'),
																																						2), 2, 9, 0))
																						AND stm.nmovpag IN (SELECT MAX(nmovpag)
																																	FROM sin_tramita_movpago stm2
																																 WHERE stm.sidepag = stm2.sidepag)))
										 AND sr.nmovres IN (SELECT MAX(nmovres)
																					FROM sin_tramita_reserva ss
																				 WHERE ss.nsinies = sr.nsinies
																					 AND sr.ntramit = ss.ntramit
																					 AND ss.ctipres = sr.ctipres
																					 AND ss.cgarant = sr.cgarant
																					 AND ss.sidepag = sr.sidepag
																					 AND NVL(ss.ctipgas, 0) = NVL(sr.ctipgas, 0)
																					 AND ss.fmovres <= p_fechacorte
																				UNION
																				SELECT MAX(nmovres)
																					FROM sin_tramita_reserva ss
																				 WHERE ss.nsinies = sr.nsinies
																					 AND sr.ntramit = ss.ntramit
																					 AND ss.ctipres = sr.ctipres
																					 AND ss.cgarant = sr.cgarant
																					 AND NVL(ss.ctipgas, 0) = NVL(sr.ctipgas, 0)
																					 AND ss.fmovres <= p_fechacorte)
										 AND cr.sseguro = s.sseguro
										 AND (cr.freafin <= p_fechacorte OR cr.freafin IS NULL)
									 GROUP BY s.cempres, s.ccompani, s.sproduc, cr.scumulo, si.fsinies, si.fnotifi, si.sseguro,
														si.nriesgo, TO_CHAR(si.fsinies, 'mm'), TO_CHAR(si.fsinies, 'yyyy'), si.ncuacoa, s.cramo,
														NVL(sr.ireserva_moncia, 0) + (CASE
																															WHEN NVL(sr.ipago_moncia, 0) < 0 THEN
																															 0
																															ELSE
																															 NVL(sr.ipago_moncia, 0)
																													 END))
					GROUP BY cumulo, cramo
					ORDER BY cumulo;
	 
			CURSOR c_sincum_det(p_scumulo IN NUMBER, p_pcramo IN NUMBER, p_fechacorte IN DATE) IS
				 SELECT sproduc, ccompapr, nsin, fsin, fnot, ctipres, mes_pag, anyo_pag, sseg, nrie, mes_sin, anyo_sin,
								ncua, cramo, cgar, ctippag, SUM(ireserva) totireserva, SUM(isinpag) totisinpag
					 FROM (SELECT DISTINCT s.sproduc, s.ccompani ccompapr, si.nsinies nsin, si.fsinies fsin, si.fnotifi fnot,
																	ps.sidepag, sr.ctipres, TO_CHAR(pm.fefepag, 'mm') mes_pag,
																	TO_CHAR(pm.fefepag, 'yyyy') anyo_pag, si.sseguro sseg, si.nriesgo nrie,
																	TO_CHAR(si.fsinies, 'mm') mes_sin, TO_CHAR(si.fsinies, 'yyyy') anyo_sin,
																	si.ncuacoa ncua, sr.cgarant cgar, s.cramo cramo, ps.ctippag,
																	NVL(sr.ireserva_moncia, 0) ireserva,
																	SUM(NVL(ps.isinretpag, 0) + NVL(ps.isuplidpag, 0)) isinpag
										FROM sin_tramita_pago ps, sin_siniestro si, sin_tramita_movpago pm, seguros s,
												 sin_tramita_reserva sr, garanpro gp, reariesgos cr -- 29484 AVT 23/12/2013
									 WHERE cr.scumulo = p_scumulo
										 AND cr.sseguro = s.sseguro
										 AND (cr.freafin <= p_fechacorte OR cr.freafin IS NULL)
										 AND ps.nsinies = si.nsinies
										 AND ps.sidepag = sr.sidepag
                                                                                 --IAXIS-13057 AABC quitar la reserva ULAE
                                                                                 AND sr.ctipres <> 5
                                                                                 --IAXIS-13057 AABC quitar la reserva ULAE
										 AND ps.sidepag = pm.sidepag
										 AND pm.cestpag = NVL(pac_parametros.f_parempresa_n(p_pcempres, 'EDO_PAGO_PROCESA_REA'), 2)
												-- No Anulaciones
										 AND NOT EXISTS (SELECT 1
														FROM sin_tramita_movpago pm2
													 WHERE pm2.sidepag = pm.sidepag
														 AND pm2.cestpag = 8)
												--
										 AND si.falta <= p_fechacorte
										 AND si.sseguro = s.sseguro
										 AND cempres = p_pcempres
										 AND si.nsinies = sr.nsinies
										 AND ps.ntramit = sr.ntramit
										 AND gp.sproduc = s.sproduc
										 AND gp.cgarant = sr.cgarant
										 AND gp.cactivi = NVL(s.cactivi, 0)
										 AND gp.creaseg IN (1, 2)
										 AND s.cramo = p_pcramo
										 AND sr.nmovres IN (SELECT MAX(nmovres)
																					FROM sin_tramita_reserva ss
																				 WHERE ss.nsinies = sr.nsinies
																					 AND sr.ntramit = ss.ntramit
																					 AND ss.ctipres = sr.ctipres
																					 AND ss.cgarant = sr.cgarant
																					 AND NVL(ss.ctipgas, 0) = NVL(sr.ctipgas, 0)
																					 AND ss.fmovres <= p_fechacorte)
									 GROUP BY s.sproduc, s.ccompani, si.nsinies, si.fsinies, si.fnotifi, ps.sidepag, sr.ctipres,
														TO_CHAR(pm.fefepag, 'mm'), TO_CHAR(pm.fefepag, 'yyyy'), si.sseguro, si.nriesgo,
														TO_CHAR(si.fsinies, 'mm'), TO_CHAR(si.fsinies, 'yyyy'), si.ncuacoa, sr.cgarant, s.cramo,
														ps.ctippag, NVL(sr.ireserva_moncia, 0)
									UNION ALL
									SELECT DISTINCT s.sproduc, s.ccompani ccompapr, si.nsinies nsin, si.fsinies fsin, si.fnotifi fnot,
																	0 sidepag, sr.ctipres, TO_CHAR(p_pfperfin, 'mm') mes_pag,
																	TO_CHAR(p_pfperfin, 'yyyy') anyo_pag, si.sseguro sseg, si.nriesgo nrie,
																	TO_CHAR(si.fsinies, 'mm') mes_sin, TO_CHAR(si.fsinies, 'yyyy') anyo_sin,
																	si.ncuacoa ncua, sr.cgarant cgar, s.cramo cramo, 0 ctippag,
																	NVL(sr.ireserva_moncia, 0) + (CASE
																																		WHEN NVL(sr.ipago_moncia, 0) < 0 THEN
																																		 0
																																		ELSE
																																		 NVL(sr.ipago_moncia, 0)
																																 END) ireserva, 0 isinpag
										FROM sin_siniestro si, seguros s, sin_tramita_reserva sr, garanpro gp, reariesgos cr -- 29484 AVT 23/12/2013
									 WHERE cr.sseguro = s.sseguro
										 AND cr.scumulo = p_scumulo
										 AND (cr.freafin <= p_fechacorte OR cr.freafin IS NULL)
										 AND si.sseguro = s.sseguro
										 AND si.falta <= p_fechacorte
										 AND cempres = p_pcempres
										 AND si.nsinies = sr.nsinies
                                                                                 --IAXIS-13057 AABC quitar la reserva ULAE
                                                                                 AND sr.ctipres <> 5
                                                                                 --IAXIS-13057 AABC quitar la reserva ULAE
										 AND gp.sproduc = s.sproduc
										 AND gp.cgarant = sr.cgarant
										 AND gp.cactivi = NVL(s.cactivi, 0)
										 AND gp.creaseg IN (1, 2)
										 AND s.cramo = p_pcramo
										 AND (NVL(ipago, 0) = 0 OR
												 sr.sidepag IN (SELECT sidepag
																					 FROM sin_tramita_movpago stm
																					WHERE stm.sidepag = sr.sidepag
																						AND stm.cestpag IN (0, 1, 8,
																																DECODE(NVL(pac_parametros.f_parempresa_n(p_pcempres,
																																																					'EDO_PAGO_PROCESA_REA'),
																																						2), 2, 9, 0))
																						AND stm.nmovpag IN (SELECT MAX(nmovpag)
																																	FROM sin_tramita_movpago stm2
																																 WHERE stm.sidepag = stm2.sidepag)))
										 AND sr.nmovres IN (SELECT MAX(nmovres)
																					FROM sin_tramita_reserva ss
																				 WHERE ss.nsinies = sr.nsinies
																					 AND sr.ntramit = ss.ntramit
																					 AND ss.ctipres = sr.ctipres
																					 AND ss.cgarant = sr.cgarant
																					 AND ss.sidepag = sr.sidepag
																					 AND NVL(ss.ctipgas, 0) = NVL(sr.ctipgas, 0)
																					 AND ss.fmovres <= p_fechacorte
																				UNION
																				SELECT MAX(nmovres)
																					FROM sin_tramita_reserva ss
																				 WHERE ss.nsinies = sr.nsinies
																					 AND sr.ntramit = ss.ntramit
																					 AND ss.ctipres = sr.ctipres
																					 AND ss.cgarant = sr.cgarant
																					 AND NVL(ss.ctipgas, 0) = NVL(sr.ctipgas, 0)
																					 AND ss.fmovres <= p_fechacorte)
										 AND NVL(sr.ireserva_moncia, 0) + NVL(sr.ipago_moncia, 0) <> 0
										 AND NOT EXISTS
									 (SELECT 1
														FROM sin_tramita_reserva tt, sin_tramita_movpago pp
													 WHERE tt.nsinies = sr.nsinies
														 AND tt.cgarant = sr.cgarant
														 AND NVL(tt.ctipgas, 0) = NVL(sr.ctipgas, 0)
														 AND pp.sidepag = tt.sidepag
														 AND pp.cestpag =
																 NVL(pac_parametros.f_parempresa_n(p_pcempres, 'EDO_PAGO_PROCESA_REA'), 2)
														 AND tt.fmovres <= p_fechacorte
														 AND NOT EXISTS (SELECT 1
																		FROM sin_tramita_movpago pm2
																	 WHERE pm2.sidepag = pp.sidepag
																		 AND pm2.cestpag = 8))
									 GROUP BY s.sproduc, s.ccompani, si.nsinies, si.fsinies, si.fnotifi, sr.ctipres,
														TO_CHAR(p_pfperfin, 'mm'), TO_CHAR(p_pfperfin, 'yyyy'), si.sseguro, si.nriesgo,
														TO_CHAR(si.fsinies, 'mm'), TO_CHAR(si.fsinies, 'yyyy'), si.ncuacoa, sr.cgarant, s.cramo,
														NVL(sr.ireserva_moncia, 0) + (CASE
																															WHEN NVL(sr.ipago_moncia, 0) < 0 THEN
																															 0
																															ELSE
																															 NVL(sr.ipago_moncia, 0)
																													 END))
					GROUP BY sproduc, ccompapr, nsin, fsin, fnot, ctipres, mes_pag, anyo_pag, sseg, nrie, mes_sin, anyo_sin,
									 ncua, cramo, cgar, ctippag
					ORDER BY nsin, mes_pag, anyo_pag;
	 
			CURSOR c_cuadroces_agr(ctr NUMBER, ver NUMBER, tram NUMBER) IS
				 SELECT c.ccompani, c.ctramo, c.iagrega, c.imaxagr, c.pcesion, ct.fconini, 0 iminagr, ccorred
					 FROM cuadroces c, contratos ct
					WHERE c.scontra = ct.scontra
						AND c.nversio = ct.nversio
						AND c.scontra = ctr
						AND c.nversio = ver
						AND c.ctramo = tram
						AND c.ccompani > 1
						AND pac_reaseguro_rec.f_compania_cutoff(c.ccompani, TRUNC(SYSDATE)) = 0; --CONF-910
	 
			vobj               VARCHAR2(200) := 'PAC_REASEGURO_XL.f_xl_sin_cum';
			nerr               NUMBER := 0;
			pnnumlin           NUMBER;
			texto              VARCHAR2(200);
			num_impliq         NUMBER;
			v_scontra          NUMBER;
			v_nversio          NUMBER;
			v_ctramo           NUMBER;
			v_ipleno           contratos.iretenc%TYPE;
			v_icapaci          contratos.icapaci%TYPE;
			v_iprioxl_ctto     contratos.iprioxl%TYPE;
			v_iprioxl_tramo    tramos.ixlprio%TYPE;
			v_caplixl          tramos.caplixl%TYPE;
			v_ixlprio          tramos.ixlprio%TYPE;
			v_imaxagr          NUMBER;
			v_iminagr          NUMBER;
			v_plimgas          tramos.plimgas%TYPE;
			v_hay              NUMBER;
			v_pliminx          NUMBER;
			v_ipagrea_tot      NUMBER := 0;
			v_pagosanteriores  NUMBER;
			v_ipc              NUMBER(8, 5);
			v_ipc_fecha_base   NUMBER(8, 5);
			v_ipc_fecha_pago   NUMBER(8, 5);
			v_pago_indexado    liquidareaxl_aux.itotind%TYPE;
			v_pago_no_indexado liquidareaxl_aux.itotexp%TYPE;
			v_pago_xl          NUMBER(15, 2);
			v_ireserv          liquidareaxl_aux.ireserv%TYPE := 0;
			v_pcuorea          liquidareaxl_aux.pcuorea%TYPE;
			v_icuorea          liquidareaxl_aux.icuorea%TYPE;
			v_iliqrea          liquidareaxl_aux.iliqrea%TYPE;
			v_iliqrea_cia      movctaaux.iimport%TYPE;
			v_iresind          liquidareaxl_aux.iresind%TYPE;
			v_pcuotot          liquidareaxl_aux.pcuotot%TYPE;
			v_itotrea          liquidareaxl_aux.itotrea%TYPE;
			v_iresrea          liquidareaxl_aux.iresrea%TYPE;
			v_iresrea_cia      movctaaux.iimport%TYPE;
			v_ilimind          liquidareaxl_aux.ilimind%TYPE;
			v_iliqrea_pag      liquidareaxl_aux.iliqnet%TYPE;
			v_iliqrea_pag_cia  NUMBER;
			v_iliqrea_cum      cuadroces.iagrega%TYPE := 0;
			v_iliqrea_lim      pagosreaxl_aux.iliqrea%TYPE := 0;
			v_iresnet          liquidareaxl_aux.iresnet%TYPE := 0;
			w_nnumlin          NUMBER;
			v_numero           NUMBER;
			v_ipagrea          liquidareaxl_aux.ipagrea%TYPE;
			v_cestado          NUMBER;
			v_mes_base         NUMBER;
			v_ano_base         NUMBER;
			v_supera           NUMBER;
			v_iliqrea_tot_cia  NUMBER;
			v_pcesion_act      NUMBER;
			v_pcesion_ini      NUMBER;
			ptipo              VARCHAR2(2);
			v_diferencia       NUMBER := 0;
			v_diferencia_min   NUMBER := 0;
			v_traza            NUMBER;
			v_entro            NUMBER := 0;
			v_cdetces          NUMBER;
			v_cmultimon        parempresas.nvalpar%TYPE := NVL(pac_parametros.f_parempresa_n(p_pcempres, 'MULTIMONEDA'),
																												 0);
			v_cmoncontab       parempresas.nvalpar%TYPE := pac_parametros.f_parempresa_n(p_pcempres, 'MONEDACONTAB');
			v_itasa            eco_tipocambio.itasa%TYPE;
			v_fcambio          DATE;
			v_iresgas_tot      liquidareaxl_aux.iresgas%TYPE;
			v_iresgas          liquidareaxl_aux.iresgas%TYPE;
			v_iresindem_tot    liquidareaxl_aux.iresindem%TYPE;
			v_iresindem        liquidareaxl_aux.iresindem%TYPE;
			v_iresinter_tot    liquidareaxl_aux.iresinter%TYPE;
			v_iresinter        liquidareaxl_aux.iresinter%TYPE;
			v_iresadmin_tot    liquidareaxl_aux.iresadmin%TYPE;
			v_iresadmin        liquidareaxl_aux.iresadmin%TYPE;
			v_hiha_cessio      NUMBER(1);
			v_plocal           NUMBER;
			v_cconcep          NUMBER(2);
			w_ctadet           NUMBER(1);
			w_cconcep          movctaaux.cconcep%TYPE;
			w_cdebhab          movctaaux.cdebhab%TYPE;
			v_cmodali          seguros.cmodali%TYPE;
			v_ctipseg          seguros.ctipseg%TYPE;
			v_ccolect          seguros.ccolect%TYPE;
			v_cactivi          seguros.cactivi%TYPE;
			--JRH Facultavio
			v_diferencia_fac    NUMBER;
			v_facultativo_fac   NUMBER;
			v_pago_indexado_fac NUMBER;
			v_ireserv_fac       NUMBER;
			v_desglose_reserva  NUMBER;
			v_iresgas_tot_fac   NUMBER;
			v_iresindem_tot_fac NUMBER;
			v_iresinter_tot_fac NUMBER;
			v_iresadmin_tot_fac NUMBER;
			v_c_gar             NUMBER;
			v_pct_fac           NUMBER;
			-- ventrar        BOOLEAN := TRUE;
			v_pago_indexado_ant NUMBER;
			v_ireserv_ant       NUMBER;
			v_iresgas_tot_ant   NUMBER := 0;
			v_iresindem_tot_ant NUMBER := 0;
			v_iresinter_tot_ant NUMBER := 0;
			v_iresadmin_tot_ant NUMBER := 0;
			-- KBR 18/09/2013
			v_res_dist    NUMBER;
			v_pag_dist    NUMBER;
			v_cestado_cia NUMBER;
			-------
			v_pago_idx       NUMBER;
			v_pago_no_idx    NUMBER;
			v_reserva        NUMBER;
			v_reserva_ret    NUMBER;
			v_ipagced_xl     NUMBER;
			v_iresced_xl     NUMBER;
			v_presrea        NUMBER;
			v_totalpagos_ret NUMBER;
			v_contador       NUMBER;
			v_sin            NUMBER;
			v_fsin           DATE;
			v_cumul          NUMBER;
			v_sproduc        NUMBER;
			v_ccompapr       NUMBER;
			v_iliqrea_sin    NUMBER;
			v_iresrea_sin    NUMBER;
			v_movsin         t_registro := t_registro();
			--KBR 09/12/2013 REASEGURO_XL (Cumulos)
			v_reserva_mat  NUMBER;
			v_moneda_prod  productos.cdivisa%TYPE;
			v_itasa_prod   eco_tipocambio.itasa%TYPE;
			v_fcambio_prod DATE;
			v_totrea_evto  NUMBER; --KBR 10/12/2013
			v_iced_xl      NUMBER;
			v_prea         NUMBER;
			---
			v_itottra          tramos.itottra%TYPE;
			v_nrepos           NUMBER;
			v_ipmd             tramos.ipmd%TYPE;
			v_crepos           tramos.crepos%TYPE;
			v_nro_repos        NUMBER;
			inicio             NUMBER;
			v_preest           tramos.preest%TYPE;
			v_primareest       NUMBER;
			v_primareest_sin   NUMBER;
			v_ixlcapaci        contratos.icapaci%TYPE;
			v_mov_res          NUMBER;
			v_mov_pag          NUMBER;
			v_reserva_anterior NUMBER := 0;
			v_pagos_anterior   NUMBER := 0;
			v_iresrea_mov      NUMBER := 0;
			v_ipagrea_mov      NUMBER := 0;
			v_nom_paquete      VARCHAR2(80) := 'PAC_REASEGURO_XL';
			v_nom_funcion      VARCHAR2(80) := 'F_XL_SINIESTROS_CON_CUMULO';
			v_porc_tramo_ramo  NUMBER;
			v_cramo            productos.cramo%TYPE;
			v_temp_pagos_ret   NUMBER := 0;
			v_temp_totrea_evto NUMBER := 0;
			v_ixlprio_ant      NUMBER := 0;
			v_total_ant        NUMBER := 0;
			v_fechacorte       DATE;
	 BEGIN
			v_traza      := 1;
			v_fechacorte := p_pfcierre; -- KBR 27/11/2014 Cambiamos por fecha de cierre
			-- Comptes a nivell de sinistres
			p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL, 654,
											'Inicio de proceso. Params de entrada: p_pcempres-' || p_pcempres || ' p_pdefi-' ||
											 p_pdefi || ' p_pipc-' || p_pipc || ' p_pmes-' || p_pmes || ' p_pany-' || p_pany ||
											 ' p_pfcierre-' || p_pfcierre || ' p_pproces-' || p_pproces || ' p_pfperini-' || p_pfperini ||
											 ' p_pfperfin-' || p_pfperfin);
			w_ctadet := pac_parametros.f_parempresa_n(p_pcempres, 'CTACES_DET');
	 
			----------------------------------------------------------------------------
			--     1. inicializamos el IAGREAGA de cuadroces para todas las compañias --
			----------------------------------------------------------------------------
			BEGIN
				 UPDATE cuadroces
						SET iagrega = 0
					WHERE scontra IN (SELECT scontra FROM codicontratos WHERE ctiprea = 3); -- XL
			EXCEPTION
				 WHEN OTHERS THEN
						nerr := 1;
						p_tab_error(f_sysdate, f_user, vobj, v_traza, 'Err UPDATE cuadroces', ' SQLERRM = ' || SQLERRM);
			END;
	 
			-- INICIALIZAR IMPORTES POR EXPDTE:
			v_pagosanteriores   := 0;
			v_pago_xl           := 0;
			v_ipc_fecha_base    := 0;
			v_ipc_fecha_pago    := 0;
			v_iprioxl_ctto      := 0;
			v_iprioxl_tramo     := 0;
			v_ilimind           := 0;
			v_iresgas_tot       := 0;
			v_iresgas           := 0;
			v_iresrea           := 0;
			v_ireserv           := 0;
			v_iresindem_tot     := 0;
			v_iresindem         := 0;
			v_iresinter_tot     := 0;
			v_iresinter         := 0;
			v_iresadmin_tot     := 0;
			v_iresadmin         := 0;
			v_diferencia_fac    := 0;
			v_facultativo_fac   := 0;
			v_pago_indexado_fac := 0;
			v_ireserv_fac       := 0;
			v_desglose_reserva  := 0;
			v_iresgas_tot_fac   := 0;
			v_iresindem_tot_fac := 0;
			v_iresinter_tot_fac := 0;
			v_iresadmin_tot_fac := 0;
			v_c_gar             := 0;
			v_pct_fac           := 0;
			v_pago_indexado_ant := 0;
			v_ireserv_ant       := 0;
			v_iresgas_tot_ant   := 0;
			v_iresindem_tot_ant := 0;
			v_iresinter_tot_ant := 0;
			v_iresadmin_tot_ant := 0;
			------
			v_reserva_ret    := 0;
			v_iresced_xl     := 0;
			v_presrea        := 0;
			v_totalpagos_ret := 0;
			v_cumul          := 0;
			v_sin            := 0;
			v_contador       := 0;
			v_res_dist       := 0;
			v_pag_dist       := 0;
			v_pago_idx       := 0;
			v_pago_no_idx    := 0;
			v_reserva        := 0;
			v_iliqrea_sin    := 0;
			v_iresrea_sin    := 0;
			--KBR 10/12/2013
			v_totrea_evto := 0;
			v_iced_xl     := 0;
			v_prea        := 0;
			----
			v_itottra         := 0;
			v_nrepos          := 0;
			v_ipmd            := 0;
			v_crepos          := 0;
			v_nro_repos       := 0;
			inicio            := 0;
			v_preest          := 0;
			v_porc_tramo_ramo := 100;
	 
			--Cursor que retorna cumulos totalizados por ramo en un período determinado
			FOR sini IN c_sincum(v_fechacorte) LOOP
				 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL, 739,
												 'Evaluando cumulo: ' || sini.cumulo);
			
				 IF v_cumul = 0 THEN
						v_cumul := sini.cumulo;
				 ELSE
						IF v_cumul <> sini.cumulo THEN
							 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL, 746,
															 'Cambia de cumulo, guarda datos en tablas y deja persistente cumulo: ' || v_cumul);
							 --Limites de Pago
							 ----<dbms_OUTPUT.put_line('Cumulo a evaluar: ' || v_cumul);
							 v_totalpagos_ret := v_pago_idx;
							 v_ctramo         := 5; --Facultativo y empezamos a validar a partir del primer tramo XL
							 v_reserva_ret    := v_reserva;
							 v_ixlprio_ant    := 0;
						
							 LOOP
									--LOOP de Multitramos
									BEGIN
										 v_ctramo := v_ctramo + 1;
									
										 IF v_totrea_evto = 0 OR
												NVL(pac_parametros.f_parempresa_n(p_pcempres, 'MAX_MTRAMOSXL_REA'), 6) < v_ctramo OR
												v_scontra IS NULL THEN
												EXIT;
										 END IF;
									
										 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL, 761,
																		 'Evaluando Tramo: ' || v_ctramo || ' Producto: ' || v_sproduc);
									
										 BEGIN
												SELECT ct.porcen
													INTO v_porc_tramo_ramo
													FROM ctto_tramo_producto ct
												 WHERE ct.ctramo = v_ctramo
													 AND ct.scontra = v_scontra
													 AND ct.nversio = v_nversio
													 AND ct.cramo = sini.cramo;
										 EXCEPTION
												WHEN no_data_found THEN
													 v_porc_tramo_ramo := 100;
												WHEN too_many_rows THEN
													 BEGIN
															SELECT ct.porcen
																INTO v_porc_tramo_ramo
																FROM ctto_tramo_producto ct
															 WHERE ct.ctramo = v_ctramo
																 AND ct.scontra = v_scontra
																 AND ct.nversio = v_nversio
																 AND ct.cramo = sini.cramo
																 AND ct.sproduc = v_sproduc;
													 EXCEPTION
															WHEN no_data_found THEN
																 v_porc_tramo_ramo := 100;
															WHEN OTHERS THEN
																 v_porc_tramo_ramo := 100;
													 END;
												WHEN OTHERS THEN
													 v_porc_tramo_ramo := 100;
										 END;
									
										 IF v_porc_tramo_ramo > 0 THEN
												--Obtenemos datos de Contrato y Tramo para Multitramos
												SELECT caplixl, ixlprio, pliminx, plimgas, itottra, icapaci, iprioxl, ipmd,
															 NVL(crepos, 0), preest
													INTO v_caplixl, v_iprioxl_tramo, v_pliminx, v_plimgas, v_itottra, v_icapaci,
															 v_iprioxl_ctto, v_ipmd, v_crepos, v_preest
													FROM tramos tt, contratos cc
												 WHERE cc.scontra = v_scontra
													 AND cc.nversio = v_nversio
													 AND cc.scontra = tt.scontra(+)
													 AND cc.nversio = tt.nversio(+)
													 AND tt.ctramo(+) = v_ctramo;
										 
												--Obtenemos número de reestablecimientos del tramo
												SELECT COUNT(norden) INTO v_nro_repos FROM reposiciones_det WHERE ccodigo = v_crepos;
										 
												IF v_nro_repos = 0 THEN
													 inicio := 0;
												ELSE
													 inicio := 1;
												END IF;
										 
												v_primareest := 0;
												p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL,
																				789, 'Reposiciones del tramo: ' || v_nro_repos);
										 
												--Si no existe capacidad del tramo tomamos la del contrato y su prioridad
												IF v_iprioxl_tramo IS NULL THEN
													 v_ixlprio   := NVL(v_iprioxl_ctto, 0);
													 v_ixlcapaci := v_icapaci - v_ixlprio;
												ELSE
													 v_ixlprio   := v_iprioxl_tramo;
													 v_ixlcapaci := v_itottra;
												END IF;
										 
												IF v_ixlprio_ant = 0 THEN
													 v_ixlprio_ant := v_ixlprio;
												ELSE
													 v_ixlprio := v_ixlprio_ant;
												END IF;
										 
												p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL,
																				801, 'Capacidad: ' || v_ixlcapaci || ' Prioridad: ' || v_ixlprio);
										 
												--Si tenemos el porcentaje de aumento por gastos en el contrato
												--Calculamos el nuevo límite aumentándolo según el procentaje definido en el contrato (PLIMGAS).
												IF NVL(v_plimgas, 0) <> 0 THEN
													 v_ixlprio := v_ixlprio * (100 + v_plimgas) / 100;
												END IF;
										 
												FOR i_rep IN inicio .. v_nro_repos LOOP
													 --LOOP de Reestablecimientos
													 BEGIN
															p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion,
																							NULL, 812, 'Importe Total Evento: ' || v_totrea_evto);
													 
															IF v_totrea_evto = 0 OR
																 NVL(pac_parametros.f_parempresa_n(p_pcempres, 'MAX_MREPOSXL_REA'), v_nro_repos) <
																 i_rep THEN
																 EXIT;
															END IF;
													 
															--KBR 14/01/2014
															IF (v_totalpagos_ret - v_ixlprio) > 0 THEN
																 IF (v_totalpagos_ret - v_ixlprio) < v_ixlcapaci THEN
																		v_ipagced_xl := v_totalpagos_ret - v_ixlprio; --importe pagado cedido xl (Total Pagos - Prioridad)
																		v_pcuorea    := ROUND((v_ipagced_xl / v_totalpagos_ret) * 100, 5);
																		--variable temporal
																		v_temp_pagos_ret := v_totalpagos_ret;
																		--No existen más pagos a ceder al XL
																		v_totalpagos_ret := 0;
																 ELSE
																		v_ipagced_xl := v_ixlcapaci;
																		v_pcuorea    := ROUND((v_ipagced_xl / v_totalpagos_ret) * 100, 5);
																		--variable temporal
																		v_temp_pagos_ret := v_totalpagos_ret;
																		--Recalculamos los pagos totales para el próximo reinstalamiento/tramo
																		v_totalpagos_ret := v_totalpagos_ret - v_ipagced_xl;
																 END IF;
															
																 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion,
																								 NULL, 833,
																								 'Pagos Ced XL: ' || v_ipagced_xl || ' % Pagos al XL: ' ||
																									v_pcuorea || ' Total Pagos Ret: ' || v_totalpagos_ret);
															
																 --Calculamos la prima de reestablecimiento
																 IF i_rep <> 0 THEN
																		--pr=(pmd*pagos cedidos xl de la capa/ capacidad de la capa)* %reestablecimiento;
																		v_primareest := (v_ipmd * v_ipagced_xl / v_ixlcapaci) * v_preest / 100;
																 END IF;
															
																 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion,
																								 NULL, 844, 'Prima Reest.: ' || v_primareest);
															ELSE
																 v_ipagced_xl := 0;
																 v_pcuorea    := 0;
																 --No existen más pagos a ceder al XL
																 v_totalpagos_ret := 0;
																 --variable temporal
																 v_temp_pagos_ret := v_totalpagos_ret;
																 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion,
																								 NULL, 851, 'No existen pagos a ceder al XL');
															END IF;
													 
															IF (v_totrea_evto - v_ixlprio) > 0 THEN
																 IF (v_totrea_evto - v_ixlprio) < v_ixlcapaci THEN
																		--Importe pagado cedido xl ((Total Pagos + Total Reservas)- Prioridad)
																		v_iced_xl := v_totrea_evto - v_ixlprio;
																		v_prea    := (v_iced_xl / v_totrea_evto) * 100;
																		--variable temporal
																		v_temp_totrea_evto := v_totrea_evto;
																		v_totrea_evto      := 0;
																 ELSE
																		v_iced_xl := v_ixlcapaci;
																		v_prea    := (v_iced_xl / v_totrea_evto) * 100;
																		--variable temporal
																		v_temp_totrea_evto := v_totrea_evto;
																		--Recalculamos el importe total para el próximo reinstalamiento/tramo
																		v_totrea_evto := v_totrea_evto - v_ixlcapaci;
																 END IF;
															
																 v_prea := ROUND(v_prea, 5);
																 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion,
																								 NULL, 868,
																								 'Total Ced XL: ' || v_iced_xl || ' % Total XL: ' || v_prea ||
																									' Total Evento: ' || v_totrea_evto);
																 --Reserva
																 v_iresced_xl := v_iced_xl - v_ipagced_xl;
															
																 --KBR 08052014
																 IF NVL(pac_parametros.f_parempresa_n(p_pcempres, 'MANEJO_RESERVAXL_REA'), 0) = 1 THEN
																		IF v_prea < v_pcuorea THEN
																			 v_presrea := 0;
																		ELSE
																			 v_presrea := 1;
																		END IF;
																 ELSE
																		v_presrea := v_prea - v_pcuorea;
																 END IF;
															
																 --Fin KBR 08052014
																 v_presrea := ROUND(v_presrea, 5);
																 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion,
																								 NULL, 874,
																								 'Reserva Ced XL: ' || v_iresced_xl || ' % Reserva XL: ' ||
																									v_presrea || ' Total Evento: ' || v_totrea_evto);
															ELSE
																 v_iced_xl     := 0;
																 v_prea        := 0;
																 v_totrea_evto := 0;
																 --variable temporal
																 v_temp_totrea_evto := v_totrea_evto;
															END IF;
													 
															--Buscamos el importe de reserva anterior para obtener el movimiento XL de reserva =
															--Valor Reserva XL actual menos valor Reserva XL anterior
															BEGIN
																 SELECT NVL(SUM(iresnet), 0)
																	 INTO v_reserva_anterior
																	 FROM liquidareaxl
																	WHERE nsinies IN (SELECT nsinies
																											FROM sin_siniestro ss, reariesgos rr
																										 WHERE rr.scumulo = v_cumul
																											 AND rr.sseguro = ss.sseguro)
																		AND fcierre = ADD_MONTHS(fcierre, -1);
															END;
													 
															p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion,
																							NULL, 895,
																							'Reserva anterior del evento Ced XL: ' || v_reserva_anterior);
															v_iresrea_mov := v_iresced_xl - v_reserva_anterior;
															p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion,
																							NULL, 900, 'Reserva Ced XL (Mov): ' || v_iresrea_mov);
													 
															--Buscamos el importe de pagos anterior para obtener el movimiento XL de pagos =
															--Valor Pagos XL actual menos valor Pagos XL anterior
															BEGIN
																 SELECT NVL(SUM(iliqnet), 0)
																	 INTO v_pagos_anterior
																	 FROM liquidareaxl
																	WHERE nsinies IN (SELECT nsinies
																											FROM sin_siniestro ss, reariesgos rr
																										 WHERE rr.scumulo = v_cumul
																											 AND rr.sseguro = ss.sseguro)
																		AND fcierre = ADD_MONTHS(fcierre, -1);
															END;
													 
															p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion,
																							NULL, 916, 'Pago anterior del evento Ced XL: ' || v_pagos_anterior);
															v_ipagrea_mov := v_ipagced_xl - v_pagos_anterior;
															p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion,
																							NULL, 920, 'Pago Ced XL (Mov): ' || v_ipagrea_mov);
													 
															IF v_iresced_xl <> 0 OR v_ipagced_xl <> 0 THEN
																 --KBR Añadir al PAC_REASEGURO_XL 24/10/2013
																 --Para cada siniestro
																 FOR sini IN 1 .. v_contador LOOP
																		p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete,
																										v_nom_funcion, NULL, 926,
																										'Evaluando siniestro: ' || v_movsin(sini).nsinies);
																 
																		FOR compa IN c_cuadroces_agr(v_movsin(sini).scontra, v_movsin(sini).nversio,
																																 v_ctramo) LOOP
																			 IF v_cmultimon = 1 THEN
																					nerr := pac_oper_monedas.f_datos_contraval(NULL, NULL,
																																										 v_movsin(sini).scontra,
																																										 v_movsin(sini).fsinies, 3,
																																										 v_itasa, v_fcambio);
																			 
																					IF nerr <> 0 THEN
																						 o_plsql    := SQLERRM;
																						 p_pscesrea := TO_NUMBER(TO_CHAR(v_movsin(sini).scontra) ||
																																		 TO_CHAR(v_movsin(sini).nversio) ||
																																		 TO_CHAR(v_ctramo) ||
																																		 TO_CHAR(compa.ccompani));
																					END IF;
																			 END IF;
																		
																			 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete,
																											 v_nom_funcion, NULL, 951,
																											 'Compañía: ' || compa.ccompani || ' % Part: ' ||
																												compa.pcesion);
																			 --v_prea corresponde con el % de prioridad del EVENTO
																			 v_icuorea   := v_ipagced_xl * compa.pcesion / 100;
																			 v_iresrea   := v_iresced_xl * compa.pcesion / 100;
																			 v_itotrea   := v_icuorea + v_iresrea;
																			 v_iresgas   := v_iresgas_tot * v_prea / 100 * compa.pcesion / 100;
																			 v_iresindem := v_iresindem_tot * v_prea / 100 * compa.pcesion / 100;
																			 v_iresinter := v_iresinter_tot * v_prea / 100 * compa.pcesion / 100;
																			 v_iresadmin := v_iresadmin_tot * v_prea / 100 * compa.pcesion / 100;
																		
																			 IF v_temp_pagos_ret = 0 THEN
																					v_iliqrea_sin    := 0;
																					v_primareest_sin := 0;
																			 ELSE
																					v_iliqrea_sin := ((v_movsin(sini)
																													 .pago_total_sin * v_ipagced_xl / v_temp_pagos_ret)) *
																													 compa.pcesion / 100;
																					--pr=(pmd*pagos cedidos xl de la capa/ capacidad de la capa)* %reestablecimiento;
																					v_primareest_sin := (v_ipmd * v_iliqrea_sin / v_ixlcapaci) * v_preest / 100;
																					p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete,
																													v_nom_funcion, NULL, 1135,
																													'Prima Reest. x Sin: ' || v_primareest_sin);
																			 END IF;
																		
																			 IF v_ipagced_xl = v_iced_xl THEN
																					v_iresrea_sin := 0;
																			 ELSE
																					IF v_temp_totrea_evto = 0 THEN
																						 v_iresrea_sin := 0;
																					ELSE
																						 --KBR 08052014
																						 IF NVL(pac_parametros.f_parempresa_n(p_pcempres,
																																									'MANEJO_RESERVAXL_REA'), 0) = 1 THEN
																								IF v_ipagced_xl = 0 THEN
																									 v_iresrea_sin := ((((v_movsin(sini).pago_total_sin + v_movsin(sini)
																																		.reserva_total_sin) * v_iced_xl /
																																		v_temp_totrea_evto)) * compa.pcesion / 100) -
																																		v_iliqrea_sin;
																								ELSE
																									 v_iresrea_sin := v_movsin(sini)
																																		.reserva_total_sin * compa.pcesion / 100;
																								END IF;
																						 ELSE
																								v_iresrea_sin := ((((v_movsin(sini).pago_total_sin + v_movsin(sini)
																																 .reserva_total_sin) * v_iced_xl /
																																 v_temp_totrea_evto)) * compa.pcesion / 100) -
																																 v_iliqrea_sin;
																						 END IF;
																						 --Fin KBR 08052014
																					END IF;
																			 END IF;
																		
																			 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete,
																											 v_nom_funcion, NULL, 978,
																											 'Pago Cia: ' || v_iliqrea_sin || ' Reserva Cia: ' ||
																												v_iresrea_sin);
																		
																			 -- Añadir detalle liquidación neta y reservas netas
																			 -- Buscar la PCESION en CTATECNICA_HIS cuando todavía no se ha actualizado la CTATECNICA
																			 BEGIN
																					SELECT NVL(cestado, 1)
																						INTO v_cestado_cia
																						FROM ctatecnica
																					 WHERE scontra = v_movsin(sini).scontra
																						 AND nversio = v_movsin(sini).nversio
																						 AND ctramo = v_ctramo
																						 AND ccompani = compa.ccompani
																						 AND sproduc = v_movsin(sini).sproduc;
																			 EXCEPTION
																					WHEN no_data_found THEN
																						 BEGIN
																								INSERT INTO ctatecnica
																									 (ccompani, nversio, scontra, ctramo, nctatec, cfrecul,
																										cestado, festado, fcierre, cempres, sproduc, ccorred)
																								VALUES
																									 (compa.ccompani, v_movsin(sini).nversio,
																										v_movsin(sini).scontra, v_ctramo, 1, 3, 1, NULL, NULL,
																										p_pcempres, v_movsin(sini).sproduc, compa.ccorred);
																						 EXCEPTION
																								WHEN OTHERS THEN
																									 --nerr := 104861;  DCT 13/02/2014
																									 v_cestado_cia := 1; --DCT 13/02/2014
																									 p_tab_error(f_sysdate, f_user, vobj, v_traza,
																															 'XL por Cumulo: Err INSERT INTO ctatecnica',
																															 ' SQLERRM = ' || SQLERRM || ' nerr = ' || nerr);
																						 END;
																					WHEN OTHERS THEN
																						 -- nerr := 104866; DCT 13/02/2014
																						 v_cestado_cia := 1; --DCT 13/02/2014
																						 o_plsql       := SQLERRM;
																						 p_tab_error(f_sysdate, f_user, vobj, v_traza,
																												 'XL por Cumulo: Err SELECT ctatecnica',
																												 ' v_scontra=' || v_movsin(sini).scontra ||
																													' v_nversio=' || v_movsin(sini).nversio || ' v_ctramo=' ||
																													v_ctramo || ' compa.ccompani=' || compa.ccompani ||
																													' SQLERRM = ' || SQLERRM || ' nerr = ' || nerr);
																			 END;
																		
																			 --Insert en LiquidareaXL
																			 BEGIN
																					p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete,
																													v_nom_funcion, NULL, 1038,
																													'Insertando en Liquidareaxl_aux');
																			 
																					INSERT INTO liquidareaxl_aux
																						 (nsinies, fsinies, itotexp, fcierre, sproces, scontra, nversio,
																							ctramo, ccompani, pcuorea, icuorea, ipagrea, iliqrea, ireserv,
																							pcuotot, itotrea, iresrea, iliqnet, iresnet, iresgas, iresindem,
																							iresinter, iresadmin, icuorea_moncon, iliqnet_moncon,
																							iliqrea_moncon, ipagrea_moncon, ireserv_moncon, iresgas_moncon,
																							iresindem_moncon, iresinter_moncon, iresadmin_moncon,
																							iresnet_moncon, iresrea_moncon, itotexp_moncon, itotrea_moncon)
																					VALUES
																						 (v_movsin(sini).nsinies, v_movsin(sini).fsinies, v_pago_idx,
																							p_pfperfin, p_pproces, v_movsin(sini).scontra,
																							v_movsin(sini).nversio, v_ctramo, compa.ccompani, v_pcuorea,
																							--% Pagos de reaseguro
																							v_icuorea,
																							--Importe de cuota del reaseguro por cia
																							v_ipagrea_mov,
																							--Liquidaciones anteriores por SINIESTRO-EVENTO
																							v_ipagrea_mov,
																							--Importe de pagos liquidados por siniestro-evento
																							v_iresrea_sin,
																							--Importe de reservas por siniestro-evento
																							v_pcuotot,
																							--% Total del Reaseguro
																							v_itotrea,
																							--Importe Total de reaseguro por cia
																							v_iresrea_mov,
																							--Importe total de reserva de reaseguro por cia
																							v_iliqrea_sin,
																							--Importe de pagos liquidados por siniestro-evento
																							v_iresrea_sin, v_iresgas, v_iresindem, v_iresinter, v_iresadmin,
																							f_round(NVL(v_icuorea, 0) * v_itasa, v_cmoncontab),
																							f_round(NVL(v_iliqrea_sin, 0) * v_itasa, v_cmoncontab),
																							f_round(NVL(v_ipagrea_mov, 0) * v_itasa, v_cmoncontab),
																							f_round(NVL(v_ipagrea_mov, 0) * v_itasa, v_cmoncontab),
																							f_round(NVL(v_iresrea_mov, 0) * v_itasa, v_cmoncontab),
																							f_round(NVL(v_iresgas, 0) * v_itasa, v_cmoncontab),
																							f_round(NVL(v_iresindem, 0) * v_itasa, v_cmoncontab),
																							f_round(NVL(v_iresinter, 0) * v_itasa, v_cmoncontab),
																							f_round(NVL(v_iresadmin, 0) * v_itasa, v_cmoncontab),
																							f_round(NVL(v_iresrea_sin, 0) * v_itasa, v_cmoncontab),
																							f_round(NVL(v_iresrea_mov, 0) * v_itasa, v_cmoncontab),
																							f_round(NVL(v_pago_idx, 0) * v_itasa, v_cmoncontab),
																							f_round(NVL(v_itotrea, 0) * v_itasa, v_cmoncontab));
																			 EXCEPTION
																					WHEN dup_val_on_index THEN
																						 UPDATE liquidareaxl_aux
																								SET icuorea = icuorea + v_icuorea,
																										iliqrea = iliqrea + v_ipagrea_mov,
																										ireserv = ireserv + v_iresrea_mov,
																										itotrea = itotrea + v_itotrea,
																										iresrea = iresrea + v_iresrea_mov,
																										iliqnet = iliqnet + v_iliqrea_sin,
																										iresnet = iresnet + v_iresrea_sin,
																										icuorea_moncon = icuorea_moncon +
																																			f_round(NVL(v_icuorea, 0) * v_itasa,
																																							v_cmoncontab),
																										iliqnet_moncon = iliqnet_moncon +
																																			f_round(NVL(v_iliqrea_sin, 0) * v_itasa,
																																							v_cmoncontab),
																										iliqrea_moncon = iliqrea_moncon +
																																			f_round(NVL(v_ipagrea_mov, 0) * v_itasa,
																																							v_cmoncontab),
																										ireserv_moncon = ireserv_moncon +
																																			f_round(NVL(v_iresrea_mov, 0) * v_itasa,
																																							v_cmoncontab),
																										iresnet_moncon = iresnet_moncon +
																																			f_round(NVL(v_iresrea_sin, 0) * v_itasa,
																																							v_cmoncontab),
																										iresrea_moncon = iresrea_moncon +
																																			f_round(NVL(v_iresrea_mov, 0) * v_itasa,
																																							v_cmoncontab),
																										itotrea_moncon = itotrea_moncon +
																																			f_round(NVL(v_itotrea, 0) * v_itasa,
																																							v_cmoncontab)
																							WHERE nsinies = v_movsin(sini).nsinies
																								AND fcierre = p_pfperfin
																								AND sproces = p_pproces
																								AND scontra = v_movsin(sini).scontra
																								AND nversio = v_movsin(sini).nversio
																								AND ctramo = v_ctramo
																								AND ccompani = compa.ccompani;
																					WHEN OTHERS THEN
																						 nerr := 1;
																						 p_tab_error(f_sysdate, f_user, vobj, v_traza,
																												 'Err INSERT INTO liquidareaxl_aux',
																												 'SQLERRM = ' || SQLERRM);
																			 END; --Insert en Liquidareaxl_aux
																		
																			 IF v_iliqrea_sin <> 0 THEN
																					--Insert Pagosreaxl_aux
																					BEGIN
																						 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete,
																														 v_nom_funcion, NULL, 1162,
																														 'Insertando en Pagosreaxl_aux');
																					
																						 INSERT INTO pagosreaxl_aux
																								(nsinies, scontra, nversio, ctramo, ccompani, fcierre, sproces,
																								 iliqrea, cestliq, iliqrea_moncon, fcambio)
																						 VALUES
																								(v_movsin(sini).nsinies, v_movsin(sini).scontra,
																								 v_movsin(sini).nversio, v_ctramo, compa.ccompani, p_pfperfin,
																								 p_pproces, v_iliqrea_sin, 0,
																								 f_round(NVL(v_iliqrea_sin, 0) * v_itasa, v_cmoncontab),
																								 DECODE(v_cmultimon, 0, NULL,
																												 NVL(v_fcambio, v_movsin(sini).fsinies)));
																					EXCEPTION
																						 WHEN dup_val_on_index THEN
																								UPDATE pagosreaxl_aux
																									 SET iliqrea = iliqrea + v_iliqrea_sin,
																											 iliqrea_moncon = iliqrea_moncon +
																																				 f_round(NVL(v_iliqrea_sin, 0) * v_itasa,
																																								 v_cmoncontab)
																								 WHERE nsinies = v_movsin(sini).nsinies
																									 AND scontra = v_movsin(sini).scontra
																									 AND nversio = v_movsin(sini).nversio
																									 AND ctramo = v_ctramo
																									 AND ccompani = compa.ccompani
																									 AND fcierre = p_pfperfin
																									 AND sproces = p_pproces;
																						 WHEN OTHERS THEN
																								p_tab_error(f_sysdate, f_user, vobj, v_traza,
																														'Err INSERT INTO pagosreaxl',
																														' SQLERRM = ' || SQLERRM);
																								nerr := 1;
																					END; --Insert Pagosreaxl_aux
																			 
																					-- Se actualizan pagos anteriores NO LIQUIDADOS
																					BEGIN
																						 UPDATE pagosreaxl
																								SET cestliq = 2
																							WHERE scontra = v_movsin(sini).scontra
																								AND nversio = v_movsin(sini).nversio
																								AND ctramo = v_ctramo
																								AND ccompani = compa.ccompani
																								AND fcierre < p_pfperfin
																								AND nsinies = v_movsin(sini).nsinies
																								AND cestliq = 0;
																					EXCEPTION
																						 WHEN no_data_found THEN
																								v_ipagrea := 0;
																						 WHEN OTHERS THEN
																								nerr := 1;
																								p_tab_error(f_sysdate, f_user, vobj, v_traza,
																														'Err UPDATE pagosreaxl',
																														' v_scontra =' || v_movsin(sini).scontra ||
																														 ' v_nversio =' || v_movsin(sini).nversio ||
																														 ' v_ctramo =' || v_ctramo || ' compa.ccompani=' ||
																														 compa.ccompani || ' sini.nsin=' || v_movsin(sini)
																														.nsinies || ' p_pfperfin =' || p_pfperfin ||
																														 ' SQLERRM = ' || SQLERRM);
																					END;
																			 END IF;
																		
																			 BEGIN
																					SELECT NVL(MAX(nnumlin), 0)
																						INTO w_nnumlin
																						FROM movctaaux
																					 WHERE scontra = v_movsin(sini).scontra
																						 AND nversio = v_movsin(sini).nversio
																						 AND ctramo = v_ctramo
																						 AND ccompani = compa.ccompani;
																			 
																					w_nnumlin := w_nnumlin + 1;
																			 EXCEPTION
																					WHEN no_data_found THEN
																						 w_nnumlin := 1;
																					WHEN OTHERS THEN
																						 nerr    := 104863;
																						 o_plsql := SQLERRM;
																						 p_tab_error(f_sysdate, f_user, vobj, v_traza,
																												 'Err SELECT MOVCTAAUX',
																												 ' v_scontra=' || v_movsin(sini).scontra ||
																													' v_nversio=' || v_movsin(sini).nversio || ' v_ctramo=' ||
																													v_ctramo || ' compa.ccompani=' || compa.ccompani ||
																													' SQLERRM = ' || SQLERRM);
																			 END;
																		
																			 IF v_iliqrea_sin <> 0 THEN
																					-- 5 -> Siniestros
																					p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete,
																													v_nom_funcion, NULL, 1268,
																													'Insertando en movctaaux-> Concepto 5 (Pago de Siniestros)');
																					v_movsin(sini).ctramo := v_ctramo;
																					nerr := f_insertxl_movctatecnica(w_ctadet, v_movsin(sini), w_nnumlin, 5,
																																					 compa.ccompani, v_iliqrea_sin,
																																					 p_pproces, v_cestado_cia, p_pcempres,
																																					 p_pfperfin, compa.ccorred); -- 25/05/2015  CJMR  0033158: Actualización campo CCORRED en los cierres de Reaseguro
																			 END IF;
																		
																			 IF v_iliqrea_sin <> 0 THEN
																					-- 15 -> Liquidacion XL
																					p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete,
																													v_nom_funcion, NULL, 1283,
																													'Insertando en movctaaux-> Concepto 15 (Liquidacion XL)');
																					v_movsin(sini).ctramo := v_ctramo;
																					nerr := f_insertxl_movctatecnica(w_ctadet, v_movsin(sini), w_nnumlin,
																																					 15, compa.ccompani, v_iliqrea_sin,
																																					 p_pproces, v_cestado_cia, p_pcempres,
																																					 p_pfperfin, compa.ccorred); -- 25/05/2015  CJMR  0033158: Actualización campo CCORRED en los cierres de Reaseguro
																			 END IF;
																		
																			 IF v_iresrea_sin <> 0 THEN
																					-- 25 -> Reserva de Siniestros
																					p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete,
																													v_nom_funcion, NULL, 1298,
																													'Insertando en movctaaux-> Concepto 25 (Reserva de Siniestros)');
																					v_movsin(sini).ctramo := v_ctramo;
																					nerr := f_insertxl_movctatecnica(w_ctadet, v_movsin(sini), w_nnumlin,
																																					 25, compa.ccompani, v_iresrea_sin,
																																					 p_pproces, v_cestado_cia, p_pcempres,
																																					 p_pfperfin, compa.ccorred); -- 25/05/2015  CJMR  0033158: Actualización campo CCORRED en los cierres de Reaseguro
																			 END IF;
																		
																			 IF v_primareest_sin <> 0 THEN
																					-- 23 -> Reinstalamento XL
																					p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete,
																													v_nom_funcion, NULL, 1412,
																													'Insertando en movctaaux-> Concepto 23 (Prima de Reinstalamiento XL)');
																					v_movsin(sini).ctramo := v_ctramo;
																					nerr := f_insertxl_movctatecnica(w_ctadet, v_movsin(sini), w_nnumlin,
																																					 23, compa.ccompani, v_primareest_sin,
																																					 p_pproces, v_cestado_cia, p_pcempres,
																																					 p_pfperfin, compa.ccorred); -- 25/05/2015  CJMR  0033158: Actualización campo CCORRED en los cierres de Reaseguro
																			 END IF;
																		END LOOP; --Cias
																 END LOOP; --Siniestros
															END IF;
													 
															--KBR Multitramos y Reinstalaciones
															IF NVL(pac_parametros.f_parempresa_n(p_pcempres, 'PERMITE_MREPOXL_REA'), 0) = 0 THEN
																 EXIT;
															END IF;
													 END;
												END LOOP; --Reestablecimientos
										 END IF;
									
										 --KBR Multitramos y Reinstalaciones
										 IF NVL(pac_parametros.f_parempresa_n(p_pcempres, 'PERMITE_MTRAMOXL_REA'), 0) = 0 THEN
												EXIT;
										 END IF;
									END;
							 END LOOP; --Multitramos
						
							 --Fin
							 v_totalpagos_ret := 0;
							 v_sin            := 0;
							 v_contador       := 0;
							 v_res_dist       := 0;
							 v_pag_dist       := 0;
							 v_pago_idx       := 0;
							 v_pago_no_idx    := 0;
							 v_reserva        := 0;
							 v_totrea_evto    := 0; --KBR 10/12/2013
							 v_cumul          := sini.cumulo; --KBR 10/12/2013
							 v_prea           := 0; --KBR 10/12/2013
							 v_iced_xl        := 0; --KBR 10/12/2013
						END IF;
				 END IF;
			
				 v_cramo := sini.cramo;
			
				 --Cursor que retorna siniestros/seguros totalizados por cumulo/ramo en un período determinado
				 FOR sincum_det IN c_sincum_det(sini.cumulo, sini.cramo, v_fechacorte) LOOP
						p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL, 1336,
														'Siniestro: ' || sincum_det.nsin || ' Cumulo: ' || sini.cumulo || ' Ramo: ' ||
														 sini.cramo);
				 
						IF sincum_det.totireserva <> 0 OR sincum_det.totisinpag <> 0 THEN
							 --KBR Agregar al PAC_REASEGURO_XL 24/10/2013
							 IF v_sin = 0 THEN
									v_sin      := sincum_det.nsin;
									v_fsin     := sincum_det.fsin;
									v_sproduc  := sincum_det.sproduc;
									v_ccompapr := sincum_det.ccompapr;
									v_contador := v_contador + 1;
									----<dbms_OUTPUT.put_line('v_sin: ' || v_sin);
							 ELSE
									IF v_sin <> sincum_det.nsin THEN
										 ----<dbms_OUTPUT.put_line('Añade al objeto: v_sin: ' || v_sin || ' contador: '
										 --                     || v_contador);
										 v_movsin.extend;
										 v_movsin(v_contador).nsinies := v_sin;
										 v_movsin(v_contador).fsinies := v_fsin;
										 v_movsin(v_contador).scontra := v_scontra;
										 v_movsin(v_contador).nversio := v_nversio;
										 v_movsin(v_contador).scumulo := v_cumul;
										 v_movsin(v_contador).ctramo := v_ctramo;
										 v_movsin(v_contador).ccompapr := v_ccompapr;
										 v_movsin(v_contador).sproduc := v_sproduc;
										 v_movsin(v_contador).pago_total := v_pago_idx;
										 v_movsin(v_contador).reserva_total := v_reserva;
									
										 IF v_contador = 1 THEN
												v_movsin(v_contador).pago_total_sin := v_pago_idx;
												v_movsin(v_contador).reserva_total_sin := v_reserva;
										 ELSE
												v_movsin(v_contador).pago_total_sin := v_pago_idx - v_movsin(v_contador - 1).pago_total;
												v_movsin(v_contador).reserva_total_sin := v_reserva - v_movsin(v_contador - 1)
																																 .reserva_total;
										 END IF;
									
										 --KBR 10/12/2013
										 v_totrea_evto := v_totrea_evto + v_movsin(v_contador).pago_total_sin + v_movsin(v_contador)
																		 .reserva_total_sin;
										 v_sin         := sincum_det.nsin;
										 v_fsin        := sincum_det.fsin;
										 v_sproduc     := sincum_det.sproduc;
										 v_ccompapr    := sincum_det.ccompapr;
										 v_contador    := v_contador + 1;
									END IF;
							 END IF;
						
							 v_pago_indexado    := 0;
							 v_pago_no_indexado := 0;
							 v_ireserv          := 0;
						
							 --<--<dbms_OUTPUT.put_line('>>>>>>>>>>>> 1. v_pago_indexado:' || v_pago_indexado);
							 BEGIN
									SELECT cmodali, ctipseg, ccolect, cactivi
										INTO v_cmodali, v_ctipseg, v_ccolect, v_cactivi
										FROM seguros
									 WHERE sseguro = sincum_det.sseg;
							 EXCEPTION
									WHEN no_data_found THEN
										 v_cmodali := NULL;
										 v_ctipseg := NULL;
										 v_ccolect := NULL;
										 v_cactivi := NULL;
									WHEN OTHERS THEN
										 nerr := 1;
										 p_tab_error(f_sysdate, f_user, vobj, v_traza, 'Err select seguros',
																 'SSEGURO =' || sincum_det.sseg || ' SQLERRM = ' || SQLERRM);
							 END;
						
							 nerr := f_buscacontrato(sincum_det.sseg, sincum_det.fsin, p_pcempres, NULL, sini.cramo, v_cmodali,
																			 v_ctipseg, v_ccolect, v_cactivi, 11, v_scontra, v_nversio, v_ipleno,
																			 v_icapaci, v_cdetces);
							 -----------------------------------------------------------------------------------
							 --  A partir del contrato conocemos: Prioridad (IPRIOXL de CONTRATOS) --
							 --  A partir del contrato conocemos: Prioridad, Capacidad, Lim de Index, Lim de Gastos,  (IPRIOXL de TRAMOS) --
							 -----------------------------------------------------------------------------------
							 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL, 1413,
															 'Contrato: ' || v_scontra || ' Version: ' || v_nversio);
						
							 IF nerr = 0 THEN
									--Verificamos si tiene Coaseguro
									DECLARE
										 v_ctipcoa seguros.ctipcoa%TYPE;
										 v_ploccoa coacuadro.ploccoa%TYPE;
									BEGIN
										 v_c_gar := sincum_det.cgar;
									
										 SELECT NVL(ctipcoa, 0) INTO v_ctipcoa FROM seguros WHERE sseguro = sincum_det.sseg;
									
										 -- si es aceptado, no modificamos el importe.
										 -- si es cedido y tiene porcentaje, modificamos el importe.
										 IF v_ctipcoa IN (1, 2) THEN
												SELECT MAX(ploccoa)
													INTO v_ploccoa
													FROM coacuadro
												 WHERE ncuacoa = sincum_det.ncua
													 AND sseguro = sincum_det.sseg;
										 
												p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL,
																				1439, '% Coaseguro Cedido: ' || v_ploccoa);
										 
												IF v_ploccoa IS NOT NULL THEN
													 sincum_det.totisinpag  := sincum_det.totisinpag * v_ploccoa / 100;
													 sincum_det.totireserva := sincum_det.totireserva * v_ploccoa / 100;
												END IF;
										 END IF;
									END;
							 
									--Reajusta todos los pagos.
									BEGIN
										 --2: Pago 8: Anulación del Recobro
										 IF sincum_det.ctippag IN (2, 8) THEN
												v_pago_indexado    := v_pago_indexado + sincum_det.totisinpag;
												v_pago_no_indexado := v_pago_no_indexado + sincum_det.totisinpag;
												--<dbms_OUTPUT.put_line('>>>>>>>>>>>> 2. v_pago_indexado:'
												--<|| v_pago_indexado);
												--3: Anulación del Pago 7: Recobro
										 ELSE
												v_pago_indexado    := v_pago_indexado - sincum_det.totisinpag;
												v_pago_no_indexado := v_pago_no_indexado - sincum_det.totisinpag;
												--<dbms_OUTPUT.put_line('>>>>>>>>>>>> 3. v_pago_indexado:'
												--<|| v_pago_indexado);
										 END IF;
									
										 v_pago_indexado    := f_round(v_pago_indexado);
										 v_pago_no_indexado := f_round(v_pago_no_indexado);
									END;
							 
									--<dbms_OUTPUT.put_line('>>>>>>>>>>>> 4. v_pago_indexado:' || v_pago_indexado);
							 
									-- Reservas totales y reserves de gastos desglosados
									BEGIN
										 v_ireserv := v_ireserv + sincum_det.totireserva;
									
										 ----<dbms_OUTPUT.put_line('v_ireserv: ' || v_ireserv);
										 IF sincum_det.ctipres = 1 THEN
												-- Indemnizatoria
												v_iresindem_tot := v_iresindem_tot + sincum_det.totireserva;
										 ELSIF sincum_det.ctipres = 2 THEN
												-- Intereses
												v_iresinter_tot := v_iresinter_tot + sincum_det.totireserva;
										 ELSIF sincum_det.ctipres = 3 THEN
												-- Gastos
												v_iresgas_tot := v_iresgas_tot + sincum_det.totireserva;
										 ELSIF sincum_det.ctipres = 4 THEN
												-- Administración
												v_iresadmin_tot := v_iresadmin_tot + sincum_det.totireserva;
										 END IF;
									END;
							 
									p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL, 1487,
																	'reserva Siniestro: ' || v_ireserv || ' Pagos Siniestro: ' || v_pago_indexado);
									--Se valida la parte protegida del siniestro
									v_plocal := 0;
							 
									IF NVL(pac_parametros.f_parempresa_n(p_pcempres, 'XL_PROTEC_PROPI'), 0) = 1 THEN
										 v_hiha_cessio := 0;
									
										 FOR f1 IN (SELECT DISTINCT scontra, nversio, ctramo, SUM(pcesion) pcesion --CONF-910
																	FROM cesionesrea
																 WHERE nsinies = sincum_det.nsin
																	 AND ctramo IN (0, 1)
																 GROUP BY scontra, nversio, ctramo) LOOP
												v_hiha_cessio := 1;
										 
												IF f1.ctramo = 0 THEN
													 v_plocal := f1.pcesion;
												ELSIF NVL(pac_parametros.f_parempresa_n(p_pcempres, 'INFORMA_FECHA_FIN'), 0) = 0 THEN
													 --CONF-910
													 SELECT plocal
														 INTO v_plocal
														 FROM tramos
														WHERE scontra = f1.scontra
															AND nversio = f1.nversio
															AND ctramo = f1.ctramo;
												
													 v_plocal := v_plocal / 100 * f1.pcesion;
												END IF;
										 END LOOP;
									
										 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL, 1514,
																		 '% Retencion: ' || v_plocal);
									
										 -- Si solo hay reserva: La garantia no es obligatoria, puede estar sin informar
										 IF v_hiha_cessio = 0 THEN
												FOR f2 IN (SELECT DISTINCT scontra, nversio, ctramo, SUM(pcesion) pcesion --CONF-910
																		 FROM cesionesrea
																		WHERE sseguro = sincum_det.sseg
																			AND cgenera IN (1, 3, 4, 5, 9, 40)
																			AND nriesgo = sincum_det.nrie
																			AND fefecto <= sincum_det.fsin
																			AND fvencim >= sincum_det.fsin -- Bug 31730 EDA 11/06/2014
																			AND (fregula IS NULL OR fregula >= sincum_det.fsin) -- Bug 31730 EDA 11/06/2014
																			AND (fanulac IS NULL OR fanulac >= sincum_det.fsin) --Bug 22678 KBR 22/05/2013
																			AND ctramo IN (0, 1)
																				 --KBR 07/10/2013
																			AND cgarant = sincum_det.cgar
																		GROUP BY scontra, nversio, ctramo) LOOP
													 v_hiha_cessio := 1;
												
													 IF f2.ctramo = 0 THEN
															v_plocal := f2.pcesion;
													 ELSIF NVL(pac_parametros.f_parempresa_n(p_pcempres, 'INFORMA_FECHA_FIN'), 0) = 0 THEN
															--CONF-910
															SELECT plocal
																INTO v_plocal
																FROM tramos
															 WHERE scontra = f2.scontra
																 AND nversio = f2.nversio
																 AND ctramo = f2.ctramo;
													 
															v_plocal := v_plocal / 100 * f2.pcesion;
													 END IF;
												END LOOP;
										 END IF;
									
										 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL, 1552,
																		 '% Retencion: ' || v_plocal);
									
										 --KBR 10/12/2013
										 IF v_hiha_cessio = 0 THEN
												-- Paso 2. Garant£¿as agrupadas: La garantia no es obligatoria a la reserva, pot estar sense informar.
												FOR f2 IN (SELECT DISTINCT scontra, nversio, ctramo, SUM(pcesion) pcesion --CONF-910
																		 FROM cesionesrea
																		WHERE sseguro = sincum_det.sseg
																			AND cgenera IN (1, 3, 4, 5, 9, 40)
																			AND nriesgo = sincum_det.nrie
																			AND fefecto <= sincum_det.fsin
																			AND fvencim >= sincum_det.fsin -- Bug 31730 EDA 11/06/2014
																			AND (fregula IS NULL OR fregula >= sincum_det.fsin) -- Bug 31730 EDA 11/06/2014
																			AND (fanulac IS NULL OR fanulac >= sincum_det.fsin)
																			AND ctramo IN (0, 1)
																				 --KBR 13/11/2013
																			AND cgarant IS NULL
																		GROUP BY scontra, nversio, ctramo) LOOP
													 v_hiha_cessio := 1; --KBR 13/11/2013
												
													 IF f2.ctramo = 0 THEN
															v_plocal := f2.pcesion;
													 ELSIF NVL(pac_parametros.f_parempresa_n(p_pcempres, 'INFORMA_FECHA_FIN'), 0) = 0 THEN
															--CONF-910
															BEGIN
																 SELECT plocal
																	 INTO v_plocal
																	 FROM tramos
																	WHERE scontra = f2.scontra
																		AND nversio = f2.nversio
																		AND ctramo = f2.ctramo;
															EXCEPTION
																 WHEN no_data_found THEN
																		p_tab_error(f_sysdate, f_user, vobj, v_traza,
																								'Err select TRAMOS: NO_DATA_FOUND',
																								' sin: ' || sincum_det.nsin || ' v_scontra =' || f2.scontra ||
																								 ' v_nversio =' || f2.nversio || ' ctramo = ' || f2.ctramo ||
																								 ' SQLERRM = ' || SQLERRM);
																		v_plocal := 0;
																 WHEN OTHERS THEN
																		p_tab_error(f_sysdate, f_user, vobj, v_traza, 'Err select TRAMOS',
																								' sin: ' || sincum_det.nsin || ' v_scontra =' || f2.scontra ||
																								 ' v_nversio =' || f2.nversio || ' ctramo = ' || f2.ctramo ||
																								 ' SQLERRM = ' || SQLERRM);
															END;
													 
															v_plocal := v_plocal / 100 * f2.pcesion;
													 END IF;
												END LOOP;
										 END IF;
									
										 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL, 1607,
																		 '% Retencion: ' || v_plocal);
									
										 IF NVL(pac_parametros.f_parempresa_n(p_pcempres, 'APLICA_RESMAT_REA_XL'), 0) = 1 THEN
												v_reserva_mat := NVL(TRUNC(pac_isqlfor.f_provisio_actual(sincum_det.sseg, 'IPROVRES',
																																								 TRUNC(f_sysdate), sincum_det.cgar),
																									 2), 0);
												p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL,
																				1627, 'Reserva Mat.: ' || v_reserva_mat);
										 
												SELECT cdivisa INTO v_moneda_prod FROM productos WHERE sproduc = v_sproduc;
										 
												IF v_cmoncontab <> v_moneda_prod THEN
													 nerr := pac_oper_monedas.f_datos_contraval(sincum_det.sseg, NULL, v_scontra,
																																			sincum_det.fsin, 3, v_itasa_prod,
																																			v_fcambio_prod);
												
													 IF nerr <> 0 THEN
															o_plsql := SQLERRM;
															p_tab_error(f_sysdate, f_user, vobj, v_traza, 'Err Tasa Prod',
																					' v_scontra =' || v_scontra || ' v_nversio =' || v_nversio ||
																					 ' ctramo = ' || v_ctramo || ' SQLERRM = ' || o_plsql);
													 END IF;
												
													 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL,
																					 1647, 'Tasa Cambio: ' || NVL(v_itasa_prod, 1));
													 v_reserva_mat := v_reserva_mat * NVL(v_itasa_prod, 1);
												END IF;
										 ELSE
												v_reserva_mat := 0;
										 END IF;
									
										 IF NVL(v_ireserv, 0) <> 0 AND NVL(sincum_det.totireserva, 0) <> 0 THEN
												v_ireserv := v_ireserv - v_reserva_mat;
										 END IF;
									
										 IF NVL(v_pago_indexado, 0) <> 0 AND NVL(sincum_det.totisinpag, 0) <> 0 THEN
												-- Si la Reserva Matematica es més gran que el pago (PAGO PARCIAL) NO LA RESTA
												IF v_pago_indexado - v_reserva_mat > 0 THEN
													 v_pago_indexado := v_pago_indexado - v_reserva_mat;
												END IF;
										 
												v_pago_no_indexado := v_pago_indexado;
										 END IF;
									
										 v_pago_idx      := v_pago_idx + (v_pago_indexado * v_plocal / 100);
										 v_pago_idx      := NVL(v_pago_idx, 0);
										 v_reserva       := v_reserva + (v_ireserv * v_plocal / 100);
										 v_reserva       := NVL(v_reserva, 0);
										 v_res_dist      := v_reserva;
										 v_iresgas_tot   := v_iresgas_tot * v_plocal / 100;
										 v_iresindem_tot := v_iresindem_tot * v_plocal / 100;
										 v_iresinter_tot := v_iresinter_tot * v_plocal / 100;
										 v_iresadmin_tot := v_iresadmin_tot * v_plocal / 100;
										 v_pago_no_idx   := v_pago_no_idx + (v_pago_no_indexado * v_plocal / 100);
										 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL, 1680,
																		 'Reserva Dist.: ' || v_res_dist || ' Pagos Dist.: ' || v_pago_idx);
									END IF;
							 END IF;
						END IF;
				 END LOOP; --Siniestros/Seguros x Cumulo
			
				 IF v_sin <> 0 THEN
						----<dbms_OUTPUT.put_line('Añade al objeto: v_sin: ' || v_sin || ' contador: '
						--                     || v_contador);
						----<dbms_OUTPUT.put_line('Añade al objeto: v_reserva: ' || v_reserva);
						----<dbms_OUTPUT.put_line('v_sin: ' || v_sin);
						----<dbms_OUTPUT.put_line('v_pago_idx: ' || v_pago_idx);
						v_movsin.extend;
						v_movsin(v_contador).nsinies := v_sin;
						v_movsin(v_contador).fsinies := v_fsin;
						v_movsin(v_contador).scontra := v_scontra;
						v_movsin(v_contador).nversio := v_nversio;
						v_movsin(v_contador).scumulo := v_cumul;
						v_movsin(v_contador).ctramo := v_ctramo;
						v_movsin(v_contador).ccompapr := v_ccompapr;
						v_movsin(v_contador).sproduc := v_sproduc;
						v_movsin(v_contador).pago_total := v_pago_idx;
						v_movsin(v_contador).reserva_total := v_reserva;
				 
						IF v_contador = 1 THEN
							 v_movsin(v_contador).pago_total_sin := v_pago_idx;
							 v_movsin(v_contador).reserva_total_sin := v_reserva;
						ELSE
							 ----<dbms_OUTPUT.put_line('v_movsin(v_contador).pago_total: '
							 --                     || v_movsin(v_contador).pago_total);
							 v_movsin(v_contador).pago_total_sin := v_pago_idx - v_movsin(v_contador - 1).pago_total;
							 v_movsin(v_contador).reserva_total_sin := v_reserva - v_movsin(v_contador - 1).reserva_total;
						END IF;
				 
						--KBR 10/12/2013
						v_totrea_evto := v_totrea_evto + v_movsin(v_contador).pago_total_sin + v_movsin(v_contador)
														.reserva_total_sin;
						----<dbms_OUTPUT.put_line('Sin: ' || v_sin || ', '
						--                     || v_movsin(v_contador).pago_total_sin || ', '
						--                     || v_movsin(v_contador).reserva_total_sin);
						v_sin := 0;
				 END IF;
			END LOOP; --Cumulos
	 
			--Distribución por compañías
			IF v_totalpagos_ret = 0 AND v_cumul <> 0 THEN
				 v_totalpagos_ret := v_pago_idx;
				 v_ctramo         := 5; --Facultativo y empezamos a validar a partir del primer tramo XL
				 v_reserva_ret    := v_reserva;
				 v_ixlprio_ant    := 0;
			
				 LOOP
						--LOOP de Multitramos
						BEGIN
							 v_ctramo := v_ctramo + 1;
						
							 IF v_totrea_evto = 0 OR
									NVL(pac_parametros.f_parempresa_n(p_pcempres, 'MAX_MTRAMOSXL_REA'), 6) < v_ctramo OR
									v_scontra IS NULL THEN
									EXIT;
							 END IF;
						
							 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL, 1741,
															 'Evaluando Tramo.: ' || v_ctramo || ' Producto: ' || v_sproduc);
						
							 BEGIN
									SELECT ct.porcen
										INTO v_porc_tramo_ramo
										FROM ctto_tramo_producto ct
									 WHERE ct.ctramo = v_ctramo
										 AND ct.scontra = v_scontra
										 AND ct.nversio = v_nversio
										 AND ct.cramo = v_cramo;
							 EXCEPTION
									WHEN no_data_found THEN
										 v_porc_tramo_ramo := 100;
									WHEN too_many_rows THEN
										 BEGIN
												SELECT ct.porcen
													INTO v_porc_tramo_ramo
													FROM ctto_tramo_producto ct
												 WHERE ct.ctramo = v_ctramo
													 AND ct.scontra = v_scontra
													 AND ct.nversio = v_nversio
													 AND ct.cramo = v_cramo
													 AND ct.sproduc = v_sproduc;
										 EXCEPTION
												WHEN no_data_found THEN
													 v_porc_tramo_ramo := 100;
												WHEN OTHERS THEN
													 v_porc_tramo_ramo := 100;
										 END;
									WHEN OTHERS THEN
										 v_porc_tramo_ramo := 100;
							 END;
						
							 IF v_porc_tramo_ramo > 0 THEN
									--Obtenemos datos de Contrato y Tramo para Multitramos
									SELECT caplixl, ixlprio, pliminx, plimgas, itottra, icapaci, iprioxl, ipmd, NVL(crepos, 0),
												 preest
										INTO v_caplixl, v_iprioxl_tramo, v_pliminx, v_plimgas, v_itottra, v_icapaci, v_iprioxl_ctto,
												 v_ipmd, v_crepos, v_preest
										FROM tramos tt, contratos cc
									 WHERE cc.scontra = v_scontra
										 AND cc.nversio = v_nversio
										 AND cc.scontra = tt.scontra(+)
										 AND cc.nversio = tt.nversio(+)
										 AND tt.ctramo(+) = v_ctramo;
							 
									--Obtenemos número de reestablecimientos del tramo
									SELECT COUNT(norden) INTO v_nro_repos FROM reposiciones_det WHERE ccodigo = v_crepos;
							 
									IF v_nro_repos = 0 THEN
										 inicio := 0;
									ELSE
										 inicio := 1;
									END IF;
							 
									v_primareest := 0;
									p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL, 1769,
																	'Reposiciones Tramo: ' || v_nro_repos);
							 
									--Si no existe capacidad del tramo tomamos la del contrato y su prioridad
									IF v_iprioxl_tramo IS NULL THEN
										 v_ixlprio   := NVL(v_iprioxl_ctto, 0);
										 v_ixlcapaci := v_icapaci - v_ixlprio;
									ELSE
										 v_ixlprio   := v_iprioxl_tramo;
										 v_ixlcapaci := v_itottra;
									END IF;
							 
									IF v_ixlprio_ant = 0 THEN
										 v_ixlprio_ant := v_ixlprio;
									ELSE
										 v_ixlprio := v_ixlprio_ant;
									END IF;
							 
									p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL, 1781,
																	'Capacidad (Cap-Prio): ' || v_ixlcapaci || ' Prioridad: ' || v_ixlprio);
							 
									--Si tenemos el porcentaje de aumento por gastos en el contrato
									--Calculamos el nuevo límite aumentándolo según el procentaje definido en el contrato (PLIMGAS).
									IF NVL(v_plimgas, 0) <> 0 THEN
										 v_ixlprio := v_ixlprio * (100 + v_plimgas) / 100;
									END IF;
							 
									FOR i_rep IN inicio .. v_nro_repos LOOP
										 --LOOP de Reestablecimientos
										 BEGIN
												IF v_totrea_evto = 0 OR NVL(pac_parametros.f_parempresa_n(p_pcempres, 'MAX_MREPOSXL_REA'),
																										v_nro_repos) < i_rep THEN
													 EXIT;
												END IF;
										 
												p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL,
																				1796, 'Evaluando Reposicion: ' || i_rep);
										 
												--KBR 14/01/2014
												IF (v_totalpagos_ret - v_ixlprio) > 0 THEN
													 IF (v_totalpagos_ret - v_ixlprio) < v_ixlcapaci THEN
															v_ipagced_xl := v_totalpagos_ret - v_ixlprio; --importe pagado cedido xl (Total Pagos - Prioridad)
															v_pcuorea    := ROUND((v_ipagced_xl / v_totalpagos_ret) * 100, 5);
															--variable temporal
															v_temp_pagos_ret := v_totalpagos_ret;
															--No existen más pagos a ceder al XL
															v_totalpagos_ret := 0;
													 ELSE
															v_ipagced_xl := v_ixlcapaci;
															v_pcuorea    := ROUND((v_ipagced_xl / v_totalpagos_ret) * 100, 5);
															--variable temporal
															v_temp_pagos_ret := v_totalpagos_ret;
															--Recalculamos los pagos totales para el próximo reinstalamiento/tramo
															v_totalpagos_ret := v_totalpagos_ret - v_ixlcapaci;
													 END IF;
												
													 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL,
																					 1813,
																					 'Pagos Ced XL: ' || v_ipagced_xl || ' % Pagos: ' || v_pcuorea ||
																						' Total Pagos Ret: ' || v_totalpagos_ret);
												
													 --Calculamos la prima de reestablecimiento
													 IF i_rep <> 0 THEN
															--pr=(pmd*pagos cedidos xl de la capa/ capacidad de la capa)* %reestablecimiento;
															v_primareest := (v_ipmd * v_ipagced_xl / v_ixlcapaci) * v_preest / 100;
													 END IF;
												
													 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL,
																					 1823, 'Prima Reest.: ' || v_primareest);
												ELSE
													 v_ipagced_xl := 0;
													 v_pcuorea    := 0;
													 --No existen más pagos a ceder al XL
													 v_totalpagos_ret := 0;
													 --variable temporal
													 v_temp_pagos_ret := v_totalpagos_ret;
													 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL,
																					 1830, 'No existen Pagos al XL');
												END IF;
										 
												IF (v_totrea_evto - v_ixlprio) > 0 THEN
													 IF (v_totrea_evto - v_ixlprio) < v_ixlcapaci THEN
															--Importe total cedido xl ((Total Pagos + Total Reservas)- Prioridad)
															v_iced_xl := v_totrea_evto - v_ixlprio;
															v_prea    := (v_iced_xl / v_totrea_evto) * 100;
															--variable temporal
															v_temp_totrea_evto := v_totrea_evto;
															v_totrea_evto      := 0;
													 ELSE
															v_iced_xl := v_ixlcapaci;
															v_prea    := (v_iced_xl / v_totrea_evto) * 100;
															--variable temporal
															v_temp_totrea_evto := v_totrea_evto;
															--Recalculamos el importe total para el próximo reinstalamiento/tramo
															v_totrea_evto := v_totrea_evto - v_ixlcapaci;
													 END IF;
												
													 v_prea := ROUND(v_prea, 5);
													 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL,
																					 1847,
																					 'Total Ced XL: ' || v_iced_xl || ' % Total XL: ' || v_prea ||
																						' Total Evento: ' || v_totrea_evto);
													 --Reserva
													 v_iresced_xl := v_iced_xl - v_ipagced_xl;
												
													 --KBR 08052014
													 IF NVL(pac_parametros.f_parempresa_n(p_pcempres, 'MANEJO_RESERVAXL_REA'), 0) = 1 THEN
															IF v_prea < v_pcuorea THEN
																 v_presrea := 0;
															ELSE
																 v_presrea := 1;
															END IF;
													 ELSE
															v_presrea := v_prea - v_pcuorea;
													 END IF;
												
													 --Fin KBR 08052014
													 v_presrea := ROUND(v_presrea, 5);
													 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL,
																					 1854,
																					 'Reserva Ced XL: ' || v_iresced_xl || ' % Reserva XL: ' || v_presrea);
												ELSE
													 v_iced_xl     := 0;
													 v_prea        := 0;
													 v_totrea_evto := 0;
													 --variable temporal
													 v_temp_totrea_evto := v_totrea_evto;
												END IF;
										 
												--Buscamos el importe de reserva anterior para obtener el movimiento XL de reserva =
												--Valor Reserva XL actual menos valor Reserva XL anterior
												BEGIN
													 SELECT NVL(SUM(iresnet), 0)
														 INTO v_reserva_anterior
														 FROM liquidareaxl
														WHERE nsinies IN (SELECT nsinies
																								FROM sin_siniestro ss, reariesgos rr
																							 WHERE rr.scumulo = v_cumul
																								 AND rr.sseguro = ss.sseguro)
															AND fcierre = ADD_MONTHS(fcierre, -1);
												END;
										 
												p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL,
																				1875, 'Reserva Anterior evento XL: ' || v_reserva_anterior);
												v_iresrea_mov := v_iresced_xl - v_reserva_anterior;
										 
												--Buscamos el importe de pagos anterior para obtener el movimiento XL de pagos =
												--Valor Pagos XL actual menos valor Pagos XL anterior
												BEGIN
													 SELECT NVL(SUM(iliqnet), 0)
														 INTO v_pagos_anterior
														 FROM liquidareaxl
														WHERE nsinies IN (SELECT nsinies
																								FROM sin_siniestro ss, reariesgos rr
																							 WHERE rr.scumulo = v_cumul
																								 AND rr.sseguro = ss.sseguro)
															AND fcierre = ADD_MONTHS(fcierre, -1);
												END;
										 
												p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL,
																				1893, 'Pagos Anterior evento XL: ' || v_pagos_anterior);
												v_ipagrea_mov := v_ipagced_xl - v_pagos_anterior;
										 
												----<dbms_OUTPUT.put_line('v_iresced_xl: ' || v_iresced_xl);
												----<dbms_OUTPUT.put_line('v_presrea: ' || v_presrea);
												IF v_iresced_xl <> 0 OR v_ipagced_xl <> 0 THEN
													 --KBR Añadir al PAC_REASEGURO_XL 24/10/2013
													 --Para cada siniestro
													 FOR sini IN 1 .. v_contador LOOP
															p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion,
																							NULL, 1904, 'Evaluando siniestro: ' || v_movsin(sini).nsinies);
													 
															FOR compa IN c_cuadroces_agr(v_movsin(sini).scontra, v_movsin(sini).nversio,
																													 v_ctramo) LOOP
																 IF v_cmultimon = 1 THEN
																		nerr := pac_oper_monedas.f_datos_contraval(NULL, NULL, v_movsin(sini).scontra,
																																							 v_movsin(sini).fsinies, 3, v_itasa,
																																							 v_fcambio);
																 
																		IF nerr <> 0 THEN
																			 o_plsql    := SQLERRM;
																			 p_pscesrea := TO_NUMBER(TO_CHAR(v_movsin(sini).scontra) ||
																															 TO_CHAR(v_movsin(sini).nversio) ||
																															 TO_CHAR(v_ctramo) || TO_CHAR(compa.ccompani));
																		END IF;
																 END IF;
															
																 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion,
																								 NULL, 1928,
																								 'Compañía: ' || compa.ccompani || ' % Part: ' || compa.pcesion);
																 v_icuorea   := v_ipagced_xl * compa.pcesion / 100;
																 v_iresrea   := v_iresced_xl * compa.pcesion / 100;
																 v_itotrea   := v_icuorea + v_iresrea;
																 v_iresgas   := v_iresgas_tot * v_prea / 100 * compa.pcesion / 100;
																 v_iresindem := v_iresindem_tot * v_prea / 100 * compa.pcesion / 100;
																 v_iresinter := v_iresinter_tot * v_prea / 100 * compa.pcesion / 100;
																 v_iresadmin := v_iresadmin_tot * v_prea / 100 * compa.pcesion / 100;
																 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion,
																								 NULL, 1940,
																								 'Pago sin: ' || v_icuorea || ' Reserva sin: ' || v_iresrea);
																 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion,
																								 NULL, 1945,
																								 'Pago total sin: ' || v_movsin(sini).pago_total_sin ||
																									' Reserva total sin: ' || v_movsin(sini).reserva_total_sin);
															
																 IF v_temp_pagos_ret = 0 THEN
																		v_iliqrea_sin    := 0;
																		v_primareest_sin := 0;
																 ELSE
																		v_iliqrea_sin := ((v_movsin(sini)
																										 .pago_total_sin * v_ipagced_xl / v_temp_pagos_ret)) *
																										 compa.pcesion / 100;
																		--pr=(pmd*pagos cedidos xl de la capa/ capacidad de la capa)* %reestablecimiento;
																		v_primareest_sin := (v_ipmd * v_iliqrea_sin / v_ixlcapaci) * v_preest / 100;
																		p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete,
																										v_nom_funcion, NULL, 2317,
																										'Prima Reest. x Sin: ' || v_primareest_sin);
																 END IF;
															
																 IF v_ipagced_xl = v_iced_xl THEN
																		v_iresrea_sin := 0;
																 ELSE
																		IF v_temp_totrea_evto = 0 THEN
																			 v_iresrea_sin := 0;
																		ELSE
																			 --KBR 08052014
																			 IF NVL(pac_parametros.f_parempresa_n(p_pcempres, 'MANEJO_RESERVAXL_REA'),
																							0) = 1 THEN
																					IF v_ipagced_xl = 0 THEN
																						 v_iresrea_sin := ((((v_movsin(sini).pago_total_sin + v_movsin(sini)
																															.reserva_total_sin) * v_iced_xl /
																															v_temp_totrea_evto)) * compa.pcesion / 100) -
																															v_iliqrea_sin;
																					ELSE
																						 v_iresrea_sin := v_movsin(sini)
																															.reserva_total_sin * compa.pcesion / 100;
																					END IF;
																			 ELSE
																					v_iresrea_sin := ((((v_movsin(sini)
																													 .pago_total_sin + v_movsin(sini).reserva_total_sin) *
																													 v_iced_xl / v_temp_totrea_evto)) * compa.pcesion / 100) -
																													 v_iliqrea_sin;
																			 END IF;
																			 --Fin KBR 08052014
																		END IF;
																 END IF;
															
																 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion,
																								 NULL, 1957,
																								 'Pago sin Cia: ' || v_iliqrea_sin || ' Reserva sin Cia: ' ||
																									v_iresrea_sin);
															
																 -- Añadir detalle liquidación neta y reservas netas
																 -- Buscar la PCESION en CTATECNICA_HIS cuando todavía no se ha actualizado la CTATECNICA
																 BEGIN
																		SELECT NVL(cestado, 1)
																			INTO v_cestado_cia
																			FROM ctatecnica
																		 WHERE scontra = v_movsin(sini).scontra
																			 AND nversio = v_movsin(sini).nversio
																			 AND ctramo = v_ctramo
																			 AND ccompani = compa.ccompani
																			 AND sproduc = v_movsin(sini).sproduc;
																 EXCEPTION
																		WHEN no_data_found THEN
																			 BEGIN
																					INSERT INTO ctatecnica
																						 (ccompani, nversio, scontra, ctramo, nctatec, cfrecul, cestado,
																							festado, fcierre, cempres, sproduc, ccorred)
																					VALUES
																						 (compa.ccompani, v_movsin(sini).nversio, v_movsin(sini).scontra,
																							v_ctramo, 1, 3, 1, NULL, NULL, p_pcempres, v_movsin(sini).sproduc,
																							compa.ccorred);
																			 EXCEPTION
																					WHEN OTHERS THEN
																						 -- nerr := 104861; DCT 13/02/2014
																						 v_cestado_cia := 1; --DCT 13/02/2014
																						 p_tab_error(f_sysdate, f_user, vobj, v_traza,
																												 'XL por Cumulos: Err INSERT INTO ctatecnica',
																												 ' SQLERRM = ' || SQLERRM || ' nerr = ' || nerr);
																			 END;
																		WHEN OTHERS THEN
																			 -- nerr := 104866; DCT 13/02/2014
																			 v_cestado_cia := 1; --DCT 13/02/2014
																			 o_plsql       := SQLERRM;
																			 p_tab_error(f_sysdate, f_user, vobj, v_traza,
																									 'XL por Cumulos: Err SELECT ctatecnica',
																									 ' v_scontra=' || v_movsin(sini).scontra || ' v_nversio=' || v_movsin(sini)
																									 .nversio || ' v_ctramo=' || v_ctramo || ' compa.ccompani=' ||
																										compa.ccompani || ' SQLERRM = ' || SQLERRM || ' nerr = ' || nerr);
																 END;
															
																 --Insert en LiquidareaXL
																 BEGIN
																		p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete,
																										v_nom_funcion, NULL, 2012, 'Insert en Liquidareaxl_aux');
																 
																		INSERT INTO liquidareaxl_aux
																			 (nsinies, fsinies, itotexp, fcierre, sproces, scontra, nversio, ctramo,
																				ccompani, pcuorea, icuorea, ipagrea, iliqrea, ireserv, pcuotot, itotrea,
																				iresrea, iliqnet, iresnet, iresgas, iresindem, iresinter, iresadmin,
																				icuorea_moncon, iliqnet_moncon, iliqrea_moncon, ipagrea_moncon,
																				ireserv_moncon, iresgas_moncon, iresindem_moncon, iresinter_moncon,
																				iresadmin_moncon, iresnet_moncon, iresrea_moncon, itotexp_moncon,
																				itotrea_moncon)
																		VALUES
																			 (v_movsin(sini).nsinies, v_movsin(sini).fsinies, v_pago_idx, p_pfperfin,
																				p_pproces, v_movsin(sini).scontra, v_movsin(sini).nversio, v_ctramo,
																				compa.ccompani, v_pcuorea,
																				--% Pagos de reaseguro
																				v_icuorea,
																				--Importe de cuota del reaseguro por cia
																				v_ipagrea_mov,
																				--Liquidaciones anteriores por SINIESTRO-EVENTO
																				v_ipagrea_mov,
																				--Importe de pagos liquidados por siniestro-evento
																				v_iresrea_sin,
																				--Importe de reservas por siniestro-evento
																				v_pcuotot,
																				--% Total del Reaseguro
																				v_itotrea,
																				--Importe Total de reaseguro por cia
																				v_iresrea_mov,
																				--Importe total de reserva de reaseguro por cia
																				v_iliqrea_sin,
																				--Importe de pagos liquidados por siniestro-evento
																				v_iresrea_sin, v_iresgas, v_iresindem, v_iresinter, v_iresadmin,
																				f_round(NVL(v_icuorea, 0) * v_itasa, v_cmoncontab),
																				f_round(NVL(v_iliqrea_sin, 0) * v_itasa, v_cmoncontab),
																				f_round(NVL(v_ipagrea_mov, 0) * v_itasa, v_cmoncontab),
																				f_round(NVL(v_ipagrea_mov, 0) * v_itasa, v_cmoncontab),
																				f_round(NVL(v_iresrea_mov, 0) * v_itasa, v_cmoncontab),
																				f_round(NVL(v_iresgas, 0) * v_itasa, v_cmoncontab),
																				f_round(NVL(v_iresindem, 0) * v_itasa, v_cmoncontab),
																				f_round(NVL(v_iresinter, 0) * v_itasa, v_cmoncontab),
																				f_round(NVL(v_iresadmin, 0) * v_itasa, v_cmoncontab),
																				f_round(NVL(v_iresrea_sin, 0) * v_itasa, v_cmoncontab),
																				f_round(NVL(v_iresrea_mov, 0) * v_itasa, v_cmoncontab),
																				f_round(NVL(v_pago_idx, 0) * v_itasa, v_cmoncontab),
																				f_round(NVL(v_itotrea, 0) * v_itasa, v_cmoncontab));
																 EXCEPTION
																		WHEN dup_val_on_index THEN
																			 UPDATE liquidareaxl_aux
																					SET icuorea = icuorea + v_icuorea, iliqrea = iliqrea + v_ipagrea_mov,
																							ireserv = ireserv + v_iresrea_mov, itotrea = itotrea + v_itotrea,
																							iresrea = iresrea + v_iresrea_mov,
																							iliqnet = iliqnet + v_iliqrea_sin,
																							iresnet = iresnet + v_iresrea_sin,
																							icuorea_moncon = icuorea_moncon +
																																f_round(NVL(v_icuorea, 0) * v_itasa, v_cmoncontab),
																							iliqnet_moncon = iliqnet_moncon +
																																f_round(NVL(v_iliqrea_sin, 0) * v_itasa,
																																				v_cmoncontab),
																							iliqrea_moncon = iliqrea_moncon +
																																f_round(NVL(v_ipagrea_mov, 0) * v_itasa,
																																				v_cmoncontab),
																							ireserv_moncon = ireserv_moncon +
																																f_round(NVL(v_iresrea_mov, 0) * v_itasa,
																																				v_cmoncontab),
																							iresnet_moncon = iresnet_moncon +
																																f_round(NVL(v_iresrea_sin, 0) * v_itasa,
																																				v_cmoncontab),
																							iresrea_moncon = iresrea_moncon +
																																f_round(NVL(v_iresrea_mov, 0) * v_itasa,
																																				v_cmoncontab),
																							itotrea_moncon = itotrea_moncon +
																																f_round(NVL(v_itotrea, 0) * v_itasa, v_cmoncontab)
																				WHERE nsinies = v_movsin(sini).nsinies
																					AND fcierre = p_pfperfin
																					AND sproces = p_pproces
																					AND scontra = v_movsin(sini).scontra
																					AND nversio = v_movsin(sini).nversio
																					AND ctramo = v_ctramo
																					AND ccompani = compa.ccompani;
																		WHEN OTHERS THEN
																			 nerr := 1;
																			 p_tab_error(f_sysdate, f_user, vobj, v_traza,
																									 'Err INSERT INTO liquidareaxl_aux', 'SQLERRM = ' || SQLERRM);
																 END; --Insert en Liquidareaxl_aux
															
																 IF v_iliqrea_sin <> 0 THEN
																		--Insert Pagosreaxl_aux
																		BEGIN
																			 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete,
																											 v_nom_funcion, NULL, 2130, 'Insert en Pagosreaxl_aux');
																		
																			 INSERT INTO pagosreaxl_aux
																					(nsinies, scontra, nversio, ctramo, ccompani, fcierre, sproces,
																					 iliqrea, cestliq, iliqrea_moncon, fcambio)
																			 VALUES
																					(v_movsin(sini).nsinies, v_movsin(sini).scontra,
																					 v_movsin(sini).nversio, v_ctramo, compa.ccompani, p_pfperfin,
																					 p_pproces, v_iliqrea_sin, 0,
																					 f_round(NVL(v_iliqrea_sin, 0) * v_itasa, v_cmoncontab),
																					 DECODE(v_cmultimon, 0, NULL, NVL(v_fcambio, v_movsin(sini).fsinies)));
																		EXCEPTION
																			 WHEN dup_val_on_index THEN
																					UPDATE pagosreaxl_aux
																						 SET iliqrea = iliqrea + v_iliqrea_sin,
																								 iliqrea_moncon = iliqrea_moncon +
																																	 f_round(NVL(v_iliqrea_sin, 0) * v_itasa,
																																					 v_cmoncontab)
																					 WHERE nsinies = v_movsin(sini).nsinies
																						 AND scontra = v_movsin(sini).scontra
																						 AND nversio = v_movsin(sini).nversio
																						 AND ctramo = v_ctramo
																						 AND ccompani = compa.ccompani
																						 AND fcierre = p_pfperfin
																						 AND sproces = p_pproces;
																			 WHEN OTHERS THEN
																					p_tab_error(f_sysdate, f_user, vobj, v_traza,
																											'Err INSERT INTO pagosreaxl', ' SQLERRM = ' || SQLERRM);
																					nerr := 1;
																		END; --Insert Pagosreaxl_aux
																 
																		-- Se actualizan pagos anteriores NO LIQUIDADOS
																		BEGIN
																			 UPDATE pagosreaxl
																					SET cestliq = 2
																				WHERE scontra = v_movsin(sini).scontra
																					AND nversio = v_movsin(sini).nversio
																					AND ctramo = v_ctramo
																					AND ccompani = compa.ccompani
																					AND fcierre < p_pfperfin
																					AND nsinies = v_movsin(sini).nsinies
																					AND cestliq = 0;
																		EXCEPTION
																			 WHEN no_data_found THEN
																					v_ipagrea := 0;
																			 WHEN OTHERS THEN
																					nerr := 1;
																					p_tab_error(f_sysdate, f_user, vobj, v_traza, 'Err UPDATE pagosreaxl',
																											' v_scontra =' || v_movsin(sini).scontra || ' v_nversio =' || v_movsin(sini)
																											.nversio || ' v_ctramo =' || v_ctramo || ' compa.ccompani=' ||
																											 compa.ccompani || ' sini.nsin=' || v_movsin(sini).nsinies ||
																											 ' p_pfperfin =' || p_pfperfin || ' SQLERRM = ' || SQLERRM);
																		END;
																 END IF;
															
																 BEGIN
																		SELECT NVL(MAX(nnumlin), 0)
																			INTO w_nnumlin
																			FROM movctaaux
																		 WHERE scontra = v_movsin(sini).scontra
																			 AND nversio = v_movsin(sini).nversio
																			 AND ctramo = v_ctramo
																			 AND ccompani = compa.ccompani;
																 
																		w_nnumlin := w_nnumlin + 1;
																 EXCEPTION
																		WHEN no_data_found THEN
																			 w_nnumlin := 1;
																		WHEN OTHERS THEN
																			 nerr    := 104863;
																			 o_plsql := SQLERRM;
																			 p_tab_error(f_sysdate, f_user, vobj, v_traza, 'Err SELECT MOVCTAAUX',
																									 ' v_scontra=' || v_movsin(sini).scontra || ' v_nversio=' || v_movsin(sini)
																									 .nversio || ' v_ctramo=' || v_ctramo || ' compa.ccompani=' ||
																										compa.ccompani || ' SQLERRM = ' || SQLERRM);
																 END;
															
																 IF v_iliqrea_sin <> 0 THEN
																		-- 5 -> Siniestros
																		p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete,
																										v_nom_funcion, NULL, 2228,
																										'Insert en movctaaux-> Concepto (5) Pago Siniestros');
																		v_movsin(sini).ctramo := v_ctramo;
																		nerr := f_insertxl_movctatecnica(w_ctadet, v_movsin(sini), w_nnumlin, 5,
																																		 compa.ccompani, v_iliqrea_sin, p_pproces,
																																		 v_cestado_cia, p_pcempres, p_pfperfin,
																																		 compa.ccorred); -- 25/05/2015  CJMR  0033158: Actualización campo CCORRED en los cierres de Reaseguro
																 END IF;
															
																 IF v_iliqrea_sin <> 0 THEN
																		-- 15 -> Liquidacion XL
																		p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete,
																										v_nom_funcion, NULL, 2239,
																										'Insert en movctaaux-> Concepto (15) Liquidacion XL');
																		v_movsin(sini).ctramo := v_ctramo;
																		nerr := f_insertxl_movctatecnica(w_ctadet, v_movsin(sini), w_nnumlin, 15,
																																		 compa.ccompani, v_iliqrea_sin, p_pproces,
																																		 v_cestado_cia, p_pcempres, p_pfperfin,
																																		 compa.ccorred); -- 25/05/2015  CJMR  0033158: Actualización campo CCORRED en los cierres de Reaseguro
																 END IF;
															
																 IF v_iresrea_sin <> 0 THEN
																		-- 25 -> Reserva de Siniestros
																		p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete,
																										v_nom_funcion, NULL, 2251,
																										'Insert en movctaaux-> Concepto (25) Reserva Siniestros');
																		v_movsin(sini).ctramo := v_ctramo;
																		nerr := f_insertxl_movctatecnica(w_ctadet, v_movsin(sini), w_nnumlin, 25,
																																		 compa.ccompani, v_iresrea_sin, p_pproces,
																																		 v_cestado_cia, p_pcempres, p_pfperfin,
																																		 compa.ccorred); -- 25/05/2015  CJMR  0033158: Actualización campo CCORRED en los cierres de Reaseguro
																 END IF;
															
																 IF v_primareest_sin <> 0 THEN
																		-- 23 -> Reinstalamento XL
																		p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete,
																										v_nom_funcion, NULL, 2438,
																										'Insertando en movctaaux-> Concepto 23 (Prima de Reinstalamiento XL)');
																		v_movsin(sini).ctramo := v_ctramo;
																		nerr := f_insertxl_movctatecnica(w_ctadet, v_movsin(sini), w_nnumlin, 23,
																																		 compa.ccompani, v_primareest_sin, p_pproces,
																																		 v_cestado_cia, p_pcempres, p_pfperfin,
																																		 compa.ccorred); -- 25/05/2015  CJMR  0033158: Actualización campo CCORRED en los cierres de Reaseguro
																 END IF;
															END LOOP; --Cias
													 END LOOP; --Siniestros
												END IF;
										 
												--KBR Multitramos y Reinstalaciones
												IF NVL(pac_parametros.f_parempresa_n(p_pcempres, 'PERMITE_MREPOXL_REA'), 0) = 0 THEN
													 EXIT;
												END IF;
										 END;
									END LOOP; --Reestablecimientos
							 END IF;
						
							 --KBR Multitramos y Reinstalaciones
							 IF NVL(pac_parametros.f_parempresa_n(p_pcempres, 'PERMITE_MTRAMOXL_REA'), 0) = 0 THEN
									EXIT;
							 END IF;
						END;
				 END LOOP; --Multitramos
			
				 --Fin
				 v_sin            := 0;
				 v_contador       := 0;
				 v_res_dist       := 0;
				 v_pago_idx       := 0;
				 v_pago_no_idx    := 0;
				 v_reserva        := 0;
				 v_totalpagos_ret := 0;
				 v_prea           := 0;
				 v_iced_xl        := 0;
			END IF;
	 
			--KBR 13/11/2013: Se incluye esta validacion para que el proceso no termine con error cuando no consiga contrato de reaseguro XL asociado
			--Se debe incluir un metodo para determinar cuando un ramo/producto está protegido por un contrato de reaseguro XL
			IF NVL(v_scontra, 0) = 0 THEN
				 nerr := 0;
			END IF;
	 
			p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL, 2286,
											'Fin de proceso: ' || nerr);
			COMMIT;
			RETURN(nerr);
	 END; --f_xl_sin_cumulo

	 FUNCTION llena_liquidaxl_aux(pcempres IN NUMBER, pdefi IN NUMBER, pipc IN NUMBER, pmes IN NUMBER,
																pany IN NUMBER, pfcierre IN DATE, pproces IN NUMBER, psql OUT VARCHAR2,
																pscesrea OUT NUMBER, pfperini IN DATE, pfperfin IN DATE) RETURN NUMBER IS
			vobj          VARCHAR2(200) := 'PAC_REASEGURO_XL.llena_liquidaxl_aux';
			nerr          NUMBER := 0;
			pnnumlin      NUMBER;
			texto         VARCHAR2(200);
			v_traza       NUMBER;
			v_nom_paquete VARCHAR2(80) := 'PAC_REASEGURO_XL';
			v_nom_funcion VARCHAR2(80) := 'LLENA_LIQUIDAXL_AUX';
	 BEGIN
			v_traza := 1;
			----------------------------------------------------------------------------
			--     1. inicializamos el IAGREAGA de cuadroces para todas las compañias --
			----------------------------------------------------------------------------
			p_traza_proceso(pcempres, vpar_traza, pproces, v_nom_paquete, v_nom_funcion, NULL, 2320,
											'Inicio de proceso', 1);
	 
			BEGIN
				 UPDATE cuadroces
						SET iagrega = 0
					WHERE scontra IN (SELECT scontra FROM codicontratos WHERE ctiprea = 3); -- XL
			EXCEPTION
				 WHEN OTHERS THEN
						nerr := 1;
						p_tab_error(f_sysdate, f_user, vobj, v_traza, 'Err UPDATE cuadroces', ' SQLERRM = ' || SQLERRM);
			END;
	 
			--XL por eventos:
			--Dividimos el proceso, uno para cuando sea por siniestro y otro para cuando sea por eventos
			v_traza := 2;
			-- dc_p_trazas(7777777, 'en el cierre xl paso 8');
			nerr := f_xl_siniestros(pcempres, pdefi, pipc, pmes, pany, pfcierre, pproces, pscesrea, pfperini, pfperfin,
															psql);
	 
			IF nerr <> 0 THEN
				 p_tab_error(f_sysdate, f_user, vobj, v_traza, 'Error en f_xl_siniestros', ' SQLERRM = ' || psql);
			END IF;
	 
			--KBR 09/12/2013 28991 Siniestros con cúmulo
			v_traza := 3;
	 
			--Solo activo para POSITIVA
			IF nerr = 0 AND pcempres = 17 THEN
				 nerr := f_xl_siniestros_con_cumulo(pcempres, pdefi, pipc, pmes, pany, pfcierre, pproces, pscesrea,
																						pfperini, pfperfin, psql);
			
				 IF nerr <> 0 THEN
						p_tab_error(f_sysdate, f_user, vobj, v_traza, 'Error en f_xl_siniestros_con_cumulo',
												' SQLERRM = ' || psql);
				 END IF;
			END IF;
	 
			IF nerr = 0 THEN
				 v_traza := 4;
				 nerr    := f_xl_eventos(pcempres, pdefi, pipc, pmes, pany, pfcierre, pproces, pscesrea, pfperini,
																 pfperfin, psql);
			
				 IF nerr <> 0 THEN
						p_tab_error(f_sysdate, f_user, vobj, v_traza, 'Error en f_xl_eventos', ' SQLERRM = ' || psql);
				 END IF;
			END IF;
			-- dc_p_trazas(7777777, 'en el cierre xl paso 9');
			--XL por eventos:
			--Crear función para insertar prima mínima de depósito por pagos fraccionados
			IF nerr = 0 THEN
				 v_traza := 5;
				 -- dc_p_trazas(7777777, 'en el cierre xl paso 10');
				 nerr := f_insertar_pmd(pcempres, pmes, pproces, pfperfin, psql);
			
				 IF nerr <> 0 THEN
						p_tab_error(f_sysdate, f_user, vobj, v_traza, 'Error en f_insertar_pmd', ' SQLERRM = ' || psql);
				 END IF;
			END IF;
	 
			RETURN(nerr);
	 END llena_liquidaxl_aux;

	 --BUG 0026444 - 27/07/2013 - JRH - Realizamos la cesión de pago al XF Facultativo
	 FUNCTION f_insert_movctaaux(pcempres NUMBER, psseguro NUMBER, pfecha DATE, pimporteini IN NUMBER,
															 pctadet NUMBER, pnsin NUMBER, pfsinies DATE, pccompapr NUMBER, p_pproces NUMBER,
															 pmes_sin NUMBER, panyo_sin NUMBER, pcestadoin NUMBER, p_pfperfin DATE,
															 pconcep NUMBER, pscontra NUMBER, pnversio NUMBER, pvtramo NUMBER, pccompani NUMBER,
															 psproduc NUMBER, pimporte NUMBER, w_nnumlin NUMBER) --JRH Gen. 5
		RETURN NUMBER IS
			vobj         VARCHAR2(200) := 'PAC_REASEGURO_XL.f_insert_movctaaux';
			v_traza      NUMBER;
			vpar         VARCHAR2(4000) := 'pcempres:' || pcempres || ' ' || 'psseguro:' || psseguro || ' ' ||
																		 'Pfecha:' || pfecha || ' ' || 'pimporteIni:' || pimporteini || ' ' ||
																		 'pctadet:' || pctadet || ' ' || 'pnsin:' || pnsin || '  pccompapr:' ||
																		 pccompapr || 'pmes_sin:' || pmes_sin || '  panyo_sin:' || panyo_sin ||
																		 'pcestadoin:' || pcestadoin || '  p_pfperfin:' || p_pfperfin ||
																		 '  p_pproces:' || p_pproces || '  pconcep:' || pconcep || 'pscontra:' ||
																		 pscontra || ' ' || 'pnversio:' || pnversio || 'pvtramo:' || pvtramo ||
																		 'pccompani:' || pccompani || 'psproduc:' || psproduc || 'pimporte:' ||
																		 pimporte;
			nerr         NUMBER := 1;
			vimporteacum NUMBER := 0;
			vimporte     NUMBER := 0;
			--   w_nnumlin      NUMBER := 0;
			--   vtramo         NUMBER;
			--  v_cestado      NUMBER;
			v_numero  NUMBER;
			v_cdebhab NUMBER;
			errpars EXCEPTION;
	 BEGIN
			IF (pcempres IS NULL) OR (psseguro IS NULL) OR (pfecha IS NULL) OR (pimporteini IS NULL) OR
				 (pctadet IS NULL)
				--OR(pccompapr IS NULL) KBR 11/11/2013 28777: Ajustes XL Facultativo
				 OR (pmes_sin IS NULL) OR (panyo_sin IS NULL) OR (pcestadoin IS NULL) OR (p_pfperfin IS NULL) OR
				 (p_pproces IS NULL) OR (pconcep IS NULL) OR (pfsinies IS NULL) OR (pscontra IS NULL) OR
				 (pnversio IS NULL) OR (pvtramo IS NULL) OR (pccompani IS NULL) OR (psproduc IS NULL) OR
				 (pimporte IS NULL) OR (pnsin IS NULL) THEN
				 RAISE errpars;
			END IF;
	 
			---------------------------------------------------------------
			---------------------------------------------------------------
			-----BUCLE COMPAÑÍAS
			------------------------------------------------------------------
			---------------------------------------------------------------
			v_traza := 1;
			--  vtramo := 5;   --JRH IMP
			--   v_cestado := NULL;
			--  w_nnumlin := NULL;
			v_numero := NULL;
			vimporte := NULL;
			---------------------------------------------------------------
			---------------------------------------------------------------
			------Numero de movcta
			------------------------------------------------------------------
			---------------------------------------------------------------
	 
			--         SELECT NVL(MAX(nnumlin), 0) + 1
			--           INTO w_nnumlin
			--           FROM movctaaux
			--          WHERE scontra = pscontra
			--            AND nversio = pnversio
			--            AND ctramo = pvtramo
			--            AND ccompani = pccompani;
			v_traza := 2;
			---------------------------------------------------------------
			---------------------------------------------------------------
			------MOVCTAAUX
			------------------------------------------------------------------
			---------------------------------------------------------------
			v_traza := 8;
	 
			--30203-178381: SHA 30/06/2014
			SELECT cdebhab
				INTO v_cdebhab
				FROM tipoctarea
			 WHERE cconcep = pconcep
				 AND cempres = pcempres;
	 
			IF NVL(pctadet, 0) = 1 THEN
				 v_traza := 9;
			
				 SELECT COUNT(1)
					 INTO v_numero
					 FROM movctaaux
					WHERE scontra = pscontra
						AND nversio = pnversio
						AND ctramo = pvtramo
						AND ccompani = pccompani
						AND cconcep = pconcep
						AND (sproduc = psproduc OR NVL(sproduc, 0) = 0)
						AND nsinies = pnsin;
			ELSE
				 v_traza := 10;
			
				 SELECT COUNT(1)
					 INTO v_numero
					 FROM movctaaux
					WHERE scontra = pscontra
						AND nversio = pnversio
						AND ctramo = pvtramo
						AND ccompani = pccompani
						AND cconcep = pconcep
						AND (sproduc = psproduc OR NVL(sproduc, 0) = 0);
			END IF;
	 
			---------------------------------------------------------------
			---------------------------------------------------------------
			------MODIF MOVCTAAUX
			------------------------------------------------------------------
			---------------------------------------------------------------
			IF v_numero > 0 THEN
				 v_traza := 21;
			
				 -- detall a nivell de sinistre
				 IF NVL(pctadet, 0) = 1 THEN
						BEGIN
							 UPDATE movctaaux
									SET iimport = iimport + pimporte
								WHERE scontra = pscontra
									AND nversio = pnversio
									AND ctramo = pvtramo
									AND ccompani = pccompani
									AND cconcep = pconcep
									AND (sproduc = psproduc OR NVL(sproduc, 0) = 0)
									AND NVL(ccompapr, 0) = NVL(pccompapr, 0)
									AND nsinies = pnsin;
						EXCEPTION
							 WHEN OTHERS THEN
									v_traza := 22;
									nerr    := 105801;
									p_tab_error(f_sysdate, f_user, vobj, v_traza, 'Err UPDATE movctaaux - cconcep = ' || pconcep,
															' v_iliqrea=' || vimporte || ' v_scontra=' || pscontra || ' v_nversio=' ||
															 pnversio || ' v_ctramo=' || pvtramo || ' compa.ccompani=' || pccompani ||
															 ' sini.nsin:' || pnsin || ' SQLERRM = ' || SQLERRM);
									RAISE;
						END;
				 ELSE
						v_traza := 23;
				 
						BEGIN
							 UPDATE movctaaux
									SET iimport = iimport + pimporte
								WHERE scontra = pscontra
									AND nversio = pnversio
									AND ctramo = pvtramo
									AND ccompani = pccompani
									AND cconcep = pconcep
									AND NVL(ccompapr, 0) = NVL(pccompapr, 0)
									AND (sproduc = psproduc OR NVL(sproduc, 0) = 0);
						EXCEPTION
							 WHEN OTHERS THEN
									nerr    := 105801;
									v_traza := 24;
									p_tab_error(f_sysdate, f_user, vobj, v_traza, 'Err UPDATE movctaaux - cconcep = ' || pconcep,
															' v_iliqrea=' || vimporte || ' v_scontra=' || pscontra || ' v_nversio=' ||
															 pnversio || ' v_ctramo=' || pvtramo || ' compa.ccompani=' || pccompani ||
															 ' SQLERRM = ' || SQLERRM);
									RAISE;
						END;
				 END IF;
			ELSE
				 --(4.e.iv.5.b.) No existe
				 --(4.e.iv.5.b.i.) Se hace el primer Insert en MOVCTAAUX
				 --DBMS_OUTPUT.put_line('INSERT INTO movctaaux 5');
				 v_traza := 25;
			
				 ---------------------------------------------------------------
				 ---------------------------------------------------------------
				 ------ALTA MOVCTAAUX
				 ------------------------------------------------------------------
				 ---------------------------------------------------------------
				 -- detall a nivell de sinistre
				 --KBR 11/12/2013
				 IF pimporte <> 0 THEN
						BEGIN
							 INSERT INTO movctaaux
									(ccompani, nversio, scontra, ctramo, nnumlin, fmovimi, fefecto, cconcep, cdebhab, iimport,
									 cestado, sproces, scesrea, cempres, fcierre, sproduc, nsinies, ccompapr)
							 VALUES
									(pccompani, pnversio, pscontra, pvtramo, w_nnumlin,
									 LAST_DAY(TO_DATE('01/' || pmes_sin || '/' || panyo_sin, 'dd/mm/yyyy')),
									 LAST_DAY(TO_DATE('01/' || pmes_sin || '/' || panyo_sin, 'dd/mm/yyyy')), pconcep, v_cdebhab,
									 pimporte, pcestadoin, p_pproces, NULL, pcempres, p_pfperfin, psproduc,
									 DECODE(NVL(pctadet, 0), 1, pnsin, 0), pccompapr);
						EXCEPTION
							 WHEN dup_val_on_index THEN
									nerr    := 105800;
									v_traza := 26;
									p_tab_error(f_sysdate, f_user, vobj, v_traza,
															'Err DUPLICADO INSERT movctaaux - cconcep = ' || pconcep,
															' v_scontra=' || pscontra || ' v_nversio=' || pnversio || ' v_ctramo=' || pvtramo ||
															 ' compa.ccompani=' || pccompani || ' SQLERRM = ' || SQLERRM);
									RAISE;
							 WHEN OTHERS THEN
									nerr    := 105802;
									v_traza := 27;
									p_tab_error(f_sysdate, f_user, vobj, v_traza, 'Err INSERT movctaaux - cconcep = ' || pconcep,
															' v_scontra=' || pscontra || ' v_nversio=' || pnversio || ' v_ctramo=' || pvtramo ||
															 ' compa.ccompani=' || pccompani || ' SQLERRM = ' || SQLERRM);
									RAISE;
						END;
				 END IF;
			END IF;
	 
			RETURN 0;
	 EXCEPTION
			WHEN errpars THEN
				 p_tab_error(f_sysdate, f_user, vobj, v_traza, 'Error en reparto XL Facultativo parámetros:' || vpar,
										 ' SQLERRM = ' || SQLERRM);
				 RETURN - 4;
			WHEN OTHERS THEN
				 p_tab_error(f_sysdate, f_user, vobj, v_traza, 'Error en reparto XL Facultativo:' || vpar,
										 ' SQLERRM = ' || SQLERRM);
				 RETURN nerr;
	 END f_insert_movctaaux;

	 FUNCTION f_cessio_xlfacult(pcempres NUMBER, psseguro NUMBER, pfecha DATE, pimporte IN NUMBER, pctadet NUMBER,
															pnsin NUMBER, pfsinies DATE, pcgarant IN NUMBER, pccompapr NUMBER, p_pproces NUMBER,
															pmes_sin NUMBER, panyo_sin NUMBER,
															--  pcestadoin NUMBER,
															p_pfperfin DATE, p_itasa NUMBER, p_cmoncontab NUMBER, p_cmultimon NUMBER,
															p_fcambio DATE, p_iliqrea_lim NUMBER, p_pago_indexado_fac NUMBER, p_pct_fac NUMBER,
															p_ireserv_fac NUMBER, p_desglose_reserva NUMBER, p_iresgas_tot_fac NUMBER,
															p_iresindem_tot_fac NUMBER, p_iresinter_tot_fac NUMBER, p_iresadmin_tot_fac NUMBER)
			RETURN NUMBER IS
			CURSOR cfacultxl IS
				 SELECT s.npoliza, s.sseguro, s.ncertif, c.nmovimi, NVL(c.nriesgo, r.nriesgo) nriesgo, c.cgarant,
								c.sfacult, c.cestado, c.scontra, c.nversio, c.finicuf, c.ffincuf, c.scumulo, c.plocal, c.pfacced,
								c.ifacced, c.ctipfac, c.ptasaxl, cf.pcesion, cf.ccompani, s.sproduc, cf.ccorred
					 FROM cuacesfac cf, cuafacul c, reariesgos r, seguros s
					WHERE ((c.scumulo IS NULL AND c.sseguro = s.sseguro) OR (c.scumulo = r.scumulo))
						AND r.sseguro(+) = s.sseguro
						AND s.cempres = pcempres
						AND s.sseguro = psseguro
						AND EXISTS (SELECT 1 FROM cesionesrea cr WHERE cr.sseguro = s.sseguro)
						AND c.cestado = 2
						AND c.finicuf <= pfecha
							 --JRH Comentamos por si hay agrupación de garantía --> KBR 11/11/2013 28777: Ajustes XL Facultativo
							 --AND NVL(c.cgarant, 0) = NVL(pcgarant, 0) KBR 11/11/2013 28777: Ajustes XL Facultativo
						AND ((c.cgarant IS NOT NULL AND c.cgarant = NVL(pcgarant, 0)) OR (c.cgarant IS NULL))
						AND ((c.ffincuf > pfecha AND c.ffincuf IS NOT NULL) OR (c.ffincuf IS NULL))
						AND cf.sfacult = c.sfacult
						AND NVL(c.ctipfac, 0) = 1; -- JRH IMP Falta mirar agr_contratos o las garantías.
	 
			vobj         VARCHAR2(200) := 'PAC_REASEGURO_XL.f_cessio_xlfacult';
			v_traza      NUMBER;
			vpar         VARCHAR2(2000) := 'pcempres:' || pcempres || ' ' || 'psseguro:' || psseguro || ' ' ||
																		 'Pfecha:' || pfecha || ' ' || 'pimporte:' || pimporte || ' ' || 'pctadet:' ||
																		 pctadet || ' ' || 'pnsin:' || pnsin || '  pccompapr:' || pccompapr ||
																		 'pmes_sin:' || pmes_sin || '  panyo_sin:' || panyo_sin || '  p_pfperfin:' ||
																		 p_pfperfin || '  p_pproces:' || p_pproces;
			nerr         NUMBER := 1;
			vimporteacum NUMBER := 0;
			vimporte     NUMBER := 0;
			w_nnumlin    NUMBER := 0;
			vtramo       NUMBER;
			v_cestado    NUMBER;
			v_numero     NUMBER;
			errpars EXCEPTION;
	 BEGIN
			IF (pcempres IS NULL) OR (psseguro IS NULL) OR (pfecha IS NULL) OR (pimporte IS NULL) OR (pctadet IS NULL)
				--OR(pccompapr IS NULL) KBR 11/11/2013 28777: Ajustes XL Facultativo
				 OR (pmes_sin IS NULL) OR (panyo_sin IS NULL)
				--   OR(pcestadoin IS NULL)
				 OR (p_pfperfin IS NULL) OR (p_pproces IS NULL) OR (pfsinies IS NULL) OR (pnsin IS NULL) THEN
				 RAISE errpars;
			END IF;
	 
			---------------------------------------------------------------
			---------------------------------------------------------------
			-----BUCLE COMPAÑÍAS
			------------------------------------------------------------------
			---------------------------------------------------------------
			FOR reg IN cfacultxl LOOP
				 v_traza   := 1;
				 vtramo    := 5; --JRH IMP
				 v_cestado := 1;
				 w_nnumlin := NULL;
				 v_numero  := NULL;
				 vimporte  := NULL;
			
				 ---------------------------------------------------------------
				 ---------------------------------------------------------------
				 ------Numero de movcta
				 ------------------------------------------------------------------
				 ---------------------------------------------------------------
				 SELECT NVL(MAX(nnumlin), 0) + 1
					 INTO w_nnumlin
					 FROM movctaaux
					WHERE scontra = reg.scontra
						AND nversio = reg.nversio
						AND ctramo = vtramo
						AND ccompani = reg.ccompani;
			
				 v_traza := 2;
			
				 ---------------------------------------------------------------
				 ---------------------------------------------------------------
				 ------Cta Técnica Hace falta?
				 ------------------------------------------------------------------
				 ---------------------------------------------------------------
				 BEGIN
						SELECT NVL(cestado, 1)
							INTO v_cestado
							FROM ctatecnica
						 WHERE scontra = reg.scontra
							 AND nversio = reg.nversio
							 AND ctramo = vtramo
							 AND ccompani = reg.ccompani
							 AND sproduc = reg.sproduc;
				 
						v_traza := 3;
				 EXCEPTION
						WHEN no_data_found THEN
							 --DBMS_OUTPUT.put_line('es nuevo, insertamos en ctatecnica');
							 BEGIN
									v_traza := 4;
							 
									INSERT INTO ctatecnica
										 (ccompani, nversio, scontra, ctramo, nctatec, cfrecul, cestado, festado, fcierre, cempres,
											sproduc, ccorred) -- 22076 AVT 25/05/2012 nous camps
									VALUES
										 (reg.ccompani, reg.nversio, reg.scontra, vtramo, 1, 3, 1, NULL, NULL, pcempres, reg.sproduc,
											reg.ccorred);
							 EXCEPTION
									WHEN OTHERS THEN
										 v_traza := 5;
										 -- nerr := 104866; DCT 13/02/2014
										 v_cestado := 1; --DCT 13/02/2014
										 v_traza   := 6;
										 p_tab_error(f_sysdate, f_user, vobj, v_traza, 'Err INSERT INTO ctatecnica',
																 ' SQLERRM = ' || SQLERRM);
										 RAISE;
							 END;
						WHEN OTHERS THEN
							 -- nerr := 104866; DCT 13/02/2014
							 v_cestado := 1; --DCT 13/02/2014
							 v_traza   := 7;
							 p_tab_error(f_sysdate, f_user, vobj, v_traza, 'Err SELECT ctatecnica',
													 ' v_scontra=' || reg.scontra || ' v_nversio=' || reg.nversio || ' v_ctramo=' ||
														vtramo || ' compa.ccompani=' || reg.ccompani || ' SQLERRM = ' || SQLERRM);
							 RAISE;
				 END;
			
				 ---------------------------------------------------------------
				 ---------------------------------------------------------------
				 ------MOVCTAAUX
				 ------------------------------------------------------------------
				 ---------------------------------------------------------------
				 vimporte := pimporte * reg.pcesion / 100; -- A saco por el PCT de momento
				 v_traza  := 8;
				 v_traza  := 9;
			
				 --
			
				 --JRH IMP Que campos enchufo aqui de todos los que hay
				 IF NVL(p_pago_indexado_fac, 0) <> 0 OR NVL(p_ireserv_fac, 0) <> 0 THEN
						BEGIN
							 INSERT INTO liquidareaxl_aux
									(nsinies, fsinies, itotexp, itotind, fcierre, sproces, scontra, nversio, ctramo, ccompani,
									 pcuorea, icuorea, ipagrea, iliqrea, ireserv, iresind, pcuotot, itotrea, iresrea, ilimind,
									 iliqnet, iresnet, iresgas, iresindem, iresinter, iresadmin, icuorea_moncon, ilimind_moncon,
									 iliqnet_moncon, iliqrea_moncon, ipagrea_moncon, ireserv_moncon, iresgas_moncon,
									 iresindem_moncon, iresinter_moncon, iresadmin_moncon, iresind_moncon, iresnet_moncon,
									 iresrea_moncon, itotexp_moncon, itotind_moncon, itotrea_moncon)
							 VALUES
									(pnsin, pfsinies, p_pago_indexado_fac, p_pago_indexado_fac, p_pfperfin, p_pproces, reg.scontra,
									 reg.nversio, vtramo, reg.ccompani, NVL(p_pct_fac, 0), NVL(p_pago_indexado_fac, 0),
									 NVL(p_pago_indexado_fac, 0), NVL(p_pago_indexado_fac, 0), NVL(p_ireserv_fac, 0),
									 NVL(p_ireserv_fac, 0), NVL(p_pct_fac, 0), NVL(p_pago_indexado_fac, 0), NVL(p_ireserv_fac, 0),
									 0, NVL(p_pago_indexado_fac, 0), NVL(p_ireserv_fac, 0), NVL(p_iresgas_tot_fac, 0),
									 NVL(p_iresindem_tot_fac, 0), NVL(p_iresinter_tot_fac, 0), NVL(p_iresadmin_tot_fac, 0),
									 f_round(NVL(p_pago_indexado_fac, 0) * p_itasa, p_cmoncontab),
									 f_round(NVL(0, 0) * p_itasa, p_cmoncontab),
									 f_round(NVL(p_pago_indexado_fac, 0) * p_itasa, p_cmoncontab),
									 f_round(NVL(p_pago_indexado_fac, 0) * p_itasa, p_cmoncontab),
									 f_round(NVL(p_pago_indexado_fac, 0) * p_itasa, p_cmoncontab),
									 f_round(NVL(p_ireserv_fac, 0) * p_itasa, p_cmoncontab),
									 f_round(NVL(p_iresgas_tot_fac, 0) * p_itasa, p_cmoncontab),
									 f_round(NVL(p_iresindem_tot_fac, 0) * p_itasa, p_cmoncontab),
									 f_round(NVL(p_iresinter_tot_fac, 0) * p_itasa, p_cmoncontab),
									 f_round(NVL(p_iresadmin_tot_fac, 0) * p_itasa, p_cmoncontab),
									 f_round(NVL(p_ireserv_fac, 0) * p_itasa, p_cmoncontab),
									 f_round(NVL(p_ireserv_fac, 0) * p_itasa, p_cmoncontab),
									 f_round(NVL(p_ireserv_fac, 0) * p_itasa, p_cmoncontab),
									 f_round(NVL(p_pago_indexado_fac, 0) * p_itasa, p_cmoncontab),
									 f_round(NVL(p_pago_indexado_fac, 0) * p_itasa, p_cmoncontab),
									 f_round(NVL(p_pago_indexado_fac, 0) * p_itasa, p_cmoncontab));
							 -- s'afegeix el Import de Reserves "Gastos" (ctipres=3)
						EXCEPTION
							 WHEN dup_val_on_index THEN
									UPDATE liquidareaxl_aux
										 SET pcuorea = pcuorea + NVL(p_pct_fac, 0), icuorea = icuorea + NVL(p_pago_indexado_fac, 0),
												 ipagrea = ipagrea + NVL(p_pago_indexado_fac, 0),
												 iliqrea = iliqrea + NVL(p_pago_indexado_fac, 0),
												 ireserv = ireserv + NVL(p_pago_indexado_fac, 0),
												 iresind = iresind + NVL(p_ireserv_fac, 0), pcuotot = pcuotot + NVL(p_pct_fac, 0),
												 itotrea = itotrea + NVL(p_pago_indexado_fac, 0),
												 iresrea = iresrea + NVL(p_ireserv_fac, 0), ilimind = ilimind + 0,
												 iliqnet = iliqnet + NVL(p_ireserv_fac, 0), iresnet = iresnet + NVL(p_ireserv_fac, 0),
												 iresgas = iresgas + NVL(p_iresgas_tot_fac, 0),
												 iresindem = iresindem + NVL(p_iresindem_tot_fac, 0),
												 iresinter = iresinter + NVL(p_iresinter_tot_fac, 0),
												 iresadmin = iresadmin + NVL(p_iresadmin_tot_fac, 0),
												 icuorea_moncon = icuorea_moncon +
																					 f_round(NVL(p_pago_indexado_fac, 0) * p_itasa, p_cmoncontab),
												 ilimind_moncon = ilimind_moncon + f_round(NVL(0, 0) * p_itasa, p_cmoncontab),
												 iliqnet_moncon = iliqnet_moncon +
																					 f_round(NVL(p_pago_indexado_fac, 0) * p_itasa, p_cmoncontab),
												 iliqrea_moncon = iliqrea_moncon +
																					 f_round(NVL(p_pago_indexado_fac, 0) * p_itasa, p_cmoncontab),
												 ipagrea_moncon = ipagrea_moncon +
																					 f_round(NVL(p_pago_indexado_fac, 0) * p_itasa, p_cmoncontab),
												 ireserv_moncon = ireserv_moncon + f_round(NVL(p_ireserv_fac, 0) * p_itasa, p_cmoncontab),
												 iresgas_moncon = iresgas_moncon +
																					 f_round(NVL(p_iresgas_tot_fac, 0) * p_itasa, p_cmoncontab),
												 iresindem_moncon = iresindem_moncon +
																						 f_round(NVL(p_iresindem_tot_fac, 0) * p_itasa, p_cmoncontab),
												 iresinter_moncon = iresinter_moncon +
																						 f_round(NVL(p_iresinter_tot_fac, 0) * p_itasa, p_cmoncontab),
												 iresadmin_moncon = iresadmin_moncon +
																						 f_round(NVL(p_iresadmin_tot_fac, 0) * p_itasa, p_cmoncontab),
												 iresind_moncon = iresind_moncon + f_round(NVL(p_ireserv_fac, 0) * p_itasa, p_cmoncontab),
												 iresnet_moncon = iresnet_moncon + f_round(NVL(p_ireserv_fac, 0) * p_itasa, p_cmoncontab),
												 iresrea_moncon = iresrea_moncon + f_round(NVL(p_ireserv_fac, 0) * p_itasa, p_cmoncontab),
												 itotexp_moncon = itotexp_moncon +
																					 f_round(NVL(p_pago_indexado_fac, 0) * p_itasa, p_cmoncontab),
												 itotind_moncon = itotind_moncon +
																					 f_round(NVL(p_pago_indexado_fac, 0) * p_itasa, p_cmoncontab),
												 itotrea_moncon = itotrea_moncon +
																					 f_round(NVL(p_pago_indexado_fac, 0) * p_itasa, p_cmoncontab)
									 WHERE nsinies = pnsin
										 AND fsinies = pfsinies
										 AND fcierre = p_pfperfin
										 AND sproces = p_pproces
										 AND scontra = reg.scontra
										 AND nversio = reg.nversio
										 AND ctramo = vtramo
										 AND ccompani = reg.ccompani;
									--JRH IMP
							 WHEN OTHERS THEN
									nerr    := 1;
									v_traza := 10;
									v_traza := 10;
									p_tab_error(f_sysdate, f_user, vobj, v_traza, 'Err INSERT INTO liquidareaxl_aux',
															'SQLERRM = ' || SQLERRM);
									RAISE;
						END;
				 END IF;
			
				 v_traza := 11;
			
				 IF NVL(p_pago_indexado_fac, 0) <> 0 THEN
						v_traza := 12;
				 
						BEGIN
							 INSERT INTO pagosreaxl_aux
									(nsinies, scontra, nversio, ctramo, ccompani, fcierre, sproces, iliqrea, cestliq,
									 iliqrea_moncon, fcambio)
							 VALUES
									(pnsin, reg.scontra, reg.nversio, vtramo, reg.ccompani, p_pfperfin, p_pproces,
									 p_pago_indexado_fac, 0, f_round(NVL(p_pago_indexado_fac, 0) * p_itasa, p_cmoncontab),
									 DECODE(p_cmultimon, 0, NULL, NVL(p_fcambio, pfsinies)));
						EXCEPTION
							 WHEN dup_val_on_index THEN
									UPDATE pagosreaxl_aux
										 SET iliqrea = iliqrea + p_pago_indexado_fac,
												 iliqrea_moncon = iliqrea_moncon +
																					 f_round(NVL(p_pago_indexado_fac, 0) * p_itasa, p_cmoncontab)
									 WHERE nsinies = pnsin
										 AND scontra = reg.scontra
										 AND nversio = reg.nversio
										 AND ctramo = vtramo
										 AND ccompani = reg.ccompani
										 AND fcierre = p_pfperfin
										 AND sproces = p_pproces;
							 WHEN OTHERS THEN
									v_traza := 14;
									p_tab_error(f_sysdate, f_user, vobj, v_traza, 'Err INSERT INTO pagosreaxl',
															' SQLERRM = ' || SQLERRM);
									nerr := 1;
									RAISE;
									--DBMS_OUTPUT.put_line('Err INSERT INTO pagosreaxl - '||SQLERRM);
							 --DBMS_OUTPUT.put_line('13. NERR:' || nerr);
						END;
				 
						-- se actualizan pagos anteriores NO LIQUIDADOS
						BEGIN
							 UPDATE pagosreaxl
									SET cestliq = 2
								WHERE scontra = reg.scontra
									AND nversio = reg.nversio
									AND ctramo = vtramo
									AND ccompani = reg.ccompani
									AND fcierre < p_pfperfin
									AND nsinies = pnsin
									AND sproces = p_pproces
									AND cestliq = 0;
						EXCEPTION
							 WHEN no_data_found THEN
									--    v_ipagrea := 0;
									p_tab_error(f_sysdate, f_user, vobj, v_traza, 'Err UPDATE pagosreaxl',
															' v_scontra =' || reg.scontra || ' v_nversio =' || reg.nversio || ' v_ctramo =' ||
															 vtramo || ' compa.ccompani=' || reg.ccompani || ' sini.nsin=' || pnsin ||
															 ' p_pfperfin =' || p_pfperfin || ' p_pproces=' || p_pproces || ' SQLERRM = ' ||
															 SQLERRM);
									RAISE;
							 WHEN OTHERS THEN
									nerr := 1;
									p_tab_error(f_sysdate, f_user, vobj, v_traza, 'Err UPDATE pagosreaxl',
															' v_scontra =' || reg.scontra || ' v_nversio =' || reg.nversio || ' v_ctramo =' ||
															 vtramo || ' compa.ccompani=' || reg.ccompani || ' sini.nsin=' || pnsin ||
															 ' p_pfperfin =' || p_pfperfin || ' p_pproces=' || p_pproces || ' SQLERRM = ' ||
															 SQLERRM);
									RAISE;
						END;
				 END IF;
			
				 --                        ELSE
				 --                           p_tab_error(f_sysdate, f_user, vobj, v_traza, 'IF nerr = 0 THEN',
				 --                                       '(4.e.iv.2.d.) (2) nerr:' || nerr);
				 IF NVL(p_pago_indexado_fac, 0) <> 0 THEN
						nerr := f_insert_movctaaux(pcempres, psseguro, pfecha, p_pago_indexado_fac, pctadet, pnsin, pfsinies,
																			 pccompapr, p_pproces, pmes_sin, panyo_sin, v_cestado, p_pfperfin, 5,
																			 reg.scontra, reg.nversio,
																			 -- Insertamos el 5 , el estado es ese
																			 vtramo, reg.ccompani, reg.sproduc, p_pago_indexado_fac, w_nnumlin
																			 --JRH IMP ?
																			 );
				 
						IF nerr <> 0 THEN
							 p_tab_error(f_sysdate, f_user, vobj, v_traza, 'Err insert movcta',
													 ' v_scontra =' || reg.scontra || ' v_nversio =' || reg.nversio || ' v_ctramo =' ||
														vtramo || ' compa.ccompani=' || reg.ccompani || ' sini.nsin=' || pnsin ||
														' p_pfperfin =' || p_pfperfin || ' SQLERRM = ' || SQLERRM);
							 RAISE no_data_found;
						END IF;
				 END IF;
			
				 IF NVL(p_ireserv_fac, 0) <> 0 THEN
						nerr := f_insert_movctaaux(pcempres, psseguro, pfecha, p_ireserv_fac, pctadet, pnsin, pfsinies,
																			 pccompapr, p_pproces, pmes_sin, panyo_sin, v_cestado, p_pfperfin, 25,
																			 reg.scontra, reg.nversio,
																			 -- Insertamos el 5 , el estado es ese
																			 vtramo, reg.ccompani, reg.sproduc, p_ireserv_fac, w_nnumlin
																			 --JRH IMP ?
																			 );
				 
						IF nerr <> 0 THEN
							 p_tab_error(f_sysdate, f_user, vobj, v_traza, 'Err insert movcta',
													 ' v_scontra =' || reg.scontra || ' v_nversio =' || reg.nversio || ' v_ctramo =' ||
														vtramo || ' compa.ccompani=' || reg.ccompani || ' sini.nsin=' || pnsin ||
														' p_pfperfin =' || p_pfperfin || ' SQLERRM = ' || SQLERRM);
							 RAISE no_data_found;
						END IF;
				 END IF;
			END LOOP;
	 
			RETURN 0;
	 EXCEPTION
			WHEN errpars THEN
				 p_tab_error(f_sysdate, f_user, vobj, v_traza, 'Error en reparto XL Facultativo parámetros:' || vpar,
										 ' SQLERRM = ' || SQLERRM);
				 RETURN - 4;
			WHEN OTHERS THEN
				 p_tab_error(f_sysdate, f_user, vobj, v_traza, 'Error en reparto XL Facultativo:' || vpar,
										 ' SQLERRM = ' || SQLERRM);
				 RETURN nerr;
	 END f_cessio_xlfacult;

	 --Fi BUG 0026444 - 27/07/2013 - JRH

	 --------------------------
	 FUNCTION f_xl_siniestros(p_pcempres IN NUMBER, p_pdefi IN NUMBER, p_pipc IN NUMBER, p_pmes IN NUMBER,
														p_pany IN NUMBER, p_pfcierre IN DATE, p_pproces IN NUMBER, p_pscesrea OUT NUMBER,
														p_pfperini IN DATE, p_pfperfin IN DATE, o_plsql OUT VARCHAR2) RETURN NUMBER IS
			CURSOR c_sinies(p_fechacorte IN DATE) IS
				 SELECT cempres, ccompapr, sproduc, nsin, fsin, fnot, sseg, nrie, mes_sin, anyo_sin, ncua, cramo,
								SUM(isinpag) pagos, SUM(ireserva) reservas
					 FROM (
									-- Cursor sobre els sinistres amb pagaments
									SELECT DISTINCT s.cempres, s.ccompani ccompapr, s.sproduc, si.nsinies nsin, si.fsinies fsin,
																	 si.fnotifi fnot, si.sseguro sseg, si.nriesgo nrie,
																	 TO_CHAR(si.fsinies, 'mm') mes_sin, TO_CHAR(si.fsinies, 'yyyy') anyo_sin,
																	 si.ncuacoa ncua, s.cramo cramo,
																	 SUM(DECODE(ps.ctippag, 8, NVL(pg.isinretpag, 0), 2, NVL(pg.isinretpag, 0),
																							 NVL(-pg.isinretpag, 0))) isinpag, 0 ireserva
										FROM sin_tramita_pago ps, sin_siniestro si, sin_tramita_pago_gar pg, seguros s, garanpro gp
									 WHERE ps.nsinies = si.nsinies
										 AND si.sseguro = s.sseguro
										 AND EXISTS (SELECT 1 FROM cesionesrea cr WHERE cr.sseguro = s.sseguro)
										 AND ps.sidepag = pg.sidepag
										 AND EXISTS (SELECT 1
														FROM sin_tramita_movpago pm
													 WHERE pm.sidepag = ps.sidepag
														 AND pm.nmovpag = (SELECT MAX(pm2.nmovpag)
																								 FROM sin_tramita_movpago pm2
																								WHERE pm2.sidepag = pm.sidepag
                                                                                                    -- INFORCOL INICIO 30-12-2019 Ajuste para reaseguro no proporcional
																									AND TRUNC(pm2.fefepag) <= p_fechacorte
                                                                                                    -- INFORCOL FIN 30-12-2019 Ajuste para reaseguro no proporcional
																									AND pm2.cestpag IN (NVL(pac_parametros.f_parempresa_n(p_pcempres,
																																																				'EDO_PAGO_PROCESA_REA'),
																																					2))))
												-- No Anulaciones
										 AND NOT EXISTS (SELECT 1
														FROM sin_tramita_movpago pm2
													 WHERE pm2.sidepag = ps.sidepag
														 AND pm2.cestpag = 8
                                                         -- INFORCOL INICIO 30-12-2019 Ajuste para reaseguro no proporcional
														 AND TRUNC(pm2.fefepag) <= p_fechacorte)
                                                         -- INFORCOL FIN 30-12-2019 Ajuste para reaseguro no proporcional
												--
                                         -- INFORCOL INICIO 30-12-2019 Ajuste para reaseguro no proporcional
										 AND TRUNC(si.falta) <= p_fechacorte
                                         -- INFORCOL FIN 30-12-2019 Ajuste para reaseguro no proporcional
										 AND si.cevento IS NULL
										 AND cempres = p_pcempres
										 AND NOT EXISTS (SELECT 1 FROM reariesgos rr WHERE rr.sseguro = s.sseguro)
												---
										 AND gp.sproduc = s.sproduc
										 AND gp.cgarant = pg.cgarant
										 AND gp.cactivi = NVL(s.cactivi, 0)
										 AND gp.creaseg IN (1, 2)
									 GROUP BY s.cempres, s.ccompani, s.sproduc, si.nsinies, si.fsinies, si.fnotifi, si.sseguro,
														 si.nriesgo, TO_CHAR(si.fsinies, 'mm'), TO_CHAR(si.fsinies, 'yyyy'), si.ncuacoa, s.cramo
									UNION ALL -- Cursor sobre els sinistres amb reserves i sense pagaments
									SELECT DISTINCT s.cempres, s.ccompani ccompapr, s.sproduc, si.nsinies nsin, si.fsinies fsin,
																	 si.fnotifi fnot, si.sseguro sseg, si.nriesgo nrie,
																	 TO_CHAR(si.fsinies, 'mm') mes_sin, TO_CHAR(si.fsinies, 'yyyy') anyo_sin,
																	 si.ncuacoa ncua, s.cramo cramo, 0 isinpag,
																	 NVL(sr.ireserva_moncia, 0) + (CASE
																																		 WHEN NVL(sr.ipago_moncia, 0) < 0 THEN
																																			0
																																		 ELSE
																																			NVL(sr.ipago_moncia, 0)
																																	END) ireserva
										FROM sin_siniestro si, seguros s, sin_tramita_reserva sr, agr_contratos ag, garanpro gp
									 WHERE si.sseguro = s.sseguro
										 AND EXISTS (SELECT 1 FROM cesionesrea cr WHERE cr.sseguro = s.sseguro)
                                         -- INFORCOL INICIO 23-12-2019 Ajuste para reaseguro no proporcional
										 AND trunc(si.falta) <= p_fechacorte
                                         -- INFORCOL FIN 23-12-2019
										 AND cempres = p_pcempres
										 AND ag.cramo = s.cramo
										 AND si.nsinies = sr.nsinies
										 AND si.cevento IS NULL
										 AND (NVL(ipago, 0) = 0 OR
												 sr.sidepag IN
												 (SELECT sidepag
														 FROM sin_tramita_movpago stm
														WHERE stm.sidepag = sr.sidepag
															AND stm.cestpag IN (0, 1, 8,
																									DECODE(NVL(pac_parametros.f_parempresa_n(p_pcempres,
																																														'EDO_PAGO_PROCESA_REA'),
																															2), 2, 9, 0))
															AND stm.nmovpag IN (SELECT MAX(nmovpag)
																										FROM sin_tramita_movpago stm2
																									 WHERE stm.sidepag = stm2.sidepag
                                                                                                         -- INFORCOL INICIO 30-12-2019 Ajuste para reaseguro no proporcional
																										 AND TRUNC(stm2.fefepag) <= p_fechacorte)))
                                                                                                         -- INFORCOL FIN 30-12-2019 Ajuste para reaseguro no proporcional
										 AND sr.nmovres IN (SELECT MAX(nmovres)
																					FROM sin_tramita_reserva ss
																				 WHERE ss.nsinies = sr.nsinies
																					 AND sr.ntramit = ss.ntramit
																					 AND ss.ctipres = sr.ctipres
																					 AND ss.cgarant = sr.cgarant
																					 AND ss.sidepag = sr.sidepag
																					 AND NVL(ss.ctipgas, 0) = NVL(sr.ctipgas, 0)
                                                                                     -- INFORCOL INICIO 23-12-2019 Ajuste para reaseguro no proporcional
																					 AND trunc(ss.fmovres) <= p_fechacorte
                                                                                     -- INFORCOL FIN 23-12-2019
																				UNION
																				SELECT MAX(nmovres)
																					FROM sin_tramita_reserva ss
																				 WHERE ss.nsinies = sr.nsinies
																					 AND sr.ntramit = ss.ntramit
																					 AND ss.ctipres = sr.ctipres
																					 AND ss.cgarant = sr.cgarant
																					 AND NVL(ss.ctipgas, 0) = NVL(sr.ctipgas, 0)
                                                                                     -- INFORCOL INICIO 23-12-2019 Ajuste para reaseguro no proporcional
																					 AND trunc(ss.fmovres) <= p_fechacorte)
                                                                                     -- INFORCOL FIN 23-12-2019
										 AND NOT EXISTS (SELECT 1 FROM reariesgos rr WHERE rr.sseguro = s.sseguro)
												------
												--KBR 26/06/2014 Solo garantias reasegurables
										 AND gp.sproduc = s.sproduc
										 AND gp.cgarant = sr.cgarant
										 AND gp.cactivi = NVL(s.cactivi, 0)
										 AND gp.creaseg IN (1, 2)
									 GROUP BY s.cempres, s.ccompani, s.sproduc, si.nsinies, si.fsinies, si.fnotifi, si.sseguro,
														 si.nriesgo, TO_CHAR(si.fsinies, 'mm'), TO_CHAR(si.fsinies, 'yyyy'), si.ncuacoa, s.cramo,
														 NVL(sr.ireserva_moncia, 0) + (CASE
																															 WHEN NVL(sr.ipago_moncia, 0) < 0 THEN
																																0
																															 ELSE
																																NVL(sr.ipago_moncia, 0)
																														END))
					GROUP BY cempres, ccompapr, sproduc, nsin, fsin, fnot, sseg, nrie, mes_sin, anyo_sin, ncua, cramo
					ORDER BY nsin;
	 
			CURSOR c_sinies_tot(sini VARCHAR2, p_fechacorte IN DATE) IS
				 SELECT DISTINCT s.sproduc, si.nsinies nsin, si.fsinies fsin, si.fnotifi fnot, sr.ctipres,
												 si.sseguro sseg, si.nriesgo nrie, TO_CHAR(si.fsinies, 'mm') mes_sin,
												 TO_CHAR(si.fsinies, 'yyyy') anyo_sin, si.ncuacoa ncua, sr.cgarant cgar, s.cramo cramo,
												 ps.ctippag, 0 ireserva, NVL(sr.ipago_moncia, 0) isinpag,
												 NVL(sr.irecobro_moncia, 0) isinrecob
					 FROM sin_tramita_pago ps, sin_siniestro si, seguros s, sin_tramita_reserva sr, garanpro gp
					WHERE ps.nsinies = si.nsinies
						AND si.nsinies = sini
						AND si.sseguro = s.sseguro
						AND ps.sidepag = sr.sidepag
                        -- INFORCOL INICIO 23-12-2019 Ajuste para reaseguro no proporcional
						AND trunc(ps.falta) <= p_fechacorte
                        -- INFORCOL FIN 23-12-2019
                        -- INFORCOL INICIO 30-12-2019 Ajuste para reaseguro no proporcional
						AND TRUNC(si.falta) <= p_fechacorte
                        -- INFORCOL FIN 30-12-2019 Ajuste para reaseguro no proporcional
						AND cempres = p_pcempres
						AND si.nsinies = sr.nsinies
						AND ps.ntramit = sr.ntramit
                        -- INFORCOL INICIO 30-12-2019 Ajuste para reaseguro no proporcional
						AND TRUNC(sr.fmovres) <= p_fechacorte
                        -- INFORCOL FIN 30-12-2019 Ajuste para reaseguro no proporcional
						AND gp.sproduc = s.sproduc
						AND gp.cgarant = sr.cgarant
						AND gp.cactivi = NVL(s.cactivi, 0)
						AND gp.creaseg IN (1, 2)
						AND sr.ipago <> 0
						AND EXISTS (SELECT 1
									 FROM sin_tramita_movpago pm2
									WHERE pm2.sidepag = sr.sidepag
										AND pm2.nmovpag = (SELECT MAX(pm3.nmovpag)
																				 FROM sin_tramita_movpago pm3
																				WHERE pm3.sidepag = sr.sidepag
                                                                                    -- INFORCOL INICIO 23-12-2019 Ajuste para reaseguro no proporcional
																					AND trunc(pm3.fefepag) <= p_fechacorte
                                                                                    -- INFORCOL FIN 23-12-2019
																					AND pm3.cestpag IN (NVL(pac_parametros.f_parempresa_n(p_pcempres,
																																																'EDO_PAGO_PROCESA_REA'),
																																	2))))
							 -- No Anulaciones
						AND NOT EXISTS (SELECT 1
									 FROM sin_tramita_movpago pm2
									WHERE pm2.sidepag = sr.sidepag
										AND pm2.cestpag = 8
                                        -- INFORCOL INICIO 23-12-2019 Ajuste para reaseguro no proporcional
										AND trunc(pm2.fefepag) <= p_fechacorte)
                                        -- INFORCOL FIN 23-12-2019
							 --
						AND sr.nmovres IN (SELECT MAX(nmovres)
																 FROM sin_tramita_reserva ss
																WHERE ss.nsinies = sr.nsinies
																	AND sr.ntramit = ss.ntramit
																	AND ss.ctipres = sr.ctipres
																	AND ss.cgarant = sr.cgarant
																	AND ss.sidepag IS NOT NULL
																	AND NVL(ss.ctipgas, 0) = NVL(sr.ctipgas, 0)
                                                                    -- INFORCOL INICIO 30-12-2019 Ajuste para reaseguro no proporcional
																	AND trunc(ss.fmovres) <= p_fechacorte)
                                                                    -- INFORCOL FIN 30-12-2019 Ajuste para reaseguro no proporcional
				 --
					GROUP BY s.sproduc, si.nsinies, si.fsinies, si.fnotifi, sr.ctipres, si.sseguro, si.nriesgo,
									 TO_CHAR(si.fsinies, 'mm'), TO_CHAR(si.fsinies, 'yyyy'), si.ncuacoa, sr.cgarant, s.cramo,
									 ps.ctippag, NVL(sr.ireserva_moncia, 0), NVL(sr.ipago_moncia, 0), NVL(sr.irecobro_moncia, 0)
				 HAVING NVL(sr.ipago_moncia, 0) <> 0
				 UNION ALL
				 SELECT DISTINCT s.sproduc, si.nsinies nsin, si.fsinies fsin, si.fnotifi fnot, sr.ctipres,
												 si.sseguro sseg, si.nriesgo nrie, TO_CHAR(si.fsinies, 'mm') mes_sin,
												 TO_CHAR(si.fsinies, 'yyyy') anyo_sin, si.ncuacoa ncua, sr.cgarant cgar, s.cramo cramo,
												 0 ctippag,
												 SUM(NVL(sr.ireserva_moncia, 0) +
															NVL((SELECT sr2.ipago_moncia
																		FROM sin_tramita_reserva sr2
																	 WHERE sr2.nsinies = sr.nsinies
																		 AND sr2.ntramit = sr.ntramit
																		 AND sr2.ctipres = sr.ctipres
																		 AND sr2.cgarant = sr.cgarant
																		 AND NVL(sr2.ctipgas, 0) = NVL(sr.ctipgas, 0)
                                                                         -- INFORCOL INICIO 30-12-2019 Ajuste para reaseguro no proporcional
																		 AND TRUNC(sr2.fmovres) <= p_fechacorte
                                                                         -- INFORCOL FIN 30-12-2019 Ajuste para reaseguro no proporcional
																		 AND sr2.ipago <> 0
																		 AND sr2.nmovres = sr.nmovres
																		 AND EXISTS
																	 (SELECT 1
																						FROM sin_tramita_movpago mp
																					 WHERE mp.sidepag = sr2.sidepag
																						 AND mp.cestpag IN (0, 1, 8)
																						 AND mp.nmovpag = (SELECT MAX(mp2.nmovpag)
																																 FROM sin_tramita_movpago mp2
																																WHERE mp2.sidepag = mp.sidepag
                                                                                                                                    -- INFORCOL INICIO 30-12-2019 Ajuste para reaseguro no proporcional
																																	AND TRUNC(mp2.fefepag) <= p_fechacorte))), 0)) ireserva,
                                                                                                                                    -- INFORCOL FIN 30-12-2019 Ajuste para reaseguro no proporcional
												 0 isinpag, 0 isinrecob
					 FROM sin_siniestro si, seguros s, sin_tramita_reserva sr, garanpro gp
					WHERE si.sseguro = s.sseguro
						AND si.nsinies = sini
                        -- INFORCOL INICIO 30-12-2019 Ajuste para reaseguro no proporcional
						AND TRUNC(si.falta) <= p_fechacorte
                        -- INFORCOL FIN 30-12-2019 Ajuste para reaseguro no proporcional
						AND cempres = p_pcempres
						AND si.nsinies = sr.nsinies
						AND gp.sproduc = s.sproduc
						AND gp.cgarant = sr.cgarant
						AND gp.cactivi = NVL(s.cactivi, 0)
						AND gp.creaseg IN (1, 2)
                        -- INFORCOL INICIO 30-12-2019 Ajuste para reaseguro no proporcional
						AND TRUNC(sr.fmovres) <= p_fechacorte
                        -- INFORCOL FIN 30-12-2019 Ajuste para reaseguro no proporcional
						AND sr.nmovres IN (SELECT MAX(nmovres)
																 FROM sin_tramita_reserva ss
																WHERE ss.nsinies = sr.nsinies
																	AND sr.ntramit = ss.ntramit
																	AND ss.ctipres = sr.ctipres
																	AND ss.cgarant = sr.cgarant
																	AND NVL(ss.ctipgas, 0) = NVL(sr.ctipgas, 0)
                                                                    -- INFORCOL INICIO 30-12-2019 Ajuste para reaseguro no proporcional
																	AND TRUNC(ss.fmovres) <= p_fechacorte)
                                                                    -- INFORCOL FIN 30-12-2019 Ajuste para reaseguro no proporcional
					GROUP BY s.sproduc, si.nsinies, si.fsinies, si.fnotifi, sr.ctipres, si.sseguro, si.nriesgo,
									 TO_CHAR(si.fsinies, 'mm'), TO_CHAR(si.fsinies, 'yyyy'), si.ncuacoa, sr.cgarant, s.cramo,
									 sr.nmovres
				 HAVING SUM(NVL(sr.ireserva_moncia, 0) + NVL((SELECT sr2.ipago_moncia
																												FROM sin_tramita_reserva sr2
																											 WHERE sr2.nsinies = sr.nsinies
																												 AND sr2.ntramit = sr.ntramit
																												 AND sr2.ctipres = sr.ctipres
																												 AND sr2.cgarant = sr.cgarant
																												 AND NVL(sr2.ctipgas, 0) = NVL(sr.ctipgas, 0)
                                                                                                                 -- INFORCOL INICIO 30-12-2019 Ajuste para reaseguro no proporcional
																												 AND TRUNC(sr2.fmovres) <= p_fechacorte
                                                                                                                 -- INFORCOL FIN 30-12-2019 Ajuste para reaseguro no proporcional
																												 AND sr2.ipago <> 0
																												 AND sr2.nmovres = sr.nmovres
																												 AND EXISTS
																											 (SELECT 1
																																FROM sin_tramita_movpago mp
																															 WHERE mp.sidepag = sr2.sidepag
																																 AND mp.cestpag IN (0, 1, 8)
																																 AND mp.nmovpag =
																																		 (SELECT MAX(mp2.nmovpag)
																																				FROM sin_tramita_movpago mp2
																																			 WHERE mp2.sidepag = mp.sidepag
                                                                                                                                                 -- INFORCOL INICIO 30-12-2019 Ajuste para reaseguro no proporcional
																																				 AND TRUNC(mp2.fefepag) <= p_fechacorte))), 0)) <> 0
                                                                                                                                                 -- INFORCOL FIN 30-12-2019 Ajuste para reaseguro no proporcional
					ORDER BY nsin, cgar;
	 
			CURSOR c_cuadroces_agr(ctr NUMBER, ver NUMBER, tram NUMBER) IS
				 SELECT c.ccompani, c.ctramo, c.iagrega, c.imaxagr, c.pcesion, ct.fconini, 0 iminagr, ccorred
					 FROM cuadroces c, contratos ct
					WHERE c.scontra = ct.scontra
						AND c.nversio = ct.nversio
						AND c.scontra = ctr
						AND c.nversio = ver
						AND c.ctramo = tram
						AND pac_reaseguro_rec.f_compania_cutoff(c.ccompani, TRUNC(SYSDATE)) = 0; --CONF-910
	 
			vobj                VARCHAR2(200) := 'PAC_REASEGURO_XL.f_xl_siniestros';
			nerr                NUMBER := 0;
			pnnumlin            NUMBER;
			texto               VARCHAR2(200);
			num_impliq          NUMBER;
			v_scontra           contratos.scontra%TYPE;
			v_nversio           contratos.nversio%TYPE;
			v_ctramo            tramos.ctramo%TYPE;
			v_ipleno            contratos.iretenc%TYPE;
			v_icapaci           contratos.icapaci%TYPE;
			v_iprioxl           contratos.iprioxl%TYPE;
			v_iprioxl_ctto      contratos.iprioxl%TYPE;
			v_iprioxl_tramo     contratos.iprioxl%TYPE;
			v_caplixl           tramos.caplixl%TYPE;
			v_imaxagr           NUMBER;
			v_iminagr           NUMBER;
			v_plimgas           tramos.plimgas%TYPE;
			v_hay               NUMBER;
			v_pliminx           NUMBER;
			v_ipagrea_tot       NUMBER := 0;
			v_pagosanteriores   NUMBER;
			v_ipc               NUMBER(8, 5);
			v_ipc_fecha_base    NUMBER(8, 5);
			v_ipc_fecha_pago    NUMBER(8, 5);
			v_pago_indexado     liquidareaxl_aux.itotind%TYPE;
			v_pago_no_indexado  liquidareaxl_aux.itotexp%TYPE;
			v_pago_xl           NUMBER(15, 2);
			v_ireserv           liquidareaxl_aux.ireserv%TYPE := 0;
			v_pcuorea           liquidareaxl_aux.pcuorea%TYPE;
			v_icuorea           liquidareaxl_aux.icuorea%TYPE;
			v_iliqrea           liquidareaxl_aux.iliqrea%TYPE;
			v_iliqrea_cia       movctaaux.iimport%TYPE;
			v_iresind           liquidareaxl_aux.iresind%TYPE;
			v_pcuotot           liquidareaxl_aux.pcuotot%TYPE;
			v_itotrea           liquidareaxl_aux.itotrea%TYPE;
			v_iresrea           liquidareaxl_aux.iresrea%TYPE;
			v_iresrea_cia       movctaaux.iimport%TYPE;
			v_ilimind           liquidareaxl_aux.ilimind%TYPE;
			v_iliqrea_pag       liquidareaxl_aux.iliqnet%TYPE;
			v_iliqrea_pag_cia   NUMBER;
			v_iliqrea_cum       cuadroces.iagrega%TYPE := 0;
			v_iliqrea_lim       pagosreaxl_aux.iliqrea%TYPE := 0;
			v_iresnet           liquidareaxl_aux.iresnet%TYPE := 0;
			w_nnumlin           NUMBER;
			v_numero            NUMBER;
			v_cestado           NUMBER;
			v_mes_base          NUMBER;
			v_ano_base          NUMBER;
			v_supera            NUMBER;
			v_iliqrea_tot_cia   NUMBER;
			v_pcesion_act       NUMBER;
			v_pcesion_ini       NUMBER;
			ptipo               VARCHAR2(2);
			v_diferencia        NUMBER := 0;
			v_diferencia_min    NUMBER := 0;
			v_traza             NUMBER;
			v_entro             NUMBER := 0;
			v_cdetces           NUMBER;
			v_cmultimon         parempresas.nvalpar%TYPE := NVL(pac_parametros.f_parempresa_n(p_pcempres, 'MULTIMONEDA'),
																													0);
			v_cmoncontab        parempresas.nvalpar%TYPE := pac_parametros.f_parempresa_n(p_pcempres, 'MONEDACONTAB');
			v_itasa             eco_tipocambio.itasa%TYPE;
			v_fcambio           DATE;
			v_iresgas_tot       liquidareaxl_aux.iresgas%TYPE;
			v_iresgas           liquidareaxl_aux.iresgas%TYPE;
			v_iresindem_tot     liquidareaxl_aux.iresindem%TYPE;
			v_iresindem         liquidareaxl_aux.iresindem%TYPE;
			v_iresinter_tot     liquidareaxl_aux.iresinter%TYPE;
			v_iresinter         liquidareaxl_aux.iresinter%TYPE;
			v_iresadmin_tot     liquidareaxl_aux.iresadmin%TYPE;
			v_iresadmin         liquidareaxl_aux.iresadmin%TYPE;
			v_hiha_cessio       NUMBER(1);
			v_plocal            NUMBER;
			v_cconcep           NUMBER(2);
			w_ctadet            NUMBER(1);
			w_cconcep           movctaaux.cconcep%TYPE;
			w_cdebhab           movctaaux.cdebhab%TYPE;
			v_cmodali           seguros.cmodali%TYPE;
			v_ctipseg           seguros.ctipseg%TYPE;
			v_ccolect           seguros.ccolect%TYPE;
			v_cactivi           seguros.cactivi%TYPE;
			v_diferencia_fac    NUMBER;
			v_facultativo_fac   NUMBER;
			v_pago_indexado_fac NUMBER;
			v_ireserv_fac       NUMBER;
			v_desglose_reserva  NUMBER;
			v_iresgas_tot_fac   NUMBER;
			v_iresindem_tot_fac NUMBER;
			v_iresinter_tot_fac NUMBER;
			v_iresadmin_tot_fac NUMBER;
			v_c_gar             NUMBER;
			v_pct_fac           NUMBER;
			v_pago_indexado_ant NUMBER;
			v_ireserv_ant       NUMBER;
			v_iresgas_tot_ant   NUMBER := 0;
			v_iresindem_tot_ant NUMBER := 0;
			v_iresinter_tot_ant NUMBER := 0;
			v_iresadmin_tot_ant NUMBER := 0;
			v_res_dist          NUMBER;
			v_pag_dist          NUMBER;
			v_reserva_mat       NUMBER := 0;
			v_moneda_prod       productos.cdivisa%TYPE;
			v_itasa_prod        eco_tipocambio.itasa%TYPE;
			v_fcambio_prod      DATE;
			v_mov_res           NUMBER;
			v_mov_pag           NUMBER;
			v_nom_paquete       VARCHAR2(80) := 'PAC_REASEGURO_XL';
			v_nom_funcion       VARCHAR2(80) := 'F_XL_SINIESTROS';
			v_reserva_anterior  NUMBER := 0;
			v_pagos_anterior    NUMBER := 0;
			v_iresrea_mov       NUMBER := 0;
			v_ipagrea_mov       NUMBER := 0;
			v_fmaxcierre        DATE;
			v_fechacorte        DATE;
			v_totrea            NUMBER; --KBR 25/07/2014
			v_totalreserv_ret   NUMBER; --KBR 25/07/2014
			v_totalpagos_ret    NUMBER; --KBR 25/07/2014
			v_ixlprio_ant       NUMBER; --KBR 25/07/2014
			v_itottra           NUMBER; --KBR 25/07/2014
			v_crepos            NUMBER; --KBR 25/07/2014
			v_nro_repos         NUMBER; --KBR 25/07/2014
			v_primareest        NUMBER; --KBR 25/07/2014
			v_primareest_sin    NUMBER;
			v_ipmd              NUMBER; --KBR 25/07/2014
			inicio              NUMBER; --KBR 25/07/2014
			v_preest            NUMBER; --KBR 25/07/2014
			v_ixlprio           NUMBER; --KBR 25/07/2014
			v_ixlcapaci         NUMBER; --KBR 25/07/2014
			v_temp_pagos_ret    NUMBER; --KBR 25/07/2014
			v_reserva_ret       NUMBER; --KBR 25/07/2014
	 BEGIN
			v_traza := 1;
			-- Comptes a nivell de sinistres
			v_fechacorte := p_pfcierre; -- KBR 27/11/2014 Cambiamos por fecha de cierre
			p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL, 3473,
											'Inicio de proceso. Params de entrada: p_pcempres-' || p_pcempres || ' p_pdefi-' ||
											 p_pdefi || ' p_pipc-' || p_pipc || ' p_pmes-' || p_pmes || ' p_pany-' || p_pany ||
											 ' p_pfcierre-' || p_pfcierre || ' p_pproces-' || p_pproces || ' p_pfperini-' || p_pfperini ||
											 ' p_pfperfin-' || p_pfperfin || ' v_fechacorte-' || v_fechacorte);
			w_ctadet := pac_parametros.f_parempresa_n(p_pcempres, 'CTACES_DET');
	 
			----------------------------------------------------------------------------
			--     1. inicializamos el IAGREAGA de cuadroces para todas las compañias --
			----------------------------------------------------------------------------
			BEGIN
				 UPDATE cuadroces
						SET iagrega = 0
					WHERE scontra IN (SELECT scontra FROM codicontratos WHERE ctiprea = 3);
			EXCEPTION
				 WHEN OTHERS THEN
						nerr := 1;
						p_tab_error(f_sysdate, f_user, vobj, v_traza, 'Err UPDATE cuadroces', ' SQLERRM = ' || SQLERRM);
			END;
	 
			FOR sini IN c_sinies(v_fechacorte) LOOP
				 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL, 3494,
												 'Evaluando siniestro: ' || sini.nsin);
				 -- INICIALIZAR IMPORTES POR EXPDTE:
				 v_pagosanteriores   := 0;
				 v_pago_xl           := 0;
				 v_ipc_fecha_base    := 0;
				 v_ipc_fecha_pago    := 0;
				 v_pago_indexado     := 0;
				 v_pago_no_indexado  := 0;
				 v_iprioxl           := 0;
				 v_iprioxl_ctto      := 0;
				 v_iprioxl_tramo     := 0;
				 v_ilimind           := 0;
				 v_iresgas_tot       := 0;
				 v_iresgas           := 0;
				 v_iresrea           := 0;
				 v_ireserv           := 0;
				 v_iresindem_tot     := 0;
				 v_iresindem         := 0;
				 v_iresinter_tot     := 0;
				 v_iresinter         := 0;
				 v_iresadmin_tot     := 0;
				 v_iresadmin         := 0;
				 v_diferencia_fac    := 0;
				 v_facultativo_fac   := 0;
				 v_pago_indexado_fac := 0;
				 v_ireserv_fac       := 0;
				 v_desglose_reserva  := 0;
				 v_iresgas_tot_fac   := 0;
				 v_iresindem_tot_fac := 0;
				 v_iresinter_tot_fac := 0;
				 v_iresadmin_tot_fac := 0;
				 v_c_gar             := 0;
				 v_pct_fac           := 0;
				 v_pago_indexado_ant := 0;
				 v_ireserv_ant       := 0;
				 v_iresgas_tot_ant   := 0;
				 v_iresindem_tot_ant := 0;
				 v_iresinter_tot_ant := 0;
				 v_iresadmin_tot_ant := 0;
				 v_res_dist          := 0;
				 v_pag_dist          := 0;
				 v_totrea            := 0; --KBR 25/07/2014
				 ------------------------------------------------------------------------------------------------
				 -- Buscamos si ya se han realizado cesiones para este siniestro                               --
				 -- Si hay importes de liquidación (PAGOSREAXL) se superó la prioridad                         --
				 -- Se recoje el SCONTRA y NVERSIO (AVT: y controlamos si existen o no datos al mismo tiempo)  --
				 ------------------------------------------------------------------------------------------------
				 v_traza := 2;
			
				 /*KBR 04/06/2014 : Agregamos que el filtro de fechas que sea por FPROCES de la tabla CIERRES*/
				 BEGIN
						SELECT MAX(fcierre) --MAX(fproces) --BUG 36059 - Cambiamos la fecha de fproces por la fcierre.- DCT - 08/10/2015
							INTO v_fmaxcierre
							FROM cierres
						 WHERE ctipo = 15 --Cierre XL (VF: 167)
							 AND cempres = p_pcempres
							 AND cestado = 1 --Finalizado
							 AND fperfin < p_pfperini;
				 EXCEPTION
						WHEN no_data_found THEN
							 v_fmaxcierre := p_pfperini;
				 END;
			
				 BEGIN
						SELECT DISTINCT 1
							INTO v_mov_res
							FROM sin_tramita_reserva sr, sin_siniestro ss, garanpro gp, seguros sg
						 WHERE sr.nsinies = sini.nsin
							 AND sr.fmovres > v_fmaxcierre
                             -- INFORCOL INICIO 23-12-2019 Ajuste para reaseguro no proporcional
							 AND trunc(sr.fmovres) <= v_fechacorte
                             -- INFORCOL FIN 23-12-2019
									----
									--KBR 26/06/2014 Solo garantias reasegurables
							 AND ss.nsinies = sr.nsinies
							 AND sg.sseguro = ss.sseguro
							 AND EXISTS (SELECT 1 FROM cesionesrea cr WHERE cr.sseguro = sg.sseguro)
							 AND gp.sproduc = sg.sproduc
							 AND gp.cgarant = sr.cgarant
							 AND gp.cactivi = NVL(sg.cactivi, 0)
							 AND gp.creaseg IN (1, 2);
				 EXCEPTION
						WHEN no_data_found THEN
							 v_mov_res := 0;
						WHEN OTHERS THEN
							 v_mov_res := 0;
				 END;
			
				 BEGIN
						SELECT DISTINCT 1
							INTO v_mov_pag
							FROM sin_tramita_pago sp, sin_tramita_reserva sr, sin_siniestro ss, seguros sg, garanpro gp
						 WHERE sp.nsinies = sini.nsin
							 AND sp.falta > v_fmaxcierre
							 AND sp.falta <= v_fechacorte
									----
									--KBR 26/06/2014 Solo garantias reasegurables
							 AND sr.sidepag = sp.sidepag
							 AND sr.nsinies = sp.nsinies
							 AND ss.nsinies = sr.nsinies
							 AND sg.sseguro = ss.sseguro
							 AND EXISTS (SELECT 1 FROM cesionesrea cr WHERE cr.sseguro = sg.sseguro)
							 AND gp.sproduc = sg.sproduc
							 AND gp.cgarant = sr.cgarant
							 AND gp.cactivi = NVL(sg.cactivi, 0)
							 AND gp.creaseg IN (1, 2);
				 EXCEPTION
						WHEN no_data_found THEN
							 v_mov_pag := 0;
						WHEN OTHERS THEN
							 v_mov_pag := 0;
				 END;
			
				 /*KBR 04/06/2014 : Agregamos que el filtro de fechas sea por FCONTAB y debe estar ligado al cierre de SINIESTROS (Existir dependencia)*/
				 IF v_mov_pag <> 0 OR v_mov_res <> 0 THEN
						p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL, 3573,
														'Siniestro con movimientos para el mes');
				 
						--KBR Cambio 14/10/2014
						---------------------------------------------------------------------------------------------------------                                                                          --
						-- Para cada Siniestro se busca el SCONTRA, NVERSIO que le corresponde a partir de la F_BUSCACONTRATO. --
						---------------------------------------------------------------------------------------------------------
						BEGIN
							 SELECT cmodali, ctipseg, ccolect, cactivi
								 INTO v_cmodali, v_ctipseg, v_ccolect, v_cactivi
								 FROM seguros
								WHERE sseguro = sini.sseg;
						EXCEPTION
							 WHEN no_data_found THEN
									v_cmodali := NULL;
									v_ctipseg := NULL;
									v_ccolect := NULL;
									v_cactivi := NULL;
							 WHEN OTHERS THEN
									nerr := 1;
									p_tab_error(f_sysdate, f_user, vobj, v_traza, 'Err select seguros',
															'SSEGURO =' || sini.sseg || ' SQLERRM = ' || SQLERRM);
						END;
				 
						--KBR Cambio 14/10/2014
						nerr := f_buscacontrato(sini.sseg, sini.fsin, p_pcempres, NULL, sini.cramo, v_cmodali, v_ctipseg,
																		v_ccolect, v_cactivi, 11, v_scontra, v_nversio, v_ipleno, v_icapaci, v_cdetces);
						p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL, 3620,
														'Contrato/Version: ' || v_scontra || '/' || v_nversio);
				 
						IF nerr = 0 THEN
							 --(4.e.iii.) Comprobamos que no estamos superando el límite
							 --(4.e.iii.1.) Calculamos el importe de pago que se cede al XL.
							 --EL IMPORTE Q SUPERA LA PRIORIDAD Y ESTÁ POR DEBAJO DEL SUPERIOR.
							 --ENTRE IPRIOXL Y IXLPRIO
							 FOR sini2 IN c_sinies_tot(sini.nsin, v_fechacorte) LOOP
									p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL, 3728,
																	'Evaluamos garantía: ' || sini2.cgar);
									v_c_gar := sini2.cgar;
							 
									DECLARE
										 v_ctipcoa seguros.ctipcoa%TYPE;
										 v_ploccoa coacuadro.ploccoa%TYPE;
									BEGIN
										 SELECT NVL(ctipcoa, 0) INTO v_ctipcoa FROM seguros WHERE sseguro = sini2.sseg;
									
										 IF v_ctipcoa IN (1, 2) THEN
												-- cedido
												SELECT MAX(ploccoa)
													INTO v_ploccoa
													FROM coacuadro
												 WHERE ncuacoa = sini2.ncua
													 AND sseguro = sini2.sseg;
										 
												IF v_ploccoa IS NOT NULL THEN
													 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL,
																					 3751, '% Coa Cedido: ' || v_ploccoa || ' para Seguro: ' || sini2.sseg);
													 -- Si tiene porcentaje, modificamos el importe.
													 sini2.isinpag  := sini2.isinpag * v_ploccoa / 100;
													 sini2.ireserva := sini2.ireserva * v_ploccoa / 100;
												END IF;
										 END IF;
										 -- si es aceptado, no modificamos el importe.
									END;
							 
									--%LOCAL
									v_plocal := 0;
							 
									IF NVL(pac_parametros.f_parempresa_n(p_pcempres, 'XL_PROTEC_PROPI'), 0) = 1 THEN
										 v_hiha_cessio := 0;
									
										 FOR f1 IN (SELECT DISTINCT scontra, nversio, ctramo, SUM(pcesion) pcesion --CONF-910
																	FROM cesionesrea
																 WHERE nsinies = sini.nsin
																	 AND ctramo IN (0, 1)
																 GROUP BY scontra, nversio, ctramo) LOOP
												v_hiha_cessio := 1;
										 
												IF f1.ctramo = 0 THEN
													 v_plocal := f1.pcesion;
												ELSIF NVL(pac_parametros.f_parempresa_n(p_pcempres, 'INFORMA_FECHA_FIN'), 0) = 0 THEN
													 --CONF-910
													 BEGIN
															SELECT plocal
																INTO v_plocal
																FROM tramos
															 WHERE scontra = f1.scontra
																 AND nversio = f1.nversio
																 AND ctramo = f1.ctramo;
													 EXCEPTION
															WHEN no_data_found THEN
																 p_tab_error(f_sysdate, f_user, vobj, v_traza,
																						 'Err select TRAMOS: NO_DATA_FOUND',
																						 ' sin: ' || sini.nsin || ' v_scontra =' || f1.scontra ||
																							' v_nversio =' || f1.nversio || ' ctramo = ' || f1.ctramo ||
																							' SQLERRM = ' || SQLERRM);
																 v_plocal := 0;
															WHEN OTHERS THEN
																 p_tab_error(f_sysdate, f_user, vobj, v_traza, 'Err select TRAMOS',
																						 ' sin: ' || sini.nsin || ' v_scontra =' || f1.scontra ||
																							' v_nversio =' || f1.nversio || ' ctramo = ' || f1.ctramo ||
																							' SQLERRM = ' || SQLERRM);
													 END;
												
													 v_plocal := v_plocal / 100 * f1.pcesion;
												END IF;
										 END LOOP;
									
										 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL, 3991,
																		 'Cesionesrea x Siniestro-> % Retencion: ' || v_plocal);
									
										 -- SI NOMÉS HI HA RESERVA
										 IF v_hiha_cessio = 0 THEN
												-- Paso 1. Buscamos por garant£¿a
												FOR f2 IN (SELECT DISTINCT scontra, nversio, ctramo, SUM(pcesion) pcesion --CONF-910
																		 FROM cesionesrea
																		WHERE sseguro = sini.sseg
																			AND cgenera IN (1, 3, 4, 5, 9, 40)
																			AND nriesgo = sini.nrie
																			AND fefecto <= sini.fsin
																			AND fvencim >= sini.fsin -- Bug 31730 EDA 11/06/2014
																			AND (fregula IS NULL OR fregula >= sini.fsin) -- Bug 31730 EDA 11/06/2014
																			AND (fanulac IS NULL OR fanulac >= sini.fsin)
																			AND ctramo IN (0, 1)
																			AND cgarant = sini2.cgar
																		GROUP BY scontra, nversio, ctramo) LOOP
													 v_hiha_cessio := 1;
												
													 IF f2.ctramo = 0 THEN
															v_plocal := f2.pcesion;
													 ELSIF NVL(pac_parametros.f_parempresa_n(p_pcempres, 'INFORMA_FECHA_FIN'), 0) = 0 THEN
															--CONF-910
															BEGIN
																 SELECT plocal
																	 INTO v_plocal
																	 FROM tramos
																	WHERE scontra = f2.scontra
																		AND nversio = f2.nversio
																		AND ctramo = f2.ctramo;
															EXCEPTION
																 WHEN no_data_found THEN
																		p_tab_error(f_sysdate, f_user, vobj, v_traza,
																								'Err select TRAMOS: NO_DATA_FOUND',
																								' sin: ' || sini.nsin || ' v_scontra =' || f2.scontra ||
																								 ' v_nversio =' || f2.nversio || ' ctramo = ' || f2.ctramo ||
																								 ' SQLERRM = ' || SQLERRM);
																		v_plocal := 0;
																 WHEN OTHERS THEN
																		p_tab_error(f_sysdate, f_user, vobj, v_traza, 'Err select TRAMOS',
																								' sin: ' || sini.nsin || ' v_scontra =' || f2.scontra ||
																								 ' v_nversio =' || f2.nversio || ' ctramo = ' || f2.ctramo ||
																								 ' SQLERRM = ' || SQLERRM);
															END;
													 
															v_plocal := v_plocal / 100 * f2.pcesion;
													 END IF;
												END LOOP;
										 
												p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL,
																				4048, 'Cesionesrea x Siniestro y Garantía-> % Retencion: ' || v_plocal);
										 
												IF v_hiha_cessio = 0 THEN
													 -- Paso 2. Garant£¿as agrupadas: La garantia no es obligatoria a la reserva, pot estar sense informar.
													 FOR f2 IN (SELECT DISTINCT scontra, nversio, ctramo, SUM(pcesion) pcesion --CONF-910
																				FROM cesionesrea
																			 WHERE sseguro = sini.sseg
																				 AND cgenera IN (1, 3, 4, 5, 9, 40)
																				 AND nriesgo = sini.nrie
																				 AND fefecto <= sini.fsin
																				 AND fvencim >= sini.fsin -- Bug 31730 EDA 11/06/2014
																				 AND (fregula IS NULL OR fregula >= sini.fsin) -- Bug 31730 EDA 11/06/2014
																				 AND (fanulac IS NULL OR fanulac >= sini.fsin)
																				 AND ctramo IN (0, 1)
																				 AND cgarant IS NULL
																			 GROUP BY scontra, nversio, ctramo) LOOP
															v_hiha_cessio := 1;
													 
															IF f2.ctramo = 0 THEN
																 v_plocal := f2.pcesion;
															ELSIF NVL(pac_parametros.f_parempresa_n(p_pcempres, 'INFORMA_FECHA_FIN'), 0) = 0 THEN
																 --CONF-910
																 BEGIN
																		SELECT plocal
																			INTO v_plocal
																			FROM tramos
																		 WHERE scontra = f2.scontra
																			 AND nversio = f2.nversio
																			 AND ctramo = f2.ctramo;
																 EXCEPTION
																		WHEN no_data_found THEN
																			 p_tab_error(f_sysdate, f_user, vobj, v_traza,
																									 'Err select TRAMOS: NO_DATA_FOUND',
																									 ' sin: ' || sini.nsin || ' v_scontra =' || f2.scontra ||
																										' v_nversio =' || f2.nversio || ' ctramo = ' || f2.ctramo ||
																										' SQLERRM = ' || SQLERRM);
																			 v_plocal := 0;
																		WHEN OTHERS THEN
																			 p_tab_error(f_sysdate, f_user, vobj, v_traza, 'Err select TRAMOS',
																									 ' sin: ' || sini.nsin || ' v_scontra =' || f2.scontra ||
																										' v_nversio =' || f2.nversio || ' ctramo = ' || f2.ctramo ||
																										' SQLERRM = ' || SQLERRM);
																 END;
															
																 v_plocal := v_plocal / 100 * f2.pcesion;
															END IF;
													 END LOOP;
												END IF;
										 END IF;
									
										 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL, 4105,
																		 'Cesionesrea x Siniestro para garantía NULL-> % Retencion: ' || v_plocal);
										 -- Si tiene porcentaje, modificamos el importe.
										 sini2.isinpag  := sini2.isinpag * v_plocal / 100;
										 sini2.ireserva := sini2.ireserva * v_plocal / 100;
									END IF;
							 
									--(4.e.iv.1.a.) Se Indexa el pago comparándolo con el Importe a fecha de efecto
									-- del Siniestro.
									v_traza := 7;
							 
									--(4.e.iv.1.b.i.) Reajusta el pago.
									--2: Pago 8: Anulación del Recobro
									IF sini2.ctippag IN (2, 8) THEN
										 v_pago_indexado := v_pago_indexado + sini2.isinpag;
										 --3: Anulación del Pago 7: Recobro
									ELSE
										 --KBR 28/07/2014 Manejo de recobros
										 IF sini2.ctippag = 7 THEN
												v_pago_indexado := v_pago_indexado + (sini2.isinpag - sini2.isinrecob);
										 ELSE
												v_pago_indexado := v_pago_indexado - sini2.isinpag;
										 END IF;
									END IF;
							 
									IF sini2.ctippag IN (2, 8) THEN
										 v_pago_no_indexado := f_round(v_pago_no_indexado + sini2.isinpag);
									ELSE
										 --KBR 28/07/2014 Manejo de recobros
										 IF sini2.ctippag = 7 THEN
												v_pago_no_indexado := f_round(v_pago_no_indexado + (sini2.isinpag - sini2.isinrecob));
										 ELSE
												v_pago_no_indexado := f_round(v_pago_no_indexado - sini2.isinpag);
										 END IF;
									END IF;
							 
									v_pago_indexado := f_round(v_pago_indexado);
							 
									IF NVL(pac_parametros.f_parempresa_n(p_pcempres, 'REA_PAGO_NO_INDEX'), 0) = 1 THEN
										 v_pago_indexado := NVL(v_pago_no_indexado, 0);
									END IF;
							 
									-- Reserves totals i reserves de Despeses desglosades
									v_ireserv := v_ireserv + sini2.ireserva;
							 
									IF NVL(pac_parametros.f_parempresa_n(p_pcempres, 'APLICA_RESMAT_REA_XL'), 0) = 1 THEN
										 v_reserva_mat := NVL(TRUNC(pac_isqlfor.f_provisio_actual(sini2.sseg, 'IPROVRES',
																																							TRUNC(f_sysdate), sini2.cgar), 2), 0);
										 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL, 3871,
																		 'Reserva Mat.: ' || v_reserva_mat);
									
										 SELECT cdivisa INTO v_moneda_prod FROM productos WHERE sproduc = sini.sproduc;
									
										 IF v_cmoncontab <> v_moneda_prod THEN
												nerr := pac_oper_monedas.f_datos_contraval(sini.sseg, NULL, v_scontra, sini.fsin, 3,
																																	 v_itasa_prod, v_fcambio_prod);
										 
												IF nerr <> 0 THEN
													 o_plsql := SQLERRM;
													 p_tab_error(f_sysdate, f_user, vobj, v_traza, 'Err Tasa Prod',
																			 ' v_scontra =' || v_scontra || ' v_nversio =' || v_nversio ||
																				' ctramo = ' || v_ctramo || ' SQLERRM = ' || o_plsql);
												END IF;
										 
												p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL,
																				3894, 'Tasa de cambio: ' || NVL(v_itasa_prod, 1));
												v_reserva_mat := v_reserva_mat * NVL(v_itasa_prod, 1);
										 END IF;
									ELSE
										 v_reserva_mat := 0;
									END IF;
							 
									IF NVL(v_ireserv, 0) <> 0 AND NVL(sini2.ireserva, 0) <> 0 THEN
										 v_ireserv := v_ireserv - v_reserva_mat;
									END IF;
							 
									p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL, 3904,
																	'Reserva (Valor Neto Retenido): ' || v_ireserv);
							 
									IF NVL(v_pago_indexado, 0) <> 0 AND NVL(sini2.isinpag, 0) <> 0 THEN
										 -- Si la Reserva Matematica es més gran que el pago (PAGO PARCIAL) NO LA RESTA
										 -- pendet de revisar amb l'usuari si s'ha de ponderar
										 IF v_pago_indexado - v_reserva_mat > 0 THEN
												v_pago_indexado := v_pago_indexado - v_reserva_mat;
										 END IF;
									
										 v_pago_no_indexado := v_pago_indexado;
									END IF;
							 
									p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL, 3920,
																	'Pagos (Valor Neto Retenido): ' || v_pago_indexado);
							 
									--Añadimos el desglose por tipo de reserva
									IF sini2.ctipres = 1 THEN
										 -- Indemnizatoria
										 v_iresindem_tot := v_iresindem_tot + sini2.ireserva;
										 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL, 3927,
																		 'Reserv. Indem.: ' || v_iresindem_tot);
									ELSIF sini2.ctipres = 2 THEN
										 -- Intereses
										 v_iresinter_tot := v_iresinter_tot + sini2.ireserva;
										 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL, 3932,
																		 'Reserv. Interese: ' || v_iresinter_tot);
									ELSIF sini2.ctipres = 3 THEN
										 -- Gastos
										 v_iresgas_tot := v_iresgas_tot + sini2.ireserva;
										 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL, 3937,
																		 'Reserv. Gastos: ' || v_iresgas_tot);
									ELSIF sini2.ctipres = 4 THEN
										 -- Administración
										 v_iresadmin_tot := v_iresadmin_tot + sini2.ireserva;
										 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL, 3942,
																		 'Reserv. Admon.: ' || v_iresadmin_tot);
									END IF;
							 
									----
									--------------------------------------------------------------------------------------------
									-- pagament indexat només per la part protegida ------------
									v_pago_indexado_ant := v_pago_indexado;
									v_ireserv_ant       := v_ireserv;
									v_iresgas_tot_ant   := v_iresgas_tot;
									v_iresindem_tot_ant := v_iresindem_tot;
									v_iresinter_tot_ant := v_iresinter_tot;
									v_iresadmin_tot_ant := v_iresadmin_tot;
									v_pag_dist          := v_pago_indexado;
									v_res_dist          := v_ireserv;
									p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL, 4128,
																	'Reservas Distribuir: ' || v_res_dist);
									p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL, 4132,
																	'Pagos Distribuir: ' || v_pag_dist);
							 
									--END IF;
									IF NVL(v_pago_indexado_ant, 0) + NVL(v_ireserv_ant, 0) > v_icapaci THEN
										 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL, 4138,
																		 'Facultativo XL');
										 --------------------------------------------------------------------------------
										 --------------------------------------------------------------------------------
										 --LLAMADA AL FACULTATIVO XL: Premisas: Un tramo XL Riesgo, Un Pago
										 --------------------------------------------------------------------------------
										 --------------------------------------------------------------------------------
										 --------------------------------------------------------------------------------
										 v_diferencia_fac    := NVL(v_pago_indexado_ant, 0) + NVL(v_ireserv_ant, 0) - v_icapaci;
										 v_pct_fac           := 100 - v_plocal;
										 v_pago_indexado_fac := v_pago_indexado_ant * v_pct_fac / 100;
										 v_ireserv_fac       := v_ireserv_ant * v_pct_fac / 100;
										 v_iresgas_tot_fac   := v_iresgas_tot_ant * v_pct_fac / 100;
										 v_iresindem_tot_fac := v_iresindem_tot_ant * v_pct_fac / 100;
										 v_iresinter_tot_fac := v_iresinter_tot_ant * v_pct_fac / 100;
										 v_iresadmin_tot_fac := v_iresadmin_tot_ant * v_pct_fac / 100;
										 --Tratamiento XL: Premisa . 1 Sólo tramo XL de riesgo, 1 sólo pago/reserva
										 nerr := f_cessio_xlfacult(p_pcempres, sini.sseg, v_fechacorte, v_pago_indexado_fac,
																							 NVL(w_ctadet, 0), sini.nsin, sini.fsin, NVL(v_c_gar, 0),
																							 sini.ccompapr, p_pproces, sini.mes_sin, sini.anyo_sin, p_pfperfin,
																							 NVL(v_itasa, 1), v_cmoncontab, NVL(v_cmultimon, 1), v_fcambio, 0,
																							 v_pago_indexado_fac, v_pct_fac, v_ireserv_fac, v_desglose_reserva,
																							 v_iresgas_tot_fac, v_iresindem_tot_fac, v_iresinter_tot_fac,
																							 v_iresadmin_tot_fac);
									
										 IF nerr <> 0 THEN
												nerr := 1;
												p_tab_error(f_sysdate, f_user, vobj, v_traza, 'Err insert fac XL',
																		' v_scontra =' || v_scontra || ' v_nversio =' || v_nversio || ' v_ctramo =' ||
																		 v_ctramo || ' 1=' || 1 || ' sini.nsin=' || sini.nsin || ' p_pfcierre =' ||
																		 p_pfcierre || ' SQLERRM = ' || SQLERRM);
												RAISE no_data_found;
										 END IF;
									END IF;
							 END LOOP;
						
							 v_totalpagos_ret  := v_pag_dist;
							 v_ctramo          := 5; --Facultativo y empezamos a validar a partir del primer tramo XL
							 v_totalreserv_ret := v_res_dist;
							 v_ixlprio_ant     := 0;
						
							 --KBR 25/07/2014
							 LOOP
									--LOOP de Multitramos
									BEGIN
										 v_ctramo := v_ctramo + 1;
									
										 IF (v_totalpagos_ret = 0 AND v_totalreserv_ret = 0) OR
												NVL(pac_parametros.f_parempresa_n(p_pcempres, 'MAX_MTRAMOSXL_REA'), 6) < v_ctramo OR
												v_scontra IS NULL THEN
												EXIT;
										 END IF;
									
										 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL, 3585,
																		 'Evaluando Tramo: ' || v_ctramo);
										 -----------------------------------------------------------------------------------
										 -- Se Indexa el pago comparándolo con el Importe a fecha de efecto del Contrato  --
										 --  A partir del contrato conocemos: Importe de Prioridad (IPRIOXL de CONTRATOS) --
										 -----------------------------------------------------------------------------------
										 v_traza := 3;
									
										 BEGIN
												--Obtenemos datos de Contrato y Tramo para Multitramos
												SELECT caplixl, ixlprio, pliminx, plimgas, itottra,
															 -- icapaci, -- Bug 32534/182018 Se elimina, debido a que ya lo asigna en f_buscacontrato
															 iprioxl, ipmd, NVL(crepos, 0), preest
													INTO v_caplixl, v_iprioxl_tramo, v_pliminx, v_plimgas, v_itottra,
															 -- v_icapaci, -- Bug 32534/182018 Se elimina, debido a que ya lo asigna en f_buscacontrato
															 v_iprioxl_ctto, v_ipmd, v_crepos, v_preest
													FROM tramos tt, contratos cc
												 WHERE cc.scontra = v_scontra
													 AND cc.nversio = v_nversio
													 AND cc.scontra = tt.scontra(+)
													 AND cc.nversio = tt.nversio(+)
													 AND tt.ctramo(+) = v_ctramo;
										 EXCEPTION
												WHEN OTHERS THEN
													 p_tab_error(f_sysdate, f_user, vobj, v_traza, 'Err select TRAMOS',
																			 ' v_scontra =' || v_scontra || ' v_nversio =' || v_nversio ||
																				' SQLERRM = ' || SQLERRM);
										 END;
									
										 v_traza := 5;
									
										 --Obtenemos número de reestablecimientos del tramo
										 SELECT COUNT(norden) INTO v_nro_repos FROM reposiciones_det WHERE ccodigo = v_crepos;
									
										 IF v_nro_repos = 0 THEN
												inicio := 0;
										 ELSE
												inicio := 1;
										 END IF;
									
										 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL, 5684,
																		 'Reposiciones del tramo: ' || v_nro_repos);
										 v_primareest := 0;
									
										 --Si no existe capacidad del tramo tomamos la del contrato y su prioridad
										 IF v_iprioxl_tramo IS NULL THEN
												v_ixlprio   := NVL(v_iprioxl_ctto, 0);
												v_ixlcapaci := v_icapaci - v_ixlprio;
										 ELSE
												v_ixlprio   := v_iprioxl_tramo;
												v_ixlcapaci := v_itottra;
										 END IF;
									
										 IF v_ixlprio_ant = 0 THEN
												v_ixlprio_ant := v_ixlprio;
										 ELSE
												v_ixlprio := v_ixlprio_ant;
										 END IF;
									
										 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL, 5700,
																		 'Capacidad: ' || v_ixlcapaci || ' Prioridad: ' || v_ixlprio);
									
										 --Si tenemos el porcentaje de aumento por gastos en el contrato
										 --Calculamos el nuevo límite aumentándolo según el procentaje definido en el contrato (PLIMGAS).
										 IF NVL(v_plimgas, 0) <> 0 THEN
												v_ixlprio := v_ixlprio * (100 + v_plimgas) / 100;
										 
												--KBR Cambio 14/10/2014
												IF v_iprioxl_tramo IS NULL THEN
													 v_ixlcapaci := v_icapaci - v_ixlprio;
												END IF;
										 END IF;
									
										 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL, 5715,
																		 ' NVL(v_pago_indexado, 0): ' || NVL(v_pago_indexado, 0) ||
																			' NVL(v_ireserv, 0): ' || NVL(v_ireserv, 0) || ' v_ixlcapaci: ' ||
																			v_ixlcapaci || ' NVL(v_ixlprio, 0): ' || NVL(v_ixlprio, 0));
									
										 FOR i_rep IN inicio .. v_nro_repos LOOP
												--LOOP de Reestablecimientos
												BEGIN
													 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL,
																					 5712,
																					 'Importe Total Pagos: ' || v_totalpagos_ret ||
																						' Importe Total Reserv.: ' || v_totalreserv_ret);
												
													 IF (v_totalpagos_ret = 0 AND v_totalreserv_ret = 0) OR
															NVL(pac_parametros.f_parempresa_n(p_pcempres, 'MAX_MREPOSXL_REA'), v_nro_repos) <
															i_rep THEN
															EXIT;
													 END IF;
												
													 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL,
																					 3720, 'Prioridad: ' || v_ixlprio);
												
													 BEGIN
															--Validar pagos
															IF NVL(v_totalpagos_ret, 0) <> 0 AND NVL((v_totalpagos_ret - v_ixlprio), 0) <> 0 THEN
																 -- Si el porcentaje cuota es negativo, se pone CERO (Ha bajado de la prioridad)
																 IF ROUND(((NVL(v_totalpagos_ret, 0) - NVL(v_ixlprio, 0)) / v_totalpagos_ret) * 100,
																					4) < 0 THEN
																		v_pcuorea        := 0;
																		v_pag_dist       := 0;
																		v_ixlprio        := v_ixlprio - v_totalpagos_ret;
																		v_totalpagos_ret := 0;
																		--variable temporal
																		v_temp_pagos_ret := v_totalpagos_ret;
																		p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete,
																										v_nom_funcion, NULL, 4192,
																										'% Cuota Negativo->Pagos 0, Prioridad: ' || v_ixlprio);
																 ELSE
																		IF NVL(v_totalpagos_ret, 0) - NVL(v_ixlprio, 0) > v_ixlcapaci THEN
																			 --v_pcuorea := ROUND((v_ixlcapaci / v_pago_indexado) * 100, 4);
																			 v_pag_dist := v_ixlcapaci;
																			 v_pcuorea  := ROUND((v_pag_dist / v_totalpagos_ret) * 100, 5);
																			 --variable temporal
																			 v_temp_pagos_ret := v_totalpagos_ret;
																			 --Recalculamos los pagos totales para el próximo reinstalamiento/tramo
																			 v_totalpagos_ret := v_totalpagos_ret - v_pag_dist;
																		ELSE
																			 --Importe pagado cedido xl (Total Pagos - Prioridad)
																			 v_pag_dist := NVL(v_totalpagos_ret, 0) - NVL(v_ixlprio, 0);
																			 v_pcuorea  := ROUND((v_pag_dist / v_totalpagos_ret) * 100, 5);
																			 --variable temporal
																			 v_temp_pagos_ret := v_totalpagos_ret;
																			 --No existen más pagos a ceder al XL
																			 v_totalpagos_ret := 0;
																		END IF;
																 
																		v_ixlprio := 0;
																 END IF;
															
																 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion,
																								 NULL, 5735,
																								 'Pagos Ced XL: ' || v_pag_dist || ' % Pagos al XL: ' ||
																									v_pcuorea || ' Total Pagos Ret: ' || v_totalpagos_ret);
															
																 --Calculamos la prima de reestablecimiento
																 IF i_rep <> 0 THEN
																		--pr=(pmd*pagos cedidos xl de la capa/ capacidad de la capa)* %reestablecimiento;
																		v_primareest := (v_ipmd * v_pag_dist / v_ixlcapaci) * v_preest / 100;
																 END IF;
															
																 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion,
																								 NULL, 5749, 'Prima Reest.: ' || v_primareest);
															ELSE
																 v_pag_dist := 0;
																 v_pcuorea  := 0;
																 --No existen más pagos a ceder al XL
																 v_totalpagos_ret := 0;
																 --variable temporal
																 v_temp_pagos_ret := v_totalpagos_ret;
																 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion,
																								 NULL, 5757, 'No existen pagos a ceder al XL');
															END IF;
													 
															p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion,
																							NULL, 4214,
																							'%Pagos, Prioridad, Pagos Dist.: ' || v_pcuorea || ',' ||
																							 v_ixlprio || ',' || v_pag_dist);
															v_res_dist := NVL(v_totalreserv_ret, 0) - NVL(v_ixlprio, 0);
													 
															IF NVL(v_pag_dist, 0) = 0 THEN
																 IF v_res_dist > v_ixlcapaci THEN
																		v_res_dist := v_ixlcapaci;
																		--variable temporal
																		v_reserva_ret := v_totalreserv_ret;
																		--Recalculamos las reservas totales para el próximo reinstalamiento/tramo
																		v_totalreserv_ret := v_totalreserv_ret - v_res_dist;
																 ELSE
																		v_reserva_ret     := v_totalreserv_ret;
																		v_totalreserv_ret := 0;
																 END IF;
															ELSE
																 IF v_res_dist > (v_ixlcapaci - NVL(v_pag_dist, 0)) THEN
																		v_res_dist := v_ixlcapaci - v_pag_dist; --Caso que se haga la distribución parcial de la reserva al XL
																		--variable temporal
																		v_reserva_ret := v_totalreserv_ret;
																		--Recalculamos las reservas totales para el próximo reinstalamiento/tramo
																		v_totalreserv_ret := v_totalreserv_ret - v_res_dist;
																 ELSE
																		v_reserva_ret     := v_totalreserv_ret;
																		v_totalreserv_ret := 0;
																 END IF;
															END IF;
													 
															p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion,
																							NULL, 4230, 'Reserv. Dist.: ' || v_res_dist);
													 END;
												
													 v_iresind := v_ireserv;
												
													 IF v_res_dist < 0 THEN
															v_res_dist := 0;
													 END IF;
												
													 --Buscamos el importe de reserva anterior para obtener el movimiento XL de reserva =
													 --Valor Reserva XL actual menos valor Reserva XL anterior
													 BEGIN
															SELECT NVL(SUM(iresnet), 0)
																INTO v_reserva_anterior
																FROM liquidareaxl
															 WHERE nsinies = sini.nsin
																 AND fcierre = ADD_MONTHS(fcierre, -1);
													 END;
												
													 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL,
																					 4259, 'Reserva Ant.: ' || v_reserva_anterior);
													 v_iresrea_mov := v_res_dist - v_reserva_anterior;
												
													 --Buscamos el importe de pagos anterior para obtener el movimiento XL de pagos =
													 --Valor Pagos XL actual menos valor Pagos XL anterior
													 BEGIN
															SELECT NVL(SUM(iliqnet), 0)
																INTO v_pagos_anterior
																FROM liquidareaxl
															 WHERE nsinies = sini.nsin
																 AND fcierre = ADD_MONTHS(fcierre, -1);
													 END;
												
													 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL,
																					 4273, 'Pagos Ant.: ' || v_pagos_anterior);
													 v_ipagrea_mov := v_pag_dist - v_pagos_anterior;
													 nerr          := 0;
													 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL,
																					 4285, 'v_res_dist: ' || v_res_dist || ' v_pag_dist: ' || v_pag_dist);
													 v_pcuotot := ROUND((NVL(v_pag_dist, 0) + NVL(v_res_dist, 0)) /
																							(NVL(v_pago_indexado, 0) + NVL(v_ireserv, 0)) * 100, 5);
													 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL,
																					 4290, '% Cuota total: ' || v_pcuotot);
												
													 --------------------------------------------------------------------------------
													 --(4.e.iiii.) Se busca las compañías definidas en el contrato (CUADROCES)
													 FOR compa IN c_cuadroces_agr(v_scontra, v_nversio, v_ctramo) LOOP
															IF compa.ccompani > 1 THEN
																 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion,
																								 NULL, 4282, 'Cia: ' || compa.ccompani);
																 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion,
																								 NULL, 4284, '%Part: ' || compa.pcesion);
																 --(4.e.iv.1.) Para todos los pagos del siniestro:
																 -- Importe pagado reaseguro (suma liquidaciones anteriores (6))
																 -- IPAGREA  = Sumatorio de ILIQREA de las liquidaciones anteriores por SINIESTRO
																 -->> importes de liquidaciones anteriores por siniestro en la PAGOSREAXL
																 v_traza := 8;
																 -- Importe Cuota Reaseguro (5)
																 -- ICUOREA = ITOTEXP * PCUOREA * Participación compañía reaseguradora
																 v_icuorea := v_pag_dist * compa.pcesion / 100;
																 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion,
																								 NULL, 4295, '%Cuota (Pagos): ' || v_icuorea);
																 -- Importe Liquidación Reaseguro (7)
																 v_iliqrea := v_icuorea;
																 -- Importe reservas (8)
																 --IRESERV = reserva actual del directo
																 v_traza := 9;
															
																 IF nerr = 0 THEN
																		IF v_cmultimon = 1 THEN
																			 nerr := pac_oper_monedas.f_datos_contraval(NULL, NULL, v_scontra,
																																									sini.fsin, 3, v_itasa, v_fcambio);
																		
																			 IF nerr <> 0 THEN
																					o_plsql    := SQLERRM;
																					p_pscesrea := TO_NUMBER(TO_CHAR(v_scontra) || TO_CHAR(v_nversio) ||
																																	TO_CHAR(v_ctramo) || TO_CHAR(compa.ccompani));
																			 END IF;
																		END IF;
																 END IF;
															
																 -- Importe total reaseguro (11)
																 --ITOTREA = ((ITOTEXP+IRESERV) * PCUOTOT * Participación compañía reaseguradora.
																 v_itotrea   := ((v_res_dist + v_pag_dist) * compa.pcesion / 100);
																 v_iresgas   := v_iresgas_tot * v_pcuotot / 100 * compa.pcesion / 100;
																 v_iresindem := v_iresindem_tot * v_pcuotot / 100 * compa.pcesion / 100;
																 v_iresinter := v_iresinter_tot * v_pcuotot / 100 * compa.pcesion / 100;
																 v_iresadmin := v_iresadmin_tot * v_pcuotot / 100 * compa.pcesion / 100;
																 -- Importe reserva reaseguro v_itotrea(12)
																 -- IRESREA = ITOTREA - ICUOREA
																 v_iresrea := v_itotrea - v_icuorea;
																 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion,
																								 NULL, 4331, 'Reserva (Cia): ' || v_iresrea);
																 --(4.e.iv.2.d.) Si es un cierre previo inserta en LIQUIDAREAXLAUX sino Inserta en LIQUIDAREAXL la suma de los importes calculados:
																 v_ilimind := 0;
																 v_pcuorea := 0;
																 v_icuorea := 0;
																 -------------------------------
																 -- Control ILIQNET i IRESNET --
																 -------------------------------
																 -- CONTROL DEL LAA ANIVEL DE COMPAÑÍAS (CORREDOR)
																 v_imaxagr     := compa.imaxagr;
																 v_iminagr     := compa.iminagr;
																 v_iliqrea_pag := 0;
																 v_traza       := 10;
															
																 -- Sumatoria de pagos en estado LIQUIDADO
																 BEGIN
																		SELECT SUM(iliqrea)
																			INTO v_ipagrea_tot
																			FROM pagosreaxl
																		 WHERE scontra = v_scontra
																			 AND nversio = v_nversio
																			 AND ctramo = compa.ctramo
																			 AND ccompani = compa.ccompani
																			 AND fcierre < p_pfperfin
																			 AND cestliq = 1;
																 EXCEPTION
																		WHEN OTHERS THEN
																			 nerr := 1;
																			 p_tab_error(f_sysdate, f_user, vobj, v_traza, 'Err SELECT pagosreaxl',
																									 ' v_scontra =' || v_scontra || ' nversio =' || v_nversio ||
																										' compa.ccompani =' || compa.ccompani || ' p_pfperfin =' ||
																										p_pfperfin || ' SQLERRM = ' || SQLERRM);
																 END;
															
																 v_traza := 11;
															
																 BEGIN
																		UPDATE cuadroces
																			 SET iagrega = v_ipagrea_tot
																		 WHERE scontra = v_scontra
																			 AND nversio = v_nversio
																			 AND ctramo = compa.ctramo
																			 AND ccompani = compa.ccompani
																			 AND iagrega = 0;
																 EXCEPTION
																		WHEN OTHERS THEN
																			 nerr := 1;
																			 p_tab_error(f_sysdate, f_user, vobj, v_traza, 'Err UPDATE cuadroces',
																									 ' v_scontra =' || v_scontra || ' v_nversio =' || v_nversio ||
																										' compa.ccompani =' || compa.ccompani || ' p_pfperfin =' ||
																										p_pfperfin || ' SQLERRM = ' || SQLERRM);
																 END;
															
																 v_traza := 12;
															
																 BEGIN
																		SELECT MAX(iagrega)
																			INTO v_iliqrea_cum
																			FROM cuadroces
																		 WHERE scontra = v_scontra
																			 AND nversio = v_nversio
																			 AND ctramo = compa.ctramo
																			 AND ccompani = compa.ccompani;
																 EXCEPTION
																		WHEN OTHERS THEN
																			 nerr := 1;
																			 p_tab_error(f_sysdate, f_user, vobj, v_traza,
																									 'Err SELECT MAX(iagrega) cuadroces',
																									 ' v_scontra =' || v_scontra || ' v_nversio =' || v_nversio ||
																										' compa.ccompani =' || compa.ccompani || ' p_pfperfin =' ||
																										p_pfperfin || ' SQLERRM = ' || SQLERRM);
																 END;
															
																 v_diferencia     := v_imaxagr - v_iliqrea_cum;
																 v_diferencia_min := v_iliqrea_cum - v_iminagr;
																 v_iliqrea_cum    := v_iliqrea_cum + v_iliqrea;
																 v_traza          := 13;
															
																 BEGIN
																		UPDATE cuadroces
																			 SET iagrega = v_iliqrea_cum
																		 WHERE scontra = v_scontra
																			 AND nversio = v_nversio
																			 AND ctramo = compa.ctramo
																			 AND ccompani = compa.ccompani;
																 EXCEPTION
																		WHEN OTHERS THEN
																			 nerr := 1;
																			 p_tab_error(f_sysdate, f_user, vobj, v_traza, 'Err UPDATE cuadroces',
																									 ' v_scontra =' || v_scontra || ' v_nversio =' || v_nversio ||
																										' compa.ccompani =' || compa.ccompani || '  v_iliqrea_cum =' ||
																										v_iliqrea_cum || ' SQLERRM = ' || SQLERRM);
																 END;
															
																 --(4.e.iv.2.) Se comprueba que no se haya superado el Límite Agregado Anual: IAGREGA de CONTRATOS (Importe Agregado XL) + Importe Pago < IMAXAGR de CONTRATOS (Límite máximo agregado anual)
																 --ICV Si el contrato a excedido el maxagr o el contrato no ha llegado al minimo no se liquida nada
																 --ICV CONTROL LIMITE AGREGADO
																 IF NVL(v_iliqrea_cum, 0) > NVL(v_imaxagr, 0) THEN
																		v_iliqrea_pag := v_diferencia;
																 
																		--(4.e.iv.2.a.) Si ha superado el LAA:
																		--(4.e.iv.2.a.i.) Actualizamos IAGREGA = IMAXAGR del contrato.
																		IF v_iliqrea_pag < 0 THEN
																			 v_iliqrea_pag := 0;
																		END IF;
																 
																		IF v_iliqrea = 0 THEN
																			 v_iliqrea_pag := v_iliqrea;
																		END IF;
																 
																		v_traza := 14;
																 
																		-- SE BAJA A NIVEL DE COMPAÑÍA
																		BEGIN
																			 UPDATE cuadroces
																					SET iagrega = v_iliqrea_cum - v_iliqrea_pag
																				WHERE scontra = v_scontra
																					AND nversio = v_nversio
																					AND ctramo = v_ctramo
																					AND ccompani = compa.ccompani;
																		EXCEPTION
																			 WHEN OTHERS THEN
																					nerr := 1;
																					p_tab_error(f_sysdate, f_user, vobj, v_traza, 'Err UPDATE CUADROCES',
																											' v_scontra =' || v_scontra || '  v_nversio =' ||
																											 v_nversio || ' SQLERRM = ' || SQLERRM);
																		END;
																 ELSE
																		-- ENTRA TOT ALS PAGAMENTS
																		v_iliqrea_pag := v_iliqrea;
																		--(4.e.iv.2.b.) No ha superado:
																 END IF;
															
																 IF NVL(v_iminagr, 0) <> 0 THEN
																		--DEDUCIBLE AGREGADO
																		IF v_iliqrea_cum < NVL(v_iminagr, 0) THEN
																			 v_iliqrea_pag := 0;
																		ELSE
																			 IF v_diferencia_min > 0 THEN
																					v_iliqrea_pag := v_iliqrea;
																			 ELSE
																					v_iliqrea_pag := v_diferencia_min + v_iliqrea;
																			 END IF;
																		END IF;
																 END IF;
															
																 ------------------------------
																 -- s'aplica la participació --
																 ------------------------------
																 -- Calculo de % Part. Inicial
																 v_traza := 15;
															
																 BEGIN
																		SELECT NVL(cestado, 1)
																			INTO v_cestado
																			FROM ctatecnica
																		 WHERE scontra = v_scontra
																			 AND nversio = v_nversio
																			 AND ctramo = v_ctramo
																			 AND ccompani = compa.ccompani
																			 AND sproduc = sini.sproduc;
																 EXCEPTION
																		WHEN no_data_found THEN
																			 BEGIN
																					INSERT INTO ctatecnica
																						 (ccompani, nversio, scontra, ctramo, nctatec, cfrecul, cestado,
																							festado, fcierre, cempres, sproduc, ccorred)
																					VALUES
																						 (compa.ccompani, v_nversio, v_scontra, v_ctramo, 1, 3, 1, NULL,
																							NULL, p_pcempres, sini.sproduc, compa.ccorred);
																			 EXCEPTION
																					WHEN OTHERS THEN
																						 v_cestado := 1;
																						 p_tab_error(f_sysdate, f_user, vobj, v_traza,
																												 'Err INSERT INTO ctatecnica', ' SQLERRM = ' || SQLERRM);
																			 END;
																		WHEN OTHERS THEN
																			 v_cestado := 1;
																			 o_plsql   := SQLERRM;
																			 p_tab_error(f_sysdate, f_user, vobj, v_traza, 'Err SELECT ctatecnica',
																									 ' v_scontra=' || v_scontra || ' v_nversio=' || v_nversio ||
																										' v_ctramo=' || v_ctramo || ' compa.ccompani=' ||
																										compa.ccompani || ' SQLERRM = ' || SQLERRM);
																 END;
															
																 v_traza := 16;
																 -- se guarda la liquidación aplicando el límite pero no el run-off
																 v_iliqrea_lim := v_iliqrea_pag;
																 v_iresnet     := v_iresrea;
																 v_traza       := 17;
															
																 IF (v_res_dist <> 0 OR v_pag_dist <> 0) THEN
																		BEGIN
																			 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete,
																											 v_nom_funcion, NULL, 4539, 'Insert liquidareaxl_aux');
																		
																			 INSERT INTO liquidareaxl_aux
																					(nsinies, fsinies, itotexp, itotind, fcierre, sproces, scontra,
																					 nversio, ctramo, ccompani, pcuorea, icuorea, ipagrea, iliqrea, ireserv,
																					 iresind, pcuotot, itotrea, iresrea, ilimind, iliqnet, iresnet, iresgas,
																					 iresindem, iresinter, iresadmin, icuorea_moncon, ilimind_moncon,
																					 iliqnet_moncon, iliqrea_moncon, ipagrea_moncon, ireserv_moncon,
																					 iresgas_moncon, iresindem_moncon, iresinter_moncon, iresadmin_moncon,
																					 iresind_moncon, iresnet_moncon, iresrea_moncon, itotexp_moncon,
																					 itotind_moncon, itotrea_moncon)
																			 VALUES
																					(sini.nsin, sini.fsin, v_pago_no_indexado, v_pago_indexado, p_pfperfin,
																					 p_pproces, v_scontra, v_nversio, v_ctramo, compa.ccompani, v_pcuorea,
																					 v_icuorea, v_ipagrea_mov, v_ipagrea_mov, v_ireserv, v_iresind,
																					 v_pcuotot, v_itotrea, v_iresrea_mov, NVL(v_ilimind, 0), v_iliqrea_pag,
																					 v_iresnet, v_iresgas, v_iresindem, v_iresinter, v_iresadmin,
																					 f_round(NVL(v_icuorea, 0) * v_itasa, v_cmoncontab),
																					 f_round(NVL(v_ilimind, 0) * v_itasa, v_cmoncontab),
																					 f_round(NVL(v_iliqrea_pag, 0) * v_itasa, v_cmoncontab),
																					 f_round(NVL(v_ipagrea_mov, 0) * v_itasa, v_cmoncontab),
																					 f_round(NVL(v_ipagrea_mov, 0) * v_itasa, v_cmoncontab),
																					 f_round(NVL(v_ireserv, 0) * v_itasa, v_cmoncontab),
																					 f_round(NVL(v_iresgas, 0) * v_itasa, v_cmoncontab),
																					 f_round(NVL(v_iresindem, 0) * v_itasa, v_cmoncontab),
																					 f_round(NVL(v_iresinter, 0) * v_itasa, v_cmoncontab),
																					 f_round(NVL(v_iresadmin, 0) * v_itasa, v_cmoncontab),
																					 f_round(NVL(v_iresind, 0) * v_itasa, v_cmoncontab),
																					 f_round(NVL(v_iresnet, 0) * v_itasa, v_cmoncontab),
																					 f_round(NVL(v_iresrea_mov, 0) * v_itasa, v_cmoncontab),
																					 f_round(NVL(v_pago_no_indexado, 0) * v_itasa, v_cmoncontab),
																					 f_round(NVL(v_pago_indexado, 0) * v_itasa, v_cmoncontab),
																					 f_round(NVL(v_itotrea, 0) * v_itasa, v_cmoncontab));
																		EXCEPTION
																			 WHEN OTHERS THEN
																					nerr := 1;
																					p_tab_error(f_sysdate, f_user, vobj, v_traza,
																											'Err INSERT INTO liquidareaxl_aux', 'SQLERRM = ' || SQLERRM);
																		END;
																 
																		v_traza := 18;
																 
																		IF v_pag_dist <> 0 THEN
																			 BEGIN
																					p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete,
																													v_nom_funcion, NULL, 4610, 'Insert pagosreaxl_aux');
																			 
																					INSERT INTO pagosreaxl_aux
																						 (nsinies, scontra, nversio, ctramo, ccompani, fcierre, sproces,
																							iliqrea, cestliq, iliqrea_moncon, fcambio)
																					VALUES
																						 (sini.nsin, v_scontra, v_nversio, v_ctramo, compa.ccompani,
																							p_pfperfin, p_pproces, v_iliqrea_lim, 0,
																							f_round(NVL(v_iliqrea_lim, 0) * v_itasa, v_cmoncontab),
																							DECODE(v_cmultimon, 0, NULL, NVL(v_fcambio, sini.fsin)));
																			 EXCEPTION
																					WHEN OTHERS THEN
																						 p_tab_error(f_sysdate, f_user, vobj, v_traza,
																												 'Err INSERT INTO pagosreaxl', ' SQLERRM = ' || SQLERRM);
																						 nerr := 1;
																			 END;
																		
																			 -- se actualizan pagos anteriores NO LIQUIDADOS
																			 BEGIN
																					UPDATE pagosreaxl
																						 SET cestliq = 2
																					 WHERE scontra = v_scontra
																						 AND nversio = v_nversio
																						 AND ctramo = compa.ctramo
																						 AND ccompani = compa.ccompani
																						 AND fcierre < p_pfperfin
																						 AND nsinies = sini.nsin
																						 AND cestliq = 0;
																			 EXCEPTION
																					WHEN no_data_found THEN
																						 p_tab_error(f_sysdate, f_user, vobj, v_traza,
																												 'Err UPDATE pagosreaxl',
																												 ' v_scontra =' || v_scontra || ' v_nversio =' ||
																													v_nversio || ' v_ctramo =' || v_ctramo ||
																													' compa.ccompani=' || compa.ccompani || ' sini.nsin=' ||
																													sini.nsin || ' p_pfperfin =' || p_pfperfin ||
																													' SQLERRM = ' || SQLERRM);
																					WHEN OTHERS THEN
																						 nerr := 1;
																						 p_tab_error(f_sysdate, f_user, vobj, v_traza,
																												 'Err UPDATE pagosreaxl',
																												 ' v_scontra =' || v_scontra || ' v_nversio =' ||
																													v_nversio || ' v_ctramo =' || v_ctramo ||
																													' compa.ccompani=' || compa.ccompani || ' sini.nsin=' ||
																													sini.nsin || ' p_pfperfin =' || p_pfperfin ||
																													' SQLERRM = ' || SQLERRM);
																			 END;
																		END IF;
																 ELSE
																		p_tab_error(f_sysdate, f_user, vobj, v_traza, 'IF nerr = 0 THEN',
																								'(4.e.iv.2.d.) (2) nerr:' || nerr);
																 END IF;
															
																 v_traza := 19;
															
																 BEGIN
																		SELECT NVL(MAX(nnumlin), 0)
																			INTO w_nnumlin
																			FROM movctaaux
																		 WHERE scontra = v_scontra
																			 AND nversio = v_nversio
																			 AND ctramo = v_ctramo
																			 AND ccompani = compa.ccompani;
																 
																		w_nnumlin := w_nnumlin + 1;
																 EXCEPTION
																		WHEN no_data_found THEN
																			 w_nnumlin := 1;
																			 p_tab_error(f_sysdate, f_user, vobj, v_traza, 'Err SELECT MOVCTAAUX',
																									 ' v_scontra=' || v_scontra || ' v_nversio=' || v_nversio ||
																										' v_ctramo=' || v_ctramo || ' compa.ccompani=' ||
																										compa.ccompani || ' SQLERRM = ' || SQLERRM);
																		WHEN OTHERS THEN
																			 nerr    := 104863;
																			 o_plsql := SQLERRM;
																			 p_tab_error(f_sysdate, f_user, vobj, v_traza, 'Err SELECT MOVCTAAUX',
																									 ' v_scontra=' || v_scontra || ' v_nversio=' || v_nversio ||
																										' v_ctramo=' || v_ctramo || ' compa.ccompani=' ||
																										compa.ccompani || ' SQLERRM = ' || SQLERRM);
																 END;
															
																 v_traza := 20;
															
																 BEGIN
																		SELECT NVL(cestado, 1)
																			INTO v_cestado
																			FROM ctatecnica
																		 WHERE scontra = v_scontra
																			 AND nversio = v_nversio
																			 AND ctramo = v_ctramo
																			 AND ccompani = compa.ccompani
																			 AND sproduc = sini.sproduc;
																 EXCEPTION
																		WHEN no_data_found THEN
																			 BEGIN
																					INSERT INTO ctatecnica
																						 (ccompani, nversio, scontra, ctramo, nctatec, cfrecul, cestado,
																							festado, fcierre, cempres, sproduc, ccorred)
																					VALUES
																						 (compa.ccompani, v_nversio, v_scontra, v_ctramo, 1, 3, 1, NULL,
																							NULL, p_pcempres, sini.sproduc, compa.ccorred);
																			 EXCEPTION
																					WHEN OTHERS THEN
																						 v_cestado := 1;
																						 p_tab_error(f_sysdate, f_user, vobj, v_traza,
																												 'Err INSERT INTO ctatecnica', ' SQLERRM = ' || SQLERRM);
																			 END;
																		WHEN OTHERS THEN
																			 v_cestado := 1;
																			 o_plsql   := SQLERRM;
																			 p_tab_error(f_sysdate, f_user, vobj, v_traza, 'Err SELECT ctatecnica',
																									 ' v_scontra=' || v_scontra || ' v_nversio=' || v_nversio ||
																										' v_ctramo=' || v_ctramo || ' compa.ccompani=' ||
																										compa.ccompani || ' SQLERRM = ' || SQLERRM);
																 END;
															
																 --(4.e.iv.5.) Selecionamos los importes de liquidación por contrato, versión, tramo, compañía (CCONCEP: 5):
																 --(4.e.iv.5.a.i.) El sumatorio de este concepto para todas las cuentas por contrato y versión
																 -- tiene que ser igual al IAGREGA definido en el contrato.
																 v_iliqrea_cia := v_iliqrea_pag * compa.pcesion / compa.pcesion;
															
																 -- detall a nivell de sinistre
																 IF NVL(w_ctadet, 0) = 1 THEN
																		SELECT COUNT(1)
																			INTO v_numero
																			FROM movctaaux
																		 WHERE scontra = v_scontra
																			 AND nversio = v_nversio
																			 AND ctramo = v_ctramo
																			 AND ccompani = compa.ccompani
																			 AND cconcep = 5
																			 AND (sproduc = sini.sproduc OR NVL(sproduc, 0) = 0)
																			 AND nsinies = sini.nsin;
																 ELSE
																		SELECT COUNT(1)
																			INTO v_numero
																			FROM movctaaux
																		 WHERE scontra = v_scontra
																			 AND nversio = v_nversio
																			 AND ctramo = v_ctramo
																			 AND ccompani = compa.ccompani
																			 AND cconcep = 5
																			 AND (sproduc = sini.sproduc OR NVL(sproduc, 0) = 0);
																 END IF;
															
																 -->> Prestaciones pagadas  (liquidadas al XL o de pagos aceptados al proporcional)
																 IF v_numero > 0 THEN
																		v_traza := 21;
																 
																		-- detall a nivell de sinistre
																		IF NVL(w_ctadet, 0) = 1 THEN
																			 BEGIN
																					UPDATE movctaaux
																						 SET iimport = iimport + v_iliqrea_cia
																					 WHERE scontra = v_scontra
																						 AND nversio = v_nversio
																						 AND ctramo = v_ctramo
																						 AND ccompani = compa.ccompani
																						 AND cconcep = 05
																						 AND (sproduc = sini.sproduc OR NVL(sproduc, 0) = 0)
																						 AND NVL(ccompapr, 0) = NVL(sini.ccompapr, 0)
																						 AND nsinies = sini.nsin;
																			 EXCEPTION
																					WHEN OTHERS THEN
																						 nerr    := 105801;
																						 o_plsql := SQLERRM;
																						 p_tab_error(f_sysdate, f_user, vobj, v_traza,
																												 'Err UPDATE movctaaux - cconcep = 05',
																												 ' v_iliqrea=' || v_iliqrea || ' v_scontra=' ||
																													v_scontra || ' v_nversio=' || v_nversio || ' v_ctramo=' ||
																													v_ctramo || ' compa.ccompani=' || compa.ccompani ||
																													' sini.nsin:' || sini.nsin || ' SQLERRM = ' || SQLERRM);
																			 END;
																		ELSE
																			 BEGIN
																					UPDATE movctaaux
																						 SET iimport = iimport + v_iliqrea_cia
																					 WHERE scontra = v_scontra
																						 AND nversio = v_nversio
																						 AND ctramo = v_ctramo
																						 AND ccompani = compa.ccompani
																						 AND cconcep = 05
																						 AND NVL(ccompapr, 0) = NVL(sini.ccompapr, 0)
																						 AND (sproduc = sini.sproduc OR NVL(sproduc, 0) = 0);
																			 EXCEPTION
																					WHEN OTHERS THEN
																						 nerr    := 105801;
																						 o_plsql := SQLERRM;
																						 p_tab_error(f_sysdate, f_user, vobj, v_traza,
																												 'Err UPDATE movctaaux - cconcep = 05',
																												 ' v_iliqrea=' || v_iliqrea || ' v_scontra=' ||
																													v_scontra || ' v_nversio=' || v_nversio || ' v_ctramo=' ||
																													v_ctramo || ' compa.ccompani=' || compa.ccompani ||
																													' SQLERRM = ' || SQLERRM);
																			 END;
																		END IF;
																 ELSE
																		--(5)Siniestros:v_iliqrea_cia
																		v_traza := 22;
																 
																		IF v_iliqrea_cia <> 0 THEN
																			 BEGIN
																					p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete,
																													v_nom_funcion, NULL, 4841,
																													'Insert movctaaux (Concepto 5: Pagos Siniestros)');
																			 
																					INSERT INTO movctaaux
																						 (ccompani, nversio, scontra, ctramo, nnumlin, fmovimi, fefecto,
																							cconcep, cdebhab, iimport, cestado, sproces, scesrea, cempres,
																							fcierre, sproduc, nsinies, ccompapr, ccorred) -- 25/05/2015  CJMR  0033158: Actualización campo CCORRED en los cierres de Reaseguro
																					VALUES
																						 (compa.ccompani, v_nversio, v_scontra, v_ctramo, w_nnumlin,
																							LAST_DAY(TO_DATE('01/' || sini.mes_sin || '/' || sini.anyo_sin,
																																'dd/mm/yyyy')),
																							LAST_DAY(TO_DATE('01/' || sini.mes_sin || '/' || sini.anyo_sin,
																																'dd/mm/yyyy')), 5, 1, v_iliqrea_cia, v_cestado,
																							p_pproces, NULL, p_pcempres, p_pfperfin, sini.sproduc,
																							DECODE(NVL(w_ctadet, 0), 1, sini.nsin, 0), sini.ccompapr,
																							compa.ccorred); -- 25/05/2015  CJMR  0033158: Actualización campo CCORRED en los cierres de Reaseguro
																			 EXCEPTION
																					WHEN dup_val_on_index THEN
																						 nerr    := 105800;
																						 o_plsql := SQLERRM;
																						 p_tab_error(f_sysdate, f_user, vobj, v_traza,
																												 'Err DUPLICADO INSERT movctaaux - cconcep = 05',
																												 ' v_scontra=' || v_scontra || ' v_nversio=' ||
																													v_nversio || ' v_ctramo=' || v_ctramo ||
																													' compa.ccompani=' || compa.ccompani || ' SQLERRM = ' ||
																													SQLERRM);
																					WHEN OTHERS THEN
																						 nerr    := 105802;
																						 o_plsql := SQLERRM;
																						 p_tab_error(f_sysdate, f_user, vobj, v_traza,
																												 'Err INSERT movctaaux - cconcep = 05',
																												 ' v_scontra=' || v_scontra || ' v_nversio=' ||
																													v_nversio || ' v_ctramo=' || v_ctramo ||
																													' compa.ccompani=' || compa.ccompani || ' SQLERRM = ' ||
																													SQLERRM);
																			 END;
																		END IF;
																 END IF;
															
																 -- CCONCEP = 15 LIQUIDACION ACTUAL XL (APLINDO EL % ACTUAL DE LA CÍA Y EL LAA)
																 IF NVL(w_ctadet, 0) = 1 THEN
																		SELECT COUNT(1)
																			INTO v_numero
																			FROM movctaaux
																		 WHERE scontra = v_scontra
																			 AND nversio = v_nversio
																			 AND ctramo = v_ctramo
																			 AND ccompani = compa.ccompani
																			 AND cconcep = 15
																			 AND (sproduc = sini.sproduc OR NVL(sproduc, 0) = 0)
																			 AND nsinies = sini.nsin;
																 ELSE
																		SELECT COUNT(1)
																			INTO v_numero
																			FROM movctaaux
																		 WHERE scontra = v_scontra
																			 AND nversio = v_nversio
																			 AND ctramo = v_ctramo
																			 AND ccompani = compa.ccompani
																			 AND cconcep = 15
																			 AND (sproduc = sini.sproduc OR NVL(sproduc, 0) = 0);
																 END IF;
															
																 IF v_ipagrea_tot >= v_imaxagr THEN
																		v_iliqrea_tot_cia := 0;
																 ELSE
																		v_iliqrea_pag_cia := v_iliqrea * compa.pcesion / compa.pcesion;
																		v_iliqrea_tot_cia := v_iliqrea_pag_cia;
																 END IF;
															
																 IF v_numero > 0 THEN
																		v_traza := 23;
																 
																		IF NVL(w_ctadet, 0) = 1 THEN
																			 BEGIN
																					UPDATE movctaaux
																						 SET iimport = iimport + v_iliqrea_tot_cia
																					 WHERE scontra = v_scontra
																						 AND nversio = v_nversio
																						 AND ctramo = v_ctramo
																						 AND ccompani = compa.ccompani
																						 AND cconcep = 15
																						 AND (sproduc = sini.sproduc OR NVL(sproduc, 0) = 0)
																						 AND NVL(ccompapr, 0) = NVL(sini.ccompapr, 0)
																						 AND nsinies = sini.nsin;
																			 EXCEPTION
																					WHEN OTHERS THEN
																						 nerr    := 105801;
																						 o_plsql := SQLERRM;
																						 p_tab_error(f_sysdate, f_user, vobj, v_traza,
																												 'Err UPDATE movctaaux - cconcep = 15',
																												 ' v_scontra=' || v_scontra || ' v_nversio=' ||
																													v_nversio || ' v_ctramo=' || v_ctramo ||
																													' compa.ccompani=' || compa.ccompani || ' sini.nsin:' ||
																													sini.nsin || ' SQLERRM = ' || SQLERRM);
																			 END;
																		ELSE
																			 BEGIN
																					UPDATE movctaaux
																						 SET iimport = iimport + v_iliqrea_tot_cia
																					 WHERE scontra = v_scontra
																						 AND nversio = v_nversio
																						 AND ctramo = v_ctramo
																						 AND ccompani = compa.ccompani
																						 AND cconcep = 15
																						 AND (sproduc = sini.sproduc OR NVL(sproduc, 0) = 0)
																						 AND NVL(ccompapr, 0) = NVL(sini.ccompapr, 0);
																			 EXCEPTION
																					WHEN OTHERS THEN
																						 nerr    := 105801;
																						 o_plsql := SQLERRM;
																						 p_tab_error(f_sysdate, f_user, vobj, v_traza,
																												 'Err UPDATE movctaaux - cconcep = 15',
																												 ' v_scontra=' || v_scontra || ' v_nversio=' ||
																													v_nversio || ' v_ctramo=' || v_ctramo ||
																													' compa.ccompani=' || compa.ccompani || ' SQLERRM = ' ||
																													SQLERRM);
																			 END;
																		END IF;
																 ELSE
																		v_traza := 24;
																 
																		IF v_iliqrea_tot_cia <> 0 THEN
																			 BEGIN
																					--(15)Liq actual XL (v_iliqrea_tot_cia)
																					p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete,
																													v_nom_funcion, NULL, 4984,
																													'Insert movctaaux (Concepto 15: Liquidac. XL)');
																			 
																					INSERT INTO movctaaux
																						 (ccompani, nversio, scontra, ctramo, nnumlin, fmovimi, fefecto,
																							cconcep, cdebhab, iimport, cestado, sproces, scesrea, cempres,
																							fcierre, sproduc, nsinies, ccompapr, ccorred) -- 25/05/2015  CJMR  0033158: Actualización campo CCORRED en los cierres de Reaseguro
																					VALUES
																						 (compa.ccompani, v_nversio, v_scontra, v_ctramo, w_nnumlin,
																							LAST_DAY(TO_DATE('01/' || sini.mes_sin || '/' || sini.anyo_sin,
																																'dd/mm/yyyy')), sini.fsin, 15, 1,
																							v_iliqrea_tot_cia, v_cestado, p_pproces, NULL, p_pcempres,
																							p_pfperfin, sini.sproduc, DECODE(NVL(w_ctadet, 0), 1, sini.nsin, 0),
																							sini.ccompapr, compa.ccorred); -- 25/05/2015  CJMR  0033158: Actualización campo CCORRED en los cierres de Reaseguro
																			 EXCEPTION
																					WHEN dup_val_on_index THEN
																						 nerr    := 105800;
																						 o_plsql := SQLERRM;
																						 p_tab_error(f_sysdate, f_user, vobj, v_traza,
																												 'Err INSERT movctaaux - cconcep = 15',
																												 ' v_scontra=' || v_scontra || ' v_nversio=' ||
																													v_nversio || ' v_ctramo=' || v_ctramo ||
																													' compa.ccompani=' || compa.ccompani || ' SQLERRM = ' ||
																													SQLERRM);
																					WHEN OTHERS THEN
																						 nerr    := 105802;
																						 o_plsql := SQLERRM;
																						 p_tab_error(f_sysdate, f_user, vobj, v_traza,
																												 'Err INSERT movctaaux - cconcep = 15',
																												 ' v_scontra=' || v_scontra || ' v_nversio=' ||
																													v_nversio || ' v_ctramo=' || v_ctramo ||
																													' compa.ccompani=' || compa.ccompani || ' SQLERRM = ' ||
																													SQLERRM);
																			 END;
																		END IF;
																 END IF;
															
																 --(4.e.iv.7.) Selecionamos el importe de reservas por contrato, versión, tramo, compañía (CCONCEP: 25)
																 --(4.e.iv.7.a.) Sumatorio (IREAREA) como CCONCEP: 25
																 IF NVL(w_ctadet, 0) = 1 THEN
																		SELECT COUNT(1)
																			INTO v_numero
																			FROM movctaaux
																		 WHERE scontra = v_scontra
																			 AND nversio = v_nversio
																			 AND ctramo = v_ctramo
																			 AND ccompani = compa.ccompani
																			 AND cconcep = 25
																			 AND (sproduc = sini.sproduc OR NVL(sproduc, 0) = 0)
																			 AND nsinies = sini.nsin;
																 ELSE
																		SELECT COUNT(1)
																			INTO v_numero
																			FROM movctaaux
																		 WHERE scontra = v_scontra
																			 AND nversio = v_nversio
																			 AND ctramo = v_ctramo
																			 AND ccompani = compa.ccompani
																			 AND cconcep = 25
																			 AND (sproduc = sini.sproduc OR NVL(sproduc, 0) = 0);
																 END IF;
															
																 v_iresrea_cia := v_iresnet * compa.pcesion / compa.pcesion;
															
																 IF v_numero > 0 THEN
																		v_traza := 25;
																 
																		IF NVL(w_ctadet, 0) = 1 THEN
																			 BEGIN
																					UPDATE movctaaux
																						 SET iimport = iimport + v_iresrea_cia
																					 WHERE scontra = v_scontra
																						 AND nversio = v_nversio
																						 AND ctramo = v_ctramo
																						 AND ccompani = compa.ccompani
																						 AND cconcep = 25
																						 AND (sproduc = sini.sproduc OR NVL(sproduc, 0) = 0)
																						 AND NVL(ccompapr, 0) = NVL(sini.ccompapr, 0)
																						 AND nsinies = sini.nsin;
																			 EXCEPTION
																					WHEN OTHERS THEN
																						 nerr    := 105801;
																						 o_plsql := SQLERRM;
																						 p_tab_error(f_sysdate, f_user, vobj, v_traza,
																												 'Err UPDATE movctaaux - cconcep = 25',
																												 ' v_scontra=' || v_scontra || ' v_nversio=' ||
																													v_nversio || ' v_ctramo=' || v_ctramo ||
																													' compa.ccompani=' || compa.ccompani || ' SQLERRM = ' ||
																													SQLERRM);
																			 END;
																		ELSE
																			 BEGIN
																					UPDATE movctaaux
																						 SET iimport = iimport + v_iresrea_cia
																					 WHERE scontra = v_scontra
																						 AND nversio = v_nversio
																						 AND ctramo = v_ctramo
																						 AND ccompani = compa.ccompani
																						 AND cconcep = 25
																						 AND NVL(ccompapr, 0) = NVL(sini.ccompapr, 0)
																						 AND (sproduc = sini.sproduc OR NVL(sproduc, 0) = 0);
																			 EXCEPTION
																					WHEN OTHERS THEN
																						 nerr    := 105801;
																						 o_plsql := SQLERRM;
																						 p_tab_error(f_sysdate, f_user, vobj, v_traza,
																												 'Err UPDATE movctaaux - cconcep = 25',
																												 ' v_scontra=' || v_scontra || ' v_nversio=' ||
																													v_nversio || ' v_ctramo=' || v_ctramo ||
																													' compa.ccompani=' || compa.ccompani || ' SQLERRM = ' ||
																													SQLERRM);
																			 END;
																		END IF;
																 ELSE
																		v_traza := 26;
																 
																		IF v_iresrea_cia <> 0 THEN
																			 BEGIN
																					--(25)Reserva siniestros (v_iresrea_cia)
																					p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete,
																													v_nom_funcion, NULL, 5119,
																													'Insert movctaaux (Concepto 25: Reservas Siniestros)');
																			 
																					INSERT INTO movctaaux
																						 (ccompani, nversio, scontra, ctramo, nnumlin, fmovimi, fefecto,
																							cconcep, cdebhab, iimport, cestado, sproces, scesrea, cempres,
																							fcierre, sproduc, nsinies, ccompapr, ccorred) -- 25/05/2015  CJMR  0033158: Actualización campo CCORRED en los cierres de Reaseguro
																					VALUES
																						 (compa.ccompani, v_nversio, v_scontra, v_ctramo, w_nnumlin,
																							LAST_DAY(TO_DATE('01/' || sini.mes_sin || '/' || sini.anyo_sin,
																																'dd/mm/yyyy')), sini.fsin, 25, 2, v_iresrea_cia,
																							v_cestado, p_pproces, NULL, p_pcempres, p_pfperfin, sini.sproduc,
																							DECODE(NVL(w_ctadet, 0), 1, sini.nsin, 0), sini.ccompapr,
																							compa.ccorred); -- 25/05/2015  CJMR  0033158: Actualización campo CCORRED en los cierres de Reaseguro
																			 EXCEPTION
																					WHEN dup_val_on_index THEN
																						 nerr    := 105800;
																						 o_plsql := SQLERRM;
																						 p_tab_error(f_sysdate, f_user, vobj, v_traza,
																												 'Err DUPLICA INSERT movctaaux - cconcep = 25',
																												 ' v_scontra=' || v_scontra || ' v_nversio=' ||
																													v_nversio || ' v_ctramo=' || v_ctramo ||
																													' compa.ccompani=' || compa.ccompani || ' SQLERRM = ' ||
																													SQLERRM);
																					WHEN OTHERS THEN
																						 nerr    := 105802;
																						 o_plsql := SQLERRM;
																						 p_tab_error(f_sysdate, f_user, vobj, v_traza,
																												 'Err INSERT movctaaux - cconcep = 25',
																												 ' v_scontra=' || v_scontra || ' v_nversio=' ||
																													v_nversio || ' v_ctramo=' || v_ctramo ||
																													' compa.ccompani=' || compa.ccompani || ' SQLERRM = ' ||
																													SQLERRM);
																			 END;
																		END IF;
																 END IF;
															END IF;
													 END LOOP; --Compañias
												
													 --KBR Multitramos y Reinstalaciones
													 IF NVL(pac_parametros.f_parempresa_n(p_pcempres, 'PERMITE_MREPOXL_REA'), 0) = 0 THEN
															EXIT;
													 END IF;
												END;
										 END LOOP; --Reestablecimientos
									
										 --KBR Multitramos y Reinstalaciones
										 IF NVL(pac_parametros.f_parempresa_n(p_pcempres, 'PERMITE_MTRAMOXL_REA'), 0) = 0 THEN
												EXIT;
										 END IF;
									END;
							 END LOOP; --Multitramos
						END IF;
				 
						--KBR 13/11/2013: Se incluye esta validacion para que el proceso no termine con error cuando no consiga contrato de reaseguro XL asociado
						--Se debe incluir un metodo para determinar cuando un ramo/producto está protegido por un contrato de reaseguro XL
						IF NVL(v_scontra, 0) = 0 THEN
							 nerr := 0;
						END IF;
				 
						COMMIT;
				 END IF;
			END LOOP;
	 
			p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL, 5182,
											'Fin de proceso: ' || nerr);
			RETURN(nerr);
	 END; --f_xl_siniestros

	 -----------------------------------
	 FUNCTION f_xl_eventos(p_pcempres IN NUMBER, p_pdefi IN NUMBER, p_pipc IN NUMBER, p_pmes IN NUMBER,
												 p_pany IN NUMBER, p_pfcierre IN DATE, p_pproces IN NUMBER, p_pscesrea OUT NUMBER,
												 p_pfperini IN DATE, p_pfperfin IN DATE, o_plsql OUT VARCHAR2) RETURN NUMBER IS
			CURSOR c_eventos(p_fechacorte IN DATE) IS
				 SELECT evto, cramo, SUM(isinret) totalevto_ret, SUM(ireserva) totalevto_res
					 FROM (SELECT DISTINCT s.cempres, s.ccompani ccompapr, s.sproduc, si.cevento evto, si.fsinies fsin,
																	si.fnotifi fnot, si.sseguro sseg, si.nriesgo nrie,
																	TO_CHAR(si.fsinies, 'mm') mes_sin, TO_CHAR(si.fsinies, 'yyyy') anyo_sin,
																	si.ncuacoa ncua, s.cramo cramo,
																	SUM(DECODE(NVL(ps.sidepag, 0), 0, 0,
																							DECODE(ps.ctippag, 8, NVL(pg.isinretpag, 0), 2, NVL(pg.isinretpag, 0),
																											NVL(-pg.isinretpag, 0)))) isinret, 0 ireserva
										FROM sin_tramita_pago ps, sin_siniestro si, sin_tramita_pago_gar pg, sin_tramita_movpago pm,
												 seguros s
									 WHERE ps.nsinies(+) = si.nsinies
										 AND si.sseguro = s.sseguro
										 AND EXISTS
									 (SELECT 1 FROM cesionesrea cr WHERE cr.sseguro = s.sseguro)
										 AND ps.sidepag = pg.sidepag(+)
										 AND ps.sidepag = pm.sidepag(+)
												-- Parámetro de empresa que especifíca el estado del pago para su tramitación
										 AND pm.cestpag = NVL(pac_parametros.f_parempresa_n(p_pcempres, 'EDO_PAGO_PROCESA_REA'), 2)
												-- No Anulaciones
										 AND NOT EXISTS (SELECT 1
														FROM sin_tramita_movpago pm2
													 WHERE pm2.sidepag = pm.sidepag
														 AND pm2.cestpag = 8)
												--
										 AND si.falta <= p_fechacorte
										 AND cempres = p_pcempres
										 AND si.cevento IS NOT NULL
									 GROUP BY s.cempres, s.ccompani, s.sproduc, si.cevento, si.fsinies, si.fnotifi, si.sseguro,
														si.nriesgo, TO_CHAR(si.fsinies, 'mm'), TO_CHAR(si.fsinies, 'yyyy'), si.ncuacoa, s.cramo
									UNION ALL
									SELECT DISTINCT s.cempres, s.ccompani ccompapr, s.sproduc, si.cevento evto, si.fsinies fsin,
																	si.fnotifi fnot, si.sseguro sseg, si.nriesgo nrie,
																	TO_CHAR(si.fsinies, 'mm') mes_sin, TO_CHAR(si.fsinies, 'yyyy') anyo_sin,
																	si.ncuacoa ncua, s.cramo cramo, 0 isinret,
																	NVL(sr.ireserva_moncia, 0) + (CASE
																																		WHEN NVL(sr.ipago_moncia, 0) < 0 THEN
																																		 0
																																		ELSE
																																		 NVL(sr.ipago_moncia, 0)
																																 END) ireserva
										FROM sin_siniestro si, seguros s, sin_tramita_reserva sr
									 WHERE si.sseguro = s.sseguro
										 AND EXISTS
									 (SELECT 1 FROM cesionesrea cr WHERE cr.sseguro = s.sseguro)
										 AND si.falta <= p_fechacorte
										 AND si.cevento IS NOT NULL
										 AND cempres = p_pcempres
										 AND si.nsinies = sr.nsinies
										 AND (NVL(ipago, 0) = 0 OR
												 sr.sidepag IN (SELECT sidepag
																					 FROM sin_tramita_movpago stm
																					WHERE stm.sidepag = sr.sidepag
																						AND stm.cestpag IN (0, 1, 8,
																																DECODE(NVL(pac_parametros.f_parempresa_n(p_pcempres,
																																																					'EDO_PAGO_PROCESA_REA'),
																																						2), 2, 9, 0))
																						AND stm.nmovpag IN (SELECT MAX(nmovpag)
																																	FROM sin_tramita_movpago stm2
																																 WHERE stm.sidepag = stm2.sidepag)))
										 AND sr.nmovres IN (SELECT MAX(nmovres)
																					FROM sin_tramita_reserva ss
																				 WHERE ss.nsinies = sr.nsinies
																					 AND sr.ntramit = ss.ntramit
																					 AND ss.ctipres = sr.ctipres
																					 AND ss.cgarant = sr.cgarant
																					 AND ss.sidepag = sr.sidepag
																					 AND NVL(ss.ctipgas, 0) = NVL(sr.ctipgas, 0)
																					 AND ss.fmovres <= p_fechacorte
																				UNION
																				SELECT MAX(nmovres)
																					FROM sin_tramita_reserva ss
																				 WHERE ss.nsinies = sr.nsinies
																					 AND sr.ntramit = ss.ntramit
																					 AND ss.ctipres = sr.ctipres
																					 AND ss.cgarant = sr.cgarant
																					 AND NVL(ss.ctipgas, 0) = NVL(sr.ctipgas, 0)
																					 AND ss.fmovres <= p_fechacorte)
									 GROUP BY s.cempres, s.ccompani, s.sproduc, si.cevento, si.fsinies, si.fnotifi, si.sseguro,
														si.nriesgo, TO_CHAR(si.fsinies, 'mm'), TO_CHAR(si.fsinies, 'yyyy'), si.ncuacoa, s.cramo,
														NVL(sr.ireserva_moncia, 0) + (CASE
																															WHEN NVL(sr.ipago_moncia, 0) < 0 THEN
																															 0
																															ELSE
																															 NVL(sr.ipago_moncia, 0)
																													 END))
					GROUP BY evto, cramo
					ORDER BY evto;
	 
			CURSOR c_sinevtos_det(p_pcevento IN VARCHAR2, p_pcramo IN NUMBER, p_fechacorte IN DATE) IS
				 SELECT sproduc, ccompapr, nsin, fsin, fnot, ctipres, mes_pag, anyo_pag, sseg, nrie, mes_sin, anyo_sin,
								ncua, cramo, cgar, ctippag, SUM(ireserva) totireserva, SUM(isinpag) totisinpag
					 FROM (SELECT DISTINCT s.sproduc, s.ccompani ccompapr, si.nsinies nsin, si.fsinies fsin, si.fnotifi fnot,
																	ps.sidepag, sr.ctipres, TO_CHAR(pm.fefepag, 'mm') mes_pag,
																	TO_CHAR(pm.fefepag, 'yyyy') anyo_pag, si.sseguro sseg, si.nriesgo nrie,
																	TO_CHAR(si.fsinies, 'mm') mes_sin, TO_CHAR(si.fsinies, 'yyyy') anyo_sin,
																	si.ncuacoa ncua, sr.cgarant cgar, s.cramo cramo, ps.ctippag,
																	NVL(sr.ireserva_moncia, 0) ireserva,
																	SUM(NVL(ps.isinretpag, 0) + NVL(ps.isuplidpag, 0)) isinpag
										FROM sin_tramita_pago ps, sin_siniestro si, sin_tramita_movpago pm, seguros s,
												 sin_tramita_reserva sr, garanpro gp
									 WHERE ps.nsinies = si.nsinies
										 AND si.cevento = p_pcevento
										 AND si.sseguro = s.sseguro
										 AND ps.sidepag = sr.sidepag
										 AND ps.sidepag = pm.sidepag
										 AND pm.cestpag = NVL(pac_parametros.f_parempresa_n(p_pcempres, 'EDO_PAGO_PROCESA_REA'), 2)
												-- No Anulaciones
										 AND NOT EXISTS (SELECT 1
														FROM sin_tramita_movpago pm2
													 WHERE pm2.sidepag = pm.sidepag
														 AND pm2.cestpag = 8)
												--
										 AND si.falta <= p_fechacorte
										 AND cempres = p_pcempres
										 AND si.nsinies = sr.nsinies
										 AND ps.ntramit = sr.ntramit
										 AND gp.sproduc = s.sproduc
										 AND gp.cgarant = sr.cgarant
										 AND gp.cactivi = NVL(s.cactivi, 0)
										 AND gp.creaseg IN (1, 2)
										 AND s.cramo = p_pcramo
										 AND sr.nmovres IN (SELECT MAX(nmovres)
																					FROM sin_tramita_reserva ss
																				 WHERE ss.nsinies = sr.nsinies
																					 AND sr.ntramit = ss.ntramit
																					 AND ss.ctipres = sr.ctipres
																					 AND ss.cgarant = sr.cgarant
																					 AND NVL(ss.ctipgas, 0) = NVL(sr.ctipgas, 0)
																					 AND ss.fmovres <= p_fechacorte)
									 GROUP BY s.sproduc, s.ccompani, si.nsinies, si.fsinies, si.fnotifi, ps.sidepag, sr.ctipres,
														TO_CHAR(pm.fefepag, 'mm'), TO_CHAR(pm.fefepag, 'yyyy'), si.sseguro, si.nriesgo,
														TO_CHAR(si.fsinies, 'mm'), TO_CHAR(si.fsinies, 'yyyy'), si.ncuacoa, sr.cgarant, s.cramo,
														ps.ctippag, NVL(sr.ireserva_moncia, 0)
									UNION ALL
									SELECT DISTINCT s.sproduc, s.ccompani ccompapr, si.nsinies nsin, si.fsinies fsin, si.fnotifi fnot,
																	0 sidepag, sr.ctipres, TO_CHAR(p_pfperfin, 'mm') mes_pag,
																	TO_CHAR(p_pfperfin, 'yyyy') anyo_pag, si.sseguro sseg, si.nriesgo nrie,
																	TO_CHAR(si.fsinies, 'mm') mes_sin, TO_CHAR(si.fsinies, 'yyyy') anyo_sin,
																	si.ncuacoa ncua, sr.cgarant cgar, s.cramo cramo, 0 ctippag,
																	NVL(sr.ireserva_moncia, 0) + (CASE
																																		WHEN NVL(sr.ipago_moncia, 0) < 0 THEN
																																		 0
																																		ELSE
																																		 NVL(sr.ipago_moncia, 0)
																																 END) ireserva, 0 isinpag
										FROM sin_siniestro si, seguros s, sin_tramita_reserva sr, garanpro gp
									 WHERE si.sseguro = s.sseguro
										 AND si.cevento = p_pcevento
										 AND si.falta <= p_fechacorte
										 AND cempres = p_pcempres
										 AND si.nsinies = sr.nsinies
										 AND gp.sproduc = s.sproduc
										 AND gp.cgarant = sr.cgarant
										 AND gp.cactivi = NVL(s.cactivi, 0)
										 AND gp.creaseg IN (1, 2)
										 AND s.cramo = p_pcramo
										 AND (NVL(ipago, 0) = 0 OR
												 sr.sidepag IN (SELECT sidepag
																					 FROM sin_tramita_movpago stm
																					WHERE stm.sidepag = sr.sidepag
																						AND stm.cestpag IN (0, 1, 8,
																																DECODE(NVL(pac_parametros.f_parempresa_n(p_pcempres,
																																																					'EDO_PAGO_PROCESA_REA'),
																																						2), 2, 9, 0))
																						AND stm.nmovpag IN (SELECT MAX(nmovpag)
																																	FROM sin_tramita_movpago stm2
																																 WHERE stm.sidepag = stm2.sidepag)))
										 AND sr.nmovres IN (SELECT MAX(nmovres)
																					FROM sin_tramita_reserva ss
																				 WHERE ss.nsinies = sr.nsinies
																					 AND sr.ntramit = ss.ntramit
																					 AND ss.ctipres = sr.ctipres
																					 AND ss.cgarant = sr.cgarant
																					 AND ss.sidepag = sr.sidepag
																					 AND NVL(ss.ctipgas, 0) = NVL(sr.ctipgas, 0)
																					 AND ss.fmovres <= p_fechacorte
																				UNION
																				SELECT MAX(nmovres)
																					FROM sin_tramita_reserva ss
																				 WHERE ss.nsinies = sr.nsinies
																					 AND sr.ntramit = ss.ntramit
																					 AND ss.ctipres = sr.ctipres
																					 AND ss.cgarant = sr.cgarant
																					 AND NVL(ss.ctipgas, 0) = NVL(sr.ctipgas, 0)
																					 AND ss.fmovres <= p_fechacorte)
										 AND NVL(sr.ireserva_moncia, 0) + NVL(sr.ipago_moncia, 0) <> 0
										 AND NOT EXISTS
									 (SELECT 1
														FROM sin_tramita_reserva tt, sin_tramita_movpago pp
													 WHERE tt.nsinies = sr.nsinies
														 AND tt.cgarant = sr.cgarant
														 AND NVL(tt.ctipgas, 0) = NVL(sr.ctipgas, 0)
														 AND pp.sidepag = tt.sidepag
														 AND pp.cestpag =
																 NVL(pac_parametros.f_parempresa_n(p_pcempres, 'EDO_PAGO_PROCESA_REA'), 2)
														 AND tt.fmovres <= p_fechacorte
														 AND NOT EXISTS (SELECT 1
																		FROM sin_tramita_movpago pm2
																	 WHERE pm2.sidepag = pp.sidepag
																		 AND pm2.cestpag = 8))
									 GROUP BY s.sproduc, s.ccompani, si.nsinies, si.fsinies, si.fnotifi, sr.ctipres,
														TO_CHAR(p_pfperfin, 'mm'), TO_CHAR(p_pfperfin, 'yyyy'), si.sseguro, si.nriesgo,
														TO_CHAR(si.fsinies, 'mm'), TO_CHAR(si.fsinies, 'yyyy'), si.ncuacoa, sr.cgarant, s.cramo,
														NVL(sr.ireserva_moncia, 0) + (CASE
																															WHEN NVL(sr.ipago_moncia, 0) < 0 THEN
																															 0
																															ELSE
																															 NVL(sr.ipago_moncia, 0)
																													 END))
					GROUP BY sproduc, ccompapr, nsin, fsin, fnot, ctipres, mes_pag, anyo_pag, sseg, nrie, mes_sin, anyo_sin,
									 ncua, cramo, cgar, ctippag
					ORDER BY nsin, mes_pag, anyo_pag;
	 
			CURSOR c_cuadroces_agr(ctr NUMBER, ver NUMBER, tram NUMBER) IS
				 SELECT c.ccompani, c.ctramo, c.iagrega, c.imaxagr, c.pcesion, ct.fconini, 0 iminagr, ccorred
					 FROM cuadroces c, contratos ct
					WHERE c.scontra = ct.scontra
						AND c.nversio = ct.nversio
						AND c.scontra = ctr
						AND c.nversio = ver
						AND c.ctramo = tram
						AND c.ccompani > 1;
	 
			vobj               VARCHAR2(200) := 'PAC_REASEGURO_XL.f_xl_eventos';
			nerr               NUMBER := 0;
			pnnumlin           NUMBER;
			texto              VARCHAR2(200);
			num_impliq         NUMBER;
			v_ipleno           contratos.iretenc%TYPE;
			v_icapaci          contratos.icapaci%TYPE;
			v_iprioxl_ctto     contratos.iprioxl%TYPE;
			v_iprioxl_tramo    tramos.ixlprio%TYPE;
			v_caplixl          tramos.caplixl%TYPE;
			v_ixlprio          tramos.ixlprio%TYPE;
			v_imaxagr          NUMBER;
			v_iminagr          NUMBER;
			v_plimgas          tramos.plimgas%TYPE;
			v_pliminx          NUMBER;
			v_pago_indexado    liquidareaxl_aux.itotind%TYPE;
			v_pago_no_indexado liquidareaxl_aux.itotexp%TYPE;
			v_ireserv          liquidareaxl_aux.ireserv%TYPE := 0;
			v_pcuorea          liquidareaxl_aux.pcuorea%TYPE;
			v_icuorea          liquidareaxl_aux.icuorea%TYPE;
			v_pcuotot          liquidareaxl_aux.pcuotot%TYPE;
			v_itotrea          liquidareaxl_aux.itotrea%TYPE;
			v_iresrea          liquidareaxl_aux.iresrea%TYPE;
			w_nnumlin          NUMBER;
			v_ipagrea          liquidareaxl_aux.ipagrea%TYPE;
			v_cestado_cia      NUMBER;
			v_supera           NUMBER;
			v_traza            NUMBER;
			v_cdetces          NUMBER;
			--Monedas
			v_cmultimon  parempresas.nvalpar%TYPE := NVL(pac_parametros.f_parempresa_n(p_pcempres, 'MULTIMONEDA'), 0);
			v_cmoncontab parempresas.nvalpar%TYPE := pac_parametros.f_parempresa_n(p_pcempres, 'MONEDACONTAB');
			v_itasa      eco_tipocambio.itasa%TYPE;
			v_fcambio    DATE;
			----------
			--Reservas
			v_iresgas_tot   liquidareaxl_aux.iresgas%TYPE;
			v_iresgas       liquidareaxl_aux.iresgas%TYPE;
			v_iresindem_tot liquidareaxl_aux.iresindem%TYPE;
			v_iresindem     liquidareaxl_aux.iresindem%TYPE;
			v_iresinter_tot liquidareaxl_aux.iresinter%TYPE;
			v_iresinter     liquidareaxl_aux.iresinter%TYPE;
			v_iresadmin_tot liquidareaxl_aux.iresadmin%TYPE;
			v_iresadmin     liquidareaxl_aux.iresadmin%TYPE;
			----------
			v_hiha_cessio NUMBER(1);
			v_plocal      NUMBER;
			w_ctadet      NUMBER(1);
			--Contrato/Producto
			v_scontra NUMBER;
			v_nversio NUMBER;
			v_ctramo  NUMBER;
			v_cmodali seguros.cmodali%TYPE;
			v_ctipseg seguros.ctipseg%TYPE;
			v_ccolect seguros.ccolect%TYPE;
			v_cactivi seguros.cactivi%TYPE;
			----------
			v_c_gar    NUMBER;
			v_res_dist NUMBER;
			-------
			v_pago_idx       NUMBER;
			v_pago_no_idx    NUMBER;
			v_reserva        NUMBER;
			v_reserva_ret    NUMBER;
			v_ipagced_xl     NUMBER;
			v_iresced_xl     NUMBER;
			v_presrea        NUMBER;
			v_totalpagos_ret NUMBER;
			v_contador       NUMBER;
			v_sin            NUMBER;
			v_fsin           DATE;
			v_evto           VARCHAR2(20);
			v_sproduc        NUMBER;
			v_ccompapr       NUMBER;
			v_iliqrea_sin    NUMBER;
			v_iresrea_sin    NUMBER;
			v_movsin         t_registro := t_registro();
			v_reserva_mat    NUMBER;
			v_moneda_prod    productos.cdivisa%TYPE;
			v_itasa_prod     eco_tipocambio.itasa%TYPE;
			v_fcambio_prod   DATE;
			v_totrea_evto    NUMBER;
			v_iced_xl        NUMBER;
			v_prea           NUMBER;
			---
			v_itottra          tramos.itottra%TYPE;
			v_nrepos           NUMBER;
			v_ipmd             tramos.ipmd%TYPE;
			v_crepos           tramos.crepos%TYPE;
			v_nro_repos        NUMBER;
			inicio             NUMBER;
			v_preest           tramos.preest%TYPE;
			v_primareest       NUMBER;
			v_primareest_sin   NUMBER;
			v_ixlcapaci        contratos.icapaci%TYPE;
			v_mov_res          NUMBER;
			v_mov_pag          NUMBER;
			v_reserva_anterior NUMBER := 0;
			v_pagos_anterior   NUMBER := 0;
			v_iresrea_mov      NUMBER := 0;
			v_ipagrea_mov      NUMBER := 0;
			v_nom_paquete      VARCHAR2(80) := 'PAC_REASEGURO_XL';
			v_nom_funcion      VARCHAR2(80) := 'F_XL_EVENTOS';
			v_porc_tramo_ramo  NUMBER;
			v_cramo            productos.cramo%TYPE;
			v_temp_pagos_ret   NUMBER := 0;
			v_temp_totrea_evto NUMBER := 0;
			v_ixlprio_ant      NUMBER := 0;
			v_total_ant        NUMBER := 0;
			v_total_res_tramos NUMBER := 0;
			v_total_pag_tramos NUMBER := 0;
			v_fechacorte       DATE;
	 BEGIN
			v_traza      := 1;
			v_fechacorte := p_pfcierre; -- KBR 27/11/2014 Cambiamos por fecha de cierre
			-- Comptes a nivell de sinistres
			p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL, 5570,
											'Inicio de proceso');
			w_ctadet := pac_parametros.f_parempresa_n(p_pcempres, 'CTACES_DET');
	 
			----------------------------------------------------------------------------
			--     1. inicializamos el IAGREAGA de cuadroces para todas las compañias --
			----------------------------------------------------------------------------
			BEGIN
				 UPDATE cuadroces
						SET iagrega = 0
					WHERE scontra IN (SELECT scontra FROM codicontratos WHERE ctiprea = 3); -- XL
			EXCEPTION
				 WHEN OTHERS THEN
						nerr := 1;
						p_tab_error(f_sysdate, f_user, vobj, v_traza, 'Err UPDATE cuadroces', ' SQLERRM = ' || SQLERRM);
			END;
	 
			-- INICIALIZAR IMPORTES POR EXPDTE:
			v_iprioxl_ctto  := 0;
			v_iprioxl_tramo := 0;
			v_iresgas_tot   := 0;
			v_iresgas       := 0;
			v_iresrea       := 0;
			v_ireserv       := 0;
			v_iresindem_tot := 0;
			v_iresindem     := 0;
			v_iresinter_tot := 0;
			v_iresinter     := 0;
			v_iresadmin_tot := 0;
			v_iresadmin     := 0;
			v_c_gar         := 0;
			------
			v_reserva_ret    := 0;
			v_iresced_xl     := 0;
			v_presrea        := 0;
			v_totalpagos_ret := 0;
			v_evto           := '0';
			v_sin            := 0;
			v_contador       := 0;
			v_res_dist       := 0;
			v_pago_idx       := 0;
			v_pago_no_idx    := 0;
			v_reserva        := 0;
			v_iliqrea_sin    := 0;
			v_iresrea_sin    := 0;
			v_totrea_evto    := 0;
			v_iced_xl        := 0;
			v_prea           := 0;
			----
			v_itottra         := 0;
			v_nrepos          := 0;
			v_ipmd            := 0;
			v_crepos          := 0;
			v_nro_repos       := 0;
			inicio            := 0;
			v_preest          := 0;
			v_porc_tramo_ramo := 100;
	 
			--Cursor que retorna eventos totalizados por ramo en un período determinado
			FOR evto IN c_eventos(v_fechacorte) LOOP
				 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL, 5632,
												 'Evaluando evento: ' || evto.evto);
			
				 IF v_evto = '0' THEN
						v_evto := evto.evto;
				 ELSE
						IF v_evto <> evto.evto THEN
							 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL, 5638,
															 'Cambia de evento, guarda datos en tablas y deja persistente evento: ' || v_evto);
							 --Limites de Pago
							 v_totalpagos_ret := v_pago_idx;
							 v_ctramo         := 5; --Facultativo y empezamos a validar a partir del primer tramo XL
							 v_reserva_ret    := v_reserva;
							 v_ixlprio_ant    := 0;
						
							 LOOP
									--LOOP de Multitramos
									BEGIN
										 v_ctramo := v_ctramo + 1;
									
										 IF v_totrea_evto = 0 OR
												NVL(pac_parametros.f_parempresa_n(p_pcempres, 'MAX_MTRAMOSXL_REA'), 6) < v_ctramo OR
												v_scontra IS NULL THEN
												EXIT;
										 END IF;
									
										 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL, 5656,
																		 'Evaluando Tramo: ' || v_ctramo || ' Producto: ' || v_sproduc);
									
										 BEGIN
												SELECT ct.porcen
													INTO v_porc_tramo_ramo
													FROM ctto_tramo_producto ct
												 WHERE ct.ctramo = v_ctramo
													 AND ct.scontra = v_scontra
													 AND ct.nversio = v_nversio
													 AND ct.cramo = evto.cramo;
										 EXCEPTION
												WHEN no_data_found THEN
													 v_porc_tramo_ramo := 100;
												WHEN too_many_rows THEN
													 BEGIN
															SELECT ct.porcen
																INTO v_porc_tramo_ramo
																FROM ctto_tramo_producto ct
															 WHERE ct.ctramo = v_ctramo
																 AND ct.scontra = v_scontra
																 AND ct.nversio = v_nversio
																 AND ct.cramo = evto.cramo
																 AND ct.sproduc = v_sproduc;
													 EXCEPTION
															WHEN no_data_found THEN
																 v_porc_tramo_ramo := 100;
															WHEN OTHERS THEN
																 v_porc_tramo_ramo := 100;
													 END;
												WHEN OTHERS THEN
													 v_porc_tramo_ramo := 100;
										 END;
									
										 IF v_porc_tramo_ramo > 0 THEN
												--Obtenemos datos de Contrato y Tramo para Multitramos
												SELECT caplixl, ixlprio, pliminx, plimgas, itottra, icapaci, iprioxl, ipmd,
															 NVL(crepos, 0), preest
													INTO v_caplixl, v_iprioxl_tramo, v_pliminx, v_plimgas, v_itottra, v_icapaci,
															 v_iprioxl_ctto, v_ipmd, v_crepos, v_preest
													FROM tramos tt, contratos cc
												 WHERE cc.scontra = v_scontra
													 AND cc.nversio = v_nversio
													 AND cc.scontra = tt.scontra(+)
													 AND cc.nversio = tt.nversio(+)
													 AND tt.ctramo(+) = v_ctramo;
										 
												--Obtenemos número de reestablecimientos del tramo
												SELECT COUNT(norden) INTO v_nro_repos FROM reposiciones_det WHERE ccodigo = v_crepos;
										 
												IF v_nro_repos = 0 THEN
													 inicio := 0;
												ELSE
													 inicio := 1;
												END IF;
										 
												p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL,
																				5684, 'Reposiciones del tramo: ' || v_nro_repos);
												v_primareest := 0;
										 
												--v_movsin(sini).ctramo := v_ctramo;
										 
												--Si no existe capacidad del tramo tomamos la del contrato y su prioridad
												IF v_iprioxl_tramo IS NULL THEN
													 v_ixlprio   := NVL(v_iprioxl_ctto, 0);
													 v_ixlcapaci := v_icapaci - v_ixlprio;
												ELSE
													 v_ixlprio   := v_iprioxl_tramo;
													 v_ixlcapaci := v_itottra;
												END IF;
										 
												IF v_ixlprio_ant = 0 THEN
													 v_ixlprio_ant := v_ixlprio;
												ELSE
													 v_ixlprio := v_ixlprio_ant;
												END IF;
										 
												p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL,
																				5700, 'Capacidad: ' || v_ixlcapaci || ' Prioridad: ' || v_ixlprio);
										 
												--Si tenemos el porcentaje de aumento por gastos en el contrato
												--Calculamos el nuevo límite aumentándolo según el procentaje definido en el contrato (PLIMGAS).
												IF NVL(v_plimgas, 0) <> 0 THEN
													 v_ixlprio := v_ixlprio * (100 + v_plimgas) / 100;
												END IF;
										 
												FOR i_rep IN inicio .. v_nro_repos LOOP
													 --LOOP de Reestablecimientos
													 BEGIN
															p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion,
																							NULL, 5712, 'Importe Total Evento: ' || v_totrea_evto);
													 
															IF v_totrea_evto = 0 OR
																 NVL(pac_parametros.f_parempresa_n(p_pcempres, 'MAX_MREPOSXL_REA'), v_nro_repos) <
																 i_rep THEN
																 EXIT;
															END IF;
													 
															IF (v_totalpagos_ret - v_ixlprio) > 0 THEN
																 IF (v_totalpagos_ret - v_ixlprio) < v_ixlcapaci THEN
																		--Importe pagado cedido xl (Total Pagos - Prioridad)
																		v_ipagced_xl := v_totalpagos_ret - v_ixlprio;
																		v_pcuorea    := ROUND((v_ipagced_xl / v_totalpagos_ret) * 100, 5);
																		--variable temporal
																		v_temp_pagos_ret := v_totalpagos_ret;
																		--No existen más pagos a ceder al XL
																		v_totalpagos_ret := 0;
																 ELSE
																		v_ipagced_xl := v_ixlcapaci;
																		v_pcuorea    := ROUND((v_ipagced_xl / v_totalpagos_ret) * 100, 5);
																		--variable temporal
																		v_temp_pagos_ret := v_totalpagos_ret;
																		--Recalculamos los pagos totales para el próximo reinstalamiento/tramo
																		v_totalpagos_ret := v_totalpagos_ret - v_ipagced_xl;
																 END IF;
															
																 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion,
																								 NULL, 5735,
																								 'Pagos Ced XL: ' || v_ipagced_xl || ' % Pagos al XL: ' ||
																									v_pcuorea || ' Total Pagos Ret: ' || v_totalpagos_ret);
															
																 --Calculamos la prima de reestablecimiento
																 IF i_rep <> 0 THEN
																		--pr=(pmd*pagos cedidos xl de la capa/ capacidad de la capa)* %reestablecimiento;
																		v_primareest := (v_ipmd * v_ipagced_xl / v_ixlcapaci) * v_preest / 100;
																 END IF;
															
																 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion,
																								 NULL, 5749, 'Prima Reest.: ' || v_primareest);
															ELSE
																 v_ipagced_xl := 0;
																 v_pcuorea    := 0;
																 --No existen más pagos a ceder al XL
																 v_totalpagos_ret := 0;
																 --variable temporal
																 v_temp_pagos_ret := v_totalpagos_ret;
																 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion,
																								 NULL, 5757, 'No existen pagos a ceder al XL');
															END IF;
													 
															--Limite de Reserva
															IF (v_totrea_evto - v_ixlprio) > 0 THEN
																 IF (v_totrea_evto - v_ixlprio) < v_ixlcapaci THEN
																		--Importe pagado cedido xl ((Total Pagos + Total Reservas)- Prioridad)
																		v_iced_xl := v_totrea_evto - v_ixlprio;
																		v_prea    := (v_iced_xl / v_totrea_evto) * 100;
																		--variable temporal
																		v_temp_totrea_evto := v_totrea_evto;
																		v_totrea_evto      := 0;
																 ELSE
																		v_iced_xl := v_ixlcapaci;
																		v_prea    := (v_iced_xl / v_totrea_evto) * 100;
																		--variable temporal
																		v_temp_totrea_evto := v_totrea_evto;
																		--Recalculamos el importe total para el próximo reinstalamiento/tramo
																		v_totrea_evto := v_totrea_evto - v_ixlcapaci;
																 END IF;
															
																 v_prea := ROUND(v_prea, 5);
																 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion,
																								 NULL, 5776,
																								 'Total Ced XL: ' || v_iced_xl || ' % Total XL: ' || v_prea ||
																									' Total Evento: ' || v_totrea_evto);
																 --Reserva
																 v_iresced_xl := v_iced_xl - v_ipagced_xl;
															
																 --KBR 08052014
																 IF NVL(pac_parametros.f_parempresa_n(p_pcempres, 'MANEJO_RESERVAXL_REA'), 0) = 1 THEN
																		IF v_prea < v_pcuorea THEN
																			 v_presrea := 0;
																		ELSE
																			 v_presrea := 1;
																		END IF;
																 ELSE
																		v_presrea := v_prea - v_pcuorea;
																 END IF;
															
																 --Fin KBR 08052014
																 v_presrea := ROUND(v_presrea, 5);
																 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion,
																								 NULL, 5783,
																								 'Reserva Ced XL: ' || v_iresced_xl || ' % Reserva XL: ' ||
																									v_presrea || ' Total Evento: ' || v_totrea_evto);
															ELSE
																 v_iced_xl     := 0;
																 v_prea        := 0;
																 v_totrea_evto := 0;
																 --variable temporal
																 v_temp_totrea_evto := v_totrea_evto;
															END IF;
													 
															--Buscamos el importe de reserva anterior para obtener el movimiento XL de reserva =
															--Valor Reserva XL actual menos valor Reserva XL anterior
															BEGIN
																 SELECT NVL(SUM(iresnet), 0)
																	 INTO v_reserva_anterior
																	 FROM liquidareaxl
																	WHERE cevento = v_evto
																		AND fcierre = ADD_MONTHS(fcierre, -1);
															END;
													 
															p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion,
																							NULL, 5804,
																							'Reserva anterior del evento Ced XL: ' || v_reserva_anterior);
															v_iresrea_mov := v_iresced_xl - v_reserva_anterior;
															p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion,
																							NULL, 5809, 'Reserva Ced XL (Mov): ' || v_iresrea_mov);
													 
															--Buscamos el importe de pagos anterior para obtener el movimiento XL de pagos =
															--Valor Pagos XL actual menos valor Pagos XL anterior
															BEGIN
																 SELECT NVL(SUM(iliqnet), 0)
																	 INTO v_pagos_anterior
																	 FROM liquidareaxl
																	WHERE cevento = v_evto
																		AND fcierre = ADD_MONTHS(fcierre, -1);
															END;
													 
															p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion,
																							NULL, 5823, 'Pago anterior del evento Ced XL: ' || v_pagos_anterior);
															v_ipagrea_mov := v_ipagced_xl - v_pagos_anterior;
															p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion,
																							NULL, 5827, 'Pago Ced XL (Mov): ' || v_ipagrea_mov);
													 
															IF v_iresced_xl <> 0 OR v_ipagced_xl <> 0 THEN
																 --Para cada siniestro
																 FOR sini IN 1 .. v_contador LOOP
																		p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete,
																										v_nom_funcion, NULL, 5836,
																										'Evaluando siniestro: ' || v_movsin(sini).nsinies);
																		v_total_pag_tramos := 0;
																		v_total_res_tramos := 0;
																 
																		FOR compa IN c_cuadroces_agr(v_movsin(sini).scontra, v_movsin(sini).nversio,
																																 v_ctramo) LOOP
																			 IF v_cmultimon = 1 THEN
																					nerr := pac_oper_monedas.f_datos_contraval(NULL, NULL,
																																										 v_movsin(sini).scontra,
																																										 v_movsin(sini).fsinies, 3,
																																										 v_itasa, v_fcambio);
																			 
																					IF nerr <> 0 THEN
																						 o_plsql    := SQLERRM;
																						 p_pscesrea := TO_NUMBER(TO_CHAR(v_movsin(sini).scontra) ||
																																		 TO_CHAR(v_movsin(sini).nversio) ||
																																		 TO_CHAR(v_ctramo) ||
																																		 TO_CHAR(compa.ccompani));
																					END IF;
																			 END IF;
																		
																			 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete,
																											 v_nom_funcion, NULL, 5862,
																											 'Compañía: ' || compa.ccompani || ' % Part: ' ||
																												compa.pcesion);
																			 --v_prea corresponde con el % de prioridad del EVENTO
																			 v_icuorea   := v_ipagced_xl * compa.pcesion / 100;
																			 v_iresrea   := v_iresced_xl * compa.pcesion / 100;
																			 v_itotrea   := v_icuorea + v_iresrea;
																			 v_iresgas   := v_iresgas_tot * v_prea / 100 * compa.pcesion / 100;
																			 v_iresindem := v_iresindem_tot * v_prea / 100 * compa.pcesion / 100;
																			 v_iresinter := v_iresinter_tot * v_prea / 100 * compa.pcesion / 100;
																			 v_iresadmin := v_iresadmin_tot * v_prea / 100 * compa.pcesion / 100;
																		
																			 IF v_temp_pagos_ret = 0 THEN
																					v_iliqrea_sin    := 0;
																					v_primareest_sin := 0;
																			 ELSE
																					v_iliqrea_sin := ((v_movsin(sini)
																													 .pago_total_sin * v_ipagced_xl / v_temp_pagos_ret)) *
																													 compa.pcesion / 100;
																					--pr=(pmd*pagos cedidos xl de la capa/ capacidad de la capa)* %reestablecimiento;
																					v_primareest_sin := (v_ipmd * v_iliqrea_sin / v_ixlcapaci) * v_preest / 100;
																					p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete,
																													v_nom_funcion, NULL, 6621,
																													'Prima Reest. x Sin: ' || v_primareest_sin);
																			 END IF;
																		
																			 IF v_ipagced_xl = v_iced_xl THEN
																					v_iresrea_sin := 0;
																			 ELSE
																					IF v_temp_totrea_evto = 0 THEN
																						 v_iresrea_sin := 0;
																					ELSE
																						 --KBR 08052014
																						 IF NVL(pac_parametros.f_parempresa_n(p_pcempres,
																																									'MANEJO_RESERVAXL_REA'), 0) = 1 THEN
																								IF v_ipagced_xl = 0 THEN
																									 v_iresrea_sin := ((((v_movsin(sini).pago_total_sin + v_movsin(sini)
																																		.reserva_total_sin) * v_iced_xl /
																																		v_temp_totrea_evto)) * compa.pcesion / 100) -
																																		v_iliqrea_sin;
																								ELSE
																									 v_iresrea_sin := v_movsin(sini)
																																		.reserva_total_sin * compa.pcesion / 100;
																								END IF;
																						 ELSE
																								v_iresrea_sin := ((((v_movsin(sini).pago_total_sin + v_movsin(sini)
																																 .reserva_total_sin) * v_iced_xl /
																																 v_temp_totrea_evto)) * compa.pcesion / 100) -
																																 v_iliqrea_sin;
																						 END IF;
																						 --Fin KBR 08052014
																					END IF;
																			 END IF;
																		
																			 v_total_pag_tramos := v_total_pag_tramos + v_iliqrea_sin;
																			 v_total_res_tramos := v_total_res_tramos + v_iresrea_sin;
																			 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete,
																											 v_nom_funcion, NULL, 5888,
																											 'Pago Cia: ' || v_iliqrea_sin || ' Reserva Cia: ' ||
																												v_iresrea_sin);
																		
																			 BEGIN
																					SELECT NVL(cestado, 1)
																						INTO v_cestado_cia
																						FROM ctatecnica
																					 WHERE scontra = v_movsin(sini).scontra
																						 AND nversio = v_movsin(sini).nversio
																						 AND ctramo = v_ctramo
																						 AND ccompani = compa.ccompani
																						 AND sproduc = v_movsin(sini).sproduc;
																			 EXCEPTION
																					WHEN no_data_found THEN
																						 BEGIN
																								INSERT INTO ctatecnica
																									 (ccompani, nversio, scontra, ctramo, nctatec, cfrecul,
																										cestado, festado, fcierre, cempres, sproduc, ccorred)
																								VALUES
																									 (compa.ccompani, v_movsin(sini).nversio,
																										v_movsin(sini).scontra, v_ctramo, 1, 3, 1, NULL, NULL,
																										p_pcempres, v_movsin(sini).sproduc, compa.ccorred);
																						 EXCEPTION
																								WHEN OTHERS THEN
																									 v_cestado_cia := 1;
																									 p_tab_error(f_sysdate, f_user, vobj, v_traza,
																															 'XL por Eventos: Err INSERT INTO ctatecnica',
																															 ' SQLERRM = ' || SQLERRM || ' nerr = 104861');
																						 END;
																					WHEN OTHERS THEN
																						 v_cestado_cia := 1;
																						 o_plsql       := SQLERRM;
																						 p_tab_error(f_sysdate, f_user, vobj, v_traza,
																												 'XL por Eventos: Err SELECT ctatecnica',
																												 ' v_scontra=' || v_movsin(sini).scontra ||
																													' v_nversio=' || v_movsin(sini).nversio || ' v_ctramo=' ||
																													v_ctramo || ' compa.ccompani=' || compa.ccompani ||
																													' SQLERRM = ' || SQLERRM || ' nerr = 104863');
																			 END;
																		
																			 --Insert en LiquidareaXL
																			 BEGIN
																					p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete,
																													v_nom_funcion, NULL, 5946,
																													'Insertando en Liquidareaxl_aux');
																			 
																					INSERT INTO liquidareaxl_aux
																						 (nsinies, fsinies, itotexp, fcierre, sproces, scontra, nversio,
																							ctramo, ccompani, pcuorea, icuorea, ipagrea, iliqrea, ireserv,
																							pcuotot, itotrea, iresrea, iliqnet, iresnet, iresgas, iresindem,
																							iresinter, iresadmin, icuorea_moncon, iliqnet_moncon,
																							iliqrea_moncon, ipagrea_moncon, ireserv_moncon, iresgas_moncon,
																							iresindem_moncon, iresinter_moncon, iresadmin_moncon,
																							iresnet_moncon, iresrea_moncon, itotexp_moncon, itotrea_moncon,
																							cevento)
																					VALUES
																						 (v_movsin(sini).nsinies, v_movsin(sini).fsinies, v_pago_idx,
																							p_pfperfin, p_pproces, v_movsin(sini).scontra,
																							v_movsin(sini).nversio, v_ctramo, compa.ccompani, v_pcuorea,
																							--% Pagos de reaseguro
																							v_icuorea,
																							--Importe de cuota del reaseguro por cia
																							v_ipagrea_mov,
																							--Liquidaciones anteriores por SINIESTRO-EVENTO
																							v_ipagrea_mov,
																							--Importe de pagos liquidados por siniestro-evento
																							v_iresrea_sin,
																							--Importe de reservas por siniestro-evento
																							v_pcuotot,
																							--% Total del Reaseguro
																							v_itotrea,
																							--Importe Total de reaseguro por cia
																							v_iresrea_mov,
																							--Importe total de reserva de reaseguro por cia
																							v_iliqrea_sin,
																							--Importe de pagos liquidados por siniestro-evento
																							v_iresrea_sin, v_iresgas, v_iresindem, v_iresinter, v_iresadmin,
																							f_round(NVL(v_icuorea, 0) * v_itasa, v_cmoncontab),
																							f_round(NVL(v_iliqrea_sin, 0) * v_itasa, v_cmoncontab),
																							f_round(NVL(v_ipagrea_mov, 0) * v_itasa, v_cmoncontab),
																							f_round(NVL(v_ipagrea_mov, 0) * v_itasa, v_cmoncontab),
																							f_round(NVL(v_iresrea_mov, 0) * v_itasa, v_cmoncontab),
																							f_round(NVL(v_iresgas, 0) * v_itasa, v_cmoncontab),
																							f_round(NVL(v_iresindem, 0) * v_itasa, v_cmoncontab),
																							f_round(NVL(v_iresinter, 0) * v_itasa, v_cmoncontab),
																							f_round(NVL(v_iresadmin, 0) * v_itasa, v_cmoncontab),
																							f_round(NVL(v_iresrea_sin, 0) * v_itasa, v_cmoncontab),
																							f_round(NVL(v_iresrea_mov, 0) * v_itasa, v_cmoncontab),
																							f_round(NVL(v_pago_idx, 0) * v_itasa, v_cmoncontab),
																							f_round(NVL(v_itotrea, 0) * v_itasa, v_cmoncontab),
																							v_movsin(sini).cevento);
																			 EXCEPTION
																					WHEN dup_val_on_index THEN
																						 UPDATE liquidareaxl_aux
																								SET icuorea = icuorea + v_icuorea,
																										iliqrea = iliqrea + v_ipagrea_mov,
																										ireserv = ireserv + v_iresrea_mov,
																										itotrea = itotrea + v_itotrea,
																										iresrea = iresrea + v_iresrea_mov,
																										iliqnet = iliqnet + v_iliqrea_sin,
																										iresnet = iresnet + v_iresrea_sin,
																										icuorea_moncon = icuorea_moncon +
																																			f_round(NVL(v_icuorea, 0) * v_itasa,
																																							v_cmoncontab),
																										iliqnet_moncon = iliqnet_moncon +
																																			f_round(NVL(v_iliqrea_sin, 0) * v_itasa,
																																							v_cmoncontab),
																										iliqrea_moncon = iliqrea_moncon +
																																			f_round(NVL(v_ipagrea_mov, 0) * v_itasa,
																																							v_cmoncontab),
																										ireserv_moncon = ireserv_moncon +
																																			f_round(NVL(v_iresrea_mov, 0) * v_itasa,
																																							v_cmoncontab),
																										iresnet_moncon = iresnet_moncon +
																																			f_round(NVL(v_iresrea_sin, 0) * v_itasa,
																																							v_cmoncontab),
																										iresrea_moncon = iresrea_moncon +
																																			f_round(NVL(v_iresrea_mov, 0) * v_itasa,
																																							v_cmoncontab),
																										itotrea_moncon = itotrea_moncon +
																																			f_round(NVL(v_itotrea, 0) * v_itasa,
																																							v_cmoncontab)
																							WHERE nsinies = v_movsin(sini).nsinies
																								AND fcierre = p_pfperfin
																								AND sproces = p_pproces
																								AND scontra = v_movsin(sini).scontra
																								AND nversio = v_movsin(sini).nversio
																								AND ctramo = v_ctramo
																								AND ccompani = compa.ccompani;
																					WHEN OTHERS THEN
																						 nerr := 1;
																						 p_tab_error(f_sysdate, f_user, vobj, v_traza,
																												 'Err INSERT INTO liquidareaxl_aux',
																												 'SQLERRM = ' || SQLERRM);
																			 END; --Insert en Liquidareaxl_aux
																		
																			 IF v_iliqrea_sin <> 0 THEN
																					--Insert Pagosreaxl_aux
																					BEGIN
																						 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete,
																														 v_nom_funcion, NULL, 6074,
																														 'Insertando en Pagosreaxl_aux');
																					
																						 INSERT INTO pagosreaxl_aux
																								(nsinies, scontra, nversio, ctramo, ccompani, fcierre, sproces,
																								 iliqrea, cestliq, iliqrea_moncon, fcambio, cevento)
																						 VALUES
																								(v_movsin(sini).nsinies, v_movsin(sini).scontra,
																								 v_movsin(sini).nversio, v_ctramo, compa.ccompani, p_pfperfin,
																								 p_pproces, v_iliqrea_sin, 0,
																								 f_round(NVL(v_iliqrea_sin, 0) * v_itasa, v_cmoncontab),
																								 DECODE(v_cmultimon, 0, NULL,
																												 NVL(v_fcambio, v_movsin(sini).fsinies)),
																								 v_movsin(sini).cevento);
																					EXCEPTION
																						 WHEN dup_val_on_index THEN
																								UPDATE pagosreaxl_aux
																									 SET iliqrea = iliqrea + v_iliqrea_sin,
																											 iliqrea_moncon = iliqrea_moncon +
																																				 f_round(NVL(v_iliqrea_sin, 0) * v_itasa,
																																								 v_cmoncontab)
																								 WHERE nsinies = v_movsin(sini).nsinies
																									 AND scontra = v_movsin(sini).scontra
																									 AND nversio = v_movsin(sini).nversio
																									 AND ctramo = v_ctramo
																									 AND ccompani = compa.ccompani
																									 AND fcierre = p_pfperfin
																									 AND sproces = p_pproces;
																						 WHEN OTHERS THEN
																								p_tab_error(f_sysdate, f_user, vobj, v_traza,
																														'Err INSERT INTO pagosreaxl',
																														' SQLERRM = ' || SQLERRM);
																								nerr := 1;
																					END; --Insert Pagosreaxl_aux
																			 
																					-- Se actualizan pagos anteriores NO LIQUIDADOS
																					BEGIN
																						 UPDATE pagosreaxl
																								SET cestliq = 2
																							WHERE scontra = v_movsin(sini).scontra
																								AND nversio = v_movsin(sini).nversio
																								AND ctramo = v_ctramo
																								AND ccompani = compa.ccompani
																								AND fcierre < p_pfperfin
																								AND nsinies = v_movsin(sini).nsinies
																								AND cestliq = 0;
																					EXCEPTION
																						 WHEN no_data_found THEN
																								v_ipagrea := 0;
																						 WHEN OTHERS THEN
																								nerr := 1;
																								p_tab_error(f_sysdate, f_user, vobj, v_traza,
																														'Err UPDATE pagosreaxl',
																														' v_scontra =' || v_movsin(sini).scontra ||
																														 ' v_nversio =' || v_movsin(sini).nversio ||
																														 ' v_ctramo =' || v_ctramo || ' compa.ccompani=' ||
																														 compa.ccompani || ' sini.nsin=' || v_movsin(sini)
																														.nsinies || ' p_pfperfin =' || p_pfperfin ||
																														 ' SQLERRM = ' || SQLERRM);
																					END;
																			 END IF;
																		
																			 BEGIN
																					SELECT NVL(MAX(nnumlin), 0)
																						INTO w_nnumlin
																						FROM movctaaux
																					 WHERE scontra = v_movsin(sini).scontra
																						 AND nversio = v_movsin(sini).nversio
																						 AND ctramo = v_ctramo
																						 AND ccompani = compa.ccompani;
																			 
																					w_nnumlin := w_nnumlin + 1;
																			 EXCEPTION
																					WHEN no_data_found THEN
																						 w_nnumlin := 1;
																					WHEN OTHERS THEN
																						 nerr    := 104863;
																						 o_plsql := SQLERRM;
																						 p_tab_error(f_sysdate, f_user, vobj, v_traza,
																												 'Err SELECT MOVCTAAUX',
																												 ' v_scontra=' || v_movsin(sini).scontra ||
																													' v_nversio=' || v_movsin(sini).nversio || ' v_ctramo=' ||
																													v_ctramo || ' compa.ccompani=' || compa.ccompani ||
																													' SQLERRM = ' || SQLERRM);
																			 END;
																		
																			 IF v_iliqrea_sin <> 0 THEN
																					-- 5 -> Siniestros
																					p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete,
																													v_nom_funcion, NULL, 6183,
																													'Insertando en movctaaux-> Concepto 5 (Pago de Siniestros)');
																					v_movsin(sini).ctramo := v_ctramo;
																					nerr := f_insertxl_movctatecnica(w_ctadet, v_movsin(sini), w_nnumlin, 5,
																																					 compa.ccompani, v_iliqrea_sin,
																																					 p_pproces, v_cestado_cia, p_pcempres,
																																					 p_pfperfin, compa.ccorred); -- 25/05/2015  CJMR  0033158: Actualización campo CCORRED en los cierres de Reaseguro
																			 END IF;
																		
																			 IF v_iliqrea_sin <> 0 THEN
																					-- 15 -> Liquidacion XL
																					p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete,
																													v_nom_funcion, NULL, 6200,
																													'Insertando en movctaaux-> Concepto 15 (Liquidacion XL)');
																					v_movsin(sini).ctramo := v_ctramo;
																					nerr := f_insertxl_movctatecnica(w_ctadet, v_movsin(sini), w_nnumlin,
																																					 15, compa.ccompani, v_iliqrea_sin,
																																					 p_pproces, v_cestado_cia, p_pcempres,
																																					 p_pfperfin, compa.ccorred); -- 25/05/2015  CJMR  0033158: Actualización campo CCORRED en los cierres de Reaseguro
																			 END IF;
																		
																			 IF v_iresrea_sin <> 0 THEN
																					-- 25 -> Reserva de Siniestros
																					p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete,
																													v_nom_funcion, NULL, 6218,
																													'Insertando en movctaaux-> Concepto 25 (Reserva de Siniestros)');
																					v_movsin(sini).ctramo := v_ctramo;
																					nerr := f_insertxl_movctatecnica(w_ctadet, v_movsin(sini), w_nnumlin,
																																					 25, compa.ccompani, v_iresrea_sin,
																																					 p_pproces, v_cestado_cia, p_pcempres,
																																					 p_pfperfin, compa.ccorred); -- 25/05/2015  CJMR  0033158: Actualización campo CCORRED en los cierres de Reaseguro
																			 END IF;
																		
																			 IF v_primareest_sin <> 0 THEN
																					-- 23 -> Reinstalamento XL
																					p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete,
																													v_nom_funcion, NULL, 6235,
																													'Insertando en movctaaux-> Concepto 23 (Prima de Reinstalamiento XL)');
																					v_movsin(sini).ctramo := v_ctramo;
																					nerr := f_insertxl_movctatecnica(w_ctadet, v_movsin(sini), w_nnumlin,
																																					 23, compa.ccompani, v_primareest_sin,
																																					 p_pproces, v_cestado_cia, p_pcempres,
																																					 p_pfperfin, compa.ccorred); -- 25/05/2015  CJMR  0033158: Actualización campo CCORRED en los cierres de Reaseguro
																			 END IF;
																		END LOOP; --Cias
																 
																		v_movsin(sini).pago_total_sin := v_movsin(sini)
																																		 .pago_total_sin - v_total_pag_tramos;
																		v_movsin(sini).reserva_total_sin := v_movsin(sini)
																																				.reserva_total_sin - v_total_res_tramos;
																		p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete,
																										v_nom_funcion, NULL, 5845,
																										'Total Res Tramos-Sin: ' || v_total_res_tramos ||
																										 ' Total Pag Tramos-Sin: ' || v_total_pag_tramos);
																 END LOOP; --Siniestros
															END IF;
													 
															--KBR Multitramos y Reinstalaciones
															IF NVL(pac_parametros.f_parempresa_n(p_pcempres, 'PERMITE_MREPOXL_REA'), 0) = 0 THEN
																 EXIT;
															END IF;
													 END;
												END LOOP; --Reestablecimientos
										 END IF;
									
										 --KBR Multitramos y Reinstalaciones
										 IF NVL(pac_parametros.f_parempresa_n(p_pcempres, 'PERMITE_MTRAMOXL_REA'), 0) = 0 THEN
												EXIT;
										 END IF;
									END;
							 END LOOP; --Multitramos
						
							 v_totalpagos_ret := 0;
							 v_sin            := 0;
							 v_contador       := 0;
							 v_res_dist       := 0;
							 v_pago_idx       := 0;
							 v_pago_no_idx    := 0;
							 v_reserva        := 0;
							 v_totrea_evto    := 0;
							 v_evto           := evto.evto;
							 v_prea           := 0;
							 v_iced_xl        := 0;
						END IF;
				 END IF;
			
				 v_cramo := evto.cramo;
			
				 --Cursor que retorna siniestros/seguros totalizados por evento/ramo en un período determinado
				 FOR evto_det IN c_sinevtos_det(evto.evto, evto.cramo, v_fechacorte) LOOP
						p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL, 6271,
														'Siniestro: ' || evto_det.nsin || ' Evento: ' || evto.evto || ' Ramo: ' ||
														 evto.cramo);
				 
						IF evto_det.totireserva <> 0 OR evto_det.totisinpag <> 0 THEN
							 IF v_sin = 0 THEN
									v_sin      := evto_det.nsin;
									v_fsin     := evto_det.fsin;
									v_sproduc  := evto_det.sproduc;
									v_ccompapr := evto_det.ccompapr;
									v_contador := v_contador + 1;
							 ELSE
									IF v_sin <> evto_det.nsin THEN
										 v_movsin.extend;
										 v_movsin(v_contador).nsinies := v_sin;
										 v_movsin(v_contador).fsinies := v_fsin;
										 v_movsin(v_contador).scontra := v_scontra;
										 v_movsin(v_contador).nversio := v_nversio;
										 v_movsin(v_contador).cevento := v_evto;
										 --v_movsin(v_contador).ctramo := v_ctramo;
										 v_movsin(v_contador).ccompapr := v_ccompapr;
										 v_movsin(v_contador).sproduc := v_sproduc;
										 v_movsin(v_contador).pago_total := v_pago_idx;
										 v_movsin(v_contador).reserva_total := v_reserva;
									
										 IF v_contador = 1 THEN
												v_movsin(v_contador).pago_total_sin := v_pago_idx;
												v_movsin(v_contador).reserva_total_sin := v_reserva;
										 ELSE
												v_movsin(v_contador).pago_total_sin := v_pago_idx - v_movsin(v_contador - 1).pago_total;
												v_movsin(v_contador).reserva_total_sin := v_reserva - v_movsin(v_contador - 1)
																																 .reserva_total;
										 END IF;
									
										 v_totrea_evto := v_totrea_evto + v_movsin(v_contador).pago_total_sin + v_movsin(v_contador)
																		 .reserva_total_sin;
										 v_sin         := evto_det.nsin;
										 v_fsin        := evto_det.fsin;
										 v_sproduc     := evto_det.sproduc;
										 v_ccompapr    := evto_det.ccompapr;
										 v_contador    := v_contador + 1;
									END IF;
							 END IF;
						
							 v_pago_indexado    := 0;
							 v_pago_no_indexado := 0;
							 v_ireserv          := 0;
						
							 ---------------------------------------------------------------------------------------------------------
							 -- Para cada Siniestro se busca el SCONTRA, NVERSIO que le corresponde a partir de la F_BUSCACONTRATO. --
							 ---------------------------------------------------------------------------------------------------------
							 BEGIN
									SELECT cmodali, ctipseg, ccolect, cactivi
										INTO v_cmodali, v_ctipseg, v_ccolect, v_cactivi
										FROM seguros
									 WHERE sseguro = evto_det.sseg;
							 EXCEPTION
									WHEN no_data_found THEN
										 v_cmodali := NULL;
										 v_ctipseg := NULL;
										 v_ccolect := NULL;
										 v_cactivi := NULL;
									WHEN OTHERS THEN
										 nerr := 1;
										 p_tab_error(f_sysdate, f_user, vobj, v_traza, 'Err select seguros',
																 'SSEGURO =' || evto_det.sseg || ' SQLERRM = ' || SQLERRM);
							 END;
						
							 nerr := f_buscacontrato(evto_det.sseg, evto_det.fsin, p_pcempres, NULL, evto.cramo, v_cmodali,
																			 v_ctipseg, v_ccolect, v_cactivi, 11, v_scontra, v_nversio, v_ipleno,
																			 v_icapaci, v_cdetces, 1);
							 -----------------------------------------------------------------------------------
							 --  A partir del contrato conocemos: Prioridad (IPRIOXL de CONTRATOS) --
							 --  A partir del contrato conocemos: Prioridad, Capacidad, Lim de Index, Lim de Gastos,  (IPRIOXL de TRAMOS) --
							 -----------------------------------------------------------------------------------
							 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL, 6350,
															 'Contrato: ' || v_scontra || ' Version: ' || v_nversio);
						
							 IF nerr = 0 THEN
									--Verificamos si tiene Coaseguro
									DECLARE
										 v_ctipcoa seguros.ctipcoa%TYPE;
										 v_ploccoa coacuadro.ploccoa%TYPE;
									BEGIN
										 v_c_gar := evto_det.cgar;
									
										 SELECT NVL(ctipcoa, 0) INTO v_ctipcoa FROM seguros WHERE sseguro = evto_det.sseg;
									
										 -- si es aceptado, no modificamos el importe.
										 -- si es cedido y tiene porcentaje, modificamos el importe.
										 IF v_ctipcoa IN (1, 2) THEN
												SELECT MAX(ploccoa)
													INTO v_ploccoa
													FROM coacuadro
												 WHERE ncuacoa = evto_det.ncua
													 AND sseguro = evto_det.sseg;
										 
												p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL,
																				6376, '% Coaseguro Cedido: ' || v_ploccoa);
										 
												IF v_ploccoa IS NOT NULL THEN
													 evto_det.totisinpag  := evto_det.totisinpag * v_ploccoa / 100;
													 evto_det.totireserva := evto_det.totireserva * v_ploccoa / 100;
												END IF;
										 END IF;
									END;
							 
									--Reajusta todos los pagos.
									BEGIN
										 --2: Pago 8: Anulación del Recobro
										 IF evto_det.ctippag IN (2, 8) THEN
												v_pago_indexado    := v_pago_indexado + evto_det.totisinpag;
												v_pago_no_indexado := v_pago_no_indexado + evto_det.totisinpag;
												--3: Anulación del Pago 7: Recobro
										 ELSE
												v_pago_indexado    := v_pago_indexado - evto_det.totisinpag;
												v_pago_no_indexado := v_pago_no_indexado - evto_det.totisinpag;
										 END IF;
									
										 v_pago_indexado    := f_round(v_pago_indexado);
										 v_pago_no_indexado := f_round(v_pago_no_indexado);
									END;
							 
									-- Reservas totales y reserves de gastos desglosados
									BEGIN
										 v_ireserv := v_ireserv + evto_det.totireserva;
									
										 IF evto_det.ctipres = 1 THEN
												-- Indemnizatoria
												v_iresindem_tot := v_iresindem_tot + evto_det.totireserva;
										 ELSIF evto_det.ctipres = 2 THEN
												-- Intereses
												v_iresinter_tot := v_iresinter_tot + evto_det.totireserva;
										 ELSIF evto_det.ctipres = 3 THEN
												-- Gastos
												v_iresgas_tot := v_iresgas_tot + evto_det.totireserva;
										 ELSIF evto_det.ctipres = 4 THEN
												-- Administración
												v_iresadmin_tot := v_iresadmin_tot + evto_det.totireserva;
										 END IF;
									END;
							 
									p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL, 6418,
																	'reserva Siniestro: ' || v_ireserv || ' Pagos Siniestro: ' || v_pago_indexado);
									--Se valida la parte protegida del siniestro
									v_plocal := 0;
							 
									IF NVL(pac_parametros.f_parempresa_n(p_pcempres, 'XL_PROTEC_PROPI'), 0) = 1 THEN
										 v_hiha_cessio := 0;
									
										 FOR f1 IN (SELECT DISTINCT scontra, nversio, ctramo, SUM(pcesion) pcesion --CONF-910
																	FROM cesionesrea
																 WHERE nsinies = evto_det.nsin
																	 AND ctramo IN (0, 1)
																 GROUP BY scontra, nversio, ctramo) LOOP
												v_hiha_cessio := 1;
										 
												IF f1.ctramo = 0 THEN
													 v_plocal := f1.pcesion;
												ELSIF NVL(pac_parametros.f_parempresa_n(p_pcempres, 'INFORMA_FECHA_FIN'), 0) = 0 THEN
													 --CONF-910
													 BEGIN
															SELECT plocal
																INTO v_plocal
																FROM tramos
															 WHERE scontra = f1.scontra
																 AND nversio = f1.nversio
																 AND ctramo = f1.ctramo;
													 EXCEPTION
															WHEN no_data_found THEN
																 p_tab_error(f_sysdate, f_user, vobj, v_traza,
																						 'Err select TRAMOS: NO_DATA_FOUND',
																						 ' sin: ' || evto_det.nsin || ' v_scontra =' || f1.scontra ||
																							' v_nversio =' || f1.nversio || ' ctramo = ' || f1.ctramo ||
																							' SQLERRM = ' || SQLERRM);
																 v_plocal := 0;
															WHEN OTHERS THEN
																 p_tab_error(f_sysdate, f_user, vobj, v_traza, 'Err select TRAMOS',
																						 ' sin: ' || evto_det.nsin || ' v_scontra =' || f1.scontra ||
																							' v_nversio =' || f1.nversio || ' ctramo = ' || f1.ctramo ||
																							' SQLERRM = ' || SQLERRM);
													 END;
												
													 v_plocal := v_plocal / 100 * f1.pcesion;
												END IF;
										 END LOOP;
									
										 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL, 6465,
																		 '% Retencion: ' || v_plocal);
									
										 -- Si solo hay reserva: La garantia no es obligatoria, puede estar sin informar
										 IF v_hiha_cessio = 0 THEN
												FOR f2 IN (SELECT DISTINCT scontra, nversio, ctramo, SUM(pcesion) pcesion --CONF-910
																		 FROM cesionesrea
																		WHERE sseguro = evto_det.sseg
																			AND cgenera IN (1, 3, 4, 5, 9, 40)
																			AND nriesgo = evto_det.nrie
																			AND fefecto <= evto_det.fsin
																			AND fvencim >= evto_det.fsin -- Bug 31730 EDA 11/06/2014
																			AND (fregula IS NULL OR fregula >= evto_det.fsin) -- Bug 31730 EDA 11/06/2014
																			AND (fanulac IS NULL OR fanulac >= evto_det.fsin)
																			AND ctramo IN (0, 1)
																			AND cgarant = evto_det.cgar
																		GROUP BY scontra, nversio, ctramo) LOOP
													 v_hiha_cessio := 1;
												
													 IF f2.ctramo = 0 THEN
															v_plocal := f2.pcesion;
													 ELSIF NVL(pac_parametros.f_parempresa_n(p_pcempres, 'INFORMA_FECHA_FIN'), 0) = 0 THEN
															--CONF-910
															BEGIN
																 SELECT plocal
																	 INTO v_plocal
																	 FROM tramos
																	WHERE scontra = f2.scontra
																		AND nversio = f2.nversio
																		AND ctramo = f2.ctramo;
															EXCEPTION
																 WHEN no_data_found THEN
																		p_tab_error(f_sysdate, f_user, vobj, v_traza,
																								'Err select TRAMOS: NO_DATA_FOUND',
																								' sin: ' || evto_det.nsin || ' v_scontra =' || f2.scontra ||
																								 ' v_nversio =' || f2.nversio || ' ctramo = ' || f2.ctramo ||
																								 ' SQLERRM = ' || SQLERRM);
																		v_plocal := 0;
																 WHEN OTHERS THEN
																		p_tab_error(f_sysdate, f_user, vobj, v_traza, 'Err select TRAMOS',
																								' sin: ' || evto_det.nsin || ' v_scontra =' || f2.scontra ||
																								 ' v_nversio =' || f2.nversio || ' ctramo = ' || f2.ctramo ||
																								 ' SQLERRM = ' || SQLERRM);
															END;
													 
															v_plocal := v_plocal / 100 * f2.pcesion;
													 END IF;
												END LOOP;
										 END IF;
									
										 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL, 6518,
																		 '% Retencion: ' || v_plocal);
									
										 IF v_hiha_cessio = 0 THEN
												-- Paso 2. Garant£¿as agrupadas: La garantia no es obligatoria a la reserva, pot estar sense informar.
												FOR f2 IN (SELECT DISTINCT scontra, nversio, ctramo, SUM(pcesion) pcesion --CONF-910
																		 FROM cesionesrea
																		WHERE sseguro = evto_det.sseg
																			AND cgenera IN (1, 3, 4, 5, 9, 40)
																			AND nriesgo = evto_det.nrie
																			AND fefecto <= evto_det.fsin
																			AND fvencim >= evto_det.fsin -- Bug 31730 EDA 11/06/2014
																			AND (fregula IS NULL OR fregula >= evto_det.fsin) -- Bug 31730 EDA 11/06/2014
																			AND (fanulac IS NULL OR fanulac >= evto_det.fsin)
																			AND ctramo IN (0, 1)
																			AND cgarant IS NULL
																		GROUP BY scontra, nversio, ctramo) LOOP
													 v_hiha_cessio := 1;
												
													 IF f2.ctramo = 0 THEN
															v_plocal := f2.pcesion;
													 ELSIF NVL(pac_parametros.f_parempresa_n(p_pcempres, 'INFORMA_FECHA_FIN'), 0) = 0 THEN
															--CONF-910
															BEGIN
																 SELECT plocal
																	 INTO v_plocal
																	 FROM tramos
																	WHERE scontra = f2.scontra
																		AND nversio = f2.nversio
																		AND ctramo = f2.ctramo;
															EXCEPTION
																 WHEN no_data_found THEN
																		p_tab_error(f_sysdate, f_user, vobj, v_traza,
																								'Err select TRAMOS: NO_DATA_FOUND',
																								' sin: ' || evto_det.nsin || ' v_scontra =' || f2.scontra ||
																								 ' v_nversio =' || f2.nversio || ' ctramo = ' || f2.ctramo ||
																								 ' SQLERRM = ' || SQLERRM);
																		v_plocal := 0;
																 WHEN OTHERS THEN
																		p_tab_error(f_sysdate, f_user, vobj, v_traza, 'Err select TRAMOS',
																								' sin: ' || evto_det.nsin || ' v_scontra =' || f2.scontra ||
																								 ' v_nversio =' || f2.nversio || ' ctramo = ' || f2.ctramo ||
																								 ' SQLERRM = ' || SQLERRM);
															END;
													 
															v_plocal := v_plocal / 100 * f2.pcesion;
													 END IF;
												END LOOP;
										 END IF;
									
										 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL, 6571,
																		 '% Retencion: ' || v_plocal);
									
										 IF NVL(pac_parametros.f_parempresa_n(p_pcempres, 'APLICA_RESMAT_REA_XL'), 0) = 1 THEN
												v_reserva_mat := NVL(TRUNC(pac_isqlfor.f_provisio_actual(evto_det.sseg, 'IPROVRES',
																																								 TRUNC(f_sysdate), evto_det.cgar),
																									 2), 0);
												p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL,
																				6586, 'Reserva Mat.: ' || v_reserva_mat);
										 
												SELECT cdivisa INTO v_moneda_prod FROM productos WHERE sproduc = v_sproduc;
										 
												IF v_cmoncontab <> v_moneda_prod THEN
													 nerr := pac_oper_monedas.f_datos_contraval(evto_det.sseg, NULL, v_scontra,
																																			evto_det.fsin, 3, v_itasa_prod,
																																			v_fcambio_prod);
												
													 IF nerr <> 0 THEN
															o_plsql := SQLERRM;
															p_tab_error(f_sysdate, f_user, vobj, v_traza, 'Err Tasa Prod',
																					' v_scontra =' || v_scontra || ' v_nversio =' || v_nversio ||
																					 ' ctramo = ' || v_ctramo || ' SQLERRM = ' || o_plsql);
													 END IF;
												
													 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL,
																					 6609, 'Tasa Cambio: ' || NVL(v_itasa_prod, 1));
													 v_reserva_mat := v_reserva_mat * NVL(v_itasa_prod, 1);
												END IF;
										 ELSE
												v_reserva_mat := 0;
										 END IF;
									
										 IF NVL(v_ireserv, 0) <> 0 AND NVL(evto_det.totireserva, 0) <> 0 THEN
												v_ireserv := v_ireserv - v_reserva_mat;
										 END IF;
									
										 IF NVL(v_pago_indexado, 0) <> 0 AND NVL(evto_det.totisinpag, 0) <> 0 THEN
												-- Si la Reserva Matematica es més gran que el pago (PAGO PARCIAL) NO LA RESTA
												IF v_pago_indexado - v_reserva_mat > 0 THEN
													 v_pago_indexado := v_pago_indexado - v_reserva_mat;
												END IF;
										 
												v_pago_no_indexado := v_pago_indexado;
										 END IF;
									
										 v_pago_idx      := v_pago_idx + (v_pago_indexado * v_plocal / 100);
										 v_pago_idx      := NVL(v_pago_idx, 0);
										 v_reserva       := v_reserva + (v_ireserv * v_plocal / 100);
										 v_reserva       := NVL(v_reserva, 0);
										 v_res_dist      := v_reserva;
										 v_iresgas_tot   := v_iresgas_tot * v_plocal / 100;
										 v_iresindem_tot := v_iresindem_tot * v_plocal / 100;
										 v_iresinter_tot := v_iresinter_tot * v_plocal / 100;
										 v_iresadmin_tot := v_iresadmin_tot * v_plocal / 100;
										 v_pago_no_idx   := v_pago_no_idx + (v_pago_no_indexado * v_plocal / 100);
										 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL, 6640,
																		 'Reserva Dist.: ' || v_res_dist || ' Pagos Dist.: ' || v_pago_idx);
									END IF;
							 END IF;
						END IF;
				 END LOOP; --Siniestros/Seguros x Evento
			
				 IF v_sin <> 0 THEN
						v_movsin.extend;
						v_movsin(v_contador).nsinies := v_sin;
						v_movsin(v_contador).fsinies := v_fsin;
						v_movsin(v_contador).scontra := v_scontra;
						v_movsin(v_contador).nversio := v_nversio;
						v_movsin(v_contador).cevento := v_evto;
						--v_movsin(v_contador).ctramo := v_ctramo;
						v_movsin(v_contador).ccompapr := v_ccompapr;
						v_movsin(v_contador).sproduc := v_sproduc;
						v_movsin(v_contador).pago_total := v_pago_idx;
						v_movsin(v_contador).reserva_total := v_reserva;
				 
						IF v_contador = 1 THEN
							 v_movsin(v_contador).pago_total_sin := v_pago_idx;
							 v_movsin(v_contador).reserva_total_sin := v_reserva;
						ELSE
							 v_movsin(v_contador).pago_total_sin := v_pago_idx - v_movsin(v_contador - 1).pago_total;
							 v_movsin(v_contador).reserva_total_sin := v_reserva - v_movsin(v_contador - 1).reserva_total;
						END IF;
				 
						v_totrea_evto := v_totrea_evto + v_movsin(v_contador).pago_total_sin + v_movsin(v_contador)
														.reserva_total_sin;
						p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL, 6674,
														'Total Evento Rea.: ' || v_totrea_evto);
						v_sin := 0;
				 END IF;
			END LOOP; --Eventos
	 
			--Distribución por compañías
			IF v_totalpagos_ret = 0 AND v_evto <> '0' THEN
				 v_totalpagos_ret := v_pago_idx;
				 v_ctramo         := 5; --Facultativo y empezamos a validar a partir del primer tramo XL
				 v_reserva_ret    := v_reserva;
				 v_ixlprio_ant    := 0;
			
				 LOOP
						--LOOP de Multitramos
						BEGIN
							 v_ctramo := v_ctramo + 1;
						
							 IF v_totrea_evto = 0 OR
									NVL(pac_parametros.f_parempresa_n(p_pcempres, 'MAX_MTRAMOSXL_REA'), 6) < v_ctramo OR
									v_scontra IS NULL THEN
									EXIT;
							 END IF;
						
							 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL, 6694,
															 'Evaluando Tramo.: ' || v_ctramo || ' Producto: ' || v_sproduc);
						
							 BEGIN
									SELECT ct.porcen
										INTO v_porc_tramo_ramo
										FROM ctto_tramo_producto ct
									 WHERE ct.ctramo = v_ctramo
										 AND ct.scontra = v_scontra
										 AND ct.nversio = v_nversio
										 AND ct.cramo = v_cramo;
							 EXCEPTION
									WHEN no_data_found THEN
										 v_porc_tramo_ramo := 100;
									WHEN too_many_rows THEN
										 BEGIN
												SELECT ct.porcen
													INTO v_porc_tramo_ramo
													FROM ctto_tramo_producto ct
												 WHERE ct.ctramo = v_ctramo
													 AND ct.scontra = v_scontra
													 AND ct.nversio = v_nversio
													 AND ct.cramo = v_cramo
													 AND ct.sproduc = v_sproduc;
										 EXCEPTION
												WHEN no_data_found THEN
													 v_porc_tramo_ramo := 100;
												WHEN OTHERS THEN
													 v_porc_tramo_ramo := 100;
										 END;
									WHEN OTHERS THEN
										 v_porc_tramo_ramo := 100;
							 END;
						
							 IF v_porc_tramo_ramo > 0 THEN
									--Obtenemos datos de Contrato y Tramo para Multitramos
									SELECT caplixl, ixlprio, pliminx, plimgas, itottra, icapaci, iprioxl, ipmd, NVL(crepos, 0),
												 preest
										INTO v_caplixl, v_iprioxl_tramo, v_pliminx, v_plimgas, v_itottra, v_icapaci, v_iprioxl_ctto,
												 v_ipmd, v_crepos, v_preest
										FROM tramos tt, contratos cc
									 WHERE cc.scontra = v_scontra
										 AND cc.nversio = v_nversio
										 AND cc.scontra = tt.scontra(+)
										 AND cc.nversio = tt.nversio(+)
										 AND tt.ctramo(+) = v_ctramo;
							 
									--Obtenemos número de reestablecimientos del tramo
									SELECT COUNT(norden) INTO v_nro_repos FROM reposiciones_det WHERE ccodigo = v_crepos;
							 
									IF v_nro_repos = 0 THEN
										 inicio := 0;
									ELSE
										 inicio := 1;
									END IF;
							 
									v_primareest := 0;
									p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL, 6722,
																	'Reposiciones Tramo: ' || v_nro_repos);
							 
									--Si no existe capacidad del tramo tomamos la del contrato y su prioridad
									IF v_iprioxl_tramo IS NULL THEN
										 v_ixlprio   := NVL(v_iprioxl_ctto, 0);
										 v_ixlcapaci := v_icapaci - v_ixlprio;
									ELSE
										 v_ixlprio   := v_iprioxl_tramo;
										 v_ixlcapaci := v_itottra;
									END IF;
							 
									IF v_ixlprio_ant = 0 THEN
										 v_ixlprio_ant := v_ixlprio;
									ELSE
										 v_ixlprio := v_ixlprio_ant;
									END IF;
							 
									p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL, 6733,
																	'Capacidad (Cap-Prio): ' || v_ixlcapaci || ' Prioridad: ' || v_ixlprio);
							 
									--Si tenemos el porcentaje de aumento por gastos en el contrato
									--Calculamos el nuevo límite aumentándolo según el procentaje definido en el contrato (PLIMGAS).
									IF NVL(v_plimgas, 0) <> 0 THEN
										 v_ixlprio := v_ixlprio * (100 + v_plimgas) / 100;
									END IF;
							 
									FOR i_rep IN inicio .. v_nro_repos LOOP
										 --LOOP de Reestablecimientos
										 BEGIN
												IF v_totrea_evto = 0 OR NVL(pac_parametros.f_parempresa_n(p_pcempres, 'MAX_MREPOSXL_REA'),
																										v_nro_repos) < i_rep THEN
													 EXIT;
												END IF;
										 
												p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL,
																				6751, 'Evaluando Reposicion: ' || i_rep);
										 
												IF (v_totalpagos_ret - v_ixlprio) > 0 THEN
													 IF (v_totalpagos_ret - v_ixlprio) < v_ixlcapaci THEN
															--Importe pagado cedido xl (Total Pagos - Prioridad)
															v_ipagced_xl := v_totalpagos_ret - v_ixlprio;
															v_pcuorea    := ROUND((v_ipagced_xl / v_totalpagos_ret) * 100, 5);
															--variable temporal
															v_temp_pagos_ret := v_totalpagos_ret;
															--No existen más pagos a ceder al XL
															v_totalpagos_ret := 0;
													 ELSE
															v_ipagced_xl := v_ixlcapaci;
															v_pcuorea    := ROUND((v_ipagced_xl / v_totalpagos_ret) * 100, 5);
															--variable temporal
															v_temp_pagos_ret := v_totalpagos_ret;
															--Recalculamos los pagos totales para el próximo reinstalamiento/tramo
															v_totalpagos_ret := v_totalpagos_ret - v_ixlcapaci;
													 END IF;
												
													 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL,
																					 6769,
																					 'Pagos Ced XL: ' || v_ipagced_xl || ' % Pagos: ' || v_pcuorea ||
																						' Total Pagos Ret: ' || v_totalpagos_ret);
												
													 --Calculamos la prima de reestablecimiento
													 IF i_rep <> 0 THEN
															--pr=(pmd*pagos cedidos xl de la capa/ capacidad de la capa)* %reestablecimiento;
															v_primareest := (v_ipmd * v_ipagced_xl / v_ixlcapaci) * v_preest / 100;
													 END IF;
												
													 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL,
																					 6782, 'Prima Reest.: ' || v_primareest);
												ELSE
													 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL,
																					 6786, 'No existen Pagos al XL');
													 v_ipagced_xl := 0;
													 v_pcuorea    := 0;
													 --No existen más pagos a ceder al XL
													 v_totalpagos_ret := 0;
													 --variable temporal
													 v_temp_pagos_ret := v_totalpagos_ret;
												END IF;
										 
												IF (v_totrea_evto - v_ixlprio) > 0 THEN
													 IF (v_totrea_evto - v_ixlprio) < v_ixlcapaci THEN
															--Importe total cedido xl ((Total Pagos + Total Reservas)- Prioridad)
															v_iced_xl := v_totrea_evto - v_ixlprio;
															v_prea    := (v_iced_xl / v_totrea_evto) * 100;
															--variable temporal
															v_temp_totrea_evto := v_totrea_evto;
															v_totrea_evto      := 0;
													 ELSE
															v_iced_xl := v_ixlcapaci;
															v_prea    := (v_iced_xl / v_totrea_evto) * 100;
															--variable temporal
															v_temp_totrea_evto := v_totrea_evto;
															--Recalculamos el importe total para el próximo reinstalamiento/tramo
															v_totrea_evto := v_totrea_evto - v_ixlcapaci;
													 END IF;
												
													 v_prea := ROUND(v_prea, 5);
													 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL,
																					 6807,
																					 'Total Ced XL: ' || v_iced_xl || ' % Total XL: ' || v_prea ||
																						' Total Evento: ' || v_totrea_evto);
													 --Reserva
													 v_iresced_xl := v_iced_xl - v_ipagced_xl;
												
													 --KBR 08052014
													 IF NVL(pac_parametros.f_parempresa_n(p_pcempres, 'MANEJO_RESERVAXL_REA'), 0) = 1 THEN
															IF v_prea < v_pcuorea THEN
																 v_presrea := 0;
															ELSE
																 v_presrea := 1;
															END IF;
													 ELSE
															v_presrea := v_prea - v_pcuorea;
													 END IF;
												
													 --Fin KBR 08052014
													 v_presrea := ROUND(v_presrea, 5);
													 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL,
																					 6814,
																					 'Reserva Ced XL: ' || v_iresced_xl || ' % Reserva XL: ' || v_presrea);
												ELSE
													 v_iced_xl     := 0;
													 v_prea        := 0;
													 v_totrea_evto := 0;
													 --variable temporal
													 v_temp_totrea_evto := v_totrea_evto;
												END IF;
										 
												--Buscamos el importe de reserva anterior para obtener el movimiento XL de reserva =
												--Valor Reserva XL actual menos valor Reserva XL anterior
												BEGIN
													 SELECT NVL(SUM(iresnet), 0)
														 INTO v_reserva_anterior
														 FROM liquidareaxl
														WHERE cevento = v_evto
															AND fcierre = ADD_MONTHS(fcierre, -1);
												END;
										 
												p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL,
																				6834, 'Reserva Anterior evento XL: ' || v_reserva_anterior);
												v_iresrea_mov := v_iresced_xl - v_reserva_anterior;
										 
												--Buscamos el importe de pagos anterior para obtener el movimiento XL de pagos =
												--Valor Pagos XL actual menos valor Pagos XL anterior
												BEGIN
													 SELECT NVL(SUM(iliqnet), 0)
														 INTO v_pagos_anterior
														 FROM liquidareaxl
														WHERE cevento = v_evto
															AND fcierre = ADD_MONTHS(fcierre, -1);
												END;
										 
												p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL,
																				6849, 'Pagos Anterior evento XL: ' || v_pagos_anterior);
												v_ipagrea_mov := v_ipagced_xl - v_pagos_anterior;
										 
												IF v_iresced_xl <> 0 OR v_ipagced_xl <> 0 THEN
													 --Para cada siniestro
													 FOR sini IN 1 .. v_contador LOOP
															p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion,
																							NULL, 6858, 'Evaluando siniestro: ' || v_movsin(sini).nsinies);
															v_total_pag_tramos := 0;
															v_total_res_tramos := 0;
													 
															FOR compa IN c_cuadroces_agr(v_movsin(sini).scontra, v_movsin(sini).nversio,
																													 v_ctramo) LOOP
																 IF v_cmultimon = 1 THEN
																		nerr := pac_oper_monedas.f_datos_contraval(NULL, NULL, v_movsin(sini).scontra,
																																							 v_movsin(sini).fsinies, 3, v_itasa,
																																							 v_fcambio);
																 
																		IF nerr <> 0 THEN
																			 o_plsql    := SQLERRM;
																			 p_pscesrea := TO_NUMBER(TO_CHAR(v_movsin(sini).scontra) ||
																															 TO_CHAR(v_movsin(sini).nversio) ||
																															 TO_CHAR(v_ctramo) || TO_CHAR(compa.ccompani));
																		END IF;
																 END IF;
															
																 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion,
																								 NULL, 6882,
																								 'Compañía: ' || compa.ccompani || ' % Part: ' || compa.pcesion);
																 v_icuorea   := v_ipagced_xl * compa.pcesion / 100;
																 v_iresrea   := v_iresced_xl * compa.pcesion / 100;
																 v_itotrea   := v_icuorea + v_iresrea;
																 v_iresgas   := v_iresgas_tot * v_prea / 100 * compa.pcesion / 100;
																 v_iresindem := v_iresindem_tot * v_prea / 100 * compa.pcesion / 100;
																 v_iresinter := v_iresinter_tot * v_prea / 100 * compa.pcesion / 100;
																 v_iresadmin := v_iresadmin_tot * v_prea / 100 * compa.pcesion / 100;
																 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion,
																								 NULL, 6896,
																								 'Pago sin: ' || v_icuorea || ' Reserva sin: ' || v_iresrea);
																 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion,
																								 NULL, 6900,
																								 'Pago total sin: ' || v_movsin(sini).pago_total_sin ||
																									' Reserva total sin: ' || v_movsin(sini).reserva_total_sin);
															
																 IF v_temp_pagos_ret = 0 THEN
																		v_iliqrea_sin    := 0;
																		v_primareest_sin := 0;
																 ELSE
																		v_iliqrea_sin := ((v_movsin(sini)
																										 .pago_total_sin * v_ipagced_xl / v_temp_pagos_ret)) *
																										 compa.pcesion / 100;
																		--pr=(pmd*pagos cedidos xl de la capa/ capacidad de la capa)* %reestablecimiento;
																		v_primareest_sin := (v_ipmd * v_iliqrea_sin / v_ixlcapaci) * v_preest / 100;
																		p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete,
																										v_nom_funcion, NULL, 7822,
																										'Prima Reest. x Sin: ' || v_primareest_sin);
																 END IF;
															
																 IF v_ipagced_xl = v_iced_xl THEN
																		v_iresrea_sin := 0;
																 ELSE
																		IF v_temp_totrea_evto = 0 THEN
																			 v_iresrea_sin := 0;
																		ELSE
																			 --KBR 08052014
																			 IF NVL(pac_parametros.f_parempresa_n(p_pcempres, 'MANEJO_RESERVAXL_REA'),
																							0) = 1 THEN
																					IF v_ipagced_xl = 0 THEN
																						 v_iresrea_sin := ((((v_movsin(sini).pago_total_sin + v_movsin(sini)
																															.reserva_total_sin) * v_iced_xl /
																															v_temp_totrea_evto)) * compa.pcesion / 100) -
																															v_iliqrea_sin;
																					ELSE
																						 v_iresrea_sin := v_movsin(sini)
																															.reserva_total_sin * compa.pcesion / 100;
																					END IF;
																			 ELSE
																					v_iresrea_sin := ((((v_movsin(sini)
																													 .pago_total_sin + v_movsin(sini).reserva_total_sin) *
																													 v_iced_xl / v_temp_totrea_evto)) * compa.pcesion / 100) -
																													 v_iliqrea_sin;
																			 END IF;
																			 --Fin KBR 08052014
																		END IF;
																 END IF;
															
																 v_total_pag_tramos := v_total_pag_tramos + v_iliqrea_sin;
																 v_total_res_tramos := v_total_res_tramos + v_iresrea_sin;
																 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion,
																								 NULL, 6915,
																								 'Pago sin Cia: ' || v_iliqrea_sin || ' Reserva sin Cia: ' ||
																									v_iresrea_sin);
															
																 -- Añadir detalle liquidación neta y reservas netas
																 BEGIN
																		SELECT NVL(cestado, 1)
																			INTO v_cestado_cia
																			FROM ctatecnica
																		 WHERE scontra = v_movsin(sini).scontra
																			 AND nversio = v_movsin(sini).nversio
																			 AND ctramo = v_ctramo
																			 AND ccompani = compa.ccompani
																			 AND sproduc = v_movsin(sini).sproduc;
																 EXCEPTION
																		WHEN no_data_found THEN
																			 BEGIN
																					INSERT INTO ctatecnica
																						 (ccompani, nversio, scontra, ctramo, nctatec, cfrecul, cestado,
																							festado, fcierre, cempres, sproduc, ccorred)
																					VALUES
																						 (compa.ccompani, v_movsin(sini).nversio, v_movsin(sini).scontra,
																							v_ctramo, 1, 3, 1, NULL, NULL, p_pcempres, v_movsin(sini).sproduc,
																							compa.ccorred);
																			 EXCEPTION
																					WHEN OTHERS THEN
																						 v_cestado_cia := 1;
																						 p_tab_error(f_sysdate, f_user, vobj, v_traza,
																												 'XL por Eventos: Err INSERT INTO ctatecnica',
																												 ' SQLERRM = ' || SQLERRM || ' nerr = 104861');
																			 END;
																		WHEN OTHERS THEN
																			 v_cestado_cia := 1;
																			 o_plsql       := SQLERRM;
																			 p_tab_error(f_sysdate, f_user, vobj, v_traza,
																									 'XL por Eventos: Err SELECT ctatecnica',
																									 ' v_scontra=' || v_movsin(sini).scontra || ' v_nversio=' || v_movsin(sini)
																									 .nversio || ' v_ctramo=' || v_ctramo || ' compa.ccompani=' ||
																										compa.ccompani || ' SQLERRM = ' || SQLERRM ||
																										' nerr = 104863');
																 END;
															
																 --Insert en LiquidareaXL
																 BEGIN
																		p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete,
																										v_nom_funcion, NULL, 6965, 'Insert en Liquidareaxl_aux');
																 
																		INSERT INTO liquidareaxl_aux
																			 (nsinies, fsinies, itotexp, fcierre, sproces, scontra, nversio, ctramo,
																				ccompani, pcuorea, icuorea, ipagrea, iliqrea, ireserv, pcuotot, itotrea,
																				iresrea, iliqnet, iresnet, iresgas, iresindem, iresinter, iresadmin,
																				icuorea_moncon, iliqnet_moncon, iliqrea_moncon, ipagrea_moncon,
																				ireserv_moncon, iresgas_moncon, iresindem_moncon, iresinter_moncon,
																				iresadmin_moncon, iresnet_moncon, iresrea_moncon, itotexp_moncon,
																				itotrea_moncon, cevento)
																		VALUES
																			 (v_movsin(sini).nsinies, v_movsin(sini).fsinies, v_pago_idx, p_pfperfin,
																				p_pproces, v_movsin(sini).scontra, v_movsin(sini).nversio, v_ctramo,
																				compa.ccompani, v_pcuorea,
																				--% Pagos de reaseguro
																				v_icuorea,
																				--Importe de cuota del reaseguro por cia
																				v_ipagrea_mov,
																				--Liquidaciones anteriores por SINIESTRO-EVENTO
																				v_ipagrea_mov,
																				--Importe de pagos liquidados por siniestro-evento
																				v_iresrea_sin,
																				--Importe de reservas por siniestro-evento
																				v_pcuotot,
																				--% Total del Reaseguro
																				v_itotrea,
																				--Importe Total de reaseguro por cia
																				v_iresrea_mov,
																				--Importe total de reserva de reaseguro por cia
																				v_iliqrea_sin,
																				--Importe de pagos liquidados por siniestro-evento
																				v_iresrea_sin, v_iresgas, v_iresindem, v_iresinter, v_iresadmin,
																				f_round(NVL(v_icuorea, 0) * v_itasa, v_cmoncontab),
																				f_round(NVL(v_iliqrea_sin, 0) * v_itasa, v_cmoncontab),
																				f_round(NVL(v_ipagrea_mov, 0) * v_itasa, v_cmoncontab),
																				f_round(NVL(v_ipagrea_mov, 0) * v_itasa, v_cmoncontab),
																				f_round(NVL(v_iresrea_mov, 0) * v_itasa, v_cmoncontab),
																				f_round(NVL(v_iresgas, 0) * v_itasa, v_cmoncontab),
																				f_round(NVL(v_iresindem, 0) * v_itasa, v_cmoncontab),
																				f_round(NVL(v_iresinter, 0) * v_itasa, v_cmoncontab),
																				f_round(NVL(v_iresadmin, 0) * v_itasa, v_cmoncontab),
																				f_round(NVL(v_iresrea_sin, 0) * v_itasa, v_cmoncontab),
																				f_round(NVL(v_iresrea_mov, 0) * v_itasa, v_cmoncontab),
																				f_round(NVL(v_pago_idx, 0) * v_itasa, v_cmoncontab),
																				f_round(NVL(v_itotrea, 0) * v_itasa, v_cmoncontab),
																				v_movsin(sini).cevento);
																 EXCEPTION
																		WHEN dup_val_on_index THEN
																			 UPDATE liquidareaxl_aux
																					SET icuorea = icuorea + v_icuorea, iliqrea = iliqrea + v_ipagrea_mov,
																							ireserv = ireserv + v_iresrea_mov, itotrea = itotrea + v_itotrea,
																							iresrea = iresrea + v_iresrea_mov,
																							iliqnet = iliqnet + v_iliqrea_sin,
																							iresnet = iresnet + v_iresrea_sin,
																							icuorea_moncon = icuorea_moncon +
																																f_round(NVL(v_icuorea, 0) * v_itasa, v_cmoncontab),
																							iliqnet_moncon = iliqnet_moncon +
																																f_round(NVL(v_iliqrea_sin, 0) * v_itasa,
																																				v_cmoncontab),
																							iliqrea_moncon = iliqrea_moncon +
																																f_round(NVL(v_ipagrea_mov, 0) * v_itasa,
																																				v_cmoncontab),
																							ireserv_moncon = ireserv_moncon +
																																f_round(NVL(v_iresrea_mov, 0) * v_itasa,
																																				v_cmoncontab),
																							iresnet_moncon = iresnet_moncon +
																																f_round(NVL(v_iresrea_sin, 0) * v_itasa,
																																				v_cmoncontab),
																							iresrea_moncon = iresrea_moncon +
																																f_round(NVL(v_iresrea_mov, 0) * v_itasa,
																																				v_cmoncontab),
																							itotrea_moncon = itotrea_moncon +
																																f_round(NVL(v_itotrea, 0) * v_itasa, v_cmoncontab)
																				WHERE nsinies = v_movsin(sini).nsinies
																					AND fcierre = p_pfperfin
																					AND sproces = p_pproces
																					AND scontra = v_movsin(sini).scontra
																					AND nversio = v_movsin(sini).nversio
																					AND ctramo = v_ctramo
																					AND ccompani = compa.ccompani;
																		WHEN OTHERS THEN
																			 nerr := 1;
																			 p_tab_error(f_sysdate, f_user, vobj, v_traza,
																									 'Err INSERT INTO liquidareaxl_aux', 'SQLERRM = ' || SQLERRM);
																 END; --Insert en Liquidareaxl_aux
															
																 IF v_iliqrea_sin <> 0 THEN
																		--Insert Pagosreaxl_aux
																		BEGIN
																			 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete,
																											 v_nom_funcion, NULL, 7088, 'Insert en Pagosreaxl_aux');
																		
																			 INSERT INTO pagosreaxl_aux
																					(nsinies, scontra, nversio, ctramo, ccompani, fcierre, sproces,
																					 iliqrea, cestliq, iliqrea_moncon, fcambio, cevento)
																			 VALUES
																					(v_movsin(sini).nsinies, v_movsin(sini).scontra,
																					 v_movsin(sini).nversio, v_ctramo, compa.ccompani, p_pfperfin,
																					 p_pproces, v_iliqrea_sin, 0,
																					 f_round(NVL(v_iliqrea_sin, 0) * v_itasa, v_cmoncontab),
																					 DECODE(v_cmultimon, 0, NULL, NVL(v_fcambio, v_movsin(sini).fsinies)),
																					 v_movsin(sini).cevento);
																		EXCEPTION
																			 WHEN dup_val_on_index THEN
																					UPDATE pagosreaxl_aux
																						 SET iliqrea = iliqrea + v_iliqrea_sin,
																								 iliqrea_moncon = iliqrea_moncon +
																																	 f_round(NVL(v_iliqrea_sin, 0) * v_itasa,
																																					 v_cmoncontab)
																					 WHERE nsinies = v_movsin(sini).nsinies
																						 AND scontra = v_movsin(sini).scontra
																						 AND nversio = v_movsin(sini).nversio
																						 AND ctramo = v_ctramo
																						 AND ccompani = compa.ccompani
																						 AND fcierre = p_pfperfin
																						 AND sproces = p_pproces;
																			 WHEN OTHERS THEN
																					p_tab_error(f_sysdate, f_user, vobj, v_traza,
																											'Err INSERT INTO pagosreaxl', ' SQLERRM = ' || SQLERRM);
																					nerr := 1;
																		END; --Insert Pagosreaxl_aux
																 
																		-- Se actualizan pagos anteriores NO LIQUIDADOS
																		BEGIN
																			 UPDATE pagosreaxl
																					SET cestliq = 2
																				WHERE scontra = v_movsin(sini).scontra
																					AND nversio = v_movsin(sini).nversio
																					AND ctramo = v_ctramo
																					AND ccompani = compa.ccompani
																					AND fcierre < p_pfperfin
																					AND nsinies = v_movsin(sini).nsinies
																					AND cestliq = 0;
																		EXCEPTION
																			 WHEN no_data_found THEN
																					v_ipagrea := 0;
																			 WHEN OTHERS THEN
																					nerr := 1;
																					p_tab_error(f_sysdate, f_user, vobj, v_traza, 'Err UPDATE pagosreaxl',
																											' v_scontra =' || v_movsin(sini).scontra || ' v_nversio =' || v_movsin(sini)
																											.nversio || ' v_ctramo =' || v_ctramo || ' compa.ccompani=' ||
																											 compa.ccompani || ' sini.nsin=' || v_movsin(sini).nsinies ||
																											 ' p_pfperfin =' || p_pfperfin || ' SQLERRM = ' || SQLERRM);
																		END;
																 END IF;
															
																 BEGIN
																		SELECT NVL(MAX(nnumlin), 0)
																			INTO w_nnumlin
																			FROM movctaaux
																		 WHERE scontra = v_movsin(sini).scontra
																			 AND nversio = v_movsin(sini).nversio
																			 AND ctramo = v_ctramo
																			 AND ccompani = compa.ccompani;
																 
																		w_nnumlin := w_nnumlin + 1;
																 EXCEPTION
																		WHEN no_data_found THEN
																			 w_nnumlin := 1;
																		WHEN OTHERS THEN
																			 nerr    := 104863;
																			 o_plsql := SQLERRM;
																			 p_tab_error(f_sysdate, f_user, vobj, v_traza, 'Err SELECT MOVCTAAUX',
																									 ' v_scontra=' || v_movsin(sini).scontra || ' v_nversio=' || v_movsin(sini)
																									 .nversio || ' v_ctramo=' || v_ctramo || ' compa.ccompani=' ||
																										compa.ccompani || ' SQLERRM = ' || SQLERRM);
																 END;
															
																 IF v_iliqrea_sin <> 0 THEN
																		-- 5 -> Siniestros
																		p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete,
																										v_nom_funcion, NULL, 7190,
																										'Insert en movctaaux-> Concepto (5) Pago Siniestros');
																		v_movsin(sini).ctramo := v_ctramo;
																		nerr := f_insertxl_movctatecnica(w_ctadet, v_movsin(sini), w_nnumlin, 5,
																																		 compa.ccompani, v_iliqrea_sin, p_pproces,
																																		 v_cestado_cia, p_pcempres, p_pfperfin,
																																		 compa.ccorred); -- 25/05/2015  CJMR  0033158: Actualización campo CCORRED en los cierres de Reaseguro
																 END IF;
															
																 IF v_iliqrea_sin <> 0 THEN
																		-- 15 -> Liquidacion XL
																		p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete,
																										v_nom_funcion, NULL, 7203,
																										'Insert en movctaaux-> Concepto (15) Liquidacion XL');
																		v_movsin(sini).ctramo := v_ctramo;
																		nerr := f_insertxl_movctatecnica(w_ctadet, v_movsin(sini), w_nnumlin, 15,
																																		 compa.ccompani, v_iliqrea_sin, p_pproces,
																																		 v_cestado_cia, p_pcempres, p_pfperfin,
																																		 compa.ccorred); -- 25/05/2015  CJMR  0033158: Actualización campo CCORRED en los cierres de Reaseguro
																 END IF;
															
																 IF v_iresrea_sin <> 0 THEN
																		-- 25 -> Reserva de Siniestros
																		p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete,
																										v_nom_funcion, NULL, 7216,
																										'Insert en movctaaux-> Concepto (25) Reserva Siniestros');
																		v_movsin(sini).ctramo := v_ctramo;
																		nerr := f_insertxl_movctatecnica(w_ctadet, v_movsin(sini), w_nnumlin, 25,
																																		 compa.ccompani, v_iresrea_sin, p_pproces,
																																		 v_cestado_cia, p_pcempres, p_pfperfin,
																																		 compa.ccorred); -- 25/05/2015  CJMR  0033158: Actualización campo CCORRED en los cierres de Reaseguro
																 END IF;
															
																 IF v_primareest_sin <> 0 THEN
																		-- 23 -> Reinstalamento XL
																		p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete,
																										v_nom_funcion, NULL, 7232,
																										'Insert en movctaaux-> Concepto (23) Reinstalamiento XL');
																		v_movsin(sini).ctramo := v_ctramo;
																		nerr := f_insertxl_movctatecnica(w_ctadet, v_movsin(sini), w_nnumlin, 23,
																																		 compa.ccompani, v_primareest_sin, p_pproces,
																																		 v_cestado_cia, p_pcempres, p_pfperfin,
																																		 compa.ccorred); -- 25/05/2015  CJMR  0033158: Actualización campo CCORRED en los cierres de Reaseguro
																 END IF;
															END LOOP; --Cias
													 
															v_movsin(sini).pago_total_sin := v_movsin(sini).pago_total_sin - v_total_pag_tramos;
															v_movsin(sini).reserva_total_sin := v_movsin(sini)
																																	.reserva_total_sin - v_total_res_tramos;
															p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion,
																							NULL, 5845,
																							'Total Res Tramos-Sin: ' || v_total_res_tramos ||
																							 ' Total Pag Tramos-Sin: ' || v_total_pag_tramos);
													 END LOOP; --Siniestros
												END IF;
										 
												--KBR Multitramos y Reinstalaciones
												IF NVL(pac_parametros.f_parempresa_n(p_pcempres, 'PERMITE_MREPOXL_REA'), 0) = 0 THEN
													 EXIT;
												END IF;
										 END;
									END LOOP; --Reestablecimientos
							 END IF;
						
							 --KBR Multitramos y Reinstalaciones
							 IF NVL(pac_parametros.f_parempresa_n(p_pcempres, 'PERMITE_MTRAMOXL_REA'), 0) = 0 THEN
									EXIT;
							 END IF;
						END;
				 END LOOP; --Multitramos
			
				 --Fin
				 v_sin            := 0;
				 v_contador       := 0;
				 v_res_dist       := 0;
				 v_pago_idx       := 0;
				 v_pago_no_idx    := 0;
				 v_reserva        := 0;
				 v_totalpagos_ret := 0;
				 v_prea           := 0;
				 v_iced_xl        := 0;
			END IF;
	 
			--KBR 13/11/2013: Se incluye esta validacion para que el proceso no termine con error cuando no consiga contrato de reaseguro XL asociado
			--Se debe incluir un metodo para determinar cuando un ramo/producto está protegido por un contrato de reaseguro XL
			IF NVL(v_scontra, 0) = 0 THEN
				 nerr := 0;
			END IF;
	 
			p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL, 7263,
											'Fin de proceso: ' || nerr);
			COMMIT;
			RETURN(nerr);
	 END; --f_xl_eventos

	 --------------------------------------------
	 FUNCTION f_insertar_pmd(p_pcempres IN NUMBER, p_pmes IN NUMBER, p_pproces IN NUMBER, p_pfperfin IN DATE,
													 p_psql OUT VARCHAR2) RETURN NUMBER IS
			--BUG 28492/156489 - Inicio - DCT - 17/12/2013 - AÃ±adimos el PTASAXL (Porcentaje de la tasa aplicable para contratos XL
			--BUG 26663/166452 AGG 17/02/2014 Obtenemos la Frecuencia de Pago
			CURSOR prima_min_deposit IS
				 SELECT c.scontra, c.nversio, COUNT(*) pmd_anyo, tr.ctramo, tr.ctramotasaxl, tr.ptasaxl, tr.cfrepmd,
								c.fconini /* EDBR - 22/09/2019 - IAXIS5134 - Se agrega el campo vecha vigencia inicial (c.fconini) del contrato  al cursor*/
					 FROM contratos c, codicontratos t, tramos tr
					WHERE c.scontra = t.scontra
						AND t.ctiprea = 3
						AND tr.nversio = c.nversio
						AND tr.scontra = c.scontra
						AND c.fconini <= p_pfperfin
						AND c.fconfin IS NULL
					GROUP BY c.scontra, c.nversio, tr.ctramo, tr.ctramotasaxl, tr.ptasaxl, tr.cfrepmd,
								c.fconini /* EDBR - 22/09/2019 - IAXIS5134 - Se agrega el campo vecha vigencia inicial (c.fconini) del contrato  al group by del cursor*/;
	 
			--BUG 26663/166452 AGG 17/02/2014  Se aÃ±ade este nuevo cursor
			CURSOR prima_min_deposit_ramo IS
				 SELECT c.scontra, c.nversio, COUNT(*) pmd_anyo, tr.ctramo, tr.ctramotasaxl, tr.ptasaxl, tr.cfrepmd,
								cramo, c.fconini /* EDBR - 22/09/2019 - IAXIS5134 - Se agrega el campo vecha vigencia inicial (c.fconini) del contrato  al cursor*/
					 FROM contratos c, codicontratos t, tramos tr, agr_contratos ag
					WHERE c.scontra = t.scontra
						AND t.ctiprea = 3
						AND tr.nversio = c.nversio
						AND tr.scontra = c.scontra
						AND c.fconini <= p_pfperfin
						AND c.fconfin IS NULL
						AND c.scontra = ag.scontra
					GROUP BY c.scontra, c.nversio, tr.ctramo, tr.ctramotasaxl, tr.ptasaxl, tr.cfrepmd, cramo,
								c.fconini /* EDBR - 22/09/2019 - IAXIS5134 - Se agrega el campo vecha vigencia inicial (c.fconini) del contrato  al group by del cursor*/;
	 
			--BUG 28492/156489 - Fin - DCT - 17/12/2013 - AÃ±adimos el PTASAXL (Porcentaje de la tasa aplicable para contratos XL
			CURSOR c_cuadroces_agr(ctr NUMBER, ver NUMBER, tram NUMBER) IS
				 SELECT c.ccompani, c.ctramo, c.iagrega, c.imaxagr, c.pcesion, ct.fconini, 0 iminagr, ccorred
					 FROM cuadroces c, contratos ct
					WHERE c.scontra = ct.scontra
						AND c.nversio = ct.nversio
						AND c.scontra = ctr
						AND c.nversio = ver
						AND c.ctramo = tram;
	 
			CURSOR c_cuadroces_agr_ramo(ctr NUMBER, ver NUMBER, tram NUMBER, ram NUMBER) IS
				 SELECT c.ccompani, c.ctramo, c.iagrega, c.imaxagr, c.pcesion, ct.fconini, 0 iminagr, ccorred, ag.cramo
					 FROM cuadroces c, contratos ct, agr_contratos ag
					WHERE c.scontra = ct.scontra
						AND c.nversio = ct.nversio
						AND ag.scontra = c.scontra
						AND c.scontra = ctr
						AND c.nversio = ver
						AND c.ctramo = tram
						AND ag.cramo = ram;
	 
			vobj                   VARCHAR2(200) := 'PAC_REASEGURO_XL.f_insertar_pmd';
			v_pmd_anyo             NUMBER;
			v_ctramo               NUMBER;
			v_ipmd                 NUMBER;
			v_ipmd_ini             NUMBER;
			v_cfrepmd              NUMBER;
			v_numero               NUMBER;
			w_nnumlin              NUMBER;
			v_cestado              NUMBER;
			v_pagopmd              NUMBER(1);
			pmes_inici             NUMBER(2);
			v_cconcep              NUMBER(2);
			v_pctpart              NUMBER;
			v_reserv_tax           NUMBER;
			v_tax                  NUMBER;
			nerr                   NUMBER := 0;
			v_traza                NUMBER;
			w_ctadet               NUMBER(1);
			w_cconcep              movctaaux.cconcep%TYPE;
			w_cdebhab              movctaaux.cdebhab%TYPE;
			w_ptasaxl              NUMBER; --BUG 25860 ETM
			v_tasa_var             NUMBER; --BUG 25860 ETM
			v_prima_anual_retenida movctatecnica.iimport%TYPE; --BUG 25860 ETM
			v_prima_anual          movctatecnica.iimport%TYPE; --BUG 25860 ETM
			v_pagos_sin_anual      movctatecnica.iimport%TYPE; --BUG 25860 ETM
			v_siniestralitat       NUMBER; --BUG 25860 ETM
			v_tasa_var_total       NUMBER; --BUG 25860 ETM
			v_reserva_anual        liqresreaaux.icompan%TYPE; --BUG 25860 ETM
			pany                   DATE; --BUG 25860 ETM
			pmes                   NUMBER; --BUG 25860 ETM
			w_panuret              NUMBER; --BUG 25860 ETM
			v_pmd                  NUMBER := 0;
			v_frepmd               tramos.cfrepmd%TYPE;
			v_numinserts           NUMBER := 0;
			v_porcen               ctto_tramo_producto.porcen%TYPE := 0;
			v_idctto               ctto_tramo_producto.id%TYPE;
			v_porcen_det           porcen_tramo_ctto.porcen%TYPE := 0;
			reg_ramo               prima_min_deposit_ramo%ROWTYPE;
			reg                    prima_min_deposit%ROWTYPE;
			reg_compa_ramo         c_cuadroces_agr_ramo%ROWTYPE;
			reg_compa              c_cuadroces_agr%ROWTYPE;
			v_anyo                 NUMBER := 0;
			v_scontra              NUMBER := 0;
			v_nversio              NUMBER := 0;
			v_cramo                NUMBER := 0;
			v_ctramotasaxl         tramos.ctramotasaxl%TYPE;
			v_ptasaxl              tramos.ptasaxl%TYPE;
			v_ccompani             cuadroces.ccompani%TYPE;
			v_pcesion              cuadroces.pcesion%TYPE;
			-- KBR 23/05/2014 PMD GAP 13
			v_costo_fijo   tramos.icostofijo%TYPE;
			v_red_flag     NUMBER := 0;
			v_primaneta_vg NUMBER := 0;
			v_primaneta_vi NUMBER := 0;
			v_primaneta_ap NUMBER := 0;
			-- 25/05/2015  CJMR  0033158: Actualización campo CCORRED en los cierres de Reaseguro
			v_ccorred          NUMBER := 0;
			v_nom_paquete      VARCHAR2(4000) := 'PAC_REASEGURO_XL';
			v_nom_funcion      VARCHAR2(4000) := 'F_INSERTAR_PMD';
			v_ctatecnica       NUMBER;
			v_iretenido        NUMBER; --CONFCC-5
			v_mes_vig_contrato DATE; /* EDBR - 22/09/2019 - IAXIS5134 - Se agrega variable para almacenar el campo vecha vigencia inicial (c.fconini) del contrato */
	 BEGIN
			p_control_error('EDBR#0', 'f_insertar_pmd', 'Begin');
			-- Insert Prima MÃ­nima DepÃ³sito por pagos fraccionados
			-- dc_p_trazas(7777777, 'en el cierre xl paso 11');
			IF nerr = 0 THEN
				 -- dc_p_trazas(7777777, 'en el cierre xl paso 12');
				 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL, 1,
												 'Proceso insertar PMD');
			
				 p_control_error('EDBR#1', 'f_insertar_pmd',
												 'f_paramempresa PMD RAMO' || pac_parametros.f_parempresa_n(p_pcempres, 'PMD_RAMO'));
				 --CONTROL DE ANUALIDAD PARA LA PMD....
				 IF NVL(pac_parametros.f_parempresa_n(p_pcempres, 'PMD_RAMO'), 0) = 1 THEN
						OPEN prima_min_deposit_ramo;
				 ELSE
						OPEN prima_min_deposit;
				 END IF;
			
				 LOOP
						-- dc_p_trazas(7777777, 'en el cierre xl paso 13');
						p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL, 2,
														'Entra LOOP PRIMA DEPOSIT. Param (PMD_RAMO): ' ||
														 NVL(pac_parametros.f_parempresa_n(p_pcempres, 'PMD_RAMO'), 0));
				 
						p_control_error('EDBR#2', 'f_insertar_pmd',
														'f_paramempresa PMD RAMO' || pac_parametros.f_parempresa_n(p_pcempres, 'PMD_RAMO'));
						IF NVL(pac_parametros.f_parempresa_n(p_pcempres, 'PMD_RAMO'), 0) = 1 THEN
							 -- dc_p_trazas(7777777, 'en el cierre xl paso 14');
							 p_control_error('EDBR#3', 'f_insertar_pmd', 'IF TRUE');
							 FETCH prima_min_deposit_ramo
									INTO reg_ramo;
							 p_control_error('EDBR#4', 'f_insertar_pmd', 'IF TRUE AFTER FETCH');
							 EXIT WHEN prima_min_deposit_ramo%NOTFOUND;
							 p_control_error('EDBR#5', 'f_insertar_pmd', 'IF TRUE AFTER FETCH EXCEPTION');
						ELSE
							 p_control_error('EDBR#6', 'f_insertar_pmd', 'ELSE');
							 -- dc_p_trazas(7777777, 'en el cierre xl paso 15');
							 FETCH prima_min_deposit
									INTO reg;
							 p_control_error('EDBR#7', 'f_insertar_pmd', 'ELSE AFTER FETCH');
							 EXIT WHEN prima_min_deposit%NOTFOUND;
							 p_control_error('EDBR#8', 'f_insertar_pmd', 'ELSE AFTER FETCH EXCEPTION');
						END IF;
						p_control_error('EDBR#9', 'f_insertar_pmd', 'ELSE AFTER FETCH');
				 
						v_pmd_anyo := 0;
						v_traza    := 27;
				 
						IF NVL(pac_parametros.f_parempresa_n(p_pcempres, 'PMD_RAMO'), 0) = 1 THEN
							 -- dc_p_trazas(7777777, 'en el cierre xl paso 16');
							 v_ctramo := reg_ramo.ctramo;
							 --BUG 26663/166452 AGG 17/02/2014
							 v_frepmd       := reg_ramo.cfrepmd;
							 v_anyo         := reg_ramo.pmd_anyo;
							 v_scontra      := reg_ramo.scontra;
							 v_nversio      := reg_ramo.nversio;
							 v_cramo        := reg_ramo.cramo;
							 v_ctramotasaxl := reg_ramo.ctramotasaxl;
							 v_ptasaxl      := reg_ramo.ptasaxl;
							 p_control_error('EDBR#10', 'f_insertar_pmd',
															 'IF true BEFORE v_mes_vig_contrato: ' || v_mes_vig_contrato);
							 v_mes_vig_contrato := reg_ramo.fconini; /* EDBR - 22/09/2019 - IAXIS5134 - Se asigna el campo vecha vigencia inicial (c.fconini) del contrato a la variable*/
							 p_control_error('EDBR#11', 'f_insertar_pmd',
															 'IF true AFTER v_mes_vig_contrato: ' || v_mes_vig_contrato);
						ELSE
							 -- dc_p_trazas(7777777, 'en el cierre xl paso 17');
							 v_ctramo       := reg.ctramo;
							 v_frepmd       := reg.cfrepmd;
							 v_anyo         := reg.pmd_anyo;
							 v_scontra      := reg.scontra;
							 v_nversio      := reg.nversio;
							 v_ctramotasaxl := reg.ctramotasaxl;
							 v_ptasaxl      := reg.ptasaxl;
							 p_control_error('EDBR#12', 'f_insertar_pmd',
															 'ELSE BEFORE v_mes_vig_contrato: ' || v_mes_vig_contrato);
							 v_mes_vig_contrato := reg_ramo.fconini; /* EDBR - 22/09/2019 - IAXIS5134 - Se asigna el campo vecha vigencia inicial (c.fconini) del contrato a la variable*/
							 p_control_error('EDBR#13', 'f_insertar_pmd',
															 'ELSE AFTER v_mes_vig_contrato: ' || v_mes_vig_contrato);
						END IF;
				 
						v_pmd := 0;
						p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL, 3,
														'Anyo: ' || v_anyo);
				 
						-- dc_p_trazas(7777777, 'en el cierre xl paso 18');
						IF v_anyo = 1 THEN
							 -- dc_p_trazas(7777777, 'en el cierre xl paso 19');
							 BEGIN
									SELECT ipmd, NVL(cfrepmd, 12)
										INTO v_ipmd_ini, v_cfrepmd
										FROM tramos
									 WHERE scontra = v_scontra
										 AND nversio = v_nversio
										 AND ctramo = v_ctramo;
							 EXCEPTION
									WHEN OTHERS THEN
										 nerr   := 104714;
										 p_psql := SQLERRM;
										 p_tab_error(f_sysdate, f_user, vobj, v_traza, 'SELECT ipmd, cfrepmd',
																 ' pmd.scontra=' || v_scontra || ' pmd.nversio=' || v_nversio || ' SQLERRM = ' ||
																	SQLERRM);
							 END;
						
							 v_traza := 28;
							 -- dc_p_trazas(7777777, 'en el cierre xl paso 20');
							 -- AGG 17/02/2014
							 IF NVL(pac_parametros.f_parempresa_n(p_pcempres, 'PMD_RAMO'), 0) = 1 THEN
									-- dc_p_trazas(7777777, 'en el cierre xl paso 21, v_scontra:'||v_scontra||' v_nversio:'||v_nversio
									--                     ||' v_ctramo:'||v_ctramo||' v_cramo:'||v_cramo);
									BEGIN
										 SELECT id, porcen
											 INTO v_idctto, v_porcen
											 FROM ctto_tramo_producto
											WHERE scontra = v_scontra
												AND nversio = v_nversio
												AND ctramo = v_ctramo
												AND cramo = v_cramo;
									EXCEPTION
										 WHEN no_data_found THEN
												v_idctto := 0;
												v_porcen := 0;
										 WHEN too_many_rows THEN
												--Si hay mas de un producto configurado por Ramo se obtiene el primero
												--ya que asumimos que es la misma configuraciÃ³n para todos los productos
												--En otro caso se deberÃ¡ modificar el proceso.
												-- INI - CJAD - 18/SEP2019 - IAXIS5317 - Errores en proceso de pre cierre  
												BEGIN
													 --FIN - CJAD - 18/SEP2019 - IAXIS5317 - Errores en proceso de pre cierre 
													 SELECT id, porcen
														 INTO v_idctto, v_porcen
														 FROM ctto_tramo_producto
														WHERE scontra = v_scontra
															AND nversio = v_nversio
															AND ctramo = v_ctramo
															AND cramo = v_cramo
															AND ROWNUM = 1;
													 -- INI - CJAD - 18/SEP2019 - IAXIS5317 - Errores en proceso de pre cierre  
												EXCEPTION
													 WHEN no_data_found THEN
															v_idctto := 0;
															v_porcen := 0;
												END;
												-- FIN - CJAD - 18/SEP2019 - IAXIS5317 - Errores en proceso de pre cierre
										 WHEN OTHERS THEN
												nerr   := 104714;
												p_psql := SQLERRM;
												p_tab_error(f_sysdate, f_user, vobj, v_traza, 'SELECT ID, porcen',
																		' scontra=' || v_scontra || ' nversio=' || v_nversio || ' ctramo=' ||
																		 v_ctramo || ' cramo=' || v_cramo || ' SQLERRM = ' || SQLERRM);
									END;
							 END IF;
							 -- dc_p_trazas(7777777, 'en el cierre xl paso 22, v_porcen:'||v_porcen);
							 IF NVL(pac_parametros.f_parempresa_n(p_pcempres, 'PMD_RAMO'), 0) = 1 THEN
									-- dc_p_trazas(7777777, 'en el cierre xl paso 23');
									OPEN c_cuadroces_agr_ramo(v_scontra, v_nversio, v_ctramo, v_cramo);
							 ELSE
									-- dc_p_trazas(7777777, 'en el cierre xl paso 24');
									OPEN c_cuadroces_agr(v_scontra, v_nversio, v_ctramo);
							 END IF;
						
							 LOOP
									-- dc_p_trazas(7777777, 'en el cierre xl paso 25');
									IF NVL(pac_parametros.f_parempresa_n(p_pcempres, 'PMD_RAMO'), 0) = 1 THEN
										 -- dc_p_trazas(7777777, 'en el cierre xl paso 26');
										 FETCH c_cuadroces_agr_ramo
												INTO reg_compa_ramo;
									
										 EXIT WHEN c_cuadroces_agr_ramo%NOTFOUND;
										 v_ccompani := reg_compa_ramo.ccompani;
										 v_pcesion  := reg_compa_ramo.pcesion;
										 v_ccorred  := reg_compa_ramo.ccorred; -- 25/05/2015  CJMR  0033158: Actualización campo CCORRED en los cierres de Reaseguro
									ELSE
										 -- dc_p_trazas(7777777, 'en el cierre xl paso 27');
										 FETCH c_cuadroces_agr
												INTO reg_compa;
									
										 EXIT WHEN c_cuadroces_agr%NOTFOUND;
										 v_ccompani := reg_compa.ccompani;
										 v_pcesion  := reg_compa.pcesion;
										 v_ccorred  := reg_compa.ccorred; -- 25/05/2015  CJMR  0033158: Actualización campo CCORRED en los cierres de Reaseguro
									END IF;
							 
									-->> Cursor sobre CUADROCES por scontra y nversio
									-- FOR compa IN c_cuadroces_agr(v_scontra, v_nversio, v_ctramo) LOOP
									v_pmd := 0;
									-- 1. insertem un cop el concepte 20 (CTIPCTA=3 - CTA.CIPOSIT) nomÃ©s el pimer mes (LCOL!!!)
									v_cconcep := 20;
							 
									IF NVL(pac_parametros.f_parempresa_n(p_pcempres, 'PMD_RAMO'), 0) = 1 THEN
										 -- dc_p_trazas(7777777, 'en el cierre xl paso 27_1');
									
										 -- INI - CJAD - 18/SEP2019 - IAXIS5317 - Errores en proceso de pre cierre  
										 BEGIN
												--FIN - CJAD - 18/SEP2019 - IAXIS5317 - Errores en proceso de pre cierre 
												SELECT COUNT(1)
													INTO v_numero
													FROM movctaaux
												 WHERE scontra = v_scontra
													 AND nversio = v_nversio
													 AND ctramo = v_ctramo
													 AND ccompani = v_ccompani
													 AND cconcep = v_cconcep
													 AND cramo = v_cramo;
												-- INI - CJAD - 18/SEP2019 - IAXIS5317 - Errores en proceso de pre cierre  
										 EXCEPTION
												WHEN no_data_found THEN
													 v_numero := 0;
										 END;
										 -- FIN - CJAD - 18/SEP2019 - IAXIS5317 - Errores en proceso de pre cierre     
									
										 -- dc_p_trazas(7777777, 'en el cierre xl paso 27_2');
									ELSE
										 -- dc_p_trazas(7777777, 'en el cierre xl paso 27_3');
										 -- INI - CJAD - 18/SEP2019 - IAXIS5317 - Errores en proceso de pre cierre  
										 BEGIN
												--FIN - CJAD - 18/SEP2019 - IAXIS5317 - Errores en proceso de pre cierre 
												SELECT COUNT(1)
													INTO v_numero
													FROM movctaaux
												 WHERE scontra = v_scontra
													 AND nversio = v_nversio
													 AND ctramo = v_ctramo
													 AND ccompani = v_ccompani
													 AND cconcep = v_cconcep;
												-- INI - CJAD - 18/SEP2019 - IAXIS5317 - Errores en proceso de pre cierre  
										 EXCEPTION
												WHEN no_data_found THEN
													 v_numero := 0;
										 END;
										 -- FIN - CJAD - 18/SEP2019 - IAXIS5317 - Errores en proceso de pre cierre
									
										 -- dc_p_trazas(7777777, 'en el cierre xl paso 27_4');
									END IF;
									p_control_error('EDBR#14', 'f_insertar_pmd', 'BEFORE IF v_numero: ' || v_numero);
									-- dc_p_trazas(7777777, 'en el cierre xl paso 28');
									IF v_numero = 0 THEN
										 -- dc_p_trazas(7777777, 'en el cierre xl paso 29');
										 --<DBMS_OUTPUT.put_line('>>> pmd.scontra:' || pmd.scontra || ' pmd.nversio:'
										 --<                     || pmd.nversio || ' v_ctramo=' || v_ctramo
										 --<                     || ' compa.ccompani:' || compa.ccompani);
										 -------------------------------------------------------------------------------------------------------
										 -- 22076/22678 AVT 18/09/2012 nomÃ©s ralitzem pagaments de PMD els mesos que toca per fraccionament   --
										 -------------------------------------------------------------------------------------------------------
										 p_control_error('EDBR#15', 'f_insertar_pmd',
																		 'BEFORE IF IMPORTANTE p_pmes: ' || p_pmes || ' P_PFPERFIN: ' || p_pfperfin);
										 p_control_error('EDBR#16', 'f_insertar_pmd',
																		 'BEFORE IF IMPORTANTE char MM mes vig contrato: ' ||
																			TO_CHAR(v_mes_vig_contrato, 'MM') || ' char YYYY p_perfin: ' ||
																			TO_CHAR(p_pfperfin, 'YYYY'));
										 p_control_error('EDBR#17', 'f_insertar_pmd',
																		 'BEFORE IF IMPORTANTE char YYYY mes vig contrato: ' ||
																			TO_CHAR(v_mes_vig_contrato, 'YYYY'));
										 --<DBMS_OUTPUT.put_line('>>> v_ipmd_ini:' || v_ipmd_ini);
										 IF NVL(v_ipmd_ini, 0) <> 0 AND nerr = 0 AND p_pmes = TO_CHAR(v_mes_vig_contrato, 'MM') AND
												TO_CHAR(p_pfperfin, 'YYYY') = TO_CHAR(v_mes_vig_contrato, 'YYYY') THEN
												/* EDBR - 22/09/2019 - IAXIS5134 - Se agrega validacion de mes y año */
												-- dc_p_trazas(7777777, 'en el cierre xl paso 30');
												w_nnumlin := w_nnumlin + 1;
										 
												-- 22076 AVT 18/09/2012 ESTAT DEL COMPTE = 4 PER COMPTES DE DIPOSIT (CTIPCTA= 3)
												-- (NO TE DESCIRPCIÃ“ AL VF: 800106 PERQUE NO ES PUGUI GESTIONAR DES DE LA LIQUIDACIÃ“)
												IF NVL(pac_parametros.f_parempresa_n(p_pcempres, 'TIPOCTAREA'), 0) = 1 THEN
													 -- dc_p_trazas(7777777, 'en el cierre xl paso 31');
													 BEGIN
															SELECT NVL(DECODE(ctipcta, 3, 4, 1), 1)
																INTO v_cestado
																FROM tipoctarea
															 WHERE cconcep = v_cconcep;
													 EXCEPTION
															-- INI - CJAD - 18/SEP2019 - IAXIS5317 - Errores en proceso de pre cierre  
															WHEN no_data_found THEN
																 v_cestado := 1;
																 -- FIN - CJAD - 18/SEP2019 - IAXIS5317 - Errores en proceso de pre cierre
															WHEN OTHERS THEN
																 nerr   := 1;
																 p_psql := SQLERRM;
																 p_tab_error(f_sysdate, f_user, vobj, v_traza, 'SELECT tipoctarea cconcep: 20',
																						 ' pmd.scontra=' || v_scontra || ' pmd.nversio=' || v_nversio ||
																							' v_ctramo=' || v_ctramo || ' compa.ccompani:' || v_ccompani ||
																							' SQLERRM = ' || SQLERRM);
													 END;
												END IF;
										 
												IF nerr = 0 THEN
													 v_traza := 29;
												
													 IF v_porcen > 0 THEN
															-- dc_p_trazas(7777777, 'en el cierre xl paso 31_1');
															v_ipmd := ((((v_ipmd_ini * v_porcen / 100) * v_porcen) / 100) * v_pcesion) / 100;
															-- dc_p_trazas(7777777, 'en el cierre xl paso 31_2');
													 ELSE
															-- dc_p_trazas(7777777, 'en el cierre xl paso 31_3');
															-- KBR 26/05/2014
															IF NVL(pac_parametros.f_parempresa_n(p_pcempres, 'PMD_RAMO'), 0) = 1 THEN
																 v_ipmd := 0;
															ELSE
																 v_ipmd := (v_ipmd_ini * v_pcesion) / 100;
															END IF;
															-- KBR 26/05/2014
													 END IF;
												
													 v_traza := 30;
													 -- dc_p_trazas(7777777, 'en el cierre xl paso 32');
													 --<DBMS_OUTPUT.put_line('>>> por cia ->  v_ipmd:' || v_ipmd);
													 --KBR 11/12/2013
													 IF v_ipmd <> 0 THEN
															-- dc_p_trazas(7777777, 'en el cierre xl paso 33');
															BEGIN
																 SELECT NVL(cestado, 1)
																	 INTO v_ctatecnica
																	 FROM ctatecnica
																	WHERE cempres = p_pcempres
																		AND scontra = v_scontra
																		AND nversio = v_nversio
																		AND ctramo = v_ctramo
																		AND ccompani = v_ccompani;
															EXCEPTION
																 WHEN no_data_found THEN
																		-- INI - CJAD - 18/SEP2019 - IAXIS5317 - Errores en proceso de pre cierre  
																		BEGIN
																			 --FIN - CJAD - 18/SEP2019 - IAXIS5317 - Errores en proceso de pre cierre 
																			 INSERT INTO ctatecnica
																					(ccompani, nversio, scontra, ctramo, nctatec, cfrecul, cestado,
																					 festado, fcierre, cempres, ccorred)
																			 VALUES
																					(v_ccompani, v_nversio, v_scontra, v_ctramo, 1, 3, 1, NULL, NULL,
																					 p_pcempres, v_ccorred);
																			 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete,
																											 v_nom_funcion, NULL, 14,
																											 'Inserto en ctatecnica - v_ccompani: ' || v_ccompani ||
																												' v_nversio: ' || v_nversio || ' v_scontra: ' ||
																												v_scontra || ' v_ctramo' || v_ctramo || ' p_pcempres: ' ||
																												p_pcempres || ' v_ccorred: ' || v_ccorred);
																			 -- INI - CJAD - 18/SEP2019 - IAXIS5317 - Errores en proceso de pre cierre  
																		EXCEPTION
																			 WHEN OTHERS THEN
																					p_tab_error(f_sysdate, f_user, vobj, v_traza,
																											'Inserto en ctatecnica - v_ccompani: ' || v_ccompani ||
																											 ' v_nversio: ' || v_nversio || ' v_scontra: ' || v_scontra ||
																											 ' v_ctramo' || v_ctramo || ' p_pcempres: ' || p_pcempres ||
																											 ' v_ccorred: ' || v_ccorred, 'Error insercion',
																											' SQLERRM = ' || SQLERRM);
																			 
																		END;
																		-- FIN - CJAD - 18/SEP2019 - IAXIS5317 - Errores en proceso de pre cierre 
															
															END;
													 
															BEGIN
																 p_control_error('EDBR#19', 'f_insertar_pmd',
																								 ' before into movctaaux concep:= ' || v_cconcep);
																 INSERT INTO movctaaux
																		(ccompani, nversio, scontra, ctramo, nnumlin, fmovimi, fefecto, cconcep,
																		 cdebhab, iimport, cestado, sproces, scesrea, cempres, fcierre, cramo,
																		 ccorred) -- 25/05/2015  CJMR  0033158: Actualización campo CCORRED en los cierres de Reaseguro
																 VALUES
																		(v_ccompani, v_nversio, v_scontra, v_ctramo, w_nnumlin, p_pfperfin,
																		 p_pfperfin, v_cconcep, 1, v_ipmd, v_cestado, p_pproces, NULL, p_pcempres,
																		 p_pfperfin, v_cramo, v_ccorred); -- 25/05/2015  CJMR  0033158: Actualización campo CCORRED en los cierres de Reaseguro
															EXCEPTION
																 WHEN dup_val_on_index THEN
																		nerr   := 105800;
																		p_psql := SQLERRM;
																		p_tab_error(f_sysdate, f_user, vobj, v_traza,
																								'INSERT INTO movctaaux cconcep: 20',
																								' pmd.scontra=' || v_scontra || ' pmd.nversio=' || v_nversio ||
																								 ' v_ctramo=' || v_ctramo || ' compa.ccompani:' || v_ccompani ||
																								 ' SQLERRM = ' || SQLERRM);
																 WHEN OTHERS THEN
																		nerr   := 105802;
																		p_psql := SQLERRM;
																		p_tab_error(f_sysdate, f_user, vobj, v_traza,
																								'INSERT INTO movctaaux cconcep: 20',
																								' pmd.scontra=' || v_scontra || ' pmd.nversio=' || v_nversio ||
																								 ' v_ctramo=' || v_ctramo || ' compa.ccompani:' || v_ccompani ||
																								 ' SQLERRM = ' || SQLERRM);
															END;
															p_control_error('EDBR#20', 'f_insertar_pmd',
																							' after into movctaaux concep:= ' || v_cconcep);
													 END IF;
												END IF;
										 
												IF nerr = 0 THEN
													 ------------------------------------------------------
													 -- AquÃ­ se contabilizan las tax --
													 -----------------------------------------------------
													 -- buscamos el tramo de impuestos
													 BEGIN
															v_traza := 98;
															-- dc_p_trazas(7777777, 'en el cierre xl paso 34');
															SELECT cd.pctpart
																INTO v_pctpart
																FROM companias cc, clausulas_reas_det cd, cod_clausulas_reas cr
															 WHERE cc.ccompani = v_ccompani
																 AND cc.ctramtax = cd.ctramo
																 AND cd.ccodigo = cr.ccodigo
																 AND cr.ctipo = 5 --Tipo:3 TAXES/TASAS VF:346---ETM MIRAR DE CREAR PATCH RSA
																 AND p_pfperfin > cr.fefecto
																 AND (p_pfperfin <= cr.fvencim OR cr.fvencim IS NULL);
													 
															v_reserv_tax := v_ipmd * v_pctpart / 100;
															w_cconcep    := 26;
															w_cdebhab    := 2;
													 
															--KBR 11/12/2013
															IF v_reserv_tax <> 0 THEN
																 -- dc_p_trazas(7777777, 'en el cierre xl paso 35');
																 BEGIN
																		SELECT NVL(cestado, 1)
																			INTO v_ctatecnica
																			FROM ctatecnica
																		 WHERE cempres = p_pcempres
																			 AND scontra = v_scontra
																			 AND nversio = v_nversio
																			 AND ctramo = v_ctramo
																			 AND ccompani = v_ccompani;
																 EXCEPTION
																		WHEN no_data_found THEN
																			 -- INI - CJAD - 18/SEP2019 - IAXIS5317 - Errores en proceso de pre cierre  
																			 BEGIN
																					--FIN - CJAD - 18/SEP2019 - IAXIS5317 - Errores en proceso de pre cierre 
																					INSERT INTO ctatecnica
																						 (ccompani, nversio, scontra, ctramo, nctatec, cfrecul, cestado,
																							festado, fcierre, cempres, ccorred)
																					VALUES
																						 (v_ccompani, v_nversio, v_scontra, v_ctramo, 1, 3, 1, NULL, NULL,
																							p_pcempres, v_ccorred);
																			 
																					-- INI - CJAD - 18/SEP2019 - IAXIS5317 - Errores en proceso de pre cierre  
																			 EXCEPTION
																					WHEN OTHERS THEN
																						 p_tab_error(f_sysdate, f_user, vobj, v_traza,
																												 'Inserto en ctatecnica - v_ccompani: ' || v_ccompani ||
																													' v_nversio: ' || v_nversio || ' v_scontra: ' ||
																													v_scontra || ' v_ctramo' || v_ctramo || ' p_pcempres: ' ||
																													p_pcempres || ' v_ccorred: ' || v_ccorred,
																												 'Error insercion', ' SQLERRM = ' || SQLERRM);
																			 END;
																			 -- FIN - CJAD - 18/SEP2019 - IAXIS5317 - Errores en proceso de pre cierre 
																 END;
															
																 BEGIN
																		INSERT INTO movctaaux
																			 (ccompani, nversio, scontra, ctramo, nnumlin, fmovimi, fefecto, cconcep,
																				cdebhab, iimport, cestado, sproces, scesrea, cempres, fcierre, ccorred) -- 25/05/2015  CJMR  0033158: Actualización campo CCORRED en los cierres de Reaseguro
																		VALUES
																			 (v_ccompani, v_nversio, v_scontra, v_ctramo, w_nnumlin, p_pfperfin,
																				p_pfperfin, v_cconcep, 1, v_reserv_tax, v_cestado, p_pproces, NULL,
																				p_pcempres, p_pfperfin, v_ccorred); -- 25/05/2015  CJMR  0033158: Actualización campo CCORRED en los cierres de Reaseguro
																 EXCEPTION
																		WHEN OTHERS THEN
																			 p_tab_error(f_sysdate, f_user, vobj, v_traza,
																									 'INSERT INTO movctaaux cconcep: 26',
																									 ' pmd.scontra=' || v_scontra || ' pmd.nversio=' || v_nversio ||
																										' v_ctramo=' || v_ctramo || ' compa.ccompani:' || v_ccompani ||
																										' SQLERRM = ' || SQLERRM);
																			 nerr   := 105802;
																			 p_psql := SQLERRM;
																 END;
															END IF;
													 EXCEPTION
															WHEN no_data_found THEN
																 NULL; -- no hay tax en esta cia
															WHEN OTHERS THEN
																 p_tab_error(f_sysdate, f_user, vobj, v_traza,
																						 'INSERT INTO movctaaux cconcep: 26',
																						 ' pmd.scontra=' || v_scontra || ' pmd.nversio=' || v_nversio ||
																							' v_ctramo=' || v_ctramo || ' compa.ccompani:' || v_ccompani ||
																							' SQLERRM = ' || SQLERRM);
																 nerr   := 105802;
																 p_psql := SQLERRM;
													 END;
												END IF;
										 END IF;
									END IF;
							 
									-- KBR 23/05/2014 PMD GAP 13
									v_red_flag   := 0;
									v_porcen_det := 0;
									-- dc_p_trazas(7777777, 'en el cierre xl paso 36');
									IF nerr = 0 THEN
										 -- dc_p_trazas(7777777, 'en el cierre xl paso 37, v_porcen:'||v_porcen);
										 pmes_inici := NVL(pac_parametros.f_parempresa_n(p_pcempres, 'MESINI_FREPMD_XL'), 0); -- parametritzat per Client
										 v_pagopmd  := 0; -- mes que no es realita Pagament de PMD (cconcep = 22)
									
										 --AGG obtenemos el valor del porcentaje de detalle
										 -- KBR 22/05/2014 Pagos irregulares de las PMD Gap 13
										 IF v_porcen > 0 THEN
												-- dc_p_trazas(7777777, 'en el cierre xl paso 38');
												--Identificamos el mes de inicio para calcular el % de pago de la PMD de la cuota correspondiente.
												--Lo haremos un mes antes para que el usuario pueda gestionar el pago con un margen de tiempo mayor.
												--Hacemos una excepciÃ³n para Enero, ya que se calcularÃ¡ ese mismo mes dado que no se podrÃ¡
												--generar antes del inicio de vigencia del contrato.
												BEGIN
													 SELECT NVL(TO_NUMBER(TO_CHAR(MIN(fpago), 'MM')), 1) - 1
														 INTO pmes_inici
														 FROM porcen_tramo_ctto
														WHERE idcabecera = v_idctto
															AND (fbaja >= p_pfperfin OR fbaja IS NULL)
															AND (TO_NUMBER(TO_CHAR(fpago, 'MM')) > TO_NUMBER(TO_CHAR(p_pfperfin, 'MM')) OR
																	(TO_NUMBER(TO_CHAR(fpago, 'MM')) = 1 AND
																	TO_NUMBER(TO_CHAR(p_pfperfin, 'MM')) = 1));
												EXCEPTION
													 WHEN no_data_found THEN
															pmes_inici := 0;
													 WHEN OTHERS THEN
															nerr   := 9906724;
															p_psql := SQLERRM;
															p_tab_error(f_sysdate, f_user, vobj, v_traza, 'SELECT fpago PORCEN_TRAMO_CTTO ',
																					' idcabecera=' || v_idctto || ' SQLERRM = ' || SQLERRM);
												END;
										 
												--Obtenemos el % de pago de la cuota de la PMD que le corresponde en el mes anterior a la
												--fecha de pago configurada para el contrato/tramo.
												--Sino se obtiene el % no se deberÃ¡ realizar el insert del pago en la MOVCTAAUX (v_red_flag)
												BEGIN
													 SELECT porcen
														 INTO v_porcen_det
														 FROM porcen_tramo_ctto
														WHERE idcabecera = v_idctto
															AND (fbaja >= p_pfperfin OR fbaja IS NULL)
															AND TO_NUMBER(TO_CHAR(fpago, 'MM')) = pmes_inici + 1
															AND p_pmes = DECODE(pmes_inici, 0, 1, pmes_inici);
												EXCEPTION
													 WHEN no_data_found THEN
															v_porcen_det := 0;
													 WHEN OTHERS THEN
															nerr   := 9906724;
															p_psql := SQLERRM;
															p_tab_error(f_sysdate, f_user, vobj, v_traza, 'SELECT porcen PORCEN_TRAMO_CTTO ',
																					' idcabecera=' || v_idctto || ' SQLERRM = ' || SQLERRM);
												END;
										 
												IF pmes_inici = 0 THEN
													 pmes_inici := 1;
												END IF;
										 
												IF v_porcen_det = 0 THEN
													 v_red_flag := 1;
												END IF;
										 END IF;
									
										 -- KBR 22/05/2014 Pagos irregulares de las PMD Gap 13
									
										 --BUG 0023830 - INICIO - DCT - 20/12/2013 - Quitar el pmes = pmes_inici + 12
										 -- dc_p_trazas(7777777, 'en el cierre xl paso 39, v_cfrepmd:'||v_cfrepmd);
										 IF v_cfrepmd = 12 AND p_pmes >= pmes_inici AND v_red_flag = 0 THEN
												-- FreqÃ¼Ã¨ncia de pago PMD  Mensual
												v_pagopmd := 1; -->> tots els mesos a partir del primer mes
										 ELSIF v_cfrepmd = 6 -- FreqÃ¼Ã¨ncia de pago PMD  Bimestral
													 AND (p_pmes = pmes_inici OR p_pmes = pmes_inici + 02 OR p_pmes = pmes_inici + 04 OR
													 p_pmes = pmes_inici + 06 OR p_pmes = pmes_inici + 08 OR p_pmes = pmes_inici + 10) AND
													 v_red_flag = 0 THEN
												v_pagopmd := 1;
										 ELSIF v_cfrepmd = 4 -- FreqÃ¼Ã¨ncia de pago PMD  Trimestral
													 AND (p_pmes = pmes_inici OR p_pmes = pmes_inici + 03 OR p_pmes = pmes_inici + 06 OR
													 p_pmes = pmes_inici + 09) AND v_red_flag = 0 THEN
												v_pagopmd := 1;
										 ELSIF v_cfrepmd = 3 -- FreqÃ¼Ã¨ncia de pago PMD  Quatrimestral
													 AND (p_pmes = pmes_inici OR p_pmes = pmes_inici + 04 OR p_pmes = pmes_inici + 08) AND
													 v_red_flag = 0 THEN
												v_pagopmd := 1;
										 ELSIF v_cfrepmd = 2 -- FreqÃ¼Ã¨ncia de pago PMD  Semestral
													 AND (p_pmes = pmes_inici OR p_pmes = pmes_inici + 06) AND v_red_flag = 0 THEN
												v_pagopmd := 1;
										 ELSIF v_cfrepmd = 1 -- FreqÃ¼Ã¨ncia de pago PMD  Anual
													 AND (p_pmes = pmes_inici) AND v_red_flag = 0 THEN
												v_pagopmd := 1;
										 END IF;
										 -- dc_p_trazas(7777777, 'en el cierre xl paso 40, v_cfrepmd:'||v_cfrepmd);
										 --BUG 0023830 - FIN - DCT - 20/12/2013 - Quitar el pmes = pmes_inici + 12
										 IF v_pagopmd = 1 THEN
												-- paguem concepte 22
												-- dc_p_trazas(7777777, 'en el cierre xl paso 41, v_cfrepmd:'||v_cfrepmd);
												v_cconcep := 22;
												v_ipmd    := 0; -- KBR 26/05/2014
										 
												IF NVL(pac_parametros.f_parempresa_n(p_pcempres, 'PMD_RAMO'), 0) = 1 THEN
												
													 -- INI - CJAD - 18/SEP2019 - IAXIS5317 - Errores en proceso de pre cierre  
													 BEGIN
															--FIN - CJAD - 18/SEP2019 - IAXIS5317 - Errores en proceso de pre cierre 
													 
															SELECT COUNT(1)
																INTO v_numero
																FROM movctaaux
															 WHERE scontra = v_scontra
																 AND nversio = v_nversio
																 AND ctramo = v_ctramo
																 AND ccompani = v_ccompani
																 AND cconcep = v_cconcep
																 AND cramo = v_cramo
																 AND TRUNC(fcierre) = TRUNC(p_pfperfin);
															-- INI - CJAD - 18/SEP2019 - IAXIS5317 - Errores en proceso de pre cierre  
													 EXCEPTION
															WHEN no_data_found THEN
																 v_numero := 0;
													 END;
													 -- FIN - CJAD - 18/SEP2019 - IAXIS5317 - Errores en proceso de pre cierre 
												
													 --BUG 26663/166452 AGG 17/02/2014
													 --AGG controlamos si se han insertado todos los registros correspondientes a
													 --cada una de las cuotas definidas en la tabla tramos
													 -- INI - CJAD - 18/SEP2019 - IAXIS5317 - Errores en proceso de pre cierre  
													 BEGIN
															--FIN - CJAD - 18/SEP2019 - IAXIS5317 - Errores en proceso de pre cierre 
															SELECT COUNT(1)
																INTO v_numinserts
																FROM movctaaux
															 WHERE scontra = v_scontra
																 AND nversio = v_nversio
																 AND ctramo = v_ctramo
																 AND ccompani = v_ccompani
																 AND cconcep = v_cconcep
																 AND cramo = v_cramo;
															-- INI - CJAD - 18/SEP2019 - IAXIS5317 - Errores en proceso de pre cierre  
													 EXCEPTION
															WHEN no_data_found THEN
																 v_numinserts := 0;
													 END;
													 -- FIN - CJAD - 18/SEP2019 - IAXIS5317 - Errores en proceso de pre cierre 
												ELSE
													 -- INI - CJAD - 18/SEP2019 - IAXIS5317 - Errores en proceso de pre cierre  
													 BEGIN
															--FIN - CJAD - 18/SEP2019 - IAXIS5317 - Errores en proceso de pre cierre 
															SELECT COUNT(1)
																INTO v_numero
																FROM movctaaux
															 WHERE scontra = v_scontra
																 AND nversio = v_nversio
																 AND ctramo = v_ctramo
																 AND ccompani = v_ccompani
																 AND cconcep = v_cconcep
																 AND TRUNC(fcierre) = TRUNC(p_pfperfin);
															-- INI - CJAD - 18/SEP2019 - IAXIS5317 - Errores en proceso de pre cierre  
													 EXCEPTION
															WHEN no_data_found THEN
																 v_numero := 0;
													 END;
													 -- FIN - CJAD - 18/SEP2019 - IAXIS5317 - Errores en proceso de pre cierre 
												
													 --BUG 26663/166452 AGG 17/02/2014
													 --AGG controlamos si se han insertado todos los registros correspondientes a
													 --cada una de las cuotas definidas en la tabla tramos
													 -- INI - CJAD - 18/SEP2019 - IAXIS5317 - Errores en proceso de pre cierre  
													 BEGIN
															--FIN - CJAD - 18/SEP2019 - IAXIS5317 - Errores en proceso de pre cierre 
															SELECT COUNT(1)
																INTO v_numinserts
																FROM movctaaux
															 WHERE scontra = v_scontra
																 AND nversio = v_nversio
																 AND ctramo = v_ctramo
																 AND ccompani = v_ccompani
																 AND cconcep = v_cconcep;
															-- INI - CJAD - 18/SEP2019 - IAXIS5317 - Errores en proceso de pre cierre  
													 EXCEPTION
															WHEN no_data_found THEN
																 v_numinserts := 0;
													 END;
													 -- FIN - CJAD - 18/SEP2019 - IAXIS5317 - Errores en proceso de pre cierre 
												END IF;
												-- dc_p_trazas(7777777, 'en el cierre xl paso 42');
												IF (v_numero = 0) AND (v_frepmd >= v_numinserts) THEN
													 IF NVL(pac_parametros.f_parempresa_n(p_pcempres, 'TIPOCTAREA'), 0) = 1 THEN
															-- INI - CJAD - 18/SEP2019 - IAXIS5317 - Errores en proceso de pre cierre  
															BEGIN
																 -- FIN - CJAD - 18/SEP2019 - IAXIS5317 - Errores en proceso de pre cierre 
																 SELECT NVL(DECODE(ctipcta, 3, 4, 1), 1)
																	 INTO v_cestado
																	 FROM tipoctarea
																	WHERE cconcep = v_cconcep;
																 -- INI - CJAD - 18/SEP2019 - IAXIS5317 - Errores en proceso de pre cierre  
															EXCEPTION
																 WHEN no_data_found THEN
																		v_cestado := 1;
															END;
															-- FIN - CJAD - 18/SEP2019 - IAXIS5317 - Errores en proceso de pre cierre 
													 END IF;
												
													 IF v_porcen_det > 0 THEN
															--AGG tenemos definido un porcentaje de detalle
															v_ipmd := (((v_ipmd_ini * v_porcen_det) / 100) * v_pcesion) / 100;
													 ELSE
															--KBR 26/05/2014
															IF NVL(pac_parametros.f_parempresa_n(p_pcempres, 'PMD_RAMO'), 0) = 1 THEN
																 v_ipmd := 0;
															ELSE
																 IF NVL(v_ipmd_ini, 0) > 0 AND NVL(v_cfrepmd, 0) > 0 THEN
																		v_ipmd := ((v_ipmd_ini / v_cfrepmd) * v_pcesion) / 100;
																 END IF;
															END IF;
													 END IF;
													 -- dc_p_trazas(7777777, 'en el cierre xl paso 43');
													 IF NVL(v_ipmd, 0) <> 0 AND nerr = 0 THEN
															-- dc_p_trazas(7777777, 'en el cierre xl paso 44');
															w_nnumlin := w_nnumlin + 1;
															v_traza   := 29;
															v_traza   := 30;
													 
															--BUG 0023830/161837 - INICIO - DCT - 23/12/2013 - AÃ±adir compaÃ±Ã­a propia la 1. (ccompapr = 1)
															BEGIN
																 SELECT NVL(cestado, 1)
																	 INTO v_ctatecnica
																	 FROM ctatecnica
																	WHERE cempres = p_pcempres
																		AND scontra = v_scontra
																		AND nversio = v_nversio
																		AND ctramo = v_ctramo
																		AND ccompani = v_ccompani;
															EXCEPTION
																 WHEN no_data_found THEN
																		-- INI - CJAD - 18/SEP2019 - IAXIS5317 - Errores en proceso de pre cierre  
																		BEGIN
																			 --FIN - CJAD - 18/SEP2019 - IAXIS5317 - Errores en proceso de pre cierre 
																			 INSERT INTO ctatecnica
																					(ccompani, nversio, scontra, ctramo, nctatec, cfrecul, cestado,
																					 festado, fcierre, cempres, ccorred)
																			 VALUES
																					(v_ccompani, v_nversio, v_scontra, v_ctramo, 1, 3, 1, NULL, NULL,
																					 p_pcempres, v_ccorred);
																			 -- INI - CJAD - 18/SEP2019 - IAXIS5317 - Errores en proceso de pre cierre  
																		EXCEPTION
																			 WHEN OTHERS THEN
																					p_tab_error(f_sysdate, f_user, vobj, v_traza,
																											' Inserto en ctatecnica -  v_ccompani: ' || v_ccompani ||
																											 ' v_nversio: ' || v_nversio || ' v_scontra: ' || v_scontra ||
																											 ' v_ctramo: ' || v_ctramo || ' p_pcempres: ' || p_pcempres ||
																											 ' v_ccorred: ' || v_ccorred, 'Error insercion',
																											' SQLERRM = ' || SQLERRM);
																		END;
																		-- FIN - CJAD - 18/SEP2019 - IAXIS5317 - Errores en proceso de pre cierre     
															
																 WHEN OTHERS THEN
																		p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete,
																										v_nom_funcion, NULL, 28, ' ENTRO A OTHERS: ' || SQLERRM);
															END;
													 
															BEGIN
																 INSERT INTO movctaaux
																		(ccompani, nversio, scontra, ctramo, nnumlin, fmovimi, fefecto, cconcep,
																		 cdebhab, iimport, cestado, sproces, scesrea, cempres, fcierre, ccompapr,
																		 cramo, ccorred) -- 25/05/2015  CJMR  0033158: Actualización campo CCORRED en los cierres de Reaseguro
																 VALUES
																		(v_ccompani, v_nversio, v_scontra, v_ctramo, w_nnumlin, p_pfperfin,
																		 p_pfperfin, v_cconcep, 2, v_ipmd, v_cestado, p_pproces,
																		 --> cdebhab de tipoctarea! !!
																		 NULL, p_pcempres, p_pfperfin, 1, v_cramo, v_ccorred); -- 25/05/2015  CJMR  0033158: Actualizaci?n campo CCORRED en los cierres de Reaseguro
															
																 --CONFCC-5 Inicio
																 IF NVL(pac_parametros.f_parempresa_n(p_pcempres, 'APLICA_RET_PRIMAS'), 0) = 1 THEN
																		pac_reaseguro_rec.p_calcula_retencion(p_pcempres, NULL, NULL, v_ccompani,
																																					p_pfperfin, v_ipmd, v_iretenido, nerr);
																 
																		BEGIN
																			 INSERT INTO movctaaux
																					(ccompani, nversio, scontra, ctramo, nnumlin, fmovimi, fefecto,
																					 cconcep, cdebhab, iimport, cestado, sproces, scesrea, cempres, fcierre,
																					 ccompapr, cramo, ccorred)
																			 VALUES
																					(v_ccompani, v_nversio, v_scontra, v_ctramo, w_nnumlin, p_pfperfin,
																					 p_pfperfin, 46, 1, v_iretenido, v_cestado, p_pproces, NULL, p_pcempres,
																					 p_pfperfin, 1, v_cramo, v_ccorred);
																		EXCEPTION
																			 WHEN OTHERS THEN
																					p_tab_error(f_sysdate, f_user, 'pac_reaseguro_xl.f_insertar_pmd',
																											v_traza,
																											'Err INSERT movctaaux Ret:' || v_ccompani || ', ' ||
																											 v_nversio || ', ' || v_scontra || ', ' || v_ctramo,
																											' SQLERRM = ' || SQLERRM);
																					nerr   := 105802;
																					p_psql := SQLERRM;
																		END;
																 END IF;
																 --CONFCC-5 Fin
															
															EXCEPTION
																 WHEN dup_val_on_index THEN
																		nerr   := 105800;
																		p_psql := SQLERRM;
																		p_tab_error(f_sysdate, f_user, vobj, v_traza,
																								'INSERT INTO movctaaux cconcep: 22',
																								' pmd.scontra=' || v_scontra || ' pmd.nversio=' || v_nversio ||
																								 ' v_ctramo=' || v_ctramo || ' compa.ccompani:' || v_ccompani ||
																								 ' SQLERRM = ' || SQLERRM);
																 WHEN OTHERS THEN
																		nerr   := 105802;
																		p_psql := SQLERRM;
																		p_tab_error(f_sysdate, f_user, vobj, v_traza,
																								'INSERT INTO movctaaux cconcep: 22',
																								' pmd.scontra=' || v_scontra || ' pmd.nversio=' || v_nversio ||
																								 ' v_ctramo=' || v_ctramo || ' compa.ccompani:' || v_ccompani ||
																								 ' SQLERRM = ' || SQLERRM);
															END;
													 END IF;
												
													 --BUG 0023830/161837 - FIN - DCT - 23/12/2013 - AÃ±adir compaÃ±Ã­a propia la 1. (ccompapr = 1)
													 IF nerr = 0 THEN
															-- dc_p_trazas(7777777, 'en el cierre xl paso 45');
															------------------------------------------------------
															-- AquÃ­ se contabilizan las tax --
															-----------------------------------------------------
															-- buscamos el tramo de impuestos
															BEGIN
																 v_traza := 99;
																 -- dc_p_trazas(7777777, 'en el cierre xl paso 45_1');
																 SELECT cd.pctpart
																	 INTO v_pctpart
																	 FROM companias cc, clausulas_reas_det cd, cod_clausulas_reas cr
																	WHERE cc.ccompani = v_ccompani
																		AND cc.ctramtax = cd.ctramo
																		AND cd.ccodigo = cr.ccodigo
																			 -- AND cr.ctipo = 3   -- Tipo:3 TAXES/TASAS VF:346
																		AND cr.ctipo = 5 --  25860 16/08/2013 avt (cambiamos 3 por 5 para no entrar en conflicto con las tasas XL)
																		AND p_pfperfin > cr.fefecto
																		AND (p_pfperfin <= cr.fvencim OR cr.fvencim IS NULL);
																 -- dc_p_trazas(7777777, 'en el cierre xl paso 45_2');
																 v_tax     := v_ipmd * v_pctpart / 100;
																 w_cconcep := 27;
																 w_cdebhab := 1;
															
																 --KBR 11/12/2013
																 IF v_tax <> 0 THEN
																		-- dc_p_trazas(7777777, 'en el cierre xl paso 46');
																		BEGIN
																			 SELECT NVL(cestado, 1)
																				 INTO v_ctatecnica
																				 FROM ctatecnica
																				WHERE cempres = p_pcempres
																					AND scontra = v_scontra
																					AND nversio = v_nversio
																					AND ctramo = v_ctramo
																					AND ccompani = v_ccompani;
																		EXCEPTION
																			 WHEN no_data_found THEN
																			 
																					INSERT INTO ctatecnica
																						 (ccompani, nversio, scontra, ctramo, nctatec, cfrecul, cestado,
																							festado, fcierre, cempres, ccorred)
																					VALUES
																						 (v_ccompani, v_nversio, v_scontra, v_ctramo, 1, 3, 1, NULL, NULL,
																							p_pcempres, v_ccorred);
																			 
																		END;
																 
																		BEGIN
																			 INSERT INTO movctaaux
																					(ccompani, nversio, scontra, ctramo, nnumlin, fmovimi, fefecto,
																					 cconcep, cdebhab, iimport, cestado, sproces, scesrea, cempres, fcierre,
																					 ccorred) -- 25/05/2015  CJMR  0033158: Actualización campo CCORRED en los cierres de Reaseguro
																			 VALUES
																					(v_ccompani, v_nversio, v_scontra, v_ctramo, w_nnumlin, p_pfperfin,
																					 p_pfperfin, v_cconcep, 2, v_tax, v_cestado, p_pproces,
																					 --> cdebhab de tipoctarea! !!
																					 NULL, p_pcempres, p_pfperfin, v_ccorred); -- 25/05/2015  CJMR  0033158: Actualización campo CCORRED en los cierres de Reaseguro
																		EXCEPTION
																			 WHEN OTHERS THEN
																					p_tab_error(f_sysdate, f_user, vobj, v_traza,
																											'INSERT INTO movctaaux cconcep: 27',
																											' pmd.scontra=' || v_scontra || ' pmd.nversio=' ||
																											 v_nversio || ' v_ctramo=' || v_ctramo ||
																											 ' compa.ccompani:' || v_ccompani || ' SQLERRM = ' ||
																											 SQLERRM);
																					nerr   := 105802;
																					p_psql := SQLERRM;
																		END;
																 END IF;
															EXCEPTION
																 WHEN no_data_found THEN
																		NULL; -- no hay tax en esta cia
																 WHEN OTHERS THEN
																		p_tab_error(f_sysdate, f_user, vobj, v_traza,
																								'INSERT INTO movctaaux cconcep: 27',
																								' pmd.scontra=' || v_scontra || ' pmd.nversio=' || v_nversio ||
																								 ' v_ctramo=' || v_ctramo || ' v_ccompani:' || v_ccompani ||
																								 ' SQLERRM = ' || SQLERRM);
																		nerr   := 105802;
																		p_psql := SQLERRM;
															END;
													 END IF;
												END IF;
										 END IF;
									END IF;
									-- dc_p_trazas(7777777, 'en el cierre xl paso 47');
									--BUG 28492/156489 - Inicio - DCT - 14/02/2014- AÃ±adimos el PTASAXL (Porcentaje de la tasa aplicable para contratos XL
									--bug 25860/149606 ETM 24/07/202013 INI---------------
									IF v_ctramotasaxl IS NOT NULL OR v_ptasaxl IS NOT NULL OR v_costo_fijo IS NOT NULL THEN
										 -- dc_p_trazas(7777777, 'en el cierre xl paso 48');
										 pany      := TO_DATE('0101' || TO_CHAR(p_pfperfin, 'yyyy'), 'ddmmyyyy'); --KBR 13/11/2013
										 w_nnumlin := w_nnumlin + 1;
										 v_traza   := 43;
									
										 -------------------------------------------------------------------------------------------
										 -- SINIESTRALIDAD = Siniestro incurrido / Prima devengada                                --
										 -- Siniestro incurrido = Siniestro pagado - recobros + reserva de siniestros pendientes  --
										 -- PMD  = Prima MÃ­nima de depÃ³sito definida por contrato para esa versiÃ³n                --
										 -------------------------------------------------------------------------------------------
										 BEGIN
												SELECT NVL(SUM(m.iimport), 0) + NVL(SUM(x.iimport), 0)
													INTO v_prima_anual
													FROM movctatecnica m, movctaaux x
												 WHERE m.fmovimi >= pany
													 AND x.fmovimi = p_pfperfin
													 AND m.scontra = x.scontra(+)
													 AND m.nversio = x.nversio(+)
													 AND m.ctramo = x.ctramo(+)
													 AND m.ccompani = x.ccompani(+)
													 AND m.scontra = v_scontra
													 AND m.nversio = v_nversio
													 AND m.ctramo = v_ctramo
													 AND m.ccompani = v_ccompani
													 AND m.cconcep = x.cconcep(+)
													 AND m.cconcep = 22; -- pagos de PMD fraccionados
										 
												IF v_prima_anual = 0 THEN
													 v_prima_anual := 1;
												END IF;
										 EXCEPTION
												WHEN no_data_found THEN
													 -- INI - CJAD - 18/SEP2019 - IAXIS5317 - Errores en proceso de pre cierre  
													 BEGIN
															--FIN - CJAD - 18/SEP2019 - IAXIS5317 - Errores en proceso de pre cierre 
															SELECT NVL(SUM(x.iimport), 1)
																INTO v_prima_anual
																FROM movctaaux x
															 WHERE x.fmovimi = p_pfperfin
																 AND x.scontra = v_scontra
																 AND x.nversio = v_nversio
																 AND x.ctramo = v_ctramo
																 AND x.ccompani = v_ccompani
																 AND x.cconcep = 22; -- pagos de PMD fraccionados
															-- INI - CJAD - 18/SEP2019 - IAXIS5317 - Errores en proceso de pre cierre  
													 EXCEPTION
															WHEN no_data_found THEN
																 v_prima_anual := 0;
													 END;
													 -- FIN - CJAD - 18/SEP2019 - IAXIS5317 - Errores en proceso de pre cierre 
										 END;
									
										 v_traza := 44;
									
										 --BUG 28492/156489 - Inicio - DCT - 14/02/2014 - SÃ³lo se debe realizar la select si tenemos que calcular la tasa variable
										 IF v_ctramotasaxl IS NOT NULL THEN
												-- dc_p_trazas(7777777, 'en el cierre xl paso 48');
												BEGIN
													 SELECT NVL(SUM(m.iimport), 0) + NVL(SUM(x.iimport), 0)
														 INTO v_pagos_sin_anual
														 FROM movctatecnica m, movctaaux x
														WHERE m.fmovimi >= pany
															AND x.fmovimi = p_pfperfin
															AND m.scontra = x.scontra(+)
															AND m.nversio = x.nversio(+)
															AND m.ctramo = x.ctramo(+)
															AND m.ccompani = x.ccompani(+)
															AND m.scontra = v_scontra
															AND m.nversio = v_nversio
															AND m.ctramo = v_ctramo
															AND m.ccompani = v_ccompani
															AND m.cconcep = x.cconcep(+)
															AND m.cconcep = 5;
												EXCEPTION
													 WHEN no_data_found THEN
															-- INI - CJAD - 18/SEP2019 - IAXIS5317 - Errores en proceso de pre cierre  
															BEGIN
																 -- FIN - CJAD - 18/SEP2019 - IAXIS5317 - Errores en proceso de pre cierre 
																 SELECT NVL(SUM(x.iimport), 0)
																	 INTO v_pagos_sin_anual
																	 FROM movctaaux x
																	WHERE x.fmovimi = p_pfperfin
																		AND x.scontra = v_scontra
																		AND x.nversio = v_nversio
																		AND x.ctramo = v_ctramo
																		AND x.ccompani = v_ccompani
																		AND x.cconcep = 5;
																 -- INI - CJAD - 18/SEP2019 - IAXIS5317 - Errores en proceso de pre cierre  
															EXCEPTION
																 WHEN no_data_found THEN
																		v_pagos_sin_anual := 0;
															END;
															-- FIN - CJAD - 18/SEP2019 - IAXIS5317 - Errores en proceso de pre cierre 
												END;
										 
												v_traza := 45;
												-- INI - CJAD - 18/SEP2019 - IAXIS5317 - Errores en proceso de pre cierre  
												BEGIN
													 -- FIN - CJAD - 18/SEP2019 - IAXIS5317 - Errores en proceso de pre cierre 
													 SELECT NVL(SUM(x.iimport), 0)
														 INTO v_reserva_anual
														 FROM movctaaux x
														WHERE x.fmovimi = p_pfperfin
															AND x.scontra = v_scontra
															AND x.nversio = v_nversio
															AND x.ctramo = v_ctramo
															AND x.ccompani = v_ccompani
															AND x.cconcep = 25;
													 -- INI - CJAD - 18/SEP2019 - IAXIS5317 - Errores en proceso de pre cierre  
												EXCEPTION
													 WHEN no_data_found THEN
															v_reserva_anual := 0;
												END;
												-- FIN - CJAD - 18/SEP2019 - IAXIS5317 - Errores en proceso de pre cierre 
										 END IF;
									
										 --BUG 28492/156489 - FIN - DCT - 14/02/2014 - SÃ³lo se debe realizar la select si tenemos que calcular la tasa variable
										 BEGIN
												SELECT NVL(SUM(m.iimport), 0) + NVL(SUM(x.iimport), 0)
													INTO v_pmd
													FROM movctatecnica m, movctaaux x
												 WHERE m.fmovimi >= pany
													 AND x.fmovimi = p_pfperfin
													 AND m.scontra = x.scontra(+)
													 AND m.nversio = x.nversio(+)
													 AND m.ctramo = x.ctramo(+)
													 AND m.ccompani = x.ccompani(+)
													 AND m.scontra = v_scontra
													 AND m.nversio = v_nversio
													 AND m.ctramo = v_ctramo
													 AND m.ccompani = v_ccompani
													 AND m.cconcep = x.cconcep(+)
													 AND m.cconcep = 22;
										 EXCEPTION
												WHEN no_data_found THEN
													 -- INI - CJAD - 18/SEP2019 - IAXIS5317 - Errores en proceso de pre cierre  
													 BEGIN
															--FIN - CJAD - 18/SEP2019 - IAXIS5317 - Errores en proceso de pre cierre 
															SELECT NVL(SUM(x.iimport), 0)
																INTO v_pmd
																FROM movctaaux x
															 WHERE x.fmovimi = p_pfperfin
																 AND x.scontra = v_scontra
																 AND x.nversio = v_nversio
																 AND x.ctramo = v_ctramo
																 AND x.ccompani = v_ccompani
																 AND x.cconcep = 22;
															-- INI - CJAD - 18/SEP2019 - IAXIS5317 - Errores en proceso de pre cierre  
													 EXCEPTION
															WHEN no_data_found THEN
																 v_pmd := 0;
													 END;
													 -- FIN - CJAD - 18/SEP2019 - IAXIS5317 - Errores en proceso de pre cierre 
										 END;
									
										 v_traza := 46;
									
										 --BUG 28492/156489 - Inicio - DCT - 17/12/2013 -  Si tenemos informado pmd.ctramotasaxl calculamos la tasa variable
										 --si tenemos informado  pmd.ptasaxl lo hacemos por tasa fija
										 IF v_ctramotasaxl IS NOT NULL THEN
												v_siniestralitat := (v_pagos_sin_anual + v_reserva_anual) / v_prima_anual;
												v_traza          := 47;
												nerr             := pac_reaseguro_xl.f_tasa_variable(p_pcempres, v_ctramotasaxl,
																																						 v_siniestralitat, w_ptasaxl);
												v_traza          := 48;
										 ELSE
												IF NVL(pac_parametros.f_parempresa_n(p_pcempres, 'TASAFIJA'), 0) = 1 THEN
													 w_ptasaxl := v_ptasaxl;
												END IF;
										 END IF;
									
										 --BUG 28492/168655 - INICIO - DCT - 05/03/2014 -AÃ±adir AND NVL(w_ptasaxl, 0) <> 0
										 --BUG 28492/156489 - Fin - DCT - 17/12/2013 -  Si tenemos informado pmd.ctramotasaxl calculamos la tasa variable
										 IF nerr = 0 AND NVL(w_ptasaxl, 0) <> 0 THEN
												-- dc_p_trazas(7777777, 'en el cierre xl paso 49');
												nerr := pac_reaseguro_xl.f_prima_anual_reten(p_pcempres, v_scontra, v_nversio, p_pfperfin,
																																		 v_ccompani, v_ctramo, v_cramo, w_panuret);
										 
												--AGG 06/06/2014 Solo POSITIVA
												IF NVL(pac_parametros.f_parempresa_n(p_pcempres, 'PMD_RAMO'), 0) = 1 THEN
													 IF v_cramo = 331 THEN
															v_primaneta_ap := w_panuret;
													 ELSIF v_cramo = 334 THEN
															v_primaneta_vg := w_panuret;
													 ELSIF v_cramo = 337 THEN
															v_primaneta_vi := w_panuret;
													 END IF;
												END IF;
										 
												v_traza := 48;
										 
												IF nerr = 0 THEN
													 -- dc_p_trazas(7777777, 'en el cierre xl paso 50');
													 v_tasa_var := (w_panuret * w_ptasaxl) / 100;
												
													 IF v_tasa_var > v_pmd THEN
															-- dc_p_trazas(7777777, 'en el cierre xl paso 51');
															-- insertem la diferencia a movctaaux com a concepte ???
															v_tasa_var_total := v_tasa_var - v_pmd;
															pmes             := TO_NUMBER(TO_CHAR(p_pfperfin, 'mm'));
													 
															IF v_ctramotasaxl IS NOT NULL THEN
																 -- AVT AJUSTE CONCEPTO PARA TASA VARIABLE
																 IF pmes = 12 THEN
																		w_cconcep := 28; --Regul. tasa Variables
																 ELSE
																		w_cconcep := 29; --Regul. tasa  Variables Provisionals
																 END IF;
															ELSE
																 -- -- AVT AJUSTE CONCEPTO PARA TASA FIJA
																 IF pmes = 12 THEN
																		w_cconcep := 32; --Regul. tasa Fija
																 ELSE
																		w_cconcep := 31; --Regul. tasa Fija Provisionals
																 END IF;
															END IF; -- -- AVT AJUSTE CONCEPTO PARA TASA FIJA  FIN
													 
															v_traza := 49;
															-- dc_p_trazas(7777777, 'en el cierre xl paso 52');
															BEGIN
																 UPDATE movctaaux
																		SET iimport = v_tasa_var_total
																	WHERE scontra = v_scontra
																		AND nversio = v_nversio
																		AND ctramo = v_ctramo
																		AND ccompani = v_ccompani
																			 --AND NVL(ccompapr, 0) = NVL(reg.ccompapr, 0)
																		AND cconcep = w_cconcep;
															
																 IF SQL%ROWCOUNT = 0 THEN
																		v_traza := 50;
																 
																		--KBR 11/12/2013
																		IF v_tasa_var_total <> 0 THEN
																			 -- dc_p_trazas(7777777, 'en el cierre xl paso 53');
																			 BEGIN
																					SELECT NVL(cestado, 1)
																						INTO v_ctatecnica
																						FROM ctatecnica
																					 WHERE cempres = p_pcempres
																						 AND scontra = v_scontra
																						 AND nversio = v_nversio
																						 AND ctramo = v_ctramo
																						 AND ccompani = v_ccompani;
																			 EXCEPTION
																					WHEN no_data_found THEN
																						 -- INI - CJAD - 18/SEP2019 - IAXIS5317 - Errores en proceso de pre cierre  
																						 BEGIN
																								-- FIN - CJAD - 18/SEP2019 - IAXIS5317 - Errores en proceso de pre cierre 
																								INSERT INTO ctatecnica
																									 (ccompani, nversio, scontra, ctramo, nctatec, cfrecul,
																										cestado, festado, fcierre, cempres, ccorred)
																								VALUES
																									 (v_ccompani, v_nversio, v_scontra, v_ctramo, 1, 3, 1, NULL,
																										NULL, p_pcempres, v_ccorred);
																						 
																								-- INI - CJAD - 18/SEP2019 - IAXIS5317 - Errores en proceso de pre cierre  
																						 EXCEPTION
																								WHEN OTHERS THEN
																									 p_tab_error(f_sysdate, f_user, vobj, v_traza,
																															 ' Inserto en ctatecnica - v_ccompani: ' ||
																																v_ccompani || ' v_nversio: ' || v_nversio ||
																																' v_scontra: ' || v_scontra || ' v_ctramo: ' ||
																																v_ctramo || ' p_pcempres: ' || p_pcempres ||
																																' v_ccorred: ' || v_ccorred, 'Error insercion',
																															 ' SQLERRM = ' || SQLERRM);
																						 END;
																						 -- FIN - CJAD - 18/SEP2019 - IAXIS5317 - Errores en proceso de pre cierre 
																			 END;
																			 BEGIN
																					INSERT INTO movctaaux
																						 (ccompani, nversio, scontra, ctramo, nnumlin, fmovimi, fefecto,
																							cconcep, cdebhab, iimport, cestado, sproces, scesrea, cempres,
																							fcierre, ccorred) -- 25/05/2015  CJMR  0033158: Actualización campo CCORRED en los cierres de Reaseguro
																					VALUES
																						 (v_ccompani, v_nversio, v_scontra, v_ctramo, w_nnumlin, p_pfperfin,
																							p_pfperfin, w_cconcep, 1, v_tasa_var_total, v_cestado, p_pproces,
																							NULL, p_pcempres, p_pfperfin, v_ccorred); -- 25/05/2015  CJMR  0033158: Actualización campo CCORRED en los cierres de Reaseguro
																			 EXCEPTION
																					WHEN OTHERS THEN
																						 p_tab_error(f_sysdate, f_user, 'pac_reaseguro_xl.f_insertar_pmd',
																												 v_traza,
																												 'Err INSERT movctaaux:' || v_ccompani || ', ' ||
																													v_nversio || ', ' || v_scontra || ', ' || v_ctramo || ', ' ||
																													w_cconcep, ' SQLERRM = ' || SQLERRM);
																						 nerr   := 105802;
																						 p_psql := SQLERRM;
																			 END;
																		END IF;
																 END IF;
															EXCEPTION
																 WHEN OTHERS THEN
																		p_tab_error(f_sysdate, f_user, 'pac_reaseguro_xl.f_insertar_pmd', v_traza,
																								'Err UPDATE movctaaux:' || v_ccompani || ', ' || v_nversio || ', ' ||
																								 v_scontra || ', ' || v_ctramo || ', ' || w_cconcep,
																								' SQLERRM = ' || SQLERRM);
																		nerr   := 105801;
																		p_psql := SQLERRM;
															END;
													 END IF;
												END IF;
										 END IF;
									END IF;
									--FIN bug 25860/149606 ETM 24/07/202013 ---------------
							 END LOOP;
						
							 IF NVL(pac_parametros.f_parempresa_n(p_pcempres, 'PMD_RAMO'), 0) = 1 THEN
									CLOSE c_cuadroces_agr_ramo;
							 ELSE
									CLOSE c_cuadroces_agr;
							 END IF;
						END IF;
				 
						--AGG 06/06/2014 Insertamos concepto de bono por no reclamaci??
						IF NVL(pac_parametros.f_parempresa_n(p_pcempres, 'PMD_RAMO'), 0) = 1 THEN
							 p_traza_proceso(p_pcempres, vpar_traza, p_pproces, v_nom_paquete, v_nom_funcion, NULL, 4,
															 'Insertar bono no reclamacion');
							 nerr := f_insertar_bononr(v_siniestralitat, v_scontra, v_nversio, v_ctramo, p_pfperfin, v_ccompani,
																				 p_pcempres, p_pproces, v_primaneta_vg, v_primaneta_vi, v_primaneta_ap);
						END IF;
				 END LOOP;
			
				 IF NVL(pac_parametros.f_parempresa_n(p_pcempres, 'PMD_RAMO'), 0) = 1 THEN
						CLOSE prima_min_deposit_ramo;
				 ELSE
						CLOSE prima_min_deposit;
				 END IF;
			END IF;
			-- dc_p_trazas(7777777, 'en el cierre xl paso 53, nerr:'||nerr);
			p_control_error('EDBR#21', 'f_insertar_pmd', 'FIN FUNCION');
			RETURN nerr;
	 END f_insertar_pmd;

	 --------------------------
	 FUNCTION llenar_tablas_defi(psql OUT VARCHAR2, pscesrea OUT NUMBER, pcempres IN NUMBER, pfperfin IN DATE)
			RETURN NUMBER IS
			num_err      NUMBER := 0;
			w_sql        VARCHAR2(500);
			w_nnumlin    NUMBER;
			v_cmultimon  parempresas.nvalpar%TYPE := NVL(pac_parametros.f_parempresa_n(pcempres, 'MULTIMONEDA'), 0);
			v_cmoncontab parempresas.nvalpar%TYPE := pac_parametros.f_parempresa_n(pcempres, 'MONEDACONTAB');
			v_itasa      eco_tipocambio.itasa%TYPE;
			v_fcambio    DATE;
	 
			--BUG 23830 - INICIO - DCT - 10/09/2013 - LCOL_A004 Ajustar el Manteniment dels comptes de Reassegurança
			CURSOR cur_movaux IS
				 SELECT ROWID, m.*
					 FROM movctaaux m
					WHERE m.cempres = pcempres
						AND m.fcierre = pfperfin
						AND NVL(m.iimport, 0) <> 0
						AND m.scontra IN (SELECT scontra FROM codicontratos WHERE ctiprea = 3);
			--BUG 23830 - FIN - DCT - 10/09/2013 - LCOL_A004 Ajustar el Manteniment dels comptes de Reassegurança
			--AVT Sólo para el XL!
	 BEGIN
			--(5.a.) Se recogen los registros actualizados en MOVCTAAUX
			--(5.a.i.) Para cada registro se calcula el número máximo de línea (NNUMLIN) que le corresponde en la MOVCTATECNIA (por SCONTRA, NVERSIO, CRAMO, CCOMPANI)
			--(5.a.ii.) Si ya existe:
			--(5.a.ii.1.)  NNUMLIN = MAX(NNUMLIN) + 1
			FOR regmov IN cur_movaux LOOP
				 --DBMS_OUTPUT.put_line('(5.a.ii.1.) LOOP regmov:' || regmov.ccompani || '-'|| regmov.nversio || '-' || regmov.scontra || '-'|| regmov.cconcep);
				 BEGIN
						SELECT NVL(MAX(nnumlin), 0)
							INTO w_nnumlin
							FROM movctatecnica
						 WHERE scontra = regmov.scontra
							 AND nversio = regmov.nversio
							 AND ctramo = regmov.ctramo
							 AND ccompani = regmov.ccompani;
				 
						w_nnumlin := w_nnumlin + 1;
				 EXCEPTION
						WHEN no_data_found THEN
							 --(5.a.iii.) No existe:
							 --(5.a.iii.1.) NNUMLIN = 1
							 w_nnumlin := 1;
							 p_tab_error(f_sysdate, f_user, 'pac_reaseguro_xl.llenar_tablas_defi', 1,
													 'Err select movctatecnica',
													 ' regmov.scontra =' || regmov.scontra || ' regmov.nversio =' || regmov.nversio ||
														' regmov.ctramo =' || regmov.ctramo || ' regmov.ccompani =' || regmov.ccompani ||
														' SQLERRM:' || SQLERRM);
						WHEN OTHERS THEN
							 num_err := 104863;
							 w_sql   := SQLERRM;
							 p_tab_error(f_sysdate, f_user, 'pac_reaseguro_xl.llenar_tablas_defi', 2,
													 'Err select movctatecnica',
													 ' regmov.scontra =' || regmov.scontra || ' regmov.nversio =' || regmov.nversio ||
														' regmov.ctramo =' || regmov.ctramo || ' regmov.ccompani =' || regmov.ccompani ||
														' SQLERRM:' || SQLERRM);
				 END;
			
				 --DBMS_OUTPUT.put_line('(5.a.iv.) num_err:' || num_err);
			
				 --(5.a.iv.) Se inserta en la tabla definitiva: MOVCTATECNICA .
				 IF num_err = 0 THEN
						-- BUG 18423 - 02/11/2011 - JMP - LCOL000 - Multimoneda
						IF v_cmultimon = 1 THEN
							 num_err := pac_oper_monedas.f_datos_contraval(NULL, NULL, regmov.scontra, regmov.fmovimi, 3,
																														 v_itasa, v_fcambio);
						
							 IF num_err <> 0 THEN
									psql     := SQLERRM;
									pscesrea := TO_NUMBER(TO_CHAR(regmov.scontra) || TO_CHAR(regmov.nversio) ||
																				TO_CHAR(regmov.ctramo) || TO_CHAR(regmov.ccompani));
							 END IF;
						END IF;
				 
						-- FIN BUG 18423 - 02/11/2011 - JMP - LCOL000 - Multimoneda
						BEGIN
							 INSERT INTO movctatecnica
									(ccompani, nversio, scontra, ctramo, nnumlin, fmovimi, fefecto, cconcep, cdebhab, iimport,
									 cestado, sproces, scesrea, iimport_moncon, fcambio, sproduc, cempres, nsinies, cevento,
									 --Kb XL por Eventos
									 ccompapr,
									 --23830/161685 - DCT - 19/12/2013. Grabar ccompapr
									 ccorred, nid
									 -- ML - APUNTES MANUALES 4818
									 ) -- 25/05/2015  CJMR  0033158: Actualización campo CCORRED en los cierres de Reaseguro
							 VALUES
									(regmov.ccompani, regmov.nversio, regmov.scontra, regmov.ctramo, w_nnumlin, pfperfin,
									 regmov.fefecto, regmov.cconcep, regmov.cdebhab, NVL(regmov.iimport, 0), NVL(regmov.cestado, 1),
									 regmov.sproces, NULL, f_round(NVL(regmov.iimport, 0) * v_itasa, v_cmoncontab),
									 DECODE(v_cmultimon, 0, NULL, NVL(v_fcambio, regmov.fmovimi)), regmov.sproduc, regmov.cempres,
									 regmov.nsinies, regmov.cevento,
									 --Kb XL por Eventos
									 regmov.ccompapr,
									 --23830/161685 - DCT - 19/12/2013 - Grabar ccompapr
									 regmov.ccorred, regmov.nid
									 -- ML - APUNTES MANULES 4818
									 ); -- 25/05/2015  CJMR  0033158: Actualización campo CCORRED en los cierres de Reaseguro
							 -- ML - 4818 - APUNTES MANUALES
							 -- INSERT EN CTATECNICA
							 IF regmov.nid IS NOT NULL THEN
									BEGIN
										 num_err := pac_rea.f_set_ctatecnica(regmov.ccompani, regmov.scontra, regmov.nversio,
																												 regmov.ctramo, 1, 3, 1, NULL, NULL, regmov.cempres,
																												 regmov.sproduc, regmov.ccorred);
									EXCEPTION
										 WHEN OTHERS THEN
												NULL;
									END;
							 END IF;
						
							 DELETE FROM movctaaux WHERE ROWID = regmov.rowid;
							 --<DBMS_OUTPUT.put_line('(5.a.iv.) INSERT movctatecnica :' || SQLERRM
							 --<                     || ' --------------------------- ' || SQL%ROWCOUNT
							 --<                     || ' registro ');
						EXCEPTION
							 WHEN dup_val_on_index THEN
									num_err := 104862;
									w_sql   := SQLERRM;
									p_tab_error(f_sysdate, f_user, 'pac_reaseguro_xl.llenar_tablas_defi', 3,
															'Err INSERT INTO movctatecnica',
															' regmov.scontra =' || regmov.scontra || ' regmov.nversio =' || regmov.nversio ||
															 ' regmov.ctramo =' || regmov.ctramo || ' regmov.ccompani =' || regmov.ccompani ||
															 ' SQLERRM:' || SQLERRM);
							 WHEN OTHERS THEN
									num_err := 104861;
									w_sql   := SQLERRM;
									p_tab_error(f_sysdate, f_user, 'pac_reaseguro_xl.llenar_tablas_defi', 4,
															'Err INSERT INTO movctatecnica',
															' regmov.scontra =' || regmov.scontra || ' regmov.nversio =' || regmov.nversio ||
															 ' regmov.ctramo =' || regmov.ctramo || ' regmov.ccompani =' || regmov.ccompani ||
															 ' SQLERRM:' || SQLERRM);
						END;
				 END IF;
			END LOOP;
	 
			--(5.b.) Se recogen los registros del detalle en LIQUIDAREAXL_AUX
			--(5.b.i.) Se insertan directamente sobre LIQUIDAREAXL
			BEGIN
				 INSERT INTO liquidareaxl (SELECT * FROM liquidareaxl_aux WHERE TRUNC(fcierre) = TRUNC(pfperfin));
				 --<DBMS_OUTPUT.put_line('(5.b.i.) INSERT INTO liquidareaxl - num_err:' || num_err
				 --<                     || ' --------------------------- ' || SQL%ROWCOUNT
				 --<                     || ' registro ');
			EXCEPTION
				 WHEN OTHERS THEN
						-->> AVT control d'errors
						num_err := 1;
						p_tab_error(f_sysdate, f_user, 'pac_reaseguro_xl.llenar_tablas_defi', 5,
												'Err INSERT INTO liquidareaxl', ' pfperfin =' || pfperfin || ' SQLERRM:' || SQLERRM);
			END;
	 
			-- AVT 23-12-2008 se añade la gestión de PAGOSREAXL
			--(5.b.) Se recogen los registros del detalle en LIQUIDAREAXL_AUX
			--(5.b.i.) Se insertan directamente sobre LIQUIDAREAXL
			BEGIN
				 INSERT INTO pagosreaxl (SELECT * FROM pagosreaxl_aux WHERE TRUNC(fcierre) = TRUNC(pfperfin));
				 --<DBMS_OUTPUT.put_line('(5.b.i.) INSERT INTO pagosreaxl - num_err:' || num_err
				 --<                     || ' --------------------------- ' || SQL%ROWCOUNT
				 --<                     || ' registro ');
			EXCEPTION
				 WHEN OTHERS THEN
						-->> AVT control d'errors
						num_err := 1;
						p_tab_error(f_sysdate, f_user, 'pac_reaseguro_xl.llenar_tablas_defi', 6,
												'Err INSERT INTO pagosreaxl', ' pfperfin =' || pfperfin || ' SQLERRM:' || SQLERRM);
			END;
	 
			DELETE FROM pagosreaxl_aux WHERE TRUNC(fcierre) = TRUNC(pfperfin);
	 
			DELETE FROM liquidareaxl_aux WHERE TRUNC(fcierre) = TRUNC(pfperfin);
	 
			--DBMS_OUTPUT.put_line('(5.b.i.) INSERT INTO liquidareaxl');
			--DBMS_OUTPUT.put_line('(5.b.i.) DELETE FROM liquidareaxl_aux err:' || SQLERRM);
			RETURN(num_err);
	 END llenar_tablas_defi;

	 --bug 25860/149606 ETM 24/07/202013 INI---------------
	 /***********************************************************************************************
       Nova funció:
       Funcio que retorna el % de tasa variable
       Parametres: pcempres, ctramotasa_, v_siniestralitat
       Sortida:w_ptasa
   
   ******************************************************************************************** */
	 FUNCTION f_tasa_variable(pcempres IN NUMBER, pctasa IN NUMBER, psinies IN NUMBER, ptasa OUT VARCHAR2)
			RETURN NUMBER IS
			pexperr    NUMBER;
			v_traza    NUMBER;
			v_sin_min  clausulas_reas_det.ilim_inf%TYPE;
			v_sin_max  clausulas_reas_det.ilim_sup%TYPE;
			v_tasa_min clausulas_reas_det.pctmin%TYPE;
			v_tasa_max clausulas_reas_det.pctmax%TYPE;
	 BEGIN
			v_traza := 1110;
	 
			IF NVL(pac_parametros.f_parempresa_n(pcempres, 'TASA_VARIABLE'), 0) = 1 THEN
				 SELECT MAX(ilim_inf), MAX(ilim_sup), MAX(pctmin), MAX(pctmax)
					 INTO v_sin_min, v_sin_max, v_tasa_min, v_tasa_max
					 FROM clausulas_reas_det
					WHERE ccodigo = pctasa;
			
				 --PCTMIN + (ILIM_SUP-SINIESTRALIDAD REAL)* (PCTMAX-PCTMIN) / (ILIM_SUP- ILIM_INF)
				 --clausulas_reas_det
				 ptasa := v_tasa_min + (v_sin_max - psinies) * (v_tasa_max - v_tasa_min) / (v_sin_max - v_sin_min);
			ELSE
				 SELECT pctmin
					 INTO ptasa
					 FROM clausulas_reas_det
					WHERE ccodigo = pctasa
						AND ilim_inf <= psinies
						AND ilim_sup >= psinies;
			END IF;
	 
			RETURN(0);
	 EXCEPTION
			WHEN no_data_found THEN
				 p_tab_error(f_sysdate, f_user, 'pac_reaseguro_xl.f_tasa_variable', v_traza,
										 'Err:' || pctasa || ', ' || psinies, ' SQLERRM = ' || SQLERRM);
				 pexperr := pexperr || ', ' || pctasa || ', ' || psinies || ', ' || ptasa || ', ' || SQLERRM || ', ' ||
										TO_CHAR(SQLCODE);
				 RETURN(104332); -- Contrato no encontrado en la tabla CONTRATOS
			WHEN OTHERS THEN
				 p_tab_error(f_sysdate, f_user, 'pac_reaseguro_xl.f_tasa_variable', v_traza,
										 'Err SELECT FROM contratos:' || pctasa || ', ' || psinies, ' SQLERRM = ' || SQLERRM);
				 pexperr := pexperr || ' ' || pctasa || ', ' || psinies || ', ' || ptasa || ', ' || SQLERRM || ', ' ||
										TO_CHAR(SQLCODE);
				 RETURN(104704); -- Error al leer de CONTRATOS
	 END f_tasa_variable;

	 FUNCTION f_prima_anual_reten(pcempres IN NUMBER, pscontra IN NUMBER, pnversio IN NUMBER, pfperfin IN DATE,
																pccompani IN NUMBER, pctramo IN NUMBER DEFAULT NULL,
																pcramo IN NUMBER DEFAULT NULL, panuret OUT VARCHAR2) RETURN NUMBER IS
			pexperr            NUMBER;
			v_traza            NUMBER;
			v_import_devengada NUMBER;
			v_import           NUMBER;
			v_prima_anual      NUMBER;
	 BEGIN
			v_traza := 55;
	 
			BEGIN
				 SELECT NVL(SUM(DECODE(r.ctiprec, 9, -d.iconcep, d.iconcep)), 0)
					 INTO v_import_devengada
					 FROM recibos r, detrecibos d, seguros s, agr_contratos a, garanpro g, productos p, contratos c
					WHERE a.scontra = pscontra
						AND ((a.nversio = pnversio AND a.nversio IS NOT NULL) OR (a.nversio IS NULL))
						AND NVL(a.cmodali, s.cmodali) = s.cmodali
						AND NVL(a.ctipseg, s.ctipseg) = s.ctipseg
						AND NVL(a.ccolect, s.ccolect) = s.ccolect
						AND s.cramo = a.cramo
						AND p.sproduc = s.sproduc
						AND NVL(p.creaseg, 0) IN (1, 2)
						AND g.sproduc = p.sproduc
						AND g.cactivi = s.cactivi
						AND NVL(g.creaseg, 0) IN (1, 2)
						AND r.sseguro = s.sseguro
						AND EXISTS (SELECT 1 FROM cesionesrea cr WHERE cr.sseguro = s.sseguro)
						AND r.fefecto BETWEEN pfperfin AND c.fconini --JRH demomento fefecto
						AND r.ctiprec NOT IN (13, 15) --retornos
						AND r.nrecibo = d.nrecibo
						AND d.cgarant = g.cgarant
						AND d.cconcep = 21
						AND c.nversio = pnversio
						AND c.scontra = pscontra
						AND s.cramo = NVL(pcramo, s.cramo);
			EXCEPTION
				 WHEN OTHERS THEN
						v_import_devengada := 0;
			END;
	 
			v_traza := 56;
	 
			BEGIN
				 SELECT NVL(SUM(DECODE(r.ctiprec, 9, -d.iconcep, d.iconcep)), 0)
					 INTO v_import
					 FROM recibos r, detrecibos d, seguros s, agr_contratos a, garanpro g, productos p, contratos c
					WHERE a.scontra = pscontra
						AND ((a.nversio = pnversio AND a.nversio IS NOT NULL) OR (a.nversio IS NULL))
						AND NVL(a.cmodali, s.cmodali) = s.cmodali
						AND NVL(a.ctipseg, s.ctipseg) = s.ctipseg
						AND NVL(a.ccolect, s.ccolect) = s.ccolect
						AND s.cramo = a.cramo
						AND p.sproduc = s.sproduc
						AND NVL(p.creaseg, 0) <> 0
						AND g.sproduc = p.sproduc
						AND g.cactivi = s.cactivi
						AND NVL(g.creaseg, 0) <> 0
						AND r.sseguro = s.sseguro
						AND EXISTS (SELECT 1 FROM cesionesrea cr WHERE cr.sseguro = s.sseguro)
						AND r.fefecto BETWEEN c.fconini AND pfperfin
						AND r.ctiprec NOT IN (13, 15) --retornos
						AND r.nrecibo = d.nrecibo
						AND d.cgarant = g.cgarant
						AND d.cconcep = 0
						AND c.nversio = pnversio
						AND c.scontra = pscontra
						AND f_cestrec_mv(r.nrecibo, 2, pfperfin) = 2
						AND s.cramo = NVL(pcramo, s.cramo);
			EXCEPTION
				 WHEN OTHERS THEN
						v_import := 0;
			END;
	 
			v_traza := 57;
	 
			BEGIN
				 SELECT NVL(SUM(m.iimport), 0)
					 INTO v_prima_anual
					 FROM movctatecnica m, contratos c
					WHERE m.fmovimi >= TO_DATE('0101' || TO_CHAR(pfperfin, 'yyyy'), 'ddmmyyyy') --KBR 13/11/2013
						AND m.scontra = c.scontra
						AND m.nversio = c.nversio
						AND c.scontra = pscontra
						AND c.nversio = pnversio
						AND m.ccompani = pccompani
						AND m.cconcep = 1
						AND m.cramo = NVL(pcramo, m.cramo)
						AND m.ctramo = NVL(pctramo, m.ctramo);
			EXCEPTION
				 WHEN OTHERS THEN
						v_prima_anual := 0;
			END;
	 
			v_traza := 58;
			panuret := v_import_devengada + v_import - v_prima_anual;
			RETURN(0);
	 EXCEPTION
			WHEN no_data_found THEN
				 p_tab_error(f_sysdate, f_user, 'pac_reaseguro_xl.f_prima_anual_reten', v_traza,
										 'Err:' || pscontra || ', ' || pnversio || ', ' || pfperfin, ' SQLERRM = ' || SQLERRM);
				 pexperr := pexperr || ', ' || pscontra || ', ' || pnversio || ', ' || pfperfin || ', ' || SQLERRM || ', ' ||
										TO_CHAR(SQLCODE);
				 RETURN(104332); -- Contrato no encontrado en la tabla CONTRATOS
			WHEN OTHERS THEN
				 p_tab_error(f_sysdate, f_user, 'pac_reaseguro_xl.f_prima_anual_reten', v_traza,
										 'Err SELECT FROM contratos:' || pscontra || ', ' || pnversio || ', ' || pfperfin,
										 ' SQLERRM = ' || SQLERRM);
				 pexperr := pexperr || ' ' || pscontra || ', ' || pnversio || ', ' || pfperfin || ', ' || SQLERRM || ', ' ||
										TO_CHAR(SQLCODE);
				 RETURN(104704); -- Error al leer de CONTRATOS
	 END f_prima_anual_reten;

	 FUNCTION f_obtener_numlin(p_scontra IN NUMBER, p_nversio IN NUMBER, p_ctramo IN NUMBER, p_ccompani IN NUMBER,
														 p_error OUT NUMBER) RETURN NUMBER IS
			v_error NUMBER := 0;
			v_aux   NUMBER := 0;
			v_traza NUMBER := 99;
	 BEGIN
			BEGIN
				 SELECT NVL(MAX(nnumlin), 0)
					 INTO v_aux
					 FROM movctatecnica
					WHERE scontra = p_scontra
						AND nversio = p_nversio
						AND ctramo = p_ctramo
						AND ccompani = p_ccompani;
			
				 v_aux := v_aux + 1;
			EXCEPTION
				 WHEN no_data_found THEN
						v_aux := 1;
				 WHEN OTHERS THEN
						p_tab_error(f_sysdate, f_user, 'pac_reaseguro_xl.f_insert_saldo', v_traza,
												'Err SELECT FROM movctatecnica:' || p_scontra || ', ' || p_nversio || ', ' || p_ctramo || ', ' ||
												 p_ccompani, ' SQLERRM = ' || SQLERRM);
						v_error := 104863;
			END;
	 
			p_error := v_error;
			RETURN v_aux;
	 END f_obtener_numlin;

	 FUNCTION f_insert_saldo(pcempres IN NUMBER, pmes IN NUMBER, pany IN NUMBER, psproces IN NUMBER,
													 pstiporea IN NUMBER DEFAULT 2) --/*1 Proporcional / 2 No proporcional (XL)
		RETURN NUMBER IS
			v_traza            NUMBER;
			v_nnumlin          NUMBER;
			v_error            NUMBER := 0;
			v_fcierre          DATE;
			v_fcierreant       DATE; --08/07/2014 SHA: Se unifica la función de saldos en PAC_REASEGURO_XL para proporcional i no propocional (28475)
			t_existe_saldo     NUMBER;
			t_pmd              NUMBER;
			t_existe_saldo_pmd NUMBER;
	 
			--08/07/2014 SHA: Se unifica la función de saldos en PAC_REASEGURO_XL para proporcional i no propocional (28475)
			CURSOR cttos(pstiporea NUMBER) IS
				 SELECT DISTINCT cc.scontra, mt.nversio, mt.ctramo, mt.ccompani, NVL(mt.sproduc, 0) sproduc,
												 NVL(mt.ccompapr, 0) ccompapr
					 FROM codicontratos cc, movctaaux mt -- BUG 28475 - 11/11/2014 - SHA: substituimos MOVCTATECNICA por MOVCTAAUX al tratarse de saldos/movimientos actuales
					WHERE mt.ccompani = 551
						AND (pstiporea = 2 AND cc.ctiprea = 3 AND mt.scontra = cc.scontra AND mt.cempres = pcempres)
						 OR (pstiporea = 1 AND cc.ctiprea IN (1, 2) AND mt.scontra = cc.scontra AND mt.cempres = pcempres)
				 /*UNION
         SELECT DISTINCT cc.scontra, mt.nversio, mt.ctramo, mt.ccompani,
                         NVL(mt.sproduc, 0) sproduc, NVL(mt.ccompapr, 0) ccompapr
                    FROM codicontratos cc,
                         movctatecnica mt   -- BUG 28475 - 11/11/2014 - SHA: substituimos MOVCTATECNICA por MOVCTAAUX al tratarse de saldos/movimientos actuales
                   WHERE mt.ccompani = 551
                     and (pstiporea = 2
                          AND cc.ctiprea = 3
                          AND mt.scontra = cc.scontra
                          AND mt.cempres = pcempres)
                      OR(pstiporea = 1
                         AND cc.ctiprea IN(1, 2)
                         AND mt.scontra = cc.scontra
                         AND mt.cempres = pcempres)
                ORDER BY 1, 2, 3*/
				 ;
	 
			-- BUG 28475 - 11/11/2014 - SHA: Adaptamos select del cursor a la tabla MOVCTAAUX
			-- Fin 08/07/2014 SHA
			CURSOR moviments(c_empresa IN NUMBER, c_scontra IN NUMBER, c_nversio IN NUMBER, c_ctramo IN NUMBER,
											 c_ccompani IN NUMBER, c_sproduc IN NUMBER, c_ccompapr IN NUMBER, c_mes IN NUMBER,
											 c_any IN NUMBER) IS
				 SELECT m.cempres, LAST_DAY(TO_DATE('01/' || c_mes || '/' || c_any, 'dd/mm/yyyy')) fmovimi,
								psproces sproces, m.scontra, m.nversio, m.ctramo, m.ccompani, NVL(m.sproduc, 0) sproduc,
								NVL(m.ccompapr, 0) ccompapr,
								
								--08/07/2014 SHA: Se unifica la función de saldos en PAC_REASEGURO_XL para proporcional i no propocional (28475)
								--SALDO = Movimientos del Periodo + Saldo Anterior - Nuestro Pago (Liquidación a favor del reasegurador) + Pagos recibidos (Liquidación a cargo del reasegurador) + Pagos recibidos de contado
								--Suma de los movimientos del periodo: el criterio en la consideración de los signos es el inverso al CDEBHAB en TIPCTAREA
								SUM(DECODE(m.cconcep, 1, iimport, 0) - DECODE(m.cconcep, 9, iimport, 0) +
										 DECODE(m.cconcep, 23, iimport, 0) + DECODE(m.cconcep, 16, iimport, 0) +
										 DECODE(m.cconcep, 6, iimport, 0) + DECODE(m.cconcep, 4, iimport, 0) +
										 (DECODE(m.cconcep, 24, iimport, 0) * -1) + (DECODE(m.cconcep, 14, iimport, 0) * -1) +
										 (DECODE(m.cconcep, 5, iimport, 0) * -1) + (DECODE(m.cconcep, 13, iimport, 0) * -1) +
										 (DECODE(m.cconcep, 3, iimport, 0) * -1) + (DECODE(m.cconcep, 12, iimport, 0) * -1) +
										 (DECODE(m.cconcep, 2, iimport, 0) * -1) + (DECODE(m.cconcep, 7, iimport, 0) * -1))
								--Saldo Anterior
								 + NVL((SELECT NVL(iimport, 0)
												 FROM movctatecnica
												WHERE cconcep = 30
													AND cempres = c_empresa
													AND scontra = c_scontra
													AND nversio = c_nversio
													AND ccompani = NVL(c_ccompani, ccompani)
													AND ctramo = NVL(c_ctramo, ctramo)
													AND NVL(sproduc, 0) = NVL(c_sproduc, NVL(sproduc, 0))
													AND NVL(ccompapr, 0) = NVL(c_ccompapr, NVL(ccompapr, 0))
													AND fmovimi =
															(CASE c_mes
																 WHEN 01 THEN
																	LAST_DAY(TO_DATE('01/12/' || TO_CHAR(TO_NUMBER(c_any) - 1), 'dd/mm/yyyy'))
																 ELSE
																	LAST_DAY(TO_DATE('01/' || TO_CHAR(TO_NUMBER(c_mes) - 1, '09') || '/' || c_any,
																									 'dd/mm/yyyy'))
															END)), 0)
								--Pagos recibidos de contado (concepto 17)
								 + SUM(DECODE(m.cconcep, 17, iimport, 0))
								--Nuestro Pago (Liquidacion a favor del reasegurador (+))
								 - (NVL((SELECT SUM(NVL(iimport, 0))
													FROM movctaaux -- BUG 28475 - 11/11/2014 - SHA: substituimos MOVCTATECNICA por MOVCTAAUX al tratarse de saldos/movimientos actuales
												 WHERE cconcep = 10
													 AND cempres = c_empresa
													 AND scontra = c_scontra
													 AND nversio = c_nversio
													 AND ccompani = NVL(c_ccompani, ccompani)
													 AND ctramo = NVL(c_ctramo, ctramo)
													 AND NVL(sproduc, 0) = NVL(c_sproduc, NVL(sproduc, 0))
													 AND NVL(ccompapr, 0) = NVL(c_ccompapr, NVL(ccompapr, 0))
													 AND iimport < 0
													 AND fmovimi = LAST_DAY(TO_DATE('01/' || c_mes || '/' || c_any, 'dd/mm/yyyy'))), 0) * -1)
								--Pago Recibidos (Liquidacion a cargo del reasegurador (-))
								 + NVL((SELECT SUM(NVL(iimport, 0))
												 FROM movctaaux -- BUG 28475 - 11/11/2014 - SHA: substituimos MOVCTATECNICA por MOVCTAAUX al tratarse de saldos/movimientos actuales
												WHERE cconcep = 10
													AND cempres = c_empresa
													AND scontra = c_scontra
													AND nversio = c_nversio
													AND ccompani = NVL(c_ccompani, ccompani)
													AND ctramo = NVL(c_ctramo, ctramo)
													AND NVL(sproduc, 0) = NVL(c_sproduc, NVL(sproduc, 0))
													AND NVL(ccompapr, 0) = NVL(c_ccompapr, NVL(ccompapr, 0))
													AND iimport > 0
													AND fmovimi = LAST_DAY(TO_DATE('01/' || c_mes || '/' || c_any, 'dd/mm/yyyy'))), 0) iimport,
								SUM(DECODE(m.cconcep, 1, iimport, 0) - DECODE(m.cconcep, 9, iimport, 0) +
										 DECODE(m.cconcep, 23, iimport, 0) + DECODE(m.cconcep, 16, iimport, 0) +
										 DECODE(m.cconcep, 6, iimport, 0) + DECODE(m.cconcep, 4, iimport, 0) +
										 (DECODE(m.cconcep, 24, iimport, 0) * -1) + (DECODE(m.cconcep, 14, iimport, 0) * -1) +
										 (DECODE(m.cconcep, 5, iimport, 0) * -1) + (DECODE(m.cconcep, 13, iimport, 0) * -1) +
										 (DECODE(m.cconcep, 3, iimport, 0) * -1) + (DECODE(m.cconcep, 12, iimport, 0) * -1) +
										 (DECODE(m.cconcep, 2, iimport, 0) * -1) + (DECODE(m.cconcep, 7, iimport, 0) * -1)) +
								 NVL((SELECT NVL(iimport_moncon, 0)
											 FROM movctatecnica
											WHERE cconcep = 30
												AND cempres = c_empresa
												AND scontra = c_scontra
												AND nversio = c_nversio
												AND ccompani = NVL(c_ccompani, ccompani)
												AND ctramo = NVL(c_ctramo, ctramo)
												AND NVL(sproduc, 0) = NVL(c_sproduc, NVL(sproduc, 0))
												AND NVL(ccompapr, 0) = NVL(c_ccompapr, NVL(ccompapr, 0))
												AND fmovimi = (CASE c_mes
															 WHEN 01 THEN
																LAST_DAY(TO_DATE('01/12/' || TO_CHAR(TO_NUMBER(c_any) - 1), 'dd/mm/yyyy'))
															 ELSE
																LAST_DAY(TO_DATE('01/' || TO_CHAR(TO_NUMBER(c_mes) - 1, '09') || '/' ||
																								 c_any, 'dd/mm/yyyy'))
														END)), 0) + SUM(DECODE(m.cconcep, 17, iimport, 0))
								--Nuestro Pago (Liquidacion a favor del reasegurador (+))
								 - (NVL((SELECT SUM(NVL(iimport, 0))
													FROM movctaaux -- BUG 28475 - 11/11/2014 - SHA: substituimos MOVCTATECNICA por MOVCTAAUX al tratarse de saldos/movimientos actuales
												 WHERE cconcep = 10
													 AND cempres = c_empresa
													 AND scontra = c_scontra
													 AND nversio = c_nversio
													 AND ccompani = NVL(c_ccompani, ccompani)
													 AND ctramo = NVL(c_ctramo, ctramo)
													 AND NVL(sproduc, 0) = NVL(c_sproduc, NVL(sproduc, 0))
													 AND NVL(ccompapr, 0) = NVL(c_ccompapr, NVL(ccompapr, 0))
													 AND iimport < 0
													 AND fmovimi = LAST_DAY(TO_DATE('01/' || c_mes || '/' || c_any, 'dd/mm/yyyy'))), 0) * -1)
								--Pago Recibidos (Liquidacion a cargo del reasegurador (-))
								 + NVL((SELECT SUM(NVL(iimport, 0))
												 FROM movctaaux -- BUG 28475 - 11/11/2014 - SHA: substituimos MOVCTATECNICA por MOVCTAAUX al tratarse de saldos/movimientos actuales
												WHERE cconcep = 10
													AND cempres = c_empresa
													AND scontra = c_scontra
													AND nversio = c_nversio
													AND ccompani = NVL(c_ccompani, ccompani)
													AND ctramo = NVL(c_ctramo, ctramo)
													AND NVL(sproduc, 0) = NVL(c_sproduc, NVL(sproduc, 0))
													AND NVL(ccompapr, 0) = NVL(c_ccompapr, NVL(ccompapr, 0))
													AND iimport > 0
													AND fmovimi = LAST_DAY(TO_DATE('01/' || c_mes || '/' || c_any, 'dd/mm/yyyy'))), 0) iimport_moncon
					 FROM movctaaux m, tipoctarea t -- BUG 28475 - 11/11/2014 - SHA: substituimos MOVCTATECNICA por MOVCTAAUX al tratarse de saldos/movimientos actuales
					WHERE m.cempres = c_empresa
						AND m.scontra = c_scontra
						AND m.nversio = c_nversio
						AND m.ccompani = NVL(c_ccompani, m.ccompani)
						AND m.ctramo = NVL(c_ctramo, m.ctramo)
						AND m.cconcep = t.cconcep
						AND NVL(m.sproduc, 0) = NVL(c_sproduc, NVL(m.sproduc, 0))
						AND NVL(m.ccompapr, 0) = NVL(c_ccompapr, NVL(m.ccompapr, 0))
						AND m.fmovimi = LAST_DAY(TO_DATE('01/' || c_mes || '/' || c_any, 'dd/mm/yyyy'))
						AND t.ctipcta = 1
					GROUP BY m.cempres, LAST_DAY(TO_DATE('01/' || c_mes || '/' || c_any, 'dd/mm/yyyy')), psproces,
									 m.scontra, m.nversio, m.ctramo, m.ccompani, NVL(m.sproduc, 0), NVL(m.ccompapr, 0)
				 UNION
				 SELECT m.cempres, LAST_DAY(TO_DATE('01/' || c_mes || '/' || c_any, 'dd/mm/yyyy')) fmovimi,
								psproces sproces, m.scontra, m.nversio, m.ctramo, m.ccompani, NVL(m.sproduc, 0) sproduc,
								NVL(m.ccompapr, 0) ccompapr, SUM(NVL(iimport, 0)) iimport,
								SUM(NVL(iimport_moncon, 0)) iimport_moncon
					 FROM movctatecnica m, tipoctarea t -- BUG 28475 - 11/11/2014 - SHA: substituimos MOVCTATECNICA por MOVCTAAUX al tratarse de saldos/movimientos actuales
					WHERE m.cempres = c_empresa
						AND m.scontra = c_scontra
						AND m.nversio = c_nversio
						AND m.ccompani = NVL(c_ccompani, m.ccompani)
						AND m.ctramo = NVL(c_ctramo, m.ctramo)
						AND m.cconcep = t.cconcep
						AND NVL(m.sproduc, 0) = NVL(c_sproduc, NVL(m.sproduc, 0))
						AND NVL(m.ccompapr, 0) = NVL(c_ccompapr, NVL(m.ccompapr, 0))
						AND m.fmovimi IN (SELECT MAX(m2.fmovimi)
																FROM movctatecnica m2
															 WHERE m2.fmovimi < LAST_DAY(TO_DATE('01/' || c_mes || '/' || c_any, 'dd/mm/yyyy'))
																 AND m2.cconcep = 30)
						AND m.cconcep = 30
						AND NOT EXISTS
					(SELECT 1
									 FROM movctaaux m2
									WHERE m.scontra = m2.scontra
										AND m.nversio = m2.nversio
										AND m.ctramo = m2.ctramo
										AND NVL(m.sproduc, 0) = NVL(m2.sproduc, 0)
										AND NVL(m.ccompapr, 0) = NVL(m2.ccompapr, 0)
										AND m2.fcierre = LAST_DAY(TO_DATE('01/' || c_mes || '/' || c_any, 'dd/mm/yyyy')))
					GROUP BY m.cempres, LAST_DAY(TO_DATE('01/' || c_mes || '/' || c_any, 'dd/mm/yyyy')), psproces,
									 m.scontra, m.nversio, m.ctramo, m.ccompani, NVL(m.sproduc, 0), NVL(m.ccompapr, 0);
	 
			CURSOR cur_movctaaux_prueba IS
				 SELECT * FROM movctaaux;
	 BEGIN
			v_fcierre := LAST_DAY(TO_DATE('01/' || pmes || '/' || pany, 'dd/mm/yyyy'));
	 
			--Borramos los registros que se pudieron haber creado por un cierre definitivo previo que fue reprocesado
			DELETE movctaaux -- BUG 28475 - 11/11/2014 - SHA: substituimos MOVCTATECNICA por MOVCTAAUX al tratarse de saldos/movimientos actuales
			 WHERE cconcep = 30
				 AND fmovimi = v_fcierre
				 AND cempres = pcempres
				 AND ((pstiporea = 1 AND scontra IN (SELECT scontra FROM codicontratos WHERE ctiprea IN (1, 2))) OR
						 (pstiporea = 2 AND scontra IN (SELECT scontra FROM codicontratos WHERE ctiprea = 3)));
	 
			-- dc_p_trazas(777777, 'en pac_reaseguro_xl.f_insertar_saldo paso 0, pstiporea:'||pstiporea||' v_fcierre:'||
			-- v_fcierre);
			--08/07/2014 SHA: Se unifica la función de saldos en PAC_REASEGURO_XL para proporcional i no propocional (28475)
			IF pstiporea = 1 THEN
				 IF pmes <> '01' THEN
						v_fcierreant := LAST_DAY(TO_DATE('01/' || TO_CHAR(TO_NUMBER(pmes) - 1, '09') || '/' || pany,
																						 'dd/mm/yyyy'));
				 ELSE
						v_fcierreant := LAST_DAY(TO_DATE('01/12/' || TO_CHAR(TO_NUMBER(pany) - 1), 'dd/mm/yyyy'));
				 END IF;
			ELSE
				 v_fcierreant := v_fcierre;
			END IF;
	 
			FOR regcttos IN cttos(pstiporea) LOOP
				 -- dc_p_trazas(777777, 'en pac_reaseguro_xl.f_insertar_saldo paso 1, pcempres:'||pcempres||' regcttos.scontra:'||
				 -- regcttos.scontra||' regcttos.nversio:'||regcttos.nversio||' regcttos.ctramo:'||regcttos.ctramo||' regcttos.ccompani:'||regcttos.ccompani||
				 -- ' NVL(regcttos.sproduc, 0):'||NVL(regcttos.sproduc, 0)||' NVL(regcttos.ccompapr, 0):'||
				 -- NVL(regcttos.ccompapr, 0)||' pmes:'||pmes||' pany:'||pany);
			
				 FOR regmov IN moviments(pcempres, regcttos.scontra, regcttos.nversio, regcttos.ctramo, regcttos.ccompani,
																 NVL(regcttos.sproduc, 0), NVL(regcttos.ccompapr, 0), pmes, pany) LOOP
						v_nnumlin := f_obtener_numlin(regmov.scontra, regmov.nversio, regmov.ctramo, regmov.ccompani, v_error);
						v_traza   := 100;
						-- dc_p_trazas(777777, 'en pac_reaseguro_xl.f_insertar_saldo paso 2, pcempres:'||pcempres||' regcttos.scontra:'||
						-- regcttos.scontra||' regcttos.nversio:'||regcttos.nversio||' regcttos.ctramo:'||regcttos.ctramo||' regcttos.ccompani:'||regcttos.ccompani||
						--  ' NVL(regcttos.sproduc, 0):'||NVL(regcttos.sproduc, 0)||' NVL(regcttos.ccompapr, 0):'||
						--  NVL(regcttos.ccompapr, 0)||' pmes:'||pmes||' pany:'||pany);
						IF v_error = 0 THEN
							 BEGIN
									v_traza := 101;
									--Si es inicio de año obtenemos PMD y afectamos saldo actual
									t_pmd := 0;
							 
									--08/07/2014 SHA: Se unifica la función de saldos en PAC_REASEGURO_XL para proporcional i no propocional (28475)
									IF pstiporea = 2 THEN
										 IF pmes = '01' THEN
												BEGIN
													 SELECT NVL(SUM(iimport), 0)
														 INTO t_pmd
														 FROM movctaaux -- BUG 28475 - 11/11/2014 - SHA: substituimos MOVCTATECNICA por MOVCTAAUX al tratarse de saldos/movimientos actuales
														WHERE cconcep = 20
															AND cempres = pcempres
															AND ccompani = regcttos.ccompani
															AND nversio = regcttos.nversio
															AND scontra = regcttos.scontra
															AND ctramo = regcttos.ctramo
															AND NVL(ccompapr, 0) = NVL(regcttos.ccompapr, 0)
															AND NVL(sproduc, 0) = NVL(regcttos.sproduc, 0)
															AND fmovimi = v_fcierre;
												EXCEPTION
													 WHEN no_data_found THEN
															t_pmd := 0;
												END;
										 END IF;
									END IF;
									-- dc_p_trazas(7777778, 'en pac_reaseguro_xl.f_insertar_saldo paso 3');
							 
									INSERT INTO movctaaux -- BUG 28475 - 11/11/2014 - SHA: substituimos MOVCTATECNICA por MOVCTAAUX
										 (ccompani, nversio, scontra, ctramo, nnumlin, fmovimi, fefecto, cconcep, cdebhab, iimport,
											cestado, sproces, scesrea, fcierre, cempres, sproduc, ccompapr)
									VALUES
										 (regmov.ccompani, regmov.nversio, regmov.scontra, regmov.ctramo, v_nnumlin, v_fcierre,
											v_fcierre, 30,
											-- Saldo
											2, NVL(regmov.iimport + t_pmd, 0), 4, regmov.sproces, NULL, v_fcierre, regmov.cempres,
											regmov.sproduc, regmov.ccompapr);
							 
									v_traza := 102;
							 EXCEPTION
									WHEN dup_val_on_index THEN
										 v_error := 104862;
										 p_tab_error(f_sysdate, f_user, 'pac_reaseguro_xl.f_insert_saldo', v_traza,
																 'Err INSERT INTO movctatecnica:' || regmov.scontra || ', ' || regmov.nversio || ', ' ||
																	regmov.ctramo || ', ' || regmov.ccompani, ' SQLERRM = ' || SQLERRM);
									WHEN OTHERS THEN
										 p_tab_error(f_sysdate, f_user, 'pac_reaseguro_xl.f_insert_saldo', v_traza,
																 'Err INSERT INTO movctatecnica:' || regmov.scontra || ', ' || regmov.nversio || ', ' ||
																	regmov.ctramo || ', ' || regmov.ccompani, ' SQLERRM = ' || SQLERRM);
										 v_error := 104861;
							 END;
						END IF;
				 END LOOP; --moviments
			
				 --Verificamos si para el ctto/version/compania/tramo/producto/compania cedente se grabó saldo y en caso negativo se copia el del mes anterior
				 BEGIN
						SELECT DISTINCT 1
							INTO t_existe_saldo
							FROM movctaaux -- BUG 28475 - 11/11/2014 - SHA: substituimos MOVCTATECNICA por MOVCTAAUX al tratarse de saldos/movimientos actuales
						 WHERE cconcep = 30
							 AND cempres = pcempres
							 AND nversio = regcttos.nversio
							 AND scontra = regcttos.scontra
							 AND ccompani = regcttos.ccompani
							 AND ctramo = regcttos.ctramo
							 AND NVL(ccompapr, 0) = NVL(regcttos.ccompapr, 0)
							 AND NVL(sproduc, 0) = NVL(regcttos.sproduc, 0)
							 AND fmovimi = v_fcierre;
				 EXCEPTION
						WHEN no_data_found THEN
							 v_nnumlin := f_obtener_numlin(regcttos.scontra, regcttos.nversio, regcttos.ctramo,
																						 regcttos.ccompani, v_error);
						
							 IF v_error = 0 THEN
									BEGIN
										 --08/07/2014 SHA: Se unifica la función de saldos en PAC_REASEGURO_XL para proporcional i no propocional (28475)
										 t_existe_saldo_pmd := 0;
										 -- dc_p_trazas(777777, 'en pac_reaseguro_xl.f_insertar_saldo paso 4, t_existe_saldo_pmd:'||t_existe_saldo_pmd||
										 -- ' v_fcierre:'||v_fcierre||' pcempres:'||pcempres||' regcttos.ccompani:'||regcttos.ccompani||
										 -- ' regcttos.nversio:'||regcttos.nversio||' regcttos.scontra:'||regcttos.scontra||' regcttos.ctramo:'||
										 -- regcttos.ctramo||' regcttos.ccompapr:'||regcttos.ccompapr||
										 -- ' pstiporea:'||pstiporea||' regcttos.sproduc:'||regcttos.sproduc);
										 SELECT COUNT(*)
											 INTO t_existe_saldo_pmd
											 FROM movctaaux -- BUG 28475 - 11/11/2014 - SHA: substituimos MOVCTATECNICA por MOVCTAAUX al tratarse de saldos/movimientos actuales
											WHERE cconcep = 30
													 --AND fmovimi = v_fcierre
												AND cempres = 24 --pcempres
												AND ccompani = 551 --regcttos.ccompani
												AND nversio = 1 --regcttos.nversio
												AND scontra = 101 --regcttos.scontra
												AND ctramo = 7 --regcttos.ctramo
										 /*AND((ccompapr IS NULL
                      AND pstiporea = 2)
                     OR(NVL(ccompapr, 0) = NVL(regcttos.ccompapr, 0)
                        AND pstiporea = 1))*/
										 /*AND((sproduc IS NULL
                      AND pstiporea = 2)
                     OR(NVL(sproduc, 0) = NVL(regcttos.sproduc, 0)
                        AND pstiporea = 1))*/
										 ;
									
										 /*for rg_movctaaux in cur_movctaaux_prueba loop
                     --  dc_p_trazas(777777, 'en pac_reaseguro_xl.f_insertar_saldo paso 4_0,
                     -- rg_movctaaux.ccompani:'||rg_movctaaux.ccompani||
                     -- ' rg_movctaaux.nversio:'||rg_movctaaux.nversio||' rg_movctaaux.scontra:'||rg_movctaaux.scontra
                     -- ||' rg_movctaaux.ctramo:'||
                     -- rg_movctaaux.ctramo||' rg_movctaaux.ccompapr:'||rg_movctaaux.ccompapr||
                     -- ' rg_movctaaux.cconcep:'||rg_movctaaux.cconcep||
                     --' rg_movctaaux.sproduc:'||rg_movctaaux.sproduc);
                     end loop;   */
									
										 -- dc_p_trazas(777777, 'en pac_reaseguro_xl.f_insertar_saldo paso 4_1, t_existe_saldo_pmd:'||t_existe_saldo_pmd||
										 -- ' v_fcierre:'||v_fcierre||' pcempres:'||pcempres||' regcttos.ccompani:'||regcttos.ccompani||
										 -- ' regcttos.nversio:'||regcttos.nversio||' regcttos.scontra:'||regcttos.scontra||' regcttos.ctramo:'||
										 -- regcttos.ctramo||' regcttos.ccompapr:'||regcttos.ccompapr||
										 -- ' pstiporea:'||pstiporea||' regcttos.sproduc:'||regcttos.sproduc);
										 IF t_existe_saldo_pmd = 0 THEN
												-- dc_p_trazas(7777778, 'en pac_reaseguro_xl.f_insertar_saldo paso 5, t_existe_saldo_pmd:'||t_existe_saldo_pmd);
												--08/07/2014 SHA: Se unifica la función de saldos en PAC_REASEGURO_XL para proporcional i no propocional (28475)
												INSERT INTO movctaaux -- BUG 28475 - 11/11/2014 - SHA: substituimos MOVCTATECNICA por MOVCTAAUX
													 (ccompani, nversio, scontra, ctramo, nnumlin, fmovimi, fefecto, cconcep, cdebhab,
														iimport, cestado, sproces, scesrea, fcierre, cempres, sproduc, ccompapr)
													 SELECT ccompani, nversio, scontra, ctramo, v_nnumlin,
																	DECODE(pstiporea, 1, v_fcierre, 2, fmovimi), fefecto, 30, 2, iimport, cestado,
																	sproces, scesrea, v_fcierre, m.cempres, m.sproduc, m.ccompapr
														 FROM movctaaux m,
																	-- BUG 28475 - 11/11/2014 - SHA: substituimos MOVCTATECNICA por MOVCTAAUX al tratarse de saldos/movimientos actuales
																	tipoctarea t
														WHERE m.cconcep = DECODE(pstiporea, 1, 30, 20)
															AND m.cempres = pcempres
															AND m.ccompani = regcttos.ccompani
															AND m.nversio = regcttos.nversio
															AND m.scontra = regcttos.scontra
															AND m.ctramo = regcttos.ctramo
															AND NVL(m.ccompapr, 0) = NVL(regcttos.ccompapr, 0)
															AND NVL(m.sproduc, 0) = NVL(regcttos.sproduc, 0)
															AND fmovimi = v_fcierre;
										 END IF;
									EXCEPTION
										 WHEN OTHERS THEN
												p_tab_error(f_sysdate, f_user, 'pac_reaseguro_xl.f_insert_saldo', v_traza,
																		'Err INSERT (PMD) INTO movctatecnica:' || regcttos.scontra || ', ' ||
																		 regcttos.nversio || ', ' || regcttos.ctramo || ', ' || regcttos.ccompani,
																		' SQLERRM = ' || SQLERRM);
									END;
							 END IF;
				 END;
			
				 COMMIT;
			END LOOP; --cttos
			-- insert into movctaaux2
			-- select * from movctaaux;
			COMMIT;
			RETURN v_error;
	 END; --Fin f_insert_saldos

	 --FIN 25860/149606 ETM 24/07/202013---------------
	 -- ***********************************************************************
	 PROCEDURE proceso_batch_cierre(pmodo IN NUMBER, pcempres IN NUMBER, pmoneda IN NUMBER, pcidioma IN NUMBER,
																	pfperini IN DATE, pfperfin IN DATE, pfcierre IN DATE, pcerror OUT NUMBER,
																	psproces OUT NUMBER, pfproces OUT DATE) IS
			/***********************************************************************************************
          Proceso que lanzará el proceso de cierre del Borderó de Reaseguro.
      ************************************************************************************************/
			num_err             NUMBER := 0;
			text_error          VARCHAR2(500);
			pnnumlin            NUMBER;
			texto               VARCHAR2(200);
			v_titulo            VARCHAR2(50);
			psql                VARCHAR2(500);
			pscesrea            NUMBER(8);
			v_ipc               NUMBER(8, 5);
			vpar_traza          VARCHAR2(80) := 'TRAZA_CIERRE_XL'; -- BUG 28475 - 11/11/2014 - SHA
			v_nom_paquete       VARCHAR2(80) := 'PAC_REASEGURO_XL'; -- BUG 28475 - 11/11/2014 - SHA
			v_nom_procedimiento VARCHAR2(80) := 'PROCESO_BATCH_CIERRE'; -- BUG 28475 - 11/11/2014 - SHA
			v_traza             NUMBER := 0;
	 BEGIN
			--DBMS_OUTPUT.put_line('(1.) pmodo:' || pmodo);
			pcerror := 0;
	 
			IF pmodo = 1 THEN
				 v_titulo := 'Proceso Cierre Mensual XL Previo';
			ELSIF pmodo = 2 THEN
				 v_titulo := 'Proceso Cierre Mensual XL  Definitivo';
			END IF;
			-- dc_p_trazas(7777777, 'en el cierre xl');
			--(1.) *** Insertamos en la tabla PROCESOSCAB el registro identificativo de proceso -----
			num_err := f_procesini(f_user, pcempres, 'REASEGURO_XL', v_titulo, psproces);
			p_traza_proceso(pcempres, vpar_traza, psproces, v_nom_paquete, NULL, v_nom_procedimiento, v_traza,
											'Inicio de proceso: ' || psproces || ' pmodo: ' || pmodo || ' pmoneda: ' || pmoneda ||
											 ' pcidioma: ' || pcidioma || ' pfperini: ' || pfperini || ' pfperfin: ' || pfperfin ||
											 ' pfcierre: ' || pfcierre);
	 
			IF num_err = 0 THEN
				 --(2.) Se controla que los porcentajes del IPC estén actualizados para el mes de cierre y se recoje el que corresponde al pago y a fecha de siniestro.
				 v_traza := 1;
			
				 BEGIN
						-- BUG 0021638 - 08/03/2012 - JMF
						v_ipc := f_ipc(TO_CHAR(pfcierre, 'MM'), TO_CHAR(pfcierre, 'YYYY'), 1, 1);
						-- dc_p_trazas(7777777, 'en el cierre xl paso 2, v_ipc:'||v_ipc);
						IF v_ipc IS NULL THEN
							 RAISE no_data_found;
						END IF;
				 EXCEPTION
						WHEN no_data_found THEN
							 -- 20023 AVT 17/01/2012 s'ajusta per si no s'ha de considerar la indexació segons IPC
							 v_traza := 2;
						
							 IF NVL(pac_parametros.f_parempresa_n(pcempres, 'REA_PAGO_NO_INDEX'), 0) = 0 THEN
									p_tab_error(f_sysdate, f_user, 'pac_reaseguro_xl.proceso_batch_cierre', v_traza,
															'Err select ipc',
															'NANYO =' || TO_CHAR(pfcierre, 'YYYY') || ' NMES =' || TO_CHAR(pfcierre, 'MM') ||
															 ' SQLERRM = ' || SQLERRM);
									num_err := 1;
							 ELSE
									num_err := 0;
									v_ipc   := 1; -- 21411 AVT 27-02/2012 s'inicialitza el IPC
							 END IF;
							 -->> Nuevo literal con la descripción: 'No hay porcentaje de IPC para esa fecha de cierre',
						WHEN OTHERS THEN
							 v_traza := 3;
							 p_tab_error(f_sysdate, f_user, 'pac_reaseguro_xl.proceso_batch_cierre', v_traza, 'Err select ipc',
													 'NANYO =' || TO_CHAR(pfcierre, 'YYYY') || ' NMES =' || TO_CHAR(pfcierre, 'MM') ||
														' SQLERRM = ' || SQLERRM);
							 num_err := 1;
				 END;
			
				 p_traza_proceso(pcempres, vpar_traza, psproces, v_nom_paquete, NULL, v_nom_procedimiento, v_traza,
												 'v_ipc: ' || v_ipc);
			
				 -- Controlar si v_ipc no está informado (not found) salir del proceso
				 -- dc_p_trazas(7777777, 'en el cierre xl paso 3');
				 IF num_err = 0 THEN
						--(3.) Se limpian los datos para ese cierre de la tabla auxiliar LIQUIDAREAXLAUX
						--DBMS_OUTPUT.put_line('(3.) limpiar datos');
						v_traza := 4;
						p_traza_proceso(pcempres, vpar_traza, psproces, v_nom_paquete, NULL, v_nom_procedimiento, v_traza,
														'DELETE liquidareaxl_aux');
						-- dc_p_trazas(7777777, 'en el cierre xl paso 4');
						BEGIN
							 DELETE FROM liquidareaxl_aux
								WHERE TRUNC(fcierre) = TRUNC(pfperfin)
										 --JRH
									AND nid IS NULL
							 --JRH
							 ; --TRUNC(pfcierre); -- 21411/108485 AVT 28/02/2012
							 -- AVT 01-08-2013 CONTROL NO BORRAR MOVIMIENTOS MANUALES
						EXCEPTION
							 WHEN OTHERS THEN
									--DBMS_OUTPUT.put_line('(3.) err:' || SQLERRM);
									p_tab_error(f_sysdate, f_user, 'pac_reaseguro_xl.proceso_batch_cierre', v_traza,
															'DELETE FROM liquidareaxl_aux',
															'pfperfin =' || pfperfin || ' SQLERRM = ' || SQLERRM);
									num_err := 1;
						END;
				 
						v_traza := 5;
						p_traza_proceso(pcempres, vpar_traza, psproces, v_nom_paquete, NULL, v_nom_procedimiento, v_traza,
														'DELETE pagosreaxl_aux');
				 
						BEGIN
							 -- dc_p_trazas(7777777, 'en el cierre xl paso 5');
							 DELETE FROM pagosreaxl_aux
								WHERE TRUNC(fcierre) = TRUNC(pfperfin)
										 --JRH
									AND nid IS NULL
							 --JRH
							 ; --TRUNC(pfcierre); -- 21411/108485 AVT 28/02/2012
							 -- AVT 01-08-2013 CONTROL NO BORRAR MOVIMIENTOS MANUALES
						EXCEPTION
							 WHEN OTHERS THEN
									--DBMS_OUTPUT.put_line('(3.) err:' || SQLERRM);
									p_tab_error(f_sysdate, f_user, 'pac_reaseguro_xl.proceso_batch_cierre', v_traza,
															'DELETE FROM pagosreaxl_aux', 'pfperfin =' || pfperfin || ' SQLERRM = ' || SQLERRM);
									num_err := 1;
						END;
				 
						v_traza := 6;
						p_traza_proceso(pcempres, vpar_traza, psproces, v_nom_paquete, NULL, v_nom_procedimiento, v_traza,
														'DELETE movctaaux');
				 
						BEGIN
							 -- dc_p_trazas(7777777, 'en el cierre xl paso 6');
							 DELETE FROM movctaaux
								WHERE TRUNC(fcierre) = TRUNC(pfperfin) --TRUNC(pfcierre); -- 21411/108485 AVT 28/02/2012
									AND ctramo >= 6
										 --JRH
									AND nid IS NULL
							 -- JRH
							 ;
							 -- AVT 01-08-2013 CONTROL NO BORRAR MOVIMIENTOS MANUALES
						EXCEPTION
							 WHEN OTHERS THEN
									--DBMS_OUTPUT.put_line('(3.) err:' || SQLERRM);
									p_tab_error(f_sysdate, f_user, 'pac_reaseguro_xl.proceso_batch_cierre', v_traza,
															'DELETE FROM movctaaux', 'pfperfin =' || pfperfin || ' SQLERRM = ' || SQLERRM);
									num_err := 1;
						END;
				 
						COMMIT;
						--(4.)   Se recojen los Siniestros cubiertos por el XL para ese mes
						-- LLENA_LIQUIDAXL_AUX
						v_traza := 7;
						p_traza_proceso(pcempres, vpar_traza, psproces, v_nom_paquete, NULL, v_nom_procedimiento, v_traza,
														'Entramos en LLENA_LIQUIDAXL_AUX');
						-- dc_p_trazas(7777777, 'en el cierre xl paso 7');
						num_err := llena_liquidaxl_aux(pcempres, pmodo, v_ipc, TO_CHAR(pfperfin, 'mm'),
																					 TO_CHAR(pfperfin, 'yyyy'), pfcierre, psproces, psql, pscesrea, pfperini,
																					 pfperfin);
						--
						v_traza := 8;
						p_traza_proceso(pcempres, vpar_traza, psproces, v_nom_paquete, NULL, v_nom_procedimiento, v_traza,
														'Entramos en F_INSERT_SALDO');
						-- BUG 28475 - 11/11/2014 - SHA : sacamos la llamada a la función f_insert_saldos del modo Definitivo (pmodo=2)
						IF (pcempres != 24) THEN
							 num_err := f_insert_saldo(pcempres, TO_CHAR(pfperfin, 'mm'), TO_CHAR(pfperfin, 'yyyy'), psproces);
						END IF;
						-- fin BUG 28475 - 11/11/2014 - SHA
				 
						--CONFCC-5 Inicio
						IF NVL(pac_parametros.f_parempresa_n(pcempres, 'CALCULA_AJUSTES_XL'), 0) = 1 THEN
							 num_err := f_calcula_ajustes(pcempres, psproces, pfperfin);
						END IF;
						--CONFCC-5 Fin
				 
						--(5.)  Si se trata de un lanzamiento Definitivo:
						IF pmodo = 2 AND num_err = 0 THEN
							 v_traza := 9;
							 p_traza_proceso(pcempres, vpar_traza, psproces, v_nom_paquete, NULL, v_nom_procedimiento, v_traza,
															 'Entramos en LLENAR_TABLAS_DEFI');
							 num_err := pac_reaseguro_xl.llenar_tablas_defi(psql, pscesrea, pcempres, pfperfin);
							 --KBR 21/03/2014
							 --               num_err := f_insert_saldo(pcempres, TO_CHAR(pfperfin, 'mm'),
							 --                                         TO_CHAR(pfperfin, 'yyyy'), psproces);
						END IF;
				 ELSE
						v_traza := 10;
						p_traza_proceso(pcempres, vpar_traza, psproces, v_nom_paquete, NULL, v_nom_procedimiento, v_traza,
														'No existe ipc para el mes de cierre, SQLERRM = ' || SQLERRM);
						p_tab_error(f_sysdate, f_user, 'pac_reaseguro_xl.proceso_batch_cierre', v_traza,
												'No existe ipc para el mes de cierre', ' SQLERRM = ' || SQLERRM);
						pcerror  := 1;
						texto    := 'No existe ipc para el mes de cierre';
						pnnumlin := NULL;
						num_err  := f_proceslin(psproces, SUBSTR(texto || ' ' || text_error, 1, 120), 0, pnnumlin);
				 END IF;
			END IF;
	 
			IF num_err <> 0 THEN
				 -->> AVT: control único de errores
				 v_traza := 11;
				 p_tab_error(f_sysdate, f_user, 'pac_reaseguro_xl.proceso_batch_cierre', v_traza,
										 'control único de errores', ' SQLERRM = ' || SQLERRM);
				 pcerror  := 1;
				 texto    := f_axis_literales(num_err, pcidioma);
				 pnnumlin := NULL;
				 num_err  := f_proceslin(psproces, SUBSTR(texto || ' ' || text_error, 1, 120), 0, pnnumlin);
			END IF;
	 
			pfproces := f_sysdate;
			num_err  := f_procesfin(psproces, num_err);
	 END proceso_batch_cierre;

	 -- ***********************************************************************
	 FUNCTION f_get_bonorec(pscontra IN NUMBER, pnversio IN NUMBER, pctramo IN NUMBER, ppsiniestra IN NUMBER)
			RETURN NUMBER IS
			v_pbonorec NUMBER := 0;
	 BEGIN
			BEGIN
				 SELECT pbonorec
					 INTO v_pbonorec
					 FROM tramo_siniestralidad_bono
					WHERE scontra = pscontra
						AND nversio = pnversio
						AND ctramo = pctramo
						AND psiniestra = ppsiniestra;
			EXCEPTION
				 WHEN no_data_found THEN
						v_pbonorec := 0;
				 WHEN OTHERS THEN
						v_pbonorec := 0;
			END;
	 
			RETURN v_pbonorec;
	 END f_get_bonorec;

	 FUNCTION f_get_comisiterm(pscontra IN NUMBER, pnversio IN NUMBER, pctramo IN NUMBER) RETURN NUMBER IS
			v_pcomisinterm NUMBER := 0;
	 BEGIN
			BEGIN
				 SELECT pcomisinterm
					 INTO v_pcomisinterm
					 FROM tramos
					WHERE scontra = pscontra
						AND nversio = pnversio
						AND ctramo = pctramo;
			EXCEPTION
				 WHEN no_data_found THEN
						v_pcomisinterm := 0;
				 WHEN OTHERS THEN
						v_pcomisinterm := 0;
			END;
	 
			RETURN v_pcomisinterm;
	 END f_get_comisiterm;

	 FUNCTION f_get_tasafija_tramo(pscontra IN NUMBER, pnversio IN NUMBER, pctramo IN NUMBER) RETURN NUMBER IS
			v_tasafija NUMBER := 0;
	 BEGIN
			BEGIN
				 SELECT ptasaxl
					 INTO v_tasafija
					 FROM tramos
					WHERE scontra = pscontra
						AND nversio = pnversio
						AND ctramo = pctramo;
			EXCEPTION
				 WHEN no_data_found THEN
						v_tasafija := 0;
				 WHEN OTHERS THEN
						v_tasafija := 0;
			END;
	 
			RETURN v_tasafija;
	 END f_get_tasafija_tramo;

	 FUNCTION f_get_tasavariable_tramo(pscontra IN NUMBER, pnversio IN NUMBER, pctramo IN NUMBER) RETURN NUMBER IS
			v_tasavariable NUMBER := 0;
	 BEGIN
			BEGIN
				 SELECT ctramotasaxl
					 INTO v_tasavariable
					 FROM tramos
					WHERE scontra = pscontra
						AND nversio = pnversio
						AND ctramo = pctramo;
			EXCEPTION
				 WHEN no_data_found THEN
						v_tasavariable := 0;
				 WHEN OTHERS THEN
						v_tasavariable := 0;
			END;
	 
			RETURN v_tasavariable;
	 END f_get_tasavariable_tramo;

	 FUNCTION f_get_costofijo_tramo(pscontra IN NUMBER, pnversio IN NUMBER, pctramo IN NUMBER) RETURN NUMBER IS
			v_costofijo NUMBER := 0;
	 BEGIN
			BEGIN
				 SELECT icostofijo
					 INTO v_costofijo
					 FROM tramos
					WHERE scontra = pscontra
						AND nversio = pnversio
						AND ctramo = pctramo;
			EXCEPTION
				 WHEN no_data_found THEN
						v_costofijo := 0;
				 WHEN OTHERS THEN
						v_costofijo := 0;
			END;
	 
			RETURN v_costofijo;
	 END f_get_costofijo_tramo;

	 FUNCTION f_insertar_bononr(ppsiniestralidad IN NUMBER, pscontra IN NUMBER, pnversio IN NUMBER,
															pctramo IN NUMBER, pfperfin IN DATE, pccompani IN NUMBER, pcempres IN NUMBER,
															pproces IN NUMBER, pprimanetavg IN NUMBER, pprimanetavi IN NUMBER,
															pprimanetaap IN NUMBER) RETURN NUMBER IS
			vobj                 VARCHAR2(200) := 'PAC_REASEGURO_XL.f_insertar_bononr';
			v_traza              NUMBER := 0;
			v_cestado            NUMBER := 1;
			v_nerror             NUMBER := 0;
			v_plsql              VARCHAR2(500);
			v_numlin             NUMBER := 1;
			v_fconfin            DATE;
			v_pbonorec           NUMBER := 0;
			v_pcomisinterm       NUMBER := 0;
			v_tasa_fija          NUMBER := 0;
			v_tasa_variable      NUMBER := 0;
			v_tprimasnetas_reten NUMBER := 0;
			v_totalbononr        NUMBER := 0;
			v_aux                NUMBER := 0;
			v_costototalcapa     NUMBER := 0;
			v_primasnetascorr    NUMBER := 0;
	 BEGIN
			BEGIN
				 SELECT fconfin
					 INTO v_fconfin
					 FROM contratos
					WHERE scontra = pscontra
						AND nversio = pnversio;
			EXCEPTION
				 WHEN no_data_found THEN
						v_fconfin := f_sysdate;
			END;
	 
			--Si el cierre de mes coincide con la fecha fin de vigencia del contrato
			--se inserta en movctaaux y movctatecnica
			IF pfperfin = v_fconfin THEN
				 --Obtenemos el porcentaje del bono por no reclamaci??         v_pbonorec := f_get_bonorec(pscontra, pnversio, pctramo, ppsiniestralidad);
				 --Obtenemos el % de comisi??e intermediaci??         v_pcomisinterm := f_get_comisiterm(pscontra, pnversio, pctramo);
				 --Obtenemos la tasa fija
				 v_tasa_fija := f_get_tasafija_tramo(pscontra, pnversio, pctramo);
				 --Obtenemos la tasa varaible
				 v_tasa_variable      := f_get_tasavariable_tramo(pscontra, pnversio, pctramo);
				 v_tprimasnetas_reten := pprimanetavg + pprimanetavi + pprimanetaap;
			
				 --Si no hay tasa de reaseguro se utiliza el costo fijo del tramo
				 IF v_tasa_fija <= 0 THEN
						v_tasa_fija := f_get_costofijo_tramo(pscontra, pnversio, pctramo);
				 END IF;
			
				 v_costototalcapa  := v_tprimasnetas_reten * v_tasa_fija;
				 v_primasnetascorr := v_costototalcapa * v_pcomisinterm;
				 v_totalbononr     := v_primasnetascorr * v_pbonorec;
			
				 --Obtenemos el estado de la cuenta t?ica
				 BEGIN
						SELECT NVL(cestado, 1)
							INTO v_cestado
							FROM ctatecnica
						 WHERE scontra = pscontra
							 AND nversio = pnversio
							 AND ctramo = pctramo
							 AND ccompani = pccompani
							 AND ROWNUM = 1;
				 EXCEPTION
						WHEN no_data_found THEN
							 v_cestado := 1;
				 END;
			
				 --Insertamos en tabla movctaaux
				 BEGIN
						v_traza := 1;
				 
						INSERT INTO movctaaux
							 (ccompani, nversio, scontra, ctramo, fmovimi, fefecto, cconcep, cdebhab, iimport, cestado,
								sproces, scesrea, cempres, fcierre)
						VALUES
							 (pccompani, pnversio, pscontra, pctramo, pfperfin, pfperfin, 2, 1, v_totalbononr, v_cestado,
								pproces, NULL, pcempres, pfperfin);
				 EXCEPTION
						WHEN dup_val_on_index THEN
							 v_nerror := 105800;
							 v_plsql  := SUBSTR(SQLERRM, 1, 500);
							 p_tab_error(f_sysdate, f_user, vobj, v_traza, 'Err DUPLICADO INSERT movctaaux - cconcep = ' || 2,
													 ' pscontra=' || pscontra || ' pnversio=' || pnversio || ' pctramo=' || pctramo ||
														' pccompani=' || pccompani || ' SQLERRM = ' || v_plsql);
						WHEN OTHERS THEN
							 v_nerror := 105802;
							 v_plsql  := SUBSTR(SQLERRM, 1, 500);
							 p_tab_error(f_sysdate, f_user, vobj, v_traza, 'Err INSERT movctaaux - cconcep = ' || 2,
													 ' pscontra=' || pscontra || ' pnversio=' || pnversio || ' pctramo=' || pctramo ||
														' pccompani=' || pccompani || ' SQLERRM = ' || v_plsql);
				 END;
			END IF;
	 
			/*Retornar?n 0 si el proceso ha finalizado satisfactoriamente
      y un 1 en caso contrario registrando en la tabla TAB_ERROR la informaci??eferente al error.*/
			RETURN 0;
	 END f_insertar_bononr;

	 --CONFCC-5 Inicio
	 --
	 /***********************************************************************************************
        Función que calcula el total de los Costos de un Contrato
   
   ********************************************************************************************  */
	 FUNCTION f_costos_contrato(p_scontra IN NUMBER, p_nversio IN NUMBER, p_ctramo IN NUMBER, p_ccompani IN NUMBER,
															p_fecmov IN DATE) RETURN NUMBER IS
	 
			v_res NUMBER := 0;
	 
			CURSOR cur_saldo_pmd IS
				 SELECT SUM(iimport)
					 FROM (SELECT SUM(m.iimport) iimport
										FROM movctatecnica m
									 WHERE m.scontra = p_scontra
										 AND m.nversio = p_nversio
										 AND m.ctramo = p_ctramo
										 AND m.ccompani = p_ccompani
										 AND m.cconcep = 22 --Pagos a Realizar (PMD - XL)
										 AND m.fmovimi <= p_fecmov
									UNION ALL
									SELECT SUM(n.iimport) iimport
										FROM movctaaux n
									 WHERE n.scontra = p_scontra
										 AND n.nversio = p_nversio
										 AND n.ctramo = p_ctramo
										 AND n.ccompani = p_ccompani
										 AND n.cconcep = 22 --Pagos a Realizar (PMD - XL)
										 AND n.fmovimi <= p_fecmov);
	 
	 BEGIN
	 
			OPEN cur_saldo_pmd;
			FETCH cur_saldo_pmd
				 INTO v_res;
			CLOSE cur_saldo_pmd;
	 
			RETURN v_res;
	 
	 END f_costos_contrato;
	 --
	 /***********************************************************************************************
        Función que calcula los Ajustes de un Contrato
   
   ********************************************************************************************  */
	 FUNCTION f_ajuste_contrato(p_scontra IN NUMBER, p_nversio IN NUMBER, p_ctramo IN NUMBER, p_ccompani IN NUMBER,
															p_fcierre IN DATE) RETURN NUMBER IS
	 
			v_primas_esp  contratos.iprimaesperadas%TYPE;
			v_primas_ret  movctatecnica.iimport_moncon%TYPE;
			v_primas_est  tramos.iprimaestimada%TYPE;
			v_tasa_ajuste NUMBER;
			v_ajuste      NUMBER := 0;
			v_fconfin     contratos.fconfin%TYPE;
			v_fconfinaux  contratos.fconfinaux%TYPE;
			v_costos_cto  movctatecnica.iimport%TYPE;
			v_cramo       agr_contratos.cramo%TYPE;
	 
			CURSOR cur_primas_ret IS
				 SELECT NVL(SUM(c.icesion), 0)
					 FROM cesionesrea c
					WHERE c.scontra = p_scontra
						AND c.nversio = p_nversio
						AND c.ctramo = 0
						AND c.fefecto <= p_fcierre;
	 
			CURSOR c_cuadroces_agr_ramo(ctr NUMBER, ver NUMBER, tram NUMBER, ram NUMBER, ccomp NUMBER) IS
				 SELECT c.ccompani, c.ctramo, c.iagrega, c.imaxagr, c.pcesion, ct.fconini, 0 iminagr, ccorred, ag.cramo
					 FROM cuadroces c, contratos ct, agr_contratos ag
					WHERE c.scontra = ct.scontra
						AND c.nversio = ct.nversio
						AND ag.scontra = c.scontra
						AND c.scontra = ctr
						AND c.nversio = ver
						AND c.ctramo = tram
						AND ag.cramo = ram
						AND c.ccompani = ccomp;
	 
			reg_compa_ramo c_cuadroces_agr_ramo%ROWTYPE;
	 
	 BEGIN
	 
			SELECT c.fconfin, c.fconfinaux, g.cramo
				INTO v_fconfin, v_fconfinaux, v_cramo
				FROM contratos c, agr_contratos g
			 WHERE c.scontra = p_scontra
				 AND c.nversio = p_nversio
				 AND c.scontra = g.scontra
				 AND (c.nversio = g.nversio OR g.nversio IS NULL);
	 
			--Si es el último cierre del contrato
			IF p_fcierre >= v_fconfinaux THEN
			
				 v_costos_cto := f_costos_contrato(p_scontra, p_nversio, p_ctramo, p_ccompani, p_fcierre);
			
				 SELECT NVL(SUM(c.iprimaesperadas), 0)
					 INTO v_primas_esp
					 FROM contratos c
					WHERE c.scontra = p_scontra
						AND c.nversio = p_nversio;
			
				 SELECT NVL(SUM(t.iprimaestimada), 0), t.ptasaxl --t.ptasaajuste
					 INTO v_primas_est, v_tasa_ajuste
					 FROM tramos t
					WHERE t.scontra = p_scontra
						AND t.nversio = p_nversio
						AND t.ctramo = p_ctramo;
			
				 OPEN cur_primas_ret;
				 FETCH cur_primas_ret
						INTO v_primas_ret;
				 CLOSE cur_primas_ret;
			
				 --Si las primas retenidas fueron mayores a las esperadas, se calcula el Ajuste
				 IF v_primas_ret > 0 AND v_primas_est > 0 AND v_primas_ret > v_primas_est THEN
				 
						OPEN c_cuadroces_agr_ramo(p_scontra, p_nversio, p_ctramo, v_cramo, p_ccompani);
				 
						LOOP
						
							 FETCH c_cuadroces_agr_ramo
									INTO reg_compa_ramo;
						
							 EXIT WHEN c_cuadroces_agr_ramo%NOTFOUND;
						
							 IF pac_reaseguro_rec.f_compania_cutoff(p_ccompani, p_fcierre) = 0 THEN
									--Se calcula la proporción para la compania según el cuadroces
									v_primas_ret := v_primas_ret * reg_compa_ramo.pcesion / 100;
							 
									v_ajuste := v_primas_ret * v_tasa_ajuste / 100;
							 END IF;
						
						END LOOP;
				 
				 END IF;
			
			END IF;
	 
			RETURN v_ajuste;
	 
	 END f_ajuste_contrato;
	 --
	 /***********************************************************************************************
        Función que calcula los Ajustes
   
   ********************************************************************************************  */
	 FUNCTION f_calcula_ajustes(p_cempres IN NUMBER, p_sproces IN NUMBER, p_fperfin IN DATE) RETURN NUMBER IS
	 
			v_res       NUMBER := 0;
			v_iretenido NUMBER;
			v_err       NUMBER;
			v_nnumlin   NUMBER;
	 
			CURSOR cur_movimientos IS
				 SELECT DISTINCT m.scontra, m.nversio, m.ctramo, m.ccompani
					 FROM movctaaux m
					WHERE m.cempres = p_cempres
						AND m.sproces = p_sproces
						AND m.fcierre = p_fperfin;
	 
	 BEGIN
	 
			--Se recorren los contratos que generaron movimientos en la cuenta técnica en el cierre
			FOR c_mov IN cur_movimientos LOOP
			
				 v_res := f_ajuste_contrato(c_mov.scontra, c_mov.nversio, c_mov.ctramo, c_mov.ccompani, p_fperfin);
			
				 IF v_res != 0 AND NVL(pac_parametros.f_parempresa_n(p_cempres, 'APLICA_RET_PRIMAS'), 0) = 1 THEN
				 
						pac_reaseguro_rec.p_calcula_retencion(p_cempres, NULL, NULL, c_mov.ccompani, p_fperfin, v_res,
																									v_iretenido, v_err);
				 
						BEGIN
							 SELECT NVL(MAX(nnumlin), 0)
								 INTO v_nnumlin
								 FROM movctaaux
								WHERE scontra = c_mov.scontra
									AND nversio = c_mov.nversio
									AND ctramo = c_mov.ctramo
									AND ccompani = c_mov.ccompani;
						
							 v_nnumlin := v_nnumlin + 1;
						EXCEPTION
							 WHEN no_data_found THEN
									v_nnumlin := 1;
							 WHEN OTHERS THEN
									v_err := 104863;
									p_tab_error(f_sysdate, f_user, 'pac_reaseguro_xl.f_calcula_ajustes', 1, 'Err SELECT MOVCTAAUX',
															' v_scontra=' || c_mov.scontra || ' v_nversio=' || c_mov.nversio || ' v_ctramo=' ||
															 c_mov.ctramo || ' compa.ccompani=' || c_mov.ccompani || ' SQLERRM = ' || SQLERRM);
						END;
				 
						BEGIN
							 INSERT INTO movctaaux
									(ccompani, nversio, scontra, ctramo, nnumlin, fmovimi, fefecto, cconcep, cdebhab, iimport,
									 cestado, sproces, scesrea, cempres, fcierre, ccompapr, cramo, ccorred)
							 VALUES
									(c_mov.ccompani, c_mov.nversio, c_mov.scontra, c_mov.ctramo, v_nnumlin, p_fperfin, p_fperfin,
									 47, 1, v_iretenido, 1, p_sproces, NULL, p_cempres, p_fperfin, 1, NULL, NULL);
						EXCEPTION
							 WHEN OTHERS THEN
									p_tab_error(f_sysdate, f_user, 'pac_reaseguro_xl.f_calcula_ajustes', 2,
															'Err INSERT movctaaux Ret:' || c_mov.ccompani || ', ' || c_mov.nversio || ', ' ||
															 c_mov.scontra || ', ' || c_mov.ctramo, ' SQLERRM = ' || SQLERRM);
									v_err := 105802;
						END;
				 
				 END IF;
			
			END LOOP;
	 
			RETURN v_res;
	 
	 END f_calcula_ajustes;
	 --
--CONFCC-5 Fin

END pac_reaseguro_xl;
/

	