--------------------------------------------------------
--  DDL for Package Body PAC_PROVI_MV_PRUEBAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_PROVI_MV_PRUEBAS" IS
/******************************************************************************
   NOMBRE:       PAC_PROVI_MV_PRUEBAS
   PROPÓSITO:

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        09/07/2009   DCT              1. 0010612: Error en la generació de pagaments automàtics.
                                              Canviar vista personas por tablas personas y añadir filtro de visión de agente

******************************************************************************/
   TYPE recordrescate IS RECORD(
      anyo           NUMBER(4),
      ivalres        v_rescate.ivalres%TYPE,
      ivalres1       v_rescate.ivalres%TYPE
   );

   rec_res        recordrescate;

   TYPE rescateparcial IS TABLE OF rec_res%TYPE
      INDEX BY BINARY_INTEGER;

   respar         rescateparcial;
   indice         NUMBER;

   TYPE recordtramosint IS RECORD(
      nramo          NUMBER(4),
      pinttec        NUMBER(5, 2),
      ffecmov        DATE
   );

   rec_tram       recordtramosint;

   TYPE tramosint IS TABLE OF rec_tram%TYPE
      INDEX BY BINARY_INTEGER;

   tramosintec    tramosint;

   -- indice   NUMBER;

   ------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
   FUNCTION f_permf2000(
      ptabla IN NUMBER,
      pedad IN NUMBER,
      psexo IN NUMBER,
      pnacim IN NUMBER,
      ptipo IN NUMBER,
      psimbolo IN VARCHAR2)
      RETURN NUMBER IS
      v_lx           NUMBER := 0;
      v_dx           NUMBER := 0;
      v_qx           NUMBER := 0;
      v_px           NUMBER := 0;
      resultado      NUMBER := 0;
   BEGIN
      BEGIN
         SELECT DECODE(psexo, 1, vmascul, 2, vfemeni)
           INTO v_lx
           FROM mortalidad
          WHERE ctabla = ptabla
            AND nedad = pedad
            AND nano_nacim = pnacim
            AND ctipo = ptipo;

         SELECT v_lx - DECODE(psexo, 1, vmascul, 2, vfemeni),
                DECODE(psexo, 1, vmascul, 2, vfemeni) / v_lx
           INTO v_dx,
                v_px
           FROM mortalidad
          WHERE ctabla = ptabla
            AND nedad = pedad + 1
            AND nano_nacim = pnacim
            AND ctipo = ptipo;

         SELECT v_dx / v_lx
           INTO v_qx
           FROM DUAL;
      END;

      SELECT DECODE(UPPER(psimbolo), 'LX', v_lx, 'DX', v_dx, 'QX', v_qx, 'PX', v_px)
        INTO resultado
        FROM DUAL;

      RETURN resultado;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN -1;
   END f_permf2000;

-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
   FUNCTION f_lx_i(
      pfecha1 IN DATE,
      pfecha2 IN DATE,
      psexo IN NUMBER,
      pnacim IN NUMBER,
      ptipo IN NUMBER)
      RETURN NUMBER IS
-- Devuelve la LX interpolada entre dos fechas
      v_edad         NUMBER(7, 4) := 0;
      v_mod1         NUMBER;
      v_mod2         NUMBER;
      v_lx1          NUMBER;
      v_lx2          NUMBER;
      v_lxi          NUMBER;
--v_qxi    number;
      resultado      NUMBER;
      vpr1           NUMBER;
   BEGIN
      v_edad := TRUNC(((pfecha1 - pfecha2) / 365.25), 4);
      v_mod2 := v_edad - TRUNC(v_edad);
      v_mod1 := 1 - v_mod2;
      v_lx1 := pac_provi_mv_pruebas.f_permf2000(6, TRUNC(v_edad), psexo, pnacim, ptipo, 'LX');
      v_lx2 := pac_provi_mv_pruebas.f_permf2000(6, TRUNC(v_edad) + 1, psexo, pnacim, ptipo,
                                                'LX');
      v_lxi := TRUNC((v_mod1 * v_lx1) +(v_mod2 * v_lx2), 4);
-- v_qxi  := trunc(((v_lx1 - v_lx2) / v_lx1),4);

      --dbms_output.put_line('EDAD: '||v_edad);
--    dbms_output.put_line('MOD1: '||v_mod1);
--    dbms_output.put_line('MOD2: '||v_mod2);
--   dbms_output.put_line('LX1 : '||v_lx1);
--   dbms_output.put_line('LX2 : '||v_lx2);
--   dbms_output.put_line('LXI : '||v_lxi);
      RETURN v_lxi;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN -2;
   END f_lx_i;

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
   FUNCTION f_cr(
      pfechaini IN DATE,
      pfechafin IN DATE,
      pfnacimi IN DATE,
      psexo IN NUMBER,
      ptipo IN NUMBER,
      paportacion IN NUMBER,
      pinteres IN NUMBER)
      RETURN NUMBER IS
/*****************************************************************************************
   F_CR: Calcula la prima entre dos fechas

   Parámetros:
   pfechaini:  fecha inicio
   pfechafin: fecha final
   pfnacimi: fecha de nacimiento
   psexo: sexo 1.- Hombre  2.- Mujer
   ptipo : tipo tablas PERMF2000. 1:- Nueva Producción 2.- Cartera
   paportación: capital de riesgo
   pinteres: interés garantizado

******************************************************************************************/
      v_lx1          NUMBER;
      v_lx2          NUMBER;
      any_nacim      NUMBER;
      v_qx           NUMBER;
      v_ndias        NUMBER;
      v_ndias_anyo   NUMBER;   --> número de dias exactos que tiene el año con el que estamos trabajando (365 o 366)
      v_periodo      NUMBER;
      v_pr           NUMBER;
      v_pr1          NUMBER;
      fechafin       DATE;
   BEGIN
      any_nacim := TO_CHAR(pfnacimi, 'YYYY');
-- QX = ((lx1 - lx2) / lx1), siendo:
--      Lx1 la lx interpolada a la fecha de efecto
--   Lz2 la lx interpolada al último dia del mes de la fecha de efecto.
      v_lx1 := pac_provi_mv_pruebas.f_lx_i(pfechaini, pfnacimi, psexo, any_nacim, ptipo);
--dbms_output.put_line ('LX1: '||v_lx1);
      fechafin := pfechafin + 1;
      v_lx2 := pac_provi_mv_pruebas.f_lx_i(fechafin, pfnacimi, psexo, any_nacim, ptipo);
--dbms_output.put_line ('LX2: '||v_lx2);
      v_qx :=((v_lx1 - v_lx2) / v_lx1);
--dbms_output.put_line ('QX: '||v_QX);
      v_ndias := TO_DATE(pfechafin, 'dd/mm/yyyy') - TO_DATE(pfechaini, 'dd/mm/yyyy') + 1;
--dbms_output.put_line ('NIDAS: '||v_NDIAS);
      v_ndias_anyo := TO_DATE('31/12/' || TO_CHAR(pfechaini, 'yyyy'))
                      - TO_DATE('01/01/' || TO_CHAR(pfechaini, 'yyyy')) + 1;
--dbms_output.put_line ('D.AÑO: '||v_NDIAS_ANYO);
      v_periodo := -1 *((v_ndias / v_ndias_anyo) * .5);
--dbms_output.put_line ('periodo: '||v_periodo);
--dbms_output.put_line('paportaon ='||paportacion);

      --v_pr := TRUNC(power((paportacion + (paportacion * 10/100)) * (1+pinteres/100),v_periodo),4);
      v_pr := TRUNC((paportacion * v_qx) * POWER((1 +(pinteres / 100)), v_periodo), 8);
--V_PR := trunc(((paportacion + (paportacion * 10/100)) * v_qx) * power((1+(pinteres/100)),v_periodo),8);
--dbms_output.put_line ('PR: '||v_PR);
--dbms_output.put_line ('PR1: '||v_PR);
      RETURN v_pr;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN -3;
   END f_cr;

   FUNCTION f_pintec_adicional(
      pmodo IN NUMBER,
      psproduc IN NUMBER,
      reserva_bruta IN NUMBER,
      pfecha IN DATE,
      pinteres OUT NUMBER)
      RETURN NUMBER IS
/*******************************************************************************************
    PMODO : 0 - para el capital garantizado al vencimiento
           1 - para el calculo del capital estimado

*******************************************************************************************/
      v_pintec_probable NUMBER;
      v_pintec_adicional NUMBER;
   BEGIN
      IF pmodo = 1 THEN   -- CAPITAL ESTIMADO
         BEGIN
            SELECT ninttec
              INTO v_pintec_probable
              FROM intertecprod ip, intertecmov im, intertecmovdet ID
             WHERE ip.sproduc = psproduc
               AND ip.ncodint = im.ncodint
               AND im.ctipo = 2
               AND im.finicio <= pfecha
               AND(im.ffin >= pfecha
                   OR im.ffin IS NULL)
               AND im.ncodint = ID.ncodint
               AND im.finicio = ID.finicio
               AND im.ctipo = ID.ctipo
               AND ID.ndesde <= reserva_bruta
               AND ID.nhasta >= reserva_bruta;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 104742;
         END;
      ELSE
         BEGIN
            SELECT ninttec
              INTO v_pintec_adicional
              FROM intertecprod ip, intertecmov im, intertecmovdet ID
             WHERE ip.sproduc = psproduc
               AND ip.ncodint = im.ncodint
               AND im.ctipo = 1
               AND im.finicio <= pfecha
               AND(im.ffin >= pfecha
                   OR im.ffin IS NULL)
               AND im.ncodint = ID.ncodint
               AND im.finicio = ID.finicio
               AND im.ctipo = ID.ctipo
               AND ID.ndesde <= reserva_bruta
               AND ID.nhasta >= reserva_bruta;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 104742;
         END;
      END IF;

      IF pmodo = 0 THEN
         pinteres := v_pintec_adicional;
      ELSE
         pinteres := v_pintec_probable;
      END IF;

      RETURN 0;
   END f_pintec_adicional;

-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
   FUNCTION f_pm(
      reserva_bruta IN NUMBER,
      pfechaini IN DATE,
      pfechafin IN DATE,
      pinteres IN NUMBER,
      psproduc IN NUMBER,
      pfnacimi IN DATE,
      pcsexo IN NUMBER,
      ptipo IN NUMBER,
      ppgasext IN NUMBER,
      ppgasint IN NUMBER)
      RETURN NUMBER IS
      periodo        NUMBER;
      v_ndias_anyo   NUMBER;
      w_periodo_prorrat NUMBER;
      v_pintec_adicional NUMBER;
      num_err        NUMBER;
      edad           NUMBER;
      capitalmaxrisc NUMBER;
      capital_mort   NUMBER;
      capital_risc   NUMBER;
      limit_max_capital_65 NUMBER;
      limit_max_capital NUMBER;
      porcaprisc     NUMBER;
      pporcaprisc    NUMBER;
      p_mort         NUMBER;
      gastos_int     NUMBER;
      gastos_ext     NUMBER;
      reserva_neta   NUMBER;
      v_lx1          NUMBER;
      v_lx2          NUMBER;
      any_nacim      NUMBER;
      intereses      NUMBER;
      pm             NUMBER;
   BEGIN
      any_nacim := TO_CHAR(pfnacimi, 'yyyy');
      periodo := pfechafin - pfechaini + 1;
--dbms_output.put_line('periodo ='||periodo);
      v_ndias_anyo := TO_DATE('31/12/' || TO_CHAR(pfechaini, 'yyyy'))
                      - TO_DATE('01/01/' || TO_CHAR(pfechaini, 'yyyy')) + 1;
      w_periodo_prorrat := periodo / v_ndias_anyo;
--dbms_output.put_line('reserva_bruta ='||reserva_bruta);

      --p_control_ERROR(NULL, 'PROVIS', 'INT_ADICIONAL ='||V_PINTEC_ADICIONAL);

      --dbms_output.put_line('PINTERES := '||pinteres);
--p_control_ERROR(NULL, 'PROVIS', 'PINTERES ='||PINTERES);
      pporcaprisc := f_detparproductos(psproduc, 'PORCAPITALRISC', 1);
--p_control_ERROR(NULL, 'PROVIS', 'PORCAPRISC ='||PORCAPRISC);
      porcaprisc := pporcaprisc / 100;
      limit_max_capital := f_detparproductos(psproduc, 'IMMAXCAPSIN1ASE', 1);
      limit_max_capital_65 := f_detparproductos(psproduc, 'IMMAXCAPSIN65', 1);
      num_err := f_difdata(pfnacimi, pfechaini, 1, 1, edad);

--dbms_output.put_line('NUM_ERR ='||NUM_ERR);

      --dbms_output.put_line('edad ='||edad);
      IF edad > 65 THEN
         capitalmaxrisc := limit_max_capital_65;
      ELSE
         capitalmaxrisc := limit_max_capital;
      END IF;

      capital_mort := reserva_bruta * porcaprisc;

      IF capital_mort > capitalmaxrisc THEN
         capital_mort := capitalmaxrisc;
      END IF;

      capital_risc := reserva_bruta + capital_mort;
--dbms_output.put_line('capital_riesc ='||capital_risc);
      p_mort := pac_provi_mv_pruebas.f_cr(pfechaini, pfechafin, pfnacimi, pcsexo, ptipo,
                                          capital_risc, pinteres);
--dbms_output.put_line('prima ='||p_mort);
   -- cálculo de los gastos
      gastos_ext := ROUND(reserva_bruta * ppgasext / 100 * w_periodo_prorrat, 8);
      gastos_int := ROUND(reserva_bruta * ppgasint / 100 * w_periodo_prorrat, 8);
      reserva_neta := reserva_bruta - p_mort   -- PRIMA
                                            - gastos_ext   -- gastos externos
                                                        - gastos_int;   -- gastos internos
--dbms_output.put_line('gastos_ext ='||gastos_ext);
--dbms_output.put_line('gastos_int ='||gastos_int);
      v_lx1 := pac_provi_mv_pruebas.f_lx_i(pfechaini, pfnacimi, pcsexo, any_nacim, ptipo);
--dbms_output.put_line ('LX1: '||v_lx1);
      v_lx2 := pac_provi_mv_pruebas.f_lx_i(pfechafin + 1, pfnacimi, pcsexo, any_nacim, ptipo);
--dbms_output.put_line ('LX2: '||v_lx2);
          --v_qx  := ((v_lx1 - v_lx2) / v_lx1);
--dbms_output.put_line ('QX: '||v_QX);
--dbms_output.put_line('reserva_neta ='||reserva_neta);
      intereses := reserva_neta
                   *(POWER((1 + pinteres / 100),(w_periodo_prorrat)) * v_lx1 / v_lx2 - 1);
--dbms_output.put_line('INTERESES ='||intereses);
      pm := reserva_neta + intereses;
      RETURN NVL(pm, 0);
--dbms_output.put_line('pm ='||pm);
   END f_pm;

-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
   FUNCTION f_calculos_cap_garantit(
      psuplem IN NUMBER,
      pmodo IN NUMBER,
      pfefecto IN DATE,
      pfecha IN DATE,
      psproduc IN NUMBER,
      ipfija IN NUMBER,
      cfpago IN NUMBER,
      iapextin IN NUMBER,
      pfnacimi IN DATE,
      nsexe IN NUMBER,
      irevali IN NUMBER,
      prevali IN NUMBER,   --
      ptipo IN NUMBER,
      pfcaranu DATE,
      ndiaspro NUMBER,
      capital OUT NUMBER,
      capital_mort OUT NUMBER,
      aportaciones OUT NUMBER)
      RETURN NUMBER IS
/************************************************************************
   F_capital_minim_garantit
      Calcula el capital mínim garantit per una pòlissa d'estalvi
   ALLIBCTR

    pmodo = 0 => Cálculo interés tecnico.
     pmodo = 1 => Cálculo con el interés probable.

    psuplem = 0 => Nueva Producción
    psuplem = 1 => Suplementos. (aportación extraordinaria, rescates)
    psuplem = 2 => Suplemento sin cta (cambio fecha de vencimiento, cambio de revalorización)

   La estructura a seguir es la siguiente:
     a) se calcula el número de iteraciones ntre las dos fechas (meses)
     b) para cada mes
             - se suma la aportación
            - se calcula la prima
            - se calculan los gastos
            - se calculan los intereses
            - saldo := saldo anterior + aportacion - prima - gastos
         - al final de cada año : revalorizamos la aportación
*************************************************************************/
      i_tecnic       NUMBER;
      cmoneda        NUMBER := 1;
      isaldo         NUMBER;
      aportacio      NUMBER;
      num_err        NUMBER;
      v_tipo         NUMBER;
      p_gasint       NUMBER;
      p_gasext       NUMBER;
      cfpago_aux     NUMBER;
      isaldoini      NUMBER;
      n_iteracions   NUMBER;
      ultim_dia_mes_anterior DATE;
      fecha_inicio_mes DATE;
      fecha_final_mes DATE;
      v_pintec_adicional NUMBER;
      v_pintec_probable NUMBER;
      pinteres       NUMBER;
      pffininttec    DATE := pfcaranu;
      pfechafin      DATE := pfecha - 1;   -- el día de vencimiento no lo contamos
      fechaini       DATE := pfefecto;
      pporcaprisc    NUMBER;
      porcaprisc     NUMBER;
      pm_a_fecha     NUMBER;
   BEGIN
      -- Hallamos el interés técnico del producto
      BEGIN
         SELECT pinttec, pgasint, pgasext
           INTO i_tecnic, p_gasint, p_gasext
           FROM productos
          WHERE sproduc = psproduc;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 104742;   -- Error al buscar el interés técnico del producto
      END;

--dbms_output.put_line('entramos en calculos');

      --dbms_output.put_line('i_tecnic ='||i_tecnic);
      --dbms_output.put_line('p_gasint ='||p_gasint);
      --dbms_output.put_line('p_gasext ='||p_gasext);

      -- Calculamos el inteés probable si el modo = 1
      num_err := f_pintec_adicional(1, psproduc, iapextin, pfefecto, v_pintec_probable);
      isaldoini := iapextin;   --+ IPFIJA;
      isaldo := isaldoini;
      aportacio := ipfija;
      aportaciones := isaldo;

      IF cfpago = 0 THEN
         cfpago_aux := 1;
      ELSE
         cfpago_aux := cfpago;
      END IF;

--dbms_output.put_line('aport. extr. inici'||iapextin);
--dbms_output.put_line('aportacion periodica ='||aportacio);

      --Calculamos el número de iteraciones  = número de meses que hay entre fecha de efecto y pfecha
      -- Si es el mismo mes y año el número de iteraciones es 0. Sólo se ejecutará una vez
      IF TO_CHAR(pfecha, 'YYYY') = TO_CHAR(fechaini, 'YYYY')
         AND TO_CHAR(pfecha, 'MM') = TO_CHAR(fechaini, 'MM') THEN
         n_iteracions := 1;
      ELSIF TO_CHAR(pfecha, 'MMDD') = TO_CHAR(fechaini, 'MMDD')
            AND TO_CHAR(pfecha, 'DD') = 1 THEN
         n_iteracions := FLOOR(MONTHS_BETWEEN(pfecha, fechaini));
--dbms_output.put_line('n_iteracions caso b='||n_iteracions);
      ELSE
         IF TO_CHAR(pfechafin, 'DD') >= TO_CHAR(fechaini, 'DD') THEN
            n_iteracions := FLOOR(MONTHS_BETWEEN(pfechafin, fechaini)) + 1;
--dbms_output.put_line('n_iteracions caso c='||n_iteracions);
         ELSE
            n_iteracions := FLOOR(MONTHS_BETWEEN(pfechafin, fechaini)) + 2;
--dbms_output.put_line('n_iteracions caso d='||n_iteracions);
         END IF;
      END IF;

--dbms_output.put_line('n_iteracions ='||n_iteracions);
      FOR i IN 0 ..(n_iteracions - 1) LOOP
--dbms_output.put_line('n_iteracion ='||i);
      -- ULTIMO DIA MES ANTERIOR
         IF i <> 0 THEN
            ultim_dia_mes_anterior := fecha_final_mes;
         ELSE
            ultim_dia_mes_anterior := LAST_DAY(ADD_MONTHS(fechaini, -1));
         END IF;

--dbms_output.put_line('Ultim_dia_mes_anterior ='||ultim_dia_mes_anterior);
      -- FECHA INICIO MES
         IF i <> 0 THEN
            fecha_inicio_mes := ultim_dia_mes_anterior + 1;
         ELSE
            fecha_inicio_mes := fechaini;
         END IF;

--dbms_output.put_line('fecha inicio mes ='||fecha_inicio_mes);
      -- FECHA FINAL MES
         IF LAST_DAY(ultim_dia_mes_anterior + 1) > pfechafin THEN
            fecha_final_mes := pfechafin;
         ELSE
            fecha_final_mes := LAST_DAY(ultim_dia_mes_anterior + 1);
         END IF;

--dbms_output.put_line('fecha final mes ='||fecha_final_mes);

         -- Revalorizamos cada año
         IF TO_CHAR(fecha_inicio_mes, 'ddmm') = TO_CHAR(pfcaranu, 'ddmm') THEN
            IF ADD_MONTHS(fecha_inicio_mes, 12) <> pfcaranu THEN
        --and (i+1) not in (1,2) THEN  -- PRIMERA REVALORIZACIÓN
--dbms_output.put_line('revolizamos 1A VEZ y siguientes');
               IF prevali IS NOT NULL
                  AND prevali <> 0 THEN
                  aportacio := f_round(aportacio *(1 + prevali / 100), cmoneda);
               ELSIF irevali IS NOT NULL
                     AND irevali <> 0 THEN
                  aportacio := f_round(aportacio + irevali / cfpago_aux, cmoneda);
               END IF;
            END IF;
--dbms_output.put_line('nueva aportacion ='||aportacio);
         END IF;

      -- Tenemos en cuenta la forma de pago única
      -- se pondrá la aportación solo una vez.
--dbms_output.put_line('months beween ='||   abs(months_between(pfcaranu, Fecha_inicio_mes)));
         IF MOD(ABS(MONTHS_BETWEEN(pfcaranu, fecha_inicio_mes)), 12 / cfpago_aux) = 0
            AND cfpago > 0
            AND(i <> 0
                OR psuplem <> 0) THEN
            -- Tenemos en cuenta si hay ndiaspro
            IF i = 1
               AND TO_CHAR(fechaini, 'dd') >= ndiaspro THEN
               -- este mes no se hace aportación, se hace el mes siguiente
               NULL;
            ELSIF i = 1
                  AND cfpago <> 12 THEN
               NULL;
            ELSE
               --dbms_output.put_line('hago aportación ='||aportacio);
               isaldo := isaldo + aportacio;
               aportaciones := aportaciones + aportacio;
            END IF;
         --end if;
         END IF;

         num_err := f_pintec_adicional(0, psproduc, isaldo, fecha_inicio_mes,
                                       v_pintec_adicional);

         -- Miramos qué interés debemos aplicar depndiendo del periodo:
         -- primer año (hasta fecha renovación): interés técnico + interés adicional
         -- sucesivos: interés técnico
         IF pmodo = 0 THEN
            IF fecha_inicio_mes < pffininttec THEN
               pinteres := i_tecnic + v_pintec_adicional;
            ELSE
               pinteres := i_tecnic;
            END IF;
         ELSE
            pinteres := v_pintec_probable;
         END IF;

--dbms_output.put_line('PINTERES := '||pinteres);
--p_control_ERROR(NULL, 'PROVIS', 'PINTERES ='||PINTERES);
         isaldo := f_pm(isaldo, fecha_inicio_mes, fecha_final_mes, pinteres, psproduc,
                        pfnacimi, nsexe, ptipo, p_gasext, p_gasint);
--dbms_output.put_line('pm := '||ISALDO);

      --dbms_output.put_line('isaldo con intereses ='||isaldo);
--P_CONTROL_ERROR(NULL, 'PROVIS', 'GRABAMOS EN DETALLE');
   /*
     INSERT INTO TMP_DETPROVIS
      (ID, FINICIO, FFIN, NDIAS, EDAD1, LXI, EDAD2, LX2,
       QX, ICAPRISC, PRIMA, IGASEXT, IGASINT, INTERES,
      PM, PM_FALLEC, SUMAAPORT)
       VALUES
      (i, Fecha_Inicio_Mes, Fecha_final_mes, periodo, null, v_lx1, null, v_lx2,
         v_qx, Capital_Risc, p_mort, gastos_ext, gastos_int, intereses,
       ISALDO, isaldo + isaldo*porcaprisc, APORTACIONES );

      */

      --dbms_output.put_line('isaldo ='||isaldo);
      END LOOP;

      capital := isaldo;
      pporcaprisc := f_detparproductos(psproduc, 'PORCAPITALRISC', 1);
      porcaprisc := pporcaprisc / 100;
      capital_mort := isaldo + isaldo * porcaprisc;
--p_control_ERROR(NULL, 'PROVIS', 'SALDO ='||CAPITAL);
--dbms_output.put_line('saldo ='||isaldo);
      RETURN 0;
   END f_calculos_cap_garantit;

--------------------------------------------------------------------------------------------

   -------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
   FUNCTION f_calculos_provmat(pmodo IN NUMBER, psseguro IN NUMBER, pfecha IN DATE)
      RETURN NUMBER IS
/************************************************************************
   F_CALCULOS_PROVMAT
      Calcula el capital mínim garantit per una pòlissa d'estalvi
   ALLIBCTR

   3
*************************************************************************/
      i_tecnic       NUMBER;
      p_mort         NUMBER;
      p_mort_mov     NUMBER;
      num_err        NUMBER;
      v_tipo         NUMBER := 1;
      any_nacim      NUMBER;
      v_fnacimi      DATE;
      v_csexo        NUMBER;
      gastos_ext     NUMBER;
      gastos_int     NUMBER;
      gastos_ext_mov NUMBER;
      gastos_int_mov NUMBER;
      n_iteracions   NUMBER;
      ultim_dia_mes_anterior DATE;
      fecha_inicio_mes DATE;
      fecha_final_mes DATE;
      periodo        NUMBER;
      periodo_mov    NUMBER;
      v_lx1          NUMBER;
      v_lx2          NUMBER;
      v_lx1_mov      NUMBER;
      v_lx2_mov      NUMBER;
      intereses      NUMBER;
      intereses_mov  NUMBER;
      porcaprisc     NUMBER;
      pporcaprisc    NUMBER;
      limit_max_capital NUMBER;
      limit_max_capital_65 NUMBER;
      capitalmaxrisc NUMBER;
      capital_risc   NUMBER;
      capital_mort   NUMBER;
      capital_risc_mov NUMBER;
      capital_mort_mov NUMBER;
      edad           NUMBER;
      v_pintec_adicional NUMBER;
      pinteres       NUMBER;
      v_pintec_adicional_mov NUMBER;
      pinteres_mov   NUMBER;
      w_periodo_prorrat NUMBER;
      w_periodo_prorrat_mov NUMBER;
      v_ndias_anyo   NUMBER;
      pm_anterior    NUMBER;
      v_fecha_pm_anterior DATE;
      v_fechaini     DATE;
      v_nnumlin      NUMBER;
      reserva_bruta  NUMBER;
      reserva_neta   NUMBER;
      reserva_bruta_mov NUMBER;
      reserva_neta_mov NUMBER;
      pm_intermedia  NUMBER;
      pm_mov         NUMBER;
      provmatfinalmes NUMBER;
      saldo          NUMBER;
      aportacion     NUMBER;
      vagente_poliza seguros.cagente%TYPE;
      vcempres       seguros.cempres%TYPE;

--p_control_ERROR(NULL, 'PROVIS', 'ENTRAMOS EN CALCULO');

      -- CURSOR QUE AGAFA TOTES LES DADES DE LA PòLISSA
      CURSOR c_polizas_provmat IS
         SELECT s.cramo, s.cmodali, s.ctipseg, s.ccolect, p.pinttec,
                NVL(s.fcaranu, s.fvencim) ffinal, s.fefecto, s.ncertif, s.nduraci nduraci,
                p.pgasint, p.pgasext, s.cactivi, s.cforpag, s.fvencim, p.pgaexin, p.pgaexex,
                p.cdivisa, s.sproduc
           FROM productos p, seguros s
          WHERE s.sseguro = psseguro
            AND p.ctipseg = s.ctipseg
            AND p.cmodali = s.cmodali
            AND p.cramo = s.cramo
            AND p.ccolect = s.ccolect
            AND s.csituac <> 4;

      -- SELECCIONEM LES GARANTIES VIGENTS DE LA POLISSA QUE CALCULEN PROVISIONS MATEMàTICAS
      CURSOR c_garantias_provmat(
         seguro NUMBER,
         p_ramo NUMBER,
         p_modalidad NUMBER,
         p_tipseg NUMBER,
         p_colect NUMBER) IS
         SELECT DISTINCT nriesgo, g.cgarant, cprovis, ctabla
                    FROM garanpro gp, garanseg g
                   WHERE g.sseguro = seguro
                     AND gp.cprovis IS NOT NULL
                     AND g.cgarant = gp.cgarant
                     AND cramo = p_ramo
                     AND cmodali = p_modalidad
                     AND ctipseg = p_tipseg
                     AND ccolect = p_colect;

      CURSOR c_aportacion_periodica(psseguro NUMBER, f_ini DATE, f_final DATE) IS
         SELECT imovimi, ffecmov, fvalmov, nnumlin
           FROM ctaseguro
          WHERE sseguro = psseguro
            AND cmovimi = 2   --1,2,4 APORTACIONS
            AND(TO_CHAR(ffecmov, 'YYYYMMDD') BETWEEN TO_CHAR(f_ini, 'YYYYMMDD')
                                                 AND TO_CHAR(f_final, 'YYYYMMDD')
                OR(TO_CHAR(fcontab, 'YYYYMMDD') BETWEEN TO_CHAR(f_ini, 'YYYYMMDD')
                                                    AND TO_CHAR(f_final, 'YYYYMMDD')
                   AND TO_CHAR(ffecmov, 'YYYYMM') <=
                                              TO_CHAR(ADD_MONTHS(LAST_DAY(f_ini), -1),
                                                      'YYYYMM')))
            AND nnumlin = (SELECT MIN(nnumlin)
                             FROM ctaseguro
                            WHERE sseguro = psseguro
                              AND(cmovimi = 2)   --1,2,4 APORTACIONS
                              AND(TO_CHAR(ffecmov, 'YYYYMMDD') BETWEEN TO_CHAR(f_ini,
                                                                               'YYYYMMDD')
                                                                   AND TO_CHAR(f_final,
                                                                               'YYYYMMDD')
                                  OR(TO_CHAR(fcontab, 'YYYYMMDD') BETWEEN TO_CHAR(f_ini,
                                                                                  'YYYYMMDD')
                                                                      AND TO_CHAR(f_final,
                                                                                  'YYYYMMDD')
                                     AND TO_CHAR(ffecmov, 'YYYYMM') <=
                                              TO_CHAR(ADD_MONTHS(LAST_DAY(f_ini), -1),
                                                      'YYYYMM'))));

      CURSOR c_movimientos(psseguro NUMBER, f_ini DATE, f_final DATE, pnnumlin NUMBER) IS
         SELECT DECODE(cmovimi, 1, imovimi, 2, imovimi, 4, imovimi, -imovimi) imovimi, ffecmov,
                fvalmov
           FROM ctaseguro
          WHERE sseguro = psseguro
            AND cmovimi IN(1, 2, 4,   --1,2,4 APORTACIONS
                                   33, 34, 27)
            AND(TO_CHAR(ffecmov, 'YYYYMMDD') BETWEEN TO_CHAR(f_ini, 'YYYYMMDD')
                                                 AND TO_CHAR(f_final, 'YYYYMMDD')
                OR(TO_CHAR(fcontab, 'YYYYMMDD') BETWEEN TO_CHAR(f_ini, 'YYYYMMDD')
                                                    AND TO_CHAR(f_final, 'YYYYMMDD')
                   AND TO_CHAR(ffecmov, 'YYYYMM') <=
                                              TO_CHAR(ADD_MONTHS(LAST_DAY(f_ini), -1),
                                                      'YYYYMM')))
            AND nnumlin <> pnnumlin;   -- NO TENEMOS EN CUENTA LA APORTACIÓN DEL MES
      --AND CMOVANU!=1                                 --EL MOVIMENT NO HA ESTAT ANULAT
   -- AND NNUMLIN!=1; --Em salto el primer rebut
   BEGIN
      FOR reg IN c_polizas_provmat LOOP
         -- Tenemos que averiguar cual fue la PM del mes anterior
         BEGIN
            SELECT imovimi, fvalmov
              INTO pm_anterior, v_fecha_pm_anterior
              FROM ctaseguro
             WHERE sseguro = psseguro
               AND cmovimi = 0   -- 0 SALDO
               AND fvalmov = (SELECT MAX(fvalmov)
                                FROM ctaseguro
                               WHERE sseguro = psseguro
                                 AND fvalmov < pfecha)
               AND cmovanu != 1;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN   -- NUEVA PRODUCCIÓN. tODAVÍA NO HA PASADO EL PRIMER CIERRE
               pm_anterior := 0;
               v_fecha_pm_anterior := reg.fefecto - 1;
            WHEN OTHERS THEN
               --DBMS_OUTPUT.PUT_LINE ('PM_A_DATA_INICIAL:SQLERRM:'||SQLERRM);
               RETURN SQLCODE;
         --    RETURN (-52);
         END;

--dbms_output.put_line('v_fecha_pm_anerior ='||v_fecha_pm_anterior);
      -- Tenemos que averiguar datos del riesgo (asegurado)
         BEGIN
            --Bug10612 - 09/07/2009 - DCT (canviar vista personas)
            SELECT p.fnacimi, p.csexper
              INTO v_fnacimi, v_csexo
              FROM per_personas p, riesgos r
             WHERE r.sperson = p.sperson
               AND r.nriesgo = 1
               AND r.sseguro = psseguro;
           /*SELECT fnacimi, csexper
         INTO  v_fnacimi, v_csexo
         FROM   PERSONAS p, RIESGOS r
         WHERE  r.sperson = p.sperson
            AND r.nriesgo = 1
           and r.sseguro = psseguro;*/

         --Bug10612 - 09/07/2009 - DCT (canviar vista personas)
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 2222;
         END;

         v_fechaini := v_fecha_pm_anterior + 1;
         provmatfinalmes := pm_anterior;

          --Calculamos el número de iteraciones  = número de meses que hay entre fecha de efecto y pfecha
         -- Si es el mismo mes y año el número de iteraciones es 0. Sólo se ejecutará una vez
         IF TO_CHAR(pfecha, 'YYYY') = TO_CHAR(v_fechaini, 'YYYY')
            AND TO_CHAR(pfecha, 'MM') = TO_CHAR(v_fechaini, 'MM') THEN
            n_iteracions := 1;
         ELSIF TO_CHAR(pfecha, 'MMDD') = TO_CHAR(v_fechaini, 'MMDD')
               AND TO_CHAR(pfecha, 'DD') = 1 THEN
            n_iteracions := FLOOR(MONTHS_BETWEEN(pfecha, v_fechaini));
--dbms_output.put_line('n_iteracions caso b='||n_iteracions);
         ELSE
            IF TO_CHAR(pfecha, 'DD') >= TO_CHAR(v_fechaini, 'DD') THEN
               n_iteracions := FLOOR(MONTHS_BETWEEN(pfecha, v_fechaini)) + 1;
--dbms_output.put_line('n_iteracions caso c='||n_iteracions);
            ELSE
               n_iteracions := FLOOR(MONTHS_BETWEEN(pfecha, v_fechaini)) + 2;
--dbms_output.put_line('n_iteracions caso d='||n_iteracions);
            END IF;
         END IF;

--dbms_output.put_line('n_iteracions ='||n_iteracions);
         FOR i IN 0 ..(n_iteracions - 1) LOOP
--dbms_output.put_line('n_iteracion ='||i);
         -- ULTIMO DIA MES ANTERIOR
            IF i <> 0 THEN
               ultim_dia_mes_anterior := fecha_final_mes;
            ELSE
               ultim_dia_mes_anterior := LAST_DAY(ADD_MONTHS(v_fechaini, -1));
            END IF;

--dbms_output.put_line('Ultim_dia_mes_anterior ='||ultim_dia_mes_anterior);
         -- FECHA INICIO MES
            IF i <> 0 THEN
               fecha_inicio_mes := ultim_dia_mes_anterior + 1;
            ELSE
               fecha_inicio_mes := v_fechaini;
            END IF;

--dbms_output.put_line('fecha inicio mes ='||fecha_inicio_mes);
         -- FECHA FINAL MES
            IF LAST_DAY(ultim_dia_mes_anterior + 1) > pfecha THEN
               fecha_final_mes := pfecha;
            ELSE
               fecha_final_mes := LAST_DAY(ultim_dia_mes_anterior + 1);
            END IF;

--dbms_output.put_line('fecha final mes ='||fecha_final_mes);

            --- Para cada aportación realizada se calcula la PM
            --- Para calcular el capital de riesgo y el interés técnico adicional se aplica sobre
            -- la PM del mes anterior + la aportación periódica de ese mes
            FOR c_aport IN c_aportacion_periodica(psseguro, fecha_inicio_mes, fecha_final_mes) LOOP
--dbms_output.put_line('aportacion ='||c_aport.imovimi);
               v_nnumlin := c_aport.nnumlin;
               aportacion := c_aport.imovimi;
            END LOOP;

            reserva_bruta := provmatfinalmes + NVL(aportacion, 0);
--dbms_output.put_line('reserva_bruta ='||reserva_bruta);
            num_err := f_pintec_adicional(0, reg.sproduc, reserva_bruta, fecha_inicio_mes,
                                          v_pintec_adicional);
            pinteres := reg.pinttec + v_pintec_adicional;
            provmatfinalmes := f_pm(reserva_bruta, fecha_inicio_mes, fecha_final_mes, pinteres,
                                    reg.sproduc, v_fnacimi, v_csexo, v_tipo, reg.pgasext,
                                    reg.pgasint);

--dbms_output.put_line('pm_intermedia ='||Provmatfinalmes);
--dbms_output.put_line('llamamos a movimientos con las fechas ini='||fecha_inicio_mes||' fin ='||fecha_final_mes);

            -- Ahora tendremos en cuenta si ha habido más movimientos en el mes
            FOR c_mov IN c_movimientos(psseguro, fecha_inicio_mes, fecha_final_mes, v_nnumlin) LOOP
--dbms_output.put_line('fvalmov ='||c_mov.fvalmov);
             -- Calculamos el saldo para cada movimiento para ver si saltamos de tramo
          -- en el interés adicional
               saldo := reserva_bruta + c_mov.imovimi;
               num_err := f_pintec_adicional(0, reg.sproduc, saldo, c_mov.fvalmov,
                                             v_pintec_adicional_mov);
               pinteres_mov := reg.pinttec + v_pintec_adicional_mov;
               pm_mov := f_pm(c_mov.imovimi, c_mov.fvalmov, fecha_final_mes, pinteres_mov,
                              reg.sproduc, v_fnacimi, v_csexo, v_tipo, reg.pgasext,
                              reg.pgasint);
--dbms_output.put_line('pm_mov ='||pm_mov);
               provmatfinalmes := provmatfinalmes + pm_mov;
            --dbms_output.put_line('provmatfinalmes ='||provmatfinalmes);
            END LOOP;
         END LOOP;
      END LOOP;

--dbms_output.put_line('provMatfinalmes ='||provmatfinalmes);

      --p_control_ERROR(NULL, 'PROVIS', 'SALDO ='||CAPITAL);
--dbms_output.put_line('saldo ='||isaldo);
      RETURN provmatfinalmes;
   END f_calculos_provmat;

--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
   FUNCTION f_provmat_linea(
      pmodo IN NUMBER,
      psseguro IN NUMBER,
      pfecha IN DATE,
      pcmovimi IN NUMBER,
      pimovimi IN NUMBER,
      psproduc IN NUMBER,
      pinttec IN NUMBER,
      pfnacimi IN DATE,
      pcsexo IN NUMBER,
      ptipo IN NUMBER,
      pgasext IN NUMBER,
      pgasint IN NUMBER)
      RETURN NUMBER IS
/************************************************************************
   F_PROVMAT_LINEA
      Calcula la provisión matemática de un movimiento de la cuenta seguro:
      cmovimi = 1 --aportación extraordinaria
      cmovimi = 33, 34, 27 -- rescates
   ALLIBCTR

   3
*************************************************************************/
      num_err        NUMBER;
      saldo_ant      NUMBER;
      importe        NUMBER;
      saldo          NUMBER;
      v_pintec_adicional_mov NUMBER;
      pinteres       NUMBER;
      pm             NUMBER;
      fecha_final_mes DATE;
   BEGIN
      -- Calculamos el saldo para cada movimiento para ver si saltamos de tramo
      -- en el interés adicional
      num_err := f_saldo(psseguro, pfecha, saldo_ant);

      IF pcmovimi > 10 THEN
         importe := pimovimi * -1;
      ELSE
         importe := pimovimi;
      END IF;

      fecha_final_mes := LAST_DAY(pfecha);
      saldo := saldo_ant + importe;
      num_err := f_pintec_adicional(0, psproduc, saldo, pfecha, v_pintec_adicional_mov);
      pinteres := pinttec + v_pintec_adicional_mov;
      pm := f_pm(importe, pfecha, fecha_final_mes, pinteres, psproduc, pfnacimi, pcsexo, ptipo,
                 pgasext, pgasint);
--dbms_output.put_line('pm_mov ='||pm);
      RETURN pm;
   END f_provmat_linea;

--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
   FUNCTION f_calculo_intereses(
      pmodo IN VARCHAR2,
      psseguro IN NUMBER,
      pfecha IN DATE,
      intereses OUT NUMBER)
      RETURN NUMBER IS
/****************************************************************************
   F_INTERESAHORRO : Calcula los intereses que corresponden a una cuenta de
            ahorro hasta una determinada fecha.

    pmodo :=  'R' . Modo Real. Estaremos en el cierre.
            Actualiza los registros de CTASEGURO con ccalint = 1.
   pmodo := 'P'. Sólo calcula los intereses
*****************************************************************************/
      CURSOR c_regctaseg IS
         SELECT   sseguro, fcontab, nnumlin, ffecmov, fvalmov, cmovimi, imovimi, imovim2,
                  nrecibo, ccalint, cmovanu, nsinies
             FROM ctaseguro
            WHERE sseguro = psseguro
              AND ccalint = 0
              AND fvalmov <= pfecha
         ORDER BY fcontab;

      regcta         c_regctaseg%ROWTYPE;
      wcramo         NUMBER;
      wcmodali       NUMBER;
      wcdelega       NUMBER;
      wctipseg       NUMBER;
      wccolect       NUMBER;
      saldo_ant      NUMBER;
      num_lin        NUMBER;
      fultsaldo      DATE;
      saldo_actual   NUMBER;
      wsproduc       NUMBER;
      wfcaranu       DATE;
      v_pintec_saldo NUMBER;
      codi_movimi    NUMBER;
      imp_movimi     NUMBER;
      xffecmov       DATE;
      v_pintec_nou   NUMBER;
      n_iteracions   NUMBER;
      v_fnacimi      DATE;
      v_sexo         NUMBER;
      any_nacimi     NUMBER;
      vtipo          NUMBER;
      xpinttec       NUMBER;
      xfefecto       DATE;
      ultim_dia_tramo_anterior DATE;
      fecha_inicio   DATE;
      fecha_final    DATE;
      periodo        NUMBER;
      v_lx1          NUMBER;
      v_lx2          NUMBER;
      v_qx           NUMBER;
      int_total      NUMBER := 0;
      interes_ini    NUMBER;
      wfefecto_pol   DATE;
      v_pinttec      NUMBER;
      cmoneda        NUMBER := 1;
      max_numlin     NUMBER;
      vagente_poliza seguros.cagente%TYPE;
      vcempres       seguros.cempres%TYPE;

      CURSOR c_mov_salt_tramo(c_fultsaldo IN DATE) IS
         SELECT   cmovimi, imovimi, ffecmov
             FROM ctaseguro
            WHERE sseguro = psseguro
              AND fcontab > c_fultsaldo
              AND fcontab <= pfecha
              AND cmovimi IN(1, 2, 4,   --APORTACIONES)
                                     33, 34, 27)   -- RESCATES Y PENALIZACIÓN RESCATE
         ORDER BY 3;
   --regsaldo   c_calcsaldo%ROWTYPE;
   BEGIN
      -- Buscamos datos generales del seguro
      BEGIN
         SELECT cramo, cmodali, ctipseg, ccolect, fcaranu, sproduc, fefecto
           INTO wcramo, wcmodali, wctipseg, wccolect, wfcaranu, wsproduc, wfefecto_pol
           FROM seguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 100500;
      END;

      BEGIN
         SELECT pinttec
           INTO v_pinttec
           FROM productos
          WHERE sproduc = wsproduc;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 104742;
      END;

      -- Buscamos la fecha de nacimiento del riesgo y el sexo
      BEGIN
         --Bug10612 - 09/07/2009 - DCT (canviar vista personas)
         SELECT p.fnacimi, TO_CHAR(p.fnacimi, 'yyyy'), p.csexper
           INTO v_fnacimi, any_nacimi, v_sexo
           FROM riesgos r, per_personas p
          WHERE r.sperson = p.sperson
            AND r.sseguro = psseguro
            AND r.nriesgo = 1;
      /*SELECT fnacimi, to_char(fnacimi, 'yyyy'),csexper
      INTO  v_fnacimi, any_nacimi, v_sexo
      FROM RIESGOS r , PERSONAS P
      WHERE r.sperson = p.sperson
      and r.sseguro = psseguro
      and r.nriesgo = 1;*/

      --FI Bug10612 - 09/07/2009 - DCT (canviar vista personas)
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      vtipo := f_es_renova(psseguro, pfecha);
-----------------------------------------------------
-----------------------------------------------------
-- Primero buscamos si hay algún salto de tramo  de interés técnico adicional
 -----------------------------------------------------
-----------------------------------------------------
      tramosintec.DELETE;

      ---Miramos el saldo inicial del que hay que
       --- partir(saldo de intereses ó 0)--
      BEGIN
         SELECT imovimi, nnumlin, fcontab
           INTO saldo_ant, num_lin, fultsaldo
           FROM ctaseguro
          WHERE sseguro = psseguro
            AND(cmovimi = 0
                AND fcontab = (SELECT MAX(fcontab)
                                 FROM ctaseguro
                                WHERE sseguro = psseguro
                                  AND cmovimi = 0
                                  AND fcontab < pfecha));
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      saldo_actual := NVL(saldo_ant, 0);
      fultsaldo := NVL(fultsaldo, wfefecto_pol);

      BEGIN
         SELECT ninttec
           INTO v_pintec_saldo
           FROM intertecprod ip, intertecmov im, intertecmovdet ID
          WHERE ip.sproduc = wsproduc
            AND ip.ncodint = im.ncodint
            AND im.ctipo = 1
            AND im.finicio <= fultsaldo
            AND(im.ffin >= fultsaldo
                OR im.ffin IS NULL)
            AND im.ncodint = ID.ncodint
            AND im.finicio = ID.finicio
            AND im.ctipo = ID.ctipo
            AND ID.ndesde <= saldo_actual
            AND ID.nhasta >= saldo_actual;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 104742;
      END;

      indice := 0;
      tramosintec(indice).pinttec := v_pintec_saldo + v_pinttec;
      tramosintec(indice).ffecmov := fultsaldo;

      OPEN c_mov_salt_tramo(fultsaldo);

      LOOP
         FETCH c_mov_salt_tramo
          INTO codi_movimi, imp_movimi, xffecmov;

--dbms_output.put_line('codi_movimi ='||codi_movimi);
--dbms_output.put_line('imp_movimi ='||imp_movimi);
--dbms_output.put_line('xffecmov ='||xffecmov);
         EXIT WHEN c_mov_salt_tramo%NOTFOUND;

         IF codi_movimi > 10 THEN
            imp_movimi := 0 - imp_movimi;
         ELSIF codi_movimi = 0 THEN
            imp_movimi := 0;
         END IF;

         saldo_actual := saldo_actual + imp_movimi;

--dbms_output.put_line('saldo_actual ='||saldo_actual);
         BEGIN
            SELECT ninttec
              INTO v_pintec_nou
              FROM intertecprod ip, intertecmov im, intertecmovdet ID
             WHERE ip.sproduc = wsproduc
               AND ip.ncodint = im.ncodint
               AND im.ctipo = 1
               AND im.finicio <= xffecmov
               AND(im.ffin >= xffecmov
                   OR im.ffin IS NULL)
               AND im.ncodint = ID.ncodint
               AND im.finicio = ID.finicio
               AND im.ctipo = ID.ctipo
               AND ID.ndesde <= saldo_actual
               AND ID.nhasta >= saldo_actual;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 104742;
         END;

         IF v_pintec_saldo <> v_pintec_nou THEN
            indice := indice + 1;
            tramosintec(indice).pinttec := v_pintec_nou + v_pinttec;
            tramosintec(indice).ffecmov := xffecmov;
         END IF;
      END LOOP;

      CLOSE c_mov_salt_tramo;

      --psaldo := saldo_actual;
      n_iteracions := tramosintec.COUNT;

--dbms_output.put_line('n_iteracions ='||n_iteracions);
   ----------------------------------------------------------------------------------------
   ----------------------------------------------------------------------------------------

      --pint_total := 0;
      OPEN c_regctaseg;

      LOOP
         FETCH c_regctaseg
          INTO regcta;

         EXIT WHEN c_regctaseg%NOTFOUND;

         ---Cálculo de los intereses---------------------
         FOR i IN 0 ..(n_iteracions - 1) LOOP
--dbms_output.put_line('n_iteracion ='||i);
          -- ULTIMO DIA MES ANTERIOR
            xpinttec := tramosintec(i).pinttec;
--dbms_output.put_line ('xpinttec: '||xpinttec);
            xfefecto := tramosintec(i).ffecmov;

            IF xfefecto >= regcta.ffecmov THEN
               IF i <> 0 THEN
                  ultim_dia_tramo_anterior := fecha_final - 1;
               ELSE
                  ultim_dia_tramo_anterior := GREATEST(xfefecto, regcta.ffecmov) - 1;
               END IF;

--dbms_output.put_line('Ultim_dia_Tramo_anterior ='||ultim_dia_tramo_anterior);
             -- FECHA INICIO
               IF i <> 0 THEN
                  fecha_inicio := ultim_dia_tramo_anterior + 1;
               ELSE
                  fecha_inicio := GREATEST(xfefecto, regcta.ffecmov);
               END IF;

--dbms_output.put_line('fecha inicio  ='||fecha_inicio);
             -- FECHA FINAL MES
               IF n_iteracions - 1 <> i THEN
                  fecha_final := tramosintec(i + 1).ffecmov;
               ELSE
                  fecha_final := pfecha;
               END IF;

--dbms_output.put_line('fecha final ='||fecha_final);
          -- PERIODO (DIAS DE CALCULO DE MES ACTUAL)
               periodo := fecha_final - fecha_inicio;
--dbms_output.put_line('periodo ='||periodo);
               v_lx1 := pac_provi_mv_pruebas.f_lx_i(fecha_inicio, v_fnacimi, v_sexo,
                                                    any_nacimi, vtipo);
--dbms_output.put_line ('LX1: '||v_lx1);
               v_lx2 := pac_provi_mv_pruebas.f_lx_i(fecha_final, v_fnacimi, v_sexo, any_nacimi,
                                                    vtipo);
--dbms_output.put_line ('LX2: '||v_lx2);
               v_qx :=((v_lx1 - v_lx2) / v_lx1);
--dbms_output.put_line ('QX: '||v_QX);
--dbms_output.put_line('isaldo ='||isaldo);
               intereses := regcta.imovimi
                            *(POWER((1 + xpinttec / 100),(periodo / 365)) * v_lx1 / v_lx2 - 1);

                ---Miramos si el interes calculado tiene que ser negativo o positivo,
               --dependiendo del tipo de movimiento que sea
               IF regcta.cmovimi > 10 THEN
                  intereses := 0 - intereses;
               END IF;

               int_total := int_total + intereses;
 --dbms_output.put_line ('intereses'||intereses);
--dbms_output.put_line ('INT TOTAL: '||int_total);
            END IF;
         END LOOP;

         IF pmodo = 'R' THEN
            BEGIN
               UPDATE ctaseguro
                  SET ccalint = 1
                WHERE sseguro = psseguro
                  AND fcontab = regcta.fcontab
                  AND nnumlin = regcta.nnumlin;
            EXCEPTION
               WHEN OTHERS THEN
                  CLOSE c_regctaseg;

                  RETURN 102537;
            END;
         END IF;
      END LOOP;

      CLOSE c_regctaseg;

      IF pmodo = 'R' THEN
         int_total := f_round(int_total, cmoneda);

         -- Grabamos el registro de intereses
         BEGIN
            SELECT MAX(nnumlin)
              INTO max_numlin
              FROM ctaseguro
             WHERE sseguro = psseguro;

            INSERT INTO ctaseguro
                        (sseguro, fcontab, nnumlin, ffecmov, fvalmov, cmovimi,
                         imovimi, imovim2, nrecibo, ccalint, cmovanu, nsinies)
                 VALUES (psseguro, pfecha, NVL(max_numlin + 1, 0), pfecha, pfecha, 3,
                         int_total, 0, 0, 1, 0, 0);
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 102555;
         END;
      END IF;

      RETURN 0;
   -- BUG -21546_108724- 07/02/2012 - JLTS - Cierre de posibles cursores abiertos, se adiciona EXCEPTION
   EXCEPTION
      WHEN OTHERS THEN
         IF c_mov_salt_tramo%ISOPEN THEN
            CLOSE c_mov_salt_tramo;
         END IF;
   END f_calculo_intereses;

---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
   FUNCTION f_capital(
      num_sesion IN NUMBER,
      psuplem IN NUMBER,
      pmodo IN NUMBER,
      pfefecto IN NUMBER,
      pfecha IN NUMBER,
      psproduc IN NUMBER,
      ipfija IN NUMBER,
      cfpago IN NUMBER,
      iapextin IN NUMBER,
      pfnacimi IN NUMBER,
      nsexe IN NUMBER,
      irevali IN NUMBER,
      prevali IN NUMBER,
      ptipo IN NUMBER,
      pfcaranu IN NUMBER,
      ndiaspro IN NUMBER,
      psseguro IN NUMBER DEFAULT NULL,
      pcmovimi IN NUMBER DEFAULT NULL,
      pimovimi IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
/*******************************************************************************************
   psuplem = 0 -- nueva producción
   psuplem = 1 -- suplementos con linea en ctaseguros (ej. aportación extraordinaria
   psuplem = 2 -- suplementos generales
********************************************************************************************/
      capital        NUMBER;
      capital_mort   NUMBER;
      aportaciones   NUMBER;
      num_err        NUMBER;
      v_fefecto      DATE;
      v_fecha        DATE;
      v_fnacimi      DATE;
      v_frenova      DATE;
      pm_a_fecha     NUMBER;
      fechaini       DATE;
      isaldoini      NUMBER;
      i_tecnic       NUMBER;
      p_gasint       NUMBER;
      p_gasext       NUMBER;
      pm_linea       NUMBER;
   BEGIN
      v_fefecto := TO_DATE(pfefecto, 'yyyymmdd');
      v_fecha := TO_DATE(pfecha, 'yyyymmdd');
      v_fnacimi := TO_DATE(pfnacimi, 'yyyymmdd');
      v_frenova := TO_DATE(pfcaranu, 'yyyymmdd');

--p_control_error(null, 'PROVIS', 'fefecto ='||v_fefecto);
--p_control_error(null, 'PROVIS', 'fecha ='||v_fecha);
--p_control_error(null, 'PROVIS', 'ipfija ='||ipfija);
--p_control_error(null, 'PROVIS', 'cfpago ='||cfpago);
--p_control_error(null, 'PROVIS', 'iapextin ='||iapextin);
--p_control_error(null, 'PROVIS', 'fnacimi ='||v_fnacimi);
--p_control_error(null, 'PROVIS', 'nsexe ='||nsexe);
--p_control_error(null, 'PROVIS', 'irevali ='||irevali);
--p_control_error(null, 'PROVIS', 'prevali ='||prevali);
--p_control_error(null, 'PROVIS', 'frenova ='||v_frenova);
      IF psuplem = 0 THEN
         isaldoini := iapextin;   --+ IPFIJA;
         fechaini := v_fefecto;
      ELSIF psuplem = 1 THEN
         -- Hallamos el interés técnico del producto
         BEGIN
            SELECT pinttec, pgasint, pgasext
              INTO i_tecnic, p_gasint, p_gasext
              FROM productos
             WHERE sproduc = psproduc;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN 104742;   -- Error al buscar el interés técnico del producto
         END;

         pm_a_fecha := f_calculos_provmat(pmodo, psseguro, LAST_DAY(v_fefecto));
         --dbms_output.put_line('pm_a_fecha ='||pm_a_fecha);
         pm_linea := f_provmat_linea(pmodo, psseguro, v_fefecto, pcmovimi, pimovimi, psproduc,
                                     i_tecnic, v_fnacimi, nsexe, ptipo, p_gasext, p_gasint);
--dbms_output.put_line('pm_linea ='||pm_linea);
         isaldoini := pm_a_fecha + pm_linea;
--dbms_output.put_line('saldoini ='||isaldoini);
         fechaini := LAST_DAY(v_fefecto) + 1;
      ELSIF psuplem = 2 THEN
         pm_a_fecha := f_calculos_provmat(pmodo, psseguro, LAST_DAY(v_fefecto));
         isaldoini := pm_a_fecha;
         fechaini := LAST_DAY(v_fefecto) + 1;
      END IF;

      num_err := pac_provi_mv_pruebas.f_calculos_cap_garantit(psuplem, pmodo, fechaini,
                                                              v_fecha, psproduc, ipfija,
                                                              cfpago, isaldoini, v_fnacimi,
                                                              nsexe, irevali, prevali, ptipo,
                                                              v_frenova, ndiaspro, capital,
                                                              capital_mort, aportaciones);

--dbms_output.put_line('num_err ='||num_err);
--dbms_output.put_line('sqlerm ='||sqlerrm);
      IF num_err <> 0 THEN
         RETURN num_err;
      ELSE
         RETURN capital;
      END IF;
   END f_capital;

-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
   FUNCTION f_capital_mort(
      num_sesion IN NUMBER,
      psuplem IN NUMBER,
      pmodo IN NUMBER,
      pfefecto IN NUMBER,
      pfecha IN NUMBER,
      psproduc IN NUMBER,
      ipfija IN NUMBER,
      cfpago IN NUMBER,
      iapextin IN NUMBER,
      pfnacimi IN NUMBER,
      nsexe IN NUMBER,
      irevali IN NUMBER,
      prevali IN NUMBER,
      ptipo IN NUMBER,
      pfcaranu IN NUMBER,
      ndiaspro IN NUMBER)
      RETURN NUMBER IS
      capital        NUMBER;
      capital_mort   NUMBER;
      aportaciones   NUMBER;
      num_err        NUMBER;
      v_fefecto      DATE;
      v_fecha        DATE;
      v_fnacimi      DATE;
      v_frenova      DATE;
   BEGIN
      v_fefecto := TO_DATE(pfefecto, 'yyyymmdd');
      v_fecha := TO_DATE(pfecha, 'yyyymmdd');
      v_fnacimi := TO_DATE(pfnacimi, 'yyyymmdd');
      v_frenova := TO_DATE(pfcaranu, 'yyyymmdd');
      num_err := pac_provi_mv_pruebas.f_calculos_cap_garantit(psuplem, pmodo, v_fefecto,
                                                              v_fecha, psproduc, ipfija,
                                                              cfpago, iapextin, v_fnacimi,
                                                              nsexe, irevali, prevali, ptipo,
                                                              v_frenova, ndiaspro, capital,
                                                              capital_mort, aportaciones);

      IF num_err <> 0 THEN
         RETURN num_err;
      ELSE
         RETURN capital_mort;
      END IF;
   END f_capital_mort;

-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
   FUNCTION f_aportaciones(
      num_sesion IN NUMBER,
      psuplem IN NUMBER,
      pmodo IN NUMBER,
      pfefecto IN NUMBER,
      pfecha IN NUMBER,
      psproduc IN NUMBER,
      ipfija IN NUMBER,
      cfpago IN NUMBER,
      iapextin IN NUMBER,
      pfnacimi IN NUMBER,
      nsexe IN NUMBER,
      irevali IN NUMBER,
      prevali IN NUMBER,
      ptipo IN NUMBER,
      pfcaranu IN NUMBER,
      ndiaspro IN NUMBER)
      RETURN NUMBER IS
      capital        NUMBER;
      capital_mort   NUMBER;
      aportaciones   NUMBER;
      num_err        NUMBER;
      v_fefecto      DATE;
      v_fecha        DATE;
      v_fnacimi      DATE;
      v_frenova      DATE;
   BEGIN
      v_fefecto := TO_DATE(pfefecto, 'yyyymmdd');
      v_fecha := TO_DATE(pfecha, 'yyyymmdd');
      v_fnacimi := TO_DATE(pfnacimi, 'yyyymmdd');
      v_frenova := TO_DATE(pfcaranu, 'yyyymmdd');
      num_err := pac_provi_mv_pruebas.f_calculos_cap_garantit(psuplem, pmodo, v_fefecto,
                                                              v_fecha, psproduc, ipfija,
                                                              cfpago, iapextin, v_fnacimi,
                                                              nsexe, irevali, prevali, ptipo,
                                                              v_frenova, ndiaspro, capital,
                                                              capital_mort, aportaciones);

      IF num_err <> 0 THEN
         RETURN num_err;
      ELSE
         RETURN aportaciones;
      END IF;
   END f_aportaciones;

-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------

   /*******************************************************************************************
      F_TRASPASO_RESPAR: Graba en la tabla v_rescate los valores de rescate calculados
               para cada año, y que están guardados en la tablaPL/SQL RESPAR.
   *********************************************************************************************/
   FUNCTION f_traspaso_respar(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pfcalcul_año IN DATE,
      pfechasup IN DATE,
      pfefecpol IN DATE,
      pcmoneda IN NUMBER)
      RETURN NUMBER IS
      registros      NUMBER;
      xaño           NUMBER;
      xvalres        NUMBER;
      i              NUMBER;
      num_err        NUMBER;
      años           NUMBER;
   BEGIN
      registros := respar.COUNT;

      IF registros > 0 THEN
         DELETE FROM v_rescate
               WHERE sseguro = psseguro
                 AND nmovimi = pnmovimi;

         FOR i IN 1 .. registros LOOP
            xaño := respar(i).anyo;
            num_err := f_difdata(pfefecpol, ADD_MONTHS(pfcalcul_año, xaño * 12), 1, 1, años);

            IF años = 1 THEN
               xvalres := respar(i).ivalres1;
            ELSIF años = 2 THEN
               xvalres := f_round(respar(i).ivalres * 0.93, pcmoneda);
            ELSE
               xvalres := respar(i).ivalres;
            END IF;

            BEGIN
               INSERT INTO v_rescate
                           (sseguro, nmovimi, femisio,
                            frescat, ivalres, finiefe, ffinefe)
                    VALUES (psseguro, pnmovimi, TRUNC(F_SYSDATE),
                            ADD_MONTHS(pfcalcul_año, xaño * 12), xvalres, pfechasup, NULL);
            EXCEPTION
               WHEN OTHERS THEN
                  respar.DELETE;
                  RETURN 107434;   --Error al insertar en la tabla parámetros de rescate
            END;
         END LOOP;

         -- Finalizamos los registros del movimiento anterior.
         BEGIN
            UPDATE v_rescate
               SET ffinefe = pfechasup
             WHERE sseguro = psseguro
               AND ffinefe IS NULL
               AND nmovimi <> pnmovimi;
         EXCEPTION
            WHEN OTHERS THEN
               respar.DELETE;
               RETURN 107433;   -- Error al modificar en la tabla parámetros de rescate
         END;

         -- borramos la tabla PL/SQL
         respar.DELETE;
      END IF;

      RETURN 0;
   END f_traspaso_respar;
END pac_provi_mv_pruebas;

/

  GRANT EXECUTE ON "AXIS"."PAC_PROVI_MV_PRUEBAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PROVI_MV_PRUEBAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PROVI_MV_PRUEBAS" TO "PROGRAMADORESCSI";
