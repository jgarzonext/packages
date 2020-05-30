--------------------------------------------------------
--  DDL for Function FRCMRIESGO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FRCMRIESGO" (
   psesion IN NUMBER,
   ptipo IN NUMBER,
   psseguro IN NUMBER,
   pnriesgo NUMBER,
   pcgarant NUMBER,
   pfecha IN NUMBER,
   pirescate IN NUMBER)
   RETURN NUMBER AUTHID CURRENT_USER IS
/*******************************************************************************************
   FRCMRIESGO: Calcula el Rendimiento de Capital Mobiliario y la Reducción a una fecha
            para productos de Riesgo (Sepelio) A NIVEL DE GARANTÍA

     PTIPO:  1.- Retorna el RCM
             2.- Retorna la Reduccion

********************************************************************************************/
   num_err        NUMBER;
   v_sproduc      NUMBER;
   v_cactivi      NUMBER;
   v_fecha        DATE;
   --
   pase           NUMBER;
   dias           NUMBER;
   primaspagadas  NUMBER;
   sumprim        NUMBER;   -- suma de primas*dias
   coefic         NUMBER;
   --
   xanyos         NUMBER;
   ircm           NUMBER;   --rendimeinto asociado a la prima
   pred           NUMBER;   -- Porcentaje de reducción
   ired           NUMBER;   -- Importe de reducción asociado a la prima
   sumircm        NUMBER;   -- Rendimiento RCM total asociado a la prima
   sumired        NUMBER;   -- Importe Reducción Total
   v_orden        NUMBER;
   v_existe       NUMBER;
-- contador para la inserción en primas_consumidas
BEGIN
   pase := 1;

   SELECT sproduc, pac_seguros.ff_get_actividad(sseguro, pnriesgo)
     INTO v_sproduc, v_cactivi
     FROM seguros
    WHERE sseguro = psseguro;

   v_fecha := TO_DATE(pfecha, 'yyyymmdd');
   --DBMS_OUTPUT.put_line('v_fecha =' || v_fecha);
   -- Cálculo del denominador para la determinación del rendimiento a nivel prima
   sumprim := 0;
   primaspagadas := 0;

   SELECT NVL(SUM(NVL(f_impgarant(r.nrecibo, 'PRIMA TOTAL', pcgarant, pnriesgo), 0)), 0)
                                                                                  total_primas,
          NVL(SUM(NVL(f_impgarant(r.nrecibo, 'PRIMA TOTAL', pcgarant, pnriesgo), 0)
                  *(v_fecha - r.fefecto)),
              0) sumprima_dias
     INTO primaspagadas,
          sumprim
     FROM recibos r, movrecibo m
    WHERE sseguro = psseguro
      AND m.nrecibo = r.nrecibo
      AND m.cestrec = 1
      AND m.cestant = 0
      AND m.smovrec = (SELECT MAX(mm.smovrec)
                         FROM movrecibo mm
                        WHERE mm.nrecibo = r.nrecibo)
      AND r.fefecto < v_fecha;

   --DBMS_OUTPUT.put_line('sum_prima =' || sumprim);
   --DBMS_OUTPUT.put_line('primaspagadas =' || primaspagadas);
   pase := 2;
   sumircm := 0;
   sumired := 0;
   v_orden := 1;

   -- Cálculo del rendimiento antes de reducciones a nivel de prima
   FOR p IN (SELECT   NVL(f_impgarant(r.nrecibo, 'PRIMA TOTAL', pcgarant, pnriesgo), 0) prima,
                      r.fefecto
                 FROM recibos r, movrecibo m
                WHERE sseguro = psseguro
                  AND m.nrecibo = r.nrecibo
                  AND m.cestrec = 1
                  AND m.cestant = 0
                  AND m.smovrec = (SELECT MAX(mm.smovrec)
                                     FROM movrecibo mm
                                    WHERE mm.nrecibo = r.nrecibo)
                  AND r.fefecto < v_fecha
             ORDER BY r.fefecto) LOOP
      num_err := f_difdata(p.fefecto, v_fecha, 1, 3, dias);
      -- dias desde el efecto de la prima hasta la fecha del siniestro
      coefic := NVL((p.prima *(dias)), 0) / sumprim;
      --DBMS_OUTPUT.put_line('coefic =' || coefic);
      ircm := (pirescate - primaspagadas) * coefic;
      --DBMS_OUTPUT.put_line('ircm =' || ircm);
      sumircm := sumircm + ircm;
      --DBMS_OUTPUT.put_line('sumircm =' || sumircm);
      -- Calculamos la reducción
      pase := 9;
      num_err := f_difdata(p.fefecto, v_fecha, 1, 1, xanyos);
      -- años desde el efecto de la prima hasta la fecha del siniestro
      pred := fbuscapreduc(1, v_sproduc, v_cactivi, pcgarant,
                           TO_NUMBER(TO_CHAR(v_fecha, 'yyyymmdd')), xanyos);

      IF pred IS NULL THEN
         RETURN NULL;
      END IF;

      ired := ircm *(pred / 100);
      sumired := sumired + ired;

      SELECT COUNT(*)
        INTO v_existe
        FROM tmp_primas_consumidas
       WHERE sseguro = psseguro
         AND nnumlin = psesion
         AND norden = v_orden
         AND nriesgo = pnriesgo;

      IF v_existe = 0 THEN
         INSERT INTO tmp_primas_consumidas
                     (sseguro, nnumlin, norden, ipricons, ircm, fecha, frescat,
                      nriesgo, ndias, ncoefic, nanys, preduc, ireduc, preg_trans, ireg_trans,
                      ircm_neto)
              VALUES (psseguro, psesion, v_orden, p.prima, ircm, p.fefecto, v_fecha,
                      pnriesgo, dias, coefic, xanyos, pred, ired, NULL, NULL,
                      ircm - ired);
      END IF;

      v_orden := v_orden + 1;
   END LOOP;

   SELECT COUNT(*)
     INTO v_existe
     FROM tmp_fis_rescate
    WHERE sseguro = psseguro
      AND frescat = v_fecha
      AND nriesgo = pnriesgo;

   IF v_existe = 0 THEN
      INSERT INTO tmp_fis_rescate
                  (sseguro, frescat, nriesgo, ivalora, isum_primas, irendim, ireduc,
                   ireg_trans, ircm, iretenc, npmp)
           VALUES (psseguro, v_fecha, pnriesgo, pirescate, primaspagadas, sumircm, sumired,
                   NULL,(sumircm - sumired), NULL, NULL);
   END IF;

   IF ptipo = 1 THEN   -- RCM
      RETURN sumircm;
   ELSIF ptipo = 2 THEN   -- Reducción
      RETURN sumired;
   ELSE
      RETURN NULL;
   END IF;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      p_tab_error(SYSDATE, f_user, 'frcmriesgo', 2,
                  'Error en la función frcmriesgo, sesion: ' || psesion || ', sseguro: '
                  || psseguro,
                  SQLERRM);
      RETURN NULL;
   WHEN OTHERS THEN
      p_tab_error(SYSDATE, f_user, 'frcmriesgo', 2,
                  'Error en la función frcmriesgo, sesion: ' || psesion || ', sseguro: '
                  || psseguro,
                  SQLERRM);
      RETURN NULL;
END frcmriesgo;
 
 

/

  GRANT EXECUTE ON "AXIS"."FRCMRIESGO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FRCMRIESGO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FRCMRIESGO" TO "PROGRAMADORESCSI";
