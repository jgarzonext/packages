--------------------------------------------------------
--  DDL for Package Body PAC_CALC_PROV_RF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_CALC_PROV_RF" IS
       /******************************************************************************
      NOMBRE:     PAC_CALC_PROV_RF
      PROPÓSITO:  Funciones calculo rentas y sus provisiones

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        XX/XX/XXXX   XXX                1. Creación del package.
      1.1        30/01/2009   JRH                2. Bug-8782 Revisión cálculo capital garantizado en productos de Ahorro
      1.2        01/05/2009   JRH                3. Bug 0009172: CRE055 - Rentas regulares e irregulares con cálculos a partir de renta
      1.3        01/05/2009   JRH                4. Bug 0009171: CRE055 - Rentas Regulares Temporal
      1.4        20/06/2009   JRH                5. Bug-10336 : CRE - Simular producto de rentas a partir del importe de renta y no de la prima
      1.5        09/12/2009   APD                6. Bug 11896 - se sustituye el TIPO = 6 por 13
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
   capitalini     NUMBER;
   rentaini       NUMBER;
   nmovimi        NUMBER;
   nriesgo        NUMBER;
   ndurper        NUMBER;
   sproduc        NUMBER;
   valor_ppj_n1vax_pp NUMBER := NULL;
   esvitalicia    BOOLEAN;
   contraseg      NUMBER := 1;
   vcontraseg2    NUMBER := 1;
   pcapfall       NUMBER;
   resp1030       NUMBER;
   pctfall        NUMBER;
   despr          NUMBER;
   despe          NUMBER;
   pctdoscab      NUMBER;
   fnacimi2       NUMBER;
   sexo2          NUMBER;
   pdoscab        NUMBER;
   vmesefecto     NUMBER;
   vcrevali       NUMBER;
   virevali       NUMBER;
   vprevali       NUMBER;
   vgarantia      NUMBER;
   vfpagprima     NUMBER;
   fpagprima      NUMBER;
   vresp1021      NUMBER;
   vresp1022      NUMBER;
   vresp1023      NUMBER;
   vresp1024      NUMBER;
   vtablamortrisc NUMBER;
   vtablamortestalvi NUMBER;
   vcimpips       NUMBER;
   vresp1004      NUMBER;
   vresp1003      NUMBER;
   vtipoint2      NUMBER;
   vactividad     NUMBER;
   vsproduc       NUMBER;
   vmi            NUMBER;
   -- BUG 9889 - 04/2009 - JRH  - Cuadre de los datos del cierre de ABRIL
   vtabriesg      t_conmutador;
   --obtabriesg     ob_iax_conmut;
   vtabestalvi    t_conmutador;
   vdiffinal      NUMBER;
   vvalorpror     NUMBER;
   vfpagren       NUMBER;
   vfechaencuentro DATE;
-- Bug 0009171 - JRH - 01/05/2009 - Nueva Función : Bug 0009171: CRE055 - Rentas temporales
   vresp637       NUMBER;
   vresp635       NUMBER;

-- fi Bug 0009171
-- Bug 0009171 - JRH - 01/05/2009 - Nueva Función : Bug 0009171: CRE055 - Rentas temporales
/*************************************************************************
   ObtenerMinValor: Busca mínimo valor de renta irregular

   Param IN psseguro: Seguro
   Param IN pnriesgo: Riesgo
   return : El valor máximo de la renta irregular
****************************************************************************************/
   FUNCTION obtenerminvalor(psseguro NUMBER, pnriesgo NUMBER)
      RETURN NUMBER IS
      --Bug 27562-XVM-11/07/2013
      CURSOR impirreg IS
         SELECT   MIN(x.importe) importe
             FROM (SELECT p1.importe
                     FROM planrentasirreg p1
                    WHERE p1.sseguro = psseguro
                      AND p1.nriesgo = pnriesgo
                      AND NVL(p1.importe, 0) <> 0
                      AND p1.nmovimi = (SELECT MAX(p2.nmovimi)
                                          FROM planrentasirreg p2
                                         WHERE p2.sseguro = p1.sseguro
                                           AND p2.nriesgo = p1.nriesgo)
                   UNION
                   SELECT p1.importe
                     FROM estplanrentasirreg p1
                    WHERE p1.sseguro = psseguro
                      AND p1.nriesgo = pnriesgo
                      AND NVL(p1.importe, 0) <> 0
                      AND p1.nmovimi = (SELECT MAX(p2.nmovimi)
                                          FROM estplanrentasirreg p2
                                         WHERE p2.sseguro = p1.sseguro
                                           AND p2.nriesgo = p1.nriesgo)) x
         ORDER BY 1 ASC;

      vimporte       planrentasirreg.importe%TYPE;
   BEGIN
      OPEN impirreg;

      FETCH impirreg
       INTO vimporte;

      CLOSE impirreg;

      RETURN NVL(vimporte, 0);
   END obtenerminvalor;

-- Bug 0009171 - JRH - 01/05/2009 - Nueva Función : Bug 0009171: CRE055 - Rentas temporales

   /*************************************************************************
      ObtenerValor: Busca renta irregular para mes año

      Param IN psseguro: Seguro
      Param IN pnriesgo: Riesgo
      Param IN pmes : mes
      Param IN panyo : año
      return : El valor de la renta irregular para ese mes/año
   ****************************************************************************************/
   FUNCTION obtenervalor(psseguro NUMBER, pnriesgo NUMBER, pmes NUMBER, panyo NUMBER)
      RETURN NUMBER IS
      CURSOR impirreg IS
         SELECT   p1.importe importe
             FROM planrentasirreg p1
            WHERE p1.sseguro = psseguro
              AND p1.nriesgo = pnriesgo
              AND p1.mes = pmes
              AND p1.anyo = panyo
              AND p1.nmovimi = (SELECT MAX(p2.nmovimi)
                                  FROM planrentasirreg p2
                                 WHERE p2.sseguro = p1.sseguro
                                   AND p2.nriesgo = p1.nriesgo)
         UNION
         SELECT   p1.importe importe
             FROM estplanrentasirreg p1
            WHERE p1.sseguro = psseguro
              AND p1.nriesgo = pnriesgo
              AND p1.mes = pmes
              AND p1.anyo = panyo
              AND p1.nmovimi = (SELECT MAX(p2.nmovimi)
                                  FROM estplanrentasirreg p2
                                 WHERE p2.sseguro = p1.sseguro
                                   AND p2.nriesgo = p1.nriesgo)
         ORDER BY 1 ASC;

      vimporte       planrentasirreg.importe%TYPE;
   BEGIN
      OPEN impirreg;

      FETCH impirreg
       INTO vimporte;

      CLOSE impirreg;

      RETURN NVL(vimporte, 0);
   END obtenervalor;

-- Bug 0009171 - JRH - 01/05/2009 - Nueva Función : Bug 0009171: CRE055 - Rentas temporales

   /*************************************************************************
      ObtenerProgresion: Obtiene el valor de la progresión a partir de la resntas irregulares

      Param IN psseguro: Seguro
      Param IN pnriesgo: Riesgo
      return : El valor de la progresión
   ****************************************************************************************/
   FUNCTION obtenerprogresion(
      psseguro NUMBER,
      pnriesgo NUMBER,
      fechainic DATE,
      fechafin DATE,
      vimportemin OUT NUMBER)
      RETURN VARCHAR2 IS
      vanyo          NUMBER;
      vmes           NUMBER;
      vfecha         NUMBER;
      vimporte       NUMBER;
      cimporte       VARCHAR2(100);
      vprog          VARCHAR2(32000);
   BEGIN
      vimportemin := obtenerminvalor(psseguro, pnriesgo);

      IF NVL(vimportemin, 0) = 0 THEN
         RETURN NULL;
      END IF;

      FOR i IN 0 .. FLOOR(MONTHS_BETWEEN(fechafin, fechainic)) LOOP
         vfecha := TO_NUMBER(TO_CHAR(ADD_MONTHS(fechainic, i), 'YYYYMMDD'));
         vmes := TO_NUMBER(TO_CHAR(TO_DATE(vfecha, 'YYYYMMDD'), 'MM'));
         vanyo := TO_NUMBER(TO_CHAR(TO_DATE(vfecha, 'YYYYMMDD'), 'YYYY'));
         vimporte := obtenervalor(psseguro, pnriesgo, vmes, vanyo);
         cimporte := TO_CHAR(ROUND(vimporte / vimportemin, 5));
         cimporte := REPLACE(REPLACE(cimporte, '.', ''), ',', '.');
         vprog := vprog || cimporte || ',';
      END LOOP;

      RETURN vprog;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_calc_prov_rf.ObtenerProgresion:' || psseguro, 1,
                     'Error:' || SQLERRM, 'AAAA');
         RAISE;
   END obtenerprogresion;

   FUNCTION fedad_aseg_efec   --JRH Cambiada
      RETURN NUMBER IS
      valor          NUMBER;
   BEGIN
      /*valor := ROUND (((TO_DATE (fecefe, 'YYYYMMDD')
                        - TO_DATE (fnacimi, 'YYYYMMDD')
                       ) / 365.25) * 12 * 2, 0) / 24;*/
      valor := ROUND(((TO_DATE(fecefe, 'YYYYMMDD') - TO_DATE(fnacimi, 'YYYYMMDD')) / 365.25)
                     * 12,
                     0)
               / 12;
      RETURN valor;
   END fedad_aseg_efec;

   FUNCTION fedad_aseg_efec2   --JRH Cambiada
      RETURN NUMBER IS
      valor          NUMBER;
   BEGIN
      /*valor := ROUND (((TO_DATE (fecefe, 'YYYYMMDD')
                        - TO_DATE (fnacimi, 'YYYYMMDD')
                       ) / 365.25) * 12 * 2, 0) / 24;*/
      valor := ROUND(((TO_DATE(fecefe, 'YYYYMMDD') - TO_DATE(fnacimi2, 'YYYYMMDD')) / 365.25)
                     * 12,
                     0)
               / 12;
      RETURN valor;
   END fedad_aseg_efec2;

   FUNCTION fedad_aseg   --JRH Cambiada
      RETURN NUMBER IS
      valor          NUMBER;
   BEGIN
      /*valor := ROUND (((TO_DATE (fecha, 'YYYYMMDD')
                        - TO_DATE (fnacimi, 'YYYYMMDD')
                       ) / 365.25) * 2 * 12, 0) / 24;*/
      valor := ROUND(((TO_DATE(fecha, 'YYYYMMDD') - TO_DATE(fnacimi, 'YYYYMMDD')) / 365.25)
                     * 12, 0)
               / 12;
      RETURN valor;
   END fedad_aseg;

   FUNCTION fedad_aseg2   --JRH Cambiada
      RETURN NUMBER IS
      valor          NUMBER;
   BEGIN
      --dbms_output.put_line('11');
       /*valor := ROUND (((TO_DATE (fecha, 'YYYYMMDD')
                         - TO_DATE (fnacimi, 'YYYYMMDD')
                        ) / 365.25) * 2 * 12, 0) / 24;*/
      valor := ROUND(((TO_DATE(fecha, 'YYYYMMDD') - TO_DATE(fnacimi2, 'YYYYMMDD')) / 365.25)
                     * 12,
                     0)
               / 12;
      RETURN valor;
   END fedad_aseg2;

   FUNCTION anyos_hasta_vencim_fecha   --cambiado
      RETURN NUMBER IS
      valor          NUMBER;
      fechavto       NUMBER;
   BEGIN
      -- Si me piden el importe en la misma fecha del vencimiento, hay que tratar ese mes
      /*
      IF ((TO_NUMBER (SUBSTR (TO_CHAR (fec_vto), 0, 6)) * 100) + 1) = fecha THEN
        fechavto := TO_CHAR (ADD_MONTHS (TO_DATE (((TO_NUMBER (SUBSTR (TO_CHAR (fec_vto), 0, 6)) * 100) + 1), 'YYYYMMDD'), 1), 'YYYYMMDD');
      ELSE*/
      fechavto := fec_vto;   --TO_CHAR (ADD_MONTHS (TO_DATE (fec_vto, 'YYYYMMDD'), 1), 'YYYYMMDD');
      --END IF;

      /*valor := (ROUND (((TO_DATE (((TO_NUMBER (SUBSTR (TO_CHAR (fecha), 0, 6)) * 100) + 1), 'YYYYMMDD')
                        - TO_DATE (fecefe, 'YYYYMMDD')
                       ) / 365.5) * 12, 0) - 0) / 12;*/
      valor := (ROUND(((ADD_MONTHS(TO_DATE(fecha, 'YYYYMMDD'), 1) - TO_DATE(fecefe, 'YYYYMMDD'))
                       / 365.5)
                      * 12,
                      0)
                - 0)
               / 12;
      RETURN valor;
   END anyos_hasta_vencim_fecha;

   FUNCTION anyos_fefecto_hasta_fecha   --cambiado
      RETURN NUMBER IS
      valor          NUMBER;
   BEGIN
      valor := (ROUND(((TO_DATE(fecha, 'YYYYMMDD')
                        - TO_DATE((TO_NUMBER(SUBSTR(TO_CHAR(fecefe), 0, 6) * 100) + 1),
                                  'YYYYMMDD'))
                       / 365.5)
                      * 12,
                      0)
                - 0)
               / 12;
      valor := (ROUND(((ADD_MONTHS(TO_DATE(fecha, 'YYYYMMDD'), 1) - TO_DATE(fecefe, 'YYYYMMDD'))
                       / 365.5)
                      * 12,
                      0)
                - 0)
               / 12;
      RETURN valor;
   END anyos_fefecto_hasta_fecha;

   FUNCTION anyos_fefecto_hasta_fecvto
      RETURN NUMBER IS
      valor          NUMBER;
   BEGIN
      valor := (ROUND(((TO_DATE(fec_vto, 'YYYYMMDD')
                        - TO_DATE((TO_NUMBER(SUBSTR(TO_CHAR(fecefe), 0, 6) * 100) + 1),
                                  'YYYYMMDD'))
                       / 365.5)
                      * 12,
                      0)
                - 0)
               / 12;
      RETURN valor;
   END anyos_fefecto_hasta_fecvto;

   FUNCTION anyos_fecha_hasta_fecvto
      RETURN NUMBER IS
      valor          NUMBER;
   BEGIN
      -- dbms_output.put_line('1111');
      valor := (ROUND(((TO_DATE(fec_vto, 'YYYYMMDD')
                        - TO_DATE((TO_NUMBER(SUBSTR(TO_CHAR(fecha), 0, 6) * 100) + 1),
                                  'YYYYMMDD'))
                       / 365.5)
                      * 12,
                      0)
                - 0)
               / 12;
      RETURN valor;
   END anyos_fecha_hasta_fecvto;

/*************************************************************************
   obtmes:  Obtiene el mes respecto a la fecha de efecto
****************************************************************************************/

   -- Bug 0009172 - JRH - 01/05/2009 - Nueva Función : Bug 0009172: CRE055 - Rentas regulares e irregulares con cálculos a partir de renta
   FUNCTION obtmes
      RETURN NUMBER IS
      meses          NUMBER;
   BEGIN
      meses := ROUND(MONTHS_BETWEEN(TO_DATE(fec_vto, 'YYYYMMDD'), TO_DATE(fecefe, 'YYYYMMDD')),
                     0);
      RETURN ABS(TRUNC(MONTHS_BETWEEN(TO_DATE(fecha, 'YYYYMMDD'), TO_DATE(fecefe, 'YYYYMMDD'))))
             + 1;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN meses - 1;
   END;

/*************************************************************************
   ppj_vaxn_pp:  ppj_vaxn_pp
****************************************************************************************/

   -- Bug 0009172 - JRH - 01/05/2009 - Nueva Función : Bug 0009172: CRE055 - Rentas regulares e irregulares con cálculos a partir de renta
   FUNCTION ppj_vaxn_pp
      RETURN NUMBER IS
      valor          NUMBER;
      valory         NUMBER := 0;
      valorxy        NUMBER := 0;
      diffinal       NUMBER;
      fecefecto      DATE;
   BEGIN
      valor := vtabestalvi(1).vaxnpp * vvalorpror;
      valory := 0;
      valorxy := 0;

      IF pctdoscab <> 0
         AND NVL(sexo2, 0) <> 0 THEN
         valory := ((vtabestalvi(1).vny - vtabestalvi(1).vnyn) / vtabestalvi(1).vdy)
                   * vvalorpror;

         IF NVL(valory, 0) <= 0 THEN
            valory := 0;
         END IF;

         valorxy := ((vtabestalvi(1).vnxy - vtabestalvi(1).vnxyn) / vtabestalvi(1).vdxy)
                    * vvalorpror;

         IF NVL(valorxy, 0) <= 0 THEN
            valorxy := 0;
         END IF;
      END IF;

      valor := valor + pctdoscab *(1 - contraseg) *(valory - valorxy);
      RETURN valor;
   END ppj_vaxn_pp;

/*************************************************************************
   ppj_vaxn_pp2:  ppj_vaxn_pp2
****************************************************************************************/

   -- Bug 0009172 - JRH - 01/05/2009 - Nueva Función : Bug 0009172: CRE055 - Rentas regulares e irregulares con cálculos a partir de renta
   FUNCTION ppj_vaxn_pp2
      RETURN NUMBER IS
      valor          NUMBER;
      valory         NUMBER := 0;
      valorxy        NUMBER := 0;
      diffinal       NUMBER;
      fecefecto      DATE;
   BEGIN
      valor := vtabestalvi(obtmes).vaxnpp * vvalorpror;
      valory := 0;
      valorxy := 0;

      IF pctdoscab <> 0
         AND NVL(sexo2, 0) <> 0 THEN
         valory := ((vtabestalvi(obtmes).vny - vtabestalvi(obtmes).vnyn)
                    / vtabestalvi(obtmes).vdy)
                   * vvalorpror;

         IF NVL(valory, 0) <= 0 THEN
            valory := 0;
         END IF;

         valorxy := ((vtabestalvi(obtmes).vnxy - vtabestalvi(obtmes).vnxyn)
                     / vtabestalvi(obtmes).vdxy)
                    * vvalorpror;

         IF NVL(valorxy, 0) <= 0 THEN
            valorxy := 0;
         END IF;
      END IF;

      valor := valor + pctdoscab *(1 - contraseg) *(valory - valorxy);
      RETURN valor;
   END ppj_vaxn_pp2;

/*************************************************************************
   ppj_n1vax_pp:  ppj_n1vax_pp
****************************************************************************************/

   -- Bug 0009172 - JRH - 01/05/2009 - Nueva Función : Bug 0009172: CRE055 - Rentas regulares e irregulares con cálculos a partir de renta
   FUNCTION ppj_n1vax_pp
      RETURN NUMBER IS
      valor          NUMBER;
   BEGIN
      valor := vtabriesg(obtmes).vux0 - vtabriesg(obtmes + 1).vux;
      valor := valor / vtabriesg(obtmes).vdx0;
      RETURN valor;
   END ppj_n1vax_pp;

/*************************************************************************
   ppj_1nvax_pp: ppj_1nvax_pp
****************************************************************************************/

   -- Bug 0009172 - JRH - 01/05/2009 - Nueva Función : Bug 0009172: CRE055 - Rentas regulares e irregulares con cálculos a partir de renta
   FUNCTION ppj_1nvax_pp
      RETURN NUMBER IS
      a              NUMBER;
      b              NUMBER;
      c              NUMBER;
      valor          NUMBER;
      pcagrpro       NUMBER;
   BEGIN
      RETURN vtabriesg(obtmes).l_nvaxpp;
   END ppj_1nvax_pp;

/*************************************************************************
   ppj_n1vax_pu: ppj_n1vax_pu
****************************************************************************************/

   -- Bug 0009172 - JRH - 01/05/2009 - Nueva Función : Bug 0009172: CRE055 - Rentas regulares e irregulares con cálculos a partir de renta
   FUNCTION ppj_n1vax_pu
      RETURN NUMBER IS
      valor          NUMBER;
   BEGIN
      valor := vtabriesg(obtmes).vmx0 - vtabriesg(obtmes + 1).vmx;
      valor := valor / vtabriesg(obtmes).vdx0;
      RETURN valor;
   END ppj_n1vax_pu;

/*************************************************************************
   iniciarparametros: Inicia parametros
   Param IN psesion: sesion
   Param IN rentamax : Defecto o
****************************************************************************************/

   -- Bug 0009172 - JRH - 01/05/2009 - Nueva Función : Bug 0009172: CRE055 - Rentas regulares e irregulares con cálculos a partir de renta
   PROCEDURE iniciarparametros(psesion IN NUMBER, rentamax IN NUMBER DEFAULT 0) IS
      var            NUMBER;
      vfecefecto     DATE;
      vinter2        NUMBER;
      vanyoefecto2   NUMBER;
      panyos         NUMBER;

      CURSOR mesextra(pseg NUMBER) IS   --JRH De momento esto lo pondremos aqui en lugar de en una variable del SGT
         SELECT nmesextra
           FROM estseguros_ren
          WHERE sseguro = pseg
         UNION
         SELECT nmesextra
           FROM seguros_ren
          WHERE sseguro = pseg;

      vnmesextra     seguros_ren.nmesextra%TYPE;
      vtabprog       VARCHAR2(32000);
      vimportemin    NUMBER;
   BEGIN
      gsesion := psesion;
      giii := pac_gfi.f_sgt_parms('GIII', psesion);
      geee := pac_gfi.f_sgt_parms('GEEE', psesion);
      isi := pac_gfi.f_sgt_parms('ISI', psesion);
      ptipoint := pac_gfi.f_sgt_parms('PTIPOINT', psesion);
      sexo := pac_gfi.f_sgt_parms('SEXO', psesion);
      fecefe := pac_gfi.f_sgt_parms('FECEFE', psesion);
      vactividad := 0;
      vfecefecto := TO_DATE(fecefe, 'YYYYMMDD');
      --fecefe:=20090531;
      vfechaencuentro := NULL;
      fec_vto := pac_gfi.f_sgt_parms('FEC_VTO', psesion);
      fnacimi := pac_gfi.f_sgt_parms('FNACIMI', psesion);
      vmesefecto := TO_NUMBER(TO_CHAR(TO_DATE(fnacimi, 'YYYYMMDD'), 'YYYY'));
      rentaini := pac_gfi.f_sgt_parms('IBRUREN', psesion);
      nmovimi := pac_gfi.f_sgt_parms('NMOVIMI', psesion);
      nriesgo := pac_gfi.f_sgt_parms('NRIESGO', psesion);
      capitalini := pac_gfi.f_sgt_parms('ICAPREN', psesion);
      ndurper := pac_gfi.f_sgt_parms('NDURPER', psesion);
      sproduc := pac_gfi.f_sgt_parms('SPRODUC', psesion);
      vsproduc := sproduc;
      pcapfall := pac_gfi.f_sgt_parms('PCAPFALL', psesion);
      pdoscab := pac_gfi.f_sgt_parms('PDOSCAB', psesion);
      resp1030 := NVL(resp(gsesion, 1030), 0);

      IF ndurper IS NOT NULL THEN
         vtipoint2 := pac_inttec.ff_int_producto(sproduc, 1, TO_DATE(fecefe, 'YYYYMMDD'),
                                                 ndurper);
         vinter2 :=(1 /(1 + vtipoint2 / 100));
      ELSE
         vinter2 := NULL;
      END IF;

      IF rentamax <> 0 THEN
         ptipoint := pac_inttec.ff_int_producto(sproduc, 1, TO_DATE(fecefe, 'YYYYMMDD'), 1);   --Si no es la màxima siempre ponemos la minima
      END IF;

      IF NVL(pcapfall, 0) <> 0 THEN
         contraseg := 1;

         IF vsproduc = 550 THEN   --JRH IMP Pdte.
            vcontraseg2 := 0;
         ELSE
            vcontraseg2 := 1;
         END IF;

         --contraseg:=PCAPFALL/100;
         pctfall := pcapfall / 100;
      ELSE
         pctfall := 0;
         contraseg := 0;
         vcontraseg2 := 0;
         resp1030 := -1;   --Si no hay fall. vale lo indicamos con -1
      END IF;

      IF NVL(pdoscab, 0) <> 0 THEN
         pctdoscab := pdoscab / 100;
      ELSE
         pctdoscab := 0;
      END IF;

      --despe := vtramo(psesion, 1310, sproduc);
      --despr := vtramo(psesion, 1309, sproduc);
      sexo2 := NVL(pac_gfi.f_sgt_parms('SEXO_ASE2', psesion), 0);
      fnacimi2 := NVL(pac_gfi.f_sgt_parms('FNAC_ASE2', psesion), 0);

      IF fnacimi2 = 0 THEN
         fnacimi2 := NULL;
      END IF;

      IF sexo2 = 0 THEN
         sexo2 := NULL;
         fnacimi2 := NULL;
      END IF;

      IF NVL(fec_vto, 0) = 0 THEN   --JRH IMP Si es vitalicia
         fec_vto := TO_CHAR(ADD_MONTHS(TO_DATE(LEAST(NVL(fnacimi2, fnacimi), fnacimi),
                                               'YYYYMMDD'),
                                       125 * 12),
                            'YYYYMMDD');
         esvitalicia := TRUE;
      ELSE
         esvitalicia := FALSE;
      END IF;

      vanyoefecto2 := TO_NUMBER(TO_CHAR(TO_DATE(fnacimi2, 'YYYYMMDD'), 'YYYY'));

      IF NVL(pctdoscab, 0) = 0 THEN
         sexo2 := NULL;
         fnacimi2 := NULL;
      END IF;

      vcrevali := NVL(pac_gfi.f_sgt_parms('CREVALI', psesion), 0);
      virevali := NVL(pac_gfi.f_sgt_parms('IREVALI', psesion), 0);
      vprevali := NVL(pac_gfi.f_sgt_parms('PREVALI', psesion), 0);
      --vgarantia := NVL(pac_gfi.f_sgt_parms('GARANTIA', psesion), 0);
      vfpagren := NVL(pac_gfi.f_sgt_parms('CFORPAG_REN', psesion), 0);

      IF vfpagren = 0 THEN
         vfpagprima := 12;
      ELSE
         vfpagprima := vfpagren;
      END IF;

      vresp1021 := NVL(resp(gsesion, 1021), 0);
      vresp1022 := NVL(resp(gsesion, 1022), 0);
      vresp1023 := NVL(resp(gsesion, 1023), 0);
      vresp1024 := NVL(resp(gsesion, 1024), 0);
      vresp637 := NVL(resp(gsesion, 637), 0);
      vresp635 := NVL(resp(gsesion, 635), 0);

      IF NVL(resp(gsesion, 1040), 0) <> 0 THEN   --Tablas a nivel de garantia en la pregunta 1040
         vtablamortrisc := NVL(resp(gsesion, 1040), 0);
      ELSE
         BEGIN
            -- Bug 11896 - APD - 09/12/2009 - se sustituye el TIPO = 6 por 13
            SELECT MAX(g.ctabla)
              INTO vtablamortrisc
              FROM garanpro g, productos s
             WHERE s.sproduc = vsproduc
               AND g.sproduc = s.sproduc
               AND f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, vactividad,
                                   g.cgarant, 'TIPO') = 13;   --Muerte (tabla associada al riesgo)
         EXCEPTION
            WHEN OTHERS THEN
               NULL;   --Pondremos valores por defecto
         END;
      END IF;

      IF NVL(resp(gsesion, 1041), 0) <> 0 THEN   --Tablas a nivel de garantia en la pregunta 1041
         vtablamortestalvi := NVL(resp(gsesion, 1041), 0);
      ELSE
         BEGIN
            SELECT MAX(g.ctabla)
              INTO vtablamortestalvi
              FROM garanpro g, productos s
             WHERE s.sproduc = vsproduc
               AND g.sproduc = s.sproduc
               AND f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, vactividad,
                                   g.cgarant, 'TIPO') IN(8, 9, 11);   --cap. garantizado (tabla associada al ahorro)
         EXCEPTION
            WHEN OTHERS THEN
               NULL;   --Pondremos valores por defecto
         END;
      END IF;

      IF NVL(vresp635, 0) <> 0 THEN   --Renta  financiera
         vtablamortrisc := 0;
         vtablamortestalvi := 0;
      END IF;

      BEGIN
         SELECT MAX(g.cimpips)
           INTO vcimpips
           FROM garanpro g, productos s
          WHERE s.sproduc = vsproduc
            AND g.sproduc = s.sproduc
            AND f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, vactividad,
                                g.cgarant, 'TIPO') >= 3;   --cap. garantizado (tabla associada al ahorro)
      EXCEPTION
         WHEN OTHERS THEN
            vcimpips := 0;   --Pondremos valores por defecto
      END;

      IF vcimpips = 0 THEN   -- No calculamos ISI
         isi := 0;
      ELSE
         isi := pac_gfi.f_sgt_parms('ISI', psesion);
      END IF;

      IF NVL(resp(gsesion, 571), 0) <> 0 THEN   --Si tenemos Gastos a nivel de póliza en la pregunta 571 QUITAR ESTO DEFINITIVAMENTE
         giii := NVL(resp(gsesion, 571), 0);
      ELSE
         giii := pac_gfi.f_sgt_parms('GIII', psesion);
      END IF;

      IF NVL(resp(gsesion, 570), 0) <> 0 THEN   --Si tenemos Gastos a nivel de póliza en la pregunta 570
         geee := NVL(resp(gsesion, 570), 0);
      ELSE
         geee := pac_gfi.f_sgt_parms('GEEE', psesion);
      END IF;

      IF NVL(resp(gsesion, 680), 0) <> 0 THEN   --Si tenemos Gastos a nivel de póliza en la pregunta 571
         despr := NVL(resp(gsesion, 680), 0);
      ELSE
         despr := pac_gfi.f_sgt_parms('GIII', psesion);
      END IF;

      IF NVL(resp(gsesion, 681), 0) <> 0 THEN   --Si tenemos Gastos a nivel de póliza en la pregunta 571
         despe := NVL(resp(gsesion, 681), 0);
      ELSE
         despe := pac_gfi.f_sgt_parms('GIII', psesion);
      END IF;

      IF pac_frm_actuarial.pctipefe(gsesion) = 0 THEN
         vmi := 1;
      ELSE
         vmi := TO_NUMBER(SUBSTR(fecefe, 5, 2));
      END IF;

      IF vcrevali = 1 THEN
         vresp1004 := 0;
         vresp1003 := virevali;   --Es un importe
      ELSIF vcrevali = 2 THEN
         vresp1004 := vprevali;
         vresp1003 := 0;   --Es un importe
      ELSIF vcrevali = 0 THEN
         vresp1004 := 0;
         vresp1003 := 0;   --Es un importe
      END IF;

      var := NVL(vtramo(gsesion, 1090, sproduc), 0);
      vdiffinal := (LAST_DAY(vfecefecto) - vfecefecto) / TO_CHAR(LAST_DAY(vfecefecto), 'DD');
      vvalorpror := POWER((1 /(1 + ptipoint / 100)), vdiffinal / 12);

      IF 125 - fedad_aseg_efec <= anyos_fefecto_hasta_fecvto THEN
         panyos := 125 - fedad_aseg_efec;
      ELSE
         panyos := anyos_fefecto_hasta_fecvto;
      END IF;

--      dbms_output.put_line('panyos:'||panyos);
--      dbms_output.put_line('fedad_aseg_efec:'||fedad_aseg_efec);
--      dbms_output.put_line('sexo:'||sexo);
--      dbms_output.put_line('vmesefecto:'||vmesefecto);
--      dbms_output.put_line('vtablamortestalvi:'||vtablamortestalvi);
--      dbms_output.put_line('ptipoint:'||ptipoint);
--      dbms_output.put_line('vtipoint2:'||vtipoint2);
--      dbms_output.put_line('ndurper:'||ndurper);
--      dbms_output.put_line('vresp1004:'||vresp1004);
--      dbms_output.put_line('vresp1003:'||vresp1003);
--      dbms_output.put_line('anyos_fefecto_hasta_fecvto:'||anyos_fefecto_hasta_fecvto);
--      dbms_output.put_line('var:'||var);
--      dbms_output.put_line('vfpagprima:'||vfpagprima);
--      dbms_output.put_line('vmi:'||vmi);
--      dbms_output.put_line('vvalorpror:'||vvalorpror);
--      dbms_output.put_line('fedad_aseg_efec2:'||fedad_aseg_efec2);
--      dbms_output.put_line('sexo2:'||sexo2);
--      dbms_output.put_line('vAnyoefecto2:'||vAnyoefecto2);
--      despe := 1;
--      despr := 7;
--      GEEE:=1;
--      vfpagprima:=1;
--      dbms_output.put_line('GEEE:'||GEEE);
--      dbms_output.put_line('despr:'||despr);
--      dbms_output.put_line('despe:'||despe);
--      dbms_output.put_line('vtablamortestalvi:'||vtablamortestalvi);
--      dbms_output.put_line('vtablamortrisc:'||vtablamortrisc);
      OPEN mesextra(pac_gfi.f_sgt_parms('SSEGURO', psesion));   --Pagas extras

      FETCH mesextra
       INTO vnmesextra;

      CLOSE mesextra;

--dbms_output.put_line('fedad_aseg_efec:'||fedad_aseg_efec);
      vtabprog := obtenerprogresion(pac_gfi.f_sgt_parms('SSEGURO', psesion), nriesgo,
                                    TO_DATE(fecefe, 'YYYYMMDD'), TO_DATE(fec_vto, 'YYYYMMDD'),
                                    vimportemin);
      vtabriesg := pac_conmutadors.calculaconmu(gsesion, fedad_aseg_efec, sexo, vmesefecto,
                                                fedad_aseg_efec2, sexo2, vanyoefecto2,
                                                vtablamortrisc,(1 /(1 + ptipoint / 100)),
                                                vinter2, ndurper, vresp1004, vresp1003, panyos,
                                                panyos, var, 1, vfpagprima, vmi, 0, vresp637,
                                                0, NVL(pdoscab, 0), vtabprog, vnmesextra,
                                                TO_NUMBER(SUBSTR(fecefe, 5, 2)));
      vtabestalvi := pac_conmutadors.calculaconmu(gsesion, fedad_aseg_efec, sexo, vmesefecto,
                                                  fedad_aseg_efec2, sexo2, vanyoefecto2,
                                                  vtablamortestalvi,(1 /(1 + ptipoint / 100)),
                                                  vinter2, ndurper, vresp1004, vresp1003,
                                                  panyos, panyos, var, 1, vfpagprima, vmi, 0,
                                                  vresp637, 0, NVL(pdoscab, 0), vtabprog,
                                                  vnmesextra, TO_NUMBER(SUBSTR(fecefe, 5, 2)));
   --IF vtabestalvi.COUNT > 0 THEN
   --   for j in vtabestalvi.first..vtabestalvi.last loop
   --      dbms_output.put_line(vtabestalvi(j).n||' dx:'||vtabestalvi(j).vdx||' nx:'||vtabestalvi(j).vnx||' vmx:'||vtabestalvi(j).vmx||' vprog:'||vtabestalvi(j).vprog);
   --
   --   end loop;
   --END IF;

   --IF vtabestalvi.COUNT > 0 THEN
   --   for j in vtabestalvi.first..vtabestalvi.last loop
   --      dbms_output.put_line(vtabestalvi(j).n||' dx:'||vtabestalvi(j).vdx||' nx:'||vtabestalvi(j).vnx||' vmx:'||vtabestalvi(j).vmx||' vprog:'||vtabestalvi(j).vprog);
   --
   --   end loop;
   --END IF;
   END iniciarparametros;

/*************************************************************************
   f_calculo_renta: Calcula renta parcial a una fecha
   Param IN psesion: sesion
   Param IN psseguro: Seguro
   Param IN pfecha : fecha
   Param IN rentamax : Defecto o
   return : El valor si todo ha ido bien, si no nulo
****************************************************************************************/

   -- Bug 0009172 - JRH - 01/05/2009 - Nueva Función : Bug 0009172: CRE055 - Rentas regulares e irregulares con cálculos a partir de renta
   FUNCTION f_calculo_renta(
      psesion IN NUMBER,
      psseguro IN NUMBER,
      pfecha IN DATE,
      rentamax IN NUMBER DEFAULT 0)
      RETURN NUMBER IS
      renta          NUMBER;
      fechaant       NUMBER;
      a              NUMBER;
      vimportemin    NUMBER;
   BEGIN
      --Si nos llaman desde el gfi debemos tener estos datos en los parametros
      --iniciarparametros(psesion,rentamax);
      fecha := TO_CHAR(pfecha, 'YYYYMMDD');   --pac_gfi.f_sgt_parms ('FECHA', psesion);
      gsesion := psesion;
      vimportemin := obtenerminvalor(psseguro, nriesgo);

      IF vimportemin <> 0 THEN   --JRH Si hay renta irregular calculamos siempre el capital
         renta := vimportemin
                  *((ppj_vaxn_pp /(1 -(despe / 100) -(geee / 100))
                     - (vcontraseg2 * ppj_n1vax_pp) /(1 -(despr / 100) -(geee / 100))
                       *(1 +(isi / 100)))
                    /(1
                      - (contraseg * ppj_n1vax_pu * pctfall) /(1 -(despr / 100) -(geee / 100))
                        *(1 +(isi / 100))));
      ELSE
         IF NVL(capitalini, 0) <> 0 THEN   --Si nos informan el capital buscamos la renta y viceversa
            renta := capitalini
                     /((ppj_vaxn_pp /(1 -(despe / 100) -(geee / 100))
                        - (vcontraseg2 * ppj_n1vax_pp) /(1 -(despr / 100) -(geee / 100))
                          *(1 +(isi / 100)))
                       /(1
                         - (ppj_n1vax_pu * contraseg * pctfall)
                           /(1 -(despr / 100) -(geee / 100)) *(1 +(isi / 100))));
         ELSE
            renta := rentaini
                     *((ppj_vaxn_pp /(1 -(despe / 100) -(geee / 100))
                        - (vcontraseg2 * ppj_n1vax_pp) /(1 -(despr / 100) -(geee / 100))
                          *(1 +(isi / 100)))
                       /(1
                         - (contraseg * ppj_n1vax_pu * pctfall)
                           /(1 -(despr / 100) -(geee / 100)) *(1 +(isi / 100))));
         END IF;
      END IF;

            /*
      --      dbms_output.put_line('renta:'||renta||'   obtmes:'||obtmes);
      --      dbms_output.put_line('rentaini:'||rentaini||'   despe:'||despe);
      --      dbms_output.put_line('geee:'||geee||'   despr:'||despr);
      --      dbms_output.put_line('ppj_vaxn_pp :'||ppj_vaxn_pp );
      --      dbms_output.put_line('ppj_n1vax_pu:'||ppj_n1vax_pu);
      --      dbms_output.put_line('ppj_n1vax_pp:'||ppj_n1vax_pp);
      --
      --      dbms_output.put_line('vtabestalvi(obtmes).ux:'||vtabestalvi(obtmes).vux);
      --      dbms_output.put_line('vtabestalvi(obtmes).ux0:'||vtabestalvi(obtmes).vux0);
      --      dbms_output.put_line('______________________________________________________________________________');
      --
      --      dbms_output.put_line('vtabestalvi(obtmes).vaxnpp:'||vtabestalvi(obtmes).vaxnpp);
      --      dbms_output.put_line('vtabestalvi(obtmes).n_vaxpp:'||vtabestalvi(obtmes).n_vaxpp);
      --      dbms_output.put_line('vtabestalvi(obtmes).l_nvaxpp:'||vtabestalvi(obtmes).l_nvaxpp);
      --      dbms_output.put_line('vtabestalvi(obtmes).vaxnpu:'||vtabestalvi(obtmes).vaxnpu);
      --      dbms_output.put_line('vtabestalvi(obtmes).n_vaxpu:'||vtabestalvi(obtmes).n_vaxpu);
      --      dbms_output.put_line('vtabestalvi(obtmes).l_nvaxpu:'||vtabestalvi(obtmes).l_nvaxpu);
      --
      --      dbms_output.put_line('obtmes:'||obtmes);
      --      dbms_output.put_line('vtabRiesg(obtmes).vlxi:'||vtabRiesg(obtmes).vlxi);
      --      dbms_output.put_line('vtabRiesg(obtmes).vaxnpp:'||vtabRiesg(obtmes).vaxnpp);
      --      dbms_output.put_line('vtabRiesg(obtmes).n_vaxpp:'||vtabRiesg(obtmes).n_vaxpp);
      --      dbms_output.put_line('vtabRiesg(obtmes).l_nvaxpp:'||vtabRiesg(obtmes).l_nvaxpp);
      --      dbms_output.put_line('vtabRiesg(obtmes).vaxnpu:'||vtabRiesg(obtmes).vaxnpu);
      --      dbms_output.put_line('vtabRiesg(obtmes).n_vaxpu:'||vtabRiesg(obtmes).n_vaxpu);
      --      dbms_output.put_line('vtabRiesg(obtmes).l_nvaxpu:'||vtabRiesg(obtmes).l_nvaxpu);
      --

            */

      /*
            fecha := TO_CHAR(ADD_MONTHS(TO_DATE(fecha ,'YYYYMMDD'),1),'YYYYMMDD');

      --       dbms_output.put_line('-------------------------------------------'); --tAx

      --      dbms_output.put_line('ppj_n1vax_pu:'||ppj_n1vax_pu); --tAx
      --      dbms_output.put_line('ppj_1nvax_pu:'||ppj_1nvax_pu);
      --      dbms_output.put_line('ppj_n1vax_pu:'||ppj_vaxn_pu);
      --      dbms_output.put_line('ppj_n1vax_pp:'||ppj_n1vax_pp);
      --      dbms_output.put_line('ppj_n1vax_pp:'||ppj_1nvax_pp);
      --      dbms_output.put_line('ppj_n1vax_pp:'||ppj_vaxn_pp);
      --      fecha := TO_CHAR(ADD_MONTHS(TO_DATE(fecha ,'YYYYMMDD'),1),'YYYYMMDD');

      --       dbms_output.put_line('-------------------------------------------'); --tAx

      --      dbms_output.put_line('ppj_n1vax_pu:'||ppj_n1vax_pu); --tAx
      --      dbms_output.put_line('ppj_1nvax_pu:'||ppj_1nvax_pu);
      --      dbms_output.put_line('ppj_n1vax_pu:'||ppj_vaxn_pu);
      --      dbms_output.put_line('ppj_n1vax_pp:'||ppj_n1vax_pp);
      --      dbms_output.put_line('ppj_n1vax_pp:'||ppj_1nvax_pp);
      --      dbms_output.put_line('ppj_n1vax_pp:'||ppj_vaxn_pp);
      --      fecha := TO_CHAR(ADD_MONTHS(TO_DATE(fecha ,'YYYYMMDD'),1),'YYYYMMDD');

      --       dbms_output.put_line('-------------------------------------------'); --tAx

      --      dbms_output.put_line('ppj_n1vax_pu:'||ppj_n1vax_pu); --tAx
      --      dbms_output.put_line('ppj_1nvax_pu:'||ppj_1nvax_pu);
      --      dbms_output.put_line('ppj_n1vax_pu:'||ppj_vaxn_pu);
      --      dbms_output.put_line('ppj_n1vax_pp:'||ppj_n1vax_pp);
      --      dbms_output.put_line('ppj_n1vax_pp:'||ppj_1nvax_pp);
      --      dbms_output.put_line('ppj_n1vax_pp:'||ppj_vaxn_pp);
            */
      RETURN renta;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'f_calculo_renta:' || psseguro, 1,
                     'Error:' || SQLERRM, 'AAAA');
         RETURN NULL;
   END f_calculo_renta;

   FUNCTION primdia(fec DATE)
      RETURN DATE IS
      fecfin         DATE;
   BEGIN
      RETURN TO_DATE('01' || SUBSTR(TO_CHAR(fec, 'DD/MM/YYYY'), 3), 'DD/MM/YYYY');
   END primdia;

/*************************************************************************
   f_cal_rent: Calcula renta total a una fecha
   Param IN psesion: sesion
   Param IN psseguro: Seguro
   Param IN pfecha : fecha
   Param IN rentamax : Defecto o
   return : El valor si todo ha ido bien, si no nulo
****************************************************************************************/

   -- Bug 0009172 - JRH - 01/05/2009 - Nueva Función : Bug 0009172: CRE055 - Rentas regulares e irregulares con cálculos a partir de renta

   -- Dudas
   -- Termes màxims (mesos) de reemborsament prestació            9999
   -- Termes totals (mesos) de renda (vençuda)            9999
   FUNCTION f_cal_rent(
      psesion IN NUMBER,
      psseguro IN NUMBER,
      pfecha IN DATE,
      rentamax IN NUMBER DEFAULT 0)
      RETURN NUMBER IS
      valor_renta_ant NUMBER := 99999999999;
      valor_renta_act NUMBER := 99999999999;
      valor_renta_post NUMBER := 99999999999;
      edad           NUMBER;
      anysmaxtabla   NUMBER;   --años hasta el máx tablas de mortalidad
      fechaminini    DATE;
      fechamaxini    DATE;
      fechaintervalorini DATE;
      fechaintervalorfin DATE;
      a              NUMBER;
   BEGIN
      --Si nos llaman desde el gfi debemos tener estos datos en los parametros
      iniciarparametros(psesion, rentamax);
      fecha := pac_gfi.f_sgt_parms('FECHA', psesion);

      IF pfecha IS NULL THEN
         fecha := pac_gfi.f_sgt_parms('FECHA', psesion);
      ELSE
         fecha := TO_CHAR(pfecha, 'YYYYMMDD');
      END IF;

      gsesion := psesion;
      fecha := fecefe;
      edad := (TO_DATE(fecha, 'yyyymmdd') - TO_DATE(fnacimi, 'yyyymmdd')) / 365;

      /*--Si es vitalicia
      if EsVitalicia then
        AnysMaxTabla:=128-edad;
      else

      end if;*/
      IF NVL(resp1030, 0) >= 0 THEN
         IF NVL(resp1030, 0) = 0 THEN
            anysmaxtabla := 125 - edad;
         ELSE
            anysmaxtabla := resp1030 / 12;
         END IF;
      ELSE
         anysmaxtabla := 0;   -- Si no hay cap fall no hemos de buscar mínimo de rentas, sólo hemos de calcular el valor de una de estás a la fecha
      END IF;

      --El margen de fechas para probar la función que devuelve las rentas es entre edad fechaMinIni y fechaMaxIni
      fechaminini := primdia(TO_DATE(fecha, 'yyyymmdd'));
      fechamaxini := primdia(ADD_MONTHS(fechaminini, anysmaxtabla * 12));
      --Empezamos por la mitad de ellas para calcular la renta
      fechaintervalorini := primdia(fechaminini +((fechamaxini - fechaminini) / 2));

      IF NVL(capitalini, 0) <> 0 THEN   --Si sacamos renta a partir de capital es el mínimo
         --Buscamos el minimo de f_calculo_renta a base de iterar a partir de fechaIntervalorIni
         --Suponemos que la función sólo tiene un mínimo en el intervalo.
         LOOP
            --dbms_output.put_line('______');
            --dbms_output.put_line('1:'||valor_renta_act||'   '||fechaIntervalorIni);
            valor_renta_act := f_calculo_renta(psesion, psseguro, fechaintervalorini,
                                               rentamax);
            valor_renta_ant := f_calculo_renta(psesion, psseguro,
                                               ADD_MONTHS(fechaintervalorini, -1), rentamax);
            valor_renta_post := f_calculo_renta(psesion, psseguro,
                                                ADD_MONTHS(fechaintervalorini, +1), rentamax);

            IF valor_renta_act < valor_renta_ant
               AND valor_renta_act > valor_renta_post THEN
               fechaminini := primdia(fechaintervalorini);
               fechamaxini := fechamaxini;   --PrimDia(ADD_MONTHS(fechaMinIni,AnysMaxTabla*12));
               fechaintervalorini := primdia(fechaminini +((fechamaxini - fechaminini) / 2));
            ELSIF valor_renta_act > valor_renta_ant
                  AND valor_renta_act < valor_renta_post THEN
               fechaminini := fechaminini;   --PrimDia(TO_DATE(fechaIntervalorIni,'yyyymmdd'));
               fechamaxini := primdia(fechaintervalorini);   --PrimDia(ADD_MONTHS(fechaMinIni,AnysMaxTabla*12));
               fechaintervalorini := primdia(fechaminini +((fechamaxini - fechaminini) / 2));
            ELSE
               valor_renta_act := LEAST(NVL(valor_renta_act, 9999999999999),
                                        NVL(valor_renta_post, 9999999999999));
               valor_renta_act := LEAST(NVL(valor_renta_act, 9999999999999),
                                        NVL(valor_renta_ant, 9999999999999));
               EXIT;
            END IF;

            IF ABS(MONTHS_BETWEEN(fechaminini, fechamaxini)) <= 2 THEN
               valor_renta_act := LEAST(NVL(valor_renta_act, 9999999999999),
                                        NVL(valor_renta_post, 9999999999999));
               valor_renta_act := LEAST(NVL(valor_renta_act, 9999999999999),
                                        NVL(valor_renta_ant, 9999999999999));
               EXIT;
            END IF;
         END LOOP;
      ELSE   --Si sacamos capital a partir de renta es el máximo (de momento hasta rentas irregulares)
         LOOP
            --dbms_output.put_line('______');
            --dbms_output.put_line('1:'||valor_renta_act||'   '||fechaIntervalorIni);
            valor_renta_act := f_calculo_renta(psesion, psseguro, fechaintervalorini,
                                               rentamax);
            valor_renta_ant := f_calculo_renta(psesion, psseguro,
                                               ADD_MONTHS(fechaintervalorini, -1), rentamax);
            valor_renta_post := f_calculo_renta(psesion, psseguro,
                                                ADD_MONTHS(fechaintervalorini, +1), rentamax);

            --dbms_output.put_line('valor_renta_act:'||valor_renta_act||' '||fechaintervalorini);
            IF valor_renta_act > valor_renta_ant
               AND valor_renta_act < valor_renta_post THEN
               fechaminini := primdia(fechaintervalorini);
               fechamaxini := fechamaxini;   --PrimDia(ADD_MONTHS(fechaMinIni,AnysMaxTabla*12));
               fechaintervalorini := primdia(fechaminini +((fechamaxini - fechaminini) / 2));
            ELSIF valor_renta_act < valor_renta_ant
                  AND valor_renta_act > valor_renta_post THEN
               fechaminini := fechaminini;   --PrimDia(TO_DATE(fechaIntervalorIni,'yyyymmdd'));
               fechamaxini := primdia(fechaintervalorini);   --PrimDia(ADD_MONTHS(fechaMinIni,AnysMaxTabla*12));
               fechaintervalorini := primdia(fechaminini +((fechamaxini - fechaminini) / 2));
            ELSE
               valor_renta_act := GREATEST(NVL(valor_renta_act, 0), NVL(valor_renta_post, 0));
               valor_renta_act := GREATEST(NVL(valor_renta_act, 0), NVL(valor_renta_ant, 0));
               EXIT;
            END IF;

            IF ABS(MONTHS_BETWEEN(fechaminini, fechamaxini)) <= 2 THEN
               valor_renta_act := GREATEST(NVL(valor_renta_act, 0), NVL(valor_renta_post, 0));
               valor_renta_act := GREATEST(NVL(valor_renta_act, 0), NVL(valor_renta_ant, 0));
               EXIT;
            END IF;
         END LOOP;
      END IF;

      vfechaencuentro := fechaintervalorini;
      --dbms_output.put_line('vFechaEncuentro:'||vFechaEncuentro);
      RETURN valor_renta_act;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'f_cal_rent:' || psseguro, 1, 'Error:' || SQLERRM,
                     'AAAA');
         RETURN NULL;
   END f_cal_rent;

/*************************************************************************
   f_cal_ObtenerSaldos: Obtiene el saldo detalle de un campo
   Param IN psseguro: Seguro
   Param IN pnumlin : Número de línia
   Param IN pcampo : Campo
   return : El valor si todo ha ido bien, si no nulo
****************************************************************************************/

   -- Bug 0009172 - JRH - 01/05/2009 - Nueva Función : Bug 0009172: CRE055 - Rentas regulares e irregulares con cálculos a partir de renta
   FUNCTION obtenersaldos(psseguro IN NUMBER, pnumlin IN NUMBER, pcampo IN VARCHAR2)
      RETURN NUMBER IS
      vvalor         NUMBER;
      errnumlin      EXCEPTION;
   BEGIN
      IF pnumlin IS NULL THEN
         RAISE errnumlin;
      END IF;

      SELECT valor
        INTO vvalor
        FROM ctaseguro_detalle
       WHERE sseguro = psseguro
         AND nnumlin = (SELECT MAX(c2.nnumlin)
                          FROM ctaseguro_detalle c2
                         WHERE c2.sseguro = psseguro
                           AND c2.ccampo = pcampo
                           AND c2.nnumlin <= pnumlin)
         AND ccampo = pcampo;

      RETURN vvalor;
   EXCEPTION
      WHEN errnumlin THEN
         p_tab_error(f_sysdate, f_user, 'ObtenerSaldos:' || psseguro || ' ' || pnumlin, 1,
                     'Error:' || 'errNumLin', 'AAAA');
         RETURN 0;
      WHEN NO_DATA_FOUND THEN
         p_tab_error(f_sysdate, f_user, 'ObtenerSaldos:' || psseguro || ' ' || pnumlin, 1,
                     'Error:' || SQLERRM, 'AAAA');
         RETURN 0;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'ObtenerSaldos:' || psseguro || ' ' || pnumlin, 1,
                     'Error:' || SQLERRM, 'AAAA');
         RETURN NULL;
   END obtenersaldos;

/*************************************************************************
   f_cal_prov: Calcula provision y capiales
   Param IN psesion: sesion
   Param IN psseguro: Seguro
   Param IN pfecha : fecha
   Param IN pfonprov : Devuelve --> 0 prov x,1 prov y, 2 prov xy, 3 prov riesg, 4 prov total, 5 capital fall, 6 capital garant
   return : El valor si todo ha ido bien, si no nulo
****************************************************************************************/

   -- Bug 0009172 - JRH - 01/05/2009 - Nueva Función : Bug 0009172: CRE055 - Rentas regulares e irregulares con cálculos a partir de renta
   FUNCTION f_cal_prov(
      psesion IN NUMBER,
      psseguro IN NUMBER,
      pfecha IN DATE,
      pfonprov IN NUMBER DEFAULT 0   -- 0 = Capital Garantizado
                                     -- 1 = Provisión matemàtica
                                  )
      RETURN NUMBER IS
      pm             NUMBER;
      pm_anterior    NUMBER;
      pm_anterior_pura NUMBER;
      capitalacumant NUMBER;
      v_fecha_pm_anterior DATE;
      v_numres       NUMBER;
      factorprov     NUMBER;
      capgaran       NUMBER;
      ulfecha        DATE;
      pcapgarant     NUMBER;
      pcapfallant    NUMBER;
      ultmov         NUMBER;
      aportacion_inicial NUMBER;
      nmovimi        NUMBER;
      nriesgo        NUMBER;

      CURSOR c_polizas_provmat IS
         SELECT s.cramo, s.cmodali, s.ctipseg, s.ccolect, p.pinttec,
                NVL(s.fcaranu, s.fvencim) ffinal, s.fefecto, s.ncertif, s.nduraci nduraci,
                p.pgasint, p.pgasext, s.cactivi, s.cforpag, s.fvencim, p.pgaexin, p.pgaexex,
                p.cdivisa, s.sproduc, NVL(s.femisio, s.fefecto) femisio
           FROM productos p, seguros s
          WHERE s.sseguro = psseguro
            AND p.ctipseg = s.ctipseg
            AND p.cmodali = s.cmodali
            AND p.cramo = s.cramo
            AND p.ccolect = s.ccolect
            AND s.csituac <> 4;

      CURSOR c_movimientos(psseguro NUMBER, f_ini DATE, f_final DATE, pnnumlin NUMBER) IS
         SELECT   DECODE(cmovimi,   -- DETVALORES = 83
                         1, imovimi,   -- Aportacio Extraordinaria
                         2, imovimi,   -- Aportació periódica
                         4, imovimi,   -- Aportació Única
                         9, imovimi,   -- Aportació Participacio Beneficis
                         10, imovimi,   -- Anulación prestación
                         -imovimi   -- (Rescats 27, 33 i 34)
                                 ) imovimi,
                  ffecmov, fvalmov, nnumlin, cmovimi
             FROM ctaseguro
            WHERE sseguro = psseguro
              AND cmovimi IN(1, 2, 4, 9, 10, 27, 33, 34, 51, 53)   -- JRH 01/2009 Ponemos el 27,51,53
              AND((TRUNC(ffecmov) BETWEEN f_ini AND f_final
                   AND TRUNC(fcontab) <= GREATEST(f_final, pfecha))
                  OR(TRUNC(fcontab) BETWEEN f_ini + 1 AND f_final
                     AND ffecmov <= f_ini
                                         --    AND nnumlin > nvl (pnnumlin, 0)
                    )
                  -- Se controlan los recibos anulados el mismo dia que se hace la reducción
                  OR(TRUNC(fcontab) = f_ini
                     AND ffecmov <= f_ini
                     AND nnumlin > NVL(pnnumlin, 0)))
              AND nnumlin > NVL(pnnumlin, 0)
         UNION   --JRH 8737 No nos dejamos aquello que tenga fecha valor > que el último cierre, la union es porque el  AND nnumlin > NVL (pnnumlin, 0) antrior es necesario
         SELECT   DECODE(cmovimi,   -- DETVALORES = 83
                         1, imovimi,   -- Aportacio Extraordinaria
                         2, imovimi,   -- Aportació periódica
                         4, imovimi,   -- Aportació Única
                         9, imovimi,   -- Aportació Participacio Beneficis
                         10, imovimi,   -- Anulación prestación
                         -imovimi   -- (Rescats 27, 33 i 34)
                                 ) imovimi,
                  ffecmov, fvalmov, nnumlin, cmovimi
             FROM ctaseguro
            WHERE sseguro = psseguro
              AND cmovimi IN(1, 2, 4, 9, 10, 27, 33, 34, 51, 53)   -- JRH 01/2009 Ponemos el 27,51,53
              AND TRUNC(ffecmov) > f_ini
              AND TRUNC(ffecmov) <= f_final
         ORDER BY nnumlin;

      v_tablas       VARCHAR2(20);
      vdxi           NUMBER := 0;
      vdyi           NUMBER := 0;
      vdxyi          NUMBER := 0;
      vdxi_risc      NUMBER := 0;
      vdxi_cx        NUMBER := 0;
      vdxi_act       NUMBER := 0;
      vdyi_act       NUMBER := 0;
      vdxyi_act      NUMBER := 0;
      vdxi_risc_act  NUMBER := 0;
      vdxi_cx_act    NUMBER := 0;
      vsaldo_x_ini   NUMBER := 0;
      vsaldo_y_ini   NUMBER := 0;
      vsaldo_xy_ini  NUMBER := 0;
      vsaldo_risc_ini NUMBER := 0;
      vsaldo_x       NUMBER := 0;
      vsaldo_y       NUMBER := 0;
      vsaldo_xy      NUMBER := 0;
      vsaldo_risc    NUMBER := 0;
      vtraza         NUMBER := 0;
      capfallec      NUMBER := 0;
      vsaldo         NUMBER := 0;
      vrenta         NUMBER := 0;
      fechaant       NUMBER;
      vrenta2        NUMBER;
      existemov      BOOLEAN := FALSE;
      vfactor1       NUMBER;
      vfactor2       NUMBER;
      vdias          NUMBER;
      vfactortotal1  NUMBER;
      vfactortotal2  NUMBER;
      vfecdate       DATE;
      vnum           NUMBER;
      vnummes        NUMBER;
   BEGIN
      --Si nos llaman desde el gfi debemos tener estos datos en los parametros
      IF pfonprov = 6 THEN
         pm := 0;   -- De momento el capital garan es 0
         RETURN 0;
      ELSIF pfonprov IN(1, 2) THEN   --Provisiones 2 cabezas
         IF NVL(pac_gfi.f_sgt_parms('PDOSCAB', psesion), 0) = 0 THEN   --Si no es 2 cabezas  valen 0
            pm := 0;
            RETURN 0;
         END IF;
      ELSIF pfonprov = 3 THEN   --Riesgo
         IF NVL(pac_gfi.f_sgt_parms('PCAPFALL', psesion), 0) = 0 THEN   --Si no hay riesgo
            pm := 0;
            RETURN 0;
         END IF;
      ELSIF pfonprov = 5 THEN   --Riesgo
         IF NVL(pac_gfi.f_sgt_parms('PCAPFALL', psesion), 0) = 0 THEN   --Si no hay riesgo
            pm := 0;
            RETURN 0;
         END IF;
      END IF;

      iniciarparametros(psesion);
      vnummes := TO_CHAR(TO_DATE(fecefe, 'YYYYMMDD'), 'DD');
      fecefe := FLOOR(fecefe / 100) * 100 + 01;
      vtraza := 1;
      v_tablas := NULL;

      --El calculo del a provisión lo haremos a partir de la ultima provisión del saldo, los movimiento siguientes, y la simulación
      --de movimientos hasta el vto
      FOR reg IN c_polizas_provmat LOOP
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
--JRH Buscamos la última provisión anterior a la fecha de consulta (CTASEGURO)
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
         SELECT COUNT(*)
           INTO vnum
           FROM ctaseguro
          WHERE sseguro = psseguro
            AND cmovimi = 0
            AND ffecmov = pfecha;

         IF vnum = 0 THEN
            p_datos_ult_saldo(psseguro,   --JRH Ssseguro
                              pfecha, v_fecha_pm_anterior, pm_anterior, pcapgarant,
                              pcapfallant, v_numres);
         ELSE
            p_datos_ult_saldo(psseguro,   --JRH Ssseguro
                              pfecha - 1, v_fecha_pm_anterior, pm_anterior, pcapgarant,
                              pcapfallant, v_numres);
         END IF;

         capfallec := contraseg * pcapfallant;
         vtraza := 2;

         --No hay saldo, estamos en NP
         IF v_fecha_pm_anterior IS NULL THEN
            pm_anterior := 0;
            -- v_fecha_pm_anterior := TRUNC (reg.femisio);
            v_fecha_pm_anterior := LEAST(TRUNC(reg.femisio), reg.fefecto);
            vtraza := 3;

            IF v_tablas IS NULL THEN
               DECLARE
                  a              NUMBER;
               BEGIN
                  SELECT COUNT(*)
                    INTO a
                    FROM ctaseguro
                   WHERE sseguro = psseguro;

                  IF a = 0 THEN
                     v_fecha_pm_anterior := reg.fefecto;
                  END IF;
               END;
            END IF;
         ELSE
            --JRH Buscamos los ultimos saldos parciales para ese último cierre
            vtraza := 4;
            vsaldo_x := obtenersaldos(psseguro, v_numres, 'PROVACX');
            vsaldo_y := obtenersaldos(psseguro, v_numres, 'PROVACY');
            vsaldo_xy := obtenersaldos(psseguro, v_numres, 'PROVACXY');
            vsaldo_risc := obtenersaldos(psseguro, v_numres, 'PROVACR');

            IF (vsaldo_x IS NULL)
               OR(vsaldo_y IS NULL)
               OR(vsaldo_xy IS NULL)
               OR(vsaldo_risc IS NULL) THEN
               RAISE NO_DATA_FOUND;
            END IF;
         END IF;

         fecha := TO_CHAR(v_fecha_pm_anterior, 'YYYYMMDD');

         IF NVL(pctdoscab, 0) = 0 THEN
            vsaldo_y := 0;
            vsaldo_xy := 0;
         END IF;

         IF contraseg = 0 THEN
            vsaldo_risc := 0;
         END IF;

         BEGIN
            vfecdate := TO_DATE(fecha, 'YYYYMMDD');
            vdias := ADD_MONTHS(vfecdate, 1) - vfecdate;
            vfactor2 := ABS((vnummes -(TO_NUMBER(TO_CHAR(vfecdate, 'DD')))) / vdias);
            vfactor1 := ABS(1 - vfactor2);

            IF vfactor1 > 1 THEN
               vfactor1 := 1;
            END IF;

            IF vfactor2 > 1 THEN
               vfactor2 := 1;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               vfactor1 := 1;
               vfactor2 := 0;
         END;

--dbms_output.put_line('obtmes:'||obtmes||' '||vtabestalvi(obtmes).vdx||' '||vtabestalvi(obtmes+1).vdx);
         vfactor1 := 1;
         vfactor2 := 0;
         -- Bug 10336 - 20/09/2009- JRH - CRE - Simular producto de rentas a partir del importe de renta y no de la prima
         vdxi := vfactor1 * vtabestalvi(obtmes).vdx + vfactor2 * vtabestalvi(obtmes + 1).vdx;
         vdyi := vfactor1 * vtabestalvi(obtmes).vdy + vfactor2 * vtabestalvi(obtmes + 1).vdy;
         vdxyi := vfactor1 * vtabestalvi(obtmes).vdxy + vfactor2 * vtabestalvi(obtmes + 1).vdxy;
         vdxi_risc := vfactor1 * vtabriesg(obtmes).vdx + vfactor2 * vtabriesg(obtmes + 1).vdx;
         vdxi_cx := vfactor1 * vtabriesg(obtmes).vcx + vfactor2 * vtabriesg(obtmes + 1).vcx;
         vtraza := 5;

         IF (vdxi IS NULL)
            OR(vdxi_risc IS NULL)
            OR(vdxi_cx IS NULL) THEN
            RAISE NO_DATA_FOUND;
         END IF;

         FOR r_mov IN c_movimientos(psseguro, v_fecha_pm_anterior, pfecha, v_numres) LOOP
            fecha := TO_CHAR(r_mov.ffecmov, 'YYYYMMDD');

            IF r_mov.cmovimi = 1
               AND vsaldo_x = 0 THEN   --Primera Aportación. Buscamos los saldos parciales iniciales.
               vtraza := 6;
               fechaant := fecha;

               SELECT ibruren
                 INTO vrenta
                 FROM seguros_ren
                WHERE sseguro = psseguro;

               IF NVL(vrenta, 0) = 0 THEN
                  vrenta := obtenerminvalor(psseguro, nriesgo);
               END IF;

               vsaldo_x := vrenta *(vtabestalvi(1).vaxnpp / 1);

               --dbms_output.put_line('vRenta:'||vRenta||' vtabestalvi(1).vaxnpp:'||vtabestalvi(1).vaxnpp);
               IF NVL(pctdoscab, 0) <> 0 THEN
                  vsaldo_y := vrenta
                              *(((vtabestalvi(1).vny - vtabestalvi(1).vnyn)
                                 / vtabestalvi(1).vdy)
                                / 1);
                  vsaldo_xy := vrenta
                               *(((vtabestalvi(1).vnxy - vtabestalvi(1).vnxyn)
                                  / vtabestalvi(1).vdxy)
                                 / 1);
                  vsaldo_xy := -vsaldo_xy;
               ELSE
                  vsaldo_y := 0;
                  vsaldo_xy := 0;
                  vsaldo_xy := 0;
               END IF;

               vtraza := 7;

               IF contraseg <> 0 THEN
                  vrenta2 := f_cal_rent(psesion, psseguro, TO_DATE(fecha, 'YYYYMMDD'));   --La ejecutamos para encontrar la fecha de encuentro
                  fecha := TO_CHAR(vfechaencuentro, 'YYYYMMDD');
                  vsaldo_risc := (r_mov.imovimi * NVL(pctfall, 0) * ppj_n1vax_pu
                                  - vrenta * ppj_n1vax_pp)
                                 * vvalorpror;
               ELSE
                  vsaldo_risc := 0;
               END IF;

               capfallec := r_mov.imovimi * vcontraseg2 * contraseg * pctfall;
               fecha := fechaant;
            END IF;

            IF r_mov.cmovimi IN(33, 34, 53) THEN   --Rescates y rentas
               existemov := TRUE;
               vtraza := 9;

               BEGIN
                  vfecdate := TO_DATE(fecha, 'YYYYMMDD');
                  vdias := ADD_MONTHS(vfecdate, 1) - vfecdate;
                  vfactor2 := ABS((vnummes -(TO_NUMBER(TO_CHAR(vfecdate, 'DD')))) / vdias);
                  vfactor1 := ABS(1 - vfactor2);

                  IF vfactor1 > 1 THEN
                     vfactor1 := 1;
                  END IF;

                  IF vfactor2 > 1 THEN
                     vfactor2 := 1;
                  END IF;
               EXCEPTION
                  WHEN OTHERS THEN
                     vfactor1 := 1;
                     vfactor2 := 0;
               END;

               vfactor1 := 1;
               vfactor2 := 0;
               vdxi_act := vfactor1 * vtabestalvi(obtmes).vdx
                           + vfactor2 * vtabestalvi(obtmes + 1).vdx;
               vdyi_act := vfactor1 * vtabestalvi(obtmes).vdy
                           + vfactor2 * vtabestalvi(obtmes + 1).vdy;
               vdxyi_act := vfactor1 * vtabestalvi(obtmes).vdxy
                            + vfactor2 * vtabestalvi(obtmes + 1).vdxy;
               vdxi_risc_act := vfactor1 * vtabriesg(obtmes).vdx
                                + vfactor2 * vtabriesg(obtmes + 1).vdx;
               vdxi_cx_act := vfactor1 * vtabriesg(obtmes).vcx
                              + vfactor2 * vtabriesg(obtmes + 1).vcx;
               --vdxi_act := vtabestalvi(obtmes).vdx;
               --vdyi_act := vtabestalvi(obtmes).vdy;
               --vdxyi_act := vtabestalvi(obtmes).vdxy;
               --vdxi_risc_act := vtabriesg(obtmes).vdx;
               --vdxi_cx_act := vtabriesg(obtmes).vcx;
               vtraza := 10;

               IF (vdxi_act IS NULL)
                  OR(vdxi_risc_act IS NULL)
                  OR(vdxi_cx_act IS NULL) THEN
                  RAISE NO_DATA_FOUND;
               END IF;

               vsaldo_x :=(vsaldo_x *(vdxi / vdxi_act) + r_mov.imovimi);
               vtraza := 11;

               IF NVL(pctdoscab, 0) <> 0 THEN
                  vsaldo_y :=(vsaldo_y *(vdyi / vdyi_act) + r_mov.imovimi);
                  vsaldo_xy :=(vsaldo_xy *(vdxyi / vdxyi_act) - r_mov.imovimi);
               END IF;

               vtraza := 12;

               IF contraseg <> 0 THEN
                  vsaldo_risc := (vsaldo_risc - capfallec *(vdxi_cx / vdxi_risc))
                                 *(vdxi_risc / vdxi_risc_act);
               END IF;

               capfallec := capfallec + r_mov.imovimi * vcontraseg2 * contraseg;
               vtraza := 14;
--   dbms_output.put_line('vdxi:'||vdxi);
--      dbms_output.put_line('vdyi:'||vdyi);
  --       dbms_output.put_line('vdxyi:'||vdxyi);
 --  dbms_output.put_line('vdxi_act:'||vdxi_act);
 --  dbms_output.put_line(' (vdxi / vdxi_act) :'||TO_CHAR (vdxi / vdxi_act) );

               --dbms_output.put_line('vsaldo_x:'||vsaldo_x);
--dbms_output.put_line('vsaldo_y:'||vsaldo_y);
--dbms_output.put_line('vsaldo_xy:'||vsaldo_xy);
--dbms_output.put_line('vsaldo_risc:'||vsaldo_risc);
--dbms_output.put_line('despr:'||despr);
--dbms_output.put_line('despe:'||despe);
--dbms_output.put_line('geee:'||geee);
               vsaldo := (((vsaldo_x + vsaldo_y + vsaldo_xy) /(1 -(despe / 100) -(geee / 100)))
                          +(vsaldo_risc /(1 -(despr / 100) -(geee / 100))))
                         *(1 - geee / 100);
               -- dbms_output.put_line('vsaldo:'||vsaldo);

               --dbms_output.put_line('vsaldo_x:'||vsaldo_x||' vsaldo:'||vsaldo);
               vtraza := 15;
               --Actualizamos los nuevos valores
               vdxi := vdxi_act;
               vdyi := vdyi_act;
               vdxyi := vdxyi_act;
               vdxi_risc := vdxi_risc_act;
               vdxi_cx := vdxi_cx_act;
            END IF;
         END LOOP;
      END LOOP;

      IF (NOT existemov)
         OR(TO_NUMBER(TO_CHAR(pfecha, 'YYYYMM')) >
                                       TO_NUMBER(TO_CHAR(TO_DATE(fecha, 'YYYYMMDD'), 'YYYYMM'))) THEN
         fecha := TO_CHAR(pfecha, 'YYYYMMDD');

         BEGIN
            vfecdate := TO_DATE(fecha, 'YYYYMMDD');
            vdias := ADD_MONTHS(vfecdate, 1) - vfecdate;
            vfactor2 := ABS(((TO_NUMBER(TO_CHAR(vfecdate, 'DD')))) / vdias);
            vfactor2 := ABS((vnummes -(TO_NUMBER(TO_CHAR(vfecdate, 'DD')))) / vdias);
            vfactor1 := ABS(1 - vfactor2);

            IF vfactor1 > 1 THEN
               vfactor1 := 1;
            END IF;

            IF vfactor2 > 1 THEN
               vfactor2 := 1;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               vfactor1 := 1;
               vfactor2 := 0;
         END;

         vdxi_act := vfactor1 * vtabestalvi(obtmes).vdx
                     + vfactor2 * vtabestalvi(obtmes + 1).vdx;
         vdyi_act := vfactor1 * vtabestalvi(obtmes).vdy
                     + vfactor2 * vtabestalvi(obtmes + 1).vdy;
         vdxyi_act := vfactor1 * vtabestalvi(obtmes).vdxy
                      + vfactor2 * vtabestalvi(obtmes + 1).vdxy;
         vdxi_risc_act := vfactor1 * vtabriesg(obtmes).vdx
                          + vfactor2 * vtabriesg(obtmes + 1).vdx;
         vdxi_cx_act := vfactor1 * vtabriesg(obtmes).vcx + vfactor2 * vtabriesg(obtmes + 1).vcx;
         -- dbms_output.put_line('vdxi_act:'||vdxi_act);
         vsaldo_x :=(vsaldo_x *(vdxi / vdxi_act) + 0);
         vtraza := 11;

         IF NVL(pctdoscab, 0) <> 0 THEN
            vsaldo_y :=(vsaldo_y *(vdyi / vdyi_act) + 0);
            vsaldo_xy :=(vsaldo_xy *(vdxyi / vdxyi_act) - 0);
         END IF;

         vtraza := 12;

         IF contraseg <> 0 THEN
            vsaldo_risc := (vsaldo_risc - capfallec *(vdxi_cx / vdxi_risc))
                           *(vdxi_risc / vdxi_risc_act);
         END IF;

         capfallec := capfallec + 0 * vcontraseg2 * contraseg;
         vsaldo := (((vsaldo_x + vsaldo_y + vsaldo_xy) /(1 -(despe / 100) -(geee / 100)))
                    +(vsaldo_risc /(1 -(despr / 100) -(geee / 100))))
                   *(1 - geee / 100);
      END IF;

-- fi Bug 10336 - 20/09/2009- JRH
      IF pfonprov = 0 THEN
         pm := vsaldo_x;
      ELSIF pfonprov = 1 THEN
         pm := vsaldo_y;
      ELSIF pfonprov = 2 THEN
         pm := vsaldo_xy;
      ELSIF pfonprov = 3 THEN
         pm := vsaldo_risc;
      ELSIF pfonprov = 4 THEN
         pm := vsaldo;
      ELSIF pfonprov = 5 THEN
         pm := capfallec;
      ELSIF pfonprov = 6 THEN
         pm := 0;   -- De momento
      ELSE
         pm := NULL;
      END IF;

      vtraza := 20;
      RETURN pm;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_calc_prov_rf.f_calculo_provision:' || psseguro,
                     vtraza, 'Error:' || SQLERRM, 'AAAA');
         RETURN NULL;
   END f_cal_prov;
END pac_calc_prov_rf;

/

  GRANT EXECUTE ON "AXIS"."PAC_CALC_PROV_RF" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CALC_PROV_RF" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CALC_PROV_RF" TO "PROGRAMADORESCSI";
