CREATE OR REPLACE PACKAGE BODY "PAC_CUADRE_ADM" IS
/******************************************************************************
   NOMBRE:       PAC_CUADRE_ADM
   PROPÓSITO:

   REVISIONES:

   Ver        Fecha        Autor  Descripción
   ---------  ----------  ------  ------------------------------------
     8        11/02/2009   DCT    1.Modificar función f_selec_cuenta
     9        26/02/2009   DCT    1.Cambiar Cursor principal de f_selec_cuenta
                                    y f_select_cuenta_asient. Anadir
                                    nueva procedure PROCESO_BATCH_CIERRE(copia MVIDA)
                                    Quitar : 'AND d.cempres = 1'
                                    Optimizar Select.Utilizamos tablas personas f_LPS_pais
     10       23/03/2009   DCT    1.Crear función f_ccontban
     11       09/03/2009   RSC    1.Unificación de recibos
     12       03/04/2009   SBG    1.Posar alias a la consulta de f_selec_cuenta i f_selec_cuenta_asient
     13       24/04/2009   DCT    1.Modificar f_ccontban
     14       02/07/2009   DCT    1.Modificar función f_lps_pais. Bug 10612
     15       14/07/2009   DCT    1.Contabilidad: Extracción correcta del detalle de las cuentas.
                                    Modificar f_ccontban
     16       09/07/2009   ETM    1.BUG 0010676: CEM - Días de gestión de un recibo
     17       08/07/2009   DCT    1.BUG 0010994: Comptabilitat. Quadre comptes ISI Abril
     18       22/09/2009   NMM    3. 10676: CEM - Días de gestión de un recibo ( canviar paràmetre funció)
     19       09/06/2010   PFA   19. 14942: AGA800 - Comptabilitat: Vida o no Vida
     20       09/09/2010   JMF   20. 0014782: APR708 - Llistat detall de la comptabilitat diaria
     21       23/12/2010   ICV   21. 0017033: CEM800 - Contabilidad - Proteger el cierre para que no se pueda hacer sobre un cálculo acumulado
     22       15/02/2011   APD   22. 0017406: ENSA101 - SAP - Interficie Contabilistica
     23       29/06/2011   ICV   23. 0018917: MSGV003 - Comptabilitat: El detall de la comptabilitat diaria no funciona.
     24       02/05/2012   MDS   24. 0020663: LCOL_F001-Contabilidad: Reportes y Validaciones
     25       02/07/2012   DCG   25. 0022394: AGM003-AGM - Contabilida no cuadra
     26       27/07/2012   DCG   26. 0022855: LCOL_F001-Contabilidad de prestamos
     27       31/10/2012   DCG   27. 0024079: LCOL_F001-Din?mica comptable - Assentaments cancelaci? pr?stecs versus reserva
     28       07/11/2012   DCG   28. 0024622: AGM800-Detalles de la contabilidad
     29       11/01/2013   JGR   29. 0025313: LCOL_F002-Ajuste Selects de Contabilidad Cambio de Ano
     30       28/01/2013   APD   30. 0025558: LCOL_F003-Env?o Contabilidad en Interface de CxP
     31       19/02/2013   RDD   31  0025872: LCOL_F002-Revisi?n Qtrackers contabilidad F2 -- incluir la tabla ctacoaseguro en la contabilización
     32       16/04/2013   DCG   32  0026422: RSA002-Enlace contable segunda entrega
     33       30/04/2013   DCG   33  0026841: Cuentas de Reserva Técnica de Riesgos en Curso no permiten ver el detalle por póliza
     34       17/06/2013   RDD   37  0027351: LCOL_F003-Revisar QT de contabilidad de Autos - Fase 3A
     35       21/10/2013   MMM   35  0028546: LCOL_A005-Mejorar el rendimiento de terminacion por no pago
     36       06/11/2013   CPM   36  0028847: LCOL_F003-Rendimiento de la pantalla de detalle de la contabilidad para cuentas de reaseguro
     37       20/11/2013   DCG   37  0027015: RSA702-Ajustes de caja
     38       22/11/2013   RDD   38  0010181: ERROR DESPLIEGO CUENTAS DE EMISION NO MUESTRA DESGLOSE
     39       18/12/2013   MMM   39  0029391: LCOL_PROD-Contabilidad - 0010526 IAXIS Interfaces Con Fecha Fuera Del Periodo- Funcionalidad
     40       20/12/2013   MMM   40  0029032: LCOLF3BADM-Id. 185 - REPORTE DETALLADO CONTABILIDAD - NOTA 0161388
     41       16/01/2014   MMM   41  0029644: LCOL_F003-0010853: No se observa Amortizacion de Sobrecomisiones en las cuentas correctas
     42       09/03/2015   KJSC  42
     43       25/05/2015   IPH   43  0036026: POSES200 el cierre generado para el mes de abril quedo reportado en mayo
     44       27/11/2017   AAB   44  CONF-403:Se Ingresan cambios para la cabecera de contabilidad.
	 45	      14/06/2019   WAJ   45  IAXIS-4182: Validacion 	de escenarios para generar idpago.	 
******************************************************************************/
--------------------------------------------------------------------------------------------
---  Borra las tablas "cuadre"
--------------------------------------------------------------------------------------------
   PROCEDURE p_cuadre_recibos(
      aaproc IN NUMBER,
      mmproc IN NUMBER,
      empresa IN NUMBER,
      pnummes IN NUMBER DEFAULT 1) IS
   BEGIN
      DELETE FROM cuadre01;

      DELETE FROM cuadre02;

      DELETE FROM cuadre03;

      DELETE FROM cuadre04;

      DELETE FROM cuadre05;

      DELETE FROM cuadre06;

      DELETE FROM cuadre07;

      DELETE FROM cuadre08;

      DELETE FROM cuadre001;

      DELETE FROM cuadre002;

      DELETE FROM cuadre003;

      DELETE FROM cuadre004;

      DELETE FROM cuadre005;

      DELETE FROM cuadre006;

      DELETE FROM cuadre_total01;

      DELETE FROM cuadre_total02;

      DELETE FROM cuadre_total03;

      DELETE FROM cuadre_total04;

      fdesde := TO_DATE('01' || LPAD(TO_CHAR(mmproc), 2, '0') || aaproc, 'ddmmyyyy');
      fhasta := ADD_MONTHS(LAST_DAY(fdesde), pnummes - 1);
      finicial := TO_DATE('0101' || aaproc, 'ddmmyyyy');

--------------------------------------------------------------------------------------------
---  Graba la tabla CUADRE01
--------------------------------------------------------------------------------------------
/* Bug 17179 XPL#17012011
      BEGIN
         p_gracuadre01(aaproc, mmproc, empresa);
      EXCEPTION
         WHEN OTHERS THEN
            raise_application_error(-20001, '(p_gracuadre01) ERROR: ' || SQLERRM);
      END;
*/
--------------------------------------------------------------------------------------------
---  Graba la tabla CUADRE02
--------------------------------------------------------------------------------------------
      BEGIN
         p_gracuadre02(aaproc, mmproc, empresa);
      EXCEPTION
         WHEN OTHERS THEN
            raise_application_error(-20001, '(p_gracuadre02) ERROR: ' || SQLERRM);
      END;

--------------------------------------------------------------------------------------------
---  Graba la tabla CUADRE03
--------------------------------------------------------------------------------------------
--Bug 0024622 - DCG - 02/07/2012 -Ini Se descomenta
/* Bug 17179 XPL#17012011
*/
      BEGIN
         p_gracuadre03(aaproc, mmproc, empresa);
      EXCEPTION
         WHEN OTHERS THEN
            raise_application_error(-20001, '(p_gracuadre03) ERROR: ' || SQLERRM);
      END;

--------------------------------------------------------------------------------------------
---  Graba la tabla CUADRE04
--------------------------------------------------------------------------------------------
      BEGIN
         p_gracuadre04(aaproc, mmproc, empresa);
      EXCEPTION
         WHEN OTHERS THEN
            raise_application_error(-20001, '(p_gracuadre04) ERROR: ' || SQLERRM);
      END;

--------------------------------------------------------------------------------------------
---  Graba la tabla CUADRE05
--------------------------------------------------------------------------------------------
      BEGIN
         p_gracuadre05(aaproc, mmproc, empresa);
      EXCEPTION
         WHEN OTHERS THEN
            raise_application_error(-20001, '(p_gracuadre05) ERROR: ' || SQLERRM);
      END;

--------------------------------------------------------------------------------------------
---  Graba la tabla CUADRE06
--------------------------------------------------------------------------------------------
      BEGIN
         p_gracuadre06(aaproc, mmproc, empresa);
      EXCEPTION
         WHEN OTHERS THEN
            raise_application_error(-20001, '(p_gracuadre06) ERROR: ' || SQLERRM);
      END;

--------------------------------------------------------------------------------------------
---  Graba la tabla CUADRE07
--------------------------------------------------------------------------------------------
      BEGIN
         p_gracuadre07(aaproc, mmproc, empresa);
      EXCEPTION
         WHEN OTHERS THEN
            raise_application_error(-20001, '(p_gracuadre07) ERROR: ' || SQLERRM);
      END;

--------------------------------------------------------------------------------------------
---  Graba la tabla CUADRE08
--------------------------------------------------------------------------------------------
      BEGIN
         p_gracuadre08(aaproc, mmproc, empresa);
      EXCEPTION
         WHEN OTHERS THEN
            raise_application_error(-20001, '(p_gracuadre08) ERROR: ' || SQLERRM);
      END;

--------------------------------------------------------------------------------------------
---  Graba la tabla CUADRE001
--------------------------------------------------------------------------------------------
/* Bug 17179 XPL#17012011
      BEGIN
         p_gracuadre001(aaproc, mmproc, empresa);
      EXCEPTION
         WHEN OTHERS THEN
            raise_application_error(-20001, '(p_gracuadre001) ERROR: ' || SQLERRM);
      END;

*/
--Bug 0024622 - DCG - 02/07/2012 -Ini Se descomenta
--------------------------------------------------------------------------------------------
---  Graba la tabla CUADRE002
--------------------------------------------------------------------------------------------
      BEGIN
         p_gracuadre002(aaproc, mmproc, empresa);
      EXCEPTION
         WHEN OTHERS THEN
            raise_application_error(-20001, '(p_gracuadre002) ERROR: ' || SQLERRM);
      END;

--------------------------------------------------------------------------------------------
---  Graba la tabla CUADRE003
--------------------------------------------------------------------------------------------
      BEGIN
         p_gracuadre003(aaproc, mmproc, empresa);
      EXCEPTION
         WHEN OTHERS THEN
            raise_application_error(-20001, '(p_gracuadre003) ERROR: ' || SQLERRM);
      END;

--------------------------------------------------------------------------------------------
---  Graba la tabla CUADRE004
--------------------------------------------------------------------------------------------
      BEGIN
         p_gracuadre004(aaproc, mmproc, empresa);
      EXCEPTION
         WHEN OTHERS THEN
            raise_application_error(-20001, '(p_gracuadre004) ERROR: ' || SQLERRM);
      END;

--------------------------------------------------------------------------------------------
---  Graba la tabla CUADRE005
--------------------------------------------------------------------------------------------
      BEGIN
         p_gracuadre005(aaproc, mmproc, empresa);
      EXCEPTION
         WHEN OTHERS THEN
            raise_application_error(-20001, '(p_gracuadre005) ERROR: ' || SQLERRM);
      END;

--------------------------------------------------------------------------------------------
---  Graba la tabla CUADRE006
--------------------------------------------------------------------------------------------
      BEGIN
         p_gracuadre006(aaproc, mmproc, empresa);
      EXCEPTION
         WHEN OTHERS THEN
            raise_application_error(-20001, '(p_gracuadre006) ERROR: ' || SQLERRM);
      END;
--------------------------------------------------------------------------------------------
---  Graba la tabla CUADRE_TOTAL01
--------------------------------------------------------------------------------------------
/* Bug 17179 XPL#17012011
     BEGIN
         p_gracuadre_total01(aaproc, mmproc, empresa);
      EXCEPTION
         WHEN OTHERS THEN
            raise_application_error(-20001, '(p_gracuadre_total01) ERROR: ' || SQLERRM);
      END;

--------------------------------------------------------------------------------------------
---  Graba la tabla CUADRE_TOTAL02
--------------------------------------------------------------------------------------------
      BEGIN
         p_gracuadre_total02(aaproc, mmproc, empresa);
      EXCEPTION
         WHEN OTHERS THEN
            raise_application_error(-20001, '(p_gracuadre_total02) ERROR: ' || SQLERRM);
      END;

--------------------------------------------------------------------------------------------
---  Graba la tabla CUADRE_TOTAL03
--------------------------------------------------------------------------------------------
      BEGIN
         p_gracuadre_total03(aaproc, mmproc, empresa);
      EXCEPTION
         WHEN OTHERS THEN
            raise_application_error(-20001, '(p_gracuadre_total03) ERROR: ' || SQLERRM);
      END;

--------------------------------------------------------------------------------------------
---  Graba la tabla CUADRE_TOTAL04
--------------------------------------------------------------------------------------------
      BEGIN
         p_gracuadre_total04(aaproc, mmproc, empresa);
      EXCEPTION
         WHEN OTHERS THEN
            raise_application_error(-20001, '(p_gracuadre_total04) ERROR: ' || SQLERRM);
      END;
      */
   EXCEPTION
      WHEN OTHERS THEN
         raise_application_error(-20001, 'ERROR: ' || SQLERRM);
   END p_cuadre_recibos;

   PROCEDURE p_gracuadre01(aaproc IN NUMBER, mmproc IN NUMBER, empresa IN NUMBER) IS
      /************************************************************************************************
         Graba en la tabla CUADRE01, todos los recibos pendientes mes anterior
      ************************************************************************************************/
      fcierre_ant    DATE;
      fcierre_act    DATE;
      tiprec         VARCHAR2(1);
      pirpf          NUMBER;

      TYPE recibo IS RECORD(
         nrecibo        NUMBER,
         sseguro        NUMBER,
         cempres        NUMBER,
         cagente        NUMBER,
         fefecto        DATE,
         femisio        DATE,
         ctiprec        NUMBER
      );

      r              recibo;

      TYPE seguro IS RECORD(
         cramo          NUMBER,
         cmodali        NUMBER,
         npoliza        NUMBER,
         ncertif        NUMBER,
         sproduc        NUMBER,
         sseguro        NUMBER,
         ctipcoa        NUMBER   -- bug 31556/176985:NSS:19/06/2014
      );

      s              seguro;
      vsigno         NUMBER;

      -- Bug 9383 - 09/03/2009 - RSC - CRE: Unificación de recibos
      -- Anadimos 'pac_gestion_rec.f_recunif'
      CURSOR cur_movrecibos IS
         SELECT m.nrecibo, m.cestrec, m.cestant, m.fmovini, m.fmovdia, m.fefeadm
           FROM movrecibo m, recibos r
          WHERE r.cempres = empresa
            AND r.nrecibo IN(SELECT m2.nrecibo
                               FROM movrecibo m2
                              WHERE TRUNC(m2.fefeadm) < fdesde
                                AND TRUNC(m2.fefeadm) >= finicial
                                AND m2.cestant = 0
                                AND m2.cestrec = 0
                                AND m2.nrecibo = m.nrecibo)
            AND m.nrecibo = r.nrecibo
            AND m.cestrec = 0
            AND m.smovrec = (SELECT MAX(m1.smovrec)
                               FROM movrecibo m1
                              WHERE m1.nrecibo = m.nrecibo
                                AND TRUNC(m1.fefeadm) < fdesde)
            AND pac_gestion_rec.f_recunif_list(r.nrecibo) = 0;
   BEGIN
      BEGIN
         SELECT fproces
           INTO fcierre_ant
           FROM cierres
          WHERE cempres = empresa
            AND ctipo = 8
            AND fperini = ADD_MONTHS(TRUNC(fdesde, 'mm'), -1);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            fcierre_ant := ADD_MONTHS(TRUNC(fdesde, 'mm'), -1);
      END;

      BEGIN
         SELECT fproces
           INTO fcierre_act
           FROM cierres
          WHERE cempres = empresa
            AND ctipo = 8
            AND fperini = TRUNC(fdesde, 'mm');
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            fcierre_act := ADD_MONTHS(TRUNC(fdesde, 'mm'), -1);
      END;

      FOR m IN cur_movrecibos LOOP
         DECLARE
            CURSOR gtias IS
               SELECT DISTINCT (cgarant) cgarant
                          FROM detrecibos
                         WHERE nrecibo = m.nrecibo;
         BEGIN
            SELECT nrecibo,
                   sseguro,
                   cempres,
                   cagente,
                   fefecto,
                   femisio,
                   ctiprec
              INTO r
              FROM recibos
             WHERE nrecibo = m.nrecibo;

            IF r.ctiprec = 0 THEN
               tiprec := 'P';
            ELSIF r.ctiprec = 3 THEN
               tiprec := 'C';
            ELSE
               tiprec := 'S';
            END IF;

            SELECT cramo,
                   cmodali,
                   npoliza,
                   ncertif,
                   sproduc,
                   sseguro,
                   ctipcoa   -- bug 31556/176985:NSS:19/06/2014
              INTO s
              FROM seguros
             WHERE sseguro = r.sseguro;

            IF r.ctiprec = 9 THEN
               vsigno := -1;
            ELSE
               vsigno := 1;
            END IF;

            FOR gtia IN gtias LOOP
               IF f_impgarant(r.nrecibo, 'COMISION', gtia.cgarant) = 0 THEN
                  pirpf := 0;
               ELSE
                  pirpf := ROUND(f_impgarant(r.nrecibo, 'IRPF', gtia.cgarant) * 100
                                 / f_impgarant(r.nrecibo, 'COMISION', gtia.cgarant),
                                 2);
               END IF;

               INSERT INTO cuadre01
                           (cdelega, cramo,
                            cmodali, cgarant, npoliza, ncertif, nrecibo,
                            sproduc, sseguro, fefecto, femision, festado, cdemision,
                            cdestado, cagente,
                            prima_total,
                            prima_tarifa,
                            rec_fpago,
                            consorcio,
                            impuesto,
                            clea,
                            comision,
                            poirpf,
                            irpf,
                            liquido,
                            prima_deven,
                            com_deven,
                            ctipcoa)   -- bug 31556/176985:NSS:19/06/2014
                    VALUES (f_delegacion(r.nrecibo, r.cempres, r.cagente, r.fefecto), s.cramo,
                            s.cmodali, gtia.cgarant, s.npoliza, s.ncertif, r.nrecibo,
                            s.sproduc, s.sseguro, r.fefecto, r.femisio, m.fmovini, tiprec,
                            'P',
                                /* CDESTADO */
                                r.cagente,
                            vsigno
                            * ROUND(f_impgarant(r.nrecibo, 'PRIMA TOTAL', gtia.cgarant), 2),
                            vsigno
                            * ROUND(f_impgarant(r.nrecibo, 'PRIMA TARIFA', gtia.cgarant), 2),
                            vsigno
                            * ROUND(f_impgarant(r.nrecibo, 'REC FPAGO', gtia.cgarant), 2),
                            vsigno
                            * ROUND(f_impgarant(r.nrecibo, 'CONSORCIO', gtia.cgarant), 2),
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'IMPUESTO', gtia.cgarant), 2),
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'CLEA', gtia.cgarant), 2),
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'COMISION', gtia.cgarant), 2),
                            vsigno * pirpf,
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'IRPF', gtia.cgarant), 2),
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'LIQUIDO', gtia.cgarant), 2),
                            vsigno
                            * ROUND(f_impgarant(r.nrecibo, 'DEVENGADA', gtia.cgarant), 2),
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'COMDEVEN', gtia.cgarant), 2),
                            s.ctipcoa);   -- bug 31556/176985:NSS:19/06/2014
            END LOOP;
         EXCEPTION
            WHEN OTHERS THEN
               raise_application_error(-20001, 'ERROR: ' || SQLERRM);
         END;
      END LOOP;

      COMMIT;
   END p_gracuadre01;

   PROCEDURE p_gracuadre02(aaproc IN NUMBER, mmproc IN NUMBER, empresa IN NUMBER) IS
      /************************************************************************************************
         Graba en la tabla CUADRE02, todos los recibos emitidos
      ************************************************************************************************/
      fcierre_ant    DATE;
      fcierre_act    DATE;
      tiprec         VARCHAR2(1);
      pirpf          NUMBER;

      TYPE recibo IS RECORD(
         nrecibo        NUMBER,
         sseguro        NUMBER,
         cempres        NUMBER,
         cagente        NUMBER,
         fefecto        DATE,
         femisio        DATE,
         ctiprec        NUMBER
      );

      r              recibo;

      TYPE seguro IS RECORD(
         cramo          NUMBER,
         cmodali        NUMBER,
         npoliza        NUMBER,
         ncertif        NUMBER,
         sproduc        NUMBER,
         sseguro        NUMBER,
         ctipcoa        NUMBER   -- bug 31556/176985:NSS:19/06/2014
      );

      s              seguro;
      vsigno         NUMBER;

      -- Bug 9383 - 09/03/2009 - RSC - CRE: Unificación de recibos
      -- Anadimos 'pac_gestion_rec.f_recunif'
      CURSOR cur_movrecibos IS
         SELECT nrecibo, cestrec, cestant, fmovini, fmovdia, fefeadm
           FROM movrecibo a
          WHERE smovrec = (SELECT MAX(smovrec)
                             FROM movrecibo
                            WHERE nrecibo = a.nrecibo
                              AND TRUNC(fefeadm) BETWEEN fdesde AND fhasta)
            AND nrecibo IN(SELECT m.nrecibo
                             FROM movrecibo m, recibos r
                            WHERE TRUNC(m.fefeadm) BETWEEN fdesde AND fhasta
                              AND m.cestant = 0
                              AND m.cestrec = 0
                              AND m.nrecibo = r.nrecibo
                              AND r.cempres = empresa)
            AND pac_gestion_rec.f_recunif_list(nrecibo) = 0;
   BEGIN
      BEGIN
         SELECT fproces
           INTO fcierre_ant
           FROM cierres
          WHERE cempres = empresa
            AND ctipo = 8
            AND fperini = ADD_MONTHS(TRUNC(fdesde, 'mm'), -1);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            fcierre_ant := ADD_MONTHS(TRUNC(fdesde, 'mm'), -1);
      END;

      BEGIN
         SELECT fproces
           INTO fcierre_act
           FROM cierres
          WHERE cempres = empresa
            AND ctipo = 8
            AND fperini = TRUNC(fdesde, 'mm');
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            fcierre_act := ADD_MONTHS(TRUNC(fdesde, 'mm'), -1);
      END;

      FOR m IN cur_movrecibos LOOP
         DECLARE
            CURSOR gtias IS
               SELECT DISTINCT (cgarant) cgarant
                          FROM detrecibos
                         WHERE nrecibo = m.nrecibo;
         BEGIN
            SELECT nrecibo,
                   sseguro,
                   cempres,
                   cagente,
                   fefecto,
                   femisio,
                   ctiprec
              INTO r
              FROM recibos
             WHERE nrecibo = m.nrecibo;

            IF r.ctiprec = 0 THEN
               tiprec := 'P';
            ELSIF r.ctiprec = 3 THEN
               tiprec := 'C';
            ELSE
               tiprec := 'S';
            END IF;

            SELECT cramo,
                   cmodali,
                   npoliza,
                   ncertif,
                   sproduc,
                   sseguro,
                   ctipcoa   -- bug 31556/176985:NSS:19/06/2014
              INTO s
              FROM seguros
             WHERE sseguro = r.sseguro;

            IF r.ctiprec = 9 THEN
               vsigno := -1;
            ELSE
               vsigno := 1;
            END IF;

            FOR gtia IN gtias LOOP
               IF f_impgarant(r.nrecibo, 'COMISION', gtia.cgarant) = 0 THEN
                  pirpf := 0;
               ELSE
                  pirpf := ROUND(f_impgarant(r.nrecibo, 'IRPF', gtia.cgarant) * 100
                                 / f_impgarant(r.nrecibo, 'COMISION', gtia.cgarant),
                                 2);
               END IF;

               INSERT INTO cuadre02
                           (cdelega, cramo,
                            cmodali, cgarant, npoliza, ncertif, nrecibo,
                            sproduc, sseguro, fefecto, femision, festado, cdemision,
                            cdestado, cagente,
                            prima_total,
                            prima_tarifa,
                            rec_fpago,
                            consorcio,
                            impuesto,
                            clea,
                            comision,
                            poirpf,
                            irpf,
                            liquido,
                            prima_deven,
                            com_deven,
                            ctipcoa)   -- bug 31556/176985:NSS:19/06/2014
                    VALUES (f_delegacion(r.nrecibo, r.cempres, r.cagente, r.fefecto), s.cramo,
                            s.cmodali, gtia.cgarant, s.npoliza, s.ncertif, r.nrecibo,
                            s.sproduc, s.sseguro, r.fefecto, r.femisio, m.fmovini, tiprec,
                            DECODE(m.cestrec, 0, 'P', 1, 'C', 'A'),
                                                                   /* CDESTADO */
                                                                   r.cagente,
                            vsigno
                            * ROUND(f_impgarant(r.nrecibo, 'PRIMA TOTAL', gtia.cgarant), 2),
                            vsigno
                            * ROUND(f_impgarant(r.nrecibo, 'PRIMA TARIFA', gtia.cgarant), 2),
                            vsigno
                            * ROUND(f_impgarant(r.nrecibo, 'REC FPAGO', gtia.cgarant), 2),
                            vsigno
                            * ROUND(f_impgarant(r.nrecibo, 'CONSORCIO', gtia.cgarant), 2),
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'IMPUESTO', gtia.cgarant), 2),
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'CLEA', gtia.cgarant), 2),
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'COMISION', gtia.cgarant), 2),
                            vsigno * pirpf,
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'IRPF', gtia.cgarant), 2),
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'LIQUIDO', gtia.cgarant), 2),
                            vsigno
                            * ROUND(f_impgarant(r.nrecibo, 'DEVENGADA', gtia.cgarant), 2),
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'COMDEVEN', gtia.cgarant), 2),
                            s.ctipcoa);   -- bug 31556/176985:NSS:19/06/2014
            END LOOP;
         EXCEPTION
            WHEN OTHERS THEN
               raise_application_error(-20001, 'ERROR: ' || SQLERRM);
         END;
      END LOOP;

      COMMIT;
   END p_gracuadre02;

   PROCEDURE p_gracuadre03(aaproc IN NUMBER, mmproc IN NUMBER, empresa IN NUMBER) IS
      /************************************************************************************************
         Graba en la tabla CUADRE03, los recibos anulados del mes anterior que hayan cambiado
         de estado o fecha de estado
      ************************************************************************************************/
      fcierre_ant    DATE;
      fcierre_act    DATE;
      tiprec         VARCHAR2(1);
      estrec         NUMBER;
      festrec        DATE;
      pirpf          NUMBER;

      TYPE recibo IS RECORD(
         nrecibo        NUMBER,
         sseguro        NUMBER,
         cempres        NUMBER,
         cagente        NUMBER,
         fefecto        DATE,
         femisio        DATE,
         ctiprec        NUMBER
      );

      r              recibo;

      TYPE seguro IS RECORD(
         cramo          NUMBER,
         cmodali        NUMBER,
         npoliza        NUMBER,
         ncertif        NUMBER,
         sproduc        NUMBER,
         sseguro        NUMBER,
         ctipcoa        NUMBER   -- bug 31556/176985:NSS:19/06/2014
      );

      s              seguro;
      vsigno         NUMBER;

      -- Bug 9383 - 09/03/2009 - RSC - CRE: Unificación de recibos
      -- Anadimos 'pac_gestion_rec.f_recunif'
      CURSOR cur_movrecibos IS
         SELECT nrecibo, cestrec, cestant, fmovini, fmovdia, fefeadm
           FROM movrecibo a
          WHERE TRUNC(fefeadm) BETWEEN fdesde AND fhasta
            AND cestant = 2
            AND smovrec = (SELECT MIN(m.smovrec)
                             FROM movrecibo m, recibos r
                            WHERE m.nrecibo = a.nrecibo
                              AND TRUNC(m.fefeadm) BETWEEN fdesde AND fhasta
                              AND m.nrecibo = r.nrecibo
                              AND r.cempres = empresa)
            AND nrecibo IN(SELECT m2.nrecibo
                             FROM movrecibo m2, recibos r2
                            WHERE TRUNC(m2.fefeadm) BETWEEN finicial AND fhasta
                              AND m2.cestant = 0
                              AND m2.cestrec = 0
                              AND m2.nrecibo = r2.nrecibo
                              AND r2.cempres = empresa)
            AND pac_gestion_rec.f_recunif_list(nrecibo) = 0;
   BEGIN
      BEGIN
         SELECT fproces
           INTO fcierre_ant
           FROM cierres
          WHERE cempres = empresa
            AND ctipo = 8
            AND fperini = ADD_MONTHS(TRUNC(fdesde, 'mm'), -1);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            fcierre_ant := ADD_MONTHS(TRUNC(fdesde, 'mm'), -1);
      END;

      BEGIN
         SELECT fproces
           INTO fcierre_act
           FROM cierres
          WHERE cempres = empresa
            AND ctipo = 8
            AND fperini = TRUNC(fdesde, 'mm');
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            fcierre_act := ADD_MONTHS(TRUNC(fdesde, 'mm'), -1);
      END;

      FOR m IN cur_movrecibos LOOP
         DECLARE
            CURSOR gtias IS
               SELECT DISTINCT (cgarant) cgarant
                          FROM detrecibos
                         WHERE nrecibo = m.nrecibo;
         BEGIN
            SELECT nrecibo,
                   sseguro,
                   cempres,
                   cagente,
                   fefecto,
                   femisio,
                   ctiprec
              INTO r
              FROM recibos
             WHERE nrecibo = m.nrecibo;

            IF r.ctiprec = 0 THEN
               tiprec := 'P';
            ELSIF r.ctiprec = 3 THEN
               tiprec := 'C';
            ELSE
               tiprec := 'S';
            END IF;

            SELECT cramo,
                   cmodali,
                   npoliza,
                   ncertif,
                   sproduc,
                   sseguro,
                   ctipcoa   -- bug 31556/176985:NSS:19/06/2014
              INTO s
              FROM seguros
             WHERE sseguro = r.sseguro;

            IF r.ctiprec = 9 THEN
               vsigno := -1;
            ELSE
               vsigno := 1;
            END IF;

            FOR gtia IN gtias LOOP
               IF f_impgarant(r.nrecibo, 'COMISION', gtia.cgarant) = 0 THEN
                  pirpf := 0;
               ELSE
                  pirpf := ROUND(f_impgarant(r.nrecibo, 'IRPF', gtia.cgarant) * 100
                                 / f_impgarant(r.nrecibo, 'COMISION', gtia.cgarant),
                                 2);
               END IF;

               INSERT INTO cuadre03
                           (cdelega, cramo,
                            cmodali, cgarant, npoliza, ncertif, nrecibo,
                            sproduc, sseguro, fefecto, femision, festado, cdemision,
                            cdestado, cagente,
                            prima_total,
                            prima_tarifa,
                            rec_fpago,
                            consorcio,
                            impuesto,
                            clea,
                            comision,
                            poirpf,
                            irpf,
                            liquido,
                            prima_deven,
                            com_deven,
                            ctipcoa)   -- bug 31556/176985:NSS:19/06/2014
                    VALUES (f_delegacion(r.nrecibo, r.cempres, r.cagente, r.fefecto), s.cramo,
                            s.cmodali, gtia.cgarant, s.npoliza, s.ncertif, r.nrecibo,
                            s.sproduc, s.sseguro, r.fefecto, r.femisio, m.fmovini, tiprec,
                            'A',
                                /* CDESTADO */
                                r.cagente,
                            vsigno
                            * ROUND(f_impgarant(r.nrecibo, 'PRIMA TOTAL', gtia.cgarant), 2),
                            vsigno
                            * ROUND(f_impgarant(r.nrecibo, 'PRIMA TARIFA', gtia.cgarant), 2),
                            vsigno
                            * ROUND(f_impgarant(r.nrecibo, 'REC FPAGO', gtia.cgarant), 2),
                            vsigno
                            * ROUND(f_impgarant(r.nrecibo, 'CONSORCIO', gtia.cgarant), 2),
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'IMPUESTO', gtia.cgarant), 2),
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'CLEA', gtia.cgarant), 2),
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'COMISION', gtia.cgarant), 2),
                            vsigno * pirpf,
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'IRPF', gtia.cgarant), 2),
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'LIQUIDO', gtia.cgarant), 2),
                            vsigno
                            * ROUND(f_impgarant(r.nrecibo, 'DEVENGADA', gtia.cgarant), 2),
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'COMDEVEN', gtia.cgarant), 2),
                            s.ctipcoa);   -- bug 31556/176985:NSS:19/06/2014
            END LOOP;
         EXCEPTION
            WHEN OTHERS THEN
               raise_application_error(-20001, 'ERROR: ' || SQLERRM);
         END;
      END LOOP;

      COMMIT;
   END p_gracuadre03;

   PROCEDURE p_gracuadre04(aaproc IN NUMBER, mmproc IN NUMBER, empresa IN NUMBER) IS
      /************************************************************************************************
         Graba en la tabla CUADRE04, los recibos emitidos en el ano que se han devuelto
         en el mes del cierre
      ************************************************************************************************/
      fcierre_ant    DATE;
      fcierre_act    DATE;
      tiprec         VARCHAR2(1);
      estrec         NUMBER;
      festrec        DATE;
      pirpf          NUMBER;
      vtipcob        NUMBER;

      TYPE recibo IS RECORD(
         nrecibo        NUMBER,
         sseguro        NUMBER,
         cempres        NUMBER,
         cagente        NUMBER,
         fefecto        DATE,
         femisio        DATE,
         ctiprec        NUMBER
      );

      r              recibo;

      TYPE seguro IS RECORD(
         cramo          NUMBER,
         cmodali        NUMBER,
         npoliza        NUMBER,
         ncertif        NUMBER,
         sproduc        NUMBER,
         sseguro        NUMBER,
         ctipcoa        NUMBER   -- bug 31556/176985:NSS:19/06/2014
      );

      s              seguro;
      vsigno         NUMBER;

      -- Bug 9383 - 09/03/2009 - RSC - CRE: Unificación de recibos
      -- Anadimos 'pac_gestion_rec.f_recunif'
      CURSOR cur_movrecibos IS
         SELECT nrecibo, cestrec, cestant, fmovini, fmovdia, fefeadm, smovrec
           FROM movrecibo a
          WHERE TRUNC(fefeadm) BETWEEN fdesde AND fhasta
            AND cestant = 1
            AND smovrec = (SELECT MIN(m.smovrec)
                             FROM movrecibo m, recibos r
                            WHERE m.nrecibo = a.nrecibo
                              AND TRUNC(m.fefeadm) BETWEEN fdesde AND fhasta
                              AND m.nrecibo = r.nrecibo
                              AND r.cempres = empresa)
            AND nrecibo IN(SELECT m2.nrecibo
                             FROM movrecibo m2, recibos r2
                            WHERE TRUNC(m2.fefeadm) <= fhasta
                              AND TRUNC(m2.fefeadm) >= finicial
                              AND m2.cestant = 0
                              AND m2.cestrec = 0
                              AND m2.nrecibo = r2.nrecibo
                              AND r2.cempres = empresa)
            AND pac_gestion_rec.f_recunif_list(nrecibo) = 0;
   BEGIN
      BEGIN
         SELECT fproces
           INTO fcierre_ant
           FROM cierres
          WHERE cempres = empresa
            AND ctipo = 8
            AND fperini = ADD_MONTHS(TRUNC(fdesde, 'mm'), -1);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            fcierre_ant := ADD_MONTHS(TRUNC(fdesde, 'mm'), -1);
      END;

      BEGIN
         SELECT fproces
           INTO fcierre_act
           FROM cierres
          WHERE cempres = empresa
            AND ctipo = 8
            AND fperini = TRUNC(fdesde, 'mm');
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            fcierre_act := ADD_MONTHS(TRUNC(fdesde, 'mm'), -1);
      END;

      FOR m IN cur_movrecibos LOOP
         DECLARE
            CURSOR gtias IS
               SELECT DISTINCT (cgarant) cgarant
                          FROM detrecibos
                         WHERE nrecibo = m.nrecibo;
         BEGIN
            SELECT nrecibo,
                   sseguro,
                   cempres,
                   cagente,
                   fefecto,
                   femisio,
                   ctiprec
              INTO r
              FROM recibos
             WHERE nrecibo = m.nrecibo;

            IF r.ctiprec = 0 THEN
               tiprec := 'P';
            ELSIF r.ctiprec = 3 THEN
               tiprec := 'C';
            ELSE
               tiprec := 'S';
            END IF;

            IF r.ctiprec = 9 THEN
               vsigno := -1;
            ELSE
               vsigno := 1;
            END IF;

            SELECT cramo,
                   cmodali,
                   npoliza,
                   ncertif,
                   sproduc,
                   sseguro,
                   ctipcoa   -- bug 31556/176985:NSS:19/06/2014
              INTO s
              FROM seguros
             WHERE sseguro = r.sseguro;

            -- CPM 28/10/04 Busquem el tipo de cobrament del moviment anterior
            SELECT ctipcob
              INTO vtipcob
              FROM movrecibo
             WHERE nrecibo = m.nrecibo
               AND smovrec = (SELECT MAX(smovrec)
                                FROM movrecibo
                               WHERE nrecibo = m.nrecibo
                                 AND smovrec < m.smovrec
                                 AND cestrec = 1);

            FOR gtia IN gtias LOOP
               IF f_impgarant(r.nrecibo, 'COMISION', gtia.cgarant) = 0 THEN
                  pirpf := 0;
               ELSE
                  pirpf := ROUND(f_impgarant(r.nrecibo, 'IRPF', gtia.cgarant) * 100
                                 / f_impgarant(r.nrecibo, 'COMISION', gtia.cgarant),
                                 2);
               END IF;

               INSERT INTO cuadre04
                           (cdelega, cramo,
                            cmodali, cgarant, npoliza, ncertif, nrecibo,
                            sproduc, sseguro, fefecto, femision, festado, cdemision,
                            cdestado, cagente,
                            prima_total,
                            prima_tarifa,
                            rec_fpago,
                            consorcio,
                            impuesto,
                            clea,
                            comision,
                            poirpf,
                            irpf,
                            liquido,
                            prima_deven,
                            com_deven,
                            ctipcoa)   -- bug 31556/176985:NSS:19/06/2014
                    VALUES (f_delegacion(r.nrecibo, r.cempres, r.cagente, r.fefecto), s.cramo,
                            s.cmodali, gtia.cgarant, s.npoliza, s.ncertif, r.nrecibo,
                            s.sproduc, s.sseguro, r.fefecto, r.femisio, m.fmovini, tiprec,
                            DECODE(vtipcob, NULL, 'R', 'C'),   /* CDESTADO */
                                                            -- R= Remesa, -- C= Cobrado
                                                            r.cagente,
                            vsigno
                            * ROUND(f_impgarant(r.nrecibo, 'PRIMA TOTAL', gtia.cgarant), 2),
                            vsigno
                            * ROUND(f_impgarant(r.nrecibo, 'PRIMA TARIFA', gtia.cgarant), 2),
                            vsigno
                            * ROUND(f_impgarant(r.nrecibo, 'REC FPAGO', gtia.cgarant), 2),
                            vsigno
                            * ROUND(f_impgarant(r.nrecibo, 'CONSORCIO', gtia.cgarant), 2),
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'IMPUESTO', gtia.cgarant), 2),
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'CLEA', gtia.cgarant), 2),
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'COMISION', gtia.cgarant), 2),
                            vsigno * pirpf,
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'IRPF', gtia.cgarant), 2),
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'LIQUIDO', gtia.cgarant), 2),
                            vsigno
                            * ROUND(f_impgarant(r.nrecibo, 'DEVENGADA', gtia.cgarant), 2),
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'COMDEVEN', gtia.cgarant), 2),
                            s.ctipcoa);   -- bug 31556/176985:NSS:19/06/2014
            END LOOP;
         EXCEPTION
            WHEN OTHERS THEN
               raise_application_error(-20001, 'ERROR: ' || SQLERRM);
         END;
      END LOOP;

      COMMIT;
   END p_gracuadre04;

   PROCEDURE p_gracuadre05(aaproc IN NUMBER, mmproc IN NUMBER, empresa IN NUMBER) IS
      /************************************************************************************************
         Graba en la tabla CUADRE05, todos los recibos cobrados
      ************************************************************************************************/
      fcierre_ant    DATE;
      fcierre_act    DATE;
      tiprec         VARCHAR2(1);
      pirpf          NUMBER;

      TYPE recibo IS RECORD(
         nrecibo        NUMBER,
         sseguro        NUMBER,
         cempres        NUMBER,
         cagente        NUMBER,
         fefecto        DATE,
         femisio        DATE,
         ctiprec        NUMBER
      );

      r              recibo;

      TYPE seguro IS RECORD(
         cramo          NUMBER,
         cmodali        NUMBER,
         npoliza        NUMBER,
         ncertif        NUMBER,
         sproduc        NUMBER,
         sseguro        NUMBER,
         ctipcoa        NUMBER   -- bug 31556/176985:NSS:19/06/2014
      );

      s              seguro;
      vsigno         NUMBER;

      -- Bug 9383 - 09/03/2009 - RSC - CRE: Unificación de recibos
      -- Anadimos 'pac_gestion_rec.f_recunif'
      CURSOR cur_movrecibos IS
         SELECT a.nrecibo, a.cestrec, a.cestant, a.fmovini, a.fmovdia, a.fefeadm, a.ctipcob
           FROM movrecibo a, recibos r
          WHERE a.cestrec = 1
            AND r.nrecibo = a.nrecibo
            AND r.cempres = empresa
            AND a.smovrec = (SELECT MAX(m.smovrec)
                               FROM movrecibo m
                              WHERE m.nrecibo = a.nrecibo
                                AND TRUNC(m.fefeadm) BETWEEN fdesde AND fhasta)
            AND a.nrecibo IN(SELECT m2.nrecibo
                               FROM movrecibo m2
                              WHERE TRUNC(m2.fefeadm) >= finicial
                                AND m2.cestant = 0
                                AND m2.cestrec = 0
                                AND m2.nrecibo = a.nrecibo)
            AND pac_gestion_rec.f_recunif_list(r.nrecibo) = 0;
   BEGIN
      BEGIN
         SELECT fproces
           INTO fcierre_ant
           FROM cierres
          WHERE cempres = empresa
            AND ctipo = 8
            AND fperini = ADD_MONTHS(TRUNC(fdesde, 'mm'), -1);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            fcierre_ant := ADD_MONTHS(TRUNC(fdesde, 'mm'), -1);
      END;

      BEGIN
         SELECT fproces
           INTO fcierre_act
           FROM cierres
          WHERE cempres = empresa
            AND ctipo = 8
            AND fperini = TRUNC(fdesde, 'mm');
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            fcierre_act := ADD_MONTHS(TRUNC(fdesde, 'mm'), -1);
      END;

      FOR m IN cur_movrecibos LOOP
         DECLARE
            CURSOR gtias IS
               SELECT DISTINCT (cgarant) cgarant
                          FROM detrecibos
                         WHERE nrecibo = m.nrecibo;
         BEGIN
            SELECT nrecibo,
                   sseguro,
                   cempres,
                   cagente,
                   fefecto,
                   femisio,
                   ctiprec
              INTO r
              FROM recibos
             WHERE nrecibo = m.nrecibo;

            IF r.ctiprec = 0 THEN
               tiprec := 'P';
            ELSIF r.ctiprec = 3 THEN
               tiprec := 'C';
            ELSE
               tiprec := 'S';
            END IF;

            IF r.ctiprec = 9 THEN
               vsigno := -1;
            ELSE
               vsigno := 1;
            END IF;

            SELECT cramo,
                   cmodali,
                   npoliza,
                   ncertif,
                   sproduc,
                   sseguro,
                   ctipcoa   -- bug 31556/176985:NSS:19/06/2014
              INTO s
              FROM seguros
             WHERE sseguro = r.sseguro;

            FOR gtia IN gtias LOOP
               IF f_impgarant(r.nrecibo, 'COMISION', gtia.cgarant) = 0 THEN
                  pirpf := 0;
               ELSE
                  pirpf := ROUND(f_impgarant(r.nrecibo, 'IRPF', gtia.cgarant) * 100
                                 / f_impgarant(r.nrecibo, 'COMISION', gtia.cgarant),
                                 2);
               END IF;

               INSERT INTO cuadre05
                           (cdelega, cramo,
                            cmodali, cgarant, npoliza, ncertif, nrecibo,
                            sproduc, sseguro, fefecto, femision, festado, cdemision,
                            cdestado,
                            cagente,
                            prima_total,
                            prima_tarifa,
                            rec_fpago,
                            consorcio,
                            impuesto,
                            clea,
                            comision,
                            poirpf,
                            irpf,
                            liquido,
                            prima_deven,
                            com_deven,
                            ctipcoa)   -- bug 31556/176985:NSS:19/06/2014
                    VALUES (f_delegacion(r.nrecibo, r.cempres, r.cagente, r.fefecto), s.cramo,
                            s.cmodali, gtia.cgarant, s.npoliza, s.ncertif, r.nrecibo,
                            s.sproduc, s.sseguro, r.fefecto, r.femisio, m.fmovini, tiprec,
                                --incid 3407, jdomingo, 6/11/2007 (no sumar dies gestió si és extorn)
                            --    DECODE(m.ctipcob, NULL, 'R','C'),    /* CDESTADO */
                            DECODE(m.ctipcob, NULL, DECODE(r.ctiprec, 9, 'C', 'R'), 'C'),   /* CDESTADO */
                            -- R= Remesa, -- C= Cobrado
                            r.cagente,
                            vsigno
                            * ROUND(f_impgarant(r.nrecibo, 'PRIMA TOTAL', gtia.cgarant), 2),
                            vsigno
                            * ROUND(f_impgarant(r.nrecibo, 'PRIMA TARIFA', gtia.cgarant), 2),
                            vsigno
                            * ROUND(f_impgarant(r.nrecibo, 'REC FPAGO', gtia.cgarant), 2),
                            vsigno
                            * ROUND(f_impgarant(r.nrecibo, 'CONSORCIO', gtia.cgarant), 2),
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'IMPUESTO', gtia.cgarant), 2),
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'CLEA', gtia.cgarant), 2),
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'COMISION', gtia.cgarant), 2),
                            vsigno * pirpf,
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'IRPF', gtia.cgarant), 2),
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'LIQUIDO', gtia.cgarant), 2),
                            vsigno
                            * ROUND(f_impgarant(r.nrecibo, 'DEVENGADA', gtia.cgarant), 2),
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'COMDEVEN', gtia.cgarant), 2),
                            s.ctipcoa);
            END LOOP;
         EXCEPTION
            WHEN OTHERS THEN
               raise_application_error(-20001, 'ERROR: ' || SQLERRM);
         END;
      END LOOP;

      COMMIT;
   END p_gracuadre05;

   PROCEDURE p_gracuadre06(aaproc IN NUMBER, mmproc IN NUMBER, empresa IN NUMBER) IS
      /************************************************************************************************
         Graba en la tabla CUADRE06, todos los recibos anulados
      ************************************************************************************************/
      fcierre_ant    DATE;
      fcierre_act    DATE;
      tiprec         VARCHAR2(1);
      pirpf          NUMBER;

      TYPE recibo IS RECORD(
         nrecibo        NUMBER,
         sseguro        NUMBER,
         cempres        NUMBER,
         cagente        NUMBER,
         fefecto        DATE,
         femisio        DATE,
         ctiprec        NUMBER
      );

      r              recibo;

      TYPE seguro IS RECORD(
         cramo          NUMBER,
         cmodali        NUMBER,
         npoliza        NUMBER,
         ncertif        NUMBER,
         sproduc        NUMBER,
         sseguro        NUMBER,
         ctipcoa        NUMBER   -- bug 31556/176985:NSS:19/06/2014
      );

      s              seguro;
      vsigno         NUMBER;

      -- Bug 9383 - 09/03/2009 - RSC - CRE: Unificación de recibos
      -- Anadimos 'pac_gestion_rec.f_recunif'
      CURSOR cur_movrecibos IS
         SELECT nrecibo, cestrec, cestant, fmovini, fmovdia, fefeadm
           FROM movrecibo a
          WHERE cestrec = 2
            AND smovrec = (SELECT MAX(m.smovrec)
                             FROM movrecibo m, recibos r
                            WHERE m.nrecibo = a.nrecibo
                              AND TRUNC(m.fefeadm) BETWEEN fdesde AND fhasta
                              AND m.nrecibo = r.nrecibo
                              AND r.cempres = empresa)
            AND nrecibo IN(SELECT m2.nrecibo
                             FROM movrecibo m2, recibos r2
                            WHERE TRUNC(m2.fefeadm) BETWEEN finicial AND fhasta
                              AND m2.cestant = 0
                              AND m2.cestrec = 0
                              AND m2.nrecibo = r2.nrecibo
                              AND r2.cempres = empresa)
            AND pac_gestion_rec.f_recunif_list(nrecibo) = 0;
   BEGIN
      BEGIN
         SELECT fproces
           INTO fcierre_ant
           FROM cierres
          WHERE cempres = empresa
            AND ctipo = 8
            AND fperini = ADD_MONTHS(TRUNC(fdesde, 'mm'), -1);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            fcierre_ant := ADD_MONTHS(TRUNC(fdesde, 'mm'), -1);
      END;

      BEGIN
         SELECT fproces
           INTO fcierre_act
           FROM cierres
          WHERE cempres = empresa
            AND ctipo = 8
            AND fperini = TRUNC(fdesde, 'mm');
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            fcierre_act := ADD_MONTHS(TRUNC(fdesde, 'mm'), -1);
      END;

      FOR m IN cur_movrecibos LOOP
         DECLARE
            CURSOR gtias IS
               SELECT DISTINCT (cgarant) cgarant
                          FROM detrecibos
                         WHERE nrecibo = m.nrecibo;
         BEGIN
            SELECT nrecibo,
                   sseguro,
                   cempres,
                   cagente,
                   fefecto,
                   femisio,
                   ctiprec
              INTO r
              FROM recibos
             WHERE nrecibo = m.nrecibo;

            IF r.ctiprec = 0 THEN
               tiprec := 'P';
            ELSIF r.ctiprec = 3 THEN
               tiprec := 'C';
            ELSE
               tiprec := 'S';
            END IF;

            IF r.ctiprec = 9 THEN
               vsigno := -1;
            ELSE
               vsigno := 1;
            END IF;

            SELECT cramo,
                   cmodali,
                   npoliza,
                   ncertif,
                   sproduc,
                   sseguro,
                   ctipcoa   -- bug 31556/176985:NSS:19/06/2014
              INTO s
              FROM seguros
             WHERE sseguro = r.sseguro;

            FOR gtia IN gtias LOOP
               IF f_impgarant(r.nrecibo, 'COMISION', gtia.cgarant) = 0 THEN
                  pirpf := 0;
               ELSE
                  pirpf := ROUND(f_impgarant(r.nrecibo, 'IRPF', gtia.cgarant) * 100
                                 / f_impgarant(r.nrecibo, 'COMISION', gtia.cgarant),
                                 2);
               END IF;

               INSERT INTO cuadre06
                           (cdelega, cramo,
                            cmodali, cgarant, npoliza, ncertif, nrecibo,
                            sproduc, sseguro, fefecto, femision, festado, cdemision,
                            cdestado, cagente,
                            prima_total,
                            prima_tarifa,
                            rec_fpago,
                            consorcio,
                            impuesto,
                            clea,
                            comision,
                            poirpf,
                            irpf,
                            liquido,
                            prima_deven,
                            com_deven,
                            ctipcoa)   -- bug 31556/176985:NSS:19/06/2014
                    VALUES (f_delegacion(r.nrecibo, r.cempres, r.cagente, r.fefecto), s.cramo,
                            s.cmodali, gtia.cgarant, s.npoliza, s.ncertif, r.nrecibo,
                            s.sproduc, s.sseguro, r.fefecto, r.femisio, m.fmovini, tiprec,
                            'A',
                                /* CDESTADO */
                                r.cagente,
                            vsigno
                            * ROUND(f_impgarant(r.nrecibo, 'PRIMA TOTAL', gtia.cgarant), 2),
                            vsigno
                            * ROUND(f_impgarant(r.nrecibo, 'PRIMA TARIFA', gtia.cgarant), 2),
                            vsigno
                            * ROUND(f_impgarant(r.nrecibo, 'REC FPAGO', gtia.cgarant), 2),
                            vsigno
                            * ROUND(f_impgarant(r.nrecibo, 'CONSORCIO', gtia.cgarant), 2),
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'IMPUESTO', gtia.cgarant), 2),
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'CLEA', gtia.cgarant), 2),
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'COMISION', gtia.cgarant), 2),
                            vsigno * pirpf,
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'IRPF', gtia.cgarant), 2),
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'LIQUIDO', gtia.cgarant), 2),
                            vsigno
                            * ROUND(f_impgarant(r.nrecibo, 'DEVENGADA', gtia.cgarant), 2),
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'COMDEVEN', gtia.cgarant), 2),
                            s.ctipcoa);   -- bug 31556/176985:NSS:19/06/2014
            END LOOP;
         EXCEPTION
            WHEN OTHERS THEN
               raise_application_error(-20001, 'ERROR: ' || SQLERRM);
         END;
      END LOOP;

      COMMIT;
   END p_gracuadre06;

   PROCEDURE p_gracuadre07(aaproc IN NUMBER, mmproc IN NUMBER, empresa IN NUMBER) IS
      /************************************************************************************************
         Graba en la tabla CUADRE07, todos los recibos pendientes
      ************************************************************************************************/
      fcierre_ant    DATE;
      fcierre_act    DATE;
      tiprec         VARCHAR2(1);
      pirpf          NUMBER;

      TYPE recibo IS RECORD(
         nrecibo        NUMBER,
         sseguro        NUMBER,
         cempres        NUMBER,
         cagente        NUMBER,
         fefecto        DATE,
         femisio        DATE,
         ctiprec        NUMBER
      );

      r              recibo;

      TYPE seguro IS RECORD(
         cramo          NUMBER,
         cmodali        NUMBER,
         npoliza        NUMBER,
         ncertif        NUMBER,
         sproduc        NUMBER,
         sseguro        NUMBER,
         ctipcoa        NUMBER   -- bug 31556/176985:NSS:19/06/2014
      );

      s              seguro;
      vsigno         NUMBER;

      -- Bug 9383 - 09/03/2009 - RSC - CRE: Unificación de recibos
      -- Anadimos 'pac_gestion_rec.f_recunif'
      CURSOR cur_movrecibos IS
         SELECT nrecibo, cestrec, cestant, fmovini, fmovdia, fefeadm
           FROM movrecibo a
          WHERE cestrec = 0
            AND smovrec = (SELECT MAX(m.smovrec)
                             FROM movrecibo m, recibos r
                            WHERE m.nrecibo = a.nrecibo
                              AND TRUNC(m.fefeadm) <= fhasta
                              AND m.nrecibo = r.nrecibo
                              AND r.cempres = empresa)
            AND nrecibo IN(SELECT m2.nrecibo
                             FROM movrecibo m2, recibos r2
                            WHERE TRUNC(m2.fefeadm) BETWEEN finicial AND fhasta
                              AND m2.cestant = 0
                              AND m2.cestrec = 0
                              AND m2.nrecibo = r2.nrecibo
                              AND r2.cempres = empresa)
            AND pac_gestion_rec.f_recunif_list(nrecibo) = 0;
   BEGIN
      BEGIN
         SELECT fproces
           INTO fcierre_ant
           FROM cierres
          WHERE cempres = empresa
            AND ctipo = 8
            AND fperini = ADD_MONTHS(TRUNC(fdesde, 'mm'), -1);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            fcierre_ant := ADD_MONTHS(TRUNC(fdesde, 'mm'), -1);
      END;

      BEGIN
         SELECT fproces
           INTO fcierre_act
           FROM cierres
          WHERE cempres = empresa
            AND ctipo = 8
            AND fperini = TRUNC(fdesde, 'mm');
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            fcierre_act := ADD_MONTHS(TRUNC(fdesde, 'mm'), -1);
      END;

      FOR m IN cur_movrecibos LOOP
         DECLARE
            CURSOR gtias IS
               SELECT DISTINCT (cgarant) cgarant
                          FROM detrecibos
                         WHERE nrecibo = m.nrecibo;
         BEGIN
            SELECT nrecibo,
                   sseguro,
                   cempres,
                   cagente,
                   fefecto,
                   femisio,
                   ctiprec
              INTO r
              FROM recibos
             WHERE nrecibo = m.nrecibo;

            IF r.ctiprec = 0 THEN
               tiprec := 'P';
            ELSIF r.ctiprec = 3 THEN
               tiprec := 'C';
            ELSE
               tiprec := 'S';
            END IF;

            IF r.ctiprec = 9 THEN
               vsigno := -1;
            ELSE
               vsigno := 1;
            END IF;

            SELECT cramo,
                   cmodali,
                   npoliza,
                   ncertif,
                   sproduc,
                   sseguro,
                   ctipcoa   -- bug 31556/176985:NSS:19/06/2014
              INTO s
              FROM seguros
             WHERE sseguro = r.sseguro;

            FOR gtia IN gtias LOOP
               IF f_impgarant(r.nrecibo, 'COMISION', gtia.cgarant) = 0 THEN
                  pirpf := 0;
               ELSE
                  pirpf := ROUND(f_impgarant(r.nrecibo, 'IRPF', gtia.cgarant) * 100
                                 / f_impgarant(r.nrecibo, 'COMISION', gtia.cgarant),
                                 2);
               END IF;

               INSERT INTO cuadre07
                           (cdelega, cramo,
                            cmodali, cgarant, npoliza, ncertif, nrecibo,
                            sproduc, sseguro, fefecto, femision, festado, cdemision,
                            cdestado, cagente,
                            prima_total,
                            prima_tarifa,
                            rec_fpago,
                            consorcio,
                            impuesto,
                            clea,
                            comision,
                            poirpf,
                            irpf,
                            liquido,
                            prima_deven,
                            com_deven,
                            ctipcoa)   -- bug 31556/176985:NSS:19/06/2014
                    VALUES (f_delegacion(r.nrecibo, r.cempres, r.cagente, r.fefecto), s.cramo,
                            s.cmodali, gtia.cgarant, s.npoliza, s.ncertif, r.nrecibo,
                            s.sproduc, s.sseguro, r.fefecto, r.femisio, m.fmovini, tiprec,
                            'P',
                                /* CDESTADO */
                                r.cagente,
                            vsigno
                            * ROUND(f_impgarant(r.nrecibo, 'PRIMA TOTAL', gtia.cgarant), 2),
                            vsigno
                            * ROUND(f_impgarant(r.nrecibo, 'PRIMA TARIFA', gtia.cgarant), 2),
                            vsigno
                            * ROUND(f_impgarant(r.nrecibo, 'REC FPAGO', gtia.cgarant), 2),
                            vsigno
                            * ROUND(f_impgarant(r.nrecibo, 'CONSORCIO', gtia.cgarant), 2),
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'IMPUESTO', gtia.cgarant), 2),
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'CLEA', gtia.cgarant), 2),
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'COMISION', gtia.cgarant), 2),
                            vsigno * pirpf,
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'IRPF', gtia.cgarant), 2),
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'LIQUIDO', gtia.cgarant), 2),
                            vsigno
                            * ROUND(f_impgarant(r.nrecibo, 'DEVENGADA', gtia.cgarant), 2),
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'COMDEVEN', gtia.cgarant), 2),
                            s.ctipcoa);   -- bug 31556/176985:NSS:19/06/2014
            END LOOP;
         EXCEPTION
            WHEN OTHERS THEN
               raise_application_error(-20001, 'ERROR: ' || SQLERRM);
         END;
      END LOOP;

      COMMIT;
   END p_gracuadre07;

   PROCEDURE p_gracuadre08(aaproc IN NUMBER, mmproc IN NUMBER, empresa IN NUMBER) IS
      /************************************************************************************************
         Graba en la tabla CUADRE08, todos los recibos que han pasado de gestión de
         cobro (estado de MV, recibos domiciliados cobrados de menos de 45 días)
         a cobrado
      ************************************************************************************************/
      tiprec         VARCHAR2(1);
      pirpf          NUMBER;

      TYPE recibo IS RECORD(
         nrecibo        NUMBER,
         sseguro        NUMBER,
         cempres        NUMBER,
         cagente        NUMBER,
         fefecto        DATE,
         femisio        DATE,
         ctiprec        NUMBER
      );

      r              recibo;

      TYPE seguro IS RECORD(
         cramo          NUMBER,
         cmodali        NUMBER,
         npoliza        NUMBER,
         ncertif        NUMBER,
         sproduc        NUMBER,
         sseguro        NUMBER,
         ctipcoa        NUMBER   -- bug 31556/176985:NSS:19/06/2014
      );

      s              seguro;
      vsigno         NUMBER;
      vtramo_dias    NUMBER;
      vent_bm        VARCHAR2(4);

      -- Bug 9383 - 09/03/2009 - RSC - CRE: Unificación de recibos
      -- Anadimos 'pac_gestion_rec.f_recunif'
      CURSOR cur_movrecibos IS
         SELECT a.nrecibo, a.cestrec, a.cestant, a.fmovini, a.fmovdia, a.fefeadm, a.ctipcob
           FROM movrecibo a, recibos b
          WHERE a.cestrec = 1
            AND b.nrecibo = a.nrecibo
            AND a.smovrec = (SELECT MAX(m.smovrec)
                               FROM movrecibo m, recibos r
                              WHERE m.nrecibo = a.nrecibo
                                AND TRUNC(m.fefeadm) <= fhasta
                                AND m.nrecibo = r.nrecibo
                                AND r.cempres = empresa)
            -- NVL(a.ctipcob,-1),  --incid 3407, jdomingo, 6/11/2007 (no sumar dies gestió si és extorn)
            AND DECODE(NVL(a.ctipcob, DECODE(b.ctiprec, 9, 0, -1)),
                       --BUG 35103-200056.KJSC. Se debe sustituir w_empresa por el número de recibo (nrecibo).
                       -1, LEAST(a.fmovini, a.fefeadm) + pac_adm.f_get_diasgest(b.nrecibo),
                       /*BUG 0010676: 22/09/2009 : NMM -- CEM - Substituïm el paràmetre de rebut pel de companyia */
                       --CLAUDIO24/04/2014
                       ---1, LEAST(a.fmovini, a.fefeadm) + pac_adm.f_get_diasgest(b.cempres),
                       -- -1, a.fmovini + pac_adm.f_get_diasgest(b.cempres),
                       TRUNC(a.fefeadm)) BETWEEN fdesde AND fhasta
            AND pac_gestion_rec.f_recunif_list(b.nrecibo) = 0;
   BEGIN
      -- Recuperamos el tramo donde estarán los días de gestión por fecha
      vtramo_dias := NVL(f_parinstalacion_n('DIASGEST'), 0);
      -- Miramos si se trata de un recibo de Banca March o no
      vent_bm := f_parinstalacion_t('ENTIDAD_TF');

      FOR m IN cur_movrecibos LOOP
         DECLARE
            CURSOR gtias IS
               SELECT DISTINCT (cgarant) cgarant
                          FROM detrecibos
                         WHERE nrecibo = m.nrecibo;
         BEGIN
            SELECT nrecibo,
                   sseguro,
                   cempres,
                   cagente,
                   fefecto,
                   femisio,
                   ctiprec
              INTO r
              FROM recibos
             WHERE nrecibo = m.nrecibo;

            IF r.ctiprec = 0 THEN
               tiprec := 'P';
            ELSIF r.ctiprec = 3 THEN
               tiprec := 'C';
            ELSE
               tiprec := 'S';
            END IF;

            IF r.ctiprec = 9 THEN
               vsigno := -1;
            ELSE
               vsigno := 1;
            END IF;

            SELECT cramo,
                   cmodali,
                   npoliza,
                   ncertif,
                   sproduc,
                   sseguro,
                   ctipcoa   -- bug 31556/176985:NSS:19/06/2014
              INTO s
              FROM seguros
             WHERE sseguro = r.sseguro;

            FOR gtia IN gtias LOOP
               IF f_impgarant(r.nrecibo, 'COMISION', gtia.cgarant) = 0 THEN
                  pirpf := 0;
               ELSE
                  pirpf := ROUND(f_impgarant(r.nrecibo, 'IRPF', gtia.cgarant) * 100
                                 / f_impgarant(r.nrecibo, 'COMISION', gtia.cgarant),
                                 2);
               END IF;

               INSERT INTO cuadre08
                           (cdelega, cramo,
                            cmodali, cgarant, npoliza, ncertif, nrecibo,
                            sproduc, sseguro, fefecto, femision, festado, cdemision,
                            cdestado,
                            cagente,
                            prima_total,
                            prima_tarifa,
                            rec_fpago,
                            consorcio,
                            impuesto,
                            clea,
                            comision,
                            poirpf,
                            irpf,
                            liquido,
                            prima_deven,
                            com_deven,
                            ctipcoa)   -- bug 31556/176985:NSS:19/06/2014
                    VALUES (f_delegacion(r.nrecibo, r.cempres, r.cagente, r.fefecto), s.cramo,
                            s.cmodali, gtia.cgarant, s.npoliza, s.ncertif, r.nrecibo,
                            s.sproduc, s.sseguro, r.fefecto, r.femisio, m.fmovini, tiprec,
                                --incid 3407, jdomingo, 6/11/2007 (no sumar dies gestió si és extorn)
                            --    DECODE(m.ctipcob, NULL, 'R','C'),    /* CDESTADO */
                            DECODE(m.ctipcob, NULL, DECODE(r.ctiprec, 9, 'C', 'R'), 'C'),   /* CDESTADO */
                            -- R= Remesa, -- C= Cobrado
                            r.cagente,
                            vsigno
                            * ROUND(f_impgarant(r.nrecibo, 'PRIMA TOTAL', gtia.cgarant), 2),
                            vsigno
                            * ROUND(f_impgarant(r.nrecibo, 'PRIMA TARIFA', gtia.cgarant), 2),
                            vsigno
                            * ROUND(f_impgarant(r.nrecibo, 'REC FPAGO', gtia.cgarant), 2),
                            vsigno
                            * ROUND(f_impgarant(r.nrecibo, 'CONSORCIO', gtia.cgarant), 2),
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'IMPUESTO', gtia.cgarant), 2),
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'CLEA', gtia.cgarant), 2),
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'COMISION', gtia.cgarant), 2),
                            vsigno * pirpf,
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'IRPF', gtia.cgarant), 2),
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'LIQUIDO', gtia.cgarant), 2),
                            vsigno
                            * ROUND(f_impgarant(r.nrecibo, 'DEVENGADA', gtia.cgarant), 2),
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'COMDEVEN', gtia.cgarant), 2),
                            s.ctipcoa);   -- bug 31556/176985:NSS:19/06/2014
            END LOOP;
         EXCEPTION
            WHEN OTHERS THEN
               raise_application_error(-20001, 'ERROR: ' || SQLERRM);
         END;
      END LOOP;

      COMMIT;
   END p_gracuadre08;

   PROCEDURE p_gracuadre001(aaproc IN NUMBER, mmproc IN NUMBER, empresa IN NUMBER) IS
      /************************************************************************************************
         Graba en la tabla CUADRE001, todos los recibos pendientes mes anterior y emision anterior al ano
      ************************************************************************************************/
      finicial_emp   DATE := TO_DATE('0101' || aaproc, 'ddmmyyyy');
      tiprec         VARCHAR2(1);
      pirpf          NUMBER;
      vsigno         NUMBER;

      TYPE recibo IS RECORD(
         nrecibo        NUMBER,
         sseguro        NUMBER,
         cempres        NUMBER,
         cagente        NUMBER,
         fefecto        DATE,
         femisio        DATE,
         ctiprec        NUMBER
      );

      r              recibo;

      TYPE seguro IS RECORD(
         cramo          NUMBER,
         cmodali        NUMBER,
         npoliza        NUMBER,
         ncertif        NUMBER,
         sproduc        NUMBER,
         sseguro        NUMBER,
         ctipcoa        NUMBER   -- bug 31556/176985:NSS:19/06/2014
      );

      s              seguro;

      -- Bug 9383 - 09/03/2009 - RSC - CRE: Unificación de recibos
      -- Anadimos 'pac_gestion_rec.f_recunif'
      CURSOR cur_movrecibos IS
         SELECT a.nrecibo, a.fmovini
           FROM movrecibo a
          WHERE a.cestrec = 0
            AND(a.smovrec, a.nrecibo) IN(SELECT   MAX(m.smovrec), m.nrecibo
                                             FROM movrecibo m
                                            WHERE m.nrecibo IN(
                                                     SELECT DISTINCT (r2.nrecibo)
                                                                FROM movrecibo m2, recibos r2
                                                               WHERE TRUNC(m2.fefeadm) <
                                                                                       finicial
                                                                 AND m2.nrecibo = r2.nrecibo
                                                                 AND r2.cempres = empresa)
                                              AND TRUNC(m.fefeadm) < fdesde
                                         GROUP BY m.nrecibo)
            AND pac_gestion_rec.f_recunif_list(a.nrecibo) = 0;
   BEGIN
      IF empresa = 2 THEN
         finicial_emp := TO_DATE('01/04/2001', 'dd/mm/rrrr');
      ELSE
         IF empresa = 1 THEN
            finicial_emp := TO_DATE('01/01/1990', 'dd/mm/rrrr');
         END IF;
      END IF;

      FOR m IN cur_movrecibos LOOP
         DECLARE
            CURSOR gtias IS
               SELECT DISTINCT (cgarant) cgarant
                          FROM detrecibos
                         WHERE nrecibo = m.nrecibo;
         BEGIN
            SELECT nrecibo,
                   sseguro,
                   cempres,
                   cagente,
                   fefecto,
                   femisio,
                   ctiprec
              INTO r
              FROM recibos
             WHERE nrecibo = m.nrecibo;

            IF r.ctiprec = 0 THEN
               tiprec := 'P';
            ELSIF r.ctiprec = 3 THEN
               tiprec := 'C';
            ELSE
               tiprec := 'S';
            END IF;

            SELECT cramo,
                   cmodali,
                   npoliza,
                   ncertif,
                   sproduc,
                   sseguro,
                   ctipcoa   -- bug 31556/176985:NSS:19/06/2014
              INTO s
              FROM seguros
             WHERE sseguro = r.sseguro;

            IF r.ctiprec = 9 THEN
               vsigno := -1;
            ELSE
               vsigno := 1;
            END IF;

            FOR gtia IN gtias LOOP
               IF f_impgarant(r.nrecibo, 'COMISION', gtia.cgarant) = 0 THEN
                  pirpf := 0;
               ELSE
                  pirpf := ROUND(f_impgarant(r.nrecibo, 'IRPF', gtia.cgarant) * 100
                                 / f_impgarant(r.nrecibo, 'COMISION', gtia.cgarant),
                                 2);
               END IF;

               INSERT INTO cuadre001
                           (cdelega, cramo,
                            cmodali, cgarant, npoliza, ncertif, nrecibo,
                            sproduc, sseguro, fefecto, femision, festado, cdemision,
                            cdestado, cagente,
                            prima_total,
                            prima_tarifa,
                            rec_fpago,
                            consorcio,
                            impuesto,
                            clea,
                            comision,
                            poirpf,
                            irpf,
                            liquido,
                            prima_deven,
                            com_deven,
                            ctipcoa)   -- bug 31556/176985:NSS:19/06/2014
                    VALUES (f_delegacion(r.nrecibo, r.cempres, r.cagente, r.fefecto), s.cramo,
                            s.cmodali, gtia.cgarant, s.npoliza, s.ncertif, r.nrecibo,
                            s.sproduc, s.sseguro, r.fefecto, r.femisio, m.fmovini, tiprec,
                            'P',
                                /* CDESTADO */
                                r.cagente,
                            vsigno
                            * ROUND(f_impgarant(r.nrecibo, 'PRIMA TOTAL', gtia.cgarant), 2),
                            vsigno
                            * ROUND(f_impgarant(r.nrecibo, 'PRIMA TARIFA', gtia.cgarant), 2),
                            vsigno
                            * ROUND(f_impgarant(r.nrecibo, 'REC FPAGO', gtia.cgarant), 2),
                            vsigno
                            * ROUND(f_impgarant(r.nrecibo, 'CONSORCIO', gtia.cgarant), 2),
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'IMPUESTO', gtia.cgarant), 2),
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'CLEA', gtia.cgarant), 2),
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'COMISION', gtia.cgarant), 2),
                            vsigno * pirpf,
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'IRPF', gtia.cgarant), 2),
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'LIQUIDO', gtia.cgarant), 2),
                            vsigno
                            * ROUND(f_impgarant(r.nrecibo, 'DEVENGADA', gtia.cgarant), 2),
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'COMDEVEN', gtia.cgarant), 2),
                            s.ctipcoa);   -- bug 31556/176985:NSS:19/06/2014
            END LOOP;
         EXCEPTION
            WHEN OTHERS THEN
               raise_application_error(-20001, 'ERROR: ' || SQLERRM);
         END;
      END LOOP;

      COMMIT;
   END p_gracuadre001;

   PROCEDURE p_gracuadre002(aaproc IN NUMBER, mmproc IN NUMBER, empresa IN NUMBER) IS
      /************************************************************************************************
         Graba en la tabla CUADRE002, los recibos anulados en el ano anterior y que hayan sido
         cobrados, anulados o pendiente en este
      ************************************************************************************************/
      finicial_emp   DATE := TO_DATE('0101' || aaproc, 'ddmmyyyy');
      tiprec         VARCHAR2(1);
      pirpf          NUMBER;
      vsigno         NUMBER;

      TYPE recibo IS RECORD(
         nrecibo        NUMBER,
         sseguro        NUMBER,
         cempres        NUMBER,
         cagente        NUMBER,
         fefecto        DATE,
         femisio        DATE,
         ctiprec        NUMBER
      );

      r              recibo;

      TYPE seguro IS RECORD(
         cramo          NUMBER,
         cmodali        NUMBER,
         npoliza        NUMBER,
         ncertif        NUMBER,
         sproduc        NUMBER,
         sseguro        NUMBER,
         ctipcoa        NUMBER   -- bug 31556/176985:NSS:19/06/2014
      );

      s              seguro;

      -- Bug 9383 - 09/03/2009 - RSC - CRE: Unificación de recibos
      -- Anadimos 'pac_gestion_rec.f_recunif'
      CURSOR cur_movrecibos IS
         SELECT a.nrecibo, a.fmovini
           FROM movrecibo a
          WHERE a.cestant = 2
            AND(a.smovrec, a.nrecibo) IN(SELECT   MIN(m.smovrec), m.nrecibo
                                             FROM movrecibo m
                                            WHERE m.nrecibo IN(
                                                     SELECT DISTINCT (r2.nrecibo)
                                                                FROM movrecibo m2, recibos r2
                                                               WHERE TRUNC(m2.fefeadm) <
                                                                                       finicial
                                                                 AND m2.nrecibo = r2.nrecibo
                                                                 AND r2.cempres = empresa)
                                              AND TRUNC(m.fefeadm) BETWEEN fdesde AND fhasta
                                         GROUP BY m.nrecibo)
            AND NOT EXISTS(
                  SELECT 'x'
                    FROM movrecibo b
                   WHERE b.cestrec = 2
                     AND b.nrecibo = a.nrecibo
                     AND(b.smovrec, b.nrecibo) IN(
                           SELECT   MAX(m.smovrec), m.nrecibo
                               FROM movrecibo m
                              WHERE m.nrecibo IN(
                                       SELECT DISTINCT (r2.nrecibo)
                                                  FROM movrecibo m2, recibos r2
                                                 WHERE TRUNC(m2.fefeadm) < finicial
                                                   AND m2.nrecibo = r2.nrecibo
                                                   AND r2.cempres = empresa)
                                AND TRUNC(m.fefeadm) BETWEEN fdesde AND fhasta
                           GROUP BY m.nrecibo))
            AND pac_gestion_rec.f_recunif_list(a.nrecibo) = 0;
   BEGIN
      IF empresa = 2 THEN
         finicial_emp := TO_DATE('01/04/2001', 'dd/mm/rrrr');
      ELSE
         IF empresa = 1 THEN
            finicial_emp := TO_DATE('01/01/1990', 'dd/mm/rrrr');
         END IF;
      END IF;

      FOR m IN cur_movrecibos LOOP
         DECLARE
            CURSOR gtias IS
               SELECT DISTINCT (cgarant) cgarant
                          FROM detrecibos
                         WHERE nrecibo = m.nrecibo;
         BEGIN
            SELECT nrecibo,
                   sseguro,
                   cempres,
                   cagente,
                   fefecto,
                   femisio,
                   ctiprec
              INTO r
              FROM recibos
             WHERE nrecibo = m.nrecibo;

            IF r.ctiprec = 0 THEN
               tiprec := 'P';
            ELSIF r.ctiprec = 3 THEN
               tiprec := 'C';
            ELSE
               tiprec := 'S';
            END IF;

            SELECT cramo,
                   cmodali,
                   npoliza,
                   ncertif,
                   sproduc,
                   sseguro,
                   ctipcoa   -- bug 31556/176985:NSS:19/06/2014
              INTO s
              FROM seguros
             WHERE sseguro = r.sseguro;

            IF r.ctiprec = 9 THEN
               vsigno := -1;
            ELSE
               vsigno := 1;
            END IF;

            FOR gtia IN gtias LOOP
               IF f_impgarant(r.nrecibo, 'COMISION', gtia.cgarant) = 0 THEN
                  pirpf := 0;
               ELSE
                  pirpf := ROUND(f_impgarant(r.nrecibo, 'IRPF', gtia.cgarant) * 100
                                 / f_impgarant(r.nrecibo, 'COMISION', gtia.cgarant),
                                 2);
               END IF;

               INSERT INTO cuadre002
                           (cdelega, cramo,
                            cmodali, cgarant, npoliza, ncertif, nrecibo,
                            sproduc, sseguro, fefecto, femision, festado, cdemision,
                            cdestado, cagente,
                            prima_total,
                            prima_tarifa,
                            rec_fpago,
                            consorcio,
                            impuesto,
                            clea,
                            comision,
                            poirpf,
                            irpf,
                            liquido,
                            prima_deven,
                            com_deven,
                            ctipcoa)   -- bug 31556/176985:NSS:19/06/2014
                    VALUES (f_delegacion(r.nrecibo, r.cempres, r.cagente, r.fefecto), s.cramo,
                            s.cmodali, gtia.cgarant, s.npoliza, s.ncertif, r.nrecibo,
                            s.sproduc, s.sseguro, r.fefecto, r.femisio, m.fmovini, tiprec,
                            'A',
                                /* CDESTADO */
                                r.cagente,
                            vsigno
                            * ROUND(f_impgarant(r.nrecibo, 'PRIMA TOTAL', gtia.cgarant), 2),
                            vsigno
                            * ROUND(f_impgarant(r.nrecibo, 'PRIMA TARIFA', gtia.cgarant), 2),
                            vsigno
                            * ROUND(f_impgarant(r.nrecibo, 'REC FPAGO', gtia.cgarant), 2),
                            vsigno
                            * ROUND(f_impgarant(r.nrecibo, 'CONSORCIO', gtia.cgarant), 2),
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'IMPUESTO', gtia.cgarant), 2),
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'CLEA', gtia.cgarant), 2),
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'COMISION', gtia.cgarant), 2),
                            vsigno * pirpf,
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'IRPF', gtia.cgarant), 2),
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'LIQUIDO', gtia.cgarant), 2),
                            vsigno
                            * ROUND(f_impgarant(r.nrecibo, 'DEVENGADA', gtia.cgarant), 2),
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'COMDEVEN', gtia.cgarant), 2),
                            s.ctipcoa);   -- bug 31556/176985:NSS:19/06/2014
            END LOOP;
         EXCEPTION
            WHEN OTHERS THEN
               raise_application_error(-20001, 'ERROR: ' || SQLERRM);
         END;
      END LOOP;

      COMMIT;
   END p_gracuadre002;

   PROCEDURE p_gracuadre003(aaproc IN NUMBER, mmproc IN NUMBER, empresa IN NUMBER) IS
      /************************************************************************************************
         Graba en la tabla CUADRE003, los recibos emitidos en anos anteriores que se
         han devuelto en el mes del cierre
      ************************************************************************************************/
      finicial_emp   DATE := TO_DATE('0101' || aaproc, 'ddmmyyyy');
      tiprec         VARCHAR2(1);
      pirpf          NUMBER;
      vsigno         NUMBER;
      vtipcob        NUMBER;

      TYPE recibo IS RECORD(
         nrecibo        NUMBER,
         sseguro        NUMBER,
         cempres        NUMBER,
         cagente        NUMBER,
         fefecto        DATE,
         femisio        DATE,
         ctiprec        NUMBER
      );

      r              recibo;

      TYPE seguro IS RECORD(
         cramo          NUMBER,
         cmodali        NUMBER,
         npoliza        NUMBER,
         ncertif        NUMBER,
         sproduc        NUMBER,
         sseguro        NUMBER,
         ctipcoa        NUMBER   -- bug 31556/176985:NSS:19/06/2014
      );

      s              seguro;

      -- Bug 9383 - 09/03/2009 - RSC - CRE: Unificación de recibos
      -- Anadimos 'pac_gestion_rec.f_recunif'
      --BUG30050-XVM-17/02/14. Se cambia todo el cursor
      CURSOR cur_movrecibos IS
         SELECT nrecibo, cestrec, cestant, fmovini, fmovdia, fefeadm, smovrec
           FROM movrecibo a
          WHERE TRUNC(fefeadm) BETWEEN fdesde AND fhasta
            AND cestant = 1
            AND smovrec = (SELECT MIN(m.smovrec)
                             FROM movrecibo m, recibos r
                            WHERE m.nrecibo = a.nrecibo
                              AND TRUNC(m.fefeadm) BETWEEN fdesde AND fhasta
                              AND m.nrecibo = r.nrecibo
                              AND r.cempres = empresa)
            AND nrecibo IN(SELECT m2.nrecibo
                             FROM movrecibo m2, recibos r2
                            WHERE TRUNC(m2.fefeadm) < finicial
                              AND m2.cestant = 0
                              AND m2.cestrec = 0
                              AND m2.nrecibo = r2.nrecibo
                              AND r2.cempres = empresa)
            AND pac_gestion_rec.f_recunif_list(nrecibo) = 0;
   BEGIN
      IF empresa = 2 THEN
         finicial_emp := TO_DATE('01/04/2001', 'dd/mm/rrrr');
      ELSE
         IF empresa = 1 THEN
            finicial_emp := TO_DATE('01/01/1990', 'dd/mm/rrrr');
         END IF;
      END IF;

      FOR m IN cur_movrecibos LOOP
         DECLARE
            CURSOR gtias IS
               SELECT DISTINCT (cgarant) cgarant
                          FROM detrecibos
                         WHERE nrecibo = m.nrecibo;
         BEGIN
            SELECT nrecibo,
                   sseguro,
                   cempres,
                   cagente,
                   fefecto,
                   femisio,
                   ctiprec
              INTO r
              FROM recibos
             WHERE nrecibo = m.nrecibo;

            IF r.ctiprec = 0 THEN
               tiprec := 'P';
            ELSIF r.ctiprec = 3 THEN
               tiprec := 'C';
            ELSE
               tiprec := 'S';
            END IF;

            SELECT cramo,
                   cmodali,
                   npoliza,
                   ncertif,
                   sproduc,
                   sseguro,
                   ctipcoa   -- bug 31556/176985:NSS:19/06/2014
              INTO s
              FROM seguros
             WHERE sseguro = r.sseguro;

            IF r.ctiprec = 9 THEN
               vsigno := -1;
            ELSE
               vsigno := 1;
            END IF;

            -- CPM 28/10/04 Busquem el tipo de cobrament del moviment anterior
            SELECT ctipcob
              INTO vtipcob
              FROM movrecibo
             WHERE nrecibo = m.nrecibo
               AND smovrec = (SELECT MAX(smovrec)
                                FROM movrecibo
                               WHERE nrecibo = m.nrecibo
                                 AND smovrec < m.smovrec
                                 AND cestrec = 1);

            FOR gtia IN gtias LOOP
               IF f_impgarant(r.nrecibo, 'COMISION', gtia.cgarant) = 0 THEN
                  pirpf := 0;
               ELSE
                  pirpf := ROUND(f_impgarant(r.nrecibo, 'IRPF', gtia.cgarant) * 100
                                 / f_impgarant(r.nrecibo, 'COMISION', gtia.cgarant),
                                 2);
               END IF;

               INSERT INTO cuadre003
                           (cdelega, cramo,
                            cmodali, cgarant, npoliza, ncertif, nrecibo,
                            sproduc, sseguro, fefecto, femision, festado, cdemision,
                            cdestado,
                            cagente,
                            prima_total,
                            prima_tarifa,
                            rec_fpago,
                            consorcio,
                            impuesto,
                            clea,
                            comision,
                            poirpf,
                            irpf,
                            liquido,
                            prima_deven,
                            com_deven,
                            ctipcoa)   -- bug 31556/176985:NSS:19/06/2014
                    VALUES (f_delegacion(r.nrecibo, r.cempres, r.cagente, r.fefecto), s.cramo,
                            s.cmodali, gtia.cgarant, s.npoliza, s.ncertif, r.nrecibo,
                            s.sproduc, s.sseguro, r.fefecto, r.femisio, m.fmovini, tiprec,
                            --DECODE(vtipcob, NULL, 'R','C'),    /* CDESTADO */
                            --incid 3407, jdomingo, 6/11/2007 (no sumar dies gestió si és extorn)
                            DECODE(vtipcob, NULL, DECODE(r.ctiprec, 9, 'C', 'R'), 'C'),   /* CDESTADO */
                            r.cagente,
                            vsigno
                            * ROUND(f_impgarant(r.nrecibo, 'PRIMA TOTAL', gtia.cgarant), 2),
                            vsigno
                            * ROUND(f_impgarant(r.nrecibo, 'PRIMA TARIFA', gtia.cgarant), 2),
                            vsigno
                            * ROUND(f_impgarant(r.nrecibo, 'REC FPAGO', gtia.cgarant), 2),
                            vsigno
                            * ROUND(f_impgarant(r.nrecibo, 'CONSORCIO', gtia.cgarant), 2),
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'IMPUESTO', gtia.cgarant), 2),
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'CLEA', gtia.cgarant), 2),
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'COMISION', gtia.cgarant), 2),
                            vsigno * pirpf,
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'IRPF', gtia.cgarant), 2),
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'LIQUIDO', gtia.cgarant), 2),
                            vsigno
                            * ROUND(f_impgarant(r.nrecibo, 'DEVENGADA', gtia.cgarant), 2),
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'COMDEVEN', gtia.cgarant), 2),
                            s.ctipcoa);   -- bug 31556/176985:NSS:19/06/2014
            END LOOP;
         EXCEPTION
            WHEN OTHERS THEN
               raise_application_error(-20001, 'ERROR: ' || SQLERRM);
         END;
      END LOOP;

      COMMIT;
   END p_gracuadre003;

   PROCEDURE p_gracuadre004(aaproc IN NUMBER, mmproc IN NUMBER, empresa IN NUMBER) IS
      /************************************************************************************************
         Graba en la tabla CUADRE004, todos los recibos cobrados en el mes cuya emisión es del ano anterior
      ************************************************************************************************/
      finicial_emp   DATE := TO_DATE('0101' || aaproc, 'ddmmyyyy');
      tiprec         VARCHAR2(1);
      pirpf          NUMBER;
      vsigno         NUMBER;

      TYPE recibo IS RECORD(
         nrecibo        NUMBER,
         sseguro        NUMBER,
         cempres        NUMBER,
         cagente        NUMBER,
         fefecto        DATE,
         femisio        DATE,
         ctiprec        NUMBER
      );

      r              recibo;

      TYPE seguro IS RECORD(
         cramo          NUMBER,
         cmodali        NUMBER,
         npoliza        NUMBER,
         ncertif        NUMBER,
         sproduc        NUMBER,
         sseguro        NUMBER,
         ctipcoa        NUMBER   -- bug 31556/176985:NSS:19/06/2014
      );

      s              seguro;

      -- Bug 9383 - 09/03/2009 - RSC - CRE: Unificación de recibos
      -- Anadimos 'pac_gestion_rec.f_recunif'
      --BUG30050-XVM-17/02/14. Se cambia todo el cursor
      CURSOR cur_movrecibos IS
         SELECT a.nrecibo, a.cestrec, a.cestant, a.fmovini, a.fmovdia, a.fefeadm, a.ctipcob
           FROM movrecibo a, recibos r
          WHERE a.cestrec = 1
            AND r.nrecibo = a.nrecibo
            AND r.cempres = empresa
            AND a.smovrec = (SELECT MAX(m.smovrec)
                               FROM movrecibo m
                              WHERE m.nrecibo = a.nrecibo
                                AND TRUNC(m.fefeadm) BETWEEN fdesde AND fhasta)
            AND a.nrecibo IN(SELECT m2.nrecibo
                               FROM movrecibo m2
                              WHERE TRUNC(m2.fefeadm) < finicial
                                AND m2.cestant = 0
                                AND m2.cestrec = 0
                                AND m2.nrecibo = a.nrecibo)
            AND pac_gestion_rec.f_recunif_list(r.nrecibo) = 0;
   BEGIN
      IF empresa = 2 THEN
         finicial_emp := TO_DATE('01/04/2001', 'dd/mm/rrrr');
      ELSE
         IF empresa = 1 THEN
            finicial_emp := TO_DATE('01/01/1990', 'dd/mm/rrrr');
         END IF;
      END IF;

      FOR m IN cur_movrecibos LOOP
         DECLARE
            CURSOR gtias IS
               SELECT DISTINCT (cgarant) cgarant
                          FROM detrecibos
                         WHERE nrecibo = m.nrecibo;
         BEGIN
            SELECT nrecibo,
                   sseguro,
                   cempres,
                   cagente,
                   fefecto,
                   femisio,
                   ctiprec
              INTO r
              FROM recibos
             WHERE nrecibo = m.nrecibo;

            IF r.ctiprec = 0 THEN
               tiprec := 'P';
            ELSIF r.ctiprec = 3 THEN
               tiprec := 'C';
            ELSE
               tiprec := 'S';
            END IF;

            SELECT cramo,
                   cmodali,
                   npoliza,
                   ncertif,
                   sproduc,
                   sseguro,
                   ctipcoa   -- bug 31556/176985:NSS:19/06/2014
              INTO s
              FROM seguros
             WHERE sseguro = r.sseguro;

            IF r.ctiprec = 9 THEN
               vsigno := -1;
            ELSE
               vsigno := 1;
            END IF;

            FOR gtia IN gtias LOOP
               IF f_impgarant(r.nrecibo, 'COMISION', gtia.cgarant) = 0 THEN
                  pirpf := 0;
               ELSE
                  pirpf := ROUND(f_impgarant(r.nrecibo, 'IRPF', gtia.cgarant) * 100
                                 / f_impgarant(r.nrecibo, 'COMISION', gtia.cgarant),
                                 2);
               END IF;

               INSERT INTO cuadre004
                           (cdelega, cramo,
                            cmodali, cgarant, npoliza, ncertif, nrecibo,
                            sproduc, sseguro, fefecto, femision, festado, cdemision,
                            cdestado,
                            cagente,
                            prima_total,
                            prima_tarifa,
                            rec_fpago,
                            consorcio,
                            impuesto,
                            clea,
                            comision,
                            poirpf,
                            irpf,
                            liquido,
                            prima_deven,
                            com_deven,
                            ctipcoa)   -- bug 31556/176985:NSS:19/06/2014
                    VALUES (f_delegacion(r.nrecibo, r.cempres, r.cagente, r.fefecto), s.cramo,
                            s.cmodali, gtia.cgarant, s.npoliza, s.ncertif, r.nrecibo,
                            s.sproduc, s.sseguro, r.fefecto, r.femisio, m.fmovini, tiprec,
                            DECODE(m.ctipcob, NULL, DECODE(r.ctiprec, 9, 'C', 'R'), 'C'), /* CDESTADO */ -- 19 - PFA BUG 14942
                            r.cagente,
                            vsigno
                            * ROUND(f_impgarant(r.nrecibo, 'PRIMA TOTAL', gtia.cgarant), 2),
                            vsigno
                            * ROUND(f_impgarant(r.nrecibo, 'PRIMA TARIFA', gtia.cgarant), 2),
                            vsigno
                            * ROUND(f_impgarant(r.nrecibo, 'REC FPAGO', gtia.cgarant), 2),
                            vsigno
                            * ROUND(f_impgarant(r.nrecibo, 'CONSORCIO', gtia.cgarant), 2),
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'IMPUESTO', gtia.cgarant), 2),
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'CLEA', gtia.cgarant), 2),
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'COMISION', gtia.cgarant), 2),
                            vsigno * pirpf,
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'IRPF', gtia.cgarant), 2),
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'LIQUIDO', gtia.cgarant), 2),
                            vsigno
                            * ROUND(f_impgarant(r.nrecibo, 'DEVENGADA', gtia.cgarant), 2),
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'COMDEVEN', gtia.cgarant), 2),
                            s.ctipcoa);   -- bug 31556/176985:NSS:19/06/2014
            END LOOP;
         EXCEPTION
            WHEN OTHERS THEN
               raise_application_error(-20001, 'ERROR: ' || SQLERRM);
         END;
      END LOOP;

      COMMIT;
   END p_gracuadre004;

   PROCEDURE p_gracuadre005(aaproc IN NUMBER, mmproc IN NUMBER, empresa IN NUMBER) IS
      /************************************************************************************************
         Graba en la tabla CUADRE005, todos los recibos anulados en el mes, cuya emisión es del ano anterior
      ************************************************************************************************/
      finicial_emp   DATE := TO_DATE('0101' || aaproc, 'ddmmyyyy');
      tiprec         VARCHAR2(1);
      pirpf          NUMBER;
      vsigno         NUMBER;

      TYPE recibo IS RECORD(
         nrecibo        NUMBER,
         sseguro        NUMBER,
         cempres        NUMBER,
         cagente        NUMBER,
         fefecto        DATE,
         femisio        DATE,
         ctiprec        NUMBER
      );

      r              recibo;

      TYPE seguro IS RECORD(
         cramo          NUMBER,
         cmodali        NUMBER,
         npoliza        NUMBER,
         ncertif        NUMBER,
         sproduc        NUMBER,
         sseguro        NUMBER,
         ctipcoa        NUMBER   -- bug 31556/176985:NSS:19/06/2014
      );

      s              seguro;

      -- Bug 9383 - 09/03/2009 - RSC - CRE: Unificación de recibos
      -- Anadimos 'pac_gestion_rec.f_recunif'
      CURSOR cur_movrecibos IS
         SELECT a.nrecibo, a.fmovini
           FROM movrecibo a
          WHERE a.cestant IN(0, 1)
            AND(a.smovrec, a.nrecibo) IN(SELECT   MIN(m.smovrec), m.nrecibo
                                             FROM movrecibo m
                                            WHERE m.nrecibo IN(
                                                     SELECT DISTINCT (r2.nrecibo)
                                                                FROM movrecibo m2, recibos r2
                                                               WHERE TRUNC(m2.fefeadm) <
                                                                                       finicial
                                                                 AND m2.nrecibo = r2.nrecibo
                                                                 AND r2.cempres = empresa)
                                              AND TRUNC(m.fefeadm) BETWEEN fdesde AND fhasta
                                         GROUP BY m.nrecibo)
            AND EXISTS(
                  SELECT 'x'
                    FROM movrecibo b
                   WHERE b.cestrec = 2
                     AND b.nrecibo = a.nrecibo
                     AND(b.smovrec, b.nrecibo) IN(
                           SELECT   MAX(m.smovrec), m.nrecibo
                               FROM movrecibo m
                              WHERE m.nrecibo IN(
                                       SELECT DISTINCT (r2.nrecibo)
                                                  FROM movrecibo m2, recibos r2
                                                 WHERE TRUNC(m2.fefeadm) < finicial
                                                   AND m2.nrecibo = r2.nrecibo
                                                   AND r2.cempres = empresa)
                                AND TRUNC(m.fefeadm) BETWEEN fdesde AND fhasta
                           GROUP BY m.nrecibo))
            AND pac_gestion_rec.f_recunif_list(a.nrecibo) = 0;
   BEGIN
      IF empresa = 2 THEN
         finicial_emp := TO_DATE('01/04/2001', 'dd/mm/rrrr');
      ELSE
         IF empresa = 1 THEN
            finicial_emp := TO_DATE('01/01/1990', 'dd/mm/rrrr');
         END IF;
      END IF;

      FOR m IN cur_movrecibos LOOP
         DECLARE
            CURSOR gtias IS
               SELECT DISTINCT (cgarant) cgarant
                          FROM detrecibos
                         WHERE nrecibo = m.nrecibo;
         BEGIN
            SELECT nrecibo,
                   sseguro,
                   cempres,
                   cagente,
                   fefecto,
                   femisio,
                   ctiprec
              INTO r
              FROM recibos
             WHERE nrecibo = m.nrecibo;

            IF r.ctiprec = 0 THEN
               tiprec := 'P';
            ELSIF r.ctiprec = 3 THEN
               tiprec := 'C';
            ELSE
               tiprec := 'S';
            END IF;

            SELECT cramo,
                   cmodali,
                   npoliza,
                   ncertif,
                   sproduc,
                   sseguro,
                   ctipcoa   -- bug 31556/176985:NSS:19/06/2014
              INTO s
              FROM seguros
             WHERE sseguro = r.sseguro;

            IF r.ctiprec = 9 THEN
               vsigno := -1;
            ELSE
               vsigno := 1;
            END IF;

            FOR gtia IN gtias LOOP
               IF f_impgarant(r.nrecibo, 'COMISION', gtia.cgarant) = 0 THEN
                  pirpf := 0;
               ELSE
                  pirpf := ROUND(f_impgarant(r.nrecibo, 'IRPF', gtia.cgarant) * 100
                                 / f_impgarant(r.nrecibo, 'COMISION', gtia.cgarant),
                                 2);
               END IF;

               INSERT INTO cuadre005
                           (cdelega, cramo,
                            cmodali, cgarant, npoliza, ncertif, nrecibo,
                            sproduc, sseguro, fefecto, femision, festado, cdemision,
                            cdestado, cagente,
                            prima_total,
                            prima_tarifa,
                            rec_fpago,
                            consorcio,
                            impuesto,
                            clea,
                            comision,
                            poirpf,
                            irpf,
                            liquido,
                            prima_deven,
                            com_deven,
                            ctipcoa)   -- bug 31556/176985:NSS:19/06/2014
                    VALUES (f_delegacion(r.nrecibo, r.cempres, r.cagente, r.fefecto), s.cramo,
                            s.cmodali, gtia.cgarant, s.npoliza, s.ncertif, r.nrecibo,
                            s.sproduc, s.sseguro, r.fefecto, r.femisio, m.fmovini, tiprec,
                            'A',
                                /* CDESTADO */
                                r.cagente,
                            vsigno
                            * ROUND(f_impgarant(r.nrecibo, 'PRIMA TOTAL', gtia.cgarant), 2),
                            vsigno
                            * ROUND(f_impgarant(r.nrecibo, 'PRIMA TARIFA', gtia.cgarant), 2),
                            vsigno
                            * ROUND(f_impgarant(r.nrecibo, 'REC FPAGO', gtia.cgarant), 2),
                            vsigno
                            * ROUND(f_impgarant(r.nrecibo, 'CONSORCIO', gtia.cgarant), 2),
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'IMPUESTO', gtia.cgarant), 2),
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'CLEA', gtia.cgarant), 2),
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'COMISION', gtia.cgarant), 2),
                            vsigno * pirpf,
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'IRPF', gtia.cgarant), 2),
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'LIQUIDO', gtia.cgarant), 2),
                            vsigno
                            * ROUND(f_impgarant(r.nrecibo, 'DEVENGADA', gtia.cgarant), 2),
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'COMDEVEN', gtia.cgarant), 2),
                            s.ctipcoa);   -- bug 31556/176985:NSS:19/06/2014
            END LOOP;
         EXCEPTION
            WHEN OTHERS THEN
               raise_application_error(-20001, 'ERROR: ' || SQLERRM);
         END;
      END LOOP;

      COMMIT;
   END p_gracuadre005;

   PROCEDURE p_gracuadre006(aaproc IN NUMBER, mmproc IN NUMBER, empresa IN NUMBER) IS
      /************************************************************************************************
         Graba en la tabla CUADRE006, todos los recibos pendientes del mes, y emiditidos ano anterior
      ************************************************************************************************/
      finicial_emp   DATE := TO_DATE('0101' || aaproc, 'ddmmyyyy');
      tiprec         VARCHAR2(1);
      pirpf          NUMBER;
      vsigno         NUMBER;

      TYPE recibo IS RECORD(
         nrecibo        NUMBER,
         sseguro        NUMBER,
         cempres        NUMBER,
         cagente        NUMBER,
         fefecto        DATE,
         femisio        DATE,
         ctiprec        NUMBER
      );

      r              recibo;

      TYPE seguro IS RECORD(
         cramo          NUMBER,
         cmodali        NUMBER,
         npoliza        NUMBER,
         ncertif        NUMBER,
         sproduc        NUMBER,
         sseguro        NUMBER,
         ctipcoa        NUMBER   -- bug 31556/176985:NSS:19/06/2014
      );

      s              seguro;

      -- Bug 9383 - 09/03/2009 - RSC - CRE: Unificación de recibos
      -- Anadimos 'pac_gestion_rec.f_recunif'
      CURSOR cur_movrecibos IS
         SELECT a.nrecibo, a.fmovini
           FROM movrecibo a
          WHERE a.cestrec = 0
            AND(a.smovrec, a.nrecibo) IN(SELECT   MAX(m.smovrec), m.nrecibo
                                             FROM movrecibo m
                                            WHERE m.nrecibo IN(
                                                     SELECT DISTINCT (r2.nrecibo)
                                                                FROM movrecibo m2, recibos r2
                                                               WHERE TRUNC(m2.fefeadm) <
                                                                                       finicial
                                                                 AND m2.nrecibo = r2.nrecibo
                                                                 AND r2.cempres = empresa)
                                              AND TRUNC(m.fefeadm) <= fhasta
                                         GROUP BY m.nrecibo)
            AND pac_gestion_rec.f_recunif_list(a.nrecibo) = 0;
   BEGIN
      IF empresa = 2 THEN
         finicial_emp := TO_DATE('01/04/2001', 'dd/mm/rrrr');
      ELSE
         IF empresa = 1 THEN
            finicial_emp := TO_DATE('01/01/1990', 'dd/mm/rrrr');
         END IF;
      END IF;

      FOR m IN cur_movrecibos LOOP
         DECLARE
            CURSOR gtias IS
               SELECT DISTINCT (cgarant) cgarant
                          FROM detrecibos
                         WHERE nrecibo = m.nrecibo;
         BEGIN
            SELECT nrecibo,
                   sseguro,
                   cempres,
                   cagente,
                   fefecto,
                   femisio,
                   ctiprec
              INTO r
              FROM recibos
             WHERE nrecibo = m.nrecibo;

            IF r.ctiprec = 0 THEN
               tiprec := 'P';
            ELSIF r.ctiprec = 3 THEN
               tiprec := 'C';
            ELSE
               tiprec := 'S';
            END IF;

            SELECT cramo,
                   cmodali,
                   npoliza,
                   ncertif,
                   sproduc,
                   sseguro,
                   ctipcoa   -- bug 31556/176985:NSS:19/06/2014
              INTO s
              FROM seguros
             WHERE sseguro = r.sseguro;

            IF r.ctiprec = 9 THEN
               vsigno := -1;
            ELSE
               vsigno := 1;
            END IF;

            FOR gtia IN gtias LOOP
               IF f_impgarant(r.nrecibo, 'COMISION', gtia.cgarant) = 0 THEN
                  pirpf := 0;
               ELSE
                  pirpf := ROUND(f_impgarant(r.nrecibo, 'IRPF', gtia.cgarant) * 100
                                 / f_impgarant(r.nrecibo, 'COMISION', gtia.cgarant),
                                 2);
               END IF;

               INSERT INTO cuadre006
                           (cdelega, cramo,
                            cmodali, cgarant, npoliza, ncertif, nrecibo,
                            sproduc, sseguro, fefecto, femision, festado, cdemision,
                            cdestado, cagente,
                            prima_total,
                            prima_tarifa,
                            rec_fpago,
                            consorcio,
                            impuesto,
                            clea,
                            comision,
                            poirpf,
                            irpf,
                            liquido,
                            prima_deven,
                            com_deven,
                            ctipcoa)   -- bug 31556/176985:NSS:19/06/2014
                    VALUES (f_delegacion(r.nrecibo, r.cempres, r.cagente, r.fefecto), s.cramo,
                            s.cmodali, gtia.cgarant, s.npoliza, s.ncertif, r.nrecibo,
                            s.sproduc, s.sseguro, r.fefecto, r.femisio, m.fmovini, tiprec,
                            'P',
                                /* CDESTADO */
                                r.cagente,
                            vsigno
                            * ROUND(f_impgarant(r.nrecibo, 'PRIMA TOTAL', gtia.cgarant), 2),
                            vsigno
                            * ROUND(f_impgarant(r.nrecibo, 'PRIMA TARIFA', gtia.cgarant), 2),
                            vsigno
                            * ROUND(f_impgarant(r.nrecibo, 'REC FPAGO', gtia.cgarant), 2),
                            vsigno
                            * ROUND(f_impgarant(r.nrecibo, 'CONSORCIO', gtia.cgarant), 2),
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'IMPUESTO', gtia.cgarant), 2),
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'CLEA', gtia.cgarant), 2),
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'COMISION', gtia.cgarant), 2),
                            vsigno * pirpf,
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'IRPF', gtia.cgarant), 2),
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'LIQUIDO', gtia.cgarant), 2),
                            vsigno
                            * ROUND(f_impgarant(r.nrecibo, 'DEVENGADA', gtia.cgarant), 2),
                            vsigno * ROUND(f_impgarant(r.nrecibo, 'COMDEVEN', gtia.cgarant), 2),
                            s.ctipcoa);   -- bug 31556/176985:NSS:19/06/2014
            END LOOP;
         EXCEPTION
            WHEN OTHERS THEN
               raise_application_error(-20001, 'ERROR: ' || SQLERRM);
         END;
      END LOOP;

      COMMIT;
   END p_gracuadre006;

   PROCEDURE p_gracuadre_total01(aaproc IN NUMBER, mmproc IN NUMBER, empresa IN NUMBER) IS
      /************************************************************************************************
         Graba en la tabla CUADRE_TOTAL01, todos los recibos emitidos durante el ano
      ************************************************************************************************/
      fcierre_ant    DATE;
      fcierre_act    DATE;
      iprima_total   NUMBER;
      iprima_tarifa  NUMBER;
      irec_fpago     NUMBER;
      iconsorcio     NUMBER;
      iimpuesto      NUMBER;
      iclea          NUMBER;
      icomision      NUMBER;
      pirpf          NUMBER;
      iirpf          NUMBER;
      iliquido       NUMBER;
      ideven         NUMBER;
      icomdeven      NUMBER;
      vsigno         NUMBER;
      tiprec         VARCHAR2(1);

      TYPE recibo IS RECORD(
         nrecibo        NUMBER,
         sseguro        NUMBER,
         cempres        NUMBER,
         cagente        NUMBER,
         fefecto        DATE,
         femisio        DATE,
         ctiprec        NUMBER
      );

      r              recibo;

      TYPE seguro IS RECORD(
         cramo          NUMBER,
         cmodali        NUMBER,
         npoliza        NUMBER,
         ncertif        NUMBER,
         sproduc        NUMBER,
         sseguro        NUMBER
      );

      s              seguro;

      -- Bug 9383 - 09/03/2009 - RSC - CRE: Unificación de recibos
      -- Anadimos 'pac_gestion_rec.f_recunif'
      CURSOR cur_movrecibos IS
         SELECT nrecibo, cestrec, cestant, fmovini, fmovdia, fefeadm
           FROM movrecibo a
          WHERE smovrec = (SELECT MAX(smovrec)
                             FROM movrecibo
                            WHERE nrecibo = a.nrecibo)
            AND nrecibo IN(SELECT m.nrecibo
                             FROM movrecibo m, recibos r
                            WHERE TRUNC(m.fefeadm) BETWEEN finicial AND fhasta
                              AND m.cestant = 0
                              AND m.cestrec = 0
                              AND m.nrecibo = r.nrecibo
                              AND r.cempres = empresa)
            AND pac_gestion_rec.f_recunif_list(nrecibo) = 0;
   BEGIN
      BEGIN
         SELECT fproces
           INTO fcierre_ant
           FROM cierres
          WHERE cempres = empresa
            AND ctipo = 8
            AND fperini = ADD_MONTHS(TRUNC(fdesde, 'mm'), -1);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            fcierre_ant := ADD_MONTHS(TRUNC(fdesde, 'mm'), -1);
      END;

      BEGIN
         SELECT fproces
           INTO fcierre_act
           FROM cierres
          WHERE cempres = empresa
            AND ctipo = 8
            AND fperini = TRUNC(fdesde, 'mm');
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            fcierre_act := ADD_MONTHS(TRUNC(fdesde, 'mm'), -1);
      END;

      FOR m IN cur_movrecibos LOOP
         DECLARE
            CURSOR gtias(psseguro NUMBER) IS
               SELECT cgarant
                 FROM garanseg
                WHERE sseguro = psseguro;
         BEGIN
            SELECT nrecibo,
                   sseguro,
                   cempres,
                   cagente,
                   fefecto,
                   femisio,
                   ctiprec
              INTO r
              FROM recibos
             WHERE nrecibo = m.nrecibo;

            IF r.ctiprec = 0 THEN
               tiprec := 'P';
            ELSIF r.ctiprec = 3 THEN
               tiprec := 'C';
            ELSE
               tiprec := 'S';
            END IF;

            IF r.ctiprec = 9 THEN
               vsigno := -1;
            ELSE
               vsigno := 1;
            END IF;

            SELECT cramo,
                   cmodali,
                   npoliza,
                   ncertif,
                   sproduc,
                   sseguro
              INTO s
              FROM seguros
             WHERE sseguro = r.sseguro;

            BEGIN   -- lectura de importes
               SELECT vsigno * itotalr, vsigno * iprinet, vsigno * irecfra, vsigno * itotcon,
                      vsigno *(itotimp - idgs), vsigno * idgs, vsigno * icombru,
                      vsigno * icomret, vsigno *(iprinet - itotimp - icombru - icomret),
                      vsigno * ipridev, vsigno * icomdev
                 INTO iprima_total, iprima_tarifa, irec_fpago, iconsorcio,
                      iimpuesto, iclea, icomision,
                      iirpf, iliquido,
                      ideven, icomdeven
                 FROM vdetrecibos
                WHERE nrecibo = r.nrecibo;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  iprima_total := 0;
                  iprima_tarifa := 0;
                  irec_fpago := 0;
                  iconsorcio := 0;
                  iimpuesto := 0;
                  iclea := 0;
                  icomision := 0;
                  iirpf := 0;
                  iliquido := 0;
                  ideven := 0;
                  icomdeven := 0;
               WHEN OTHERS THEN
                  raise_application_error(-20101,
                                          'ERROR al leer VDETRECIBOS (' || r.nrecibo || ') '
                                          || SQLERRM);
            END;

            IF icomision = 0 THEN
               pirpf := 0;
            ELSE
               pirpf := ROUND(iirpf * 100 / icomision, 2);
            END IF;

            INSERT INTO cuadre_total01
                        (cdelega, cramo,
                         cmodali, npoliza, ncertif, nrecibo, sproduc, sseguro,
                         fefecto, femision, festado, cdemision,
                         cdestado, cagente, prima_total,
                         prima_tarifa, rec_fpago, consorcio, impuesto, clea, comision,
                         poirpf, irpf, liquido, prima_deven, com_deven)
                 VALUES (f_delegacion(r.nrecibo, r.cempres, r.cagente, r.fefecto), s.cramo,
                         s.cmodali, s.npoliza, s.ncertif, r.nrecibo, s.sproduc, s.sseguro,
                         r.fefecto, r.femisio, m.fmovini, tiprec,
                         DECODE(m.cestrec, 0, 'P', 1, 'C', 'A'),
                                                                /* CDESTADO */
                                                                r.cagente, iprima_total,
                         iprima_tarifa, irec_fpago, iconsorcio, iimpuesto, iclea, icomision,
                         pirpf, iirpf, iliquido, ideven, icomdeven);
         EXCEPTION
            WHEN OTHERS THEN
               raise_application_error(-20001, 'ERROR al grabar CUADRE_TOTAL01: ' || SQLERRM);
         END;
      END LOOP;

      COMMIT;
   END p_gracuadre_total01;

   PROCEDURE p_gracuadre_total02(aaproc IN NUMBER, mmproc IN NUMBER, empresa IN NUMBER) IS
      /************************************************************************************************
         Graba en la tabla CUADRE_TOTAL02, todos los recibos emitidos y cobrados durante el ano
      ************************************************************************************************/
      fcierre_ant    DATE;
      fcierre_act    DATE;
      iprima_total   NUMBER;
      iprima_tarifa  NUMBER;
      irec_fpago     NUMBER;
      iconsorcio     NUMBER;
      iimpuesto      NUMBER;
      iclea          NUMBER;
      icomision      NUMBER;
      pirpf          NUMBER;
      iirpf          NUMBER;
      iliquido       NUMBER;
      ideven         NUMBER;
      icomdeven      NUMBER;
      vsigno         NUMBER;
      tiprec         VARCHAR2(1);

      TYPE recibo IS RECORD(
         nrecibo        NUMBER,
         sseguro        NUMBER,
         cempres        NUMBER,
         cagente        NUMBER,
         fefecto        DATE,
         femisio        DATE,
         ctiprec        NUMBER
      );

      r              recibo;

      TYPE seguro IS RECORD(
         cramo          NUMBER,
         cmodali        NUMBER,
         npoliza        NUMBER,
         ncertif        NUMBER,
         sproduc        NUMBER,
         sseguro        NUMBER
      );

      s              seguro;

      -- Bug 9383 - 09/03/2009 - RSC - CRE: Unificación de recibos
      -- Anadimos 'pac_gestion_rec.f_recunif'
      CURSOR cur_movrecibos IS
         SELECT nrecibo, cestrec, cestant, fmovini, fmovdia, fefeadm
           FROM movrecibo a
          WHERE cestrec = 1
            AND smovrec = (SELECT MAX(m.smovrec)
                             FROM movrecibo m, recibos r
                            WHERE m.nrecibo = a.nrecibo
                              AND TRUNC(m.fefeadm) BETWEEN finicial AND fhasta
                              AND m.nrecibo = r.nrecibo
                              AND r.cempres = empresa)
            AND EXISTS(SELECT 'x'
                         FROM movrecibo m2
                        WHERE m2.nrecibo = a.nrecibo
                          AND TRUNC(m2.fefeadm) BETWEEN finicial AND fhasta
                          AND m2.cestrec = 0
                          AND m2.cestant = 0)
            AND pac_gestion_rec.f_recunif_list(nrecibo) = 0;
   BEGIN
      BEGIN
         SELECT fproces
           INTO fcierre_ant
           FROM cierres
          WHERE cempres = empresa
            AND ctipo = 8
            AND fperini = ADD_MONTHS(TRUNC(fdesde, 'mm'), -1);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            fcierre_ant := ADD_MONTHS(TRUNC(fdesde, 'mm'), -1);
      END;

      BEGIN
         SELECT fproces
           INTO fcierre_act
           FROM cierres
          WHERE cempres = empresa
            AND ctipo = 8
            AND fperini = TRUNC(fdesde, 'mm');
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            fcierre_act := ADD_MONTHS(TRUNC(fdesde, 'mm'), -1);
      END;

      FOR m IN cur_movrecibos LOOP
         DECLARE
            CURSOR gtias(psseguro NUMBER) IS
               SELECT cgarant
                 FROM garanseg
                WHERE sseguro = psseguro;
         BEGIN
            SELECT nrecibo,
                   sseguro,
                   cempres,
                   cagente,
                   fefecto,
                   femisio,
                   ctiprec
              INTO r
              FROM recibos
             WHERE nrecibo = m.nrecibo;

            IF r.ctiprec = 0 THEN
               tiprec := 'P';
            ELSIF r.ctiprec = 3 THEN
               tiprec := 'C';
            ELSE
               tiprec := 'S';
            END IF;

            IF r.ctiprec = 9 THEN
               vsigno := -1;
            ELSE
               vsigno := 1;
            END IF;

            SELECT cramo,
                   cmodali,
                   npoliza,
                   ncertif,
                   sproduc,
                   sseguro
              INTO s
              FROM seguros
             WHERE sseguro = r.sseguro;

            BEGIN   -- lectura de importes
               SELECT vsigno * itotalr, vsigno * iprinet, vsigno * irecfra, vsigno * itotcon,
                      vsigno *(itotimp - idgs), vsigno * idgs, vsigno * icombru,
                      vsigno * icomret, vsigno *(iprinet - itotimp - icombru - icomret),
                      vsigno * ipridev, vsigno * icomdev
                 INTO iprima_total, iprima_tarifa, irec_fpago, iconsorcio,
                      iimpuesto, iclea, icomision,
                      iirpf, iliquido,
                      ideven, icomdeven
                 FROM vdetrecibos
                WHERE nrecibo = r.nrecibo;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  iprima_total := 0;
                  iprima_tarifa := 0;
                  irec_fpago := 0;
                  iconsorcio := 0;
                  iimpuesto := 0;
                  iclea := 0;
                  icomision := 0;
                  iirpf := 0;
                  iliquido := 0;
                  ideven := 0;
                  icomdeven := 0;
               WHEN OTHERS THEN
                  raise_application_error(-20101,
                                          'ERROR al leer VDETRECIBOS (' || r.nrecibo || ') '
                                          || SQLERRM);
            END;

            IF icomision = 0 THEN
               pirpf := 0;
            ELSE
               pirpf := ROUND(iirpf * 100 / icomision, 2);
            END IF;

            INSERT INTO cuadre_total02
                        (cdelega, cramo,
                         cmodali, npoliza, ncertif, nrecibo, sproduc, sseguro,
                         fefecto, femision, festado, cdemision,
                         cdestado, cagente, prima_total,
                         prima_tarifa, rec_fpago, consorcio, impuesto, clea, comision,
                         poirpf, irpf, liquido, prima_deven, com_deven)
                 VALUES (f_delegacion(r.nrecibo, r.cempres, r.cagente, r.fefecto), s.cramo,
                         s.cmodali, s.npoliza, s.ncertif, r.nrecibo, s.sproduc, s.sseguro,
                         r.fefecto, r.femisio, m.fmovini, tiprec,
                         DECODE(m.cestrec, 0, 'P', 1, 'C', 'A'),
                                                                /* CDESTADO */
                                                                r.cagente, iprima_total,
                         iprima_tarifa, irec_fpago, iconsorcio, iimpuesto, iclea, icomision,
                         pirpf, iirpf, iliquido, ideven, icomdeven);
         EXCEPTION
            WHEN OTHERS THEN
               raise_application_error(-20001, 'ERROR al grabar CUADRE_TOTAL02: ' || SQLERRM);
         END;
      END LOOP;

      COMMIT;
   END p_gracuadre_total02;

   PROCEDURE p_gracuadre_total03(aaproc IN NUMBER, mmproc IN NUMBER, empresa IN NUMBER) IS
      /************************************************************************************************
         Graba en la tabla CUADRE_TOTAL03, todos los recibos anulados en el periodo
      ************************************************************************************************/
      fcierre_ant    DATE;
      fcierre_act    DATE;
      iprima_total   NUMBER;
      iprima_tarifa  NUMBER;
      irec_fpago     NUMBER;
      iconsorcio     NUMBER;
      iimpuesto      NUMBER;
      iclea          NUMBER;
      icomision      NUMBER;
      pirpf          NUMBER;
      iirpf          NUMBER;
      iliquido       NUMBER;
      ideven         NUMBER;
      icomdeven      NUMBER;
      vsigno         NUMBER;
      tiprec         VARCHAR2(1);

      TYPE recibo IS RECORD(
         nrecibo        NUMBER,
         sseguro        NUMBER,
         cempres        NUMBER,
         cagente        NUMBER,
         fefecto        DATE,
         femisio        DATE,
         ctiprec        NUMBER
      );

      r              recibo;

      TYPE seguro IS RECORD(
         cramo          NUMBER,
         cmodali        NUMBER,
         npoliza        NUMBER,
         ncertif        NUMBER,
         sproduc        NUMBER,
         sseguro        NUMBER
      );

      s              seguro;

      -- 2/2/05 CPM:Es guarden els rebuts anulats en aquest any,
      -- encara que hagin emés en un altre any.
      -- Bug 9383 - 09/03/2009 - RSC - CRE: Unificación de recibos
      -- Anadimos 'pac_gestion_rec.f_recunif'
      CURSOR cur_movrecibos IS
         SELECT nrecibo, cestrec, cestant, fmovini, fmovdia, fefeadm
           FROM movrecibo a
          WHERE cestrec = 2
            AND smovrec = (SELECT MAX(m.smovrec)
                             FROM movrecibo m, recibos r
                            WHERE m.nrecibo = a.nrecibo
                              AND TRUNC(m.fefeadm) BETWEEN finicial AND fhasta
                              AND m.nrecibo = r.nrecibo
                              AND r.cempres = empresa)
            AND EXISTS(SELECT 'x'
                         FROM movrecibo m2
                        WHERE m2.nrecibo = a.nrecibo
                          AND TRUNC(m2.fefeadm) <= fhasta
                          AND m2.cestrec = 0
                          AND m2.cestant = 0)
            AND pac_gestion_rec.f_recunif_list(nrecibo) = 0;
   BEGIN
      BEGIN
         SELECT fproces
           INTO fcierre_ant
           FROM cierres
          WHERE cempres = empresa
            AND ctipo = 8
            AND fperini = ADD_MONTHS(TRUNC(fdesde, 'mm'), -1);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            fcierre_ant := ADD_MONTHS(TRUNC(fdesde, 'mm'), -1);
      END;

      BEGIN
         SELECT fproces
           INTO fcierre_act
           FROM cierres
          WHERE cempres = empresa
            AND ctipo = 8
            AND fperini = TRUNC(fdesde, 'mm');
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            fcierre_act := ADD_MONTHS(TRUNC(fdesde, 'mm'), -1);
      END;

      FOR m IN cur_movrecibos LOOP
         DECLARE
            CURSOR gtias(psseguro NUMBER) IS
               SELECT cgarant
                 FROM garanseg
                WHERE sseguro = psseguro;
         BEGIN
            SELECT nrecibo,
                   sseguro,
                   cempres,
                   cagente,
                   fefecto,
                   femisio,
                   ctiprec
              INTO r
              FROM recibos
             WHERE nrecibo = m.nrecibo;

            IF r.ctiprec = 0 THEN
               tiprec := 'P';
            ELSIF r.ctiprec = 3 THEN
               tiprec := 'C';
            ELSE
               tiprec := 'S';
            END IF;

            IF r.ctiprec = 9 THEN
               vsigno := -1;
            ELSE
               vsigno := 1;
            END IF;

            SELECT cramo,
                   cmodali,
                   npoliza,
                   ncertif,
                   sproduc,
                   sseguro
              INTO s
              FROM seguros
             WHERE sseguro = r.sseguro;

            BEGIN   -- lectura de importes
               SELECT vsigno * itotalr, vsigno * iprinet, vsigno * irecfra, vsigno * itotcon,
                      vsigno *(itotimp - idgs), vsigno * idgs, vsigno * icombru,
                      vsigno * icomret, vsigno *(iprinet - itotimp - icombru - icomret),
                      vsigno * ipridev, vsigno * icomdev
                 INTO iprima_total, iprima_tarifa, irec_fpago, iconsorcio,
                      iimpuesto, iclea, icomision,
                      iirpf, iliquido,
                      ideven, icomdeven
                 FROM vdetrecibos
                WHERE nrecibo = r.nrecibo;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  iprima_total := 0;
                  iprima_tarifa := 0;
                  irec_fpago := 0;
                  iconsorcio := 0;
                  iimpuesto := 0;
                  iclea := 0;
                  icomision := 0;
                  iirpf := 0;
                  iliquido := 0;
                  ideven := 0;
                  icomdeven := 0;
               WHEN OTHERS THEN
                  raise_application_error(-20101,
                                          'ERROR al leer VDETRECIBOS (' || r.nrecibo || ') '
                                          || SQLERRM);
            END;

            IF icomision = 0 THEN
               pirpf := 0;
            ELSE
               pirpf := ROUND(iirpf * 100 / icomision, 2);
            END IF;

            INSERT INTO cuadre_total03
                        (cdelega, cramo,
                         cmodali, npoliza, ncertif, nrecibo, sproduc, sseguro,
                         fefecto, femision, festado, cdemision,
                         cdestado, cagente, prima_total,
                         prima_tarifa, rec_fpago, consorcio, impuesto, clea, comision,
                         poirpf, irpf, liquido, prima_deven, com_deven)
                 VALUES (f_delegacion(r.nrecibo, r.cempres, r.cagente, r.fefecto), s.cramo,
                         s.cmodali, s.npoliza, s.ncertif, r.nrecibo, s.sproduc, s.sseguro,
                         r.fefecto, r.femisio, m.fmovini, tiprec,
                         DECODE(m.cestrec, 0, 'P', 1, 'C', 'A'),
                                                                /* CDESTADO */
                                                                r.cagente, iprima_total,
                         iprima_tarifa, irec_fpago, iconsorcio, iimpuesto, iclea, icomision,
                         pirpf, iirpf, iliquido, ideven, icomdeven);
         EXCEPTION
            WHEN OTHERS THEN
               raise_application_error(-20001, 'ERROR al grabar CUADRE_TOTAL03: ' || SQLERRM);
         END;
      END LOOP;

      COMMIT;
   END p_gracuadre_total03;

   PROCEDURE p_gracuadre_total04(aaproc IN NUMBER, mmproc IN NUMBER, empresa IN NUMBER) IS
      /************************************************************************************************
         Graba en la tabla CUADRE_TOTAL04, todos los recibos pendientes en el periodo
      ************************************************************************************************/
      fcierre_ant    DATE;
      fcierre_act    DATE;
      iprima_total   NUMBER;
      iprima_tarifa  NUMBER;
      irec_fpago     NUMBER;
      iconsorcio     NUMBER;
      iimpuesto      NUMBER;
      iclea          NUMBER;
      icomision      NUMBER;
      pirpf          NUMBER;
      iirpf          NUMBER;
      iliquido       NUMBER;
      ideven         NUMBER;
      icomdeven      NUMBER;
      vsigno         NUMBER;
      tiprec         VARCHAR2(1);

      TYPE recibo IS RECORD(
         nrecibo        NUMBER,
         sseguro        NUMBER,
         cempres        NUMBER,
         cagente        NUMBER,
         fefecto        DATE,
         femisio        DATE,
         ctiprec        NUMBER
      );

      r              recibo;

      TYPE seguro IS RECORD(
         cramo          NUMBER,
         cmodali        NUMBER,
         npoliza        NUMBER,
         ncertif        NUMBER,
         sproduc        NUMBER,
         sseguro        NUMBER
      );

      s              seguro;

      -- Bug 9383 - 09/03/2009 - RSC - CRE: Unificación de recibos
      -- Anadimos 'pac_gestion_rec.f_recunif'
      CURSOR cur_movrecibos IS
         SELECT nrecibo, cestrec, cestant, fmovini, fmovdia, fefeadm
           FROM movrecibo a
          WHERE cestrec = 0
            AND smovrec = (SELECT MAX(m.smovrec)
                             FROM movrecibo m, recibos r
                            WHERE m.nrecibo = a.nrecibo
                              AND TRUNC(m.fefeadm) BETWEEN finicial AND fhasta
                              AND m.nrecibo = r.nrecibo
                              AND r.cempres = empresa)
            AND EXISTS(SELECT 'x'
                         FROM movrecibo m2
                        WHERE m2.nrecibo = a.nrecibo
                          AND TRUNC(m2.fefeadm) BETWEEN finicial AND fhasta
                          AND m2.cestrec = 0
                          AND m2.cestant = 0)
            AND pac_gestion_rec.f_recunif_list(nrecibo) = 0;
   BEGIN
      BEGIN
         SELECT fproces
           INTO fcierre_ant
           FROM cierres
          WHERE cempres = empresa
            AND ctipo = 8
            AND fperini = ADD_MONTHS(TRUNC(fdesde, 'mm'), -1);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            fcierre_ant := ADD_MONTHS(TRUNC(fdesde, 'mm'), -1);
      END;

      BEGIN
         SELECT fproces
           INTO fcierre_act
           FROM cierres
          WHERE cempres = empresa
            AND ctipo = 8
            AND fperini = TRUNC(fdesde, 'mm');
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            fcierre_act := ADD_MONTHS(TRUNC(fdesde, 'mm'), -1);
      END;

      FOR m IN cur_movrecibos LOOP
         DECLARE
            CURSOR gtias(psseguro NUMBER) IS
               SELECT cgarant
                 FROM garanseg
                WHERE sseguro = psseguro;
         BEGIN
            SELECT nrecibo,
                   sseguro,
                   cempres,
                   cagente,
                   fefecto,
                   femisio,
                   ctiprec
              INTO r
              FROM recibos
             WHERE nrecibo = m.nrecibo;

            IF r.ctiprec = 0 THEN
               tiprec := 'P';
            ELSIF r.ctiprec = 3 THEN
               tiprec := 'C';
            ELSE
               tiprec := 'S';
            END IF;

            IF r.ctiprec = 9 THEN
               vsigno := -1;
            ELSE
               vsigno := 1;
            END IF;

            SELECT cramo,
                   cmodali,
                   npoliza,
                   ncertif,
                   sproduc,
                   sseguro
              INTO s
              FROM seguros
             WHERE sseguro = r.sseguro;

            BEGIN   -- lectura de importes
               SELECT vsigno * itotalr, vsigno * iprinet, vsigno * irecfra, vsigno * itotcon,
                      vsigno *(itotimp - idgs), vsigno * idgs, vsigno * icombru,
                      vsigno * icomret, vsigno *(iprinet - itotimp - icombru - icomret),
                      vsigno * ipridev, vsigno * icomdev
                 INTO iprima_total, iprima_tarifa, irec_fpago, iconsorcio,
                      iimpuesto, iclea, icomision,
                      iirpf, iliquido,
                      ideven, icomdeven
                 FROM vdetrecibos
                WHERE nrecibo = r.nrecibo;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  iprima_total := 0;
                  iprima_tarifa := 0;
                  irec_fpago := 0;
                  iconsorcio := 0;
                  iimpuesto := 0;
                  iclea := 0;
                  icomision := 0;
                  iirpf := 0;
                  iliquido := 0;
                  ideven := 0;
                  icomdeven := 0;
               WHEN OTHERS THEN
                  raise_application_error(-20101,
                                          'ERROR al leer VDETRECIBOS (' || r.nrecibo || ') '
                                          || SQLERRM);
            END;

            IF icomision = 0 THEN
               pirpf := 0;
            ELSE
               pirpf := ROUND(iirpf * 100 / icomision, 2);
            END IF;

            INSERT INTO cuadre_total04
                        (cdelega, cramo,
                         cmodali, npoliza, ncertif, nrecibo, sproduc, sseguro,
                         fefecto, femision, festado, cdemision,
                         cdestado, cagente, prima_total,
                         prima_tarifa, rec_fpago, consorcio, impuesto, clea, comision,
                         poirpf, irpf, liquido, prima_deven, com_deven)
                 VALUES (f_delegacion(r.nrecibo, r.cempres, r.cagente, r.fefecto), s.cramo,
                         s.cmodali, s.npoliza, s.ncertif, r.nrecibo, s.sproduc, s.sseguro,
                         r.fefecto, r.femisio, m.fmovini, tiprec,
                         DECODE(m.cestrec, 0, 'P', 1, 'C', 'A'),
                                                                /* CDESTADO */
                                                                r.cagente, iprima_total,
                         iprima_tarifa, irec_fpago, iconsorcio, iimpuesto, iclea, icomision,
                         pirpf, iirpf, iliquido, ideven, icomdeven);
         EXCEPTION
            WHEN OTHERS THEN
               raise_application_error(-20001, 'ERROR al grabar CUADRE_TOTAL04: ' || SQLERRM);
         END;
      END LOOP;

      COMMIT;
   END p_gracuadre_total04;

/************************************************************************************************
   Inserta en las tablas CONTAB y DETCONTAB
************************************************************************************************/
   PROCEDURE p_contabiliza(empresa IN NUMBER, pfecha IN DATE, pnummes IN NUMBER DEFAULT 1) IS
      ----
      ----
      ----
      CURSOR c_conta IS
         SELECT m.casient, m.smodcon
           FROM modconta m
          WHERE m.cempres = empresa
            AND m.fini < pfecha
            AND(m.ffin >= pfecha
                OR m.ffin IS NULL)
            AND pnummes = 1
         UNION ALL
         SELECT m.casient, m.smodcon
           FROM modconta m
          WHERE m.cempres = empresa
            AND m.ffin IS NULL
            AND pnummes <> 1;

      CURSOR c_detconta(psmodcon NUMBER) IS
         SELECT d.nlinea, d.ccuenta, d.tcuenta, c.cgroup,
                REPLACE
                   (REPLACE
                       (REPLACE
                           (d.tscuadre || ' ' || c.tcondic
                            || 'group by Pac_Cuadre_Adm.f_LPS_pais(sseguro)'
                            || DECODE(c.cgroup, 1, ', sproduc', 2, ', sproduc'),   -- en realitat és la compania
                            '#fecha', TO_CHAR(pfecha, 'dd/mm/yyyy')),
                        '#nmes', pnummes),
                    '#ccuenta', d.ccuenta) tselec
           FROM descuenta c, detmodconta d
          WHERE c.ccuenta = d.ccuenta
            AND d.smodcon = psmodcon
            AND d.cempres = empresa;

      TYPE t_cursor IS REF CURSOR;

      c_rec          t_cursor;
      importe        NUMBER;
      producto       NUMBER;
      pais           NUMBER;
      votros         VARCHAR2(4000);   --bug 31556/176732:NSS:05/06/2014
      wtxt           VARCHAR2(32000);   --bug 31556/176861:NSS:11/07/2014
      vconta_otros   NUMBER;   -- bug 31556/176732:NSS:05/06/2014
      vtraza         NUMBER := 0;
   BEGIN
      -- Esborrem els registre ja existents
      DELETE FROM contab
            WHERE cempres = empresa
              AND fasient = pfecha;

      DELETE FROM detcontab
            WHERE cempres = empresa
              AND fasient = pfecha;

      vtraza := 1;

      -- Insertem en la taula de contabilitat
      FOR reg IN c_conta LOOP
         INSERT INTO contab
                     (cempres, nasient, fasient, casient, fvalor, fmovimi, sproces)
              VALUES (empresa, reg.smodcon, pfecha, reg.casient, pfecha, f_sysdate, 1);

         vtraza := 2;

         FOR reg_det IN c_detconta(reg.smodcon) LOOP
            --p_control_error(f_user, 'P_CONTABILIZA',
              --              ' ----  smodcon= ' || reg.smodcon || ' --nlinea = '
             --              || reg_det.nlinea || ' --casient= ' || reg.casient
              --              || ' --tselec= ' || reg_det.tselec);
            vtraza := 3;
            wtxt := reg_det.tselec;
            vtraza := 4;

            OPEN c_rec FOR reg_det.tselec;

            vtraza := 5;
            --p_control_error(f_user, 'P_CONTABILIZA',
                  --          ' ----  -- nlinea = ' || reg_det.nlinea || ' ---- '
                  --          || reg_det.tselec);

            --ini bug 31556/176732:NSS:05/06/2014
            vconta_otros :=
               NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,
                                                 'CONTA_OTROS'),
                   0);
            vtraza := 6;

            IF vconta_otros = 1 THEN
               FETCH c_rec
                INTO importe, producto, pais, votros;
            ELSE
               FETCH c_rec
                INTO importe, producto, pais;
            END IF;

            vtraza := 7;

            --fin bug 31556/176732:NSS:05/06/2014

            --p_control_error(f_user, 'P_CONTABILIZA', ' ---- ok 22!! ');
            LOOP
               IF c_rec%NOTFOUND THEN
                  EXIT;
               ELSE
                  IF importe <> 0 THEN
                     --p_control_error(f_user, 'P_CONTABILIZA',
                      --               ' ---- insertamos -- ' || reg_det.tcuenta
                       --              || ' ccuenta = ' || reg_det.ccuenta || ' importe='
                       --              || importe);
                     vtraza := 8;

                     INSERT INTO detcontab
                                 (cempres, nasient, fasient, nlinea,
                                  tasient, iasient,
                                  ccuenta,
                                  cpais, otros)   --bug 31556/176732:NSS:05/06/2014
                          VALUES (empresa, reg.smodcon, pfecha, reg_det.nlinea,
                                  reg_det.tcuenta, importe,
                                  reg_det.ccuenta
                                  || DECODE
                                       (SUBSTR(LPAD(reg_det.nlinea, 2, '0'), 1, 1),
                                        9, LPAD(producto, 15, '0'),
                                        SUBSTR
                                           (LPAD(NVL(DECODE(reg_det.cgroup,
                                                            1, f_cnvproductos_ext(producto),
                                                            producto),
                                                     '0'),
                                                 10, '0'),
                                            GREATEST
                                               (NVL
                                                   (pac_parametros.f_parempresa_n
                                                               (pac_md_common.f_get_cxtempresa,
                                                                'MIN_LONG_CTA_CONTA'),
                                                    4),
                                                LENGTH(TRIM(reg_det.ccuenta)))
                                            --bug 31556/0177801:NSS:05/06/2014
                                            - NVL(f_parinstalacion_n('LONG_CUENTA_CONTA'), 9))),
                                  pais, votros);   --bug 31556/176732:NSS:05/06/2014

                     vtraza := 9;
                  END IF;

                  --ini bug 31556/176732:NSS:05/06/2014
                  IF vconta_otros = 1 THEN
                     FETCH c_rec
                      INTO importe, producto, pais, votros;
                  ELSE
                     FETCH c_rec
                      INTO importe, producto, pais;
                  END IF;

                  vtraza := 10;
               --fin bug 31556/176732:NSS:05/06/2014
               END IF;
            END LOOP;

            CLOSE c_rec;

            vtraza := 11;
         END LOOP;
      END LOOP;
   EXCEPTION
      WHEN OTHERS THEN
         -- BUG -21546_108724- 09/02/2012 - JLTS - Cierre de posibles cursores abiertos
         IF c_rec%ISOPEN THEN
            CLOSE c_rec;
         END IF;

         p_tab_error(f_sysdate, f_user, 'pac_cuadre_Adm.p_contabiliza', vtraza,
                     'Error incontrolado', SQLERRM || ' "' || wtxt || '"');
         p_tab_error(f_sysdate, f_user, 'pac_cuadre_Adm.p_contabiliza', vtraza,
                     'Error incontrolado',
                     'importe(' || importe || ') Producto(' || producto || ') pais(' || pais
                     || ')');
   END p_contabiliza;

   PROCEDURE p_traspaso_his(empresa IN NUMBER, pfecha IN DATE) IS
-------------------------------------------------------------
-- Procediment per traspasar a les taules definitivas
-- CPM 4/2/04
-------------------------------------------------------------
      v_contab       NUMBER(1);
   BEGIN
      v_contab := f_parinstalacion_n('CONTAB_X_ASIENT');

      IF v_contab = 1 THEN
         INSERT INTO his_contab_asient
                     (nlinea, cempres, fconta, nasient, ccuenta, tdescri, debe, haber, cpais,
                      otros)
            --31556/176732:NSS:05/06/2014
            SELECT   nlinea, d.cempres, pfecha, d.nasient, d.ccuenta, c.tdescri,
                     DECODE(SIGN(SUM(DECODE(tasient, 'D', iasient, 0 - iasient))),
                            1, SUM(DECODE(tasient, 'D', iasient, 0 - iasient))) debe,
                     DECODE(SIGN(SUM(DECODE(tasient, 'H', iasient, 0 - iasient))),
                            1, SUM(DECODE(tasient, 'H', iasient, 0 - iasient))) haber,
                     d.cpais, d.otros   --31556/176732:NSS:05/06/2014
                FROM descuenta c, detcontab d
               WHERE SUBSTR(d.ccuenta, 1, LENGTH(c.ccuenta)) = c.ccuenta
                 AND d.fasient = pfecha
                 AND d.cempres = empresa
            --  WHERE SUBSTR(d.ccuenta,1,4) = DECODE (c.ccuenta, 572, 5721, 11, 1182, 51, 5182, 454, 4548, c.ccuenta)
            GROUP BY nlinea, d.cempres, d.nasient, d.ccuenta, c.tdescri, d.cpais, d.otros;   --31556/176732:NSS:05/06/2014
      ELSE
         INSERT INTO his_contable
                     (cempres, fconta, ccuenta, tdescri, debe, haber, cpais, otros)   --31556/176732:NSS:05/06/2014
            SELECT   d.cempres, pfecha, d.ccuenta, c.tdescri,
                     DECODE(SIGN(SUM(DECODE(tasient, 'D', iasient, 0 - iasient))),
                            1, SUM(DECODE(tasient, 'D', iasient, 0 - iasient))) debe,
                     DECODE(SIGN(SUM(DECODE(tasient, 'H', iasient, 0 - iasient))),
                            1, SUM(DECODE(tasient, 'H', iasient, 0 - iasient))) haber,
                     d.cpais, d.otros   --31556/176732:NSS:05/06/2014
                FROM descuenta c, detcontab d
               WHERE SUBSTR(d.ccuenta, 1, LENGTH(c.ccuenta)) = c.ccuenta
                 AND d.fasient = pfecha
                 AND d.cempres = empresa
            --  WHERE SUBSTR(d.ccuenta,1,4) = DECODE (c.ccuenta, 572, 5721, 11, 1182, 51, 5182, 454, 4548, c.ccuenta)
            GROUP BY d.cempres, d.ccuenta, c.tdescri, d.cpais, d.otros;
      --31556/176732:NSS:05/06/2014
      END IF;

         /* Bug 17179 XPL#17012011
            INSERT INTO his_cuadre01
               (SELECT pfecha, cdelega, cramo, cmodali, cgarant, npoliza, ncertif, nrecibo, sproduc,
                       sseguro, fefecto, femision, festado, cdemision, cdestado, cagente,
                       prima_total, prima_tarifa, rec_fpago, consorcio, impuesto, clea, comision,
                       poirpf, irpf, liquido, prima_deven, com_deven
                  FROM cuadre01);
      */
      INSERT INTO his_cuadre02
         (SELECT pfecha, cdelega, cramo, cmodali, cgarant, npoliza, ncertif, nrecibo, sproduc,
                 sseguro, fefecto, femision, festado, cdemision, cdestado, cagente,
                 prima_total, prima_tarifa, rec_fpago, consorcio, impuesto, clea, comision,
                 poirpf, irpf, liquido, prima_deven, com_deven,
                 ctipcoa   -- bug 31556/176985:NSS:19/06/2014
            FROM cuadre02);

--Bug 0024622 - DCG - 02/07/2012 -Ini Se descomenta
/* Bug 17179 XPL#17012011
*/
      INSERT INTO his_cuadre03
         (SELECT pfecha, cdelega, cramo, cmodali, cgarant, npoliza, ncertif, nrecibo, sproduc,
                 sseguro, fefecto, femision, festado, cdemision, cdestado, cagente,
                 prima_total, prima_tarifa, rec_fpago, consorcio, impuesto, clea, comision,
                 poirpf, irpf, liquido, prima_deven, com_deven,
                 ctipcoa   -- bug 31556/176985:NSS:19/06/2014
            FROM cuadre03);

      INSERT INTO his_cuadre04
         (SELECT pfecha, cdelega, cramo, cmodali, cgarant, npoliza, ncertif, nrecibo, sproduc,
                 sseguro, fefecto, femision, festado, cdemision, cdestado, cagente,
                 prima_total, prima_tarifa, rec_fpago, consorcio, impuesto, clea, comision,
                 poirpf, irpf, liquido, prima_deven, com_deven,
                 ctipcoa   -- bug 31556/176985:NSS:19/06/2014
            FROM cuadre04);

      INSERT INTO his_cuadre05
         (SELECT pfecha, cdelega, cramo, cmodali, cgarant, npoliza, ncertif, nrecibo, sproduc,
                 sseguro, fefecto, femision, festado, cdemision, cdestado, cagente,
                 prima_total, prima_tarifa, rec_fpago, consorcio, impuesto, clea, comision,
                 poirpf, irpf, liquido, prima_deven, com_deven,
                 ctipcoa   -- bug 31556/176985:NSS:19/06/2014
            FROM cuadre05);

      INSERT INTO his_cuadre06
         (SELECT pfecha, cdelega, cramo, cmodali, cgarant, npoliza, ncertif, nrecibo, sproduc,
                 sseguro, fefecto, femision, festado, cdemision, cdestado, cagente,
                 prima_total, prima_tarifa, rec_fpago, consorcio, impuesto, clea, comision,
                 poirpf, irpf, liquido, prima_deven, com_deven,
                 ctipcoa   -- bug 31556/176985:NSS:19/06/2014
            FROM cuadre06);

      INSERT INTO his_cuadre07
         (SELECT pfecha, cdelega, cramo, cmodali, cgarant, npoliza, ncertif, nrecibo, sproduc,
                 sseguro, fefecto, femision, festado, cdemision, cdestado, cagente,
                 prima_total, prima_tarifa, rec_fpago, consorcio, impuesto, clea, comision,
                 poirpf, irpf, liquido, prima_deven, com_deven,
                 ctipcoa   -- bug 31556/176985:NSS:19/06/2014
            FROM cuadre07);

      INSERT INTO his_cuadre08
         (SELECT pfecha, cdelega, cramo, cmodali, cgarant, npoliza, ncertif, nrecibo, sproduc,
                 sseguro, fefecto, femision, festado, cdemision, cdestado, cagente,
                 prima_total, prima_tarifa, rec_fpago, consorcio, impuesto, clea, comision,
                 poirpf, irpf, liquido, prima_deven, com_deven,
                 ctipcoa   -- bug 31556/176985:NSS:19/06/2014
            FROM cuadre08);

/* Bug 17179 XPL#17012011
      INSERT INTO his_cuadre001
         (SELECT pfecha, cdelega, cramo, cmodali, cgarant, npoliza, ncertif, nrecibo, sproduc,
                 sseguro, fefecto, femision, festado, cdemision, cdestado, cagente,
                 prima_total, prima_tarifa, rec_fpago, consorcio, impuesto, clea, comision,
                 poirpf, irpf, liquido, prima_deven, com_deven
            FROM cuadre001);
*/
--Bug 0024622 - DCG - 02/07/2012 -Ini Se descomenta
      INSERT INTO his_cuadre002
         (SELECT pfecha, cdelega, cramo, cmodali, cgarant, npoliza, ncertif, nrecibo, sproduc,
                 sseguro, fefecto, femision, festado, cdemision, cdestado, cagente,
                 prima_total, prima_tarifa, rec_fpago, consorcio, impuesto, clea, comision,
                 poirpf, irpf, liquido, prima_deven, com_deven,
                 ctipcoa   -- bug 31556/176985:NSS:19/06/2014
            FROM cuadre002);

      INSERT INTO his_cuadre003
         (SELECT pfecha, cdelega, cramo, cmodali, cgarant, npoliza, ncertif, nrecibo, sproduc,
                 sseguro, fefecto, femision, festado, cdemision, cdestado, cagente,
                 prima_total, prima_tarifa, rec_fpago, consorcio, impuesto, clea, comision,
                 poirpf, irpf, liquido, prima_deven, com_deven,
                 ctipcoa   -- bug 31556/176985:NSS:19/06/2014
            FROM cuadre003);

      INSERT INTO his_cuadre004
         (SELECT pfecha, cdelega, cramo, cmodali, cgarant, npoliza, ncertif, nrecibo, sproduc,
                 sseguro, fefecto, femision, festado, cdemision, cdestado, cagente,
                 prima_total, prima_tarifa, rec_fpago, consorcio, impuesto, clea, comision,
                 poirpf, irpf, liquido, prima_deven, com_deven,
                 ctipcoa   -- bug 31556/176985:NSS:19/06/2014
            FROM cuadre004);

      INSERT INTO his_cuadre005
         (SELECT pfecha, cdelega, cramo, cmodali, cgarant, npoliza, ncertif, nrecibo, sproduc,
                 sseguro, fefecto, femision, festado, cdemision, cdestado, cagente,
                 prima_total, prima_tarifa, rec_fpago, consorcio, impuesto, clea, comision,
                 poirpf, irpf, liquido, prima_deven, com_deven,
                 ctipcoa   -- bug 31556/176985:NSS:19/06/2014
            FROM cuadre005);

      INSERT INTO his_cuadre006
         (SELECT pfecha, cdelega, cramo, cmodali, cgarant, npoliza, ncertif, nrecibo, sproduc,
                 sseguro, fefecto, femision, festado, cdemision, cdestado, cagente,
                 prima_total, prima_tarifa, rec_fpago, consorcio, impuesto, clea, comision,
                 poirpf, irpf, liquido, prima_deven, com_deven,
                 ctipcoa   -- bug 31556/176985:NSS:19/06/2014
            FROM cuadre006);
/* Bug 17179 XPL#17012011
      INSERT INTO his_cuadre_total01
         (SELECT pfecha, cdelega, cramo, cmodali, npoliza, ncertif, nrecibo, sproduc, sseguro,
                 fefecto, femision, festado, cdemision, cdestado, cagente, prima_total,
                 prima_tarifa, rec_fpago, consorcio, impuesto, clea, comision, poirpf, irpf,
                 liquido, prima_deven, com_deven
            FROM cuadre_total01);

      INSERT INTO his_cuadre_total02
         (SELECT pfecha, cdelega, cramo, cmodali, npoliza, ncertif, nrecibo, sproduc, sseguro,
                 fefecto, femision, festado, cdemision, cdestado, cagente, prima_total,
                 prima_tarifa, rec_fpago, consorcio, impuesto, clea, comision, poirpf, irpf,
                 liquido, prima_deven, com_deven
            FROM cuadre_total02);

      INSERT INTO his_cuadre_total03
         (SELECT pfecha, cdelega, cramo, cmodali, npoliza, ncertif, nrecibo, sproduc, sseguro,
                 fefecto, femision, festado, cdemision, cdestado, cagente, prima_total,
                 prima_tarifa, rec_fpago, consorcio, impuesto, clea, comision, poirpf, irpf,
                 liquido, prima_deven, com_deven
            FROM cuadre_total03);

      INSERT INTO his_cuadre_total04
         (SELECT pfecha, cdelega, cramo, cmodali, npoliza, ncertif, nrecibo, sproduc, sseguro,
                 fefecto, femision, festado, cdemision, cdestado, cagente, prima_total,
                 prima_tarifa, rec_fpago, consorcio, impuesto, clea, comision, poirpf, irpf,
                 liquido, prima_deven, com_deven
            FROM cuadre_total04);
            */
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_cuadre_Adm.p_traspaso_his', 1,
                     'Error incontrolado', SQLERRM);
   END p_traspaso_his;

-- BUG 14942: PFA - Comptabilitat: Vida o no Vida
-------------------------------------------------------------
-- Funció que indica si una poliza es de vida o de no vida
-- Devuelv  0: no es Vida; 1: si es vida
-------------------------------------------------------------
   FUNCTION f_es_vida(psseguro IN NUMBER)
      RETURN NUMBER IS
      esvida         NUMBER;
      vccompani      NUMBER;
   BEGIN
      -- Bug 23963/125448 - 16/10/2012 - AMC
      SELECT cagrpro, ccompani
        INTO esvida, vccompani
        FROM seguros
       WHERE sseguro = psseguro;

      IF vccompani IS NOT NULL THEN
         RETURN vccompani;
      ELSE
         IF esvida IN(1, 2, 10, 11, 21) THEN
            RETURN 1;
         ELSE
            RETURN 0;
         END IF;
      END IF;
   -- Fi Bug 23963/125448 - 16/10/2012 - AMC
   END;

-- Fi BUG 14942: PFA - Comptabilitat: Vida o no Vida
   FUNCTION f_esta_cerrado(empresa IN NUMBER, pfecha IN DATE)
      RETURN NUMBER IS
-------------------------------------------------------------
-- Funció que indica si un mes està ja tancat o no
--   Retorna 0: no està tancat; 1: està tancat
-- CPM 4/2/04
--Bug.: 10576 - DCT - 21/07/09. Tener en cuenta la empresa
--                              en las tablas his_contab_asient y his_contable
-------------------------------------------------------------
      aux            NUMBER;
      v_contab       NUMBER(1);
   BEGIN
      v_contab := f_parinstalacion_n('CONTAB_X_ASIENT');

      IF v_contab = 1 THEN
         SELECT COUNT('1')
           INTO aux
           FROM his_contab_asient
          WHERE cempres = empresa
            AND fconta = pfecha;
      ELSE
         SELECT COUNT('1')
           INTO aux
           FROM his_contable
          WHERE cempres = empresa
            AND fconta = pfecha;
      END IF;

      IF aux = 0 THEN
         RETURN 0;
      ELSE
         RETURN 1;
      END IF;
   END f_esta_cerrado;

   FUNCTION f_selec_cuenta(
      pcuenta IN VARCHAR2,
      ptipo IN VARCHAR2,
      pfecha IN DATE,
      pempresa IN NUMBER DEFAULT 1,
      pactual IN NUMBER DEFAULT 0,
      pmes IN NUMBER DEFAULT 1)
      RETURN VARCHAR2 IS
-------------------------------------------------------------
-- Funció que calcula la select utilitzada per extreure la informació
--   d'una certa select
--   Retorna la select
--     PActual indica si la select es fa sobre les taules actuals del
--         CUADRE (1) o sobre l'Historic (0)
-- CPM 4/2/04
-- BUG 0008989-  11/02/2009 - dciurans (DCT)
-- BUG 0008990- 26/02/2009 --dciurans (DCT) Arreglar   f_selec_cuenta y  f_selec_cuenta_asient.
-- BUG 0010994- 08/09/2009 - DCT Modificar f_selec_cuenta y f_select_cuenta_asient
--------------------------------------------------------------------------------
      CURSOR sel IS
         SELECT   d.ccuenta, d.tcuenta,
                  UPPER(REPLACE(d.tscuadre || ' ' || c.tcondic, '#ccuenta', d.ccuenta))
                                                                                       tselec
             FROM descuenta c, detmodconta d, modconta m
            WHERE c.ccuenta = d.ccuenta
              AND c.ccuenta = pcuenta
              AND d.tcuenta = DECODE(ptipo, '1', 'D', '2', 'H', ptipo)
              AND m.smodcon = d.smodcon
              AND m.cempres = d.cempres
              AND m.cempres = pempresa
              AND m.fini < pfecha
              AND(m.ffin >= pfecha
                  OR m.ffin IS NULL)
         ORDER BY d.ccuenta, d.tcuenta;

      ttexto         VARCHAR2(32000);
      ttexto_2       VARCHAR2(32000);
      ttexto_from    VARCHAR2(32000);
      aux_pos        NUMBER;
      aux_pos_c1     NUMBER;
      aux_pos_c2     NUMBER;
      cuen_old       VARCHAR2(8) := '00';
      aux_fecha      DATE;
       --3407 jdomingo 7/11/2007
      -- s1 varchar2(200);
      aux_pos_c3     NUMBER;
      aux_pos_c4     NUMBER;
      aux_pos_c5     NUMBER;
   BEGIN
      -- p_control_error(f_user, 'F_SELECT_CUENTA ', 'ENTRAMOS ');
      FOR reg IN sel LOOP
         -- p_control_error(f_user, 'F_SELECT_CUENTA ', 'ENTRAMOS  --' || reg.tselec);
         IF cuen_old <> '00' THEN
            ttexto := ttexto || ' UNION ALL ';
         END IF;

         aux_pos := INSTR(reg.tselec, 'UNION ALL');
         aux_pos_c1 := INSTR(reg.tselec, 'CESION');
         aux_pos_c3 := INSTR(reg.tselec, 'MINUS');

--3407 jdomingo 7/11/2007 tenim en compte el cas que hi hagi un  ( a minus (b union c) )
         IF aux_pos <> 0
            AND aux_pos_c1 = 0
            AND INSTR(reg.tselec, '*') = 0
            AND aux_pos_c3 = 0   --3407 jdomingo 7/11/2007
                              THEN
            aux_pos_c1 := INSTR(reg.tselec, 'CUADRE0');
            aux_pos_c2 := INSTR(reg.tselec, 'CUADRE00');
            ttexto_from := '( Select * from ' || SUBSTR(reg.tselec, aux_pos_c1, 8)
                           || ' UNION ALL ' || 'Select * from '
                           || SUBSTR(reg.tselec, aux_pos_c2, 9) || ') ';
            aux_pos := INSTR(reg.tselec, 'FROM (');
            ttexto_from := SUBSTR(reg.tselec, 1, aux_pos + 4) || ttexto_from
                           || SUBSTR(reg.tselec, aux_pos_c2 + 10);
         ELSIF aux_pos <> 0
               AND aux_pos_c1 = 0
               AND INSTR(reg.tselec, '*') = 0
               AND aux_pos_c3 <> 0
               AND aux_pos_c3 < aux_pos THEN
            --3407 jdomingo 7/11/2007  , cas minus
            --és un cas molt concret que només es donarà durant un mes
            aux_pos_c1 := INSTR(reg.tselec, 'HIS_CUADRE0');
            aux_pos_c2 := INSTR(reg.tselec, 'HIS_CUADRE0', 1, 2);
            aux_pos_c4 := INSTR(reg.tselec, ' CUADRE0');
            aux_pos_c5 := INSTR(reg.tselec, 'WHERE', 1, 4);
            --en lloc de select *, com són taules his i no his,
            --seleccionem els camps en comú només
            ttexto_from :=
               '( ( Select CDELEGA,CRAMO,CMODALI,CGARANT,
                 NPOLIZA,NCERTIF,NRECIBO,SPRODUC,SSEGURO,FEFECTO,
                 FEMISION,FESTADO,CDEMISION,CDESTADO,CAGENTE,PRIMA_TOTAL,
                 PRIMA_TARIFA,REC_FPAGO,CONSORCIO,IMPUESTO,CLEA,COMISION,
                 POIRPF,IRPF,LIQUIDO,PRIMA_DEVEN,COM_DEVEN from '
               || SUBSTR(reg.tselec, aux_pos_c1, aux_pos_c3 - aux_pos_c1)
               || ' MINUS ( Select CDELEGA,CRAMO,CMODALI,CGARANT,
                 NPOLIZA,NCERTIF,NRECIBO,SPRODUC,SSEGURO,FEFECTO,
                 FEMISION,FESTADO,CDEMISION,CDESTADO,CAGENTE,PRIMA_TOTAL,
                 PRIMA_TARIFA,REC_FPAGO,CONSORCIO,IMPUESTO,CLEA,COMISION,
                 POIRPF,IRPF,LIQUIDO,PRIMA_DEVEN,COM_DEVEN from '
               || SUBSTR(reg.tselec, aux_pos_c2, aux_pos - aux_pos_c2)
               || ' UNION ALL Select CDELEGA,CRAMO,CMODALI,CGARANT,
                 NPOLIZA,NCERTIF,NRECIBO,SPRODUC,SSEGURO,FEFECTO,
                 FEMISION,FESTADO,CDEMISION,CDESTADO,CAGENTE,PRIMA_TOTAL,
                 PRIMA_TARIFA,REC_FPAGO,CONSORCIO,IMPUESTO,CLEA,COMISION,
                 POIRPF,IRPF,LIQUIDO,PRIMA_DEVEN,COM_DEVEN from '
               || SUBSTR(reg.tselec, aux_pos_c4, aux_pos_c5 - aux_pos_c4);
            aux_pos := INSTR(reg.tselec, 'FROM (');
            ttexto_from := SUBSTR(reg.tselec, 1, aux_pos + 4) || ttexto_from
                           || SUBSTR(reg.tselec, aux_pos_c5 - 1);
         ELSE
            aux_pos := INSTR(reg.tselec, 'FROM');
            ttexto_from := reg.tselec;
         END IF;

         --p_control_error(f_user, 'F_SELECT_CUENTA ', 'ttexto_from='||ttexto_from);
         aux_fecha := NVL(pfecha, LAST_DAY(ADD_MONTHS(f_sysdate, -1)));
         aux_pos_c1 := INSTR(reg.tselec, 'CUADRE0');

         IF pactual = 0 THEN   --Histórico
            IF aux_pos_c1 <> 0 THEN
               /*                ttexto_FROM := REPLACE (ttexto_FROM, 'CUADRE0', 'HIS_CUADRE0');
                                aux_pos_c1 := INSTR(ttexto_FROM,') WHERE');
                              ttexto_FROM := SUBSTR (ttexto_FROM, 1, aux_pos_c1 -1)||
                                          ' and fconta = TO_CHAR(aux_fecha,'dd/mm/yyyy')||
                                               SUBSTR (ttexto_FROM, aux_pos_c1);
                           ELSE
               */
               --BUG10994 - 07/09/2009 - DCT
               IF INSTR(ttexto_from, '*') = 0 THEN
                  aux_pos_c1 := INSTR(ttexto_from, 'FROM CUADRE');
                  ttexto_from := SUBSTR(ttexto_from, 1, aux_pos_c1 - 1) || ',FCONTA '
                                 || SUBSTR(ttexto_from, aux_pos_c1);
               END IF;

               --FI BUG10994 - 07/09/2009 - DCT
               ttexto_from := REPLACE(ttexto_from, 'CUADRE0', 'HIS_CUADRE0')
                              || ' and fconta = to_date(' || CHR(39)
                              || TO_CHAR(aux_fecha, 'dd/mm/yyyy') || CHR(39) || ',' || CHR(39)
                              || 'dd/mm/yyyy' || CHR(39) || ') ';
            END IF;
         END IF;

         aux_pos_c1 := INSTR(reg.tselec, '), ');
         aux_pos_c2 := INSTR(reg.tselec, 'CUADRE0');

                  -- Fem la conversió dels paràmetres variables
         --         ttexto_FROM := REPLACE (REPLACE(ttexto_FROM,'#NMES','1'), '#FECHA',
         --                        TO_CHAR(aux_fecha,'dd/mm/yyyy') );

         -- BUG 7174 - 03/04/2009 - SBG - Posem alias als sumatoris, necessari des de java.
         IF aux_pos_c2 <> 0 THEN
            ttexto_2 :=
               SUBSTR(reg.tselec, 1, aux_pos_c1 + 2)
               || ' SPRODUC, NPOLIZA, NRECIBO, SSEGURO, FEFECTO, FEMISION, FESTADO, '
               || 'Pac_Cuadre_Adm.f_LPS_pais(sseguro) PAIS, '
               || 'sum(PRIMA_TOTAL) PRIMA_TOTAL, sum(PRIMA_TARIFA) PRIMA_TARIFA, sum(REC_FPAGO) REC_FPAGO, sum(CONSORCIO) CONSORCIO, '
               || 'sum(IMPUESTO) IMPUESTO, sum(CLEA) CLEA, sum(COMISION) COMISION, sum(POIRPF) POIRPF, sum(IRPF) IRPF, '
               || 'sum(LIQUIDO) LIQUIDO, sum(PRIMA_DEVEN) PRIMA_DEVEN, sum(COM_DEVEN) COM_DEVEN '
               || SUBSTR(ttexto_from, aux_pos)
               || ' group by SPRODUC, NPOLIZA, NRECIBO, SSEGURO, FEFECTO, FEMISION, FESTADO, Pac_Cuadre_Adm.f_LPS_pais(sseguro)';
            aux_pos := INSTR(reg.tselec, 'MOVRECIBO');

            IF aux_pos <> 0 THEN
               ttexto_2 := REPLACE(ttexto_2, 'NRECIBO,', 'C.NRECIBO,');
            END IF;

            ttexto := ttexto || ttexto_2;
         ELSE
            ttexto :=
               ttexto || SUBSTR(reg.tselec, 1, aux_pos_c1 + 2)
               || ' SPRODUC,NPOLIZA,null NRECIBO,SSEGURO,FEFECTO,FEMISION,FESTADO, '
               || 'Pac_Cuadre_Adm.f_LPS_pais(sseguro) PAIS, '
               || 'sum(0) PRIMA_TOTAL, sum(0) PRIMA_TARIFA, sum(0) REC_FPAGO, sum(0) CONSORCIO, '
               || 'sum(0) IMPUESTO, sum(0) CLEA, sum(0) COMISION, sum(0) POIRPF, sum(0) IRPF, '
               || 'sum(0) LIQUIDO, sum(0) PRIMA_DEVEN, sum(0) COM_DEVEN '
               || SUBSTR(ttexto_from, aux_pos)
               || ' group by SPRODUC,NPOLIZA,SSEGURO,FEFECTO,FEMISION,FESTADO, Pac_Cuadre_Adm.f_LPS_pais(sseguro)';
         END IF;

         -- FINAL BUG 7174 - 03/04/2009 - SBG
         cuen_old := reg.ccuenta;
      END LOOP;

      -- Fem la conversió dels paràmetres variables
      ttexto := REPLACE(REPLACE(ttexto, '#NMES', pmes), '#FECHA',
                        TO_CHAR(aux_fecha, 'dd/mm/yyyy'));
      --     ttexto := ttexto ||';';
           -- p_control_error(f_user, 'F_SELEC_CUENTA. ccuenta = ' || pcuenta || 'ptipo =' || ptipo,SUBSTR(ttexto, 1, 1999));
            --p_control_error(f_user, 'F_SELEC_CUENTA. ccuenta = ' || pcuenta || 'ptipo =' || ptipo,SUBSTR(ttexto, 2000, 1999));
            --p_control_error(f_user, 'F_SELEC_CUENTA. ccuenta = ' || pcuenta || 'ptipo =' || ptipo, SUBSTR(ttexto, 4000, 1999));
            --p_control_error(f_user, 'F_SELEC_CUENTA. ccuenta = ' || pcuenta || 'ptipo =' || ptipo,SUBSTR(ttexto, 6000, 1999));
            --p_control_error(f_user, 'F_SELEC_CUENTA. ccuenta = ' || pcuenta || 'ptipo =' || ptipo,SUBSTR(ttexto, 8000, 1999));
      RETURN ttexto;
   EXCEPTION
      WHEN OTHERS THEN
         --P_control_Error( F_USER, 'F_SELEC_CUENTA', 'ERROR  =  '||SQLERRM );
         RETURN NULL;
   END f_selec_cuenta;

   FUNCTION f_selec_cuenta_asient(
      pcuenta IN VARCHAR2,
      plinea IN NUMBER,
      pasient IN NUMBER,
      ptipo IN VARCHAR2,
      pfecha IN DATE,
      pempresa IN NUMBER DEFAULT 1,
      pactual IN NUMBER DEFAULT 0)
      RETURN VARCHAR2 IS
-------------------------------------------------------------
-- Funció que calcula la select utilitzada per extreure la informació
--   d'una certa select
--   Retorna la select
--     PActual indica si la select es fa sobre les taules actuals del
--         CUADRE (1) o sobre l'Historic (0)
-- CPM 4/2/04
-------------------------------------------------------------
      CURSOR sel IS
         SELECT   d.ccuenta, d.tcuenta,
                  UPPER(REPLACE(d.tscuadre || ' ' || c.tcondic, '#ccuenta', d.ccuenta))
                                                                                       tselec
             FROM descuenta c, detmodconta d, modconta m
            WHERE c.ccuenta = d.ccuenta
              AND c.ccuenta = pcuenta
              AND d.nlinea = NVL(plinea, d.nlinea)
              AND m.smodcon = pasient
              AND d.tcuenta = DECODE(ptipo, '1', 'D', '2', 'H', ptipo)
              AND m.smodcon = d.smodcon
              AND m.cempres = d.cempres
              AND m.cempres = pempresa
              AND m.fini < pfecha
              AND(m.ffin >= pfecha
                  OR m.ffin IS NULL)
         ORDER BY d.ccuenta, d.tcuenta;

      ttexto         VARCHAR2(32000);
      ttexto_2       VARCHAR2(32000);
      ttexto_from    VARCHAR2(32000);
      aux_pos        NUMBER;
      aux_pos_c1     NUMBER;
      aux_pos_c2     NUMBER;
      cuen_old       VARCHAR2(8) := '00';
      aux_fecha      DATE;
       --3407 jdomingo 7/11/2007
      -- s1 varchar2(200);
      aux_pos_c3     NUMBER;
      aux_pos_c4     NUMBER;
      aux_pos_c5     NUMBER;
      aux_pos_gr     NUMBER;
   BEGIN
      --p_control_error(f_user, 'F_SELECT_CUENTA ', 'ENTRAMOS ');
      FOR reg IN sel LOOP
         --p_control_error(f_user, 'F_SELECT_CUENTA ', 'ENTRAMOS  --'||REG.TSELEC);
         IF cuen_old <> '00' THEN
            ttexto := ttexto || ' UNION ALL ';
         END IF;

         aux_pos := INSTR(reg.tselec, 'UNION ALL');
         aux_pos_c1 := INSTR(reg.tselec, 'CESION');
         aux_pos_c3 := INSTR(reg.tselec, 'MINUS');

--3407 jdomingo 7/11/2007 tenim en compte el cas que hi hagi un  ( a minus (b union c) )
         IF aux_pos <> 0
            AND aux_pos_c1 = 0
            AND INSTR(reg.tselec, '*') = 0
            AND aux_pos_c3 = 0   --3407 jdomingo 7/11/2007
                              THEN
            aux_pos_c1 := INSTR(reg.tselec, 'CUADRE0');
            aux_pos_c2 := INSTR(reg.tselec, 'CUADRE00');
            ttexto_from := '( Select * from ' || SUBSTR(reg.tselec, aux_pos_c1, 8)
                           || ' UNION ALL ' || 'Select * from '
                           || SUBSTR(reg.tselec, aux_pos_c2, 9) || ') ';
            aux_pos := INSTR(reg.tselec, 'FROM (');
            ttexto_from := SUBSTR(reg.tselec, 1, aux_pos + 4) || ttexto_from
                           || SUBSTR(reg.tselec, aux_pos_c2 + 10);
         ELSIF aux_pos <> 0
               AND aux_pos_c1 = 0
               AND INSTR(reg.tselec, '*') = 0
               AND aux_pos_c3 <> 0
               AND aux_pos_c3 < aux_pos THEN
            --3407 jdomingo 7/11/2007  , cas minus
            --és un cas molt concret que només es donarà durant un mes
            aux_pos_c1 := INSTR(reg.tselec, 'HIS_CUADRE0');
            aux_pos_c2 := INSTR(reg.tselec, 'HIS_CUADRE0', 1, 2);
            aux_pos_c4 := INSTR(reg.tselec, ' CUADRE0');
            aux_pos_c5 := INSTR(reg.tselec, 'WHERE', 1, 4);
            --en lloc de select *, com són taules his i no his,
            --seleccionem els camps en comú només
            ttexto_from :=
               '( ( Select CDELEGA,CRAMO,CMODALI,CGARANT,
                 NPOLIZA,NCERTIF,NRECIBO,SPRODUC,SSEGURO,FEFECTO,
                 FEMISION,FESTADO,CDEMISION,CDESTADO,CAGENTE,PRIMA_TOTAL,
                 PRIMA_TARIFA,REC_FPAGO,CONSORCIO,IMPUESTO,CLEA,COMISION,
                 POIRPF,IRPF,LIQUIDO,PRIMA_DEVEN,COM_DEVEN from '
               || SUBSTR(reg.tselec, aux_pos_c1, aux_pos_c3 - aux_pos_c1)
               || ' MINUS ( Select CDELEGA,CRAMO,CMODALI,CGARANT,
                 NPOLIZA,NCERTIF,NRECIBO,SPRODUC,SSEGURO,FEFECTO,
                 FEMISION,FESTADO,CDEMISION,CDESTADO,CAGENTE,PRIMA_TOTAL,
                 PRIMA_TARIFA,REC_FPAGO,CONSORCIO,IMPUESTO,CLEA,COMISION,
                 POIRPF,IRPF,LIQUIDO,PRIMA_DEVEN,COM_DEVEN from '
               || SUBSTR(reg.tselec, aux_pos_c2, aux_pos - aux_pos_c2)
               || ' UNION ALL Select CDELEGA,CRAMO,CMODALI,CGARANT,
                 NPOLIZA,NCERTIF,NRECIBO,SPRODUC,SSEGURO,FEFECTO,
                 FEMISION,FESTADO,CDEMISION,CDESTADO,CAGENTE,PRIMA_TOTAL,
                 PRIMA_TARIFA,REC_FPAGO,CONSORCIO,IMPUESTO,CLEA,COMISION,
                 POIRPF,IRPF,LIQUIDO,PRIMA_DEVEN,COM_DEVEN from '
               || SUBSTR(reg.tselec, aux_pos_c4, aux_pos_c5 - aux_pos_c4);
            aux_pos := INSTR(reg.tselec, 'FROM (');
            ttexto_from := SUBSTR(reg.tselec, 1, aux_pos + 4) || ttexto_from
                           || SUBSTR(reg.tselec, aux_pos_c5 - 1);
         ELSE
            aux_pos := INSTR(reg.tselec, 'FROM');
            ttexto_from := reg.tselec;
         END IF;

         aux_fecha := NVL(pfecha, LAST_DAY(ADD_MONTHS(f_sysdate, -1)));
         aux_pos_c1 := INSTR(reg.tselec, 'CUADRE0');

         IF pactual = 0 THEN   --Histórico
            IF aux_pos_c1 <> 0 THEN
               /*                ttexto_FROM := REPLACE (ttexto_FROM, 'CUADRE0', 'HIS_CUADRE0');
                                aux_pos_c1 := INSTR(ttexto_FROM,') WHERE');
                              ttexto_FROM := SUBSTR (ttexto_FROM, 1, aux_pos_c1 -1)||
                                          ' and fconta = ''||TO_CHAR(aux_fecha,'dd/mm/yyyy')||'''||
                                               SUBSTR (ttexto_FROM, aux_pos_c1);
                           ELSE
               */                                                  -- JGM --ANTES --ttexto_FROM := REPLACE (ttexto_FROM, 'CUADRE0', 'HIS_CUADRE0')||
                                         -- JGM --ANTES ' and fconta = ''||TO_CHAR(aux_fecha,'dd/mm/yyyy')||''';

               --BUG10994 - 08/09/2009 - DCT
               IF INSTR(ttexto_from, '*') = 0 THEN
                  aux_pos_c1 := INSTR(ttexto_from, 'FROM CUADRE');
                  ttexto_from := SUBSTR(ttexto_from, 1, aux_pos_c1 - 1) || ',FCONTA '
---- Bug 0024622 - DCG - 02/07/2012 -Ini creamos un espacio después de FCONTA para que no se junte con el FROM
                                 || SUBSTR(ttexto_from, aux_pos_c1);
                  aux_pos_gr := INSTR(ttexto_from, 'GROUP BY');

                  IF aux_pos_gr > 0 THEN
                     ttexto_from := SUBSTR(ttexto_from, 1, aux_pos_gr + 8) || ' FCONTA, '
                                    || SUBSTR(ttexto_from, aux_pos_gr + 8);
                  END IF;
               END IF;

               --FI BUG10994 - 08/09/2009 - DCT
               ttexto_from := REPLACE(ttexto_from, 'CUADRE0', 'HIS_CUADRE0')
                              || ' and fconta = to_date(' || CHR(39)
                              || TO_CHAR(aux_fecha, 'dd/mm/yyyy') || CHR(39) || ',' || CHR(39)
                              || 'dd/mm/yyyy' || CHR(39) || ') ';
            END IF;
         END IF;

         aux_pos_c1 := INSTR(reg.tselec, '), ');
         aux_pos_c2 := INSTR(reg.tselec, 'CUADRE0');

                  -- Fem la conversió dels paràmetres variables
         --         ttexto_FROM := REPLACE (REPLACE(ttexto_FROM,'#NMES','1'), '#FECHA',
         --                        TO_CHAR(aux_fecha,'dd/mm/yyyy') );

         -- BUG 7174 - 03/04/2009 - SBG - Posem alias als sumatoris, necessari des de java.
         IF aux_pos_c2 <> 0 THEN
            ttexto_2 :=
               SUBSTR(reg.tselec, 1, aux_pos_c1 + 2)
               || ' SPRODUC, NPOLIZA, NRECIBO, SSEGURO, FEFECTO, FEMISION, FESTADO, '
               || 'Pac_Cuadre_Adm.f_LPS_pais(sseguro) PAIS, '
               || 'sum(PRIMA_TOTAL) PRIMA_TOTAL, sum(PRIMA_TARIFA) PRIMA_TARIFA, sum(REC_FPAGO) REC_FPAGO, sum(CONSORCIO) CONSORCIO, '
               || 'sum(IMPUESTO) IMPUESTO, sum(CLEA) CLEA, sum(COMISION) COMISION, sum(POIRPF) POIRPF, sum(IRPF) IRPF, '
               || 'sum(LIQUIDO) LIQUIDO, sum(PRIMA_DEVEN) PRIMA_DEVEN, sum(COM_DEVEN) COM_DEVEN '
               || SUBSTR(ttexto_from, aux_pos)
               || ' group by SPRODUC, NPOLIZA, NRECIBO, SSEGURO, FEFECTO, FEMISION, FESTADO, Pac_Cuadre_Adm.f_LPS_pais(sseguro)';
            aux_pos := INSTR(reg.tselec, 'MOVRECIBO');

            IF aux_pos <> 0 THEN
               ttexto_2 := REPLACE(ttexto_2, 'NRECIBO,', 'C.NRECIBO,');
            END IF;

            ttexto := ttexto || ttexto_2;
         ELSE
            ttexto :=
               ttexto || SUBSTR(reg.tselec, 1, aux_pos_c1 + 2)
               || ' SPRODUC,NPOLIZA,null NRECIBO,SSEGURO,FEFECTO,FEMISION,FESTADO, '
               || 'Pac_Cuadre_Adm.f_LPS_pais(sseguro) PAIS, '
               || 'sum(0) PRIMA_TOTAL, sum(0) PRIMA_TARIFA, sum(0) REC_FPAGO, sum(0) CONSORCIO, '
               || 'sum(0) IMPUESTO, sum(0) CLEA, sum(0) COMISION, sum(0) POIRPF, sum(0) IRPF, '
               || 'sum(0) LIQUIDO, sum(0) PRIMA_DEVEN, sum(0) COM_DEVEN '
               || SUBSTR(ttexto_from, aux_pos)
               || ' group by SPRODUC,NPOLIZA,SSEGURO,FEFECTO,FEMISION,FESTADO, Pac_Cuadre_Adm.f_LPS_pais(sseguro)';
         END IF;

         -- FINAL BUG 7174 - 03/04/2009 - SBG
         cuen_old := reg.ccuenta;
      END LOOP;

      -- Fem la conversió dels paràmetres variables
      ttexto := REPLACE(REPLACE(ttexto, '#NMES', '1'), '#FECHA',
                        TO_CHAR(aux_fecha, 'dd/mm/yyyy'));
      --     ttexto := ttexto ||';';
        --P_control_Error( F_USER, 'F_SELEC_CUENTA. ccuenta = '||pcuenta||'ptipo ='||ptipo, substr(TTEXTO, 1, 1999) );
        -- P_control_Error( F_USER, 'F_SELEC_CUENTA. ccuenta = '||pcuenta||'ptipo ='||ptipo, substr(TTEXTO, 2000, 1999) );
         -- P_control_Error( F_USER, 'F_SELEC_CUENTA. ccuenta = '||pcuenta||'ptipo ='||ptipo, substr(TTEXTO, 4000, 1999) );
         --  P_control_Error( F_USER, 'F_SELEC_CUENTA. ccuenta = '||pcuenta||'ptipo ='||ptipo, substr(TTEXTO, 6000, 1999) );
      RETURN ttexto;
   EXCEPTION
      WHEN OTHERS THEN
         --P_control_Error( F_USER, 'F_SELEC_CUENTA', 'ERROR  =  '||SQLERRM );
         RETURN NULL;
   END f_selec_cuenta_asient;

-----------------------------------------------------
   FUNCTION f_contratorea(psseguro IN NUMBER, pcgarant IN NUMBER)
      RETURN NUMBER IS
-------------------------------------------------------------
-- Funció utilitzada per trobar el ple que li toca segons
--   el contracte del reaseguro
--   Retorna el ple (o límit que no es reasegura)
-- CPM 10/3/04
-------------------------------------------------------------
   BEGIN
      -- Se modificarà aquesta funció amb la crida o el càlcul corresponent
      --  quan estigui montat el Reaseguro.
      RETURN(18000);
   END f_contratorea;

   FUNCTION f_lps_pais(psseguro IN NUMBER)
      RETURN NUMBER IS
-------------------------------------------------------------
-- Funció utilitzada per trobar el pais del prenedor d'una
--   pol·lissa per contabilitat
-- CPM 23/6/05
-- DCT 3/02/2009. Optimizar Select.Utilizamos tablas personas
-- Bug10612 - 02/07/2009 - DCT (Modificar Select. Anadir filtro de visión de agente)
-------------------------------------------------------------
      xpais          NUMBER;
   BEGIN
      /*SELECT cpais
        INTO xpais
        FROM personas p, tomadores t
       WHERE nordtom = 1
         AND t.sseguro = psseguro
         AND t.sperson = p.sperson;*/
      SELECT cpais
        INTO xpais
        FROM per_detper p, tomadores t, seguros s
       WHERE t.nordtom = 1
         AND t.sseguro = psseguro
         AND s.sseguro = t.sseguro
         AND p.cagente = ff_agente_cpervisio(s.cagente, f_sysdate, s.cempres)
         --AND p.cagente = s.cagente
         AND t.sperson = p.sperson;

      IF xpais IS NULL THEN
         SELECT nvalpar
           INTO xpais
           FROM parinstalacion
          WHERE UPPER(cparame) LIKE '%PAIS%DEF%';
      END IF;

      RETURN xpais;
   EXCEPTION
      WHEN OTHERS THEN
         SELECT nvalpar
           INTO xpais
           FROM parinstalacion
          WHERE UPPER(cparame) LIKE '%PAIS%DEF%';

         RETURN xpais;   -- País por defecto
   END f_lps_pais;

   FUNCTION f_obtener_map(p_cempres IN NUMBER)
      RETURN VARCHAR2 IS
-------------------------------------------------------------
-- Funció que retorna el map a executar que fa la generació
-- del fitxer de comptabilidad.
-- SBG 28/08/2008
-------------------------------------------------------------
      v_map          VARCHAR2(10);
   BEGIN
      SELECT tvalpar
        INTO v_map
        FROM parempresas
       WHERE cempres = p_cempres
         AND cparam = 'CONTA_MAP';

      RETURN(v_map);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN(NULL);
   END f_obtener_map;

   -- 4857 jdomingo 28/2/2008 creem nou tancament procés contabilitat,
   -- seguint el model d'altres cridats per ejecutar_cierres
   PROCEDURE proceso_batch_cierre(
      pmodo IN NUMBER,   --1 previ; altres, definitiu
      pcempres IN NUMBER,
      pmoneda IN NUMBER,
      --no usat aquí; però necessitem el format per ejecutar_cierres
      pcidioma IN NUMBER,
      pfperini IN DATE,
      --no usat aquí; però necessitem el format per ejecutar_cierres
      pfperfin IN DATE,
      --la data, a partir de la qual també traurem any i mes
      pfcierre IN DATE,
      --no usat aquí; però necessitem el format per ejecutar_cierres
      pcerror OUT NUMBER,
      psproces OUT NUMBER,
      pfproces OUT DATE) IS
      num_err        NUMBER := 0;
      text_error     VARCHAR2(500) := 0;
      pnnumlin       NUMBER;
      texto          VARCHAR2(400);
      conta_err      NUMBER := 0;
      v_titulo       VARCHAR2(50);
      lany           NUMBER;
      mes            NUMBER;
   BEGIN
      IF pmodo = 1 THEN
         v_titulo := 'Proceso Cierre de Contabilidad - Previo';
      ELSE
         v_titulo := 'Proceso Cierre de Contabilidad';
      END IF;

      --Insertamos en la tabla PROCESOSCAB el registro identificativo de proceso -----
      num_err := f_procesini(f_user, pcempres, 'CIERRE_FISCAL', v_titulo, psproces);
      COMMIT;

      IF num_err <> 0 THEN
         pcerror := 1;
         conta_err := conta_err + 1;
         texto := f_axis_literales(num_err, pcidioma);
         pnnumlin := NULL;
         num_err := f_proceslin(psproces,
                                SUBSTR('Cierre fiscal: ' || texto || ' ' || text_error, 1,
                                       120),
                                0, pnnumlin);
         COMMIT;
      ELSE
         IF pac_cuadre_adm.f_esta_cerrado(pcempres, pfperfin) = 0 THEN   --la data que ens interessa és la datafin
            SELECT TO_NUMBER(TO_CHAR(pfperfin, 'yyyy'))
              INTO lany
              FROM DUAL;

            SELECT TO_NUMBER(TO_CHAR(pfperfin, 'mm'))
              INTO mes
              FROM DUAL;

            -- Carrega les taules de quadres
            pac_cuadre_adm.p_cuadre_recibos(lany, mes, pcempres);
                                            --el num de mesos el per defecte,1
            -- Carrega de les taules contables
            pac_cuadre_adm.p_contabiliza(pcempres, pfperfin);
            --el num de mesos el per defecte,1
            COMMIT;

            IF pmodo != 1 THEN   --el tancament és definitiu
               pac_cuadre_adm.p_traspaso_his(pcempres, pfperfin);
               COMMIT;
            END IF;

            pcerror := 0;
         ELSE
            pcerror := 1;
            conta_err := conta_err + 1;
            texto := f_axis_literales(107855, pcidioma);   --mes ja tancat
            pnnumlin := NULL;
            num_err := f_proceslin(psproces,
                                   SUBSTR('Cierre fiscal: ' || texto || ' ' || text_error, 1,
                                          120),
                                   0, pnnumlin);
            COMMIT;
         END IF;
      END IF;

      num_err := f_procesfin(psproces, conta_err);
      pfproces := f_sysdate;
      COMMIT;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'CIERRE CONTABILIDAD =' || psproces, NULL,
                     'when others del cierre =' || pfperfin, SQLERRM);
         pcerror := 1;
   END proceso_batch_cierre;

--------------------------------------------------------------------
----  F_ccontban: Retorna el código contable de su cobrador bancario.
----  Funció utilitzada en comptabilitat
----- 20/03/2009 DCT
---------------------------------------------------------------------
   FUNCTION f_ccontban(pnrecibo NUMBER, sproduc NUMBER, pnsinies NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      xclave         NUMBER(4);
   BEGIN
      IF pnsinies IS NOT NULL THEN
         BEGIN
            --Bug10576 - 14/07/2009 - DCT - Contabilidad: Extracción correcta del detalle de las cuentas
            SELECT b.ccontaban
              INTO xclave
              FROM remesas r, cobbancario b
             WHERE nsinies = pnsinies
               AND r.ccc = b.ncuenta
               AND r.cempres = b.cempres
               AND sremesa = (SELECT MAX(sremesa)
                                FROM remesas
                               WHERE nsinies = pnsinies);
         /*SELECT ctipban
           INTO xclave
           FROM remesas
          WHERE nsinies = pnsinies
            AND sremesa = (SELECT MAX(sremesa)
                             FROM remesas
                            WHERE nsinies = pnsinies);*/

         --FI Bug10576 - 14/07/2009 - DCT - Contabilidad: Extracción correcta del detalle de las cuentas
         EXCEPTION
            WHEN OTHERS THEN
               xclave := NULL;
         END;
      ELSE
         BEGIN
            SELECT b.ccontaban
              INTO xclave
              FROM recibos r, cobbancario b
             WHERE r.ccobban = b.ccobban
               AND r.nrecibo = pnrecibo;
         EXCEPTION
            WHEN OTHERS THEN
               xclave := NULL;
         END;
      END IF;

      IF xclave IS NULL THEN
         IF f_parinstalacion_n('ES_PRODUCTO_HOST') = 1 THEN
            xclave := TO_NUMBER(f_cnvproductos_ext(sproduc));
         ELSE
            IF f_prod_ahorro(sproduc) = 1 THEN
               xclave := 10;
            ELSE
               xclave := 15;
            END IF;
         END IF;
      END IF;

      RETURN xclave;
   END f_ccontban;

   FUNCTION f_contabiliza_diario(pcempres IN NUMBER, pfecha IN DATE)
      RETURN NUMBER IS
      v_sysdate      DATE;
      v_existecontab NUMBER;

      CURSOR c_conta IS
         -- 40 - 20/12/2013 - MMM - 0029032: LCOLF3BADM-Id. 185 - REPORTE DETALLADO CONTABILIDAD - NOTA 0161388 - Inicio
         --SELECT m.casient, m.smodcon
         SELECT m.casient, m.smodcon, m.tfunc
           -- 40 - 20/12/2013 - MMM - 0029032: LCOLF3BADM-Id. 185 - REPORTE DETALLADO CONTABILIDAD - NOTA 0161388 - Fin
         FROM   modconta m
          WHERE m.cempres = pcempres
            AND m.fini < pfecha
            AND(m.ffin >= pfecha
                OR m.ffin IS NULL)
            AND pfecha IS NOT NULL
         UNION ALL
         -- 40 - 20/12/2013 - MMM - 0029032: LCOLF3BADM-Id. 185 - REPORTE DETALLADO CONTABILIDAD - NOTA 0161388 - Inicio
         --SELECT m.casient, m.smodcon
         SELECT m.casient, m.smodcon, m.tfunc
           -- 40 - 20/12/2013 - MMM - 0029032: LCOLF3BADM-Id. 185 - REPORTE DETALLADO CONTABILIDAD - NOTA 0161388 - Fin
         FROM   modconta m
          WHERE m.cempres = pcempres
            AND m.ffin IS NULL
            AND pfecha IS NULL;

      CURSOR c_detconta(psmodcon NUMBER) IS
         SELECT d2.nlinea, d2.ccuenta, d2.claenlace, d2.tipofec, d1.tcuenta, c.cgroup,
                c.tdescri,
                          -- 29. 0025313: LCOL_F002-Ajuste Selects de Contabilidad Cambio de Ano - Inicio
                          d2.tseldia tselec
                  /*
                  'select sum(importe), coletilla, proceso, fecha, pais, descrip from ('
                  || REPLACE(REPLACE(d2.tseldia || ' '
                                     || DECODE(pfecha,
                                               NULL, 'fcontab is null',
                                               'trunc(fcontab) = to_date(''
                                               || TO_CHAR(pfecha, 'dd/mm/yyyy')
                                               || '',''dd/mm/yyyy'') '),
                                     '#fecha', TO_CHAR(pfecha, 'dd/mm/yyyy')),
                             '#ccuenta', d2.ccuenta)
                  || ' ) group by coletilla, proceso, fecha, pais, descrip' tselec
                  */
           -- 29. 0025313: LCOL_F002-Ajuste Selects de Contabilidad Cambio de Ano - Fin
         FROM   descuenta c, detmodconta d1, detmodconta_dia d2
          WHERE d1.smodcon = d2.smodcon
            AND d1.ccuenta = d2.ccuenta
            AND d1.cempres = d2.cempres
            AND d1.nlinea = d2.nlinea
            AND c.ccuenta = d1.ccuenta
            AND d1.smodcon = psmodcon
            AND d1.cempres = pcempres;

      CURSOR c_invert IS
         SELECT ccuenta, nlinea, nasient, tapunte, cpais, fefeadm, cproces, tdescri,
                fconta   --Bug 38439_219851 27/11/2015 KJSC Agregar fconta
           FROM contab_asient_dia ca
          WHERE ca.cempres = pcempres
            AND ca.fconta = NVL(pfecha, TRUNC(v_sysdate))
            AND ca.iapunte < 0;

      TYPE t_cursor IS REF CURSOR;

      c_rec          t_cursor;
      importe        NUMBER;
      producto       VARCHAR2(32000);
      pais           NUMBER;
      vproces        NUMBER;
      vfadm          DATE;
      vdescri        VARCHAR2(32000);
      maxasien       NUMBER;
      vfecha         DATE;
      v_nlong_tipodiario NUMBER;
      v_ccuenta_aux  VARCHAR2(50);
      v_nlinea_aux   NUMBER;
      -- 29. 0025313: LCOL_F002-Ajuste Selects de Contabilidad Cambio de Ano - Inicio
      vtselec        VARCHAR2(32000);
      vntraza        NUMBER := 0;

      -- 29. 0025313: LCOL_F002-Ajuste Selects de Contabilidad Cambio de Ano - Fin

      -- 35 - 21/10/2013 - MMM - 0028546: LCOL_A005-Mejorar el rendimiento de terminacion por no pago - Mejora conta diaria - Inicio
      TYPE ARRAY IS TABLE OF c_detconta%ROWTYPE;

      l_data         ARRAY;
      -- 35 - 21/10/2013 - MMM - 0028546: LCOL_A005-Mejorar el rendimiento de terminacion por no pago - Mejora conta diaria - Fin

      -- 39  - 18/12/2013 - MMM - 0029391: LCOL_PROD-Contabilidad - 0010526 IAXIS Interfaces Con Fecha Fuera Del Periodo- Funcionalidad - Inicio
      vfcierre       DATE;
      -- 39  - 18/12/2013 - MMM - 0029391: LCOL_PROD-Contabilidad - 0010526 IAXIS Interfaces Con Fecha Fuera Del Periodo- Funcionalidad - Fin

      -- 40 - 20/12/2013 - MMM - 0029032: LCOLF3BADM-Id. 185 - REPORTE DETALLADO CONTABILIDAD - NOTA 0161388 - Inicio
      vtselec_aux_conta VARCHAR2(4000);
      vaux_fecha_conta VARCHAR2(4000);
      vejecuta_conta BOOLEAN;
      vsalida_aux_conta NUMBER;
      -- 40 - 20/12/2013 - MMM - 0029032: LCOLF3BADM-Id. 185 - REPORTE DETALLADO CONTABILIDAD - NOTA 0161388 - Fin

      -- 41 - 16/01/2014 - MMM - 0029644: LCOL_F003-0010853: No se observa Amortizacion de Sobrecomisiones en las cuentas correctas - Inicio
      vaux_f_sysdate DATE;
   -- 41 - 16/01/2014 - MMM - 0029644: LCOL_F003-0010853: No se observa Amortizacion de Sobrecomisiones en las cuentas correctas - Fin
   BEGIN
      v_nlong_tipodiario := NVL(pac_parametros.f_parempresa_n(pcempres,
                                                              'LONG_TIPODIARI_CONTA'),
                                2);
      vntraza := 10;

      --Ini Bug 37097 KJSC 14/09/2015 AVISO DE CONTABILIDAD YA GENERADA.
      -- Comprobar si existe una contabilidad generada y traspasada en la fecha
      SELECT NVL(MAX(1), 0)
        INTO v_existecontab
        FROM contab_asient_dia
       WHERE cempres = pcempres
         AND fconta = pfecha
         AND ftraspaso IS NOT NULL
         AND ROWNUM = 1;

      IF v_existecontab = 1 THEN
         RETURN 9908449;
      END IF;

      --Fin Bug 37097 KJSC 14/09/2015 AVISO DE CONTABILIDAD YA GENERADA.

      -- Esborrem els registre ja existents
      IF pfecha IS NOT NULL THEN
         DELETE FROM contab_asient_dia
               WHERE cempres = pcempres
                 AND fconta = pfecha
                 AND ftraspaso IS NULL;

         v_sysdate := pfecha;
      ELSE
         v_sysdate := f_sysdate;
--RDD APLICAMOS LA FECHA AQUI PARA TENER UNA UNICA FECHA PARA MANEJAR LA CONTABILIDAD
--F_SYSDATE CAMBIARA EN ADELANTE POR V_SYSDATE
      END IF;

      -- 41 - 16/01/2014 - MMM - 0029644: LCOL_F003-0010853: No se observa Amortizacion de Sobrecomisiones en las cuentas correctas - Inicio
      -- Guardamos el F_SYSDATE del momento del inicio del proceso para ponerlo en lugar del F_SYSDATE de las consultas y así
      -- evitar problemas cuando se empieza a ejecutar la contabilidad un día y se alarga hasta el día siguiente
      vaux_f_sysdate := f_sysdate;
      -- 41 - 16/01/2014 - MMM - 0029644: LCOL_F003-0010853: No se observa Amortizacion de Sobrecomisiones en las cuentas correctas - Fin
      vntraza := 20;

      SELECT NVL(MAX(nasient), 0)
        INTO maxasien
        FROM contab_asient_dia
       WHERE fconta = NVL(pfecha, TRUNC(v_sysdate));

      vntraza := 30;

      -- 39  - 18/12/2013 - MMM - 0029391: LCOL_PROD-Contabilidad - 0010526 IAXIS Interfaces Con Fecha Fuera Del Periodo- Funcionalidad - Inicio
      SELECT TRUNC(MAX(fperfin)) + 1
        INTO vfcierre
        FROM cierres
       WHERE ctipo = 7
         AND cestado = 1
         AND TRUNC(fproces) < NVL(pfecha, TRUNC(f_sysdate));

      vntraza := 40;

      -- 39  - 18/12/2013 - MMM - 0029391: LCOL_PROD-Contabilidad - 0010526 IAXIS Interfaces Con Fecha Fuera Del Periodo- Funcionalidad - Fin
      FOR reg IN c_conta LOOP
         -- 40 - 20/12/2013 - MMM - 0029032: LCOLF3BADM-Id. 185 - REPORTE DETALLADO CONTABILIDAD - NOTA 0161388 - Inicio
         vejecuta_conta := TRUE;
         vtselec_aux_conta := reg.tfunc;
         vntraza := 50;

         -- Si no es NULL vamos a ejecutar
         IF vtselec_aux_conta IS NOT NULL THEN
            IF pfecha IS NULL THEN
               vaux_fecha_conta := ' fcontab is null';
            ELSE
               vaux_fecha_conta := ' trunc(fcontab) = to_date(' || CHR(39)
                                   || TO_CHAR(pfecha, 'dd/mm/yyyy') || CHR(39) || ','
                                   || CHR(39) || 'dd/mm/yyyy' || CHR(39) || ') ';
            END IF;   -- Del IF que mira si pfecha IS NULL

            vntraza := 60;
            vtselec_aux_conta := REPLACE(vtselec_aux_conta, '#pfecha', vaux_fecha_conta);

            BEGIN
               EXECUTE IMMEDIATE (vtselec_aux_conta)
                            INTO vsalida_aux_conta;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  -- No hay datos. No ejecutamos
                  vejecuta_conta := FALSE;
               WHEN OTHERS THEN
                  -- En cualquier otro caso, por si acaso ejecutamos
                  vejecuta_conta := TRUE;
            END;
         END IF;

         -- Del IF que mira si hay validación - vtselect_conta IS NOT NULL
         vntraza := 70;

         IF vejecuta_conta THEN
            -- 40 - 20/12/2013 - MMM - 0029032: LCOLF3BADM-Id. 185 - REPORTE DETALLADO CONTABILIDAD - NOTA 0161388 - Fin

            -- 35 - 21/10/2013 - MMM - 0028546: LCOL_A005-Mejorar el rendimiento de terminacion por no pago - Mejora conta diaria - Inicio
            --FOR reg_det IN c_detconta(reg.smodcon) LOOP
            OPEN c_detconta(reg.smodcon);

            LOOP
               FETCH c_detconta
               BULK COLLECT INTO l_data LIMIT 200;

               FOR i IN 1 .. l_data.COUNT LOOP
                  --v_ccuenta_aux := reg_det.ccuenta;
                  v_ccuenta_aux := l_data(i).ccuenta;
                  --v_nlinea_aux := reg_det.nlinea;
                  v_nlinea_aux := l_data(i).nlinea;
                  -- 29. 0025313: LCOL_F002-Ajuste Selects de Contabilidad Cambio de Ano - Inicio
                  -- Se quita del cursor el montaje del valor TSELDIA, y se hace sobre la variable vtselec,
                  -- porque puede al anadirle nuevas instrucciones puede superar los 4000 caracteres y hacer
                  -- que el cursor de un error.
                  vntraza := 100;
                  --vtselec := reg_det.tselec;
                  vtselec := l_data(i).tselec;

                  IF pfecha IS NULL THEN
                     vntraza := 110;
                     vtselec := vtselec || ' fcontab is null';
                  ELSE
                     vntraza := 120;
                     vtselec := vtselec || ' trunc(fcontab) = to_date(' || CHR(39)
                                || TO_CHAR(pfecha, 'dd/mm/yyyy') || CHR(39) || ',' || CHR(39)
                                || 'dd/mm/yyyy' || CHR(39) || ') ';
                  END IF;

                  vntraza := 130;
                  --vtselec := REPLACE(REPLACE(vtselec, '#fecha', TO_CHAR(pfecha, 'dd/mm/yyyy')),'#ccuenta', reg_det.ccuenta);
                  vtselec := REPLACE(REPLACE(vtselec, '#fecha', TO_CHAR(pfecha, 'dd/mm/yyyy')),
                                     '#ccuenta', l_data(i).ccuenta);
                  vntraza := 140;
                  -- 39  - 18/12/2013 - MMM - 0029391: LCOL_PROD-Contabilidad - 0010526 IAXIS Interfaces Con Fecha Fuera Del Periodo- Funcionalidad - Inicio
                  --vtselec := 'select sum(importe), coletilla, proceso, fecha, pais, descrip from ('|| vtselec;
                  vtselec :=
                     'select sum(importe), coletilla, proceso, greatest(fecha,to_date('''
                     || TO_CHAR(vfcierre, 'dd/mm/yyyy')
                     || ''',''dd/mm/yyyy'')) fecha,
                                     pais, descrip from ('
                     || vtselec;
                  vntraza := 150;
                  --vtselec := vtselec || ' ) group by coletilla, proceso, fecha, pais, descrip';
                  vtselec := vtselec
                             || ' ) group by coletilla, proceso, greatest(fecha,to_date('''
                             || TO_CHAR(vfcierre, 'dd/mm/yyyy')
                             || ''',''dd/mm/yyyy'')), pais, descrip';
                  vntraza := 160;
                  -- 41 - 16/01/2014 - MMM - 0029644: LCOL_F003-0010853: No se observa Amortizacion de Sobrecomisiones en las cuentas correctas - Inicio
                  vtselec := REPLACE(vtselec, 'F_SYSDATE',
                                     'to_date(''' || TO_CHAR(vaux_f_sysdate, 'dd/mm/yyyy')
                                     || ''',''dd/mm/yyyy'')');
                  vtselec := REPLACE(vtselec, 'f_sysdate',
                                     'to_date(''' || TO_CHAR(vaux_f_sysdate, 'dd/mm/yyyy')
                                     || ''',''dd/mm/yyyy'')');
                  vtselec := REPLACE(vtselec, 'F_sysdate',
                                     'to_date(''' || TO_CHAR(vaux_f_sysdate, 'dd/mm/yyyy')
                                     || ''',''dd/mm/yyyy'')');
                  vntraza := 165;

                  -- 41 - 16/01/2014 - MMM - 0029644: LCOL_F003-0010853: No se observa Amortizacion de Sobrecomisiones en las cuentas correctas - Fin

                  -- 39  - 18/12/2013 - MMM - 0029391: LCOL_PROD-Contabilidad - 0010526 IAXIS Interfaces Con Fecha Fuera Del Periodo- Funcionalidad - Fin
                  OPEN c_rec FOR vtselec;

                  vntraza := 170;

                  -- OPEN c_rec FOR reg_det.tselec;
                  -- 29. 0025313: LCOL_F002-Ajuste Selects de Contabilidad Cambio de Ano - Inicio

                  -- Insertem en la taula de contabilitat
                  FETCH c_rec
                   INTO importe, producto, vproces, vfadm, pais, vdescri;

                  LOOP
                     vntraza := 190;   -- 29. 0025313

                     IF c_rec%NOTFOUND THEN
                        EXIT;
                     ELSE
                        IF importe <> 0 THEN
                           --En ENSA las selects devuelven la fecha de administración vacía
                           vfadm := NVL(vfadm, TRUNC(f_sysdate));

                           --JGM 30/07/2008 control de nuevo campo fasiento.
                           --IF reg_det.tipofec = 1 THEN
                           IF l_data(i).tipofec = 1 THEN
                              vfecha := vfadm;
                           ELSE
                              vfecha := NVL(pfecha, TRUNC(v_sysdate));
                           END IF;

                           BEGIN
                              INSERT INTO contab_asient_dia
                                          (cempres, fconta,
                                           nasient, nlinea,
                                           ccuenta,
                                           cproces, fefeadm, cpais, tapunte, iapunte,
                                           tdescri, ftraspaso,
                                           cenlace, claveasi,
                                           tipodiario, fasiento)
                                   VALUES (pcempres, NVL(pfecha, TRUNC(v_sysdate)),
                                           reg.smodcon, l_data(i).nlinea,
                                           --reg_det.nlinea,
                                           l_data(i).ccuenta
                                           --reg_det.ccuenta
                                           || SUBSTR
                                                (LPAD(NVL(producto, '0'), 10, '0'),

                                                 --GREATEST(4, LENGTH(TRIM(reg_det.ccuenta)))
                                                 --GREATEST(4, LENGTH(TRIM(l_data(i).ccuenta)))
                                                 GREATEST
                                                    (NVL
                                                        (pac_parametros.f_parempresa_n
                                                               (pac_md_common.f_get_cxtempresa,
                                                                'MIN_LONG_CTA_CONTA'),
                                                         4),
                                                     LENGTH(TRIM(l_data(i).ccuenta)))
                                                 --bug 31556/177801:NSS:19/06/2014
                                                 - NVL
                                                      (f_parinstalacion_n('LONG_CUENTA_CONTA'),
                                                       9)),
                                           vproces, vfadm, pais,
                                                                /*reg_det.tcuenta,*/
                                                                l_data(i).tcuenta, importe,
                                           SUBSTR(vdescri,(v_nlong_tipodiario + 1)), NULL,
                                           /*reg_det.claenlace,*/
                                           l_data(i).claenlace,(reg.smodcon + maxasien),
                                           SUBSTR(vdescri, 1, v_nlong_tipodiario), vfecha);
                           EXCEPTION
                              WHEN OTHERS THEN
                                 p_tab_error(f_sysdate, f_user,
                                             'pac_contabiliza.f_contabiliza_diario', 2,
                                             'Error smodcon:' || reg.smodcon || ' nlinea:'
                                             || /*reg_det.nlinea*/ l_data(i).nlinea
                                             || ' cproces:' || vproces,
                                             SQLERRM);
                                 ROLLBACK;
                                 RETURN 1;
                           END;
                        END IF;

                        FETCH c_rec
                         INTO importe, producto, vproces, vfadm, pais, vdescri;
                     END IF;
                  END LOOP;

                  CLOSE c_rec;
               END LOOP;

               EXIT WHEN c_detconta%NOTFOUND;
            END LOOP;

            CLOSE c_detconta;
         -- 40 - 20/12/2013 - MMM - 0029032: LCOLF3BADM-Id. 185 - REPORTE DETALLADO CONTABILIDAD - NOTA 0161388 - Inicio
         END IF;
      -- Del IF que mira si se ha de ejecutar la contabilidad - vejecuta_conta
      -- 40 - 20/12/2013 - MMM - 0029032: LCOLF3BADM-Id. 185 - REPORTE DETALLADO CONTABILIDAD - NOTA 0161388 - Fin

      -- 35 - 21/10/2013 - MMM - 0028546: LCOL_A005-Mejorar el rendimiento de terminacion por no pago - Mejora conta diaria - Fin
      END LOOP;

      IF pfecha IS NULL THEN   -- Actualizamos la fecha contable
         UPDATE movrecibo
            SET fcontab = TRUNC(v_sysdate)
          WHERE fcontab IS NULL;

         UPDATE ctacoaseguro   --rdd bug comentario 25872/138421
            SET fcontab = TRUNC(v_sysdate)
          WHERE fcontab IS NULL;

         IF NVL(pac_parametros.f_parempresa_n(pcempres, 'MODULO_SINI'), 0) = 0 THEN
            UPDATE pagosinitrami
               SET fcontab = TRUNC(v_sysdate)
             WHERE fcontab IS NULL;
         ELSE
            UPDATE sin_tramita_reserva
               SET fcontab = TRUNC(v_sysdate)
             WHERE fcontab IS NULL;

            UPDATE sin_tramita_movpago
               SET fcontab = TRUNC(v_sysdate)
             WHERE fcontab IS NULL;
         END IF;

         -- Bug 17406 - APD - 15/02/2011 - se debe actualizar la fecha contable
         UPDATE movpagren
            SET fcontab = TRUNC(v_sysdate)
          WHERE fcontab IS NULL;

         -- Fin Bug 17406 - APD - 15/02/2011

         --bug.: 19942 - ICV - 29/12/2011
         UPDATE liquidacab
            SET fcontab = TRUNC(v_sysdate)
          WHERE fcontab IS NULL;

         UPDATE prestamos
            SET fcontab = TRUNC(v_sysdate)
          WHERE fcontab IS NULL;

         UPDATE prestamopago
            SET fcontab = TRUNC(v_sysdate)
          WHERE fcontab IS NULL;

         UPDATE prestamocuotas
            SET fcontab = TRUNC(v_sysdate)
          WHERE fcontab IS NULL;

         --fi bug.: 19942
         -- Bug 0022855 - DCG - 02/07/2012 -Ini
         UPDATE prestcuadro
            SET fcontab = TRUNC(v_sysdate)
          WHERE fcontab IS NULL;

         -- Bug 0022855 - DCG - 02/07/2012 -Fi
         -- Bug 0024079 - DCG - 31/10/2012 -Ini
         UPDATE mov_prestamos
            SET fcontab = TRUNC(v_sysdate)
          WHERE fcontab IS NULL;

         -- Bug 0024079 - DCG - 31/10/2012 -Fi
            -- Bug 0026422 - DCG - 16/04/2013 -Ini
         UPDATE detmovrecibo
            SET fcontab = TRUNC(v_sysdate)
          WHERE fcontab IS NULL;

         UPDATE cajamov
            SET fcontab = TRUNC(v_sysdate)
          WHERE fcontab IS NULL;

         -- Bug 0026422 - DCG - 16/04/2013 -Fi
         -- Bug 0027015 - DCG - 20/11/2013 -Ini
         UPDATE pagos_masivos_sobrante
            SET fcontab = TRUNC(v_sysdate)
          WHERE fcontab IS NULL;

         -- Bug 0027015 - DCG - 20/11/2013 -Fi
         UPDATE liquidacab
            SET fcontab = TRUNC(v_sysdate)
          WHERE fcontab IS NULL;

         UPDATE movctatecnica
            SET fcontab = TRUNC(v_sysdate)
          WHERE fcontab IS NULL;

         -- 41 - 16/01/2014 - MMM - 0029644: LCOL_F003-0010853: No se observa Amortizacion de Sobrecomisiones en las cuentas correctas - Inicio
         UPDATE ctrl_provis
            SET fcontab = TRUNC(v_sysdate)
          WHERE fcontab IS NULL;
      -- 41 - 16/01/2014 - MMM - 0029644: LCOL_F003-0010853: No se observa Amortizacion de Sobrecomisiones en las cuentas correctas - Fin

         UPDATE cierres
            SET fcontab = TRUNC(v_sysdate)
          WHERE fcontab IS NULL;

      END IF;

      --Control para invertir el tapunte
      IF NVL(pac_parametros.f_parempresa_n(pcempres, 'INVERT_APUNTE_CONTA'), 0) = 1 THEN
         FOR rc IN c_invert LOOP
            UPDATE contab_asient_dia
               SET tapunte = DECODE(tapunte, 'H', 'D', 'H'),
                   iapunte = ABS(iapunte)
             WHERE cempres = pcempres
               AND nasient = rc.nasient
               AND ccuenta = rc.ccuenta
               AND nlinea = rc.nlinea
               AND tapunte = rc.tapunte
               AND cpais = rc.cpais
               AND fefeadm = rc.fefeadm
               AND cproces = rc.cproces
               AND tdescri = rc.tdescri
               AND fconta = rc.fconta;   --Bug 38439_219851 27/11/2015 KJSC Agregar fconta
         END LOOP;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         -- BUG -21546_108724- 09/02/2012 - JLTS - Cierre de posibles cursores abiertos
         IF c_rec%ISOPEN THEN
            CLOSE c_rec;
         END IF;

         p_tab_error(f_sysdate, f_user, 'pac_contabiliza.f_contabiliza_diario',
                     -- 1,     -- 29. 0025313 (-)
                     vntraza,   -- 29. 0025313 (+)
                     'Error incontrolado en CCUENTA : ' || v_ccuenta_aux || ' NLINEA : '
                     || v_nlinea_aux,
                     SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_contabiliza_diario;

-- Bug 0014782 - JMF - 03/09/2010
/*************************************************************************
  Función que busca selects dinámicas para detalle contabilidad diaria
  param in p_cempres   : Código empresa
  param in p_fcontab   : Fecha contabilidad
  retorna 0 si ha ido bien, 1 en casos contrario
  *************************************************************************/
   FUNCTION f_contabiliza_detallediario(
      p_cempres IN NUMBER,
      p_fcontab IN DATE,
      p_ccuenta IN VARCHAR2,
      p_nlinea IN NUMBER,
      p_smodcon IN NUMBER,
      p_cpais IN NUMBER,
      p_fefeadm IN DATE,
      p_cproces IN NUMBER)
      RETURN VARCHAR2 IS
      v_tobjeto      VARCHAR2(100) := 'PAC_CUADRE_ADM.F_CONTABILIZA_DETALLEDIARIO';
      v_tparam       VARCHAR2(500)
         := 'empresa=' || p_cempres || ' fcontab=' || TO_CHAR(p_fcontab, 'dd-mm-yyyy')
            || ', p_nlinea =' || p_nlinea || ', p_smodcon = ' || p_smodcon || ', p_cpais = '
            || p_cpais || ', p_fefeadm = ' || p_fefeadm || ', p_cproces = ' || p_cproces;
      v_ntraza       NUMBER := 0;

      /*CURSOR cur_conta IS
          SELECT m.casient, m.smodcon
            FROM modconta m
           WHERE m.cempres = p_cempres
             AND m.fini < p_fcontab
             AND(m.ffin >= p_fcontab
                 OR m.ffin IS NULL)
             AND p_fcontab IS NOT NULL
          UNION ALL
          SELECT m.casient, m.smodcon
            FROM modconta m
           WHERE m.cempres = p_cempres
             AND m.ffin IS NULL
             AND p_fcontab IS NULL;*/
      CURSOR cur_detalle IS
         SELECT d2.nlinea, d2.ccuenta, d2.claenlace, d2.tipofec, d1.tcuenta, c.cgroup,
                c.tdescri,
                          /*REPLACE(REPLACE(d2.tseldia || ' '
                                                           -- Bug 0014782 - DCG - 30/04/2013 -Ini
                                          || '('
                                          -- Bug 0014782 - DCG - 30/04/2013 -Fi
                                          || DECODE(p_fcontab,
                                                    NULL, 'fcontab is null',
                                                    'trunc(fcontab) = to_date('''
                                                    || TO_CHAR(p_fcontab, 'dd/mm/yyyy')
                                                    || ''',''dd/mm/yyyy'') '),
                                          '#fecha', TO_CHAR(p_fcontab, 'dd/mm/yyyy')),
                                  '#ccuenta', d2.ccuenta)
                          -- Bug 0014782 - DCG - 30/04/2013 -Ini
                          || 'or fcontab is null)'
                                                  -- Bug 0014782 - DCG - 30/04/2013 -Fi*/
                          d2.tseldia AS tselec   --RADD
           FROM descuenta c, detmodconta d1, detmodconta_dia d2
          WHERE d1.smodcon = d2.smodcon
            AND d1.ccuenta = d2.ccuenta
            AND d1.cempres = d2.cempres
            AND d1.nlinea = d2.nlinea
            AND c.ccuenta = d1.ccuenta
            AND d2.smodcon = p_smodcon
            AND d2.nlinea = p_nlinea
            AND d1.cempres = p_cempres
            AND d2.ccuenta = SUBSTR(p_ccuenta, 1, LENGTH(d2.ccuenta));

      v_ttexto       VARCHAR2(32000);
      v_ttexto2      VARCHAR2(32000);
      v_npos         NUMBER;
      v_nlong        NUMBER;
      v_nlong_tipodiario NUMBER;
      v_dumrec       NUMBER := 0;
      -- 39  - 18/12/2013 - MMM - 0029391: LCOL_PROD-Contabilidad - 0010526 IAXIS Interfaces Con Fecha Fuera Del Periodo- Funcionalidad - Inicio
      vfcierre       DATE;
   -- 39  - 18/12/2013 - MMM - 0029391: LCOL_PROD-Contabilidad - 0010526 IAXIS Interfaces Con Fecha Fuera Del Periodo- Funcionalidad - Fin
   BEGIN
      v_ntraza := 1000;
      v_ttexto := NULL;
      v_nlong := NVL(f_parinstalacion_n('LONG_CUENTA_CONTA'), 9);
      v_nlong_tipodiario := NVL(pac_parametros.f_parempresa_n(p_cempres,
                                                              'LONG_TIPODIARI_CONTA'),
                                2);

      -- 39  - 18/12/2013 - MMM - 0029391: LCOL_PROD-Contabilidad - 0010526 IAXIS Interfaces Con Fecha Fuera Del Periodo- Funcionalidad - Inicio
      SELECT TRUNC(MAX(fperfin)) + 1
        INTO vfcierre
        FROM cierres
       WHERE ctipo = 7
         AND cestado = 1
         AND TRUNC(fproces) < NVL(p_fcontab, TRUNC(f_sysdate));

      -- 39  - 18/12/2013 - MMM - 0029391: LCOL_PROD-Contabilidad - 0010526 IAXIS Interfaces Con Fecha Fuera Del Periodo- Funcionalidad - Fin

      /*FOR reg_conta IN cur_conta LOOP
         v_ntraza := 1010;*/
      FOR reg_detalle IN cur_detalle LOOP
         v_ntraza := 1020;

          --v_ttexto2 := reg_detalle.tselec;
         /* v_ttexto2 := REPLACE(REPLACE(reg_detalle.tselec || ' ' || '('
                                       || DECODE(p_fcontab,
                                                 NULL, 'fcontab is null',
                                                 'trunc(fcontab) = to_date('''
                                                 || TO_CHAR(p_fcontab, 'dd/mm/yyyy')
                                                 || ''',''dd/mm/yyyy'') '),
                                       '#fecha', TO_CHAR(p_fcontab, 'dd/mm/yyyy')),
                               '#ccuenta', d2.ccuenta)
                       || 'or fcontab is null)';*/
         IF (p_fcontab IS NULL) THEN   --IF DE RADD PARA 0027351
            v_ttexto2 := REPLACE(REPLACE(reg_detalle.tselec || ' ' || '(' || 'fcontab is null',
                                         '#fecha', TO_CHAR(p_fcontab, 'dd/mm/yyyy')),
                                 '#ccuenta', reg_detalle.ccuenta)
                         || ' or fcontab is null)';
         ELSE
            v_ttexto2 := REPLACE(REPLACE(reg_detalle.tselec || ' '
                                         || 'trunc(fcontab) = to_date('''
                                         || TO_CHAR(p_fcontab, 'dd/mm/yyyy')
                                         || ''',''dd/mm/yyyy'') ',
                                         '#fecha', TO_CHAR(p_fcontab, 'dd/mm/yyyy')),
                                 '#ccuenta', reg_detalle.ccuenta);
         --CPM   36  0028847: Se elimina la condición fcontab is null, pues siempre tendremos informada la fecha.
         END IF;

         v_npos := INSTR(v_ttexto2, 'SELECT') + 7;

         IF UPPER(v_ttexto2) LIKE '%RECIBO%' THEN
            v_dumrec := 0;
            v_ttexto2 := 'SELECT ''' || reg_detalle.ccuenta || ''' ccuenta,'''
                         || reg_detalle.tcuenta || ''' tcuenta,'
                         || 's.npoliza,s.sproduc,r.nrecibo,r.fefecto,'
                         || SUBSTR(v_ttexto2, v_npos);
         ELSE
            v_dumrec := 1;
            v_ttexto2 := 'SELECT ''' || reg_detalle.ccuenta || ''' ccuenta,'''
                         || reg_detalle.tcuenta || ''' tcuenta,'
                         || 's.npoliza,s.sproduc,null nrecibo,null fefecto,'
                         || SUBSTR(v_ttexto2, v_npos);
         END IF;

         v_ntraza := 1070;
         -- IF v_ttexto IS NULL THEN
         v_ttexto := v_ttexto2;
      /* ELSE
          v_ttexto := v_ttexto || ' ' || 'union all' || ' ' || v_ttexto2;
       END IF;*/
      END LOOP;

      IF NVL(v_dumrec, 0) = 0 THEN
         -- END LOOP;
         v_ttexto := 'SELECT x.ccuenta' || '       || SUBSTR(LPAD(NVL(x.coletilla, ''0''), '
                     || v_nlong || ', ''0''),GREATEST(4, LENGTH(x.ccuenta))- ' || v_nlong
                     || ' ) cuenta,' || '       substr(x.descrip,' ||(v_nlong_tipodiario + 1)
                     || ') descrip,' || '       NVL( TO_DATE( '''
                     || TO_CHAR(p_fcontab, 'dd/mm/yyyy')
                     || ''', ''dd/mm/yyyy'') , TRUNC(f_sysdate)) fec_contable,'
                     || '       x.fecha fec_administra, ' || ' '''''''' ||'
                     || 'x.proceso proceso,      ' || '       x.tcuenta texto_apunte, '
                     || '       x.importe Importe,      ' || '       x.npoliza Poliza,       '
                     || '       x.nrecibo Recibo,       ' || '       x.fefecto fec_efectoRec,'
                     || '       y.itotpri itotpri,      ' || '       y.itotdto itotdto,      '
                     || '       y.itotimp itotimp,      ' || '       y.itotrec itotrec,      '
                     || '       y.icombru icombru,      ' || '       y.itotalr itotalr,      '
                     || '       x.sproduc sproduc,      ' || '       z.FMOVINI fec_estadoRec '
                     || ' FROM vdetrecibos y, movrecibo z, (        ' || v_ttexto
                     || '     ) x' || ' where x.importe<>0' || ' and   y.nrecibo=x.nrecibo'
                     || '   and z.nrecibo = y.nrecibo and z.fmovfin is null '
                     || '   and trim(x.ccuenta || SUBSTR(LPAD(NVL(x.coletilla, ''0''),'
                     || v_nlong
                     || ', ''0''),
                     GREATEST(4, LENGTH(x.ccuenta)) - ' || v_nlong || ')) = '''
                     || TRIM(p_ccuenta) || CHR(39) || ' and x.pais = ' || p_cpais
                     -- 39  - 18/12/2013 - MMM - 0029391: LCOL_PROD-Contabilidad - 0010526 IAXIS Interfaces Con Fecha Fuera Del Periodo- Funcionalidad - Inicio
                     --|| ' and x.fecha =  TO_DATE( ''' || TO_CHAR(p_fefeadm, 'dd/mm/yyyy')
                     || ' and GREATEST(x.fecha,to_date(''' || TO_CHAR(vfcierre, 'dd/mm/yyyy')
                     || ''',''dd/mm/yyyy'')) =  TO_DATE( '''
                     || TO_CHAR(p_fefeadm, 'dd/mm/yyyy')
                                                        -- 39  - 18/12/2013 - MMM - 0029391: LCOL_PROD-Contabilidad - 0010526 IAXIS Interfaces Con Fecha Fuera Del Periodo- Funcionalidad - Fin
                     || ''', ''dd/mm/yyyy'')' || ' and x.proceso = ' || p_cproces;
      ELSE
         v_ttexto := 'SELECT x.ccuenta' || '       || SUBSTR(LPAD(NVL(x.coletilla, ''0''), '
                     || v_nlong || ', ''0''),GREATEST(4, LENGTH(x.ccuenta))- ' || v_nlong
                     || ' ) cuenta,' || '       substr(x.descrip,' ||(v_nlong_tipodiario + 1)
                     || ') descrip,' || '       NVL( TO_DATE( '''
                     || TO_CHAR(p_fcontab, 'dd/mm/yyyy')
                     || ''', ''dd/mm/yyyy'') , TRUNC(f_sysdate)) fec_contable,'
                     || '       x.fecha fec_administra, ' || ' '''''''' ||'
                     || 'x.proceso proceso,      ' || '       x.tcuenta texto_apunte, '
                     || '       x.importe Importe,      ' || '       x.npoliza Poliza,       '
                     || '       null Recibo,       ' || '       x.fefecto fec_efectoRec,'
                     || '       null itotpri,      ' || '       null itotdto,      '
                     || '            null itotimp,      ' || '       null itotrec,      '
                     || '       null icombru,      ' || '       null itotalr,      '
                     || '       x.sproduc sproduc,      ' || '       null fec_estadoRec '
                     || ' FROM  (        ' || v_ttexto || '     ) x' || ' where x.importe<>0'
                     || '   and trim(x.ccuenta || SUBSTR(LPAD(NVL(x.coletilla, ''0''),'
                     || v_nlong
                     || ', ''0''),
                         GREATEST(4, LENGTH(x.ccuenta)) - ' || v_nlong || ')) = '''
                     || TRIM(p_ccuenta) || CHR(39) || ' and x.pais = ' || p_cpais
                     --|| ' and x.fecha =  TO_DATE( ''' || TO_CHAR(p_fefeadm, 'dd/mm/yyyy')
                     -- 39  - 18/12/2013 - MMM - 0029391: LCOL_PROD-Contabilidad - 0010526 IAXIS Interfaces Con Fecha Fuera Del Periodo- Funcionalidad - Inicio
                     --|| ' and x.fecha =  TO_DATE( ''' || TO_CHAR(p_fefeadm, 'dd/mm/yyyy')
                     || ' and GREATEST(x.fecha,to_date(''' || TO_CHAR(vfcierre, 'dd/mm/yyyy')
                     || ''',''dd/mm/yyyy'')) =  TO_DATE( '''
                     || TO_CHAR(p_fefeadm, 'dd/mm/yyyy')
                                                        -- 39  - 18/12/2013 - MMM - 0029391: LCOL_PROD-Contabilidad - 0010526 IAXIS Interfaces Con Fecha Fuera Del Periodo- Funcionalidad - Fin
                     || ''', ''dd/mm/yyyy'')' || ' and x.proceso = ' || p_cproces;
      END IF;

       --ICV -- Anadimos la cuenta con la coletilla.
      /* IF p_ccuenta IS NOT NULL THEN
          v_ttexto :=
             v_ttexto
             || ' and x.ccuenta
             || SUBSTR(LPAD(NVL(x.coletilla, ''0''),'||v_nlong||', ''0''),
                  GREATEST(4, LENGTH(x.ccuenta)) - '||v_nlong||') = ''
             || p_ccuenta || ''';
       END IF;*/
      v_ntraza := 1080;
      RETURN v_ttexto;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam || ': Error' || SQLCODE,
                     SQLERRM);
         RETURN NULL;
   END f_contabiliza_detallediario;

-- Bug 0022394 - DCG - 02/07/2012
/*************************************************************************
  Función que busca selects dinámicas para detalle del MAP 311
  param in p_cempres   : Código empresa
  param in p_mes       : Mes
  param in p_ano       : Ano
  param in p_cpais     : País
  param in p_simulhist : Simulación o histórico
  *************************************************************************/
   FUNCTION f_list_map311(
      p_cempres IN NUMBER,
      p_mes IN NUMBER,
      p_ano IN NUMBER,
      p_cpais IN NUMBER,
      p_simulhist IN NUMBER)
      RETURN VARCHAR2 IS
      v_tobjeto      VARCHAR2(100) := 'PAC_CUADRE_ADM.f_list_map311';
      v_tparam       VARCHAR2(500)
         := 'empresa=' || p_cempres || ', mes=' || p_mes || ', ano =' || p_ano || ', pais = '
            || p_cpais || ', p_simulhist = ' || p_simulhist;
      v_ntraza       NUMBER := 0;
      v_ttexto       VARCHAR2(32000);
      v_tabla2       VARCHAR2(50);
      v_nasient      VARCHAR(50);
      v_nasient2     VARCHAR(50);
      v_nasient3     VARCHAR(50);
      v_pais         VARCHAR(50);
      v_order        VARCHAR(50);
   BEGIN
      v_ntraza := 1;
      v_ttexto := NULL;

      IF NVL(f_parinstalacion_n('CONTAB_X_ASIENT'), 0) = 0 THEN
         v_ntraza := 2;
         v_tabla2 := 'his_contable';
         v_nasient := NULL;
         v_nasient2 := NULL;
         v_nasient3 := NULL;
         v_order := 'ccuenta';
      ELSE
         v_ntraza := 3;
         v_tabla2 := 'his_contab_asient';
         v_nasient := ', d.nasient, d.nlinea';
         v_nasient2 := ', nasient, nlinea';
         v_nasient3 := 'nasient' || ' || '';'' || ';
         v_order := 'nasient, nlinea, ccuenta';
      END IF;

      IF p_cpais IS NOT NULL THEN
         v_pais := p_cpais;
      ELSE
         v_pais := 'NULL';
      END IF;

      v_ntraza := 4;
      v_ttexto :=
         'SELECT   ' || v_nasient3 || '' || ' fasient ' || ' || '';'' || ' || ' ccuenta '
         || ' || '';'' || ' || ' tdescri ' || ' || '';'' || ' || ' SUM(debe) '
         || ' || '';'' || '
         || ' SUM(haber) linea
         FROM (SELECT   d.cempres, d.fasient, c.tdescri, d.ccuenta ccuenta,
         DECODE(SIGN(SUM(DECODE(tasient, ''D'', iasient, 0 - iasient))),
         1, SUM(DECODE(tasient, ''D'', iasient, 0 - iasient)),
         0, 0) debe,
         DECODE(SIGN(SUM(DECODE(tasient, ''H'', iasient, 0 - iasient))),
         1, SUM(DECODE(tasient, ''H'', iasient, 0 - iasient))) haber,
         d.cpais'
         || v_nasient
         || '
         FROM descuenta c, detcontab d
         WHERE SUBSTR(d.ccuenta, 1, LENGTH(c.ccuenta)) = c.ccuenta
         AND 1 = '
         || p_simulhist || '
         AND d.cpais = ' || v_pais || '
         AND cempres = ' || p_cempres || '
         AND fasient = LAST_DAY(TO_DATE(' || '''' || p_ano || '''' || '||''''/''''||'
         || ' LPAD(' || p_mes
         || ', 2, ''0''), ''yyyy/mm''))
         GROUP BY d.cempres, d.fasient, d.ccuenta, c.tdescri, d.cpais '
         || v_nasient
         || '
         UNION ALL
         SELECT   cempres, fconta fasient, ccuenta, tdescri,
         DECODE(SIGN(SUM(NVL(debe, 0) - NVL(haber, 0))),
         1, SUM(NVL(debe, 0) - NVL(haber, 0))) debe,
         DECODE(SIGN(SUM(NVL(haber, 0) - NVL(debe, 0))),
         1, SUM(NVL(haber, 0) - NVL(debe, 0))) haber,
         cpais '
         || v_nasient2 || '
         FROM ' || v_tabla2 || '
         WHERE 2 = ' || p_simulhist || ' AND cpais = ' || v_pais || '
         AND cempres = ' || p_cempres || '
         AND fconta = LAST_DAY(TO_DATE(' || '''' || p_ano || '''' || '||''''/''''||'
         || ' LPAD(' || p_mes
         || ', 2, ''0''), ''yyyy/mm''))
         GROUP BY cempres, fconta, ccuenta, tdescri, cpais '
         || v_nasient2
         || '
         UNION ALL
         SELECT d.cempres, d.fasient, c.tdescri, d.ccuenta ccuenta,
         DECODE(SIGN(SUM(DECODE(tasient, ''D'', iasient, 0 - iasient))),
         1, SUM(DECODE(tasient, ''D'', iasient, 0 - iasient)),
         0, 0) debe,
         DECODE(SIGN(SUM(DECODE(tasient, ''H'', iasient, 0 - iasient))),
         1, SUM(DECODE(tasient, ''H'', iasient, 0 - iasient))) haber,
         NULL cpais '
         || v_nasient
         || '
         FROM descuenta c, detcontab d
         WHERE SUBSTR(d.ccuenta, 1, LENGTH(c.ccuenta)) = c.ccuenta
         AND 1 = '
         || p_simulhist || '
         AND ' || v_pais || ' IS NULL
         AND cempres = ' || p_cempres || '
         AND fasient = LAST_DAY(TO_DATE(' || '''' || p_ano || '''' || '||''''/''''||'
         || ' LPAD(' || p_mes
         || ', 2, ''0''), ''yyyy/mm''))
         GROUP BY d.cempres, d.fasient, d.ccuenta, c.tdescri '
         || v_nasient
         || '
         UNION ALL
         SELECT   cempres, fconta fasient, ccuenta, tdescri,
         DECODE(SIGN(SUM(NVL(debe, 0) - NVL(haber, 0))),
         1, SUM(NVL(debe, 0) - NVL(haber, 0))) debe,
         DECODE(SIGN(SUM(NVL(haber, 0) - NVL(debe, 0))),
         1, SUM(NVL(haber, 0) - NVL(debe, 0))) haber,
         NULL cpais '
         || v_nasient2 || '
         FROM ' || v_tabla2 || '
         WHERE 2 = ' || p_simulhist || '
         AND ' || v_pais || ' IS NULL
         AND cempres = ' || p_cempres || '
         AND fconta = LAST_DAY(TO_DATE(' || '''' || p_ano || '''' || '||''''/''''||'
         || ' LPAD(' || p_mes
         || ', 2, ''0''), ''yyyy/mm''))
         GROUP BY cempres, fconta, ccuenta, tdescri ' || v_nasient2
         || ')
         GROUP BY fasient, ccuenta, tdescri ' || v_nasient2 || '
         ORDER BY ' || v_order || '';
      RETURN v_ttexto;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam || ': Error' || SQLCODE,
                     SQLERRM);
         RETURN NULL;
   END f_list_map311;

/*************************************************************************
  Mapa que se ejecuta desde la pantalla axisadm007 Desglose Simul. Contable
  *************************************************************************/
   FUNCTION f_desglose_cuenta(
      pcuenta IN VARCHAR2,
      ptipo IN VARCHAR2,
      pfecha IN DATE,
      pempresa IN NUMBER DEFAULT 1,
      pactual IN NUMBER DEFAULT 0,
      pmes IN NUMBER DEFAULT 1,
      pasient IN NUMBER,
      plinea IN NUMBER)
      RETURN VARCHAR2 IS
      v_ntraza       NUMBER := 0;
      v_ttexto       VARCHAR2(32000);
      v_tobjeto      VARCHAR2(100) := 'PAC_CUADRE_ADM.f_desglose_cuenta';
      v_tparam       VARCHAR2(500)
         := 'empresa=' || pempresa || ', fecha=' || pfecha || ', cuenta =' || pcuenta
            || ', linea = ' || plinea || ', asiento = ' || pasient || ', tipo = ' || ptipo
            || ', actual = ' || pactual;
   BEGIN
      IF NVL(f_parinstalacion_n('CONTAB_X_ASIENT'), 0) = 1 THEN
         v_ntraza := 1;
         v_ttexto := f_selec_cuenta_asient(pcuenta, plinea, pasient, ptipo, pfecha, pempresa,
                                           pactual);
      ELSE
         v_ntraza := 2;
         v_ttexto := f_selec_cuenta(pcuenta, ptipo, pfecha, pempresa, pactual, pmes);
      END IF;

      RETURN v_ttexto;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam || ': Error' || SQLCODE,
                     SQLERRM);
         RETURN NULL;
   END f_desglose_cuenta;

  /*************************************************************************
   Funcion que obtiene el IDPAGO tanto si debe ser concatenado o debe
   conservar el IDPAGO.
  *************************************************************************/
  -- Version 44
   FUNCTION f_idpago(pttippag IN NUMBER,
                     pidpago IN NUMBER,
                     pidmovimiento IN NUMBER)
   RETURN NUMBER IS
   --
   l_tatribu        detvalores.tatribu%TYPE;
   l_idpago         NUMBER;
   l_causacion_comi VARCHAR2(30) := 'CAUSACION COMISION';
   l_causacion_coa VARCHAR2(30) := 'COASEGURO'; --CONF-403 - Ajuste cabecera coaseguro LR
   --
   BEGIN
      --
      BEGIN
         --
         SELECT d.tatribu
           INTO l_tatribu
           FROM detvalores d
          WHERE d.cvalor  = 963
            AND d.cidioma = 8
            AND d.catribu = pttippag
            AND d.tatribu IN (l_causacion_comi, l_causacion_coa);--CONF-403 - Ajuste cabecera coaseguro LR
   --
         --
      EXCEPTION WHEN no_data_found THEN
         --
         l_tatribu := NULL;
         --
      END;
      --
      IF l_tatribu IS NOT NULL THEN
         --
         l_idpago := pidpago||pidmovimiento;
         --
      ELSE
         --
         l_idpago := pidpago;
         --
      END IF;
      --
      RETURN l_idpago;
      --
   END f_idpago;
   --Version 44
   -- Bug 25558 - APD - 25/01/2013 - se crea la funcion
   FUNCTION f_contabiliza_interf(
      psinterf IN NUMBER,
      pttippag IN NUMBER,
      pidpago IN NUMBER,
      pcempres IN NUMBER,
      pfecha IN DATE,
      pidmovimiento IN NUMBER)
      RETURN NUMBER IS
      CURSOR c_conta IS
         SELECT m.casient, m.smodcon
           FROM modconta m
          WHERE m.cempres = pcempres
            AND m.fini < pfecha
            AND(m.ffin >= pfecha
                OR m.ffin IS NULL)
            AND pfecha IS NOT NULL
         UNION ALL
         SELECT m.casient, m.smodcon
           FROM modconta m
          WHERE m.cempres = pcempres
            AND m.ffin IS NULL
            AND pfecha IS NULL;

      CURSOR c_detconta(psmodcon NUMBER) IS
         SELECT d2.nlinea, d2.ccuenta, d2.claenlace, d2.tlibro, d2.tipofec, d2.ttippag,
                d1.tcuenta, c.cgroup, c.tdescri, d2.tseldia tselec
                ,nvl(ctiprec,0) solidaridad -- axis 4504
                ,nvl(codescenario,0) codescenario-- axis 4504
           FROM descuenta c, detmodconta d1, detmodconta_interf d2
           -- inicio axis 4504 - EA - 2019-07-17 - se valida para que solo se tomen los subselect especificos
           join sgt_subtabs_det sqt1 on  sqt1.csubtabla=9000016    
        join sgt_subtabs_det sqt2 on  sqt2.csubtabla=9000016   and sqt1.nval7=sqt2.nval7
         and sqt2.nval5 is not null and sqt2.nval4=d2.nlinea and decode(sqt1.nval2,1,sqt2.nval5,sqt1.nval2)=sqt2.nval5
         join MOVCONTASAP on MOVCONTASAP.nrecibo=pidpago 
         and sqt1.ccla2=MOVCONTASAP.ramo and sqt1.ccla1=MOVCONTASAP.cconcep and sqt2.nval5=MOVCONTASAP.ctiprec and MOVCONTASAP.cconcep=sqt1.ccla1
          and sqt1.ccla2 =MOVCONTASAP.ramo  and sqt2.ccla2<>MOVCONTASAP.ramo
            -- fin axis 4504 - EA - 2019-07-17 - se valida para que solo se tomen los subselect especificos
          WHERE d1.smodcon = d2.smodcon
            AND d1.ccuenta = d2.ccuenta
            AND d1.cempres = d2.cempres
            AND d1.nlinea = d2.nlinea
            AND c.ccuenta = d1.ccuenta
            AND d1.smodcon = psmodcon
            AND d1.cempres = pcempres
            AND d2.ttippag = pttippag            
            ORDER BY nlinea ASC;

      CURSOR c_invert IS
         SELECT ccuenta, nlinea, nasient, ccoletilla, tdescri, fefeadm, otros
           FROM contab_asient_interf ca
          WHERE ca.sinterf = psinterf
            AND ca.ttippag = pttippag
            AND ca.idpago = pidpago
            AND ca.fconta = NVL(pfecha, TRUNC(f_sysdate))
            AND ca.iapunte < 0;

      TYPE t_cursor IS REF CURSOR;

      c_rec          t_cursor;
      importe        NUMBER;
      producto       VARCHAR2(32000);
      pais           NUMBER;
      vproces        NUMBER;
      vcuenta        NUMBER;
      vcoletilla     VARCHAR2(100);
      vtlibro        VARCHAR2(100);
      vidpago        NUMBER;
      vttippag       NUMBER;
      vsucursal      VARCHAR2(20);
      vfadm          DATE;
      vdescri        VARCHAR2(32000);
      maxasien       NUMBER;
      vfecha         DATE;
      votros         VARCHAR2(4000);
      v_ccuenta_aux  VARCHAR2(50);
      v_nlinea_aux   NUMBER;
      vtselec        VARCHAR2(32000);
      vntraza        NUMBER := 0;
      -- inicio axis 4504 - EA - 2019-07-17 - se valida para que solo se tomen los subselect especificos 
      vcramo         NUMBER;
      vcconpag       NUMBER;
      -- fin axis 4504 - EA - 2019-07-17 - se valida para que solo se tomen los subselect especificos 
      l_idpago       NUMBER;
      l_idmovimiento NUMBER(8);
      --
      vobject        VARCHAR2(200) := 'PAC_CUADRE_ADM.f_contabiliza_interf';
      -- 39  - 18/12/2013 - MMM - 0029391: LCOL_PROD-Contabilidad - 0010526 IAXIS Interfaces Con Fecha Fuera Del Periodo- Funcionalidad - Inicio
      vfcierre       DATE;
   -- 39  - 18/12/2013 - MMM - 0029391: LCOL_PROD-Contabilidad - 0010526 IAXIS Interfaces Con Fecha Fuera Del Periodo- Funcionalidad - Fin
   BEGIN
      -- Esborrem els registre ja existents
      IF pfecha IS NOT NULL THEN
         DELETE FROM contab_asient_interf
               WHERE sinterf = psinterf
               and idpago = pidpago;
      END IF;
           -- 39  - 18/12/2013 - MMM - 0029391: LCOL_PROD-Contabilidad - 0010526 IAXIS Interfaces Con Fecha Fuera Del Periodo- Funcionalidad - Inicio
      --     SELECT TRUNC (MAX (fperfin)) + 1
           -- 43  --25/05/2015 -- IPH -- 0036026: POSES200-el cierre generado para el mes de abril quedo reportado en mayo
      SELECT TRUNC(MAX(fperfin)) + DECODE(pttippag, 13, 0, 14, 0, 1)
        INTO vfcierre
        FROM cierres
       WHERE ctipo = 7
         AND cestado = 1
         AND TRUNC(fproces) < NVL(pfecha, TRUNC(f_sysdate));
      -- inicio axis 4504 - EA - 2019-07-17 - se valida para que solo se tomen los subselect especificos 
      BEGIN 
        --
        SELECT sp.cconpag, s.cramo
          INTO vcconpag, vcramo
          FROM sin_tramita_pago sp, sin_siniestro sn , seguros s 
         WHERE s.sseguro = sn.sseguro 
           AND sn.nsinies = sp.nsinies 
           AND sp.sidepag = pidpago;
        EXCEPTION WHEN OTHERS THEN 
          NULL;             
        --
      END;
      -- fin axis 4504 - EA - 2019-07-17 - se valida para que solo se tomen los subselect especificos
      -- 43  --25/05/2015 -- IPH -- 0036026: POSES200-el cierre generado para el mes de abril quedo reportado en mayo
      -- 39  - 18/12/2013 - MMM - 0029391: LCOL_PROD-Contabilidad - 0010526 IAXIS Interfaces Con Fecha Fuera Del Periodo- Funcionalidad - Fin
      FOR reg IN c_conta LOOP
         FOR reg_det IN c_detconta(reg.smodcon) LOOP
            v_ccuenta_aux := reg_det.ccuenta;
            v_nlinea_aux := reg_det.nlinea;
            vntraza := 100;
            vtselec := reg_det.tselec;
            vntraza := 130;
            vtselec := REPLACE(vtselec, '#idpago', pidpago);
            vtselec := REPLACE(vtselec, '#pidmov', pidmovimiento);
            vtselec := REPLACE(vtselec, '#cconpag', vcconpag);
            vtselec := REPLACE(vtselec, '#cramo', vcramo);
            vtselec := REPLACE(vtselec, '#codescenario', reg_det.codescenario);
            -- 39  - 18/12/2013 - MMM - 0029391: LCOL_PROD-Contabilidad - 0010526 IAXIS Interfaces Con Fecha Fuera Del Periodo- Funcionalidad - Inicio
            vntraza := 140;
            --vtselec := 'select coletilla, descrip, sum(importe), otros, fecha from ('|| vtselec;
            vtselec :=
               'select coletilla, descrip, sum(importe), otros, greatest(fecha,to_date('''
               || TO_CHAR(vfcierre, 'dd/mm/yyyy') || ''',''dd/mm/yyyy'')) fecha from ('
               || vtselec;
            vntraza := 150;
            --vtselec := vtselec || ' ) group by coletilla, descrip, otros, fecha';
            vtselec := vtselec
                       || ' ) group by coletilla, descrip, otros, greatest(fecha,to_date('''
                       || TO_CHAR(vfcierre, 'dd/mm/yyyy') || ''',''dd/mm/yyyy'')) ';
            vntraza := 160;

            -- 39  - 18/12/2013 - MMM - 0029391: LCOL_PROD-Contabilidad - 0010526 IAXIS Interfaces Con Fecha Fuera Del Periodo- Funcionalidad - Fin
            OPEN c_rec FOR vtselec;

            vntraza := 170;
            -- Insertem en la taula de contabilitat
            FETCH c_rec
             INTO vcoletilla, vdescri, importe, votros, vfadm;
            LOOP
               vntraza := 190;

               IF c_rec%NOTFOUND THEN
                  EXIT;
               ELSE
                  IF importe <> 0 THEN
                     vntraza := 200;
                     -- Version 44
                     l_idpago := pac_cuadre_adm.f_idpago(pttippag,pidpago,pidmovimiento);
                     l_idmovimiento := to_number(substr(pidmovimiento,0,7));
                     -- Version 44
                     BEGIN
					 
					 --BEGIN	iaxis--4182  -WAJ
					 if substr(votros, 1, 3) in ('251','255','256','248') then
                            l_idpago := pidmovimiento;
                     end if;
					 --END	iaxis--4182  -WAJ
                    
                   
                        INSERT INTO contab_asient_interf
                                    (sinterf, ttippag, idpago,
                                     fconta, nasient,
                                     nlinea, ccuenta, ccoletilla,
                                     tapunte, iapunte, tdescri, fefeadm,
                                     cenlace, tlibro, otros, idmov)
                             VALUES (psinterf, pttippag, l_idpago,                 -- Version 44
                                     NVL(pfecha, TRUNC(f_sysdate)), reg.smodcon,
                                     reg_det.nlinea, reg_det.ccuenta, vcoletilla,
                                     reg_det.tcuenta, importe, vdescri, vfadm,
                                     reg_det.claenlace, reg_det.tlibro, votros, l_idmovimiento);
                     EXCEPTION
                        WHEN OTHERS THEN
                           p_tab_error(f_sysdate, f_user, vobject, 2,
                                       'Error smodcon:' || reg.smodcon || ' nlinea:'
                                       || reg_det.nlinea || ' cproces:' || vproces,
                                       SQLERRM);
                           RETURN 1;
                     END;
                  END IF;

                  vntraza := 210;

                  FETCH c_rec
                   INTO vcoletilla, vdescri, importe, votros, vfadm;
               END IF;
            END LOOP;

            CLOSE c_rec;
         END LOOP;
      END LOOP;

      vntraza := 220;

      --Control para invertir el tapunte
      IF NVL(pac_parametros.f_parempresa_n(pcempres, 'INVERT_APUNTE_CONTA'), 0) = 1 THEN
         FOR rc IN c_invert LOOP
            vntraza := 350;

            UPDATE contab_asient_interf
               SET tapunte = DECODE(tapunte, 'H', 'D', 'H'),
                   iapunte = ABS(iapunte)
             WHERE sinterf = psinterf
               AND ttippag = pttippag
               AND idpago = pidpago
               AND fconta = NVL(pfecha, TRUNC(f_sysdate))
               AND nasient = rc.nasient
               AND ccuenta = rc.ccuenta
               AND nlinea = rc.nlinea
               AND ccoletilla = rc.ccoletilla
               AND fefeadm = rc.fefeadm
               AND tdescri = rc.tdescri
               AND otros = rc.otros;
         END LOOP;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         IF c_rec%ISOPEN THEN
            CLOSE c_rec;
         END IF;

         p_tab_error(f_sysdate, f_user, vobject, vntraza,
                     'Error incontrolado en CCUENTA : ' || v_ccuenta_aux || ' NLINEA : '
                     || v_nlinea_aux,
                     SQLERRM);
         RETURN 1;
   END f_contabiliza_interf;
   --Bug 4504 creacion de funcion de contabilidad para siniestros 
   FUNCTION f_conta_int_sini(
      psinterf IN NUMBER,
      pttippag IN NUMBER,
      pidpago IN NUMBER,
      pcempres IN NUMBER,
      pfecha IN DATE,
      pidmovimiento IN NUMBER)
      RETURN NUMBER IS
      CURSOR c_conta IS
         SELECT m.casient, m.smodcon
           FROM modconta m
          WHERE m.cempres = pcempres
            AND m.fini < pfecha
            AND(m.ffin >= pfecha
                OR m.ffin IS NULL)
            AND pfecha IS NOT NULL
         UNION ALL
         SELECT m.casient, m.smodcon
           FROM modconta m
          WHERE m.cempres = pcempres
            AND m.ffin IS NULL
            AND pfecha IS NULL;
      -- IAXIS 4504 22/08/2019 actualizacion sinterf nuevos cambios .
      CURSOR c_detconta(psmodcon NUMBER, pcestpag  NUMBER, potrosgastos  NUMBER , pcramo NUMBER) IS
         SELECT d2.nlinea, d2.ccuenta, d2.claenlace, d2.tlibro, d2.tipofec, d2.ttippag,
                decode(0,pcestpag,d1.tcuenta,decode(d1.tcuenta,'H','D','H')) tcuenta, c.cgroup, c.tdescri, d2.tseldia tselec
                ,nvl(ctiprec,0) solidaridad 
                ,nvl(codescenario,0) codescenario
                ,cconcep
                ,sqt2.nval3 cuenta
           FROM descuenta c, detmodconta d1, detmodconta_interf d2
           join sgt_subtabs_det sqt1 on  sqt1.csubtabla=9000016    
           join sgt_subtabs_det sqt2 on  sqt2.csubtabla=9000016           
           and sqt2.ccla1=d2.nlinea  
           and  ','||sqt2.nval8||',' like '%,'||sqt1.nval1||',%'   and sqt2.nval1<>decode(0,potrosgastos,0,1) AND sqt2.ccla2 = pcramo 
           join MOVCONTASAP on MOVCONTASAP.ESTADO in(0,3,5) AND MOVCONTASAP.nrecibo =pidpago --and sqt2.nval4=pcestpag 
           and sqt1.nval1=codescenario and sqt1.ccla1=cconcep          
          WHERE d1.smodcon = d2.smodcon
            AND d1.ccuenta = d2.ccuenta
            AND d1.cempres = d2.cempres
            AND d1.nlinea = d2.nlinea
            AND c.ccuenta = d1.ccuenta
            AND d1.smodcon = psmodcon
            AND d1.cempres = pcempres
            AND d2.ttippag = pttippag            
            ORDER BY nlinea ASC;
      -- IAXIS 4504 22/08/2019 actualizacion sinterf nuevos cambios.
      CURSOR c_invert IS
         SELECT ccuenta, nlinea, nasient, ccoletilla, tdescri, fefeadm, otros
           FROM contab_asient_interf ca
          WHERE ca.sinterf = psinterf
            AND ca.ttippag = pttippag
            AND ca.idpago = pidpago
            AND ca.fconta = NVL(pfecha, TRUNC(f_sysdate))
            AND ca.iapunte < 0;

      TYPE t_cursor IS REF CURSOR;

      c_rec          t_cursor;
      importe        NUMBER;
      producto       VARCHAR2(32000);
      pais           NUMBER;
      vproces        NUMBER;
      vcuenta        NUMBER;
      vcoletilla     VARCHAR2(100);
      vtlibro        VARCHAR2(100);
      vidpago        NUMBER;
      vttippag       NUMBER;
      vsucursal      VARCHAR2(20);
      vfadm          DATE;
      vdescri        VARCHAR2(32000);
      maxasien       NUMBER;
      vfecha         DATE;
      votros         VARCHAR2(4000);
      v_ccuenta_aux  VARCHAR2(50);
      v_nlinea_aux   NUMBER;
      vtselec        VARCHAR2(32000);
      vntraza        NUMBER := 0;
      vcramo         NUMBER;
      vcconpag       NUMBER;
      votrosgastos  NUMBER;
      l_idpago       NUMBER;
      l_idmovimiento NUMBER(8);
      vobject        VARCHAR2(200) := 'PAC_CUADRE_ADM.f_contabiliza_interf';
      vfcierre       DATE;
      vcestpag       NUMBER; 
  
   BEGIN
      -- Esborrem els registre ja existents
      IF pfecha IS NOT NULL THEN
         DELETE FROM contab_asient_interf
               WHERE sinterf = psinterf
               and idpago = pidpago;
      END IF;
           -- 39  - 18/12/2013 - MMM - 0029391: LCOL_PROD-Contabilidad - 0010526 IAXIS Interfaces Con Fecha Fuera Del Periodo- Funcionalidad - Inicio

      SELECT TRUNC(MAX(fperfin)) + DECODE(pttippag, 13, 0, 14, 0, 1)
        INTO vfcierre
        FROM cierres
       WHERE ctipo = 7
         AND cestado = 1
         AND TRUNC(fproces) < NVL(pfecha, TRUNC(f_sysdate));
      
      BEGIN 
        --
        SELECT sp.cconpag, s.cramo,case when sp.iotrosgas > 0 then 1 
               when sp.iotrosgas is null then 0 
               when sp.iotrosgas=0 then 1 end
          INTO vcconpag, vcramo,votrosgastos
          FROM sin_tramita_pago sp, sin_siniestro sn , seguros s 
         WHERE s.sseguro = sn.sseguro 
           AND sn.nsinies = sp.nsinies 
           AND sp.sidepag = pidpago;
	   -- IAxis 4504 AABC 10/09/02019 
        EXCEPTION WHEN OTHERS THEN 
          NULL;             
        --
      END;
      --
      BEGIN 
        --
        SELECT cestpag 
          INTO vcestpag
          FROM sin_tramita_movpago sp
         WHERE sp.sidepag = pidpago
           AND sp.nmovpag = (SELECT MAX(sp1.nmovpag)
                               FROM sin_tramita_movpago sp1
                              WHERE sp1.sidepag = sp.sidepag);
        EXCEPTION WHEN OTHERS THEN 
          --
          vcestpag := NULL;
          --                      
        
      END;  
      --
      IF vcestpag = 9 THEN 
         --
         vcestpag := 0;
         --
      END IF;   
      --
      IF vcestpag IN (0,8) THEN 
      --      
      FOR reg IN c_conta LOOP
         FOR reg_det IN c_detconta(reg.smodcon, vcestpag,votrosgastos,vcramo ) LOOP
            v_ccuenta_aux := reg_det.ccuenta;
            v_nlinea_aux := reg_det.nlinea;
            vntraza := 100;
            vtselec := reg_det.tselec;
            vntraza := 130;
            vtselec := REPLACE(vtselec, '#idpago', pidpago);
            vtselec := REPLACE(vtselec, '#pidmov', pidmovimiento);
            vtselec := REPLACE(vtselec, '#cconpag', vcconpag);
            vtselec := REPLACE(vtselec, '#cramo', vcramo);
            vtselec := REPLACE(vtselec, '#codescenario', reg_det.codescenario);
            vtselec := REPLACE(vtselec, '#cuenta', reg_det.cuenta);
            vntraza := 140;
            --
            vtselec :=
               'select coletilla, descrip, sum(importe), otros, greatest(fecha,to_date('''
               || TO_CHAR(vfcierre, 'dd/mm/yyyy') || ''',''dd/mm/yyyy'')) fecha from ('
               || vtselec;
            vntraza := 150;
            --
            vtselec := vtselec
                       || ' ) group by coletilla, descrip, otros, greatest(fecha,to_date('''
                       || TO_CHAR(vfcierre, 'dd/mm/yyyy') || ''',''dd/mm/yyyy'')) ';
            vntraza := 160;
            --    
            OPEN c_rec FOR vtselec;

            vntraza := 170;
            -- Insertem en la taula de contabilitat
            FETCH c_rec
             INTO vcoletilla, vdescri, importe, votros, vfadm;
            LOOP
               vntraza := 190;

               IF c_rec%NOTFOUND THEN
                  EXIT;
               ELSE
                  IF importe <> 0 THEN
                     vntraza := 200;
                     l_idpago := pac_cuadre_adm.f_idpago(pttippag,pidpago,pidmovimiento);
                     l_idmovimiento := to_number(substr(pidmovimiento,0,7));
                     BEGIN
           
           --BEGIN  iaxis--4182  -WAJ
           if substr(votros, 1, 3) in ('251','255','256','248') then
                            l_idpago := pidmovimiento;
                     end if;
           --END  iaxis--4182  -WAJ
                    
                   
                        INSERT INTO contab_asient_interf
                                    (sinterf, ttippag, idpago,
                                     fconta, nasient,
                                     nlinea, ccuenta, ccoletilla,
                                     tapunte, iapunte, tdescri, fefeadm,
                                     cenlace, tlibro, otros, idmov)
                             VALUES (psinterf, pttippag, l_idpago,                 -- Version 44
                                     NVL(pfecha, TRUNC(f_sysdate)), reg.smodcon,
                                     reg_det.nlinea, reg_det.ccuenta, vcoletilla,
                                     reg_det.tcuenta, importe, vdescri, vfadm,
                                     reg_det.claenlace, reg_det.tlibro, votros, l_idmovimiento);
                                     COMMIT;
                     EXCEPTION
                        WHEN OTHERS THEN
                           p_tab_error(f_sysdate, f_user, vobject, 2,
                                       'Error smodcon:' || reg.smodcon || ' nlinea:'
                                       || reg_det.nlinea || ' cproces:' || vproces,
                                       SQLERRM);
                           RETURN 1;
                     END;
                  END IF;
                  -- IAXIS 4504 22/08/2019 actualizacion sinterf. 
                  /*UPDATE movcontasap m
                     SET m.sinterf = psinterf
                   WHERE m.nrecibo = l_idpago
                     AND m.cconcep = cconcep
                     AND m.sinterf IS NULL; */  
                  -- IAXIS 4504 22/08/2019 actualizacion sinterf.
                  vntraza := 210;

                  FETCH c_rec
                   INTO vcoletilla, vdescri, importe, votros, vfadm;
               END IF;
            END LOOP;

            CLOSE c_rec;
         END LOOP;
      END LOOP;
      --
      ELSE 
        --
        RETURN 1;
        --
      END IF; 

      vntraza := 220;

      --Control para invertir el tapunte
      IF NVL(pac_parametros.f_parempresa_n(pcempres, 'INVERT_APUNTE_CONTA'), 0) = 1 THEN
         FOR rc IN c_invert LOOP
            vntraza := 350;

            UPDATE contab_asient_interf
               SET tapunte = DECODE(tapunte, 'H', 'D', 'H'),
                   iapunte = ABS(iapunte)
             WHERE sinterf = psinterf
               AND ttippag = pttippag
               AND idpago = pidpago
               AND fconta = NVL(pfecha, TRUNC(f_sysdate))
               AND nasient = rc.nasient
               AND ccuenta = rc.ccuenta
               AND nlinea = rc.nlinea
               AND ccoletilla = rc.ccoletilla
               AND fefeadm = rc.fefeadm
               AND tdescri = rc.tdescri
               AND otros = rc.otros;
               COMMIT;
         END LOOP;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         IF c_rec%ISOPEN THEN
            CLOSE c_rec;
         END IF;

         p_tab_error(f_sysdate, f_user, vobject, vntraza,
                     'Error incontrolado en CCUENTA : ' || v_ccuenta_aux || ' NLINEA : '
                     || v_nlinea_aux,
                     SQLERRM);
         RETURN 1;
   END f_conta_int_sini;
   --  
   --Bug 5194 creacion de funcion de contabilidad para siniestros 
   FUNCTION f_conta_int_res(
      psinterf IN NUMBER,
      pttippag IN NUMBER,
      pidpago IN NUMBER,
      pcempres IN NUMBER,
      pfecha IN DATE,
      pidmovimiento IN NUMBER,
      pnsinies in sin_siniestro.nsinies%type, 
      pntramit in number, 
      pctipres      in number, 
      pnmovres      in number,
      pnmovresdet   IN NUMBER,
      pcreexpre     IN NUMBER,
      pidres        IN NUMBER,
      pcmonres      IN NUMBER)
      RETURN NUMBER IS
      CURSOR c_conta IS
         SELECT m.casient, m.smodcon
           FROM modconta m
          WHERE m.cempres = pcempres
            AND m.fini < pfecha
            AND(m.ffin >= pfecha
                OR m.ffin IS NULL)
            AND pfecha IS NOT NULL
         UNION ALL
         SELECT m.casient, m.smodcon
           FROM modconta m
          WHERE m.cempres = pcempres
            AND m.ffin IS NULL
            AND pfecha IS NULL;
      -- IAXIS 4504 22/08/2019 actualizacion sinterf.
      CURSOR c_detconta(psmodcon NUMBER, pcestpag  NUMBER, pcramo NUMBER) IS
         SELECT D2.NLINEA , SQT1.NVAL2 CCUENTA, D2.CLAENLACE , D2.TLIBRO, D2.TIPOFEC , D2.TTIPPAG , D1.TCUENTA,
                C.CGROUP , D1.TDESCRI , D2.TSELDIA   TSELEC
                ,SQT1.NVAL1 CODESCENARIO , NSINIES , IDRES , NMOVRES , NMOVRESDET
           FROM descuenta c, detmodconta d1, detmodconta_interf d2
           JOIN SGT_SUBTABS_DET SQT1
             ON SQT1.CSUBTABLA = 9000020
           JOIN (SELECT CRAMO,NSINIES,NTRAMIT,CTIPRES,IDRES,NMOVRES,NMOVRESDET,CREEXPRESION,
                   CASE
                   WHEN MAX(ICONSTRES_MONCIA) <> 0 THEN
                        'CONSTITUCION'
                   WHEN MAX(IAUMENRES_MONCIA) <> 0 THEN
                        'AUMENTO'
                   WHEN MAX(ILIBERARES_MONCIA) <> 0 AND max(IDISMIRES_MONCIA) = 0 THEN
                        'LIBERACION'
                   WHEN MAX(IDISMIRES_MONCIA) <> 0  AND max(ILIBERARES_MONCIA) = 0 THEN
                        'DISMINUCION'
                   WHEN MAX(IDISMIRES_MONCIA) <> 0  AND max(ILIBERARES_MONCIA) <> 0 THEN
                        'LIBERADISM' 
                    END ACCION
                 FROM SIN_TRAMITA_RESERVA_CONTA
                 JOIN SIN_TRAMITA_RESERVADET
                USING (NSINIES, IDRES, NMOVRES)
                 JOIN SIN_SINIESTRO
                USING (NSINIES)
                 JOIN SEGUROS
                USING (SSEGURO)
          GROUP BY NSINIES, IDRES, NMOVRES, NTRAMIT, CTIPRES, CRAMO,NMOVRESDET,CREEXPRESION) STRC
          ON nsinies  = pnsinies 
         and ntramit  = pntramit 
         and ctipres  = pctipres 
         and nmovres  = pnmovres 
         AND idres    = pidres
         AND NMOVRESDET = pnmovresdet
         AND CREEXPRESION = pcreexpre
            and accion=sqt1.nval10
         AND SQT1.CCLA4 = pcreexpre
         AND sqt1.ccla5 = pcmonres
         AND SQT1.CCLA1 = D2.NLINEA
         AND SQT1.NVAL3 = D2.CCUENTA
         AND SQT1.CCLA2 = pcramo
       WHERE C.CCUENTA = D1.CCUENTA
         AND D1.SMODCON = D2.SMODCON
            AND d1.ccuenta = d2.ccuenta
            AND d1.cempres = d2.cempres
            AND d1.nlinea = d2.nlinea
            AND c.ccuenta = d1.ccuenta
            AND d1.smodcon = psmodcon
            AND d1.cempres = pcempres
            AND d2.ttippag = pttippag            
            ORDER BY nlinea ASC;
      -- IAXIS 4504 22/08/2019 actualizacion sinterf.
      CURSOR c_invert IS
         SELECT ccuenta, nlinea, nasient, ccoletilla, tdescri, fefeadm, otros
           FROM contab_asient_interf ca
          WHERE ca.sinterf = psinterf
            AND ca.ttippag = pttippag
            AND ca.idpago = pidpago
            AND ca.fconta = NVL(pfecha, TRUNC(f_sysdate))
            AND ca.iapunte < 0;

      TYPE t_cursor IS REF CURSOR;

      c_rec          t_cursor;
      importe        NUMBER;
      producto       VARCHAR2(32000);
      pais           NUMBER;
      vproces        NUMBER;
      vcuenta        NUMBER;
      vcoletilla     VARCHAR2(100);
      vtlibro        VARCHAR2(100);
      vidpago        NUMBER;
      vttippag       NUMBER;
      vsucursal      VARCHAR2(20);
      vfadm          DATE;
      vdescri        VARCHAR2(32000);
      maxasien       NUMBER;
      vfecha         DATE;
      votros         VARCHAR2(4000);
      v_ccuenta_aux  VARCHAR2(50);
      v_nlinea_aux   NUMBER;
      vtselec        VARCHAR2(32000);
      vntraza        NUMBER := 0;
      vcramo         NUMBER;
      vcconpag       NUMBER;
      l_idpago       NUMBER;
      l_idmovimiento NUMBER(8);
      vobject        VARCHAR2(200) := 'PAC_CUADRE_ADM.f_contabiliza_interf';
      vfcierre       DATE;
      vcestpag       NUMBER; 
  
   BEGIN
      -- Esborrem els registre ja existents
      IF pfecha IS NOT NULL THEN
         DELETE FROM contab_asient_interf
               WHERE sinterf = psinterf
               and idpago = pidpago;
      END IF;
           -- 39  - 18/12/2013 - MMM - 0029391: LCOL_PROD-Contabilidad - 0010526 IAXIS Interfaces Con Fecha Fuera Del Periodo- Funcionalidad - Inicio

      SELECT TRUNC(MAX(fperfin)) + DECODE(pttippag, 13, 0, 14, 0, 1)
        INTO vfcierre
        FROM cierres
       WHERE ctipo = 7
         AND cestado = 1
         AND TRUNC(fproces) < NVL(pfecha, TRUNC(f_sysdate));
      
      BEGIN 
        --
        SELECT  DISTINCT (s.cramo)
          INTO  vcramo
          FROM sin_tramita_reserva sp, sin_siniestro sn , seguros s 
         WHERE s.sseguro = sn.sseguro 
           AND sn.nsinies = sp.nsinies 
           AND sp.nsinies = pidpago;
        EXCEPTION WHEN OTHERS THEN 
          NULL;             
        --
      END;
      --
       
          
     
      FOR reg IN c_conta LOOP
       p_control_error('EDIER5194','1','6-'||reg.smodcon);
       p_control_error('EDIER5194','1','6.1-'||'pnsinies '||pnsinies||'pntramit  '||pntramit||' pctipres  '||pctipres|| 'pnmovres  '||pnmovres);
         FOR reg_det IN c_detconta(reg.smodcon, vcestpag , vcramo ) LOOP
            v_ccuenta_aux := reg_det.ccuenta;
            v_nlinea_aux := reg_det.nlinea;
            vntraza := 100;
            vtselec := reg_det.tselec;
            vntraza := 130;
            vtselec := REPLACE(vtselec, '#idpago', pidpago);
            vtselec := REPLACE(vtselec, '#pidmov', pidmovimiento);
            vtselec := REPLACE(vtselec, '#cconpag', vcconpag);
            vtselec := REPLACE(vtselec, '#cramo', vcramo);
            vtselec := REPLACE(vtselec, '#descrip', reg_det.tdescri);
            vtselec := REPLACE(vtselec, '#codescenario', reg_det.codescenario);
            vtselec := REPLACE(vtselec, '#nsinies', reg_det.nsinies);
            vtselec := REPLACE(vtselec, '#nmovres', reg_det.nmovres);
            vtselec := REPLACE(vtselec, '#idres', reg_det.idres);
            vtselec := REPLACE(vtselec, '#ndetmovres', reg_det.nmovresdet);
             vtselec := REPLACE(vtselec, '#cuenta', reg_det.ccuenta);
            vntraza := 140;
            --
            vtselec :=
               'select coletilla, descrip, sum(importe), otros, greatest(fecha,to_date('''
               || TO_CHAR(vfcierre, 'dd/mm/yyyy') || ''',''dd/mm/yyyy'')) fecha from ('
               || vtselec;
            vntraza := 150;
            --
            vtselec := vtselec
                       || ' ) group by coletilla, descrip, otros, greatest(fecha,to_date('''
                       || TO_CHAR(vfcierre, 'dd/mm/yyyy') || ''',''dd/mm/yyyy'')) ';
            vntraza := 160;
            --  
            OPEN c_rec FOR vtselec;

            vntraza := 170;
            -- Insertem en la taula de contabilitat
            FETCH c_rec
             INTO vcoletilla, vdescri, importe, votros, vfadm;
            LOOP
               vntraza := 190;

               IF c_rec%NOTFOUND THEN
                  EXIT;
               ELSE
                  IF importe <> 0 THEN
                     vntraza := 200;
                     l_idpago := pac_cuadre_adm.f_idpago(pttippag,pidpago,pidmovimiento);
                     l_idmovimiento := to_number(substr(pidmovimiento,0,7));
                     BEGIN
           
           --BEGIN  iaxis--4182  -WAJ
           if substr(votros, 1, 3) in ('251','255','256','248') then
                            l_idpago := pidmovimiento;
                     end if;
           --END  iaxis--4182  -WAJ
                    
                   
                        INSERT INTO contab_asient_interf
                                    (sinterf, ttippag, idpago,
                                     fconta, nasient,
                                     nlinea, ccuenta, ccoletilla,
                                     tapunte, iapunte, tdescri, fefeadm,
                                     cenlace, tlibro, otros, idmov)
                             VALUES (psinterf, pttippag, reg_det.nsinies,                 -- Version 44
                                     NVL(pfecha, TRUNC(f_sysdate)), reg.smodcon,
                                     reg_det.nlinea, substr(reg_det.ccuenta,0,6), vcoletilla,
                                     reg_det.tcuenta, importe, vdescri, vfadm,
                                     reg_det.claenlace, reg_det.tlibro, votros,  reg_det.nmovres);
                                     COMMIT;
                     EXCEPTION
                        WHEN OTHERS THEN
                           p_tab_error(f_sysdate, f_user, vobject, 2,
                                       'Error smodcon:' || reg.smodcon || ' nlinea:'
                                       || reg_det.nlinea || ' cproces:' || vproces,
                                       SQLERRM);
                           RETURN 1;
                     END;
                  -- IAXIS 4504 22/08/2019 actualizacion sinterf. 
                  BEGIN
                    UPDATE MOVCONTASAP M
                       SET M.CODESCENARIO = REG_DET.CODESCENARIO
                     WHERE M.NRECIBO = REG_DET.NSINIES
                       AND M.NSINIES = REG_DET.NSINIES
                       AND M.NMOVIMI = REG_DET.NMOVRES
                       AND M.CTIPCOA = REG_DET.NMOVRESDET;
                    COMMIT;
                  END;
                  -- IAXIS 4504 22/08/2019 actualizacion sinterf.
                  END IF;
                  vntraza := 210;

                  FETCH c_rec
                   INTO vcoletilla, vdescri, importe, votros, vfadm;
               END IF;
            END LOOP;

            CLOSE c_rec;
         END LOOP;
      END LOOP;
     

      vntraza := 220;

      --Control para invertir el tapunte
      IF NVL(pac_parametros.f_parempresa_n(pcempres, 'INVERT_APUNTE_CONTA'), 0) = 1 THEN
         FOR rc IN c_invert LOOP
            vntraza := 350;

            UPDATE contab_asient_interf
               SET tapunte = DECODE(tapunte, 'H', 'D', 'H'),
                   iapunte = ABS(iapunte)
             WHERE sinterf = psinterf
               AND ttippag = pttippag
               AND idpago = pidpago
               AND fconta = NVL(pfecha, TRUNC(f_sysdate))
               AND nasient = rc.nasient
               AND ccuenta = rc.ccuenta
               AND nlinea = rc.nlinea
               AND ccoletilla = rc.ccoletilla
               AND fefeadm = rc.fefeadm
               AND tdescri = rc.tdescri
               AND otros = rc.otros;
               COMMIT;
         END LOOP;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         IF c_rec%ISOPEN THEN
            CLOSE c_rec;
         END IF;

         p_tab_error(f_sysdate, f_user, vobject, vntraza,
                     'Error incontrolado en CCUENTA : ' || v_ccuenta_aux || ' NLINEA : '
                     || v_nlinea_aux,
                     SQLERRM);
         RETURN 1;
   END f_conta_int_res;
   -- 
END pac_cuadre_adm;
/

