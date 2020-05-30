--------------------------------------------------------
--  DDL for Package Body PAC_LIQUIDA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_LIQUIDA" AS
/******************************************************************************
   NOMBRE:      PAC_LIQUIDA
   PROPÓSITO:   Nuevo paquete de la capa lógica que tendrá las funciones para
                la liquidación de comisiones.

--   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        02/06/2009   JRB               1. Creación del package.
   2.0        02/11/2009   APD               2. 0011595: CEM - Siniestros. Adaptación al nuevo módulo de siniestros
   3.0        28/12/2009   SVJ/MCA           3. Modificación del package para incluir nuevas módulo
   4.0        03/05/2010   JTS               4. 0014301: APR707 - conceptos fiscales o no fiscales
   5.0        05/05/2010   MCA               5. 0014344: Incorporar a transferencias los pagos de liquidación de comisiones
   6.0        29/03/2011   JMF               6. 0018046: Liquidaciones comisiones recibos externos.
   7.0        14/07/2011   ICV               7. 0018843: LCOL003 - Liquidación de comisiones
   8.0        02/08/2011   JMF               8. 0019154 AGM703 - Adaptar nuevo proceso de liquidaciones a los productos externos
   9.0        18/10/2011   JMC               9. 0019586: AGM003-Comisiones Indirectas a distintos niveles.
   10.0       29/09/2011   DRA               10. 0019069: LCOL_C001 - Co-corretaje
   11.0       11/11/2011   JMC               11. 0020136: AGM003-Incluir los pagos de comisiones en el fichero de transferencias
   12.0       02/11/2011   JMP               12. 0018423: LCOL000 - Multimoneda
   13.0       04/11/2011   JMP               13. 0019791: LCOL_A001-Modificaciones de fase 0 en la consulta de recibos
   14.0       13/12/2011   APD               14. 0020287: LCOL_C001 - Tener en cuenta campo Subvención
   15.0       29/12/2011   JMP               15. 0020559: LCOL_A001 - UAT-ADM - Error en liquidacio agents
   16.0       31/01/2012   JGR               16. 0021164: LCOL_A001: Proceso de liquidación, ajuste para los extornos
   17.0       13/03/2012   JMC               17. 0021606: AGM - Aplicar cambios en el fichero de Reale/ocaso
   18.0       20/02/2012   APD               18. 0021230: LCOL: Comisiones indirectas en el proceso de liquidaciones
   19.0       22/05/2012   JMC               19. 0022337: AGM - Descuadre en la liquidación de comisiones
   20.0       29/06/2012   MDS               20. 0022637: LCOL: Listado de liquidación previa y real
   21.0       27/07/2012   JGR               21. 0022753: MDP_A001-Cierre de remesa
   22.0       26/09/2012   JGR               22. 0022346: LCOL_A003-Cobro parcial de los recibos Fase 2
   23.0       17/10/2012   JGR               23. 0022346: LCOL_A003-Cobro parcial de los recibos Fase 2 - 0126249
   24.0       20/11/2012   JGR               24. 0024803: (POSDE100)-Desarrollo-GAPS Administracion-Id 61 - Facturas intermediario
   25.0       04/01/2013   APD               25. 0024814: (POSDE100)-Desarrollo-GAPS Administracion-Id 110 - Conceptos manuales e impuestos
   26.0       08/02/2013   APD               26. 0026022: LCOL: Liquidaciones de Colectivos
   27.0       13/02/2013   DRA               27. 0026036: LCOL: Interface de comisiones liquidadas
   28.0       18/03/2013   CPM               28. 0026478: LCOL999-Contabilidad - Tener en cuenta las liquidaciones negativas
   29.0       22/03/2013   JMF               0026398: LCOL_A003-LCOL: Proceso de liquidaci?n
   30.0       16/05/2013   AMJ               30. 0026993: LCOL_A005-Error en liquidaciones de comisiones cuando se realiza una devolucion
   31.0       28/06/2013   MMM               31. 0027518: LCOL_PROD-0008271: LIBELULA IAXIS- ERROR COMISIONES DE AHORRO
   32.0       09/07/2013   MCA               32. 0027599 : Liquidación de apuntes manuales cuando no hay recibos a liquidar
   33.0       16/07/2013   MMM               33. 0027518: LCOL_PROD-0008271: LIBELULA IAXIS- ERROR COMISIONES DE AHORRO - NOTA 0149187
   34.0       10/09/2013   JMF               0027043: Cuenta corriente de agente
   35.0       04/10/2013   JMF               0027043: Cuenta corriente de agente
   36.0       23/10/2013   JLV               0028611: Liquidación agente corretaje
   37.0       29/10/2013   FAL               0028371: PROBLEMA CON LAS COMISIONES INDIRECTAS
   38.0       19/11/2013   JLV               28964/158955 - 28611: Problemas en liquidaciones.
   39.0       20/11/2013   AFM               0027043/157331: Cta corriente agente. Se incorporar parametro nuevo COMIS_DD_CAMB_LIQ en
                                                parempresa que indica los días a sumar al fin de mes y con la fecha resultante buscar
                                    el contravalor que se ha de aplicar en la liquidación, si no es final de mes la liquidación
                                    se contravalorará a día de petición. Solo se aplica cuando el PAREMPRESA.CALC_COMIND = 1 y
                                    cuando es MULTIMONEDA.
   40.0       21/11/2013   JLV               28964/158945: Aplicación comisiones Liberty Web sólo al agente lider
   41.0       26/11/2013   FAL               0029023: AGM800 - Agrupación de pago al grupo coordinación
   42.0       11/12/2013   JMF               0029334 RSA998. Liquidacion desglosada
   43.0       08/01/2014   MMM               0029471: LCOL_C004-LCOL: Ajuste en el proceso de liquidacion de Convenio Liberty Web
   44.0       30/05/2014   MCA               0030026: LCOL ajuste para los recibos de ahorro que han sido anulados, será el signo del concepto
                                                      58 que indicará si va al D o al H en contabilidad.
   45.0       21/05/2014   FAL               0031489: TRQ003-TRQ: Gap de comercial. Liquidación a nivel de Banco
   46.0       22/0572014   dlF               0029023: AGM800 - Agrupación de pago al grupo coordinación
   47.0       29/10/2014   AQ                0033115: AGM301-error en el calculo de la comisión indirecta de un extorno (REAL)
   48.0       04/11/2014   JAMF              0033155: AGM301-Mantenimiento de cuentas técnicas de comisiones (bug hermano interno)
   49.0       18/02/2015   JAMF              31321 RSA - Liquidación de comisiones no tiene en cuenta la fecha
   50.0       21/09/2015   AFM               035979/214061: Deshacer cambio realizado.
   51.0       10/12/2015   AFM               0039204: Activación del bloqueo de liquidaciones (corte cuentas en colombia).
   52.0       10/12/2015   JCP               0039421: Creacion funciones f_signo_comision_age y f_validar_ccc_age, modificacion f_set_recibos_liq y f_lliqudia age
   53.0       10/12/2017   FAC               CONF-439 CONF_ADM-05_CAMBIOS_PROCESO_COMISIONES
   ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   --
   -- BUG - 0035181 - 200356 - 20/03/2015 - JMF - Contabilidad
   -- Averiguar si un recibo es autoliquidado (0-No, 1-Si)
   -- Se utiliza en selects de contabilidad DETMODCONTA_DIA
   FUNCTION f_esautoliquidado(p_rec IN NUMBER, p_smovrec IN NUMBER)
      RETURN NUMBER IS
      n_ret          NUMBER;
   BEGIN
      -- Buscamos la última liquidación de la fecha, y si existe en las 2 tablas es autoliquidado
      /*
      SELECT DECODE(COUNT(1), 0, 0, 1)
        INTO n_ret
        FROM DUAL
       WHERE EXISTS(SELECT 1
                      FROM liquidalin c, liquidacobros d
                     WHERE c.nrecibo = p_rec
                       AND c.nliqmen = (SELECT MAX(b.nliqmen)
                                          FROM liquidalin a, liquidacab b
                                         WHERE a.nrecibo = p_rec
                                           AND b.cagente = a.cagente
                                           AND b.cempres = a.cempres
                                           AND b.nliqmen = a.nliqmen
                                           AND b.ctipoliq = 0
                                           AND b.fliquid <= p_fec)
                       AND d.cagente = c.cagente
                       AND d.cempres = c.cempres
                       AND d.nliqmen = c.nliqmen);
      */
      --Inicio Bug 41094  Ajuste para smovrec envez de por fecha
      SELECT DECODE(COUNT(1), 0, 0, 1)
        INTO n_ret
        FROM liquidacab a, liquidalin b
       WHERE a.cestautoliq = 2
         AND b.smovrec = p_smovrec
         AND a.ctipoliq = 0
         AND b.nliqmen = a.nliqmen
         AND b.cagente = a.cagente
         AND b.cempres = a.cempres
         AND b.nrecibo = p_rec;
      --Fin Bug 41094

      RETURN n_ret;
   END f_esautoliquidado;

   /***********************************************************************
   FUNCTION f_ccobban_autoliquida
   Devuelve código cobrador bancario de autoliquidaciones
   param in p_rec: recibo
   param in p_mov: smovrec del recibo
   return:         ccobban
   -- JMF  bug 0035609/0206695 10/06/2015 -- Se utiliza en select contabilidad
   ***********************************************************************/
   FUNCTION f_ccobban_autoliquida(p_rec IN NUMBER, p_mov IN NUMBER)
      RETURN NUMBER IS
      --
      v_ret          cobbancario.ccobban%TYPE;
      v_fec          DATE;
   BEGIN
      SELECT GREATEST(r.fefecto, TRUNC(m.fefeadm))
        INTO v_fec
        FROM recibos r, movrecibo m
       WHERE r.nrecibo = p_rec
         AND m.nrecibo = r.nrecibo
         AND m.smovrec = p_mov;

      SELECT MAX(c.cbanco)
        INTO v_ret
        FROM liquidacab a, liquidalin b, liquidacobros c
       WHERE a.cestautoliq = 2
         AND a.fliquid = (SELECT MAX(a1.fliquid)
                            FROM liquidacab a1
                           WHERE a1.cempres = b.cempres
                             AND a1.cagente = b.cagente
                             AND a1.fliquid <= v_fec   /*p_fec*/
                             AND a1.ctipoliq = 0
                             AND a1.cestautoliq = 2
                             AND a1.nliqmen = b.nliqmen)
         AND a.ctipoliq = 0
         AND b.nliqmen = a.nliqmen
         AND b.cagente = a.cagente
         AND b.cempres = a.cempres
         AND b.nrecibo = p_rec   /*p_rec*/
         AND c.cempres = b.cempres
         AND c.cagente = b.cagente
         AND c.sproliq = a.sproliq;

      RETURN v_ret;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_LIQUIDA.f_ccobban_autoliquida', 1,
                     'parametros: p_rec =' || p_rec || ' mov=' || p_mov,
                     SQLCODE || ' ' || SQLERRM);
         RETURN NULL;
   END f_ccobban_autoliquida;

   --
   -- Bug 0029334 - JMF - 11/12/2013
   -- Genera desglose de una linea de liquidacion comisión directa, de algunos conceptos
   --
   -- Bug 0030978 - JMF - 28/04/2014
   FUNCTION f_crea_liquidalindet_dir(
      p_nliqmen IN NUMBER,
      p_cagente IN NUMBER,
      p_nliqlin IN NUMBER,
      p_cempres IN NUMBER,
      p_nrecibo IN NUMBER,
      p_signo IN NUMBER,
      pfecliq IN DATE,
      pnorden IN NUMBER,
      psmovrec IN NUMBER)
      RETURN NUMBER IS
      --
      v_pas          NUMBER(4) := 0;
      v_obj          VARCHAR2(500) := 'PAC_LIQUIDA.f_crea_liquidalindet_dir';
      v_par          VARCHAR2(500)
         := 'lm=' || p_nliqmen || ' ag=' || p_cagente || ' ll=' || p_nliqlin || ' em='
            || p_cempres || ' re=' || p_nrecibo || ' si=' || p_signo || ' f=' || pfecliq
            || ' or=' || pnorden || ' sm=' || psmovrec;
      v_numerr       NUMBER;
      v_signo        NUMBER;
      v_cmultimon    NUMBER := NVL(pac_parametros.f_parempresa_n(p_cempres, 'MULTIMONEDA'), 0);
      v_cmoncia      NUMBER := pac_parametros.f_parempresa_n(p_cempres, 'MONEDAEMP');
      v_dd_cambio    NUMBER
                     := NVL(pac_parametros.f_parempresa_n(p_cempres, 'COMIS_DD_CAMB_LIQ'), 99);
      v_itasa        eco_tipocambio.itasa%TYPE;
      v_fcambio      DATE;
      v_fechac       DATE;
      v_icomisi_tot  liquidalin.icomisi%TYPE;
      v_icomisi_moncia_tot liquidalin.icomisi_moncia%TYPE;
      v_11exmon      liquidalindet.c11ex_moncia%TYPE;
      v_17exmon      liquidalindet.c17ex_moncia%TYPE;
      v_44afmon      liquidalindet.c44af_moncia%TYPE;
      v_44exmon      liquidalindet.c44ex_moncia%TYPE;
      v_47afmon      liquidalindet.c47af_moncia%TYPE;
      v_47exmon      liquidalindet.c47ex_moncia%TYPE;

      CURSOR c1 IS
         SELECT 1
           FROM detrecibos
          WHERE nrecibo = p_nrecibo
            AND cconcep IN(11, 44, 45, 46);

      CURSOR c3 IS
         SELECT p_cempres, p_nliqmen, p_cagente, p_nliqlin, p_nrecibo,
                v_signo * SUM(DECODE(cconcep, 11, DECODE(tasaimp, NULL, 0, iconcep), 0)) c11af,
                v_signo * SUM(DECODE(cconcep, 11, DECODE(tasaimp, NULL, iconcep, 0), 0)) c11ex,
                0 c17af, 0 c17ex,
                v_signo * SUM(DECODE(cconcep, 44, DECODE(tasaimp, NULL, 0, iconcep), 0)) c44af,
                v_signo * SUM(DECODE(cconcep, 44, DECODE(tasaimp, NULL, iconcep, 0), 0)) c44ex,
                v_signo * SUM(DECODE(cconcep, 45, DECODE(tasaimp, NULL, 0, iconcep), 0)) c45af,
                v_signo * SUM(DECODE(cconcep, 45, DECODE(tasaimp, NULL, iconcep, 0), 0)) c45ex,
                v_signo * SUM(DECODE(cconcep, 46, DECODE(tasaimp, NULL, 0, iconcep), 0)) c46af,
                v_signo * SUM(DECODE(cconcep, 46, DECODE(tasaimp, NULL, iconcep, 0), 0)) c46ex,
                0 c47af, 0 c47ex, 0 c48af, 0 c48ex, 0 c49af, 0 c49ex,
                f_round(SUM(DECODE(cconcep,
                                   11, DECODE(tasaimp,
                                              NULL, 0,
                                              DECODE(v_dd_cambio,
                                                     99, iconcep_monpol * v_signo,
                                                     NVL(iconcep, 0) * v_signo * v_itasa)),
                                   0)),
                        v_cmoncia) c11af_moncia,
                f_round(SUM(DECODE(cconcep,
                                   11, DECODE(tasaimp,
                                              NULL, DECODE(v_dd_cambio,
                                                           99, iconcep_monpol * v_signo,
                                                           NVL(iconcep, 0) * v_signo * v_itasa),
                                              0),
                                   0)),
                        v_cmoncia) c11ex_moncia,
                0 c17af_moncia, 0 c17ex_moncia,
                f_round(SUM(DECODE(cconcep,
                                   44, DECODE(tasaimp,
                                              NULL, 0,
                                              DECODE(v_dd_cambio,
                                                     99, iconcep_monpol * v_signo,
                                                     NVL(iconcep, 0) * v_signo * v_itasa)),
                                   0)),
                        v_cmoncia) c44af_moncia,
                f_round(SUM(DECODE(cconcep,
                                   44, DECODE(tasaimp,
                                              NULL, DECODE(v_dd_cambio,
                                                           99, iconcep_monpol * v_signo,
                                                           NVL(iconcep, 0) * v_signo * v_itasa),
                                              0),
                                   0)),
                        v_cmoncia) c44ex_moncia,
                f_round(SUM(DECODE(cconcep,
                                   45, DECODE(tasaimp,
                                              NULL, 0,
                                              DECODE(v_dd_cambio,
                                                     99, iconcep_monpol * v_signo,
                                                     NVL(iconcep, 0) * v_signo * v_itasa)),
                                   0)),
                        v_cmoncia) c45af_moncia,
                f_round(SUM(DECODE(cconcep,
                                   45, DECODE(tasaimp,
                                              NULL, DECODE(v_dd_cambio,
                                                           99, iconcep_monpol * v_signo,
                                                           NVL(iconcep, 0) * v_signo * v_itasa),
                                              0),
                                   0)),
                        v_cmoncia) c45ex_moncia,
                f_round(SUM(DECODE(cconcep,
                                   46, DECODE(tasaimp,
                                              NULL, 0,
                                              DECODE(v_dd_cambio,
                                                     99, iconcep_monpol * v_signo,
                                                     NVL(iconcep, 0) * v_signo * v_itasa)),
                                   0)),
                        v_cmoncia) c46af_moncia,
                f_round(SUM(DECODE(cconcep,
                                   46, DECODE(tasaimp,
                                              NULL, DECODE(v_dd_cambio,
                                                           99, iconcep_monpol * v_signo,
                                                           NVL(iconcep, 0) * v_signo * v_itasa),
                                              0),
                                   0)),
                        v_cmoncia) c46ex_moncia,
                0 c47af_moncia, 0 c47ex_moncia, 0 c48af_moncia, 0 c48ex_moncia, 0 c49af_moncia,
                0 c49ex_moncia
           FROM (SELECT cconcep, iconcep, iconcep_monpol,
                        (SELECT   COUNT(1)
                             FROM imprec i, recibos r, seguros s
                            WHERE i.cconcep = 4
                              AND i.cramo = s.cramo
                              AND i.cmodali = s.cmodali
                              AND i.ctipseg = s.ctipseg
                              AND i.ccolect = s.ccolect
                              AND i.cactivi = s.cactivi
                              AND i.cempres = s.cempres
                              AND s.sseguro = r.sseguro
                              AND r.nrecibo = d.nrecibo
                              AND i.cgarant = d.cgarant
                         GROUP BY r.nrecibo, i.cgarant) tasaimp
                   FROM detrecibos d
                  WHERE d.nrecibo = p_nrecibo
                    AND d.cconcep IN(11, 44, 45, 46)
                    AND NOT EXISTS(SELECT 1
                                     FROM detmovrecibo_parcial dp
                                    WHERE dp.nrecibo = p_nrecibo)
                 UNION ALL
                 SELECT cconcep, iconcep, iconcep_monpol,
                        (SELECT   COUNT(1)
                             FROM imprec i, recibos r, seguros s
                            WHERE i.cconcep = 4
                              AND i.cramo = s.cramo
                              AND i.cmodali = s.cmodali
                              AND i.ctipseg = s.ctipseg
                              AND i.ccolect = s.ccolect
                              AND i.cactivi = s.cactivi
                              AND i.cempres = s.cempres
                              AND s.sseguro = r.sseguro
                              AND r.nrecibo = d.nrecibo
                              AND i.cgarant = d.cgarant
                         GROUP BY r.nrecibo, i.cgarant) tasaimp
                   FROM detmovrecibo_parcial d
                  WHERE d.nrecibo = p_nrecibo
                    AND(pnorden IS NULL
                        OR d.norden = pnorden)
                    AND d.smovrec = psmovrec
                    AND d.cconcep IN(11, 44, 45, 46));

      CURSOR c4 IS
         SELECT p_cempres, p_nliqmen, p_cagente, p_nliqlin, p_nrecibo,
                v_signo * SUM(DECODE(cconcep, 11, DECODE(tasaimp, NULL, 0, iconcep), 0)) c11af,
                v_signo * SUM(DECODE(cconcep, 11, DECODE(tasaimp, NULL, iconcep, 0), 0)) c11ex,
                0 c17af, 0 c17ex,
                v_signo * SUM(DECODE(cconcep, 44, DECODE(tasaimp, NULL, 0, iconcep), 0)) c44af,
                v_signo * SUM(DECODE(cconcep, 44, DECODE(tasaimp, NULL, iconcep, 0), 0)) c44ex,
                v_signo * SUM(DECODE(cconcep, 45, DECODE(tasaimp, NULL, 0, iconcep), 0)) c45af,
                v_signo * SUM(DECODE(cconcep, 45, DECODE(tasaimp, NULL, iconcep, 0), 0)) c45ex,
                v_signo * SUM(DECODE(cconcep, 46, DECODE(tasaimp, NULL, 0, iconcep), 0)) c46af,
                v_signo * SUM(DECODE(cconcep, 46, DECODE(tasaimp, NULL, iconcep, 0), 0)) c46ex,
                0 c47af, 0 c47ex, 0 c48af, 0 c48ex, 0 c49af, 0 c49ex,
                f_round(SUM(DECODE(cconcep,
                                   11, DECODE(tasaimp,
                                              NULL, 0,
                                              DECODE(v_dd_cambio,
                                                     99, iconcep_monpol * v_signo,
                                                     NVL(iconcep, 0) * v_signo * v_itasa)),
                                   0)),
                        v_cmoncia) c11af_moncia,
                f_round(SUM(DECODE(cconcep,
                                   11, DECODE(tasaimp,
                                              NULL, DECODE(v_dd_cambio,
                                                           99, iconcep_monpol * v_signo,
                                                           NVL(iconcep, 0) * v_signo * v_itasa),
                                              0),
                                   0)),
                        v_cmoncia) c11ex_moncia,
                0 c17af_moncia, 0 c17ex_moncia,
                f_round(SUM(DECODE(cconcep,
                                   44, DECODE(tasaimp,
                                              NULL, 0,
                                              DECODE(v_dd_cambio,
                                                     99, iconcep_monpol * v_signo,
                                                     NVL(iconcep, 0) * v_signo * v_itasa)),
                                   0)),
                        v_cmoncia) c44af_moncia,
                f_round(SUM(DECODE(cconcep,
                                   44, DECODE(tasaimp,
                                              NULL, DECODE(v_dd_cambio,
                                                           99, iconcep_monpol * v_signo,
                                                           NVL(iconcep, 0) * v_signo * v_itasa),
                                              0),
                                   0)),
                        v_cmoncia) c44ex_moncia,
                f_round(SUM(DECODE(cconcep,
                                   45, DECODE(tasaimp,
                                              NULL, 0,
                                              DECODE(v_dd_cambio,
                                                     99, iconcep_monpol * v_signo,
                                                     NVL(iconcep, 0) * v_signo * v_itasa)),
                                   0)),
                        v_cmoncia) c45af_moncia,
                f_round(SUM(DECODE(cconcep,
                                   45, DECODE(tasaimp,
                                              NULL, DECODE(v_dd_cambio,
                                                           99, iconcep_monpol * v_signo,
                                                           NVL(iconcep, 0) * v_signo * v_itasa),
                                              0),
                                   0)),
                        v_cmoncia) c45ex_moncia,
                f_round(SUM(DECODE(cconcep,
                                   46, DECODE(tasaimp,
                                              NULL, 0,
                                              DECODE(v_dd_cambio,
                                                     99, iconcep_monpol * v_signo,
                                                     NVL(iconcep, 0) * v_signo * v_itasa)),
                                   0)),
                        v_cmoncia) c46af_moncia,
                f_round(SUM(DECODE(cconcep,
                                   46, DECODE(tasaimp,
                                              NULL, DECODE(v_dd_cambio,
                                                           99, iconcep_monpol * v_signo,
                                                           NVL(iconcep, 0) * v_signo * v_itasa),
                                              0),
                                   0)),
                        v_cmoncia) c46ex_moncia,
                0 c47af_moncia, 0 c47ex_moncia, 0 c48af_moncia, 0 c48ex_moncia, 0 c49af_moncia,
                0 c49ex_moncia
           FROM (SELECT cconcep, iconcep, iconcep_monpol,
                        (SELECT   COUNT(1)
                             FROM imprec i, recibos r, seguros s
                            WHERE i.cconcep = 4
                              AND i.cramo = s.cramo
                              AND i.cmodali = s.cmodali
                              AND i.ctipseg = s.ctipseg
                              AND i.ccolect = s.ccolect
                              AND i.cactivi = s.cactivi
                              AND i.cempres = s.cempres
                              AND s.sseguro = r.sseguro
                              AND r.nrecibo = d.nrecibo
                              AND i.cgarant = d.cgarant
                         GROUP BY r.nrecibo, i.cgarant) tasaimp
                   FROM detrecibos_fcambio d
                  WHERE d.nrecibo = p_nrecibo
                    AND d.cconcep IN(11, 44, 45, 46)
                    AND NOT EXISTS(SELECT 1
                                     FROM detmovrecibo_parcial dp
                                    WHERE dp.nrecibo = p_nrecibo)
                 UNION ALL
                 SELECT cconcep, iconcep, iconcep_monpol,
                        (SELECT   COUNT(1)
                             FROM imprec i, recibos r, seguros s
                            WHERE i.cconcep = 4
                              AND i.cramo = s.cramo
                              AND i.cmodali = s.cmodali
                              AND i.ctipseg = s.ctipseg
                              AND i.ccolect = s.ccolect
                              AND i.cactivi = s.cactivi
                              AND i.cempres = s.cempres
                              AND s.sseguro = r.sseguro
                              AND r.nrecibo = d.nrecibo
                              AND i.cgarant = d.cgarant
                         GROUP BY r.nrecibo, i.cgarant) tasaimp
                   FROM detmovrecibo_parcial d
                  WHERE d.nrecibo = p_nrecibo
                    AND(pnorden IS NULL
                        OR d.norden = pnorden)
                    AND d.smovrec = psmovrec
                    AND d.cconcep IN(11, 44, 45, 46));
   BEGIN
      v_pas := 1;

      OPEN c1;

      FETCH c1
       INTO v_numerr;

      IF c1%NOTFOUND THEN
         CLOSE c1;

         -- Si no tiene detalle, no insertamos
         RETURN 0;
      END IF;

      CLOSE c1;

      v_pas := 2;
      /*
      -- Bug 0030978 - JMF - 28/04/2014
      DELETE      liquidalindet
            WHERE nliqmen = p_nliqmen
              AND cagente = p_cagente
              AND cempres = p_cempres
              AND nrecibo = p_nrecibo;
      */
      v_pas := 3;

      IF p_signo = -1 THEN
         v_signo := -1;
      ELSE
         v_signo := 1;
      END IF;

      v_pas := 4;

      IF v_cmultimon = 1 THEN
         -- Bug Ini 0027043/157331: AFM - 30/10/2013
         IF v_dd_cambio = 99 THEN   -- No hay dia de cambio
            v_numerr := pac_oper_monedas.f_datos_contraval(NULL, p_nrecibo, NULL, f_sysdate,
                                                           2, v_itasa, v_fcambio);
         ELSE   -- El día de cambio es uno concreto si la fecha liquidación es final de mes
            IF pfecliq = LAST_DAY(pfecliq) THEN
               v_fechac := pfecliq + v_dd_cambio;
            ELSE
               v_fechac := TRUNC(f_sysdate);
            END IF;

            v_numerr := pac_oper_monedas.f_datos_contraval(NULL, p_nrecibo, NULL, v_fechac, 2,
                                                           v_itasa, v_fcambio);
         END IF;
      -- Bug Fin 0027043/157331: AMF - 30/10/2013
      END IF;

      v_pas := 5;

      SELECT SUM(icomisi), SUM(icomisi_moncia)
        INTO v_icomisi_tot, v_icomisi_moncia_tot
        FROM liquidalin
       WHERE nliqmen = p_nliqmen
         AND cagente = p_cagente
         AND cempres = p_cempres
         AND nrecibo = p_nrecibo
         -- Bug 0030978 - JMF - 05/05/2014
         AND(pnorden IS NULL
             OR norden = pnorden);

      v_pas := 7;

      IF NVL(pac_parametros.f_parempresa_n(p_cempres, 'DETRECIBOS_FCAMBIO'), 0) = 1 THEN
         v_pas := 71;

         -- Se ha de crear un nuevo cursor igual que el c3 pero buscando los importes en detrecibos_fcambio.
         -- El recorrido se hace sobre el nuevo cursor y el insert de liquidalindet con los valores de cambio según fecha recaudo
         FOR f4 IN c4 LOOP
            v_pas := 72;

            IF f4.c11ex <> 0
               OR f4.c11af <> 0 THEN
               v_11exmon := v_icomisi_moncia_tot - f4.c11af_moncia;
               v_44afmon := f4.c11af_moncia - f4.c45af_moncia - f4.c46af_moncia;
               v_44exmon := v_11exmon - f4.c45ex_moncia - f4.c46ex_moncia;
            ELSE
               v_11exmon := 0;
               v_44afmon := 0;
               v_44exmon := 0;
            END IF;

            v_17exmon := 0;
            v_47afmon := 0;
            v_47exmon := 0;
            v_pas := 73;

            INSERT INTO liquidalindet
                        (cempres, nliqmen, cagente, nliqlin, nrecibo,
                         c11af, c11ex, c17af, c17ex, c44af, c44ex, c45af,
                         c45ex, c46af, c46ex, c47af, c47ex, c48af, c48ex,
                         c49af, c49ex, c11af_moncia, c11ex_moncia, c17af_moncia,
                         c17ex_moncia, c44af_moncia, c44ex_moncia, c45af_moncia, c45ex_moncia,
                         c46af_moncia, c46ex_moncia, c47af_moncia, c47ex_moncia,
                         c48af_moncia, c48ex_moncia, c49af_moncia, c49ex_moncia,
                         norden, smovrec)
                 VALUES (f4.p_cempres, f4.p_nliqmen, f4.p_cagente, f4.p_nliqlin, f4.p_nrecibo,
                         f4.c11af, f4.c11ex, f4.c17af, f4.c17ex, f4.c44af, f4.c44ex, f4.c45af,
                         f4.c45ex, f4.c46af, f4.c46ex, f4.c47af, f4.c47ex, f4.c48af, f4.c48ex,
                         f4.c49af, f4.c49ex, f4.c11af_moncia, v_11exmon, f4.c17af_moncia,
                         v_17exmon, v_44afmon, v_44exmon, f4.c45af_moncia, f4.c45ex_moncia,
                         f4.c46af_moncia, f4.c46ex_moncia, v_47afmon, v_47exmon,
                         f4.c48af_moncia, f4.c48ex_moncia, f4.c49af_moncia, f4.c49ex_moncia,
                         pnorden, psmovrec);
         END LOOP;
      ELSE
         v_pas := 8;

         FOR f3 IN c3 LOOP
            v_pas := 81;

            IF f3.c11ex <> 0
               OR f3.c11af <> 0 THEN
               v_11exmon := v_icomisi_moncia_tot - f3.c11af_moncia;
               v_44afmon := f3.c11af_moncia - f3.c45af_moncia - f3.c46af_moncia;
               v_44exmon := v_11exmon - f3.c45ex_moncia - f3.c46ex_moncia;
            ELSE
               v_11exmon := 0;
               v_44afmon := 0;
               v_44exmon := 0;
            END IF;

            v_17exmon := 0;
            v_47afmon := 0;
            v_47exmon := 0;
            v_pas := 82;

            INSERT INTO liquidalindet
                        (cempres, nliqmen, cagente, nliqlin, nrecibo,
                         c11af, c11ex, c17af, c17ex, c44af, c44ex, c45af,
                         c45ex, c46af, c46ex, c47af, c47ex, c48af, c48ex,
                         c49af, c49ex, c11af_moncia, c11ex_moncia, c17af_moncia,
                         c17ex_moncia, c44af_moncia, c44ex_moncia, c45af_moncia, c45ex_moncia,
                         c46af_moncia, c46ex_moncia, c47af_moncia, c47ex_moncia,
                         c48af_moncia, c48ex_moncia, c49af_moncia, c49ex_moncia,
                         norden, smovrec)
                 VALUES (f3.p_cempres, f3.p_nliqmen, f3.p_cagente, f3.p_nliqlin, f3.p_nrecibo,
                         f3.c11af, f3.c11ex, f3.c17af, f3.c17ex, f3.c44af, f3.c44ex, f3.c45af,
                         f3.c45ex, f3.c46af, f3.c46ex, f3.c47af, f3.c47ex, f3.c48af, f3.c48ex,
                         f3.c49af, f3.c49ex, f3.c11af_moncia, v_11exmon, f3.c17af_moncia,
                         v_17exmon, v_44afmon, v_44exmon, f3.c45af_moncia, f3.c45ex_moncia,
                         f3.c46af_moncia, f3.c46ex_moncia, v_47afmon, v_47exmon,
                         f3.c48af_moncia, f3.c48ex_moncia, f3.c49af_moncia, f3.c49ex_moncia,
                         pnorden, psmovrec);
         END LOOP;
      END IF;

      v_pas := 9;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_obj, v_pas, v_par, SQLCODE || ' - ' || SQLERRM);
         RETURN 9906352;
   END f_crea_liquidalindet_dir;

   --
   -- Bug 0029334 - JMF - 11/12/2013
   -- Genera desglose de una linea de liquidacion, de algunos conceptos
   --
   -- Bug 0030978 - JMF - 28/04/2014
   FUNCTION f_crea_liquidalindet_ind(
      p_nliqmen IN NUMBER,
      p_cagente IN NUMBER,
      p_nliqlin IN NUMBER,
      p_cempres IN NUMBER,
      p_nrecibo IN NUMBER,
      p_signo IN NUMBER,
      pfecliq IN DATE,
      pnorden IN NUMBER,
      psmovrec IN NUMBER)
      RETURN NUMBER IS
      --
      v_pas          NUMBER(4) := 0;
      v_obj          VARCHAR2(500) := 'PAC_LIQUIDA.f_crea_liquidalindet_ind';
      v_par          VARCHAR2(500)
         := 'lm=' || p_nliqmen || ' ag=' || p_cagente || ' ll=' || p_nliqlin || ' em='
            || p_cempres || ' re=' || p_nrecibo || ' si=' || p_signo || ' o=' || pnorden
            || ' sm=' || psmovrec;
      v_numerr       NUMBER;
      v_signo        NUMBER;
      v_cmultimon    NUMBER := NVL(pac_parametros.f_parempresa_n(p_cempres, 'MULTIMONEDA'), 0);
      v_cmoncia      NUMBER := pac_parametros.f_parempresa_n(p_cempres, 'MONEDAEMP');
      v_dd_cambio    NUMBER
                     := NVL(pac_parametros.f_parempresa_n(p_cempres, 'COMIS_DD_CAMB_LIQ'), 99);
      v_itasa        eco_tipocambio.itasa%TYPE;
      v_fcambio      DATE;
      v_fechac       DATE;
      v_icomisi_tot  liquidalin.icomisi%TYPE;
      v_icomisi_moncia_tot liquidalin.icomisi_moncia%TYPE;
      v_11exmon      liquidalindet.c11ex_moncia%TYPE;
      v_17exmon      liquidalindet.c17ex_moncia%TYPE;
      v_44afmon      liquidalindet.c44af_moncia%TYPE;
      v_44exmon      liquidalindet.c44ex_moncia%TYPE;
      v_47afmon      liquidalindet.c47af_moncia%TYPE;
      v_47exmon      liquidalindet.c47ex_moncia%TYPE;

      CURSOR c1 IS
         SELECT 1
           FROM detrecibos
          WHERE nrecibo = p_nrecibo
            AND cconcep IN(17, 47, 48, 49);

      CURSOR c3 IS
         SELECT p_cempres, p_nliqmen, p_cagente, p_nliqlin, p_nrecibo, 0 c11af, 0 c11ex,
                v_signo * SUM(DECODE(cconcep, 17, DECODE(tasaimp, NULL, 0, iconcep), 0)) c17af,
                v_signo * SUM(DECODE(cconcep, 17, DECODE(tasaimp, NULL, iconcep, 0), 0)) c17ex,
                0 c44af, 0 c44ex, 0 c45af, 0 c45ex, 0 c46af, 0 c46ex,
                v_signo * SUM(DECODE(cconcep, 47, DECODE(tasaimp, NULL, 0, iconcep), 0)) c47af,
                v_signo * SUM(DECODE(cconcep, 47, DECODE(tasaimp, NULL, iconcep, 0), 0)) c47ex,
                v_signo * SUM(DECODE(cconcep, 48, DECODE(tasaimp, NULL, 0, iconcep), 0)) c48af,
                v_signo * SUM(DECODE(cconcep, 48, DECODE(tasaimp, NULL, iconcep, 0), 0)) c48ex,
                v_signo * SUM(DECODE(cconcep, 49, DECODE(tasaimp, NULL, 0, iconcep), 0)) c49af,
                v_signo * SUM(DECODE(cconcep, 49, DECODE(tasaimp, NULL, iconcep, 0), 0)) c49ex,
                0 c11af_moncia, 0 c11ex_moncia,
                f_round(SUM(DECODE(cconcep,
                                   17, DECODE(tasaimp,
                                              NULL, 0,
                                              DECODE(v_dd_cambio,
                                                     99, iconcep_monpol * v_signo,
                                                     NVL(iconcep, 0) * v_signo * v_itasa)),
                                   0)),
                        v_cmoncia) c17af_moncia,
                f_round(SUM(DECODE(cconcep,
                                   17, DECODE(tasaimp,
                                              NULL, DECODE(v_dd_cambio,
                                                           99, iconcep_monpol * v_signo,
                                                           NVL(iconcep, 0) * v_signo * v_itasa),
                                              0),
                                   0)),
                        v_cmoncia) c17ex_moncia,
                0 c44af_moncia, 0 c44ex_moncia, 0 c45af_moncia, 0 c45ex_moncia, 0 c46af_moncia,
                0 c46ex_moncia,
                f_round(SUM(DECODE(cconcep,
                                   47, DECODE(tasaimp,
                                              NULL, 0,
                                              DECODE(v_dd_cambio,
                                                     99, iconcep_monpol * v_signo,
                                                     NVL(iconcep, 0) * v_signo * v_itasa)),
                                   0)),
                        v_cmoncia) c47af_moncia,
                f_round(SUM(DECODE(cconcep,
                                   47, DECODE(tasaimp,
                                              NULL, DECODE(v_dd_cambio,
                                                           99, iconcep_monpol * v_signo,
                                                           NVL(iconcep, 0) * v_signo * v_itasa),
                                              0),
                                   0)),
                        v_cmoncia) c47ex_moncia,
                f_round(SUM(DECODE(cconcep,
                                   48, DECODE(tasaimp,
                                              NULL, 0,
                                              DECODE(v_dd_cambio,
                                                     99, iconcep_monpol * v_signo,
                                                     NVL(iconcep, 0) * v_signo * v_itasa)),
                                   0)),
                        v_cmoncia) c48af_moncia,
                f_round(SUM(DECODE(cconcep,
                                   48, DECODE(tasaimp,
                                              NULL, DECODE(v_dd_cambio,
                                                           99, iconcep_monpol * v_signo,
                                                           NVL(iconcep, 0) * v_signo * v_itasa),
                                              0),
                                   0)),
                        v_cmoncia) c48ex_moncia,
                f_round(SUM(DECODE(cconcep,
                                   49, DECODE(tasaimp,
                                              NULL, 0,
                                              DECODE(v_dd_cambio,
                                                     99, iconcep_monpol * v_signo,
                                                     NVL(iconcep, 0) * v_signo * v_itasa)),
                                   0)),
                        v_cmoncia) c49af_moncia,
                f_round(SUM(DECODE(cconcep,
                                   49, DECODE(tasaimp,
                                              NULL, DECODE(v_dd_cambio,
                                                           99, iconcep_monpol * v_signo,
                                                           NVL(iconcep, 0) * v_signo * v_itasa),
                                              0),
                                   0)),
                        v_cmoncia) c49ex_moncia
           FROM (SELECT cconcep, iconcep, iconcep_monpol,
                        (SELECT   COUNT(1)
                             FROM imprec i, recibos r, seguros s
                            WHERE i.cconcep = 4
                              AND i.cramo = s.cramo
                              AND i.cmodali = s.cmodali
                              AND i.ctipseg = s.ctipseg
                              AND i.ccolect = s.ccolect
                              AND i.cactivi = s.cactivi
                              AND i.cempres = s.cempres
                              AND s.sseguro = r.sseguro
                              AND r.nrecibo = d.nrecibo
                              AND i.cgarant = d.cgarant
                         GROUP BY r.nrecibo, i.cgarant) tasaimp
                   FROM detrecibos d
                  WHERE d.nrecibo = p_nrecibo
                    AND d.cconcep IN(17, 47, 48, 49)
                    AND NOT EXISTS(SELECT 1
                                     FROM detmovrecibo_parcial dp
                                    WHERE dp.nrecibo = p_nrecibo)
                 UNION ALL
                 SELECT cconcep, iconcep, iconcep_monpol,
                        (SELECT   COUNT(1)
                             FROM imprec i, recibos r, seguros s
                            WHERE i.cconcep = 4
                              AND i.cramo = s.cramo
                              AND i.cmodali = s.cmodali
                              AND i.ctipseg = s.ctipseg
                              AND i.ccolect = s.ccolect
                              AND i.cactivi = s.cactivi
                              AND i.cempres = s.cempres
                              AND s.sseguro = r.sseguro
                              AND r.nrecibo = d.nrecibo
                              AND i.cgarant = d.cgarant
                         GROUP BY r.nrecibo, i.cgarant) tasaimp
                   FROM detmovrecibo_parcial d
                  WHERE d.nrecibo = p_nrecibo
                    AND(pnorden IS NULL
                        OR d.norden = pnorden)
                    AND d.smovrec = psmovrec
                    AND d.cconcep IN(17, 47, 48, 49));

      CURSOR c4 IS
         SELECT p_cempres, p_nliqmen, p_cagente, p_nliqlin, p_nrecibo, 0 c11af, 0 c11ex,
                v_signo * SUM(DECODE(cconcep, 17, DECODE(tasaimp, NULL, 0, iconcep), 0)) c17af,
                v_signo * SUM(DECODE(cconcep, 17, DECODE(tasaimp, NULL, iconcep, 0), 0)) c17ex,
                0 c44af, 0 c44ex, 0 c45af, 0 c45ex, 0 c46af, 0 c46ex,
                v_signo * SUM(DECODE(cconcep, 47, DECODE(tasaimp, NULL, 0, iconcep), 0)) c47af,
                v_signo * SUM(DECODE(cconcep, 47, DECODE(tasaimp, NULL, iconcep, 0), 0)) c47ex,
                v_signo * SUM(DECODE(cconcep, 48, DECODE(tasaimp, NULL, 0, iconcep), 0)) c48af,
                v_signo * SUM(DECODE(cconcep, 48, DECODE(tasaimp, NULL, iconcep, 0), 0)) c48ex,
                v_signo * SUM(DECODE(cconcep, 49, DECODE(tasaimp, NULL, 0, iconcep), 0)) c49af,
                v_signo * SUM(DECODE(cconcep, 49, DECODE(tasaimp, NULL, iconcep, 0), 0)) c49ex,
                0 c11af_moncia, 0 c11ex_moncia,
                f_round(SUM(DECODE(cconcep,
                                   17, DECODE(tasaimp,
                                              NULL, 0,
                                              DECODE(v_dd_cambio,
                                                     99, iconcep_monpol * v_signo,
                                                     NVL(iconcep, 0) * v_signo * v_itasa)),
                                   0)),
                        v_cmoncia) c17af_moncia,
                f_round(SUM(DECODE(cconcep,
                                   17, DECODE(tasaimp,
                                              NULL, DECODE(v_dd_cambio,
                                                           99, iconcep_monpol * v_signo,
                                                           NVL(iconcep, 0) * v_signo * v_itasa),
                                              0),
                                   0)),
                        v_cmoncia) c17ex_moncia,
                0 c44af_moncia, 0 c44ex_moncia, 0 c45af_moncia, 0 c45ex_moncia, 0 c46af_moncia,
                0 c46ex_moncia,
                f_round(SUM(DECODE(cconcep,
                                   47, DECODE(tasaimp,
                                              NULL, 0,
                                              DECODE(v_dd_cambio,
                                                     99, iconcep_monpol * v_signo,
                                                     NVL(iconcep, 0) * v_signo * v_itasa)),
                                   0)),
                        v_cmoncia) c47af_moncia,
                f_round(SUM(DECODE(cconcep,
                                   47, DECODE(tasaimp,
                                              NULL, DECODE(v_dd_cambio,
                                                           99, iconcep_monpol * v_signo,
                                                           NVL(iconcep, 0) * v_signo * v_itasa),
                                              0),
                                   0)),
                        v_cmoncia) c47ex_moncia,
                f_round(SUM(DECODE(cconcep,
                                   48, DECODE(tasaimp,
                                              NULL, 0,
                                              DECODE(v_dd_cambio,
                                                     99, iconcep_monpol * v_signo,
                                                     NVL(iconcep, 0) * v_signo * v_itasa)),
                                   0)),
                        v_cmoncia) c48af_moncia,
                f_round(SUM(DECODE(cconcep,
                                   48, DECODE(tasaimp,
                                              NULL, DECODE(v_dd_cambio,
                                                           99, iconcep_monpol * v_signo,
                                                           NVL(iconcep, 0) * v_signo * v_itasa),
                                              0),
                                   0)),
                        v_cmoncia) c48ex_moncia,
                f_round(SUM(DECODE(cconcep,
                                   49, DECODE(tasaimp,
                                              NULL, 0,
                                              DECODE(v_dd_cambio,
                                                     99, iconcep_monpol * v_signo,
                                                     NVL(iconcep, 0) * v_signo * v_itasa)),
                                   0)),
                        v_cmoncia) c49af_moncia,
                f_round(SUM(DECODE(cconcep,
                                   49, DECODE(tasaimp,
                                              NULL, DECODE(v_dd_cambio,
                                                           99, iconcep_monpol * v_signo,
                                                           NVL(iconcep, 0) * v_signo * v_itasa),
                                              0),
                                   0)),
                        v_cmoncia) c49ex_moncia
           FROM (SELECT cconcep, iconcep, iconcep_monpol,
                        (SELECT   COUNT(1)
                             FROM imprec i, recibos r, seguros s
                            WHERE i.cconcep = 4
                              AND i.cramo = s.cramo
                              AND i.cmodali = s.cmodali
                              AND i.ctipseg = s.ctipseg
                              AND i.ccolect = s.ccolect
                              AND i.cactivi = s.cactivi
                              AND i.cempres = s.cempres
                              AND s.sseguro = r.sseguro
                              AND r.nrecibo = d.nrecibo
                              AND i.cgarant = d.cgarant
                         GROUP BY r.nrecibo, i.cgarant) tasaimp
                   FROM detrecibos_fcambio d
                  WHERE d.nrecibo = p_nrecibo
                    AND d.cconcep IN(17, 47, 48, 49)
                    AND NOT EXISTS(SELECT 1
                                     FROM detmovrecibo_parcial dp
                                    WHERE dp.nrecibo = p_nrecibo)
                 UNION ALL
                 SELECT cconcep, iconcep, iconcep_monpol,
                        (SELECT   COUNT(1)
                             FROM imprec i, recibos r, seguros s
                            WHERE i.cconcep = 4
                              AND i.cramo = s.cramo
                              AND i.cmodali = s.cmodali
                              AND i.ctipseg = s.ctipseg
                              AND i.ccolect = s.ccolect
                              AND i.cactivi = s.cactivi
                              AND i.cempres = s.cempres
                              AND s.sseguro = r.sseguro
                              AND r.nrecibo = d.nrecibo
                              AND i.cgarant = d.cgarant
                         GROUP BY r.nrecibo, i.cgarant) tasaimp
                   FROM detmovrecibo_parcial d
                  WHERE d.nrecibo = p_nrecibo
                    AND(pnorden IS NULL
                        OR d.norden = pnorden)
                    AND d.smovrec = psmovrec
                    AND d.cconcep IN(17, 47, 48, 49));
   BEGIN
      v_pas := 1;

      OPEN c1;

      FETCH c1
       INTO v_numerr;

      IF c1%NOTFOUND THEN
         CLOSE c1;

         -- Si no tiene detalle, no insertamos
         RETURN 0;
      END IF;

      CLOSE c1;

      v_pas := 2;
      /*
      -- Bug 0030978 - JMF - 28/04/2014
      DELETE      liquidalindet
            WHERE nliqmen = p_nliqmen
              AND cagente = p_cagente
              AND cempres = p_cempres
              AND nrecibo = p_nrecibo;
      */
      v_pas := 4;

      IF p_signo = -1 THEN
         v_signo := -1;
      ELSE
         v_signo := 1;
      END IF;

      v_pas := 5;

      IF v_cmultimon = 1 THEN
         -- Bug Ini 0027043/157331: AFM - 30/10/2013
         IF v_dd_cambio = 99 THEN   -- No hay dia de cambio
            v_numerr := pac_oper_monedas.f_datos_contraval(NULL, p_nrecibo, NULL, f_sysdate,
                                                           2, v_itasa, v_fcambio);
         ELSE   -- El día de cambio es uno concreto si la fecha liquidación es final de mes
            IF pfecliq = LAST_DAY(pfecliq) THEN
               v_fechac := pfecliq + v_dd_cambio;
            ELSE
               v_fechac := TRUNC(f_sysdate);
            END IF;

            v_numerr := pac_oper_monedas.f_datos_contraval(NULL, p_nrecibo, NULL, v_fechac, 2,
                                                           v_itasa, v_fcambio);
         END IF;
      -- Bug Fin 0027043/157331: AMF - 30/10/2013
      END IF;

      v_pas := 6;

      SELECT SUM(icomisi), SUM(icomisi_moncia)
        INTO v_icomisi_tot, v_icomisi_moncia_tot
        FROM liquidalin
       WHERE nliqmen = p_nliqmen
         AND cagente = p_cagente
         AND cempres = p_cempres
         AND nrecibo = p_nrecibo
         -- Bug 0030978 - JMF - 05/05/2014
         AND(pnorden IS NULL
             OR norden = pnorden);

      v_pas := 7;

      IF NVL(pac_parametros.f_parempresa_n(p_cempres, 'DETRECIBOS_FCAMBIO'), 0) = 1 THEN
         v_pas := 71;

         FOR f4 IN c4 LOOP
            v_pas := 72;
            v_11exmon := 0;
            v_44afmon := 0;
            v_44exmon := 0;

            IF f4.c17ex <> 0
               OR f4.c17af <> 0 THEN
               v_17exmon := v_icomisi_moncia_tot - f4.c17af_moncia;
               v_47afmon := f4.c17af_moncia - f4.c48af_moncia - f4.c49af_moncia;
               v_47exmon := v_17exmon - f4.c48ex_moncia - f4.c49ex_moncia;
            ELSE
               v_17exmon := 0;
               v_47afmon := 0;
               v_47exmon := 0;
            END IF;

            v_pas := 73;

            INSERT INTO liquidalindet
                        (cempres, nliqmen, cagente, nliqlin, nrecibo,
                         c11af, c11ex, c17af, c17ex, c44af, c44ex, c45af,
                         c45ex, c46af, c46ex, c47af, c47ex, c48af, c48ex,
                         c49af, c49ex, c11af_moncia, c11ex_moncia, c17af_moncia,
                         c17ex_moncia, c44af_moncia, c44ex_moncia, c45af_moncia, c45ex_moncia,
                         c46af_moncia, c46ex_moncia, c47af_moncia, c47ex_moncia,
                         c48af_moncia, c48ex_moncia, c49af_moncia, c49ex_moncia,
                         norden, smovrec)
                 VALUES (f4.p_cempres, f4.p_nliqmen, f4.p_cagente, f4.p_nliqlin, f4.p_nrecibo,
                         f4.c11af, f4.c11ex, f4.c17af, f4.c17ex, f4.c44af, f4.c44ex, f4.c45af,
                         f4.c45ex, f4.c46af, f4.c46ex, f4.c47af, f4.c47ex, f4.c48af, f4.c48ex,
                         f4.c49af, f4.c49ex, f4.c11af_moncia, v_11exmon, f4.c17af_moncia,
                         v_17exmon, v_44afmon, v_44exmon, f4.c45af_moncia, f4.c45ex_moncia,
                         f4.c46af_moncia, f4.c46ex_moncia, v_47afmon, v_47exmon,
                         f4.c48af_moncia, f4.c48ex_moncia, f4.c49af_moncia, f4.c49ex_moncia,
                         pnorden, psmovrec);
         END LOOP;
      ELSE
         v_pas := 8;

         FOR f3 IN c3 LOOP
            v_pas := 81;
            v_11exmon := 0;
            v_44afmon := 0;
            v_44exmon := 0;

            IF f3.c17ex <> 0
               OR f3.c17af <> 0 THEN
               v_17exmon := v_icomisi_moncia_tot - f3.c17af_moncia;
               v_47afmon := f3.c17af_moncia - f3.c48af_moncia - f3.c49af_moncia;
               v_47exmon := v_17exmon - f3.c48ex_moncia - f3.c49ex_moncia;
            ELSE
               v_17exmon := 0;
               v_47afmon := 0;
               v_47exmon := 0;
            END IF;

            v_pas := 82;

            INSERT INTO liquidalindet
                        (cempres, nliqmen, cagente, nliqlin, nrecibo,
                         c11af, c11ex, c17af, c17ex, c44af, c44ex, c45af,
                         c45ex, c46af, c46ex, c47af, c47ex, c48af, c48ex,
                         c49af, c49ex, c11af_moncia, c11ex_moncia, c17af_moncia,
                         c17ex_moncia, c44af_moncia, c44ex_moncia, c45af_moncia, c45ex_moncia,
                         c46af_moncia, c46ex_moncia, c47af_moncia, c47ex_moncia,
                         c48af_moncia, c48ex_moncia, c49af_moncia, c49ex_moncia,
                         norden, smovrec)
                 VALUES (f3.p_cempres, f3.p_nliqmen, f3.p_cagente, f3.p_nliqlin, f3.p_nrecibo,
                         f3.c11af, f3.c11ex, f3.c17af, f3.c17ex, f3.c44af, f3.c44ex, f3.c45af,
                         f3.c45ex, f3.c46af, f3.c46ex, f3.c47af, f3.c47ex, f3.c48af, f3.c48ex,
                         f3.c49af, f3.c49ex, f3.c11af_moncia, v_11exmon, f3.c17af_moncia,
                         v_17exmon, v_44afmon, v_44exmon, f3.c45af_moncia, f3.c45ex_moncia,
                         f3.c46af_moncia, f3.c46ex_moncia, v_47afmon, v_47exmon,
                         f3.c48af_moncia, f3.c48ex_moncia, f3.c49af_moncia, f3.c49ex_moncia,
                         pnorden, psmovrec);
         END LOOP;
      END IF;

      v_pas := 10;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_obj, v_pas, v_par, SQLCODE || ' - ' || SQLERRM);
         RETURN 9906352;
   END f_crea_liquidalindet_ind;

/*************************************************************************
          Función que seleccionará los recibos que se tienen que liquidar
          param in p_cempres   : código de la empresa
          param in p_sproduc   : Producto
          param in p_npoliza   : Póliza
          param in p_cagente   : Agente
          param in p_femiini   : Fecha inicio emisión.
          param in p_femifin   : Fecha fin emisión.
          param in p_fefeini   : Fecha inicio efecto
          param in p_fefefin   : Fecha fin efecto
          param in p_fcobini   : Fecha inicio cobro
          param in p_fcobfin   : Fecha fin cobro.
          param in p_idioma   : Idioma
          return psquery   : varchar2
   *************************************************************************/
   FUNCTION f_consultarecibos(
      p_cempres IN NUMBER,
      p_sproduc IN NUMBER,
      p_npoliza IN NUMBER,
      p_cagente IN NUMBER,
      p_femiini IN DATE,
      p_femifin IN DATE,
      p_fefeini IN DATE,
      p_fefefin IN DATE,
      p_fcobini IN DATE,
      p_fcobfin IN DATE,
      p_idioma IN NUMBER)
      RETURN CLOB IS
      --v_selec        VARCHAR2(10000);
      v_selec        CLOB;
      v_object       VARCHAR2(500) := 'PAC_LIQUIDA.f_consultarecibos';
      v_param        VARCHAR2(500)
         := 'parámetros - p_cempres: ' || p_cempres || ', p_sproduc: ' || p_sproduc
            || ', p_npoliza: ' || p_npoliza || ', p_cagente: ' || p_cagente || ', p_femiini: '
            || p_femiini || ', p_femifin: ' || p_fefeini || ', p_fefefin: ' || p_fefefin
            || ', p_fcobini: ' || p_fcobini || ', p_fcobfin: ' || p_fcobfin || ', p_cidioma: '
            || p_idioma;
      v_pasexec      NUMBER(5) := 1;
      vdiasliq       NUMBER(5) := 0;
   BEGIN
      vdiasliq := NVL(pac_parametros.f_parinstalacion_n('DIASLIQ'), 0);
      v_selec :=
         ' SELECT nrecibo, cagente, sseguro, cempres, smovrec, fefeadm, fefecto, femisio, cgescob, tcconcep FROM vista_liqcomision'
         || ' where ';

      IF p_cagente IS NOT NULL THEN
         v_selec := v_selec || 'cagente = ' || p_cagente || ' and ';
      END IF;

      IF p_sproduc IS NOT NULL THEN
         v_selec := v_selec || 'sproduc = ' || p_sproduc || ' and ';
      END IF;

      IF p_npoliza IS NOT NULL THEN
         v_selec := v_selec || 'npoliza = ' || p_npoliza || ' and ';
      END IF;

      v_selec :=
         v_selec || ' cempres = ' || p_cempres || ' and
      (femisio >= ''' || p_femiini || ''' or''' || p_femiini
         || ''' is null) and
      (femisio <= ''' || p_femifin || ''' or ''' || p_femifin
         || ''' is null) and
      (fefecto >= ''' || p_fefeini || ''' or ''' || p_fefeini
         || ''' is null) and
      (fefecto <= ''' || p_fefefin || ''' or ''' || p_fefefin
         || ''' is null) and
      nrecibo in (select b.nrecibo
                  from movrecibo b
                  where fmovini >= nvl('''
         || p_fcobini || ''', fmovini) and
                        fmovini <= nvl(''' || p_fcobfin || ''', fmovini)
                 ) ';
      RETURN v_selec;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param,
                     'Parámetros incorrectos');
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param,
                     SQLCODE || ' - ' || SQLERRM);
         RETURN NULL;
   END f_consultarecibos;

/*************************************************************************
          Función que en una liquidación devuelve en nliqmen  dependiendo de empresa, fecha liqui y agente
          y si estamos en modo real y existe algún previo lo borramos.

          param in pcempres   : código de la empresa
          param in pcagente   : Agente
          param in pfecliq    : Fecha lquidación
          param in psproces   : Código de todo el proceso de liquidación para todos los agentes
          param in pmodo      : Pmodo = 0 Real y 1 Previo
          return psquery   : varchar2
   *************************************************************************/
   FUNCTION f_get_nliqmen(
      pcempres IN NUMBER,
      pcagente IN NUMBER,
      pfecliq IN DATE,
      psproces IN NUMBER,
      pmodo IN NUMBER)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;
      v_nliqmen      NUMBER := NULL;
      v_nliqaux2     NUMBER := NULL;
      v_selec        CLOB;
      v_object       VARCHAR2(500) := 'PAC_LIQUIDA.f_get_nliqmen';
      v_param        VARCHAR2(500)
         := 'parámetros - pcempres: ' || pcempres || ', pcagente: ' || pcagente
            || ', pfecliq: ' || pfecliq || ', psproces: ' || psproces || ', pmodo: ' || pmodo;
      v_pasexec      NUMBER(5) := 1;
      vdiasliq       NUMBER(5) := 0;
      vcestado       NUMBER;
   BEGIN
      --Borramos si hay algun previo para este agente / empresa / fecha SOLO SI estamos en real
      SELECT MAX(nliqmen)
        INTO v_nliqaux2
        FROM liquidacab
       WHERE cagente = pcagente
         --AND fliquid = pfecliq -- BUG: 26993 16/05/2013 AMJ 0026993: LCOL_A005-Error en liquidaciones de comisiones cuando se realiza una devolucion
         AND fliquid <=
               pfecliq   -- BUG: 26993 16/05/2013 AMJ 0026993: LCOL_A005-Error en liquidaciones de comisiones cuando se realiza una devolucion
         AND ctipoliq = 1
         AND cempres = pcempres;

      v_pasexec := 2;

      -- Si existe algun previo y estamos en modo real borramos el previo que existe.
      IF v_nliqaux2 IS NOT NULL
         AND pmodo = 0 THEN
         -- Bug 0029334 - JMF - 11/12/2013
         DELETE FROM liquidalindet
               WHERE nliqmen = v_nliqaux2
                 AND cagente = pcagente
                 AND cempres = pcempres;

         DELETE FROM liquidalin
               WHERE nliqmen = v_nliqaux2
                 AND cagente = pcagente
                 AND cempres = pcempres;

         DELETE FROM ext_liquidalin
               WHERE nliqmen = v_nliqaux2
                 AND cagente = pcagente
                 AND cempres = pcempres;

         DELETE FROM liquidacab
               WHERE ctipoliq = 1
                 AND cagente = pcagente
                 AND cempres = pcempres
                 AND nliqmen = v_nliqaux2
                 AND fliquid = pfecliq;
      END IF;

      v_pasexec := 3;

      BEGIN
         SELECT nliqmen
           INTO v_nliqmen
           FROM liquidacab
          WHERE cempres = pcempres
            AND sproliq = psproces
            AND cagente = pcagente;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            SELECT NVL(MAX(nliqmen), 0) + 1
              INTO v_nliqmen
              FROM liquidacab
             WHERE cempres = pcempres
               AND cagente = pcagente;

            v_pasexec := 4;

            IF pmodo = 0 THEN   --Bug 27599 19/08/2013 Si es modo/liquidación REAL, el cestado = 1 de liquidacab
               vcestado := 1;
            END IF;

            --Creamos la cabecera de liquidacab por agente
            vnumerr := pac_liquida.f_set_cabeceraliq(pcagente, v_nliqmen, pfecliq, f_sysdate,
                                                     NULL, pcempres, psproces, NULL, NULL,
                                                     NULL, pmodo, vcestado, NULL, NULL);

            IF vnumerr <> 0 THEN
               RETURN vnumerr;
            END IF;

            v_pasexec := 5;
      END;

      v_pasexec := 6;
      RETURN v_nliqmen;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param,
                     'Parámetros incorrectos');
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param,
                     SQLCODE || ' - ' || SQLERRM);
         RETURN NULL;
   END f_get_nliqmen;

   FUNCTION f_get_recibos_liq(
      p_cempres IN NUMBER,
      p_cagente IN NUMBER,
      p_fecini IN DATE,
      p_fecfin IN DATE)
      RETURN CLOB IS
      --v_selec        VARCHAR2(10000);
      v_selec        CLOB;
      v_object       VARCHAR2(500) := 'PAC_LIQUIDA.f_get_recibos_liq';
      v_param        VARCHAR2(500)
         := 'parámetros - p_cempres: ' || p_cempres || ', p_cagente: ' || p_cagente
            || ', p_fecini: ' || p_fecini;
      v_pasexec      NUMBER(5) := 1;
      vdiasliq       NUMBER(5) := 0;
   BEGIN
      v_selec :=
         ' SELECT nrecibo, cagente, sseguro, cempres, smovrec, fefeadm, fefecto, femisio, cgescob, '
         || 'iprinet, icomisi, itotimp, itotalr, cestrec '
         || 'FROM vista_liqcomision WHERE cempres = ' || p_cempres || ' and fefeadm <= '''
         || p_fecfin || CHR(39);

      --|| ' and trunc(fefeadm) between ''' || p_fecini || '''and ''' || p_fecfin || chr(39);
      IF p_cagente IS NOT NULL THEN
         v_selec := v_selec || ' and cagente = ' || p_cagente;
      END IF;

      RETURN v_selec;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param,
                     'Parámetros incorrectos');
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param,
                     SQLCODE || ' - ' || SQLERRM);
         RETURN NULL;
   END f_get_recibos_liq;

   -- BUG 18046:JMC:24/03/2011:Inici
   /*************************************************************************
           Función que insertará los recibos que forman la liquidación
           param in p_nrecibo   : Código recibo
           param in p_smovrec   : Movimiento recibo
           param in p_sproliq   : Código ID del proceso de liquidación asociado
           return 0 o error
    *************************************************************************/
   FUNCTION f_set_recliqui(
      p_nrecibo IN NUMBER,
      p_smovrec IN NUMBER,
      p_cgescob IN NUMBER,
      p_icomisi IN NUMBER,
      p_itotimp IN NUMBER,
      p_itotalr IN NUMBER,
      p_iprinet IN NUMBER,
      p_cestrec IN NUMBER,
      p_sproliq IN NUMBER,
      p_cestado IN NUMBER,   -- 1 Liquidado, 2 Autoliquidado, 3 retenido.
      pmodo IN NUMBER)
      RETURN NUMBER IS
      v_object       VARCHAR2(500) := 'PAC_LIQUIDA.f_set_recliqui';
      v_param        VARCHAR2(500)
         := 'parámetros - p_nrecibo: ' || p_nrecibo || ', p_smovrec: ' || p_smovrec
            || ', p_sproliq: ' || p_sproliq;
      v_pasexec      NUMBER(5) := 1;
      v_factor       NUMBER;
      vcestliq       NUMBER := 1;
      vcempres       NUMBER;
      vcagente       NUMBER;
      vitotalr       NUMBER;
      vitotimp       NUMBER;
      vicomisi       NUMBER;
      viliquida      NUMBER;
      v_cont         NUMBER;
      vctiprec       NUMBER;   -- 16. 0021164: LCOL_A001: Proceso de liquidación, ajuste para los extornos
   BEGIN
      --v_factor := pac_liquida.f_get_signo(p_nrecibo, p_smovrec, pmodo);
      IF p_cestrec IN(10, 11, 12) THEN   --Son cobros
         --  cgescob = 3 G.Broker
         /*select decode(p_cgescob,3,((-1)*p_itotalr), p_itotalr) into vitotalr
         from dual;*/
         --vfactor := (1);  --Cobros
         vitotalr := p_itotalr;
         vitotimp := p_itotimp;
         vicomisi := p_icomisi;
      ELSIF p_cestrec = 20 THEN   --Son descobros
         --  cgescob = 3 G.Broker
         /*select decode(p_cgescob,3,p_itotalr, ((-1)*p_itotalr)) into vitotalr
         from dual;*/
         --vfactor := (-1);  --Son descobros
         vitotalr := (-1) * p_itotalr;
         vitotimp := (-1) * p_itotimp;
         vicomisi := (-1) * p_icomisi;
      END IF;

      SELECT cempres, cagente,
             ctiprec   -- 16. 0021164: LCOL_A001: Proceso de liquidación, ajuste para los extornos
        INTO vcempres, vcagente,
             vctiprec   -- 16. 0021164: LCOL_A001: Proceso de liquidación, ajuste para los extornos
        FROM recibos
       WHERE nrecibo = p_nrecibo;

      -- 16. 0021164: LCOL_A001: Proceso de liquidación, ajuste para los extornos - DESDE
      -- Si los recibos son de 9-extorno o 13-retorno se les vuelve a cambiar el signo
      IF vctiprec IN(9, 13) THEN
         vitotalr := (-1) * vitotalr;
         vitotimp := (-1) * vitotimp;
         vicomisi := (-1) * vicomisi;
      END IF;

      -- 16. 0021164: LCOL_A001: Proceso de liquidación, ajuste para los extornos - HASTA
      v_pasexec := 2;

      IF p_cgescob = 3 THEN
         viliquida :=(-vitotalr + vicomisi - vitotimp);
      ELSE
         viliquida := vicomisi - vitotimp;
      END IF;

      SELECT COUNT(1)
        INTO v_cont
        FROM ctactes
       WHERE nrecibo = p_nrecibo
         AND cconcta IN(8)
         AND cestado = 1   --Estado pdte.
         AND cmanual = 1;   --Apunte automático

      IF v_cont > 0 THEN
         vcestliq := 2;   -- Autoliquidado
      END IF;

      v_pasexec := 3;

      IF pmodo = 1 THEN   --MODO PREVIO
         BEGIN
            v_pasexec := 4;

            INSERT INTO liqmovrec_previo
                        (smovrec, cempres, fliquid, cestliq, itotalr, icomisi,
                         iretenc, iprinet, nrecibo, sproliq, cagente, sproces,
                         cgescob, iliquida)
                 VALUES (p_smovrec, vcempres, TRUNC(f_sysdate), vcestliq, vitotalr, vicomisi,
                         vitotimp, p_iprinet, p_nrecibo, p_sproliq, vcagente, p_sproliq,
                         p_cgescob, viliquida);

            v_pasexec := 5;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
               RETURN 9001752;
         END;
      ELSE   --MODO REAL
         BEGIN
            v_pasexec := 6;

            INSERT INTO liqmovrec
                        (smovrec, cempres, fliquid, cestliq, itotalr, icomisi,
                         iretenc, iprinet, nrecibo, sproliq, cagente, sproces,
                         cgescob, iliquida)
                 VALUES (p_smovrec, vcempres, TRUNC(f_sysdate), vcestliq, vitotalr, vicomisi,
                         vitotimp, p_iprinet, p_nrecibo, p_sproliq, vcagente, p_sproliq,
                         p_cgescob, viliquida);

            v_pasexec := 7;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
               RETURN 9001752;
         END;
      END IF;

      v_pasexec := 8;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
         RETURN 9001752;
   END f_set_recliqui;

   /*************************************************************************
          Función que retornará el signo a aplicar en función del tipo de recibo y del estado del recibo.
          param in p_nrecibo   : Código recibo
          param in p_smovrec   : Movimiento recibo
          return 1, -1 o error
   *************************************************************************/
   FUNCTION f_get_signo(p_nrecibo IN NUMBER, p_smovrec IN NUMBER, pmodo IN NUMBER)
      RETURN NUMBER IS
      v_object       VARCHAR2(500) := 'PAC_LIQUIDA.f_get_signo';
      v_param        VARCHAR2(500)
                    := 'parámetros - p_nrecibo: ' || p_nrecibo || ', p_smovrec: ' || p_smovrec;
      v_pasexec      NUMBER(5) := 1;
      v_factor       NUMBER;
      v_ctiprec      recibos.ctiprec%TYPE;
      v_cestrec      movrecibo.cestrec%TYPE;
      v_cestant      movrecibo.cestant%TYPE;
      v_nliq         NUMBER;
   BEGIN
      SELECT ctiprec
        INTO v_ctiprec
        FROM recibos
       WHERE nrecibo = p_nrecibo;

      v_pasexec := 2;

      SELECT cestrec, cestant
        INTO v_cestrec, v_cestant
        FROM movrecibo
       WHERE smovrec = p_smovrec;

      v_pasexec := 3;

      /*IF pmodo = 1 THEN   --previo
         SELECT COUNT(1)
           INTO v_nliq
           FROM liqmovrec_previo
          WHERE nrecibo = p_nrecibo;
      ELSE*/
      SELECT COUNT(1)
        INTO v_nliq
        FROM liqmovrec
       WHERE nrecibo = p_nrecibo;

      --END IF;
      v_pasexec := 4;

      IF v_ctiprec IN(9, 13) THEN   -- BUG 19791 - 04/11/2011 - JMP - LCOL_A001-Modificaciones de fase 0 en la consulta de recibos
         --si es extorno o gestiona compañía
         IF (v_cestrec IN(0, 1))
            AND(v_cestant = 0) THEN
            v_factor :=(-1);
         ELSE
            v_factor := 1;
         END IF;
      ELSE
         IF ((v_cestrec = 0)
             AND(v_cestant = 1))
            OR((v_cestrec = 2)
               AND(v_cestant = 0)) THEN
            --Cuando esta en estado descobrado ó anulado
            IF v_nliq > 0 THEN
               v_factor :=(-1);
            ELSE
               v_factor := 1;
            END IF;
         ELSE
            v_factor := 1;
         END IF;
      END IF;

      RETURN v_factor;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
         RETURN 9001753;
   END f_get_signo;

/*************************************************************************
       Función que calcula el saldo de la cuenta corriente de un agente
       param in  pcempres    : código empresa
       param in  pcagente    : código de agente
       param out psaldo      : importe que representa el saldo
       return                : 0.-    OK
                               1.-    KO
    *************************************************************************/
   FUNCTION f_get_saldoagente(pcempres IN NUMBER, pcagente IN NUMBER, psaldo OUT NUMBER)
      RETURN NUMBER IS
      v_object       VARCHAR2(500) := 'PAC_LIQUIDA.f_get_saldoagente';
      v_param        VARCHAR2(500)
                          := 'params : pcempres : ' || pcempres || ', pcagente : ' || pcagente;
      v_pasexec      NUMBER(5) := 1;
      vfecha         DATE;
      vsaldo         NUMBER;
      vapuntespdtes  NUMBER;
   BEGIN
      --Bug 22637  Cambio en el cálculo de saldo del agente
      BEGIN
         SELECT   ffecmov, SUM(DECODE(cdebhab, 1, iimport, -iimport))
             INTO vfecha, vsaldo
             FROM ctactes
            WHERE cempres = pcempres
              AND cagente = pcagente
              AND cestado = 0   --Apuntes liquidados
              AND cconcta = 0   --Apunte de Saldo final
              AND fvalor = (SELECT MAX(fvalor)
                              FROM ctactes
                             WHERE cempres = pcempres
                               AND cagente = pcagente
                               AND cestado = 0
                               AND cconcta = 0)
         GROUP BY ffecmov;
      EXCEPTION
         WHEN OTHERS THEN
            vfecha := NULL;
            vsaldo := NULL;
      END;

      --Fin bug 22637
      SELECT SUM(DECODE(cdebhab, 1, iimport, -iimport)) suma
        INTO vapuntespdtes
        FROM ctactes
       WHERE cempres = pcempres
         AND cagente = pcagente
         AND TRUNC(ffecmov) >= TRUNC(vfecha)
         AND cestado = 1;   --apuntes pdtes

      psaldo := NVL(vsaldo, 0) + NVL(vapuntespdtes, 0);
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 0;
   END f_get_saldoagente;

  /*************************************************************************
Función que devuelve las cuentas técnicas de un agente
param in  pcagente    : código de agente
param out psquery      : cursor con las cuentas técnicas de un agente
return                : 0.-    OK
1.-    KO
*************************************************************************/
FUNCTION f_get_ctas(
    pcagente IN NUMBER,
    pcidioma IN NUMBER,
    psquery OUT VARCHAR2)
  RETURN NUMBER
IS
  v_object VARCHAR2(500) := 'PAC_LIQUIDA.f_get_ctas';
  v_param  VARCHAR2(500) := 'params : pcagente : ' || pcagente ||
  ', pcidioma : ' || pcidioma;
  v_pasexec NUMBER(5) := 1;
  v_factor  NUMBER;
BEGIN
  -- BUG14344:DRA:05/05/2010:Inici
  psquery :=
  'SELECT cagente, cempres, nnumlin, tipolin, cmanual, ffecmov, cestado,' ||
  'testado, concepto, idebe, ihaber, tdescrip,' ||
  'fvalor, cconcta, cfiscal, tfiscal, cestpag FROM ('
  --
  || 'SELECT c.cagente, c.cempres, c.nnumlin, ff_desvalorfijo(693,' || pcidioma
  || ', c.cmanual) tipolin, c.cmanual, c.ffecmov, c.cestado,' ||
  ' ff_desvalorfijo(18,' || pcidioma || ', c.cestado) testado,' ||
  ' d.tcconcta concepto, decode(c.cdebhab, 1, c.iimport, 0) idebe,' ||
  ' decode (c.cdebhab, 2, c.iimport, 0) ihaber, c.tdescrip, c.fvalor,' ||
  ' c.cconcta, c.cfiscal, ff_desvalorfijo(800017,' || pcidioma ||
  ', c.cfiscal) tfiscal, to_number (null) cestpag' ||
  ' FROM ctactes c, desctactes d' || ' WHERE c.cconcta = d.cconcta' ||
  ' AND d.cidioma = ' || pcidioma || ' AND c.cagente = ' || pcagente ||
  ' AND c.cconcta <> 98 ' --
  || ' UNION ALL '
  --Bug.: 21449 - ICV - 01/03/2012 - Con los cambios que se han realizado en la
  -- liquidación si hay 98 es porque hay pago.
  --Si se divide entre productos el pago se relaciona con el saldo
  --Sino se relaciona con el concepto a pagar (98) ya que solo hay uno
  || 'SELECT p.cagente, p.cempres, p.nnumlin, ff_desvalorfijo(693,' || pcidioma
  || ', c.cmanual) tipolin, c.cmanual, c.ffecmov, c.cestado,' ||
  ' ff_desvalorfijo(18,' || pcidioma || ', c.cestado) testado,' ||
  ' d.tcconcta concepto, sum(decode(c.cdebhab, 1, c.iimport, 0)) idebe,' ||
  ' sum(decode (c.cdebhab, 2, c.iimport, 0)) ihaber, c.tdescrip, c.fvalor,' ||
  ' c.cconcta, c.cfiscal, ff_desvalorfijo(800017,' || pcidioma ||
  ', c.cfiscal) tfiscal, p.cestado cestpag' ||
  ' FROM ctactes c, desctactes d, pagoscomisiones p' ||
  ' WHERE c.cconcta = d.cconcta' || ' AND d.cidioma = ' || pcidioma ||
  ' AND c.cagente = ' || pcagente || ' AND c.cconcta = 98' ||
  ' AND p.cagente = c.cagente' || ' AND p.cempres = c.cempres';
  IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,
    'CTAPROD'), 0) = 1 THEN
    psquery       := psquery ||
    ' AND p.nnumlin = (select max(nnumlin) from ctactes c2 where c2.cagente = c.cagente and c2.cempres = c.cempres and c2.sproces = c.sproces
and c2.cconcta = 0)'
    ;
  ELSE
  --  psquery := psquery || ' and p.nnumlin = c.nnumlin ' || -- BUG 1896 AP 23/04/2018
  psquery := psquery || ' AND p.spago = (select max(p.spago) from pagoscomisiones p, ctactes c where p.cagente = ' || pcagente || ' and p.cempres = c.cempres and p.nnumlin = c.nnumlin)' ||
  ' group by p.cagente, p.cempres, p.nnumlin, c.cmanual, c.ffecmov, c.cestado, d.tcconcta, c.tdescrip, c.fvalor, c.cconcta, ' ||
  ' c.cfiscal, p.cestado, c.sproces, c.cdebhab '; -- BUG 1896 AP 23/04/2018
  END IF;
  psquery := psquery || ' UNION ALL ' ||
  'SELECT c.cagente, c.cempres, c.nnumlin, ff_desvalorfijo(693,' || pcidioma ||
  ', c.cmanual) tipolin, c.cmanual, c.ffecmov, c.cestado,' ||
  ' ff_desvalorfijo(18,' || pcidioma || ', c.cestado) testado,' ||
  ' d.tcconcta concepto, decode(c.cdebhab, 1, c.iimport, 0) idebe,' ||
  ' decode (c.cdebhab, 2, c.iimport, 0) ihaber, c.tdescrip, c.fvalor,' ||
  ' c.cconcta, c.cfiscal, ff_desvalorfijo(800017,' || pcidioma ||
  ', c.cfiscal) tfiscal, 1 cestpag' ||
  ' FROM ctactes c, desctactes d, liquidaage la' ||
  ' WHERE c.cconcta = d.cconcta' || ' AND d.cidioma = ' || pcidioma ||
  ' AND c.cagente = ' || pcagente || ' AND c.cconcta = 98' ||
  ' AND la.cagente = c.cagente' || ' AND la.cempres = c.cempres' ||
  ' AND la.sproliq = c.sproces';
  psquery := psquery || ') ORDER BY cagente, nnumlin desc';
  -- BUG14344:DRA:05/05/2010:Fi
  RETURN 0;
EXCEPTION
WHEN OTHERS THEN
  p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
  RETURN 9001936;
END f_get_ctas;

-- JLB - I -
   /*************************************************************************
       Función que borra los movimientos automaticos que se hayan creado en
       ctactes pendientes del movimiento
       RETURN NUMBER
   *************************************************************************/
   FUNCTION f_del_ctas_imp(pcempres IN NUMBER, pcagente IN NUMBER, pnnumlin IN NUMBER)
      RETURN NUMBER IS
      v_object       VARCHAR2(500) := 'PAC_LIQUIDA.f_del_ctas_imp';
      v_param        VARCHAR2(500)
         := 'params : pcempres : ' || pcempres || ', pcagente : ' || pcagente || ',pnnumlin :'
            || pnnumlin;
      v_pasexec      NUMBER(5) := 1;
   BEGIN
      DELETE      ctactes
            WHERE cempres = pcempres
              AND cagente = pcagente
              AND nnumlin_depen = pnnumlin;

      -- JLB - F
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
         RETURN 9001937;
   END f_del_ctas_imp;

-- JLB - F -

   /*************************************************************************
       Función que elimina una cuenta técnica de un agente
       param in  pcempres    : código empresa
       param in  pcagente    : código de agente
       param in  pnnumlin    : numero linea
       return                : 0.-    OK
                               1.-    KO
    *************************************************************************/
   FUNCTION f_del_ctas(pcempres IN NUMBER, pcagente IN NUMBER, pnnumlin IN NUMBER)
      RETURN NUMBER IS
      v_object       VARCHAR2(500) := 'PAC_LIQUIDA.f_del_ctas';
      v_param        VARCHAR2(500)
         := 'params : pcempres : ' || pcempres || ', pcagente : ' || pcagente || ',pnnumlin :'
            || pnnumlin;
      v_pasexec      NUMBER(5) := 1;
      v_factor       NUMBER;
      -- JLB - I
      v_error        NUMBER;
   -- JLB -F
   BEGIN
      DELETE      ctactes
            WHERE cempres = pcempres
              AND cagente = pcagente
              AND nnumlin = pnnumlin;

      -- JLB - I
      v_error := f_del_ctas_imp(pcempres, pcagente, pnnumlin);

      IF v_error <> 0 THEN
         RETURN v_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
         RETURN 9001937;
   END f_del_ctas;

   /*************************************************************************
       Función que devuelve el detalle de una cuenta técnica de un agente
       param in  pcempres    : código empresa
       param in  pcagente    : código de agente
       param in  pnnumlin    : numero linea
       param out psquery      : cursor con las cuentas técnicas de un agente
       return                : 0.-    OK
                               1.-    KO
    *************************************************************************/
   FUNCTION f_get_datos_cta(
      pcempres IN NUMBER,
      pcagente IN NUMBER,
      pnnumlin IN NUMBER,
      pcidioma IN NUMBER,
      psquery OUT VARCHAR2)
      RETURN NUMBER IS
      v_object       VARCHAR2(500) := 'PAC_LIQUIDA.f_get_datos_cta';
      v_param        VARCHAR2(500)
         := 'params : pcempres : ' || pcempres || ', pcidioma : ' || pcidioma
            || ',pcagente : ' || pcagente || ', pnnumlin :' || pnnumlin;
      v_pasexec      NUMBER(5) := 1;
      v_factor       NUMBER;
   BEGIN
      psquery :=
         'select c.cagente, pac_redcomercial.ff_desagente(c.cagente, ' || pcidioma
         || ') tnombre, c.nnumlin, c.cestado, ff_desvalorfijo(18,' || pcidioma
         || ',c.cestado) testado,
         c.ffecmov, c.cmanual, ndocume, c.cdebhab, c.iimport, t.cconcta cconcepto, c.tdescrip,
         c.nrecibo, c.nsinies, ff_desvalorfijo(693, '
         || pcidioma
         || ', c.cmanual) tipolin, c.sseguro,
         s.npoliza, s.ncertif, c.fvalor, d.tcconcta tconcepto, ff_desvalorfijo(19, '
         || pcidioma || ', c.cdebhab) tdebhab,c.cfiscal, ff_desvalorfijo(800017,' || pcidioma
         || ',c.cfiscal) tfiscal
         from ctactes c, desctactes d, codctactes t, seguros s
         where c.cconcta = d.cconcta
         and c.sseguro = s.sseguro(+)
         and c.cconcta = t.cconcta
         and d.cidioma = '
         || pcidioma || '
         and c.cagente = ' || pcagente || '
         and c.cempres = ' || pcempres || '
         and c.nnumlin = ' || pnnumlin;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
         RETURN 9001936;
   END f_get_datos_cta;

-- JLB - I -- nuevo

   /*************************************************************************
*************************************************************************/
   FUNCTION f_calc_formula_agente(
      pcagente IN NUMBER,
      pclave IN NUMBER,
      pfecefe IN DATE,
      presultado OUT NUMBER,
      psproduc IN NUMBER DEFAULT 0)
      RETURN NUMBER IS
      v_object       VARCHAR2(500) := 'PAC_LIQUIDA.f_calc_formula_agente';
      v_param        VARCHAR2(500)
                              := 'params : pcagente : ' || pcagente || ', pclave : ' || pclave;
      -- pac_calculo_formulas.calc_formul
      val            NUMBER;   -- Valor que retorna la formula
      xxformula      VARCHAR2(20000);   -- contiene la Formula a calcular
      xxsesion       NUMBER;   -- Nro de sesion que ejecuta la formula
      e              NUMBER;   -- Error Retorno funciones
      xxcodigo       VARCHAR2(30);
      xfecefe        NUMBER;
--
      xs             VARCHAR2(20000);
      retorno        NUMBER;
--
      xnmovimi       NUMBER;
      xfecha         NUMBER;
      xfefecto       NUMBER;
      xfvencim       NUMBER;
      xcforpag       NUMBER;
      ntraza         NUMBER := 0;
      v_cursor       INTEGER;
      v_filas        NUMBER;
      -- RSC 04/08/2008
      xfrevant       NUMBER;

      CURSOR cur_termino(wclave NUMBER) IS
         SELECT   parametro
             FROM sgt_trans_formula
            WHERE clave = wclave
         ORDER BY 1;

      no_encuentra   EXCEPTION;
   BEGIN
--DBMS_OUTPUT.PUT_LINE('ENTRAMOS');
      xfecefe := TO_NUMBER(TO_CHAR(NVL(pfecefe, f_sysdate), 'YYYYMMDD'));
      ntraza := 1;

--      IF psesion IS NULL THEN
      SELECT sgt_sesiones.NEXTVAL
        INTO xxsesion
        FROM DUAL;

      --    ELSE
        --     xxsesion := psesion;
          --END IF;
      IF xxsesion IS NULL THEN
         ROLLBACK;
         RETURN 108418;
      END IF;

      ntraza := 2;
--DBMS_OUTPUT.PUT_LINE('X_CLLAMADA ='||X_CLLAMADA);
--
      ntraza := 3;
      -- Quan hi ha error graba_param fa un RAISE exGrabaParam
      e := pac_calculo_formulas.graba_param(xxsesion, 'SESION', xxsesion);
      -- Insertamos parametros genericos para el calculo de las provisiones
      e := pac_calculo_formulas.graba_param(xxsesion, 'FECEFE', xfecefe);
      e := pac_calculo_formulas.graba_param(xxsesion, 'CAGENTE', pcagente);
      e := pac_calculo_formulas.graba_param(xxsesion, 'SPRODUC', psproduc);
--
      ntraza := 4;

      BEGIN
         SELECT formula, codigo
           INTO xxformula, xxcodigo
           FROM sgt_formulas
          WHERE clave = pclave;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, v_object, ntraza,
                        SUBSTR('error al buscar en SGT_FORMULAS' || ' PFECHA=' || pfecefe
                               || ' clave =' || pclave,
                               1, 500),
                        SUBSTR(SQLERRM, 1, 2500));
            RETURN 108423;
      END;

      -- Cargo parametros predefinidos
      ntraza := 6;

      FOR term IN cur_termino(pclave) LOOP
         BEGIN
--DBMS_OUTPUT.PUT_LINE ('SELECT CON CLLAMADA ='||X_CLLAMADA);
            SELECT 'BEGIN SELECT ' || tcampo || ' INTO :RETORNO  FROM ' || ttable || ' WHERE '
                   || twhere || ' ; END;'
              INTO xs
              FROM sgt_carga_arg_prede
             WHERE termino = term.parametro
               AND ttable IS NOT NULL
               AND cllamada = 'GENERICO';

            --
            IF DBMS_SQL.is_open(v_cursor) THEN
               DBMS_SQL.close_cursor(v_cursor);
            END IF;

            v_cursor := DBMS_SQL.open_cursor;
            DBMS_SQL.parse(v_cursor, xs, DBMS_SQL.native);
            DBMS_SQL.bind_variable(v_cursor, ':RETORNO', retorno);

            IF INSTR(xs, ':FECEFE') > 0 THEN
               DBMS_SQL.bind_variable(v_cursor, ':FECEFE', xfecefe);
            END IF;

            IF INSTR(xs, ':CAGENTE') > 0 THEN
               DBMS_SQL.bind_variable(v_cursor, ':CAGENTE', pcagente);
            END IF;

            IF INSTR(xs, ':SPRODUC') > 0 THEN
               DBMS_SQL.bind_variable(v_cursor, ':SPRODUC', psproduc);
            END IF;

            -- Fin Bug 10690
            BEGIN
               v_filas := DBMS_SQL.EXECUTE(v_cursor);
               DBMS_SQL.variable_value(v_cursor, 'RETORNO', retorno);

               IF DBMS_SQL.is_open(v_cursor) THEN
                  DBMS_SQL.close_cursor(v_cursor);
               END IF;
--DBMS_OUTPUT.PUT_LINE ('despues execute ' || term.parametro|| ':' || retorno);
            EXCEPTION
               WHEN OTHERS THEN
                  IF DBMS_SQL.is_open(v_cursor) THEN
                     DBMS_SQL.close_cursor(v_cursor);
                  END IF;

--DBMS_OUTPUT.PUT_LINE('ENTRAMOS EN WHEN OTHERS ='||SUBSTR(SQLERRM,0,255));
                  p_tab_error(f_sysdate, f_user, v_object, ntraza,
                              SUBSTR('error al ejecutar la select dinámica ' || ' PFECHA='
                                     || pfecefe || ' select =' || xs,
                                     1, 500),
                              SQLERRM);
--DBMS_OUTPUT.PUT_LINE ('whn others ' || term.parametro|| ':' || 0);
                  retorno := 0;
            END;

            IF retorno IS NULL THEN
               RETURN 103135;
            ELSE
               -- Quan hi ha error graba_param fa un RAISE exGrabaParam
               e := pac_calculo_formulas.graba_param(xxsesion, term.parametro, retorno);
            END IF;
         --
         EXCEPTION
            WHEN no_encuentra THEN
               xs := NULL;
            WHEN OTHERS THEN
               --DBMS_OUTPUT.PUT_LINE ('sqlerrm =' || SQLERRM);
               p_tab_error(f_sysdate, f_user, v_object, ntraza,
                           SUBSTR('error al buscar la select dinámica' || ' PFECHA='
                                  || pfecefe || ' para el termino =' || term.parametro,
                                  1, 500),
                           xs);
               xs := NULL;
               RETURN 109843;
         END;
      END LOOP;

      --DBMS_OUTPUT.put_line('INSERTAMOS LAS PREGUNTAS');
      ntraza := 9;
  --   DBMS_OUTPUT.PUT_LINE ('xxformula =' ||SUBSTR( xxformula,1,255));
--     DBMS_OUTPUT.PUT_LINE ('xxsesion =' || xxsesion);
 --
      ntraza := 12;

      BEGIN
         val := pk_formulas.eval(xxformula, xxsesion);
         -- Borro sgt_parms_transitorios
         -- CPM 20/12/05: Se descomenta el borrar parámetros y se hace antes de detectar
         --   si tenemos valor o no.
         e := pac_calculo_formulas.borra_param(xxsesion);

         IF val IS NULL THEN
            p_tab_error(f_sysdate, f_user, v_object, ntraza,
                        SUBSTR('error al evaluar la formula =' || xxformula || ' sesion ='
                               || xxsesion,
                               1, 500),
                        NULL);
            RETURN 103135;
         ELSE
            presultado := val;
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, v_object, ntraza,
                        SUBSTR('error Oracle al evaluar la formula =' || xxformula
                               || ' sesion =' || xxsesion,
                               1, 500),
                        SQLERRM);
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, ntraza, v_param, SQLERRM);
         RETURN 109843;
   END f_calc_formula_agente;

/*************************************************************************
*************************************************************************/
   FUNCTION f_insert_cta(
      pmodo IN NUMBER,   -- 1 previo, 2 liquidación
      pcagente IN ctactes.cagente%TYPE,
      pnnumlin IN ctactes.nnumlin%TYPE,
      pcdebhab IN ctactes.cdebhab%TYPE,
      pcconcta IN ctactes.cconcta%TYPE,
      pcestado IN ctactes.cestado%TYPE,
      pndocume IN ctactes.ndocume%TYPE,
      pffecmov IN ctactes.ffecmov%TYPE,
      piimport IN ctactes.iimport%TYPE,
      ptdescrip IN ctactes.tdescrip%TYPE,
      pcmanual IN ctactes.cmanual%TYPE,
      pcempres IN ctactes.cempres%TYPE,
      pnrecibo IN ctactes.nrecibo%TYPE,
      pnsinies IN ctactes.nsinies%TYPE,
      psseguro IN ctactes.sseguro%TYPE,
      pfvalor IN ctactes.fvalor%TYPE,
      psproces IN ctactes.sproces%TYPE,
      pcfiscal IN ctactes.cfiscal%TYPE,
      pnnumlin_depen IN ctactes.nnumlin_depen%TYPE,
      psproduc IN ctactes.sproduc%TYPE,
      pccompani IN ctactes.ccompani%TYPE   -- Bug 26964/146968 - 19/06/2013 - AMC
                                        )
      RETURN NUMBER IS
      v_object       VARCHAR2(500) := 'PAC_LIQUIDA.f_insert_cta';
      v_param        VARCHAR2(1000)
         := ' m=' || pmodo || ' a=' || pcagente || ' l=' || pnnumlin || ' dh=' || pcdebhab
            || ' c=' || pcconcta || ' e=' || pcestado || ' d=' || pndocume || ' f='
            || pffecmov || ' i=' || piimport || ' t=' || ptdescrip || ' a=' || pcmanual
            || ' e=' || pcempres || ' re=' || pnrecibo || ' si=' || pnsinies || ' se='
            || psseguro || ' v=' || pfvalor || ' p=' || psproces || ' f=' || pcfiscal || ' n='
            || pnnumlin_depen || ' p=' || psproduc || ' c=' || pccompani;
      v_paso_exec    NUMBER(5);
      v_anex_desc    VARCHAR2(25);
      v_cmoncia      NUMBER;   -- 24. 0024803 26/11/2012
   BEGIN
      v_paso_exec := 1;

      IF NVL(pac_parametros.f_parempresa_n(pcempres, 'CTAPROD'), 0) = 1 THEN
         v_anex_desc := ' - (' || NVL(f_cnvproductos_ext(psproduc), psproduc) || ')';
      END IF;

      -- 24. 0024803 26/11/2012 - Inicio
      IF NVL(pac_parametros.f_parempresa_n(pcempres, 'MULTIMONEDA'), 0) = 1 THEN
         v_cmoncia := pac_parametros.f_parempresa_n(pcempres, 'MONEDAEMP');
      END IF;

      IF NVL(pac_parametros.f_parempresa_n(pcempres, 'LIQ_DESG_COMP'), 0) = 1 THEN
         v_anex_desc := v_anex_desc || ' - (' || pccompani || ')';
      END IF;

      -- 24. 0024803 26/11/2012 - Fin
      IF pmodo = 1 THEN   --previo
         v_paso_exec := 2;

         INSERT INTO ctactes_previo
                     (cagente, nnumlin, cdebhab, cconcta, cestado, ndocume, ffecmov,
                      iimport, tdescrip, cmanual,
                      cempres, nrecibo, nsinies, sseguro, fvalor, sproces,
                      nnumlin_depen, sproduc,
                      ccompani   -- Bug 26964/146968 - 19/06/2013 - AMC
                              )
              VALUES (pcagente, pnnumlin, pcdebhab, pcconcta, pcestado, pndocume, pffecmov,
                      -- f_round(piimport), -- 24. 0024803 26/11/2012 (-)
                      f_round(piimport, v_cmoncia),   -- 24. 0024803 26/11/2012 (+)
                                                   ptdescrip || v_anex_desc, pcmanual,
                      pcempres, pnrecibo, pnsinies, psseguro, pfvalor, psproces,
                      pnnumlin_depen, psproduc,
                      pccompani   -- Bug 26964/146968 - 19/06/2013 - AMC
                               );
      ELSE   -- liquidacion
         v_paso_exec := 3;

         INSERT INTO ctactes
                     (cagente, nnumlin, cdebhab, cconcta, cestado, ndocume, ffecmov,
                      iimport, tdescrip, cmanual,
                      cempres, nrecibo, nsinies, sseguro, fvalor, sproces, cfiscal,
                      nnumlin_depen, sproduc,
                      ccompani   -- Bug 26964/146968 - 19/06/2013 - AMC
                              )
              VALUES (pcagente, pnnumlin, pcdebhab, pcconcta, pcestado, pndocume, pffecmov,
                      -- f_round(piimport), -- 24. 0024803 26/11/2012 (-)
                      f_round(piimport, v_cmoncia),   -- 24. 0024803 26/11/2012 (+)
                                                   ptdescrip || v_anex_desc, pcmanual,
                      pcempres, pnrecibo, pnsinies, psseguro, pfvalor, psproces, pcfiscal,
                      pnnumlin_depen, psproduc,
                      pccompani   -- Bug 26964/146968 - 19/06/2013 - AMC
                               );
      END IF;

      v_paso_exec := 4;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_paso_exec, v_param, SQLERRM);
         RETURN 9001949;
   END f_insert_cta;

/*************************************************************************
*************************************************************************/
   FUNCTION f_crea_conceptos_impuestos(
      pmodo IN NUMBER,
      pcagente IN ctactes.cagente%TYPE,
      pnnumlin IN ctactes.nnumlin%TYPE,
      pcdebhab IN ctactes.cdebhab%TYPE,
      pcconcta IN ctactes.cconcta%TYPE,
      pcestado IN ctactes.cestado%TYPE,
      pndocume IN ctactes.ndocume%TYPE,
      pffecmov IN ctactes.ffecmov%TYPE,
      piimport IN ctactes.iimport%TYPE,
      ptdescrip IN ctactes.tdescrip%TYPE,
      pcmanual IN ctactes.cmanual%TYPE,
      pcempres IN ctactes.cempres%TYPE,
      pnrecibo IN ctactes.nrecibo%TYPE,
      pnsinies IN ctactes.nsinies%TYPE,
      psseguro IN ctactes.sseguro%TYPE,
      pfvalor IN ctactes.fvalor%TYPE,
      psproces IN ctactes.sproces%TYPE,
      pcfiscal IN ctactes.cfiscal%TYPE,
      psproduc IN ctactes.sproduc%TYPE,
      pccompani IN ctactes.ccompani%TYPE   -- Bug 26964/146968 - 19/06/2013 - AMC
                                        )
      RETURN NUMBER IS
      v_object       VARCHAR2(500) := 'PAC_LIQUIDA.f_crea_conceptos_impuestos';
      v_param        VARCHAR2(500)
         := 'params : pcempres : ' || pcempres || ', pcagente : ' || pcagente
            || ', pnnumlin : ' || pnnumlin || ' , pcdebhab : ' || pcdebhab || ', pndocume : '
            || pndocume || ', ptdescrip : ' || ptdescrip || ', pnrecibo : ' || pnrecibo
            || ' , pnsinies : ' || pnsinies || ', pcconcepto :' || pcconcta || ', pffecmov : '
            || pffecmov || ', pcfiscal : ' || pcfiscal || ' pccompani:' || pccompani;
      verror         NUMBER(10);
      vvalor         NUMBER;
      v_nnumlin      ctactes.nnumlin%TYPE;
      vdebhab        ctactes.cdebhab%TYPE;
      v_cmoncia      NUMBER;   -- 24. 0024803 26/11/2012
   BEGIN
      -- Bug 24814 - APD - 20/12/2012 - si no existe parametrizacion para el sproduc indicado, buscar
      -- si existe parametrizacion para el sproduc = 0
      FOR reg IN (SELECT cconcta_imp, clave, cinvertido
                    FROM codctactes_imp
                   WHERE cempres = pcempres
                     AND cconcta = pcconcta
                     AND sproduc = NVL(psproduc, 0)   -- JLB  bug 21164(0109619)
                     AND NVL(psproduc, 0) <> 0
                  UNION
                  SELECT cconcta_imp, clave, cinvertido
                    FROM codctactes_imp
                   WHERE cempres = pcempres
                     AND cconcta = pcconcta
                     AND sproduc = 0
                     AND cconcta_imp NOT IN(SELECT cconcta_imp
                                              FROM codctactes_imp
                                             WHERE cempres = pcempres
                                               AND cconcta = pcconcta
                                               AND sproduc =
                                                     NVL(psproduc, 0)   -- JLB  bug 21164(0109619)
                                               AND NVL(psproduc, 0) <> 0)) LOOP
         -- fin Bug 24814 - APD - 20/12/2012

         -- Bug 24814 - APD - 20/12/2012 - si la clave = 1 indica que no se quiere impuestos
         -- para esa ctactes (esto es para el caso que existe la parametrizacion general, es
         -- decir, la parametrizacion del impuesto para el sproduc = 0)
         IF reg.clave <> 1 THEN
            verror := f_calc_formula_agente(pcagente, reg.clave, pffecmov, vvalor, psproduc);

            IF verror <> 0 THEN
               RETURN verror;
            END IF;

            IF pmodo = 1 THEN   -- 1 previo
               SELECT NVL(MAX(nnumlin), 0) + 1
                 INTO v_nnumlin
                 FROM ctactes_previo
                WHERE cagente = pcagente;
            ELSE   --2 liquidacion
               SELECT NVL(MAX(nnumlin), 0) + 1
                 INTO v_nnumlin
                 FROM ctactes
                WHERE cagente = pcagente;
            END IF;

            -- giro el debe y el haber de lo que me ha llegado
            IF reg.cinvertido = 0 THEN
               IF pcdebhab = 2 THEN
                  vdebhab := 1;
                  if reg.cconcta_imp = 53 and pcconcta <> 99 THEN -- BUG 1892 21/03/2018 AP
                    vdebhab := 2;
                  END IF;
               ELSE
                  vdebhab := 2;
                  if reg.cconcta_imp = 53 and pcconcta <> 99 THEN -- BUG 1892 21/03/2018 AP
                    vdebhab := 1;
                  END IF;
               END IF;
            ELSE
               IF pcdebhab = 2 THEN
                  vdebhab := 2;
                  if reg.cconcta_imp = 53 and pcconcta <> 99 THEN -- BUG 1892 21/03/2018 AP
                    vdebhab := 1;
                  END IF;
               ELSE
                  vdebhab := 1;
                  if reg.cconcta_imp = 53 and pcconcta <> 99 THEN -- BUG 1892 21/03/2018 AP
                    vdebhab := 2;
                  END IF;
               END IF;
            END IF;

            -- 24. 0024803 26/11/2012 - Inicio
            IF NVL(pac_parametros.f_parempresa_n(pcempres, 'MULTIMONEDA'), 0) = 1 THEN
               v_cmoncia := pac_parametros.f_parempresa_n(pcempres, 'MONEDAEMP');
            END IF;

            -- 24. 0024803 26/11/2012 - Fin
            verror := f_insert_cta(pmodo, pcagente, v_nnumlin, vdebhab, reg.cconcta_imp,
                                   pcestado, pndocume, pffecmov,

                                   -- f_round((piimport * NVL(vvalor, 0))), -- 24. 0024803 26/11/2012 (-)
                                   f_round((piimport * NVL(vvalor, 0)), v_cmoncia),   -- 24. 0024803 26/11/2012 (+)
                                   ptdescrip, pcmanual, pcempres, pnrecibo, pnsinies, psseguro,
                                   pfvalor, psproces, pcfiscal, pnnumlin, psproduc,
                                   pccompani   -- Bug 26964/146968 - 19/06/2013 - AMC
                                            );

            IF verror <> 0 THEN
               RETURN verror;
            END IF;
         END IF;   -- fin Bug 24814 - APD - 20/12/2012
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, 1, v_param, SQLERRM);
         RETURN 1;
   END f_crea_conceptos_impuestos;

-- JLB - F

   /*************************************************************************
       Función que insertará o modificará una cuenta técnica de un agente en función del pmodo
       param in  pcempres    : código empresa
       param in  pcagente    : código de agente
       param in  pnnumlin    : numero linea
       param in pcimporte    : Codigo debe o haber
       param in pimporte     : Importe
       param in pndocume     : numero documento
       param in ptdescrip    : Texto
       param in pmodo        : 0 Modificación - 1 Inserción
       param in pnrecibo     : num. recibos
       param in pnsinies     : num. siniestro
       param in pcconcepto   : codigo concepto cta. corriente
       param in pffecmov
       return                : 0.-    OK
                               1.-    KO
    *************************************************************************/
   FUNCTION f_set_cta(
      pcempres IN NUMBER,
      pcagente IN NUMBER,
      psseguro IN NUMBER,
      pnnumlin IN NUMBER,
      pcdebhab IN NUMBER,
      pimporte IN NUMBER,
      pndocume IN VARCHAR2,
      ptdescrip IN VARCHAR2,
      pmodo IN NUMBER,
      pnrecibo IN NUMBER,
      pnsinies IN NUMBER,
      pcconcepto IN NUMBER,
      pffecmov IN DATE,
      pfvalor IN DATE,
      pcfiscal IN NUMBER,
      psproduc IN NUMBER)
      RETURN NUMBER IS
      v_object       VARCHAR2(500) := 'PAC_LIQUIDA.f_set_cta';
      v_param        VARCHAR2(500)
         := 'params : pcempres : ' || pcempres || ', pcagente : ' || pcagente
            || ', pnnumlin : ' || pnnumlin || ' , pcdebhab : ' || pcdebhab || ', pndocume : '
            || pndocume || ', ptdescrip : ' || ptdescrip || ', pmodo : ' || pmodo
            || ', pnrecibo : ' || pnrecibo || ' , pnsinies : ' || pnsinies || ', pcconcepto :'
            || ', pffecmov : ' || pffecmov || ', pcfiscal : ' || pcfiscal;
      v_pasexec      NUMBER(5) := 1;
      v_exist        NUMBER;
      v_cconcta      NUMBER;
      v_cont         NUMBER;
      v_nnumlin      NUMBER;
      vccodcon       NUMBER;
      vffecmov       DATE;
      vsseguro       NUMBER;
      -- JLB - i
      verror         NUMBER;
      vcagente       NUMBER;
      -- JLB - F
      vsproduc       NUMBER;
      vccompani      NUMBER;   -- Bug 26964/146968 - 19/06/2013 - AMC
      --JLV bug 27599 - 25/07/2013
      v_esage        BOOLEAN := FALSE;
	  v_cageaux number;

   BEGIN
      IF pffecmov IS NULL THEN
         vffecmov := f_sysdate;
      ELSE
         vffecmov := pffecmov;
      END IF;

      --No se puede imputar a meses cerrados
      IF pfvalor IS NOT NULL
         AND TRUNC(pfvalor) < NVL(pac_cierres.f_fecha_ultcierre(pcempres, 17), pfvalor) THEN
         RETURN 107855;
      END IF;

	    v_pasexec  := 1;

      -- Bug 21285/106731 - 09/02/2012 - AMC
      --Comprobamos que la poliza/recibo/siniestro pertenezca a agente
      IF psseguro IS NOT NULL THEN

	  v_pasexec  := 2;

         SELECT cagente,
                DECODE(NVL(pac_parametros.f_parempresa_n(pcempres, 'CTAPROD'), 0),
                       1, sproduc,
                       0),
                DECODE
                   (NVL(pac_parametros.f_parempresa_n(pcempres, 'LIQ_DESG_COMP'), 0),
                    1, DECODE(pac_cuadre_adm.f_es_vida(sseguro), 1, 2, 1),
                    0)   -- Bug 26964/146968 - 19/06/2013 - AMC
           INTO vcagente,
                vsproduc,
                vccompani   -- Bug 26964/146968 - 19/06/2013 - AMC
           FROM seguros
          WHERE sseguro = psseguro;

         IF vcagente <> pcagente THEN   --JLV 25/07/2013 bug 27599, nos aseguramos que no sea un agente del cocorretaje.
            FOR c_coco IN (SELECT cagente
                             FROM age_corretaje
                            WHERE sseguro = psseguro
                              AND islider = 0) LOOP
               IF c_coco.cagente = pcagente THEN
                  v_esage := TRUE;
                  EXIT;
               END IF;
            END LOOP;

			  --Nos aseguramos que no sea el padre del agente por comisión indirecta
          if not v_esage then
             v_cageaux := nvl(pac_redcomercial.f_busca_padre(pcempres,vcagente,null,pfvalor),0);
             if v_cageaux = pcagente then --si es el padre del agente de la póliza el que me llega le dejo pasar
              v_esage:=true; --sino sigue false
            end if;
          end if;

            IF NOT v_esage THEN
               RETURN 9903256;
            END IF;
         END IF;

		 v_pasexec  := 3;

      ELSIF pnrecibo IS NOT NULL THEN

	  v_pasexec  := 4;
         SELECT sseguro
           INTO vsseguro
           FROM recibos
          WHERE nrecibo = pnrecibo;

         SELECT cagente,
                DECODE(NVL(pac_parametros.f_parempresa_n(pcempres, 'CTAPROD'), 0),
                       1, sproduc,
                       0),
                DECODE
                   (NVL(pac_parametros.f_parempresa_n(pcempres, 'LIQ_DESG_COMP'), 0),
                    1, DECODE(pac_cuadre_adm.f_es_vida(sseguro), 1, 2, 1),
                    0)   -- Bug 26964/146968 - 19/06/2013 - AMC
           INTO vcagente,
                vsproduc,
                vccompani   -- Bug 26964/146968 - 19/06/2013 - AMC
           FROM seguros
          WHERE sseguro = vsseguro;

         IF vcagente <> pcagente THEN   --JLV 25/07/2013 bug 27599, nos aseguramos que no sea un agente del cocorretaje.
            FOR c_coco IN (SELECT cagente
                             FROM age_corretaje
                            WHERE sseguro = vsseguro
                              AND islider = 0) LOOP
               IF c_coco.cagente = pcagente THEN
                  v_esage := TRUE;
                  EXIT;
               END IF;
            END LOOP;

				  --Nos aseguramos que no sea el padre del agente por comisión indirecta
          if not v_esage then
             v_cageaux := nvl(pac_redcomercial.f_busca_padre(pcempres,vcagente,null,pfvalor),0);
             if v_cageaux = pcagente then --si es el padre del agente de la póliza el que me llega le dejo pasar
              v_esage:=true; --sino sigue false
            end if;
          end if;

            IF NOT v_esage THEN
               RETURN 9903257;
            END IF;
         END IF;
		 v_pasexec  := 5;
      ELSIF pnsinies IS NOT NULL THEN
	  v_pasexec  := 6;
         IF NVL(pac_parametros.f_parempresa_n(pcempres, 'MODULO_SINI'), 0) = 0 THEN
            SELECT sseguro
              INTO vsseguro
              FROM siniestros
             WHERE nsinies = pnsinies;
         ELSE
            SELECT sseguro
              INTO vsseguro
              FROM sin_siniestro
             WHERE nsinies = pnsinies;
         END IF;

         SELECT cagente,
                DECODE(NVL(pac_parametros.f_parempresa_n(pcempres, 'CTAPROD'), 0),
                       1, sproduc,
                       0),
                DECODE
                   (NVL(pac_parametros.f_parempresa_n(pcempres, 'LIQ_DESG_COMP'), 0),
                    1, DECODE(pac_cuadre_adm.f_es_vida(sseguro), 1, 2, 1),
                    0)   -- Bug 26964/146968 - 19/06/2013 - AMC
           INTO vcagente,
                vsproduc,
                vccompani   -- Bug 26964/146968 - 19/06/2013 - AMC
           FROM seguros
          WHERE sseguro = vsseguro;

         IF vcagente <> pcagente THEN   --JLV 25/07/2013 bug 27599, nos aseguramos que no sea un agente del cocorretaje.
            FOR c_coco IN (SELECT cagente
                             FROM age_corretaje
                            WHERE sseguro = vsseguro
                              AND islider = 0) LOOP
               IF c_coco.cagente = pcagente THEN
                  v_esage := TRUE;
                  EXIT;
               END IF;
            END LOOP;

					  --Nos aseguramos que no sea el padre del agente por comisión indirecta
          if not v_esage then
             v_cageaux := nvl(pac_redcomercial.f_busca_padre(pcempres,vcagente,null,pfvalor),0);
             if v_cageaux = pcagente then --si es el padre del agente de la póliza el que me llega le dejo pasar
              v_esage:=true; --sino sigue false
            end if;
          end if;

            IF NOT v_esage THEN
               RETURN 9903258;
            END IF;
         END IF;
		 v_pasexec  := 7;
      END IF;

      vsproduc := NVL(NVL(psproduc, vsproduc), 0);

      -- Fi Bug 21285/106731 - 09/02/2012 - AMC
      IF pmodo = 0 THEN   --Modificación de registros
	  v_pasexec  := 8;
         SELECT COUNT(1)
           INTO v_exist
           FROM ctactes
          WHERE cagente = pcagente
            AND cempres = pcempres
            AND nnumlin = pnnumlin;

			v_pasexec  := 9;

         IF v_exist > 0 THEN
            SELECT cconcta
              INTO v_cconcta
              FROM ctactes
             WHERE cagente = pcagente
               AND cempres = pcempres
               AND nnumlin = pnnumlin;

            IF v_cconcta <> pcconcepto THEN
               SELECT COUNT(1)
                 INTO v_cont
                 FROM ctactes c, codctactes cc
                WHERE c.cagente = pcagente
                  AND c.cestado = 1
                  AND c.cconcta = cc.cconcta
                  AND cc.cconcta = pcconcepto;

               IF v_cont > 0 THEN
                  RETURN 9001938;
               END IF;
            END IF;

			v_pasexec  := 10;

            UPDATE ctactes
               SET cdebhab = pcdebhab,
                   iimport = pimporte,
                   ndocume = pndocume,
                   tdescrip = ptdescrip,
                   cconcta = pcconcepto,
                   fvalor = pfvalor,
                   cfiscal = pcfiscal
             WHERE cagente = pcagente
               AND nnumlin = pnnumlin
               AND cempres = pcempres;

            -- JLB --
             -- f_del_ctaas
			 v_pasexec  := 11;
            verror := f_del_ctas_imp(pcempres, pcagente, pnnumlin);
			v_pasexec  := 12;

            IF verror <> 0 THEN
               RETURN verror;
            END IF;
v_pasexec  := 13;
            verror :=
               f_crea_conceptos_impuestos(2, pcagente, pnnumlin, pcdebhab, pcconcepto, 1,
                                          pndocume, pffecmov, pimporte, ptdescrip, 1, pcempres,
                                          pnrecibo, pnsinies, psseguro, pfvalor, NULL,
                                          pcfiscal, vsproduc,
                                          vccompani   -- Bug 26964/146968 - 19/06/2013 - AMC
                                                   );

            v_pasexec  := 14;
			IF verror <> 0 THEN
               RETURN verror;
            END IF;
         -- JLB F
         END IF;
      ELSIF pmodo = 1 THEN   --Inserción de registros
         v_pasexec  := 15;
		 IF pnrecibo IS NOT NULL THEN
            SELECT COUNT(1)
              INTO v_cont
              FROM recibos
             WHERE nrecibo = pnrecibo
               AND cagente = pcagente;
     --INI BUG 1891 AP CONSULTA AGENTES CON CORRETAJE
       IF v_cont = 0 THEN
             select count(1)
              INTO v_cont
              from age_corretaje a
             where a.cagente =  pcagente
               and a.sseguro = (select sseguro from recibos where nrecibo = pnrecibo)
               and a.nmovimi = (select max(nmovimi) from age_corretaje where cagente = pcagente and sseguro = (select sseguro from recibos where nrecibo = pnrecibo));
        END IF;
    --FIN BUG 1891 AP
            IF v_cont = 0 THEN
               RETURN 9001939;
            END IF;
			v_pasexec  := 16;
         END IF;

         IF pnsinies IS NOT NULL THEN
		 v_pasexec  := 17;
            -- BUG 11595 - 02/11/2009 - APD - Adaptación al nuevo módulo de siniestros
            IF NVL(pac_parametros.f_parempresa_n(pcempres, 'MODULO_SINI'), 0) = 0 THEN
               SELECT COUNT(1)
                 INTO v_cont
                 FROM siniestros
                WHERE nsinies = pnsinies;
            ELSE
               SELECT COUNT(1)
                 INTO v_cont
                 FROM sin_siniestro
                WHERE nsinies = pnsinies;
            END IF;

            -- Fin BUG 11595 - 02/11/2009 - APD - Adaptación al nuevo módulo de siniestros
            IF v_cont = 0 THEN
               RETURN 9001940;
            END IF;
			v_pasexec  := 18;
         END IF;

         SELECT NVL(MAX(nnumlin), 0) + 1
           INTO v_nnumlin
           FROM ctactes
          WHERE cagente = pcagente;

         vsseguro := psseguro;
v_pasexec  := 19;
         IF psseguro IS NULL THEN
            IF pnrecibo IS NOT NULL THEN
               SELECT sseguro
                 INTO vsseguro
                 FROM recibos
                WHERE nrecibo = pnrecibo;
            ELSIF pnsinies IS NOT NULL THEN
               -- BUG 11595 - 02/11/2009 - APD - Adaptación al nuevo módulo de siniestros
               IF NVL(pac_parametros.f_parempresa_n(pcempres, 'MODULO_SINI'), 0) = 0 THEN
                  SELECT sseguro
                    INTO vsseguro
                    FROM siniestros
                   WHERE nsinies = pnsinies;
               ELSE
                  SELECT sseguro
                    INTO vsseguro
                    FROM sin_siniestro
                   WHERE nsinies = pnsinies;
               END IF;
            -- Fin BUG 11595 - 02/11/2009 - APD - Adaptación al nuevo módulo de siniestros
            END IF;
         END IF;
		 v_pasexec  := 20;

         -- JLB  - I
                --INSERT INTO ctactes
                  --          (cagente, nnumlin, cdebhab, cconcta, cestado, ffecmov, iimport, cmanual,
                    --         cempres, tdescrip, nrecibo, nsinies, ndocume, sseguro, fvalor,
                      --       cfiscal)
                     --VALUES (pcagente, v_nnumlin, pcdebhab, pcconcepto, 1, vffecmov, pimporte, 0,
                       --      pcempres, ptdescrip, pnrecibo, pnsinies, pndocume, vsseguro, pfvalor,
                         --    pcfiscal);
						 v_pasexec  := 21;
         verror := f_insert_cta(2,   -- liquidacion
                                pcagente,   -- pcagente
                                v_nnumlin,   -- PNNUMLIN,
                                pcdebhab,   --PCDEBHAB,
                                pcconcepto,   --PCCONCTA,
                                1,   -- pcestado
                                pndocume,   -- PNDOCUME,
                                vffecmov,   -- PFFECMOV,
                                pimporte,   -- PIIMPORT,
                                ptdescrip,   --PTDESCRIP,
                                0,   --PCMANUAL,
                                pcempres,   --PCEMPRES,
                                pnrecibo,   --PNRECIBO,
                                pnsinies,   -- PNSINIES,
                                vsseguro,   --PSSEGURO,
                                pfvalor,   --PFVALOR,
                                NULL,   -- PSPROCES ,
                                pcfiscal,   -- PCFISCAL,
                                NULL,   --PNNUMLIN_DEPEN
                                vsproduc, vccompani   -- Bug 26964/146968 - 19/06/2013 - AMC
                                                   );
												   v_pasexec  := 22;

         IF verror <> 0 THEN
            RETURN verror;
         END IF;
v_pasexec  := 23;
         verror := f_crea_conceptos_impuestos(2, pcagente, v_nnumlin, pcdebhab, pcconcepto, 1,
                                              pndocume, vffecmov, pimporte, ptdescrip, 1,
                                              pcempres, pnrecibo, pnsinies, vsseguro, pfvalor,
                                              NULL, pcfiscal, vsproduc,
                                              vccompani   -- Bug 26964/146968 - 19/06/2013 - AMC
                                                       );
v_pasexec  := 24;

         IF verror <> 0 THEN
            RETURN verror;
         END IF;
      -- JLB - F
      END IF;
	  v_pasexec  := 25;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
         RETURN 9001949;
   END f_set_cta;

   /*************************************************************************
       Función que devuelve el detalle de una cuenta técnica de un agente
       pcagente IN NUMBER,
      pcempres IN NUMBER,
      psproces IN NUMBER,
      pcidioma IN NUMBER,
      pfmovimi IN DATE,
      pmodo IN NUMBER,
      parupacion IN NUMBER
       return                : 0.-    OK
                               1.-    KO

    *************************************************************************/
   FUNCTION f_set_resumen_ctactes(
      pcagente IN NUMBER,
      pcempres IN NUMBER,
      psproces IN NUMBER,
      pcidioma IN NUMBER,
      pfecliq IN DATE,
      pnliqmen IN NUMBER,
      pmodo IN NUMBER,
      pcagentevision IN NUMBER,
      psmovagr IN NUMBER DEFAULT NULL   -- 21. 0022753
                                     )
      RETURN NUMBER IS
      v_object       VARCHAR2(500) := 'PAC_LIQUIDA.f_set_resumen_ctactes';
      v_param        VARCHAR2(500)
         := 'params : pcempres : ' || pcempres || ', pmodo : ' || pmodo || ',pcagente : '
            || pcagente || ', psproces :' || psproces || ', agente vision :' || pcagentevision;
      v_pasexec      NUMBER(5) := 1;
      v_factor       NUMBER;
      vcdebhab       NUMBER;
      v_nnumlin      NUMBER;
      vidioma        NUMBER;
      vpago          NUMBER;
      vctipban       NUMBER;
      vcbancar       agentes.cbancar%TYPE;
      vimporte       NUMBER;
      v_nrecpend     NUMBER;
      v_nnumlin_pago NUMBER := 0;
      -- Bug 0019154 - JMF - 02/08/2011
      n_prodext      NUMBER;   -- Productos externos.
      -- JLB - I
      verror         NUMBER;
      v_cmoncia      NUMBER;   -- 24. 0024803 26/11/2012
      vterminal      VARCHAR2(200);
      vtipopago      NUMBER := 11;
      vemitido       NUMBER;
      perror         VARCHAR2(2000);
      psinterf       NUMBER;
      -- 43.0 - 08/01/2014 - MMM - 0029471: LCOL_C004-LCOL: Ajuste en el proceso de liquidacion de Convenio Liberty Web - Inicio
      v_sobrecomis   NUMBER;

      -- 43.0 - 08/01/2014 - MMM - 0029471: LCOL_C004-LCOL: Ajuste en el proceso de liquidacion de Convenio Liberty Web - Fin

      -- JLB  - F
         -- Bug 26022 - APD - 08/02/2013 - recuperar los campos de liquidalin según el campo de compañía
         -- NVL(icomisi_moncia, icomisi), NVL(iretenccom_moncia, iretenccom)
         -- NVL(lq.icomisi_moncia, lq.icomisi), NVL(lq.iretenccom_moncia, lq.iretenccom)
      CURSOR c_liqmovrec_previo IS
         SELECT   cempres, cagente, SUM(suma) suma, sprod, SUM(suma_aho) suma_aho,
                  SUM(iconvoleducto) iconvoleducto,   -- Bug 25988/145805 - 06/06/2013 - AMC
                  compania   -- Bug 26964/146968 - 19/06/2013 - AMC
             FROM (SELECT   lq.cempres, lq.cagente,
                            DECODE(NVL(pac_parametros.f_parempresa_n(pcempres, 'CTAPROD'), 0),
                                   1, s.sproduc,
                                   0) sprod,
                            sum(nvl(icomisi_moncia, icomisi)) suma, -- BUG 1896 AP 23/04/2018
                            SUM(NVL(icomisi_moncia, icomisi)
                                - NVL(iretenccom_moncia, iretenccom)) suma1, -- BUG 1896 AP 23/04/2018
                            SUM(DECODE(r.ctiprec,
                                       5, nvl(lq.icomisi_moncia, lq.icomisi),
                                       0)) suma_aho, -- BUG 1896 AP 23/04/2018
                            SUM(DECODE(r.ctiprec,
                                       5, NVL(lq.icomisi_moncia, lq.icomisi)
                                        - NVL(lq.iretenccom_moncia, lq.iretenccom),
                                       0)) suma_aho1, -- BUG 1896 AP 23/04/2018
                            SUM(NVL(lq.iconvoleducto, 0)) iconvoleducto,   -- Bug 25988/145805 - 06/06/2013 - AMC
                            DECODE
                               (NVL(pac_parametros.f_parempresa_n(pcempres, 'LIQ_DESG_COMP'),
                                    0),
                                1, DECODE(pac_cuadre_adm.f_es_vida(s.sseguro), 1, 2, 1),
                                0) compania   -- Bug 26964/146968 - 19/06/2013 - AMC
                       FROM liquidalin lq, liquidacab lc, recibos r, seguros s
                      WHERE lq.cempres = pcempres
                        AND lq.nliqmen = pnliqmen
                        AND lq.cagente = NVL(pcagente, lq.cagente)
                        AND lq.cagente = lc.cagente
                        AND lq.cempres = lc.cempres
                        AND lq.nliqmen = lc.nliqmen
                        AND lc.cestado IS NULL
                        AND lq.nrecibo = r.nrecibo
                        AND r.sseguro = s.sseguro
                   GROUP BY lq.cempres, lq.cagente,
                            DECODE(NVL(pac_parametros.f_parempresa_n(pcempres, 'CTAPROD'), 0),
                                   1, s.sproduc,
                                   0),
                            DECODE
                               (NVL(pac_parametros.f_parempresa_n(pcempres, 'LIQ_DESG_COMP'),
                                    0),
                                1, DECODE(pac_cuadre_adm.f_es_vida(s.sseguro), 1, 2, 1),
                                0)   -- Bug 26964/146968 - 19/06/2013 - AMC
                   UNION ALL
                   SELECT   lq.cempres, lq.cagente,
                            DECODE(NVL(pac_parametros.f_parempresa_n(pcempres, 'CTAPROD'), 0),
                                   1, s.sproduc,
                                   0) sprod,
                            sum(lq.icomisi) suma,   -- Bug 18843/91812 - 06/09/2011 - AMC
                            sum(lq.icomisi - iretenccom) sumaf1,   -- Bug 18843/91812 - 06/09/2011 - AMC
                            sum(decode(r.ctiprec, 5, lq.icomisi, 0)) suma_aho, -- BUG 1896 AP 23/04/2018
                            SUM(DECODE(r.ctiprec, 5, lq.icomisi - iretenccom, 0)) suma_ahof1, -- BUG 1896 AP 23/04/2018
                            SUM(NVL(lq.iconvoleducto, 0)) iconvoleducto,   -- Bug 25988/145805 - 06/06/2013 - AMC
                            DECODE
                               (NVL(pac_parametros.f_parempresa_n(pcempres, 'LIQ_DESG_COMP'),
                                    0),
                                1, s.ccompani,
                                0) compania   -- Bug 26964/146968 - 19/06/2013 - AMC
                       FROM ext_liquidalin lq, liquidacab lc, ext_recibos r, ext_seguros s
                      WHERE lq.cempres = pcempres
                        AND lq.nliqmen = pnliqmen
                        AND lq.cagente = NVL(pcagente, lq.cagente)
                        AND lq.cagente = lc.cagente
                        AND lq.cempres = lc.cempres
                        AND lq.nliqmen = lc.nliqmen
                        AND lc.cestado = NULL
                        AND lq.num_rec = r.nreccia
                        AND lq.ccompani = r.ccompani
                        AND r.sextmovrec = (SELECT MAX(sextmovrec)
                                              FROM ext_recibos
                                             WHERE ccompani = r.ccompani
                                               AND nreccia = r.nreccia)
                        AND r.npolcia = s.npoliza
                        AND r.ccompani = s.ccompani
                        AND n_prodext = 1
                   GROUP BY lq.cempres, lq.cagente,
                            DECODE(NVL(pac_parametros.f_parempresa_n(pcempres, 'CTAPROD'), 0),
                                   1, s.sproduc,
                                   0),
                            DECODE(NVL(pac_parametros.f_parempresa_n(pcempres, 'LIQ_DESG_COMP'),
                                       0),
                                   1, s.ccompani,
                                   0))   -- Bug 26964/146968 - 19/06/2013 - AMC
         GROUP BY cempres, cagente, sprod, compania;   -- Bug 26964/146968 - 19/06/2013 - AMC

      -- fin Bug 26022 - APD - 08/02/2013

      -- Bug 26022 - APD - 08/02/2013 - recuperar los campos de liquidalin según el campo de compañía
      -- NVL(icomisi_moncia, icomisi), NVL(iretenccom_moncia, iretenccom)
      -- NVL(lq.icomisi_moncia, lq.icomisi), NVL(lq.iretenccom_moncia, lq.iretenccom)
      CURSOR c_liqmovrec IS
         SELECT   cempres, cagente, SUM(suma) suma, sprod, SUM(suma_aho) suma_aho,
                  SUM(iconvoleducto) iconvoleducto,   -- Bug 25988/145805 - 06/06/2013 - AMC
                  compania   -- Bug 26964/146968 - 19/06/2013 - AMC
             FROM (SELECT   lq.cempres, lq.cagente,
                            DECODE(NVL(pac_parametros.f_parempresa_n(pcempres, 'CTAPROD'), 0),
                                   1, s.sproduc,
                                   0) sprod,
                            sum(nvl(icomisi_moncia, icomisi)) suma,   -- Bug 18843/91812 - 06/09/2011 - AMC -- BUG 1896 AP 23/04/2018
                            SUM(NVL(icomisi_moncia, icomisi)
                                - NVL(iretenccom_moncia, iretenccom)) suma2,   -- Bug 18843/91812 - 06/09/2011 - AMC -- BUG 1896 AP 23/04/2018
                            SUM(DECODE(r.ctiprec,
                                       5, NVL(lq.icomisi_moncia, lq.icomisi),
                                       0)) suma_aho, -- BUG 1896 AP 23/04/2018
                            SUM(DECODE(r.ctiprec,
                                       5, NVL(lq.icomisi_moncia, lq.icomisi)
                                        - NVL(lq.iretenccom_moncia, lq.iretenccom),
                                       0)) suma_aho2, -- BUG 1896 AP 23/04/2018
                            SUM(NVL(lq.iconvoleducto, 0)) iconvoleducto,   -- Bug 25988/145805 - 06/06/2013 - AMC
                            DECODE
                               (NVL(pac_parametros.f_parempresa_n(pcempres, 'LIQ_DESG_COMP'),
                                    0),
                                1, DECODE(pac_cuadre_adm.f_es_vida(s.sseguro), 1, 2, 1),
                                0) compania   -- Bug 26964/146968 - 19/06/2013 - AMC
                       FROM liquidalin lq, liquidacab lc, recibos r, seguros s
                      WHERE lq.cempres = pcempres
                        AND lq.nliqmen = pnliqmen
                        AND lq.cagente = NVL(pcagente, lq.cagente)
                        AND lq.cagente = lc.cagente
                        AND lq.cempres = lc.cempres
                        AND lq.nliqmen = lc.nliqmen
                        AND lc.cestado = 1
                        AND lq.nrecibo = r.nrecibo
                        AND r.sseguro = s.sseguro
                   GROUP BY lq.cempres, lq.cagente,
                            DECODE(NVL(pac_parametros.f_parempresa_n(pcempres, 'CTAPROD'), 0),
                                   1, s.sproduc,
                                   0),
                            DECODE
                               (NVL(pac_parametros.f_parempresa_n(pcempres, 'LIQ_DESG_COMP'),
                                    0),
                                1, DECODE(pac_cuadre_adm.f_es_vida(s.sseguro), 1, 2, 1),
                                0)   -- Bug 26964/146968 - 19/06/2013 - AMC
                   UNION ALL
                   SELECT   lq.cempres, lq.cagente,
                            DECODE(NVL(pac_parametros.f_parempresa_n(pcempres, 'CTAPROD'), 0),
                                   1, s.sproduc,
                                   0) sprod,
                            sum(lq.icomisi) suma,   -- Bug 18843/91812 - 06/09/2011 - AMC -- BUG 1896 AP 23/04/2018
                            sum(lq.icomisi - iretenccom) sumaf2,   -- Bug 18843/91812 - 06/09/2011 - AMC -- BUG 1896 AP 23/04/2018
                            sum(decode(r.ctiprec, 5, lq.icomisi, 0)) suma_aho, -- BUG 1896 AP 23/04/2018
                            SUM(DECODE(r.ctiprec, 5, lq.icomisi - iretenccom, 0)) suma_ahof2, -- BUG 1896 AP 23/04/2018
                            SUM(NVL(lq.iconvoleducto, 0)) iconvoleducto,   -- Bug 25988/145805 - 06/06/2013 - AMC
                            DECODE
                               (NVL(pac_parametros.f_parempresa_n(pcempres, 'LIQ_DESG_COMP'),
                                    0),
                                1, s.ccompani,
                                0) compania   -- Bug 26964/146968 - 19/06/2013 - AMC
                       FROM ext_liquidalin lq, liquidacab lc, ext_recibos r, ext_seguros s
                      WHERE lq.cempres = pcempres
                        AND lq.nliqmen = pnliqmen
                        AND lq.cagente = NVL(pcagente, lq.cagente)
                        AND lq.cagente = lc.cagente
                        AND lq.cempres = lc.cempres
                        AND lq.nliqmen = lc.nliqmen
                        AND lc.cestado = 1
                        AND lq.num_rec = r.nreccia
                        AND lq.ccompani = r.ccompani
                        AND r.sextmovrec = (SELECT MAX(sextmovrec)
                                              FROM ext_recibos
                                             WHERE ccompani = r.ccompani
                                               AND nreccia = r.nreccia)
                        AND r.npolcia = s.npoliza
                        AND r.ccompani = s.ccompani
                        AND n_prodext = 1
                   GROUP BY lq.cempres, lq.cagente,
                            DECODE(NVL(pac_parametros.f_parempresa_n(pcempres, 'CTAPROD'), 0),
                                   1, s.sproduc,
                                   0),
                            DECODE(NVL(pac_parametros.f_parempresa_n(pcempres, 'LIQ_DESG_COMP'),
                                       0),
                                   1, s.ccompani,
                                   0))   -- Bug 26964/146968 - 19/06/2013 - AMC
         GROUP BY cempres, cagente, sprod, compania;   -- Bug 26964/146968 - 19/06/2013 - AMC

      -- fin Bug 26022 - APD - 08/02/2013
      -- 43.0 - 08/01/2014 - MMM - 0029471: LCOL_C004-LCOL: Ajuste en el proceso de liquidacion de Convenio Liberty Web - Inicio
      --CURSOR c_saldofin_previo
      CURSOR c_saldofin_previo(vconcepto NUMBER) IS
         -- 43.0 - 08/01/2014 - MMM - 0029471: LCOL_C004-LCOL: Ajuste en el proceso de liquidacion de Convenio Liberty Web - Fin
         SELECT   cagente, SUM(suma) suma, sproduc,
                  ccompani   -- Bug 26964/146968 - 19/06/2013 - AMC
             FROM (SELECT   cagente, SUM(DECODE(cdebhab, 1, iimport, -iimport)) suma, sproduc,
                            ccompani   -- Bug 26964/146968 - 19/06/2013 - AMC
                       FROM ctactes_previo
                      WHERE cempres = pcempres
                        AND sproces = psproces
                        AND cagente = NVL(pcagente, cagente)
                        -- 43.0 - 08/01/2014 - MMM - 0029471: LCOL_C004-LCOL: Ajuste en el proceso de liquidacion de Convenio Liberty Web - Inicio
                        AND cconcta = vconcepto
                   -- 43.0 - 08/01/2014 - MMM - 0029471: LCOL_C004-LCOL: Ajuste en el proceso de liquidacion de Convenio Liberty Web - Fin
                   GROUP BY cagente, sproduc, ccompani   -- Bug 26964/146968 - 19/06/2013 - AMC
                   UNION ALL
                   SELECT   cagente, SUM(DECODE(cdebhab, 1, iimport, -iimport)) suma, sproduc,
                            ccompani   -- Bug 26964/146968 - 19/06/2013 - AMC
                       FROM ctactes
                      WHERE cempres = pcempres
                        AND cestado = 1
                        AND cagente = NVL(pcagente, cagente)
                              -- bug 0035979 - 27/07/2015 - JMF
                        -- bug 035979 - 21/09/2015 - AFM
                        AND sproces IS NULL
                        --  AND(sproces IS NULL
                        --      OR pac_liquida.f_esautoliquidado(nrecibo, ffecmov) = 1)
                        AND fvalor <= pfecliq
                        -- 43.0 - 08/01/2014 - MMM - 0029471: LCOL_C004-LCOL: Ajuste en el proceso de liquidacion de Convenio Liberty Web - Inicio
                        -- Hacemos que los apuntes manuales solo se traten si hacemos la llamada para el concepto 99
                        AND cconcta = DECODE(vconcepto, 99, cconcta, -1)
                   -- 43.0 - 08/01/2014 - MMM - 0029471: LCOL_C004-LCOL: Ajuste en el proceso de liquidacion de Convenio Liberty Web - Fin
                   GROUP BY cagente, sproduc, ccompani   -- Bug 26964/146968 - 19/06/2013 - AMC
                   UNION ALL
                   -- 43.0 - 08/01/2014 - MMM - 0029471: LCOL_C004-LCOL: Ajuste en el proceso de liquidacion de Convenio Liberty Web - Inicio
                   -- Buscamos los apuntes que estén relacionados con el concepto que llega como parámetro
                   SELECT   cagente, SUM(DECODE(cdebhab, 1, iimport, -iimport)) suma, sproduc,
                            ccompani   -- Bug 26964/146968 - 19/06/2013 - AMC
                       FROM ctactes_previo
                      WHERE (cempres, sproces, cagente, nnumlin_depen) IN(
                               SELECT cempres, sproces, cagente, nnumlin
                                 FROM ctactes_previo
                                WHERE cempres = pcempres
                                  AND sproces = psproces
                                  AND cagente = NVL(pcagente, cagente)
                                  AND cconcta = vconcepto)
                   -- 43.0 - 08/01/2014 - MMM - 0029471: LCOL_C004-LCOL: Ajuste en el proceso de liquidacion de Convenio Liberty Web - Fin
                   GROUP BY cagente, sproduc, ccompani   -- Bug 26964/146968 - 19/06/2013 - AMC
                                                      )
         GROUP BY cagente, sproduc, ccompani;   -- Bug 26964/146968 - 19/06/2013 - AMC

      -- 43.0 - 08/01/2014 - MMM - 0029471: LCOL_C004-LCOL: Ajuste en el proceso de liquidacion de Convenio Liberty Web - Inicio
      --CURSOR c_saldofin
      CURSOR c_saldofin(vconcepto NUMBER) IS
         -- 43.0 - 08/01/2014 - MMM - 0029471: LCOL_C004-LCOL: Ajuste en el proceso de liquidacion de Convenio Liberty Web - Fin
         SELECT   cagente, SUM(suma) suma, sproduc,
                  ccompani   -- Bug 26964/146968 - 19/06/2013 - AMC
             FROM (SELECT   cagente, SUM(DECODE(cdebhab, 1, iimport, -iimport)) suma, sproduc,
                            ccompani   -- Bug 26964/146968 - 19/06/2013 - AMC
                       FROM ctactes
                      WHERE cempres = pcempres
                        AND sproces = psproces
                        AND cagente = NVL(pcagente, cagente)
                        -- 43.0 - 08/01/2014 - MMM - 0029471: LCOL_C004-LCOL: Ajuste en el proceso de liquidacion de Convenio Liberty Web - Inicio
                        AND cconcta = vconcepto
                   -- 43.0 - 08/01/2014 - MMM - 0029471: LCOL_C004-LCOL: Ajuste en el proceso de liquidacion de Convenio Liberty Web - Fin
                   GROUP BY cagente, sproduc, ccompani   -- Bug 26964/146968 - 19/06/2013 - AMC
                   UNION ALL
                   SELECT   cagente, SUM(DECODE(cdebhab, 1, iimport, -iimport)) suma, sproduc,
                            ccompani   -- Bug 26964/146968 - 19/06/2013 - AMC
                       FROM ctactes
                      WHERE cempres = pcempres
                        AND cestado = 1
                        AND cagente = NVL(pcagente, cagente)
                              -- bug 0035979 - 27/07/2015 - JMF
                        -- bug 035979 - 21/09/2015 - AFM
                        AND sproces IS NULL
                        -- AND(sproces IS NULL
                        --     OR pac_liquida.f_esautoliquidado(nrecibo, ffecmov) = 1)
                        AND fvalor <= pfecliq
                        -- 43.0 - 08/01/2014 - MMM - 0029471: LCOL_C004-LCOL: Ajuste en el proceso de liquidacion de Convenio Liberty Web - Inicio
                        -- Hacemos que los apuntes manuales solo se traten si hacemos la llamada para el concepto 99
                        AND cconcta = DECODE(vconcepto, 99, cconcta, -1)
                   -- 43.0 - 08/01/2014 - MMM - 0029471: LCOL_C004-LCOL: Ajuste en el proceso de liquidacion de Convenio Liberty Web - Fin
                   GROUP BY cagente, sproduc, ccompani   -- Bug 26964/146968 - 19/06/2013 - AMC
                   UNION ALL
                   -- 43.0 - 08/01/2014 - MMM - 0029471: LCOL_C004-LCOL: Ajuste en el proceso de liquidacion de Convenio Liberty Web - Inicio
                   -- Buscamos los conceptos relacionados con el concepto que se pasa como parámetro
                   SELECT   cagente, SUM(DECODE(cdebhab, 1, iimport, -iimport)) suma, sproduc,
                            ccompani   -- Bug 26964/146968 - 19/06/2013 - AMC
                       FROM ctactes
                      WHERE (cempres, sproces, cagente, nnumlin_depen) IN(
                               SELECT cempres, sproces, cagente, nnumlin
                                 FROM ctactes
                                WHERE cempres = pcempres
                                  AND sproces = psproces
                                  AND cagente = NVL(pcagente, cagente)
                                  AND cconcta = vconcepto)
                   -- 43.0 - 08/01/2014 - MMM - 0029471: LCOL_C004-LCOL: Ajuste en el proceso de liquidacion de Convenio Liberty Web - Fin
                   GROUP BY cagente, sproduc, ccompani   -- Bug 26964/146968 - 19/06/2013 - AMC
                                                      )
         GROUP BY cagente, sproduc, ccompani;   -- Bug 26964/146968 - 19/06/2013 - AMC

      CURSOR c_pagocomision IS
         SELECT   cagente, SUM(suma) suma   --, cconcta  Bug 25988 comisiones Liberty Web
             FROM (SELECT   cagente, SUM(DECODE(cdebhab, 2, iimport, -iimport)) suma, cconcta
                       FROM ctactes
                      WHERE cempres = pcempres
                        AND sproces = psproces
                        AND cagente = NVL(pcagente, cagente)
                        AND cconcta IN(97, 98)   -- Bug 25988/145805 - 06/06/2013 - AMC
                   GROUP BY cagente, cconcta)
         GROUP BY cagente;   --, cconcta; Bug 25988 comisiones Liberty Web

      v_anex_desc    VARCHAR2(25);
   BEGIN
      v_pasexec := 1;
      -- Bug 0019154 - JMF - 02/08/2011
      n_prodext := NVL(pac_parametros.f_parempresa_n(pcempres, 'EMP_POL_EXTERNA'), 0);

      -- 24. 0024803 26/11/2012 - Inicio
      IF NVL(pac_parametros.f_parempresa_n(pcempres, 'MULTIMONEDA'), 0) = 1 THEN
         v_cmoncia := pac_parametros.f_parempresa_n(pcempres, 'MONEDAEMP');
      END IF;

      v_pasexec := 2;

      -- 24. 0024803 26/11/2012 - Fin
      IF pmodo = 1 THEN   -- Previo
         FOR reg IN c_liqmovrec_previo LOOP
            -- positivo al debe
            vcdebhab := 1;

            -- negativo al haber
            IF reg.suma < 0 THEN
               vcdebhab := 2;
            END IF;

            SELECT NVL(MAX(nnumlin), 0) + 1
              INTO v_nnumlin
              FROM ctactes_previo
             WHERE cagente = reg.cagente;

            -- Apuntes en CTACTES en el idioma del agente
            BEGIN
               SELECT cidioma
                 INTO vidioma
                 FROM agentes a, per_detper p
                WHERE a.sperson = p.sperson
                  AND a.cagente = reg.cagente
                  AND p.cagente = ff_agente_cpervisio(pcagentevision, f_sysdate, pcempres);
            EXCEPTION
               WHEN OTHERS THEN
                  vidioma := pcidioma;   --Si el agente no tiene idioma le asignamos idioma por parámetro
            END;

            verror :=
               f_insert_cta
                  (1, reg.cagente, v_nnumlin, vcdebhab, 99, 0, NULL, f_sysdate,

                   -- 43.0 - 08/01/2014 - MMM - 0029471: LCOL_C004-LCOL: Ajuste en el proceso de liquidacion de Convenio Liberty Web - Inicio
                   --NVL((ABS(reg.suma) + f_round(ABS(reg.iconvoleducto), v_cmoncia)), 0),
                   NVL(ABS(reg.suma), 0),   -- Bug 25988/145805 - 06/06/2013 - AMC  -- BUG 28371/0157125 - FAL - 29/10/2013
                                                          -- Bug  29471 20/12/2013 se elimina imp oleoducto + f_round(ABS(reg.iconvoleducto)
                   -- 43.0 - 08/01/2014 - MMM - 0029471: LCOL_C004-LCOL: Ajuste en el proceso de liquidacion de Convenio Liberty Web - Fin
                   f_axis_literales(9002059, vidioma), 1, pcempres, NULL, NULL, NULL, pfecliq,
                   psproces, NULL, NULL, reg.sprod,
                   reg.compania   -- Bug 26964/146968 - 19/06/2013 - AMC
                               );

            IF verror <> 0 THEN
               RETURN verror;
            END IF;

            verror :=
               f_crea_conceptos_impuestos
                                    (1, reg.cagente, v_nnumlin, vcdebhab, 99, 0, NULL,
                                     f_sysdate,
                                     -- 43.0 - 08/01/2014 - MMM - 0029471: LCOL_C004-LCOL: Ajuste en el proceso de liquidacion de Convenio Liberty Web - Inicio
                                     --NVL((ABS(reg.suma) + f_round(ABS(reg.iconvoleducto), v_cmoncia)), 0),
                                     NVL(ABS(reg.suma), 0),   -- Bug 25988/145805 - 06/06/2013 - AMC
                                                                         -- Bug 29471 20/12/2013 se elimina imp oleoducto + f_round(ABS(reg.iconvoleducto)
                                     -- 43.0 - 08/01/2014 - MMM - 0029471: LCOL_C004-LCOL: Ajuste en el proceso de liquidacion de Convenio Liberty Web - Fin
                                     f_axis_literales(9002059, vidioma), 1, pcempres, NULL,
                                     NULL, NULL, pfecliq, psproces, NULL, reg.sprod,
                                     reg.compania   -- Bug 26964/146968 - 19/06/2013 - AMC
                                                 );

            IF verror <> 0 THEN
               RETURN verror;
            END IF;

            --Bug.: 22193 - ICV - 09/05/2012
            --En caso de necesitar desglosar los importes de los recibos de comisión, para ahorro, se crea un nuevo
            --concepto al debe y al haber para tener dicho importe desglosado
            IF NVL(pac_parametros.f_parempresa_n(pcempres, 'LIQ_DESG_AHO'), 0) = 1 THEN
               IF NVL(ABS(reg.suma_aho), 0) <> 0 THEN
                  SELECT NVL(MAX(nnumlin), 0) + 1
                    INTO v_nnumlin
                    FROM ctactes_previo
                   WHERE cagente = reg.cagente;

                  verror :=
                     f_insert_cta
                        (1, reg.cagente, v_nnumlin, 1, 58, 0, NULL, f_sysdate, reg.suma_aho,
                         f_axis_literales(9002059, vidioma),   --Bug 30026  ABS( se elimina el valor abs. para insertar y
                                                               -- contabilizar correctamente, el signo nos dará la columna D/H
                         1, pcempres, NULL, NULL, NULL, pfecliq, psproces, NULL, NULL,
                         reg.sprod, reg.compania   -- Bug 26964/146968 - 19/06/2013 - AMC
                                                );

                  IF verror <> 0 THEN
                     RETURN verror;
                  END IF;

                  v_nnumlin := v_nnumlin + 1;
                  verror :=
                     f_insert_cta
                        (1, reg.cagente, v_nnumlin, 2, 58, 0, NULL, f_sysdate, reg.suma_aho,
                         f_axis_literales(9002059, vidioma),   --Bug 30026  ABS( se elimina el valor abs. para insertar y
                                                               -- contabilizar correctamente, el signo nos dará la columna D/H
                         1, pcempres, NULL, NULL, NULL, pfecliq, psproces, NULL, NULL,
                         reg.sprod, reg.compania   -- Bug 26964/146968 - 19/06/2013 - AMC
                                                );

                  IF verror <> 0 THEN
                     RETURN verror;
                  END IF;
               END IF;
            END IF;

            --End Bug.: 22193

            -- 43.0 - 08/01/2014 - MMM - 0029471: LCOL_C004-LCOL: Ajuste en el proceso de liquidacion de Convenio Liberty Web - Inicio
            v_sobrecomis := NVL(pac_parametros.f_parempresa_n(pcempres, 'SOBRECOMISION_EMISIO'),
                                0);

            IF NVL(reg.iconvoleducto, 0) <> 0
               AND v_sobrecomis = 1 THEN
               --Bug 29741 Se ha de crear el concepto Liberty Web base, y cálculo de sus respectivos impuestos
               SELECT NVL(MAX(nnumlin), 0) + 1
                 INTO v_nnumlin
                 FROM ctactes_previo
                WHERE cagente = reg.cagente;

               verror := f_insert_cta(1, reg.cagente, v_nnumlin, vcdebhab, 96, 0, NULL,
                                      f_sysdate,
                                      NVL(f_round(ABS(reg.iconvoleducto), v_cmoncia), 0),
                                      f_axis_literales(9002059, vidioma), 1, pcempres, NULL,
                                      NULL, NULL, pfecliq, psproces, NULL, NULL, reg.sprod,
                                      reg.compania);

               IF verror <> 0 THEN
                  RETURN verror;
               END IF;

               verror := f_crea_conceptos_impuestos(1, reg.cagente, v_nnumlin, vcdebhab, 96, 0,
                                                    NULL, f_sysdate,
                                                    NVL(f_round(ABS(reg.iconvoleducto),
                                                                v_cmoncia),
                                                        0),
                                                    f_axis_literales(9002059, vidioma), 1,
                                                    pcempres, NULL, NULL, NULL, pfecliq,
                                                    psproces, NULL, reg.sprod, reg.compania);

               IF verror <> 0 THEN
                  RETURN verror;
               END IF;
            -- 43.0 - 08/01/2014 - MMM - 0029471: LCOL_C004-LCOL: Ajuste en el proceso de liquidacion de Convenio Liberty Web - Inicio
            /*IF NVL(pac_parametros.f_parempresa_n(pcempres, 'CTAPROD'), 0) = 1 THEN
               v_anex_desc := ' - (' || NVL(f_cnvproductos_ext(reg.sprod), reg.sprod)
                              || ')';
            END IF;

            -- Bug 25988/145805 - 06/06/2013 - AMC
            SELECT NVL(MAX(nnumlin), 0) + 1
              INTO v_nnumlin
              FROM ctactes_previo
             WHERE cagente = reg.cagente;

            INSERT INTO ctactes_previo
                        (cagente, nnumlin, cdebhab, cconcta, cestado, ndocume, ffecmov,
                         iimport,
                         tdescrip, cmanual, cempres,
                         nrecibo, nsinies, sseguro, sproces, fvalor, sproduc)
                 VALUES (reg.cagente, v_nnumlin, vcdebhab, 97, 0, NULL, f_sysdate,
                         f_round(ABS(reg.iconvoleducto), v_cmoncia),
                         f_axis_literales(9905677, vidioma) || v_anex_desc, 1, pcempres,
                         NULL, NULL, NULL, psproces, pfecliq, reg.sprod);*/
            -- 43.0 - 08/01/2014 - MMM - 0029471: LCOL_C004-LCOL: Ajuste en el proceso de liquidacion de Convenio Liberty Web - Fin

            -- Fi Bug 25988/145805 - 06/06/2013 - AMC
            END IF;
         END LOOP;

         -- 43.0 - 08/01/2014 - MMM - 0029471: LCOL_C004-LCOL: Ajuste en el proceso de liquidacion de Convenio Liberty Web - Fin
         IF psmovagr IS NULL THEN   -- 21. 0022753  (+)
            -- Si psmovagr viene informado no ha de hacer el apunte de pago 98, ni pagos.
            -- y SOLO se liquidan los recibos de ese movimiento.
            v_pasexec := 3;

            -- 43.0 - 08/01/2014 - MMM - 0029471: LCOL_C004-LCOL: Ajuste en el proceso de liquidacion de Convenio Liberty Web - Inicio
            FOR reg IN c_saldofin_previo(99) LOOP   --Los apuntes de Comisiones básicas  incluidos los apuntes manuales   Bug 29471   MCA
                --es posa al reves ja que per poder tancar hem de tenir el valor que doni 0 per tal de quadra
               -- positivo al debe
               vcdebhab := 1;

               -- negativo al haber
               IF reg.suma < 0 THEN
                  vcdebhab := 2;

                  -- CPM 26478
                  IF NVL(pac_parametros.f_parempresa_n(pcempres, 'LIQ_NEGATIVO'), 0) = 1 THEN
                     vimporte := 0;
                  ELSE
                     vimporte := ABS(reg.suma);
                  END IF;
               ELSE
                  vimporte := 0;
               END IF;

               SELECT NVL(MAX(nnumlin), 0) + 1
                 INTO v_nnumlin
                 FROM ctactes_previo
                WHERE cagente = reg.cagente;

               -- Apuntes en CTACTES en el idioma del agente
               BEGIN
                  SELECT cidioma
                    INTO vidioma
                    FROM agentes a, per_detper p
                   WHERE a.sperson = p.sperson
                     AND a.cagente = reg.cagente
                     AND p.cagente = ff_agente_cpervisio(pcagentevision, f_sysdate, pcempres);
               EXCEPTION
                  WHEN OTHERS THEN
                     vidioma := pcidioma;   --Si el agente no tiene idioma le asignamos idioma por parámetro
               END;

               IF NVL(pac_parametros.f_parempresa_n(pcempres, 'CTAPROD'), 0) = 1 THEN
                  v_anex_desc := ' - (' || NVL(f_cnvproductos_ext(reg.sproduc), reg.sproduc)
                                 || ')';
               END IF;

               IF NVL(pac_parametros.f_parempresa_n(pcempres, 'LIQ_DESG_COMP'), 0) = 1 THEN
                  v_anex_desc := v_anex_desc || ' - (' || reg.ccompani || ')';
               END IF;

               --Bug.: 21449 - 01/03/2012 - ICV
               --IF reg.suma > 0 THEN   --Sólo creamos el apunte de pago liquidación cuando debemos al agente
               INSERT INTO ctactes_previo
                           (cagente, nnumlin, cdebhab, cconcta, cestado, ndocume,
                            ffecmov, iimport,
                            tdescrip, cmanual, cempres,
                            nrecibo, nsinies, sseguro, sproces, fvalor, sproduc)
                    VALUES (reg.cagente, v_nnumlin, DECODE(vcdebhab, 1, 2, 1), 98, 0, NULL,
                            f_sysdate,
                                      -- f_round(ABS(reg.suma)), -- 24. 0024803 26/11/2012 (-)
                                      f_round(ABS(reg.suma), v_cmoncia),   -- 24. 0024803 26/11/2012 (+)
                            f_axis_literales(9002265, vidioma) || v_anex_desc, 1, pcempres,
                            NULL, NULL, NULL, psproces, pfecliq, reg.sproduc);   -- Apunte de Pago liquidación

               --Se aumenta el nºlinea
               v_nnumlin := v_nnumlin + 1;

               --END IF;
               IF reg.suma > 0
                  OR NVL(pac_parametros.f_parempresa_n(pcempres, 'LIQ_NEGATIVO'), 0) = 1 THEN
                  INSERT INTO ctactes_previo
                              (cagente, nnumlin, cdebhab, cconcta, cestado, ndocume, ffecmov,
                               iimport,
                               tdescrip, cmanual, cempres, nrecibo, nsinies,
                               sseguro, sproces, fvalor, sproduc)
                       VALUES (reg.cagente, v_nnumlin, vcdebhab, 0, 0, NULL, f_sysdate,
                               -- f_round(vimporte),  -- 24. 0024803 26/11/2012 (-)
                               f_round(vimporte, v_cmoncia),   -- 24. 0024803 26/11/2012 (+)
                               f_axis_literales(9002057, vidioma), 1, pcempres, NULL, NULL,
                               NULL, psproces, pfecliq, 0   -- Apunte de Saldo final
                                                         );
               ELSE
                  --Si es negativo convertimos los apuntes 98 a apuntes de saldo del agente
                  UPDATE ctactes_previo
                     SET cconcta = 0,
                         cdebhab = DECODE(cdebhab, 2, 1, 2),
                         sproces = NULL,
                         cestado = 1
                   WHERE cconcta = 98
                     AND cagente = reg.cagente
                     AND cempres = pcempres
                     AND sproces = psproces;
               END IF;
            --  fin 14344
            END LOOP;

            -- Miramos si la empresa tiene sobrecomisión
            v_sobrecomis := NVL(pac_parametros.f_parempresa_n(pcempres, 'SOBRECOMISION_EMISIO'),
                                0);

            IF v_sobrecomis = 1 THEN
               FOR reg IN c_saldofin_previo(96) LOOP   --Los apuntes de Comisiones Liberty Web Bug 29471   MCA
                   --es posa al reves ja que per poder tancar hem de tenir el valor que doni 0 per tal de quadra
                  -- positivo al debe
                  vcdebhab := 1;

                  -- negativo al haber
                  IF reg.suma < 0 THEN
                     vcdebhab := 2;

                     -- CPM 26478
                     IF NVL(pac_parametros.f_parempresa_n(pcempres, 'LIQ_NEGATIVO'), 0) = 1 THEN
                        vimporte := 0;
                     ELSE
                        vimporte := ABS(reg.suma);
                     END IF;
                  ELSE
                     vimporte := 0;
                  END IF;

                  SELECT NVL(MAX(nnumlin), 0) + 1
                    INTO v_nnumlin
                    FROM ctactes_previo
                   WHERE cagente = reg.cagente;

                  -- Apuntes en CTACTES en el idioma del agente
                  BEGIN
                     SELECT cidioma
                       INTO vidioma
                       FROM agentes a, per_detper p
                      WHERE a.sperson = p.sperson
                        AND a.cagente = reg.cagente
                        AND p.cagente = ff_agente_cpervisio(pcagentevision, f_sysdate,
                                                            pcempres);
                  EXCEPTION
                     WHEN OTHERS THEN
                        vidioma := pcidioma;   --Si el agente no tiene idioma le asignamos idioma por parámetro
                  END;

                  IF NVL(pac_parametros.f_parempresa_n(pcempres, 'CTAPROD'), 0) = 1 THEN
                     v_anex_desc := ' - ('
                                    || NVL(f_cnvproductos_ext(reg.sproduc), reg.sproduc)
                                    || ')';
                  END IF;

                  IF NVL(pac_parametros.f_parempresa_n(pcempres, 'LIQ_DESG_COMP'), 0) = 1 THEN
                     v_anex_desc := v_anex_desc || ' - (' || reg.ccompani || ')';
                  END IF;

                  --Bug.: 21449 - 01/03/2012 - ICV
                  --IF reg.suma > 0 THEN   --Sólo creamos el apunte de pago liquidación cuando debemos al agente
                  INSERT INTO ctactes_previo
                              (cagente, nnumlin, cdebhab, cconcta, cestado, ndocume,
                               ffecmov, iimport,
                               tdescrip, cmanual, cempres,
                               nrecibo, nsinies, sseguro, sproces, fvalor, sproduc)
                       VALUES (reg.cagente, v_nnumlin, DECODE(vcdebhab, 1, 2, 1), 97, 0, NULL,
                               f_sysdate,
                                         -- f_round(ABS(reg.suma)), -- 24. 0024803 26/11/2012 (-)
                                         f_round(ABS(reg.suma), v_cmoncia),   -- 24. 0024803 26/11/2012 (+)
                               f_axis_literales(9002265, vidioma) || v_anex_desc, 1, pcempres,
                               NULL, NULL, NULL, psproces, pfecliq, reg.sproduc);   -- Apunte de Pago liquidación

                  --Se aumenta el nºlinea
                  v_nnumlin := v_nnumlin + 1;

                  --END IF;
                  IF reg.suma > 0   ----??????
                     OR NVL(pac_parametros.f_parempresa_n(pcempres, 'LIQ_NEGATIVO'), 0) = 1 THEN
                     INSERT INTO ctactes_previo
                                 (cagente, nnumlin, cdebhab, cconcta, cestado, ndocume,
                                  ffecmov, iimport,
                                  tdescrip, cmanual, cempres, nrecibo,
                                  nsinies, sseguro, sproces, fvalor, sproduc)
                          VALUES (reg.cagente, v_nnumlin, vcdebhab, 0, 0, NULL,
                                  f_sysdate,
                                            -- f_round(vimporte),  -- 24. 0024803 26/11/2012 (-)
                                            f_round(vimporte, v_cmoncia),   -- 24. 0024803 26/11/2012 (+)
                                  f_axis_literales(9002057, vidioma), 1, pcempres, NULL,
                                  NULL, NULL, psproces, pfecliq, 0   -- Apunte de Saldo final
                                                                  );
                  ELSE
                     --Si es negativo convertimos los apuntes 97 a apuntes de saldo del agente
                     UPDATE ctactes_previo
                        SET cconcta = 0,
                            cdebhab = DECODE(cdebhab, 2, 1, 2),
                            sproces = NULL,
                            cestado = 1
                      WHERE cconcta = 97
                        AND cagente = reg.cagente
                        AND cempres = pcempres
                        AND sproces = psproces;
                  END IF;
               --  fin 14344
               END LOOP;   --Fin bug 29471  MCA
            END IF;   -- Del IF que mira si la empresa tiene sobrecomisión a contabilizar
         -- 43.0 - 08/01/2014 - MMM - 0029471: LCOL_C004-LCOL: Ajuste en el proceso de liquidacion de Convenio Liberty Web - Fin
         END IF;   -- 21. 0022753  (+)
      ELSE   --Liquidación Real
         v_pasexec := 4;

         FOR reg IN c_liqmovrec LOOP
            -- positivo al debe
            vcdebhab := 1;

            -- negativo al haber
            IF reg.suma < 0 THEN
               vcdebhab := 2;
            END IF;

            SELECT NVL(MAX(nnumlin), 0) + 1
              INTO v_nnumlin
              FROM ctactes
             WHERE cagente = reg.cagente;

            -- Apuntes en CTACTES en el idioma del agente
            BEGIN
               SELECT cidioma
                 INTO vidioma
                 FROM agentes a, per_detper p
                WHERE a.sperson = p.sperson
                  AND a.cagente = reg.cagente
                  AND p.cagente = ff_agente_cpervisio(pcagentevision, f_sysdate, pcempres);
            EXCEPTION
               WHEN OTHERS THEN
                  vidioma := pcidioma;   --Si el agente no tiene idioma le asignamos idioma por parámetro
            END;

            verror := f_insert_cta(2, reg.cagente, v_nnumlin, vcdebhab, 99, 0, NULL, f_sysdate,

                                   -- 43.0 - 08/01/2014 - MMM - 0029471: LCOL_C004-LCOL: Ajuste en el proceso de liquidacion de Convenio Liberty Web - Inicio
                                   --(ABS(reg.suma) + f_round(ABS(reg.iconvoleducto), v_cmoncia)),   -- Bug 25988/145805 - 06/06/2013 - AMC
                                   ABS(reg.suma),
                                   -- 43.0 - 08/01/2014 - MMM - 0029471: LCOL_C004-LCOL: Ajuste en el proceso de liquidacion de Convenio Liberty Web - Fin
                                   f_axis_literales(9002059, vidioma), 1, pcempres, NULL, NULL,
                                   NULL, pfecliq, psproces, NULL, NULL, reg.sprod,
                                   reg.compania   -- Bug 26964/146968 - 19/06/2013 - AMC
                                               );

            IF verror <> 0 THEN
               RETURN verror;
            END IF;

            verror :=
               f_crea_conceptos_impuestos(2, reg.cagente, v_nnumlin, vcdebhab, 99, 0, NULL,
                                          f_sysdate,
                                          -- 43.0 - 08/01/2014 - MMM - 0029471: LCOL_C004-LCOL: Ajuste en el proceso de liquidacion de Convenio Liberty Web - Inicio
                                          --(ABS(reg.suma) + f_round(ABS(reg.iconvoleducto), v_cmoncia))
                                          ABS(reg.suma),   -- Bug 25988/145805 - 06/06/2013 - AMC
                                          -- 43.0 - 08/01/2014 - MMM - 0029471: LCOL_C004-LCOL: Ajuste en el proceso de liquidacion de Convenio Liberty Web - Fin
                                          f_axis_literales(9002059, vidioma), 1, pcempres,
                                          NULL, NULL, NULL, pfecliq, psproces, NULL, reg.sprod,
                                          reg.compania   -- Bug 26964/146968 - 19/06/2013 - AMC
                                                      );

            IF verror <> 0 THEN
               RETURN verror;
            END IF;

             --Bug.: 22193 - ICV - 09/05/2012
            --En caso de necesitar desglosar los importes de los recibos de comisión, para ahorro, se crea un nuevo
            --concepto al debe y al haber para tener dicho importe desglosado
            IF NVL(pac_parametros.f_parempresa_n(pcempres, 'LIQ_DESG_AHO'), 0) = 1 THEN
               IF NVL(ABS(reg.suma_aho), 0) <> 0 THEN
                  SELECT NVL(MAX(nnumlin), 0) + 1
                    INTO v_nnumlin
                    FROM ctactes
                   WHERE cagente = reg.cagente;

                  verror :=
                     f_insert_cta
                        (2, reg.cagente, v_nnumlin, 1, 58, 0, NULL, f_sysdate, reg.suma_aho,
                         f_axis_literales(9002059, vidioma),   --Bug 30026  ABS( se elimina el valor abs. para insertar y
                                                               -- contabilizar correctamente, el signo nos dará la columna D/H
                         1, pcempres, NULL, NULL, NULL, pfecliq, psproces, NULL, NULL,
                         reg.sprod, reg.compania   -- Bug 26964/146968 - 19/06/2013 - AMC
                                                );

                  IF verror <> 0 THEN
                     RETURN verror;
                  END IF;

                  v_nnumlin := v_nnumlin + 1;
                  verror :=
                     f_insert_cta
                        (2, reg.cagente, v_nnumlin, 2, 58, 0, NULL, f_sysdate, reg.suma_aho,
                         f_axis_literales(9002059, vidioma),   --Bug 30026  ABS( se elimina el valor abs. para insertar y
                                                               -- contabilizar correctamente, el signo nos dará la columna D/H
                         1, pcempres, NULL, NULL, NULL, pfecliq, psproces, NULL, NULL,
                         reg.sprod, reg.compania   -- Bug 26964/146968 - 19/06/2013 - AMC
                                                );

                  IF verror <> 0 THEN
                     RETURN verror;
                  END IF;
               END IF;
            END IF;

            --End Bug.: 22193
            -- Miramos si la empresa tiene sobrecomisión
            v_sobrecomis := NVL(pac_parametros.f_parempresa_n(pcempres, 'SOBRECOMISION_EMISIO'),
                                0);

            IF NVL(reg.iconvoleducto, 0) <> 0
               AND v_sobrecomis = 1 THEN
               SELECT NVL(MAX(nnumlin), 0) + 1
                 INTO v_nnumlin
                 FROM ctactes
                WHERE cagente = reg.cagente;

               --Bug 29741 Se ha de crear el concepto Liberty Web base, y cálculo de sus respectivos impuestos
               verror := f_insert_cta(2, reg.cagente, v_nnumlin, vcdebhab, 96, 0, NULL,
                                      f_sysdate,
                                      NVL(f_round(ABS(reg.iconvoleducto), v_cmoncia), 0),
                                      f_axis_literales(9002059, vidioma), 1, pcempres, NULL,
                                      NULL, NULL, pfecliq, psproces, NULL, NULL, reg.sprod,
                                      reg.compania);

               IF verror <> 0 THEN
                  RETURN verror;
               END IF;

               verror := f_crea_conceptos_impuestos(2, reg.cagente, v_nnumlin, vcdebhab, 96, 0,
                                                    NULL, f_sysdate,
                                                    NVL(f_round(ABS(reg.iconvoleducto),
                                                                v_cmoncia),
                                                        0),
                                                    f_axis_literales(9002059, vidioma), 1,
                                                    pcempres, NULL, NULL, NULL, pfecliq,
                                                    psproces, NULL, reg.sprod, reg.compania);

               IF verror <> 0 THEN
                  RETURN verror;
               END IF;
            /*IF NVL(pac_parametros.f_parempresa_n(pcempres, 'CTAPROD'), 0) = 1 THEN
                 v_anex_desc := ' - (' || NVL(f_cnvproductos_ext(reg.sprod), reg.sprod)
                                || ')';
              END IF;

              -- Bug 25988/145805 - 06/06/2013 - AMC
              SELECT NVL(MAX(nnumlin), 0) + 1
                INTO v_nnumlin
                FROM ctactes
               WHERE cagente = reg.cagente;

              INSERT INTO ctactes
                          (cagente, nnumlin, cdebhab, cconcta, cestado, ndocume,
                           ffecmov, iimport,
                           tdescrip, cmanual, cempres, nrecibo, nsinies, sseguro,
                           sproces, fvalor, sproduc,
                           ccompani   -- Bug 26964/146968 - 19/06/2013 - AMC
                                   )
                   VALUES (reg.cagente, v_nnumlin, DECODE(vcdebhab, 1, 2, 1), 97, 0, NULL,
                           f_sysdate, f_round(ABS(reg.iconvoleducto), v_cmoncia),
                           f_axis_literales(9905677, vidioma), 1, pcempres, NULL, NULL, NULL,
                           psproces, pfecliq, reg.sprod,
                           reg.compania   -- Bug 26964/146968 - 19/06/2013 - AMC
                                       );*/

            -- Fi Bug 25988/145805 - 06/06/2013 - AMC
            END IF;
         END LOOP;

         IF psmovagr IS NULL THEN   -- 21. 0022753
            -- Si psmovagr viene informado no ha de hacer el apunte de pago 98, ni pagos.
            v_pasexec := 5;

            -- 43.0 - 08/01/2014 - MMM - 0029471: LCOL_C004-LCOL: Ajuste en el proceso de liquidacion de Convenio Liberty Web - Inicio
            FOR reg IN c_saldofin(99) LOOP
               -- 43.0 - 08/01/2014 - MMM - 0029471: LCOL_C004-LCOL: Ajuste en el proceso de liquidacion de Convenio Liberty Web - Fin
                  --es posa al reves ja que per poder tancar hem de tenir el valor que doni 0 per tal de quadra
                  -- positivo al debe
               vcdebhab := 1;

               -- negativo al haber
               IF reg.suma < 0 THEN   --Nos debe el agente
                  vcdebhab := 2;

                  -- CPM 26478
                  IF NVL(pac_parametros.f_parempresa_n(pcempres, 'LIQ_NEGATIVO'), 0) = 1 THEN
                     vimporte := 0;
                  ELSE
                     vimporte := ABS(reg.suma);
                  END IF;
               ELSE
                  vimporte := 0;   --A 0 para compensar
               END IF;

               SELECT NVL(MAX(nnumlin), 0) + 1
                 INTO v_nnumlin
                 FROM ctactes
                WHERE cagente = reg.cagente;

               -- Apuntes en CTACTES en el idioma del agente
               BEGIN
                  SELECT cidioma
                    INTO vidioma
                    FROM agentes a, per_detper p
                   WHERE a.sperson = p.sperson
                     AND a.cagente = reg.cagente
                     AND p.cagente = ff_agente_cpervisio(pcagentevision, f_sysdate, pcempres);
               EXCEPTION
                  WHEN OTHERS THEN
                     vidioma := pcidioma;   --Si el agente no tiene idioma le asignamos idioma por parámetro
               END;

               IF NVL(pac_parametros.f_parempresa_n(pcempres, 'CTAPROD'), 0) = 1 THEN
                  v_anex_desc := ' - (' || NVL(f_cnvproductos_ext(reg.sproduc), reg.sproduc)
                                 || ')';
               END IF;

               IF NVL(pac_parametros.f_parempresa_n(pcempres, 'LIQ_DESG_COMP'), 0) = 1 THEN
                  v_anex_desc := v_anex_desc || ' - (' || reg.ccompani || ')';
               END IF;

               --Bug.: 21449 - 01/03/2012 - ICV   --Creamos el apunte siempre
               --IF reg.suma > 0 THEN   --Sólo creamos el apunte de pago liquidación cuando debemos al agente
               INSERT INTO ctactes
                           (cagente, nnumlin, cdebhab, cconcta, cestado, ndocume,
                            ffecmov, iimport,
                            tdescrip, cmanual, cempres,
                            nrecibo, nsinies, sseguro, sproces, fvalor, sproduc,
                            ccompani   -- Bug 26964/146968 - 19/06/2013 - AMC
                                    )
                    VALUES (reg.cagente, v_nnumlin, DECODE(vcdebhab, 1, 2, 1), 98, 0, NULL,
                            f_sysdate,
                                      -- f_round(ABS(reg.suma)), -- 24. 0024803 26/11/2012 (-)
                                      f_round(ABS(reg.suma), v_cmoncia),   -- 24. 0024803 26/11/2012 (+)
                            f_axis_literales(9002265, vidioma) || v_anex_desc, 1, pcempres,
                            NULL, NULL, NULL, psproces, pfecliq, reg.sproduc,
                            reg.ccompani   -- Bug 26964/146968 - 19/06/2013 - AMC
                                        );   -- Apunte de Pago liquidación

               v_nnumlin_pago := v_nnumlin;
               --Se aumenta el nºlinea
               v_nnumlin := v_nnumlin + 1;
               --END IF;

               --Se han de actualizar los apuntes manuales de la liquidación con el sproces correspondiente
               pac_liquida.p_apuntes_manuales(reg.cagente, pcempres, psproces, pfecliq);

               --Fi Bug.: 21449

               -- Bug 26964/146968 - 19/06/2013 - AMC
               IF (reg.suma >= 0
                   OR NVL(pac_parametros.f_parempresa_n(pcempres, 'LIQ_NEGATIVO'), 0) = 1)
                  AND NVL(pac_parametros.f_parempresa_n(pcempres, 'CTAPROD'), 0) = 0
                  AND NVL(pac_parametros.f_parempresa_n(pcempres, 'LIQ_DESG_COMP'), 0) = 0 THEN
                  -- Fi Bug 26964/146968 - 19/06/2013 - AMC

                  --Bug.: 21449 - 01/03/2012 - ICV
                  --Creamos el apunte de saldo a 0
                  INSERT INTO ctactes
                              (cagente, nnumlin, cdebhab, cconcta, cestado, ndocume, ffecmov,
                               iimport,
                               tdescrip, cmanual, cempres, nrecibo, nsinies,
                               sseguro, sproces, fvalor, sproduc,
                               ccompani   -- Bug 26964/146968 - 19/06/2013 - AMC
                                       )
                       VALUES (reg.cagente, v_nnumlin, vcdebhab, 0, 0, NULL, f_sysdate,
                               -- f_round(vimporte), -- 24. 0024803 26/11/2012 (-)
                               f_round(vimporte, v_cmoncia),   -- 24. 0024803 26/11/2012 (+)
                               f_axis_literales(9002057, vidioma), 1, pcempres, NULL, NULL,
                               NULL, psproces, pfecliq, 0,
                               0   -- Bug 26964/146968 - 19/06/2013 - AMC
                                );   --Unico para todos los productos

                  SELECT seqpago.NEXTVAL
                    INTO vpago
                    FROM DUAL;

                  BEGIN
                     --Se recupera la cuenta de abono del pago
                     SELECT ctipban, cbancar
                       INTO vctipban, vcbancar
                       FROM agentes
                      WHERE cagente = reg.cagente;
                  EXCEPTION
                     WHEN OTHERS THEN
                        vctipban := NULL;
                        vcbancar := NULL;
                  END;

                  IF NVL(pac_parametros.f_parempresa_n(pcempres, 'DIAS_RET_PAGOLIQ'), 0) <> 0 THEN
                     --RDD 04/02/2013 BUG 24813
                     BEGIN
                        SELECT COUNT(1)
                          INTO v_nrecpend
                          FROM recibos r, movrecibo m
                         WHERE r.cempres = pcempres
                           AND r.cagente = reg.cagente
                           AND m.nrecibo = r.nrecibo
                           AND m.cestrec = 0
                           AND m.fmovfin IS NULL
                           AND(f_sysdate - m.fmovini) >=
                                 NVL(pac_parametros.f_parempresa_n(pcempres,
                                                                   'DIAS_RET_PAGOLIQ'),
                                     0);
                     EXCEPTION
                        WHEN OTHERS THEN
                           v_nrecpend := 0;
                     END;
                  ELSE
                     v_nrecpend := 0;
                  END IF;

                  INSERT INTO pagoscomisiones
                              (spago, cusuario, falta, cempres, cagente, fliquida,
                               iimporte, nremesa, ftrans,
                               cestado, cforpag, ctipopag, ctipban, cbancar,
                               nnumlin)
                       VALUES (vpago, f_user, f_sysdate, pcempres, reg.cagente, pfecliq,
                               -- f_round(ABS(reg.suma)),  -- 24. 0024803 26/11/2012 (-)
                               f_round(ABS(reg.suma), v_cmoncia),   -- 24. 0024803 26/11/2012 (+)
                                                                 NULL, NULL,
                               DECODE(v_nrecpend, 0, 0, 2),   --rdd 04/02/2013 bug 24813 si hay recibos entonces estado 2, retenido,
                                                           2, vcdebhab, vctipban, vcbancar,
                               v_nnumlin_pago);

                  IF NVL(pac_parametros.f_parempresa_n(pcempres, 'CONTAB_ONLINE'), 0) = 1
                     AND pmodo <> 1
                     AND NVL(pac_parametros.f_parempresa_n(pcempres, 'GESTIONA_COBPAG'), 0) = 1
                     AND v_nrecpend = 0 THEN
                     verror := pac_user.f_get_terminal(pac_md_common.f_get_cxtusuario,
                                                       vterminal);
                     verror := pac_con.f_emision_pagorec(pcempres, 1, vtipopago, vpago, NULL,
                                                         vterminal, vemitido, psinterf,
                                                         perror, f_user, NULL, NULL, NULL, 1);

                     IF verror <> 0
                        OR TRIM(perror) IS NOT NULL THEN
                        IF verror = 0 THEN
                           verror := 9903116;   --151323;
                           RETURN verror;
                        END IF;

                        p_tab_error(f_sysdate, f_user, 'pac_liquida.f_set_resumen_ctactes', 1,
                                    'error no controlado', perror || ' ' || verror);
                     ELSE
                        UPDATE pagoscomisiones
                           SET cestado = 1
                         WHERE spago = vpago;
                     END IF;
                  END IF;
               -- fin 14344
               ELSIF reg.suma < 0
                     AND NVL(pac_parametros.f_parempresa_n(pcempres, 'CTAPROD'), 0) = 0 THEN
                  UPDATE ctactes
                     SET cconcta = 0,
                         cdebhab = DECODE(cdebhab, 2, 1, 2),
                         sproces = NULL,
                         cestado = 1
                   WHERE cconcta IN(98)
                     AND cagente = reg.cagente
                     AND cempres = pcempres
                     AND sproces = psproces;
               END IF;
            END LOOP;

            -- 43.0 - 08/01/2014 - MMM - 0029471: LCOL_C004-LCOL: Ajuste en el proceso de liquidacion de Convenio Liberty Web - Inicio
            v_sobrecomis := NVL(pac_parametros.f_parempresa_n(pcempres, 'SOBRECOMISION_EMISIO'),
                                0);

            IF v_sobrecomis = 1 THEN
               FOR reg IN c_saldofin(96) LOOP
                  --es posa al reves ja que per poder tancar hem de tenir el valor que doni 0 per tal de quadra
                  -- positivo al debe
                  vcdebhab := 1;

                  -- negativo al haber
                  IF reg.suma < 0 THEN   --Nos debe el agente
                     vcdebhab := 2;

                     -- CPM 26478
                     IF NVL(pac_parametros.f_parempresa_n(pcempres, 'LIQ_NEGATIVO'), 0) = 1 THEN
                        vimporte := 0;
                     ELSE
                        vimporte := ABS(reg.suma);
                     END IF;
                  ELSE
                     vimporte := 0;   --A 0 para compensar
                  END IF;

                  SELECT NVL(MAX(nnumlin), 0) + 1
                    INTO v_nnumlin
                    FROM ctactes
                   WHERE cagente = reg.cagente;

                  -- Apuntes en CTACTES en el idioma del agente
                  BEGIN
                     SELECT cidioma
                       INTO vidioma
                       FROM agentes a, per_detper p
                      WHERE a.sperson = p.sperson
                        AND a.cagente = reg.cagente
                        AND p.cagente = ff_agente_cpervisio(pcagentevision, f_sysdate,
                                                            pcempres);
                  EXCEPTION
                     WHEN OTHERS THEN
                        vidioma := pcidioma;   --Si el agente no tiene idioma le asignamos idioma por parámetro
                  END;

                  IF NVL(pac_parametros.f_parempresa_n(pcempres, 'CTAPROD'), 0) = 1 THEN
                     v_anex_desc := ' - ('
                                    || NVL(f_cnvproductos_ext(reg.sproduc), reg.sproduc)
                                    || ')';
                  END IF;

                  IF NVL(pac_parametros.f_parempresa_n(pcempres, 'LIQ_DESG_COMP'), 0) = 1 THEN
                     v_anex_desc := v_anex_desc || ' - (' || reg.ccompani || ')';
                  END IF;

                  --Bug.: 21449 - 01/03/2012 - ICV   --Creamos el apunte siempre
                  --IF reg.suma > 0 THEN   --Sólo creamos el apunte de pago liquidación cuando debemos al agente
                  INSERT INTO ctactes
                              (cagente, nnumlin, cdebhab, cconcta, cestado, ndocume,
                               ffecmov, iimport,
                               tdescrip, cmanual, cempres,
                               nrecibo, nsinies, sseguro, sproces, fvalor, sproduc,
                               ccompani   -- Bug 26964/146968 - 19/06/2013 - AMC
                                       )
                       VALUES (reg.cagente, v_nnumlin, DECODE(vcdebhab, 1, 2, 1), 97, 0, NULL,
                               f_sysdate,
                                         -- f_round(ABS(reg.suma)), -- 24. 0024803 26/11/2012 (-)
                                         f_round(ABS(reg.suma), v_cmoncia),   -- 24. 0024803 26/11/2012 (+)
                               f_axis_literales(9002265, vidioma) || v_anex_desc, 1, pcempres,
                               NULL, NULL, NULL, psproces, pfecliq, reg.sproduc,
                               reg.ccompani   -- Bug 26964/146968 - 19/06/2013 - AMC
                                           );   -- Apunte de Pago liquidación

                  v_nnumlin_pago := v_nnumlin;
                  --Se aumenta el nºlinea
                  v_nnumlin := v_nnumlin + 1;

                  --END IF;

                  -- 43.0 - 08/01/2014 - MMM - 0029471: LCOL_C004-LCOL: Ajuste en el proceso de liquidacion de Convenio Liberty Web - Inicio
                  -- La parte de los apuntes manuales la tratamos en la comisión "normal" - 99
                  --Se han de actualizar los apuntes manuales de la liquidación con el sproces correspondiente
                  --pac_liquida.p_apuntes_manuales(reg.cagente, pcempres, psproces, pfecliq);
                  -- 43.0 - 08/01/2014 - MMM - 0029471: LCOL_C004-LCOL: Ajuste en el proceso de liquidacion de Convenio Liberty Web - Fin

                  --Fi Bug.: 21449

                  -- Bug 26964/146968 - 19/06/2013 - AMC
                  IF (reg.suma >= 0
                      OR NVL(pac_parametros.f_parempresa_n(pcempres, 'LIQ_NEGATIVO'), 0) = 1)
                     AND NVL(pac_parametros.f_parempresa_n(pcempres, 'CTAPROD'), 0) = 0
                     AND NVL(pac_parametros.f_parempresa_n(pcempres, 'LIQ_DESG_COMP'), 0) = 0 THEN
                     -- Fi Bug 26964/146968 - 19/06/2013 - AMC

                     --Bug.: 21449 - 01/03/2012 - ICV
                     --Creamos el apunte de saldo a 0
                     INSERT INTO ctactes
                                 (cagente, nnumlin, cdebhab, cconcta, cestado, ndocume,
                                  ffecmov, iimport,
                                  tdescrip, cmanual, cempres, nrecibo,
                                  nsinies, sseguro, sproces, fvalor, sproduc,
                                  ccompani   -- Bug 26964/146968 - 19/06/2013 - AMC
                                          )
                          VALUES (reg.cagente, v_nnumlin, vcdebhab, 0, 0, NULL,
                                  f_sysdate,
                                            -- f_round(vimporte), -- 24. 0024803 26/11/2012 (-)
                                            f_round(vimporte, v_cmoncia),   -- 24. 0024803 26/11/2012 (+)
                                  f_axis_literales(9002057, vidioma), 1, pcempres, NULL,
                                  NULL, NULL, psproces, pfecliq, 0,
                                  0   -- Bug 26964/146968 - 19/06/2013 - AMC
                                   );   --Unico para todos los productos

                     SELECT seqpago.NEXTVAL
                       INTO vpago
                       FROM DUAL;

                     BEGIN
                        --Se recupera la cuenta de abono del pago
                        SELECT ctipban, cbancar
                          INTO vctipban, vcbancar
                          FROM agentes
                         WHERE cagente = reg.cagente;
                     EXCEPTION
                        WHEN OTHERS THEN
                           vctipban := NULL;
                           vcbancar := NULL;
                     END;

                     IF NVL(pac_parametros.f_parempresa_n(pcempres, 'DIAS_RET_PAGOLIQ'), 0) <>
                                                                                              0 THEN
                        --RDD 04/02/2013 BUG 24813
                        BEGIN
                           SELECT COUNT(1)
                             INTO v_nrecpend
                             FROM recibos r, movrecibo m
                            WHERE r.cempres = pcempres
                              AND r.cagente = reg.cagente
                              AND m.nrecibo = r.nrecibo
                              AND m.cestrec = 0
                              AND m.fmovfin IS NULL
                              AND(f_sysdate - m.fmovini) >=
                                    NVL(pac_parametros.f_parempresa_n(pcempres,
                                                                      'DIAS_RET_PAGOLIQ'),
                                        0);
                        EXCEPTION
                           WHEN OTHERS THEN
                              v_nrecpend := 0;
                        END;
                     ELSE
                        v_nrecpend := 0;
                     END IF;

                     INSERT INTO pagoscomisiones
                                 (spago, cusuario, falta, cempres, cagente, fliquida,
                                  iimporte, nremesa, ftrans,
                                  cestado, cforpag, ctipopag, ctipban,
                                  cbancar, nnumlin)
                          VALUES (vpago, f_user, f_sysdate, pcempres, reg.cagente, pfecliq,
                                  -- f_round(ABS(reg.suma)),  -- 24. 0024803 26/11/2012 (-)
                                  f_round(ABS(reg.suma), v_cmoncia),   -- 24. 0024803 26/11/2012 (+)
                                                                    NULL, NULL,
                                  DECODE(v_nrecpend, 0, 0, 2),   --rdd 04/02/2013 bug 24813 si hay recibos entonces estado 2, retenido,
                                                              2, vcdebhab, vctipban,
                                  vcbancar, v_nnumlin_pago);

                     IF NVL(pac_parametros.f_parempresa_n(pcempres, 'CONTAB_ONLINE'), 0) = 1
                        AND pmodo <> 1
                        AND NVL(pac_parametros.f_parempresa_n(pcempres, 'GESTIONA_COBPAG'), 0) =
                                                                                              1
                        AND v_nrecpend = 0 THEN
                        verror := pac_user.f_get_terminal(pac_md_common.f_get_cxtusuario,
                                                          vterminal);
                        verror := pac_con.f_emision_pagorec(pcempres, 1, vtipopago, vpago,
                                                            NULL, vterminal, vemitido,
                                                            psinterf, perror, f_user, NULL,
                                                            NULL, NULL, 1);

                        IF verror <> 0
                           OR TRIM(perror) IS NOT NULL THEN
                           IF verror = 0 THEN
                              verror := 9903116;   --151323;
                              RETURN verror;
                           END IF;

                           p_tab_error(f_sysdate, f_user, 'pac_liquida.f_set_resumen_ctactes',
                                       1, 'error no controlado', perror || ' ' || verror);
                        ELSE
                           UPDATE pagoscomisiones
                              SET cestado = 1
                            WHERE spago = vpago;
                        END IF;
                     END IF;
                  -- fin 14344
                  ELSIF reg.suma < 0
                        AND NVL(pac_parametros.f_parempresa_n(pcempres, 'CTAPROD'), 0) = 0 THEN
                     UPDATE ctactes
                        SET cconcta = 0,
                            cdebhab = DECODE(cdebhab, 2, 1, 2),
                            sproces = NULL,
                            cestado = 1
                      WHERE cconcta IN(97)
                        AND cagente = reg.cagente
                        AND cempres = pcempres
                        AND sproces = psproces;
                  END IF;
               END LOOP;   -- Del BUCLE para el concepto 96 --
            END IF;   -- Del IF que mira si la empresa tiene sobrecomisión

            -- 43.0 - 08/01/2014 - MMM - 0029471: LCOL_C004-LCOL: Ajuste en el proceso de liquidacion de Convenio Liberty Web - Fin

            -- Bug 26964/146968 - 19/06/2013 - AMC
            IF (NVL(pac_parametros.f_parempresa_n(pcempres, 'CTAPROD'), 0) = 1
                OR NVL(pac_parametros.f_parempresa_n(pcempres, 'LIQ_DESG_COMP'), 0) = 1) THEN
               -- Fi Bug 26964/146968 - 19/06/2013 - AMC
               v_pasexec := 6;

               FOR reg IN c_pagocomision LOOP
                  IF reg.suma >= 0
                     OR NVL(pac_parametros.f_parempresa_n(pcempres, 'LIQ_NEGATIVO'), 0) = 1 THEN
                     --Bug.: 21449 - 01/03/2012 - ICV
                     --Creamos el apunte de saldo a 0
                     SELECT NVL(MAX(nnumlin), 0) + 1
                       INTO v_nnumlin
                       FROM ctactes
                      WHERE cagente = reg.cagente;

                     INSERT INTO ctactes
                                 (cagente, nnumlin, cdebhab, cconcta, cestado, ndocume,
                                  ffecmov, iimport,
                                  tdescrip, cmanual, cempres, nrecibo, nsinies,
                                  sseguro, sproces, fvalor, sproduc,
                                  ccompani   -- Bug 26964/146968 - 19/06/2013 - AMC
                                          )
                          VALUES (reg.cagente, v_nnumlin, vcdebhab, 0, 0, NULL,
                                  f_sysdate,
                                            -- f_round(vimporte),  -- 24. 0024803 26/11/2012 (-)
                                            f_round(vimporte, v_cmoncia),   -- 24. 0024803 26/11/2012 (+)
                                  f_axis_literales(9002057, vidioma), 1, pcempres, NULL, NULL,
                                  NULL, psproces, pfecliq, 0,
                                  0   -- Bug 26964/146968 - 19/06/2013 - AMC
                                   );   --Unico para todos los productos

                     SELECT seqpago.NEXTVAL
                       INTO vpago
                       FROM DUAL;

                     BEGIN
                        --Se recupera la cuenta de abono del pago
                        SELECT ctipban, cbancar
                          INTO vctipban, vcbancar
                          FROM agentes
                         WHERE cagente = reg.cagente;
                     EXCEPTION
                        WHEN OTHERS THEN
                           vctipban := NULL;
                           vcbancar := NULL;
                     END;

                     IF reg.suma < 0 THEN
                        vcdebhab := 2;
                     ELSE
                        vcdebhab := 1;
                     END IF;

                     IF NVL(pac_parametros.f_parempresa_n(pcempres, 'DIAS_RET_PAGOLIQ'), 0) <>
                                                                                              0 THEN
                        --RDD 04/02/2013 BUG 24813
                        BEGIN
                           SELECT COUNT(1)
                             INTO v_nrecpend
                             FROM recibos r, movrecibo m
                            WHERE r.cempres = pcempres
                              AND r.cagente = reg.cagente
                              AND m.nrecibo = r.nrecibo
                              AND m.cestrec = 0
                              AND m.fmovfin IS NULL
                              AND(f_sysdate - m.fmovini) >=
                                    NVL(pac_parametros.f_parempresa_n(pcempres,
                                                                      'DIAS_RET_PAGOLIQ'),
                                        0);
                        EXCEPTION
                           WHEN OTHERS THEN
                              v_nrecpend := 0;
                        END;
                     ELSE
                        v_nrecpend := 0;
                     END IF;

                     INSERT INTO pagoscomisiones
                                 (spago, cusuario, falta, cempres, cagente, fliquida,
                                  iimporte, nremesa, ftrans,
                                  cestado, cforpag, ctipopag, ctipban,
                                  cbancar, nnumlin)
                          VALUES (vpago, f_user, f_sysdate, pcempres, reg.cagente, pfecliq,
                                  -- f_round(ABS(reg.suma)), -- 24. 0024803 26/11/2012 (-)
                                  f_round(ABS(reg.suma), v_cmoncia),   -- 24. 0024803 26/11/2012 (+)
                                                                    NULL, NULL,
                                  DECODE(v_nrecpend, 0, 0, 2),   --rdd 04/02/2013 bug 24813 si hay recibos entonces estado 2, retenido,
                                                              2, vcdebhab, vctipban,
                                  vcbancar, v_nnumlin);

                     IF NVL(pac_parametros.f_parempresa_n(pcempres, 'CONTAB_ONLINE'), 0) = 1
                        AND pmodo <> 1
                        AND NVL(pac_parametros.f_parempresa_n(pcempres, 'GESTIONA_COBPAG'), 0) =
                                                                                              1
                        AND v_nrecpend = 0 THEN
                        verror := pac_user.f_get_terminal(pac_md_common.f_get_cxtusuario,
                                                          vterminal);
                        verror := pac_con.f_emision_pagorec(pcempres, 1, vtipopago, vpago,
                                                            NULL, vterminal, vemitido,
                                                            psinterf, perror, f_user, NULL,
                                                            NULL, NULL, 1);

                        IF verror <> 0
                           OR TRIM(perror) IS NOT NULL THEN
                           IF verror = 0 THEN
                              verror := 9903116;   --151323;
                              RETURN verror;
                           END IF;

                           p_tab_error(f_sysdate, f_user, 'pac_liquida.f_set_resumen_ctactes',
                                       1, 'error no controlado', perror || ' ' || verror);
                        ELSE
                           UPDATE pagoscomisiones
                              SET cestado = 1
                            WHERE spago = vpago;
                        END IF;
                     END IF;
                  ELSIF reg.suma < 0 THEN
                     UPDATE ctactes
                        SET cconcta = 0,
                            cdebhab = DECODE(cdebhab, 2, 1, 2),
                            sproces = NULL,
                            cestado = 1
                      WHERE cconcta IN(98, 97)   -- Bug 25988/145805 - 06/06/2013 - AMC
                        AND cagente = reg.cagente
                        AND cempres = pcempres
                        AND sproces = psproces;
                  END IF;
               END LOOP;
            END IF;
         END IF;   -- 21. 0022753
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
         RETURN 9001936;
   END f_set_resumen_ctactes;

   PROCEDURE p_apuntes_manuales(
      pagente IN NUMBER,
      pcempres IN NUMBER,
      psproces IN NUMBER,
      pfecliq IN DATE) IS
      v_object       VARCHAR2(500) := 'PAC_LIQUIDA.p_apuntes_manuales';
      v_param        VARCHAR2(500)
         := 'params : pcempres : ' || pcempres || ',pcagente : ' || pagente || ', psproces :'
            || psproces || ', fecha :' || pfecliq;
      v_pasexec      NUMBER(5) := 1;
      vreg           NUMBER;
   BEGIN
      UPDATE ctactes
         SET sproces = psproces,
             cestado = 0   --Estado liquidado
       WHERE cagente = pagente
         AND cempres = pcempres
         AND cestado = 1
         --AND cmanual = 0   -- ahora liquidamos todos manuales y  automaticos -- BUG 1896 AP 23/04/2018
         AND sproces IS NULL
         AND fvalor <= pfecliq;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
   END p_apuntes_manuales;

 /*************************************************************************
       Función que inserta los recibos pendientes de liquidar en liquidalin
       RETURN NUMBER
   *************************************************************************/
   FUNCTION f_set_recibos_liq(pcempres IN NUMBER,
                              pcagente IN NUMBER,
                              pfecliq  IN DATE,
                              psproces IN NUMBER,
                              pmodo    IN NUMBER,
                              pnliqmen OUT NUMBER,
                              psmovagr IN NUMBER DEFAULT NULL, -- 21. 0022753
                              pnrecibo IN NUMBER DEFAULT NULL) RETURN NUMBER IS
      --
      v_object  VARCHAR2(500) := 'PAC_LIQUIDA.F_SET_RECIBOS_LIQ';
      v_param   VARCHAR2(500) := 'params - pcempres :' || pcempres || ' pcagente : ' ||
                                 pcagente || ' pfecliq : ' || pfecliq || ' pnliqmen : ' ||
                                 pnliqmen || 'spro=' || psproces || 'mod=' || pmodo ||
                                 ' agr=' || psmovagr || ' rec=' || pnrecibo;
      v_pasexec NUMBER(5) := 1;
      num_err   NUMBER := 0;
      v_cageliq NUMBER;
      -- Bug 0026398 - JMF - 22/03/2013
      v_p_fefeadm_fmovdia NUMBER := NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,
                                                                      'FEFEADM_FMOVDIA'),
                                        0);
      v_p_diasliq         NUMBER := pac_parametros.f_parinstalacion_n('DIASLIQ');
      -- Bug Ini 0027043/157331: AMF - 30/10/2013
      v_dd_cambio NUMBER := NVL(pac_parametros.f_parempresa_n(pcempres,
                                                              'COMIS_DD_CAMB_LIQ'),
                                99);
      -- Bug Fin 0027043/157331: AMF - 30/10/2013
      d_hoytrunc DATE := TRUNC(f_sysdate);

      /* calculo anterior cestrec
              decode ( decode(
                             -- validar tipo _10
                             r.cestimp,5,0,1) , 1 , 10,
                       decode(
                              -- valida tipo_11
                               (select nvl(max(1),0) from dual where m.fmovini > r.fefecto  AND TRUNC(f_sysdate) >= (m.fmovini + v_p_DIASLIQ ) ), 1, 11,
                               decode(
                               -- valida_tipo_12
                               (select nvl(max(1),0) from dual where m.fmovini <= r.fefecto AND TRUNC(f_sysdate) >= (r.fefecto + v_p_DIASLIQ ) ), 1, 12
                               , 0)
                             )
                     ) cestrec,
      */
      /***************************************************************
      -- 10 cestrec,
                  --no domiciliat
                  AND r.cestimp <> 5
                  AND DECODE(v_p_FEFEADM_FMOVDIA, 1, TRUNC(m.fmovdia), TRUNC(m.fefeadm)) <= pfecliq   -- Bug: 20136 - JMC - 11/11/2011

      -- 11 cestrec,
                  --domiciliat
                  --que la data del moviment de cobrat sigui més gran que la data d'efecte
                  -- que hagin passat els dies de gestió a partir de la data de movimient del movimient de cobrat
                  AND r.cestimp = 5
                  AND m.fmovini > r.fefecto
                  AND TRUNC(f_sysdate) >= (m.fmovini +(v_p_DIASLIQ))

      -- 12 cestrec,
                  --domiciliat
                  --que la data del movimient de cobrat sigui menor o igual que la data d'efecte
                  -- que hagin passat els dies de gestió a partir de la data d'efecte del moviment de cobrat
                  AND r.cestimp = 5
                  AND m.fmovini <= r.fefecto
                  AND TRUNC(f_sysdate) >= (r.fefecto +(v_p_DIASLIQ))
      ***************************************************************/
      CURSOR c_rec IS
         SELECT r.nrecibo,
                r.nmovimi,
                r.cagente,
                r.sseguro,
                r.cempres,
                m.smovrec,
                m.fefeadm,
                r.fefecto,
                r.femisio,
                s.npoliza,
                s.cramo,
                r.cgescob,
                s.sproduc,
                v.iprinet + v.icednet iprinet,
                vm.iprinet + vm.icednet iprinet_moncia,
                v.icombru + v.icedcbr icomisi,
                vm.icombru + vm.icedcbr icomisi_moncia,
                v.icomret + v.icedcrt icomret,
                vm.icomret + vm.icedcrt icomret_moncia,
                v.itotalr itotalr,
                vm.itotalr itotalr_moncia,
                v.itotimp itotimp,
                vm.itotimp itotimp_moncia,
                0 cestrec,
                r.ctiprec, -- 16. 0021164: LCOL_A001: Proceso de liquidación, ajuste para los extornos
                v.iconvoleoducto iconvoleoducto,
                vm.iconvoleoducto iconvoleoducto_moncia, -- Bug 25988/145805 - 06/06/2013 - AMC
                pac_agentes.f_agente_liquida(r.cempres,
                                             NVL(pcagente,
                                                 r.cagente)) gestor -- BUG 31489 - FAL - 21/05/2014
           FROM movrecibo          m,
                recibos            r,
                seguros            s,
                vdetrecibos        v,
                vdetrecibos_monpol vm,
                agentes            a -- AFM 10/12/2015 bug: 39204
          WHERE m.nrecibo = r.nrecibo
            AND r.cagente = a.cagente -- AFM 10/12/2015 bug: 39204
            AND s.sseguro = r.sseguro
            AND r.nrecibo = v.nrecibo
            AND v.nrecibo = vm.nrecibo(+)
            AND m.smovagr = NVL(psmovagr,
                                m.smovagr) -- 21. 0022753
            AND m.nrecibo = NVL(pnrecibo,
                                m.nrecibo)
            AND m.smovrec = (SELECT MAX(smovrec) --agafem el màxim moviment del rebut
                               FROM movrecibo mv
                              WHERE mv.nrecibo = r.nrecibo
                                AND mv.fmovfin IS NULL)
            AND (((v.icombru <> 0 OR v.icombrui <> 0) AND r.cgescob IS NULL) OR
                (r.cgescob = 3)) --rebut amb comisions o gestió broker
            AND ((m.cestrec = 1) or (a.ctipage=4 and EXISTS (SELECT 1 FROM detrecibos dr
                                                              WHERE dr.nrecibo=v.nrecibo
                                                                and dr.nrecibo=r.nrecibo
                                                                and dr.cconcep in (32,33,34,35))))
            AND (NOT EXISTS (SELECT '*' --que el rebut no s'hagi liquidat mai
                               FROM liquidalin l,
                                    liquidacab lc
                              WHERE r.nrecibo = l.nrecibo
                                AND l.nliqmen = lc.nliqmen
                                AND l.cagente = lc.cagente
                                AND l.cempres = lc.cempres
                                   -- BUG 31489 - FAL - 21/05/2014
                                   -- AND lc.cagente = NVL(v_cageliq, r.cagente)
                                AND lc.cagente =
                                    NVL(v_cageliq,
                                        pac_agentes.f_agente_liquida(r.cempres,
                                                                     r.cagente))
                                   -- FI BUG 31489
                                AND lc.cestado = 1) OR EXISTS
                 (SELECT '*' --que la última vegada que el rebut hagi estat liquidat sigui un descobrament
                    FROM liquidalin l,
                         movrecibo  m,
                         liquidacab lc
                   WHERE l.nrecibo = r.nrecibo
                     AND m.smovrec = l.smovrec
                        --33.0 MMM -- 0027518: LCOL_PROD-0008271: LIBELULA IAXIS- ERROR COMISIONES DE AHORRO - NOTA 0149187 - Inicio
                        --AND l.smovrec = (SELECT MAX(l2.smovrec)
                        --                   FROM liquidalin l2
                        --                  WHERE l2.nrecibo = r.nrecibo)
                     AND l.smovrec = (SELECT MAX(l2.smovrec)
                                        FROM liquidalin l2,
                                             liquidacab lc2
                                       WHERE l2.nrecibo = l.nrecibo
                                         AND lc2.cagente = l2.cagente
                                         AND lc2.nliqmen = l2.nliqmen
                                         AND lc2.cestado = 1)
                        --33.0 MMM -- 0027518: LCOL_PROD-0008271: LIBELULA IAXIS- ERROR COMISIONES DE AHORRO - NOTA 014918 Fin
                     AND ((m.cestrec = 0 AND m.cestant = 1) OR m.cestrec = 2)
                        --AND l.smovrec <> m.smovrec -- MMM. 31. BUG 0027518: LCOL_PROD-0008271: LIBELULA IAXIS- ERROR COMISIONES DE AHORRO
                     AND l.nliqmen = lc.nliqmen
                     AND l.cagente = lc.cagente
                     AND l.cempres = lc.cempres
                        -- BUG 31489 - FAL - 21/05/2014
                        -- AND lc.cagente = NVL(v_cageliq, r.cagente)
                     AND lc.cagente =
                         NVL(v_cageliq,
                             pac_agentes.f_agente_liquida(r.cempres,
                                                          r.cagente))
                        -- FI BUG 31489
                     AND lc.cestado = 1))
            AND r.cempres = pcempres
               -- BUG 31489 - FAL - 21/05/2014
            AND r.cagente = NVL(pcagente,
                                r.cagente)
               -- FI BUG 31489 - FAL - 21/05/2014
            AND NOT EXISTS
          (SELECT 1
                   FROM age_corretaje c
                  WHERE c.sseguro = s.sseguro
                    AND c.nmovimi = (SELECT MAX(m.nmovimi)
                                       FROM age_corretaje m
                                      WHERE m.sseguro = s.sseguro))
            AND r.cestaux = 0 -- Bug 26022 - APD - 11/02/2013
            AND ((r.cestimp <> 5) OR --no domiciliat
                (SELECT NVL(MAX(1),
                             0)
                    FROM DUAL
                   WHERE m.fmovini > r.fefecto
                     AND d_hoytrunc >= (m.fmovini + v_p_diasliq)) = 1 OR
                (SELECT NVL(MAX(1),
                             0)
                    FROM DUAL
                   WHERE m.fmovini <= r.fefecto
                     AND d_hoytrunc >= (r.fefecto + v_p_diasliq)) = 1)
            AND DECODE(v_p_fefeadm_fmovdia,
                       1,
                       TRUNC(m.fmovdia),
                       TRUNC(m.fefeadm)) <= pfecliq --JAMF 18/02/2015  31321
            AND NVL(a.cliquido,
                    0) = DECODE(NVL(pac_parametros.f_parempresa_n(pcempres,
                                                                  'LIQ_CORTE_CUENTA'),
                                    0),
                                2,
                                0,
                                1,
                                1,
                                NVL(a.cliquido,
                                    0)) -- AFM 10/12/2015 bug: 39204
         UNION ALL
         SELECT DISTINCT (r.nrecibo),
                         r.nmovimi,
                         lq.cagente,
                         r.sseguro,
                         r.cempres,
                         m.smovrec,
                         m.fefeadm,
                         r.fefecto,
                         r.femisio,
                         s.npoliza,
                         s.cramo,
                         r.cgescob,
                         s.sproduc,
                         ABS(lq.iprinet),
                         ABS(lq.iprinet_moncia),
                         ABS(lq.icomisi),
                         ABS(lq.icomisi_moncia),
                         ABS(lq.iretenccom) icomret,
                         ABS(lq.iretenccom_moncia) icomret_moncia,
                         ABS(lq.itotalr),
                         ABS(lq.itotalr_moncia),
                         ABS(lq.itotimp),
                         ABS(lq.itotimp_moncia),
                         20 cestrec,
                         r.ctiprec, -- 16. 0021164: LCOL_A001: Proceso de liquidación, ajuste para los extornos
                         ABS(lq.iconvoleducto) iconvoleoducto,
                         ABS(lq.iconvoleod_moncia) iconvoleoducto_moncia, -- Bug 25988/145805 - 06/06/2013 - AMC
                         pac_agentes.f_agente_liquida(r.cempres,
                                                      NVL(pcagente,
                                                          lq.cagente)) gestor -- BUG 31489 - FAL - 21/05/2014
           FROM movrecibo  m,
                recibos    r,
                seguros    s, --JLV 04/06/2013 manca join contra liquidacab.
                liquidalin lq,
                agentes    a, -- AFM 10/12/2015 bug: 39204
                liquidacab lb --com que es moviment de "descobro" anem contra liquidalin
          WHERE s.sseguro = r.sseguro
            AND r.nrecibo = m.nrecibo
            AND m.nrecibo = lq.nrecibo
            AND lq.nliqmen = lb.nliqmen
            AND lq.cempres = lb.cempres
            AND a.cagente = NVL(v_cageliq,
                                r.cagente) -- AFM 10/12/2015 bug: 39204
            AND lq.cagente = NVL(v_cageliq,
                                 lq.cagente) --JLV 19/11/2013, 28611.
            AND NVL(a.cliquido,
                    0) = DECODE(NVL(pac_parametros.f_parempresa_n(pcempres,
                                                                  'LIQ_CORTE_CUENTA'),
                                    0),
                                2,
                                0,
                                1,
                                1,
                                NVL(a.cliquido,
                                    0)) -- AFM 10/12/2015 bug: 39204
            AND lq.cagente = lb.cagente
            AND lb.cestado = 1 --JLV 06/06/2013 bug 7375
            AND m.smovrec <> lq.smovrec -- que el moviment que estem tractant no sigui el moviment liquidat
            AND m.smovagr = NVL(psmovagr,
                                m.smovagr) -- 21. 0022753
            AND m.nrecibo = NVL(pnrecibo,
                                m.nrecibo)
            AND m.smovrec = (SELECT MAX(smovrec) --agafem el màxim moviment del rebut
                               FROM movrecibo mv
                              WHERE mv.nrecibo = r.nrecibo
                                AND mv.fmovfin IS NULL)
            AND ((m.cestrec = 0 AND cestant = 1) OR (m.cestrec = 2)) -- que sigui un descobrament
            AND EXISTS
          (SELECT '*' -- que la última liquidació d'aquest rebut sigui un cobrament
                   FROM liquidalin l,
                        movrecibo  m,
                        liquidacab lc
                  WHERE l.smovrec = m.smovrec
                    AND l.smovrec = (SELECT MAX(l2.smovrec)
                                       FROM liquidalin l2,
                                            liquidacab l3
                                      WHERE l2.nrecibo = r.nrecibo
                                        AND l2.cempres = l3.cempres
                                        AND l2.cagente = l3.cagente
                                        AND l2.cagente = NVL(v_cageliq,
                                                             lq.cagente) --JLV 19/11/2013, 28611
                                        AND l2.nliqmen = l3.nliqmen
                                        AND l3.ctipoliq = 0
                                        AND l3.cestado = 1)
                    AND m.cestrec = 1
                    AND l.nliqmen = lc.nliqmen
                    AND l.cempres = lc.cempres
                    AND l.cagente = lc.cagente
                    AND lc.cagente = NVL(v_cageliq,
                                         lq.cagente)
                       -- hem de tirar enrera el que hem donat per cobrat
                       -- independentment de si la liquidació ha sigut de comisions (1)
                       -- o d'autoliquidació (import(2) o comisions (3))
                       -- quins imports tirem enrera se soluciona a la select
                    AND lc.cestado = 1)
            AND r.cestaux = 0 -- Bug 26022 - APD - 11/02/2013
            AND DECODE(v_p_fefeadm_fmovdia,
                       1,
                       TRUNC(m.fmovdia),
                       TRUNC(m.fefeadm)) <= pfecliq --JAMF 18/02/2015  31321
         ------ AHORA HACEMOS LAS SELECTS QUE RECUPEREN LOS RECIBOS EN CORRETAJE -----
         UNION ALL
         ------ AHORA HACEMOS LAS SELECTS QUE RECUPEREN LOS RECIBOS EN CORRETAJE -----
         SELECT r.nrecibo,
                r.nmovimi,
                cr.cagente,
                r.sseguro,
                r.cempres,
                m.smovrec,
                m.fefeadm,
                r.fefecto,
                r.femisio,
                s.npoliza,
                s.cramo,
                r.cgescob,
                s.sproduc,
                v.iprinet + v.icednet iprinet,
                vm.iprinet + vm.icednet iprinet_moncia,
                ABS(SUM(cr.icombru)) icomisi,
                ABS(SUM(cr.icombru_moncia)) icomisi_moncia, -- JLV 19/11/2013 28964/158955
                ABS(SUM(cr.icomret)) icomret,
                ABS(SUM(cr.icomret_moncia)) icomret_moncia, -- JLV 19/11/2013 28964/158955
                v.itotalr itotalr,
                vm.itotalr itotalr_moncia,
                v.itotimp itotimp,
                vm.itotimp itotimp_moncia,
                0 cestrec,
                r.ctiprec, -- 16. 0021164: LCOL_A001: Proceso de liquidación, ajuste para los extornos

                /*v.iconvoleoducto iconvoleoducto,
                vm.iconvoleoducto iconvoleoducto_moncia   -- Bug 25988/145805 - 06/06/2013 - AMC*/ --40.0 JLV aplicar comisión Liberty Web sólo agente lider
                DECODE(pac_corretaje.f_esagelider(r.sseguro,
                                                  NULL,
                                                  cr.cagente),
                       0,
                       v.iconvoleoducto,
                       0) iconvoleoducto,
                DECODE(pac_corretaje.f_esagelider(r.sseguro,
                                                  NULL,
                                                  cr.cagente),
                       0,
                       vm.iconvoleoducto,
                       0) iconvoleoducto_moncia,
                pac_agentes.f_agente_liquida(r.cempres,
                                             NVL(pcagente,
                                                 cr.cagente)) gestor -- BUG 31489 - FAL - 21/05/2014
           FROM movrecibo          m,
                recibos            r,
                seguros            s,
                vdetrecibos        v,
                vdetrecibos_monpol vm,
                comrecibo          cr,
                agentes            a -- AFM 10/12/2015 bug: 39204
          WHERE m.nrecibo = r.nrecibo
            AND s.sseguro = r.sseguro
            AND r.nrecibo = v.nrecibo
            AND v.nrecibo = vm.nrecibo(+)
            AND m.smovagr = NVL(psmovagr,
                                m.smovagr) -- 21. 0022753
            AND m.nrecibo = NVL(pnrecibo,
                                m.nrecibo)
            AND m.smovrec = (SELECT MAX(smovrec) --agafem el màxim moviment del rebut
                               FROM movrecibo mv
                              WHERE mv.nrecibo = r.nrecibo
                                AND mv.fmovfin IS NULL)
            AND ((cr.icombru <> 0 AND r.cgescob IS NULL) OR r.cgescob = 3) --rebut amb comisions o gestió broker
            AND (NOT EXISTS (SELECT '*' --que el rebut no s'hagi liquidat mai
                               FROM liquidalin l,
                                    liquidacab lc
                              WHERE r.nrecibo = l.nrecibo
                                AND l.cagente = cr.cagente -- BUG 20559 - 29/12/2011 - JMP - LCOL_A001 - UAT-ADM - Error en liquidacio agents
                                AND l.nliqmen = lc.nliqmen
                                AND l.cagente = lc.cagente
                                AND l.cempres = lc.cempres
                                AND lc.cestado = 1) OR EXISTS
                 (SELECT '*' --que la última vegada que el rebut hagi estat liquidat sigui un descobrament
                    FROM liquidalin l,
                         movrecibo  m,
                         liquidacab lc
                   WHERE l.nrecibo = r.nrecibo
                     AND l.cagente = cr.cagente -- BUG 20559 - 29/12/2011 - JMP - LCOL_A001 - UAT-ADM - Error en liquidacio agents
                     AND m.smovrec = l.smovrec
                        --33.0 MMM -- 0027518: LCOL_PROD-0008271: LIBELULA IAXIS- ERROR COMISIONES DE AHORRO - NOTA 0149187 - Inicio
                        --AND l.smovrec = (SELECT MAX(l2.smovrec)
                        --                   FROM liquidalin l2
                        --                  WHERE l2.nrecibo = r.nrecibo)
                     AND l.smovrec = (SELECT MAX(l2.smovrec)
                                        FROM liquidalin l2,
                                             liquidacab lc2
                                       WHERE l2.nrecibo = l.nrecibo
                                         AND lc2.cagente = cr.cagente -- 36.0 JLV se añade el agente para que recupere el último movimiento de éste
                                         AND lc2.cagente = l2.cagente
                                         AND lc2.nliqmen = l2.nliqmen
                                         AND lc2.cestado = 1)
                        --33.0 MMM -- 0027518: LCOL_PROD-0008271: LIBELULA IAXIS- ERROR COMISIONES DE AHORRO - NOTA 014918 Fin
                     AND ((m.cestrec = 0 AND m.cestant = 1) OR m.cestrec = 2)
                        --AND l.smovrec <> m.smovrec -- MMM. 31. BUG 0027518: LCOL_PROD-0008271: LIBELULA IAXIS- ERROR COMISIONES DE AHORRO
                     AND l.nliqmen = lc.nliqmen
                     AND l.cagente = lc.cagente
                     AND l.cempres = lc.cempres
                     AND lc.cestado = 1))
            AND ((m.cestrec = 1) or (a.ctipage=4 and EXISTS (SELECT 1 FROM detrecibos dr
                                                              WHERE dr.nrecibo=v.nrecibo
                                                                and dr.nrecibo=r.nrecibo
                                                                and dr.cconcep in (32,33,34,35))))
            AND cr.nrecibo = r.nrecibo
            AND cr.cagente = NVL(pcagente,
                                 cr.cagente)
            AND a.cagente = NVL(v_cageliq,
                                cr.cagente) -- AFM 10/12/2015 bug: 39204
            AND NVL(a.cliquido,
                    0) = DECODE(NVL(pac_parametros.f_parempresa_n(pcempres,
                                                                  'LIQ_CORTE_CUENTA'),
                                    0),
                                2,
                                0,
                                1,
                                1,
                                NVL(a.cliquido,
                                    0)) -- AFM 10/12/2015 bug: 39204
            AND DECODE(v_p_fefeadm_fmovdia,
                       1,
                       TRUNC(m.fmovdia),
                       TRUNC(m.fefeadm)) <= pfecliq -- Bug: 20136 - JMC - 11/11/2011
            AND r.cempres = pcempres
            AND EXISTS
          (SELECT 1
                   FROM age_corretaje c
                  WHERE c.sseguro = s.sseguro
                    AND c.nmovimi = (SELECT MAX(m.nmovimi)
                                       FROM age_corretaje m
                                      WHERE m.sseguro = s.sseguro))
            AND r.cestaux = 0 -- Bug 26022 - APD - 11/02/2013
            AND ((r.cestimp <> 5) OR --no domiciliat
                (SELECT NVL(MAX(1),
                             0)
                    FROM DUAL
                   WHERE m.fmovini > r.fefecto
                     AND d_hoytrunc >= (m.fmovini + v_p_diasliq)) = 1 OR
                (SELECT NVL(MAX(1),
                             0)
                    FROM DUAL
                   WHERE m.fmovini <= r.fefecto
                     AND d_hoytrunc >= (r.fefecto + v_p_diasliq)) = 1)
          GROUP BY r.nrecibo,
                   r.nmovimi,
                   cr.cagente,
                   r.sseguro,
                   r.cempres,
                   m.smovrec,
                   m.fefeadm,
                   r.fefecto,
                   r.femisio,
                   s.npoliza,
                   s.cramo,
                   r.cgescob,
                   s.sproduc,
                   v.iprinet + v.icednet,
                   vm.iprinet + vm.icednet,
                   v.itotalr,
                   vm.itotalr,
                   v.itotimp,
                   vm.itotimp,
                   r.ctiprec,
                   v.iconvoleoducto,
                   vm.iconvoleoducto; -- Bug 25988/145805 - 06/06/2013 - AMC;

      v_nliqlin        NUMBER := 0;
      v_signo          NUMBER := 1;
      v_icomisi        NUMBER := 0;
      v_icomisi_moncia NUMBER := 0;
      v_itasa          eco_tipocambio.itasa%TYPE;
      v_cmultimon      parempresas.nvalpar%TYPE;
      v_fcambio        DATE;
      v_fechac         DATE; -- Bug  0027043/157331: AMF - 30/10/2013
      v_dd             CHAR(2); -- Bug  0027043/157331: AMF - 30/10/2013
      v_cmoncia        parempresas.nvalpar%TYPE;
      -- Bug 0022346 - JGR - Inicio
      v_cobro_parc      NUMBER := NVL(pac_parametros.f_parempresa_n(pcempres,
                                                                    'LIQ_COBRO_PARCIAL'),
                                      0);
      v_liquida_ctipage NUMBER := pac_parametros.f_parempresa_n(pcempres,
                                                                'LIQUIDA_CTIPAGE');
      -- Bug 0022346 - JGR - Fin
      v_p_calc_comind    NUMBER := NVL(pac_parametros.f_parempresa_n(pcempres,
                                                                     'CALC_COMIND'),
                                       0);
      vimpiprinet        NUMBER;
      vimpiprinet_monpol NUMBER;
      vimpicomisi        NUMBER;
      vimpicomisi_monpol NUMBER;
      vimpicomret        NUMBER;
      vimpicomret_monpol NUMBER;
      vimpitotalr        NUMBER;
      vimpitotalr_monpol NUMBER;
      vimpitotimp        NUMBER;
      vimpitotimp_monpol NUMBER;
      -- Bug 35979/206802: KJSC Asignar varibale nueva al parametro 'LIQUIDA_AGECLAVE'
      v_liquida_ageclave NUMBER;
      v_agente_ins       NUMBER;
      v_pretenc          NUMBER;
      v_nnumcom          NUMBER;
      v_nnumcom_c        NUMBER;
   BEGIN
      v_pasexec := 100;

      IF v_liquida_ctipage IS NULL THEN
         v_cageliq := pcagente;
      ELSE
         IF pcagente IS NOT NULL THEN
            v_pasexec := 110;
            v_cageliq := pac_agentes.f_get_cageliq(pcempres,
                                                   v_liquida_ctipage,
                                                   pcagente);
         END IF;
      END IF;

      -- Ini BUG 21606 - 26/03/2012 - JMC
      v_pasexec   := 120;
      v_cmultimon := NVL(pac_parametros.f_parempresa_n(pcempres,
                                                       'MULTIMONEDA'),
                         0);
      v_cmoncia   := pac_parametros.f_parempresa_n(pcempres,
                                                   'MONEDAEMP');
      -- Bug 35979/206802: KJSC Asignar varibale nueva al parametro 'LIQUIDA_AGECLAVE'
      v_liquida_ageclave := NVL(pac_parametros.f_parempresa_n(pcempres,
                                                              'LIQUIDA_AGECLAVE'),
                                0);
      -- Fin BUG 21606 - 26/03/2012 - JMC
      v_pasexec := 130;

      FOR rc IN c_rec LOOP
         -- Procesamos los recibos
         -- Bug 18843/91812 - 06/09/2011 - AMC
         -- BUG 31489 - FAL - 21/05/2014
         -- pnliqmen := f_get_nliqmen(pcempres, rc.cagente, pfecliq, psproces, pmodo);
         v_pasexec := 140;
         pnliqmen  := f_get_nliqmen(pcempres,
                                    rc.gestor,
                                    pfecliq,
                                    psproces,
                                    pmodo);
         -- FI BUG 31489 - FAL - 21/05/2014
         v_pasexec := 150;

         SELECT NVL(MAX(nliqlin),
                    0)
           INTO v_nliqlin
           FROM liquidalin
          WHERE cempres = pcempres
            AND nliqmen = pnliqmen
               -- BUG 31489 - FAL - 21/05/2014
               --AND cagente = rc.cagente;
            AND cagente = rc.gestor;

         -- FI BUG 31489 - FAL - 21/05/2014

         -- 22. 0022346: LCOL_A003-Cobro parcial de los recibos Fase 2 - Inicio
         -- Descartar los recibos con cobros parciales
         v_pasexec := 160;

         IF v_cobro_parc = 0 OR
            pac_adm_cobparcial.f_get_importe_cobro_parcial(rc.nrecibo,
                                                           NULL,
                                                           NULL) = 0 THEN
            -- 22. 0022346: LCOL_A003-Cobro parcial de los recibos Fase 2 - Fin

            -- ini AFM 10/12/2015  Error en la liquidación calculaba mal la comisión
            -- IF rc.cgescob = 3 THEN
            --    v_pasexec := 170;
            --    v_icomisi :=(-rc.itotalr + rc.icomisi);
            --    v_icomisi_moncia :=(-rc.itotalr_moncia + rc.icomisi_moncia);
            -- ELSE
            v_pasexec        := 180;
            v_icomisi        := rc.icomisi;
            v_icomisi_moncia := rc.icomisi_moncia;

            -- END IF;
            -- Fin AFM 10/12/2015 Error en la liquidación calculaba mal la comisión
            -- Fi Bug 18843/91812 - 06/09/2011 - AMC
            IF rc.cestrec = 20 THEN
               v_signo := -1;
            ELSE
               v_signo := 1;
            END IF;

            -- 16. 0021164: LCOL_A001: Proceso de liquidación, ajuste para los extornos - Inicio
            IF rc.ctiprec IN (9,
                              13) THEN
               v_signo := v_signo * -1;
            END IF;

            -- 16. 0021164: LCOL_A001: Proceso de liquidación, ajuste para los extornos - Fin

            -- BUG 18423 - 02/11/2011 - JMP - LCOL000 - Multimoneda
            v_pasexec := 190;

            IF v_cmultimon = 1 THEN
               -- Bug Ini 0027043/157331: AMF - 30/10/2013
               IF v_dd_cambio = 99 THEN
                  -- No hay dia de cambio
                  v_pasexec := 200;
                  num_err   := pac_oper_monedas.f_datos_contraval(NULL,
                                                                  rc.nrecibo,
                                                                  NULL,
                                                                  f_sysdate,
                                                                  2,
                                                                  v_itasa,
                                                                  v_fcambio);
               ELSE
                  -- El día de cambio es uno concreto si la fecha liquidación es final de mes
                  IF pfecliq = LAST_DAY(pfecliq) THEN
                     v_pasexec := 210;
                     v_fechac  := pfecliq + v_dd_cambio;
                  ELSE
                     v_fechac := TRUNC(f_sysdate);
                  END IF;

                  --
                  v_pasexec := 220;
                  num_err   := pac_oper_monedas.f_datos_contraval(NULL,
                                                                  rc.nrecibo,
                                                                  NULL,
                                                                  v_fechac,
                                                                  2,
                                                                  v_itasa,
                                                                  v_fcambio);
               END IF;
               -- Bug Fin 0027043/157331: AMF - 30/10/2013
            END IF;

            v_nliqlin := v_nliqlin + 1;
            -- Inicio Bug 32674 MMS 20141006
            v_pasexec := 230;

            IF NVL(pac_parametros.f_parempresa_n(pcempres,
                                                 'DETRECIBOS_FCAMBIO'),
                   0) = 1 THEN
               v_pasexec := 240;
               num_err   := f_valor_recaudo(rc.nrecibo,
                                            rc.smovrec,
                                            vimpiprinet,
                                            vimpiprinet_monpol,
                                            vimpicomisi,
                                            vimpicomisi_monpol,
                                            vimpicomret,
                                            vimpicomret_monpol,
                                            vimpitotalr,
                                            vimpitotalr_monpol,
                                            vimpitotimp,
                                            vimpitotimp_monpol);
            ELSE
               vimpiprinet := NVL(rc.iprinet,
                                  0) * v_signo;
               v_pasexec   := 250;

               SELECT f_round(DECODE(v_dd_cambio,
                                     99,
                                     rc.iprinet_moncia * v_signo,
                                     NVL(rc.iprinet,
                                         0) * v_signo * v_itasa),
                              v_cmoncia)
                 INTO vimpiprinet_monpol
                 FROM DUAL;

               vimpicomisi := NVL(v_icomisi,
                                  0) * v_signo;
               v_pasexec   := 260;

               SELECT f_round(DECODE(v_dd_cambio,
                                     99,
                                     v_icomisi_moncia * v_signo,
                                     NVL(v_icomisi,
                                         0) * v_signo * v_itasa),
                              v_cmoncia)
                 INTO vimpicomisi_monpol
                 FROM DUAL;

               vimpicomret := NVL(rc.icomret,
                                  0) * v_signo;
               v_pasexec   := 270;

               SELECT f_round(DECODE(v_dd_cambio,
                                     99,
                                     rc.icomret_moncia * v_signo,
                                     NVL(rc.icomret,
                                         0) * v_signo * v_itasa),
                              v_cmoncia)
                 INTO vimpicomret_monpol
                 FROM DUAL;

               vimpitotalr := NVL(rc.itotalr,
                                  0) * v_signo;
               v_pasexec   := 280;

               SELECT f_round(DECODE(v_dd_cambio,
                                     99,
                                     rc.itotalr_moncia * v_signo,
                                     NVL(rc.itotalr,
                                         0) * v_signo * v_itasa),
                              v_cmoncia)
                 INTO vimpitotalr_monpol
                 FROM DUAL;

               vimpitotimp := NVL(rc.itotimp,
                                  0) * v_signo;
               v_pasexec   := 290;

               SELECT f_round(DECODE(v_dd_cambio,
                                     99,
                                     rc.itotimp_moncia * v_signo,
                                     NVL(rc.itotimp,
                                         0) * v_signo * v_itasa),
                              v_cmoncia)
                 INTO vimpitotimp_monpol
                 FROM DUAL;
            END IF;

            -- Fin Bug 32674 MMS 20141006
            -- FIN BUG 18423 - 02/11/2011 - JMP - LCOL000 - Multimoneda
            -- Bug 35979/206802: KJSC Verificamos que el parametro LIQUIDA_AGECLAVE es 1
            v_pasexec := 300;

            IF v_liquida_ageclave = 1 THEN
               SELECT MAX(cageclave)
                 INTO v_agente_ins
                 FROM agentes_comp
                WHERE cagente = rc.gestor;

               IF v_agente_ins IS NULL THEN
                  v_agente_ins := rc.gestor;
               END IF;
            ELSE
               v_agente_ins := rc.gestor;
            END IF;

            v_pasexec := 310;

            ---nueva funcion para validar signo
             IF v_signo = 1 THEN



               SELECT count(1) into v_nnumcom_c FROM COMRECIBO WHERE nrecibo= rc.nrecibo;

               IF v_nnumcom_c<>0 THEN

                  SELECT MAX(NNUMCOM) into v_nnumcom FROM COMRECIBO WHERE nrecibo= rc.nrecibo;

               END IF;

                  IF v_nnumcom_c<>0 THEN
                     v_pasexec := 311;
                  INSERT INTO COMRECIBO(NRECIBO,
                                        NNUMCOM,
                                        CAGENTE,
                                        CESTREC,
                                        FMOVDIA,
                                        FCONTAB,
                                        ICOMBRU,
                                        ICOMRET,
                                        ICOMDEV,
                                        IRETDEV,
                                        NMOVIMI,
                                        ICOMBRU_MONCIA,
                                        ICOMRET_MONCIA,
                                        ICOMDEV_MONCIA,
                                        IRETDEV_MONCIA,
                                        FCAMBIO,
                                        CGARANT,
                                        ICOMCEDIDA,
                                        ICOMCEDIDA_MONCIA)
                                        VALUES(rc.nrecibo,
                                        v_nnumcom+1,
                                        rc.cagente,
                                        f_cestrec_mv(rc.nrecibo, null),
                                        null,
                                        null,
                                        -v_icomisi,
                                        -vimpicomret,
                                        null,
                                        null,
                                        rc.nmovimi
                                        ,null,null
                                        ,null,null
                                        ,null,null,
                                        null,null);
                  ELSE

                   v_pasexec := 312;
                  v_nnumcom:=1;
                    INSERT INTO COMRECIBO(NRECIBO,
                                        NNUMCOM,
                                        CAGENTE,
                                        CESTREC,
                                        FMOVDIA,
                                        FCONTAB,
                                        ICOMBRU,
                                        ICOMRET,
                                        ICOMDEV,
                                        IRETDEV,
                                        NMOVIMI,
                                        ICOMBRU_MONCIA,
                                        ICOMRET_MONCIA,
                                        ICOMDEV_MONCIA,
                                        IRETDEV_MONCIA,
                                        FCAMBIO,
                                        CGARANT,
                                        ICOMCEDIDA,
                                        ICOMCEDIDA_MONCIA)
                                        VALUES(rc.nrecibo,
                                        v_nnumcom,
                                        rc.cagente,
                                        f_cestrec_mv(rc.nrecibo, null),
                                        f_sysdate,
                                        null,
                                        -v_icomisi,
                                        -vimpicomret,
                                        null,
                                        null,
                                        rc.nmovimi
                                        ,null,null
                                        ,null,null
                                        ,null,null,
                                        null,null);
                                         v_pasexec := 313;
                                          INSERT INTO COMRECIBO(NRECIBO,
                                        NNUMCOM,
                                        CAGENTE,
                                        CESTREC,
                                        FMOVDIA,
                                        FCONTAB,
                                        ICOMBRU,
                                        ICOMRET,
                                        ICOMDEV,
                                        IRETDEV,
                                        NMOVIMI,
                                        ICOMBRU_MONCIA,
                                        ICOMRET_MONCIA,
                                        ICOMDEV_MONCIA,
                                        IRETDEV_MONCIA,
                                        FCAMBIO,
                                        CGARANT,
                                        ICOMCEDIDA,
                                        ICOMCEDIDA_MONCIA)
                                        VALUES(rc.nrecibo,
                                        v_nnumcom+1,
                                        rc.cagente,
                                        f_cestrec_mv(rc.nrecibo, null),
                                        f_sysdate,
                                        null,
                                        v_icomisi,
                                        vimpicomret,
                                        null,
                                        null,
                                        rc.nmovimi
                                        ,null,null
                                        ,null,null
                                        ,null,null,
                                        null,null);
                  END IF;

                   v_pasexec := 314;
                SELECT r.pretenc
                INTO v_pretenc
                  FROM RETENCIONES r,  AGENTES a
                  WHERE r.CRETENC = a.cretenc
                  AND   F_SYSDATE BETWEEN FINIVIG AND NVL(FFINVIG, F_SYSDATE)
                  AND   a.cagente = v_agente_ins;

                  vimpicomret :=  (v_icomisi * v_pretenc)/100;



                  IF v_nnumcom_c<>0 THEN
                  --registro 1
                 v_pasexec := 315;
                 INSERT INTO COMRECIBO(NRECIBO,
                                        NNUMCOM,
                                        CAGENTE,
                                        CESTREC,
                                        FMOVDIA,
                                        FCONTAB,
                                        ICOMBRU,
                                        ICOMRET,
                                        ICOMDEV,
                                        IRETDEV,
                                        NMOVIMI,
                                        ICOMBRU_MONCIA,
                                        ICOMRET_MONCIA,
                                        ICOMDEV_MONCIA,
                                        IRETDEV_MONCIA,
                                        FCAMBIO,
                                        CGARANT,
                                        ICOMCEDIDA,
                                        ICOMCEDIDA_MONCIA)
                                        VALUES(rc.nrecibo,
                                        v_nnumcom+2,
                                        rc.cagente,
                                        f_cestrec_mv(rc.nrecibo, null),
                                        f_sysdate,
                                        null,
                                        v_icomisi,
                                        vimpicomret,
                                        null,
                                        null,
                                        rc.nmovimi
                                        ,null,null
                                        ,null,null
                                        ,null,null,
                                        null,null);


                ELSE
                 v_pasexec := 316;
                v_nnumcom:=1;
                INSERT INTO COMRECIBO(NRECIBO,
                                        NNUMCOM,
                                        CAGENTE,
                                        CESTREC,
                                        FMOVDIA,
                                        FCONTAB,
                                        ICOMBRU,
                                        ICOMRET,
                                        ICOMDEV,
                                        IRETDEV,
                                        NMOVIMI,
                                        ICOMBRU_MONCIA,
                                        ICOMRET_MONCIA,
                                        ICOMDEV_MONCIA,
                                        IRETDEV_MONCIA,
                                        FCAMBIO,
                                        CGARANT,
                                        ICOMCEDIDA,
                                        ICOMCEDIDA_MONCIA)
                                        VALUES(rc.nrecibo,
                                        v_nnumcom+3,
                                        rc.cagente,
                                        f_cestrec_mv(rc.nrecibo, null),
                                        f_sysdate,
                                        null,
                                        v_icomisi,
                                        vimpicomret,
                                        null,
                                        null,
                                        rc.nmovimi
                                        ,null,null
                                        ,null,null
                                        ,null,null,
                                        null,null);



          END IF;
          END IF;

          UPDATE DETRECIBOS
          SET ICONCEP=vimpicomret
          WHERE nrecibo=rc.nrecibo
          AND cconcep=12;


            INSERT INTO liquidalin
               (cempres,
                nliqmen,
                cagente,
                nliqlin,
                nrecibo,
                smovrec,
                itotimp,
                itotalr,
                iprinet,
                icomisi,
                iretenccom,
                isobrecomision,
                iretencsobrecom,
                iconvoleducto,
                iretencoleoducto,
                ctipoliq,
                -- BUG 18423 - 02/11/2011 - JMP - LCOL000 - Multimoneda
                itotimp_moncia,
                itotalr_moncia,
                iprinet_moncia,
                icomisi_moncia,
                iretenccom_moncia,
                isobrecom_moncia,
                iretencscom_moncia,
                iconvoleod_moncia,
                iretoleod_moncia,
                fcambio,
                -- FIN BUG 18423 - 02/11/2011 - JMP - LCOL000 - Multimoneda
                cagerec)
            -- Bug 35979/206802: KJSC Insertamos el agente v_agente_ins
            VALUES
               (pcempres,
                pnliqmen,
                v_agente_ins /*rc.gestor*/,
                v_nliqlin,
                rc.nrecibo,
                rc.smovrec,
                vimpitotimp,
                vimpitotalr,
                vimpiprinet,
                vimpicomisi,
                vimpicomret, --Bug 32674 MMS 20141006
                NULL,
                NULL,
                NVL(rc.iconvoleoducto,
                    0) * v_signo, -- Bug 25988/145805 - 06/06/2013 - AMC
                NULL,
                NULL,
                -- BUG 18423 - 02/11/2011 - JMP - LCOL000 - Multimoneda
                -- Bug Ini 27043/157331: AFM - 30/10/2013
                vimpitotimp_monpol,
                vimpitotalr_monpol,
                vimpiprinet_monpol, -- Bug 32674 MMS 20141006
                vimpicomisi_monpol,
                vimpicomret_monpol,
                NULL, --Bug 32674 MMS 20141006
                NULL,
                -- Bug 25988/145805 - 06/06/2013 - AMC,
                f_round(DECODE(v_dd_cambio,
                               99,
                               NVL(rc.iconvoleoducto_moncia,
                                   0) * v_signo,
                               NVL(rc.iconvoleoducto,
                                   0) * v_signo * v_itasa),
                        v_cmoncia),
                -- Bug Fin 0027043/157331: AFM - 30/10/2013
                NULL,
                DECODE(v_cmultimon,
                       0,
                       NULL,
                       NVL(v_fcambio,
                           f_sysdate)),
                -- FIN BUG 18423 - 02/11/2011 - JMP - LCOL000 - Multimoneda
                rc.cagente);

            -- Bug 0029334 - JMF - 11/12/2013
            IF v_p_calc_comind IN (1,
                                   3) THEN
               -- por cuadros de comisión indirecta pero modalidad directa
               v_pasexec := 320;
               num_err   := f_crea_liquidalindet_dir(pnliqmen,
                                                     rc.cagente,
                                                     v_nliqlin,
                                                     pcempres,
                                                     rc.nrecibo,
                                                     SIGN(NVL(v_icomisi,
                                                              0) * v_signo),
                                                     pfecliq,
                                                     NULL,
                                                     rc.smovrec);
            END IF;

         END IF; -- 22. 0022346: LCOL_A003-Cobro parcial de los recibos Fase 2

      END LOOP;

      v_pasexec := 330;
      RETURN num_err;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate,
                     f_user,
                     v_object,
                     v_pasexec,
                     v_param,
                     num_err || ' ' || SQLERRM);
         RETURN 108953;
   END f_set_recibos_liq;


    /*************************************************************************
       Función que inserta los recibos externos pendientes de liquidar en liquidalin
           param in p_cempres   : Código empresa
           param in p_cagente   : Código agente
           param in pfecliq     : Periodo a liquidar
           param in pnliqmen    : Numero liquidacion
           RETURN NUMBER        : 0=Ok, numero error
   *************************************************************************/
   -- ini Bug 0019154 - JMF - 02/08/2011
   FUNCTION f_set_ext_recibos_liq(
      pcempres IN NUMBER,
      pcagente IN NUMBER,
      pfecliq IN DATE,
      psproces IN NUMBER,
      pmodo IN NUMBER,
      pnliqmen OUT NUMBER,
      psmovagr IN NUMBER DEFAULT NULL,   -- 21. 0022753
      pnrecibo IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      v_object       VARCHAR2(500) := 'PAC_LIQUIDA.F_SET_EXT_RECIBOS_LIQ';
      v_param        VARCHAR2(500)
         := 'e:' || pcempres || ' a:' || pcagente || ' f:' || pfecliq || ' n:' || pnliqmen
            || ' sproces:' || psproces || ' modo:' || pmodo;
      v_pasexec      NUMBER(5) := 1;
      num_err        NUMBER := 0;
      v_cageliq      NUMBER;

      CURSOR c_rec IS
         SELECT e.nreccia num_rec, e.sextmovrec, 2 cgescob, e.iprinet, e.icombru icomisi,
                e.itotrec itotalr, 0 itotimp, 0 icomret, DECODE(e.csitrec, 2, 20, 10) cestrec,
                e.ccompani
           FROM ext_recibos e, productos p, codiram r
          WHERE p.sproduc = e.sproduc
            AND r.cramo = p.cramo
            AND e.icombru <> 0
            AND e.csitrec = 1   --cobrado
            AND(NOT EXISTS(SELECT 1   --que el rebut no s'hagi liquidat mai
                             FROM ext_liquidalin l, liquidacab lc
                            WHERE e.nreccia = l.num_rec
                              AND l.nliqmen = lc.nliqmen
                              AND l.cagente = lc.cagente
                              AND l.cempres = lc.cempres
                              AND lc.cagente = v_cageliq   --pcagente
                              AND lc.cestado = 1)
                OR EXISTS(
                     SELECT 1   --que la última vegada que el rebut hagi estat liquidat sigui un descobrament
                       FROM ext_liquidalin l, ext_recibos e1, liquidacab lc
                      WHERE e1.nreccia = e.nreccia
                        AND e1.ccompani = e.ccompani
                        AND l.ccompani = e1.ccompani
                        AND l.num_rec = e1.nreccia
                        AND l.nliqmen = lc.nliqmen
                        AND l.cagente = lc.cagente
                        AND l.cempres = lc.cempres
                        AND l.sextmovrec = e1.sextmovrec
                        AND l.sextmovrec = (SELECT MAX(l2.sextmovrec)
                                              FROM ext_liquidalin l2, liquidacab lc2
                                             WHERE l2.nliqmen = lc2.nliqmen
                                               AND l2.cagente = lc2.cagente
                                               AND l2.cempres = lc2.cempres
                                               AND l2.ccompani = e1.ccompani
                                               AND l2.num_rec = e1.nreccia
                                               AND lc2.cestado = 1)
                        AND lc.cagente = v_cageliq   --pcagente
                        AND e1.csitrec = 2
                        AND lc.cestado = 1))
            AND r.cempres = pcempres
            --AND e.fefecto <= pfecliq
            AND e.ccolabo = pcagente
            AND e.sextmovrec = (SELECT MAX(e5.sextmovrec)
                                  FROM ext_recibos e5
                                 WHERE e5.icombru <> 0
                                   AND e5.ccolabo = pcagente
                                   AND e5.nreccia = e.nreccia
                                   AND e5.fmovrec <= pfecliq)
         UNION
         /*
         SELECT e.nreccia num_rec, e.sextmovrec, 2 cgescob, e.iprinet, e.icombru icomisi,
                e.itotrec itotalr, 0 itotimp, 0 icomret, DECODE(e.csitrec, 2, 20, 10) cestrec,
                e.ccompani
           FROM ext_recibos e, productos p, codiram r
          WHERE p.sproduc = e.sproduc
            AND r.cramo = p.cramo
            AND e.icombru <> 0
            AND e.csitrec = 2   --Anulado
            AND EXISTS(
                  SELECT 1   --que la última vegada que el rebut hagi estat liquidat sigui un cobrament
                    FROM ext_liquidalin l, ext_recibos e1, liquidacab lc
                   WHERE e1.nreccia = e.nreccia
                     AND e1.ccompani = e.ccompani
                     AND l.ccompani = e1.ccompani
                     AND l.num_rec = e1.nreccia
                     AND l.nliqmen = lc.nliqmen
                     AND l.cagente = lc.cagente
                     AND l.cempres = lc.cempres
                     AND l.sextmovrec = e1.sextmovrec
                     AND l.sextmovrec = (SELECT MAX(l2.sextmovrec)
                                           FROM ext_liquidalin l2
                                          WHERE l2.ccompani = e1.ccompani
                                            AND l2.num_rec = e1.nreccia)
                     AND l.sextmovrec <> e.sextmovrec
                     AND lc.cagente = v_cageliq   --pcagente
                     AND e1.csitrec = 1
                     AND lc.cestado = 1)
            AND r.cempres = pcempres
            AND e.ccolabo = pcagente
            AND e.sextmovrec = (SELECT MAX(e5.sextmovrec)
                                  FROM ext_recibos e5
                                 WHERE e5.icombru <> 0
                                   AND e5.ccolabo = pcagente
                                   AND e5.nreccia = e.nreccia
                                   AND e5.fmovrec <= pfecliq);*/
         SELECT e.nreccia num_rec, e.sextmovrec, 2 cgescob, e.iprinet, e.icombru icomisi,
                e.itotrec itotalr, 0 itotimp, 0 icomret, DECODE(e.csitrec, 2, 20, 10) cestrec,
                e.ccompani
           FROM ext_recibos e, productos p, codiram r, ext_liquidalin l, liquidacab lc
          WHERE p.sproduc = e.sproduc
            AND r.cramo = p.cramo
            AND l.ccompani = e.ccompani
            AND l.num_rec = e.nreccia
            AND l.nliqmen = lc.nliqmen
            AND l.cagente = lc.cagente
            AND l.cempres = lc.cempres
            AND e.icombru <> 0
            AND e.csitrec = 2   --Anulado
            AND r.cempres = 10
            AND e.ccolabo = pcagente
            AND l.sextmovrec <> e.sextmovrec
            AND e.sextmovrec = (SELECT MAX(e5.sextmovrec)
                                  FROM ext_recibos e5
                                 WHERE e5.icombru <> 0
                                   AND e5.ccolabo = pcagente
                                   AND e5.nreccia = e.nreccia
                                   AND e5.fmovrec <= pfecliq)
            AND EXISTS(
                  SELECT l2.*   --que la última vegada que el rebut hagi estat liquidat sigui un cobrament
                    FROM ext_liquidalin l2, ext_recibos e2, liquidacab lc2
                   WHERE e2.nreccia = e.nreccia
                     AND e2.ccompani = e.ccompani
                     AND l2.ccompani = e2.ccompani
                     AND l2.num_rec = e2.nreccia
                     AND l2.nliqmen = lc2.nliqmen
                     AND l2.cagente = lc2.cagente
                     AND l2.cempres = lc2.cempres
                     AND l2.sextmovrec = e2.sextmovrec
                     AND l2.sextmovrec = (SELECT MAX(l3.sextmovrec)
                                            FROM ext_liquidalin l3, liquidacab lc3
                                           WHERE l3.ccompani = e2.ccompani
                                             AND l3.num_rec = e2.nreccia
                                             AND lc3.nliqmen = l3.nliqmen
                                             AND lc3.cagente = l3.cagente
                                             AND lc3.cempres = l3.cempres
                                             AND lc3.cestado = 1)
                     AND lc2.cagente = v_cageliq
                     AND e2.csitrec = 1
                     AND lc2.cestado = 1);

      v_nliqlin      NUMBER := 0;
      v_signo        NUMBER := 1;
      v_icomisi      NUMBER := 0;
      v_cmoncia      NUMBER;   -- 24. 0024803 26/11/2012
   BEGIN
      IF pac_parametros.f_parempresa_n(pcempres, 'LIQUIDA_CTIPAGE') IS NULL THEN
         v_cageliq := pcagente;
      ELSE
         v_cageliq :=
            pac_agentes.f_get_cageliq(pcempres,
                                      pac_parametros.f_parempresa_n(pcempres,
                                                                    'LIQUIDA_CTIPAGE'),
                                      pcagente);
      END IF;

      v_pasexec := 100;
      -- buscamos el nliqmen del agente
      pnliqmen := f_get_nliqmen(pcempres, v_cageliq, pfecliq, psproces, pmodo);

      SELECT NVL(MAX(nliqlin), 0)
        INTO v_nliqlin
        FROM ext_liquidalin
       WHERE cempres = pcempres
         AND nliqmen = pnliqmen
         AND cagente = v_cageliq;

      v_pasexec := 102;

      -- 24. 0024803 26/11/2012 - Inicio
      IF NVL(pac_parametros.f_parempresa_n(pcempres, 'MULTIMONEDA'), 0) = 1 THEN
         v_cmoncia := pac_parametros.f_parempresa_n(pcempres, 'MONEDAEMP');
      END IF;

      v_pasexec := 103;

      -- 24. 0024803 26/11/2012 - Fin
      FOR rc IN c_rec LOOP   -- Procesamos los recibos
         v_pasexec := 105;

         IF rc.cgescob = 3 THEN
            v_pasexec := 110;
            v_icomisi :=(-rc.itotalr + rc.icomisi - rc.itotimp);
         ELSE
            v_pasexec := 115;
            v_icomisi := rc.icomisi - rc.itotimp;
         END IF;

         v_pasexec := 120;

         IF rc.cestrec = 20 THEN
            v_signo := -1;
         ELSE
            v_signo := 1;
         END IF;

         v_pasexec := 125;
         v_nliqlin := v_nliqlin + 1;
         v_pasexec := 130;

         INSERT INTO ext_liquidalin
                     (cempres, nliqmen, cagente, nliqlin, num_rec, ccompani,
                      sextmovrec, itotimp,
                      itotalr,
                      iprinet,
                      icomisi,
                      iretenccom, isobrecomision, iretencsobrecom, iconvoleducto,
                      iretencoleoducto, ctipoliq, sproliq, cagerec)
              VALUES (pcempres, pnliqmen, v_cageliq, v_nliqlin, rc.num_rec, rc.ccompani,
                      rc.sextmovrec,
                                    -- 24. 0024803 26/11/2012 - Inicio
                                    -- f_round(NVL(rc.itotimp, 0) * v_signo),
                                    -- f_round(NVL(rc.itotalr, 0) * v_signo),
                                    -- f_round(NVL(rc.iprinet, 0) * v_signo),
                                    -- f_round(NVL(v_icomisi, 0) * v_signo),
                                    -- f_round(NVL(rc.icomret, 0) * v_signo),
                                    f_round(NVL(rc.itotimp, 0) * v_signo, v_cmoncia),
                      f_round(NVL(rc.itotalr, 0) * v_signo, v_cmoncia),
                      f_round(NVL(rc.iprinet, 0) * v_signo, v_cmoncia),
                      f_round(NVL(v_icomisi, 0) * v_signo, v_cmoncia),
                      f_round(NVL(rc.icomret, 0) * v_signo, v_cmoncia),
                                                                       -- 24. 0024803 26/11/2012 - Fin
                      NULL, NULL, NULL,
                      NULL, NULL, psproces, pcagente);
      END LOOP;

      v_pasexec := 140;
      RETURN 0;
   -- fin Bug 0019154 - JMF - 02/08/2011
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param,
                     SQLCODE || ' ' || SQLERRM);
         RETURN 108953;
   END f_set_ext_recibos_liq;

    /*************************************************************************
       Función que inserta los recibos externos pendientes de liquidar en liquidalin
           param in p_cempres   : Código empresa
           param in p_cagente   : Código agente
           param in pfecliq     : Periodo a liquidar
           param in pnliqmen    : Numero liquidacion
           RETURN NUMBER        : 0=Ok, numero error
   *************************************************************************/
   -- ini Bug 0019689 - JMC - 18/10/2011
   FUNCTION f_set_ext_recibos_liq_ind(
      pcempres IN NUMBER,
      pcagente IN NUMBER,
      pfecliq IN DATE,
      psproces IN NUMBER,
      pmodo IN NUMBER,
      pnliqmen OUT NUMBER,
      pcageind IN NUMBER)
      RETURN NUMBER IS
      v_object       VARCHAR2(500) := 'PAC_LIQUIDA.F_SET_EXT_RECIBOS_LIQ_IND';
      v_param        VARCHAR2(500)
         := 'e:' || pcempres || ' a:' || pcagente || ' f:' || pfecliq || ' n:' || pnliqmen
            || ' ai:' || pcageind;
      v_pasexec      NUMBER(5) := 1;
      num_err        NUMBER := 0;

      CURSOR c_rec IS
         SELECT e.nreccia num_rec, e.sextmovrec, 2 cgescob, e.iprinet, e.icomind icomisi,
                e.itotrec itotalr, 0 itotimp, iretind icomret,
                DECODE(e.csitrec, 2, 20, 10) cestrec, e.ccompani, e.ctiprec
           FROM ext_recibos e, productos p, codiram r
          WHERE p.sproduc = e.sproduc
            AND r.cramo = p.cramo
            AND e.icombru <> 0
            AND e.csitrec = 1   --cobrado
            AND(NOT EXISTS(SELECT 1   --que el rebut no s'hagi liquidat mai
                             FROM ext_liquidalin l, liquidacab lc
                            WHERE e.nreccia = l.num_rec
                              AND l.nliqmen = lc.nliqmen
                              AND l.cagente = lc.cagente
                              AND l.cempres = lc.cempres
                              AND lc.cagente = pcagente
                              AND lc.cestado = 1)
                OR EXISTS(
                     SELECT 1   --que la última vegada que el rebut hagi estat liquidat sigui un descobrament
                       FROM ext_liquidalin l, ext_recibos e1, liquidacab lc
                      WHERE e1.nreccia = e.nreccia
                        AND e1.ccompani = e.ccompani
                        AND l.ccompani = e1.ccompani
                        AND l.num_rec = e1.nreccia
                        AND l.nliqmen = lc.nliqmen
                        AND l.cagente = lc.cagente
                        AND l.cempres = lc.cempres
                        AND l.sextmovrec = e1.sextmovrec
                        AND l.sextmovrec = (SELECT MAX(l2.sextmovrec)
                                              FROM ext_liquidalin l2, liquidacab lc2
                                             WHERE l2.nliqmen = lc2.nliqmen
                                               AND l2.cagente = lc2.cagente
                                               AND l2.cempres = lc2.cempres
                                               AND l2.ccompani = e1.ccompani
                                               AND l2.num_rec = e1.nreccia
                                               AND lc2.cestado = 1)
                        AND lc.cagente = pcagente
                        AND e1.csitrec = 2
                        AND lc.cestado = 1))
            AND r.cempres = pcempres
            AND e.ccolabo = pcageind
            AND e.sextmovrec = (SELECT MAX(e5.sextmovrec)
                                  FROM ext_recibos e5
                                 WHERE e5.icombru <> 0
                                   AND e5.ccolabo = pcageind
                                   AND e5.nreccia = e.nreccia
                                   AND e5.fmovrec <= pfecliq)
         UNION
         SELECT e.nreccia num_rec, e.sextmovrec, 2 cgescob, e.iprinet, e.icomind icomisi,
                e.itotrec itotalr, 0 itotimp, iretind icomret,
                DECODE(e.csitrec, 2, 20, 10) cestrec, e.ccompani, e.ctiprec
           FROM ext_recibos e, productos p, codiram r, ext_liquidalin l, liquidacab lc
          WHERE p.sproduc = e.sproduc
            AND r.cramo = p.cramo
            AND l.ccompani = e.ccompani
            AND l.num_rec = e.nreccia
            AND l.nliqmen = lc.nliqmen
            AND l.cagente = lc.cagente
            AND l.cempres = lc.cempres
            AND e.icombru <> 0
            AND e.csitrec = 2   --Anulado
            AND r.cempres = 10
            AND e.ccolabo = pcageind
            AND l.sextmovrec <> e.sextmovrec
            AND e.sextmovrec = (SELECT MAX(e5.sextmovrec)
                                  FROM ext_recibos e5
                                 WHERE e5.icombru <> 0
                                   AND e5.ccolabo = pcageind
                                   AND e5.nreccia = e.nreccia
                                   AND e5.fmovrec <= pfecliq)
            AND EXISTS(
                  SELECT l2.*   --que la última vegada que el rebut hagi estat liquidat sigui un cobrament
                    FROM ext_liquidalin l2, ext_recibos e2, liquidacab lc2
                   WHERE e2.nreccia = e.nreccia
                     AND e2.ccompani = e.ccompani
                     AND l2.ccompani = e2.ccompani
                     AND l2.num_rec = e2.nreccia
                     AND l2.nliqmen = lc2.nliqmen
                     AND l2.cagente = lc2.cagente
                     AND l2.cempres = lc2.cempres
                     AND l2.sextmovrec = e2.sextmovrec
                     AND l2.sextmovrec = (SELECT MAX(l3.sextmovrec)
                                            FROM ext_liquidalin l3, liquidacab lc3
                                           WHERE l3.ccompani = e2.ccompani
                                             AND l3.num_rec = e2.nreccia
                                             AND lc3.nliqmen = l3.nliqmen
                                             AND lc3.cagente = l3.cagente
                                             AND lc3.cempres = l3.cempres
                                             AND lc3.cestado = 1)
                     AND lc2.cagente = pcagente
                     AND e2.csitrec = 1
                     AND lc2.cestado = 1);

      v_nliqlin      NUMBER := 0;
      v_signo        NUMBER := 1;
      v_icomisi      NUMBER := 0;
      v_cmoncia      NUMBER;   -- 24. 0024803 26/11/2012
   BEGIN
      v_pasexec := 100;
      -- buscamos el nliqmen del agente
      pnliqmen := f_get_nliqmen(pcempres, pcagente, pfecliq, psproces, pmodo);

      SELECT NVL(MAX(nliqlin), 0)
        INTO v_nliqlin
        FROM ext_liquidalin
       WHERE cempres = pcempres
         AND nliqmen = pnliqmen
         AND cagente = pcagente;

      v_pasexec := 102;

      -- 24. 0024803 26/11/2012 - Inicio
      IF NVL(pac_parametros.f_parempresa_n(pcempres, 'MULTIMONEDA'), 0) = 1 THEN
         v_cmoncia := pac_parametros.f_parempresa_n(pcempres, 'MONEDAEMP');
      END IF;

      v_pasexec := 103;

      -- 24. 0024803 26/11/2012 - Fin
      FOR rc IN c_rec LOOP   -- Procesamos los recibos
         v_pasexec := 105;

         IF rc.cgescob = 3 THEN
            v_pasexec := 110;
            v_icomisi :=(-rc.itotalr + rc.icomisi - rc.itotimp);
         ELSE
            v_pasexec := 115;
            v_icomisi := rc.icomisi - rc.itotimp;
         END IF;

         v_pasexec := 120;

         IF rc.cestrec = 20 THEN
            v_signo := -1;
         ELSE
            v_signo := 1;
         END IF;

         --47.0 AQ Start Bug 0033115
         IF rc.ctiprec IN(9, 13) THEN
            v_signo := v_signo * -1;
         END IF;

         v_pasexec := 125;
         v_nliqlin := v_nliqlin + 1;
         v_pasexec := 130;

         INSERT INTO ext_liquidalin
                     (cempres, nliqmen, cagente, nliqlin, num_rec, ccompani,
                      sextmovrec, itotimp,
                      itotalr,
                      iprinet,
                      icomisi,
                      iretenccom, isobrecomision, iretencsobrecom, iconvoleducto,
                      iretencoleoducto, ctipoliq, sproliq)
              VALUES (pcempres, pnliqmen, pcagente, v_nliqlin, rc.num_rec, rc.ccompani,
                      rc.sextmovrec,
                                    -- 24. 0024803 26/11/2012 - Inicio
                                    -- f_round(NVL(rc.itotimp, 0) * v_signo),
                                    -- f_round(NVL(rc.itotalr, 0) * v_signo),
                                    -- f_round(NVL(rc.iprinet, 0) * v_signo),
                                    -- f_round(NVL(v_icomisi, 0) * v_signo),
                                    -- f_round(NVL(rc.icomret, 0) * v_signo),
                                    f_round(NVL(rc.itotimp, 0) * v_signo, v_cmoncia),
                      f_round(NVL(rc.itotalr, 0) * v_signo, v_cmoncia),
                      f_round(NVL(rc.iprinet, 0) * v_signo, v_cmoncia),
                      f_round(NVL(v_icomisi, 0) * v_signo, v_cmoncia),
                      f_round(NVL(rc.icomret, 0) * v_signo, v_cmoncia),
                                                                       -- 24. 0024803 26/11/2012 - Fin
                      NULL, NULL, NULL,
                      NULL, NULL, psproces);
      END LOOP;

      v_pasexec := 140;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param,
                     SQLCODE || ' ' || SQLERRM);
         RETURN 108953;
   END f_set_ext_recibos_liq_ind;

-- fin Bug 0019689 - JMC - 18/10/2011
   -- ini Bug 0019689 - JMC - 18/10/2011
    /*************************************************************************
       Función que inserta los recibos pendientes de liquidar en liquidalin
       para comisiones indirectas
       RETURN NUMBER
   *************************************************************************/
   FUNCTION f_set_recibos_liq_ind(
      pcempres IN NUMBER,
      pcagente IN NUMBER,
      pfecliq IN DATE,
      pcageind IN NUMBER,
      psproces IN NUMBER,
      pmodo IN NUMBER,
      pnliqmen OUT NUMBER,
      psmovagr IN NUMBER DEFAULT NULL,   -- 21. 0022753
      pnrecibo IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      v_object       VARCHAR2(500) := 'PAC_LIQUIDA.F_SET_RECIBOS_LIQ_IND';
      v_param        VARCHAR2(500)
         := 'params - pcempres :' || pcempres || ' pcagente : ' || pcagente || ' pfecliq : '
            || pfecliq || ' pcageind : ' || pcageind;
      v_pasexec      NUMBER(5) := 1;
      num_err        NUMBER := 0;
      -- ini bug 27043 jmf 10-09-2013
      v_p_diasliq    NUMBER := pac_parametros.f_parinstalacion_n('DIASLIQ');
      v_p_calc_comind NUMBER := NVL(pac_parametros.f_parempresa_n(pcempres, 'CALC_COMIND'), 0);
      v_cmultimon    NUMBER := NVL(pac_parametros.f_parempresa_n(pcempres, 'MULTIMONEDA'), 0);
      v_cmoncia      NUMBER := pac_parametros.f_parempresa_n(pcempres, 'MONEDAEMP');
      d_hoytrunc     DATE := TRUNC(f_sysdate);

      -- Bug 21230 - APD - 16/04/2012 - se añade el parametro ppcageind
      -- se sustituye pcageind por ppcageind
      CURSOR c_rec(ppcageind IN NUMBER) IS
         SELECT r.nrecibo, r.cagente, r.sseguro, r.cempres, m.smovrec, m.fefeadm, r.fefecto,
                r.femisio, s.npoliza, s.cramo, r.cgescob, s.sproduc,
                v.iprinet + v.icednet iprinet, vm.iprinet + vm.icednet iprinet_moncia,
                v.icombrui + v.icedcbr icomisi, vm.icombrui + vm.icedcbr icomisi_moncia,
                v.icomreti + v.icedcrt icomret, vm.icomreti + vm.icedcrt icomret_moncia,
                v.itotalr itotalr, vm.itotalr itotalr_moncia, v.itotimp itotimp,
                vm.itotimp itotimp_moncia, 0 cestrec, r.ctiprec,   -- 16. 0021164: LCOL_A001: Proceso de liquidación, ajuste para los extornos
                v.iconvoleoducto iconvoleoducto,
                vm.iconvoleoducto iconvoleoducto_moncia   -- Bug 25988/145805 - 06/06/2013 - AMC
           FROM movrecibo m, recibos r, seguros s, vdetrecibos v, vdetrecibos_monpol vm
          WHERE m.nrecibo = r.nrecibo
            AND s.sseguro = r.sseguro
            AND r.nrecibo = v.nrecibo
            AND v.nrecibo = vm.nrecibo(+)
            AND m.smovagr = NVL(psmovagr, m.smovagr)   -- 21. 0022753
            AND m.nrecibo = NVL(pnrecibo, m.nrecibo)
            AND m.smovrec = (SELECT MAX(smovrec)   --agafem el màxim moviment del rebut
                               FROM movrecibo mv
                              WHERE mv.nrecibo = r.nrecibo
                                AND mv.fmovfin IS NULL)
            AND(((v.icombru <> 0
                  OR v.icombrui <> 0)
                 AND r.cgescob IS NULL)
                OR(r.cgescob = 3))   --rebut amb comisions o gestió broker
            AND m.cestrec = 1   --Cobrat
            AND(NOT EXISTS(SELECT '*'   --que el rebut no s'hagi liquidat mai
                             FROM liquidalin l, liquidacab lc
                            WHERE r.nrecibo = l.nrecibo
                              AND l.nliqmen = lc.nliqmen
                              AND l.cagente = lc.cagente
                              AND l.cempres = lc.cempres
                              AND lc.cagente = NVL(pcagente, r.cagente)
                              AND lc.cestado = 1)
                OR EXISTS(
                     SELECT '*'   --que la última vegada que el rebut hagi estat liquidat sigui un descobrament
                       FROM liquidalin l, movrecibo m, liquidacab lc
                      WHERE l.nrecibo = r.nrecibo
                        AND m.smovrec = l.smovrec
                        --33.0 MMM -- 0027518: LCOL_PROD-0008271: LIBELULA IAXIS- ERROR COMISIONES DE AHORRO - NOTA 0149187 - Inicio
                        --AND l.smovrec = (SELECT MAX(l2.smovrec)
                        --                   FROM liquidalin l2
                        --                  WHERE l2.nrecibo = r.nrecibo)
                        AND l.smovrec = (SELECT MAX(l2.smovrec)
                                           FROM liquidalin l2, liquidacab lc2
                                          WHERE l2.nrecibo = l.nrecibo
                                            AND lc2.cagente = l2.cagente
                                            AND lc2.nliqmen = l2.nliqmen
                                            AND lc2.cestado = 1)
                        --33.0 MMM -- 0027518: LCOL_PROD-0008271: LIBELULA IAXIS- ERROR COMISIONES DE AHORRO - NOTA 014918 Fin
                        AND((m.cestrec = 0
                             AND m.cestant = 1)
                            OR m.cestrec = 2)
                        --AND l.smovrec <> m.smovrec -- MMM. 31. BUG 0027518: LCOL_PROD-0008271: LIBELULA IAXIS- ERROR COMISIONES DE AHORRO
                        AND l.nliqmen = lc.nliqmen
                        AND l.cagente = lc.cagente
                        AND l.cempres = lc.cempres
                        AND lc.cagente = NVL(pcagente, r.cagente)
                        AND lc.cestado = 1))
            AND r.cempres = pcempres
            AND r.cagente = ppcageind
            AND NOT EXISTS(SELECT 1
                             FROM age_corretaje c
                            WHERE c.sseguro = s.sseguro
                              AND c.nmovimi = (SELECT MAX(m.nmovimi)
                                                 FROM age_corretaje m
                                                WHERE m.sseguro = s.sseguro))
            AND r.cestaux = 0   -- Bug 26022 - APD - 11/02/2013
            AND((r.cestimp <> 5)
                OR   --no domiciliat
                  (SELECT NVL(MAX(1), 0)
                     FROM DUAL
                    WHERE m.fmovini > r.fefecto
                      AND d_hoytrunc >=(m.fmovini + v_p_diasliq)) = 1
                OR (SELECT NVL(MAX(1), 0)
                      FROM DUAL
                     WHERE m.fmovini <= r.fefecto
                       AND d_hoytrunc >=(r.fefecto + v_p_diasliq)) = 1)
         UNION ALL
         SELECT r.nrecibo, lq.cagente, r.sseguro, r.cempres, m.smovrec, m.fefeadm, r.fefecto,
                r.femisio, s.npoliza, s.cramo, r.cgescob, s.sproduc, ABS(lq.iprinet),
                ABS(lq.iprinet_moncia), ABS(lq.icomisi), ABS(lq.icomisi_moncia),
                ABS(lq.iretenccom) icomret, ABS(lq.iretenccom_moncia) icomret_moncia,
                ABS(lq.itotalr), ABS(lq.itotalr_moncia), ABS(lq.itotimp),
                ABS(lq.itotimp_moncia), 20 cestrec, r.ctiprec,   -- 16. 0021164: LCOL_A001: Proceso de liquidación, ajuste para los extornos
                ABS(lq.iconvoleducto) iconvoleoducto,
                ABS(lq.iconvoleod_moncia) iconvoleoducto_moncia   -- Bug 25988/145805 - 06/06/2013 - AMC
           FROM movrecibo m, recibos r, seguros s,   --JLV 04/06/2013 manca join contra liquidacab.
                                                  liquidalin lq,
                liquidacab lb   --com que es moviment de "descobro" anem contra liquidalin
          WHERE s.sseguro = r.sseguro
            AND r.nrecibo = m.nrecibo
            AND m.nrecibo = lq.nrecibo
            AND lq.nliqmen = lb.nliqmen
            AND lq.cempres = lb.cempres
            AND lq.cagente = lb.cagente
            AND lb.cestado = 1   --JLV 06/06/2013 bug 7375
            AND m.smovrec <>
                  lq.smovrec   -- que el moviment que estem tractant no sigui el moviment liquidat
            AND m.smovagr = NVL(psmovagr, m.smovagr)   -- 21. 0022753
            AND m.nrecibo = NVL(pnrecibo, m.nrecibo)
            AND m.smovrec = (SELECT MAX(smovrec)   --agafem el màxim moviment del rebut
                               FROM movrecibo mv
                              WHERE mv.nrecibo = r.nrecibo
                                AND mv.fmovfin IS NULL)
            AND((m.cestrec = 0
                 AND cestant = 1)
                OR(m.cestrec = 2))   -- que sigui un descobrament
            AND EXISTS(SELECT '*'   -- que la última liquidació d'aquest rebut sigui un cobrament
                         FROM liquidalin l, movrecibo m, liquidacab lc
                        WHERE l.smovrec = m.smovrec
                          AND l.smovrec = (SELECT MAX(l2.smovrec)
                                             FROM liquidalin l2, liquidacab l3
                                            WHERE l2.nrecibo = r.nrecibo
                                              AND l2.cempres = l3.cempres
                                              AND l2.cagente = l3.cagente
                                              AND l2.nliqmen = l3.nliqmen
                                              AND l3.ctipoliq = 0
                                              AND l3.cestado = 1)
                          AND m.cestrec = 1
                          AND l.nliqmen = lc.nliqmen
                          AND l.cempres = lc.cempres
                          AND l.cagente = lc.cagente
                          AND lc.cagente = NVL(pcagente, lq.cagente)
                          -- hem de tirar enrera el que hem donat per cobrat
                          -- independentment de si la liquidació ha sigut de comisions (1)
                          -- o d'autoliquidació (import(2) o comisions (3))
                          -- quins imports tirem enrera se soluciona a la select
                          AND lc.cestado = 1)
            AND r.cestaux = 0   -- Bug 26022 - APD - 11/02/2013
                             ;

      -- fin bug 27043 jmf 10-09-2013
      v_nliqlin      NUMBER := 0;
      v_signo        NUMBER := 1;
      v_icomisi      NUMBER := 0;
      v_icomisi_moncia NUMBER := 0;
      v_itasa        eco_tipocambio.itasa%TYPE;
      v_fcambio      DATE;
      vcageind       NUMBER;   -- Bug 21230 - APD - 21/02/2012
      vcagente       NUMBER;   -- Bug 21230 - APD - 21/02/2012
      -- Bug 0022346 - JGR - Inicio
      v_cobro_parc   NUMBER
                        := NVL(pac_parametros.f_parempresa_n(pcempres, 'LIQ_COBRO_PARCIAL'), 0);
   -- Bug 0022346 - JGR - Fin
   BEGIN
      -- Bug 21230 - APD - 15/04/2012 - segun el calculo de la comision
      -- indirecta, los recibos se deben buscar del agente o del agente indirecto
      IF v_p_calc_comind = 2 THEN
         -- Por agente indirecto y modalidad indirecta en el cuadro asignado al agente
         vcageind := pcageind;
      ELSIF v_p_calc_comind in (1,3) THEN
         -- por cuadros de comisión indirecta pero modalidad directa
         vcageind := pcagente;
      ELSE
         vcageind := NULL;
      END IF;

      -- fin Bug 21230 - APD - 15/04/2012
      IF vcageind IS NOT NULL THEN
         -- Bug 21230 - APD - 15/04/2012 - segun el calculo de la comision
         -- indirecta, la liquidacion del agente se hace al agente o al agente indirecto
         IF v_p_calc_comind = 2 THEN
            vcagente := pcagente;
         ELSIF v_p_calc_comind in (1,3) THEN
            vcagente := pcageind;
         END IF;

         -- Buscamos el nliqmen del cagente de la liqui.
         pnliqmen := f_get_nliqmen(pcempres, vcagente, pfecliq, psproces, pmodo);

         -- buscamos el nliqlin
            -- Ini BUG 21606 - 26/03/2012 - JMC
         SELECT NVL(MAX(nliqlin), 0)
           INTO v_nliqlin
           FROM liquidalin
          WHERE cempres = pcempres
            AND nliqmen = pnliqmen
            AND cagente = vcagente;

         -- Ini BUG 21606 - 26/03/2012 - JMC
                             --
         -- Bug 21230 - APD - 15/04/2012 - se le pasa el agente indirecto
         -- al cursor
         FOR rc IN c_rec(vcageind) LOOP   -- Procesamos los recibos
            -- 22. 0022346: LCOL_A003-Cobro parcial de los recibos Fase 2 - Inicio
            -- Descartar los recibos con cobros parciales
            IF v_cobro_parc = 0
               OR pac_adm_cobparcial.f_get_importe_cobro_parcial(rc.nrecibo, NULL, NULL) = 0 THEN
               -- 22. 0022346: LCOL_A003-Cobro parcial de los recibos Fase 2 - Fin
                  -- Bug 18843/91812 - 06/09/2011 - AMC
               IF rc.cgescob = 3 THEN
                  v_icomisi :=(-rc.itotalr + rc.icomisi);
                  v_icomisi_moncia :=(-rc.itotalr_moncia + rc.icomisi_moncia);
               ELSE
                  v_icomisi := rc.icomisi;
                  v_icomisi_moncia := rc.icomisi_moncia;
               END IF;

               -- Fi Bug 18843/91812 - 06/09/2011 - AMC
               IF rc.cestrec = 20 THEN
                  v_signo := -1;
               ELSE
                  v_signo := 1;
               END IF;

               --47.0 AQ Start Bug 0033115
               IF rc.ctiprec IN(9, 13) THEN
                  v_signo := v_signo * -1;
               END IF;

               --Fi 47.0 AQ

               -- BUG 18423 - 02/11/2011 - JMP - LCOL000 - Multimoneda
               IF v_cmultimon = 1 THEN
                  num_err := pac_oper_monedas.f_datos_contraval(NULL, rc.nrecibo, NULL,
                                                                f_sysdate, 2, v_itasa,
                                                                v_fcambio);
               END IF;

               -- FIN BUG 18423 - 02/11/2011 - JMP - LCOL000 - Multimoneda
               BEGIN
                  -- Aumentamos el nliqlin
                  v_nliqlin := v_nliqlin + 1;

                  INSERT INTO liquidalin
                              (cempres, nliqmen, cagente, nliqlin, nrecibo,
                               smovrec, itotimp,
                               itotalr, iprinet,
                               icomisi, iretenccom, isobrecomision,
                               iretencsobrecom, iconvoleducto, iretencoleoducto, ctipoliq,
                               -- BUG 18423 - 02/11/2011 - JMP - LCOL000 - Multimoneda
                               itotimp_moncia,
                               itotalr_moncia,
                               iprinet_moncia,
                               icomisi_moncia,
                               iretenccom_moncia, isobrecom_moncia, iretencscom_moncia,
                               iconvoleod_moncia, iretoleod_moncia,
                               fcambio
                                      -- FIN BUG 18423 - 02/11/2011 - JMP - LCOL000 - Multimoneda
                              )
                       VALUES (rc.cempres, pnliqmen, vcagente, v_nliqlin, rc.nrecibo,
                               rc.smovrec, NVL(rc.itotimp, 0) * v_signo,
                               NVL(rc.itotalr, 0) * v_signo, NVL(rc.iprinet, 0) * v_signo,
                               NVL(v_icomisi, 0) * v_signo, NVL(rc.icomret, 0) * v_signo, NULL,
                               NULL, NULL, NULL, NULL,
                               -- BUG 18423 - 02/11/2011 - JMP - LCOL000 - Multimoneda
                               f_round(rc.itotimp_moncia * v_signo, v_cmoncia),
                               f_round(rc.itotalr_moncia * v_signo, v_cmoncia),
                               f_round(rc.iprinet_moncia * v_signo, v_cmoncia),
                               f_round(v_icomisi_moncia * v_signo, v_cmoncia),
                               f_round(rc.icomret_moncia * v_signo, v_cmoncia), NULL, NULL,
                               NULL, NULL,
                               DECODE(v_cmultimon, 0, NULL, NVL(v_fcambio, f_sysdate))
                                                                                      -- FIN BUG 18423 - 02/11/2011 - JMP - LCOL000 - Multimoneda
                              );

                  -- Bug 0029334 - JMF - 11/12/2013
                  IF v_p_calc_comind In (1,3) THEN
                     -- por cuadros de comisión indirecta pero modalidad directa
                     num_err := f_crea_liquidalindet_ind(pnliqmen, vcagente, v_nliqlin,
                                                         rc.cempres, rc.nrecibo,
                                                         SIGN(NVL(v_icomisi, 0) * v_signo),
                                                         pfecliq, NULL, rc.smovrec);
                  END IF;
               EXCEPTION
                  WHEN DUP_VAL_ON_INDEX THEN
                     p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param,
                                 '------------->  DUP VAL ON INDEX  .- v_nliqlin = '
                                 || ' cempres ' || rc.cempres || ' nliqmen ' || pnliqmen
                                 || ' cagente = ' || vcagente || ' nliqlin  ' || v_nliqlin);
                     RETURN 108953;
               END;
            -- fin Bug 21230 - APD - 15/04/2012
            END IF;   -- 22. 0022346: LCOL_A003-Cobro parcial de los recibos Fase 2
         END LOOP;
      END IF;

      RETURN num_err;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
         RETURN 108953;
   END f_set_recibos_liq_ind;

-- fin Bug 0019689 - JMC - 18/10/2011

   -- ini Bug 27043 - JMF - 10/09/2013
    /*************************************************************************
       Función que inserta los recibos pendientes de liquidar en liquidalin
       para comisiones indirectas
       Caso para CALC_COMIND 1 : El agente indirecto esta en detrecibos
       RETURN NUMBER
   *************************************************************************/
   FUNCTION f_set_recibos_liq_ind1(
      pcempres IN NUMBER,
      pcagente IN NUMBER,
      pfecliq IN DATE,
      pcageind IN NUMBER,
      psproces IN NUMBER,
      pmodo IN NUMBER,
      pnliqmen OUT NUMBER,
      psmovagr IN NUMBER DEFAULT NULL,   -- 21. 0022753
      pnrecibo IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      v_object       VARCHAR2(500) := 'PAC_LIQUIDA.F_SET_RECIBOS_LIQ_IND1';
      v_param        VARCHAR2(500)
         := 'params - pcempres :' || pcempres || ' pcagente : ' || pcagente || ' pfecliq : '
            || pfecliq || ' pcageind : ' || pcageind;
      v_pasexec      NUMBER(5) := 1;
      num_err        NUMBER := 0;
      -- ini Bug 27043 - JMF - 10/09/2013
      v_p_diasliq    NUMBER := pac_parametros.f_parinstalacion_n('DIASLIQ');
      v_p_calc_comind NUMBER := NVL(pac_parametros.f_parempresa_n(pcempres, 'CALC_COMIND'), 0);
      v_cmultimon    NUMBER := NVL(pac_parametros.f_parempresa_n(pcempres, 'MULTIMONEDA'), 0);
      v_cmoncia      NUMBER := pac_parametros.f_parempresa_n(pcempres, 'MONEDAEMP');
      -- Bug Ini 0027043/157331: AFM - 30/10/2013
      v_dd_cambio    NUMBER
                      := NVL(pac_parametros.f_parempresa_n(pcempres, 'COMIS_DD_CAMB_LIQ'), 99);
      -- Bug Fin 0027043/157331: AFM - 30/10/2013
      d_hoytrunc     DATE := TRUNC(f_sysdate);

      -- Bug 21230 - APD - 16/04/2012 - se añade el parametro ppcageind
      -- se sustituye pcageind por ppcageind
      CURSOR c_rec(ppcageind IN NUMBER) IS
         SELECT r.nrecibo, d.cageven, r.sseguro, r.cempres, m.smovrec, m.fefeadm, r.fefecto,
                r.femisio, s.npoliza, s.cramo, r.cgescob, s.sproduc,
                v.iprinet + v.icednet iprinet, vm.iprinet + vm.icednet iprinet_moncia,
                v.icombrui + v.icedcbr icomisi, vm.icombrui + vm.icedcbr icomisi_moncia,
                v.icomreti + v.icedcrt icomret, vm.icomreti + vm.icedcrt icomret_moncia,
                v.itotalr itotalr, vm.itotalr itotalr_moncia, v.itotimp itotimp,
                vm.itotimp itotimp_moncia, 0 cestrec, r.ctiprec,   -- 16. 0021164: LCOL_A001: Proceso de liquidación, ajuste para los extornos
                v.iconvoleoducto iconvoleoducto,
                vm.iconvoleoducto iconvoleoducto_moncia   -- Bug 25988/145805 - 06/06/2013 - AMC
           FROM movrecibo m,
                recibos r,
                seguros s,
                vdetrecibos v,
                vdetrecibos_monpol vm,
                (SELECT   d1.nrecibo, MAX(d1.cageven) cageven
                     FROM detrecibos d1
                    WHERE d1.cconcep = 17
                 GROUP BY d1.nrecibo) d
          WHERE m.nrecibo = r.nrecibo
            AND s.sseguro = r.sseguro
            AND r.nrecibo = v.nrecibo
            AND v.nrecibo = vm.nrecibo(+)
            AND d.nrecibo = r.nrecibo
            AND m.smovagr = NVL(psmovagr, m.smovagr)   -- 21. 0022753
            AND m.nrecibo = NVL(pnrecibo, m.nrecibo)
            AND m.smovrec = (SELECT MAX(smovrec)   --agafem el màxim moviment del rebut
                               FROM movrecibo mv
                              WHERE mv.nrecibo = r.nrecibo
                                AND mv.fmovfin IS NULL)
            AND(((v.icombru <> 0
                  OR v.icombrui <> 0)
                 AND r.cgescob IS NULL)
                OR(r.cgescob = 3))   --rebut amb comisions o gestió broker
            AND m.cestrec = 1   --Cobrat
            AND(NOT EXISTS(SELECT '*'   --que el rebut no s'hagi liquidat mai
                             FROM liquidalin l, liquidacab lc
                            WHERE r.nrecibo = l.nrecibo
                              AND l.nliqmen = lc.nliqmen
                              AND l.cagente = lc.cagente
                              AND l.cempres = lc.cempres
                              AND lc.cagente = d.cageven
                              AND lc.cestado = 1)
                OR EXISTS(
                     SELECT '*'   --que la última vegada que el rebut hagi estat liquidat sigui un descobrament
                       FROM liquidalin l, movrecibo m, liquidacab lc
                      WHERE l.nrecibo = r.nrecibo
                        AND m.smovrec = l.smovrec
                        --33.0 MMM -- 0027518: LCOL_PROD-0008271: LIBELULA IAXIS- ERROR COMISIONES DE AHORRO - NOTA 0149187 - Inicio
                        --AND l.smovrec = (SELECT MAX(l2.smovrec)
                        --                   FROM liquidalin l2
                        --                  WHERE l2.nrecibo = r.nrecibo)
                        AND l.smovrec = (SELECT MAX(l2.smovrec)
                                           FROM liquidalin l2, liquidacab lc2
                                          WHERE l2.nrecibo = l.nrecibo
                                            AND lc2.cagente = l2.cagente
                                            AND lc2.nliqmen = l2.nliqmen
                                            AND lc2.cestado = 1)
                        --33.0 MMM -- 0027518: LCOL_PROD-0008271: LIBELULA IAXIS- ERROR COMISIONES DE AHORRO - NOTA 014918 Fin
                        AND((m.cestrec = 0
                             AND m.cestant = 1)
                            OR m.cestrec = 2)
                        --AND l.smovrec <> m.smovrec -- MMM. 31. BUG 0027518: LCOL_PROD-0008271: LIBELULA IAXIS- ERROR COMISIONES DE AHORRO
                        AND l.nliqmen = lc.nliqmen
                        AND l.cagente = lc.cagente
                        AND l.cempres = lc.cempres
                        AND lc.cagente = d.cageven
                        AND lc.cestado = 1))
            AND r.cempres = pcempres
            AND r.cagente = NVL(ppcageind, r.cagente)   -- Bug 0027043/157331: AFM - 30/10/2013
            AND NOT EXISTS(SELECT 1
                             FROM age_corretaje c
                            WHERE c.sseguro = s.sseguro
                              AND c.nmovimi = (SELECT MAX(m.nmovimi)
                                                 FROM age_corretaje m
                                                WHERE m.sseguro = s.sseguro))
            AND r.cestaux = 0   -- Bug 26022 - APD - 11/02/2013
            AND((r.cestimp <> 5)
                OR   --no domiciliat
                  (SELECT NVL(MAX(1), 0)
                     FROM DUAL
                    WHERE m.fmovini > r.fefecto
                      AND d_hoytrunc >=(m.fmovini + v_p_diasliq)) = 1
                OR (SELECT NVL(MAX(1), 0)
                      FROM DUAL
                     WHERE m.fmovini <= r.fefecto
                       AND d_hoytrunc >=(r.fefecto + v_p_diasliq)) = 1)
         UNION ALL
         SELECT r.nrecibo, lq.cagente cageven, r.sseguro, r.cempres, m.smovrec, m.fefeadm,
                r.fefecto, r.femisio, s.npoliza, s.cramo, r.cgescob, s.sproduc,
                ABS(lq.iprinet), ABS(lq.iprinet_moncia), ABS(lq.icomisi),
                ABS(lq.icomisi_moncia), ABS(lq.iretenccom) icomret,
                ABS(lq.iretenccom_moncia) icomret_moncia, ABS(lq.itotalr),
                ABS(lq.itotalr_moncia), ABS(lq.itotimp), ABS(lq.itotimp_moncia), 20 cestrec,
                r.ctiprec,   -- 16. 0021164: LCOL_A001: Proceso de liquidación, ajuste para los extornos
                          ABS(lq.iconvoleducto) iconvoleoducto,
                ABS(lq.iconvoleod_moncia) iconvoleoducto_moncia   -- Bug 25988/145805 - 06/06/2013 - AMC
           FROM movrecibo m, recibos r, seguros s,   --JLV 04/06/2013 manca join contra liquidacab.
                                                  liquidalin lq,
                liquidacab lb   --com que es moviment de "descobro" anem contra liquidalin
          WHERE s.sseguro = r.sseguro
            AND r.nrecibo = m.nrecibo
            AND m.nrecibo = lq.nrecibo
            AND lq.nliqmen = lb.nliqmen
            AND lq.cempres = lb.cempres
            AND lq.cagente = lb.cagente
            AND lb.cestado = 1   --JLV 06/06/2013 bug 7375
            AND m.smovrec <>
                  lq.smovrec   -- que el moviment que estem tractant no sigui el moviment liquidat
            AND m.smovagr = NVL(psmovagr, m.smovagr)   -- 21. 0022753
            AND m.nrecibo = NVL(pnrecibo, m.nrecibo)
            AND m.smovrec = (SELECT MAX(smovrec)   --agafem el màxim moviment del rebut
                               FROM movrecibo mv
                              WHERE mv.nrecibo = r.nrecibo
                                AND mv.fmovfin IS NULL)
            AND((m.cestrec = 0
                 AND cestant = 1)
                OR(m.cestrec = 2))   -- que sigui un descobrament
            AND EXISTS(SELECT '*'   -- que la última liquidació d'aquest rebut sigui un cobrament
                         FROM liquidalin l, movrecibo m, liquidacab lc
                        WHERE l.smovrec = m.smovrec
                          AND l.smovrec = (SELECT MAX(l2.smovrec)
                                             FROM liquidalin l2, liquidacab l3
                                            WHERE l2.nrecibo = r.nrecibo
                                              AND l2.cempres = l3.cempres
                                              AND l2.cagente = l3.cagente
                                              AND l2.nliqmen = l3.nliqmen
                                              AND l3.ctipoliq = 0
                                              AND l3.cestado = 1)
                          AND m.cestrec = 1
                          AND l.nliqmen = lc.nliqmen
                          AND l.cempres = lc.cempres
                          AND l.cagente = lc.cagente
                          AND lc.cagente = (SELECT MAX(dd.cageven)
                                              FROM detrecibos dd
                                             WHERE dd.cconcep = 17
                                               AND dd.nrecibo = r.nrecibo)
                          -- hem de tirar enrera el que hem donat per cobrat
                          -- independentment de si la liquidació ha sigut de comisions (1)
                          -- o d'autoliquidació (import(2) o comisions (3))
                          -- quins imports tirem enrera se soluciona a la select
                          AND lc.cestado = 1)
            AND r.cestaux = 0   -- Bug 26022 - APD - 11/02/2013
                             ;

      -- fin Bug 27043 - JMF - 10/09/2013
      v_nliqlin      NUMBER := 0;
      v_signo        NUMBER := 1;
      v_icomisi      NUMBER := 0;
      v_icomisi_moncia NUMBER := 0;
      v_itasa        eco_tipocambio.itasa%TYPE;
      v_fcambio      DATE;
      v_fechac       DATE;   -- Bug  27043/157331: AFM - 30/10/2013
      v_dd           CHAR(2);   -- Bug 27043/157331: AFM - 30/10/2013
      vcageind       NUMBER;   -- Bug 21230 - APD - 21/02/2012
      vcagente       NUMBER;   -- Bug 21230 - APD - 21/02/2012
      -- Bug 0022346 - JGR - Inicio
      v_cobro_parc   NUMBER
                        := NVL(pac_parametros.f_parempresa_n(pcempres, 'LIQ_COBRO_PARCIAL'), 0);
      -- Bug 0022346 - JGR - Fin
      vimpiprinet    NUMBER;
      vimpiprinet_monpol NUMBER;
      vimpicomisi    NUMBER;
      vimpicomisi_monpol NUMBER;
      vimpicomret    NUMBER;
      vimpicomret_monpol NUMBER;
      vimpitotalr    NUMBER;
      vimpitotalr_monpol NUMBER;
      vimpitotimp    NUMBER;
      vimpitotimp_monpol NUMBER;
   BEGIN
      -- Bug 21230 - APD - 15/04/2012 - segun el calculo de la comision
      -- indirecta, los recibos se deben buscar del agente o del agente indirecto

      -- por cuadros de comisión indirecta pero modalidad directa
      vcageind := pcagente;

      -- fin Bug 21230 - APD - 15/04/2012
      -- IF vcageind IS NOT NULL THEN       -- Bug Ini 0027043/157331: AFM - 30/10/2013
                           --
         -- Bug 21230 - APD - 15/04/2012 - se le pasa el agente indirecto
         -- al cursor
      FOR rc IN c_rec(vcageind) LOOP   -- Procesamos los recibos
         -- indirecta, caso 1, el agente viene en el cursor
         vcagente := rc.cageven;
         -- Buscamos el nliqmen del cagente de la liqui.
         pnliqmen := f_get_nliqmen(pcempres, vcagente, pfecliq, psproces, pmodo);

         -- buscamos el nliqlin
         -- Ini BUG 21606 - 26/03/2012 - JMC
         SELECT NVL(MAX(nliqlin), 0)
           INTO v_nliqlin
           FROM liquidalin
          WHERE cempres = pcempres
            AND nliqmen = pnliqmen
            AND cagente = vcagente;

         -- 22. 0022346: LCOL_A003-Cobro parcial de los recibos Fase 2 - Inicio
         -- Descartar los recibos con cobros parciales
         IF v_cobro_parc = 0
            OR pac_adm_cobparcial.f_get_importe_cobro_parcial(rc.nrecibo, NULL, NULL) = 0 THEN
            -- 22. 0022346: LCOL_A003-Cobro parcial de los recibos Fase 2 - Fin
               -- Bug 18843/91812 - 06/09/2011 - AMC
            IF rc.cgescob = 3 THEN
               v_icomisi :=(-rc.itotalr + rc.icomisi);
               v_icomisi_moncia :=(-rc.itotalr_moncia + rc.icomisi_moncia);
            ELSE
               v_icomisi := rc.icomisi;
               v_icomisi_moncia := rc.icomisi_moncia;
            END IF;

            -- Fi Bug 18843/91812 - 06/09/2011 - AMC
            IF rc.cestrec = 20 THEN
               v_signo := -1;
            ELSE
               v_signo := 1;
            END IF;

            -- BUG 18423 - 02/11/2011 - JMP - LCOL000 - Multimoneda
            IF v_cmultimon = 1 THEN
               -- Bug Ini 0027043/157331: AMF - 30/10/2013
               IF v_dd_cambio = 99 THEN   -- No hay dia de cambio
                  num_err := pac_oper_monedas.f_datos_contraval(NULL, rc.nrecibo, NULL,
                                                                f_sysdate, 2, v_itasa,
                                                                v_fcambio);
               ELSE   -- El día de cambio es uno concreto si la fecha liquidación es final de mes
                  IF pfecliq = LAST_DAY(pfecliq) THEN
                     v_fechac := pfecliq + v_dd_cambio;
                  ELSE
                     v_fechac := TRUNC(f_sysdate);
                  END IF;

                  --
                  num_err := pac_oper_monedas.f_datos_contraval(NULL, rc.nrecibo, NULL,
                                                                v_fechac, 2, v_itasa,
                                                                v_fcambio);
               END IF;
            -- Bug Fin 0027043/157331: AFM - 30/10/2013
            END IF;

            -- FIN BUG 18423 - 02/11/2011 - JMP - LCOL000 - Multimoneda
            BEGIN
               -- Aumentamos el nliqlin
               v_nliqlin := v_nliqlin + 1;

               -- Inicio Bug 32674 MMS 20141006
               IF NVL(pac_parametros.f_parempresa_n(pcempres, 'DETRECIBOS_FCAMBIO'), 0) = 1 THEN
                  num_err := f_valor_recaudo(rc.nrecibo, rc.smovrec, vimpiprinet,
                                             vimpiprinet_monpol, vimpicomisi,
                                             vimpicomisi_monpol, vimpicomret,
                                             vimpicomret_monpol, vimpitotalr,
                                             vimpitotalr_monpol, vimpitotimp,
                                             vimpitotimp_monpol);
               ELSE
                  vimpiprinet := NVL(rc.iprinet, 0) * v_signo;

                  SELECT f_round(DECODE(v_dd_cambio,
                                        99, rc.iprinet_moncia * v_signo,
                                        NVL(rc.iprinet, 0) * v_signo * v_itasa),
                                 v_cmoncia)
                    INTO vimpiprinet_monpol
                    FROM DUAL;

                  vimpicomisi := NVL(v_icomisi, 0) * v_signo;

                  SELECT f_round(DECODE(v_dd_cambio,
                                        99, v_icomisi_moncia * v_signo,
                                        NVL(v_icomisi, 0) * v_signo * v_itasa),
                                 v_cmoncia)
                    INTO vimpicomisi_monpol
                    FROM DUAL;

                  vimpicomret := NVL(rc.icomret, 0) * v_signo;

                  SELECT f_round(DECODE(v_dd_cambio,
                                        99, rc.icomret_moncia * v_signo,
                                        NVL(rc.icomret, 0) * v_signo * v_itasa),
                                 v_cmoncia)
                    INTO vimpicomret_monpol
                    FROM DUAL;

                  vimpitotalr := NVL(rc.itotalr, 0) * v_signo;

                  SELECT f_round(DECODE(v_dd_cambio,
                                        99, rc.itotalr_moncia * v_signo,
                                        NVL(rc.itotalr, 0) * v_signo * v_itasa),
                                 v_cmoncia)
                    INTO vimpitotalr_monpol
                    FROM DUAL;

                  vimpitotimp := NVL(rc.itotimp, 0) * v_signo;

                  SELECT f_round(DECODE(v_dd_cambio,
                                        99, rc.itotimp_moncia * v_signo,
                                        NVL(rc.itotimp, 0) * v_signo * v_itasa),
                                 v_cmoncia)
                    INTO vimpitotimp_monpol
                    FROM DUAL;
               END IF;

               -- Fin Bug 32674 MMS 20141006
               INSERT INTO liquidalin
                           (cempres, nliqmen, cagente, nliqlin, nrecibo, smovrec,
                            itotimp, itotalr, iprinet, icomisi, iretenccom,
                            isobrecomision, iretencsobrecom, iconvoleducto, iretencoleoducto,
                            ctipoliq,
                                     -- BUG 18423 - 02/11/2011 - JMP - LCOL000 - Multimoneda
                                     itotimp_moncia, itotalr_moncia, iprinet_moncia,
                            icomisi_moncia, iretenccom_moncia, isobrecom_moncia,
                            iretencscom_moncia, iconvoleod_moncia, iretoleod_moncia,
                            fcambio
                                   -- FIN BUG 18423 - 02/11/2011 - JMP - LCOL000 - Multimoneda
                           )
                    VALUES (rc.cempres, pnliqmen, vcagente, v_nliqlin, rc.nrecibo, rc.smovrec,
                            vimpitotimp, vimpitotalr, vimpiprinet, vimpicomisi, vimpicomret,   --Bug 32674 MMS 20141006
                            NULL, NULL, NULL, NULL,
                            NULL,
                                 -- BUG 18423 - 02/11/2011 - JMP - LCOL000 - Multimoneda
                                 -- Bug Ini 0027043/157331: AFM - 30/10/2013
                                 vimpitotimp_monpol, vimpitotalr_monpol, vimpiprinet_monpol,   -- Bug 32674 MMS 20141006
                            vimpicomisi_monpol, vimpicomret_monpol,   --Bug 32674 MMS 20141006
                                                                   -- Bug Fin 0027043/157331: AFM - 30/10/2013
                            NULL,
                            NULL, NULL, NULL,
                            DECODE(v_cmultimon, 0, NULL, NVL(v_fcambio, f_sysdate))
                                                                                   -- FIN BUG 18423 - 02/11/2011 - JMP - LCOL000 - Multimoneda
                           );

               -- Bug 0029334 - JMF - 11/12/2013
               IF v_p_calc_comind In (1,3) THEN
                  -- por cuadros de comisión indirecta pero modalidad directa
                  num_err := f_crea_liquidalindet_ind(pnliqmen, vcagente, v_nliqlin,
                                                      rc.cempres, rc.nrecibo,
                                                      SIGN(NVL(v_icomisi, 0) * v_signo),
                                                      pfecliq, NULL, rc.smovrec);
               END IF;
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param,
                              '------------->  DUP VAL ON INDEX  .- v_nliqlin = '
                              || ' cempres ' || rc.cempres || ' nliqmen ' || pnliqmen
                              || ' cagente = ' || vcagente || ' nliqlin  ' || v_nliqlin);
                  RETURN 108953;
            END;
         -- fin Bug 21230 - APD - 15/04/2012
         END IF;   -- 22. 0022346: LCOL_A003-Cobro parcial de los recibos Fase 2
      END LOOP;

      -- END IF;       -- Bug 0027043/157331: AFM - 30/10/2013
      RETURN num_err;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
         RETURN 108953;
   END f_set_recibos_liq_ind1;

   -- fin Bug 27043 - JMF - 10/09/2013

   /*******************************************************************************
   FUNCION PAC_LIQUIDA.F_SET_RECIBOS_PARCIAL_LIQ_IND1
   Inserta las comisiones indirectas de los recibos con pagos parciales pendientes
   de liquidar en las tablas de liquidaciones

   Caso para CALC_COMIND 1 : El agente indirecto esta en detrecibos

   Parámetros:
      param in pcempres   : código de la empresa
      param in pcagente   : Agente
      param in pfecliq    : Fecha liquidación (hasta la que incluyen movimientos)
      param in pcageind   : Agente indirecto
      param in psproces   : Código de todo el proceso de liquidación para todos los agentes
      param in pmodo      : Pmodo = 0 Real y 1 Previo
      param in psmovagr   : Secuencial de agrupación de recibos (movrecibo.smovagr)

      return: number un número con el id del error, en caso de que todo vaya OK, retornará un cero.
   ********************************************************************************/
   FUNCTION f_set_recibos_parcial_liq_ind1(
      pcempres IN NUMBER,
      pcagente IN NUMBER,
      pfecliq IN DATE,
      pcageind IN NUMBER,
      psproces IN NUMBER,
      pmodo IN NUMBER,
      pnliqmen OUT NUMBER,
      psmovagr IN NUMBER DEFAULT NULL,
      pnrecibo IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      v_object       VARCHAR2(500) := 'PAC_LIQUIDA.F_SET_RECIBOS_PARCIAL_LIQ_IND1';
      v_param        VARCHAR2(500)
         := 'params - pcempres :' || pcempres || ' pcagente : ' || pcagente || ' pfecliq : '
            || pfecliq || ' pcageind : ' || pcageind;
      v_pasexec      NUMBER(5) := 1;
      num_err        NUMBER := 0;
      --
      v_diasliq      NUMBER := NVL(pac_parametros.f_parinstalacion_n('DIASLIQ'), 0);
      v_p_fefeadm_fmovdia NUMBER
                         := NVL(pac_parametros.f_parempresa_n(pcempres, 'FEFEADM_FMOVDIA'), 0);
      v_p_calc_comind NUMBER := NVL(pac_parametros.f_parempresa_n(pcempres, 'CALC_COMIND'), 0);
      v_cmultimon    NUMBER := NVL(pac_parametros.f_parempresa_n(pcempres, 'MULTIMONEDA'), 0);
      v_cmoncia      NUMBER := pac_parametros.f_parempresa_n(pcempres, 'MONEDAEMP');
      -- Bug Ini 0027043/157331: AFM - 30/10/2013
      v_dd_cambio    NUMBER
                      := NVL(pac_parametros.f_parempresa_n(pcempres, 'COMIS_DD_CAMB_LIQ'), 99);
      -- Bug Fin 0027043/157331: AFM - 30/10/2013
      d_hoytrunc     DATE := TRUNC(f_sysdate);

      -- Bug 27043 - JMF - 10/09/2013: Rerforma select para optimizar
      -- Bug 21230 - APD - 16/04/2012 - se añade el parametro ppcageind
      -- se sustituye pcageind por ppcageind
      -- Bug 0027043 - JMF - 04/10/2013: Importes parciales mismo calculo que f_vdetrecibos
      CURSOR c_rec(ppcageind IN NUMBER) IS
         SELECT   r.nrecibo, e.cageven, r.sseguro, r.cempres, m.fefeadm, r.fefecto, r.femisio,
                  s.npoliza, s.cramo, r.cgescob, s.sproduc,
                  SUM(DECODE(dp.cconcep, 0, dp.iconcep, 50, dp.iconcep, 0)) iprinet,
                  SUM(DECODE(dp.cconcep,
                             0, dp.iconcep_monpol,
                             50, dp.iconcep_monpol,
                             0)) iprinet_moncia,
                  SUM(DECODE(dp.cconcep, 17, dp.iconcep, 61, dp.iconcep, 0)) icomisi,
                  SUM(DECODE(dp.cconcep,
                             17, dp.iconcep_monpol,
                             61, dp.iconcep_monpol,
                             0)) icomisi_moncia,
                  SUM(DECODE(dp.cconcep, 18, dp.iconcep, 62, dp.iconcep, 0)) icomret,
                  SUM(DECODE(dp.cconcep,
                             18, dp.iconcep_monpol,
                             62, dp.iconcep_monpol,
                             0)) icomret_moncia,
                  SUM(DECODE(dp.cconcep, 0, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 1, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 2, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 3, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 4, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 5, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 6, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 7, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 8, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 14, dp.iconcep, 0)
                      - DECODE(dp.cconcep, 13, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 86, dp.iconcep, 0)
                      -- it1totr
                      + DECODE(dp.cconcep, 50, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 51, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 52, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 53, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 54, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 55, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 56, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 57, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 58, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 64, dp.iconcep, 0)
                      - DECODE(dp.cconcep, 63, dp.iconcep, 0)
                      -- it2totr
                      + DECODE(dp.cconcep, 26, dp.iconcep, 0)
                                                             -- iocorec
                  ) itotalr,
                  SUM(DECODE(dp.cconcep, 0, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 1, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 2, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 3, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 4, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 5, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 6, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 7, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 8, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 14, dp.iconcep_monpol, 0)
                      - DECODE(dp.cconcep, 13, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 86, dp.iconcep_monpol, 0)
                      -- it1totr
                      + DECODE(dp.cconcep, 50, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 51, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 52, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 53, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 54, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 55, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 56, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 57, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 58, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 64, dp.iconcep_monpol, 0)
                      - DECODE(dp.cconcep, 63, dp.iconcep_monpol, 0)
                      -- it2totr
                      + DECODE(dp.cconcep, 26, dp.iconcep_monpol, 0)
                                                                    -- iocorec
                  ) itotalr_moncia,
                  (SUM(DECODE(dp.cconcep, 4, dp.iconcep, 0)
                       + DECODE(dp.cconcep, 5, dp.iconcep, 0)
                       + DECODE(dp.cconcep, 6, dp.iconcep, 0)
                       + DECODE(dp.cconcep, 7, dp.iconcep, 0)
                       + DECODE(dp.cconcep, 86, dp.iconcep, 0)
                       -- it1imp
                       + DECODE(dp.cconcep, 54, dp.iconcep, 0)
                       + DECODE(dp.cconcep, 55, dp.iconcep, 0)
                       + DECODE(dp.cconcep, 56, dp.iconcep, 0)
                       + DECODE(dp.cconcep, 57, dp.iconcep, 0)
                                                              -- it2imp
                   )) itotimp,
                  (SUM(DECODE(dp.cconcep, 4, dp.iconcep_monpol, 0)
                       + DECODE(dp.cconcep, 5, dp.iconcep_monpol, 0)
                       + DECODE(dp.cconcep, 6, dp.iconcep_monpol, 0)
                       + DECODE(dp.cconcep, 7, dp.iconcep_monpol, 0)
                       + DECODE(dp.cconcep, 86, dp.iconcep_monpol, 0)
                       -- it1imp
                       + DECODE(dp.cconcep, 54, dp.iconcep_monpol, 0)
                       + DECODE(dp.cconcep, 55, dp.iconcep_monpol, 0)
                       + DECODE(dp.cconcep, 56, dp.iconcep_monpol, 0)
                       + DECODE(dp.cconcep, 57, dp.iconcep_monpol, 0)
                                                                     -- it2imp
                   )) itotimp_moncia,
                  10 cestrec, d.smovrec, d.norden, d.iimporte
             FROM movrecibo m, recibos r, seguros s, detmovrecibo d, detrecibos e,
                  detmovrecibo_parcial dp
            WHERE m.nrecibo = r.nrecibo
              AND s.sseguro = r.sseguro
              AND e.nrecibo = r.nrecibo
              AND e.cconcep = 17
              AND m.smovagr = NVL(psmovagr, m.smovagr)   -- 21. 0022753
              AND m.nrecibo = NVL(pnrecibo, m.nrecibo)
              AND m.smovrec IN(SELECT MAX(x.smovrec)
                                 FROM movrecibo x
                                WHERE x.nrecibo = r.nrecibo
                                  AND x.cestrec = 0)
              AND((EXISTS(SELECT 1
                            FROM detmovrecibo_parcial dp2
                           WHERE dp2.smovrec = m.smovrec
                             AND dp2.cconcep = 17
                             AND NVL(dp2.iconcep, 0) <> 0)
                   AND r.cgescob IS NULL)
                  OR(r.cgescob = 3))   --rebut amb comisions o gestió broker
              AND NOT EXISTS(SELECT '*'   --que el rebut no s'hagi liquidat mai
                               FROM liquidalin l, liquidacab lc
                              WHERE l.nliqmen = lc.nliqmen
                                AND l.cagente = lc.cagente
                                AND l.cempres = lc.cempres
                                AND lc.cagente = e.cageven
                                AND l.smovrec = d.smovrec
                                AND l.norden = d.norden
                                AND lc.cestado = 1)
              --AND m.cestrec = 1   --Cobrat
              AND d.smovrec = m.smovrec
              AND r.cagente = NVL(ppcageind, r.cagente)
              AND DECODE(v_p_fefeadm_fmovdia, 1, TRUNC(m.fmovdia), TRUNC(m.fefeadm)) <= pfecliq
              AND DECODE(v_p_fefeadm_fmovdia, 1, TRUNC(d.fmovimi), TRUNC(d.fefeadm)) <= pfecliq
              AND r.cempres = pcempres
              AND r.cestaux = 0   -- Bug 26022 - APD - 11/02/2013
              AND((r.cestimp <> 5)   --no domiciliat
                  OR(r.cestimp = 5   --domiciliat
                     AND m.fmovini >
                           r.fefecto   --que la data del moviment de cobrat sigui més gran que la data d'efecte
                     -- que hagin passat els dies de gestió a partir de la data de movimient del movimient de cobrat
                     AND d_hoytrunc >=(m.fmovini + v_diasliq))
                  OR(r.cestimp = 5   --domiciliat
                     AND m.fmovini <=
                           r.fefecto   --que la data del movimient de cobrat sigui menor o igual que la data d'efecte
                     -- que hagin passat els dies de gestió a partir de la data de movimient del movimient de cobrat
                     AND d_hoytrunc >=(r.fefecto + v_diasliq)))
              AND dp.smovrec = m.smovrec
              AND dp.norden = d.norden
              AND dp.cgarant = e.cgarant
              AND dp.cconcep IN(0, 1, 2, 3, 4, 5, 6, 7, 8, 17, 18, 13, 14, 26, 43, 50, 51, 52,
                                53, 54, 55, 56, 57, 58, 61, 62, 63, 64, 86)
         GROUP BY r.nrecibo, e.cageven, r.sseguro, r.cempres, m.fefeadm, r.fefecto, r.femisio,
                  s.npoliza, s.cramo, r.cgescob, s.sproduc, 10, d.smovrec, d.norden,
                  d.iimporte
         ORDER BY nrecibo, norden;

      -- NO EXISTE DESCOBRO O ANULACIÓN EN COBROS PARCIALES (NO SE HAN DE BUSCAR ESTOS CASOS)
      -- PARA ANULAR UN COBRO PARCIAL SE COBRA LA TOTALIDAD DEL RECIBO Y SE
      -- GENERA UN RECIBO DE EXTORNO, COBRANDOSE AMBOS. POR LO QUE PARA LA
      -- LIQUIDACIÓN SOLO ES NECESARIO TENER EN CUENTA LOS COBROS.
      v_nliqlin      NUMBER := 0;
      v_signo        NUMBER := 1;
      v_icomisi      NUMBER := 0;
      v_icomisi_moncia NUMBER := 0;
      v_itasa        eco_tipocambio.itasa%TYPE;
      v_fcambio      DATE;
      vcageind       NUMBER;   -- Bug 21230 - APD - 21/02/2012
      vcagente       NUMBER;   -- Bug 21230 - APD - 21/02/2012
      -- Bug Ini 0027043/157331: AFM - 30/10/2013
      --v_factor       NUMBER;
      v_fechac       DATE;
      v_dd           CHAR(2);
      -- Bug Fin 0027043/157331: AFM - 30/10/2013
      -- 23. 0022346: LCOL_A003-Cobro parcial de los recibos Fase 2 - 0126249 - Inicio
      vitotimp_det   vdetrecibos.itotimp%TYPE;
      viprinet_det   vdetrecibos.iprinet%TYPE;
      vitotalr_det   vdetrecibos.itotalr%TYPE;
      viretenc_det   vdetrecibos.ireccon%TYPE;
      vicomisi_det   vdetrecibos.icombru%TYPE;
      vitotimp_liq   liquidalin.itotimp%TYPE;
      viprinet_liq   liquidalin.iprinet%TYPE;
      vitotalr_liq   liquidalin.itotalr%TYPE;
      viretenc_liq   liquidalin.iretenccom%TYPE;
      vicomisi_liq   liquidalin.icomisi%TYPE;
   -- 23. 0022346: LCOL_A003-Cobro parcial de los recibos Fase 2 - 0126249 - Fin
   BEGIN
      v_pasexec := 10;

      -- Bug 21230 - APD - 15/04/2012 - segun el calculo de la comision
      -- indirecta, los recibos se deben buscar del agente o del agente indirecto
      IF v_p_calc_comind = 2 THEN
         -- Por agente indirecto y modalidad indirecta en el cuadro asignado al agente
         vcageind := pcageind;
      ELSIF v_p_calc_comind in (1,3) THEN
         -- por cuadros de comisión indirecta pero modalidad directa
         vcageind := pcagente;
      ELSE
         vcageind := NULL;
      END IF;

      v_pasexec := 20;
      -- fin Bug 21230 - APD - 15/04/2012
      -- IF vcageind IS NOT NULL THEN       -- Bug 0027043/157331: AFM - 30/10/2013

      -- Bug 21230 - APD - 15/04/2012 - segun el calculo de la comision
      -- indirecta, la liquidacion del agente se hace al agente o al agente indirecto
      v_pasexec := 30;

      IF v_p_calc_comind = 2 THEN
         vcagente := pcagente;
      ELSIF v_p_calc_comind in (1,3) THEN
         vcagente := pcageind;
      END IF;

      -- Ini BUG 21606 - 26/03/2012 - JMC
                          --
      -- Bug 21230 - APD - 15/04/2012 - se le pasa el agente indirecto
      -- al cursor
      v_pasexec := 60;

      FOR rc IN c_rec(vcageind) LOOP   -- Procesamos los recibos
         -- indirecta, caso 1, el agente viene en el cursor
         vcagente := rc.cageven;
         -- Buscamos el nliqmen del cagente de la liqui.
         v_pasexec := 40;
         pnliqmen := f_get_nliqmen(pcempres, vcagente, pfecliq, psproces, pmodo);
         -- buscamos el nliqlin
            -- Ini BUG 21606 - 26/03/2012 - JMC
         v_pasexec := 50;

         SELECT NVL(MAX(nliqlin), 0)
           INTO v_nliqlin
           FROM liquidalin
          WHERE cempres = pcempres
            AND nliqmen = pnliqmen
            AND cagente = vcagente;

         -- Bug 18843/91812 - 06/09/2011 - AMC
         IF rc.cgescob = 3 THEN
            v_pasexec := 70;
            v_icomisi :=(-rc.itotalr + rc.icomisi);
            v_icomisi_moncia :=(-rc.itotalr_moncia + rc.icomisi_moncia);
         ELSE
            v_pasexec := 80;
            v_icomisi := rc.icomisi;
            v_icomisi_moncia := rc.icomisi_moncia;
         END IF;

         -- Fi Bug 18843/91812 - 06/09/2011 - AMC
         v_pasexec := 90;

         IF rc.cestrec = 20 THEN
            v_signo := -1;
         ELSE
            v_signo := 1;
         END IF;

         -- Calcular el factor proporcional del pago parcial respecto al importe total del recibo.
         v_pasexec := 100;
         -- Bug 0027043 - JMF - 04/10/2013: Importes parciales mismo calculo que f_vdetrecibos
         -- v_factor := rc.iimporte / rc.itotalr;
         -- v_factor := 1; -- Bug Ini 0027043/157331: AFM - 30/10/2013
         -- BUG 18423 - 02/11/2011 - JMP - LCOL000 - Multimoneda
         v_pasexec := 110;

         IF v_cmultimon = 1 THEN
            v_pasexec := 130;

            -- Bug Ini 0027043/157331: AFM - 30/10/2013
            IF v_dd_cambio = 99 THEN   -- No hay dia de cambio
               num_err := pac_oper_monedas.f_datos_contraval(NULL, rc.nrecibo, NULL,
                                                             f_sysdate, 2, v_itasa, v_fcambio);
            ELSE   -- El día de cambio es uno concreto si la fecha liquidación es final de mes
               IF pfecliq = LAST_DAY(pfecliq) THEN
                  v_fechac := pfecliq + v_dd_cambio;
               ELSE
                  v_fechac := TRUNC(f_sysdate);
               END IF;

               --
               num_err := pac_oper_monedas.f_datos_contraval(NULL, rc.nrecibo, NULL, v_fechac,
                                                             2, v_itasa, v_fcambio);
            --
            END IF;
         -- Bug Fin 0027043/157331: AMF - 30/10/2013
         END IF;

         v_pasexec := 145;
         v_nliqlin := v_nliqlin + 1;
         v_pasexec := 180;

         -- FIN BUG 18423 - 02/11/2011 - JMP - LCOL000 - Multimoneda
         BEGIN
            -- Aumentamos el nliqlin
            v_pasexec := 190;

            INSERT INTO liquidalin
                        (cempres, nliqmen, cagente, nliqlin, nrecibo, smovrec,
                         itotimp, itotalr,
                         iprinet, icomisi,
                         iretenccom, isobrecomision, iretencsobrecom, iconvoleducto,
                         iretencoleoducto, ctipoliq,
                         -- BUG 18423 - 02/11/2011 - JMP - LCOL000 - Multimoneda
                         itotimp_moncia,
                         itotalr_moncia,
                         iprinet_moncia,
                         icomisi_moncia,
                         iretenccom_moncia,
                         isobrecom_moncia, iretencscom_moncia, iconvoleod_moncia,
                         iretoleod_moncia, fcambio,
                         norden)
                 VALUES (rc.cempres, pnliqmen, vcagente, v_nliqlin, rc.nrecibo, rc.smovrec,
                         NVL(rc.itotimp, 0) * v_signo, NVL(rc.itotalr, 0) * v_signo,
                         NVL(rc.iprinet, 0) * v_signo, NVL(v_icomisi, 0) * v_signo,
                         NVL(rc.icomret, 0) * v_signo, NULL, NULL, NULL,
                         NULL, NULL,
                         -- BUG 18423 - 02/11/2011 - JMP - LCOL000 - Multimoneda
                         -- Bug Ini 0027043/157331: AFM - 30/10/2013
                         f_round(DECODE(v_dd_cambio,
                                        99, rc.itotimp_moncia * v_signo,
                                        NVL(rc.itotimp, 0) * v_signo * v_itasa),
                                 v_cmoncia),
                         f_round(DECODE(v_dd_cambio,
                                        99, rc.itotalr_moncia * v_signo,
                                        NVL(rc.itotalr, 0) * v_signo * v_itasa),
                                 v_cmoncia),
                         f_round(DECODE(v_dd_cambio,
                                        99, rc.iprinet_moncia * v_signo,
                                        NVL(rc.iprinet, 0) * v_signo * v_itasa),
                                 v_cmoncia),
                         f_round(DECODE(v_dd_cambio,
                                        99, v_icomisi_moncia * v_signo,
                                        NVL(v_icomisi, 0) * v_signo * v_itasa),
                                 v_cmoncia),
                         f_round(DECODE(v_dd_cambio,
                                        99, rc.icomret_moncia * v_signo,
                                        NVL(rc.icomret, 0) * v_signo * v_itasa),
                                 v_cmoncia),
                         -- Bug Fin 0027043/157331: AFM - 30/10/2013
                         NULL, NULL, NULL,
                         NULL, DECODE(v_cmultimon, 0, NULL, NVL(v_fcambio, f_sysdate)),
                         rc.norden);

            -- Bug 0029334 - JMF - 11/12/2013
            IF v_p_calc_comind In (1,3) THEN
               -- por cuadros de comisión indirecta pero modalidad directa
               num_err := f_crea_liquidalindet_ind(pnliqmen, vcagente, v_nliqlin, rc.cempres,
                                                   rc.nrecibo,
                                                   SIGN(NVL(v_icomisi, 0) * v_signo), pfecliq,
                                                   rc.norden, rc.smovrec);
            END IF;
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param,
                           '------------->  DUP VAL ON INDEX  .- v_nliqlin = ' || ' cempres '
                           || rc.cempres || ' nliqmen ' || pnliqmen || ' cagente = '
                           || vcagente || ' nliqlin  ' || v_nliqlin);
               RETURN 108953;
         END;
      -- fin Bug 21230 - APD - 15/04/2012
      END LOOP;

      -- END IF;       -- Bug Ini 0027043/157331: AFM - 30/10/2013
      v_pasexec := 200;
      RETURN num_err;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
         RETURN 108953;
   END f_set_recibos_parcial_liq_ind1;

   /*************************************************************************
      Proceso que lanzará la liquidación del agente
      param in  pmodo
      param in  pcempres
      param in  pmoneda
      param in pcidioma
      param in pfperfin
      param in pfcierre
      param in ptdescrip
      param in pcerror
      param in psproces
      param in pfproces
   *************************************************************************/
   FUNCTION f_liquidaliq_age(pcagente       IN NUMBER, --Agente que vamos a realizar la liquidacion
                             pcempres       IN NUMBER,
                             pmodo          IN NUMBER, -- 0:MODO REAL 1:MODO PREVIO
                             pfecliq        IN DATE,
                             pcidioma       IN NUMBER,
                             pcagentevision IN NUMBER,
                             psproces       IN OUT NUMBER,
                             psmovagr       IN NUMBER DEFAULT NULL, -- 21. 0022753
                             pnrecibo       IN NUMBER DEFAULT NULL) RETURN NUMBER IS
      num_err           NUMBER := 0;
      vnumerr           NUMBER := 0;
      v_titulo          VARCHAR2(2000);
      v_llinia          NUMBER := 0;
      v_cur             SYS_REFCURSOR;
      v_ttexto          VARCHAR2(1000);
      v_ttexto1         VARCHAR2(1000);
      v_ttexto2         VARCHAR2(1000);
      v_ttexto3         VARCHAR2(1000);
      v_cagente         NUMBER;
      v_nrecibo         NUMBER;
      v_sseguro         NUMBER;
      v_cempres         NUMBER;
      v_smovrec         NUMBER;
      v_fefeadm         DATE;
      v_fefecto         DATE;
      v_femisio         DATE;
      v_cgescob         NUMBER;
      v_icomisi         NUMBER;
      v_itotimp         NUMBER;
      v_itotalr         NUMBER;
      v_iprinet         NUMBER;
      v_cestrec         NUMBER;
      v_sproliq         NUMBER;
      v_squery          VARCHAR(10000);
      v_pasexec         NUMBER := 1;
      v_param           VARCHAR2(2000) := 'params : pcagente : ' || pcagente ||
                                          ', pcempres : ' || pcempres || ', psproces : ' ||
                                          psproces || ', pfecliq : ' || pfecliq ||
                                          ', pmodo : ' || pmodo || ' idi=' || pcidioma ||
                                          ' vis=' || pcagentevision || ' spro=' ||
                                          psproces || ' agr=' || psmovagr || ' rec=' ||
                                          pnrecibo;
      v_object          VARCHAR2(200) := 'PAC_LIQUIDA.f_liquidaliq_age';
      n_prodext         NUMBER; -- Productos externos.
      v_numrec          ext_recibos.nreccia%TYPE;
      v_nliqaux         NUMBER;
      v_cageliq         NUMBER;
      vnumlin           NUMBER;
      vcage_padre       redcomercial.cpadre%TYPE; -- Bug 21230 - APD - 20/02/2012
      v_nliqaux2        NUMBER; -- Bug 21230 - APD - 16/04/2012
      v_nliqmen         NUMBER;
      v_nliqmen_ext     NUMBER; -- Bug 21230 - APD - 16/04/2012
      v_nliqmen_ind     NUMBER; -- Bug 21230 - APD - 16/04/2012
      v_nliqmen_ind_ext NUMBER; -- Bug 21230 - APD - 16/04/2012
      --  v_nliqmen_ind  NUMBER;   -- Bug 22940/119016 - 17/07/2012 - AMC
      -- Bug 0022346 - JGR - Inicio
      v_nliqmen_parc NUMBER;
      v_nliqmen_pind NUMBER;
      v_cobro_parc   NUMBER := NVL(pac_parametros.f_parempresa_n(pcempres,
                                                                 'LIQ_COBRO_PARCIAL'),
                                   0);
      -- Bug 0022346 - JGR - Fin

      -- ini Bug 27043 - JMF - 10/09/2013
      v_p_liquida_ctipage NUMBER := pac_parametros.f_parempresa_n(pcempres,
                                                                  'LIQUIDA_CTIPAGE');
      v_p_calc_comind     NUMBER := NVL(pac_parametros.f_parempresa_n(pcempres,
                                                                      'CALC_COMIND'),
                                        0);
      -- fin Bug 27043 - JMF - 10/09/2013

      -- Bug 35979/206802: KJSC Asignar variaBle nueva al parametro 'LIQUIDA_AGECLAVE'
      v_liquida_ageclave NUMBER := NVL(pac_parametros.f_parempresa_n(pcempres,
                                                                     'LIQUIDA_AGECLAVE'),
                                       0);
      -- Bug 35979/206802: KJSC Variable agente
      v_agente_ins   NUMBER;
      mensajes       t_iax_mensajes;
      piddocgedox    NUMBER;
      vtamano        age_documentos.tamano%TYPE;
      v_liq_info_alt NUMBER := 0;
      v_count NUMBER;
      bytes_vtamano NUMBER;

      vfarchiv      date; --CONF 236 JAAB
      vfelimin      date; --CONF 236 JAAB
      vfcaduci      date; --CONF 236 JAAB

   BEGIN
      v_pasexec := 10;
      -- Bug 0018046 - JMF - 29/03/2011
      n_prodext := NVL(pac_parametros.f_parempresa_n(pcempres,
                                                     'EMP_POL_EXTERNA'),
                       0);
      v_pasexec := 20;

      IF v_p_liquida_ctipage IS NULL THEN
         v_cageliq := pcagente;
      ELSE
         v_pasexec := 30;
         v_cageliq := pac_agentes.f_get_cageliq(pcempres,
                                                v_p_liquida_ctipage,
                                                pcagente);
      END IF;

      v_pasexec := 40;

      IF psproces IS NULL THEN
         IF pmodo = 1 THEN
            -- PREVIO
            v_ttexto1 := f_axis_literales(9900860,
                                          pcidioma);
            v_ttexto2 := f_axis_literales(101619,
                                          pcidioma);
            v_ttexto3 := f_axis_literales(100584,
                                          pcidioma);
            v_titulo  := v_ttexto1 || ' ' || TO_CHAR(pfecliq,
                                                     'MM') || ' ' || v_ttexto2 || ' ' ||
                         pcempres || ' ' || v_ttexto3 || ' ' || v_cageliq;
         ELSE
            --REAL
            v_ttexto1 := f_axis_literales(9900861,
                                          pcidioma);
            v_ttexto2 := f_axis_literales(101619,
                                          pcidioma);
            v_ttexto3 := f_axis_literales(100584,
                                          pcidioma);
            v_titulo  := v_ttexto1 || ' ' || TO_CHAR(pfecliq,
                                                     'MM') || ' ' || v_ttexto2 || ' ' ||
                         pcempres || ' ' || v_ttexto3 || ' ' || v_cageliq;
         END IF;

         --Insertamos en la tabla PROCESOSCAB el registro identificativo de proceso -----
         vnumerr := f_procesini(f_user,
                                pcempres,
                                'COMISIONES ',
                                v_titulo,
                                psproces);
      END IF;

      -- Reemplazamos por una función para no repetir código .
      -- función que devuelve el nliqmen que toca por agente, empresa
      v_pasexec := 50;
      --Insertamos en liquidaliq
      vnumerr   := pac_liquida.f_set_recibos_liq(pcempres,
                                                 pcagente,
                                                 pfecliq,
                                                 psproces,
                                                 pmodo,
                                                 v_nliqmen,
                                                 psmovagr,
                                                 pnrecibo);
      v_pasexec := 60;

      IF vnumerr <> 0 THEN
         RETURN vnumerr;
      END IF;

      -- Bug 0022346 - JGR - Inicio
      -- Liquidación de recibos con cobros parciales (v_cobro_parc = 1)
      IF v_cobro_parc = 1 THEN
         v_pasexec := 70;
         vnumerr   := pac_liquida.f_set_recibos_parcial_liq(pcempres,
                                                            pcagente,
                                                            pfecliq,
                                                            psproces,
                                                            pmodo,
                                                            v_nliqmen_parc,
                                                            psmovagr,
                                                            pnrecibo);

         IF vnumerr <> 0 THEN
            RETURN vnumerr;
         END IF;
      END IF;

      -- Bug 0022346 - JGR - Fin
      v_pasexec := 90;

      -- ini Bug 0019154 - JMF - 02/08/2011
      -- Insertamos en liquidaliq recibos externos
      IF n_prodext = 1 AND v_cobro_parc = 0 THEN
         -- Bug 0022346 - JGR
         vnumerr := pac_liquida.f_set_ext_recibos_liq(pcempres,
                                                      pcagente,
                                                      pfecliq,
                                                      psproces,
                                                      pmodo,
                                                      v_nliqmen_ext,
                                                      psmovagr,
                                                      pnrecibo);

         IF vnumerr <> 0 THEN
            RETURN vnumerr;
         END IF;
      END IF;

      -- Bug 21230 - APD - 20/02/2012 - se añade el IF para saber de que modo
      -- se quiere insertar las comisiones indirectas
      v_pasexec := 100;

      IF v_p_calc_comind = 2 THEN
         -- Por agente indirecto y modalidad indirecta en el cuadro asignado al agente
         -- ini Bug 0019689 - JMC - 18/10/2011
         --Insertamos las comisiones indirectas
         v_pasexec := 110;

         FOR regind IN (SELECT cagente,
                               cageind
                          FROM redcomercial
                         WHERE fmovfin IS NULL
                           AND cempres = pcempres
                           AND cageind IS NOT NULL
                         ORDER BY cagente) LOOP
            -- Bug 22940/119016 - 17/07/2012 - AMC
            -- Reemplazamos por una función para no repetir código .y buscamos la cabecera que le toca,
            v_pasexec := 120;
            --v_nliqmen_ind := f_get_nliqmen(pcempres, regind.cagente, pfecliq, psproces, pmodo);
            -- El campo nlliqmen en este caso lo calculamos detnro de la función
            v_pasexec := 130;
            vnumerr   := pac_liquida.f_set_recibos_liq_ind(pcempres, /*pcagente*/
                                                           regind.cageind,
                                                           pfecliq, -- BUG 28371/0157125 - FAL - 29/10/2013
                                                           regind.cagente,
                                                           psproces,
                                                           pmodo,
                                                           v_nliqmen_ind,
                                                           psmovagr, -- 21. 0022753
                                                           pnrecibo);
            v_pasexec := 140;

            IF vnumerr <> 0 THEN
               RETURN vnumerr;
            END IF;

            IF n_prodext = 1 AND v_cobro_parc = 0 -- Bug 0022346 - JGR
             THEN
               v_pasexec := 150;
               vnumerr   := pac_liquida.f_set_ext_recibos_liq_ind(pcempres, /*pcagente*/
                                                                  regind.cageind,
                                                                  pfecliq, -- BUG 28371/0157125 - FAL - 29/10/2013
                                                                  psproces,
                                                                  pmodo,
                                                                  v_nliqmen_ind_ext,
                                                                  regind.cagente);

               IF vnumerr <> 0 THEN
                  RETURN vnumerr;
               END IF;
            END IF;

            -- Bug 0022346 - JGR - Inicio
            -- Liquidación de recibos con cobros parciales (v_cobro_parc = 1)
            v_pasexec := 160;

            IF v_cobro_parc = 1 THEN
               v_pasexec := 170;
               vnumerr   := pac_liquida.f_set_recibos_parcial_liq_ind(pcempres, /*pcagente*/
                                                                      regind.cageind, -- BUG 28371/0157125 - FAL - 29/10/2013
                                                                      pfecliq,
                                                                      regind.cagente,
                                                                      psproces,
                                                                      pmodo,
                                                                      v_nliqmen_pind,
                                                                      psmovagr,
                                                                      pnrecibo);

               IF vnumerr <> 0 THEN
                  RETURN vnumerr;
               END IF;
            END IF;

            -- Bug 0022346 - JGR - Fin
            v_pasexec := 190;
            -- Fi Bug 22940/119016 - 17/07/2012 - AMC
         END LOOP;
         -- Fin Bug 0019689 - JMC - 18/10/2011
      ELSIF v_p_calc_comind IN (1,
                                3) THEN
         -- por cuadros de comisión indirecta pero modalidad directa
         v_pasexec := 200;
         -- Bug 27043 - JMF - 10/09/2013
         vnumerr := pac_liquida.f_set_recibos_liq_ind1(pcempres,
                                                       pcagente,
                                                       pfecliq,
                                                       NULL,
                                                       psproces,
                                                       pmodo,
                                                       v_nliqmen_ind,
                                                       psmovagr, -- 21. 0022753
                                                       pnrecibo);

         IF vnumerr <> 0 THEN
            RETURN vnumerr;
         END IF;

         -- Bug 0022346 - JGR - Inicio
         -- Liquidación de recibos con cobros parciales (v_cobro_parc = 1)
         v_pasexec := 220;

         IF v_cobro_parc = 1 THEN
            v_pasexec := 230;
            -- Bug 27043 - JMF - 10/09/2013
            vnumerr := pac_liquida.f_set_recibos_parcial_liq_ind1(pcempres,
                                                                  pcagente,
                                                                  pfecliq,
                                                                  vcage_padre,
                                                                  psproces,
                                                                  pmodo,
                                                                  v_nliqmen_pind,
                                                                  psmovagr,
                                                                  pnrecibo);

            IF vnumerr <> 0 THEN
               RETURN vnumerr;
            END IF;
         END IF;
         -- Bug 0022346 - JGR - Fin
      ELSE
         -- No aplica comisión indirecta
         NULL;
      END IF;

      v_pasexec := 250;

      -- fin Bug 21230 - APD - 20/02/2012
      -- fin Bug 0019154 - JMF - 02/08/2011
      IF pmodo = 0 THEN
         --Real
         UPDATE liquidacab
            SET cestado = 1 --liquidado
          WHERE cempres = pcempres
            AND sproliq = psproces;
         -- fin Bug 21230 - APD - 16/04/2012
      END IF;



      -- INI Bug 22337 - JMC - 22/05/2012 -- Si la empresa tiene un tipo de agente definido
      -- este proceso se realiza en la PAC_MD_LIQUIDA
      -- Bug 22065 - APD - 24/04/2012 -- se vuelve a añadir este codigo que se
      -- había modificado a pac_md_liquida para AGM
         v_agente_ins := NULL;

       SELECT MAX(cageclave)
              INTO v_agente_ins
              FROM agentes_comp
             WHERE cagente = pcagente;


         IF v_agente_ins IS NOT NULL THEN
            ---BUG 27599  MCA 10/09/2013
            v_pasexec := 290;

            FOR reg IN (SELECT DISTINCT (c.cagente)
                          FROM ctactes c,
                               agentes a -- AFM 10/12/2015 bug: 39204
                         WHERE c.fvalor <= pfecliq
                           AND c.cestado = 1 -- Bug 27599  Apuntes manuales pdtes liquidar
                              -- bug 0035979 - 27/07/2015 - JMF
                              -- bug 035979 - 21/09/2015 - AFM
                           AND c.cmanual = 0
                           AND c.cagente = a.cagente -- AFM 10/12/2015 bug: 39204
                           AND NVL(a.cliquido,
                                   0) = DECODE(NVL(pac_parametros.f_parempresa_n(pcempres,
                                                                                 'LIQ_CORTE_CUENTA'),
                                                   0),
                                               2,
                                               0,
                                               1,
                                               1,
                                               NVL(a.cliquido,
                                                   0)) -- AFM 10/12/2015 bug: 39204
                           AND c.cagente = v_agente_ins) LOOP
               --Se revisan apuntes manuales y que no tengan recibos a liqudiar
               --Creación de la cabecera de la liquidación cuando solo hay apuntes manuales y no recibos a liquidar
               v_pasexec := 300;
               v_nliqmen := f_get_nliqmen(pcempres,
                                          reg.cagente,
                                          pfecliq,
                                          psproces,
                                          pmodo);
            END LOOP;
         ELSE
            v_pasexec := 310;

            FOR reg IN (SELECT DISTINCT (c.cagente)
                          FROM ctactes c,
                               agentes a
                         WHERE c.fvalor <= pfecliq
                           AND c.cestado = 1 -- Bug 27599  Apuntes manuales pdtes liquidar
                              -- bug 0035979 - 27/07/2015 - JMF
                              -- bug 035979 - 21/09/2015 - AFM
                           AND c.cmanual = 0
                           AND c.cagente = a.cagente -- AFM 10/12/2015 bug: 39204
                           AND NVL(a.cliquido,
                                   0) = DECODE(NVL(pac_parametros.f_parempresa_n(pcempres,
                                                                                 'LIQ_CORTE_CUENTA'),
                                                   0),
                                               2,
                                               0,
                                               1,
                                               1,
                                               NVL(a.cliquido,
                                                   0)) -- AFM 10/12/2015 bug: 39204
                           AND ((pcagente IS NOT NULL AND c.cagente = pcagente) OR
                               (pcagente IS NULL AND
                               c.cagente NOT IN
                               (SELECT cagente
                                    FROM liquidacab
                                   WHERE sproliq = psproces
                                     AND fliquid = pfecliq
                                     AND cempres = pcempres)))) LOOP
               --Se revisan apuntes manuales y que no tengan recibos a liqudiar
               --Creación de la cabecera de la liquidación cuando solo hay apuntes manuales y no recibos a liquidar
               v_pasexec := 320;
               v_nliqmen := f_get_nliqmen(pcempres,
                                          reg.cagente,
                                          pfecliq,
                                          psproces,
                                          pmodo);
            END LOOP;
END IF;


   IF NVL(v_p_liquida_ctipage,
             999) = 999 THEN
         v_pasexec    := 321;

        -- había modificado a pac_md_liquida para AGM
      IF NVL(pac_parametros.f_parempresa_n(pcempres,
                                              'SIN_CCC_NO_LIQUIDA'),
                0) = 1 THEN
            v_pasexec := 322;
          vnumerr := pac_liquida.f_validar_ccc_age(pcempres,psproces);
         END IF;

          IF NVL(pac_parametros.f_parempresa_n(pcempres,
                                              'BORRAR_LIQ_NEGATIVO'),
                0) = 1 THEN
            v_pasexec := 323;
          vnumerr := pac_liquida.f_signo_comision_age(pcempres,psproces);
         END IF;
    END IF;

         ---BUG 27599
         v_pasexec := 330;

         FOR c IN (SELECT cagente,
                          nliqmen
                     FROM liquidacab
                    WHERE cempres = pcempres
                      AND sproliq = psproces) LOOP
            v_pasexec := 340;
            num_err   := f_set_resumen_ctactes(c.cagente,
                                               pcempres,
                                               psproces,
                                               pcidioma,
                                               pfecliq,
                                               c.nliqmen,
                                               pmodo,
                                               pcagentevision,
                                               psmovagr);

            IF num_err <> 0 THEN
               -- hay errores
               v_ttexto := f_axis_literales(num_err,
                                            pcidioma);
               vnumerr  := f_proceslin(psproces,
                                       v_ttexto,
                                       0,
                                       v_llinia);
               vnumerr  := f_procesfin(psproces,
                                       1);
               --ROLLBACK;
               RETURN num_err;
            END IF;

            -- 21. 0022753: MDP_A001-Cierre de remesa - Inicio
            v_pasexec := 350;

            DELETE liquidacab l
             WHERE l.cempres = pcempres
               AND l.sproliq = psproces
               AND l.cagente = c.cagente
               AND NOT EXISTS
             (SELECT 1
                      FROM liquidalin li
                     WHERE li.cempres = l.cempres
                       AND li.cagente = l.cagente
                       AND li.nliqmen = l.nliqmen
                    UNION
                    SELECT 1
                      FROM ext_liquidalin li
                     WHERE li.nliqmen = l.nliqmen
                       AND li.cagente = l.cagente
                       AND li.cempres = l.cempres
                    UNION
                    SELECT 1
                      FROM ctactes c
                     WHERE cempres = l.cempres
                       AND cagente = l.cagente
                       AND ((cestado = 1 ---- pendent de liquidar
                           AND sproces IS NULL AND pmodo = 1 ----- mode previ
                           AND fvalor <= pfecliq) OR
                           (sproces = psproces AND pmodo = 0 AND cestado = 0) ----- liquidats
                           ));
         END LOOP;
     -- END IF;


      v_pasexec      := 260;
      v_liq_info_alt := NVL(pac_parametros.f_parempresa_n(pcempres,
                                                          'LIQ_INFORMES_ALT'),
                            0);

      IF v_liq_info_alt = 1 AND pmodo = 0 THEN
         v_pasexec := 2000;

         -- JAJG - BUG 40343. Se cambia el cursor para sólo coger tipos de liquidación de real (0) y estado pendiente (1).
         DECLARE
            CURSOR c_agentesliq IS
               SELECT cagente,
                      cempres,
                      nliqmen,
                      fliquid
                 FROM liquidacab a
                WHERE fliquid = pfecliq
                  AND cempres = pcempres
                  AND nliqmen IN (SELECT MAX(nliqmen)
                                    FROM liquidacab b
                                   WHERE cempres = pcempres --
                                     AND ctipoliq = 0
                                     AND a.cagente = b.cagente
                                     AND fliquid = pfecliq
                                     AND b.cestado = 1
                                     AND b.cestautoliq IS NULL);
         BEGIN
            v_pasexec := 2100;

            FOR reg IN c_agentesliq LOOP
               DECLARE
                  num_err     NUMBER(8) := 0;
                  onomfichero VARCHAR2(1000);
                  ofichero    VARCHAR2(1000);
                  vterror     VARCHAR2(1000);
                  viddoc      NUMBER(8) := 0;
                  vnumerr     NUMBER;

                  CURSOR c_informes IS
                     SELECT c.cmap cmap,
                            c.cempres cempres,
                            c.lexport lexport,
                            c.lparams lparams,
                            f_axis_literales(c.slitera,
                                             pcidioma) descr
                       FROM cfg_lanzar_informes c
                      WHERE c.cempres = reg.cempres
                        AND c.tevento = 'LST_LIQUIDA';

                  vtinfo t_iax_info;
                  vinfo  ob_iax_info;
                  e_continua EXCEPTION;
               BEGIN
                  v_pasexec := 2200;

                  FOR reg1 IN c_informes LOOP
                     vtinfo := t_iax_info();
                     vtinfo.DELETE;
                     vinfo := ob_iax_info();
                     vtinfo.EXTEND;
                     vinfo.nombre_columna := 'PAGENTE';
                     vinfo.valor_columna := reg.cagente;
                     vinfo.tipo_columna := 1;
                     vtinfo(vtinfo.LAST) := vinfo;
                     vtinfo.EXTEND;
                     vinfo.nombre_columna := 'PFECHA';
                     vinfo.valor_columna := TO_CHAR(pfecliq,
                                                    'dd/mm/rrrr');
                     vinfo.tipo_columna := 3;
                     vtinfo(vtinfo.LAST) := vinfo;
                     vtinfo.EXTEND;
                     vinfo.nombre_columna := 'PNLIQMEN';
                     vinfo.valor_columna := reg.nliqmen;
                     vinfo.tipo_columna := 1;
                     vtinfo(vtinfo.LAST) := vinfo;
                     v_pasexec := 2300;


                     num_err := pac_iax_informes.f_ejecuta_informe(reg1.cmap,
                                                                   reg1.cempres,
                                                                   reg1.lexport,
                                                                   vtinfo,
                                                                   pcidioma,
                                                                   0,
                                                                   NULL,
                                                                   onomfichero,
                                                                   ofichero,
                                                                   mensajes);


                     IF num_err <> 0 THEN
                        -- Control de error
                        p_tab_error(f_sysdate,
                                    f_user,
                                    v_object,
                                    v_pasexec,
                                    'age=' || reg.cagente || ' cmap=' || reg1.cmap || ' ' ||
                                    v_param,
                                    num_err || ' ' || SQLCODE || ' ' || SQLERRM);
                        RAISE e_continua;
                     END IF;

                     v_pasexec := 2400;
                     -- Categoria 8 Otros.
                     /*  num_err := pac_md_gedox.f_set_documgedox(f_user, onomfichero, piddocgedox,
                     reg1.descr, 8, mensajes,
                     onomfichero);*/

                        --INI JAAB CONF-236 22/08/2016
                        vfarchiv := PAC_MD_GEDOX.F_CALCULA_FECHA_AEC(1);
                        vfcaduci := PAC_MD_GEDOX.F_CALCULA_FECHA_AEC(2);
                        vfelimin := PAC_MD_GEDOX.F_CALCULA_FECHA_AEC(3);
                        --FIN JAAB CONF 236 22/08/2016

                     viddoc := piddocgedox;
                     --pac_axisgedox.grabacabecera(f_user, onomfichero, reg1.descr, 1, 1, 8, vterror, viddoc); --JAAB CONF 236
                     pac_axisgedox.grabacabecera(f_user, onomfichero, reg1.descr, 1, 1, 8, vterror, viddoc, vfarchiv, vfelimin, vfcaduci);

                     IF vterror IS NOT NULL THEN
                        p_tab_error(f_sysdate,
                                    f_user,
                                    v_object,
                                    v_pasexec,
                                    'age=' || reg.cagente || ' cmap=' || reg1.cmap || ' ' ||
                                    v_param,
                                    num_err || ' ' || SQLCODE || ' ' || SQLERRM);
                        RAISE e_continua;
                     END IF;

                     v_pasexec := 2450;
                     pac_axisgedox.actualiza_gedoxdb(onomfichero,
                                                     viddoc,
                                                     vterror);
                     piddocgedox := viddoc;

                     IF vterror IS NOT NULL THEN
                        p_tab_error(f_sysdate,
                                    f_user,
                                    v_object,
                                    v_pasexec,
                                    'age=' || reg.cagente || ' cmap=' || reg1.cmap || ' ' ||
                                    v_param,
                                    num_err || ' ' || SQLCODE || ' ' || SQLERRM);
                        RAISE e_continua;
                     END IF;

                     COMMIT;
                     v_pasexec := 2451;

                     IF piddocgedox IS NOT NULL THEN
                        num_err := pac_md_gedox.f_get_tamanofit(piddocgedox, vtamano,
                                                                mensajes);

                        IF num_err <> 0 THEN
                           vtamano := NULL;
              --          ELSE
              --            SELECT LENGTH(contenido)
              --                INTO bytes_vtamano
              --             FROM gedoxdb
              --             WHERE iddoc = piddocgedox;

              --             IF bytes_vtamano < 102400 then
              --
              --                vnumerr := f_proceslin(psproces, 'Documento no cumple los requerimientos de tamaño mínimo: ID_DOC: '||piddocgedox, 0, v_llinia);

              --             END IF;

                        END IF;
                     ELSE
                        vtamano := NULL;
                     END IF;

                     v_pasexec := 2500;
                     num_err   := pac_md_redcomercial.f_set_docagente(reg.cagente,
                                                                      NULL,
                                                                      reg1.descr,
                                                                      piddocgedox,
                                                                      vtamano,
                                                                      mensajes);

                     -- JAJG -- BUG 40343. Se añade e informa campo NLIQMEN
                     UPDATE age_documentos
                        SET nliqmen = reg.nliqmen
                      WHERE iddocgedox = piddocgedox;

                     IF num_err <> 0 THEN
                        -- Control de error
                        p_tab_error(f_sysdate,
                                    f_user,
                                    v_object,
                                    v_pasexec,
                                    'age=' || reg.cagente || ' cmap=' || reg1.cmap || ' ' ||
                                    v_param,
                                    num_err || ' ' || SQLCODE || ' ' || SQLERRM);
                        RAISE e_continua;
                     END IF;

                     COMMIT;
                     vterror := pac_md_log.f_log_actividad('axisgedox',
                                                           1,
                                                           viddoc,
                                                           NULL,
                                                           NULL,
                                                           onomfichero,
                                                           mensajes);

                     IF vterror <> 0 THEN
                        -- Control de error
                        p_tab_error(f_sysdate,
                                    f_user,
                                    v_object,
                                    v_pasexec,
                                    'age=' || reg.cagente || ' cmap=' || reg1.cmap || ' ' ||
                                    v_param,
                                    num_err || ' ' || SQLCODE || ' ' || SQLERRM);
                        RAISE e_continua;
                     END IF;
                  END LOOP;
               EXCEPTION
                  WHEN e_continua THEN
                     -- Para que siga con el siguiente agente
                     NULL;
               END;
            END LOOP;
         END;
      END IF;

      v_pasexec := 400;
      RETURN NVL(num_err,
                 0);
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate,
                     f_user,
                     v_object,
                     v_pasexec,
                     v_param,
                     num_err || ' ' || SQLERRM);
         RETURN 1;
   END f_liquidaliq_age;

-- Proceso de cierre de liquidaciones
    /*************************************************************************/
   FUNCTION f_validacion_cierre(pfcierre IN DATE, pcempres IN NUMBER)
      RETURN NUMBER IS
      vcerrado       NUMBER;
   BEGIN
      -- Comprobamos si esta cerrado el mes ya.
      SELECT COUNT(1)
        INTO vcerrado
        FROM cierres
       WHERE ctipo = 17   -- Cierre de Comisiones. cvalor= 167
         AND cestado = 1   -- Mes cerrado
         AND fcierre = pfcierre;

      IF vcerrado > 0 THEN
         RETURN 107855;
      END IF;

      -- Comprobamos que el mes tiene que estar cerrado para el cierre de producción de recibos.
      SELECT COUNT(1)
        INTO vcerrado
        FROM cierres
       WHERE ctipo = 7   -- Cierre de producción de recibos. cvalor= 167
         AND cestado = 1   -- Mes cerrado
         AND fcierre = pfcierre;

      IF vcerrado = 0 THEN
         RETURN 9900798;
      END IF;

      -- Comprobamos que el mes tiene que estar cerrado para el cierre de administración de recibos.
      SELECT COUNT(1)
        INTO vcerrado
        FROM cierres
       WHERE ctipo = 8   -- Cierre de administración de recibos cvalor= 167
         AND cestado = 1   -- Mes cerrado
         AND fcierre = pfcierre;

      IF vcerrado = 0 THEN
         RETURN 9900799;
      END IF;

      RETURN 0;
   END f_validacion_cierre;

-------------------------------------------------------------------
-------------------------------------------------------------------
   PROCEDURE proceso_batch_cierre(
      pmodo IN NUMBER,   -- 0:MODO REAL 1:MODO PREVIO
      pcempres IN NUMBER,
      pmoneda IN NUMBER,
      pcidioma IN NUMBER,
      pfperini IN DATE,
      pfperfin IN DATE,
      pfcierre IN DATE,
      pcerror OUT NUMBER,
      psproces OUT NUMBER,
      pfproces OUT DATE) IS
      num_err        NUMBER := 0;
      text_error     VARCHAR2(500) := 0;
      pnnumlin       NUMBER;
      texto          VARCHAR2(400);
      conta_err      NUMBER := 0;
      v_titulo       VARCHAR2(100);
      lany           NUMBER;
      mes            NUMBER;
      v_modo         NUMBER;
      vsmovagr       NUMBER := NULL;   -- 21. 0022753: MDP_A001-Cierre de remesa
      v_ttexto       VARCHAR2(1000);   -- 48. 33155: AGM301-Mantenimiento de cuentas técnicas de comisiones
      v_llinia       NUMBER := 0;   --
      v_pasexec      NUMBER := 0;   --
      v_object       VARCHAR2(200) := 'PAC_LIQUIDA.proceso_batch_cierre';
      v_param        VARCHAR2(200)
         := 'params : pmodo=' || pmodo || ' pmoneda=' || pmoneda || ' pfperini=' || pfperini
            || ' pfperfin=' || pfperfin || ' pfcierre=' || pfcierre;
      e_object_error EXCEPTION;   -- 48
   BEGIN
      IF pmodo = 1 THEN
         v_titulo := 'Proceso Cierre de Comisiones - Previo';
      ELSE
         v_titulo := 'Proceso Cierre de Comisiones';
      END IF;

      IF pmodo = 2 THEN
         v_modo := 0;
      ELSE
         v_modo := pmodo;
      END IF;

      --Insertamos en la tabla PROCESOSCAB el registro identificativo de proceso -----
      num_err := f_procesini(f_user, pcempres, 'CIERRE_COMISIONES', v_titulo, psproces);
      COMMIT;

      IF num_err <> 0 THEN
         pcerror := 1;
         conta_err := conta_err + 1;
         texto := f_axis_literales(num_err, pcidioma);
         pnnumlin := NULL;
         num_err := f_proceslin(psproces,
                                SUBSTR('Cierre Comisiones: ' || texto || ' ' || text_error, 1,
                                       120),
                                0, pnnumlin);
         COMMIT;
      ELSE
         -- Comprobamos  si se puede realizar el cierre.
         num_err := f_validacion_cierre(pfcierre, pcempres);

         IF num_err = 1 THEN
            pcerror := 1;
            conta_err := conta_err + 1;
            texto := f_axis_literales(num_err, pcidioma);
            pnnumlin := NULL;
            num_err := f_proceslin(psproces,
                                   SUBSTR('Cierre Comisiones: ' || texto || ' ' || text_error,
                                          1, 120),
                                   0, pnnumlin);
         ELSE
            --Liquidación a nivel de toda la compañía
            num_err := pac_liquida.f_liquidaliq_age(NULL, pcempres, v_modo, pfperfin,
                                                    pcidioma, pac_md_common.f_get_cxtagente,
                                                    psproces, vsmovagr);   -- 21. 0022753: MDP_A001-Cierre de remesa

            IF num_err <> 0 THEN
               pcerror := 1;
               conta_err := conta_err + 1;
               texto := f_axis_literales(num_err, pcidioma);
               pnnumlin := NULL;
               num_err := f_proceslin(psproces,
                                      SUBSTR('Cierre Comisiones: ' || texto || ' '
                                             || text_error,
                                             1, 120),
                                      0, pnnumlin);
               COMMIT;
            END IF;
         END IF;
      END IF;

      -- 48. 33155: AGM301-Mantenimiento de cuentas técnicas de comisiones
      IF NVL(pac_parametros.f_parempresa_n(pcempres, 'LIQUIDA_CTIPAGE'), 999) <> 999 THEN
         v_pasexec := 70;

         FOR x IN (SELECT   *
                       FROM liquidacab
                      WHERE sproliq = psproces
                   ORDER BY cagente, nliqmen) LOOP
            num_err := pac_liquida.f_set_resumen_ctactes(x.cagente, pcempres, psproces,
                                                         pcidioma, x.fliquid, x.nliqmen,
                                                         pmodo, pac_md_common.f_get_cxtagente);

            IF num_err <> 0 THEN   -- hay errores
               v_ttexto := f_axis_literales(num_err, pcidioma);
               num_err := f_proceslin(psproces, v_ttexto, 0, v_llinia);
               num_err := f_procesfin(psproces, 1);
               ROLLBACK;
               --pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_error);
               RAISE e_object_error;
            END IF;
         END LOOP;
      END IF;

      IF NVL(pac_parametros.f_parempresa_n(pcempres, 'AGRUPA_PAGO_DIRECT'), 0) = 1
         AND pmodo <> 1 THEN
         v_pasexec := 80;
         num_err := pac_liquida.f_agrupa_pagocomisi_directas(pcempres, psproces);

         IF num_err <> 0 THEN   -- hay errores
            v_ttexto := f_axis_literales(num_err, pcidioma);
            num_err := f_proceslin(psproces, v_ttexto, 0, v_llinia);
            num_err := f_procesfin(psproces, 1);
            ROLLBACK;
            --pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_error);
            RAISE e_object_error;
         END IF;
      END IF;

      -- 48. 33155: AGM301-Mantenimiento de cuentas técnicas de comisiones   FIN
      num_err := f_procesfin(psproces, conta_err);
      pfproces := f_sysdate;
      pcerror := 0;
      COMMIT;
   EXCEPTION
      WHEN e_object_error THEN
         p_tab_error(f_sysdate, f_user, 'CIERRE COMISIONES =' || psproces, v_pasexec,
                     'e_object_error cierre =' || pfperfin, SQLERRM);
         pcerror := 1;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'CIERRE COMISIONES =' || psproces, NULL,
                     'when others del cierre =' || pfperfin, SQLERRM);
         pcerror := 1;
   END proceso_batch_cierre;

   /*************************************************************************
       Función que devuelve la query a ejecutar para saber el dia inicio de liquidacion

       pctipo IN NUMBER
       RETURN VARCHAR2
   *************************************************************************/
   FUNCTION f_get_feciniliq(pctipo IN NUMBER)
      RETURN VARCHAR2 IS
      v_object       VARCHAR2(500) := 'PAC_LIQUIDA.f_get_feciniliq';
      v_param        VARCHAR2(500) := 'params : pctipo : ' || pctipo;
      v_pasexec      NUMBER(5) := 1;
      squery         VARCHAR2(2000);
   BEGIN
      squery := 'SELECT MAX(fperfin) + 1 finici FROM cierres WHERE ctipo = ' || pctipo
                || ' AND cestado = 1';
      RETURN squery;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
         RETURN NULL;
   END f_get_feciniliq;

   /*************************************************************************
       Función que devuelve la query que devuelve los procesos de cierre
       0:MODO REAL 1:MODO PREVIO
       pctipo IN NUMBER
       RETURN VARCHAR2
   *************************************************************************/
   FUNCTION f_get_proc_cierres_liq(pmodo IN NUMBER, pfecliq IN DATE, pcempres IN NUMBER)
      RETURN VARCHAR2 IS
      v_object       VARCHAR2(500) := 'PAC_LIQUIDA.f_get_proc_cierres_liq';
      v_param        VARCHAR2(500) := 'params : ';
      v_pasexec      NUMBER(5) := 1;
      squery         VARCHAR2(2000);
   BEGIN
      -- BUG 0025198 - 20/12/2012 - JMF: afegir pfecliq al previ + canvi ordre de tdesc per sproces
      -- Bug 26187, sólo mostrar los procesos finalizados
      IF pmodo = 0
         AND pfecliq IS NOT NULL THEN   --Real
         squery :=
            'select distinct to_char(lc.FLIQUID,''dd/mm/rrrr'') || '' - ''|| SPROLIQ|| '' - ''||lc.cagente||'' ''||ff_desagente(lc.cagente) tdesc, SPROLIQ sproces
                 from liquidacab lc where cempres = '
            || pcempres || 'and lc.fliquid = ' || CHR(39) || pfecliq || CHR(39)
            || 'and lc.ctipoliq = ' || pmodo || ' and lc.cestado = 1 '
            || 'and lc.cagente = (SELECT a.cagente FROM agentes a, per_regimenfiscal p WHERE a.SPERSON = P.SPERSON and a.cagente = lc.cagente and CREGFISCAL = 1) ' -- BUG 1896 AP 23/04/2018
            || 'and 1 = (select count(''1'') from liquidacab lc2 where lc2.sproliq = lc.sproliq) '
            || 'AND sproliq IN (SELECT sproces FROM procesoscab WHERE sproces = lc.sproliq and fprofin is not null)'
            || ' union '
            || ' select distinct to_char(lc.FLIQUID,''dd/mm/rrrr'') || '' - ''|| SPROLIQ tdesc, SPROLIQ sproces
                 from liquidacab lc where cempres = '
            || pcempres || 'and lc.fliquid = ' || CHR(39) || pfecliq || CHR(39)
            || 'and lc.ctipoliq = ' || pmodo || ' and lc.cestado = 1 '
            || 'and lc.cagente = (SELECT a.cagente FROM agentes a, per_regimenfiscal p WHERE a.SPERSON = P.SPERSON and a.cagente = lc.cagente and CREGFISCAL = 1) ' -- BUG 1896 AP 23/04/2018
            || 'and 1 < (select count(''1'') from liquidacab lc2 where lc2.sproliq = lc.sproliq) '
            || 'AND sproliq IN (SELECT sproces FROM procesoscab WHERE sproces = lc.sproliq and fprofin is not null)'
            || 'order by sproces desc';
      ELSIF pmodo = 1 THEN
         squery :=
            'select distinct to_char(lc.FLIQUID,''dd/mm/rrrr'') || '' - ''|| SPROLIQ|| '' - ''||lc.cagente||'' ''||ff_desagente(lc.cagente) tdesc, SPROLIQ sproces
                 from liquidacab lc where cempres = '
            || pcempres || 'and lc.fliquid = ' || CHR(39) || pfecliq || CHR(39)
            || 'and lc.ctipoliq = ' || pmodo || ' and lc.cestado is null '
            || 'and lc.cagente = (SELECT a.cagente FROM agentes a, per_regimenfiscal p WHERE a.SPERSON = P.SPERSON and a.cagente = lc.cagente and CREGFISCAL = 1) ' -- BUG 1896 AP 23/04/2018
            || ' and 1 = (select count(''1'') from liquidacab lc2 where lc2.sproliq = lc.sproliq) '
            || ' AND sproliq IN (SELECT sproces FROM procesoscab WHERE sproces = lc.sproliq and fprofin is not null)'
            || ' union '
            || ' select distinct to_char(lc.FLIQUID,''dd/mm/rrrr'') || '' - ''|| SPROLIQ tdesc, SPROLIQ sproces
                 from liquidacab lc where cempres = '
            || pcempres || ' and lc.fliquid = ' || CHR(39) || pfecliq || CHR(39)
            || ' and lc.ctipoliq = ' || pmodo || ' and lc.cestado is null '
            || 'and lc.cagente = (SELECT a.cagente FROM agentes a, per_regimenfiscal p WHERE a.SPERSON = P.SPERSON and a.cagente = lc.cagente and CREGFISCAL = 1) ' -- BUG 1896 AP 23/04/2018
            || ' and 1 < (select count(''1'') from liquidacab lc2 where lc2.sproliq = lc.sproliq) '
            || ' AND sproliq IN (SELECT sproces FROM procesoscab WHERE sproces = lc.sproliq and fprofin is not null)'
            || 'order by sproces desc';
      END IF;

      RETURN squery;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
         RETURN NULL;
   END f_get_proc_cierres_liq;

   /*************************************************************************
       Función que inserta el proceso de cierre

       RETURN NUMBER
   *************************************************************************/
   FUNCTION f_set_cierre_liq(
      pfperini IN DATE,
      pfperfin IN DATE,
      pfcierre IN DATE,
      pcempres IN NUMBER,
      pctipo IN NUMBER,
      pcestado IN NUMBER,
      psproces IN NUMBER,
      pfproces IN DATE)
      RETURN NUMBER IS
      --
      v_object       VARCHAR2(500) := 'PAC_LIQUIDA.f_set_cierre_liq';
      v_param        VARCHAR2(500)
         := 'params - pfperini : ' || pfperini || ' - pfperfin : ' || pfperfin
            || ' - pfcierre : ' || pfcierre || ' - pcempres : ' || pcempres || ' - pctipo : '
            || pctipo || ' - pcestado : ' || pcestado || ' - psproces : ' || psproces
            || ' - pfproces : ' || pfproces;
      v_pasexec      NUMBER(5) := 1;
   BEGIN
      INSERT INTO cierres
                  (fperini, fperfin, fcierre, cempres, ctipo, cestado, sproces,
                   fproces)
           VALUES (pfperini, pfperfin, pfcierre, pcempres, pctipo, pcestado, psproces,
                   pfproces);

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
         RETURN 105511;
   END f_set_cierre_liq;

   /*************************************************************************
       Función que elimina datos del previo

       RETURN NUMBER
   *************************************************************************/
   FUNCTION f_del_liq_previo(psproces IN NUMBER)
      RETURN NUMBER IS
      --
      v_object       VARCHAR2(500) := 'PAC_LIQUIDA.f_del_liq_previo';
      v_param        VARCHAR2(500) := 'params - psproces : ' || psproces;
      v_pasexec      NUMBER(5) := 1;
   BEGIN
      DELETE FROM liqmovrec_previo
            WHERE sproces = psproces;

      DELETE FROM ctactes_previo
            WHERE sproces = psproces;

      DELETE FROM ext_liqmovrec_previo
            WHERE sproces = psproces;

      DELETE FROM ext_ctactes_previo
            WHERE sproces = psproces;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
         RETURN 108017;
   END f_del_liq_previo;

   /*************************************************************************
       Función para insertar la cabecera de la liquidación
       RETURN NUMBER
   *************************************************************************/
   FUNCTION f_set_cabeceraliq(
      pcagente IN NUMBER,
      pnliqmen IN NUMBER,
      pfliquid IN DATE,
      pfmovimi IN DATE,
      pfcontab IN DATE,
      pcempres IN NUMBER,
      psproliq IN NUMBER,
      pntalon IN NUMBER,
      pcctatalon IN VARCHAR,
      pfingtalon DATE,
      pctipoliq IN NUMBER,
      pcestado IN NUMBER,
      pfcobro IN DATE,
      pctotalliq IN NUMBER)
      RETURN NUMBER IS
      v_object       VARCHAR2(500) := 'PAC_LIQUIDA.F_SET_CABECERALIQ';
      v_param        VARCHAR2(500)
         := 'params - PCAGENTE : ' || pcagente || ' PNLIQMEN ' || pnliqmen || ' PFLIQUID '
            || pfliquid || ' PFMOVIMI ' || pfmovimi || ' PFCONTAB ' || pfcontab
            || ' PCEMPRES ' || pcempres || ' PSPROLIQ ' || psproliq || ' PNTALON ' || pntalon
            || ' PCCTATALON ' || pcctatalon || ' PFINGTALON ' || pfingtalon || ' PCTIPOLIQ '
            || pctipoliq || ' PCESTADO ' || pcestado || ' PFCOBRO ' || pfcobro
            || ' PCTOTALLIQ ' || pctotalliq;
      v_pasexec      NUMBER(5) := 1;
      num_err        NUMBER := 0;
   BEGIN
      INSERT INTO liquidacab
                  (cagente, nliqmen, fliquid, fmovimi, fcontab, cempres, sproliq,
                   ntalon, cctatalon, fingtalon, ctipoliq, cestado, cusuari, fcobro,
                   ctotalliq)
           VALUES (pcagente, pnliqmen, pfliquid, pfmovimi, pfcontab, pcempres, psproliq,
                   pntalon, pcctatalon, pfingtalon, pctipoliq, pcestado, f_user, pfcobro,
                   pctotalliq);

      v_pasexec := 2;
      RETURN num_err;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
         RETURN 108953;
   END f_set_cabeceraliq;

   -- 22. 0022346: LCOL_A003-Cobro parcial de los recibos Fase 2 - Inicio
   /*******************************************************************************
   FUNCION PAC_LIQUIDA.F_SET_RECIBOS_PARCIAL_LIQ
   Inserta las comisiones directas de los recibos con pagos parciales pendientes
   de liquidar en las tablas de liquidaciones

   Parámetros:
      param in pcempres   : código de la empresa
      param in pcagente   : Agente
      param in pfecliq    : Fecha lquidación (hasta la que incluyen movimientos)
      param in psproces   : Código de todo el proceso de liquidación para todos los agentes
      param in pmodo      : Pmodo = 0 Real y 1 Previo
      param in psmovagr   : Secuencial de agrupación de recibos (movrecibo.smovagr)

      return: number un número con el id del error, en caso de que todo vaya OK, retornará un cero.
   ********************************************************************************/
   FUNCTION f_set_recibos_parcial_liq(
      pcempres IN NUMBER,
      pcagente IN NUMBER,
      pfecliq IN DATE,
      psproces IN NUMBER,
      pmodo IN NUMBER,
      pnliqmen OUT NUMBER,
      psmovagr IN NUMBER DEFAULT NULL,
      pnrecibo IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      --
      v_object       VARCHAR2(500) := 'PAC_LIQUIDA.F_SET_RECIBOS_PARCIAL_LIQ';
      v_param        VARCHAR2(500)
         := 'params - pcempres :' || pcempres || ' pcagente : ' || pcagente || ' pfecliq : '
            || pfecliq || ' psproces : ' || psproces || ' pmodo : ' || pmodo || ' psmovagr : '
            || psmovagr || ' rec=' || pnrecibo;
      v_pasexec      NUMBER(5) := 1;
      num_err        NUMBER := 0;
      v_cageliq      NUMBER;
      v_diasliq      NUMBER := NVL(pac_parametros.f_parinstalacion_n('DIASLIQ'), 0);
      v_p_fefeadm_fmovdia NUMBER
                         := NVL(pac_parametros.f_parempresa_n(pcempres, 'FEFEADM_FMOVDIA'), 0);
      v_p_liquida_ctipage NUMBER := pac_parametros.f_parempresa_n(pcempres, 'LIQUIDA_CTIPAGE');
      v_cmultimon    NUMBER := NVL(pac_parametros.f_parempresa_n(pcempres, 'MULTIMONEDA'), 0);
      v_cmoncia      NUMBER := pac_parametros.f_parempresa_n(pcempres, 'MONEDAEMP');
      -- Bug Ini 0027043/157331: AFM - 30/10/2013
      v_dd_cambio    NUMBER
                      := NVL(pac_parametros.f_parempresa_n(pcempres, 'COMIS_DD_CAMB_LIQ'), 99);
      -- Bug Fin 0027043/157331: AFM - 30/10/2013
      d_hoytrunc     DATE := TRUNC(f_sysdate);
      v_p_calc_comind NUMBER := NVL(pac_parametros.f_parempresa_n(pcempres, 'CALC_COMIND'), 0);

      -- Bug 27043 - JMF - 10/09/2013: Rerforma select para optimizar
      CURSOR c_rec IS
         -- POR COBRO NO DOMICILIADO
         -- Bug 0027043 - JMF - 04/10/2013: Importes parciales mismo calculo que f_vdetrecibos
         SELECT   r.nrecibo, r.cagente, r.sseguro, r.cempres, m.fefeadm, r.fefecto, r.femisio,
                  s.npoliza, s.cramo, r.cgescob, s.sproduc,
                  SUM(DECODE(dp.cconcep, 0, dp.iconcep, 50, dp.iconcep, 0)) iprinet,
                  SUM(DECODE(dp.cconcep,
                             0, dp.iconcep_monpol,
                             50, dp.iconcep_monpol,
                             0)) iprinet_moncia,
                  SUM(DECODE(dp.cconcep, 11, dp.iconcep, 61, dp.iconcep, 0)) icomisi,
                  SUM(DECODE(dp.cconcep,
                             11, dp.iconcep_monpol,
                             61, dp.iconcep_monpol,
                             0)) icomisi_moncia,
                  SUM(DECODE(dp.cconcep, 12, dp.iconcep, 62, dp.iconcep, 0)) icomret,
                  SUM(DECODE(dp.cconcep,
                             12, dp.iconcep_monpol,
                             62, dp.iconcep_monpol,
                             0)) icomret_moncia,
                  SUM(DECODE(dp.cconcep, 0, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 1, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 2, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 3, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 4, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 5, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 6, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 7, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 8, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 14, dp.iconcep, 0)
                      - DECODE(dp.cconcep, 13, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 86, dp.iconcep, 0)
                      -- it1totr
                      + DECODE(dp.cconcep, 50, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 51, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 52, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 53, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 54, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 55, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 56, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 57, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 58, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 64, dp.iconcep, 0)
                      - DECODE(dp.cconcep, 63, dp.iconcep, 0)
                      -- it2totr
                      + DECODE(dp.cconcep, 26, dp.iconcep, 0)
                                                             -- iocorec
                  ) itotalr,
                  SUM(DECODE(dp.cconcep, 0, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 1, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 2, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 3, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 4, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 5, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 6, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 7, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 8, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 14, dp.iconcep_monpol, 0)
                      - DECODE(dp.cconcep, 13, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 86, dp.iconcep_monpol, 0)
                      -- it1totr
                      + DECODE(dp.cconcep, 50, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 51, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 52, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 53, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 54, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 55, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 56, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 57, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 58, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 64, dp.iconcep_monpol, 0)
                      - DECODE(dp.cconcep, 63, dp.iconcep_monpol, 0)
                      -- it2totr
                      + DECODE(dp.cconcep, 26, dp.iconcep_monpol, 0)
                                                                    -- iocorec
                  ) itotalr_moncia,
                  (SUM(DECODE(dp.cconcep, 4, dp.iconcep, 0)
                       + DECODE(dp.cconcep, 5, dp.iconcep, 0)
                       + DECODE(dp.cconcep, 6, dp.iconcep, 0)
                       + DECODE(dp.cconcep, 7, dp.iconcep, 0)
                       + DECODE(dp.cconcep, 86, dp.iconcep, 0)
                       -- it1imp
                       + DECODE(dp.cconcep, 54, dp.iconcep, 0)
                       + DECODE(dp.cconcep, 55, dp.iconcep, 0)
                       + DECODE(dp.cconcep, 56, dp.iconcep, 0)
                       + DECODE(dp.cconcep, 57, dp.iconcep, 0)
                                                              -- it2imp
                   )) itotimp,
                  (SUM(DECODE(dp.cconcep, 4, dp.iconcep_monpol, 0)
                       + DECODE(dp.cconcep, 5, dp.iconcep_monpol, 0)
                       + DECODE(dp.cconcep, 6, dp.iconcep_monpol, 0)
                       + DECODE(dp.cconcep, 7, dp.iconcep_monpol, 0)
                       + DECODE(dp.cconcep, 86, dp.iconcep_monpol, 0)
                       -- it1imp
                       + DECODE(dp.cconcep, 54, dp.iconcep_monpol, 0)
                       + DECODE(dp.cconcep, 55, dp.iconcep_monpol, 0)
                       + DECODE(dp.cconcep, 56, dp.iconcep_monpol, 0)
                       + DECODE(dp.cconcep, 57, dp.iconcep_monpol, 0)
                                                                     -- it2imp
                   )) itotimp_moncia,
                  10 cestrec, r.ctiprec, d.smovrec, d.norden, d.iimporte,
                  SUM(DECODE(dp.cconcep, 43, dp.iconcep, 0)) iconvoleoducto,
                  SUM(DECODE(dp.cconcep, 43, dp.iconcep_monpol, 0)) iconvoleoducto_moncia
             FROM movrecibo m, recibos r, seguros s, detmovrecibo d, detmovrecibo_parcial dp
            WHERE m.nrecibo = r.nrecibo
              AND s.sseguro = r.sseguro
              AND m.smovagr = NVL(psmovagr, m.smovagr)
              AND m.nrecibo = NVL(pnrecibo, m.nrecibo)
              AND m.smovrec IN(SELECT MAX(x.smovrec)
                                 FROM movrecibo x
                                WHERE x.nrecibo = r.nrecibo
                                  AND x.cestrec = 0)
              AND((EXISTS(SELECT 1
                            FROM detmovrecibo_parcial dp2
                           WHERE dp2.smovrec = m.smovrec
                             AND dp2.cconcep = 11
                             AND NVL(dp2.iconcep, 0) <> 0)
                   AND r.cgescob IS NULL)
                  OR(r.cgescob = 3))   --rebut amb comisions o gestió broker
              AND(NOT EXISTS(
                     SELECT '*'   --que el rebut no s'hagi liquidat mai
                       FROM liquidalin l, liquidacab lc
                      WHERE l.nliqmen = lc.nliqmen
                        AND l.cagente = lc.cagente
                        AND l.cempres = lc.cempres
                        AND lc.cagente =
                              NVL
                                 (v_cageliq,
                                  pac_agentes.f_agente_liquida(r.cempres, r.cagente))   -- Bug 35979/206802: KJSC busque el f_agente_liquida igual que hace en función F_SET_RECIBOS_LIQ
                        -- AND lc.cagente = NVL(v_cageliq, r.cagente)   --pcagente
                        AND l.smovrec = d.smovrec
                        AND l.norden = d.norden
                        AND lc.cestado = 1))
              AND d.smovrec = m.smovrec
              AND r.cagente = NVL(pcagente, r.cagente)
              AND DECODE(v_p_fefeadm_fmovdia, 1, TRUNC(m.fmovdia), TRUNC(m.fefeadm)) <
                                                                                    pfecliq + 1
              AND DECODE(v_p_fefeadm_fmovdia, 1, TRUNC(d.fmovimi), TRUNC(d.fefeadm)) <=
                                                                                    pfecliq + 1
              AND r.cempres = pcempres
              AND pac_corretaje.f_tiene_corretaje(s.sseguro, NULL) = 0
              AND r.cestaux = 0   -- Bug 26022 - APD - 11/02/2013
              AND((r.cestimp <> 5)   --no domiciliat
                  OR(r.cestimp = 5   --domiciliat
                     AND((m.fmovini >
                             r.fefecto   --que la data del moviment de cobrat sigui més gran que la data d'efecte
                          -- que hagin passat els dies de gestió a partir de la data d'efecte del moviment de cobrat
                          AND d_hoytrunc >= m.fmovini + v_diasliq)
                         OR(m.fmovini <=
                               r.fefecto   --que la data del movimient de cobrat sigui menor o igual que la data d'efecte
                            -- que hagin passat els dies de gestió a partir de la data d'efecte del moviment de cobrat
                            AND d_hoytrunc >= r.fefecto + v_diasliq))))
              AND dp.smovrec = m.smovrec
              AND dp.norden = d.norden
              AND dp.cconcep IN(0, 1, 2, 3, 4, 5, 6, 7, 8, 11, 12, 13, 14, 26, 43, 50, 51, 52,
                                53, 54, 55, 56, 57, 58, 61, 62, 63, 64, 86)
         GROUP BY r.nrecibo, r.cagente, r.sseguro, r.cempres, m.fefeadm, r.fefecto, r.femisio,
                  s.npoliza, s.cramo, r.cgescob, s.sproduc, 10, r.ctiprec, d.smovrec, d.norden,
                  d.iimporte
         -- NO EXISTE DESCOBRO O ANULACIÓN EN COBROS PARCIALES (NO SE HAN DE BUSCAR ESTOS CASOS)
         -- PARA ANULAR UN COBRO PARCIAL SE COBRA LA TOTALIDAD DEL RECIBO Y SE
         -- GENERA UN RECIBO DE EXTORNO, COBRANDOSE AMBOS. POR LO QUE PARA LA
         -- LIQUIDACIÓN SOLO ES NECESARIO TENER EN CUENTA LOS COBROS.
         UNION
         ------ AHORA HACEMOS LAS SELECTS QUE RECUPEREN LOS RECIBOS EN CORRETAJE -----
         -- Bug 0027043 - JMF - 04/10/2013: Importes parciales mismo calculo que f_vdetrecibos
         SELECT   r.nrecibo, r.cagente, r.sseguro, r.cempres, m.fefeadm, r.fefecto, r.femisio,
                  s.npoliza, s.cramo, r.cgescob, s.sproduc,
                  SUM(DECODE(dp.cconcep, 0, dp.iconcep, 50, dp.iconcep, 0)) iprinet,
                  SUM(DECODE(dp.cconcep,
                             0, dp.iconcep_monpol,
                             50, dp.iconcep_monpol,
                             0)) iprinet_moncia,
                  SUM(ABS(cr.icombru)) icomisi, SUM(ABS(cr.icombru_moncia)) icomisi_moncia,
                  SUM(ABS(cr.icomret)) icomret, SUM(ABS(cr.icomret_moncia)) icomret_moncia,
                  SUM(DECODE(dp.cconcep, 0, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 1, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 2, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 3, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 4, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 5, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 6, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 7, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 8, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 14, dp.iconcep, 0)
                      - DECODE(dp.cconcep, 13, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 86, dp.iconcep, 0)
                      -- it1totr
                      + DECODE(dp.cconcep, 50, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 51, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 52, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 53, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 54, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 55, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 56, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 57, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 58, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 64, dp.iconcep, 0)
                      - DECODE(dp.cconcep, 63, dp.iconcep, 0)
                      -- it2totr
                      + DECODE(dp.cconcep, 26, dp.iconcep, 0)
                                                             -- iocorec
                  ) itotalr,
                  SUM(DECODE(dp.cconcep, 0, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 1, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 2, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 3, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 4, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 5, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 6, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 7, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 8, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 14, dp.iconcep_monpol, 0)
                      - DECODE(dp.cconcep, 13, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 86, dp.iconcep_monpol, 0)
                      -- it1totr
                      + DECODE(dp.cconcep, 50, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 51, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 52, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 53, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 54, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 55, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 56, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 57, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 58, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 64, dp.iconcep_monpol, 0)
                      - DECODE(dp.cconcep, 63, dp.iconcep_monpol, 0)
                      -- it2totr
                      + DECODE(dp.cconcep, 26, dp.iconcep_monpol, 0)
                                                                    -- iocorec
                  ) itotalr_moncia,
                  (SUM(DECODE(dp.cconcep, 4, dp.iconcep, 0)
                       + DECODE(dp.cconcep, 5, dp.iconcep, 0)
                       + DECODE(dp.cconcep, 6, dp.iconcep, 0)
                       + DECODE(dp.cconcep, 7, dp.iconcep, 0)
                       + DECODE(dp.cconcep, 86, dp.iconcep, 0)
                       -- it1imp
                       + DECODE(dp.cconcep, 54, dp.iconcep, 0)
                       + DECODE(dp.cconcep, 55, dp.iconcep, 0)
                       + DECODE(dp.cconcep, 56, dp.iconcep, 0)
                       + DECODE(dp.cconcep, 57, dp.iconcep, 0)
                                                              -- it2imp
                   )) itotimp,
                  (SUM(DECODE(dp.cconcep, 4, dp.iconcep_monpol, 0)
                       + DECODE(dp.cconcep, 5, dp.iconcep_monpol, 0)
                       + DECODE(dp.cconcep, 6, dp.iconcep_monpol, 0)
                       + DECODE(dp.cconcep, 7, dp.iconcep_monpol, 0)
                       + DECODE(dp.cconcep, 86, dp.iconcep_monpol, 0)
                       -- it1imp
                       + DECODE(dp.cconcep, 54, dp.iconcep_monpol, 0)
                       + DECODE(dp.cconcep, 55, dp.iconcep_monpol, 0)
                       + DECODE(dp.cconcep, 56, dp.iconcep_monpol, 0)
                       + DECODE(dp.cconcep, 57, dp.iconcep_monpol, 0)
                                                                     -- it2imp
                   )) itotimp_moncia,
                  10 cestrec, r.ctiprec, d.smovrec, d.norden, d.iimporte,
                  SUM(DECODE(dp.cconcep, 43, dp.iconcep, 0)) iconvoleoducto,
                  SUM(DECODE(dp.cconcep, 43, dp.iconcep_monpol, 0)) iconvoleoducto_moncia
             FROM movrecibo m, recibos r, seguros s, comrecibo cr, detmovrecibo d,
                  detmovrecibo_parcial dp
            WHERE m.nrecibo = r.nrecibo
              AND s.sseguro = r.sseguro
              AND m.smovagr = NVL(psmovagr, m.smovagr)
              AND m.nrecibo = NVL(pnrecibo, m.nrecibo)
              AND m.smovrec IN(SELECT MAX(x.smovrec)
                                 FROM movrecibo x
                                WHERE x.nrecibo = r.nrecibo
                                  AND x.cestrec = 0)
              AND((cr.icombru <> 0
                   AND r.cgescob IS NULL)
                  OR r.cgescob = 3)   --rebut amb comisions o gestió broker
              AND NOT EXISTS(SELECT '*'   --que el rebut no s'hagi liquidat mai
                               FROM liquidalin l, liquidacab lc
                              WHERE r.nrecibo = l.nrecibo
                                AND l.cagente = cr.cagente
                                AND l.nliqmen = lc.nliqmen
                                AND l.cagente = lc.cagente
                                AND l.cempres = lc.cempres
                                AND l.smovrec = d.smovrec
                                AND l.norden = d.norden
                                AND lc.cestado = 1)
              -- AND m.cestrec = 1   --Cobrat
              -- AND cr.cestrec = 1   --Cobrat
              AND d.smovrec = m.smovrec
              AND cr.nrecibo = r.nrecibo
              AND cr.cagente = NVL(pcagente, cr.cagente)
              AND DECODE(v_p_fefeadm_fmovdia, 1, TRUNC(m.fmovdia), TRUNC(m.fefeadm)) <
                                                                                    pfecliq + 1
              AND DECODE(v_p_fefeadm_fmovdia, 1, TRUNC(d.fmovimi), TRUNC(d.fefeadm)) <
                                                                                    pfecliq + 1
              AND r.cempres = pcempres
              AND pac_corretaje.f_tiene_corretaje(s.sseguro, NULL) = 1
              AND r.cestaux = 0   -- Bug 26022 - APD - 11/02/2013
              AND((r.cestimp <> 5)   --no domiciliat
                  OR(r.cestimp = 5   --domiciliat
                     AND m.fmovini >
                           r.fefecto   --que la data del moviment de cobrat sigui més gran que la data d'efecte
                     -- que hagin passat els dies de gestió a partir de la data d'efecte del moviment de cobrat
                     AND d_hoytrunc >= m.fmovini + v_diasliq)
                  OR(r.cestimp = 5   --domiciliat
                     AND m.fmovini <=
                           r.fefecto   --que la data del movimient de cobrat sigui menor o igual que la data d'efecte
                     -- que hagin passat els dies de gestió a partir de la data d'efecte del moviment de cobrat
                     AND d_hoytrunc >= r.fefecto + v_diasliq))
              AND dp.smovrec = m.smovrec
              AND dp.norden = d.norden
              AND dp.cconcep IN(0, 1, 2, 3, 4, 5, 6, 7, 8, 13, 14, 26, 43, 50, 51, 52, 53, 54,
                                55, 56, 57, 58, 63, 64, 86)
         GROUP BY r.nrecibo, r.cagente, r.sseguro, r.cempres, m.fefeadm, r.fefecto, r.femisio,
                  s.npoliza, s.cramo, r.cgescob, s.sproduc, 10, r.ctiprec, d.smovrec, d.norden,
                  d.iimporte
         ORDER BY nrecibo, norden;

      v_nliqlin      NUMBER := 0;
      v_signo        NUMBER := 1;
      v_icomisi      NUMBER := 0;
      v_icomisi_moncia NUMBER := 0;
      v_itasa        eco_tipocambio.itasa%TYPE;
      v_fcambio      DATE;
      -- Bug Ini 0027043/157331: AFM - 30/10/2013
      v_fechac       DATE;
      v_dd           CHAR(2);
      -- Bug Fin 0027043/157331: AFM - 30/10/2013
      v_factor       NUMBER;
      -- 23. 0022346: LCOL_A003-Cobro parcial de los recibos Fase 2 - 0126249 - Inicio
      vitotimp_det   vdetrecibos.itotimp%TYPE;
      viprinet_det   vdetrecibos.iprinet%TYPE;
      vitotalr_det   vdetrecibos.itotalr%TYPE;
      viretenc_det   vdetrecibos.ireccon%TYPE;
      vicomisi_det   vdetrecibos.icombru%TYPE;
      vitotimp_liq   liquidalin.itotimp%TYPE;
      viprinet_liq   liquidalin.iprinet%TYPE;
      vitotalr_liq   liquidalin.itotalr%TYPE;
      viretenc_liq   liquidalin.iretenccom%TYPE;
      vicomisi_liq   liquidalin.icomisi%TYPE;
      viconvoleoducto_det vdetrecibos.iconvoleoducto%TYPE;   -- Bug 25988/145805 - 06/06/2013 - AMC
      -- 23. 0022346: LCOL_A003-Cobro parcial de los recibos Fase 2 - 0126249 - Fin
      -- Bug 35979/206802: KJSC Variables para parametro y agente
      v_liquida_ageclave NUMBER;
      v_agente_ins   NUMBER;
   BEGIN
      v_pasexec := 10;

      IF v_p_liquida_ctipage IS NULL THEN
         v_pasexec := 20;
         v_cageliq := pcagente;
      ELSE
         v_pasexec := 30;
         v_cageliq := pac_agentes.f_get_cageliq(pcempres, v_p_liquida_ctipage, pcagente);
      END IF;

      -- Bug 35979/206802: KJSC Asignar variaBle nueva al parametro 'LIQUIDA_AGECLAVE'
      v_liquida_ageclave := NVL(pac_parametros.f_parempresa_n(pcempres, 'LIQUIDA_AGECLAVE'), 0);

      FOR rc IN c_rec LOOP   -- Procesamos los recibos
         v_pasexec := 60;
         pnliqmen := f_get_nliqmen(pcempres, rc.cagente, pfecliq, psproces, pmodo);
         -- Bug 35979/206802: KJSC Buscar si existe el parametro 'LIQUIDA_AGECLAVE' en la empresa consultar por cageclave
         v_agente_ins := NULL;

         IF v_liquida_ageclave = 1 THEN
            SELECT MAX(cageclave)
              INTO v_agente_ins
              FROM agentes_comp
             WHERE cagente = pcagente;

            SELECT NVL(MAX(nliqlin), 0)
              INTO v_nliqlin
              FROM liquidalin
             WHERE cempres = pcempres
               AND nliqmen = pnliqmen
               AND cagente = NVL(v_agente_ins, rc.cagente);
         ELSE
            SELECT NVL(MAX(nliqlin), 0)
              INTO v_nliqlin
              FROM liquidalin
             WHERE cempres = pcempres
               AND nliqmen = pnliqmen
               AND cagente = rc.cagente;
         END IF;

         IF v_agente_ins IS NULL THEN
            v_agente_ins := NVL(v_cageliq, rc.cagente);
         END IF;

         v_pasexec := 70;

         IF rc.cgescob = 3 THEN
            v_icomisi :=(-rc.itotalr + rc.icomisi);
            v_icomisi_moncia :=(-rc.itotalr_moncia + rc.icomisi_moncia);
         ELSE
            v_icomisi := rc.icomisi;
            v_icomisi_moncia := rc.icomisi_moncia;
         END IF;

         -- Proceso de liquidación, ajuste para los extornos - Inicio
         v_pasexec := 80;

         IF rc.ctiprec IN(9, 13) THEN
            v_signo := v_signo * -1;
         END IF;

         -- Calcular el factor proporcional del pago parcial respecto al importe total del recibo.
         -- Bug 0027043 - JMF - 04/10/2013: Importes parciales mismo calculo que f_vdetrecibos
         -- v_factor := rc.iimporte / rc.itotalr;
         v_factor := 1;
         -- Multimoneda
         v_pasexec := 90;

         IF v_cmultimon = 1 THEN
            v_pasexec := 100;

            -- Bug Ini 0027043/157331: AMF - 30/10/2013
            IF v_dd_cambio = 99 THEN   -- No hay dia de cambio
               v_pasexec := 105;
               num_err := pac_oper_monedas.f_datos_contraval(NULL, rc.nrecibo, NULL,
                                                             f_sysdate, 2, v_itasa, v_fcambio);
            ELSE   -- El día de cambio es uno concreto si la fecha liquidación es final de mes
               v_pasexec := 110;

               IF pfecliq = LAST_DAY(pfecliq) THEN
                  v_fechac := pfecliq + v_dd_cambio;
               ELSE
                  v_fechac := TRUNC(f_sysdate);
               END IF;

               --
               v_pasexec := 115;
               num_err := pac_oper_monedas.f_datos_contraval(NULL, rc.nrecibo, NULL, v_fechac,
                                                             2, v_itasa, v_fcambio);
            END IF;
         -- Bug Fin 0027043/157331: AFM - 30/10/2013
         END IF;

         v_pasexec := 120;
         v_nliqlin := v_nliqlin + 1;

         -- Bug 35979/206802: KJSC  Si v_agente_ins esta informado insertar v_agente_ins en agente
         INSERT INTO liquidalin
                     (cempres, nliqmen, cagente, nliqlin, nrecibo, smovrec,
                      itotimp,
                      itotalr,
                      iprinet,
                      icomisi,
                      iretenccom, isobrecomision, iretencsobrecom,
                      iconvoleducto, iretencoleoducto, ctipoliq,
                      itotimp_moncia,
                      itotalr_moncia,
                      iprinet_moncia,
                      icomisi_moncia,
                      iretenccom_moncia,
                      isobrecom_moncia, iretencscom_moncia,
                      iconvoleod_moncia,
                      iretoleod_moncia, fcambio, cagerec,
                      norden)
              VALUES (pcempres, pnliqmen, v_agente_ins, v_nliqlin, rc.nrecibo, rc.smovrec,
                      NVL(rc.itotimp, 0) * v_signo * v_factor,
                      NVL(rc.itotalr, 0) * v_signo * v_factor,
                      NVL(rc.iprinet, 0) * v_signo * v_factor,
                      NVL(v_icomisi, 0) * v_signo * v_factor,
                      NVL(rc.icomret, 0) * v_signo * v_factor, NULL, NULL,
                      rc.iconvoleoducto * v_signo * v_factor,   -- Bug 25988/145805 - 06/06/2013 - AMC
                                                             NULL, NULL,
                      -- Bug Ini 0027043/157331: AFM - 30/10/2013
                      f_round(DECODE(v_dd_cambio,
                                     99, rc.itotimp_moncia * v_signo * v_factor,
                                     NVL(rc.itotimp, 0) * v_signo * v_factor * v_itasa),
                              v_cmoncia),
                      f_round(DECODE(v_dd_cambio,
                                     99, rc.itotalr_moncia * v_signo * v_factor,
                                     NVL(rc.itotalr, 0) * v_signo * v_factor * v_itasa),
                              v_cmoncia),
                      f_round(DECODE(v_dd_cambio,
                                     99, rc.iprinet_moncia * v_signo * v_factor,
                                     NVL(rc.iprinet, 0) * v_signo * v_factor * v_itasa),
                              v_cmoncia),
                      f_round(DECODE(v_dd_cambio,
                                     99, v_icomisi_moncia * v_signo * v_factor,
                                     NVL(v_icomisi, 0) * v_signo * v_factor * v_itasa),
                              v_cmoncia),
                      f_round(DECODE(v_dd_cambio,
                                     99, rc.icomret_moncia * v_signo * v_factor,
                                     NVL(rc.icomret, 0) * v_signo * v_factor * v_itasa),
                              v_cmoncia),
                      NULL, NULL,
                      -- Bug 25988/145805 - 06/06/2013 - AMC
                      f_round(DECODE(v_dd_cambio,
                                     99, rc.iconvoleoducto_moncia * v_signo * v_factor,
                                     NVL(rc.iconvoleoducto, 0) * v_signo * v_factor * v_itasa),
                              v_cmoncia),
                      -- Bug Fin 0027043/157331: AFM - 30/10/2013
                      NULL, DECODE(v_cmultimon, 0, NULL, NVL(v_fcambio, f_sysdate)), pcagente,
                      rc.norden);

         -- Bug 0029334 - JMF - 11/12/2013
         -- Bug 0029334 - JMF - 11/12/2013
         IF v_p_calc_comind In (1,3) THEN
            num_err := f_crea_liquidalindet_dir(pnliqmen, NVL(v_cageliq, rc.cagente),
                                                v_nliqlin, pcempres, rc.nrecibo,
                                                SIGN(NVL(v_icomisi, 0) * v_signo), pfecliq,
                                                rc.norden, rc.smovrec);
         END IF;
      END LOOP;

      v_pasexec := 200;
      RETURN num_err;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param,
                     num_err || ' ' || SQLERRM);
         RETURN 108953;
   END f_set_recibos_parcial_liq;

   /*******************************************************************************
   FUNCION PAC_LIQUIDA.F_SET_RECIBOS_PARCIAL_LIQ_IND
   Inserta las comisiones indirectas de los recibos con pagos parciales pendientes
   de liquidar en las tablas de liquidaciones

   Parámetros:
      param in pcempres   : código de la empresa
      param in pcagente   : Agente
      param in pfecliq    : Fecha liquidación (hasta la que incluyen movimientos)
      param in pcageind   : Agente indirecto
      param in psproces   : Código de todo el proceso de liquidación para todos los agentes
      param in pmodo      : Pmodo = 0 Real y 1 Previo
      param in psmovagr   : Secuencial de agrupación de recibos (movrecibo.smovagr)

      return: number un número con el id del error, en caso de que todo vaya OK, retornará un cero.
   ********************************************************************************/
   FUNCTION f_set_recibos_parcial_liq_ind(
      pcempres IN NUMBER,
      pcagente IN NUMBER,
      pfecliq IN DATE,
      pcageind IN NUMBER,
      psproces IN NUMBER,
      pmodo IN NUMBER,
      pnliqmen OUT NUMBER,
      psmovagr IN NUMBER DEFAULT NULL,
      pnrecibo IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      v_object       VARCHAR2(500) := 'PAC_LIQUIDA.F_SET_RECIBOS_PARCIAL_LIQ_IND';
      v_param        VARCHAR2(500)
         := 'params - pcempres :' || pcempres || ' pcagente : ' || pcagente || ' pfecliq : '
            || pfecliq || ' pcageind : ' || pcageind;
      v_pasexec      NUMBER(5) := 1;
      num_err        NUMBER := 0;
      --
      v_diasliq      NUMBER := NVL(pac_parametros.f_parinstalacion_n('DIASLIQ'), 0);
      v_p_fefeadm_fmovdia NUMBER
                         := NVL(pac_parametros.f_parempresa_n(pcempres, 'FEFEADM_FMOVDIA'), 0);
      v_p_calc_comind NUMBER := NVL(pac_parametros.f_parempresa_n(pcempres, 'CALC_COMIND'), 0);
      v_cmultimon    NUMBER := NVL(pac_parametros.f_parempresa_n(pcempres, 'MULTIMONEDA'), 0);
      v_cmoncia      NUMBER := pac_parametros.f_parempresa_n(pcempres, 'MONEDAEMP');
      d_hoytrunc     DATE := TRUNC(f_sysdate);

      -- Bug 27043 - JMF - 10/09/2013: Rerforma select para optimizar
      -- Bug 21230 - APD - 16/04/2012 - se añade el parametro ppcageind
      -- se sustituye pcageind por ppcageind
      -- Bug 0027043 - JMF - 04/10/2013: Importes parciales mismo calculo que f_vdetrecibos
      CURSOR c_rec(ppcageind IN NUMBER) IS
         SELECT   r.nrecibo, r.cagente, r.sseguro, r.cempres, m.fefeadm, r.fefecto, r.femisio,
                  s.npoliza, s.cramo, r.cgescob, s.sproduc,
                  SUM(DECODE(dp.cconcep, 0, dp.iconcep, 50, dp.iconcep, 0)) iprinet,
                  SUM(DECODE(dp.cconcep,
                             0, dp.iconcep_monpol,
                             50, dp.iconcep_monpol,
                             0)) iprinet_moncia,
                  SUM(DECODE(dp.cconcep, 17, dp.iconcep, 61, dp.iconcep, 0)) icomisi,
                  SUM(DECODE(dp.cconcep,
                             17, dp.iconcep_monpol,
                             61, dp.iconcep_monpol,
                             0)) icomisi_moncia,
                  SUM(DECODE(dp.cconcep, 18, dp.iconcep, 62, dp.iconcep, 0)) icomret,
                  SUM(DECODE(dp.cconcep,
                             18, dp.iconcep_monpol,
                             62, dp.iconcep_monpol,
                             0)) icomret_moncia,
                  SUM(DECODE(dp.cconcep, 0, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 1, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 2, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 3, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 4, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 5, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 6, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 7, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 8, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 14, dp.iconcep, 0)
                      - DECODE(dp.cconcep, 13, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 86, dp.iconcep, 0)
                      -- it1totr
                      + DECODE(dp.cconcep, 50, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 51, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 52, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 53, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 54, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 55, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 56, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 57, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 58, dp.iconcep, 0)
                      + DECODE(dp.cconcep, 64, dp.iconcep, 0)
                      - DECODE(dp.cconcep, 63, dp.iconcep, 0)
                      -- it2totr
                      + DECODE(dp.cconcep, 26, dp.iconcep, 0)
                                                             -- iocorec
                  ) itotalr,
                  SUM(DECODE(dp.cconcep, 0, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 1, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 2, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 3, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 4, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 5, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 6, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 7, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 8, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 14, dp.iconcep_monpol, 0)
                      - DECODE(dp.cconcep, 13, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 86, dp.iconcep_monpol, 0)
                      -- it1totr
                      + DECODE(dp.cconcep, 50, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 51, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 52, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 53, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 54, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 55, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 56, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 57, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 58, dp.iconcep_monpol, 0)
                      + DECODE(dp.cconcep, 64, dp.iconcep_monpol, 0)
                      - DECODE(dp.cconcep, 63, dp.iconcep_monpol, 0)
                      -- it2totr
                      + DECODE(dp.cconcep, 26, dp.iconcep_monpol, 0)
                                                                    -- iocorec
                  ) itotalr_moncia,
                  (SUM(DECODE(dp.cconcep, 4, dp.iconcep, 0)
                       + DECODE(dp.cconcep, 5, dp.iconcep, 0)
                       + DECODE(dp.cconcep, 6, dp.iconcep, 0)
                       + DECODE(dp.cconcep, 7, dp.iconcep, 0)
                       + DECODE(dp.cconcep, 86, dp.iconcep, 0)
                       -- it1imp
                       + DECODE(dp.cconcep, 54, dp.iconcep, 0)
                       + DECODE(dp.cconcep, 55, dp.iconcep, 0)
                       + DECODE(dp.cconcep, 56, dp.iconcep, 0)
                       + DECODE(dp.cconcep, 57, dp.iconcep, 0)
                                                              -- it2imp
                   )) itotimp,
                  (SUM(DECODE(dp.cconcep, 4, dp.iconcep_monpol, 0)
                       + DECODE(dp.cconcep, 5, dp.iconcep_monpol, 0)
                       + DECODE(dp.cconcep, 6, dp.iconcep_monpol, 0)
                       + DECODE(dp.cconcep, 7, dp.iconcep_monpol, 0)
                       + DECODE(dp.cconcep, 86, dp.iconcep_monpol, 0)
                       -- it1imp
                       + DECODE(dp.cconcep, 54, dp.iconcep_monpol, 0)
                       + DECODE(dp.cconcep, 55, dp.iconcep_monpol, 0)
                       + DECODE(dp.cconcep, 56, dp.iconcep_monpol, 0)
                       + DECODE(dp.cconcep, 57, dp.iconcep_monpol, 0)
                                                                     -- it2imp
                   )) itotimp_moncia,
                  10 cestrec, d.smovrec, d.norden, d.iimporte
             FROM movrecibo m, recibos r, seguros s, detmovrecibo d, detmovrecibo_parcial dp
            WHERE m.nrecibo = r.nrecibo
              AND s.sseguro = r.sseguro
              AND m.smovagr = NVL(psmovagr, m.smovagr)   -- 21. 0022753
              AND m.nrecibo = NVL(pnrecibo, m.nrecibo)
              AND m.smovrec IN(SELECT MAX(x.smovrec)
                                 FROM movrecibo x
                                WHERE x.nrecibo = r.nrecibo
                                  AND x.cestrec = 0)
              AND((EXISTS(SELECT 1
                            FROM detmovrecibo_parcial dp2
                           WHERE dp2.smovrec = m.smovrec
                             AND dp2.cconcep = 17
                             AND NVL(dp2.iconcep, 0) <> 0)
                   AND r.cgescob IS NULL)
                  OR(r.cgescob = 3))   --rebut amb comisions o gestió broker
              AND NOT EXISTS(SELECT '*'   --que el rebut no s'hagi liquidat mai
                               FROM liquidalin l, liquidacab lc
                              WHERE l.nliqmen = lc.nliqmen
                                AND l.cagente = lc.cagente
                                AND l.cempres = lc.cempres
                                AND lc.cagente = pcagente
                                AND l.smovrec = d.smovrec
                                AND l.norden = d.norden
                                AND lc.cestado = 1)
              --AND m.cestrec = 1   --Cobrat
              AND d.smovrec = m.smovrec
              AND r.cagente = ppcageind
              AND DECODE(v_p_fefeadm_fmovdia, 1, TRUNC(m.fmovdia), TRUNC(m.fefeadm)) <= pfecliq
              AND DECODE(v_p_fefeadm_fmovdia, 1, TRUNC(d.fmovimi), TRUNC(d.fefeadm)) <= pfecliq
              AND r.cempres = pcempres
              AND r.cestaux = 0   -- Bug 26022 - APD - 11/02/2013
              AND((r.cestimp <> 5)   --no domiciliat
                  OR(r.cestimp = 5   --domiciliat
                     AND m.fmovini >
                           r.fefecto   --que la data del moviment de cobrat sigui més gran que la data d'efecte
                     -- que hagin passat els dies de gestió a partir de la data de movimient del movimient de cobrat
                     AND d_hoytrunc >=(m.fmovini + v_diasliq))
                  OR(r.cestimp = 5   --domiciliat
                     AND m.fmovini <=
                           r.fefecto   --que la data del movimient de cobrat sigui menor o igual que la data d'efecte
                     -- que hagin passat els dies de gestió a partir de la data de movimient del movimient de cobrat
                     AND d_hoytrunc >=(r.fefecto + v_diasliq)))
              AND dp.smovrec = m.smovrec
              AND dp.norden = d.norden
              AND dp.cconcep IN(0, 1, 2, 3, 4, 5, 6, 7, 8, 17, 18, 13, 14, 26, 43, 50, 51, 52,
                                53, 54, 55, 56, 57, 58, 61, 62, 63, 64, 86)
         GROUP BY r.nrecibo, r.cagente, r.sseguro, r.cempres, m.fefeadm, r.fefecto, r.femisio,
                  s.npoliza, s.cramo, r.cgescob, s.sproduc, 10, d.smovrec, d.norden,
                  d.iimporte
         ORDER BY nrecibo, norden;

      -- NO EXISTE DESCOBRO O ANULACIÓN EN COBROS PARCIALES (NO SE HAN DE BUSCAR ESTOS CASOS)
      -- PARA ANULAR UN COBRO PARCIAL SE COBRA LA TOTALIDAD DEL RECIBO Y SE
      -- GENERA UN RECIBO DE EXTORNO, COBRANDOSE AMBOS. POR LO QUE PARA LA
      -- LIQUIDACIÓN SOLO ES NECESARIO TENER EN CUENTA LOS COBROS.
      v_nliqlin      NUMBER := 0;
      v_signo        NUMBER := 1;
      v_icomisi      NUMBER := 0;
      v_icomisi_moncia NUMBER := 0;
      v_itasa        eco_tipocambio.itasa%TYPE;
      v_fcambio      DATE;
      vcageind       NUMBER;   -- Bug 21230 - APD - 21/02/2012
      vcagente       NUMBER;   -- Bug 21230 - APD - 21/02/2012
      v_factor       NUMBER;
      -- 23. 0022346: LCOL_A003-Cobro parcial de los recibos Fase 2 - 0126249 - Inicio
      vitotimp_det   vdetrecibos.itotimp%TYPE;
      viprinet_det   vdetrecibos.iprinet%TYPE;
      vitotalr_det   vdetrecibos.itotalr%TYPE;
      viretenc_det   vdetrecibos.ireccon%TYPE;
      vicomisi_det   vdetrecibos.icombru%TYPE;
      vitotimp_liq   liquidalin.itotimp%TYPE;
      viprinet_liq   liquidalin.iprinet%TYPE;
      vitotalr_liq   liquidalin.itotalr%TYPE;
      viretenc_liq   liquidalin.iretenccom%TYPE;
      vicomisi_liq   liquidalin.icomisi%TYPE;
   -- 23. 0022346: LCOL_A003-Cobro parcial de los recibos Fase 2 - 0126249 - Fin
   BEGIN
      v_pasexec := 10;

      -- Bug 21230 - APD - 15/04/2012 - segun el calculo de la comision
      -- indirecta, los recibos se deben buscar del agente o del agente indirecto
      IF v_p_calc_comind = 2 THEN
         -- Por agente indirecto y modalidad indirecta en el cuadro asignado al agente
         vcageind := pcageind;
      ELSIF v_p_calc_comind in (1,3) THEN
         -- por cuadros de comisión indirecta pero modalidad directa
         vcageind := pcagente;
      ELSE
         vcageind := NULL;
      END IF;

      v_pasexec := 20;

      -- fin Bug 21230 - APD - 15/04/2012
      IF vcageind IS NOT NULL THEN
         -- Bug 21230 - APD - 15/04/2012 - segun el calculo de la comision
         -- indirecta, la liquidacion del agente se hace al agente o al agente indirecto
         v_pasexec := 30;

         IF v_p_calc_comind = 2 THEN
            vcagente := pcagente;
         ELSIF v_p_calc_comind in (1,3) THEN
            vcagente := pcageind;
         END IF;

         -- Buscamos el nliqmen del cagente de la liqui.
         v_pasexec := 40;
         pnliqmen := f_get_nliqmen(pcempres, vcagente, pfecliq, psproces, pmodo);
         -- buscamos el nliqlin
            -- Ini BUG 21606 - 26/03/2012 - JMC
         v_pasexec := 50;

         SELECT NVL(MAX(nliqlin), 0)
           INTO v_nliqlin
           FROM liquidalin
          WHERE cempres = pcempres
            AND nliqmen = pnliqmen
            AND cagente = vcagente;

         -- Ini BUG 21606 - 26/03/2012 - JMC
                             --
         -- Bug 21230 - APD - 15/04/2012 - se le pasa el agente indirecto
         -- al cursor
         v_pasexec := 60;

         FOR rc IN c_rec(vcageind) LOOP   -- Procesamos los recibos
            -- Bug 18843/91812 - 06/09/2011 - AMC
            IF rc.cgescob = 3 THEN
               v_pasexec := 70;
               v_icomisi :=(-rc.itotalr + rc.icomisi);
               v_icomisi_moncia :=(-rc.itotalr_moncia + rc.icomisi_moncia);
            ELSE
               v_pasexec := 80;
               v_icomisi := rc.icomisi;
               v_icomisi_moncia := rc.icomisi_moncia;
            END IF;

            -- Fi Bug 18843/91812 - 06/09/2011 - AMC
            v_pasexec := 90;

            IF rc.cestrec = 20 THEN
               v_signo := -1;
            ELSE
               v_signo := 1;
            END IF;

            -- Calcular el factor proporcional del pago parcial respecto al importe total del recibo.
            v_pasexec := 100;
            -- Bug 0027043 - JMF - 04/10/2013: Importes parciales mismo calculo que f_vdetrecibos
            -- v_factor := rc.iimporte / rc.itotalr;
            v_factor := 1;
            -- BUG 18423 - 02/11/2011 - JMP - LCOL000 - Multimoneda
            v_pasexec := 110;

            IF v_cmultimon = 1 THEN
               v_pasexec := 130;
               num_err := pac_oper_monedas.f_datos_contraval(NULL, rc.nrecibo, NULL,
                                                             f_sysdate, 2, v_itasa, v_fcambio);
            END IF;

            v_pasexec := 145;
            v_nliqlin := v_nliqlin + 1;
            v_pasexec := 180;

            -- FIN BUG 18423 - 02/11/2011 - JMP - LCOL000 - Multimoneda
            BEGIN
               -- Aumentamos el nliqlin
               v_pasexec := 190;

               INSERT INTO liquidalin
                           (cempres, nliqmen, cagente, nliqlin, nrecibo,
                            smovrec, itotimp,
                            itotalr,
                            iprinet,
                            icomisi,
                            iretenccom, isobrecomision, iretencsobrecom, iconvoleducto,
                            iretencoleoducto, ctipoliq,
                            -- BUG 18423 - 02/11/2011 - JMP - LCOL000 - Multimoneda
                            itotimp_moncia,
                            itotalr_moncia,
                            iprinet_moncia,
                            icomisi_moncia,
                            iretenccom_moncia, isobrecom_moncia,
                            iretencscom_moncia, iconvoleod_moncia, iretoleod_moncia,
                            fcambio, norden)
                    VALUES (rc.cempres, pnliqmen, vcagente, v_nliqlin, rc.nrecibo,
                            rc.smovrec, NVL(rc.itotimp, 0) * v_signo * v_factor,
                            NVL(rc.itotalr, 0) * v_signo * v_factor,
                            NVL(rc.iprinet, 0) * v_signo * v_factor,
                            NVL(v_icomisi, 0) * v_signo * v_factor,
                            NVL(rc.icomret, 0) * v_signo * v_factor, NULL, NULL, NULL,
                            NULL, NULL,
                            -- BUG 18423 - 02/11/2011 - JMP - LCOL000 - Multimoneda
                            f_round(rc.itotimp_moncia * v_signo * v_factor, v_cmoncia),
                            f_round(rc.itotalr_moncia * v_signo * v_factor, v_cmoncia),
                            f_round(rc.iprinet_moncia * v_signo * v_factor, v_cmoncia),
                            f_round(v_icomisi_moncia * v_signo * v_factor, v_cmoncia),
                            f_round(rc.icomret_moncia * v_signo * v_factor, v_cmoncia), NULL,
                            NULL, NULL, NULL,
                            DECODE(v_cmultimon, 0, NULL, NVL(v_fcambio, f_sysdate)), rc.norden);

               -- Bug 0029334 - JMF - 11/12/2013
               IF v_p_calc_comind In (1,3) THEN
                  -- por cuadros de comisión indirecta pero modalidad directa
                  num_err := f_crea_liquidalindet_ind(pnliqmen, vcagente, v_nliqlin,
                                                      rc.cempres, rc.nrecibo,
                                                      SIGN(NVL(v_icomisi, 0) * v_signo
                                                           * v_factor),
                                                      pfecliq, rc.norden, rc.smovrec);
               END IF;
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param,
                              '------------->  DUP VAL ON INDEX  .- v_nliqlin = '
                              || ' cempres ' || rc.cempres || ' nliqmen ' || pnliqmen
                              || ' cagente = ' || vcagente || ' nliqlin  ' || v_nliqlin);
                  RETURN 108953;
            END;
         -- fin Bug 21230 - APD - 15/04/2012
         END LOOP;
      END IF;

      v_pasexec := 200;
      RETURN num_err;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
         RETURN 108953;
   END f_set_recibos_parcial_liq_ind;

-- 22. 0022346: LCOL_A003-Cobro parcial de los recibos Fase 2 - Fin

   -- BUG 29023 - FAL - 26/11/2013
   FUNCTION f_agrupa_pagocomisi_directas(pcempres IN NUMBER, vsproliq IN NUMBER)
      RETURN NUMBER IS
      v_object       VARCHAR2(500) := 'PAC_LIQUIDA.F_AGRUPA_PAGOCOMISI_DIRECTAS';
      v_param        VARCHAR2(500)
                            := 'params - pcempres :' || pcempres || ' vsproliq : ' || vsproliq;
      v_pasexec      NUMBER(5) := 1;
      vpago          pagoscomisiones.spago%TYPE;
      v_fliquida     liquidacab.fliquid%TYPE;
      v_nnumlin      ctactes.nnumlin%TYPE;
      vctipban       agentes.ctipban%TYPE;
      vcbancar       agentes.cbancar%TYPE;
      vcdebhab       pagoscomisiones.ctipopag%TYPE;
      v_cmoncia      NUMBER;
   BEGIN
      -- Bug 29023 - AGM800 - Agrupación de pago al grupo coordinación - 22-VII-2014 - dlF
      FOR reg IN (SELECT     DECODE(r.ctipage,
                                    8, r.cagente,
                                    pac_redcomercial.f_busca_padre(10, p.cagente, 8, NULL))
                                                                                      cagente,
                             SUM(p.iimporte) importe
                        FROM pagoscomisiones p, redcomercial r
                       WHERE p.cagente IN(SELECT cagente
                                            FROM liquidacab
                                           WHERE sproliq = vsproliq)
                         AND p.cagente IN(SELECT cagente
                                            FROM redcomercial
                                           WHERE cempres = pcempres
                                             AND cpadre IS NOT NULL)
                         AND(p.cestado = 0
                             OR p.nremesa IS NULL)
                         AND p.cempres = pcempres
                         AND p.cagente = r.cagente
                         AND r.cempres = pcempres
                         AND r.fmovfin IS NULL
                         AND r.ctipage >= 8
                         AND(p.cagente, p.nnumlin) IN(SELECT cagente, nnumlin
                                                        FROM ctactes
                                                       WHERE sproces = vsproliq)
                         AND LEVEL = 1
                  CONNECT BY PRIOR r.cpadre = r.cagente
                         AND PRIOR r.cempres = r.cempres
                  START WITH r.cagente = p.cagente
                         AND r.cempres = pcempres
                    GROUP BY DECODE(r.ctipage,
                                    8, r.cagente,
                                    pac_redcomercial.f_busca_padre(10, p.cagente, 8, NULL))) LOOP
         SELECT seqpago.NEXTVAL
           INTO vpago
           FROM DUAL;

         SELECT DISTINCT fliquid
                    INTO v_fliquida
                    FROM liquidacab
                   WHERE sproliq = vsproliq;

         SELECT NVL(MAX(nnumlin), 0) + 1
           INTO v_nnumlin
           FROM ctactes
          WHERE cagente = reg.cagente;

         BEGIN
            SELECT ctipban, cbancar
              INTO vctipban, vcbancar
              FROM agentes
             WHERE cagente = reg.cagente;
         EXCEPTION
            WHEN OTHERS THEN
               vctipban := NULL;
               vcbancar := NULL;
         END;

         vcdebhab := 1;

         -- negativo al haber
         IF reg.importe < 0 THEN
            vcdebhab := 2;
         END IF;

         IF NVL(pac_parametros.f_parempresa_n(pcempres, 'MULTIMONEDA'), 0) = 1 THEN
            v_cmoncia := pac_parametros.f_parempresa_n(pcempres, 'MONEDAEMP');
         END IF;

         INSERT INTO pagoscomisiones
                     (spago, cempres, cagente, iimporte, cestado,
                      fliquida, cusuario, falta, cforpag, ctipopag, nremesa, ftrans, nnumlin,
                      ctipban, cbancar)
              VALUES (vpago, pcempres, reg.cagente, f_round(ABS(reg.importe), v_cmoncia), 0,
                      v_fliquida, f_user, f_sysdate, 2, vcdebhab, NULL, NULL, v_nnumlin,
                      vctipban, vcbancar);

         FOR pagospend IN (SELECT p.spago
                             FROM pagoscomisiones p, redcomercial r
                            WHERE p.cagente IN(SELECT cagente
                                                 FROM liquidacab
                                                WHERE sproliq = vsproliq)
                              AND p.cagente IN(SELECT cagente
                                                 FROM redcomercial
                                                WHERE cempres = pcempres
                                                  -- AND pac_agentes.f_get_cageind(cagente, f_sysdate) IS NULL
                                                  AND cpadre IS NOT NULL)
                              AND(p.cestado = 0
                                  OR nremesa IS NULL)
                              AND p.cempres = pcempres
                              AND p.cagente = r.cagente
                              AND r.cempres = pcempres
                              AND r.fmovfin IS NULL
                              AND(pac_redcomercial.f_busca_padre(10, p.cagente, 8, NULL) =
                                                                                    reg.cagente
                                  OR(p.cagente = reg.cagente
                                     AND r.ctipage = 8
                                     AND p.spago <> vpago))
                              AND(p.cagente, p.nnumlin) IN(SELECT cagente, nnumlin
                                                             FROM ctactes
                                                            WHERE sproces = vsproliq)) LOOP
            UPDATE pagoscomisiones
               SET cestado = 1
             WHERE spago = pagospend.spago;
         END LOOP;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
         RETURN 108953;
   END f_agrupa_pagocomisi_directas;

-- FI BUG 29023 - FAL - 26/11/2013
-- end 29023 - AGM800 - Agrupación de pago al grupo coordinación - 22-VII-2014 - dlF

   -- Inicio Bug 32674 MMS 20141006
   FUNCTION f_valor_recaudo(
      pnrecibo IN recibos.nrecibo%TYPE,
      psmovrec IN movrecibo.smovrec%TYPE,
      pimpiprinet OUT NUMBER,
      pimpiprinet_monpol OUT NUMBER,
      pimpicomisi OUT NUMBER,
      pimpicomisi_monpol OUT NUMBER,
      pimpicomret OUT NUMBER,
      pimpicomret_monpol OUT NUMBER,
      pimpitotalr OUT NUMBER,
      pimpitotalr_monpol OUT NUMBER,
      pimpitotimp OUT NUMBER,
      pimpitotimp_monpol OUT NUMBER)
      RETURN NUMBER IS
      v_object       VARCHAR2(500) := 'PAC_LIQUIDA.f_valor_recaudo';
      v_param        VARCHAR2(500)
                              := 'params - pnrecibo:' || pnrecibo || ' psmovrec: ' || psmovrec;
      v_pasexec      NUMBER(5) := 1;
   BEGIN
/*
Campos a recuperar:
        Iprinet >> (cconcep 0 + cconcep 50)
        Icomisi >> (cconcep 11 + cconcep 61)
        Icomret >> (cconcep 12 + cconcep 62)
        Itotalr >> (cconcep que suman 0, 1, 2, 3, 4, 5, 6, 7, 8, 14, 86, 50, 51, 52, 53, 54, 55, 56, 57, 58, 64) – (cconcep que restan 13, 63)
        Itotimp >> (cconcep que suman 4, 5, 6, 7, 54, 55, 56, 57)
*/
      SELECT SUM(DECODE(cconcep, 0, iconcep, 0)) iprinet,
             SUM(DECODE(cconcep, 0, iconcep_monpol, 0)) iprinet_monpol
        INTO pimpiprinet,
             pimpiprinet_monpol
        FROM detrecibos_fcambio
       WHERE nrecibo = pnrecibo
         AND smovrec = psmovrec
         AND cconcep IN(0, 50);

      SELECT SUM(DECODE(cconcep, 0, iconcep, 0)) iprinet,
             SUM(DECODE(cconcep, 0, iconcep_monpol, 0)) iprinet_monpol
        INTO pimpicomisi,
             pimpicomisi_monpol
        FROM detrecibos_fcambio
       WHERE nrecibo = pnrecibo
         AND smovrec = psmovrec
         AND cconcep IN(11, 61);

      SELECT SUM(DECODE(cconcep, 0, iconcep, 0)) pimpicomret,
             SUM(DECODE(cconcep, 0, iconcep_monpol, 0)) pimpicomret_monpol
        INTO pimpicomret,
             pimpicomret_monpol
        FROM detrecibos_fcambio
       WHERE nrecibo = pnrecibo
         AND smovrec = psmovrec
         AND cconcep IN(12, 62);

      SELECT SUM(z.impitotalr_mas) - SUM(z.impitotalr_menos),
             SUM(z.impitotalr_monpol_mas) - SUM(z.impitotalr_monpol_menos)
        INTO pimpitotalr,
             pimpitotalr_monpol
        FROM (SELECT SUM(iconcep) impitotalr_mas, 0 impitotalr_menos,
                     SUM(iconcep_monpol) impitotalr_monpol_mas, 0 impitotalr_monpol_menos
                FROM detrecibos_fcambio
               WHERE nrecibo = pnrecibo
                 AND smovrec = psmovrec
                 AND cconcep IN(0, 1, 2, 3, 4, 5, 6, 7, 8, 14, 86, 50, 51, 52, 53, 54, 55, 56,
                                57, 58, 64)
              UNION
              SELECT 0 iprinet_mas, SUM(iconcep) iprinet_menos, 0 iprinet_monpol_mas,
                     SUM(iconcep_monpol) iprinet_monpol_menos
                FROM detrecibos_fcambio
               WHERE nrecibo = pnrecibo
                 AND smovrec = psmovrec
                 AND cconcep IN(13, 63, 21)) z;

      SELECT SUM(DECODE(cconcep, 0, iconcep, 0)), SUM(DECODE(cconcep, 0, iconcep_monpol, 0))
        INTO pimpitotimp, pimpitotimp_monpol
        FROM detrecibos_fcambio
       WHERE nrecibo = pnrecibo
         AND smovrec = psmovrec
         AND cconcep IN(4, 5, 6, 7, 54, 55, 56, 57);

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
         RETURN 108953;
   END f_valor_recaudo;
-- Fin Bug 32674 MMS 20141006
  FUNCTION f_validar_ccc_age(pcempres IN NUMBER,
                              psproliq IN NUMBER) RETURN NUMBER IS
      v_object  VARCHAR2(500) := 'PAC_LIQUIDA.f_validar_ccc_age';
      v_param   VARCHAR2(500) := 'params - pcempres:' || pcempres || ' psproliq: ' ||
                                 psproliq;
      v_pasexec NUMBER(5) := 1;
      v_i       NUMBER := 1;
      v_count  NUMBER :=0;
      CURSOR c_agente IS
         SELECT lc.cagente,
                lc.sproliq,
                lc.nliqmen
           FROM liquidacab lc
          WHERE lc.cempres = pcempres
            AND lc.sproliq = psproliq
          GROUP BY lc.cagente,lc.sproliq,lc.nliqmen;
   BEGIN

      FOR c IN c_agente LOOP

          SELECT count(*) into v_count
          FROM  agentes ag
         WHERE ag.cagente= c.cagente and cbancar is not  null;

     IF  v_count = 0 THEN
         INSERT INTO PROCESOSLIN
            (SPROCES,
             NPROLIN,
             NPRONUM,
             TPROLIN,
             FPROLIN,
             CESTADO,
             CTIPLIN)
         VALUES
            (c.sproliq,
             (SELECT nvl(MAX(NPROLIN),0)+1 from procesoslin where sproces=c.sproliq),
             0,
             'Agente ' || c.cagente || ' sin cuenta infomada',
             f_sysdate,
             0,
             v_i);
            DELETE FROM LIQUIDALIN
         WHERE CAGENTE = c.cagente
         AND nliqmen=c.nliqmen;
         --
         DELETE FROM LIQUIDACAB
          WHERE CAGENTE = c.cagente
            AND SPROLIQ = c.sproliq
            AND nliqmen=c.nliqmen;

            END IF;

         v_i := v_i + 1;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate,
                     f_user,
                     v_object,
                     v_pasexec,
                     v_param,
                     SQLERRM);
         RETURN 108953;

   END f_validar_ccc_age;

   FUNCTION f_signo_comision_age(pcempres IN NUMBER,
                                 psproliq IN NUMBER) RETURN NUMBER IS
      v_object  VARCHAR2(500) := 'PAC_LIQUIDA.f_signo_comision_age';
      v_param   VARCHAR2(500) := 'params - pcempres:' || pcempres || ' psproliq: ' ||
                                 psproliq;
      v_pasexec NUMBER(5) := 1;
      v_i       NUMBER := 1;
      v_comis   NUMBER;
      v_comis_sum   NUMBER;
      v_count       NUMBER;
      v_import_ctates  NUMBER;
      CURSOR c_agente IS
         SELECT lc.cagente,
                lc.sproliq,
                lc.nliqmen
           FROM liquidacab lc
          WHERE lc.CEMPRES = pcempres
            AND lc.SPROLIQ = psproliq;
   BEGIN



      FOR reg IN c_agente LOOP
      SELECT NVL(SUM(ICOMISI) - SUM(IRETENCCOM),0)
      into v_comis FROM
      LIQUIDALIN
        WHERE CAGENTE = reg.cagente
        AND   NLIQMEN = reg.nliqmen;



        select sum(decode(cdebhab,1,1,2,-1)*(iimport))
        into v_import_ctates
        from ctactes
        where cagente=reg.cagente and cestado=1;

        v_comis_sum:=v_comis+v_import_ctates;


        IF v_comis_sum < 0  THEN

         INSERT INTO PROCESOSLIN
            (SPROCES,
             NPROLIN,
             NPRONUM,
             TPROLIN,
             FPROLIN,
             CESTADO,
             CTIPLIN)
         VALUES
            (reg.sproliq,
             (SELECT nvl(MAX(NPROLIN),0)+1 from procesoslin where sproces=reg.sproliq),
             0,
             'Agente ' ||reg.cagente || ' tiene un liquidacion negativa',
             f_sysdate,
             0,
             v_i);


            DELETE FROM LIQUIDALIN
                 WHERE CAGENTE = reg.cagente
                 AND nliqmen=reg.nliqmen;
         --
             DELETE FROM LIQUIDACAB
              WHERE CAGENTE = reg.cagente
                AND SPROLIQ = reg.sproliq
                AND nliqmen=reg.nliqmen;

         v_i := v_i + 1;
           END IF;
      END LOOP;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate,
                     f_user,
                     v_object,
                     v_pasexec,
                     v_param,
                     SQLERRM);
         RETURN 108953;

   END f_signo_comision_age;

   FUNCTION f_esautoliq_conta(p_rec IN NUMBER, p_smovrec IN NUMBER)
      RETURN NUMBER IS
      n_ret          NUMBER;
      vrecunificado  NUMBER;
      vmovimiento    NUMBER;
   BEGIN

      BEGIN
         --Si está en la tabla de unificados, se busca el agrupador que es el recibo que se liquida y el movimiento
        SELECT nrecunif INTO vrecunificado
        FROM adm_recunif
        WHERE nrecibo = p_rec;
        SELECT m2.smovrec INTO vmovimiento
        FROM movrecibo m1, adm_recunif a1, movrecibo m2
        WHERE m1.nrecibo = a1.nrecibo
          AND m1.nrecibo =  p_rec AND m1.smovrec = p_smovrec
          AND m2.nrecibo = a1.nrecunif AND m1.smovagr = m2.smovagr;
        --Recibos unificados, pero contabilizamos recIbos hijos

      EXCEPTION
           WHEN NO_DATA_FOUND THEN
              --Recibos NO unificados
            vmovimiento := p_smovrec;
            vrecunificado := p_rec;

      END;
      SELECT DECODE(COUNT(1), 0, 0, 1)
          INTO n_ret
      FROM liquidacab a, liquidalin b
      WHERE a.cestautoliq = 2
                 AND b.smovrec = vmovimiento
                 AND a.ctipoliq = 0
                 AND b.nliqmen = a.nliqmen
                 AND b.cagente = a.cagente
                 AND b.cempres = a.cempres
                 AND b.nrecibo = vrecunificado;

      RETURN n_ret;
   END f_esautoliq_conta;

   /***********************************************************************
   FUNCTION f_ccobban_autoliq_conta
   Devuelve código cobrador bancario de autoliquidaciones
   param in p_rec: recibo
   param in p_mov: smovrec del recibo
   return:         ccobban
   -- JMF  bug 0035609/0206695 10/06/2015 -- Se utiliza en select contabilidad
   ***********************************************************************/
   FUNCTION f_ccobban_autoliq_conta(p_rec IN NUMBER, p_mov IN NUMBER)
      RETURN NUMBER IS
      --
      v_ret          cobbancario.ccobban%TYPE;
      v_fec          DATE;
      vmovimiento    NUMBER;
      vrecunificado  NUMBER;
   BEGIN
      BEGIN
        --Si está en la tabla de unificados, se busca el agrupador que es el recibo que se liquida y el movimiento
        SELECT nrecunif INTO vrecunificado
        FROM adm_recunif
        WHERE nrecibo = p_rec;
        SELECT m2.smovrec INTO vmovimiento
        FROM movrecibo m1, adm_recunif a1, movrecibo m2
        WHERE m1.nrecibo = a1.nrecibo
          AND m1.nrecibo =  p_rec AND m1.smovrec = p_mov
          AND m2.nrecibo = a1.nrecunif AND m1.smovagr = m2.smovagr;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
            --Recibos sin unificar
            vmovimiento := p_mov;
            vrecunificado := p_rec;
      END;
      SELECT GREATEST(r.fefecto, TRUNC(m.fefeadm))
        INTO v_fec
        FROM recibos r, movrecibo m
       WHERE r.nrecibo = vrecunificado
         AND m.nrecibo = r.nrecibo
         AND m.smovrec = vmovimiento;

      SELECT MAX(c.cbanco)
        INTO v_ret
        FROM liquidacab a, liquidalin b, liquidacobros c
       WHERE a.cestautoliq = 2
         AND a.fliquid = (SELECT MAX(a1.fliquid)
                            FROM liquidacab a1
                           WHERE a1.cempres = b.cempres
                             AND a1.cagente = b.cagente
                             AND a1.fliquid <= v_fec   /*p_fec*/
                             AND a1.ctipoliq = 0
                             AND a1.cestautoliq = 2
                             AND a1.nliqmen = b.nliqmen)
         AND a.ctipoliq = 0
         AND b.nliqmen = a.nliqmen
         AND b.cagente = a.cagente
         AND b.cempres = a.cempres
         AND b.nrecibo = vrecunificado   /*p_rec*/
         AND c.cempres = b.cempres
         AND c.cagente = b.cagente
         AND c.sproliq = a.sproliq;

      RETURN v_ret;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_LIQUIDA.f_ccobban_autoliq_conta', 1,
                     'parametros: p_rec =' || p_rec || ' mov=' || p_mov||' recunif=' || vrecunificado||' movagr=' || vmovimiento,
                     SQLCODE || ' ' || SQLERRM);
         RETURN NULL;
   END f_ccobban_autoliq_conta;


   FUNCTION f_rec_agrupador(p_rec IN NUMBER)
      RETURN NUMBER IS
      vrecunificado  NUMBER;
   BEGIN

      BEGIN
         --Si está en la tabla de unificados, se busca el agrupador que es el recibo que se liquida
        SELECT nrecunif INTO vrecunificado
        FROM adm_recunif
        WHERE nrecibo = p_rec;

      EXCEPTION
           WHEN NO_DATA_FOUND THEN
              --Recibos NO unificados
              vrecunificado := p_rec;
      END;

      RETURN vrecunificado;
   END f_rec_agrupador;


   FUNCTION f_mov_agrupador(p_rec IN NUMBER, p_mov IN NUMBER)
      RETURN NUMBER IS
      vmovimiento    NUMBER;
   BEGIN
        --Si está en la tabla de unificados, se busca el mov agrupador que se ha liquidado
        SELECT m2.smovrec INTO vmovimiento
        FROM movrecibo m1, adm_recunif a1, movrecibo m2
        WHERE m1.nrecibo = a1.nrecibo
          AND m1.nrecibo = p_rec AND m1.smovrec = p_mov
          AND m2.nrecibo = a1.nrecunif AND m1.smovagr = m2.smovagr;

       RETURN vmovimiento;

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         --Recibos NO unificados
         vmovimiento := p_mov;
         RETURN vmovimiento;
   END f_mov_agrupador;

   PROCEDURE proceso_update_irpf(
       agente_ins IN NUMBER,
      icomisi IN NUMBER,
      vimpicomret IN OUT NUMBER,
      v_nrecibo IN NUMBER,
      v_nmovimi IN NUMBER,
      cagente IN NUMBER,
      signo   IN NUMBER,
      pcerror OUT NUMBER) IS
      new_vimpicomret  NUMBER;
      v_nnumcom     NUMBER;
      v_pretenc          NUMBER;
      v_pasexec NUMBER(5) := 1;
       num_err   NUMBER := 0;
      v_object       VARCHAR2(200) := 'PAC_LIQUIDA.proceso_update_irpf';
      v_param        VARCHAR2(200)
         := 'params : agente_ins=' || agente_ins || ' icomisi=' || icomisi || ' vimpicomret=' || vimpicomret
            || ' nrecibo=' || v_nrecibo || ' nmovimi=' || v_nmovimi|| ' cagente=' || cagente || ' signo=' || signo;
      e_object_error EXCEPTION;   -- 48
   BEGIN
      SELECT nvl(r.pretenc,0)
                INTO v_pretenc
                  FROM RETENCIONES r,  AGENTES a
                  WHERE r.CRETENC = a.cretenc
                  AND   F_SYSDATE BETWEEN FINIVIG AND NVL(FFINVIG, F_SYSDATE)

                  AND   a.cagente = agente_ins;

            new_vimpicomret :=  f_round((icomisi * v_pretenc)/100);



            IF (vimpicomret <> new_vimpicomret) and   signo = 1 THEN

                 p_control_Error('JMT','ACUALIZA_IRPF','nrecibo:'||v_nrecibo);
                  FOR ricon IN (SELECT nrecibo, cgarant, nriesgo
                          FROM detrecibos
                          where nrecibo = v_nrecibo
                            and cconcep = 11) LOOP



                       UPDATE DETRECIBOS
                          SET ICONCEP= f_round((select nvl(iconcep,0)
                                                  from detrecibos
                                                 where nrecibo = v_nrecibo
                                                   and cconcep=11
                                                   and cgarant= ricon.cgarant
                                                   and nriesgo = ricon.nriesgo ) * v_pretenc/100)
                         WHERE nrecibo=v_nrecibo
                           AND cconcep=12
                           AND cgarant = ricon.cgarant
                           AND  nriesgo = ricon.nriesgo;

                            IF (SQL%ROWCOUNT = 0) THEN

                          INSERT INTO DETRECIBOS (nrecibo, cconcep, cgarant, nriesgo, iconcep)
                          VALUES (v_nrecibo, 12, ricon.cgarant, ricon.nriesgo, f_round((select nvl(iconcep,0)
                                                  from detrecibos
                                                 where nrecibo = v_nrecibo
                                                   and cconcep=11
                                                   and cgarant= ricon.cgarant
                                                   and nriesgo = ricon.nriesgo ) * v_pretenc/100));

                        END IF;
                  END LOOP;


                 --Actulizar vdetrecibos y vdetrecibos_monpol

                 delete from vdetrecibos_monpol where nrecibo =  v_nrecibo;

                 delete from vdetrecibos where nrecibo =  v_nrecibo;

                 num_err := f_vdetrecibos('R',v_nrecibo);



                -- Volver a obtener el total de laretencion del recibo


                select sum(nvl(iconcep,0))
                  into new_vimpicomret
                from  detrecibos
                where nrecibo = v_nrecibo
                  and cconcep = 12;


                SELECT nvl(MAX(nvl(NNUMCOM,0)), 0 ) into v_nnumcom FROM COMRECIBO WHERE nrecibo= v_nrecibo;




                  IF v_nnumcom<>0 THEN
                     v_pasexec := 311;

                  INSERT INTO COMRECIBO(NRECIBO,
                                        NNUMCOM,
                                        CAGENTE,
                                        CESTREC,
                                        FMOVDIA,
                                        FCONTAB,
                                        ICOMBRU,
                                        ICOMRET,
                                        ICOMDEV,
                                        IRETDEV,
                                        NMOVIMI,
                                        ICOMBRU_MONCIA,
                                        ICOMRET_MONCIA,
                                        ICOMDEV_MONCIA,
                                        IRETDEV_MONCIA,
                                        FCAMBIO,
                                        CGARANT,
                                        ICOMCEDIDA,
                                        ICOMCEDIDA_MONCIA)
                                        VALUES(v_nrecibo,
                                        v_nnumcom+1,
                                        cagente,
                                        f_cestrec_mv(v_nrecibo, null),
                                        null,
                                        null,

                                        -icomisi,
                                        -vimpicomret,
                                        null,
                                        null,
                                        v_nmovimi
                                        ,null,null
                                        ,null,null
                                        ,null,null,
                                        null,null);

                       INSERT INTO COMRECIBO(NRECIBO,
                                        NNUMCOM,
                                        CAGENTE,
                                        CESTREC,
                                        FMOVDIA,
                                        FCONTAB,
                                        ICOMBRU,
                                        ICOMRET,
                                        ICOMDEV,
                                        IRETDEV,
                                        NMOVIMI,
                                        ICOMBRU_MONCIA,
                                        ICOMRET_MONCIA,
                                        ICOMDEV_MONCIA,
                                        IRETDEV_MONCIA,
                                        FCAMBIO,
                                        CGARANT,
                                        ICOMCEDIDA,
                                        ICOMCEDIDA_MONCIA)
                                        VALUES(v_nrecibo,
                                        v_nnumcom+2,
                                        cagente,
                                        f_cestrec_mv(v_nrecibo, null),
                                        f_sysdate,
                                        null,


                                        icomisi,
                                        new_vimpicomret,
                                        null,
                                        null,
                                        v_nmovimi
                                        ,null,null
                                        ,null,null
                                        ,null,null,
                                        null,null);
                  ELSE

                   v_pasexec := 312;


                    INSERT INTO COMRECIBO(NRECIBO,
                                        NNUMCOM,
                                        CAGENTE,
                                        CESTREC,
                                        FMOVDIA,
                                        FCONTAB,
                                        ICOMBRU,
                                        ICOMRET,
                                        ICOMDEV,
                                        IRETDEV,
                                        NMOVIMI,
                                        ICOMBRU_MONCIA,
                                        ICOMRET_MONCIA,
                                        ICOMDEV_MONCIA,
                                        IRETDEV_MONCIA,
                                        FCAMBIO,
                                        CGARANT,
                                        ICOMCEDIDA,
                                        ICOMCEDIDA_MONCIA)
                                        VALUES(v_nrecibo,
                                        v_nnumcom+1,
                                        cagente,
                                        f_cestrec_mv(v_nrecibo, null),
                                        f_sysdate,
                                        null,

                                        icomisi,
                                        vimpicomret,
                                        null,
                                        null,
                                        v_nmovimi
                                        ,null,null
                                        ,null,null
                                        ,null,null,
                                        null,null);

                                         v_pasexec := 313;

                         INSERT INTO COMRECIBO(NRECIBO,
                                        NNUMCOM,
                                        CAGENTE,
                                        CESTREC,
                                        FMOVDIA,
                                        FCONTAB,
                                        ICOMBRU,
                                        ICOMRET,
                                        ICOMDEV,
                                        IRETDEV,
                                        NMOVIMI,
                                        ICOMBRU_MONCIA,
                                        ICOMRET_MONCIA,
                                        ICOMDEV_MONCIA,
                                        IRETDEV_MONCIA,
                                        FCAMBIO,
                                        CGARANT,
                                        ICOMCEDIDA,
                                        ICOMCEDIDA_MONCIA)
                                        VALUES(v_nrecibo,
                                        v_nnumcom+2,
                                        cagente,
                                        f_cestrec_mv(v_nrecibo, null),
                                        f_sysdate,
                                        null,

                                        -icomisi,
                                        -vimpicomret,
                                        null,
                                        null,
                                        v_nmovimi
                                        ,null,null
                                        ,null,null
                                        ,null,null,
                                        null,null);

                    INSERT INTO COMRECIBO(NRECIBO,
                                        NNUMCOM,
                                        CAGENTE,
                                        CESTREC,
                                        FMOVDIA,
                                        FCONTAB,
                                        ICOMBRU,
                                        ICOMRET,
                                        ICOMDEV,
                                        IRETDEV,
                                        NMOVIMI,
                                        ICOMBRU_MONCIA,
                                        ICOMRET_MONCIA,
                                        ICOMDEV_MONCIA,
                                        IRETDEV_MONCIA,
                                        FCAMBIO,
                                        CGARANT,
                                        ICOMCEDIDA,
                                        ICOMCEDIDA_MONCIA)
                                        VALUES(v_nrecibo,
                                        v_nnumcom+3,
                                        cagente,
                                        f_cestrec_mv(v_nrecibo, null),
                                        f_sysdate,
                                        null,


                                        icomisi,
                                        new_vimpicomret,
                                        null,
                                        null,
                                        v_nmovimi
                                        ,null,null
                                        ,null,null
                                        ,null,null,
                                        null,null);
                  END IF;



          END IF;
          commit;
		  vimpicomret := new_vimpicomret;
          pcerror := 0;
   EXCEPTION
      WHEN e_object_error THEN
         p_tab_error(f_sysdate, f_user, 'Actualización IRPF', v_pasexec,
                     'e_object_error Update_irpf nrecibo=' || v_nrecibo, SQLERRM);
         pcerror := 1;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Actualización IRPF', NULL,
                     'when others del Update_irpf nrecibo=' || v_nrecibo, SQLERRM);
         pcerror := 1;
   END proceso_update_irpf;


   FUNCTION f_insert_liquidafact_inter(sproces VARCHAR2, cagente NUMBER)
      RETURN NUMBER IS
      PRAGMA AUTONOMOUS_TRANSACTION;
      vreturn        NUMBER;
      vcliquidafact  NUMBER(8);
   BEGIN
      SELECT s_cliquidafact.NEXTVAL
        INTO vcliquidafact
        FROM DUAL;

      INSERT INTO liquidafact_inter
                  (sproceso, fecha, cagente,
                   consecutivo, cliquidafact)
           VALUES (sproces, f_sysdate, cagente,
                   TO_CHAR(f_sysdate, 'YYYY') || 'C' || LPAD(vcliquidafact, 8, 0), vcliquidafact);

      COMMIT;
      RETURN vcliquidafact;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_insert_liquidafact_inter;

   -- CONF-905 INICIO
    FUNCTION f_calc_formula_coaseguro(
      pccompani IN NUMBER,
      pclave IN NUMBER,
      pfecefe IN DATE,
      presultado OUT NUMBER,
      psproduc IN NUMBER DEFAULT 0)
      RETURN NUMBER IS
      v_object       VARCHAR2(500) := 'PAC_LIQUIDA.f_calc_formula_coaseguro';
      v_param        VARCHAR2(500)
                              := 'params : pccompani : ' || pccompani || ', pclave : ' || pclave;
      -- pac_calculo_formulas.calc_formul
      val            NUMBER;   -- Valor que retorna la formula
      xxformula      VARCHAR2(20000);   -- contiene la Formula a calcular
      xxsesion       NUMBER;   -- Nro de sesion que ejecuta la formula
      e              NUMBER;   -- Error Retorno funciones
      xxcodigo       VARCHAR2(30);
      xfecefe        NUMBER;
--
      xs             VARCHAR2(20000);
      retorno        NUMBER;
--
      xnmovimi       NUMBER;
      xfecha         NUMBER;
      xfefecto       NUMBER;
      xfvencim       NUMBER;
      xcforpag       NUMBER;
      ntraza         NUMBER := 0;
      v_cursor       INTEGER;
      v_filas        NUMBER;
      -- RSC 04/08/2008
      xfrevant       NUMBER;

      CURSOR cur_termino(wclave NUMBER) IS
         SELECT   parametro
             FROM sgt_trans_formula
            WHERE clave = wclave
         ORDER BY 1;

      no_encuentra   EXCEPTION;
   BEGIN
--DBMS_OUTPUT.PUT_LINE('ENTRAMOS');
      xfecefe := TO_NUMBER(TO_CHAR(NVL(pfecefe, f_sysdate), 'YYYYMMDD'));
      ntraza := 1;

--      IF psesion IS NULL THEN
      SELECT sgt_sesiones.NEXTVAL
        INTO xxsesion
        FROM DUAL;

      --    ELSE
        --     xxsesion := psesion;
          --END IF;
      IF xxsesion IS NULL THEN
         ROLLBACK;
         RETURN 108418;
      END IF;

      ntraza := 2;
--DBMS_OUTPUT.PUT_LINE('X_CLLAMADA ='||X_CLLAMADA);
--
      ntraza := 3;
      -- Quan hi ha error graba_param fa un RAISE exGrabaParam
      e := pac_calculo_formulas.graba_param(xxsesion, 'SESION', xxsesion);
      -- Insertamos parametros genericos para el calculo de las provisiones
      --e := pac_calculo_formulas.graba_param(xxsesion, 'FECEFE', xfecefe);
      e := pac_calculo_formulas.graba_param(xxsesion, 'CCOMPANI', pccompani);

--
      ntraza := 4;

      BEGIN
         SELECT formula, codigo
           INTO xxformula, xxcodigo
           FROM sgt_formulas
          WHERE clave = pclave;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, v_object, ntraza,
                        SUBSTR('error al buscar en SGT_FORMULAS' || ' PFECHA=' || pfecefe
                               || ' clave =' || pclave,
                               1, 500),
                        SUBSTR(SQLERRM, 1, 2500));
            RETURN 108423;
      END;

      -- Cargo parametros predefinidos
      ntraza := 6;

      FOR term IN cur_termino(pclave) LOOP
         BEGIN
--DBMS_OUTPUT.PUT_LINE ('SELECT CON CLLAMADA ='||X_CLLAMADA);
            SELECT 'BEGIN SELECT ' || tcampo || ' INTO :RETORNO  FROM ' || ttable || ' WHERE '
                   || twhere || ' ; END;'
              INTO xs
              FROM sgt_carga_arg_prede
             WHERE termino = term.parametro
               AND ttable IS NOT NULL
               AND cllamada = 'GENERICO';

            --
            IF DBMS_SQL.is_open(v_cursor) THEN
               DBMS_SQL.close_cursor(v_cursor);
            END IF;

            v_cursor := DBMS_SQL.open_cursor;
            DBMS_SQL.parse(v_cursor, xs, DBMS_SQL.native);
            DBMS_SQL.bind_variable(v_cursor, ':RETORNO', retorno);

            IF INSTR(xs, ':FECEFE') > 0 THEN
               DBMS_SQL.bind_variable(v_cursor, ':FECEFE', xfecefe);
            END IF;

            IF INSTR(xs, ':CCOMPANI') > 0 THEN
               DBMS_SQL.bind_variable(v_cursor, ':CCOMPANI', pccompani);
            END IF;

            IF INSTR(xs, ':SPRODUC') > 0 THEN
               DBMS_SQL.bind_variable(v_cursor, ':SPRODUC', psproduc);
            END IF;

            -- Fin Bug 10690
            BEGIN
               v_filas := DBMS_SQL.EXECUTE(v_cursor);
               DBMS_SQL.variable_value(v_cursor, 'RETORNO', retorno);

               IF DBMS_SQL.is_open(v_cursor) THEN
                  DBMS_SQL.close_cursor(v_cursor);
               END IF;
--DBMS_OUTPUT.PUT_LINE ('despues execute ' || term.parametro|| ':' || retorno);
            EXCEPTION
               WHEN OTHERS THEN
                  IF DBMS_SQL.is_open(v_cursor) THEN
                     DBMS_SQL.close_cursor(v_cursor);
                  END IF;

--DBMS_OUTPUT.PUT_LINE('ENTRAMOS EN WHEN OTHERS ='||SUBSTR(SQLERRM,0,255));
                  p_tab_error(f_sysdate, f_user, v_object, ntraza,
                              SUBSTR('error al ejecutar la select dinámica ' || ' PFECHA='
                                     || pfecefe || ' select =' || xs,
                                     1, 500),
                              SQLERRM);
--DBMS_OUTPUT.PUT_LINE ('whn others ' || term.parametro|| ':' || 0);
                  retorno := 0;
            END;

            IF retorno IS NULL THEN
               RETURN 103135;
            ELSE
               -- Quan hi ha error graba_param fa un RAISE exGrabaParam
               e := pac_calculo_formulas.graba_param(xxsesion, term.parametro, retorno);
            END IF;
         --
         EXCEPTION
            WHEN no_encuentra THEN
               xs := NULL;
            WHEN OTHERS THEN
               --DBMS_OUTPUT.PUT_LINE ('sqlerrm =' || SQLERRM);
               p_tab_error(f_sysdate, f_user, v_object, ntraza,
                           SUBSTR('error al buscar la select dinámica' || ' PFECHA='
                                  || pfecefe || ' para el termino =' || term.parametro,
                                  1, 500),
                           xs);
               xs := NULL;
               RETURN 109843;
         END;
      END LOOP;

      --DBMS_OUTPUT.put_line('INSERTAMOS LAS PREGUNTAS');
      ntraza := 9;
  --   DBMS_OUTPUT.PUT_LINE ('xxformula =' ||SUBSTR( xxformula,1,255));
--     DBMS_OUTPUT.PUT_LINE ('xxsesion =' || xxsesion);
 --
      ntraza := 12;

      BEGIN
         val := pk_formulas.eval(xxformula, xxsesion);
         -- Borro sgt_parms_transitorios
         -- CPM 20/12/05: Se descomenta el borrar parámetros y se hace antes de detectar
         --   si tenemos valor o no.
         e := pac_calculo_formulas.borra_param(xxsesion);

         IF val IS NULL THEN
            p_tab_error(f_sysdate, f_user, v_object, ntraza,
                        SUBSTR('error al evaluar la formula =' || xxformula || ' sesion ='
                               || xxsesion,
                               1, 500),
                        NULL);
            RETURN 103135;
         ELSE
            presultado := val;
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, v_object, ntraza,
                        SUBSTR('error Oracle al evaluar la formula =' || xxformula
                               || ' sesion =' || xxsesion,
                               1, 500),
                        SQLERRM);
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, ntraza, v_param, SQLERRM);
         RETURN 109843;
   END f_calc_formula_coaseguro;
   -- CONF-905 FIN



END pac_liquida;

/

  GRANT EXECUTE ON "AXIS"."PAC_LIQUIDA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_LIQUIDA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_LIQUIDA" TO "PROGRAMADORESCSI";
