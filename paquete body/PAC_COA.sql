--------------------------------------------------------
--  DDL for Package Body PAC_COA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_COA" IS
/******************************************************************************
 NAME: pac_coa
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        29/05/2012                    1. Created this package body.
   2.0        29/05/2012    AVT             2. 0022076: LCOL_A004-Mantenimientos de cuenta tecnica del reaseguro y del coaseguro
   3.0        07/11/2012    AVT             3. 0023830: LCOL_A004 Ajustar el Manteniment dels Comptes de Reasseguranca (Nota: 22076/0123753)
   4.0        14/02/2013    RDD             4. 0025872: LCOL_F002-Revisi?n Qtrackers contabilidad F2
   5.0        01/03/2013    RDD             5. 0025872: LCOL_F002-Revisi?n Qtrackers contabilidad Nota 0139547
   6.0        07/03/2013    JDS             6. 0025098: Qtracker: 5616 i 5617 Inconsistencias al generar cuenta corriente del coaseguro
   7.0        19/03/2013    AFM             7. 0025803: RSA001 - Ampliar los decimales que utiliza iAXIS
   8.0        11/07/2013    MMM             8. 0025872: LCOL_F002-Revision Qtrackers contabilidad F2 - Nota 0148800
   9.0        14/10/2013    MMM             9. 0027909: Nota 0155796 - Se detectan cambios a realizar en el package PAC_COA en el tramite de las reservas de COASEGURO
   10.0       17/09/2014    EDA             10. 0032159: LCOL_A004-0013424: Siniestro Coaseguro Cedido No Muestra Constitución en Concepto Taller. Repuestos con IVA
   11.0       30/07/2014    DCT             10. 0032159: LCOL_A004-0013424: Siniestro Coaseguro Cedido No Muestra Constitución en Concepto Taller. Repuestos con IVA
   12.0       18/05/2015    KBR             11. 0033250: LCOLF3BSIN-Revisión Q-Trackers Fase 3B - Siniestros
   13.0       11/06/2015    KBR             13. 0036409: Pendientes Modulo Coaseguro
   14.0		  26/02/2018	JAA				14. 0001621: Confianza, Bug 1621 Función F_SET_REMESA_CTACOA
   15.0		  19/04/2018	JAA				15. 0002057: Confianza, Bug 2057 Función f_insctacoas_parcial
******************************************************************************/

   /*************************************************************************
   Función que elimina un movimiento manual de la cuenta técnica del coaseguro
   *************************************************************************/
   -- Bug 22076 - AVT - 29/05/2012 - se crea la funcion
   FUNCTION f_del_mov_ctacoa(
      pcempres IN NUMBER,
      pccompani IN NUMBER,
      psseguro IN NUMBER,
      pfcierre IN DATE,
      pnnumlin IN NUMBER)
      RETURN NUMBER IS
      v_object       VARCHAR2(200) := 'pac_coa.f_del_mov_ctacoa';
      v_param        VARCHAR2(500)
         := 'params :  pcempres:' || pcempres || ' - pccompani:' || pccompani
            || ' - psseguro:' || psseguro || ' - pfcierre:' || pfcierre || ' - pnnumlin:'
            || pnnumlin;
      v_pasexec      NUMBER(5) := 0;
      num_err        NUMBER := 0;
      vcont          NUMBER := 0;
      v_max_fcierre  DATE;
   BEGIN
      v_pasexec := 1;

      SELECT MAX(fcierre)
        INTO v_max_fcierre
        FROM cierres
       WHERE ctipo = 5;

      v_pasexec := 2;

      SELECT COUNT(*)
        INTO vcont
        FROM ctacoaseguro
       WHERE cempres = pcempres
         AND ccompani = pccompani
         AND sseguro = psseguro
         AND fmovimi > ADD_MONTHS(pfcierre, -1)
         AND fmovimi <= pfcierre
         AND smovcoa = pnnumlin
         AND(NVL(ctipmov, 0) = 0
             OR fmovimi < v_max_fcierre
             OR NVL(cestado, 1) <> 1);

-->> no es poden esborrar registres si:
-- NVL(ctipmov, 0) = 0      --> provenen de moviments automàtics
-- fmovimi < v_max_fcierre  --> son anteriors a la darrera data de tancament
-- NVL(cestado, 1) <> 1     --> no están en estat "pendent"
      v_pasexec := 3;

      IF vcont > 0 THEN
         num_err := 1000402;
      ELSE
         v_pasexec := 4;

         BEGIN
            DELETE      ctacoaseguro
                  WHERE cempres = pcempres
                    AND ccompani = pccompani
                    AND sseguro = psseguro
                    AND fmovimi > ADD_MONTHS(pfcierre, -1)
                    AND fmovimi <= pfcierre
                    AND smovcoa = pnnumlin
                    AND ctipmov = 1   -- Només moviments manuals
                    AND NVL(cestado, 1) = 1   -- estat "pendent de liquidar"
                    AND fmovimi > v_max_fcierre;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               num_err := 102903;
            WHEN OTHERS THEN
               num_err := 104863;
         END;
      END IF;

      RETURN num_err;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
         RETURN 107091;
   END f_del_mov_ctacoa;

   /*********************************************************************************
   Función que actualiza el estado de movimiento concreto de una cuenta de coaseguro
   *********************************************************************************/
   -- Bug 32034 - SHA - 18/08/2014 - se crea la funcion
   FUNCTION f_set_estado_ctacoa(
      pccompani IN NUMBER,
      pcompapr IN NUMBER,
      pctipcoa IN NUMBER,
      pcempres IN NUMBER,
      psproces IN NUMBER,
      pcmovimi IN NUMBER,
      pfcierre IN DATE,
      pestadonew IN NUMBER,
      pestadoold IN NUMBER)
      RETURN NUMBER IS
      v_object       VARCHAR2(500) := 'PAC_COA.f_set_estado_ctacoa';
      v_param        VARCHAR2(500)
         := 'params : pccompani : ' || pccompani || ', pcompapr : ' || pcompapr
            || ', pctipcoa : ' || pctipcoa || ' , pcempres : ' || pcempres || ', psproces : '
            || psproces || ', pfcierre : ' || pfcierre || ', pestadonew : ' || pestadonew
            || ', pestadoold : ' || pestadoold || ', pcmovimi : ' || pcmovimi;
      v_pasexec      NUMBER(5) := 0;
   BEGIN
      UPDATE ctacoaseguro
         SET cestado = pestadonew
       WHERE ccompani = pccompani
         AND ccompapr = pcompapr
         AND ctipcoa = pctipcoa
         AND cempres = pcempres
         AND cestado = pestadoold
         AND fcierre = pfcierre
         AND sproces = psproces
         AND cmovimi = pcmovimi;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
         RETURN 105234;
   END f_set_estado_ctacoa;

   /***************************************************************************************************
   Función que setea a Pendiente el estado de aquellos movimientos de cuenta de coaseguro con estado 4
   ****************************************************************************************************/
   -- Bug 32034 - SHA - 18/08/2014 - se crea la funcion
   FUNCTION f_reset_estado(pcempres IN NUMBER)
      RETURN NUMBER IS
      v_object       VARCHAR2(500) := 'PAC_COA.f_reset_estado';
      v_param        VARCHAR2(500) := 'params : pcempres : ' || pcempres;
      v_pasexec      NUMBER(5) := 0;
   BEGIN
      UPDATE ctacoaseguro
         SET cestado = 1
       WHERE cempres = pcempres
         AND cestado = 4;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
         RETURN 105234;
   END f_reset_estado;

   /*************************************************************************
   Función que apunta en la tabla de liquidación los importes pendientes de la cuenta técnica del coaseguro.
   *************************************************************************/
   FUNCTION f_liquida_ctatec_coa(
      pcempres IN NUMBER,
      pccompani IN NUMBER,
      pccompapr IN NUMBER,
      pfcierre IN DATE,
      pfcierredesde IN DATE,
      pfcierrehasta IN DATE,
      pctipcoa IN NUMBER,
      psproces_ant IN NUMBER,
      psproces_nou IN NUMBER,
      indice OUT NUMBER)
      RETURN NUMBER IS
      v_object       VARCHAR2(200) := 'pac_coa.f_liquida_ctatec_coa';
      v_param        VARCHAR2(500)
         := 'params : pccompani : ' || pccompani || ', pcempres : ' || pcempres
            || ', pfcierre : ' || pfcierre || ' - pfcierredesde:' || pfcierredesde
            || ' - pfcierrehasta:' || pfcierrehasta ;
      v_pasexec      NUMBER(5) := 0;
      vnumerr        NUMBER := 0;
      v_iimport      pagos_ctatec_coa.iimporte%TYPE;
      v_spagcoa      NUMBER := 0;
      v_cmultimon    parempresas.nvalpar%TYPE
                             := NVL(pac_parametros.f_parempresa_n(pcempres, 'MULTIMONEDA'), 0);
      v_cmoncontab   parempresas.nvalpar%TYPE
                                    := pac_parametros.f_parempresa_n(pcempres, 'MONEDACONTAB');
      v_importe_mon  pagos_ctatec_coa.iimporte_moncon%TYPE;
      v_iimp_montan  pagos_ctatec_coa.iimporte_moncon%TYPE;
      v_idifer       ctacoaseguro.imovimi_moncon%TYPE;
      v_fcambio      DATE;
      v_itasa        NUMBER;
      v_sseguro      NUMBER;
      v_cdebhab      NUMBER;
      v_smovcoa      NUMBER(8);
      pnnumlin       NUMBER;
      verror         NUMBER;
      vterminal      VARCHAR2(20);
      perror         VARCHAR2(2000);
      v_cestado      NUMBER(1);
      v_fcierre_ini  DATE;
      v_fcierre_fin  DATE;
      vpar_traza     VARCHAR2(80) := 'TRAZA_LIQUIDA_COA';
      v_nom_paquete  VARCHAR2(80) := 'PAC_COA';
      v_nom_funcion  VARCHAR2(80) := 'F_LIQUIDA_CTATEC_COA';
      v_ttexto1      VARCHAR2(1000);
      v_ttexto2      VARCHAR2(1000);
      v_ttexto3      VARCHAR2(1000);
      v_descri       VARCHAR2(200);
   BEGIN
      v_pasexec := 1;
      indice := 0;
      p_traza_proceso(pcempres, vpar_traza, psproces_nou, v_nom_paquete, v_nom_funcion, NULL,
                      165, 'Inicio de proceso', 1);
      v_fcierre_ini := TO_DATE(TO_CHAR(pfcierredesde, 'ddmmyyyy'), 'ddmmyyyy');
      v_fcierre_fin := TO_DATE(TO_CHAR(pfcierrehasta, 'ddmmyyyy'), 'ddmmyyyy');

      SELECT SUM(imovimi *(DECODE(cdebhab, 2, -1, 1))),
             SUM(imovimi_moncon *(DECODE(cdebhab, 2, -1, 1)))
        INTO v_iimport,
             v_importe_mon
        FROM ctacoaseguro
       WHERE cmovimi = 99
         AND cempres = pcempres
         AND TRUNC(fcierre) >= v_fcierre_ini
         AND TRUNC(fcierre) <= v_fcierre_fin
         AND ccompapr = pccompapr
         AND ctipcoa = pctipcoa
         AND ccompani = NVL(pccompani, ccompani)
         AND cestado = 1
         AND sproces = psproces_ant;

      v_fcambio := f_sysdate;
      indice := indice + 1;

      FOR cia IN (SELECT DISTINCT ccompani
                             FROM ctacoaseguro
                            WHERE cmovimi = 99
                              AND cempres = pcempres
                              AND TRUNC(fcierre) >= v_fcierre_ini
                              AND TRUNC(fcierre) <= v_fcierre_fin
                              AND NVL(ccompapr, 0) = nvl(pccompapr, 0)
                              AND ctipcoa = pctipcoa
                              AND cestado = 1
                              AND imovimi <> 0
                              AND sproces = psproces_ant
                              AND ccompani = NVL(pccompani, ccompani)
                         ORDER BY ccompani) LOOP
         SELECT SUM(imovimi *(DECODE(cdebhab, 2, -1, 1))),
                SUM(imovimi_moncon *(DECODE(cdebhab, 2, -1, 1)))
           INTO v_iimport,
                v_importe_mon
           FROM ctacoaseguro
          WHERE cmovimi = 99
            AND cempres = pcempres
            AND TRUNC(fcierre) >= v_fcierre_ini
            AND TRUNC(fcierre) <= v_fcierre_fin
            AND NVL(ccompapr, 0) = nvl(pccompapr, 0)
            AND ctipcoa = pctipcoa
            AND ccompani = cia.ccompani
            AND cestado = 1
            AND sproces = psproces_ant;

         IF v_cmultimon = 1 THEN
            SELECT DISTINCT sseguro
                       INTO v_sseguro
                       FROM ctacoaseguro
                      WHERE cmovimi = 99
                        AND cempres = pcempres
                        AND TRUNC(fcierre) >= v_fcierre_ini
                        AND TRUNC(fcierre) <= v_fcierre_fin
                        AND NVL(ccompapr, 0) = nvl(pccompapr, 0)
                        AND ctipcoa = pctipcoa
                        AND cestado = 1
                        AND imovimi <> 0
                        AND sproces = psproces_ant
                        AND ccompani = NVL(pccompani, ccompani)
                        AND ROWNUM = 1;

            v_pasexec := 2;
            vnumerr := pac_oper_monedas.f_datos_contraval(v_sseguro, NULL, NULL, v_fcambio, 3,
                                                          v_itasa, v_fcambio);

            IF vnumerr <> 0 THEN
               UPDATE ctacoaseguro
                  SET cestado = 1
                WHERE cestado = 4;

               RETURN vnumerr;
            END IF;

            IF v_itasa = 1 THEN
               v_importe_mon := v_importe_mon;
               v_iimport := v_importe_mon;
            ELSE
               v_importe_mon := f_round(NVL(v_iimport, 0) * v_itasa, v_cmoncontab);
            END IF;
         END IF;

         v_pasexec := 3;

         SELECT spagcoa.NEXTVAL
           INTO v_spagcoa
           FROM DUAL;

         IF v_iimport < 0 THEN
            v_cdebhab := 2;
         ELSE
            v_cdebhab := 1;
         END IF;

         INSERT INTO pagos_ctatec_coa
                     (spagcoa, cempres, sproduc, ccompani, iimporte, cestado, fliquida,
                      cusuario, falta, iimporte_moncon, fcambio, ctipopag, sproces)
              VALUES (v_spagcoa, pcempres, NULL, cia.ccompani, v_iimport, 1, TRUNC(f_sysdate),
                      f_user, f_sysdate, v_importe_mon, v_fcambio, v_cdebhab, psproces_nou);

         v_cestado := 0;   -- LIQUIDAT
         v_ttexto1 := f_axis_literales(104910, pac_md_common.f_get_cxtidioma());   -- Saldo
         v_ttexto2 := f_axis_literales(9902071, pac_md_common.f_get_cxtidioma());   -- Liquidaci?n
         v_ttexto3 := f_axis_literales(1000576, pac_md_common.f_get_cxtidioma());   -- Proceso
         v_descri := v_ttexto1 || ' ' || v_ttexto2 || ':' || psproces_nou;

         IF pctipcoa IN(1, 2) THEN
            v_pasexec := 4;

            UPDATE ctacoaseguro
               SET cestado = v_cestado,
                   fliqcia = f_sysdate,
                   spagcoa = v_spagcoa,
                   tdescri = v_descri
             WHERE cempres = pcempres
               AND ccompani = cia.ccompani
               AND NVL(cestado, 1) = 1
               AND cmovimi = 99
               AND imovimi <> 0
               AND TRUNC(fcierre) >= v_fcierre_ini
               AND TRUNC(fcierre) <= v_fcierre_fin
               AND NVL(ccompapr,0) = NVL(pccompapr,0)
               AND ctipcoa = pctipcoa
               AND sproces = psproces_ant;
         ELSIF pctipcoa IN(8, 9) THEN
            v_pasexec := 5;

            UPDATE ctacoaseguro
               SET cestado = v_cestado,
                   fliqcia = f_sysdate,
                   fcierre = pfcierre,
                   spagcoa = v_spagcoa,
                   tdescri = v_descri
             WHERE cempres = pcempres
               AND ccompani = cia.ccompani
               AND NVL(cestado, 1) = 1
               AND ctipcoa = pctipcoa
               AND imovimi <> 0
               AND ccompapr = pccompapr
               AND fcierre IS NULL;
         END IF;
      END LOOP;

      v_pasexec := 6;

      /*
       * INI-CONF-403 - Casuisticas de Remesas de Coaseguros
       * Se gestiona el parametro de empresa GESTIONA_LIQ_REACOA
       * para que permita la correcta generación de los asientos contables.
       * Marzo/2018
      */
      IF NVL(pac_parametros.f_parempresa_n(pcempres, 'GESTIONA_LIQ_REACOA'), 0) = 1 THEN
        UPDATE parempresas
           SET nvalpar = 0
         WHERE cparam = 'GESTIONA_LIQ_REACOA';
        COMMIT;
      END IF;
      /*FIN--CONF-403 - Casuisticas de Remesas de Coaseguros*/

      IF NVL(pac_parametros.f_parempresa_n(pcempres, 'GESTIONA_LIQ_REACOA'), 0) = 1 THEN
         DECLARE
            --tipo para Liquidacions Coassegurança
            vtipopago      NUMBER := 9;
            vemitido       NUMBER;
            vsinterf       NUMBER;
         BEGIN
            v_pasexec := 7;
            vnumerr := pac_user.f_get_terminal(pac_md_common.f_get_cxtusuario, vterminal);
            vnumerr := pac_con.f_emision_pagorec(pcempres, 1, vtipopago, v_spagcoa, 1,
                                                 vterminal, vemitido, vsinterf, perror,
                                                 f_user, NULL, NULL, NULL, 1);
            v_pasexec := 8;

            IF vnumerr <> 0
               OR TRIM(perror) IS NOT NULL THEN
               IF vnumerr = 0 THEN
                  vnumerr := 151323;
               END IF;

               p_tab_error(f_sysdate, f_user, 'PAC_REA.f_liquida_ctatec_rea', v_pasexec,
                           v_param, perror || ' ' || vnumerr);
               pnnumlin := NULL;
               vnumerr :=
                  f_proceslin(psproces_nou,
                              SUBSTR('Liquidación: Proceso no finalizado correctamente', 1,
                                     120),
                              0, pnnumlin);
            END IF;

            v_pasexec := 9;

            --------
            IF vnumerr = 0 THEN
               v_cestado := 0;   -- LIQUIDAT
            ELSE
               v_cestado := 3;   -- REBUTJAT
            END IF;
         END;
      ELSE
         v_cestado := 0;   -- si no anem al JDE Liquidem directmanet
      END IF;

      v_pasexec := 10;

      UPDATE pagos_ctatec_coa
         SET cestado = v_cestado
       WHERE spagcoa = v_spagcoa;

      v_pasexec := 11;

      IF v_cestado = 3 THEN
         v_pasexec := 12;

         UPDATE ctacoaseguro
            SET cestado = v_cestado   -- liquidada VF: 18
          WHERE spagcoa = v_spagcoa;
      END IF;

      v_pasexec := 14;
      -- apunte de diferencia de Pérdidas / ganancias
      v_idifer := v_iimp_montan - v_importe_mon;
      v_pasexec := 16;

      /*
       * INI-CONF-403 - Casuisticas de Remesas de Coaseguros
       * Se gestiona el parametro de empresa GESTIONA_LIQ_REACOA
       * para que permita la correcta generación de los asientos contables.
       * Marzo/2018
      */
      IF NVL(pac_parametros.f_parempresa_n(pcempres, 'GESTIONA_LIQ_REACOA'), 0) = 0 THEN
        UPDATE parempresas
           SET nvalpar = 1
         WHERE cparam = 'GESTIONA_LIQ_REACOA';
        COMMIT;
      END IF;
      /*FIN--CONF-403 - Casuisticas de Remesas de Coaseguros*/

      --Ponemos en pendiente todo lo que dejamos en estado 4
      UPDATE ctacoaseguro
         SET cestado = 1
       WHERE cestado = 4;

      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);

         --Ponemos en pendiente todo lo que dejamos en estado 4
         UPDATE ctacoaseguro
            SET cestado = 1
          WHERE cestado = 4;

         RETURN 9904134;
   END f_liquida_ctatec_coa;

   /*************************************************************************
       Función que insertará o modificará un movimiento de cuenta técnica en función del pmodo
   *************************************************************************/
   -- Bug 22076 - AVT - 25/05/2012 - se crea la funcion
   FUNCTION f_set_mov_ctacoa(
      pcempres IN NUMBER,
      pccompani IN NUMBER,
      pnnumlin IN NUMBER,
      pctipcoa IN NUMBER,
      pcdebhab IN NUMBER,
      psseguro IN NUMBER,
      pnrecibo IN NUMBER,
      psidepag IN NUMBER,
      pfcierre IN DATE,
      pcmovimi IN NUMBER,   -- vindrà informat sempre a les modificacions
      pcimport IN NUMBER,   -- sempre obligatori
      pimovimi IN NUMBER,
      pfcambio IN DATE,
      pcestado IN NUMBER,
      ptdescri IN VARCHAR2,
      ptdocume IN VARCHAR2,
      pmodo IN NUMBER)
      RETURN NUMBER IS
      v_object       VARCHAR2(500) := 'pac_coa.f_set_mov_ctacoa';
      v_param        VARCHAR2(500)
         := 'params pcempres : ' || pcempres || 'pccompani : ' || pccompani || ', pnnumlin : '
            || pnnumlin || ', pctipcoa : ' || pctipcoa || ', pcdebhab :' || pcdebhab
            || ' , psseguro : ' || psseguro || ', pnrecibo : ' || pnrecibo || ', psidepag : '
            || psidepag || ', pfcierre : ' || pfcierre || ', pcmovimi : ' || pcmovimi
            || ', pcimport : ' || pcimport || ' , pimovimi : ' || pimovimi || ' , pcestado : '
            || pcestado || ' , ptdescri : ' || ptdescri || ' , ptdocume : ' || ptdocume
            || ', pmodo:' || pmodo;
      v_pasexec      NUMBER(5) := 0;
      v_nnumlin      NUMBER;
      vfcambio       DATE;
      verror         NUMBER := 0;
      v_sproduc      NUMBER;
      v_smovrec      NUMBER;
      v_itasa        NUMBER;
      v_cmultimon    parempresas.nvalpar%TYPE
                             := NVL(pac_parametros.f_parempresa_n(pcempres, 'MULTIMONEDA'), 0);
      v_cmoncontab   parempresas.nvalpar%TYPE
                                    := pac_parametros.f_parempresa_n(pcempres, 'MONEDACONTAB');
      v_importe_mon  NUMBER;
      v_cestado      movctatecnica.cestado%TYPE;
      v_cmovimi      ctacoaseguro.cmovimi%TYPE;
      v_ctippag      sin_tramita_pago.ctippag%TYPE;
      v_ncuacoa      seguros.ncuacoa%TYPE;
      v_pcescoa      coacedido.pcescoa%TYPE;
      v_cmoneda      seguros.cmoneda%TYPE;
      v_ccompapr     seguros.ccompani%TYPE;
   BEGIN
      v_pasexec := 1;

      -- CONTROL DE CAMPS OBLIGATORIS I CONTROL TIPO MOVIMIENTO COASEGURO (CMOVIMI)
      IF pcimport IS NULL THEN
         verror := 9904287;   -- Tipus Import Coassegurança Obligatori
      ELSE
         IF pcimport IN
               (5, 17)   -- Pagaments de Sinistres / Salvamentos y/o Recobros -- JDS - 25098 - 07/03/2013 s'afegeix el Recobro
            AND psidepag IS NULL THEN
            verror := 9001427;   -- Concepto Pago obligatorio
         ELSIF pcimport IN(5, 17)   -- Pagaments de Sinistres / Salvamentos y/o Recobros
               AND psidepag IS NOT NULL
               AND pcmovimi IS NULL THEN
            BEGIN
               SELECT ctippag
                 INTO v_ctippag
                 FROM sin_tramita_pago
                WHERE sidepag = psidepag;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  verror := 9906421;   -- Número de siniestro inexistente
            END;

            -- buscamos el tipo de movimiento
            IF v_ctippag = 2 THEN
               v_cmovimi := 10;   -- pago
            ELSIF v_ctippag = 3 THEN
               v_cmovimi := 12;   -- anulación pago
            ELSIF v_ctippag = 7 THEN
               v_cmovimi := 11;   -- recobro
            ELSIF v_ctippag = 8 THEN
               v_cmovimi := 13;   -- anulación recobro
            ELSE
               verror := 9906421;   -- Número de siniestro inexistente
            END IF;
         ELSIF pcimport NOT IN(5, 17)   -- Pagaments de Sinistres / Salvamentos y/o Recobros
               --BUG 25098 - DCT - 4-02-2013  Añadir AND pcimport <> 0
               AND pcimport <> 0   -- Rebuts (no saldos)
               AND pnrecibo IS NULL THEN
            verror := 9904027;
         ELSIF pcimport NOT IN(5, 17)   -- Pagaments de Sinistres / Salvamentos y/o Recobros
               AND pnrecibo IS NOT NULL
               AND pcmovimi IS NULL THEN
            BEGIN
               SELECT ctiprec
                 INTO v_cmovimi
                 FROM recibos
                WHERE nrecibo = pnrecibo;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  --RCL - BUG 27322 / 146807 - Canvi literal
                  verror := 101731;   -- Recibo no encontrado
            END;
         --BUG 25098 - Nota: 137032 - INICIO - DCT - 4/02/2013
         ELSIF pcimport NOT IN(5, 17)   -- Pagaments de Sinistres / Salvamentos y/o Recobros
               AND pcimport = 0   -- Rebuts (saldos)
               AND pnrecibo IS NULL THEN
            v_cmovimi := 99;
         END IF;
      --BUG 25098 - Nota: 137032 - FIN - DCT - 4/02/2013
      END IF;

      IF verror = 0 THEN
         IF pmodo = 1 THEN   --Inserci?n de registros
            vfcambio := pfcierre;
         ELSE
            IF pfcambio IS NULL THEN
               vfcambio := pfcierre;
            ELSE
               vfcambio := pfcambio;
            END IF;
         END IF;

         v_pasexec := 2;

         --No se puede imputar a meses cerrados (5 Cierre coaseguro)(cvalor 167 tipos de cierre)
         IF pfcierre IS NOT NULL
            AND TRUNC(pfcierre) < NVL(pac_cierres.f_fecha_ultcierre(pcempres, 5), pfcierre) THEN
            RETURN 107855;
         END IF;

         v_pasexec := 3;

         IF v_cmultimon = 1 THEN
            verror := pac_oper_monedas.f_datos_contraval(psseguro, NULL, NULL, vfcambio, 3,
                                                         v_itasa, vfcambio);

            IF verror <> 0 THEN
               RETURN verror;
            END IF;

            v_importe_mon := f_round(NVL(pimovimi, 0) * v_itasa, v_cmoncontab);
         END IF;

         v_pasexec := 4;

         IF pnrecibo IS NOT NULL THEN
            BEGIN
               SELECT MAX(smovrec)
                 INTO v_smovrec
                 FROM movrecibo
                WHERE nrecibo = pnrecibo;
            EXCEPTION
               WHEN OTHERS THEN
                  verror := 9901116;
            END;
         END IF;

         v_pasexec := 5;

         IF pmodo = 0 THEN   --Modificación de registros
            SELECT NVL(cestado, 1)
              INTO v_cestado
              FROM ctacoaseguro
             WHERE ccompani = pccompani
               AND sseguro = psseguro
               AND smovcoa = pnnumlin;
         ELSE
            v_cestado := 1;

            BEGIN
               SELECT ccompani, NVL(cmoneda, v_cmoncontab)
                 INTO v_ccompapr, v_cmoneda
                 FROM seguros
                WHERE sseguro = psseguro;
            EXCEPTION
               WHEN OTHERS THEN
                  RETURN 101919;
            END;
         END IF;

         IF verror = 0 THEN
            IF v_cestado NOT IN(1, 3)
               OR pcestado NOT IN(1, 3) THEN
               verror := 110300;   -- Cambio de estado no permitido
            END IF;

            IF verror = 0 THEN
               --->>>>>>>>  IF v_ctipmov = 1 THEN   -- Movimiento manual
               IF pmodo = 0 THEN   --Modificación de registros
                  v_pasexec := 6;

                  UPDATE ctacoaseguro
                     SET cestado = pcestado,
                         tdescri = ptdescri,
                         tdocume = ptdocume
                   WHERE ccompani = pccompani
                     AND sseguro = psseguro
                     AND smovcoa = pnnumlin;
               ELSIF pmodo = 1 THEN   --Inserción de registros Manuales
                  v_pasexec := 7;

                  SELECT smovcoa.NEXTVAL
                    INTO v_nnumlin
                    FROM DUAL;

                  SELECT sproduc, ncuacoa
                    INTO v_sproduc, v_ncuacoa
                    FROM seguros
                   WHERE sseguro = psseguro;

                  v_pasexec := 8;

                  --BUG 0025098: INICIO  - 4-02-2013  - DCT
                  IF pctipcoa = 1 THEN
                     BEGIN
                        SELECT pcescoa
                          INTO v_pcescoa
                          FROM coacedido
                         WHERE sseguro = psseguro
                           AND ncuacoa = v_ncuacoa
                           AND ccompan = pccompani;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           BEGIN
                              SELECT pcescoa
                                INTO v_pcescoa
                                FROM coacedido c
                               WHERE c.sseguro = psseguro
                                 AND c.ncuacoa IN(
                                        SELECT MAX(ncuacoa)
                                          FROM coacedido cc
                                         WHERE cc.sseguro = c.sseguro
                                           AND cc.ccompan = c.ccompan)
                                 AND c.ccompan = pccompani;
                           EXCEPTION
                              WHEN NO_DATA_FOUND THEN
                                 RETURN 9904293;   -- No existeix quadre de Coasseguro per aquesta pòlissa
                           END;
                     END;
                  ELSE
                     BEGIN
                        SELECT ploccoa
                          INTO v_pcescoa
                          FROM coacuadro
                         WHERE sseguro = psseguro
                           AND ncuacoa = v_ncuacoa
                           AND ccompan = pccompani;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           BEGIN
                              SELECT ploccoa
                                INTO v_pcescoa
                                FROM coacuadro c
                               WHERE c.sseguro = psseguro
                                 AND c.ncuacoa IN(
                                        SELECT MAX(ncuacoa)
                                          FROM coacuadro cc
                                         WHERE cc.sseguro = c.sseguro
                                           AND cc.ccompan = c.ccompan)
                                 AND c.ccompan = pccompani;
                           EXCEPTION
                              WHEN NO_DATA_FOUND THEN
                                 RETURN 9904293;   -- No existeix quadre de Coasseguro per aquesta pòlissa
                           END;
                     END;
                  END IF;

                  --BUG 0025098: FIN  - 4-02-2013  - DCT
                  v_pasexec := 9;

                  INSERT INTO ctacoaseguro
                              (smovcoa, ccompani, sproduc, cimport, ctipcoa,
                               cmovimi, imovimi, fmovimi, cdebhab,
                               sidepag, nrecibo, smovrec, cempres, sseguro, ctipmov, tdescri,
                               tdocume, fcambio, imovimi_moncon, pcescoa, cestado,
                               cmoneda, ccompapr)
                       VALUES (v_nnumlin, pccompani, v_sproduc, pcimport, pctipcoa,
                               NVL(pcmovimi, v_cmovimi), pimovimi, pfcierre, pcdebhab,
                               psidepag, pnrecibo, v_smovrec, pcempres, psseguro, 1, ptdescri,
                               ptdocume, vfcambio, v_importe_mon, v_pcescoa, pcestado,
                               v_cmoneda, v_ccompapr);
               END IF;
            END IF;
         END IF;
      END IF;

      RETURN verror;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
         RETURN 9001949;
   END f_set_mov_ctacoa;

   /*******************************************************************************
                                                                                                                                                                                                                                                   FUNCION F_INICIALIZA_CARTERA
    Esta función devuelve el sproces con el que se realizará la liquidació del Coasseguro,
    para ello llamará a la función de f_procesini.
   Parámetros
    Entrada :
       Pfperini  DATE     : Fecha
       Pcempres  NUMBER   : Empresa
       Ptexto    VARCHAR2 :
    Salida :
       Psproces  NUMBER  : Numero proceso de cartera.
   Retorna :NUMBER con el número de proceso
   *********************************************************************************/
   FUNCTION f_inicializa_liquida_coa(
      pfperini IN DATE,
      pcempres IN NUMBER,
      ptexto IN VARCHAR2,
      pcidioma IN NUMBER,
      psproces OUT NUMBER)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'Pfperini=' || pfperini || ' Pcempres=' || pcempres;
      vobject        VARCHAR2(200) := 'PAC_COA.f_inicializa_liquida_coa';
      v_titulo       VARCHAR2(200);
      num_err        NUMBER;
      pnnumlin       NUMBER;
      pcerror        NUMBER;
      conta_err      NUMBER;
      vtexto         VARCHAR2(2000);
   BEGIN
      -- Control parametros entrada
      IF pfperini IS NULL
         OR pcempres IS NULL
         OR pcidioma IS NULL THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec,
                     ' Faltan parametros por informar: ' || vparam, SQLERRM);
         RETURN 140974;   --Faltan parametros por informar
      END IF;

      v_titulo := 'Liquida Coaseguro - ' || vparam;
      --Insertamos en la tabla PROCESOSCAB el registro identificativo de proceso -----
      num_err := f_procesini(f_user, pcempres, ptexto, v_titulo, psproces);

      IF num_err <> 0 THEN
         pcerror := 1;
         conta_err := conta_err + 1;
         vtexto := f_axis_literales(num_err, pcidioma);
         pnnumlin := NULL;
         num_err := f_proceslin(psproces, vtexto, 0, pnnumlin);
      END IF;

      RETURN num_err;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 9904134;
   END f_inicializa_liquida_coa;

   FUNCTION f_reservas_sin_online(
      pcempres IN NUMBER,
      pnsinies IN NUMBER,
      pntramit IN NUMBER,
      pctipres IN NUMBER,
      pnmovres IN NUMBER,
      pcidioma IN NUMBER)
      RETURN NUMBER IS
      -- Bug 0023188 - 23/08/2012 - JMF
/*
   ************************************************************************
   Cálculo de cesión de reservas de siniestros para el Coaseguro
   ************************************************************************
*/
      num_err        NUMBER := 0;
      text_error     VARCHAR2(500);
      pnnumlin       NUMBER;
      texto          VARCHAR2(400);
      indice_error   NUMBER := 0;
      v_estado       NUMBER;
      v_titulo       VARCHAR2(50);
      psql           VARCHAR2(500);
      psmovcoa       NUMBER;
      v_cursor       INTEGER;
      v_truncatectacoaseguroaux VARCHAR2(40);
      v_numrows      INTEGER;
      psproces       NUMBER;
      pcerror        NUMBER;

      FUNCTION f_insert_reservas_sin(
         pcempres IN NUMBER,
         pnsinies IN NUMBER,
         pntramit IN NUMBER,
         pctipres IN NUMBER,
         pnmovres IN NUMBER,
         pcidioma IN NUMBER,
         pproces IN NUMBER,
         psql OUT VARCHAR2,
         psmovcoa OUT NUMBER)
         RETURN NUMBER IS
      -- Bug 0023188 - 23/08/2012 - JMF
/*
   ************************************************************************
   Cálculo de cesión de reservas de siniestros para el Coaseguro
   ************************************************************************
*/
         vobj           VARCHAR2(500) := 'pac_coa.f_insert_reservas_sin';
         vpar           VARCHAR2(500)
            := 'pcempres=' || pcempres || ' pnsinies=' || pnsinies || ' pntramit=' || pntramit
               || ' pctipres=' || pctipres || ' pnmovres=' || pnmovres || ' pcidioma='
               || pcidioma || ' pproces=' || pproces;
         vpas           NUMBER := 0;
         perror         NUMBER := 0;
         v_cmovimi      ctacoaseguroaux.cmovimi%TYPE := 25;   -- Reservas.
         d_perini       DATE;
         d_perfin       DATE;
         xsigno         NUMBER(1);
         vnmoneda       monedas.cmoneda%TYPE;
         ximporte       NUMBER;
         ximporte_moncia NUMBER;
         w_smovcoa      ctacoaseguro.smovcoa%TYPE;
         v_cdebhab      ctacoaseguroaux.cdebhab%TYPE;
         e_salida       EXCEPTION;
         -- 8. MMM - 0025872: LCOL_F002-Revision Qtrackers contabilidad F2 - Nota 0148800 - Inicio
         xnmovpag       NUMBER;
         xcestpag       NUMBER;
         v_no_cede_coa  NUMBER := 0;   -- Bug 29409/161614 - 17/12/2013 - AMC
         vctipcoa       NUMBER;
         vnumctacoa     NUMBER;   -- 17/09/2014   EDA  Bug: 32159
         vcimporte      NUMBER;   -- 17/09/2014   EDA  Bug: 32159
         v_simovimi     NUMBER;   -- 17/09/2014   EDA  Bug: 32159
         v_simoncon     NUMBER;   -- 17/09/2014   EDA  Bug: 32159
         v_existe       NUMBER;   -- 17/09/2014   EDA  Bug: 32159
         v_nmovres      ctacoaseguro.nmovres%TYPE;   -- 17/09/2014   EDA  Bug: 32159

         -- 8. MMM - 0025872: LCOL_F002-Revision Qtrackers contabilidad F2 - Nota 0148800 - Fin
         CURSOR c2 IS
            SELECT   si.nsinies nsin, si.fsinies fsin, si.fnotifi fnot,
                                                                                                                         -- 8. MMM - 0025872: LCOL_F002-Revision Qtrackers contabilidad F2 - Nota 0148800 - Inicio
                                                                                                                         -- Se recupera el sidepag, en lugar de informarlo a 0 y se añade la recuperación del ntramit
                                                                       --0 sidepag,
                                                                       sr.sidepag, sr.ntramit,
                     sr.nmovres,
                                -- 8. MMM - 0025872: LCOL_F002-Revision Qtrackers contabilidad F2 - Nota 0148800 - Fin
                                sr.ctipres, TO_CHAR(f_sysdate, 'mm') mes_pag,
                     TO_CHAR(f_sysdate, 'yyyy') anyo_pag, si.sseguro sseg, si.nriesgo nrie,
                     TO_CHAR(si.fsinies, 'mm') mes_sin, TO_CHAR(si.fsinies, 'yyyy') anyo_sin,
                     si.ncuacoa ncua, sr.cgarant cgar, s.cramo cramo, 0 ctippag,
                     NVL(sr.ireserva_moncia, 0) ireserva_moncia, NVL(sr.ireserva, 0) ireserva,
                     s.ctipcoa, sr.cmonres, sr.fcambio, s.sproduc, s.ccompani ccompapr,
                     DECODE(sr.ctipres, 1, 25, 2, 26, 3, 27, 4, 28, 25) vcimporte,
                     sr.ctipgas ctipgas, s.cactivi
                FROM sin_siniestro si, seguros s, sin_tramita_reserva sr
               WHERE si.sseguro = s.sseguro
                 AND NVL(s.ctipcoa, 0) IN(1, 2, 8, 9)
                 AND s.cempres = pcempres
                 AND si.nsinies = sr.nsinies
                 AND(NVL(ipago, 0) = 0
                     OR sr.sidepag IS NULL   -- 8. MMM - 0025872: LCOL_F002-Revision Qtrackers contabilidad F2 - Nota 0148800
                     OR sr.sidepag IN(SELECT sidepag
                                        FROM sin_tramita_movpago stm
                                       WHERE stm.sidepag = sr.sidepag
                                         AND stm.cestpag IN(0, 1, 8, 9)
                                         AND stm.nmovpag IN(SELECT MAX(nmovpag)
                                                              FROM sin_tramita_movpago stm2
                                                             WHERE stm.sidepag = stm2.sidepag)))
                 AND si.nsinies = pnsinies
                 AND sr.ntramit = pntramit
                 AND sr.ctipres = pctipres
                 AND sr.nmovres = pnmovres
            ORDER BY nsin, mes_pag, anyo_pag, sidepag;

         CURSOR c3(pc_seg IN NUMBER, pc_cua IN NUMBER) IS
            SELECT ccompan, pcescoa
              FROM coacedido
             WHERE sseguro = pc_seg
               AND ncuacoa = pc_cua;

         CURSOR c4 IS
            SELECT *
              FROM ctacoaseguroaux
             WHERE cmovimi = v_cmovimi;
      BEGIN
         vpas := 100;

         FOR f2 IN c2 LOOP
            -- Bug 29409/161614 - 17/12/2013 - AMC
            IF f2.cgar IS NOT NULL THEN
               v_no_cede_coa := NVL(pac_parametros.f_pargaranpro_n(f2.sproduc, f2.cactivi,
                                                                   f2.cgar,
                                                                   'NO_CEDE_COASEGURO'),
                                    0);
            ELSE
               v_no_cede_coa := 0;
            END IF;

            IF v_no_cede_coa = 0 THEN
               -- buscamos el signo
               vpas := 130;

               FOR f3 IN c3(f2.sseg, f2.ncua) LOOP
                  -- buscamos el importe a grabar en la cuenta
                  IF f2.ctipcoa IN(1, 2) THEN   -- cedido
                     vpas := 150;
                     vnmoneda := pac_monedas.f_cmoneda_n(f2.cmonres);
                     vpas := 160;
                     perror := f_importecoa(f2.sseg, f2.ncua, f2.ireserva, f3.ccompan,
                                            f3.pcescoa, vnmoneda, ximporte);
                     vpas := 170;
                     perror := f_importecoa(f2.sseg, f2.ncua, f2.ireserva_moncia, f3.ccompan,
                                            f3.pcescoa, vnmoneda, ximporte_moncia);

-- Inicio 17/09/2014   EDA  Bug: 32159
                     SELECT NVL(SUM(imovimi * DECODE(cdebhab, 1, 1, -1)), 0),
                            NVL(SUM(imovimi_moncon * DECODE(cdebhab, 1, 1, -1)), 0)
                       INTO v_simovimi,
                            v_simoncon
                       FROM ctacoaseguro
                      WHERE nsinies = pnsinies
                        AND NVL(ctipgas, 0) = NVL(f2.ctipgas, NVL(ctipgas, 0))
                        AND NVL(cgarant, 0) = NVL(f2.cgar, NVL(cgarant, 0))
                        AND ntramit = f2.ntramit
                        AND cmovimi = v_cmovimi
                        AND ctipcoa = f2.ctipcoa
                        AND ccompani = f3.ccompan
                        AND cimport = f2.vcimporte;

                     ximporte := ximporte - v_simovimi;
                     ximporte_moncia := ximporte_moncia - v_simoncon;
                  ELSIF f2.ctipcoa IN(8, 9) THEN   -- aceptado
                     vpas := 180;

                     SELECT NVL(SUM((imovimi * DECODE(cdebhab, 1, 1, -1)) / pcescoa * 100), 0),
                            NVL(SUM((imovimi_moncon * DECODE(cdebhab, 1, 1, -1)) / pcescoa
                                    * 100),
                                0)
                       INTO v_simovimi,
                            v_simoncon
                       FROM ctacoaseguro
                      WHERE nsinies = pnsinies
                        AND NVL(ctipgas, 0) = NVL(f2.ctipgas, NVL(ctipgas, 0))
                        AND NVL(cgarant, 0) = NVL(f2.cgar, NVL(cgarant, 0))
                        AND ntramit = f2.ntramit
                        AND cmovimi = v_cmovimi
                        AND ctipcoa = f2.ctipcoa
                        AND ccompani = f3.ccompan
                        AND cimport = f2.vcimporte;

                     ximporte := f2.ireserva - v_simovimi;
                     ximporte_moncia := f2.ireserva_moncia - v_simoncon;
-- Fin 17/09/2014   EDA  Bug: 32159
                  END IF;

                  IF perror <> 0 THEN
                     psql := SQLERRM;
                     psmovcoa := f2.sseg;
                     RAISE e_salida;
                  END IF;

                  vpas := 190;

                  IF ximporte >= 0 THEN
                     v_cdebhab := 1;
                  ELSE
                     v_cdebhab := 2;
                     ximporte := ximporte * -1;
                     ximporte_moncia := ximporte_moncia * -1;
                  END IF;

                  BEGIN
                     vpas := 200;

                     SELECT COUNT(*)
                       INTO v_existe
                       FROM ctacoaseguro
                      WHERE nsinies = pnsinies
                        AND NVL(ctipgas, 0) = NVL(f2.ctipgas, NVL(ctipgas, 0))
                        AND NVL(cgarant, 0) = NVL(f2.cgar, NVL(cgarant, 0))
                        AND ntramit = f2.ntramit
                        AND cmovimi = v_cmovimi
                        AND ctipcoa = f2.ctipcoa
                        AND ccompani = f3.ccompan
                        AND cimport = f2.vcimporte
                        AND nmovres = f2.nmovres
                        AND imovimi = ximporte
                        AND NVL(sidepag, 0) = NVL(f2.sidepag, 0);

                     IF ximporte <> 0
                        AND v_existe = 0 THEN
                        -- 17/09/2014   EDA  Bug: 32159
                        SELECT NVL(MAX(nmovres), 0)
                          INTO v_nmovres
                          FROM ctacoaseguro
                         WHERE nsinies = pnsinies
                           AND NVL(ctipgas, 0) = NVL(f2.ctipgas, NVL(ctipgas, 0))
                           AND NVL(cgarant, 0) = NVL(f2.cgar, NVL(cgarant, 0))
                           AND ntramit = f2.ntramit
                           AND cmovimi = v_cmovimi
                           AND ctipcoa = f2.ctipcoa
                           AND ccompani = f3.ccompan
                           AND cimport = f2.vcimporte
                           AND((sidepag IS NOT NULL
                                AND f2.sidepag IS NOT NULL)
                               OR(f2.sidepag IS NULL));

                        IF v_nmovres <= f2.nmovres THEN
                           -- 23830 AVT 08/11/2012 afegim la ccompapr

                           -- 23830 AVT 08/11/2012 afegim la ccompapr
                           INSERT INTO ctacoaseguroaux
                                       (ccompani, cimport, ctipcoa, cmovimi,
                                        imovimi,
                                                --fmovimi, fcontab, cdebhab, fliqcia, pcescoa, sidepag, nrecibo,
                                                fmovimi, fcierre, cdebhab, fliqcia,
                                        pcescoa, sidepag, nrecibo,   -- BUG 0025357/0138513 - FAL - 12/03/2013
                                                                  smovrec, cempres,
                                        sseguro, sproduc, imovimi_moncon, fcambio,
                                        nsinies, cestado, ccompapr, ctipgas,
                                                                            -- 8. 0025872: LCOL_F002-Revisi?n Qtrackers contabilidad F2 - Nota 0148800 - Inicio
                                                                            ntramit,
                                        nmovres, cgarant
                                                        -- 8. 0025872: LCOL_F002-Revisi?n Qtrackers contabilidad F2 - Nota 0148800 - Fin
                                       )
                                VALUES (f3.ccompan, f2.vcimporte, f2.ctipcoa, v_cmovimi,
                                        ximporte, f_sysdate, f_sysdate, v_cdebhab, NULL,
                                        f3.pcescoa, f2.sidepag, /* NULL,*/   -- 8. 0025872: LCOL_F002-Revisi?n Qtrackers contabilidad F2 - Nota 0148800
                                                               NULL, NULL, pcempres,
                                        f2.sseg, f2.sproduc, ximporte_moncia, f2.fcambio,
                                        f2.nsin, 4, f2.ccompapr, f2.ctipgas,
                                                                            -- 8. 0025872: LCOL_F002-Revision Qtrackers contabilidad F2 - Nota 0148800 - Inicio
                                                                            f2.ntramit,
                                        f2.nmovres, f2.cgar
                                                           -- 8. 0025872: LCOL_F002-Revision Qtrackers contabilidad F2 - Nota 0148800 - Fin
                                       );   --> NO EXISTENT PER QUE NO ES PUGUI LIQUIDAR
                        END IF;
                     END IF;   -- Fin 17/09/2014   EDA  Bug: 32159
                  EXCEPTION
                     WHEN OTHERS THEN
                        perror := 108168;
                        psql := SQLERRM;
                        psmovcoa := f2.sseg;
                        RAISE e_salida;
                  END;
               END LOOP;
            END IF;
         -- Fi Bug 29409/161614 - 17/12/2013 - AMC
         END LOOP;

         -- Bug 29409/161614 - 17/12/2013 - AMC
         IF vpas = 100
            AND v_no_cede_coa <> 1 THEN
            BEGIN
               SELECT s.ctipcoa
                 INTO vctipcoa
                 FROM sin_siniestro si, seguros s
                WHERE si.sseguro = s.sseguro
                  AND si.nsinies = pnsinies;
            EXCEPTION
               WHEN OTHERS THEN
                  vctipcoa := 0;
            END;

            IF vctipcoa = 1 THEN
               p_tab_error(f_sysdate, f_user, 'PAC_COA.f_reservas_sin_online', vpas,
                           'No ha entrado en el cursor', vpar);
            END IF;
         END IF;

         -- Fi Bug 29409/161614 - 17/12/2013 - AMC
         vpas := 210;

         IF perror = 0 THEN
            vpas := 220;

            FOR f4 IN c4 LOOP
               vpas := 230;

               SELECT smovcoa.NEXTVAL
                 INTO w_smovcoa
                 FROM DUAL;

               BEGIN
                  vpas := 240;

-- 23830 AVT 08/11/2012 afegim la ccompapr
                  INSERT INTO ctacoaseguro
                              (smovcoa, ccompani, cimport, ctipcoa, cmovimi,
                               --imovimi, fmovimi, fcontab, cdebhab, fliqcia,
                               imovimi, fmovimi, fcierre, cdebhab, fliqcia,   -- BUG 0025357/0138513 - FAL - 19/02/2013
                               pcescoa, sidepag, nrecibo, smovrec, cempres,
                               sseguro, sproduc, imovimi_moncon, fcambio,
                               nsinies, cestado, ccompapr, ctipgas, cmoneda,
                               -- 8. 0025872: LCOL_F002-Revisi?n Qtrackers contabilidad F2 - Nota 0148800 - Inicio
                               ntramit, nmovres, cgarant
                                                        -- 8. 0025872: LCOL_F002-Revisi?n Qtrackers contabilidad F2 - Nota 0148800 - Fin
                              )   -- BUG 0025357/0138513 - FAL - 19/02/2013
                       VALUES (w_smovcoa, f4.ccompani, f4.cimport, f4.ctipcoa, f4.cmovimi,
                               --f4.imovimi, f4.fmovimi, f4.fcontab, f4.cdebhab, f4.fliqcia,
                               f4.imovimi, f4.fmovimi, f4.fcierre, f4.cdebhab, f4.fliqcia,   -- BUG 0025357/0138513 - FAL - 19/02/2013
                               f4.pcescoa, f4.sidepag, f4.nrecibo, f4.smovrec, f4.cempres,
                               f4.sseguro, f4.sproduc, f4.imovimi_moncon, f4.fcambio,
                               f4.nsinies, f4.cestado, f4.ccompapr, f4.ctipgas, vnmoneda,
                               -- 8. 0025872: LCOL_F002-Revisi?n Qtrackers contabilidad F2 - Nota 0148800 - Inicio
                               f4.ntramit, f4.nmovres, f4.cgarant
                                                                 -- 8. 0025872: LCOL_F002-Revisi?n Qtrackers contabilidad F2 - Nota 0148800 - Fin
                              );   -- BUG 0025357/0138513 - FAL - 19/02/2013
               EXCEPTION
                  WHEN OTHERS THEN
                     perror := 105578;
                     psql := SQLERRM;
                     psmovcoa := f4.sseguro;
                     RAISE e_salida;
               END;
            END LOOP;
         END IF;

         RETURN(perror);
      EXCEPTION
         WHEN e_salida THEN
            IF c4%ISOPEN THEN
               CLOSE c4;
            END IF;

            IF c3%ISOPEN THEN
               CLOSE c3;
            END IF;

            IF c2%ISOPEN THEN
               CLOSE c2;
            END IF;

            p_tab_error(f_sysdate, f_user, vobj, vpas, vpar,
                        perror || ' ' || NVL(psql, SQLCODE || ' ' || SQLERRM));
            RETURN(perror);
      END f_insert_reservas_sin;
   BEGIN
      v_titulo := 'Cierre Coaseguro Diario';
      --Insertamos en la tabla PROCESOSCAB el registro identificativo de proceso -----
      num_err := f_procesini(f_user, pcempres, 'COASEGURO', v_titulo, psproces);

      IF num_err <> 0 THEN
         pcerror := 1;
         texto := f_axis_literales(num_err, pcidioma);
         pnnumlin := NULL;
         num_err := f_proceslin(psproces, SUBSTR(texto || ' ' || text_error, 1, 120), 0,
                                pnnumlin);
      -- COMMIT;
      ELSE
         -- *** Se trunca la tabla auxiliar CTACOASEGUROAUX...
         BEGIN
            -- Para poder ejecutar la instruccion 'TRUNCATE'
            v_cursor := DBMS_SQL.open_cursor;
            v_truncatectacoaseguroaux := 'TRUNCATE TABLE CTACOASEGUROAUX';
            DBMS_SQL.parse(v_cursor, v_truncatectacoaseguroaux, DBMS_SQL.native);
            v_numrows := DBMS_SQL.EXECUTE(v_cursor);
            DBMS_SQL.close_cursor(v_cursor);
         EXCEPTION
            WHEN OTHERS THEN
               IF DBMS_SQL.is_open(v_cursor) THEN
                  DBMS_SQL.close_cursor(v_cursor);
               END IF;

               num_err := 108191;   -- Error al borrar la tabla
         END;

         IF num_err <> 0 THEN
            pcerror := 1;
            texto := f_axis_literales(num_err, pcidioma);
            pnnumlin := NULL;
            text_error := SUBSTR(texto || ' ' || psql, 1, 120);
            num_err := f_proceslin(psproces, text_error, 0, pnnumlin);
         --COMMIT;
         ELSE
            num_err := f_insert_reservas_sin(pcempres, pnsinies, pntramit, pctipres, pnmovres,
                                             pcidioma, psproces, psql, psmovcoa);

            IF num_err <> 0 THEN
               pcerror := 1;
               texto := f_axis_literales(num_err, pcidioma);
               pnnumlin := NULL;
               text_error := SUBSTR(texto || ' ' || psql, 1, 120);
               num_err := f_proceslin(psproces, text_error, psmovcoa, pnnumlin);
            -- COMMIT;
            ELSE
               -- COMMIT;   -- COMMIT PRINCIPAL DEL PROCESO...
               pcerror := 0;
            END IF;
         END IF;
      END IF;

      num_err := f_procesfin(psproces, pcerror);
            --pfproces := f_sysdate;
           /* IF num_err = 0 THEN
               COMMIT;
            END IF;
      */
      RETURN(num_err);
   END f_reservas_sin_online;

   /*
     RDD -  14/02/2012 - bug 25872 - comentario 138055
     Función devuelve el importe de coaseguro por compañía
   */
   FUNCTION f_impcoa_ccomp(
      psseguro IN NUMBER,
      pccompan IN NUMBER,
      pfinicoa IN DATE,
      pimporte IN NUMBER)
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 0;
      v_param        VARCHAR2(500)
         := 'psseguro: ' || TO_CHAR(psseguro) || ', pccompan: ' || TO_CHAR(pccompan)
            || ', pfinicoa ' || TO_CHAR(pfinicoa, 'dd/mm/yyyy') || ', pimporte: '
            || TO_CHAR(pimporte);
      v_object       VARCHAR2(200) := 'PAC_COA.f_impcor_ccomp';
      v_numerr       NUMBER := 0;
      v_monedinst    NUMBER;
      v_implider     NUMBER;
      v_ccompanlider NUMBER;
      v_ccompan      NUMBER;
      v_importccomp  NUMBER;
      v_impaux       NUMBER := 0;
      v_importeregistro NUMBER;
      v_faltante     NUMBER;

      CURSOR c_coaseguro IS
         SELECT b.ccompan, pcescoa, pcesion
           FROM coacuadro a, coacedido b
          WHERE a.sseguro = psseguro   --6706
            AND a.ncuacoa = (SELECT MAX(z.ncuacoa)
                               FROM coacuadro z
                              WHERE z.sseguro = a.sseguro
                                AND z.fcuacoa <= TRUNC(pfinicoa)
                                                 + 0.99999   --to_date('16112012','ddmmyyyy')
                                                          )
            AND b.sseguro = a.sseguro
            AND b.ncuacoa = a.ncuacoa;

      TYPE ARRAY IS TABLE OF c_coaseguro%ROWTYPE;

      l_data         ARRAY;
   BEGIN
      v_monedinst := pac_parametros.f_parinstalacion_n('MONEDAINST');
      v_implider := NULL;
      v_ccompanlider := NULL;

      OPEN c_coaseguro;

      LOOP
         FETCH c_coaseguro
         BULK COLLECT INTO l_data LIMIT 200;

         FOR i IN 1 .. l_data.COUNT LOOP
            v_importeregistro := f_round((pimporte   --*(NVL(l_data(i).pcescoa, 100) / 100)
                                          *(NVL(l_data(i).pcesion, 100) / 100)),
                                         v_monedinst);
            v_impaux := v_impaux + v_importeregistro;

            IF (v_implider IS NULL
                OR v_implider <= v_importeregistro) THEN
               v_ccompanlider := l_data(i).ccompan;
               v_implider := v_importeregistro;
            END IF;

            IF pccompan = l_data(i).ccompan THEN
               v_importccomp := v_importeregistro;
            END IF;
         END LOOP;

         EXIT WHEN c_coaseguro%NOTFOUND;
      END LOOP;

      CLOSE c_coaseguro;

      v_faltante := f_round(pimporte, v_monedinst) - v_impaux;

      IF (v_ccompanlider = pccompan) THEN
         RETURN(NVL(v_implider, 0) + NVL(v_faltante, 0));
      ELSE
         RETURN NVL(v_importccomp, 0);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param,
                     'num_err=' || v_numerr || ' --> Error: ' || SQLERRM);
         RETURN 0;
   END f_impcoa_ccomp;

 /*******************************************************************************
FUNCION F_SET_REMESA_DET
Esta función nos devolverá la consulta de remesas

********************************************************************************/
   -- Bug 22076 - AVT - 04/10/2012 - se crea la funcion
    function F_SET_REMESA_CTACOA(
        pcempres IN NUMBER,
        pccompani IN NUMBER,
        pnnumlin IN NUMBER,
        pctipcoa IN NUMBER,
        pcdebhab IN NUMBER,
        psseguro IN NUMBER,
        pnrecibo IN NUMBER,
        psidepag IN NUMBER,
        pfcierre IN DATE,
        pcmovimi IN NUMBER,
        pcimport IN NUMBER,
        pimovimi IN NUMBER,
        pfcambio IN DATE,
        pcestado IN NUMBER,
        ptdescri IN VARCHAR2,
        ptdocume IN VARCHAR2,
        PMODO in number,
        PNPOLCIA in number,
        PCSUCURSAL in number,
        PMONEDA in number,
        psmvcoa in number        )
    return number is  --ramiro
        V_PASEXEC      number(8) := 1;
        VPARAM         varchar2(200) :=  PCEMPRES||','||PCCOMPANI||','||PNNUMLIN||','||PNPOLCIA||','||PCSUCURSAL||','||
                       pcestado||','||pfcierre||','||pcmovimi||','||pctipcoa||','||PIMOVIMI||','||PMODO;
        vobject        VARCHAR2(200) := 'PAC_COA.F_SET_REMESA_CTACOA';
        V_TITULO       varchar2(200);
        NUM_ERR        NUMBER;
        verror         number :=0;
        v_sproduc      NUMBER;
        v_smovrec      NUMBER;
        v_itasa        NUMBER;
        v_cmultimon    parempresas.nvalpar%TYPE
                     := NVL(pac_parametros.f_parempresa_n(pcempres, 'MULTIMONEDA'), 0);
        v_cmoncontab   parempresas.nvalpar%TYPE
                            := pac_parametros.f_parempresa_n(pcempres, 'MONEDACONTAB');
        v_importe_mon  NUMBER;
        v_cestado      movctatecnica.cestado%TYPE;
        v_cmovimi      ctacoaseguro.cmovimi%TYPE;
        v_ctippag      sin_tramita_pago.ctippag%TYPE;
        v_ncuacoa      seguros.ncuacoa%TYPE;
        v_pcescoa      coacedido.pcescoa%TYPE;
        V_CMONEDA      SEGUROS.CMONEDA%type;
        V_CCOMPAPR     SEGUROS.CCOMPANI%type;
        VFCAMBIO       date;
        v_nnumlin       NUMBER;
        Vcdebhab        NUMBER;
        VCIMPORT        NUMBER;
        VPORGASTO       NUMBER;
        VPORRETEIVA     NUMBER;
        VPORRETEICA     NUMBER;
        VPORRETFTEGASADM    NUMBER;
        vptipiva        NUMBER;
        VGASADM         NUMBER;
        VIVAGASADM      NUMBER;
        VRETIVAGASADM   NUMBER;
        VRETFTEGASADM   NUMBER;
        VRETICAGASADM   NUMBER;
        vvalor          number;
        xxsesion        number;
        vret            number;
    BEGIN
        V_pasexec := 0;

        -- Retefuente
        BEGIN
            SELECT DECODE (r.cregfiscal, 6, 0, 8, 0, DECODE (p.ctipper, 1, 1, 2))
              INTO vvalor
              FROM companias cp, per_personas p,(SELECT sperson, cregfiscal
                                                   FROM per_regimenfiscal
                                                  WHERE (sperson, fefecto) IN (SELECT   sperson, MAX (fefecto)
                                                                                 FROM per_regimenfiscal
                                                                             GROUP BY sperson)) r
             WHERE cp.ccompani = pccompani
               AND p.sperson = cp.sperson
               AND p.sperson = r.sperson(+);

            SELECT sgt_sesiones.NEXTVAL
              INTO xxsesion
              FROM DUAL;

            SELECT vtramo (xxsesion, 800064, vvalor)
              INTO VPORRETFTEGASADM
              FROM DUAL;

        EXCEPTION
            WHEN OTHERS THEN
                p_tab_error (f_sysdate, f_user, vobject, v_pasexec, VPARAM, 107885 || ' - ' || SQLCODE || ' - ' || SQLERRM);
        END;


        v_pasexec := 0.1;

        VPORGASTO   := NVL(pac_parametros.f_parempresa_n(pcempres, 'PORGAST_ADMCOA'), 0);--Porcentaje Gastos de Administración
        VPORRETEIVA := NVL(pac_parametros.f_parempresa_n(pcempres, 'PORRETIVA_ADMCOA'), 0);--Porcentaje RETEIVA Gastos de Administración

        BEGIN--Porcentaje IVA
            SELECT ptipiva
              INTO vptipiva
              FROM tipoiva t, companias co
             WHERE co.ccompani = pccompani
               AND co.ctipiva = t.ctipiva
               AND t.ffinvig IS NULL;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                Vptipiva := 0;
            WHEN OTHERS THEN
                p_tab_error(f_sysdate, f_user, vobject, v_pasexec, VPARAM,  107885 || ' ' || NVL(SQLERRM, SQLCODE || ' ' || SQLERRM));
        END;

        --ReteICA
        VPORRETEICA := PAC_IMPUESTOS_CONF.F_RETEICA_INDICADOR_COA (pccompani);

        IF pcimport IS NULL and pmodo = 1 THEN
            VERROR := 9904287;   -- Tipus Import Coassegurança Obligatori
        ELSE
            V_CMOVIMI := 99;
        END IF;

        IF VERROR = 0 THEN
            IF pmodo = 1 THEN   --Inserci?n de registros
                vfcambio := pfcierre;
            ELSE
                IF pfcambio IS NULL THEN
                    vfcambio := pfcierre;
                ELSE
                    vfcambio := pfcambio;
                END IF;
            END IF;

            IF pfcierre IS NOT NULL AND TRUNC(pfcierre) < NVL(pac_cierres.f_fecha_ultcierre(pcempres, 5), pfcierre) THEN
                RETURN 107855;
            END IF;

            IF V_CMULTIMON = 1 THEN
                IF verror <> 0 THEN
                    RETURN verror;
                END IF;

                V_IMPORTE_MON := F_ROUND(NVL(PIMOVIMI, 0) * V_ITASA, V_CMONCONTAB);
            END IF;

            IF pmodo = 0 THEN   --Modificación de registros
                SELECT NVL(cestado, 1)
                  INTO v_cestado
                  FROM ctacoaseguro
                 WHERE  smovcoa = psmvcoa;
            ELSE
                v_cestado := 1;
                V_CCOMPAPR := PCCOMPANI;

                IF (PMONEDA is null) THEN
                    V_CMONEDA := V_CMONCONTAB;
                ELSE
                    V_CMONEDA :=   PMONEDA;
                end if;

            END IF;


            IF pmodo = 0 THEN   --Modificación de registros
                v_pasexec := 6;

                UPDATE ctacoaseguro
                   SET --cestado = pcestado,
                        tdescri = ptdescri,
                        tdocume = ptdocume,
                        cimport = pcimport,
                        cdebhab = pcdebhab,
                        IMOVIMI = PIMOVIMI,
                        cmoneda = PMONEDA --JAAB 26/02/2018 CONF-QT1621 Se agregan pcimport, pcdebhab, PIMOVIMI y V_CMONEDA
                  WHERE smovcoa = psmvcoa;
            ELSIF pmodo = 1 THEN   --Inserción de registros Manuales
            --Los cambios hechos aquí deben replicarse en f_insctacoas y pac_coa.F_SET_REMESA_CTACOA y pac_coa.F_insctacoas_parcial
                v_pasexec := 7;

                SELECT smovcoa.NEXTVAL
                  INTO v_nnumlin
                  FROM DUAL;

                V_SPRODUC := NULL;
                v_ncuacoa := null;
                v_pasexec := 8;

                --BUG 0025098: FIN  - 4-02-2013  - DCT
                v_pasexec := 9;

                INSERT INTO ctacoaseguro
                          (SMOVCOA, CCOMPANI, SPRODUC, CIMPORT, CTIPCOA,
                           cmovimi, imovimi, FCIERRE, cdebhab,
                           sidepag, nrecibo, smovrec, cempres, sseguro, ctipmov, tdescri,
                           TDOCUME, FCAMBIO, IMOVIMI_MONCON, PCESCOA, CESTADO,
                           cmoneda, ccompapr,CSUCURSAL,NPOLCIA,FMOVIMI)
                   VALUES (v_nnumlin, pccompani, v_sproduc, pcimport, pctipcoa,
                           NVL(pcmovimi, v_cmovimi), pimovimi, pfcierre, pcdebhab,
                           psidepag, pnrecibo, v_smovrec, pcempres, psseguro, 1, ptdescri,
                           PTDOCUME, VFCAMBIO, V_IMPORTE_MON, 0, PCESTADO,
                           v_cmoneda, v_ccompapr,pcsucursal,PNPOLCIA,F_SYSDATE);

                --JAAB QT1613 Inicio
                --Se calculan los conceptos automàticos
                IF PCIMPORT = 1 THEN
                    IF pcdebhab = 1 THEN
                        Vcdebhab := 2;
                    ELSIF pcdebhab = 2 THEN
                        Vcdebhab := 1;
                    END IF;
                ELSE
                    Vcdebhab := pcdebhab;
                END IF;

                IF PCIMPORT = 1 THEN --prima
                    v_pasexec := 10;
                    VCIMPORT := 4; --Gastos de Administración
                    SELECT smovcoa.NEXTVAL
                      INTO v_nnumlin
                      FROM DUAL;

                    VGASADM := ROUND(PIMOVIMI * VPORGASTO / 100, 0);

                    INSERT INTO ctacoaseguro
                          (SMOVCOA, CCOMPANI, SPRODUC, CIMPORT, CTIPCOA,
                           cmovimi, imovimi, FCIERRE, cdebhab,
                           sidepag, nrecibo, smovrec, cempres, sseguro, ctipmov, tdescri,
                           TDOCUME, FCAMBIO, IMOVIMI_MONCON, PCESCOA, CESTADO,
                           cmoneda, ccompapr,CSUCURSAL,NPOLCIA,FMOVIMI)
                    VALUES (v_nnumlin, pccompani, v_sproduc, VCIMPORT, pctipcoa,
                           NVL(pcmovimi, v_cmovimi), VGASADM, pfcierre, Vcdebhab,
                           psidepag, pnrecibo, v_smovrec, pcempres, psseguro, 1, ptdescri,
                           PTDOCUME, VFCAMBIO, V_IMPORTE_MON, 0, PCESTADO,
                           v_cmoneda, v_ccompapr,pcsucursal,PNPOLCIA,F_SYSDATE);
                ELSIF PCIMPORT = 4 THEN
                    VGASADM := PIMOVIMI;
                END IF;

                IF PCIMPORT IN (1,4) THEN
                    v_pasexec := 11;
                    VCIMPORT := 13; --IVA sobre gastos de Administración
                    SELECT smovcoa.NEXTVAL
                      INTO v_nnumlin
                      FROM DUAL;

                    VIVAGASADM := ROUND(VGASADM * vptipiva / 100, 0);

                    INSERT INTO ctacoaseguro
                          (SMOVCOA, CCOMPANI, SPRODUC, CIMPORT, CTIPCOA,
                           cmovimi, imovimi, FCIERRE, cdebhab,
                           sidepag, nrecibo, smovrec, cempres, sseguro, ctipmov, tdescri,
                           TDOCUME, FCAMBIO, IMOVIMI_MONCON, PCESCOA, CESTADO,
                           cmoneda, ccompapr,CSUCURSAL,NPOLCIA,FMOVIMI)
                    VALUES (v_nnumlin, pccompani, v_sproduc, VCIMPORT, pctipcoa,
                           NVL(pcmovimi, v_cmovimi), VIVAGASADM, pfcierre, Vcdebhab,
                           psidepag, pnrecibo, v_smovrec, pcempres, psseguro, 1, ptdescri,
                           PTDOCUME, VFCAMBIO, V_IMPORTE_MON, 0, PCESTADO,
                           v_cmoneda, v_ccompapr,pcsucursal,PNPOLCIA,F_SYSDATE);

                    IF PCIMPORT = 1 THEN
                        Vcdebhab := PCDEBHAB;
                    ELSE
                        IF pcdebhab = 1 THEN
                            Vcdebhab := 2;
                        ELSIF pcdebhab = 2 THEN
                            Vcdebhab := 1;
                        END IF;
                    END IF;

                    v_pasexec := 12;
                    VCIMPORT := 38; --Retención de IVA sobre gastos de Administración
                    SELECT smovcoa.NEXTVAL
                      INTO v_nnumlin
                      FROM DUAL;

                    VRETIVAGASADM := ROUND(VIVAGASADM * VPORRETEIVA / 100, 0);

                    INSERT INTO ctacoaseguro
                          (SMOVCOA, CCOMPANI, SPRODUC, CIMPORT, CTIPCOA,
                           cmovimi, imovimi, FCIERRE, cdebhab,
                           sidepag, nrecibo, smovrec, cempres, sseguro, ctipmov, tdescri,
                           TDOCUME, FCAMBIO, IMOVIMI_MONCON, PCESCOA, CESTADO,
                           cmoneda, ccompapr,CSUCURSAL,NPOLCIA,FMOVIMI)
                    VALUES (v_nnumlin, pccompani, v_sproduc, VCIMPORT, pctipcoa,
                           NVL(pcmovimi, v_cmovimi), VRETIVAGASADM, pfcierre, Vcdebhab,
                           psidepag, pnrecibo, v_smovrec, pcempres, psseguro, 1, ptdescri,
                           PTDOCUME, VFCAMBIO, V_IMPORTE_MON, 0, PCESTADO,
                           v_cmoneda, v_ccompapr,pcsucursal,PNPOLCIA,F_SYSDATE);

                    v_pasexec := 13;
                    VCIMPORT := 39; --Retención en la fuente sobre gastos de Administración
                    SELECT smovcoa.NEXTVAL
                      INTO v_nnumlin
                      FROM DUAL;

                    VRETFTEGASADM := ROUND(VGASADM * VPORRETFTEGASADM / 100, 0);

                    INSERT INTO ctacoaseguro
                          (SMOVCOA, CCOMPANI, SPRODUC, CIMPORT, CTIPCOA,
                           cmovimi, imovimi, FCIERRE, cdebhab,
                           sidepag, nrecibo, smovrec, cempres, sseguro, ctipmov, tdescri,
                           TDOCUME, FCAMBIO, IMOVIMI_MONCON, PCESCOA, CESTADO,
                           cmoneda, ccompapr,CSUCURSAL,NPOLCIA,FMOVIMI)
                    VALUES (v_nnumlin, pccompani, v_sproduc, VCIMPORT, pctipcoa,
                           NVL(pcmovimi, v_cmovimi), VRETFTEGASADM, pfcierre, Vcdebhab,
                           psidepag, pnrecibo, v_smovrec, pcempres, psseguro, 1, ptdescri,
                           PTDOCUME, VFCAMBIO, V_IMPORTE_MON, 0, PCESTADO,
                           v_cmoneda, v_ccompapr,pcsucursal,PNPOLCIA,F_SYSDATE);

                    v_pasexec := 14;
                    VCIMPORT := 42;	--Retención de ICA sobre gastos de Administración
                    SELECT smovcoa.NEXTVAL
                      INTO v_nnumlin
                      FROM DUAL;

                    VRETICAGASADM := ROUND(VGASADM * VPORRETEICA / 1000, 0);

                    INSERT INTO ctacoaseguro
                          (SMOVCOA, CCOMPANI, SPRODUC, CIMPORT, CTIPCOA,
                           cmovimi, imovimi, FCIERRE, cdebhab,
                           sidepag, nrecibo, smovrec, cempres, sseguro, ctipmov, tdescri,
                           TDOCUME, FCAMBIO, IMOVIMI_MONCON, PCESCOA, CESTADO,
                           cmoneda, ccompapr,CSUCURSAL,NPOLCIA,FMOVIMI)
                    VALUES (v_nnumlin, pccompani, v_sproduc, VCIMPORT, pctipcoa,
                           NVL(pcmovimi, v_cmovimi), VRETICAGASADM, pfcierre, Vcdebhab,
                           psidepag, pnrecibo, v_smovrec, pcempres, psseguro, 1, ptdescri,
                           PTDOCUME, VFCAMBIO, V_IMPORTE_MON, 0, PCESTADO,
                           v_cmoneda, v_ccompapr,pcsucursal,PNPOLCIA,F_SYSDATE);

                END IF;
                --JAAB QT1613 Fin
            END IF;

        end if; --VERROR

        RETURN verror;

    EXCEPTION
      when OTHERS then
             p_tab_error(f_sysdate, f_user, vobject, V_PASEXEC, vparam, 'num_err=' || num_err || ' --> Error: ' || SQLERRM);
             RETURN 9999;

    END F_SET_REMESA_CTACOA;

FUNCTION f_insctacoas_parcial(--RAMIRO
   pnrecibo IN NUMBER,
   pcestrec IN NUMBER,
   pcempres IN empresas.cempres%TYPE DEFAULT pac_md_common.f_get_cxtempresa,   -- 23183 - AVT - 26/10/2012
   psmovrec IN NUMBER,
   PFMOVIMI in date)
   return number is
   -- ini BUG 0026035 - 12/02/2013 - JMF
   v_obj          VARCHAR2(200) := 'f_insctacoas_parcial';
   v_par          VARCHAR2(500)
      := 'rec=' || pnrecibo || ' est=' || pcestrec || 'emp=' || pcempres || ' mov='
         || psmovrec || ' fec=' || pfmovimi;
   -- fin BUG 0026035 - 12/02/2013 - JMF
   error          NUMBER := 0;
   xctipcoa       NUMBER;
   xncuacoa       NUMBER;
   xsseguro       NUMBER;
   xtiprec        NUMBER;
   xtipimp        NUMBER;
   ximporte       NUMBER;
   xsmovcoa       NUMBER;
   xitpri         NUMBER;
   xitcon         NUMBER;
   xittotr        NUMBER;
   xicombru       NUMBER;
   xpcescoa       NUMBER;
   xsignoprima    NUMBER;
   xsignocomis    NUMBER;
   xcestaux       recibos.cestaux%TYPE;
   v_pgasadm      NUMBER;
   vpasexec       NUMBER;
-- Bug 0023183 - DCG - 14/08/2012 - LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
   xcmoneda       NUMBER;
   v_fcambio      DATE;
   v_importe_mon  NUMBER;
   v_itasa        NUMBER;
   v_cmultimon    parempresas.nvalpar%TYPE;
   v_cmoncontab   parempresas.nvalpar%TYPE;
   xsproduc       seguros.sproduc%TYPE;
   xccompapr      seguros.ccompani%TYPE;

-- Fin Bug 0023183

   -- Bug 0023183 - DCG - 14/08/2012 - LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
   -- 23183 - AVT - 26/10/2012 s'afegeix el Coasseguro acceptat.
   -- 23183 - AVT - 01/11/2012 afegim SPRODUC i CCOMPAPR
   CURSOR cur_compania(cpseguro NUMBER, cpcuacoa NUMBER) IS
      SELECT sseguro, ncuacoa, ccompan, pcescoa, pcomcoa, pcomcon, pcomgas, pcesion
        FROM (SELECT c.sseguro, c.ncuacoa, c.ccompan, ploccoa pcescoa, 0 pcomcoa, 0 pcomcon,
                     NVL(pac_preguntas.ff_buscapregunpolseg(s.sseguro, 5700, NULL), 0) pcomgas,
                     ploccoa pcesion
                FROM coacuadro c, seguros s
               WHERE c.sseguro = s.sseguro
                 AND s.ctipcoa = 8
                 AND c.sseguro = cpseguro
                 AND c.ncuacoa = cpcuacoa
              UNION
              SELECT c.sseguro, c.ncuacoa, c.ccompan, c.pcescoa, c.pcomcoa, c.pcomcon,
                     c.pcomgas, c.pcesion
                FROM coacedido c, seguros s
               WHERE c.sseguro = s.sseguro
                 AND s.ctipcoa = 1
                 AND c.sseguro = cpseguro
                 AND c.ncuacoa = cpcuacoa);

   regcom         coacedido%ROWTYPE;
   xcempres       seguros.cempres%TYPE;
   vtmpcontrol    NUMBER;

    --QT 2057
    VCDEBHAB        NUMBER;
    VCIMPORT        NUMBER;
    VPORGASTO       NUMBER;
    VPORRETEIVA     NUMBER;
    VPORRETEICA     NUMBER;
    VPORRETFTEGASADM    NUMBER;
    VPTIPIVA        NUMBER;
    VGASADM         NUMBER;
    VIVAGASADM      NUMBER;
    VRETIVAGASADM   NUMBER;
    VRETFTEGASADM   NUMBER;
    VRETICAGASADM   NUMBER;
    VCCOMPANI       COMPANIAS.CCOMPANI%TYPE;
    VVALOR          NUMBER;
    XXSESION        NUMBER;
    VRET            NUMBER;
    VIMOVIMI        NUMBER;
    VNORDEN         NUMBER;
BEGIN
	--P_CONTROL_ERROR('JAAB', 'INICIA INSCTACOAS', 'v_par: ' || v_par);

   vpasexec := 1;

   -- 1.8 - 22/11/2013 - MMM - 9. 0028986: LCOL_A004-Qtracker: 10043, 10046, 10051 - Inicio
   -- Para evitar problemas si se llama más de una vez para el mismo recibo se incluye un control
   -- Si ya existe el recibo en ctacoaseguro, no hacemos nada y salimos de la función
   /*SELECT COUNT(1)
     INTO vtmpcontrol
     FROM ctacoaseguro
    WHERE nrecibo = pnrecibo
      AND smovrec = psmovrec;

   IF vtmpcontrol > 0 THEN
      p_tab_error(f_sysdate, f_user, 'F_INSCTACOAS = ' || pnrecibo, vpasexec,
                  'Recibo ya existente en CTACOASEGURO', SQLERRM);
      RETURN 0;
   END IF;*/

   UPDATE CTACOASEGURO cta
   SET CESTADO=4
   WHERE NRECIBO=pnrecibo
   and not exists (select 1 from CTACOASEGURO c
                     where cta.nrecibo=c.nrecibo
                     and cestado=4);

   -- 1.8 - 22/11/2013 - MMM - 9. 0028986: LCOL_A004-Qtracker: 10043, 10046, 10051 - Fin

   -- Buscamos el tipo de coaseguro, y el numero de cuadro
   BEGIN
      SELECT r.ctipcoa, r.ncuacoa, r.sseguro, r.ctiprec, r.cempres, s.sproduc, s.ccompani,
             r.cestaux
        INTO xctipcoa, xncuacoa, xsseguro, xtiprec, xcempres, xsproduc, xccompapr,
             xcestaux
        FROM recibos r, seguros s
       WHERE s.sseguro = r.sseguro
         AND nrecibo = pnrecibo;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         p_tab_error(f_sysdate, f_user, 'f_insctacoas_parcial = ' || pnrecibo, vpasexec,
                     'NO_DATA_FOUND FROM recibos error:' || error, SQLERRM);
         RETURN 101902;   -- Recibo no encontrado en la tabla
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'F_INSCTACOAS = ' || pnrecibo, vpasexec,
                     'OTHERS FROM recibos error:' || error, SQLERRM);
         RETURN 102367;   -- Error al leer de la tabla RECIBOS
   END;

   vpasexec := 2;
   v_cmultimon := NVL(pac_parametros.f_parempresa_n(NVL(pcempres, xcempres), 'MULTIMONEDA'), 0);
   v_cmoncontab := pac_parametros.f_parempresa_n(NVL(pcempres, xcempres), 'MONEDACONTAB');

   IF (xctipcoa = 1
       OR xctipcoa = 8)
      AND xcestaux <> 2 THEN   --Bug 23183-XVM-08/11/2012.Añadimos condición cestaux
      -- Se trata de un coaseguro de recibo unico
      IF error = 0 THEN
         -- Obtenemos los importes totales cedidos del recibo
         BEGIN
            IF xctipcoa = 1 THEN
               vpasexec := 3;

               --BUG 0025357: DCT: 21/12/2012: INICIO: LCOL_T020-LCOL-COA Nuevos conceptos Cuenta Coaseguro. Se añade NVL(icedcbr, 0)
               -- coaseguro cedido necesitamos los importes de la parte cedida
               BEGIN
                  select  (SUM(DECODE(CCONCEP, 50, ICONCEP, 0)) + SUM(DECODE(CCONCEP, 51, ICONCEP, 0))) IT2PRI,
                          (SUM(DECODE(CCONCEP, 52, ICONCEP, 0)) + SUM(DECODE(CCONCEP, 53, ICONCEP, 0))) IT2CON,
                          (SUM(DECODE(cconcep, 50, iconcep, 0)) + SUM(DECODE(cconcep, 51, iconcep, 0))
                                        + SUM(DECODE(cconcep, 52, iconcep, 0)) + SUM(DECODE(cconcep, 53, iconcep, 0))
                                        + SUM(DECODE(cconcep, 54, iconcep, 0)) + SUM(DECODE(cconcep, 55, iconcep, 0))
                                        + SUM(DECODE(cconcep, 56, iconcep, 0)) + SUM(DECODE(cconcep, 57, iconcep, 0))
                                        + SUM(DECODE(CCONCEP, 58, ICONCEP, 0)) + SUM(DECODE(CCONCEP, 64, ICONCEP, 0))
                                        - SUM(DECODE(CCONCEP, 63, ICONCEP, 0))) IT2TOTR,
                          SUM(DECODE(cconcep, 61, iconcep, 0)) Icedcbr
                  into XITPRI, XITCON, XITTOTR, xicombru
                  from DETMOVRECIBO_PARCIAL D
                  where D.NRECIBO = pnrecibo
                  and norden = (select max(norden) from DETMOVRECIBO_PARCIAL dmr
                               where dmr.nrecibo=d.nrecibo
                               and dmr.nrecibo=d.nrecibo);

					IF xitpri IS NULL OR xitcon IS NULL OR xittotr IS NULL OR xicombru IS NULL THEN
						SELECT NVL(it2pri, 0), NVL(it2con, 0), NVL(it2totr, 0), NVL(icedcbr, 0)
						  INTO xitpri, xitcon, xittotr, xicombru
						  FROM vdetrecibos
						 WHERE nrecibo = pnrecibo;
					END IF;
               EXCEPTION
				  WHEN NO_DATA_FOUND THEN
					SELECT NVL(it2pri, 0), NVL(it2con, 0), NVL(it2totr, 0), NVL(icedcbr, 0)
                    -- SE AÑADE LA COMISIÓN BRUTA CEDIDA
                    -- Se añade la retencion por IVA sobre comision cedida
						INTO   xitpri, xitcon, xittotr, xicombru
                    FROM vdetrecibos
                   WHERE nrecibo = pnrecibo;
                  WHEN OTHERS THEN
                     p_tab_error(f_sysdate, f_user, 'f_insctacoas_parcial = ' || pnrecibo, vpasexec,
                                 'OTHERS FROM vdetrecibos error:' || error, SQLERRM);
               END;

               --BUG 0025357: DCT: 21/12/2012: FIN: LCOL_T020-LCOL-COA Nuevos conceptos Cuenta Coaseguro. Se añade NVL(icedcbr, 0)

               -- Buscamos si es un concepto del Debe o del Haber
               -- 27879 KBR. 17/10/2013 No tomamos en cuenta el estado del recibo, solo el tipo de recibo
               IF xtiprec != 9 THEN
                  xsignoprima := 1;   -- Debe
                  xsignocomis := 2;   -- Haber
               ELSE
                  xsignoprima := 2;   --Haber
                  xsignocomis := 1;   -- Debe
               END IF;
            -- 27879 KBR. 17/10/2013
            ELSE
               vpasexec := 4;

               BEGIN
                 select  (SUM(DECODE(CCONCEP, 50, ICONCEP, 0)) + SUM(DECODE(CCONCEP, 51, ICONCEP, 0))) IT2PRI,
                          (SUM(DECODE(CCONCEP, 52, ICONCEP, 0)) + SUM(DECODE(CCONCEP, 53, ICONCEP, 0))) IT2CON,
                          (SUM(DECODE(cconcep, 50, iconcep, 0)) + SUM(DECODE(cconcep, 51, iconcep, 0))
                                        + SUM(DECODE(cconcep, 52, iconcep, 0)) + SUM(DECODE(cconcep, 53, iconcep, 0))
                                        + SUM(DECODE(cconcep, 54, iconcep, 0)) + SUM(DECODE(cconcep, 55, iconcep, 0))
                                        + SUM(DECODE(cconcep, 56, iconcep, 0)) + SUM(DECODE(cconcep, 57, iconcep, 0))
                                        + SUM(DECODE(CCONCEP, 58, ICONCEP, 0)) + SUM(DECODE(CCONCEP, 64, ICONCEP, 0))
                                        - SUM(DECODE(CCONCEP, 63, ICONCEP, 0))) IT2TOTR,
                          SUM(DECODE(cconcep, 61, iconcep, 0)) Icedcbr
                  into XITPRI, XITCON, XITTOTR, xicombru
                  from DETMOVRECIBO_PARCIAL D
                  where D.NRECIBO = pnrecibo
                   and norden = (select max(norden) from DETMOVRECIBO_PARCIAL dmr
                               where dmr.nrecibo=d.nrecibo
                               and dmr.nrecibo=d.nrecibo);
					IF xitpri IS NULL OR xitcon IS NULL OR xittotr IS NULL OR xicombru IS NULL THEN
						SELECT NVL(it2pri, 0), NVL(it2con, 0), NVL(it2totr, 0), NVL(icedcbr, 0)
						  INTO xitpri, xitcon, xittotr, xicombru
						  FROM vdetrecibos
						 WHERE nrecibo = pnrecibo;
					END IF;
               EXCEPTION
				  WHEN NO_DATA_FOUND THEN
					SELECT NVL(it2pri, 0), NVL(it2con, 0), NVL(it2totr, 0), NVL(icedcbr, 0)
                    -- SE AÑADE LA COMISIÓN BRUTA CEDIDA
                    -- Se añade la retencion por IVA sobre comision cedida
						INTO   xitpri, xitcon, xittotr, xicombru
                    FROM vdetrecibos
                   WHERE nrecibo = pnrecibo;
                  WHEN OTHERS THEN
                     p_tab_error(f_sysdate, f_user, 'f_insctacoas_parcial = ' || pnrecibo, vpasexec,
                                 'OTHERS FROM vdetrecibos error:' || error, SQLERRM);
               END;

               vpasexec := 5;

               -- Buscamos el signo
               -- 27879 KBR. 06/11/2013 Ajustes en signos de cta coaseguro
               --9: Extornos
               IF xtiprec = 9 THEN
                  xsignoprima := 1;
                  xsignocomis := 2;
               ELSE
                  -- gastos honorarios retorno (13: old=Anulacion recobro new=Retorno)
                  IF xtiprec = 13 THEN
                     xsignoprima := 2;
                  -- gastos honorarios (15: old=Nuestra remesa new=Recobro del retorno)
                  ELSIF xtiprec = 15 THEN
                     xsignoprima := 1;
                  ELSE
                     xsignoprima := 2;
                  END IF;

                  xsignocomis := 1;
               END IF;
            -- 27879 KBR. 17/10/2013
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               p_tab_error(f_sysdate, f_user, 'f_insctacoas_parcial = ' || pnrecibo, vpasexec,
                           'NO_DATA_FOUND 103936', SQLERRM);
               RETURN 103936;   -- Registro no encontrado en VDETRECIBOS
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'f_insctacoas_parcial = ' || pnrecibo, vpasexec,
                           'NO_DATA_FOUND 103920', SQLERRM);
               RETURN 103920;   -- Error al leer en la tabla VDETRECIBOS
         END;

         vpasexec := 6;
         VCDEBHAB := xsignoprima;
		 --p_control_error('JAAB', 'INSCTACOAS_PARCIAL', 'XITTOTR: ' || XITTOTR);

         OPEN cur_compania(xsseguro, xncuacoa);

         FETCH cur_compania
          INTO regcom;

         WHILE cur_compania%FOUND LOOP
            BEGIN
               xpcescoa := regcom.pcescoa;
               -- ***** Prima (total del recibo) *****
               -- Buscamos el siguiente numero de secuencia
               vpasexec := 7;

               BEGIN
                  SELECT smovcoa.NEXTVAL
                    INTO xsmovcoa
                    FROM DUAL;
               EXCEPTION
                  WHEN OTHERS THEN
                     p_tab_error(f_sysdate, f_user, 'f_insctacoas_parcial = ' || pnrecibo, vpasexec,
                                 'OTHERS xsmovcoa 105575', SQLERRM);
                     RETURN 105575;
               -- Error al leer la secuencia (smovcoa de la Bds
               END;

               --BUG 0025357: DCT: 21/12/2012: INICIO: LCOL_T020-LCOL-COA Nuevos conceptos Cuenta Coaseguro. Añadir IF xtiprec IN(13, 15) THEN  xtipimp := 8
               IF xtiprec IN(13, 15) THEN
                  xtipimp := 8;   -- nou vf:150 Gastos honorarios
               ELSE
                  xtipimp := 1;
               END IF;

               --BUG 0025357: DCT: 21/12/2012: FIN: LCOL_T020-LCOL-COA Nuevos conceptos Cuenta Coaseguro. Añadir IF xtiprec IN(13, 15) THEN  xtipimp := 8
               IF xctipcoa = 1 THEN
                  ximporte := xittotr *(regcom.pcesion / 100);
               ELSE
                  ximporte := xittotr;
               END IF;

               vpasexec := 8;

-- Bug 0023183 - DCG - 14/08/2012 - LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
               BEGIN
                  SELECT cmoneda
                    INTO xcmoneda
                    FROM seguros
                   WHERE sseguro = xsseguro;
               EXCEPTION
                  WHEN OTHERS THEN
                     p_tab_error(f_sysdate, f_user, 'f_insctacoas_parcial = ' || pnrecibo, vpasexec,
                                 'NO_DATA_FOUND Moneda', SQLERRM);
               END;

               v_fcambio := pfmovimi;

               IF v_cmultimon = 1 THEN
                  vpasexec := 81;
                  error := pac_oper_monedas.f_datos_contraval(xsseguro, NULL, NULL, v_fcambio,
                                                              3, v_itasa, v_fcambio);

                  IF error <> 0 THEN
                     p_tab_error(f_sysdate, f_user, 'f_insctacoas_parcial = ' || xsseguro, vpasexec,
                                 'f_datos_contraval:' || error, SQLERRM);
                     RETURN error;
                  END IF;

                  v_importe_mon := f_round(NVL(ximporte, 0) * v_itasa, v_cmoncontab);
               END IF;

-- Fin Bug 0023183
				SELECT MAX(norden)
				  INTO VNORDEN
				  FROM detmovrecibo_parcial dmr
				 WHERE dmr.nrecibo = pnrecibo;

				IF NVL(VNORDEN, 0) = 0 THEN
					VNORDEN := 1;
				END IF;

               IF ximporte != 0 THEN
                  XIMPORTE := ROUND(XIMPORTE, 0);
                  BEGIN
                     INSERT INTO ctacoaseguro
                                 (smovcoa, ccompani, cimport, ctipcoa, cmovimi,
                                  imovimi, fmovimi, fcontab,
                                  cdebhab,
                                  fliqcia, pcescoa, nrecibo, smovrec, sseguro,
                                  imovimi_moncon, fcambio, cempres,
                                  cmoneda, cestado, ctipmov, sproduc, ccompapr, fcierre,NORDEN)
                          VALUES (xsmovcoa, regcom.ccompan, xtipimp, xctipcoa, xtiprec,
                                  ximporte, pfmovimi, NULL,
                                  DECODE
                                     (pcestrec,   -- 16/07/2014   EDA  Bug 0032085/179140 Cuando el recibo se anula cambia el signo origen
                                      2, DECODE(xsignoprima, 1, 2, 2, 1),
                                      xsignoprima),
                                  NULL, xpcescoa, pnrecibo, psmovrec, xsseguro,
                                  v_importe_mon, v_fcambio, NVL(pcempres, xcempres),
                                  xcmoneda, 1, 0, xsproduc, xccompapr, NULL, VNORDEN);
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_tab_error(f_sysdate, f_user, 'f_insctacoas_parcial = ' || pnrecibo,
                                    vpasexec, 'INSERT INTO ctacoaseguro', SQLERRM);
                  END;
                    VIMOVIMI := XIMPORTE;
               END IF;

               --BUG 0025357: DCT: 21/12/2012: INICIO: LCOL_T020-LCOL-COA Nuevos conceptos Cuenta Coaseguro.
               IF xtiprec NOT IN(13, 15) THEN
                  -- Buscamos el siguiente numero de secuencia
                  vpasexec := 9;

                  BEGIN
                     SELECT smovcoa.NEXTVAL
                       INTO xsmovcoa
                       FROM DUAL;
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_tab_error(f_sysdate, f_user, 'f_insctacoas_parcial = ' || pnrecibo,
                                    vpasexec, 'OTHERS xsmovcoa 105575', SQLERRM);
                        RETURN 105575;
                  -- Error al leer la secuencia (smovcoa de la Bds
                  END;

                  xtipimp := 2;
                  vpasexec := 10;

                  IF xctipcoa = 1 THEN
                     --BUG 0025357: DCT: 21/12/2012: INICIO: LCOL_T020-LCOL-COA Nuevos conceptos Cuenta Coaseguro.
                     IF NVL(regcom.pcomcoa, 0) <> 0 THEN
                        ximporte := xitpri *(regcom.pcesion / 100) *(regcom.pcomcoa / 100);
                     ELSE
                        ximporte := xicombru *(regcom.pcesion / 100);
                     END IF;
                  --BUG 0025357: DCT: 21/12/2012: FIN: LCOL_T020-LCOL-COA Nuevos conceptos Cuenta Coaseguro.
                  ELSE
                     BEGIN
                        SELECT pgasadm
                          INTO v_pgasadm
                          FROM companias_gastos
                         WHERE cempres = NVL(pcempres, xcempres)
                           AND sproduc = 0
                           AND finigac > pfmovimi
                           AND(ffingac IS NULL
                               OR ffingac < pfmovimi);

                        ximporte := xitpri *(v_pgasadm / 100);
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           p_tab_error(f_sysdate, f_user, 'f_insctacoas_parcial = ' || pnrecibo,
                                       vpasexec, 'NO_DATA_FOUND  FROM companias_gastos',
                                       SQLERRM);

                           -- INI RLLF BUG-32591 28/05/2015 no inserta el coaseguro en ctacoaseguro y no se envia a sap
                           --IF regcom.pcomcoa IS NULL THEN
                           IF NVL(regcom.pcomcoa,0) = 0 THEN
                           -- FIN RLLF BUG-32591 28/05/2015 no inserta el coaseguro en ctacoaseguro y no se envia a sap
                              ximporte := xicombru;
                           ELSE
                              ximporte := xitpri *(regcom.pcomcoa / 100);
                           END IF;
                     END;
                  END IF;

                  BEGIN
                     SELECT cmoneda
                       INTO xcmoneda
                       FROM seguros
                      WHERE sseguro = xsseguro;
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_tab_error(f_sysdate, f_user, 'f_insctacoas_parcial = ' || pnrecibo,
                                    vpasexec, 'NO_DATA_FOUND  Moneda', SQLERRM);
                  END;

                  vpasexec := 11;
                  v_fcambio := pfmovimi;

                  IF v_cmultimon = 1 THEN
                     vpasexec := 82;
                     error := pac_oper_monedas.f_datos_contraval(xsseguro, NULL, NULL,
                                                                 v_fcambio, 3, v_itasa,
                                                                 v_fcambio);

                     IF error <> 0 THEN
                        p_tab_error(f_sysdate, f_user, 'f_insctacoas_parcial = ' || xsseguro,
                                    vpasexec, 'f_datos_contraval:' || error, SQLERRM);
                        RETURN error;
                     END IF;

                     v_importe_mon := f_round(NVL(ximporte, 0) * v_itasa, v_cmoncontab);
                  END IF;

-- Fin Bug 0023183
                  IF ximporte != 0 THEN
                     XIMPORTE := ROUND(XIMPORTE, 0);
                     BEGIN
                        INSERT INTO ctacoaseguro
                                    (smovcoa, ccompani, cimport, ctipcoa, cmovimi,
                                     imovimi, fmovimi, fcontab,
                                     cdebhab,
                                     fliqcia, pcescoa, nrecibo, smovrec, sseguro,
                                     imovimi_moncon, fcambio, cempres,
                                     cmoneda, cestado, ctipmov, sproduc, ccompapr, fcierre,NORDEN)
                             VALUES (xsmovcoa, regcom.ccompan, xtipimp, xctipcoa, xtiprec,
                                     ximporte, pfmovimi, NULL,
                                     DECODE
                                        (pcestrec,   -- 16/07/2014   EDA  Bug 0032085/179140 Cuando el recibo se anula cambia el signo origen
                                         2, DECODE(xsignocomis, 1, 2, 2, 1),
                                         xsignocomis),
                                     NULL, xpcescoa, pnrecibo, psmovrec, xsseguro,
                                     v_importe_mon, v_fcambio, NVL(pcempres, xcempres),
                                     xcmoneda, 1, 0, xsproduc, xccompapr, NULL, VNORDEN);
                     EXCEPTION
                        WHEN OTHERS THEN
                           p_tab_error(f_sysdate, f_user, 'f_insctacoas_parcial = ' || pnrecibo,
                                       vpasexec, 'INSERT INTO ctacoaseguro', SQLERRM);
                     END;
                  END IF;

                  vpasexec := 12;

                  -- ****** Comision consorcio *****
                  -- Buscamos el siguiente numero de secuencia
                  BEGIN
                     SELECT smovcoa.NEXTVAL
                       INTO xsmovcoa
                       FROM DUAL;
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_tab_error(f_sysdate, f_user, 'f_insctacoas_parcial = ' || pnrecibo,
                                    vpasexec, 'OTHERS xsmovcoa 105575', SQLERRM);
                        RETURN 105575;
                  -- Error al leer la secuencia (smovcoa de la Bds
                  END;

--INICIO JAAB 18/04/2018 QT 2057
--Los cambios hechos aquí deben replicarse en f_insctacoas y pac_coa.F_SET_REMESA_CTACOA y pac_coa.F_insctacoas_parcial

                    IF pcempres = 24 THEN --confianza
                        vpasexec := 500;
                        vccompani := regcom.ccompan;

                        -- Retefuente
                        BEGIN
                            SELECT DECODE (r.cregfiscal, 6, 0, 8, 0, DECODE (p.ctipper, 1, 1, 2))
                              INTO vvalor
                              FROM companias cp, per_personas p,(SELECT sperson, cregfiscal
                                                                   FROM per_regimenfiscal
                                                                  WHERE (sperson, fefecto) IN (SELECT   sperson, MAX (fefecto)
                                                                                                 FROM per_regimenfiscal
                                                                                             GROUP BY sperson)) r
                             WHERE cp.ccompani = Vccompani
                               AND p.sperson = cp.sperson
                               AND p.sperson = r.sperson(+);

                            SELECT sgt_sesiones.NEXTVAL
                              INTO xxsesion
                              FROM DUAL;

                            SELECT vtramo (xxsesion, 800064, vvalor)
                              INTO VPORRETFTEGASADM
                              FROM DUAL;

                        EXCEPTION
                            WHEN OTHERS THEN
                                p_tab_error (f_sysdate, f_user, v_obj, vpasexec, v_par, 107885 || ' - ' || SQLCODE || ' - ' || SQLERRM);
                        END;


                        vpasexec := 501;

                        VPORGASTO   := NVL(pac_parametros.f_parempresa_n(pcempres, 'PORGAST_ADMCOA'), 0);--Porcentaje Gastos de Administración
                        VPORRETEIVA := NVL(pac_parametros.f_parempresa_n(pcempres, 'PORRETIVA_ADMCOA'), 0);--Porcentaje RETEIVA Gastos de Administración

                        BEGIN--Porcentaje IVA
                            SELECT ptipiva
                              INTO vptipiva
                              FROM tipoiva t, companias co
                             WHERE co.ccompani = Vccompani
                               AND co.ctipiva = t.ctipiva
                               AND t.ffinvig IS NULL;
                        EXCEPTION
                            WHEN NO_DATA_FOUND THEN
                                Vptipiva := 0;
                            WHEN OTHERS THEN
                                p_tab_error(f_sysdate, f_user, v_obj, vpasexec, V_PAR,  107885 || ' ' || NVL(SQLERRM, SQLCODE || ' ' || SQLERRM));
                        END;

                        vpasexec := 502;
                        --ReteICA
                        VPORRETEICA := PAC_IMPUESTOS_CONF.F_RETEICA_INDICADOR_COA (vccompani);

                        BEGIN
                            SELECT cmoneda
                              INTO xcmoneda
                              FROM seguros
                             WHERE sseguro = xsseguro;
                        EXCEPTION
                            WHEN OTHERS THEN
                                p_tab_error(f_sysdate, f_user, 'F_INSCTACOAS = ' || pnrecibo, vpasexec, 'NO_DATA_FOUND Moneda', SQLERRM);
                        END;

                        IF v_cmultimon = 1 THEN
                            vpasexec := 503;
                            v_fcambio := pfmovimi;
                            error := pac_oper_monedas.f_datos_contraval(xsseguro, NULL, NULL, v_fcambio, 3, v_itasa, v_fcambio);

                            IF error <> 0 THEN
                                p_tab_error(f_sysdate, f_user, 'F_INSCTACOAS = ' || xsseguro, vpasexec, 'f_datos_contraval:' || error, SQLERRM);
                                RETURN error;
                            END IF;
                        END IF;

                        --Se calculan los conceptos automàticos
                        IF Vcdebhab = 1 THEN
                            Vcdebhab := 2;
                        ELSIF Vcdebhab = 2 THEN
                            Vcdebhab := 1;
                        END IF;

                        vpasexec := 504;
                        VCIMPORT := 4; --Gastos de Administración
                        SELECT smovcoa.NEXTVAL
                          INTO xsmovcoa
                          FROM DUAL;

                        VGASADM := ROUND(VIMOVIMI * VPORGASTO / 100, 0);
                        v_importe_mon := f_round(NVL(VGASADM, 0) * v_itasa, v_cmoncontab);

                        vpasexec := 505;
                        BEGIN
                            INSERT INTO ctacoaseguro
                                    (smovcoa, ccompani, cimport, ctipcoa, cmovimi, imovimi, fmovimi, fcontab, cdebhab, fliqcia,
                                    pcescoa, nrecibo, smovrec, sseguro, imovimi_moncon, fcambio,cempres, cmoneda, cestado, ctipmov,
                                    sproduc, ccompapr, fcierre, norden)
                            VALUES (xsmovcoa, Vccompani, VCIMPORT, xctipcoa, xtiprec, VGASADM, pfmovimi, NULL, VCDEBHAB, NULL,
                                    xpcescoa, pnrecibo, psmovrec, xsseguro, v_importe_mon, v_fcambio, NVL(pcempres, xcempres), xcmoneda, 1, 0,
                                    xsproduc, xccompapr, NULL, VNORDEN);
                        EXCEPTION
                            WHEN OTHERS THEN
                                p_tab_error(f_sysdate, f_user, 'F_INSCTACOAS = ' || pnrecibo, vpasexec, 'INSERT INTO ctacoaseguro', SQLERRM);
                        END;

                        vpasexec := 506;
                        VCIMPORT := 13; --IVA sobre gastos de Administración
                        SELECT smovcoa.NEXTVAL
                          INTO xsmovcoa
                          FROM DUAL;

                        VIVAGASADM := ROUND(VGASADM * vptipiva / 100, 0);
                        v_importe_mon := f_round(NVL(VIVAGASADM, 0) * v_itasa, v_cmoncontab);

                        vpasexec := 507;
                        BEGIN
                            INSERT INTO ctacoaseguro
                                    (smovcoa, ccompani, cimport, ctipcoa, cmovimi, imovimi, fmovimi, fcontab, cdebhab, fliqcia,
                                    pcescoa, nrecibo, smovrec, sseguro, imovimi_moncon, fcambio,cempres, cmoneda, cestado, ctipmov,
                                    sproduc, ccompapr, fcierre, norden)
                            VALUES (xsmovcoa, Vccompani, VCIMPORT, xctipcoa, xtiprec, VIVAGASADM, pfmovimi, NULL, VCDEBHAB, NULL,
                                    xpcescoa, pnrecibo, psmovrec, xsseguro, v_importe_mon, v_fcambio, NVL(pcempres, xcempres), xcmoneda, 1, 0,
                                    xsproduc, xccompapr, NULL, VNORDEN);
                        EXCEPTION
                            WHEN OTHERS THEN
                                p_tab_error(f_sysdate, f_user, 'F_INSCTACOAS = ' || pnrecibo, vpasexec, 'INSERT INTO ctacoaseguro', SQLERRM);
                        END;

                        --Cambia el signo para las retenciones
                        IF Vcdebhab = 1 THEN
                            Vcdebhab := 2;
                        ELSIF Vcdebhab = 2 THEN
                            Vcdebhab := 1;
                        END IF;

                        vpasexec := 508;
                        VCIMPORT := 38; --Retención de IVA sobre gastos de Administración
                        SELECT smovcoa.NEXTVAL
                          INTO xsmovcoa
                          FROM DUAL;

                        VRETIVAGASADM := ROUND(VIVAGASADM * VPORRETEIVA / 100, 0);
                        v_importe_mon := f_round(NVL(VRETIVAGASADM, 0) * v_itasa, v_cmoncontab);

                        vpasexec := 509;
                        BEGIN
                            INSERT INTO ctacoaseguro
                                    (smovcoa, ccompani, cimport, ctipcoa, cmovimi, imovimi, fmovimi, fcontab, cdebhab, fliqcia,
                                    pcescoa, nrecibo, smovrec, sseguro, imovimi_moncon, fcambio,cempres, cmoneda, cestado, ctipmov,
                                    sproduc, ccompapr, fcierre, norden)
                            VALUES (xsmovcoa, Vccompani, VCIMPORT, xctipcoa, xtiprec, VRETIVAGASADM, pfmovimi, NULL, VCDEBHAB, NULL,
                                    xpcescoa, pnrecibo, psmovrec, xsseguro, v_importe_mon, v_fcambio, NVL(pcempres, xcempres), xcmoneda, 1, 0,
                                    xsproduc, xccompapr, NULL, VNORDEN);
                        EXCEPTION
                            WHEN OTHERS THEN
                                p_tab_error(f_sysdate, f_user, 'F_INSCTACOAS = ' || pnrecibo, vpasexec, 'INSERT INTO ctacoaseguro', SQLERRM);
                        END;

                        vpasexec := 510;
                        VCIMPORT := 39; --Retención en la fuente sobre gastos de Administración
                        SELECT smovcoa.NEXTVAL
                          INTO xsmovcoa
                          FROM DUAL;

                        VRETFTEGASADM := ROUND(VGASADM * VPORRETFTEGASADM / 100, 0);
                        v_importe_mon := f_round(NVL(VRETFTEGASADM, 0) * v_itasa, v_cmoncontab);

                        vpasexec := 511;
                        BEGIN
                            INSERT INTO ctacoaseguro
                                    (smovcoa, ccompani, cimport, ctipcoa, cmovimi, imovimi, fmovimi, fcontab, cdebhab, fliqcia,
                                    pcescoa, nrecibo, smovrec, sseguro, imovimi_moncon, fcambio,cempres, cmoneda, cestado, ctipmov,
                                    sproduc, ccompapr, fcierre, norden)
                            VALUES (xsmovcoa, Vccompani, VCIMPORT, xctipcoa, xtiprec, VRETFTEGASADM, pfmovimi, NULL, VCDEBHAB, NULL,
                                    xpcescoa, pnrecibo, psmovrec, xsseguro, v_importe_mon, v_fcambio, NVL(pcempres, xcempres), xcmoneda, 1, 0,
                                    xsproduc, xccompapr, NULL, VNORDEN);
                        EXCEPTION
                            WHEN OTHERS THEN
                                p_tab_error(f_sysdate, f_user, 'F_INSCTACOAS = ' || pnrecibo, vpasexec, 'INSERT INTO ctacoaseguro', SQLERRM);
                        END;

                        vpasexec := 512;
                        VCIMPORT := 42;	--Retención de ICA sobre gastos de Administración
                        SELECT smovcoa.NEXTVAL
                          INTO xsmovcoa
                          FROM DUAL;

                        VRETICAGASADM := ROUND(VGASADM * VPORRETEICA / 1000, 0);
                        v_importe_mon := f_round(NVL(VRETICAGASADM, 0) * v_itasa, v_cmoncontab);

                        vpasexec := 513;
                        BEGIN
                            INSERT INTO ctacoaseguro
                                    (smovcoa, ccompani, cimport, ctipcoa, cmovimi, imovimi, fmovimi, fcontab, cdebhab, fliqcia,
                                    pcescoa, nrecibo, smovrec, sseguro, imovimi_moncon, fcambio,cempres, cmoneda, cestado, ctipmov,
                                    sproduc, ccompapr, fcierre, norden)
                            VALUES (xsmovcoa, Vccompani, VCIMPORT, xctipcoa, xtiprec, VRETICAGASADM, pfmovimi, NULL, VCDEBHAB, NULL,
                                    xpcescoa, pnrecibo, psmovrec, xsseguro, v_importe_mon, v_fcambio, NVL(pcempres, xcempres), xcmoneda, 1, 0,
                                    xsproduc, xccompapr, NULL, VNORDEN);
                        EXCEPTION
                            WHEN OTHERS THEN
                                p_tab_error(f_sysdate, f_user, 'F_INSCTACOAS = ' || pnrecibo, vpasexec, 'INSERT INTO ctacoaseguro', SQLERRM);
                        END;

                    ELSE
--FIN JAAB 18/04/2018 QT 2057
--DE AQUÍ EN ADELANTE ES LA VERSIÓN ORIGINAL DE ESTA FUNCIÓN

                          xtipimp := 3;
                          vpasexec := 13;

                          IF xctipcoa = 1 THEN
                             ximporte := xitcon *(regcom.pcesion / 100) *(regcom.pcomcon / 100);
                          ELSE
                             ximporte := xitcon *(regcom.pcomcon / 100);
                          END IF;

                        -- Bug 0023183 - DCG - 14/08/2012 - LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
                          BEGIN
                             SELECT cmoneda
                               INTO xcmoneda
                               FROM seguros
                              WHERE sseguro = xsseguro;
                          EXCEPTION
                             WHEN OTHERS THEN
                                p_tab_error(f_sysdate, f_user, 'f_insctacoas_parcial = ' || pnrecibo,
                                            vpasexec, 'NO_DATA_FOUND  Moneda', SQLERRM);
                          END;

                          v_fcambio := pfmovimi;

                          IF v_cmultimon = 1 THEN
                             vpasexec := 81;
                             error := pac_oper_monedas.f_datos_contraval(xsseguro, NULL, NULL,
                                                                         v_fcambio, 3, v_itasa,
                                                                         v_fcambio);

                             IF error <> 0 THEN
                                p_tab_error(f_sysdate, f_user, 'f_insctacoas_parcial = ' || xsseguro,
                                            vpasexec, 'f_datos_contraval:' || error, SQLERRM);
                                RETURN error;
                             END IF;

                             v_importe_mon := f_round(NVL(ximporte, 0) * v_itasa, v_cmoncontab);
                          END IF;

                            -- Fin Bug 0023183
                          IF ximporte != 0 THEN
                             BEGIN
                                INSERT INTO ctacoaseguro
                                            (smovcoa, ccompani, cimport, ctipcoa, cmovimi,
                                             imovimi, fmovimi, fcontab,
                                             cdebhab,
                                             fliqcia, pcescoa, nrecibo, smovrec, sseguro,
                                             imovimi_moncon, fcambio, cempres,
                                             cmoneda, cestado, ctipmov, sproduc, ccompapr, fcierre,NORDEN)
                                     VALUES (xsmovcoa, regcom.ccompan, xtipimp, xctipcoa, xtiprec,
                                             ximporte, pfmovimi, NULL,
                                             DECODE
                                                (pcestrec,   -- 16/07/2014   EDA  Bug 0032085/179140 Cuando el recibo se anula cambia el signo origen
                                                 2, DECODE(xsignocomis, 1, 2, 2, 1),
                                                 xsignocomis),
                                             NULL, xpcescoa, pnrecibo, psmovrec, xsseguro,
                                             v_importe_mon, v_fcambio, NVL(pcempres, xcempres),
                                             xcmoneda, 1, 0, xsproduc, xccompapr, NULL,(select max(norden)
                                                                                     from DETMOVRECIBO_PARCIAL dmr
                                                                                     where dmr.nrecibo=pnrecibo));
                             EXCEPTION
                                WHEN OTHERS THEN
                                   p_tab_error(f_sysdate, f_user, 'f_insctacoas_parcial = ' || pnrecibo,
                                               vpasexec, 'INSERT INTO ctacoaseguro', SQLERRM);
                             END;
                          END IF;

                          vpasexec := 14;

                          -- ****** Comision gastos *******
                          -- Buscamos el siguiente numero de secuencia
                          BEGIN
                             SELECT smovcoa.NEXTVAL
                               INTO xsmovcoa
                               FROM DUAL;
                          EXCEPTION
                             WHEN OTHERS THEN
                                p_tab_error(f_sysdate, f_user, 'f_insctacoas_parcial = ' || pnrecibo,
                                            vpasexec, 'OTHERS xsmovcoa 105575', SQLERRM);
                                RETURN 105575;
                          -- Error al leer la secuencia (smovcoa de la Bds
                          END;

                          xtipimp := 4;

                          IF xctipcoa = 1 THEN
                             ximporte := xittotr *(regcom.pcesion / 100) *(regcom.pcomgas / 100);
                          ELSE
                             ximporte := xittotr *(regcom.pcomgas / 100);
                          END IF;

                            -- 0027260/0149814- JSV - 24/07/2013 - FIN
                          vpasexec := 15;
                        -- Bug 0023183 - DCG - 14/08/2012 - LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
                          v_fcambio := pfmovimi;

                          IF v_cmultimon = 1 THEN
                             vpasexec := 81;
                             error := pac_oper_monedas.f_datos_contraval(xsseguro, NULL, NULL,
                                                                         v_fcambio, 3, v_itasa,
                                                                         v_fcambio);

                             IF error <> 0 THEN
                                p_tab_error(f_sysdate, f_user, 'f_insctacoas_parcial = ' || xsseguro,
                                            vpasexec, 'f_datos_contraval:' || error, SQLERRM);
                                RETURN error;
                             END IF;

                             v_importe_mon := f_round(NVL(ximporte, 0) * v_itasa, v_cmoncontab);
                          END IF;

                            -- Fin Bug 0023183
                          BEGIN
                             SELECT cmoneda
                               INTO xcmoneda
                               FROM seguros
                              WHERE sseguro = xsseguro;
                          EXCEPTION
                             WHEN OTHERS THEN
                                p_tab_error(f_sysdate, f_user, 'f_insctacoas_parcial = ' || pnrecibo,
                                            vpasexec, 'NO_DATA_FOUND  Moneda', SQLERRM);
                          END;

                          IF ximporte != 0 THEN
                             BEGIN
                                INSERT INTO ctacoaseguro
                                            (smovcoa, ccompani, cimport, ctipcoa, cmovimi,
                                             imovimi, fmovimi, fcontab,
                                             cdebhab,
                                             fliqcia, pcescoa, nrecibo, smovrec, sseguro,
                                             imovimi_moncon, fcambio, cempres,
                                             cmoneda, cestado, ctipmov, sproduc, ccompapr,   -- Bug 0023183 - DCG - 14/08/2012 - LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
                                                                                          fcierre,NORDEN)   -- BUG 0025357/0138513 - FAL - 19/02/2013
                                     VALUES (xsmovcoa, regcom.ccompan, xtipimp, xctipcoa, xtiprec,
                                             ximporte, pfmovimi, NULL,
                                             DECODE
                                                (pcestrec,   -- 16/07/2014   EDA  Bug 0032085/179140 Cuando el recibo se anula cambia el signo origen
                                                 2, DECODE(xsignocomis, 1, 2, 2, 1),
                                                 xsignocomis),
                                             NULL, xpcescoa, pnrecibo, psmovrec, xsseguro,
                                             v_importe_mon, v_fcambio, NVL(pcempres, xcempres),
                                             xcmoneda, 1, 0, xsproduc, xccompapr,   -- Bug 0023183 - DCG - 14/08/2012 - LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
                                                                                 NULL,(select max(norden)
                                                                                     from DETMOVRECIBO_PARCIAL dmr
                                                                                     where dmr.nrecibo=pnrecibo));   -- BUG 0025357/0138513 - FAL - 19/02/2013
                             EXCEPTION
                                WHEN OTHERS THEN
                                   p_tab_error(f_sysdate, f_user, 'f_insctacoas_parcial = ' || pnrecibo,
                                               vpasexec, 'INSERT INTO ctacoaseguro', SQLERRM);
                             END;
                          END IF;

                    --HASTA AQUÍ ES LA VERSIÓN ORIGINAL DE ESTA FUNCIÓN
                    END IF;--<> 24 NO CONFIANZA
               END IF;   --IF xtiprec NOT IN(13, 15) THEN
            --BUG 0025357: DCT: 21/12/2012: INICIO: LCOL_T020-LCOL-COA Nuevos conceptos Cuenta Coaseguro.
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  RETURN 105579;   -- registre duplicat en CTACOASEGURO
               WHEN OTHERS THEN
                  RETURN 105578;   -- Error a l' inserir a CTACOASEGURO
            END;

            FETCH cur_compania
             INTO regcom;
         END LOOP;

         -- BUG 21546_108724 - 13/02/2012 - JLTS - Cierre de posibles cursores abiertos.
         IF cur_compania%ISOPEN THEN
            CLOSE cur_compania;
         END IF;

         RETURN 0;
      ELSE
         RETURN error;
      END IF;
   ELSE
      -- Cualquiera de los otros casos. No tenemos que hacer nada
      RETURN 0;
   END IF;

EXCEPTION
  when OTHERS then
         p_tab_error(f_sysdate, f_user, v_obj, vpasexec, v_par,
                     'num_err=' ||' --> Error: ' || SQLERRM);
         RETURN 9999;

END f_insctacoas_parcial; --RAMIRO

END pac_coa;

/

  GRANT EXECUTE ON "AXIS"."PAC_COA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_COA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_COA" TO "PROGRAMADORESCSI";
