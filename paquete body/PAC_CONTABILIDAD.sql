--------------------------------------------------------
--  DDL for Package Body PAC_CONTABILIDAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_CONTABILIDAD" AS
/******************************************************************************
   NOMBRE:    PAC_CONTABILIDAD
   PROPÓSITO: Contiene el módulo de contabilidad de la capa de negocio

   REVISIONES:
   Ver        Fecha       Autor            Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        27/08/2008  SBG              1. Creación del package.
   2.0        14/12/2010  ICV              2. 0016908: APRM - Contabilidad diaria
   3.0        23/02/2011  APD              3. 0017406: ENSA101 - SAP - Interficie Contabilistica
   4.0        29/06/2011  ICV              4. 0018917: MSGV003 - Comptabilitat: El detall de la comptabilitat diaria no funciona.
   5.0        03/05/2012  MDS              5. 0020663: LCOL_F001-Contabilidad: Reportes y Validaciones
******************************************************************************/

   /*************************************************************************
      Procedimiento que graba en MODCONTA y DETMODIF
   *************************************************************************/
   PROCEDURE p_grabar_plantilla(
      p_cempres IN NUMBER,
      p_smodcon IN NUMBER,
      p_casient IN NUMBER,
      p_cprogra IN NUMBER,
      p_ffin IN DATE,
      p_newsmod OUT NUMBER,
      p_error OUT NUMBER) IS
      v_cmodifi      NUMBER(1);
      v_smodifi      NUMBER(6);
      v_smodcon      modconta.smodcon%TYPE;
      v_fini         modconta.fini%TYPE;
      v_bsortir      BOOLEAN := FALSE;
   BEGIN
      --Si és una modificació, abans de fer l'INSERT hem de fer un UPDATE
      BEGIN
         SELECT smodcon, fini
           INTO v_smodcon, v_fini
           FROM modconta
          WHERE cempres = p_cempres
            AND casient = p_casient
            AND ffin IS NULL;

         IF p_ffin IS NOT NULL
            AND p_ffin < v_fini THEN
            p_error := 110361;
            v_bsortir := TRUE;
         ELSE
            IF pac_cuadre_adm.f_esta_cerrado(p_cempres, LAST_DAY(TRUNC(p_ffin))) = 1 THEN
               p_error := 107855;
               v_bsortir := TRUE;
            ELSE
               p_error := 105039;

               UPDATE modconta
                  SET ffin = NVL(p_ffin, TRUNC(f_sysdate))
                WHERE cempres = p_cempres
                  AND smodcon = v_smodcon;

               v_cmodifi := 2;
            END IF;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            v_cmodifi := 1;
      END;

      IF NOT v_bsortir THEN
         IF p_ffin IS NULL THEN
            p_error := 105039;

            --Obtenim el nou SMODCON
            SELECT smodcon.NEXTVAL
              INTO v_smodcon
              FROM DUAL;

            --Insertem a MODCONTA
            INSERT INTO modconta
                        (smodcon, cempres, casient, cprogra, fini)
                 VALUES (v_smodcon, p_cempres, p_casient, p_cprogra, TRUNC(f_sysdate));

            p_newsmod := v_smodcon;
         ELSE
            -- Si la data final està informada, es tracta d'una baixa, no fem insert.
            v_cmodifi := 4;
         END IF;

         p_error := 105394;

         --Obtenim el SMODIFI
         SELECT smodifi.NEXTVAL
           INTO v_smodifi
           FROM DUAL;

         --Insertem a DETMODIF
         INSERT INTO detmodif
                     (smodcon, smodifi, cmodifi, cusuari, fmodifi, crevisi)
              VALUES (v_smodcon, v_smodifi, v_cmodifi, f_user, f_sysdate, 1);

         COMMIT;
         p_error := 0;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END p_grabar_plantilla;

   /*************************************************************************
      Procedimiento que elimina de DETMODCONTA según parámetros de entrada
   *************************************************************************/
   PROCEDURE p_del_detalleplantilla(
      p_smodcon IN NUMBER,
      p_cempres IN NUMBER,
      p_nlinea IN NUMBER,
      p_error OUT NUMBER) IS
      v_smodifi      NUMBER(6);
   BEGIN
      p_error := 105020;

      DELETE      detmodconta
            WHERE smodcon = p_smodcon
              AND cempres = p_cempres
              AND nlinea = p_nlinea;

      p_error := 105394;

      --Obtenim el SMODIFI
      SELECT smodifi.NEXTVAL
        INTO v_smodifi
        FROM DUAL;

      --Insertem a DETMODIF
      INSERT INTO detmodif
                  (smodcon, smodifi, cmodifi, cusuari, fmodifi, crevisi)
           VALUES (p_smodcon, v_smodifi, 4, f_user, f_sysdate, 1);

      COMMIT;
      p_error := 0;
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END p_del_detalleplantilla;

   /*************************************************************************
      Procedimiento que graba en DETMODCONTA
   *************************************************************************/
   PROCEDURE p_grabar_detalleplantilla(
      p_smodcon IN NUMBER,
      p_cempres IN NUMBER,
      p_nlinea IN NUMBER,
      p_tdescri IN VARCHAR2,
      p_ccuenta IN VARCHAR2,
      p_tcuenta IN VARCHAR2,
      p_tselect IN VARCHAR2,
      p_newnlin OUT NUMBER,
      p_error OUT NUMBER) IS
      v_smodifi      NUMBER(6);
   BEGIN
      IF p_nlinea IS NULL THEN   -- ALTA
         p_error := 105039;

         --Obtenim el NLINEA
         SELECT NVL(MAX(nlinea), 0) + 1
           INTO p_newnlin
           FROM detmodconta
          WHERE smodcon = p_smodcon
            AND cempres = p_cempres;

         --Insertem
         INSERT INTO detmodconta
                     (smodcon, cempres, nlinea, tdescri, ccuenta, tcuenta,
                      tscuadre)
              VALUES (p_smodcon, p_cempres, p_newnlin, p_tdescri, p_ccuenta, p_tcuenta,
                      p_tselect);
      ELSE   -- MODIFICACIÓ
         p_error := 105040;
         p_newnlin := p_nlinea;

         --Modifiquem
         UPDATE detmodconta
            SET tdescri = p_tdescri,
                ccuenta = p_ccuenta,
                tcuenta = p_tcuenta,
                tscuadre = p_tselect
          WHERE smodcon = p_smodcon
            AND cempres = p_cempres
            AND nlinea = p_nlinea;
      END IF;

      p_error := 105394;

      --Obtenim el SMODIFI
      SELECT smodifi.NEXTVAL
        INTO v_smodifi
        FROM DUAL;

      --Insertem a DETMODIF
      INSERT INTO detmodif
                  (smodcon, smodifi, cmodifi, cusuari, fmodifi, crevisi)
           VALUES (p_smodcon, v_smodifi, 3, f_user, f_sysdate, 1);

      COMMIT;
      p_error := 0;
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END p_grabar_detalleplantilla;

   /*************************************************************************
      Procedimiento que duplica un modelo contable e informa la fecha de fin
      del modelo del parámetro
   *************************************************************************/
   PROCEDURE p_duplicarmodelo(
      p_cempres IN NUMBER,
      p_smodcon IN NUMBER,
      p_newsmod OUT NUMBER,
      p_error OUT NUMBER) IS
      v_smodifi      NUMBER(6);
   BEGIN
      p_error := 105040;

      --Abans de fer l'INSERT hem de fer un UPDATE
      UPDATE modconta
         SET ffin = TRUNC(f_sysdate)
       WHERE smodcon = p_smodcon
         AND cempres = p_cempres;

      p_error := 105039;

      --Obtenim el nou SMODCON
      SELECT smodcon.NEXTVAL
        INTO p_newsmod
        FROM DUAL;

      --Insertem a MODCONTA
      INSERT INTO modconta
                  (smodcon, cempres, casient, cprogra, fini)
         SELECT p_newsmod, cempres, casient, cprogra, TRUNC(f_sysdate)
           FROM modconta
          WHERE smodcon = p_smodcon
            AND cempres = p_cempres;

      --Insertem a DETMODCONTA
      INSERT INTO detmodconta
                  (smodcon, cempres, cprogra, nlinea, cclavep, cclaven, tdescri, ccuenta,
                   ccompan, cme, cbaja, tcuenta, tscuadre)
         SELECT p_newsmod, p_cempres, cprogra, nlinea, cclavep, cclaven, tdescri, ccuenta,
                ccompan, cme, cbaja, tcuenta, tscuadre
           FROM detmodconta
          WHERE smodcon = p_smodcon
            AND cempres = p_cempres;

      p_error := 105394;

      --Obtenim el SMODIFI
      SELECT smodifi.NEXTVAL
        INTO v_smodifi
        FROM DUAL;

      --Insertem a DETMODIF
      INSERT INTO detmodif
                  (smodcon, smodifi, cmodifi, cusuari, fmodifi, crevisi)
           VALUES (p_newsmod, v_smodifi, 1, f_user, f_sysdate, 1);

      COMMIT;
      p_error := 0;
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END p_duplicarmodelo;

   /*************************************************************************
      Función que devuelve un sys_refcursor con los registros de la contabilidad diaria filtrado por los parametros
      del modelo del parámetro
      param in  pcempres : código empresa
      param in  pfcontabini : fecha de contabilidad inicial
      param in  pfcontabfin : fecha de contabilidad final
      param in  pftraspasini : fecha de traspaso inicial
      param in  pftraspasfin : fecha de traspaso inicial
      param in  pchecktraspas : traspasados o no
      param out  vquery : Cursor con los resultados
   *************************************************************************/
   FUNCTION f_get_contabilidad_diaria(
      pcempres IN NUMBER,
      pfcontabini IN DATE,
      pfcontabfin IN DATE,
      pftraspasini IN DATE,
      pftraspasfin IN DATE,
      pfadminini IN DATE,
      pfadminfin IN DATE,
      pchecktraspas IN NUMBER,
      vquery OUT VARCHAR2)
      RETURN NUMBER IS
      --
      vwhere         VARCHAR2(3000) := ' where 1=1 ';
   BEGIN
      IF pcempres IS NOT NULL THEN
         vwhere := vwhere || ' and cempres = ' || pcempres;
      END IF;

      IF pchecktraspas = 1 THEN
         vwhere := vwhere || ' AND ftraspaso IS NULL';
      ELSE
         IF pftraspasini IS NOT NULL THEN
            vwhere := vwhere || ' AND trunc(ftraspaso) >= to_date('''
                      || TO_CHAR(pftraspasini, 'DD/MM/YYYY') || ''',''DD/MM/YYYY'') ';
         END IF;

         IF pftraspasfin IS NOT NULL THEN
            vwhere := vwhere || ' AND trunc(ftraspaso) <= to_date('''
                      || TO_CHAR(pftraspasfin, 'DD/MM/YYYY') || ''',''DD/MM/YYYY'') ';
         END IF;

         IF pfcontabini IS NOT NULL THEN
            vwhere := vwhere || ' AND trunc(fconta) >= to_date('''
                      || TO_CHAR(pfcontabini, 'DD/MM/YYYY') || ''',''DD/MM/YYYY'') ';
         END IF;

         IF pfcontabfin IS NOT NULL THEN
            vwhere := vwhere || ' AND trunc(fconta) <= to_date('''
                      || TO_CHAR(pfcontabfin, 'DD/MM/YYYY') || ''',''DD/MM/YYYY'') ';
         END IF;

         IF pfadminini IS NOT NULL THEN
            vwhere := vwhere || ' AND trunc(fefeadm) >= to_date('''
                      || TO_CHAR(pfadminini, 'DD/MM/YYYY') || ''',''DD/MM/YYYY'') ';
         END IF;

         IF pfadminfin IS NOT NULL THEN
            vwhere := vwhere || ' AND trunc(fefeadm) <= to_date('''
                      || TO_CHAR(pfadminfin, 'DD/MM/YYYY') || ''',''DD/MM/YYYY'') ';
         END IF;
      END IF;

      vquery :=
         'SELECT ccuenta, tdescri, fconta, fefeadm, cproces, ftraspaso, decode (TAPUNTE, ''D'', f_axis_literales(9908682, f_usu_idioma), ''H'', f_axis_literales(9908683, f_usu_idioma)) tapunte, iapunte, nlinea, nasient, cpais, cenlace
         FROM CONTAB_ASIENT_DIA '
         || vwhere;
      --p_control_error('xpl', 'query', vquery);
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_contabiliza.f_get_contabilidad_diaria', 1,
                     'Error incontrolado', SQLERRM);
         RETURN 1;
   END f_get_contabilidad_diaria;

   /*************************************************************************
       Función que ejecuta el map 321
       param in  pcempres : código empresa
       param out  pnomfichero : Nombre fichero
    *************************************************************************/
   FUNCTION f_traspasar(
      pcempres IN NUMBER,
      pfecini IN DATE,
      pfecfin IN DATE,
      pnomfichero OUT VARCHAR2,
      pfadminini IN DATE DEFAULT NULL,
      pfadminfin IN DATE DEFAULT NULL)
      RETURN NUMBER IS
      num_err        NUMBER;
      wpath          map_cabecera.tparpath%TYPE;
      wtdesmap       map_cabecera.tdesmap%TYPE;
      wruta          VARCHAR2(100);
      wttipomap      map_cabecera.ttipomap%TYPE;
      wttipotrat     map_cabecera.ttipotrat%TYPE;
      psmapead       NUMBER;
      wnom           VARCHAR2(200);
      pclinea        VARCHAR2(4000);
      pcmapead       VARCHAR2(200);
      vfichero       VARCHAR2(4000);
      v_dummy        NUMBER;
   BEGIN
      SELECT COUNT('1')
        INTO v_dummy
        FROM contab_asient_dia c
       WHERE (pfecini IS NULL
              OR TRUNC(c.fconta) >= pfecini)
         AND(pfecfin IS NULL
             OR TRUNC(c.fconta) <= pfecfin)
         AND(pfadminini IS NULL
             OR TRUNC(c.fefeadm) >= pfadminini)
         AND(pfadminfin IS NULL
             OR TRUNC(c.fefeadm) <= pfadminfin)
         AND c.ftraspaso IS NULL
         AND c.cempres = pcempres;

      IF v_dummy = 0 THEN
         RETURN 9903410;
      END IF;

      pcmapead := pac_cuadre_adm.f_obtener_map(pcempres);

      -- Bug 17406 - APD - 23/02/2011 - El nombre del fichero de Interficie Contabilistica
      -- para ENSA (map = 440) debe ser AXIS#YYYYMMDDHHMI.txt
      -- se realiza el REPLACE del nombre del fichero

      --Bug.: 21102 - ICV - 28/01/2012
      SELECT DECODE(INSTR(UPPER(tdesmap), '#YYYYMMDDHHMISS'),
                    0, DECODE(INSTR(UPPER(tdesmap), '#YYYYMMDDHHMI'),
                              0, tdesmap,
                              REPLACE(UPPER(tdesmap), '#YYYYMMDDHHMI',
                                      TO_CHAR(f_sysdate, 'yyyymmddhh24mi'))),
                    REPLACE(UPPER(tdesmap), '#YYYYMMDDHHMISS',
                            TO_CHAR(f_sysdate, 'yyyymmddhh24miss'))),
             tparpath || '_C'
        INTO wtdesmap,
             wpath
        FROM map_cabecera
       WHERE cmapead = pcmapead;

      -- Fin Bug 17406 - APD - 23/02/2011
      wruta := f_parinstalacion_t(wpath);

      SELECT COUNT(1)
        INTO v_dummy
        FROM detmodconta_dia
       WHERE cempres <> 2
         AND cempres = pcempres;

      IF v_dummy = 0 THEN
         num_err := pac_map.f_extraccion(pcmapead,
                                         TO_CHAR(pfecini, 'ddmmrrrr') || '|'
                                         || TO_CHAR(pfecfin, 'ddmmrrrr') || '|' || pcempres,
                                         wtdesmap, vfichero);
      ELSE
         num_err := pac_map.f_extraccion(pcmapead,
                                         TO_CHAR(pfecini, 'ddmmrrrr') || '|'
                                         || TO_CHAR(pfecfin, 'ddmmrrrr') || '|' || pcempres
                                         || '|' || TO_CHAR(pfadminini, 'ddmmrrrr') || '|'
                                         || TO_CHAR(pfadminfin, 'ddmmrrrr'),
                                         wtdesmap, vfichero);
      END IF;

      pnomfichero := vfichero;

      IF num_err = 0 THEN
         UPDATE contab_asient_dia c
            SET ftraspaso = f_sysdate
          WHERE (pfecini IS NULL
                 OR TRUNC(c.fconta) >= pfecini)
            AND(pfecfin IS NULL
                OR TRUNC(c.fconta) <= pfecfin)
            AND(pfadminini IS NULL
                OR TRUNC(c.fefeadm) >= pfadminini)
            AND(pfadminfin IS NULL
                OR TRUNC(c.fefeadm) <= pfadminfin)
            AND ftraspaso IS NULL
            AND c.cempres = pcempres;
      END IF;

      RETURN num_err;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_contabiliza.f_traspasar', 1,
                     'Error incontrolado', SQLERRM);
         RETURN 1;
   END f_traspasar;

   PROCEDURE p_montar_fichero(
      pcempres IN NUMBER,
      pfcontabini IN DATE,
      pfcontabfin IN DATE,
      pftraspasini IN DATE,
      pftraspasfin IN DATE,
      pfadminini IN DATE,
      pfadminfin IN DATE,
      pchecktraspas IN NUMBER,
      pcidioma IN NUMBER,
      pnomfichero OUT VARCHAR2) IS
      vtraza         NUMBER;
      vquery         VARCHAR2(3000);
      cur            sys_refcursor;
      vcamp1         VARCHAR2(34);
      vcamp2         VARCHAR2(1000);
      vcamp3         DATE;
      vcamp4         DATE;
      vcamp5         NUMBER;
      vcamp6         DATE;
	  -- BUG PRBMANT-49 30/06/2016  JMT Se amplia el tamaño de la variable vcamp7
      vcamp7         VARCHAR2(100);
      vcamp8         NUMBER;
      vcamp9         VARCHAR2(3000);
      vcamp10        VARCHAR2(3000);
      vcamp11        VARCHAR2(3000);
      vcamp12        VARCHAR2(3000);
      vcamps         VARCHAR2(3000);
      v_fitxer       UTL_FILE.file_type;
      v_path         VARCHAR2(100);
      v_tfitxer      VARCHAR2(100);
      vnum_err       NUMBER;
      vcampo121      VARCHAR2(3000);
      vcampo122      VARCHAR2(3000);
      vcampo123      VARCHAR2(3000);
      v_cenlace_sub  VARCHAR2(400);
      v_vcamp5       VARCHAR2(100);   -- Bug 20663 - MDS - 04/05/2012
      --BUG 37097 - 210918 KJSC 28/07/2015 Crear variables (v_posdescri, vcamp02)
      v_posdescri    NUMBER;
      vcamp021       VARCHAR2(1000);
      vcamp022       VARCHAR2(1000);
   BEGIN
      --BUG 37097 - 210918 KJSC 28/07/2015 Crear variable (v_posdescri)
      v_posdescri := NVL(pac_parametros.f_parempresa_n(pcempres, 'INFCONTA_POSDESCRI'), 0);
      vtraza := 1;
      v_path := f_parinstalacion_t('INFORMES');
      v_tfitxer := 'contab_asient_dia' || TO_CHAR(f_sysdate, 'YYYYMMDDMISS') || '.csv';
      v_fitxer := UTL_FILE.fopen(v_path, v_tfitxer, 'w');
      vnum_err := f_get_contabilidad_diaria(pcempres, pfcontabini, pfcontabfin, pftraspasini,
                                            pftraspasfin, pfadminini, pfadminfin,
                                            pchecktraspas, vquery);

      OPEN cur FOR vquery;

      --BUG 37097 - 210918 KJSC 28/07/2015 Crear variable (v_posdescri)
      IF v_posdescri = 0 THEN
         --ccuenta, tdescri, fconta, fefeadm, cproces, ftraspaso, tapunte, iapunte
         vcamps := f_axis_literales(9000533, pcidioma) || ';'
                   || f_axis_literales(100588, pcidioma) || ';'
                   || f_axis_literales(1000575, pcidioma) || ';'
                   || f_axis_literales(1000596, pcidioma) || ';'
                   || f_axis_literales(1000576, pcidioma) || ';'
                   || f_axis_literales(9901135, pcidioma) || ';'
                   || f_axis_literales(9001197, pcidioma) || ';'
                   || f_axis_literales(100563, pcidioma);
      ELSE
         --ccuenta, coletilla, tdescri, fconta, fefeadm, cproces, ftraspaso, tapunte, iapunte
         vcamps := f_axis_literales(9000533, pcidioma) || ';'
                   || f_axis_literales(9908367, pcidioma)
                   || ';'   --coletilla BUG 37097 - 210918 KJSC 28/07/2015
                   || f_axis_literales(100588, pcidioma) || ';'
                   || f_axis_literales(1000575, pcidioma) || ';'
                   || f_axis_literales(1000596, pcidioma) || ';'
                   || f_axis_literales(1000576, pcidioma) || ';'
                   || f_axis_literales(9901135, pcidioma) || ';'
                   || f_axis_literales(9001197, pcidioma) || ';'
                   || f_axis_literales(100563, pcidioma);
      END IF;

      v_cenlace_sub := pac_parametros.f_parlistado_t(pcempres, 'CENLACE_CONTA_SUB');

      IF v_cenlace_sub IS NOT NULL THEN
         vcamps := vcamps || ';' || f_axis_literales(9903387, pcidioma);   --tipo de comprobante
         vcamps := vcamps || ';' || f_axis_literales(100588, pcidioma);   --Descripción
         vcamps := vcamps || ';' || f_axis_literales(9903314, pcidioma);   --Libro Contable
      END IF;

      UTL_FILE.put_line(v_fitxer, vcamps);

      LOOP
         FETCH cur
          INTO vcamp1, vcamp2, vcamp3, vcamp4, vcamp5, vcamp6, vcamp7, vcamp8, vcamp9,
               vcamp10, vcamp11, vcamp12;

         EXIT WHEN cur%NOTFOUND;

-- Ini Bug 20663 - MDS - 04/05/2012
/*
         IF NVL(pac_parametros.f_parempresa_n(pcempres, 'INI_PROC_CONTA'), 0) <> 0 THEN
            vcamp5 := SUBSTR(vcamp5,
                             pac_parametros.f_parempresa_n(pcempres, 'INI_PROC_CONTA'),
                             LENGTH(vcamp5));
         END IF;
*/
--si supera los 15 caracteres, poner apóstrofe por la izquierda para engañar al excel
         IF LENGTH(vcamp5) >= 15 THEN
            v_vcamp5 := CHR(39) || TO_CHAR(vcamp5);
         ELSE
            v_vcamp5 := TO_CHAR(vcamp5);
         END IF;

         --BUG 37097 - 210918 KJSC 28/07/2015 Preguntar por la variable (v_posdescri)
         IF v_posdescri = 0 THEN
            -- Ini Bug 20663 - MDS - 04/05/2012
            vcamps := vcamp1 || ';' || vcamp2 || ';' || TO_CHAR(vcamp3, 'YYYYMMDD') || ';'
                      || TO_CHAR(vcamp4, 'YYYYMMDD') || ';' || v_vcamp5 || ';'
                      || TO_CHAR(vcamp6, 'YYYYMMDD') || ';' || vcamp7 || ';'
                      || TO_CHAR(vcamp8);
         ELSE
            vcamp021 := SUBSTR(vcamp2, 1, v_posdescri - 1);
            vcamp022 := SUBSTR(vcamp2, v_posdescri);
            vcamps := vcamp1 || ';' || vcamp021 || ';' || vcamp022 || ';'
                      || TO_CHAR(vcamp3, 'YYYYMMDD') || ';' || TO_CHAR(vcamp4, 'YYYYMMDD')
                      || ';' || v_vcamp5 || ';' || TO_CHAR(vcamp6, 'YYYYMMDD') || ';'
                      || vcamp7 || ';' || TO_CHAR(vcamp8);
         END IF;

         IF v_cenlace_sub IS NOT NULL THEN
            vcampo123 := SUBSTR(vcamp12, v_cenlace_sub + 1, LENGTH(vcamp12));   --Libro contable
            vcampo121 := SUBSTR(vcamp12, 1, v_cenlace_sub);   --Comprobante contable

            IF vcampo121 IS NOT NULL THEN
               BEGIN
                  IF vcampo123 = 'AG' THEN
                     SELECT cvalemp
                       INTO vcampo122
                       FROM int_codigos_emp ie
                      WHERE ie.cempres = TO_CHAR(pcempres)
                        AND ccodigo = 'COMPR_CONTA'
                        AND cvalaxis = vcampo121 || 'G';
                  ELSE
                     SELECT cvalemp
                       INTO vcampo122
                       FROM int_codigos_emp ie
                      WHERE ie.cempres = TO_CHAR(pcempres)
                        AND ccodigo = 'COMPR_CONTA'
                        AND cvalaxis = vcampo121;
                  END IF;
               EXCEPTION
                  WHEN OTHERS THEN
                     vcampo122 := NULL;
               END;
            END IF;

            vcamps := vcamps || ';' || vcampo121 || ';' || vcampo122 || ';' || vcampo123;
         END IF;

         UTL_FILE.put_line(v_fitxer, vcamps);
      END LOOP;

      CLOSE cur;

      UTL_FILE.fclose(v_fitxer);
      v_path := f_parinstalacion_t('INFORMES_C');
      pnomfichero := v_path || '\' || v_tfitxer;
   EXCEPTION
      WHEN OTHERS THEN
         -- BUG -21546_108724- 09/02/2012 - JLTS - Cierre de posibles cursores abiertos
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         p_tab_error(f_sysdate, f_user, 'pac_contabiliza.p_montar_fichero', 1,
                     'Error incontrolado', SQLERRM);
   END p_montar_fichero;

   /*************************************************************************
      Función que elimina un apunte manual
      param in  pcempres : código empresa
      param in  pfcontabini : fecha de contabilidad inicial
      param in  pfcontabfin : fecha de contabilidad final
      param in  pftraspasini : fecha de traspaso inicial
      param in  pftraspasfin : fecha de traspaso inicial
      param in  pchecktraspas : traspasados o no
      return error
   *************************************************************************/
   FUNCTION f_del_apuntemanual(
      pcpais IN NUMBER,
      pfefeadm IN DATE,
      pcproces IN NUMBER,
      pccuenta IN VARCHAR2,
      pnlinea IN NUMBER,
      pnasient IN NUMBER,
      pcempres IN NUMBER,
      pfconta IN DATE,
      ptdescri IN VARCHAR2,
      psinterf IN NUMBER,
      pttippag IN NUMBER,
      pidpago IN NUMBER,
      pccoletilla IN VARCHAR2,
      potros IN VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      IF NVL(pac_parametros.f_parempresa_n(pcempres, 'CONTAB_ONLINE'), 0) = 1 THEN
         DELETE FROM contab_manu_interf
               WHERE sinterf = psinterf
                 AND ttippag = pttippag
                 AND idpago = pidpago
                 AND fconta = pfconta
                 AND nasient = pnasient
                 AND nlinea = pnlinea
                 AND ccuenta = pccuenta
                 AND ccoletilla = pccoletilla
                 AND tdescri = ptdescri
                 AND fefeadm = pfefeadm
                 AND otros = potros;
      ELSE
         DELETE FROM contab_manu_dia
               WHERE cpais = pcpais
                 AND fefeadm = pfefeadm
                 AND cproces = pcproces
                 AND ccuenta = pccuenta
                 AND nlinea = pnlinea
                 AND nasient = pnasient
                 AND cempres = pcempres
                 AND fconta = pfconta
                 AND tdescri = ptdescri;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_contabiliza.f_del_apuntemanual', 1,
                     'Error incontrolado', SQLERRM);
         RETURN 1;
   END f_del_apuntemanual;

   /*************************************************************************
      Función que inserta un apunte manual
      param in  pcempres : código empresa
      param in  pfcontabini : fecha de contabilidad inicial
      param in  pfcontabfin : fecha de contabilidad final
      param in  pftraspasini : fecha de traspaso inicial
      param in  pftraspasfin : fecha de traspaso inicial
      param in  pchecktraspas : traspasados o no
      return error
   *************************************************************************/
   FUNCTION f_set_apuntemanual(
      psinterf IN NUMBER,
      pttippag IN NUMBER,
      pidpago IN NUMBER,
      pfconta IN DATE,
      pnasient IN NUMBER,
      pnlinea IN NUMBER,
      pccuenta IN VARCHAR2,
      pccoletilla IN VARCHAR2,
      ptapunte IN VARCHAR2,
      piapunte IN NUMBER,
      ptdescri IN VARCHAR2,
      pfefeadm IN DATE,
      potros IN VARCHAR2,
      pcenlace IN VARCHAR2,
      pcempres IN NUMBER,
      pcproces IN NUMBER,
      pcpais IN NUMBER,
      pftraspaso IN DATE,
      pclaveasi IN VARCHAR2,
      ptipodiario IN VARCHAR2,
      pfasiento IN DATE)
      RETURN NUMBER IS
   BEGIN
      IF NVL(pac_parametros.f_parempresa_n(pcempres, 'CONTAB_ONLINE'), 0) = 1 THEN
         BEGIN
            INSERT INTO contab_manu_interf
                        (sinterf, ttippag, idpago, fconta, nasient, nlinea, ccuenta,
                         ccoletilla, tapunte, iapunte, tdescri, fefeadm, otros, cenlace)
                 VALUES (psinterf, pttippag, pidpago, pfconta, pnasient, pnlinea, pccuenta,
                         pccoletilla, ptapunte, piapunte, ptdescri, pfefeadm, potros, pcenlace);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               UPDATE contab_manu_interf
                  SET tapunte = ptapunte,
                      iapunte = piapunte,
                      cenlace = pcenlace
                WHERE sinterf = psinterf
                  AND ttippag = pttippag
                  AND idpago = pidpago
                  AND fconta = pfconta
                  AND nasient = pnasient
                  AND nlinea = pnlinea
                  AND ccuenta = pccuenta
                  AND ccoletilla = pccoletilla
                  AND tdescri = ptdescri
                  AND fefeadm = pfefeadm
                  AND otros = potros;
         END;
      ELSE
         BEGIN
            INSERT INTO contab_manu_dia
                        (cempres, fconta, nasient, nlinea, ccuenta, cproces, fefeadm,
                         cpais, tapunte, iapunte, tdescri, ftraspaso, cenlace,
                         claveasi, tipodiario, fasiento)
                 VALUES (pcempres, pfconta, pnasient, pnlinea, pccuenta, pcproces, pfefeadm,
                         pcpais, ptapunte, piapunte, ptdescri, pftraspaso, pcenlace,
                         pclaveasi, ptipodiario, pfasiento);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               UPDATE contab_manu_dia
                  SET tapunte = ptapunte,
                      iapunte = piapunte,
                      cenlace = pcenlace
                WHERE cpais = pcpais
                  AND fefeadm = pfefeadm
                  AND cproces = pcproces
                  AND ccuenta = pccuenta
                  AND nlinea = pnlinea
                  AND nasient = pnasient
                  AND fconta = pfconta
                  AND tdescri = ptdescri;
         END;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_contabiliza.f_set_apuntemanual', 1,
                     'Error incontrolado', SQLERRM);
         RETURN 1;
   END f_set_apuntemanual;
END pac_contabilidad;

/

  GRANT EXECUTE ON "AXIS"."PAC_CONTABILIDAD" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CONTABILIDAD" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CONTABILIDAD" TO "PROGRAMADORESCSI";
