--------------------------------------------------------
--  DDL for Package Body PAC_FORMUL_PE_PPA_CALC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_FORMUL_PE_PPA_CALC" IS
   tabla_morta    NUMBER(1) := NULL;
   ddias          NUMBER(3);
   swajuste       NUMBER(1);   -- AJUSTE PARA PRIMAS EN REVISION INTERES
   swbisiesto     NUMBER(1);   -- PARA CONTROL DE AñOS BISIESTOS
   i1             NUMBER(5, 6);   -- INTERES AñO/ 100
   ig             NUMBER(5, 6);   -- INTERES TECNICO / 100
   k              NUMBER(3);   -- DIAS RESTANTES PRIMERA CABEZA
   j              NUMBER(3);   -- DIAS PENDIENTES A 365
   d              NUMBER(3);   -- DIAS TRANSCURRIDOS DE 365
   n              NUMBER(3);   -- AñOS PARA JUBILACION DESDE INICIO
   t              NUMBER(3);   -- AñOS TRANSCURRIDOS    PRIMERA CABEZA
   nedact_112     NUMBER(19, 2);   -- EDAD ACTUAL  + 1 PRIMERA/SEGUNDA CABEZA
   nedact_12s     NUMBER(19, 2);   -- EDAD ACTUAL    PRIMERA/SEGUNDA CABEZA
   nedjub12       NUMBER(19, 2);   -- EDAD JUBILACION  PRIMERA/SEGUNDA CABEZA
--
   aig            NUMBER;   -- AREA DE TRABAJO
   aigs           NUMBER;   -- AREA DE TRABAJO
   --
   fecha_ini      DATE;
------ JG ------
   fe_forzada     DATE;

--
-- CALCULO "NXY" --
--------------------
   FUNCTION calculo_nxy(
      pedad1 IN NUMBER,
      psexo1 IN NUMBER,
      pedad2 IN NUMBER,
      psexo2 IN NUMBER,
      pint_tec IN NUMBER)
      RETURN NUMBER IS
      sgts_pp_nxy    NUMBER(19, 2);
   BEGIN
--
      sgts_pp_nxy := fsimbolconmu_2cab(NULL, tabla_morta, pint_tec / 100, pedad1, psexo1,
                                       pedad2, psexo2, 1);
      RETURN sgts_pp_nxy;
   END calculo_nxy;

--

   -- Calcula probabilitat per 2 caps
-- Nota : per si un dia cal calcular 3 caps, cridar la funció així  Prob2Caps( cap1, Prob2Caps( cap2, cap3 ) )
--        i anàlogament per tants caps com calgui.
   FUNCTION prob2caps(prob1 IN NUMBER, prob2 IN NUMBER)
      RETURN NUMBER IS
   BEGIN
      RETURN prob1 + NVL(prob2, 0) - NVL(prob1 * prob2, 0);
   END;

   FUNCTION omplir_dades_cap(
      p_sesion IN NUMBER,
      pfe_naci IN DATE,
      pko_sexo IN NUMBER,   -- 1 Home, 2 Dona, 0 no hi ha segon prenedor
      pfe_alta IN DATE,
      pint_tec IN NUMBER)
      RETURN rt_dades_cap IS
      v_dades        rt_dades_cap;
      x              NUMBER(3);   -- EDAD AL INICIO DEL CONTRATO
   BEGIN
      IF pko_sexo IN(1, 2) THEN
         -- EDAD INICIAL -- Anys actuarials
         x := GREATEST(TRUNC((MONTHS_BETWEEN(pfe_alta, pfe_naci) + 6) / 12), 1);
         v_dades.edajub := LEAST(x + n, 115);
         v_dades.edact := x + t;
         v_dades.ledact := ff_mortalidad(p_sesion, tabla_morta, v_dades.edact, pko_sexo, NULL,
                                         NULL, 'LX');
         v_dades.ledact_1 := ff_mortalidad(p_sesion, tabla_morta, v_dades.edact + 1, pko_sexo,
                                           NULL, NULL, 'LX');
         v_dades.ledact_d := v_dades.ledact - (v_dades.ledact - v_dades.ledact_1) / 365 * d;
         v_dades.ledjub := ff_mortalidad(p_sesion, tabla_morta, v_dades.edajub, pko_sexo,
                                         NULL, NULL, 'LX');
         v_dades.ledjub_1 := ff_mortalidad(p_sesion, tabla_morta, v_dades.edajub + 1,
                                           pko_sexo, NULL, NULL, 'LX');
         v_dades.ledjub_k := v_dades.ledjub - (v_dades.ledjub - v_dades.ledjub_1) / 365 * k;
         v_dades.nedact := fsimbolconmu(p_sesion, tabla_morta, pint_tec / 100, v_dades.edact,
                                        pko_sexo, 6);
         v_dades.nedact_1 := fsimbolconmu(p_sesion, tabla_morta, pint_tec / 100,
                                          v_dades.edact + 1, pko_sexo, 6);
         v_dades.nedjub := fsimbolconmu(p_sesion, tabla_morta, pint_tec / 100, v_dades.edajub,
                                        pko_sexo, 6);
      END IF;

      RETURN v_dades;
   END;

----------------------------------------------------------------------
--               P R E P A R A R    D A T O S                         --
----------------------------------------------------------------------
   PROCEDURE preparar_datos(
      psesion IN NUMBER,
      psproduc IN productos.sproduc%TYPE,
      pfe_venci IN DATE,
      pfe_naci1 IN DATE,
      pfe_naci2 IN DATE,
      pko_sexo1 IN NUMBER,   -- 1 Home, 2 Dona
      pko_sexo2 IN NUMBER,   -- 1 Home, 2 Dona, 0 no hi ha segon prenedor
      pfe_alta IN DATE,
      pfe_revint IN OUT DATE,
      pfe_proceso IN DATE,
      pint_ano IN NUMBER,
      pint_tec IN NUMBER) IS
      v_2cab         BOOLEAN;   -- TRUE si la pòlissa te Caps
      v_traza        tab_error.ntraza%TYPE;
   BEGIN
      v_traza := 1;
      v_2cab :=(pko_sexo2 = 1
                OR pko_sexo2 = 2);   -- v_2CAB a TRUE si SEXO_ASE2 val 1 o 2
      fe_forzada := NULL;
      --
      tabla_morta := NULL;

      FOR rtablamorta IN (SELECT ctabla
                            FROM garanpro
                           WHERE sproduc = psproduc
                             AND cgarant = 283) LOOP
         tabla_morta := rtablamorta.ctabla;
      END LOOP;

      --
      --
      IF pfe_revint >= pfe_venci THEN
         fe_forzada := pfe_revint;
         pfe_revint := pfe_venci;
      END IF;

--
-- INTERESES --
----------------
      v_traza := 2;
      i1 := pint_ano / 100;
      ig := pint_tec / 100;
--
--
-- DIAS RESTANTES --
--------------------
      v_traza := 3;

      BEGIN
         fecha_ini := TO_DATE(TO_CHAR(pfe_venci, 'YYYY') || TO_CHAR(pfe_alta, 'MMDD'),
                              'YYYYMMDD');
      EXCEPTION
         WHEN OTHERS THEN
            -- Puede fallar sólo en el caso en que la fecha FECHA_INI sea el 29/02/XXXX de un año que no sea bisiesto,
            -- con lo que se calculará la fecha con el último día del mes del año XXXX
            fecha_ini := LAST_DAY(TO_DATE('1' || '/' || TO_CHAR(pfe_alta, 'MM') || '/'
                                          || TO_CHAR(pfe_venci, 'YYYY'),
                                          'DD/MM/YYYY'));
      END;

      IF fecha_ini > pfe_venci THEN
         fecha_ini := ADD_MONTHS(fecha_ini, -12);   -- Resta 1 any
      END IF;

      k := TRUNC(pfe_venci - fecha_ini);
--
--
-- DIAS PENDIENTES --
----------------------
      v_traza := 4;
      j := TRUNC(pfe_revint - pfe_proceso);

      IF j = 366 THEN
         j := 365;
      END IF;

--
--
-- DIAS TRANSCURRIDOS --
------------------------
      v_traza := 5;

      IF fe_forzada >= pfe_venci THEN
         IF k > 0 THEN
            d :=(k - j);
         ELSE
            d :=(365 - j);
         END IF;
      ELSE
         d := TRUNC(pfe_proceso - ADD_MONTHS(pfe_revint, -12));   -- 1 Any abans de revisió

         IF d = 366 THEN
            d := 365;
            swbisiesto := 1;
         ELSE
            swbisiesto := 0;
         END IF;

         IF d = 365
            AND j <> 1 THEN
            swajuste := 1;
         ELSE
            swajuste := 0;
         END IF;
      END IF;

--
--
-- AñOS TRANSCURRIDOS --
------------------------
      v_traza := 6;
      t := TRUNC(MONTHS_BETWEEN(pfe_proceso, pfe_alta) / 12);
--
-- AñOS PARA JUBILACION --
--------------------------
-- Anys sencers
      v_traza := 7;
      n := TRUNC(MONTHS_BETWEEN(pfe_venci, pfe_alta) / 12);
--
--
-- Omple les dades pels CAPS 1 i 2 --
-------------------------------------
      v_traza := 8;
      cap1 := omplir_dades_cap(psesion, pfe_naci1, NVL(pko_sexo1, 0), pfe_alta, pint_tec);
      v_traza := 9;
      cap2 := omplir_dades_cap(psesion, pfe_naci2, NVL(pko_sexo2, 0), pfe_alta, pint_tec);
--
--
-- NEDACT_112 --
----------------
      v_traza := 10;

      IF v_2cab THEN
         nedact_112 := calculo_nxy(cap1.edact + 1, pko_sexo1, cap2.edact + 1, pko_sexo2,
                                   pint_tec);
      END IF;

--
--
-- NEDACT_12S --
----------------
      v_traza := 11;

      IF v_2cab THEN
         nedact_12s := calculo_nxy(cap1.edact, pko_sexo1, cap2.edact, pko_sexo2, pint_tec);
      END IF;

--
--
-- NEDJUB12 --
--------------
      v_traza := 12;

      IF v_2cab THEN
         nedjub12 := calculo_nxy(cap1.edajub, pko_sexo1, cap2.edajub, pko_sexo2, pint_tec);
      ELSE
         nedjub12 := 1;
      END IF;

--
--
-- AIG PARA UNA / DOS CABEZAS --
--------------------------------
--
      v_traza := 13;
      aig := (cap1.nedact_1 - cap1.nedjub) *((1 + ig) **(cap1.edact + 1)) / cap1.ledact_1
             + CASE v_2cab
                WHEN TRUE THEN (cap2.nedact_1 - cap2.nedjub) *((1 + ig) **(cap2.edact + 1))
                               / cap2.ledact_1   -- AIGY
                               - (nedact_112 - nedjub12)
                                 *((1 + ig) **((cap1.edact + cap2.edact) / 2 + 1))
                                 /(cap1.ledact_1 * cap2.ledact_1)   -- AIGXY
                ELSE 0
             END;
--
--
-- -- AIGXS PARA UNA/DOS CABEZAS --
----------------------------
--
      v_traza := 14;
      aigs := (cap1.nedact - cap1.nedjub) *((1 + ig) ** cap1.edact) / cap1.ledact
              + CASE v_2cab
                 WHEN TRUE THEN (cap2.nedact - cap2.nedjub) *((1 + ig) ** cap2.edact)
                                / cap2.ledact   -- AIGYS
                                - (nedact_12s - nedjub12)
                                  *((1 + ig) **((cap1.edact + cap2.edact) / 2))
                                  /(cap1.ledact * cap2.ledact)   -- AIGXS
                 ELSE 0
              END;
   --
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_FORMUL_PE_PPA_CALC.Preparar_Datos', v_traza,
                     'parametros: pSesion=' || psesion || ' pFE_VENCI=' || pfe_venci
                     || ' pFE_ALTA=' || pfe_alta,
                     SQLERRM);
         RAISE;
   END preparar_datos;

----------------------------------------------------------------------
--        PROVISION    MATEMATICA                                   --
----------------------------------------------------------------------
   FUNCTION provision_matematica(
      psesion IN NUMBER,
      psproduc IN productos.sproduc%TYPE,
      pfe_venci IN DATE,
      pfe_naci1 IN DATE,
      pfe_naci2 IN DATE,
      pko_sexo1 IN NUMBER,   -- 1 Home, 2 Dona
      pko_sexo2 IN NUMBER,   -- 1 Home, 2 Dona, 0 no hi ha segon prenedor
      pfe_alta IN DATE,
      pfe_revint IN DATE,
      pfe_proceso IN DATE,
      pint_ano IN NUMBER,
      pint_tec IN NUMBER,
      pdespeses IN NUMBER,
      pprimes IN NUMBER,
      pcap_super IN NUMBER,
      pcap_fall IN NUMBER)
      RETURN NUMBER IS
      vprov_mat      NUMBER;
      vfe_revint     DATE;
      v_traza        tab_error.ntraza%TYPE;

----------------------------------------------------------------------
--  PRIMA --
----------------------------------------------------------------------
      PROCEDURE provision_mat IS
         expo           NUMBER;   -- EXPONENTE
         expo2          NUMBER;   -- EXPONENTE
         v1             NUMBER;   -- INTERES AñO
         vgnt           NUMBER;   -- AREA DE TRABAJO
         vgntk          NUMBER;   -- AREA DE TRABAJO
         nkpxy          NUMBER;   -- AREA DE TRABAJO
         npxy           NUMBER;   --NUMBER(2,6); -- AREA DE TRABAJO
         pxy            NUMBER;   --NUMBER(2,6); -- AREA DE TRABAJO
      BEGIN
         v_traza := 10;
         expo := d / 365;
         v1 :=(1 /(1 + i1)) **(1 - expo);
         expo2 := k / 365;
         vgntk :=(1 /(1 + ig)) **(n - t - 1 + expo2);
         nkpxy := prob2caps(cap1.ledjub_k / cap1.ledact_d, cap2.ledjub_k / cap2.ledact_d);
         pxy := prob2caps(cap1.ledact_1 / cap1.ledact_d, cap2.ledact_1 / cap2.ledact_d);
         vgnt :=(1 /(1 + ig)) **(n - t - 1);
         npxy := prob2caps(cap1.ledjub / cap1.ledact_d, cap2.ledjub / cap2.ledact_d);
         vprov_mat := (pcap_super * v1 * vgntk * nkpxy)
                      + pdespeses * pcap_super
                        *((1 - expo) + aig * v1 * pxy + expo2 * vgnt * v1 * npxy)
                      + pcap_fall *(1 - nkpxy);
      END provision_mat;

----------------------------------------------------------------------
--        PROVISION    MATEMATICA  CAMBIO INTERES     --
----------------------------------------------------------------------
      PROCEDURE provision_mats IS
         expo           NUMBER;   -- EXPONENTE
         expo2          NUMBER;   -- EXPONENTE
         v1             NUMBER;   -- INTERES AñO
         vgnt           NUMBER;   -- AREA DE TRABAJO
         nkpxy          NUMBER;   -- AREA DE TRABAJO
         npxy           NUMBER;   --NUMBER(2,6); -- AREA DE TRABAJO
         vgntk          NUMBER;   -- AREA DE TRABAJO
         pxy            NUMBER;   --NUMBER(2,6); -- AREA DE TRABAJO
      BEGIN
         v_traza := 20;
         expo := d / 365;
         v1 :=(1 /(1 + i1)) **(1 - expo);
         expo2 := k / 365;
         vgntk :=(1 /(1 + ig)) **(n - t + expo2);
         nkpxy := prob2caps(cap1.ledjub_k / cap1.ledact, cap2.ledjub_k / cap2.ledact);
         pxy := prob2caps(cap1.ledact_1 / cap1.ledact, cap2.ledact_1 / cap2.ledact);
         vgnt :=(1 /(1 + ig)) **(n - t);
         npxy := prob2caps(cap1.ledjub / cap1.ledact, cap2.ledjub / cap2.ledact);
         vprov_mat := (pcap_super * v1 * vgntk * nkpxy)
                      + pdespeses * pcap_super
                        *((1 - expo) + aigs * v1 * 1 + expo2 * vgnt * v1 * npxy)
                      + pcap_fall *(1 - nkpxy);
      END provision_mats;

----------------------------------------------------------------------
--        PROVISION    MATEMATICA   T :=  N             --
----------------------------------------------------------------------
      PROCEDURE provision_mat2 IS
         expo           NUMBER;   -- EXPONENTE
         expo2          NUMBER;   -- EXPONENTE
         v1             NUMBER;   -- INTERES AñO
         nkpxy          NUMBER;   -- AREA DE TRABAJO
      BEGIN
         v_traza := 30;
         expo :=(j / 365);
         v1 :=(1 /(1 + i1)) **(expo);
         nkpxy := prob2caps(cap1.ledjub_k / cap1.ledact_d, cap2.ledjub_k / cap2.ledact_d);
         vprov_mat := (pcap_super * v1 * nkpxy) + pdespeses * pcap_super * expo
                      + pcap_fall *(1 - nkpxy);
      END provision_mat2;

----------------------------------------------------------------------
--    PROVISION  MATEMATICA T :=  N / CAMBIO INTERES   --
----------------------------------------------------------------------
      PROCEDURE provision_mat3 IS
         expo           NUMBER;   -- EXPONENTE
         expo2          NUMBER;   -- EXPONENTE
         v1             NUMBER;   -- INTERES AñO
         nkpxy          NUMBER;   -- AREA DE TRABAJO
         vgntk          NUMBER;   -- AREA DE TRABAJO
      BEGIN
         v_traza := 40;
         expo :=(j / 365);
         v1 :=(1 /(1 + i1)) **(expo);
         expo2 := k / 365;
         vgntk :=(1 /(1 + ig)) **(n - t + expo2);
         nkpxy := prob2caps(cap1.ledjub_k / cap1.ledact, cap2.ledjub_k / cap2.ledact);
         vprov_mat := (pcap_super * v1 * vgntk * nkpxy) + pdespeses * pcap_super * expo2
                      + pcap_fall *(1 - nkpxy);
      END provision_mat3;

--
--
----------------------------------------------------------------------
--               RUTINA     D E C I D I R                             --
----------------------------------------------------------------------
      PROCEDURE decidir IS
      BEGIN
         v_traza := 50;

         -- CALCULO DE LA PROVISION MATEMATICA
         IF pfe_revint = pfe_proceso
            AND t < n THEN
            --  PROVISION MATEMATICA CAMBIO INTERES SUPERVIVENCIA
            provision_mats;
         ELSE
            IF pfe_revint = pfe_proceso
               AND t = n
               AND pfe_proceso != pfe_venci THEN
               --  PROVISION MATEMATICA T := N /  CAMBIO INTERES
               provision_mat3;
            ELSE
               IF t < n THEN
                  --  PROVISION MATEMATICA CAMBIO INTERES
                  provision_mat;
               ELSE
                  IF t = n THEN
                     -- PROVISION MATEMATICA T := N
                     provision_mat2;
                  END IF;
               END IF;
            END IF;
         END IF;
      END decidir;

----------------------------------------------------------------------
--       R U T I N A      JUST_IN_CASE
----------------------------------------------------------------------
      PROCEDURE just_in_case IS
         cap_fall_int   NUMBER(15, 2);
         prov_mat_int   NUMBER;   --NUMBER(15, 2);
         verror         NUMBER(1);
         vly_error      VARCHAR2(255);
      BEGIN
         v_traza := 60;
         prov_mat_int := vprov_mat - 5;
         cap_fall_int := pcap_fall;

         IF prov_mat_int > cap_fall_int THEN
            -- Com tractem l'error ?  *****MSR****
            verror := 8;
            vly_error := 'Prov.Matematica >= Cap.Fallecimie';
            p_tab_error(f_sysdate, f_user, 'PAC_FORMUL_PE_PPA_CALC.PROVISION_MATEMATICA',
                        NULL,
                        'Error cálculo provisión ' || vly_error || 'parametros: pSesion='
                        || psesion,
                        'JUST_IN_CASE: Provisión matemática (' || ROUND(vprov_mat, 2)
                        || ') > capital fallecimiento (' || ROUND(pcap_fall, 2) || ')');
            vprov_mat := NULL;
         END IF;
      END just_in_case;
   BEGIN
----------------------------------------------------------------------
--                     E S T R U C T U R A                            --
----------------------------------------------------------------------
--
      v_traza := 1;
      vfe_revint := pfe_revint;
      v_traza := 2;
      preparar_datos(psesion, psproduc, pfe_venci, pfe_naci1, pfe_naci2, pko_sexo1,   -- 1 Home, 2 Dona
                     pko_sexo2,   -- 1 Home, 2 Dona, 0 no hi ha segon prenedor
                     pfe_alta, vfe_revint, pfe_proceso, pint_ano, pint_tec);
      v_traza := 3;
      decidir;
      v_traza := 4;
      just_in_case;
      RETURN vprov_mat;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_FORMUL_PE_PPA_CALC.PROVISION_MATEMATICA',
                     v_traza, 'parametros: pSesion=' || psesion, SQLERRM);
         RAISE;
   END;

----------------------------------------------------------------------
--               C A P I T A L   G A R A N T I Z A D O              --
----------------------------------------------------------------------
   FUNCTION capital_garantizado(
      psesion IN NUMBER,
      psproduc IN productos.sproduc%TYPE,
      pfe_venci IN DATE,
      pfe_naci1 IN DATE,
      pfe_naci2 IN DATE,
      pko_sexo1 IN NUMBER,   -- 1 Home, 2 Dona
      pko_sexo2 IN NUMBER,   -- 1 Home, 2 Dona, 0 no hi ha segon prenedor
      pfe_alta IN DATE,
      pfe_revint IN DATE,
      pfe_proceso IN DATE,
      pint_ano IN NUMBER,
      pint_tec IN NUMBER,
      pdespeses IN NUMBER,
      pprimes IN NUMBER,
      pcap_fall IN NUMBER,
      pprov_mat IN NUMBER)
      RETURN NUMBER IS
      vcap_super     NUMBER;
      vfe_revint     DATE;
      sw_just_in_case NUMBER(1);   -- SW PARA RUITNA JUST IN CASE

--
  ---------------------------------------------------------------------
  --           CAPITAL  SUPERVIVENCIA PRIMERA PRIMA       --
  ----------------------------------------------------------------------
      PROCEDURE capital_super1 IS
         numerador      NUMBER;   -- AREA DE TRABAJO
         denominador    NUMBER;   -- AREA DE TRABAJO
         v1             NUMBER;   -- INTERES AñO
         vg             NUMBER;   -- INTERES TECNICO
         npxy           NUMBER;   --NUMBER(2,6); -- AREA DE TRABAJO
         nkpxy          NUMBER;   -- AREA DE TRABAJO
         vgn1           NUMBER;   --NUMBER(2,6); -- AREA DE TRABAJO
         pxy            NUMBER;   --NUMBER(2,6); -- AREA DE TRABAJO
         expo           NUMBER;   -- EXPONENTE
         expo2          NUMBER;   -- EXPONENTE
      BEGIN
         --
         sw_just_in_case := 1;
         --
         nkpxy := prob2caps(cap1.ledjub_k / cap1.ledact, cap2.ledjub_k / cap2.ledact);
         numerador := pprimes * nkpxy;
         --
         expo := j / 365;
         v1 :=(1 /(1 + i1)) ** expo;
         expo2 := k / 365;
         vg :=(1 /(1 + ig)) **(n - 1 + expo2);
         pxy := prob2caps(cap1.ledact_1 / cap1.ledact, cap2.ledact_1 / cap2.ledact);
         vgn1 :=(1 + ig) **((n - 1) * -1);
         npxy := prob2caps(cap1.ledjub / cap1.ledact, cap2.ledjub / cap2.ledact);
         --
         denominador := v1 * vg * nkpxy
                        + pdespeses *(expo + aig * v1 * pxy + expo2 * vgn1 * v1 * npxy);
         --
         vcap_super := numerador / denominador;
      --
      END capital_super1;

----------------------------------------------------------------------
--     CAPITAL  SUPERVIVENCIA PRIMAS SUCESIVAS     --
----------------------------------------------------------------------
      PROCEDURE capital_supers IS
         numerador      NUMBER;   -- AREA DE TRABAJO
         denominador    NUMBER;   -- AREA DE TRABAJO
         v1             NUMBER;   -- INTERES AñO
         vg             NUMBER;   -- INTERES TECNICO
         npxy           NUMBER;   --NUMBER(2,6); -- AREA DE TRABAJO
         nkpxy          NUMBER;   -- AREA DE TRABAJO
         vgn1           NUMBER;   --NUMBER(2,6); -- AREA DE TRABAJO
         pxy            NUMBER;   --NUMBER(2,6); -- AREA DE TRABAJO
         expo           NUMBER;   -- EXPONENTE
         expo2          NUMBER;   -- EXPONENTE
      BEGIN
         sw_just_in_case := 1;

         IF swajuste = 1 THEN
            cap1.ledact_d := cap1.ledact;
            cap2.ledact_d := cap2.ledact;
            t := t - 1;
         END IF;

         nkpxy := prob2caps(cap1.ledjub_k / cap1.ledact_d, cap2.ledjub_k / cap2.ledact_d);
         numerador := pprimes * nkpxy;
         expo := d / 365;
         v1 :=(1 /(1 + i1)) **(1 - expo);
         expo2 := k / 365;
         vg :=(1 /(1 + ig)) **(n - t - 1 + expo2);
         npxy := prob2caps(cap1.ledjub / cap1.ledact_d, cap2.ledjub / cap2.ledact_d);
         pxy := prob2caps(cap1.ledact_1 / cap1.ledact_d, cap2.ledact_1 / cap2.ledact_d);
         vgn1 :=(1 + ig) **((n - t - 1) * -1);

         IF swajuste = 1
            AND n = t + 1 THEN
            denominador := vg * nkpxy + pdespeses * expo2;
         ELSE
            denominador := v1 * vg * nkpxy
                           + pdespeses
                             *(1 - expo + aig * v1 * pxy + expo2 * vgn1 * v1 * npxy);
         END IF;

         vcap_super := numerador / denominador;
      END capital_supers;

----------------------------------------------------------------------
--        CAPITAL   SUPERVIVENCIA    CAMBIO INTERES   --
----------------------------------------------------------------------
      PROCEDURE capital_super2 IS
         numerador      NUMBER;   -- AREA DE TRABAJO
         denominador    NUMBER;   -- AREA DE TRABAJO
         v1             NUMBER;   -- INTERES AñO
         vg             NUMBER;   -- INTERES TECNICO
         npxy           NUMBER;   --NUMBER(2,6); -- AREA DE TRABAJO
         nkpxy          NUMBER;   -- AREA DE TRABAJO
         vgn1           NUMBER;   --NUMBER(2,6); -- AREA DE TRABAJO
         pxy            NUMBER;   --NUMBER(2,6); -- AREA DE TRABAJO
         expo           NUMBER;   -- EXPONENTE
         expo2          NUMBER;   -- EXPONENTE
      BEGIN
         sw_just_in_case := 2;
         nkpxy := prob2caps(cap1.ledjub_k / cap1.ledact_d, cap2.ledjub_k / cap2.ledact_d);
         numerador := pprov_mat - pcap_fall *(1 - nkpxy);
         expo := j / 365;
         v1 :=(1 /(1 + i1)) ** expo;
         expo2 := k / 365;
         vg :=(1 /(1 + ig)) **(n - t - 1 + expo2);
         npxy := prob2caps(cap1.ledjub / cap1.ledact_d, cap2.ledjub / cap2.ledact_d);
         pxy := prob2caps(cap1.ledact_1 / cap1.ledact_d, cap2.ledact_1 / cap2.ledact_d);
         vgn1 :=(1 /(1 + ig)) **(n - t - 1);
         denominador := v1 * vg * nkpxy
                        + pdespeses *(1 + aig * v1 * pxy +(expo2 * vgn1 * v1 * npxy));
         vcap_super := numerador / denominador;
      END capital_super2;

----------------------------------------------------------------------
--        CAPITAL   SUPERVIVENCIA    CAMBIO INTERES PARA T = N      --
----------------------------------------------------------------------
      PROCEDURE capital_super2_tn IS
         numerador      NUMBER;   -- AREA DE TRABAJO
         denominador    NUMBER;   -- AREA DE TRABAJO
         v1             NUMBER;   -- INTERES AñO
         nkpxy          NUMBER;   -- AREA DE TRABAJO
         expo           NUMBER;   -- EXPONENTE
      BEGIN
         sw_just_in_case := 2;
         nkpxy := prob2caps(cap1.ledjub_k / cap1.ledact_d, cap2.ledjub_k / cap2.ledact_d);
         numerador := pprov_mat - pcap_fall *(1 - nkpxy);
         expo := j / 365;
         v1 :=(1 /(1 + i1)) ** expo;
         denominador := v1 * nkpxy + pdespeses * expo;
         vcap_super := numerador / denominador;
      END capital_super2_tn;

----------------------------------------------------------------------
--        CAPITAL   SUPERVIVENCIA PARA T =  N   --
----------------------------------------------------------------------
      PROCEDURE capital_super3 IS
         numerador      NUMBER;   -- AREA DE TRABAJO
         denominador    NUMBER;   -- AREA DE TRABAJO
         v1             NUMBER;   -- INTERES AñO
         nkpxy          NUMBER;   -- AREA DE TRABAJO
         expo           NUMBER;   -- EXPONENTE
      BEGIN
         --
         sw_just_in_case := 1;
         nkpxy := prob2caps(cap1.ledjub_k / cap1.ledact_d, cap2.ledjub_k / cap2.ledact_d);
         numerador := pprimes * nkpxy;
         expo := (k / 365) -(d / 365);
         v1 :=(1 /(1 + i1)) ** expo;
         denominador := v1 * nkpxy + pdespeses * expo;
         vcap_super := numerador / denominador;
      END capital_super3;

--
--
----------------------------------------------------------------------
--               RUTINA     D E C I D I R                             --
----------------------------------------------------------------------
      PROCEDURE decidir IS
      BEGIN
         -- CALCULO DEL CAPITAL GARANTIZADO AL VENCIMIENTO
         IF pfe_revint = ADD_MONTHS(pfe_proceso, 12)
            AND pfe_proceso != pfe_alta THEN
            -- CAPITAL  SUPERVIVENCIA  CAMBIO INTERES
            capital_super2;
         ELSE
            IF t = n
               AND j = k
               AND pfe_revint = pfe_venci THEN
               -- CAPITAL   SUPERVIVENCIA  CAMBIO INTERES PARA T = N
               --   N : AñOS PARA JUBILACION DESDE INICIO
               --   T : AñOS TRANSCURRIDOS  PRIMERA CABEZA
               capital_super2_tn;
            ELSE
               IF t = n
                  AND j < k
                  AND pfe_revint = pfe_venci THEN
                  --  CAPITAL SUPERVIVENCIA PARA T =  N
                  capital_super3;
               ELSE
                  IF pfe_alta = pfe_proceso THEN
                     -- CAPITAL SUPERVIVENCIA PRIMERA PRIMA
                     capital_super1;
                  ELSE
                     -- CAPITAL SUPERVIVENCIA PRIMAS SUCESIVAS
                     capital_supers;
                  END IF;
               END IF;
            END IF;
         END IF;
      END decidir;

----------------------------------------------------------------------
--       R U T I N A      JUST_IN_CASE
----------------------------------------------------------------------
      PROCEDURE just_in_case IS
         verror         NUMBER(1);
         vly_error      VARCHAR2(255);
         v1             NUMBER;   -- INTERES AñO
         vg             NUMBER;   -- INTERES TECNICO
         v1vg           NUMBER;   --NUMBER(13,2);  -- CAPITAL SUPERVIVENCIA DE COMPROBACION
      BEGIN
         v1 :=(1 + i1) **(j / 365);

         IF t = n THEN
            vg := 1;
         ELSE
            vg :=(1 + ig) **(n - t - 1 +(k / 365));
         END IF;

         IF sw_just_in_case = 1 THEN
            v1vg := v1 * vg * pprimes;
         ELSE
            v1vg := v1 * vg * pprov_mat;
         END IF;

         IF ABS(vcap_super) > ABS((v1vg + 0.10)) THEN
            -- Com tractem l'error ?  *****MSR****
            verror := 9;
            vly_error := 'Calculo Cap.Supervivencia erroneo';
            p_tab_error(f_sysdate, f_user, 'PAC_FORMUL_PE_PPA_CALC.CAPITAL_GARANTIZADO', NULL,
                        'Error cálculo capital garantizado parametros: pSesion=' || psesion,
                        'JUST_IN_CASE: Capital Garantizado (' || ROUND(vcap_super, 2)
                        || ') >  V1VG+0.10 (' || ROUND(v1vg + 0.10, 2) || ')');
            vcap_super := NULL;
         END IF;
      END just_in_case;
   BEGIN
----------------------------------------------------------------------
--                     E S T R U C T U R A                            --
----------------------------------------------------------------------
--
      sw_just_in_case := 0;
      vfe_revint := pfe_revint;
      preparar_datos(psesion, psproduc, pfe_venci, pfe_naci1, pfe_naci2, pko_sexo1,   -- 1 Home, 2 Dona
                     pko_sexo2,   -- 1 Home, 2 Dona, 0 no hi ha segon prenedor
                     pfe_alta, vfe_revint, pfe_proceso, pint_ano, pint_tec);
      decidir;
      just_in_case;
      RETURN vcap_super;
   END;

----------------------------------------------------------------------
--         C A P I T A L _ F A L L E C I M I E N T O                --
----------------------------------------------------------------------
   FUNCTION capital_fallecimiento(
      psesion IN NUMBER,
      psseguro IN seguros.sseguro%TYPE,
      ptablas IN VARCHAR2,
      poperacion IN VARCHAR2,
      pfe_ult_oper IN DATE,
      pfe_proceso IN DATE,
      pfe_interes IN DATE,   -- Data a utilitzar per calcular l'interès
      pprimes IN NUMBER,
      pcap_fall IN NUMBER)
      RETURN NUMBER IS
      --
      --  1.- Inclou els interessos passats però no els futurs.
      --  2.- Entre pFE_PROCESO i pFE_ULT_OPER  no pot haver cap canvi d'interès en cas de CIERRE MENSUAL i RENOVACION
      --  3.- Per PRIMA + SOL es pot passar una pFE_PROCESO posterior a 1 any, aleshores pel primer any s'aplica el tipus d'interès
      --      de l'any i després el tipus d'interès tècnic.
      --
      vsproduc CONSTANT productos.sproduc%TYPE := pac_gfi.f_sgt_parms('SPRODTAR', psesion);
      vnduraci CONSTANT seguros.nduraci%TYPE := pac_gfi.f_sgt_parms('NDURACI', psesion);
      vint_ano CONSTANT NUMBER(5, 4)
                                   := pac_inttec.ff_int_seguro(ptablas, psseguro, pfe_interes);
--    vINT_TEC      CONSTANT NUMBER(5,4) := pac_inttec.ff_int_producto(vSProduc, 1, pFE_PROCESO, 1);
      vint_tec CONSTANT NUMBER(5, 4)
                    := pac_inttec.ff_int_producto(vsproduc, 1, pfe_proceso, NVL(pcap_fall, 1));
      vcap_fall      NUMBER;   --NUMBER(13, 2);
      ddias          NUMBER(6);
      ddias2         NUMBER(6);
   BEGIN
--
      ddias := TRUNC(pfe_proceso - pfe_ult_oper);
--
      vcap_fall := pcap_fall
                   *(1 + vint_ano / 100) **(ddias / 365)   /* * (1 + vINT_TEC / 100 )**(DDIAS2 / 365) */
                   + CASE poperacion
                      WHEN 'PRIMA' THEN pprimes
                      ELSE 0
                   END;
      RETURN vcap_fall;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_FORMUL_PE_PPA_CALC.Capital_Fallecimiento', 1,
                     'parametros: pOPERACION=' || poperacion, SQLERRM);
         RAISE;
   END;

----------------------------------------------------------------------
--                     P R O V M A T                                --
----------------------------------------------------------------------
   FUNCTION provmat(
      p_sesion IN NUMBER,
      psseguro IN seguros.sseguro%TYPE,
      ptablas IN VARCHAR2,
      poperacion IN VARCHAR2,
      pfe_venci IN DATE,
      pfe_alta IN DATE,
      pfe_revint IN DATE,
      pfe_interes IN DATE,   -- Data a utilitzar per calcular l'interès
      pfe_ult_oper IN DATE,
      pfe_proceso IN DATE,
      pprimes IN NUMBER,
      pcap_super IN NUMBER,
      pcap_fall IN NUMBER,
      pprov_mat IN NUMBER)
      RETURN NUMBER IS
      vsproduc CONSTANT productos.sproduc%TYPE := pac_gfi.f_sgt_parms('SPRODTAR', p_sesion);
      vfe_naci1      DATE := TO_DATE(pac_gfi.f_sgt_parms('FNAC_ASE1', p_sesion), 'YYYYMMDD');
      vfe_naci2      DATE := TO_DATE(pac_gfi.f_sgt_parms('FNAC_ASE2', p_sesion), 'YYYYMMDD');
      vko_sexo1      NUMBER(1) := pac_gfi.f_sgt_parms('SEXO_ASE1', p_sesion);
      vko_sexo2      NUMBER(1) := pac_gfi.f_sgt_parms('SEXO_ASE2', p_sesion);
      vnduraci CONSTANT seguros.nduraci%TYPE := pac_gfi.f_sgt_parms('NDURACI', p_sesion);
      vint_ano CONSTANT NUMBER(5, 4)
                                   := pac_inttec.ff_int_seguro(ptablas, psseguro, pfe_interes);
      vint_tec CONSTANT NUMBER(5, 4)
                    := pac_inttec.ff_int_producto(vsproduc, 1, pfe_proceso, NVL(pcap_fall, 1));
      vdespeses CONSTANT NUMBER := pac_gfi.f_sgt_parms('GASTOS', p_sesion) / 100;
      vfe_mue1 CONSTANT NUMBER := pac_gfi.f_sgt_parms('FMUE_ASE1', p_sesion);
      vfe_mue2 CONSTANT NUMBER := pac_gfi.f_sgt_parms('FMUE_ASE2', p_sesion);
      primes         NUMBER;   --NUMBER(13, 2);
      cap_super      NUMBER;   --NUMBER(13, 2);
      cap_fall       NUMBER;   --NUMBER(13, 2);
      prov_mat       NUMBER;   --NUMBER(13, 2);
      v_traza        tab_error.ntraza%TYPE;
   BEGIN
      v_traza := 1;

      -- Tratamiento de fallecimiento de 1 asegurado
      IF vfe_mue1 <> 10000101
         OR vfe_mue2 <> 10000101 THEN   -- hay algún fallecido
         -- solo lo contamos si la póliza no ha revisado
         IF vfe_mue1 <> 10000101
            AND vfe_mue2 = 10000101
            AND(pfe_revint > ADD_MONTHS(TO_DATE(vfe_mue1, 'yyyymmdd'), 12)
                AND poperacion <> 'REVISION')
            OR(pfe_revint > ADD_MONTHS(TO_DATE(vfe_mue1, 'yyyymmdd'), 24)
               AND poperacion = 'REVISION') THEN
            vfe_naci1 := vfe_naci2;
            vko_sexo1 := vko_sexo2;
            vfe_naci2 := TO_DATE('10000101', 'yyyymmdd');
            vko_sexo2 := 0;
         END IF;

         IF vfe_mue2 <> 10000101
            AND vfe_mue1 = 10000101
            AND(pfe_revint > ADD_MONTHS(TO_DATE(vfe_mue1, 'yyyymmdd'), 12)
                AND poperacion <> 'REVISION')
            OR(pfe_revint > ADD_MONTHS(TO_DATE(vfe_mue1, 'yyyymmdd'), 24)
               AND poperacion = 'REVISION') THEN
            vfe_naci2 := TO_DATE('10000101', 'yyyymmdd');
            vko_sexo2 := 0;
         END IF;
      END IF;

      IF poperacion IN('PRIMA') THEN
         primes := pprimes;
         cap_super := pcap_super
                      + capital_garantizado(p_sesion, vsproduc, pfe_venci, vfe_naci1,
                                            vfe_naci2, vko_sexo1, vko_sexo2, pfe_alta,
                                            pfe_revint, pfe_proceso, vint_ano, vint_tec,
                                            vdespeses, pprimes, pcap_fall, pprov_mat);
      ELSE   -- pOPERACION IN ('CIERRE MENSUAL','REVISION')
         primes := 0;
         cap_super := pcap_super;
      END IF;

      v_traza := 2;
      cap_fall := capital_fallecimiento(p_sesion, psseguro, ptablas, poperacion, pfe_ult_oper,
                                        pfe_proceso, pfe_interes, primes, pcap_fall);
      v_traza := 3;
      prov_mat := provision_matematica(p_sesion, vsproduc, pfe_venci, vfe_naci1, vfe_naci2,
                                       vko_sexo1, vko_sexo2, pfe_alta, pfe_revint, pfe_proceso,
                                       vint_ano, vint_tec, vdespeses, primes, cap_super,
                                       cap_fall);
      v_traza := 4;
      RETURN prov_mat;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_FORMUL_PE_PPA_CALC.ProvMat', v_traza,
                     'parametros: psseguro=' || psseguro, SQLERRM);
         RAISE;
   END;

----------------------------------------------------------------------
--                     C A P G A R A N                              --
----------------------------------------------------------------------
   FUNCTION capgaran(
      p_sesion IN NUMBER,
      psseguro IN seguros.sseguro%TYPE,
      ptablas IN VARCHAR2,
      poperacion IN VARCHAR2,
      pfe_venci IN DATE,
      pfe_alta IN DATE,
      pfe_revint IN DATE,
      pfe_interes IN DATE,   -- Data a utilitzar per calcular l'interès
      pfe_ult_oper IN DATE,
      pfe_proceso IN DATE,
      pprimes IN NUMBER,
      pcap_super IN NUMBER,
      pcap_fall IN NUMBER,
      pprov_mat IN NUMBER)
      RETURN NUMBER IS
      vsproduc CONSTANT productos.sproduc%TYPE := pac_gfi.f_sgt_parms('SPRODTAR', p_sesion);
      vfe_naci1 CONSTANT DATE
                            := TO_DATE(pac_gfi.f_sgt_parms('FNAC_ASE1', p_sesion), 'YYYYMMDD');
      vfe_naci2 CONSTANT DATE
                            := TO_DATE(pac_gfi.f_sgt_parms('FNAC_ASE2', p_sesion), 'YYYYMMDD');
      vko_sexo1 CONSTANT NUMBER(1) := pac_gfi.f_sgt_parms('SEXO_ASE1', p_sesion);
      vko_sexo2 CONSTANT NUMBER(1) := pac_gfi.f_sgt_parms('SEXO_ASE2', p_sesion);
      vnduraci CONSTANT seguros.nduraci%TYPE := pac_gfi.f_sgt_parms('NDURACI', p_sesion);
      vint_ano CONSTANT NUMBER(5, 4)
                                   := pac_inttec.ff_int_seguro(ptablas, psseguro, pfe_interes);
      vint_tec CONSTANT NUMBER(5, 4)
                    := pac_inttec.ff_int_producto(vsproduc, 1, pfe_proceso, NVL(pcap_fall, 1));
      vdespeses CONSTANT NUMBER := pac_gfi.f_sgt_parms('GASTOS', p_sesion) / 100;
      vcap_super     NUMBER;   --NUMBER(13, 2);
      vfe_mue1 CONSTANT NUMBER := pac_gfi.f_sgt_parms('FMUE_ASE1', p_sesion);
      vfe_mue2 CONSTANT NUMBER := pac_gfi.f_sgt_parms('FMUE_ASE2', p_sesion);
      xfe_naci1      DATE;
      xfe_naci2      DATE;
      xko_sexo1      NUMBER(1);
      xko_sexo2      NUMBER(1);
      cambia         BOOLEAN := FALSE;
      primes         NUMBER;   --NUMBER(13, 2);
      cap_super      NUMBER;   --NUMBER(13, 2);
      cap_fall       NUMBER;   --NUMBER(13, 2);
      prov_mat       NUMBER;   --NUMBER(13, 2);
      xfe_revint     DATE;
      xfe_interes    DATE;
      xint_ano       NUMBER;
      v_traza        tab_error.ntraza%TYPE;

      PROCEDURE calculo_g IS   --- CALCULO DEL CAPITAL GARANTIZADO AL VENCIMIENTO.
      BEGIN
         v_traza := 10;
         vcap_super := capital_garantizado(p_sesion, vsproduc, pfe_venci, xfe_naci1,
                                           xfe_naci2, xko_sexo1, xko_sexo2, pfe_alta,
                                           xfe_revint, pfe_proceso, NVL(xint_ano, vint_ano),
                                           vint_tec, vdespeses, primes, cap_fall, prov_mat);
      END;

      PROCEDURE calculo_f IS   -- CALCULO DEL CAPITAL DE FALLECIMIENTO
      BEGIN
         v_traza := 20;
         cap_fall := capital_fallecimiento(p_sesion, psseguro, ptablas, poperacion,
                                           pfe_ult_oper, pfe_proceso, xfe_interes, 0,
                                           cap_fall);
      END;

      PROCEDURE calculo_p IS   -- CALCULO DE LA PROVISION MATEMATICA
      BEGIN
         v_traza := 30;
         prov_mat := provision_matematica(p_sesion, vsproduc, pfe_venci, xfe_naci1, xfe_naci2,
                                          xko_sexo1, xko_sexo2, pfe_alta, xfe_revint,
                                          pfe_proceso, NVL(xint_ano, vint_ano), vint_tec,
                                          vdespeses, 0, cap_super, cap_fall);
      END;
   BEGIN
      v_traza := 1;
      primes := pprimes;
      cap_super := pcap_super;
      cap_fall := pcap_fall;
      prov_mat := pprov_mat;
      xfe_revint := pfe_revint;

      -- Tratamiento de fallecimiento de 1 asegurado
      IF vfe_mue1 <> 10000101
         OR vfe_mue2 <> 10000101 THEN   -- hay algún fallecido
         -- solo lo contamos si la póliza no ha revisado
         IF vfe_mue1 <> 10000101
            AND vfe_mue2 = 10000101
            AND(pfe_revint > ADD_MONTHS(TO_DATE(vfe_mue1, 'yyyymmdd'), 12)
                AND poperacion <> 'REVISION')
            OR(pfe_revint > ADD_MONTHS(TO_DATE(vfe_mue1, 'yyyymmdd'), 24)
               AND poperacion = 'REVISION') THEN
            cambia := TRUE;
            xfe_naci1 := vfe_naci2;
            xko_sexo1 := vko_sexo2;
            xfe_naci2 := TO_DATE('10000101', 'yyyymmdd');
            xko_sexo2 := 0;
         END IF;

         IF vfe_mue2 <> 10000101
            AND vfe_mue1 = 10000101
            AND(pfe_revint > ADD_MONTHS(TO_DATE(vfe_mue1, 'yyyymmdd'), 12)
                AND poperacion <> 'REVISION')
            OR(pfe_revint > ADD_MONTHS(TO_DATE(vfe_mue1, 'yyyymmdd'), 24)
               AND poperacion = 'REVISION') THEN
            cambia := TRUE;
            xfe_naci2 := TO_DATE('10000101', 'yyyymmdd');
            xko_sexo2 := 0;
         END IF;

         IF NOT cambia THEN
            xfe_naci1 := vfe_naci1;
            xko_sexo1 := vko_sexo1;
            xfe_naci2 := vfe_naci2;
            xko_sexo2 := vko_sexo2;
         END IF;
      ELSE
         xfe_naci1 := vfe_naci1;
         xko_sexo1 := vko_sexo1;
         xfe_naci2 := vfe_naci2;
         xko_sexo2 := vko_sexo2;
      END IF;

      IF poperacion IN('PRIMA') THEN
         calculo_g;
         cap_super := cap_super + vcap_super;
      ELSIF poperacion IN('CIERRE MENSUAL') THEN
         NULL;
      ELSIF poperacion IN('REVISION') THEN
         primes := 0;
         xfe_interes := pfe_interes - 1;   --porque queremos el interés que tenía la póliza antes de renovar
         calculo_f;
         xint_ano := pac_inttec.ff_int_seguro(ptablas, psseguro, xfe_interes);
         calculo_p;
         xfe_interes := pfe_interes;   -- el interés nuevo que tiene la póliza después de renovar.
         xfe_revint := LEAST(ADD_MONTHS(pfe_revint, 12), pfe_venci);
         xint_ano := pac_inttec.ff_int_seguro(ptablas, psseguro, xfe_interes);

         -- Tratamiento de fallecimiento de 1 asegurado
         IF vfe_mue1 <> 10000101
            OR vfe_mue2 <> 10000101 THEN   -- hay algún fallecido
            -- solo lo contamos si la póliza en la revisión
            IF vfe_mue1 <> 10000101
               AND vfe_mue2 = 10000101 THEN
               xfe_naci1 := vfe_naci2;
               xko_sexo1 := vko_sexo2;
               xfe_naci2 := TO_DATE('10000101', 'yyyymmdd');
               xko_sexo2 := 0;
            END IF;

            IF vfe_mue2 <> 10000101
               AND vfe_mue1 = 10000101 THEN
               xfe_naci2 := TO_DATE('10000101', 'yyyymmdd');
               xko_sexo2 := 0;
            END IF;
         END IF;

         calculo_g;
         cap_super := vcap_super;
         xint_ano := NULL;
      END IF;

      v_traza := 2;
      RETURN cap_super;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_FORMUL_PE_PPA_CALC.Capital_Fallecimiento',
                     v_traza, 'parametros: psseguro=' || psseguro, SQLERRM);
         RAISE;
   END;

----------------------------------------------------------------------
--        PROVISION    MATEMATICA    Z                              --
----------------------------------------------------------------------
   FUNCTION provision_matematica_z(
      psesion IN NUMBER,
      psproduc IN productos.sproduc%TYPE,
      pfe_venci IN DATE,
      pfe_naci1 IN DATE,
      pfe_naci2 IN DATE,
      pko_sexo1 IN NUMBER,   -- 1 Home, 2 Dona
      pko_sexo2 IN NUMBER,   -- 1 Home, 2 Dona, 0 no hi ha segon prenedor
      pfe_alta IN DATE,
      pfe_revint IN DATE,
      pfe_proceso IN DATE,
      pint_ano IN NUMBER,
      pint_tec IN NUMBER,
      pprov_mat IN NUMBER,
      pcap_fall IN NUMBER)
      RETURN NUMBER IS
      vcap_super     NUMBER;
      v_traza        tab_error.ntraza%TYPE;
      vfe_revint     DATE;

----------------------------------------------------------------------
--  PRESTACIÓ SUPERVIVENCIA 'Z'  --
----------------------------------------------------------------------
      PROCEDURE provisionz_mat IS
         expo           NUMBER;   -- EXPONENTE
         expo2          NUMBER;   -- EXPONENTE
         v1             NUMBER;   -- INTERES AñO
         vgnt           NUMBER;   -- AREA DE TRABAJO
         vgntk          NUMBER;   -- AREA DE TRABAJO
         nkpxy          NUMBER;   -- AREA DE TRABAJO
         npxy           NUMBER;   --NUMBER(2,6); -- AREA DE TRABAJO
         pxy            NUMBER;   --NUMBER(2,6); -- AREA DE TRABAJO
      BEGIN
         v_traza := 10;
         expo := d / 365;
         v1 :=(1 /(1 + i1)) **(1 - expo);
         expo2 := k / 365;
         vgntk :=(1 /(1 + ig)) **(n - t - 1 + expo2);
         nkpxy := prob2caps(cap1.ledjub_k / cap1.ledact_d, cap2.ledjub_k / cap2.ledact_d);
         pxy := prob2caps(cap1.ledact_1 / cap1.ledact_d, cap2.ledact_1 / cap2.ledact_d);
         vgnt :=(1 /(1 + ig)) **(n - t - 1);
         npxy := prob2caps(cap1.ledjub / cap1.ledact_d, cap2.ledjub / cap2.ledact_d);
         vcap_super := (pprov_mat - pcap_fall *(1 - nkpxy))
                       /(v1 * vgntk * nkpxy
                         + 0.001 *((1 - expo) + aig * v1 * pxy + expo2 * vgnt * v1 * npxy));
      END provisionz_mat;

----------------------------------------------------------------------
--        PRESTACIO SUPERVIVENCIA T :=  N             --
----------------------------------------------------------------------
      PROCEDURE provisionz_mat2 IS
         expo           NUMBER;   -- EXPONENTE
         expo2          NUMBER;   -- EXPONENTE
         v1             NUMBER;   -- INTERES AñO
         nkpxy          NUMBER;   -- AREA DE TRABAJO
      BEGIN
         v_traza := 30;
         expo :=(j / 365);
         v1 :=(1 /(1 + i1)) **(expo);
         nkpxy := prob2caps(cap1.ledjub_k / cap1.ledact_d, cap2.ledjub_k / cap2.ledact_d);
         vcap_super := (pprov_mat - pcap_fall *(1 - nkpxy)) /(v1 * nkpxy + 0.001 * expo);
      END provisionz_mat2;
   BEGIN
      v_traza := 1;
      vfe_revint := pfe_revint;
      v_traza := 2;
      preparar_datos(psesion, psproduc, pfe_venci, pfe_naci1, pfe_naci2, pko_sexo1,   -- 1 Home, 2 Dona
                     pko_sexo2,   -- 1 Home, 2 Dona, 0 no hi ha segon prenedor
                     pfe_alta, vfe_revint, pfe_proceso, pint_ano, pint_tec);
      v_traza := 3;

      -- T : Anys transcorreguts
      -- N : Anys per la jubilació des del principi
      IF t = n
         OR t > n THEN
         provisionz_mat2;
      ELSE
         provisionz_mat;
      END IF;

      RETURN vcap_super;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_FORMUL_PE_PPA_CALC.PROVISION_MATEMATICA_Z',
                     v_traza, 'parametros: pSesion=' || psesion, SQLERRM);
         RAISE;
   END;

----------------------------------------------------------------------
--                     P R O V M A T Z                              --
----------------------------------------------------------------------
   FUNCTION provmatz(
      p_sesion IN NUMBER,
      psseguro IN seguros.sseguro%TYPE,
      ptablas IN VARCHAR2,
      poperacion IN VARCHAR2,
      pfe_venci IN DATE,
      pfe_alta IN DATE,
      pfe_revint IN DATE,
      pfe_interes IN DATE,   -- Data a utilitzar per calcular l'interès
      pfe_proceso IN DATE,
      pcap_super IN NUMBER,
      pcap_fall IN NUMBER,
      pprov_mat IN NUMBER)
      RETURN NUMBER IS
      vsproduc CONSTANT productos.sproduc%TYPE := pac_gfi.f_sgt_parms('SPRODTAR', p_sesion);
      vfe_naci1 CONSTANT DATE
                            := TO_DATE(pac_gfi.f_sgt_parms('FNAC_ASE1', p_sesion), 'YYYYMMDD');
      vfe_naci2 CONSTANT DATE
                            := TO_DATE(pac_gfi.f_sgt_parms('FNAC_ASE2', p_sesion), 'YYYYMMDD');
      vko_sexo1 CONSTANT NUMBER(1) := pac_gfi.f_sgt_parms('SEXO_ASE1', p_sesion);
      vko_sexo2 CONSTANT NUMBER(1) := pac_gfi.f_sgt_parms('SEXO_ASE2', p_sesion);
      vint_ano CONSTANT NUMBER(5, 4)
                                   := pac_inttec.ff_int_seguro(ptablas, psseguro, pfe_interes);
      vint_tec CONSTANT NUMBER(5, 4)
                    := pac_inttec.ff_int_producto(vsproduc, 1, pfe_proceso, NVL(pcap_fall, 1));
      cap_super      NUMBER;   --NUMBER(13, 2);
      v_traza        tab_error.ntraza%TYPE;
   BEGIN
      v_traza := 1;

      IF poperacion IN('Z') THEN
         cap_super := pcap_super
                      + provision_matematica_z(p_sesion, vsproduc, pfe_venci, vfe_naci1,
                                               vfe_naci2, vko_sexo1, vko_sexo2, pfe_alta,
                                               pfe_revint, pfe_proceso, vint_ano, vint_tec,
                                               pprov_mat, pcap_fall);
      ELSE
         cap_super := pcap_super;
      END IF;

      v_traza := 2;
      RETURN cap_super;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_FORMUL_PE_PPA_CALC.ProvMatZ', v_traza,
                     'parametros: psseguro=' || psseguro, SQLERRM);
         RAISE;
   END;

----------------------------------------------------------------------
--                     INTERES PROMOCIONAL                          --
----------------------------------------------------------------------
   FUNCTION interes_promocional(
      psesion IN NUMBER,
      psseguro IN NUMBER,
      ptablas IN VARCHAR2,
      pfecalta IN DATE,
      pfecproceso IN DATE,
      pprimainicial IN seguros.iprianu%TYPE,
      pinterespromocional IN NUMBER)
      RETURN NUMBER IS
      v_prima        NUMBER;   --NUMBER(17, 2);
      v_aux CONSTANT NUMBER := 1 / 12;
      v_interes_mes  NUMBER;
      v_supervivencia_1 NUMBER;
      v_supervivencia_2 NUMBER;
      v_traza        tab_error.ntraza%TYPE;
      v_sproduc CONSTANT productos.sproduc%TYPE := pac_gfi.f_sgt_parms('SPRODUC', psesion);
      --v_InteresTecnico  CONSTANT NUMBER(5,4) :=  pac_inttec.ff_int_producto(v_SProduc, 1, pFecProceso, 1 );
      v_interestecnico CONSTANT NUMBER(5, 4)
                                      := pac_inttec.ff_int_seguro(ptablas, psseguro, pfecalta);
      v_fecnaci1 CONSTANT DATE
                             := TO_DATE(pac_gfi.f_sgt_parms('FNAC_ASE1', psesion), 'YYYYMMDD');
      v_fecnaci2 CONSTANT DATE
                             := TO_DATE(pac_gfi.f_sgt_parms('FNAC_ASE2', psesion), 'YYYYMMDD');
      v_sexo1 CONSTANT NUMBER(1) := pac_gfi.f_sgt_parms('SEXO_ASE1', psesion);
      v_sexo2 CONSTANT NUMBER(1) := pac_gfi.f_sgt_parms('SEXO_ASE2', psesion);
   BEGIN
      IF pinterespromocional < 0
         OR pinterespromocional > 0 THEN
         v_traza := 1;
         -- Obtenim la taula de mortalitat a aplicar-hi
         tabla_morta := NULL;

         FOR rtablamorta IN (SELECT ctabla
                               FROM garanpro
                              WHERE sproduc = v_sproduc
                                AND cgarant = 283) LOOP
            tabla_morta := rtablamorta.ctabla;
         END LOOP;

         v_traza := 2;
         -- Obtenim les dades per cada assegurat
         t := 0;
         n := 0;
         cap1 := omplir_dades_cap(psesion, v_fecnaci1, NVL(v_sexo1, 0), pfecalta,
                                  v_interestecnico);
         cap2 := omplir_dades_cap(psesion, v_fecnaci2, NVL(v_sexo2, 0), pfecalta,
                                  v_interestecnico);
         v_traza := 3;
         -- Per/u d'Interes extra per 1 més
         v_interes_mes :=(1 + pinterespromocional / 100 - v_interestecnico / 100) ** v_aux;
         v_traza := 4;
         -- Invers de les probabilitats que continuin vius els caps, en per/u
         v_supervivencia_1 := cap1.ledact /(cap1.ledact - (cap1.ledact - cap1.ledact_1) * v_aux);
         v_supervivencia_2 := cap2.ledact /(cap2.ledact - (cap2.ledact - cap2.ledact_1) * v_aux);
         v_traza := 5;
         -- Incrementem la prima inicial per l'interès més la proporció que li correspongui pels que es morin durant el primer mes.
         v_prima := pprimainicial * v_interes_mes
                    * prob2caps(v_supervivencia_1, v_supervivencia_2);
      ELSE
         v_prima := pprimainicial;
      END IF;

      RETURN v_prima;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_FORMUL_PE_PPA_CALC.Interes_Promocional', v_traza,
                     'parametros: pSesion=' || psesion, SQLERRM);
         RAISE;
   END;
END;

/

  GRANT EXECUTE ON "AXIS"."PAC_FORMUL_PE_PPA_CALC" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_FORMUL_PE_PPA_CALC" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_FORMUL_PE_PPA_CALC" TO "PROGRAMADORESCSI";
