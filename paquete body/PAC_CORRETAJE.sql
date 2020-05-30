--------------------------------------------------------
--  DDL for Package Body PAC_CORRETAJE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY PAC_CORRETAJE AS
   /******************************************************************************
      NOMBRE:      PAC_CORRETAJE
      PROPÓSITO:   Contiene las funciones de gestión del Co-corretaje

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        28/09/2011   DRA               1. 0019069: LCOL_C001 - Co-corretaje
      2.0        21/11/2011   JMP               2. 0018423: LCOL000 - Multimoneda
      3.0        16/12/2011   APD               3. 0020580: LCOL_C001: Ajuste en el pac_corretaje
      4.0        16/10/2012   DRA               4. 0022402: LCOL_C003: Adaptación del co-corretaje
      5.0        31/10/2012   AVT               5. 0023183: Control del Coasseguro Acceptat
      6.0        21/11/2012   DRA               6. 0024802: LCOL_C001-LCOL: Anulaci?n de p?liza con co-corretaje
      7.0        29/11/2012   DCG               7. 0024782: LCOL_C001-Modificar la contabilidad teniendo en cuenta el co-corretaje
      8.0        23/01/2013   APD               8. 0025831: LCOL999-Modificaci?n en la interface de CxP para env?ar desglose de contabilidad por Co-Corretaje
      9.0        08/02/2013   RDD               9. 0025864: LCOL_F002-Valores con decimales en Resultado de Contabilidad Diaria
      10.0       11/02/2013   DRA              10. 0026049: LCOL: Cálculo del % de comisión con co-corretaje
      11.0       12/02/2013   DRA              11. 0026036: LCOL: Interface de comisiones liquidadas
      12.0       18/02/2013   RDD              12. 0025864: LCOL_F002-Valores con decimales en Resultado de Contabilidad Diaria
      13.0       28/02/2013   DRA              13. 0026229: LCOL: Retorno sobre el recibo de Regularizaci?n de prima m?nima
      14.0       04/03/2013   DRA              14. 0025924: LCOL: Excel de liquidaciones con co-corretaje
      15.0       18/03/2013   DCG              15. 0024866: Repasar incidencias QT para Fase 2
      16.0       04/04/2013   APD              16. 0026341: LCOL: Comisiones de recibos
      17.0       08/07/2013   DCT              17. 0027048: LCOL_T010-Revision incidencias qtracker (V)
      18.0       08/10/2013   MCA              18. 0028445: LCOL: Ajuste para el importe de la COMRECIBO
      19.0       18/10/2013   JLV              19. 0028416: LCOL: Ajuste en función f_esagelider.
      20.0       19/02/2014   JSV              20. 0028479: LCOL895-Incidencias Fase 2 Post-Producci?n UAT
      21.0       12/03/2014   MMM              21. 0029793: LCOL_C004-Descuadre Cuentas contables de Comision con respecto a iAxis
      22.0       27/03/2014   MMM              22. 0030713: LCOL_F002-0011957-11958-11959: Se realizo anulacion...
      23.0       10/04/2014   MMM              23. 0025872: Revision Qtrackers contabilidad
      24.0       01/07/2014   JLV              24. 0032007: Division por 0 en función f_impcorcomi_agente
      25.0       23/07/2014   MMM              25. 0032356: LCOL_F004-0013547: AMOCOM: Error en distribución del valor de la comisión
      26.0       13/11/2014   SHA              26. 0032034: LCOLF3BREA-ID 8 - Ajustes en circuito de Mtto. de Cta. técnica de Coaseguro (INVERFAS)
      27.0       11/12/2014   MMM              27. 0033850: LCOL_A005 - 0015927: Inconsistencia en concepto de recibos en polizas con extornos "Recobro del Retorno”
      28.0       12/01/2015   MMM              28. 0034149: LCOL: Revisión del importe de comisión entre detrecibos y comrecibo
	  29.0       01/07/2015   JCP			   29. 0032034: LCOL: Modificación a realizar pac_corretaje.f_reparto_corretaje
   ******************************************************************************/

   -- 23.0 - 10/04/2014 - MMM - 0025872: Revision Qtrackers contabilidad - Inicio
   FUNCTION f_nmovimi_corr(psseguro IN NUMBER, pnmovimi IN NUMBER)
      RETURN NUMBER IS
      v_nmovimi      NUMBER;
   BEGIN
      SELECT NVL(MAX(a.nmovimi), -1)
        INTO v_nmovimi
        FROM age_corretaje a
       WHERE a.sseguro = psseguro
         AND a.nmovimi <= pnmovimi;

      RETURN v_nmovimi;
   EXCEPTION
      WHEN OTHERS THEN
         v_nmovimi := -1;
         RETURN v_nmovimi;
   END f_nmovimi_corr;

   -- 23.0 - 10/04/2014 - MMM - 0025872: Revision Qtrackers contabilidad - Fin
   FUNCTION f_tiene_corretaje(psseguro IN NUMBER, pnmovimi IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      --
      v_numregs      NUMBER(8);
   BEGIN
      SELECT COUNT(1)
        INTO v_numregs
        FROM age_corretaje c
       WHERE c.sseguro = psseguro
         AND(c.nmovimi = pnmovimi
             OR(pnmovimi IS NULL
                AND c.nmovimi = (SELECT MAX(m.nmovimi)
                                   FROM age_corretaje m
                                  WHERE m.sseguro = c.sseguro)))
         AND ppartici <> 100;

      IF v_numregs = 0 THEN
         RETURN 0;
      ELSE
         RETURN 1;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_corretaje.f_tiene_corretaje', 1,
                     'psseguro = ' || psseguro, SQLERRM);
         RETURN 0;
   END f_tiene_corretaje;

   FUNCTION f_pcomisi_cor(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pcagente IN NUMBER,
      pfretenc IN DATE,
      ppcomisi OUT NUMBER,
      ppretenc OUT NUMBER,
      ptablas IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER IS
      /******************************************************************
         NOMBRE:     F_PCOMISI_COR
         PROPÓSITO:  Función que encuentra la comisión y la retención
                     dependiendo de los parametros de
                     entrada informados(por el producto o por el sseguro)
      *******************************************************************/
      v_pasexec      NUMBER(8) := 0;
      v_param        VARCHAR2(500)
         := 'psseguro: ' || psseguro || ' - pnmovimi: ' || pnmovimi || ' - pcagente: '
            || pcagente || ' - pfretenc: ' || pfretenc || ' - ptablas: ' || ptablas;
      v_object       VARCHAR2(200) := 'PAC_CORRETAJE.f_pcomisi_cor';
      num_error      NUMBER := 0;
      xcretenc       NUMBER;
      xccomisi       NUMBER;
      v_nmovimi      NUMBER;
   BEGIN
      IF pnmovimi IS NULL THEN
         IF ptablas = 'EST' THEN
            SELECT MAX(nmovimi)
              INTO v_nmovimi
              FROM estage_corretaje
             WHERE sseguro = psseguro
               AND cagente = pcagente;
         ELSE
            SELECT MAX(nmovimi)
              INTO v_nmovimi
              FROM age_corretaje
             WHERE sseguro = psseguro
               AND cagente = pcagente;
         END IF;
      ELSE
         v_nmovimi := pnmovimi;
      END IF;

      BEGIN
         SELECT cretenc, ccomisi
           INTO xcretenc, xccomisi
           FROM agentes
          WHERE cagente = pcagente;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 100504;   -- Agent inexistent
      END;

      IF ptablas = 'EST' THEN
         BEGIN
            SELECT c.pcomisi
              INTO ppcomisi
              FROM estage_corretaje c
             WHERE c.sseguro = psseguro
               AND c.cagente = pcagente
               AND c.nmovimi = v_nmovimi;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
               RETURN 100933;   -- Comissió inexistent
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
               RETURN 9902412;   --Error al llegir la taula AGE_CORRETAJE
         END;
      ELSE
         BEGIN
            SELECT c.pcomisi
              INTO ppcomisi
              FROM age_corretaje c
             WHERE c.sseguro = psseguro
               AND c.cagente = pcagente
               AND c.nmovimi = v_nmovimi;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
               RETURN 100933;   -- Comissió inexistent
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
               RETURN 9902412;   -- Error al llegir la taula AGE_CORRETAJE
         END;
      END IF;

      IF ppcomisi IS NULL THEN
         RETURN 100933;   -- Comissió inexistent
      END IF;

      BEGIN
         SELECT pretenc
           INTO ppretenc
           FROM retenciones
          WHERE cretenc = xcretenc
            AND TRUNC(pfretenc) >= TRUNC(finivig)
            AND TRUNC(pfretenc) < TRUNC(NVL(ffinvig, pfretenc + 1));
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, v_object, v_pasexec,
                        v_param || '- xcretenc: ' || xcretenc, SQLERRM);
            RETURN 100726;   -- retención no encontrada
      END;

      RETURN 0;
   END f_pcomisi_cor;

   FUNCTION f_reparto_corretaje(psseguro IN NUMBER, pnmovimi IN NUMBER, pnrecibo IN NUMBER)
      RETURN NUMBER IS
      --
      CURSOR c_corret(pc_sseguro IN NUMBER, pc_nmovimi IN NUMBER) IS
         SELECT c.cagente, c.nmovimi, c.nordage, c.pcomisi, c.ppartici, c.islider
           FROM age_corretaje c
          WHERE c.sseguro = pc_sseguro
            AND(c.nmovimi = pc_nmovimi
                OR(pc_nmovimi IS NULL
                   AND c.nmovimi = (SELECT MAX(m.nmovimi)
                                      FROM age_corretaje m
                                     WHERE m.sseguro = c.sseguro)));

      CURSOR cur_recibos(pc_sseguro IN NUMBER, pc_nmovimi IN NUMBER, pc_nrecibo IN NUMBER) IS
         -- Bug 26341 - APD - 04/04/2013 - se modifica la select para que tenga encuenta
         -- el caso que el pc_nmovimi IS NULL y pc_nrecibo IS NULL
         SELECT   r.nrecibo, r.cempres, r.sseguro, r.fefecto
             FROM recibos r
            WHERE r.sseguro = pc_sseguro
              AND((r.nmovimi = pc_nmovimi
                   AND pc_nmovimi IS NOT NULL
                   AND pc_nrecibo IS NULL)
                  OR(r.nrecibo = pc_nrecibo
                     AND pc_nrecibo IS NOT NULL)
                  OR(pc_nmovimi IS NULL
                     AND pc_nrecibo IS NULL
                     AND r.nrecibo NOT IN(SELECT c.nrecibo
                                            FROM comrecibo c)))
              -- 22.0 - 27/03/2014 - MMM - 0030713: LCOL_F002-0011957-11958-11959: Se realizo anulacion... Inicio
              AND EXISTS(SELECT 1
                           FROM movrecibo m
                          WHERE m.nrecibo = r.nrecibo
                            AND m.cestrec IN(0, 2)
                            AND m.fmovfin IS NULL)
              -- 22.0 - 27/03/2014 - MMM - 0030713: LCOL_F002-0011957-11958-11959: Se realizo anulacion... Fin
              AND NVL(r.cestaux, 0) IN(0, 2)
              AND r.ctiprec NOT IN(13, 15)   --JLV 27/08/2013  bug 27954
         ORDER BY r.nrecibo;

      -- fin Bug 26341 - APD - 04/04/2013
      CURSOR cur_detrecibos(pc_nrecibo IN NUMBER) IS
         SELECT   nriesgo, cgarant, cageven, nmovima
             FROM detrecibos
            WHERE nrecibo = pc_nrecibo
         GROUP BY nriesgo, cgarant, cageven, nmovima;

      v_pasexec      NUMBER(8) := 0;
      v_param        VARCHAR2(500)
         := 'psseguro: ' || psseguro || ' - pnmovimi: ' || pnmovimi || ' - pnrecibo: '
            || pnrecibo;
      v_object       VARCHAR2(200) := 'PAC_CORRETAJE.f_reparto_corretaje';
      v_numerr       NUMBER := 0;
      v_nrecibo      NUMBER;
      v_nmovimi      NUMBER;
      xctipcoa       NUMBER;
      xncuacoa       NUMBER;
      xpcomcoa       NUMBER;
      porcagente     NUMBER;
      porragente     NUMBER;
      pcomisagente   NUMBER;
      pretenagente   NUMBER;
      xccalcom       NUMBER;
      xploccoa       NUMBER;   -- COASEGURO
      xsproduc       seguros.sproduc%TYPE;
      xcgarant       detrecibos.cgarant%TYPE;
      xnriesgo       detrecibos.nriesgo%TYPE;
      xcageven       detrecibos.cageven%TYPE;
      xnmovima       detrecibos.nmovima%TYPE;
      iconcep0       detrecibos.iconcep%TYPE;
      iconcep21      detrecibos.iconcep%TYPE;
      v_icombru      detrecibos.iconcep%TYPE;
      v_icomret      detrecibos.iconcep%TYPE;
      v_icomdev      detrecibos.iconcep%TYPE;
      v_iretdev      detrecibos.iconcep%TYPE;
      v_cestrec      movrecibo.cestrec%TYPE;
      v_fmovdia      movrecibo.fmovdia%TYPE;
      v_smovrec      movrecibo.smovrec%TYPE;   -- BUG 28475 - 13/11/2014 - SHA
      v_fcontab      movrecibo.fcontab%TYPE;
      v_sseguro      seguros.sseguro%TYPE;
      v_cactivi      seguros.cactivi%TYPE;
      v_cramo        seguros.cramo%TYPE;
      v_cmodali      seguros.cmodali%TYPE;
      v_ctipseg      seguros.ctipseg%TYPE;
      v_ccolect      seguros.ccolect%TYPE;
      v_fefecto      seguros.fefecto%TYPE;
      v_cempres      empresas.cempres%TYPE;
      pmoneda        monedas.cmoneda%TYPE := f_parinstalacion_n('MONEDAINST');
      comis_calc     NUMBER;
      comis_calcf    NUMBER;
      reten_calc     NUMBER;
      reten_calcf    NUMBER;
      comis_dev      NUMBER;
      comis_devf     NUMBER;
      reten_dev      NUMBER;
      reten_devf     NUMBER;
      v_hoy          DATE;
      v_cmodcom      comisionprod.cmodcom%TYPE;
      error_proc     EXCEPTION;
      v_fefectovig   DATE;
      vcrespue       pregunpolseg.crespue%TYPE;
      iconcep8       NUMBER;   --BUG27311 DCT- 18/06/2013 - Inici
      v_ajuste       NUMBER;
      v_ajuste_moncia NUMBER;
      v_icombru_moncia NUMBER;
      v_icomdev_moncia NUMBER;
      v_signo        NUMBER;
      comis_devfdet  NUMBER;
      comis_calcfdet NUMBER;
      iconcep50      NUMBER;
      comis_cedidaf  NUMBER;
      comis_cedidafdet NUMBER;
      v_icomcedida_moncia NUMBER;
      v_icomcedida   NUMBER;
      -- 22.0 - 27/03/2014 - MMM - 0030713: LCOL_F002-0011957-11958-11959: Se realizo anulacion... Inicio
      v_tmp_cestrec  NUMBER;
      v_tmp_signo    NUMBER;
      v_tmp_idetrecibos NUMBER;
      v_tmp_idetrecibos_monpol NUMBER;
      v_tmp_icomrec  NUMBER;
      v_tmp_icomrec_moncia NUMBER;
      -- 22.0 - 27/03/2014 - MMM - 0030713: LCOL_F002-0011957-11958-11959: Se realizo anulacion... Fin

      -- 25.0 - 23/07/2014 - MMM -0032356: LCOL_F004-0013547: AMOCOM: Error en distribución del valor de la comisión - Inicio
      iconcep58      NUMBER;
      -- 28.0 - 12/01/2015 - MMM - 0034149: LCOL: Revisión del importe de comisión entre detrecibos y comrecibo - Inicio
      v_tmp_contador NUMBER;
      v_tmp_cagente  NUMBER;

      -- 28.0 - 12/01/2015 - MMM - 0034149: LCOL: Revisión del importe de comisión entre detrecibos y comrecibo - Fin

      -- BUG 28475 - 13/11/2014 - SHA: se crea la función
      FUNCTION f_updcomis_coa(
         pcempres NUMBER,
         psseguro NUMBER,
         pncuacoa NUMBER,
         pnrecibo NUMBER,
         pimporte NUMBER,
         ptipcoa NUMBER,
         psmovrec NUMBER)
         RETURN NUMBER IS
         xittotr        NUMBER;
         ximporte       NUMBER;
         vpasexec       NUMBER := 0;
         xcmoneda       NUMBER;
         v_error        NUMBER := 0;   -- 27.0 -11/12/2014 - MMM - 0033850: LCOL_A005 - 0015927: Inconsistencia en concepto de recibos...
         v_cmultimon    NUMBER;
         v_cmoncontab   NUMBER;
         v_itasa        NUMBER;
         v_importe_mon  NUMBER;
         v_fcambio      DATE;
         v_tobj         VARCHAR2(500) := 'PAC_CORRETAJE.F_UPDCOMIS_COA';
         v_tpar         VARCHAR2(2000)
            := 'pcempres=' || pcempres || ' psseguro=' || psseguro || ' pncuacoa=' || pncuacoa
               || ' pnrecibo=' || pnrecibo || ' pimporte=' || pimporte || ' ptipcoa='
               || ptipcoa || ' psmovrec=' || psmovrec;

         CURSOR c_cias_coa IS
            SELECT ccompan, pcesion
              FROM (SELECT c.sseguro, c.ncuacoa, c.ccompan, ploccoa pcescoa, 0 pcomcoa,
                           0 pcomcon,
                           NVL(pac_preguntas.ff_buscapregunpolseg(s.sseguro, 5700,
                                                                  NULL),
                               0) pcomgas,
                           ploccoa pcesion
                      FROM coacuadro c, seguros s
                     WHERE c.sseguro = s.sseguro
                       AND s.ctipcoa = 8
                       AND c.sseguro = psseguro
                       AND c.ncuacoa = pncuacoa
                    UNION
                    SELECT c.sseguro, c.ncuacoa, c.ccompan, c.pcescoa, c.pcomcoa, c.pcomcon,
                           c.pcomgas, c.pcesion
                      FROM coacedido c, seguros s
                     WHERE c.sseguro = s.sseguro
                       AND s.ctipcoa = 1
                       AND c.sseguro = psseguro
                       AND c.ncuacoa = pncuacoa);
      BEGIN
         FOR i IN c_cias_coa LOOP
            vpasexec := 1;

            BEGIN
               SELECT cmoneda
                 INTO xcmoneda
                 FROM seguros
                WHERE sseguro = psseguro;
            EXCEPTION
               WHEN OTHERS THEN
                  v_error := 1;
                  p_tab_error(f_sysdate, f_user, v_tobj, vpasexec, v_tpar, v_error);
                  RETURN v_error;
            END;

            vpasexec := 2;
            v_cmultimon := NVL(pac_parametros.f_parempresa_n(pcempres, 'MULTIMONEDA'), 0);
            v_cmoncontab := pac_parametros.f_parempresa_n(pcempres, 'MONEDACONTAB');

            IF v_cmultimon = 1 THEN
               vpasexec := 3;
               v_error := pac_oper_monedas.f_datos_contraval(psseguro, NULL, NULL, f_sysdate,
                                                             3, v_itasa, v_fcambio);

               IF v_error <> 0 THEN
                  p_tab_error(f_sysdate, f_user, v_tobj, vpasexec, v_tpar, v_error);
                  RETURN v_error;
               END IF;

               v_importe_mon := f_round(NVL(pimporte, 0) * v_itasa, v_cmoncontab);
            END IF;

            vpasexec := 4;

            UPDATE ctacoaseguro
               SET imovimi = pimporte * i.pcesion / 100,
                   imovimi_moncon = v_importe_mon * i.pcesion / 100
             WHERE sseguro = psseguro
               AND nrecibo = pnrecibo
               AND ccompani = i.ccompan
               AND smovrec = psmovrec
               AND ctipcoa = ptipcoa
               AND cimport = 2;
         END LOOP;

         RETURN v_error;
      EXCEPTION
         WHEN OTHERS THEN
            v_error := 1;
            p_tab_error(f_sysdate, f_user, v_tobj, vpasexec, v_tpar, v_error);
            RETURN v_error;
      END;

      -- 25.0 - 23/07/2014 - MMM -0032356: LCOL_F004-0013547: AMOCOM: Error en distribución del valor de la comisión - Fin
      FUNCTION f_ajuste_moncia(pimporte NUMBER, p_nrecibo NUMBER)
         RETURN NUMBER IS
         v_importe      NUMBER;
         v_cmoncia      parempresas.nvalpar%TYPE;
         v_cmultimon    parempresas.nvalpar%TYPE;
         n_cagente      NUMBER;
         d_hoy          DATE;
         n_nnumcom      NUMBER;
         v_cempres      NUMBER;
         v_femisio      DATE;
         v_itasa        NUMBER;
         v_fcambio      DATE;
         v_tobj         VARCHAR2(500) := 'PAC_corretaje.f_ajuste_moncia';
         v_tpar         VARCHAR2(2000)
                                      := 'p_nrecibo=' || p_nrecibo || ' pimporte=' || pimporte;
         v_ntra         NUMBER(5) := 1;
         e_salir        EXCEPTION;
         n_err          NUMBER;
         v_cmonpol      NUMBER;
      BEGIN
         SELECT MAX(a.cagente), TRUNC(f_sysdate), MAX(b.nnumcom), MAX(a.cempres),
                MAX(a.femisio)
           INTO n_cagente, d_hoy, n_nnumcom, v_cempres,
                v_femisio
           FROM recibos a, comrecibo b
          WHERE a.nrecibo = p_nrecibo
            AND b.nrecibo(+) = a.nrecibo;

         v_cmultimon := NVL(pac_parametros.f_parempresa_n(v_cempres, 'MULTIMONEDA'), 0);

         IF v_cmultimon = 1 THEN
            v_cmoncia := pac_parametros.f_parempresa_n(v_cempres, 'MONEDAEMP');
            n_err := pac_oper_monedas.f_datos_contraval(NULL, p_nrecibo, NULL, v_femisio, 2,
                                                        v_itasa, v_fcambio);
            --Bug 29237: Diferencia Valores Poliza Cocorretaje   MCA
            v_ntra := 6;

            SELECT NVL(cdivisa, v_cmoncia)
              INTO v_cmonpol
              FROM seguros s, productos p
             WHERE s.sproduc = p.sproduc
               AND sseguro = v_sseguro;

            --Bug 29237  Fin
            IF n_err <> 0 THEN
               RAISE e_salir;
            END IF;
         END IF;

         v_importe := f_round(NVL(pimporte, 0) * v_itasa, v_cmoncia);
         RETURN v_importe;
      EXCEPTION
         WHEN e_salir THEN
            p_tab_error(f_sysdate, f_user, v_tobj, v_ntra, v_tpar, n_err);
            RETURN pimporte;
      END;
   BEGIN
      v_pasexec := 1;

      FOR r_rec IN cur_recibos(psseguro, pnmovimi, pnrecibo) LOOP
         v_pasexec := 2;
         v_nrecibo := r_rec.nrecibo;
         v_sseguro := r_rec.sseguro;
         v_cempres := r_rec.cempres;

         SELECT MAX(nmovimi)
           INTO v_nmovimi
           FROM movseguro
          WHERE sseguro = v_sseguro;

         v_pasexec := 4;

         IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'CONTA_DIA'), 0) = 1 THEN
            v_fcontab := NULL;
         ELSE
            v_fcontab := TRUNC(f_sysdate);
         END IF;

         v_pasexec := 6;

         SELECT m.cestrec, m.fmovdia, m.smovrec   -- BUG 28475 - 13/11/2014 - SHA
           INTO v_cestrec, v_fmovdia, v_smovrec   -- BUG 28475 - 13/11/2014 - SHA
           FROM movrecibo m
          WHERE m.nrecibo = v_nrecibo
            AND m.smovrec = (SELECT MAX(m1.smovrec)
                               FROM movrecibo m1
                              WHERE m1.nrecibo = m.nrecibo);

         -- 22.0 - 27/03/2014 - MMM - 0030713: LCOL_F002-0011957-11958-11959: Se realizo anulacion... Inicio
         -- Verificamos que estamos insertando por primera vez la emisión o bien por primera vez la anulación
         -- Si no es así, no hacemos nada
         BEGIN
            SELECT cestrec
              INTO v_tmp_cestrec
              FROM comrecibo
             WHERE nrecibo = v_nrecibo
               AND fmovdia = (SELECT MAX(fmovdia)
                                FROM comrecibo
                               WHERE nrecibo = v_nrecibo)
               AND ROWNUM = 1;
         EXCEPTION
            WHEN OTHERS THEN
               v_tmp_cestrec := NULL;
         END;

         IF (v_tmp_cestrec IS NULL
             AND v_cestrec IN(0, 2))
            OR(v_tmp_cestrec = 0
               AND v_cestrec = 2) THEN
            -- 22.0 - 27/03/2014 - MMM - 0030713: LCOL_F002-0011957-11958-11959: Se realizo anulacion...  Fin

            --CALCUL COMISIONS I RETENCIONS (MODE 'R': REAL)
            --SI SE TRATA DE UN COASEGURO ACEPTADO. PUEDE PASAR QUE NOSOTROS PAGUEMOS DIRECTAMENTE AL
            --AGENTE CON LO QUE PCOMCOA SERA NULO, Y DEBEREMOS IR A BUSCAR LOS PORCENTAJES POR P_FCOMISI.
            --SINO PCOMCOA SERA DIFERENTE A NULO, Y TENDRA EL PORCENTAJE A PAGAR A LA OTRA COMPAÑIA Y LA
            --COMISION Y RETENCIO EN VDETRECIBOS SERA 0.
            v_pasexec := 7;

            SELECT ctipcoa, ncuacoa, fefecto, cactivi, cramo, cmodali, ctipseg,


                   ccolect, pac_monedas.f_moneda_producto(sproduc)

              INTO xctipcoa, xncuacoa, v_fefecto, v_cactivi, v_cramo, v_cmodali, v_ctipseg,
                   v_ccolect, pmoneda
              FROM seguros





             WHERE sseguro = v_sseguro;

            v_pasexec := 8;

            IF xctipcoa <> 0 THEN
               SELECT ploccoa
                 INTO xploccoa
                 FROM coacuadro
                WHERE ncuacoa = xncuacoa
                  AND sseguro = v_sseguro;
            END IF;

            v_pasexec := 9;

            --COASEGURO ACEPTADO NO NOS INTERESA APLICAR DOS VECES EL PORCENTAJE LOCAL
            IF xctipcoa = 8
               OR xctipcoa = 9 THEN
               xploccoa := 100;
            END IF;

            v_pasexec := 10;

            BEGIN
               SELECT p.ccalcom, p.sproduc
                 INTO xccalcom, xsproduc
                 FROM productos p, seguros s
                WHERE p.sproduc = s.sproduc
                  AND s.sseguro = v_sseguro;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  v_numerr := 104347;   -- Producte no trobat a PRODUCTOS
                  RAISE error_proc;
               WHEN OTHERS THEN
                  v_numerr := 102705;   -- Error al llegir de PRODUCTOS
                  RAISE error_proc;
            END;

            -- BUG22402:DRA:10/07/2012:Inici
            v_pasexec := 101;

            IF NVL(pac_parametros.f_parproducto_t(xsproduc, 'FVIG_COMISION'), 'FEFECTO_REC') =
                                                                                  'FEFECTO_REC' THEN
               v_fefectovig := r_rec.fefecto;   --Efecto del recibo
            ELSIF pac_parametros.f_parproducto_t(xsproduc, 'FVIG_COMISION') = 'FEFECTO_POL' THEN   --Efecto de la póliza
               v_pasexec := 102;
               v_numerr := pac_preguntas.f_get_pregunpolseg(v_sseguro, 4046, 'SEG', vcrespue);

               IF v_numerr NOT IN(0, 120135) THEN
                  RETURN v_numerr;
               ELSE
                  v_numerr := 0;
                  v_fefectovig := NVL(TO_DATE(vcrespue, 'YYYYMMDD'), v_fefecto);
               END IF;
            ELSIF pac_parametros.f_parproducto_t(xsproduc, 'FVIG_COMISION') = 'FEFECTO_RENOVA' THEN   -- efecto a la renovacion
               v_fefectovig := TO_DATE(frenovacion(NULL, v_sseguro, 2), 'yyyymmdd');
            END IF;

            -- BUG22402:DRA:10/07/2012:Fi
            v_pasexec := 11;

            DELETE FROM detrecibos
                  WHERE nrecibo = v_nrecibo
                    AND cconcep IN(11, 12, 15, 16, 61, 62, 65, 66);

            v_pasexec := 8;

            OPEN cur_detrecibos(v_nrecibo);

            v_pasexec := 9;

            FETCH cur_detrecibos
             INTO xnriesgo, xcgarant, xcageven, xnmovima;

            v_pasexec := 10;

            WHILE cur_detrecibos%FOUND LOOP
               iconcep0 := 0;
               iconcep21 := 0;
               v_pasexec := 11;

               BEGIN
                  SELECT   NVL(SUM(iconcep), 0)
                      INTO iconcep0
                      FROM detrecibos
                     WHERE nrecibo = v_nrecibo
                       AND nriesgo = xnriesgo
                       AND cgarant = xcgarant
                       AND NVL(nmovima, -1) = NVL(xnmovima, -1)   --JLV Bug 27311. 22/07/2013
                       AND cconcep IN(0, 50)   -- LOCAL + CEDIDA
                  GROUP BY nriesgo, cgarant;
               EXCEPTION
                  WHEN OTHERS THEN
                     iconcep0 := 0;
               END;

               --JLV 10/03/2014 29793/169102
               BEGIN
                  SELECT   NVL(SUM(iconcep), 0)
                      INTO iconcep50
                      FROM detrecibos
                     WHERE nrecibo = v_nrecibo
                       AND nriesgo = xnriesgo
                       AND cgarant = xcgarant
                       AND NVL(nmovima, -1) = NVL(xnmovima, -1)   --JLV Bug 27311. 22/07/2013
                       AND cconcep IN(50)   -- CEDIDA
                  GROUP BY nriesgo, cgarant;
               EXCEPTION
                  WHEN OTHERS THEN
                     iconcep50 := 0;
               END;

               v_pasexec := 12;

               BEGIN
                  SELECT   NVL(SUM(iconcep), 0)
                      INTO iconcep21
                      FROM detrecibos
                     WHERE nrecibo = v_nrecibo
                       AND nriesgo = xnriesgo
                       AND cgarant = xcgarant
                       AND NVL(nmovima, -1) = NVL(xnmovima, -1)   --JLV Bug 27311. 22/07/2013
                       AND cconcep IN(21, 71)   -- LOCAL + CEDIDA
                  GROUP BY nriesgo, cgarant;
               EXCEPTION
                  WHEN OTHERS THEN
                     iconcep21 := 0;
               END;

               v_pasexec := 13;
               --BUG27311 DCT- 18/06/2013 - Inici
               iconcep8 := 0;

               IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'CONCEP_COMISION'), 0) = 1 THEN
                  BEGIN
                     SELECT NVL(SUM(iconcep), 0)
                       INTO iconcep8
                       FROM detrecibos
                      WHERE nrecibo = v_nrecibo
                        AND nriesgo = xnriesgo
                        AND cgarant = xcgarant
                        AND NVL(nmovima, -1) = NVL(xnmovima, -1)   --JLV bug 27311, 22/07/2013
                        AND cconcep IN(8, 58);   -- LOCAL + CEDIDA
                  EXCEPTION
                     WHEN OTHERS THEN
                        iconcep8 := 0;
                  END;
               END IF;

               -- 25.0 - 23/07/2014 - MMM -0032356: LCOL_F004-0013547: AMOCOM: Error en distribución del valor de la comisión - Inicio
               v_pasexec := 14;
               iconcep58 := 0;

               IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'CONCEP_COMISION'), 0) = 1 THEN
                  BEGIN
                     SELECT NVL(SUM(iconcep), 0)
                       INTO iconcep58
                       FROM detrecibos
                      WHERE nrecibo = v_nrecibo
                        AND nriesgo = xnriesgo
                        AND cgarant = xcgarant
                        AND NVL(nmovima, -1) = NVL(xnmovima, -1)   --JLV bug 27311, 22/07/2013
                        AND cconcep IN(58);   -- LOCAL + CEDIDA
                  EXCEPTION
                     WHEN OTHERS THEN
                        iconcep58 := 0;
                  END;
               END IF;

               -- 25.0 - 23/07/2014 - MMM -0032356: LCOL_F004-0013547: AMOCOM: Error en distribución del valor de la comisión - Fin

               --BUG27311 DCT- 18/06/2013 - Fin
               v_pasexec := 17;

               FOR r_corret IN c_corret(v_sseguro, NULL) LOOP
                  v_pasexec := 18;

                  IF f_es_renovacion(v_sseguro) = 0 THEN   -- es cartera
                     v_cmodcom := 2;
                  ELSE   -- si es 1 es nueva produccion
                     v_cmodcom := 1;
                  END IF;

                  v_pasexec := 181;
                  v_numerr := f_pcomisi(v_sseguro, v_cmodcom, v_fefectovig, pcomisagente,
                                        pretenagente, r_corret.cagente, v_cramo, v_cmodali,
                                        v_ctipseg, v_ccolect, v_cactivi, xcgarant, 'POL',
                                        'CAR', v_fefectovig);

                  -- fin Bug 20580 - APD - 16/12/2011
                  IF v_numerr <> 0 THEN
                     RAISE error_proc;
                  END IF;

                  v_pasexec := 19;

                  IF xctipcoa = 8
                     OR xctipcoa = 9 THEN
                     BEGIN
                        v_pasexec := 20;

                        SELECT pcomcoa
                          INTO xpcomcoa
                          FROM coacedido
                         WHERE sseguro = v_sseguro
                           AND ncuacoa = xncuacoa;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN   -- 23183 AVT 31/10/2012
                           porcagente := pcomisagente;
                           porragente := pretenagente;
                        WHEN OTHERS THEN
                           v_numerr := 105582;   -- ERROR AL LEER DE LA TABLA COACEDIDO
                           RAISE error_proc;
                     END;

                     v_pasexec := 21;

                     IF xpcomcoa IS NULL THEN
                        porcagente := pcomisagente;
                        porragente := pretenagente;
                     ELSE
                        porcagente := 0;
                        porragente := 0;
                     END IF;
                  ELSE
                     v_pasexec := 22;
                     porcagente := pcomisagente;
                     porragente := pretenagente;
                  END IF;

                  --CALCUL COMISIONS I RETENCIONS (MODE 'R': REAL)
                  IF xccalcom = 1 THEN   -- Sobre prima
                     v_pasexec := 23;
                     v_numerr := f_pcomisi(v_sseguro, v_cmodcom, v_fefectovig, pcomisagente,
                                           pretenagente, r_corret.cagente, v_cramo, v_cmodali,
                                           v_ctipseg, v_ccolect, v_cactivi, xcgarant, 'POL',
                                           'CAR', v_fefectovig);

                     IF v_numerr <> 0 THEN
                        RAISE error_proc;
                     END IF;
                  END IF;

                  v_pasexec := 24;
                  --Bug 29237  MCA   Ajuste de la comisión
                  v_icombru := ((NVL(iconcep0, 0) + NVL(iconcep8, 0)) * r_corret.ppartici / 100)
                               * porcagente / 100;   --Se ha de enviar a comrecibo
                  comis_calc := f_round(v_icombru, pmoneda);   --Se ha de enviar a la función de f_insdetrec
                  --JLV Bug 29237/162160.
                  comis_calcf := NVL(comis_calcf, 0) + v_icombru;
                  --Bug 29237  Fin
                  v_pasexec := 26;
                  --Bug 29237  MCA   Ajuste de la retención
                  v_icomret :=((v_icombru * porragente) / 100);   -- Se ha de enviar a comrecibo
                  --reten_calc := f_round(((v_icombru * porragente) / 100), pmoneda);   --Se ha de enviar a f_insdetrec
                  reten_calc :=((v_icombru * porragente) / 100);   --Se ha de enviar a f_insdetrec
                  --JLV Bug 29237/162160.
                  reten_calcf := NVL(reten_calcf, 0) + reten_calc;
                  --Bug 29237   Fin

                  --CALCUL COMISIO I RETENCIO DEVENGADES(CCONCEP = 15 I 16)(MODE 'R' : REAL)
                  --COMIS_CALC := ROUND(((COMIS_CALC * PORCAGENTE) / 100), 0);
                  v_pasexec := 28;
                  --Bug 29237  MCA   Ajuste de la comisión devengada
                  v_icomdev := (NVL(iconcep21, 0) * r_corret.ppartici / 100) * porcagente / 100;   --Se ha de enviar a comrecibo
                  --comis_calc := f_round(v_icomdev, pmoneda);   --Se ha de enviar a la función de f_insdetrec
                  comis_dev := f_round(v_icomdev, pmoneda);   --Se ha de enviar a la función de f_insdetrec
                  comis_devf := NVL(comis_devf, 0) + v_icomdev;
                  --Bug 29237  Fin MCA
                  v_pasexec := 30;
                  --Bug 29237  MCA   Ajuste de la retención devengada
                  v_iretdev :=((v_icomdev * porragente) / 100);   -- Se ha de enviar a comrecibo
                  --reten_calc := f_round(((v_icomdev * porragente) / 100), pmoneda);   --Se ha de enviar a f_insdetrec
                  --JLV bug 29850
                  --reten_dev := f_round(((v_icomdev * porragente) / 100), pmoneda);   --Se ha de enviar a f_insdetrec
                  reten_dev :=((v_icomdev * porragente) / 100);   --Se ha de enviar a f_insdetrec
                  reten_devf := NVL(reten_devf, 0) + reten_dev;
                  --Bug 29237  Fin MCA

                  --Ajuste comisión cedida
                  -- 25.0 - 23/07/2014 - MMM - 0032356: LCOL_F004-0013547: AMOCOM: Error en distribución del valor de la comisión - Inicio
                  --v_icomcedida := ((NVL(iconcep50, 0)) * r_corret.ppartici / 100) * porcagente/ 100;   --Se ha de enviar a comrecibo
                  v_icomcedida := ((NVL(iconcep50, 0) + NVL(iconcep58, 0)) * r_corret.ppartici
                                   / 100)
                                  * porcagente / 100;
                  -- 25.0 - 23/07/2014 - MMM - 0032356: LCOL_F004-0013547: AMOCOM: Error en distribución del valor de la comisión - Fin
                  comis_cedidaf := NVL(comis_cedidaf, 0) + v_icomcedida;
                  v_pasexec := 32;
                  -- 22.0 - 27/03/2014 - MMM - 0030713: LCOL_F002-0011957-11958-11959: Se realizo anulacion... Inicio
                  /*v_numerr := pac_comisiones.f_alt_comisionrec(v_nrecibo, v_cestrec, v_fmovdia,
                                                               v_icombru, v_icomret, v_icomdev,
                                                               v_iretdev, r_corret.cagente,
                                                               xcgarant, v_icomcedida);*/
                  v_tmp_signo := 1;

                  IF v_cestrec = 2 THEN
                     v_tmp_signo := -1;
                  END IF;

                  v_numerr := pac_comisiones.f_alt_comisionrec(v_nrecibo, v_cestrec, v_fmovdia,
                                                               v_tmp_signo * v_icombru,
                                                               v_tmp_signo * v_icomret,
                                                               v_tmp_signo * v_icomdev,
                                                               v_tmp_signo * v_iretdev,
                                                               r_corret.cagente, xcgarant,
                                                               v_tmp_signo * v_icomcedida);

                  -- 22.0 - 27/03/2014 - MMM - 0030713: LCOL_F002-0011957-11958-11959: Se realizo anulacion... Inicio
                  IF v_numerr <> 0 THEN
                     RAISE error_proc;
                  END IF;
               END LOOP;

               v_pasexec := 33;

               ----JLV Bug 29743
               IF NVL(comis_calcf, 0) <> 0 THEN
                  --AND NVL(porcagente, 0) <> 0 THEN   Bug 30045  Solo tenemos en cuenta si hay importe comisión
                  v_pasexec := 35;

                  --JLV bug 29850. Si la cantidad insertada en comrecibo no coincide con la que se insertará ahora en detrec
                  --La diferencia asignarla al agente lider.
                  BEGIN
                     SELECT SUM(icombru), SUM(icombru_moncia)
                       INTO v_ajuste, v_ajuste_moncia
                       FROM comrecibo
                      WHERE nrecibo = v_nrecibo
                        AND cgarant = xcgarant
                        -- 22.0 - 27/03/2014 - MMM - 0030713: LCOL_F002-0011957-11958-11959: Se realizo anulacion... Inicio
                        AND cestrec = v_cestrec;
                  -- 22.0 - 27/03/2014 - MMM - 0030713: LCOL_F002-0011957-11958-11959: Se realizo anulacion... Fin
                  EXCEPTION
                     WHEN OTHERS THEN
                        v_ajuste := f_round(comis_calcf);
                        v_ajuste_moncia := f_round(comis_calcf);
                  END;

                  -- Ojo puede recuperar un valor negativo (extorno...)
                  v_signo := SIGN(v_ajuste);
                  v_ajuste := ABS(v_ajuste);
                  comis_calcfdet := comis_calcf;   --Bug 29793  Con signo, se inserta en detrecibos
                  comis_calcf := ABS(comis_calcf);   --Bug 29793  Sin signo
                  -- 22.0 - 27/03/2014 - MMM - 0030713: LCOL_F002-0011957-11958-11959: Se realizo anulacion... Fin
                  v_numerr :=
                     f_insdetrec
                        (v_nrecibo, 11, comis_calcfdet, xploccoa, xcgarant, NVL(xnriesgo, 0),   --Bug  29237  v_icombru  con signo se ha de insertar en detrecibos
                         xctipcoa, xcageven, xnmovima, porcagente, v_sseguro,   -- BUG 18423 - I - 27/12/2011 - JLB - LCOL000 - Multimoneda
                         1, NULL, NULL, NULL, pmoneda);

                  -- BUG 18423 - F - 27/12/2011 - JLB - LCOL000 - Multimoneda
                  IF v_numerr <> 0 THEN
                     RAISE error_proc;
                  END IF;

                  IF NVL(reten_calcf, 0) <> 0 THEN   -- INSERTEM LA RETENCIO
                     v_pasexec := 36;
                     v_numerr :=
                        f_insdetrec
                           (v_nrecibo, 12, reten_calcf, xploccoa, xcgarant, NVL(xnriesgo, 0),   --Bug 29237  v_icomret
                            xctipcoa, xcageven, xnmovima, porcagente, v_sseguro,   -- BUG 18423 - I - 27/12/2011 - JLB - LCOL000 - Multimoneda
                            1, NULL, NULL, NULL, pmoneda);

                     -- BUG 18423 - F - 27/12/2011 - JLB - LCOL000 - Multimoneda
                     IF v_numerr <> 0 THEN
                        RAISE error_proc;
                     END IF;
                  END IF;
               END IF;

               IF NVL(comis_devf, 0) <> 0 THEN
                  --AND NVL(porcagente, 0) <> 0 THEN   Bug 30045  Solo tenemos en cuenta si hay importe comisión
                  --INSERTEM LA COMISIO DEVENGADA
                  v_pasexec := 37;

                  --JLV bug 29850. Si la cantidad insertada en comrecibo no coincide con la que se insertará ahora en detrec
                  --La diferencia asignarla al agente lider.
                  BEGIN
                     SELECT SUM(icomdev), SUM(icomdev_moncia)
                       INTO v_ajuste, v_ajuste_moncia
                       FROM comrecibo
                      WHERE nrecibo = v_nrecibo
                        AND cgarant = xcgarant
                        -- 22.0 - 27/03/2014 - MMM - 0030713: LCOL_F002-0011957-11958-11959: Se realizo anulacion... Inicio
                        AND cestrec = v_cestrec;
                  -- 22.0 - 27/03/2014 - MMM - 0030713: LCOL_F002-0011957-11958-11959: Se realizo anulacion... Fin
                  EXCEPTION
                     WHEN OTHERS THEN
                        v_ajuste := f_round(comis_devf);
                        v_ajuste_moncia := f_round(comis_devf);
                  END;

                  -- Ojo puede recuperar un valor negativo (extorno...)
                  v_signo := SIGN(v_ajuste);
                  v_ajuste := ABS(v_ajuste);
                  comis_devfdet := comis_devf;   --Bug 29793  Con signo, se inserta en detrecibos
                  comis_devf := ABS(comis_devf);
                  v_numerr :=
                     f_insdetrec
                        (v_nrecibo, 15, comis_devfdet, xploccoa, xcgarant, NVL(xnriesgo, 0),   --Bug  29237  v_icomdev  se inserta en detrecibos con signo
                         xctipcoa, xcageven, xnmovima, porcagente, v_sseguro,   -- BUG 18423 - I - 27/12/2011 - JLB - LCOL000 - Multimoneda
                         1, NULL, NULL, NULL, pmoneda);

                  -- BUG 18423 - F - 27/12/2011 - JLB - LCOL000 - Multimoneda
                  IF v_numerr <> 0 THEN
                     RAISE error_proc;
                  END IF;

                  IF NVL(reten_devf, 0) <> 0 THEN
                     -- INSERTEM LA RETENCIO DEVENGADA
                     v_pasexec := 38;
                     v_numerr :=
                        f_insdetrec
                           (v_nrecibo, 16, reten_devf, xploccoa, xcgarant, NVL(xnriesgo, 0),   -- Bug 29237   v_iretdev
                            xctipcoa, xcageven, xnmovima, porcagente, v_sseguro,   -- BUG 18423 - I - 27/12/2011 - JLB - LCOL000 - Multimoneda
                            1, NULL, NULL, NULL, pmoneda);

                     -- BUG 18423 - F - 27/12/2011 - JLB - LCOL000 - Multimoneda
                     IF v_numerr <> 0 THEN
                        RAISE error_proc;
                     END IF;
                  END IF;
               END IF;

               -- JLV PARTE CEDIDA
               IF NVL(comis_cedidaf, 0) <> 0 THEN
                  --INSERTEM LA COMISIO CEDIDA
                  v_pasexec := 39;

                  --La diferencia asignarla al agente lider.
                  BEGIN
                     SELECT SUM(icomcedida), SUM(icomcedida_moncia)
                       INTO v_ajuste, v_ajuste_moncia
                       FROM comrecibo
                      WHERE nrecibo = v_nrecibo
                        AND cgarant = xcgarant
                        -- 22.0 - 27/03/2014 - MMM - 0030713: LCOL_F002-0011957-11958-11959: Se realizo anulacion... Inicio
                        AND cestrec = v_cestrec;
                  -- 22.0 - 27/03/2014 - MMM - 0030713: LCOL_F002-0011957-11958-11959: Se realizo anulacion... Fin
                  EXCEPTION
                     WHEN OTHERS THEN
                        v_ajuste := f_round(comis_cedidaf);
                        v_ajuste_moncia := f_round(comis_cedidaf);
                  END;

                  -- Ojo puede recuperar un valor negativo (extorno...)
                  v_signo := SIGN(v_ajuste);
                  v_ajuste := ABS(v_ajuste);
                  comis_cedidafdet := comis_cedidaf;   --Bug 29793  Con signo, se inserta en detrecibos
                  comis_cedidaf := ABS(comis_cedidaf);

                  --Antes de insertar hacemos un delete porque sino como ya existe hace un update y no funciona.
                  BEGIN
                     DELETE FROM detrecibos
                           WHERE nrecibo = v_nrecibo
                             AND cconcep = 61
                             AND cgarant = xcgarant
                             AND nriesgo = NVL(xnriesgo, 0);
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_tab_error(f_sysdate, f_user, v_object, v_pasexec,
                                    'Error al borrar detrecibo', SQLERRM);
                  END;

                  v_numerr :=
                     f_insdetrec
                        (v_nrecibo, 61, comis_cedidafdet, xploccoa, xcgarant, NVL(xnriesgo, 0),   --Bug  29237  v_icomdev  se inserta en detrecibos con signo
                         0, xcageven, xnmovima, porcagente, v_sseguro,   --JLV xctipcoa le obligamos a que sea 0 para que no recalcule el valor que le pasamos
                         1, NULL, NULL, NULL, pmoneda);
               -- JLV FIN PARTE CEDIDA
               END IF;

               comis_calcf := 0;
               reten_calcf := 0;
               comis_devf := 0;
               reten_devf := 0;
               comis_cedidaf := 0;

               FETCH cur_detrecibos
                INTO xnriesgo, xcgarant, xcageven, xnmovima;
            END LOOP;

            CLOSE cur_detrecibos;

            v_pasexec := 40;

            -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
            DELETE FROM vdetrecibos_monpol
                  WHERE nrecibo = v_nrecibo;

            -- FIN BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
            DELETE FROM vdetrecibos
                  WHERE nrecibo = v_nrecibo;

            --Bug 32034 Ajuste de coaseguro
            DELETE FROM ctacoaseguro
                  WHERE nrecibo = v_nrecibo
                    AND smovrec = v_smovrec;

            --- en la f_vdetrecibos se vuelven a generar los conceptos
            v_pasexec := 41;
            v_numerr := f_vdetrecibos('R', v_nrecibo);

            IF v_numerr <> 0 THEN
               RAISE error_proc;
            END IF;
         -- 22.0 - 27/03/2014 - MMM - 0030713: LCOL_F002-0011957-11958-11959: Se realizo anulacion...  Inicio
         END IF;   -- Del IF que mira si tenemos que insertar registro

         -- Dejamos aqui la parte de código que se encarga de realizar los ajustes para cada recibo
         -- Estamos dentro del cursor principal de recibos, por lo que tenemos informado v_nrecibo y v_cestrec
         -- Comparamos los importes de DETRECIBOS con los de COMRECIBO y si hay diferencias, ajustamos COMRECIBO
         -- para la garantía que corresponda y el agente líder
         FOR c IN cur_detrecibos(v_nrecibo) LOOP
            v_pasexec := 42;

            -- Ajuste COMRECIBO -- ICOMBRU -- CONCEPTOS 11 y 61
            BEGIN
               SELECT NVL(SUM(iconcep), 0), NVL(SUM(iconcep_monpol), 0)
                 INTO v_tmp_idetrecibos, v_tmp_idetrecibos_monpol
                 FROM detrecibos
                WHERE nrecibo = v_nrecibo
                  AND cgarant = c.cgarant
                  AND cconcep IN(11, 61)
                  AND nriesgo = NVL(c.nriesgo, 0);

               v_pasexec := 43;

               SELECT NVL(SUM(icombru), 0), NVL(SUM(icombru_moncia), 0)
                 INTO v_tmp_icomrec, v_tmp_icomrec_moncia
                 FROM comrecibo
                WHERE nrecibo = v_nrecibo
                  AND cgarant = c.cgarant
                  AND cestrec = v_cestrec;

               IF ABS(v_tmp_idetrecibos) - ABS(v_tmp_icomrec) <> 0
                  OR ABS(v_tmp_idetrecibos_monpol) - ABS(v_tmp_icomrec_moncia) <> 0 THEN
                  v_pasexec := 44;

                  -- 28.0 - 12/01/2015 - MMM - 0034149: LCOL: Revisión del importe de comisión entre detrecibos y comrecibo - Inicio

                  -- Comprobamos que el agente líder tenga importe de comisión. Si no tiene, haremos el ajuste sobre otro agente
                  SELECT COUNT(*)
                    INTO v_tmp_contador
                    FROM comrecibo
                   WHERE nrecibo = v_nrecibo
                     AND cagente = (SELECT cagente
                                      FROM age_corretaje a
                                     WHERE sseguro = psseguro
                                       AND islider = 1
                                       AND nmovimi =
                                             (SELECT MAX(nmovimi)
                                                FROM age_corretaje ag
                                               WHERE ag.sseguro = a.sseguro
                                                 AND nmovimi <= pnmovimi))
                     AND NVL(icombru, 0) <> 0
                     AND cgarant = c.cgarant
                     AND cestrec = v_cestrec;

                  IF v_tmp_contador <> 0 THEN
                     UPDATE comrecibo
                        SET icombru = icombru
                                      + SIGN(icombru)
                                        *(ABS(v_tmp_idetrecibos) - ABS(v_tmp_icomrec)),
                            icombru_moncia = icombru_moncia
                                             + SIGN(icombru_moncia)
                                               *(ABS(v_tmp_idetrecibos_monpol)
                                                 - ABS(v_tmp_icomrec_moncia))
                      WHERE nrecibo = v_nrecibo
                        AND cagente = (SELECT cagente
                                         FROM age_corretaje a
                                        WHERE sseguro = psseguro
                                          AND islider = 1
                                          AND nmovimi =
                                                (SELECT MAX(nmovimi)
                                                   FROM age_corretaje ag
                                                  WHERE ag.sseguro = a.sseguro
                                                    AND nmovimi <= pnmovimi))
                        AND cgarant = c.cgarant
                        AND cestrec = v_cestrec;
                  ELSE
                     SELECT MAX(cagente)
                       INTO v_tmp_cagente
                       FROM comrecibo
                      WHERE nrecibo = v_nrecibo
                        AND cagente = (SELECT cagente
                                         FROM age_corretaje a
                                        WHERE sseguro = psseguro
                                          AND islider <> 1
                                          AND nmovimi =
                                                (SELECT MAX(nmovimi)
                                                   FROM age_corretaje ag
                                                  WHERE ag.sseguro = a.sseguro
                                                    AND nmovimi <= pnmovimi))
                        AND NVL(icombru, 0) <> 0
                        AND cgarant = c.cgarant
                        AND cestrec = v_cestrec;

                     IF v_tmp_cagente IS NOT NULL THEN
                        UPDATE comrecibo
                           SET icombru = icombru
                                         + SIGN(icombru)
                                           *(ABS(v_tmp_idetrecibos) - ABS(v_tmp_icomrec)),
                               icombru_moncia = icombru_moncia
                                                + SIGN(icombru_moncia)
                                                  *(ABS(v_tmp_idetrecibos_monpol)
                                                    - ABS(v_tmp_icomrec_moncia))
                         WHERE nrecibo = v_nrecibo
                           AND cagente = v_tmp_cagente
                           AND cgarant = c.cgarant
                           AND cestrec = v_cestrec;
                     END IF;   -- Del IF que mira si encontramos agente con importe de comisión en COMRECIBO
                  END IF;   -- Del IF que mira v_tmp_contador para ver si el líder tiene comisión
               -- 28.0 - 12/01/2015 - MMM - 0034149: LCOL: Revisión del importe de comisión entre detrecibos y comrecibo - Fin
               END IF;
            EXCEPTION
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
            END;

            v_pasexec := 45;

            -- Ajuste COMRECIBO -- ICOMDEV -- CONCEPTOS 15 y 65
            BEGIN
               SELECT NVL(SUM(iconcep), 0), NVL(SUM(iconcep_monpol), 0)
                 INTO v_tmp_idetrecibos, v_tmp_idetrecibos_monpol
                 FROM detrecibos
                WHERE nrecibo = v_nrecibo
                  AND cgarant = c.cgarant
                  AND cconcep IN(15, 65)
                  AND nriesgo = NVL(c.nriesgo, 0);

               v_pasexec := 46;

               SELECT NVL(SUM(icomdev), 0), NVL(SUM(icomdev_moncia), 0)
                 INTO v_tmp_icomrec, v_tmp_icomrec_moncia
                 FROM comrecibo
                WHERE nrecibo = v_nrecibo
                  AND cgarant = c.cgarant
                  AND cestrec = v_cestrec;

               IF ABS(v_tmp_idetrecibos) - ABS(v_tmp_icomrec) <> 0
                  OR ABS(v_tmp_idetrecibos_monpol) - ABS(v_tmp_icomrec_moncia) <> 0 THEN
                  v_pasexec := 47;

                  -- 28.0 - 12/01/2015 - MMM - 0034149: LCOL: Revisión del importe de comisión entre detrecibos y comrecibo - Inicio
                  -- Comprobamos que el agente líder tenga importe de comisión. Si no tiene, haremos el ajuste sobre otro agente
                  SELECT COUNT(*)
                    INTO v_tmp_contador
                    FROM comrecibo
                   WHERE nrecibo = v_nrecibo
                     AND cagente = (SELECT cagente
                                      FROM age_corretaje a
                                     WHERE sseguro = psseguro
                                       AND islider = 1
                                       AND nmovimi =
                                             (SELECT MAX(nmovimi)
                                                FROM age_corretaje ag
                                               WHERE ag.sseguro = a.sseguro
                                                 AND nmovimi <= pnmovimi))
                     AND NVL(icomdev, 0) <> 0
                     AND cgarant = c.cgarant
                     AND cestrec = v_cestrec;

                  IF v_tmp_contador <> 0 THEN
                     UPDATE comrecibo
                        SET icomdev = icomdev
                                      + SIGN(icomdev)
                                        *(ABS(v_tmp_idetrecibos) - ABS(v_tmp_icomrec)),
                            icomdev_moncia = icomdev_moncia
                                             + SIGN(icomdev_moncia)
                                               *(ABS(v_tmp_idetrecibos_monpol)
                                                 - ABS(v_tmp_icomrec_moncia))
                      WHERE nrecibo = v_nrecibo
                        AND cagente = (SELECT cagente
                                         FROM age_corretaje a
                                        WHERE sseguro = psseguro
                                          AND islider = 1
                                          AND nmovimi =
                                                (SELECT MAX(nmovimi)
                                                   FROM age_corretaje ag
                                                  WHERE ag.sseguro = a.sseguro
                                                    AND nmovimi <= pnmovimi))
                        AND cgarant = c.cgarant
                        AND cestrec = v_cestrec;
                  ELSE
                     SELECT MAX(cagente)
                       INTO v_tmp_cagente
                       FROM comrecibo
                      WHERE nrecibo = v_nrecibo
                        AND cagente = (SELECT cagente
                                         FROM age_corretaje a
                                        WHERE sseguro = psseguro
                                          AND islider <> 1
                                          AND nmovimi =
                                                (SELECT MAX(nmovimi)
                                                   FROM age_corretaje ag
                                                  WHERE ag.sseguro = a.sseguro
                                                    AND nmovimi <= pnmovimi))
                        AND NVL(icomdev, 0) <> 0
                        AND cgarant = c.cgarant
                        AND cestrec = v_cestrec;

                     IF v_tmp_cagente IS NOT NULL THEN
                        UPDATE comrecibo
                           SET icomdev = icomdev
                                         + SIGN(icomdev)
                                           *(ABS(v_tmp_idetrecibos) - ABS(v_tmp_icomrec)),
                               icomdev_moncia = icomdev_moncia
                                                + SIGN(icomdev_moncia)
                                                  *(ABS(v_tmp_idetrecibos_monpol)
                                                    - ABS(v_tmp_icomrec_moncia))
                         WHERE nrecibo = v_nrecibo
                           AND cagente = v_tmp_cagente
                           AND cgarant = c.cgarant
                           AND cestrec = v_cestrec;
                     END IF;   -- Del IF que mira si encontramos agente con importe de comisión en COMRECIBO
                  END IF;   -- Del IF que mira v_tmp_contador para ver si el líder tiene comisión
               -- 28.0 - 12/01/2015 - MMM - 0034149: LCOL: Revisión del importe de comisión entre detrecibos y comrecibo - Fin
               END IF;
            EXCEPTION
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
            END;

            v_pasexec := 48;

            -- Ajuste COMRECIBO -- ICOMCEDIDA
            BEGIN
               SELECT NVL(SUM(iconcep), 0), NVL(SUM(iconcep_monpol), 0)
                 INTO v_tmp_idetrecibos, v_tmp_idetrecibos_monpol
                 FROM detrecibos
                WHERE nrecibo = v_nrecibo
                  AND cgarant = c.cgarant
                  AND cconcep IN(61)
                  AND nriesgo = NVL(c.nriesgo, 0);

               v_pasexec := 49;

               SELECT NVL(SUM(icomcedida), 0), NVL(SUM(icomcedida_moncia), 0)
                 INTO v_tmp_icomrec, v_tmp_icomrec_moncia
                 FROM comrecibo
                WHERE nrecibo = v_nrecibo
                  AND cgarant = c.cgarant
                  AND cestrec = v_cestrec;

               IF ABS(v_tmp_idetrecibos) - ABS(v_tmp_icomrec) <> 0
                  OR ABS(v_tmp_idetrecibos_monpol) - ABS(v_tmp_icomrec_moncia) <> 0 THEN
                  v_pasexec := 50;

                  -- 28.0 - 12/01/2015 - MMM - 0034149: LCOL: Revisión del importe de comisión entre detrecibos y comrecibo - Inicio
                  -- Comprobamos que el agente líder tenga importe de comisión. Si no tiene, haremos el ajuste sobre otro agente
                  SELECT COUNT(*)
                    INTO v_tmp_contador
                    FROM comrecibo
                   WHERE nrecibo = v_nrecibo
                     AND cagente = (SELECT cagente
                                      FROM age_corretaje a
                                     WHERE sseguro = psseguro
                                       AND islider = 1
                                       AND nmovimi =
                                             (SELECT MAX(nmovimi)
                                                FROM age_corretaje ag
                                               WHERE ag.sseguro = a.sseguro
                                                 AND nmovimi <= pnmovimi))
                     AND NVL(icomcedida, 0) <> 0
                     AND cgarant = c.cgarant
                     AND cestrec = v_cestrec;

                  IF v_tmp_contador <> 0 THEN
                     UPDATE comrecibo
                        SET icomcedida = icomcedida
                                         + SIGN(icomcedida)
                                           *(ABS(v_tmp_idetrecibos) - ABS(v_tmp_icomrec)),
                            icomcedida_moncia = icomcedida_moncia
                                                + SIGN(icomcedida_moncia)
                                                  *(ABS(v_tmp_idetrecibos_monpol)
                                                    - ABS(v_tmp_icomrec_moncia))
                      WHERE nrecibo = v_nrecibo
                        AND cagente = (SELECT cagente
                                         FROM age_corretaje a
                                        WHERE sseguro = psseguro
                                          AND islider = 1
                                          AND nmovimi =
                                                (SELECT MAX(nmovimi)
                                                   FROM age_corretaje ag
                                                  WHERE ag.sseguro = a.sseguro
                                                    AND nmovimi <= pnmovimi))
                        AND cgarant = c.cgarant
                        AND cestrec = v_cestrec;
                  ELSE
                     SELECT MAX(cagente)
                       INTO v_tmp_cagente
                       FROM comrecibo
                      WHERE nrecibo = v_nrecibo
                        AND cagente = (SELECT cagente
                                         FROM age_corretaje a
                                        WHERE sseguro = psseguro
                                          AND islider <> 1
                                          AND nmovimi =
                                                (SELECT MAX(nmovimi)
                                                   FROM age_corretaje ag
                                                  WHERE ag.sseguro = a.sseguro
                                                    AND nmovimi <= pnmovimi))
                        AND NVL(icomcedida, 0) <> 0
                        AND cgarant = c.cgarant
                        AND cestrec = v_cestrec;

                     IF v_tmp_cagente IS NOT NULL THEN
                        UPDATE comrecibo
                           SET icomcedida = icomcedida
                                            + SIGN(icomcedida)
                                              *(ABS(v_tmp_idetrecibos) - ABS(v_tmp_icomrec)),
                               icomcedida_moncia =
                                  icomcedida_moncia
                                  + SIGN(icomcedida_moncia)
                                    *(ABS(v_tmp_idetrecibos_monpol) - ABS(v_tmp_icomrec_moncia))
                         WHERE nrecibo = v_nrecibo
                           AND cagente = v_tmp_cagente
                           AND cgarant = c.cgarant
                           AND cestrec = v_cestrec;
                     END IF;   -- Del IF que mira si encontramos agente con importe de comisión en COMRECIBO
                  END IF;   -- Del IF que mira v_tmp_contador para ver si el líder tiene comisión
               -- 28.0 - 12/01/2015 - MMM - 0034149: LCOL: Revisión del importe de comisión entre detrecibos y comrecibo - Fin
               END IF;
            EXCEPTION
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
            END;
         END LOOP;

         -- 22.0 - 27/03/2014 - MMM - 0030713: LCOL_F002-0011957-11958-11959: Se realizo anulacion... Fin

         -- BUG 28475 - 13/11/2014 - SHA
         SELECT NVL(SUM(iconcep), 0)
           INTO v_tmp_idetrecibos
           FROM detrecibos
          WHERE nrecibo = v_nrecibo
            AND cconcep IN(61);

         v_numerr := f_updcomis_coa(v_cempres, v_sseguro, xncuacoa, v_nrecibo,
                                    v_tmp_idetrecibos, xctipcoa, v_smovrec);
      -- fin BUG 28475
      END LOOP;

      RETURN v_numerr;
   EXCEPTION
      WHEN error_proc THEN
         -- BUG -21546_108724 - 04/02/2012 - JLTS - Cierre de cursores
         IF cur_detrecibos%ISOPEN THEN
            CLOSE cur_detrecibos;
         END IF;

         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_numerr,
                     f_axis_literales(v_numerr, f_usu_idioma));
         RETURN v_numerr;
      WHEN OTHERS THEN
         -- BUG -21546_108724 - 04/02/2012 - JLTS - Cierre de cursores
         IF cur_detrecibos%ISOPEN THEN
            CLOSE cur_detrecibos;
         END IF;

         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, SQLCODE, SQLERRM);
         RETURN 9902428;
   END f_reparto_corretaje;

   FUNCTION f_traspaso_corretaje(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnrecibo IN NUMBER,
      pcageini IN NUMBER,
      pcagefin IN NUMBER)
      RETURN NUMBER IS
      /******************************************************************
         NOMBRE:     F_TRASPASO_CORRETAJE
         PROPÓSITO:  Función que traspasa los datos de corretaje
      *******************************************************************/
      v_pasexec      NUMBER(8) := 0;
      v_param        VARCHAR2(500)
         := 'psseguro: ' || psseguro || ' - pnrecibo: ' || pnrecibo || ' - pcageini: '
            || pcageini || ' - pcagefin: ' || pcagefin;
      v_object       VARCHAR2(200) := 'PAC_CORRETAJE.f_traspaso_corretaje';
      num_err        NUMBER := 0;
      v_cempres      recibos.cempres%TYPE;
      v_hoy          DATE;
      v_fcontab      DATE;
      v_nnumcom      NUMBER;
      v_cestrec      movrecibo.cestrec%TYPE;
      v_fmovdia      DATE;
   BEGIN
      IF pnrecibo IS NOT NULL THEN
         SELECT cempres
           INTO v_cempres
           FROM recibos a
          WHERE a.nrecibo = pnrecibo;

         IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'CONTA_DIA'), 0) = 1 THEN
            v_fcontab := NULL;
         ELSE
            v_fcontab := TRUNC(f_sysdate);
         END IF;

         SELECT m.cestrec, m.fmovdia
           INTO v_cestrec, v_fmovdia
           FROM movrecibo m
          WHERE m.nrecibo = pnrecibo
            AND m.smovrec = (SELECT MAX(m1.smovrec)
                               FROM movrecibo m1
                              WHERE m1.nrecibo = m.nrecibo);

         UPDATE recibos
            SET cagente = pcagefin
          WHERE nrecibo = pnrecibo
            AND cagente = pcageini;

         FOR cor IN (SELECT   cr.nrecibo, cr.cagente, SUM(cr.icombru) icombru,
                              SUM(cr.icomret) icomret, SUM(cr.icomdev) icomdev,
                              SUM(cr.iretdev) iretdev, cr.cgarant
                         FROM comrecibo cr
                        WHERE cr.nrecibo = pnrecibo
                          AND cr.cagente = pcageini
                     GROUP BY cr.nrecibo, cr.cagente, cr.cgarant) LOOP
            num_err := pac_comisiones.f_anu_comisionrec(cor.nrecibo, v_cestrec, v_fmovdia,
                                                        cor.icombru, cor.icomret, cor.icomdev,
                                                        cor.iretdev, pcageini, cor.cgarant);
            num_err := pac_comisiones.f_alt_comisionrec(cor.nrecibo, v_cestrec, v_fmovdia,
                                                        cor.icombru, cor.icomret, cor.icomdev,
                                                        cor.iretdev, pcagefin, cor.cgarant);
         END LOOP;
      ELSE
         -- Creamos un nuevo movimiento de esta tabla
         FOR cor IN (SELECT c.sseguro, c.cagente, c.nmovimi, c.nordage, c.pcomisi, c.ppartici,
                            c.islider
                       FROM age_corretaje c
                      WHERE c.sseguro = psseguro
                        AND c.nmovimi = PAC_ISQLFOR_CONF.f_get_ultmov(c.sseguro,1)) LOOP
						
            IF cor.cagente = pcagefin THEN
               -- Si ya existe en el corretaje, daremos error y abortamos
               RETURN 9902560;
            ELSE
               INSERT INTO age_corretaje
                           (sseguro,
                            cagente, nmovimi,
                            nordage, pcomisi, ppartici, islider)
                    VALUES (cor.sseguro,
                            DECODE(cor.cagente, pcageini, pcagefin, cor.cagente), pnmovimi,
                            cor.nordage, cor.pcomisi, cor.ppartici, cor.islider);
            END IF;
         END LOOP;
      END IF;

      RETURN num_err;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, SQLCODE, SQLERRM);
         RETURN 9902429;
   END f_traspaso_corretaje;

   -- BUG25924:DRA:04/03/2013:Inici
   FUNCTION f_segprima_corr(psseguro IN NUMBER, ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_prima        NUMBER;
   BEGIN
      IF ptablas = 'EST' THEN
         SELECT SUM(g.iprianu * NVL(r.nasegur, 1))
           INTO v_prima
           FROM estriesgos r, estgaranseg g
          WHERE r.sseguro = psseguro
            AND g.sseguro = r.sseguro
            AND g.nriesgo = r.nriesgo
            AND g.nmovimi = (SELECT MAX(g1.nmovimi)
                               FROM estgaranseg g1
                              WHERE g1.sseguro = g.sseguro
                                AND g1.nriesgo = g.nriesgo);
      ELSIF ptablas = 'SOL' THEN
         SELECT SUM(g.iprianu * NVL(r.nasegur, 1))
           INTO v_prima
           FROM solriesgos r, solgaranseg g
          WHERE r.ssolicit = psseguro
            AND g.ssolicit = r.ssolicit
            AND g.nriesgo = r.nriesgo;
      ELSE
         SELECT SUM(g.iprianu * NVL(r.nasegur, 1))
           INTO v_prima
           FROM riesgos r, garanseg g
          WHERE r.sseguro = psseguro
            AND g.sseguro = r.sseguro
            AND g.nriesgo = r.nriesgo
            AND g.nmovimi = (SELECT MAX(g1.nmovimi)
                               FROM garanseg g1
                              WHERE g1.sseguro = g.sseguro
                                AND g1.nriesgo = g.nriesgo);
      END IF;

      RETURN v_prima;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_CORRETAJE.f_segprima_corr', 99,
                     psseguro || '-' || ptablas, 'Error: ' || SQLERRM);
         RETURN 0;
   END f_segprima_corr;

   -- BUG25924:DRA:04/03/2013:Fi
   FUNCTION f_calcular_comision_corretaje(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pfefecto IN DATE,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pcactivi IN NUMBER,
      pcagente IN NUMBER,
      ptablas IN VARCHAR2,
      ppartici IN NUMBER,
      ppcomisi OUT NUMBER,
      ppretenc OUT NUMBER)
      RETURN NUMBER IS
      --
      v_pasexec      NUMBER(8) := 0;
      v_param        VARCHAR2(500)
         := 'psseguro: ' || psseguro || ', pnriesgo: ' || pnriesgo || ', pnmovimi: '
            || pnmovimi || ', pcagente: ' || pcagente || ', ptablas: ' || ptablas
            || ', pfefecto: ' || pfefecto || ', pcramo: ' || pcramo || ', pcmodali: '
            || pcmodali || ', pctipseg: ' || pctipseg || ', pccolect: ' || pccolect
            || ', pcactivi: ' || pcactivi || ', ppartici: ' || ppartici;
      v_object       VARCHAR2(200) := 'PAC_CORRETAJE.f_calcular_comision_corretaje';
      v_numerr       NUMBER := 0;
      v_cmodcom      comisionprod.cmodcom%TYPE;
      v_funcion      VARCHAR2(3);
      v_pcomisi      NUMBER;
      v_pretenc      NUMBER;
      v_ipriseg      NUMBER := 0;
      v_ipricom      NUMBER := 0;

      CURSOR c_rie IS
         SELECT nriesgo
           FROM estriesgos
          WHERE sseguro = psseguro
            AND(nriesgo = pnriesgo
                OR pnriesgo IS NULL)
            AND NVL(ptablas, 'POL') = 'EST'
         UNION ALL
         SELECT nriesgo
           FROM riesgos
          WHERE sseguro = psseguro
            AND(nriesgo = pnriesgo
                OR pnriesgo IS NULL)
            AND NVL(ptablas, 'POL') <> 'EST';

      CURSOR c_gar(pc_nriesgo IN NUMBER) IS
         SELECT g.cgarant, g.iprianu
           FROM estgaranseg g
          WHERE g.sseguro = psseguro
            AND g.nriesgo = pc_nriesgo
            AND g.nmovimi = (SELECT MAX(g1.nmovimi)
                               FROM garanseg g1
                              WHERE g1.sseguro = g.sseguro
                                AND g1.nriesgo = g.nriesgo)
            AND g.cobliga = 1
            AND NVL(ptablas, 'POL') = 'EST'
         UNION ALL
         SELECT g.cgarant, g.iprianu
           FROM garanseg g
          WHERE g.sseguro = psseguro
            AND g.nriesgo = pc_nriesgo
            AND g.nmovimi = (SELECT MAX(g1.nmovimi)
                               FROM garanseg g1
                              WHERE g1.sseguro = g.sseguro
                                AND g1.nriesgo = g.nriesgo)
            AND NVL(ptablas, 'POL') <> 'EST';
   BEGIN
      v_pasexec := 1;

      IF f_es_renovacion(psseguro) = 0 THEN   -- es cartera
         v_cmodcom := 2;
      ELSE   -- si es 1 es nueva produccion
         v_cmodcom := 1;
      END IF;

      v_pasexec := 3;

      IF ptablas = 'EST' THEN
         v_funcion := 'TAR';
      ELSE
         v_funcion := 'CAR';
      END IF;

      v_pasexec := 4;
      v_ipriseg := pac_corretaje.f_segprima_corr(psseguro, ptablas);
      v_pasexec := 5;

      FOR rie IN c_rie LOOP
         FOR gar IN c_gar(rie.nriesgo) LOOP
            v_pasexec := 6;
            v_numerr := f_pcomisi(psseguro, v_cmodcom, pfefecto, v_pcomisi, ppretenc,
                                  pcagente, pcramo, pcmodali, pctipseg, pccolect, pcactivi,
                                  gar.cgarant, ptablas, v_funcion, pfefecto);

            IF v_numerr <> 0 THEN
               p_tab_error(f_sysdate, f_user, v_object, v_pasexec,
                           psseguro || '-' || v_cmodcom || '-' || pfefecto || '-' || v_pcomisi
                           || '-' || ppretenc || '-' || pcagente || '-' || pcramo || '-'
                           || pcmodali || '-' || pctipseg || '-' || pccolect || '-'
                           || pcactivi || '-' || gar.cgarant || '-' || ptablas || '-'
                           || v_funcion || '-' || pfefecto,
                           'num_err=' || v_numerr || ' --> Error: '
                           || f_axis_literales(v_numerr));
               RETURN 9000503;
            END IF;

            v_pasexec := 7;
            v_ipricom := v_ipricom +(NVL(gar.iprianu, 0) *(ppartici / 100) *(v_pcomisi / 100));
         END LOOP;
      END LOOP;

      v_pasexec := 8;

      IF NVL(ppartici, 0) = 0 THEN
         ppcomisi := 0;
      ELSE
         BEGIN
            ppcomisi := ROUND((v_ipricom /(v_ipriseg *(ppartici / 100))) * 100, 2);
         EXCEPTION
            WHEN OTHERS THEN
               ppcomisi := NULL;
         END;
      END IF;

      RETURN v_numerr;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param,
                     'num_err=' || v_numerr || ' --> Error: ' || SQLERRM);
         RETURN 9000503;
   END f_calcular_comision_corretaje;

   FUNCTION f_gen_comision_corr(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnrecibo IN NUMBER,
      psigno IN NUMBER DEFAULT 1)
      RETURN NUMBER IS
      --
      v_pasexec      NUMBER(8) := 0;
      v_param        VARCHAR2(500)
         := 'psseguro: ' || psseguro || ', pnmovimi: ' || pnmovimi || ', pnrecibo: '
            || pnrecibo;
      v_object       VARCHAR2(200) := 'PAC_CORRETAJE.f_gen_comision_corr';
      v_numerr       NUMBER := 0;
      v_cestrec      movrecibo.cestrec%TYPE;
      v_fmovdia      DATE;
      iconcep0       detrecibos.iconcep%TYPE;
      iconcep21      detrecibos.iconcep%TYPE;
      v_icombru      detrecibos.iconcep%TYPE;
      v_icomret      detrecibos.iconcep%TYPE;
      v_icomdev      detrecibos.iconcep%TYPE;
      v_iretdev      detrecibos.iconcep%TYPE;
      v_cmodcom      comisionprod.cmodcom%TYPE;
      vcrespue       pregunpolseg.crespue%TYPE;
      porcagente     NUMBER;
      porragente     NUMBER;
      pcomisagente   NUMBER;
      pretenagente   NUMBER;
      v_fefectovig   DATE;
      xpcomcoa       NUMBER;
      xccalcom       NUMBER;
      xploccoa       NUMBER;   -- COASEGURO
      comis_calc     NUMBER;
      reten_calc     NUMBER;
      v_signo        NUMBER;
      error_proc     EXCEPTION;

      CURSOR c_recibo IS
         SELECT r.nrecibo, r.sseguro, r.fefecto fefecto_rec, s.sproduc, s.cramo, s.cmodali,
                s.ctipseg, s.ccolect, s.cactivi, s.ctipcoa, s.ncuacoa, s.fefecto fefecto_seg,
                pac_monedas.f_moneda_producto(s.sproduc) moneda, r.ctiprec
           FROM recibos r, seguros s
          WHERE s.sseguro = psseguro
            AND r.sseguro = s.sseguro
            AND r.nmovimi = pnmovimi
            AND pnrecibo IS NULL
         UNION
         SELECT r.nrecibo, r.sseguro, r.fefecto fefecto_rec, s.sproduc, s.cramo, s.cmodali,
                s.ctipseg, s.ccolect, s.cactivi, s.ctipcoa, s.ncuacoa, s.fefecto fefecto_seg,
                pac_monedas.f_moneda_producto(s.sproduc) moneda, r.ctiprec
           FROM recibos r, seguros s
          WHERE r.nrecibo = pnrecibo
            AND s.sseguro = r.sseguro
            AND pnrecibo IS NOT NULL;

      CURSOR c_corret(pc_sseguro IN NUMBER, pc_nmovimi IN NUMBER) IS
         SELECT c.cagente, c.nmovimi, c.nordage, c.pcomisi, c.ppartici, c.islider
           FROM age_corretaje c
          WHERE c.sseguro = pc_sseguro
            AND(c.nmovimi = pc_nmovimi
                OR(pc_nmovimi IS NULL
                   AND c.nmovimi = (SELECT MAX(m.nmovimi)
                                      FROM age_corretaje m
                                     WHERE m.sseguro = c.sseguro)));

      CURSOR cur_detrecibos(pc_nrecibo IN NUMBER) IS
         SELECT   nriesgo, cgarant, cageven   --, nmovima
             FROM detrecibos
            WHERE nrecibo = pc_nrecibo
         GROUP BY nriesgo, cgarant, cageven;   --, nmovima;
   BEGIN
      v_pasexec := 1;

      FOR rec IN c_recibo LOOP
         IF rec.ctiprec = 9 THEN
            v_signo := -1 * psigno;
         ELSE
            v_signo := 1 * psigno;
         END IF;

         v_pasexec := 2;

         SELECT m.cestrec, m.fmovdia
           INTO v_cestrec, v_fmovdia
           FROM movrecibo m
          WHERE m.nrecibo = rec.nrecibo
            AND m.smovrec = (SELECT MAX(m1.smovrec)
                               FROM movrecibo m1
                              WHERE m1.nrecibo = m.nrecibo);

         -- BUG22402:DRA:10/07/2012:Inici
         v_pasexec := 8;

         IF rec.ctipcoa <> 0 THEN
            SELECT ploccoa
              INTO xploccoa
              FROM coacuadro
             WHERE ncuacoa = rec.ncuacoa
               AND sseguro = rec.sseguro;
         END IF;

         v_pasexec := 9;

         --COASEGURO ACEPTADO NO NOS INTERESA APLICAR DOS VECES EL PORCENTAJE LOCAL
         IF rec.ctipcoa = 8
            OR rec.ctipcoa = 9 THEN
            xploccoa := 100;
         END IF;

         v_pasexec := 10;

         BEGIN
            SELECT p.ccalcom
              INTO xccalcom
              FROM productos p
             WHERE p.sproduc = rec.sproduc;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_numerr := 104347;   -- Producte no trobat a PRODUCTOS
               RAISE error_proc;
            WHEN OTHERS THEN
               v_numerr := 102705;   -- Error al llegir de PRODUCTOS
               RAISE error_proc;
         END;

         v_pasexec := 101;

         IF NVL(pac_parametros.f_parproducto_t(rec.sproduc, 'FVIG_COMISION'), 'FEFECTO_REC') =
                                                                                  'FEFECTO_REC' THEN
            v_fefectovig := rec.fefecto_rec;   --Efecto del recibo
         ELSIF pac_parametros.f_parproducto_t(rec.sproduc, 'FVIG_COMISION') = 'FEFECTO_POL' THEN   --Efecto de la póliza
            v_pasexec := 102;
            v_numerr := pac_preguntas.f_get_pregunpolseg(rec.sseguro, 4046, 'SEG', vcrespue);

            IF v_numerr NOT IN(0, 120135) THEN
               RETURN v_numerr;
            ELSE
               v_numerr := 0;
               v_fefectovig := NVL(TO_DATE(vcrespue, 'YYYYMMDD'), rec.fefecto_seg);
            END IF;
         ELSIF pac_parametros.f_parproducto_t(rec.sproduc, 'FVIG_COMISION') = 'FEFECTO_RENOVA' THEN   -- efecto a la renovacion
            v_fefectovig := TO_DATE(frenovacion(NULL, rec.sseguro, 2), 'yyyymmdd');
         END IF;

         -- BUG22402:DRA:10/07/2012:Fi
         FOR detrec IN cur_detrecibos(rec.nrecibo) LOOP
            iconcep0 := 0;
            iconcep21 := 0;
            v_pasexec := 11;

            BEGIN
               SELECT   NVL(SUM(iconcep), 0)
                   INTO iconcep0
                   FROM detrecibos
                  WHERE nrecibo = rec.nrecibo
                    AND nriesgo = detrec.nriesgo
                    AND cgarant = detrec.cgarant
                    --AND nmovima = detrec.nmovima
                    AND cconcep IN(0, 50)   -- LOCAL + CEDIDA
               GROUP BY nriesgo, cgarant;
            EXCEPTION
               WHEN OTHERS THEN
                  iconcep0 := 0;
            END;

            v_pasexec := 12;

            BEGIN
               SELECT   NVL(SUM(iconcep), 0)
                   INTO iconcep21
                   FROM detrecibos
                  WHERE nrecibo = rec.nrecibo
                    AND nriesgo = detrec.nriesgo
                    AND cgarant = detrec.cgarant
                    --AND nmovima = detrec.nmovima
                    AND cconcep IN(21, 71)   -- LOCAL + CEDIDA
               GROUP BY nriesgo, cgarant;
            EXCEPTION
               WHEN OTHERS THEN
                  iconcep21 := 0;
            END;

            v_pasexec := 17;

            FOR r_corret IN c_corret(rec.sseguro, NULL) LOOP
               v_pasexec := 18;

               IF f_es_renovacion(rec.sseguro) = 0 THEN   -- es cartera
                  v_cmodcom := 2;
               ELSE   -- si es 1 es nueva produccion
                  v_cmodcom := 1;
               END IF;

               v_pasexec := 181;
               v_numerr := f_pcomisi(rec.sseguro, v_cmodcom, v_fefectovig, pcomisagente,
                                     pretenagente, r_corret.cagente, rec.cramo, rec.cmodali,
                                     rec.ctipseg, rec.ccolect, rec.cactivi, detrec.cgarant,
                                     'POL', 'CAR', v_fefectovig);

               IF v_numerr <> 0 THEN
                  RAISE error_proc;
               END IF;

               v_pasexec := 19;

               IF rec.ctipcoa = 8
                  OR rec.ctipcoa = 9 THEN
                  BEGIN
                     v_pasexec := 20;

                     SELECT pcomcoa
                       INTO xpcomcoa
                       FROM coacedido
                      WHERE sseguro = rec.sseguro
                        AND ncuacoa = rec.ncuacoa;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN   -- 23183 AVT 31/10/2012
                        porcagente := pcomisagente;
                        porragente := pretenagente;
                     WHEN OTHERS THEN
                        v_numerr := 105582;   -- ERROR AL LEER DE LA TABLA COACEDIDO
                        RAISE error_proc;
                  END;

                  v_pasexec := 21;

                  IF xpcomcoa IS NULL THEN
                     porcagente := pcomisagente;
                     porragente := pretenagente;
                  ELSE
                     porcagente := 0;
                     porragente := 0;
                  END IF;
               ELSE
                  v_pasexec := 22;
                  porcagente := pcomisagente;
                  porragente := pretenagente;
               END IF;

               --CALCUL COMISIONS I RETENCIONS (MODE 'R': REAL)
               IF xccalcom = 1 THEN   -- Sobre prima
                  v_pasexec := 23;
                  v_numerr := f_pcomisi(rec.sseguro, v_cmodcom, v_fefectovig, pcomisagente,
                                        pretenagente, r_corret.cagente, rec.cramo,
                                        rec.cmodali, rec.ctipseg, rec.ccolect, rec.cactivi,
                                        detrec.cgarant, 'POL', 'CAR', v_fefectovig);

                  IF v_numerr <> 0 THEN
                     RAISE error_proc;
                  END IF;
               END IF;

               v_pasexec := 24;
               comis_calc := f_round((NVL(iconcep0, 0) * r_corret.ppartici / 100) * porcagente
                                     / 100,
                                     rec.moneda);
               v_icombru := comis_calc;

               IF NVL(comis_calc, 0) <> 0
                  AND NVL(porcagente, 0) <> 0 THEN
                  v_pasexec := 25;
                  reten_calc := f_round(((comis_calc * porragente) / 100), rec.moneda);
                  v_icomret := reten_calc;
               END IF;

               --CALCUL COMISIO I RETENCIO DEVENGADES(CCONCEP = 15 I 16)(MODE 'R' : REAL)
               v_pasexec := 28;
               comis_calc := f_round((NVL(iconcep21, 0) * r_corret.ppartici / 100) * porcagente
                                     / 100,
                                     rec.moneda);
               v_icomdev := comis_calc;

               IF NVL(comis_calc, 0) <> 0
                  AND NVL(porcagente, 0) <> 0 THEN
                  --INSERTEM LA COMISIO DEVENGADA
                  v_pasexec := 30;
                  reten_calc := f_round(((comis_calc * porragente) / 100), rec.moneda);
                  v_iretdev := reten_calc;
               END IF;

               v_pasexec := 32;
               v_numerr := pac_comisiones.f_alt_comisionrec(rec.nrecibo, v_cestrec, v_fmovdia,
                                                            v_icombru * v_signo,
                                                            v_icomret * v_signo,
                                                            v_icomdev * v_signo,
                                                            v_iretdev * v_signo,
                                                            r_corret.cagente, detrec.cgarant);

               IF v_numerr <> 0 THEN
                  RAISE error_proc;
               END IF;
            END LOOP;
         END LOOP;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN error_proc THEN
         -- BUG -21546_108724 - 04/02/2012 - JLTS - Cierre de cursores
         IF cur_detrecibos%ISOPEN THEN
            CLOSE cur_detrecibos;
         END IF;

         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_numerr,
                     f_axis_literales(v_numerr, f_usu_idioma));
         RETURN v_numerr;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param,
                     'num_err=' || v_numerr || ' --> Error: ' || SQLERRM);
         RETURN 140999;
   END f_gen_comision_corr;

-- BUG24782:DCG:29/11/2012:Inici
   FUNCTION f_impcor_agente(
      pimporte IN NUMBER,
      pcagente IN NUMBER,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER)
      RETURN NUMBER IS
      --
      v_pasexec      NUMBER(8) := 0;
      v_param        VARCHAR2(500)
         := 'pimporte: ' || pimporte || ', pcagente: ' || pcagente || ', psseguro: '
            || psseguro || ', pnmovimi: ' || pnmovimi;
      v_object       VARCHAR2(200) := 'PAC_CORRETAJE.f_impcor_agente';
      v_numerr       NUMBER := 0;
      v_importe      NUMBER;
      v_cagente      NUMBER;
      v_sseguro      NUMBER;
      v_nmovimi      NUMBER;
      v_dummy        NUMBER;
      v_impaux       NUMBER;
      v_implider     NUMBER;
      v_impnolider   NUMBER;
      v_monedinst    NUMBER;

      CURSOR c_correyaje IS
         SELECT cagente, ppartici, islider
           FROM age_corretaje a
          WHERE a.sseguro = psseguro
            --AND(a.cagente = pcagente
            --    OR pcagente IS NULL)
            AND a.nmovimi = (SELECT MAX(nmovimi)
                               FROM age_corretaje ac2
                              WHERE ac2.sseguro = a.sseguro
                                --AND(ac2.cagente = pcagente
                                --    OR pcagente IS NULL)
                                AND ac2.nmovimi <= pnmovimi);
   BEGIN
      v_monedinst := pac_parametros.f_parinstalacion_n('MONEDAINST');

      SELECT COUNT('1')
        INTO v_dummy
        FROM age_corretaje a
       WHERE a.sseguro = psseguro
         AND nmovimi <= pnmovimi;   --rdd 04/04/2014

      IF v_dummy = 0 THEN
         RETURN f_round(pimporte, v_monedinst);
      ELSE
         --v_monedinst := pac_parametros.f_parinstalacion_n('MONEDAINST'); RDD BUG 25864 - 8/02/2013 SUBIRLO Y HACER F_ROUND A EL IMPORTE EN CASO V_DUMMY = 0
         FOR cor IN c_correyaje LOOP
            v_impaux := NVL(v_impaux, 0)
                        + f_round((pimporte * cor.ppartici / 100), v_monedinst);

            IF cor.islider = 1
               AND pcagente = cor.cagente THEN
               --v_implider := f_round((pimporte * cor.ppartici / 100), v_implider); --RDD 18/02/2013 (-)
               v_implider := f_round((pimporte * cor.ppartici / 100), v_monedinst);   --RDD 18/02/2013 (+)
            ELSIF pcagente = cor.cagente THEN
               v_impnolider := f_round((pimporte * cor.ppartici / 100), v_monedinst);
            END IF;
         END LOOP;

         IF v_implider IS NOT NULL THEN
            v_implider := (f_round(pimporte, v_monedinst) - v_impaux) + v_implider;
            RETURN v_implider;
         ELSE
            RETURN v_impnolider;
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param,
                     'num_err=' || v_numerr || ' --> Error: ' || SQLERRM);
         RETURN 0;   -- Bug 25831 - APD - 23/01/2013 - si hay error la funcion debe devolver 0
   END f_impcor_agente;

   -- BUG24782:DCG:29/11/2012:Fi

   -- BUG26036:DRA:12/02/2013:Inici
   FUNCTION ff_comis_corretaje(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pfefecto IN DATE,
      pcagente IN NUMBER,
      ppartici IN NUMBER,
      ptablas IN VARCHAR2)
      RETURN NUMBER IS
      --
      v_pasexec      NUMBER(8) := 0;
      v_param        VARCHAR2(500)
         := 'psseguro: ' || psseguro || ', pnriesgo: ' || pnriesgo || ', pnmovimi: '
            || pnmovimi || ', pcagente: ' || pcagente || ', ptablas: ' || ptablas
            || ', pfefecto: ' || pfefecto || ', ppartici: ' || ppartici;
      v_object       VARCHAR2(200) := 'PAC_CORRETAJE.ff_comis_corretaje';
      v_numerr       NUMBER := 0;
      v_pcomisi      NUMBER;
      v_pretenc      NUMBER;
      v_cramo        NUMBER;
      v_cmodali      NUMBER;
      v_ctipseg      NUMBER;
      v_ccolect      NUMBER;
      v_cactivi      NUMBER;
      v_cidioma      NUMBER;
   BEGIN
      v_pasexec := 1;

      IF ptablas = 'EST' THEN
         SELECT cramo, cmodali, ctipseg, ccolect, cactivi, cidioma
           INTO v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_cactivi, v_cidioma
           FROM estseguros
          WHERE sseguro = psseguro;
      ELSE
         SELECT cramo, cmodali, ctipseg, ccolect, cactivi, cidioma
           INTO v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_cactivi, v_cidioma
           FROM seguros
          WHERE sseguro = psseguro;
      END IF;

      v_pasexec := 2;
      v_numerr := pac_corretaje.f_calcular_comision_corretaje(psseguro, pnriesgo, pnmovimi,
                                                              pfefecto, v_cramo, v_cmodali,
                                                              v_ctipseg, v_ccolect, v_cactivi,
                                                              pcagente, ptablas, ppartici,
                                                              v_pcomisi, v_pretenc);
      v_pasexec := 3;

      IF v_numerr <> 0 THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param,
                     'num_err=' || v_numerr || ' --> Error: '
                     || f_axis_literales(v_numerr, v_cidioma));
         RETURN NULL;
      END IF;

      RETURN v_pcomisi;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param,
                     'num_err=' || v_numerr || ' --> Error: ' || SQLERRM);
         RETURN NULL;
   END ff_comis_corretaje;

-- BUG26036:DRA:12/02/2013:Fi

   -- BUG25924:DRA:04/03/2013:Inici
   FUNCTION f_calcular_liqcom_corretaje(
      pnrecibo IN NUMBER,
      pfefecto IN DATE,
      pcagente IN NUMBER,
      ppcomisi OUT NUMBER,
      ppretenc OUT NUMBER)
      RETURN NUMBER IS
      --
      v_pasexec      NUMBER(8) := 0;
      v_param        VARCHAR2(500)
         := 'pnrecibo: ' || pnrecibo || ', pcagente: ' || pcagente || ', pfefecto: '
            || pfefecto;
      v_object       VARCHAR2(200) := 'PAC_CORRETAJE.f_calcular_liqcom_corretaje';
      v_numerr       NUMBER := 0;
      v_cmodcom      comisionprod.cmodcom%TYPE;
      v_funcion      VARCHAR2(3);
      v_pcomisi      NUMBER;
      v_pretenc      NUMBER;
      v_ipriseg      NUMBER := 0;
      v_ipricom      NUMBER := 0;
      v_ppartici     NUMBER;
      v_pcomisi_tot  NUMBER := 0;
      v_pcomisi_par  NUMBER := 0;
      v_pretenc_tot  NUMBER := 0;
      v_cont         NUMBER := 0;
      e_error        EXCEPTION;

      CURSOR c_rec IS
         SELECT r.nrecibo, r.sseguro, s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.cactivi
           FROM recibos r, seguros s
          WHERE r.nrecibo = pnrecibo
            AND s.sseguro = r.sseguro
            AND r.cestaux = 0
            AND NOT EXISTS(SELECT 1
                             FROM adm_recunif ar
                            WHERE ar.nrecunif = r.nrecibo)
         UNION ALL
         SELECT DISTINCT r.nrecibo, r.sseguro, s.cramo, s.cmodali, s.ctipseg, s.ccolect,
                         s.cactivi
                    FROM adm_recunif ar, recibos r, seguros s
                   WHERE ar.nrecunif = pnrecibo
                     AND r.nrecibo = ar.nrecunif
                     AND r.cestaux = 0
                     AND r.sseguro = s.sseguro;

         /* JLV 06/05/2013 Bug 26276/143415
         SELECT r.nrecibo, r.sseguro, s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.cactivi
           FROM adm_recunif ar, recibos r, seguros s, recibos r2
          WHERE ar.nrecunif = pnrecibo
            AND r.nrecibo = ar.nrecibo
            AND s.sseguro = r.sseguro
            AND r2.nrecibo = ar.nrecunif
            AND r2.cestaux = 0;
      /* JLV 30/04/2013 Bug 26276/143415
      SELECT r.nrecibo, r.sseguro, s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.cactivi
        FROM adm_recunif ar, recibos r, seguros s
       WHERE ar.nrecunif = pnrecibo
         AND r.nrecibo = ar.nrecibo
         AND s.sseguro = r.sseguro
         AND((pac_seguros.f_es_col_admin(s.sseguro) = 1
              AND s.ncertif <> 0)
             OR pac_seguros.f_es_col_admin(s.sseguro) = 0);*/
      CURSOR c_rie(pc_sseguro IN NUMBER) IS
         SELECT nriesgo
           FROM riesgos
          WHERE sseguro = pc_sseguro;

      CURSOR c_gar(pc_sseguro IN NUMBER, pc_nriesgo IN NUMBER) IS
         SELECT g.cgarant, g.iprianu
           FROM garanseg g
          WHERE g.sseguro = pc_sseguro
            AND g.nriesgo = pc_nriesgo
            AND g.nmovimi = (SELECT MAX(g1.nmovimi)
                               FROM garanseg g1
                              WHERE g1.sseguro = g.sseguro
                                AND g1.nriesgo = g.nriesgo);
   BEGIN
      v_pasexec := 1;

      FOR r_rec IN c_rec LOOP
         v_pasexec := 2;

         BEGIN
            SELECT c.ppartici
              INTO v_ppartici
              FROM age_corretaje c
             WHERE c.sseguro = r_rec.sseguro
               AND c.cagente = pcagente
               AND c.nmovimi = (SELECT MAX(c1.nmovimi)
                                  FROM age_corretaje c1
                                 WHERE c1.sseguro = c.sseguro);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
               v_numerr := 100933;   -- Comissió inexistent
               RAISE e_error;
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
               v_numerr := 9902412;   -- Error al llegir la taula AGE_CORRETAJE
               RAISE e_error;
         END;

         IF f_es_renovacion(r_rec.sseguro) = 0 THEN   -- es cartera
            v_cmodcom := 2;
         ELSE   -- si es 1 es nueva produccion
            v_cmodcom := 1;
         END IF;

         v_pasexec := 3;
         v_funcion := 'CAR';   -- IF ptablas = 'EST'  v_funcion := 'TAR';
         v_pasexec := 4;
         v_ipriseg := f_segprima_corr(r_rec.sseguro);
         v_ipricom := 0;   --Bug 26276 Inicializa el valor de la variable sino acumula
         v_pasexec := 5;

         FOR rie IN c_rie(r_rec.sseguro) LOOP
            FOR gar IN c_gar(r_rec.sseguro, rie.nriesgo) LOOP
               v_pasexec := 6;
               v_numerr := f_pcomisi(r_rec.sseguro, v_cmodcom, pfefecto, v_pcomisi, v_pretenc,
                                     pcagente, r_rec.cramo, r_rec.cmodali, r_rec.ctipseg,
                                     r_rec.ccolect, r_rec.cactivi, gar.cgarant, NULL,
                                     v_funcion, pfefecto);

               IF v_numerr <> 0 THEN
                  p_tab_error(f_sysdate, f_user, v_object, v_pasexec,
                              r_rec.sseguro || '-' || v_cmodcom || '-' || pfefecto || '-'
                              || v_pcomisi || '-' || v_pretenc || '-' || pcagente || '-'
                              || r_rec.cramo || '-' || r_rec.cmodali || '-' || r_rec.ctipseg
                              || '-' || r_rec.ccolect || '-' || r_rec.cactivi || '-'
                              || gar.cgarant || '-' || v_funcion || '-' || pfefecto,
                              'num_err=' || v_numerr || ' --> Error: '
                              || f_axis_literales(v_numerr));
                  RETURN 9000503;
               END IF;

               v_pasexec := 7;
               v_ipricom := v_ipricom
                            +(NVL(gar.iprianu, 0) *(v_ppartici / 100) *(v_pcomisi / 100));
            END LOOP;
         END LOOP;

         v_pasexec := 8;

         IF NVL(v_ppartici, 0) = 0 THEN
            v_pcomisi_par := 0;
         ELSE
            BEGIN
               v_pcomisi_par := ROUND((v_ipricom /(v_ipriseg *(v_ppartici / 100))) * 100, 2);
            EXCEPTION
               WHEN OTHERS THEN
                  v_pcomisi_par := 0;
            END;
         END IF;

         v_cont := v_cont + 1;
         v_pcomisi_tot := v_pcomisi_tot + NVL(v_pcomisi_par, 0);
         v_pretenc_tot := v_pretenc_tot + NVL(v_pretenc, 0);
      END LOOP;

      ppcomisi := ROUND(v_pcomisi_tot / v_cont, 2);
      ppretenc := ROUND(v_pretenc_tot / v_cont, 2);
      RETURN v_numerr;
   EXCEPTION
      WHEN e_error THEN
         ppcomisi := 0;
         ppretenc := 0;
         RETURN v_numerr;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param,
                     'num_err=' || v_numerr || ' --> Error: ' || SQLERRM);
         RETURN 9000503;
   END f_calcular_liqcom_corretaje;

-- BUG25924:DRA:04/03/2013:Fi

   -- BUG 0026253 - 04/03/2013 - FAL
   FUNCTION f_esagelider(psseguro IN NUMBER, pnmovimi IN NUMBER, pcagente IN NUMBER)
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 0;
      v_param        VARCHAR2(500)
         := 'psseguro: ' || psseguro || ', pnmovimi: ' || pnmovimi || ', pcagente: '
            || pcagente;
      v_object       VARCHAR2(200) := 'PAC_CORRETAJE.f_esagelider';
      v_agelider     NUMBER;
   BEGIN
      IF pac_corretaje.f_tiene_corretaje(psseguro) = 1 THEN
         BEGIN
            SELECT c.islider
              INTO v_agelider
              FROM age_corretaje c
             WHERE c.sseguro = psseguro
               AND c.nmovimi = (SELECT MAX(nmovimi)
                                  FROM age_corretaje d
                                 WHERE d.sseguro = psseguro
                                   AND(d.cagente = pcagente
                                       OR d.cagente =
                                            (SELECT b.cagente
                                               FROM agentes_agente_pol a, redcomercial b
                                              WHERE a.cagente = pcagente
                                                AND b.cpadre = pcagente
                                                AND b.cagente = d.cagente
                                                AND b.fmovfin IS NULL)))
               AND(c.cagente = pcagente
                   OR c.cagente = (SELECT b.cagente
                                     FROM agentes_agente_pol a, redcomercial b
                                    WHERE a.cagente = pcagente
                                      AND b.cpadre = pcagente
                                      AND b.cagente = c.cagente
                                      AND b.fmovfin IS NULL));

            IF v_agelider = 1 THEN
               RETURN 0;
            ELSIF v_agelider = 0 THEN
               RETURN 1;
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN 0;   -- agente no está en el corretaje
            WHEN TOO_MANY_ROWS THEN   -- 19. JLV - Qt. 9601
               RETURN 0;
         END;
      ELSE
         RETURN 0;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, 'Error: ' || SQLERRM);
         RETURN NULL;
   END f_esagelider;

-- FI BUG 0026253

   -- BUG24866:DCG:18/03/2013:Inici
   FUNCTION f_impcorcomi_agente(
      pimporte IN NUMBER,
      pcagente IN NUMBER,
      pnrecibo IN NUMBER,
      pcestrec IN NUMBER,
      pcgarant IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      --
      v_pasexec      NUMBER(8) := 0;
      v_param        VARCHAR2(500)
         := 'pimporte: ' || pimporte || ', pcagente: ' || pcagente || ', pnrecibo: '
            || pnrecibo || ', pcestrec: ' || pcestrec || ', pcgarant: ' || pcgarant;
      v_object       VARCHAR2(200) := 'PAC_CORRETAJE.f_impcorcomi_agente';
      v_numerr       NUMBER := 0;
      v_impcom       NUMBER;
      v_dummy        NUMBER;
      v_monedinst    NUMBER;
      v_imptot       NUMBER;
      v_nnumcom      NUMBER;
      v_impcalctot   NUMBER := 0;
      v_ultnumcom    NUMBER := 0;
      v_cestrec      NUMBER;
      vmovimiento    NUMBER;
      vsseguro       NUMBER;

      CURSOR c_comcorretaje(pc_cestrec NUMBER) IS
         --SELECT   cagente, SUM(ABS(icombru)) icombru, SUM(ABS(icombru_moncia)) icombru_moncia
         SELECT   cagente, SUM(icombru) icombru, SUM(icombru_moncia) icombru_moncia
             FROM comrecibo c
            WHERE c.nrecibo = pnrecibo
              AND c.cestrec = pc_cestrec
              AND c.cagente = pcagente
              AND(pcgarant IS NULL
                  OR c.cgarant = pcgarant)
         GROUP BY cagente;
   BEGIN
      v_monedinst := pac_parametros.f_parinstalacion_n('MONEDAINST');
      v_cestrec := pcestrec;
      v_cestrec := 0;

      --Bug 28381  27/09/2013  si la póliza tiene co-corretaje
      SELECT nmovimi, sseguro
        INTO vmovimiento, vsseguro
        FROM recibos
       WHERE nrecibo = pnrecibo;

      SELECT COUNT('1')
        INTO v_dummy
        FROM age_corretaje ac
       WHERE ac.sseguro = vsseguro
         AND ac.nmovimi = (SELECT MAX(nmovimi)
                             FROM age_corretaje ac2
                            WHERE ac2.sseguro = vsseguro
                              AND ac2.nmovimi <= vmovimiento);

      IF v_dummy <= 1 THEN   -- Fin bug 28381
         RETURN f_round(pimporte, v_monedinst);
      ELSE
         v_impcom := 0;

         FOR com IN c_comcorretaje(v_cestrec) LOOP
            --SELECT SUM(NVL(ABS(icombru_moncia), ABS(icombru))), MAX(nnumcom)
            SELECT SUM(NVL(icombru_moncia, icombru)), MAX(nnumcom)
              INTO v_imptot, v_nnumcom
              FROM comrecibo c
             WHERE c.nrecibo = pnrecibo
               AND c.cestrec = v_cestrec
               AND(pcgarant IS NULL
                   OR c.cgarant = pcgarant);

            SELECT MAX(nnumcom)
              INTO v_ultnumcom
              FROM comrecibo c
             WHERE c.nrecibo = pnrecibo
               AND c.cestrec = v_cestrec
               AND(pcgarant IS NULL
                   OR c.cgarant = pcgarant)
               AND c.cagente = com.cagente;

            --v_impcom := f_round((ABS(pimporte) *(NVL(com.icombru_moncia, com.icombru))

            --JLV 01/07/2014 división por 0
            IF v_imptot = 0 THEN
               v_impcom := 0;
            ELSE
               v_impcom := f_round((pimporte *(NVL(com.icombru_moncia, com.icombru)) / v_imptot),
                                   v_monedinst);
            END IF;

            IF v_ultnumcom = v_nnumcom THEN   --Último agente le añado los centimos de diferencia
               --FOR rc2 IN (SELECT cagente, ABS(icombru) icombru,
               FOR rc2 IN (SELECT cagente, icombru,
                                                   --ABS(icombru_moncia) icombru_moncia, cgarant, nnumcom
                                                   icombru_moncia, cgarant, nnumcom
                             FROM comrecibo c
                            WHERE c.nrecibo = pnrecibo
                              AND c.cestrec = v_cestrec
                              AND(pcgarant IS NULL
                                  OR c.cgarant = pcgarant)) LOOP
                  IF v_imptot <> 0 THEN
                     v_impcalctot := NVL(v_impcalctot, 0)
                                     --+(ABS(pimporte) *(NVL(rc2.icombru_moncia, rc2.icombru))
                                     +(pimporte *(NVL(rc2.icombru_moncia, rc2.icombru))
                                       / v_imptot);
                  END IF;
               END LOOP;

               --v_impcom := v_impcom + f_round(v_impcalctot, v_monedinst) - ABS(pimporte);
               v_impcom := v_impcom + f_round(v_impcalctot, v_monedinst) - pimporte;
            END IF;
         END LOOP;

         --RETURN ABS(v_impcom);   --devolvemos el valor absoluto del importe calculado
         RETURN v_impcom;   --devolvemos el valor absoluto del importe calculado
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param,
                     'num_err=' || v_numerr || ' --> Error: ' || SQLERRM);
         RETURN 0;
   END f_impcorcomi_agente;

-- BUG24866:DCG:18/03/2013:Fi

   --INICIO BUG 27048 - DCT - 08/07/2013
   FUNCTION f_update_age_corretaje(psseguro IN NUMBER)
      RETURN NUMBER IS
      v_nmovimi      NUMBER;
      v_cagente      NUMBER;
      v_cagente2     NUMBER;
      -- 28479/0166457
      v_cuenta       NUMBER;
   BEGIN
      SELECT MAX(nmovimi)
        INTO v_nmovimi
        FROM movseguro
       WHERE sseguro = psseguro;

      IF f_tiene_corretaje(psseguro, v_nmovimi) = 1 THEN
         --Agente que cambiaremos
         SELECT cagente
           INTO v_cagente
           FROM age_corretaje
          WHERE sseguro = psseguro
            AND nmovimi = v_nmovimi
            AND islider = 1;

         --Agente que debemos poner cómo cambio
         SELECT cagente
           INTO v_cagente2
           FROM seguros
          WHERE sseguro = psseguro;

-- 28479/0166457 - INI
         SELECT COUNT(1)
           INTO v_cuenta
           FROM age_corretaje
          WHERE sseguro = psseguro
            AND cagente = v_cagente2
            AND nmovimi = v_nmovimi;

/*
 BEGIN
               UPDATE age_corretaje
                  SET cagente = v_cagente2
                WHERE sseguro = psseguro
                  AND cagente = v_cagente
                  AND nmovimi = v_nmovimi;
            EXCEPTION
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user, 'pac_corretaje.f_update_age_corretaje', 1,
                              'psseguro = ' || psseguro || ' v_nnmovimi = ' || v_nmovimi
                              || 'v_cagente = ' || v_cagente || ' v_cagente2 = ' || v_cagente2,
                              'error =' || SQLERRM);
                  --Error al modificar la tabla AGE_CORRETAJE
                  RETURN 9905769;
            END;
            */
         IF (v_cuenta > 0) THEN
            BEGIN
               UPDATE age_corretaje
                  SET islider = 1
                WHERE sseguro = psseguro
                  AND cagente = v_cagente2
                  AND nmovimi = v_nmovimi;
            EXCEPTION
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user, 'pac_corretaje.f_update_age_corretaje', 1,
                              'islider=1 - psseguro = ' || psseguro || ' v_nnmovimi = '
                              || v_nmovimi || 'v_cagente = ' || v_cagente || ' v_cagente2 = '
                              || v_cagente2,
                              'error =' || SQLERRM);
                  --Error al modificar la tabla AGE_CORRETAJE
                  RETURN 9905769;
            END;

            BEGIN
               UPDATE age_corretaje
                  SET islider = 0
                WHERE sseguro = psseguro
                  AND cagente = v_cagente
                  AND nmovimi = v_nmovimi;
            EXCEPTION
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user, 'pac_corretaje.f_update_age_corretaje', 1,
                              'islider=0 - psseguro = ' || psseguro || ' v_nnmovimi = '
                              || v_nmovimi || 'v_cagente = ' || v_cagente || ' v_cagente2 = '
                              || v_cagente2,
                              'error =' || SQLERRM);
                  --Error al modificar la tabla AGE_CORRETAJE
                  RETURN 9905769;
            END;
         ELSE
            -- Modificamos el agente del age_corretaje
            BEGIN
               UPDATE age_corretaje
                  SET cagente = v_cagente2
                WHERE sseguro = psseguro
                  AND cagente = v_cagente
                  AND nmovimi = v_nmovimi;
            EXCEPTION
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user, 'pac_corretaje.f_update_age_corretaje', 1,
                              'psseguro = ' || psseguro || ' v_nnmovimi = ' || v_nmovimi
                              || 'v_cagente = ' || v_cagente || ' v_cagente2 = ' || v_cagente2,
                              'error =' || SQLERRM);
                  --Error al modificar la tabla AGE_CORRETAJE
                  RETURN 9905769;
            END;
         -- 28479/0166457 - FIN
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_corretaje.f_update_age_corretaje', 1,
                     'psseguro = ' || psseguro || ' v_nmovimi = ' || v_nmovimi
                     || ' v_cagente = ' || v_cagente || ' v_cagente2 = ' || v_cagente2,
                     SQLERRM);
         RETURN SQLCODE;
   END f_update_age_corretaje;

--FIN BUG 27048 - DCT - 08/07/2013

   --Bug 28043 - JLV 09/09/2013
   FUNCTION f_validapsu(p_seguro IN NUMBER, p_nmovimi IN NUMBER)
      RETURN NUMBER IS
      v_sseguro      NUMBER;
      v_tipcom       NUMBER;
      v_agente       NUMBER;
      v_comisi       NUMBER;
      v_nanuali      NUMBER;
      v_nregest      NUMBER;
      v_nreg         NUMBER;
      v_cambioagente BOOLEAN := FALSE;
      v_cambiocomision BOOLEAN := FALSE;
   BEGIN
      -- Obtener el sseguro real, ya que el que nos llega, es de las tablas EST
      SELECT ssegpol
        INTO v_sseguro
        FROM estseguros
       WHERE sseguro = p_seguro;

      --Primero determinar si el numero de registros en estage_corretaje
      SELECT COUNT(1)
        INTO v_nregest
        FROM estage_corretaje
       WHERE sseguro = p_seguro;

      SELECT COUNT(1)
        INTO v_nreg
        FROM age_corretaje
       WHERE sseguro = v_sseguro
         AND nmovimi = (SELECT MAX(nmovimi)
                          FROM age_corretaje
                         WHERE sseguro = v_sseguro);

      IF (v_nregest <> v_nreg) THEN
         RETURN 1;
      END IF;

      -- determinar si ha habido cambio de intermediario.
      FOR c_agen IN (SELECT cagente
                       FROM age_corretaje
                      WHERE sseguro = v_sseguro
                        AND nmovimi = (SELECT MAX(nmovimi)
                                         FROM age_corretaje
                                        WHERE sseguro = v_sseguro)) LOOP
         BEGIN
            SELECT cagente
              INTO v_agente
              FROM estage_corretaje
             WHERE sseguro = p_seguro
               AND cagente = c_agen.cagente
               AND nmovimi = p_nmovimi;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_agente := -1;
         END;

         IF c_agen.cagente <> v_agente THEN
            --Se ha cambiado lel agente
            v_cambioagente := TRUE;
            EXIT;
         END IF;
      END LOOP;

      IF v_cambioagente THEN
         RETURN 1;
      END IF;

      --Determinar el cambio de comisión si es comi
      BEGIN
         SELECT ctipcom, nanuali
           INTO v_tipcom, v_nanuali
           FROM seguros
          WHERE sseguro = v_sseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            v_tipcom := -1;
      END;

      IF v_tipcom IN(90, 92) THEN   --comisión especial negocio/seguro
         --Recuperar los datos de la nueva producción y de carteras sucesivas.
         FOR c_comis IN (SELECT cmodcom, pcomisi
                           FROM comisionsegu
                          WHERE sseguro = v_sseguro
                            AND nmovimi =
                                  (SELECT MAX(nmovimi)
                                     FROM comisionsegu
                                    WHERE sseguro = v_sseguro)   -- Bug 30642/169851 - 20/03/2014 - AMC
                            AND NVL(v_nanuali, 0) BETWEEN ninialt AND nfinalt) LOOP
            BEGIN
               SELECT pcomisi
                 INTO v_comisi
                 FROM estcomisionsegu
                WHERE sseguro = p_seguro
                  AND nmovimi = p_nmovimi   -- Bug 30642/169851 - 20/03/2014 - AMC
                  AND cmodcom = c_comis.cmodcom
                  AND NVL(v_nanuali, 0) BETWEEN ninialt AND nfinalt;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  v_comisi := -1;
            END;

            IF c_comis.pcomisi <> v_comisi THEN
               --Se ha cambiado la comisión
               v_cambiocomision := TRUE;
               EXIT;
            END IF;
         END LOOP;

         IF v_cambiocomision THEN
            RETURN 1;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_corretaje.f_validapsumodifcorretaje', 1,
                     'Seguro = ' || p_seguro, SQLERRM);
         RETURN SQLCODE;
   END f_validapsu;
-- Fin Bug 28043 - JLV 09/09/2013
 
END pac_corretaje;

/

  GRANT EXECUTE ON "AXIS"."PAC_CORRETAJE" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CORRETAJE" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CORRETAJE" TO "PROGRAMADORESCSI";
