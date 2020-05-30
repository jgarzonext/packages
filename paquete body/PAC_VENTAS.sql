--------------------------------------------------------
--  DDL for Package Body PAC_VENTAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_VENTAS" IS
/********************************
  Variables globales del package
 ********************************/
   vg_nmesven     NUMBER;
   vg_nanyven     NUMBER;

/********************************************************************************************
 Proceso batch diario que calcula las ventas desde el último mes cerrado proceso de cierre
*********************************************************************************************/
   FUNCTION fecha_calculo(
      pcempres IN NUMBER,
      pmodo IN NUMBER,
      pfcierre OUT DATE,
      pnmesven OUT NUMBER,
      pnanyven OUT NUMBER)
      RETURN NUMBER IS
/********************************************************************************************
 Devuelve el mes y año para el cual hay que calcular las ventas de cada empresa.
        pmodo = 1 ==> Proceso diario, por lo tanto, será el mes siguiente al último cierre
                      que tenemos en HISVENTAS
        pmodo = 2 ==> Cierre definitivo, por lo tanto, será el último cierre
                      que tenemos en CIERRES para el ctipo = 1(Cierres de Ventas).
        pmodo = 3 ==> Simulación cierre, por lo tanto, será el mes siguiente al último cierre
                      que tenemos en HISVENTAS
*********************************************************************************************/
      num_err        NUMBER := 0;
   BEGIN
      IF pmodo IN(1, 3) THEN
         SELECT MAX(fperfin), TO_NUMBER(TO_CHAR(MAX(fperfin), 'mm')),
                TO_NUMBER(TO_CHAR(MAX(fperfin), 'yyyy'))
           INTO pfcierre, pnmesven,
                pnanyven
           FROM cierres
          WHERE ctipo = 1
            AND cempres = pcempres
            AND cestado = 0;

         IF pfcierre IS NULL THEN
            SELECT ADD_MONTHS(MAX(fcierre), 1), TO_NUMBER(TO_CHAR(MAX(fcierre) + 1, 'mm')),
                   TO_NUMBER(TO_CHAR(MAX(fcierre) + 1, 'yyyy'))
              INTO pfcierre, pnmesven,
                   pnanyven
              FROM hisventas
             WHERE cempres = pcempres;
         END IF;

--  Si el histórico está vacío lo inicializaremos en el año 2000
         IF pfcierre IS NULL THEN
            pfcierre := TO_DATE('31/01/2000', 'dd/mm/yyyy');
            pnmesven := 1;
            pnanyven := 2000;
         END IF;
      ELSIF pmodo = 2 THEN
         SELECT MAX(fperfin), TO_NUMBER(TO_CHAR(MAX(fperfin), 'mm')),
                TO_NUMBER(TO_CHAR(MAX(fperfin), 'yyyy'))
           INTO pfcierre, pnmesven,
                pnanyven
           FROM cierres
          WHERE ctipo = 1
            AND cempres = pcempres;
      END IF;

      RETURN num_err;
   EXCEPTION
      WHEN OTHERS THEN
         num_err := 105511;   -- Error de lectura en CIERRES
         RETURN num_err;
   END fecha_calculo;

----------------------------------------------------------------------------------------------
   FUNCTION venta_generada(
      pmodo IN NUMBER,
      pcempres IN NUMBER,
      pnmesven IN NUMBER,
      pnanyven IN NUMBER,
      psproces IN NUMBER,
      pfcierre IN DATE,
      pfcalcul IN DATE,
      pmoneda IN NUMBER,
      text_error OUT VARCHAR2)
      RETURN NUMBER IS
/*********************************************************************************************
   En este proceso se calculan las ventas generadas, sin anulaciones, es decir,
   ventas de nueva producción, suplementos(pueden ser extornos), cartera y aportaciones
   extraordinarias.
**********************************************************************************************/
      num_err        NUMBER := 0;
      text_error1    VARCHAR2(150);
-- Para poder ejecutar la instruccion 'INSERT'
      v_cursor       INTEGER;
      v_insertventas VARCHAR2(40);
      v_insertventasaux VARCHAR2(40);
      v_restoinsert  VARCHAR2(32000);
      v_numrows      INTEGER;
   BEGIN
      text_error1 := '- FUNCION VENTAS_GENERADAS - ';

      -- Con este insert conseguimos saber todos los movimientos de seguro que tienen venta en
      -- los meses que nos interesan
      BEGIN
         INSERT INTO movventas
                     (sseguro, pdtoord, nanyven, nmesven, nmovimi, sproces, cramo, cmodali,
                      ctipseg, ccolect, cactivi, npoliza, ncertif, cagente, cagrpro, ctiprea,
                      ctipcoa, cempres)
            (SELECT m.sseguro, NVL(s.pdtoord, 0), m.nanyven, m.nmesven, nmovimi, psproces,
                    s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.cactivi, s.npoliza, s.ncertif,
                    s.cagente, s.cagrpro, s.ctiprea, s.ctipcoa, s.cempres
               FROM movseguro m, seguros s
              WHERE s.cempres = pcempres
                AND s.sseguro = m.sseguro
                AND m.cmovseg <> 3
                AND m.nmesven >= DECODE(m.nanyven, pnanyven, pnmesven, 1)
                AND m.nanyven >= pnanyven);
      EXCEPTION
         WHEN OTHERS THEN
            num_err := 108012;   -- Error al insertar en la tabla MOVVENTAS
            text_error := text_error1 || SQLERRM || '  ' || SQLCODE;
      END;

      -- Para cada movimiento seleccionamos todos los recibos que 'cuelgan' de ese movimiento
      -- Grabamos también cagente y cdelega, aunque serán los agentes a la fecha de cálculo de
      -- la venta. Para los listados se hará siempre join con la tabla SEGUREDCOM
      IF num_err = 0 THEN
         BEGIN
            -- Para poder ejecutar la instruccion 'INSERT' de forma dinámica
            v_cursor := DBMS_SQL.open_cursor;
            v_insertventas := 'INSERT INTO VENTAS ';
            v_insertventasaux := 'INSERT INTO VENTASAUX ';
            v_restoinsert :=
               '
           (sseguro, nriesgo, cgarant, nmovimi, nanyven, nmesven, sproces,
            fcierre, fcalcul, cempres, cramo,   cmodali, ctipseg, ccolect, cactivi,
            npoliza, ncertif, cagente, cagrpro, ctiprea, ctipcoa,
            inovpro,
            ianureb_npac,ianupol_npac,ianureb_npan,ianupol_npan,
            isuplem,
            icartera,
            ianureb_carac,ianupol_carac,ianureb_caran,ianupol_caran,
            iaportex,
            iextorn,
            icomnp,
            iretnp,
            icomanureb_npac, iretanureb_npac, icomanureb_npan, iretanureb_npan,
            icomanupol_npac, iretanupol_npac, icomanupol_npan, iretanupol_npan,
            icomsup,
            iretsup,
            icomcar,
            iretcar,
            icomanureb_carac, iretanureb_carac, icomanureb_caran, iretanureb_caran,
            icomanupol_carac, iretanupol_carac, icomanupol_caran, iretanupol_caran,
            icomextorn,
            iretextorn,
            icomaport,
            iretaport)
      (SELECT mv.sseguro, nvl(d.nriesgo,1),nvl(d.cgarant,287),mv.nmovimi,mv.nanyven,mv.nmesven,:psproces,
            :pfcierre,:pfcalcul,r.cempres,mv.cramo,mv.cmodali,mv.ctipseg,mv.ccolect,mv.cactivi,
            mv.npoliza,mv.ncertif,mv.cagente,mv.cagrpro,mv.ctiprea,mv.ctipcoa,
            NVL(f_round(sum(decode(r.ctiprec,0,decode(cconcep,21,iconcep,0),0))
                           - (sum(decode(r.ctiprec,0,decode(cconcep,21,iconcep,0),0))
                                          *NVL(mv.pdtoord,0)/100)
                           + sum(decode(d.cgarant,189,decode(r.ctiprec,0,decode(cconcep,21,iconcep,0)
                                          *5/100,0),0)),
                           :pmoneda),0) inovpro,
            0,0,0,0,
            NVL(f_round(sum(decode(r.ctiprec,1,decode(cconcep,21,iconcep,0),0))
                           - (sum(decode(r.ctiprec,1,decode(cconcep,21,iconcep,0),0))
                                          *NVL(mv.pdtoord,0)/100)
                           + sum(decode(d.cgarant,189,decode(r.ctiprec,1,decode(cconcep,21,iconcep,0)
                                          *5/100,0),0)),
                           :pmoneda),0) isuplem,
            NVL(f_round(sum(decode(r.ctiprec,3,decode(cconcep,21,iconcep,0),0))
                           - (sum(decode(r.ctiprec,3,decode(cconcep,21,iconcep,0),0))
                                          *NVL(mv.pdtoord,0)/100)
                           + sum(decode(d.cgarant,189,decode(r.ctiprec,3,decode(cconcep,21,iconcep,0)
                                          *5/100,0),0)),
                           :pmoneda),0) icartera,
            0,0,0,0,
            NVL(f_round(sum(decode(r.ctiprec,4,decode(cconcep,21,iconcep,0),0)),
                          :pmoneda),0) iaporex,
            NVL(f_round(sum(decode(r.ctiprec,9,decode(cconcep,21,iconcep,0),0))
                           - (sum(decode(r.ctiprec,9,decode(cconcep,21,iconcep,0),0))
                                          *NVL(mv.pdtoord,0)/100)
                           + sum(decode(d.cgarant,189,decode(r.ctiprec,9,decode(cconcep,21,iconcep,0)
                                          *5/100,0),0)),
                           :pmoneda),0) iextorn,
            NVL(f_round(sum(decode(r.ctiprec,0,decode(cconcep,15,iconcep,0),0)),:pmoneda),0) icomnp,
            NVL(f_round(sum(decode(r.ctiprec,0,decode(cconcep,16,iconcep,0),0)),:pmoneda),0) iretnp,
            0,0,0,0,
            0,0,0,0,
            NVL(f_round(sum(decode(r.ctiprec,1,decode(cconcep,15,iconcep,0),0)),:pmoneda),0) icomsup,
            NVL(f_round(sum(decode(r.ctiprec,1,decode(cconcep,16,iconcep,0),0)),:pmoneda),0) iretsup,
            NVL(f_round(sum(decode(r.ctiprec,3,decode(cconcep,15,iconcep,0),0)),:pmoneda),0) icomcar,
            NVL(f_round(sum(decode(r.ctiprec,3,decode(cconcep,16,iconcep,0),0)),:pmoneda),0) iretcar,
            0,0,0,0,
            0,0,0,0,
            NVL(f_round(sum(decode(r.ctiprec,9,decode(cconcep,15,iconcep,0),0)),:pmoneda),0) icomextorn,
            NVL(f_round(sum(decode(r.ctiprec,9,decode(cconcep,16,iconcep,0),0)),:pmoneda),0) iretextorn,
            NVL(f_round(sum(decode(r.ctiprec,4,decode(cconcep,15,iconcep,0),0)),:pmoneda),0) icomaport,
            NVL(f_round(sum(decode(r.ctiprec,4,decode(cconcep,16,iconcep,0),0)),:pmoneda),0) iretaport
       FROM MOVVENTAS mv,DETRECIBOS d, RECIBOS r
      WHERE r.sseguro = mv.sseguro
        AND r.nmovimi = mv.nmovimi
        AND r.nrecibo = d.nrecibo
        AND d.cconcep in (15,16,21)
        AND mv.sproces = :psproces
        AND mv.cempres = :pcempres
      GROUP BY mv.sseguro, nvl(d.nriesgo,1),nvl(d.cgarant,287),mv.nmovimi,mv.nanyven,mv.nmesven,
               r.cempres,mv.cramo,mv.cmodali,mv.ctipseg,mv.ccolect,mv.cactivi,mv.npoliza,
               mv.ncertif, mv.cagente,mv.cagrpro,mv.ctiprea,mv.ctipcoa,mv.pdtoord
         )
         ';   --fin de la asignación de la variable v_RestoInsert

            IF pmodo IN(1, 2) THEN   -- si no es simulación
               DBMS_SQL.parse(v_cursor, v_insertventas || v_restoinsert, DBMS_SQL.native);
            ELSIF pmodo = 3 THEN
               DBMS_SQL.parse(v_cursor, v_insertventasaux || v_restoinsert, DBMS_SQL.native);
            END IF;

            DBMS_SQL.bind_variable(v_cursor, ':pfcierre', pfcierre);
            DBMS_SQL.bind_variable(v_cursor, ':pfcalcul', pfcalcul);
            DBMS_SQL.bind_variable(v_cursor, ':pmoneda', pmoneda);
            DBMS_SQL.bind_variable(v_cursor, ':psproces', psproces);
            DBMS_SQL.bind_variable(v_cursor, ':pcempres', pcempres);
            v_numrows := DBMS_SQL.EXECUTE(v_cursor);
            DBMS_SQL.close_cursor(v_cursor);
         EXCEPTION
            WHEN OTHERS THEN
               IF DBMS_SQL.is_open(v_cursor) THEN
                  DBMS_SQL.close_cursor(v_cursor);
               END IF;

               num_err := 104923;   -- Error al calcular las ventas
               text_error := text_error1 || SQLERRM || '  ' || SQLCODE;
         END;
      END IF;

      RETURN num_err;
   EXCEPTION
      WHEN OTHERS THEN
         num_err := 111111;
         text_error := text_error1 || SQLERRM;
         RETURN num_err;
   END venta_generada;

-----------------------------------------------------------------------------------------------
   FUNCTION fecha_venta_recibo(
      pnrecibo IN NUMBER,
      psseguro IN NUMBER,
      pctiprec IN NUMBER,
      pnmovimi IN NUMBER,
      rec_nmesven OUT NUMBER,
      rec_nanyven OUT NUMBER,
      text_error OUT VARCHAR2)
      RETURN NUMBER IS
/*********************************************************************************************
      Calculamos el año de la venta del movimiento al cual pertenece el recibo
      Podemos entrar por nº de recibo, o por sseguro, tipo de recibo y movimiento
**********************************************************************************************/
      v_sseguro      NUMBER;
      v_ctiprec      NUMBER;
      v_nmovimi      NUMBER;
      v_fefecto      DATE;
      num_err        NUMBER := 0;
   BEGIN
      IF pnrecibo IS NULL
         AND pctiprec IS NULL
         AND pnmovimi IS NULL
         AND psseguro IS NULL THEN
         num_err := 101901;   -- Paso incorrecto de parámetros a la función
         text_error := 'FECHA_VENTA_RECIBO';
      ELSE
         IF pnrecibo IS NOT NULL THEN
            BEGIN
               SELECT ctiprec, nmovimi, sseguro, fefecto
                 INTO v_ctiprec, v_nmovimi, v_sseguro, v_fefecto
                 FROM recibos
                WHERE nrecibo = pnrecibo;
            EXCEPTION
               WHEN OTHERS THEN
                  num_err := 101902;   -- Recibo no encontrado en la tabla recibos
                  text_error := 'función fecha_venta_recibo';
            END;
         ELSE
            v_ctiprec := pctiprec;
            v_nmovimi := pnmovimi;
            v_sseguro := psseguro;
         END IF;

         IF v_ctiprec IN(0, 3) THEN   -- si el recibo es de nueva prod. o cartera
            DECLARE
               CURSOR c_anyven(pc_sseguro IN NUMBER, pc_nmovimi IN NUMBER) IS
                  SELECT   nanyven, nmesven
                      FROM movseguro
                     WHERE sseguro = pc_sseguro
                       AND nmovimi <= pc_nmovimi
                       AND cmovseg IN(0, 2)
                       AND nanyven IS NOT NULL
                  ORDER BY nanyven DESC;
            BEGIN
               OPEN c_anyven(v_sseguro, v_nmovimi);

               FETCH c_anyven
                INTO rec_nanyven, rec_nmesven;

               CLOSE c_anyven;
            -- BUG -21546_108724- 08/02/2012 - JLTS - Cierre de posibles cursores abiertos, se adiciona EXCEPTION
            EXCEPTION
               WHEN OTHERS THEN
                  IF c_anyven%ISOPEN THEN
                     CLOSE c_anyven;
                  END IF;
            END;
         ELSE   -- si el recibo es de suplemento, aport. extr.
            BEGIN
               SELECT nanyven, nmesven
                 INTO rec_nanyven, rec_nmesven
                 FROM movseguro
                WHERE sseguro = v_sseguro
                  AND nmovimi = v_nmovimi;
            EXCEPTION
               WHEN OTHERS THEN
                  num_err := 104349;   -- Error al leer de la tabla MOVSEGURO
                  text_error := 'función fecha_venta_recibo';
            END;
         END IF;

-- Si no se encuentra la venta (por ser excesivamente antiguo) lo devolvemos según su fefecto
         IF rec_nmesven IS NULL THEN
            rec_nmesven := TO_CHAR(v_fefecto, 'mm');
            rec_nanyven := TO_CHAR(v_fefecto, 'yyyy');
         END IF;
      END IF;

      RETURN num_err;
   END fecha_venta_recibo;

----------------------------------------------------------------------------------------------
   FUNCTION anulaciones_recibos(
      pmodo IN NUMBER,
      pcempres IN NUMBER,
      pnmesven IN NUMBER,
      pnanyven IN NUMBER,
      psproces IN NUMBER,
      pfcierre IN DATE,
      pfperfin IN DATE,
      pfcalcul IN DATE,
      pmoneda IN NUMBER,
      text_error OUT VARCHAR2)
      RETURN NUMBER IS
/*********************************************************************************************
     Calcula las ventas anuladas que provienen de anulaciones de recibos
**********************************************************************************************/
      CURSOR c_recibos_anulados IS
         SELECT s.sseguro, s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.cactivi, s.npoliza,
                s.ncertif, s.nanuali, r.nmovimi, r.ctiprec, mvr.cmotmov, s.pdtoord, r.nrecibo,
                mvr.fmovdia, r.cempres, mvr.fmovini, r.cagente, s.cagrpro, s.ctiprea,
                s.ctipcoa, r.fefecto, r.fvencim
           FROM movrecibo mvr, recibos r, seguros s
          WHERE (mvr.fmovdia >= mvr.fmovini
                 AND mvr.fmovdia > pfcierre
                 OR mvr.fmovdia < mvr.fmovini
                    AND mvr.fmovini >= pfcierre)
            AND mvr.cestrec = 2
            AND mvr.fmovini <= pfcalcul
            AND(mvr.fmovfin > pfcalcul + 30
                OR mvr.fmovfin IS NULL)
            AND r.nrecibo = mvr.nrecibo
            AND r.cempres = pcempres
            AND s.sseguro = r.sseguro;

      CURSOR c_detrecibos(pc_nrecibo IN NUMBER, pc_ctiprec IN NUMBER) IS
         SELECT   nriesgo, cgarant,
                  SUM(DECODE(cconcep, 0, DECODE(pc_ctiprec, 9, -iconcep, iconcep), 0)) iprinet,
                  SUM(DECODE(cconcep, 21, DECODE(pc_ctiprec, 9, -iconcep, iconcep), 0))
                                                                                       ipridev,
                  SUM(DECODE(cconcep, 15, DECODE(pc_ctiprec, 9, -iconcep, iconcep), 0))
                                                                                       icomdev,
                  SUM(DECODE(cconcep, 16, DECODE(pc_ctiprec, 9, -iconcep, iconcep), 0))
                                                                                       iretdev,
                  SUM(DECODE(cconcep, 11, DECODE(pc_ctiprec, 9, -iconcep, iconcep), 0))
                                                                                       icombru,
                  SUM(DECODE(cconcep, 12, DECODE(pc_ctiprec, 9, -iconcep, iconcep), 0))
                                                                                       iretbru,
                  SUM(DECODE(cconcep, 13, DECODE(pc_ctiprec, 9, -iconcep, iconcep), 0)) idtoom,
                  SUM(DECODE(cconcep, 14, DECODE(pc_ctiprec, 9, -iconcep, iconcep), 0))
                                                                                       iderreg
             FROM detrecibos
            WHERE nrecibo = pc_nrecibo
         GROUP BY nriesgo, cgarant;

      v_peranul      NUMBER;
      v_mesanul      NUMBER;
      v_anyanul      NUMBER;
      v_nrecibo_ant  NUMBER := 0;
      rec_nmesven    NUMBER;
      rec_nanyven    NUMBER;
      anulacion      NUMBER;
      comi_anulada   NUMBER;
      reten_anulada  NUMBER;
      v_ianureb_npac NUMBER;
      v_ianureb_npan NUMBER;
      v_ianureb_carac NUMBER;
      v_ianureb_caran NUMBER;
      v_icomanureb_npac NUMBER;
      v_icomanureb_npan NUMBER;
      v_icomanureb_carac NUMBER;
      v_icomanureb_caran NUMBER;
      v_iretanureb_npac NUMBER;
      v_iretanureb_npan NUMBER;
      v_iretanureb_carac NUMBER;
      v_iretanureb_caran NUMBER;
      v_iderreg_dev  NUMBER;
      num_err        NUMBER := 0;
      text_error1    VARCHAR2(150);
      v_excact       NUMBER;
      v_excant       NUMBER;
      v_fcierre_excant_efe DATE;
      v_fcierre_excant_proc DATE;
      v_pe_excant    NUMBER;
      v_pe_excact    NUMBER;
      coefic         NUMBER;
      v_dtom_excant  NUMBER;
      v_derreg_excant NUMBER;
      v_comanul_excant NUMBER;
      v_retanul_excant NUMBER;
      v_dtom_excact  NUMBER;
      v_derreg_excact NUMBER;
      v_comanul_excact NUMBER;
      v_retanul_excact NUMBER;
      venta_excact   NUMBER;
      comi_excact    NUMBER;
      reten_excact   NUMBER;
      venta_excant   NUMBER;
      comi_excant    NUMBER;
      reten_excant   NUMBER;
   BEGIN
      FOR anul IN c_recibos_anulados LOOP
         -- Inicializamos todas las variables
         text_error1 := '- FUNCIÓN ANULACIÓN RECIBOS - recibo = ' || anul.nrecibo || ' ';
         v_peranul := 0;
         v_mesanul := 0;
         v_anyanul := 0;
         rec_nmesven := 0;
         rec_nanyven := 0;

         IF anul.nrecibo <> v_nrecibo_ant THEN
            v_peranul := f_perventa(NULL, anul.fmovdia, anul.fmovini, anul.cempres);
            v_anyanul := ROUND(v_peranul / 100);
            v_mesanul := v_peranul - ROUND(v_peranul / 100) * 100;
         END IF;

         IF ((v_anyanul = pnanyven
              AND v_mesanul >= pnmesven)
             OR v_anyanul > pnanyven) THEN   -- Venta en periodo
            -- Primero miramos la fecha de venta del movimiento del recibo(si es de cartera miramos la
            -- fecha de emisión), y entonces calculamos la fecha de cierre
            -- del ejercicio anterior a esa fecha.
            -- Si el recibo es del ejercicio actual, se prorratea la prima neta entre el ejercicio actual y
            -- el anterior(Ejemplo: ejer act = 2000 y ejer ant = 1999). Pero si el recibo es del ejercicio
            -- anterior (1999), se prorrateará entre el año 1999 y el año 1998, imputándose la venta del
            -- año 1998 al año 2000., y la del año 1999 al 1999.
            -- Calculamos la fecha de venta del recibo
            IF anul.ctiprec = 3 THEN   -- si es de cartera
               rec_nmesven := TO_CHAR(anul.fefecto, 'mm');
               rec_nanyven := TO_CHAR(anul.fefecto, 'yyyy');
            ELSE
               num_err := fecha_venta_recibo(anul.nrecibo, anul.sseguro, anul.ctiprec,
                                             anul.nmovimi, rec_nmesven, rec_nanyven,
                                             text_error);

               IF num_err <> 0 THEN
                  text_error := text_error1 || text_error || 'fechventa';
                  RETURN num_err;
               END IF;
            END IF;

            -- Calculamos cual es el ejercicio anterior, el ejercicio actual y
            -- la fecha de cierre del ejercicio anterior
            v_excact := rec_nanyven;
            v_excant := v_excact - 1;
            v_fcierre_excant_efe := TO_DATE('3112' || v_excant, 'ddmmyyyy');

            BEGIN
               SELECT fcierre
                 INTO v_fcierre_excant_proc
                 FROM cierres
                WHERE ctipo = 1
                  AND cestado = 1
                  AND cempres = pcempres
                  AND fperfin = TO_DATE('3112' || v_excant, 'ddmmyyyy');
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  v_fcierre_excant_proc := TO_DATE('3112' || v_excant, 'ddmmyyyy');
               WHEN OTHERS THEN
                  num_err := 111111;   -- Error al calcular la fecha de cierre del ejercicio anterior
                  text_error := text_error1 || SQLERRM || ' ' || SQLCODE || 'fechcierre'
                                || v_excant;
                  RETURN num_err;
            END;

            FOR det IN c_detrecibos(anul.nrecibo, anul.ctiprec) LOOP
               -- Si el cmotmov = 0, entonces la venta es la prima neta. Por lo tanto, tenemos que
               -- hacer el reparto entre el ejercicio anterior y el ejercicio actual
               IF anul.cmotmov = 0 THEN
                  -- Si el recibo es de cartera, tenemos que hacer el reparto
                  -- entre ejercicio anterior y actual. Si es de otro tipo (suplemento,
                  -- nueva producción,... la prima emitida siempre es del ejercicio actual
                  IF anul.ctiprec = 3 THEN
                     num_err := pac_ventascontab.f_pe_excant_gar(anul.sseguro, det.nriesgo,
                                                                 det.cgarant, anul.fefecto,
                                                                 anul.fvencim, v_excant,
                                                                 v_fcierre_excant_efe,
                                                                 v_fcierre_excant_proc,
                                                                 pmoneda, v_pe_excant);
                  ELSE
                     v_pe_excant := 0;   -- no hay prima emitida del ejercicio anterior
                  END IF;

                  IF num_err <> 0 THEN
                     text_error := text_error1 || 'f_pe_excant_gar';
                     RETURN num_err;
                  END IF;

                  IF v_pe_excant <> 0
                     AND det.iprinet <> 0 THEN
                     coefic := v_pe_excant / det.iprinet;
                     v_dtom_excant := det.idtoom * coefic;
                     v_derreg_excant := det.iderreg * coefic;
                     v_comanul_excant := det.icombru * coefic;
                     v_retanul_excant := det.iretbru * coefic;
                  ELSE
                     v_dtom_excant := 0;
                     v_derreg_excant := 0;
                     v_comanul_excant := 0;
                     v_retanul_excant := 0;
                  END IF;

                  v_pe_excact := det.iprinet - v_pe_excant;
                  v_dtom_excact := det.idtoom - v_dtom_excant;
                  v_derreg_excact := det.iderreg - v_derreg_excant;
                  v_comanul_excact := det.icombru - v_comanul_excant;
                  v_retanul_excact := det.iretbru - v_retanul_excant;
               END IF;

               -- Para cada registro de detrecibos calculamos el importe de la anulación, si es
               -- anulación de cartera y el año de la venta
               anulacion := 0;
               comi_anulada := 0;
               reten_anulada := 0;
               v_ianureb_npac := 0;
               v_ianureb_npan := 0;
               v_ianureb_carac := 0;
               v_ianureb_caran := 0;
               v_icomanureb_npac := 0;
               v_icomanureb_npan := 0;
               v_icomanureb_carac := 0;
               v_icomanureb_caran := 0;
               v_iretanureb_npac := 0;
               v_iretanureb_npan := 0;
               v_iretanureb_carac := 0;
               v_iretanureb_caran := 0;
               v_iderreg_dev := 0;

               IF anul.cmotmov = 0 THEN
                  venta_excact := v_pe_excact - v_dtom_excact + v_derreg_excact;
                  comi_excact := v_comanul_excact;
                  reten_excact := v_retanul_excact;
                  venta_excant := v_pe_excant - v_dtom_excant + v_derreg_excant;
                  comi_excant := v_comanul_excant;
                  reten_excant := v_retanul_excant;
               ELSIF anul.cmotmov = 1 THEN
                  IF det.iderreg <> 0 THEN
                     v_iderreg_dev := det.ipridev * 5 / 100;
                  ELSE
                     v_iderreg_dev := 0;
                  END IF;

                  venta_excact := NVL(f_round(det.ipridev
                                              -(det.ipridev * NVL(anul.pdtoord, 0) / 100)
                                              + v_iderreg_dev,
                                              pmoneda),
                                      0);
                  comi_excact := NVL(f_round(det.icomdev, pmoneda), 0);
                  reten_excact := NVL(f_round(det.iretdev, pmoneda), 0);
                  venta_excant := 0;
                  comi_excant := 0;
                  reten_excant := 0;
               ELSIF anul.cmotmov = 2 THEN
                  venta_excact := 0;
                  comi_excact := 0;
                  reten_excact := 0;
                  venta_excant := 0;
                  comi_excant := 0;
                  reten_excant := 0;
               END IF;

               -- Si la póliza a fecha de efecto del recibo ya ha pasado cartera, es una anulación
               -- de cartera, si no es una anulación de nueva producción.
               IF f_es_renova(anul.sseguro, anul.fefecto) = 1 THEN   -- todavía no ha pasado ninguna cartera,
                                                                     --  es nueva producción
                  IF v_excact = rec_nanyven THEN
                     v_ianureb_npac := venta_excact;
                     v_icomanureb_npac := comi_excact;
                     v_iretanureb_npac := reten_excact;
                     v_ianureb_npan := venta_excant;
                     v_icomanureb_npan := comi_excant;
                     v_iretanureb_npan := reten_excant;
                  ELSE
                     v_ianureb_npac := venta_excant;
                     v_icomanureb_npac := comi_excant;
                     v_iretanureb_npac := reten_excant;
                     v_ianureb_npan := venta_excact;
                     v_icomanureb_npan := comi_excact;
                     v_iretanureb_npan := reten_excact;
                  END IF;
               ELSE   -- póliza de cartera
                  IF v_excact = rec_nanyven THEN
                     v_ianureb_carac := venta_excact;
                     v_icomanureb_carac := comi_excact;
                     v_iretanureb_carac := reten_excact;
                     v_ianureb_caran := venta_excant;
                     v_icomanureb_caran := comi_excant;
                     v_iretanureb_caran := reten_excant;
                  ELSE
                     v_ianureb_carac := venta_excant;
                     v_icomanureb_carac := comi_excant;
                     v_iretanureb_carac := reten_excant;
                     v_ianureb_caran := venta_excact;
                     v_icomanureb_caran := comi_excact;
                     v_iretanureb_caran := reten_excact;
                  END IF;
               END IF;

               -- Grabamos en VENTAS si algun importe es distinto de cero
               IF v_ianureb_npac <> 0
                  OR v_ianureb_npan <> 0
                  OR v_icomanureb_npac <> 0
                  OR v_icomanureb_npan <> 0
                  OR v_iretanureb_npac <> 0
                  OR v_iretanureb_npan <> 0
                  OR v_ianureb_carac <> 0
                  OR v_ianureb_caran <> 0
                  OR v_icomanureb_carac <> 0
                  OR v_icomanureb_caran <> 0
                  OR v_iretanureb_carac <> 0
                  OR v_iretanureb_caran <> 0 THEN
                  IF pmodo IN(1, 2) THEN
                     BEGIN
                        INSERT INTO ventas
                                    (sseguro, nriesgo, cgarant, nmovimi,
                                     nanyven, nmesven, sproces, fcierre, fcalcul,
                                     cempres, cramo, cmodali, ctipseg,
                                     ccolect, cactivi, npoliza, ncertif,
                                     cagente, cagrpro, ctiprea, ctipcoa,
                                     inovpro, ianureb_npac, ianupol_npac, ianureb_npan,
                                     ianupol_npan, isuplem, icartera, ianureb_carac,
                                     ianupol_carac, ianureb_caran, ianupol_caran, iaportex,
                                     iextorn,
                                             --CAMPOS DE COMISIONES
                                             icomnp, iretnp, icomanureb_npac,
                                     iretanureb_npac, icomanureb_npan, iretanureb_npan,
                                     icomanupol_npac, iretanupol_npac, icomanupol_npan,
                                     iretanupol_npan, icomsup, iretsup, icomcar, iretcar,
                                     icomanureb_carac, iretanureb_carac,
                                     icomanureb_caran, iretanureb_caran, icomanupol_carac,
                                     iretanupol_carac, icomanupol_caran, iretanupol_caran,
                                     icomextorn, iretextorn, icomaport, iretaport)
                             VALUES (anul.sseguro, det.nriesgo, det.cgarant, anul.nmovimi,
                                     v_anyanul, v_mesanul, psproces, pfperfin, pfcalcul,
                                     anul.cempres, anul.cramo, anul.cmodali, anul.ctipseg,
                                     anul.ccolect, anul.cactivi, anul.npoliza, anul.ncertif,
                                     anul.cagente, anul.cagrpro, anul.ctiprea, anul.ctipcoa,
                                     0, v_ianureb_npac, 0, v_ianureb_npan,
                                     0, 0, 0, v_ianureb_carac,
                                     0, v_ianureb_caran, 0, 0,
                                     0,
                                       --campos de comisiones
                                     0, 0, v_icomanureb_npac,
                                     v_iretanureb_npac, v_icomanureb_npan, v_iretanureb_npan,
                                     0, 0, 0,
                                     0, 0, 0, 0, 0,
                                     v_icomanureb_carac, v_iretanureb_carac,
                                     v_icomanureb_caran, v_iretanureb_caran, 0,
                                     0, 0, 0,
                                     0, 0, 0, 0);
                     EXCEPTION
                        WHEN OTHERS THEN
                           num_err := 108013;   -- Error al insertar en VENTASAUX
                           text_error := text_error1 || SQLERRM || ' ' || SQLCODE
                                         || 'errinsert';
                     END;
                  ELSIF pmodo = 3 THEN   -- si es simulación se graba en VENTASAUX
                     BEGIN
                        INSERT INTO ventasaux
                                    (sseguro, nriesgo, cgarant, nmovimi,
                                     nanyven, nmesven, sproces, fcierre, fcalcul,
                                     cempres, cramo, cmodali, ctipseg,
                                     ccolect, cactivi, npoliza, ncertif,
                                     cagente, cagrpro, ctiprea, ctipcoa,
                                     inovpro, ianureb_npac, ianupol_npac, ianureb_npan,
                                     ianupol_npan, isuplem, icartera, ianureb_carac,
                                     ianupol_carac, ianureb_caran, ianupol_caran, iaportex,
                                     iextorn,
                                             --CAMPOS DE COMISIONES
                                             icomnp, iretnp, icomanureb_npac,
                                     iretanureb_npac, icomanureb_npan, iretanureb_npan,
                                     icomanupol_npac, iretanupol_npac, icomanupol_npan,
                                     iretanupol_npan, icomsup, iretsup, icomcar, iretcar,
                                     icomanureb_carac, iretanureb_carac,
                                     icomanureb_caran, iretanureb_caran, icomanupol_carac,
                                     iretanupol_carac, icomanupol_caran, iretanupol_caran,
                                     icomextorn, iretextorn, icomaport, iretaport)
                             VALUES (anul.sseguro, det.nriesgo, det.cgarant, anul.nmovimi,
                                     v_anyanul, v_mesanul, psproces, pfperfin, pfcalcul,
                                     anul.cempres, anul.cramo, anul.cmodali, anul.ctipseg,
                                     anul.ccolect, anul.cactivi, anul.npoliza, anul.ncertif,
                                     anul.cagente, anul.cagrpro, anul.ctiprea, anul.ctipcoa,
                                     0, v_ianureb_npac, 0, v_ianureb_npan,
                                     0, 0, 0, v_ianureb_carac,
                                     0, v_ianureb_caran, 0, 0,
                                     0,
                                       --campos de comisiones
                                     0, 0, v_icomanureb_npac,
                                     v_iretanureb_npac, v_icomanureb_npan, v_iretanureb_npan,
                                     0, 0, 0,
                                     0, 0, 0, 0, 0,
                                     v_icomanureb_carac, v_iretanureb_carac,
                                     v_icomanureb_caran, v_iretanureb_caran, 0,
                                     0, 0, 0,
                                     0, 0, 0, 0);
                     EXCEPTION
                        WHEN OTHERS THEN
                           num_err := 108013;   -- Error al insertar en VENTAS/VENTASAUX
                           text_error := text_error1 || SQLERRM || SQLCODE || 'errinsventas';
                     END;
                  END IF;
               END IF;

               IF num_err <> 0 THEN
                  RETURN num_err;
               END IF;
            END LOOP;
         END IF;   -- venta en periodo CML

         v_nrecibo_ant := anul.nrecibo;

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;
      END LOOP;

      RETURN num_err;
   EXCEPTION
      WHEN OTHERS THEN
         num_err := 111111;
         text_error := text_error1 || SQLERRM || 'altres';
         RETURN num_err;
   END anulaciones_recibos;

-----------------------------------------------------------------------------------------------
   FUNCTION anulaciones_poliza(
      pmodo IN NUMBER,
      pcempres IN NUMBER,
      pnmesven IN NUMBER,
      pnanyven IN NUMBER,
      psproces IN NUMBER,
      pfperfin IN DATE,
      pfcalcul IN DATE,
      pmoneda IN NUMBER,
      text_error OUT VARCHAR2)
      RETURN NUMBER IS
/**********************************************************************************************
  Calcula la venta anulada cuando se anula una póliza
**********************************************************************************************/
      CURSOR c_anulaciones IS
         SELECT s.sseguro, s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.cactivi, s.npoliza,
                s.ncertif, s.nanuali, m.nmovimi, s.pdtoord, s.cempres, s.cagente, s.cagrpro,
                s.ctiprea, s.ctipcoa, m.fefecto, m.nanyven, m.nmesven
           FROM movseguro m, seguros s
          WHERE m.cmovseg = 3
            AND m.nmesven >= DECODE(m.nanyven, pnanyven, pnmesven, 1)
            AND m.nanyven >= pnanyven
            AND m.sseguro = s.sseguro
            AND s.cempres = pcempres
            AND s.cramo = s.cramo;

      CURSOR c_detrecibos(pc_sseguro IN NUMBER, pc_nmovimi IN NUMBER) IS
         SELECT   d.nriesgo, cgarant, SUM(DECODE(cconcep, 21, iconcep, 0)) ipridev,
                  SUM(DECODE(cconcep, 15, iconcep, 0)) icomdev,
                  SUM(DECODE(cconcep, 16, iconcep, 0)) iretdev,
                  SUM(DECODE(cconcep, 13, iconcep, 0)) idtoom,
                  SUM(DECODE(cconcep, 14, iconcep, 0)) iderreg
             FROM detrecibos d, recibos r
            WHERE r.sseguro = pc_sseguro
              AND r.nmovimi = pc_nmovimi
              AND r.nrecibo = d.nrecibo
         GROUP BY d.nriesgo, cgarant;

      v_fcierre_exant_efe DATE;   -- fecha de cierre del ejercicio anterior
      anulacion      NUMBER;   -- venta anulada total
      comi_anulada   NUMBER;   -- comision anulada total
      reten_anulada  NUMBER;   -- retencion anulada total
      v_anul_exant   NUMBER;   -- venta anulada del ejercicio anterior
      v_anul_exac    NUMBER;   -- venta anulada del ejercicio actual
      v_comanul_exant NUMBER;   -- comisión anulada del ejercicio anterior
      v_comanul_exac NUMBER;   -- comisión anulada ejercicio actual
      v_retanul_exant NUMBER;   -- retención anulada ejercicio anterior
      v_retanul_exac NUMBER;   -- retención anulada ejercicio actual
      v_ianupol_npac NUMBER;   -- venta anulada nueva prod. ejerc. actual
      v_ianupol_npan NUMBER;   -- venta anulada nueva prod. ejerc. anterior
      v_ianupol_carac NUMBER;   -- venta anulada cartera ejerc. actual
      v_ianupol_caran NUMBER;   -- venta anulada cartera ejerc. anterior
      v_icomanupol_npac NUMBER;   -- comision anulada nueva prod. ejerc. actual
      v_icomanupol_npan NUMBER;   -- comision anulada nueva prod. ejerc. anterior
      v_icomanupol_carac NUMBER;   -- comision anulada cartera ejerc. actual
      v_icomanupol_caran NUMBER;   -- comision anulada cartera ejerc. anterior
      v_iretanupol_npac NUMBER;   -- retención anulada nueva prod. ejerc. actual
      v_iretanupol_npan NUMBER;   -- retención anulada nueva prod. ejerc. anterior
      v_iretanupol_carac NUMBER;   -- retención anulada cartera ejerc. actual
      v_iretanupol_caran NUMBER;   -- retención anulada cartera ejerc. anterior
      v_iderreg_dev  NUMBER;   -- derechos de registro devengados
      num_err        NUMBER := 0;
      text_error1    VARCHAR2(150);
   BEGIN
      -- Averiguamos la fecha de cierre del ejercicio anterior (la fecha de cierre del mes de
      -- diciembre del año anterior)
      v_fcierre_exant_efe := TO_DATE('3112' ||(pnanyven - 1), 'ddmmyyyy');

      FOR anul IN c_anulaciones LOOP
         FOR det IN c_detrecibos(anul.sseguro, anul.nmovimi) LOOP
            text_error1 := '- FUNCIÓN ANULACIÓN PÓLIZAS - sseguro = ' || anul.sseguro || ' ';
            anulacion := 0;
            comi_anulada := 0;
            reten_anulada := 0;
            v_anul_exant := 0;
            v_anul_exac := 0;
            v_comanul_exant := 0;
            v_comanul_exac := 0;
            v_retanul_exant := 0;
            v_retanul_exac := 0;
            v_ianupol_npac := 0;
            v_ianupol_npan := 0;
            v_ianupol_carac := 0;
            v_ianupol_caran := 0;
            v_icomanupol_npac := 0;
            v_icomanupol_npan := 0;
            v_icomanupol_carac := 0;
            v_icomanupol_caran := 0;
            v_iretanupol_npac := 0;
            v_iretanupol_npan := 0;
            v_iretanupol_carac := 0;
            v_iretanupol_caran := 0;
            v_iderreg_dev := 0;

            IF det.iderreg <> 0 THEN
               v_iderreg_dev := det.ipridev * 5 / 100;
            ELSE
               v_iderreg_dev := 0;
            END IF;

            anulacion := NVL(f_round(det.ipridev -(det.ipridev * NVL(anul.pdtoord, 0) / 100)
                                     + v_iderreg_dev,
                                     pmoneda),
                             0);
            comi_anulada := NVL(f_round(det.icomdev, pmoneda), 0);
            reten_anulada := NVL(f_round(det.iretdev, pmoneda), 0);
            -- Calculamos la parte de la venta anulada que corresponde al ejercicio anterior
            -- y al ejercicio actual
            num_err := pac_ventascontab.f_vanu_excant_gar(anul.sseguro, det.cgarant,
                                                          det.nriesgo, pnanyven - 1,
                                                          v_fcierre_exant_efe, anul.fefecto,
                                                          pmoneda, v_anul_exant);

            IF num_err <> 0 THEN
               text_error := text_error1;
               RETURN num_err;
            END IF;

            -- La comisión anulada del ejercicio anterior será:
            IF comi_anulada <> 0 THEN
               v_comanul_exant := f_round(v_anul_exant * comi_anulada / anulacion, pmoneda);
               v_retanul_exant := f_round(v_comanul_exant * reten_anulada / comi_anulada,
                                          pmoneda);
            ELSE
               v_comanul_exant := 0;
               v_retanul_exant := 0;
            END IF;

            v_anul_exac := anulacion - v_anul_exant;
            v_comanul_exac := comi_anulada - v_comanul_exant;
            v_retanul_exac := reten_anulada - v_retanul_exant;

            IF f_es_renova(anul.sseguro, anul.fefecto) = 1 THEN
               v_ianupol_npac := v_anul_exac;
               v_ianupol_npan := v_anul_exant;
               v_icomanupol_npac := v_comanul_exac;
               v_icomanupol_npan := v_comanul_exant;
               v_iretanupol_npac := v_retanul_exac;
               v_iretanupol_npan := v_retanul_exant;
            ELSE
               v_ianupol_carac := v_anul_exac;
               v_ianupol_caran := v_anul_exant;
               v_icomanupol_carac := v_comanul_exac;
               v_icomanupol_caran := v_comanul_exant;
               v_iretanupol_carac := v_retanul_exac;
               v_iretanupol_caran := v_retanul_exant;
            END IF;

            -- Grabamos en VENTAS si algun importe es distinto de cero
            IF anulacion <> 0
               OR comi_anulada <> 0
               OR reten_anulada <> 0 THEN
               IF pmodo IN(1, 2) THEN
                  BEGIN
                     INSERT INTO ventas
                                 (sseguro, nriesgo, cgarant, nmovimi,
                                  nanyven, nmesven, sproces, fcierre, fcalcul,
                                  cempres, cramo, cmodali, ctipseg,
                                  ccolect, cactivi, npoliza, ncertif,
                                  cagente, cagrpro, ctiprea, ctipcoa, inovpro,
                                  ianureb_npac, ianupol_npac, ianureb_npan, ianupol_npan,
                                  isuplem, icartera, ianureb_carac, ianupol_carac,
                                  ianureb_caran, ianupol_caran, iaportex, iextorn,
                                                                                  --CAMPOS DE COMISIONES
                                                                                  icomnp,
                                  iretnp, icomanureb_npac, iretanureb_npac, icomanureb_npan,
                                  iretanureb_npan, icomanupol_npac, iretanupol_npac,
                                  icomanupol_npan, iretanupol_npan, icomsup, iretsup,
                                  icomcar, iretcar, icomanureb_carac, iretanureb_carac,
                                  icomanureb_caran, iretanureb_caran, icomanupol_carac,
                                  iretanupol_carac, icomanupol_caran, iretanupol_caran,
                                  icomextorn, iretextorn, icomaport, iretaport)
                          VALUES (anul.sseguro, det.nriesgo, det.cgarant, anul.nmovimi,
                                  anul.nanyven, anul.nmesven, psproces, pfperfin, pfcalcul,
                                  anul.cempres, anul.cramo, anul.cmodali, anul.ctipseg,
                                  anul.ccolect, anul.cactivi, anul.npoliza, anul.ncertif,
                                  anul.cagente, anul.cagrpro, anul.ctiprea, anul.ctipcoa, 0,
                                  0, v_ianupol_npac, 0, v_ianupol_npan,
                                  0, 0, 0, v_ianupol_carac,
                                  0, v_ianupol_caran, 0, 0,
                                                           --campos de comisiones
                                  0,
                                  0, 0, 0, 0,
                                  0, v_icomanupol_npac, v_iretanupol_npac,
                                  v_icomanupol_npan, v_iretanupol_npan, 0, 0,
                                  0, 0, 0, 0,
                                  0, 0, v_icomanupol_carac,
                                  v_iretanupol_carac, v_icomanupol_caran, v_iretanupol_caran,
                                  0, 0, 0, 0);
                  EXCEPTION
                     WHEN OTHERS THEN
                        num_err := 108013;   -- Error al insertar en VENTASAUX
                        text_error := text_error1 || SQLERRM || ' ' || SQLCODE;
                  END;
               ELSIF pmodo = 3 THEN   -- si es simulación se graba en VENTASAUX
                  BEGIN
                     INSERT INTO ventasaux
                                 (sseguro, nriesgo, cgarant, nmovimi,
                                  nanyven, nmesven, sproces, fcierre, fcalcul,
                                  cempres, cramo, cmodali, ctipseg,
                                  ccolect, cactivi, npoliza, ncertif,
                                  cagente, cagrpro, ctiprea, ctipcoa, inovpro,
                                  ianureb_npac, ianupol_npac, ianureb_npan, ianupol_npan,
                                  isuplem, icartera, ianureb_carac, ianupol_carac,
                                  ianureb_caran, ianupol_caran, iaportex, iextorn,
                                                                                  --CAMPOS DE COMISIONES
                                                                                  icomnp,
                                  iretnp, icomanureb_npac, iretanureb_npac, icomanureb_npan,
                                  iretanureb_npan, icomanupol_npac, iretanupol_npac,
                                  icomanupol_npan, iretanupol_npan, icomsup, iretsup,
                                  icomcar, iretcar, icomanureb_carac, iretanureb_carac,
                                  icomanureb_caran, iretanureb_caran, icomanupol_carac,
                                  iretanupol_carac, icomanupol_caran, iretanupol_caran,
                                  icomextorn, iretextorn, icomaport, iretaport)
                          VALUES (anul.sseguro, det.nriesgo, det.cgarant, anul.nmovimi,
                                  anul.nanyven, anul.nmesven, psproces, pfperfin, pfcalcul,
                                  anul.cempres, anul.cramo, anul.cmodali, anul.ctipseg,
                                  anul.ccolect, anul.cactivi, anul.npoliza, anul.ncertif,
                                  anul.cagente, anul.cagrpro, anul.ctiprea, anul.ctipcoa, 0,
                                  0, v_ianupol_npac, 0, v_ianupol_npan,
                                  0, 0, 0, v_ianupol_carac,
                                  0, v_ianupol_caran, 0, 0,
                                                           --campos de comisiones
                                  0,
                                  0, 0, 0, 0,
                                  0, v_icomanupol_npac, v_iretanupol_npac,
                                  v_icomanupol_npan, v_iretanupol_npan, 0, 0,
                                  0, 0, 0, 0,
                                  0, 0, v_icomanupol_carac,
                                  v_iretanupol_carac, v_icomanupol_caran, v_iretanupol_caran,
                                  0, 0, 0, 0);
                  EXCEPTION
                     WHEN OTHERS THEN
                        num_err := 108013;   -- Error al insertar en VENTAS/VENTASAUX
                        text_error := text_error1 || SQLERRM || ' ' || SQLCODE;
                  END;
               END IF;
            END IF;

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;
         END LOOP;
      END LOOP;

      RETURN num_err;
   EXCEPTION
      WHEN OTHERS THEN
         num_err := 111111;
         text_error := text_error1 || SQLERRM;
         RETURN num_err;
   END anulaciones_poliza;

-----------------------------------------------------------------------------------------------
   FUNCTION traspaso_a_hisventas(
      psproces IN NUMBER,
      pcempres IN NUMBER,
      text_error OUT VARCHAR2)
      RETURN NUMBER IS
/**********************************************************************************************
   Traspasamos a la tabla HISVENTAS la información de VENTAS correpondiente al mes
   y año de cierre. Se borrarán los mismos registros de la tabla VENTAS.
   De esta manera ya tendremos el proceso diario calculado a la vez.
**********************************************************************************************/
      num_err        NUMBER := 0;
      text_error1    VARCHAR2(150);
   BEGIN
      text_error1 := ' - FUNCIÓN TRASPASO HISVENTAS - ';

      -- Primero borramos los registros de HISVENTAS del mismo mes que se cierra (por si el
      -- mes ya estaba cerrado
      BEGIN
         DELETE FROM hisventas
               WHERE nmesven = vg_nmesven
                 AND nanyven = vg_nanyven
                 AND cempres = pcempres;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 108014;   -- Error al borrar en la tabla HISVENTAS
            text_error := text_error1 || SQLERRM || ' ' || SQLCODE;
      END;

      BEGIN
         INSERT INTO hisventas
                     (sseguro, nriesgo, cgarant, nmovimi, nanyven, nmesven, sproces, fcierre,
                      fcalcul, cempres, cramo, cmodali, ctipseg, ccolect, cactivi, npoliza,
                      ncertif, cagente, cagrpro, ctiprea, ctipcoa, inovpro, ianureb_npac,
                      ianupol_npac, ianureb_npan, ianupol_npan, isuplem, icartera,
                      ianureb_carac, ianupol_carac, ianureb_caran, ianupol_caran, iaportex,
                      iextorn,
                              --CAMPOS DE COMISIONES
                              icomnp, iretnp, icomanureb_npac, iretanureb_npac,
                      icomanureb_npan, iretanureb_npan, icomanupol_npac, iretanupol_npac,
                      icomanupol_npan, iretanupol_npan, icomsup, iretsup, icomcar, iretcar,
                      icomanureb_carac, iretanureb_carac, icomanureb_caran, iretanureb_caran,
                      icomanupol_carac, iretanupol_carac, icomanupol_caran, iretanupol_caran,
                      icomextorn, iretextorn, icomaport, iretaport)
            (SELECT sseguro, nriesgo, cgarant, nmovimi, nanyven, nmesven, sproces, fcierre,
                    fcalcul, cempres, cramo, cmodali, ctipseg, ccolect, cactivi, npoliza,
                    ncertif, cagente, cagrpro, ctiprea, ctipcoa, inovpro, ianureb_npac,
                    ianupol_npac, ianureb_npan, ianupol_npan, isuplem, icartera,
                    ianureb_carac, ianupol_carac, ianureb_caran, ianupol_caran, iaportex,
                    iextorn,
                            --CAMPOS DE COMISIONES
                            icomnp, iretnp, icomanureb_npac, iretanureb_npac, icomanureb_npan,
                    iretanureb_npan, icomanupol_npac, iretanupol_npac, icomanupol_npan,
                    iretanupol_npan, icomsup, iretsup, icomcar, iretcar, icomanureb_carac,
                    iretanureb_carac, icomanureb_caran, iretanureb_caran, icomanupol_carac,
                    iretanupol_carac, icomanupol_caran, iretanupol_caran, icomextorn,
                    iretextorn, icomaport, iretaport
               FROM ventas
              WHERE sproces = psproces
                AND nmesven = vg_nmesven
                AND nanyven = vg_nanyven
                AND cempres = pcempres);
      EXCEPTION
         WHEN OTHERS THEN
            num_err := 108015;   -- Error al insertar en HISVENTAS
            text_error := text_error1 || SQLERRM || '  ' || SQLCODE;
      END;

      IF num_err = 0 THEN
         BEGIN
            DELETE FROM ventas
                  WHERE sproces = psproces
                    AND nmesven = vg_nmesven
                    AND nanyven = vg_nanyven
                    AND cempres = pcempres;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := 108016;   -- Error al borrar en VENTAS
               text_error := text_error1 || SQLERRM || '  ' || SQLCODE;
         END;
      END IF;

      RETURN num_err;
   END traspaso_a_hisventas;

-----------------------------------------------------------------------------------------------
   FUNCTION calculo_ventas(
      psproces IN NUMBER,
      pmodo IN NUMBER,
      pcempres IN NUMBER,
      pmoneda IN NUMBER,
      pfperfin IN DATE,
      text_error OUT VARCHAR2)
      RETURN NUMBER IS
/*********************************************************************************************
   función principal para el cálculo de ventas
**********************************************************************************************/-- Si el pmodo in (2,3), entonces sólo seleccionará la empresa del cierre. Si no,
 -- selecciona todas las empresas
      CURSOR c_empresas(pc_modo IN NUMBER) IS
         SELECT cempres
           FROM empresas
          WHERE cempres = DECODE(pc_modo, 1, cempres, pcempres);

      num_err        NUMBER;
      ult_fcierre    DATE;
      v_fcierre      DATE;
-- Para poder ejecutar la instruccion 'TRUNCATE'
      v_cursor       INTEGER;
      v_truncateventas VARCHAR2(40);
      v_truncatemovventas VARCHAR2(40);
      v_numrows      INTEGER;
   BEGIN
      IF pmodo = 1 THEN
         -- Si es el proceso diario para todas las empresas, hacemos un truncate
         -- de las tablas porque es más optimo
         -- Borramos el contenido de la tablas
         BEGIN
            -- Para poder ejecutar la instruccion 'TRUNCATE'
            v_cursor := DBMS_SQL.open_cursor;
            v_truncateventas := 'TRUNCATE TABLE VENTAS';
            v_truncatemovventas := 'TRUNCATE TABLE MOVVENTAS';
            DBMS_SQL.parse(v_cursor, v_truncateventas, DBMS_SQL.native);
            DBMS_SQL.parse(v_cursor, v_truncatemovventas, DBMS_SQL.native);
            v_numrows := DBMS_SQL.EXECUTE(v_cursor);
            DBMS_SQL.close_cursor(v_cursor);
         EXCEPTION
            WHEN OTHERS THEN
               IF DBMS_SQL.is_open(v_cursor) THEN
                  DBMS_SQL.close_cursor(v_cursor);
               END IF;

               RETURN 108017;   -- Error al borrar las tablas
         END;
      ELSIF pmodo = 3 THEN   -- si hacemos una simulación del cierre truncamos otras tablas
         BEGIN
            -- Para poder ejecutar la instruccion 'TRUNCATE'
            v_cursor := DBMS_SQL.open_cursor;
            v_truncateventas := 'TRUNCATE TABLE VENTASAUX';
            v_truncatemovventas := 'TRUNCATE TABLE MOVVENTAS';
            DBMS_SQL.parse(v_cursor, v_truncateventas, DBMS_SQL.native);
            DBMS_SQL.parse(v_cursor, v_truncatemovventas, DBMS_SQL.native);
            v_numrows := DBMS_SQL.EXECUTE(v_cursor);
            DBMS_SQL.close_cursor(v_cursor);
         EXCEPTION
            WHEN OTHERS THEN
               IF DBMS_SQL.is_open(v_cursor) THEN
                  DBMS_SQL.close_cursor(v_cursor);
               END IF;

               RETURN 108017;   -- Error al borrar las tablas
         END;
      ELSE   -- si es cierre definitivo, sólo borramos de la tabla ventas los registros
             -- de la empresa que estamos cerrando
         COMMIT;
         SET TRANSACTION USE ROLLBACK SEGMENT rollbig;

         DELETE FROM ventas
               WHERE cempres = pcempres;

         COMMIT;
         SET TRANSACTION USE ROLLBACK SEGMENT rollbig;

         DELETE FROM movventas
               WHERE cempres = pcempres;

         COMMIT;
         SET TRANSACTION USE ROLLBACK SEGMENT rollbig;
      END IF;

      -- Primero lanzamos el proceso que graba en movseguro el mes y año de venta de los movimientos
      -- que se han emitido durante el día
      num_err := f_fechventa;

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      -- Para cada empresa calculamos las ventas desde el último cierre
      FOR emp IN c_empresas(pmodo) LOOP
         -- Inicializamos las variables
         vg_nmesven := 0;
         vg_nanyven := 0;
         v_fcierre := NULL;

         IF pmodo IN(1, 3) THEN
            -- Miramos para que año y mes hay que hacer el cálculo
            num_err := fecha_calculo(emp.cempres, pmodo, v_fcierre, vg_nmesven, vg_nanyven);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;
         ELSIF pmodo = 2 THEN
            v_fcierre := pfperfin;
            vg_nmesven := TO_CHAR(pfperfin, 'mm');
            vg_nanyven := TO_CHAR(pfperfin, 'yyyy');
         END IF;

         -- La fecha del último cierre será la del mes anterior a pfperfin
         ult_fcierre := ADD_MONTHS(v_fcierre, -1);
         COMMIT;
         SET TRANSACTION USE ROLLBACK SEGMENT rollbig;
         num_err := venta_generada(pmodo, emp.cempres, vg_nmesven, vg_nanyven, psproces,
                                   v_fcierre, f_sysdate, pmoneda, text_error);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;

         COMMIT;
         SET TRANSACTION USE ROLLBACK SEGMENT rollbig;
         num_err := anulaciones_recibos(pmodo, emp.cempres, vg_nmesven, vg_nanyven, psproces,
                                        ult_fcierre, v_fcierre, f_sysdate, pmoneda, text_error);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;

         COMMIT;
         SET TRANSACTION USE ROLLBACK SEGMENT rollbig;
         num_err := anulaciones_poliza(pmodo, emp.cempres, vg_nmesven, vg_nanyven, psproces,
                                       v_fcierre, f_sysdate, pmoneda, text_error);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;

         IF pmodo = 2 THEN   -- Cierre definitivo
            COMMIT;
            SET TRANSACTION USE ROLLBACK SEGMENT rollbig;
            num_err := traspaso_a_hisventas(psproces, emp.cempres, text_error);
         END IF;
      END LOOP;

      RETURN num_err;
   END calculo_ventas;

-----------------------------------------------------------------------------------------------
   PROCEDURE proceso_batch_cierre(
      pmodo IN NUMBER,
      pcempres IN NUMBER,
      pmoneda IN NUMBER,
      pcidioma IN NUMBER,
      pfperfin IN DATE,
      pcerror OUT NUMBER,
      psproces OUT NUMBER,
      pfproces OUT DATE) IS
/*********************************************************************************************
  Proceso que lanzará todos los procesos de cierres (provisiones, siniestros, ventas,....)
**********************************************************************************************/
      num_err        NUMBER := 0;
      text_error     VARCHAR2(500);
      pnnumlin       NUMBER;
      texto          VARCHAR2(400);
      indice_error   NUMBER := 0;
      v_estado       NUMBER := 0;
      v_titulo       VARCHAR2(50);
   BEGIN
      IF pmodo = 1 THEN
         v_titulo := 'Proceso Cierre Diario';
      ELSIF pmodo = 2 THEN
         v_titulo := 'Proceso Cierre Mensual';
      ELSIF pmodo = 3 THEN
         v_titulo := 'Simulación Cierre';
      END IF;

      --Insertamos en la tabla PROCESOSCAB el registro identificativo de proceso -----
      num_err := f_procesini(f_user, 1, 'VENTAS', v_titulo, psproces);

      -- si es simulación grabamos un registro identificativo en la tabla CABVENTASAUX con
      -- cestado = 99 (en proceso)
      IF pmodo = 3 THEN
         BEGIN
            INSERT INTO cabventasaux
                        (sproces, fproces, cempres, cestado, comentarios)
                 VALUES (psproces, f_sysdate, pcempres, 99, NULL);
         EXCEPTION
            WHEN OTHERS THEN
               num_err := 108018;   -- Error al insertar en CABVENTASAUX
         END;
      END IF;

      COMMIT;

      IF num_err <> 0 THEN
         pcerror := 1;
         texto := f_axis_literales(num_err, pcidioma);
         pnnumlin := NULL;
         num_err := f_proceslin(psproces, SUBSTR(texto || ' ' || text_error, 1, 120), 0,
                                pnnumlin);
         COMMIT;
      ELSE
         num_err := calculo_ventas(psproces, pmodo, pcempres, pmoneda, pfperfin, text_error);

         -- Si es una simulación, cuando acabamos actualizamos
         IF num_err <> 0 THEN   -- hay errores
            v_estado := 1;
         ELSE
            v_estado := 0;
         END IF;

         IF v_estado = 0 THEN
            num_err := pac_ventascontab.calculo_ventas(psproces, pmodo, pcempres, pmoneda,
                                                       pfperfin, text_error);

            IF num_err <> 0 THEN   -- hay errores
               v_estado := 1;
            ELSE
               v_estado := 0;
            END IF;
         END IF;

         IF pmodo = 3 THEN
            BEGIN
               UPDATE cabventasaux
                  SET cestado = v_estado
                WHERE sproces = psproces;
            EXCEPTION
               WHEN OTHERS THEN
                  num_err := 108019;   -- Error al modificar la tabla CABVENTASAUX
                  text_error := text_error || SQLERRM || ' ' || SQLCODE;
            END;
         END IF;

         IF num_err <> 0 THEN
            pcerror := 1;
            texto := f_axis_literales(num_err, pcidioma);
            pnnumlin := NULL;
            num_err := f_proceslin(psproces, SUBSTR(texto || ' ' || text_error, 1, 120), 0,
                                   pnnumlin);
            COMMIT;
         ELSE
            COMMIT;
            pcerror := 0;
         END IF;
      END IF;

      num_err := f_procesfin(psproces, pcerror);
      pfproces := f_sysdate;

      IF num_err = 0 THEN
         COMMIT;
      END IF;
   END proceso_batch_cierre;
END;

/

  GRANT EXECUTE ON "AXIS"."PAC_VENTAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_VENTAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_VENTAS" TO "PROGRAMADORESCSI";
