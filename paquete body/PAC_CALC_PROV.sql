--------------------------------------------------------
--  DDL for Package Body PAC_CALC_PROV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_CALC_PROV" IS
   /******************************************************************************
    NOMBRE:     PAC_CALC_PROV
    PROPÓSITO:  Funciones calculo provisiones

    REVISIONES:
    Ver        Fecha     Autor    Descripción
    ------  ----------  --------  ------------------------------------
    1.0     XX/XX/XXXX   XXX      1. Creación del package.
    1.1     30/01/2009   JRH      2. Bug-8782 Revisión cálculo capital garantizado en productos de Ahorro
    1.2     01/03/2009   JRH      3. Bug-8763 Simulaciones PPJ
    1.3     01/03/2009   JRH      4. Bug-9569 CRE - Càlcul capital de mort amb cost de pensió
    1.4     01/04/2009   JRH      5. Bug-9752 CRE - Corregir càlcul provisió
    1.5     27/03/2009   APD      6. Bug 9446 (precisiones var numericas)
    1.6     28/04/2009   JRH      7. Bug 9889 Cuadre de los datos del cierre de ABRIL
    1.7     01/05/2009   JRH      8. Bug 9172: CRE055 - Rentas regulares e irregulares con cálculos a partir de renta
    1.8     17/04/2009   APD      9. Bug 9685 - en lugar de coger la actividad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
    1.9     01/08/2009   NMM     10. Bug 10864: CEM - Tasa aplicable en Consorcio.
    2.0     09/12/2009   APD     11. Bug 11896 - se sustituye el TIPO = 6 por 13
    3.0     01/06/2010   JRH     12. Buf 14787: CRE802 - revisión PMAT cartera CaixaBank
    4.0     12/07/2010   JRH     13. Bug 0015510: CRE - Desviació de la provisió quan es fan rescats parcials
    5.0     16/09/2010   ICV     14. Bug 0015874: CRE802 - Pòlissa PPJ Garantit que no cálcula saldo en els tancaments
    6.0     28/11/2011   JMP     15. Bug 0018423: LCOL000 - Multimoneda
    7.0     29/11/2011   FAL     16. Bug 0020314: GIP003 - Modificar el cálculo del Selo
    8.0     01/03/2013   NMM     17. 26264: CRE800-CRE - Error càlcul capital garantit en suplements
   ******************************************************************************/
   gsesion        NUMBER;
   giii           NUMBER;
   geee           NUMBER;
   isi            NUMBER;
   ptipoint       NUMBER;
   sexo           NUMBER;
   fecefe         NUMBER;
   fec_vto        NUMBER;
   fec_vtom       NUMBER;   --Para la pensión
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
   varv_pensio1_pp NUMBER;
   varv_pensio2_pp NUMBER;
   varfactorpensio NUMBER;
   vfactorriesgopu NUMBER;   -- BUG 8763 - 03/2009 - JRH  - 0008763: CRE - Simulaciones PPJ
   vtipogarant    pargaranpro.cvalpar%TYPE := 5;   -- BUG 8763 - 03/2009 - JRH  - 0008763: CRE - Simulaciones PPJ
   --pctipefe number;
   resp1021       NUMBER;
   resp1022       NUMBER;
   resp1023       NUMBER;
   resp1024       NUMBER;
   resp1027       NUMBER;
   vcrevali       NUMBER;
   virevali       NUMBER;
   vprevali       NUMBER;
   cactividad     NUMBER;
   tablamortrisc  NUMBER;
   tablamortestalvi NUMBER;
   reemb          NUMBER := 0;
   factreemb      NUMBER := 1;
   capitprim      NUMBER := 1;
   fecefecparareval NUMBER;
   fecrefreval    NUMBER;
   importebase    NUMBER;
   mesefecto      NUMBER;
   mesact         NUMBER;
   recfracc       NUMBER := 0;
   gastcapitalini NUMBER := 0;
   gastosintporcapital NUMBER := 0;
   ultfec         NUMBER;
   vcorrecprovini NUMBER;   -- BUG 9569 - 03/2009 - JRH  - Càlcul capital de mort amb cost de pensió.
   -- BUG 9889 - 04/2009 - JRH  - Cuadre de los datos del cierre de ABRIL
   vtabriesg      t_conmutador;
   vtabestalvi    t_conmutador;

   /*************************************************************************
      Valor de la cobertura Capital Garan a la fecha. En algún producto nos puede ser util, si
      siempre coincide con el valor real de capital garantizado.
      param in psseguro  : número de seguro
      param in pnriesgo  : número de riesgo
      param in parfecha     : Fecha
      return             : El capital
   *************************************************************************/
   FUNCTION ultvalorcapgaran(pseguro IN NUMBER, priesgo IN NUMBER, parfecha DATE)
      RETURN NUMBER IS
      -- Bug 9685 - APD - 21/05/2009 - en lugar de coger la actividad de la tabla seguros,
      -- llamar a la función pac_seguros.ff_get_actividad
      CURSOR tablasseg IS
         SELECT   gar.icapital
             FROM seguros s, garanseg gar
            WHERE s.sseguro = pseguro
              AND gar.sseguro = s.sseguro
              AND gar.nriesgo = NVL(priesgo, 1)
              AND f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect,
                                  pac_seguros.ff_get_actividad(s.sseguro, gar.nriesgo),
                                  gar.cgarant, 'TIPO') = 5   -- Cap Garan
              AND finiefe <= parfecha
         ORDER BY nmovimi DESC, finiefe DESC;

      -- Bug 9685 - APD - 21/05/2009 - fin
      capgar         garanseg.icapital%TYPE;   --NUMBER(14, 3);
   BEGIN
      OPEN tablasseg;

      FETCH tablasseg
       INTO capgar;

      CLOSE tablasseg;

      RETURN capgar;
   EXCEPTION
      WHEN OTHERS THEN
         -- BUG -21546_108724- 07/02/2012 - JLTS - Cierre de posibles cursores abiertos
         IF tablasseg%ISOPEN THEN
            CLOSE tablasseg;
         END IF;

         RETURN NULL;
   END ultvalorcapgaran;

   /*************************************************************************
       Buscamos la prima base. Para ello miramos el ultimo suplemento de cambio de prima periodica, si no existe miramos
       la pregunta 1025 para las pólizas de migración, sino el movimiento 1 y sino la pregunta 1001.
       Lo necesitamos para el calculo de % Reva lineal (irevali*100/ibase), y de paso pues para aplicar y simular la progresión
       en el paso del tiempo (partimos del ibase). Obtenemos también la fecha del suplemento.
       Buscamos el ultimo valor, suponemos que el mes está bien cerrado..
       En las tablas EST miramos si estamos ahora en un suplemento de cambio de prima.

        param in psseguro  : número de seguro
        param in pnriesgo  : número de riesgo
        param out importeprimper     : Importe
        return             : La fecha en un numero
     *************************************************************************/
   FUNCTION fechaultcambprima(
      psesion NUMBER,
      pseguro IN NUMBER,
      priesgo IN NUMBER,
      importeprimper OUT NUMBER)
      RETURN NUMBER IS
      fechaultcamb   DATE;
      vnmovimi       movseguro.nmovimi%TYPE;   --NUMBER(10);
      vssegpol       estseguros.ssegpol%TYPE;   --NUMBER(10);
      seguroini      estseguros.ssegpol%TYPE;   --NUMBER(10);
      importeprimperpreg NUMBER;

      -- Bug 9685 - APD - 21/05/2009 - en lugar de coger la actividad de la tabla seguros,
      -- llamar a la función pac_seguros.ff_get_actividad
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
              AND f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect,
                                  pac_seguros.ff_get_actividad(s.sseguro, NVL(priesgo, 1)),
                                  det1.cgarant, 'TIPO') = 3   -- PRIMA AHORRO
              AND NOT EXISTS(SELECT 1
                               FROM detmovseguro det2
                              WHERE det2.sseguro = det1.sseguro
                                AND det2.cmotmov IN(266, 276)
                                AND det2.nmovimi = det1.nmovimi
                                AND det2.nriesgo = det1.nriesgo)   --Que no sea una suspensión.
         ORDER BY 2 DESC;

      -- Bug 9685 - APD - 21/05/2009 - fin

      -- Bug 9685 - APD - 21/05/2009 - en lugar de coger la actividad de la tabla seguros,
      -- llamar a la función pac_seguros.ff_get_actividad
      CURSOR tablasest IS
         SELECT   s.fefecto
             INTO fechaultcamb
             FROM estseguros s, estdetmovseguro det1
            WHERE s.sseguro = pseguro
              AND s.sseguro = det1.sseguro
              AND det1.cmotmov = 281
              AND det1.nriesgo = NVL(priesgo, 1)
              AND f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect,
                                  pac_seguros.ff_get_actividad(s.sseguro, NVL(priesgo, 1),
                                                               'EST'),
                                  det1.cgarant, 'TIPO') = 3   -- PRIMA AHORRO
              AND NOT EXISTS(SELECT 1
                               FROM estdetmovseguro det2
                              WHERE det2.sseguro = det1.sseguro
                                AND det2.cmotmov IN(266, 276)
                                AND det2.nmovimi = det1.nmovimi
                                AND det2.nriesgo = det1.nriesgo)
         ORDER BY 1 DESC;
   -- Bug 9685 - APD - 21/05/2009 - fin
   BEGIN
      importeprimper := NULL;
      importeprimperpreg := NVL(resp(gsesion, 1025), 0);   --Migración
      fechaultcamb := NULL;
      vnmovimi := NULL;

      --Si estamos en un suplemento
      OPEN tablasest;

      FETCH tablasest
       INTO fechaultcamb;

      IF tablasest%FOUND THEN
         --Buscamos el valor de la prima para esa fecha
         BEGIN
            -- Bug 9685 - APD - 21/05/2009 - en lugar de coger la actividad de la tabla seguros,
            -- llamar a la función pac_seguros.ff_get_actividad
            SELECT estgaranseg.icapital, s.ssegpol
              INTO importeprimper, vssegpol
              FROM estseguros s, estgaranseg
             WHERE s.sseguro = pseguro
               AND estgaranseg.sseguro = s.sseguro
               AND estgaranseg.nriesgo = NVL(priesgo, 1)
               AND f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect,
                                   pac_seguros.ff_get_actividad(s.sseguro, NVL(priesgo, 1),
                                                                'EST'),
                                   estgaranseg.cgarant, 'TIPO') = 3;   -- PRIMA AHORRO
         -- Bug 9685 - APD - 21/05/2009 - fin
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
            -- Bug 9685 - APD - 21/05/2009 - en lugar de coger la actividad de la tabla seguros,
            -- llamar a la función pac_seguros.ff_get_actividad
            SELECT icapital
              INTO importeprimper
              FROM seguros s, garanseg
             WHERE s.sseguro = seguroini
               AND garanseg.sseguro = s.sseguro
               AND garanseg.nriesgo = NVL(priesgo, 1)
               AND garanseg.nmovimi = vnmovimi
               AND f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect,
                                   pac_seguros.ff_get_actividad(s.sseguro, NVL(priesgo, 1)),
                                   garanseg.cgarant, 'TIPO') = 3;   -- PRIMA AHORRO
         -- Bug 9685 - APD - 21/05/2009 - fin
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
               -- Bug 9685 - APD - 21/05/2009 - en lugar de coger la actividad de la tabla seguros,
               -- llamar a la función pac_seguros.ff_get_actividad
               SELECT icapital
                 INTO importeprimper   --Cogemos el de la nmovimi=1
                 FROM seguros s, garanseg
                WHERE s.sseguro = seguroini
                  AND garanseg.sseguro = s.sseguro
                  AND garanseg.nriesgo = NVL(priesgo, 1)
                  AND garanseg.nmovimi = 1
                  AND f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect,
                                      pac_seguros.ff_get_actividad(s.sseguro, NVL(priesgo, 1)),
                                      garanseg.cgarant, 'TIPO') = 3;   -- PRIMA AHORRO
            -- Bug 9685 - APD - 21/05/2009 - fin
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  importeprimper := NVL(resp(gsesion, 1001), 0);   --La pregunta 1001 (Estmaos en una NP).
            END;
         END IF;
      END IF;

      CLOSE tablasseg;

      RETURN TO_CHAR(fechaultcamb, 'YYYYMMDD');
   EXCEPTION
      WHEN OTHERS THEN
         -- BUG -21546_108724- 07/02/2012 - JLTS - Cierre de posibles cursores abiertos
         IF tablasest%ISOPEN THEN
            CLOSE tablasest;
         END IF;

         IF tablasseg%ISOPEN THEN
            CLOSE tablasseg;
         END IF;

         RETURN NULL;
   END fechaultcambprima;

   FUNCTION anyos_fefecto_hasta_fecha2
      RETURN NUMBER IS
      valor          NUMBER;
   BEGIN
      valor := (ROUND(((TO_DATE(fecha, 'YYYYMMDD')
                        - TO_DATE((TO_NUMBER(SUBSTR(TO_CHAR(fecrefreval), 0, 6) * 100) + 1),
                                  'YYYYMMDD'))
                       / 365.5)
                      * 12,
                      0)
                - 0)
               / 12;
      RETURN valor;
   END anyos_fefecto_hasta_fecha2;

   FUNCTION fedad_aseg_efec
      RETURN NUMBER IS
      valor          NUMBER;
   BEGIN
      valor := ROUND(((TO_DATE(fecefe, 'YYYYMMDD') - TO_DATE(fnacimi, 'YYYYMMDD')) / 365.25)
                     * 12 * 2,
                     0)
               / 24;
      RETURN valor;
   END fedad_aseg_efec;

   FUNCTION fedad_aseg
      RETURN NUMBER IS
      valor          NUMBER;
   BEGIN
      valor := ROUND(((TO_DATE(fecha, 'YYYYMMDD') - TO_DATE(fnacimi, 'YYYYMMDD')) / 365.25)
                     * 2 * 12,
                     0)
               / 24;
      RETURN valor;
   END fedad_aseg;

   FUNCTION anyos_hasta_vencim_fecha
      RETURN NUMBER IS
      valor          NUMBER;
      valor2         NUMBER := 0;
   BEGIN
      valor := ROUND(((TO_DATE(fec_vto, 'YYYYMMDD') - TO_DATE(fnacimi, 'YYYYMMDD')) / 365.25)
                     * 2 * 12,
                     0)
               / 24;
      valor2 := ROUND(((TO_DATE(fecha, 'YYYYMMDD') - TO_DATE(fnacimi, 'YYYYMMDD')) / 365.25)
                      * 2 * 12,
                      0)
                / 24;
      /*valor := (ROUND(((TO_DATE(((TO_NUMBER(SUBSTR(TO_CHAR(fec_vto), 0, 6)) * 100) + 1),
                                'YYYYMMDD')
                        - TO_DATE(fecha, 'YYYYMMDD'))
                       / 365.25)
                      * 12,
                      0)
                - 0)
               / 12;*/
      --RETURN valor - NVL(valor2, 0) -(1 / 12);
      RETURN (FLOOR(12 * valor - 12 * NVL(valor2, 0)) - 1) / 12;
   END anyos_hasta_vencim_fecha;

   FUNCTION anyos_fefecto_hasta_fecha
      RETURN NUMBER IS
      valor          NUMBER;
   BEGIN
      valor := (ROUND(((TO_DATE(fecha, 'YYYYMMDD')
                        - TO_DATE((TO_NUMBER(SUBSTR(TO_CHAR(fecefe), 0, 6) * 100) + 1),
                                  'YYYYMMDD'))
                       / 365.25)
                      * 12,
                      0)
                - 0)
               / 12;
      RETURN valor;
   END anyos_fefecto_hasta_fecha;

   FUNCTION anyos_fefecto_hasta_fecvto
      RETURN NUMBER IS
      valor          NUMBER;
      valor2         NUMBER := 0;
   BEGIN
      /*valor := (ROUND(((TO_DATE(fec_vto, 'YYYYMMDD')
                        - TO_DATE((TO_NUMBER(SUBSTR(TO_CHAR(fecefe), 0, 6) * 100) + 1),
                                  'YYYYMMDD'))
                       / 365.25)
                      * 12,
                      0)
                - 0)
               / 12;*/
      valor := ROUND(((TO_DATE(fec_vto, 'YYYYMMDD') - TO_DATE(fnacimi, 'YYYYMMDD')) / 365.25)
                     * 2 * 12,
                     0)
               / 24;
      valor2 := ROUND(((TO_DATE(fecefe, 'YYYYMMDD') - TO_DATE(fnacimi, 'YYYYMMDD')) / 365.25)
                      * 2 * 12,
                      0)
                / 24;
      -- RETURN valor - NVL(valor2, 0) -(0);
      RETURN (CEIL(12 * valor - 12 * NVL(valor2, 0)) - 0) / 12;
   END anyos_fefecto_hasta_fecvto;

   /*************************************************************************
    Función Para el coste pensión.
    ****/
   FUNCTION anyos_fefecto_h_fecvto_pens
      RETURN NUMBER IS
      valor          NUMBER;
      valor2         NUMBER := 0;
   BEGIN
      /*valor := (ROUND(((TO_DATE(fec_vto, 'YYYYMMDD')
                        - TO_DATE((TO_NUMBER(SUBSTR(TO_CHAR(fecefe), 0, 6) * 100) + 1),
                                  'YYYYMMDD'))
                       / 365.25)
                      * 12,
                      0)
                - 0)
               / 12;*/
      valor := ROUND(((TO_DATE(fec_vtom, 'YYYYMMDD') - TO_DATE(fnacimi, 'YYYYMMDD')) / 365.25)
                     * 2 * 12,
                     0)
               / 24;
      valor2 := ROUND(((TO_DATE(fecefe, 'YYYYMMDD') - TO_DATE(fnacimi, 'YYYYMMDD')) / 365.25)
                      * 2 * 12,
                      0)
                / 24;
      -- RETURN valor - NVL(valor2, 0) -(0);
      RETURN (FLOOR(12 * valor - 12 * NVL(valor2, 0)) - 0) / 12;
   END anyos_fefecto_h_fecvto_pens;

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

   --Como esta funcion ppj_vaxn_pp  de momento ya no la utilizamos en el calculo del saldo a partir de CTASEGURO (solo usamos las pu que no contienen la progresión en su llamada)
   --ni en ningún tipo de suplemento (solo en nueva producción) no hemos de tener en cuenta una posible fecha de
   --cambio de prima periodica para que nos tenga en cuenta correctamente la nueva (el nuevo cambio de) progresion a partir de esa fecha (lo tendriamos que hacer cambiando el fedad_aseg_efec y que la referencia fuera no
   --la fecha efecto sino la fecha del último cambio de prima periodica).
   FUNCTION ppj_vaxn_pp
      RETURN NUMBER IS
      valor          NUMBER;
   BEGIN
      RETURN vtabriesg(obtmes).vaxnpp;
   END ppj_vaxn_pp;

   --Como esta funcion ppj_n1vax_pp  de momento ya no la utilizamos en el calculo del saldo a partir de CTASEGURO (solo usamos las pu que no contienen la progresión en su llamada)
   --ni en ningún tipo de suplemento (solo en nueva producción) no hemos de tener en cuenta una posible fecha de
   --cambio de prima periodica para que nos tenga en cuenta correctamente la nueva (el nuevo cambio de) progresion a partir de esa fecha (lo tendriamos que hacer cambiando el fedad_aseg_efec y que la referencia fuera no
   --la fecha efecto sino la fecha del último cambio de prima periodica).
   FUNCTION ppj_n1vax_pp
      RETURN NUMBER IS
      valor          NUMBER;
   BEGIN
      IF resp1021 = 0 THEN
         RETURN 0;
      END IF;

      RETURN vtabestalvi(obtmes).n_vaxpp;
   END ppj_n1vax_pp;

   --Como esta funcion ppj_1nvax_pp  de momento ya no la utilizamos en el calculo del saldo a partir de CTASEGURO (solo usamos las pu que no contienen la progresión en su llamada)
   --ni en ningún tipo de suplemento (solo en nueva producción) no hemos de tener en cuenta una posible fecha de
   --cambio de prima periodica para que nos tenga en cuenta correctamente la nueva (el nuevo cambio de) progresion a partir de esa fecha (lo tendriamos que hacer cambiando el fedad_aseg_efec y que la referencia fuera no
   --la fecha efecto sino la fecha del último cambio de prima periodica).
   FUNCTION ppj_1nvax_pp
      RETURN NUMBER IS
      a              NUMBER;
      b              NUMBER;
      c              NUMBER;
      valor          NUMBER;
      mesini         NUMBER;
   BEGIN
      IF resp1022 = 0 THEN
         RETURN 0;
      END IF;

      RETURN vtabestalvi(obtmes).l_nvaxpp;
   /*
   IF pac_frm_actuarial.pctipefe(gsesion) = 0 THEN
      mesini := 1;
   ELSE
      mesini := TO_NUMBER(SUBSTR(fecefe, 5, 2));
   END IF;

   a := pac_frm_actuarial.ff_progacumnat(gsesion, resp1004,   --NVL (resp (gsesion, 1004), 0),
                                         resp1003,   --NVL (resp (gsesion, 1003), 0),
                                         (12 * anyos_hasta_vencim_fecha - 1) / 12, mesini,
                                         1);
   b := pac_frm_actuarial.ff_aprog2(gsesion, tablamortestalvi,   --10,
                                    sexo, fedad_aseg + anyos_hasta_vencim_fecha, 0,
                                    (1 /(1 + ptipoint / 100)), NULL, NULL, 1,
                                    fedad_aseg_efec,   --
                                    --fedad_aseg,
                                    1, FALSE);
   c := pac_frm_actuarial.ff_aprog2(gsesion, tablamortestalvi,   --10,
                                    sexo, fedad_aseg_efec,
                                    anyos_fefecto_hasta_fecha -(1 / 12),
                                    (1 /(1 + ptipoint / 100)), NULL, NULL, 1,
                                    fedad_aseg_efec,   --
                                    --fedad_aseg,
                                    1, FALSE);
   valor := a *(b - NVL(c, 0));
   RETURN valor;*/
   END ppj_1nvax_pp;

   FUNCTION ppj_n1vax_pu
      RETURN NUMBER IS
      valor          NUMBER;
      -- BUG 9889 - 04/2009 - JRH  - Cuadre de los datos del cierre de ABRIL
      vf1            NUMBER;
      vf2            NUMBER;
      vmesesi        NUMBER;
      vmesesfi       NUMBER;
   BEGIN
      IF resp1021 = 0 THEN
         RETURN 0;
      END IF;

      --dbms_output.put_line(obtabEstalvi.n_vaxpu||'    '||obtabEstalvi.l_nvaxpu);
      RETURN vtabestalvi(obtmes).n_vaxpu;
   END ppj_n1vax_pu;

   FUNCTION ppj_1nvax_pu
      RETURN NUMBER IS
      valor          NUMBER;
      -- BUG 9889 - 04/2009 - JRH  - Cuadre de los datos del cierre de ABRIL
      vf1            NUMBER;
      vf2            NUMBER;
      vf3            NUMBER;
      vmesesi        NUMBER;
      vmesesfi       NUMBER;
      vmesesfi2      NUMBER;
   BEGIN
      IF resp1022 = 0 THEN
         RETURN 0;
      END IF;

      RETURN vtabestalvi(obtmes).l_nvaxpu;
   END ppj_1nvax_pu;

   FUNCTION ppj_vaxn_pu
      RETURN NUMBER IS
   BEGIN
      RETURN 1;
   END ppj_vaxn_pu;

   FUNCTION ppj_exincre
      RETURN NUMBER IS
      valor          NUMBER;
   BEGIN
      --dbms_output.put_line(obtabRiesg.vexn1);
      RETURN vtabriesg(obtmes).vexn1;
   END ppj_exincre;

   FUNCTION ppj_exincre_fijo
      RETURN NUMBER IS
      valor          NUMBER;
   BEGIN
      RETURN vtabriesg(obtmes).vdxn1 / vtabriesg(1).vdx;
   END ppj_exincre_fijo;

   /*************************************************************************
    Función Para el coste pensión.
    ****/
   FUNCTION factorpensio
      RETURN NUMBER IS
      valor          NUMBER := 0;
   BEGIN
      IF vtabriesg(obtmes).vdxn <> 0 THEN
         RETURN NVL(vtabriesg(obtmes).vdxn1 / vtabriesg(obtmes).vdxn, 0);
      ELSE
         RETURN 0;
      END IF;
   END factorpensio;

   /*************************************************************************
    Función Para el coste pensión.
    ****/
   FUNCTION v_pensio1_pu
      RETURN NUMBER IS
      valor          NUMBER := 0;
   BEGIN
      IF resp1023 = 0 THEN
         RETURN 0;
      END IF;

      --return tabEstalvi(ObtMes).Axtkpu;
      --dbms_output.put_line('factorpensio:'||factorpensio|| 'tabEstalvi(ObtMes).vmx:'||tabEstalvi(ObtMes).vmx);
      RETURN factorpensio * vtabestalvi(obtmes).axtkpu;
   END v_pensio1_pu;

   /*************************************************************************
    Función Para el coste pensión.
    ****/
   FUNCTION v_pensio2_pu
      RETURN NUMBER IS
      valor          NUMBER := 0;
      duracion       NUMBER;
   BEGIN
      IF resp1024 = 0 THEN
         RETURN 0;
      END IF;

      RETURN factorpensio * vtabestalvi(obtmes).axtnkpu;
   END v_pensio2_pu;

   /*************************************************************************
    Función Para el coste pensión.
    ****/
   FUNCTION v_pensio1_pp
      RETURN NUMBER IS
      valor          NUMBER := 0;
   BEGIN
      IF resp1023 = 0 THEN
         RETURN 0;
      END IF;

      RETURN factorpensio * vtabestalvi(obtmes).axtkpp;
   -- if varv_pensio1_pp is null then  -- si no está calculada la calculamos, no hemos de repetir el proceso
   END v_pensio1_pp;

   /*************************************************************************
    Función Para el coste pensión.
    ****/
   FUNCTION v_pensio2_pp
      RETURN NUMBER IS
      valor          NUMBER := 0;
      duracion       NUMBER := 0;
   BEGIN
      IF resp1024 = 0 THEN
         RETURN 0;
      END IF;

      RETURN factorpensio * vtabestalvi(obtmes).axtnkpp;
   END v_pensio2_pp;

   FUNCTION progresion2   --Dede la fecha de efecto
      RETURN NUMBER IS
      valor          NUMBER;
      mesini         NUMBER;
   BEGIN
      IF pac_frm_actuarial.pctipefe(gsesion) = 0 THEN
         mesini := 1;
      ELSE
         mesini := TO_NUMBER(SUBSTR(fecefe, 5, 2));
      END IF;

      valor := pac_frm_actuarial.ff_progresionnat(gsesion, NVL(resp1004, 0), NVL(resp1003, 0),
                                                  (12 * anyos_fefecto_hasta_fecha2
                                                                                  --  - 1 --(para que cambie en el mes correcto)
                                                  ) / 12, mesini, 1);

      IF valor = 0 THEN
         valor := 1;
      END IF;

      RETURN valor;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 1;
   END progresion2;

   FUNCTION progresion
      RETURN NUMBER IS
      valor          NUMBER;
   BEGIN
      --valor := progresion2 / progresion3;   --Encontramos la proporcion para sacar la prima en fecha a partir de la prima actual (no la original)
      valor := progresion2;
      RETURN valor;
   END progresion;

/*************************************************************************

      Calcula la CorrecFactProv



    *************************************************************************/
   FUNCTION correcfactprov   -- BUG 9569 - 03/2009 - JRH  - Càlcul capital de mort amb cost de pensió.
      RETURN NUMBER IS
      valor          NUMBER;
      ulfecha        NUMBER;
   BEGIN
      ulfecha := fecha;
      fecha := (ROUND(fecha / 100, 0) * 100) + 1;

      IF vtabriesg(obtmes).vdx <> 0 THEN
         valor := (vtabriesg(obtmes).vnnx - vtabriesg(obtmes).vnnxn1) / vtabriesg(obtmes).vdx;
      ELSE
         valor := 1;
      END IF;

      IF valor < 0 THEN
         valor := 1;
      END IF;

      fecha := ulfecha;
      RETURN valor;
   END correcfactprov;

   FUNCTION capital_garan_ppj_pu
      RETURN NUMBER IS
      valor          NUMBER;
      v_vaxn         NUMBER;
      v_1nvax        NUMBER;
      v_n1vax        NUMBER;
      v_exincre      NUMBER;
      -- BUG 8782 - 02/2009 - JRH  - Variables para el coste de la pensión
      v_p1_pu        NUMBER;
      v_p2_pu        NUMBER;
   BEGIN
      -- fi  BUG 9889
      v_vaxn := ppj_vaxn_pu;
      v_1nvax := ppj_1nvax_pu;
      v_n1vax := ppj_n1vax_pu;
      v_exincre := ppj_exincre;
      -- BUG 8782 - 02/2009 - JRH  - Variables para el coste de la pensión
      v_p1_pu := v_pensio1_pu;
      v_p2_pu := v_pensio2_pu;
      valor := (v_vaxn
                - ((v_n1vax * 1) +(v_1nvax * 1)) /(1 -(giii / 100) -(geee / 100)) *(1 +(isi)))
               /(v_exincre /(1 -(giii / 100) -(geee / 100))
                 + (v_p1_pu + v_p2_pu) /(1 -(giii / 100) -(geee / 100)) *(1 +(isi)));
      valor := valor /(1 +(recfracc / 100));
      valor := valor /(1 +(gastcapitalini));
      valor := valor * resp1027 / 100;
      RETURN valor;
   END capital_garan_ppj_pu;

   FUNCTION capital_garan_ppj_pb
      RETURN NUMBER IS
      valor          NUMBER;
      v_vaxn         NUMBER;
      v_1nvax        NUMBER;
      v_n1vax        NUMBER;
      v_exincre      NUMBER;
      -- BUG 8782 - 02/2009 - JRH  - Variables para el coste de la pensión
      v_p1_pu        NUMBER;
      v_p2_pu        NUMBER;
   BEGIN
      v_vaxn := ppj_vaxn_pu;
      v_1nvax := ppj_1nvax_pu;
      v_n1vax := ppj_n1vax_pu;
      v_exincre := ppj_exincre;
      -- BUG 8782 - 02/2009 - JRH  - Variables para el coste de la pensión
      v_p1_pu := v_pensio1_pu;
      v_p2_pu := v_pensio2_pu;
      valor := (v_vaxn - ((v_n1vax * 1) +(v_1nvax * 1)) /(1 -(giii / 100) -(0 / 100))
                         *(1 +(0)))
               /(v_exincre /(1 -(giii / 100) -(0 / 100))
                 + (v_p1_pu + v_p2_pu) /(1 -(giii / 100) -(0 / 100)) *(1 +(0)));
      valor := valor /(1 +(recfracc / 100));
      valor := valor /(1 +(gastcapitalini));
      valor := valor * resp1027 / 100;
      RETURN valor;
   END capital_garan_ppj_pb;

   FUNCTION capital_garan_ppj_pp
      RETURN NUMBER IS
      valor          NUMBER;
      v_vaxn         NUMBER;
      v_1nvax        NUMBER;
      v_n1vax        NUMBER;
      v_exincre      NUMBER;
      gastcapital    NUMBER;
      -- BUG 8782 - 02/2009 - JRH  - Variables para el coste de la pensión
      v_p1_pp        NUMBER;
      v_p2_pp        NUMBER;
   BEGIN
      v_vaxn := ppj_vaxn_pp;
      v_1nvax := ppj_1nvax_pp;
      v_n1vax := ppj_n1vax_pp;
      v_exincre := ppj_exincre_fijo;
      -- BUG 8782 - 02/2009 - JRH  - Variables para el coste de la pensión
      v_p1_pp := v_pensio1_pp;
      v_p2_pp := v_pensio2_pp;
      valor := (v_vaxn
                - ((v_n1vax * NVL(1, 1)) +(v_1nvax * NVL(1, 1)))
                  /(1 -(giii / 100) -(geee / 100)) *(1 +(isi)))
               /(v_exincre /(1 -(giii / 100) -(geee / 100))
                 + (v_p1_pp + v_p2_pp) /(1 -(giii / 100) -(geee / 100)) *(1 +(isi)));
      gastcapital := v_vaxn * gastosintporcapital / 100;
      --v_vaxn := ppj_vaxn_pp;
      valor := valor /(1 +(gastcapital / 100)) /(1 +(recfracc / 100));
      valor := valor * resp1027 / 100;
      --dbms_output.put_line('v_vaxn:'||v_vaxn||'v_1nvax:'||v_1nvax||'v_n1vax:'||v_n1vax||'v_exincre:'||v_exincre);
      RETURN valor;
   END capital_garan_ppj_pp;

   /*************************************************************************

      iniciar_parametros: Inicial las variables que se usarán en la tarificación
      Param in  psesion: Sesión.
   **********************************************************/
   PROCEDURE iniciar_parametros(psesion IN NUMBER) IS
      psproduc       NUMBER;
      pcimpips       NUMBER;
      meses          NUMBER;
      vsseguro       NUMBER;
      ultfec         NUMBER;
      vgarantia      garanpro.cgarant%TYPE;   -- BUG 8763 - 02/2009 - JRH  - 0008763: CRE - Simulaciones PPJ
      var            NUMBER;
      vmi            NUMBER;
      vfpagprima     NUMBER;
   BEGIN
      ptipoint := pac_gfi.f_sgt_parms('PTIPOINT', psesion);
      sexo := pac_gfi.f_sgt_parms('SEXO', psesion);
      fecefe := pac_gfi.f_sgt_parms('FEFEPOL', psesion);
      mesefecto := TO_NUMBER(TO_CHAR(TO_DATE(fecefe, 'YYYYMMDD'), 'MM'));
      fec_vto := pac_gfi.f_sgt_parms('FEC_VTO', psesion);
      fec_vtom := fec_vto;   -- BUG 8782 - 02/2009 - JRH  - Variables para el coste de la pensión. De momento fec_vto
      fnacimi := pac_gfi.f_sgt_parms('FNACIMI', psesion);
      nmovimi := pac_gfi.f_sgt_parms('NMOVIMI', psesion);
      nriesgo := pac_gfi.f_sgt_parms('NRIESGO', psesion);
      factorcap := NVL(resp(gsesion, 1020), 1);   --JRH 10/2008
      -- fecha := pac_gfi.f_sgt_parms ('FECHA', psesion);
      gsesion := psesion;
      fpagprima := NVL(pac_gfi.f_sgt_parms('FPAGPRIMA', psesion), 0);

      IF fpagprima = 0 THEN
         vfpagprima := 12;
      ELSE
         vfpagprima := fpagprima;
      END IF;

      sproduc := pac_gfi.f_sgt_parms('SPRODUC', psesion);
      vsseguro := pac_gfi.f_sgt_parms('SSEGURO', psesion);
      cactividad := NVL(pac_gfi.f_sgt_parms('ACTIVIDAD', psesion), 0);   --Si no existe el parámetro es un 0.
      psproduc := sproduc;
      vcrevali := NVL(pac_gfi.f_sgt_parms('CREVALI', psesion), 0);
      virevali := NVL(pac_gfi.f_sgt_parms('IREVALI', psesion), 0);
      vprevali := NVL(pac_gfi.f_sgt_parms('PREVALI', psesion), 0);
      vgarantia := NVL(pac_gfi.f_sgt_parms('GARANTIA', psesion), 0);
      -- BUG 9889 - 04/2009 - JRH  - Cuadre de los datos del cierre de ABRIL
      varfactorpensio := NULL;
      varv_pensio2_pp := NULL;
      -- fi bug 9889

      --------------------------------------
--Coberturas
--------------------------------------
      resp1021 := NVL(resp(gsesion, 1021), 0);
      resp1022 := NVL(resp(gsesion, 1022), 0);
      resp1023 := NVL(resp(gsesion, 1023), 0);
      resp1024 := NVL(resp(gsesion, 1024), 0);
      resp1027 := NVL(resp(gsesion, 1027), 100);

      IF resp1027 = 0 THEN
         resp1027 := 100;
      END IF;

      -- Bug 13570 - RSC - 26/07/2010 - CRE998 - Nuevo Producto Pla Estudiant Garantit
      IF sproduc IN(263, 82) THEN   --Caso especial
         -- Fin Bug 13570
         resp1021 := 1;
         resp1022 := 1;
         resp1023 := 0;
         resp1024 := 0;
      END IF;

------------------------------------------
-------------------------------------------

      --------------------------------------
--Capitalización de primas
--------------------------------------
      reemb := NVL(vtramo(gsesion, 1450, sproduc), 0);
      factreemb := POWER(1 +(reemb / 100), 1 / 12);   -- 01/01/2009 Factor Capitalización de reembolso primas (cambiará si la prima es anual).
                                                      --Cambiar el 12 si se cambia la forma de pago
      meses := ROUND(MONTHS_BETWEEN(TO_DATE(fec_vto, 'YYYYMMDD'), TO_DATE(fecefe, 'YYYYMMDD')),
                     0);
      capitprim := POWER(factreemb, meses);   --Factor de corrección para pólizas con capit primas.

------------------------------------------
-------------------------------------------

      --------------------------------------
--Tablas mortalidad
--------------------------------------
      IF NVL(resp(gsesion, 1040), 0) <> 0 THEN   --Tablas a nivel de garantia en la pregunta 1040
         tablamortrisc := NVL(resp(gsesion, 1040), 0);
      ELSE
         BEGIN
            -- Bug 11896 - APD - 09/12/2009 - se sustituye el TIPO = 6 por 13
            SELECT MAX(g.ctabla)
              INTO tablamortrisc
              FROM garanpro g, productos s
             WHERE s.sproduc = psproduc
               AND g.sproduc = s.sproduc
               AND f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, cactividad,
                                   g.cgarant, 'TIPO') = 13;   --Muerte (tabla associada al riesgo)
         EXCEPTION
            WHEN OTHERS THEN
               NULL;   --Pondremos valores por defecto
         END;
      END IF;

      IF NVL(resp(gsesion, 1041), 0) <> 0 THEN   --Tablas a nivel de garantia en la pregunta 1041
         tablamortestalvi := NVL(resp(gsesion, 1041), 0);
      ELSE
         BEGIN
            SELECT MAX(g.ctabla)
              INTO tablamortestalvi
              FROM garanpro g, productos s
             WHERE s.sproduc = psproduc
               AND g.sproduc = s.sproduc
               AND f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, cactividad,
                                   g.cgarant, 'TIPO') = 5;   --cap. garantizado (tabla associada al ahorro)
         EXCEPTION
            WHEN OTHERS THEN
               NULL;   --Pondremos valores por defecto
         END;
      END IF;

------------------------------------------
-------------------------------------------

      --------------------------------------
--ISI
--------------------------------------
      BEGIN
         SELECT MAX(g.cimpips)
           INTO pcimpips
           FROM garanpro g, productos s
          WHERE s.sproduc = psproduc
            AND g.sproduc = s.sproduc
            AND f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, cactividad,
                                g.cgarant, 'TIPO') = 3;   --cap. garantizado (tabla associada al ahorro)
      EXCEPTION
         WHEN OTHERS THEN
            pcimpips := 0;   --Pondremos valores por defecto
      END;

      IF pcimpips = 0 THEN   -- No calculamos ISI
         isi := 0;
      ELSE
         isi := pac_gfi.f_sgt_parms('ISI', psesion);
      END IF;

------------------------------------------
-------------------------------------------

      --------------------------------------
--Fecha Referencia de último cambio de prima base, y ultima prima base
--------------------------------------
      fecrefreval := fechaultcambprima(gsesion, vsseguro, nriesgo, importebase);   --JRH Fecha de referencia para la revalorización. Si hay un cambio de prima, empieza a partir de esa fecha la revalorización.

      IF fecrefreval IS NOT NULL THEN
         IF pac_frm_actuarial.pctipefe(gsesion) = 0 THEN   --Buscamos la fecha de renovación para renovación contractual anual
            BEGIN
               IF SUBSTR(fecrefreval, 5) >= SUBSTR(fecefe, 5) THEN
                  fecrefreval := SUBSTR(fecrefreval, 1, 4) || SUBSTR(fecefe, 5);
               ELSE
                  fecrefreval := TO_CHAR(TO_NUMBER(SUBSTR(fecrefreval, 1, 4)) - 1)
                                 || SUBSTR(fecefe, 5);
               END IF;
            EXCEPTION
               WHEN OTHERS THEN
                  fecrefreval := fecefe;
            END;
         ELSE   --Buscamos la fecha de renovación para renovación natural anual
            DECLARE
               fec1           DATE;
            BEGIN
               fecrefreval := SUBSTR(fecrefreval, 1, 4) || '0101';
            EXCEPTION
               WHEN OTHERS THEN
                  fecrefreval := fecefe;
            END;
         END IF;
      ELSE
         fecrefreval := fecefe;
      END IF;

      IF importebase IS NULL THEN
         importebase := NVL(resp(gsesion, 1001), 0);
      END IF;

--------------------------------------
--Revalorarización
--------------------------------------
      --resp1004 := NVL(resp(gsesion, 1004), 0);
      --resp1003 := NVL(resp(gsesion, 1003), 0);   --Es un importe

      --Usamos la variable a nivel de seguro
      IF vcrevali = 1 THEN
         resp1004 := 0;
         resp1003 := virevali;   --Es un importe
      ELSIF vcrevali = 2 THEN
         resp1004 := vprevali;
         resp1003 := 0;   --Es un importe
      ELSIF vcrevali = 0 THEN
         resp1004 := 0;
         resp1003 := 0;   --Es un importe
      END IF;

      IF NVL(resp1003, 0) <> 0 THEN
         resp1003 := ROUND(resp1003 * 100 / importebase, 2);   --Aqui tenemos el porcentage
      END IF;

--------------------------------------
-- Gastos
--------------------------------------
      IF NVL(resp(gsesion, 550), 0) <> 0 THEN   --Si tenemos Gastos a nivel de póliza en la pregunta 550
         giii := NVL(resp(gsesion, 550), 0);
      ELSE
         giii := pac_gfi.f_sgt_parms('GIII', psesion);
      END IF;

      IF NVL(resp(gsesion, 570), 0) <> 0 THEN   --Si tenemos Gastos a nivel de póliza en la pregunta 570
         geee := NVL(resp(gsesion, 570), 0);
      ELSE
         geee := pac_gfi.f_sgt_parms('GEEE', psesion);
      END IF;

------------------------------------------
-- GastosInt sobre K (De momeno solo el 5010, si hay tiempo ya se pondra como una pregunta y mejor desarrollado)
------------------------------------------
      gastosintporcapital := NVL(vtramo(gsesion, 1452, sproduc), 0);
      gastcapitalini := 0;

      --Recargo
      DECLARE
         error1         NUMBER;
         vctipcon       NUMBER;
         vnvalcon       NUMBER;
         vcfracci       NUMBER;
         vcbonifi       NUMBER;
         vcrecfra       NUMBER;
         tiprec         NUMBER;
         -- Bug 10864.NMM.01/08/2009.
         w_climit       NUMBER;
         v_cmonimp      imprec.cmoneda%TYPE;   -- BUG 18423: LCOL000 - Multimoneda
         vcderreg       NUMBER;   -- Bug 0020314 - FAL - 29/11/2011

         -- Bug 9685 - APD - 21/05/2009 - Canvi actividad de la tabla seguros per pac_seguros.ff_get_actividad.
         CURSOR cursorseguro IS
            SELECT cempres, fefecto, cforpag, cramo, cmodali, ctipseg, ccolect,
                   pac_seguros.ff_get_actividad(sseguro, nriesgo) cactivi
              FROM seguros
             WHERE sseguro = vsseguro
            UNION
            SELECT cempres, fefecto, cforpag, cramo, cmodali, ctipseg, ccolect,
                   pac_seguros.ff_get_actividad(sseguro, nriesgo, 'EST') cactivi
              FROM estseguros
             WHERE sseguro = vsseguro;
      -- Bug 9685 - APD - 21/05/2009 - fin
      BEGIN
         SELECT crecfra
           INTO tiprec
           FROM productos
          WHERE sproduc = psproduc;

         IF NVL(tiprec, 0) <> 0 THEN
            FOR reg IN cursorseguro LOOP
               error1 := f_concepto(8, reg.cempres, reg.fefecto, reg.cforpag, reg.cramo,
                                    reg.cmodali, reg.ctipseg, reg.ccolect, reg.cactivi, 48,
                                    vctipcon, recfracc, vcfracci, vcbonifi, vcrecfra,
                                    w_climit,   -- Bug 10864.NMM.01/08/2009.
                                    v_cmonimp,   -- BUG 18423: LCOL000 - Multimoneda
                                    vcderreg);   -- Bug 0020314 - FAL - 29/11/2011
            END LOOP;
         END IF;

         recfracc := NVL(recfracc, 0);
      EXCEPTION
         WHEN OTHERS THEN
            recfracc := 0;
      END;

      DECLARE   -- BUG 8763 - 02/2009 - JRH  - 0008763: CRE - Simulaciones PPJ
         vcgarant       garanpro.cgarant%TYPE;
      BEGIN
         IF vgarantia <> 0 THEN
            SELECT NVL(f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, cactividad,
                                       g.cgarant, 'TIPO'),
                       0)
              INTO vtipogarant
              FROM garanpro g, productos s
             WHERE s.sproduc = psproduc
               AND g.sproduc = s.sproduc
               AND g.cgarant = vgarantia
               AND NVL(f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, cactividad,
                                       g.cgarant, 'TIPO'),
                       0) = 5;
         END IF;

         vtipogarant := 5;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN   --Es una garantía de simulación la que tratamos ahora. Buscamos su interés.
            vtipogarant := 0;
            ptipoint := pac_inttec.ff_int_producto(psproduc, 2, TO_DATE(fecefe, 'YYYYMMDD'),
                                                   0);
      END;

      IF pac_frm_actuarial.pctipefe(gsesion) = 0 THEN
         vmi := 1;
      ELSE
         vmi := TO_NUMBER(SUBSTR(fecefe, 5, 2));
      END IF;

      var := NVL(vtramo(gsesion, 1090, sproduc), 2);
      vtabriesg := pac_conmutadors.calculaconmu(gsesion, fedad_aseg_efec, sexo, 1967, NULL,
                                                NULL, NULL, tablamortrisc,
                                                (1 /(1 + ptipoint / 100)), NULL, NULL,
                                                resp1004, resp1003,
                                                anyos_fefecto_hasta_fecvto -(0 / 12),
                                                anyos_fefecto_hasta_fecvto -(0 / 12), var, 1,
                                                vfpagprima, vmi, reemb);
      vtabestalvi := pac_conmutadors.calculaconmu(gsesion, fedad_aseg_efec, sexo, 1967, NULL,
                                                  NULL, NULL, tablamortestalvi,
                                                  (1 /(1 + ptipoint / 100)), NULL, NULL,
                                                  resp1004, resp1003,
                                                  anyos_fefecto_hasta_fecvto -(0 / 12),
                                                  anyos_fefecto_hasta_fecvto -(0 / 12), var, 1,
                                                  vfpagprima, vmi, reemb);

      IF gastosintporcapital <> 0 THEN
         ultfec := fecha;
         giii := 0;   -- BUG 8782 - 02/2009 - JRH  - De momento en estos casos los gastos internos normales valen 0
         fecha := fecefe;
         gastcapitalini := ppj_vaxn_pp * gastosintporcapital / 100;

         IF fpagprima <> 0 THEN
            gastcapitalini := gastcapitalini / fpagprima;
         END IF;

         fecha := ultfec;
      ELSE   -- BUG 9569 - 03/2009 - JRH  - Càlcul capital de mort amb cost de pensió.
         ultfec := fecha;
         fecha := fecefe;
         vcorrecprovini := correcfactprov;   --Buscamos el factor corrector inicial.
         fecha := ultfec;
      END IF;
   END iniciar_parametros;

   /*************************************************************************
      Calculas datos financieros polizas ahorro.
      Param IN psesion: Sesión
      Param IN psseguro: Seguro
      Param IN pfecha : Fecha
      Param IN pfonprov : Modo
      retrun :Calcula para pfonprov: 0 --> Capital garantizado, 1 --> Provisión matemática, 2--> Capital de Fallecimiento.
   ****************************************************************************************/
   FUNCTION f_calculo_prov(
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
      fechaant       NUMBER;
      capgaran1      NUMBER;
      capgaran2      NUMBER;
      capaportext    NUMBER := 0;
      aportext       BOOLEAN := FALSE;
      seguroini      NUMBER;
      v_finiefe      DATE;
      v_tablas       VARCHAR2(3);
      hacerdif       BOOLEAN := TRUE;
      fechainic      DATE;
      fechafin       DATE;
      capfinal       NUMBER;
      consultainicial BOOLEAN := TRUE;
      importecapfallec NUMBER := 0;
      existeaportext BOOLEAN := FALSE;
      -- 26264.NMM.
      wpas           PLS_INTEGER := 0;
      -- Data auxiliar, es farà servir pq amb pfecha en simulacions no s'entra
      -- al bucle de moviments.
      wfecha         DATE;

      -- Bug 9685 - APD - 21/05/2009 - en lugar de coger la actividad de la tabla seguros,
      -- llamar a la función pac_seguros.ff_get_actividad
      CURSOR c_polizas_provmat IS
         SELECT s.cramo, s.cmodali, s.ctipseg, s.ccolect, p.pinttec,
                NVL(s.fcaranu, s.fvencim) ffinal, s.fefecto, s.ncertif, s.nduraci nduraci,
                p.pgasint, p.pgasext, pac_seguros.ff_get_actividad(s.sseguro, nriesgo)
                                                                                      cactivi,
                s.cforpag, s.fvencim, p.pgaexin, p.pgaexex, p.cdivisa, s.sproduc,
                NVL(m.femisio, s.fefecto) femisio
           FROM productos p, seguros s, movseguro m
          WHERE s.sseguro = psseguro
            AND p.ctipseg = s.ctipseg
            AND p.cmodali = s.cmodali
            AND p.cramo = s.cramo
            AND p.ccolect = s.ccolect
            -- AND s.csituac <> 4 -- BUG 8763 - 03/2009 - JRH  - 0008763: CRE - Simulaciones PPJ
            AND m.sseguro = s.sseguro
            AND m.nmovimi = 1
         UNION
         SELECT s.cramo, s.cmodali, s.ctipseg, s.ccolect, p.pinttec,
                NVL(s.fcaranu, s.fvencim) ffinal, s.fefecto, s.ncertif, s.nduraci nduraci,
                p.pgasint, p.pgasext,
                pac_seguros.ff_get_actividad(s.sseguro, nriesgo, 'EST') cactivi, s.cforpag,
                s.fvencim, p.pgaexin, p.pgaexex, p.cdivisa, s.sproduc,
                NVL(s.femisio, s.fefecto) femisio
           FROM productos p, estseguros s
          WHERE s.sseguro = psseguro
            AND p.ctipseg = s.ctipseg
            AND p.cmodali = s.cmodali
            AND p.cramo = s.cramo
            AND p.ccolect = s.ccolect;

      -- Bug 9685 - APD - 21/05/2009 - fin
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
              AND cmovimi IN(1, 2, 4, 9, 10, 27, 33, 34, 39, 51, 53)   -- JRH 01/2009 Ponemos el 27,51,53
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
              --AND nnumlin <> NVL (pnnumlin, 0)
              AND nnumlin > NVL(pnnumlin, 0)   --JRH Buscamos mayor que el saldo
                      -- NO TENEMOS EN CUENTA LA APORTACIÓN DEL MES
         --AND CMOVANU!=1     -- EL MOVIMENT NO HA ESTAT ANULAT
         --AND NNUMLIN!=1;    --Em salto el primer rebut
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
              AND cmovimi IN(1, 2, 4, 9, 10, 27, 33, 34, 39, 51, 53)   -- JRH 01/2009 Ponemos el 27,51,53
              AND TRUNC(ffecmov) > f_ini
              AND TRUNC(ffecmov) <= f_final
         ORDER BY nnumlin;

      -- Bug 9685 - APD - 21/05/2009 - en lugar de coger la actividad de la tabla seguros,
      -- llamar a la función pac_seguros.ff_get_actividad
      CURSOR c_aport_ini(pfechaini IN DATE) IS
         SELECT   g.icapital, g.finiefe
             FROM garanseg g, seguros s
            WHERE s.sseguro = psseguro
              AND g.sseguro = s.sseguro
              AND g.nriesgo = nriesgo
              --AND g.nmovimi = nmovimi
              AND f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect,
                                  pac_seguros.ff_get_actividad(s.sseguro, nriesgo), g.cgarant,
                                  'TIPO') = 3   -- PRIMA AHORRO
              AND TRUNC(g.finiefe) <= pfechaini
              AND v_tablas IS NULL
         UNION ALL
         SELECT   g.icapital, g.finiefe
             FROM estgaranseg g, estseguros s
            WHERE s.sseguro = psseguro
              AND g.sseguro = s.sseguro
              AND g.nriesgo = nriesgo
              AND g.nmovimi = nmovimi
              AND f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect,
                                  pac_seguros.ff_get_actividad(s.sseguro, nriesgo, 'EST'),
                                  g.cgarant, 'TIPO') = 3   -- PRIMA AHORRO
              AND TRUNC(g.finiefe) <= pfechaini
              AND v_tablas = 'EST'
         ORDER BY finiefe DESC;

      -- Bug 9685 - APD - 21/05/2009 - fin
      CURSOR c_est IS
         SELECT e.sseguro
           FROM estseguros e
          WHERE e.sseguro = psseguro;
   BEGIN
      wpas := 10;

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

      iniciar_parametros(psesion);

      IF NVL(v_tablas, 'SEG') <> 'EST' THEN
         IF vtipogarant <> 5 THEN   -- BUG 8763 - 03/2009 - JRH  - 0008763: CRE - Simulaciones PPJ
            wpas := 20;
            RETURN 0;   --Si no estamos en una simulación, devolvemos 0 para esta garantía.
         END IF;
      END IF;

      --El calculo de la provisión lo haremos a partir de la ultima provisión del saldo, los movimiento siguientes, y la simulación
      --de movimientos hasta el vto
      FOR reg IN c_polizas_provmat LOOP
         --Buscamos el recargo por fraccionamiento por si existe

         -----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- JRH Buscamos la última provisión anterior a la fecha de consulta (CTASEGURO)
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
         p_datos_ult_saldo(seguroini,   --JRH Ssseguro
                           pfecha, v_fecha_pm_anterior, pm_anterior, pcapgarant, pcapfallant,
                           v_numres);
         wpas := 25;

         --No hay saldo, estamos en NP
         IF v_fecha_pm_anterior IS NULL THEN
            pm_anterior := 0;
            -- v_fecha_pm_anterior := TRUNC (reg.femisio);
            v_fecha_pm_anterior := LEAST(TRUNC(reg.femisio), reg.fefecto);

            IF v_tablas IS NULL THEN
               DECLARE
                  a              NUMBER;
               BEGIN
                  SELECT COUNT(*)
                    INTO a
                    FROM ctaseguro
                   WHERE sseguro = seguroini;

                  IF a = 0 THEN
                     v_fecha_pm_anterior := reg.fefecto;
                  END IF;
               END;
            END IF;
         END IF;

         IF gastosintporcapital <> 0 THEN   -- BUG 8782 - 02/2009 - JRH  - Gastos internos por capital
            ultfec := fecha;
            giii := 0;
            fecha := TO_NUMBER(TO_CHAR(v_fecha_pm_anterior, 'YYYYMMDD'));
            gastcapitalini := ppj_vaxn_pp * gastosintporcapital / 100;

            IF fpagprima <> 0 THEN
               gastcapitalini := gastcapitalini / fpagprima;
            END IF;

            fecha := ultfec;
            -- BUG 14787 - 06/2010 - JRH  - 0014787: CRE802 - revisión PMAT cartera CaixaBank
            --pm_anterior_pura := pm_anterior /(1 +(gastcapitalini)); --no hay que volverlo a descontar
            pm_anterior_pura := pm_anterior;
            -- Fi BUG 14787 - 06/2010 - JRH
            wpas := 30;
         ELSE
            ultfec := fecha;   --Bug 9752 - 04/2009 - JRH  - Corregir càlcul provisió.
            fecha := TO_NUMBER(TO_CHAR(v_fecha_pm_anterior, 'YYYYMMDD'));
            fecha := (ROUND(fecha / 100, 0) * 100) + 1;
            pm_anterior_pura := pm_anterior
                                /(1 +((giii / 100) *(correcfactprov / vcorrecprovini)));   -- BUG 9569 - 03/2009 - JRH  - Càlcul capital de mort amb cost de pensió.
            fecha := ultfec;
            wpas := 40;
         END IF;

         --buscamos la provisión pura a partir de la de inventario
         fecha := TO_NUMBER(TO_CHAR(v_fecha_pm_anterior, 'YYYYMMDD'));

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
--vamos a calcular la provisión y el capial garantizado a acumulado si tenemos
--movimientos entre v_fecha_pm_anterior y la fecha de la consulta pfecha
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
         IF pm_anterior <> 0 THEN
            --buscamos el capital garantizado acumulado anterior (correspondiente a esta provisión pura mediante el factor de provision a fecha v_fecha_pm_anterior )
            --factorprov := 1 /(ppj_exincre +(v_pensio1_pu + v_pensio2_pu))
            --              - ((ppj_1nvax_pu * capitprim) +(ppj_n1vax_pu * capitprim))
             --               /(ppj_exincre +(v_pensio1_pu + v_pensio2_pu));

            -- BUG 8628 - 03/2009 - JRH  - Nueva forma de calcular el factor prov
            ultfec := fecha;
            -- BUG 14787 - 06/2010 - JRH  - 0014787: CRE802 - revisión PMAT cartera CaixaBank
            --fecha := (ROUND(fecha / 100, 0) * 100) + 1;   --Primer dia del mes
            fecha := TO_NUMBER(TO_CHAR(LAST_DAY(TO_DATE(fecha, 'YYYYMMDD')), 'YYYYMMDD'));   --Ponemos último día del mes
            -- Fi BUG 14787 - 06/2010 - JRH
            vfactorriesgopu := (ppj_1nvax_pu * 1) +(ppj_n1vax_pu * 1)
                               + capital_garan_ppj_pu *(v_pensio1_pu + v_pensio2_pu);
            factorprov := (1 - vfactorriesgopu) / ppj_exincre
                          + capital_garan_ppj_pu *(v_pensio1_pu + v_pensio2_pu);
            factorprov := factorprov /(1 + gastcapitalini);
            capitalacumant := pm_anterior_pura * factorprov;
            fecha := ultfec;   --Primer dia del mes
            wpas := 50;
         ELSE
            capitalacumant := 0;
            wpas := 60;
         END IF;

         --dbms_output.put_line('pm_anterior_pura:'||pm_anterior_pura||' factorprov:'||factorprov||' capitalacumant:'||capitalacumant);
         ulfecha := GREATEST(v_fecha_pm_anterior, reg.fefecto);
         --dependiendo de si es un suplemento , una NP, cartera o una mera consulta, la aportación en cuestión la
         --tendremos en ctaseguro, con lo que tendríamos bastante en el cursor siguiente o
         --tendremos que buscarla también con RESP() a una pregunta (p ejemplo en un suplemento)
         --queda pdte. de momento
         wpas := 65;

         -- 26264.NMM. A partir d'aqui substituïm pfecha per wfecha menys en el pas 122.
         -- 0 = Capital Garantit
         -- 1 = Provisió matemàtica
         IF pfonprov <> 1
            AND v_tablas = 'EST' THEN
            SELECT MAX(ffecmov)
              INTO wfecha
              FROM ctaseguro
             WHERE sseguro = seguroini;

            wfecha := NVL(wfecha, pfecha);
            wfecha := GREATEST(wfecha, pfecha);
         ELSE
            wfecha := pfecha;
         END IF;

         --FOR r_mov IN c_movimientos(seguroini, v_fecha_pm_anterior, pfecha, v_numres) LOOP
         FOR r_mov IN c_movimientos(seguroini, v_fecha_pm_anterior, wfecha, v_numres) LOOP
            consultainicial := FALSE;
            -- Vamos actualizando el nuevo valor de la fecha
            fecha := GREATEST(TO_NUMBER(TO_CHAR(r_mov.ffecmov, 'YYYYMMDD')), fecefe);
            ulfecha := GREATEST(r_mov.ffecmov, reg.fefecto);

            --Calculamos el capital garantizado a vto para cada aportación y lo vamos sumando al acumulado
            IF r_mov.cmovimi = 2 THEN
               -- Aportació periódica
               IF fpagprima = 0 THEN
                  capgaran := r_mov.imovimi * capital_garan_ppj_pu;
               ELSE
                  capgaran := r_mov.imovimi * capital_garan_ppj_pu /(1 +(recfracc / 100));   --Li hem de treure el recàrrec
               END IF;

               capitalacumant := capitalacumant + capgaran;
               wpas := 70;
            ELSIF r_mov.cmovimi = 9 THEN
               -- Aportació extraordinaria, única i rescats
               capgaran := r_mov.imovimi * capital_garan_ppj_pb;
               capitalacumant := capitalacumant + capgaran;
               existeaportext := TRUE;
               wpas := 80;
            ELSE
               -- Aportació extraordinaria, única i rescats
               -- BUG 15510 - 08/2010 - JRH  - 0015510: CRE - Desviació de la provisió quan es fan rescats parcials
               --capgaran := r_mov.imovimi * capital_garan_ppj_pu;  --Era pb no pu
               capgaran := r_mov.imovimi * capital_garan_ppj_pb;
               -- Fi BUG 15510 - 08/2010 - JRH
               capitalacumant := capitalacumant + capgaran;
               existeaportext := TRUE;
               wpas := 90;
            END IF;

            importecapfallec := importecapfallec + r_mov.imovimi;
            wpas := 95;
         END LOOP;

         IF NVL(pac_iaxpar_productos.f_get_parproducto('CAP_GAR_NO_CALC',
                                                       pac_gfi.f_sgt_parms('SPRODUC', psesion)),
                0) = 1 THEN
            IF pfonprov = 0
               AND(v_tablas IS NULL)
               AND(NOT existeaportext)
               AND NVL(pcapgarant, 0) <> 0 THEN
               wpas := 100;
               RETURN pcapgarant;   --Per a aquest parametre, si estem a consulta, solament hi ha hagut periodiques i ens demanen el capital, retornem l'ultim capgar i axí no tarda el càlcul.
            END IF;
         END IF;

         -- BUG 9889 - 05/2009 - JRH  -  Bug 0009172: CRE055 - Rentas regulares e irregulares con cálculos a partir de renta
         IF NVL(pac_iaxpar_productos.f_get_parproducto('CAP_GAR_NO_CALC',
                                                       pac_gfi.f_sgt_parms('SPRODUC', psesion)),
                0) = 1 THEN
            IF pfonprov = 2
               AND(v_tablas IS NULL)
               AND(NOT existeaportext)
               AND(NVL(resp1021, 0) = 0)
               AND NVL(pcapfallant, 0) <> 0 THEN
               wpas := 110;
               RETURN pcapfallant;   --Per a aquest parametre, si estema consulta, solament hi ha hagut periodiques i ens demanen el capital, retornem l'ultim capgar i axí no tarda el càlcul.
            END IF;
         END IF;

         --fi bug

         -- Si estamos en una NP, cartera o Suplemento hemos de añadir las aportaciones en cuestión.
         -- Si estamos simulando por aquí no entrará
         FOR e IN c_est LOOP
            IF nmovimi = 1 THEN   -- NP
               hacerdif := FALSE;
               fecha := fecefe;

               IF fpagprima = 0 THEN
                  capgaran := resp(psesion, 1001) * capital_garan_ppj_pu;
               ELSE
                  capgaran := resp(psesion, 1001) * capital_garan_ppj_pp;
               END IF;

               capitalacumant := capitalacumant + capgaran;
               capgaran := resp(psesion, 1002) * capital_garan_ppj_pu;
               capitalacumant := capitalacumant + capgaran;
               capgaran := resp(psesion, 1008) * capital_garan_ppj_pb;
               capitalacumant := capitalacumant + capgaran;
               --ulfecha := pfecha;
               ulfecha := wfecha;
               wpas := 120;
            ELSIF nmovimi > 1 THEN   -- Suplemento (Aport. Extr.)
               aportext := TRUE;

               IF resp(psesion, 1002) <> 0 THEN
                  fechaant := fecha;
                  fecha := TO_CHAR(pfecha, 'YYYYMMDD');
                  -- 26264.NMM.  canvi capital_garan_ppj_pu per capital_garan_ppj_pb
                  capaportext := resp(psesion, 1002) * capital_garan_ppj_pb;
                  fecha := fechaant;
                  importecapfallec := importecapfallec + resp(psesion, 1002);
                  wpas := 122;
               ELSIF NVL(resp(psesion, 1008), 0) <> 0 THEN
                  fechaant := fecha;
                  --fecha := TO_CHAR(pfecha, 'YYYYMMDD');
                  fecha := TO_CHAR(wfecha, 'YYYYMMDD');
                  capaportext := resp(psesion, 1008) * capital_garan_ppj_pb;
                  fecha := fechaant;
                  importecapfallec := importecapfallec + resp(psesion, 1008);
                  wpas := 124;
               ELSIF resp(psesion, 1001) <> 0 THEN
                  -- Le quito un mes para que este lo tenga en cuenta también en el cálculo
                  --ulfecha := ADD_MONTHS(pfecha, -1);
                  ulfecha := ADD_MONTHS(wfecha, -1);
                  capaportext := 0;
                  wpas := 126;
               END IF;

               wpas := 130;
            END IF;
         END LOOP;

         wpas := 135;

         IF aportext THEN   --Estamos en un suplemento, simulamos el capital garantizado.
            fecha := TO_NUMBER(TO_CHAR(ADD_MONTHS(ulfecha, 1), 'YYYYMMDD'));
            fecha := (ROUND(fecha / 100, 0) * 100) + 1;   --Primer dia del mes
            capgaran := 0;
            wpas := 140;

            IF fpagprima <> 0 THEN   --Tenemos prima periodica
               aportacion_inicial := NULL;

               OPEN c_aport_ini(TO_DATE(fecha, 'YYYYMMDD'));

               FETCH c_aport_ini
                INTO aportacion_inicial, v_finiefe;

               CLOSE c_aport_ini;

               -- dramon 3-10-2008: bug mantis 7417
               IF aportacion_inicial IS NULL THEN
                  -- Si es NULL es por problema con las fechas
                  aportacion_inicial := resp(psesion, 1001);
                  wpas := 150;
               END IF;

               --capgaran := NVL (aportacion_inicial, 0) * capital_garan_ppj_pp;
               IF pfonprov = 0 THEN
                  fechafin := ADD_MONTHS(TO_DATE(fec_vto, 'YYYYMMDD'), -1);
               ELSE
                  --fechafin := pfecha;
                  fechafin := wfecha;
               END IF;

               fechainic := TO_DATE(fecha, 'YYYYMMDD');
               capfinal := 0;   --Simulamos la prima periodica
               wpas := 160;

               FOR i IN 0 .. FLOOR(MONTHS_BETWEEN(fechafin, fechainic)) LOOP
                  --Numero de pagos a simular si UlFecha obtenida antes < Pfecha que nos piden la provison
                  --Calculamos el capital garantizado a vto para cada aportación y lo vamos sumando al acumulado
                  -- IF aportperiodica
                  -- THEN                       -- de momento solo seran las peridicas
                  fecha := TO_NUMBER(TO_CHAR(ADD_MONTHS(fechainic, i), 'YYYYMMDD'));
                  mesact := TO_NUMBER(TO_CHAR(TO_DATE(fecha, 'YYYYMMDD'), 'MM'));

                  IF MOD((ABS(mesact - mesefecto)),(12 / fpagprima)) = 0 THEN
                     capfinal := NVL(aportacion_inicial, 0) * progresion
                                 * capital_garan_ppj_pu;
                     --a la fecha en cuestión a futuro
                     capgaran := capgaran + capfinal;
                     importecapfallec := importecapfallec
                                         +(NVL(aportacion_inicial, 0) * progresion);
                     wpas := 170;
                  END IF;
               END LOOP;
            --ELSE
            --  CapAportExt:= resp (psesion, 1001) * capital_garan_ppj_pu;
            END IF;

            capitalacumant := capitalacumant + capgaran;
            capitalacumant := capitalacumant + capaportext;
            wpas := 180;
         ELSE   --Es una consulta, buscamos a la fecha capitales y provisión
            IF hacerdif
               AND fpagprima <> 0
               AND pfonprov NOT IN(1, 2) THEN   -- Si hay periodica
               --IF (TO_CHAR(pfecha, 'YYYYMM') > TO_CHAR(ulfecha, 'YYYYMM'))
               IF (TO_CHAR(wfecha, 'YYYYMM') > TO_CHAR(ulfecha, 'YYYYMM'))
                  OR(pfonprov = 0) THEN
                  --Ahora simulamos todas las aportaciones hasta fec_vto
                  IF NOT consultainicial THEN
                     fecha := TO_NUMBER(TO_CHAR(ADD_MONTHS(ulfecha, 1), 'YYYYMMDD'));
                  END IF;

                  fecha := (ROUND(fecha / 100, 0) * 100) + 1;   --Primer dia del mes
                  aportacion_inicial := NULL;

                  --capgaran := NVL (aportacion_inicial, 0) * nvl(capital_garan_ppj_pp,0);
                  IF pfonprov = 0 THEN
                     fechafin := ADD_MONTHS(TO_DATE(fec_vto, 'YYYYMMDD'), -1);
                  ELSE
                     --fechafin := pfecha;
                     fechafin := wfecha;
                  END IF;

                  wpas := 190;
                  fechainic := TO_DATE(fecha, 'YYYYMMDD');
                  wpas := 200;

                  FOR i IN 0 .. FLOOR(MONTHS_BETWEEN(fechafin, fechainic)) LOOP
                     --Numero de pagos a simular si UlFecha obtenida antes < Pfecha que nos piden la provison
                     --Calculamos el capital garantizado a vto para cada aportación y lo vamos sumando al acumulado
                     -- IF aportperiodica
                     -- THEN                       -- de momento solo seran las peridicas
                     fecha := TO_NUMBER(TO_CHAR(ADD_MONTHS(fechainic, i), 'YYYYMMDD'));
                     mesact := TO_NUMBER(TO_CHAR(TO_DATE(fecha, 'YYYYMMDD'), 'MM'));

                     IF MOD((ABS(mesact - mesefecto)),(12 / fpagprima)) = 0 THEN   --Solo para los meses que tocan segun la forma pag
                        capgaran := importebase * progresion * capital_garan_ppj_pu;   --Para la progresión partimos de ibase.
                        --a la fecha en cuestión a futuro

                        --dbms_output.put_line('capital_garan_ppj_pp:'||capital_garan_ppj_pp);
                        capitalacumant := capitalacumant + capgaran;
                        --dbms_output.put_line('i:'||i||' importebase:'||importebase||' capital_garan_ppj_pu:'||capital_garan_ppj_pu||' progresion:'||progresion||' capgaran:'||capgaran);
                        importecapfallec := importecapfallec + NVL(importebase, 0)
                                                               * progresion;
                        wpas := 210;
                     END IF;
                  END LOOP;
               END IF;
            END IF;   --hacerdif
         END IF;   --Aport extra

         --convertimos el nuevo capital acumulado a provision multiplicando por FactorProv a la fecha de la consulta
         IF pfonprov = 1 THEN
            -- Solo quitamos 2 meses en el caso que se pida todos los periodos
            --IF TO_CHAR(pfecha, 'YYYYMM') = SUBSTR(fec_vto, 1, 6) THEN
            IF TO_CHAR(wfecha, 'YYYYMM') = SUBSTR(fec_vto, 1, 6) THEN
               fecha := TO_NUMBER(TO_CHAR(ADD_MONTHS(TO_DATE(fecha, 'YYYYMMDD'), -1),
                                          'YYYYMMDD'));
            --ELSIF TO_CHAR(pfecha, 'YYYYMM') > TO_CHAR(ulfecha, 'YYYYMM') THEN
            ELSIF TO_CHAR(wfecha, 'YYYYMM') > TO_CHAR(ulfecha, 'YYYYMM') THEN
               fecha := TO_NUMBER(TO_CHAR(ADD_MONTHS(TO_DATE(fecha, 'YYYYMMDD'), -0),
                                          'YYYYMMDD'));

               DECLARE
                  fec            DATE;
                  fechaanterior1 NUMBER;
               BEGIN
                  fechaanterior1 := fecha;
                  --fecha := FLOOR(fecha / 100) * 100 + TO_NUMBER(TO_CHAR(pfecha, 'dd'));   --Dejamos la fecha según el día de pfecha, si no puede ser, dejamos la que ya teníamos.
                  fecha := FLOOR(fecha / 100) * 100 + TO_NUMBER(TO_CHAR(wfecha, 'dd'));
                  fec := TO_DATE(fecha, 'YYYYMMDD');
               EXCEPTION
                  WHEN OTHERS THEN
                     fecha := fechaanterior1;
               END;
            ELSE
               NULL;
            END IF;

            IF fpagprima IN(0, 1, 2, 3, 4, 6) THEN
               --IF TO_CHAR(pfecha, 'YYYYMMDD') <> fecha THEN
               IF TO_CHAR(wfecha, 'YYYYMMDD') <> fecha THEN
                  --fecha := TO_CHAR(pfecha, 'YYYYMMDD');
                  fecha := TO_CHAR(wfecha, 'YYYYMMDD');
               END IF;
            END IF;

            wpas := 220;

            -- BUG 9889 - 04/2009 - JRH  - Cuadre de los datos del cierre de ABRIL
            DECLARE
               vfactor1       NUMBER;
               vfactor2       NUMBER;
               vdias          NUMBER;
               vfactortotal1  NUMBER;
               vfactortotal2  NUMBER;
               vfecdate       DATE;
            BEGIN
               vfecdate := TO_DATE(fecha, 'YYYYMMDD');
               --vdias := ADD_MONTHS(vfecdate, 1) - vfecdate;
               vdias := TO_NUMBER(TO_CHAR(LAST_DAY(vfecdate), 'DD'));
               vfactor2 := ABS((TO_NUMBER(TO_CHAR(vfecdate, 'DD')) - 1) / vdias);
               vfactor1 := ABS(1 - vfactor2);

               IF vfactor1 > 1 THEN
                  vfactor1 := 1;
               END IF;

               IF vfactor2 > 1 THEN
                  vfactor2 := 1;
               END IF;

               fecha := (ROUND(fecha / 100, 0) * 100) + 1;   --Primer dia del mes
               vfactorriesgopu := (ppj_1nvax_pu * 1) +(ppj_n1vax_pu * 1)
                                  + capital_garan_ppj_pu *(v_pensio1_pu + v_pensio2_pu);
               factorprov := (1 - vfactorriesgopu) / ppj_exincre
                             + capital_garan_ppj_pu *(v_pensio1_pu + v_pensio2_pu);
               wpas := 230;

               --factorprov := factorprov /(1 + gastcapitalini);
               IF gastosintporcapital <> 0 THEN
                  ultfec := fecha;
                  gastcapitalini := ppj_vaxn_pp * gastosintporcapital / 100;

                  IF fpagprima <> 0 THEN
                     gastcapitalini := gastcapitalini / fpagprima;
                  END IF;

                  fecha := ultfec;
               ELSE
                  NULL;
               END IF;

               wpas := 240;

               IF gastosintporcapital <> 0 THEN
                  vfactortotal1 := (1 / factorprov) *(1 +(gastcapitalini));
               ELSE
                  vfactortotal1 := (1 / factorprov)
                                   *(1 +((giii / 100) *(correcfactprov / vcorrecprovini)));   -- BUG 9569 - 03/2009 - JRH  - Càlcul capital de mort amb cost de pensió.
               END IF;

               wpas := 250;

               BEGIN
                  fecha := TO_NUMBER(TO_CHAR(ADD_MONTHS(TO_DATE(fecha, 'YYYYMMDD'), 1),
                                             'YYYYMMDD'));
                  vfactorriesgopu := (ppj_1nvax_pu * 1) +(ppj_n1vax_pu * 1)
                                     + capital_garan_ppj_pu *(v_pensio1_pu + v_pensio2_pu);
                  factorprov := (1 - vfactorriesgopu) / ppj_exincre
                                + capital_garan_ppj_pu *(v_pensio1_pu + v_pensio2_pu);
                  wpas := 260;

                  --factorprov := factorprov /(1 + gastcapitalini);
                  IF gastosintporcapital <> 0 THEN
                     ultfec := fecha;
                     gastcapitalini := ppj_vaxn_pp * gastosintporcapital / 100;

                     IF fpagprima <> 0 THEN
                        gastcapitalini := gastcapitalini / fpagprima;
                     END IF;

                     fecha := ultfec;
                  ELSE
                     NULL;
                  END IF;

                  wpas := 270;

                  IF gastosintporcapital <> 0 THEN
                     vfactortotal2 := (1 / factorprov) *(1 +(gastcapitalini));
                  ELSE
                     vfactortotal2 := (1 / factorprov)
                                      *(1 +((giii / 100) *(correcfactprov / vcorrecprovini)));   -- BUG 9569 - 03/2009 - JRH  - Càlcul capital de mort amb cost de pensió.
                  END IF;

                  IF vfactortotal2 IS NULL THEN
                     vfactortotal2 := 0;
                     vfactor1 := 1;
                     vfactor2 := 0;
                  END IF;
               EXCEPTION
                  WHEN OTHERS THEN
                     vfactortotal2 := 0;
                     vfactor1 := 1;
                     vfactor2 := 0;
               END;

               pm := capitalacumant *(vfactortotal1 * vfactor1 + vfactortotal2 * vfactor2);
               wpas := 280;
            END;
         ELSIF pfonprov = 0 THEN
            pm := capitalacumant;
            wpas := 290;
         ELSIF pfonprov = 2 THEN   -- BUG 8782 - 02/2009 - JRH  - Parte del capital de fallecimiento
            IF (NVL(resp1021, 0) = 0) THEN
               --AND(NVL(resp1022, 0) = 0)) THEN
                 -- BUG 9569 - 03/2009 - JRH  - Calculo capital de fallecimiento
               pm := factorpensio * NVL(pcapgarant, 0);
            ELSE
               pm := (importecapfallec + pcapfallant) * factreemb;
            END IF;

            wpas := 300;
         END IF;
      END LOOP;

      wpas := 310;
      RETURN pm;
   END f_calculo_prov;

   FUNCTION f_calc_coefprov(psesion IN NUMBER, psseguro IN NUMBER, pfecha IN DATE)
      RETURN NUMBER IS
      coefpp         NUMBER := 0;
      prog           NUMBER;
      coefuu         NUMBER;
      coefuuacum     NUMBER := 0;
      coef           NUMBER := 0;
      num            NUMBER;
      ptablas        VARCHAR2(20);
   BEGIN
      --Si nos llaman desde el gfi debemos tener estos datos en los parametros
      giii := pac_gfi.f_sgt_parms('GIII', psesion);
      geee := pac_gfi.f_sgt_parms('GEEE', psesion);
      isi := pac_gfi.f_sgt_parms('ISI', psesion);
      ptipoint := pac_gfi.f_sgt_parms('PTIPOINT', psesion);
      sexo := pac_gfi.f_sgt_parms('SEXO', psesion);
      fecefe := pac_gfi.f_sgt_parms('FEFEPOL', psesion);
      fec_vto := pac_gfi.f_sgt_parms('FEC_VTO', psesion);
      fnacimi := pac_gfi.f_sgt_parms('FNACIMI', psesion);
      nmovimi := pac_gfi.f_sgt_parms('NMOVIMI', psesion);
      nriesgo := pac_gfi.f_sgt_parms('NRIESGO', psesion);
      -- fecha := pac_gfi.f_sgt_parms ('FECHA', psesion);
      fpagprima := pac_gfi.f_sgt_parms('FPAGPRIMA', psesion);
      sproduc := pac_gfi.f_sgt_parms('SPRODUC', psesion);

      BEGIN
         SELECT 1
           INTO num
           FROM seguros
          WHERE sseguro = psseguro;

         ptablas := 'SEG';
      EXCEPTION
         WHEN OTHERS THEN
            ptablas := 'EST';
      END;

      resp1004 := NVL(pac_albsgt_mv.f_prevali(ptablas, psseguro, nriesgo,
                                              TO_DATE(fecefe, 'YYYYMMDD'), nmovimi, 283, NULL,
                                              NULL, NULL),
                      0);
      resp1003 := NVL(pac_albsgt_mv.f_irevali(ptablas, psseguro, nriesgo,
                                              TO_DATE(fecefe, 'YYYYMMDD'), nmovimi, 283, NULL,
                                              NULL, NULL),
                      0);
      gsesion := psesion;
      fecha := fecefe;
      resp1021 := NVL(resp(gsesion, 1021), 0);
      resp1022 := NVL(resp(gsesion, 1022), 0);
      resp1023 := NVL(resp(gsesion, 1023), 0);
      resp1024 := NVL(resp(gsesion, 1024), 0);

      -- Bug 13570 - RSC - 26/07/2010 - CRE998 - Nuevo Producto Pla Estudiant Garantit
      IF sproduc IN(263, 82) THEN
         -- Fin Bug 13570
         resp1021 := 1;
         resp1022 := 1;
      END IF;

      coefpp := NVL(capital_garan_ppj_pp, 0);

      FOR i IN 1 .. MONTHS_BETWEEN(TO_DATE(fec_vto, 'YYYYMMDD'), TO_DATE(fecefe, 'YYYYMMDD')) LOOP
         -- Vamos actualizando el nuevo valor de la fecha
         coefuu := NVL(capital_garan_ppj_pu, 0);
         prog := pac_frm_actuarial.ff_progresionnat(gsesion, resp1004,   --NVL (resp (gsesion, 1004), 0),
                                                    resp1003,   --NVL (resp (gsesion, 1003), 0),
                                                    (12 * anyos_fefecto_hasta_fecha   -- - 1
                                                                                   ) / 12,
                                                    1, 1);
         coefuuacum := coefuuacum + prog * coefuu;
         fecha := TO_CHAR(ADD_MONTHS(TO_DATE(fecha, 'YYYYMMDD'), 1), 'YYYYMMDD');

         IF fecha >= fec_vto THEN
            EXIT;
         END IF;
      END LOOP;

      coef := coefpp / coefuuacum;
      RETURN(coef);
   END f_calc_coefprov;

   FUNCTION f_calc_isi_pu(psesion IN NUMBER, psseguro IN NUMBER, pfecha IN DATE)
      RETURN NUMBER IS
      valor          NUMBER;
   BEGIN
      --Si nos llaman desde el gfi debemos tener estos datos en los parametros
      /*giii := pac_gfi.f_sgt_parms ('GIII', psesion);
      geee := pac_gfi.f_sgt_parms ('GEEE', psesion);
      isi := pac_gfi.f_sgt_parms ('ISI', psesion);
      ptipoint := pac_gfi.f_sgt_parms ('PTIPOINT', psesion);
      sexo := pac_gfi.f_sgt_parms ('SEXO', psesion);
      fecefe := pac_gfi.f_sgt_parms ('FECEFE', psesion);
      fec_vto := pac_gfi.f_sgt_parms ('FEC_VTO', psesion);
      fnacimi := pac_gfi.f_sgt_parms ('FNACIMI', psesion);
      nmovimi := pac_gfi.f_sgt_parms ('NMOVIMI', psesion);
      nriesgo := pac_gfi.f_sgt_parms ('NRIESGO', psesion);
      FactorCap :=  NVL (resp (gsesion, 1020), 1);--JRH 10/2008
      FPAGPRIMA := pac_gfi.f_sgt_parms ('FPAGPRIMA', psesion);
      sproduc:= pac_gfi.f_sgt_parms ('SPRODUC', psesion);

      if pfecha is null then
          fecha := pac_gfi.f_sgt_parms ('FECHA', psesion);
      else
          fecha:=TO_CHAR(pfecha,'YYYYMMDD');
      end if;

      gsesion := psesion;

      resp1004:=NVL (resp (gsesion, 1004), 0);
      resp1003:= NVL (resp (gsesion, 1003), 0);
      --El calculo del a provisión lo haremos a partir de la ultima provisión del saldo, los movimiento siguientes, y la simulación

      resp1021:=NVL (resp (gsesion, 1021), 0);
      resp1022:=NVL (resp (gsesion, 1022), 0);
      resp1023:=NVL (resp (gsesion, 1023), 0);
      resp1024:=NVL (resp (gsesion, 1024), 0);

      if sproduc = 263 then
        resp1021:=1;
        resp1022:=1;
      end if;
      */
      iniciar_parametros(psesion);

      IF pfecha IS NULL THEN
         fecha := pac_gfi.f_sgt_parms('FECHA', psesion);
      ELSE
         fecha := TO_CHAR(pfecha, 'YYYYMMDD');
      END IF;

      gsesion := psesion;
      valor :=((resp(psesion, 1002)
                - resp(psesion, 1002) * capital_garan_ppj_pu
                  *(ppj_exincre /(1 -(giii / 100) -(geee / 100))) / ppj_vaxn_pu)
               /(1 +(isi)) *(isi));

      IF valor < 0 THEN
         valor := 0.001;
      END IF;

      RETURN valor;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 0;
   END f_calc_isi_pu;

   FUNCTION f_calc_isi_pp(psesion IN NUMBER, psseguro IN NUMBER, pfecha IN DATE)
      RETURN NUMBER IS
      valor          NUMBER;
      fpagprima      NUMBER;
      -- BUG 8628 - 03/2009 - JRH  - Nueva forma de calcular el factor prov
      vfactorisi     NUMBER;
   BEGIN
      --Si nos llaman desde el gfi debemos tener estos datos en los parametros
      iniciar_parametros(psesion);

      IF pfecha IS NULL THEN
         fecha := pac_gfi.f_sgt_parms('FECHA', psesion);
      ELSE
         fecha := TO_CHAR(pfecha, 'YYYYMMDD');
      END IF;

      IF ABS(MONTHS_BETWEEN(TO_DATE(fecha, 'YYYYMMDD'), TO_DATE(fec_vto, 'YYYYMMDD'))) <= 2 THEN
         fecha := TO_CHAR(ADD_MONTHS(TO_DATE(fec_vto, 'YYYYMMDD'), -2) - 1, 'YYYYMMDD');
      END IF;

      gsesion := psesion;
      --El calculo del a provisión lo haremos a partir de la ultima provisión del saldo, los movimiento siguientes, y la simulación

      --De momento
      capitprim := 1;

      IF fpagprima = 0 THEN
         valor :=((resp(psesion, 1001)
                   - resp(psesion, 1001) * capital_garan_ppj_pu
                     *(ppj_exincre /(1 -(giii / 100) -(geee / 100))) / ppj_vaxn_pu)
                  /(1 +(isi)) *(isi));
      ELSE
         -- BUG 8628 - 03/2009 - JRH  - Nueva forma de calcular el factor prov
         vfactorisi := ((ppj_1nvax_pp * NVL(capitprim, 1)) +(ppj_n1vax_pp * NVL(capitprim, 1))
                        + capital_garan_ppj_pp *(v_pensio1_pp + v_pensio2_pp))
                       / ppj_vaxn_pp;
         --valor := resp(psesion, 1001) * progresion * vfactorisi;
         valor := resp(psesion, 1001) * 1 * vfactorisi;
         --jrh resp(psesion, 1001) LLEVA LA PROGRESIÓN DENTRO YA
         valor := valor /(1 -(giii / 100) -(geee / 100)) * isi;
      END IF;

      IF valor < 0 THEN
         valor := 0.001;
      END IF;

      RETURN valor;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'calculoISIWhen others', 1,
                     'fecha:' || fecha || 'valor:' || valor || 'fec_vto:' || fec_vto
                     || 'pfecha:' || pfecha || 'isi:' || isi,
                     'AAAA');
         RETURN 0;
   END f_calc_isi_pp;

   FUNCTION f_calc_isi(psesion IN NUMBER, psseguro IN NUMBER, pfecha IN DATE)
      RETURN NUMBER IS
      valor          NUMBER;
   BEGIN
      valor := f_calc_isi_pp(psesion, psseguro, pfecha)
               + f_calc_isi_pu(psesion, psseguro, pfecha);
   END f_calc_isi;
END pac_calc_prov;

/

  GRANT EXECUTE ON "AXIS"."PAC_CALC_PROV" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CALC_PROV" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CALC_PROV" TO "PROGRAMADORESCSI";
