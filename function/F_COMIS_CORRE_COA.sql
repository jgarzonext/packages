CREATE OR REPLACE FUNCTION f_comis_corre_coa(psseguro IN NUMBER,
                                             pnrecibo IN NUMBER,
                                             pnriesgo IN NUMBER) RETURN NUMBER IS
   /***********************************************************************
      f_comis_corre_coa       : Permite realiza el calculo de todas las comisiones incluyendo
                                Coaseguro Aceptado
				Coaseguro Cedido
				y Corretaje
				Lo anterior con el objetivo que dicha tabla sea utilizada para 
				el proceso de envo de infomacin a SAP.
   REVISIONES:
         Ver        Fecha        Autor             Descripcin
         ---------  ----------  -------  -------------------------------------
         1.0        19/09/2019   JLTS     1. IAXIS-5040. Creacin de la funcin.
         2.0        25/09/2019   JLTS     2. IAXIS-5040. Ajusta de la comisin de coaseguro aceptado
         3.0        05/03/2020   JRVG     3. IAXIS-12960 Bug en comisiones por cambios en emisin
         4.0        03/04/2020   JRVG     4. IAXIS-13762 Ajuste Comision Especial Corretaje  
   ***********************************************************************/
  vobj VARCHAR2(200) := 'F_COMIS_CORRE_COA';
  vpas NUMBER := 1;
  vpar VARCHAR2(500) := '01 psseguro=' || psseguro || ' 02 pnrecibo=' || pnrecibo || '03 pnriesgo ' || pnriesgo;
  -- 
  v_retorno NUMBER := 0;
  --
  v_numerr  NUMBER := 0;
  v_cagente seguros.cagente%TYPE;
  v_sproduc seguros.sproduc%TYPE;
  v_ctipcoa seguros.ctipcoa%TYPE;
  v_ctipcom seguros.ctipcom%TYPE;--SGM IAXIS 5347 Se corrige traida de comision especial
  v_ncuacoa seguros.ncuacoa%TYPE;
  v_cactivi seguros.cactivi%TYPE;
  v_cramo   seguros.cramo%TYPE;
  v_cmodali seguros.cmodali%TYPE;
  v_ctipseg seguros.ctipseg%TYPE;
  v_ccolect seguros.ccolect%TYPE;
  v_cmoneda NUMBER := 0; 
  v_nmovimi recibos.nmovimi%TYPE; -- INI IAXIS-12960  05/03/2020 - JRVG
  --
  v_pcomisi comisionprod.pcomisi%TYPE := 0;
  -- 
  v_cestrec movrecibo.cestrec%TYPE;
  v_fmovdia movrecibo.fmovdia%TYPE;
  --
  v_ctiprec recibos.ctiprec%TYPE;
  --
  v_tiene_corretaje NUMBER := 0;
  --
  v_pclocal comisionprod.pcomisi%TYPE;
  --
  iconcep0      detrecibos.iconcep%TYPE;
  aux_iconcep0  detrecibos.iconcep%TYPE;
  iconcep11     detrecibos.iconcep%TYPE;
  iconcep15     detrecibos.iconcep%TYPE;
  iconcep21     detrecibos.iconcep%TYPE;
  aux_iconcep21 detrecibos.iconcep%TYPE;
  iconcep33     detrecibos.iconcep%TYPE;
  iconcep50     detrecibos.iconcep%TYPE;
  aux_iconcep50 detrecibos.iconcep%TYPE;
  iconcep58     detrecibos.iconcep%TYPE;
  aux_iconcep58 detrecibos.iconcep%TYPE;

  --
  v_icombru comrecibo.icombru%TYPE;
  v_icomret comrecibo.icomret%TYPE;
  --
  v_pcacept NUMBER := 1;
  --
  CURSOR c_garantias(w_nrecibo recibos.nrecibo%TYPE) IS
    SELECT DISTINCT d.cgarant, d.nmovima
      FROM detrecibos d
     WHERE d.nrecibo = w_nrecibo
       AND d.nmovima = (SELECT MAX(d1.nmovima) FROM detrecibos d1 WHERE d1.nrecibo = d.nrecibo)
     ORDER BY d.cgarant;
  --
  CURSOR c_age(w_cagente agentes.cagente%TYPE) IS
    SELECT * FROM agentes a WHERE a.cagente = w_cagente;
  c_age_r c_age%ROWTYPE;
  --
  CURSOR c_com_age(w_sproduc comisionprod.sproduc%TYPE,
                   w_ccomisi comisionprod.ccomisi%TYPE) IS
    SELECT c.pcomisi
      FROM comisionprod c
     WHERE c.sproduc = w_sproduc
       AND c.ccomisi = w_ccomisi
       AND c.finivig = (SELECT MAX(c1.finivig)
                          FROM comisionprod c1
                         WHERE c1.cmodali = c.cmodali
                           AND c1.ccolect = c.ccolect
                           AND c1.cramo = c.cramo
                           AND c1.ctipseg = c.ctipseg
                           AND c1.ccomisi = c.ccomisi
                           AND c1.cmodcom = c.cmodcom
                           AND c1.ninialt = c.ninialt);
  --
  CURSOR c_coaced_local(w_sseguro seguros.sseguro%TYPE) IS
    SELECT 100 - nvl(SUM(c.pcescoa), 0) pclocal
      FROM coacedido c
     WHERE c.sseguro = w_sseguro
       AND c.ncuacoa = (SELECT MAX(c1.ncuacoa)
                          FROM coacedido c1
                         WHERE c1.sseguro = c.sseguro
                           AND c1.ccompan = c.ccompan);
  --
  CURSOR c_coaced(w_sseguro seguros.sseguro%TYPE) IS
    SELECT *
      FROM coacedido c
     WHERE c.sseguro = w_sseguro
       AND c.ncuacoa = (SELECT MAX(c1.ncuacoa)
                          FROM coacedido c1
                         WHERE c1.sseguro = c.sseguro
                           AND c1.ccompan = c.ccompan);
  --
  -- INI IAXIS-13762 - JRVG -03/04/2020 - Comision especial Corretaje
  CURSOR c_corretaje(w_sseguro seguros.sseguro%TYPE) IS
    SELECT *
      FROM age_corretaje a
     WHERE a.sseguro = w_sseguro
       AND a.nmovimi = v_nmovimi --(SELECT MAX(a1.nmovimi) FROM age_corretaje a1 WHERE a1.sseguro = a.sseguro)
     ORDER BY a.nordage;
  -- FIN IAXIS-13762 - JRVG -03/04/2020 - Comision especial Corretaje 
  --
  CURSOR c_aceptado(w_sseguro seguros.sseguro%TYPE) IS
    SELECT * FROM coacuadro c WHERE c.sseguro = w_sseguro;
  c_aceptado_r c_aceptado%ROWTYPE;
  --
  FUNCTION f_inserta_comision(pcgarant     NUMBER,
                              piporcentaje NUMBER,
                              pcagente     NUMBER,
                              pcomisi      NUMBER,
                              pccompan     NUMBER DEFAULT 0) RETURN NUMBER IS
    v_comis_calc comrecibo.icombru%TYPE := 0;
    v_reten_calc comrecibo.icomret%TYPE := 0;
    v_icomdev    comrecibo.icomdev%TYPE := 0;
    v_iretdev    comrecibo.icomret%TYPE := 0;
    v_icomcedida comrecibo.icomcedida%TYPE := 0;
  BEGIN
    --
    -- Inicia formulacin
    --
    vpar := 310;
    -- Comisin bruta
    IF aux_iconcep0 IS NOT NULL THEN
      v_comis_calc := f_round((nvl(aux_iconcep0, 0) * pcomisi / 100), v_cmoneda);
    ELSE
      -- Se ajusta la condicin para el coaseguro aceptado
      IF v_ctipcoa not in (8,9) THEN
        v_comis_calc := f_round((nvl(iconcep0, 0) * piporcentaje / 100) * pcomisi / 100, v_cmoneda);
      ELSE
	      v_comis_calc := f_round(nvl(iconcep0, 0) * pcomisi / 100, v_cmoneda);
      END IF;
    END IF;
    v_icombru := v_comis_calc;
    vpar      := 320;
    IF nvl(v_comis_calc, 0) <> 0 AND nvl(pcomisi, 0) <> 0 THEN
      -- Comsicin retenida
      v_reten_calc := f_round(((v_comis_calc * pcomisi) / 100), v_cmoneda);
      v_icomret    := v_reten_calc;
    END IF;
    vpar := 330;

    IF aux_iconcep21 IS NOT NULL THEN
      v_comis_calc := f_round((nvl(aux_iconcep21, 0) * pcomisi / 100), v_cmoneda);
    ELSE
      v_comis_calc := f_round((nvl(iconcep21, 0) * piporcentaje / 100) * pcomisi / 100, v_cmoneda);
    END IF;
    vpar      := 340;
    v_icomdev := v_comis_calc;

    IF nvl(v_comis_calc, 0) <> 0 AND nvl(v_pcomisi, 0) <> 0 THEN
      -- Comisin devengada
      v_reten_calc := f_round(((v_comis_calc * pcomisi) / 100), v_cmoneda);
      v_iretdev    := v_reten_calc;
    END IF;

    vpar := 350;
    IF aux_iconcep50 IS NOT NULL AND aux_iconcep58 IS NOT NULL THEN
      v_icomcedida := f_round(((nvl(aux_iconcep50, 0) + nvl(aux_iconcep58, 0)) * pcomisi / 100), v_cmoneda);
    ELSE
      v_icomcedida := f_round(((nvl(iconcep50, 0) + nvl(iconcep58, 0)) * piporcentaje / 100) * pcomisi / 100, v_cmoneda);
    END IF;
    vpar     := 360;
    v_numerr := pac_comisiones.f_alt_comisionrec(pnrecibo, v_cestrec, v_fmovdia, v_icombru, v_icomret, v_icomdev, v_iretdev,
                                                 pcagente, pcgarant, v_icomcedida, pccompan);

    IF v_numerr <> 0 THEN
      p_tab_error(f_sysdate, f_user, vobj, vpas, vpar,
                  'SQLCODE = ' || SQLCODE || ' - ' || 'SQLERRM = ' || SQLERRM || 'v_numerr = ' || v_numerr);
      RETURN v_numerr;
    END IF;
    RETURN 0;
  END f_inserta_comision;

BEGIN
  vpar := 10;
  --
  -- Carga datos del seguro
  -- SGM IAXIS 5347 Se corrige traida de comision especial (se agrega tipo de comision)
  -- IAXIS-12960  05/03/2020 - JRVG - Bug en comisiones por cambios en emisión (v_nmovimi)
  SELECT s.cagente, s.sproduc, s.ctipcoa, s.ncuacoa, s.cactivi, s.cramo, s.cmodali, s.ctipseg, s.ccolect, r.ctiprec, s.ctipcom ,r.nmovimi
    INTO v_cagente, v_sproduc, v_ctipcoa, v_ncuacoa, v_cactivi, v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_ctiprec, v_ctipcom, v_nmovimi
    FROM seguros s, recibos r
   WHERE s.sseguro = r.sseguro
     AND s.sseguro = psseguro
     AND r.nrecibo = pnrecibo;
  vpar := 20;
  --
  -- Datos del movimiento
  --
  SELECT m.cestrec, m.fmovdia
    INTO v_cestrec, v_fmovdia
    FROM movrecibo m
   WHERE m.nrecibo = pnrecibo
     AND m.smovrec = (SELECT MAX(m1.smovrec) FROM movrecibo m1 WHERE m1.nrecibo = m.nrecibo);
  vpar := 30;
  --
  -- Valida agente
  --

  OPEN c_age(v_cagente);
  FETCH c_age
    INTO c_age_r;
  IF c_age%NOTFOUND THEN
    RETURN 101842;
  END IF;
  IF c_age%ISOPEN THEN
    CLOSE c_age;
  END IF;
  --
  -- Comsion del agente
  --
  vpar := 40;
  IF v_ctipcom = 0 THEN  --
      OPEN c_com_age(v_sproduc, c_age_r.ccomisi);
      FETCH c_com_age
        INTO v_pcomisi;
      IF c_com_age%NOTFOUND THEN
        v_pcomisi := 0;
      END IF;
      IF c_com_age%ISOPEN THEN
        CLOSE c_com_age;
      END IF;
  ELSIF v_ctipcom = 90 THEN
    v_pcomisi := pac_propio_albsgt_conf.f_recupera_comision(ptablas => 'POL',
                                                        psseguro => psseguro,
                                                        pnriesgo => pnriesgo,
                                                        pfefecto => NULL,
                                                        pnmovimi => v_nmovimi, -- IAXIS-13762 - JRVG -03/04/2020 - Comision Especial Corretatje
                                                        pcgarant => NULL,
                                                        psproces => NULL,
                                                        pnmovima => NULL,
                                                        picapital => NULL);
  ELSIF v_ctipcom = 99 THEN
    v_pcomisi := 0;
  END IF;  
  vpar := 50;
  -- Valida si tiene corretaje
  -- Ini IAXIS-12960  05/03/2020 - JRVG - Bug en comisiones por cambios en emisión
  v_tiene_corretaje := pac_corretaje.f_tiene_corretaje(psseguro,v_nmovimi);
  vpar              := 60;
  -- Fin IAXIS-12960  05/03/2020 - JRVG - Bug en comisiones por cambios en emisión
  --
  -- Porcentajes de coaseguro cedido
  --
  IF v_pcomisi <> 0 THEN
   -- INI IAXIS-13762 - JRVG -03/04/2020 - Comision especial Corretaje
   -- IF v_tiene_corretaje = 1 THEN
      vpar := 50;
      -- Se borra la informacin previa de CORRETAJE en la tabla COMRECIBO
      DELETE comrecibo c WHERE c.nrecibo = pnrecibo;
      COMMIT; 
   -- END IF;
   -- INI IAXIS-13762 - JRVG -03/04/2020 - Comision especial Corretaje
   
    FOR c_garantias_r IN c_garantias(pnrecibo) LOOP
      iconcep0      := 0;
      aux_iconcep0  := NULL; -- NULL para que la funcion f_inserta_comision NO lo tome
      iconcep11     := 0;
      iconcep15     := 0;
      iconcep21     := 0;
      aux_iconcep21 := NULL; -- NULL para que la funcion f_inserta_comision NO lo tome
      iconcep33     := 0;
      iconcep50     := 0;
      aux_iconcep50 := NULL; -- NULL para que la funcion f_inserta_comision NO lo tome
      iconcep58     := 0;
      aux_iconcep58 := NULL; -- NULL para que la funcion f_inserta_comision NO lo tome
      vpar          := 70;
      --
      -- Carga los datos de prima neta (0,50) local y cedido
      --
      BEGIN
        SELECT nvl(SUM(d.iconcep), 0)
          INTO iconcep0
          FROM detrecibos d
         WHERE nrecibo = pnrecibo
           AND nriesgo = pnriesgo
           AND nvl(nmovima, -1) = nvl(c_garantias_r.nmovima, -1)
           AND cgarant = c_garantias_r.cgarant
           AND cconcep IN (0, 50) -- LOCAL + CEDIDA
         GROUP BY nriesgo;
      EXCEPTION
        WHEN OTHERS THEN
          iconcep0 := 0;
      END;
      vpar := 80;
      --
      -- Carga los datos de Comisin bruta (11,61) local y cedido
      --
      BEGIN
        SELECT nvl(SUM(d.iconcep), 0)
          INTO iconcep11
          FROM detrecibos d
         WHERE nrecibo = pnrecibo
           AND nriesgo = pnriesgo
           AND nvl(nmovima, -1) = nvl(c_garantias_r.nmovima, -1)
           AND cgarant = c_garantias_r.cgarant
           AND cconcep IN (11, 61) -- LOCAL + CEDIDA
         GROUP BY nriesgo;
      EXCEPTION
        WHEN OTHERS THEN
          iconcep11 := 0;
      END;
      vpar := 90;
      --
      -- Carga los datos de Comisin devengada (15,65) local y cedido
      --
      BEGIN
        SELECT nvl(SUM(d.iconcep), 0)
          INTO iconcep15
          FROM detrecibos d
         WHERE nrecibo = pnrecibo
           AND nriesgo = pnriesgo
           AND nvl(nmovima, -1) = nvl(c_garantias_r.nmovima, -1)
           AND cgarant = c_garantias_r.cgarant
           AND cconcep IN (15, 65) -- LOCAL + CEDIDA
         GROUP BY nriesgo;
      EXCEPTION
        WHEN OTHERS THEN
          iconcep15 := 0;
      END;
      vpar := 100;
      --
      -- Carga los datos de Prima devengada (21,71) local y cedido
      --
      BEGIN
        SELECT nvl(SUM(d.iconcep), 0)
          INTO iconcep21
          FROM detrecibos d
         WHERE nrecibo = pnrecibo
           AND nriesgo = pnriesgo
           AND nvl(nmovima, -1) = nvl(c_garantias_r.nmovima, -1)
           AND cgarant = c_garantias_r.cgarant
           AND cconcep IN (21, 71) -- LOCAL + CEDIDA
         GROUP BY nriesgo;
      EXCEPTION
        WHEN OTHERS THEN
          iconcep21 := 0;
      END;
      vpar := 110;
      --
      -- Carga los datos de Comisin retenida "Retencin en la fuente sobre comisin" (33,83) local y cedido
      --
      BEGIN
        SELECT nvl(SUM(d.iconcep), 0)
          INTO iconcep33
          FROM detrecibos d
         WHERE nrecibo = pnrecibo
           AND nriesgo = pnriesgo
           AND nvl(nmovima, -1) = nvl(c_garantias_r.nmovima, -1)
           AND cgarant = c_garantias_r.cgarant
           AND cconcep IN (33, 83) -- LOCAL + CEDIDA
         GROUP BY nriesgo;
      EXCEPTION
        WHEN OTHERS THEN
          iconcep33 := 0;
      END;
      vpar := 120;
      --
      -- Carga los datos de Prima Neta - cedido (50)
      --
      BEGIN
        SELECT nvl(SUM(d.iconcep), 0)
          INTO iconcep50
          FROM detrecibos d
         WHERE nrecibo = pnrecibo
           AND nriesgo = pnriesgo
           AND nvl(nmovima, -1) = nvl(c_garantias_r.nmovima, -1)
           AND cgarant = c_garantias_r.cgarant
           AND cconcep IN (50)
         GROUP BY nriesgo;
      EXCEPTION
        WHEN OTHERS THEN
          iconcep50 := 0;
      END;
      vpar := 130;
      --
      -- Carga los datos de Recargo por fracc. - cedido (58)
      --
      BEGIN
        SELECT nvl(SUM(d.iconcep), 0)
          INTO iconcep58
          FROM detrecibos d
         WHERE nrecibo = pnrecibo
           AND nriesgo = pnriesgo
           AND nvl(nmovima, -1) = nvl(c_garantias_r.nmovima, -1)
           AND cgarant = c_garantias_r.cgarant
           AND cconcep IN (58)
         GROUP BY nriesgo;
      EXCEPTION
        WHEN OTHERS THEN
          iconcep58 := 0;
      END;
      vpar := 140;
      -- No es negocio directo
      -- Sin coaseguro ni corretaje
      IF v_ctipcoa = 0 AND v_tiene_corretaje = 0 THEN
        vpar := 150;
        --
        -- Inserta comision local
        -- 
        v_numerr := f_inserta_comision(c_garantias_r.cgarant, 100, c_age_r.cagente, v_pcomisi);
        IF v_numerr <> 0 THEN
          RETURN v_numerr;
        END IF;
      ELSIF v_ctipcoa IN (1, 2) AND v_tiene_corretaje = 0 THEN
        vpar := 160;
        --
        -- Extrae porcentaje comsion local 
        --
        --      v_pasexec := 30;
        OPEN c_coaced_local(psseguro);
        FETCH c_coaced_local
          INTO v_pclocal;
        IF c_coaced_local%NOTFOUND THEN
          v_pclocal := 0;
        END IF;
        IF c_coaced_local%ISOPEN THEN
          CLOSE c_coaced_local;
        END IF;
        IF v_pclocal > 0 THEN
          vpar := 170;
          --
          -- Inserta comision local
          --
          v_numerr := f_inserta_comision(c_garantias_r.cgarant, v_pclocal, c_age_r.cagente, v_pcomisi);
          IF v_numerr <> 0 THEN
            RETURN v_numerr;
          END IF;
          --
          -- Inserta comision cedida
          --
          FOR c_coaced_r IN c_coaced(psseguro) LOOP
            vpar     := 180;
            v_numerr := f_inserta_comision(c_garantias_r.cgarant, c_coaced_r.pcescoa, c_age_r.cagente, v_pcomisi,
                                           c_coaced_r.ccompan);
            IF v_numerr <> 0 THEN
              RETURN v_numerr;
            END IF;
          END LOOP;
        END IF;
      ELSIF v_ctipcoa = 0 AND v_tiene_corretaje = 1 THEN
        FOR c_corretaje_r IN c_corretaje(psseguro) LOOP
          vpar     := 190;
          v_numerr := f_inserta_comision(c_garantias_r.cgarant, c_corretaje_r.ppartici, c_corretaje_r.cagente, v_pcomisi);
          IF v_numerr <> 0 THEN
            RETURN v_numerr;
          END IF;
        END LOOP;
      ELSIF v_ctipcoa IN (1,2,8,9) AND v_tiene_corretaje = 1 THEN--IAXIS 5347 calcula comision de coaseguro cedido/aceptado

        FOR c_corretaje_r IN c_corretaje(psseguro) LOOP
          vpar := 200;
          --
          -- Calcula prima auxiliar segn porcentaje
          --
          aux_iconcep0  := (((iconcep0 * v_pcomisi) * c_corretaje_r.ppartici) / 100) / 100;
          aux_iconcep21 := (((iconcep21 * v_pcomisi) * c_corretaje_r.ppartici) / 100) / 100;
          aux_iconcep50 := (((iconcep50 * v_pcomisi) * c_corretaje_r.ppartici) / 100) / 100;
          aux_iconcep58 := (((iconcep58 * v_pcomisi) * c_corretaje_r.ppartici) / 100) / 100;
          vpar          := 210;
          --
          -- Extrae porcentaje comsion local 
          --
          --      v_pasexec := 30;
          OPEN c_coaced_local(psseguro);
          FETCH c_coaced_local
            INTO v_pclocal;
          IF c_coaced_local%NOTFOUND THEN
            v_pclocal := 0;
          END IF;
          IF c_coaced_local%ISOPEN THEN
            CLOSE c_coaced_local;
          END IF;
          IF v_pclocal > 0 THEN
            vpar := 220;
            --
            -- Inserta comision local
            --
            v_numerr := f_inserta_comision(c_garantias_r.cgarant, v_pcomisi, c_corretaje_r.cagente, v_pclocal);
            IF v_numerr <> 0 THEN
              RETURN v_numerr;
            END IF;
          END IF;
          FOR c_coaced_r IN c_coaced(psseguro) LOOP
            vpar     := 230;
            v_numerr := f_inserta_comision(c_garantias_r.cgarant, c_corretaje_r.ppartici, c_corretaje_r.cagente,
                                           c_coaced_r.pcescoa, c_coaced_r.ccompan);
            IF v_numerr <> 0 THEN
              RETURN v_numerr;
            END IF;
          END LOOP;
        END LOOP;
        --END IF;
      ELSIF v_ctipcoa IN (8, 9) AND v_tiene_corretaje = 0 THEN --IAXIS 5792 calcula comision de coaseguro aceptado sin corretaje
        vpar := 240;
        OPEN c_aceptado(psseguro);
        FETCH c_aceptado
          INTO c_aceptado_r;
        IF c_aceptado%NOTFOUND THEN
          v_pcacept := 0;
        END IF;
        IF c_aceptado%ISOPEN THEN
          CLOSE c_aceptado;
        END IF;
        IF v_pcacept = 1 THEN
          vpar     := 250;
          v_numerr := f_inserta_comision(c_garantias_r.cgarant, c_aceptado_r.ploccoa, v_cagente, v_pcomisi);
          IF v_numerr <> 0 THEN
            RETURN v_numerr;
          END IF;
        END IF; 
      END IF;
    END LOOP;
  END IF;
  vpar := 181;
  RETURN v_retorno;
EXCEPTION
  WHEN OTHERS THEN
    p_tab_error(f_sysdate, f_user, vobj, vpas, vpar,
                'SQLCODE = ' || SQLCODE || ' - ' || 'SQLERRM = ' || SQLERRM || 'v_numerr = ' || v_numerr || ' - ' ||
                 dbms_utility.format_error_backtrace);
    RETURN 3000000;
END f_comis_corre_coa;
/