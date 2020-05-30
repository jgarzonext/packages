--------------------------------------------------------
--  DDL for Package Body PAC_CARGAS_EXT_SEPA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_CARGAS_EXT_SEPA" IS
   /******************************************************************************
      NOMBRE:      pac_cargas_ext_sepa
      PROPÓSITO: Funciones para la gestión de la carga de procesos
      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        03/11/2011   MLR              1. Creación del package.

   ******************************************************************************/

   /*************************************************************************
       Procedimiento que guarda logs en las diferentes tablas.
       param p_tabobj in : tab_error tobjeto
       param p_tabtra in : tab_error ntraza
       param p_tabdes in : tab_error tdescrip
       param p_taberr in : tab_error terror
       param p_propro in : PROCESOSLIN sproces
       param p_protxt in : PROCESOSLIN tprolin
       devuelve número o null si existe error.
   *************************************************************************/
   gverr_prc      NUMBER := 0;   --VF:800019: 1-ERROR,2-AVIS,3-PENDENT,4-CORRECTE,5-NO PROCESSAT
   gverrtext_prc  VARCHAR2(2000) := NULL;
   gvprocesoenv   NUMBER := 0;
   gvcobban       NUMBER := 0;
   gvcempres      empresas.cempres%TYPE := pac_md_common.f_get_cxtempresa;
   gvcestado      VARCHAR2(20);
   gvcobra_recdom NUMBER;
   d_remesa       DATE;   -- BUG 0038205 - 21/10/2015 - JMF

   FUNCTION f_get_proceso_origen(p_proceso IN NUMBER, pnrecibo IN NUMBER)
      RETURN NUMBER IS
      ndummy         NUMBER;
      gvfondoc       NUMBER := 0;
      vtraza         NUMBER;
   BEGIN
      vtraza := 10;

      SELECT sproces, ccobban
        INTO gvprocesoenv, gvcobban
        FROM domiciliaciones
       WHERE nrecibo = pnrecibo
         AND sproces IN(SELECT MAX(sproces)
                          FROM domiciliaciones
                         WHERE nrecibo = pnrecibo);

      vtraza := 10;
      RETURN(0);
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         p_tab_error(f_sysdate, f_user, 'pac_cargas_ext_sepa.f_get_proceso_origen', vtraza,
                     'No se encuentra el número iAXIS del proceso origen para el recibo '
                     || pnrecibo,
                     SQLERRM);
         ndummy := f_proceslin(p_proceso,
                               SUBSTR(f_axis_literales(9001650, k_idiomaaxis) || ':'
                                      || 9001650,
                                      1, 120),
                               1, ndummy);
         RETURN 9001650;   --Error recuperando la información del proceso de devolución
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_cargas_ext_sepa.f_get_proceso_origen', vtraza,
                     'Error cargando el fichero ', SQLERRM);
         ndummy := f_proceslin(p_proceso,
                               SUBSTR(f_axis_literales(9001896, k_idiomaaxis) || SQLCODE, 1,
                                      120),
                               1, ndummy);
         RETURN 9001896;   --error cargando el fichero
   END;

   PROCEDURE p_genera_logs(
      p_tabobj IN VARCHAR2,
      p_tabtra IN NUMBER,
      p_tabdes IN VARCHAR2,
      p_taberr IN VARCHAR2,
      p_propro IN NUMBER,
      p_protxt IN VARCHAR2) IS
      vnnumlin       NUMBER;
      vnum_err       NUMBER;
   BEGIN
      IF p_tabobj IS NOT NULL
         AND p_tabtra IS NOT NULL THEN
         p_tab_error(f_sysdate, f_user, p_tabobj, p_tabtra, SUBSTR(p_tabdes, 1, 500),
                     SUBSTR(p_taberr, 1, 2500));
      END IF;

      IF p_propro IS NOT NULL
         AND p_protxt IS NOT NULL THEN
         vnnumlin := NULL;
         vnum_err := f_proceslin(p_propro, SUBSTR(p_protxt, 1, 120), 0, vnnumlin);   --error general (no es de línea)
      END IF;
   END p_genera_logs;

   /*************************************************************************
       Función que da correspondencia valor de la empresa en la interface con axis.
            param in p_cod : código a buscar
            param in p_emp : código valor de la empresa
            return : código valor de axis
   *************************************************************************/
   FUNCTION f_buscavalor(p_cod IN VARCHAR2, p_emp IN VARCHAR2)
      RETURN VARCHAR2 IS
      v_ret          int_codigos_emp.cvalaxis%TYPE;
   BEGIN
      SELECT NVL(MAX(cvalaxis), 5)
        INTO v_ret
        FROM int_codigos_emp
       WHERE cempres = k_empresaaxis
         AND ccodigo = p_cod
         AND cvalemp = p_emp;

      RETURN v_ret;
   END f_buscavalor;

   /*************************************************************************
             Función que marca linea que tratamos con un estado.
          param p_pro in : proceso
          param p_lin in : linea
          param p_tip in : tipo
          param p_est in : estado
          param p_val in : validado
          param p_seg in : seguro
          devuelve número o null si existe error.
   *************************************************************************/
   FUNCTION f_marcalinea(
      p_pro IN NUMBER,
      p_lin IN NUMBER,
      p_tip IN NUMBER,
      p_est IN NUMBER,
      p_val IN NUMBER,
      p_seg IN NUMBER,
      p_id_ext IN VARCHAR2,
      p_ncarg IN NUMBER,
      p_sin IN NUMBER DEFAULT NULL,
      p_tra IN NUMBER DEFAULT NULL,
      p_per IN NUMBER DEFAULT NULL,
      p_rec IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'pac_cargas_ext_sepa.f_marcalinea';
      num_err        NUMBER;
      vtipo          NUMBER;
      num_lin        NUMBER;
      num_aux        NUMBER;
   BEGIN
      num_err := pac_gestion_procesos.f_set_carga_ctrl_linea(p_pro, p_lin, p_tip,
                                                             NVL(p_rec, p_lin), p_tip, p_est,
                                                             p_val, p_seg, p_id_ext, p_ncarg,
                                                             p_sin, p_tra, p_per, p_rec);

      IF num_err <> 0 THEN   --Si fallan estas funciones de gestión salimos del programa
         p_genera_logs(vobj, 1, num_err,
                       'p=' || p_pro || ' l=' || p_lin || ' t=' || p_tip || ' EST=' || p_est
                       || ' v=' || p_val || ' s=' || p_seg,
                       p_pro, 'Error ' || num_err || ' l=' || p_lin || ' e=' || p_est);
         num_err := 1;
      END IF;

      RETURN num_err;
   END f_marcalinea;

   /*************************************************************************
        Función que marca el error de la linea que tratamos.
          param p_pro in : proceso
          param p_lin in : linea
          param p_ner in : numero error
          param p_tip in : tipo
          param p_cod in : codigo
          param p_men in : mensaje
          devuelve número o null si existe error.
   *************************************************************************/
   FUNCTION f_marcalineaerror(
      p_pro IN NUMBER,
      p_lin IN NUMBER,
      p_ner IN NUMBER,
      p_tip IN NUMBER,
      p_cod IN NUMBER,
      p_men IN VARCHAR2)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'pac_cargas_ext_sepa.f_marcalineaERROR';
      num_err        NUMBER;
   BEGIN
      num_err := pac_gestion_procesos.f_set_carga_ctrl_linea_error(p_pro, p_lin, p_ner, p_tip,
                                                                   p_cod, p_men);

      IF num_err <> 0 THEN   --Si fallan estas funciones de gestión salimos del programa
         p_genera_logs(vobj, 1, num_err,
                       'p=' || p_pro || ' l=' || p_lin || ' n=' || p_ner || ' t=' || p_tip
                       || ' c=' || p_cod || ' m=' || p_men,
                       p_pro, 'Error ' || num_err || ' l=' || p_lin || ' c=' || p_cod);
         num_err := 1;
      END IF;

      RETURN num_err;
   END f_marcalineaerror;

   PROCEDURE p_log_lin(p_proceso IN NUMBER, p_bprenotificacion IN BOOLEAN DEFAULT FALSE) IS
      CURSOR c_lineas_errores IS
         --Buscamos errores generales de procesos iAXIS
         SELECT   l.*, e.tmensaje, e.nerror, p.tprolin
             FROM int_carga_ctrl_linea l, int_carga_ctrl_linea_errs e, procesoslin p
            WHERE l.sproces = p_proceso
              AND l.nlinea > 0
              AND e.sproces(+) = l.sproces
              AND e.nlinea(+) = l.nlinea
              AND p.sproces(+) = l.sproces
              AND p.npronum(+) = l.sseguro
         ORDER BY 1;

      vdummy         NUMBER;
   BEGIN
      FOR reg IN c_lineas_errores LOOP
         -- 6. 0021663: Incidencias con la carga de domiciliaciones y la interfaz de recaudo - 0109768 - Inicio
         IF NOT p_bprenotificacion THEN
            reg.idext := ff_desvalorfijo(383, k_idiomaaxis,
                                         f_cestrec_mv(reg.nrecibo, k_idiomaaxis, NULL));
         END IF;

         -- 6. 0021663: Incidencias con la carga de domiciliaciones y la interfaz de recaudo - 0109768 - Fin
         IF reg.tmensaje IS NOT NULL
            OR reg.tprolin IS NOT NULL THEN
            -- JAJG -- BUG 40490: PANTALLA EN IAXIS PARA LA GESTIÓN DE FICHEROS SEPA POR DEVOLUCIÓN DE RECIBOS IMPAGADOS
          -- Se modifica el cuarto parámetro, p_tip al llamar a la función f_marcalineaerror por coheréncia con el tipo de mensaje
          -- en la linea de detalle f_marcalinea. De 1 (error) se cambia a 2 (aviso).
          --  vdummy := f_marcalineaerror(p_proceso, reg.nlinea, reg.nerror, 1   /*error*/
          --                                                                  ,
          --                              reg.nrecibo, reg.tmensaje || CHR(10) || reg.tprolin);

            vdummy := f_marcalineaerror(p_proceso, reg.nlinea, reg.nerror, 2   /*error*/
                                                                            ,
                                        reg.nrecibo, reg.tmensaje || CHR(10) || reg.tprolin);
            vdummy := f_marcalinea(reg.sproces, reg.nlinea, reg.ctipo, 2   /*aviso*/
                                                                        , 0, reg.sseguro,
                                   reg.idext, NULL   /*proceso_carga*/
                                                  , NULL, NULL, NULL, reg.nrecibo);
         ELSE
            IF p_bprenotificacion THEN
               --Si hay algún error al cambiar el estado debería grabar en PROCESOSLIN
               --y así se visualizaría el mismo en la pantalla de cargas
               BEGIN
                  SELECT cestimp
                    INTO vdummy
                    FROM recibos
                   WHERE nrecibo = reg.nrecibo;

                  reg.idext := ff_desvalorfijo(75, k_idiomaaxis, vdummy);
               EXCEPTION
                  WHEN OTHERS THEN
                     reg.idext := NULL;
                     p_tab_error(f_sysdate, f_user, 'pac_cargas_ext_sepa.p_log_lin', 1,
                                 'Error sqlcode: ' || SQLCODE, SQLERRM);
               END;

               vdummy := f_marcalinea(reg.sproces, reg.nlinea, reg.ctipo, reg.cestado,
                                      reg.cvalidado, reg.sseguro, reg.idext,
                                      NULL   /*proceso_carga*/
                                          , NULL, NULL, NULL, reg.nrecibo);
            -- 6. 0021663: Incidencias con la carga de domiciliaciones y la interfaz de recaudo - 0109768 - Inicio
            ELSE
               vdummy := f_marcalinea(reg.sproces, reg.nlinea, reg.ctipo, reg.cestado,
                                      reg.cvalidado, reg.sseguro, reg.idext,
                                      NULL   /*proceso_carga*/
                                          , NULL, NULL, NULL, reg.nrecibo);
            -- 6. 0021663: Incidencias con la carga de domiciliaciones y la interfaz de recaudo - 0109768 - Fin
            END IF;
         END IF;
      END LOOP;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_cargas_ext_sepa.p_log_lin', 1,
                     'Error sqlcode: ' || SQLCODE, SQLERRM);
   END;

   FUNCTION f_test_errores_cab(p_proceso IN NUMBER, nerr OUT NUMBER)
      RETURN BOOLEAN IS
      CURSOR c_proc_errores IS
         --Buscamos errores generales de procesos iAXIS
         SELECT tprolin
           FROM procesoslin
          WHERE sproces = p_proceso
            AND npronum = 0;   --son errores generales que no pertenecen a una línea en concreto
   BEGIN
      nerr := 0;
      gverrtext_prc := NULL;

      --Buscamos errores de carga de líneas
      SELECT COUNT(1)
        INTO nerr
        FROM int_carga_ctrl_linea_errs
       WHERE sproces = p_proceso;

      --Buscamos errores de procesos iAXIS
      FOR reg IN c_proc_errores LOOP
         gverrtext_prc := SUBSTR(gverrtext_prc || reg.tprolin || '|', 1, 2000);
      END LOOP;

      IF gverrtext_prc IS NOT NULL THEN
         gverrtext_prc := SUBSTR(gverrtext_prc, 1, LENGTH(gverrtext_prc) - 1);
      END IF;

      IF nerr > 0
         OR gverrtext_prc IS NOT NULL THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_cargas_ext_sepa.f_test_errores_cab', 1,
                     'Error sqlcode: ' || SQLCODE,
                     SQLERRM || '-gverrtext_prc:' || gverrtext_prc);
         RETURN TRUE;
   END;

   FUNCTION f_log_cab(
      p_proceso IN NUMBER,
      p_nerrores OUT NUMBER,
      p_fichero IN VARCHAR2,
      p_cproces IN NUMBER,
      p_bprenotificacion IN BOOLEAN DEFAULT FALSE)
      RETURN NUMBER IS
      ncab_err       NUMBER;
   BEGIN
      IF f_test_errores_cab(p_proceso, p_nerrores) THEN
         IF p_nerrores > 0 THEN
            gverr_prc := 1;   --ERROR: ERRORES DE CARGA
         ELSE
            gverr_prc := 2;   --AVIS: ERRORES DE PROCESO
         END IF;

         IF gverr_prc = 1 THEN
            ncab_err := 151541;
            -- Error cargando el fichero
            gverrtext_prc := SUBSTR(f_axis_literales(9001896) || gverrtext_prc, 1, 2000);
         ELSE
            ncab_err := 0;
            -- Aviso
            gverrtext_prc := SUBSTR(f_axis_literales(9000642) || gverrtext_prc, 1, 2000);
         END IF;
      -- 7. 0021718: MDP_A001-Domiciliaciones: modificaciones generales - 0111176 - Fin
      ELSE
         gverr_prc := 4;   --OK
         gverrtext_prc := NULL;
         ncab_err := 0;
      END IF;

      IF SUBSTR(gverrtext_prc, -1) = ':' THEN
         gverrtext_prc := SUBSTR(gverrtext_prc, 1, LENGTH(gverrtext_prc) - 1);
      END IF;

      --Actualizamos la cabecera del proceso indicando si ha habido o no algún error en todo el proceso de carga
      ncab_err :=
         pac_gestion_procesos.f_set_carga_ctrl_cabecera
            (p_proceso, p_fichero, NULL, f_sysdate, gverr_prc, p_cproces, ncab_err,   --vnum_err: AFM no puedo ponerlo porque peta la pantalla (number precision too large)
             gverrtext_prc);

      IF ncab_err <> 0 THEN
         p_genera_logs('f_actualizar_cab', 111, ncab_err,
                       'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera',
                       p_proceso,
                       f_axis_literales(180856) || ':' || p_fichero || ' : ' || ncab_err);
      END IF;

      p_log_lin(p_proceso, p_bprenotificacion);
      RETURN ncab_err;   --O, OK
   END;

   FUNCTION f_test_recibo_logs(
      p_proceso IN NUMBER,
      p_nlinea IN NUMBER,
      p_vnrecibo IN VARCHAR2,
      p_nseguro OUT NUMBER,
      p_bdomiciliacion IN BOOLEAN DEFAULT TRUE,
      p_idnotif2 IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER IS
      nretorno       NUMBER := -1;
      ndummy         NUMBER;
      vffiledev      DATE;
      vtfiledev      domiciliaciones.tfiledev%TYPE;
      v_nrecibo      domiciliaciones.nrecibo%TYPE;
   BEGIN
      SELECT 0, sseguro, tfiledev
        INTO nretorno, p_nseguro, vtfiledev
        FROM domiciliaciones
       WHERE nrecibo = TO_NUMBER(p_vnrecibo)
         AND sproces = gvprocesoenv;

      IF vtfiledev IS NOT NULL THEN
         nretorno := 9831;
         ndummy := f_marcalineaerror(p_proceso, p_nlinea, nretorno, 1, p_vnrecibo,
                                     'Proceso ' || gvprocesoenv
                                     || ' ya cerrado, no se procesara este recibo '
                                     || p_vnrecibo);
      END IF;

      RETURN nretorno;
   EXCEPTION
      WHEN OTHERS THEN
         nretorno := SQLCODE;

         IF p_idnotif2 IS NOT NULL THEN
            ndummy := f_marcalineaerror(p_proceso, p_nlinea, nretorno, 1   /*error*/
                                                                        ,
                                        v_nrecibo,
                                        'No se ha encontrado la matrícula:' || p_idnotif2
                                        || ' para el proceso origen:' || p_proceso);
         ELSE
            ndummy := f_marcalineaerror(p_proceso, p_nlinea, nretorno, 1   /*error*/
                                                                        ,
                                        p_vnrecibo,
                                        'No se ha encontrado el recibo:' || p_vnrecibo
                                        || ' para el proceso origen:' || p_proceso);
         END IF;   -- 10. 0026726 - 0142708 - Final

         RETURN nretorno;
   END;

   /*************************************************************************
        procedimiento que traspasa de una tabla INT_XXX_EXT a INT_XXX
        param in   out pdeserror   : mensaje de error
        param in psproces   : Número proceso
   *************************************************************************/
   PROCEDURE p_trasp_tabla(
      pdeserror OUT VARCHAR2,
      psproces IN NUMBER,
      p_tabla IN VARCHAR2,
      pid_rechazo IN NUMBER) IS
      num_err        NUMBER;
      v_pasexec      NUMBER := 1;
      vparam         VARCHAR2(1) := NULL;
      vobj           VARCHAR2(200) := 'pac_cargas_ext_sepa.P_TRASP_TABLA';
      v_dummy        NUMBER;
      v_numerr       NUMBER := 0;
      errgrabarprov  EXCEPTION;
      e_object_error EXCEPTION;
      v_linea        NUMBER := 0;
      v_stmt         VARCHAR2(2000);
      vbicbankrec    int_sepa_respcobros.BICBANKREC%Type;
      vMsgorigen     int_sepa_respcobros.MSGORIGEN%Type;
   BEGIN
      v_pasexec := 10;
      pdeserror := NULL;
      v_pasexec := 20;

   BEGIN
      INSERT INTO int_sepa_respcobros  (
        SINTERF,
        NLINEA ,
        BICBANKREC,
        BICBANKDEB,
        CBANCAR   ,
        ITOTALR   ,
        NNUMIDE   ,
        IDMANDAT,
        CESTDEV   ,
        NFACTURA,
        FDEBITO   ,
        MSGORIGEN
        )
      SELECT psproces, rownum,bicbankrec,  bicbankdeb,cbancar, TO_NUMBER(itotalr,'9999999999999999.99') itotalr,
             nnumide, idmandat, cestdev , nfactura, fdebito , Msgorigen
        FROM xml_rechazos,
        XMLTABLE(
          XMLNamespaces(default 'urn:iso:std:iso:20022:tech:xsd:pain.002.001.03' ),
         '//CstmrPmtStsRpt'
         PASSING xml_rechazos.xmldoc
         COLUMNS bicbankrec    VARCHAR2(200 BYTE) PATh '/CstmrPmtStsRpt/GrpHdr/CdtrAgt/FinInstnId/BIC'
        )a,
        XMLTABLE(
          XMLNamespaces(default 'urn:iso:std:iso:20022:tech:xsd:pain.002.001.03'),
         '//OrgnlPmtInfAndSts'
         PASSING xml_rechazos.xmldoc
         COLUMNS  bicbankdeb    VARCHAR2(200 BYTE) PATh '/OrgnlPmtInfAndSts/TxInfAndSts/StsRsnInf/Orgtr/Id/OrgId/BICOrBEI',
          cbancar       VARCHAR2(200 BYTE) PATh '/OrgnlPmtInfAndSts/TxInfAndSts/OrgnlTxRef/CdtrAcct/Id/IBAN',
          itotalr       VARCHAR2(200 BYTE) PATh '/OrgnlPmtInfAndSts/TxInfAndSts/OrgnlTxRef/Amt/InstdAmt',
          nnumide       VARCHAR2(200 BYTE) PATh '/OrgnlPmtInfAndSts/TxInfAndSts/OrgnlTxRef/BIC',
          idmandat      VARCHAR2(200 BYTE) PATh '/OrgnlPmtInfAndSts/TxInfAndSts/OrgnlTxRef/MndtRltdInf/MndtId',
          cestdev       VARCHAR2(200 BYTE) PATh '/OrgnlPmtInfAndSts/TxInfAndSts/StsRsnInf/Rsn/Cd',
          nfactura      VARCHAR2(200 BYTE) PATh '/OrgnlPmtInfAndSts/TxInfAndSts/OrgnlEndToEndId',
          fdebito       date PATh '/OrgnlPmtInfAndSts/TxInfAndSts/OrgnlTxRef/ReqdColltnDt'
        ) b,
        XMLTABLE(
       XMLNamespaces(default 'urn:iso:std:iso:20022:tech:xsd:pain.002.001.03'),
         '//OrgnlGrpInfAndSts'
         PASSING xml_rechazos.xmldoc
         COLUMNS Msgorigen    VARCHAR2(200 BYTE) PATh '/OrgnlGrpInfAndSts/OrgnlMsgId'
        )c
       WHERE id_rechazo = pid_rechazo;
    EXCEPTION
        WHEN OTHERS THEN
      IF SQLCODE = -19279 THEN
        /*ORA-19279: XPTY0004: El tipo dinámico de XQuery no coincide: Se esperaba secuencia Singleton, se ha obtenido una secuencia de varios elementos
            El error es porque el tag OrgnlPmtInfAndSts tiene más de un nodo hijo TxInfAndSts y es ok segun especificación pain.002.001.03
        */
        SELECT bicbankrec
        into vbicbankrec
        FROM xml_rechazos,
        XMLTABLE(
          XMLNamespaces(default 'urn:iso:std:iso:20022:tech:xsd:pain.002.001.03' ),
         '//CstmrPmtStsRpt'
         PASSING xml_rechazos.xmldoc
         COLUMNS bicbankrec    VARCHAR2(200 BYTE) PATh '/CstmrPmtStsRpt/GrpHdr/CdtrAgt/FinInstnId/BIC'
        )a
        WHERE id_rechazo = pid_rechazo;

        SELECT Msgorigen
        into vMsgorigen
        FROM xml_rechazos,
        XMLTABLE(
       XMLNamespaces(default 'urn:iso:std:iso:20022:tech:xsd:pain.002.001.03'),
         '//OrgnlGrpInfAndSts'
         PASSING xml_rechazos.xmldoc
         COLUMNS Msgorigen    VARCHAR2(200 BYTE) PATh '/OrgnlGrpInfAndSts/OrgnlMsgId'
        )a
        WHERE id_rechazo = pid_rechazo;

        INSERT INTO int_sepa_respcobros  (
        SINTERF,
        NLINEA ,
        BICBANKREC,
        BICBANKDEB,
        CBANCAR   ,
        ITOTALR   ,
        NNUMIDE   ,
        IDMANDAT,
        CESTDEV   ,
        NFACTURA,
        FDEBITO   ,
        MSGORIGEN
        )
      SELECT psproces, rownum,vbicbankrec,  bicbankdeb,cbancar, TO_NUMBER(itotalr,'9999999999999999.99') itotalr,
             nnumide, idmandat, cestdev , nfactura, fdebito , vMsgorigen
        FROM xml_rechazos,
        XMLTABLE(
          XMLNamespaces(default 'urn:iso:std:iso:20022:tech:xsd:pain.002.001.03'),
         '//TxInfAndSts'
         PASSING xml_rechazos.xmldoc
         COLUMNS  bicbankdeb    VARCHAR2(200 BYTE) PATh '/TxInfAndSts/StsRsnInf/Orgtr/Id/OrgId/BICOrBEI',
          cbancar       VARCHAR2(200 BYTE) PATh '/TxInfAndSts/OrgnlTxRef/CdtrAcct/Id/IBAN',
          itotalr       VARCHAR2(200 BYTE) PATh '/TxInfAndSts/OrgnlTxRef/Amt/InstdAmt',
          nnumide       VARCHAR2(200 BYTE) PATh '/TxInfAndSts/OrgnlTxRef/BIC',
          idmandat      VARCHAR2(200 BYTE) PATh '/TxInfAndSts/OrgnlTxRef/MndtRltdInf/MndtId',
          cestdev       VARCHAR2(200 BYTE) PATh '/TxInfAndSts/StsRsnInf/Rsn/Cd',
          nfactura      VARCHAR2(200 BYTE) PATh '/TxInfAndSts/OrgnlEndToEndId',
          fdebito       date PATh '/TxInfAndSts/OrgnlTxRef/ReqdColltnDt'
        ) b
       WHERE id_rechazo = pid_rechazo;



      ELSE
       v_pasexec := 29;
        p_tab_error(f_sysdate, f_user, vobj, v_pasexec, SQLCODE, SQLERRM);
        RAISE e_object_error;
      END IF;
      v_pasexec := 30;
      COMMIT;
      v_pasexec := 40;
    END;


      DECLARE
         TYPE tipo_curref IS REF CURSOR;

         curtbl         tipo_curref;
         nlinea         NUMBER;
      BEGIN
         OPEN curtbl FOR 'SELECT NLINEA FROM ' || p_tabla || ' WHERE SINTERF= ' || psproces
                         || ' ORDER BY NLINEA';

         LOOP
            v_pasexec := 50;

            FETCH curtbl
             INTO v_linea;

            EXIT WHEN curtbl%NOTFOUND;
            v_numerr := f_marcalinea(psproces, v_linea, 2, 3, 0, NULL, NULL, NULL);   --RECIBOS PENDIENTES

            IF v_numerr <> 0 THEN
               RAISE errgrabarprov;
            END IF;

            v_pasexec := 60;
         END LOOP;

         CLOSE curtbl;

         v_pasexec := 70;
      EXCEPTION
         WHEN errgrabarprov THEN
            ROLLBACK;
            p_tab_error(f_sysdate, f_user, vobj, v_pasexec, 108953, vobj);
            pdeserror := f_axis_literales(108953, k_idiomaaxis) || ':' || v_linea || ':'
                         || vobj;
            RAISE e_object_error;
         WHEN OTHERS THEN
            ROLLBACK;
            p_tab_error(f_sysdate, f_user, vobj, v_pasexec, SQLCODE, SQLERRM);
            pdeserror := f_axis_literales(105133, k_idiomaaxis) || ':' || v_linea || ':'
                         || f_axis_literales(1000136, k_idiomaaxis) || ':'
                         || TO_NUMBER(v_pasexec + 1) || ' ' || SQLERRM;
            RAISE e_object_error;
      END;

      v_pasexec := 90;
      COMMIT;
   EXCEPTION
      WHEN e_object_error THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, vobj, v_pasexec, SQLCODE, SQLERRM);

         IF pdeserror IS NULL THEN
            pdeserror := f_axis_literales(108953, k_idiomaaxis);
         END IF;

         RAISE;
      --NULL;
      WHEN OTHERS THEN
         ROLLBACK;
         pdeserror := f_axis_literales(103187, k_idiomaaxis) || SQLERRM;
         p_tab_error(f_sysdate, f_user, vobj, v_pasexec, SQLCODE, SQLERRM);
         RAISE;
   END p_trasp_tabla;

   FUNCTION f_domiciliacion_post(p_proceso IN NUMBER, p_seqdev IN NUMBER)
      RETURN NUMBER IS
      vtraza         NUMBER;
      vnum_err       NUMBER;
      vnumlin        NUMBER;
   --e_salir        EXCEPTION;
   BEGIN
      vtraza := 333;
      vnum_err := pac_devolu.tratar_devoluciones(pac_md_common.f_get_cxtidioma, p_seqdev,
                                                 p_proceso);

      IF vnum_err <> 0 THEN
         vnumlin := f_proceslin(p_proceso,
                                SUBSTR('Error pac_devolu.tratar_devoluciones: '
                                       || f_axis_literales(vnum_err),
                                       1, 120),
                                0, vnumlin);
      --RAISE e_salir;
      END IF;

      COMMIT;
      -- 4. 0021480: RSA898-Temar pendientes de DOMICILIACIONES - Inicio
      vtraza := 357;
      vnum_err := pac_devolu.f_devol_automatico(0, 99, pac_md_common.f_get_cxtidioma,
                                                p_proceso);

      IF NVL(vnum_err, 0) <> 0 THEN
         vnumlin := f_proceslin(p_proceso,
                                SUBSTR('Error pac_devolu.f_devol_automatico: '
                                       || f_axis_literales(vnum_err),
                                       1, 120),
                                0, vnumlin);
      END IF;

      COMMIT;
      -- 4. 0021480: RSA898-Temar pendientes de DOMICILIACIONES - Fin

      --IF vnum_err = 0 THEN
      --SOLO ENVIAMOS A JDE SI TODO HA IDO BIEN!!!
      vtraza := 444;

      --usamos el proceso original utilizado para crear las domiciliaciones
      IF vnum_err <> 0 THEN
         IF vnum_err = 9903246 THEN
            vnumlin := f_proceslin(p_proceso,
                                   SUBSTR('INFO: ' || f_axis_literales(vnum_err), 1, 120), 0,
                                   vnumlin);
            vnum_err := 0;   --NO ES ERROR
         ELSE
            vnumlin :=
               f_proceslin(p_proceso,
                           SUBSTR('Error pac_recaudos_RSA.f_creafichero_cobros_a_jde: '
                                  || f_axis_literales(vnum_err),
                                  1, 120),
                           0, vnumlin);
         END IF;
      --RAISE e_salir;
      END IF;

      --END IF;
      COMMIT;
      RETURN vnum_err;   --0--> OK
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_cargas_ext_sepa.f_domiciliacion_post', 111,
                     'Error: vtraza:' || vtraza || ' -vnum_err:' || vnum_err, SQLERRM);
         p_tab_error(f_sysdate, f_user, 'pac_cargas_ext_sepa.f_domiciliacion_post', 112,
                     'gvprocesoenv:' || gvprocesoenv || ' k_empresaaxis:' || k_empresaaxis
                     || 'gvcobban:' || gvcobban || ' idioma:' || pac_md_common.f_get_cxtidioma,
                     vnum_err);
         RETURN -555;
   END;

   /*************************************************************************
          procedimiento que ejecuta una carga.
          param in psproces   : Número proceso
          retorna 0 si ha ido bien, 1 en caso contrario
   FUNCIONALIDAD: AFM 7/11/11
   En función de la respuesta del cobro recibida modificaremos el estado del recibo envíado
   (originalmente como REMESADO -3-) a:
        1.Respuesta APROBADA --> poner el estado del recibo a COBRADO (1) vía f_mov_recibo()
        2.Respuesta DIFERENTE --> poner el estado del recibo a PENDIENTE (0) y grabar en TMP_IMPAGADOS para su seguimiento
         (más o menos parecido a PAC_DEVOLU.tratar_devoluciones() pasándole recibo x recibo en lugar del cursor que contiene)
   *************************************************************************/
   FUNCTION f_carga_sepa_respcobros(
      psproces IN NUMBER,
      p_cproces IN NUMBER,
      p_fichero IN VARCHAR2)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'pac_cargas_ext_sepa.f_carga_sepa_respcobros';

      CURSOR c_carga(psproces2 IN NUMBER) IS
         SELECT   a.*
             FROM int_sepa_respcobros a
            WHERE a.sinterf = psproces2
              AND NOT EXISTS(SELECT 1
                               FROM int_carga_ctrl_linea
                              WHERE int_carga_ctrl_linea.sproces = a.sinterf
                                AND int_carga_ctrl_linea.nlinea = a.nlinea
                                AND int_carga_ctrl_linea.cestado IN(2, 4, 5))
         --Solo las no procesadas
         ORDER BY a.nlinea;

      vtraza         NUMBER := 0;
      vdeserror      VARCHAR2(1000);
      vnnumlin       NUMBER;
      verrorfin      BOOLEAN := FALSE;
      vavisfin       BOOLEAN := FALSE;
      vcoderror      NUMBER;
      v_deserror     int_carga_ctrl_linea_errs.tmensaje%TYPE;
      vnum_err       NUMBER;
      v_dummy        NUMBER := 0;
      vtiperr        NUMBER := 0;
      verror         NUMBER;   --Codigo error
      vterror        VARCHAR2(4000);   --Descripción ampliada error
      v_hay          NUMBER := 0;
      v_idioma       NUMBER;
      v_errdat       VARCHAR2(4000);
      v_errtot       NUMBER := 0;
      v_wartot       NUMBER := 0;
      v_sproces      NUMBER;
      v_cont         NUMBER;
      v_fefecto      DATE;
      v_nclave       NUMBER;
      v_nvalor       NUMBER;
      v_period       NUMBER;
      v_row          int_sepa_respcobros%ROWTYPE;
      nok            NUMBER := 0;
      nko            NUMBER := 0;
      vseqdev        NUMBER;
      vestado        VARCHAR2(50);
      nseguro        NUMBER;
      vfdebito       DATE;   -- 6. 0021663 / 0109768
      e_errfin       EXCEPTION;
      vprimera       NUMBER := 0;   -- 7. 0021718: MDP_A001-Domiciliaciones: modificaciones generales - 0111176

------------------------------
---Insertem a devbanrecibos---
------------------------------
      FUNCTION insertar_devbanrecibos(
         p_seqdev IN NUMBER,
         p_fichero IN VARCHAR2,
         p_row IN int_sepa_respcobros%ROWTYPE)
         RETURN NUMBER IS
         num_error      NUMBER := 0;
         ilinea         NUMBER;
         vcempres       empresas.cempres%TYPE;
         vccobban       cobbancario.ccobban%TYPE;
         vctipban       recibos.ctipban%TYPE;
         vcdevmot       devbanrecibos.cdevmot%TYPE;
      BEGIN
         vtraza := 150;

         BEGIN
            vtraza := 160;

            SELECT MAX(d.cempres), MAX(ccobban)
              INTO vcempres, vccobban
              FROM domiciliaciones d
             WHERE d.sproces = gvprocesoenv;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               vtraza := 170;
               vcempres := k_empresaaxis;
               vccobban := 2;
         END;

         vtraza := 180;
         -- Convertir el código error SEPA devuelto por el banco
         -- al formato antiguo al que están relacionadas las acciones
         --vcdevmot := f_buscavalor('RECHAZO_SEPA', p_row.cestdev);

         BEGIN
            vtraza := 190;

            SELECT CDEVMOT
              INTO vcdevmot
              FROM codrechazo_banco
             WHERE cempres = vcempres
               AND ccobban = vccobban
               AND trim(crechazo) = trim(p_row.cestdev);
         EXCEPTION
            WHEN OTHERS THEN
               num_error := f_proceslin(p_row.sinterf,
                                        SUBSTR('Carga DEVBANRECIBOS - traza(' || vtraza
                                               || ') - crechazo(' || p_row.cestdev
                                               || ') - cempres(' || vcempres || ') - ccobban('
                                               || vccobban || ') ' || SQLERRM,
                                               1, 120),
                                        num_error, ilinea);
               num_error := 9905078;   -- Error al llegir la taula codrechazo_banco
               RETURN(num_error);
         END;

         vtraza := 200;

         -- 18. 0028206 - Inicio
         BEGIN
            SELECT ctipban
              INTO vctipban
              FROM recibos
             WHERE nrecibo = p_row.nfactura;
         EXCEPTION
            WHEN OTHERS THEN
               vctipban := NULL;
         END;

         vtraza := 220;

         -- ini BUG 0038205 - 21/10/2015 - JMF
         if NVL(pac_parametros.f_parempresa_n( vcempres , 'CARGA_FREMESA_HOY'),0)=1 then
            d_remesa := f_sysdate;
         else
            d_remesa := NVL(p_row.fdebito, f_sysdate);
         end if;
         -- fin BUG 0038205 - 21/10/2015 - JMF

         INSERT INTO devbanrecibos
                     (sdevolu, nnumnif, tsufijo,
                      fremesa, crefere,
                      nrecibo, trecnom,
                      nrecccc, irecdev, cdevrec,
                      crefint, cdevmot, cdevsit, tprilin, ccobban,
                      ctipban)
              VALUES (p_seqdev, NVL(LTRIM(p_row.nnumide, 0), 'x'), 0,
                      d_remesa, NVL(SUBSTR(p_fichero, 1, 50), 'x'),
                      TO_NUMBER(p_row.nfactura), NVL(p_row.nnumide, 'x'),
                      NVL(p_row.cbancar, 'x'), p_row.itotalr, p_row.cestdev,
                      NVL(SUBSTR(p_row.idmandat, 1, 10), 'x'), vcdevmot, 1, NULL, vccobban,
                      vctipban);

         vtraza := 230;

         -- ini BUG 0038205 - 21/10/2015 - JMF
         -- d_remesa
         -- fin BUG 0038205 - 21/10/2015 - JMF

         num_error :=
            pac_cargas_ext_sepa.f_insertar_devbanordenantes(p_seqdev, LTRIM(p_row.nnumide, 0),
                                                            0, d_remesa, vccobban,
                                                            p_row.bicbankrec, p_row.nlinea,
                                                            TO_NUMBER(p_row.itotalr), psproces,
                                                            p_fichero);
         vtraza := 240;
         RETURN num_error;
      EXCEPTION
         WHEN OTHERS THEN
            --quan no s'ha trobat el rebut inserto a procesoscab el rebut no trobat
            num_error := f_proceslin(p_row.sinterf,
                                     SUBSTR('Carga DEVBANRECIBOS: (' || p_row.nlinea || ') '
                                            || p_row.nfactura || ' ' || SQLERRM,
                                            1, 120),
                                     num_error, ilinea);
            num_error := 103944;
            --Error al insertar en la tabla DEVBANRECIBOS
            RETURN(num_error);
      END;
   BEGIN
      vtraza := 100;
      v_idioma := k_idiomaaxis;

      SELECT sdevolu.NEXTVAL
        INTO vseqdev
        FROM DUAL;

      /* SELECT NVL(MAX(sdevolu), 0) + 1
         INTO vseqdev
         FROM devbanpresentadores;*/
      FOR x IN c_carga(psproces) LOOP
         vtiperr := 0;
         verror := NULL;
         vterror := NULL;

         IF vprimera = 0 THEN
            verror := f_get_proceso_origen(psproces, x.nfactura);
         END IF;

         vtraza := 110;
         vnum_err := f_test_recibo_logs(psproces, x.nlinea, x.nfactura, nseguro, TRUE);

         IF vnum_err = 0 THEN
            IF vprimera = 0 THEN
               vprimera := 1;
               vtraza := 112;

               UPDATE domiciliaciones_cab d
                  SET d.tfiledev = p_fichero,
                      --> Estado domiciliación "Cerrado" -> 0
                      --> Si no está informado se cierra siempre
                      d.cestdom = NVL(pac_parametros.f_parempresa_n(cempres, 'CESTREM_DEVOL'),
                                      0),
                      d.sdevolu = psproces
                WHERE d.sproces = gvprocesoenv;
            END IF;

            BEGIN
               vtraza := 114;
               vfdebito := TO_DATE(x.fdebito, 'YYYYMMDD');
            EXCEPTION
               WHEN OTHERS THEN
                  vtraza := 116;
                  vfdebito := f_sysdate;
            END;

            --Actualizar domiciliaciones para actualizar estados de recibos posteriormente
            vtraza := 117;
         -- ini BUG 0038205 - 21/10/2015 - JMF
         if NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa, 'CARGA_FREMESA_HOY'),0)=1 then
            d_remesa := f_sysdate;
         else
            d_remesa := vfdebito;
         end if;
         -- fin BUG 0038205 - 21/10/2015 - JMF

         vtraza := 118;
            UPDATE domiciliaciones d
               SET d.cdomest = 1,
                   d.cdomerr = SUBSTR(x.cestdev, 1, 4),
                   d.idnotif2 = SUBSTR(x.idmandat, 1, 100),
                   d.fdebito = d_remesa
             WHERE sproces = gvprocesoenv
               AND nrecibo = x.nfactura;   --num.recibo

            vtraza := 120;
            /*
            --ESTADO del RECIBO DEVUELTO x el BCO (R-->REALIZADO, <>R -->PENDIENTE)
            IF x.cestdev = '00' THEN
               BEGIN
                  vfdebito := f_sysdate;
               EXCEPTION
                  WHEN OTHERS THEN
                     vfdebito := NULL;
               END;

               --Pasamos de REMESADO a COBRADO
               vtraza := 130;
               vnum_err := pac_domis.f_estado_domiciliacion(pac_md_common.f_get_cxtempresa,
                                                            SUBSTR(x.idmandat, 1, 6),
                                                            x.nfactura, 1, nok, nko, vfdebito);
            ELSE
               --Pasamos de REMESADO a PENDIENTE
               vtraza := 140;
               vnum_err := insertar_devbanrecibos(vseqdev, p_fichero, x);
            END IF;
            */
            vtraza := 140;
            vnum_err := insertar_devbanrecibos(vseqdev, p_fichero, x);
            vtraza := 150;
            vestado := f_cestrec(x.nfactura, NULL);
            vtraza := 160;
            vestado := ff_desvalorfijo(1, k_idiomaaxis, vestado);
            vtraza := 170;

            IF vnum_err = 0 THEN
               --Si todo correcto marco la linea correcta
               vtiperr := f_marcalinea(psproces, x.nlinea, 2, 4, 1, nseguro, vestado, NULL,
                                       NULL, NULL, NULL, x.nfactura);
            ELSE
               vtiperr := f_marcalineaerror(psproces, x.nlinea, vnum_err, 1, x.nfactura,
                                            'Error al cambiar el estado del recibo');
            END IF;
         END IF;
      END LOOP;

      vtraza := 180;
      vnum_err := f_domiciliacion_post(psproces, vseqdev);
      vtraza := 190;
      -- 7. 0021718: MDP_A001-Domiciliaciones: modificaciones generales - 0111176
      -- Modificación de f_log_cab para que diferencie los AVISOS de los ERRORES.
      -- vnum_err := f_log_cab(psproces, verror, p_fichero, p_cproces);
      vnum_err := f_log_cab(psproces, vnum_err, p_fichero, p_cproces);
      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_errfin THEN
         ROLLBACK;
         p_genera_logs(vobj, vtraza, 'Error:' || vnum_err, vdeserror, psproces,
                       'Error:' || vnum_err || ' ' || vdeserror);
         COMMIT;
         RETURN -1;
      WHEN OTHERS THEN
         ROLLBACK;
         --KO si ha habido algun error en la cabecera
         p_genera_logs(vobj, vtraza, 'Error:' || SQLCODE, SQLERRM, psproces,
                       f_axis_literales(103187, v_idioma) || ':' || p_fichero || ' : '
                       || SQLERRM);
         COMMIT;
         RETURN -2;
   END f_carga_sepa_respcobros;

   -- BUG 20278 - 02/12/2011 - JMP - RSA898 - Interface - Recaudos - Débito Automático - Carga resultado cobros VISA
   /*************************************************************************
      F_CARGA_VISA_RESPCOBROS
          procedimiento que ejecuta una carga.
          param in psproces   : Número proceso
          retorna 0 si ha ido bien, 1 en caso contrario

   En función de la respuesta del cobro recibida modificaremos el estado del recibo envíado
   (originalmente como REMESADO -3-) a:
        1.Respuesta APROBADA --> poner el estado del recibo a COBRADO (1) vía f_mov_recibo()
        2.Respuesta DIFERENTE --> poner el estado del recibo a PENDIENTE (0) y grabar en TMP_IMPAGADOS para su seguimiento
         (más o menos parecido a PAC_DEVOLU.tratar_devoluciones() pasándole recibo x recibo en lugar del cursor que contiene)
   *************************************************************************/

   /*************************************************************************
         procedimiento que ejecuta una carga (parte1 fichero)
         param in p_nombre   : Nombre fichero
         param out psproces   : Número proceso
         retorna 0 si ha ido bien, 1 en casos contrario
   *************************************************************************/
   FUNCTION f_ejecutar_carga_fichero(
      p_fichero IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces OUT NUMBER,
      p_tabla IN VARCHAR2,
      pid_rechazo IN NUMBER)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'pac_cargas_ext_sepa.F_EJECUTAR_CARGA_FICHERO';
      linea          NUMBER := 0;
      pcarga         NUMBER;
      sentencia      VARCHAR2(32000);
      vfichero       UTL_FILE.file_type;
      vtraza         NUMBER := 0;
      verror         NUMBER;
      vdeserror      VARCHAR2(1000);
      v_sproces      NUMBER;
      errorini       EXCEPTION;   --Indica error grabando estados.--Error que para ejecución
      vnum_err       NUMBER;
      vsalir         EXCEPTION;
      vnnumlin       NUMBER;
      vsinproc       BOOLEAN := TRUE;   --Indica si tenemos o no proceso
      verrorfin      BOOLEAN := FALSE;
      vavisfin       BOOLEAN := FALSE;
      vtiperr        NUMBER;
      vcoderror      NUMBER;
      n_imp          NUMBER;
      v_deserror     int_carga_ctrl_linea_errs.tmensaje%TYPE;
      e_errdatos     EXCEPTION;
   BEGIN
      vtraza := 1;
      vsinproc := TRUE;
      vnum_err := f_procesini(f_user, k_empresaaxis, 'CARGA_SEPA_FICH_EXT', p_fichero,
                              v_sproces);

      IF vnum_err <> 0 THEN
         RAISE errorini;   --Error que para ejecución
      END IF;

      vtraza := 2;
      psproces := v_sproces;

      IF p_cproces IS NULL THEN
         vnum_err := 9901092;
         vdeserror := 'cfg_files falta proceso: ' || vobj;
         RAISE e_errdatos;
      END IF;

      vtraza := 21;
      vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(v_sproces, p_fichero,
                                                                 f_sysdate, NULL, 3, p_cproces,
                                                                 NULL, NULL);
      vtraza := 3;

      IF vnum_err <> 0 THEN   --Si fallan esta funciones de gestión salimos del programa
         p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                     'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera');
         vnum_err := f_proceslin(v_sproces,
                                 f_axis_literales(180856, k_idiomaaxis) || ':' || p_fichero
                                 || ' : ' || vnum_err,
                                 1, vnnumlin);
         RAISE errorini;   --Error que para ejecución
      END IF;

      COMMIT;
      vtraza := 4;
      vtraza := 5;
      p_trasp_tabla(vdeserror, v_sproces, p_tabla, pid_rechazo);

      IF vdeserror IS NOT NULL THEN
         --Si hay un error leyendo el fichero salimos del programa del todo y lo indicamos.
         vtraza := 6;
         vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(v_sproces, p_fichero,
                                                                    f_sysdate, NULL, 1,
                                                                    p_cproces, NULL,
                                                                    vdeserror);
         vtraza := 7;

         IF vnum_err <> 0 THEN   --Si fallan esta funciones de gestión salimos del programa
            vtraza := 8;
            p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                        'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera2');
            vnnumlin := NULL;
            vnum_err := f_proceslin(v_sproces,
                                    SUBSTR(f_axis_literales(180856, k_idiomaaxis) || ':'
                                           || p_fichero || ' : ' || vnum_err,
                                           1, 120),
                                    1, vnnumlin);
            RAISE errorini;   --Error que para ejecución
         END IF;

         vtraza := 9;
         COMMIT;   --Guardamos la tabla temporal int
         RAISE vsalir;
      END IF;

      vtraza := 10;
      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN vsalir THEN
         NULL;
         RETURN 1;
      WHEN e_errdatos THEN
         ROLLBACK;
         p_genera_logs(vobj, vtraza, 'Error:' || vnum_err, vdeserror, psproces,
                       'Error:' || vnum_err || ' ' || vdeserror);
         COMMIT;
         RETURN 1;
      WHEN errorini THEN   --Error al insertar estados
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, vobj, vtraza, 'Error:' || 'ErrorIni' || ' en :' || 1,
                     'Error:' || 'Insertando estados registros');
         vnum_err := f_proceslin(v_sproces,
                                 SUBSTR(f_axis_literales(108953, k_idiomaaxis) || ':'
                                        || p_fichero || ' : ' || 'errorini',
                                        1, 120),
                                 1, vnnumlin);
         COMMIT;
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         --KO si ha habido algun error en la cabecera
         --coderr := SQLCODE;
         p_tab_error(f_sysdate, f_user, vobj, vtraza, 'Error:' || SQLERRM || ' en :' || 1,
                     'Error:' || SQLERRM);
         vnum_err := f_proceslin(v_sproces,
                                 SUBSTR(f_axis_literales(103187, k_idiomaaxis) || ':'
                                        || p_fichero || ' : ' || SQLERRM,
                                        1, 120),
                                 1, vnnumlin);
         vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(v_sproces, p_fichero,
                                                                    f_sysdate, NULL, 1,
                                                                    p_cproces, 151541,
                                                                    SQLERRM);
         vtraza := 51;

         IF vnum_err <> 0 THEN
            --RAISE ErrGrabarProv;
            p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                        'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera2');
            vnnumlin := NULL;
            vnum_err := f_proceslin(v_sproces,
                                    SUBSTR(f_axis_literales(180856, k_idiomaaxis) || ':'
                                           || p_fichero || ' : ' || vnum_err,
                                           1, 120),
                                    1, vnnumlin);
            RAISE errorini;
         END IF;

         COMMIT;
         RETURN 1;
   END f_ejecutar_carga_fichero;

   /*************************************************************************
          procedimiento que ejecuta una carga de tabla EXTERNA
          param in p_nombre   : Nombre fichero
          param in  out psproces   : Número proceso (informado para recargar proceso).
          retorna 0 si ha ido bien, 1 en casos contrario
   *************************************************************************/
   FUNCTION f_ejecutar_carga_ext(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      p_sproces IN OUT NUMBER)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'pac_cargas_ext_sepa.F_EJECUTAR_CARGA_EXT';
      vtraza         NUMBER := 0;
      vnum_err       NUMBER;
      vnum_err2      NUMBER;
      vfichero       VARCHAR2(100);
      vtabla         VARCHAR2(30);
      psproces       NUMBER;
      e_salir        EXCEPTION;
      bprocesando    BOOLEAN := FALSE;
      vtxterr        VARCHAR2(2000);   -- 15. 0027690 - QT-8414
      vid_rechazo    NUMBER;
   BEGIN
      vtraza := 1;
      vfichero := p_nombre;   --fichero para cargar seleccionado en pantalla
      gverr_prc := 4;   --CORRECTO
      gverrtext_prc := NULL;

      SELECT NVL(cpara_error, 0), UPPER(ttabla)
        INTO k_para_carga, vtabla
        FROM cfg_files
       WHERE cempres = k_empresaaxis
         AND cproceso = p_cproces;

      vtraza := 2;
      psproces := p_sproces;
      vnum_err := pac_sepa.f_leer_file_rechazo(vfichero, p_path, vid_rechazo); -- BUG 0036506 - FAL - 10/12/2015

      IF vnum_err <> 0 THEN
         RAISE e_salir;
      END IF;

      IF p_sproces IS NULL THEN
         vnum_err := f_ejecutar_carga_fichero(vfichero, p_path, p_cproces, psproces, vtabla,
                                              vid_rechazo);

         IF vnum_err <> 0 THEN
            RAISE e_salir;
         END IF;
      END IF;

      vtraza := 3;

      IF psproces IS NULL THEN
         vnum_err := 9000505;
         p_genera_logs(vobj, vtraza, 'Error:' || vnum_err, 'Parámetro psproces obligatorio',
                       psproces,
                       f_axis_literales(vnum_err) || ':' || vfichero || ' : ' || vnum_err);
         RAISE e_salir;
      END IF;

      vtraza := 4;

      IF vfichero IS NULL THEN
         vnum_err := 9901092;
         p_genera_logs(vobj, vtraza, 'Error:' || vnum_err, 'Falta fichero para proceso.',
                       psproces,
                       f_axis_literales(vnum_err) || ':' || vfichero || ' : ' || vnum_err);
         RAISE e_salir;
      END IF;

      --Tratamiento específico para cada tabla de carga (ya se ha volcado la EXT en la tabla que toca)
      vtraza := 40;

      -- vnum_err := f_get_proceso_origen(psproces, vfichero, FALSE);
      IF vnum_err = 0 THEN
         vtraza := 30;
         vnum_err := f_carga_sepa_respcobros(psproces, p_cproces, vfichero);
      END IF;

      IF vnum_err <> 0 THEN
         p_sproces := psproces;
         RAISE e_salir;
      END IF;

      IF p_sproces IS NULL THEN
         vtraza := 240;
         vnum_err2 := f_procesfin(psproces, vnum_err);
      END IF;

      vtraza := 250;
      p_sproces := psproces;

      IF vnum_err <> 0 THEN
         RAISE e_salir;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_salir THEN
         p_tab_error(f_sysdate, f_user, vobj, 1,
                     'ERROR SALIR: proceso:' || psproces || ' c_proceso:' || p_cproces
                     ||' p_path:'|| p_path || ' vfichero:' || vfichero || ' vtraza:' || vtraza || ' vnum_err:' -- AGM-4 03/06/2016 Mostrar el Patch
                     || vnum_err || ' vtabla:' || vtabla,
                     SQLERRM);
         --vtraza := 777;
         gverr_prc := 1;   --ERROR
         -- 15. 0027690 - QT-8414 - Inicio
         -- gverrtext_prc := NVL(f_axis_literales(vnum_err), f_axis_literales(9001896));
         gverrtext_prc := NVL(vtxterr,
                              NVL(f_axis_literales(vnum_err), f_axis_literales(9001896)));
         -- 15. 0027690 - QT-8414 - Final
         -- vnum_err :=  f_actualizar_cab (psproces, verror, p_fichero , p_cproces);

         --Actualizamos la cabecera del proceso indicando el error general
         vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces, vfichero, NULL,
                                                                    f_sysdate, gverr_prc,   --error
                                                                    p_cproces, vnum_err,
                                                                    gverrtext_prc);
         -- 5. 0021120: RSA897-RSA_A001-Resumen y detalle domis y prenotif ... - 0109142 - Inicio
         /*
         p_tab_error(f_sysdate, f_user, vobj, 1,
                     'ERROR SALIR:proceso:c_proceso:vfichero:vtraza:vnum_err' || psproces
                     || ':' || p_cproces || ':' || vfichero || ':' || vtraza || ':'
                     || vnum_err,
                     SQLERRM);
         p_tab_error(f_sysdate, f_user, vobj, 1,
                     'ERROR SALIR: proceso:' || psproces || ' c_proceso:' || p_cproces
                     || ' vfichero:' || vfichero || ' vtraza:' || vtraza || ' vnum_err:'
                     || vnum_err || ' vtabla:' || vtabla,
                     SQLERRM);
         */
         -- 5. 0021120: RSA897-RSA_A001-Resumen y detalle domis y prenotif ... - 0109142 - Fin
         --RETURN 11; --Si no devolvemos 0 al JAVA no aparecen los errores en pantalla!!
         RETURN 0;
      WHEN OTHERS THEN
         -- vtraza := SQLCODE; -- 5. 0021120 / 0109142
         gverr_prc := 1;   --ERROR
         gverrtext_prc := NVL(f_axis_literales(vnum_err), f_axis_literales(1000455));   --error no controlado
         -- vnum_err :=  f_actualizar_cab (psproces, verror, p_fichero , p_cproces);
         --Actualizamos la cabecera del proceso indicando el error general
         vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces, vfichero, NULL,
                                                                    f_sysdate, gverr_prc,   --error
                                                                    p_cproces, vnum_err,
                                                                    gverrtext_prc);
         -- 5. 0021120: RSA897-RSA_A001-Resumen y detalle domis y prenotif ... - 0109142 - Inicio
         /*
         p_tab_error(f_sysdate, f_user, vobj, 1,
                     'ERROR OTHERS:proceso:c_proceso:vfichero:vtraza:vnum_err' || psproces
                     || ':' || p_cproces || ':' || vfichero || ':' || vtraza || ':'
                     || vnum_err,
                     SQLERRM);
         */
         p_tab_error(f_sysdate, f_user, vobj, vtraza,
                     'ERROR OTHERS: proceso:' || psproces || ' c_proceso:' || p_cproces
                     ||' p_path:'|| p_path || ' vfichero:' || vfichero || ' vtraza:' || vtraza || ' vnum_err:' -- AGM-4 03/06/2016 Mostrar el Patch
                     || vnum_err || ' vtabla:' || vtabla,
                     SQLERRM);
         -- 5. 0021120: RSA897-RSA_A001-Resumen y detalle domis y prenotif ... - 0109142 - Fin

         --RETURN 22; --Si no devolvemos 0 al JAVA no aparecen los errores en pantalla!!
         RETURN 0;
   END f_ejecutar_carga_ext;

   /*************************************************************************
          Insertar en la tabla DEVBANORDENANTES
          param in p_seqdev   : Número proceso
          param in pnnumnif   : Número de identificación
          param in ptsufijo   : Sufijo
          param in pfremesa   : Fecha remesa
          param in pccobban   : Cobrador bancario
          param in ptordnom   : Nombre ordenante
          param in pnordreg   : Orden registro
          param in ptotalr    : Importe total del recibo ITOTALR
          param in psproces   : SPROCES
          param in pfichero   : Nombre del fichero
          retorna 0 si ha ido bien, 1 en caso contrario
   *************************************************************************/
   FUNCTION f_insertar_devbanordenantes(
      p_seqdev IN NUMBER,
      pnnumnif IN VARCHAR2,
      ptsufijo IN VARCHAR2,
      pfremesa IN DATE,
      pccobban IN NUMBER,
      ptordnom IN VARCHAR2,
      pnordreg IN NUMBER,
      ptotalr IN NUMBER,
      psproces IN NUMBER,
      pfichero IN VARCHAR2)
      RETURN NUMBER IS
      vcdevmot       NUMBER(3);
      num_error      NUMBER := 0;
      ilinea         NUMBER;
      v_recibo       VARCHAR2(10) := NULL;
      v_proceso      VARCHAR2(10) := NULL;
      vtraza         NUMBER := 0;
      vobj           VARCHAR2(1000) := 'pac_cargas_ext_sepa.f_insertar_devbanordenantes';
      vparam         VARCHAR2(2000)
         := 'pnnumnif:' || pnnumnif || ' ptsufijo:' || ptsufijo || ' pfremesa:' || pfremesa
            || ' pccobban:' || pccobban || ' ptordnom:' || ptordnom || ' pnordreg:'
            || pnordreg || ' ptotalr :' || ptotalr || ' psproces:' || psproces || ' pfichero:'
            || pfichero;
      vncuenta       cobbancario.ncuenta%TYPE;
      vctipban       cobbancario.ctipban%TYPE;
      vcdoment       cobbancario.cdoment%TYPE;
      vcdomsuc       cobbancario.cdomsuc%TYPE;
      vnnumnif       cobbancario.nnumnif%TYPE;
   BEGIN
      vtraza := 10;

      UPDATE devbanordenantes
         SET iordtot_r = iordtot_r + ptotalr,
             iordtot_t = iordtot_t + ptotalr,
             nordtot_r = nordtot_r + 1,
             nordtot_t = nordtot_r + 1
       WHERE sdevolu = p_seqdev;

      --WHERE sdevolu = pnordreg;
      vtraza := 20;

      IF SQL%NOTFOUND THEN
         vtraza := 25;

         BEGIN
            SELECT ncuenta, ctipban, cdoment, cdomsuc, nnumnif
              INTO vncuenta, vctipban, vcdoment, vcdomsuc, vnnumnif
              FROM cobbancario
             WHERE ccobban = pccobban;
         EXCEPTION
            WHEN OTHERS THEN
               vncuenta := NULL;
               vctipban := NULL;
         END;

         BEGIN
            vtraza := 30;

            INSERT INTO devbanpresentadores
                        (sdevolu, cempres, cdoment, cdomsuc,
                         fsoport, nnumnif, tsufijo,
                         tprenom, fcarga, cusuari, tficher, nprereg,
                         ipretot_r, ipretot_t, npretot_r, npretot_t, sproces)
                 VALUES (p_seqdev, gvcempres, NVL(vcdoment, 0), NVL(vcdomsuc, 0),
                         NVL(pfremesa, f_sysdate), NVL(vnnumnif, 'x'), 'x',
                         NVL(ptordnom, 'x'), f_sysdate, f_user, NVL(pfichero, 'x'), pnordreg,
                         ptotalr, ptotalr, pnordreg, pnordreg, psproces);

            vtraza := 40;

            INSERT INTO devbanordenantes
                        (sdevolu, nnumnif, tsufijo,
                         fremesa, ccobban, tordnom,
                         nordccc, nordreg, iordtot_r, iordtot_t, nordtot_r, nordtot_t, ctipban)
                 VALUES (p_seqdev, NVL(pnnumnif, 'x'), NVL(ptsufijo, 'x'),
                         NVL(pfremesa, f_sysdate), NVL(pccobban, 0), NVL(ptordnom, 'x'),
                         NVL(vncuenta, 'x'), pnordreg, ptotalr, ptotalr, 1, 1, vctipban);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               -- Cargar el mismo fichero dos veces el mismo día da error en
               -- DEVBANPRESENTADORES_UK1 (CDOMENT, CDOMSUC, FSOPORT, TFICHER)
               -- NO HACEMOS EL INSERT Y LO CONSIDERAMOS OK
               vtraza := 50;
               num_error := 0;
         END;
      END IF;

      vtraza := 60;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobj, vtraza, vparam, SQLERRM);
         --quan no s'ha trobat el rebut inserto a procesoscab el rebut no trobat
         num_error :=
            f_proceslin(psproces,
                        SUBSTR('Carga DEVBANORDENANTES/DEVBANPRESENTADORES: (' || p_seqdev
                               || ') ' || ' NIF:' || pnnumnif || ' ccobban:' || pccobban
                               || ' sproces:' || psproces || ' ' || SQLERRM || ' traza('
                               || vtraza || ')',
                               1, 120),
                        num_error, ilinea);
         num_error := 103943;
         --Error al insertar en DEVBANORDENANTES

         RETURN(num_error);
   END f_insertar_devbanordenantes;
-- 18. 0021718: MDP_A001-Domiciliaciones - 0111176 - Fin
END pac_cargas_ext_sepa;

/

  GRANT EXECUTE ON "AXIS"."PAC_CARGAS_EXT_SEPA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CARGAS_EXT_SEPA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CARGAS_EXT_SEPA" TO "PROGRAMADORESCSI";
