--------------------------------------------------------
--  DDL for Package Body PAC_PROVI_MV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_PROVI_MV" IS
/******************************************************************************
   NOMBRE:     Pac_Provi_Mv
   PROPÓSITO:  Funciones de provisiones

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        XX/XX/XXXX   XXX                1. Creación del package.
   2.0        27/04/2009   APD                2. Bug 9699 - primero se ha de buscar para la actividad en concreto
                                                 y si no se encuentra nada ir a buscar a GARANFORMULA para la actividad cero
   2.1        27/04/2009   APD                3. Bug 9685 - en lugar de coger la actividad de la tabla seguros, llamar a la
                                                 función pac_seguros.ff_get_actividad
   3.0        08/07/2009   DCT                4. 0010612: CRE - Error en la generació de pagaments automàtics.
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
      pinttec        productos.pinttec%TYPE,
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
      v_lx           mortalidad.vfemeni%TYPE := 0;
      v_dx           mortalidad.vfemeni%TYPE := 0;
      v_qx           NUMBER := 0;
      v_px           mortalidad.vfemeni%TYPE := 0;
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
      --v_edad := trunc((months_between(pfecha1,pfecha2)/12),4);
      v_edad := TRUNC(((pfecha1 - pfecha2) / 365.25), 4);
      v_mod2 := v_edad - TRUNC(v_edad);
      v_mod1 := 1 - v_mod2;
      v_lx1 := pac_provi_mv.f_permf2000(6, TRUNC(v_edad), psexo, pnacim, ptipo, 'LX');
      v_lx2 := pac_provi_mv.f_permf2000(6, TRUNC(v_edad) + 1, psexo, pnacim, ptipo, 'LX');
      v_lxi := TRUNC((v_mod1 * v_lx1) +(v_mod2 * v_lx2), 4);
-- v_qxi  := trunc(((v_lx1 - v_lx2) / v_lx1),4);

      --    dbms_output.put_line('EDAD: '||v_edad);
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
      v_lx1 := pac_provi_mv.f_lx_i(pfechaini, pfnacimi, psexo, any_nacim, ptipo);
--dbms_output.put_line ('LX1: '||v_lx1);
      fechafin := pfechafin + 1;
      v_lx2 := pac_provi_mv.f_lx_i(fechafin, pfnacimi, psexo, any_nacim, ptipo);
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

---------------------------------------------------------------------------------------------
------------------------------------------------ ----------------------------------------------
   FUNCTION f_capital_risc(psproduc IN NUMBER, edad IN NUMBER, provision IN NUMBER)
      RETURN NUMBER IS
      pporcaprisc    NUMBER;
      porcaprisc     NUMBER;
      limit_max_capital NUMBER;
      limit_max_capital_65 NUMBER;
      capitalmaxrisc NUMBER;
      capital_mort   NUMBER;
      capital_risc   NUMBER;
   BEGIN
      -- Averiguamos el porcentaje de capital en riesgo marcado en el producto y los
      -- límites de capital
      pporcaprisc := f_detparproductos(psproduc, 'PORCAPITALRISC', 1);
--dbms_output.put_line('PPORCAPRISC ='||pporcaprisc);
--p_control_ERROR(NULL, 'PROVIS', 'PORCAPRISC ='||PORCAPRISC);
      porcaprisc := pporcaprisc / 100;
--dbms_output.put_line('porcaprisc ='||porcaprisc);
      limit_max_capital := f_detparproductos(psproduc, 'IMMAXCAPSIN1ASE', 1);
      limit_max_capital_65 := f_detparproductos(psproduc, 'IMMAXCAPSIN65', 1);

--dbms_output.put_line('limit_max_capital ='||limit_max_capital);
--dbms_output.put_line('limit_65 ='||limit_max_capital_65);
--dbms_output.put_line('edad ='||edad);

      --dbms_output.put_line('NUM_ERR ='||NUM_ERR);
--dbms_output.put_line('edad ='||edad);
      IF edad >= 65 THEN
         capitalmaxrisc := limit_max_capital_65;
      ELSE
         capitalmaxrisc := limit_max_capital;
      END IF;

--dbms_output.put_line('Capitalmaxrisc ='||capitalmaxrisc);
      capital_mort := provision * porcaprisc;

--dbms_output.put_line('capitalmort ='||Capital_Mort);
      IF capital_mort > capitalmaxrisc THEN
         capital_mort := capitalmaxrisc;
      END IF;

      capital_risc := provision + capital_mort;
--dbms_output.put_line('Capital_risc ='||capital_risc);
--dbms_output.put_line('capital_riesc ='||capital_risc);
      RETURN capital_risc;
   END f_capital_risc;

   FUNCTION f_pintec_adicional(
      pmodo IN NUMBER,
      psproduc IN NUMBER,
      reserva_bruta IN NUMBER,
      pfecha IN DATE,
      pinteres OUT NUMBER,
      psseguro IN NUMBER)
      RETURN NUMBER IS
/*******************************************************************************************
    PMODO : 0 - para el capital garantizado al vencimiento
           1 - para el calculo del capital estimado

*******************************************************************************************/
      v_pintec_probable intertecmovdet.ninttec%TYPE;
      v_pintec_adicional intertecmovdet.ninttec%TYPE;
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
         IF psseguro IS NULL THEN   -- queremos el del producto
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
         ELSE   -- queremos el del seguro
--DBMS_OUTPUT.PUT_LINE('***************************************SSEGURO = '||PSSEGURO);
            BEGIN
               SELECT ninttec
                 INTO v_pintec_adicional
                 FROM intertecseg isg, intertecprod ip, intertecmov im, intertecmovdet ID
                WHERE ip.sproduc = psproduc
                  AND ip.ncodint = im.ncodint
                  AND im.ctipo = 1
                  AND isg.sseguro = psseguro
                  -- Se incluye el filtro por fecha para que no busque el interes del último movimiento
                  -- sino la del periodo que le toca, el nvl es para tratar los casos de Nueva Producción
                  -- que no tienen movimientos para la fecha calculada.
                  AND isg.nmovimi = NVL((SELECT MAX(i.nmovimi)
                                           FROM intertecseg i
                                          WHERE i.sseguro = psseguro
                                            AND TRUNC(i.fefemov) <= pfecha),
                                        isg.nmovimi)
                  AND im.finicio <= isg.fefemov
                  AND(im.ffin >= isg.fefemov
                      OR im.ffin IS NULL)
                  AND im.ncodint = ID.ncodint
                  AND im.finicio = ID.finicio
                  AND im.ctipo = ID.ctipo
                  AND ID.ndesde <= reserva_bruta
                  AND ID.nhasta >= reserva_bruta;
--DBMS_OUTPUT.PUT_LINE('***************************************FECHAS ='||PFECHA);
--DBMS_OUTPUT.PUT_LINE('***************************************PINTECADICIONAL ='||V_PINTEC_ADICIONAL);
            EXCEPTION
               WHEN OTHERS THEN
                  RETURN 104742;
            END;
         END IF;
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
      ppgasint IN NUMBER,
      pimpgasext OUT NUMBER,
      pimpgasint OUT NUMBER)
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
      num_err := f_difdata(pfnacimi, pfechaini, 1, 1, edad);
--dbms_output.put_line('edad actuarial ='||edad);
      capital_risc := pac_provi_mv.f_capital_risc(psproduc, edad, reserva_bruta);
--dbms_output.put_line('capital_riesc ='||capital_risc);
      p_mort := pac_provi_mv.f_cr(pfechaini, pfechafin, pfnacimi, pcsexo, ptipo, capital_risc,
                                  pinteres);
--dbms_output.put_line('prima ='||p_mort);
   -- cálculo de los gastos
      gastos_ext := ROUND(reserva_bruta * ppgasext / 100 * w_periodo_prorrat, 8);
      gastos_int := ROUND(reserva_bruta * ppgasint / 100 * w_periodo_prorrat, 8);
      reserva_neta := reserva_bruta - p_mort   -- PRIMA
                                            - gastos_ext   -- gastos externos
                                                        - gastos_int;   -- gastos internos
--dbms_output.put_line('gastos_ext ='||gastos_ext);
--dbms_output.put_line('gastos_int ='||gastos_int);
      v_lx1 := pac_provi_mv.f_lx_i(pfechaini, pfnacimi, pcsexo, any_nacim, ptipo);
--dbms_output.put_line ('LX1: '||v_lx1);
      v_lx2 := pac_provi_mv.f_lx_i(pfechafin + 1, pfnacimi, pcsexo, any_nacim, ptipo);
--dbms_output.put_line ('LX2: '||v_lx2);
          --v_qx  := ((v_lx1 - v_lx2) / v_lx1);
--dbms_output.put_line ('QX: '||v_QX);
--dbms_output.put_line('reserva_neta ='||reserva_neta);
      intereses := reserva_neta
                   *(POWER((1 + pinteres / 100),(w_periodo_prorrat)) * v_lx1 / v_lx2 - 1);
--dbms_output.put_line('INTERESES ='||intereses);
      pm := reserva_neta + intereses;
      pimpgasext := gastos_ext;
      pimpgasint := gastos_int;
      RETURN NVL(pm, 0);
--dbms_output.put_line('pm ='||pm);
   END f_pm;

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
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
      cmovimi = 8 -- traspaso de entrada
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
      v_impgasext    NUMBER;
      v_impgasint    NUMBER;
   BEGIN
--dbms_output.put_line('F_PROVMAT_LINEA');
   -- Calculamos el saldo para cada movimiento para ver si saltamos de tramo
   -- en el interés adicional
 --  NUM_ERR := F_SALDO(PSSEGURO, PFECHA, saldo_ant);
      IF pcmovimi > 10 THEN
         importe := pimovimi * -1;
      ELSE
         importe := pimovimi;
      END IF;

      fecha_final_mes := LAST_DAY(pfecha);
      --  saldo := saldo_ant;-- + importe;

      --  num_err := f_pintec_adicional(0, psproduc, saldo, pfecha,
        --                              v_pintec_adicional_mov);
      pinteres := pinttec;   --+ v_pintec_adicional_mov;
--dbms_output.put_line('LLAMAMOS A F_PM');
      pm := f_pm(importe, pfecha, fecha_final_mes, pinteres, psproduc, pfnacimi, pcsexo, ptipo,
                 pgasext, pgasint, v_impgasext, v_impgasint);
--dbms_output.put_line('pm_mov ='||pm);
      RETURN pm;
   END f_provmat_linea;

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
      psseguro IN NUMBER DEFAULT NULL,
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
    psuplem = 3 => Cartera

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
      i_tecnic       productos.pinttec%TYPE;
      cmoneda        NUMBER := 1;
      isaldo         NUMBER;
      aportacio      NUMBER;
      num_err        NUMBER;
      v_tipo         NUMBER;
      p_gasint       productos.pgasint%TYPE;
      p_gasext       productos.pgasext%TYPE;
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
      v_impgasext    NUMBER;
      v_impgasint    NUMBER;
      v_fefepol      seguros.fefecto%TYPE;
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

-- JLB - I - BUG 18423 COjo la moneda del producto
      cmoneda := pac_monedas.f_moneda_producto(psproduc);

-- JLB - F - BUG 18423 COjo la moneda del producto
      IF psseguro IS NOT NULL THEN
         BEGIN
            SELECT fefecto
              INTO v_fefepol
              FROM seguros
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS THEN
               --se debería controlar el error;
               NULL;
         END;
      END IF;

--dbms_output.put_line('entramos en calculos');
--p_control_error(null, 'apo', 'entramos en cap garantit');

      -- DBMS_OUTPUT.PUT_LINE('i_tecnic ='||i_tecnic);
-- DBMS_OUTPUT.PUT_LINE('p_gasint ='||p_gasint);
-- DBMS_OUTPUT.PUT_LINE('p_gasext ='||p_gasext);
--p_control_error(null, 'apo', 'iapextin ='||iapextin);
   -- Calculamos el inteés probable si el modo = 1
      num_err := f_pintec_adicional(1, psproduc, iapextin, pfefecto, v_pintec_probable, NULL);
--p_control_error(null, 'apo', 'num_err ='||num_err);
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
            IF LAST_DAY(pfechafin) = pfechafin THEN
               n_iteracions := FLOOR(MONTHS_BETWEEN(pfechafin, fechaini)) + 1;
            ELSE
               n_iteracions := FLOOR(MONTHS_BETWEEN(pfechafin, fechaini)) + 2;
            END IF;
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
            -- Treiem el psuplem = 0
            IF NOT(ADD_MONTHS(fecha_inicio_mes, 12) = pfcaranu) THEN   -- AND psuplem IN (0,3)
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
--DBMS_OUTPUT.PUT_LINE('months beween ='||   ABS(MONTHS_BETWEEN(pfcaranu, Fecha_inicio_mes)));
--DBMS_OUTPUT.PUT_LINE('ndiaspro ='||ndiaspro||' v_fefepol='||v_fefepol);
         IF MOD(ABS(MONTHS_BETWEEN(pfcaranu, fecha_inicio_mes)), 12 / cfpago_aux) = 0
            AND cfpago > 0
            AND(i <> 0
                OR psuplem <> 0) THEN
            -- Tenemos en cuenta si hay ndiaspro
            IF i = 1
               AND psuplem = 0
               AND TO_CHAR(fechaini, 'dd') >= ndiaspro THEN
               -- este mes no se hace aportación, se hace el mes siguiente
               NULL;
            ELSIF i = 1
                  AND psuplem = 0
                  AND cfpago <> 12 THEN
               NULL;
            ELSIF psuplem <> 0
                  AND i = 0
                  AND TO_CHAR(v_fefepol, 'dd') >= ndiaspro
                  AND TO_NUMBER(TO_CHAR(fecha_inicio_mes, 'mmyyyy')) =
                                         TO_NUMBER(TO_CHAR(ADD_MONTHS(v_fefepol, 1), 'mmyyyy')) THEN
               -- Comparem mes i any
               NULL;
            ELSE
-- DBMS_OUTPUT.PUT_LINE('hago aportación ='||aportacio);
               isaldo := isaldo + aportacio;
               aportaciones := aportaciones + aportacio;
            --   DBMS_OUTPUT.PUT_LINE('aportaciones ='||aportaciones);
            END IF;
         --end if;
         END IF;

         num_err := f_pintec_adicional(0, psproduc, isaldo, fecha_inicio_mes,
                                       v_pintec_adicional, psseguro);

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
                        pfnacimi, nsexe, ptipo, p_gasext, p_gasint, v_impgasext, v_impgasint);
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
   EXCEPTION
      WHEN OTHERS THEN
--P_Control_Error(NULL, 'error2', SQLERRM);
     -- Protegim l'error de final de canal de comunicació o altres
         RETURN 111933;   -- Error tabla. No hay descripciones en la tabla de datos
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

    pmodo = 0 -- retorna PROVISION MATEMATICA
            1 --         GASTOS EXTERNOS
          2 --         GASTOS INTERNOS
          3 --         GASTOS TOTALES
*************************************************************************/
      v_ftarifa      garanseg.ftarifa%TYPE;
      v_clave        garanformula.clave%TYPE;
      v_sproduc      seguros.sproduc%TYPE;
      v_cactivi      NUMBER;
      v_cgarant      garanseg.cgarant%TYPE;
      i_tecnic       NUMBER;
      p_mort         NUMBER;
      p_mort_mov     NUMBER;
      num_err        NUMBER;
      v_tipo         NUMBER := 1;
      any_nacim      NUMBER;
      v_fnacimi      per_personas.fnacimi%TYPE;
      v_csexo        per_personas.csexper%TYPE;
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
      pm_anterior    ctaseguro.imovimi%TYPE;
      v_fecha_pm_anterior ctaseguro.fvalmov%TYPE;
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
      v_impgasext    NUMBER;
      v_impgasint    NUMBER;
      v_impgasext_mov NUMBER;
      v_impgasint_mov NUMBER;
      resultado      NUMBER;
      v_numres       ctaseguro.nnumlin%TYPE;   --Número de linea de la reducció
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
            AND nnumlin = (SELECT MIN(nnumlin)
                             FROM ctaseguro
                            WHERE sseguro = psseguro
                              AND(cmovimi = 2)   --1,2,4 APORTACIONS
                              AND(TRUNC(ffecmov) BETWEEN f_ini AND f_final
                                                                          --    OR (FCONTAB BETWEEN F_INI AND F_FINAL
                                                                            --           AND FFECMOV < F_INI)
                                 ));

      CURSOR c_movimientos(psseguro NUMBER, f_ini DATE, f_final DATE, pnnumlin NUMBER) IS
         SELECT DECODE(cmovimi,
                       1, imovimi,
                       2, imovimi,
                       4, imovimi,
                       8, imovimi,
                       -imovimi) imovimi,
                ffecmov, fvalmov, nnumlin
           FROM ctaseguro
          WHERE sseguro = psseguro
            AND cmovimi IN(1, 2, 4,   --1,2,4 APORTACIONS
                                   8,   -- Traspaso de entrada
                                     33, 34, 27)
            AND((TRUNC(ffecmov) BETWEEN f_ini AND f_final
                 -- Se coge la fecha mayor entre la entrada y la calculada
                 --  para no tener problemas con los traspasos de fechas anteriores
                 AND TRUNC(fcontab) <= GREATEST(f_final, pfecha))
                -- Se modifica para que coja los movimientos correctos
                OR(TRUNC(fcontab) BETWEEN v_fecha_pm_anterior + 1 AND f_final
                   AND ffecmov <= v_fecha_pm_anterior   --F_INI)
                                                     --  AND nnumlin > pnnumlin
                  )
                -- Se controlan los recibos anulados el mismo dia que se hace la reducción
                OR(TRUNC(fcontab) = v_fecha_pm_anterior
                   AND ffecmov <= v_fecha_pm_anterior
                   AND nnumlin > pnnumlin))
            AND nnumlin <> pnnumlin;   -- NO TENEMOS EN CUENTA LA APORTACIÓN DEL MES
      --AND CMOVANU!=1                                 --EL MOVIMENT NO HA ESTAT ANULAT
   -- AND NNUMLIN!=1; --Em salto el primer rebut
   BEGIN
      -- Si la póliza está anulada en esta fecha la provisión = 0
      -- Miramos si está anulada a esta fecha
      IF f_situacion_v(psseguro, pfecha) = 2 THEN
         RETURN 0;
      END IF;

      -- Se añade la llamada a las formulas del GFI

      -- Buscamos los datos del seguro para PFECHA
      BEGIN
         -- Bug 9685 - APD - 27/04/2009 - en lugar de coger la actividad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
         SELECT gf.clave, ss.sproduc, pac_seguros.ff_get_actividad(ss.sseguro, g.nriesgo),
                g.ftarifa, g.cgarant
           INTO v_clave, v_sproduc, v_cactivi,
                v_ftarifa, v_cgarant
           FROM garanformula gf, garanseg g, historicoseguros s, seguros ss
          WHERE gf.cgarant = g.cgarant
            AND gf.cramo = ss.cramo
            AND gf.cmodali = ss.cmodali
            AND gf.ctipseg = ss.ctipseg
            AND gf.ccolect = ss.ccolect
            AND gf.ccampo = 'IPROAHO'
            AND gf.cactivi = pac_seguros.ff_get_actividad(ss.sseguro, g.nriesgo)
            AND g.finiefe <= pfecha
            AND(g.ffinefe IS NULL
                OR g.ffinefe > pfecha)
            AND g.sseguro = s.sseguro
            AND s.sseguro = ss.sseguro
            AND ss.sseguro = psseguro
            AND s.nmovimi = (SELECT MAX(nmovimi)
                               FROM movseguro
                              WHERE sseguro = psseguro
                                AND fefecto <= pfecha
                                AND femisio < pfecha + 1);
      -- Bug 9685 - APD - 27/04/2009 - Fin
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            BEGIN
               -- Bug 9699 - APD - 27/04/2009 - primero se ha de buscar para la actividad en concreto
               -- y si no se encuentra nada ir a buscar a GARANFORMULA para la actividad cero
               SELECT gf.clave, ss.sproduc,
                      pac_seguros.ff_get_actividad(ss.sseguro, g.nriesgo), g.ftarifa,
                      g.cgarant
                 INTO v_clave, v_sproduc,
                      v_cactivi, v_ftarifa,
                      v_cgarant
                 FROM garanformula gf, garanseg g, historicoseguros s, seguros ss
                WHERE gf.cgarant = g.cgarant
                  AND gf.cramo = ss.cramo
                  AND gf.cmodali = ss.cmodali
                  AND gf.ctipseg = ss.ctipseg
                  AND gf.ccolect = ss.ccolect
                  AND gf.ccampo = 'IPROAHO'
                  AND gf.cactivi = 0
                  AND g.finiefe <= pfecha
                  AND(g.ffinefe IS NULL
                      OR g.ffinefe > pfecha)
                  AND g.sseguro = s.sseguro
                  AND s.sseguro = ss.sseguro
                  AND ss.sseguro = psseguro
                  AND s.nmovimi = (SELECT MAX(nmovimi)
                                     FROM movseguro
                                    WHERE sseguro = psseguro
                                      AND fefecto <= pfecha
                                      AND femisio < pfecha + 1);
            -- Bug 9699 - APD - 27/04/2009 - Fin
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  BEGIN
                     -- Bug 9685 - APD - 27/04/2009 - en lugar de coger la actividad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
                     SELECT gf.clave, s.sproduc,
                            pac_seguros.ff_get_actividad(s.sseguro, g.nriesgo), g.ftarifa,
                            g.cgarant
                       INTO v_clave, v_sproduc,
                            v_cactivi, v_ftarifa,
                            v_cgarant
                       FROM garanformula gf, garanseg g, seguros s
                      WHERE gf.cgarant = g.cgarant
                        AND gf.cramo = s.cramo
                        AND gf.cmodali = s.cmodali
                        AND gf.ctipseg = s.ctipseg
                        AND gf.ccolect = s.ccolect
                        AND gf.ccampo = 'IPROAHO'
                        AND gf.cactivi = pac_seguros.ff_get_actividad(s.sseguro, g.nriesgo)
                        AND g.finiefe <= pfecha
                        AND(g.ffinefe IS NULL
                            OR g.ffinefe > pfecha)
                        AND g.sseguro = s.sseguro
                        AND s.sseguro = psseguro;
                  -- Bug 9685 - APD - 27/04/2009 - Fin
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        BEGIN
                           -- Bug 9699 - APD - 27/04/2009 - primero se ha de buscar para la actividad en concreto
                           -- y si no se encuentra nada ir a buscar a GARANFORMULA para la actividad cero
                           SELECT gf.clave, s.sproduc,
                                  pac_seguros.ff_get_actividad(s.sseguro, g.nriesgo),
                                  g.ftarifa, g.cgarant
                             INTO v_clave, v_sproduc,
                                  v_cactivi,
                                  v_ftarifa, v_cgarant
                             FROM garanformula gf, garanseg g, seguros s
                            WHERE gf.cgarant = g.cgarant
                              AND gf.cramo = s.cramo
                              AND gf.cmodali = s.cmodali
                              AND gf.ctipseg = s.ctipseg
                              AND gf.ccolect = s.ccolect
                              AND gf.ccampo = 'IPROAHO'
                              AND gf.cactivi = 0
                              AND g.finiefe <= pfecha
                              AND(g.ffinefe IS NULL
                                  OR g.ffinefe > pfecha)
                              AND g.sseguro = s.sseguro
                              AND s.sseguro = psseguro;
                        -- Bug 9699 - APD - 27/04/2009 - Fin
                        EXCEPTION
                           WHEN OTHERS THEN
                              v_clave := NULL;
                        END;
                  END;
            END;
      END;

      IF v_clave IS NOT NULL THEN
         num_err := pac_calculo_formulas.calc_formul(pfecha, v_sproduc, v_cactivi, v_cgarant,
                                                     1, psseguro, v_clave, resultado, NULL,
                                                     NULL, 2, v_ftarifa, 'R');
      ELSE
         FOR reg IN c_polizas_provmat LOOP
            -- Tenemos que averiguar cual fue la PM del mes anterior
            BEGIN
               SELECT imovimi, fvalmov, nnumlin
                 INTO pm_anterior, v_fecha_pm_anterior, v_numres
                 FROM ctaseguro
                WHERE sseguro = psseguro
                  AND cmovimi = 0   -- 0 SALDO
                  AND fvalmov = (SELECT MAX(fvalmov)
                                   FROM ctaseguro
                                  WHERE sseguro = psseguro
                                    AND fvalmov < pfecha
                                    AND cmovimi = 0)
                  AND cmovanu != 1;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN   -- NUEVA PRODUCCIÓN. tODAVÍA NO HA PASADO EL PRIMER CIERRE
                  pm_anterior := 0;
                  -- (BUG 3546) Se coge la fecha efecto, pues no se le sumará nada posteriormente
                  v_fecha_pm_anterior := reg.fefecto;
               WHEN OTHERS THEN
                  --DBMS_OUTPUT.PUT_LINE ('PM_A_DATA_INICIAL:SQLERRM:'||SQLERRM);
                  RETURN NULL;
            --    RETURN (-52);
            END;

--dbms_output.put_line('v_fecha_pm_anerior ='||v_fecha_pm_anterior);
      -- Tenemos que averiguar datos del riesgo (asegurado)
            BEGIN
               --Bug10612 - 08/07/2009 - DCT (canviar vista personas)
               --Conseguimos el vagente_poliza y la empresa de la póliza a partir del psseguro
               SELECT cagente, cempres
                 INTO vagente_poliza, vcempres
                 FROM seguros
                WHERE sseguro = psseguro;

               SELECT p.fnacimi, p.csexper
                 INTO v_fnacimi, v_csexo
                 FROM per_personas p, per_detper d, riesgos r
                WHERE d.sperson = p.sperson
                  AND d.cagente = ff_agente_cpervisio(vagente_poliza, f_sysdate, vcempres)
                  AND r.sperson = p.sperson
                  AND r.nriesgo = 1
                  AND r.sseguro = psseguro;
            /*SELECT fnacimi, csexper
              INTO v_fnacimi, v_csexo
              FROM personas p, riesgos r
             WHERE r.sperson = p.sperson
               AND r.nriesgo = 1
               AND r.sseguro = psseguro;*/

            --FI Bug10612 - 08/07/2009 - DCT (canviar vista personas)
            EXCEPTION
               WHEN OTHERS THEN
                  --DBMS_OUTPUT.PUT_LINE ('PERSONAS:'||SQLERRM);
                  RETURN NULL;
            END;

            -- Controlem el calculs de saldo intermitjos (p.e. reduccions)
            IF v_fecha_pm_anterior = LAST_DAY(v_fecha_pm_anterior)
               AND v_fecha_pm_anterior <> reg.fefecto THEN
--      DBMS_OUTPUT.PUT_LINE('v_fecha_pm_anterior + 1'||v_fecha_pm_anterior + 1);
               v_fechaini := v_fecha_pm_anterior + 1;
            ELSE
--    DBMS_OUTPUT.PUT_LINE( 'v_fecha_pm_anterior'||v_fecha_pm_anterior);
               v_fechaini := v_fecha_pm_anterior;
            END IF;

--    DBMS_OUTPUT.PUT_LINE('fecha final'|| v_fechaini);
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
                  IF LAST_DAY(pfecha) = pfecha THEN
                     n_iteracions := FLOOR(MONTHS_BETWEEN(pfecha, v_fechaini)) + 1;
                  ELSE
                     n_iteracions := FLOOR(MONTHS_BETWEEN(pfecha, v_fechaini)) + 2;
                  END IF;
--dbms_output.put_line('n_iteracions caso d='||n_iteracions);
               END IF;
            END IF;

--dbms_output.put_line('n_iteracions ='||n_iteracions);
            FOR i IN 0 ..(n_iteracions - 1) LOOP
--DBMS_OUTPUT.PUT_LINE('n_iteracion ='||i);
         -- ULTIMO DIA MES ANTERIOR
               IF i <> 0 THEN
                  ultim_dia_mes_anterior := fecha_final_mes;
               ELSE
                  ultim_dia_mes_anterior := LAST_DAY(ADD_MONTHS(v_fechaini, -1));
               END IF;

--DBMS_OUTPUT.PUT_LINE('fecha ini='||v_fechaini);
         -- FECHA INICIO MES
               IF i <> 0 THEN
                  fecha_inicio_mes := ultim_dia_mes_anterior + 1;
               ELSE
                  fecha_inicio_mes := v_fechaini;
               END IF;

--DBMS_OUTPUT.PUT_LINE('fecha inicio mes ='||fecha_inicio_mes);
         -- FECHA FINAL MES
               IF LAST_DAY(ultim_dia_mes_anterior + 1) > pfecha THEN
                  fecha_final_mes := pfecha;
               ELSE
                  fecha_final_mes := LAST_DAY(ultim_dia_mes_anterior + 1);
               END IF;

--dbms_output.put_line('fecha final mes ='||fecha_final_mes);
               v_nnumlin := v_numres;
               aportacion := 0;

               --- Para cada aportación realizada se calcula la PM
               --- Para calcular el capital de riesgo y el interés técnico adicional se aplica sobre
               -- la PM del mes anterior + la aportación periódica de ese mes
               FOR c_aport IN c_aportacion_periodica(psseguro, fecha_inicio_mes,
                                                     fecha_final_mes) LOOP
--dbms_output.put_line('aportacion ='||c_aport.imovimi);
--dbms_output.put_line('nnumlin ='||c_aport.nnumlin);
        -- Se té en compte la data del movimient de saldo i no la fecha inici
                  IF c_aport.fvalmov = v_fecha_pm_anterior
                     AND c_aport.nnumlin < v_numres THEN
                     -- No lo tenemos en cuenta, pues es una aportación extraordinaria
                     -- anterior al saldo
                     v_nnumlin := v_numres;
                     aportacion := 0;
                  ELSE
                     v_nnumlin := c_aport.nnumlin;
                     aportacion := c_aport.imovimi;
                  END IF;
               END LOOP;

--dbms_output.put_line('v_nnumlin ='||v_nnumlin);
--dbms_output.put_line('provmatfinalmes ='||provmatfinalmes);
               reserva_bruta := provmatfinalmes + NVL(aportacion, 0);
--dbms_output.put_line('reserva_bruta ='||reserva_bruta);
--DBMS_OUTPUT.PUT_LINE('fecha de inicio mes '||Fecha_inicio_mes);
               num_err := f_pintec_adicional(0, reg.sproduc, reserva_bruta, fecha_inicio_mes,
                                             v_pintec_adicional, psseguro);
               pinteres := reg.pinttec + v_pintec_adicional;
               provmatfinalmes := f_pm(reserva_bruta, fecha_inicio_mes, fecha_final_mes,
                                       pinteres, reg.sproduc, v_fnacimi, v_csexo, v_tipo,
                                       reg.pgasext, reg.pgasint, v_impgasext, v_impgasint);

--dbms_output.put_line('pm_intermedia ='||Provmatfinalmes);
--dbms_output.put_line('llamamos a movimientos con las fechas ini='||fecha_inicio_mes||' fin ='||fecha_final_mes);
--dbms_output.put_line('Moviment:'||NVL(v_nnumlin,0));

               -- Ahora tendremos en cuenta si ha habido más movimientos en el mes
               FOR c_mov IN c_movimientos(psseguro, fecha_inicio_mes, fecha_final_mes,
                                          NVL(v_nnumlin, 0)) LOOP
                  -- Se té en compte la data del movimient de saldo i no la fecha inici
                  IF c_mov.fvalmov = v_fecha_pm_anterior
                     AND c_mov.nnumlin < v_numres THEN
                     NULL;   -- No lo tenemos en cuenta, pues es una aportación extraordinaria
                  -- anterior al saldo
                  ELSE
--dbms_output.put_line('fvalmov ='||c_mov.fvalmov);
--dbms_output.put_line('nnumlin ='||c_mov.nnumlin);
             -- Calculamos el saldo para cada movimiento para ver si saltamos de tramo
          -- en el interés adicional
        --     saldo := reserva_bruta + c_mov.imovimi;
        --     num_err := f_pintec_adicional(0, reg.sproduc, saldo, c_mov.fvalmov,
          --                              v_pintec_adicional_mov);
                     pinteres_mov := reg.pinttec + v_pintec_adicional;   --_mov;
                     pm_mov := f_pm(c_mov.imovimi, c_mov.fvalmov, fecha_final_mes,
                                    pinteres_mov, reg.sproduc, v_fnacimi, v_csexo, v_tipo,
                                    reg.pgasext, reg.pgasint, v_impgasext_mov,
                                    v_impgasint_mov);
--dbms_output.put_line('pm_mov ='||pm_mov);
                     provmatfinalmes := provmatfinalmes + pm_mov;
--dbms_output.put_line('provmatfinalmes ='||provmatfinalmes);
                     v_impgasext := v_impgasext + v_impgasext_mov;
                     v_impgasint := v_impgasint + v_impgasint_mov;
                  END IF;
               END LOOP;
            END LOOP;
         END LOOP;

--dbms_output.put_line('provMatfinalmes ='||provmatfinalmes);
         IF pmodo = 0 THEN   -- PROVISION MATEMÁTICA
            resultado := provmatfinalmes;
         ELSIF pmodo = 1 THEN   -- GASTOS EXTERNOS
            resultado := v_impgasext;
         ELSIF pmodo = 2 THEN   -- gastos internos
            resultado := v_impgasint;
         ELSIF pmodo = 3 THEN   -- gastos totales
            resultado := v_impgasext + v_impgasint;
         ELSIF pmodo = 4 THEN   -- interés aplicado (tecnico + adicional)
            resultado := pinteres;
         END IF;
      END IF;

--p_control_ERROR(NULL, 'PROVIS', 'SALDO ='||CAPITAL);
--dbms_output.put_line('saldo ='||resultado);
      RETURN resultado;
   END f_calculos_provmat;

--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
   FUNCTION f_capital_risc_a_fecha(
      pmodo IN NUMBER,
      psseguro IN NUMBER,
      pfecha IN DATE,
      provision IN NUMBER)
      RETURN NUMBER IS
      v_fnacimi      DATE;
      v_csexo        NUMBER;
      v_sproduc      seguros.sproduc%TYPE;
      num_err        NUMBER;
      capital_risc   NUMBER;
      edad           NUMBER;
      vagente_poliza seguros.cagente%TYPE;
      vcempres       seguros.cempres%TYPE;
   BEGIN
      -- Se añade la llamada a las formulas del GFI
      capital_risc := f_calformulas_cap_garan(psseguro, pfecha, 'IRISCFEC');

--p_control_error('PROVI_MV', 'formula', capital_risc);
      IF capital_risc IS NULL THEN
         -- Si el Capital és zero no s'ha de fer res

         -- Calculamos la edad del riesgo
         BEGIN
            --Bug10612 - 08/07/2009 - DCT (canviar vista personas)
            --Conseguimos el vagente_poliza y la empresa de la póliza a partir del psseguro
            SELECT cagente, cempres
              INTO vagente_poliza, vcempres
              FROM seguros
             WHERE sseguro = psseguro;

            SELECT p.fnacimi, p.csexper
              INTO v_fnacimi, v_csexo
              FROM per_personas p, per_detper d, riesgos r
             WHERE d.sperson = p.sperson
               AND d.cagente = ff_agente_cpervisio(vagente_poliza, f_sysdate, vcempres)
               AND r.sperson = p.sperson
               AND r.nriesgo = 1
               AND r.sseguro = psseguro;
         /*SELECT fnacimi, csexper
           INTO v_fnacimi, v_csexo
           FROM personas p, riesgos r
          WHERE r.sperson = p.sperson
            AND r.nriesgo = 1
            AND r.sseguro = psseguro;*/

         --FI Bug10612 - 08/07/2009 - DCT (canviar vista personas)
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 2222;
         END;

         BEGIN
            SELECT sproduc
              INTO v_sproduc
              FROM seguros
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 1111;
         END;

         num_err := f_difdata(v_fnacimi, pfecha, 1, 1, edad);
         capital_risc := pac_provi_mv.f_capital_risc(v_sproduc, edad, provision);
      ELSIF capital_risc = 0 THEN   -- No se ha encontrado fórmula asociada  o el capital es 0 (esta reducida)
         -- AVT 23-04-2007 S'HI PASSA LA PROVISIÓ
         capital_risc := pac_provi_mv.f_calculos_provmat(0, psseguro, pfecha);
      END IF;

      RETURN capital_risc;
   END f_capital_risc_a_fecha;

--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------

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
   psuplem = 3 -- renovacion de cartera
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
      i_tecnic       productos.pinttec%TYPE;
      p_gasint       productos.pgasint%TYPE;
      p_gasext       productos.pgasext%TYPE;
      pm_linea       NUMBER;
      pinteres       NUMBER;
      v_sseguro      NUMBER;
      f_calcul       DATE;
      v_fsaldo       DATE;
      v_fefepol      DATE;
   BEGIN
--dbms_output.put_line('parametros ='||pfefecto||'-'||pfecha||'-'||pfnacimi||'-'||pfcaranu);
      v_fefecto := TO_DATE(pfefecto, 'yyyymmdd');
      v_fecha := TO_DATE(pfecha, 'yyyymmdd');
      v_fnacimi := TO_DATE(pfnacimi, 'yyyymmdd');
      v_frenova := TO_DATE(pfcaranu, 'yyyymmdd');

--P_Control_Error(NULL, 'PROVIS', 'fefecto ='||v_fefecto);
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
         v_sseguro := NULL;
      ELSIF psuplem = 1 THEN
         -- Hallamos el interés técnico del producto
         BEGIN
            SELECT pinttec, pgasint, pgasext
              INTO i_tecnic, p_gasint, p_gasext
              FROM productos
             WHERE sproduc = psproduc;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN 0;   -- Error al buscar el interés técnico del producto
         END;

         pm_a_fecha := f_calculos_provmat(pmodo, psseguro, LEAST(LAST_DAY(v_fefecto), v_fecha));
--dbms_output.put_line('pm_a_fecha ='||pm_a_fecha);
         pinteres := f_calculos_provmat(4, psseguro, LEAST(LAST_DAY(v_fefecto), v_fecha));
         --p_control_error(null, 'PROVIS', 'PM_AFECHA ='||PM_A_FECHA);
         pm_linea := f_provmat_linea(pmodo, psseguro, v_fefecto, pcmovimi, pimovimi, psproduc,
                                     pinteres, v_fnacimi, nsexe, ptipo, p_gasext, p_gasint);
--dbms_output.put_line('pm_linea ='||pm_linea);
--p_control_error(null, 'PROVIS', 'PM_LINEA ='||PM_LINEA);
         isaldoini := pm_a_fecha + pm_linea;
--dbms_output.put_line('saldoini ='||isaldoini);
         fechaini := LEAST(LAST_DAY(v_fefecto) + 1, v_fecha);
--dbms_output.put_line('fechaini ='||fechaini);
         v_sseguro := psseguro;
      ELSIF psuplem = 2 THEN
       -- miramos si la fecha de efecto del suplemento dista más de un mes del último
       -- cierre del seguro. Si no tiene cierre es la fecha de efecto de la póliza y la
       -- fecha del suplemento no debería ser superior al último día del mes
     --  v_fsaldo := f_fechasaldo(psseguro, v_fefecto);
--dbms_output.put_line('v_fsaldo ='||v_fsaldo);
     --  IF v_fsaldo is null then -- NO HA HABIDO TODAVÍA NINGÚN CIERRE
       --   begin
         --    select fefecto into v_fefepol
            -- from seguros where sseguro = psseguro;
    --      exception
        --     when others then
--dbms_output.put_line(sqlerrm);
            --    v_fefepol := null;
        --  end;
--dbms_output.put_line('v_efepol ='||v_fefepol);
    --      f_calcul := last_day(v_fefepol);
      -- ELSIF ADD_MONTHS(v_fsaldo,1) < v_fefecto THEN -- ES SUPERIOR A 1 MES
        --  f_calcul := last_day(add_months(v_fsaldo,1));
       --else
         -- f_calcul := last_day(v_fefecto);
       --end if;
         IF TO_CHAR(v_fefecto, 'dd') = 1 THEN
            f_calcul := LAST_DAY(ADD_MONTHS(v_fefecto, -1));
         ELSE
            f_calcul := LEAST(LAST_DAY(v_fefecto), v_fecha);
         END IF;

--dbms_output.put_line('f_calcul ='||f_calcul);
         pm_a_fecha := f_calculos_provmat(pmodo, psseguro, f_calcul);
         isaldoini := pm_a_fecha;
         fechaini := LEAST(f_calcul + 1, v_fecha);
         v_sseguro := psseguro;
      ELSIF psuplem = 3 THEN   -- CARTERA
--p_control_error(null, 'car','entramos a capital cartera');
--dbms_output.put_line('ENTRAMOS CAPITAL CARTERA');
--dbms_output.put_line('V_FEFECTO ='||V_FEFECTO);
         pm_a_fecha := f_calculos_provmat(pmodo, psseguro,(v_fefecto - 1));
--dbms_output.put_line('pm_A FECHA DESPUES DE CALCULOS_PROVMAT ='||PM_A_FECHA);
         isaldoini := pm_a_fecha;
         fechaini := v_fefecto;
      END IF;

--p_control_error(null, 'apo','isaldoini ='||isaldoini);
--dbms_output.put_line('llamamos a capital garantizado isaodloini ='||isaldoini);
      num_err := pac_provi_mv.f_calculos_cap_garantit(psuplem, pmodo, fechaini, v_fecha,
                                                      psproduc, ipfija, cfpago, isaldoini,
                                                      v_fnacimi, nsexe, irevali, prevali,
                                                      ptipo, v_frenova, ndiaspro, v_sseguro,
                                                      capital, capital_mort, aportaciones);

--dbms_output.put_line('num_err ='||num_err);
--dbms_output.put_line('sqlerm ='||sqlerrm);
      IF num_err <> 0 THEN
         RETURN 0;
      ELSE
         RETURN capital;
      END IF;
   END f_capital;

-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
   FUNCTION f_capital_actual(psseguro IN NUMBER, pfecha IN DATE, num_err OUT NUMBER)
      RETURN NUMBER IS
      capgar         NUMBER;
      v_ftarifa      DATE;
      v_clave        NUMBER;
      v_sproduc      NUMBER;
      v_cactivi      NUMBER;
      v_cgarant      NUMBER;
   BEGIN
--DBMS_OUTPUT.PUT_LINE('ENTRO EN F_CAPITAL_ACTUAL CON pFECHA ='||pFECHA);
   -- Si la póliza está anulada en esta fecha la provisión = 0
    -- Miramos si está anulada a esta fecha
      IF f_situacion_v(psseguro, pfecha) = 2 THEN
         RETURN 0;
      END IF;

      -- Se añade la llamada a las formulas del GFI

      -- Buscamos los datos del seguro para PFECHA
      BEGIN
         -- Bug 9685 - APD - 27/04/2009 - en lugar de coger la actividad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
         SELECT gf.clave, ss.sproduc, pac_seguros.ff_get_actividad(ss.sseguro, g.nriesgo),
                g.ftarifa, g.cgarant
           INTO v_clave, v_sproduc, v_cactivi,
                v_ftarifa, v_cgarant
           FROM garanformula gf, garanseg g, historicoseguros s, seguros ss
          WHERE gf.cgarant = g.cgarant
            AND gf.cramo = ss.cramo
            AND gf.cmodali = ss.cmodali
            AND gf.ctipseg = ss.ctipseg
            AND gf.ccolect = ss.ccolect
            AND gf.ccampo = 'ICAPCAL'
            AND gf.cactivi = pac_seguros.ff_get_actividad(ss.sseguro, g.nriesgo)
            AND g.finiefe <= pfecha
            AND(g.ffinefe IS NULL
                OR g.ffinefe > pfecha)
            AND g.sseguro = s.sseguro
            AND f_pargaranpro_v(ss.cramo, ss.cmodali, ss.ctipseg, ss.ccolect, 0, g.cgarant,
                                'TIPO') = 5   -- Capital garantizado
            AND s.sseguro = ss.sseguro
            AND ss.sseguro = psseguro
            AND s.nmovimi = (SELECT MAX(nmovimi)
                               FROM movseguro
                              WHERE sseguro = psseguro
                                AND fefecto <= pfecha
                                AND femisio < pfecha + 1);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            BEGIN
               -- Bug 9699 - APD - 27/04/2009 - primero se ha de buscar para la actividad en concreto
               -- y si no se encuentra nada ir a buscar a GARANFORMULA para la actividad cero
               SELECT gf.clave, ss.sproduc,
                      pac_seguros.ff_get_actividad(ss.sseguro, g.nriesgo), g.ftarifa,
                      g.cgarant
                 INTO v_clave, v_sproduc,
                      v_cactivi, v_ftarifa,
                      v_cgarant
                 FROM garanformula gf, garanseg g, historicoseguros s, seguros ss
                WHERE gf.cgarant = g.cgarant
                  AND gf.cramo = ss.cramo
                  AND gf.cmodali = ss.cmodali
                  AND gf.ctipseg = ss.ctipseg
                  AND gf.ccolect = ss.ccolect
                  AND gf.ccampo = 'ICAPCAL'
                  AND gf.cactivi = 0
                  AND g.finiefe <= pfecha
                  AND(g.ffinefe IS NULL
                      OR g.ffinefe > pfecha)
                  AND g.sseguro = s.sseguro
                  AND f_pargaranpro_v(ss.cramo, ss.cmodali, ss.ctipseg, ss.ccolect, 0,
                                      g.cgarant, 'TIPO') = 5   -- Capital garantizado
                  AND s.sseguro = ss.sseguro
                  AND ss.sseguro = psseguro
                  AND s.nmovimi = (SELECT MAX(nmovimi)
                                     FROM movseguro
                                    WHERE sseguro = psseguro
                                      AND fefecto <= pfecha
                                      AND femisio < pfecha + 1);
            -- Bug 9699 - APD - 27/04/2009 - Fin
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  BEGIN
                     -- Bug 9685 - APD - 27/04/2009 - en lugar de coger la actividad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
                     SELECT gf.clave, s.sproduc,
                            pac_seguros.ff_get_actividad(s.sseguro, g.nriesgo), g.ftarifa,
                            g.cgarant
                       INTO v_clave, v_sproduc,
                            v_cactivi, v_ftarifa,
                            v_cgarant
                       FROM garanformula gf, garanseg g, seguros s
                      WHERE gf.cgarant = g.cgarant
                        AND gf.cramo = s.cramo
                        AND gf.cmodali = s.cmodali
                        AND gf.ctipseg = s.ctipseg
                        AND gf.ccolect = s.ccolect
                        AND gf.ccampo = 'ICAPCAL'
                        AND gf.cactivi = pac_seguros.ff_get_actividad(s.sseguro, g.nriesgo)
                        AND g.finiefe <= pfecha
                        AND(g.ffinefe IS NULL
                            OR g.ffinefe > pfecha)
                        AND g.sseguro = s.sseguro
                        AND f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, 0,
                                            g.cgarant, 'TIPO') = 5   -- Capital garantizado
                        AND s.sseguro = psseguro;
                  -- Bug 9685 - APD - 27/04/2009 - Fin
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        -- Bug 9699 - APD - 27/04/2009 - primero se ha de buscar para la actividad en concreto
                        -- y si no se encuentra nada ir a buscar a GARANFORMULA para la actividad cero
                        SELECT gf.clave, s.sproduc,
                               pac_seguros.ff_get_actividad(s.sseguro, g.nriesgo), g.ftarifa,
                               g.cgarant
                          INTO v_clave, v_sproduc,
                               v_cactivi, v_ftarifa,
                               v_cgarant
                          FROM garanformula gf, garanseg g, seguros s
                         WHERE gf.cgarant = g.cgarant
                           AND gf.cramo = s.cramo
                           AND gf.cmodali = s.cmodali
                           AND gf.ctipseg = s.ctipseg
                           AND gf.ccolect = s.ccolect
                           AND gf.ccampo = 'ICAPCAL'
                           AND gf.cactivi = 0
                           AND g.finiefe <= pfecha
                           AND(g.ffinefe IS NULL
                               OR g.ffinefe > pfecha)
                           AND g.sseguro = s.sseguro
                           AND f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, 0,
                                               g.cgarant, 'TIPO') = 5   -- Capital garantizado
                           AND s.sseguro = psseguro;
                  -- Bug 9699 - APD - 27/04/2009 - Fin
                  END;
            END;
      END;

      num_err := pac_calculo_formulas.calc_formul(pfecha, v_sproduc, v_cactivi, v_cgarant, 1,
                                                  psseguro, v_clave, capgar, NULL, NULL, 2,
                                                  v_ftarifa, 'R');
      RETURN capgar;
   EXCEPTION
      WHEN OTHERS THEN
         --P_CONTROL_ERROR('f_capital_actual','error',sqlerrm);
         p_tab_error(f_sysdate, f_user, 'pac_provi_mv.f_capital_actual', 1,
                     'pfecha =' || pfecha || ' sseguro=' || psseguro, SQLERRM);
         -- Protegim l'error de final de canal de comunicació o altres
         num_err := 100825;   -- No hi ha cap garantia introduida
         RETURN NULL;
   END f_capital_actual;

-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
   FUNCTION f_capital_mort_garantit(
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
      edad           NUMBER;
   BEGIN
      v_fefecto := TO_DATE(pfefecto, 'yyyymmdd');
      v_fecha := TO_DATE(pfecha, 'yyyymmdd');
      v_fnacimi := TO_DATE(pfnacimi, 'yyyymmdd');
      v_frenova := TO_DATE(pfcaranu, 'yyyymmdd');
      num_err := pac_provi_mv.f_calculos_cap_garantit(psuplem, pmodo, v_fefecto, v_fecha,
                                                      psproduc, ipfija, cfpago, iapextin,
                                                      v_fnacimi, nsexe, irevali, prevali,
                                                      ptipo, v_frenova, ndiaspro, NULL,
                                                      capital, capital_mort, aportaciones);
      num_err := f_difdata(v_fnacimi, v_fefecto, 1, 1, edad);
      capital_mort := pac_provi_mv.f_capital_risc(psproduc, edad, capital);

      IF num_err <> 0 THEN
         RETURN 0;
      ELSE
         RETURN capital_mort;
      END IF;
   END f_capital_mort_garantit;

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
      num_err := pac_provi_mv.f_calculos_cap_garantit(psuplem, pmodo, v_fefecto, v_fecha,
                                                      psproduc, ipfija, cfpago, iapextin,
                                                      v_fnacimi, nsexe, irevali, prevali,
                                                      ptipo, v_frenova, ndiaspro, NULL,
                                                      capital, capital_mort, aportaciones);

      IF num_err <> 0 THEN
         RETURN 0;
      ELSE
         RETURN aportaciones;
      END IF;
   END f_aportaciones;

------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
   FUNCTION f_calformulas_cap_garan(psseguro IN NUMBER, pfecha IN DATE, pcampo IN VARCHAR2)
      RETURN NUMBER IS
      capgar         NUMBER;
      v_ftarifa      DATE;
      v_clave        NUMBER;
      v_sproduc      NUMBER;
      v_cactivi      NUMBER;
      v_cgarant      NUMBER;
      num_err        NUMBER;
   BEGIN
--DBMS_OUTPUT.PUT_LINE('ENTRO EN F_CAPITAL_ACTUAL CON pFECHA ='||pFECHA);
   -- Si la póliza está anulada en esta fecha la provisión = 0
    -- Miramos si está anulada a esta fecha
      IF f_situacion_v(psseguro, pfecha) = 2 THEN
         RETURN 0;
      END IF;

      -- Se añade la llamada a las formulas del GFI

      -- Buscamos los datos del seguro para PFECHA
      BEGIN
         -- Bug 9685 - APD - 27/04/2009 - en lugar de coger la actividad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
         SELECT gf.clave, ss.sproduc, pac_seguros.ff_get_actividad(ss.sseguro, g.nriesgo),
                g.ftarifa, g.cgarant
           INTO v_clave, v_sproduc, v_cactivi,
                v_ftarifa, v_cgarant
           FROM garanformula gf, garanseg g, historicoseguros s, seguros ss
          WHERE gf.cgarant = g.cgarant
            AND gf.cramo = ss.cramo
            AND gf.cmodali = ss.cmodali
            AND gf.ctipseg = ss.ctipseg
            AND gf.ccolect = ss.ccolect
            AND gf.ccampo = pcampo
            AND gf.cactivi = pac_seguros.ff_get_actividad(ss.sseguro, g.nriesgo)
            AND g.finiefe <= pfecha
            AND(g.ffinefe IS NULL
                OR g.ffinefe > pfecha)
            AND g.sseguro = s.sseguro
            AND f_pargaranpro_v(ss.cramo, ss.cmodali, ss.ctipseg, ss.ccolect, 0, g.cgarant,
                                'TIPO') = 5   -- Capital garantizado
            AND s.sseguro = ss.sseguro
            AND ss.sseguro = psseguro
            AND s.nmovimi = (SELECT MAX(nmovimi)
                               FROM movseguro
                              WHERE sseguro = psseguro
                                AND fefecto <= pfecha
                                AND femisio < pfecha + 1);
      -- Bug 9685 - APD - 27/04/2009 - Fin
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            BEGIN
               -- Bug 9699 - APD - 27/04/2009 - primero se ha de buscar para la actividad en concreto
               -- y si no se encuentra nada ir a buscar a GARANFORMULA para la actividad cero
               SELECT gf.clave, ss.sproduc,
                      pac_seguros.ff_get_actividad(ss.sseguro, g.nriesgo), g.ftarifa,
                      g.cgarant
                 INTO v_clave, v_sproduc,
                      v_cactivi, v_ftarifa,
                      v_cgarant
                 FROM garanformula gf, garanseg g, historicoseguros s, seguros ss
                WHERE gf.cgarant = g.cgarant
                  AND gf.cramo = ss.cramo
                  AND gf.cmodali = ss.cmodali
                  AND gf.ctipseg = ss.ctipseg
                  AND gf.ccolect = ss.ccolect
                  AND gf.ccampo = pcampo
                  AND gf.cactivi = 0
                  AND g.finiefe <= pfecha
                  AND(g.ffinefe IS NULL
                      OR g.ffinefe > pfecha)
                  AND g.sseguro = s.sseguro
                  AND f_pargaranpro_v(ss.cramo, ss.cmodali, ss.ctipseg, ss.ccolect, 0,
                                      g.cgarant, 'TIPO') = 5   -- Capital garantizado
                  AND s.sseguro = ss.sseguro
                  AND ss.sseguro = psseguro
                  AND s.nmovimi = (SELECT MAX(nmovimi)
                                     FROM movseguro
                                    WHERE sseguro = psseguro
                                      AND fefecto <= pfecha
                                      AND femisio < pfecha + 1);
            -- Bug 9699 - APD - 27/04/2009 - Fin
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  BEGIN
                     -- Bug 9685 - APD - 27/04/2009 - en lugar de coger la actividad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
                     SELECT gf.clave, s.sproduc,
                            pac_seguros.ff_get_actividad(s.sseguro, g.nriesgo), g.ftarifa,
                            g.cgarant
                       INTO v_clave, v_sproduc,
                            v_cactivi, v_ftarifa,
                            v_cgarant
                       FROM garanformula gf, garanseg g, seguros s
                      WHERE gf.cgarant = g.cgarant
                        AND gf.cramo = s.cramo
                        AND gf.cmodali = s.cmodali
                        AND gf.ctipseg = s.ctipseg
                        AND gf.ccolect = s.ccolect
                        AND gf.ccampo = pcampo
                        AND gf.cactivi = pac_seguros.ff_get_actividad(s.sseguro, g.nriesgo)
                        AND g.finiefe <= pfecha
                        AND(g.ffinefe IS NULL
                            OR g.ffinefe > pfecha)
                        AND g.sseguro = s.sseguro
                        AND f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, 0,
                                            g.cgarant, 'TIPO') = 5   -- Capital garantizado
                        AND s.sseguro = psseguro;
                  -- Bug 9685 - APD - 27/04/2009 - Fin
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        -- Bug 9699 - APD - 27/04/2009 - primero se ha de buscar para la actividad en concreto
                        -- y si no se encuentra nada ir a buscar a GARANFORMULA para la actividad cero
                        SELECT gf.clave, s.sproduc,
                               pac_seguros.ff_get_actividad(s.sseguro, g.nriesgo), g.ftarifa,
                               g.cgarant
                          INTO v_clave, v_sproduc,
                               v_cactivi, v_ftarifa,
                               v_cgarant
                          FROM garanformula gf, garanseg g, seguros s
                         WHERE gf.cgarant = g.cgarant
                           AND gf.cramo = s.cramo
                           AND gf.cmodali = s.cmodali
                           AND gf.ctipseg = s.ctipseg
                           AND gf.ccolect = s.ccolect
                           AND gf.ccampo = pcampo
                           AND gf.cactivi = 0
                           AND g.finiefe <= pfecha
                           AND(g.ffinefe IS NULL
                               OR g.ffinefe > pfecha)
                           AND g.sseguro = s.sseguro
                           AND f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, 0,
                                               g.cgarant, 'TIPO') = 5   -- Capital garantizado
                           AND s.sseguro = psseguro;
                  -- Bug 9699 - APD - 27/04/2009 - Fin
                  END;
            END;
      END;

      num_err := pac_calculo_formulas.calc_formul(pfecha, v_sproduc, v_cactivi, v_cgarant, 1,
                                                  psseguro, v_clave, capgar, NULL, NULL, 2,
                                                  v_ftarifa, 'R');
      RETURN capgar;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         num_err := 100825;   -- No hi ha cap garantia introduida
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_provi_mv.f_calformulas_cap_garan', 1,
                     'pfecha =' || pfecha || ' sseguro=' || psseguro || ' campo=' || pcampo,
                     SQLERRM);
         -- Protegim l'error de final de canal de comunicació o altres
         num_err := 100825;   -- No hi ha cap garantia introduida
         RETURN NULL;
   END f_calformulas_cap_garan;
------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
END pac_provi_mv;

/

  GRANT EXECUTE ON "AXIS"."PAC_PROVI_MV" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PROVI_MV" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PROVI_MV" TO "PROGRAMADORESCSI";
