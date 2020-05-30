--------------------------------------------------------
--  DDL for Function F_CAPPROB_PEG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_CAPPROB_PEG" (
   pssolicit IN NUMBER,
   p_data_efecte IN DATE,   -- FECHA EFECTO
   p_data_final IN DATE,   -- FECHA DE CÁLCULO (PUEDE SER CUALQUIER DÍA)
   p_sexo IN NUMBER,   -- SEXO DEL PRIMER ASEGURADO (1: hombre, 2: mujer)
   p_sexo2 IN NUMBER,   -- SEXO DEL SEGUNDO ASEGURADO (1: hombre; 2 mujer; NULL: sólo hay un asegurado)
   p_data_naix IN DATE,   -- FECHA DE NACIMIENTO DEL 1º
   p_data_naix2 IN DATE,   -- FECHA DE NACIMIENTO DEL 2º
   p_ctiptab IN NUMBER,   -- CÓDIGO DE LA TABLA DE MORTALIDAD (TIENE QUE SER 1)
   p_capprobable OUT NUMBER,
   p_rescate OUT NUMBER)
   RETURN NUMBER IS
   --FECHAS
   data_inici_mes DATE;
   data_final_mes DATE;
   ultim_dia_mes_anterior DATE;
   vmesestudio    VARCHAR2(2);
   vanyestudio    VARCHAR2(4);
   p_limit_max_capital_ass1 garanpro.icapmax%TYPE := 2000000;   --Capital Màxim Assegurat fixat a 2000000 PTA
   p_limit_max_capital_ass2 garanpro.icapmax%TYPE := 5000000;   --Capital Màxim Assegurat fixat a 5000000 PTA
   p_limit_max_65 garanpro.icapmax%TYPE := 100000;   --Capital Màxim Assegurat als 65 anys fixat a 100000 PTA
   p_int_tec_risc_perc NUMBER := 4;   --interés técnico de riesgo
   p_des_ginternasi_perc NUMBER;   -- Despeses de gestió interna sobre interès
   p_des_gexternosint NUMBER;   -- Gastos de gestión externos internos
   p_des_gexternosext NUMBER;   -- Gastos de gestión externos externos
   p_des_ext_risc NUMBER := 1;   -- Despeses de gestió externa  (Càlcul de la prima de Risc)
   --VALORES DE MORTALIDAD Y DE INVALIDEZ
   q              NUMBER;
   qx1            NUMBER;
   qx2            NUMBER;
   qy1            NUMBER;
   qy2            NUMBER;
   ix1            NUMBER;
   ix2            NUMBER;
   q2n            NUMBER;
   edat_actuarial NUMBER;
   edat_actuarial2 NUMBER;
   p_int_tec_perc_actual NUMBER;   --Percentatge d'interès tècnic (Pot variar)
   prov_matfinalmes NUMBER;
   capital_maximassegurat NUMBER;
   capital_risc   NUMBER;
   prima_purarisc NUMBER;
   prima_risc     NUMBER;   --Percentatge
   prima_riscpta  NUMBER;   --PTA
   i_tecnicaplicat_perc NUMBER;
   d              NUMBER;   --dies 1..31
   n_iteracions   NUMBER;
   parella        BOOLEAN;   --Per saber si és 1 ó 2 cabezas
   suma_aportacions NUMBER;
   vcoeficiente   NUMBER;
   vmultiplica    NUMBER;
   --Errors
   error1         NUMBER := 0;
   error2         NUMBER;

------------------------
--CURSORES
------------------------
--Primas
   CURSOR aportaciones IS
      SELECT   iprima
          FROM tmp_aportaciones
         WHERE ssolicit = pssolicit
           AND npago <> 0
           AND SUBSTR(TO_CHAR(fpago, 'DDMMYYYY'), 5) = vanyestudio
           AND SUBSTR(TO_CHAR(fpago, 'DDMMYYYY'), 3, 2) = vmesestudio
      ORDER BY nany, npago;

--Gastos
   CURSOR gastosprod IS
      SELECT pgaexin, pgaexex, pgasint
        FROM productos
       WHERE cramo = 2
         AND cmodali = 1
         AND ctipseg = 10
         AND ccolect = 4;

--Aportación Inicial
   CURSOR aportainicial IS
      SELECT iprima
        FROM tmp_aportaciones
       WHERE ssolicit = pssolicit
         AND npago = 0;

------------------------
--FUNCIONES
------------------------
--Calcula interés técnico
   FUNCTION c_interestecnic(periode IN DATE, pssolicit IN NUMBER)
      RETURN NUMBER IS
      vinteres       NUMBER;
      p_cramo        solseguros.cramo%TYPE;
      p_ccolect      solseguros.ccolect%TYPE;
      p_ctipseg      solseguros.ctipseg%TYPE;
      p_cmodali      solseguros.cmodali%TYPE;
      vfecha         DATE;
      vfechafin      DATE;
   BEGIN
      SELECT cramo, ccolect, ctipseg, cmodali
        INTO p_cramo, p_ccolect, p_ctipseg, p_cmodali
        FROM solseguros
       WHERE ssolicit = pssolicit;

      SELECT finivig
        INTO vfecha
        FROM interesprod
       WHERE cramo = p_cramo
         AND cmodali = p_cmodali
         AND ctipseg = p_ctipseg
         AND ccolect = p_ccolect
         AND ffinvig IS NULL;

      --añado 6 meses a la fecha inicial
      vfechafin := ADD_MONTHS(vfecha, 6);

      IF (periode >= vfecha)
         AND(periode < vfechafin) THEN
         SELECT NVL(pinttot, 0)
           INTO vinteres
           FROM interesprod
          WHERE cramo = p_cramo
            AND cmodali = p_cmodali
            AND ctipseg = p_ctipseg
            AND ccolect = p_ccolect
            AND finivig <= periode
            AND(ffinvig > periode
                OR ffinvig IS NULL);
      ELSE
         --será el interés garantizado
         SELECT NVL(pintprob, 0)
           INTO vinteres
           FROM interesprobprod
          WHERE cramo = p_cramo
            AND cmodali = p_cmodali
            AND ctipseg = p_ctipseg
            AND ccolect = p_ccolect
            AND finivig <= periode
            AND(ffinvig > periode
                OR ffinvig IS NULL);
/*     SELECT NVL(PINTTEC,0) INTO VINTERES
       FROM PRODUCTOS
       WHERE CRAMO = P_CRAMO AND CMODALI = P_CMODALI
       AND CTIPSEG = P_CTIPSEG AND CCOLECT = P_CCOLECT;*/
      END IF;

      RETURN vinteres;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN(-1);
/*  SELECT CRAMO,CCOLECT,CTIPSEG,CMODALI
    INTO P_CRAMO,P_CCOLECT,P_CTIPSEG,P_CMODALI
    FROM SOLSEGUROS
    WHERE SSOLICIT=PSSOLICIT;
    SELECT FINIVIG INTO VFECHA
    FROM INTERESPROBPROD
    WHERE CRAMO = P_CRAMO AND CMODALI = P_CMODALI
    AND CTIPSEG = P_CTIPSEG AND CCOLECT = P_CCOLECT
    AND FFINVIG IS NULL;
    --añado 6 meses a la fecha inicial
    VFECHAFIN:=ADD_MONTHS(VFECHA,6);
    IF (Periode >= VFECHA) AND (Periode < VFECHAFIN) THEN
       SELECT NVL(PINTPROB,0) INTO VINTERES
       FROM INTERESPROBPROD
       WHERE CRAMO = P_CRAMO AND CMODALI = P_CMODALI
       AND CTIPSEG = P_CTIPSEG AND CCOLECT = P_CCOLECT
       AND FINIVIG <=Periode AND (FFINVIG>Periode OR FFINVIG IS NULL);
    ELSE
       --será el interés garantizado
       SELECT NVL(PINTTEC,0) INTO VINTERES
       FROM PRODUCTOS
       WHERE CRAMO = P_CRAMO AND CMODALI = P_CMODALI
       AND CTIPSEG = P_CTIPSEG AND CCOLECT = P_CCOLECT;
    END IF;
    RETURN VINTERES;
    EXCEPTION
    WHEN OTHERS THEN
            RETURN (-1);*/
   END;

   FUNCTION rescate_probable(pssolicit IN NUMBER, capprobable IN NUMBER)
      RETURN NUMBER IS
      p_cramo        solseguros.cramo%TYPE;
      p_ccolect      solseguros.ccolect%TYPE;
      p_ctipseg      solseguros.ctipseg%TYPE;
      p_cmodali      solseguros.cmodali%TYPE;
      vpenalizacion  detprodtraresc.ppenali%TYPE;
      vrescate       NUMBER;
   BEGIN
      SELECT cramo, ccolect, ctipseg, cmodali
        INTO p_cramo, p_ccolect, p_ctipseg, p_cmodali
        FROM solseguros
       WHERE ssolicit = pssolicit;

      SELECT d.ppenali
        INTO vpenalizacion
        FROM detprodtraresc d, prodtraresc p, productos t
       WHERE d.sidresc = p.sidresc
         AND p.sproduc = t.sproduc
         AND t.cramo = p_cramo
         AND t.cmodali = p_cmodali
         AND t.ctipseg = p_ctipseg
         AND t.ccolect = p_ccolect   --P.SPRODUC=611
         AND p.ctipmov = 3
         AND niniran = 0
         AND nfinran = 1;   --CTIPMOV=3 RESCATE TOTAL

      IF vpenalizacion IS NOT NULL THEN
         vrescate :=(capprobable -((vpenalizacion / 100) * capprobable));
      END IF;

      RETURN vrescate;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN(-1);
   END;

--INVALIDEZ
   FUNCTION c_invalidesa(p_ctiptab IN NUMBER, p_pinttec IN NUMBER, p_edat_actuarial NUMBER)
      RETURN NUMBER IS
   BEGIN
      SELECT NVL(ix, 0)
        INTO ix2
        FROM simbolconmu
       WHERE ctabla = p_ctiptab   --taula 2
         AND pinttec = p_pinttec   --dada fixa
         AND nedad = p_edat_actuarial;

      RETURN(ix2);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN(-2);
   END;

--MORTALIDAD
   FUNCTION c_mortalitat(
      p_ctiptab IN NUMBER,
      p_pinttec IN NUMBER,
      p_edat_actuarial IN NUMBER,
      sexe IN NUMBER)
      RETURN NUMBER IS
   BEGIN
      SELECT NVL(qx, 0), NVL(qy, 0)
        INTO qx1, qy1
        FROM simbolconmu
       WHERE ctabla = p_ctiptab   --taula 2
         AND pinttec = 0   --dada fixa
         AND nedad = p_edat_actuarial;

      IF sexe = 1 THEN
         RETURN(qx1);
      ELSE
         RETURN(qy1);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN(-3);
   END;
BEGIN
--Gastos
   OPEN gastosprod;

   FETCH gastosprod
    INTO p_des_gexternosint, p_des_gexternosext, p_des_ginternasi_perc;   --p_des_GExternaSI_Perc;

   IF gastosprod%NOTFOUND THEN
      p_des_gexternosint := 0;
      p_des_gexternosext := 0;
      p_des_ginternasi_perc := 0;
   END IF;

   CLOSE gastosprod;

--1 ó 2 cabezas
   parella :=(p_data_naix2 IS NOT NULL);

--Cálculo del nº de iteraciones
--Si és el mateix mes i any el numero d'iteracions és 0,0..0 S'executarà 1 vegada
   IF TO_CHAR(p_data_final, 'YYYY') = TO_CHAR(p_data_efecte, 'YYYY')
      AND TO_CHAR(p_data_final, 'MM') = TO_CHAR(p_data_efecte, 'MM') THEN
      n_iteracions := 0;
   ELSE
      n_iteracions := CEIL(MONTHS_BETWEEN(p_data_final, p_data_efecte));
   END IF;

--La primera vez es la aportación inicial
   OPEN aportainicial;

   FETCH aportainicial
    INTO prov_matfinalmes;

   IF aportainicial%NOTFOUND THEN
      prov_matfinalmes := 0;
   END IF;

   CLOSE aportainicial;

   IF parella = FALSE THEN
--   dbms_output.put_line('********* 1 SOLA CABEZA *********');
      vcoeficiente := 0.1;
   ELSE
--   dbms_output.put_line('*********** 2 CABEZAS ***********');
      vcoeficiente := 3;
   END IF;

   FOR i IN 0 ..(n_iteracions - 1) LOOP   --n_iteracions=nº de meses que hay entre fecha efecto y fecha final
      --ÚLTIMO DÍA DEL MES ANTERIOR
      IF i <> 0 THEN
         ultim_dia_mes_anterior := data_final_mes;
      ELSE
         ultim_dia_mes_anterior := LAST_DAY(ADD_MONTHS(p_data_efecte, -1));
         --SE CALCULA LA EDAD ACTUARIAL
         error1 := f_difdata(p_data_naix, p_data_efecte, 2, 1, edat_actuarial);

         IF parella = TRUE THEN
            error2 := f_difdata(p_data_naix2, p_data_efecte, 2, 1, edat_actuarial2);
         END IF;

         IF error1 < 0
            OR error2 < 0 THEN
            RETURN -20;
         END IF;
      END IF;

      --FECHA INICIO DEL MES
      IF i <> 0 THEN
         data_inici_mes := ultim_dia_mes_anterior + 1;
      ELSE
         data_inici_mes := p_data_efecte;
      END IF;

      --FECHA FINAL DE MES
      IF LAST_DAY(ultim_dia_mes_anterior + 1) >= p_data_final THEN
         data_final_mes := p_data_final;
      ELSE
         data_final_mes := LAST_DAY(ultim_dia_mes_anterior + 1);
      END IF;

-- dbms_output.put_line('Fecha Inicio: '||to_char(Data_Inici_Mes));
   --d: DÍAS DE CÁLCULO DEL MES ACTUAL
      d := data_final_mes - data_inici_mes + 1;

-- dbms_output.put_line('Días: '||to_char(d));
   --ACTUALIZAMOS LA EDAD ACTUARIAL CADA AÑO
      IF MOD(i, 12) = 1
         AND i <> 1 THEN
         edat_actuarial := edat_actuarial + 1;

         IF parella = TRUE THEN
            edat_actuarial2 := edat_actuarial2 + 1;
         END IF;
      END IF;

/* dbms_output.put_line('Edad: '||to_char(edat_Actuarial));
   IF parella = TRUE THEN
      dbms_output.put_line('Edad 2: '||to_char(edat_Actuarial2));
   END IF;*/--CÁLCULO DEL INTERÉS TÉCNICO
   --PARA LA SIMULACIÓN, HASTA FECHA DEL PRIMER SEMESTRE NATURAL VA A SER EL MISMO
   --Y A PARTIR DE ESTE SEMESTRE SERÁ CTE.
      p_int_tec_perc_actual := c_interestecnic(data_inici_mes, pssolicit);

-- dbms_output.put_line('Interes que rescata: '|| to_char(p_int_tec_Perc_Actual));
      IF (p_int_tec_perc_actual < 0) THEN
         RETURN(-7);
      END IF;

      --Calculem el capital_MaximAssegurat (funció edat)
      IF parella = FALSE THEN
         IF edat_actuarial < 65 THEN
            capital_maximassegurat := p_limit_max_capital_ass1;
         ELSE
            capital_maximassegurat := p_limit_max_65;
         END IF;
      ELSE
         IF edat_actuarial < 65
            AND edat_actuarial2 < 65 THEN
            capital_maximassegurat := p_limit_max_capital_ass2;
         ELSE
            capital_maximassegurat := p_limit_max_65;
         END IF;
      END IF;

      --capital riesgo es el 10% (para una sola cabeza) ó
      --el 300% (para dos cabezas) de la prov mate de finals del mes anterior
      capital_risc := vcoeficiente * prov_matfinalmes;

-- dbms_output.put_line('Capital de Riesgo: '||capital_Risc);
      IF capital_risc > capital_maximassegurat THEN
         capital_risc := capital_maximassegurat;
      END IF;

      --Se calcula el porcentaje de mortalidad y de invalidez
      --Si hombre q=qx otherwise q=qy
      IF p_sexo = 1 THEN
         q := c_mortalitat(p_ctiptab, 0, edat_actuarial, 1);

         IF (q < 0) THEN
            RETURN(-8);
         END IF;
      ELSIF p_sexo = 2 THEN
         q := c_mortalitat(p_ctiptab, 0, edat_actuarial, 2);

         IF (q < 0) THEN
            RETURN(-9);
         END IF;
      ELSE
         RETURN(-11);
      END IF;

      IF parella = TRUE THEN
         -- Calculamos el valor de la tabla de mortalitat pel segon assegurat
         IF p_sexo2 = 1 THEN
            q2n := c_mortalitat(p_ctiptab, 0, edat_actuarial2, 1);

            IF (q2n < 0) THEN
               RETURN(-14);
            END IF;
         ELSIF p_sexo2 = 2 THEN
            q2n := c_mortalitat(p_ctiptab, 0, edat_actuarial2, 2);

            IF (q2n < 0) THEN
               RETURN(-15);
            END IF;
         ELSE
            RETURN(-16);
         END IF;
      END IF;

/* dbms_output.put_line('Mortalidad: '||to_char(q));
   IF parella = TRUE THEN
      dbms_output.put_line('Mortalidad 2: '||to_char(q2n));
   END IF;*/-- Calculamos el valor de la tabla de invalidez
      ix1 := c_invalidesa(p_ctiptab, 0, edat_actuarial);

      IF parella = TRUE THEN
         ix2 := c_invalidesa(p_ctiptab, 0, edat_actuarial2);

         IF (ix1 < 0)
            OR(ix2 < 0) THEN
            RETURN(-17);
         END IF;
      ELSE
         IF (ix1 < 0) THEN
            RETURN(-11);
         END IF;
      END IF;

/* dbms_output.put_line('Invalidez: '||to_char(ix1));
   IF parella = TRUE THEN
      dbms_output.put_line('Invalidez 2: '||to_char(ix2));
   END IF;*/
      i_tecnicaplicat_perc := ROUND((1 +(p_int_tec_perc_actual / 100))
                                    *(1 -(p_des_ginternasi_perc / 100)
                                      -((p_des_gexternosint + p_des_gexternosext) / 100))
                                    - 1,
                                    4)
                              * 100;
-- dbms_output.put_line('Interés: '||to_char(i_TecnicAplicat_Perc));
   --Consigo la aportación del mes de estudio
      suma_aportacions := 0;
      vanyestudio := SUBSTR(TO_CHAR(data_final_mes, 'DDMMYYYY'), 5);
      vmesestudio := SUBSTR(TO_CHAR(data_final_mes, 'DDMMYYYY'), 3, 2);

      OPEN aportaciones;

      FETCH aportaciones
       INTO suma_aportacions;

      IF aportaciones%NOTFOUND THEN
         suma_aportacions := 0;
      END IF;

      CLOSE aportaciones;

-- dbms_output.put_line('Aportación: ' || TO_CHAR(Suma_Aportacions));
   --Arrodonim al decimal 8
      IF parella = TRUE THEN
         vmultiplica :=((q * q2n) +(q * ix2) +(q2n * ix1) +(ix1 * ix2));
      ELSE
         vmultiplica :=(q + ix1);
      END IF;

      prima_purarisc := ROUND(vmultiplica * POWER(1 +(p_int_tec_risc_perc / 100.0), -0.5), 8);
      --Arrodinim al decimal 8
      prima_risc := ROUND(prima_purarisc /(1 -(p_des_ext_risc / 100.0)), 8);
      prima_riscpta := ROUND((ROUND((vmultiplica * POWER(1 +(p_int_tec_risc_perc / 100.0),
                                                         -0.5)),
                                    8)
                              /((1 -(p_des_ext_risc / 100.0))) * capital_risc * d)
                             / 365.0,
                             10);
-- dbms_output.put_line('Prima de Riesgo: ' || TO_CHAR(PRIMA_RISCPTA));
      prov_matfinalmes := f_round((prov_matfinalmes - prima_riscpta)
                                  * POWER(1 + i_tecnicaplicat_perc / 100.0, d / 365.0)
                                  +(suma_aportacions
                                    * POWER(1 + i_tecnicaplicat_perc / 100.0, d / 365.0)));

-- dbms_output.put_line('Provisión Matemática a Final de Mes: ' || TO_CHAR(prov_MatFinalMes));
   --Calculo el Valor de Rescate Probable
      IF vmesestudio = '12' THEN
         p_capprobable := prov_matfinalmes;

--    dbms_output.put_line('Valor de Capital Probable: '|| to_char(prov_MatFinalMes));
         IF vanyestudio = TO_CHAR(p_data_efecte, 'YYYY') THEN
            p_rescate := rescate_probable(pssolicit, prov_matfinalmes);
         ELSE
            p_rescate := prov_matfinalmes;
         END IF;
      END IF;
-- dbms_output.put_line('Valor de Rescate: '|| to_char(p_rescate));
   END LOOP;

   IF error1 < 0 THEN
      RETURN error1;
   ELSE
      RETURN 0;
   END IF;
-- BUG 21546_108724 - 08/02/2012 - JLTS - Cierre de posibles cursores abiertos, se adiciona EXCEPTION
EXCEPTION
   WHEN OTHERS THEN
      IF gastosprod%ISOPEN THEN
         CLOSE gastosprod;
      END IF;

      IF aportainicial%ISOPEN THEN
         CLOSE aportainicial;
      END IF;

      IF aportaciones%ISOPEN THEN
         CLOSE aportaciones;
      END IF;

      RETURN 140999;
END f_capprob_peg;

/

  GRANT EXECUTE ON "AXIS"."F_CAPPROB_PEG" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_CAPPROB_PEG" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_CAPPROB_PEG" TO "PROGRAMADORESCSI";
