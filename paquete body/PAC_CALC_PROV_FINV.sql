--------------------------------------------------------
--  DDL for Package Body PAC_CALC_PROV_FINV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_CALC_PROV_FINV" AS
   /******************************************************************************
      NOMBRE:       PAC_CALC_PROV_FINV
      PROPÓSITO:
      REVISIONES:

       Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
       1.0       07/05/2009  RSC              1. Creación de package
       2.0       17/09/2009     RSC           2. Bug 0010828: CRE - Revisión de los productos PPJ dinámico y Pla Estudiant (ajustes)
   ******************************************************************************/
   FUNCTION fechaultcambprima281(
      psesion NUMBER,
      pseguro IN NUMBER,
      priesgo IN NUMBER,
      importeprimper OUT NUMBER)
      RETURN NUMBER IS
      fechaultcamb   DATE;
      vnmovimi       NUMBER(10);
      vssegpol       NUMBER(10);
      seguroini      NUMBER(10);
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
      vssegpol       NUMBER(10);
      seguroini      NUMBER(10);

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
      vssegpol       NUMBER(10);
      seguroini      NUMBER(10);

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
      vssegpol       NUMBER(10);
      seguroini      NUMBER(10);

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
      vssegpol       NUMBER(10);
      seguroini      NUMBER(10);

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

      IF v_tablas = 'EST' THEN
         fecefe := v_fecha;
      END IF;

      -- Fin Bug 10828

      --p_control_error('RSC_X23','f_cesperado','fecefe = '||fecefe);
--dbms_output.put_line('------------------------------------------------------------ fecefe = '||fecefe);

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
            SELECT crespue
              INTO v_opdinamica
              FROM pregunseg
             WHERE sseguro = psseguro
               AND cpregun = 560
               AND nmovimi = (SELECT MAX(nmovimi)
                                FROM pregunseg
                               WHERE sseguro = psseguro
                                 AND cpregun = 560);
      END;

      -- Fin Bug 10040
      v_traza := 5;

      -- Inicialización del capital esperaedo
      IF nmovimi = 1 THEN   -- NP
         v_capesperado := NVL(resp(psesion, 1002), 0);   -- La aportación extraordinaria
      ELSE   -- Aportación extraordinaria, suplementos, etc
         BEGIN
            SELECT v.itotalr
              INTO v_capesperado
              FROM vdetrecibos v, recibos r, seguros s
             WHERE v.nrecibo = r.nrecibo
               AND r.sseguro = s.sseguro
               AND r.fefecto = s.fefecto
               AND r.sseguro = v_seguroini
               AND r.nrecibo = (SELECT MIN(nrecibo)
                                  FROM recibos
                                 WHERE sseguro = r.sseguro
                                   AND fefecto = r.fefecto
                                   AND ctiprec = r.ctiprec)
               AND r.ctiprec = 4;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_capesperado := 0;
         END;
      END IF;

      v_traza := 6;
      v_fecha281 := pac_calc_prov_finv.fechaultcambprima281(psesion, psseguro, nriesgo,
                                                            v_importeprimper);
      v_traza := 7;
      v_fecha500 := pac_calc_prov_finv.fechaultcambprima500(psesion, psseguro, pfecha, nriesgo);
      v_traza := 8;
      v_fecha508 := pac_calc_prov_finv.fechaultcambprima508(psesion, psseguro, pfecha, nriesgo);
      v_traza := 9;
      v_fecha526 := pac_calc_prov_finv.fechaultcambprima526(psesion, psseguro, pfecha, nriesgo);
      v_traza := 10;
      v_fecha266 := pac_calc_prov_finv.fechaultcambprima266(psesion, psseguro, pfecha, nriesgo);
      v_traza := 11;

      SELECT DECODE(fpagprima, 1, 12, 12, 1, 4, 3, 2, 6, fpagprima)
        INTO vforpag
        FROM DUAL;

      v_traza := 12;

      IF v_fecha281 IS NULL
         AND v_fecha500 IS NULL
         AND v_fecha508 IS NULL
         AND v_fecha526 IS NULL
         AND v_fecha266 IS NULL THEN   -- NP limpia / limpio
         -- Bug 10828 - RSC - 141092009 - CRE - Revisión de los productos PPJ dinámico y Pla Estudiant (ajustes)
         IF nmovimi = 1 THEN
            v_capesperado := NVL(resp(psesion, 1002), 0);   -- La aportación extraordinaria
         ELSE
            v_capesperado := pac_operativa_finv.ff_provmat(psesion, v_seguroini, fecefe);
         END IF;

         -- Fin Bug 10828

         --p_control_error('RSC_X23','f_cesperado','YYYYYY v_capesperado = '||v_capesperado);
--dbms_output.put_line('------------------------------------------------------------------- YYYYYY v_capesperado = '||v_capesperado);
         IF fpagprima <> 0 THEN   --Tenemos prima periodica
            v_traza := 13;

            OPEN c_aport_per(TO_DATE(fecefe, 'YYYYMMDD'));

            v_traza := 14;

            FETCH c_aport_per
             INTO aportacion_periodica, vfecha_aux;

            v_traza := 15;

            CLOSE c_aport_per;

            v_traza := 16;
            aportacion_periodica := NVL(aportacion_periodica, NVL(resp(psesion, 1001), 0));
--p_control_error('RSC_X23','f_cesperado','YYYYYY aportacion_periodica = '||aportacion_periodica);
--dbms_output.put_line('------------------------------------------------------------------- YYYYYY aportacion_periodica = '||aportacion_periodica);
            v_traza := 17;
            -- Tratamiento de las periodica
            fechainic := TO_DATE(fecefe, 'YYYYMMDD')
                         + NVL(f_parproductos_v(v_sproduc, 'DIASCARGA_PRIMA'), 0);
            v_edad1 := (TO_DATE(fecefe, 'YYYYMMDD') - TO_DATE(v_fnacimi, 'YYYYMMDD')) / 365.25;
            v_traza := 14;
            fecha := TO_NUMBER(TO_CHAR(fechainic, 'YYYYMMDD'));
            i := 1;

--p_control_error('RSC_X23','f_cesperado','YYYYYY fechainic = '||fechainic);
--dbms_output.put_line('------------------------------------------------------------------- YYYYYY fechainic = '||fechainic);
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
         END IF;

         -- Capital esperado a vencimiento
         v_capesperado := v_capesperado
                          * POWER((1 +(v_rendesp / 100)),
                                  (TO_DATE(fec_vto, 'YYYYMMDD')
                                   - TO_DATE(v_fechaold, 'YYYYMMDD'))
                                  / 365);
      ELSE
         SELECT GREATEST(NVL(v_fecha281, fecefe), NVL(v_fecha500, fecefe),
                         NVL(v_fecha508, fecefe), NVL(v_fecha526, fecefe),
                         NVL(v_fecha266, fecefe), fecefe)
           INTO v_fechacorte
           FROM DUAL;

         -- Provisión a fecha de corte
         v_capesperado := pac_operativa_finv.ff_provmat(psesion, v_seguroini, v_fechacorte);

--p_control_error('RSC_X23','f_cesperado','XXXXXXX v_capesperado = '||v_capesperado);
--dbms_output.put_line('------------------------------------------------------------------- XXXXXX v_capesperado = '||v_capesperado);

         -- Calculo del capital esperado en el nuevo regimen (tras un suplemento de cambio de perfil,
         -- un suplemento de aportación extraordinaria, una modificación de prima periodica y/o
         -- rescate parcial
         IF fpagprima <> 0 THEN   --Tenemos prima periodica
            OPEN c_aport_per(TO_DATE(v_fechacorte, 'YYYYMMDD'));

            FETCH c_aport_per
             INTO aportacion_periodica, vfecha_aux;

            CLOSE c_aport_per;

            aportacion_periodica := NVL(aportacion_periodica, NVL(resp(psesion, 1001), 0));
--p_control_error('RSC_X23','f_cesperado','XXXXXXX aportacion_periodica = '||aportacion_periodica);
--dbms_output.put_line('------------------------------------------------------------------- XXXXXX aportacion_periodica = '||aportacion_periodica);
            -- Tratamiento de las periodica
            fechainic := TO_DATE(v_fechacorte, 'YYYYMMDD')
                         + NVL(f_parproductos_v(v_sproduc, 'DIASCARGA_PRIMA'), 0);
            v_edad1 := (TO_DATE(v_fechacorte, 'YYYYMMDD') - TO_DATE(v_fnacimi, 'YYYYMMDD'))
                       / 365.25;
            fecha := TO_NUMBER(TO_CHAR(fechainic, 'YYYYMMDD'));
            i := 1;

--p_control_error('RSC_X23','f_cesperado','XXXXXXX fechainic = '||fechainic);
--dbms_output.put_line('------------------------------------------------------------------- XXXXXX fechainic = '||fechainic);
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
         END IF;

         -- Capital esperado a vencimiento
         v_capesperado := v_capesperado
                          * POWER((1 +(v_rendesp / 100)),
                                  (TO_DATE(fec_vto, 'YYYYMMDD')
                                   - TO_DATE(v_fechaold, 'YYYYMMDD'))
                                  / 365);
      -- Nou capital esperat = saldo actual + el nou règim d'aportacions futures
      --v_capesperado := v_capesp_aux + v_capesperado;
      END IF;

--p_control_error('RSC_X23','f_cesperado','XXXXXXX v_capesperado final = '||v_capesperado);
--dbms_output.put_line('------------------------------------------------------------------- XXXXXX v_capesperado final = '||v_capesperado);
      RETURN v_capesperado;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_CALC_PROV_FINV.f_cesperado', v_traza,
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
      v_capesperado := pac_calc_prov_finv.f_cesperado(psesion, psseguro, ppfefecto);
      -- Valor de provisión (Participaciones acumuladas * Precio participacion)
      v_provision := pac_operativa_finv.ff_provmat(psesion, psseguro, ppfefecto);

      SELECT GREATEST((v_capesperado - v_provision), 0)
        INTO v_cfallec
        FROM DUAL;

      RETURN v_cfallec;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_CALC_PROV_FINV.ff_cfallec', NULL,
                     'parametros: psseguro = ' || psseguro, SQLERRM);
         RETURN NULL;
   END ff_cfallec;
/*************************************************************************
   Obtiene el rendimiento esperado del modelo de inversión asociado
   a un contrato financiero de inversión.
   param in ptablas  : Tablas reales o table est
   param in psseguro : Código de contrato
   return          : 0 todo correcto
                     1 ha habido un error
*************************************************************************/
-- Bug 9424 - 07/04/2009 - RSC - Creación del producto PPJ Dinàmic
/*
FUNCTION ff_rendimiento_esperado(ptablas IN VARCHAR2, psseguro IN NUMBER)
   RETURN NUMBER IS
   v_cmodinv      seguros_ulk.cmodinv%TYPE;
   v_rendesp      modelosinversion.rendesp%TYPE;
   v_fnacimi      per_personas.fnacimi%TYPE;
   v_fefecto      seguros.fefecto%TYPE;
   v_edad         NUMBER;
BEGIN
   IF ptablas = 'EST' THEN
      -----------------------
      --  ptablas = 'EST'  --
      -----------------------
      SELECT cmodinv
        INTO v_cmodinv
        FROM estseguros_ulk
       WHERE sseguro = psseguro;
   ELSE
      -------------------------
      --  ptablas  'reales'  --
      -------------------------
      SELECT cmodinv
        INTO v_cmodinv
        FROM seguros_ulk
       WHERE sseguro = psseguro;
   END IF;

   SELECT rendesp
     INTO v_rendesp
     FROM modelosinversion
    WHERE cmodinv = v_cmodinv;

   RETURN v_rendesp;
END ff_rendimiento_esperado;
*/
-- Fin Bug 9424
END pac_calc_prov_finv;

/

  GRANT EXECUTE ON "AXIS"."PAC_CALC_PROV_FINV" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CALC_PROV_FINV" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CALC_PROV_FINV" TO "PROGRAMADORESCSI";
