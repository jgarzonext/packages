--------------------------------------------------------
--  DDL for Package Body PAC_GASTOS_FONDOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_GASTOS_FONDOS" IS
/****************************************************************************
            NOMBRE:       PAC_GASTOS_FONDOS
            PROPÓSITO:  Funciones para cálculo de los Gastos sobre Fondos (Comisiones)

            REVISIONES:
    Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------  ----------------------------------
    1.0        14/02/2011    APD     1.- Bug 17243: ENSA101 - Rebuts de comissió  - Creación package.
    2.0        28/04/2011    APD     2.- Bug 18326: ENSA101 - Generación Comisiones - Modificación Proceso

****************************************************************************/-- BUG 0016981 - 12/2010 - JRH  -  Proceso ALM
   e_param_error  EXCEPTION;
   e_object_error EXCEPTION;
   ult_momento    NUMBER := DBMS_UTILITY.get_time;

/*************************************************************************
      Generar Fichero
      psproces: Proceso
      pmodo: Modo
      Retorna diferente de 0 (un código de error) en caso de error
   *************************************************************************/
   FUNCTION f_generar_fichero(psproces IN NUMBER, pmodo IN VARCHAR2)
      RETURN NUMBER IS
      vnomsalida     VARCHAR2(100);
      vficherosalida UTL_FILE.file_type;
      vempresa       NUMBER;

      CURSOR c_proces IS
         SELECT *
           FROM fongast_cierre_previo
          WHERE sproces = psproces
            AND pmodo = 'P'
         UNION
         SELECT *
           FROM fongast_cierre
          WHERE sproces = psproces
            AND pmodo <> 'P';

      vobjectname    VARCHAR2(500) := 'PAC_GASTOS_FONDOS.f_generar_Fichero';
      vparam         VARCHAR2(500) := 'psproces:' || psproces || ' ' || 'pmodo:' || pmodo;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      v_linea        VARCHAR2(2000);
      pdata_proces   DATE;
      vpath          VARCHAR2(100);
   BEGIN
      vnumerr := 0;
      vnomsalida := '_GASTFON_' || TRIM(TO_CHAR(NVL(pdata_proces, f_sysdate), 'yyyymmdd'))
                    || '_' || TRIM(TO_CHAR(f_sysdate, 'hh24miss')) || '.txt';
      vpasexec := 2;
      vempresa := f_parinstalacion_n('EMPRESADEF');
      vpath := pac_nombres_ficheros.ff_ruta_fichero(vempresa, 10, 1);

      IF vpath IS NULL THEN
         vpath := f_parinstalacion_t('INFORMES');
      END IF;

      vficherosalida := UTL_FILE.fopen(vpath, vnomsalida, 'w', 32767);
      vpasexec := 3;
      --Cabecera
      v_linea := NULL;
      v_linea := v_linea || RPAD('SPROCES', 14, ' ');
      v_linea := v_linea || RPAD('FPROCES', 14, ' ');
      v_linea := v_linea || RPAD('CCFONDO', 14, ' ');
      v_linea := v_linea || RPAD('TFONDO', 100, ' ');
      v_linea := v_linea || RPAD('SSEGURO', 14, ' ');
      v_linea := v_linea || RPAD('IMPORTE_BASE', 20, ' ');
      v_linea := v_linea || RPAD('CCONCEP', 14, ' ');
      v_linea := v_linea || RPAD('CTIPOCALCUL', 14, ' ');
      v_linea := v_linea || RPAD('PORCEN', 20, ' ');
      v_linea := v_linea || RPAD('IMPORTE_RECIBO', 20, ' ');
      v_linea := v_linea || RPAD('NRECIBO', 10, ' ');
      vpasexec := 4;
      UTL_FILE.put_line(vficherosalida, v_linea);
      vpasexec := 5;

      FOR reg IN c_proces LOOP
         v_linea := NULL;
         v_linea := v_linea || RPAD(reg.sproces, 14, ' ');
         v_linea := v_linea || RPAD(TO_CHAR(reg.fproces, 'DD/MM/YYYY'), 14, ' ');
         v_linea := v_linea || RPAD(reg.ccfondo, 14, ' ');
         v_linea := v_linea || RPAD(reg.tfondo, 100, ' ');
         v_linea := v_linea || RPAD(reg.sseguro, 14, ' ');
         v_linea := v_linea || RPAD(ROUND(reg.importe_base, 3) * 1000, 20, ' ');
         v_linea := v_linea || RPAD(reg.cconcep, 14, ' ');
         v_linea := v_linea || RPAD(reg.ctipocalcul, 14, ' ');
         v_linea := v_linea || RPAD(ROUND(reg.porcen, 3) * 1000000000, 20, ' ');
         v_linea := v_linea || RPAD(ROUND(reg.importe_recibo, 3) * 1000, 20, ' ');
         v_linea := v_linea || RPAD(reg.nrecibo, 10, ' ');
         vpasexec := 6;
         UTL_FILE.put_line(vficherosalida, v_linea);
         vpasexec := 7;
      END LOOP;

      IF UTL_FILE.is_open(vficherosalida) THEN
         UTL_FILE.fclose(vficherosalida);
      END IF;

      vpasexec := 8;
      UTL_FILE.frename(vpath, vnomsalida, vpath, SUBSTR(vnomsalida,(LENGTH(vnomsalida) - 1)
                                                         * -1), TRUE);
      vpasexec := 9;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'Objeto invocado con parámetros erroneos');
         RETURN 1000005;   --Error al gravar la variable de contexto agente de producción.
      WHEN e_object_error THEN
         IF UTL_FILE.is_open(vficherosalida) THEN
            UTL_FILE.fclose(vficherosalida);
         END IF;

         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'Error al ejecutar procedimiento o funció - vnumerr: ' || vnumerr);
         RETURN 1000006;   --Error al gravar la variable de contexto agente de producción.
      WHEN OTHERS THEN
         IF UTL_FILE.is_open(vficherosalida) THEN
            UTL_FILE.fclose(vficherosalida);
         END IF;

         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1000001;   --Error al gravar la variable de contexto agente de producción.
   END f_generar_fichero;

   /*************************************************************************
      Funcion f_set_tabla_cierre
      Inserta en las tablas de cierres
      param in   pmodo : Modo (P-->Previo y R --> Real)
      param in   psproces : Número de proceso
      param in   pfproces : Fecha del proceso
      param in   pccodfon : codigo del fondo
      param in  psseguro : Sseguro
      param in   pimporte_base : Importe base
      param in  pcconcep : En caso de tipo comisión por cierre, la comision se calcula sobre un concepto
      param in  pctipocalcul : Tipo de Calculo para los Gastos del Fondo
      param in  ppgastos : Porcentaje a aplicar sobre el importe base del Fondo
      param in   pimporte_recibo : Importe final del recibo
      Retorna diferente de 0 (un código de error) en caso de error
   *************************************************************************/
   FUNCTION f_set_tabla_cierre(
      pmodo IN VARCHAR2,
      psproces IN NUMBER,
      pfproces IN DATE,
      pccodfon IN NUMBER,
      psseguro IN NUMBER,
      pimporte_base IN NUMBER,
      pcconcep IN NUMBER,
      pctipocalcul IN NUMBER,
      ppgastos IN NUMBER,
      pimporte_recibo IN NUMBER,
      pnrecibo IN NUMBER)
      RETURN NUMBER IS
      vtobjeto       VARCHAR2(500) := 'PAC_GASTOS_FONDOS.f_set_tabla_cierre';
      vparam         VARCHAR2(500)
         := 'pmodo:' || pmodo || ' - ' || 'psproces:' || psproces || ' - ' || 'pfproces:'
            || TO_CHAR(pfproces, 'DD/MM/YYYY') || ' - ' || 'pccodfon:' || pccodfon || ' - '
            || 'psseguro:' || psseguro || ' - ' || 'pimporte_base:' || pimporte_base || ' - '
            || 'pcconcep:' || pcconcep || ' - ' || 'pctipocalcul:' || pctipocalcul || ' - '
            || 'ppgastos:' || ppgastos || ' - ' || 'pimporte_recibo:' || pimporte_recibo
            || 'pnrecibo:' || pnrecibo;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      IF pmodo = 'R' THEN
         vpasexec := 2;

         INSERT INTO fongast_cierre
                     (sproces, fproces, ccfondo, tfondo, sseguro,
                      importe_base, cconcep, ctipocalcul, porcen, importe_recibo,
                      nrecibo)
              VALUES (psproces, pfproces, pccodfon, pac_isqlfor.f_fondo(psseguro), psseguro,
                      pimporte_base, pcconcep, pctipocalcul, ppgastos, pimporte_recibo,
                      pnrecibo);
      ELSE
         vpasexec := 3;

         INSERT INTO fongast_cierre_previo
                     (sproces, fproces, ccfondo, tfondo, sseguro,
                      importe_base, cconcep, ctipocalcul, porcen, importe_recibo,
                      nrecibo)
              VALUES (psproces, pfproces, pccodfon, pac_isqlfor.f_fondo(psseguro), psseguro,
                      pimporte_base, pcconcep, pctipocalcul, ppgastos, pimporte_recibo,
                      pnrecibo);
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vtobjeto, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 9901846;   --Error al insertar en la tabla de cierres
   END f_set_tabla_cierre;

   /*************************************************************************
      Funcion f_get_importe_gastos
      Busca el importe base y el importe final del recibo
      param in   pmodo : Modo (P-->Previo y R --> Real)
      param in   psproces : Número de proceso
      param in   pfproces : Fecha del proceso
      param in   pccodfon : codigo del fondo
      param in  psseguro : Sseguro
      param in   pimporte_base : Importe base
      param in  pcconcep : En caso de tipo comisión por cierre, la comision se calcula sobre un concepto
      param in  pctipocalcul : Tipo de Calculo para los Gastos del Fondo
      param in  ppgastos : Porcentaje a aplicar sobre el importe base del Fondo
      param in   pimporte_recibo : Importe final del recibo
      Retorna diferente de 0 (un código de error) en caso de error
   *************************************************************************/
   FUNCTION f_get_importe_gastos(
      pccodfon IN NUMBER,
      pctipocalcul IN NUMBER,
      pcconcep IN NUMBER,
      ppgastos IN NUMBER,
      piimpfij IN NUMBER,
      pclave IN NUMBER,
      pfproces IN DATE,
      pfperini IN DATE,
      pfperfin IN DATE,
      pimporte_base IN OUT NUMBER,
      pimporte_recibo IN OUT NUMBER)
      RETURN NUMBER IS
      vtobjeto       VARCHAR2(500) := 'PAC_GASTOS_FONDOS.f_get_importe_gastos';
      vparam         VARCHAR2(500)
         := 'pccodfon:' || pccodfon || ' - ' || 'pctipocalcul:' || pctipocalcul || ' - '
            || 'pcconcep:' || pcconcep || ' - ' || 'ppgastos:' || ppgastos || ' - '
            || 'piimpfij:' || piimpfij || ' - ' || 'pclave:' || pclave || ' - ' || 'pfproces:'
            || TO_CHAR(pfproces, 'DD/MM/YYYY') || ' - ' || 'pfperini:'
            || TO_CHAR(pfperini, 'DD/MM/YYYY') || ' - ' || 'pfperfin:'
            || TO_CHAR(pfperfin, 'DD/MM/YYYY');
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      e_error        EXCEPTION;
      v_importe_base NUMBER;
      v_importe_recibo NUMBER;
   BEGIN
      IF pctipocalcul = 1 THEN   -- Porcentaje
         IF pcconcep = 1 THEN   -- Valor del Fondo a fecha final periodo
            BEGIN
               SELECT t.ipatrimonio
                 INTO v_importe_base
                 FROM tabvalces t
                WHERE t.fvalor = (SELECT MAX(t2.fvalor)
                                    FROM tabvalces t2
                                   WHERE t2.ccesta = t.ccesta
                                     AND t2.fvalor <= pfproces)
                  AND t.ccesta = pccodfon;

               IF v_importe_base IS NULL THEN
                  vnumerr := 9901867;   -- Debe introducir el valor del fondo.
                  RAISE e_error;
               END IF;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  vnumerr := 9901867;   -- Debe introducir el valor del fondo.
                  RAISE e_error;
               WHEN OTHERS THEN
                  vnumerr := 9901845;   -- Error al leer datos de la tabla TABVALCES
                  RAISE e_error;
            END;
         ELSIF pcconcep = 2 THEN   -- Contribuciones totales del periodo
            -- Las polizas de un fondo se obtienen haciendo la join entre:
            -- FONDOS-->PLANPENSIONES-->CODIPROPLAN-->SEGUROS
            -- Y las contribuciones son los importes  de ctaseguro para cmovimi  en
            -- (1,2,4) positivos y cmovimi=51 en negativo. Mirar que la fefecto en
            -- ctaseguro esté en los márgenes de las fechas indicadas en el cierre.
            BEGIN
               SELECT NVL(SUM(DECODE(c.cmovimi, 51, c.imovimi * -1, c.imovimi)), 0)
                 INTO v_importe_base
                 FROM fondos f, planpensiones pp, proplapen p, seguros s, ctaseguro c
                WHERE f.ccodfon = pp.ccodfon
                  AND pp.ccodpla = p.ccodpla
                  AND p.sproduc = s.sproduc
                  AND s.sseguro = c.sseguro
                  AND f.ccodfon = pccodfon
                  AND c.cmovimi IN(1, 2, 4, 51)
                  AND((TRUNC(c.fvalmov) BETWEEN pfperini AND pfperfin
                       AND TRUNC(c.fcontab) <= pfperfin)
                      OR(TRUNC(c.fcontab) BETWEEN pfperini AND pfperfin
                         AND c.fvalmov <= pfperini));
            EXCEPTION
               WHEN OTHERS THEN
                  vnumerr := 104882;   -- Error al leer de la tabla CTASEGURO
                  RAISE e_error;
            END;
         END IF;

         -- Si el tipo de cálculo de gastos es porcentaje, una vez tenemos el importe base sólo hemos de
         -- multiplicar por el campo % de la tabla FONGAST para obtener el importe de los gastos.
         v_importe_recibo := v_importe_base *(ppgastos / 100);
      ELSIF pctipocalcul = 2 THEN   -- Importe
         -- Si el tipo de cálculo es importe el valor de los gastos es directamente el campo importe de FONGAST
         v_importe_base := piimpfij;
         v_importe_recibo := v_importe_base;
      ELSIF pctipocalcul = 3 THEN   -- Formula
         -- Si el tipo de cálculo es una fórmula el valor de los gastos es el devuelto por esa fórmula.
         --Se deja para maás adelante. Hay que definir un campo nuevo e inclusive nuevos terminos para las fórmula.
         v_importe_base := 0;
         v_importe_recibo := v_importe_base;
      END IF;

      pimporte_base := v_importe_base;
      pimporte_recibo := v_importe_recibo;
      RETURN 0;
   EXCEPTION
      WHEN e_error THEN
         pimporte_base := 0;
         pimporte_recibo := 0;
         p_tab_error(f_sysdate, f_user, vtobjeto, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN vnumerr;   --Error al insertar en la tabla de cierres
      WHEN OTHERS THEN
         pimporte_base := 0;
         pimporte_recibo := 0;
         p_tab_error(f_sysdate, f_user, vtobjeto, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 140999;   --Error no controlado
   END f_get_importe_gastos;

   /*************************************************************************
      Funcion f_genera_recibo
      Genera un recibo
      param in   pmodo : Modo (P-->Previo y R --> Real)
      param in   psproces : Número de proceso
      param in   pfproces : Fecha del proceso
      param in   pccodfon : codigo del fondo
      param in  psseguro : Sseguro
      param in   pimporte_base : Importe base
      param in  pcconcep : En caso de tipo comisión por cierre, la comision se calcula sobre un concepto
      param in  pctipocalcul : Tipo de Calculo para los Gastos del Fondo
      param in  ppgastos : Porcentaje a aplicar sobre el importe base del Fondo
      param in   pimporte_recibo : Importe final del recibo
      Retorna diferente de 0 (un código de error) en caso de error
   *************************************************************************/
   FUNCTION f_genera_recibo(
      pcempres IN NUMBER,
      pfproces IN DATE,
      pfperini IN DATE,
      pfperfin IN DATE,
      psseguro IN NUMBER,
      pimporte IN NUMBER,
      pcidioma IN NUMBER,
      pnrecibo OUT NUMBER)
      RETURN NUMBER IS
      vtobjeto       VARCHAR2(500) := 'PAC_GASTOS_FONDOS.f_genera_recibo';
      vparam         VARCHAR2(500)
         := 'psseguro:' || psseguro || ' - ' || 'pimporte:' || pimporte || ' - '
            || 'pcidioma:' || pcidioma || ' - ' || 'pfproces:'
            || TO_CHAR(pfproces, 'DD/MM/YYYY');
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      e_error        EXCEPTION;
      num_err        NUMBER;
      wnmovimi       NUMBER;
      wnrecibo       NUMBER;
      aux            NUMBER;
      wcdelega       NUMBER;
      wsmovagr       NUMBER;
      wliqmen        NUMBER;
      wliqlin        NUMBER;
      vcgarantfin    garanpro.cgarant%TYPE;
      v_cmodcom      comisionprod.cmodcom%TYPE;
   BEGIN
      wnrecibo := NULL;
      vpasexec := 2;
      num_err := f_buscanmovimi(psseguro, 1, 1, wnmovimi);

      IF num_err <> 0 THEN
         RAISE e_error;
      END IF;

      vpasexec := 3;
      num_err := f_insrecibo(psseguro, NULL, f_sysdate, pfperini, pfperfin, 5, NULL, NULL,
                             NULL, 0, NULL, wnrecibo, 'R', NULL, NULL, wnmovimi, f_sysdate);
      vpasexec := 4;

      IF num_err <> 0 THEN
         RAISE e_error;
      ELSE
         vpasexec := 5;

         BEGIN
            SELECT g.cgarant
              INTO vcgarantfin
              FROM seguros s, garanpro g
             WHERE s.sseguro = psseguro
               AND g.sproduc = s.sproduc
               AND NVL(f_pargaranpro_v(g.cramo, g.cmodali, g.ctipseg, g.ccolect,
                                       NVL(s.cactivi, 0), g.cgarant, 'TIPO'),
                       0) = 3;
         EXCEPTION
            WHEN OTHERS THEN
               BEGIN
                  SELECT g.cgarant
                    INTO vcgarantfin
                    FROM seguros s, garanpro g
                   WHERE s.sseguro = psseguro
                     AND g.sproduc = s.sproduc
                     AND NVL(f_pargaranpro_v(g.cramo, g.cmodali, g.ctipseg, g.ccolect,
                                             NVL(s.cactivi, 0), g.cgarant, 'TIPO'),
                             0) = 4;
               EXCEPTION
                  WHEN OTHERS THEN
                     num_err := 105710;   -- Garantía no encontrada en la tabla GARANPRO

                     IF num_err <> 0 THEN
                        RAISE e_error;
                     END IF;
               END;
         END;

         -- Bug 19777/95194 - 26/10/2011 -AMC
         IF f_es_renovacion(psseguro) = 0 THEN   -- es cartera
            v_cmodcom := 2;
         ELSE   -- si es 1 es nueva produccion
            v_cmodcom := 1;
         END IF;

         num_err := f_detrecibo(NULL, psseguro, wnrecibo, NULL, 'I', v_cmodcom, f_sysdate,
                                pfperini, pfperfin, NULL, pimporte, NULL, wnmovimi, 1, aux,
                                NULL, NULL, NULL, NULL, vcgarantfin);
         -- Fi Bug 19777/95194 - 26/10/2011 -AMC
         vpasexec := 6;

         IF num_err <> 0 THEN
            RAISE e_error;
         END IF;

         -- Si todo Ok Y 'GESTIONA_COBPAG' = 1, se envia recibo al SAP
         -- BUG 17247-  02/2011 - JRH  - 0017247: Envio pagos SAP
         IF NVL(pac_parametros.f_parempresa_n(pcempres, 'GESTIONA_COBPAG'), 0) = 1 THEN
            DECLARE
               vtipopago      NUMBER;
               vemitido       NUMBER;
               vsinterf       NUMBER;
               verror         NUMBER;
               vterminal      VARCHAR2(1000);
               pcestrec       NUMBER;
               xcestrec       NUMBER;
               xsmovrec       movrecibo.smovrec%TYPE;
               pfmovini       movrecibo.fmovini%TYPE;
               perror         VARCHAR2(1000);
               pctipcob       movrecibo.ctipcob%TYPE;
               pcmotmov       movrecibo.cmotmov%TYPE;
               pccobban       movrecibo.ccobban%TYPE;
               pcdelega       movrecibo.cdelega%TYPE;
               xsmovagr       movrecibo.smovagr%TYPE;
            BEGIN
               BEGIN
                  SELECT cestrec, cestant, smovrec, fmovini, ctipcob, cmotmov,
                         ccobban, cdelega, smovagr
                    INTO pcestrec, xcestrec, xsmovrec, pfmovini, pctipcob, pcmotmov,
                         pccobban, pcdelega, xsmovagr
                    FROM movrecibo
                   WHERE nrecibo = wnrecibo
                     AND fmovfin IS NULL;
               EXCEPTION
                  WHEN OTHERS THEN
                     pcestrec := NULL;
                     xcestrec := NULL;
               END;

               vtipopago := 4;   --Pago
               num_err := pac_user.f_get_terminal(pac_md_common.f_get_cxtusuario, vterminal);
               num_err := pac_con.f_emision_pagorec(pcempres, 1, vtipopago, wnrecibo, xsmovrec,
                                                    vterminal, vemitido, vsinterf, perror,
                                                    f_user);

               IF num_err <> 0
                  OR TRIM(perror) IS NOT NULL THEN
                  IF num_err = 0 THEN
                     num_err := 151323;
                  END IF;

                  --Mira si borraar sin_tramita_movpago porque se tiene que hacer un commit para que loo vea el sap
                  RAISE e_error;
               ELSE
                  UPDATE movrecibo
                     SET fmovfin = TRUNC(pfmovini)
                   WHERE smovrec = xsmovrec;   --actualizamos el último estado

                  -- poner aquí el cambio de estado . Que nuevo tipo?
                  BEGIN
                     SELECT smovrec.NEXTVAL
                       INTO xsmovrec
                       FROM DUAL;
                  EXCEPTION
                     WHEN OTHERS THEN
                        num_err := 104060;   -- Error al llegir la seqüència (smovrec) de BD
                        RAISE e_error;
                  END;

                  INSERT INTO movrecibo
                              (smovrec, cestrec, fmovini, fcontab, fmovfin, nrecibo, cestant,
                               cusuari, smovagr, fmovdia, cmotmov, ccobban, cdelega,
                               ctipcob)
                       VALUES (xsmovrec, '3', TRUNC(pfmovini), NULL, NULL, wnrecibo, pcestrec,
                               f_user, xsmovagr, f_sysdate, pcmotmov, pccobban, pcdelega,
                               pctipcob);
               END IF;
            END;
         END IF;
      END IF;

      -- Bug 18326 - APD - 28/04/2011 - se devuelve el nrecibo
      pnrecibo := wnrecibo;
      -- Fin Bug 18326 - APD - 28/04/2011
      RETURN 0;
   EXCEPTION
      WHEN e_error THEN
         p_tab_error(f_sysdate, f_user, vtobjeto, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN num_err;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vtobjeto, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 140999;   --Error no controlado
   END f_genera_recibo;

/*************************************************************************
      f_generar_gastos_fondos
      Genera alm de una póliza
      param in   psproces : Número de proceso
      param in   pfproces : Fecha del proceso
      param in   pcramo : Ramo
      param in   psproduc : Producto
      param in  psseguro : Sseguro
      Retorna diferente de 0 (un código de error) en caso de error
   *************************************************************************/
   FUNCTION f_generar_gastos_fondos(
      pcempres IN NUMBER,
      psproces IN NUMBER,
      pfperini IN DATE,
      pfperfin IN DATE,
      pfproces IN DATE,
      pcidioma IN NUMBER,
      pcagrup IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      psseguro IN NUMBER,
      pmodo IN VARCHAR2 DEFAULT 'R')
      RETURN NUMBER IS
      vtobjeto       VARCHAR2(500) := 'PAC_GASTOS_FONDOS.f_generar_gastos_fondos';
      vparam         VARCHAR2(500)
         := 'parámetros - psproces: ' || psproces || ' - pfperini: '
            || TO_CHAR(pfperini, 'DD/MM/YYYY') || ' - pfperfin: '
            || TO_CHAR(pfperfin, 'DD/MM/YYYY') || ' - pfproces: '
            || TO_CHAR(pfproces, 'DD/MM/YYYY') || ' -  pcramo:   ' || pcramo
            || ' -  psproduc:   ' || psproduc || ' - psseguro:   ' || psseguro
            || ' - pmodo:   ' || pmodo;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;

      CURSOR c_fondos IS
         SELECT fg.ccodfon, fg.cconcep, fg.ctipocalcul, fg.pgastos, fg.iimpfij, fg.clave
           FROM fondos f, fongast fg
          WHERE f.ccodfon = fg.ccodfon
            AND f.cempres = pcempres
            AND f.ffin IS NULL   -- Fondos activos
            AND(fg.finicio <= pfproces
                AND(fg.ffin > pfproces
                    AND fg.ffin IS NOT NULL)
                OR(fg.ffin IS NULL))   -- con gastos definidos a la fecha del cierre
            AND fg.ctipcom = 2   -- tipo de comision por cierre
            AND NOT EXISTS(SELECT 1
                             FROM fongast_cierre fc
                            WHERE fc.ccfondo = f.ccodfon
                              AND fc.fproces = pfproces);   --NO GENERADOS ENUN CIRRE ANTERIOR QUE HUBIERA DADO ERROR

      verrores       NUMBER := 0;
      vnprolin       NUMBER;
      --
      v_importe_base NUMBER;
      v_importe_recibo NUMBER;
      v_sseguro      seguros.sseguro%TYPE;
      indice         NUMBER;
      indice_error   NUMBER;
      contador       NUMBER;
      algun_error    NUMBER;
      num_err        NUMBER := 0;
      pnnumlin       NUMBER;
      texto          VARCHAR2(400);
      v_nrecibo      recibos.nrecibo%TYPE;   -- Bug 18326
      -- JLB - I - BUG 18423 COjo la moneda del producto
      vmoneda        monedas.cmoneda%TYPE;
   -- JLB - F - BUG 18423 COjo la moneda del producto
   BEGIN
      vpasexec := 0;

      IF pfperini IS NULL
         OR pfperfin IS NULL
         OR pfproces IS NULL
         OR psproces IS NULL
         OR pcempres IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 1;

      IF pmodo = 'P' THEN
         BEGIN
            EXECUTE IMMEDIATE ('TRUNCATE TABLE FONGAST_CIERRE_PREVIO');
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;
      END IF;

      vpasexec := 2;
      indice := 0;
      indice_error := 0;
      contador := 0;
      vpasexec := 3;

      -- Para cada fondo devuelto en el cursor hemos de obtener sobre que importe base calcular los gastos
      -- si el tipo de cálculo es porcentaje. Tenemos dos casos (tabla FONGAST):
      -- 1.  Sobre valor del fondo: Para este caso hemos de obtener para el fondo en cuestión el valor del
      -- campo NPARACT de la tabla TABVALCES a la fecha del cierre
      -- 2.  Sobre contribuciones del periodo: El importe será igual a la suma de las contribuciones de
      -- todas las pólizas del fondo para el periodo indicado en el cierre (fecha_ini/fecha_fin).
      FOR reg IN c_fondos LOOP
         vpasexec := 4;
         algun_error := 0;
         contador := contador + 1;
---------------------------------------------------
-- Se calcula el importe de los gastos del fondo --
---------------------------------------------------
         num_err := f_get_importe_gastos(reg.ccodfon, reg.ctipocalcul, reg.cconcep,
                                         reg.pgastos, reg.iimpfij, reg.clave, pfproces,
                                         pfperini, pfperfin, v_importe_base, v_importe_recibo);

         IF num_err <> 0 THEN
            ROLLBACK;
            texto := f_axis_literales(num_err, pcidioma);
            algun_error := 1;
            indice_error := indice_error + 1;
            pnnumlin := NULL;
            vnumerr := f_proceslin(psproces, texto || '. Paso: ' || vpasexec, reg.ccodfon,
                                   pnnumlin);
         END IF;

-------------------------
-- Se genera el recibo --
-------------------------
         vpasexec := 5;

         -- Una vez tenemos el importe de los gastos hemos de generar un recibo del tipo 5 para este
         -- importe. El sseguro asociado será el del certificado 0 del plan de pensiones preferente del
         -- fondo
         BEGIN
            SELECT s.sseguro
              INTO v_sseguro
              FROM fondos f, planpensiones pp, proplapen p, seguros s
             WHERE f.ccodfon = pp.ccodfon
               AND pp.ccodpla = p.ccodpla
               AND p.sproduc = s.sproduc
               AND f.ccodfon = reg.ccodfon
               AND NVL(pp.cplapref, 0) = 1   -- plan de pensiones preferente del fondo
               AND s.ncertif = 0;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               vpasexec := 6;

               -- Si sólo hay un plan y no está marcado como preferente, éste único plan
               -- seria el preferente
               BEGIN
                  SELECT s.sseguro
                    INTO v_sseguro
                    FROM fondos f, planpensiones pp, proplapen p, seguros s
                   WHERE f.ccodfon = pp.ccodfon
                     AND pp.ccodpla = p.ccodpla
                     AND p.sproduc = s.sproduc
                     AND f.ccodfon = reg.ccodfon
                     --AND pp.cplapref = 1   -- plan de pensiones preferente del fondo
                     AND s.ncertif = 0;
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;
               END;
            WHEN OTHERS THEN
               num_err := 101919;   -- Error al leer datos de la tabla SEGUROS
               ROLLBACK;
               texto := f_axis_literales(num_err, pcidioma);
               algun_error := 1;
               indice_error := indice_error + 1;
               pnnumlin := NULL;
               p_tab_error(f_sysdate, f_user, vtobjeto, vpasexec, vparam,
                           SQLCODE || '-' || SQLERRM);
               vnumerr := f_proceslin(psproces, texto || '. Paso: ' || vpasexec, v_sseguro,
                                      pnnumlin);
         END;

         vpasexec := 7;

         IF pmodo = 'R'
            AND algun_error = 0 THEN   -- no ha habido ningun error
            -- Se genera el recibo de tipo 5
            BEGIN
               SELECT pac_monedas.f_moneda_producto(sproduc)
                 INTO vmoneda
                 FROM seguros
                WHERE sseguro = v_sseguro;
            EXCEPTION
               WHEN OTHERS THEN
                  vmoneda := pac_md_common.f_get_parinstalacion_n('MONEDAINST');
            END;

            IF f_round(v_importe_recibo,
                       -- JLB 1
                       vmoneda) <> 0
               AND algun_error = 0 THEN   -- no ha habido ningun error
               vpasexec := 8;
               num_err := f_genera_recibo(pcempres, pfproces, pfperini, pfperfin, v_sseguro,

                                          -- jlb v_importe_recibo
                                          f_round(v_importe_recibo, vmoneda), pcidioma,
                                          v_nrecibo);

               IF num_err <> 0 THEN
                  ROLLBACK;
                  texto := f_axis_literales(num_err, pcidioma);
                  algun_error := 1;
                  indice_error := indice_error + 1;
                  pnnumlin := NULL;
                  p_tab_error(f_sysdate, f_user, vtobjeto, vpasexec, vparam,
                              SQLCODE || '-' || SQLERRM);
                  vnumerr := f_proceslin(psproces, texto || '. Paso: ' || vpasexec, v_sseguro,
                                         pnnumlin);
               END IF;
            END IF;   -- f_round(v_importe_recibo, 1) <> 0
         END IF;   -- pmodo = 'R'

-----------------------------------
-- Se informa la tabla de cierre --
-----------------------------------
         vpasexec := 9;

         IF algun_error = 0 THEN
            vpasexec := 10;
            num_err := f_set_tabla_cierre(pmodo, psproces, pfproces, reg.ccodfon, v_sseguro,
                                          v_importe_base, reg.cconcep, reg.ctipocalcul,
                                          reg.pgastos, v_importe_recibo, v_nrecibo);

            IF num_err <> 0 THEN
               ROLLBACK;
               texto := f_axis_literales(num_err, pcidioma);
               algun_error := 1;
               indice_error := indice_error + 1;
               pnnumlin := NULL;
               vnumerr := f_proceslin(psproces, texto || '. Paso: ' || vpasexec, v_sseguro,
                                      pnnumlin);
            END IF;
         END IF;

         -- Si ha habido algun error, se sale del cursor
         IF algun_error <> 0 THEN
            ROLLBACK;
         -- Bug 18326 - APD - 28/04/2011 - Hacer commit para cada recibo que ha ido bien
         --EXIT;
         -- Fin Bug 18326 - APD - 28/04/2011
         ELSE
            COMMIT;
         END IF;
      END LOOP;

      -- Bug 18326 - APD - 28/04/2011 - Hacer commit para cada recibo que ha ido bien
      -- Si todo ha ido bien, se guardan los datos
      -- El commit se realiza en p_proceso_cierre despuede de generar el fichero
      -- si todo ha ido bien
      /*
      IF algun_error = 0 THEN
         vpasexec := 11;
         --COMMIT;
         num_err := 109904;   -- Proceso finalizado correctamente
         texto := f_axis_literales(num_err, pcidioma);
         pnnumlin := NULL;
         vnumerr := f_proceslin(psproces, texto, NULL, pnnumlin);
         num_err := 0;
      END IF;
      */
      -- fin Bug 18326 - APD - 28/04/2011
      vpasexec := 8;
      vnumerr := f_proceslin(psproces,
                             'Nº Total de registros procesados = ' || contador
                             || ' ; Nº Registros Correctos = '
                             || TO_CHAR(contador - indice_error)
                             || ' , Nº Registros Incorrectos = ' || indice_error,
                             0, vnprolin, 4);
--
      vpasexec := 9;

      -- Bug 18326 - APD - 28/04/2011 -
      -- Si todos los registros se han procesaso correctamente, no ha habido ningun error
      IF indice_error = 0 THEN
         RETURN 0;
      ELSE
         -- si ha habido algun error en algun registro, se indica devolviendo 4 en la funcion
         RETURN 4;
      END IF;
   -- fin Bug 18326 - APD - 28/04/2011
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vtobjeto, vpasexec, vparam,
                     'Objeto invocado con parámetros erroneos');
         RETURN 1000005;   --Error al gravar la variable de contexto agente de producción.
      WHEN e_object_error THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, vtobjeto, vpasexec, vparam,
                     'Error al ejecutar procedimiento o funció - vnumerr: ' || vnumerr);
         RETURN 1000006;   --Error al gravar la variable de contexto agente de producción.
      WHEN OTHERS THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, vtobjeto, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1000001;   --Error al gravar la variable de contexto agente de producción.
   END f_generar_gastos_fondos;

   /************************************************************************
       f_proceso_cierre
          Proceso batch de inserción de la ALM en CTASEGURO

        Parámetros Entrada:

            psmodo : Modo (1-->Previo y '2 --> Real)
            pcempres: Empresa
            pmoneda: Divisa
            pcidioma: Idioma
            pfperini: Fecha Inicio
            pfperfin: Fecha Fin
            pfcierre: Fecha Cierre

        Parámetros Salida:

            pcerror : <>0 si ha habido algún error
            psproces : Proceso
            pfproces : Fecha en que se realiza el proceso

    *************************************************************************/
   PROCEDURE p_proceso_cierre(
      pmodo IN NUMBER,
      pcempres IN NUMBER,
      pmoneda IN NUMBER,
      pcidioma IN NUMBER,
      pfperini IN DATE,
      pfperfin IN DATE,
      pfcierre IN DATE,
      pcagrup IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      psseguro IN NUMBER,
      pcerror OUT NUMBER,
      psproces OUT NUMBER,
      pfproces OUT DATE) IS
      -- 16/9/04 CPM:
      --
      --    Proceso que lanzará el proceso de cierre de gastos sobre fondos de forma batch
      --
      --   Esta llamada tiene parámetros que no son necesarios por ser requeridos
      --     para que sea compatible con el resto de cierres programados.
      --
      vobjectname    VARCHAR2(500) := 'PAC_GASTOS_FONDOS.p_proceso_cierre';
      vparam         VARCHAR2(500)
         := 'parámetros - psproces: ' || psproces || ' - pfcierre: '
            || TO_CHAR(pfcierre, 'DD/MM/YYYY') || '   pcramo:   ' || pcramo
            || '  psproduc:   ' || psproduc || '  psseguro:   ' || psseguro || '  pmodo:   '
            || pmodo || ' pcempres:' || pcempres;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vnum_err       NUMBER;
      vindice        NUMBER;
      v_modo         VARCHAR2(1);
      vtitulo        VARCHAR2(2000);
      vtexto         VARCHAR2(100);
      vnprolin       NUMBER;
   BEGIN
      IF pfcierre IS NULL
         OR pfperini IS NULL
         OR pfperfin IS NULL
         OR pmodo IS NULL
         OR pcempres IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 1;

      IF pmodo = 2 THEN
         v_modo := 'R';
      ELSE
         v_modo := 'P';
      END IF;

      vpasexec := 2;
      vnum_err := f_desvalorfijo(54, pcidioma, TO_NUMBER(TO_CHAR(pfcierre, 'mm')), vtexto);
      vpasexec := 3;

      IF vnum_err <> 0 THEN
         RAISE e_param_error;
      END IF;

      IF v_modo = 'P' THEN   -- previo del cierre
         vtitulo := 'Previo Gastos sobre Fondos de ' || vtexto;
      ELSE
         vtitulo := 'Cierre Gastos sobre Fondos de ' || vtexto;
      END IF;

      IF pcagrup IS NOT NULL THEN
         vtitulo := vtitulo || ' Agrupación: ' || pcagrup;
      END IF;

      IF pcramo IS NOT NULL THEN
         vtitulo := vtitulo || ' Ramo: ' || pcramo;
      END IF;

      IF psproduc IS NOT NULL THEN
         vtitulo := vtitulo || ' Producto: ' || psproduc;
      END IF;

      IF psseguro IS NOT NULL THEN
         vtitulo := vtitulo || ' Póliza: ' || psseguro;
      END IF;

      vpasexec := 4;
      vnum_err := f_procesini(f_user, pcempres, 'CIERRE_GASTOS_FONDOS', vtitulo, psproces);

      IF vnum_err <> 0 THEN
         vnum_err := 109388;
         RAISE e_object_error;
      END IF;

      vpasexec := 5;
      vnum_err := f_generar_gastos_fondos(pcempres, psproces, pfperini, pfperfin, pfcierre,
                                          pcidioma, pcagrup, pcramo, psproduc, psseguro,
                                          v_modo);
      vpasexec := 6;

      -- Bug 18326 - APD - 28/04/2011 -
      -- si f_generar_gastos_fondos devuelve 0 --> todos los registros procesados correctos
      -- si f_generar_gastos_fondos devuelve 4 --> algun registro procesado ha dado error
      -- en ambos casos queremos que se genere el fichero
      IF vnum_err IN(0, 4) THEN
         vnumerr := f_generar_fichero(psproces, v_modo);

         IF vnumerr <> 0 THEN
            vnumerr := 151632;
            vnumerr := f_proceslin(psproces,
                                   vnumerr || ' - ' || f_axis_literales(vnumerr, f_idiomauser),
                                   psseguro, vnprolin, 1);
         END IF;
      END IF;

      -- Bug 18326 - APD - 28/04/2011 - Hacer commit para cada recibo que ha ido bien
      -- se comenta el COMMIT y el ROLLBACK
      -- Bug 18326 - APD - 28/04/2011 -
      -- si f_generar_gastos_fondos devuelve 0 --> todos los registros procesados correctos
      -- si f_generar_gastos_fondos devuelve 4 --> algun registro procesado ha dado error
      -- solo si la funcion devuelve 0 se debe finalizar el proceso de cierre correctamente
      -- si la funcion devuelve 4 se debe finalizar el proceso indicando que ha habido un error
      IF vnum_err = 0 THEN
         pcerror := 0;
         vpasexec := 7;
         vnum_err := f_procesfin(psproces, 0);

         IF vnum_err <> 0 THEN
            vnum_err := 800727;
            RAISE e_object_error;
         END IF;

         vpasexec := 8;
      --COMMIT;
      ELSE
         pcerror := vnum_err;
         vpasexec := 9;
         vnum_err := f_procesfin(psproces, 1);

         IF vnum_err <> 0 THEN
            vnum_err := 800727;
            RAISE e_object_error;
         END IF;

         vpasexec := 10;
      --ROLLBACK;
      END IF;

      -- fin Bug 18326 - APD - 28/04/2011
      vpasexec := 11;
      pfproces := f_sysdate;
   EXCEPTION
      WHEN e_param_error THEN
         pcerror := 1000005;
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'Objeto invocado con parámetros erroneos');
      --Error al grabar la variable de contexto agente de producción.
      WHEN e_object_error THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'Error al ejecutar procedimiento o función - vnumerr: ' || vnumerr);
         pcerror := vnumerr;
         ROLLBACK;
      --Error al grabar la variable de contexto agente de producción.
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         pcerror := 1000001;
         ROLLBACK;
   --Error al grabar la variable de contexto agente de producción.
   END p_proceso_cierre;

    /************************************************************************
      proceso_batch_cierre
         Proceso batch de inserción de la PB en CTASEGURO

       Parámetros Entrada:

           psmodo : Modo (1-->Previo y '2 --> Real)
           pcempres: Empresa
           pmoneda: Divisa
           pcidioma: Idioma
           pfperini: Fecha Inicio
           pfperfin: Fecha Fin
           pfcierre: Fecha Cierre

       Parámetros Salida:

           pcerror : <>0 si ha habido algún error
           psproces : Proceso
           pfproces : Fecha en que se realiza el proceso

   *************************************************************************/
   PROCEDURE proceso_batch_cierre(
      pmodo IN NUMBER,
      pcempres IN NUMBER,
      pmoneda IN NUMBER,
      pcidioma IN NUMBER,
      pfperini IN DATE,
      pfperfin IN DATE,
      pfcierre IN DATE,
      pcerror OUT NUMBER,
      psproces OUT NUMBER,
      pfproces OUT DATE) IS
      -- 16/9/04 CPM:
      --
      --    Proceso que lanzará el proceso de cierre de ahorro de forma batch
      --
      --   Esta llamada tiene parámetros que no son necesarios por ser requeridos
      --     para que sea compatible con el resto de cierres programados.
      --
      vnum_err       NUMBER;
      vindice        NUMBER;
      v_modo         VARCHAR2(1);
   BEGIN
      p_proceso_cierre(pmodo, pcempres, pmoneda, pcidioma, pfperini, pfperfin, pfcierre, NULL,
                       NULL, NULL, NULL, pcerror, psproces, pfproces);

      IF NVL(pcerror, 0) <> 0 THEN
         pcerror := 109388;
      END IF;
   END proceso_batch_cierre;
-- Fi BUG 0016981 - 12/2010 - JRH
END pac_gastos_fondos;

/

  GRANT EXECUTE ON "AXIS"."PAC_GASTOS_FONDOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_GASTOS_FONDOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_GASTOS_FONDOS" TO "PROGRAMADORESCSI";
