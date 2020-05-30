--------------------------------------------------------
--  DDL for Package Body PAC_FRM_ACTUARIAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_FRM_ACTUARIAL" IS
       /******************************************************************************
      NOMBRE:     PAC_FRM_ACTUARIAL
      PROPÓSITO:  Funciones para el cálculo actuarial

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        XX/XX/XXXX   XXX                1. Creación del package.
      1.1        01/02/2009   JRH                2. Bug 8782.
      1.2        01/03/2009   JRH                3. Bug 7959
      1.3        01/03/2009   JRH                4. Bug 9541. CRE - Incidència Cartera de Decesos
      1.4        01/03/2009   JRH                5. Bug-9569 CRE - Càlcul capital de mort amb cost de pensió
      1.5        27/03/2009   APD                6. Bug 9446 (precisiones var numericas)
      1.6        28/04/2009   JRH                7. Bug 9889 Cuadre de los datos del cierre de ABRIL
      1.7        21/05/2009   JRH                7. Bug 9540: CRE - Parametritzar sinistres de Decesos
   ******************************************************************************/
   TYPE rt_parametres IS RECORD(
      fecefe         DATE,
      fnac1          DATE,   -- Data naixement assegurat 1
      sexo1          NUMBER,   -- Sexe assegurat 1
      edad1          NUMBER,
      fnac2          DATE,   -- Data naixement assegurat 2
      sexo2          NUMBER,   -- Sexe aswegurat 2
      edad2          NUMBER,
      n              NUMBER,
      sproduc        productos.sproduc%TYPE,
      int_min        NUMBER,   -- Interès mínim (ig)
      int_garan      NUMBER,   -- Interes garantit (i1)
      int_fin        NUMBER,   -- Interès financer (ifi)
      ptipoint       NUMBER,
      gastos         NUMBER,
      tabla_morta    NUMBER,
      -- Agafat de RESP
      vt             NUMBER,   -- Valor taxació
      pxvt           NUMBER,
      gtos_notario   NUMBER,
      gtos_registro  NUMBER,
      impto_ajd      NUMBER,
      gtos_tasacion  NUMBER,
      gtos_gestoria  NUMBER,
      cap_disponible NUMBER
   );

/*************************************************************************
      -- BUG 8782 - 02/2009 - JRH  - Factor de reembolso de primas
      Nos indica el tipo de efecto.
      return             : Tipo efecto
   *************************************************************************/
   FUNCTION pctipefe(psesion IN NUMBER)
      RETURN NUMBER IS
      v_sseguro      seguros.sseguro%TYPE;

      CURSOR tipefec(vsseguro IN NUMBER) IS
         SELECT nrenova
           FROM seguros
          WHERE sseguro = vsseguro
         UNION
         SELECT nrenova
           FROM estseguros
          WHERE sseguro = vsseguro;

      valor          NUMBER := 0;
   BEGIN
      v_sseguro := pac_gfi.f_sgt_parms('SSEGURO', psesion);

      OPEN tipefec(v_sseguro);

      FETCH tipefec
       INTO valor;

      CLOSE tipefec;

      IF valor = 0 THEN
         p_tab_error(f_sysdate, f_user, 'PAC_FRM_ACTUARIAL.pctipefe', 1,
                     'No encuentra nrenova:' || v_sseguro, 'AAAA');
      END IF;

      IF NVL(valor, 0) = 101 THEN   --Es natural
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_FRM_ACTUARIAL.pctipefe', 1,
                     'Error:' || v_sseguro, SQLERRM);
   END pctipefe;

/*************************************************************************
      -- BUG 8782 - 02/2009 - JRH  - Factor de reembolso de primas
      Nos indica el si es ahorro
      return             : 1 si es ahorro 0 si no
   *************************************************************************/
   FUNCTION pesahorr(psesion IN NUMBER)
      RETURN NUMBER IS
      v_sseguro      NUMBER;

      CURSOR tipefec(vsproduc IN NUMBER) IS
         SELECT cagrpro
           FROM productos
          WHERE sproduc = vsproduc;

      /*UNION
      SELECT cagrpro
        FROM estseguros
       WHERE sseguro = vsseguro;*/
      valor          productos.cagrpro%TYPE;
   BEGIN
      v_sseguro := pac_gfi.f_sgt_parms('SPRODUC', psesion);

      OPEN tipefec(v_sseguro);

      FETCH tipefec
       INTO valor;

      CLOSE tipefec;

      IF valor = 0 THEN
         p_tab_error(f_sysdate, f_user, 'PAC_FRM_ACTUARIAL.pctipefe', 1,
                     'No encuentra nrenova:' || v_sseguro, 'AAAA');
      END IF;

      IF NVL(valor, 0) <> 10 THEN   --Es ahorro
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_FRM_ACTUARIAL.pctipefe', 1,
                     'Error:' || v_sseguro, SQLERRM);
   END pesahorr;

/*************************************************************************
      -- BUG 7959 - 03/2009 - JRH  - Decesos
      Nos indica  si es riesgo
      param in psesion: Sesión.
      return             : 1 si es riesgo 0 si no
   *************************************************************************/
   FUNCTION pesriesgo(psesion IN NUMBER)
      RETURN NUMBER IS
      v_sseguro      seguros.sseguro%TYPE;

      CURSOR tipefec(vsproduc IN NUMBER) IS
         SELECT cagrpro
           FROM productos
          WHERE sproduc = vsproduc;

      /*UNION
      SELECT cagrpro
        FROM estseguros
       WHERE sseguro = vsseguro;*/
      valor          productos.cagrpro%TYPE;
   BEGIN
      v_sseguro := pac_gfi.f_sgt_parms('SPRODUC', psesion);

      OPEN tipefec(v_sseguro);

      FETCH tipefec
       INTO valor;

      CLOSE tipefec;

      IF valor = 0 THEN
         p_tab_error(f_sysdate, f_user, 'PAC_FRM_ACTUARIAL.pctipefe', 1,
                     'No encuentra nrenova:' || v_sseguro, 'AAAA');
      END IF;

      IF NVL(valor, 0) = 1 THEN   --Es riesgo
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_FRM_ACTUARIAL.pctipefe', 1,
                     'Error:' || v_sseguro, SQLERRM);
   END pesriesgo;

   FUNCTION ff_progacumnat(
      psesion IN NUMBER,
      gg IN NUMBER,
      ig IN NUMBER,
      nduraci IN NUMBER,
      mesini IN NUMBER DEFAULT 0,
      p_es_mensual IN NUMBER DEFAULT 0,
      esahorr NUMBER DEFAULT 1)
      RETURN NUMBER IS
      valor          NUMBER := 0;
      prog           NUMBER;
      pduraci        NUMBER;
      primeravez     BOOLEAN := TRUE;
      sproduc        productos.sproduc%TYPE;
      reemb          NUMBER;
      factreemb      NUMBER;
   BEGIN
      sproduc := pac_gfi.f_sgt_parms('SPRODUC', psesion);
      reemb := NVL(vtramo(psesion, 1450, sproduc), 0);

      IF p_es_mensual <> 0 THEN
         factreemb := POWER(1 +(reemb / 100), 1 / 12);   -- BUG 8782 - 02/2009 - JRH  - Factor de reembolso de primas
         pduraci := nduraci * 12;

         FOR i IN 0 .. pduraci LOOP
            prog := ff_progresionnat(psesion, gg, ig, i / 12, mesini, p_es_mensual, esahorr);
            valor := (valor + prog) * factreemb;
         END LOOP;
      ELSE
         factreemb := POWER(1 +(reemb / 100), 1);   -- BUG 8782 - 02/2009 - JRH  - Factor de reembolso de primas
         pduraci := nduraci;

         FOR i IN 0 .. pduraci LOOP
            prog := POWER((1 + gg / 100), i) + (i) *(ig / 100);
            valor := (valor + prog) * factreemb;
         END LOOP;
      END IF;

      RETURN valor;
   END ff_progacumnat;

/*************************************************************************

      Calcula la progresion especial para productos de decesos

     param in psesion     : Sesión
     param in gg     :Reval. geométrica.
     param in ig      : Reval. lineal.
     param in nduraci      : Fecha en meses desd efecto.
     param in mesini      : mes inicio efecto
     param in p_es_mensual      : Tratamiento mensual o segun forma pago.
     param in esahorr    : Indica si es ahorro.
     return                : Progresión.

      -- BUG 7959 - 03/2009 - JRH  - Decesos
      De momento esta función la hemos de duplicar para el caso de DECESOS. (Progresión especial de la cobertura de fallecimiento).
   *************************************************************************/
   FUNCTION ff_progresionnatrisc(   --JRH La tenemos que hacer de momento porque no hay nada implementado especial para esto
      psesion IN NUMBER,
      gg IN NUMBER,
      ig IN NUMBER,
      nduraci IN NUMBER,
      mesini IN NUMBER DEFAULT 0,
      p_es_mensual IN NUMBER DEFAULT 0,
      esahorr NUMBER DEFAULT 1)
      RETURN NUMBER IS
      valor          NUMBER := 0;
      prog           NUMBER;
      prog2          NUMBER;
      pduraci        NUMBER;
      primeravez     BOOLEAN := TRUE;
      fpagprima      seguros.cforpag%TYPE;
      v_cgarant      NUMBER;   --JRH IMP Temporal
   BEGIN
      fpagprima := NVL(pac_gfi.f_sgt_parms('FPAGPRIMA', psesion), 12);

      IF fpagprima = 0 THEN
         fpagprima := 1;
      END IF;

      --dbms_output.put_line('nduraci:'||nduraci);
      IF p_es_mensual <> 0 THEN
         pduraci := ROUND(nduraci * 12, 0);

         IF MOD(pduraci,(12 / fpagprima)) <> 0 THEN
            RETURN 0;
         END IF;

         IF NVL(gg, 0) = 0
            AND NVL(ig, 0) = 0 THEN
            IF esahorr <> 1 THEN   --En rentas no incluimos el inicial
               IF pduraci = 0 THEN
                  RETURN 0;
               ELSE
                  RETURN 1;
               END IF;
            ELSE
               RETURN 1;
            END IF;
         END IF;

         primeravez := FALSE;
         prog := POWER((1 + gg / 100), FLOOR((mesini + pduraci - 1) / 12))
                 + FLOOR(((mesini + pduraci - 1) / 12)) *(ig / 100);
         prog2 := prog;

          --dbms_output.put_line('prog:'||prog);
         -- END IF;
         IF pduraci = 0 THEN
            IF esahorr <> 1 THEN   --En rentas no incluimos el inicial
               prog := 0;
            ELSE
               prog := prog2;
            END IF;
         ELSE
            prog := prog2;
         END IF;
      ELSE
         pduraci := nduraci;

         IF NVL(gg, 0) = 0
            AND NVL(ig, 0) = 0 THEN
            IF esahorr <> 1 THEN   --En rentas no incluimos el inicial
               IF pduraci = 0 THEN
                  RETURN 0;
               ELSE
                  RETURN 1;
               END IF;
            ELSE
               RETURN 1;
            END IF;
         END IF;

         v_cgarant := NVL(pac_gfi.f_sgt_parms('GARANTIA', psesion), 0);
         prog := POWER((1 + gg / 100), pduraci) + (pduraci) *(ig / 100);

         IF v_cgarant = 1
            AND NVL(resp(psesion, 608), 0) <> 0 THEN   -- BUG 7959 - 03/2009 - JRH  - Decesos: La progresión de fallecimiento es así. De momento es temporal.
            DECLARE
               vfecefe        NUMBER;
               vfnacimi       NUMBER;
               edadinipol     NUMBER;
               capital        NUMBER;
               capitjub       NUMBER;
               edadjub        NUMBER;
               vfactor        NUMBER;
               vcapsep        NUMBER;
            BEGIN
               vfecefe := pac_gfi.f_sgt_parms('FEFEPOL', psesion);
               vfnacimi := pac_gfi.f_sgt_parms('FNACIMI', psesion);
               capital := pac_gfi.f_sgt_parms('CAPITAL', psesion);
               capitjub := NVL(resp(psesion, 608), 0);
               edadjub := NVL(resp(psesion, 610), 0);

               -- BUG 9540 - 05/2009 - JRH  -  Parametritzar sinistres de Decesos
               IF NVL(resp(psesion, 609), 0) <> 0 THEN
                  vfactor := NVL(resp(psesion, 609), 0);
               ELSE
                  vfactor := 1.444444;   -- De momento, hasta que decidan poner el cap. de falllec. es como el de enterr por un factor entero en la pregunta 609NVL(resp(psesion, 609), 0);
               END IF;

               --fi BUG
               vcapsep := NVL(resp(psesion, 611), 0);
               edadinipol := ROUND(MONTHS_BETWEEN(TO_DATE(vfecefe, 'YYYYMMDD'),
                                                  TO_DATE(vfnacimi, 'YYYYMMDD'))
                                   / 12);

               IF edadinipol + pduraci > edadjub THEN
                  prog := capitjub /(vfactor * vcapsep);   --100;--Capital;
               ELSIF edadinipol + pduraci <= 18 THEN
                  prog := capitjub /(vfactor * vcapsep);   -- BUG 7959 - 03/2009 - JRH  - Decesos Llamamos a esta progresió no acumulada en el caso de riesgo.
               ELSE
                  prog := 1;
               END IF;
            END;
         END IF;
      -- END LOOP;
      END IF;

      -- dbms_output.put_line('prog3:'||prog);
      RETURN prog;
   END ff_progresionnatrisc;

   FUNCTION ff_progresionnat(
      psesion IN NUMBER,
      gg IN NUMBER,
      ig IN NUMBER,
      nduraci IN NUMBER,
      mesini IN NUMBER DEFAULT 0,
      p_es_mensual IN NUMBER DEFAULT 0,
      esahorr NUMBER DEFAULT 1)
      RETURN NUMBER IS
      valor          NUMBER := 0;
      prog           NUMBER;
      prog2          NUMBER;
      pduraci        NUMBER;
      primeravez     BOOLEAN := TRUE;
      fpagprima      NUMBER;
      v_cgarant      NUMBER;   --JRH IMP Temporal
   BEGIN
      fpagprima := NVL(pac_gfi.f_sgt_parms('FPAGPRIMA', psesion), 12);

      IF fpagprima = 0 THEN
         fpagprima := 1;
      END IF;

      --dbms_output.put_line('nduraci:'||nduraci);
      IF p_es_mensual <> 0 THEN
         pduraci := ROUND(nduraci * 12, 0);

         IF MOD(pduraci,(12 / fpagprima)) <> 0 THEN
            RETURN 0;
         END IF;

         IF NVL(gg, 0) = 0
            AND NVL(ig, 0) = 0 THEN
            IF esahorr <> 1 THEN   --En rentas no incluimos el inicial
               IF pduraci = 0 THEN
                  RETURN 0;
               ELSE
                  RETURN 1;
               END IF;
            ELSE
               RETURN 1;
            END IF;
         END IF;

         /*FOR i IN 0 .. pduraci LOOP
            IF MOD(mesini + i - 1, 12) = 0
               OR primeravez THEN
               primeravez := FALSE;
               prog := POWER((1 + gg / 100), FLOOR((mesini + i - 1) / 12))
                       + FLOOR(((mesini + i - 1) / 12)) *(ig / 100);
               prog2 := prog;
            --dbms_output.put_line('prog:'||prog);
            END IF;

            IF i = 0 THEN
              if esAhorr<>1 then --En rentas no incluimos el inicial
               prog := 0;
              else
               prog := prog2;
              end if;
            ELSE
               prog := prog2;
            END IF;
         -- dbms_output.put_line('prog2:'||prog);
         END LOOP;*/

         -- IF MOD(mesini + i - 1, 12) = 0
         --    OR primeravez THEN
         primeravez := FALSE;
         prog := POWER((1 + gg / 100), FLOOR((mesini + pduraci - 1) / 12))
                 + FLOOR(((mesini + pduraci - 1) / 12)) *(ig / 100);
         prog2 := prog;

          --dbms_output.put_line('prog:'||prog);
         -- END IF;
         IF pduraci = 0 THEN
            IF esahorr <> 1 THEN   --En rentas no incluimos el inicial
               prog := 0;
            ELSE
               prog := prog2;
            END IF;
         ELSE
            prog := prog2;
         END IF;
      ELSE
         pduraci := nduraci;

         IF NVL(gg, 0) = 0
            AND NVL(ig, 0) = 0 THEN
            IF esahorr <> 1 THEN   --En rentas no incluimos el inicial
               IF pduraci = 0 THEN
                  RETURN 0;
               ELSE
                  RETURN 1;
               END IF;
            ELSE
               RETURN 1;
            END IF;
         END IF;

         prog := POWER((1 + gg / 100), pduraci) + (pduraci) *(ig / 100);
      -- END LOOP;
      END IF;

      -- dbms_output.put_line('prog3:'||prog);
      RETURN prog;
   END ff_progresionnat;

   FUNCTION f_morta_mes(
      nsesion IN NUMBER DEFAULT 1,
      ptabla IN NUMBER,
      pedad IN NUMBER,
      psexo IN NUMBER,
      pnacim IN NUMBER)
      RETURN NUMBER IS
/*------------------------------------------------------------------------------
  CPM 30/06/2005 : F_MORTA_MES
  Funció que calcula el valor de mortalitat (LX) mensualitzat.
  Es crida des del SGT
------------------------------------------------------------------------------*/
      v_lx           NUMBER := 0;
      vedad          NUMBER := pedad;
      residuo        NUMBER := 0;
      v_lx2          NUMBER := 0;
      v_lxmen        NUMBER := 0;
   BEGIN
      vedad := TRUNC(pedad / 12);
      residuo := (pedad / 12) - vedad;

      -- CPM 1/12/06: Si l'any es mes gran de 2000 s'agafa el 2000
      BEGIN
         SELECT DECODE(psexo, 1, vmascul, 2, vfemeni)
           INTO v_lx
           FROM mortalidad
          WHERE ctabla = ptabla
            AND nedad = vedad
            AND nano_nacim = LEAST(pnacim, 2000);

         SELECT DECODE(psexo, 1, vmascul, 2, vfemeni)
           INTO v_lx2
           FROM mortalidad
          WHERE ctabla = ptabla
            AND nedad = vedad + 1
            AND nano_nacim = LEAST(pnacim, 2000);

         v_lxmen := v_lx *(1 - residuo) + v_lx2 * residuo;
      --dbms_output.put_line('vedad:'||vedad||'  ptabla:'||' pnacim:'||pnacim||' v_lx:'||v_lx||'  v_lx2:'||v_lx);
      END;

      RETURN v_lxmen;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN -1;
   END f_morta_mes;

/*************************************************************************

      Calcula la ff_axprog2

     param in psesion     : Sesión
     param in ptabla     :Tabla mortalidad
     param in sexo     :Sexo
     param in edad     :edad act.
     param in pduraci      : numero de bucles
     param in gg     :Reval. geométrica.
     param in ig      : Reval. lineal.
     param in pv : Interés
     param in mes      : mes inicio efecto

     param in p_es_mensual      : Tratamiento mensual o segun forma pago.
     param in pedadini    : Edad  al efecto.
     param in desdeinicio : Cociente desde efecto o no
     return                : ff_aprog2.

    *************************************************************************/
   FUNCTION ff_axprog2(
      psesion IN NUMBER,
      ptabla IN NUMBER,
      psexo IN NUMBER,
      pedad IN NUMBER,
      pduraci IN NUMBER,
      pv IN NUMBER,
      gg IN NUMBER,
      ig IN NUMBER,
      mes IN NUMBER,
      pedadini IN NUMBER,
      p_es_mensual IN NUMBER DEFAULT 0,
      desdeinicio IN BOOLEAN DEFAULT TRUE)
      RETURN NUMBER IS
      lx_edad        NUMBER;
      lxi            NUMBER;
      sum_a          NUMBER;
      ex             NUMBER;
      lduraci        NUMBER;
      prog           NUMBER;
      var            NUMBER;   --años de menos
      bb             NUMBER := 0;
      sumtot         NUMBER := 1500;
      factor         NUMBER;
      increm         NUMBER;
      fecefe         NUMBER;
      mesini         NUMBER;
      sproduc        NUMBER;
      pnacim         NUMBER;
      --pctipefe Number;
      lproduc        NUMBER;
      pcagrpro       NUMBER;
      inter          NUMBER;
      ndurper        NUMBER;
      intmin         NUMBER;
   BEGIN
      sum_a := 0;
      inter := pv;
      --var:=NVL(pac_gfi.f_sgt_parms ('ANYSDIF', psesion),2); --De moment el 2 és perquè el PPJ ja està fet i valia 2
      sproduc := pac_gfi.f_sgt_parms('SPRODUC', psesion);
      lproduc := sproduc;
      fecefe := pac_gfi.f_sgt_parms('FEFEPOL', psesion);
      mesini := TO_NUMBER(SUBSTR(fecefe, 5, 2));   -- Para la progresión por año natural
      pnacim := TO_CHAR(TO_DATE(NVL(pac_gfi.f_sgt_parms('FNACIMI', psesion), 0), 'YYYYMMDD'),
                        'YYYY');
      var := NVL(vtramo(psesion, 1090, sproduc), 2);   --desfasament en nys d'accés a les taules
      pcagrpro := pesahorr(psesion);

      IF p_es_mensual <> 0 THEN   --Para convertir todo lo que nos viene en años a meses
         factor := 12;
      ELSE
         factor := 1;
      END IF;

      lduraci := ROUND(pduraci * factor, 0);
      sumtot := (maxtaula -(pedad + pduraci)) * factor;

      IF desdeinicio THEN
         IF ptabla = 6 THEN
            lx_edad := f_morta_mes(psesion, ptabla, 12 *(pedadini - var), psexo, pnacim);
         ELSE
            lx_edad := ff_lx(psesion, ptabla, pedadini - var, psexo, p_es_mensual);
         END IF;
      --LX_EDAD := ff_LX(Psesion, pTABLA, pedad-var, pSEXO, p_es_mensual);
      ELSE
         IF ptabla = 6 THEN
            lx_edad := f_morta_mes(psesion, ptabla, 12 *(pedad + 0 - var), psexo,   -- 0 en lugar de pduraci
                                   pnacim);
         ELSE
            lx_edad := ff_lx(psesion, ptabla, pedad + 0 - var, psexo, p_es_mensual);
         END IF;
      END IF;

      --if lx_edad < 0 then
      --  lx_edad:=0;
      --end if;
      lxi := lx_edad;
      increm := pedad - pedadini;

      IF pctipefe(psesion) = 0 THEN
         mesini := 1;
      END IF;

      /*inter:=pv;
        ndurper := pac_gfi.f_sgt_parms ('NDURPER', psesion);
        intmin:=pac_inttec.Ff_int_producto (SPRODUC, 1, TO_DATE(fecefe,'YYYYMMDD'), NDURPER);
        */
      FOR i IN 0 .. lduraci LOOP
         /*if nvl(NDURPER ,0)>0 then
           if  (pedad-pedadIni) + i/12 >= nvl(NDURPER ,0) then
               inter:=(1 / (1 + intmin / 100));
           end if;
         end if;*/--Pendiente de validar para cambio de interés en periodo
         IF gg IS NOT NULL   -- BUG 9569 - 03/2009 - JRH  - Càlcul capital de mort amb cost de pensió.
            OR ig IS NOT NULL THEN
            prog := ff_progresionnat(psesion, gg, ig, increm + i / factor, mesini,
                                     p_es_mensual, pcagrpro);
         ELSE
            prog := 1;
         END IF;

         IF ptabla = 6 THEN
            lxi := f_morta_mes(psesion, ptabla, 12 *(pedad + 0 - var +(i / factor)), psexo,
                               pnacim);
         ELSE
            lxi := ff_lx(psesion, ptabla, pedad + 0 - var +(i / factor), psexo, p_es_mensual);
         END IF;

         IF lxi < 0 THEN
            lxi := 0;
         END IF;

         IF pcagrpro = 1 THEN
            IF prog = 0 THEN
               prog := 1;
            END IF;   --JRH IMP En rentas viene diferente la prog., el primer mes es 0.
         END IF;

         sum_a := sum_a + prog *(lxi / 1) * POWER(inter, pedad + i / factor);
      END LOOP;

      sum_a := sum_a /(lx_edad * POWER(pv, pedadini));
      ex := (lxi / lx_edad) * POWER(pv, lduraci);
      RETURN(sum_a + (1 - ex) *(mes - 1) /(mes * 2));
   END ff_axprog2;

/*************************************************************************

      Calcula la ff_axyprog2

     param in psesion     : Sesión
     param in ptabla     :Tabla mortalidad
     param in sexo     :Sexo
     param in edad     :edad act.
     param in pduraci      : numero de bucles
     param in gg     :Reval. geométrica.
     param in ig      : Reval. lineal.
     param in pv : Interés
     param in mes      : mes inicio efecto

     param in p_es_mensual      : Tratamiento mensual o segun forma pago.
     param in pedadini    : Edad  al efecto.
     param in desdeinicio : Cociente desde efecto o no
     return                : ff_aprog2.

    *************************************************************************/
   FUNCTION ff_axyprog2(
      psesion IN NUMBER,
      ptabla IN NUMBER,
      psexo IN NUMBER,
      pedad IN NUMBER,
      psexo2 IN NUMBER,
      pedad2 IN NUMBER,
      pduraci IN NUMBER,
      pv IN NUMBER,
      gg IN NUMBER,
      ig IN NUMBER,
      mes IN NUMBER,
      pedadini IN NUMBER,
      pedadini2 IN NUMBER,
      p_es_mensual IN NUMBER DEFAULT 0,
      desdeinicio IN BOOLEAN DEFAULT TRUE)
      RETURN NUMBER IS
      lx_edad        NUMBER;
      lxi            NUMBER;
      ly_edad        NUMBER;
      lyi            NUMBER;
      sum_a          NUMBER;
      ex             NUMBER;
      lduraci        NUMBER;
      prog           NUMBER;
      var            NUMBER;   --años de menos
      bb             NUMBER := 0;
      sumtot         NUMBER := 1500;
      factor         NUMBER;
      increm         NUMBER;
      fecefe         NUMBER;
      mesini         NUMBER;
      sproduc        NUMBER;
      pnacim         NUMBER;
      --pctipefe Number;
      lproduc        NUMBER;
      pcagrpro       NUMBER;
      inter          NUMBER;
      ndurper        NUMBER;
      intmin         NUMBER;
   BEGIN
      sum_a := 0;
      inter := pv;
      --var:=NVL(pac_gfi.f_sgt_parms ('ANYSDIF', psesion),2); --De moment el 2 és perquè el PPJ ja està fet i valia 2
      sproduc := pac_gfi.f_sgt_parms('SPRODUC', psesion);
      lproduc := sproduc;
      fecefe := pac_gfi.f_sgt_parms('FEFEPOL', psesion);
      mesini := TO_NUMBER(SUBSTR(fecefe, 5, 2));   -- Para la progresión por año natural
      pnacim := TO_CHAR(TO_DATE(NVL(pac_gfi.f_sgt_parms('FNACIMI', psesion), 0), 'YYYYMMDD'),
                        'YYYY');
      var := NVL(vtramo(psesion, 1090, sproduc), 2);   --desfasament en nys d'accés a les taules
      pcagrpro := pesahorr(psesion);

      IF p_es_mensual <> 0 THEN   --Para convertir todo lo que nos viene en años a meses
         factor := 12;
      ELSE
         factor := 1;
      END IF;

      lduraci := ROUND(pduraci * factor, 0);
      sumtot := (maxtaula -(pedad + pduraci)) * factor;

      IF desdeinicio THEN
         IF ptabla = 6 THEN
            lx_edad := f_morta_mes(psesion, ptabla, 12 *(pedadini - var), psexo, pnacim);
            ly_edad := f_morta_mes(psesion, ptabla, 12 *(pedadini2 - var), psexo, pnacim);
         ELSE
            lx_edad := ff_lx(psesion, ptabla, pedadini - var, psexo, p_es_mensual);
            ly_edad := ff_lx(psesion, ptabla, pedadini2 - var, psexo, p_es_mensual);
         END IF;
      --LX_EDAD := ff_LX(Psesion, pTABLA, pedad-var, pSEXO, p_es_mensual);
      ELSE
         IF ptabla = 6 THEN
            lx_edad := f_morta_mes(psesion, ptabla, 12 *(pedad + 0 - var), psexo, pnacim);
            ly_edad := f_morta_mes(psesion, ptabla, 12 *(pedad2 + 0 - var), psexo, pnacim);
         ELSE
            lx_edad := ff_lx(psesion, ptabla, pedad + 0 - var, psexo, p_es_mensual);
            ly_edad := ff_lx(psesion, ptabla, pedad2 + 0 - var, psexo, p_es_mensual);
         END IF;
      END IF;

       --if lx_edad <= 0 then
      --   lx_edad:=1;
       --end if;

      -- if ly_edad <= 0 then
      --   ly_edad:=1;
      -- end if;
      lxi := lx_edad;
      lyi := ly_edad;
      increm := pedad - pedadini;

      IF pctipefe(psesion) = 0 THEN
         mesini := 1;
      END IF;

      /*inter:=pv;
        ndurper := pac_gfi.f_sgt_parms ('NDURPER', psesion);
        intmin:=pac_inttec.Ff_int_producto (SPRODUC, 1, TO_DATE(fecefe,'YYYYMMDD'), NDURPER);
        */
      FOR i IN 0 .. lduraci LOOP
         /*if nvl(NDURPER ,0)>0 then
           if  (pedad-pedadIni) + i/12 >= nvl(NDURPER ,0) then
               inter:=(1 / (1 + intmin / 100));
           end if;
         end if;*/--Pendiente de validar para cambio de interés en periodo
         IF gg IS NOT NULL   -- BUG 9569 - 03/2009 - JRH  - Càlcul capital de mort amb cost de pensió.
            OR ig IS NOT NULL THEN
            prog := ff_progresionnat(psesion, gg, ig, increm + i / factor, mesini,
                                     p_es_mensual, pcagrpro);
         ELSE
            prog := 1;
         END IF;

         IF ptabla = 6 THEN
            lxi := f_morta_mes(psesion, ptabla, 12 *(pedad + 0 - var +(i / factor)), psexo,
                               pnacim);
            lyi := f_morta_mes(psesion, ptabla, 12 *(pedad2 + 0 - var +(i / factor)), psexo,
                               pnacim);
         ELSE
            lxi := ff_lx(psesion, ptabla, pedad + 0 - var +(i / factor), psexo, p_es_mensual);
            lyi := ff_lx(psesion, ptabla, pedad2 + 0 - var +(i / factor), psexo, p_es_mensual);
         END IF;

         IF lxi < 0 THEN
            lxi := 0;
         END IF;

         IF lyi < 0 THEN
            lyi := 0;
         END IF;

         IF pcagrpro = 1 THEN
            IF prog = 0 THEN
               prog := 1;
            END IF;   --JRH IMP En rentas viene diferente la prog., el primer mes es 0.
         END IF;

         sum_a := sum_a
                  + prog *(lxi / 1) *(lyi / 1) * POWER(inter, pedad + i / factor)
                    * POWER(inter, pedad2 + i / factor);
      END LOOP;

      sum_a := sum_a /((lx_edad * POWER(pv, pedadini)) *(ly_edad * POWER(pv, pedadini2)));
      ex := (lxi / lx_edad) * POWER(pv, lduraci);
      RETURN(sum_a + (1 - ex) *(mes - 1) /(mes * 2));
   END ff_axyprog2;

   FUNCTION ff_axyprog_cab(
      psesion IN NUMBER,
      ptabla IN NUMBER,
      psexo IN NUMBER,
      pedad IN NUMBER,
      psexo2 IN NUMBER,
      pedad2 IN NUMBER,
      pduraci IN NUMBER,
      pv IN NUMBER,
      gg IN NUMBER,
      ig IN NUMBER,
      pfracc IN NUMBER DEFAULT 12,
      pedadini IN NUMBER,
      pedadini2 IN NUMBER,
      p_es_mensual IN NUMBER DEFAULT 0,
      prever IN NUMBER DEFAULT 100,
      desdeinicio IN BOOLEAN DEFAULT TRUE)
      RETURN NUMBER IS
      vdurax         NUMBER;
      vduray         NUMBER;
      vduraxy        NUMBER;
      a_xym          NUMBER;
   BEGIN
      IF pduraci >= fin_morta THEN
         vdurax := pduraci - pedad;
         vduray := pduraci - pedad2;
      ELSE
         vdurax := pduraci;
         vduray := pduraci;
      END IF;

      IF NVL(psexo2, 0) = 0 THEN   --Una cabeza
         a_xym := ff_axprog2(psesion, ptabla, psexo, pedad, vdurax, pv, gg, ig, pfracc,
                             pedadini, p_es_mensual, desdeinicio);
         NULL;
      ELSE
         IF pduraci >= fin_morta THEN
            IF pedad > pedad2 THEN
               vduraxy := pduraci - pedad2;
            ELSE
               vduraxy := pduraci - pedad;
            END IF;
         ELSE
            vduraxy := pduraci;
         END IF;

         a_xym := ff_axprog2(psesion, ptabla, psexo, pedad, vdurax, pv, gg, ig, pfracc,
                             pedadini, p_es_mensual, desdeinicio)
                  + prever / 100
                    *(ff_axprog2(psesion, ptabla, psexo2, pedad2, vduray, pv, gg, ig, pfracc,
                                 pedadini2, p_es_mensual, desdeinicio)
                      - ff_axyprog2(psesion, ptabla, psexo, pedad, psexo2, pedad2, vduraxy, pv,
                                    gg, ig, pfracc, pedadini, pedadini2, p_es_mensual,
                                    desdeinicio));
      END IF;

      -- dbms_output.put_line('a_xym='||a_xym);
      RETURN a_xym;
   END ff_axyprog_cab;

/*************************************************************************

      Calcula la ff_aprog2

     param in psesion     : Sesión
     param in ptabla     :Tabla mortalidad
     param in sexo     :Sexo
     param in edad     :edad act.
     param in pduraci      : numero de bucles
     param in gg     :Reval. geométrica.
     param in ig      : Reval. lineal.
     param in pv : Interés
     param in mes      : mes inicio efecto

     param in p_es_mensual      : Tratamiento mensual o segun forma pago.
     param in pedadini    : Edad  al efecto.
     param in desdeinicio : Cociente desde efecto o no
     return                : ff_aprog2.

    *************************************************************************/
   FUNCTION ff_aprog2(
      psesion IN NUMBER,
      ptabla IN NUMBER,
      psexo IN NUMBER,
      pedad IN NUMBER,
      pduraci IN NUMBER,
      pv IN NUMBER,
      gg IN NUMBER,
      ig IN NUMBER,
      mes IN NUMBER,
      pedadini IN NUMBER,
      p_es_mensual IN NUMBER DEFAULT 0,
      desdeinicio IN BOOLEAN DEFAULT TRUE)
      RETURN NUMBER IS
      lx_edad        NUMBER;
      lxi            NUMBER;
      lxi1           NUMBER;
      sum_a          NUMBER;
      ex             NUMBER;
      lduraci        NUMBER;
      prog           NUMBER;
      var            NUMBER;   --años de menos
      bb             NUMBER := 0;
      sumtot         NUMBER := 1500;
      factor         NUMBER;
      increm         NUMBER;
      fecefe         NUMBER;
      mesini         NUMBER;
      sproduc        NUMBER;
      lproduc        NUMBER;
      pnacim         NUMBER;
      --pctipefe NUMBER;
      pcagrpro       NUMBER;
      inter          NUMBER;
      ndurper        NUMBER;
      intmin         NUMBER;
      vesries        NUMBER;
      -- BUG 9889 - 04/2009 - JRH  - Cuadre de los datos del cierre de ABRIL
      vreemb         NUMBER;
      vfactreemb     NUMBER;
      vedadini       NUMBER;
      vincrereemb    NUMBER;
   -- fi BUG 9889
   BEGIN
      sum_a := 0;
      inter := pv;
      --var:=NVL(pac_gfi.f_sgt_parms ('ANYSDIF', psesion),2); --De moment el 2 és perquè el PPJ ja està fet i valia 2
      sproduc := pac_gfi.f_sgt_parms('SPRODUC', psesion);
      --LXI := LX_EDAD;
      lproduc := sproduc;
      fecefe := pac_gfi.f_sgt_parms('FEFEPOL', psesion);
      mesini := TO_NUMBER(SUBSTR(fecefe, 5, 2));   -- Para la progresión por año natural
      pnacim := TO_CHAR(TO_DATE(NVL(pac_gfi.f_sgt_parms('FNACIMI', psesion), 0), 'YYYYMMDD'),
                        'YYYY');
      pcagrpro := pesahorr(psesion);
      var := NVL(vtramo(psesion, 1090, sproduc), 2);
      vesries := pesriesgo(psesion);

      IF p_es_mensual <> 0 THEN   --Para convertir todo lo que nos viene en años a meses
         factor := 12;
      ELSE
         factor := 1;
      END IF;

      increm := pedad - pedadini;
      lduraci := ROUND(pduraci * factor, 0);
      sumtot := (maxtaula -(pedad + pduraci)) * factor;

      IF desdeinicio THEN
         --LX_EDAD := ff_LX(Psesion, pTABLA, pedadIni-var, pSEXO, p_es_mensual);
         IF ptabla = 6 THEN
            lx_edad := f_morta_mes(psesion, ptabla, 12 *(pedad - var), psexo, pnacim);
         ELSE
            lx_edad := ff_lx(psesion, ptabla, pedad - var, psexo, p_es_mensual);
         END IF;
      ELSE
         IF ptabla = 6 THEN
            lx_edad := f_morta_mes(psesion, ptabla, 12 *(pedadini + 0 - var), psexo, pnacim);
         ELSE
            lx_edad := ff_lx(psesion, ptabla, pedadini + 0 - var, psexo, p_es_mensual);
         END IF;
      END IF;

      --if lx_edad <= 0 then
      --  lx_edad:=1;
      --end if;

      --LXI := LX_EDAD;

      -- BUG 9889 - 04/2009 - JRH  - Cuadre de los datos del cierre de ABRIL
      vreemb := NVL(vtramo(psesion, 1450, sproduc), 0);
      vfactreemb := POWER(1 +(vreemb / 100), 1 / factor);
      -- fi BUG 9889
      vedadini := ROUND(((TO_DATE(fecefe, 'YYYYMMDD')
                          - TO_DATE(NVL(pac_gfi.f_sgt_parms('FNACIMI', psesion), 0),
                                    'YYYYMMDD'))
                         / 365.25)
                        * 12 * 2,
                        0)
                  / 24;
      vincrereemb := ROUND(factor *(pedad - vedadini), 0);

      /*inter:=pv;
        ndurper := pac_gfi.f_sgt_parms ('NDURPER', psesion);
        intmin:=pac_inttec.Ff_int_producto (SPRODUC, 1, TO_DATE(fecefe,'YYYYMMDD'), NDURPER);
        */
      IF pctipefe(psesion) = 0 THEN
         mesini := 1;
      END IF;

      FOR i IN 0 .. lduraci LOOP
         /*if nvl(NDURPER ,0)>0 then
           if  (pedad-pedadIni) + i/12 >= nvl(NDURPER ,0) then
               inter:=(1 / (1 + intmin / 100));
           end if;
         end if;*/--Pendiente de validar para cambio de interés en periodo

         --prog := ff_progacumnat(psesion, gg, ig, increm + i / factor, mesini, p_es_mensual,
         --                          pcagrpro);
         IF gg IS NOT NULL
            OR ig IS NOT NULL THEN
            IF vesries = 1 THEN   -- BUG 7959 - 03/2009 - JRH  - Decesos Llamamos a esta progresió no acumulada en el caso de riesgo.
               prog := ff_progresionnatrisc(psesion, gg, ig, increm + i / factor, mesini,
                                            p_es_mensual, pcagrpro);
            ELSE
               prog := ff_progacumnat(psesion, gg, ig, increm + i / factor, mesini,
                                      p_es_mensual, pcagrpro);
            END IF;
         ELSE
            prog := 1 * POWER(vfactreemb, vincrereemb + i + 1);
         END IF;

         IF ptabla = 6 THEN
            lxi := f_morta_mes(psesion, ptabla, 12 *(pedad + 0 - var +(i / factor)), psexo,
                               pnacim);
         ELSE
            lxi := ff_lx(psesion, ptabla, pedad + 0 - var +(i / factor), psexo, p_es_mensual);
         END IF;

         IF ptabla = 6 THEN
            lxi1 := f_morta_mes(psesion, ptabla, 12 *(pedad + 0 - var +((i + 1) / factor)),
                                psexo, pnacim);
         ELSE
            lxi1 := ff_lx(psesion, ptabla, pedad + 0 - var +((i + 1) / factor), psexo,
                          p_es_mensual);
         END IF;

         IF lxi < 0 THEN
            lxi := 0;
         END IF;

         IF lxi1 < 0 THEN
            lxi1 := 0;
         END IF;

         IF pcagrpro = 1 THEN
            IF prog = 0 THEN
               prog := 1;
            END IF;   --JRH IMP En rentas viene diferente la prog., el primer mes es 0.
         END IF;

         sum_a := sum_a
                  + prog *((lxi - lxi1) / 1)
                    * POWER(inter,(i +(pedad * factor)) / factor - 0.5 / factor);
      END LOOP;

      --if lx_edad<=0 then
      --  lx_edad:=1;
      --end if;
      sum_a := sum_a /(lx_edad * POWER(pv, pedadini));
      ex := (lxi / lx_edad) * POWER(pv, lduraci);
      RETURN(sum_a + (1 - ex) *(mes - 1) /(mes * 2));
   END ff_aprog2;

/*************************************************************************

      Calcula la ff_a2prog2

     param in psesion     : Sesión
     param in ptabla     :Tabla mortalidad
     param in sexo     :Sexo
     param in edad     :edad act.
     param in pduraci      : numero de bucles
     param in gg     :Reval. geométrica.
     param in ig      : Reval. lineal.
     param in pv : Interés
     param in mes      : mes inicio efecto

     param in p_es_mensual      : Tratamiento mensual o segun forma pago.
     param in pedadini    : Edad  al efecto.
     param in desdeinicio : Cociente desde efecto o no
     return                : ff_a2prog2.

    *************************************************************************/
   FUNCTION ff_a2prog2(
      psesion IN NUMBER,
      ptabla IN NUMBER,
      psexo IN NUMBER,
      pedad IN NUMBER,
      psexo2 IN NUMBER,
      pedad2 IN NUMBER,
      pduraci IN NUMBER,
      pv IN NUMBER,
      gg IN NUMBER,
      ig IN NUMBER,
      mes IN NUMBER,
      pedadini IN NUMBER,
      pedadini2 IN NUMBER,
      p_es_mensual IN NUMBER DEFAULT 0,
      desdeinicio IN BOOLEAN DEFAULT TRUE)
      RETURN NUMBER IS
      lx_edad        NUMBER;
      lxi            NUMBER;
      lxi1           NUMBER;
      ly_edad        NUMBER;
      lyi            NUMBER;
      lyi1           NUMBER;
      sum_a          NUMBER;
      ex             NUMBER;
      lduraci        NUMBER;
      prog           NUMBER;
      var            NUMBER;   --años de menos
      bb             NUMBER := 0;
      sumtot         NUMBER := 1500;
      factor         NUMBER;
      increm         NUMBER;
      fecefe         NUMBER;
      mesini         NUMBER;
      sproduc        NUMBER;
      lproduc        NUMBER;
      pnacim         NUMBER;
      --pctipefe NUMBER;
      pcagrpro       NUMBER;
      inter          NUMBER;
      ndurper        NUMBER;
      intmin         NUMBER;
   BEGIN
      sum_a := 0;
      inter := pv;
      --var:=NVL(pac_gfi.f_sgt_parms ('ANYSDIF', psesion),2); --De moment el 2 és perquè el PPJ ja està fet i valia 2
      sproduc := pac_gfi.f_sgt_parms('SPRODUC', psesion);
      --LXI := LX_EDAD;
      lproduc := sproduc;
      fecefe := pac_gfi.f_sgt_parms('FEFEPOL', psesion);
      mesini := TO_NUMBER(SUBSTR(fecefe, 5, 2));   -- Para la progresión por año natural
      pnacim := TO_CHAR(TO_DATE(NVL(pac_gfi.f_sgt_parms('FNACIMI', psesion), 0), 'YYYYMMDD'),
                        'YYYY');
      pcagrpro := pesahorr(psesion);
      var := NVL(vtramo(psesion, 1090, sproduc), 2);

      IF p_es_mensual <> 0 THEN   --Para convertir todo lo que nos viene en años a meses
         factor := 12;
      ELSE
         factor := 1;
      END IF;

      increm := pedad - pedadini;
      lduraci := ROUND(pduraci * factor, 0);
      sumtot := (maxtaula -(pedad + pduraci)) * factor;

      IF desdeinicio THEN
         --LX_EDAD := ff_LX(Psesion, pTABLA, pedadIni-var, pSEXO, p_es_mensual);
         IF ptabla = 6 THEN
            lx_edad := f_morta_mes(psesion, ptabla, 12 *(pedad - var), psexo, pnacim);
            ly_edad := f_morta_mes(psesion, ptabla, 12 *(pedad2 - var), psexo, pnacim);
         ELSE
            lx_edad := ff_lx(psesion, ptabla, pedad - var, psexo, p_es_mensual);
            ly_edad := ff_lx(psesion, ptabla, pedad2 - var, psexo, p_es_mensual);
         END IF;
      ELSE
         IF ptabla = 6 THEN
            lx_edad := f_morta_mes(psesion, ptabla, 12 *(pedadini + 0 - var), psexo, pnacim);
            ly_edad := f_morta_mes(psesion, ptabla, 12 *(pedadini2 + 0 - var), psexo, pnacim);
         ELSE
            lx_edad := ff_lx(psesion, ptabla, pedadini + 0 - var, psexo, p_es_mensual);
            ly_edad := ff_lx(psesion, ptabla, pedadini2 + 0 - var, psexo, p_es_mensual);
         END IF;
      END IF;

      --if ly_edad <= 0 then
      --  ly_edad:=1;
      --end if;

      --if lx_edad <= 0 then
      --   lx_edad:=1;
      -- end if;

      --LXI := LX_EDAD;

      /*inter:=pv;
        ndurper := pac_gfi.f_sgt_parms ('NDURPER', psesion);
        intmin:=pac_inttec.Ff_int_producto (SPRODUC, 1, TO_DATE(fecefe,'YYYYMMDD'), NDURPER);
        */
      IF pctipefe(psesion) = 0 THEN
         mesini := 1;
      END IF;

      FOR i IN 0 .. lduraci LOOP
         /*if nvl(NDURPER ,0)>0 then
           if  (pedad-pedadIni) + i/12 >= nvl(NDURPER ,0) then
               inter:=(1 / (1 + intmin / 100));
           end if;
         end if;*/--Pendiente de validar para cambio de interés en periodo
         --prog := ff_progacumnat(psesion, gg, ig, increm + i / factor, mesini, p_es_mensual,
         --                          pcagrpro);
         IF gg IS NOT NULL
            OR ig IS NOT NULL THEN
            prog := ff_progacumnat(psesion, gg, ig, increm + i / factor, mesini, p_es_mensual,
                                   pcagrpro);
         ELSE
            prog := 1;
         END IF;

         IF ptabla = 6 THEN
            lxi := f_morta_mes(psesion, ptabla, 12 *(pedad + 0 - var +(i / factor)), psexo,
                               pnacim);
            lyi := f_morta_mes(psesion, ptabla, 12 *(pedad2 + 0 - var +(i / factor)), psexo,
                               pnacim);
         ELSE
            lxi := ff_lx(psesion, ptabla, pedad + 0 - var +(i / factor), psexo, p_es_mensual);
            lyi := ff_lx(psesion, ptabla, pedad2 + 0 - var +(i / factor), psexo, p_es_mensual);
         END IF;

         IF ptabla = 6 THEN
            lxi1 := f_morta_mes(psesion, ptabla, 12 *(pedad + 0 - var +((i + 1) / factor)),
                                psexo, pnacim);
            lyi1 := f_morta_mes(psesion, ptabla, 12 *(pedad2 + 0 - var +((i + 1) / factor)),
                                psexo, pnacim);
         ELSE
            lxi1 := ff_lx(psesion, ptabla, pedad + 0 - var +((i + 1) / factor), psexo,
                          p_es_mensual);
            lyi1 := ff_lx(psesion, ptabla, pedad2 + 0 - var +((i + 1) / factor), psexo,
                          p_es_mensual);
         END IF;

         IF lxi < 0 THEN
            lxi := 0;
         END IF;

         IF lxi1 < 0 THEN
            lxi1 := 0;
         END IF;

         IF lyi < 0 THEN
            lyi := 0;
         END IF;

         IF lyi1 < 0 THEN
            lyi1 := 0;
         END IF;

         IF pcagrpro = 1 THEN
            IF prog = 0 THEN
               prog := 1;
            END IF;   --JRH IMP En rentas viene diferente la prog., el primer mes es 0.
         END IF;

         sum_a := sum_a
                  + prog *((lxi - lxi1) / 1) *((lyi - lyi1) / 1)
                    * POWER(inter,(i +(pedad * factor)) / factor - 0.5 / factor)
                    * POWER(inter,(i +(pedad2 * factor)) / factor - 0.5 / factor);
      END LOOP;

      sum_a := sum_a /(lx_edad * POWER(pv, pedadini) * ly_edad * POWER(pv, pedadini2));
      ex := (lxi / lx_edad) * POWER(pv, lduraci);
      RETURN(sum_a + (1 - ex) *(mes - 1) /(mes * 2));
   END ff_a2prog2;

   FUNCTION ff_a2prog_cab(
      psesion IN NUMBER,
      ptabla IN NUMBER,
      psexo IN NUMBER,
      pedad IN NUMBER,
      psexo2 IN NUMBER,
      pedad2 IN NUMBER,
      pduraci IN NUMBER,
      pv IN NUMBER,
      gg IN NUMBER,
      ig IN NUMBER,
      pfracc IN NUMBER DEFAULT 12,
      pedadini IN NUMBER,
      pedadini2 IN NUMBER,
      p_es_mensual IN NUMBER DEFAULT 0,
      prever IN NUMBER DEFAULT 100,
      desdeinicio IN BOOLEAN DEFAULT TRUE)
      RETURN NUMBER IS
      vdurax         NUMBER;
      vduray         NUMBER;
      vduraxy        NUMBER;
      a_xym          NUMBER;
   BEGIN
      IF pduraci >= fin_morta THEN
         vdurax := pduraci - pedad;
         vduray := pduraci - pedad2;
      ELSE
         vdurax := pduraci;
         vduray := pduraci;
      END IF;

      IF NVL(psexo2, 0) = 0 THEN   --Una cabeza
         a_xym := ff_aprog2(psesion, ptabla, psexo, pedad, vdurax, pv, gg, ig, pfracc,
                            pedadini, p_es_mensual, desdeinicio);
         NULL;
      ELSE
         IF pduraci >= fin_morta THEN
            IF pedad > pedad2 THEN
               vduraxy := pduraci - pedad2;
            ELSE
               vduraxy := pduraci - pedad;
            END IF;
         ELSE
            vduraxy := pduraci;
         END IF;

         a_xym := ff_aprog2(psesion, ptabla, psexo, pedad, vdurax, pv, gg, ig, pfracc,
                            pedadini, p_es_mensual, desdeinicio)
                  + prever / 100
                    *(ff_aprog2(psesion, ptabla, psexo2, pedad2, vduray, pv, gg, ig, pfracc,
                                pedadini2, p_es_mensual, desdeinicio)
                      - ff_a2prog2(psesion, ptabla, psexo, pedad, psexo2, pedad2, vduraxy, pv,
                                   gg, ig, pfracc, pedadini, pedadini2, p_es_mensual,
                                   desdeinicio));
      END IF;

      -- dbms_output.put_line('a_xym='||a_xym);
      RETURN a_xym;
   END ff_a2prog_cab;

   -- Funció privada per carregar els paràmetres utilitzats a la majoria de funcions
   FUNCTION carregarparametres(psesion IN NUMBER, ptablamorta IN NUMBER)
      RETURN rt_parametres IS
      v              rt_parametres;
   BEGIN
      v.tabla_morta := ptablamorta;
      -- NOTA : Intencionadament, els dades del segon cap, si només n'hi ha un han de quedar a NULL
      -- Sgt Params
      v.fecefe := TO_DATE(pac_gfi.f_sgt_parms('FECEFE', psesion), 'YYYYMMDD');
      v.fnac1 := TO_DATE(pac_gfi.f_sgt_parms('FNACIMI', psesion), 'YYYYMMDD');
      v.fnac2 := TO_DATE(pac_gfi.f_sgt_parms('FNAC_ASE2', psesion), 'YYYYMMDD');
      v.sexo1 := pac_gfi.f_sgt_parms('SEXO', psesion);
      v.sexo2 := pac_gfi.f_sgt_parms('SEXO_ASE2', psesion);
      v.ptipoint := pac_gfi.f_sgt_parms('PTIPOINT', psesion);
      v.sproduc := pac_gfi.f_sgt_parms('SPRODUC', psesion);
      v.gastos := pac_gfi.f_sgt_parms('GASTOS', psesion) / 100;
      -- RESP
      v.n := resp(psesion, 105);   -- Busca periodo "N" de la operacion
      v.vt := resp(psesion, 100);   -- Valor taxació
      v.pxvt := resp(psesion, 101) / 100;   -- % valor taxació
      v.gtos_notario := resp(psesion, 107);
      v.gtos_registro := resp(psesion, 108);
      v.impto_ajd := resp(psesion, 109);
      v.gtos_tasacion := resp(psesion, 110);
      v.gtos_gestoria := resp(psesion, 112);
      v.cap_disponible := resp(psesion, 102);
      -- Calculats
      v.int_garan := 1 /(1 + v.ptipoint / 100);
      v.int_min := 1 /(1 + (pac_inttec.ff_int_producto(v.sproduc, 1, v.fecefe, v.n)) / 100);
      v.int_fin := pac_inttec.ff_int_producto(v.sproduc, 9, v.fecefe, v.n) / 100;
      v.edad1 := fedad(psesion, TO_CHAR(v.fnac1, 'YYYYMMDD'), TO_CHAR(v.fecefe, 'YYYYMMDD'),
                       2);

      --IF v.FNAC2 IS NOT NULL THEN
      IF v.sexo2 <> 0 THEN
         v.edad2 := fedad(psesion, TO_CHAR(v.fnac2, 'YYYYMMDD'),
                          TO_CHAR(v.fecefe, 'YYYYMMDD'), 2);
      END IF;

/*
    -- dbms_output.PUT_LINE('CarregarParametres');
    -- dbms_output.PUT_LINE('------------------');
    -- dbms_output.PUT_LINE('v.FECEFE='||v.FECEFE);
    -- dbms_output.PUT_LINE('v.FNAC1='||v.FNAC1);
    -- dbms_output.PUT_LINE('v.SEXO1='||v.SEXO1);
    -- dbms_output.PUT_LINE('v.EDAD1='||v.EDAD1);
    -- dbms_output.PUT_LINE('v.FNAC2='||v.FNAC2);
    -- dbms_output.PUT_LINE('v.SEXO2='||v.SEXO2);
    -- dbms_output.PUT_LINE('v.EDAD2='||v.EDAD2);
    -- dbms_output.PUT_LINE('v.PTIPOINT='||v.PTIPOINT);
    -- dbms_output.PUT_LINE('INTTEC='||pac_inttec.Ff_int_producto (v.SPRODUC, 1, v.FECEFE, v.N));
    -- dbms_output.PUT_LINE('v.SPRODUC='||v.SPRODUC);
    -- dbms_output.PUT_LINE('v.GASTOS='||v.GASTOS);
    -- dbms_output.PUT_LINE('v.N='||v.N);
    -- dbms_output.PUT_LINE('v.VT='||v.VT);
    -- dbms_output.PUT_LINE('v.PXVT='||v.PXVT);
    -- dbms_output.PUT_LINE('v.GTOS_NOTARIO='||v.GTOS_NOTARIO);
    -- dbms_output.PUT_LINE('v.GTOS_REGISTRO='||v.GTOS_REGISTRO);
    -- dbms_output.PUT_LINE('v.IMPTO_AJD='||v.IMPTO_AJD);
    -- dbms_output.PUT_LINE('v.GTOS_TASACION='||v.GTOS_TASACION);
    -- dbms_output.PUT_LINE('v.GTOS_GESTORIA='||v.GTOS_GESTORIA);
    -- dbms_output.PUT_LINE('v.CAP_DISPONIBLE='||v.CAP_DISPONIBLE);
    -- dbms_output.PUT_LINE('v.INT_MIN='||v.INT_MIN);
    -- dbms_output.PUT_LINE('v.INT_GARAN='||v.INT_GARAN);
    -- dbms_output.PUT_LINE('------------------');
*/
      RETURN v;
   END carregarparametres;

   FUNCTION ff_lx(
      psesion IN NUMBER,
      ptabla IN NUMBER,
      pedad IN NUMBER,
      psexo IN NUMBER,
      p_es_mensual IN NUMBER)
      RETURN NUMBER IS
      retorno        NUMBER := 0;
      v_lx           NUMBER := 0;
      vedad          NUMBER := pedad;
      residuo        NUMBER := 0;
      v_lx2          NUMBER := 0;
      nuevapedad     NUMBER;   --puede ser <0 porque se le reste alguna correción
   BEGIN
      -- Si volem LX mensualitzada tindrem p_es_mensual = 1
      IF pedad < 0 THEN
         nuevapedad := 0;
         vedad := 0;
      ELSE
         nuevapedad := pedad;
         vedad := pedad;
      END IF;

      IF p_es_mensual = 1 THEN
         vedad := TRUNC(nuevapedad);
         residuo := nuevapedad - vedad;
         v_lx := ff_mortalidad(psesion, ptabla, vedad, psexo, NULL, NULL, 'LX');
         v_lx2 := ff_mortalidad(psesion, ptabla, vedad + 1, psexo, NULL, NULL, 'LX');
         retorno := v_lx *(1 - residuo) + v_lx2 * residuo;
      --  -- dbms_output.put_line('lx mensualizada (edad '||pedad||')='||retorno);
      ELSE
         retorno := ff_mortalidad(psesion, ptabla, nuevapedad, psexo, NULL, NULL, 'LX');
      END IF;

      RETURN retorno;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN -1;
   END ff_lx;

   FUNCTION ff_a(
      psesion IN NUMBER,
      ptabla IN NUMBER,
      psexo IN NUMBER,
      pedad IN NUMBER,
      pduraci IN NUMBER,
      pv IN NUMBER,
      mes IN NUMBER,
      p_es_mensual IN NUMBER DEFAULT 0)
      RETURN NUMBER IS
      lx_edad        NUMBER;
      lxi            NUMBER;
      lxi1           NUMBER;
      sum_ax         NUMBER;
   BEGIN
      sum_ax := 0;
      -- dbms_output.put_line('pTABLA='||pTABLA||'pEDAD'||pEDAD||'pSEXO'||pSEXO);
      lx_edad := ff_lx(psesion, ptabla, pedad, psexo, p_es_mensual);

      -- dbms_output.put_line('LX_EDAD='||LX_EDAD);
      FOR i IN 0 .. pduraci LOOP
         lxi := ff_lx(psesion, ptabla, pedad + i, psexo, p_es_mensual);
         lxi1 := ff_lx(psesion, ptabla, pedad + i + 1, psexo, p_es_mensual);
         sum_ax := sum_ax + ((lxi - lxi1) / lx_edad) * POWER(pv, i + 0.5);
--      SUM_AX := SUM_AX + (LXI-LXI1) * POWER(pv, i+0.5);
--    -- dbms_output.put_line('SUM_AX'||i||'='||SUM_AX);
      END LOOP;

      RETURN sum_ax;
   END ff_a;

   FUNCTION ff_a2(
      psesion IN NUMBER,
      ptabla IN NUMBER,
      psexo IN NUMBER,
      pedad IN NUMBER,
      psexo2 IN NUMBER,
      pedad2 IN NUMBER,
      pduraci IN NUMBER,
      pv IN NUMBER,
      mes IN NUMBER,
      p_es_mensual IN NUMBER DEFAULT 0)
      RETURN NUMBER IS
      lx_edad        NUMBER;
      lxi            NUMBER;
      lxi1           NUMBER;
      ly_edad        NUMBER;
      lyi            NUMBER;
      lyi1           NUMBER;
      sum_a2         NUMBER;
   BEGIN
      sum_a2 := 0;
--    -- dbms_output.put_line('pTABLA='||pTABLA||'pEDAD'||pEDAD||'pSEXO'||pSEXO);
      lx_edad := ff_lx(psesion, ptabla, pedad, psexo, p_es_mensual);
      ly_edad := ff_lx(psesion, ptabla, pedad2, psexo2, p_es_mensual);

--    -- dbms_output.put_line('LX_EDAD='||LX_EDAD);
      FOR i IN 0 .. pduraci LOOP
         lxi := ff_lx(psesion, ptabla, pedad + i, psexo, p_es_mensual);
         lxi1 := ff_lx(psesion, ptabla, pedad + i + 1, psexo, p_es_mensual);
         lyi := ff_lx(psesion, ptabla, pedad2 + i, psexo2, p_es_mensual);
         lyi1 := ff_lx(psesion, ptabla, pedad2 + i + 1, psexo2, p_es_mensual);
         sum_a2 := sum_a2
                   + ((lxi * lyi - lxi1 * lyi1) /(lx_edad * ly_edad)) * POWER(pv, i + 0.5);
--    -- dbms_output.put_line('SUM_A2'||i||'='||SUM_A2);
      END LOOP;

      RETURN sum_a2;
   END ff_a2;

   FUNCTION ff_a_cab(
      psesion IN NUMBER,
      ptabla IN NUMBER,
      psexo IN NUMBER,
      pedad IN NUMBER,
      psexo2 IN NUMBER,
      pedad2 IN NUMBER,
      pduraci IN NUMBER,
      pv IN NUMBER,
      mes IN NUMBER,
      p_es_mensual IN NUMBER DEFAULT 0)
      RETURN NUMBER IS
      vdurax         NUMBER;
      vduray         NUMBER;
      vduraxy        NUMBER;
      axy            NUMBER;
   BEGIN
      IF pduraci >= fin_morta THEN
         vdurax := pduraci - pedad - 1;
         vduray := pduraci - pedad2 - 1;
      ELSE
         vdurax := pduraci - 1;
         vduray := pduraci - 1;
      END IF;

      IF NVL(psexo2, 0) = 0 THEN   --Una cabeza
         axy := ff_a(psesion, ptabla, psexo, pedad, vdurax, pv, mes, p_es_mensual);
      ELSE
         IF pduraci >= fin_morta THEN
            IF pedad > pedad2 THEN
               vduraxy := pduraci - pedad2 - 1;
            ELSE
               vduraxy := pduraci - pedad - 1;
            END IF;
         ELSE
            vduraxy := pduraci - 1;
         END IF;

         axy := ff_a(psesion, ptabla, psexo, pedad, vdurax, pv, mes, p_es_mensual)
                + ff_a(psesion, ptabla, psexo2, pedad2, vduray, pv, mes, p_es_mensual)
                - ff_a2(psesion, ptabla, psexo, pedad, psexo2, pedad2, vduraxy, pv, mes,
                        p_es_mensual);
      END IF;

      -- dbms_output.put_line('Axy='||Axy);
      RETURN axy;
   END ff_a_cab;

   FUNCTION ff_ax(
      psesion IN NUMBER,
      ptabla IN NUMBER,
      psexo IN NUMBER,
      pedad IN NUMBER,
      pduraci IN NUMBER,
      pv IN NUMBER,
      mes IN NUMBER,
      p_es_mensual IN NUMBER DEFAULT 0)
      RETURN NUMBER IS
      lx_edad        NUMBER;
      lxi            NUMBER;
      sum_a          NUMBER;
      ex             NUMBER;
   BEGIN
      sum_a := 0;
--    LX_EDAD := ff_mortalidad(Psesion, pTABLA, pEDAD, pSEXO, null, null, 'LX');
      lx_edad := ff_lx(psesion, ptabla, pedad, psexo, p_es_mensual);
---- dbms_output.put_line('-LX_EDAD='||LX_EDAD||'  pduraci='||pduraci);
      lxi := lx_edad;

      FOR i IN 1 .. pduraci LOOP
      --LXI := ff_mortalidad(Psesion, pTABLA, pEDAD+i, pSEXO, null, null, 'LX');
---- dbms_output.put_line(Psesion||':'|| pTABLA||':'|| pEDAD||':'||i||':'|| pSEXO||':'|| p_es_mensual);
         lxi := ff_lx(psesion, ptabla, pedad + i, psexo, p_es_mensual);
---- dbms_output.put_line('1=>'||SUM_a||':'||(LXI/LX_EDAD)||':'||POWER(pv,i));
         sum_a := sum_a + (lxi / lx_edad) * POWER(pv, i);
---- dbms_output.put_line('2=>');
--    -- dbms_output.put_line('ax-lx'||i||'='||LXI/LX_EDAD);
--    -- dbms_output.put_line('ax-v'||i||'='||POWER(pv,i));
--    -- dbms_output.put_line('ax'||i||'='||(LXI/LX_EDAD)*POWER(pv,i));
--    -- dbms_output.put_line('SUM_a'||i||'='||SUM_a);
      END LOOP;

      -- dbms_output.put_line('SUM_a='||SUM_a);
      ex := (lxi / lx_edad) * POWER(pv, pduraci);
      -- dbms_output.put_line('Ex='||Ex ||'  Q='||((1-Ex)*(mes-1)/(mes*2)));
      RETURN(sum_a + (1 - ex) *(mes - 1) /(mes * 2));
   END ff_ax;

   FUNCTION ff_axy(
      psesion IN NUMBER,
      ptabla IN NUMBER,
      psexo IN NUMBER,
      pedad IN NUMBER,
      psexo2 IN NUMBER,
      pedad2 IN NUMBER,
      pduraci IN NUMBER,
      pv IN NUMBER,
      mes IN NUMBER,
      p_es_mensual IN NUMBER DEFAULT 0)
      RETURN NUMBER IS
      lx_edad        NUMBER;
      ly_edad        NUMBER;
      lxi            NUMBER;
      lyi            NUMBER;
      sum_axy        NUMBER;
      exy            NUMBER;
   BEGIN
      sum_axy := 0;
      --LX_EDAD := ff_mortalidad(Psesion, pTABLA, pEDAD, pSEXO, null, null, 'LX');
      lx_edad := ff_lx(psesion, ptabla, pedad, psexo, p_es_mensual);
      --LY_EDAD := ff_mortalidad(Psesion, pTABLA, pEDAD2, pSEXO2, null, null, 'LX');
      ly_edad := ff_lx(psesion, ptabla, pedad2, psexo2, p_es_mensual);
      lxi := lx_edad;
      lyi := ly_edad;

      FOR i IN 1 .. pduraci LOOP
         --LXI := ff_mortalidad(Psesion, pTABLA, pEDAD+i, pSEXO, null, null, 'LX');
         lxi := ff_lx(psesion, ptabla, pedad + i, psexo, p_es_mensual);
         --LYI := ff_mortalidad(Psesion, pTABLA, pEDAD2+i, pSEXO2, null, null, 'LX');
         lyi := ff_lx(psesion, ptabla, pedad2 + i, psexo2, p_es_mensual);
--    -- dbms_output.put_line('axy'||i||'='||(LXI/LX_EDAD)*(LYI/LY_EDAD)*POWER(pv,i));
         sum_axy := sum_axy + (lxi / lx_edad) *(lyi / ly_edad) * POWER(pv, i);
      END LOOP;

      -- dbms_output.put_line('SUM_axy='||SUM_axy);
      exy := (lxi / lx_edad) *(lyi / ly_edad) * POWER(pv, pduraci);
      -- dbms_output.put_line('Exy='||Exy ||'  Q='||((1-Exy)*(mes-1)/(mes*2)));
      RETURN(sum_axy + (1 - exy) *(mes - 1) /(mes * 2));
   END ff_axy;

   FUNCTION ff_axy_cab(
      psesion IN NUMBER,
      ptabla IN NUMBER,
      psexo IN NUMBER,
      pedad IN NUMBER,
      psexo2 IN NUMBER,
      pedad2 IN NUMBER,
      pduraci IN NUMBER,
      pv IN NUMBER,
      pfracc IN NUMBER DEFAULT 12,
      p_es_mensual IN NUMBER DEFAULT 0,
      prever IN NUMBER DEFAULT 100)
      RETURN NUMBER IS
      vdurax         NUMBER;
      vduray         NUMBER;
      vduraxy        NUMBER;
      a_xym          NUMBER;
   BEGIN
      IF pduraci >= fin_morta THEN
         vdurax := pduraci - pedad;
         vduray := pduraci - pedad2;
      ELSE
         vdurax := pduraci;
         vduray := pduraci;
      END IF;

      IF NVL(psexo2, 0) = 0 THEN   --Una cabeza
         a_xym := ff_ax(psesion, ptabla, psexo, pedad, vdurax, pv, pfracc, p_es_mensual);
      ELSE
         IF pduraci >= fin_morta THEN
            IF pedad > pedad2 THEN
               vduraxy := pduraci - pedad2;
            ELSE
               vduraxy := pduraci - pedad;
            END IF;
         ELSE
            vduraxy := pduraci;
         END IF;

         a_xym := ff_ax(psesion, ptabla, psexo, pedad, vdurax, pv, pfracc, p_es_mensual)
                  + prever / 100
                    *(ff_ax(psesion, ptabla, psexo2, pedad2, vduray, pv, pfracc, p_es_mensual)
                      - ff_axy(psesion, ptabla, psexo, pedad, psexo2, pedad2, vduraxy, pv,
                               pfracc, p_es_mensual));
      END IF;

      -- dbms_output.put_line('a_xym='||a_xym);
      RETURN a_xym;
   END ff_axy_cab;

   FUNCTION ff_axy_rever(
      psesion IN NUMBER,
      ptabla IN NUMBER,
      psexo IN NUMBER,
      pedad IN NUMBER,
      psexo2 IN NUMBER,
      pedad2 IN NUMBER,
      pduraci IN NUMBER,
      pv IN NUMBER,
      pvmin IN NUMBER,
      prever IN NUMBER,
      preval IN NUMBER DEFAULT 0,
      pfracc IN NUMBER DEFAULT 12,
      p_es_mensual IN NUMBER DEFAULT 0)
      RETURN NUMBER IS
/* Se calcula el factor axy pero con un factor de reversión y con un porcentaje de revalorizacion
   Si pfracc = 1, no le aplicamos factor Q
   */
      vdurax         NUMBER;
      vduray         NUMBER;
      vduraxy        NUMBER;
      a_xym          NUMBER;
      ax             NUMBER;
      ay             NUMBER;
      axy            NUMBER;
   BEGIN
      IF pduraci >= fin_morta THEN
         vdurax := pduraci - pedad;
         vduray := pduraci - pedad2;
      ELSE
         vdurax := pduraci;
         vduray := pduraci;
      END IF;

/* En la hoja excel:
SI(REVAL=0;ax+11/24+REVER*CONY*(ay-axy);
        11/24*((ax*(1+REVAL)+1)+REVER*CONY*((ay*(1+REVAL)+1)-(axy*(1+REVAL)+1)))+13/24*(ax+REVER*CONY*(ay-axy))
  )*1,02*12
En nuestra implementación:
        11/24+11/24*(1+REVAL)*(ax+REVER*CONY*(ay-axy))
        +13/24*(ax+REVER*CONY*(ay-axy))
*/
      ax := ff_ax(psesion, ptabla, psexo, pedad, vdurax, pv, 1, p_es_mensual);

      IF NVL(psexo2, 0) = 0 THEN   --Una cabeza
         a_xym := (pfracc - 1) /(pfracc * 2)
                  + ((pfracc - 1) /(pfracc * 2)) *(1 - preval / 100) * ax
                  + ((pfracc + 1) /(pfracc * 2)) * ax;
      -- dbms_output.put_line('pfracc='||pfracc||' ax='||ax||' preval='||preval);
      ELSE
         IF pduraci >= fin_morta THEN
            IF pedad > pedad2 THEN
               vduraxy := pduraci - pedad2;
            ELSE
               vduraxy := pduraci - pedad;
            END IF;
         ELSE
            vduraxy := pduraci;
         END IF;

         ay := ff_ax(psesion, ptabla, psexo2, pedad2, vduray, pv, 1, p_es_mensual);
         axy := ff_axy(psesion, ptabla, psexo, pedad, psexo2, pedad2, vduraxy, pv, 1,
                       p_es_mensual);
         a_xym := (pfracc - 1) /(pfracc * 2)
                  + ((pfracc - 1) /(pfracc * 2)) *(1 - preval / 100)
                    *(ax + prever / 100 *(ay - axy))
                  + ((pfracc + 1) /(pfracc * 2)) *(ax + prever / 100 *(ay - axy));
      END IF;

      -- dbms_output.put_line('a_xym_rever='||a_xym||' resul='||(a_xym*12*1/pvmin)||' int='||1/pvmin);
      RETURN a_xym * 12 * 1 / pvmin;
   END ff_axy_rever;

   FUNCTION ff_ex(
      psesion IN NUMBER,
      ptabla IN NUMBER,
      psexo IN NUMBER,
      pedad IN NUMBER,
      pduraci IN NUMBER,
      pv IN NUMBER,
      pfrac NUMBER DEFAULT 12,
      p_es_mensual IN NUMBER DEFAULT 0)
      RETURN NUMBER IS
      lx_edad        NUMBER;
      lxi            NUMBER;
      sum_a          NUMBER;
      ex             NUMBER;
      var            NUMBER;
      sproduc        NUMBER;
   BEGIN
      sum_a := 0;
      sproduc := pac_gfi.f_sgt_parms('SPRODUC', psesion);
      var := NVL(vtramo(psesion, 1090, sproduc), 2);
      --LX_EDAD := ff_mortalidad(Psesion, pTABLA, pEDAD, pSEXO, null, null, 'LX');

      --dbms_output.put_line('var:'||var);
      lx_edad := ff_lx(psesion, ptabla, pedad - var, psexo, p_es_mensual);

      --dbms_output.put_line('EXLX_EDAD:'||LX_EDAD);
      IF lx_edad <= 0 THEN
         lx_edad := 1;
      END IF;

      -- LXI := ff_mortalidad(Psesion, pTABLA, pEDAD+pduraci, pSEXO, null, null, 'LX');
      lxi := ff_lx(psesion, ptabla, pedad - var + pduraci, psexo, p_es_mensual);
      --dbms_output.put_line('EXLXI:'||LXI);
      ex := (lxi / lx_edad) * POWER(pv, pduraci);
      -- dbms_output.put_line('!!!!!!Ex='||Ex);
      RETURN ex;
   END ff_ex;

   FUNCTION ff_factorprovi(
      psesion IN NUMBER,
      ptabla IN NUMBER,
      psexo IN NUMBER,
      pedad IN NUMBER,
      psexo2 IN NUMBER,
      pedad2 IN NUMBER,
      pduraci IN NUMBER,
      pv IN NUMBER,
      pro IN NUMBER,
      preserva IN NUMBER,
      pgastos IN NUMBER,
      mes IN NUMBER,
      p_es_mensual IN NUMBER DEFAULT 0)
      RETURN NUMBER IS
      axy            NUMBER;
      a_xym          NUMBER;
      retorno        NUMBER;
   BEGIN
      axy := ff_a_cab(psesion, ptabla, psexo, pedad, psexo2, pedad2, pduraci, pv, mes,
                      p_es_mensual);
      a_xym := ff_axy_cab(psesion, ptabla, psexo, pedad, psexo2, pedad2, pduraci, pv, mes,
                          p_es_mensual);
      -- dbms_output.put_line('Axy='||Axy||' a_xym='||a_xym);
      retorno := pro *(1 + pgastos) * a_xym + preserva * axy;
      -- dbms_output.put_line('factorprovi='||retorno);
      RETURN retorno;
   END ff_factorprovi;

   FUNCTION ff_factorgaran(
      psesion IN NUMBER,
      ptabla IN NUMBER,
      psexo IN NUMBER,
      pedad IN NUMBER,
      psexo2 IN NUMBER,
      pedad2 IN NUMBER,
      pduraci IN NUMBER,
      pv IN NUMBER,
      pro IN NUMBER,
      preserva IN NUMBER,
      pgastos IN NUMBER,
      pv_e IN NUMBER,
      nitera IN NUMBER,
      mes IN NUMBER,
      p_es_mensual IN NUMBER DEFAULT 0)
      RETURN NUMBER IS
      nvx            NUMBER;
      nvy            NUMBER;
      nvxy           NUMBER;
      lx_edad        NUMBER;
      lxi            NUMBER;
      ly_edad        NUMBER;
      lyi            NUMBER;
      resul          NUMBER;
   BEGIN
      -- Provision si viven los dos (o solo tenemos una cabeza)
      nvxy := ff_factorprovi(psesion, ptabla, psexo, pedad + pduraci, psexo2,
                             pedad2 + pduraci, fin_morta, pv, pro, preserva, pgastos, mes,
                             p_es_mensual);
      -- dbms_output.put_line('nVxy='||nVxy);
      -- dbms_output.put_line('  edad lx_edad='||(pEDAD+nitera));
      lx_edad := ff_lx(psesion, ptabla, pedad + nitera, psexo, p_es_mensual);
      -- dbms_output.put_line('  edad lxi='||(pEDAD+pduraci));
      lxi := ff_lx(psesion, ptabla, pedad + pduraci, psexo, p_es_mensual);

      -- dbms_output.put_line('  lxi='||lxi ||'  lx_edad='||lx_edad);
      IF NVL(psexo2, 0) = 0 THEN   --Una cabeza
         -- dbms_output.put_line('Ex='||((LXI/LX_EDAD)*POWER(pv,pduraci-nitera)));
         -- dbms_output.put_line('nitera='||nitera||' power='||POWER(pv,pduraci-nitera));
         resul := nvxy *(lxi / lx_edad) * POWER(pv_e, pduraci - nitera);
      ELSE
         -- Provision si vive solo x
         nvx := ff_factorprovi(psesion, ptabla, psexo, pedad + pduraci, 0, 0, fin_morta, pv,
                               pro, preserva, pgastos, mes, p_es_mensual);
         -- Provision si vive solo y
         nvy := ff_factorprovi(psesion, ptabla, psexo2, pedad2 + pduraci, 0, 0, fin_morta, pv,
                               pro, preserva, pgastos, mes, p_es_mensual);
         ly_edad := ff_lx(psesion, ptabla, pedad2 + nitera, psexo2, p_es_mensual);
         lyi := ff_lx(psesion, ptabla, pedad2 + pduraci, psexo2, p_es_mensual);
         -- dbms_output.put_line('factor NVxy='||nVxy||' nVx='||nVx||' nVy='||nVy);
         -- dbms_output.put_line('factor LXI='||LXI||' LYI='||LYI||' LY_EDAD='||LY_EDAD);
         resul := nvxy *(lxi * lyi /(lx_edad * ly_edad)) * POWER(pv_e, pduraci - nitera)
                  + nvx *(lxi *(ly_edad - lyi) /(lx_edad * ly_edad))
                    * POWER(pv_e, pduraci - nitera)
                  + nvy *(lyi *(lx_edad - lxi) /(lx_edad * ly_edad))
                    * POWER(pv_e, pduraci - nitera);
      END IF;

      -- dbms_output.put_line('factorgaran='||resul);
      RETURN resul;
   END ff_factorgaran;

   FUNCTION ff_exy(
      psesion IN NUMBER,
      ptabla IN NUMBER,
      psexo IN NUMBER,
      pedad IN NUMBER,
      psexo2 IN NUMBER,
      pedad2 IN NUMBER,
      pduraci IN NUMBER,
      pv IN NUMBER,
      pfrac NUMBER DEFAULT 12,
      p_es_mensual IN NUMBER DEFAULT 0)
      RETURN NUMBER IS
      lx_edad        NUMBER;
      lxi            NUMBER;
      ly_edad        NUMBER;
      lyi            NUMBER;
      sum_a          NUMBER;
      ex             NUMBER;
      exy            NUMBER;
   BEGIN
      sum_a := 0;
      --LX_EDAD := ff_mortalidad(Psesion, pTABLA, pEDAD, pSEXO, null, null, 'LX');
      --LXI := ff_mortalidad(Psesion, pTABLA, pEDAD+pduraci, pSEXO, null, null, 'LX');
      lx_edad := ff_lx(psesion, ptabla, pedad, psexo, p_es_mensual);

      IF lx_edad <= 0 THEN
         lx_edad := 1;
      END IF;

      lxi := ff_lx(psesion, ptabla, pedad + pduraci, psexo, p_es_mensual);
      --LY_EDAD := ff_mortalidad(Psesion, pTABLA, pEDAD2, pSEXO2, null, null, 'LX');
      --LYI := ff_mortalidad(Psesion, pTABLA, pEDAD2+pduraci, pSEXO2, null, null, 'LX');
      ly_edad := ff_lx(psesion, ptabla, pedad2, psexo2, p_es_mensual);
      lyi := ff_lx(psesion, ptabla, pedad2 + pduraci, psexo2, p_es_mensual);
      exy := (lxi / lx_edad) *(lyi / ly_edad) * POWER(pv, pduraci);
      RETURN exy;
   END ff_exy;

   FUNCTION ff_exy_cab(
      psesion IN NUMBER,
      ptabla IN NUMBER,
      psexo IN NUMBER,
      pedad IN NUMBER,
      psexo2 IN NUMBER,
      pedad2 IN NUMBER,
      pduraci IN NUMBER,
      pv IN NUMBER,
      pfrac NUMBER DEFAULT 12,
      p_es_mensual IN NUMBER DEFAULT 0)
      RETURN NUMBER IS
      vdurax         NUMBER;
      vduray         NUMBER;
      vduraxy        NUMBER;
      axy            NUMBER;
   BEGIN
      IF pduraci >= fin_morta THEN
         vdurax := pduraci - pedad;
         vduray := pduraci - pedad2;
      ELSE
         vdurax := pduraci;
         vduray := pduraci;
      END IF;

      IF NVL(psexo2, 0) = 0 THEN   --Una cabeza
         axy := ff_ex(psesion, ptabla, psexo, pedad, vdurax, pv, pfrac, p_es_mensual);
      ELSE
         IF pduraci >= fin_morta THEN
            IF pedad > pedad2 THEN
               vduraxy := pduraci - pedad2;
            ELSE
               vduraxy := pduraci - pedad;
            END IF;
         ELSE
            vduraxy := pduraci;
         END IF;

         axy := ff_ex(psesion, ptabla, psexo, pedad, vdurax, pv, pfrac, p_es_mensual)
                + ff_ex(psesion, ptabla, psexo2, pedad2, vduray, pv, pfrac, p_es_mensual)
                - ff_exy(psesion, ptabla, psexo, pedad, psexo2, pedad2, vduraxy, pv, pfrac,
                         p_es_mensual);
      END IF;

      RETURN axy;
   END ff_exy_cab;

--Igual que la FF_ax pero empieza por i=0 hasta n-1
   FUNCTION ff_ax2(
      psesion IN NUMBER,
      ptabla IN NUMBER,
      psexo IN NUMBER,
      pedad IN NUMBER,
      pduraci IN NUMBER,
      pv IN NUMBER,
      mes IN NUMBER,
      p_es_mensual IN NUMBER DEFAULT 0)
      RETURN NUMBER IS
      lx_edad        NUMBER;
      lxi            NUMBER;
      sum_a          NUMBER;
      ex             NUMBER;
   BEGIN
      sum_a := 0;
      lx_edad := ff_lx(psesion, ptabla, pedad, psexo, p_es_mensual);
      lxi := lx_edad;

      FOR i IN 0 .. pduraci - 1 LOOP
         lxi := ff_lx(psesion, ptabla, pedad + i, psexo, p_es_mensual);
         sum_a := sum_a + (lxi / lx_edad) * POWER(pv, i);
      END LOOP;

--    -- dbms_output.put_line('SUM_a='||SUM_a);
      ex := (lxi / lx_edad) * POWER(pv, pduraci);
      -- -- dbms_output.put_line('------------AAAAA:'||(SUM_a + (1-Ex)*(mes-1)/(mes*2)));
      RETURN(sum_a + (1 - ex) *(mes - 1) /(mes * 2));
   END ff_ax2;

   --Igual que la FF_axy pero empieza por i=0 hasta n-1
   FUNCTION ff_axy2(
      psesion IN NUMBER,
      ptabla IN NUMBER,
      psexo IN NUMBER,
      pedad IN NUMBER,
      psexo2 IN NUMBER,
      pedad2 IN NUMBER,
      pduraci IN NUMBER,
      pv IN NUMBER,
      mes IN NUMBER,
      p_es_mensual IN NUMBER DEFAULT 0)
      RETURN NUMBER IS
      lx_edad        NUMBER;
      ly_edad        NUMBER;
      lxi            NUMBER;
      lyi            NUMBER;
      sum_axy        NUMBER;
      exy            NUMBER;
   BEGIN
      sum_axy := 0;
      --LX_EDAD := ff_mortalidad(Psesion, pTABLA, pEDAD, pSEXO, null, null, 'LX');
      lx_edad := ff_lx(psesion, ptabla, pedad, psexo, p_es_mensual);
      --LY_EDAD := ff_mortalidad(Psesion, pTABLA, pEDAD2, pSEXO2, null, null, 'LX');
      ly_edad := ff_lx(psesion, ptabla, pedad2, psexo2, p_es_mensual);
      lxi := lx_edad;
      lyi := ly_edad;

      FOR i IN 0 .. pduraci - 1 LOOP
         --LXI := ff_mortalidad(Psesion, pTABLA, pEDAD+i, pSEXO, null, null, 'LX');
         lxi := ff_lx(psesion, ptabla, pedad + i, psexo, p_es_mensual);
         --LYI := ff_mortalidad(Psesion, pTABLA, pEDAD2+i, pSEXO2, null, null, 'LX');
         lyi := ff_lx(psesion, ptabla, pedad2 + i, psexo2, p_es_mensual);
--    -- dbms_output.put_line('axy'||i||'='||(LXI/LX_EDAD)*(LYI/LY_EDAD)*POWER(pv,i));
         sum_axy := sum_axy + (lxi / lx_edad) *(lyi / ly_edad) * POWER(pv, i);
      END LOOP;

      --  -- dbms_output.put_line('SUM_axy='||SUM_axy);
      exy := (lxi / lx_edad) *(lyi / ly_edad) * POWER(pv, pduraci);
      RETURN(sum_axy + (1 - exy) *(mes - 1) /(mes * 2));
   END ff_axy2;

   FUNCTION ff_axy_cab2(
      psesion IN NUMBER,
      ptabla IN NUMBER,
      psexo IN NUMBER,
      pedad IN NUMBER,
      psexo2 IN NUMBER,
      pedad2 IN NUMBER,
      pduraci IN NUMBER,
      pv IN NUMBER,
      pfracc IN NUMBER DEFAULT 12,
      p_es_mensual IN NUMBER DEFAULT 0)
      RETURN NUMBER IS
      vdurax         NUMBER;
      vduray         NUMBER;
      vduraxy        NUMBER;
      a_xym          NUMBER;
   BEGIN
      IF pduraci >= fin_morta THEN
         vdurax := pduraci - pedad;
         vduray := pduraci - pedad2;
      ELSE
         vdurax := pduraci;
         vduray := pduraci;
      END IF;

      IF NVL(psexo2, 0) = 0 THEN   --Una cabeza
         a_xym := ff_ax2(psesion, ptabla, psexo, pedad, vdurax, pv, pfracc, p_es_mensual);
      ELSE
         IF pduraci >= fin_morta THEN
            IF pedad > pedad2 THEN
               vduraxy := pduraci - pedad2;
            ELSE
               vduraxy := pduraci - pedad;
            END IF;
         ELSE
            vduraxy := pduraci;
         END IF;

         a_xym := ff_ax2(psesion, ptabla, psexo, pedad, vdurax, pv, pfracc, p_es_mensual)
                  + ff_ax2(psesion, ptabla, psexo2, pedad2, vduray, pv, pfracc, p_es_mensual)
                  - ff_axy2(psesion, ptabla, psexo, pedad, psexo2, pedad2, vduraxy, pv, pfracc,
                            p_es_mensual);
      END IF;

      --   -- dbms_output.put_line('a_xym2222='||a_xym);
      RETURN a_xym;
   END ff_axy_cab2;

   FUNCTION f_cpg_ppj(sesion IN NUMBER)
      RETURN NUMBER IS
      icapren        NUMBER;
      rc             NUMBER;
      gastos         NUMBER;
      fecefe         NUMBER;
      fnacimi        NUMBER;
      fnac_ase2      NUMBER;
      sexo           NUMBER;
      sexo_ase2      NUMBER;
      edad_x         NUMBER;
      edad_y         NUMBER;
      ptipoint       NUMBER;
      sproduc        NUMBER;
      nduraci        NUMBER;
      v_int_garan    NUMBER;
      v_int_min      NUMBER;
      tabla_morta    NUMBER;
      axy            NUMBER;
      a_xym          NUMBER;
      nfactor        NUMBER;
      ro             NUMBER;
      retorno        NUMBER := 0;
      v_sseguro      NUMBER := 0;
      v_capital      NUMBER := 0;
      nriesgo        NUMBER := 0;
   BEGIN
      --  GASTOS:= pac_GFI.f_sgt_parms ('GASTOS', sesion)/100;
      fecefe := pac_gfi.f_sgt_parms('FEFEPOL', sesion);   --No esta fecefec
      nriesgo := pac_gfi.f_sgt_parms('NRIESGO', sesion);
      sexo := pac_gfi.f_sgt_parms('SEXO', sesion);
      v_sseguro := pac_gfi.f_sgt_parms('SSEGURO', sesion);

      SELECT TO_CHAR(fnacimi, 'YYYYMMDD')
        INTO fnacimi
        FROM estper_personas
       WHERE sperson = (SELECT sperson
                          FROM estriesgos
                         WHERE sseguro = v_sseguro
                           AND nriesgo = nriesgo);

      ptipoint := pac_gfi.f_sgt_parms('PTIPOINT', sesion);
      nduraci := NVL(pac_gfi.f_sgt_parms('NDURPER', sesion), 10);

      BEGIN
         SELECT SUM(icapital)
           INTO v_capital
           FROM estgaranseg
          WHERE sseguro = v_sseguro
            AND cgarant IN(48, 282);
      EXCEPTION
         WHEN OTHERS THEN
            v_capital := 1;
      END;

      v_int_garan := 1 /(1 + ptipoint / 100);
      tabla_morta := 8;
--    TABLA_MORTA := 5;
      edad_x := fedad(sesion, fnacimi, fecefe, 2);
      --Axy := FF_A_cab(sesion, TABLA_MORTA, SEXO, EDAD_X, SEXO_ASE2, EDAD_Y, NDURACI, V_INT_GARAN);
      --a_xym := FF_axy_cab(sesion, TABLA_MORTA, SEXO, EDAD_X, SEXO_ASE2, EDAD_Y, NDURACI, V_INT_GARAN);
      axy := ff_ex(sesion, tabla_morta, sexo, edad_x, nduraci, v_int_garan, 12, 1);
      RETURN v_capital * axy;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_FRM_ACTUARIAL.F_CPG_PPJ', NULL,
                     'parametros: FECEFE = ' || fecefe || ' FNACIMI =' || fnacimi
                     || ' NDURACI =' || nduraci || ' V_INT_GARAN =' || v_int_garan,
                     SQLERRM);
         RETURN -1;
   END f_cpg_ppj;
END pac_frm_actuarial;

/

  GRANT EXECUTE ON "AXIS"."PAC_FRM_ACTUARIAL" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_FRM_ACTUARIAL" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_FRM_ACTUARIAL" TO "PROGRAMADORESCSI";
