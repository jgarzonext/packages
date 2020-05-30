--------------------------------------------------------
--  DDL for Package Body PAC_FORMUL_TARIFICADOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_FORMUL_TARIFICADOR" IS
   vtabriesg      t_conmutador;
   vtabestalvi    t_conmutador;

   FUNCTION iniciarparametros(psesion IN NUMBER)
      RETURN NUMBER IS
      var            NUMBER;
      vinter2        NUMBER;
      vanyoefecto2   NUMBER;
      panyos         NUMBER;
      v_tablasren    VARCHAR2(100);
      psseguro       NUMBER;
      vgsesion       NUMBER;
      vptipoint      NUMBER;
      vsuprenov      BOOLEAN;
      vsexo          NUMBER;
      vnriesgo       NUMBER;
      vpctdoscab     NUMBER;
      vresp635       NUMBER;
      vpctfall       NUMBER;
      vsexo2         NUMBER;
      vtablamortrisc NUMBER;
      vtablamortestalvi NUMBER;
      vfecrevi2      NUMBER;
      vfechaefectopol DATE;
      vfnacimi2      NUMBER;
      vvfecefecto    DATE;
      vdescerror     VARCHAR2(100);
      vresp637       NUMBER;
      --     vpcapfall NUMBER;
      vpctgasextprov NUMBER;
      paramnul       EXCEPTION;
      vcapitalini    NUMBER;
      vresp1030      NUMBER;
      vdespe         NUMBER;
      vtipoint2      NUMBER;
      vcrevali       NUMBER;
      virevali       NUMBER;
      vprevali       NUMBER;
      vfpagprima     NUMBER;
      --vgarantia := NVL(pac_gfi.f_sgt_parms('GARANTIA', psesion), 0);
      vfpagren       NUMBER;
      vmesefecto     NUMBER;
      vactividad     NUMBER;
      vsproduc       NUMBER;
      vvsproduc      NUMBER;
      vfrevant       NUMBER;
      vesvitalicia   BOOLEAN;
      vfecrevi       NUMBER;
      vfecrevi2fec   DATE;
      vmi            NUMBER;
      vvalorpror     NUMBER;
      vcclaren       NUMBER;
      vnmesextra     seguros_ren.nmesextra%TYPE;
      vtabprog       VARCHAR2(32000);
      vimportemin    NUMBER;
      vpm_anterior   ctaseguro.imovimi%TYPE;
      vcapgarant     ctaseguro_libreta.ccapgar%TYPE;
      vcapfallant    ctaseguro_libreta.ccapfal%TYPE;
      v_numres       ctaseguro.nnumlin%TYPE;
      v_tablas       VARCHAR2(10);
      v_fecha_pm_anterior DATE;
      vnmovimi       NUMBER;
      vdiffinal      NUMBER;
      vgiii          NUMBER;
      vorigenren     NUMBER;
      vgeee          NUMBER;
      vrentaini      NUMBER;
      vfecefe        NUMBER;
      vfec_vto       NUMBER;
      vfnacimi       NUMBER;
      vndurper       NUMBER;
      vpcapfall      NUMBER;
      vpdoscab       NUMBER;
      vreservriesgo  NUMBER;
      vinteresfinal  NUMBER;
      vesmensual     NUMBER;
      vireserva      NUMBER;

      CURSOR esrenov IS
         SELECT 1
           FROM movseguro
          WHERE sseguro = psseguro
            AND cmotmov = 410
            AND nmovimi = vnmovimi;

      vaseg          NUMBER := NULL;
      vesrenov       esrenov%ROWTYPE;
      vfecefepol     NUMBER;
      pesrenov       NUMBER := 0;
      varesrenov     NUMBER := 0;
      vanyosmaxtab   NUMBER;
      vtraza         NUMBER;
      vdespp         NUMBER;
      -- vinteresfinal  NUMBER;
      vgarantia      NUMBER;
      vtarifriesgo   NUMBER;
      vinteres_riesgo NUMBER;

      CURSOR mesextra(pseg NUMBER) IS   --JRH De momento esto lo pondremos aqui en lugar de en una variable del SGT
         SELECT nmesextra
           FROM estseguros_ren
          WHERE sseguro = pseg
            AND v_tablasren = 'EST'
         UNION
         SELECT nmesextra
           FROM seguros_ren
          WHERE sseguro = pseg
            AND v_tablasren <> 'EST';

      CURSOR revi IS   --JRH De momento esto lo pondremos aqui en lugar de en una variable del SGT
         SELECT frevisio
           FROM estseguros_aho
          WHERE sseguro = psseguro
            AND v_tablasren = 'EST'
         UNION
         SELECT frevisio
           FROM seguros_aho
          WHERE sseguro = psseguro
            AND v_tablasren <> 'EST';

--   CURSOR esrenov IS
--      SELECT 1
--        FROM movseguro
--       WHERE sseguro = psseguro
--         AND cmotmov = 410
--         AND nmovimi = vnmovimi;
      CURSOR aseg IS   --JRH De momento esto lo pondremos aqui en lugar de en una variable del SGT
         SELECT 1
           FROM estassegurats
          WHERE sseguro = psseguro
            AND v_tablasren = 'EST'
            AND ffecfin IS NOT NULL
         UNION
         SELECT 1
           FROM asegurados
          WHERE sseguro = psseguro
            AND v_tablasren <> 'EST'
            AND ffecfin IS NOT NULL;

      FUNCTION fedad_aseg_efec   --JRH Cambiada
         RETURN NUMBER IS
         valor          NUMBER;
         vfechaefecto   DATE;
         vfechanacim    DATE;
      BEGIN
         vfechaefecto := TO_DATE(vfecefe, 'YYYYMMDD');
         vfechanacim := TO_DATE(vfnacimi, 'YYYYMMDD');
          -- vfechaefecto := ADD_MONTHS(LAST_DAY(vfechaefecto) + 1, vmesesaanyyadir);
         --  valor := (vfechaefecto - vfechanacim) / 365.25;
         -- -- valor := valor * 12 + -0.5;
         --  valor := TRUNC(valor);
         /*valor := ROUND (((TO_DATE (vfecefe, 'YYYYMMDD')
                           - TO_DATE (vfnacimi, 'YYYYMMDD')
                          ) / 365.25) * 12 * 2, 0) / 24;*/
         valor := ROUND((vfechaefecto - vfechanacim) / 365.25 * 12, 0);
         RETURN valor / 12;
      END fedad_aseg_efec;

      FUNCTION fedad_aseg_efec2   --JRH Cambiada
         RETURN NUMBER IS
         valor          NUMBER;
         vfechaefecto   DATE;
         vfechanacim    DATE;
      BEGIN
         IF vfnacimi2 IS NULL THEN
            RETURN NULL;
         END IF;

         vfechaefecto := TO_DATE(vfecefe, 'YYYYMMDD');
         vfechanacim := TO_DATE(vfnacimi2, 'YYYYMMDD');
          --vfechaefecto := LAST_DAY(vfechaefecto) + 1;
          --vfechaefecto := ADD_MONTHS(LAST_DAY(vfechaefecto) + 1, vmesesaanyyadir);
         -- valor := (vfechaefecto - vfechanacim) / 365.25;
          --valor := valor * 12 + -0.5;   --Correccion tablas
         -- valor := TRUNC(valor);
         valor := ROUND((vfechaefecto - vfechanacim) / 365.25 * 12, 0);
         RETURN valor / 12;
      END fedad_aseg_efec2;

      FUNCTION anyos_fefecto_hasta_fecvto
         RETURN NUMBER IS
         valor          NUMBER;
      BEGIN
         valor := (ROUND(((TO_DATE(vfec_vto, 'YYYYMMDD')
                           - TO_DATE((TO_NUMBER(SUBSTR(TO_CHAR(vfecefe), 0, 6) * 100) + 1),
                                     'YYYYMMDD'))
                          / 365.5)
                         * 12,
                         0)
                   - 0)
                  / 12;
         RETURN valor;
      END anyos_fefecto_hasta_fecvto;
   BEGIN
      -- BUG 13241-  04/2010 - JRH  - 0013421: CIV - Construcción del producto de RENTA VITALICIA según sus requerimientos
         --Varios cambios para mejorar el proceso y adaptarlo a sus especificaciones.
      -- Fi BUG 13241-  04/2010 - JRH
      vorigenren := pac_gfi.f_sgt_parms('ORIGEN', psesion);

      IF NVL(vorigenren, 0) = 1 THEN
         v_tablasren := 'EST';
      ELSE
         v_tablasren := 'SEG';
      -- Si la póliza está anulada en esta fecha la provisión = 0
            -- Miramos si está anulada a esta fecha
      END IF;

      vtraza := 1;
      vgsesion := psesion;
      psseguro := pac_gfi.f_sgt_parms('SSEGURO', psesion);
      vnmovimi := pac_gfi.f_sgt_parms('NMOVIMI', psesion);
      vnriesgo := pac_gfi.f_sgt_parms('NRIESGO', psesion);
      vgarantia := pac_gfi.f_sgt_parms('GARANTIA', psesion);

      --vsproduc := pac_gfi.f_sgt_parms('SPRODUC', psesion);
      --vgiii := pac_gfi.f_sgt_parms('GIII', psesion);
      --vgeee := pac_gfi.f_sgt_parms('GEEE', psesion);
      --vptipoint := pac_gfi.f_sgt_parms('PTIPOINT', psesion);
      --vsexo := pac_gfi.f_sgt_parms('SEXO', psesion);
      -- vfecefe := pac_gfi.f_sgt_parms('FEFEPOL', psesion);
      -- vfecefepol := pac_gfi.f_sgt_parms('FEFEPOL', psesion);
      --vactividad := NVL(pac_gfi.f_sgt_parms('CACTIVI', psesion), 0);
      -- vfec_vto := pac_gfi.f_sgt_parms('FEC_VTO', psesion);
      --vfnacimi := pac_gfi.f_sgt_parms('FNACIMI', psesion);
      --vrentaini := pac_gfi.f_sgt_parms('IBRUREN', psesion);
      --vcapitalini := pac_gfi.f_sgt_parms('ICAPREN', psesion);
      --vndurper := pac_gfi.f_sgt_parms('NDURPER', psesion);
      --vfrevant := pac_gfi.f_sgt_parms('FREVANT', psesion);
      --vfecrevi := pac_gfi.f_sgt_parms('FREVISIO', psesion);

      --vpcapfall := pac_gfi.f_sgt_parms('PCAPFALL', psesion);
      --vpdoscab := pac_gfi.f_sgt_parms('PDOSCAB', psesion);
      --vfpagren := NVL(pac_gfi.f_sgt_parms('CFORPAG_REN', psesion), 0);

      -- vcrevali := NVL(pac_gfi.f_sgt_parms('CREVALI', psesion), 0);
      -- virevali := NVL(pac_gfi.f_sgt_parms('IREVALI', psesion), 0);
      -- vprevali := NVL(pac_gfi.f_sgt_parms('PREVALI', psesion), 0);
      IF NVL(vorigenren, 0) = 1 THEN
         SELECT sproduc, TO_CHAR(fefecto, 'YYYYMMDD'), NVL(cactivi, 0),
                TO_CHAR(fvencim, 'YYYYMMDD'), NVL(crevali, 0), NVL(irevali, 0),
                NVL(prevali, 0)
           INTO vsproduc, vfecefe, vactividad,
                vfec_vto, vcrevali, virevali,
                vprevali
           FROM estseguros
          WHERE sseguro = psseguro;

         vtraza := 101;
         vfechaefectopol := TO_DATE(vfecefe, 'YYYYMMDD');
         vfecefepol := vfecefe;
         vptipoint := pac_inttec.ff_int_seguro('EST', psseguro, TO_DATE(vfecefe, 'yyyymmdd'));
         vtraza := 102;

         SELECT csexper, TO_CHAR(fnacimi, 'YYYYMMDD')
           INTO vsexo, vfnacimi
           FROM estper_personas
          WHERE sperson = (SELECT sperson
                             FROM estriesgos
                            WHERE sseguro = psseguro
                              AND nriesgo = vnriesgo);

         BEGIN
            SELECT NVL(ibruren, 0), NVL(icapren, 0), NVL(ireserva, 0), NVL(cforpag, 0),
                   NVL(pcapfall, 0), NVL(pdoscab, 100)
              INTO vrentaini, vcapitalini, vireserva, vfpagren,
                   vpcapfall, vpdoscab
              FROM estseguros_ren
             WHERE sseguro = psseguro;

            vtraza := 104;
         EXCEPTION
            WHEN OTHERS THEN
               vrentaini := 0;
               vcapitalini := 0;
               vireserva := 0;
               vfpagren := 0;
               vpcapfall := 0;
               vpdoscab := 0;
         END;

         vtraza := 105;

         BEGIN
            SELECT NVL(ndurper, nduraci), TO_CHAR(frevant, 'YYYYMMYY'),
                   TO_CHAR(frevisio, 'YYYYMMYY')
              INTO vndurper, vfrevant,
                   vfecrevi
              FROM estseguros_aho so, estseguros s
             WHERE so.sseguro = psseguro
               AND so.sseguro = s.sseguro;
         EXCEPTION
            WHEN OTHERS THEN
               vndurper := 0;
               vfrevant := NULL;
               vfecrevi := NULL;
         END;

         vtraza := 106;

         BEGIN
            SELECT NVL(MAX(p.csexper), 0), NVL(TO_CHAR(MAX(p.fnacimi), 'yyyymmdd'), 0)
              INTO vsexo2, vfnacimi2
              FROM estassegurats a, estper_personas p
             WHERE a.norden = 2
               AND a.sperson = p.sperson
               AND a.sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS THEN
               vsexo2 := 0;
               vfnacimi2 := 0;
         END;

         vtraza := 107;
      ELSE
         SELECT sproduc, TO_CHAR(fefecto, 'YYYYMMDD'), NVL(cactivi, 0),
                TO_CHAR(fvencim, 'YYYYMMDD'), NVL(crevali, 0), NVL(irevali, 0),
                NVL(prevali, 0)
           INTO vsproduc, vfecefe, vactividad,
                vfec_vto, vcrevali, virevali,
                vprevali
           FROM seguros
          WHERE sseguro = psseguro;

         vtraza := 101;
         vfechaefectopol := TO_DATE(vfecefe, 'YYYYMMDD');
         vfecefepol := vfecefe;
         vptipoint := pac_inttec.ff_int_seguro('SEG', psseguro, TO_DATE(vfecefe, 'yyyymmdd'));
         vtraza := 102;

         SELECT csexper, TO_CHAR(fnacimi, 'YYYYMMDD')
           INTO vsexo, vfnacimi
           FROM per_personas
          WHERE sperson = (SELECT sperson
                             FROM riesgos
                            WHERE sseguro = psseguro
                              AND nriesgo = vnriesgo);

         BEGIN
            SELECT NVL(ibruren, 0), NVL(icapren, 0), NVL(ireserva, 0), NVL(cforpag, 0),
                   NVL(pcapfall, 0), NVL(pdoscab, 100)
              INTO vrentaini, vcapitalini, vireserva, vfpagren,
                   vpcapfall, vpdoscab
              FROM seguros_ren
             WHERE sseguro = psseguro;

            vtraza := 104;
         EXCEPTION
            WHEN OTHERS THEN
               vrentaini := 0;
               vcapitalini := 0;
               vireserva := 0;
               vfpagren := 0;
               vpcapfall := 0;
               vpdoscab := 0;
         END;

         vtraza := 105;

         BEGIN
            SELECT NVL(ndurper, nduraci), TO_CHAR(frevant, 'YYYYMMYY'),
                   TO_CHAR(frevisio, 'YYYYMMYY')
              INTO vndurper, vfrevant,
                   vfecrevi
              FROM seguros_aho so, seguros s
             WHERE so.sseguro = psseguro
               AND so.sseguro = s.sseguro;
         EXCEPTION
            WHEN OTHERS THEN
               vndurper := 0;
               vfrevant := NULL;
               vfecrevi := NULL;
         END;

         vtraza := 106;

         BEGIN
            SELECT NVL(MAX(p.csexper), 0), NVL(TO_CHAR(MAX(p.fnacimi), 'yyyymmdd'), 0)
              INTO vsexo2, vfnacimi2
              FROM asegurados a, per_personas p
             WHERE a.norden = 2
               AND a.sperson = p.sperson
               AND a.sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS THEN
               vsexo2 := 0;
               vfnacimi2 := 0;
         END;
      END IF;

      vtraza := 108;

      SELECT NVL(pgasint, 0), NVL(pgasext, 0)
        INTO vgiii, vgeee
        FROM productos
       WHERE sproduc = vsproduc;

      DECLARE
         vvalor         NUMBER;
      BEGIN
         SELECT cvalpar
           INTO vvalor
           FROM parproductos
          WHERE sproduc = vsproduc
            AND cparpro = 'DURPER';

         IF vvalor = 0 THEN
            vtipoint2 := vptipoint;
         ELSE
            vtipoint2 := pac_inttec.ff_int_producto(vsproduc, 1, TO_DATE(vfecefe, 'yyyymmdd'),
                                                    0);
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            vtipoint2 := vptipoint;
      END;

      vtraza := 18;
      --vfecefe:=20090531;
      vmesefecto := TO_NUMBER(TO_CHAR(TO_DATE(vfnacimi, 'YYYYMMDD'), 'YYYY'));
      vvsproduc := vsproduc;
      vtraza := 2;

      --JRH Fechas de revisión
      IF revi%ISOPEN THEN
         CLOSE revi;
      END IF;

      OPEN revi;

      FETCH revi
       INTO vfecrevi2fec;

      CLOSE revi;

      vtraza := 3;

      IF vfecrevi2fec IS NULL THEN
         vfecrevi2 := 0;
         vfecrevi := NULL;
      ELSE
         vfecrevi2 := 1;
      END IF;

      vtraza := 4;

      BEGIN
         SELECT cclaren
           INTO vcclaren
           FROM producto_ren
          WHERE sproduc = vsproduc;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            vcclaren := 0;
      END;

      vtraza := 5;
      --Gastos de Momento
      vdespe := 0;   --astos sobre pensión 0
      --  vgiii:=0;
      vdespe := 0;
      --   vgeee:=0;
      vdespp := 0;
      vpctgasextprov := 0;   --Gastos ext. sobre prov=0
      vtraza := 6;

      --Fechas de límite
      IF NVL(vfrevant, 0) = 0
         OR vfrevant = vfecefepol THEN   --JRH IMP Si no hay fecha renovacion anterior cogemos la fecha efecto poliza
         vfrevant := vfecefepol;
         vfecefe := vfecefepol;
         varesrenov := 0;
      ELSE
         vfecefe := vfrevant;
         varesrenov := 0;   --Lo tienen asi en su tarificador
      END IF;

      vvfecefecto := TO_DATE(vfecefe, 'YYYYMMDD');

      --Capital ini
      IF NVL(vireserva, 0) <> 0 THEN
         vcapitalini := NVL(vireserva, 0);   --JRH Si ya hemos pasado revisión , en este campo tenemos el capital incial a fecha de revisión
      END IF;

      vtraza := 7;
      --Tipo Alto
      vptipoint := ((1 +(vptipoint / 100)) *(1 -(vdespp + vpctgasextprov))) - 1;
      vptipoint := vptipoint * 100;
      --Tipo Bajo

      -- Bug 15167 - 02/07/2010 - JRH - 0015167: CIV401 - El interés minimo es el de la póliza en estos productos (sólo hay un interés)
      vtraza := 9;
      -- Fi BUG 0011691 - 12/2009 - JRH
      vtipoint2 := ((1 +(vtipoint2 / 100)) *(1 -(vdespp + vpctgasextprov))) - 1;
      vtipoint2 := vtipoint2 * 100;
      vinter2 :=(1 /(1 + vtipoint2 / 100));
      -- dbms_output.put_line('vtipoint2:'||vtipoint2);
      vtraza := 10;
      vtraza := 11;

      IF NVL(vpcapfall, 0) <> 0 THEN
         vpctfall := vpcapfall / 100;
      ELSE
         vpctfall := 0;
         vresp1030 := -1;   --Si no hay fall. vale lo indicamos con -1
      END IF;

      vtraza := 12;

      IF NVL(vpdoscab, 0) <> 0 THEN
         vpctdoscab := vpdoscab / 100;
      ELSE
         vpctdoscab := 0;
      END IF;

--JRH Edades y sexos
      vtraza := 14;

      IF vfnacimi2 = 0 THEN
         vfnacimi2 := NULL;
      END IF;

      IF vsexo2 = 0 THEN
         vsexo2 := NULL;
         vfnacimi2 := NULL;
      END IF;

      vtraza := 15;
      vtraza := 5;

      --JRH 2 CABEZAS
      IF aseg%ISOPEN THEN
         CLOSE aseg;
      END IF;

      OPEN aseg;

      vtraza := 16;

      FETCH aseg
       INTO vaseg;

      CLOSE aseg;

      IF vaseg IS NOT NULL THEN   --Existe un fallecido
         vpctdoscab := 0;   -- no hay reversión ya. El primer riesgo es el que está vivo
      END IF;

      IF NVL(vpctdoscab, 0) = 0 THEN
         vsexo2 := NULL;
         vfnacimi2 := NULL;
      END IF;

      vtraza := 17;
      vtraza := 19;

      --   JRH Tablas de mortalidad
      BEGIN
         SELECT MAX(NVL(g.ctabla, 0))
           INTO vtablamortrisc
           FROM garanpro g, productos s
          WHERE s.sproduc = vsproduc
            AND g.sproduc = s.sproduc
            AND f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, vactividad,
                                g.cgarant, 'TIPO') IN(1, 6, 13);   --Fallecimiento (tabla associada al riesgo)
      EXCEPTION
         WHEN OTHERS THEN
            NULL;   --Pondremos valores por defecto
      END;

      BEGIN
         SELECT MAX(NVL(g.ctabla, 0))
           INTO vtablamortestalvi
           FROM garanpro g, productos s
          WHERE s.sproduc = vsproduc
            AND g.sproduc = s.sproduc
            AND f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, vactividad,
                                g.cgarant, 'TIPO') IN(8, 9);   --renta (tabla associada al ahorro)
      EXCEPTION
         WHEN OTHERS THEN
            NULL;   --Pondremos valores por defecto
      END;

      IF NVL(vresp635, 0) <> 0 THEN   --Renta  financiera
         vtablamortrisc := 0;
         vtablamortestalvi := 0;
      END IF;

--Fin JRH IMP
      vtraza := 20;
      -- Fi Bug 0024725- 27/11/2012 - FAC
      vanyosmaxtab := pac_conmutadors.f_anyos_maxtabla(vtablamortestalvi);
      -- Fi Bug 15869 - 23/10/2010
      vanyosmaxtab := vanyosmaxtab + 1;
      vtraza := 21;

      --JRH Vtos y revisiones
      IF NVL(vfec_vto, 0) = 0 THEN   --JRH IMP Si es vitalicia
         vfec_vto := TO_CHAR(ADD_MONTHS(TO_DATE(GREATEST(NVL(vfnacimi2, vfnacimi), vfnacimi),
                                                'YYYYMMDD'),
                                        vanyosmaxtab * 12),
                             'YYYYMMDD');
         vesvitalicia := TRUE;
      ELSE
         vesvitalicia := FALSE;
      END IF;

      IF NVL(vfecrevi, 0) = 0 THEN   --JRH IMP
         vfecrevi := vfec_vto;
      END IF;

      vanyoefecto2 := TO_NUMBER(TO_CHAR(TO_DATE(vfnacimi2, 'YYYYMMDD'), 'YYYY'));
      vtraza := 6;

      --JRH Duración del periodo de interes
      IF NVL(vndurper, 0) = 0 THEN
         vndurper := MONTHS_BETWEEN(TO_DATE(vfecrevi, 'YYYYMMDD'),
                                    TO_DATE(vfrevant, 'YYYYMMDD'))
                     / 12;
      END IF;

      --JRH Valores revalorización
      vtraza := 22;

      --vgarantia := NVL(pac_gfi.f_sgt_parms('GARANTIA', psesion), 0);
       --JRH Inicio de la revalorización
      IF pac_frm_actuarial.pctipefe(vgsesion) = 0 THEN
         vmi := 1;
      ELSE
         vmi := TO_NUMBER(SUBSTR(vfecefepol, 5, 2));
      END IF;

      --JRH Periodicidad del intervalo de muestreo
      IF vfpagren = 0 THEN
         vfpagprima := 12;
      ELSE
         vfpagprima := vfpagren;
      END IF;

      --JRH Sobremortalidad
      vresp637 := NVL(resp(vgsesion, 637), 0);
      vtraza := 24;
      --JRH Capitalización
      var := NVL(vtramo(vgsesion, 1090, vsproduc), 0);

      ---JRH Calculo de años necesarios para calcular
      IF NVL(fedad_aseg_efec2, 1000) > fedad_aseg_efec THEN
         --    dbms_output.put_line('enro en 111111111111111111111111');
         IF vanyosmaxtab - fedad_aseg_efec <= anyos_fefecto_hasta_fecvto THEN
            panyos := vanyosmaxtab - fedad_aseg_efec;
         ELSE
            panyos := anyos_fefecto_hasta_fecvto;
         END IF;
      ELSE
         -- dbms_output.put_line('enro en 22222222222222222222222');
         IF vanyosmaxtab - fedad_aseg_efec2 <= anyos_fefecto_hasta_fecvto THEN
            --  dbms_output.put_line('enro en 33333333333333333333333333333');
            panyos := vanyosmaxtab - fedad_aseg_efec2;
         ELSE
            -- dbms_output.put_line('enro en 4444444444444444444444');
            panyos := anyos_fefecto_hasta_fecvto;
         END IF;
      END IF;

      vtraza := 28;
      vtabprog := NULL;   --JRH IMP De momento , no hay irregulares--obtenerprogresion(pac_gfi.f_sgt_parms('SSEGURO', psesion), vnriesgo,

      --           TO_DATE(vfecefe, 'YYYYMMDD'), TO_DATE(vfec_vto, 'YYYYMMDD'),
       --          vimportemin);
      OPEN esrenov;

      FETCH esrenov
       INTO vesrenov;

      IF esrenov%FOUND THEN
         --p_datos_ult_saldo(psseguro,   --JRH Ssseguro
          --                 TO_DATE(pfecha, 'YYYYMMDD'), v_fecha_pm_anterior, vpm_anterior,
         --                  vcapgarant, vcapfallant, v_numres);
         --vcapitalini := vpm_anterior;
         vtraza := 30;
         vsuprenov := TRUE;
         varesrenov := 0;

         BEGIN
            SELECT icapital   --Tendremos aqui el ultimo saldo según el proceso de revisión
              INTO vcapitalini
              FROM garanseg, seguros
             WHERE seguros.sseguro = psseguro
               AND garanseg.sseguro = seguros.sseguro
               AND garanseg.nriesgo = 1
               AND garanseg.nmovimi = vnmovimi
               AND f_pargaranpro_v(seguros.cramo, seguros.cmodali, seguros.ctipseg,
                                   seguros.ccolect,
                                   pac_seguros.ff_get_actividad(psseguro, garanseg.nriesgo),
                                   garanseg.cgarant, 'TIPO') = 3;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               vtraza := 32;
               p_tab_error(f_sysdate, f_user, 'pac_formul_cem.f_prov_rent_vit', vtraza,
                           'no encuentra prov ini psseguro:' || psseguro || 'pfecha:' || 1
                           || '1:' || 11,
                           SQLERRM);
               p_datos_ult_saldo(psseguro,   --JRH Ssseguro
                                 f_sysdate, v_fecha_pm_anterior, vpm_anterior, vcapgarant,
                                 vcapfallant, v_numres);
               vcapitalini := vpm_anterior;
         END;
      --vfecefe:=20010901; --JRH Es la fecha efecto de la garantía, fecfrevant
      END IF;

      CLOSE esrenov;

--      DBMS_OUTPUT.put_line('___________________________________________1');   --   vfecha := pfecha;   --JRH IMP Asegurarse que siempre coge la fecha correcta
--      DBMS_OUTPUT.put_line('fedad_aseg_efec:' || fedad_aseg_efec);
--      DBMS_OUTPUT.put_line('vsexo:' || vsexo);
--      DBMS_OUTPUT.put_line('vmesefecto:' || vmesefecto);
--      DBMS_OUTPUT.put_line('fedad_aseg_efec2:' || fedad_aseg_efec2);
--      DBMS_OUTPUT.put_line('vsexo2:' || vsexo2);
--      DBMS_OUTPUT.put_line('vanyoefecto2:' || vanyoefecto2);
--      DBMS_OUTPUT.put_line('vtablamortrisc:' || vtablamortrisc);
--      DBMS_OUTPUT.put_line('vptipoint:' || vptipoint);
--      DBMS_OUTPUT.put_line('vinter2:' || vinter2);
--      DBMS_OUTPUT.put_line('vndurper:' || vndurper);
--      DBMS_OUTPUT.put_line('vprevali:' || vprevali);
--      DBMS_OUTPUT.put_line('virevali:' || virevali);
--      DBMS_OUTPUT.put_line('panyos:' || panyos);
--      DBMS_OUTPUT.put_line('panyos:' || panyos);
--      DBMS_OUTPUT.put_line('var:' || var);
--      DBMS_OUTPUT.put_line('vfpagprima:' || vfpagprima);
--      DBMS_OUTPUT.put_line('vmi:' || vmi);
--      DBMS_OUTPUT.put_line('vresp637:' || vresp637);
--      DBMS_OUTPUT.put_line('vpdoscab:' || vpdoscab);
--      DBMS_OUTPUT.put_line('vfecefe:' || vfecefe);
      vtraza := 33;

      --   varesrenov:=0;
      OPEN mesextra(psseguro);

      FETCH mesextra
       INTO vnmesextra;

      CLOSE mesextra;

      vinteresfinal :=(1 /(1 +(vptipoint / 100)));
      vtarifriesgo := NVL(pac_parametros.f_pargaranpro_n(vsproduc, vactividad, vgarantia,
                                                         'TIPO'),
                          0);
      vesmensual := 1;

      IF vtarifriesgo NOT IN(3, 4, 5, 8, 9, 12) THEN   --Garantías no de ahorro
         vesmensual := 0;

         BEGIN
            SELECT MAX(NVL(g.ctabla, 0))
              INTO vtablamortrisc
              FROM garanpro g, productos s
             WHERE s.sproduc = vsproduc
               AND g.sproduc = s.sproduc
               AND g.cgarant = vgarantia;   --Fallecimiento (tabla associada al riesgo)

            vtablamortestalvi := vtablamortrisc;
         EXCEPTION
            WHEN OTHERS THEN
               NULL;   --Pondremos valores por defecto
         END;

         SELECT NVL(pinttec, 0)
           INTO vinteres_riesgo
           FROM productos
          WHERE sproduc = vsproduc;

         vinteresfinal :=(1 /(1 +(vinteres_riesgo / 100)));
         vinter2 :=(1 /(1 +(vinteres_riesgo / 100)));
      END IF;

      vtabriesg := pac_conmutadors.calculaconmu(vgsesion, fedad_aseg_efec, vsexo, vmesefecto,
                                                fedad_aseg_efec2, vsexo2, vanyoefecto2,
                                                vtablamortrisc, vinteresfinal, vinter2,
                                                vndurper, vprevali, virevali, panyos, panyos,
                                                var, vesmensual, vfpagprima, vmi, 0, vresp637,
                                                0, NVL(vpdoscab, 0), vtabprog, vnmesextra,
                                                TO_NUMBER(SUBSTR(vfecefepol, 5, 2)),
                                                varesrenov, 1, 0, 0);
      vtraza := 34;
      --   DBMS_OUTpUT.PUT_LINE('___________________________________________2');
      vtabestalvi := pac_conmutadors.calculaconmu(vgsesion, fedad_aseg_efec, vsexo, vmesefecto,
                                                  fedad_aseg_efec2, vsexo2, vanyoefecto2,
                                                  vtablamortestalvi, vinteresfinal, vinter2,
                                                  vndurper, vprevali, virevali, panyos, panyos,
                                                  var, 1, vfpagprima, vmi, 0, vresp637, 0,
                                                  NVL(vpdoscab, 0), vtabprog, vnmesextra,
                                                  TO_NUMBER(SUBSTR(vfecefepol, 5, 2)),
                                                  varesrenov, 1, 0, 0);
--    DBMS_OUTpUT.PUT_LINE('___________________________________________3');

      --            if pmodo=6 then
--            IF vtabestalvi.COUNT > 0 THEN
--             dbms_output.put_line('n'||CHR(9)||'vfacint1'||CHR(9)||'vlxi'||CHR(9)||'coc.'||CHR(9)||'vprog'||CHR(9)||'vly'||CHR(9)||'vly/vly0');

      --                        for j in vtabestalvi.first..vtabestalvi.last loop
--              --dbms_output.put_line(vtabestalvi(j).n||' vfacint1:'||vtabestalvi(j).vfacint1||' nx:'||vtabestalvi(j).vnx||' vmx:'||vtabestalvi(j).vmx||' vprog:'||vtabestalvi(j).vprog||' vlxi:'||vtabestalvi(j).vlxi||' div_vlxi:'||to_char(vtabestalvi(j).vlxi/vtabestalvi(1).vlxi));
--      dbms_output.put_line(vtabestalvi(j).n||CHR(9)||vtabestalvi(j).vfacint1||CHR(9)||vtabestalvi(j).vlxi||CHR(9)||to_char(vtabestalvi(j).vlxi/vtabestalvi(1).vlxi)||CHR(9)||vtabestalvi(j).vprog);
----dbms_output.put_line(vtabestalvi(j).n||CHR(9)||vtabestalvi(j).vfacint1||CHR(9)||to_char(vtabestalvi(j).vcx/vtabestalvi(1).vlxi)||CHR(9)||to_char(vtabestalvi(j).vcy/vtabestalvi(1).vlyi)||CHR(9)||to_char(vtabestalvi(j).vcxy/(vtabestalvi(1).vlyi*vtabestalvi(1).vlxi))||CHR(9)||vtabestalvi(j).vprog||CHR(9)||vtabestalvi(j).vlyi||CHR(9)||to_char(vtabestalvi(j).vlyi/vtabestalvi(1).vlyi));
--                  end loop;
--         END IF;
   --   END IF;
      -- BUG -21546_108724- 06/02/2012 - JLTS - Cierre de posibles cursores abiertos
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Error pac_formul_tarificador.iniciarparametros',
                     vtraza, SQLERRM, '1');

         IF revi%ISOPEN THEN
            CLOSE revi;
         END IF;

         IF esrenov%ISOPEN THEN
            CLOSE esrenov;
         END IF;

         RETURN 1;
   END iniciarparametros;

   FUNCTION obtmes(psesion IN NUMBER)
      RETURN NUMBER IS
      vmeses         NUMBER;
      vmeses2        NUMBER;
      vfact          NUMBER;
      vfechaefecto   DATE;
      vfechanacim    DATE;
      vfechadate     DATE;
      psseguro       NUMBER;
      pfecha         NUMBER;
      vfpagprima     NUMBER;
      vfec_vto       NUMBER;
      vfecefe        NUMBER;
      vnmovimi       NUMBER;
      vorigenren     NUMBER;
      vsuprenov      BOOLEAN := FALSE;   --DE MOMENTO
      vfecha         DATE;
      vgarantia      NUMBER;
      vtarifriesgo   NUMBER;
      vmesesdev      NUMBER;
      vesmensual     NUMBER;
      vsproduc       NUMBER;
      vactividad     NUMBER;
   -- vfechadate DATE;
   BEGIN
      psseguro := pac_gfi.f_sgt_parms('SSEGURO', psesion);
      pfecha := NVL(pac_gfi.f_sgt_parms('FECHA', psesion), 0);
      vnmovimi := pac_gfi.f_sgt_parms('NMOVIMI', psesion);
      vorigenren := pac_gfi.f_sgt_parms('ORIGEN', psesion);
      vgarantia := pac_gfi.f_sgt_parms('GARANTIA', psesion);

      IF NVL(vorigenren, 0) = 1 THEN
         SELECT TO_CHAR(fefecto, 'YYYYMMDD'), TO_CHAR(fvencim, 'YYYYMMDD'), sproduc, cactivi
           INTO vfecefe, vfec_vto, vsproduc, vactividad
           FROM estseguros
          WHERE sseguro = psseguro;
      ELSE
         SELECT TO_CHAR(fefecto, 'YYYYMMDD'), TO_CHAR(fvencim, 'YYYYMMDD'), sproduc, cactivi
           INTO vfecefe, vfec_vto, vsproduc, vactividad
           FROM seguros
          WHERE sseguro = psseguro;
      END IF;

      vtarifriesgo := NVL(pac_parametros.f_pargaranpro_n(vsproduc, vactividad, vgarantia,
                                                         'TIPO'),
                          0);

      IF vtarifriesgo NOT IN(3, 4, 5, 8, 9, 12) THEN
         vesmensual := 0;
      END IF;

      IF pfecha = 0 THEN
         pfecha := vfecefe;
      END IF;

      vfecha := TO_DATE(pfecha, 'YYYYMMDD');
      vfpagprima := 12;   --DE MOMENTO

      DECLARE
         vfppren        DATE;
      BEGIN
         SELECT fppren
           INTO vfppren
           FROM seguros_ren
          WHERE sseguro = psseguro;

         IF TO_NUMBER(TO_CHAR(TO_DATE(pfecha, 'YYYYMMDD'), 'DD')) <
                                                              TO_NUMBER(TO_CHAR(vfppren, 'DD')) THEN
            vfact := 12 / vfpagprima;
         ELSE
            vfact := 0;
         END IF;
      --dbms_output.put_line('to_char(vfppren,):'||to_char(vfppren,'DD'));
      EXCEPTION
         WHEN OTHERS THEN
            vfact := 0;
      END;

      vmeses := ROUND(MONTHS_BETWEEN(TO_DATE(vfec_vto, 'YYYYMMDD'),
                                     TO_DATE(vfecefe, 'YYYYMMDD')),
                      0);

--      DBMS_OUTPUT.put_line('vfpagprima_____________:' || vfpagprima);
--      DBMS_OUTPUT.put_line('vnmovimi_____________:' || vnmovimi);
--      DBMS_OUTPUT.put_line('vnmovvorigenrenimi_____________:' || vorigenren);
      IF vfpagprima = 12
         OR(vnmovimi = 1
            AND vorigenren = 1)
         OR vsuprenov THEN
         -- DBMS_OUTPUT.put_line('vfechadate_____________:' || vfechadate);
         vfechaefecto := TO_DATE(vfecefe, 'YYYYMMDD');
         --  DBMS_OUTPUT.put_line('vfechaefecto_____________:' || vfechaefecto);
         vfechadate := vfecha;

         --vfechaefecto := ADD_MONTHS(LAST_DAY(vfechaefecto) + 1, vmesesaanyyadir);
         IF vfechadate < vfechaefecto THEN
            vfechadate := vfechaefecto;
         END IF;

         vmesesdev := ABS(TRUNC(MONTHS_BETWEEN(vfechadate, vfechaefecto))) + 1;
      ELSE
         IF vmeses2 - vfact < 1 THEN
            vfechaefecto := TO_DATE(vfecefe, 'YYYYMMDD');
            vfechadate := TO_DATE(vfecha, 'YYYYMMDD');

            -- vfechaefecto := ADD_MONTHS(LAST_DAY(vfechaefecto) + 1, vmesesaanyyadir);
            IF vfechadate < vfechaefecto THEN
               vfechadate := vfechaefecto;
            END IF;

            vmesesdev := ABS(TRUNC(MONTHS_BETWEEN(vfechadate, vfechaefecto))) + 1;
         ELSE
            vfechaefecto := TO_DATE(vfecefe, 'YYYYMMDD');
            vfechadate := TO_DATE(vfecha, 'YYYYMMDD');

            --  vfechaefecto := ADD_MONTHS(LAST_DAY(vfechaefecto) + 1, vmesesaanyyadir);
            IF vfechadate < vfechaefecto THEN
               vfechadate := vfechaefecto;
            END IF;

            vmesesdev := ABS(TRUNC(MONTHS_BETWEEN(vfechadate, vfechaefecto))) + 1 - vfact;
         END IF;
      END IF;

--
      IF vesmensual = 0 THEN
         RETURN FLOOR(vmesesdev / 12) + 1;
      ELSE
         RETURN vmesesdev;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         --  DBMS_OUTPUT.put_line('vfechadate_____________:' || SQLERRM);
         IF vesmensual = 0 THEN
            RETURN FLOOR((vmeses - 1) / 12) + 1;
         ELSE
            RETURN vmeses - 1;
         END IF;
   END obtmes;

   FUNCTION dx1(psesion IN NUMBER, a NUMBER)
      RETURN NUMBER IS
   BEGIN
      RETURN vtabestalvi(1).vdx;
   END dx1;

   FUNCTION nxn(psesion IN NUMBER, a NUMBER)
      RETURN NUMBER IS
   BEGIN
      RETURN vtabestalvi(obtmes(psesion)).vnxn;
   END nxn;

   FUNCTION dxn(psesion IN NUMBER, a NUMBER)
      RETURN NUMBER IS
   BEGIN
      RETURN vtabestalvi(obtmes(psesion)).vdxn;
   END dxn;

   FUNCTION nx(psesion IN NUMBER, a NUMBER)
      RETURN NUMBER IS
   BEGIN
      --DBMS_OUTPUT.put_line('obtmes(psesion):' || obtmes(psesion));
      IF NVL(a, 0) = 0 THEN
         RETURN vtabestalvi(obtmes(psesion)).vnx;
      ELSE
         RETURN 1 * a;
      END IF;
   END nx;

   FUNCTION dx(psesion IN NUMBER, a NUMBER)
      RETURN NUMBER IS
   BEGIN
      IF NVL(a, 0) = 0 THEN
         RETURN vtabestalvi(obtmes(psesion)).vdx;
      ELSE
         RETURN 1 * a;
      END IF;
   END dx;

   FUNCTION cuenta
      RETURN NUMBER IS
   BEGIN
      RETURN vtabestalvi.COUNT;
   END cuenta;

   FUNCTION mxn(psesion IN NUMBER, a NUMBER)
      RETURN NUMBER IS
   BEGIN
      RETURN vtabestalvi(obtmes(psesion)).vmxn;
   END mxn;

   FUNCTION mx(psesion IN NUMBER, a NUMBER)
      RETURN NUMBER IS
   BEGIN
      IF NVL(a, 0) = 0 THEN
         RETURN vtabestalvi(obtmes(psesion)).vmx;
      ELSE
         RETURN 1 * a;
      END IF;
   END mx;

   FUNCTION rxn(psesion IN NUMBER, a NUMBER)
      RETURN NUMBER IS
   BEGIN
      RETURN vtabestalvi(obtmes(psesion)).vrxn;
   END rxn;

   FUNCTION rx(psesion IN NUMBER, a NUMBER)
      RETURN NUMBER IS
   BEGIN
      IF NVL(a, 0) = 0 THEN
         RETURN vtabestalvi(obtmes(psesion)).vrx;
      ELSE
         RETURN a * 1;
      END IF;
   END rx;

   FUNCTION sxn(psesion IN NUMBER, a NUMBER)
      RETURN NUMBER IS
   BEGIN
      RETURN vtabestalvi(obtmes(psesion)).vsxn;
   END sxn;

   FUNCTION sx(psesion IN NUMBER, a NUMBER)
      RETURN NUMBER IS
   BEGIN
      IF NVL(a, 0) = 0 THEN
         RETURN vtabestalvi(obtmes(psesion)).vsx;
      ELSE
         RETURN 1 * a;
      END IF;
   END sx;
END pac_formul_tarificador;

/

  GRANT EXECUTE ON "AXIS"."PAC_FORMUL_TARIFICADOR" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_FORMUL_TARIFICADOR" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_FORMUL_TARIFICADOR" TO "PROGRAMADORESCSI";
