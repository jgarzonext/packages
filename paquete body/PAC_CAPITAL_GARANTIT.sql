--------------------------------------------------------
--  DDL for Package Body PAC_CAPITAL_GARANTIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_CAPITAL_GARANTIT" IS
    TYPE RecordRescate IS RECORD(
        anyo       NUMBER(4),
        ivalres    v_rescate.ivalres%TYPE,
        ivalres1    v_rescate.ivalres%TYPE);
    Rec_Res    RecordRescate;
    TYPE RescateParcial IS TABLE OF Rec_Res%TYPE
    INDEX BY BINARY_INTEGER;
    ResPar     RescateParcial;
    indice    NUMBER;
/************************************************************************
    F_capital_minim_garantit
        Calcula el capital mínim garantit per una pòlissa d'estalvi
    ALLIBCTR
*************************************************************************/
     FUNCTION F_capital_minim_garantit(pmodo IN NUMBER,pfechini IN DATE, pfcarpro IN DATE,
    pfcaranu IN DATE,pfvencim IN DATE,pfcarant IN DATE,pfefecto IN DATE,NDUR IN NUMBER,
    pcramo IN NUMBER,pcmodali IN NUMBER,pctipseg IN NUMBER,pccolect IN NUMBER,
    IPFIJA IN NUMBER, CFPAGO IN NUMBER, IAPEXTIN IN NUMBER,NEDAT IN NUMBER,NSEXE IN NUMBER,
    IMORT IN NUMBER, CMORT IN NUMBER,IACCI IN NUMBER,CACCI IN NUMBER, ICIRC IN NUMBER,
    CCIRC IN NUMBER, IINVA IN NUMBER, CINVA IN NUMBER, CMONEDA IN NUMBER,
    importe IN NUMBER,capital OUT NUMBER,PRECGEO IN NUMBER DEFAULT 0.05)
    RETURN NUMBER IS
    I_tecnic    NUMBER;
    P_mort    NUMBER;
    P_acci    NUMBER;
    P_circ    NUMBER;
    P_inva    NUMBER;
    Pmensual    NUMBER;
    Isaldo     NUMBER;
    edat        NUMBER;
    inter_edat    NUMBER;
    aportacio    NUMBER;
    num_err        NUMBER;
    dias        NUMBER;
    meses        NUMBER;
    Pdiari        NUMBER;
    años        NUMBER;
    diasaldo    NUMBER;
    intsaldo    NUMBER;
    intconimporte    NUMBER;
    isaldo_un_año    NUMBER:=0;
    FUNCTION Faux_tarifa (pEDAT IN NUMBER, pSEXE IN NUMBER,
        pimport IN NUMBER, ptarifa IN NUMBER, pMONEDA IN NUMBER)
        RETURN NUMBER IS
        Num_err    NUMBER;
        num_aux1    NUMBER;
        num_aux2    NUMBER;
        num_aux3    NUMBER;
        total        NUMBER;
    BEGIN
        IF ptarifa IS NOT NULL THEN
            num_err := f_tarifas (ptarifa, psexe, pedat, 2, pimport,
                num_aux1, num_aux2, num_aux3, total, pmoneda);
        ELSE
            total := 0;
        END IF;
        RETURN(nvl(total,0));
    END;
    PROCEDURE Paux_total_tarifa IS
    BEGIN
        IF edat < 45 THEN inter_edat := 1;
        ELSIF edat > 44 AND edat < 55 THEN inter_edat := 2;
        ELSIF edat > 54 AND edat <= 65 THEN inter_edat := 3;
        END IF;
        p_mort := Faux_tarifa (edat, nsexe, imort, cmort, cmoneda);
        p_acci := Faux_tarifa (0, 0, iacci, cacci, cmoneda);
        p_circ := Faux_tarifa (0, 0, icirc, ccirc, cmoneda);
        p_inva := Faux_tarifa (inter_edat, 0, iinva, cinva, cmoneda);
    END Paux_total_tarifa;
    BEGIN
    -- BORRAMOS LA TABLA PL/SQL RESPAR
    respar.delete;
    -- Inicializamos el índice de la tabla temporal
    indice := 0;
    -- Hallamos el interés técnico del producto
    BEGIN
        SELECT pinttec INTO I_tecnic
        FROM PRODUCTOS
        WHERE cramo = pcramo
        AND cmodali = pcmodali
        AND ctipseg = pctipseg
        AND ccolect = pccolect;
    EXCEPTION
        WHEN no_data_found THEN
            RETURN 104742;  -- Error al buscar el interés técnico del producto
    END;
    Pmensual := POWER((1+ I_tecnic/100),(1/12)) - 1;
    Pdiari := POWER((1 + I_tecnic/100),(1/365));
    Isaldo := IAPEXTIN;
    Isaldo_un_año := Isaldo;
    edat := NEDAT;
    aportacio := IPFIJA;
    IF pmodo = 0 THEN  -- cálculo inicial (al dar de alta)
        años := NDUR;
    ELSIF pmodo = 1 THEN
        -- Calculamos los dias que hay entre la fecha del movimiento y la fecha de la aportación
        -- periódica (si la tiene)
        IF pfcarpro IS NOT NULL THEN
            num_err := f_difdata(pfechini, pfcarpro,1,3,dias);
            IF num_err <> 0 THEN
                RETURN num_err;
            END IF;
        ELSE
            RETURN 105131; -- Falta la fecha de cartera
        END IF;
        -- Calculamos los días entre fcarant y la fecha que hacemos el cambio de saldo
        num_err := f_difdata(nvl(pfcarant,pfefecto), pfechini, 1, 3, diasaldo);
        IF num_err <> 0 THEN
            RETURN num_err;
        END IF;
        -- Calculamos los meses que hay entre la fecha de cartera próxima y la cartera anual
        IF pfcaranu IS NOT NULL THEN
            num_err := f_difdata(pfcarpro, pfcaranu, 1,2,meses);
            IF num_err <> 0 THEN
                RETURN num_err;
            END IF;
        ELSE
            num_err := f_difdata(pfcarpro,pfvencim, 1, 2, meses);
            IF num_err <> 0 THEN
                RETURN num_err;
            END IF;
        END IF;
        -- Calculamos los años entre la cartera anual y el vencimiento
        num_err := f_difdata(pfcaranu, pfvencim,1,1,años);
        IF num_err <> 0 THEN
            RETURN num_err;
        END IF;
        -- Calculamos los intereses del saldo hasta la fecha del cambio
        intsaldo := f_round(isaldo*((power(pdiari,diasaldo)-1)),cmoneda);
        IF pfcarant is null THEN -- estamos dentro del primer periodo de la póliza
            Paux_total_tarifa;
            isaldo := isaldo + aportacio - (f_round(p_mort/12, cmoneda) +
                    f_round(p_acci/12, cmoneda) + f_round(p_circ/12, cmoneda)
                    + f_round(p_inva/12, cmoneda));
            isaldo_un_año := isaldo_un_año + aportacio - (f_round(p_mort/12, cmoneda) +
                    f_round(p_acci/12, cmoneda) + f_round(p_circ/12, cmoneda)
                    + f_round(p_inva/12, cmoneda));
        END IF;
        -- Calculamos los intereses de los días restantes del saldo +/- importe
        isaldo := isaldo + NVL(importe,0);
        isaldo_un_año := isaldo_un_año + NVL(importe,0);
        intconimporte := f_round(isaldo*((power(pdiari,dias)-1)),cmoneda);
        -- Calculamos el saldo con los intereses por los meses
        Paux_total_tarifa;
        FOR n_mes IN 1..meses LOOP
            IF n_mes <> 1 THEN
                Isaldo := Isaldo + f_round(Isaldo * Pmensual, cmoneda);
                Isaldo_un_año := Isaldo_un_año;
            ELSE
                isaldo := isaldo + intsaldo + intconimporte;
                Isaldo_un_año := Isaldo_un_año;
            END IF;
            --  Tenemos en cuenta la forma de pago única - se
            --  pondrá la aportación solo una vez.
            IF MOD(n_mes, 12/Cfpago) = 0
               AND (Cfpago > 0 OR (n_mes <> 0 AND pmodo = 0)) THEN
                Isaldo := Isaldo + aportacio;
                Isaldo_un_año := Isaldo_un_año + aportacio;
            END IF;
            Isaldo := Isaldo - (f_round(p_mort/12, cmoneda) +
                    f_round(p_acci/12, cmoneda) + f_round(p_circ/12, cmoneda)
                    + f_round(p_inva/12, cmoneda));
            Isaldo_un_año := Isaldo_un_año - (f_round(p_mort/12, cmoneda) +
                    f_round(p_acci/12, cmoneda) + f_round(p_circ/12, cmoneda)
                    + f_round(p_inva/12, cmoneda));
        END LOOP;
        aportacio := f_round (aportacio * (1+Precgeo), cmoneda);
        edat := edat + 1;
        indice := indice + 1;
        respar(indice).anyo := indice;
        respar(indice).ivalres := isaldo;
        respar(indice).ivalres1 := isaldo_un_año;
    END IF;
    FOR n_any IN 1..AÑOS LOOP
        Paux_total_tarifa;
        FOR n_mes IN 0..11 LOOP
            -- Calculem els interessos menys els del primer mes
            IF n_any <> 1 OR n_mes <> 0 OR pmodo = 1 THEN
                Isaldo := Isaldo + f_round(Isaldo * Pmensual, cmoneda);
                Isaldo_un_año := Isaldo_un_año;
            END IF;
            --  Tenemos en cuenta la forma de pago única - se
            --  pondrá la aportación solo una vez.
            IF MOD(n_mes, 12/Cfpago) = 0
               AND (Cfpago > 0 OR (n_any = 1 AND pmodo = 0)) THEN
                Isaldo := Isaldo + aportacio;
                Isaldo_un_año := Isaldo_un_año + aportacio;
            END IF;
            Isaldo := Isaldo - (f_round(p_mort/12, cmoneda) +
                f_round(p_acci/12, cmoneda) + f_round(p_circ/12, cmoneda)
                + f_round(p_inva/12, cmoneda));
            Isaldo_un_año := Isaldo_un_año - (f_round(p_mort/12, cmoneda) +
                f_round(p_acci/12, cmoneda) + f_round(p_circ/12, cmoneda)
                + f_round(p_inva/12, cmoneda));
        END LOOP;
        indice := indice + 1;
        respar(indice).anyo := indice;
        respar(indice).ivalres := isaldo;
        respar(indice).ivalres1 := isaldo_un_año;
        edat := edat + 1;
        aportacio := f_round (aportacio * (1+Precgeo), cmoneda);
    END LOOP;
    -- Calculem els últims interessos
    Isaldo := Isaldo + f_round(Isaldo * Pmensual, cmoneda);
    respar(respar.last).ivalres := isaldo;
    capital := isaldo;
    RETURN 0;
    END F_capital_minim_garantit;
/*******************************************************************************************
    F_TRASPASO_RESPAR: Graba en la tabla v_rescate los valores de rescate calculados
               para cada año, y que están guardados en la tablaPL/SQL RESPAR.
*********************************************************************************************/
FUNCTION F_TRASPASO_RESPAR(psseguro IN NUMBER, pnmovimi IN NUMBER, pfcalcul_año IN DATE,
            pfechasup IN DATE, pfefecpol IN DATE, pcmoneda IN NUMBER) RETURN NUMBER IS
    registros    NUMBER;
    xaño        NUMBER;
    xvalres        NUMBER;
    i        NUMBER;
    num_err        NUMBER;
    años        NUMBER;
BEGIN
    registros := respar.count;
    IF registros > 0 THEN
       DELETE FROM V_RESCATE
       WHERE sseguro = psseguro
         AND nmovimi = pnmovimi;
       FOR i IN 1..registros LOOP
        xaño := respar(i).anyo;
        num_err := f_difdata(pfefecpol, add_months(pfcalcul_año , xaño*12), 1, 1, años);
        IF años = 1 THEN
            xvalres := respar(i).ivalres1;
        ELSIF años = 2 THEN
            xvalres := f_round(respar(i).ivalres*0.93,pcmoneda);
        ELSE
            xvalres := respar(i).ivalres;
        END IF;
        BEGIN
            INSERT INTO V_RESCATE
            (sseguro, nmovimi, femisio, frescat,
             ivalres, finiefe, ffinefe)
            VALUES
            (psseguro, pnmovimi, trunc(sysdate), add_months(pfcalcul_año , xaño*12),
             xvalres, pfechasup, null);
        EXCEPTION
            WHEN OTHERS THEN
                respar.delete;
                RETURN 107434;  --Error al insertar en la tabla parámetros de rescate
        END;
       END LOOP;
    -- Finalizamos los registros del movimiento anterior.
       BEGIN
        UPDATE V_RESCATE
        SET ffinefe = pfechasup
        WHERE sseguro = psseguro
          AND ffinefe is null
          AND nmovimi <> pnmovimi;
       EXCEPTION
        WHEN OTHERS THEN
            respar.delete;
            RETURN 107433;  -- Error al modificar en la tabla parámetros de rescate
       END;
      -- borramos la tabla PL/SQL
      respar.delete;
    END IF;
    RETURN 0;
END F_TRASPASO_RESPAR;
END;

/

  GRANT EXECUTE ON "AXIS"."PAC_CAPITAL_GARANTIT" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CAPITAL_GARANTIT" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CAPITAL_GARANTIT" TO "PROGRAMADORESCSI";
