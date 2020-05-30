--------------------------------------------------------
--  DDL for Package Body CALC_RESCATES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."CALC_RESCATES" AS
/******************************************************************************
   NOMBRE:      CALC_RESCATES
   PROPÓSITO:   Funciones para la gestión de rescates

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        ??/??/????   ???                1. Creación del package
   2.0        04/02/2010   JRH                2.BUG 0012986: CEM - CRS - Ajustes productos CRS
   3.0        22/02/2010   RSC                3. 0013296: CEM - Revisión módulo de rescates
   4.0        16/04/2010   RSC                3. 0014160: CEM800 - Adaptar packages de productos de inversión al nuevo módulo de siniestros
   5.0        05/09/2010   JRH                4. BUG 0016217: Mostrar cuadro de capitales para la pólizas de rentas
   6.0        27/10/2010   RSC                5. Bug 16494: CRS: INCORPORACIÓ INFO ADDICIONAL PANTALLA I DOCUMENT
   7.0        16/11/2010   RSC                6.0016716: CRS: INCORPORACIÓ INFO ADDICIONAL PANTALLA I DOCUMENT
   8.1        25/11/2010   JRH                8. 0016833: F_PENALIZACION incorrecta
   9.0        13/07/2011   DRA                9. 0019054: CIV800-No funcionen les sol?licituds de rescats a Beta
  10.0        03/11/2011   JMF               10. 0019791: LCOL_A001-Modificaciones de fase 0 en la consulta de recibos
   11.0        22/11/2011   RSC                 11. 0020241: LCOL_T004-Parametrización de Rescates (retiros)
   ******************************************************************************/
   FUNCTION fvalresctotaho(
      pnsesion IN NUMBER,
      psseguro IN NUMBER,
      pfrescat IN NUMBER,
      psituac IN NUMBER DEFAULT 1)
      RETURN NUMBER IS
/***********************************************************************
    Retorna el valor bruto del rescate para pólizas de ahorro
******************************************************************************/
      xicaprisc      NUMBER;
   BEGIN
      xicaprisc := pac_propio.f_irescate(psseguro, TO_DATE(pfrescat, 'YYYYMMDD'), psituac);
      RETURN NVL(ROUND(xicaprisc, 2), 0);
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'calc_rescates.fvalresctotaho', NULL,
                     'parametros: psseguro=' || psseguro || ' pfrescat=' || pfrescat, SQLERRM);
         RETURN NULL;
   END fvalresctotaho;

   FUNCTION fvalvenctotaho(pnsesion IN NUMBER, psseguro IN NUMBER, pfrescat IN NUMBER)
      RETURN NUMBER IS
      /***********************************************************************
          Retorna el valor bruto del rescate para pólizas de ahorro (en rescate por
          vencimiento)
      ******************************************************************************/
      xicaprisc      NUMBER;
   BEGIN
      xicaprisc := pac_propio.f_ivencimiento(psseguro, TO_DATE(pfrescat, 'YYYYMMDD'));
      RETURN ROUND(xicaprisc, 2);
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'calc_rescates.FvalvencTotAho', NULL,
                     'parametros: psseguro=' || psseguro || ' pfrescat=' || pfrescat, SQLERRM);
         RETURN NULL;
   END fvalvenctotaho;

   FUNCTION frecgestion(psseguro IN NUMBER, ptipo IN NUMBER)
      RETURN NUMBER IS
/*************************************************************************************************************
    FrecGestion: devolverá si una póliza tiene recibos en gestión
       Si ptipo = 1 => devolverá el número de recibos en gestión
       Si ptipo = 2 => devolverá el importe de los recibos en gestión
**************************************************************************************************************/
      xrecgest       NUMBER;
      xigestion      NUMBER;
   BEGIN
      -- bug 0019791
      SELECT DECODE(COUNT(*), 0, NULL, COUNT(*)),
             DECODE(SUM(DECODE(r.ctiprec, 9, -itotalr, 13, -itotalr, itotalr)),
                    0, NULL,
                    SUM(DECODE(r.ctiprec, 9, -itotalr, 13, -itotalr, itotalr)))   -- ctiprec = 9 (Extorno), 13 (Retorno)
        INTO xrecgest,
             xigestion
        FROM vdetrecibos v, recibos r
       WHERE r.sseguro = psseguro
         AND r.nrecibo = v.nrecibo
         AND f_cestrec_mv(r.nrecibo, 1) = 3;

      IF ptipo = 1 THEN
         RETURN NVL(xrecgest, 0);
      ELSIF ptipo = 2 THEN
         RETURN NVL(xigestion, 0);
      ELSE
         --- No se ha informado el tipo
         RETURN -1;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'calc_rescates.frecgestion', NULL,
                     'parametros: psseguro=' || psseguro || ' ptipo=' || ptipo, SQLERRM);
         RETURN NULL;
   END frecgestion;

   FUNCTION frcmrescate(
      psesion IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      pfefecto IN NUMBER,
      pctipres IN NUMBER,
      picapris IN NUMBER,
      pipenali IN NUMBER)
      RETURN NUMBER IS
       /******************************************************************************************
          Retorna el valora de RCM en un rescate total o vencimiento en pólizas de ahorro
      ***********************************************************************************/
      xerror         NUMBER;
      xmoneda        NUMBER := 1;
      xireten        NUMBER;
      xireduc        NUMBER;
      xircm          NUMBER;
      xfefecto       DATE;
      v_cempres      NUMBER;
   BEGIN
      xfefecto := TO_DATE(pfefecto, 'YYYYMMDD');

      -- BUG 11595 - 03/11/2009 - APD - Adaptación al nuevo módulo de siniestros
      SELECT cempres
        INTO v_cempres
        FROM seguros
       WHERE sseguro = psseguro;

      IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'MODULO_SINI'), 0) = 0 THEN
         xerror := pac_rescates.f_retencion_simulada(psesion, psseguro, pnriesgo, pcgarant,
                                                     xfefecto, xfefecto, pctipres, picapris,
                                                     pipenali, xmoneda, xireten, xireduc,
                                                     xircm);
      ELSE
         xerror := pac_sin_rescates.f_retencion_simulada(psesion, psseguro, pnriesgo,
                                                         pcgarant, xfefecto, xfefecto,
                                                         pctipres, picapris, pipenali,
                                                         xmoneda, xireten, xireduc, xircm);
      END IF;

      -- Fin BUG 11595 - 03/11/2009 - APD - Adaptación al nuevo módulo de siniestros
      IF xerror <> 0 THEN
         -- BUG19054:DRA:13/07/2011:Inici
         p_tab_error(f_sysdate, f_user, 'calc_rescates.frcmrescate', NULL,
                     'parametros: psseguro=' || psseguro || ' pnriesgo =' || pnriesgo
                     || ' pcgarant =' || pcgarant || ' pfefecto=' || pfefecto || ' pctipres ='
                     || pctipres || ' picapris =' || picapris || ' pipenali =' || pipenali,
                     f_axis_literales(xerror, f_usu_idioma));
         -- BUG19054:DRA:13/07/2011:Fi
         RETURN NULL;
      END IF;

      RETURN xircm;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'calc_rescates.frcmrescate', NULL,
                     'parametros: psseguro=' || psseguro || ' pnriesgo =' || pnriesgo
                     || ' pcgarant =' || pcgarant || ' pfefecto=' || pfefecto || ' pctipres ='
                     || pctipres || ' picapris =' || picapris || ' pipenali =' || pipenali,
                     SQLERRM);
         RETURN NULL;
   END frcmrescate;

   FUNCTION fredrescate(
      psesion IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      pfefecto IN NUMBER,
      pctipres IN NUMBER,
      picapris IN NUMBER,
      pipenali IN NUMBER)
      RETURN NUMBER IS
       /**********************************************************************************
          Retorna el importe de reducción en un rescate total o vencimiento
      ***********************************************************************************/
      xerror         NUMBER;
      xmoneda        NUMBER := 1;
      xireten        NUMBER;
      xireduc        NUMBER;
      xircm          NUMBER;
      xfefecto       DATE;
      v_cempres      NUMBER;
   BEGIN
      xfefecto := TO_DATE(pfefecto, 'YYYYMMDD');

      -- BUG 11595 - 03/11/2009 - APD - Adaptación al nuevo módulo de siniestros
      SELECT cempres
        INTO v_cempres
        FROM seguros
       WHERE sseguro = psseguro;

      IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'MODULO_SINI'), 0) = 0 THEN
         xerror := pac_rescates.f_retencion_simulada(psesion, psseguro, pnriesgo, pcgarant,
                                                     xfefecto, xfefecto, pctipres, picapris,
                                                     pipenali, xmoneda, xireten, xireduc,
                                                     xircm);
      ELSE
         xerror := pac_sin_rescates.f_retencion_simulada(psesion, psseguro, pnriesgo,
                                                         pcgarant, xfefecto, xfefecto,
                                                         pctipres, picapris, pipenali,
                                                         xmoneda, xireten, xireduc, xircm);
      END IF;

      IF xerror <> 0 THEN
         RETURN NULL;
      END IF;

      RETURN xireduc;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'calc_rescates.fredrescate', NULL,
                     'parametros: psseguro=' || psseguro || ' pnriesgo =' || pnriesgo
                     || ' pcgarant =' || pcgarant || ' pfefecto=' || pfefecto || ' pctipres ='
                     || pctipres || ' picapris =' || picapris || ' pipenali =' || pipenali,
                     SQLERRM);
         RETURN NULL;
   END fredrescate;

   -- Bug 13296 - RSC - 22/02/2010 - CEM - Revisión módulo de rescates
   /*************************************************************************
       fporcenpenali:

       Cálculo de la % penalización
       param in psseguro          : Sseguro
       param in pfrescat          : Fecha de rescate
       param in pccausin          : Tipo de movimiento (4 : Rescate total / 5 : Rescate parcial)
       param out pnmesessinpenali : mensajes de error
       para in porigen : 1 EST / 2 SEG
       return                     : %
                                    nulo si error
   *************************************************************************/
   FUNCTION fporcenpenali(
      psesion IN NUMBER,
      psseguro IN NUMBER,
      pfrescat IN NUMBER,
      pccausin IN NUMBER,
      -- BUG 16217 - 09/2010 - JRH  -  Cuadro de provisiones
      porigen IN NUMBER DEFAULT 2)
      -- Fi BUG 16217 - 09/2010 - JRH
   RETURN NUMBER IS
      pipenali       NUMBER;
      ptippenali     NUMBER;
   BEGIN
      IF pccausin = 4 THEN   -- rescate total
         pipenali := calc_rescates.f_get_penalizacion(psseguro, pfrescat, 3, ptippenali,
                                                      porigen);
      ELSIF pccausin = 5 THEN   -- rescate parcial
         pipenali := calc_rescates.f_get_penalizacion(psseguro, pfrescat, 2, ptippenali,
                                                      porigen);
      END IF;

      RETURN pipenali;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'calc_rescates.fporcenpenali', NULL,
                     'parametros: psseguro=' || psseguro || ' pfrescat =' || pfrescat
                     || ' pccausin =' || pccausin,
                     SQLERRM);
         RETURN NULL;
   END fporcenpenali;

   -- Fin Bug 13296

   -- RSC 18/03/2008
-- Calcula el importe máximo rescatable
   FUNCTION fimaximo_rescp(
      psesion IN NUMBER,
      psseguro IN NUMBER,
      pfrescat IN NUMBER,
      pccausin IN NUMBER)
      RETURN NUMBER IS
      viminimo       NUMBER;
      vtmaxano       NUMBER;
      vclaveimax     NUMBER;
      v_ctipmov      NUMBER;
      v_sproduc      NUMBER;
      nanyos         NUMBER;
      vimaximo       NUMBER;
      v_fefecto      DATE;
      num_err        NUMBER;
      v_frevant      DATE;
      v_fecha        DATE;
   BEGIN
      IF pccausin = 4 THEN   -- rescate total
         v_ctipmov := 3;
      ELSIF pccausin = 5 THEN   -- rescate parcial
         v_ctipmov := 2;
      END IF;

      -- Bug 13296 - RSC - 22/02/2010 - CEM - Revisión módulo de rescates

      -- RSC 12/12/2007 (añado la left join con seguros_aho)
      --SELECT s.sproduc, s.fefecto, NVL(sa.frevant, s.fefecto)
      --INTO v_sproduc, v_fefecto, v_frevant
      --FROM seguros s LEFT JOIN seguros_aho sa ON(s.sseguro = sa.sseguro)
      --WHERE s.sseguro = psseguro;
      --
      --IF NVL(f_parproductos_v(v_sproduc, 'EVOLUPROVMATSEG'), 0) = 1 THEN
      --   v_fecha := v_frevant;
      --ELSE
      --   v_fecha := v_fefecto;
      --END IF;
      --
      --nanyos := TRUNC(MONTHS_BETWEEN(TO_DATE(pfrescat, 'yyyymmdd'), v_fecha) / 12);
      nanyos := calc_rescates.f_get_anyos_porcenpenali(psseguro, pfrescat, v_ctipmov);

      -- Fin Bug 13296

      --información a nivel de producto
      SELECT d.iminimo
        INTO viminimo
        FROM detprodtraresc d, prodtraresc p
       WHERE d.sidresc = p.sidresc
         AND p.sproduc = v_sproduc
         AND p.ctipmov = v_ctipmov
         AND p.finicio <= TO_DATE(pfrescat, 'yyyymmdd')
         AND(p.ffin > TO_DATE(pfrescat, 'yyyymmdd')
             OR p.ffin IS NULL)
         AND d.niniran = (SELECT MIN(dp.niniran)
                            FROM detprodtraresc dp
                           WHERE dp.sidresc = d.sidresc
                             AND nanyos BETWEEN dp.niniran AND dp.nfinran);

      vimaximo := pac_provmat_formul.f_calcul_formulas_provi(psseguro,
                                                             TO_DATE(pfrescat, 'yyyymmdd'),
                                                             'IPROVAC');
      vimaximo := vimaximo - viminimo;
      RETURN vimaximo;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'calc_rescates.fimaximo_rescatep', NULL,
                     'parametros: psseguro=' || psseguro || ' pfrescat =' || pfrescat
                     || ' pccausin =' || pccausin,
                     SQLERRM);
         RETURN NULL;
   END fimaximo_rescp;

   FUNCTION fprimasaport(
      pnsesion IN NUMBER,
      psseguro IN NUMBER,
      pfrescat IN NUMBER,
      pccausin IN NUMBER)
      RETURN NUMBER IS
/************************************************************************************
   Retorna las primas aportadas por asegurado:
     -- si en el momento del rescate hay 2 asegurados: retorna el 50%
     -- si en el momento del rescate hay 1 asegurado:
         -- si la póliza inicialmente tiene 1 solo asegurado: 100%
         -- si la póliza inicialmente tiene 2 asegurados y 1 ha fallecido: el 50%
            hasta la fecha de fallecimiento y el 100% después.
 ************************************************************************************/
      xfrescat       DATE;
      xirecges       NUMBER;
      xfmuerte       DATE;
      primasaportadas NUMBER;
      v_cempres      NUMBER;
      xnumaseg       NUMBER;
   BEGIN
      xfrescat := TO_DATE(pfrescat, 'yyyymmdd');

      -- BUG 11595 - 03/11/2009 - APD - Adaptación al nuevo módulo de siniestros
      SELECT cempres
        INTO v_cempres
        FROM seguros
       WHERE sseguro = psseguro;

      IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'MODULO_SINI'), 0) = 0 THEN
         -- Primero hay que mirar si hay algún asegurado fallecido
         xnumaseg := pac_rescates.f_vivo_o_muerto(psseguro, 2, xfrescat);
      ELSE
         -- Primero hay que mirar si hay algún asegurado fallecido
         xnumaseg := pac_sin_rescates.f_vivo_o_muerto(psseguro, 2, xfrescat);
      END IF;

      -- Fin BUG 11595 - 03/11/2009 - APD - Adaptación al nuevo módulo de siniestros
      -- Primero hay que mirar si hay algún asegurado fallecido
      IF xnumaseg > 0 THEN
         SELECT ffecfin
           INTO xfmuerte
           FROM asegurados
          WHERE ffecmue IS NOT NULL
            AND sseguro = psseguro;
      END IF;

      --Cálculo de PrimasAportadas
      SELECT NVL(SUM(CASE
                        WHEN fvalmov < NVL(xfmuerte, fvalmov) THEN ROUND(iprima
                                                                         / DECODE(xfmuerte,
                                                                                  NULL, 1,
                                                                                  2),
                                                                         2)
                        ELSE iprima
                     END),
                 0)
        INTO primasaportadas
        FROM primas_aportadas
       WHERE sseguro = psseguro
         AND fvalmov <= xfrescat;   -- RSC 17/04/2008 Antes era <, ahora se ha puesto <=
                                    -- por que si no no tiene en cuenta las aportaciones
                                    -- realizadas en el dia para el cálculo de primas_aportadas

      RETURN primasaportadas;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'calc_rescates.fprimasaport', NULL,
                     'parametros: psseguro=' || psseguro || ' pfrescat =' || pfrescat
                     || ' pccausin =' || pccausin,
                     SQLERRM);
         RETURN NULL;
   END fprimasaport;

/*************************************************************************
       fipenali:

       Cálculo de la % penalización
       param in psseguro          : Sseguro
       param in pfrescat          : Fecha de rescate
       param in pccausin          : Tipo de movimiento (4 : Rescate total / 5 : Rescate parcial)
        param in  porigen         : 1 EST, 2 SEG
       return                     : %
                                    nulo si error
   *************************************************************************/
--------------------------------------------------------------------------------
   FUNCTION fipenali(
      psesion IN NUMBER,
      psseguro IN NUMBER,
      pfrescat IN NUMBER,
      pccausin IN NUMBER,
      picaprisc IN NUMBER,
      -- BUG 16217 - 09/2010 - JRH  -  Cuadro de provisiones
      porigen IN NUMBER DEFAULT 2)
      -- Fi BUG 16217 - 09/2010 - JRH
   RETURN NUMBER IS
      /* calcula el IMPORTE de penalización a aplicar a la póliza */
      v_ctipmov      NUMBER;
      v_sproduc      NUMBER;
      v_fefecto      DATE;
      v_frevant      DATE;
      v_fecha        DATE;
      nanyos         NUMBER;
      num_err        NUMBER;
      vipenali       NUMBER;
      vtippenali     NUMBER;
   BEGIN
      IF pccausin = 4 THEN   -- RESCATE TOTAL
         vipenali := calc_rescates.f_get_penalizacion(psseguro, pfrescat, 3, vtippenali,
                                                      porigen);
      ELSIF pccausin = 5 THEN   -- RESCATE PARCIAL
         vipenali := calc_rescates.f_get_penalizacion(psseguro, pfrescat, 2, vtippenali,
                                                      porigen);
      END IF;

      IF vtippenali = 2 THEN
         vipenali := picaprisc * vipenali / 100;
      END IF;

      RETURN ROUND(vipenali, 2);
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'CALC_RESCATES.FIPENALI', NULL,
                     'parametros: psesion =' || psesion || ', psseguro =' || psseguro
                     || ', pfrescat =' || pfrescat || ', pccausin =' || pccausin
                     || ', picaprisc =' || picaprisc,
                     SQLERRM);
         RETURN NULL;
   END fipenali;

-- Bug 11227 - APD - 25/09/2009 - se crea la funcion fprimasconsum
   FUNCTION fprimasconsum(
      pnsesion IN NUMBER,
      psseguro IN NUMBER,
      pfrescat IN NUMBER,
      pccausin IN NUMBER)
      RETURN NUMBER IS
/************************************************************************************
   Retorna las primas consumidas por asegurado:
     -- si en el momento del rescate hay 2 asegurados: retorna el 50%
     -- si en el momento del rescate hay 1 asegurado:
         -- si la póliza inicialmente tiene 1 solo asegurado: 100%
         -- si la póliza inicialmente tiene 2 asegurados y 1 ha fallecido: el 50%
            hasta la fecha de fallecimiento y el 100% después.
 ************************************************************************************/
      xfrescat       DATE;
      xirecges       NUMBER;
      xfmuerte       DATE;
      primasconsumidas NUMBER;
      v_cempres      NUMBER;
      xnumaseg       NUMBER;
   BEGIN
      xfrescat := TO_DATE(pfrescat, 'yyyymmdd');

      -- BUG 11595 - 03/11/2009 - APD - Adaptación al nuevo módulo de siniestros
      SELECT cempres
        INTO v_cempres
        FROM seguros
       WHERE sseguro = psseguro;

      IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'MODULO_SINI'), 0) = 0 THEN
         -- Primero hay que mirar si hay algún asegurado fallecido
         xnumaseg := pac_rescates.f_vivo_o_muerto(psseguro, 2, xfrescat);
      ELSE
         -- Primero hay que mirar si hay algún asegurado fallecido
         xnumaseg := pac_sin_rescates.f_vivo_o_muerto(psseguro, 2, xfrescat);
      END IF;

      -- Fin BUG 11595 - 03/11/2009 - APD - Adaptación al nuevo módulo de siniestros
      -- Primero hay que mirar si hay algún asegurado fallecido
      IF xnumaseg > 0 THEN
         SELECT ffecfin
           INTO xfmuerte
           FROM asegurados
          WHERE ffecmue IS NOT NULL
            AND sseguro = psseguro;
      END IF;

      --Cálculo de PrimasAportadas
      SELECT NVL(SUM(CASE
                        WHEN fecha < NVL(xfmuerte, fecha) THEN ROUND(ipricons
                                                                     / DECODE(xfmuerte,
                                                                              NULL, 1,
                                                                              2),
                                                                     2)
                        ELSE ipricons
                     END),
                 0)
        INTO primasconsumidas
        FROM primas_consumidas
       WHERE sseguro = psseguro
         AND fecha <= xfrescat;   -- RSC 17/04/2008 Antes era <, ahora se ha puesto <=

      -- por que si no no tiene en cuenta las aportaciones
      -- realizadas en el dia para el cálculo de primas_aportadas
      RETURN primasconsumidas;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, getuser, 'calc_rescates.fprimasconsum', NULL,
                     'parametros: psseguro=' || psseguro || ' pfrescat =' || pfrescat
                     || ' pccausin =' || pccausin,
                     SQLERRM);
         RETURN NULL;
   END fprimasconsum;

-- Bug 11227 - APD - 25/09/2009 - se crea la funcion fprimasnoconsum
   FUNCTION fprimasnoconsum(
      pnsesion IN NUMBER,
      psseguro IN NUMBER,
      pfrescat IN NUMBER,
      pccausin IN NUMBER)
      RETURN NUMBER IS
/************************************************************************************
   Retorna las primas no consumidas por asegurado, es decir, la diferencia entre las primas
   aportadas y las primas consumidas:
     -- si en el momento del rescate hay 2 asegurados: retorna el 50%
     -- si en el momento del rescate hay 1 asegurado:
         -- si la póliza inicialmente tiene 1 solo asegurado: 100%
         -- si la póliza inicialmente tiene 2 asegurados y 1 ha fallecido: el 50%
            hasta la fecha de fallecimiento y el 100% después.
 ************************************************************************************/
      xfrescat       DATE;
      xirecges       NUMBER;
      xfmuerte       DATE;
      primasaportadas NUMBER;
      primasconsumidas NUMBER;
      primasnoconsumidas NUMBER;
   BEGIN
      primasnoconsumidas := NVL(calc_rescates.fprimasaport(pnsesion, psseguro, pfrescat,
                                                           pccausin),
                                0)
                            - NVL(calc_rescates.fprimasconsum(pnsesion, psseguro, pfrescat,
                                                              pccausin),
                                  0);
      RETURN primasnoconsumidas;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, getuser, 'calc_rescates.fprimasnoconsum', NULL,
                     'parametros: psseguro=' || psseguro || ' pfrescat =' || pfrescat
                     || ' pccausin =' || pccausin,
                     SQLERRM);
         RETURN NULL;
   END fprimasnoconsum;

   /*************************************************************************
       Cálculo de años dentro de periodo revisión / hasta periodo revisión.
       param in psseguro          : Sseguro
       param in pfrescat          : Fecha de rescate
       param in pctipmov          : Tipo de movimiento (3: Rescate total / 2: Rescate parcial)
       param out pnanyos2         : Anyos2 para el cálculo de penalización recucida en meses.
       param out pnmeses          : Numero de meses (para penalización recucida en meses)
       param out pctipo           : Tipo de penalización aplicada (valor fijo 360)
       param out pnmesessinpenali : mensajes de error
       porigen OUT NUMBER         : 1 EST 2 SEG
       return                     : Número de año dentro de periodo de revisión /
                                                  hasta periodo de revisión.
   *************************************************************************/
   -- Bug 13296 - RSC - 22/02/2010 - CEM - Revisión módulo de rescates
   FUNCTION f_calc_anyos_porcenpenali(
      psseguro IN NUMBER,
      pfrescat IN NUMBER,
      pctipmov IN NUMBER,
      pnanyos2 OUT NUMBER,
      pnmeses OUT NUMBER,
      pctipo OUT NUMBER,
      pnmesessinpenali OUT NUMBER,
      -- BUG 16217 - 09/2010 - JRH  -  Cuadro de provisiones
      porigen IN NUMBER DEFAULT 2)
      -- Fi BUG 16217 - 09/2010 - JRH
   RETURN NUMBER IS
      v_sproduc      seguros.sproduc%TYPE;
      v_fefecto      seguros.fefecto%TYPE;
      v_frevant      seguros_aho.frevant%TYPE;
      v_frevisio     seguros_aho.frevisio%TYPE;
      v_frevant2     seguros_aho.frevant%TYPE;
      vctipo         prodtraresc.ctipo%TYPE;
      vnmesessinpenali prodtraresc.nmesessinpenali%TYPE;
      vnanyosefecto  prodtraresc.nanyosefecto%TYPE;
      vsidresc       NUMBER;
      vanysrenov     NUMBER;
      v_fecha        DATE;
      nanyos         NUMBER;
      v_nanyos2      NUMBER;   -- Siguiente valor para calcular reducido por meses
      vnmeses        NUMBER;
      pipenali2      NUMBER;
      ptippenali2    NUMBER;
      vnumanyos      NUMBER;
      vfecharev      NUMBER;
      v_fecharef     DATE;
   BEGIN
      IF porigen = 2 THEN
         -- RSC 12/12/2007 (añado la left join con seguros_aho)
         SELECT s.sproduc, s.fefecto, NVL(sa.frevant, s.fefecto), frevisio, sa.frevant
           INTO v_sproduc, v_fefecto, v_frevant, v_frevisio, v_frevant2
           FROM seguros s LEFT JOIN seguros_aho sa ON(s.sseguro = sa.sseguro)
          WHERE s.sseguro = psseguro;
      ELSE
         SELECT s.sproduc, s.fefecto, NVL(sa.frevant, s.fefecto), frevisio, sa.frevant
           INTO v_sproduc, v_fefecto, v_frevant, v_frevisio, v_frevant2
           FROM estseguros s LEFT JOIN estseguros_aho sa ON(s.sseguro = sa.sseguro)
          WHERE s.sseguro = psseguro;
      END IF;

      -- Bug 11923 - APD - 24/12/2009 - se busca el valor de los campos ctipo, nmesessinpenali, nanyosefecto
      -- para la fecha del siniestro (pfrescat)
      SELECT NVL(ctipo, 0), nmesessinpenali, nanyosefecto, sidresc
        INTO vctipo, vnmesessinpenali, vnanyosefecto, vsidresc
        FROM prodtraresc
       WHERE sproduc = v_sproduc
         AND ctipmov = pctipmov
         AND finicio <= TO_DATE(pfrescat, 'yyyymmdd')
         AND(ffin > TO_DATE(pfrescat, 'yyyymmdd')
             OR ffin IS NULL);

      pctipo := vctipo;
      pnmesessinpenali := vnmesessinpenali;

      SELECT MAX(NVL(nfinran, niniran))
        INTO vanysrenov
        FROM detprodtraresc
       WHERE sidresc = vsidresc;

      -- Bug 11923 - APD - 24/12/2009 - si ctipo in (0,1) (v.f.360 0.-Desde fecha última revisión;
      -- 1.-Desde fecha última revisión reducción meses) lo mismo que está haciendo hasta ahora
      -- si ctipo in (2,3) (2.-Hasta fecha revisión;3.-Hasta fecha revisión reducción meses), entonces
      -- v_fecha será la fecha de revisión
      IF vctipo IN(0, 1) THEN
         --Contamos los años transcurridos desde la última revisión (o fefecto) a la fecha del siniestro
         IF NVL(f_parproductos_v(v_sproduc, 'EVOLUPROVMATSEG'), 0) = 1 THEN
            v_fecha := v_frevant;
         ELSE
            -- BUG 16833 - 11/2010 - JRH  - 0016833: F_PENALIZACION incorrecta
            -- v_fecha := v_fefecto;
            v_fecha := NVL(v_frevant, v_fefecto);
         -- Fi BUG 16833 - 11/2010 - JRH
         END IF;

         --Años enteros. TENER EN CUENTA QUE SE LE SUMA 1 AL ACCEDER A F_PENALIZACIÓN
         nanyos := TRUNC(MONTHS_BETWEEN(TO_DATE(pfrescat, 'yyyymmdd'), v_fecha) / 12);
         --Buscamos nanyos-1 para que nos de la penalización anterior
         --Por si necesitamos reducción por meses buscaremos el valor en anyos-1 para despues hacer
         --la reducción por meses (prorratear por meses entre el valor años y años-1 que es donde sucede el siniestro)
         --TENER EN CUENTA QUE SE LE SUMA 1 AL ACCEDER A F_PENALIZACIÓN
         pnanyos2 := nanyos - 1;
         --TENER EN CUENTA QUE SE LE SUMA 1 AL ACCEDER A F_PENALIZACIÓN
         --Meses entre fecha siguiente y fecharescate , Dividido por 12, dará el prorrateo entre los dos penalis de nanyos y v_nanyos2.
         pnmeses := ABS(TRUNC(MONTHS_BETWEEN(v_fecha, TO_DATE(pfrescat, 'yyyymmdd'))));
         pnmeses := 12 - MOD(pnmeses, 12);
      ELSIF vctipo IN(2, 3) THEN
         --Contamos los años hasta la fecha de revisión  para la fecha del siniestro
         v_fecha := v_frevisio;
         --Años enteros. TENER EN CUENTA QUE SE LE SUMA 1 AL ACCEDER A F_PENALIZACIÓN
         nanyos := TRUNC(MONTHS_BETWEEN(v_fecha, TO_DATE(pfrescat, 'yyyymmdd')) / 12);
          --Buscamos nanyos-1 para que nos de la penalización siguiente
         --Por si necesitamos reducción por meses buscaremos el valor en anyos-1 para despues hacer
         --la reducción por meses (prorratear por meses entre el valor años y años-1 que es dondes sucede el siniestro)
         --TENER EN CUENTA QUE SE LE SUMA 1 AL ACCEDER A F_PENALIZACIÓN
         pnanyos2 := nanyos - 1;
         --TENER EN CUENTA QUE SE LE SUMA 1 AL ACCEDER A F_PENALIZACIÓN
          --Meses entre fecha anterior  y fecharescate , Dividido por 12, dará el prorrateo entre los dos penalis de nanyos y v_nanyos2.
         pnmeses := ABS(TRUNC(MONTHS_BETWEEN(v_fecha, TO_DATE(pfrescat, 'yyyymmdd'))));
         pnmeses := 12 - MOD(pnmeses, 12);
      ELSIF vctipo IN(4, 5) THEN
         --Si es mixto miramos los años desde la fecha ultima revisión
         IF NVL(f_parproductos_v(v_sproduc, 'EVOLUPROVMATSEG'), 0) = 1 THEN
            v_fecha := v_frevant;
         ELSE
             -- BUG 16833 - 11/2010 - JRH  - 0016833: F_PENALIZACION incorrecta
            -- v_fecha := v_fefecto;
            v_fecha := NVL(v_frevant, v_fefecto);
         -- Fi BUG 16833 - 11/2010 - JRH
         END IF;

         --Son estos
         nanyos := TRUNC(MONTHS_BETWEEN(TO_DATE(pfrescat, 'yyyymmdd'), v_fecha) / 12);
         pnmeses := ABS(TRUNC(MONTHS_BETWEEN(v_fecha, TO_DATE(pfrescat, 'yyyymmdd'))));
         pnmeses := 12 - MOD(pnmeses, 12);
         pnanyos2 := nanyos - 1;

         --Si estos años estan dentro del margen vnanyosefecto estamos en el caso de ctipo=0,1
         IF vnanyosefecto < nanyos + 1 THEN   --Si nos pasamos de vnanyosefecto, es que hemos de ir a frevisió
            --Si no, se supone que a partir de ahi se calculo hasta fecha revision (ctipo 2,3)
            --Buscamos años hasta fecha revisión
            v_fecha := v_frevisio;
            nanyos := TRUNC(MONTHS_BETWEEN(v_fecha, TO_DATE(pfrescat, 'yyyymmdd')) / 12);
            nanyos := vanysrenov - nanyos - 1;
            pnanyos2 := nanyos - 1;
            pnmeses := ABS(TRUNC(MONTHS_BETWEEN(v_fecha, TO_DATE(pfrescat, 'yyyymmdd'))));
            pnmeses := MOD(pnmeses, 12);
         END IF;
      --Buscamos vnmeses por si nos piden resucción por meses
      END IF;

      RETURN nanyos;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'CALC_RESCATES.f_calc_anyos_porcenpenali', NULL,
                     'parametros: psseguro=' || psseguro || ' pfrescat =' || pfrescat
                     || ' pctipmov =' || pctipmov,
                     SQLERRM);
         RETURN NULL;
   END f_calc_anyos_porcenpenali;

   /*************************************************************************
       Cálculo del porcentaje o importe de penalización

       param in psseguro          : Sseguro
       param in pfrescat          : Fecha de rescate
       param in pctipmov          : Tipo de movimiento (3: Rescate total / 2: Rescate parcial)
       param out ptippenali       : Tipo de penalización (Porcentaje / Importe)
       porigen In NUMBER DEFAULT 2 : 1:EST ; 2 SEG
       return                     : Porcentaje o improte de penalización.
   *************************************************************************/
   FUNCTION f_get_penalizacion(
      psseguro IN NUMBER,
      pfrescat IN NUMBER,
      pctipmov IN NUMBER,
      ptippenali OUT NUMBER,
      -- BUG 16217 - 09/2010 - JRH  -  Cuadro de provisiones
      porigen IN NUMBER DEFAULT 2)
      -- Fi BUG 16217 - 09/2010 - JRH
   RETURN NUMBER IS
      v_sproduc      NUMBER;
      nanyos         NUMBER;
      v_fefecto      DATE;
      num_err        NUMBER;
      pipenali       NUMBER;
      v_frevant      DATE;
      v_fecha        DATE;
      -- RSC 19/12/2007
      v_anyosibex    NUMBER;
      -- Bug 11923 - APD - 24/12/2009
      vctipo         prodtraresc.ctipo%TYPE;
      vnmesessinpenali prodtraresc.nmesessinpenali%TYPE;
      vnanyosefecto  prodtraresc.nanyosefecto%TYPE;
      v_frevisio     seguros_aho.frevisio%TYPE;
      v_nanyos2      NUMBER;   -- Siguiente valor para calcular reducido por meses
      pipenali2      NUMBER;
      ptippenali2    NUMBER;
      v_frevant2     DATE;
      vnmeses        NUMBER;
      vsidresc       NUMBER;
      vanysrenov     NUMBER;
      vnumanyos      NUMBER;
      vfecharev      NUMBER;
      v_fecharef     DATE;
      err_data       EXCEPTION;
      vtablas        VARCHAR2(10);
   BEGIN
      IF porigen = 2 THEN
         -- RSC 12/12/2007 (añado la left join con seguros_aho)
         SELECT s.sproduc, s.fefecto, NVL(sa.frevant, s.fefecto), frevisio, sa.frevant
           INTO v_sproduc, v_fefecto, v_frevant, v_frevisio, v_frevant2
           FROM seguros s LEFT JOIN seguros_aho sa ON(s.sseguro = sa.sseguro)
          WHERE s.sseguro = psseguro;

         vtablas := 'SEG';
      ELSE
         SELECT s.sproduc, s.fefecto, NVL(sa.frevant, s.fefecto), frevisio, sa.frevant
           INTO v_sproduc, v_fefecto, v_frevant, v_frevisio, v_frevant2
           FROM estseguros s LEFT JOIN estseguros_aho sa ON(s.sseguro = sa.sseguro)
          WHERE s.sseguro = psseguro;

         vtablas := 'EST';
      END IF;

      -- Bug 13296 - RSC - 22/02/2010 - CEM - Revisión módulo de rescates
      nanyos := calc_rescates.f_calc_anyos_porcenpenali(psseguro, pfrescat, pctipmov,
                                                        v_nanyos2, vnmeses, vctipo,
                                                        vnmesessinpenali, porigen);

      IF nanyos IS NULL THEN
         RAISE err_data;
      END IF;

      -- Fin Bug 13296

      --Buscamos penalización para nanyos
      num_err := f_penalizacion(pctipmov, nanyos + 1, v_sproduc, psseguro,
                                TO_DATE(pfrescat, 'yyyymmdd'), pipenali, ptippenali, vtablas,
                                1);

      IF vctipo IN(1, 3, 5) THEN   --reducido por meses
         --Buscamos penalización para v_nanyos2
         IF v_nanyos2 < 0 THEN
            pipenali2 := 0;   --Penalización 0
            ptippenali2 := ptippenali;
         ELSE
            num_err := f_penalizacion(pctipmov, v_nanyos2 + 1, v_sproduc, psseguro,
                                      TO_DATE(pfrescat, 'yyyymmdd'), pipenali2, ptippenali2,
                                      vtablas, 1);
         END IF;

         -- Obtenemos la recucción por meses (entre pipenali y pipenali2)
         pipenali := pipenali - ((pipenali - pipenali2) / 12) * GREATEST(vnmeses - 1, 0);
      END IF;

      -- Bug 16716 - RSC - 16/11/2010 - CRS: INCORPORACIÓ INFO ADDICIONAL PANTALLA I DOCUMENT
      IF vctipo IN(0, 1) THEN
         -- Fin Bug 16716
         IF v_frevant2 IS NULL THEN
            vnmesessinpenali := 0;   --Si no ha pasaado revisión vnmesessinpenali siempre ha de ser 0
         END IF;
      -- Bug 16716 - RSC - 16/11/2010 - CRS: INCORPORACIÓ INFO ADDICIONAL PANTALLA I DOCUMENT
      END IF;

      -- Fin Bug 16716
      IF NVL(vnmesessinpenali, 0) <> 0 THEN   --Si el rescate está entre estos meses respecto a la fecha de revisión, la penalización es 0
         -- BUG 12986- 02/2010 - JRH  - 0012986: CEM - CRS - Ajustes productos CRS
         -- Bug 16494 - RSC - 27/10/2010 - CRS: INCORPORACIÓ INFO ADDICIONAL PANTALLA I DOCUMENT (añadimos >=)
         IF TO_DATE(pfrescat, 'yyyymmdd') >= v_frevisio THEN
            -- Fin Bug 16494
            v_fecharef := v_frevisio;
         ELSE
            v_fecharef := v_frevant;
         END IF;

         IF v_frevant2 IS NULL
            AND v_fecharef = v_frevant THEN
            NULL;
         ELSE
            --IF MONTHS_BETWEEN(TO_DATE(pfrescat, 'yyyymmdd'), v_frevisio) <= vnmesessinpenali THEN
            IF MONTHS_BETWEEN(TO_DATE(pfrescat, 'yyyymmdd'), v_fecharef) <= vnmesessinpenali THEN
               pipenali := 0;
            END IF;
         END IF;
      -- Fi BUG 12986- 02/2010 - JRH
      END IF;

      IF (NVL(f_parproductos_v(v_sproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1
          AND NVL(f_parproductos_v(v_sproduc, 'USA_EDAD_CFALLAC'), 0) = 1
          AND NVL(f_parproductos_v(v_sproduc, 'PRODUCTO_MIXTO'), 0) <> 1) THEN   -- Ibex 35
         v_anyosibex := MONTHS_BETWEEN(TO_DATE(pfrescat, 'yyyymmdd'), v_fecha);

         IF v_anyosibex > 6 THEN   -- 6 meses y un dia
            pipenali := 0;
         END IF;
      END IF;

      RETURN pipenali;
   EXCEPTION
      WHEN err_data THEN
         p_tab_error(f_sysdate, f_user, 'calc_rescates.fporcenpenali', NULL,
                     'parametros: psseguro=' || psseguro || ' pfrescat =' || pfrescat
                     || ' pctipmov =' || pctipmov,
                     SQLERRM);
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'calc_rescates.fporcenpenali', NULL,
                     'parametros: psseguro=' || psseguro || ' pfrescat =' || pfrescat
                     || ' pctipmov =' || pctipmov,
                     SQLERRM);
         RETURN NULL;
   END f_get_penalizacion;

   -- Fin Bug 13296

   /*************************************************************************
       Cálculo de años dentro de periodo revisión / hasta periodo revisión.

       param in psseguro          : Sseguro
       param in pfrescat          : Fecha de rescate
       param in pctipmov          : Tipo de movimiento (3: Rescate total / 2: Rescate parcial)
       param in porigen           : 1 EST/2 SEG
       return                     : Número de año dentro de periodo de revisión /
                                                  hasta periodo de revisión.
   *************************************************************************/
   -- Bug 13296 - RSC - 22/02/2010 - CEM - Revisión módulo de rescates
   FUNCTION f_get_anyos_porcenpenali(
      psseguro IN NUMBER,
      pfrescat IN NUMBER,
      pctipmov IN NUMBER,
      -- BUG 16217 - 09/2010 - JRH  -  Cuadro de provisiones
      porigen NUMBER DEFAULT 2)
      -- Fi BUG 16217 - 09/2010 - JRH
   RETURN NUMBER IS
      v_anyos        NUMBER;
      v_dummuy1      NUMBER;
      v_dummuy2      NUMBER;
      v_dummuy3      NUMBER;
      v_dummuy4      NUMBER;
   BEGIN
      v_anyos := calc_rescates.f_calc_anyos_porcenpenali(psseguro, pfrescat, pctipmov,
                                                         v_dummuy1, v_dummuy2, v_dummuy3,
                                                         v_dummuy4, porigen);
      RETURN v_anyos;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'CALC_RESCATES.f_get_anyos_porcenpenali', NULL,
                     'parametros: psseguro=' || psseguro || ' pfrescat =' || pfrescat
                     || ' pctipmov =' || pctipmov,
                     SQLERRM);
         RETURN NULL;
   END f_get_anyos_porcenpenali;

   /*************************************************************************
       Cálculo de valoración de reserva en siniestros de muerte (garantás de riesgo)

         param in pnsesion          : sesion
       param in psseguro          : Sseguro
       param in pfrescat          : Fecha de rescate
       param in pcgarant          : Identificador de garantía
       return                     : Número de año dentro de periodo de revisión /
                                                  hasta periodo de revisión.
   *************************************************************************/
   -- Bug 14160 - RSC - 16/04/2010 - CEM800 - Adaptar packages de productos de inversión al nuevo módulo de siniestros
   FUNCTION fvalresc_finv(
      pnsesion IN NUMBER,
      psseguro IN NUMBER,
      pfrescat IN NUMBER,
      pcgarant IN NUMBER)
      RETURN NUMBER IS
      xicaprisc      NUMBER;
   BEGIN
      xicaprisc := pac_propio.f_irescate_finv(psseguro, TO_DATE(pfrescat, 'YYYYMMDD'),
                                              pcgarant);
      RETURN ROUND(xicaprisc, 2);
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'calc_rescates.fvalresctotaho_finv', NULL,
                     'parametros: psseguro=' || psseguro || ' pfrescat=' || pfrescat, SQLERRM);
         RETURN NULL;
   END fvalresc_finv;

-- Fin Bug 14160
   FUNCTION fvalresctotrie(
      pnsesion IN NUMBER,
      psseguro IN NUMBER,
      pfrescat IN NUMBER,
      pcgarant IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      xicaprisc      NUMBER;
   BEGIN
      xicaprisc := pac_propio.f_irescate_rie(psseguro, TO_DATE(pfrescat, 'YYYYMMDD'),
                                             pcgarant);
      RETURN ROUND(xicaprisc, 2);
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'calc_rescates.fvalresctotrie', NULL,
                     'parametros: psseguro=' || psseguro || ' pfrescat=' || pfrescat, SQLERRM);
         RETURN NULL;
   END fvalresctotrie;

   FUNCTION f_penal_sialp(
      pnsesion IN NUMBER,
      pprovisi IN NUMBER,
      psproduc IN NUMBER,
      pfsinies IN NUMBER,
      pnsinies IN NUMBER,
      psseguro IN NUMBER)
      RETURN NUMBER IS
      vparam         VARCHAR2(100)
         := 'psproduc=' || psproduc || ' pfsinies=' || pfsinies || ' pnsinies=' || pnsinies
            || ' psseguro=' || psseguro;
      vpaso          NUMBER;
      vpenali        NUMBER;
      vfrevant       DATE;
      vaporta        NUMBER;
      vprovi         NUMBER;
   BEGIN
--Si se rescata antes de la primera revisión de intereses (seguros_aho.frevant NULL o no):
--En este caso el ICAPRIS será la provisión matemática y la penalización IPENALI será (la provisión matemática - las aportaciones realizadas)
--(será los intereses)
--Si se rescate después de la primera revisión de intereses:
--El ICAPRIS será la provisión a fecha de rescate
--El IPENALI será (la provisión a fehca de rescate) - (provisión a fecha de última revisión + aportaciones realizadas desde la última revisión)
--(será los intereses desde la última revisión)
--Siempre IVALSIN=ICAPRIS-IPENALI
--Las aportaciones se obtendrán de ctaseguro suando los registros tipo 1 y 2
--Para calcular las aportaciones a partir de la última renovación se han de calcular a partir del último saldo antes de la fecha de renovación,
--para evitar considerar las que se puedan haber hecho el mismo día de la renovación de intereses y que no estén contempladas en la provisión
      vpaso := 0;

      BEGIN
         SELECT frevant
           INTO vfrevant
           FROM seguros_aho
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 0;
      END;

      IF vfrevant IS NULL THEN   --Todavía no ha renovado intereses
         --Vamos a calcular las aporaciones realizadas
         SELECT NVL(SUM(DECODE(cmovimi,
                               1, imovimi,
                               2, imovimi,
                               4, imovimi,
                               8, imovimi,
                               9, imovimi,
                               10, imovimi,
                               -imovimi)),
                    0)
           INTO vaporta
           FROM ctaseguro
          WHERE sseguro = psseguro
            AND cmovimi IN(1, 2, 4,   --1,2,4 APORTACIONS
                                   8,   -- Traspaso de entrada
                                     9,   --Part. Benef.
                                       33, 34, 27, 51,   --anulación de aportacion
                                                      47,   -- traspasos de salida
                                                         53,   -- pago prestación
                                                            10   -- anulacion prestacion
                                                              );

         vpenali := GREATEST((pprovisi - vaporta), 0);
      ELSE   -- Ya ha renovado intereses alguna vez
         SELECT NVL(SUM(DECODE(cmovimi,
                               1, imovimi,
                               2, imovimi,
                               4, imovimi,
                               8, imovimi,
                               9, imovimi,
                               10, imovimi,
                               -imovimi)),
                    0)
           INTO vaporta
           FROM ctaseguro
          WHERE sseguro = psseguro
            AND ffecmov >= vfrevant
            AND cmovimi IN(1, 2, 4,   --1,2,4 APORTACIONS
                                   8,   -- Traspaso de entrada
                                     9,   --Part. Benef.
                                       33, 34, 27, 51,   --anulación de aportacion
                                                      47,   -- traspasos de salida
                                                         53,   -- pago prestación
                                                            10   -- anulacion prestacion
                                                              );

         vprovi := calc_rescates.fvalresctotaho(0, psseguro, TO_CHAR(vfrevant, 'YYYYMMDD'));
         vpenali := pprovisi - (vprovi + vaporta); --Bug 41488/232317 - 08/04/2016
      END IF;

      --vpenali := 10;
      RETURN vpenali;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'calc_rescates.f_penal_sialp', vpaso,
                     'parametros: ' || vparam, SQLERRM);
         RETURN 0;
   END f_penal_sialp;
END calc_rescates;

/

  GRANT EXECUTE ON "AXIS"."CALC_RESCATES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."CALC_RESCATES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."CALC_RESCATES" TO "PROGRAMADORESCSI";
