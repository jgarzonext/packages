--------------------------------------------------------
--  DDL for Package Body PAC_CARGAS_FARAGGI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_CARGAS_FARAGGI" IS
   /******************************************************************************
      NOMBRE:      pac_cargas_faraggi
      PROPÓSITO: Funciones para la gestión de la carga de procesos
      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        14/10/2014   NSS              1. Creación del package.
     2.0        15/08/2015   ACL              2. 0033884/212340: POS - En "f_modi_siniestro" corregir la llamada a la función F_INS_PAGO, se agrega el parámetro ncheque.
   ******************************************************************************/

   /*************************************************************************
      1.0.0.0.0 f_SIN_ejecutarcarga
      1.1.0.0.0 ....f_sin_ejecutarcargafichero
      1.1.1.0.0 ........f_sin_leefichero
      1.2.0.0.0 ....f_sin_ejecutarcargaproceso
      1.2.1.0.0 ........f_altasiniestro.............(ALTA)
   *************************************************************************/

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
         vnum_err := f_proceslin(p_propro, SUBSTR(p_protxt, 1, 120), 1, vnnumlin);
      END IF;
   END p_genera_logs;

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
   FUNCTION p_marcalinea(
      p_pro IN NUMBER,
      p_lin IN NUMBER,
      p_tip IN VARCHAR2,
      p_est IN NUMBER,
      p_val IN NUMBER,
      p_seg IN NUMBER,
      p_id_ext IN VARCHAR2,
      p_ncarg IN NUMBER,
      p_sin IN NUMBER DEFAULT NULL,
      p_tra IN NUMBER DEFAULT NULL,
      p_per IN NUMBER DEFAULT NULL,
      p_rec IN NUMBER DEFAULT NULL,
      p_idint IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'pac_cargas_faraggi.P_MARCALINEA';
      num_err        NUMBER;
      vtipo          NUMBER;
      num_lin        NUMBER;
      num_aux        NUMBER;
   BEGIN
      IF p_tip = 'ALTA' THEN
         vtipo := 0;
      ELSIF p_tip = 'ALTA_SIN'
            OR p_tip = 'MODI_SIN' THEN
         vtipo := 1;
      ELSIF p_tip = 'ALTA_REC'
            OR p_tip = 'MODI_REC' THEN
         vtipo := 2;
      ELSE
         vtipo := 0;
      END IF;

      num_err :=
         pac_gestion_procesos.f_set_carga_ctrl_linea
            (p_pro, p_lin, vtipo, NVL(p_idint, p_lin), p_tip, p_est, p_val, p_seg,   -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
             p_id_ext,   -- Fi Bug 14888
                         -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
             p_ncarg,   -- Fi Bug 16324
             p_sin, p_tra, p_per, p_rec);

      IF num_err <> 0 THEN   --Si fallan estas funciones de gestión salimos del programa
         p_genera_logs(vobj, 1, num_err,
                       'p=' || p_pro || ' l=' || p_lin || ' t=' || p_tip || ' EST=' || p_est
                       || ' v=' || p_val || ' s=' || p_seg,
                       p_pro, 'Error ' || num_err || ' l=' || p_lin || ' e=' || p_est);
         num_err := 1;
      END IF;

      RETURN num_err;
   END p_marcalinea;

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
   FUNCTION p_marcalineaerror(
      p_pro IN NUMBER,
      p_lin IN NUMBER,
      p_ner IN NUMBER,
      p_tip IN NUMBER,
      p_cod IN NUMBER,
      p_men IN VARCHAR2)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'pac_cargas_faraggi.P_MARCALINEAERROR';
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
   END p_marcalineaerror;

   /*************************************************************************
                                    Función que devuelve una fecha,
          si la conversión de char a fecha es correcta.
          param p_txt    IN  : caracter a convertir
          param p_for    IN  : formato fecha a convertir
          devuelve fecha o null si existe error.
      *************************************************************************/
   FUNCTION converteix_charadate(p_txt IN VARCHAR2, p_for IN VARCHAR2)
      RETURN DATE IS
      d_ret          DATE;
   BEGIN
      BEGIN
         d_ret := TO_DATE(p_txt, p_for);
      EXCEPTION
         WHEN OTHERS THEN
            d_ret := NULL;
      END;

      RETURN d_ret;
   END converteix_charadate;

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
      SELECT MAX(cvalaxis)
        INTO v_ret
        FROM int_codigos_emp
       WHERE cempres = k_empresaaxis
         AND ccodigo = p_cod
         AND cvalemp = p_emp;

      RETURN v_ret;
   END;

   -- Bug 0017569 - FAL - 11/02/2011 - CRT - Interfases y gestión personas
   /*************************************************************************
        Función que da de alta la persona en Host
          param in x : registro tipo int_polizas_ASEFA
          param in psinterf: id interfase obtenido en la busqueda persona host
          return : 0 si ha ido bien
    *************************************************************************/

   /***************************************************************************
                           FUNCTION f_next_carga
      Asigna número de carga
         return         : Número de carga
   ***************************************************************************/
   FUNCTION f_next_carga
      RETURN NUMBER IS
      v_seq          NUMBER;
   BEGIN
      SELECT sncarga.NEXTVAL
        INTO v_seq
        FROM DUAL;

      RETURN v_seq;
   END f_next_carga;

   /***************************************************************************
         FUNCTION f_ins_mig_logs_emp
      Inserta registro en la tabla de logs de las cargas de las tablas APRA a
      tablas MIG
         param in pncarga : número de carga
         param in pmig_pk : valor primary key del registro de APRA
         param in ptipo   : tipo log (E=error, I=Información, W-Warning)
         param in ptexto  : Texto log
         return           : código error
   ***************************************************************************/
   FUNCTION f_ins_mig_logs_emp(
      pncarga IN NUMBER,
      pmig_pk IN VARCHAR2,
      ptipo IN VARCHAR2,
      ptexto IN VARCHAR2,
      pseq OUT NUMBER)
      RETURN NUMBER IS
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      SELECT sseqlogmig.NEXTVAL
        INTO pseq
        FROM DUAL;

      INSERT INTO mig_logs_emp
                  (ncarga, seqlog, fecha, mig_pk, tipo, incid)
           VALUES (pncarga, pseq, f_sysdate, pmig_pk, ptipo, ptexto);

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN SQLCODE;
   END f_ins_mig_logs_emp;

   /*************************************************************************
                procedimiento que lee el fichero SINIESTRO
          param in p_nombre   : Nombre fichero
          param in p_path   : Nuombre path
          param in psproces   : Número proceso
          param in   out pdeserror   : mensaje de error
      *************************************************************************/
   PROCEDURE f_sin_leefichero(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      pdeserror OUT VARCHAR2,
      psproces IN NUMBER) IS
      num_err        NUMBER;
      v_pasexec      NUMBER := 1;
      vparam         VARCHAR2(1) := NULL;
      vobj           VARCHAR2(200) := 'pac_cargas_faraggi.F_SIN_LEEFICHERO';
--      v_empresa      VARCHAR2(100);
      e_object_error EXCEPTION;
      vlinea         NUMBER := 0;
      v_numerr       NUMBER;
      errgrabarprov  EXCEPTION;
      vfichero       UTL_FILE.file_type;
      reglinea       VARCHAR2(4000);
      v_linea        NUMBER(15) := 0;
      reg_cabecera   carga_cab_faraggi%ROWTYPE;
      reg_detalle    carga_det_faraggi%ROWTYPE;
   BEGIN
      pdeserror := NULL;
      v_pasexec := 1;

      IF p_nombre IS NULL THEN
         pdeserror := f_axis_literales(103835, k_idiomaaaxis) || ':p_nombre';
         RAISE e_object_error;
      END IF;

      IF p_path IS NULL THEN
         pdeserror := f_axis_literales(103835, k_idiomaaaxis) || ':p_path';
         RAISE e_object_error;
      END IF;

      IF psproces IS NULL THEN
         pdeserror := f_axis_literales(103835, k_idiomaaaxis) || ':psproces';
         RAISE e_object_error;
      END IF;

      BEGIN
         -- leo fichero
         v_pasexec := 2;
         vfichero := UTL_FILE.fopen(p_path, p_nombre, 'r', 32000);
         v_pasexec := 3;

         LOOP
            BEGIN
               v_pasexec := 5;
               UTL_FILE.get_line(vfichero, reglinea);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  EXIT;
               WHEN OTHERS THEN
                  --     v_numerr:= p_marcalineaerror(psproces, v_linea, NULL, 1, SQLCODE,
                    --                                f_axis_literales(105133, k_idiomaaaxis) || v_linea);
                  pdeserror := SQLERRM;
                  RAISE errgrabarprov;
            END;

            v_pasexec := 4;

            BEGIN
               v_linea := v_linea + 1;
               v_pasexec := 6;

               IF SUBSTR(reglinea, 1, 1) = 1 THEN   -- cabecera
                  v_numerr := p_marcalinea(psproces, v_linea, 'ALTA_SIN', 3, 0, NULL,
                                           TO_NUMBER(SUBSTR(reglinea, 12, 10)), NULL,   -- Fi Bug 16324
                                           NULL, NULL, NULL, NULL,
                                           v_linea || '(' || SUBSTR(reglinea, 1, 1) || ')');
                  v_pasexec := 7;
                  reg_cabecera.sdenunc := SUBSTR(reglinea, 2, 10);
                  reg_cabecera.sfaragi := SUBSTR(reglinea, 12, 10);
                  reg_cabecera.ccodest := SUBSTR(reglinea, 22, 1);
                  reg_cabecera.npoliza := SUBSTR(reglinea, 23, 12);
                  reg_cabecera.ncertif := SUBSTR(reglinea, 35, 6);
                  reg_cabecera.nrutase := SUBSTR(reglinea, 41, 8);
                  reg_cabecera.fsinies := TO_DATE(SUBSTR(reglinea, 49, 8), 'YYYYMMDD');
                  reg_cabecera.fnotifi := TO_DATE(SUBSTR(reglinea, 57, 8), 'YYYYMMDD');
                  reg_cabecera.nrutben := SUBSTR(reglinea, 65, 8);
                  reg_cabecera.fpago := TO_DATE(SUBSTR(reglinea, 73, 8), 'YYYYMMDD');
                  reg_cabecera.sfrgrel := SUBSTR(reglinea, 81, 10);
                  reg_cabecera.tobserv := SUBSTR(reglinea, 91, 2000);
                  reg_cabecera.cestpag := SUBSTR(reglinea, 2091, 1);
                  reg_cabecera.crechaz := SUBSTR(reglinea, 2092, 4);
                  reg_cabecera.ctippag := SUBSTR(reglinea, 2096, 1);
                  reg_cabecera.cforpag := SUBSTR(reglinea, 2097, 1);
                  reg_cabecera.cbanco := SUBSTR(reglinea, 2098, 3);
                  reg_cabecera.ctipban := SUBSTR(reglinea, 2101, 1);
                  reg_cabecera.ccuenta := SUBSTR(reglinea, 2102, 17);
                  reg_cabecera.scarga := NULL;
                  reg_cabecera.falta := f_sysdate;
                  reg_cabecera.sseguro := NULL;
                  reg_cabecera.sproduc := NULL;
                  reg_cabecera.sperson := NULL;
                  reg_cabecera.sbenefi := NULL;
                  reg_cabecera.ctipdes := NULL;
                  reg_cabecera.cbancar := NULL;
                  reg_cabecera.sproces := psproces;
                  reg_cabecera.nlinea := v_linea;
                  reg_cabecera.fproces := NULL;
                  reg_cabecera.nsinies := NULL;
                  reg_cabecera.tipo_oper := 1;

                  INSERT INTO carga_cab_faraggi
                       VALUES reg_cabecera;
               ELSIF SUBSTR(reglinea, 1, 1) = 2 THEN   --detalle
                  v_pasexec := 8;
                  v_numerr := p_marcalinea(psproces, v_linea, 'ALTA_SIN', 3, 0, NULL,
                                           TO_NUMBER(SUBSTR(reglinea, 2, 10)), NULL,   -- Fi Bug 16324
                                           NULL, NULL, NULL, NULL,
                                           v_linea || '(' || SUBSTR(reglinea, 1, 1) || ')');
                  reg_detalle.sfaragi := SUBSTR(reglinea, 2, 10);
                  reg_detalle.nnumlin := SUBSTR(reglinea, 12, 3);
                  reg_detalle.tpresta := SUBSTR(reglinea, 15, 40);
                  reg_detalle.tcobert := SUBSTR(reglinea, 55, 3);
                  reg_detalle.ifranqu := SUBSTR(reglinea, 58, 9);
                  reg_detalle.ipago := SUBSTR(reglinea, 67, 9);
                  reg_detalle.fcambio := TO_DATE(SUBSTR(reglinea, 76, 8), 'YYYYMMDD');
                  reg_detalle.cgarant := NULL;
                  reg_detalle.scarga := NULL;
                  reg_detalle.falta := f_sysdate;
                  reg_detalle.sproces := psproces;
                  reg_detalle.nlinea := v_linea;
                  reg_detalle.fproces := NULL;
                  reg_detalle.tipo_oper := 2;

                  INSERT INTO carga_det_faraggi
                       VALUES reg_detalle;
               END IF;

               v_pasexec := 10;
            EXCEPTION
               WHEN OTHERS THEN
                  v_numerr := p_marcalinea(psproces, v_linea, 'ALTA_SIN', 1, 0, NULL,
                                           reg_detalle.sfaragi, NULL,   -- Fi Bug 16324
                                           NULL, NULL, NULL, NULL,
                                           v_linea || '(' || SUBSTR(reglinea, 1, 1) || ')');
                  v_numerr := p_marcalineaerror(psproces, v_linea, NULL, 1, SQLCODE,
                                                f_axis_literales(105133, k_idiomaaaxis)
                                                || '(lin: ' || v_linea || ') -' || SQLERRM);

                  IF v_numerr <> 0 THEN
                     RAISE errgrabarprov;
                  END IF;
            END;
         END LOOP;
      EXCEPTION
         WHEN errgrabarprov THEN
            ROLLBACK;
            p_tab_error(f_sysdate, f_user, vobj, v_pasexec, 108953, vobj || '-' || pdeserror);
            pdeserror := f_axis_literales(108953, k_idiomaaaxis) || ':' || pdeserror;
            RAISE e_object_error;
         WHEN OTHERS THEN
            ROLLBACK;
            p_tab_error(f_sysdate, f_user, vobj, v_pasexec, SQLCODE, SQLERRM);
            pdeserror := f_axis_literales(105133, k_idiomaaaxis) || ':' || vlinea || '    '
                         || f_axis_literales(1000136, k_idiomaaaxis) || ':'
                         || TO_NUMBER(v_pasexec + 1) || ' ' || SQLERRM;
            RAISE e_object_error;
      END;

      v_pasexec := 8;
      COMMIT;
   EXCEPTION
      WHEN e_object_error THEN
         ROLLBACK;

         IF pdeserror IS NULL THEN
            pdeserror := f_axis_literales(108953, k_idiomaaaxis);
         END IF;

         NULL;
      WHEN OTHERS THEN
         ROLLBACK;
         pdeserror := f_axis_literales(103187, k_idiomaaaxis) || SQLERRM;
         p_tab_error(f_sysdate, f_user, vobj, v_pasexec, SQLCODE, SQLERRM);
   END f_sin_leefichero;

   /*************************************************************************
          procedimiento que da de alta siniestros en las mig
          param in x : registro tipo carga_det_faraggi
      *************************************************************************/
   FUNCTION f_altasiniestro_mig(
      faraggi IN OUT carga_cab_faraggi%ROWTYPE,
      pterror IN OUT VARCHAR2)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'pac_cargas_faraggi.F_ALTASINIESTRO_MIG';
      v_ncarga       NUMBER;
      v_seq          NUMBER;
      errdatos       EXCEPTION;
      --Tablas
      v_mig_seg      mig_seguros%ROWTYPE;
      v_mig_sin      mig_sin_siniestro%ROWTYPE;
      v_mig_smv      mig_sin_movsiniestro%ROWTYPE;
      v_mig_tra      mig_sin_tramitacion%ROWTYPE;
      v_mig_trm      mig_sin_tramita_movimiento%ROWTYPE;
      v_mig_res      mig_sin_tramita_reserva%ROWTYPE;
      v_mig_tpa      mig_sin_tramita_pago%ROWTYPE;
      v_mig_per      mig_personas%ROWTYPE;
      v_mig_tmp      mig_sin_tramita_movpago%ROWTYPE;
      v_mig_tpg      mig_sin_tramita_pago_gar%ROWTYPE;
      v_mig_des      mig_sin_tramita_dest%ROWTYPE;
      v_mig_ref      mig_sin_siniestro_referencias%ROWTYPE;
      v_cunitra      VARCHAR2(250);
      v_ctramit      VARCHAR2(250);
      v_sperson      per_personas.sperson%TYPE;
      v_norden       NUMBER := 1;
      verror         VARCHAR2(1000);
      cerror         NUMBER;
      vtraza         NUMBER;
      vnum_err       NUMBER;
      v_rowid        ROWID;
      v_rowid_ini    ROWID;
      pid            VARCHAR2(200);
      b_warning      BOOLEAN;
      v_csincia      VARCHAR2(250);
      n_aux          NUMBER;
      v_nriesgo      sin_siniestro.nriesgo%TYPE;
      v_user         VARCHAR2(20);
      v_sysdate      DATE;
      vseq           NUMBER := 0;
   BEGIN
      vtraza := 10;
      v_user := f_user;
      v_sysdate := f_sysdate;
      cerror := 0;
      pid := faraggi.sfaragi;
      b_warning := FALSE;
      --Inicializamos la cabecera de la carga
      v_ncarga := f_next_carga;
      faraggi.scarga := v_ncarga;
      vnum_err := f_ins_mig_logs_emp(v_ncarga, 'Inicio', 'I', 'Carga Siniestros', v_seq);
      vtraza := 20;

      INSERT INTO mig_cargas
                  (ncarga, cempres, finiorg, ffinorg, ID, estorg)
           VALUES (v_ncarga, k_empresaaxis, f_sysdate, f_sysdate, pid, 'OK');

-------------------- Valida ---------------------
-- ya se han hecho las validaciones en f_sin_validarsiniestro

      -------------------- INICI ---------------------
      vtraza := 30;

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, 'CARGA_CAB_FARAGGI', 'MIG_SEGUROS', 0);

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, 'CARGA_CAB_FARAGGI', 'MIG_PERSONAS', 1);

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, 'CARGA_CAB_FARAGGI', 'MIG_SIN_SINIESTRO', 2);

      --      INSERT INTO mig_cargas_tab_mig
      --                  (ncarga, tab_org, tab_des, ntab)
      --           VALUES (v_ncarga, 'CARGA_CAB_FARAGGI', 'MIG_SIN_SINIESTRO_REFERENCIAS', 3);
      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, 'CARGA_CAB_FARAGGI', 'MIG_SIN_TRAMITACION', 4);

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, 'CARGA_CAB_FARAGGI', 'MIG_SIN_TRAMITA_MOVIMIENTO', 5);

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, 'CARGA_CAB_FARAGGI', 'MIG_SIN_MOVSINIESTRO', 6);

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, 'CARGA_CAB_FARAGGI', 'MIG_SIN_TRAMITA_RESERVA', 7);

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, 'CARGA_CAB_FARAGGI', 'MIG_SIN_TRAMITA_DEST', 8);

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, 'CARGA_CAB_FARAGGI', 'MIG_SIN_TRAMITA_PAGO', 9);

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, 'CARGA_CAB_FARAGGI', 'MIG_SIN_TRAMITA_MOVPAGO', 10);

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, 'CARGA_CAB_FARAGGI', 'MIG_SIN_TRAMITA_PAGO_GAR', 11);

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, 'CARGA_CAB_FARAGGI', 'MIG_SIN_SINIESTRO_REFERENCIAS', 12);

      -- Necesitamos informar mig_seguros para join con mig_sin_siniestros
      vtraza := 40;
      v_mig_sin.mig_pk := v_ncarga || '/' || faraggi.sdenunc;
      v_mig_sin.mig_fk := v_mig_sin.mig_pk;
      v_mig_sin.ncarga := v_ncarga;
      v_mig_sin.cestmig := 1;

      SELECT v_ncarga ncarga, -4 cestmig, v_mig_sin.mig_fk mig_pk, -1 mig_fk,
             cagente, npoliza, ncertif, fefecto,
             creafac, cactivi, ctiprea, cidioma,
             cforpag, cempres, sproduc, casegur,
             nsuplem, sseguro, 0 sperson
        INTO v_mig_seg.ncarga, v_mig_seg.cestmig, v_mig_seg.mig_pk, v_mig_seg.mig_fk,
             v_mig_seg.cagente, v_mig_seg.npoliza, v_mig_seg.ncertif, v_mig_seg.fefecto,
             v_mig_seg.creafac, v_mig_seg.cactivi, v_mig_seg.ctiprea, v_mig_seg.cidioma,
             v_mig_seg.cforpag, v_mig_seg.cempres, v_mig_seg.sproduc, v_mig_seg.casegur,
             v_mig_seg.nsuplem, v_mig_seg.sseguro, v_mig_seg.sperson
        FROM seguros
       WHERE sseguro = faraggi.sseguro;

      vtraza := 45;

      INSERT INTO mig_seguros
           VALUES v_mig_seg
        RETURNING ROWID
             INTO v_rowid;

      INSERT INTO mig_pk_emp_mig
           VALUES (0, v_ncarga, 0, v_mig_seg.mig_pk);

      vtraza := 50;

      --MIG_PERSONA cargamos mig_personas por las joins que hay con mig_tramita_pago
      BEGIN
         SELECT sperson, nriesgo
           INTO v_sperson, v_nriesgo
           FROM seguros s, asegurados a
          WHERE s.sseguro = faraggi.sseguro
            AND a.sseguro = s.sseguro;
      EXCEPTION
         WHEN OTHERS THEN
            verror := 'No se encuentra el Asegurado de la póliza: ' || faraggi.sseguro;
            cerror := 9001086;
            RAISE errdatos;
      END;

      v_mig_per.ncarga := v_ncarga;
      v_mig_per.cestmig := -4;
      v_mig_per.mig_pk := v_mig_sin.mig_pk || '/01/' || faraggi.sperson;
      v_mig_per.idperson := faraggi.sperson;   --v_sperson;
      v_mig_per.ctipide := 0;
      v_mig_per.cestper := 0;
      v_mig_per.cpertip := 0;
      v_mig_per.swpubli := 0;
      v_mig_per.tapelli1 := ' ';

      INSERT INTO mig_personas
           VALUES v_mig_per
        RETURNING ROWID
             INTO v_rowid;

      INSERT INTO mig_pk_emp_mig
           VALUES (0, v_ncarga, 1, v_mig_per.mig_pk);

      vtraza := 60;
      --beneficiario
      v_mig_per.mig_pk := v_mig_sin.mig_pk || '/02/' || faraggi.sbenefi;
      v_mig_per.idperson := faraggi.sbenefi;

      INSERT INTO mig_personas
           VALUES v_mig_per
        RETURNING ROWID
             INTO v_rowid;

      INSERT INTO mig_pk_emp_mig
           VALUES (0, v_ncarga, 1, v_mig_per.mig_pk);

      --Información de sin siniestro
      vtraza := 70;
      v_mig_sin.ncarga := v_ncarga;
      v_mig_sin.cestmig := 1;
      v_mig_sin.nriesgo := v_nriesgo;
      v_mig_sin.sseguro := faraggi.sseguro;
      v_mig_sin.nsinies := 0;   --Lo calcula despues la función de pac_mig_axis
      v_mig_sin.fsinies := TRIM(faraggi.fsinies);   --TO_DATE(TRIM(faraggi.fsinies), 'rrrrmmdd');
      v_mig_sin.fnotifi := TRIM(faraggi.fnotifi);   --TO_DATE(TRIM(faraggi.fnotifi), 'rrrrmmdd');
      v_mig_sin.ccausin := 6;   -- Asistencia sanitaria
      v_mig_sin.cmotsin := 0;   -- Recibida asistencia sanitaria
      --v_mig_sin.cagente := v_mig_seg.cagente;
      --v_mig_sin.ccarpeta := 0;
      v_mig_sin.cusualt := v_user;
      v_mig_sin.falta := v_sysdate;
      v_mig_sin.csincia := faraggi.sdenunc;
      vtraza := 75;

      FOR des IN (SELECT tpresta
                    FROM carga_det_faraggi
                   WHERE sproces = faraggi.sproces
                     AND sfaragi = faraggi.sfaragi) LOOP
         v_mig_sin.tsinies := v_mig_sin.tsinies || des.tpresta || ';';
      END LOOP;

      vtraza := 76;

      SELECT MAX(nmovimi)
        INTO n_aux
        FROM movseguro
       WHERE sseguro = faraggi.sseguro
         AND fefecto <= v_mig_sin.fsinies
         AND cmovseg <> 52;

      v_mig_sin.nmovimi := n_aux;
      vtraza := 77;

      INSERT INTO mig_sin_siniestro
           VALUES v_mig_sin
        RETURNING ROWID
             INTO v_rowid;

      INSERT INTO mig_pk_emp_mig
           VALUES (0, v_ncarga, 2, v_mig_sin.mig_pk);

      --MIG_SIN_SINIESTRO_REFERENCIAS
      vtraza := 80;
      v_mig_ref.ncarga := v_ncarga;
      v_mig_ref.cestmig := 1;
      v_mig_ref.mig_pk := v_mig_sin.mig_pk || '/RE/' || 0;
      v_mig_ref.mig_fk := v_mig_sin.mig_pk;
      v_mig_ref.nsinies := 0;
      v_mig_ref.ctipref := 7;   -- Referencia Faraggi
      v_mig_ref.trefext := faraggi.sfaragi;
      v_mig_ref.frefini := v_sysdate;
      v_mig_ref.cusualt := v_user;
      v_mig_ref.falta := v_sysdate;

      INSERT INTO mig_sin_siniestro_referencias
           VALUES v_mig_ref
        RETURNING ROWID
             INTO v_rowid;

      INSERT INTO mig_pk_emp_mig
           VALUES (0, v_ncarga, 3, v_mig_ref.mig_pk);

      v_mig_ref.ncarga := v_ncarga;
      v_mig_ref.cestmig := 1;
      v_mig_ref.mig_pk := v_mig_sin.mig_pk || '/RE/' || 1;
      v_mig_ref.mig_fk := v_mig_sin.mig_pk;
      v_mig_ref.nsinies := 0;
      v_mig_ref.ctipref := 8;   -- Numero de denuncia
      v_mig_ref.trefext := faraggi.sdenunc;
      v_mig_ref.frefini := v_sysdate;
      v_mig_ref.cusualt := v_user;
      v_mig_ref.falta := v_sysdate;

      INSERT INTO mig_sin_siniestro_referencias
           VALUES v_mig_ref
        RETURNING ROWID
             INTO v_rowid;

      INSERT INTO mig_pk_emp_mig
           VALUES (0, v_ncarga, 3, v_mig_ref.mig_pk);

      --SIN_TRAMITACION
      vtraza := 90;
      v_mig_tra.ncarga := v_ncarga;
      v_mig_tra.cestmig := 1;
      v_mig_tra.mig_pk := v_mig_sin.mig_pk || '/T/' || 0;
      v_mig_tra.mig_fk := v_mig_sin.mig_pk;   --v_ncarga || '/' || faraggi.sdenunc;
      v_mig_tra.nsinies := 0;   -- Se determina en el PAC_MIG_AXIS
      v_mig_tra.ntramit := 0;
      v_mig_tra.ctramit := 0;
      v_mig_tra.cinform := 1;
      v_mig_tra.cusualt := v_user;
      v_mig_tra.falta := v_sysdate;

      INSERT INTO mig_sin_tramitacion
           VALUES v_mig_tra
        RETURNING ROWID
             INTO v_rowid;

      INSERT INTO mig_pk_emp_mig
           VALUES (0, v_ncarga, 4, v_mig_tra.mig_pk);

      --SIN_TRAMITA_MOVIMIENTO
      vtraza := 100;
      v_mig_trm.ncarga := v_ncarga;
      v_mig_trm.cestmig := 1;
      v_mig_trm.mig_pk := v_mig_sin.mig_pk || '/TM/' || 0;
      v_mig_trm.mig_fk := v_mig_tra.mig_pk;
      v_mig_trm.nsinies := 0;   --Lo  de sin_siniestro el pac_mig_axis
      v_mig_trm.ntramit := 0;
      v_mig_trm.nmovtra := 0;   -- M0vimiento inicial (0)
      cerror := pac_siniestros.f_get_unitradefecte(k_empresaaxis, v_cunitra, v_ctramit);

      IF cerror <> 0 THEN
         verror := 'Error recuperando los tramitadores para la empresa : ' || k_empresaaxis;
         RAISE errdatos;
      END IF;

      v_mig_trm.cunitra := v_cunitra;
      v_mig_trm.ctramitad := v_ctramit;
      v_mig_trm.cesttra := 0;   --ABIERTO
      v_mig_trm.csubtra := 0;
      v_mig_trm.festtra := v_mig_sin.fnotifi;   --v_mig_sin.fsinies;
      v_mig_trm.cusualt := v_user;
      v_mig_trm.falta := v_sysdate;

      INSERT INTO mig_sin_tramita_movimiento
           VALUES v_mig_trm
        RETURNING ROWID
             INTO v_rowid;

      INSERT INTO mig_pk_emp_mig
           VALUES (0, v_ncarga, 5, v_mig_trm.mig_pk);

      --SIN_MOVSINIESTRO
      vtraza := 110;
      v_mig_smv.ncarga := v_ncarga;
      v_mig_smv.cestmig := 1;
      v_mig_smv.mig_pk := v_mig_sin.mig_pk || '/SM/' || 0;
      v_mig_smv.mig_fk := v_mig_sin.mig_pk;
      v_mig_smv.nsinies := 0;   --Lo recupera en el pac_mig_axis
      v_mig_smv.nmovsin := 0;
      v_mig_smv.cestsin := v_mig_trm.cesttra;
      v_mig_smv.festsin := v_mig_sin.fnotifi;   --v_mig_sin.fsinies;
      v_mig_smv.cunitra := v_mig_trm.cunitra;
      v_mig_smv.ctramitad := v_mig_trm.ctramitad;
      v_mig_smv.cusualt := v_user;
      v_mig_smv.falta := v_sysdate;

      INSERT INTO mig_sin_movsiniestro
           VALUES v_mig_smv
        RETURNING ROWID
             INTO v_rowid;

      INSERT INTO mig_pk_emp_mig
           VALUES (0, v_ncarga, 6, v_mig_smv.mig_pk);

      --SIN_TRAMITA_DESTINATARIO
      vtraza := 300;
      v_mig_des.ncarga := v_ncarga;
      v_mig_des.cestmig := 1;
      v_mig_des.mig_pk := v_mig_sin.mig_pk || '/' || faraggi.sbenefi;
      v_mig_des.mig_fk := v_mig_tra.mig_pk;
      v_mig_des.nsinies := 0;
      v_mig_des.ntramit := v_mig_tra.ntramit;
      v_mig_des.sperson := faraggi.sbenefi;
      v_mig_des.ctipdes := faraggi.ctipdes;
      v_mig_des.ctipban := faraggi.ctipban;
      v_mig_des.cbancar := faraggi.cbancar;
      v_mig_des.cpagdes := 1;
      v_mig_des.pasigna := 100;
      v_mig_des.cusualt := v_user;
      v_mig_des.falta := v_sysdate;

      INSERT INTO mig_sin_tramita_dest
           VALUES v_mig_des
        RETURNING ROWID
             INTO v_rowid;

      INSERT INTO mig_pk_emp_mig
           VALUES (0, v_ncarga, 8, v_mig_des.mig_pk);

      vtraza := 310;

      --SIN_TRAMITA_RESERVA
      FOR gar IN (SELECT   cgarant, tcobert, SUM(ipago) ipago, SUM(ifranqu) ifranqu
                      FROM carga_det_faraggi
                     WHERE sproces = faraggi.sproces
                       AND sfaragi = faraggi.sfaragi
                  GROUP BY cgarant, tcobert) LOOP
         vtraza := 200;
         v_mig_res.ncarga := v_ncarga;
         v_mig_res.cestmig := 1;
         v_mig_res.mig_pk := v_mig_sin.mig_pk || '/R/' || gar.cgarant;
         v_mig_res.mig_fk := v_mig_tra.mig_pk;
         v_mig_res.nsinies := 0;
         v_mig_res.ntramit := v_mig_tra.ntramit;
         v_mig_res.nmovres := 0;
         v_mig_res.ctipres := 1;   --Indemni
         v_mig_res.ccalres := 0;
         v_mig_res.cgarant := f_buscavalor('FARAGGI_GARANTIAS', gar.tcobert);   --traduccion gar.tcobert
         v_mig_res.fmovres := v_mig_sin.fsinies;
         v_mig_res.cmonres := 'CLP';
         v_mig_res.cgarant := gar.cgarant;
         v_mig_res.ireserva := NVL(TRIM(gar.ipago), 0);
         v_mig_res.ifranq := NVL(TRIM(gar.ifranqu), 0);
         v_mig_res.sproces := faraggi.sproces;
         v_mig_res.cusualt := v_user;
         v_mig_res.falta := v_sysdate;
         v_mig_res.idres := NVL(v_mig_res.idres, 0) + 1;   -- Sequencial empezando por 1
         v_mig_res.cmovres := 0;   -- Alta del siniestro

         INSERT INTO mig_sin_tramita_reserva
              VALUES v_mig_res
           RETURNING ROWID
                INTO v_rowid;

         INSERT INTO mig_pk_emp_mig
              VALUES (0, v_ncarga, 7, v_mig_res.mig_pk);

         vtraza := 210;
         vseq := vseq + 1;
         /*FOR regdet IN (  SELECT   *
                            FROM   carga_det_faraggi
                           WHERE   sfaragi = faraggi.sfaragi
                                   AND tcobert = gar.tcobert
                                   and sproces = faraggi.sproces
                        ORDER BY   nnumlin) LOOP*/--MIG_SIN_TRAMITA_PAGO_GAR
         vtraza := 220;
         v_mig_tpg.ncarga := v_ncarga;
         v_mig_tpg.cestmig := 1;
         v_mig_tpg.mig_pk := v_mig_sin.mig_pk || '/DET/' || vseq;
         v_mig_tpg.mig_fk := v_mig_sin.mig_pk || '/PAG/' || gar.cgarant;   --v_mig_tpa.mig_pk;   -- Esto debe coincidir con la PK de SIN_TRAMITA_PAGO
         v_mig_tpg.sidepag := 0;
         v_mig_tpg.ctipres := v_mig_res.ctipres;
         v_mig_tpg.nmovres := v_mig_res.nmovres;
         v_mig_tpg.cgarant := v_mig_res.cgarant;
         v_mig_tpg.cmonres := v_mig_res.cmonres;
         v_mig_tpg.isinret := gar.ipago;
         v_mig_tpg.fcambio := v_sysdate;
         v_mig_tpg.ifranq := gar.ifranqu;
         v_mig_tpg.cusualt := v_user;
         v_mig_tpg.falta := v_sysdate;
         v_mig_tpg.norden := NVL(v_mig_tpg.norden, 0) + 1;   --seq
         v_mig_tpg.idres := v_mig_res.idres;

         INSERT INTO mig_sin_tramita_pago_gar
              VALUES v_mig_tpg
           RETURNING ROWID
                INTO v_rowid;

         INSERT INTO mig_pk_emp_mig
              VALUES (0, v_ncarga, 11, v_mig_tpg.mig_pk);

         vseq := vseq + 1;
            /*--Después de insertar el detalle del pago se actualiza la reserva con el importe del pago
            vtraza := 221;
            v_mig_res.mig_pk := v_mig_sin.mig_pk || '/R/' || gar.cgarant || vseq;
            v_mig_res.nmovres := v_mig_res.nmovres + 1;
            v_mig_res.ireserva := v_mig_res.ireserva - regdet.ipago;
            v_mig_res.ipago := v_mig_res.ipago + regdet.ipago;
            v_mig_res.ifranq := v_mig_res.ifranq - regdet.ifranqu;
            v_mig_res.idres := NVL(v_mig_res.idres, 0) + 1; -- Sequencial empezando por 1
            v_mig_res.cmovres := 4; -- Pago

            INSERT INTO   mig_sin_tramita_reserva
                 VALUES   v_mig_res
              RETURNING   ROWID
                   INTO   v_rowid;

            INSERT INTO   mig_pk_emp_mig
                 VALUES   (0, v_ncarga, 7, v_mig_res.mig_pk);
         END LOOP;*/
         vtraza := 230;
         --Se supone que no hace falta actualizar la reserva a 0 cuando el siniestro esté aceptado o rechazado, ya que los importes
         --del pago deben cuadrar y al actualizar la reserva con el pago ya debe quedar a 0 finalmente.

         --         --Actualizaremos la reserva a 0, para los siniestros pagados, la reserva se actualiza a 0 a causa del pago
         --         IF faraggi.cestpag IN (0, 1) --aprobado, rechazado
         --         THEN
         --            vtraza := 230;
         --            v_mig_res.ncarga := v_ncarga;
         --            v_mig_res.cestmig := 1;
         --            v_mig_res.mig_pk := v_mig_sin.mig_pk || '/RES/' || v_mig_res.cgarant || '/' || 2;
         --            v_mig_res.mig_fk := v_mig_tra.mig_pk;
         --            v_mig_res.nsinies := 0;
         --            v_mig_res.ntramit := v_mig_tra.ntramit;
         --            v_mig_res.nmovres := 0;
         --            v_mig_res.ctipres := 1;   --Indemni
         --            v_mig_res.cgarant := v_mig_res.cgarant;
         --            v_mig_res.ccalres := 0;   --Manual
         --            v_mig_res.fmovres := v_mig_sin.fsinies;
         --            v_mig_res.cmonres := 'CLP';
         --            v_mig_res.ireserva := 0;
         --            v_mig_res.ipago := gar.ipago;
         --            v_mig_res.icaprie := gar.ipago + gar.ifranqu;
         --            v_mig_res.ifranq := gar.ifranqu;
         --            v_mig_res.sidepag := 0;
         --            -- v_mig_res.sproces := gar.sproces;
         --            v_mig_res.cusualt := v_user;
         --            v_mig_res.falta := v_sysdate;
         --         --v_mig_res.idres := v_mig_res.idres + 1;   -- Sequencial empezando por 1
         --         --v_mig_res.cmovres := 4; -- pago
         --         END IF;
         vtraza := 320;
         v_mig_tpa.ncarga := v_ncarga;
         v_mig_tpa.cestmig := 1;
         v_mig_tpa.mig_pk := v_mig_sin.mig_pk || '/PAG/' || gar.cgarant;   --v_ncarga || '/' || faraggi.sdenunc || '/PAG/' || 0;
         v_mig_tpa.mig_fk := v_ncarga || '/' || faraggi.sdenunc || '/' || faraggi.sbenefi;
         v_mig_tpa.mig_fk2 := v_mig_tra.mig_pk;
         v_mig_tpa.sidepag := 0;
         v_mig_tpa.nsinies := 0;
         v_mig_tpa.ntramit := v_mig_tra.ntramit;
         v_mig_tpa.sperson := faraggi.sbenefi;
         v_mig_tpa.ctipdes := v_mig_des.ctipdes;
         v_mig_tpa.ctipban := v_mig_des.ctipban;
         v_mig_tpa.cbancar := v_mig_des.cbancar;
         v_mig_tpa.cmonres := 'CLP';
         v_mig_tpa.ctippag := 2;
         v_mig_tpa.cconpag := 1;   --Indemni
         v_mig_tpa.sperson := faraggi.sbenefi;
         v_mig_tpa.ccauind := 0;   --otros
         v_mig_tpa.cforpag := f_buscavalor('FARAGGI_FORMAS_PAGO', faraggi.cforpag);
         v_mig_tpa.fordpag := faraggi.fpago;
         v_mig_tpa.isinret := NVL(gar.ipago, 0);
         v_mig_tpa.ifranq := NVL(gar.ifranqu, 0);
         v_mig_tpa.cusualt := v_user;
         v_mig_tpa.falta := v_sysdate;

         INSERT INTO mig_sin_tramita_pago
              VALUES v_mig_tpa
           RETURNING ROWID
                INTO v_rowid;

         INSERT INTO mig_pk_emp_mig
              VALUES (0, v_ncarga, 9, v_mig_tpa.mig_pk);
      END LOOP;

      vtraza := 330;
      --MIG_SIN_TRAMITA_MOVPAGO
      v_mig_tmp.ncarga := v_ncarga;
      v_mig_tmp.cestmig := 1;
      v_mig_tmp.mig_pk := v_mig_sin.mig_pk || '/MOVPAG/' || 0 || vseq;
      v_mig_tmp.mig_fk := v_mig_tpa.mig_pk;
      v_mig_tmp.sidepag := 0;
      v_mig_tmp.nmovpag := 0;
      v_mig_tmp.cestpag := 0;   --Pendiente
      v_mig_tmp.fefepag := v_mig_sin.fsinies;
      v_mig_tmp.cestval := 0;   -- Pendiente de validar
      v_mig_tmp.cusualt := v_user;
      v_mig_tmp.falta := v_sysdate;

      INSERT INTO mig_sin_tramita_movpago
           VALUES v_mig_tmp
        RETURNING ROWID
             INTO v_rowid;

      INSERT INTO mig_pk_emp_mig
           VALUES (0, v_ncarga, 10, v_mig_tmp.mig_pk);

      vtraza := 340;

      IF faraggi.cestpag = 1   --aprobado
                            THEN
         vtraza := 350;
         v_mig_tmp.mig_pk := v_mig_sin.mig_pk || '/MOVPAG/' || 1 || vseq;
         v_mig_tmp.nmovpag := 1;
         v_mig_tmp.cestpag := 1;   --Aceptado
         v_mig_tmp.cestval := 1;   --Validaddo

         INSERT INTO mig_sin_tramita_movpago
              VALUES v_mig_tmp
           RETURNING ROWID
                INTO v_rowid;

         INSERT INTO mig_pk_emp_mig
              VALUES (0, v_ncarga, 10, v_mig_tmp.mig_pk);

         vtraza := 360;
         v_mig_tmp.mig_pk := v_mig_sin.mig_pk || '/MOVPAG/' || 2 || vseq;
         v_mig_tmp.nmovpag := 2;
         v_mig_tmp.cestpag := 2;   --Pagado
         v_mig_tmp.cestval := 1;   --Validado

         INSERT INTO mig_sin_tramita_movpago
              VALUES v_mig_tmp
           RETURNING ROWID
                INTO v_rowid;

         INSERT INTO mig_pk_emp_mig
              VALUES (0, v_ncarga, 10, v_mig_tmp.mig_pk);

         vtraza := 370;
         v_mig_trm.mig_pk := v_mig_sin.mig_pk || '/TM/' || 1;
         v_mig_trm.nmovtra := 1;   -- Movimiento Cierre
         v_mig_trm.cesttra := 1;   -- Cerrado
         v_mig_trm.ccauest := 1;   -- Cierre por finalizacin siniestro
         v_mig_trm.festtra := v_mig_sin.fnotifi;
         v_mig_trm.cusualt := v_user;
         v_mig_trm.falta := v_sysdate;

         INSERT INTO mig_sin_tramita_movimiento
              VALUES v_mig_trm
           RETURNING ROWID
                INTO v_rowid;

         INSERT INTO mig_pk_emp_mig
              VALUES (0, v_ncarga, 5, v_mig_trm.mig_pk);
      ELSIF faraggi.cestpag = 0   --RECHAZADO
                               THEN
         vtraza := 380;
         v_mig_tmp.mig_pk := v_mig_sin.mig_pk || '/MOVPAG/' || 1 || vseq;
         v_mig_tmp.nmovpag := 1;
         v_mig_tmp.cestpag := 8;   --Anulado
         v_mig_tmp.cestval := 0;   --Pendiente de validar

         INSERT INTO mig_sin_tramita_movpago
              VALUES v_mig_tmp
           RETURNING ROWID
                INTO v_rowid;

         INSERT INTO mig_pk_emp_mig
              VALUES (0, v_ncarga, 10, v_mig_tmp.mig_pk);

         vtraza := 390;
         v_mig_trm.mig_pk := v_mig_sin.mig_pk || '/TM/' || 1;
         v_mig_trm.nmovtra := 1;
         v_mig_trm.cesttra := 3;   --Rechazado
         v_mig_trm.ccauest := f_buscavalor('FARAGGI_CAUSA_RECHAZO', faraggi.crechaz);
         v_mig_trm.csubtra := 0;
         v_mig_trm.festtra := v_mig_sin.fnotifi;

         INSERT INTO mig_sin_tramita_movimiento
              VALUES v_mig_trm
           RETURNING ROWID
                INTO v_rowid;

         INSERT INTO mig_pk_emp_mig
              VALUES (0, v_ncarga, 5, v_mig_tmp.mig_pk);
      END IF;

      vtraza := 400;
      v_mig_smv.mig_pk := v_mig_sin.mig_pk || '/SM/' || 1;
      v_mig_smv.mig_fk := v_mig_sin.mig_pk;
      v_mig_smv.nmovsin := 1;   --Movimiento segun el estado de la tramitacion
      v_mig_smv.cestsin := v_mig_trm.cesttra;
      v_mig_smv.festsin := v_mig_sin.fnotifi;   --v_mig_sin.fsinies;

      INSERT INTO mig_sin_movsiniestro
           VALUES v_mig_smv
        RETURNING ROWID
             INTO v_rowid;

      INSERT INTO mig_pk_emp_mig
           VALUES (0, v_ncarga, 6, v_mig_tmp.mig_pk);

      vtraza := 500;

-------------------- FINAL ---------------------
      UPDATE carga_cab_faraggi
         SET scarga = v_ncarga
       WHERE sproces = faraggi.sproces
         AND sdenunc = faraggi.sdenunc
         AND sfaragi = faraggi.sfaragi;

      UPDATE carga_det_faraggi
         SET scarga = v_ncarga
       WHERE sproces = faraggi.sproces
         AND sfaragi = faraggi.sfaragi;

      COMMIT;

      IF b_warning THEN
         cerror := -2;
      END IF;

      RETURN cerror;
   EXCEPTION
      WHEN errdatos THEN
         ROLLBACK;
         pac_cargas_faraggi.p_genera_logs(vobj, vtraza, 'Error ' || cerror, verror,
                                          faraggi.sproces,
                                          'Error ' || cerror || ' ' || verror);
         pterror := verror;
         RETURN cerror;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_cargas_faraggi.p_genera_logs(vobj, vtraza, 'ERROR ' || SQLCODE, SQLERRM,
                                          faraggi.sproces,
                                          'Error ' || SQLCODE || ' ' || SQLERRM);
         cerror := SQLCODE;
         pterror := SQLERRM;
         RETURN cerror;
   END f_altasiniestro_mig;

/*************************************************************************
                   procedimiento que genera movimientos recibo
          param in x : registro tipo int_recibos_ASEFA
          param p_deserror out: Descripción del error si existe.
          Devuelve TIPOERROR ( 1-Ha habido error, 2-Es un warning, 4-Ha ido bien, x-Error incontrolado).
          --
          Para modificar una póliza, los siguientes campos son obligatorios:
          - póliza cia
          - fecha efecto (se toma como fecha operacion).
          - estado recibo.
          --
      *************************************************************************/
   FUNCTION f_modi_siniestro(x IN OUT carga_cab_faraggi%ROWTYPE, p_deserror IN OUT VARCHAR2)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'pac_cargas_faraggi.F_MODI_SINIESTRO';
      vtraza         NUMBER;
      cerror         NUMBER;
      errdatos       EXCEPTION;
      mismoestado    EXCEPTION;
      n_sin          sin_siniestro.nsinies%TYPE;
      v_cesttranou   sin_tramita_movimiento.cesttra%TYPE;
      v_cesttraant   sin_tramita_movimiento.cesttra%TYPE;
      v_nmovtra      sin_tramita_movimiento.nmovtra%TYPE;
      v_cunitra      sin_tramita_movimiento.cunitra%TYPE;
      v_ctramit      sin_tramita_movimiento.ctramitad%TYPE;
      v_nmovsin      sin_movsiniestro.nmovsin%TYPE;
      v_fsinies      DATE;
      n_aux          NUMBER;
      b_warning      BOOLEAN;
      v_deswarning   VARCHAR2(1000);
      v_sseguro      seguros.sseguro%TYPE;
      vnmovsin       sin_movsiniestro.nmovsin%TYPE;
      vnmovtra       sin_tramita_movimiento.nmovtra%TYPE;
      vsbenefi       sin_tramita_destinatario.sperson%TYPE;
      vcgarant       sin_tramita_reserva.cgarant%TYPE;
      vireserva      sin_tramita_reserva.ireserva%TYPE;
      vipago         sin_tramita_reserva.ipago%TYPE;
      vifranq        sin_tramita_reserva.ifranq%TYPE;
      vicaprie       sin_tramita_reserva.icaprie%TYPE;
      vipenali       sin_tramita_reserva.ipenali%TYPE;
      viingreso      sin_tramita_reserva.iingreso%TYPE;
      virecobro      sin_tramita_reserva.irecobro%TYPE;
      vcmovres       sin_tramita_reserva.cmovres%TYPE;
      vnmovres       sin_tramita_reserva.nmovres%TYPE;
      vsidepag       sin_tramita_pago.sidepag%TYPE;
      vcmonres       sin_tramita_reserva.cmonres%TYPE;
      vnmovpag       sin_tramita_movpago.nmovpag%TYPE;
      vcestpag       sin_tramita_movpago.cestpag%TYPE;
      vaccion        NUMBER;
   BEGIN
      vtraza := 1000;
      cerror := 0;
      p_deserror := NULL;
      b_warning := FALSE;
      v_deswarning := NULL;
---------------------------------------------------------
-- VALIDAR CAMPOS CLAVE: Recibo cia.                   --
---------------------------------------------------------
      vtraza := 1010;

      IF LTRIM(x.sfrgrel) IS NULL THEN
         p_deserror := 'Número Siniestro cia sin informar';
         cerror := 101731;
         RAISE errdatos;
      END IF;

      vtraza := 1015;
      cerror := pac_siniestros.f_get_unitradefecte(k_empresaaxis, v_cunitra, v_ctramit);

      IF cerror <> 0 THEN
         p_deserror := 'Error recuperando los tramitadores para la empresa : '
                       || k_empresaaxis;
         RAISE errdatos;
      END IF;

      vtraza := 1020;

      /*  SELECT nsinies
          INTO n_sin
          FROM sin_siniestro si
         WHERE si.nsincia = TO_CHAR(x.csincia);*/
      BEGIN
         SELECT nsinies
           INTO n_sin
           FROM sin_siniestro_referencias
          WHERE srefext = x.sfrgrel
            AND ctipref = 7;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 9907232;
      END;

      vtraza := 1025;

      SELECT nsinies, SIN.sseguro
        INTO n_sin, v_sseguro
        FROM sin_siniestro SIN, seguros seg
       WHERE SIN.nsinies = n_sin
         AND seg.sseguro = SIN.sseguro;

      vtraza := 1030;

      IF v_sseguro IS NULL THEN
         p_deserror := 'Número Siniestro cia no existe: ' || x.sfrgrel;
         cerror := 101731;
         RAISE errdatos;
      END IF;

      vtraza := 1035;

      IF v_sseguro <> x.sseguro THEN
         RETURN 9907234;
      END IF;

      vtraza := 1040;

      IF x.cestpag = 8   --anulado
                      THEN
         RETURN 9907235;
      ELSIF x.cestpag = 0   --rechazado
            OR x.cestpag = 1   --cerrado
                            THEN
         cerror := pac_siniestros.f_get_unitradefecte(k_empresaaxis, v_cunitra, v_ctramit);

         IF cerror <> 0 THEN
            p_deserror := 'Error recuperando los tramitadores para la empresa : '
                          || k_empresaaxis;
            RAISE errdatos;
         END IF;

         vtraza := 1045;
         --Se reabre el siniestro
         cerror := pac_siniestros.f_ins_movsiniestro(n_sin,   -- pnsinies
                                                     4,   -- pestsin
                                                     f_sysdate,   -- pfestsin
                                                     1,   --pccauest
                                                     v_cunitra,   -- pcunitra
                                                     v_ctramit,   --pctramitad
                                                     vnmovsin   -- pnmovsin
                                                             );

         IF cerror <> NULL THEN
            p_deserror := 'Error : ' || cerror;
            RAISE errdatos;
         END IF;

         vtraza := 1050;
         cerror := pac_siniestros.f_ins_tramita_movimiento(n_sin,   -- pnsinies
                                                           0,   -- pntramit
                                                           v_cunitra,   -- pcunitra
                                                           v_ctramit,   -- pctramitad
                                                           4,   -- pcesttra
                                                           NULL,   -- pcsubtra
                                                           f_sysdate,   -- pfesttra
                                                           vnmovtra,   -- pnmovtra
                                                           1,   -- pccauest
                                                           NULL   -- pcvalida_ult
                                                               );

         IF cerror <> NULL THEN
            p_deserror := 'Error : ' || cerror;
            RAISE errdatos;
         END IF;

         vtraza := 1055;
      END IF;

      vtraza := 1060;

      BEGIN
         SELECT sperson
           INTO vsbenefi
           FROM sin_tramita_destinatario
          WHERE nsinies = n_sin
            AND sperson = x.sbenefi;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN   --Si el destinatario no existe, lo damos de alta
            vtraza := 1065;
            cerror :=
               pac_siniestros.f_ins_destinatario
                                       (n_sin,   -- pnsinies
                                        0,   -- pntramit
                                        x.sbenefi,   -- psperson
                                        x.cbanco,   -- pcbancar
                                        x.ctipban,   -- pctipban
                                        100,   -- ppasigna
                                        NULL,   --   pcpaisre
                                        f_buscavalor('FARAGGI_TIPO_DESTINATARIO', x.ctippag),   -- pctipdes
                                        1,   -- pcpagdes
                                        NULL   -- pcactpro
                                            );

            IF cerror <> NULL THEN
               p_deserror := 'Error : ' || cerror;
               RAISE errdatos;
            END IF;

            vtraza := 1070;
      END;

      vtraza := 1075;

      FOR gar IN (SELECT   cgarant, tcobert, SUM(ipago) ipago, SUM(ifranqu) ifranqu
                      FROM carga_det_faraggi
                     WHERE sfaragi = x.sfaragi
                       AND sproces = x.sproces
                  GROUP BY cgarant, tcobert) LOOP
         vtraza := 1080;

         BEGIN
            SELECT cgarant, NVL(ireserva, 0), NVL(ipago, 0), NVL(ifranq, 0), NVL(icaprie, 0),
                   NVL(ipenali, 0), NVL(iingreso, 0), NVL(irecobro, 0)
              INTO vcgarant, vireserva, vipago, vifranq, vicaprie,
                   vipenali, viingreso, virecobro
              FROM sin_tramita_reserva
             WHERE nsinies = n_sin
               AND cgarant = gar.cgarant
               AND ctipres = 1
               AND nmovres = (SELECT MAX(nmovres)
                                FROM sin_tramita_reserva
                               WHERE cgarant = gar.cgarant
                                 AND nsinies = n_sin
                                 AND ctipres = 1);

            vcmovres := 2;
            vtraza := 1085;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               vcmovres := 1;
               vtraza := 1090;
         END;

         vnmovres := NULL;
         cerror := pac_siniestros.f_ins_reserva(n_sin,   -- pnsinies
                                                0,   -- pntramit
                                                1,   -- pctipres INDEMNIZATORIA
                                                gar.cgarant,   -- pcgarant
                                                1,   -- pccalres
                                                f_sysdate,   -- pfmovres
                                                'CLP',   -- pcmonres = 'CLP'
                                                vireserva + gar.ipago,   -- pireserva
                                                vipago,   -- pipago
                                                vicaprie + gar.ipago,   --picaprie
                                                0,   -- pipenali
                                                0,   -- piingreso
                                                0,   -- pirecobro
                                                NULL,   -- pfresini
                                                NULL,   -- pfresfin
                                                NULL,   -- pfultpag
                                                NULL,   -- psidepag
                                                NULL,   -- piprerec
                                                NULL,   -- pctipgas
                                                vnmovres,   -- pnmovres
                                                vcmovres,   -- pcmovres
                                                vifranq + gar.ifranqu,   -- pifranq
                                                NULL,   -- pndias
                                                NULL,   -- pitotimp
                                                NULL,   -- pitotret
                                                NULL,   -- piva_ctipind
                                                NULL,   -- pretenc_ctipind
                                                NULL,   -- preteiva_ctipind
                                                NULL,   -- preteica_ctipind
                                                0   --pcalcfranq
                                                 );

         IF cerror <> NULL THEN
            p_deserror := 'Error : ' || cerror;
            RAISE errdatos;
         END IF;

         vtraza := 1095;
         cerror :=
            pac_siniestros.f_ins_pago(vsidepag,   -- psidepag,
                                      n_sin,   -- pnsinies,
                                      0,   -- pntramit,
                                      x.sbenefi,   -- sperson,
                                      f_buscavalor('FARAGGI_TIPO_DESTINATARIO', x.ctippag),   -- pctipdes
                                      1,   -- ctippag
                                      1,   -- cconpag
                                      0,   -- ccauind,
                                      f_buscavalor('FARAGGI_FORMAS_PAGO', x.cforpag),   -- cforpag,
                                      f_sysdate,   -- fordpag,
                                      x.ctipban,   -- ctipban,
                                      x.cbancar,   -- cbancar,
                                      gar.ipago,   -- isinret,
                                      0,   -- iretenc,
                                      0,   -- iiva
                                      0,   -- isuplid
                                      gar.ifranqu,   -- ifranq
                                      0,   -- iresrcm
                                      0,   -- iresred
                                      NULL,   -- nfacref
                                      NULL,   -- ffacref
                                      1,   -- sidepagtemp  -- Obtener nuevo sidepag
                                      0,   -- cultpag
                                      NULL,   -- ncheque
                                      0,   -- ireteiva
                                      0,   -- ireteica
                                      0,   -- ireteivapag
                                      0,   -- ireteicapag
                                      0,   -- iica
                                      0,   -- iicapag
                                      'CLP'   -- pcmonres
                                           );

         IF cerror <> NULL THEN
            p_deserror := 'Error : ' || cerror;
            RAISE errdatos;
         END IF;

         vtraza := 1100;
         vnmovpag := 0;
         cerror := pac_siniestros.f_ins_movpago(vsidepag, 0,   --pendiente
                                                f_sysdate, 0, TRUNC(f_sysdate), NULL, 0,
                                                vnmovpag, 0, 0);

         IF cerror <> NULL THEN
            p_deserror := 'Error : ' || cerror;
            RAISE errdatos;
         END IF;

         vtraza := 1105;
         vnmovres := NULL;
         --Reducir reserva
         cerror := pac_siniestros.f_ins_reserva(n_sin,   -- pnsinies
                                                0,   -- pntramit
                                                1,   -- pctipres INDEMNIZATORIA
                                                gar.cgarant,   -- pcgarant
                                                1,   -- pccalres
                                                f_sysdate,   -- pfmovres
                                                'CLP',   -- pcmonres = 'CLP'
                                                vireserva - gar.ipago,   -- pireserva
                                                vipago + gar.ipago,   -- pipago
                                                vicaprie,   --picaprie
                                                vipenali,   -- pipenali
                                                viingreso,   -- piingreso
                                                virecobro,   -- pirecobro
                                                NULL,   -- pfresini
                                                NULL,   -- pfresfin
                                                NULL,   -- pfultpag
                                                vsidepag,   -- psidepag
                                                NULL,   -- piprerec
                                                NULL,   -- pctipgas
                                                vnmovres,   -- pnmovres
                                                4,   -- pcmovres
                                                vifranq,   -- pifranq
                                                NULL,   -- pndias
                                                NULL,   -- pitotimp
                                                NULL,   -- pitotret
                                                NULL,   -- piva_ctipind
                                                NULL,   -- pretenc_ctipind
                                                NULL,   -- preteiva_ctipind
                                                NULL,   -- preteica_ctipind
                                                0   --pcalcfranq
                                                 );

         IF cerror <> NULL THEN
            p_deserror := 'Error : ' || cerror;
            RAISE errdatos;
         END IF;

         vtraza := 1110;
--          SELECT MAX(nmovres)
--          INTO   vnmovres
--          FROM   sin_tramita_reserva
--          WHERE  nsinies = n_sin
--          AND    cgarant = gar.cgarant
--          AND    ctipres = 1;
         cerror :=
            pac_siniestros.f_ins_pago_gar
                       (n_sin, 0, vsidepag, 1, vnmovres - 1,   -- nmovres (Correspondiente al movimiento de reserva previo)
                        gar.cgarant, NULL, NULL, vcmonres, gar.ipago,   --isinret
                        NULL,   --iiva
                        NULL,   --isuplid,
                        NULL,   --iretenc,
                        NULL,   --ifranq,
                        NULL,   --iresrcm,
                        NULL,   --iresred,
                        NULL,   --pretenc,
                        NULL,   --piva,
                        'CLP',   --pcmonpag
                        gar.ipago,   --isinretpag,
                        NULL,   --iivapag,
                        NULL,   --isuplidpag,
                        NULL,   --iretencpag,
                        gar.ifranqu,   --ifranqpag,
                        f_sysdate,   --fcambio,
                        NULL,   --pcconpag
                        NULL,   --vnorden,
                        NULL,   --27062014
                        NULL,   --preteiva,
                        NULL,   --preteica,
                        NULL,   --ireteiva,
                        NULL,   --ireteica,
                        NULL,   --ireteivapag,
                        NULL,   --ireteicapag,
                        NULL,   --pica,
                        NULL,   --iica,
                        NULL   --iicapag
                            );

         IF cerror <> NULL THEN
            p_deserror := 'Error : ' || cerror;
            RAISE errdatos;
         END IF;

         vtraza := 1110;
         vnmovpag := vnmovpag + 1;
         cerror := pac_siniestros.f_ins_movpago(vsidepag, 1,   -- cestpag
                                                f_sysdate,   -- fefepag
                                                1,   -- cestval
                                                TRUNC(f_sysdate),   -- fcontab
                                                NULL,   -- sproces
                                                0,   -- cestpagant
                                                vnmovpag, 0,   -- csubpag
                                                0);   -- csubpagant

         IF cerror <> NULL THEN
            p_deserror := 'Error : ' || cerror;
            RAISE errdatos;
         END IF;

         vtraza := 1120;

         IF x.cestpag = 1   -- pagado
                         THEN
            vcestpag := 2;
            vaccion := 2;
         ELSIF x.cestpag = 8
               OR   -- anulado
                 x.cestpag = 0   --rechazado
                              THEN
            vcestpag := 8;
            vaccion := 3;
         END IF;

         vnmovpag := vnmovpag + 1;
         cerror := pac_siniestros.f_ins_movpago(vsidepag, vcestpag,   -- cestpag
                                                f_sysdate,   -- fefepag
                                                1,   -- cestval
                                                TRUNC(f_sysdate),   -- fcontab
                                                NULL,   -- sproces
                                                0,   -- cestpagant
                                                vnmovpag, 1,   -- csubpag
                                                1);

         IF cerror <> NULL THEN
            p_deserror := 'Error : ' || cerror;
            RAISE errdatos;
         END IF;

         vtraza := 1125;
      END LOOP;

      --Finalmente según el estado del pago (faraggi.cestpag) realizaremos el cierre del siniestro o rechazo.
      cerror := pac_siniestros.f_accion_siniestro(n_sin, vaccion);

      IF cerror <> NULL THEN
         p_deserror := 'Error : ' || cerror;
         RAISE errdatos;
      END IF;

      vtraza := 1126;

---------------------------------------------------------
-- CONTROL FINAL                                       --
---------------------------------------------------------
      IF b_warning THEN
         cerror := -2;
      END IF;

      RETURN cerror;
   EXCEPTION
      WHEN errdatos THEN
         ROLLBACK;
         pac_cargas_faraggi.p_genera_logs(vobj, vtraza, 'Error ' || cerror, cerror, x.sproces,
                                          'Error ' || cerror || ' ' || cerror);
         p_deserror := cerror;
         RETURN cerror;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_cargas_faraggi.p_genera_logs(vobj, vtraza, 'ERROR ' || SQLCODE, SQLERRM,
                                          x.sproces, 'Error ' || SQLCODE || ' ' || SQLERRM);
         cerror := SQLCODE;
         p_deserror := SQLERRM;
         RETURN cerror;
   END f_modi_siniestro;

   /*************************************************************************
       Función que da de alta recibo en las SEG
          param in x : registro tipo carga_cab_faraggi
          return : 1 si ha habido error
                   2 si ha habido warning
                   4 si ha ido bien
      *************************************************************************/
   FUNCTION f_altasiniestro_seg(x IN OUT carga_cab_faraggi%ROWTYPE)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'pac_cargas_faraggi.F_altasiniestro_SEG';
      v_i            BOOLEAN := FALSE;
      vnum_err       NUMBER;
      vnnumlin       NUMBER;
      verrorgrab     EXCEPTION;
      vtraza         NUMBER := 0;
      vtiperr        NUMBER;
      vnsinies       sin_siniestro.nsinies%TYPE;
      vsrefext       sin_siniestro_referencias.srefext%TYPE;
      vccompani      seguros.ccompani%TYPE;
      vsseguro       seguros.sseguro%TYPE;
      v_tipooper     VARCHAR2(10);
   BEGIN
      vtraza := 100;
      pac_mig_axis.p_migra_cargas(x.sfaragi, 'C', x.scarga, 'DEL');
      --Cargamos las SEG para la póliza (ncarga)
      vtraza := 110;

      FOR reg IN (SELECT *
                    FROM mig_logs_axis
                   WHERE ncarga = x.scarga
                     AND tipo = 'E') LOOP   --Miramos si ha habido algún error y lo informamos.
         vtraza := 200;
         vnum_err :=
            p_marcalinea
               (x.sproces, x.nlinea, 'ALTA_SIN', 1, 0, NULL,   -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.sfaragi,   -- Fi Bug 14888
                -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                x.scarga, vnsinies, NULL, NULL, NULL,
                x.nlinea || '(' || x.tipo_oper || ')'   -- Fi Bug 16324
                                                     );

         IF vnum_err <> 0 THEN   --Si fallan estas funciones de gestión salimos del programa
            RAISE verrorgrab;
         END IF;

         v_i := TRUE;
         vtraza := 201;
         vnum_err := p_marcalineaerror(x.sproces, x.nlinea, NULL, 1, 1000176,
                                       '(' || vtraza || ')-' || reg.incid);

         IF vnum_err <> 0 THEN   --Si fallan estas funciones de gestión salimos del programa
            RAISE verrorgrab;
         END IF;

         vtiperr := 1;
      END LOOP;

      BEGIN
         SELECT nsinies
           INTO vnsinies
           FROM mig_sin_siniestro
          WHERE ncarga = x.scarga;
      EXCEPTION
         WHEN OTHERS THEN
            NULL;   --JRH IMP de momento
      END;

      IF NOT v_i THEN
         SELECT seg.ccompani, seg.sseguro
           INTO vccompani, vsseguro
           FROM seguros seg, sin_siniestro SIN
          WHERE SIN.nsinies = vnsinies
            AND seg.sseguro = SIN.sseguro;

         UPDATE sin_siniestro
            SET nsincia = TO_CHAR(x.sdenunc),
                ccompani = vccompani
          WHERE nsinies = vnsinies;
      END IF;

      IF NOT v_i THEN
         FOR reg IN (SELECT *
                       FROM mig_logs_axis
                      WHERE ncarga = x.scarga
                        AND tipo = 'W') LOOP   --Miramos si han habido warnings.
            vtraza := 202;
            vnum_err :=
               p_marcalinea
                  (x.sproces, x.nlinea, 'ALTA_SIN', 2, 1, vsseguro,   -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                   x.sfaragi,   -- Fi Bug 14888
                   -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                   x.scarga,   -- Fi Bug 16324
                   vnsinies, NULL, NULL, x.nlinea || '(' || x.tipo_oper || ')');

            IF vnum_err <> 0 THEN   --Si fallan estas funciones de gestión salimos del programa
               RAISE verrorgrab;
            END IF;

            vtraza := 203;
            vnum_err := p_marcalineaerror(x.sproces, x.nlinea, NULL, 2, 700145, reg.incid);

            IF vnum_err <> 0 THEN   --Si fallan estas funciones de gestión salimos del programa
               RAISE verrorgrab;
            END IF;

            v_i := TRUE;
         END LOOP;

         vtiperr := 2;
      END IF;

      IF NOT v_i THEN
         --Esto quiere decir que no ha habido ningún error (lo indicamos también).
         vtraza := 204;
         vnum_err :=
            p_marcalinea
               (x.sproces, x.nlinea, 'ALTA_SIN', 4, 1, vsseguro,   -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.sfaragi,   -- Fi Bug 14888
                -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                x.scarga,   -- Fi Bug 16324
                vnsinies, NULL, NULL, NULL, x.nlinea || '(' || x.tipo_oper || ')');

         IF vnum_err <> 0 THEN   --Si fallan estas funciones de gestión salimos del programa
            RAISE verrorgrab;
         END IF;

         vtiperr := 4;
      END IF;

      RETURN vtiperr;   --Devolvemos el tipo error que ha habido
   EXCEPTION
      WHEN verrorgrab THEN
         RETURN 10;
      WHEN OTHERS THEN
         RETURN 10;
   END f_altasiniestro_seg;

/*************************************************************************
                            procedimiento que ejecuta una carga (parte1 fichero) SINIESTRO
       param in p_nombre   : Nombre fichero
       param in p_path   : Nuombre path
       param out psproces   : Número proceso
       retorna 0 si ha ido bien, 1 en casos contrario
   *************************************************************************/
   FUNCTION f_sin_ejecutarcargafichero(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,   -- BUG16130:DRA:15/10/2010
      psproces OUT NUMBER)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'pac_cargas_faraggi.F_SIN_EJECUTARCARGAFICHERO';
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
      -- BUG16130:DRA:29/09/2010:Inici
      e_errdatos     EXCEPTION;
-- BUG16130:DRA:29/09/2010:Fi
   BEGIN
      vtraza := 0;
      vsinproc := TRUE;
      vnum_err := f_procesini(f_user, k_empresaaxis, 'CARGA_ASEFA_SIN', p_nombre, v_sproces);

      IF vnum_err <> 0 THEN
         RAISE errorini;   --Error que para ejecución
      END IF;

      psproces := v_sproces;
      vtraza := 1;

      -- BUG16130:DRA:29/09/2010:Inici
      IF p_cproces IS NULL THEN
         vnum_err := 9901092;
         vdeserror := 'cfg_files falta proceso: ' || vobj;
         RAISE e_errdatos;
      END IF;

      -- BUG16130:DRA:29/09/2010:Fi
      vtraza := 11;
      vnum_err :=
         pac_gestion_procesos.f_set_carga_ctrl_cabecera(v_sproces, p_nombre, f_sysdate, NULL,
                                                        3, p_cproces,   -- BUG16130:DRA:29/09/2010
                                                        NULL, NULL);
      vtraza := 12;

      IF vnum_err <> 0 THEN   --Si fallan esta funciones de gestión salimos del programa
         p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                     'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera');
         vnum_err := f_proceslin(v_sproces,
                                 f_axis_literales(180856, k_idiomaaaxis) || ':' || p_nombre
                                 || ' : ' || vnum_err,
                                 1, vnnumlin);
         RAISE errorini;   --Error que para ejecución
      END IF;

      COMMIT;
      vtraza := 2;
      f_sin_leefichero(p_nombre, p_path, vdeserror, v_sproces);
      vtraza := 3;

      IF vdeserror IS NOT NULL THEN
         --Si hay un error leyendo el fichero salimos del programa del todo y lo indicamos.
         vtraza := 5;
         vnum_err :=
            pac_gestion_procesos.f_set_carga_ctrl_cabecera
                                                         (v_sproces, p_nombre, f_sysdate,
                                                          NULL, 1, p_cproces,   -- BUG16130:DRA:29/09/2010
                                                          NULL, vdeserror);
         vtraza := 51;

         IF vnum_err <> 0 THEN   --Si fallan esta funciones de gestión salimos del programa
            p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                        'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera2');
            vnnumlin := NULL;
            vnum_err := f_proceslin(v_sproces,
                                    f_axis_literales(180856, k_idiomaaaxis) || ':' || p_nombre
                                    || ' : ' || vnum_err,
                                    1, vnnumlin);
            RAISE errorini;   --Error que para ejecución
         END IF;

         vtraza := 52;
         COMMIT;   --Guardamos la tabla temporal int
         RAISE vsalir;
      ELSE
         vnum_err := pac_gestion_procesos.f_set_carga_fichero(30, p_nombre, 3, f_sysdate);

         IF vnum_err <> 0 THEN   --Si fallan esta funciones de gestión salimos del programa
            v_deserror := 'Error llamando a pac_gestion_procesos.f_set_carga_fichero';
            RAISE errorini;
         END IF;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN vsalir THEN
         NULL;
         RETURN 1;
      WHEN e_errdatos THEN
         ROLLBACK;
         pac_cargas_faraggi.p_genera_logs(vobj, vtraza, 'Error:' || vnum_err, vdeserror,
                                          psproces, 'Error:' || vnum_err || ' ' || vdeserror);
         COMMIT;
         RETURN 1;
      WHEN errorini THEN   --Error al insertar estados
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, vobj, vtraza, 'Error:' || 'ErrorIni' || ' en :' || 1,
                     'Error:' || 'Insertando estados registros');
         vnum_err := f_proceslin(v_sproces,
                                 f_axis_literales(108953, k_idiomaaaxis) || ':' || p_nombre
                                 || ' : ' || 'errorini',
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
                                 f_axis_literales(103187, k_idiomaaaxis) || ':' || p_nombre
                                 || ' : ' || SQLERRM,
                                 1, vnnumlin);
         vnum_err :=
            pac_gestion_procesos.f_set_carga_ctrl_cabecera
                                                         (v_sproces, p_nombre, f_sysdate,
                                                          NULL, 1, p_cproces,   -- BUG16130:DRA:29/09/2010
                                                          151541, SQLERRM);
         vtraza := 51;

         IF vnum_err <> 0 THEN
            --RAISE ErrGrabarProv;
            p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                        'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera2');
            vnnumlin := NULL;
            vnum_err := f_proceslin(v_sproces,
                                    f_axis_literales(180856, k_idiomaaaxis) || ':' || p_nombre
                                    || ' : ' || vnum_err,
                                    1, vnnumlin);
            RAISE errorini;
         END IF;

         COMMIT;
         RETURN 1;
   END f_sin_ejecutarcargafichero;

/*************************************************************************
       procedimiento que realiza validaciones funcionales. SINIESTRO
       param in psproces   : Número proceso
       retorna 0 si ha ido bien, 1 en casos contrario
   *************************************************************************/
   FUNCTION f_sin_validarsiniestro(
      faraggi IN OUT carga_cab_faraggi%ROWTYPE,
      pterror IN OUT VARCHAR2)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(100) := 'pac_cargas_faraggi.F_SIN_EJECUTARCARGA';
      vtraza         NUMBER := 0;
      vnum_err       NUMBER;
      vsalir         EXCEPTION;
      wlinerr        NUMBER := 0;
      vdet_faraggi   carga_det_faraggi%ROWTYPE;
      vsproduc       seguros.sproduc%TYPE;
      vsseguro       seguros.sseguro%TYPE;
      vcbanco        bancos.cbanco%TYPE;
      vctipdes       sin_tramita_destinatario.ctipdes%TYPE;
      vctipban       tipos_cuenta.ctipban%TYPE;
      vcbancar       per_ccc.cbancar%TYPE;
      vsperson_aseg  per_personas.sperson%TYPE;
      vsperson_benef per_personas.sperson%TYPE;
      vcgarant       carga_det_faraggi.cgarant%TYPE;
   BEGIN
      vtraza := 1;

      BEGIN
         SELECT DISTINCT sfaragi
                    INTO vdet_faraggi.sfaragi
                    FROM carga_det_faraggi
                   WHERE sproces = faraggi.sproces
                     AND sfaragi = faraggi.sfaragi;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 9907167;
      END;

      vtraza := 2;

      BEGIN
         SELECT sseguro, sproduc
           INTO vsseguro, vsproduc
           FROM seguros
          WHERE npoliza = faraggi.npoliza
            AND ncertif = faraggi.ncertif;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 9907168;
      END;

      IF TRUNC(faraggi.fsinies) > TRUNC(f_sysdate) THEN
         RETURN 9907220;
      END IF;

      IF TRUNC(faraggi.fnotifi) > TRUNC(f_sysdate) THEN
         RETURN 9907171;
      END IF;

      vtraza := 3;

      BEGIN
         SELECT sperson
           INTO vsperson_aseg
           FROM per_personas
          WHERE nnumide = faraggi.nrutase
            AND ctipide = 41;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 9907169;
         WHEN TOO_MANY_ROWS THEN
            RETURN 9907170;
      END;

      vtraza := 4;

      BEGIN
         SELECT sperson
           INTO vsperson_benef
           FROM per_personas
          WHERE nnumide = faraggi.nrutben
            AND ctipide = 41;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 9907172;
         WHEN TOO_MANY_ROWS THEN
            RETURN 9907173;
      END;

      IF faraggi.cestpag NOT IN(0, 1, 3)   --rechazo, aprobado, pendiente
                                        THEN
         RETURN 9907174;
      END IF;

      IF (faraggi.ccodest = 0   --pendiente liquidacion
          AND faraggi.cestpag <> 3)   --pendiente
         OR(faraggi.ccodest = 1   --liquidada
            AND faraggi.cestpag <> 1)   --aprobado
                                     THEN
         RETURN 9907175;
      END IF;

      IF f_buscavalor('FARAGGI_CAUSAS_RECHAZO', faraggi.crechaz) = NULL THEN
         RETURN 9907176;
      END IF;

      IF faraggi.ctippag NOT IN(0, 1)   --contratante, titular
                                     THEN
         RETURN 9907177;
      END IF;

      vctipdes := f_buscavalor('FARAGGI_TIPO_DESTINATARIO', faraggi.ctippag);

      IF vctipdes = NULL THEN
         RETURN 9907176;
      END IF;

      IF faraggi.cforpag NOT IN(0, 1, 2)   --contratante, titular
                                        THEN
         RETURN 9907178;
      END IF;

      IF faraggi.ctippag = 1   --titular
         AND faraggi.cforpag = 0   --cuenta
                                THEN
         IF faraggi.cbanco IS NULL THEN
            RETURN 9907179;
         END IF;
      END IF;

      vtraza := 5;

      BEGIN
         SELECT cbanco
           INTO vcbanco
           FROM bancos
          WHERE cbanco = faraggi.cbanco;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 9907180;
      END;

      vtraza := 6;
      vcbancar := LPAD(faraggi.cbanco, 3, '0') || '-' || TRIM(faraggi.ccuenta);

      BEGIN
         SELECT ctipban
           INTO vctipban
           FROM tipos_cuenta
          WHERE cbanco IS NULL   -- Cuenta genérica
            AND ctipcc = 1   -- Cuenta corriente
            AND longitud = LENGTH(vcbancar);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 9907181;
      END;

      IF faraggi.cforpag = 0   --cuenta
         AND faraggi.ctippag = 0   --al contratante
                                THEN
         vtraza := 7;

         BEGIN
            SELECT ctipban, cbancar
              INTO vctipban, vcbancar
              FROM per_ccc
             WHERE sperson = vsperson_benef
               AND fbaja IS NULL;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN 9907182;
         END;
      END IF;

      vtraza := 8;

      UPDATE carga_cab_faraggi
         SET sseguro = vsseguro,
             sproduc = vsproduc,
             sperson = vsperson_aseg,
             sbenefi = vsperson_benef,
             ctipdes = vctipdes,
             ctipban = vctipban,
             cbancar = vcbancar
       WHERE sfaragi = faraggi.sfaragi
         AND sproces = faraggi.sproces
         AND sdenunc = faraggi.sdenunc;

      faraggi.sseguro := vsseguro;
      faraggi.sproduc := vsproduc;
      faraggi.sperson := vsperson_aseg;
      faraggi.sbenefi := vsperson_benef;
      faraggi.ctipdes := vctipdes;
      faraggi.ctipban := vctipban;
      faraggi.cbancar := vcbancar;

      FOR x IN (SELECT *
                  FROM carga_det_faraggi d
                 WHERE d.sfaragi = faraggi.sfaragi
                   AND d.sproces = faraggi.sproces) LOOP
         vcgarant := pac_cargas_faraggi.f_buscavalor('FARAGGI_GARANTIAS', x.tcobert);

         IF vcgarant IS NULL THEN
            RETURN 9907225;
         END IF;

         IF x.ifranqu < 0 THEN
            RETURN 9907183;
         END IF;

         IF x.ipago < 0 THEN
            RETURN 9907184;
         END IF;

         vtraza := 9;

         UPDATE carga_det_faraggi
            SET cgarant = vcgarant
          WHERE sfaragi = x.sfaragi
            AND nnumlin = x.nnumlin
            AND sproces = x.sproces;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vtraza, faraggi.sfaragi,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_sin_validarsiniestro;

/*************************************************************************
                   procedimiento que ejecuta una carga (parte2 proceso). SINIESTRO
       param in psproces   : Número proceso
       retorna 0 si ha ido bien, 1 en casos contrario
   *************************************************************************/
   FUNCTION f_sin_ejecutarcargaproceso(psproces IN NUMBER, p_cproces IN NUMBER)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'pac_cargas_faraggi.F_SIN_EJECUTARCARGAPROCESO';

      CURSOR sinmigra(psproces2 IN NUMBER) IS
         SELECT   a.*
             FROM carga_cab_faraggi a   --, carga_det_faraggi d
            WHERE a.sproces = psproces2
              --AND a.sfaragi = d.sfaragi
              AND NOT EXISTS(SELECT 1
                               FROM int_carga_ctrl_linea
                              WHERE int_carga_ctrl_linea.sproces = a.sproces
                                --AND int_carga_ctrl_linea.nlinea = d.nnumlin
                                AND int_carga_ctrl_linea.cestado IN(2, 4, 5))
         --Solo las no procesadas
         ORDER BY nlinea, a.sfaragi;

      vtraza         NUMBER := 0;
      verror         NUMBER;
      vdeserror      VARCHAR2(1000);
      errorini       EXCEPTION;   --Indica error grabando estados.--Error que para ejecución
      vnum_err       NUMBER;
      vsalir         EXCEPTION;
      vnnumlin       NUMBER;
      verrorfin      BOOLEAN := FALSE;
      vavisfin       BOOLEAN := FALSE;
      vtiperr        NUMBER := 0;
      vcoderror      NUMBER;
      n_imp          NUMBER;
      v_deserror     int_carga_ctrl_linea_errs.tmensaje%TYPE;
      v_tfichero     int_carga_ctrl.tfichero%TYPE;
      -- BUG16130:DRA:29/09/2010:Inici
      e_errdatos     EXCEPTION;
      -- BUG16130:DRA:29/09/2010:Fi
      vterror        VARCHAR2(4000);
      vtipo_oper     VARCHAR2(10);
-- Bug 0016324. FAL. 26/10/2010. Añadimos var. desc. error salida init a NULL
   BEGIN
      vtraza := 0;

      IF psproces IS NULL THEN
         vnum_err := 9000505;
         pac_cargas_faraggi.p_genera_logs(vobj, vtraza, 'Error:' || vnum_err,
                                          'Parámetro psproces obligatorio.', psproces,
                                          f_axis_literales(vnum_err, k_idiomaaaxis) || ':'
                                          || v_tfichero || ' : ' || vnum_err);
         RAISE errorini;
      END IF;

      vtraza := 1;

      SELECT tfichero
        INTO v_tfichero
        FROM int_carga_ctrl
       WHERE sproces = psproces;

      vtraza := 2;

      IF v_tfichero IS NULL THEN
         vnum_err := 9901092;
         p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                     'Falta fichero para proceso: ' || psproces);
         vnnumlin := NULL;
         vnum_err := f_proceslin(psproces,
                                 f_axis_literales(vnum_err, k_idiomaaaxis) || ':'
                                 || v_tfichero || ' : ' || vnum_err,
                                 1, vnnumlin);
         RAISE errorini;
      END IF;

      -- BUG16130:DRA:29/09/2010:Inici
      IF p_cproces IS NULL THEN
         vnum_err := 9901092;
         vdeserror := 'cfg_files falta proceso: ' || vobj;
         RAISE e_errdatos;
      END IF;

      -- BUG16130:DRA:29/09/2010:Fi
      vtraza := 4;

      FOR x IN sinmigra(psproces) LOOP
         --Leemos los registros de la tabla int no procesados OK
         -- Bug 0016324. FAL. 18/10/2010
         IF NVL(x.sfrgrel, 0) = 0 THEN
            vtipo_oper := 'ALTA_SIN';
         ELSE
            vtipo_oper := 'MODI_SIN';
         END IF;

         vtraza := 5;

         IF NVL(vtiperr, 0) <> 1 THEN
            -- Fi Bug 0016324
            vtraza := 51;

            IF vtipo_oper = 'ALTA_SIN' THEN   --Si es alta
               vtraza := 6;
               vterror := NULL;
               -- Bug 0016324. FAL. 26/10/2010. Añadimos var. desc. error salida init a NULL
               verror := f_sin_validarsiniestro(x, vterror);

               IF verror <> 0 THEN
                  --Si fallan esta funciones de gestión salimos del programa
                  p_tab_error(f_sysdate, f_user, vobj, vtraza, verror,
                              'Error llamando a pac_cargas_faraggi.f_sin_validarsiniestro');
                  RAISE e_errdatos;   --Error que para ejecución
               END IF;

               verror := f_altasiniestro_mig(x, vterror);

               --Grabamos en las MIG  -- Bug 0016324. FAL. 26/10/2010. Añadimos var. desc. error salida init a NULL
               IF verror IN(0, -2) THEN   --Si ha ido bien o tenemos avisos.
                  IF verror = -2 THEN   -- Avisos.
                     vtraza := 7;
                     vnum_err :=
                        p_marcalinea
                           (psproces, x.nlinea, vtipo_oper, 2, 0, NULL,   -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                            x.sfaragi,   -- Fi Bug 14888
                                         -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                            x.scarga, NULL, NULL, NULL, NULL,
                            x.nlinea || '(' || x.tipo_oper || ')');

                     IF vnum_err <> 0 THEN
                        --Si fallan esta funciones de gestión salimos del programa
                        RAISE errorini;   --Error que para ejecución
                     END IF;

                     verror := 0;
                  END IF;

------------------
                  vtiperr := f_altasiniestro_seg(x);   --Grabamos en las SEG

                  -- Bug 0016324. FAL. 18/10/2010.
                  IF vtiperr NOT IN(0, 4, 2) THEN
                     IF k_para_carga <> 1 THEN
                        vtiperr := 4;   -- para que continue con la siguiente linea.
                     ELSE
                        vtiperr := 1;   -- para la carga
                     END IF;
                  END IF;
               -- Fi Bug 0016324
               ELSE   --Si ha ido mal el paso a las MIG lo indicamos con el error orbtenido
                  -- Bug 0016324. FAL. 18/10/2010
                  vtiperr := 1;
                  -- Fi Bug 0016324
                  vtraza := 70;
                  vnum_err :=
                     p_marcalinea
                        (psproces, x.nlinea, vtipo_oper, 1, 0, NULL,   -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                         x.sfaragi,   -- Fi Bug 14888
                                      -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                         x.scarga, NULL, NULL, NULL, NULL,
                         x.nlinea || '(' || x.tipo_oper || ')');

                  IF vnum_err <> 0 THEN
                     --Si fallan esta funciones de gestión salimos del programa
                     RAISE errorini;   --Error que para ejecución
                  END IF;

                  vtraza := 72;
                  vnum_err := p_marcalineaerror(psproces, x.nlinea, NULL, 1, verror,
                                                NVL(vterror, verror));

                  -- Bug 0016324. FAL. 26/10/2010. Registra la desc. error si informada. en caso contrario el literal verror
                  IF vnum_err <> 0 THEN
                     --Si fallan esta funciones de gestión salimos del programa
                     RAISE errorini;   --Error que para ejecución
                  END IF;

                  verrorfin := TRUE;
                  COMMIT;

                  -- Bug 0016324. FAL. 18/10/2010.
                  IF k_para_carga <> 1 THEN
                     -- Fi Bug 0016324
                     vtiperr := 4;   -- para que continue con la siguiente linea.
                  -- Bug 0016324. FAL. 18/10/2010.
                  END IF;
               -- Fi Bug 0016324
               END IF;
            ELSIF vtipo_oper = 'MODI_SIN' THEN
               vtraza := 80;
               vtiperr := f_modi_siniestro(x, v_deserror);
               vtraza := 82;

               IF vtiperr = 0 THEN
                  vtiperr := 4;
               -- Bug 0016324. FAL. 18/10/2010.
               --ELSE
               --   vtiperr := 2;
               -- Fi Bug 0016324
               END IF;

               -- Bug 0016324. FAL. 18/10/2010.d
               IF vtiperr NOT IN(4, 2) THEN
                  IF k_para_carga <> 1 THEN
                     vtiperr := 4;   -- para que continue con la siguiente linea.
                  ELSE
                     vtiperr := 1;   -- para la carga
                  END IF;
               END IF;
            -- Fi Bug 0016324
            END IF;

            vtraza := 90;

            IF vtiperr = 1 THEN   --Ha habido error
               verrorfin := TRUE;
            ELSIF vtiperr = 2 THEN   -- Es un warning
               vavisfin := TRUE;
            ELSIF vtiperr = 4 THEN   --Ha ido bien.
               NULL;
            ELSE
               RAISE errorini;   --Error que para ejecución(funciones de gestión)
            END IF;

            COMMIT;
         -- Bug 0016324. FAL. 18/10/2010
         ELSIF vtiperr = 1
               AND k_para_carga = 1 THEN
            vtiperr := 1;
            vcoderror := 151541;
            --Actualizamos la cabecera del proceso indicando si ha habido o no algún error o warning en todo el proceso de carga
            vnum_err :=
               pac_gestion_procesos.f_set_carga_ctrl_cabecera
                                                         (psproces, v_tfichero, f_sysdate,
                                                          f_sysdate, vtiperr, p_cproces,   -- BUG16130:DRA:29/09/2010
                                                          vcoderror, NULL);

            IF vnum_err <> 0 THEN   --Si fallan esta funciones de gestión salimos del programa
               p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                           'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera2');
               vnnumlin := NULL;
               vnum_err := f_proceslin(psproces,
                                       f_axis_literales(180856, k_idiomaaaxis) || ':'
                                       || v_tfichero || ' : ' || vnum_err,
                                       1, vnnumlin);
               RAISE errorini;   --Error que para ejecución
            END IF;

            --Bug.:17155
            IF vtiperr IN(4, 2) THEN
               vnum_err := pac_gestion_procesos.f_set_carga_fichero(30, v_tfichero, 2,
                                                                    f_sysdate);

               IF vnum_err <> 0 THEN   --Si fallan esta funciones de gestión salimos del programa
                  p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                              'Error llamando a pac_gestion_procesos.f_set_carga_fichero');
                  vnnumlin := NULL;
                  vnum_err := f_proceslin(psproces,
                                          f_axis_literales(180856, k_idiomaaaxis) || ':'
                                          || v_tfichero || ' : ' || vnum_err,
                                          1, vnnumlin);
                  RAISE errorini;   --Error que para ejecución
               END IF;
            --Fi Bug.: 17155
            END IF;

            COMMIT;
            RETURN 0;
         --RAISE vsalir;
         END IF;
      -- Fi Bug 0016324
      END LOOP;

      vtiperr := 4;
      vcoderror := NULL;

      IF vavisfin THEN
         vtiperr := 2;
         vcoderror := 700145;
      END IF;

      IF verrorfin THEN
         vtiperr := 1;
         vcoderror := 151541;
      END IF;

      --Actualizamos la cabecera del proceso indicando si ha habido o no algún error o warning en todo el proceso de carga
      vnum_err :=
         pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces, v_tfichero, f_sysdate,
                                                        f_sysdate, vtiperr, p_cproces,   -- BUG16130:DRA:29/09/2010
                                                        vcoderror, NULL);
      vtraza := 51;

      IF vnum_err <> 0 THEN   --Si fallan esta funciones de gestión salimos del programa
         p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                     'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera2');
         vnnumlin := NULL;
         vnum_err := f_proceslin(psproces,
                                 f_axis_literales(180856, k_idiomaaaxis) || ':' || v_tfichero
                                 || ' : ' || vnum_err,
                                 1, vnnumlin);
         RAISE errorini;   --Error que para ejecución
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN vsalir THEN
         NULL;
         RETURN 1;
      WHEN e_errdatos THEN
         ROLLBACK;
         pac_cargas_faraggi.p_genera_logs(vobj, vtraza, 'Error:' || vnum_err, vdeserror,
                                          psproces, 'Error:' || vnum_err || ' ' || vdeserror);
         COMMIT;
         RETURN 1;
      WHEN errorini THEN   --Error al insertar estados
         ROLLBACK;
         pac_cargas_faraggi.p_genera_logs(vobj, vtraza,
                                          'Error:' || 'ErrorIni' || ' en :' || vnum_err,
                                          'Error:' || 'Insertando estados registros',
                                          psproces,
                                          f_axis_literales(108953, k_idiomaaaxis) || ':'
                                          || v_tfichero || ' : ' || 'errorini');
         COMMIT;
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         --KO si ha habido algun error en la cabecera
         pac_cargas_faraggi.p_genera_logs(vobj, vtraza, 'Error:' || vnum_err, SQLERRM,
                                          psproces,
                                          f_axis_literales(103187, k_idiomaaaxis) || ':'
                                          || v_tfichero || ' : ' || SQLERRM);
         vnum_err :=
            pac_gestion_procesos.f_set_carga_ctrl_cabecera
                                                         (psproces, v_tfichero, f_sysdate,
                                                          NULL, 1, p_cproces,   -- BUG16130:DRA:29/09/2010
                                                          151541, SQLERRM);

         IF vnum_err <> 0 THEN
            pac_cargas_faraggi.p_genera_logs
                          (vobj, vtraza, vnum_err,
                           'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera2',
                           psproces,
                           f_axis_literales(180856, k_idiomaaaxis) || ':' || v_tfichero
                           || ' : ' || vnum_err);
            RAISE errorini;
         END IF;

         COMMIT;
         RETURN 1;
   END f_sin_ejecutarcargaproceso;

/*************************************************************************
                                                                                       procedimiento que ejecuta una carga SINIESTROS
        param in p_nombre   : Nombre fichero
        param in p_path   : Nuombre path
        param in  out psproces   : Número proceso (informado para recargar proceso).
        retorna 0 si ha ido bien, 1 en casos contrario
    *************************************************************************/
   FUNCTION f_sin_ejecutarcarga(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,   -- BUG16130:DRA:15/10/2010
      psproces IN OUT NUMBER)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'pac_cargas_faraggi.F_SIN_EJECUTARCARGA';
      vtraza         NUMBER := 0;
      vnum_err       NUMBER;
      vsalir         EXCEPTION;
      wlinerr        NUMBER := 0;   -- FAL - 07707/2011 - Bug 0019991
   BEGIN
      vtraza := 0;

      -- Bug 0016324. FAL. 18/10/2010
      SELECT NVL(cpara_error, 0)
        INTO k_para_carga
        FROM cfg_files
       WHERE cempres = k_empresaaxis
         AND cproceso = p_cproces;

      -- Fi Bug 0016324
      IF psproces IS NULL THEN
         vnum_err :=
            pac_cargas_faraggi.f_sin_ejecutarcargafichero
                                                         (p_nombre, p_path, p_cproces,   -- BUG16130:DRA:15/10/2010
                                                          psproces);

         IF vnum_err <> 0 THEN
            RAISE vsalir;
         END IF;
      END IF;

      vtraza := 1;
      vnum_err := pac_cargas_faraggi.f_sin_ejecutarcargaproceso(psproces, p_cproces);

      -- BUG16130:DRA:15/10/2010
      IF vnum_err <> 0 THEN
         RAISE vsalir;
      END IF;

      -- FAL - 07/11/2011 - Bug 0019991: CRT002-Cargas Sicoef: marca el proceso como correcto cuando existen lineas erroneas
      wlinerr := 0;

      SELECT COUNT(DISTINCT nlinea)
        INTO wlinerr
        FROM int_carga_ctrl_linea
       WHERE sproces = psproces
         AND cestado = 1;

      IF wlinerr > 0 THEN
         UPDATE int_carga_ctrl
            SET cestado = 1
          WHERE sproces = psproces;

         COMMIT;
      END IF;

      -- Fi Bug 0019991
      RETURN 0;
   EXCEPTION
      WHEN vsalir THEN
         RETURN 1;
   END f_sin_ejecutarcarga;
END pac_cargas_faraggi;

/

  GRANT EXECUTE ON "AXIS"."PAC_CARGAS_FARAGGI" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CARGAS_FARAGGI" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CARGAS_FARAGGI" TO "PROGRAMADORESCSI";
