--------------------------------------------------------
--  DDL for Package Body PAC_REMUNERACION_CANAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_REMUNERACION_CANAL" AS
   /******************************************************************************
      NOMBRE:      PAC_REMUNERACION_CANAL
      PROPÓSITO:   Contiene las funciones de cierre de la remuneracion del canal

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        15/11/2011   DRA               1. 0019347: LCOL_C002 - Proceso de cierre de remuneración al canal
      2.0        17/01/2012   DRA               2. 0020967: LCOL - Carga de empleados y representantes.
      3.0        06/02/2012   DRA               3. 0021109: LCOL: Remuneración al Canal
      4.0        07/03/2012   DRA               4. 0021604: LCOL: Ajuste del proceso de remuneración al canal
      5.0        22/05/2015   OZEA              5. : LCOL:
   ******************************************************************************/
   FUNCTION f_obtener_sperson(psseguro IN NUMBER)
      RETURN sys_refcursor IS
      --
      v_object       VARCHAR2(500) := 'PAC_REMUNERACION_CANAL.f_obtener_sperson';
      v_param        VARCHAR2(500) := 'psseguro : ' || psseguro;
      v_pasexec      NUMBER(5) := 1;
      v_numerr       NUMBER := 0;
      v_squery       VARCHAR2(4000);
      cur            sys_refcursor;
   BEGIN
      -- Promotor
      v_squery := 'SELECT cpromotor sperson, 1 ctipper FROM seguros WHERE sseguro = '
                  || psseguro || ' AND cpromotor IS NOT NULL';
      -- Coordinador
      v_squery :=
         v_squery
         || ' UNION ALL SELECT r.spercoord sperson, 6 ctipper FROM representantes r, seguros s '
         || ' WHERE s.sseguro = ' || psseguro
         || ' AND s.cpromotor IS NOT NULL AND r.sperson = s.cpromotor AND r.spercoord IS NOT NULL';
      -- GESTOR
      v_squery := v_squery || ' UNION ALL SELECT DISTINCT e.sperson, 2 ctipper '
                  || ' FROM productos_empleados pe, empleados e,'
                  || ' tipo_empleados te, seguros s, pregunpolseg ps1, pregunpolseg ps2'
                  || ' WHERE s.sseguro = ' || psseguro
                  || ' AND ps1.sseguro = s.sseguro AND ps1.cpregun = 9008'
                  || ' AND ps2.sseguro = s.sseguro AND ps2.cpregun = 9006'
                  || ' AND pe.cageint = s.cagente AND pe.sproduc = s.sproduc'
                  || ' AND te.sperson = pe.sperson AND te.csegmento = ps1.crespue'
                  || ' AND e.sperson = pe.sperson AND e.ccanal = ps2.crespue'
                  || ' AND e.ctipo = 1';
      -- VICEPRESIDENTE, GERENTE, DIRECTOR
      v_squery := v_squery || ' UNION ALL SELECT DISTINCT e.sperson, '
                  || ' DECODE (e.ccargo, 1, 3, 2, 4, 3, 5, e.ccargo) ctipper '
                  || ' FROM productos_empleados pe, empleados e,'
                  || ' tipo_empleados te, seguros s, pregunpolseg ps1, pregunpolseg ps2'
                  || ' WHERE s.sseguro = ' || psseguro
                  || ' AND ps1.sseguro = s.sseguro AND ps1.cpregun = 9008'
                  || ' AND ps2.sseguro = s.sseguro AND ps2.cpregun = 9006'
                  || ' AND pe.cageint = s.cagente AND pe.sproduc = s.sproduc'
                  || ' AND te.sperson = pe.sperson AND te.csegmento = ps1.crespue'
                  || ' AND e.sperson = pe.sperson AND e.ccanal = ps2.crespue'
                  || ' AND e.ctipo = 2 AND e.ccargo IN (1, 2, 3)';
      cur := pac_listvalores.f_opencursor(v_squery);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
         RETURN NULL;
   END f_obtener_sperson;

   FUNCTION f_cierre_remun_pol(
      psproces IN NUMBER,
      psremcanal IN NUMBER,
      pmodo IN NUMBER,
      pcempres IN NUMBER,
      pmoneda IN NUMBER,
      pcidioma IN NUMBER,
      pfperini IN DATE,
      pfperfin IN DATE,
      pfcierre IN DATE)
      RETURN NUMBER IS
      --
      v_object       VARCHAR2(500) := 'PAC_REMUNERACION_CANAL.f_cierre_remun_pol';
      v_param        VARCHAR2(500)
         := 'psproces : ' || psproces || ', psremcanal : ' || psremcanal || ', pmodo : '
            || pmodo || ', pcempres : ' || pcempres || ', pmoneda : ' || pmoneda
            || ', pcidioma : ' || pcidioma || ', pfperini : ' || pfperini || ', pfperfin : '
            || pfperfin || ' , pfcierre : ' || pfcierre;
      v_pasexec      NUMBER;
      v_numerr       NUMBER := 0;
      v_sperson      NUMBER;
      v_ctipper      NUMBER;
      refcur         sys_refcursor;
      v_cmonemp      NUMBER := pac_parametros.f_parempresa_n(pcempres, 'MONEDAEMP');
      v_iprinet      NUMBER;
      v_fechacmb     DATE;
      v_importe      NUMBER;

      CURSOR c_pol IS
         -- Pólizas nuevas
         SELECT   s.sseguro, s.sproduc, 1 ctipo, MAX(NVL(m.femisio, s.femisio)) femisio
             FROM seguros s, movseguro m
            WHERE s.cempres = pcempres
              AND m.sseguro = s.sseguro
              AND m.cmotmov = 100   --> (100.-Nueva Produccion)
              AND TRUNC(GREATEST(m.femisio, m.fefecto)) BETWEEN pfperini AND pfperfin
              AND f_vigente(s.sseguro, NULL, pfperfin) = 0   --Para pólizas vigentes
         GROUP BY s.sseguro, s.sproduc, 3
         UNION ALL
         -- Pólizas renovadas
         SELECT   s.sseguro, s.sproduc, 2 ctipo, MAX(m.femisio) femisio
             FROM seguros s, movseguro m
            WHERE s.cempres = pcempres
              AND m.sseguro = s.sseguro
              AND m.cmotmov IN
                    (404, 406, 407)   --> (404.-Renovacion de Cartera, 406. -Movimiento aniversario 407.-Renovacion anual)
              AND TRUNC(GREATEST(m.femisio, m.fefecto)) BETWEEN pfperini AND pfperfin
              AND TO_DATE(LPAD(s.nrenova, 4, '0') || TO_CHAR(m.fefecto, 'YYYY'), 'MMDDYYYY')
                    BETWEEN pfperini
                        AND pfperfin
              AND f_vigente(s.sseguro, NULL, pfperfin) = 0   --Para pólizas vigentes
         GROUP BY s.sseguro, s.sproduc, 3;
   BEGIN
      FOR cur IN c_pol LOOP
         v_iprinet := NULL;
         v_pasexec := cur.sseguro;
         -- Calculamos el importe en la moneda
         v_fechacmb :=
            pac_eco_tipocambio.f_fecha_max_cambio
                         (pac_monedas.f_cmoneda_t(pac_monedas.f_moneda_producto(cur.sproduc)),
                          pac_monedas.f_cmoneda_t(v_cmonemp), cur.femisio);

         SELECT SUM((NVL(g.iprianu, 0) + NVL(g.irecarg, 0)) * NVL(r.nasegur, 1))
           INTO v_importe
           FROM riesgos r, garanseg g
          WHERE g.sseguro = cur.sseguro
            AND g.finiefe <= pfperfin
            AND r.nriesgo = g.nriesgo
            AND r.sseguro = g.sseguro
            AND(r.fanulac IS NULL
                OR r.fanulac > pfperfin)
            AND(g.ffinefe > pfperfin
                OR g.ffinefe IS NULL);

         v_iprinet :=
            pac_eco_tipocambio.f_importe_cambio
                          (pac_monedas.f_cmoneda_t(pac_monedas.f_moneda_producto(cur.sproduc)),
                           pac_monedas.f_cmoneda_t(v_cmonemp), v_fechacmb, v_importe);
         -- Obtenemos la lista de representantes del promotor
         refcur := f_obtener_sperson(cur.sseguro);

         FETCH refcur
          INTO v_sperson, v_ctipper;

         WHILE refcur%FOUND LOOP
            INSERT INTO remuneracion_canal_pol
                        (sremcanal, sseguro, cageprom, sproces, ctipo, importe,
                         ctipper)
                 VALUES (psremcanal, cur.sseguro, v_sperson, psproces, cur.ctipo, v_iprinet,
                         v_ctipper);

            FETCH refcur
             INTO v_sperson, v_ctipper;
         END LOOP;

         CLOSE refcur;
      END LOOP;

      RETURN v_numerr;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
         RETURN 9002056;
   END f_cierre_remun_pol;

   FUNCTION f_cierre_remun_rec(
      psproces IN NUMBER,
      psremcanal IN NUMBER,
      pmodo IN NUMBER,
      pcempres IN NUMBER,
      pmoneda IN NUMBER,
      pcidioma IN NUMBER,
      pfperini IN DATE,
      pfperfin IN DATE,
      pfcierre IN DATE)
      RETURN NUMBER IS
      --
      v_object       VARCHAR2(500) := 'PAC_REMUNERACION_CANAL.f_cierre_remun_rec';
      v_param        VARCHAR2(500)
         := 'psproces : ' || psproces || ', psremcanal : ' || psremcanal || ', pmodo : '
            || pmodo || ', pcempres : ' || pcempres || ', pmoneda : ' || pmoneda
            || ', pcidioma : ' || pcidioma || ', pfperini : ' || pfperini || ', pfperfin : '
            || pfperfin || ' , pfcierre : ' || pfcierre;
      v_pasexec      NUMBER;
      v_numerr       NUMBER := 0;
      v_sperson      NUMBER;
      v_ctipper      NUMBER;
      refcur         sys_refcursor;

      CURSOR c_rec IS
         -- Primas emitidas
         SELECT r.nrecibo, s.sseguro,
                DECODE(r.ctiprec, 9, -1, 1) *(d.iprinet + d.irecfra) iprinet, NULL itotalr,
                1 ctipo
           FROM recibos r, vdetrecibos_monpol d, seguros s, movrecibo m
          WHERE r.cempres = pcempres
            AND r.nrecibo = d.nrecibo
            AND r.ctiprec IN(0, 1, 3, 4, 9)   --> (detvalores = 8)
            AND s.sseguro = r.sseguro
            AND f_vigente(s.sseguro, NULL, pfperfin) = 0   --Para pólizas vigentes
            AND m.nrecibo = r.nrecibo
            AND m.cestrec = 0
            AND m.cestant = 0
            AND((r.ctiprec = 0   -- BUG21604:DRA:07/03/2012
                 AND TRUNC(GREATEST(r.femisio, m.fmovini)) BETWEEN pfperini AND pfperfin)
                OR(r.ctiprec <> 0
                   AND TRUNC(r.fefecto) BETWEEN pfperini AND pfperfin))
         UNION ALL
         -- Primas por cobrar > 90 días
         SELECT DISTINCT r.nrecibo, s.sseguro, d.iprinet, NULL itotalr, 2 ctipo
                    FROM recibos r, movrecibo m, vdetrecibos_monpol d, seguros s
                   WHERE r.cempres = pcempres
                     AND r.nrecibo = d.nrecibo
                     AND r.nrecibo = m.nrecibo
                     AND m.cestrec = 0   --> (0 .- pendiente)
                     AND m.fmovfin IS NULL
                     AND(pfperfin - r.fefecto) >= 90
                     AND s.sseguro = r.sseguro
         UNION ALL
         -- Primas por cobrar > 180 días
         SELECT DISTINCT r.nrecibo, s.sseguro, d.iprinet, NULL itotalr, 3 ctipo
                    FROM recibos r, movrecibo m, vdetrecibos_monpol d, seguros s
                   WHERE r.cempres = pcempres
                     AND r.nrecibo = d.nrecibo
                     AND r.nrecibo = m.nrecibo
                     AND m.cestrec = 0   --> (0 .- pendiente)
                     AND m.fmovfin IS NULL
                     AND(pfperfin - r.fefecto) >= 180
                     AND s.sseguro = r.sseguro
         UNION ALL
         -- Tiempos corridos
         /*SELECT DISTINCT r.nrecibo, s.sseguro, d.iprinet, NULL itotalr, 4 ctipo
                    FROM recibos r, movrecibo m, seguros s, movseguro ms, vdetrecibos_monpol d
                   WHERE r.cempres = pcempres
                     AND r.nrecibo = d.nrecibo
                     AND r.nrecibo = m.nrecibo
                     AND r.sseguro = s.sseguro
                     AND s.sseguro = ms.sseguro
                     AND ms.cmovseg = 3
                     AND ms.cmotmov = 321   --> ('Anulación póliza por impago')
                     AND ms.nmovimi = (SELECT MAX(ms2.nmovimi)
                                         FROM movseguro ms2
                                        WHERE ms2.sseguro = ms.sseguro)
                     AND m.cestrec = 0
                     AND m.fmovfin IS NULL
                     --AND TRUNC(r.fefecto) BETWEEN pfperini AND pfperfin
                     AND TO_NUMBER(TO_CHAR(r.fefecto, 'YYYY'))
                           BETWEEN TO_NUMBER(TO_CHAR(pfperini, 'YYYY'))
                               AND TO_NUMBER(TO_CHAR(pfperfin, 'YYYY'))
         UNION ALL
         -- Retenedores de primas
         SELECT r.nrecibo, s.sseguro, NULL iprinet, d.itotalr, 5 ctipo
           FROM recibos r, vdetrecibos_monpol d, seguros s
          WHERE r.cempres = pcempres
            AND r.nrecibo = d.nrecibo
            AND r.ctiprec = 0   --> (0.-produccion (detvalores = 8))
            -- AND TRUNC(r.fefecto) BETWEEN pfperini AND pfperfin
            AND TO_NUMBER(TO_CHAR(r.fefecto, 'YYYY')) BETWEEN TO_NUMBER(TO_CHAR(pfperini,
                                                                                'YYYY'))
                                                          AND TO_NUMBER(TO_CHAR(pfperfin,
                                                                                'YYYY'))
            AND s.sseguro = r.sseguro
         UNION ALL
         -- Cartera castigada
         SELECT DISTINCT r.nrecibo, s.sseguro, d.iprinet, NULL itotalr, 6 ctipo
                    FROM recibos r, movrecibo m, vdetrecibos_monpol d, seguros s
                   WHERE r.cempres = pcempres
                     AND r.nrecibo = d.nrecibo
                     AND r.nrecibo = m.nrecibo
                     AND m.cestrec = 0   --> (0 .- pendiente)
                     AND m.fmovini IS NULL
                     AND r.ctiprec = 0   --> (0.-produccion (detvalores = 8))
                     --AND TRUNC(r.fefecto) BETWEEN pfperini AND pfperfin
                     AND TO_NUMBER(TO_CHAR(r.fefecto, 'YYYY'))
                           BETWEEN TO_NUMBER(TO_CHAR(pfperini, 'YYYY'))
                               AND TO_NUMBER(TO_CHAR(pfperfin, 'YYYY'))
                     AND s.sseguro = r.sseguro
         UNION ALL*/
         -- Cartera negativa > 90 días
         SELECT DISTINCT r.nrecibo, s.sseguro, d.iprinet, NULL itotalr, 7 ctipo
                    FROM recibos r, vdetrecibos_monpol d, movseguro m, seguros s
                   WHERE r.cempres = pcempres
                     AND r.nrecibo = d.nrecibo
                     AND r.ctiprec = 9   --> (9.-extorno (detvalores = 8))
                     AND(pfperfin - r.fefecto) >= 90
                     AND m.sseguro = r.sseguro
                     AND m.nmovimi = r.nmovimi
                     AND m.cmovseg = 1   --> (V.F. 16 = Suplemento)
                     AND s.sseguro = r.sseguro
         UNION ALL
         -- Cartera negativa > 180 días
         SELECT DISTINCT r.nrecibo, s.sseguro, d.iprinet, NULL itotalr, 8 ctipo
                    FROM recibos r, vdetrecibos_monpol d, movseguro m, seguros s
                   WHERE r.cempres = pcempres
                     AND r.nrecibo = d.nrecibo
                     AND r.ctiprec = 9   --> (9.-extorno (detvalores = 8))
                     AND(pfperfin - r.fefecto) >= 180
                     AND m.sseguro = r.sseguro
                     AND m.nmovimi = r.nmovimi
                     AND m.cmovseg = 1   --> (V.F. 16 = Suplemento)
                     AND s.sseguro = r.sseguro
         UNION ALL
         -- Primas cedidas
         SELECT r.nrecibo, s.sseguro, DECODE(r.ctiprec, 9, -1, 1) * d.icednet iprinet,
                NULL itotalr, 9 ctipo
           FROM recibos r, vdetrecibos_monpol d, seguros s, movrecibo m
          WHERE r.cempres = pcempres
            AND r.nrecibo = d.nrecibo
            AND r.ctiprec IN(0, 1, 3, 4, 9)   --> (detvalores = 8)
            AND NVL(d.icednet, 0) > 0
            AND s.sseguro = r.sseguro
            AND m.nrecibo = r.nrecibo
            AND m.cestrec = 0
            AND m.cestant = 0
            AND((r.ctiprec = 0   -- BUG21604:DRA:07/03/2012
                 AND TRUNC(GREATEST(r.femisio, m.fmovini)) BETWEEN pfperini AND pfperfin)
                OR(r.ctiprec <> 0
                   AND TRUNC(r.fefecto) BETWEEN pfperini AND pfperfin))
         UNION ALL
         -- Primas recaudadas
         SELECT DISTINCT r.nrecibo, s.sseguro, d.iprinet, NULL itotalr, 10 ctipo
                    FROM recibos r, movrecibo m, vdetrecibos_monpol d, seguros s
                   WHERE r.cempres = pcempres
                     AND r.nrecibo = d.nrecibo
                     AND r.nrecibo = m.nrecibo
                     AND m.cestrec IN(1, 3)   --> (1.-Cobrado, 3.-Remesado)
                     AND TRUNC(m.fcontab) BETWEEN pfperini AND pfperfin
                     AND m.fcontab = (SELECT MAX(m2.fcontab)
                                        FROM movrecibo m2
                                       WHERE m2.nrecibo = m.nrecibo)
                     AND s.sseguro = r.sseguro;
   BEGIN
      FOR cur IN c_rec LOOP
         v_pasexec := cur.nrecibo;
         -- Obtenemos la lista de representantes del promotor
         refcur := f_obtener_sperson(cur.sseguro);

         FETCH refcur
          INTO v_sperson, v_ctipper;

         WHILE refcur%FOUND LOOP
            INSERT INTO remuneracion_canal_rec
                        (sremcanal, nrecibo, ctipo, sproces, iprinet,
                         itotalr, cageprom, ctipper)
                 VALUES (psremcanal, cur.nrecibo, cur.ctipo, psproces, cur.iprinet,
                         cur.itotalr, v_sperson, v_ctipper);

            FETCH refcur
             INTO v_sperson, v_ctipper;
         END LOOP;

         CLOSE refcur;
      END LOOP;

      RETURN v_numerr;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
         RETURN 9001250;
   END f_cierre_remun_rec;

   FUNCTION f_cierre_remun_sin(
      psproces IN NUMBER,
      psremcanal IN NUMBER,
      pmodo IN NUMBER,
      pcempres IN NUMBER,
      pmoneda IN NUMBER,
      pcidioma IN NUMBER,
      pfperini IN DATE,
      pfperfin IN DATE,
      pfcierre IN DATE)
      RETURN NUMBER IS
      --
      v_object       VARCHAR2(500) := 'PAC_REMUNERACION_CANAL.f_cierre_remun_sin';
      v_param        VARCHAR2(500)
         := 'psproces : ' || psproces || ', psremcanal : ' || psremcanal || ', pmodo : '
            || pmodo || ', pcempres : ' || pcempres || ', pmoneda : ' || pmoneda
            || ', pcidioma : ' || pcidioma || ', pfperini : ' || pfperini || ', pfperfin : '
            || pfperfin || ' , pfcierre : ' || pfcierre;
      v_pasexec      NUMBER;
      v_numerr       NUMBER := 0;
      v_sperson      NUMBER;
      v_ctipper      NUMBER;
      refcur         sys_refcursor;

      CURSOR c_sin IS
         SELECT   nsinies, sseguro, SUM(NVL(iimpsin, 0)) iimpsin, SUM(NVL(lae, 0)) lae,
                  SUM(NVL(ipridev, 0)) ipridev
             FROM (
                   -- Prima devengada de Siniestros incurridos
                   /*SELECT ss.nsinies, s.sseguro,
                          0 iimpsin, 0 lae, v.ipridev
                     FROM sin_siniestro ss, sin_tramitacion st, sin_tramita_reserva str,
                          recibos r, vdetrecibos_monpol v, seguros s
                    WHERE st.nsinies = ss.nsinies
                      AND str.nsinies = st.nsinies
                      AND str.ntramit = st.ntramit
                      AND TRUNC(str.fmovres) BETWEEN pfperini AND pfperfin
                      AND str.ctipres = 1
                      AND str.nmovres = (SELECT MAX(str1.nmovres)
                                           FROM sin_tramita_reserva str1
                                          WHERE str1.nsinies = str.nsinies
                                            AND str1.ntramit = str.ntramit
                                            AND str1.ctipres = str.ctipres)
                      AND r.sseguro = ss.sseguro
                      AND v.nrecibo(+) = r.nrecibo
                      AND s.sseguro = ss.sseguro
                      AND s.cempres = pcempres
                   UNION ALL*/
                   -- Siniestros incurridos
                   SELECT ss.nsinies, s.sseguro,
                          (NVL(str.ireserva_moncia, 0) + NVL(str.ipago_moncia, 0)
                           - NVL(str.irecobro_moncia, 0)) iimpsin,
                          0 lae, 0 ipridev
                     FROM sin_siniestro ss, sin_tramitacion st, sin_tramita_reserva str,
                          seguros s
                    WHERE st.nsinies = ss.nsinies
                      AND str.nsinies = st.nsinies
                      AND str.ntramit = st.ntramit
                      AND TRUNC(str.fmovres) BETWEEN pfperini AND pfperfin
                      AND str.ctipres = 1
                      AND str.nmovres = (SELECT MAX(str1.nmovres)
                                           FROM sin_tramita_reserva str1
                                          WHERE str1.nsinies = str.nsinies
                                            AND str1.ntramit = str.ntramit
                                            AND str1.ctipres = str.ctipres)
                      AND s.sseguro = ss.sseguro
                      AND s.cempres = pcempres
                   UNION ALL
                   -- Siniestros de Gastos
                   SELECT ss.nsinies, s.sseguro, 0 iimpsin, str.ireserva_moncia lae, 0 ipridev
                     FROM sin_siniestro ss, sin_tramitacion st, sin_tramita_reserva str,
                          seguros s
                    WHERE st.nsinies = ss.nsinies
                      AND str.nsinies = st.nsinies
                      AND str.ntramit = st.ntramit
                      AND TRUNC(str.fmovres) BETWEEN pfperini AND pfperfin
                      AND str.ctipres = 3
                      AND str.nmovres = (SELECT MAX(str1.nmovres)
                                           FROM sin_tramita_reserva str1
                                          WHERE str1.nsinies = str.nsinies
                                            AND str1.ntramit = str.ntramit
                                            AND str1.ctipres = str.ctipres)
                      AND s.sseguro = ss.sseguro
                      AND s.cempres = pcempres)
         GROUP BY nsinies, sseguro;
   BEGIN
      FOR cur IN c_sin LOOP
         v_pasexec := cur.nsinies;
         -- Obtenemos la lista de representantes del promotor
         refcur := f_obtener_sperson(cur.sseguro);

         FETCH refcur
          INTO v_sperson, v_ctipper;

         WHILE refcur%FOUND LOOP
            INSERT INTO remuneracion_canal_sin
                        (sremcanal, nsinies, sproces, iimpsin, lae,
                         ipridev, cageprom, ctipper)
                 VALUES (psremcanal, cur.nsinies, psproces, cur.iimpsin, cur.lae,
                         cur.ipridev, v_sperson, v_ctipper);

            FETCH refcur
             INTO v_sperson, v_ctipper;
         END LOOP;

         CLOSE refcur;
      END LOOP;

      RETURN v_numerr;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
         RETURN 108129;
   END f_cierre_remun_sin;

   FUNCTION f_cierre_remun_canal(
      psproces IN NUMBER,
      psremcanal IN NUMBER,
      pmodo IN NUMBER,
      pcempres IN NUMBER,
      pmoneda IN NUMBER,
      pcidioma IN NUMBER,
      pfperini IN DATE,
      pfperfin IN DATE,
      pfcierre IN DATE,
      pfproces IN DATE)
      RETURN NUMBER IS
      --
      v_object       VARCHAR2(500) := 'PAC_REMUNERACION_CANAL.f_cierre_remun_canal';
      v_param        VARCHAR2(500)
         := 'psproces : ' || psproces || ', psremcanal : ' || psremcanal || ', pmodo : '
            || pmodo || ', pcempres : ' || pcempres || ', pmoneda : ' || pmoneda
            || ', pcidioma : ' || pcidioma || ', pfperini : ' || pfperini || ', pfperfin : '
            || pfperfin || ' , pfcierre : ' || pfcierre;
      v_pasexec      NUMBER(5) := 1;
      v_numerr       NUMBER := 0;
      v_ttipper      VARCHAR2(100);

      CURSOR c_ageprom IS
         SELECT DISTINCT r.cageprom, r.ctipper, s.cramo
                    FROM remuneracion_canal_pol r, seguros s
                   WHERE r.sremcanal = psremcanal
                     AND s.sseguro = r.sseguro
         UNION
         SELECT DISTINCT r.cageprom, r.ctipper, s.cramo
                    FROM remuneracion_canal_rec r, seguros s, recibos rec
                   WHERE r.sremcanal = psremcanal
                     AND rec.nrecibo = r.nrecibo
                     AND s.sseguro = rec.sseguro
         UNION
         SELECT DISTINCT r.cageprom, r.ctipper, s.cramo
                    FROM remuneracion_canal_sin r, seguros s, sin_siniestro ss
                   WHERE r.sremcanal = psremcanal
                     AND ss.nsinies = r.nsinies
                     AND s.sseguro = ss.sseguro;

      v_cramo        codiram.cramo%TYPE;
      v_ipriemi      NUMBER;
      v_icartera90   NUMBER;
      v_icartera180  NUMBER;
      v_psinies      NUMBER;
      v_icrepriemi   NUMBER;
      v_icreprinet   NUMBER;
      v_npolnew      NUMBER;
      v_ipolnew      NUMBER;
      v_npolren      NUMBER;
      v_ipolren      NUMBER;
      v_iprirecaud   NUMBER;
      v_icrepriemi_ant NUMBER;
      v_icreprinet_ant NUMBER;
      v_iprinet      NUMBER;
      v_iimpsin      NUMBER;
      v_lae          NUMBER;
      v_ipridev      NUMBER;
      v_ipri90       NUMBER;
      v_ipri180      NUMBER;
      v_itmpcor      NUMBER;
      v_iretpri      NUMBER;
      v_icarctg      NUMBER;
      v_ictneg90     NUMBER;
      v_ictneg180    NUMBER;
      v_icstxl       NUMBER;
   BEGIN
      v_pasexec := 1;

      FOR pol IN c_ageprom LOOP
         v_ipriemi := NULL;
         v_icartera90 := NULL;
         v_icartera180 := NULL;
         v_psinies := NULL;
         v_icrepriemi := NULL;
         v_icreprinet := NULL;
         v_npolnew := NULL;
         v_ipolnew := NULL;
         v_npolren := NULL;
         v_ipolren := NULL;
         v_iprirecaud := NULL;
         v_icrepriemi_ant := NULL;
         v_icreprinet_ant := NULL;
         v_iprinet := NULL;
         v_iimpsin := NULL;
         v_lae := NULL;
         v_ipridev := NULL;
         v_ipri90 := NULL;
         v_ipri180 := NULL;
         v_itmpcor := NULL;
         v_iretpri := NULL;
         v_icarctg := NULL;
         v_ictneg90 := NULL;
         v_ictneg180 := NULL;
         v_icstxl := NULL;
         -- Primas emitidas: El valor se registrará en el campo IPRIEMI.
         v_pasexec := 2;

         BEGIN
            SELECT   s.cramo, SUM(NVL(r.iprinet, 0))
                INTO v_cramo, v_ipriemi
                FROM remuneracion_canal_rec r, recibos rec, seguros s
               WHERE r.sremcanal = psremcanal
                 AND r.ctipo = 1
                 AND r.cageprom = pol.cageprom
                 AND r.ctipper = pol.ctipper
                 AND rec.nrecibo = r.nrecibo
                 AND s.sseguro = rec.sseguro
                 AND s.cramo = pol.cramo
            GROUP BY s.cramo;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_ipriemi := NULL;
         END;

         v_pasexec := 3;

         -- Indice de cartera > 90 días: El valor se registrará en el campo ICARTERA90.
         BEGIN
            SELECT   s.cramo, SUM(NVL(r.iprinet, 0)) + SUM(NVL(r.itotalr, 0))
                INTO v_cramo, v_icartera90
                FROM remuneracion_canal_rec r, recibos rec, seguros s
               WHERE r.sremcanal = psremcanal
                 AND r.ctipo IN(2, 4, 5, 6, 7)
                 AND r.cageprom = pol.cageprom
                 AND r.ctipper = pol.ctipper
                 AND rec.nrecibo = r.nrecibo
                 AND s.sseguro = rec.sseguro
                 AND s.cramo = pol.cramo
            GROUP BY s.cramo;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_icartera90 := NULL;
         END;

         v_pasexec := 31;

         -- Prima > 90 días
         BEGIN
            SELECT   s.cramo, SUM(NVL(r.iprinet, 0))
                INTO v_cramo, v_ipri90
                FROM remuneracion_canal_rec r, recibos rec, seguros s
               WHERE r.sremcanal = psremcanal
                 AND r.ctipo = 2
                 AND r.cageprom = pol.cageprom
                 AND r.ctipper = pol.ctipper
                 AND rec.nrecibo = r.nrecibo
                 AND s.sseguro = rec.sseguro
                 AND s.cramo = pol.cramo
            GROUP BY s.cramo;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_ipri90 := NULL;
         END;

         v_pasexec := 4;

         -- Indice de cartera > 180 días: El valor se registrará en el campo ICARTERA180.
         BEGIN
            SELECT   s.cramo, SUM(NVL(r.iprinet, 0)) + SUM(NVL(r.itotalr, 0))
                INTO v_cramo, v_icartera180
                FROM remuneracion_canal_rec r, recibos rec, seguros s
               WHERE r.sremcanal = psremcanal
                 AND r.ctipo IN(3, 4, 5, 6, 8)
                 AND r.cageprom = pol.cageprom
                 AND r.ctipper = pol.ctipper
                 AND rec.nrecibo = r.nrecibo
                 AND s.sseguro = rec.sseguro
                 AND s.cramo = pol.cramo
            GROUP BY s.cramo;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_icartera180 := NULL;
         END;

         v_pasexec := 41;

         -- Prima > 180 días
         BEGIN
            SELECT   s.cramo, SUM(NVL(r.iprinet, 0))
                INTO v_cramo, v_ipri180
                FROM remuneracion_canal_rec r, recibos rec, seguros s
               WHERE r.sremcanal = psremcanal
                 AND r.ctipo = 3
                 AND r.cageprom = pol.cageprom
                 AND r.ctipper = pol.ctipper
                 AND rec.nrecibo = r.nrecibo
                 AND s.sseguro = rec.sseguro
                 AND s.cramo = pol.cramo
            GROUP BY s.cramo;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_ipri180 := NULL;
         END;

         v_pasexec := 42;

         -- Prima Tiempos Corridos
         BEGIN
            SELECT   s.cramo, SUM(NVL(r.iprinet, 0))
                INTO v_cramo, v_itmpcor
                FROM remuneracion_canal_rec r, recibos rec, seguros s
               WHERE r.sremcanal = psremcanal
                 AND r.ctipo = 4
                 AND r.cageprom = pol.cageprom
                 AND r.ctipper = pol.ctipper
                 AND rec.nrecibo = r.nrecibo
                 AND s.sseguro = rec.sseguro
                 AND s.cramo = pol.cramo
            GROUP BY s.cramo;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_itmpcor := NULL;
         END;

         v_pasexec := 43;

         -- Prima Retenedores de Prima
         BEGIN
            SELECT   s.cramo, SUM(NVL(r.itotalr, 0))
                INTO v_cramo, v_iretpri
                FROM remuneracion_canal_rec r, recibos rec, seguros s
               WHERE r.sremcanal = psremcanal
                 AND r.ctipo = 5
                 AND r.cageprom = pol.cageprom
                 AND r.ctipper = pol.ctipper
                 AND rec.nrecibo = r.nrecibo
                 AND s.sseguro = rec.sseguro
                 AND s.cramo = pol.cramo
            GROUP BY s.cramo;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_iretpri := NULL;
         END;

         v_pasexec := 44;

         -- Cartera Castigada
         BEGIN
            SELECT   s.cramo, SUM(NVL(r.iprinet, 0))
                INTO v_cramo, v_icarctg
                FROM remuneracion_canal_rec r, recibos rec, seguros s
               WHERE r.sremcanal = psremcanal
                 AND r.ctipo = 6
                 AND r.cageprom = pol.cageprom
                 AND r.ctipper = pol.ctipper
                 AND rec.nrecibo = r.nrecibo
                 AND s.sseguro = rec.sseguro
                 AND s.cramo = pol.cramo
            GROUP BY s.cramo;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_icarctg := NULL;
         END;

         v_pasexec := 45;

         -- Cartera Negativa > 90 dias
         BEGIN
            SELECT   s.cramo, SUM(NVL(r.iprinet, 0))
                INTO v_cramo, v_ictneg90
                FROM remuneracion_canal_rec r, recibos rec, seguros s
               WHERE r.sremcanal = psremcanal
                 AND r.ctipo = 7
                 AND r.cageprom = pol.cageprom
                 AND r.ctipper = pol.ctipper
                 AND rec.nrecibo = r.nrecibo
                 AND s.sseguro = rec.sseguro
                 AND s.cramo = pol.cramo
            GROUP BY s.cramo;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_ictneg90 := NULL;
         END;

         v_pasexec := 46;

         -- Cartera Negativa > 90 dias
         BEGIN
            SELECT   s.cramo, SUM(NVL(r.iprinet, 0))
                INTO v_cramo, v_ictneg180
                FROM remuneracion_canal_rec r, recibos rec, seguros s
               WHERE r.sremcanal = psremcanal
                 AND r.ctipo = 8
                 AND r.cageprom = pol.cageprom
                 AND r.ctipper = pol.ctipper
                 AND rec.nrecibo = r.nrecibo
                 AND s.sseguro = rec.sseguro
                 AND s.cramo = pol.cramo
            GROUP BY s.cramo;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_ictneg180 := NULL;
         END;

         v_pasexec := 5;

         -- Siniestralidad: El valor se registrará en el campo PSINIES.
         BEGIN
            SELECT   s.cramo, SUM(NVL(r.iimpsin, 0)), SUM(NVL(r.lae, 0)),
                     SUM(NVL(r.ipridev, 0))
                INTO v_cramo, v_iimpsin, v_lae,
                     v_ipridev
                FROM remuneracion_canal_sin r, sin_siniestro ss, seguros s
               WHERE r.sremcanal = psremcanal
                 AND r.cageprom = pol.cageprom
                 AND r.ctipper = pol.ctipper
                 AND ss.nsinies = r.nsinies
                 AND s.sseguro = ss.sseguro
                 AND s.cramo = pol.cramo
            GROUP BY s.cramo;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_iimpsin := NULL;
               v_lae := NULL;
               v_ipridev := NULL;
         END;

         v_pasexec := 7;

         -- Crecimiento prima neta: El valor se registrará en el campo ICREPRINET.
         BEGIN
            SELECT   s.cramo, SUM(NVL(r.iprinet, 0) - NVL(r_ced.iprinet, 0))
                INTO v_cramo, v_iprinet
                FROM remuneracion_canal_rec r, recibos rec, seguros s,
                     remuneracion_canal_rec r_ced
               WHERE r.sremcanal = psremcanal
                 AND r.ctipo = 1
                 AND r.cageprom = pol.cageprom
                 AND r.ctipper = pol.ctipper
                 AND rec.nrecibo = r.nrecibo
                 AND s.sseguro = rec.sseguro
                 AND s.cramo = pol.cramo
                 AND r_ced.sremcanal(+) = r.sremcanal
                 AND r_ced.nrecibo(+) = r.nrecibo
                 AND r_ced.ctipo(+) = 9
                 AND r_ced.cageprom(+) = r.cageprom
                 AND r_ced.ctipper(+) = r.ctipper
            GROUP BY s.cramo;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_iprinet := NULL;
         END;

         v_pasexec := 8;

         -- Número de pólizas nuevas:
         BEGIN
            SELECT   s.cramo, COUNT(DISTINCT r.sseguro)
                INTO v_cramo, v_npolnew
                FROM remuneracion_canal_pol r, seguros s
               WHERE r.sremcanal = psremcanal
                 AND r.ctipo = 1
                 AND r.cageprom = pol.cageprom
                 AND r.ctipper = pol.ctipper
                 AND s.sseguro = r.sseguro
                 AND s.cramo = pol.cramo
            GROUP BY s.cramo;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_npolnew := NULL;
         END;

         v_pasexec := 9;

         -- Valor de las pólizas nuevas:
         BEGIN
            SELECT   s.cramo, SUM(NVL(r.importe, 0))
                INTO v_cramo, v_ipolnew
                FROM remuneracion_canal_pol r, seguros s
               WHERE r.sremcanal = psremcanal
                 AND r.ctipo = 1
                 AND r.cageprom = pol.cageprom
                 AND r.ctipper = pol.ctipper
                 AND s.sseguro = r.sseguro
                 AND s.cramo = pol.cramo
            GROUP BY s.cramo;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_ipolnew := NULL;
         END;

         v_pasexec := 10;

         -- Número de pólizas renovadas:
         BEGIN
            SELECT   s.cramo, COUNT(DISTINCT r.sseguro)
                INTO v_cramo, v_npolren
                FROM remuneracion_canal_pol r, seguros s
               WHERE r.sremcanal = psremcanal
                 AND r.ctipo = 2
                 AND r.cageprom = pol.cageprom
                 AND r.ctipper = pol.ctipper
                 AND s.sseguro = r.sseguro
                 AND s.cramo = pol.cramo
            GROUP BY s.cramo;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_npolren := NULL;
         END;

         v_pasexec := 11;

         -- Valor de las pólizas renovadas:
         BEGIN
            SELECT   s.cramo, SUM(NVL(r.importe, 0))
                INTO v_cramo, v_ipolren
                FROM remuneracion_canal_pol r, seguros s
               WHERE r.sremcanal = psremcanal
                 AND r.ctipo = 2
                 AND r.cageprom = pol.cageprom
                 AND r.ctipper = pol.ctipper
                 AND s.sseguro = r.sseguro
                 AND s.cramo = pol.cramo
            GROUP BY s.cramo;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_ipolren := NULL;
         END;

         v_pasexec := 12;

         -- Primas recaudadas:
         BEGIN
            SELECT   s.cramo, SUM(NVL(r.iprinet, 0))
                INTO v_cramo, v_iprirecaud
                FROM remuneracion_canal_rec r, recibos rec, seguros s
               WHERE r.sremcanal = psremcanal
                 AND r.ctipo = 10
                 AND r.cageprom = pol.cageprom
                 AND r.ctipper = pol.ctipper
                 AND rec.nrecibo = r.nrecibo
                 AND s.sseguro = rec.sseguro
                 AND s.cramo = pol.cramo
            GROUP BY s.cramo;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_iprirecaud := NULL;
         END;

         v_pasexec := 121;

         IF pol.ctipper = 1 THEN
            v_ttipper := f_axis_literales(151522, pcidioma);
         ELSIF pol.ctipper = 2 THEN
            v_ttipper := f_axis_literales(1000566, pcidioma);
         ELSIF pol.ctipper = 3 THEN
            v_ttipper := f_axis_literales(9902722, pcidioma);
         ELSIF pol.ctipper = 4 THEN
            v_ttipper := f_axis_literales(9903208, pcidioma);
         ELSIF pol.ctipper = 5 THEN
            v_ttipper := f_axis_literales(9902721, pcidioma);
         ELSIF pol.ctipper = 6 THEN
            v_ttipper := f_axis_literales(9902626, pcidioma);
         END IF;

         v_pasexec := 13;

         BEGIN
            INSERT INTO remuneracion_canal
                        (sremcanal, cempres, cramo, sperson, fcierre, fperini,
                         fperfin, sproces, fproces, cmodo, ttipper, ipriemi,
                         iprinet, icartera90, icartera180, npolnew, ipolnew,
                         npolren, ipolren, iprirecaud, ctipper, iimpsin, igaslae,
                         ipridev, ipri90, ipri180, itmpcor, iretpri, icarctg,
                         ictneg90, ictneg180, icstxl)
                 VALUES (psremcanal, pcempres, pol.cramo, pol.cageprom, pfcierre, pfperini,
                         pfperfin, psproces, pfproces, pmodo, v_ttipper, v_ipriemi,
                         v_iprinet, v_icartera90, v_icartera180, v_npolnew, v_ipolnew,
                         v_npolren, v_ipolren, v_iprirecaud, pol.ctipper, v_iimpsin, v_lae,
                         v_ipridev, v_ipri90, v_ipri180, v_itmpcor, v_iretpri, v_icarctg,
                         v_ictneg90, v_ictneg180, v_icstxl);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               v_pasexec := 14;

               UPDATE remuneracion_canal
                  SET ipriemi = NVL(ipriemi, 0) + NVL(v_ipriemi, 0),
                      iprinet = NVL(iprinet, 0) + NVL(v_iprinet, 0),
                      icartera90 = NVL(icartera90, 0) + NVL(v_icartera90, 0),
                      icartera180 = NVL(icartera180, 0) + NVL(v_icartera180, 0),
                      npolnew = NVL(npolnew, 0) + NVL(v_npolnew, 0),
                      ipolnew = NVL(ipolnew, 0) + NVL(v_ipolnew, 0),
                      npolren = NVL(npolren, 0) + NVL(v_npolren, 0),
                      ipolren = NVL(ipolren, 0) + NVL(v_ipolren, 0),
                      iprirecaud = NVL(iprirecaud, 0) + NVL(v_iprirecaud, 0),
                      iimpsin = NVL(iimpsin, 0) + NVL(v_iimpsin, 0),
                      igaslae = NVL(igaslae, 0) + NVL(v_lae, 0),
                      ipridev = NVL(ipridev, 0) + NVL(v_ipridev, 0),
                      ipri90 = NVL(ipri90, 0) + NVL(v_ipri90, 0),
                      ipri180 = NVL(ipri180, 0) + NVL(v_ipri180, 0),
                      itmpcor = NVL(itmpcor, 0) + NVL(v_itmpcor, 0),
                      iretpri = NVL(iretpri, 0) + NVL(v_iretpri, 0),
                      icarctg = NVL(icarctg, 0) + NVL(v_icarctg, 0),
                      ictneg90 = NVL(ictneg90, 0) + NVL(v_ictneg90, 0),
                      ictneg180 = NVL(ictneg180, 0) + NVL(v_ictneg180, 0),
                      icstxl = NVL(icstxl, 0) + NVL(v_icstxl, 0)
                WHERE sremcanal = psremcanal
                  AND cempres = pcempres
                  AND cramo = pol.cramo
                  AND sperson = pol.cageprom
                  AND ctipper = pol.ctipper;
         END;

         v_pasexec := 15;
         -- Calculamos el porcentaje de siniestralidad
         /* BUG21109:DRA:22/02/2012: De momento lo comentamos hasta saber como calcular la prima devengada
         UPDATE remuneracion_canal
            SET psinies = (iimpsin + igaslae) / DECODE(ipridev, 0, 1, ipridev)
          WHERE sremcanal = psremcanal
            AND cempres = pcempres
            AND cramo = pol.cramo
            AND sperson = pol.cageprom
            AND ctipper = pol.ctipper;*/
         v_pasexec := 16;

         -- Crecimiento prima emitida: El valor se registrará en el campo ICREPRIEMI.
         -- Crecimiento prima neta: El valor se registrará en el campo ICREPRINET.
         BEGIN
            SELECT NVL(rc.ipriemi, 0), NVL(rc.iprinet, 0)
              INTO v_icrepriemi_ant, v_icreprinet_ant
              FROM remuneracion_canal rc
             WHERE rc.cramo = pol.cramo
               AND rc.sperson = pol.cageprom
               AND rc.ctipper = pol.ctipper
               AND rc.cempres = pcempres
               AND rc.cmodo = 2
               AND rc.fperfin = ADD_MONTHS(pfperfin, -12);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_icrepriemi_ant := NULL;   -- Para que salga cero en la resta
               v_icrepriemi_ant := NULL;   -- Para que salga cero en la resta
         END;

         v_pasexec := 17;

         -- Crecimiento prima emitida: El valor se registrará en el campo ICREPRIEMI.
         IF v_icrepriemi_ant <> 0 THEN
            v_icrepriemi := ROUND(((v_ipriemi - NVL(v_icrepriemi_ant, v_ipriemi))
                                   / ABS(NVL(v_icrepriemi_ant, 1)))
                                  * 100,
                                  2);
         END IF;

         v_pasexec := 18;

         -- Crecimiento prima neta: El valor se registrará en el campo ICREPRINET.
         IF v_icreprinet_ant <> 0 THEN
            v_icreprinet := ROUND(((v_iprinet - NVL(v_icreprinet_ant, v_iprinet))
                                   / ABS(NVL(v_icreprinet_ant, v_iprinet)))
                                  * 100,
                                  2);
         END IF;

         v_pasexec := 19;

         UPDATE remuneracion_canal
            SET icrepriemi = v_icrepriemi,
                icreprinet = v_icreprinet
          WHERE sremcanal = psremcanal
            AND cempres = pcempres
            AND cramo = pol.cramo
            AND sperson = pol.cageprom
            AND ctipper = pol.ctipper;
      END LOOP;

      RETURN v_numerr;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
         RETURN 108129;
   END f_cierre_remun_canal;

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
      --
      --    Proceso que lanzará el proceso de cierre de la remuneración del canal
      --
      num_err        NUMBER := 0;
      text_error     VARCHAR2(500) := 0;
      pnnumlin       NUMBER;
      texto          VARCHAR2(400);
      conta_err      NUMBER := 0;
      v_titulo       VARCHAR2(50);
      verror         NUMBER;
      v_sremcanal    NUMBER;
   BEGIN
      IF pmodo = 1 THEN
         v_titulo := 'Proceso Cierre Remuneración Canal - Previo';
      ELSE
         v_titulo := 'Proceso Cierre Remuneración Canal ';
      END IF;

      num_err := f_procesini(f_user, pcempres, 'CIERRE_REMUN_CANAL', v_titulo, psproces);
      pfproces := f_sysdate;

      IF num_err <> 0 THEN
         pcerror := 1;
         conta_err := conta_err + 1;
         texto := f_axis_literales(num_err, pcidioma);
         pnnumlin := NULL;
         num_err := f_proceslin(psproces,
                                SUBSTR('Remuneración Canal: ' || texto || ' ' || text_error,
                                       1, 120),
                                0, pnnumlin);
      ELSE
         pcerror := 0;

         -- Borrado de los registros que se corresponden al año y empresa que vamos a tratar
         BEGIN
            DELETE FROM remuneracion_canal_pol
                  WHERE sremcanal IN(SELECT sremcanal
                                       FROM remuneracion_canal
                                      WHERE TO_CHAR(fperfin, 'MMYYYY') =
                                                                   TO_CHAR(pfperfin, 'MMYYYY')
                                        AND cempres = pcempres);

            DELETE FROM remuneracion_canal_rec
                  WHERE sremcanal IN(SELECT sremcanal
                                       FROM remuneracion_canal
                                      WHERE TO_CHAR(fperfin, 'MMYYYY') =
                                                                    TO_CHAR(pfperfin, 'MMYYYY')
                                        AND cempres = pcempres);

            DELETE FROM remuneracion_canal_sin
                  WHERE sremcanal IN(SELECT sremcanal
                                       FROM remuneracion_canal
                                      WHERE TO_CHAR(fperfin, 'MMYYYY') =
                                                                    TO_CHAR(pfperfin, 'MMYYYY')
                                        AND cempres = pcempres);

            DELETE FROM remuneracion_canal
                  WHERE TO_CHAR(fperfin, 'MMYYYY') = TO_CHAR(pfperfin, 'MMYYYY')
                    AND cempres = pcempres;

            COMMIT;
         EXCEPTION
            WHEN OTHERS THEN
               pcerror := 1;
               p_tab_error(f_sysdate, f_user, 'REMUNERACION CANAL =' || psproces, NULL,
                           'when others del delete del cierre =' || pfperfin, SQLERRM);
         END;

         -- Obtenemos el identificador
         SELECT sremcanal.NEXTVAL
           INTO v_sremcanal
           FROM DUAL;

         -- Desde aqui vamos a lanzar todos los cierres.
         -- Inserción de la tabla REMUNERACION_CANAL_POL
         verror := pac_remuneracion_canal.f_cierre_remun_pol(psproces, v_sremcanal, pmodo,
                                                             pcempres, pmoneda, pcidioma,
                                                             pfperini, pfperfin, pfcierre);

         IF verror <> 0 THEN
            -- Apuntem linea de error a PROCESOSLIN
            conta_err := conta_err + 1;
            pcerror := 1;
            pnnumlin := NULL;
            num_err :=
               f_proceslin(psproces,
                           SUBSTR('Remuneración Canal Polizas: Proceso no finalizado.', 1,
                                  120),
                           0, pnnumlin);
         END IF;

         -- Inserción de la tabla REMUNERACION_CANAL_REC
         verror := pac_remuneracion_canal.f_cierre_remun_rec(psproces, v_sremcanal, pmodo,
                                                             pcempres, pmoneda, pcidioma,
                                                             pfperini, pfperfin, pfcierre);

         IF verror <> 0 THEN
            -- Apuntem linea de error a PROCESOSLIN
            conta_err := conta_err + 1;
            pcerror := 1;
            pnnumlin := NULL;
            num_err :=
               f_proceslin(psproces,
                           SUBSTR('Remuneración Canal Recibos: Proceso no finalizado', 1, 120),
                           0, pnnumlin);
         END IF;

         -- Inserción de la tabla REMUNERACION_CANAL_SIN
         verror := pac_remuneracion_canal.f_cierre_remun_sin(psproces, v_sremcanal, pmodo,
                                                             pcempres, pmoneda, pcidioma,
                                                             pfperini, pfperfin, pfcierre);

         IF verror <> 0 THEN
            -- Apuntem linea de error a PROCESOSLIN
            conta_err := conta_err + 1;
            pcerror := 1;
            pnnumlin := NULL;
            num_err :=
               f_proceslin(psproces,
                           SUBSTR('Remuneración Canal Siniestros: Proceso no finalizado', 1,
                                  120),
                           0, pnnumlin);
         END IF;

         IF conta_err = 0 THEN
            -- Inserción de la tabla REMUNERACION_CANAL
            verror := pac_remuneracion_canal.f_cierre_remun_canal(psproces, v_sremcanal,
                                                                  pmodo, pcempres, pmoneda,
                                                                  pcidioma, pfperini,
                                                                  pfperfin, pfcierre,
                                                                  pfproces);

            IF verror <> 0 THEN
               -- Apuntem linea de error a PROCESOSLIN
               conta_err := conta_err + 1;
               pcerror := 1;
               pnnumlin := NULL;
               num_err :=
                  f_proceslin(psproces,
                              SUBSTR('Remuneración Canal Resumen: Proceso no finalizado', 1,
                                     120),
                              0, pnnumlin);
            END IF;
         END IF;
      END IF;

      num_err := f_procesfin(psproces, conta_err);
      COMMIT;
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, 'REMUNERACIÓN CANAL =' || psproces, NULL,
                     'when others del cierre =' || pfperfin, SQLERRM);
         pcerror := 1;
   END proceso_batch_cierre;
END pac_remuneracion_canal;

/

  GRANT EXECUTE ON "AXIS"."PAC_REMUNERACION_CANAL" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_REMUNERACION_CANAL" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_REMUNERACION_CANAL" TO "PROGRAMADORESCSI";
