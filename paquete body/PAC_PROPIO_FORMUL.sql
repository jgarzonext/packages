--------------------------------------------------------
--  DDL for Package Body PAC_PROPIO_FORMUL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_PROPIO_FORMUL" IS
   /******************************************************************************
      NOMBRE:     PAC_PROPIO_FORMUL
      PROPÓSITO:  Funciones calculo ahorro general

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        XX/XX/XXXX   XXX                1. Creación del package.
      1.1        30/01/2009   JRH                2. Bug-8782 Revisión cálculo capital garantizado en productos de Ahorro
      1.2        01/03/2009   JRH                3. Bug 7959 Decesos
      1.3        01/03/2009   JRH                4. 0009541   CRE - Incidència Cartera de Decesos
      1.4        01/05/2009   JRH                7. Bug 0009172: CRE055 - Rentas regulares e irregulares con cálculos a partir de renta
      1.5        21/05/2009   JRH                7. Bug 9540: CRE - Parametritzar sinistres de Decesos
      1.6        21/07/2009   JRH                8. Bug 10784: CRE - Modificaciones en producto Decesos
      5.0        03/11/2009   JMF                5. 0011678 CRE - Ajustes cartera PPJ dinámico y Pla Estudiant
      6.0        03/11/2009   JRH                6. 0011715: Proviones matématicas del CV Previsió
      7.0        04/11/2009   RSC                7. 0011771: CRE - Ajustes en simulación y contratación PPJ Dinámico/Pla Estudiant
      8.0        09/12/2009   APD                8. Bug 11896 - se sustituye el TIPO = 6 por 13
      9.0        10/02/2010   ICV                9. 0012912: CRE080 - Pantalla de simulacion de saldo deutors
     10.0        19/07/2010   JRH                10. 0015412: CRE - Aportacions extraordinàries en el mes de venciment de la pòlissa
     11.0        29/11/2011   DRA                11. 0020676: CRE998 - Creació del nou producte PPJ Empleats
     12.0        22/06/2012   FAL                12. 0022498: CRE_800: Producte CVPrevisió
     13.0        25/06/2013   RCL                13. 0024697: Canvi mida camp sseguro
   ******************************************************************************/
   gsesion        NUMBER;
   giii           NUMBER;
   geee           NUMBER;
   isi            NUMBER;
   ptipoint       NUMBER;
   sexo           NUMBER;
   fecefe         NUMBER;
   fec_vto        NUMBER;
   fnacimi        NUMBER;
   fecha          NUMBER;
   capgaranant    NUMBER;
   factorcap      NUMBER;
   fpagprima      NUMBER;
   resp1004       NUMBER;
   resp1003       NUMBER;
   sproduc        NUMBER;
   nmovimi        NUMBER;
   nriesgo        NUMBER;
   v_numres       NUMBER;
   fecultsald     DATE;
   inici_any      DATE;
   inici_trim     DATE;
   fi_trim        DATE;
   fref           DATE;
   --Edades iniciales
   edat_inici_any NUMBER;
   edat_inici_trim NUMBER;
   edat_actual    NUMBER;
   edat_31122008  NUMBER;
   edat_jub       NUMBER;
   pm_anterior    NUMBER;
   pcapgarant     NUMBER;
   pcapfallant    NUMBER;

   FUNCTION f_trim(fref IN DATE)
      RETURN DATE IS
      valor          NUMBER;
   BEGIN
      RETURN LAST_DAY('01' || LPAD(CEIL(TO_CHAR(fref, 'MM') / 3) * 3, 2, 0)
                      || TO_CHAR(fref, 'YYYY'));
   END f_trim;

   FUNCTION i_trim(fref IN DATE)
      RETURN DATE IS
      valor          NUMBER;
   BEGIN
      RETURN ADD_MONTHS(f_trim(fref), -3) + 1;
   END i_trim;

   FUNCTION i_anyo(fref IN DATE)
      RETURN DATE IS
      valor          NUMBER;
   BEGIN
      RETURN TO_DATE('01/01' || TO_CHAR(fref, 'YYYY'), 'DD/MM/YYYY') - 1;
   END i_anyo;

   FUNCTION edad_ini_any(fref IN DATE)
      RETURN NUMBER IS
      valor          NUMBER;
   BEGIN
      valor := TRUNC(((i_anyo(fref) - TO_DATE(fnacimi, 'YYYYMMDD')) / 365.25), 2);
      RETURN valor;
   END edad_ini_any;

   FUNCTION edad_ini_trim(fref IN DATE)
      RETURN NUMBER IS
      valor          NUMBER;
   BEGIN
      valor := TRUNC(((i_trim(fref) - TO_DATE(fnacimi, 'YYYYMMDD')) / 365.25), 2);
      RETURN valor;
   END edad_ini_trim;

   FUNCTION edad_act(fref IN DATE)
      RETURN NUMBER IS
      valor          NUMBER;
   BEGIN
      valor :=
         TRUNC
             (((   --f_trim(FRef) -- BUG 8782 - 02/2009 - JRH  -  Ja no va per fi de trimestre
                fref - TO_DATE(fnacimi, 'YYYYMMDD'))
               / 365.25),
              2);
      RETURN valor;
   END edad_act;

   FUNCTION edad_31122008(fref IN DATE)
      RETURN NUMBER IS
      valor          NUMBER;
   BEGIN
      valor := TRUNC(((TO_DATE('31/12/2008', 'DD/MM/YYYY') - TO_DATE(fnacimi, 'YYYYMMDD'))
                      / 365.25),
                     2);
      RETURN valor;
   END edad_31122008;

   FUNCTION edad_jubil(fref IN DATE)
      RETURN NUMBER IS
      valor          NUMBER;
   BEGIN
      valor := TRUNC(((TO_DATE(fec_vto, 'YYYYMMDD') - TO_DATE(fnacimi, 'YYYYMMDD')) / 365.25),
                     2);
      RETURN valor;
   END edad_jubil;

   FUNCTION fedad_aseg(pfecha IN DATE)
      RETURN NUMBER IS
      valor          NUMBER;
   BEGIN
      valor := TRUNC(((pfecha - TO_DATE(fnacimi, 'YYYYMMDD')) / 365.25), 2);
      RETURN valor;
   END fedad_aseg;

   FUNCTION f_pla_ini(pfecha IN DATE)
      RETURN NUMBER IS
      valor          NUMBER;
   BEGIN
      valor := edat_inici_any - fedad_aseg(pfecha);

      IF valor < 0 THEN
         RETURN 0;
      ELSE
         RETURN valor;
      END IF;

      RETURN valor;
   END f_pla_ini;

   FUNCTION f_pla_ini_trim(pfecha IN DATE)
      RETURN NUMBER IS
      valor          NUMBER;
   BEGIN
      valor := edat_inici_trim - fedad_aseg(pfecha);

      IF valor < 0 THEN
         RETURN 0;
      ELSE
         RETURN valor;
      END IF;

      RETURN valor;
   END f_pla_ini_trim;

   FUNCTION f_pla_fin_trim(pfecha IN DATE)
      RETURN NUMBER IS
      valor          NUMBER;
   BEGIN
      valor := edat_actual - fedad_aseg(pfecha);

      IF valor < 0 THEN
         RETURN 0;
      ELSE
         RETURN valor;
      END IF;

      RETURN valor;
   END f_pla_fin_trim;

   FUNCTION f_pla_fin_trim_futuro(pfecha IN DATE)
      RETURN NUMBER IS
      valor          NUMBER;
   BEGIN
      valor := fedad_aseg(pfecha) - edat_actual;

      IF valor < 0 THEN
         RETURN 0;
      ELSE
         RETURN valor;
      END IF;

      RETURN valor;
   END f_pla_fin_trim_futuro;

   FUNCTION f_pla_fin_trim_futuro2(pfecha1 IN DATE, pfecha IN DATE)
      RETURN NUMBER IS
      valor          NUMBER;
   BEGIN
      valor := fedad_aseg(pfecha1) - fedad_aseg(pfecha);

      IF valor < 0 THEN
         RETURN 0;
      ELSE
         RETURN valor;
      END IF;

      RETURN valor;
   END f_pla_fin_trim_futuro2;

   FUNCTION f_pla_31122008(pfecha IN DATE)
      RETURN NUMBER IS
      valor          NUMBER;
   BEGIN
      valor := edat_31122008 - fedad_aseg(pfecha);

      IF valor < 0 THEN
         RETURN 0;
      ELSE
         RETURN valor;
      END IF;

      RETURN valor;
   END f_pla_31122008;

   FUNCTION f_pla_vto(pfecha IN DATE)
      RETURN NUMBER IS
      valor          NUMBER;
   BEGIN
      valor := edat_jub - fedad_aseg(pfecha);

      IF valor < 0 THEN
         RETURN 0;
      ELSE
         RETURN valor;
      END IF;

      RETURN valor;
   END f_pla_vto;

   FUNCTION pm_inicio(importe IN NUMBER, pfecha IN DATE)
      RETURN NUMBER IS
      valor          NUMBER;
   BEGIN
      --if f_pla_ini(add_months(pfecha,-1)) > 0 then  --? no sera año
      IF f_pla_ini_trim(ADD_MONTHS(pfecha, -1)) > 0 THEN   --? no sera año
         valor := importe *(1 -(geee / 100)) *(POWER(1 + ptipoint, f_pla_ini(pfecha)))
                  *(POWER(1 -(giii / 100), f_pla_ini(pfecha)));
      ELSE
         valor := 0;
      END IF;

      RETURN valor;
   END pm_inicio;

   FUNCTION pm_iniciotrim(importe IN NUMBER, pfecha IN DATE)
      RETURN NUMBER IS
      valor          NUMBER;
   BEGIN
      IF f_pla_ini_trim(ADD_MONTHS(pfecha, -1)) > 0 THEN   --? no sera año
         valor := importe *(1 -(geee / 100)) *(POWER(1 + ptipoint, f_pla_ini_trim(pfecha)))
                  *(POWER(1 -(giii / 100), f_pla_ini_trim(pfecha)));
      ELSE
         valor := 0;
      END IF;

      RETURN valor;
   END pm_iniciotrim;

   FUNCTION pm_fintrim(importe IN NUMBER, pfecha IN DATE)
      RETURN NUMBER IS
      valor          NUMBER;
   BEGIN
      IF f_pla_fin_trim(ADD_MONTHS(pfecha, -1)) > 0 THEN
         valor := importe *(1 -(geee / 100)) *(POWER(1 + ptipoint, f_pla_fin_trim(pfecha)))
                  *(POWER(1 -(giii / 100), f_pla_fin_trim(pfecha)));
      ELSE
         valor := 0;
      END IF;

      RETURN valor;
   END pm_fintrim;

   FUNCTION pm_fintrim_futuro(importe IN NUMBER, pfecha IN DATE)
      RETURN NUMBER IS
      valor          NUMBER;
   BEGIN
      IF f_pla_fin_trim(ADD_MONTHS(pfecha, -1)) > 0 THEN
         valor := importe *(1 -(geee / 100))
                  *(POWER(1 + ptipoint, f_pla_fin_trim_futuro(pfecha)))
                  *(POWER(1 -(giii / 100), f_pla_fin_trim_futuro(pfecha)));
      ELSE
         valor := 0;
      END IF;

      RETURN valor;
   END pm_fintrim_futuro;

   --Capitalización entre dos fechas
   FUNCTION pm_fintrim_futuro2(importe IN NUMBER, pfecha1 IN DATE, pfecha IN DATE)
      RETURN NUMBER IS
      valor          NUMBER;
   BEGIN
      --if f_pla_fin_trim(add_months(pfecha,-1)) > 0 then
      valor := importe *(1 -(geee / 100))
               *(POWER(1 + ptipoint, f_pla_fin_trim_futuro2(pfecha1, pfecha)))
               *(POWER(1 -(giii / 100), f_pla_fin_trim_futuro2(pfecha1, pfecha)));
      -- else
       --   valor:=0;
      -- end if;
      RETURN valor;
   END pm_fintrim_futuro2;

   --Evoluciona desde la fecha del último saldo y sin los gastos externos
   FUNCTION pm_saldoant(importe IN NUMBER, pfecha IN DATE)
      RETURN NUMBER IS
      valor          NUMBER;
   BEGIN
      --if f_pla_fin_trim(add_months(pfecha,-1)) > 0 then
      valor := importe *(POWER(1 + ptipoint, f_pla_fin_trim_futuro(pfecha)))
               *(POWER(1 -(giii / 100), f_pla_fin_trim_futuro(pfecha)));
        -- else
         --   valor:=0;
      --   end if;
      RETURN valor;
   END pm_saldoant;

   FUNCTION capaseg(importe IN NUMBER, pfecha IN DATE)
      RETURN NUMBER IS
      valor          NUMBER;
   BEGIN
      IF f_pla_vto(ADD_MONTHS(pfecha, -1)) > 0 THEN
         valor := importe *(1 -(geee / 100)) *(POWER(1 + ptipoint, f_pla_vto(pfecha)))
                  *(POWER(1 -(giii / 100), f_pla_vto(pfecha)));
      ELSE
         valor := 0;
      END IF;

      RETURN valor;
   END capaseg;

   FUNCTION gastos(importe IN NUMBER, pfecha IN DATE)
      RETURN NUMBER IS
      valor          NUMBER;
   BEGIN
      valor := (importe) *(POWER(1 + ptipoint, f_pla_fin_trim(pfecha)))
               - pm_fintrim(importe, pfecha);

      IF valor < 0 THEN
         valor := 0;
      END IF;

      RETURN valor;
   END gastos;

   PROCEDURE iniciar_parametros(psesion IN NUMBER, psseguro IN NUMBER, pfecha IN DATE) IS
      psproduc       NUMBER;
      pcimpips       NUMBER;
      v_fecha_pm_anterior DATE;
   BEGIN
      giii := pac_gfi.f_sgt_parms('GIII', psesion);
      geee := pac_gfi.f_sgt_parms('GEEE', psesion);
      isi := pac_gfi.f_sgt_parms('ISI', psesion);
      ptipoint := pac_gfi.f_sgt_parms('PTIPOINT', psesion) / 100;
      sexo := pac_gfi.f_sgt_parms('SEXO', psesion);
      fecefe := pac_gfi.f_sgt_parms('FECEFE', psesion);
      fec_vto := pac_gfi.f_sgt_parms('FEC_VTO', psesion);
      fnacimi := pac_gfi.f_sgt_parms('FNACIMI', psesion);
      nmovimi := pac_gfi.f_sgt_parms('NMOVIMI', psesion);
      nriesgo := pac_gfi.f_sgt_parms('NRIESGO', psesion);
      factorcap := NVL(resp(gsesion, 1020), 1);   --JRH 10/2008
      -- fecha := pac_gfi.f_sgt_parms ('FECHA', psesion);
      gsesion := psesion;
      fpagprima := pac_gfi.f_sgt_parms('FPAGPRIMA', psesion);
      sproduc := pac_gfi.f_sgt_parms('SPRODUC', psesion);
      p_datos_ult_saldo(psseguro,   --JRH Ssseguro
                        pfecha, v_fecha_pm_anterior, pm_anterior, pcapgarant, pcapfallant,
                        v_numres);

      IF v_fecha_pm_anterior IS NOT NULL THEN
         fref := v_fecha_pm_anterior;
      ELSE
         fref := TO_DATE(fecefe, 'YYYYMMDD');   --F_SYSDATE;
      END IF;

      --Fechas iniciales
      fecultsald := fref;
      inici_any := i_anyo(fref);
      inici_trim := i_trim(fref);
      fi_trim := f_trim(fref);
      --Edades iniciales
      edat_inici_any := edad_ini_any(fref);
      edat_inici_trim := edad_ini_trim(fref);
      edat_actual := edad_act(fref);
      edat_31122008 := edad_31122008(fref);
      edat_jub := edad_jubil(fref);
   END iniciar_parametros;

   FUNCTION f_prueb(
      psesion IN NUMBER,
      psseguro IN NUMBER,
      pfecha IN DATE,
      pfonprov IN NUMBER DEFAULT 0   -- 0 = Capital Garantizado
                                     -- 1 = Provisión matemàtica
                                  )
      RETURN NUMBER IS
      a              NUMBER;
   BEGIN
      iniciar_parametros(psesion, psseguro, pfecha);
        /*
       --dbms_output.put_line('inici_any:'||inici_any);
       --dbms_output.put_line('inici_trim:'||inici_trim);
       --dbms_output.put_line('fi_trim:'||fi_trim);
       --dbms_output.put_line('Edat_inici_any:'||Edat_inici_any);
       --dbms_output.put_line('Edat_inici_trim:'||Edat_inici_trim);
       --dbms_output.put_line('Edat_actual:'||Edat_actual);
       --dbms_output.put_line('Edat_31122008:'||Edat_31122008);
       --dbms_output.put_line('Edat_jub:'||Edat_jub);


      --dbms_output.put_line('f_pla_ini:'||f_pla_ini(TO_DATE('30/04/2008','DD/MM/YYYY')));
      --dbms_output.put_line('f_pla_ini_trim:'||f_pla_ini_trim(TO_DATE('30/04/2008','DD/MM/YYYY')));
      --dbms_output.put_line('f_pla_fin_trim:'||f_pla_fin_trim(TO_DATE('30/04/2008','DD/MM/YYYY')));
      --dbms_output.put_line('f_pla_31122008:'||f_pla_31122008(TO_DATE('30/04/2008','DD/MM/YYYY')));
      --dbms_output.put_line('f_pla_vto:'||f_pla_vto(TO_DATE('30/04/2008','DD/MM/YYYY')));

      --dbms_output.put_line('PM_Inicio:'||PM_Inicio(59.14,TO_DATE('30/04/2008','DD/MM/YYYY')));
      --dbms_output.put_line('PM_InicioTrim:'||PM_InicioTrim(59.14,TO_DATE('30/04/2008','DD/MM/YYYY')));
      --dbms_output.put_line('PM_FinTrim:'||PM_FinTrim(59.14,TO_DATE('30/04/2008','DD/MM/YYYY')));
      --dbms_output.put_line('CapAseg:'||CapAseg(59.14*2,TO_DATE('30/04/2008','DD/MM/YYYY')));
      --dbms_output.put_line('Gastos:'||Gastos(59.14*2,TO_DATE('30/04/2008','DD/MM/YYYY')));*/
      RETURN a;
   END f_prueb;

   FUNCTION f_calfeda(
      psesion IN NUMBER,
      psseguro IN NUMBER,
      pfecha IN DATE,
      pfonprov IN NUMBER DEFAULT 0   -- 0 = Capital Garantizado
                                     -- 1 = Provisión matemàtica
                                  )
      RETURN NUMBER IS
      aportext       BOOLEAN := FALSE;
      seguroini      NUMBER;
      v_finiefe      DATE;
      v_tablas       VARCHAR2(3);
      hacerdif       BOOLEAN := TRUE;
      aportacion_inicial2 NUMBER := 0;
      consultainicial BOOLEAN := TRUE;
      capitalacum    NUMBER := 0;
      provacum       NUMBER := 0;
      importesup     NUMBER;
      fechasaldo     DATE;
      -- Bug 0009172 - JRH - 01/05/2009 - Nueva Función : Bug 0009172: CRE055 - Rentas regulares e irregulares con cálculos a partir de renta
      vvalorfactor   NUMBER := NULL;

      -- fi bug
      CURSOR c_polizas_provmat IS
         SELECT s.cramo, s.cmodali, s.ctipseg, s.ccolect, p.pinttec,
                NVL(s.fcaranu, s.fvencim) ffinal, s.fefecto, s.ncertif, s.nduraci nduraci,
                p.pgasint, p.pgasext, s.cactivi, s.cforpag, s.fvencim, p.pgaexin, p.pgaexex,
                p.cdivisa, s.sproduc, NVL(m.femisio, s.fefecto) femisio
           FROM productos p, seguros s, movseguro m
          WHERE s.sseguro = psseguro
            AND p.ctipseg = s.ctipseg
            AND p.cmodali = s.cmodali
            AND p.cramo = s.cramo
            AND p.ccolect = s.ccolect
            AND s.csituac <> 4
            AND m.sseguro = s.sseguro
            AND m.nmovimi = 1
         UNION
         SELECT s.cramo, s.cmodali, s.ctipseg, s.ccolect, p.pinttec,
                NVL(s.fcaranu, s.fvencim) ffinal, s.fefecto, s.ncertif, s.nduraci nduraci,
                p.pgasint, p.pgasext, s.cactivi, s.cforpag, s.fvencim, p.pgaexin, p.pgaexex,
                p.cdivisa, s.sproduc, NVL(s.femisio, s.fefecto) femisio
           FROM productos p, estseguros s
          WHERE s.sseguro = psseguro
            AND p.ctipseg = s.ctipseg
            AND p.cmodali = s.cmodali
            AND p.cramo = s.cramo
            AND p.ccolect = s.ccolect;

      CURSOR c_movimientos(psseguro NUMBER, f_ini DATE, f_final DATE, pnnumlin NUMBER) IS
         SELECT   DECODE(cmovimi,   -- DETVALORES = 83
                         1, imovimi,   -- Aportacio Extraordinaria
                         2, imovimi,   -- Aportació periódica
                         4, imovimi,   -- Aportació Única
                         9, imovimi,   -- Aportació Participacio Beneficis
                         84, imovimi,   -- Aportació Participacio Beneficis  Empleat
                         85, imovimi,   -- Aportació Participacio Beneficis  Empresa
                         -imovimi   -- (Rescats 27, 33 i 34)
                                 ) imovimi,
                  ffecmov, fvalmov, nnumlin, cmovimi
             FROM ctaseguro
            WHERE sseguro = psseguro
              AND cmovimi IN(1, 2, 4, 9, 84, 85, 27, 33, 34, 39, 51, 53)
              AND((TRUNC(ffecmov) BETWEEN f_ini AND f_final
                   -- Se coge la fecha mayor entre la entrada y la calculada
                   --  para no tener problemas con los traspasos de fechas anteriores
                   AND TRUNC(fcontab) <= GREATEST(f_final, pfecha))
                  -- Se modifica para que coja los movimientos correctos
                  OR(TRUNC(fcontab) BETWEEN f_ini + 1 AND f_final
                     AND ffecmov <= f_ini
                                         --    AND nnumlin > nvl (pnnumlin, 0)
                    )
                  -- Se controlan los recibos anulados el mismo dia que se hace la reducción
                  OR(TRUNC(fcontab) = f_ini
                     AND ffecmov <= f_ini
                     AND nnumlin > NVL(pnnumlin, 0)))
              AND nnumlin > NVL(pnnumlin, 0)
              -- NO TENEMOS EN CUENTA LA APORTACIÓN DEL MES
              AND cmovanu <> 1   -- EL MOVIMENT NO HA ESTAT ANULAT
         --AND NNUMLIN!=1;    --Em salto el primer rebut
         ORDER BY nnumlin;

      CURSOR c_est IS
         SELECT e.cramo, e.cmodali, e.ctipseg, e.ccolect, e.cactivi, e.sseguro
           FROM estseguros e
          WHERE e.sseguro = psseguro;
   BEGIN
      BEGIN
         SELECT ssegpol   -- Queremos el sseguro original
           INTO seguroini
           FROM estseguros
          WHERE sseguro = psseguro;

         v_tablas := 'EST';
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            seguroini := psseguro;
            v_tablas := NULL;
      END;

      iniciar_parametros(psesion, seguroini, pfecha);

      FOR reg IN c_polizas_provmat LOOP
         FOR r_mov IN c_movimientos(seguroini, fref, TO_DATE('01/01/2940', 'DD/MM/YYYY'),
                                    v_numres) LOOP
            --IF r_mov.cmovimi in ( 1,84,85,9 THEN
            capitalacum := capitalacum
                           + capaseg(r_mov.imovimi,
                                     GREATEST(r_mov.ffecmov, TO_DATE(fecefe, 'YYYYMMDD')));
            --if r_mov.ffecmov<=pfecha then --Solo contribuye hasta la fecha
            provacum := provacum
                        + pm_fintrim_futuro2(r_mov.imovimi, pfecha,
                                             GREATEST(r_mov.ffecmov,
                                                      TO_DATE(fecefe, 'YYYYMMDD')));
         --end if;

         --END IF;
         END LOOP;

         -- Si estamos en una NP, cartera o Suplemento hemos de añadir las aportaciones en cuestión.
         -- Si estamos simulando por aquí no entrará
         FOR e IN c_est LOOP
            IF nmovimi = 1 THEN   -- NP
               hacerdif := FALSE;
               capitalacum := capitalacum + 0;
               provacum := provacum + 0;
            ELSIF nmovimi > 1 THEN   -- Suplemento (Aport. Extr.)
               SELECT SUM
                         (g.icapital)   --Miramos el importe del suplemento de aport extraordinaria
                 INTO importesup
                 FROM estgaranseg g
                WHERE g.sseguro = e.sseguro
                  AND g.nriesgo = nriesgo
                  AND g.nmovimi = nmovimi
                  AND f_pargaranpro_v(e.cramo, e.cmodali, e.ctipseg, e.ccolect, e.cactivi,
                                      g.cgarant, 'TIPO') IN(4, 12);   -- APORT EXTRA, o PB

               aportext := TRUE;
               capitalacum := capitalacum + capaseg(NVL(importesup, 0), pfecha);
               provacum := provacum + 0;   --PM_FinTrim_futuro(nvl(ImporteSup,0), pfecha);
            END IF;
         END LOOP;
      END LOOP;

      IF MONTHS_BETWEEN(pfecha, fecultsald) >= 1 THEN
         fechasaldo := pfecha;
         pm_anterior := pm_saldoant(NVL(pm_anterior, 0), pfecha);
      ELSE
         pm_anterior := NVL(pm_anterior, 0);   --Mantenemos el valor de la provisión dentro del mismo mes
      END IF;

      IF pfonprov = 0 THEN
         RETURN capitalacum + NVL(pcapgarant, 0);
      ELSE
         RETURN provacum + NVL(pm_anterior, 0);
      END IF;
   END f_calfeda;

   FUNCTION f_calpb(psseguro IN NUMBER, pfecha IN DATE)
      RETURN NUMBER IS
      factor         NUMBER;
      importe        NUMBER;
      importeacum    NUMBER;
      v_fecha_pm_anterior DATE;
      pm_anterior    NUMBER;
      pcapgarant     NUMBER;
      pcapfallant    NUMBER;
      v_numres       NUMBER;
      dias           NUMBER;
      importepb      NUMBER;
      pctpb          NUMBER;
      psproduc       NUMBER;
      pctasign       NUMBER := 90;
      intminimo      NUMBER := 0;
      rendbrutcart   NUMBER := 4.5;
      despfinan      NUMBER := 0.3;
      margbenef      NUMBER := 0.5;
      ndurper        NUMBER;
      vfefecto       DATE;

      CURSOR c_movimientos(psseguro NUMBER, f_ini DATE, f_final DATE, pnnumlin NUMBER) IS
         SELECT   DECODE(cmovimi,   -- DETVALORES = 83
                         1, imovimi,   -- Aportacio Extraordinaria
                         2, imovimi,   -- Aportació periódica
                         4, imovimi,   -- Aportació Única
                         9, imovimi,   -- Aportació Participacio Beneficis
                         84, imovimi,   -- Aportació Participacio Beneficis  Empleat
                         85, imovimi,   -- Aportació Participacio Beneficis  Empresa
                         -imovimi   -- (Rescats 27, 33 i 34)
                                 ) imovimi,
                  ffecmov, fvalmov, nnumlin, cmovimi
             FROM ctaseguro
            WHERE sseguro = psseguro
              AND cmovimi IN(1, 2, 4, 9, 84, 85, 27, 33, 34, 39)
              AND((TRUNC(ffecmov) BETWEEN f_ini AND f_final
                   -- Se coge la fecha mayor entre la entrada y la calculada
                   --  para no tener problemas con los traspasos de fechas anteriores
                   AND TRUNC(fcontab) <= GREATEST(f_final, pfecha))
                  -- Se modifica para que coja los movimientos correctos
                  OR(TRUNC(fcontab) BETWEEN f_ini + 1 AND f_final
                     AND ffecmov <= f_ini
                                         --    AND nnumlin > nvl (pnnumlin, 0)
                    )
                  -- Se controlan los recibos anulados el mismo dia que se hace la reducción
                  OR(TRUNC(fcontab) = f_ini
                     AND ffecmov <= f_ini
                     AND nnumlin > NVL(pnnumlin, 0)))
              AND nnumlin > NVL(pnnumlin, 0)
              -- NO TENEMOS EN CUENTA LA APORTACIÓN DEL MES
              AND cmovanu <> 1   -- EL MOVIMENT NO HA ESTAT ANULAT
         --AND NNUMLIN!=1;    --Em salto el primer rebut
         ORDER BY nnumlin;
   BEGIN
      SELECT s.sproduc, NVL(ndurper, nduraci), fefecto
        INTO psproduc, ndurper, vfefecto
        FROM seguros_aho so, seguros s
       WHERE so.sseguro = psseguro
         AND so.sseguro = s.sseguro;

      p_datos_ult_saldo(psseguro,   --JRH Ssseguro
                        ADD_MONTHS(pfecha, -12) + 1, v_fecha_pm_anterior, pm_anterior,
                        pcapgarant, pcapfallant, v_numres);
      importeacum := 0;
      dias := pfecha - ADD_MONTHS(pfecha, -12);

      FOR r_mov IN c_movimientos(psseguro, ADD_MONTHS(pfecha, -12) + 1, pfecha, v_numres) LOOP
         factor := (pfecha -(r_mov.ffecmov - 1)) / dias;
         importe := r_mov.imovimi * factor;
         importeacum := importeacum + NVL(importe, 0);
      END LOOP;

      importeacum := NVL(importeacum, 0) + NVL(pm_anterior, 0);
      intminimo := pac_inttec.ff_int_producto(psproduc, 1, vfefecto, ndurper);   --JRH IMP A lo mejor es F_SYSDATE en lugar de vfefecto!!!
      pctasign := vtramo(-1, 1352, psproduc);
      margbenef := vtramo(-1, 1351, psproduc);
      rendbrutcart := vtramo(-1, 1350, psproduc);
      despfinan := vtramo(-1, 1310, psproduc);
      pctpb := pctasign *(rendbrutcart - despfinan - margbenef - intminimo);
      importepb := importeacum * pctpb / 10000;
      RETURN importepb;
   END f_calpb;

   FUNCTION f_procpb(
      psproces IN NUMBER,
      psmodo IN NUMBER,
      psproduc IN NUMBER,
      pfecha IN DATE,
      pcidioma IN NUMBER,
      psseguro IN NUMBER)
      RETURN NUMBER IS
      CURSOR polizas IS
         SELECT   sseguro, cbancar, ctipban, sproduc
             FROM seguros s
            WHERE s.sproduc = psproduc
              AND s.fefecto < pfecha
              AND((s.sseguro = psseguro
                   AND psseguro IS NOT NULL)
                  OR(psseguro IS NULL))
              AND s.csituac = 0
              AND NOT EXISTS(SELECT 1
                               FROM ctaseguro c
                              WHERE c.sseguro = s.sseguro
                                AND c.cmovimi IN(9, 39)
                                AND c.cmovanu <> 1
                                AND c.fvalmov <> pfecha)
         ORDER BY s.sseguro;

      errparms       EXCEPTION;
      i              NUMBER;
   BEGIN
      IF psproces IS NULL
         OR psmodo IS NULL
         OR psproduc IS NULL
         OR pfecha IS NULL THEN
         RAISE errparms;
      END IF;

      i := 0;

      --Contexto?
      FOR reg IN polizas LOOP
         DECLARE
            v_cgarant      NUMBER;
            imppb          NUMBER;
            numerr         NUMBER;
            vnmovimi       NUMBER;
            mensajes       t_iax_mensajes;
            errorsup       EXCEPTION;
            texto          VARCHAR2(500);
            num_lin        NUMBER;
            num_err        NUMBER;
            v_cmovimi      ctaseguro.cmovimi%TYPE;
         BEGIN
            imppb := f_calpb(reg.sseguro, pfecha);   --Buscamos el importe de PB y generamos el suplemento

            IF imppb IS NULL THEN
               RAISE errorsup;
            END IF;

            --Buscamos la cobertura de tipo PB
            SELECT MIN(g.cgarant)
              INTO v_cgarant
              FROM garanpro g, seguros s
             WHERE g.sproduc = s.sproduc
               AND g.cramo = s.cramo
               AND g.cmodali = s.cmodali
               AND g.ctipseg = s.ctipseg
               AND g.ccolect = s.ccolect
               AND g.cactivi = s.cactivi
               AND f_pargaranpro_v(g.cramo, g.cmodali, g.ctipseg, g.ccolect, g.cactivi,
                                   g.cgarant, 'TIPO') = 12
               AND s.sseguro = reg.sseguro;

            IF psmodo = 'R' THEN   --Para el modo real generamos el suplemento con el importe de la PB calculado anteriormente.
               --De momento el riesgo vale 1
               numerr := pac_md_sup_finan.f_aportacion_extraordinaria(reg.sseguro, 1, pfecha,
                                                                      imppb, reg.ctipban,
                                                                      reg.cbancar, v_cgarant,
                                                                      vnmovimi, mensajes);

               IF numerr <> 0 THEN
                  RAISE errorsup;
               END IF;
            ELSE
               IF NVL(imppb, 0) < 0
                  AND NVL(f_parproductos_v(reg.sproduc, 'BONUS_NEG'), 0) = 1 THEN
                  v_cmovimi := 39;
               ELSE
                  v_cmovimi := 9;
               END IF;

               --Para el previo insertamos en CTASEGURO_PREVIO con el importe de la PB calculado anteriormente.
               numerr := pac_ctaseguro.f_insctaseguro(reg.sseguro, f_sysdate, NULL,   --nvl(xnnumlin,0)+1,
                                                      f_sysdate, f_sysdate, v_cmovimi,   --pcmovimi, Part. Beneficios
                                                      imppb, imppb, NULL, 0, 0, NULL, NULL,
                                                      NULL, 'P', psproces, NULL, NULL, NULL);

               IF numerr <> 0 THEN
                  RAISE errorsup;
               END IF;

               IF pac_ctaseguro.f_tiene_ctashadow(reg.sseguro, NULL) = 1 THEN
                  numerr :=
                     pac_ctaseguro.f_insctaseguro_shw(reg.sseguro, f_sysdate, NULL,   --nvl(xnnumlin,0)+1,
                                                      f_sysdate, f_sysdate, v_cmovimi,   --pcmovimi, Part. Beneficios
                                                      imppb, imppb, NULL, 0, 0, NULL, NULL,
                                                      NULL, 'P', psproces, NULL, NULL, NULL);

                  IF numerr <> 0 THEN
                     RAISE errorsup;
                  END IF;
               END IF;
            END IF;
         EXCEPTION   --Las que fallan no las tratamos y las dejamos para más adelante
            WHEN errorsup THEN
               p_tab_error(f_sysdate, f_user, 'Pac_Propio_Formul.f_ProcPB', NULL,
                           'Error:' || reg.sseguro || ' importe: ' || imppb || ' numerr:'
                           || numerr,
                           'Error en suplemento');
               ROLLBACK;
               p_literal2(numerr, pcidioma, texto);
                --DBMS_OUTPUT.put_line(
               --    ' rollback '|| num_err || texto || psproces);
               texto := texto || '.' || reg.sseguro;
               num_lin := NULL;
               num_err := f_proceslin(psproces, texto, reg.sseguro, num_lin);
               i := i + 1;
               COMMIT;
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'Pac_Propio_Formul.f_ProcPB', NULL,
                           'Error no controlado:' || reg.sseguro || ' importe: ' || imppb,
                           SQLERRM);
               ROLLBACK;
               num_lin := NULL;
               num_err := f_proceslin(psproces, SQLERRM, reg.sseguro, num_lin);
               i := i + 1;
               COMMIT;
         END;
      END LOOP;

      RETURN i;   --Devuelve las pólizas que han ido mal
   EXCEPTION
      WHEN errparms THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Propio_Formul.f_ProcPB', 99,
                     'Faltan parámetros=' || SQLCODE, SQLERRM);
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Propio_Formul.f_ProcPB', 99,
                     'Error When others,sqlcode=' || SQLCODE, SQLERRM);
         RETURN NULL;
   END f_procpb;

    /*************************************************************************
      -- BUG 7959 - 03/2009 - JRH  - Decesos
       Calcula varios conceptos según el parametro de entrada pmodo  (por cobertura en sesión).
      Param IN psesion: Sesión
      Param IN psseguro: Seguro
      Param IN pfecha : Fecha
      Param IN pModo : Modo
      Return:Devuelve según modo:
      0-> Factor de Tasa para los capitales de Sepelio o Fallecimiento.
      1-> Provisión de la cobertura que se calcula.
      2-> Capital de Fallecimiento del producto de Decesos.
       null si hay error
   *************************************************************************/
   FUNCTION f_pdecesosf(psesion IN NUMBER, psseguro IN NUMBER, pfecha IN DATE, pmodo IN NUMBER)
      RETURN NUMBER IS
      vfechainicial  NUMBER;
      vfechafinal    NUMBER;
      vprovini       NUMBER;
      vprovfin       NUMBER;
      vfracany       NUMBER;
      vfracmes       NUMBER;
      vprimagar      NUMBER;
      vfecefe        NUMBER;
      vproduc        productos.sproduc%TYPE;
      vact           NUMBER;
      vtablamortestalvi garanpro.ctabla%TYPE;
      vtablamortrisc garanpro.ctabla%TYPE;
      vsexo          NUMBER;
      vfedadaseg     NUMBER;
      vfnacimi       NUMBER;
      vfecha         NUMBER;
      vfedadasegefec NUMBER;
      vcrevali       seguros.crevali%TYPE;
      virevali       seguros.irevali%TYPE;
      vprevali       seguros.prevali%TYPE;
      vcgarant       garanpro.cgarant%TYPE;
      vtipoint       NUMBER;
      vfpagprima     seguros.cforpag%TYPE;
      vedadfin       NUMBER;
      vnriesgo       NUMBER;
      vcapital       garanseg.icapital%TYPE;
      vprimaanu      garanseg.iprianu%TYPE;
      vduraci        NUMBER;
      vvax           NUMBER;
      vaxn           NUMBER;
      vprovtotal     NUMBER;
      vgeee          productos.pgasext%TYPE;
      vgiii          productos.pgasint%TYPE;
      vpaso          NUMBER := 0;
      vcapitalsep    garanseg.icapital%TYPE;
      valores        VARCHAR2(10000);
      vresp608       NUMBER;
      vresp609       NUMBER;
      vresp610       NUMBER;
      vresp611       NUMBER;
      vresp1         NUMBER;
      vssegurodef    seguros.sseguro%TYPE;

      CURSOR importes(vseg NUMBER, priesgo NUMBER, vgar NUMBER) IS
         SELECT icapital,
                iprianu   --Bug 0009541: CRE - Incidència Cartera de Decesos Quitamos itarifa
           FROM garanseg g1
          WHERE g1.sseguro = vseg
            AND g1.nriesgo = priesgo
            AND g1.cgarant = vgar
            AND g1.nmovimi = (SELECT MIN(nmovimi)
                                FROM garanseg g2
                               WHERE g2.sseguro = g1.sseguro
                                 AND g2.nriesgo = g1.nriesgo
                                 AND g2.cgarant = g1.cgarant);

      CURSOR importesant(vseg NUMBER, priesgo NUMBER, vgar NUMBER) IS
         SELECT icapital, iprianu,   --Bug 0009541: CRE - Incidència Cartera de Decesos Quitamos itarifa
                                  precarg   -- BUG 0022498 - FAL - 22/06/2012
           FROM garanseg g1
          WHERE g1.sseguro = vseg
            AND g1.nriesgo = priesgo
            AND g1.cgarant = vgar
            AND g1.nmovimi = (SELECT MAX(nmovimi)
                                FROM garanseg g2
                               WHERE g2.sseguro = g1.sseguro
                                 AND g2.nriesgo = g1.nriesgo
                                 AND g2.cgarant = g1.cgarant);

      CURSOR busccapital(vsseguro NUMBER, priesgo NUMBER) IS
         SELECT icapital
           FROM garanseg g1
          WHERE g1.sseguro = vsseguro
            AND g1.nriesgo = priesgo
            AND g1.cgarant = 103
            AND g1.nmovimi = (SELECT MIN(nmovimi)
                                FROM garanseg g2
                               WHERE g2.sseguro = g1.sseguro
                                 AND g2.nriesgo = g1.nriesgo
                                 AND g2.cgarant = g1.cgarant)
         UNION
         SELECT icapital
           FROM estgaranseg g1
          WHERE g1.sseguro = psseguro
            AND g1.nriesgo = priesgo
            AND g1.cgarant = 103;

      -- BUG 10784 - 02/2009 - JRH  -  Modificaciones en producto Decesos
      vrevalcap      NUMBER;
      vaccion        NUMBER;
      --vfeccart NUMBER;
      vcapitalcart   NUMBER;
      vprimaanucart  NUMBER;
      vcapitalgar    NUMBER;
      vprop          NUMBER;
      -- fi BUG 10784 - 02/2009 - JRH
      vprecarg       garanseg.precarg%TYPE;   -- BUG 0022498 - FAL - 22/06/2012
   BEGIN
      --   dbms_output.put_line('AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA');
       --  dbms_output.put_line(pac_gfi.f_sgt_parms('ACCION', psesion)||':'||pac_gfi.f_sgt_parms('CACCION', psesion));
             --iniciar_parametros(psesion);
      vpaso := 1;
      vfecefe := pac_gfi.f_sgt_parms('FEFEPOL', psesion);
      vproduc := pac_gfi.f_sgt_parms('SPRODUC', psesion);
      vact := NVL(pac_gfi.f_sgt_parms('CACTIVI', psesion), 0);
      vsexo := pac_gfi.f_sgt_parms('SEXO', psesion);
      vaccion := pac_gfi.f_sgt_parms('ACCION', psesion);
      vfnacimi := pac_gfi.f_sgt_parms('FNACIMI', psesion);
      --vfeccart := pac_gfi.f_sgt_parms('FECEFE', psesion);
      vcrevali := NVL(pac_gfi.f_sgt_parms('CREVALI', psesion), 0);
      virevali := NVL(pac_gfi.f_sgt_parms('IREVALI', psesion), 0);
      vprevali := NVL(pac_gfi.f_sgt_parms('PREVALI', psesion), 0);
      vcgarant := NVL(pac_gfi.f_sgt_parms('GARANTIA', psesion), 0);
      vtipoint := NVL(pac_gfi.f_sgt_parms('PTIPOINT', psesion), 0);
      vfpagprima := NVL(pac_gfi.f_sgt_parms('FPAGPRIMA', psesion), 0);
      vnriesgo := pac_gfi.f_sgt_parms('NRIESGO', psesion);
      vgeee := pac_gfi.f_sgt_parms('GEEE', psesion);
      vgiii := pac_gfi.f_sgt_parms('GIII', psesion);
      vcapitalgar := pac_gfi.f_sgt_parms('CAPITAL', psesion);
      vresp608 := NVL(resp(psesion, 608), 0);
      -- BUG 10784 - 02/2009 - JRH  -  Modificaciones en producto Decesos
      vrevalcap := vtramo(-1, 1650, vproduc);

--dbms_output.put_line('vaccion:'||vaccion||' pmodo:'||pmodo);
      -- fi BUG 10784 - 02/2009 - JRH

      -- BUG 9540 - 05/2009 - JRH  -  Parametritzar sinistres de Decesos
      IF NVL(resp(psesion, 609), 0) <> 0 THEN
         vresp609 := NVL(resp(psesion, 609), 0);
      ELSE
         vresp609 := 1.444444;   -- NVL(resp(psesion, 609), 0);
      END IF;

      --Fi BUG
      vresp610 := NVL(resp(psesion, 610), 0);
      vresp611 := NVL(resp(psesion, 611), 0);
      vresp1 := NVL(resp(psesion, 1), 0);

      IF pmodo = 2 THEN   -- Busqueda de capital
         BEGIN
            SELECT ssegpol
              INTO vssegurodef
              FROM estseguros
             WHERE sseguro = psseguro;

            vssegurodef := NVL(vssegurodef, psseguro);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               vssegurodef := psseguro;
         END;

         OPEN busccapital(vssegurodef, vnriesgo);

         FETCH busccapital
          INTO vcapitalsep;

         CLOSE busccapital;

         IF vresp1 > vresp610 THEN
            --return vresp608*nvl(vCapitalSep,0)*vresp609/100;
            RETURN vresp608;
         ELSIF vresp1 < 18 THEN   -- BUG 0022498 - FAL- Se cambia el <= por <
            --return vresp608*nvl(vCapitalSep,0)*vresp609/100;
            RETURN vresp608;
         ELSE
            --return nvl(vCapitalSep,0)*vresp609;
            RETURN vresp611 * vresp609;
         END IF;
      END IF;

      vpaso := 2;

      BEGIN
         -- Bug 11896 - APD - 09/12/2009 - se sustituye el TIPO = 6 por 13
         SELECT MAX(NVL(g.ctabla, 0))
           INTO vtablamortrisc
           FROM garanpro g, productos s
          WHERE s.sproduc = vproduc
            AND g.sproduc = s.sproduc
            AND f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, vact, g.cgarant,
                                'TIPO') = 13;   --Muerte (tabla associada al riesgo)
      EXCEPTION
         WHEN OTHERS THEN
            NULL;   --Pondremos valores por defecto
      END;

      vpaso := 3;

      BEGIN
         -- Bug 11896 - APD - 09/12/2009 - se sustituye el TIPO = 6 por 13
         SELECT MAX(NVL(g.ctabla, 0))
           INTO vtablamortestalvi
           FROM garanpro g, productos s
          WHERE s.sproduc = vproduc
            AND g.sproduc = s.sproduc
            AND NVL(f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, vact, g.cgarant,
                                    'TIPO'),
                    0) <> 13;   --Muerte (tabla associada al riesgo)
      EXCEPTION
         WHEN OTHERS THEN
            NULL;   --Pondremos valores por defecto
      END;

      vpaso := 4;

      OPEN importes(psseguro, vnriesgo, vcgarant);

      FETCH importes
       INTO vcapital, vprimaanu;

      CLOSE importes;

      vprimaanu := vprimaanu *(1 -(vgiii / 100) -(vgeee / 100));   --Bug 0009541: CRE - Incidència Cartera de Decesos
      valores := valores || ' psesion:' || psesion || ' psseguro:' || psseguro || ' pfecha:'
                 || pfecha || ' pModo:' || pmodo || CHR(10);
      valores := valores || ' vfecefe:' || vfecefe || ' vproduc:' || vproduc || ' vact:'
                 || vact || ' vsexo:' || vsexo || ' vfnacimi:' || vfnacimi || ' vcrevali:'
                 || vcrevali || CHR(10);
      valores := valores || ' virevali:' || virevali || ' vprevali:' || vprevali
                 || ' vcgarant:' || vcgarant || ' vtipoint:' || vtipoint || ' vFpagPrima:'
                 || vfpagprima || ' vNRiesgo:' || vnriesgo || CHR(10);
      valores := valores || ' vgeee:' || vgeee || ' vgiii:' || vgiii || ' vtablamortrisc:'
                 || vtablamortrisc || ' vtablamortestalvi:' || vtablamortestalvi
                 || ' vCapital:' || vcapital || ' vPrimaAnu:' || vprimaanu || CHR(10);

      IF pmodo = 0
         AND vaccion = 3 THEN   --JRH Devolvemos la prima revalorizada
         OPEN importesant(psseguro, vnriesgo, vcgarant);

         FETCH importesant
          INTO vcapitalcart, vprimaanucart, vprecarg;   -- BUG 0022498 - FAL - 22/06/2012

         CLOSE importesant;

            -- dbms_output.put_line('________________________vcgarant:'||vcgarant);
          --   dbms_output.put_line('________________________vprimaanucart:'||vprimaanucart);
         --     dbms_output.put_line('________________________vprevali:'||vprevali);
         -- BUG 0022498 - FAL - 22/06/2012 - Se aplica el recargo a la prima anual de cartera
         vprimaanucart := (vprimaanucart /(1 +(vprecarg / 100)))
                          *(1 -(vgiii / 100) -(vgeee / 100));   --Bug 0009541: CRE - Incidència Cartera de Decesos
         --    dbms_output.put_line('________________________vprimaanucart:'||vprimaanucart);

         -- dbms_output.put_line('________________________tt:'||round(vprimaanucart * POWER((1 + (vprevali / 100)), 1) + (1) *(virevali / 100),2));
         --  dbms_output.put_line('B:'||round(vprimaanucart * POWER((1 + (vprevali / 100)), 1) + (1) *(virevali / 100),2));
         RETURN ROUND(vprimaanucart * POWER((1 +(vprevali / 100)), 1) + (1) *(virevali / 100),
                      2);
      -- dbms_output.put_line('A');
      END IF;

      vduraci := FLOOR(MONTHS_BETWEEN(pfecha, TO_DATE(vfecefe, 'YYYYMMDD')) / 12);
      vprimaanu := ROUND(vprimaanu / vfpagprima, 2);

      --Suponemos vfecefe empieza en 1 del mes, pero por si acaso

      --Buscamos fechas. Lo hacemos de momento tomando las fechas como numbers tal como las considera el tarificador
      IF TO_CHAR(pfecha, 'MMDD') >= TO_CHAR(TO_DATE(vfecefe, 'YYYYMMDD'), 'MMDD') THEN
         vfechainicial := TO_CHAR(pfecha, 'YYYY')
                          || TO_CHAR(TO_DATE(vfecefe, 'YYYYMMDD'), 'MMDD');
         vfechafinal := TO_CHAR(TO_NUMBER(TO_CHAR(pfecha, 'YYYY')) + 1)
                        || TO_CHAR(TO_DATE(vfecefe, 'YYYYMMDD'), 'MMDD');
      ELSE
         vfechafinal := TO_CHAR(pfecha, 'YYYY')
                        || TO_CHAR(TO_DATE(vfecefe, 'YYYYMMDD'), 'MMDD');
         vfechainicial := TO_CHAR(TO_NUMBER(TO_CHAR(pfecha, 'YYYY')) - 1)
                          || TO_CHAR(TO_DATE(vfecefe, 'YYYYMMDD'), 'MMDD');
      END IF;

      vpaso := 5;
      vprimagar := vprimaanu * POWER((1 + vprevali / 100), vduraci)
                   + (vduraci) *(virevali / 100);
      vpaso := 6;

      IF pmodo = 0 THEN   --Buscamos sólo la tasa inicial
         vfecha := TO_CHAR(pfecha, 'YYYYMMDD');
      ELSE
         vfecha := vfechainicial;   --Estamos en el cálculo de la provisión
      END IF;

      valores := valores || ' vFechaInicial:' || vfechainicial || ' vFechaFinal:'
                 || vfechafinal || ' vPrimaGar:' || vprimagar || ' vduraci:' || vduraci
                 || ' vCapital:' || vcapital || ' vfecha:' || vfecha || CHR(10);
      vpaso := 7;
      vfedadaseg := ROUND(MONTHS_BETWEEN(TO_DATE(vfecha, 'YYYYMMDD'),
                                         TO_DATE(vfnacimi, 'YYYYMMDD'))
                          / 12);
      vfedadasegefec := ROUND(MONTHS_BETWEEN(TO_DATE(vfecefe, 'YYYYMMDD'),
                                             TO_DATE(vfnacimi, 'YYYYMMDD'))
                              / 12);
      vedadfin := 127 - vfedadaseg;
      vvax := pac_frm_actuarial.ff_aprog2(psesion, vtablamortestalvi, vsexo, vfedadaseg,
                                          vedadfin,(1 /(1 + vtipoint / 100)), vrevalcap,
                                          virevali, 1, vfedadasegefec, 0, TRUE);
      -- BUG 10784 - 02/2009 - JRH  -  Modificaciones en producto Decesos
      vaxn := pac_frm_actuarial.ff_axprog2(psesion, vtablamortrisc, vsexo, vfedadaseg,
                                           vedadfin,(1 /(1 + vtipoint / 100)), vprevali,
                                           virevali, 1, vfedadasegefec, 0, FALSE);
      -- fi BUG 10784 - 02/2009 - JRH
      vpaso := 8;
      valores := valores || ' vfedadaseg:' || vfedadaseg || ' vfedadasegefec:'
                 || vfedadasegefec || ' vEdadFin:' || vedadfin || ' vVAx:' || vvax || ' vAxn:'
                 || vaxn || ' vfecha:' || vfecha || CHR(10);

      IF pmodo = 0 THEN
         -- DBMS_OUTPUT.put_line('vvax:' || vvax);

         --dbms_output.put_line('Valores:'||Valores);
         IF vcgarant = 1 THEN
            --dbms_output.put_line('Prima 1:'||TO_CHAR(ROUND(1.444444 * vresp611 * vvax / vaxn, 2)));
            RETURN ROUND(1.444444 * vresp611 * vvax / vaxn, 2);
         ELSE
            -- dbms_output.put_line('Prima 1:'||TO_CHAR(ROUND(vcapitalgar * vvax / vaxn, 2)));
            RETURN ROUND(vcapitalgar * vvax / vaxn, 2);
         END IF;
      END IF;

-- BUG 11715 - 11/2009 - JRH  - Modificacióón para tener en cuenta el prorrateo
      --JRH Si continuamos con la provisión-->Modificacióón para tener en cuenta el prorrateo
      DECLARE
         vpartea        NUMBER;
         vparteb        NUMBER;
         vvax2          NUMBER;
         vaxn2          NUMBER;
      BEGIN
         vvax2 := pac_frm_actuarial.ff_aprog2(psesion, vtablamortestalvi, vsexo,
                                              vfedadasegefec,(127 - vfedadasegefec),
                                              (1 /(1 + vtipoint / 100)), vrevalcap, virevali,
                                              1, vfedadasegefec, 0, TRUE);
         -- BUG 10784 - 02/2009 - JRH  -  Modificaciones en producto Decesos
         vaxn2 := pac_frm_actuarial.ff_axprog2(psesion, vtablamortrisc, vsexo, vfedadasegefec,
                                               (127 - vfedadasegefec),
                                               (1 /(1 + vtipoint / 100)), vprevali, virevali,
                                               1, vfedadasegefec, 0, FALSE);
         vpartea := vcapital * vvax2;
         vparteb := vprimaanu * vaxn2 * vfpagprima;
         vprop := vpartea / vparteb - 1;
      EXCEPTION
         WHEN OTHERS THEN
            vprop := 0;
      END;

--fi BUG 11715 - 11/2009 - JRH
      vprovini := vcapital * vvax - vprimaanu * vaxn * vfpagprima *(1 + vprop);
      vpaso := 9;
      vfecha := vfechafinal;
      --vfedadaseg:=FLOOR(((TO_DATE(vfecha, 'YYYYMMDD') - TO_DATE(vfnacimi, 'YYYYMMDD')) / 365.25));
      vfedadaseg := ROUND(MONTHS_BETWEEN(TO_DATE(vfecha, 'YYYYMMDD'),
                                         TO_DATE(vfnacimi, 'YYYYMMDD'))
                          / 12);
      vfedadasegefec := ROUND(MONTHS_BETWEEN(TO_DATE(vfecefe, 'YYYYMMDD'),
                                             TO_DATE(vfnacimi, 'YYYYMMDD'))
                              / 12);
      vedadfin := 127 - vfedadaseg;
      vvax := pac_frm_actuarial.ff_aprog2(psesion, vtablamortestalvi, vsexo, vfedadaseg,
                                          vedadfin,(1 /(1 + vtipoint / 100)), vrevalcap,
                                          virevali, 1, vfedadasegefec, 0, TRUE);
      vaxn := pac_frm_actuarial.ff_axprog2(psesion, vtablamortrisc, vsexo, vfedadaseg,
                                           vedadfin,(1 /(1 + vtipoint / 100)), vprevali,
                                           virevali, 1, vfedadasegefec, 0, FALSE);
      vprovfin := vcapital * vvax - vprimaanu * vaxn * vfpagprima *(1 + vprop);
      vpaso := 10;
      valores := valores || ' vfedadaseg:' || vfedadaseg || ' vfedadasegefec:'
                 || vfedadasegefec || ' vEdadFin:' || vedadfin || ' vVAx:' || vvax || ' vAxn:'
                 || vaxn || ' vProvIni:' || vprovini || ' vProvFin:' || vprovfin || CHR(10);
      vfracany := ABS(MONTHS_BETWEEN(pfecha, TO_DATE(vfechainicial, 'YYYYMMDD')) / 12);
      vpaso := 11;
      vfracmes := MOD(ABS(CEIL(MONTHS_BETWEEN(pfecha, TO_DATE(vfecefe, 'YYYYMMDD'))) - 0),
                      (12 / vfpagprima))
                  /(12 / vfpagprima);
      vprovtotal := vprovfin * vfracany + vprovini *(1 - vfracany) + vprimagar *(1 - vfracmes);
      vpaso := 12;
      valores := valores || ' vFracAny:' || vfracany || ' vFracMes:' || vfracmes || CHR(10);
      --dbms_output.put_line('Valores:'||Valores);
      RETURN(vprovtotal *(1 +(vgiii / 100)));
   EXCEPTION
      WHEN OTHERS THEN
         --dbms_output.put_line('Valores Error:'||Valores);
         p_tab_error(f_sysdate, f_user, 'f_ProvDecesosfec others', vpaso,
                     valores || ' ' || SQLERRM, 'AAAA');
         RETURN NULL;
   END f_pdecesosf;

   /*************************************************************************
      -- BUG 7959 - 03/2009 - JRH  - Decesos
      Calcula la provisión total de una póliza de decesos.
      Param IN psesion: Sesión
      Param IN psseguro: Seguro
      Param IN pfecha : Fecha
      return             : Provisión, null si hay error.
   *************************************************************************/
   FUNCTION f_pdecesos(psesion IN NUMBER, psseguro IN NUMBER, pfecha IN DATE)
      RETURN NUMBER IS
      vproduc        productos.sproduc%TYPE;
      vact           seguros.cactivi%TYPE;
      vpaso          NUMBER := 0;
      vimporte       NUMBER;
      vimportefin    NUMBER := 0;
      verrform       EXCEPTION;
      vnum_err       NUMBER;

      CURSOR garprov(prod NUMBER, cact NUMBER) IS
         SELECT p.sproduc, g.cgarant, g.clave, g.cactivi
           FROM productos p, garanformula g
          WHERE p.sproduc = prod
            AND p.cramo = g.cramo
            AND p.cmodali = g.cmodali
            AND p.ctipseg = g.ctipseg
            AND p.ccolect = g.ccolect
            AND g.cactivi = cact
            AND g.ccampo = 'IPROVAC';
   BEGIN
      vproduc := pac_gfi.f_sgt_parms('SPRODUC', psesion);
      vact := NVL(pac_gfi.f_sgt_parms('CACTIVI', psesion), 0);
      vpaso := 1;

      FOR reg IN garprov(vproduc, vact) LOOP
         vpaso := 2;
         vnum_err := pac_calculo_formulas.calc_formul(pfecha, reg.sproduc, reg.cactivi,
                                                      reg.cgarant, 1, psseguro, reg.clave,
                                                      vimporte, NULL, NULL, 2, pfecha, 'R');

         IF vnum_err <> 0 THEN
            RAISE verrform;
         END IF;

         vpaso := 3;
         vimportefin := vimportefin + vimporte;
      END LOOP;

      vpaso := 4;
      RETURN vimportefin;
   EXCEPTION
      WHEN verrform THEN
         p_tab_error(f_sysdate, f_user, 'f_Tasa_Decesos others', vpaso,
                     'fecha:' || fecha || 'vImporte:' || vimporte || 'vImporteFin:'
                     || vimportefin || 'pfecha:' || pfecha || 'sseguro:' || psseguro || ' '
                     || 'vErrForm',
                     'AAAA');
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'f_Tasa_Decesos others', vpaso,
                     'fecha:' || fecha || 'vImporte:' || vimporte || 'vImporteFin:'
                     || vimportefin || 'pfecha:' || pfecha || 'sseguro:' || psseguro || ' '
                     || SQLERRM,
                     'AAAA');
         RETURN NULL;
   END f_pdecesos;

   /*************************************************************************
        -- BUG 7959 - 03/2009 - JRH  - Decesos
        Calcula la provisión total de una póliza de decesos.
        Param IN psesion: Sesión
        Param IN psseguro: Seguro
        Param IN pfecha : Fecha
        return             : Provisión, null si hay error.
     *************************************************************************/
   FUNCTION f_cpsaldodeu(
      psesion IN NUMBER,
      porigen IN NUMBER,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER)
      RETURN NUMBER IS
      vtraza         NUMBER := 0;
      vnmovimi       NUMBER;
      vorigen        NUMBER;   -- si ORGIEN = 0  --> SOL
                               -- si ORGIEN = 1  --> EST
                               -- si ORGIEN = 2  --> SEG
      vtab           VARCHAR2(10);
      vquery         VARCHAR2(4000);
      vicapmaxpol    NUMBER;
      vicapital      NUMBER;
      s              VARCHAR2(4000);
      v              NUMBER;
   BEGIN
      vtraza := 1;

      IF porigen = 1 THEN
         vtab := 'EST';
      ELSE
         vtab := ' ';
      END IF;

      vtraza := 2;
      vquery := 'begin   select nvl(max( icapmax), 0) into :vicapmaxpol from ' || vtab
                || 'saldodeutorseg  where sseguro=  :psseguro and nmovimi = :pnmovimi;  end;';
      vtraza := 3;

      EXECUTE IMMEDIATE vquery
                  USING OUT vicapmaxpol, IN psseguro, IN pnmovimi;

      vtraza := 4;
      vtraza := 7;
      -- Bug 11165 - 16/09/2009 - AMC - Se sustituñe  detsaldodeutorseg por prestamoseg
      vquery := ' begin  select sum(nvl(icapaseg,0))into :vicapital  from  ' || vtab
                || 'prestamoseg  where sseguro=  :psseguro and nmovimi = :pnmovimi;  end;';
      vtraza := 8;

      EXECUTE IMMEDIATE vquery
                  USING OUT vicapital, IN psseguro, IN pnmovimi;

      vtraza := 9;

      IF NVL(vicapital, 0) > NVL(vicapmaxpol, 0)
         AND NVL(vicapmaxpol, 0) != 0 THEN
         vtraza := 11;
         RETURN vicapmaxpol;
      ELSE
         vtraza := 12;
         RETURN vicapital;
      END IF;

      vtraza := 13;
      --Ini bug.: 0012912 - ICV - 10/02/2010
      RETURN NULL;
   --Fin bug.: 0012912
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'f_cpsaldodeu', vtraza,
                     ' -psesion:' || psesion || ' -psseguro:' || psseguro || ' -vOrigen:'
                     || vorigen || ' -vnmovimi:' || vnmovimi || ' -vquery:  ' || vquery,
                     SQLERRM);
         RETURN NULL;
   END f_cpsaldodeu;

   -- BUG 10846 - 13/10/2009 - RSC - Operaciones con fondos
   FUNCTION fechaultcambprima281(
      psesion NUMBER,
      pseguro IN NUMBER,
      priesgo IN NUMBER,
      importeprimper OUT NUMBER)
      RETURN NUMBER IS
      fechaultcamb   DATE;
      vnmovimi       NUMBER(10);
      vssegpol       NUMBER;
      seguroini      NUMBER;
      importeprimperpreg NUMBER(14, 3);

      CURSOR tablasseg(psseguro NUMBER) IS
         SELECT   movseguro.fefecto, movseguro.nmovimi
             FROM seguros s, movseguro, detmovseguro det1
            WHERE s.sseguro = pseguro
              AND movseguro.sseguro = s.sseguro
              AND movseguro.cmotmov IN(281, 666)
              --and movseguro.fefecto<=pfecha
              AND det1.sseguro = movseguro.sseguro
              AND det1.cmotmov = DECODE(movseguro.cmotmov, 666, 281, 281)
              AND det1.nmovimi = movseguro.nmovimi
              AND det1.nriesgo = NVL(priesgo, 1)
              AND f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.cactivi,
                                  det1.cgarant, 'TIPO') = 3   -- PRIMA AHORRO
              AND NOT EXISTS(SELECT 1
                               FROM detmovseguro det2
                              WHERE det2.sseguro = det1.sseguro
                                AND det2.cmotmov IN(266, 276)
                                AND det2.nmovimi = det1.nmovimi
                                AND det2.nriesgo = det1.nriesgo)   --Que no sea una suspensión.
         ORDER BY 1 DESC;

      CURSOR tablasest IS
         SELECT   s.fefecto
             INTO fechaultcamb
             FROM estseguros s, estdetmovseguro det1
            WHERE s.sseguro = pseguro
              AND s.sseguro = det1.sseguro
              AND det1.cmotmov = 281
              AND det1.nriesgo = NVL(priesgo, 1)
              AND f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.cactivi,
                                  det1.cgarant, 'TIPO') = 3   -- PRIMA AHORRO
              AND NOT EXISTS(SELECT 1
                               FROM estdetmovseguro det2
                              WHERE det2.sseguro = det1.sseguro
                                AND det2.cmotmov IN(266, 276)
                                AND det2.nmovimi = det1.nmovimi
                                AND det2.nriesgo = det1.nriesgo)
         ORDER BY 1 DESC;
   BEGIN
      importeprimper := NULL;
      importeprimperpreg := NVL(resp(psesion, 1025), 0);   --Migración
      fechaultcamb := NULL;
      vnmovimi := NULL;

      --Si estamos en un suplemento
      OPEN tablasest;

      FETCH tablasest
       INTO fechaultcamb;

      IF tablasest%FOUND THEN
         --Buscamos el valor de la prima para esa fecha
         BEGIN
            SELECT estgaranseg.icapital, s.ssegpol
              INTO importeprimper, vssegpol
              FROM estseguros s, estgaranseg
             WHERE s.sseguro = pseguro
               AND estgaranseg.sseguro = s.sseguro
               AND estgaranseg.nriesgo = NVL(priesgo, 1)
               AND f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.cactivi,
                                   estgaranseg.cgarant, 'TIPO') = 3;   -- PRIMA AHORRO
         EXCEPTION
            WHEN OTHERS THEN
               importeprimper := NULL;
         END;

         RETURN TO_CHAR(fechaultcamb, 'YYYYMMDD');
      END IF;

      CLOSE tablasest;

      --No estamos en suplemento de cambio de prima, buscamos la prima base ahora en las SEG.
      BEGIN
         SELECT ssegpol   -- Queremos el sseguro original
           INTO seguroini
           FROM estseguros
          WHERE sseguro = pseguro;
      -- v_tablas := 'EST';
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            seguroini := pseguro;
      --  v_tablas := NULL;
      END;

      fechaultcamb := NULL;
      vnmovimi := NULL;

      OPEN tablasseg(seguroini);

      FETCH tablasseg
       INTO fechaultcamb, vnmovimi;

      importeprimper := NULL;

      IF tablasseg%FOUND THEN
         --Buscamos la prima base en ese movimiento
         BEGIN
            SELECT icapital
              INTO importeprimper
              FROM seguros s, garanseg
             WHERE s.sseguro = seguroini
               AND garanseg.sseguro = s.sseguro
               AND garanseg.nriesgo = NVL(priesgo, 1)
               AND garanseg.nmovimi = vnmovimi
               AND f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.cactivi,
                                   garanseg.cgarant, 'TIPO') = 3;   -- PRIMA AHORRO
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               importeprimper := NULL;
            WHEN OTHERS THEN
               importeprimper := NULL;
         END;
      END IF;

      IF importeprimper IS NULL THEN   --Si no ha habido supl. de cambio de prima
         IF importeprimperpreg <> 0 THEN
            importeprimper := importeprimperpreg;   --Cogemos el de la migración
         ELSE
            BEGIN
               SELECT icapital
                 INTO importeprimper   --Cogemos el de la nmovimi=1
                 FROM seguros s, garanseg
                WHERE s.sseguro = seguroini
                  AND garanseg.sseguro = s.sseguro
                  AND garanseg.nriesgo = NVL(priesgo, 1)
                  AND garanseg.nmovimi = 1
                  AND f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.cactivi,
                                      garanseg.cgarant, 'TIPO') = 3;   -- PRIMA AHORRO
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  importeprimper := NVL(resp(psesion, 1001), 0);   --La pregunta 1001 (Estmaos en una NP).
            END;
         END IF;
      END IF;

      CLOSE tablasseg;

      RETURN TO_CHAR(fechaultcamb, 'YYYYMMDD');
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END fechaultcambprima281;

   FUNCTION fechaultcambprima500(
      psesion NUMBER,
      pseguro IN NUMBER,
      pfecha IN NUMBER,
      priesgo IN NUMBER)
      RETURN NUMBER IS
      fechaultcamb   DATE;
      vssegpol       NUMBER;
      seguroini      NUMBER;

      CURSOR tablasseg(psseguro NUMBER) IS
         SELECT   MAX(movseguro.fefecto)
             FROM seguros s, movseguro, detmovseguro det1
            WHERE s.sseguro = pseguro
              AND movseguro.sseguro = s.sseguro
              AND movseguro.cmotmov IN(500, 666)
              AND movseguro.fefecto <= TO_DATE(pfecha, 'YYYYMMDD')
              AND det1.sseguro = movseguro.sseguro
              AND det1.cmotmov = DECODE(movseguro.cmotmov, 666, 500, 500)
              AND det1.nmovimi = movseguro.nmovimi
              AND det1.nriesgo = NVL(priesgo, 1)
         ORDER BY 1 DESC;

      CURSOR tablasest IS
         SELECT   s.fefecto
             INTO fechaultcamb
             FROM estseguros s, estdetmovseguro det1
            WHERE s.sseguro = pseguro
              AND s.sseguro = det1.sseguro
              AND det1.cmotmov = 500
              AND det1.nriesgo = NVL(priesgo, 1)
         ORDER BY 1 DESC;
   BEGIN
      fechaultcamb := NULL;

      --Si estamos en un suplemento
      OPEN tablasest;

      FETCH tablasest
       INTO fechaultcamb;

      IF tablasest%FOUND THEN
         --Buscamos el valor de la prima para esa fecha
         RETURN TO_CHAR(fechaultcamb, 'YYYYMMDD');
      END IF;

      CLOSE tablasest;

      --No estamos en suplemento de cambio de prima, buscamos la prima base ahora en las SEG.
      BEGIN
         SELECT ssegpol   -- Queremos el sseguro original
           INTO seguroini
           FROM estseguros
          WHERE sseguro = pseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            seguroini := pseguro;
      END;

      fechaultcamb := NULL;

      OPEN tablasseg(seguroini);

      FETCH tablasseg
       INTO fechaultcamb;

      IF tablasseg%FOUND THEN
         --Buscamos el valor de la prima para esa fecha
         RETURN TO_CHAR(fechaultcamb, 'YYYYMMDD');
      END IF;

      CLOSE tablasseg;

      RETURN TO_CHAR(fechaultcamb, 'YYYYMMDD');
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END fechaultcambprima500;

   FUNCTION fechaultcambprima508(
      psesion NUMBER,
      pseguro IN NUMBER,
      pfecha IN NUMBER,
      priesgo IN NUMBER)
      RETURN NUMBER IS
      fechaultcamb   DATE;
      vssegpol       NUMBER;
      seguroini      NUMBER;

      CURSOR tablasseg(psseguro NUMBER) IS
         SELECT   MAX(movseguro.fefecto)
             FROM seguros s, movseguro, detmovseguro det1
            WHERE s.sseguro = pseguro
              AND movseguro.sseguro = s.sseguro
              AND movseguro.cmotmov IN(508, 666)
              AND movseguro.fefecto <= TO_DATE(pfecha, 'YYYYMMDD')
              AND det1.sseguro = movseguro.sseguro
              AND det1.cmotmov = DECODE(movseguro.cmotmov, 666, 508, 508)
              AND det1.nmovimi = movseguro.nmovimi
              AND det1.nriesgo = NVL(priesgo, 1)
         ORDER BY 1 DESC;

      CURSOR tablasest IS
         SELECT   s.fefecto
             INTO fechaultcamb
             FROM estseguros s, estdetmovseguro det1
            WHERE s.sseguro = pseguro
              AND s.sseguro = det1.sseguro
              AND det1.cmotmov = 508
              AND det1.nriesgo = NVL(priesgo, 1)
         ORDER BY 1 DESC;
   BEGIN
      fechaultcamb := NULL;

      --Si estamos en un suplemento
      OPEN tablasest;

      FETCH tablasest
       INTO fechaultcamb;

      IF tablasest%FOUND THEN
         --Buscamos el valor de la prima para esa fecha
         RETURN TO_CHAR(fechaultcamb, 'YYYYMMDD');
      END IF;

      CLOSE tablasest;

      --No estamos en suplemento de cambio de prima, buscamos la prima base ahora en las SEG.
      BEGIN
         SELECT ssegpol   -- Queremos el sseguro original
           INTO seguroini
           FROM estseguros
          WHERE sseguro = pseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            seguroini := pseguro;
      END;

      fechaultcamb := NULL;

      OPEN tablasseg(seguroini);

      FETCH tablasseg
       INTO fechaultcamb;

      IF tablasseg%FOUND THEN
         --Buscamos el valor de la prima para esa fecha
         RETURN TO_CHAR(fechaultcamb, 'YYYYMMDD');
      END IF;

      CLOSE tablasseg;

      RETURN TO_CHAR(fechaultcamb, 'YYYYMMDD');
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END fechaultcambprima508;

   FUNCTION fechaultcambprima526(
      psesion NUMBER,
      pseguro IN NUMBER,
      pfecha IN NUMBER,
      priesgo IN NUMBER)
      RETURN NUMBER IS
      fechaultcamb   DATE;
      vssegpol       NUMBER;
      seguroini      NUMBER;

      CURSOR tablasseg(psseguro NUMBER) IS
         SELECT   MAX(movseguro.fefecto)
             FROM seguros s, movseguro, detmovseguro det1
            WHERE s.sseguro = pseguro
              AND movseguro.sseguro = s.sseguro
              AND movseguro.cmotmov IN(526, 666)
              AND movseguro.fefecto <= TO_DATE(pfecha, 'YYYYMMDD')
              AND det1.sseguro = movseguro.sseguro
              AND det1.cmotmov = DECODE(movseguro.cmotmov, 666, 526, 526)
              AND det1.nmovimi = movseguro.nmovimi
              AND det1.nriesgo = NVL(priesgo, 1)
         ORDER BY 1 DESC;

      CURSOR tablasest IS
         SELECT   s.fefecto
             INTO fechaultcamb
             FROM estseguros s, estdetmovseguro det1
            WHERE s.sseguro = pseguro
              AND s.sseguro = det1.sseguro
              AND det1.cmotmov = 526
              AND det1.nriesgo = NVL(priesgo, 1)
         ORDER BY 1 DESC;
   BEGIN
      fechaultcamb := NULL;

      --Si estamos en un suplemento
      OPEN tablasest;

      FETCH tablasest
       INTO fechaultcamb;

      IF tablasest%FOUND THEN
         --Buscamos el valor de la prima para esa fecha
         RETURN TO_CHAR(fechaultcamb, 'YYYYMMDD');
      END IF;

      CLOSE tablasest;

      --No estamos en suplemento de cambio de prima, buscamos la prima base ahora en las SEG.
      BEGIN
         SELECT ssegpol   -- Queremos el sseguro original
           INTO seguroini
           FROM estseguros
          WHERE sseguro = pseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            seguroini := pseguro;
      END;

      fechaultcamb := NULL;

      OPEN tablasseg(seguroini);

      FETCH tablasseg
       INTO fechaultcamb;

      IF tablasseg%FOUND THEN
         --Buscamos el valor de la prima para esa fecha
         RETURN TO_CHAR(fechaultcamb, 'YYYYMMDD');
      END IF;

      CLOSE tablasseg;

      RETURN TO_CHAR(fechaultcamb, 'YYYYMMDD');
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END fechaultcambprima526;

   FUNCTION fechaultcambprima266(
      psesion NUMBER,
      pseguro IN NUMBER,
      pfecha IN NUMBER,
      priesgo IN NUMBER)
      RETURN NUMBER IS
      fechaultcamb   DATE;
      vssegpol       NUMBER;
      seguroini      NUMBER;

      CURSOR tablasseg(psseguro NUMBER) IS
         SELECT   MAX(movseguro.fefecto)
             FROM seguros s, movseguro, detmovseguro det1
            WHERE s.sseguro = pseguro
              AND movseguro.sseguro = s.sseguro
              AND movseguro.cmotmov IN(266, 666)
              AND movseguro.fefecto <= TO_DATE(pfecha, 'YYYYMMDD')
              AND det1.sseguro = movseguro.sseguro
              AND det1.cmotmov = DECODE(movseguro.cmotmov, 666, 266, 266)
              AND det1.nmovimi = movseguro.nmovimi
              AND det1.nriesgo = NVL(priesgo, 1)
         ORDER BY 1 DESC;

      CURSOR tablasest IS
         SELECT   s.fefecto
             INTO fechaultcamb
             FROM estseguros s, estdetmovseguro det1
            WHERE s.sseguro = pseguro
              AND s.sseguro = det1.sseguro
              AND det1.cmotmov = 266
              AND det1.nriesgo = NVL(priesgo, 1)
         ORDER BY 1 DESC;
   BEGIN
      fechaultcamb := NULL;

      --Si estamos en un suplemento
      OPEN tablasest;

      FETCH tablasest
       INTO fechaultcamb;

      IF tablasest%FOUND THEN
         --Buscamos el valor de la prima para esa fecha
         RETURN TO_CHAR(fechaultcamb, 'YYYYMMDD');
      END IF;

      CLOSE tablasest;

      --No estamos en suplemento de cambio de prima, buscamos la prima base ahora en las SEG.
      BEGIN
         SELECT ssegpol   -- Queremos el sseguro original
           INTO seguroini
           FROM estseguros
          WHERE sseguro = pseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            seguroini := pseguro;
      END;

      fechaultcamb := NULL;

      OPEN tablasseg(seguroini);

      FETCH tablasseg
       INTO fechaultcamb;

      IF tablasseg%FOUND THEN
         --Buscamos el valor de la prima para esa fecha
         RETURN TO_CHAR(fechaultcamb, 'YYYYMMDD');
      END IF;

      CLOSE tablasseg;

      RETURN TO_CHAR(fechaultcamb, 'YYYYMMDD');
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END fechaultcambprima266;

   FUNCTION f_cesperado(psesion IN NUMBER, psseguro IN NUMBER, pfecha IN NUMBER)
      RETURN NUMBER IS
      fechainic      DATE;
      fechafin       DATE;
      v_tablas       VARCHAR2(3);
      vforpag        NUMBER;
      fecha          NUMBER;
      vfecha_aux     DATE;
      aportacion_inicial NUMBER;
      aportacion_periodica NUMBER;
      -- Parámetros de ejecución
      fecefe         NUMBER;
      fec_vto        NUMBER;
      fpagprima      NUMBER;
      nmovimi        NUMBER;
      nriesgo        NUMBER;
      v_rendesp      NUMBER;
      v_fnacimi      NUMBER;
      vcrevali       seguros.crevali%TYPE;
      virevali       seguros.irevali%TYPE;
      vprevali       seguros.prevali%TYPE;
      v_nrenova      seguros.nrenova%TYPE;
      -- Variables de cálculo
      vfact1         NUMBER;
      vprimer        NUMBER := 1;
      v_edad1        NUMBER;
      v_edad2        NUMBER;
      v_fact2        NUMBER;
      v_crecimiento  NUMBER;
      v_anyscreix    NUMBER := 0;
      v_rendesp_ini  NUMBER;
      v_sproduc      NUMBER;
      -- Resultado
      v_capesperado  NUMBER;
      v_seguroini    estseguros.ssegpol%TYPE;
      -- RSC 14/04/2009
      v_importeprimper NUMBER;
      v_fecha281     NUMBER;
      v_fecha500     NUMBER;
      v_fecha526     NUMBER;
      v_fecha508     NUMBER;
      v_fecha266     NUMBER;
      v_capesp_aux   NUMBER;
      v_fechacorte   NUMBER;
      v_perfil       NUMBER;
      -- 08/05/2009
      v_fnacmenor    NUMBER;
      v_cpregun576   pregunpro.cpregun%TYPE;
      v_edadmenor    NUMBER;
      i              NUMBER;
      v_aporta       NUMBER;
      v_fechaold     NUMBER;
      v_traza        NUMBER := 0;
      -- Bug 10040 - RSC - 15/06/2009 - Ajustes PPJ D y PLA Estudiant
      v_opdinamica   NUMBER;

      -- Fin Bug 10040
      CURSOR c_aport_per(pfechaini IN DATE) IS
         SELECT   g.icapital, g.finiefe
             FROM garanseg g, seguros s
            WHERE s.sseguro = psseguro
              AND g.sseguro = s.sseguro
              AND g.nriesgo = nriesgo
              AND f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.cactivi,
                                  g.cgarant, 'TIPO') = 3   -- PRIMA AHORRO
              AND TRUNC(g.finiefe) <= pfechaini
              AND v_tablas IS NULL
         UNION ALL
         SELECT   g.icapital, g.finiefe
             FROM estgaranseg g, estseguros s
            WHERE s.sseguro = psseguro
              AND g.sseguro = s.sseguro
              AND g.nriesgo = nriesgo
              AND g.nmovimi = nmovimi
              AND f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.cactivi,
                                  g.cgarant, 'TIPO') = 3   -- PRIMA AHORRO
              AND v_tablas = 'EST'
         ORDER BY finiefe DESC;

      -- Bug 10828 - RSC - 18/09/2009 - CRE - Revisión de los productos PPJ dinámico y Pla Estudiant (ajustes)
      v_fecha        NUMBER;
      -- Fin Bug 10828

      -- Bug 11771 - RSC - 04/11/2009 - CRE - Ajustes en simulación y contratación PPJ Dinámico/Pla Estudiant
      v_accion       NUMBER;
      v_capesp_gar   garanseg.icapital%TYPE;
      v_finiefe_cesp garanseg.finiefe%TYPE;

      CURSOR c_capesp_gar(pfechaini IN DATE) IS
         SELECT   g.icapital, g.finiefe
             FROM garanseg g, seguros s
            WHERE s.sseguro = psseguro
              AND g.sseguro = s.sseguro
              AND g.nriesgo = nriesgo
              AND f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.cactivi,
                                  g.cgarant, 'TIPO') = 9
              AND TRUNC(g.finiefe) <= pfechaini
              AND v_tablas IS NULL
         UNION ALL
         SELECT   g.icapital, g.finiefe
             FROM estgaranseg g, estseguros s
            WHERE s.sseguro = psseguro
              AND g.sseguro = s.sseguro
              AND g.nriesgo = nriesgo
              AND g.nmovimi = nmovimi
              AND f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.cactivi,
                                  g.cgarant, 'TIPO') = 9
              AND v_tablas = 'EST'
         ORDER BY finiefe DESC;
   -- Fin Bug 11771
   BEGIN
      v_traza := 1;

      BEGIN
         SELECT ssegpol   -- Queremos el sseguro original
           INTO v_seguroini
           FROM estseguros
          WHERE sseguro = psseguro;

         v_tablas := 'EST';
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            v_seguroini := psseguro;
            v_tablas := NULL;
      END;

      v_traza := 2;
      fpagprima := NVL(pac_gfi.f_sgt_parms('FPAGPRIMA', psesion), 0);
      nmovimi := pac_gfi.f_sgt_parms('NMOVIMI', psesion);
      nriesgo := pac_gfi.f_sgt_parms('NRIESGO', psesion);
      v_perfil := pac_gfi.f_sgt_parms('PERFIL', psesion);
      fec_vto := pac_gfi.f_sgt_parms('FEC_VTO', psesion);
      fecefe := pac_gfi.f_sgt_parms('FEFEPOL', psesion);
      v_fnacimi := pac_gfi.f_sgt_parms('FNACIMI', psesion);
      vcrevali := NVL(pac_gfi.f_sgt_parms('CREVALI', psesion), 0);
      virevali := NVL(pac_gfi.f_sgt_parms('IREVALI', psesion), 0);
      vprevali := NVL(pac_gfi.f_sgt_parms('PREVALI', psesion), 0);
      v_nrenova := NVL(pac_gfi.f_sgt_parms('NRENOVA', psesion), 0);
      v_sproduc := NVL(pac_gfi.f_sgt_parms('SPRODUC', psesion), 0);
      v_traza := 3;
      -- Bug 10828 - RSC - 18/09/2009 - CRE - Revisión de los productos PPJ dinámico y Pla Estudiant (ajustes)
      v_fecha := NVL(pac_gfi.f_sgt_parms('FECHA', psesion), 0);
      -- Fin Bug 10828

      -- Bug 11771 - RSC - 04/11/2009 - CRE - Ajustes en simulación y contratación PPJ Dinámico/Pla Estudiant
      v_accion := pac_gfi.f_sgt_parms('ACCION', psesion);

      -- Fin Bug 11771
      IF v_tablas = 'EST' THEN
         fecefe := v_fecha;
      END IF;

      -- Fecha de nacimiento del menor ---------
      BEGIN
         SELECT cpregun
           INTO v_cpregun576
           FROM pregunpro
          WHERE cpregun = 576
            AND sproduc = v_sproduc;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            v_cpregun576 := NULL;
      END;

      v_traza := 4;

      IF v_cpregun576 IS NOT NULL THEN
         BEGIN
            SELECT TO_NUMBER(TO_CHAR(TO_DATE(trespue, 'DD/MM/YYYY'), 'YYYYMMDD'))   -- Queremos el sseguro original
              INTO v_fnacmenor
              FROM estpregunpolseg
             WHERE sseguro = psseguro
               AND cpregun = 576
               AND nmovimi = (SELECT MAX(nmovimi)
                                FROM estpregunpolseg
                               WHERE sseguro = psseguro
                                 AND cpregun = 576);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               SELECT TO_NUMBER(TO_CHAR(TO_DATE(trespue, 'DD/MM/YYYY'), 'YYYYMMDD'))   -- Queremos el sseguro original
                 INTO v_fnacmenor
                 FROM pregunpolseg
                WHERE sseguro = psseguro
                  AND cpregun = 576
                  AND nmovimi = (SELECT MAX(nmovimi)
                                   FROM pregunpolseg
                                  WHERE sseguro = psseguro
                                    AND cpregun = 576);
         END;
      END IF;

      -- Bug 10040 - RSC - 15/06/2009 - Ajustes PPJ D y PLA Estudiant
      BEGIN
         SELECT crespue   -- Queremos el sseguro original
           INTO v_opdinamica
           FROM estpregunseg
          WHERE sseguro = psseguro
            AND cpregun = 560
            AND nmovimi = (SELECT MAX(nmovimi)
                             FROM estpregunseg
                            WHERE sseguro = psseguro
                              AND cpregun = 560);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            BEGIN
               SELECT crespue
                 INTO v_opdinamica
                 FROM pregunseg
                WHERE sseguro = psseguro
                  AND cpregun = 560
                  AND nmovimi = (SELECT MAX(nmovimi)
                                   FROM pregunseg
                                  WHERE sseguro = psseguro
                                    AND cpregun = 560);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  v_opdinamica := 0;   -- BUG20676:DRA:29/12/2011
            END;
      END;

      -- Fin Bug 10040
      v_traza := 6;
      -- Bug 11678 - 03/11/2009 - JMF - CRE - Ajustes cartera PPJ dinámico y Pla Estudiant
      -- Usar 'pac_propio_formul'
      v_fecha281 := pac_propio_formul.fechaultcambprima281(psesion, psseguro, nriesgo,
                                                           v_importeprimper);
      v_traza := 7;
      -- Bug 11678 - 03/11/2009 - JMF - CRE - Ajustes cartera PPJ dinámico y Pla Estudiant
      -- Usar 'pac_propio_formul'
      v_fecha500 := pac_propio_formul.fechaultcambprima500(psesion, psseguro, pfecha, nriesgo);
      v_traza := 8;
      -- Bug 11678 - 03/11/2009 - JMF - CRE - Ajustes cartera PPJ dinámico y Pla Estudiant
      -- Usar 'pac_propio_formul'
      v_fecha508 := pac_propio_formul.fechaultcambprima508(psesion, psseguro, pfecha, nriesgo);
      v_traza := 9;
      -- Bug 11678 - 03/11/2009 - JMF - CRE - Ajustes cartera PPJ dinámico y Pla Estudiant
      -- Usar 'pac_propio_formul'
      v_fecha526 := pac_propio_formul.fechaultcambprima526(psesion, psseguro, pfecha, nriesgo);
      v_traza := 10;
      -- Bug 11678 - 03/11/2009 - JMF - CRE - Ajustes cartera PPJ dinámico y Pla Estudiant
      -- Usar 'pac_propio_formul'
      v_fecha266 := pac_propio_formul.fechaultcambprima266(psesion, psseguro, pfecha, nriesgo);
      v_traza := 11;

      SELECT DECODE(fpagprima, 1, 12, 12, 1, 4, 3, 2, 6, fpagprima)
        INTO vforpag
        FROM DUAL;

      v_traza := 12;

      -- Bug 11771 - RSC - 04/11/2009 - CRE - Ajustes en simulación y contratación PPJ Dinámico/Pla Estudiant
      -- Añadimos: v_tablas = 'EST'
      IF v_tablas = 'EST'
         OR(v_fecha281 IS NOT NULL)
         OR(v_fecha500 IS NOT NULL)
         OR(v_fecha508 IS NOT NULL)
         OR(v_fecha526 IS NOT NULL)
         OR(v_fecha266 IS NOT NULL)
         OR(nmovimi = 1
            AND v_accion = 0) THEN
         -- Bug 11771 - RSC - 04/11/2009 - CRE - Ajustes en simulación y contratación PPJ Dinámico/Pla Estudiant
         IF (nmovimi = 1
             AND v_accion = 0) THEN
            v_fechacorte := fecefe;
            v_capesperado := NVL(resp(psesion, 1002), 0);   -- La aportación extraordinaria
         ELSE
            IF v_fecha281 IS NULL
               AND v_fecha500 IS NULL
               AND v_fecha508 IS NULL
               AND v_fecha526 IS NULL
               AND v_fecha266 IS NULL THEN   -- v_tablas = 'EST'
               -- Entonces es que v_tablas = 'EST'
               v_fechacorte := fecefe;
            ELSE
               SELECT GREATEST(NVL(v_fecha281, fecefe), NVL(v_fecha500, fecefe),
                               NVL(v_fecha508, fecefe), NVL(v_fecha526, fecefe),
                               NVL(v_fecha266, fecefe), fecefe)
                 INTO v_fechacorte
                 FROM DUAL;
            END IF;

            -- Provisión a fecha de corte
            v_capesperado := pac_operativa_finv.ff_provmat(psesion, v_seguroini, v_fechacorte);
         END IF;

         -- Fin Bug 11771

         -- Calculo del capital esperado en el nuevo regimen (tras un suplemento de cambio de perfil,
         -- un suplemento de aportación extraordinaria, una modificación de prima periodica y/o
         -- rescate parcial
         IF fpagprima <> 0 THEN   --Tenemos prima periodica
            OPEN c_aport_per(TO_DATE(v_fechacorte, 'YYYYMMDD'));

            FETCH c_aport_per
             INTO aportacion_periodica, vfecha_aux;

            CLOSE c_aport_per;

            aportacion_periodica := NVL(aportacion_periodica, NVL(resp(psesion, 1001), 0));
            -- Tratamiento de las periodica
            fechainic := TO_DATE(v_fechacorte, 'YYYYMMDD')
                         + NVL(f_parproductos_v(v_sproduc, 'DIASCARGA_PRIMA'), 0);
            v_edad1 := (TO_DATE(v_fechacorte, 'YYYYMMDD') - TO_DATE(v_fnacimi, 'YYYYMMDD'))
                       / 365.25;
            fecha := TO_NUMBER(TO_CHAR(fechainic, 'YYYYMMDD'));
            i := 1;

            -- BUG 15412 - 07/2010 - JRH  -  0015412: CRE - Aportacions extraordinàries en el mes de venciment de la pòlissa
            IF TO_DATE(fecha, 'YYYYMMDD') > TO_DATE(fec_vto, 'YYYYMMDD') THEN
               fecha := fec_vto;
            END IF;

            -- Fi BUG 15412 - 07/2010 - JRH
            WHILE TO_DATE(fecha, 'YYYYMMDD') <= TO_DATE(fec_vto, 'YYYYMMDD') LOOP
               -- Edad a la fecha anterior
               vfact1 := 0;
               v_fact2 := 0;

               IF TO_DATE(fecha, 'YYYYMMDD') <= TO_DATE(fec_vto, 'YYYYMMDD') THEN
                  vfact1 := 1;

                  -- Aportacion periodica
                  IF MOD(i - 1, vforpag) = 0 THEN
                     v_fact2 := 1;
                  ELSE
                     v_fact2 := 0;
                  END IF;
               END IF;

               -- Cálculo anys creixement
               IF i > 1 THEN
                  -- =SI(MES(B29)=$C$12;E28+1;E28)
                  IF SUBSTR(LPAD(v_nrenova, 4, '0'), 1, 2) =
                                                     TO_CHAR(TO_DATE(fecha, 'YYYYMMDD'), 'MM') THEN
                     v_anyscreix := v_anyscreix + 1;
                  END IF;
               ELSE
                  v_anyscreix := 0;
               END IF;

               -- Cálculo de crecimiento
               -- =SI($C$10="Lineal";1+ $C$11*E28;(1+ $C$11)^E28)
               IF vcrevali = 1 THEN   -- Lineal
                  v_crecimiento := 1 +((virevali / 100) * v_anyscreix);
               ELSE
                  v_crecimiento := POWER((1 +(vprevali / 100)), v_anyscreix);
               END IF;

               -- Edad a la fecha actual
               v_edad2 := (TO_DATE(fecha, 'YYYYMMDD') - TO_DATE(v_fnacimi, 'YYYYMMDD'))
                          / 365.25;

               IF v_cpregun576 IS NOT NULL THEN
                  v_edadmenor := (TO_DATE(fecha, 'YYYYMMDD') - TO_DATE(v_fnacmenor, 'YYYYMMDD'))
                                 / 365.25;

                  -- Rendimiento
                  IF v_opdinamica = 0 THEN
                     SELECT DECODE(vtramo(psesion, 1512, v_perfil),
                                   -1, vtramo(psesion, vtramo(psesion, 1507, v_sproduc),
                                              TRUNC(v_edadmenor)),
                                   vtramo(psesion, 1512, v_perfil))
                       INTO v_rendesp
                       FROM DUAL;
                  ELSE
                     SELECT vtramo(psesion, vtramo(psesion, 1507, v_sproduc),
                                   TRUNC(v_edadmenor))
                       INTO v_rendesp
                       FROM DUAL;
                  END IF;
               ELSE
                  -- Rendimiento
                  IF v_opdinamica = 0 THEN
                     SELECT DECODE(vtramo(psesion, 1512, v_perfil),
                                   -1, vtramo(psesion, vtramo(psesion, 1507, v_sproduc),
                                              TRUNC(v_edad2)),
                                   vtramo(psesion, 1512, v_perfil))
                       INTO v_rendesp
                       FROM DUAL;
                  ELSE
                     SELECT vtramo(psesion, vtramo(psesion, 1507, v_sproduc), TRUNC(v_edad2))
                       INTO v_rendesp
                       FROM DUAL;
                  END IF;
               END IF;

               v_aporta := aportacion_periodica;

               IF MOD(i - 1, vforpag) <> 0 THEN
                  v_aporta := 0;
               END IF;

               v_capesperado := vfact1 * v_capesperado
                                *(POWER((1 +(v_rendesp / 100)),(v_edad2 - v_edad1)))
                                +(v_aporta * v_fact2 * v_crecimiento);
               v_edad1 := (TO_DATE(fecha, 'YYYYMMDD') - TO_DATE(v_fnacimi, 'YYYYMMDD'))
                          / 365.25;
               v_fechaold := TO_NUMBER(TO_CHAR(ADD_MONTHS(fechainic, i - 1), 'YYYYMMDD'));   -- Fecha de la aportación
               fecha := TO_NUMBER(TO_CHAR(ADD_MONTHS(fechainic, i), 'YYYYMMDD'));   -- Fecha de la aportación
               i := i + 1;
            END LOOP;

            -- Capital esperado a vencimiento
            v_capesperado := v_capesperado
                             * POWER((1 +(v_rendesp / 100)),
                                     (TO_DATE(fec_vto, 'YYYYMMDD')
                                      - TO_DATE(v_fechaold, 'YYYYMMDD'))
                                     / 365);
         ELSE
            OPEN c_aport_per(TO_DATE(v_fechacorte, 'YYYYMMDD'));

            FETCH c_aport_per
             INTO aportacion_periodica, vfecha_aux;

            CLOSE c_aport_per;

            v_capesperado := aportacion_periodica;
         END IF;
      -- Nou capital esperat = saldo actual + el nou règim d'aportacions futures
      --v_capesperado := v_capesp_aux + v_capesperado;
      ELSE
         OPEN c_capesp_gar(TO_DATE(v_fecha, 'YYYYMMDD'));

         FETCH c_capesp_gar
          INTO v_capesp_gar, v_finiefe_cesp;

         CLOSE c_capesp_gar;

         v_capesperado := v_capesp_gar;
      END IF;

      RETURN v_capesperado;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_propio_formul.f_cesperado', v_traza,
                     'parametros: psseguro = ' || psseguro, SQLERRM);
         RETURN NULL;
   END f_cesperado;

   FUNCTION ff_cfallec(psesion IN NUMBER, psseguro IN NUMBER, ppfefecto IN NUMBER)
      RETURN NUMBER IS
      v_capesperado  NUMBER;
      v_provision    NUMBER;
      v_cfallec      NUMBER;
   BEGIN
      -- Capital esperado al vencimiento
      -- Bug 11678 - 03/11/2009 - JMF - CRE - Ajustes cartera PPJ dinámico y Pla Estudiant
      -- Usar 'pac_propio_formul'
      v_capesperado := pac_propio_formul.f_cesperado(psesion, psseguro, ppfefecto);
      -- Valor de provisión (Participaciones acumuladas * Precio participacion)
      v_provision := pac_operativa_finv.ff_provmat(psesion, psseguro, ppfefecto);

      SELECT GREATEST((v_capesperado - v_provision), 0)
        INTO v_cfallec
        FROM DUAL;

      RETURN v_cfallec;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_propio_formul.ff_cfallec', NULL,
                     'parametros: psseguro = ' || psseguro, SQLERRM);
         RETURN NULL;
   END ff_cfallec;

-- Fin Bug 10846

   -- BUG-15443
   FUNCTION ff_cbaja(
      psesion IN NUMBER,
      pcmotsin IN NUMBER,
      pfsinies IN NUMBER,
      pfperini IN NUMBER,
      pfperfin IN NUMBER,
      pndiafrq IN NUMBER,
      pntramo IN NUMBER)
      RETURN NUMBER IS
      v_ndias1       NUMBER;
      v_ndias31      NUMBER;
      v_nresul       NUMBER;
      v_nfranq       NUMBER;
   BEGIN
      -- Hay que calcular los dias de franquicia
      IF pcmotsin = 0 THEN
         IF NVL(pndiafrq, 0) -(TO_DATE(pfperini, 'YYYYMMDD') - TO_DATE(pfsinies, 'YYYYMMDD')) >
                                                                                             0 THEN
            v_nfranq := NVL(pndiafrq, 0)
                        -(TO_DATE(pfperini, 'YYYYMMDD') - TO_DATE(pfsinies, 'YYYYMMDD'));
         ELSE
            v_nfranq := 0;
         END IF;
      END IF;

      IF (TO_DATE(pfperfin, 'YYYYMMDD') - TO_DATE(pfsinies, 'YYYYMMDD') + 1 - 30) > 0 THEN   -- El periodo tiene más de 30 días
         IF (TO_DATE(pfperini, 'YYYYMMDD') - TO_DATE(pfsinies, 'YYYYMMDD') + 1 - 30) > 0 THEN   -- Todo está fuera de los 30 días
            v_nresul := pac_sin_formula.f_tramo(psesion, pfsinies, pntramo, 31)
                        *(TO_DATE(pfperfin, 'YYYYMMDD') - TO_DATE(pfperini, 'YYYYMMDD') + 1);
         ELSE   -- Puede entrar todo o parte dentro de los 30 dias
            -- Primeros 30 días (tener en cuenta si hay franquicia)
            v_ndias1 :=(30 - v_nfranq
                        -(TO_DATE(pfperini, 'YYYYMMDD') - TO_DATE(pfsinies, 'YYYYMMDD')));
            -- Dias sucesivos a 30
            v_ndias31 :=((TO_DATE(pfperfin, 'YYYYMMDD') - TO_DATE(pfsinies, 'YYYYMMDD')) - 30
                         + 1);
            v_nresul := pac_sin_formula.f_tramo(psesion, pfsinies, pntramo, 1) * v_ndias1
                        + pac_sin_formula.f_tramo(psesion, pfsinies, pntramo, 31) * v_ndias31;
         END IF;
      ELSE   -- El periodo tiene menos de 30 días
         IF (TO_DATE(pfperfin, 'YYYYMMDD') - TO_DATE(pfperini, 'YYYYMMDD') - NVL(v_nfranq, 0)
             + 1) > 0 THEN
            v_nresul := pac_sin_formula.f_tramo(psesion, pfsinies, pntramo, 1)
                        *(TO_DATE(pfperfin, 'YYYYMMDD') - TO_DATE(pfperini, 'YYYYMMDD')
                          - NVL(v_nfranq, 0) + 1);
         ELSE
            v_nresul := 0;
         END IF;
      END IF;

      RETURN v_nresul;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_propio_formul.ff_cbaja', NULL,
                     'parametros: pcmotsin = ' || pcmotsin || ' pfsinies=' || pfsinies
                     || ' pfperini=' || pfperini || ' pfperfin=' || pfperfin || ' pndiafrq='
                     || pndiafrq || ' pntramo=' || pntramo,
                     SQLERRM);
         RETURN NULL;
   END ff_cbaja;

-- Fin BUG-15443

   /*************************************************************************
      Devuelve el capital pendiente
      Param IN psesion: Sesión
      Param IN psseguro: Seguro
      Param IN pfsinies : Fecha del siniestro

      BUG 16169 - 18/10/2010 - AMC
   *************************************************************************/
   FUNCTION f_get_cappendiente(psesion IN NUMBER, psseguro IN NUMBER, pfsinies IN NUMBER)
      RETURN NUMBER IS
      vicappend      NUMBER;
   BEGIN
      SELECT icappend
        INTO vicappend
        FROM prestcuadroseg p
       WHERE p.sseguro = psseguro
         AND p.fefecto <= TO_DATE(pfsinies, 'YYYYMMDD')
         AND p.fvencim > TO_DATE(pfsinies, 'YYYYMMDD')
         AND p.finicuaseg <= TO_DATE(pfsinies, 'YYYYMMDD')
         AND(p.ffincuaseg > TO_DATE(pfsinies, 'YYYYMMDD')
             OR p.ffincuaseg IS NULL);

      RETURN vicappend;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_propio_formul.f_get_cappendiente', NULL,
                     'parametros: psesion = ' || psesion || ' psseguro=' || psseguro
                     || ' pfsinies=' || pfsinies,
                     SQLERRM);
         RETURN NULL;
   END f_get_cappendiente;
END pac_propio_formul;

/

  GRANT EXECUTE ON "AXIS"."PAC_PROPIO_FORMUL" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PROPIO_FORMUL" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PROPIO_FORMUL" TO "PROGRAMADORESCSI";
