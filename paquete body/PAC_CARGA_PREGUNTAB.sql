--------------------------------------------------------
--  DDL for Package Body PAC_CARGA_PREGUNTAB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_CARGA_PREGUNTAB" AS
/*******************************************************************************
   NOMBRE:       pac_carga_preguntab
   PROPÓSITO: Funciones para la carga de preguntas de tipo tabla

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ----------  ------------------------------------
   1.0        13/2/2015   AMC                1. Creación del package.
*******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;
   salir          EXCEPTION;

   /***************************************************************************
        procedimiento que ejecuta una carga
        param in p_nombre   : Nombre fichero
        param in  out psproces   : Número proceso (informado para recargar proceso).
        retorna 0 si ha ido bien, 1 en casos contrario
     **************************************************************************/
   FUNCTION f_ejecutar_carga_preguntab(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      p_sseguro IN NUMBER,
      p_nriesgo IN NUMBER,
      p_cgarant IN NUMBER,
      p_cpregun IN NUMBER,
      p_nmovimi IN NUMBER,
      psproces IN OUT NUMBER)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'PAC_CARGAS_DEDUCIBLE_LCOL.f_ejecutar_carga_preguntab';
      vtraza         NUMBER := 0;
      vnum_err       NUMBER;
      vsalir         EXCEPTION;
      vcjob          NUMBER;
      vpatch         cfg_files.tdestino_bbdd%TYPE;
   BEGIN
      vtraza := 0;

      SELECT NVL(cpara_error, 0), cjob, tdestino_bbdd
        INTO k_para_carga, vcjob, vpatch
        FROM cfg_files
       WHERE cempres = k_empresaaxis
         AND cproceso = 223;

      IF psproces IS NULL
         OR(psproces IS NOT NULL
            AND vcjob = 1) THEN
         vnum_err := f_ejecutar_carga_fichero(p_nombre, vpatch, 223, psproces);

         IF vnum_err <> 0 THEN
            RAISE vsalir;
         END IF;
      END IF;

      vtraza := 1;
      vnum_err := f_ejecutar_carga(psproces, p_cproces, p_sseguro, p_nriesgo, p_cgarant,
                                   p_cpregun, p_nmovimi);
      COMMIT;

      IF vnum_err <> 0 THEN
         RAISE vsalir;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN vsalir THEN
         ROLLBACK;
         RETURN 1;
   END f_ejecutar_carga_preguntab;

   /*************************************************************************
       procedimiento que ejecuta una carga (parte1 fichero)
       param in p_nombre   : Nombre fichero
       param out psproces   : Número proceso
       retorna 0 si ha ido bien, 1 en casos contrario
   *************************************************************************/
   FUNCTION f_ejecutar_carga_fichero(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'f_ejec_carga_fichero';
      linea          NUMBER := 0;
      pcarga         NUMBER;
      sentencia      VARCHAR2(32000);
      vfichero       UTL_FILE.file_type;
      vtraza         NUMBER := 0;
      verror         NUMBER;
      vdeserror      VARCHAR2(1000);
      v_sproces      NUMBER := psproces;
      errorini       EXCEPTION;   --Indica error grabando estados.--Error que para ejecución
      vbloq          EXCEPTION;   --Indica error grabando estados.--Error que para ejecución
      vbloquea       NUMBER;
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
      vtraza := 0;
      vsinproc := TRUE;

      IF psproces IS NULL THEN
         vnum_err := f_procesini(f_user, k_empresaaxis, 'CARGA_PREGUNTAB', p_nombre,
                                 v_sproces);

         IF vnum_err <> 0 THEN
            RAISE errorini;   --Error que para ejecución
         END IF;

         psproces := v_sproces;
      END IF;

      vtraza := 1;

      IF p_cproces IS NULL THEN
         vnum_err := 9901092;
         vdeserror := 'cfg_files falta proceso: ' || vobj;
         RAISE e_errdatos;
      END IF;

      vtraza := 11;
      vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(v_sproces, p_nombre,
                                                                 f_sysdate, NULL, 4, p_cproces,
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

      --COMMIT;
      vtraza := 2;
      vbloquea := bloquea_tablas;

      IF vbloquea <> 0 THEN
         RAISE vbloq;
      END IF;

      --Creamos la tabla a partir del nombre de fichero enviado dinamicamente.
      vnum_err := f_modi_tabla(p_nombre);

      IF vnum_err <> 0 THEN
         p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                     'Error creando la tabla externa');
         vnum_err := f_proceslin(v_sproces,
                                 f_axis_literales(vnum_err, k_idiomaaaxis) || ':' || p_nombre
                                 || ' : ' || vnum_err,
                                 1, vnnumlin);
         RAISE errorini;   --Error que para ejecución
      END IF;

      vtraza := 3;

      IF vdeserror IS NOT NULL THEN
         --Si hay un error leyendo el fichero salimos del programa del todo y lo indicamos.
         vtraza := 5;
         vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(v_sproces, p_nombre,
                                                                    f_sysdate, NULL, 1,
                                                                    p_cproces, NULL,
                                                                    vdeserror);
         vtraza := 51;

         IF vnum_err <> 0 THEN   --Si fallan esta funciones de gestión salimos del programa
            --RAISE ErrGrabarProv;
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
      END IF;

      COMMIT;
      vbloquea := bloquea_tablas;

      IF vbloquea <> 0 THEN
         RAISE vbloq;
      END IF;

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
                                 f_axis_literales(108953, k_idiomaaaxis) || ':' || p_nombre
                                 || ' : ' || 'errorini',
                                 1, vnnumlin);
         COMMIT;
         RETURN 1;
      WHEN vbloq THEN
         p_tab_error(f_sysdate, f_user, vobj, vtraza, 'Error:' || 'ErrorIni' || ' en :' || 1,
                     'AVISO:' || 'Tablas bloqueadas SS' || '--' || SQLCODE || '--' || SQLERRM);
         RETURN 3;
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
   END f_ejecutar_carga_fichero;

    /**********************************************************************
        Función que modifica la tabla ext para cargar un fichero
        param in p_nombre : Nombre fichero
        param in p_path : Nombre Path
        retorna 0 si ha ido bien, sino num_err.
   ***********************************************************************/
   FUNCTION f_modi_tabla(p_nombre VARCHAR2)
      RETURN NUMBER IS
      v_tnomfich     VARCHAR2(100);
      v_tabla        VARCHAR2(100);
   BEGIN
      v_tabla := 'int_preguntab_ext';
      v_tnomfich := SUBSTR(p_nombre, 1, INSTR(p_nombre, '.') - 1);

      --Modificamos los logs
      EXECUTE IMMEDIATE 'alter table ' || v_tabla
                        || ' ACCESS PARAMETERS (records delimited by 0x''0A''
                   logfile '
                        || CHR(39) || v_tnomfich || '.log' || CHR(39)
                        || '
                   badfile ' || CHR(39) || v_tnomfich || '.bad' || CHR(39)
                        || '
                   discardfile ' || CHR(39) || v_tnomfich || '.dis' || CHR(39)
                        || '
                   fields terminated by '';'' lrtrim
                   MISSING FIELD VALUES ARE NULL
                   REJECT ROWS WITH ALL NULL FIELDS
                   (  CCLA1,
                      CCLA2,
                      CCLA3,
                      CCLA4,
                      CCLA5,
                      CCLA6,
                      CCLA7,
                      CCLA8,
                      CCLA9,
                      CCLA10,
                      NVAL1,
                      NVAL2,
                      NVAL3,
                      NVAL4,
                      NVAL5,
                      NVAL6,
                      NVAL7,
                      NVAL8,
                      NVAL9,
                      NVAL10
                  ))';

      --Cargamos el fichero
      EXECUTE IMMEDIATE 'ALTER TABLE ' || v_tabla || ' LOCATION (''' || p_nombre || ''')';

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_md_carga_preguntab.f_modi_tabla', 1,
                     'Error creando la tabla ' || v_tabla, SQLERRM);
         RETURN 107914;
   END f_modi_tabla;

   /*************************************************************************
           procedimiento que ejecuta una carga (parte2 fichero)
           param in p_nombre   : Nombre fichero
           param out psproces   : Número proceso
           retorna 0 si ha ido bien, 1 en casos contrario
       *************************************************************************/
   FUNCTION f_ejecutar_carga(
      psproces IN NUMBER,
      p_cproces IN NUMBER,
      p_sseguro IN NUMBER,
      p_nriesgo IN NUMBER,
      p_cgarant IN NUMBER,
      p_cpregun IN NUMBER,
      p_nmovimi IN NUMBER)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'PAC_CARGA_preguntab.f_ejecutar_carga';
      empresa        VARCHAR2(10) := 12;
      num_err        NUMBER;
      mensajes       t_iax_mensajes;
      nlinea         NUMBER := 0;
      vcolumvalor    NUMBER;
      vnum_err       NUMBER;
      vnumlinea      NUMBER := 0;
      vnorden        NUMBER;
      vcount         NUMBER;

      TYPE t_valores IS TABLE OF VARCHAR2(500)
         INDEX BY VARCHAR2(100);

      vcolumn1       t_valores;
      vcolumn2       t_valores;
      vcolumn3       t_valores;
      vcolumn4       t_valores;
      vcolumn5       t_valores;
      vcolumn6       t_valores;
      vcolumn7       t_valores;
      vcolumn8       t_valores;
      vcolumn9       t_valores;
      vcolumn10      t_valores;
      vcolumn11      t_valores;
      vcolumn12      t_valores;
      vcolumn13      t_valores;
      curid          INTEGER;
      dummy          INTEGER;
      cvalor         VARCHAR2(100);
      tvalor         VARCHAR2(500);
      vidioma        NUMBER;
      vsproduc       NUMBER;
      vselect        VARCHAR2(1000);
      vvalor         VARCHAR2(1000);
      vctipcol       NUMBER;

      CURSOR c_nacional IS
         SELECT *
           FROM int_preguntab_ext;
   BEGIN
      DELETE      estsubtabs_seg_det
            WHERE sseguro = p_sseguro
              AND nriesgo = NVL(p_nriesgo, 1)
              AND cgarant = NVL(p_cgarant, 0)
              AND nmovimi = NVL(p_nmovimi, 1)
              AND cpregun = p_cpregun;

      IF p_cgarant IS NOT NULL
         AND NVL(p_cgarant, 0) <> 0 THEN
         DELETE      estpregungaransegtab
               WHERE sseguro = p_sseguro
                 AND nriesgo = NVL(p_nriesgo, 1)
                 AND cgarant = p_cgarant
                 AND nmovimi = NVL(p_nmovimi, 1)
                 AND cpregun = p_cpregun;
      ELSIF p_nriesgo IS NOT NULL
            AND NVL(p_cgarant, 0) = 0 THEN
         DELETE      estpregunsegtab
               WHERE sseguro = p_sseguro
                 AND nriesgo = NVL(p_nriesgo, 1)
                 AND nmovimi = NVL(p_nmovimi, 1)
                 AND cpregun = p_cpregun;
      ELSE
         DELETE      estpregunpolsegtab
               WHERE sseguro = p_sseguro
                 AND nmovimi = NVL(p_nmovimi, 1)
                 AND cpregun = p_cpregun;
      END IF;

      SELECT NVL(MAX(norden), 0) + 1
        INTO vnorden
        FROM estvalidacargapregtab
       WHERE cpregun = p_cpregun
         AND sseguro = p_sseguro
         AND nmovimi = NVL(p_nmovimi, 1)
         AND nriesgo = NVL(p_nriesgo, 1)
         AND cgarant = NVL(p_cgarant, 0);

      BEGIN
         INSERT INTO estvalidacargapregtab
                     (cpregun, sseguro, nmovimi, nriesgo,
                      cgarant, norden, sproces, cvalida,
                      cusuari, fecha)
              VALUES (p_cpregun, p_sseguro, NVL(p_nmovimi, 1), NVL(p_nriesgo, 1),
                      NVL(p_cgarant, 0), vnorden, psproces, 0,
                      pac_md_common.f_get_cxtusuario(), f_sysdate);
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'f_ejecutar_carga', 4,
                        'psseguro = ' || p_sseguro || ' pnriesgo = ' || p_nriesgo
                        || ' pcgarant = ' || p_cgarant || ' pnmovimi = ' || p_nmovimi
                        || ' p_cpregun = ' || p_cpregun || ' psproces:' || psproces
                        || ' vnorden = ' || vnorden,
                        SQLCODE || ' - ' || SQLERRM);
      END;

      vidioma := pac_md_common.f_get_cxtidioma();
      vsproduc := pac_iax_produccion.vproducto;

      FOR cur IN (SELECT *
                    FROM preguntab_colum
                   WHERE cpregun = p_cpregun) LOOP
         IF cur.ctipcol = 5 THEN
            vselect := cur.tconsulta;
            vselect := REPLACE(vselect, ':PMT_IDIOMA', vidioma);
            vselect := REPLACE(vselect, ':PMT_SPRODUC', vsproduc);
            vselect := REPLACE(vselect, ':PMT_CGARANT', p_cgarant);
            curid := DBMS_SQL.open_cursor;
            DBMS_SQL.parse(curid, vselect, DBMS_SQL.v7);
            dummy := DBMS_SQL.EXECUTE(curid);
            DBMS_SQL.define_column(curid, 1, cvalor, 2000);
            DBMS_SQL.define_column(curid, 2, tvalor, 2000);

            LOOP
               EXIT WHEN DBMS_SQL.fetch_rows(curid) = 0;
               DBMS_SQL.COLUMN_VALUE(curid, 1, cvalor);
               DBMS_SQL.COLUMN_VALUE(curid, 2, tvalor);

               CASE cur.ccolumn
                  WHEN 1 THEN
                     vcolumn1(cvalor) := tvalor;
                  WHEN 2 THEN
                     vcolumn2(cvalor) := tvalor;
                  WHEN 3 THEN
                     vcolumn3(cvalor) := tvalor;
                  WHEN 4 THEN
                     vcolumn4(cvalor) := tvalor;
                  WHEN 5 THEN
                     vcolumn5(cvalor) := tvalor;
                  WHEN 6 THEN
                     vcolumn6(cvalor) := tvalor;
                  WHEN 7 THEN
                     vcolumn7(cvalor) := tvalor;
                  WHEN 8 THEN
                     vcolumn8(cvalor) := tvalor;
                  WHEN 9 THEN
                     vcolumn9(cvalor) := tvalor;
                  WHEN 10 THEN
                     vcolumn10(cvalor) := tvalor;
                  WHEN 11 THEN
                     vcolumn11(cvalor) := tvalor;
                  WHEN 12 THEN
                     vcolumn12(cvalor) := tvalor;
                  WHEN 13 THEN
                     vcolumn13(cvalor) := tvalor;
                  ELSE
                     NULL;
               END CASE;
            END LOOP;

            DBMS_SQL.close_cursor(curid);
         END IF;
      END LOOP;

      FOR regn IN c_nacional LOOP
         BEGIN
            IF regn.ccla1 IS NULL
               OR regn.nval1 IS NULL THEN
               vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces, vnumlinea, 0,
                                                                       vnumlinea, vnumlinea,
                                                                       1, 0, NULL, NULL, NULL,
                                                                       NULL, NULL, NULL, NULL);
               vnum_err :=
                  pac_gestion_procesos.f_set_carga_ctrl_linea_error
                                                                  (psproces, vnumlinea, 1, 1,
                                                                   1,
                                                                   'Falta valores en la linea');
               RAISE salir;
            END IF;

            IF regn.ccla1 IS NOT NULL THEN
               SELECT ctipcol
                 INTO vctipcol
                 FROM preguntab_colum
                WHERE cpregun = p_cpregun
                  AND ccolumn = 1;

               IF vctipcol = 5 THEN
                  BEGIN
                     SELECT vcolumn1(regn.ccla1)
                       INTO vvalor
                       FROM DUAL;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces,
                                                                                vnumlinea, 0,
                                                                                vnumlinea,
                                                                                vnumlinea, 1,
                                                                                0, NULL, NULL,
                                                                                NULL, NULL,
                                                                                NULL, NULL,
                                                                                NULL);
                        vnum_err :=
                           pac_gestion_procesos.f_set_carga_ctrl_linea_error
                                             (psproces, vnumlinea, 1, 1, 1,
                                              'Hay valores que no corresponden a la columna 1');
                        RAISE salir;
                  END;
               END IF;
            END IF;

            IF regn.ccla2 IS NOT NULL THEN
               SELECT ctipcol
                 INTO vctipcol
                 FROM preguntab_colum
                WHERE cpregun = p_cpregun
                  AND ccolumn = 2;

               IF vctipcol = 5 THEN
                  BEGIN
                     SELECT vcolumn2(regn.ccla2)
                       INTO vvalor
                       FROM DUAL;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces,
                                                                                vnumlinea, 0,
                                                                                vnumlinea,
                                                                                vnumlinea, 1,
                                                                                0, NULL, NULL,
                                                                                NULL, NULL,
                                                                                NULL, NULL,
                                                                                NULL);
                        vnum_err :=
                           pac_gestion_procesos.f_set_carga_ctrl_linea_error
                                             (psproces, vnumlinea, 1, 1, 1,
                                              'Hay valores que no corresponden a la columna 2');
                        RAISE salir;
                  END;
               END IF;
            END IF;

            IF regn.ccla3 IS NOT NULL THEN
               SELECT ctipcol
                 INTO vctipcol
                 FROM preguntab_colum
                WHERE cpregun = p_cpregun
                  AND ccolumn = 3;

               IF vctipcol = 5 THEN
                  BEGIN
                     SELECT vcolumn3(regn.ccla3)
                       INTO vvalor
                       FROM DUAL;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces,
                                                                                vnumlinea, 0,
                                                                                vnumlinea,
                                                                                vnumlinea, 1,
                                                                                0, NULL, NULL,
                                                                                NULL, NULL,
                                                                                NULL, NULL,
                                                                                NULL);
                        vnum_err :=
                           pac_gestion_procesos.f_set_carga_ctrl_linea_error
                                             (psproces, vnumlinea, 1, 1, 1,
                                              'Hay valores que no corresponden a la columna 3');
                        RAISE salir;
                  END;
               END IF;
            END IF;

            IF regn.ccla4 IS NOT NULL THEN
               SELECT ctipcol
                 INTO vctipcol
                 FROM preguntab_colum
                WHERE cpregun = p_cpregun
                  AND ccolumn = 4;

               IF vctipcol = 5 THEN
                  BEGIN
                     SELECT vcolumn4(regn.ccla4)
                       INTO vvalor
                       FROM DUAL;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces,
                                                                                vnumlinea, 0,
                                                                                vnumlinea,
                                                                                vnumlinea, 1,
                                                                                0, NULL, NULL,
                                                                                NULL, NULL,
                                                                                NULL, NULL,
                                                                                NULL);
                        vnum_err :=
                           pac_gestion_procesos.f_set_carga_ctrl_linea_error
                                             (psproces, vnumlinea, 1, 1, 1,
                                              'Hay valores que no corresponden a la columna 4');
                        RAISE salir;
                  END;
               END IF;
            END IF;

            IF regn.ccla5 IS NOT NULL THEN
               SELECT ctipcol
                 INTO vctipcol
                 FROM preguntab_colum
                WHERE cpregun = p_cpregun
                  AND ccolumn = 5;

               IF vctipcol = 5 THEN
                  BEGIN
                     SELECT vcolumn5(regn.ccla5)
                       INTO vvalor
                       FROM DUAL;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces,
                                                                                vnumlinea, 0,
                                                                                vnumlinea,
                                                                                vnumlinea, 1,
                                                                                0, NULL, NULL,
                                                                                NULL, NULL,
                                                                                NULL, NULL,
                                                                                NULL);
                        vnum_err :=
                           pac_gestion_procesos.f_set_carga_ctrl_linea_error
                                             (psproces, vnumlinea, 1, 1, 1,
                                              'Hay valores que no corresponden a la columna 5');
                        RAISE salir;
                  END;
               END IF;
            END IF;

            IF regn.ccla6 IS NOT NULL THEN
               SELECT ctipcol
                 INTO vctipcol
                 FROM preguntab_colum
                WHERE cpregun = p_cpregun
                  AND ccolumn = 6;

               IF vctipcol = 5 THEN
                  BEGIN
                     SELECT vcolumn6(regn.ccla6)
                       INTO vvalor
                       FROM DUAL;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces,
                                                                                vnumlinea, 0,
                                                                                vnumlinea,
                                                                                vnumlinea, 1,
                                                                                0, NULL, NULL,
                                                                                NULL, NULL,
                                                                                NULL, NULL,
                                                                                NULL);
                        vnum_err :=
                           pac_gestion_procesos.f_set_carga_ctrl_linea_error
                                             (psproces, vnumlinea, 1, 1, 1,
                                              'Hay valores que no corresponden a la columna 6');
                        RAISE salir;
                  END;
               END IF;
            END IF;

            IF regn.ccla7 IS NOT NULL THEN
               SELECT ctipcol
                 INTO vctipcol
                 FROM preguntab_colum
                WHERE cpregun = p_cpregun
                  AND ccolumn = 7;

               IF vctipcol = 5 THEN
                  BEGIN
                     SELECT vcolumn7(regn.ccla7)
                       INTO vvalor
                       FROM DUAL;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces,
                                                                                vnumlinea, 0,
                                                                                vnumlinea,
                                                                                vnumlinea, 1,
                                                                                0, NULL, NULL,
                                                                                NULL, NULL,
                                                                                NULL, NULL,
                                                                                NULL);
                        vnum_err :=
                           pac_gestion_procesos.f_set_carga_ctrl_linea_error
                                             (psproces, vnumlinea, 1, 1, 1,
                                              'Hay valores que no corresponden a la columna 7');
                        RAISE salir;
                  END;
               END IF;
            END IF;

            IF regn.ccla8 IS NOT NULL THEN
               SELECT ctipcol
                 INTO vctipcol
                 FROM preguntab_colum
                WHERE cpregun = p_cpregun
                  AND ccolumn = 8;

               IF vctipcol = 5 THEN
                  BEGIN
                     SELECT vcolumn8(regn.ccla8)
                       INTO vvalor
                       FROM DUAL;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces,
                                                                                vnumlinea, 0,
                                                                                vnumlinea,
                                                                                vnumlinea, 1,
                                                                                0, NULL, NULL,
                                                                                NULL, NULL,
                                                                                NULL, NULL,
                                                                                NULL);
                        vnum_err :=
                           pac_gestion_procesos.f_set_carga_ctrl_linea_error
                                             (psproces, vnumlinea, 1, 1, 1,
                                              'Hay valores que no corresponden a la columna 8');
                        RAISE salir;
                  END;
               END IF;
            END IF;

            IF regn.ccla9 IS NOT NULL THEN
               SELECT ctipcol
                 INTO vctipcol
                 FROM preguntab_colum
                WHERE cpregun = p_cpregun
                  AND ccolumn = 9;

               IF vctipcol = 5 THEN
                  BEGIN
                     SELECT vcolumn9(regn.ccla9)
                       INTO vvalor
                       FROM DUAL;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces,
                                                                                vnumlinea, 0,
                                                                                vnumlinea,
                                                                                vnumlinea, 1,
                                                                                0, NULL, NULL,
                                                                                NULL, NULL,
                                                                                NULL, NULL,
                                                                                NULL);
                        vnum_err :=
                           pac_gestion_procesos.f_set_carga_ctrl_linea_error
                                             (psproces, vnumlinea, 1, 1, 1,
                                              'Hay valores que no corresponden a la columna 9');
                        RAISE salir;
                  END;
               END IF;
            END IF;

            IF regn.ccla10 IS NOT NULL THEN
               SELECT ctipcol
                 INTO vctipcol
                 FROM preguntab_colum
                WHERE cpregun = p_cpregun
                  AND ccolumn = 10;

               IF vctipcol = 5 THEN
                  BEGIN
                     SELECT vcolumn10(regn.ccla10)
                       INTO vvalor
                       FROM DUAL;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces,
                                                                                vnumlinea, 0,
                                                                                vnumlinea,
                                                                                vnumlinea, 1,
                                                                                0, NULL, NULL,
                                                                                NULL, NULL,
                                                                                NULL, NULL,
                                                                                NULL);
                        vnum_err :=
                           pac_gestion_procesos.f_set_carga_ctrl_linea_error
                                            (psproces, vnumlinea, 1, 1, 1,
                                             'Hay valores que no corresponden a la columna 10');
                        RAISE salir;
                  END;
               END IF;
            END IF;

            IF regn.nval1 IS NOT NULL THEN
               SELECT ctipcol
                 INTO vctipcol
                 FROM preguntab_colum
                WHERE cpregun = p_cpregun
                  AND ccolumn = 11;

               IF vctipcol = 5 THEN
                  BEGIN
                     SELECT vcolumn11(regn.nval1)
                       INTO vvalor
                       FROM DUAL;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces,
                                                                                vnumlinea, 0,
                                                                                vnumlinea,
                                                                                vnumlinea, 1,
                                                                                0, NULL, NULL,
                                                                                NULL, NULL,
                                                                                NULL, NULL,
                                                                                NULL);
                        vnum_err :=
                           pac_gestion_procesos.f_set_carga_ctrl_linea_error
                                               (psproces, vnumlinea, 1, 1, 1,
                                                'Hay valores que no corresponden a la columna');
                        RAISE salir;
                  END;
               END IF;
            END IF;

            IF regn.nval2 IS NOT NULL THEN
               SELECT ctipcol
                 INTO vctipcol
                 FROM preguntab_colum
                WHERE cpregun = p_cpregun
                  AND ccolumn = 12;

               IF vctipcol = 5 THEN
                  BEGIN
                     SELECT vcolumn12(regn.nval2)
                       INTO vvalor
                       FROM DUAL;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces,
                                                                                vnumlinea, 0,
                                                                                vnumlinea,
                                                                                vnumlinea, 1,
                                                                                0, NULL, NULL,
                                                                                NULL, NULL,
                                                                                NULL, NULL,
                                                                                NULL);
                        vnum_err :=
                           pac_gestion_procesos.f_set_carga_ctrl_linea_error
                                               (psproces, vnumlinea, 1, 1, 1,
                                                'Hay valores que no corresponden a la columna');
                        RAISE salir;
                  END;
               END IF;
            END IF;

            IF regn.nval3 IS NOT NULL THEN
               SELECT ctipcol
                 INTO vctipcol
                 FROM preguntab_colum
                WHERE cpregun = p_cpregun
                  AND ccolumn = 13;

               IF vctipcol = 5 THEN
                  BEGIN
                     SELECT vcolumn13(regn.nval3)
                       INTO vvalor
                       FROM DUAL;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces,
                                                                                vnumlinea, 0,
                                                                                vnumlinea,
                                                                                vnumlinea, 1,
                                                                                0, NULL, NULL,
                                                                                NULL, NULL,
                                                                                NULL, NULL,
                                                                                NULL);
                        vnum_err :=
                           pac_gestion_procesos.f_set_carga_ctrl_linea_error
                                               (psproces, vnumlinea, 1, 1, 1,
                                                'Hay valores que no corresponden a la columna');
                        RAISE salir;
                  END;
               END IF;
            END IF;

            BEGIN
               INSERT INTO estsubtabs_seg_det
                           (sseguro, nriesgo, cgarant,
                            nmovimi, cpregun, nlinea, ccla1, ccla2,
                            ccla3, ccla4, ccla5, ccla6, ccla7,
                            ccla8, ccla9, ccla10, nval1, nval2,
                            nval3, nval4, nval5, nval6, nval7,
                            nval8, nval9, nval10)
                    VALUES (p_sseguro, NVL(p_nriesgo, 1), NVL(p_cgarant, 0),
                            NVL(p_nmovimi, 1), p_cpregun, vnumlinea, regn.ccla1, regn.ccla2,
                            regn.ccla3, regn.ccla4, regn.ccla5, regn.ccla6, regn.ccla7,
                            regn.ccla8, regn.ccla9, regn.ccla10, regn.nval1, regn.nval2,
                            regn.nval3, regn.nval4, regn.nval5, regn.nval6, regn.nval7,
                            regn.nval8, regn.nval9, regn.nval10);
            EXCEPTION
               WHEN OTHERS THEN
                  vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces, vnumlinea,
                                                                          0, vnumlinea,
                                                                          vnumlinea, 1, 0,
                                                                          NULL, NULL, NULL,
                                                                          NULL, NULL, NULL,
                                                                          NULL);
                  vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea_error(psproces,
                                                                                vnumlinea, 1,
                                                                                1, 1, SQLERRM);
                  RAISE salir;
            END;

            IF p_cgarant IS NOT NULL
               AND NVL(p_cgarant, 0) <> 0 THEN
               SELECT MAX(TO_NUMBER(ccolumn))
                 INTO vcolumvalor
                 FROM preguntab_colum
                WHERE cpregun = p_cpregun
                  AND cclavevalor = 0;

               FOR cur IN (SELECT   ccolumn
                               FROM preguntab_colum
                              WHERE cpregun = p_cpregun
                                AND cclavevalor = 0
                           ORDER BY TO_NUMBER(ccolumn)) LOOP
                  BEGIN
                     IF cur.ccolumn = 1 THEN
                        INSERT INTO estpregungaransegtab
                                    (sseguro, nriesgo, cpregun, cgarant,
                                     nmovimi, nlinea, nmovima,
                                     finiefe, ccolumna, nvalor)
                             VALUES (p_sseguro, NVL(p_nriesgo, 1), p_cpregun, p_cgarant,
                                     NVL(p_nmovimi, 1), vnumlinea, NVL(p_nmovimi, 1),
                                     f_sysdate, cur.ccolumn, regn.ccla1);
                     ELSIF cur.ccolumn = 2 THEN
                        INSERT INTO estpregungaransegtab
                                    (sseguro, nriesgo, cpregun, cgarant,
                                     nmovimi, nlinea, nmovima,
                                     finiefe, ccolumna, nvalor)
                             VALUES (p_sseguro, NVL(p_nriesgo, 1), p_cpregun, p_cgarant,
                                     NVL(p_nmovimi, 1), vnumlinea, NVL(p_nmovimi, 1),
                                     f_sysdate, cur.ccolumn, regn.ccla2);
                     ELSIF cur.ccolumn = 3 THEN
                        INSERT INTO estpregungaransegtab
                                    (sseguro, nriesgo, cpregun, cgarant,
                                     nmovimi, nlinea, nmovima,
                                     finiefe, ccolumna, nvalor)
                             VALUES (p_sseguro, NVL(p_nriesgo, 1), p_cpregun, p_cgarant,
                                     NVL(p_nmovimi, 1), vnumlinea, NVL(p_nmovimi, 1),
                                     f_sysdate, cur.ccolumn, regn.ccla3);
                     ELSIF cur.ccolumn = 4 THEN
                        INSERT INTO estpregungaransegtab
                                    (sseguro, nriesgo, cpregun, cgarant,
                                     nmovimi, nlinea, nmovima,
                                     finiefe, ccolumna, nvalor)
                             VALUES (p_sseguro, NVL(p_nriesgo, 1), p_cpregun, p_cgarant,
                                     NVL(p_nmovimi, 1), vnumlinea, NVL(p_nmovimi, 1),
                                     f_sysdate, cur.ccolumn, regn.ccla4);
                     ELSIF cur.ccolumn = 5 THEN
                        INSERT INTO estpregungaransegtab
                                    (sseguro, nriesgo, cpregun, cgarant,
                                     nmovimi, nlinea, nmovima,
                                     finiefe, ccolumna, nvalor)
                             VALUES (p_sseguro, NVL(p_nriesgo, 1), p_cpregun, p_cgarant,
                                     NVL(p_nmovimi, 1), vnumlinea, NVL(p_nmovimi, 1),
                                     f_sysdate, cur.ccolumn, regn.ccla5);
                     ELSIF cur.ccolumn = 6 THEN
                        INSERT INTO estpregungaransegtab
                                    (sseguro, nriesgo, cpregun, cgarant,
                                     nmovimi, nlinea, nmovima,
                                     finiefe, ccolumna, nvalor)
                             VALUES (p_sseguro, NVL(p_nriesgo, 1), p_cpregun, p_cgarant,
                                     NVL(p_nmovimi, 1), vnumlinea, NVL(p_nmovimi, 1),
                                     f_sysdate, cur.ccolumn, regn.ccla6);
                     ELSIF cur.ccolumn = 7 THEN
                        INSERT INTO estpregungaransegtab
                                    (sseguro, nriesgo, cpregun, cgarant,
                                     nmovimi, nlinea, nmovima,
                                     finiefe, ccolumna, nvalor)
                             VALUES (p_sseguro, NVL(p_nriesgo, 1), p_cpregun, p_cgarant,
                                     NVL(p_nmovimi, 1), vnumlinea, NVL(p_nmovimi, 1),
                                     f_sysdate, cur.ccolumn, regn.ccla7);
                     ELSIF cur.ccolumn = 8 THEN
                        INSERT INTO estpregungaransegtab
                                    (sseguro, nriesgo, cpregun, cgarant,
                                     nmovimi, nlinea, nmovima,
                                     finiefe, ccolumna, nvalor)
                             VALUES (p_sseguro, NVL(p_nriesgo, 1), p_cpregun, p_cgarant,
                                     NVL(p_nmovimi, 1), vnumlinea, NVL(p_nmovimi, 1),
                                     f_sysdate, cur.ccolumn, regn.ccla8);
                     ELSIF cur.ccolumn = 9 THEN
                        INSERT INTO estpregungaransegtab
                                    (sseguro, nriesgo, cpregun, cgarant,
                                     nmovimi, nlinea, nmovima,
                                     finiefe, ccolumna, nvalor)
                             VALUES (p_sseguro, NVL(p_nriesgo, 1), p_cpregun, p_cgarant,
                                     NVL(p_nmovimi, 1), vnumlinea, NVL(p_nmovimi, 1),
                                     f_sysdate, cur.ccolumn, regn.ccla9);
                     ELSIF cur.ccolumn = 10 THEN
                        INSERT INTO estpregungaransegtab
                                    (sseguro, nriesgo, cpregun, cgarant,
                                     nmovimi, nlinea, nmovima,
                                     finiefe, ccolumna, nvalor)
                             VALUES (p_sseguro, NVL(p_nriesgo, 1), p_cpregun, p_cgarant,
                                     NVL(p_nmovimi, 1), vnumlinea, NVL(p_nmovimi, 1),
                                     f_sysdate, cur.ccolumn, regn.ccla10);
                     END IF;

                     vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces,
                                                                             vnumlinea, 0,
                                                                             vnumlinea,
                                                                             vnumlinea, 4, 1,
                                                                             NULL, NULL, NULL,
                                                                             NULL, NULL, NULL,
                                                                             NULL);
                  EXCEPTION
                     WHEN OTHERS THEN
                        vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces,
                                                                                vnumlinea, 0,
                                                                                vnumlinea,
                                                                                vnumlinea, 1,
                                                                                0, NULL, NULL,
                                                                                NULL, NULL,
                                                                                NULL, NULL,
                                                                                NULL);
                        vnum_err :=
                           pac_gestion_procesos.f_set_carga_ctrl_linea_error(psproces,
                                                                             vnumlinea, 1, 1,
                                                                             1, SQLERRM);
                        RAISE salir;
                  END;
               END LOOP;

               FOR cur IN (SELECT   ccolumn
                               FROM preguntab_colum
                              WHERE cpregun = p_cpregun
                                AND cclavevalor = 1
                           ORDER BY TO_NUMBER(ccolumn)) LOOP
                  BEGIN
                     IF (cur.ccolumn - vcolumvalor) = 1 THEN
                        INSERT INTO estpregungaransegtab
                                    (sseguro, nriesgo, cpregun, cgarant,
                                     nmovimi, nlinea, nmovima,
                                     finiefe, ccolumna, nvalor)
                             VALUES (p_sseguro, NVL(p_nriesgo, 1), p_cpregun, p_cgarant,
                                     NVL(p_nmovimi, 1), vnumlinea, NVL(p_nmovimi, 1),
                                     f_sysdate, cur.ccolumn, regn.nval1);
                     ELSIF(cur.ccolumn - vcolumvalor) = 2 THEN
                        INSERT INTO estpregungaransegtab
                                    (sseguro, nriesgo, cpregun, cgarant,
                                     nmovimi, nlinea, nmovima,
                                     finiefe, ccolumna, nvalor)
                             VALUES (p_sseguro, NVL(p_nriesgo, 1), p_cpregun, p_cgarant,
                                     NVL(p_nmovimi, 1), vnumlinea, NVL(p_nmovimi, 1),
                                     f_sysdate, cur.ccolumn, regn.nval2);
                     ELSIF(cur.ccolumn - vcolumvalor) = 3 THEN
                        INSERT INTO estpregungaransegtab
                                    (sseguro, nriesgo, cpregun, cgarant,
                                     nmovimi, nlinea, nmovima,
                                     finiefe, ccolumna, nvalor)
                             VALUES (p_sseguro, NVL(p_nriesgo, 1), p_cpregun, p_cgarant,
                                     NVL(p_nmovimi, 1), vnumlinea, NVL(p_nmovimi, 1),
                                     f_sysdate, cur.ccolumn, regn.nval3);
                     ELSIF(cur.ccolumn - vcolumvalor) = 4 THEN
                        INSERT INTO estpregungaransegtab
                                    (sseguro, nriesgo, cpregun, cgarant,
                                     nmovimi, nlinea, nmovima,
                                     finiefe, ccolumna, nvalor)
                             VALUES (p_sseguro, NVL(p_nriesgo, 1), p_cpregun, p_cgarant,
                                     NVL(p_nmovimi, 1), vnumlinea, NVL(p_nmovimi, 1),
                                     f_sysdate, cur.ccolumn, regn.nval4);
                     ELSIF(cur.ccolumn - vcolumvalor) = 5 THEN
                        INSERT INTO estpregungaransegtab
                                    (sseguro, nriesgo, cpregun, cgarant,
                                     nmovimi, nlinea, nmovima,
                                     finiefe, ccolumna, nvalor)
                             VALUES (p_sseguro, NVL(p_nriesgo, 1), p_cpregun, p_cgarant,
                                     NVL(p_nmovimi, 1), vnumlinea, NVL(p_nmovimi, 1),
                                     f_sysdate, cur.ccolumn, regn.nval5);
                     ELSIF(cur.ccolumn - vcolumvalor) = 6 THEN
                        INSERT INTO estpregungaransegtab
                                    (sseguro, nriesgo, cpregun, cgarant,
                                     nmovimi, nlinea, nmovima,
                                     finiefe, ccolumna, nvalor)
                             VALUES (p_sseguro, NVL(p_nriesgo, 1), p_cpregun, p_cgarant,
                                     NVL(p_nmovimi, 1), vnumlinea, NVL(p_nmovimi, 1),
                                     f_sysdate, cur.ccolumn, regn.nval6);
                     ELSIF(cur.ccolumn - vcolumvalor) = 7 THEN
                        INSERT INTO estpregungaransegtab
                                    (sseguro, nriesgo, cpregun, cgarant,
                                     nmovimi, nlinea, nmovima,
                                     finiefe, ccolumna, nvalor)
                             VALUES (p_sseguro, NVL(p_nriesgo, 1), p_cpregun, p_cgarant,
                                     NVL(p_nmovimi, 1), vnumlinea, NVL(p_nmovimi, 1),
                                     f_sysdate, cur.ccolumn, regn.nval7);
                     ELSIF(cur.ccolumn - vcolumvalor) = 8 THEN
                        INSERT INTO estpregungaransegtab
                                    (sseguro, nriesgo, cpregun, cgarant,
                                     nmovimi, nlinea, nmovima,
                                     finiefe, ccolumna, nvalor)
                             VALUES (p_sseguro, NVL(p_nriesgo, 1), p_cpregun, p_cgarant,
                                     NVL(p_nmovimi, 1), vnumlinea, NVL(p_nmovimi, 1),
                                     f_sysdate, cur.ccolumn, regn.nval8);
                     ELSIF(cur.ccolumn - vcolumvalor) = 9 THEN
                        INSERT INTO estpregungaransegtab
                                    (sseguro, nriesgo, cpregun, cgarant,
                                     nmovimi, nlinea, nmovima,
                                     finiefe, ccolumna, nvalor)
                             VALUES (p_sseguro, NVL(p_nriesgo, 1), p_cpregun, p_cgarant,
                                     NVL(p_nmovimi, 1), vnumlinea, NVL(p_nmovimi, 1),
                                     f_sysdate, cur.ccolumn, regn.nval9);
                     ELSIF(cur.ccolumn - vcolumvalor) = 10 THEN
                        INSERT INTO estpregungaransegtab
                                    (sseguro, nriesgo, cpregun, cgarant,
                                     nmovimi, nlinea, nmovima,
                                     finiefe, ccolumna, nvalor)
                             VALUES (p_sseguro, NVL(p_nriesgo, 1), p_cpregun, p_cgarant,
                                     NVL(p_nmovimi, 1), vnumlinea, NVL(p_nmovimi, 1),
                                     f_sysdate, cur.ccolumn, regn.nval10);
                     END IF;

                     vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces,
                                                                             vnumlinea, 0,
                                                                             vnumlinea,
                                                                             vnumlinea, 4, 1,
                                                                             NULL, NULL, NULL,
                                                                             NULL, NULL, NULL,
                                                                             NULL);
                  EXCEPTION
                     WHEN OTHERS THEN
                        vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces,
                                                                                vnumlinea, 0,
                                                                                vnumlinea,
                                                                                vnumlinea, 1,
                                                                                0, NULL, NULL,
                                                                                NULL, NULL,
                                                                                NULL, NULL,
                                                                                NULL);
                        vnum_err :=
                           pac_gestion_procesos.f_set_carga_ctrl_linea_error(psproces,
                                                                             vnumlinea, 1, 1,
                                                                             1, SQLERRM);
                        RAISE salir;
                  END;
               END LOOP;

               SELECT MAX(TO_NUMBER(ccolumn))
                 INTO vcolumvalor
                 FROM preguntab_colum
                WHERE cpregun = p_cpregun;

               SELECT COUNT(1)
                 INTO vcount
                 FROM estpregungaransegtab
                WHERE sseguro = p_sseguro
                  AND nriesgo = NVL(p_nriesgo, 1)
                  AND cpregun = p_cpregun
                  AND cgarant = p_cgarant
                  AND nmovimi = NVL(p_nmovimi, 1)
                  AND nlinea = vnumlinea
                  AND nvalor IS NOT NULL;

               IF vcolumvalor <> vcount THEN
                  vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces, vnumlinea,
                                                                          0, vnumlinea,
                                                                          vnumlinea, 1, 0,
                                                                          NULL, NULL, NULL,
                                                                          NULL, NULL, NULL,
                                                                          NULL);
                  vnum_err :=
                     pac_gestion_procesos.f_set_carga_ctrl_linea_error
                                                                 (psproces, vnumlinea, 1, 1,
                                                                  1,
                                                                  'Falta valores por informar');
                  RAISE salir;
               END IF;

               COMMIT;
            ELSIF p_nriesgo IS NOT NULL
                  AND NVL(p_cgarant, 0) = 0 THEN
               SELECT MAX(TO_NUMBER(ccolumn))
                 INTO vcolumvalor
                 FROM preguntab_colum
                WHERE cpregun = p_cpregun
                  AND cclavevalor = 0;

               FOR cur IN (SELECT   ccolumn
                               FROM preguntab_colum
                              WHERE cpregun = p_cpregun
                                AND cclavevalor = 0
                           ORDER BY TO_NUMBER(ccolumn)) LOOP
                  BEGIN
                     IF cur.ccolumn = 1 THEN
                        INSERT INTO estpregunsegtab
                                    (sseguro, nriesgo, cpregun,
                                     nmovimi, nlinea, ccolumna, nvalor)
                             VALUES (p_sseguro, NVL(p_nriesgo, 1), p_cpregun,
                                     NVL(p_nmovimi, 1), vnumlinea, cur.ccolumn, regn.ccla1);
                     ELSIF cur.ccolumn = 2 THEN
                        INSERT INTO estpregunsegtab
                                    (sseguro, nriesgo, cpregun,
                                     nmovimi, nlinea, ccolumna, nvalor)
                             VALUES (p_sseguro, NVL(p_nriesgo, 1), p_cpregun,
                                     NVL(p_nmovimi, 1), vnumlinea, cur.ccolumn, regn.ccla2);
                     ELSIF cur.ccolumn = 3 THEN
                        INSERT INTO estpregunsegtab
                                    (sseguro, nriesgo, cpregun,
                                     nmovimi, nlinea, ccolumna, nvalor)
                             VALUES (p_sseguro, NVL(p_nriesgo, 1), p_cpregun,
                                     NVL(p_nmovimi, 1), vnumlinea, cur.ccolumn, regn.ccla3);
                     ELSIF cur.ccolumn = 4 THEN
                        INSERT INTO estpregunsegtab
                                    (sseguro, nriesgo, cpregun,
                                     nmovimi, nlinea, ccolumna, nvalor)
                             VALUES (p_sseguro, NVL(p_nriesgo, 1), p_cpregun,
                                     NVL(p_nmovimi, 1), vnumlinea, cur.ccolumn, regn.ccla4);
                     ELSIF cur.ccolumn = 5 THEN
                        INSERT INTO estpregunsegtab
                                    (sseguro, nriesgo, cpregun,
                                     nmovimi, nlinea, ccolumna, nvalor)
                             VALUES (p_sseguro, NVL(p_nriesgo, 1), p_cpregun,
                                     NVL(p_nmovimi, 1), vnumlinea, cur.ccolumn, regn.ccla5);
                     ELSIF cur.ccolumn = 6 THEN
                        INSERT INTO estpregunsegtab
                                    (sseguro, nriesgo, cpregun,
                                     nmovimi, nlinea, ccolumna, nvalor)
                             VALUES (p_sseguro, NVL(p_nriesgo, 1), p_cpregun,
                                     NVL(p_nmovimi, 1), vnumlinea, cur.ccolumn, regn.ccla6);
                     ELSIF cur.ccolumn = 7 THEN
                        INSERT INTO estpregunsegtab
                                    (sseguro, nriesgo, cpregun,
                                     nmovimi, nlinea, ccolumna, nvalor)
                             VALUES (p_sseguro, NVL(p_nriesgo, 1), p_cpregun,
                                     NVL(p_nmovimi, 1), vnumlinea, cur.ccolumn, regn.ccla7);
                     ELSIF cur.ccolumn = 8 THEN
                        INSERT INTO estpregunsegtab
                                    (sseguro, nriesgo, cpregun,
                                     nmovimi, nlinea, ccolumna, nvalor)
                             VALUES (p_sseguro, NVL(p_nriesgo, 1), p_cpregun,
                                     NVL(p_nmovimi, 1), vnumlinea, cur.ccolumn, regn.ccla8);
                     ELSIF cur.ccolumn = 9 THEN
                        INSERT INTO estpregunsegtab
                                    (sseguro, nriesgo, cpregun,
                                     nmovimi, nlinea, ccolumna, nvalor)
                             VALUES (p_sseguro, NVL(p_nriesgo, 1), p_cpregun,
                                     NVL(p_nmovimi, 1), vnumlinea, cur.ccolumn, regn.ccla9);
                     ELSIF cur.ccolumn = 10 THEN
                        INSERT INTO estpregunsegtab
                                    (sseguro, nriesgo, cpregun,
                                     nmovimi, nlinea, ccolumna, nvalor)
                             VALUES (p_sseguro, NVL(p_nriesgo, 1), p_cpregun,
                                     NVL(p_nmovimi, 1), vnumlinea, cur.ccolumn, regn.ccla10);
                     END IF;

                     vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces,
                                                                             vnumlinea, 0,
                                                                             vnumlinea,
                                                                             vnumlinea, 4, 1,
                                                                             NULL, NULL, NULL,
                                                                             NULL, NULL, NULL,
                                                                             NULL);
                  EXCEPTION
                     WHEN OTHERS THEN
                        vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces,
                                                                                vnumlinea, 0,
                                                                                vnumlinea,
                                                                                vnumlinea, 1,
                                                                                0, NULL, NULL,
                                                                                NULL, NULL,
                                                                                NULL, NULL,
                                                                                NULL);
                        vnum_err :=
                           pac_gestion_procesos.f_set_carga_ctrl_linea_error(psproces,
                                                                             vnumlinea, 1, 1,
                                                                             1, SQLERRM);
                        RAISE salir;
                  END;
               END LOOP;

               FOR cur IN (SELECT   ccolumn
                               FROM preguntab_colum
                              WHERE cpregun = p_cpregun
                                AND cclavevalor = 1
                           ORDER BY TO_NUMBER(ccolumn)) LOOP
                  BEGIN
                     IF (cur.ccolumn - vcolumvalor) = 1 THEN
                        INSERT INTO estpregunsegtab
                                    (sseguro, nriesgo, cpregun,
                                     nmovimi, nlinea, ccolumna, nvalor)
                             VALUES (p_sseguro, NVL(p_nriesgo, 1), p_cpregun,
                                     NVL(p_nmovimi, 1), vnumlinea, cur.ccolumn, regn.nval1);
                     ELSIF(cur.ccolumn - vcolumvalor) = 2 THEN
                        INSERT INTO estpregunsegtab
                                    (sseguro, nriesgo, cpregun,
                                     nmovimi, nlinea, ccolumna, nvalor)
                             VALUES (p_sseguro, NVL(p_nriesgo, 1), p_cpregun,
                                     NVL(p_nmovimi, 1), vnumlinea, cur.ccolumn, regn.nval2);
                     ELSIF(cur.ccolumn - vcolumvalor) = 3 THEN
                        INSERT INTO estpregunsegtab
                                    (sseguro, nriesgo, cpregun,
                                     nmovimi, nlinea, ccolumna, nvalor)
                             VALUES (p_sseguro, NVL(p_nriesgo, 1), p_cpregun,
                                     NVL(p_nmovimi, 1), vnumlinea, cur.ccolumn, regn.nval3);
                     ELSIF(cur.ccolumn - vcolumvalor) = 4 THEN
                        INSERT INTO estpregunsegtab
                                    (sseguro, nriesgo, cpregun,
                                     nmovimi, nlinea, ccolumna, nvalor)
                             VALUES (p_sseguro, NVL(p_nriesgo, 1), p_cpregun,
                                     NVL(p_nmovimi, 1), vnumlinea, cur.ccolumn, regn.nval4);
                     ELSIF(cur.ccolumn - vcolumvalor) = 5 THEN
                        INSERT INTO estpregunsegtab
                                    (sseguro, nriesgo, cpregun,
                                     nmovimi, nlinea, ccolumna, nvalor)
                             VALUES (p_sseguro, NVL(p_nriesgo, 1), p_cpregun,
                                     NVL(p_nmovimi, 1), vnumlinea, cur.ccolumn, regn.nval5);
                     ELSIF(cur.ccolumn - vcolumvalor) = 6 THEN
                        INSERT INTO estpregunsegtab
                                    (sseguro, nriesgo, cpregun,
                                     nmovimi, nlinea, ccolumna, nvalor)
                             VALUES (p_sseguro, NVL(p_nriesgo, 1), p_cpregun,
                                     NVL(p_nmovimi, 1), vnumlinea, cur.ccolumn, regn.nval6);
                     ELSIF(cur.ccolumn - vcolumvalor) = 7 THEN
                        INSERT INTO estpregunsegtab
                                    (sseguro, nriesgo, cpregun,
                                     nmovimi, nlinea, ccolumna, nvalor)
                             VALUES (p_sseguro, NVL(p_nriesgo, 1), p_cpregun,
                                     NVL(p_nmovimi, 1), vnumlinea, cur.ccolumn, regn.nval7);
                     ELSIF(cur.ccolumn - vcolumvalor) = 8 THEN
                        INSERT INTO estpregunsegtab
                                    (sseguro, nriesgo, cpregun,
                                     nmovimi, nlinea, ccolumna, nvalor)
                             VALUES (p_sseguro, NVL(p_nriesgo, 1), p_cpregun,
                                     NVL(p_nmovimi, 1), vnumlinea, cur.ccolumn, regn.nval8);
                     ELSIF(cur.ccolumn - vcolumvalor) = 9 THEN
                        INSERT INTO estpregunsegtab
                                    (sseguro, nriesgo, cpregun,
                                     nmovimi, nlinea, ccolumna, nvalor)
                             VALUES (p_sseguro, NVL(p_nriesgo, 1), p_cpregun,
                                     NVL(p_nmovimi, 1), vnumlinea, cur.ccolumn, regn.nval9);
                     ELSIF(cur.ccolumn - vcolumvalor) = 10 THEN
                        INSERT INTO estpregunsegtab
                                    (sseguro, nriesgo, cpregun,
                                     nmovimi, nlinea, ccolumna, nvalor)
                             VALUES (p_sseguro, NVL(p_nriesgo, 1), p_cpregun,
                                     NVL(p_nmovimi, 1), vnumlinea, cur.ccolumn, regn.nval10);
                     END IF;

                     vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces,
                                                                             vnumlinea, 0,
                                                                             vnumlinea,
                                                                             vnumlinea, 4, 1,
                                                                             NULL, NULL, NULL,
                                                                             NULL, NULL, NULL,
                                                                             NULL);
                  EXCEPTION
                     WHEN OTHERS THEN
                        vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces,
                                                                                vnumlinea, 0,
                                                                                vnumlinea,
                                                                                vnumlinea, 1,
                                                                                0, NULL, NULL,
                                                                                NULL, NULL,
                                                                                NULL, NULL,
                                                                                NULL);
                        vnum_err :=
                           pac_gestion_procesos.f_set_carga_ctrl_linea_error(psproces,
                                                                             vnumlinea, 1, 1,
                                                                             1, SQLERRM);
                        RAISE salir;
                  END;
               END LOOP;

               SELECT MAX(TO_NUMBER(ccolumn))
                 INTO vcolumvalor
                 FROM preguntab_colum
                WHERE cpregun = p_cpregun;

               SELECT COUNT(1)
                 INTO vcount
                 FROM estpregunsegtab
                WHERE sseguro = p_sseguro
                  AND nriesgo = NVL(p_nriesgo, 1)
                  AND cpregun = p_cpregun
                  AND nmovimi = NVL(p_nmovimi, 1)
                  AND nlinea = vnumlinea
                  AND nvalor IS NOT NULL;

               IF vcolumvalor <> vcount THEN
                  vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces, vnumlinea,
                                                                          0, vnumlinea,
                                                                          vnumlinea, 1, 0,
                                                                          NULL, NULL, NULL,
                                                                          NULL, NULL, NULL,
                                                                          NULL);
                  vnum_err :=
                     pac_gestion_procesos.f_set_carga_ctrl_linea_error
                                                                 (psproces, vnumlinea, 1, 1,
                                                                  1,
                                                                  'Falta valores por informar');
                  RAISE salir;
               END IF;

               COMMIT;
            ELSE
               SELECT MAX(TO_NUMBER(ccolumn))
                 INTO vcolumvalor
                 FROM preguntab_colum
                WHERE cpregun = p_cpregun
                  AND cclavevalor = 0;

               BEGIN
                  FOR cur IN (SELECT   ccolumn
                                  FROM preguntab_colum
                                 WHERE cpregun = p_cpregun
                                   AND cclavevalor = 0
                              ORDER BY TO_NUMBER(ccolumn)) LOOP
                     BEGIN
                        IF cur.ccolumn = 1 THEN
                           INSERT INTO estpregunpolsegtab
                                       (sseguro, cpregun, nmovimi, nlinea,
                                        ccolumna, nvalor)
                                VALUES (p_sseguro, p_cpregun, NVL(p_nmovimi, 1), vnumlinea,
                                        cur.ccolumn, regn.ccla1);
                        ELSIF cur.ccolumn = 2 THEN
                           INSERT INTO estpregunpolsegtab
                                       (sseguro, cpregun, nmovimi, nlinea,
                                        ccolumna, nvalor)
                                VALUES (p_sseguro, p_cpregun, NVL(p_nmovimi, 1), vnumlinea,
                                        cur.ccolumn, regn.ccla2);
                        ELSIF cur.ccolumn = 3 THEN
                           INSERT INTO estpregunpolsegtab
                                       (sseguro, cpregun, nmovimi, nlinea,
                                        ccolumna, nvalor)
                                VALUES (p_sseguro, p_cpregun, NVL(p_nmovimi, 1), vnumlinea,
                                        cur.ccolumn, regn.ccla3);
                        ELSIF cur.ccolumn = 4 THEN
                           INSERT INTO estpregunpolsegtab
                                       (sseguro, cpregun, nmovimi, nlinea,
                                        ccolumna, nvalor)
                                VALUES (p_sseguro, p_cpregun, NVL(p_nmovimi, 1), vnumlinea,
                                        cur.ccolumn, regn.ccla4);
                        ELSIF cur.ccolumn = 5 THEN
                           INSERT INTO estpregunpolsegtab
                                       (sseguro, cpregun, nmovimi, nlinea,
                                        ccolumna, nvalor)
                                VALUES (p_sseguro, p_cpregun, NVL(p_nmovimi, 1), vnumlinea,
                                        cur.ccolumn, regn.ccla5);
                        ELSIF cur.ccolumn = 6 THEN
                           INSERT INTO estpregunpolsegtab
                                       (sseguro, cpregun, nmovimi, nlinea,
                                        ccolumna, nvalor)
                                VALUES (p_sseguro, p_cpregun, NVL(p_nmovimi, 1), vnumlinea,
                                        cur.ccolumn, regn.ccla6);
                        ELSIF cur.ccolumn = 7 THEN
                           INSERT INTO estpregunpolsegtab
                                       (sseguro, cpregun, nmovimi, nlinea,
                                        ccolumna, nvalor)
                                VALUES (p_sseguro, p_cpregun, NVL(p_nmovimi, 1), vnumlinea,
                                        cur.ccolumn, regn.ccla7);
                        ELSIF cur.ccolumn = 8 THEN
                           INSERT INTO estpregunpolsegtab
                                       (sseguro, cpregun, nmovimi, nlinea,
                                        ccolumna, nvalor)
                                VALUES (p_sseguro, p_cpregun, NVL(p_nmovimi, 1), vnumlinea,
                                        cur.ccolumn, regn.ccla8);
                        ELSIF cur.ccolumn = 9 THEN
                           INSERT INTO estpregunpolsegtab
                                       (sseguro, cpregun, nmovimi, nlinea,
                                        ccolumna, nvalor)
                                VALUES (p_sseguro, p_cpregun, NVL(p_nmovimi, 1), vnumlinea,
                                        cur.ccolumn, regn.ccla9);
                        ELSIF cur.ccolumn = 10 THEN
                           INSERT INTO estpregunpolsegtab
                                       (sseguro, cpregun, nmovimi, nlinea,
                                        ccolumna, nvalor)
                                VALUES (p_sseguro, p_cpregun, NVL(p_nmovimi, 1), vnumlinea,
                                        cur.ccolumn, regn.ccla10);
                        END IF;

                        vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces,
                                                                                vnumlinea, 0,
                                                                                vnumlinea,
                                                                                vnumlinea, 4,
                                                                                1, NULL, NULL,
                                                                                NULL, NULL,
                                                                                NULL, NULL,
                                                                                NULL);
                     EXCEPTION
                        WHEN OTHERS THEN
                           vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces,
                                                                                   vnumlinea,
                                                                                   0,
                                                                                   vnumlinea,
                                                                                   vnumlinea,
                                                                                   1, 0, NULL,
                                                                                   NULL, NULL,
                                                                                   NULL, NULL,
                                                                                   NULL, NULL);
                           vnum_err :=
                              pac_gestion_procesos.f_set_carga_ctrl_linea_error(psproces,
                                                                                vnumlinea, 1,
                                                                                1, 1, SQLERRM);
                           RAISE salir;
                     END;
                  END LOOP;

                  FOR cur IN (SELECT   ccolumn
                                  FROM preguntab_colum
                                 WHERE cpregun = p_cpregun
                                   AND cclavevalor = 1
                              ORDER BY TO_NUMBER(ccolumn)) LOOP
                     BEGIN
                        IF (cur.ccolumn - vcolumvalor) = 1 THEN
                           INSERT INTO estpregunpolsegtab
                                       (sseguro, cpregun, nmovimi, nlinea,
                                        ccolumna, nvalor)
                                VALUES (p_sseguro, p_cpregun, NVL(p_nmovimi, 1), vnumlinea,
                                        cur.ccolumn, regn.nval1);
                        ELSIF(cur.ccolumn - vcolumvalor) = 2 THEN
                           INSERT INTO estpregunpolsegtab
                                       (sseguro, cpregun, nmovimi, nlinea,
                                        ccolumna, nvalor)
                                VALUES (p_sseguro, p_cpregun, NVL(p_nmovimi, 1), vnumlinea,
                                        cur.ccolumn, regn.nval2);
                        ELSIF(cur.ccolumn - vcolumvalor) = 3 THEN
                           INSERT INTO estpregunpolsegtab
                                       (sseguro, cpregun, nmovimi, nlinea,
                                        ccolumna, nvalor)
                                VALUES (p_sseguro, p_cpregun, NVL(p_nmovimi, 1), vnumlinea,
                                        cur.ccolumn, regn.nval3);
                        ELSIF(cur.ccolumn - vcolumvalor) = 4 THEN
                           INSERT INTO estpregunpolsegtab
                                       (sseguro, cpregun, nmovimi, nlinea,
                                        ccolumna, nvalor)
                                VALUES (p_sseguro, p_cpregun, NVL(p_nmovimi, 1), vnumlinea,
                                        cur.ccolumn, regn.nval4);
                        ELSIF(cur.ccolumn - vcolumvalor) = 5 THEN
                           INSERT INTO estpregunpolsegtab
                                       (sseguro, cpregun, nmovimi, nlinea,
                                        ccolumna, nvalor)
                                VALUES (p_sseguro, p_cpregun, NVL(p_nmovimi, 1), vnumlinea,
                                        cur.ccolumn, regn.nval5);
                        ELSIF(cur.ccolumn - vcolumvalor) = 6 THEN
                           INSERT INTO estpregunpolsegtab
                                       (sseguro, cpregun, nmovimi, nlinea,
                                        ccolumna, nvalor)
                                VALUES (p_sseguro, p_cpregun, NVL(p_nmovimi, 1), vnumlinea,
                                        cur.ccolumn, regn.nval6);
                        ELSIF(cur.ccolumn - vcolumvalor) = 7 THEN
                           INSERT INTO estpregunpolsegtab
                                       (sseguro, cpregun, nmovimi, nlinea,
                                        ccolumna, nvalor)
                                VALUES (p_sseguro, p_cpregun, NVL(p_nmovimi, 1), vnumlinea,
                                        cur.ccolumn, regn.nval7);
                        ELSIF(cur.ccolumn - vcolumvalor) = 8 THEN
                           INSERT INTO estpregunpolsegtab
                                       (sseguro, cpregun, nmovimi, nlinea,
                                        ccolumna, nvalor)
                                VALUES (p_sseguro, p_cpregun, NVL(p_nmovimi, 1), vnumlinea,
                                        cur.ccolumn, regn.nval8);
                        ELSIF(cur.ccolumn - vcolumvalor) = 9 THEN
                           INSERT INTO estpregunpolsegtab
                                       (sseguro, cpregun, nmovimi, nlinea,
                                        ccolumna, nvalor)
                                VALUES (p_sseguro, p_cpregun, NVL(p_nmovimi, 1), vnumlinea,
                                        cur.ccolumn, regn.nval9);
                        ELSIF(cur.ccolumn - vcolumvalor) = 10 THEN
                           INSERT INTO estpregunpolsegtab
                                       (sseguro, cpregun, nmovimi, nlinea,
                                        ccolumna, nvalor)
                                VALUES (p_sseguro, p_cpregun, NVL(p_nmovimi, 1), vnumlinea,
                                        cur.ccolumn, regn.nval10);
                        END IF;

                        vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces,
                                                                                vnumlinea, 0,
                                                                                vnumlinea,
                                                                                vnumlinea, 4,
                                                                                1, NULL, NULL,
                                                                                NULL, NULL,
                                                                                NULL, NULL,
                                                                                NULL);
                     EXCEPTION
                        WHEN OTHERS THEN
                           vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces,
                                                                                   vnumlinea,
                                                                                   0,
                                                                                   vnumlinea,
                                                                                   vnumlinea,
                                                                                   1, 0, NULL,
                                                                                   NULL, NULL,
                                                                                   NULL, NULL,
                                                                                   NULL, NULL);
                           vnum_err :=
                              pac_gestion_procesos.f_set_carga_ctrl_linea_error(psproces,
                                                                                vnumlinea, 1,
                                                                                1, 1, SQLERRM);
                           RAISE salir;
                     END;
                  END LOOP;
               END;

               SELECT MAX(TO_NUMBER(ccolumn))
                 INTO vcolumvalor
                 FROM preguntab_colum
                WHERE cpregun = p_cpregun;

               SELECT COUNT(1)
                 INTO vcount
                 FROM estpregunpolsegtab
                WHERE sseguro = p_sseguro
                  AND cpregun = p_cpregun
                  AND nmovimi = NVL(p_nmovimi, 1)
                  AND nlinea = vnumlinea
                  AND nvalor IS NOT NULL;

               IF vcolumvalor <> vcount THEN
                  vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces, vnumlinea,
                                                                          0, vnumlinea,
                                                                          vnumlinea, 1, 0,
                                                                          NULL, NULL, NULL,
                                                                          NULL, NULL, NULL,
                                                                          NULL);
                  vnum_err :=
                     pac_gestion_procesos.f_set_carga_ctrl_linea_error
                                                                 (psproces, vnumlinea, 1, 1,
                                                                  1,
                                                                  'Falta valores por informar');
                  RAISE salir;
               END IF;

               COMMIT;
            END IF;
         EXCEPTION
            WHEN salir THEN
               ROLLBACK;

               UPDATE estvalidacargapregtab
                  SET cvalida = 1
                WHERE cpregun = p_cpregun
                  AND sseguro = p_sseguro
                  AND nmovimi = NVL(p_nmovimi, 1)
                  AND nriesgo = NVL(p_nriesgo, 1)
                  AND cgarant = NVL(p_cgarant, 0)
                  AND sproces = psproces;

               COMMIT;
         END;

         vnumlinea := vnumlinea + 1;
      END LOOP;

      RETURN 0;
   END f_ejecutar_carga;

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

   FUNCTION bloquea_tablas
      RETURN NUMBER IS
      mensajes       t_iax_mensajes;
   BEGIN
      LOCK TABLE int_preguntab_ext IN EXCLUSIVE MODE NOWAIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_carga_preguntab.bloque_tablas', 1,
                     'Error tabla bloqueada SS.', SQLCODE || '--' || SQLERRM);
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 9903637);
         RETURN 1;
   END bloquea_tablas;

   FUNCTION f_borrar_carga(
      psseguro IN NUMBER,
      pcpregun IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      pnmovimi IN NUMBER,
      pcnivel IN VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      DELETE      estsubtabs_seg_det
            WHERE sseguro = psseguro
              AND nriesgo = NVL(pnriesgo, 1)
              AND cgarant = NVL(pcgarant, 0)
              AND nmovimi = NVL(pnmovimi, 1)
              AND cpregun = pcpregun;

      IF pcnivel = 'P' THEN
         DELETE      estpregunpolsegtab
               WHERE sseguro = psseguro
                 AND cpregun = pcpregun
                 AND nmovimi = NVL(pnmovimi, 1);
      ELSIF pcnivel = 'R' THEN
         DELETE      estpregunsegtab
               WHERE sseguro = psseguro
                 AND nriesgo = NVL(pnriesgo, 1)
                 AND cpregun = pcpregun
                 AND nmovimi = NVL(pnmovimi, 1);
      ELSIF pcnivel = 'G' THEN
         DELETE      estpregungaransegtab
               WHERE sseguro = psseguro
                 AND nriesgo = NVL(pnriesgo, 1)
                 AND cpregun = pcpregun
                 AND nmovimi = NVL(pnmovimi, 1)
                 AND cgarant = NVL(pcgarant, 0);
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_carga_preguntab.f_borrar_carga', 1,
                     'Error al borrar la carga.', SQLCODE || '--' || SQLERRM);
         RETURN 1;
   END f_borrar_carga;

   FUNCTION f_validar_carga(
      psproces IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      pcpregun IN NUMBER,
      pnmovimi IN NUMBER,
      pmensaje IN OUT NUMBER)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'PAC_CARGA_preguntab.f_validar_carga';
      vparam         VARCHAR2(1000)
         := 'psproces:' || psproces || ' psseguro:' || psseguro || ' pnriesgo:' || pnriesgo
            || ' pcgarant:' || pcgarant || ' pcpregun:' || pcpregun || ' pnmovimi:'
            || pnmovimi;
      vnum_err       NUMBER;
      vcount         NUMBER;
      vnorden        NUMBER;
   BEGIN
      IF psproces IS NULL THEN
         pmensaje := 9907581;
         RETURN 0;
      END IF;

      SELECT COUNT(1)
        INTO vcount
        FROM estvalidacargapregtab
       WHERE cpregun = pcpregun
         AND sseguro = psseguro
         AND nmovimi = NVL(pnmovimi, 1)
         AND nriesgo = NVL(pnriesgo, 1)
         AND cgarant = NVL(pcgarant, 0)
         AND sproces = psproces
         AND cvalida = 1;

      IF vcount = 0 THEN
         pmensaje := 9907582;
         RETURN 0;
      ELSIF vcount >= 1 THEN
         SELECT NVL(MAX(norden), 0) + 1
           INTO vnorden
           FROM estvalidacargapregtab
          WHERE cpregun = pcpregun
            AND sseguro = psseguro
            AND nmovimi = NVL(pnmovimi, 1)
            AND nriesgo = NVL(pnriesgo, 1)
            AND cgarant = NVL(pcgarant, 0);

         BEGIN
            INSERT INTO estvalidacargapregtab
                        (cpregun, sseguro, nmovimi, nriesgo,
                         cgarant, norden, sproces, cvalida,
                         cusuari, fecha)
                 VALUES (pcpregun, psseguro, NVL(pnmovimi, 1), NVL(pnriesgo, 1),
                         NVL(pcgarant, 0), vnorden, psproces, 0,
                         pac_md_common.f_get_cxtusuario(), f_sysdate);
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'f_ejecutar_carga', 4,
                           'psseguro = ' || psseguro || ' pnriesgo = ' || pnriesgo
                           || ' pcgarant = ' || pcgarant || ' pnmovimi = ' || pnmovimi
                           || ' pcpregun = ' || pcpregun || ' psproces:' || psproces
                           || ' vnorden = ' || vnorden,
                           SQLCODE || ' - ' || SQLERRM);
         END;

         COMMIT;
         pmensaje := 9907583;
         RETURN 0;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_carga_preguntab.f_borrar_carga', 1,
                     'Error al validar la carga.vparam' || vparam, SQLCODE || '--' || SQLERRM);
         RETURN 1;
   END f_validar_carga;

   FUNCTION f_cargas_validadas(
      psseguro IN NUMBER,
      pemitir IN OUT NUMBER,
      pmensaje IN OUT VARCHAR2)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'PAC_CARGA_preguntab.f_cargas_validadas';
      vparam         VARCHAR2(1000) := 'psseguro:' || psseguro;
      vnum_err       NUMBER;
      vcount         NUMBER;
      mensaje        VARCHAR2(1000);
   BEGIN
      SELECT COUNT(1)
        INTO vcount
        FROM estvalidacargapregtab v
       WHERE sseguro = psseguro
         AND cvalida = 1
         AND norden = (SELECT MAX(norden)
                         FROM estvalidacargapregtab vv
                        WHERE vv.cpregun = v.cpregun
                          AND vv.sseguro = psseguro
                          AND vv.nmovimi = v.nmovimi
                          AND vv.nriesgo = v.nriesgo
                          AND vv.cgarant = v.cgarant);

      IF vcount >= 1 THEN
         FOR cur IN (SELECT cpregun
                       FROM estvalidacargapregtab v
                      WHERE sseguro = psseguro
                        AND cvalida = 1
                        AND norden = (SELECT MAX(norden)
                                        FROM estvalidacargapregtab vv
                                       WHERE vv.cpregun = v.cpregun
                                         AND vv.sseguro = psseguro
                                         AND vv.nmovimi = v.nmovimi
                                         AND vv.nriesgo = v.nriesgo
                                         AND vv.cgarant = v.cgarant)) LOOP
            IF mensaje IS NULL THEN
               mensaje := mensaje || TO_CHAR(cur.cpregun);
            ELSE
               mensaje := mensaje || ',' || TO_CHAR(cur.cpregun);
            END IF;
         END LOOP;

         pemitir := 1;
         pmensaje := f_axis_literales(9907584, pac_md_common.f_get_cxtidioma()) || mensaje;
         RETURN 0;
      END IF;

      pemitir := 0;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_carga_preguntab.f_borrar_carga', 1,
                     'Error al validar la carga.vparam' || vparam, SQLCODE || '--' || SQLERRM);
         RETURN 1;
   END f_cargas_validadas;
END pac_carga_preguntab;

/

  GRANT EXECUTE ON "AXIS"."PAC_CARGA_PREGUNTAB" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CARGA_PREGUNTAB" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CARGA_PREGUNTAB" TO "PROGRAMADORESCSI";
