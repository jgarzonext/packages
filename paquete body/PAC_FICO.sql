--------------------------------------------------------
--  DDL for Package Body PAC_FICO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_FICO" AS
   /******************************************************************************
      NOMBRE:      PAC_FICO
      PROPÓSITO:   Package propio para carga y generación de ficheros FICO de ICEA

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        10/10/2012   XVM              1. 0023945: MDP002-MDP- Implementación de Interfaces

   ******************************************************************************/
   k_cempresa CONSTANT empresas.cempres%TYPE
                      := NVL(pac_md_common.f_get_cxtempresa, f_parinstalacion_n('EMPRESADEF'));
   k_cidioma CONSTANT idiomas.cidioma%TYPE
      := NVL(pac_md_common.f_get_cxtidioma,
             pac_parametros.f_parempresa_n(f_parinstalacion_n('EMPRESADEF'), 'IDIOMA_DEF'));

   /*************************************************************************
       PROCEDURE p_genera_logs: Procedimiento que guarda logs en las diferentes tablas.
       param p_tabobj in : tab_error tobjeto
       param p_tabtra in : tab_error ntraza
       param p_tabdes in : tab_error tdescrip
       param p_taberr in : tab_error terror
       param p_propro in : PROCESOSLIN sproces
       param p_protxt in : PROCESOSLIN tprolin
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
          FUNCTION f_marcalinea: Función que marca linea que tratamos con un estado.
          param pnsproces   in : proceso
          param pnlinea     in : linea
          param pctipo      in : tipo
          param pnestado    in : estado
          param pnvalidado  in : validado
          param pid_ext     in : Id. interno
          RETURN               : 0.-    OK
                                 otro.- error
      *************************************************************************/
   FUNCTION f_marcalinea(
      pnsproces IN NUMBER,
      pnlinea IN NUMBER,
      pctipo IN NUMBER,
      pnestado IN NUMBER,
      pnvalidado IN NUMBER,
      pid_ext IN VARCHAR2)
      RETURN NUMBER IS
      v_tobjeto      VARCHAR2(100) := 'PAC_CARGAS_FICO.f_marcalinea';
      v_nnumerr      NUMBER := 0;
   BEGIN
      v_nnumerr := pac_gestion_procesos.f_set_carga_ctrl_linea(pnsproces, pnlinea, pctipo,
                                                               pnlinea, pid_ext, pnestado,
                                                               pnvalidado, NULL, pid_ext,
                                                               NULL, NULL, NULL, NULL, NULL);

      IF v_nnumerr <> 0 THEN   --Si falla esta funcion de gestión salimos del programa
         p_genera_logs(v_tobjeto, 1, v_nnumerr,
                       'p=' || pnsproces || ' l=' || pnlinea || ' t=' || pctipo || ' EST='
                       || pnestado || ' v=' || pnvalidado || ' CIF=' || pid_ext,
                       pnsproces,
                       'Error ' || v_nnumerr || ' l=' || pnlinea || ' e=' || pnestado
                       || ' CIF=' || pid_ext);
         v_nnumerr := 1;
      END IF;

      RETURN v_nnumerr;
   END f_marcalinea;

   /*************************************************************************
          FUNCTION f_marcalineaerror: Función que marca el error de la linea que tratamos.
          param pssproces in : proceso
          param pnlinea   in : linea
          param pnnumerr  in : numero error
          param pctipo    in : tipo
          param pncodigo  in : codigo
          param ptmensaje in : mensaje
          RETURN             : 0.-    OK
                               otro.- error
      *************************************************************************/
   FUNCTION f_marcalineaerror(
      pssproces IN NUMBER,
      pnlinea IN NUMBER,
      pnnumerr IN NUMBER,
      pctipo IN NUMBER,
      pncodigo IN NUMBER,
      ptmensaje IN VARCHAR2)
      RETURN NUMBER IS
      v_tobjeto      VARCHAR2(100) := 'PAC_CARGAS_FICO.f_marcalineaerror';
      v_nnumerr      NUMBER := 0;
   BEGIN
      v_nnumerr := pac_gestion_procesos.f_set_carga_ctrl_linea_error(pssproces, pnlinea,
                                                                     pnnumerr, pctipo,
                                                                     pncodigo, ptmensaje);

      IF v_nnumerr <> 0 THEN   --Si falla esta funció de gestión salimos del programa
         p_genera_logs(v_tobjeto, 1, v_nnumerr,
                       'p=' || pssproces || ' l=' || pnlinea || ' n=' || pnnumerr || ' t='
                       || pctipo || ' c=' || pncodigo || ' m=' || ptmensaje,
                       pssproces,
                       'Error ' || v_nnumerr || ' l=' || pnlinea || ' c=' || pncodigo);
         v_nnumerr := 1;
      END IF;

      RETURN v_nnumerr;
   END f_marcalineaerror;

     /***********************************************************************
      FUNCTION f_cargar_fico: Función de carga de ficheros FICO de ICEA
      param in  pnombre        : nombre del fichero a leer
      param in  ppath          : path del fichero a leer
      param in  pcproceso      : código del proceso FICO
      param in out psproces    : Id. del proceso
      return                   : 0.-    OK
                                 otro.- error
   ***********************************************************************/
   FUNCTION f_cargar_fico(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproceso IN NUMBER,
      p_sproces IN OUT NUMBER)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'PAC_CARGAS_FICO.F_CARGAR_FICO';
      reglinia       VARCHAR2(1000);
      v_linea        NUMBER(15) := 0;
      pcarga         NUMBER;
      v_existcif     NUMBER(1);
      v_indice       NUMBER(1) := 0;
      vfichero       UTL_FILE.file_type;
      registro       fico%ROWTYPE;
      vtraza         NUMBER;
      vdeserror      VARCHAR2(1000);
      v_sproces      NUMBER;
      errorini       EXCEPTION;
      --Indica error grabando estados.--Error que para ejecución
      vnum_err       NUMBER;
      vnnumlin       NUMBER;
      --Indica si tenemos o no proceso
      v_deserror     int_carga_ctrl_linea_errs.tmensaje%TYPE;
      e_errdatos     EXCEPTION;
      aux_err        NUMBER := 4;
   BEGIN
      vtraza := 0;
       --v_context := f_parinstalacion_t('CONTEXT_USER');
       --v_cempres := pac_contexto.f_contextovalorparametro(v_context, 'IAX_EMPRESA');
      -- v_cempres := f_parinstalacion_n('EMPRESADEF');
      vnum_err := f_procesini(f_user, k_cempresa, 'CARGA_FICO', p_nombre, v_sproces);

      IF vnum_err <> 0 THEN
         RAISE errorini;   --Error que para ejecución
      END IF;

      p_sproces := v_sproces;
      vtraza := 1;

      IF p_cproceso IS NULL THEN
         vnum_err := 9901092;
         vdeserror := 'cfg_files falta proceso: ' || vobj;
         RAISE e_errdatos;
      END IF;

      vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(v_sproces, p_nombre,
                                                                 f_sysdate, NULL, 3,
                                                                 p_cproceso, NULL, NULL);
      vtraza := 2;

      IF vnum_err <> 0 THEN
         p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                     'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera');
         vnum_err := f_proceslin(v_sproces,
                                 f_axis_literales(180856, k_cidioma) || ':' || p_nombre
                                 || ' : ' || vnum_err,
                                 1, vnnumlin);
         RAISE errorini;
      END IF;

      vfichero := UTL_FILE.fopen(p_path, p_nombre, 'r');
      vtraza := 3;

      WHILE v_indice = 0 LOOP
         BEGIN
            UTL_FILE.get_line(vfichero, reglinia);
            reglinia := REPLACE(REPLACE(reglinia, CHR(13), ''), CHR(10), '');

            IF reglinia <> '=' THEN
               v_linea := v_linea + 1;
               vtraza := 4;
               vnum_err := f_marcalinea(v_sproces, v_linea, 5, 1, 0,
                                        TRIM(SUBSTR(reglinia, 32, 9)));

               IF vnum_err <> 0 THEN
                  RAISE e_errdatos;
               END IF;

               IF LENGTH(reglinia) <> 100 THEN
                  vtraza := 5;
                  vnum_err := f_marcalineaerror(p_sproces, v_linea, NULL, 5, 1,
                                                f_axis_literales(9904310, k_cidioma));
                  aux_err := 1;

                  IF vnum_err <> 0 THEN
                     RAISE e_errdatos;
                  END IF;
               ELSE
                  vtraza := 6;
                  registro.proceso := v_sproces;
                  registro.nlinea := v_linea;
                  registro.entidad := SUBSTR(reglinia, 1, 4);
                  registro.estado := SUBSTR(reglinia, 5, 11);
                  registro.poliza := SUBSTR(reglinia, 16, 16);
                  registro.cif := TRIM(SUBSTR(reglinia, 32, 9));
                  registro.fanulacion := TO_DATE(SUBSTR(reglinia, 41, 8), 'ddmmyyyy');
                  registro.anulacion := SUBSTR(reglinia, 49, 2);
                  registro.capital := SUBSTR(reglinia, 51, 5);
                  registro.direccion := TRIM(SUBSTR(reglinia, 56, 45));

                  SELECT COUNT(1)
                    INTO v_existcif
                    FROM fico
                   WHERE cif = registro.cif;

                  IF v_existcif = 0 THEN
                     vtraza := 7;

                     INSERT INTO fico
                          VALUES registro;
                  ELSE
                     IF registro.anulacion IN('A*', 'F*') THEN
                        vtraza := 8;

                        DELETE FROM fico
                              WHERE cif = registro.cif;
                     ELSE
                        vtraza := 9;

                        UPDATE fico
                           SET proceso = v_sproces,
                               nlinea = v_linea,
                               entidad = registro.entidad,
                               estado = registro.estado,
                               poliza = registro.poliza,
                               fanulacion = registro.fanulacion,
                               anulacion = registro.anulacion,
                               capital = registro.capital,
                               direccion = registro.direccion
                         WHERE cif = registro.cif;
                     END IF;
                  END IF;

                  vtraza := 10;
               END IF;

               vnum_err := f_marcalinea(v_sproces, v_linea, 5, 4, 0,
                                        TRIM(SUBSTR(reglinia, 32, 9)));
            ELSE
               v_indice := 1;
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_indice := 1;
            WHEN OTHERS THEN
               vnum_err := f_marcalineaerror(p_sproces, v_linea, NULL, 5, 1,
                                             f_axis_literales(105133, k_cidioma) || v_linea);
               aux_err := 1;

               IF vnum_err <> 0 THEN
                  RAISE e_errdatos;
               END IF;
         END;
      END LOOP;

      vtraza := 11;
      UTL_FILE.fclose(vfichero);
      vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(p_sproces, p_nombre,
                                                                 f_sysdate, f_sysdate, aux_err,
                                                                 p_cproceso, 0, NULL);
      vnum_err := f_procesfin(v_sproces, 0);
      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_errdatos THEN
         ROLLBACK;

         IF UTL_FILE.is_open(vfichero) THEN
            UTL_FILE.fclose(vfichero);
         END IF;

         pac_fico.p_genera_logs(vobj, vtraza, 'Error:' || vnum_err, vdeserror, p_sproces,
                                'Error:' || vnum_err || ' ' || vdeserror);
         vnum_err := f_marcalinea(v_sproces, v_linea, 5, 1, 0, NULL);
         vnum_err := f_marcalineaerror(p_sproces, v_linea, NULL, 5, 1,
                                       'Error:' || vnum_err || ' ' || vdeserror);
         vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(p_sproces, p_nombre,
                                                                    f_sysdate, f_sysdate, 1,
                                                                    p_cproceso, 0, NULL);
         COMMIT;
         RETURN 1;
      WHEN errorini THEN   --Error al insertar estados
         ROLLBACK;

         IF UTL_FILE.is_open(vfichero) THEN
            UTL_FILE.fclose(vfichero);
         END IF;

         -- Bug 0015721 - JMF - 02/09/2010
         p_tab_error(f_sysdate, f_user, vobj, vtraza, 1,
                     f_axis_literales(108953, k_cidioma) || ':' || p_nombre);
         vnum_err := f_proceslin(v_sproces,
                                 f_axis_literales(108953, k_cidioma) || ':' || p_nombre, 1,
                                 vnnumlin);
         vnum_err := f_marcalinea(v_sproces, v_linea, 5, 1, 0, NULL);
         vnum_err := f_marcalineaerror(p_sproces, v_linea, NULL, 5, 1,
                                       'Error:' || vnum_err || ' ' || vdeserror);
         vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(p_sproces, p_nombre,
                                                                    f_sysdate, f_sysdate, 1,
                                                                    p_cproceso, 0, NULL);
         COMMIT;
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;

         IF UTL_FILE.is_open(vfichero) THEN
            UTL_FILE.fclose(vfichero);
         END IF;

         --KO si ha habido algun error en la cabecera
         --coderr := SQLCODE;
         p_tab_error(f_sysdate, f_user, vobj, vtraza, 'Error:' || SQLERRM || ' en :' || 1,
                     'Error:' || SQLERRM);
         vnum_err := f_proceslin(v_sproces,
                                 f_axis_literales(103187, k_cidioma) || ':' || p_nombre
                                 || ' : ' || SQLCODE || '-' || SQLERRM,
                                 1, vnnumlin);
         vnum_err := f_marcalinea(v_sproces, v_linea, 5, 1, 0, NULL);
         vnum_err := f_marcalineaerror(p_sproces, v_linea, NULL, 5, 1,
                                       'Error:' || vnum_err || ' ' || vdeserror);
         vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(p_sproces, p_nombre,
                                                                    f_sysdate, f_sysdate, 1,
                                                                    p_cproceso, 0, NULL);
         vtraza := 12;

         IF vnum_err <> 0 THEN
            --RAISE ErrGrabarProv;
            -- Bug 0015721 - JMF - 02/09/2010
            p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                        f_axis_literales(vnum_err, k_cidioma));
            vnnumlin := NULL;
            vnum_err := f_proceslin(v_sproces,
                                    f_axis_literales(180856, k_cidioma) || ':' || p_nombre
                                    || ' : ' || vnum_err,
                                    1, vnnumlin);
            RAISE errorini;
         END IF;

         COMMIT;
         RETURN 1;
   END f_cargar_fico;

   /******************************************************************************************
     F_DET_FICO1: Función que genera el texto detalle para el listado de FICO
     Paràmetres entrada: - p_cidioma     -> codigo idioma
                         - p_cempres     -> codigo empresa
                         - p_finiefe     -> fecha inicio
                         - p_ffinefe     -> fecha final
     return:             texto detalle
   ******************************************************************************************/
   FUNCTION f_det_fico1(
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_finiefe IN VARCHAR2 DEFAULT NULL,
      p_ffinefe IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2 IS
      v_tobjeto      VARCHAR2(100) := 'PAC_FICO.f_det_fico1';
      v_tparam       VARCHAR2(1000)
         := ' idioma=' || p_cidioma || ' empresa=' || p_cempres || ' fecha ini=' || p_finiefe
            || ' fecha fin=' || p_ffinefe;
      v_ntraza       NUMBER := 0;
      v_finiefe      VARCHAR2(100);
      v_ffinefe      VARCHAR2(100);
      v_text         VARCHAR2(4000);
   BEGIN
      v_ntraza := 1;
      v_text := NULL;
      v_ntraza := 2;
      v_finiefe := LPAD(p_finiefe, 8, '0');
      v_ntraza := 3;
      v_finiefe := 'to_date(' || CHR(39) || v_finiefe || CHR(39) || ',''ddmmyyyy'')';
      v_ntraza := 4;
      v_ffinefe := LPAD(p_ffinefe, 8, '0');
      v_ntraza := 5;
      v_ffinefe := 'to_date(' || CHR(39) || v_ffinefe || CHR(39) || ',''ddmmyyyy'')';
      v_ntraza := 6;
      v_text :=
         'SELECT ''M199'', LPAD(NVL(sit.cpostal,0),5,0)|| RPAD(NVL(substr(tnomvia,length(tnomvia)-3), '' ''),3)
                ||LPAD(NVL(to_char(nnumvia),'' ''),3), RPAD(seg.npoliza,16), LPAD(per.nnumide,9),
                LPAD(NVL(to_char(seg.fanulac,''ddmmyyyy''),'' ''),8), ''A '', LPAD(NVL(TRUNC(g.icapital),0)/1000,5,0), RPAD(NVL(sit.tdomici,'' ''),45)
                FROM seguros seg, movseguro mov,
                     sitriesgo sit, asegurados ase, garanseg g,
                     per_personas per
                WHERE mov.cmotmov = 312
                  AND mov.sseguro = seg.sseguro
                  AND mov.fmovimi >= '
         || v_finiefe || ' AND mov.fmovimi <= ' || v_ffinefe
         || ' AND mov.nmovimi in (SELECT MAX(nmovimi)
                                        FROM movseguro
                                       WHERE sseguro = seg.sseguro
                                         AND cmotmov = 312)
                  AND seg.cramo = 201
                  AND ase.sseguro = seg.sseguro
                  AND sit.sseguro = seg.sseguro
                  AND ase.sperson = per.sperson
                  AND g.sseguro = mov.sseguro
                  AND g.nriesgo = 1
                  AND g.cgarant = 2001
                  AND g.nmovimi IN (SELECT MAX(nmovimi)
                                         FROM garanseg
                                        WHERE sseguro = g.sseguro
                                          AND nriesgo = 1
                                          AND cgarant = 2001
                                          AND nmovimi <=mov.nmovimi)';
      v_ntraza := 7;
      RETURN v_text;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam || ': Error' || SQLCODE,
                     SQLERRM);
         RETURN 1;
   END f_det_fico1;
END pac_fico;

/

  GRANT EXECUTE ON "AXIS"."PAC_FICO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_FICO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_FICO" TO "PROGRAMADORESCSI";
