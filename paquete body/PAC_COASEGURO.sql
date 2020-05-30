--------------------------------------------------------
--  DDL for Package Body PAC_COASEGURO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_COASEGURO" IS
/******************************************************************************
   NOMBRE:      pac_coaseguro
   PROPÓSITO:   proceso batch mensual que realiza el Cierre de Coaseguro.

   REVISIONES:
   Ver        Fecha       Autor      Descripción
   ---------  ----------  ---------  ------------------------------------
   1.0        XX/XX/XXXX  XXX        1. Creación del package.
   2.0        06/10/2011  JGR        2. 0019088: LCOL_F001-Parametrizacion de los cierres
   3.0        23/08/2012  JMF        3. 0023188 LCOL_T020-COA-Circuit de Tancament de Coasseguran
   4.0        19/03/2013  AFM        4. 0025803: RSA001 - Ampliar los decimales que utiliza iAXIS
   5.0        30/09/2013  DCT        5. 0028351 - INICIO - DCT - 30/09/2013 - LCOL_A004-Qtracker: 9342: CIERRE DE COASEGUROS NO TERMINARON
QUEDARON EN CIERRES PROGRAMADOS
   6.0        10/10/2013  MMM        6. 0028351: Nota 0155495 -LCOL_A004-Qtracker 9342 CIERRE DE COASEGUROS NO TERMINARON QUEDARON EN CIERRES PROGRAMADOS
   7.0        13/02/2014  SHA        7. 0029734: LCOL_F002-0010651: CONTABILIZACION CTAS CTES COASEGURO CEDIDO RETORNOS 232000.0210
   8.0        18/02/2014  AGG        8. 0026663: POSPG400-(POSPG400)- Parametrizacion Reaseguro, Coaseguro - Parametrizacion contratos
   9.0        20/06/2014  EDA        9. 0024462: LCOL_A004-Qreacker: 11203 y 11707 (176931) Modificación del circuito de siniestros-coaseguro
   10.0       07/07/2014  EDA        10.0032070: LCOL_A004-Qtracker: 0013334: NO SE CONTABILIZARON CTA CTE COA CED DE IVAS GTOS ADMIN Nota: 179039
   11.0       16/07/2014  EDA        11.0032085: LCOL_A004-QT LISTADOS COASEGURO: Se consideran los recibos anulados, que hayan sido impagados.
   12.0       29/07/2014  ETM-EDA    12.0032034: LCOLF3BREA-ID 8 - Ajustes en circuito de Mtto. de Cta. técnica de Coaseguro (INVERFAS) (32034/179554)
   13.0       11/06/2015  KBR        13. 0036409: Pendientes Modulo Coaseguro
******************************************************************************/
   vg_nmesven     NUMBER;
   vg_nanyven     NUMBER;

-------------------------------------------------------------------------------------------------
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
/***********************************************************************************************
    Proceso que lanzará todos los procesos de cierres
    (provisiones, siniestros, ventas, reaseguro, coaseguro....)
************************************************************************************************/
      num_err        NUMBER := 0;
      text_error     VARCHAR2(500);
      pnnumlin       NUMBER;
      texto          VARCHAR2(400);
      indice_error   NUMBER := 0;
      v_estado       NUMBER;
      v_titulo       VARCHAR2(50);
      psql           VARCHAR2(500);
      psmovcoa       NUMBER;
      v_cursor       INTEGER;
      v_truncatectacoaseguroaux VARCHAR2(40);
      v_numrows      INTEGER;
   BEGIN
      IF pmodo = 1 THEN
         v_titulo := 'Cierre Coaseguro Mensual Previo';
      ELSIF pmodo = 2 THEN
         v_titulo := 'Cierre Coaseguro Mensual Definitivo';
      END IF;

      --Insertamos en la tabla PROCESOSCAB el registro identificativo de proceso -----
      num_err := f_procesini(f_user, pcempres, 'COASEGURO', v_titulo, psproces);

      IF num_err <> 0 THEN
         pcerror := 1;
         texto := f_axis_literales(num_err, pcidioma);
         pnnumlin := NULL;
         num_err := f_proceslin(psproces, SUBSTR(texto || ' ' || text_error, 1, 120), 0,
                                pnnumlin);
         COMMIT;
      ELSE
         -- *** Se trunca la tabla auxiliar CTACOASEGUROAUX...
         BEGIN
            -- Para poder ejecutar la instruccion 'TRUNCATE'
            v_cursor := DBMS_SQL.open_cursor;
            v_truncatectacoaseguroaux := 'TRUNCATE TABLE CTACOASEGUROAUX';
            DBMS_SQL.parse(v_cursor, v_truncatectacoaseguroaux, DBMS_SQL.native);
            v_numrows := DBMS_SQL.EXECUTE(v_cursor);
            DBMS_SQL.close_cursor(v_cursor);
         EXCEPTION
            WHEN OTHERS THEN
               IF DBMS_SQL.is_open(v_cursor) THEN
                  DBMS_SQL.close_cursor(v_cursor);
               END IF;

               num_err := 108191;   -- Error al borrar la tabla
         END;

         IF num_err <> 0 THEN
            pcerror := 1;
            texto := f_axis_literales(num_err, pcidioma);
            pnnumlin := NULL;
            text_error := SUBSTR(texto || ' ' || psql, 1, 120);
            num_err := f_proceslin(psproces, text_error, 0, pnnumlin);
            COMMIT;
         ELSE
            -- 6.0 - 10/10/2013 - MMM -0028351: Nota 0155495 -LCOL_A004-Qtracker 9342 CIERRE DE COASEGUROS NO TERMINARON - Inicio
            num_err := cierre_coaseguro(pcempres, pmodo, TO_CHAR(pfperfin, 'mm'),
                                        TO_CHAR(pfperfin, 'yyyy'), psproces, psql, psmovcoa);

            -- 6.0 - 10/10/2013 - MMM -0028351: Nota 0155495 -LCOL_A004-Qtracker 9342 CIERRE DE COASEGUROS NO TERMINARON - Fin
            IF num_err <> 0 THEN
               pcerror := 1;
               texto := f_axis_literales(num_err, pcidioma);
               pnnumlin := NULL;
               text_error := SUBSTR(texto || ' ' || psql, 1, 120);
               num_err := f_proceslin(psproces, text_error, psmovcoa, pnnumlin);
               COMMIT;
            ELSE
               COMMIT;   -- COMMIT PRINCIPAL DEL PROCESO...
               pcerror := 0;
            END IF;
         END IF;
      END IF;

      num_err := f_procesfin(psproces, pcerror);
      pfproces := f_sysdate;

      IF num_err = 0 THEN
         COMMIT;
      END IF;
   END proceso_batch_cierre;

-- *********************************************************
   FUNCTION f_actualizacion_saldos(
      pcempres IN NUMBER,
      pdefi IN NUMBER,
      pmes IN NUMBER,
      pany IN NUMBER,
      pproces IN NUMBER,
      psql OUT VARCHAR2,
      psmovcoa OUT NUMBER)
      RETURN NUMBER IS
/*
   ************************************************************************
   GENERACIÓN O ACTUALIZACIÓN DE SALDOS DE CIERRE DE COASEGURO A NIVEL DE
   COMPAÑÍAS.
   ************************************************************************
*/
      vobj           VARCHAR2(200) := 'PAC_COASEGURO.f_actualizacion_saldos';
      vpar           VARCHAR2(500)
         := 'e=' || pcempres || ' d=' || pdefi || ' m=' || pmes || ' a=' || pany || ' p='
            || pproces;
      vpas           NUMBER := 1;
      perror         NUMBER := 0;
      texto          VARCHAR2(400);
      w_ccompani     NUMBER(3);
      w_saldo_ant_dh NUMBER(1);
      w_saldo_ant    ctacoaseguro.imovimi%TYPE;
      w_smovcoa      NUMBER(8);
      w_ptipiva      NUMBER(5, 2);
      w_impiva       ctacoaseguroaux.imovimi%TYPE;
      d_perfin       DATE;
      v_ctaseg       ctacoaseguroaux.sseguro%TYPE;
      v_ctapro       ctacoaseguroaux.sproduc%TYPE;
      w_saldo_ant_moncon ctacoaseguro.imovimi_moncon%TYPE;
      w_cmoneda      ctacoaseguro.cmoneda%TYPE;
      v_cmultimon    parempresas.nvalpar%TYPE;
      v_cmoncontab   parempresas.nvalpar%TYPE;
      v_itasa        eco_tipocambio.itasa%TYPE;
      v_fcambio      DATE;
      w_impaux       ctacoaseguroaux.imovimi_moncon%TYPE;
      v_cestado      movrecibo.cestrec%TYPE;
      v_ctipcoa      ctacoaseguro.ctipcoa%TYPE;
      v_cramosalud   productos.cagrpro%TYPE;
      w_pretenc      NUMBER := 0;
      w_impret       NUMBER := 0;
      w_liquida_coa  NUMBER := 0;
      w_liquida_conc_liq NUMBER := 0;   --Parametro de empresa que indica si la liquidacion se realiza solo por conceptos liquidables
      w_es_liquidable NUMBER := 0;   --Busca en la tabla TIPOCTACOA si el concepto es liquidable
      d_perini       DATE;
      monneda_inst   NUMBER := 0;
      v_mon_pol      NUMBER := 0;
      existe_cambio  NUMBER := 0;
      imp_cambio_emi NUMBER := 0;
      imp_cambio_rec NUMBER := 0;
      v_fmovini      DATE;
      v_importe_emision NUMBER := 0;
      v_importe_recaudo NUMBER := 0;
      --CONF-905 INICIO
      v_calgastemi   parempresas.nvalpar%TYPE;
      v_pagoparcial  NUMBER := 0;
      w_pcomgas      NUMBER := 0;
      w_impgastos    NUMBER := 0;
      w_impgastaux   NUMBER := 0;
      xcmoneda       NUMBER;
      pnvalcon       NUMBER;
      num_err        NUMBER := 0;
      vporcentaje    NUMBER;
      iva_gastos     NUMBER;
      w_ivagastos    NUMBER;
      w_ivagastaux   NUMBER;
      ppretenc       NUMBER;
      reteniva_gastos NUMBER;
      w_retenivagastaux NUMBER;
      w_reteniva_gastos NUMBER;
      vvalor            NUMBER;
      xxsesion          NUMBER;
      vret              NUMBER;
      retefu_gastos     NUMBER;
      w_retefue_gastos  NUMBER;
      w_retefuegastaux  NUMBER;

      --CONF-905 FIN

      CURSOR co(c_emp IN NUMBER, c_data IN DATE, c_tipocoa IN NUMBER) IS
         SELECT UNIQUE c.sseguro, c.ccompani, s.sproduc, nvl(s.ccompani,1) ccompapr,
                       (SELECT MAX(c2.fmovimi)
                          FROM ctacoaseguro c2
                         WHERE c2.ctipcoa = c.ctipcoa
                           AND c2.ccompani = c.ccompani
                           AND c2.cmovimi = 99
                           AND TRUNC(c2.fmovimi) < c_data) f_max_movimi
                  FROM ctacoaseguro c, seguros s
                 WHERE c.sseguro = s.sseguro
                   AND c.ctipcoa = c_tipocoa
                   AND c.cempres = c_emp
                   AND c.fcierre IS NULL
                   AND TRUNC(c.fmovimi) <= c_data
                   AND cestado<>4
              ORDER BY c.sseguro, c.ccompani;

      CURSOR c(
         c_emp IN NUMBER,
         c_cia IN NUMBER,
         c_data IN DATE,
         c_seg IN NUMBER,
         c_tipocoa IN NUMBER) IS

         SELECT *
           FROM ctacoaseguro
          WHERE ctipcoa = c_tipocoa
            AND cempres = c_emp
            AND ccompani = c_cia
            AND cmovimi <> 99
            AND fcierre IS NULL
            AND TRUNC(fmovimi) <= c_data
            AND sseguro = c_seg
            AND cestado<>4
            and NORDEN is null
          UNION ALL
         SELECT *
           FROM ctacoaseguro cc
          WHERE cc.ctipcoa = c_tipocoa
            AND cc.cempres = c_emp
            AND cc.ccompani = c_cia
            AND cc.cmovimi NOT IN(99, 25)
            AND cc.sseguro = c_seg
            AND cc.fcierre IS NULL
            AND CC.SMOVREC IS NOT NULL
            and CC.NORDEN is not null;


      CURSOR caux IS
         SELECT *
           FROM ctacoaseguroaux
          WHERE cimport IN(13, 30, 31, 4, 37, 38, 39, 40)
             OR cmovimi = 99;

/*********************/
      PROCEDURE loc_calcula_moneda(
         p_impin IN NUMBER,
         p_monin IN VARCHAR2,
         p_impout IN OUT NUMBER,
         p_fecout IN OUT DATE) IS
      BEGIN
         IF v_cmultimon = 1 THEN
            IF p_monin = v_cmoncontab THEN
               v_itasa := 1;
            ELSE
               p_fecout := pac_eco_tipocambio.f_fecha_max_cambio(w_cmoneda, v_cmoncontab,
                                                                 d_perfin);

               IF p_fecout IS NULL THEN
                  p_tab_error(f_sysdate, f_user, vobj, vpas, vpar,
                              'mi=' || w_cmoneda || ' mo=' || v_cmoncontab || ' fe='
                              || d_perfin || ' ' || f_axis_literales(9902592, f_usu_idioma));
                  v_itasa := 0;
               ELSE
                  v_itasa := pac_eco_tipocambio.f_cambio(p_monin, v_cmoncontab, p_fecout);
               END IF;

               p_impout := f_round(NVL(p_impin, 0) * v_itasa, v_cmoncontab);
            END IF;
         ELSE
            p_impout := 0;
         END IF;
      END loc_calcula_moneda;
/*********************/
   BEGIN
      vpas := 1000;
      d_perfin := LAST_DAY(TO_DATE(TO_CHAR(pmes) || '/' || TO_CHAR(pany), 'mm/yyyy'));
      d_perini := trunc(TO_DATE(TO_CHAR(pmes) || '/' || TO_CHAR(pany), 'mm/yyyy'), 'MM');
      v_cmultimon := NVL(pac_parametros.f_parempresa_n(pcempres, 'MULTIMONEDA'), 0);
      v_cmoncontab := pac_parametros.f_parempresa_n(pcempres, 'MONEDACONTAB');
      v_calgastemi := NVL(pac_parametros.f_parempresa_n(NVL(pcempres, pcempres), 'CALCULA_GASTOS_EMI'),0);

      FOR i IN 1 .. 2 LOOP
         IF i = 1 THEN
            v_ctipcoa := 1;
         ELSE
            v_ctipcoa := 8;
         END IF;

         FOR regco IN co(pcempres, d_perfin, v_ctipcoa) LOOP
            IF perror = 0 THEN
               w_ccompani := regco.ccompani;
               w_saldo_ant_dh := 1;
               w_saldo_ant := 0;
               w_saldo_ant_moncon := 0;
               vpas := 1001;
               -- Se busca el saldo anterior...
-- *****************************
-- BUG 32034/179554 - ETM - 14/07/2014 Per les empreses que liquiden a partir del manteniment NO s'arrosseguen els Saldos anteriors
---------------------------------------------------------------------------------------------------------------------------------------
               w_liquida_coa := NVL(pac_parametros.f_parempresa_n(pcempres,
                                                                  'GESTIONA_LIQ_REACOA'),
                                    0);

               BEGIN
                  SELECT c1.cdebhab, DECODE(w_liquida_coa, 0, c1.imovimi, 0), c1.smovcoa,
                         DECODE(w_liquida_coa, 0, c1.imovimi_moncon, 0), c1.cmoneda
                    INTO w_saldo_ant_dh, w_saldo_ant, w_smovcoa,
                         w_saldo_ant_moncon, w_cmoneda
                    FROM ctacoaseguro c1
                   WHERE c1.ctipcoa = v_ctipcoa
                     AND c1.ccompani = w_ccompani
                     AND c1.cmovimi = 99
                     AND c1.fmovimi = regco.f_max_movimi
                     AND c1.sseguro = regco.sseguro
                     AND c1.imovimi <> 0;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     NULL;
                  WHEN OTHERS THEN
                     perror := 107854;
                     psql := SQLERRM;
                     psmovcoa := w_smovcoa;
                     p_tab_error(f_sysdate, f_user, vobj, vpas,
                                 vpar || ' coa: ' || v_ctipcoa || ' seg: ' || regco.sseguro
                                 || ' comp: ' || w_ccompani,
                                 perror || ' ' || NVL(psql, SQLCODE || ' ' || SQLERRM));
               END;

               IF w_saldo_ant_moncon IS NULL THEN
                  loc_calcula_moneda(w_saldo_ant, w_cmoneda, w_saldo_ant_moncon, v_fcambio);
               END IF;

               IF perror = 0 THEN
                  IF w_saldo_ant_dh = 2 THEN
                     w_saldo_ant := w_saldo_ant * -1;
                     w_saldo_ant_moncon := w_saldo_ant_moncon * -1;
                  END IF;

-- Se acumulan los movimientos...
-- ******************************
-- Se crean registros de IVA gastos...
-- ***********************************
-- 23188 AVT 26/10/2012 afegim saldo per pòlissa
                  w_liquida_conc_liq := NVL(pac_parametros.f_parempresa_n(pcempres,
                                                                          'LIQCOACONLIQ'),
                                            0);

                  FOR reg IN c(pcempres, w_ccompani, d_perfin, regco.sseguro, v_ctipcoa) LOOP
                     IF w_liquida_conc_liq = 1 THEN
                        BEGIN
                           SELECT 1
                             INTO w_es_liquidable
                             FROM tipoctacoa
                            WHERE cempres = pcempres
                              AND cimport = reg.cimport
                              AND cmovimi = reg.cmovimi
                              AND ctipcta = 1
                              AND cliquid = 'S';
                        EXCEPTION
                           WHEN NO_DATA_FOUND THEN
                              w_es_liquidable := 0;
                           WHEN OTHERS THEN
                              w_es_liquidable := 0;
                        END;
                     ELSE
                        w_es_liquidable := 1;
                     END IF;

                     IF w_es_liquidable = 1 THEN
                        BEGIN
                           IF reg.nrecibo IS NOT NULL THEN
                              --Se consideran los recibos impagados.
                              SELECT DECODE(cestrec, 0, cestant, cestrec)
                                INTO v_cestado
                                FROM movrecibo
                               WHERE nrecibo = reg.nrecibo
                                 AND fmovfin IS NULL;
                           ELSIF reg.nsinies IS NOT NULL
                                 AND reg.sidepag IS NOT NULL THEN
                              SELECT DECODE(stm.cestpag, 0, 0, 1)
                                INTO v_cestado
                                FROM sin_tramita_movpago stm
                               WHERE stm.sidepag = reg.sidepag
                                 AND stm.nmovpag IN(SELECT MAX(nmovpag)
                                                      FROM sin_tramita_movpago stm2
                                                     WHERE stm.sidepag = stm2.sidepag);
                           ELSE
                              v_cestado := 1;
                           END IF;
                        EXCEPTION
                           WHEN OTHERS THEN
                              v_cestado := 0;
                        END;

                        IF v_cestado =0 then  --REVISAMOS SI  TIENE PARCIALES
                            SELECT  NVL(CASE WHEN count(0) = 0 THEN 0 ELSE 1 END,0)
                            INTO v_cestado
                            FROM detmovrecibo
                            WHERE nrecibo=reg.nrecibo
                            AND TRUNC(fmovimi) BETWEEN d_perini AND d_perfin;
                        END IF;

                        --Estado PAGADO/COBRADO
                        IF v_cestado = 1 THEN
                           IF reg.imovimi_moncon IS NULL THEN
                              loc_calcula_moneda(reg.imovimi, reg.cmoneda, reg.imovimi_moncon,
                                                 reg.fcambio);
                           END IF;

                           vpas := 1002;

                           SELECT MAX(a.sseguro), MAX(b.sproduc)
                             INTO v_ctaseg, v_ctapro
                             FROM recibos a, seguros b
                            WHERE a.nrecibo = reg.nrecibo
                              AND b.sseguro = a.sseguro;

                           IF perror = 0 THEN
                              --Se pasan los movimientos existentes al CTACOASEGUROAUX...
                              BEGIN
                                 INSERT INTO ctacoaseguroaux
                                             (ccompani, cimport, ctipcoa,
                                              cmovimi, imovimi, fmovimi, fcontab,
                                              cdebhab, fliqcia, pcescoa, sidepag,
                                              nrecibo, smovrec, cempres, sseguro,
                                              sproduc, imovimi_moncon, fcambio,
                                              nsinies, cestado, ccompapr, fcierre)
                                      VALUES (reg.ccompani, reg.cimport, reg.ctipcoa,
                                              reg.cmovimi, reg.imovimi, reg.fmovimi, NULL,
                                              reg.cdebhab, NULL, reg.pcescoa, reg.sidepag,
                                              reg.nrecibo, reg.smovrec, pcempres, v_ctaseg,
                                              v_ctapro, reg.imovimi_moncon, reg.fcambio,
                                              reg.nsinies, 1, 1, d_perfin);
                              EXCEPTION
                                 WHEN OTHERS THEN
                                    perror := 108168;
                                    psql := SQLERRM;
                                    psmovcoa := reg.smovcoa;
                                    p_tab_error(f_sysdate, f_user, vobj, vpas, vpar,
                                                perror || ' '
                                                || NVL(psql, SQLCODE || ' ' || SQLERRM));
                              END;


                              --                  El signo de los movimientos de recibos dependen del CDEBHAB,
                              --                  mientras que el signo de los movimientos de siniestros dependen
                              --                  del cmovimi...
                              IF reg.cdebhab = 1 THEN
                                 w_saldo_ant := w_saldo_ant + reg.imovimi;   -- Cobro recibo...
                                 w_saldo_ant_moncon := w_saldo_ant_moncon + reg.imovimi_moncon;   -- Cobro recibo...
                              ELSE
                                 w_saldo_ant := w_saldo_ant - reg.imovimi;   -- Descobro o extorno...
                                 w_saldo_ant_moncon := w_saldo_ant_moncon - reg.imovimi_moncon;   -- Descobro o extorno...
                              END IF;

                              vpas := 1003;

                              IF pdefi = 2 THEN
                                 BEGIN
                                    UPDATE ctacoaseguro
                                       SET fcierre = d_perfin,
                                           cestado = 0,
                                           sproces = pproces
                                     WHERE smovcoa = reg.smovcoa
                                     AND cestado <>4;
                                 EXCEPTION
                                    WHEN OTHERS THEN
                                       perror := 105674;
                                       psql := SQLERRM;
                                       psmovcoa := reg.smovcoa;
                                       p_tab_error(f_sysdate, f_user, vobj, vpas, vpar,
                                                   perror || ' '
                                                   || NVL(psql, SQLCODE || ' ' || SQLERRM));
                                 END;
                              END IF;

                              vpas := 1004;



                           --------------------UTILIDAD Y PERDIDA FAC-----------------------------
                              --VERIFICAR SI LA POLIZA ES MONEDA EXTRANJERA
                              monneda_inst:=pac_parametros.f_parinstalacion_n ('MONEDAINST');
                              SELECT CDIVISA INTO v_mon_pol
                              FROM PRODUCTOS
                              WHERE SPRODUC IN (SELECT SPRODUC
                                                FROM SEGUROS
                                                WHERE SSEGURO IN (SELECT SSEGURO
                                                                    FROM RECIBOS
                                                                   WHERE NRECIBO =reg.nrecibo));

                            IF monneda_inst <> V_MON_POL THEN
                                SELECT count(*)
                                  INTO existe_cambio
                                FROM detmovrecibo
                                WHERE NRECIBO=reg.nrecibo;

                                IF  existe_cambio > 0 THEN
                                   SELECT max(fmovimi),max(fcambio)
                                   INTO v_fmovini ,v_fcambio
                                   FROM detmovrecibo
                                   WHERE NRECIBO=reg.nrecibo;
                                ELSE
                                   SELECT max(fmovini),max(fcontab)
                                   INTO v_fmovini ,v_fcambio
                                   FROM movrecibo
                                   WHERE NRECIBO=reg.nrecibo;
                                END IF;

                                IF  reg.cimport =1 THEN

                                   imp_cambio_emi:= pac_eco_tipocambio.f_cambio(pac_monedas.f_cmoneda_t(V_MON_POL), pac_monedas.f_cmoneda_t(monneda_inst), v_fmovini);
                                   imp_cambio_rec:= pac_eco_tipocambio.f_cambio(pac_monedas.f_cmoneda_t(V_MON_POL), pac_monedas.f_cmoneda_t(monneda_inst), v_fcambio);

                                   v_importe_emision :=reg.imovimi * imp_cambio_emi;
                                   v_importe_recaudo :=reg.imovimi * imp_cambio_rec;

                                   IF  v_importe_emision < v_importe_recaudo THEN
                                      BEGIN
                                        INSERT INTO ctacoaseguroaux
                                                 (ccompani, cimport, ctipcoa,
                                                  cmovimi, imovimi, fmovimi, fcontab,
                                                  cdebhab, fliqcia, pcescoa, sidepag,
                                                  nrecibo, smovrec, cempres, sseguro,
                                                  sproduc, imovimi_moncon, fcambio,
                                                  nsinies, cestado, fcierre, cmoneda,ccompapr)
                                        VALUES (reg.ccompani, 32 , reg.ctipcoa,
                                                  99, NVL(abs(v_importe_emision-v_importe_recaudo),0), reg.fmovimi, NULL,
                                                  1, NULL, reg.pcescoa, reg.sidepag,
                                                  NULL, NULL, pcempres, reg.sseguro,
                                                  NULL, NULL, reg.fcambio,
                                                  reg.nsinies, 1, d_perfin, 8,1);
                                      EXCEPTION
                                        WHEN OTHERS THEN
                                        perror := 108168;
                                        psql := SQLERRM;
                                        psmovcoa := reg.smovcoa;
                                        p_tab_error(f_sysdate, f_user, vobj, vpas, vpar,
                                                    perror || ' '
                                                    || NVL(psql, SQLCODE || ' ' || SQLERRM));
                                      END;
                                   ELSE
                                      BEGIN
                                        INSERT INTO ctacoaseguroaux
                                                 (ccompani, cimport, ctipcoa,
                                                  cmovimi, imovimi, fmovimi, fcontab,
                                                  cdebhab, fliqcia, pcescoa, sidepag,
                                                  nrecibo, smovrec, cempres, sseguro,
                                                  sproduc, imovimi_moncon, fcambio,
                                                  nsinies, cestado, fcierre, cmoneda,ccompapr)
                                        VALUES (reg.ccompani, 33 , reg.ctipcoa,
                                                  99, NVL(abs(v_importe_emision-v_importe_recaudo),0), reg.fmovimi, NULL,
                                                  2, NULL, reg.pcescoa, reg.sidepag,
                                                  NULL, NULL, pcempres, reg.sseguro,
                                                  NULL, NULL, reg.fcambio,
                                                  reg.nsinies, 1, d_perfin, 8,1);
                                      EXCEPTION
                                        WHEN OTHERS THEN
                                        perror := 108168;
                                        psql := SQLERRM;
                                        psmovcoa := reg.smovcoa;
                                        p_tab_error(f_sysdate, f_user, vobj, vpas, vpar,
                                                    perror || ' '
                                                    || NVL(psql, SQLCODE || ' ' || SQLERRM));
                                      END;
                                   END IF;
                                END IF;
                            END IF;

                            vpas := 10005;

                              ---------------------------------HASTA ACA FAC-------------------------------

                              -- CONF-905 INICIO
                              IF v_calgastemi = 1 THEN --OSCAR INICIO
                                IF v_ctipcoa = 1   THEN
                                  IF reg.cimport = 1 THEN
                                  BEGIN
                                    vpas := 9991;
                                    SELECT nvl(max(pcomgas),0)
                                        INTO w_pcomgas
                                    FROM coacedido
                                    WHERE sseguro = v_ctaseg
                                    AND ccompan = reg.ccompani;
                                    EXCEPTION
                                       WHEN NO_DATA_FOUND THEN
                                          w_pcomgas := 0;
                                       WHEN OTHERS THEN
                                          perror := 107885;
                                          psql := SQLERRM;
                                          psmovcoa := reg.smovcoa;
                                          p_tab_error(f_sysdate, f_user, vobj, vpas, vpar,
                                                      perror || ' '
                                                      || NVL(psql, SQLCODE || ' ' || SQLERRM));
                                       END;
                                     p_control_error('OSUAREZ','PAC_COASEGURO','w_pcomgas '||w_pcomgas);

                                     vpas := 9992;
                                     IF perror = 0 THEN

                                       w_impgastos := reg.imovimi * NVL(w_pcomgas, 0) / 100;
                                       w_impgastaux := reg.imovimi_moncon * NVL(w_pcomgas, 0)/100;
                                       w_impgastaux := f_round(w_impgastaux, v_cmoncontab);


                                     END IF;
                                     vpas := 9993;
                                     --IF reg.cdebhab = 1 THEN
                                     --     w_saldo_ant := w_saldo_ant + w_impgastos;
                                     --     w_saldo_ant_moncon := w_saldo_ant_moncon + w_impgastaux;
                                     --ELSE
                                          w_saldo_ant := w_saldo_ant - w_impgastos;
                                          w_saldo_ant_moncon := w_saldo_ant_moncon - w_impgastaux;
                                     --END IF;
                                     vpas := 9994;
                                     BEGIN
                                        p_control_error('OSUAREZ','PAC_COASEGURO','PASO INSERT');
                                          --El concepto 4 es "GASTOS ADMINISTRACION"
                                          INSERT INTO ctacoaseguroaux
                                                      (ccompani, cimport, ctipcoa, cmovimi,
                                                       imovimi, fmovimi, fcontab,
                                                       cdebhab, fliqcia, pcescoa,
                                                       sidepag, nrecibo, smovrec,
                                                       cempres, sseguro, sproduc,
                                                       imovimi_moncon, fcambio, nsinies,
                                                       cestado, ccompapr, fcierre)
                                               VALUES (reg.ccompani, 4, 1, reg.cmovimi,
                                                       w_impgastos, reg.fmovimi, NULL,
                                                       2, NULL, reg.pcescoa,
                                                       reg.sidepag, reg.nrecibo, reg.smovrec,
                                                       pcempres, v_ctaseg, v_ctapro,
                                                       w_impgastaux, reg.fcambio, NULL,
                                                       0, 1, d_perfin);
                                       EXCEPTION
                                          WHEN OTHERS THEN
                                             perror := 108168;
                                             psql := SQLERRM;
                                             psmovcoa := reg.ccompani;
                                             p_tab_error(f_sysdate, f_user, vobj, vpas, vpar,
                                                         perror || ' '
                                                         || NVL(psql,
                                                                SQLCODE || ' ' || SQLERRM));
                                       END;
                                    p_control_error('OSUAREZ','PAC_COASEGURO','PASO INSERT 2');
                                  vpas := 9995;

                                  END IF;
                                END IF;
                                    --funcion que calcula las conceptos y tenciones para los gastos a nivel caseguradoras
                                      ----iva sobre gastos--
                              ----------------------
                              BEGIN
                                 SELECT cmoneda
                                   INTO xcmoneda
                                   FROM seguros
                                  WHERE sseguro = v_ctaseg;
                              EXCEPTION
                                 WHEN OTHERS THEN
                                     p_tab_error(f_sysdate, f_user, vobj, vpas, vpar, perror || ' ' || NVL(psql, SQLCODE || ' ' || SQLERRM));
                              END;

                              BEGIN
                                 SELECT clave
                                   INTO pnvalcon
                                   FROM sgt_trans_formula
                                  WHERE parametro = 'IVA_GASTOS';
                              EXCEPTION
                                 WHEN OTHERS THEN
                                    perror   := 107885;
                                    psql     := SQLERRM;
                                    psmovcoa := reg.smovcoa;
                                    p_tab_error(f_sysdate, f_user, vobj, vpas, vpar, perror || ' ' || NVL(psql, SQLCODE || ' ' || SQLERRM));
                              END;


                              num_err := pac_liquida.f_calc_formula_coaseguro(reg.ccompani, pnvalcon, f_sysdate, vporcentaje);

                              IF num_err <> 0 THEN
                                 RETURN num_err;
                              END IF;

                              iva_gastos := f_round(w_impgastos * vporcentaje, xcmoneda,
                                                  pac_parametros.f_parempresa_n(pcempres, 'MONEDACONTAB'));


                              w_ivagastos := iva_gastos * NVL(w_pcomgas, 0) / 100;
                              w_ivagastaux := iva_gastos * NVL(w_pcomgas, 0)/100;
                              w_ivagastaux := f_round(w_ivagastaux, v_cmoncontab);


                              BEGIN
                                 INSERT INTO ctacoaseguroaux
                                    (ccompani, cimport, ctipcoa, cmovimi,
                                     imovimi, fmovimi, fcontab, cdebhab,
                                     fliqcia, pcescoa, sidepag, nrecibo,
                                     smovrec, cempres, sseguro, sproduc,
                                     imovimi_moncon, fcambio, nsinies,
                                     cestado, ccompapr, fcierre)
                                 VALUES
                                    (reg.ccompani, 37, 1, reg.cmovimi,
                                     w_ivagastos, reg.fmovimi, NULL, 2, NULL,
                                     reg.pcescoa, reg.sidepag, reg.nrecibo,
                                     reg.smovrec, pcempres, v_ctaseg,
                                     v_ctapro, w_ivagastaux, reg.fcambio,
                                     NULL, 0, 1, d_perfin);
                              EXCEPTION
                                 WHEN OTHERS THEN
                                    perror   := 108168;
                                    psql     := SQLERRM;
                                    psmovcoa := reg.ccompani;
                                    p_tab_error(f_sysdate, f_user, vobj,
                                                vpas, vpar, perror || ' ' || NVL(psql, SQLCODE || ' ' ||  SQLERRM));
                              END;


                              -- RETEIVA

                              BEGIN
                               SELECT NVL(max(rc.pretenc),0)
                                 INTO ppretenc
                                 FROM retenciones ret, recibos rc
                                WHERE rc.sseguro = v_ctaseg;
                              EXCEPTION
                                 WHEN OTHERS THEN
                                    perror   := 107885;
                                    psql     := SQLERRM;
                                    psmovcoa := reg.smovcoa;
                                    p_tab_error(f_sysdate, f_user, vobj, vpas, vpar, perror || ' ' || NVL(psql, SQLCODE || ' ' || SQLERRM));
                              END;

                              IF ppretenc <> 0 THEN

                              ppretenc := ppretenc/100;

                              reteniva_gastos := f_round(w_impgastos * ppretenc, xcmoneda,
                                                  pac_parametros.f_parempresa_n(pcempres, 'MONEDACONTAB'));


                              w_reteniva_gastos := reteniva_gastos * NVL(w_pcomgas, 0) / 100;
                              w_retenivagastaux := reteniva_gastos * NVL(w_pcomgas, 0)/100;
                              w_retenivagastaux := f_round(w_retenivagastaux, v_cmoncontab);


                              BEGIN
                                 INSERT INTO ctacoaseguroaux
                                    (ccompani, cimport, ctipcoa, cmovimi,
                                     imovimi, fmovimi, fcontab, cdebhab,
                                     fliqcia, pcescoa, sidepag, nrecibo,
                                     smovrec, cempres, sseguro, sproduc,
                                     imovimi_moncon, fcambio, nsinies,
                                     cestado, ccompapr, fcierre)
                                 VALUES
                                    (reg.ccompani, 38, 1, reg.cmovimi,
                                     w_reteniva_gastos, reg.fmovimi, NULL, 2, NULL,
                                     reg.pcescoa, reg.sidepag, reg.nrecibo,
                                     reg.smovrec, pcempres, v_ctaseg,
                                     v_ctapro, w_retenivagastaux, reg.fcambio,
                                     NULL, 0, 1, d_perfin);
                              EXCEPTION
                                 WHEN OTHERS THEN
                                    perror   := 108168;
                                    psql     := SQLERRM;
                                    psmovcoa := reg.ccompani;
                                    p_tab_error(f_sysdate, f_user, vobj,
                                                vpas, vpar, perror || ' ' || NVL(psql, SQLCODE || ' ' ||  SQLERRM));
                              END;

                              END IF;

                              -- Retefuente
                              BEGIN
                               SELECT DECODE(r.cregfiscal, 6, 0, 8, 0, DECODE(p.ctipper, 1, 1, 2))
                                 INTO vvalor
                                 FROM companias cp,
                                      per_personas p,
                                      (SELECT sperson,
                                              cregfiscal
                                         FROM per_regimenfiscal
                                        WHERE (sperson, fefecto) IN
                                              (SELECT sperson,
                                                      MAX(fefecto)
                                                 FROM per_regimenfiscal
                                                GROUP BY sperson)) r
                                WHERE cp.ccompani = reg.ccompani
                                  AND p.sperson = cp.sperson
                                  AND p.sperson = r.sperson(+);
                              EXCEPTION
                                 WHEN OTHERS THEN
                                    perror   := 107885;
                                    psql     := SQLERRM;
                                    psmovcoa := reg.smovcoa;
                                    p_tab_error(f_sysdate, f_user, vobj, vpas, vpar, perror || ' ' || NVL(psql, SQLCODE || ' ' || SQLERRM));
                              END;

                             SELECT sgt_sesiones.nextval
                               INTO xxsesion
                               FROM dual;

                               SELECT VTRAMO(xxsesion,800064,vvalor)
                               INTO vret
                               FROM DUAL;

                               vret := vret/100;


                               retefu_gastos := f_round(w_impgastos * vret, xcmoneda,
                                                  pac_parametros.f_parempresa_n(pcempres, 'MONEDACONTAB'));


                              w_retefue_gastos := retefu_gastos * NVL(w_pcomgas, 0) / 100;
                              w_retefuegastaux := retefu_gastos * NVL(w_pcomgas, 0)/100;
                              w_retefuegastaux := f_round(w_retefuegastaux, v_cmoncontab);


                              BEGIN
                                 INSERT INTO ctacoaseguroaux
                                    (ccompani, cimport, ctipcoa, cmovimi,
                                     imovimi, fmovimi, fcontab, cdebhab,
                                     fliqcia, pcescoa, sidepag, nrecibo,
                                     smovrec, cempres, sseguro, sproduc,
                                     imovimi_moncon, fcambio, nsinies,
                                     cestado, ccompapr, fcierre)
                                 VALUES
                                    (reg.ccompani, 39, 1, reg.cmovimi,
                                     w_retefue_gastos, reg.fmovimi, NULL, 2, NULL,
                                     reg.pcescoa, reg.sidepag, reg.nrecibo,
                                     reg.smovrec, pcempres, v_ctaseg,
                                     v_ctapro, w_retefuegastaux, reg.fcambio,
                                     NULL, 0, 1, d_perfin);
                              EXCEPTION
                                 WHEN OTHERS THEN
                                    perror   := 108168;
                                    psql     := SQLERRM;
                                    psmovcoa := reg.ccompani;
                                    p_tab_error(f_sysdate, f_user, vobj,
                                                vpas, vpar, perror || ' ' || NVL(psql, SQLCODE || ' ' ||  SQLERRM));
                              END;
                              ----------------------

                              ELSE
                              vpas := 55555;
                              -- CONF-905 FIN




                              IF perror = 0 THEN
                                 IF reg.cimport = 4 THEN   -- gastos...
                                    BEGIN
                                       SELECT ptipiva
                                         INTO w_ptipiva
                                         FROM tipoiva t, companias co
                                        WHERE co.ccompani = reg.ccompani
                                          AND co.ctipiva = t.ctipiva
                                          AND t.ffinvig IS NULL;
                                    EXCEPTION
                                       WHEN NO_DATA_FOUND THEN
                                          w_ptipiva := 0;
                                       WHEN OTHERS THEN
                                          perror := 107885;
                                          psql := SQLERRM;
                                          psmovcoa := reg.smovcoa;
                                          p_tab_error(f_sysdate, f_user, vobj, vpas, vpar,
                                                      perror || ' '
                                                      || NVL(psql, SQLCODE || ' ' || SQLERRM));
                                    END;
                                    vpas := 9996;

                                    IF perror = 0 THEN
                                       w_impiva := reg.imovimi * NVL(w_ptipiva, 0) / 100;
                                       w_impaux := reg.imovimi_moncon * NVL(w_ptipiva, 0)
                                                   / 100;
                                       w_impaux := f_round(w_impaux, v_cmoncontab);

                                       IF reg.cdebhab = 1 THEN
                                          w_saldo_ant := w_saldo_ant + w_impiva;
                                          w_saldo_ant_moncon := w_saldo_ant_moncon + w_impaux;
                                       ELSE
                                          w_saldo_ant := w_saldo_ant - w_impiva;
                                          w_saldo_ant_moncon := w_saldo_ant_moncon - w_impaux;
                                       END IF;

                                       SELECT MAX(a.sseguro), MAX(b.sproduc)
                                         INTO v_ctaseg, v_ctapro
                                         FROM recibos a, seguros b
                                        WHERE a.nrecibo = reg.nrecibo
                                          AND b.sseguro = a.sseguro;
                                    vpas := 9997;
                                       vpas := 1005;

                                       IF v_ctipcoa = 8 THEN
                                          --Calcular IVA sobre gastos (ramo salud)y configurar un parametro de producto para este tipo de concepto
                                          BEGIN
                                             SELECT cagrpro
                                               INTO v_cramosalud
                                               FROM productos
                                              WHERE sproduc = reg.sproduc;
                                          EXCEPTION
                                             WHEN NO_DATA_FOUND THEN
                                                v_cramosalud := 0;
                                          END;

                                          IF v_cramosalud = 5 THEN   --Ramo Salud
                                             --cconcep 30: IVA gastos para ramo salud
                                             vpas := 1006;

                                             BEGIN
                                                INSERT INTO ctacoaseguroaux
                                                            (ccompani, cimport, ctipcoa,
                                                             cmovimi, imovimi,
                                                             fmovimi, fcontab, cdebhab,
                                                             fliqcia, pcescoa, sidepag,
                                                             nrecibo, smovrec,
                                                             cempres, sseguro, sproduc,
                                                             imovimi_moncon, fcambio,
                                                             nsinies, cestado, ccompapr,
                                                             fcierre)
                                                     VALUES (reg.ccompani, 30, 8,   -- 07/07/2014 EDA 2070/179039
                                                             reg.cmovimi, w_impiva,
                                                             reg.fmovimi, NULL, reg.cdebhab,
                                                             NULL, reg.pcescoa, reg.sidepag,
                                                             reg.nrecibo, reg.smovrec,
                                                             pcempres, v_ctaseg, v_ctapro,
                                                             w_impaux, reg.fcambio,
                                                             NULL, 0, 1,
                                                             d_perfin);
                                             EXCEPTION
                                                WHEN OTHERS THEN
                                                   perror := 108168;
                                                   psql := SQLERRM;
                                                   psmovcoa := reg.ccompani;
                                                   p_tab_error(f_sysdate, f_user, vobj, vpas,
                                                               vpar,
                                                               perror || ' '
                                                               || NVL(psql,
                                                                      SQLCODE || ' '
                                                                      || SQLERRM));
                                             END;

                                             vpas := 1007;

                                             --Obtenemos la retención del IVA
                                             BEGIN
                                                SELECT pimpint
                                                  INTO w_pretenc
                                                  FROM companias
                                                 WHERE ccompani = reg.ccompani;

                                                IF w_pretenc = 0 THEN
                                                   SELECT pretenc
                                                     INTO w_pretenc
                                                     FROM companias c, paises p
                                                    WHERE c.cpais = p.cpais
                                                      AND c.ccompani = reg.ccompani;
                                                END IF;
                                             EXCEPTION
                                                WHEN NO_DATA_FOUND THEN
                                                   w_pretenc := 0;
                                             END;

                                             w_impret := w_impaux * w_pretenc;
                                             vpas := 1008;

                                             BEGIN
                                                --cconcep 31: Retención del IVA (solo IVA ramo salud)
                                                INSERT INTO ctacoaseguroaux
                                                            (ccompani, cimport, ctipcoa,
                                                             cmovimi, imovimi,
                                                             fmovimi, fcontab, cdebhab,
                                                             fliqcia, pcescoa, sidepag,
                                                             nrecibo, smovrec,
                                                             cempres, sseguro, sproduc,
                                                             imovimi_moncon, fcambio,
                                                             nsinies, cestado, ccompapr,
                                                             fcierre)
                                                     VALUES (reg.ccompani, 31, 8,
                                                             reg.cmovimi, w_impiva,
                                                             reg.fmovimi, NULL, reg.cdebhab,
                                                             NULL, reg.pcescoa, reg.sidepag,
                                                             reg.nrecibo, reg.smovrec,
                                                             pcempres, v_ctaseg, v_ctapro,
                                                             w_impret, reg.fcambio,
                                                             NULL, 0, 1,
                                                             d_perfin);
                                             EXCEPTION
                                                WHEN OTHERS THEN
                                                   perror := 108168;
                                                   psql := SQLERRM;
                                                   psmovcoa := reg.ccompani;
                                                   p_tab_error(f_sysdate, f_user, vobj, vpas,
                                                               vpar,
                                                               perror || ' '
                                                               || NVL(psql,
                                                                      SQLCODE || ' '
                                                                      || SQLERRM));
                                             END;
                                          END IF;
                                       END IF;

                                       vpas := 1009;

                                       BEGIN
                                          --El concepto 13 es "IVA sobre los gastos de administración"
                                          --Que irá relacionado con el concepto 4 "Gastos de administración"
                                          INSERT INTO ctacoaseguroaux
                                                      (ccompani, cimport, ctipcoa, cmovimi,
                                                       imovimi, fmovimi, fcontab,
                                                       cdebhab, fliqcia, pcescoa,
                                                       sidepag, nrecibo, smovrec,
                                                       cempres, sseguro, sproduc,
                                                       imovimi_moncon, fcambio, nsinies,
                                                       cestado, ccompapr, fcierre)
                                               VALUES (reg.ccompani, 13, 1, reg.cmovimi,
                                                       w_impiva, reg.fmovimi, NULL,
                                                       reg.cdebhab, NULL, reg.pcescoa,
                                                       reg.sidepag, reg.nrecibo, reg.smovrec,
                                                       pcempres, v_ctaseg, v_ctapro,
                                                       w_impaux, reg.fcambio, NULL,
                                                       0, 1, d_perfin);
                                       EXCEPTION
                                          WHEN OTHERS THEN
                                             perror := 108168;
                                             psql := SQLERRM;
                                             psmovcoa := reg.ccompani;
                                             p_tab_error(f_sysdate, f_user, vobj, vpas, vpar,
                                                         perror || ' '
                                                         || NVL(psql,
                                                                SQLCODE || ' ' || SQLERRM));
                                       END;
                                    END IF;
                                 END IF;
                              END IF;
                              END IF; --OSCAR FIN
                           END IF;
                        END IF;
                     ELSE
                        IF pdefi = 2 THEN
                           BEGIN
                              UPDATE ctacoaseguro
                                 SET fcierre = d_perfin,
                                     sproces = pproces
                               WHERE smovcoa = reg.smovcoa;
                           EXCEPTION
                              WHEN OTHERS THEN
                                 perror := 105674;
                                 psql := SQLERRM;
                                 psmovcoa := reg.smovcoa;
                                 p_tab_error(f_sysdate, f_user, vobj, vpas, vpar,
                                             perror || ' '
                                             || NVL(psql, SQLCODE || ' ' || SQLERRM));
                           END;
                        END IF;
                     END IF;
                  END LOOP;

                  IF perror = 0 THEN
                     IF w_saldo_ant >= 0 THEN
                        w_saldo_ant_dh := 1;
                     ELSE
                        w_saldo_ant_dh := 2;
                        w_saldo_ant := w_saldo_ant * -1;
                        w_saldo_ant_moncon := w_saldo_ant_moncon * -1;
                     END IF;

-- Se genera último saldo si el cierre es definitivo...
-- ****************************************************
                     vpas := 1006;

                     IF pdefi = 2 THEN
                        BEGIN
                           INSERT INTO ctacoaseguroaux
                                       (ccompani, cimport, ctipcoa, cmovimi, imovimi,
                                        fmovimi, fcontab, cdebhab, fliqcia, pcescoa, sidepag,
                                        nrecibo, smovrec, cempres, sseguro, sproduc,
                                        imovimi_moncon, fcambio, nsinies, cestado,
                                        ccompapr, fcierre, sproces)
                                VALUES (w_ccompani, 0, 1, 99, w_saldo_ant,
                                        d_perfin, NULL, w_saldo_ant_dh, NULL, 0, NULL,
                                        NULL, NULL, pcempres, regco.sseguro, regco.sproduc,
                                        w_saldo_ant_moncon, v_fcambio, NULL, 1,
                                        1, d_perfin, pproces);
                        EXCEPTION
                           WHEN OTHERS THEN
                              perror := 108168;
                              psql := SQLERRM;
                              psmovcoa := w_ccompani;
                              p_tab_error(f_sysdate, f_user, vobj, vpas, vpar,
                                          perror || ' '
                                          || NVL(psql, SQLCODE || ' ' || SQLERRM));
                        END;
                     END IF;
                  END IF;
               END IF;
            END IF;
         END LOOP;

         vpas := 1007;
      END LOOP;

-- Si es cierre definitivo, se pasan de la tabla
-- auxiliar a la definitiva los ivas y los saldos finales...
-- *******************************************************
      IF perror = 0 THEN
         IF pdefi = 2 THEN
            FOR regaux IN caux LOOP
               SELECT smovcoa.NEXTVAL
                 INTO w_smovcoa
                 FROM DUAL;

               BEGIN
                  INSERT INTO ctacoaseguro
                              (smovcoa, ccompani, cimport, ctipcoa,
                               cmovimi, imovimi, fmovimi,
                               fcontab, cdebhab, fliqcia,
                               pcescoa, sidepag, nrecibo,
                               smovrec, cempres, sseguro,
                               sproduc, imovimi_moncon, fcambio,
                               nsinies, cestado, ccompapr,
                               fcierre, sproces)
                       VALUES (w_smovcoa, regaux.ccompani, regaux.cimport, regaux.ctipcoa,
                               regaux.cmovimi, regaux.imovimi, regaux.fmovimi,
                               regaux.fcontab, regaux.cdebhab, regaux.fliqcia,
                               regaux.pcescoa, regaux.sidepag, regaux.nrecibo,
                               regaux.smovrec, regaux.cempres, regaux.sseguro,
                               regaux.sproduc, regaux.imovimi_moncon, regaux.fcambio,
                               regaux.nsinies, regaux.cestado, regaux.ccompapr,
                               regaux.fcierre, pproces);
               EXCEPTION
                  WHEN OTHERS THEN
                     perror := 105578;
                     psql := SQLERRM;
                     psmovcoa := regaux.ccompani;
                     p_tab_error(f_sysdate, f_user, vobj, vpas, vpar,
                                 perror || ' ' || NVL(psql, SQLCODE || ' ' || SQLERRM));
               END;
            END LOOP;
         END IF;
      END IF;

      RETURN(perror);
   END f_actualizacion_saldos;

-- *********************************************************
   FUNCTION f_reservas_sin(
      pcempres IN NUMBER,
      pdefi IN NUMBER,
      pmes IN NUMBER,
      pany IN NUMBER,
      pproces IN NUMBER,
      psql OUT VARCHAR2,
      psmovcoa OUT NUMBER)
      RETURN NUMBER IS
      -- Bug 0023188 - 23/08/2012 - JMF
/*
   ************************************************************************
   Cálculo de cesión de reservas de siniestros para el Coaseguro
   ************************************************************************
*/
      vobj           VARCHAR2(500) := 'pac_coaseguro.f_reservas_sin';
      vpar           VARCHAR2(500)
                        := 'd=' || pdefi || ' m=' || pmes || ' a=' || pany || ' p=' || pproces;
      vpas           NUMBER := 0;
      perror         NUMBER := 0;
      v_cmovimi      ctacoaseguroaux.cmovimi%TYPE := 25;   -- Reservas.
      d_perini       DATE;
      d_perfin       DATE;
      xsigno         NUMBER(1);
      vnmoneda       monedas.cmoneda%TYPE;
      ximporte       NUMBER;
      ximporte_moncia NUMBER;
      w_smovcoa      ctacoaseguro.smovcoa%TYPE;
      v_cdebhab      ctacoaseguroaux.cdebhab%TYPE;
      e_salida       EXCEPTION;
      v_cestado      sin_tramita_movpago.cestpag%TYPE;   -- 20/06/2014 EDA Bug 24462/176931

      CURSOR c2 IS
         SELECT DISTINCT si.nsinies nsin, si.fsinies fsin, si.fnotifi fnot, sr.sidepag,   -- 20/06/2014 EDA Bug 24462/176931
                         sr.ctipres, TO_CHAR(d_perini, 'mm') mes_pag,
                         TO_CHAR(d_perini, 'yyyy') anyo_pag, si.sseguro sseg, si.nriesgo nrie,
                         TO_CHAR(si.fsinies, 'mm') mes_sin,
                         TO_CHAR(si.fsinies, 'yyyy') anyo_sin, si.ncuacoa ncua,
                         sr.cgarant cgar, s.cramo cramo, 0 ctippag,
                         NVL(sr.ireserva, 0) + NVL(sr.ipago, 0) ireserva,
                         NVL(sr.ireserva_moncia, 0) + NVL(sr.ipago_moncia, 0) ireserva_moncia,
                         s.ctipcoa, sr.cmonres, sr.fcambio, s.sproduc, s.ccompani ccompapr,
                         DECODE(sr.ctipres, 1, 25, 2, 26, 3, 27, 4, 28, 25) vcimporte,
                         sr.ctipgas ctipgas
                    FROM sin_siniestro si, seguros s, sin_tramita_reserva sr
                   WHERE si.sseguro = s.sseguro
                     AND NVL(s.ctipcoa, 0) IN(1, 2, 8, 9)
                     AND si.fnotifi >= d_perini
                     AND si.fnotifi <= d_perfin
                     AND s.cempres = pcempres
                     AND si.nsinies = sr.nsinies
                     AND(NVL(ipago, 0) = 0
                         OR sr.sidepag IN(SELECT sidepag
                                            FROM sin_tramita_movpago stm
                                           WHERE stm.sidepag = sr.sidepag
                                             AND stm.cestpag IN(0, 1, 9)
                                             AND stm.nmovpag IN(
                                                               SELECT MAX(nmovpag)
                                                                 FROM sin_tramita_movpago stm2
                                                                WHERE stm.sidepag =
                                                                                   stm2.sidepag)))
                     AND sr.nmovres IN(SELECT MAX(nmovres)
                                         FROM sin_tramita_reserva ss
                                        WHERE ss.nsinies = sr.nsinies
                                          AND sr.ntramit = ss.ntramit
                                          AND ss.ctipres = sr.ctipres
                                          AND TRUNC(ss.fmovres) <= d_perfin)
                GROUP BY si.nsinies, si.fsinies, si.fnotifi, sr.ctipres,
                         TO_CHAR(d_perfin, 'mm'), TO_CHAR(d_perfin, 'yyyy'), si.sseguro,
                         si.nriesgo, TO_CHAR(si.fsinies, 'mm'), TO_CHAR(si.fsinies, 'yyyy'),
                         si.ncuacoa, sr.cgarant, s.cramo,
                         NVL(sr.ireserva, 0) + NVL(sr.ipago, 0),
                         NVL(sr.ireserva_moncia, 0) + NVL(sr.ipago_moncia, 0), s.ctipcoa,
                         sr.cmonres, sr.fcambio, s.sproduc, s.ccompani, ctipgas,
                         sidepag   -- 20/06/2014 EDA Bug 24462/176931
                ORDER BY nsin, mes_pag, anyo_pag, sidepag;

      CURSOR c3(pc_seg IN NUMBER, pc_cua IN NUMBER) IS
         SELECT ccompan, pcescoa
           FROM coacedido
          WHERE sseguro = pc_seg
            AND ncuacoa = pc_cua;

      CURSOR c4 IS
         SELECT *
           FROM ctacoaseguroaux
          WHERE cmovimi = v_cmovimi;
   BEGIN
      vpas := 100;
      d_perini := TO_DATE('01/' || TO_CHAR(pmes) || '/' || TO_CHAR(pany), 'dd/mm/yyyy');
      vpas := 110;
      d_perfin := LAST_DAY(TO_DATE(TO_CHAR(pmes) || '/' || TO_CHAR(pany), 'mm/yyyy'));
      vpas := 120;

      FOR f2 IN c2 LOOP
         -- 20/06/2014 EDA Bug 24462/176931
         IF f2.sidepag IS NOT NULL THEN
            SELECT DECODE(stm.cestpag, 0, 0, 1)
              INTO v_cestado
              FROM sin_tramita_movpago stm
             WHERE stm.sidepag = f2.sidepag
               AND stm.nmovpag IN(SELECT MAX(nmovpag)
                                    FROM sin_tramita_movpago stm2
                                   WHERE stm.sidepag = stm2.sidepag);
         ELSE
            v_cestado := 1;
         END IF;

         -- 20/06/2014 EDA Bug 24462/176931 Los siniestros pendientes no se realiza la cesión de reservas de siniestros para el Coaseguro
         IF v_cestado = 1 THEN
            -- buscamos el signo
            vpas := 130;

            IF f2.ctipcoa IN(1, 2) THEN
               xsigno := 2;   -- cedido (haber)
            ELSIF f2.ctipcoa IN(8, 9) THEN
               xsigno := 1;   -- aceptado (debe)
            END IF;

            vpas := 140;

            FOR f3 IN c3(f2.sseg, f2.ncua) LOOP
               -- buscamos el importe a grabar en la cuenta
               IF f2.ctipcoa IN(1, 2) THEN   -- cedido
                  vpas := 150;
                  vnmoneda := pac_monedas.f_cmoneda_n(f2.cmonres);
                  vpas := 160;
                  perror := f_importecoa(f2.sseg, f2.ncua, f2.ireserva, f3.ccompan,
                                         f3.pcescoa, vnmoneda, ximporte);
                  vpas := 170;
                  perror := f_importecoa(f2.sseg, f2.ncua, f2.ireserva_moncia, f3.ccompan,
                                         f3.pcescoa, vnmoneda, ximporte_moncia);
               ELSIF f2.ctipcoa IN(8, 9) THEN   -- aceptado
                  vpas := 180;
                  ximporte := f2.ireserva;
                  ximporte_moncia := f2.ireserva_moncia;
               END IF;

               IF perror <> 0 THEN
                  psql := SQLERRM;
                  psmovcoa := f2.sseg;
                  RAISE e_salida;
               END IF;

               vpas := 190;

               IF ximporte >= 0 THEN
                  v_cdebhab := 1;
               ELSE
                  v_cdebhab := 2;
                  ximporte := ximporte * -1;
                  ximporte_moncia := ximporte_moncia * -1;
               END IF;

               BEGIN
                  vpas := 200;

-- 23830 AVT 08/11/2012 afegim la ccompapr
                  INSERT INTO ctacoaseguroaux
                              (ccompani, cimport, ctipcoa, cmovimi, imovimi,
                               fmovimi, fcontab, cdebhab, fliqcia, pcescoa, sidepag, nrecibo,
                               smovrec, cempres, sseguro, sproduc, imovimi_moncon,
                               fcambio,
                                       -- nsinies, cestado, ccompapr, ctipgas)
                                       nsinies, cestado, ccompapr, ctipgas, fcierre)   -- BUG 0025357/0138513 - FAL - 19/02/2013
                       VALUES (f3.ccompan, f2.vcimporte, f2.ctipcoa, v_cmovimi, ximporte,
                               d_perfin, NULL, v_cdebhab, NULL, f3.pcescoa, NULL, NULL,
                               NULL, pcempres, f2.sseg, f2.sproduc, ximporte_moncia,
                               f2.fcambio,
                                          -- f2.nsin, 4, f2.ccompapr, f2.ctipgas);   --> NO EXISTENT PER QUE NO ES PUGUI LIQUIDAR
                                          f2.nsin, 4, f2.ccompapr, f2.ctipgas, d_perfin);   --> NO EXISTENT PER QUE NO ES PUGUI LIQUIDAR      -- BUG 0025357/0138513 - FAL - 19/02/2013
               EXCEPTION
                  WHEN OTHERS THEN
                     perror := 108168;
                     psql := SQLERRM;
                     psmovcoa := f2.sseg;
                     RAISE e_salida;
               END;
            END LOOP;
         END IF;   -- 20/06/2014 EDA Bug 24462/176931
      END LOOP;

      vpas := 210;

      IF perror = 0
         AND pdefi = 2 THEN
         vpas := 220;

         FOR f4 IN c4 LOOP
            vpas := 230;

            SELECT smovcoa.NEXTVAL
              INTO w_smovcoa
              FROM DUAL;

            BEGIN
               vpas := 240;

-- 23830 AVT 08/11/2012 afegim la ccompapr
               INSERT INTO ctacoaseguro
                           (smovcoa, ccompani, cimport, ctipcoa, cmovimi,
                            imovimi, fmovimi, fcontab, cdebhab, fliqcia,
                            pcescoa, sidepag, nrecibo, smovrec, cempres,
                            sseguro, sproduc, imovimi_moncon, fcambio,
                            -- nsinies, cestado, ccompapr, ctipgas)
                            nsinies, cestado, ccompapr, ctipgas, fcierre)   -- BUG 0025357/0138513 - FAL - 19/02/2013
                    VALUES (w_smovcoa, f4.ccompani, f4.cimport, f4.ctipcoa, f4.cmovimi,
                            f4.imovimi, f4.fmovimi, f4.fcontab, f4.cdebhab, f4.fliqcia,
                            f4.pcescoa, f4.sidepag, f4.nrecibo, f4.smovrec, f4.cempres,
                            f4.sseguro, f4.sproduc, f4.imovimi_moncon, f4.fcambio,
                            -- f4.nsinies, f4.cestado, f4.ccompapr, f4.ctipgas);
                            f4.nsinies, f4.cestado, f4.ccompapr, f4.ctipgas, f4.fcierre);   -- BUG 0025357/0138513 - FAL - 19/02/2013
            EXCEPTION
               WHEN OTHERS THEN
                  perror := 105578;
                  psql := SQLERRM;
                  psmovcoa := f4.sseguro;
                  RAISE e_salida;
            END;
         END LOOP;
      END IF;

      RETURN(perror);
   EXCEPTION
      WHEN e_salida THEN
         IF c4%ISOPEN THEN
            CLOSE c4;
         END IF;

         IF c3%ISOPEN THEN
            CLOSE c3;
         END IF;

         IF c2%ISOPEN THEN
            CLOSE c2;
         END IF;

         p_tab_error(f_sysdate, f_user, vobj, vpas, vpar,
                     perror || ' ' || NVL(psql, SQLCODE || ' ' || SQLERRM));
         RETURN(perror);
   END f_reservas_sin;

-- *********************************************************
   FUNCTION cierre_coaseguro(
      pcempres IN NUMBER,
      pdefi IN NUMBER,
      pmes IN NUMBER,
      pany IN NUMBER,
      pproces IN NUMBER,
      psql OUT VARCHAR2,
      psmovcoa OUT NUMBER)
      RETURN NUMBER IS
   -- Bug 0023188 - 23/08/2012 - JMF
/*
   ************************************************************************
   CIERRE DE COASEGURO
   ************************************************************************
*/
      n_error        NUMBER := 0;
      n_smovcoa      NUMBER;
      v_psql         VARCHAR2(500);
   BEGIN
      n_error := pac_coaseguro.f_actualizacion_saldos(pcempres, pdefi, pmes, pany, pproces,
                                                      v_psql, n_smovcoa);

      IF n_error = 0
         AND NVL(pac_parametros.f_parempresa_n(pcempres, 'RESERVA_ONLINE'), 0) = 0 THEN
         n_error := pac_coaseguro.f_reservas_sin(pcempres, pdefi, pmes, pany, pproces, v_psql,
                                                 n_smovcoa);
      END IF;

      RETURN(n_error);
   END cierre_coaseguro;
END pac_coaseguro;

/

  GRANT EXECUTE ON "AXIS"."PAC_COASEGURO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_COASEGURO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_COASEGURO" TO "PROGRAMADORESCSI";
