CREATE OR REPLACE PACKAGE BODY "PAC_CARGAS_CONF" AS
   /*************************************************************************
   NOMBRE:       PAC_CARGAS_CONF
   PROPSITO: Fichero carga masiva de agentes de una campaa
   REVISIONES:
   Ver        Fecha        Autor             Descripcin
   ---------  ----------  ----------  ------------------------------------
   1.0        17/06/2016   AP         1. Creacin del package.
   2.0        18/02/2019   JLTS       2. IAXIS-Se adiciona la variable v_max_nmovimi para no hacer tantas veces la consulta
   3.0        28/02/2019   DFR        3. IAXIS-2418: Fichero carga agentes masiva a campaa
   4.0        08/03/2019   Swapnil    4. Cambios para IAXIS-2015
   5.0        11/03/2019   DFR        5. IAXIS-2016: Scoring
   6.0        13/02/2019   JLTS       6. IAXIS-3070 Se adiciona la variable v_max_nmovimi1 para no hacer tantas veces la consulta
   7.0        23/04/2019   JLTS       7. IAXIS-3673 Se incluyen las validaciones de ecuaciones patrimoniales
   8.0        19/04/2019   Swapnil    8. Cambios de IAXIS-3562 
   9.0        17/04/2019   SGM        9. IAXIS 3482 PODER INGRESAR ACUERDOS DE PAGO, MASIVAMENTE Y TRAZAR  
   10.0       02/07/2019   KK         10. CAMBIOS De IAXIS-4538
   11.0       08/07/2019   Swapnil    11. Cambios de IAXIS-4732
   12.0       08/07/2019   SGM        12. IAXIS-4511 SGM detalles de conciliacion  
   13.0	      19/07/2019   PK         13. Cambio de IAXIS-4844 - Optimizar Petición Servicio I017
   14.0	      19/07/2019   SGM        14. Cambio de IAXIS-4512 historico pendientes conciliacion
   15.0	      19/07/2019   SGM        15. Cambio de IAXIS-4102 saldos a favor del cliente
   16.0       05/09/2019   SGM        16. IAXIS-4511 CONCILIACION DE CARTERA
   17.0       09/09/2019   JLTS       17. IAXIS-5154. Ajute a la funci¿n f_finleco y f_carga_finleco y se comentarizan
                                          las dem¿s que no se utilizan
   18.0       06/11/2019   CJMR       18. IAXIS-4834. Cargue masivo marcas de Grupos Econ¿micos
   19.0       01/17/2020   JRVG       19. Cambio de IAXIS-4945 - bug 7780  Patrimonio Liquido (f_carga_finleco)
   20.0       28/10/2019   CJMR       20. IAXIS-5422. Nota Beneficiario adicional
   21.0       13/02/2020   JLTS       21. IAXIS-5339. Ajuste de la función p_setPersona_Cargar_CIFIN incluyendo el calculo del modelo 
                                          para personas naturales (cupo sugerido y gaanizado)
   22.0       20/02/2020   JRVG       22. IAXIS-7629  Cargue de plantilla VidaGrupo 
   23.0       14/04/2020   JRVG       23. Cambios de IAXIS-5241 
   24.0       15/04/2020   JRVG       24. Cambios de IAXIS-4102
   *************************************************************************/
   /*************************************************************************
            Procedimiento que guarda logs en las diferentes tablas.
      param p_tabobj in : tab_error tobjeto
      param p_tabtra in : tab_error ntraza
      param p_tabdes in : tab_error tdescrip
      param p_taberr in : tab_error terror
      param p_propro in : PROCESOSLIN sproces
      param p_protxt in : PROCESOSLIN tprolin
      devuelve numero o null si existe error.
   *************************************************************************/


   k_cempresa CONSTANT empresas.cempres%TYPE
                      := NVL(pac_md_common.f_get_cxtempresa, f_parinstalacion_n('EMPRESADEF'));
   k_cidioma CONSTANT idiomas.cidioma%TYPE
              := pac_parametros.f_parempresa_n(f_parinstalacion_n('EMPRESADEF'), 'IDIOMA_DEF');
   k_cpara_error  cfg_files.cpara_error%TYPE;
   k_busca_host   cfg_files.cbusca_host%TYPE;
   k_cformato_decimales cfg_files.cformato_decimales%TYPE := 0;   -- Decimales se multiplica el valor * 100. Valor por defecto
   k_cdebug       cfg_files.cdebug%TYPE := 99;   -- por defecto maximo debug
   k_nregmasivo   cfg_files.nregmasivo%TYPE := 1;   --por defecto procedsamos una unica entidad (poliza, recibo, siniestro, persona..)
--   k_sistema_numerico_bd CHAR := f_recupera_separador_decimal;
   --  k_cmotivoanula   motmovseg.cmotmov%TYPE := 324;
   k_tablas       VARCHAR2(3) := 'EST';
   k_iteraciones CONSTANT NUMBER(2) := 10;   -- veces que intento modificar la tabla externa
   k_segundos CONSTANT NUMBER(2) := 10;   -- espera para veces que intento modificar la tabla externa
   k_mascara_date CONSTANT VARCHAR2(12) := 'FXDD/MM/YYYY';
     -- e_errdatos     EXCEPTION;
--   v_tdeserror    int_carga_ctrl_linea_errs.tmensaje%TYPE;
   v_nnumerr      NUMBER;
   v_nnumerr1     NUMBER;
   b_cobro_parcial BOOLEAN := FALSE;


   PROCEDURE p_genera_logs_g(
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
   END p_genera_logs_g;

   /***************************************************************************
      FUNCTION f_next_carga
      Asigna numero de carga
      return :Numero de carga
   ***************************************************************************/
   FUNCTION f_next_carga_g
      RETURN NUMBER IS
      v_seq          NUMBER;
   BEGIN
      SELECT sncarga.NEXTVAL
        INTO v_seq
        FROM DUAL;

      RETURN v_seq;
   END f_next_carga_g;

   FUNCTION f_buscavalor_g(p_cod IN VARCHAR2, p_emp IN VARCHAR2)
      RETURN VARCHAR2 IS
      v_ret          int_codigos_emp.cvalaxis%TYPE;
   BEGIN
      p_control_error('jaab', 'f_buscavalor_g',
                      'kempresa: ' || kempresa || ' - p_cod: ' || p_cod || ' - p_emp: '
                      || p_emp);

      BEGIN
         SELECT cvalaxis
           INTO v_ret
           FROM int_codigos_emp
          WHERE cempres = kempresa
            AND ccodigo = p_cod
            AND cvaldef = p_emp;
      EXCEPTION
         WHEN OTHERS THEN
            SELECT MAX(cvalaxis)
              INTO v_ret
              FROM int_codigos_emp
             WHERE cempres = kempresa
               AND ccodigo = p_cod
               AND cvalemp = p_emp;
      END;

      RETURN v_ret;
   END f_buscavalor_g;

   PROCEDURE p_error_linea_g(
      psproces IN NUMBER,
      psseguro IN NUMBER,
      pnlinea IN NUMBER,
      perror IN VARCHAR2) IS
      vobjectname    VARCHAR2(200) := 'pac_cargas_sian_pos.p_error_linea_g';
      vpas           NUMBER := 0;
      vparam         VARCHAR2(200)
         := 'Parametros :psproces=' || psproces || ':psseguro=' || psseguro || ':pnlinea='
            || pnlinea || ':perror=' || perror;
   BEGIN
      INSERT INTO int_carga_ctrl_linea_errs
                  (sproces, nlinea, nerror, ctipo, cerror, tmensaje, cusuario, fmovimi)
           VALUES (psproces, pnlinea, 1, 1, NULL, perror, f_user, f_sysdate);

      UPDATE int_carga_ctrl_linea
         SET cestado = 1
       WHERE sproces = psproces
         AND nlinea = pnlinea;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpas, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
   END p_error_linea_g;

   PROCEDURE psdwat(tens_of_millisecs BINARY_INTEGER);

   PRAGMA INTERFACE(c, psdwat);

   PROCEDURE sleep(pseconds NUMBER) IS
      arg1           BINARY_INTEGER;
      badseconds_num EXCEPTION;
   BEGIN
      arg1 := pseconds * 100;

      IF arg1 < 0 THEN
         RAISE badseconds_num;
      ELSE
         psdwat(arg1);
      END IF;
   END;

/*************************************************************************
FUNCTION f_campana_ejecutarcarga
*************************************************************************/
   FUNCTION f_campana_ejecutarcarga(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER)
      RETURN NUMBER IS
      vlin           NUMBER;
      vobj           VARCHAR2(200) := 'PAC_CARGAS_CONF.f_campana_ejecutarcarga';
      vpar           VARCHAR2(2000)
         := 'p_nombre=' || p_nombre || 'p_path=' || p_path || ' p_cproces=' || p_cproces
            || 'psproces= ' || psproces;
      vnum_err       NUMBER := 0;
   BEGIN
      vnum_err := pac_cargas_conf.f_campana_ejecutarcargafichero(p_nombre, p_path, p_cproces,
                                                                 psproces);

      --
      IF vnum_err <> 0 THEN
         RAISE e_param_error;
      END IF;

      vlin := 2;
      --
      -- Inicio IAXIS-2418 28/02/2019
      --
      vnum_err := pac_cargas_conf.f_campana_ejecutarproceso(psproces);
      --
      -- Fin IAXIS-2418 28/02/2019
      --
      --
      UPDATE int_carga_ctrl
         SET cestado = vnum_err,
             ffin = f_sysdate
       WHERE sproces = psproces;

      --
      COMMIT;
      --
      RETURN 0;
   --
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobj, vlin, vpar, SQLCODE);
         RETURN 1;
      WHEN e_object_error THEN
         p_tab_error(f_sysdate, f_user, vobj, vlin, vpar, SQLCODE);
         RETURN 1;
      WHEN OTHERS THEN
         DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_backtrace);
         p_tab_error(f_sysdate, f_user, vobj, vlin, vpar, SQLCODE);
         RETURN 1;
   END f_campana_ejecutarcarga;

   /*************************************************************************
   FUNCTION f_campana_ejecutarcargafichero
   *************************************************************************/
   FUNCTION f_campana_ejecutarcargafichero(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces OUT NUMBER)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'pac_cargas_conf.f_campana_ejecutarcargafichero';
      vnum_err       NUMBER := 0;
      v_line         VARCHAR2(32767);
      v_file         UTL_FILE.file_type;
      v_numlineaf    NUMBER := 0; -- IAXIS-2418 28/02/2019
      -- Numero de linea del fichero
      -- Numero de linea del insert
      errorini       EXCEPTION;
      errorcarga     EXCEPTION;
      e_errdatos     EXCEPTION;
      -- Formato Ingls
      v_sep          VARCHAR2(1) := ';';
      v_currfield    VARCHAR2(64);
      v_ccodigo      NUMBER;
      v_cagente      NUMBER;
      v_ctipage      NUMBER;
      v_finicam      DATE;
      v_ffincam      DATE;
      v_imeta        NUMBER;
      vlin           NUMBER;
      -- Inicio IAXIS-2418 28/02/2019
      vncarga        NUMBER := f_next_carga_g;
      v_iproduccion  NUMBER;
      v_irecaudo     NUMBER;
      -- Fin IAXIS-2418 28/02/2019
      vpar           VARCHAR2(2000)
         := 'p_nombre=' || p_nombre || 'p_path=' || p_path || ' p_cproces=' || p_cproces
            || 'psproces= ' || psproces;

      PROCEDURE p_controlar_error(p_traza NUMBER, p_estado NUMBER, v_msg VARCHAR2) IS
      BEGIN
         vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces, p_nombre,
                                                                    f_sysdate, NULL, p_estado,
                                                                    p_cproces, NULL, v_msg);

         IF vnum_err <> 0 THEN
            -- Si fallan esta funciones de gestin salimos del programa
            p_tab_error(f_sysdate, f_user, vobj, p_traza, vnum_err,
                        'Error llamando pac_gestion_procesos.f_set_carga_ctrl_cabecera'
                        || p_traza);
            RAISE errorini;
         END IF;
      END p_controlar_error;
   BEGIN
      SELECT sproces.NEXTVAL
        INTO psproces
        FROM DUAL;

      IF p_cproces IS NULL THEN
         vnum_err := 9901092;
         RAISE e_errdatos;
      END IF;

      p_controlar_error(2, 3, NULL);

      BEGIN
         -- Inicio: Lectura de fichero.
         v_file := UTL_FILE.fopen(p_path, p_nombre, 'R', 256);

         LOOP
            EXIT WHEN v_numlineaf = -1;

            BEGIN
               v_numlineaf := v_numlineaf + 1;
               UTL_FILE.get_line(v_file, v_line, 32767);
               DBMS_OUTPUT.put_line(v_line);

               IF (v_numlineaf > 0) THEN -- IAXIS-2418 28/02/2019
                  -- A partir de la Segona
                  -- Incio IAXIS-2418 28/02/2019
                  v_line := REPLACE(REPLACE(v_line, chr(10), ''), chr(13), '');
                  -- Fin IAXIS-2418 28/02/2019
                  v_currfield := 'CCODIGO';
                  v_ccodigo := pac_util.splitt(v_line, 1, v_sep);
                  v_currfield := 'CAGENTE';
                  v_cagente := pac_util.splitt(v_line, 2, v_sep);
                  v_currfield := 'CTIPAGE';
                  v_ctipage := pac_util.splitt(v_line, 3, v_sep);
                  v_currfield := 'FINICAM';
                  v_finicam := TO_DATE(pac_util.splitt(v_line, 4, v_sep), 'DD/MM/YYYY');
                  v_currfield := 'FFINCAM';
                  v_ffincam := TO_DATE(pac_util.splitt(v_line, 5, v_sep), 'DD/MM/YYYY');
                  v_currfield := 'IMETA';
                  v_imeta := pac_util.splitt(v_line, 6, v_sep);
                  -- Incio IAXIS-2418 28/02/2019
                  v_currfield := 'IPRODUCCION';
                  v_iproduccion := pac_util.splitt(v_line, 7, v_sep);
                  v_currfield := 'IRECAUDO';
                  v_irecaudo := pac_util.splitt(v_line, 8, v_sep);
                  --
                  -- Begin no necesario. El manejo de excepciones se realizar con el de ms
                  -- arriba
                  -- BEGIN
                     --Insert
                     -- Se traslada insert sobre tabla campaage a funcin f_ejecutarproceso
                     /*INSERT INTO campaage
                                 (ccodigo, cagente, ctipage, finicam, ffincam, bganador,
                                  imeta)
                          VALUES (v_ccodigo, v_cagente, v_ctipage, v_finicam, v_ffincam, 'N',
                                  v_imeta);*/
                     --
                     -- Se realiza insercin de datos sobre tabla externa int_carga_campaage
                     --
                     INSERT INTO int_carga_campaage
                       (proceso, nlinea, ncarga, ccampana, cagente, imeta,
                        falta, finicam, ffincam, ctipage, iproduccion, irecaudo)
                     VALUES
                        (psproces, v_numlineaf, vncarga, v_ccodigo, v_cagente, v_imeta,
                         f_sysdate, v_finicam,v_ffincam,v_ctipage,v_iproduccion,v_irecaudo );
                  --
                  -- Tambin se traslada la excepecin puesto que no habr insert para la tabla
                  -- campaage
                  --
                  /*EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                        UPDATE campaage
                           SET ccodigo = v_ccodigo,
                               cagente = v_cagente,
                               ctipage = v_ctipage,
                               finicam = v_finicam,
                               ffincam = v_ffincam,
                               bganador = 'N'
                         WHERE ccodigo = v_ccodigo
                           AND cagente = v_cagente
                           AND ctipage = v_ctipage;
                  END;*/
                  -- Fin IAXIS-2418 28/02/2019
                  vnum_err :=
                     pac_gestion_procesos.f_set_carga_ctrl_linea(psproces => psproces,
                                                                 pnlinea => v_numlineaf,
                                                                 pctipo => 20,
                                                                 pidint => v_numlineaf,
                                                                 pidext => v_numlineaf,
                                                                 pcestado => 4,
                                                                 pcvalidado => NULL,
                                                                 psseguro => NULL,
                                                                 pidexterno => NULL,
                                                                 pncarga => NULL,
                                                                 pnsinies => NULL,
                                                                 pntramit => NULL,
                                                                 psperson => NULL,
                                                                 pnrecibo => NULL);
                  --
                  COMMIT;
               --
               END IF;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  -- No hay mas datos para leer.
                  v_numlineaf := -1;
               WHEN OTHERS THEN
                  -- Inicio IAXIS-2418 28/02/2019
                  -- Traza de errores por lnea
                  --p_controlar_error(2, 3, NULL);
                  vnum_err :=
                     pac_gestion_procesos.f_set_carga_ctrl_linea(psproces => psproces,
                                                                 pnlinea => v_numlineaf,
                                                                 pctipo => 20,
                                                                 pidint => v_numlineaf,
                                                                 pidext => v_numlineaf,
                                                                 pcestado => 4,
                                                                 pcvalidado => NULL,
                                                                 psseguro => NULL,
                                                                 pidexterno => NULL,
                                                                 pncarga => NULL,
                                                                 pnsinies => NULL,
                                                                 pntramit => NULL,
                                                                 psperson => NULL,
                                                                 pnrecibo => NULL);
                  p_error_linea_g(psproces, NULL, v_numlineaf,
                                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
                  -- Fin IAXIS-2418 28/02/2019
            END;
         END LOOP;

         UTL_FILE.fclose(v_file);
         RETURN 0;
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_backtrace);
            ROLLBACK;
            UTL_FILE.fclose(v_file);
            p_controlar_error(5, 1,
                              f_axis_literales(9904284, pac_md_common.f_get_cxtidioma())
                              || ' at line ' || v_numlineaf);
            RETURN 9904284;
         -- Duplicated record
         WHEN VALUE_ERROR THEN
            DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_backtrace);
            ROLLBACK;
            UTL_FILE.fclose(v_file);
            p_controlar_error(6, 1,
                              f_axis_literales(9907933, pac_md_common.f_get_cxtidioma())
                              || ' at line ' || v_numlineaf || ', field: ' || v_currfield);
            RETURN 9907933;
         -- Data Error. Check character length OR NUMBER format
         WHEN OTHERS THEN
            DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_backtrace);
            ROLLBACK;
            UTL_FILE.fclose(v_file);
            p_controlar_error(7, 1, f_axis_literales(103187, pac_md_common.f_get_cxtidioma()));
            RETURN 103187;
      -- An error has occurred while reading the file
      END;
   EXCEPTION
      WHEN e_errdatos THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, vobj, vlin, vpar, SQLCODE || CHR(10) || vnum_err);
         DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_backtrace);
         RETURN vnum_err;
      WHEN errorini THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, vobj, vlin, vpar, SQLCODE || CHR(10) || vnum_err);
         DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_backtrace);
         RETURN 108953;
   -- A runtime error has occurred
   END f_campana_ejecutarcargafichero;
   --
   -- Inicio IAXIS-2418 28/02/2019
   --
   /*************************************************************************
   FUNCTION f_campana_ejecutarproceso
   Ejecuta la carga del archivo de campaas de agentes
   Retorna 1- Error, 2- correcto
   *************************************************************************/
   FUNCTION f_campana_ejecutarproceso(p_sproces IN NUMBER)
      RETURN NUMBER IS
      rcampaage      campaage%ROWTYPE;
      vcod           NUMBER;
      vexiste        detvalores.tatribu%TYPE;
      vtraza         NUMBER;
      vdeserror      VARCHAR2(1000);
      vobj           VARCHAR2(100) := 'pac_cargas_conf.f_campana_ejecutarproceso';
      verror         NUMBER;
   BEGIN
     --
     vtraza := 1;
     --
     FOR cur_campaage IN (SELECT i.*
                            FROM int_carga_campaage i
                            WHERE proceso = p_sproces) LOOP
       BEGIN
         --
         vtraza := 2;
         --
         rcampaage.ccodigo := cur_campaage.ccampana;
         rcampaage.cagente := cur_campaage.cagente;
         rcampaage.ctipage := cur_campaage.ctipage;
         rcampaage.finicam := cur_campaage.finicam;
         rcampaage.ffincam := cur_campaage.ffincam;
         rcampaage.imeta   := cur_campaage.imeta;
         rcampaage.iproduccion := cur_campaage.iproduccion;
         rcampaage.irecaudo := cur_campaage.irecaudo;
         rcampaage.bganador := 'N';
         --
         vtraza := 3;
         --
         INSERT INTO campaage VALUES rcampaage;
         --
         vtraza := 4;
         --
       EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
           --
           vtraza := 5;
           --
           UPDATE campaage
              SET ccodigo = rcampaage.ccodigo,
                  cagente = rcampaage.cagente,
                  ctipage = rcampaage.ctipage,
                  finicam = rcampaage.finicam,
                  ffincam = rcampaage.ffincam,
                  bganador = rcampaage.bganador,
                  imeta = rcampaage.imeta,
                  iproduccion = rcampaage.iproduccion,
                  irecaudo =  rcampaage.irecaudo
            WHERE ccodigo = rcampaage.ccodigo
              AND cagente = rcampaage.cagente;
           --
           vtraza := 6;
           --
       END;
     --
     END LOOP;
   --
   RETURN 2;
   EXCEPTION
      WHEN OTHERS THEN
         p_genera_logs_g(vobj, vtraza, 'Error: ' || SQLCODE, SQLERRM, p_sproces,
                         'Error: ' || SQLERRM);
         RETURN 1;
   END f_campana_ejecutarproceso;
   --
   -- Fin IAXIS-2418 28/02/2019
   --
   --
   PROCEDURE p_genera_logs(
      p_tabobj IN VARCHAR2,
      p_tabtra IN NUMBER,
      p_tabdes IN VARCHAR2,
      p_taberr IN VARCHAR2) IS
   BEGIN
      IF p_tabobj IS NOT NULL
         AND p_tabtra IS NOT NULL THEN
         p_tab_error(f_sysdate, f_user, p_tabobj, p_tabtra, SUBSTR(p_tabdes, 1, 500),
                     SUBSTR(p_taberr, 1, 2500), 10);
      END IF;
   END p_genera_logs;

   --
  /*  --INI -IAXIS-51545 - JLTS - 04/09/2019
    FUNCTION f_carga_informa_colombia(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER,
      pjob IN NUMBER DEFAULT 0,
      pcusuari IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'pac_cargas_conf.f_carga_informa_colombia';
      vtraza         NUMBER := 0;
      vnum_err       NUMBER := 0;
      vsalir         EXCEPTION;

      --
      CURSOR infcolombiais IS
         SELECT r.*
           FROM int_carga_informacol r
          WHERE r.proceso = psproces;

      --
      FUNCTION f_ejecutar_carga_fichero(
         p_nombre IN VARCHAR2,
         p_path IN VARCHAR2,
         p_cproces IN NUMBER,
         psproces IN OUT NUMBER)
         RETURN NUMBER IS
         vobj           VARCHAR2(100) := 'f_ejecutar_carga_fichero';
         vtraza         NUMBER := 0;
         vdeserror      VARCHAR2(1000);
         errorini       EXCEPTION;
         vnum_err       NUMBER := 0;
         vsalir         EXCEPTION;

         --
         FUNCTION f_modi_tabla_ext(p_nombre VARCHAR2, p_path IN VARCHAR2)
            RETURN NUMBER IS
            v_iteraciones  NUMBER(2);
            k_iteraciones  NUMBER(2) := 10;
         BEGIN
            v_iteraciones := 1;

            LOOP
               BEGIN
                  LOCK TABLE int_carga_informacol_ext IN EXCLUSIVE MODE;

                  EXECUTE IMMEDIATE 'ALTER TABLE int_carga_informacol_ext LOCATION ('
                                    || p_path || ':''' || p_nombre || ''')';

                  EXIT;
               EXCEPTION
                  WHEN OTHERS THEN
                     p_tab_error(f_sysdate, f_user, 'f_modi_tabla_ext', v_iteraciones,
                                 'Error modificando tabla. Reintento.', SQLERRM, 10);

                     IF k_iteraciones <= v_iteraciones THEN
                        RAISE;
                     END IF;

                     v_iteraciones := v_iteraciones + 1;
               END;
            END LOOP;

            LOCK TABLE int_carga_informacol_ext IN EXCLUSIVE MODE;
            RETURN 0;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'pac_cargas_conf.f_modi_tabla_ext', 1,
                           'Error creando la tabla.', SQLERRM, 10);
               RETURN 103865;
         END f_modi_tabla_ext;

         --
         FUNCTION f_trasp_tabla(pdeserror OUT VARCHAR2, psproces IN NUMBER)
            RETURN NUMBER IS
            v_pasexec           NUMBER := 1;
            vobj                VARCHAR2(200) := 'pac_cargas_conf.f_trasp_tabla';
            v_numlin            int_carga_informacol.nlinea%TYPE;
             v_existe_sfianci NUMBER := 0;
             v_existe_indicad NUMBER := 0;
             v_existe_d_renta NUMBER := 0;
             v_existe_informa NUMBER := 0;
                        v_nit int_carga_informacol.nit%TYPE;
                   v_sfinanci NUMBER := 0;

              v_existe_cuenta NUMBER := 0;
              v_conta_informa NUMBER := 0;

         BEGIN
            v_pasexec := 0;
            pdeserror := NULL;

            SELECT NVL(MAX(nlinea), 0)
              INTO v_numlin
              FROM int_carga_informacol
             WHERE proceso = psproces;

            INSERT      \*+ APPEND *\INTO int_carga_informacol
                        (proceso, nlinea, ncarga, tipo_oper, nit, nombre, tiposociedad,
                         reprelegal, revfiscal, estempresa, objsocial, fechacons, vigsociedad,
                         limreplegal, incjudicial, nomaccionista1, nomaccionista2,
                         nomaccionista3, nomaccionista4, nitaccionista1, nitaccionista2,
                         nitaccionista3, nitaccionista4, partaccionista1, partaccionista2,
                         partaccionista3, partaccionista4, ciiu, fuenteinf, moneda, valmiles,
                         fecestfinan, ventas, ventasperant, costoventas, gastosadm,
                         utloperacional, gastosfinan, resultantimp, utlneta, inventario,
                         cartcliente, actcorriente, totactnocorriente, propplanequipo,
                         otrosactivos, activototal, obligfinancp, proveedorescp, anticipocp,
                         pascorriente, obligfinanlp, anticipolp, totpascorriente, pastotal,
                         patriperant, patrianoact, capsocial, pricolacc, invsuplcap, reslegal,
                         resocasional, resejerant, valorizacion, feccamcomercio, fotrut,
                         fecrut, fotcedula, fecexpcedula, ciuexpcedula, feccordeclrenta,
                         patriliquido, renliqgrav, origencarga)
               (SELECT psproces proceso, ROWNUM + v_numlin nlinea, NULL ncarga, NULL tipo_oper,
                       nit, nombre, tiposociedad, reprelegal, revfiscal, estempresa, objsocial,
                       fechacons, vigsociedad, limreplegal, incjudicial, nomaccionista1,
                       nomaccionista2, nomaccionista3, nomaccionista4, nitaccionista1,
                       nitaccionista2, nitaccionista3, nitaccionista4, partaccionista1,
                       partaccionista2, partaccionista3, partaccionista4, ciiu, fuenteinf,
                       moneda, valmiles, fecestfinan, ventas, ventasperant, costoventas,
                       gastosadm, utloperacional, gastosfinan, resultantimp, utlneta,
                       inventario, cartcliente, actcorriente, totactnocorriente,
                       propplanequipo, otrosactivos, activototal, obligfinancp, proveedorescp,
                       anticipocp, pascorriente, obligfinanlp, anticipolp, totpascorriente,
                       pastotal, patriperant, patrianoact, capsocial, pricolacc, invsuplcap,
                       reslegal, resocasional, resejerant, valorizacion, feccamcomercio,
                       fotrut, fecrut, fotcedula, fecexpcedula, ciuexpcedula, feccordeclrenta,
                       patriliquido, renliqgrav, 'ARC'
                  FROM int_carga_informacol_ext);


                FOR ext IN(select e.*
                             from int_carga_informacol_ext e
                           ) LOOP

                         SELECT count(SFINANCI)
                          INTO v_existe_sfianci
                          FROM FIN_GENERAL fg
                         WHERE fg.SPERSON in(select pp.SPERSON
                                               from PER_PERSONAS pp
                                              where pp.NNUMIDE
                                               like ext.nit || '%');

                       IF v_existe_sfianci > 0 THEN

                        SELECT SFINANCI
                          INTO v_sfinanci
                          FROM FIN_GENERAL fg
                         WHERE fg.SPERSON in(select pp.SPERSON
                                               from PER_PERSONAS pp
                                              where pp.NNUMIDE
                                               like ext.nit || '%');

                                  UPDATE FIN_GENERAL
                                     SET tdescrip = 'Ficha tecnica ' || ext.NOMBRE,
                                         cfotorut = ext.FOTRUT,
                                             frut = TO_DATE(ext.FECRUT,'DD/MM/YYYY'),
                                         cfotoced = ext.FOTCEDULA,
                                         fexpiced = TO_DATE(ext.FECEXPCEDULA,'DD/MM/YYYY'),
                                            cciiu = ext.CIIU,
                                         ctipsoci = ext.TIPOSOCIEDAD,
                                          cestsoc = (select CATRIBU
                                                      from  DETVALORES
                                                      where cidioma = 8
                                                       and cvalor = '8001074'
                                                       and UPPER(TATRIBU)
                                                      like ext.ESTEMPRESA),
                                          tobjsoc = ext.OBJSOCIAL,
                                          fconsti = TO_DATE(ext.FECHACONS,'DD/MM/YYYY'),
                                          tvigenc = ext.VIGSOCIEDAD,
                                          fccomer = TO_DATE(ext.FECCAMCOMERCIO,'DD/MM/YYYY')
                                   WHERE sfinanci = v_sfinanci;



                                  SELECT count(*)
                                    INTO v_existe_indicad
                                    FROM FIN_INDICADORES
                                   WHERE sfinanci = v_sfinanci
                                     and findicad = TO_DATE(ext.fecestfinan,'DD/MM/YYYY');


                                   IF v_existe_indicad > 0 THEN

                                     FOR fin_indica IN(select fi.*
                                                         from fin_indicadores fi
                                                        where fi.sfinanci = v_sfinanci
                                                          and fi.findicad = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')
                                                         ) LOOP

                                          SELECT count(*)
                                            INTO v_existe_informa
                                            FROM fin_parametros fp
                                           WHERE fp.sfinanci = v_sfinanci
                                             and  fp.nmovimi = fin_indica.nmovimi
                                             and   fp.cparam = 'FUENTE_INFORMACION'
                                             and  fp.nvalpar = 1;

                                          v_conta_informa := v_conta_informa + v_existe_informa;

                                      END LOOP;

                                   END IF;



                                   IF v_existe_indicad = 0 OR v_conta_informa = 0 THEN

                                      INSERT INTO FIN_INDICADORES
                                                  (sfinanci, nmovimi, findicad, imargen, icaptrab,
                                                    trazcor, tprbaci, ienduada, ndiacar, nrotpro,
                                                    nrotinv, ndiacicl, irentab, ioblcp, iobllp,
                                                   igastfin, ivalpt, cesvalor, cmoneda, fcupo,
                                                     icupog, icupos, fcupos, tcupor, tconcepc,
                                                   tconceps, tcburea, tcotros, cmoncam, ncapfin)
                                          VALUES (v_sfinanci, nmovimi.nextval,  TO_DATE(ext.fecestfinan,'DD/MM/YYYY'), null, null,
                                                   null, null, null, null, null,
                                                   null, null, null, null, null,
                                                   null, null, '1', 'COP', null,
                                                   null, null, null, null, null,
                                                   null, null, null, null, null);



                                                  SELECT count(*)
                                                    INTO v_existe_cuenta
                                                    FROM FIN_PARAMETROS
                                                   WHERE sfinanci = v_sfinanci
                                                     AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                     AND cparam = 'FUENTE_INFORMACION';

                                                 IF v_existe_cuenta = 0 THEN
                                                  INSERT INTO FIN_PARAMETROS
                                                              (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                                                       VALUES (v_sfinanci, (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')), 'FUENTE_INFORMACION', f_user, f_sysdate, f_user, f_sysdate, null, 1, null);
                                                 ELSE
                                                     UPDATE FIN_PARAMETROS
                                                        SET nvalpar = 1
                                                      WHERE sfinanci = v_sfinanci
                                                        AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                        AND cparam = 'FUENTE_INFORMACION';
                                                 END IF;

                                                  SELECT count(*)
                                                    INTO v_existe_cuenta
                                                    FROM FIN_PARAMETROS
                                                   WHERE sfinanci = v_sfinanci
                                                     AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                     AND cparam = 'FECHA_EST_FIN';

                                                 IF v_existe_cuenta = 0 THEN
                                                  INSERT INTO FIN_PARAMETROS
                                                              (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                                                       VALUES (v_sfinanci, (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')), 'FECHA_EST_FIN', f_user, f_sysdate, f_user, f_sysdate, TO_DATE(ext.fecestfinan,'DD/MM/YYYY'), null, null);
                                                 ELSE
                                                     UPDATE FIN_PARAMETROS
                                                        SET fvalpar = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')
                                                      WHERE sfinanci = v_sfinanci
                                                        AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                        AND cparam = 'FECHA_EST_FIN';
                                                 END IF;

                                                  SELECT count(*)
                                                    INTO v_existe_cuenta
                                                    FROM FIN_PARAMETROS
                                                   WHERE sfinanci = v_sfinanci
                                                     AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                     AND cparam = 'VT_PER_ANT';

                                                 IF v_existe_cuenta = 0 THEN
                                                  INSERT INTO FIN_PARAMETROS
                                                              (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                                                       VALUES (v_sfinanci, (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')), 'VT_PER_ANT', f_user, f_sysdate, f_user, f_sysdate, null, null, ext.VENTASPERANT);
                                                 ELSE
                                                     UPDATE FIN_PARAMETROS
                                                        SET tvalpar = ext.VENTASPERANT
                                                      WHERE sfinanci = v_sfinanci
                                                        AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                        AND cparam = 'VT_PER_ANT';
                                                 END IF;

                                                     SELECT count(*)
                                                    INTO v_existe_cuenta
                                                    FROM FIN_PARAMETROS
                                                   WHERE sfinanci = v_sfinanci
                                                     AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                     AND cparam = 'VENTAS';

                                                 IF v_existe_cuenta = 0 THEN
                                                  INSERT INTO FIN_PARAMETROS
                                                              (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                                                       VALUES (v_sfinanci, (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')), 'VENTAS', f_user, f_sysdate, f_user, f_sysdate, null, null, ext.VENTAS);
                                                 ELSE
                                                     UPDATE FIN_PARAMETROS
                                                        SET tvalpar = ext.VENTAS
                                                      WHERE sfinanci = v_sfinanci
                                                        AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                        AND cparam = 'VENTAS';
                                                 END IF;


                                                   SELECT count(*)
                                                    INTO v_existe_cuenta
                                                    FROM FIN_PARAMETROS
                                                   WHERE sfinanci = v_sfinanci
                                                     AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                     AND cparam = 'COSTO_VT';

                                                 IF v_existe_cuenta = 0 THEN
                                                  INSERT INTO FIN_PARAMETROS
                                                              (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                                                       VALUES (v_sfinanci, (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')), 'COSTO_VT', f_user, f_sysdate, f_user, f_sysdate, null, null, ext.COSTOVENTAS);
                                                 ELSE
                                                     UPDATE FIN_PARAMETROS
                                                        SET tvalpar = ext.COSTOVENTAS
                                                      WHERE sfinanci = v_sfinanci
                                                        AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                        AND cparam = 'COSTO_VT';
                                                 END IF;


                                                    SELECT count(*)
                                                    INTO v_existe_cuenta
                                                    FROM FIN_PARAMETROS
                                                   WHERE sfinanci = v_sfinanci
                                                     AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                     AND cparam = 'GASTO_ADM';

                                                 IF v_existe_cuenta = 0 THEN
                                                  INSERT INTO FIN_PARAMETROS
                                                              (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                                                       VALUES (v_sfinanci, (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')), 'GASTO_ADM', f_user, f_sysdate, f_user, f_sysdate, null, null, ext.GASTOSADM);
                                                 ELSE
                                                     UPDATE FIN_PARAMETROS
                                                        SET tvalpar = ext.GASTOSADM
                                                      WHERE sfinanci = v_sfinanci
                                                        AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                        AND cparam = 'GASTO_ADM';
                                                 END IF;


                                                  SELECT count(*)
                                                    INTO v_existe_cuenta
                                                    FROM FIN_PARAMETROS
                                                   WHERE sfinanci = v_sfinanci
                                                     AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                     AND cparam = 'UTIL_OPERAC';

                                                 IF v_existe_cuenta = 0 THEN
                                                  INSERT INTO FIN_PARAMETROS
                                                              (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                                                       VALUES (v_sfinanci, (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')), 'UTIL_OPERAC', f_user, f_sysdate, f_user, f_sysdate, null, null, ext.UTLOPERACIONAL);
                                                 ELSE
                                                     UPDATE FIN_PARAMETROS
                                                        SET tvalpar = ext.UTLOPERACIONAL
                                                      WHERE sfinanci = v_sfinanci
                                                        AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                        AND cparam = 'UTIL_OPERAC';
                                                 END IF;

                                                    SELECT count(*)
                                                    INTO v_existe_cuenta
                                                    FROM FIN_PARAMETROS
                                                   WHERE sfinanci = v_sfinanci
                                                     AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                     AND cparam = 'GASTO_FIN';

                                                 IF v_existe_cuenta = 0 THEN
                                                  INSERT INTO FIN_PARAMETROS
                                                              (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                                                       VALUES (v_sfinanci, (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')), 'GASTO_FIN', f_user, f_sysdate, f_user, f_sysdate, null, null, ext.GASTOSFINAN);
                                                 ELSE
                                                     UPDATE FIN_PARAMETROS
                                                        SET tvalpar = ext.GASTOSFINAN
                                                      WHERE sfinanci = v_sfinanci
                                                        AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                        AND cparam = 'GASTO_FIN';
                                                 END IF;

                                                   SELECT count(*)
                                                    INTO v_existe_cuenta
                                                    FROM FIN_PARAMETROS
                                                   WHERE sfinanci = v_sfinanci
                                                     AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                     AND cparam = 'GASTO_FIN';

                                                 IF v_existe_cuenta = 0 THEN
                                                  INSERT INTO FIN_PARAMETROS
                                                              (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                                                       VALUES (v_sfinanci, (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')), 'GASTO_FIN', f_user, f_sysdate, f_user, f_sysdate, null, null, ext.GASTOSFINAN);
                                                 ELSE
                                                     UPDATE FIN_PARAMETROS
                                                        SET tvalpar = ext.GASTOSFINAN
                                                      WHERE sfinanci = v_sfinanci
                                                        AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                        AND cparam = 'GASTO_FIN';
                                                 END IF;

                                                  SELECT count(*)
                                                    INTO v_existe_cuenta
                                                    FROM FIN_PARAMETROS
                                                   WHERE sfinanci = v_sfinanci
                                                     AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                     AND cparam = 'RES_ANT_IMP';

                                                 IF v_existe_cuenta = 0 THEN
                                                  INSERT INTO FIN_PARAMETROS
                                                              (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                                                       VALUES (v_sfinanci, (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')), 'RES_ANT_IMP', f_user, f_sysdate, f_user, f_sysdate, null, null, ext.RESULTANTIMP);
                                                 ELSE
                                                     UPDATE FIN_PARAMETROS
                                                        SET tvalpar = ext.RESULTANTIMP
                                                      WHERE sfinanci = v_sfinanci
                                                        AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                        AND cparam = 'RES_ANT_IMP';
                                                 END IF;


                                                   SELECT count(*)
                                                    INTO v_existe_cuenta
                                                    FROM FIN_PARAMETROS
                                                   WHERE sfinanci = v_sfinanci
                                                     AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                     AND cparam = 'UTIL_NETA';

                                                 IF v_existe_cuenta = 0 THEN
                                                  INSERT INTO FIN_PARAMETROS
                                                              (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                                                       VALUES (v_sfinanci, (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')), 'UTIL_NETA', f_user, f_sysdate, f_user, f_sysdate, null, null, ext.UTLNETA);
                                                 ELSE
                                                     UPDATE FIN_PARAMETROS
                                                        SET tvalpar = ext.UTLNETA
                                                      WHERE sfinanci = v_sfinanci
                                                        AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                        AND cparam = 'UTIL_NETA';
                                                 END IF;

                                                 SELECT count(*)
                                                    INTO v_existe_cuenta
                                                    FROM FIN_PARAMETROS
                                                   WHERE sfinanci = v_sfinanci
                                                     AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                     AND cparam = 'INVENT';

                                                 IF v_existe_cuenta = 0 THEN
                                                  INSERT INTO FIN_PARAMETROS
                                                              (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                                                       VALUES (v_sfinanci, (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')), 'INVENT', f_user, f_sysdate, f_user, f_sysdate, null, null, ext.INVENTARIO);
                                                 ELSE
                                                     UPDATE FIN_PARAMETROS
                                                        SET tvalpar = ext.INVENTARIO
                                                      WHERE sfinanci = v_sfinanci
                                                        AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                        AND cparam = 'INVENT';
                                                 END IF;


                                                   SELECT count(*)
                                                    INTO v_existe_cuenta
                                                    FROM FIN_PARAMETROS
                                                   WHERE sfinanci = v_sfinanci
                                                     AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                     AND cparam = 'CARTE_CLIE';

                                                 IF v_existe_cuenta = 0 THEN
                                                  INSERT INTO FIN_PARAMETROS
                                                              (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                                                       VALUES (v_sfinanci, (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')), 'CARTE_CLIE', f_user, f_sysdate, f_user, f_sysdate, null, null, ext.CARTCLIENTE);
                                                 ELSE
                                                     UPDATE FIN_PARAMETROS
                                                        SET tvalpar = ext.CARTCLIENTE
                                                      WHERE sfinanci = v_sfinanci
                                                        AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                        AND cparam = 'CARTE_CLIE';
                                                 END IF;


                                                   SELECT count(*)
                                                    INTO v_existe_cuenta
                                                    FROM FIN_PARAMETROS
                                                   WHERE sfinanci = v_sfinanci
                                                     AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                     AND cparam = 'ACT_CORR';

                                                 IF v_existe_cuenta = 0 THEN
                                                  INSERT INTO FIN_PARAMETROS
                                                              (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                                                       VALUES (v_sfinanci, (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')), 'ACT_CORR', f_user, f_sysdate, f_user, f_sysdate, null, null, ext.ACTCORRIENTE);
                                                 ELSE
                                                     UPDATE FIN_PARAMETROS
                                                        SET tvalpar = ext.ACTCORRIENTE
                                                      WHERE sfinanci = v_sfinanci
                                                        AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                        AND cparam = 'ACT_CORR';
                                                 END IF;


                                                     SELECT count(*)
                                                    INTO v_existe_cuenta
                                                    FROM FIN_PARAMETROS
                                                   WHERE sfinanci = v_sfinanci
                                                     AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                     AND cparam = 'PROP_PLNT_EQP';

                                                 IF v_existe_cuenta = 0 THEN
                                                  INSERT INTO FIN_PARAMETROS
                                                              (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                                                       VALUES (v_sfinanci, (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')), 'PROP_PLNT_EQP', f_user, f_sysdate, f_user, f_sysdate, null, null, ext.PROPPLANEQUIPO);
                                                 ELSE
                                                     UPDATE FIN_PARAMETROS
                                                        SET tvalpar = ext.PROPPLANEQUIPO
                                                      WHERE sfinanci = v_sfinanci
                                                        AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                        AND cparam = 'PROP_PLNT_EQP';
                                                 END IF;

                                                   SELECT count(*)
                                                    INTO v_existe_cuenta
                                                    FROM FIN_PARAMETROS
                                                   WHERE sfinanci = v_sfinanci
                                                     AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                     AND cparam = 'TOT_ACT_NO_CORR';

                                                 IF v_existe_cuenta = 0 THEN
                                                  INSERT INTO FIN_PARAMETROS
                                                              (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                                                       VALUES (v_sfinanci, (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')), 'TOT_ACT_NO_CORR', f_user, f_sysdate, f_user, f_sysdate, null, null, ext.TOTACTNOCORRIENTE);
                                                 ELSE
                                                     UPDATE FIN_PARAMETROS
                                                        SET tvalpar = ext.TOTACTNOCORRIENTE
                                                      WHERE sfinanci = v_sfinanci
                                                        AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                        AND cparam = 'TOT_ACT_NO_CORR';
                                                 END IF;


                                                    SELECT count(*)
                                                    INTO v_existe_cuenta
                                                    FROM FIN_PARAMETROS
                                                   WHERE sfinanci = v_sfinanci
                                                     AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                     AND cparam = 'ACT_TOTAL';

                                                 IF v_existe_cuenta = 0 THEN
                                                  INSERT INTO FIN_PARAMETROS
                                                              (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                                                       VALUES (v_sfinanci, (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')), 'ACT_TOTAL', f_user, f_sysdate, f_user, f_sysdate, null, null, ext.ACTIVOTOTAL);
                                                 ELSE
                                                     UPDATE FIN_PARAMETROS
                                                        SET tvalpar = ext.ACTIVOTOTAL
                                                      WHERE sfinanci = v_sfinanci
                                                        AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                        AND cparam = 'ACT_TOTAL';
                                                 END IF;


                                                    SELECT count(*)
                                                    INTO v_existe_cuenta
                                                    FROM FIN_PARAMETROS
                                                   WHERE sfinanci = v_sfinanci
                                                     AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                     AND cparam = 'O_FIN_CORTO_PLAZO';

                                                 IF v_existe_cuenta = 0 THEN
                                                  INSERT INTO FIN_PARAMETROS
                                                              (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                                                       VALUES (v_sfinanci, (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')), 'O_FIN_CORTO_PLAZO', f_user, f_sysdate, f_user, f_sysdate, null, null, ext.OBLIGFINANCP);
                                                 ELSE
                                                     UPDATE FIN_PARAMETROS
                                                        SET tvalpar = ext.OBLIGFINANCP
                                                      WHERE sfinanci = v_sfinanci
                                                        AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                        AND cparam = 'O_FIN_CORTO_PLAZO';
                                                 END IF;


                                                  SELECT count(*)
                                                    INTO v_existe_cuenta
                                                    FROM FIN_PARAMETROS
                                                   WHERE sfinanci = v_sfinanci
                                                     AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                     AND cparam = 'PROVEE_CORTO_PLAZO';

                                                 IF v_existe_cuenta = 0 THEN
                                                  INSERT INTO FIN_PARAMETROS
                                                              (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                                                       VALUES (v_sfinanci, (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')), 'PROVEE_CORTO_PLAZO', f_user, f_sysdate, f_user, f_sysdate, null, null, ext.PROVEEDORESCP);
                                                 ELSE
                                                     UPDATE FIN_PARAMETROS
                                                        SET tvalpar = ext.PROVEEDORESCP
                                                      WHERE sfinanci = v_sfinanci
                                                        AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                        AND cparam = 'PROVEE_CORTO_PLAZO';
                                                 END IF;


                                                    SELECT count(*)
                                                    INTO v_existe_cuenta
                                                    FROM FIN_PARAMETROS
                                                   WHERE sfinanci = v_sfinanci
                                                     AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                     AND cparam = 'ATC_CORTO_PLAZO';

                                                 IF v_existe_cuenta = 0 THEN
                                                  INSERT INTO FIN_PARAMETROS
                                                              (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                                                       VALUES (v_sfinanci, (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')), 'ATC_CORTO_PLAZO', f_user, f_sysdate, f_user, f_sysdate, null, null, ext.PROVEEDORESCP);
                                                 ELSE
                                                     UPDATE FIN_PARAMETROS
                                                        SET tvalpar = ext.PROVEEDORESCP
                                                      WHERE sfinanci = v_sfinanci
                                                        AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                        AND cparam = 'ATC_CORTO_PLAZO';
                                                 END IF;


                                                    SELECT count(*)
                                                    INTO v_existe_cuenta
                                                    FROM FIN_PARAMETROS
                                                   WHERE sfinanci = v_sfinanci
                                                     AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                     AND cparam = 'ATC_CORTO_PLAZO';

                                                 IF v_existe_cuenta = 0 THEN
                                                  INSERT INTO FIN_PARAMETROS
                                                              (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                                                       VALUES (v_sfinanci, (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')), 'ATC_CORTO_PLAZO', f_user, f_sysdate, f_user, f_sysdate, null, null, ext.ANTICIPOCP);
                                                 ELSE
                                                     UPDATE FIN_PARAMETROS
                                                        SET tvalpar = ext.ANTICIPOCP
                                                      WHERE sfinanci = v_sfinanci
                                                        AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                        AND cparam = 'ATC_CORTO_PLAZO';
                                                 END IF;


                                                    SELECT count(*)
                                                    INTO v_existe_cuenta
                                                    FROM FIN_PARAMETROS
                                                   WHERE sfinanci = v_sfinanci
                                                     AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                     AND cparam = 'PAS_CORR';

                                                 IF v_existe_cuenta = 0 THEN
                                                  INSERT INTO FIN_PARAMETROS
                                                              (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                                                       VALUES (v_sfinanci, (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')), 'PAS_CORR', f_user, f_sysdate, f_user, f_sysdate, null, null, ext.PASCORRIENTE);
                                                 ELSE
                                                     UPDATE FIN_PARAMETROS
                                                        SET tvalpar = ext.PASCORRIENTE
                                                      WHERE sfinanci = v_sfinanci
                                                        AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                        AND cparam = 'PAS_CORR';
                                                 END IF;


                                                    SELECT count(*)
                                                    INTO v_existe_cuenta
                                                    FROM FIN_PARAMETROS
                                                   WHERE sfinanci = v_sfinanci
                                                     AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                     AND cparam = 'O_FIN_LARGO_PLAZO';

                                                 IF v_existe_cuenta = 0 THEN
                                                  INSERT INTO FIN_PARAMETROS
                                                              (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                                                       VALUES (v_sfinanci, (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')), 'O_FIN_LARGO_PLAZO', f_user, f_sysdate, f_user, f_sysdate, null, null, ext.OBLIGFINANLP);
                                                 ELSE
                                                     UPDATE FIN_PARAMETROS
                                                        SET tvalpar = ext.OBLIGFINANLP
                                                      WHERE sfinanci = v_sfinanci
                                                        AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                        AND cparam = 'O_FIN_LARGO_PLAZO';
                                                 END IF;


                                                 SELECT count(*)
                                                    INTO v_existe_cuenta
                                                    FROM FIN_PARAMETROS
                                                   WHERE sfinanci = v_sfinanci
                                                     AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                     AND cparam = 'ATC_LARGO_PLAZO';

                                                 IF v_existe_cuenta = 0 THEN
                                                  INSERT INTO FIN_PARAMETROS
                                                              (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                                                       VALUES (v_sfinanci, (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')), 'ATC_LARGO_PLAZO', f_user, f_sysdate, f_user, f_sysdate, null, null, ext.ANTICIPOLP);
                                                 ELSE
                                                     UPDATE FIN_PARAMETROS
                                                        SET tvalpar = ext.ANTICIPOLP
                                                      WHERE sfinanci = v_sfinanci
                                                        AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                        AND cparam = 'ATC_LARGO_PLAZO';
                                                 END IF;


                                                    SELECT count(*)
                                                    INTO v_existe_cuenta
                                                    FROM FIN_PARAMETROS
                                                   WHERE sfinanci = v_sfinanci
                                                     AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                     AND cparam = 'PAS_NO_CORR';

                                                 IF v_existe_cuenta = 0 THEN
                                                  INSERT INTO FIN_PARAMETROS
                                                              (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                                                       VALUES (v_sfinanci, (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')), 'PAS_NO_CORR', f_user, f_sysdate, f_user, f_sysdate, null, null, ext.TOTPASCORRIENTE);
                                                 ELSE
                                                     UPDATE FIN_PARAMETROS
                                                        SET tvalpar = ext.TOTPASCORRIENTE
                                                      WHERE sfinanci = v_sfinanci
                                                        AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                        AND cparam = 'PAS_NO_CORR';
                                                 END IF;


                                                   SELECT count(*)
                                                    INTO v_existe_cuenta
                                                    FROM FIN_PARAMETROS
                                                   WHERE sfinanci = v_sfinanci
                                                     AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                     AND cparam = 'PAS_TOTAL';

                                                 IF v_existe_cuenta = 0 THEN
                                                  INSERT INTO FIN_PARAMETROS
                                                              (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                                                       VALUES (v_sfinanci, (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')), 'PAS_TOTAL', f_user, f_sysdate, f_user, f_sysdate, null, null, ext.PASTOTAL);
                                                 ELSE
                                                     UPDATE FIN_PARAMETROS
                                                        SET tvalpar = ext.PASTOTAL
                                                      WHERE sfinanci = v_sfinanci
                                                        AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                        AND cparam = 'PAS_TOTAL';
                                                 END IF;



                                                   SELECT count(*)
                                                    INTO v_existe_cuenta
                                                    FROM FIN_PARAMETROS
                                                   WHERE sfinanci = v_sfinanci
                                                     AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                     AND cparam = 'PATRI_PERI_ANT';

                                                 IF v_existe_cuenta = 0 THEN
                                                  INSERT INTO FIN_PARAMETROS
                                                              (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                                                       VALUES (v_sfinanci, (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')), 'PATRI_PERI_ANT', f_user, f_sysdate, f_user, f_sysdate, null, null, ext.PATRIPERANT);
                                                 ELSE
                                                     UPDATE FIN_PARAMETROS
                                                        SET tvalpar = ext.PATRIPERANT
                                                      WHERE sfinanci = v_sfinanci
                                                        AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                        AND cparam = 'PATRI_PERI_ANT';
                                                 END IF;


                                                 SELECT count(*)
                                                    INTO v_existe_cuenta
                                                    FROM FIN_PARAMETROS
                                                   WHERE sfinanci = v_sfinanci
                                                     AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                     AND cparam = 'PATRI_ANO_ACTUAL';

                                                 IF v_existe_cuenta = 0 THEN
                                                  INSERT INTO FIN_PARAMETROS
                                                              (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                                                       VALUES (v_sfinanci, (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')), 'PATRI_ANO_ACTUAL', f_user, f_sysdate, f_user, f_sysdate, null, null, ext.PATRIANOACT);
                                                 ELSE
                                                     UPDATE FIN_PARAMETROS
                                                        SET tvalpar = ext.PATRIANOACT
                                                      WHERE sfinanci = v_sfinanci
                                                        AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                        AND cparam = 'PATRI_ANO_ACTUAL';
                                                 END IF;


                                                   SELECT count(*)
                                                    INTO v_existe_cuenta
                                                    FROM FIN_PARAMETROS
                                                   WHERE sfinanci = v_sfinanci
                                                     AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                     AND cparam = 'RESV_LEGAL';

                                                 IF v_existe_cuenta = 0 THEN
                                                  INSERT INTO FIN_PARAMETROS
                                                              (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                                                       VALUES (v_sfinanci, (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')), 'RESV_LEGAL', f_user, f_sysdate, f_user, f_sysdate, null, null, ext.RESLEGAL);
                                                 ELSE
                                                     UPDATE FIN_PARAMETROS
                                                        SET tvalpar = ext.RESLEGAL
                                                      WHERE sfinanci = v_sfinanci
                                                        AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                        AND cparam = 'RESV_LEGAL';
                                                 END IF;


                                                  SELECT count(*)
                                                    INTO v_existe_cuenta
                                                    FROM FIN_PARAMETROS
                                                   WHERE sfinanci = v_sfinanci
                                                     AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                     AND cparam = 'CAP_SOCIAL';

                                                 IF v_existe_cuenta = 0 THEN
                                                  INSERT INTO FIN_PARAMETROS
                                                              (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                                                       VALUES (v_sfinanci, (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')), 'CAP_SOCIAL', f_user, f_sysdate, f_user, f_sysdate, null, null, ext.CAPSOCIAL);
                                                 ELSE
                                                     UPDATE FIN_PARAMETROS
                                                        SET tvalpar = ext.CAPSOCIAL
                                                      WHERE sfinanci = v_sfinanci
                                                        AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                        AND cparam = 'CAP_SOCIAL';
                                                 END IF;

                                                 SELECT count(*)
                                                    INTO v_existe_cuenta
                                                    FROM FIN_PARAMETROS
                                                   WHERE sfinanci = v_sfinanci
                                                     AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                     AND cparam = 'RES_EJER_ANT';

                                                 IF v_existe_cuenta = 0 THEN
                                                  INSERT INTO FIN_PARAMETROS
                                                              (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                                                       VALUES (v_sfinanci, (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')), 'RES_EJER_ANT', f_user, f_sysdate, f_user, f_sysdate, null, null, ext.RESEJERANT);
                                                 ELSE
                                                     UPDATE FIN_PARAMETROS
                                                        SET tvalpar = ext.RESEJERANT
                                                      WHERE sfinanci = v_sfinanci
                                                        AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                        AND cparam = 'RES_EJER_ANT';
                                                 END IF;


                                                  SELECT count(*)
                                                    INTO v_existe_cuenta
                                                    FROM FIN_PARAMETROS
                                                   WHERE sfinanci = v_sfinanci
                                                     AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                     AND cparam = 'PRIMA_ACCION';

                                                 IF v_existe_cuenta = 0 THEN
                                                  INSERT INTO FIN_PARAMETROS
                                                              (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                                                       VALUES (v_sfinanci, (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')), 'PRIMA_ACCION', f_user, f_sysdate, f_user, f_sysdate, null, null, ext.PRICOLACC);
                                                 ELSE
                                                     UPDATE FIN_PARAMETROS
                                                        SET tvalpar = ext.PRICOLACC
                                                      WHERE sfinanci = v_sfinanci
                                                        AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                        AND cparam = 'PRIMA_ACCION';
                                                 END IF;


                                                   SELECT count(*)
                                                    INTO v_existe_cuenta
                                                    FROM FIN_PARAMETROS
                                                   WHERE sfinanci = v_sfinanci
                                                     AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                     AND cparam = 'RESV_OCASI';

                                                 IF v_existe_cuenta = 0 THEN
                                                  INSERT INTO FIN_PARAMETROS
                                                              (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                                                       VALUES (v_sfinanci, (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')), 'RESV_OCASI', f_user, f_sysdate, f_user, f_sysdate, null, null, ext.RESOCASIONAL);
                                                 ELSE
                                                     UPDATE FIN_PARAMETROS
                                                        SET tvalpar = ext.RESOCASIONAL
                                                      WHERE sfinanci = v_sfinanci
                                                        AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                        AND cparam = 'RESV_OCASI';
                                                 END IF;


                                                   SELECT count(*)
                                                    INTO v_existe_cuenta
                                                    FROM FIN_PARAMETROS
                                                   WHERE sfinanci = v_sfinanci
                                                     AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                     AND cparam = 'VALORIZA';

                                                 IF v_existe_cuenta = 0 THEN
                                                  INSERT INTO FIN_PARAMETROS
                                                              (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                                                       VALUES (v_sfinanci, (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')), 'VALORIZA', f_user, f_sysdate, f_user, f_sysdate, null, null, ext.VALORIZACION);
                                                 ELSE
                                                     UPDATE FIN_PARAMETROS
                                                        SET tvalpar = ext.VALORIZACION
                                                      WHERE sfinanci = v_sfinanci
                                                        AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                        AND cparam = 'VALORIZA';
                                                 END IF;

                                                   SELECT count(*)
                                                    INTO v_existe_cuenta
                                                    FROM FIN_PARAMETROS
                                                   WHERE sfinanci = v_sfinanci
                                                     AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                     AND cparam = 'ASIGNADO';

                                                 IF v_existe_cuenta = 0 THEN
                                                  INSERT INTO FIN_PARAMETROS
                                                              (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                                                       VALUES (v_sfinanci, (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')), 'ASIGNADO', f_user, f_sysdate, f_user, f_sysdate, null, null, ext.INVSUPLCAP);
                                                 ELSE
                                                     UPDATE FIN_PARAMETROS
                                                        SET tvalpar = ext.INVSUPLCAP
                                                      WHERE sfinanci = v_sfinanci
                                                        AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                        AND cparam = 'ASIGNADO';
                                                 END IF;


                                          END IF;


                                   IF ext.feccordeclrenta IS NOT NULL THEN
                                        SELECT count(*)
                                          INTO v_existe_d_renta
                                          FROM FIN_D_RENTA
                                         WHERE sfinanci = v_sfinanci
                                           AND   fcorte = TO_DATE(ext.feccordeclrenta,'DD/MM/YYYY');

                                           IF v_existe_d_renta = 0 THEN
                                                    INSERT INTO FIN_D_RENTA
                                                                (sfinanci, fcorte, cesvalor, ipatriliq, irenta)
                                                         VALUES (v_sfinanci, TO_DATE(ext.feccordeclrenta,'DD/MM/YYYY'), '1', ext.patriliquido, ext.renliqgrav);
                                           ELSE
                                                      UPDATE FIN_D_RENTA
                                                         SET ipatriliq = ext.patriliquido,
                                                                irenta = ext.renliqgrav
                                                        WHERE sfinanci = v_sfinanci
                                                          AND   fcorte = TO_DATE(ext.feccordeclrenta,'DD/MM/YYYY');
                                           END IF;
                                    END IF;

                                 END IF;
                            END LOOP;

            v_pasexec := 1;
            COMMIT;
            RETURN 0;
         EXCEPTION
            WHEN OTHERS THEN
               ROLLBACK;
               pdeserror := f_axis_literales(103187, pac_md_common.f_get_cxtidioma) || SQLERRM;
               p_tab_error(f_sysdate, f_user, vobj, v_pasexec, SQLCODE, SQLERRM, 10);
               RETURN 1;
         END f_trasp_tabla;
      --
      BEGIN
         vtraza := 0;

         IF psproces IS NULL THEN
            SELECT sproces.NEXTVAL
              INTO psproces
              FROM DUAL;
         END IF;

         vtraza := 1;

         IF p_cproces IS NULL THEN
            vnum_err := 9901092;
            vdeserror := 'cfg_files falta proceso: ' || vobj;
            RAISE e_errdatos;
         END IF;

         --
         vtraza := 2;
         --
         vnum_err := f_modi_tabla_ext(p_nombre, p_path);

         IF vnum_err <> 0 THEN
            p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                        'Error creando la tabla externa', 10);
            RAISE errorini;
         END IF;

         vnum_err := f_trasp_tabla(vdeserror, psproces);
         vtraza := 3;

         IF vnum_err <> 0 THEN
            --
            vtraza := 5;
            vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces, p_nombre,
                                                                       f_sysdate, NULL, 1,
                                                                       p_cproces, NULL,
                                                                       vdeserror, 0);
            vtraza := 51;

            IF vnum_err <> 0 THEN
               p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                           'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera',
                           10);
               RAISE errorini;
            END IF;

            vtraza := 52;
            RAISE vsalir;
         END IF;

         RETURN 0;
      EXCEPTION
         WHEN vsalir THEN
            RETURN 103187;
         WHEN e_errdatos THEN
            ROLLBACK;
            p_genera_logs(vobj, vtraza, 'Error:' || vnum_err, vdeserror);
            RETURN vnum_err;
         WHEN errorini THEN
            ROLLBACK;
            p_genera_logs(vobj, vtraza, 'Error:' || 'ErrorIni' || ' en :' || 1,
                          'Error:' || 'Insertando estados registros');
            RETURN 1;
         WHEN OTHERS THEN
            ROLLBACK;
            p_genera_logs(vobj, vtraza, 'Error:' || 'ErrorIni en 1',
                          'Error: Insertando estados registros');
            vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces, p_nombre,
                                                                       f_sysdate, NULL, 1,
                                                                       p_cproces, 151541,
                                                                       SQLERRM, 0);
            vtraza := 51;

            IF vnum_err <> 0 THEN
               p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                           'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera',
                           10);
            END IF;

            RETURN 1;
      END f_ejecutar_carga_fichero;

   --
   BEGIN
      vtraza := 0;

      IF pjob = 1 THEN
         vnum_err :=
            pac_contexto.f_inicializarctx
                   (NVL(pcusuari,
                        pac_parametros.f_parempresa_t(NVL(pac_md_common.f_get_cxtempresa,
                                                          f_parinstalacion_n('EMPRESADEF')),
                                                      'USER_BBDD')));
      END IF;

      IF psproces IS NULL
         OR(psproces IS NOT NULL
            AND pjob = 1) THEN
         vnum_err := f_ejecutar_carga_fichero(p_nombre, p_path, p_cproces, psproces);

         IF vnum_err <> 0 THEN
            RAISE vsalir;
         END IF;
      END IF;

      --
      vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces, p_nombre, f_sysdate,
                                                                 NULL, 3, p_cproces, NULL,
                                                                 NULL, 1);

      IF vnum_err <> 0 THEN
         p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                     'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera', 10);
         RAISE vsalir;
      END IF;

      FOR reg IN infcolombiais LOOP
         vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces => psproces,
                                                                 pnlinea => reg.nlinea,
                                                                 pctipo => 20,
                                                                 pidint => reg.nlinea,
                                                                 pidext => reg.nlinea,
                                                                 pcestado => 4,
                                                                 pcvalidado => NULL,
                                                                 psseguro => NULL,
                                                                 pidexterno => NULL,
                                                                 pncarga => NULL,
                                                                 pnsinies => NULL,
                                                                 pntramit => NULL,
                                                                 psperson => NULL,
                                                                 pnrecibo => NULL);
      END LOOP;

      UPDATE int_carga_ctrl
         SET cestado = vnum_err,
             ffin = f_sysdate,
             cbloqueo = 0
       WHERE sproces = psproces;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN vsalir THEN
         RETURN vnum_err;
   END f_carga_informa_colombia;
   --FIN -IAXIS-51545 - JLTS - 04/09/2019 */

   --
   /* --INI -IAXIS-51545 - JLTS - 04/09/2019
     FUNCTION f_informa_colombia(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN VARCHAR2,
      psproces IN OUT NUMBER)
      RETURN NUMBER IS
      vmensaje       NUMBER;
   BEGIN
      --
      IF psproces IS NULL THEN
         SELECT sproces.NEXTVAL
           INTO psproces
           FROM DUAL;

         vmensaje := pac_cargas_conf.f_carga_informa_colombia(p_nombre, p_path, p_cproces,
                                                              psproces, 1, f_user);

         IF vmensaje <> 0 THEN
            RETURN 180856;
         END IF;
      END IF;

      --
      RETURN 0;
   END f_informa_colombia;*/
    --

    /*FUNCTION f_carga_supersociedades(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER,
      pjob IN NUMBER DEFAULT 0,
      pcusuari IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'pac_cargas_conf.f_carga_supersociedades';
      vtraza         NUMBER := 0;
      vnum_err       NUMBER := 0;
      vsalir         EXCEPTION;

      --
      CURSOR infcolombiais IS
         SELECT r.*
           FROM int_carga_informacol r
          WHERE r.proceso = psproces;

      --
      FUNCTION f_ejecutar_carga_fichero(
         p_nombre IN VARCHAR2,
         p_path IN VARCHAR2,
         p_cproces IN NUMBER,
         psproces IN OUT NUMBER)
         RETURN NUMBER IS
         vobj           VARCHAR2(100) := 'f_ejecutar_carga_fichero';
         vtraza         NUMBER := 0;
         vdeserror      VARCHAR2(1000);
         errorini       EXCEPTION;
         vnum_err       NUMBER := 0;
         vsalir         EXCEPTION;

         --
         FUNCTION f_modi_tabla_ext(p_nombre VARCHAR2, p_path IN VARCHAR2)
            RETURN NUMBER IS
            v_iteraciones  NUMBER(2);
            k_iteraciones  NUMBER(2) := 10;
         BEGIN
            v_iteraciones := 1;

            LOOP
               BEGIN
                  LOCK TABLE int_carga_informacol_ext IN EXCLUSIVE MODE;

                  EXECUTE IMMEDIATE 'ALTER TABLE int_carga_informacol_ext LOCATION ('
                                    || p_path || ':''' || p_nombre || ''')';

                  EXIT;
               EXCEPTION
                  WHEN OTHERS THEN
                     p_tab_error(f_sysdate, f_user, 'f_modi_tabla_ext', v_iteraciones,
                                 'Error modificando tabla. Reintento.', SQLERRM, 10);

                     IF k_iteraciones <= v_iteraciones THEN
                        RAISE;
                     END IF;

                     v_iteraciones := v_iteraciones + 1;
               END;
            END LOOP;

            LOCK TABLE int_carga_informacol_ext IN EXCLUSIVE MODE;
            RETURN 0;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'pac_cargas_conf.f_modi_tabla_ext', 1,
                           'Error creando la tabla.', SQLERRM, 10);
               RETURN 103865;
         END f_modi_tabla_ext;

         --
         FUNCTION f_trasp_tabla(pdeserror OUT VARCHAR2, psproces IN NUMBER)
            RETURN NUMBER IS
            v_pasexec           NUMBER := 1;
            vobj                VARCHAR2(200) := 'pac_cargas_conf.f_trasp_tabla';
            v_numlin            int_carga_informacol.nlinea%TYPE;
             v_existe_sfianci NUMBER := 0;
             v_existe_indicad NUMBER := 0;
             v_existe_superso NUMBER := 0;
              v_conta_superso NUMBER := 0;
             v_existe_d_renta NUMBER := 0;
                        v_nit int_carga_informacol.nit%TYPE;
                   v_sfinanci NUMBER := 0;
                    v_nmovimi NUMBER := 0;
              v_existe_cuenta NUMBER := 0;


         BEGIN
            v_pasexec := 0;
            pdeserror := NULL;

            SELECT NVL(MAX(nlinea), 0)
              INTO v_numlin
              FROM int_carga_informacol
             WHERE proceso = psproces;

            INSERT      \*+ APPEND *\INTO int_carga_informacol
                        (proceso, nlinea, ncarga, tipo_oper, nit, nombre, tiposociedad,
                         reprelegal, revfiscal, estempresa, objsocial, fechacons, vigsociedad,
                         limreplegal, incjudicial, nomaccionista1, nomaccionista2,
                         nomaccionista3, nomaccionista4, nitaccionista1, nitaccionista2,
                         nitaccionista3, nitaccionista4, partaccionista1, partaccionista2,
                         partaccionista3, partaccionista4, ciiu, fuenteinf, moneda, valmiles,
                         fecestfinan, ventas, ventasperant, costoventas, gastosadm,
                         utloperacional, gastosfinan, resultantimp, utlneta, inventario,
                         cartcliente, actcorriente, totactnocorriente, propplanequipo,
                         otrosactivos, activototal, obligfinancp, proveedorescp, anticipocp,
                         pascorriente, obligfinanlp, anticipolp, totpascorriente, pastotal,
                         patriperant, patrianoact, capsocial, pricolacc, invsuplcap, reslegal,
                         resocasional, resejerant, valorizacion, feccamcomercio, fotrut,
                         fecrut, fotcedula, fecexpcedula, ciuexpcedula, feccordeclrenta,
                         patriliquido, renliqgrav, origencarga)
               (SELECT psproces proceso, ROWNUM + v_numlin nlinea, NULL ncarga, NULL tipo_oper,
                       nit, nombre, tiposociedad, reprelegal, revfiscal, estempresa, objsocial,
                       fechacons, vigsociedad, limreplegal, incjudicial, nomaccionista1,
                       nomaccionista2, nomaccionista3, nomaccionista4, nitaccionista1,
                       nitaccionista2, nitaccionista3, nitaccionista4, partaccionista1,
                       partaccionista2, partaccionista3, partaccionista4, ciiu, fuenteinf,
                       moneda, valmiles, fecestfinan, ventas, ventasperant, costoventas,
                       gastosadm, utloperacional, gastosfinan, resultantimp, utlneta,
                       inventario, cartcliente, actcorriente, totactnocorriente,
                       propplanequipo, otrosactivos, activototal, obligfinancp, proveedorescp,
                       anticipocp, pascorriente, obligfinanlp, anticipolp, totpascorriente,
                       pastotal, patriperant, patrianoact, capsocial, pricolacc, invsuplcap,
                       reslegal, resocasional, resejerant, valorizacion, feccamcomercio,
                       fotrut, fecrut, fotcedula, fecexpcedula, ciuexpcedula, feccordeclrenta,
                       patriliquido, renliqgrav, 'ARC'
                  FROM int_carga_informacol_ext);


                FOR ext IN(select e.*
                             from int_carga_informacol_ext e
                           ) LOOP

                         SELECT count(SFINANCI)
                          INTO v_existe_sfianci
                          FROM FIN_GENERAL fg
                         WHERE fg.SPERSON in(select pp.SPERSON
                                               from PER_PERSONAS pp
                                              where pp.NNUMIDE
                                               like ext.nit || '%');

                       IF v_existe_sfianci > 0 THEN

                        SELECT SFINANCI
                          INTO v_sfinanci
                          FROM FIN_GENERAL fg
                         WHERE fg.SPERSON in(select pp.SPERSON
                                               from PER_PERSONAS pp
                                              where pp.NNUMIDE
                                               like ext.nit || '%');

                                  UPDATE FIN_GENERAL
                                     SET tdescrip = 'Ficha tecnica ' || ext.NOMBRE,
                                         cfotorut = ext.FOTRUT,
                                             frut = TO_DATE(ext.FECRUT,'DD/MM/YYYY'),
                                         cfotoced = ext.FOTCEDULA,
                                         fexpiced = TO_DATE(ext.FECEXPCEDULA,'DD/MM/YYYY'),
                                            cciiu = ext.CIIU,
                                         ctipsoci = ext.TIPOSOCIEDAD,
                                          cestsoc = (select CATRIBU
                                                      from  DETVALORES
                                                      where cidioma = 8
                                                       and cvalor = '8001074'
                                                       and UPPER(TATRIBU)
                                                      like ext.ESTEMPRESA),
                                          tobjsoc = ext.OBJSOCIAL,
                                          fconsti = TO_DATE(ext.FECHACONS,'DD/MM/YYYY'),
                                          tvigenc = ext.VIGSOCIEDAD,
                                          fccomer = TO_DATE(ext.FECCAMCOMERCIO,'DD/MM/YYYY')
                                   WHERE sfinanci = v_sfinanci;



                                  SELECT count(*)
                                    INTO v_existe_indicad
                                    FROM FIN_INDICADORES
                                   WHERE sfinanci = v_sfinanci
                                     and findicad = TO_DATE(ext.fecestfinan,'DD/MM/YYYY');

                                  IF v_existe_indicad > 0 THEN

                                     FOR fin_indica IN(select fi.*
                                                         from fin_indicadores fi
                                                        where fi.sfinanci = v_sfinanci
                                                          and fi.findicad = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')
                                                         ) LOOP

                                          SELECT count(*)
                                            INTO v_existe_superso
                                            FROM fin_parametros fp
                                           WHERE fp.sfinanci = v_sfinanci
                                             and  fp.nmovimi = fin_indica.nmovimi
                                             and   fp.cparam = 'FUENTE_INFORMACION'
                                             and  fp.nvalpar = 3;

                                          v_conta_superso := v_conta_superso + v_existe_superso;

                                      END LOOP;

                                   END IF;



                                   IF v_existe_indicad = 0 OR v_conta_superso = 0 THEN

                                      INSERT INTO FIN_INDICADORES
                                                  (sfinanci, nmovimi, findicad, imargen, icaptrab,
                                                    trazcor, tprbaci, ienduada, ndiacar, nrotpro,
                                                    nrotinv, ndiacicl, irentab, ioblcp, iobllp,
                                                   igastfin, ivalpt, cesvalor, cmoneda, fcupo,
                                                     icupog, icupos, fcupos, tcupor, tconcepc,
                                                   tconceps, tcburea, tcotros, cmoncam, ncapfin)
                                          VALUES (v_sfinanci, nmovimi.nextval,  TO_DATE(ext.fecestfinan,'DD/MM/YYYY'), null, null,
                                                   null, null, null, null, null,
                                                   null, null, null, null, null,
                                                   null, null, '1', 'COP', null,
                                                   null, null, null, null, null,
                                                   null, null, null, null, null);



                                                  SELECT count(*)
                                                    INTO v_existe_cuenta
                                                    FROM FIN_PARAMETROS
                                                   WHERE sfinanci = v_sfinanci
                                                     AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                     AND cparam = 'FUENTE_INFORMACION';

                                                 IF v_existe_cuenta = 0 THEN
                                                  INSERT INTO FIN_PARAMETROS
                                                              (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                                                       VALUES (v_sfinanci, (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')), 'FUENTE_INFORMACION', f_user, f_sysdate, f_user, f_sysdate, null, 3, null);
                                                 ELSE
                                                     UPDATE FIN_PARAMETROS
                                                        SET nvalpar = 3
                                                      WHERE sfinanci = v_sfinanci
                                                        AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                        AND cparam = 'FUENTE_INFORMACION';
                                                 END IF;

                                                  SELECT count(*)
                                                    INTO v_existe_cuenta
                                                    FROM FIN_PARAMETROS
                                                   WHERE sfinanci = v_sfinanci
                                                     AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                     AND cparam = 'FECHA_EST_FIN';

                                                 IF v_existe_cuenta = 0 THEN
                                                  INSERT INTO FIN_PARAMETROS
                                                              (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                                                       VALUES (v_sfinanci, (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')), 'FECHA_EST_FIN', f_user, f_sysdate, f_user, f_sysdate, TO_DATE(ext.fecestfinan,'DD/MM/YYYY'), null, null);
                                                 ELSE
                                                     UPDATE FIN_PARAMETROS
                                                        SET fvalpar = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')
                                                      WHERE sfinanci = v_sfinanci
                                                        AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                        AND cparam = 'FECHA_EST_FIN';
                                                 END IF;

                                                  SELECT count(*)
                                                    INTO v_existe_cuenta
                                                    FROM FIN_PARAMETROS
                                                   WHERE sfinanci = v_sfinanci
                                                     AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                     AND cparam = 'VT_PER_ANT';

                                                 IF v_existe_cuenta = 0 THEN
                                                  INSERT INTO FIN_PARAMETROS
                                                              (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                                                       VALUES (v_sfinanci, (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')), 'VT_PER_ANT', f_user, f_sysdate, f_user, f_sysdate, null, null, ext.VENTASPERANT);
                                                 ELSE
                                                     UPDATE FIN_PARAMETROS
                                                        SET tvalpar = ext.VENTASPERANT
                                                      WHERE sfinanci = v_sfinanci
                                                        AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                        AND cparam = 'VT_PER_ANT';
                                                 END IF;

                                                     SELECT count(*)
                                                    INTO v_existe_cuenta
                                                    FROM FIN_PARAMETROS
                                                   WHERE sfinanci = v_sfinanci
                                                     AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                     AND cparam = 'VENTAS';

                                                 IF v_existe_cuenta = 0 THEN
                                                  INSERT INTO FIN_PARAMETROS
                                                              (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                                                       VALUES (v_sfinanci, (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')), 'VENTAS', f_user, f_sysdate, f_user, f_sysdate, null, null, ext.VENTAS);
                                                 ELSE
                                                     UPDATE FIN_PARAMETROS
                                                        SET tvalpar = ext.VENTAS
                                                      WHERE sfinanci = v_sfinanci
                                                        AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                        AND cparam = 'VENTAS';
                                                 END IF;


                                                   SELECT count(*)
                                                    INTO v_existe_cuenta
                                                    FROM FIN_PARAMETROS
                                                   WHERE sfinanci = v_sfinanci
                                                     AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                     AND cparam = 'COSTO_VT';

                                                 IF v_existe_cuenta = 0 THEN
                                                  INSERT INTO FIN_PARAMETROS
                                                              (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                                                       VALUES (v_sfinanci, (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')), 'COSTO_VT', f_user, f_sysdate, f_user, f_sysdate, null, null, ext.COSTOVENTAS);
                                                 ELSE
                                                     UPDATE FIN_PARAMETROS
                                                        SET tvalpar = ext.COSTOVENTAS
                                                      WHERE sfinanci = v_sfinanci
                                                        AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                        AND cparam = 'COSTO_VT';
                                                 END IF;


                                                    SELECT count(*)
                                                    INTO v_existe_cuenta
                                                    FROM FIN_PARAMETROS
                                                   WHERE sfinanci = v_sfinanci
                                                     AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                     AND cparam = 'GASTO_ADM';

                                                 IF v_existe_cuenta = 0 THEN
                                                  INSERT INTO FIN_PARAMETROS
                                                              (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                                                       VALUES (v_sfinanci, (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')), 'GASTO_ADM', f_user, f_sysdate, f_user, f_sysdate, null, null, ext.GASTOSADM);
                                                 ELSE
                                                     UPDATE FIN_PARAMETROS
                                                        SET tvalpar = ext.GASTOSADM
                                                      WHERE sfinanci = v_sfinanci
                                                        AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                        AND cparam = 'GASTO_ADM';
                                                 END IF;


                                                  SELECT count(*)
                                                    INTO v_existe_cuenta
                                                    FROM FIN_PARAMETROS
                                                   WHERE sfinanci = v_sfinanci
                                                     AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                     AND cparam = 'UTIL_OPERAC';

                                                 IF v_existe_cuenta = 0 THEN
                                                  INSERT INTO FIN_PARAMETROS
                                                              (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                                                       VALUES (v_sfinanci, (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')), 'UTIL_OPERAC', f_user, f_sysdate, f_user, f_sysdate, null, null, ext.UTLOPERACIONAL);
                                                 ELSE
                                                     UPDATE FIN_PARAMETROS
                                                        SET tvalpar = ext.UTLOPERACIONAL
                                                      WHERE sfinanci = v_sfinanci
                                                        AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                        AND cparam = 'UTIL_OPERAC';
                                                 END IF;

                                                    SELECT count(*)
                                                    INTO v_existe_cuenta
                                                    FROM FIN_PARAMETROS
                                                   WHERE sfinanci = v_sfinanci
                                                     AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                     AND cparam = 'GASTO_FIN';

                                                 IF v_existe_cuenta = 0 THEN
                                                  INSERT INTO FIN_PARAMETROS
                                                              (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                                                       VALUES (v_sfinanci, (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')), 'GASTO_FIN', f_user, f_sysdate, f_user, f_sysdate, null, null, ext.GASTOSFINAN);
                                                 ELSE
                                                     UPDATE FIN_PARAMETROS
                                                        SET tvalpar = ext.GASTOSFINAN
                                                      WHERE sfinanci = v_sfinanci
                                                        AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                        AND cparam = 'GASTO_FIN';
                                                 END IF;

                                                   SELECT count(*)
                                                    INTO v_existe_cuenta
                                                    FROM FIN_PARAMETROS
                                                   WHERE sfinanci = v_sfinanci
                                                     AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                     AND cparam = 'GASTO_FIN';

                                                 IF v_existe_cuenta = 0 THEN
                                                  INSERT INTO FIN_PARAMETROS
                                                              (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                                                       VALUES (v_sfinanci, (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')), 'GASTO_FIN', f_user, f_sysdate, f_user, f_sysdate, null, null, ext.GASTOSFINAN);
                                                 ELSE
                                                     UPDATE FIN_PARAMETROS
                                                        SET tvalpar = ext.GASTOSFINAN
                                                      WHERE sfinanci = v_sfinanci
                                                        AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                        AND cparam = 'GASTO_FIN';
                                                 END IF;

                                                  SELECT count(*)
                                                    INTO v_existe_cuenta
                                                    FROM FIN_PARAMETROS
                                                   WHERE sfinanci = v_sfinanci
                                                     AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                     AND cparam = 'RES_ANT_IMP';

                                                 IF v_existe_cuenta = 0 THEN
                                                  INSERT INTO FIN_PARAMETROS
                                                              (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                                                       VALUES (v_sfinanci, (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')), 'RES_ANT_IMP', f_user, f_sysdate, f_user, f_sysdate, null, null, ext.RESULTANTIMP);
                                                 ELSE
                                                     UPDATE FIN_PARAMETROS
                                                        SET tvalpar = ext.RESULTANTIMP
                                                      WHERE sfinanci = v_sfinanci
                                                        AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                        AND cparam = 'RES_ANT_IMP';
                                                 END IF;


                                                   SELECT count(*)
                                                    INTO v_existe_cuenta
                                                    FROM FIN_PARAMETROS
                                                   WHERE sfinanci = v_sfinanci
                                                     AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                     AND cparam = 'UTIL_NETA';

                                                 IF v_existe_cuenta = 0 THEN
                                                  INSERT INTO FIN_PARAMETROS
                                                              (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                                                       VALUES (v_sfinanci, (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')), 'UTIL_NETA', f_user, f_sysdate, f_user, f_sysdate, null, null, ext.UTLNETA);
                                                 ELSE
                                                     UPDATE FIN_PARAMETROS
                                                        SET tvalpar = ext.UTLNETA
                                                      WHERE sfinanci = v_sfinanci
                                                        AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                        AND cparam = 'UTIL_NETA';
                                                 END IF;

                                                 SELECT count(*)
                                                    INTO v_existe_cuenta
                                                    FROM FIN_PARAMETROS
                                                   WHERE sfinanci = v_sfinanci
                                                     AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                     AND cparam = 'INVENT';

                                                 IF v_existe_cuenta = 0 THEN
                                                  INSERT INTO FIN_PARAMETROS
                                                              (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                                                       VALUES (v_sfinanci, (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')), 'INVENT', f_user, f_sysdate, f_user, f_sysdate, null, null, ext.INVENTARIO);
                                                 ELSE
                                                     UPDATE FIN_PARAMETROS
                                                        SET tvalpar = ext.INVENTARIO
                                                      WHERE sfinanci = v_sfinanci
                                                        AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                        AND cparam = 'INVENT';
                                                 END IF;


                                                   SELECT count(*)
                                                    INTO v_existe_cuenta
                                                    FROM FIN_PARAMETROS
                                                   WHERE sfinanci = v_sfinanci
                                                     AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                     AND cparam = 'CARTE_CLIE';

                                                 IF v_existe_cuenta = 0 THEN
                                                  INSERT INTO FIN_PARAMETROS
                                                              (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                                                       VALUES (v_sfinanci, (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')), 'CARTE_CLIE', f_user, f_sysdate, f_user, f_sysdate, null, null, ext.CARTCLIENTE);
                                                 ELSE
                                                     UPDATE FIN_PARAMETROS
                                                        SET tvalpar = ext.CARTCLIENTE
                                                      WHERE sfinanci = v_sfinanci
                                                        AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                        AND cparam = 'CARTE_CLIE';
                                                 END IF;


                                                   SELECT count(*)
                                                    INTO v_existe_cuenta
                                                    FROM FIN_PARAMETROS
                                                   WHERE sfinanci = v_sfinanci
                                                     AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                     AND cparam = 'ACT_CORR';

                                                 IF v_existe_cuenta = 0 THEN
                                                  INSERT INTO FIN_PARAMETROS
                                                              (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                                                       VALUES (v_sfinanci, (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')), 'ACT_CORR', f_user, f_sysdate, f_user, f_sysdate, null, null, ext.ACTCORRIENTE);
                                                 ELSE
                                                     UPDATE FIN_PARAMETROS
                                                        SET tvalpar = ext.ACTCORRIENTE
                                                      WHERE sfinanci = v_sfinanci
                                                        AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                        AND cparam = 'ACT_CORR';
                                                 END IF;


                                                     SELECT count(*)
                                                    INTO v_existe_cuenta
                                                    FROM FIN_PARAMETROS
                                                   WHERE sfinanci = v_sfinanci
                                                     AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                     AND cparam = 'PROP_PLNT_EQP';

                                                 IF v_existe_cuenta = 0 THEN
                                                  INSERT INTO FIN_PARAMETROS
                                                              (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                                                       VALUES (v_sfinanci, (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')), 'PROP_PLNT_EQP', f_user, f_sysdate, f_user, f_sysdate, null, null, ext.PROPPLANEQUIPO);
                                                 ELSE
                                                     UPDATE FIN_PARAMETROS
                                                        SET tvalpar = ext.PROPPLANEQUIPO
                                                      WHERE sfinanci = v_sfinanci
                                                        AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                        AND cparam = 'PROP_PLNT_EQP';
                                                 END IF;

                                                   SELECT count(*)
                                                    INTO v_existe_cuenta
                                                    FROM FIN_PARAMETROS
                                                   WHERE sfinanci = v_sfinanci
                                                     AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                     AND cparam = 'TOT_ACT_NO_CORR';

                                                 IF v_existe_cuenta = 0 THEN
                                                  INSERT INTO FIN_PARAMETROS
                                                              (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                                                       VALUES (v_sfinanci, (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')), 'TOT_ACT_NO_CORR', f_user, f_sysdate, f_user, f_sysdate, null, null, ext.TOTACTNOCORRIENTE);
                                                 ELSE
                                                     UPDATE FIN_PARAMETROS
                                                        SET tvalpar = ext.TOTACTNOCORRIENTE
                                                      WHERE sfinanci = v_sfinanci
                                                        AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                        AND cparam = 'TOT_ACT_NO_CORR';
                                                 END IF;


                                                    SELECT count(*)
                                                    INTO v_existe_cuenta
                                                    FROM FIN_PARAMETROS
                                                   WHERE sfinanci = v_sfinanci
                                                     AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                     AND cparam = 'ACT_TOTAL';

                                                 IF v_existe_cuenta = 0 THEN
                                                  INSERT INTO FIN_PARAMETROS
                                                              (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                                                       VALUES (v_sfinanci, (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')), 'ACT_TOTAL', f_user, f_sysdate, f_user, f_sysdate, null, null, ext.ACTIVOTOTAL);
                                                 ELSE
                                                     UPDATE FIN_PARAMETROS
                                                        SET tvalpar = ext.ACTIVOTOTAL
                                                      WHERE sfinanci = v_sfinanci
                                                        AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                        AND cparam = 'ACT_TOTAL';
                                                 END IF;


                                                    SELECT count(*)
                                                    INTO v_existe_cuenta
                                                    FROM FIN_PARAMETROS
                                                   WHERE sfinanci = v_sfinanci
                                                     AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                     AND cparam = 'O_FIN_CORTO_PLAZO';

                                                 IF v_existe_cuenta = 0 THEN
                                                  INSERT INTO FIN_PARAMETROS
                                                              (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                                                       VALUES (v_sfinanci, (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')), 'O_FIN_CORTO_PLAZO', f_user, f_sysdate, f_user, f_sysdate, null, null, ext.OBLIGFINANCP);
                                                 ELSE
                                                     UPDATE FIN_PARAMETROS
                                                        SET tvalpar = ext.OBLIGFINANCP
                                                      WHERE sfinanci = v_sfinanci
                                                        AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                        AND cparam = 'O_FIN_CORTO_PLAZO';
                                                 END IF;


                                                  SELECT count(*)
                                                    INTO v_existe_cuenta
                                                    FROM FIN_PARAMETROS
                                                   WHERE sfinanci = v_sfinanci
                                                     AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                     AND cparam = 'PROVEE_CORTO_PLAZO';

                                                 IF v_existe_cuenta = 0 THEN
                                                  INSERT INTO FIN_PARAMETROS
                                                              (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                                                       VALUES (v_sfinanci, (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')), 'PROVEE_CORTO_PLAZO', f_user, f_sysdate, f_user, f_sysdate, null, null, ext.PROVEEDORESCP);
                                                 ELSE
                                                     UPDATE FIN_PARAMETROS
                                                        SET tvalpar = ext.PROVEEDORESCP
                                                      WHERE sfinanci = v_sfinanci
                                                        AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                        AND cparam = 'PROVEE_CORTO_PLAZO';
                                                 END IF;


                                                    SELECT count(*)
                                                    INTO v_existe_cuenta
                                                    FROM FIN_PARAMETROS
                                                   WHERE sfinanci = v_sfinanci
                                                     AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                     AND cparam = 'ATC_CORTO_PLAZO';

                                                 IF v_existe_cuenta = 0 THEN
                                                  INSERT INTO FIN_PARAMETROS
                                                              (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                                                       VALUES (v_sfinanci, (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')), 'ATC_CORTO_PLAZO', f_user, f_sysdate, f_user, f_sysdate, null, null, ext.PROVEEDORESCP);
                                                 ELSE
                                                     UPDATE FIN_PARAMETROS
                                                        SET tvalpar = ext.PROVEEDORESCP
                                                      WHERE sfinanci = v_sfinanci
                                                        AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                        AND cparam = 'ATC_CORTO_PLAZO';
                                                 END IF;


                                                    SELECT count(*)
                                                    INTO v_existe_cuenta
                                                    FROM FIN_PARAMETROS
                                                   WHERE sfinanci = v_sfinanci
                                                     AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                     AND cparam = 'ATC_CORTO_PLAZO';

                                                 IF v_existe_cuenta = 0 THEN
                                                  INSERT INTO FIN_PARAMETROS
                                                              (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                                                       VALUES (v_sfinanci, (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')), 'ATC_CORTO_PLAZO', f_user, f_sysdate, f_user, f_sysdate, null, null, ext.ANTICIPOCP);
                                                 ELSE
                                                     UPDATE FIN_PARAMETROS
                                                        SET tvalpar = ext.ANTICIPOCP
                                                      WHERE sfinanci = v_sfinanci
                                                        AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                        AND cparam = 'ATC_CORTO_PLAZO';
                                                 END IF;


                                                    SELECT count(*)
                                                    INTO v_existe_cuenta
                                                    FROM FIN_PARAMETROS
                                                   WHERE sfinanci = v_sfinanci
                                                     AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                     AND cparam = 'PAS_CORR';

                                                 IF v_existe_cuenta = 0 THEN
                                                  INSERT INTO FIN_PARAMETROS
                                                              (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                                                       VALUES (v_sfinanci, (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')), 'PAS_CORR', f_user, f_sysdate, f_user, f_sysdate, null, null, ext.PASCORRIENTE);
                                                 ELSE
                                                     UPDATE FIN_PARAMETROS
                                                        SET tvalpar = ext.PASCORRIENTE
                                                      WHERE sfinanci = v_sfinanci
                                                        AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                        AND cparam = 'PAS_CORR';
                                                 END IF;


                                                    SELECT count(*)
                                                    INTO v_existe_cuenta
                                                    FROM FIN_PARAMETROS
                                                   WHERE sfinanci = v_sfinanci
                                                     AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                     AND cparam = 'O_FIN_LARGO_PLAZO';

                                                 IF v_existe_cuenta = 0 THEN
                                                  INSERT INTO FIN_PARAMETROS
                                                              (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                                                       VALUES (v_sfinanci, (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')), 'O_FIN_LARGO_PLAZO', f_user, f_sysdate, f_user, f_sysdate, null, null, ext.OBLIGFINANLP);
                                                 ELSE
                                                     UPDATE FIN_PARAMETROS
                                                        SET tvalpar = ext.OBLIGFINANLP
                                                      WHERE sfinanci = v_sfinanci
                                                        AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                        AND cparam = 'O_FIN_LARGO_PLAZO';
                                                 END IF;


                                                 SELECT count(*)
                                                    INTO v_existe_cuenta
                                                    FROM FIN_PARAMETROS
                                                   WHERE sfinanci = v_sfinanci
                                                     AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                     AND cparam = 'ATC_LARGO_PLAZO';

                                                 IF v_existe_cuenta = 0 THEN
                                                  INSERT INTO FIN_PARAMETROS
                                                              (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                                                       VALUES (v_sfinanci, (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')), 'ATC_LARGO_PLAZO', f_user, f_sysdate, f_user, f_sysdate, null, null, ext.ANTICIPOLP);
                                                 ELSE
                                                     UPDATE FIN_PARAMETROS
                                                        SET tvalpar = ext.ANTICIPOLP
                                                      WHERE sfinanci = v_sfinanci
                                                        AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                        AND cparam = 'ATC_LARGO_PLAZO';
                                                 END IF;


                                                    SELECT count(*)
                                                    INTO v_existe_cuenta
                                                    FROM FIN_PARAMETROS
                                                   WHERE sfinanci = v_sfinanci
                                                     AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                     AND cparam = 'PAS_NO_CORR';

                                                 IF v_existe_cuenta = 0 THEN
                                                  INSERT INTO FIN_PARAMETROS
                                                              (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                                                       VALUES (v_sfinanci, (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')), 'PAS_NO_CORR', f_user, f_sysdate, f_user, f_sysdate, null, null, ext.TOTPASCORRIENTE);
                                                 ELSE
                                                     UPDATE FIN_PARAMETROS
                                                        SET tvalpar = ext.TOTPASCORRIENTE
                                                      WHERE sfinanci = v_sfinanci
                                                        AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                        AND cparam = 'PAS_NO_CORR';
                                                 END IF;


                                                   SELECT count(*)
                                                    INTO v_existe_cuenta
                                                    FROM FIN_PARAMETROS
                                                   WHERE sfinanci = v_sfinanci
                                                     AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                     AND cparam = 'PAS_TOTAL';

                                                 IF v_existe_cuenta = 0 THEN
                                                  INSERT INTO FIN_PARAMETROS
                                                              (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                                                       VALUES (v_sfinanci, (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')), 'PAS_TOTAL', f_user, f_sysdate, f_user, f_sysdate, null, null, ext.PASTOTAL);
                                                 ELSE
                                                     UPDATE FIN_PARAMETROS
                                                        SET tvalpar = ext.PASTOTAL
                                                      WHERE sfinanci = v_sfinanci
                                                        AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                        AND cparam = 'PAS_TOTAL';
                                                 END IF;



                                                   SELECT count(*)
                                                    INTO v_existe_cuenta
                                                    FROM FIN_PARAMETROS
                                                   WHERE sfinanci = v_sfinanci
                                                     AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                     AND cparam = 'PATRI_PERI_ANT';

                                                 IF v_existe_cuenta = 0 THEN
                                                  INSERT INTO FIN_PARAMETROS
                                                              (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                                                       VALUES (v_sfinanci, (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')), 'PATRI_PERI_ANT', f_user, f_sysdate, f_user, f_sysdate, null, null, ext.PATRIPERANT);
                                                 ELSE
                                                     UPDATE FIN_PARAMETROS
                                                        SET tvalpar = ext.PATRIPERANT
                                                      WHERE sfinanci = v_sfinanci
                                                        AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                        AND cparam = 'PATRI_PERI_ANT';
                                                 END IF;


                                                 SELECT count(*)
                                                    INTO v_existe_cuenta
                                                    FROM FIN_PARAMETROS
                                                   WHERE sfinanci = v_sfinanci
                                                     AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                     AND cparam = 'PATRI_ANO_ACTUAL';

                                                 IF v_existe_cuenta = 0 THEN
                                                  INSERT INTO FIN_PARAMETROS
                                                              (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                                                       VALUES (v_sfinanci, (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')), 'PATRI_ANO_ACTUAL', f_user, f_sysdate, f_user, f_sysdate, null, null, ext.PATRIANOACT);
                                                 ELSE
                                                     UPDATE FIN_PARAMETROS
                                                        SET tvalpar = ext.PATRIANOACT
                                                      WHERE sfinanci = v_sfinanci
                                                        AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                        AND cparam = 'PATRI_ANO_ACTUAL';
                                                 END IF;


                                                   SELECT count(*)
                                                    INTO v_existe_cuenta
                                                    FROM FIN_PARAMETROS
                                                   WHERE sfinanci = v_sfinanci
                                                     AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                     AND cparam = 'RESV_LEGAL';

                                                 IF v_existe_cuenta = 0 THEN
                                                  INSERT INTO FIN_PARAMETROS
                                                              (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                                                       VALUES (v_sfinanci, (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')), 'RESV_LEGAL', f_user, f_sysdate, f_user, f_sysdate, null, null, ext.RESLEGAL);
                                                 ELSE
                                                     UPDATE FIN_PARAMETROS
                                                        SET tvalpar = ext.RESLEGAL
                                                      WHERE sfinanci = v_sfinanci
                                                        AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                        AND cparam = 'RESV_LEGAL';
                                                 END IF;


                                                  SELECT count(*)
                                                    INTO v_existe_cuenta
                                                    FROM FIN_PARAMETROS
                                                   WHERE sfinanci = v_sfinanci
                                                     AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                     AND cparam = 'CAP_SOCIAL';

                                                 IF v_existe_cuenta = 0 THEN
                                                  INSERT INTO FIN_PARAMETROS
                                                              (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                                                       VALUES (v_sfinanci, (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')), 'CAP_SOCIAL', f_user, f_sysdate, f_user, f_sysdate, null, null, ext.CAPSOCIAL);
                                                 ELSE
                                                     UPDATE FIN_PARAMETROS
                                                        SET tvalpar = ext.CAPSOCIAL
                                                      WHERE sfinanci = v_sfinanci
                                                        AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                        AND cparam = 'CAP_SOCIAL';
                                                 END IF;

                                                 SELECT count(*)
                                                    INTO v_existe_cuenta
                                                    FROM FIN_PARAMETROS
                                                   WHERE sfinanci = v_sfinanci
                                                     AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                     AND cparam = 'RES_EJER_ANT';

                                                 IF v_existe_cuenta = 0 THEN
                                                  INSERT INTO FIN_PARAMETROS
                                                              (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                                                       VALUES (v_sfinanci, (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')), 'RES_EJER_ANT', f_user, f_sysdate, f_user, f_sysdate, null, null, ext.RESEJERANT);
                                                 ELSE
                                                     UPDATE FIN_PARAMETROS
                                                        SET tvalpar = ext.RESEJERANT
                                                      WHERE sfinanci = v_sfinanci
                                                        AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                        AND cparam = 'RES_EJER_ANT';
                                                 END IF;


                                                  SELECT count(*)
                                                    INTO v_existe_cuenta
                                                    FROM FIN_PARAMETROS
                                                   WHERE sfinanci = v_sfinanci
                                                     AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                     AND cparam = 'PRIMA_ACCION';

                                                 IF v_existe_cuenta = 0 THEN
                                                  INSERT INTO FIN_PARAMETROS
                                                              (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                                                       VALUES (v_sfinanci, (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')), 'PRIMA_ACCION', f_user, f_sysdate, f_user, f_sysdate, null, null, ext.PRICOLACC);
                                                 ELSE
                                                     UPDATE FIN_PARAMETROS
                                                        SET tvalpar = ext.PRICOLACC
                                                      WHERE sfinanci = v_sfinanci
                                                        AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                        AND cparam = 'PRIMA_ACCION';
                                                 END IF;


                                                   SELECT count(*)
                                                    INTO v_existe_cuenta
                                                    FROM FIN_PARAMETROS
                                                   WHERE sfinanci = v_sfinanci
                                                     AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                     AND cparam = 'RESV_OCASI';

                                                 IF v_existe_cuenta = 0 THEN
                                                  INSERT INTO FIN_PARAMETROS
                                                              (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                                                       VALUES (v_sfinanci, (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')), 'RESV_OCASI', f_user, f_sysdate, f_user, f_sysdate, null, null, ext.RESOCASIONAL);
                                                 ELSE
                                                     UPDATE FIN_PARAMETROS
                                                        SET tvalpar = ext.RESOCASIONAL
                                                      WHERE sfinanci = v_sfinanci
                                                        AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                        AND cparam = 'RESV_OCASI';
                                                 END IF;


                                                   SELECT count(*)
                                                    INTO v_existe_cuenta
                                                    FROM FIN_PARAMETROS
                                                   WHERE sfinanci = v_sfinanci
                                                     AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                     AND cparam = 'VALORIZA';

                                                 IF v_existe_cuenta = 0 THEN
                                                  INSERT INTO FIN_PARAMETROS
                                                              (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                                                       VALUES (v_sfinanci, (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')), 'VALORIZA', f_user, f_sysdate, f_user, f_sysdate, null, null, ext.VALORIZACION);
                                                 ELSE
                                                     UPDATE FIN_PARAMETROS
                                                        SET tvalpar = ext.VALORIZACION
                                                      WHERE sfinanci = v_sfinanci
                                                        AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                        AND cparam = 'VALORIZA';
                                                 END IF;

                                                   SELECT count(*)
                                                    INTO v_existe_cuenta
                                                    FROM FIN_PARAMETROS
                                                   WHERE sfinanci = v_sfinanci
                                                     AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                     AND cparam = 'ASIGNADO';

                                                 IF v_existe_cuenta = 0 THEN
                                                  INSERT INTO FIN_PARAMETROS
                                                              (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                                                       VALUES (v_sfinanci, (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY')), 'ASIGNADO', f_user, f_sysdate, f_user, f_sysdate, null, null, ext.INVSUPLCAP);
                                                 ELSE
                                                     UPDATE FIN_PARAMETROS
                                                        SET tvalpar = ext.INVSUPLCAP
                                                      WHERE sfinanci = v_sfinanci
                                                        AND nmovimi = (select MAX(fi.NMOVIMI) FROM  fin_indicadores fi WHERE fi.sfinanci = v_sfinanci and fi.FINDICAD = TO_DATE(ext.fecestfinan,'DD/MM/YYYY'))
                                                        AND cparam = 'ASIGNADO';
                                                 END IF;

                                          END IF;


                                   IF ext.feccordeclrenta IS NOT NULL THEN
                                        SELECT count(*)
                                          INTO v_existe_d_renta
                                          FROM FIN_D_RENTA
                                         WHERE sfinanci = v_sfinanci
                                           AND   fcorte = TO_DATE(ext.feccordeclrenta,'DD/MM/YYYY');

                                           IF v_existe_d_renta = 0 THEN
                                                    INSERT INTO FIN_D_RENTA
                                                                (sfinanci, fcorte, cesvalor, ipatriliq, irenta)
                                                         VALUES (v_sfinanci, TO_DATE(ext.feccordeclrenta,'DD/MM/YYYY'), '1', ext.patriliquido, ext.renliqgrav);
                                           ELSE
                                                      UPDATE FIN_D_RENTA
                                                         SET ipatriliq = ext.patriliquido,
                                                                irenta = ext.renliqgrav
                                                        WHERE sfinanci = v_sfinanci
                                                          AND   fcorte = TO_DATE(ext.feccordeclrenta,'DD/MM/YYYY');
                                           END IF;
                                    END IF;

                                 END IF;
                            END LOOP;

            v_pasexec := 1;
            COMMIT;
            RETURN 0;
         EXCEPTION
            WHEN OTHERS THEN
               ROLLBACK;
               pdeserror := f_axis_literales(103187, pac_md_common.f_get_cxtidioma) || SQLERRM;
               p_tab_error(f_sysdate, f_user, vobj, v_pasexec, SQLCODE, SQLERRM, 10);
               RETURN 1;
         END f_trasp_tabla;
      --
      BEGIN
         vtraza := 0;

         IF psproces IS NULL THEN
            SELECT sproces.NEXTVAL
              INTO psproces
              FROM DUAL;
         END IF;

         vtraza := 1;

         IF p_cproces IS NULL THEN
            vnum_err := 9901092;
            vdeserror := 'cfg_files falta proceso: ' || vobj;
            RAISE e_errdatos;
         END IF;

         --
         vtraza := 2;
         --
         vnum_err := f_modi_tabla_ext(p_nombre, p_path);

         IF vnum_err <> 0 THEN
            p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                        'Error creando la tabla externa', 10);
            RAISE errorini;
         END IF;

         vnum_err := f_trasp_tabla(vdeserror, psproces);
         vtraza := 3;

         IF vnum_err <> 0 THEN
            --
            vtraza := 5;
            vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces, p_nombre,
                                                                       f_sysdate, NULL, 1,
                                                                       p_cproces, NULL,
                                                                       vdeserror, 0);
            vtraza := 51;

            IF vnum_err <> 0 THEN
               p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                           'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera',
                           10);
               RAISE errorini;
            END IF;

            vtraza := 52;
            RAISE vsalir;
         END IF;

         RETURN 0;
      EXCEPTION
         WHEN vsalir THEN
            RETURN 103187;
         WHEN e_errdatos THEN
            ROLLBACK;
            p_genera_logs(vobj, vtraza, 'Error:' || vnum_err, vdeserror);
            RETURN vnum_err;
         WHEN errorini THEN
            ROLLBACK;
            p_genera_logs(vobj, vtraza, 'Error:' || 'ErrorIni' || ' en :' || 1,
                          'Error:' || 'Insertando estados registros');
            RETURN 1;
         WHEN OTHERS THEN
            ROLLBACK;
            p_genera_logs(vobj, vtraza, 'Error:' || 'ErrorIni en 1',
                          'Error: Insertando estados registros');
            vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces, p_nombre,
                                                                       f_sysdate, NULL, 1,
                                                                       p_cproces, 151541,
                                                                       SQLERRM, 0);
            vtraza := 51;

            IF vnum_err <> 0 THEN
               p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                           'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera',
                           10);
            END IF;

            RETURN 1;
      END f_ejecutar_carga_fichero;

   --
   BEGIN
      vtraza := 0;

      IF pjob = 1 THEN
         vnum_err :=
            pac_contexto.f_inicializarctx
                   (NVL(pcusuari,
                        pac_parametros.f_parempresa_t(NVL(pac_md_common.f_get_cxtempresa,
                                                          f_parinstalacion_n('EMPRESADEF')),
                                                      'USER_BBDD')));
      END IF;

      IF psproces IS NULL
         OR(psproces IS NOT NULL
            AND pjob = 1) THEN
         vnum_err := f_ejecutar_carga_fichero(p_nombre, p_path, p_cproces, psproces);

         IF vnum_err <> 0 THEN
            RAISE vsalir;
         END IF;
      END IF;

      --
      vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces, p_nombre, f_sysdate,
                                                                 NULL, 3, p_cproces, NULL,
                                                                 NULL, 1);

      IF vnum_err <> 0 THEN
         p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                     'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera', 10);
         RAISE vsalir;
      END IF;

      FOR reg IN infcolombiais LOOP
         vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces => psproces,
                                                                 pnlinea => reg.nlinea,
                                                                 pctipo => 20,
                                                                 pidint => reg.nlinea,
                                                                 pidext => reg.nlinea,
                                                                 pcestado => 4,
                                                                 pcvalidado => NULL,
                                                                 psseguro => NULL,
                                                                 pidexterno => NULL,
                                                                 pncarga => NULL,
                                                                 pnsinies => NULL,
                                                                 pntramit => NULL,
                                                                 psperson => NULL,
                                                                 pnrecibo => NULL);
      END LOOP;

      UPDATE int_carga_ctrl
         SET cestado = vnum_err,
             ffin = f_sysdate,
             cbloqueo = 0
       WHERE sproces = psproces;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN vsalir THEN
         RETURN vnum_err;
   END f_carga_supersociedades;*/

    --
    /*FUNCTION f_supersociedades(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN VARCHAR2,
      psproces IN OUT NUMBER)
      RETURN NUMBER IS
      vmensaje       NUMBER;
   BEGIN
      --
      IF psproces IS NULL THEN
         SELECT sproces.NEXTVAL
           INTO psproces
           FROM DUAL;

         vmensaje := pac_cargas_conf.f_carga_supersociedades(p_nombre, p_path, p_cproces,
                                                              psproces, 1, f_user);

         IF vmensaje <> 0 THEN
            RETURN 180856;
         END IF;
      END IF;

      --
      RETURN 0;
   END f_supersociedades;
   --FIN -IAXIS-51545 - JLTS - 04/09/2019 */


   --
  FUNCTION f_carga_finleco(p_nombre  IN VARCHAR2,
                           p_path    IN VARCHAR2,
                           p_cproces IN NUMBER,
                           psproces  IN OUT NUMBER,
                           pjob      IN NUMBER DEFAULT 0,
                           pcusuari  IN VARCHAR2 DEFAULT NULL) RETURN NUMBER IS
    vobj     VARCHAR2(100) := 'pac_cargas_conf.f_carga_finleco';
    vtraza   NUMBER := 0;
    vnum_err NUMBER := 0;
    vsalir EXCEPTION;
    --
    CURSOR infcolombiais IS
      SELECT r.* FROM int_carga_informacol r WHERE r.proceso = psproces;

    --
    FUNCTION f_ejecutar_carga_fichero(p_nombre IN VARCHAR2, p_path IN VARCHAR2, p_cproces IN NUMBER, psproces IN OUT NUMBER)
      RETURN NUMBER IS
      vobj      VARCHAR2(100) := 'f_ejecutar_carga_fichero';
      vtraza    NUMBER := 0;
      vdeserror VARCHAR2(1000);
      errorini EXCEPTION;
      vnum_err NUMBER := 0;
      vsalir EXCEPTION;

      --
      FUNCTION f_modi_tabla_ext(p_nombre VARCHAR2, p_path IN VARCHAR2) RETURN NUMBER IS
        v_iteraciones NUMBER(2);
        k_iteraciones NUMBER(2) := 10;
      BEGIN
        v_iteraciones := 1;

        LOOP
          BEGIN
            LOCK TABLE int_carga_informacol_ext IN EXCLUSIVE MODE;

            EXECUTE IMMEDIATE 'ALTER TABLE int_carga_informacol_ext LOCATION (' || p_path || ':''' || p_nombre || ''')';

            EXIT;
          EXCEPTION
            WHEN OTHERS THEN
              p_tab_error(f_sysdate,
                          f_user,
                          'f_modi_tabla_ext',
                          v_iteraciones,
                          'Error modificando tabla. Reintento.',
                          SQLERRM,
                          10);

              IF k_iteraciones <= v_iteraciones THEN
                RAISE;
              END IF;

              v_iteraciones := v_iteraciones + 1;
          END;
        END LOOP;

        LOCK TABLE int_carga_informacol_ext IN EXCLUSIVE MODE;
        RETURN 0;
      EXCEPTION
        WHEN OTHERS THEN
          p_tab_error(f_sysdate, f_user, 'pac_cargas_conf.f_modi_tabla_ext', 1, 'Error creando la tabla.', SQLERRM, 10);
          RETURN 103865;
      END f_modi_tabla_ext;

      --
      FUNCTION f_trasp_tabla(pdeserror OUT VARCHAR2, psproces IN NUMBER) RETURN NUMBER IS
        v_pasexec        NUMBER := 1;
        vobj             VARCHAR2(200) := 'pac_cargas_conf.f_trasp_tabla';
        v_numlin         int_carga_informacol.nlinea%TYPE;
        v_existe_sfianci NUMBER := 0;
        v_existe_indicad NUMBER := 0;
        v_existe_d_renta NUMBER := 0;
        v_existe_finleco NUMBER := 0;
        v_nit            int_carga_informacol.nit%TYPE;
        v_sfinanci       NUMBER := 0;
        v_numlinfile     NUMBER := 0;

        v_existe_cuenta NUMBER := 0;
        v_conta_finleco NUMBER := 0;
        -- INI TCS_453B - 18/02/2019 - JLTS - Se adiciona la variable v_max_nmovimi para no hacer tantas veces la consulta
        v_max_nmovimi NUMBER := 0;
        -- FIN TCS_453B - 18/02/2019 - JLTS.
        -- INI IAXIS-3070 - 18/03/2019 - JLTS - Se adiciona la variable v_max_nmovimi1 para no hacer tantas veces la consulta
        v_max_nmovimi1 NUMBER := 0;
        -- FIN IAXIS-3070 - 18/03/2019 - JLTS - Se adiciona la variable v_max_nmovimi1 para no hacer tantas veces la consulta
        -- INI -IAXIS-3673 -25/04/2019 -JLTS. Se incluyen las validaciones de ecuaciones patrimoniales
        V_RANGO  constant number := 100;
        v_patri_ano_actual number := 0;
        v_act_total number := 0;
        V_PAS_TOTAL number := 0;
        V_ACT_CORR number := 0;
        V_TOT_ACT_NO_CORR number := 0;
        V_PAS_NO_CORR number := 0;
        V_PAS_CORR  number := 0;
        v_tdeserror    int_carga_ctrl_linea_errs.tmensaje%TYPE;
        mensajes  t_iax_mensajes;
              --
      PROCEDURE p_controlar_error(p_traza NUMBER, p_estado NUMBER, v_msg VARCHAR2) IS
      BEGIN
         vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces, p_nombre,
                                                                    f_sysdate, NULL, p_estado,
                                                                    p_cproces, NULL, v_msg);

         IF vnum_err <> 0 THEN
            -- Si fallan esta funciones de gestin salimos del programa
            p_tab_error(f_sysdate, f_user, vobj, p_traza, vnum_err,
                        'Error llamando pac_gestion_procesos.f_set_carga_ctrl_cabecera'
                        || p_traza);
            RAISE errorini;
         END IF;
      END p_controlar_error;
      -- FIN -IAXIS-3673 -25/04/2019 -JLTS. Se incluyen las validaciones de ecuaciones patrimoniales
      BEGIN
        v_pasexec := 0;
        pdeserror := NULL;

        SELECT nvl(MAX(nlinea), 0) INTO v_numlin FROM int_carga_informacol WHERE proceso = psproces;

        INSERT /*+ APPEND */
        INTO int_carga_informacol
          (proceso, nlinea, ncarga, tipo_oper, nit, nombre, tiposociedad, reprelegal, revfiscal, estempresa, objsocial, fechacons,
           vigsociedad, limreplegal, incjudicial, nomaccionista1, nomaccionista2, nomaccionista3, nomaccionista4, nitaccionista1,
           nitaccionista2, nitaccionista3, nitaccionista4, partaccionista1, partaccionista2, partaccionista3, partaccionista4,
           ciiu, fuenteinf, moneda, valmiles, fecestfinan, ventas, ventasperant, costoventas, gastosadm, utloperacional,
           gastosfinan, resultantimp, utlneta, inventario, cartcliente, actcorriente, totactnocorriente, propplanequipo,
           otrosactivos, activototal, obligfinancp, proveedorescp, anticipocp, pascorriente, obligfinanlp, anticipolp,
           totpascorriente, pastotal, patriperant, patrianoact, capsocial, pricolacc, invsuplcap, reslegal, resocasional,
           resejerant, valorizacion, feccamcomercio, fotrut, fecrut, fotcedula, fecexpcedula, ciuexpcedula, feccordeclrenta,
           patriliquido, renliqgrav, origencarga)
          (SELECT psproces proceso, rownum + v_numlin nlinea, NULL ncarga, NULL tipo_oper, nit, nombre, tiposociedad, reprelegal,
                  revfiscal, estempresa, objsocial, fechacons, vigsociedad, limreplegal, incjudicial, nomaccionista1,
                  nomaccionista2, nomaccionista3, nomaccionista4, nitaccionista1, nitaccionista2, nitaccionista3, nitaccionista4,
                  partaccionista1, partaccionista2, partaccionista3, partaccionista4, ciiu, fuenteinf, moneda, valmiles,
                  fecestfinan, ventas, ventasperant, costoventas, gastosadm, utloperacional, gastosfinan, resultantimp, utlneta,
                  inventario, cartcliente, actcorriente, totactnocorriente, propplanequipo, otrosactivos, activototal,
                  obligfinancp, proveedorescp, anticipocp, pascorriente, obligfinanlp, anticipolp, totpascorriente, pastotal,
                  patriperant, patrianoact, capsocial, pricolacc, invsuplcap, reslegal, resocasional, resejerant, valorizacion,
                  feccamcomercio, fotrut, fecrut, fotcedula, fecexpcedula, ciuexpcedula, feccordeclrenta, patriliquido,
                  to_number(REPLACE(REPLACE(renliqgrav, chr(10), ''), chr(13), ''),
                             '9999999999999D999',
                             'NLS_NUMERIC_CHARACTERS = '',.'''), 'ARC'
             FROM int_carga_informacol_ext);
        -- INI -IAXIS-3673 -25/04/2019 -JLTS. Se incluyen las validaciones de ecuaciones patrimoniales
        --
        p_controlar_error(2, 3, NULL);
        --
        FOR ext IN (SELECT rownum nlinea,e.* FROM int_carga_informacol_ext e) LOOP
          --
          BEGIN --IAXIS-51545 - JLTS - 09/09/2019
            v_nit := ext.nit;
            v_numlinfile := ext.nlinea;
            mensajes := t_iax_mensajes();
            v_pas_total := to_number(ext.pastotal, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.''');
            v_patri_ano_actual := to_number(ext.patrianoact, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.''');
            v_act_total := to_number(ext.activototal, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.''');
            V_ACT_CORR := to_number(ext.actcorriente, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.''');
            V_TOT_ACT_NO_CORR := to_number(ext.totactnocorriente, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.''');
            V_PAS_NO_CORR := to_number(ext.totpascorriente, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.''');
            V_PAS_CORR := to_number(ext.pascorriente, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.''');

            -- Activo Total debe ser igual a Pasivo Total + Patrimonio.
             IF (V_PAS_TOTAL + V_PATRI_ANO_ACTUAL) > (V_ACT_TOTAL + V_RANGO) OR
                (V_PAS_TOTAL + V_PATRI_ANO_ACTUAL) < (V_ACT_TOTAL - V_RANGO) THEN
               v_nnumerr := 89906072;
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_nnumerr);
             END IF;
                vtraza := 100;
             -- Pasivo Total debe ser igual a Activo Total - Patrimonio.
             IF (V_ACT_TOTAL - V_PATRI_ANO_ACTUAL) > (V_PAS_TOTAL + V_RANGO) OR
                (V_ACT_TOTAL - V_PATRI_ANO_ACTUAL) < (V_PAS_TOTAL - V_RANGO) THEN
               v_nnumerr := 89906073;
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_nnumerr);
             END IF;
                vtraza := 110;
             -- Patrimonio debe ser igual a Activo Total - Pasivo Total.
             IF (V_ACT_TOTAL - V_PAS_TOTAL) > (V_PATRI_ANO_ACTUAL + V_RANGO) OR
                (V_ACT_TOTAL - V_PAS_TOTAL) < (V_PATRI_ANO_ACTUAL - V_RANGO) THEN
               v_nnumerr := 89906074;
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_nnumerr);
             END IF;
                vtraza := 120;
             -- Otras validaciones
             -- Activo Corriente + Activo no corriente debe ser igual a Activo Total.
             IF (V_ACT_CORR + V_TOT_ACT_NO_CORR) > (V_ACT_TOTAL + V_RANGO) OR
                (V_ACT_CORR + V_TOT_ACT_NO_CORR) < (V_ACT_TOTAL - V_RANGO)  THEN
               v_nnumerr := 89906270;
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_nnumerr);
             END IF;
                vtraza := 130;
             -- Pasivo Corriente + Pasivo no Corriente debe ser igual a Pasivo Total.
             IF (V_PAS_CORR + V_PAS_NO_CORR) < (V_PAS_TOTAL - V_RANGO) OR
               (V_PAS_CORR + V_PAS_NO_CORR) > (V_PAS_TOTAL + V_RANGO) THEN
               v_nnumerr := 89906271;
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_nnumerr);
             END IF;
             IF mensajes IS NOT NULL  and mensajes.count > 0 THEN
               v_tdeserror := null;
               FOR i IN mensajes.FIRST .. mensajes.LAST LOOP
                 v_tdeserror := SUBSTR(v_tdeserror||mensajes(i).terror||chr(13),1,4000);
               END LOOP;
               v_nnumerr := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces, 
                                                                        ext.nlinea,
                                                                        3,
                                                                        v_tdeserror,
                                                                        NULL,
                                                                        1, 
                                                                        0, 
                                                                        NULL,
                                                                        ext.nit, 
                                                                        NULL, 
                                                                        NULL,
                                                                        NULL, 
                                                                        NULL, 
                                                                        NULL);
                v_nnumerr := pac_gestion_procesos.f_set_carga_ctrl_linea_error(psproces,
                                                                                ext.nlinea, 1,
                                                                                1, 151541,
                                                                                v_nit);
                continue;
             ELSE
             vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces   => psproces,
                                                                     pnlinea    => ext.nlinea,
                                                                     pctipo     => 3,
                                                                     pidint     => ext.nlinea,
                                                                     pidext     => ext.nlinea,
                                                                     pcestado   => 4,
                                                                     pcvalidado => NULL,
                                                                     psseguro   => NULL,
                                                                     pidexterno => ext.nit,
                                                                     pncarga    => NULL,
                                                                     pnsinies   => NULL,
                                                                     pntramit   => NULL,
                                                                     psperson   => NULL,
                                                                     pnrecibo   => NULL);
           END IF;
   --INI -IAXIS-51545 - JLTS - 04/09/2019
        EXCEPTION
        WHEN OTHERS THEN
					 v_nnumerr := 1000176;
           pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_nnumerr);
           v_tdeserror := null;
             FOR i IN mensajes.FIRST .. mensajes.LAST LOOP
               v_tdeserror := SUBSTR(v_tdeserror||mensajes(i).terror||chr(13),1,4000);
             END LOOP;
             v_nnumerr := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces, 
                                                                      ext.nlinea,
                                                                      3,
                                                                      v_tdeserror,
                                                                      NULL,
                                                                      1, 
                                                                      0, 
                                                                      NULL,
                                                                      ext.nit, 
                                                                      NULL, 
                                                                      NULL,
                                                                      NULL, 
                                                                      NULL, 
                                                                      NULL);

            v_nnumerr := pac_gestion_procesos.f_set_carga_ctrl_linea_error(psproces,
                                                                           ext.nlinea, 1,
                                                                           1, 151541,
                                                                           v_nit);
            continue;
        END;
       END LOOP;
       
       
        IF v_tdeserror is not null then
          UPDATE int_carga_ctrl SET cestado = 3, cerror = 9903644, ffin = f_sysdate, cbloqueo = 0 WHERE sproces = psproces;
        END IF;

       FOR ext IN (SELECT rownum nlinea,e.* FROM int_carga_informacol_ext e) LOOP
				 BEGIN
            v_nit := ext.nit;
            v_numlinfile := ext.nlinea;
            mensajes := t_iax_mensajes();
       --FIN -IAXIS-51545 - JLTS - 04/09/2019
          --
          -- FIN -IAXIS-3673 -25/04/2019 -JLTS. Se incluyen las validaciones de ecuaciones patrimoniales          
          SELECT COUNT(sfinanci)
            INTO v_existe_sfianci
            FROM fin_general fg
           WHERE fg.sperson IN (SELECT pp.sperson FROM per_personas pp WHERE pp.nnumide LIKE ext.nit || '%');
          IF v_existe_sfianci > 0 THEN
            -- INI TCS_9998 IAXIS-2607 - JLTS - 28/02/2019. Se incluye el valor mximo de la sfinanci
            SELECT MAX(sfinanci)
              INTO v_sfinanci
              FROM fin_general fg
             WHERE fg.sperson IN (SELECT pp.sperson FROM per_personas pp WHERE pp.nnumide LIKE ext.nit || '%');
            -- FIN TCS_9998 IAXIS-2607 - JLTS - 28/02/2019. Se incluye el valor mximo de la sfinanci
            -- INI IAXIS-3070 - 18/03/2019 - JLTS - Se adiciona la variable v_max_nmovimi1 para no hacer tantas veces la consulta
            SELECT MAX(d1.nmovimi) INTO v_max_nmovimi1 FROM fin_general_det d1 WHERE d1.sfinanci = v_sfinanci;
            -- FIN IAXIS-3070 - 18/03/2019 - JLTS.
            -- INI TCS_11;IAXIS-3070 - JLTS - Ajuste de la carga por cambios en FIN_GENERAL
            UPDATE fin_general_det d
               SET tdescrip = CASE
                                WHEN ext.nombre IS NULL THEN
                                 tdescrip
                                ELSE
                                 'Ficha tecnica ' || ext.nombre
                              END,
                   cfotorut = CASE
                                WHEN ext.fotrut = 'SI' THEN
                                 1
                                ELSE
                                 0
                              END,
                   frut = CASE
                            WHEN ext.fecrut IS NOT NULL THEN
                             to_date(ext.fecrut, 'DD/MM/YYYY')
                            ELSE
                             frut
                          END,
                   cfotoced = CASE
                                WHEN ext.fotcedula = 'SI' THEN
                                 1
                                ELSE
                                 0
                              END,
                   fexpiced = CASE
                                WHEN ext.fecexpcedula IS NOT NULL THEN
                                 to_date(ext.fecexpcedula, 'DD/MM/YYYY')
                                ELSE
                                 fexpiced
                              END,
                   cciiu = CASE
                             WHEN ext.ciiu != 0 THEN
                              to_number(ext.ciiu)
                             ELSE
                              cciiu
                           END,
                   ctipsoci = CASE
                                WHEN ext.tiposociedad IS NOT NULL THEN
                                 nvl((SELECT catribu
                                       FROM detvalores
                                      WHERE cidioma = 8
                                        AND cvalor = '8001073'
                                        AND upper(tatribu) LIKE ext.tiposociedad),
                                     ctipsoci)
                                ELSE
                                 ctipsoci
                              END,
                   cestsoc = CASE
                               WHEN ext.estempresa IS NOT NULL THEN
                                nvl((SELECT catribu
                                      FROM detvalores
                                     WHERE cidioma = 8
                                       AND cvalor = '8001074'
                                       AND upper(tatribu) LIKE ext.estempresa),
                                    cestsoc)
                               ELSE
                                cestsoc
                             END,
                   tobjsoc = CASE
                               WHEN ext.objsocial IS NOT NULL THEN
                                ext.objsocial
                               ELSE
                                tobjsoc
                             END,
                   fconsti = CASE
                               WHEN ext.fechacons IS NOT NULL THEN
                                to_date(ext.fechacons, 'DD/MM/YYYY')
                               ELSE
                                fconsti
                             END,
                   tvigenc = CASE
                               WHEN ext.vigsociedad IS NOT NULL THEN
                                ext.vigsociedad
                               ELSE
                                tvigenc
                             END,
                   fccomer = CASE
                               WHEN ext.feccamcomercio IS NOT NULL THEN
                                to_date(ext.feccamcomercio, 'DD/MM/YYYY')
                               ELSE
                                fccomer
                             END
             WHERE sfinanci = v_sfinanci
               AND d.nmovimi = v_max_nmovimi1; -- IAXIS-3070 - 18/03/2019 - JLTS - Se adiciona la variable v_max_nmovimi1 para no hacer tantas veces la consulta

            -- INI IAXIS-3070 - JLTS - Se actualiza el FIN_GENERAL basado en el último movimiento de FIN_GENERAL_DET
            UPDATE (SELECT fg.tdescrip AS old_tdescrip, fg.cfotorut AS old_cfotorut, fg.frut AS old_frut, fg.ttitulo AS old_ttitulo,
                            fg.cfotoced AS old_cfotoced, fg.fexpiced AS old_fexpiced, fg.cpais AS old_cpais,
                            fg.cprovin AS old_cprovin, fg.cpoblac AS old_cpoblac, fg.tinfoad AS old_tinfoad, fg.cciiu AS old_cciiu,
                            fg.ctipsoci AS old_ctipsoci, fg.cestsoc AS old_cestsoc, fg.tobjsoc AS old_tobjsoc,
                            fg.texperi AS old_texperi, fg.fconsti AS old_fconsti, fg.tvigenc AS old_tvigenc,
                            fg.fccomer AS old_fccomer, fgd.tdescrip AS new_tdescrip, fgd.cfotorut AS new_cfotorut,
                            fgd.frut AS new_frut, fgd.ttitulo AS new_ttitulo, fgd.cfotoced AS new_cfotoced,
                            fgd.fexpiced AS new_fexpiced, fgd.cpais AS new_cpais, fgd.cprovin AS new_cprovin,
                            fgd.cpoblac AS new_cpoblac, fgd.tinfoad AS new_tinfoad, fgd.cciiu AS new_cciiu,
                            fgd.ctipsoci AS new_ctipsoci, fgd.cestsoc AS new_cestsoc, fgd.tobjsoc AS new_tobjsoc,
                            fgd.texperi AS new_texperi, fgd.fconsti AS new_fconsti, fgd.tvigenc AS new_tvigenc,
                            fgd.fccomer AS new_fccomer
                       FROM fin_general fg
                      INNER JOIN fin_general_det fgd
                         ON fg.sfinanci = fgd.sfinanci
                      WHERE fg.sfinanci = v_sfinanci
                        AND fgd.nmovimi = v_max_nmovimi1) -- IAXIS-3070 - 18/03/2019 - JLTS - Se adiciona la variable v_max_nmovimi1 para no hacer tantas veces la consulta
               SET old_tdescrip = new_tdescrip, old_cfotorut = new_cfotorut, old_frut = new_frut, old_ttitulo = new_ttitulo,
                   old_cfotoced = new_cfotoced, old_fexpiced = new_fexpiced, old_cpais = new_cpais, old_cprovin = new_cprovin,
                   old_cpoblac = new_cpoblac, old_tinfoad = new_tinfoad, old_cciiu = new_cciiu, old_ctipsoci = new_ctipsoci,
                   old_cestsoc = new_cestsoc, old_tobjsoc = new_tobjsoc, old_texperi = new_texperi, old_fconsti = new_fconsti,
                   old_tvigenc = new_tvigenc, old_fccomer = new_fccomer;
            -- FIN IAXIS-3070 - JLTS - Ajuste de la carga por cambios en FIN_GENERAL
            -- INI TCS_453B - 18/02/2019 - JLTS - Se adiciona la condición ext.fecestfinan porque estaba insertando datos nulos
            IF ext.fecestfinan IS NOT NULL THEN
              SELECT COUNT(*)
                INTO v_existe_indicad
                FROM fin_indicadores
               WHERE sfinanci = v_sfinanci
                 AND findicad = to_date(ext.fecestfinan, 'DD/MM/YYYY');

              IF v_existe_indicad > 0 THEN

                FOR fin_indica IN (SELECT fi.*
                                     FROM fin_indicadores fi
                                    WHERE fi.sfinanci = v_sfinanci
                                      AND fi.findicad = to_date(ext.fecestfinan, 'DD/MM/YYYY')) LOOP

                  SELECT COUNT(*)
                    INTO v_existe_finleco
                    FROM fin_parametros fp
                   WHERE fp.sfinanci = v_sfinanci
                     AND fp.nmovimi = fin_indica.nmovimi
                     AND fp.cparam = 'FUENTE_INFORMACION'
                     AND fp.nvalpar = decode(p_cproces, 222, 1, 223, 3, 8);

                  v_conta_finleco := v_conta_finleco + v_existe_finleco;

                END LOOP;

              END IF;

              IF v_existe_indicad = 0 OR v_conta_finleco = 0 THEN

                INSERT INTO fin_indicadores
                  (sfinanci, nmovimi, findicad, imargen, icaptrab, trazcor, tprbaci, ienduada, ndiacar, nrotpro, nrotinv,
                   ndiacicl, irentab, ioblcp, iobllp, igastfin, ivalpt, cesvalor, cmoneda, fcupo, icupog, icupos, fcupos, tcupor,
                   tconcepc, tconceps, tcburea, tcotros, cmoncam, ncapfin)
                VALUES
                  (v_sfinanci, nmovimi.nextval, to_date(ext.fecestfinan, 'DD/MM/YYYY'), NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                   NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1', 'COP', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                   NULL, NULL);
                -- INI TCS_453B - 18/02/2019 - JLTS - Se adiciona la variable v_max_nmovimi para no hacer tantas veces la consulta
                SELECT MAX(fi.nmovimi)
                  INTO v_max_nmovimi
                  FROM fin_indicadores fi
                 WHERE fi.sfinanci = v_sfinanci
                   AND fi.findicad = to_date(ext.fecestfinan, 'DD/MM/YYYY');

                IF v_max_nmovimi IS NOT NULL THEN

                  SELECT COUNT(*)
                    INTO v_existe_cuenta
                    FROM fin_parametros
                   WHERE sfinanci = v_sfinanci
                     AND nmovimi = v_max_nmovimi
                     AND cparam = 'FUENTE_INFORMACION';

                  IF v_existe_cuenta = 0 THEN
                    INSERT INTO fin_parametros
                      (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                    VALUES
                      (v_sfinanci, v_max_nmovimi, 'FUENTE_INFORMACION', f_user, f_sysdate, f_user, f_sysdate, NULL,
                       decode(p_cproces, 222, 1, 223, 3, 8), NULL);
                  ELSE
                    UPDATE fin_parametros
                       SET nvalpar = decode(p_cproces, 222, 1, 223, 3, 8)
                     WHERE sfinanci = v_sfinanci
                       AND nmovimi = v_max_nmovimi
                       AND cparam = 'FUENTE_INFORMACION';
                  END IF;

                  SELECT COUNT(*)
                    INTO v_existe_cuenta
                    FROM fin_parametros
                   WHERE sfinanci = v_sfinanci
                     AND nmovimi = v_max_nmovimi
                     AND cparam = 'FECHA_EST_FIN';

                  IF v_existe_cuenta = 0 THEN
                    INSERT INTO fin_parametros
                      (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                    VALUES
                      (v_sfinanci, v_max_nmovimi, 'FECHA_EST_FIN', f_user, f_sysdate, f_user, f_sysdate,
                       to_date(ext.fecestfinan, 'DD/MM/YYYY'), NULL, NULL);
                  ELSE
                    UPDATE fin_parametros
                       SET fvalpar = to_date(ext.fecestfinan, 'DD/MM/YYYY')
                     WHERE sfinanci = v_sfinanci
                       AND nmovimi = v_max_nmovimi
                       AND cparam = 'FECHA_EST_FIN';
                  END IF;

                  SELECT COUNT(*)
                    INTO v_existe_cuenta
                    FROM fin_parametros
                   WHERE sfinanci = v_sfinanci
                     AND nmovimi = v_max_nmovimi
                     AND cparam = 'VT_PER_ANT';

                  IF v_existe_cuenta = 0 THEN
                    INSERT INTO fin_parametros
                      (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                    VALUES
                      (v_sfinanci, v_max_nmovimi, 'VT_PER_ANT', f_user, f_sysdate, f_user, f_sysdate, NULL, NULL,
                       ext.ventasperant);
                  ELSE
                    UPDATE fin_parametros
                       SET tvalpar = ext.ventasperant
                     WHERE sfinanci = v_sfinanci
                       AND nmovimi = v_max_nmovimi
                       AND cparam = 'VT_PER_ANT';
                  END IF;

                  SELECT COUNT(*)
                    INTO v_existe_cuenta
                    FROM fin_parametros
                   WHERE sfinanci = v_sfinanci
                     AND nmovimi = v_max_nmovimi
                     AND cparam = 'VENTAS';

                  IF v_existe_cuenta = 0 THEN
                    INSERT INTO fin_parametros
                      (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                    VALUES
                      (v_sfinanci, v_max_nmovimi, 'VENTAS', f_user, f_sysdate, f_user, f_sysdate, NULL, NULL, ext.ventas);
                  ELSE
                    UPDATE fin_parametros
                       SET tvalpar = ext.ventas
                     WHERE sfinanci = v_sfinanci
                       AND nmovimi = v_max_nmovimi
                       AND cparam = 'VENTAS';
                  END IF;

                  SELECT COUNT(*)
                    INTO v_existe_cuenta
                    FROM fin_parametros
                   WHERE sfinanci = v_sfinanci
                     AND nmovimi = v_max_nmovimi
                     AND cparam = 'COSTO_VT';

                  IF v_existe_cuenta = 0 THEN
                    INSERT INTO fin_parametros
                      (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                    VALUES
                      (v_sfinanci, v_max_nmovimi, 'COSTO_VT', f_user, f_sysdate, f_user, f_sysdate, NULL, NULL, ext.costoventas);
                  ELSE
                    UPDATE fin_parametros
                       SET tvalpar = ext.costoventas
                     WHERE sfinanci = v_sfinanci
                       AND nmovimi = v_max_nmovimi
                       AND cparam = 'COSTO_VT';
                  END IF;

                  SELECT COUNT(*)
                    INTO v_existe_cuenta
                    FROM fin_parametros
                   WHERE sfinanci = v_sfinanci
                     AND nmovimi = v_max_nmovimi
                     AND cparam = 'GASTO_ADM';

                  IF v_existe_cuenta = 0 THEN
                    INSERT INTO fin_parametros
                      (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                    VALUES
                      (v_sfinanci, v_max_nmovimi, 'GASTO_ADM', f_user, f_sysdate, f_user, f_sysdate, NULL, NULL, ext.gastosadm);
                  ELSE
                    UPDATE fin_parametros
                       SET tvalpar = ext.gastosadm
                     WHERE sfinanci = v_sfinanci
                       AND nmovimi = v_max_nmovimi
                       AND cparam = 'GASTO_ADM';
                  END IF;

                  SELECT COUNT(*)
                    INTO v_existe_cuenta
                    FROM fin_parametros
                   WHERE sfinanci = v_sfinanci
                     AND nmovimi = v_max_nmovimi
                     AND cparam = 'UTIL_OPERAC';

                  IF v_existe_cuenta = 0 THEN
                    INSERT INTO fin_parametros
                      (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                    VALUES
                      (v_sfinanci, v_max_nmovimi, 'UTIL_OPERAC', f_user, f_sysdate, f_user, f_sysdate, NULL, NULL,
                       ext.utloperacional);
                  ELSE
                    UPDATE fin_parametros
                       SET tvalpar = ext.utloperacional
                     WHERE sfinanci = v_sfinanci
                       AND nmovimi = v_max_nmovimi
                       AND cparam = 'UTIL_OPERAC';
                  END IF;

                  SELECT COUNT(*)
                    INTO v_existe_cuenta
                    FROM fin_parametros
                   WHERE sfinanci = v_sfinanci
                     AND nmovimi = v_max_nmovimi
                     AND cparam = 'GASTO_FIN';

                  IF v_existe_cuenta = 0 THEN
                    INSERT INTO fin_parametros
                      (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                    VALUES
                      (v_sfinanci, v_max_nmovimi, 'GASTO_FIN', f_user, f_sysdate, f_user, f_sysdate, NULL, NULL, ext.gastosfinan);
                  ELSE
                    UPDATE fin_parametros
                       SET tvalpar = ext.gastosfinan
                     WHERE sfinanci = v_sfinanci
                       AND nmovimi = v_max_nmovimi
                       AND cparam = 'GASTO_FIN';
                  END IF;

                  SELECT COUNT(*)
                    INTO v_existe_cuenta
                    FROM fin_parametros
                   WHERE sfinanci = v_sfinanci
                     AND nmovimi = v_max_nmovimi
                     AND cparam = 'GASTO_FIN';

                  IF v_existe_cuenta = 0 THEN
                    INSERT INTO fin_parametros
                      (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                    VALUES
                      (v_sfinanci, v_max_nmovimi, 'GASTO_FIN', f_user, f_sysdate, f_user, f_sysdate, NULL, NULL, ext.gastosfinan);
                  ELSE
                    UPDATE fin_parametros
                       SET tvalpar = ext.gastosfinan
                     WHERE sfinanci = v_sfinanci
                       AND nmovimi = v_max_nmovimi
                       AND cparam = 'GASTO_FIN';
                  END IF;

                  SELECT COUNT(*)
                    INTO v_existe_cuenta
                    FROM fin_parametros
                   WHERE sfinanci = v_sfinanci
                     AND nmovimi = v_max_nmovimi
                     AND cparam = 'RES_ANT_IMP';

                  IF v_existe_cuenta = 0 THEN
                    INSERT INTO fin_parametros
                      (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                    VALUES
                      (v_sfinanci, v_max_nmovimi, 'RES_ANT_IMP', f_user, f_sysdate, f_user, f_sysdate, NULL, NULL,
                       ext.resultantimp);
                  ELSE
                    UPDATE fin_parametros
                       SET tvalpar = ext.resultantimp
                     WHERE sfinanci = v_sfinanci
                       AND nmovimi = v_max_nmovimi
                       AND cparam = 'RES_ANT_IMP';
                  END IF;

                  SELECT COUNT(*)
                    INTO v_existe_cuenta
                    FROM fin_parametros
                   WHERE sfinanci = v_sfinanci
                     AND nmovimi = v_max_nmovimi
                     AND cparam = 'UTIL_NETA';

                  IF v_existe_cuenta = 0 THEN
                    INSERT INTO fin_parametros
                      (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                    VALUES
                      (v_sfinanci, v_max_nmovimi, 'UTIL_NETA', f_user, f_sysdate, f_user, f_sysdate, NULL, NULL, ext.utlneta);
                  ELSE
                    UPDATE fin_parametros
                       SET tvalpar = ext.utlneta
                     WHERE sfinanci = v_sfinanci
                       AND nmovimi = v_max_nmovimi
                       AND cparam = 'UTIL_NETA';
                  END IF;

                  SELECT COUNT(*)
                    INTO v_existe_cuenta
                    FROM fin_parametros
                   WHERE sfinanci = v_sfinanci
                     AND nmovimi = v_max_nmovimi
                     AND cparam = 'INVENT';

                  IF v_existe_cuenta = 0 THEN
                    INSERT INTO fin_parametros
                      (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                    VALUES
                      (v_sfinanci, v_max_nmovimi, 'INVENT', f_user, f_sysdate, f_user, f_sysdate, NULL, NULL, ext.inventario);
                  ELSE
                    UPDATE fin_parametros
                       SET tvalpar = ext.inventario
                     WHERE sfinanci = v_sfinanci
                       AND nmovimi = v_max_nmovimi
                       AND cparam = 'INVENT';
                  END IF;

                  SELECT COUNT(*)
                    INTO v_existe_cuenta
                    FROM fin_parametros
                   WHERE sfinanci = v_sfinanci
                     AND nmovimi = v_max_nmovimi
                     AND cparam = 'CARTE_CLIE';

                  IF v_existe_cuenta = 0 THEN
                    INSERT INTO fin_parametros
                      (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                    VALUES
                      (v_sfinanci, v_max_nmovimi, 'CARTE_CLIE', f_user, f_sysdate, f_user, f_sysdate, NULL, NULL, ext.cartcliente);
                  ELSE
                    UPDATE fin_parametros
                       SET tvalpar = ext.cartcliente
                     WHERE sfinanci = v_sfinanci
                       AND nmovimi = v_max_nmovimi
                       AND cparam = 'CARTE_CLIE';
                  END IF;

                  SELECT COUNT(*)
                    INTO v_existe_cuenta
                    FROM fin_parametros
                   WHERE sfinanci = v_sfinanci
                     AND nmovimi = v_max_nmovimi
                     AND cparam = 'ACT_CORR';

                  IF v_existe_cuenta = 0 THEN
                    INSERT INTO fin_parametros
                      (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                    VALUES
                      (v_sfinanci, v_max_nmovimi, 'ACT_CORR', f_user, f_sysdate, f_user, f_sysdate, NULL, NULL, ext.actcorriente);
                  ELSE
                    UPDATE fin_parametros
                       SET tvalpar = ext.actcorriente
                     WHERE sfinanci = v_sfinanci
                       AND nmovimi = v_max_nmovimi
                       AND cparam = 'ACT_CORR';
                  END IF;

                  SELECT COUNT(*)
                    INTO v_existe_cuenta
                    FROM fin_parametros
                   WHERE sfinanci = v_sfinanci
                     AND nmovimi = v_max_nmovimi
                     AND cparam = 'PROP_PLNT_EQP';

                  IF v_existe_cuenta = 0 THEN
                    INSERT INTO fin_parametros
                      (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                    VALUES
                      (v_sfinanci, v_max_nmovimi, 'PROP_PLNT_EQP', f_user, f_sysdate, f_user, f_sysdate, NULL, NULL,
                       ext.propplanequipo);
                  ELSE
                    UPDATE fin_parametros
                       SET tvalpar = ext.propplanequipo
                     WHERE sfinanci = v_sfinanci
                       AND nmovimi = v_max_nmovimi
                       AND cparam = 'PROP_PLNT_EQP';
                  END IF;

                  SELECT COUNT(*)
                    INTO v_existe_cuenta
                    FROM fin_parametros
                   WHERE sfinanci = v_sfinanci
                     AND nmovimi = v_max_nmovimi
                     AND cparam = 'TOT_ACT_NO_CORR';

                  IF v_existe_cuenta = 0 THEN
                    INSERT INTO fin_parametros
                      (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                    VALUES
                      (v_sfinanci, v_max_nmovimi, 'TOT_ACT_NO_CORR', f_user, f_sysdate, f_user, f_sysdate, NULL, NULL,
                       ext.totactnocorriente);
                  ELSE
                    UPDATE fin_parametros
                       SET tvalpar = ext.totactnocorriente
                     WHERE sfinanci = v_sfinanci
                       AND nmovimi = v_max_nmovimi
                       AND cparam = 'TOT_ACT_NO_CORR';
                  END IF;

                  SELECT COUNT(*)
                    INTO v_existe_cuenta
                    FROM fin_parametros
                   WHERE sfinanci = v_sfinanci
                     AND nmovimi = v_max_nmovimi
                     AND cparam = 'ACT_TOTAL';

                  IF v_existe_cuenta = 0 THEN
                    INSERT INTO fin_parametros
                      (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                    VALUES
                      (v_sfinanci, v_max_nmovimi, 'ACT_TOTAL', f_user, f_sysdate, f_user, f_sysdate, NULL, NULL, ext.activototal);
                  ELSE
                    UPDATE fin_parametros
                       SET tvalpar = ext.activototal
                     WHERE sfinanci = v_sfinanci
                       AND nmovimi = v_max_nmovimi
                       AND cparam = 'ACT_TOTAL';
                  END IF;

                  SELECT COUNT(*)
                    INTO v_existe_cuenta
                    FROM fin_parametros
                   WHERE sfinanci = v_sfinanci
                     AND nmovimi = v_max_nmovimi
                     AND cparam = 'O_FIN_CORTO_PLAZO';

                  IF v_existe_cuenta = 0 THEN
                    INSERT INTO fin_parametros
                      (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                    VALUES
                      (v_sfinanci, v_max_nmovimi, 'O_FIN_CORTO_PLAZO', f_user, f_sysdate, f_user, f_sysdate, NULL, NULL,
                       ext.obligfinancp);
                  ELSE
                    UPDATE fin_parametros
                       SET tvalpar = ext.obligfinancp
                     WHERE sfinanci = v_sfinanci
                       AND nmovimi = v_max_nmovimi
                       AND cparam = 'O_FIN_CORTO_PLAZO';
                  END IF;

                  SELECT COUNT(*)
                    INTO v_existe_cuenta
                    FROM fin_parametros
                   WHERE sfinanci = v_sfinanci
                     AND nmovimi = v_max_nmovimi
                     AND cparam = 'PROVEE_CORTO_PLAZO';

                  IF v_existe_cuenta = 0 THEN
                    INSERT INTO fin_parametros
                      (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                    VALUES
                      (v_sfinanci, v_max_nmovimi, 'PROVEE_CORTO_PLAZO', f_user, f_sysdate, f_user, f_sysdate, NULL, NULL,
                       ext.proveedorescp);
                  ELSE
                    UPDATE fin_parametros
                       SET tvalpar = ext.proveedorescp
                     WHERE sfinanci = v_sfinanci
                       AND nmovimi = v_max_nmovimi
                       AND cparam = 'PROVEE_CORTO_PLAZO';
                  END IF;

                  SELECT COUNT(*)
                    INTO v_existe_cuenta
                    FROM fin_parametros
                   WHERE sfinanci = v_sfinanci
                     AND nmovimi = v_max_nmovimi
                     AND cparam = 'ATC_CORTO_PLAZO';

                  IF v_existe_cuenta = 0 THEN
                    INSERT INTO fin_parametros
                      (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                    VALUES
                      (v_sfinanci, v_max_nmovimi, 'ATC_CORTO_PLAZO', f_user, f_sysdate, f_user, f_sysdate, NULL, NULL,
                       ext.proveedorescp);
                  ELSE
                    UPDATE fin_parametros
                       SET tvalpar = ext.proveedorescp
                     WHERE sfinanci = v_sfinanci
                       AND nmovimi = v_max_nmovimi
                       AND cparam = 'ATC_CORTO_PLAZO';
                  END IF;

                  SELECT COUNT(*)
                    INTO v_existe_cuenta
                    FROM fin_parametros
                   WHERE sfinanci = v_sfinanci
                     AND nmovimi = v_max_nmovimi
                     AND cparam = 'ATC_CORTO_PLAZO';

                  IF v_existe_cuenta = 0 THEN
                    INSERT INTO fin_parametros
                      (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                    VALUES
                      (v_sfinanci, v_max_nmovimi, 'ATC_CORTO_PLAZO', f_user, f_sysdate, f_user, f_sysdate, NULL, NULL,
                       ext.anticipocp);
                  ELSE
                    UPDATE fin_parametros
                       SET tvalpar = ext.anticipocp
                     WHERE sfinanci = v_sfinanci
                       AND nmovimi = v_max_nmovimi
                       AND cparam = 'ATC_CORTO_PLAZO';
                  END IF;

                  SELECT COUNT(*)
                    INTO v_existe_cuenta
                    FROM fin_parametros
                   WHERE sfinanci = v_sfinanci
                     AND nmovimi = v_max_nmovimi
                     AND cparam = 'PAS_CORR';

                  IF v_existe_cuenta = 0 THEN
                    INSERT INTO fin_parametros
                      (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                    VALUES
                      (v_sfinanci, v_max_nmovimi, 'PAS_CORR', f_user, f_sysdate, f_user, f_sysdate, NULL, NULL, ext.pascorriente);
                  ELSE
                    UPDATE fin_parametros
                       SET tvalpar = ext.pascorriente
                     WHERE sfinanci = v_sfinanci
                       AND nmovimi = v_max_nmovimi
                       AND cparam = 'PAS_CORR';
                  END IF;

                  SELECT COUNT(*)
                    INTO v_existe_cuenta
                    FROM fin_parametros
                   WHERE sfinanci = v_sfinanci
                     AND nmovimi = v_max_nmovimi
                     AND cparam = 'O_FIN_LARGO_PLAZO';

                  IF v_existe_cuenta = 0 THEN
                    INSERT INTO fin_parametros
                      (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                    VALUES
                      (v_sfinanci, v_max_nmovimi, 'O_FIN_LARGO_PLAZO', f_user, f_sysdate, f_user, f_sysdate, NULL, NULL,
                       ext.obligfinanlp);
                  ELSE
                    UPDATE fin_parametros
                       SET tvalpar = ext.obligfinanlp
                     WHERE sfinanci = v_sfinanci
                       AND nmovimi = v_max_nmovimi
                       AND cparam = 'O_FIN_LARGO_PLAZO';
                  END IF;

                  SELECT COUNT(*)
                    INTO v_existe_cuenta
                    FROM fin_parametros
                   WHERE sfinanci = v_sfinanci
                     AND nmovimi = v_max_nmovimi
                     AND cparam = 'ATC_LARGO_PLAZO';

                  IF v_existe_cuenta = 0 THEN
                    INSERT INTO fin_parametros
                      (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                    VALUES
                      (v_sfinanci, v_max_nmovimi, 'ATC_LARGO_PLAZO', f_user, f_sysdate, f_user, f_sysdate, NULL, NULL,
                       ext.anticipolp);
                  ELSE
                    UPDATE fin_parametros
                       SET tvalpar = ext.anticipolp
                     WHERE sfinanci = v_sfinanci
                       AND nmovimi = v_max_nmovimi
                       AND cparam = 'ATC_LARGO_PLAZO';
                  END IF;

                  SELECT COUNT(*)
                    INTO v_existe_cuenta
                    FROM fin_parametros
                   WHERE sfinanci = v_sfinanci
                     AND nmovimi = v_max_nmovimi
                     AND cparam = 'PAS_NO_CORR';

                  IF v_existe_cuenta = 0 THEN
                    INSERT INTO fin_parametros
                      (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                    VALUES
                      (v_sfinanci, v_max_nmovimi, 'PAS_NO_CORR', f_user, f_sysdate, f_user, f_sysdate, NULL, NULL,
                       ext.totpascorriente);
                  ELSE
                    UPDATE fin_parametros
                       SET tvalpar = ext.totpascorriente
                     WHERE sfinanci = v_sfinanci
                       AND nmovimi = v_max_nmovimi
                       AND cparam = 'PAS_NO_CORR';
                  END IF;

                  SELECT COUNT(*)
                    INTO v_existe_cuenta
                    FROM fin_parametros
                   WHERE sfinanci = v_sfinanci
                     AND nmovimi = v_max_nmovimi
                     AND cparam = 'PAS_TOTAL';

                  IF v_existe_cuenta = 0 THEN
                    INSERT INTO fin_parametros
                      (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                    VALUES
                      (v_sfinanci, v_max_nmovimi, 'PAS_TOTAL', f_user, f_sysdate, f_user, f_sysdate, NULL, NULL, ext.pastotal);
                  ELSE
                    UPDATE fin_parametros
                       SET tvalpar = ext.pastotal
                     WHERE sfinanci = v_sfinanci
                       AND nmovimi = v_max_nmovimi
                       AND cparam = 'PAS_TOTAL';
                  END IF;

                  SELECT COUNT(*)
                    INTO v_existe_cuenta
                    FROM fin_parametros
                   WHERE sfinanci = v_sfinanci
                     AND nmovimi = v_max_nmovimi
                     AND cparam = 'PATRI_PERI_ANT';

                  IF v_existe_cuenta = 0 THEN
                    INSERT INTO fin_parametros
                      (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                    VALUES
                      (v_sfinanci, v_max_nmovimi, 'PATRI_PERI_ANT', f_user, f_sysdate, f_user, f_sysdate, NULL, NULL,
                       ext.patriperant);
                  ELSE
                    UPDATE fin_parametros
                       SET tvalpar = ext.patriperant
                     WHERE sfinanci = v_sfinanci
                       AND nmovimi = v_max_nmovimi
                       AND cparam = 'PATRI_PERI_ANT';
                  END IF;

                  SELECT COUNT(*)
                    INTO v_existe_cuenta
                    FROM fin_parametros
                   WHERE sfinanci = v_sfinanci
                     AND nmovimi = v_max_nmovimi
                     AND cparam = 'PATRI_ANO_ACTUAL';

                  IF v_existe_cuenta = 0 THEN
                    INSERT INTO fin_parametros
                      (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                    VALUES
                      (v_sfinanci, v_max_nmovimi, 'PATRI_ANO_ACTUAL', f_user, f_sysdate, f_user, f_sysdate, NULL, NULL,
                       ext.patrianoact);
                  ELSE
                    UPDATE fin_parametros
                       SET tvalpar = ext.patrianoact
                     WHERE sfinanci = v_sfinanci
                       AND nmovimi = v_max_nmovimi
                       AND cparam = 'PATRI_ANO_ACTUAL';
                  END IF;

                  SELECT COUNT(*)
                    INTO v_existe_cuenta
                    FROM fin_parametros
                   WHERE sfinanci = v_sfinanci
                     AND nmovimi = v_max_nmovimi
                     AND cparam = 'RESV_LEGAL';

                  IF v_existe_cuenta = 0 THEN
                    INSERT INTO fin_parametros
                      (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                    VALUES
                      (v_sfinanci, v_max_nmovimi, 'RESV_LEGAL', f_user, f_sysdate, f_user, f_sysdate, NULL, NULL, ext.reslegal);
                  ELSE
                    UPDATE fin_parametros
                       SET tvalpar = ext.reslegal
                     WHERE sfinanci = v_sfinanci
                       AND nmovimi = v_max_nmovimi
                       AND cparam = 'RESV_LEGAL';
                  END IF;

                  SELECT COUNT(*)
                    INTO v_existe_cuenta
                    FROM fin_parametros
                   WHERE sfinanci = v_sfinanci
                     AND nmovimi = v_max_nmovimi
                     AND cparam = 'CAP_SOCIAL';

                  IF v_existe_cuenta = 0 THEN
                    INSERT INTO fin_parametros
                      (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                    VALUES
                      (v_sfinanci, v_max_nmovimi, 'CAP_SOCIAL', f_user, f_sysdate, f_user, f_sysdate, NULL, NULL, ext.capsocial);
                  ELSE
                    UPDATE fin_parametros
                       SET tvalpar = ext.capsocial
                     WHERE sfinanci = v_sfinanci
                       AND nmovimi = v_max_nmovimi
                       AND cparam = 'CAP_SOCIAL';
                  END IF;

                  SELECT COUNT(*)
                    INTO v_existe_cuenta
                    FROM fin_parametros
                   WHERE sfinanci = v_sfinanci
                     AND nmovimi = v_max_nmovimi
                     AND cparam = 'RES_EJER_ANT';

                  IF v_existe_cuenta = 0 THEN
                    INSERT INTO fin_parametros
                      (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                    VALUES
                      (v_sfinanci, v_max_nmovimi, 'RES_EJER_ANT', f_user, f_sysdate, f_user, f_sysdate, NULL, NULL,
                       ext.resejerant);
                  ELSE
                    UPDATE fin_parametros
                       SET tvalpar = ext.resejerant
                     WHERE sfinanci = v_sfinanci
                       AND nmovimi = v_max_nmovimi
                       AND cparam = 'RES_EJER_ANT';
                  END IF;

                  SELECT COUNT(*)
                    INTO v_existe_cuenta
                    FROM fin_parametros
                   WHERE sfinanci = v_sfinanci
                     AND nmovimi = v_max_nmovimi
                     AND cparam = 'PRIMA_ACCION';

                  IF v_existe_cuenta = 0 THEN
                    INSERT INTO fin_parametros
                      (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                    VALUES
                      (v_sfinanci, v_max_nmovimi, 'PRIMA_ACCION', f_user, f_sysdate, f_user, f_sysdate, NULL, NULL, ext.pricolacc);
                  ELSE
                    UPDATE fin_parametros
                       SET tvalpar = ext.pricolacc
                     WHERE sfinanci = v_sfinanci
                       AND nmovimi = v_max_nmovimi
                       AND cparam = 'PRIMA_ACCION';
                  END IF;

                  SELECT COUNT(*)
                    INTO v_existe_cuenta
                    FROM fin_parametros
                   WHERE sfinanci = v_sfinanci
                     AND nmovimi = v_max_nmovimi
                     AND cparam = 'RESV_OCASI';

                  IF v_existe_cuenta = 0 THEN
                    INSERT INTO fin_parametros
                      (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                    VALUES
                      (v_sfinanci, v_max_nmovimi, 'RESV_OCASI', f_user, f_sysdate, f_user, f_sysdate, NULL, NULL,
                       ext.resocasional);
                  ELSE
                    UPDATE fin_parametros
                       SET tvalpar = ext.resocasional
                     WHERE sfinanci = v_sfinanci
                       AND nmovimi = v_max_nmovimi
                       AND cparam = 'RESV_OCASI';
                  END IF;

                  SELECT COUNT(*)
                    INTO v_existe_cuenta
                    FROM fin_parametros
                   WHERE sfinanci = v_sfinanci
                     AND nmovimi = v_max_nmovimi
                     AND cparam = 'VALORIZA';

                  IF v_existe_cuenta = 0 THEN
                    INSERT INTO fin_parametros
                      (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                    VALUES
                      (v_sfinanci, v_max_nmovimi, 'VALORIZA', f_user, f_sysdate, f_user, f_sysdate, NULL, NULL, ext.valorizacion);
                  ELSE
                    UPDATE fin_parametros
                       SET tvalpar = ext.valorizacion
                     WHERE sfinanci = v_sfinanci
                       AND nmovimi = v_max_nmovimi
                       AND cparam = 'VALORIZA';
                  END IF;

                  SELECT COUNT(*)
                    INTO v_existe_cuenta
                    FROM fin_parametros
                   WHERE sfinanci = v_sfinanci
                     AND nmovimi = v_max_nmovimi
                     AND cparam = 'ASIGNADO';

                  IF v_existe_cuenta = 0 THEN
                    INSERT INTO fin_parametros
                      (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                    VALUES
                      (v_sfinanci, v_max_nmovimi, 'ASIGNADO', f_user, f_sysdate, f_user, f_sysdate, NULL, NULL, ext.invsuplcap);
                  ELSE
                    UPDATE fin_parametros
                       SET tvalpar = ext.invsuplcap
                     WHERE sfinanci = v_sfinanci
                       AND nmovimi = v_max_nmovimi
                       AND cparam = 'ASIGNADO';
                  END IF;
                  
                  -- INICIO BUG - 7780 17/01/2020 - JRVG.
                  
                  SELECT COUNT(*)
                    INTO v_existe_cuenta
                    FROM fin_parametros
                   WHERE sfinanci = v_sfinanci
                     AND nmovimi = v_max_nmovimi
                     AND cparam = 'PATRI_LIQUIDO';

                  IF v_existe_cuenta = 0 THEN
                    INSERT INTO fin_parametros
                      (sfinanci, nmovimi, cparam, cusualt, falta, cusumod, fmodif, fvalpar, nvalpar, tvalpar)
                    VALUES
                      (v_sfinanci, v_max_nmovimi, 'PATRI_LIQUIDO', f_user, f_sysdate, f_user, f_sysdate, NULL, 
                       (ext.reslegal+ext.capsocial+ext.resejerant+ext.pricolacc+ext.resocasional+ext.invsuplcap),NULL);
                  ELSE
                    UPDATE fin_parametros
                       SET nvalpar = ext.patriliquido
                     WHERE sfinanci = v_sfinanci
                       AND nmovimi = v_max_nmovimi
                       AND cparam = 'PATRI_LIQUIDO';
                  END IF;
                   -- FIN BUG - 7780 17/01/2020 - JRVG.
                       
                END IF;
                -- FIN TCS_453B - 18/02/2019 - JLTS.
              END IF;
            END IF;
            -- INI TCS_453B - 18/02/2019 - JLTS - Se adiciona la condicin ext.fecestfinan porque estaba insertando datos nulos
            IF ext.feccordeclrenta IS NOT NULL THEN
              SELECT COUNT(*)
                INTO v_existe_d_renta
                FROM fin_d_renta
               WHERE sfinanci = v_sfinanci
                 AND fcorte = to_date(ext.feccordeclrenta, 'DD/MM/YYYY');

              IF v_existe_d_renta = 0 THEN
                -- INI TCS_453B - 18/02/2019 - JLTS - Se ajusta el ltimo campo que trae el caracter chr(13) retorno de carro
                INSERT INTO fin_d_renta
                  (sfinanci, fcorte, cesvalor, ipatriliq, irenta)
                VALUES
                  (v_sfinanci, to_date(ext.feccordeclrenta, 'DD/MM/YYYY'), '1', ext.patriliquido,
                   to_number(REPLACE(REPLACE(ext.renliqgrav, chr(10), ''), chr(13), ''),
                              '9999999999999D999',
                              'NLS_NUMERIC_CHARACTERS = '',.'''));
              ELSE
                UPDATE fin_d_renta
                   SET ipatriliq = ext.patriliquido,
                       irenta = to_number(REPLACE(REPLACE(ext.renliqgrav, chr(10), ''), chr(13), ''),
                                           '9999999999999D999',
                                           'NLS_NUMERIC_CHARACTERS = '',.''')
                 WHERE sfinanci = v_sfinanci
                   AND fcorte = to_date(ext.feccordeclrenta, 'DD/MM/YYYY');
              END IF;
            END IF;
          END IF;
       EXCEPTION
        WHEN OTHERS THEN
          ROLLBACK;
          v_nnumerr := 1000176;
          pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_nnumerr);
          pdeserror := f_axis_literales(103187, pac_md_common.f_get_cxtidioma) || SQLERRM||' - '||v_nit||' - '||v_numlinfile;
          p_tab_error(f_sysdate, f_user, vobj, v_pasexec, SQLCODE, SQLERRM, 10);
          v_tdeserror := null;
          FOR i IN mensajes.FIRST .. mensajes.LAST LOOP
            v_tdeserror := SUBSTR(v_tdeserror||mensajes(i).terror||chr(13),1,4000);
          END LOOP;
          v_nnumerr := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces, 
                                                                   ext.nlinea,
                                                                   3,
                                                                   pdeserror,
                                                                   NULL,
                                                                   1, 
                                                                   0, 
                                                                   NULL,
                                                                   ext.nit, 
                                                                   NULL, 
                                                                   NULL,
                                                                   NULL, 
                                                                   NULL, 
                                                                   NULL);
          v_nnumerr := pac_gestion_procesos.f_set_carga_ctrl_linea_error(psproces,
                                                                         ext.nlinea, 1,
                                                                         1, 151541,
                                                                         ext.nit);
          continue;
        END;
        END LOOP;

        v_pasexec := 1;
        IF PDESERROR IS NULL THEN 
          COMMIT;
        ELSE
          UPDATE int_carga_ctrl SET cestado = 3, cerror = 9903644, ffin = f_sysdate, cbloqueo = 0 WHERE sproces = psproces;
        END IF;
        RETURN 0;

      END f_trasp_tabla;
      --
    BEGIN
      vtraza := 0;

      IF psproces IS NULL THEN
        SELECT sproces.nextval INTO psproces FROM dual;
      END IF;

      vtraza := 1;

      IF p_cproces IS NULL THEN
        vnum_err  := 9901092;
        vdeserror := 'cfg_files falta proceso: ' || vobj;
        RAISE e_errdatos;
      END IF;

      --
      vtraza := 2;
      --
      vnum_err := f_modi_tabla_ext(p_nombre, p_path);

      IF vnum_err <> 0 THEN
        p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err, 'Error creando la tabla externa', 10);
        RAISE errorini;
      END IF;

      vnum_err := f_trasp_tabla(vdeserror, psproces);
      vtraza   := 3;
      IF vnum_err <> 0 THEN
        --
        vtraza   := 5;
        vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces,
                                                                   p_nombre,
                                                                   f_sysdate,
                                                                   NULL,
                                                                   1,
                                                                   p_cproces,
                                                                   NULL,
                                                                   vdeserror,
                                                                   0);
        vtraza   := 51;

        IF vnum_err <> 0 THEN
          p_tab_error(f_sysdate,
                      f_user,
                      vobj,
                      vtraza,
                      vnum_err,
                      'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera',
                      10);
          RAISE errorini;
        END IF;

        vtraza := 52;
        RAISE vsalir;
      END IF;

      RETURN 0;
    EXCEPTION
      WHEN vsalir THEN
        RETURN 103187; -- Error al leer el fichero
      WHEN e_errdatos THEN
        ROLLBACK;
        p_genera_logs(vobj, vtraza, 'Error:' || vnum_err, vdeserror);
        RETURN vnum_err;
      WHEN errorini THEN
        ROLLBACK;
        p_genera_logs(vobj, vtraza, 'Error:' || 'ErrorIni' || ' en :' || 1, 'Error:' || 'Insertando estados registros');
        RETURN 1;
      WHEN OTHERS THEN
        ROLLBACK;
        p_genera_logs(vobj, vtraza, 'Error:' || 'ErrorIni en 1', 'Error: Insertando estados registros');
        vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces,
                                                                   p_nombre,
                                                                   f_sysdate,
                                                                   NULL,
                                                                   1,
                                                                   p_cproces,
                                                                   151541,
                                                                   SQLERRM,
                                                                   0);
        vtraza   := 51;

        IF vnum_err <> 0 THEN
          p_tab_error(f_sysdate,
                      f_user,
                      vobj,
                      vtraza,
                      vnum_err,
                      'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera',
                      10);
        END IF;

        RETURN 1;
    END f_ejecutar_carga_fichero;

    --
  BEGIN
    vtraza := 0;

    IF pjob = 1 THEN
      vnum_err := pac_contexto.f_inicializarctx(nvl(pcusuari,
                                                    pac_parametros.f_parempresa_t(nvl(pac_md_common.f_get_cxtempresa,
                                                                                      f_parinstalacion_n('EMPRESADEF')),
                                                                                  'USER_BBDD')));
    END IF;

    IF psproces IS NULL OR (psproces IS NOT NULL AND pjob = 1) THEN
      vnum_err := f_ejecutar_carga_fichero(p_nombre, p_path, p_cproces, psproces);

      IF vnum_err <> 0 THEN
        RAISE vsalir;
      END IF;
    END IF;

    --p_control_error(f_user,'f_carga_finleco','04 vnum_err='||vnum_err);
    IF vnum_err <> 0 THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobj,
                  vtraza,
                  vnum_err,
                  'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera',
                  10);
      RAISE vsalir;
    END IF;

/* INI - IAXIS-5154 - JLTS - 09/09/2019 Se elimina el código
    UPDATE int_carga_ctrl SET cestado = vnum_err, ffin = f_sysdate, cbloqueo = 0 WHERE sproces = psproces;
   INI - IAXIS-5154 - JLTS - 09/09/2019 Se elimina el código */
    COMMIT;
    RETURN 0;
  EXCEPTION
    WHEN vsalir THEN
      RETURN vnum_err;
  END f_carga_finleco;

    --
    FUNCTION f_finleco(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN VARCHAR2,
      psproces IN OUT NUMBER)
      RETURN NUMBER IS
      vmensaje       NUMBER;
   BEGIN
      --
      IF psproces IS NULL THEN
         SELECT sproces.NEXTVAL
           INTO psproces
           FROM DUAL;
         vmensaje := pac_cargas_conf.f_carga_finleco(p_nombre, p_path, p_cproces,
                                                             psproces, 1, f_user);

         IF vmensaje <> 0 THEN
            RETURN 9903644; -- INI - IAXIS-5154 - JLTS - 09/09/2019 Se actualizó el código de error 180856 a 9903644
         END IF;
      END IF;

      --
      RETURN 0;
   END f_finleco;


--AAC_INI-CONF_OUTSOURCING-20160906
   FUNCTION f_carga_gescar(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      p_sproces IN OUT NUMBER)
      RETURN NUMBER IS
      v_fic          UTL_FILE.file_type;
      b_con          BOOLEAN := TRUE;
      v_lin          VARCHAR2(4000);
      v_num_lin      NUMBER := 0;
      v_charfecha    VARCHAR2(50);
      vnum_err       NUMBER;
      v_msg          VARCHAR2(500);
      v_nrecibo      VARCHAR2(200);
      v_cegescar     VARCHAR2(200);
      x_cegescar     NUMBER:= 0;
      v_pas          NUMBER := 0;
      vobjectname    VARCHAR2(500) := 'pac_cargas_conf.f_carga_gescar';
      v_par          VARCHAR2(2000)
         := 'p_nombre=' || p_nombre || ';p_path=' || p_path || 'p_cproces=' || p_cproces
            || ';psproces= ' || p_sproces;
      v_sep          VARCHAR2(5) := ';';

         
   BEGIN
      --Revisar parametros
      v_pas := 1;

      IF p_nombre IS NULL THEN
         RAISE e_param_error;
      END IF;

      --Recuperar sproces siguiente.
      v_pas := 2;

      SELECT sproces.NEXTVAL
        INTO p_sproces
        FROM DUAL;

      --Recuperar fecha formateada
      SELECT TO_CHAR(SYSDATE, 'YYYYMMDDHHMISS')
        INTO v_charfecha
        FROM DUAL;

      --Registrar proceso
      v_pas := 3;
      vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(p_sproces, p_nombre,
                                                                 f_sysdate, NULL, 3, p_cproces,
                                                                 NULL, v_msg);
      --Abrir fichero
      v_pas := 4;
      v_fic := UTL_FILE.fopen(p_path, p_nombre, 'r');
      --Tratar fichero
      v_pas := 5;
      UTL_FILE.get_line(v_fic, v_lin);   --TITULO
      UTL_FILE.get_line(v_fic, v_lin);   --CABECERA
      v_num_lin := 2;

      WHILE b_con LOOP
         BEGIN
            v_num_lin := v_num_lin + 1;
            vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces => p_sproces,
                                                                    pnlinea => v_num_lin,
                                                                    pctipo => 20,
                                                                    pidint => v_num_lin,
                                                                    pidext => v_num_lin,
                                                                    pcestado => 3,
                                                                    pcvalidado => NULL,
                                                                    psseguro => NULL,
                                                                    pidexterno => NULL,
                                                                    pncarga => NULL,
                                                                    pnsinies => NULL,
                                                                    pntramit => NULL,
                                                                    psperson => NULL,
                                                                    pnrecibo => NULL);
            --recupero linia
            UTL_FILE.get_line(v_fic, v_lin);
            v_pas := 51;
            -- Tratamiento linea
            -- Primer campo (recibos)
            v_pas := 52;
            v_nrecibo := pac_util.splitt(v_lin, 1, v_sep);
            -- Segundo campo (cgescar)
            v_pas := 53;
             v_cegescar := upper(pac_util.splitt(v_lin, 2, v_sep));
            v_pas := 54;

            BEGIN
             -- INI IAXIS-5241 JRVG 14/04/2020 
             insert into outsorcing_ext (nrecibo, aplica_out,cgescar,cproces, fcarga) values (v_nrecibo,v_cegescar,null,p_sproces,f_sysdate);
             -- INI IAXIS-5241 JRVG 14/04/2020  
            EXCEPTION
               WHEN OTHERS THEN
                  vnum_err :=
                     pac_gestion_procesos.f_set_carga_ctrl_linea(psproces => p_sproces,
                                                                 pnlinea => v_num_lin,
                                                                 pctipo => 20,
                                                                 pidint => v_num_lin,
                                                                 pidext => v_num_lin,
                                                                 pcestado => 1,
                                                                 pcvalidado => NULL,
                                                                 psseguro => NULL,
                                                                 pidexterno => NULL,
                                                                 pncarga => NULL,
                                                                 pnsinies => NULL,
                                                                 pntramit => NULL,
                                                                 psperson => NULL,
                                                                 pnrecibo => NULL);
                  vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea_error(p_sproces,
                                                                                v_num_lin, 1,
                                                                                1, 102358,
                                                                                v_nrecibo);
                  p_tab_error(f_sysdate, f_user, vobjectname, v_pas || ' ' || vnum_err,
                              vobjectname, SQLERRM);
            END;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces => p_sproces,
                                                                       pnlinea => v_num_lin,
                                                                       pctipo => 20,
                                                                       pidint => v_num_lin,
                                                                       pidext => v_num_lin,
                                                                       pcestado => 1,
                                                                       pcvalidado => NULL,
                                                                       psseguro => NULL,
                                                                       pidexterno => NULL,
                                                                       pncarga => NULL,
                                                                       pnsinies => NULL,
                                                                       pntramit => NULL,
                                                                       psperson => NULL,
                                                                       pnrecibo => NULL);
               vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea_error(p_sproces,
                                                                             v_num_lin, 1, 1,
                                                                             102358,
                                                                             v_nrecibo);
               b_con := FALSE;
            WHEN OTHERS THEN
               vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces => p_sproces,
                                                                       pnlinea => v_num_lin,
                                                                       pctipo => 20,
                                                                       pidint => v_num_lin,
                                                                       pidext => v_num_lin,
                                                                       pcestado => 1,
                                                                       pcvalidado => NULL,
                                                                       psseguro => NULL,
                                                                       pidexterno => NULL,
                                                                       pncarga => NULL,
                                                                       pnsinies => NULL,
                                                                       pntramit => NULL,
                                                                       psperson => NULL,
                                                                       pnrecibo => NULL);
               vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea_error(p_sproces,
                                                                             v_num_lin, 1, 1,
                                                                             102358,
                                                                             v_nrecibo);
               b_con := FALSE;
         END;

         vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces => p_sproces,
                                                                 pnlinea => v_num_lin,
                                                                 pctipo => 20,
                                                                 pidint => v_num_lin,
                                                                 pidext => v_num_lin,
                                                                 pcestado => 1,
                                                                 pcvalidado => NULL,
                                                                 psseguro => NULL,
                                                                 pidexterno => NULL,
                                                                 pncarga => NULL,
                                                                 pnsinies => NULL,
                                                                 pntramit => NULL,
                                                                 psperson => NULL,
                                                                 pnrecibo => NULL);
         vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea_error(p_sproces, v_num_lin, 1,
                                                                       1, 102358, v_nrecibo);
         v_pas := 55;
      END LOOP;
      
       -- INI IAXIS-5241 JRVG 14/04/2020
       UTL_FILE.FCLOSE(v_fic); -- cerrar el archivo abierto
       -- FIN IAXIS-5241 JRVG 14/04/2020
      COMMIT;
      v_pas := 7;
      vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(p_sproces, p_nombre,
                                                                 f_sysdate, NULL, 4, p_cproces,
                                                                 NULL, '');
   -- INI IAXIS-5241 JRVG 14/04/2020
      BEGIN  
        update outsorcing_ext t
           set t.cgescar = 1
         where t.aplica_out like 'N%'; 
        update outsorcing_ext t
           set t.cgescar = 2
         where t.aplica_out like '%S%';
         commit; 
         -- Se realiza update del campo cgescar - tabla recibos
         pac_cargas_conf.p_update_cgescar(p_sproces);
         -- Borramos el historial del cargue 
         Delete outsorcing_ext where cproces = p_sproces ;
         commit;
         
         v_pas := 8;
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;
   -- FIN IAXIS-5241 JRVG 14/04/2020
     
      RETURN 0;
   EXCEPTION
      WHEN e_format_error THEN
         vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(p_sproces, p_nombre,
                                                                    f_sysdate, NULL, 1,
                                                                    p_cproces, NULL, '');
         RETURN -99;
      WHEN e_param_error THEN
         vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(p_sproces, p_nombre,
                                                                    f_sysdate, NULL, 1,
                                                                    p_cproces, NULL, '');
         RETURN -99;
      WHEN e_rename_error THEN
         vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(p_sproces, p_nombre,
                                                                    f_sysdate, NULL, 1,
                                                                    p_cproces, NULL, '');
         RETURN -99;
      WHEN OTHERS THEN
         vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(p_sproces, p_nombre,
                                                                    f_sysdate, NULL, 1,
                                                                    p_cproces, NULL, '');
         p_tab_error(f_sysdate, f_user, vobjectname, v_pas || ' ' || vnum_err, v_par, SQLERRM);
         RETURN -99;
   END f_carga_gescar;

   FUNCTION f_carga_gescar_agen(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      p_sproces IN OUT NUMBER)
      RETURN NUMBER IS
      v_fic          UTL_FILE.file_type;
      b_con          BOOLEAN := TRUE;
      v_lin          VARCHAR2(4000);
      v_num_lin      NUMBER := 0;
      v_charfecha    VARCHAR2(50);
      vnum_err       NUMBER;
      v_msg          VARCHAR2(500);
      v_nrecibo      VARCHAR2(200);
      v_cegescar     VARCHAR2(200);
      v_estado       VARCHAR2(200);
      v_observa      VARCHAR2(200);
      v_fecha_com    VARCHAR2(200);
      v_atentido     VARCHAR2(200);
      v_fecha        VARCHAR2(200);
      v_seleccion    VARCHAR2(200);
      v_poliza       VARCHAR2(200);
      v_recibo       VARCHAR2(200);
      v_sep          VARCHAR2(5) := ';';
      v_pas          NUMBER := 0;
      vobjectname    VARCHAR2(500) := 'pac_cargas_conf.f_carga_gescar_agen';
      v_par          VARCHAR2(2000)
         := 'p_nombre=' || p_nombre || ';p_path=' || p_path || 'p_cproces=' || p_cproces
            || ';psproces= ' || p_sproces;
   BEGIN
      --Revisar parametros
      v_pas := 1;

      IF p_nombre IS NULL THEN
         RAISE e_param_error;
      END IF;

      --Recuperar sproces siguiente.
      v_pas := 2;

      SELECT sproces.NEXTVAL
        INTO p_sproces
        FROM DUAL;

      --Recuperar fecha formateada
      SELECT TO_CHAR(SYSDATE, 'YYYYMMDDHHMISS')
        INTO v_charfecha
        FROM DUAL;

      --Registrar proceso
      v_pas := 3;
      vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(p_sproces, p_nombre,
                                                                 f_sysdate, NULL, 3, p_cproces,
                                                                 NULL, v_msg);
      --Abrir fichero
      v_pas := 4;
      v_fic := UTL_FILE.fopen(p_path, p_nombre, 'r');
      --Tratar fichero
      v_pas := 5;
      --UTL_FILE.get_line(v_fic, v_lin);--TITULO
      UTL_FILE.get_line(v_fic, v_lin);   --CABECERA
      v_num_lin := 2;

      WHILE b_con LOOP
         BEGIN
            vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces => p_sproces,
                                                                    pnlinea => v_num_lin,
                                                                    pctipo => 20,
                                                                    pidint => v_num_lin,
                                                                    pidext => v_num_lin,
                                                                    pcestado => 3,
                                                                    pcvalidado => NULL,
                                                                    psseguro => NULL,
                                                                    pidexterno => NULL,
                                                                    pncarga => NULL,
                                                                    pnsinies => NULL,
                                                                    pntramit => NULL,
                                                                    psperson => NULL,
                                                                    pnrecibo => NULL);
            v_num_lin := v_num_lin + 1;
            --recupero linia
            UTL_FILE.get_line(v_fic, v_lin);
            v_pas := 50;
            -- Tratamiento linea
            -- Primer campo (recibos)
            v_pas := 51;
            v_nrecibo := pac_util.splitt(v_lin, 8, v_sep);
            v_pas := 52;
            v_nrecibo := pac_util.splitt(v_lin, 2, v_sep);
            -- Actualizacion tabla
            v_pas := 54;

            BEGIN
               vnum_err :=
                  pac_prenotificaciones.f_agd_observaciones(pac_md_common.f_get_cxtempresa,
                                                            v_nrecibo, v_observa);
            EXCEPTION
               WHEN OTHERS THEN
                  vnum_err :=
                     pac_gestion_procesos.f_set_carga_ctrl_linea(psproces => p_sproces,
                                                                 pnlinea => v_num_lin,
                                                                 pctipo => 20,
                                                                 pidint => v_num_lin,
                                                                 pidext => v_num_lin,
                                                                 pcestado => 1,
                                                                 pcvalidado => NULL,
                                                                 psseguro => NULL,
                                                                 pidexterno => NULL,
                                                                 pncarga => NULL,
                                                                 pnsinies => NULL,
                                                                 pntramit => NULL,
                                                                 psperson => NULL,
                                                                 pnrecibo => NULL);
                  vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea_error(p_sproces,
                                                                                v_num_lin, 1,
                                                                                1, 102358,
                                                                                v_nrecibo);
                  p_tab_error(f_sysdate, f_user, vobjectname, v_pas || ' ' || vnum_err,
                              vobjectname, SQLERRM);
            END;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces => p_sproces,
                                                                       pnlinea => v_num_lin,
                                                                       pctipo => 20,
                                                                       pidint => v_num_lin,
                                                                       pidext => v_num_lin,
                                                                       pcestado => 1,
                                                                       pcvalidado => NULL,
                                                                       psseguro => NULL,
                                                                       pidexterno => NULL,
                                                                       pncarga => NULL,
                                                                       pnsinies => NULL,
                                                                       pntramit => NULL,
                                                                       psperson => NULL,
                                                                       pnrecibo => NULL);
               vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea_error(p_sproces,
                                                                             v_num_lin, 1, 1,
                                                                             102358,
                                                                             v_nrecibo);
               b_con := FALSE;
            WHEN OTHERS THEN
               vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces => p_sproces,
                                                                       pnlinea => v_num_lin,
                                                                       pctipo => 20,
                                                                       pidint => v_num_lin,
                                                                       pidext => v_num_lin,
                                                                       pcestado => 1,
                                                                       pcvalidado => NULL,
                                                                       psseguro => NULL,
                                                                       pidexterno => NULL,
                                                                       pncarga => NULL,
                                                                       pnsinies => NULL,
                                                                       pntramit => NULL,
                                                                       psperson => NULL,
                                                                       pnrecibo => NULL);
               vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea_error(p_sproces,
                                                                             v_num_lin, 1, 1,
                                                                             102358,
                                                                             v_nrecibo);
               b_con := FALSE;
         END;

         vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces => p_sproces,
                                                                 pnlinea => v_num_lin,
                                                                 pctipo => 20,
                                                                 pidint => v_num_lin,
                                                                 pidext => v_num_lin,
                                                                 pcestado => 1,
                                                                 pcvalidado => NULL,
                                                                 psseguro => NULL,
                                                                 pidexterno => NULL,
                                                                 pncarga => NULL,
                                                                 pnsinies => NULL,
                                                                 pntramit => NULL,
                                                                 psperson => NULL,
                                                                 pnrecibo => NULL);
         vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea_error(p_sproces, v_num_lin, 1,
                                                                       1, 102358, v_nrecibo);
         v_pas := 55;
      END LOOP;

      BEGIN
         v_pas := 6;
      --UTL_FILE.FRENAME(p_path,p_nombre,p_path, p_nombre || '_procesado_' || v_charfecha);
      EXCEPTION
         WHEN OTHERS THEN
            RAISE e_rename_error;
      END;

      COMMIT;
      v_pas := 7;
      vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(p_sproces, p_nombre,
                                                                 f_sysdate, NULL, 4, p_cproces,
                                                                 NULL, '');
      v_pas := 8;
      RETURN 0;
   EXCEPTION
      WHEN e_format_error THEN
         vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(p_sproces, p_nombre,
                                                                    f_sysdate, NULL, 1,
                                                                    p_cproces, NULL, '');
         RETURN -99;
      WHEN e_param_error THEN
         vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(p_sproces, p_nombre,
                                                                    f_sysdate, NULL, 1,
                                                                    p_cproces, NULL, '');
         RETURN -99;
      WHEN e_rename_error THEN
         vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(p_sproces, p_nombre,
                                                                    f_sysdate, NULL, 1,
                                                                    p_cproces, NULL, '');
         RETURN -99;
      WHEN OTHERS THEN
         vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(p_sproces, p_nombre,
                                                                    f_sysdate, NULL, 1,
                                                                    p_cproces, NULL, '');
         p_tab_error(f_sysdate, f_user, vobjectname, v_pas || ' ' || vnum_err, v_par, SQLERRM);
         RETURN -99;
   END f_carga_gescar_agen;

   --AAC_FI-CONF_OUTSOURCING-20160906

   --AAC_INI-CONF_379-20160927
   FUNCTION f_modi_tabla_corte_fac(p_nombre VARCHAR2, p_path IN VARCHAR2, p_cproceso VARCHAR2)
      RETURN NUMBER IS
      v_tnomfich     VARCHAR2(100);
      v_pas          NUMBER := 0;
      v_tip_proc     VARCHAR2(50);
      v_objectname   VARCHAR2(500) := 'pac_cargas_conf.f_modi_tabla_corte_fac';
      v_par          VARCHAR2(2000)
                                   := 'p_nombre=' || p_nombre || '; p_cproceso=' || p_cproceso;
   BEGIN
      v_pas := 1;

      IF p_nombre IS NULL THEN
         RAISE e_param_error;
      END IF;

      v_pas := 2;

      IF p_cproceso IS NULL THEN
         RAISE e_param_error;
      ELSE
         SELECT DECODE(cproceso,
                       302, 'INT_FACTURAS_AGENTE_AON',
                       --Pesos
                       303, 'INT_FACTURAS_AGENTE_CORRECOL',
                       304, 'INT_FACTURAS_AGENTE_HELM',
                       305, 'INT_FACTURAS_AGENTE_WACOLDA',
                       306, 'INT_FACTURAS_AGENTE_WILLIS',
                       307, 'INT_FACTURAS_AGENTE_AON',

                       --Dolares
                       'INT_FACTURAS_AGENTE')
           INTO v_tip_proc
           FROM cfg_files
          WHERE cproceso = p_cproceso;
      END IF;

      v_pas := 3;
      v_tnomfich := SUBSTR(p_nombre, 1, INSTR(p_nombre, '.') - 1);
      v_pas := 4;

      IF v_tip_proc = 'INT_FACTURAS_AGENTE_WILLIS' THEN
         v_pas := 51;

         EXECUTE IMMEDIATE 'alter table INT_FACT_AGENTES_WILLIS_EXT ACCESS PARAMETERS (records delimited by 0x''0A''
                         logfile '
                           || CHR(39) || v_tnomfich || '.log' || CHR(39)
                           || '
                         badfile ' || CHR(39) || v_tnomfich || '.bad' || CHR(39)
                           || '
                         discardfile ' || CHR(39) || v_tnomfich || '.dis' || CHR(39)
                           || '
                         fields terminated by ''|'' lrtrim
                         MISSING FIELD VALUES ARE NULL
                         REJECT ROWS WITH ALL NULL FIELDS
                         (  RECIBO
                          , FRECAU DATE  MASK "DD/MM/YYYY"
                          , MONRECAU
                          , NFACTURA
                          , FFACT DATE  MASK "DD/MM/YYYY"
                          , PENDPAG
                          , TOTTRANSAC
                          , PORCOMISI
                          , PORPARTICI
                          , PRIMA
                          , IVAPRIMA
                          , VRCOMISI
                          , IVACOMISI
                          , COMISIVA
                          , NITTOMAD
                          , NOMTOMAD
                          , REGTOMAD
                          , NREFER
                          , NCARAT
                          , NVERSION
                          , NITASEGUR
                          , NOMASEGUR
                          , NRAMO
                          , NPOLIZA
                          , NCERTIF
                          , TIPRECAUD
                          , NOMUSU
                          , NETPAG
                        ))';

         /*Cargamos el fichero*/
         v_pas := 61;

         EXECUTE IMMEDIATE 'ALTER TABLE INT_FACT_AGENTES_WILLIS_EXT LOCATION (' || p_path
                           || ':''' || p_nombre || ''')';
      END IF;

      IF v_tip_proc = 'INT_FACTURAS_AGENTE_WACOLDA' THEN
         v_pas := 52;

         EXECUTE IMMEDIATE 'alter table INT_FACT_AGENTES_WACOLDA_EXT ACCESS PARAMETERS (records delimited by 0x''0A''
                         logfile '
                           || CHR(39) || v_tnomfich || '.log' || CHR(39)
                           || '
                         badfile ' || CHR(39) || v_tnomfich || '.bad' || CHR(39)
                           || '
                         discardfile ' || CHR(39) || v_tnomfich || '.dis' || CHR(39)
                           || '
                         fields terminated by ''|'' lrtrim
                         MISSING FIELD VALUES ARE NULL
                         REJECT ROWS WITH ALL NULL FIELDS
                         (  RAMPROD
                          , CODRAM
                          , NPOLIZA
                          , NDOCUM
                          , PORCOMISI
                          , VRRECAU
                          , VRCOMISI
                          , PRIMAS
                          , IVAGASTOS
                          , IVACOM
                          , NETO
                          , REMISI
                          , FECHA DATE  MASK "DD/MM/YYYY"
                          , RC
                          , FPAGO DATE  MASK "DD/MM/YYYY"
                          , PIVACOM
                        ))';

         /*Cargamos el fichero*/
         v_pas := 62;

         EXECUTE IMMEDIATE 'ALTER TABLE INT_FACT_AGENTES_WACOLDA_EXT LOCATION (' || p_path
                           || ':''' || p_nombre || ''')';
      END IF;

      IF v_tip_proc = 'INT_FACTURAS_AGENTE_HELM' THEN
         v_pas := 53;

         EXECUTE IMMEDIATE 'alter table INT_FACT_AGENTES_HELM_EXT ACCESS PARAMETERS (records delimited by 0x''0A''
                         logfile '
                           || CHR(39) || v_tnomfich || '.log' || CHR(39)
                           || '
                         badfile ' || CHR(39) || v_tnomfich || '.bad' || CHR(39)
                           || '
                         discardfile ' || CHR(39) || v_tnomfich || '.dis' || CHR(39)
                           || '
                         fields terminated by ''|'' lrtrim
                         MISSING FIELD VALUES ARE NULL
                         REJECT ROWS WITH ALL NULL FIELDS
                         (  NITASEGURA
                          , NOMASEGURA
                          , NITTOMADOR
                          , NOMTOMADOR
                          , NOMCIUDAD
                          , TIPREC
                          , COMREC
                          , NRECIBO
                          , SECUENCIA
                          , FPAGO DATE  MASK "DD/MM/YYYY"
                          , NITRESPON
                          , NOMRESPON
                          , CONCEPTO
                          , TIPO
                          , COMPROB
                          , REMISION
                          , NPOLIZA
                          , NCERTIF
                          , VPAGO
                          , PLACA
                          , RAMO
                          , VCOMISI
                          , VCOMISIADI
                          , VPRIMA
                          , VIVA
                          , VOTROS
                          , TPRIMA
                          , VIGPOLINI DATE  MASK "DD/MM/YYYY"
                          , VIGPOLFIN DATE  MASK "DD/MM/YYYY"
                          , VIGCERTIFINI DATE  MASK "DD/MM/YYYY"
                          , VIGCERTIFFIN DATE  MASK "DD/MM/YYYY"
                          , PORIVA
                          , PORCENT
                          , VRCOMIGR
                          , VRCOMINOGR
                          , VRIVACOMISI
                          , VRIVARETEN
                          , VRTOTCOMISI
                        ))';

         /*Cargamos el fichero*/
         v_pas := 63;

         EXECUTE IMMEDIATE 'ALTER TABLE INT_FACT_AGENTES_HELM_EXT LOCATION (' || p_path
                           || ':''' || p_nombre || ''')';
      END IF;

      IF v_tip_proc = 'INT_FACTURAS_AGENTE_CORRECOL' THEN
         v_pas := 54;

         EXECUTE IMMEDIATE 'alter table INT_FACT_AGENTES_CORRECOL_EXT ACCESS PARAMETERS (records delimited by 0x''0A''
                         logfile '
                           || CHR(39) || v_tnomfich || '.log' || CHR(39)
                           || '
                         badfile ' || CHR(39) || v_tnomfich || '.bad' || CHR(39)
                           || '
                         discardfile ' || CHR(39) || v_tnomfich || '.dis' || CHR(39)
                           || '
                         fields terminated by ''|'' lrtrim
                         MISSING FIELD VALUES ARE NULL
                         REJECT ROWS WITH ALL NULL FIELDS
                         (  TIPOPAG
                          , NDOCUMEN
                          , FRECI DATE  MASK "DD/MM/YYYY"
                          , CODCLIE
                          , CODCLIE2
                          , VTOTAL
                          , VDESCAR
                          , DEPOSITO
                          , ESPRIMA
                          , ESINGRESO
                          , ESPECIAL
                          , TIPODESC
                          , CODCIA
                          , SIGLA
                          , NPOLIZA
                          , NCERTIF
                          , NCTA
                          , SALPRIMA
                          , SALGASTOS
                          , SALIVA
                          , SALTOTAL
                          , PORCOMI
                          , SALCOMISI
                          , DSCTOCOMI
                          , FABONO
                          , NOTAPAGO
                          , NCORTE
                          , SEQFACT
                          , CERRADO
                          , TECNICO
                          , SOCIO
                          , COMERCIAL
                          , ESTADO
                          , FESTADO DATE  MASK "DD/MM/YYYY"
                          , NOMTOMAD
                          , NOMASEGURA
                          , NOMCIA
                          , USUARIO
                          , FECINTE DATE  MASK "DD/MM/YYYY"
                          , PORPARTI
                          , PJEINT
                          , NPLAGE
                          , NCOMP
                          , FCOMP
                          , VCOMP
                          , PLACA
                          , TIPNEG
                          , DEVEFEC
                          , SOCIORI
                          , CORPORATIVO
                          , RAMOCIA
                          , CMONEDA
                          , PRIDOLAR
                          , TRMCIA
                          , INNOCORR
                          , VEFEC
                          , VCHEQ
                          , VPAGARE
                          , NPAGARE
                          , NCHEQ
                          , BANCO
                          , NTARJE
                          , ENTITARJE
                          , VOTROS
                          , VAPLICA
                          , SAP
                          , FSAP
                        ))';

         /*Cargamos el fichero*/
         v_pas := 64;

         EXECUTE IMMEDIATE 'ALTER TABLE INT_FACT_AGENTES_CORRECOL_EXT LOCATION (' || p_path
                           || ':''' || p_nombre || ''')';
      END IF;

      IF v_tip_proc = 'INT_FACTURAS_AGENTE_AON' THEN
         v_pas := 55;

         EXECUTE IMMEDIATE 'alter table INT_FACT_AGENTES_AON_EXT ACCESS PARAMETERS (records delimited by 0x''0A''
                         logfile '
                           || CHR(39) || v_tnomfich || '.log' || CHR(39)
                           || '
                         badfile ' || CHR(39) || v_tnomfich || '.bad' || CHR(39)
                           || '
                         discardfile ' || CHR(39) || v_tnomfich || '.dis' || CHR(39)
                           || '
                         fields terminated by ''|'' lrtrim
                         MISSING FIELD VALUES ARE NULL
                         REJECT ROWS WITH ALL NULL FIELDS
                         (  NOMCLIENTE
                          , NITCLIENTE
                          , NOMSUCUR
                                  , NOMTOMAD
                                , NITTOMAD
                          , FCORTE DATE  MASK "DD/MM/YYYY"
                          , NLIQUIDACION
                          , NOMASEGURA
                          , DESCRAMO
                          , NPOLIZA
                          , NANEXO
                          , NORDEN
                          , NCOMPROB
                          , TCOBRANZA
                          , NFACT
                          , CTAMON
                          , PMAPROP
                          , IMPPAGO
                          , TCML
                          , PAGOML
                          , IVAPRIMA
                          , COMFIJA
                          , NCERTIF
                          , PORCOMISI
                          , COMTOTAL
                          , COMML
                          , IVACOMISI
                          , IVACOMML
                          , NETOREMI
                          , NETOREMIML
                        )) REJECT LIMIT UNLIMITED';

         /*Cargamos el fichero*/
         v_pas := 65;

         EXECUTE IMMEDIATE 'ALTER TABLE INT_FACT_AGENTES_AON_EXT LOCATION (' || p_path
                           || ':''' || p_nombre || ''')';
      END IF;

      IF v_tip_proc = 'INT_FACTURAS_AGENTE' THEN
         v_pas := 56;

         EXECUTE IMMEDIATE 'alter table INT_FACTURAS_AGENTES_EXT ACCESS PARAMETERS (records delimited by 0x''0A''
                         logfile '
                           || CHR(39) || v_tnomfich || '.log' || CHR(39)
                           || '
                         badfile ' || CHR(39) || v_tnomfich || '.bad' || CHR(39)
                           || '
                         discardfile ' || CHR(39) || v_tnomfich || '.dis' || CHR(39)
                           || '
                         fields terminated by ''|'' lrtrim
                         MISSING FIELD VALUES ARE NULL
                         REJECT ROWS WITH ALL NULL FIELDS
                         ( CAGENTE,
                           NRECIBO,
                           FCOBRO DATE  MASK "DDMMYYYY",
                           CORTECUENTA,
                           CMONEDA,
                           ITOTALR,
                           ICOMISION,
                           IVA,
                           IRETEFUENTE,
                           IRETEIVA,
                           IRETEICA
                        ))';

         /*Cargamos el fichero*/
         v_pas := 66;

         EXECUTE IMMEDIATE 'ALTER TABLE INT_FACTURAS_AGENTES_EXT LOCATION (' || p_path
                           || ':''' || p_nombre || ''')';
      END IF;

      v_pas := 7;
      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_objectname, v_pas,
                     'Error creando la tabla.: ' || v_par, SQLERRM);
         RETURN 107914;
   END f_modi_tabla_corte_fac;

   PROCEDURE p_trasp_tabla_corte_fac(
      p_sproces IN VARCHAR2,
      p_cproceso IN VARCHAR2,
      p_deserror IN OUT VARCHAR2) IS
      v_pas          NUMBER := 0;
      v_tip_proc     VARCHAR2(50);
      v_objectname   VARCHAR2(500) := 'pac_cargas_conf.f_trasp_tabla_corte_fac';
      v_par          VARCHAR2(2000)
                                 := 'p_sproces=' || p_sproces || '; p_cproceso=' || p_cproceso;
   BEGIN
      v_pas := 1;

      IF p_sproces IS NULL THEN
         RAISE e_param_error;
      END IF;

      v_pas := 2;

      IF p_cproceso IS NULL THEN
         RAISE e_param_error;
      ELSE
         SELECT DECODE(cproceso,
                       300, 'INT_LIST_CORTE_PROD',
                       302, 'INT_FACTURAS_AGENTE_AON_P',
                       303, 'INT_FACTURAS_AGENTE_CORRECOL',
                       304, 'INT_FACTURAS_AGENTE_HELM',
                       305, 'INT_FACTURAS_AGENTE_WACOLDA',
                       306, 'INT_FACTURAS_AGENTE_WILLIS',
                       307, 'INT_FACTURAS_AGENTE_AON_D',
                       'INT_FACTURAS_AGENTE')
           INTO v_tip_proc
           FROM cfg_files
          WHERE cproceso = p_cproceso;
      END IF;

      v_pas := 3;

      IF v_tip_proc = 'INT_LIST_CORTE_PROD' THEN
         v_pas := 40;

         INSERT INTO int_facturas_agentes
                     (sproces, nlinea, cempres, cagente, nrecibo, fcobro, cortecuenta,
                      cmoneda, itotalr, icomision, iva, iretefuente, ireteiva, ireteica)
            (SELECT p_sproces, ROWNUM, f_empres, '00',   --codigo de corte PROD
                                                      NULL,   --N/A
                                                           i.fcta, 0,   --No lo relaciona, el archivo es el corte de cuenta
                                                                     NULL,   --N/A
                                                                          i.vtotal,
                    i.comision, i.iva2, NULL, NULL, i.porica
               FROM int_list_corte_prod_ext i);
      END IF;

      IF v_tip_proc = 'INT_FACTURAS_AGENTE_WILLIS' THEN
         v_pas := 41;

         INSERT INTO int_facturas_agentes
                     (sproces, nlinea, cempres, cagente, nrecibo, fcobro, cortecuenta,
                      cmoneda, itotalr, icomision, iva, iretefuente, ireteiva, ireteica)
            (SELECT p_sproces, ROWNUM, f_empres, (SELECT cagente
                                                    FROM recibos
                                                   WHERE nrecibo = i.ncertif), i.ncertif,
                    i.frecau, 1,   --No lo relaciona, el archivo es el corte de cuenta
                                8,   --pesos
                                  i.monrecau, i.vrcomisi, i.ivacomisi, NULL, NULL, NULL
               FROM int_fact_agentes_willis_ext i);
      END IF;

      IF v_tip_proc = 'INT_FACTURAS_AGENTE_WACOLDA' THEN
         v_pas := 42;

         INSERT INTO int_facturas_agentes
                     (sproces, nlinea, cempres, cagente, nrecibo, fcobro, cortecuenta,
                      cmoneda, itotalr, icomision, iva, iretefuente, ireteiva, ireteica)
            (SELECT p_sproces, ROWNUM, f_empres, (SELECT cagente
                                                    FROM recibos
                                                   WHERE nrecibo = i.NDOCUM), i.NDOCUM,
                    i.fpago, 1,   --No lo relaciona, el archivo es el corte de cuenta
                               8,   --pesos
                                 i.vrrecau, i.vrcomisi, i.ivacom, NULL, NULL, NULL
               FROM int_fact_agentes_wacolda_ext i);
      END IF;

      IF v_tip_proc = 'INT_FACTURAS_AGENTE_HELM' THEN
         v_pas := 43;

         INSERT INTO int_facturas_agentes
                     (sproces, nlinea, cempres, cagente, nrecibo, fcobro, cortecuenta,
                      cmoneda, itotalr, icomision, iva, iretefuente, ireteiva, ireteica)
            (SELECT p_sproces, ROWNUM, f_empres, (SELECT cagente
                                                    FROM recibos
                                                   WHERE nrecibo = i.ncertif), i.ncertif,
                    i.fpago, 1,   --No lo relaciona, el archivo es el corte de cuenta
                               8,   --pesos
                                 i.vpago, i.vrcomigr, i.vrivacomisi, NULL, NULL, NULL
               FROM int_fact_agentes_helm_ext i);
      END IF;

      IF v_tip_proc = 'INT_FACTURAS_AGENTE_CORRECOL' THEN
         v_pas := 44;

         INSERT INTO int_facturas_agentes
                     (sproces, nlinea, cempres, cagente, nrecibo, fcobro, cortecuenta,
                      cmoneda, itotalr, icomision, iva, iretefuente, ireteiva, ireteica)
            (SELECT p_sproces, ROWNUM, f_empres, (SELECT cagente
                                                    FROM recibos
                                                   WHERE nrecibo = i.ncertif), i.ncertif,
                    i.freci, 1,   --No lo relaciona, el archivo es el corte de cuenta
                               8,   --pesos
                                 i.saltotal, i.salcomisi, NULL,   --no vendra informada
                                                               NULL, NULL, NULL
               FROM int_fact_agentes_correcol_ext i);
      END IF;

      IF v_tip_proc = 'INT_FACTURAS_AGENTE_AON_P' THEN
         v_pas := 45;

         INSERT INTO int_facturas_agentes
                     (sproces, nlinea, cempres, cagente, nrecibo, fcobro, cortecuenta,
                      cmoneda, itotalr, icomision, iva, iretefuente, ireteiva, ireteica)
            (SELECT p_sproces, ROWNUM, f_empres, (SELECT cagente
                                                    FROM recibos
                                                   WHERE nrecibo = i.ncertif), i.ncertif,
                    i.fcorte, 1,   --No lo relaciona, el archivo es el corte de cuenta
                                i.ctamon,   --pesos
                                         i.pagoml, i.comml, i.ivacomml, NULL, NULL, NULL
               FROM int_fact_agentes_aon_ext i);
      END IF;

      IF v_tip_proc = 'INT_FACTURAS_AGENTE_AON_D' THEN
         v_pas := 46;

         INSERT INTO int_facturas_agentes
                     (sproces, nlinea, cempres, cagente, nrecibo, fcobro, cortecuenta,
                      cmoneda, itotalr, icomision, iva, iretefuente, ireteiva, ireteica)
            (SELECT p_sproces, ROWNUM, f_empres, (SELECT cagente
                                                    FROM recibos
                                                   WHERE nrecibo = i.nanexo), i.nanexo,
                    i.fcorte, 1,   --No lo relaciona, el archivo es el corte de cuenta
                                i.ctamon,   --dolares
                                         i.imppago, i.comtotal, i.imppago - i.pmaprop, NULL,
                    NULL, NULL
               FROM int_fact_agentes_aon_ext i);
      END IF;

      IF v_tip_proc = 'INT_FACTURAS_AGENTE' THEN
         v_pas := 47;

         INSERT INTO int_facturas_agentes
                     (sproces, nlinea, cempres, cagente, nrecibo, fcobro, cortecuenta,
                      cmoneda, itotalr, icomision, iva, iretefuente, ireteiva, ireteica)
            (SELECT p_sproces, ROWNUM, f_empres, i.cagente, i.nrecibo, i.fcobro, 1,   --No lo relaciona, el archivo es el corte de cuenta
                                                                                   i.cmoneda,
                    i.itotalr, i.icomision, i.iva, i.iretefuente, i.ireteiva, i.ireteica
               FROM int_facturas_agentes_ext i);
      END IF;

      v_pas := 5;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_objectname, v_pas, 9909783, SQLERRM);
         p_deserror := 'Error al crear tabla externa';
   END p_trasp_tabla_corte_fac;

       /*************************************************************************
       Procedimiento que guarda logs en las diferentes tablas.
       param p_tabobj in : tab_error tobjeto
       param p_tabtra in : tab_error ntraza
       param p_tabdes in : tab_error tdescrip
       param p_taberr in : tab_error terror
       param p_propro in : PROCESOSLIN sproces
       param p_protxt in : PROCESOSLIN tprolin
       devuelve nmero o null si existe error.
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
             Funcin que marca linea que tratamos con un estado.
          param p_pro in : proceso
          param p_lin in : linea
          param p_tip in : tipo
          param p_est in : estado
          param p_val in : validado
          param p_seg in : seguro
          devuelve nmero o null si existe error.
   *************************************************************************/
   FUNCTION p_marcalinea(
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
      vobj           VARCHAR2(100) := 'PAC_CARGAS_CONF.P_MARCALINEA';
      num_err        NUMBER;
      vtipo          NUMBER;
      num_lin        NUMBER;
      num_aux        NUMBER;
   BEGIN
      num_err := pac_gestion_procesos.f_set_carga_ctrl_linea(p_pro, p_lin, p_tip, p_lin,
                                                             p_tip, p_est, p_val, p_seg,
                                                             p_id_ext, p_ncarg, p_sin, p_tra,
                                                             p_per, p_rec);

      IF num_err <> 0 THEN
         /*Si fallan estas funciones de gestin salimos del programa*/
         p_genera_logs(vobj, 1, num_err,
                       'p=' || p_pro || ' l=' || p_lin || ' t=' || p_tip || ' EST=' || p_est
                       || ' v=' || p_val || ' s=' || p_seg,
                       p_pro, 'Error ' || num_err || ' l=' || p_lin || ' e=' || p_est);
         num_err := 1;
      END IF;

      RETURN num_err;
   END p_marcalinea;

   /*************************************************************************
        Funcin que marca el error de la linea que tratamos.
          param p_pro in : proceso
          param p_lin in : linea
          param p_ner in : numero error
          param p_tip in : tipo
          param p_cod in : codigo
          param p_men in : mensaje
          devuelve nmero o null si existe error.
   *************************************************************************/
   FUNCTION p_marcalineaerror(
      p_pro IN NUMBER,
      p_lin IN NUMBER,
      p_ner IN NUMBER,
      p_tip IN NUMBER,
      p_cod IN NUMBER,
      p_men IN VARCHAR2)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'PAC_CARGAS_CONF.P_MARCALINEAERROR';
      num_err        NUMBER;
   BEGIN
      num_err := pac_gestion_procesos.f_set_carga_ctrl_linea_error(p_pro, p_lin, p_ner, p_tip,
                                                                   p_cod, p_men);

      IF num_err <> 0 THEN
         /*Si fallan estas funciones de gestin salimos del programa*/
         p_genera_logs(vobj, 1, num_err,
                       'p=' || p_pro || ' l=' || p_lin || ' n=' || p_ner || ' t=' || p_tip
                       || ' c=' || p_cod || ' m=' || p_men,
                       p_pro, 'Error ' || num_err || ' l=' || p_lin || ' c=' || p_cod);
         num_err := 1;
      END IF;

      RETURN num_err;
   END p_marcalineaerror;

   /*************************************************************************
                     procedimiento que ejecuta una carga (parte1 fichero)
         param in p_nombre   : Nombre fichero
         param out psproces   : Nmero proceso
         retorna 0 si ha ido bien, 1 en casos contrario
   *************************************************************************/
   FUNCTION f_ejecuta_carga_fichero_corte(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces OUT NUMBER)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'pac_cargas_conf.F_EJECUTA_CARGA_FICHERO_CORTE';
      linea          NUMBER := 0;
      pcarga         NUMBER;
      sentencia      VARCHAR2(32000);
      vfichero       UTL_FILE.file_type;
      vtraza         NUMBER := 0;
      verror         NUMBER;
      vdeserror      VARCHAR2(1000);
      v_sproces      NUMBER;
      errorini       EXCEPTION;   /*Indica error grabando estados.--Error que para ejecucin*/
      errorcar       EXCEPTION;   /*Indica error grabando estados.--Error que para ejecucin*/
      vnum_err       NUMBER;
      vsalir         EXCEPTION;
      vnnumlin       NUMBER;
      vsinproc       BOOLEAN := TRUE;   /*Indica si tenemos o no proceso*/
      verrorfin      BOOLEAN := FALSE;
      vavisfin       BOOLEAN := FALSE;
      vtiperr        NUMBER;
      vcoderror      NUMBER;
      n_imp          NUMBER;
      v_deserror     int_carga_ctrl_linea_errs.tmensaje%TYPE;
      e_errdatos     EXCEPTION;
      v_tip_proc     VARCHAR2(50);
   BEGIN
      IF p_cproces IS NULL THEN
         vnum_err := 9901092;
         vdeserror := 'cfg_files falta proceso: ' || vobj;
         RAISE e_errdatos;
      ELSE
         SELECT ttabla
           INTO v_tip_proc
           FROM cfg_files
          WHERE cproceso = p_cproces;   --recupero tabla para informar el log
      END IF;

      vtraza := 0;
      vsinproc := TRUE;
      vnum_err := f_procesini(f_user, k_empresaaxis, 'CRG_CORTE_CUENTA:' || p_cproces,
                              p_nombre, v_sproces);

      IF vnum_err <> 0 THEN
         RAISE errorini;   /*Error que para ejecucin*/
      END IF;

      psproces := v_sproces;
      vtraza := 1;

      IF p_cproces IS NULL THEN
         vnum_err := 9901092;
         vdeserror := 'cfg_files falta proceso: ' || vobj;
         RAISE e_errdatos;
      END IF;

      vtraza := 11;
      vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(v_sproces, p_nombre,
                                                                 f_sysdate, NULL, 3, p_cproces,
                                                                 NULL, NULL);
      vtraza := 12;

      IF vnum_err <> 0 THEN
         /*Si fallan esta funciones de gestin salimos del programa*/
         p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                     'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera');
         vnum_err := f_proceslin(v_sproces,
                                 f_axis_literales(180856, k_idiomaaaxis) || ':' || p_nombre
                                 || ' : ' || vnum_err,
                                 1, vnnumlin);
         RAISE errorini;   /*Error que para ejecucin*/
      END IF;

      COMMIT;
      vtraza := 2;
      /*Creamos la tabla a partir del nombre de fichero enviado dinamicamente.*/
      vnum_err := f_modi_tabla_corte_fac(p_nombre, p_path, p_cproces);

      IF vnum_err <> 0 THEN
         p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                     'Error creando la tabla externa');
         vnum_err := f_proceslin(v_sproces,
                                 f_axis_literales(vnum_err, k_idiomaaaxis) || ':' || p_nombre
                                 || ' : ' || vnum_err,
                                 1, vnnumlin);
         vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(v_sproces, p_nombre,
                                                                    f_sysdate, NULL, 1,
                                                                    p_cproces, NULL, NULL);
         vdeserror := 'Error creando la tabla externa';
         RAISE errorcar;   /*Error que para ejecucin*/
      END IF;

      p_trasp_tabla_corte_fac(v_sproces, p_cproces, vdeserror);
      vtraza := 3;

      IF vdeserror IS NOT NULL THEN
         /*Si hay un error leyendo el fichero salimos del programa del todo y lo indicamos.*/
         vtraza := 5;
         vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(v_sproces, p_nombre,
                                                                    f_sysdate, NULL, 1,
                                                                    p_cproces, NULL,
                                                                    vdeserror);
         vtraza := 51;

         IF vnum_err <> 0 THEN
            /*Si fallan esta funciones de gestin salimos del programa*/
            p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                        'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera2');
            vnnumlin := NULL;
            vnum_err := f_proceslin(v_sproces,
                                    f_axis_literales(180856, k_idiomaaaxis) || ':' || p_nombre
                                    || ' : ' || vnum_err,
                                    1, vnnumlin);
            RAISE errorini;   /*Error que para ejecucin*/
         END IF;

         vtraza := 52;
         COMMIT;   /*Guardamos la tabla temporal int*/
         RAISE vsalir;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN vsalir THEN
         NULL;
         RETURN 1;
      WHEN e_errdatos THEN
         ROLLBACK;
         pac_cargas_conf.p_genera_logs(vobj, vtraza, 'Error:' || vnum_err, vdeserror,
                                       psproces, 'Error:' || vnum_err || ' ' || vdeserror);
         COMMIT;
         RETURN 1;
      WHEN errorini THEN
         /*Error al insertar estados*/
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, vobj, vtraza, 'Error:' || 'ErrorIni' || ' en :' || 1,
                     'Error:' || 'Insertando estados registros');
         vnum_err := f_proceslin(v_sproces,
                                 f_axis_literales(108953, k_idiomaaaxis) || ':' || p_nombre
                                 || ' : ' || 'errorini',
                                 1, vnnumlin);
         COMMIT;
      WHEN errorcar THEN
         /*Error al insertar datos*/
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, vobj, vtraza, 'Error:' || 'ErrorIni' || ' en :' || 1,
                     'Error:' || 'Insertando estados registros');
         vnum_err := f_proceslin(v_sproces,
                                 f_axis_literales(108953, k_idiomaaaxis) || ':' || p_nombre
                                 || ' : ' || 'errorini',
                                 1, vnnumlin);
         pac_cargas_conf.p_genera_logs(vobj, vtraza, 'Error:' || vnum_err, vdeserror,
                                       psproces,
                                       'Error creando tabla externa.' || vnum_err || ' '
                                       || vdeserror);
         COMMIT;
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         /*KO si ha habido algun error en la cabecera*/
         /*coderr := SQLCODE;*/
         p_tab_error(f_sysdate, f_user, vobj, vtraza, 'Error:' || SQLERRM || ' en :' || 1,
                     'Error:' || SQLERRM);
         vnum_err := f_proceslin(v_sproces,
                                 f_axis_literales(103187, k_idiomaaaxis) || ':' || p_nombre
                                 || ' : ' || SQLERRM,
                                 1, vnnumlin);
         vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(v_sproces, p_nombre,
                                                                    f_sysdate, NULL, 1,
                                                                    p_cproces, 151541,
                                                                    SQLERRM);
         vtraza := 51;

         IF vnum_err <> 0 THEN
            /*RAISE ErrGrabarProv;*/
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
   END f_ejecuta_carga_fichero_corte;

   FUNCTION f_ejecuta_carga_proceso_corte(psproces IN NUMBER, p_cproces IN NUMBER)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'pac_cargas_conf.F_EJECUTAR_CARGA_PROCESO_FAC';

      CURSOR polmigra(psproces2 IN NUMBER) IS
         SELECT   a.*
             FROM int_facturas_agentes a
            WHERE sproces = psproces2
              AND NOT EXISTS(SELECT 1
                               FROM int_carga_ctrl_linea
                              WHERE int_carga_ctrl_linea.sproces = a.sproces
                                AND int_carga_ctrl_linea.nlinea = a.nlinea
                                AND int_carga_ctrl_linea.cestado IN(2, 4, 5, 6))
         /*   AND int_carga_ctrl_linea.cestado IN(2, 4, 5)) --> 4.0 - 0024803 - Inicial*/
         /*Solo las no procesadas*/
         ORDER BY nlinea;

      /*
      CESTADO:
      1,Error
      2,Aviso
      3,Pendiente
      4,Correcto
      5,No procesado
      6,Recargado
      */
      viva           int_facturas_agentes.iva%TYPE;
      viretefuente   int_facturas_agentes.iretefuente%TYPE;
      vireteiva      int_facturas_agentes.ireteiva%TYPE;
      vireteica      int_facturas_agentes.ireteica%TYPE;
      vtraza         NUMBER := 0;
      vdeserror      VARCHAR2(1000);
      errorini       EXCEPTION;
      /*Indica error grabando estados.--Error que para ejecucin*/
      vnnumlin       NUMBER;
      verrorfin      BOOLEAN := FALSE;
      vavisfin       BOOLEAN := FALSE;
      vcoderror      NUMBER;
      v_deserror     int_carga_ctrl_linea_errs.tmensaje%TYPE;
      v_tfichero     int_carga_ctrl.tfichero%TYPE;
      e_errdatos     EXCEPTION;
      e_validaciones EXCEPTION;
      vnum_err       NUMBER;
      v_dummy        NUMBER := 0;
      vtiperr        NUMBER := 0;
      verror         NUMBER;
      /*Codigo error*/
      vterror        VARCHAR2(4000);
      /*Descripcin ampliada error*/
      v_idioma       NUMBER;
      v_errdat       VARCHAR2(4000);
      v_errtot       NUMBER := 0;
      /*v_sproces      NUMBER; -- 4.0 - 0024803*/
      vcagente       agentes.cagente%TYPE;
      vnrecibo       recibos.nrecibo%TYPE;
      v_regext       ext_seguros%ROWTYPE;
      v_ncarga       mig_cargas.ncarga%TYPE;
      viprinet       NUMBER;
      vicomisi       NUMBER;
      vicomret       NUMBER;
      vitotalr       NUMBER;
      vitotimp       NUMBER;
      vsproduc       seguros.sproduc%TYPE;
      v_cmoncia      NUMBER;
      vclave         codctactes_imp.clave%TYPE;
      vvalor         NUMBER;
      validaciones   NUMBER;
      vidiferencia   NUMBER;
      vestadorecibo  NUMBER;

      /* Funcin para buscar la clave para el clculo de impuestos*/
      FUNCTION f_set_codctactes_imp(
         pcconcta IN NUMBER,
         pcconcta_imp IN NUMBER,
         psproduc IN NUMBER)
         RETURN NUMBER IS
         vclave         codctactes_imp.clave%TYPE;
      BEGIN
         BEGIN
            SELECT clave
              INTO vclave
              FROM codctactes_imp
             WHERE cempres = k_empresaaxis
               AND cconcta = pcconcta
               AND cconcta_imp = pcconcta_imp
               AND sproduc = NVL(psproduc, 0)
               AND NVL(psproduc, 0) <> 0
            UNION
            SELECT clave
              FROM codctactes_imp
             WHERE cempres = k_empresaaxis
               AND cconcta = pcconcta
               AND cconcta_imp = pcconcta_imp
               AND sproduc = 0
               AND cconcta_imp NOT IN(SELECT cconcta_imp
                                        FROM codctactes_imp
                                       WHERE cempres = k_empresaaxis
                                         AND cconcta = pcconcta
                                         AND cconcta_imp = pcconcta_imp
                                         AND sproduc = NVL(psproduc, 0)
                                         AND NVL(psproduc, 0) <> 0);
         EXCEPTION
            WHEN OTHERS THEN
               vclave := NULL;
         END;

         RETURN vclave;
      END;
   BEGIN
      /* vnum_err := f_procesini(f_user, k_empresaaxis, 'CARGA_FACT_AGE', 'PROCESO', v_sproces); 4.0 - 0024803*/
      vtraza := 10;
      v_idioma := k_idiomaaaxis;

      IF psproces IS NULL THEN
         vnum_err := 9000505;
         pac_cargas_conf.p_genera_logs(vobj, vtraza, 'Error:' || vnum_err,
                                       'Parmetro psproces obligatorio.', psproces,
                                       f_axis_literales(vnum_err, v_idioma) || ':'
                                       || v_tfichero || ' : ' || vnum_err);
         RAISE errorini;
      END IF;

      vtraza := 15;

      SELECT MIN(tfichero)
        INTO v_tfichero
        FROM int_carga_ctrl
       WHERE sproces = psproces;

      vtraza := 20;

      IF v_tfichero IS NULL THEN
         vnum_err := 9901092;
         p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                     'Falta fichero para proceso: ' || psproces);
         vnnumlin := NULL;
         vnum_err := f_proceslin(psproces,
                                 f_axis_literales(vnum_err, v_idioma) || ':' || v_tfichero
                                 || ' : ' || vnum_err,
                                 1, vnnumlin);
         RAISE errorini;
      END IF;

      vtraza := 30;

      IF NVL(pac_parametros.f_parempresa_n(k_empresaaxis, 'MULTIMONEDA'), 0) = 1 THEN
         v_cmoncia := pac_parametros.f_parempresa_n(k_empresaaxis, 'MONEDAEMP');
      END IF;

      vtraza := 40;

      FOR x IN polmigra(psproces) LOOP
         BEGIN
            /*Leemos los registros de la tabla int no procesados OK*/
            vtiperr := 0;
            verror := NULL;
            vterror := NULL;
            vtraza := 50;

            BEGIN
               SELECT cagente
                 INTO vcagente
                 FROM agentes
                WHERE cagente = x.cagente;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  verror := 101902;
                  /* Agente inexistente osea recibo no encontrado */
                  vterror := f_axis_literales(verror, pac_md_common.f_get_cxtidioma) || ' '
                             || x.cagente;
                  RAISE e_validaciones;
            END;

            vtraza := 60;

            BEGIN
               SELECT r.nrecibo, s.sproduc, f_cestrec(x.nrecibo, f_sysdate)
                 INTO vnrecibo, vsproduc, vestadorecibo
                 FROM recibos r, seguros s
                WHERE s.sseguro = r.sseguro
                  AND r.nrecibo = x.nrecibo;

               IF vestadorecibo <> 0 THEN
                  verror := 101126;
                  /* Recibo no pendiente*/
                  vterror := f_axis_literales(verror, pac_md_common.f_get_cxtidioma) || ' '
                             || x.nrecibo;
                  RAISE e_validaciones;
               END IF;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  verror := 101902;
                  /* Recibo no encontrado en la tabla RECIBOS*/
                  vterror := f_axis_literales(verror, pac_md_common.f_get_cxtidioma) || ' '
                             || x.nrecibo;
                  RAISE e_validaciones;
            END;

            vtraza := 70;

            BEGIN
               /* 8.0 0030683: POSADM Cortes de Cuenta - 177808 - Inicio*/
               /*SELECT NVL(vm.iprinet, v.iprinet) iprinet, NVL(vm.icombru, v.icombru) icomisi,*/
               /*       NVL(vm.icomret, v.icomret) icomret, NVL(vm.itotalr, v.itotalr) itotalr,*/
               /*       NVL(vm.itotimp, v.itotimp) itotimp*/
               SELECT NVL(vm.iprinet, v.iprinet) + NVL(vm.icednet, v.icednet) iprinet,
                      NVL(vm.icombru, v.icombru) + NVL(vm.icedcbr, v.icedcbr) icomisi,
                      NVL(vm.icomret, v.icomret) + NVL(vm.icedcrt, v.icedcrt) icomret,
                      NVL(vm.itotalr, v.itotalr) itotalr, NVL(vm.itotimp, v.itotimp) itotimp
                 /* 8.0 0030683: POSADM Cortes de Cuenta - 177808 - Final*/
               INTO   viprinet,
                      vicomisi,
                      vicomret,
                      vitotalr, vitotimp
                 FROM vdetrecibos v, vdetrecibos_monpol vm
                WHERE vm.nrecibo(+) = v.nrecibo
                  AND v.nrecibo = x.nrecibo;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  verror := 103936;
                  /* Recibo no encontrado en la tabla VDETRECIBOS*/
                  vterror := f_axis_literales(verror, pac_md_common.f_get_cxtidioma) || ' '
                             || x.nrecibo;
                  RAISE e_validaciones;
            END;

            vtraza := 80;
            validaciones := 0;

            /* int_facturas_agentes
            IF vitotalr < x.itotalr THEN
               vterror := 'TOTAL_REC - cargado(' || x.itotalr || ') > real(' || vitotalr
                          || ') ';
               validaciones := validaciones + 1;
            ELSE
               vidiferencia := vitotalr - x.itotalr;
            END IF;*/

            vtraza := 90;

            /*IF vicomisi < x.icomision THEN
               vterror := 'COMISION - cargado(' || x.icomision || ') > calculada(' || vicomisi
                          || ') ';
               validaciones := validaciones + 1;
            END IF;*/

            vtraza := 100;

            IF x.iva IS NOT NULL THEN
               BEGIN
                  vtraza := 105;
                  vclave := f_set_codctactes_imp(40, 53, vsproduc);

                  /* IVA*/
                  IF vclave IS NOT NULL THEN
                     vtraza := 110;
                     verror := pac_liquida.f_calc_formula_agente(x.cagente, vclave, f_sysdate,
                                                                 vvalor, vsproduc);
                     vtraza := 120;
                     viva := f_round(vicomisi * vvalor, v_cmoncia);
                  ELSE
                     viva := 0;
                  END IF;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     viva := 0;
               END;

               /*IF NVL(x.iva, 0) > NVL(viva, 0) THEN
                  vtraza := 130;
                  vterror := 'IVA - cargado(' || x.iva || ') > calculado(' || viva || ') ['
                             || vclave || ']';
                  validaciones := validaciones + 1;
               END IF;*/
            END IF;

            vtraza := 140;

            IF x.iretefuente IS NOT NULL THEN
               BEGIN
                  vtraza := 145;
                  vclave := f_set_codctactes_imp(40, 54, vsproduc);

                  /* IRETEFUENTE*/
                  IF vclave IS NOT NULL THEN
                     vtraza := 150;
                     verror := pac_liquida.f_calc_formula_agente(x.cagente, vclave, f_sysdate,
                                                                 vvalor, vsproduc);
                     vtraza := 160;
                     viretefuente := f_round(vicomisi * vvalor, v_cmoncia);
                  ELSE
                     viretefuente := 0;
                  END IF;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     viretefuente := 0;
               END;

               /*IF NVL(x.iretefuente, 0) > NVL(viretefuente, 0) THEN
                  vtraza := 170;
                  vterror := 'RETEFUENTE - cargado((' || x.iretefuente || ' > calculado('
                             || viretefuente || ') [' || vclave || ']';
                  validaciones := validaciones + 1;
               END IF;*/
            END IF;

            vtraza := 180;

            IF x.ireteiva IS NOT NULL THEN
               BEGIN
                  vtraza := 185;
                  vclave := f_set_codctactes_imp(40, 55, vsproduc);

                  /* IRETEIVA*/
                  IF vclave IS NOT NULL THEN
                     vtraza := 190;
                     verror := pac_liquida.f_calc_formula_agente(x.cagente, vclave, f_sysdate,
                                                                 vvalor, vsproduc);
                     vtraza := 200;
                     vireteiva := f_round(vicomisi * vvalor, v_cmoncia);
                  ELSE
                     vireteiva := 0;
                  END IF;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     vireteiva := 0;
               END;

               /*IF NVL(x.ireteiva, 0) > NVL(vireteiva, 0) THEN
                  vtraza := 210;
                  vterror := 'RETEIVA - cargado(' || x.ireteiva || ') > calculado('
                             || vireteiva || ') [' || vclave || '] vsproduc:' || vsproduc;
                  validaciones := validaciones + 1;
               END IF;*/
            END IF;

            vtraza := 220;

            IF x.ireteica IS NOT NULL THEN
               BEGIN
                  vtraza := 225;
                  vclave := f_set_codctactes_imp(40, 56, vsproduc);

                  /* IRETEICA*/
                  IF vclave IS NOT NULL THEN
                     vtraza := 230;
                     verror := pac_liquida.f_calc_formula_agente(x.cagente, vclave, f_sysdate,
                                                                 vvalor, vsproduc);
                     vtraza := 240;
                     vireteica := f_round(vicomisi * vvalor, v_cmoncia);
                  ELSE
                     vireteica := 0;
                  END IF;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     vireteica := 0;
               END;

               /*IF NVL(x.ireteica, 0) > NVL(vireteica, 0) THEN
                  vtraza := 250;
                  vterror := 'RETEICA - cargado(' || x.ireteica || ') > calculado('
                             || vireteica || ') [' || vclave || ']';
                  validaciones := validaciones + 1;
               END IF;*/
            END IF;

            vtraza := 260;

            IF validaciones != 0 THEN
               verror := 9904578;
               /* Los importes cargados no coinciden*/
               vterror := f_axis_literales(verror, pac_md_common.f_get_cxtidioma) || ' '
                          || x.nrecibo || ' ' || vterror;
               RAISE e_validaciones;
            END IF;

            vtraza := 270;
            /*Si todo correcto marco la linea correcta*/
            vnum_err := p_marcalinea(psproces, x.nlinea, 2, 4, 0, NULL, 'ALTA(OK)', NULL, NULL,
                                     NULL, x.cagente, x.nrecibo);
         EXCEPTION
            WHEN e_validaciones THEN
               ROLLBACK;
                     /*
               UPDATE mig_cargas_tab_mig
               SET estdes = 'DEL'
               WHERE ncarga = v_ncarga;
               COMMIT;
               pac_mig_axis.p_borra_cargas('DEL', v_ncarga);
               */
               v_errtot := 1;
               vnum_err := p_marcalinea(psproces, x.nlinea, 2, 1, 0, NULL, 'ALTA(KO-AVISOS)',
                                        NULL, NULL, NULL, x.cagente, x.nrecibo);

               IF vnum_err <> 0 THEN
                  RAISE errorini;
               /*Error que para ejecucin*/
               END IF;

               vnum_err := p_marcalineaerror(psproces, x.nlinea, NULL, 1, verror,
                                             NVL(vterror, verror) || ' (traza:' || vtraza
                                             || ')');

               IF vnum_err <> 0 THEN
                  RAISE errorini;
               /*Error que para ejecucin*/
               END IF;

               COMMIT;
         END;
      END LOOP;

      RETURN v_errtot;
   EXCEPTION
      WHEN errorini THEN
         /*Error al insertar estados*/
         ROLLBACK;
         pac_cargas_conf.p_genera_logs(vobj, vtraza,
                                       'Error:' || 'ErrorIni' || ' en :' || vnum_err,
                                       'Error:' || 'Insertando estados registros', psproces,
                                       f_axis_literales(108953, v_idioma) || ':' || v_tfichero
                                       || ' : ' || 'errorini');
         /*vnum_err := f_procesfin(v_sproces, 1); -- 4.0 - 0024803*/
         COMMIT;
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         /*KO si ha habido algun error en la cabecera*/
         pac_cargas_conf.p_genera_logs(vobj, vtraza, 'Error:' || vnum_err, SQLERRM, psproces,
                                       f_axis_literales(103187, v_idioma) || ':' || v_tfichero
                                       || ' : ' || SQLERRM);
         vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces, v_tfichero,
                                                                    f_sysdate, NULL, 1,
                                                                    p_cproces, 151541,
                                                                    SQLERRM);

         IF vnum_err <> 0 THEN
            pac_cargas_conf.p_genera_logs
                          (vobj, vtraza, vnum_err,
                           'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera2',
                           psproces,
                           f_axis_literales(180856, v_idioma) || ':' || v_tfichero || ' : '
                           || vnum_err);
            RAISE errorini;
         END IF;

         /*vnum_err := f_procesfin(v_sproces, 1); -- 4.0 - 0024803*/
         COMMIT;
         RETURN 1;
   END f_ejecuta_carga_proceso_corte;

   FUNCTION f_ejecutar_carga_corte_fac(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'PAC_CARGAS_CONF.f_ejecutar_carga_corte_fac';
      v_param        VARCHAR2(200)
         := 'p_nombre = ' || p_nombre || ' p_path = ' || p_path || ' p_cproces = '
            || p_cproces || ' psproces = ' || psproces;
      vtraza         NUMBER := 0;
      vnum_err       NUMBER;
      vsalir         EXCEPTION;
      v_tip_proc     VARCHAR2(50);
   BEGIN
      --
      vnum_err := f_procesini(f_user, k_empresaaxis, 'CRG_CORTE_CUENTA:' || p_cproces,
                              p_nombre, psproces);
      vtraza := 10;

      SELECT NVL(cpara_error, 0)
        INTO k_para_carga
        FROM cfg_files
       WHERE cempres = k_empresaaxis
         AND cproceso = p_cproces;

      vtraza := 20;
      /* IF psproces IS NULL THEN -- 4.0 - 0024803*/
      vtraza := 30;
      vnum_err := pac_cargas_conf.f_ejecuta_carga_fichero_corte(p_nombre, p_path, p_cproces,
                                                                psproces);

      --
      IF vnum_err <> 0 THEN
         RAISE vsalir;
      END IF;

      /* END IF; -- 4.0 - 0024803*/
      vtraza := 40;
      vnum_err := pac_cargas_conf.f_ejecuta_carga_proceso_corte(psproces, p_cproces);

      IF vnum_err <> 0
         AND k_para_carga <> 0   /* 76.*/
                              THEN
         RAISE vsalir;
      END IF;

      vtraza := 50;

      IF p_cproces = 300 THEN
         --CORTEPROD
         vnum_err := f_liquidar_carga_cortepro_fac(psproces, p_cproces);
      ELSE
         vnum_err := pac_cargas_conf.f_liquidar_carga_corte_fac(psproces, p_cproces);
      END IF;

      IF vnum_err <> 0 THEN
         RAISE vsalir;
      END IF;

      vnum_err := f_procesfin(psproces, 0);   /* 4.0 - 0024803 (aadido)*/
      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN vsalir THEN
         p_tab_error(f_sysdate, f_user, vobj, vtraza, v_param,
                     vnum_err || '.-' || f_axis_literales(vnum_err));
         /* Error controlado que se ver en el resultado de la carga*/
         /* Si devuelve 1, para el proceso y no se llega a ver el resultado de la carga.*/
         vnum_err := f_procesfin(psproces, 1);   /* 4.0 - 0024803 (aadido)*/
         RETURN 0;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobj, vtraza, v_param, SQLERRM);
         vnum_err := f_procesfin(psproces, 1);   /* 4.0 - 0024803 (aadido)*/
         RETURN 1;
   END f_ejecutar_carga_corte_fac;

   FUNCTION f_liquidar_carga_corte_fac(psproces IN NUMBER, p_cproces IN NUMBER)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'pac_cargas_conf.f_liquidar_carga_corte_fac';

        /*
      Estado control de linea "int_carga_ctrl.cestado"
      1       Error
      2       Aviso
      3       Pendiente
      4       Correcto
      5       No procesado
      */
      CURSOR fact_liq(psproces2 IN NUMBER) IS
         SELECT   a.sproces, a.nlinea, a.cagente, a.nrecibo, a.fcobro, a.cortecuenta,
                  a.cmoneda, a.itotalr itotalr_int, a.icomision, iva, iretefuente, ireteiva,
                  ireteica, NVL(vm.iprinet, v.iprinet) iprinet, r.ctiprec, r.cgescob,
                  r.ccobban, r.cdelega, r.sseguro, r.nmovimi,
                  NVL(vm.icombru, v.icombru) icomisi, NVL(vm.icomret, v.icomret) icomret,
                  NVL(vm.itotalr, v.itotalr) itotalr, NVL(vm.itotimp, v.itotimp) itotimp,
                  NVL(r.sperson, ff_sperson_tomador(r.sseguro)) sperson_pag,
                  a.itotalr irecaudo
             FROM int_facturas_agentes a, vdetrecibos v, vdetrecibos_monpol vm, recibos r
                                                                                         /* 4.0 - 0024803 - Inicial*/
                  ,
                  int_carga_ctrl_linea c
            /* 4.0 - 0024803 - Final*/
         WHERE    a.sproces = psproces2
              AND v.nrecibo = r.nrecibo
              AND vm.nrecibo(+) = r.nrecibo
              AND a.nrecibo = r.nrecibo
              /* 4.0 - 0024803 - Inicial*/
              AND c.sproces = a.sproces
              AND c.nlinea = a.nlinea
              AND c.cestado IN 4
         /*  AND EXISTS(SELECT 1*/
         /*               FROM int_carga_ctrl*/
         /*              WHERE int_carga_ctrl.sproces = a.sproces*/
         /*                AND int_carga_ctrl.cestado = 4)*/
         /*  FOR UPDATE OF a.cagente, a.cempres, a.nliqmen, a.nliqlin*/
         /* 4.0 - 0024803 - Final*/
         /*Solo las no procesadas*/
         ORDER BY nlinea;

      CURSOR ctactes_liq(psproces2 IN NUMBER) IS
         SELECT   a.cagente, a.cempres, a.nliqmen, NVL(MIN(a.cortecuenta),
                                                       g.cliquido) cliquido
             FROM agentes g, int_facturas_agentes a
                                                   /* 4.0 - 0024803 - Inicial*/
                  , int_carga_ctrl_linea c
            /* 4.0 - 0024803 - Final*/
         WHERE    a.sproces = psproces2
              AND a.cagente = g.cagente
              /* 4.0 - 0024803 - Inicial*/
              AND c.sproces = a.sproces
              AND c.nlinea = a.nlinea
              AND c.cestado IN 4
         /*> Trate solo los pendientes -- 4.0 - 0024803*/
         /* 4.0 - 0024803 - Inicial*/
         GROUP BY a.cagente, a.cempres, a.nliqmen, g.cliquido
         ORDER BY a.cagente;

      CURSOR pago_corte_cuenta(psproces IN NUMBER) IS
         SELECT DISTINCT (p.spago) spago
                    FROM ctactes c, pagoscomisiones p
                   WHERE c.sproces = psproces
                     AND c.nnumlin = p.nnumlin
                     AND p.cagente = c.cagente
                     AND p.cestado = 1
                     AND p.cempres = c.cempres;

      vtraza         NUMBER := 0;
      vdeserror      VARCHAR2(1000);
      errorini       EXCEPTION;
      /*Indica error grabando estados.--Error que para ejecucin*/
      vcoderror      NUMBER;
      v_deserror     int_carga_ctrl_linea_errs.tmensaje%TYPE;
      v_tfichero     int_carga_ctrl.tfichero%TYPE;
      e_errorliq     EXCEPTION;
      vnum_err       NUMBER;
      v_idioma       NUMBER;
      v_errdat       VARCHAR2(4000);
      v_errtot       NUMBER := 0;
      /* v_sproces      NUMBER; -- 4.0 - 0024803*/
      vcempres       empresas.cempres%TYPE := pac_md_common.f_get_cxtempresa;
      vnrecibo       recibos.nrecibo%TYPE;
      v_regext       ext_seguros%ROWTYPE;
      v_ncarga       mig_cargas.ncarga%TYPE;
      vmodo          NUMBER;
      vnliqmen       liquidalin.nliqmen%TYPE;
      vnliqlin       liquidalin.nliqlin%TYPE;
      vcageliq       agentes.cagente%TYPE;
      vcagente       agentes.cagente%TYPE := -1;
      vsmovrec       movrecibo.smovrec%TYPE;
      v_cmultimon    NUMBER;
      v_cmoncia      NUMBER;
      v_itasa        NUMBER;
      v_fcambio      DATE;
      v_icomisi      NUMBER;
      vnnumlin       NUMBER;
      vfecliq        DATE := TRUNC(f_sysdate);
      v_signo        NUMBER;
      vnliqmen2      NUMBER;
      vnnumlin2      NUMBER;
      vcliquido      agentes.cliquido%TYPE;
      vconcta59      NUMBER;
      /* Factura*/
      vconcta60      NUMBER;
      /* Recibos*/
      vconcta99      NUMBER;
      /* Saldo final de los apuntes automticos (Comisin)*/
      vcdebhab1      NUMBER;
      /* Debe*/
      vcdebhab2      NUMBER;
      /* Haber*/
      vconcta53      NUMBER;
      /* IVA*/
      vconcta54      NUMBER;
      /* RETEFUENTE*/
      vconcta55      NUMBER;
      /* RETEIVA*/
      vconcta56      NUMBER;
      /* RETEICA*/
      vconcta94      NUMBER;   --gastos gestion
      vcestado       NUMBER;
      verror         NUMBER;
      vsmovagr       NUMBER := 0;
      vvalor_ica     NUMBER;
      vvalor_fuente  NUMBER;
      vvalor_iva     NUMBER;
      vvalor_reteiva NUMBER;
      vyacargado     NUMBER;
      /* 4.0 - 0024803*/
      vsproces       NUMBER;
      /* 5.0*/
      vterminal      VARCHAR2(200);
      vemitido       NUMBER;
      perror         VARCHAR2(2000);
      psinterf       NUMBER;
      vspago         NUMBER;
      vidcobro       NUMBER := 1;
      vidiferencia   NUMBER;
   /* 4.0 - 0024803 - Final*/
   BEGIN
      vtraza := 5;
      v_idioma := k_idiomaaaxis;

      IF psproces IS NULL THEN
         vnum_err := 9000505;
         pac_cargas_conf.p_genera_logs(vobj, vtraza, 'Error:' || vnum_err,
                                       'Parmetro psproces obligatorio.', psproces,
                                       f_axis_literales(vnum_err, v_idioma) || ':'
                                       || v_tfichero || ' : ' || vnum_err);
         RAISE errorini;
      END IF;

      vtraza := 10;

      SELECT MIN(tfichero)
        INTO v_tfichero
        FROM int_carga_ctrl
       WHERE sproces = psproces;

      vtraza := 20;

      IF v_tfichero IS NULL THEN
         vnum_err := 9901092;
         p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                     'Falta fichero para proceso: ' || psproces);
         vnnumlin2 := NULL;
         vnum_err := f_proceslin(psproces,
                                 f_axis_literales(vnum_err, v_idioma) || ':' || v_tfichero
                                 || ' : ' || vnum_err,
                                 1, vnnumlin2);
         RAISE errorini;
      END IF;

      vtraza := 30;

      FOR x IN fact_liq(psproces) LOOP
         vtraza := 40;

         BEGIN
            /* 5.0  - Facturas intermediario - 170459 - Inicio*/
            IF vnliqmen IS NULL
               OR NVL(vcagente, -1) != x.cagente THEN
               vcagente := x.cagente;
               vtraza := 60;

               IF pac_parametros.f_parempresa_n(vcempres, 'LIQUIDA_CTIPAGE') IS NULL THEN
                  vcageliq := vcagente;
               ELSE
                  vtraza := 70;
                  vcageliq :=
                     pac_agentes.f_get_cageliq
                                            (vcempres,
                                             pac_parametros.f_parempresa_n(vcempres,
                                                                           'LIQUIDA_CTIPAGE'),
                                             vcagente);
               END IF;

               -- Que la liquidacin sea por corte de cuenta (liquido/autoliquidacin)[1] o no [0]
               -- Se dejar grabado en LIQUIDACAB
               vtraza := 80;

               IF x.cortecuenta IS NULL THEN
                  BEGIN
                     vtraza := 90;

                     SELECT NVL(cliquido, 0)
                       INTO vcliquido
                       FROM agentes
                      WHERE cagente = vcageliq;
                  END;
               ELSE
                  vtraza := 100;
                  vcliquido := x.cortecuenta;
               END IF;

               vmodo := 0;   --> Modo real
               vtraza := 110;
               vnliqmen := f_get_nliqmen(vcempres, x.cagente, vfecliq, psproces, vmodo,
                                         vcliquido);
               vnliqlin := 1;
            ELSE
               vtraza := 120;
               vcagente := x.cagente;
               vnliqlin := vnliqlin + 1;
            END IF;

            vtraza := 130;

            BEGIN
               INSERT INTO liquidaage
                           (cempres, cageclave, cagente, sproliq, nliqmen, cestautoliq,
                            fliquid, iimporte, cusuari, fcobro)
                    VALUES (vcempres, x.cagente, x.cagente, psproces, vnliqmen, 1,
                            vfecliq, x.itotalr, pac_md_common.f_get_cxtusuario, x.fcobro);
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;

            vtraza := 131;

            BEGIN
               SELECT NVL((SELECT MAX(idcobro)
                             FROM liquidacobros
                            WHERE sproliq = psproces), 0) + 1
                 INTO vidcobro
                 FROM DUAL;
            EXCEPTION
               WHEN OTHERS THEN
                  vidcobro := 1;
            END;

            vtraza := 132;

            INSERT INTO liquidacobros
                        (cagente, cempres, ccobro, iimporte, tobserva, sproliq, idcobro)
                 VALUES (x.cagente, vcempres, 3, x.itotalr, 'CORTE CUENTA', psproces, vidcobro);

            vtraza := 133;

            IF x.cgescob = 3 THEN
               v_icomisi :=(-x.itotalr + x.icomisi);
            ELSE
               v_icomisi := x.icomisi;
            END IF;

            vtraza := 140;

            IF x.ctiprec IN(9, 13) THEN
               v_signo := -1;
            ELSE
               v_signo := 1;
            END IF;

            vtraza := 150;
            v_cmultimon := NVL(pac_parametros.f_parempresa_n(vcempres, 'MULTIMONEDA'), 0);

            IF v_cmultimon = 1 THEN
               v_cmoncia := pac_parametros.f_parempresa_n(vcempres, 'MONEDAEMP');
               vnum_err := pac_oper_monedas.f_datos_contraval(NULL, x.nrecibo, NULL,
                                                              f_sysdate, 2, v_itasa,
                                                              v_fcambio);
            END IF;

            /* 5.0  - Facturas intermediario - 170459 - Final*/
            vtraza := 190;
            vtraza := 200;

            UPDATE int_facturas_agentes
               SET nliqmen = vnliqmen,
                   nliqlin = vnliqlin,
                   cempres = vcempres
             WHERE sproces = x.sproces
               AND nlinea = x.nlinea;

            vtraza := 250;

            /* 5.0  - Facturas intermediario - 170459 - Inicio*/
            SELECT MAX(smovrec)
              INTO vsmovrec
              FROM movrecibo
             WHERE nrecibo = x.nrecibo;

            vtraza := 260;
            vidiferencia := NVL(x.itotalr, 0) - NVL(x.irecaudo, 0);

            INSERT INTO liquidalin
                        (cempres, nliqmen, cagente, nliqlin, nrecibo, smovrec,
                         itotimp, itotalr,
                         iprinet, icomisi,
                         iretenccom, isobrecomision, iretencsobrecom, iconvoleducto,
                         iretencoleoducto, ctipoliq, itotimp_moncia,
                         itotalr_moncia,
                         iprinet_moncia,
                         icomisi_moncia,
                         iretenccom_moncia, isobrecom_moncia, iretencscom_moncia,
                         iconvoleod_moncia, iretoleod_moncia, fcambio,
                         cagerec, corteprod, idiferencia)
                 VALUES (vcempres, vnliqmen, vcageliq, vnliqlin, x.nrecibo, vsmovrec,
                         NVL(x.itotimp, 0) * v_signo, NVL(x.itotalr, 0) * v_signo,
                         NVL(x.iprinet, 0) * v_signo, NVL(v_icomisi, 0) * v_signo,
                         NVL(x.icomret, 0) * v_signo, NULL, NULL, NULL,
                         NULL, NULL, f_round(NVL(x.itotimp, 0) * v_signo * v_itasa, v_cmoncia),
                         f_round(NVL(x.itotalr, 0) * v_signo * v_itasa, v_cmoncia),
                         f_round(NVL(x.iprinet, 0) * v_signo * v_itasa, v_cmoncia),
                         f_round(NVL(v_icomisi, 0) * v_signo * v_itasa, v_cmoncia),
                         f_round(NVL(x.icomret, 0) * v_signo * v_itasa, v_cmoncia), NULL, NULL,
                         NULL, NULL, DECODE(v_cmultimon, 0, NULL, NVL(v_fcambio, f_sysdate)),
                         x.cagente, 1, vidiferencia);

            vsproces := NULL;
            vtraza := 270;
         EXCEPTION
            WHEN e_errorliq THEN
               /* ROLLBACK; -- 4.0 - 0024803*/
               v_errtot := 1;
               vnum_err := p_marcalinea(psproces, x.nlinea, 2, 1, 0, NULL, 'ALTA(KO-ERROR)',
                                        NULL, NULL, NULL, x.cagente, x.nrecibo);
               /*- IF vnum_err <> 0 THEN*/
               /*-    RAISE errorini;   --Error que para ejecucin*/
               /*- END IF;*/
               vnum_err :=
                  p_marcalineaerror(psproces, x.nlinea, NULL, 1, verror,

                                    /* 2.0 - 24803 - 154143 (aadir)*/
                                    f_axis_literales(verror, pac_md_common.f_get_cxtidioma)
                                    || ' ' || x.nrecibo
                                                       /* , verror  -- 2.0 - 24803 - 154143 (comentar)*/
                  );
         /*IF vnum_err <> 0 THEN*/
         /*   RAISE errorini;   --Error que para ejecucin*/
         /*END IF;*/
         /*-RAISE errorini;   -- Si hay error mejor que no sigua con el resto del proceso*/
         END;
      END LOOP;

      /* 4.0 - 0024803 - Ahora no hace falta que sea cticob = 2 - Inicio*/
      IF v_errtot = 1 THEN
         RAISE errorini;
      /* Si hay error mejor que no sigua con el resto del proceso*/
      END IF;

      /* 4.0 - 0024803 - Ahora no hace falta que sea cticob = 2 - Final*/
      vtraza := 300;

      /* 5.0  - Facturas intermediario - 170459 - Inicio*/
      FOR y IN ctactes_liq(psproces) LOOP
         vtraza := 310;

         IF y.cliquido = 1 THEN
            -- LIQUIDACIN POR CORTE DE CUENTA / LIQUIDO
            vtraza := 320;

            SELECT NVL(MAX(nnumlin), 0)
              INTO vnnumlin
              FROM ctactes
             WHERE cagente = y.cagente;

            vtraza := 330;

            SELECT NVL(SUM(l.icomision), 0) comision,
                   NVL(SUM(l.itotalr - l.icomision), 0) factura,
                   NVL(SUM(l.itotalr), 0) - NVL(SUM(l.iva), 0) recibo, NVL(SUM(l.iva), 0) iva,
                   NVL(SUM(l.iretefuente), 0) retfte, NVL(SUM(l.ireteiva), 0) reteiva,
                   NVL(SUM(l.ireteica), 0) ireteica,
                   NVL(DECODE(SIGN(SUM(l.icomision)), -1, 2, 1), 0),
                   NVL(DECODE(SIGN(SUM(l.icomision)), -1, 1, 2), 0), 0
              INTO vconcta99,   -- Saldo final de los apuntes automticos (Comisin)
                             vconcta59,   -- Factura
                   vconcta60,   -- Recibos
                             vconcta53,   -- IVA
                                       vconcta54,   -- RETEFUENTE
                   vconcta55,   -- RETEIVA
                             vconcta56,   -- RETEICA
                   vcdebhab1,   -- Debe
                   vcdebhab2,   -- Haber
                   vconcta94   -- Gastos gestion
              FROM int_facturas_agentes l, tipoiva t, agentes ag
             WHERE l.cempres = y.cempres
               AND l.nliqmen = y.nliqmen
               AND l.cagente = y.cagente
               AND l.sproces = psproces
               AND ag.cagente = y.cagente
               AND t.ctipiva = ag.ctipiva
               AND TRUNC(l.fcobro) >= TRUNC(l.fcobro)
               AND TRUNC(l.fcobro) < TRUNC(NVL(ffinvig, l.fcobro + 1));

            vcestado := 1;   --> Pendiente
            -- DEBE (siempre que los importes sean positivos)
            vtraza := 350;
            vnnumlin := vnnumlin + 1;

            INSERT INTO ctactes
                        (cagente, nnumlin, cdebhab, cconcta, cestado, ndocume, ffecmov,
                         iimport, tdescrip, cmanual, cempres, nrecibo,
                         nsinies, sseguro, sproces, fvalor, sproduc)
                 VALUES (y.cagente, vnnumlin, vcdebhab1, 99, vcestado, NULL, f_sysdate,
                         vconcta99, f_axis_literales(9002057, v_idioma), 0, vcempres, NULL,
                         NULL, NULL, psproces, vfecliq, 0);

            vtraza := 360;
            vnnumlin := vnnumlin + 1;

            INSERT INTO ctactes
                        (cagente, nnumlin, cdebhab, cconcta, cestado, ndocume, ffecmov,
                         iimport, tdescrip, cmanual, cempres, nrecibo,
                         nsinies, sseguro, sproces, fvalor, sproduc)
                 VALUES (y.cagente, vnnumlin, vcdebhab1, 59, vcestado, NULL, f_sysdate,
                         vconcta59, f_axis_literales(9002057, v_idioma), 0, vcempres, NULL,
                         NULL, NULL, psproces, vfecliq, 0);

            -- HABER (siempre que los importes sean positivos)
            vtraza := 370;
            vnnumlin := vnnumlin + 1;

            INSERT INTO ctactes
                        (cagente, nnumlin, cdebhab, cconcta, cestado, ndocume, ffecmov,
                         iimport, tdescrip, cmanual, cempres, nrecibo,
                         nsinies, sseguro, sproces, fvalor, sproduc)
                 VALUES (y.cagente, vnnumlin, vcdebhab2, 60, vcestado, NULL, f_sysdate,
                         vconcta60, f_axis_literales(9002265, v_idioma), 0, vcempres, NULL,
                         NULL, NULL, psproces, vfecliq, 0);

            vtraza := 380;

            IF vconcta53 IS NOT NULL
               AND vconcta53 != 0 THEN
               vnnumlin := vnnumlin + 1;

               INSERT INTO ctactes
                           (cagente, nnumlin, cdebhab, cconcta, cestado, ndocume, ffecmov,
                            iimport, tdescrip, cmanual, cempres,
                            nrecibo, nsinies, sseguro, sproces, fvalor, sproduc)
                    VALUES (y.cagente, vnnumlin, vcdebhab2, 53, vcestado, NULL, f_sysdate,
                            vconcta53, f_axis_literales(9002265, v_idioma), 0, vcempres,
                            NULL, NULL, NULL, psproces, vfecliq, 0);
            END IF;

            vtraza := 390;

            IF vconcta54 IS NOT NULL
               AND vconcta54 != 0 THEN
               vnnumlin := vnnumlin + 1;

               INSERT INTO ctactes
                           (cagente, nnumlin, cdebhab, cconcta, cestado, ndocume, ffecmov,
                            iimport, tdescrip, cmanual, cempres,
                            nrecibo, nsinies, sseguro, sproces, fvalor, sproduc)
                    VALUES (y.cagente, vnnumlin, vcdebhab2, 54, vcestado, NULL, f_sysdate,
                            vconcta54, f_axis_literales(9002265, v_idioma), 0, vcempres,
                            NULL, NULL, NULL, psproces, vfecliq, 0);
            END IF;

            vtraza := 400;

            IF vconcta55 IS NOT NULL
               AND vconcta55 != 0 THEN
               vnnumlin := vnnumlin + 1;

               INSERT INTO ctactes
                           (cagente, nnumlin, cdebhab, cconcta, cestado, ndocume, ffecmov,
                            iimport, tdescrip, cmanual, cempres,
                            nrecibo, nsinies, sseguro, sproces, fvalor, sproduc)
                    VALUES (y.cagente, vnnumlin, vcdebhab2, 55, vcestado, NULL, f_sysdate,
                            vconcta55, f_axis_literales(9002265, v_idioma), 0, vcempres,
                            NULL, NULL, NULL, psproces, vfecliq, 0);
            END IF;

            vtraza := 410;

            IF vconcta56 IS NOT NULL
               AND vconcta56 != 0 THEN
               vnnumlin := vnnumlin + 1;

               INSERT INTO ctactes
                           (cagente, nnumlin, cdebhab, cconcta, cestado, ndocume, ffecmov,
                            iimport, tdescrip, cmanual, cempres,
                            nrecibo, nsinies, sseguro, sproces, fvalor, sproduc)
                    VALUES (y.cagente, vnnumlin, vcdebhab2, 56, vcestado, NULL, f_sysdate,
                            vconcta56, f_axis_literales(9002265, v_idioma), 0, vcempres,
                            NULL, NULL, NULL, psproces, vfecliq, 0);
            END IF;

            vtraza := 420;

            IF vconcta94 IS NOT NULL
               AND vconcta94 != 0 THEN
               vnnumlin := vnnumlin + 1;

               INSERT INTO ctactes
                           (cagente, nnumlin, cdebhab, cconcta, cestado, ndocume, ffecmov,
                            iimport, tdescrip, cmanual, cempres,
                            nrecibo, nsinies, sseguro, sproces, fvalor, sproduc)
                    VALUES (y.cagente, vnnumlin, vcdebhab1, 94, vcestado, NULL, f_sysdate,
                            vconcta94, f_axis_literales(9002265, v_idioma), 0, vcempres,
                            NULL, NULL, NULL, psproces, vfecliq, 0);
            END IF;
         ELSE
            vtraza := 450;

            -- LIQUIDACIN SIN CORTE DE CUENTA
            SELECT NVL(MAX(nnumlin), 0)
              INTO vnnumlin
              FROM ctactes
             WHERE cagente = y.cagente;

            vtraza := 460;

            SELECT NVL(SUM(l.itotalr), 0), NVL(SUM(l.itotalr), 0), NVL(SUM(l.icomision), 0),
                   NVL(DECODE(SIGN(SUM(l.icomision)), -1, 2, 1), 0),
                   NVL(DECODE(SIGN(SUM(l.icomision)), -1, 1, 2), 0)
              INTO vconcta59,   -- Factura
                             vconcta60,   -- Recibos
                                       vconcta99,   -- Saldo final de los apuntes automticos (Comisin)
                   vcdebhab1,   -- Debe
                   vcdebhab2   -- Haber
              FROM int_facturas_agentes l
             WHERE l.cempres = y.cempres
               AND l.nliqmen = y.nliqmen
               AND l.cagente = y.cagente
               AND l.sproces = psproces;

            vcestado := 1;   --> Pendienteo
            -- DEBE (siempre que los importes sean positivos)
            vtraza := 500;
            vnnumlin := vnnumlin + 1;

            INSERT INTO ctactes
                        (cagente, nnumlin, cdebhab, cconcta, cestado, ndocume, ffecmov,
                         iimport, tdescrip, cmanual, cempres, nrecibo,
                         nsinies, sseguro, sproces, fvalor, sproduc)
                 VALUES (y.cagente, vnnumlin, vcdebhab1, 59, vcestado, NULL, f_sysdate,
                         vconcta59, f_axis_literales(9002057, v_idioma), 0, vcempres, NULL,
                         NULL, NULL, psproces, vfecliq, 0);

            -- HABER (siempre que los importes sean positivos)
            vtraza := 510;
            vnnumlin := vnnumlin + 1;

            INSERT INTO ctactes
                        (cagente, nnumlin, cdebhab, cconcta, cestado, ndocume, ffecmov,
                         iimport, tdescrip, cmanual, cempres, nrecibo,
                         nsinies, sseguro, sproces, fvalor, sproduc)
                 VALUES (y.cagente, vnnumlin, vcdebhab2, 60, vcestado, NULL, f_sysdate,
                         vconcta60, f_axis_literales(9002265, v_idioma), 0, vcempres, NULL,
                         NULL, NULL, psproces, vfecliq, 0);

            -- DEBE (siempre que los importes sean positivos)[Pendiente de liquidar]
            -- Cuando es sin corte de cuenta, por tanto sin autoliquidacin, la comisin la dejamos pendiente
            -- y cuando se liquide ya se le calcularn adems los impuestos automticamente.
            IF vconcta99 != 0 THEN
               vcestado := 1;   --> Pendiente de liquidar
               vtraza := 520;
               vnnumlin := vnnumlin + 1;

               INSERT INTO ctactes
                           (cagente, nnumlin, cdebhab, cconcta, cestado, ndocume, ffecmov,
                            iimport, tdescrip, cmanual, cempres,
                            nrecibo, nsinies, sseguro, sproces, fvalor, sproduc)
                    VALUES (y.cagente, vnnumlin, vcdebhab1, 99, vcestado, NULL, f_sysdate,
                            vconcta99, f_axis_literales(9002265, v_idioma), 0, vcempres,
                            NULL, NULL, NULL, psproces, vfecliq, 0);
            END IF;
         END IF;
      END LOOP;

      /* 5.0  - Facturas intermediario - 170459 - Final*/
      /*Actualizamos la cabecera del proceso indicando si ha habido o no algn error o warning en todo el proceso de carga*/
      vtraza := 550;
      vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces, v_tfichero,
                                                                 f_sysdate, f_sysdate,
                                                                 v_errtot, p_cproces, 0, NULL);
      vtraza := 560;
      /* vnum_err := f_procesfin(v_sproces, 0); -- 4.0 - 0024803*/
      RETURN 0;
   EXCEPTION
      WHEN errorini THEN
         ROLLBACK;
         /*KO si ha habido algun error en la cabecera*/
         pac_cargas_conf.p_genera_logs(vobj, vtraza, 'Error:' || vnum_err, SQLERRM, psproces,
                                       f_axis_literales(103187, v_idioma) || ':' || v_tfichero
                                       || ' : ' || SQLERRM);
         vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces, v_tfichero,
                                                                    f_sysdate, NULL, 1,
                                                                    p_cproces, 151541,
                                                                    SQLERRM);

         IF vnum_err <> 0 THEN
            pac_cargas_conf.p_genera_logs
                          (vobj, vtraza, vnum_err,
                           'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera2',
                           psproces,
                           f_axis_literales(180856, v_idioma) || ':' || v_tfichero || ' : '
                           || vnum_err);
         END IF;

         /* vnum_err := f_procesfin(v_sproces, 1); -- 4.0 - 0024803*/
         COMMIT;
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         /*KO si ha habido algun error en la cabecera*/
         pac_cargas_conf.p_genera_logs(vobj, vtraza, 'Error No Controlado:' || vnum_err,
                                       SQLERRM, psproces,
                                       f_axis_literales(103187, v_idioma) || ':' || v_tfichero
                                       || ' : ' || SQLERRM);
         vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces, v_tfichero,
                                                                    f_sysdate, NULL, 1,
                                                                    p_cproces, 151541,
                                                                    SQLERRM);

         IF vnum_err <> 0 THEN
            pac_cargas_conf.p_genera_logs
                          (vobj, vtraza, vnum_err,
                           'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera2',
                           psproces,
                           f_axis_literales(180856, v_idioma) || ':' || v_tfichero || ' : '
                           || vnum_err);
         END IF;

         /* vnum_err := f_procesfin(v_sproces, 1); -- 4.0 - 0024803*/
         COMMIT;
         RETURN 1;
   END f_liquidar_carga_corte_fac;

   /* 4.0 - 0024803 - Inicial*/
   /* Alta de personas en SAP*/
   FUNCTION f_set_personas_a_sap(psperson IN NUMBER, psseguro IN NUMBER, pnmovimi IN NUMBER)
      RETURN NUMBER IS
      vpsinterf      NUMBER;
      vperror        VARCHAR2(2000);
      vterminal      VARCHAR2(200);
      vemitido       NUMBER;
      perror         VARCHAR2(2000);
      psinterf       NUMBER;
      verror_pago    NUMBER;
      v_host         VARCHAR2(50);
      v_nnumerr      NUMBER;
      v_object       VARCHAR2(500) := 'pac_cargas_conf.f_set_personas_a_sap';
      v_pasexec      NUMBER := 0;
      v_param        VARCHAR2(500)
         := 'parmetros - psperson: ' || psperson || ', psseguro: ' || psseguro
            || ', pnmovimi: ' || pnmovimi;
      /* Cambios de IAXIS-4844 : start */
    VPERSON_NUM_ID PER_PERSONAS.NNUMIDE%TYPE;    
      VDIGITOIDE     PER_PERSONAS.TDIGITOIDE%TYPE;    
      VCTIPIDE       PER_PERSONAS.CTIPIDE%TYPE;
    /* Cambios de IAXIS-4844 : end */
   
   BEGIN
   
        /* Cambios de IAXIS-4844 : start */
    BEGIN
    SELECT PP.NNUMIDE,PP.TDIGITOIDE
      INTO VPERSON_NUM_ID,VDIGITOIDE
      FROM PER_PERSONAS PP
     WHERE PP.SPERSON = psperson
       AND ROWNUM = 1;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      SELECT PP.CTIPIDE, PP.NNUMIDE
      INTO VCTIPIDE, VPERSON_NUM_ID
      FROM PER_PERSONAS PP
       WHERE PP.SPERSON = psperson;
      VDIGITOIDE := PAC_IDE_PERSONA.F_DIGITO_NIF_COL(VCTIPIDE,
                             UPPER(VPERSON_NUM_ID));
    END;
  /* Cambios de IAXIS-4844 : end */
        
      v_host := pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                              'ALTA_INTERM_HOST');
      v_pasexec := 10;

      IF v_host IS NOT NULL THEN
         v_pasexec := 20;

         IF pac_persona.f_persona_duplicada_nnumide(psperson) = 1 THEN
            v_host := pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                    'DUPL_ACREEDOR_HOST');
         END IF;

         v_pasexec := 30;
         v_nnumerr := pac_user.f_get_terminal(f_user, vterminal);
         v_pasexec := 40;
         /* Cambios de IAXIS-4844 : start */
         v_nnumerr := pac_con.f_alta_persona(pac_md_common.f_get_cxtempresa, psperson,
                                             vterminal, vpsinterf, verror_pago,
                                             pac_md_common.f_get_cxtusuario, 1, 'ALTA', VDIGITOIDE,
                                             v_host);
        /* Cambios de IAXIS-4844 : end */
         v_pasexec := 50;

         IF v_nnumerr <> 0 THEN
            RETURN v_nnumerr;
         END IF;
      END IF;

      v_pasexec := 60;

      IF NVL(pac_parametros.f_parempresa_n(k_empresaaxis, 'CONTAB_ONLINE'), 0) = 1
         AND NVL(pac_parametros.f_parempresa_n(k_empresaaxis, 'GESTIONA_COBPAG'), 0) = 1 THEN
         v_pasexec := 70;
         v_nnumerr := pac_user.f_get_terminal(pac_md_common.f_get_cxtusuario, vterminal);
         v_pasexec := 80;
         v_nnumerr := pac_con.f_emision_pagorec(k_empresaaxis, 1, 17, psseguro, pnmovimi,
                                                vterminal, vemitido, vpsinterf, verror_pago,
                                                f_user, NULL, NULL, NULL, 1);
         v_pasexec := 90;

         IF v_nnumerr <> 0
            OR TRIM(verror_pago) IS NOT NULL THEN
            v_pasexec := 90;

            IF v_nnumerr = 0 THEN
               v_nnumerr := 9903116;
               /*151323;*/
               RETURN v_nnumerr;
            END IF;
         /*p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza,*/
         /*            'carga REVERSIONES-SGP - error no controlado ',*/
         /*            verror_pago || ' - ' || v_nnumerr);*/
         END IF;
      END IF;

      v_pasexec := 100;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param,
                     SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_set_personas_a_sap;

   FUNCTION f_get_nliqmen(
      pcempres IN NUMBER,
      pcagente IN NUMBER,
      pfecliq IN DATE,
      psproces IN NUMBER,
      pmodo IN NUMBER,
      pcliquido IN NUMBER)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;
      v_nliqmen      NUMBER := NULL;
      v_nliqaux2     NUMBER := NULL;
      v_selec        CLOB;
      v_object       VARCHAR2(500) := 'pac_cargas_conf.f_get_nliqmen';
      v_param        VARCHAR2(500)
         := 'parmetros - pcempres: ' || pcempres || ', pcagente: ' || pcagente
            || ', pfecliq: ' || pfecliq || ', psproces: ' || psproces || ', pmodo: ' || pmodo;
      v_pasexec      NUMBER(5) := 1;
      vdiasliq       NUMBER(5) := 0;
   BEGIN
      /*Borramos si hay algun previo para este agente / empresa / fecha SOLO SI estamos en real*/
      SELECT MAX(nliqmen)
        INTO v_nliqaux2
        FROM liquidacab
       WHERE cagente = pcagente
         AND fliquid = pfecliq
         AND ctipoliq = 1
         AND cempres = pcempres;

      v_pasexec := 2;

      /* Si existe algun previo y estamos en modo real borramos el previo que existe.*/
      IF v_nliqaux2 IS NOT NULL
         AND pmodo = 0 THEN
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
            /*Creamos la cabecera de liquidacab por agente*/
            vnumerr := pac_liquida.f_set_cabeceraliq(pcagente, v_nliqmen, pfecliq, f_sysdate,
                                                     NULL, pcempres, psproces, NULL, NULL,
                                                     NULL, pmodo, NULL, NULL, NULL);

            IF vnumerr <> 0 THEN
               RETURN vnumerr;
            END IF;

            v_pasexec := 5;
      END;

      v_pasexec := 6;
      RETURN v_nliqmen;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param,
                     SQLCODE || ' - ' || SQLERRM);
         RETURN NULL;
   END f_get_nliqmen;

   FUNCTION f_liquidar_carga_cortepro_fac(psproces IN NUMBER, p_cproces IN NUMBER)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'PAC_CARGAS_CONF.f_liquidar_carga_corte_prod_fac';

        /*
      Estado control de linea "int_carga_ctrl.cestado"
      1       Error
      2       Aviso
      3       Pendiente
      4       Correcto
      5       No procesado
      */
      CURSOR fact_liq(psproces2 IN NUMBER) IS
         SELECT   a.sproces, a.nlinea, a.cagente, a.nrecibo, a.fcobro, a.cortecuenta,
                  a.cmoneda, a.itotalr itotalr_int, a.icomision, iva, iretefuente, ireteiva,
                  ireteica, NVL(vm.iprinet, v.iprinet) iprinet, r.ctiprec, r.cgescob,
                  r.ccobban, r.cdelega, r.sseguro, r.nmovimi,
                  NVL(vm.icombru, v.icombru) icomisi, NVL(vm.icomret, v.icomret) icomret,
                  NVL(vm.itotalr, v.itotalr) itotalr, NVL(vm.itotimp, v.itotimp) itotimp,
                  NVL(r.sperson, ff_sperson_tomador(r.sseguro)) sperson_pag
             FROM int_facturas_agentes a, vdetrecibos v, vdetrecibos_monpol vm, recibos r
                                                                                         /* 4.0 - 0024803 - Inicial*/
                  ,
                  int_carga_ctrl_linea c
            /* 4.0 - 0024803 - Final*/
         WHERE    a.sproces = psproces2
              AND v.nrecibo = r.nrecibo
              AND vm.nrecibo(+) = r.nrecibo
              AND a.nrecibo = r.nrecibo
              /* 4.0 - 0024803 - Inicial*/
              AND c.sproces = a.sproces
              AND c.nlinea = a.nlinea
              AND c.cestado IN 4
         /*  AND EXISTS(SELECT 1*/
         /*               FROM int_carga_ctrl*/
         /*              WHERE int_carga_ctrl.sproces = a.sproces*/
         /*                AND int_carga_ctrl.cestado = 4)*/
         /*  FOR UPDATE OF a.cagente, a.cempres, a.nliqmen, a.nliqlin*/
         /* 4.0 - 0024803 - Final*/
         /*Solo las no procesadas*/
         ORDER BY nlinea;

      CURSOR ctactes_liq(psproces2 IN NUMBER) IS
         SELECT   a.cagente, a.cempres, a.nliqmen, NVL(MIN(a.cortecuenta),
                                                       g.cliquido) cliquido
             FROM agentes g, int_facturas_agentes a
                                                   /* 4.0 - 0024803 - Inicial*/
                  , int_carga_ctrl_linea c
            /* 4.0 - 0024803 - Final*/
         WHERE    a.sproces = psproces2
              AND a.cagente = g.cagente
              /* 4.0 - 0024803 - Inicial*/
              AND c.sproces = a.sproces
              AND c.nlinea = a.nlinea
              AND c.cestado IN 4
         /*> Trate solo los pendientes -- 4.0 - 0024803*/
         /* 4.0 - 0024803 - Inicial*/
         GROUP BY a.cagente, a.cempres, a.nliqmen, g.cliquido
         ORDER BY a.cagente;

      CURSOR pago_corte_cuenta(psproces IN NUMBER) IS
         SELECT DISTINCT (p.spago) spago
                    FROM ctactes c, pagoscomisiones p
                   WHERE c.sproces = psproces
                     AND c.nnumlin = p.nnumlin
                     AND p.cagente = c.cagente
                     AND p.cestado = 1
                     AND p.cempres = c.cempres;

      vtraza         NUMBER := 0;
      vdeserror      VARCHAR2(1000);
      errorini       EXCEPTION;
      /*Indica error grabando estados.--Error que para ejecucin*/
      vcoderror      NUMBER;
      v_deserror     int_carga_ctrl_linea_errs.tmensaje%TYPE;
      v_tfichero     int_carga_ctrl.tfichero%TYPE;
      e_errorliq     EXCEPTION;
      vnum_err       NUMBER;
      v_idioma       NUMBER;
      v_errdat       VARCHAR2(4000);
      v_errtot       NUMBER := 0;
      /* v_sproces      NUMBER; -- 4.0 - 0024803*/
      vcempres       empresas.cempres%TYPE := pac_md_common.f_get_cxtempresa;
      vnrecibo       recibos.nrecibo%TYPE;
      v_regext       ext_seguros%ROWTYPE;
      v_ncarga       mig_cargas.ncarga%TYPE;
      vmodo          NUMBER;
      vnliqmen       liquidalin.nliqmen%TYPE;
      vnliqlin       liquidalin.nliqlin%TYPE;
      vcageliq       agentes.cagente%TYPE;
      vcagente       agentes.cagente%TYPE := -1;
      vsmovrec       movrecibo.smovrec%TYPE;
      v_cmultimon    NUMBER;
      v_cmoncia      NUMBER;
      v_itasa        NUMBER;
      v_fcambio      DATE;
      v_icomisi      NUMBER;
      vnnumlin       NUMBER;
      vfecliq        DATE := TRUNC(f_sysdate);
      v_signo        NUMBER;
      vnliqmen2      NUMBER;
      vnnumlin2      NUMBER;
      vcliquido      agentes.cliquido%TYPE;
      vconcta59      NUMBER;
      /* Factura*/
      vconcta60      NUMBER;
      /* Recibos*/
      vconcta99      NUMBER;
      /* Saldo final de los apuntes automticos (Comisin)*/
      vcdebhab1      NUMBER;
      /* Debe*/
      vcdebhab2      NUMBER;
      /* Haber*/
      vconcta53      NUMBER;
      /* IVA*/
      vconcta54      NUMBER;
      /* RETEFUENTE*/
      vconcta55      NUMBER;
      /* RETEIVA*/
      vconcta56      NUMBER;
      /* RETEICA*/
      vcestado       NUMBER;
      verror         NUMBER;
      vsmovagr       NUMBER := 0;
      vvalor_ica     NUMBER;
      vvalor_fuente  NUMBER;
      vvalor_iva     NUMBER;
      vvalor_reteiva NUMBER;
      vyacargado     NUMBER;
      /* 4.0 - 0024803*/
      vsproces       NUMBER;
      /* 5.0*/
      vterminal      VARCHAR2(200);
      vemitido       NUMBER;
      perror         VARCHAR2(2000);
      psinterf       NUMBER;
      vspago         NUMBER;
   /* 4.0 - 0024803 - Final*/
   BEGIN
      /*vnum_err := f_procesini(f_user, k_empresaaxis, 'CARGA_FACT_AGE_LIQ', 'PROCESO',*/
      /*                        v_sproces); -- 4.0 - 0024803*/
      vtraza := 5;
      v_idioma := k_idiomaaaxis;

      IF psproces IS NULL THEN
         vnum_err := 9000505;
         pac_cargas_conf.p_genera_logs(vobj, vtraza, 'Error:' || vnum_err,
                                       'Parmetro psproces obligatorio.', psproces,
                                       f_axis_literales(vnum_err, v_idioma) || ':'
                                       || v_tfichero || ' : ' || vnum_err);
         RAISE errorini;
      END IF;

      vtraza := 10;

      SELECT MIN(tfichero)
        INTO v_tfichero
        FROM int_carga_ctrl
       WHERE sproces = psproces;

      vtraza := 20;

      IF v_tfichero IS NULL THEN
         vnum_err := 9901092;
         p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                     'Falta fichero para proceso: ' || psproces);
         vnnumlin2 := NULL;
         vnum_err := f_proceslin(psproces,
                                 f_axis_literales(vnum_err, v_idioma) || ':' || v_tfichero
                                 || ' : ' || vnum_err,
                                 1, vnnumlin2);
         RAISE errorini;
      END IF;

      vtraza := 30;

      FOR x IN fact_liq(psproces) LOOP
         vtraza := 40;

         BEGIN
                  /* 5.0  - Facturas intermediario - 170459 - Inicio*/
                  /*
            IF vnliqmen IS NULL
            OR NVL(vcagente, -1) != x.cagente THEN
            vcagente := x.cagente;
            vtraza := 60;
            IF pac_parametros.f_parempresa_n(vcempres, 'LIQUIDA_CTIPAGE') IS NULL THEN
            vcageliq := vcagente;
            ELSE
            vtraza := 70;
            vcageliq :=
            pac_agentes.f_get_cageliq
            (vcempres,
            pac_parametros.f_parempresa_n(vcempres,
            'LIQUIDA_CTIPAGE'),
            vcagente);
            END IF;
            -- Que la liquidacin sea por corte de cuenta (liquido/autoliquidacin)[1] o no [0]
            -- Se dejar grabado en LIQUIDACAB
            vtraza := 80;
            IF x.cortecuenta IS NULL THEN
            BEGIN
            vtraza := 90;
            SELECT NVL(cliquido, 0)
            INTO vcliquido
            FROM agentes
            WHERE cagente = vcageliq;
            END;
            ELSE
            vtraza := 100;
            vcliquido := x.cortecuenta;
            END IF;
            vmodo := 0;   --> Modo real
            vtraza := 110;
            vnliqmen := f_get_nliqmen(vcempres, x.cagente, vfecliq, psproces, vmodo,
            vcliquido);
            vnliqlin := 1;
            ELSE
            vtraza := 120;
            vcagente := x.cagente;
            vnliqlin := vnliqlin + 1;
            END IF;
            -- Si el recibo tiene cobros parciales hace la liquidacin parcial
            -- No se tratarn los cobros parciales
            --IF pac_adm_cobparcial.f_get_importe_cobro_parcial(x.nrecibo) != 0 THEN
            --   vnum_err := pac_liquida.f_set_recibos_parcial_liq_ind(vcempres, vcageliq,
            --                                                         vfecliq, NULL, psproces,
            --                                                         0, vnliqmen2, NULL,
            --                                                         x.nrecibo);
            --ELSE
            vtraza := 130;
            IF x.cgescob = 3 THEN
            v_icomisi :=(-x.itotalr + x.icomisi);
            ELSE
            v_icomisi := x.icomisi;
            END IF;
            vtraza := 140;
            IF x.ctiprec IN(9, 13) THEN
            v_signo := -1;
            ELSE
            v_signo := 1;
            END IF;
            vtraza := 150;
            v_cmultimon := NVL(pac_parametros.f_parempresa_n(vcempres, 'MULTIMONEDA'), 0);
            IF v_cmultimon = 1 THEN
            v_cmoncia := pac_parametros.f_parempresa_n(vcempres, 'MONEDAEMP');
            vnum_err := pac_oper_monedas.f_datos_contraval(NULL, x.nrecibo, NULL,
            f_sysdate, 2, v_itasa,
            v_fcambio);
            END IF;
            */
                  /* 5.0  - Facturas intermediario - 170459 - Final*/
                  /*END IF;*/
                  /* 3.0  0024803 - 158543 - Inicio*/
            vtraza := 190;
            verror := f_set_personas_a_sap(x.sperson_pag, x.sseguro, x.nmovimi);
                  /* A SAP solo se enva los tipos de cobro = 2*/
                  /*
            -- 4.0 - 0024803 - Ahora no hace falta que sea cticob = 2
            UPDATE recibos
            SET ctipcob = 2
            WHERE nrecibo = x.nrecibo;
            */
                  /* 3.0  0024803 - 158543 - Final*/
            vtraza := 200;

            IF verror != 0 THEN
               p_tab_error(f_sysdate, f_user, vobj, vtraza, verror,
                           'Error(' || verror
                           || ') generando alta personas en SAP. f_set_personas_a_sap('
                           || x.sperson_pag || ',' || x.sseguro || ',' || x.nmovimi || ')');
               RAISE e_errorliq;
            END IF;

            /* COBRAR RECIBO*/
            vtraza := 210;
            verror := f_movrecibo(x.nrecibo, 1, f_sysdate, NULL, vsmovagr, vnliqmen, vnliqlin,
                                  f_sysdate, x.ccobban, x.cdelega, NULL, NULL);
            vtraza := 230;

            IF verror != 0 THEN
               p_tab_error(f_sysdate, f_user, vobj, vtraza, verror,
                           'Error(' || verror || ') cobrado RECIBO (' || x.nrecibo || ')');
               RAISE e_errorliq;
            END IF;

            vtraza := 240;

            UPDATE int_facturas_agentes
               SET nliqmen = vnliqmen,
                   nliqlin = vnliqlin
             /* ,cempres = vcempres*/
             /*WHERE CURRENT OF fact_liq;*/
            WHERE  sproces = x.sproces
               AND nlinea = x.nlinea;

            vtraza := 250;
                  /* 5.0  - Facturas intermediario - 170459 - Inicio*/
                  /*
            SELECT MAX(smovrec)
            INTO vsmovrec
            FROM movrecibo
            WHERE nrecibo = x.nrecibo;
            vtraza := 260;
            INSERT INTO liquidalin
            (cempres, nliqmen, cagente, nliqlin, nrecibo, smovrec,
            itotimp, itotalr,
            iprinet, icomisi,
            iretenccom, isobrecomision, iretencsobrecom, iconvoleducto,
            iretencoleoducto, ctipoliq, itotimp_moncia,
            itotalr_moncia,
            iprinet_moncia,
            icomisi_moncia,
            iretenccom_moncia, isobrecom_moncia, iretencscom_moncia,
            iconvoleod_moncia, iretoleod_moncia, fcambio,
            cagerec)
            VALUES (vcempres, vnliqmen, vcageliq, vnliqlin, x.nrecibo, vsmovrec,
            NVL(x.itotimp, 0) * v_signo, NVL(x.itotalr, 0) * v_signo,
            NVL(x.iprinet, 0) * v_signo, NVL(v_icomisi, 0) * v_signo,
            NVL(x.icomret, 0) * v_signo, NULL, NULL, NULL,
            NULL, NULL, f_round(NVL(x.itotimp, 0) * v_signo * v_itasa, v_cmoncia),
            f_round(NVL(x.itotalr, 0) * v_signo * v_itasa, v_cmoncia),
            f_round(NVL(x.iprinet, 0) * v_signo * v_itasa, v_cmoncia),
            f_round(NVL(v_icomisi, 0) * v_signo * v_itasa, v_cmoncia),
            f_round(NVL(x.icomret, 0) * v_signo * v_itasa, v_cmoncia), NULL, NULL,
            NULL, NULL, DECODE(v_cmultimon, 0, NULL, NVL(v_fcambio, f_sysdate)),
            x.cagente);
            */
            vsproces := NULL;
            /*se enva el agente a null necesariamente para que liquide el cocorretaje.*/
            /*Modificamos las cuentas para que no se enven aqui, sino ms abajo en corte de cuenta.*/
            verror := pac_liquida.f_liquidaliq_age(NULL, vcempres, 0, vfecliq, v_idioma,
                                                   pac_md_common.f_get_cxtagente, vsproces,
                                                   NULL, x.nrecibo);

            /* 5.0  - Facturas intermediario - 170459 - Final*/
            IF verror <> 0 THEN
               p_int_error(f_axis_literales(9900986, v_idioma),
                           'p_procesos_nocturnos_pos Liquidacin de comisiones diarias '
                           || f_axis_literales(9901093, v_idioma),
                           2, verror);
            /*  7.0 - Corregimos el proceso para enviar el aviso de cobro a SAP - 177026 - Inicio*/
            ELSE
               /*lanzamos a mano el movimiento del cobro por corte de cuenta*/
               IF NVL(pac_parametros.f_parempresa_n(vcempres, 'CONTAB_ONLINE'), 0) = 1
                  /*AND pmodo <> 1*/
                  /*AND verror <> 0*/
                  AND NVL(pac_parametros.f_parempresa_n(vcempres, 'GESTIONA_COBPAG'), 0) = 1
                                                                                            /*AND v_nrecpend = 0*/
               THEN
                  psinterf := NULL;
                  verror := pac_user.f_get_terminal(pac_md_common.f_get_cxtusuario, vterminal);
                  verror := pac_con.f_emision_pagorec(vcempres, 1, 4, x.nrecibo, NULL,
                                                      vterminal, vemitido, psinterf, perror,
                                                      f_user, NULL, NULL, NULL, 1);

                  IF verror <> 0
                     OR TRIM(perror) IS NOT NULL THEN
                     IF verror = 0 THEN
                        verror := 9903116;
                        /*151323;*/
                        RETURN verror;
                     END IF;

                     p_tab_error(f_sysdate, f_user, 'pac_cargas_conf.f_liquidar_carga_fac', 1,
                                 'error no controlado', perror || ' ' || verror);
                  END IF;
               END IF;
            END IF;

            /*lanzamos a mano el movimiento de liquidacin por corte de cuenta*/
            IF NVL(pac_parametros.f_parempresa_n(vcempres, 'CONTAB_ONLINE'), 0) = 1
               /*AND pmodo <> 1*/
               /*AND verror <> 0*/
               AND NVL(pac_parametros.f_parempresa_n(vcempres, 'GESTIONA_COBPAG'), 0) = 1
               AND vsproces IS NOT NULL
                                       /*AND v_nrecpend = 0*/
            THEN
               FOR cur_corte IN pago_corte_cuenta(vsproces) LOOP
                  psinterf := NULL;
                  verror := pac_user.f_get_terminal(pac_md_common.f_get_cxtusuario, vterminal);
                  verror := pac_con.f_emision_pagorec(vcempres, 1, 21, cur_corte.spago, NULL,
                                                      vterminal, vemitido, psinterf, perror,
                                                      f_user, NULL, NULL, NULL, 1);

                  IF verror <> 0
                     OR TRIM(perror) IS NOT NULL THEN
                     IF verror = 0 THEN
                        verror := 9903116;
                        /*151323;*/
                        RETURN verror;
                     END IF;

                     p_tab_error(f_sysdate, f_user, 'pac_cargas_conf.f_liquidar_carga_fac', 1,
                                 'error no controlado', perror || ' ' || verror);
                  END IF;
               END LOOP;
            END IF;

                  /*esto fuera*/
                  /*
            IF NVL(pac_parametros.f_parempresa_n(vcempres, 'CONTAB_ONLINE'), 0) = 1
            --AND pmodo <> 1
            --AND verror <> 0
            AND NVL(pac_parametros.f_parempresa_n(vcempres, 'GESTIONA_COBPAG'), 0) = 1
            --AND v_nrecpend = 0
            THEN
            SELECT MAX(spago)
            INTO vspago
            FROM pagoscomisiones
            WHERE (cagente, cempres, nnumlin) IN(SELECT cagente, cempres, nnumlin
            FROM ctactes
            WHERE sproces = vsproces)
            AND cestado = 1;
            verror := pac_user.f_get_terminal(pac_md_common.f_get_cxtusuario, vterminal);
            verror := pac_con.f_emision_pagorec(vcempres, 1, 20, vspago, NULL, vterminal,
            vemitido, psinterf, perror, f_user, NULL,
            NULL, NULL, 1);
            IF verror <> 0
            OR TRIM(perror) IS NOT NULL THEN
            IF verror = 0 THEN
            verror := 9903116;   --151323;
            RETURN verror;
            END IF;
            p_tab_error(f_sysdate, f_user, 'pac_cargas_conf.f_liquidar_carga_fac', 1,
            'error no controlado', perror || ' ' || verror);
            END IF;
            END IF;
            */
            vtraza := 270;
         EXCEPTION
            WHEN e_errorliq THEN
               /* ROLLBACK; -- 4.0 - 0024803*/
               v_errtot := 1;
               vnum_err := p_marcalinea(psproces, x.nlinea, 2, 1, 0, NULL, 'ALTA(KO-ERROR)',
                                        NULL, NULL, NULL, x.cagente, x.nrecibo);
               /*- IF vnum_err <> 0 THEN*/
               /*-    RAISE errorini;   --Error que para ejecucin*/
               /*- END IF;*/
               vnum_err :=
                  p_marcalineaerror(psproces, x.nlinea, NULL, 1, verror,

                                    /* 2.0 - 24803 - 154143 (aadir)*/
                                    f_axis_literales(verror, pac_md_common.f_get_cxtidioma)
                                    || ' ' || x.nrecibo
                                                       /* , verror  -- 2.0 - 24803 - 154143 (comentar)*/
                  );
         /*IF vnum_err <> 0 THEN*/
         /*   RAISE errorini;   --Error que para ejecucin*/
         /*END IF;*/
         /*-RAISE errorini;   -- Si hay error mejor que no sigua con el resto del proceso*/
         END;
      END LOOP;

      /* 4.0 - 0024803 - Ahora no hace falta que sea cticob = 2 - Inicio*/
      IF v_errtot = 1 THEN
         RAISE errorini;
      /* Si hay error mejor que no sigua con el resto del proceso*/
      END IF;

      /* 4.0 - 0024803 - Ahora no hace falta que sea cticob = 2 - Final*/
      vtraza := 300;
        /* 5.0  - Facturas intermediario - 170459 - Inicio*/
        /*
      FOR y IN ctactes_liq(psproces) LOOP
      vtraza := 310;
      IF y.cliquido = 1 THEN
      -- LIQUIDACIN POR CORTE DE CUENTA / LIQUIDO
      vtraza := 320;
      SELECT NVL(MAX(nnumlin), 0)
      INTO vnnumlin
      FROM ctactes
      WHERE cagente = y.cagente;
      vtraza := 330;
      SELECT NVL(SUM(l.icomision), 0), NVL(SUM(l.itotalr - l.icomision), 0),
      NVL(SUM(l.itotalr), 0), NVL(SUM(l.iva), 0), NVL(SUM(l.iretefuente), 0),
      NVL(SUM(l.ireteiva), 0), NVL(SUM(l.ireteica), 0),
      NVL(DECODE(SIGN(SUM(l.icomision)), -1, 2, 1), 0),
      NVL(DECODE(SIGN(SUM(l.icomision)), -1, 1, 2), 0)
      INTO vconcta99,   -- Saldo final de los apuntes automticos (Comisin)
      vconcta59,   -- Factura
      vconcta60,   -- Recibos
      vconcta53,   -- IVA
      vconcta54,   -- RETEFUENTE
      vconcta55,   -- RETEIVA
      vconcta56,   -- RETEICA
      vcdebhab1,   -- Debe
      vcdebhab2   -- Haber
      FROM int_facturas_agentes l
      WHERE l.cempres = y.cempres
      AND l.nliqmen = y.nliqmen
      AND l.cagente = y.cagente
      AND l.sproces = psproces;
      vcestado := 0;   --> Liquidado
      -- DEBE (siempre que los importes sean positivos)
      vtraza := 350;
      vnnumlin := vnnumlin + 1;
      INSERT INTO ctactes
      (cagente, nnumlin, cdebhab, cconcta, cestado, ndocume, ffecmov,
      iimport, tdescrip, cmanual, cempres, nrecibo,
      nsinies, sseguro, sproces, fvalor, sproduc)
      VALUES (y.cagente, vnnumlin, vcdebhab1, 99, vcestado, NULL, f_sysdate,
      vconcta99, f_axis_literales(9002057, v_idioma), 0, vcempres, NULL,
      NULL, NULL, psproces, vfecliq, 0);
      vtraza := 360;
      vnnumlin := vnnumlin + 1;
      INSERT INTO ctactes
      (cagente, nnumlin, cdebhab, cconcta, cestado, ndocume, ffecmov,
      iimport, tdescrip, cmanual, cempres, nrecibo,
      nsinies, sseguro, sproces, fvalor, sproduc)
      VALUES (y.cagente, vnnumlin, vcdebhab1, 59, vcestado, NULL, f_sysdate,
      vconcta59, f_axis_literales(9002057, v_idioma), 0, vcempres, NULL,
      NULL, NULL, psproces, vfecliq, 0);
      -- HABER (siempre que los importes sean positivos)
      vtraza := 370;
      vnnumlin := vnnumlin + 1;
      INSERT INTO ctactes
      (cagente, nnumlin, cdebhab, cconcta, cestado, ndocume, ffecmov,
      iimport, tdescrip, cmanual, cempres, nrecibo,
      nsinies, sseguro, sproces, fvalor, sproduc)
      VALUES (y.cagente, vnnumlin, vcdebhab2, 60, vcestado, NULL, f_sysdate,
      vconcta60, f_axis_literales(9002265, v_idioma), 0, vcempres, NULL,
      NULL, NULL, psproces, vfecliq, 0);
      vtraza := 380;
      IF vconcta53 IS NOT NULL
      AND vconcta53 != 0 THEN
      vnnumlin := vnnumlin + 1;
      INSERT INTO ctactes
      (cagente, nnumlin, cdebhab, cconcta, cestado, ndocume, ffecmov,
      iimport, tdescrip, cmanual, cempres,
      nrecibo, nsinies, sseguro, sproces, fvalor, sproduc)
      VALUES (y.cagente, vnnumlin, vcdebhab2, 53, vcestado, NULL, f_sysdate,
      vconcta53, f_axis_literales(9002265, v_idioma), 0, vcempres,
      NULL, NULL, NULL, psproces, vfecliq, 0);
      END IF;
      vtraza := 390;
      IF vconcta54 IS NOT NULL
      AND vconcta54 != 0 THEN
      vnnumlin := vnnumlin + 1;
      INSERT INTO ctactes
      (cagente, nnumlin, cdebhab, cconcta, cestado, ndocume, ffecmov,
      iimport, tdescrip, cmanual, cempres,
      nrecibo, nsinies, sseguro, sproces, fvalor, sproduc)
      VALUES (y.cagente, vnnumlin, vcdebhab2, 54, vcestado, NULL, f_sysdate,
      vconcta54, f_axis_literales(9002265, v_idioma), 0, vcempres,
      NULL, NULL, NULL, psproces, vfecliq, 0);
      END IF;
      vtraza := 400;
      IF vconcta55 IS NOT NULL
      AND vconcta55 != 0 THEN
      vnnumlin := vnnumlin + 1;
      INSERT INTO ctactes
      (cagente, nnumlin, cdebhab, cconcta, cestado, ndocume, ffecmov,
      iimport, tdescrip, cmanual, cempres,
      nrecibo, nsinies, sseguro, sproces, fvalor, sproduc)
      VALUES (y.cagente, vnnumlin, vcdebhab2, 55, vcestado, NULL, f_sysdate,
      vconcta55, f_axis_literales(9002265, v_idioma), 0, vcempres,
      NULL, NULL, NULL, psproces, vfecliq, 0);
      END IF;
      vtraza := 410;
      IF vconcta56 IS NOT NULL
      AND vconcta56 != 0 THEN
      vnnumlin := vnnumlin + 1;
      INSERT INTO ctactes
      (cagente, nnumlin, cdebhab, cconcta, cestado, ndocume, ffecmov,
      iimport, tdescrip, cmanual, cempres,
      nrecibo, nsinies, sseguro, sproces, fvalor, sproduc)
      VALUES (y.cagente, vnnumlin, vcdebhab2, 56, vcestado, NULL, f_sysdate,
      vconcta56, f_axis_literales(9002265, v_idioma), 0, vcempres,
      NULL, NULL, NULL, psproces, vfecliq, 0);
      END IF;
      ELSE
      vtraza := 450;
      -- LIQUIDACIN SIN CORTE DE CUENTA
      SELECT NVL(MAX(nnumlin), 0)
      INTO vnnumlin
      FROM ctactes
      WHERE cagente = y.cagente;
      vtraza := 460;
      SELECT NVL(SUM(l.itotalr), 0), NVL(SUM(l.itotalr), 0), NVL(SUM(l.icomision), 0),
      NVL(DECODE(SIGN(SUM(l.icomision)), -1, 2, 1), 0),
      NVL(DECODE(SIGN(SUM(l.icomision)), -1, 1, 2), 0)
      INTO vconcta59,   -- Factura
      vconcta60,   -- Recibos
      vconcta99,   -- Saldo final de los apuntes automticos (Comisin)
      vcdebhab1,   -- Debe
      vcdebhab2   -- Haber
      FROM int_facturas_agentes l
      WHERE l.cempres = y.cempres
      AND l.nliqmen = y.nliqmen
      AND l.cagente = y.cagente
      AND l.sproces = psproces;
      vcestado := 0;   --> Liquidado
      -- DEBE (siempre que los importes sean positivos)
      vtraza := 500;
      vnnumlin := vnnumlin + 1;
      INSERT INTO ctactes
      (cagente, nnumlin, cdebhab, cconcta, cestado, ndocume, ffecmov,
      iimport, tdescrip, cmanual, cempres, nrecibo,
      nsinies, sseguro, sproces, fvalor, sproduc)
      VALUES (y.cagente, vnnumlin, vcdebhab1, 59, vcestado, NULL, f_sysdate,
      vconcta59, f_axis_literales(9002057, v_idioma), 0, vcempres, NULL,
      NULL, NULL, psproces, vfecliq, 0);
      -- HABER (siempre que los importes sean positivos)
      vtraza := 510;
      vnnumlin := vnnumlin + 1;
      INSERT INTO ctactes
      (cagente, nnumlin, cdebhab, cconcta, cestado, ndocume, ffecmov,
      iimport, tdescrip, cmanual, cempres, nrecibo,
      nsinies, sseguro, sproces, fvalor, sproduc)
      VALUES (y.cagente, vnnumlin, vcdebhab2, 60, vcestado, NULL, f_sysdate,
      vconcta60, f_axis_literales(9002265, v_idioma), 0, vcempres, NULL,
      NULL, NULL, psproces, vfecliq, 0);
      -- DEBE (siempre que los importes sean positivos)[Pendiente de liquidar]
      -- Cuando es sin corte de cuenta, por tanto sin autoliquidacin, la comisin la dejamos pendiente
      -- y cuando se liquide ya se le calcularn adems los impuestos automticamente.
      IF vconcta99 != 0 THEN
      vcestado := 1;   --> Pendiente de liquidar
      vtraza := 520;
      vnnumlin := vnnumlin + 1;
      INSERT INTO ctactes
      (cagente, nnumlin, cdebhab, cconcta, cestado, ndocume, ffecmov,
      iimport, tdescrip, cmanual, cempres,
      nrecibo, nsinies, sseguro, sproces, fvalor, sproduc)
      VALUES (y.cagente, vnnumlin, vcdebhab1, 99, vcestado, NULL, f_sysdate,
      vconcta99, f_axis_literales(9002265, v_idioma), 0, vcempres,
      NULL, NULL, NULL, psproces, vfecliq, 0);
      END IF;
      END IF;
      END LOOP;
      */
        /* 5.0  - Facturas intermediario - 170459 - Final*/
        /*Actualizamos la cabecera del proceso indicando si ha habido o no algn error o warning en todo el proceso de carga*/
      vtraza := 550;
      vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces, v_tfichero,
                                                                 f_sysdate, f_sysdate,
                                                                 v_errtot, p_cproces, 0, NULL);
      vtraza := 560;
      /* vnum_err := f_procesfin(v_sproces, 0); -- 4.0 - 0024803*/
      RETURN 0;
   EXCEPTION
      WHEN errorini THEN
         ROLLBACK;
         /*KO si ha habido algun error en la cabecera*/
         pac_cargas_conf.p_genera_logs(vobj, vtraza, 'Error:' || vnum_err, SQLERRM, psproces,
                                       f_axis_literales(103187, v_idioma) || ':' || v_tfichero
                                       || ' : ' || SQLERRM);
         vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces, v_tfichero,
                                                                    f_sysdate, NULL, 1,
                                                                    p_cproces, 151541,
                                                                    SQLERRM);

         IF vnum_err <> 0 THEN
            pac_cargas_conf.p_genera_logs
                          (vobj, vtraza, vnum_err,
                           'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera2',
                           psproces,
                           f_axis_literales(180856, v_idioma) || ':' || v_tfichero || ' : '
                           || vnum_err);
         END IF;

         /* vnum_err := f_procesfin(v_sproces, 1); -- 4.0 - 0024803*/
         COMMIT;
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         /*KO si ha habido algun error en la cabecera*/
         pac_cargas_conf.p_genera_logs(vobj, vtraza, 'Error No Controlado:' || vnum_err,
                                       SQLERRM, psproces,
                                       f_axis_literales(103187, v_idioma) || ':' || v_tfichero
                                       || ' : ' || SQLERRM);
         vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces, v_tfichero,
                                                                    f_sysdate, NULL, 1,
                                                                    p_cproces, 151541,
                                                                    SQLERRM);

         IF vnum_err <> 0 THEN
            pac_cargas_conf.p_genera_logs
                          (vobj, vtraza, vnum_err,
                           'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera2',
                           psproces,
                           f_axis_literales(180856, v_idioma) || ':' || v_tfichero || ' : '
                           || vnum_err);
         END IF;

         /* vnum_err := f_procesfin(v_sproces, 1); -- 4.0 - 0024803*/
         COMMIT;
         RETURN 1;
   END f_liquidar_carga_cortepro_fac;

--AAC_FI-CONF_379-20160927

   --CONF 239 JAVENDANO
   /*************************************************************************
   FUNCTION f_lre_ejecutarcarga
   Ejecurta la carga del archivo de listas restrictivas
   Retorna 0 Ok <> 0 Error
   *************************************************************************/
   FUNCTION f_lre_ejecutarcarga(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER)
      RETURN NUMBER IS
      vtraza         NUMBER;
      vnum_err       NUMBER;
      vobj           VARCHAR2(100) := 'pac_cargas_conf.f_lre_ejecutarcarga';
      vdeserror      VARCHAR2(100);
      esalir         EXCEPTION;
   BEGIN
      vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces, p_nombre,
                                                                 f_sysdate, NULL, 3,
                                                                 p_cproces, NULL, NULL);
      vtraza := 1;
      vnum_err := f_lre_ejecutarfichero(p_nombre, p_path, p_cproces, psproces);

      IF vnum_err <> 0 THEN
         vdeserror := 'Leyendo fichero: ' || p_nombre;
         RAISE esalir;
      END IF;

      vtraza := 2;
      vnum_err := f_lre_ejecutarproceso(psproces);
      --Posibles retornos: 1- Error, 2correcto , 3- pendiente, 4 con avisos
      vtraza := 3;

      UPDATE int_carga_ctrl
         SET cestado = vnum_err,
             ffin = f_sysdate
       WHERE sproces = psproces;

      vtraza := 4;

      DELETE      lre_personas
            WHERE NVL(cmarca, 0) = 0;

      vtraza := 5;

      UPDATE lre_personas
         SET cmarca = 0
       WHERE cclalis = 1;   --Solo se marcan las listas externas

      RETURN 0;
   EXCEPTION
      WHEN esalir THEN
         p_genera_logs_g(vobj, vtraza, 'Error: ' || SQLCODE, SQLERRM, psproces,
                         'Error: ' || vdeserror);
         RETURN vnum_err;
      WHEN OTHERS THEN
         p_genera_logs_g(vobj, vtraza, 'Error: ' || SQLCODE, SQLERRM, psproces,
                         'Error: ' || SQLERRM);
         RETURN 1;
   END f_lre_ejecutarcarga;

   /*************************************************************************
   FUNCTION f_lre_ejecutarfichero
   Ejecurta la carga del archivo de listas restrictivas
   Retorna 1- Error, 2- correcto
   *************************************************************************/
   FUNCTION f_lre_ejecutarfichero(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces OUT NUMBER)
      RETURN NUMBER IS
      vdeserror      VARCHAR2(1000);
      vobj           VARCHAR2(100) := 'pac_cargas_conf.f_lre_ejecutarfichero';
      vtraza         NUMBER := 0;
      vnum_err       NUMBER := 0;
      vncarga        NUMBER := f_next_carga_g;
      v_line         VARCHAR2(32000);
      v_file         UTL_FILE.file_type;
      v_numlineaf    NUMBER := 0;
      -- Numero de linea del fichero
      v_numlineai    NUMBER := 1;
      -- Numero de linea del insert
      errorini       EXCEPTION;
      e_errdatos     EXCEPTION;
      v_nnumide      VARCHAR2(50);
      v_ctipide      VARCHAR2(5);
      v_nombre       VARCHAR2(100);
      v_apellido     VARCHAR2(100);
      v_crle         VARCHAR2(10);
      v_sep          VARCHAR2(1) := '|';
      v_currfield    VARCHAR2(64);

      PROCEDURE p_controlar_error(p_traza NUMBER, p_estado NUMBER, v_msg VARCHAR2) IS
      BEGIN
         vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces, p_nombre,
                                                                    f_sysdate, NULL, p_estado,
                                                                    p_cproces, NULL, v_msg);

         IF vnum_err <> 0 THEN
            -- Si fallan esta funciones de gesti?n salimos del programa
            p_tab_error(f_sysdate, f_user, vobj, p_traza, vnum_err,
                        'Error llamando pac_gestion_procesos.f_set_carga_ctrl_cabecera'
                        || p_traza);
            RAISE errorini;
         END IF;
      END p_controlar_error;
   BEGIN
      SELECT sproces.NEXTVAL
        INTO psproces
        FROM DUAL;

      vtraza := 1;

      IF p_cproces IS NULL THEN
         vnum_err := 9901092;
         vdeserror := 'cfg_files falta proceso: ' || vobj;
         RAISE e_errdatos;
      END IF;

      vtraza := 2;
      p_controlar_error(vtraza, 3, NULL);

      BEGIN
         -- Inicio: Lectura de fichero.
         vtraza := 3;
         v_file := UTL_FILE.fopen(p_path, p_nombre, 'r');

         LOOP
            BEGIN
               vtraza := 4;
               v_numlineaf := v_numlineaf + 1;
               UTL_FILE.get_line(v_file, v_line);
               --IF (v_numlineaf > 1) THEN
               v_currfield := 'CTIPIDE';
               v_ctipide := pac_util.splitt(v_line, 1, v_sep);
               v_currfield := 'NNUMIDE';
               v_nnumide := pac_util.splitt(v_line, 2, v_sep);
               v_currfield := 'TNOMBRES';
               v_nombre := pac_util.splitt(v_line, 3, v_sep);
               v_currfield := 'CLRE';
               v_crle := REPLACE(pac_util.splitt(v_line, 4, v_sep), CHR(13), NULL);
               vtraza := 5;

               INSERT INTO int_carga_lre
                           (proceso, nlinea, ncarga, clre, nnumide,
                            ctipide, tnomape, falta)
                    VALUES (psproces, v_numlineai, vncarga, TO_NUMBER(v_crle), v_nnumide,
                            v_ctipide, v_nombre, f_sysdate);

               v_numlineai := v_numlineai + 1;
               --END IF;
               vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces => psproces,
                                                                       pnlinea => v_numlineaf,
                                                                       pctipo => 20,
                                                                       pidint => v_numlineaf,
                                                                       pidext => v_numlineaf,
                                                                       pcestado => 4,
                                                                       pcvalidado => NULL,
                                                                       psseguro => NULL,
                                                                       pidexterno => NULL,
                                                                       pncarga => NULL,
                                                                       pnsinies => NULL,
                                                                       pntramit => NULL,
                                                                       psperson => NULL,
                                                                       pnrecibo => NULL);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  -- No hay mas datos para leer.
                  EXIT;
               WHEN OTHERS THEN
                  p_error_linea_g(psproces, NULL, v_numlineaf,
                                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
            END;
         END LOOP;

         COMMIT;
         UTL_FILE.fclose(v_file);
         RETURN 0;
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            ROLLBACK;
            UTL_FILE.fclose(v_file);
            p_controlar_error(5, 1,
                              f_axis_literales(9904284, kidiomaaaxis) || ' at line '
                              || v_numlineaf);
            RETURN 9904284;   -- Duplicated record
         WHEN VALUE_ERROR THEN
            ROLLBACK;
            UTL_FILE.fclose(v_file);
            p_controlar_error(6, 1,
                              f_axis_literales(9907933, kidiomaaaxis) || ' at line '
                              || v_numlineaf || ', field: ' || v_currfield);
            RETURN 9907933;
         -- Data Error. Check character length or number format
         WHEN OTHERS THEN
            ROLLBACK;
            UTL_FILE.fclose(v_file);
            p_controlar_error(7, 1, f_axis_literales(103187, kidiomaaaxis));
            DBMS_OUTPUT.put_line(SQLERRM);
            RETURN 103187;   -- An error has occurred while reading the file
      END;
   EXCEPTION
      WHEN e_errdatos THEN
         ROLLBACK;
         p_genera_logs_g(vobj, vtraza, 'Error: ' || SQLCODE, SQLERRM, psproces,
                         'Error: ' || vdeserror);
         RETURN vnum_err;
      WHEN errorini THEN
         ROLLBACK;
         p_genera_logs_g(vobj, vtraza, 'Error:' || 'ErrorIni : ' || vnum_err,
                         'Error:' || 'Insertando estados registros: ', psproces,
                         f_axis_literales(108953, kidiomaaaxis) || ':' || p_nombre || ' : '
                         || 'errorini');
         RETURN 108953;   -- A runtime error has occurred
   END f_lre_ejecutarfichero;

   /*************************************************************************
   FUNCTION f_lre_ejecutarproceso
   Ejecurta la carga del archivo de listas restrictivas
   Retorna 1- Error, 2- correcto
   *************************************************************************/
   FUNCTION f_lre_ejecutarproceso(p_sproces IN NUMBER)
      RETURN NUMBER IS
      reglre         lre_personas%ROWTYPE;
      vcod           NUMBER;
      vexiste        detvalores.tatribu%TYPE;
      vtraza         NUMBER;
      vdeserror      VARCHAR2(1000);
      vobj           VARCHAR2(100) := 'pac_cargas_conf.f_lre_ejecutarproceso';
      verror         NUMBER;
   BEGIN
      vtraza := 1;

      FOR cur_lre IN (SELECT *
                        FROM int_carga_lre
                       WHERE proceso = p_sproces) LOOP
         reglre := NULL;
         vtraza := 2;
         reglre.nnumide := cur_lre.nnumide;
         reglre.ctipide := f_buscavalor_g('TIPOIDEN_FICLISEXT', cur_lre.ctipide);
         reglre.ctiplis := cur_lre.clre;
         reglre.nordide := 0;
         reglre.cclalis := 1;
         reglre.ctipper := NULL;
         reglre.ctipper := NULL;
         reglre.tnomape := cur_lre.tnomape;
         reglre.tnombre1 := NULL;
         reglre.tnombre2 := NULL;
         reglre.tapelli1 := NULL;
         reglre.tapelli2 := NULL;
         reglre.cnovedad := 1;
         reglre.cnotifi := NULL;
         reglre.cclalis := 1;

         IF reglre.ctiplis IS NULL THEN
            vcod := '105940';
            vdeserror := '';
            RAISE e_errdatos;
         ELSE
            vtraza := 3;

            BEGIN
               SELECT DISTINCT tatribu
                          INTO vexiste
                          FROM detvalores
                         WHERE cvalor = 800048
                           AND cidioma = kidiomaaaxis
                           AND catribu = reglre.ctiplis;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  vcod := '102844';
                  RAISE e_errdatos;
            END;
         END IF;

         vtraza := 4;

         -- Busca la persona en la tabla de listas restringidas, por tipo de lista, clase y datos de la persona.
         SELECT MAX(sperlre), MAX(sperson)
           INTO reglre.sperlre, reglre.sperson
           FROM lre_personas
          WHERE nnumide = reglre.nnumide
            AND ctipide = reglre.ctipide
            AND nordide = reglre.nordide
            AND cclalis = reglre.cclalis
            AND ctiplis = reglre.ctiplis;

         IF reglre.sperson IS NULL THEN
            vtraza := 5;

            SELECT MAX(sperson)   -- Se busca primero por n?mero de documento e identificador.
              INTO reglre.sperson
              FROM per_personas
             WHERE nnumide = reglre.nnumide
               AND ctipide = reglre.ctipide;

            -- En caso de que no se encuentre, se busca por nombre.
            IF reglre.sperson IS NULL THEN
               vtraza := 6;

               SELECT MAX(sperson)
                 INTO reglre.sperson
                 FROM per_detper
                WHERE UPPER(tnombre1 || ' ' || tnombre2 || ' ' || tapelli1 || ' ' || tapelli2) =
                                                                          UPPER(reglre.tnomape);
            END IF;
         END IF;

         IF reglre.sperson IS NOT NULL THEN
            -- En caso de que la persona haya sido encontrada en la bd, se buscan los datos neceserios
            vtraza := 7;

            -- Datos de la persona...
            SELECT p.nnumide, p.ctipide, dp.tnombre1, dp.tnombre2,
                   dp.tapelli1, dp.tapelli2,
                   dp.tnombre1 || ' ' || dp.tnombre2 || ' ' || dp.tapelli1 || ' '
                   || dp.tapelli2
              INTO reglre.nnumide, reglre.ctipide, reglre.tnombre1, reglre.tnombre2,
                   reglre.tapelli1, reglre.tapelli2,
                   reglre.tnomape
              FROM per_personas p JOIN per_detper dp ON p.sperson = dp.sperson
             WHERE p.sperson = reglre.sperson;

            vtraza := 7.1;

            --Se valida la existencia en listas clinton clre= 5 o PEPs clre = 45
            IF cur_lre.clre = 5 THEN
               --Se marca la persona en lista Clinton o OFAC
               verror := pac_marcas.f_set_marca_automatica(kempresa, reglre.sperson, '0050');
            ELSIF cur_lre.clre = 45 THEN
               --Se marca la persona en lista PEPS
               verror := pac_marcas.f_set_marca_automatica(kempresa, reglre.sperson, '0041');
            END IF;

            IF verror <> 0 THEN
               p_genera_logs_g(vobj, vtraza, 'Error: ', verror, p_sproces,
                               'Error: Actualizando marcas CLINTON o PEPS');
            END IF;
         END IF;

         IF reglre.sperlre IS NULL THEN
            -- Si la persona no existe en la lista restringida se da de alta.
            SELECT sperlre.NEXTVAL
              INTO reglre.sperlre
              FROM DUAL;

            vtraza := 8;

            INSERT INTO lre_personas
                        (sperlre, nnumide, nordide, ctipide,
                         ctipper,
                         tnomape, tnombre1, tnombre2, tapelli1,
                         tapelli2, sperson, cnovedad, cnotifi,
                         cclalis, ctiplis, finclus, cusumod, cmarca)
                 VALUES (reglre.sperlre, reglre.nnumide, reglre.nordide, reglre.ctipide,
                         DECODE(reglre.ctipper,
                                NULL, DECODE(reglre.ctipide, 37, 2, 1),
                                reglre.ctipper),
                         reglre.tnomape, reglre.tnombre1, reglre.tnombre2, reglre.tapelli1,
                         reglre.tapelli2, reglre.sperson, reglre.cnovedad, reglre.cnotifi,
                         reglre.cclalis, reglre.ctiplis, f_sysdate, f_user, 1);
         ELSE
            -- Si la persona ya existia en la lista restringida se actualzia
            vtraza := 9;

            UPDATE lre_personas
               SET cnovedad = 1,
                   fmodifi = f_sysdate,
                   fexclus = NULL,
                   sperson = reglre.sperson,
                   cmarca = 1
             WHERE sperlre = reglre.sperlre
               AND ctiplis = reglre.ctiplis;
         END IF;
      END LOOP;

      RETURN 2;
   EXCEPTION
      WHEN e_errdatos THEN
         p_genera_logs_g(vobj, vtraza, 'Error: ' || SQLCODE, SQLERRM, p_sproces,
                         'Error: ' || vdeserror);
         RETURN 1;
      WHEN OTHERS THEN
         p_genera_logs_g(vobj, vtraza, 'Error: ' || SQLCODE, SQLERRM, p_sproces,
                         'Error: ' || SQLERRM);
         RETURN 1;
   END f_lre_ejecutarproceso;

   --CONF 239 JAVENDANO

   -- CONF-247 OSUAREZ

   /*************************************************************************
      Carga de los ficheros de CIFIN INICIO
    *************************************************************************/
   FUNCTION f_modi_cifin_ext(p_nombre VARCHAR2)
      RETURN NUMBER IS
      v_tnomfich     VARCHAR2(100);
   BEGIN
      v_tnomfich := SUBSTR(p_nombre, 1, INSTR(p_nombre, '.') - 1);

      --Modificamos los logs
      EXECUTE IMMEDIATE 'alter table CIFIN_INTERMEDIO_EXT ACCESS PARAMETERS (records delimited by 0x''0A''
                   logfile '
                        || CHR(39) || v_tnomfich || '.log' || CHR(39)
                        || '
                   badfile ' || CHR(39) || v_tnomfich || '.bad' || CHR(39)
                        || '
                   discardfile ' || CHR(39) || v_tnomfich || '.dis' || CHR(39)
                        || '
                   fields terminated by ''|'' lrtrim
                   MISSING FIELD VALUES ARE NULL
                   REJECT ROWS WITH ALL NULL FIELDS
                   (  TIPO_ID ,
                      NO_ID ,
                      DIGITO_DQ ,
                      RAZON_SOCIAL ,
                      APELLIDO1_DQ ,
                      APELLIDO2_DQ ,
                      NOMBRE1_DQ ,
                      NOMBRE2_DQ ,
                      CODIGO_PAIS ,
                      FECHA_EXPEDICION DATE MASK "dd/mm/yyyy",
                      CIUDAD_EXPEDICION ,
                      DEPTO_EXPEDICION ,
                      CODIGO_CIUDAD ,
                      CODIGO_DEPTO ,
                      ESTADO_DTO ,
                      RANGO_EDAD ,
                      CODIGO_CIIU ,
                      ACTIVIDAD_ECONOMICA ,
                      GENERO ,
                      UBICACION_DIRECCION_1 ,
                      DIRECCION_1 ,
                      CIUDAD1_1 ,
                      DEPTO1_1 ,
                      CODIGO_CIUDAD1_1 ,
                      CODIGO_DEPTO1_1 ,
                      FECHA_ULT1_REPORTE_1 DATE MASK "dd/mm/yyyy",
                      UBICACION_TELEFONO_1 ,
                      TELEFONO_1 ,
                      CIUDAD2_1 ,
                      DEPTO2_1 ,
                      CODIGO_CIUDAD2_1 ,
                      CODIGO_DEPTO2_1 ,
                      FECHA_ULT2_REPORTE_1 DATE MASK "dd/mm/yyyy",
                      CELULAR_1 ,
                      FECHA_ULT3_REPORTE_1 DATE MASK "dd/mm/yyyy",
                      CORREO_1 ,
                      FECHA_ULT4_REPORTE_1 DATE MASK "dd/mm/yyyy",
                      UBICACION_DIRECCION_2 ,
                      DIRECCION_2 ,
                      CIUDAD1_2 ,
                      DEPTO1_2 ,
                      CODIGO_CIUDAD2_2 ,
                      CODIGO_DEPTO1_2 ,
                      FECHA_ULT1_REPORTE_2 DATE MASK "dd/mm/yyyy",
                      UBICACION_TELEFONO_2 ,
                      TELEFONO_2 ,
                      CIUDAD2_2 ,
                      DEPTO2_2 ,
                      CODIGO_CIUDAD1_2 ,
                      CODIGO_DEPTO2_2 ,
                      FECHA_ULT2_REPORTE_2 DATE MASK "dd/mm/yyyy",
                      CELULAR_2 ,
                      FECHA_ULT3_REPORTE_2 DATE MASK "dd/mm/yyyy",
                      CORREO_2 ,
                      FECHA_ULT4_REPORTE_2 DATE MASK "dd/mm/yyyy",
                      UBICACION_DIRECCION_3 ,
                      DIRECCION_3 ,
                      CIUDAD1_3 ,
                      DEPTO1_3 ,
                      CODIGO_CIUDAD1_3 ,
                      CODIGO_DEPTO1_3 ,
                      FECHA_ULT1_REPORTE_3 DATE MASK "dd/mm/yyyy",
                      UBICACION_TELEFONO_3 ,
                      TELEFONO_3 ,
                      CIUDAD2_3 ,
                      DEPTO2_3 ,
                      CODIGO_CIUDAD2_3 ,
                      CODIGO_DEPTO2_3 ,
                      FECHA_ULT2_REPORTE_3 DATE MASK "dd/mm/yyyy",
                      CELULAR_3 ,
                      FECHA_ULT3_REPORTE_3 DATE MASK "dd/mm/yyyy",
                      CORREO_3 ,
                      FECHA_ULT4_REPORTE_3 DATE MASK "dd/mm/yyyy",
                      INGRESO_MIN_PROBABLE,
                      CAPACIDAD_PAGO ,
                      CAPACIDAD_ENDEUDA ,
                      ENDEUDA_TOTAL_SFINANCIERO ,
                      SUMATORIA_CALIF_A ,
                      SUMATORIA_CALIF_B ,
                      SUMATORIA_CALIF_C ,
                      SUMATORIA_CALIF_D ,
                      SUMATORIA_CALIF_E ,
                      SUM_CON_ULT_6_MESES ,
                      PUNTAJE_SCORE ,
                      PROB_MORA ,
                      PROB_INCUMPLIMIENTO
                  ))';

      --Cargamos el fichero
      EXECUTE IMMEDIATE 'ALTER TABLE CIFIN_INTERMEDIO_EXT LOCATION (''' || p_nombre || ''')';

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_cargas_conf.F_MODI_CIFIN_EXT', 1,
                     'Error creando la tabla.', SQLERRM);
         RETURN 107914;
   END f_modi_cifin_ext;

   PROCEDURE p_trasp_tabla(pdeserror OUT VARCHAR2, psproces IN NUMBER) IS
      num_err        NUMBER;
      v_pasexec      NUMBER := 1;
      vparam         VARCHAR2(1) := NULL;
      vobj           VARCHAR2(200) := 'pac_cargas_conf.p_trasp_tabla';
      v_numerr       NUMBER := 0;
      errgrabarprov  EXCEPTION;
      e_object_error EXCEPTION;
      v_linea        NUMBER := 0;
      v_idcarga      NUMBER := 0;
      v_desc_carga   VARCHAR2(20) := NULL;

    v_existe_endeuda NUMBER := 0;
      v_existe_sfianci NUMBER := 0;
      v_sfinanci       NUMBER := 0;

   BEGIN
      v_pasexec := 0;
      pdeserror := NULL;

      SELECT NVL(MAX(id_carga + 1), 1)
        INTO v_idcarga
        FROM cifin_intermedio;

      v_desc_carga := 'CARGA FICHERO';
      DBMS_SESSION.set_nls('nls_numeric_characters', ''',.''');

      INSERT INTO cifin_intermedio
         (SELECT v_idcarga, v_desc_carga, f_sysdate, tipo_id, no_id, digito_dq, razon_social,
                 apellido1_dq, apellido2_dq, nombre1_dq, nombre2_dq, codigo_pais,
                 fecha_expedicion, ciudad_expedicion, depto_expedicion, codigo_ciudad,
                 codigo_depto, estado_dto, rango_edad, codigo_ciiu, actividad_economica,
                 genero, ubicacion_direccion_1, direccion_1, ciudad1_1, depto1_1,
                 codigo_ciudad1_1, codigo_depto1_1, fecha_ult1_reporte_1, ubicacion_telefono_1,
                 telefono_1, ciudad2_1, depto2_1, codigo_ciudad2_1, codigo_depto2_1,
                 fecha_ult2_reporte_1, celular_1, fecha_ult3_reporte_1, correo_1,
                 fecha_ult4_reporte_1, ubicacion_direccion_2, direccion_2, ciudad1_2, depto1_2,
                 codigo_ciudad2_2, codigo_depto1_2, fecha_ult1_reporte_2, ubicacion_telefono_2,
                 telefono_2, ciudad2_2, depto2_2, codigo_ciudad1_2, codigo_depto2_2,
                 fecha_ult2_reporte_2, celular_2, fecha_ult3_reporte_2, correo_2,
                 fecha_ult4_reporte_2, ubicacion_direccion_3, direccion_3, ciudad1_3, depto1_3,
                 codigo_ciudad1_3, codigo_depto1_3, fecha_ult1_reporte_3, ubicacion_telefono_3,
                 telefono_3, ciudad2_3, depto2_3, codigo_ciudad2_3, codigo_depto2_3,
                 fecha_ult2_reporte_3, celular_3, fecha_ult3_reporte_3, correo_3,
                 fecha_ult4_reporte_3,
                 TO_NUMBER(REPLACE(ingreso_min_probable, '.', ',')) ingreso_min_probable,
                 TO_NUMBER(REPLACE(capacidad_pago, '.', ',')) capacidad_pago,
                 TO_NUMBER(REPLACE(capacidad_endeuda, '.', ',')) capacidad_endeuda,
                 TO_NUMBER(REPLACE(endeuda_total_sfinanciero, '.',
                                   ',')) endeuda_total_sfinanciero,
                 TO_NUMBER(REPLACE(sumatoria_calif_a, '.', ',')) sumatoria_calif_a,
                 TO_NUMBER(REPLACE(sumatoria_calif_b, '.', ',')) sumatoria_calif_b,
                 TO_NUMBER(REPLACE(sumatoria_calif_c, '.', ',')) sumatoria_calif_c,
                 TO_NUMBER(REPLACE(sumatoria_calif_d, '.', ',')) sumatoria_calif_d,
                 TO_NUMBER(REPLACE(sumatoria_calif_e, '.', ',')) sumatoria_calif_e,
                 TO_NUMBER(REPLACE(sum_con_ult_6_meses, '.', ',')) sum_con_ult_6_meses,
                 TO_NUMBER(REPLACE(puntaje_score, '.', ',')) puntaje_score,
                 TO_NUMBER(REPLACE(prob_mora, '.', ',')) prob_mora,
                 TO_NUMBER(REPLACE(prob_incumplimiento, '.', ',')) prob_incumplimiento
            FROM cifin_intermedio_ext);

      /* Cambios para IAXIS-2015 : Start
      FOR ext IN(select e.*
                             from cifin_intermedio_ext e
                           ) LOOP

                         SELECT count(SFINANCI)
                          INTO v_existe_sfianci
                          FROM FIN_GENERAL fg
                         WHERE fg.SPERSON in(select pp.SPERSON
                                               from PER_PERSONAS pp
                                              where pp.NNUMIDE
                                               like ext.NO_ID);

                       IF v_existe_sfianci > 0 THEN
                        SELECT SFINANCI
                          INTO v_sfinanci
                          FROM FIN_GENERAL fg
                         WHERE fg.SPERSON in(select pp.SPERSON
                                               from PER_PERSONAS pp
                                              where pp.NNUMIDE
                                               like ext.NO_ID);

                               IF TO_DATE(ext.FECHA_ULT1_REPORTE_1,'DD/MM/YYYY') is not null THEN
                                   SELECT count(*)
                                      INTO v_existe_endeuda
                                      FROM FIN_ENDEUDAMIENTO
                                     WHERE sfinanci = v_sfinanci
                                       and fconsulta = TO_DATE(ext.FECHA_ULT1_REPORTE_1,'DD/MM/YYYY');

                                     IF v_existe_endeuda = 0 THEN
                                        INSERT INTO FIN_ENDEUDAMIENTO
                                                    (sfinanci, fconsulta, cfuente, iminimo, icappag,
                                                      icapend, iendtot, ncalifa, ncalifb, ncalifc,
                                                      ncalifd, ncalife, nconsul, nscore, nmora,
                                                      icupog, icupos, fcupo, crestric, tconcepc,
                                                      tconceps, tcburea, tcotros)
                                              values (v_sfinanci, TO_DATE(ext.FECHA_ULT1_REPORTE_1,'DD/MM/YYYY'), '1', TO_NUMBER(REPLACE(ext.INGRESO_MIN_PROBABLE, '.', ',')), TO_NUMBER(REPLACE(ext.CAPACIDAD_PAGO, '.', ',')),
                                                      TO_NUMBER(REPLACE(ext.CAPACIDAD_ENDEUDA, '.', ',')), TO_NUMBER(REPLACE(ext.ENDEUDA_TOTAL_SFINANCIERO, '.', ',')), TO_NUMBER(REPLACE(ext.SUMATORIA_CALIF_A, '.', ',')), TO_NUMBER(REPLACE(ext.SUMATORIA_CALIF_B, '.', ',')), TO_NUMBER(REPLACE(ext.SUMATORIA_CALIF_C, '.', ',')),
                                                      TO_NUMBER(REPLACE(ext.SUMATORIA_CALIF_D, '.', ',')), TO_NUMBER(REPLACE(ext.SUMATORIA_CALIF_E, '.', ',')), TO_NUMBER(REPLACE(ext.SUM_CON_ULT_6_MESES, '.', ',')), TO_NUMBER(REPLACE(ext.PUNTAJE_SCORE, '.', ',')),
                                                      TO_NUMBER(REPLACE(ext.PROB_MORA, '.', ',')),
                                                      null, null, null, null, null,
                                                      null, null, null);
                                    END IF;
                               END IF;
                        END IF;
                    END LOOP;

      v_pasexec := 1;
      COMMIT;

      DECLARE
         CURSOR c1 IS
            SELECT ROWNUM AS codigo
              FROM cifin_intermedio
             WHERE id_carga = v_idcarga;
      BEGIN
         FOR f1 IN c1 LOOP
            v_pasexec := 2;
            v_linea := f1.codigo;
            v_numerr := p_marcalinea(psproces, f1.codigo, 6, 3, 0, NULL, f1.codigo, NULL);

            IF v_numerr <> 0 THEN
               RAISE errgrabarprov;
            END IF;

            v_pasexec := 3;
         END LOOP;

         v_pasexec := 4;
         COMMIT;
      EXCEPTION
         WHEN errgrabarprov THEN
            ROLLBACK;
            p_tab_error(f_sysdate, f_user, vobj, v_pasexec, 108953, vobj);
            pdeserror := f_axis_literales(108953, k_idiomaaaxis) || ':' || vobj;
            RAISE e_object_error;
         WHEN OTHERS THEN
            ROLLBACK;
            p_tab_error(f_sysdate, f_user, vobj, v_pasexec, SQLCODE, SQLERRM);
            pdeserror := f_axis_literales(105133, k_idiomaaaxis) || ':' || v_linea || '    '
                         || f_axis_literales(1000136, k_idiomaaaxis) || ':'
                         || TO_NUMBER(v_pasexec + 1) || ' ' || SQLERRM;
            RAISE e_object_error;
      END;
   ** Cambios para IAXIS-2015 : End **/
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
         RAISE;
   END p_trasp_tabla;

   FUNCTION f_cifin_ejecutarcarga(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'pac_cargas_conf';
      vtraza         NUMBER := 0;
      vnum_err       NUMBER;
      vsalir         EXCEPTION;
   BEGIN
      vtraza := 0;

      SELECT NVL(cpara_error, 0)
        INTO k_para_carga
        FROM cfg_files
       WHERE cempres = k_empresaaxis
         AND cproceso = p_cproces;

      IF psproces IS NULL THEN
         vnum_err := pac_cargas_conf.f_ejecutar_carga_fichero_cifin(p_nombre, p_path,
                                                                    p_cproces, psproces);

         IF vnum_err <> 0 THEN
            RAISE vsalir;
         END IF;
      END IF;

      vtraza := 1;
      vnum_err := pac_cargas_conf.f_proceso_cifin(psproces, p_cproces);

      IF vnum_err <> 0 THEN
         RAISE vsalir;
   /* Cambios para IAXIS-2015 : Start */
     else
      vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces,
                                                                 p_nombre,
                                                                 null,
                                                                 f_sysdate,
                                                                 4,
                                                                 p_cproces,
                                                                 0,
                                                                 NULL);
      vnum_err := f_procesfin(psproces, 0);
     /* Cambios para IAXIS-2015 : End */
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN vsalir THEN
         RETURN 1;
   END f_cifin_ejecutarcarga;

   FUNCTION f_ejecutar_carga_fichero_cifin(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,   -- BUG16130:DRA:15/10/2010
      psproces OUT NUMBER)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'f_ejecutar_carga_fichero_cifin';
      linea          NUMBER := 0;
      pcarga         NUMBER;
      sentencia      VARCHAR2(32000);
      vfichero       UTL_FILE.file_type;
      vtraza         NUMBER := 0;
      verror         NUMBER;
      vdeserror      VARCHAR2(1000);
      v_sproces      NUMBER;
      errorini       EXCEPTION;   --Indica error grabando estados.--Error que para ejecucin
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
      /* Cambios para IAXIS-2015 : Start */
    vnum_err_cargarCIFIN NUMBER;
    vnum_CountFail NUMBER;
    vnum_CountSuccess NUMBER;
      /* Cambios para IAXIS-2015 : End */
   BEGIN
      vtraza := 0;
      vsinproc := TRUE;
      vnum_err := f_procesini(f_user, k_empresaaxis,
        /* Cambios para IAXIS-2015 : Start */
                            'CARGA_CIFIN',
                /* Cambios para IAXIS-2015 : End */
         p_nombre, v_sproces);

      IF vnum_err <> 0 THEN
         RAISE errorini;   --Error que para ejecucin
      END IF;

      psproces := v_sproces;
      vtraza := 1;

      IF p_cproces IS NULL THEN
         vnum_err := 9901092;
         vdeserror := 'cfg_files falta proceso: ' || vobj;
         RAISE e_errdatos;
      END IF;

      vtraza := 11;
      vnum_err :=
         pac_gestion_procesos.f_set_carga_ctrl_cabecera(v_sproces, p_nombre, f_sysdate, NULL,
                                                        3, p_cproces,   -- BUG16130:DRA:29/09/2010
                                                        NULL, NULL);
      vtraza := 12;

      IF vnum_err <> 0 THEN   --Si fallan esta funciones de gestin salimos del programa
         p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                     'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera');
         vnum_err := f_proceslin(v_sproces,
                                 f_axis_literales(180856, k_idiomaaaxis) || ':' || p_nombre
                                 || ' : ' || vnum_err,
                                 1, vnnumlin);
         RAISE errorini;   --Error que para ejecucin
      END IF;

      COMMIT;
      vtraza := 2;
      --Creamos la tabla apartir del nombre de fichero enviado dinamicamente.
      vnum_err := f_modi_cifin_ext(p_nombre);

      IF vnum_err <> 0 THEN
         p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                     'Error creando la tabla externa');
         vnum_err := f_proceslin(v_sproces,
                                 f_axis_literales(vnum_err, k_idiomaaaxis) || ':' || p_nombre
                                 || ' : ' || vnum_err,
                                 1, vnnumlin);
         RAISE errorini;   --Error que para ejecucin
      END IF;

  /* Cambios para IAXIS-2015 : Start */
    vtraza := 53;
    if vnum_err = 0 then
     begin
      p_setPersona_Cargar_CIFIN(p_path,p_nombre,p_cproces,v_sproces,vnum_CountFail,vnum_CountSuccess,vnum_err_cargarCIFIN);
      IF vnum_err_cargarCIFIN <> 0 THEN
         p_tab_error(f_sysdate,
              f_user,
              vobj,
              vtraza,
              vnum_err_cargarCIFIN,
              'Cargar archivo de CIFIN : Funciona :'||vnum_CountSuccess || ' : No Funciona :'||vnum_CountFail);

         vnum_err := f_proceslin(v_sproces,
                     f_axis_literales(vnum_err_cargarCIFIN, k_idiomaaaxis) || ':' ||
                     p_nombre || ' : ' || vnum_err_cargarCIFIN,
                     1,
                     vnnumlin);
        RAISE errorini;
      END IF;
      exception
      WHEN others THEN
        p_tab_error(f_sysdate,
              f_user,
              vobj,
              vtraza,
              vnum_CountFail,
              'Error en cargar archivo de CIFIN : Funciona :'||vnum_CountSuccess || ' : No Funciona :'||vnum_CountFail);
      end;
    end if;
    /* Cambios para IAXIS-2015 : End */

      p_trasp_tabla(vdeserror, v_sproces);
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

         IF vnum_err <> 0 THEN   --Si fallan esta funciones de gestin salimos del programa
            --RAISE ErrGrabarProv;
            p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                        'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera2');
            vnnumlin := NULL;
            vnum_err := f_proceslin(v_sproces,
                                    f_axis_literales(180856, k_idiomaaaxis) || ':' || p_nombre
                                    || ' : ' || vnum_err,
                                    1, vnnumlin);
            RAISE errorini;   --Error que para ejecucin
         END IF;

         vtraza := 52;
         COMMIT;   --Guardamos la tabla temporal int
         RAISE vsalir;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN vsalir THEN
         NULL;
         RETURN 1;
      WHEN e_errdatos THEN
         ROLLBACK;
         pac_cargas_conf.p_genera_logs(vobj, vtraza, 'Error:' || vnum_err, vdeserror,
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
   END f_ejecutar_carga_fichero_cifin;

   FUNCTION f_proceso_cifin(psproces IN NUMBER, p_cproces IN NUMBER)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'pac_cargas_conf.f_proceso_cifin';
      vtraza         NUMBER := 0;
      vdeserror      VARCHAR2(1000);
      errorini       EXCEPTION;   --Indica error grabando estados.--Error que para ejecucin
      vsalir         EXCEPTION;
      emigra         EXCEPTION;
      vnnumlin       NUMBER;
      verrorfin      BOOLEAN := FALSE;
      vavisfin       BOOLEAN := FALSE;
      vcoderror      NUMBER;
      v_deserror     int_carga_ctrl_linea_errs.tmensaje%TYPE;
      v_tfichero     int_carga_ctrl.tfichero%TYPE;
      e_errdatos     EXCEPTION;
      e_validaciones EXCEPTION;
      vnum_err       NUMBER;
      v_dummy        NUMBER := 0;
      vtiperr        NUMBER := 0;
      verror         NUMBER;   --Codigo error
      vterror        VARCHAR2(4000);   --Descripcin ampliada error
      vwarning       NUMBER;
      v_hay          NUMBER := 0;
      v_cnodrban     NUMBER;
      v_idioma       NUMBER;
      v_sperson      NUMBER;
      v_errdat       VARCHAR2(4000);
      v_errtot       NUMBER := 0;
      v_wartot       NUMBER := 0;
      v_sproces      NUMBER;
      vactualiza     NUMBER(1);
      v_contmarca    NUMBER := 0;
      v_maxmodelo    NUMBER := 0;
      v_contmodelo   NUMBER := 0;
      v_conttipo     NUMBER := 0;
      v_clase        aut_codclaveh.cclaveh%TYPE;
      v_peso         NUMBER := 0;
      v_servicio     NUMBER := 0;
      v_origen       NUMBER := 0;
      v_modelo       aut_modelos.cmodelo%TYPE;
      v_version      NUMBER := 0;
      v_idcarga      NUMBER := 0;
      v_pasexec      NUMBER := 1;
      v_linea        NUMBER := 0;
      v_numerr       NUMBER := 0;
   BEGIN
   /** Cambios para IAXIS-2015 : Start **
      vnum_err := f_procesini(f_user, k_empresaaxis, 'CARGA_CIFIN', 'PROCESO', v_sproces);
    ** Cambios para IAXIS-2015 : End **/
      vtraza := 0;
      v_idioma := k_idiomaaaxis;

      IF psproces IS NULL THEN
         vnum_err := 9000505;
         pac_cargas_conf.p_genera_logs(vobj, vtraza, 'Error:' || vnum_err,
                                       'Parmetro psproces obligatorio.', psproces,
                                       f_axis_literales(vnum_err, v_idioma) || ':'
                                       || v_tfichero || ' : ' || vnum_err);
         RAISE errorini;
      END IF;

      vtraza := 1;
  /** Cambios para IAXIS-2015 : Start **
      SELECT NVL(MAX(id_carga), 1)
        INTO v_idcarga
        FROM cifin_intermedio
       WHERE f_carga = f_sysdate;

      DECLARE
         CURSOR c1 IS
            SELECT ROWNUM AS codigo
              FROM cifin_intermedio
             WHERE id_carga = v_idcarga;
      BEGIN
         FOR f1 IN c1 LOOP
            v_pasexec := 2;
            v_linea := f1.codigo;
            --Si todo correcto marco la linea correcta
            vnum_err := p_marcalinea(psproces, v_linea, 6, 4, 6, NULL, v_linea, NULL, NULL);

            IF v_numerr <> 0 THEN
               RAISE e_validaciones;
            END IF;

            v_pasexec := 3;
         END LOOP;
      EXCEPTION
         WHEN e_validaciones THEN
            ROLLBACK;

            IF vnum_err <> 0 THEN
               RAISE errorini;   --Error que para ejecucin
            END IF;

            vnum_err := p_marcalineaerror(psproces, v_linea, NULL, 1, verror,
                                          NVL(vterror, verror));
            --Actualizamos la cabecera del proceso indicando si ha habido o no algn error o warning en todo el proceso de carga
            vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces, v_tfichero,
                                                                       f_sysdate, f_sysdate, 4,
                                                                       p_cproces, 0, NULL);
            vnum_err := f_procesfin(v_sproces, 0);
      END;

      COMMIT;
    ** Cambios para IAXIS-2015 : End **/
      RETURN 0;
   EXCEPTION
      WHEN vsalir THEN
         NULL;
         RETURN 1;
      WHEN e_errdatos THEN
         ROLLBACK;
         pac_cargas_conf.p_genera_logs(vobj, vtraza, 'Error:' || vnum_err, vdeserror,
                                       psproces, 'Error:' || vnum_err || ' ' || vdeserror);
         vnum_err := f_procesfin(v_sproces, 1);
         COMMIT;
         RETURN 1;
      WHEN errorini THEN   --Error al insertar estados
         ROLLBACK;
         pac_cargas_conf.p_genera_logs(vobj, vtraza,
                                       'Error:' || 'ErrorIni' || ' en :' || vnum_err,
                                       'Error:' || 'Insertando estados registros', psproces,
                                       f_axis_literales(108953, v_idioma) || ':' || v_tfichero
                                       || ' : ' || 'errorini');
         vnum_err := f_procesfin(v_sproces, 1);
         COMMIT;
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         --KO si ha habido algun error en la cabecera
         pac_cargas_conf.p_genera_logs(vobj, vtraza, 'Error:' || vnum_err, SQLERRM, psproces,
                                       f_axis_literales(103187, v_idioma) || ':' || v_tfichero
                                       || ' : ' || SQLERRM);
         vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces, v_tfichero,
                                                                    f_sysdate, NULL, 1,
                                                                    p_cproces, 151541,
                                                                    SQLERRM);

         IF vnum_err <> 0 THEN
            pac_cargas_conf.p_genera_logs
                          (vobj, vtraza, vnum_err,
                           'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera2',
                           psproces,
                           f_axis_literales(180856, v_idioma) || ':' || v_tfichero || ' : '
                           || vnum_err);
            RAISE errorini;
         END IF;

         vnum_err := f_procesfin(v_sproces, 1);
         COMMIT;
         RETURN 1;
   END f_proceso_cifin;

   -- CONF-247 OSUAREZ
   -- Inicio IAXIS-2016 11/03/2019
   /*************************************************************************
   FUNCTION f_eje_carga_score_canales
   *************************************************************************/
   FUNCTION f_eje_carga_score_canales(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER)
      RETURN NUMBER IS
      vlin           NUMBER;
      vobj           VARCHAR2(200) := 'PAC_CARGAS_CONF.f_eje_carga_score_canales';
      vpar           VARCHAR2(2000)
         := 'p_nombre=' || p_nombre || 'p_path=' || p_path || ' p_cproces=' || p_cproces
            || 'psproces= ' || psproces;
      vnum_err       NUMBER := 0;
   BEGIN
      vnum_err := pac_cargas_conf.f_eje_carga_fichero_score_cana(p_nombre, p_path, p_cproces,
      psproces);

      --
      IF vnum_err <> 0 THEN
         RAISE e_param_error;
      END IF;

      vlin := 2;

      --
      UPDATE int_carga_ctrl
         SET cestado = vnum_err,
             ffin = f_sysdate
       WHERE sproces = psproces;

      --
      COMMIT;
      --
      RETURN 0;
   --
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobj, vlin, vpar, SQLCODE);
         RETURN 1;
      WHEN e_object_error THEN
         p_tab_error(f_sysdate, f_user, vobj, vlin, vpar, SQLCODE);
         RETURN 1;
      WHEN OTHERS THEN
         DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_backtrace);
         p_tab_error(f_sysdate, f_user, vobj, vlin, vpar, SQLCODE);
         RETURN 1;
   END f_eje_carga_score_canales;
   -- Fin IAXIS-2016 11/03/2019

   /*************************************************************************
   FUNCTION f_eje_carga_score_tipo_per
   *************************************************************************/
   FUNCTION f_eje_carga_score_tipo_per(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER)
      RETURN NUMBER IS
      vlin           NUMBER;
      vobj           VARCHAR2(200) := 'PAC_CARGAS_CONF.f_eje_carga_score_tipo_per';
      vpar           VARCHAR2(2000)
         := 'p_nombre=' || p_nombre || 'p_path=' || p_path || ' p_cproces=' || p_cproces
            || 'psproces= ' || psproces;
      vnum_err       NUMBER := 0;
   BEGIN
      vnum_err := pac_cargas_conf.f_eje_carga_fichero_score_tp(p_nombre, p_path, p_cproces,
                                                               psproces);

      --
      IF vnum_err <> 0 THEN
         RAISE e_param_error;
      END IF;

      vlin := 2;

      --
      UPDATE int_carga_ctrl
         SET cestado = vnum_err,
             ffin = f_sysdate
       WHERE sproces = psproces;

      --
      COMMIT;
      --
      RETURN 0;
   --
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobj, vlin, vpar, SQLCODE);
         RETURN 1;
      WHEN e_object_error THEN
         p_tab_error(f_sysdate, f_user, vobj, vlin, vpar, SQLCODE);
         RETURN 1;
      WHEN OTHERS THEN
         DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_backtrace);
         p_tab_error(f_sysdate, f_user, vobj, vlin, vpar, SQLCODE);
         RETURN 1;
   END f_eje_carga_score_tipo_per;

   /*************************************************************************
    FUNCTION f_eje_carga_fichero_score_tp
    *************************************************************************/
   FUNCTION f_eje_carga_fichero_score_tp(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces OUT NUMBER)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'pac_cargas_conf.f_eje_carga_fichero_score_tp';
      vnum_err       NUMBER := 0;
      v_line         VARCHAR2(32767);
      v_file         UTL_FILE.file_type;
      v_numlineaf    NUMBER := 0; --IAXIS-2016 11/03/2019
      -- Numero de linea del fichero
      -- Numero de linea del insert
      errorini       EXCEPTION;
      errorcarga     EXCEPTION;
      e_errdatos     EXCEPTION;
      -- Formato Ingls
      v_sep          VARCHAR2(1) := ';';
      v_currfield    VARCHAR2(64);
      v_sscore       NUMBER;
      v_cdescri      NUMBER;
      v_ctipide      NUMBER;
      v_ncalrie      NUMBER;
      vlin           NUMBER;
      vpar           VARCHAR2(2000)
         := 'p_nombre=' || p_nombre || 'p_path=' || p_path || ' p_cproces=' || p_cproces
            || 'psproces= ' || psproces;

      PROCEDURE p_controlar_error(p_traza NUMBER, p_estado NUMBER, v_msg VARCHAR2) IS
      BEGIN
         vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces, p_nombre,
                                                                    f_sysdate, NULL, p_estado,
                                                                    p_cproces, NULL, v_msg);

         IF vnum_err <> 0 THEN
            -- Si fallan esta funciones de gestin salimos del programa
            p_tab_error(f_sysdate, f_user, vobj, p_traza, vnum_err,
                        'Error llamando pac_gestion_procesos.f_set_carga_ctrl_cabecera'
                        || p_traza);
            RAISE errorini;
         END IF;
      END p_controlar_error;
   BEGIN
      SELECT sproces.NEXTVAL
        INTO psproces
        FROM DUAL;

      IF p_cproces IS NULL THEN
         vnum_err := 9901092;
         RAISE e_errdatos;
      END IF;

      p_controlar_error(2, 3, NULL);

      BEGIN
         -- Inicio: Lectura de fichero.
         v_file := UTL_FILE.fopen(p_path, p_nombre, 'R', 256);

         LOOP
            EXIT WHEN v_numlineaf = -1;

            BEGIN
               v_numlineaf := v_numlineaf + 1;
               UTL_FILE.get_line(v_file, v_line, 32767);
               DBMS_OUTPUT.put_line(v_line);

               IF (v_numlineaf > 0) THEN -- IAXIS-2016 11/03/2019
                  -- A partir de la Segona
          -- Incio IAXIS-2016 11/03/2019
                  v_line := REPLACE(REPLACE(v_line, chr(10), ''), chr(13), '');
                  -- Fin IAXIS-2016 11/03/2019
                  v_currfield := 'SSCORE';
                  v_sscore := pac_util.splitt(v_line, 1, v_sep);
                  v_currfield := 'CDESCRI';
                  v_cdescri := pac_util.splitt(v_line, 2, v_sep);
                  v_currfield := 'CTIPIDE';
                  v_ctipide := pac_util.splitt(v_line, 3, v_sep);
                  v_currfield := 'NCALRIE';
                  v_ncalrie := pac_util.splitt(v_line, 4, v_sep);

                  --
                  BEGIN
                     --Insert
                     INSERT INTO score_tipo_persona
                                 (sscore, cdescri, ctipide, ncalrie)
                          VALUES (v_sscore, v_cdescri, v_ctipide, v_ncalrie);
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                        UPDATE score_tipo_persona
                           SET sscore = v_sscore,
                               cdescri = v_cdescri,
                               ctipide = v_ctipide,
                               ncalrie = v_ncalrie
                         WHERE sscore = v_sscore;
                  END;

                  vnum_err :=
                     pac_gestion_procesos.f_set_carga_ctrl_linea(psproces => psproces,
                                                                 pnlinea => v_numlineaf,
                                                                 pctipo => 20,
                                                                 pidint => v_numlineaf,
                                                                 pidext => v_numlineaf,
                                                                 pcestado => 4,
                                                                 pcvalidado => NULL,
                                                                 psseguro => NULL,
                                                                 pidexterno => NULL,
                                                                 pncarga => NULL,
                                                                 pnsinies => NULL,
                                                                 pntramit => NULL,
                                                                 psperson => NULL,
                                                                 pnrecibo => NULL);
                  --
                  COMMIT;
               --
               END IF;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  -- No hay mas datos para leer.
                  v_numlineaf := -1;
               WHEN OTHERS THEN
                  --Inicio IAXIS-2016 11/03/2019
                  --p_controlar_error(2, 3, NULL);
                  vnum_err :=
                     pac_gestion_procesos.f_set_carga_ctrl_linea(psproces => psproces,
                                                                 pnlinea => v_numlineaf,
                                                                 pctipo => 20,
                                                                 pidint => v_numlineaf,
                                                                 pidext => v_numlineaf,
                                                                 pcestado => 4,
                                                                 pcvalidado => NULL,
                                                                 psseguro => NULL,
                                                                 pidexterno => NULL,
                                                                 pncarga => NULL,
                                                                 pnsinies => NULL,
                                                                 pntramit => NULL,
                                                                 psperson => NULL,
                                                                 pnrecibo => NULL);
                  --Fin IAXIS-2016 11/03/2019
            END;
         END LOOP;

         UTL_FILE.fclose(v_file);
         RETURN 0;
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_backtrace);
            ROLLBACK;
            UTL_FILE.fclose(v_file);
            p_controlar_error(5, 1,
                              f_axis_literales(9904284, pac_md_common.f_get_cxtidioma())
                              || ' at line ' || v_numlineaf);
            RETURN 9904284;
         -- Duplicated record
         WHEN VALUE_ERROR THEN
            DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_backtrace);
            ROLLBACK;
            UTL_FILE.fclose(v_file);
            p_controlar_error(6, 1,
                              f_axis_literales(9907933, pac_md_common.f_get_cxtidioma())
                              || ' at line ' || v_numlineaf || ', field: ' || v_currfield);
            RETURN 9907933;
         -- Data Error. Check character length OR NUMBER format
         WHEN OTHERS THEN
            DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_backtrace);
            ROLLBACK;
            UTL_FILE.fclose(v_file);
            p_controlar_error(7, 1, f_axis_literales(103187, pac_md_common.f_get_cxtidioma()));
            RETURN 103187;
      -- An error has occurred while reading the file
      END;
   EXCEPTION
      WHEN e_errdatos THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, vobj, vlin, vpar, SQLCODE || CHR(10) || vnum_err);
         DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_backtrace);
         RETURN vnum_err;
      WHEN errorini THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, vobj, vlin, vpar, SQLCODE || CHR(10) || vnum_err);
         DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_backtrace);
         RETURN 108953;
   -- A runtime error has occurred
   END f_eje_carga_fichero_score_tp;

   /*************************************************************************
    FUNCTION f_eje_carga_score_act_economic
    *************************************************************************/
   FUNCTION f_eje_carga_score_act_economic(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER)
      RETURN NUMBER IS
      vlin           NUMBER;
      vobj           VARCHAR2(200) := 'PAC_CARGAS_CONF.f_eje_carga_score_act_economic';
      vpar           VARCHAR2(2000)
         := 'p_nombre=' || p_nombre || 'p_path=' || p_path || ' p_cproces=' || p_cproces
            || 'psproces= ' || psproces;
      vnum_err       NUMBER := 0;
   BEGIN
      vnum_err := pac_cargas_conf.f_eje_carga_fichero_score_ac(p_nombre, p_path, p_cproces,
                                                               psproces);

      --
      IF vnum_err <> 0 THEN
         RAISE e_param_error;
      END IF;

      vlin := 2;

      --
      UPDATE int_carga_ctrl
         SET cestado = vnum_err,
             ffin = f_sysdate
       WHERE sproces = psproces;

      --
      COMMIT;
      --
      RETURN 0;
   --
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobj, vlin, vpar, SQLCODE);
         RETURN 1;
      WHEN e_object_error THEN
         p_tab_error(f_sysdate, f_user, vobj, vlin, vpar, SQLCODE);
         RETURN 1;
      WHEN OTHERS THEN
         DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_backtrace);
         p_tab_error(f_sysdate, f_user, vobj, vlin, vpar, SQLCODE);
         RETURN 1;
   END f_eje_carga_score_act_economic;

   /*************************************************************************
    FUNCTION f_eje_carga_fichero_score_ac
    *************************************************************************/
   FUNCTION f_eje_carga_fichero_score_ac(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces OUT NUMBER)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'pac_cargas_conf.f_eje_carga_fichero_score_ac';
      vnum_err       NUMBER := 0;
      v_line         VARCHAR2(32767);
      v_file         UTL_FILE.file_type;
      v_numlineaf    NUMBER := 0; --IAXIS-2016 11/03/2019
      -- Numero de linea del fichero
      -- Numero de linea del insert
      errorini       EXCEPTION;
      errorcarga     EXCEPTION;
      e_errdatos     EXCEPTION;
      -- Formato Ingls
      v_sep          VARCHAR2(1) := ';';
      v_currfield    VARCHAR2(64);
      v_cciiu        NUMBER;
      v_ncalrie      NUMBER;
      vlin           NUMBER;
      vpar           VARCHAR2(2000)
         := 'p_nombre=' || p_nombre || 'p_path=' || p_path || ' p_cproces=' || p_cproces
            || 'psproces= ' || psproces;

      PROCEDURE p_controlar_error(p_traza NUMBER, p_estado NUMBER, v_msg VARCHAR2) IS
      BEGIN
         vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces, p_nombre,
                                                                    f_sysdate, NULL, p_estado,
                                                                    p_cproces, NULL, v_msg);

         IF vnum_err <> 0 THEN
            -- Si fallan esta funciones de gestin salimos del programa
            p_tab_error(f_sysdate, f_user, vobj, p_traza, vnum_err,
                        'Error llamando pac_gestion_procesos.f_set_carga_ctrl_cabecera'
                        || p_traza);
            RAISE errorini;
         END IF;
      END p_controlar_error;
   BEGIN
      SELECT sproces.NEXTVAL
        INTO psproces
        FROM DUAL;

      IF p_cproces IS NULL THEN
         vnum_err := 9901092;
         RAISE e_errdatos;
      END IF;

      p_controlar_error(2, 3, NULL);

      BEGIN
         -- Inicio: Lectura de fichero.
         v_file := UTL_FILE.fopen(p_path, p_nombre, 'R', 256);

         LOOP
            EXIT WHEN v_numlineaf = -1;

            BEGIN
               v_numlineaf := v_numlineaf + 1;
               UTL_FILE.get_line(v_file, v_line, 32767);
               DBMS_OUTPUT.put_line(v_line);

               IF (v_numlineaf > 0) THEN --IAXIS-2016 11/03/2019
                  -- A partir de la Segona
                  -- Incio IAXIS-2016 11/03/2019
                  v_line := REPLACE(REPLACE(v_line, chr(10), ''), chr(13), '');
                  -- Fin IAXIS-2016 11/03/2019
                  v_currfield := 'CCIIU';
                  v_cciiu := pac_util.splitt(v_line, 1, v_sep);
                  v_currfield := 'NCALRIE';
                  v_ncalrie := pac_util.splitt(v_line, 2, v_sep);

                  --
                  BEGIN
                     --UPDATE
                     UPDATE per_ciiu
                        SET ncalrie = v_ncalrie
                      WHERE cciiu = v_cciiu;
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                        UPDATE per_ciiu
                           SET ncalrie = v_ncalrie
                         WHERE cciiu = v_cciiu;
                  END;

                  vnum_err :=
                     pac_gestion_procesos.f_set_carga_ctrl_linea(psproces => psproces,
                                                                 pnlinea => v_numlineaf,
                                                                 pctipo => 20,
                                                                 pidint => v_numlineaf,
                                                                 pidext => v_numlineaf,
                                                                 pcestado => 4,
                                                                 pcvalidado => NULL,
                                                                 psseguro => NULL,
                                                                 pidexterno => NULL,
                                                                 pncarga => NULL,
                                                                 pnsinies => NULL,
                                                                 pntramit => NULL,
                                                                 psperson => NULL,
                                                                 pnrecibo => NULL);
                  --
                  COMMIT;
               --
               END IF;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  -- No hay mas datos para leer.
                  v_numlineaf := -1;
               WHEN OTHERS THEN
                  --Inicio IAXIS-2016 11/03/2019
                  --p_controlar_error(2, 3, NULL);
                  vnum_err :=
                     pac_gestion_procesos.f_set_carga_ctrl_linea(psproces => psproces,
                                                                 pnlinea => v_numlineaf,
                                                                 pctipo => 20,
                                                                 pidint => v_numlineaf,
                                                                 pidext => v_numlineaf,
                                                                 pcestado => 4,
                                                                 pcvalidado => NULL,
                                                                 psseguro => NULL,
                                                                 pidexterno => NULL,
                                                                 pncarga => NULL,
                                                                 pnsinies => NULL,
                                                                 pntramit => NULL,
                                                                 psperson => NULL,
                                                                 pnrecibo => NULL);
                  --Fin IAXIS-2016 11/03/2019
            END;
         END LOOP;

         UTL_FILE.fclose(v_file);
         RETURN 0;
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_backtrace);
            ROLLBACK;
            UTL_FILE.fclose(v_file);
            p_controlar_error(5, 1,
                              f_axis_literales(9904284, pac_md_common.f_get_cxtidioma())
                              || ' at line ' || v_numlineaf);
            RETURN 9904284;
         -- Duplicated record
         WHEN VALUE_ERROR THEN
            DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_backtrace);
            ROLLBACK;
            UTL_FILE.fclose(v_file);
            p_controlar_error(6, 1,
                              f_axis_literales(9907933, pac_md_common.f_get_cxtidioma())
                              || ' at line ' || v_numlineaf || ', field: ' || v_currfield);
            RETURN 9907933;
         -- Data Error. Check character length OR NUMBER format
         WHEN OTHERS THEN
            DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_backtrace);
            ROLLBACK;
            UTL_FILE.fclose(v_file);
            p_controlar_error(7, 1, f_axis_literales(103187, pac_md_common.f_get_cxtidioma()));
            RETURN 103187;
      -- An error has occurred while reading the file
      END;
   EXCEPTION
      WHEN e_errdatos THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, vobj, vlin, vpar, SQLCODE || CHR(10) || vnum_err);
         DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_backtrace);
         RETURN vnum_err;
      WHEN errorini THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, vobj, vlin, vpar, SQLCODE || CHR(10) || vnum_err);
         DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_backtrace);
         RETURN 108953;
   -- A runtime error has occurred
   END f_eje_carga_fichero_score_ac;

   /*************************************************************************
   FUNCTION f_eje_carga_score_producto
   *************************************************************************/
   FUNCTION f_eje_carga_score_producto(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER)
      RETURN NUMBER IS
      vlin           NUMBER;
      vobj           VARCHAR2(200) := 'PAC_CARGAS_CONF.f_eje_carga_score_producto';
      vpar           VARCHAR2(2000)
         := 'p_nombre=' || p_nombre || 'p_path=' || p_path || ' p_cproces=' || p_cproces
            || 'psproces= ' || psproces;
      vnum_err       NUMBER := 0;
   BEGIN
      vnum_err := pac_cargas_conf.f_eje_carga_fichero_score_prod(p_nombre, p_path, p_cproces,
                                                                 psproces);

      --
      IF vnum_err <> 0 THEN
         RAISE e_param_error;
      END IF;

      vlin := 2;

      --
      UPDATE int_carga_ctrl
         SET cestado = vnum_err,
             ffin = f_sysdate
       WHERE sproces = psproces;

      --
      COMMIT;
      --
      RETURN 0;
   --
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobj, vlin, vpar, SQLCODE);
         RETURN 1;
      WHEN e_object_error THEN
         p_tab_error(f_sysdate, f_user, vobj, vlin, vpar, SQLCODE);
         RETURN 1;
      WHEN OTHERS THEN
         DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_backtrace);
         p_tab_error(f_sysdate, f_user, vobj, vlin, vpar, SQLCODE);
         RETURN 1;
   END f_eje_carga_score_producto;

   /*************************************************************************
    FUNCTION f_eje_carga_fichero_score_prod
    *************************************************************************/
   FUNCTION f_eje_carga_fichero_score_prod(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces OUT NUMBER)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'pac_cargas_conf.f_eje_carga_fichero_score_prod';
      vnum_err       NUMBER := 0;
      v_line         VARCHAR2(32767);
      v_file         UTL_FILE.file_type;
      v_numlineaf    NUMBER := 0; --IAXIS-2016 11/03/2019
      -- Numero de linea del fichero
      -- Numero de linea del insert
      errorini       EXCEPTION;
      errorcarga     EXCEPTION;
      e_errdatos     EXCEPTION;
      -- Formato Ingls
      v_sep          VARCHAR2(1) := ';';
      v_currfield    VARCHAR2(64);
      v_sproduc      NUMBER;
      v_ncalrie      NUMBER;
      vlin           NUMBER;
      vpar           VARCHAR2(2000)
         := 'p_nombre=' || p_nombre || 'p_path=' || p_path || ' p_cproces=' || p_cproces
            || 'psproces= ' || psproces;

      PROCEDURE p_controlar_error(p_traza NUMBER, p_estado NUMBER, v_msg VARCHAR2) IS
      BEGIN
         vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces, p_nombre,
                                                                    f_sysdate, NULL, p_estado,
                                                                    p_cproces, NULL, v_msg);

         IF vnum_err <> 0 THEN
            -- Si fallan esta funciones de gestin salimos del programa
            p_tab_error(f_sysdate, f_user, vobj, p_traza, vnum_err,
                        'Error llamando pac_gestion_procesos.f_set_carga_ctrl_cabecera'
                        || p_traza);
            RAISE errorini;
         END IF;
      END p_controlar_error;
   BEGIN
      SELECT sproces.NEXTVAL
        INTO psproces
        FROM DUAL;

      IF p_cproces IS NULL THEN
         vnum_err := 9901092;
         RAISE e_errdatos;
      END IF;

      p_controlar_error(2, 3, NULL);

      BEGIN
         -- Inicio: Lectura de fichero.
         v_file := UTL_FILE.fopen(p_path, p_nombre, 'R', 256);

         LOOP
            EXIT WHEN v_numlineaf = -1;

            BEGIN
               v_numlineaf := v_numlineaf + 1;
               UTL_FILE.get_line(v_file, v_line, 32767);
               DBMS_OUTPUT.put_line(v_line);

               IF (v_numlineaf > 0) THEN  --IAXIS-2016 11/03/2019
                  -- A partir de la Segona
                  -- Incio IAXIS-2016 11/03/2019
                  v_line := REPLACE(REPLACE(v_line, chr(10), ''), chr(13), '');
                  -- Fin IAXIS-2016 11/03/2019
                  v_currfield := 'SPRODUC';
                  v_sproduc := pac_util.splitt(v_line, 1, v_sep);
                  v_currfield := 'NCALRIE';
                  v_ncalrie := pac_util.splitt(v_line, 2, v_sep);

                  --
                  BEGIN
                     -- INSERT
                     INSERT INTO parproductos
                                 (sproduc, cparpro, cvalpar)
                          VALUES (v_sproduc, 'CALIFICACION_RIESDGO', v_ncalrie);
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                        UPDATE parproductos
                           SET cvalpar = v_ncalrie
                         WHERE sproduc = v_sproduc
                           AND cparpro = 'CALIFICACION_RIESDGO';
                  END;

                  vnum_err :=
                     pac_gestion_procesos.f_set_carga_ctrl_linea(psproces => psproces,
                                                                 pnlinea => v_numlineaf,
                                                                 pctipo => 20,
                                                                 pidint => v_numlineaf,
                                                                 pidext => v_numlineaf,
                                                                 pcestado => 4,
                                                                 pcvalidado => NULL,
                                                                 psseguro => NULL,
                                                                 pidexterno => NULL,
                                                                 pncarga => NULL,
                                                                 pnsinies => NULL,
                                                                 pntramit => NULL,
                                                                 psperson => NULL,
                                                                 pnrecibo => NULL);
                  --
                  COMMIT;
               --
               END IF;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  -- No hay mas datos para leer.
                  v_numlineaf := -1;
               WHEN OTHERS THEN
                  --Incio IAXIS-2016 11/03/2019
                  --p_controlar_error(2, 3, NULL);
                  vnum_err :=
                     pac_gestion_procesos.f_set_carga_ctrl_linea(psproces => psproces,
                                                                 pnlinea => v_numlineaf,
                                                                 pctipo => 20,
                                                                 pidint => v_numlineaf,
                                                                 pidext => v_numlineaf,
                                                                 pcestado => 4,
                                                                 pcvalidado => NULL,
                                                                 psseguro => NULL,
                                                                 pidexterno => NULL,
                                                                 pncarga => NULL,
                                                                 pnsinies => NULL,
                                                                 pntramit => NULL,
                                                                 psperson => NULL,
                                                                 pnrecibo => NULL);
                    p_error_linea_g(psproces, NULL, v_numlineaf,
                                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
                   --Fin IAXIS-2016 11/03/2019
            END;
         END LOOP;

         UTL_FILE.fclose(v_file);
         RETURN 0;
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_backtrace);
            ROLLBACK;
            UTL_FILE.fclose(v_file);
            p_controlar_error(5, 1,
                              f_axis_literales(9904284, pac_md_common.f_get_cxtidioma())
                              || ' at line ' || v_numlineaf);
            RETURN 9904284;
         -- Duplicated record
         WHEN VALUE_ERROR THEN
            DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_backtrace);
            ROLLBACK;
            UTL_FILE.fclose(v_file);
            p_controlar_error(6, 1,
                              f_axis_literales(9907933, pac_md_common.f_get_cxtidioma())
                              || ' at line ' || v_numlineaf || ', field: ' || v_currfield);
            RETURN 9907933;
         -- Data Error. Check character length OR NUMBER format
         WHEN OTHERS THEN
            DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_backtrace);
            ROLLBACK;
            UTL_FILE.fclose(v_file);
            p_controlar_error(7, 1, f_axis_literales(103187, pac_md_common.f_get_cxtidioma()));
            RETURN 103187;
      -- An error has occurred while reading the file
      END;
   EXCEPTION
      WHEN e_errdatos THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, vobj, vlin, vpar, SQLCODE || CHR(10) || vnum_err);
         DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_backtrace);
         RETURN vnum_err;
      WHEN errorini THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, vobj, vlin, vpar, SQLCODE || CHR(10) || vnum_err);
         DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_backtrace);
         RETURN 108953;
   -- A runtime error has occurred
   END f_eje_carga_fichero_score_prod;

   /*************************************************************************
    FUNCTION f_eje_carga_score_corrupcion
    *************************************************************************/
   FUNCTION f_eje_carga_score_corrupcion(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER)
      RETURN NUMBER IS
      vlin           NUMBER;
      vobj           VARCHAR2(200) := 'PAC_CARGAS_CONF.f_eje_carga_score_corrupcion';
      vpar           VARCHAR2(2000)
         := 'p_nombre=' || p_nombre || 'p_path=' || p_path || ' p_cproces=' || p_cproces
            || 'psproces= ' || psproces;
      vnum_err       NUMBER := 0;
   BEGIN
      vnum_err := pac_cargas_conf.f_eje_carga_fichero_score_corr(p_nombre, p_path, p_cproces,
                                                                 psproces);

      --
      IF vnum_err <> 0 THEN
         RAISE e_param_error;
      END IF;

      vlin := 2;

      --
      UPDATE int_carga_ctrl
         SET cestado = vnum_err,
             ffin = f_sysdate
       WHERE sproces = psproces;

      --
      COMMIT;
      --
      RETURN 0;
   --
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobj, vlin, vpar, SQLCODE);
         RETURN 1;
      WHEN e_object_error THEN
         p_tab_error(f_sysdate, f_user, vobj, vlin, vpar, SQLCODE);
         RETURN 1;
      WHEN OTHERS THEN
         DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_backtrace);
         p_tab_error(f_sysdate, f_user, vobj, vlin, vpar, SQLCODE);
         RETURN 1;
   END f_eje_carga_score_corrupcion;

   /*************************************************************************
    FUNCTION f_eje_carga_fichero_score_corr
    *************************************************************************/
   FUNCTION f_eje_carga_fichero_score_corr(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces OUT NUMBER)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'pac_cargas_conf.f_eje_carga_fichero_score_corr';
      vnum_err       NUMBER := 0;
      v_line         VARCHAR2(32767);
      v_file         UTL_FILE.file_type;
      v_numlineaf    NUMBER := 0; -- IAXIS-2016 11/03/2019
      -- Numero de linea del fichero
      -- Numero de linea del insert
      errorini       EXCEPTION;
      errorcarga     EXCEPTION;
      e_errdatos     EXCEPTION;
      -- Formato Ingls
      v_sep          VARCHAR2(1) := ';';
      v_currfield    VARCHAR2(64);
      v_cpais        NUMBER;
      v_score        NUMBER;
      v_score2       NUMBER;
      vlin           NUMBER;
      vpar           VARCHAR2(2000)
         := 'p_nombre=' || p_nombre || 'p_path=' || p_path || ' p_cproces=' || p_cproces
            || 'psproces= ' || psproces;

      PROCEDURE p_controlar_error(p_traza NUMBER, p_estado NUMBER, v_msg VARCHAR2) IS
      BEGIN
         vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces, p_nombre,
                                                                    f_sysdate, NULL, p_estado,
                                                                    p_cproces, NULL, v_msg);

         IF vnum_err <> 0 THEN
            -- Si fallan esta funciones de gestin salimos del programa
            p_tab_error(f_sysdate, f_user, vobj, p_traza, vnum_err,
                        'Error llamando pac_gestion_procesos.f_set_carga_ctrl_cabecera'
                        || p_traza);
            RAISE errorini;
         END IF;
      END p_controlar_error;
   BEGIN
      SELECT sproces.NEXTVAL
        INTO psproces
        FROM DUAL;

      IF p_cproces IS NULL THEN
         vnum_err := 9901092;
         RAISE e_errdatos;
      END IF;

      p_controlar_error(2, 3, NULL);

      BEGIN
         -- Inicio: Lectura de fichero.
         v_file := UTL_FILE.fopen(p_path, p_nombre, 'R', 256);

         LOOP
            EXIT WHEN v_numlineaf = -1;

            BEGIN
               v_numlineaf := v_numlineaf + 1;
               UTL_FILE.get_line(v_file, v_line, 32767);
               DBMS_OUTPUT.put_line(v_line);

               IF (v_numlineaf > 0) THEN -- IAXIS-2016 11/03/2019
                  -- A partir de la Segona
                  -- Inicio IAXIS-2016 11/03/2019
                  v_line := REPLACE(REPLACE(v_line, chr(10), ''), chr(13), '');
                  -- Fin IAXIS-2016 11/03/2019
                  v_currfield := 'CPAIS';
                  v_cpais := pac_util.splitt(v_line, 1, v_sep);
                  v_currfield := 'SCORE';
                  v_score := pac_util.splitt(v_line, 2, v_sep);
                  v_currfield := 'SCORE2';
                  v_score2 := pac_util.splitt(v_line, 3, v_sep); -- IAXIS-2016 11/03/2019

                  --
                  BEGIN
                     -- INSERT
                     INSERT INTO score_corrupcion
                                 (cpais, score, score2)
                          VALUES (v_cpais, v_score, v_score2);
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                        UPDATE score_corrupcion
                           SET score = v_score,
                               score2 = v_score2
                         WHERE cpais = v_cpais;
                  END;

                  vnum_err :=
                     pac_gestion_procesos.f_set_carga_ctrl_linea(psproces => psproces,
                                                                 pnlinea => v_numlineaf,
                                                                 pctipo => 20,
                                                                 pidint => v_numlineaf,
                                                                 pidext => v_numlineaf,
                                                                 pcestado => 4,
                                                                 pcvalidado => NULL,
                                                                 psseguro => NULL,
                                                                 pidexterno => NULL,
                                                                 pncarga => NULL,
                                                                 pnsinies => NULL,
                                                                 pntramit => NULL,
                                                                 psperson => NULL,
                                                                 pnrecibo => NULL);
                  --
                  COMMIT;
               --
               END IF;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  -- No hay mas datos para leer.
                  v_numlineaf := -1;
               WHEN OTHERS THEN
                  -- Inicio IAXIS-2016 11/03/2019
                  --p_controlar_error(2, 3, NULL);
                  vnum_err :=
                     pac_gestion_procesos.f_set_carga_ctrl_linea(psproces => psproces,
                                                                 pnlinea => v_numlineaf,
                                                                 pctipo => 20,
                                                                 pidint => v_numlineaf,
                                                                 pidext => v_numlineaf,
                                                                 pcestado => 4,
                                                                 pcvalidado => NULL,
                                                                 psseguro => NULL,
                                                                 pidexterno => NULL,
                                                                 pncarga => NULL,
                                                                 pnsinies => NULL,
                                                                 pntramit => NULL,
                                                                 psperson => NULL,
                                                                 pnrecibo => NULL);
                  -- Fin IAXIS-2016 11/03/2019
            END;
         END LOOP;

         UTL_FILE.fclose(v_file);
         RETURN 0;
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_backtrace);
            ROLLBACK;
            UTL_FILE.fclose(v_file);
            p_controlar_error(5, 1,
                              f_axis_literales(9904284, pac_md_common.f_get_cxtidioma())
                              || ' at line ' || v_numlineaf);
            RETURN 9904284;
         -- Duplicated record
         WHEN VALUE_ERROR THEN
            DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_backtrace);
            ROLLBACK;
            UTL_FILE.fclose(v_file);
            p_controlar_error(6, 1,
                              f_axis_literales(9907933, pac_md_common.f_get_cxtidioma())
                              || ' at line ' || v_numlineaf || ', field: ' || v_currfield);
            RETURN 9907933;
         -- Data Error. Check character length OR NUMBER format
         WHEN OTHERS THEN
            DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_backtrace);
            ROLLBACK;
            UTL_FILE.fclose(v_file);
            p_controlar_error(7, 1, f_axis_literales(103187, pac_md_common.f_get_cxtidioma()));
            RETURN 103187;
      -- An error has occurred while reading the file
      END;
   EXCEPTION
      WHEN e_errdatos THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, vobj, vlin, vpar, SQLCODE || CHR(10) || vnum_err);
         DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_backtrace);
         RETURN vnum_err;
      WHEN errorini THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, vobj, vlin, vpar, SQLCODE || CHR(10) || vnum_err);
         DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_backtrace);
         RETURN 108953;
   -- A runtime error has occurred
   END f_eje_carga_fichero_score_corr;

   /*************************************************************************
    FUNCTION f_eje_carga_score_paises
    *************************************************************************/
   FUNCTION f_eje_carga_score_paises(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER)
      RETURN NUMBER IS
      vlin           NUMBER;
      vobj           VARCHAR2(200) := 'PAC_CARGAS_CONF.f_eje_carga_score_paises';
      vpar           VARCHAR2(2000)
         := 'p_nombre=' || p_nombre || 'p_path=' || p_path || ' p_cproces=' || p_cproces
            || 'psproces= ' || psproces;
      vnum_err       NUMBER := 0;
   BEGIN
      vnum_err := pac_cargas_conf.f_eje_carga_fichero_score_pais(p_nombre, p_path, p_cproces,
                                                                 psproces);

      --
      IF vnum_err <> 0 THEN
         RAISE e_param_error;
      END IF;

      vlin := 2;

      --
      UPDATE int_carga_ctrl
         SET cestado = vnum_err,
             ffin = f_sysdate
       WHERE sproces = psproces;

      --
      COMMIT;
      --
      RETURN 0;
   --
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobj, vlin, vpar, SQLCODE);
         RETURN 1;
      WHEN e_object_error THEN
         p_tab_error(f_sysdate, f_user, vobj, vlin, vpar, SQLCODE);
         RETURN 1;
      WHEN OTHERS THEN
         DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_backtrace);
         p_tab_error(f_sysdate, f_user, vobj, vlin, vpar, SQLCODE);
         RETURN 1;
   END f_eje_carga_score_paises;

   /*************************************************************************
    FUNCTION f_eje_carga_fichero_score_pais
    *************************************************************************/
   FUNCTION f_eje_carga_fichero_score_pais(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces OUT NUMBER)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'pac_cargas_conf.f_eje_carga_fichero_score_pais';
      vnum_err       NUMBER := 0;
      v_line         VARCHAR2(32767);
      v_file         UTL_FILE.file_type;
      v_numlineaf    NUMBER := 0; -- IAXIS-2016 11/03/2019
      -- Numero de linea del fichero
      -- Numero de linea del insert
      errorini       EXCEPTION;
      errorcarga     EXCEPTION;
      e_errdatos     EXCEPTION;
      -- Formato Ingls
      v_sep          VARCHAR2(1) := ';';
      v_currfield    VARCHAR2(64);
      v_cpais        NUMBER;
      v_ncaltotal    NUMBER;
      v_ncalprom     NUMBER;
      v_ncalparcial  NUMBER;
      v_ncalpropia   NUMBER;
      v_ncaltrans    NUMBER;
      v_nsustanti    NUMBER;
      v_nparfis      NUMBER;
      v_nlrojagafi   NUMBER;
      v_nlnegragafi  NUMBER;
      v_nlgrisoscgafi NUMBER;
      v_nlgrisgafi   NUMBER;
      v_nlgafi       NUMBER;
      vlin           NUMBER;
      vpar           VARCHAR2(2000)
         := 'p_nombre=' || p_nombre || 'p_path=' || p_path || ' p_cproces=' || p_cproces
            || 'psproces= ' || psproces;

      PROCEDURE p_controlar_error(p_traza NUMBER, p_estado NUMBER, v_msg VARCHAR2) IS
      BEGIN
         vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces, p_nombre,
                                                                    f_sysdate, NULL, p_estado,
                                                                    p_cproces, NULL, v_msg);

         IF vnum_err <> 0 THEN
            -- Si fallan esta funciones de gestin salimos del programa
            p_tab_error(f_sysdate, f_user, vobj, p_traza, vnum_err,
                        'Error llamando pac_gestion_procesos.f_set_carga_ctrl_cabecera'
                        || p_traza);
            RAISE errorini;
         END IF;
      END p_controlar_error;
   BEGIN
      SELECT sproces.NEXTVAL
        INTO psproces
        FROM DUAL;

      IF p_cproces IS NULL THEN
         vnum_err := 9901092;
         RAISE e_errdatos;
      END IF;

      p_controlar_error(2, 3, NULL);

      BEGIN
         -- Inicio: Lectura de fichero.
         v_file := UTL_FILE.fopen(p_path, p_nombre, 'R', 256);

         LOOP
            EXIT WHEN v_numlineaf = -1;

            BEGIN
               v_numlineaf := v_numlineaf + 1;
               UTL_FILE.get_line(v_file, v_line, 32767);
               DBMS_OUTPUT.put_line(v_line);

               IF (v_numlineaf > 0) THEN -- IAXIS-2016 11/03/2019
                  -- A partir de la Segona
                  -- Inicio IAXIS-2016 11/03/2019
                  v_line := REPLACE(REPLACE(v_line, chr(10), ''), chr(13), '');
                  -- Fin IAXIS-2016 11/03/2019
                  v_currfield := 'CPAIS';
                  v_cpais := pac_util.splitt(v_line, 1, v_sep);
                  v_currfield := 'NCALTOTAL';
                  v_ncaltotal := pac_util.splitt(v_line, 2, v_sep);
                  v_currfield := 'NCALPROM';
                  v_ncalprom := pac_util.splitt(v_line, 3, v_sep);
                  v_currfield := 'NCALPARCIAL';
                  v_ncalparcial := pac_util.splitt(v_line, 4, v_sep);
                  v_currfield := 'NCALPROPIA';
                  v_ncalpropia := pac_util.splitt(v_line, 5, v_sep);
                  v_currfield := 'NCALTRANS';
                  v_ncaltrans := pac_util.splitt(v_line, 6, v_sep);
                  v_currfield := 'NSUSTANTI';
                  v_nsustanti := pac_util.splitt(v_line, 7, v_sep);
                  v_currfield := 'NPARFIS';
                  v_nparfis := pac_util.splitt(v_line, 8, v_sep);
                  v_currfield := 'NLROJAGAFI';
                  v_nlrojagafi := pac_util.splitt(v_line, 9, v_sep);
                  v_currfield := 'NLNEGRAGAFI';
                  v_nlnegragafi := pac_util.splitt(v_line, 10, v_sep);
                  v_currfield := 'NLGRISOSCGAFI';
                  v_nlgrisoscgafi := pac_util.splitt(v_line, 11, v_sep);
                  v_currfield := 'NLGRISGAFI';
                  v_nlgrisgafi := pac_util.splitt(v_line, 12, v_sep);
                  v_currfield := 'NLGAFI';
                  v_nlgafi := pac_util.splitt(v_line, 13, v_sep);

                  --
                  BEGIN
                     -- INSERT
                     INSERT INTO score_paises
                                 (cpais, ncaltotal, ncalprom, ncalparcial,
                                  ncalpropia, ncaltrans, nsustanti, nparfis,
                                  nlrojagafi, nlnegragafi, nlgrisoscgafi, nlgrisgafi,
                                  nlgafi)
                          VALUES (v_cpais, v_ncaltotal, v_ncalprom, v_ncalparcial,
                                  v_ncalpropia, v_ncaltrans, v_nsustanti, v_nparfis,
                                  v_nlrojagafi, v_nlnegragafi, v_nlgrisoscgafi, v_nlgrisgafi,
                                  v_nlgafi);
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                        UPDATE score_paises
                           SET ncaltotal = v_ncaltotal,
                               ncalprom = v_ncalprom,
                               ncalparcial = v_ncalparcial,
                               ncalpropia = v_ncalpropia,
                               ncaltrans = v_ncaltrans,
                               nsustanti = v_nsustanti,
                               nparfis = v_nparfis,
                               nlrojagafi = v_nlrojagafi,
                               nlnegragafi = v_nlnegragafi,
                               nlgrisoscgafi = v_nlnegragafi,
                               nlgrisgafi = v_nlgrisgafi,
                               nlgafi = v_nlgafi
                         WHERE cpais = v_cpais;
                  END;

                  vnum_err :=
                     pac_gestion_procesos.f_set_carga_ctrl_linea(psproces => psproces,
                                                                 pnlinea => v_numlineaf,
                                                                 pctipo => 20,
                                                                 pidint => v_numlineaf,
                                                                 pidext => v_numlineaf,
                                                                 pcestado => 4,
                                                                 pcvalidado => NULL,
                                                                 psseguro => NULL,
                                                                 pidexterno => NULL,
                                                                 pncarga => NULL,
                                                                 pnsinies => NULL,
                                                                 pntramit => NULL,
                                                                 psperson => NULL,
                                                                 pnrecibo => NULL);
                  --
                  COMMIT;
               --
               END IF;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  -- No hay mas datos para leer.
                  v_numlineaf := -1;
               WHEN OTHERS THEN
                  -- Inicio IAXIS-2016 11/03/2019
                  --p_controlar_error(2, 3, NULL);
                  vnum_err :=
                     pac_gestion_procesos.f_set_carga_ctrl_linea(psproces => psproces,
                                                                 pnlinea => v_numlineaf,
                                                                 pctipo => 20,
                                                                 pidint => v_numlineaf,
                                                                 pidext => v_numlineaf,
                                                                 pcestado => 4,
                                                                 pcvalidado => NULL,
                                                                 psseguro => NULL,
                                                                 pidexterno => NULL,
                                                                 pncarga => NULL,
                                                                 pnsinies => NULL,
                                                                 pntramit => NULL,
                                                                 psperson => NULL,
                                                                 pnrecibo => NULL);
                  -- Fin IAXIS-2016 11/03/2019
            END;
         END LOOP;

         UTL_FILE.fclose(v_file);
         RETURN 0;
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_backtrace);
            ROLLBACK;
            UTL_FILE.fclose(v_file);
            p_controlar_error(5, 1,
                              f_axis_literales(9904284, pac_md_common.f_get_cxtidioma())
                              || ' at line ' || v_numlineaf);
            RETURN 9904284;
         -- Duplicated record
         WHEN VALUE_ERROR THEN
            DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_backtrace);
            ROLLBACK;
            UTL_FILE.fclose(v_file);
            p_controlar_error(6, 1,
                              f_axis_literales(9907933, pac_md_common.f_get_cxtidioma())
                              || ' at line ' || v_numlineaf || ', field: ' || v_currfield);
            RETURN 9907933;
         -- Data Error. Check character length OR NUMBER format
         WHEN OTHERS THEN
            DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_backtrace);
            ROLLBACK;
            UTL_FILE.fclose(v_file);
            p_controlar_error(7, 1, f_axis_literales(103187, pac_md_common.f_get_cxtidioma()));
            RETURN 103187;
      -- An error has occurred while reading the file
      END;
   EXCEPTION
      WHEN e_errdatos THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, vobj, vlin, vpar, SQLCODE || CHR(10) || vnum_err);
         DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_backtrace);
         RETURN vnum_err;
      WHEN errorini THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, vobj, vlin, vpar, SQLCODE || CHR(10) || vnum_err);
         DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_backtrace);
         RETURN 108953;
   -- A runtime error has occurred
   END f_eje_carga_fichero_score_pais;

   /*************************************************************************
    FUNCTION f_eje_carga_score_poblaciones
    *************************************************************************/
   FUNCTION f_eje_carga_score_poblaciones(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER)
      RETURN NUMBER IS
      vlin           NUMBER;
      vobj           VARCHAR2(200) := 'PAC_CARGAS_CONF.f_eje_carga_score_poblaciones';
      vpar           VARCHAR2(2000)
         := 'p_nombre=' || p_nombre || 'p_path=' || p_path || ' p_cproces=' || p_cproces
            || 'psproces= ' || psproces;
      vnum_err       NUMBER := 0;
   BEGIN
      vnum_err := pac_cargas_conf.f_eje_carga_fichero_score_pobl(p_nombre, p_path, p_cproces,
                                                                 psproces);

      --
      IF vnum_err <> 0 THEN
         RAISE e_param_error;
      END IF;

      vlin := 2;

      --
      UPDATE int_carga_ctrl
         SET cestado = vnum_err,
             ffin = f_sysdate
       WHERE sproces = psproces;

      --
      COMMIT;
      --
      RETURN 0;
   --
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobj, vlin, vpar, SQLCODE);
         RETURN 1;
      WHEN e_object_error THEN
         p_tab_error(f_sysdate, f_user, vobj, vlin, vpar, SQLCODE);
         RETURN 1;
      WHEN OTHERS THEN
         DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_backtrace);
         p_tab_error(f_sysdate, f_user, vobj, vlin, vpar, SQLCODE);
         RETURN 1;
   END f_eje_carga_score_poblaciones;

   /*************************************************************************
    FUNCTION f_eje_carga_fichero_score_pobl
    *************************************************************************/
   FUNCTION f_eje_carga_fichero_score_pobl(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces OUT NUMBER)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'pac_cargas_conf.f_eje_carga_fichero_score_pobl';
      vnum_err       NUMBER := 0;
      v_line         VARCHAR2(32767);
      v_file         UTL_FILE.file_type;
      v_numlineaf    NUMBER := 0; -- IAXIS-2016 11/03/2019
      -- Numero de linea del fichero
      -- Numero de linea del insert
      errorini       EXCEPTION;
      errorcarga     EXCEPTION;
      e_errdatos     EXCEPTION;
      -- Formato Ingls
      v_sep          VARCHAR2(1) := ';';
      v_currfield    VARCHAR2(64);
      v_cprovin      NUMBER;
      v_cpoblac      NUMBER;
      v_npundep      NUMBER;
      vlin           NUMBER;
      vpar           VARCHAR2(2000)
         := 'p_nombre=' || p_nombre || 'p_path=' || p_path || ' p_cproces=' || p_cproces
            || 'psproces= ' || psproces;

      PROCEDURE p_controlar_error(p_traza NUMBER, p_estado NUMBER, v_msg VARCHAR2) IS
      BEGIN
         vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces, p_nombre,
                                                                    f_sysdate, NULL, p_estado,
                                                                    p_cproces, NULL, v_msg);

         IF vnum_err <> 0 THEN
            -- Si fallan esta funciones de gestin salimos del programa
            p_tab_error(f_sysdate, f_user, vobj, p_traza, vnum_err,
                        'Error llamando pac_gestion_procesos.f_set_carga_ctrl_cabecera'
                        || p_traza);
            RAISE errorini;
         END IF;
      END p_controlar_error;
   BEGIN
      SELECT sproces.NEXTVAL
        INTO psproces
        FROM DUAL;

      IF p_cproces IS NULL THEN
         vnum_err := 9901092;
         RAISE e_errdatos;
      END IF;

      p_controlar_error(2, 3, NULL);

      BEGIN
         -- Inicio: Lectura de fichero.
         v_file := UTL_FILE.fopen(p_path, p_nombre, 'R', 256);

         LOOP
            EXIT WHEN v_numlineaf = -1;

            BEGIN
               v_numlineaf := v_numlineaf + 1;
               UTL_FILE.get_line(v_file, v_line, 32767);
               DBMS_OUTPUT.put_line(v_line);

                IF (v_numlineaf > 0) THEN -- IAXIS-2016 11/03/2019
                  -- A partir de la Segona
                  -- Inicio IAXIS-2016 11/03/2019
                  v_line := REPLACE(REPLACE(v_line, chr(10), ''), chr(13), '');
                  -- Fin IAXIS-2016 11/03/2019
                  v_currfield := 'CPROVIN';
                  v_cprovin := pac_util.splitt(v_line, 1, v_sep);
                  --v_currfield := 'CPOBLAC';
                  --v_cpoblac := pac_util.splitt(v_line, 2, v_sep); --IAXIS-2016 11/03/2019
                  v_currfield := 'NPUNDEP';
                  v_npundep := pac_util.splitt(v_line, 2, v_sep); --IAXIS-2016 11/03/2019

                  --
                  BEGIN
                     -- INSERT
                     UPDATE poblaciones
                        SET npundep = v_npundep
                      WHERE cprovin = v_cprovin;
                        --AND cpoblac = v_cpoblac; -- IAXIS-2016 11/03/2019
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                        UPDATE poblaciones
                           SET npundep = v_npundep
                         WHERE cprovin = v_cprovin;
                           --AND cpoblac = v_cpoblac; -- IAXIS-2016 11/03/2019
                  END;

                  vnum_err :=
                     pac_gestion_procesos.f_set_carga_ctrl_linea(psproces => psproces,
                                                                 pnlinea => v_numlineaf,
                                                                 pctipo => 20,
                                                                 pidint => v_numlineaf,
                                                                 pidext => v_numlineaf,
                                                                 pcestado => 4,
                                                                 pcvalidado => NULL,
                                                                 psseguro => NULL,
                                                                 pidexterno => NULL,
                                                                 pncarga => NULL,
                                                                 pnsinies => NULL,
                                                                 pntramit => NULL,
                                                                 psperson => NULL,
                                                                 pnrecibo => NULL);
                  --
                  COMMIT;
               --
               END IF;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  -- No hay mas datos para leer.
                  v_numlineaf := -1;
               WHEN OTHERS THEN
                  -- Inicio IAXIS-2016 11/03/2019
                  --p_controlar_error(2, 3, NULL);
                  vnum_err :=
                     pac_gestion_procesos.f_set_carga_ctrl_linea(psproces => psproces,
                                                                 pnlinea => v_numlineaf,
                                                                 pctipo => 20,
                                                                 pidint => v_numlineaf,
                                                                 pidext => v_numlineaf,
                                                                 pcestado => 4,
                                                                 pcvalidado => NULL,
                                                                 psseguro => NULL,
                                                                 pidexterno => NULL,
                                                                 pncarga => NULL,
                                                                 pnsinies => NULL,
                                                                 pntramit => NULL,
                                                                 psperson => NULL,
                                                                 pnrecibo => NULL);
                  -- Fin IAXIS-2016 11/03/2019
            END;
         END LOOP;

         UTL_FILE.fclose(v_file);
         RETURN 0;
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_backtrace);
            ROLLBACK;
            UTL_FILE.fclose(v_file);
            p_controlar_error(5, 1,
                              f_axis_literales(9904284, pac_md_common.f_get_cxtidioma())
                              || ' at line ' || v_numlineaf);
            RETURN 9904284;
         -- Duplicated record
         WHEN VALUE_ERROR THEN
            DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_backtrace);
            ROLLBACK;
            UTL_FILE.fclose(v_file);
            p_controlar_error(6, 1,
                              f_axis_literales(9907933, pac_md_common.f_get_cxtidioma())
                              || ' at line ' || v_numlineaf || ', field: ' || v_currfield);
            RETURN 9907933;
         -- Data Error. Check character length OR NUMBER format
         WHEN OTHERS THEN
            DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_backtrace);
            ROLLBACK;
            UTL_FILE.fclose(v_file);
            p_controlar_error(7, 1, f_axis_literales(103187, pac_md_common.f_get_cxtidioma()));
            RETURN 103187;
      -- An error has occurred while reading the file
      END;
   EXCEPTION
      WHEN e_errdatos THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, vobj, vlin, vpar, SQLCODE || CHR(10) || vnum_err);
         DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_backtrace);
         RETURN vnum_err;
      WHEN errorini THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, vobj, vlin, vpar, SQLCODE || CHR(10) || vnum_err);
         DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_backtrace);
         RETURN 108953;
   -- A runtime error has occurred
   END f_eje_carga_fichero_score_pobl;
   -- Inicio IAXIS-2016 11/03/2019
   FUNCTION f_eje_carga_fichero_score_cana(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces OUT NUMBER)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'pac_cargas_conf.f_eje_carga_fichero_score_cana';
      vnum_err       NUMBER := 0;
      v_line         VARCHAR2(32767);
      v_file         UTL_FILE.file_type;
      v_numlineaf    NUMBER := 0;
      -- Numero de linea del fichero
      -- Numero de linea del insert
      errorini       EXCEPTION;
      errorcarga     EXCEPTION;
      e_errdatos     EXCEPTION;
      -- Formato Inglés
      v_sep          VARCHAR2(1) := ';';
      v_currfield    VARCHAR2(64);
      v_ccanal       NUMBER;
      v_ncalrie      NUMBER;
      vlin           NUMBER;
      vpar           VARCHAR2(2000)
         := 'p_nombre=' || p_nombre || 'p_path=' || p_path || ' p_cproces=' || p_cproces
            || 'psproces= ' || psproces;

      PROCEDURE p_controlar_error(p_traza NUMBER, p_estado NUMBER, v_msg VARCHAR2) IS
      BEGIN
         vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces, p_nombre,
                                                                    f_sysdate, NULL, p_estado,
                                                                    p_cproces, NULL, v_msg);

         IF vnum_err <> 0 THEN
            -- Si fallan esta funciones de gestión salimos del programa
            p_tab_error(f_sysdate, f_user, vobj, p_traza, vnum_err,
                        'Error llamando pac_gestion_procesos.f_set_carga_ctrl_cabecera'
                        || p_traza);
            RAISE errorini;
         END IF;
      END p_controlar_error;
   BEGIN
      SELECT sproces.NEXTVAL
        INTO psproces
        FROM DUAL;

      IF p_cproces IS NULL THEN
         vnum_err := 9901092;
         RAISE e_errdatos;
      END IF;

      p_controlar_error(2, 3, NULL);

      BEGIN
         -- Inicio: Lectura de fichero.
         v_file := UTL_FILE.fopen(p_path, p_nombre, 'R', 256);

         LOOP
            EXIT WHEN v_numlineaf = -1;

            BEGIN
               v_numlineaf := v_numlineaf + 1;
               UTL_FILE.get_line(v_file, v_line, 32767);
               DBMS_OUTPUT.put_line(v_line);

               IF (v_numlineaf > 0) THEN
                  -- A partir de la Segona
                  v_line := REPLACE(REPLACE(v_line, chr(10), ''), chr(13), '');
                  v_currfield := 'CCANAL';
                  v_ccanal := pac_util.splitt(v_line, 1, v_sep);
                  v_currfield := 'NCALRIE';
                  v_ncalrie := pac_util.splitt(v_line, 2, v_sep);

                  --
                  BEGIN
                     --Insert
                     INSERT INTO score_canales
                                 (ccanal, ncalrie)
                          VALUES (v_ccanal, v_ncalrie);
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                        UPDATE score_canales
                           SET ncalrie = v_ncalrie
                         WHERE ccanal = v_ccanal;
                  END;

                  vnum_err :=
                     pac_gestion_procesos.f_set_carga_ctrl_linea(psproces => psproces,
                                                                 pnlinea => v_numlineaf,
                                                                 pctipo => 20,
                                                                 pidint => v_numlineaf,
                                                                 pidext => v_numlineaf,
                                                                 pcestado => 4,
                                                                 pcvalidado => NULL,
                                                                 psseguro => NULL,
                                                                 pidexterno => NULL,
                                                                 pncarga => NULL,
                                                                 pnsinies => NULL,
                                                                 pntramit => NULL,
                                                                 psperson => NULL,
                                                                 pnrecibo => NULL);
                  --
                  COMMIT;
               --
               END IF;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  -- No hay mas datos para leer.
                  v_numlineaf := -1;
               WHEN OTHERS THEN
                  vnum_err :=
                     pac_gestion_procesos.f_set_carga_ctrl_linea(psproces => psproces,
                                                                 pnlinea => v_numlineaf,
                                                                 pctipo => 20,
                                                                 pidint => v_numlineaf,
                                                                 pidext => v_numlineaf,
                                                                 pcestado => 4,
                                                                 pcvalidado => NULL,
                                                                 psseguro => NULL,
                                                                 pidexterno => NULL,
                                                                 pncarga => NULL,
                                                                 pnsinies => NULL,
                                                                 pntramit => NULL,
                                                                 psperson => NULL,
                                                                 pnrecibo => NULL);
            END;
         END LOOP;

         UTL_FILE.fclose(v_file);
         RETURN 0;
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_backtrace);
            ROLLBACK;
            UTL_FILE.fclose(v_file);
            p_controlar_error(5, 1,
                              f_axis_literales(9904284, pac_md_common.f_get_cxtidioma())
                              || ' at line ' || v_numlineaf);
            RETURN 9904284;
         -- Duplicated record
         WHEN VALUE_ERROR THEN
            DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_backtrace);
            ROLLBACK;
            UTL_FILE.fclose(v_file);
            p_controlar_error(6, 1,
                              f_axis_literales(9907933, pac_md_common.f_get_cxtidioma())
                              || ' at line ' || v_numlineaf || ', field: ' || v_currfield);
            RETURN 9907933;
         -- Data Error. Check character length OR NUMBER format
         WHEN OTHERS THEN
            DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_backtrace);
            ROLLBACK;
            UTL_FILE.fclose(v_file);
            p_controlar_error(7, 1, f_axis_literales(103187, pac_md_common.f_get_cxtidioma()));
            RETURN 103187;
      -- An error has occurred while reading the file
      END;
   EXCEPTION
      WHEN e_errdatos THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, vobj, vlin, vpar, SQLCODE || CHR(10) || vnum_err);
         DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_backtrace);
         RETURN vnum_err;
      WHEN errorini THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, vobj, vlin, vpar, SQLCODE || CHR(10) || vnum_err);
         DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_backtrace);
         RETURN 108953;
   -- A runtime error has occurred
   END f_eje_carga_fichero_score_cana;
   -- Fin IAXIS-2016 11/03/2019
--BRSP
   FUNCTION f_conccar_ejecutarcarga(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER,
      pjob IN NUMBER DEFAULT 0,
      pcusuari IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'PAC_CARGAS_CON.f_conccar_ejecutarcarga';
      vtraza         NUMBER := 0;
      vnum_err       NUMBER := 0;
      vsalir         EXCEPTION;
      wlinerr        NUMBER := 0;
      pnnumideage    NUMBER := 0;
      codefichero    NUMBER := 0;
      CURSOR detalle_con(vsproces IN NUMBER) IS
         SELECT *
                    FROM GCA_CONCILIACIONDET
                   WHERE sidcon = vsproces order by nlinea;
   BEGIN
      vtraza := 0;

      IF pjob = 1 THEN
         vnum_err :=
            pac_contexto.f_inicializarctx(NVL(pcusuari,
                                              pac_parametros.f_parempresa_t(k_cempresa,
                                                                            'USER_BBDD')));
      END IF;

      SELECT NVL(cpara_error, 0), NVL(cbusca_host, 0), NVL(cformato_decimales, 0),
             NVL(ctablas, 'POL'), cdebug, nregmasivo
        INTO k_cpara_error, k_busca_host, k_cformato_decimales,
             k_tablas, k_cdebug, k_nregmasivo
        FROM cfg_files
       WHERE cempres = k_cempresa
         AND cproceso = p_cproces;

      IF psproces IS NULL
         OR(psproces IS NOT NULL
            AND pjob = 1) THEN
         vnum_err := f_ejecutar_carga_fichero(p_nombre, p_path, p_cproces, psproces);

         IF vnum_err <> 0 THEN
            RAISE vsalir;
         END IF;
      END IF;

      vnum_err := f_set_carga_ctrl_cabecera(psproces, p_nombre, f_sysdate, NULL, 3,   --pendiente
                                            p_cproces, NULL, NULL, 1);   -- bloqueo

      IF vnum_err <> 0 THEN   --Si fallan esta funciones de gestin salimos del programa
         p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                     'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera', 10);
         RAISE vsalir;   --Error que para ejecucin
      END IF;

-- inicializamos trazas de debug
      pac_contexto.p_contextoasignaparametro('DEBUG', NVL(k_cdebug, 99));
--
      vtraza := 1;

      --vnum_err := f_pol_ejecutar_carga_proceso(psproces);
      SELECT nnumideage, cfichero
        INTO pnnumideage, codefichero
        FROM gca_cargaconc cc
       WHERE UPPER(cc.tdescrip) LIKE UPPER(SUBSTR(p_nombre, 0, 3)) || '%'
         AND ROWNUM = 1;

      INSERT INTO gca_conciliacioncab
                  (sidcon, acon,
                   mcon, tdesc, csucursal, nnumideage,
                   cfichero, sproces, cestado, ncodacta, cusualt, falta, cusumod, fmodifi)
           VALUES (psproces, (SELECT TO_NUMBER(TO_CHAR(f_sysdate, 'yyy'))
                                FROM DUAL),
                   (SELECT TO_NUMBER(TO_CHAR(f_sysdate, 'mm'))
                      FROM DUAL), p_nombre, NULL, pnnumideage,
                   codefichero, psproces, 2, NULL, NULL, NULL, NULL, NULL);

      vnum_err := f_carga_generica(psproces, p_nombre);


      FOR cur_det IN detalle_con(psproces) LOOP
        vnum_err := pac_cargas_conf.f_validar_registro_repetido( cur_det.nrecibo_fic, cur_det.npoliza_fic, cur_det.itotalr_fic, cur_det.sidcon, cur_det.nlinea );
      END LOOP;

      UPDATE int_carga_ctrl
         SET cestado = vnum_err,
             ffin = f_sysdate,
             cbloqueo = 0   -- lo desbloqueo
       WHERE sproces = psproces;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN vsalir THEN
         RETURN vnum_err;
   END f_conccar_ejecutarcarga;

   FUNCTION f_ejecutar_carga_fichero(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER,
      pjob IN NUMBER DEFAULT 0,
      pcusuari IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'PAC_CARGAS_CONF.f_ejecutar_carga_fichero';
      linea          NUMBER := 0;
      pcarga         NUMBER;
      vtraza         NUMBER := 0;
      vdeserror      VARCHAR2(1000);
      errorini       EXCEPTION;
      --Indica error grabando estados.--Error que para ejecucin
      vnum_err       NUMBER := 0;
      vsalir         EXCEPTION;
      verrorfin      BOOLEAN := FALSE;
      vavisfin       BOOLEAN := FALSE;
      vtiperr        NUMBER;
      vcoderror      NUMBER;
   BEGIN
      vtraza := 0;

      IF psproces IS NULL THEN
         SELECT sproces.NEXTVAL
           INTO psproces
           FROM DUAL;
      END IF;

      vtraza := 1;

      IF p_cproces IS NULL THEN
         vnum_err := 9901092;
         vdeserror := 'cfg_files falta proceso: ' || vobj;
         RAISE e_errdatos;
      END IF;

      vtraza := 11;
      --   vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces, p_nombre, f_sysdate,
      --                                                              NULL, 3, p_cproces, NULL,
      --                                                              NULL);
      vtraza := 12;
      --     IF vnum_err <> 0 THEN   --Si fallan esta funciones de gestin salimos del programa
      --        p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
      --                    'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera');
      --        RAISE errorini;   --Error que para ejecucin
      --     END IF;
      vtraza := 2;
      --Creamos la tabla int_carga_ext apartir del nombre de fichero enviado dinamicamente.
      vnum_err := f_modi_tabla_ext(p_nombre, p_path);

      IF vnum_err <> 0 THEN
         p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                     'Error creando la tabla externa', 10);
         RAISE errorini;   --Error que para ejecucin
      END IF;

      vnum_err := f_trasp_tabla(vdeserror, psproces);
      vtraza := 3;

      IF vnum_err <> 0 THEN
         --Si hay un error leyendo el fichero salimos del programa del todo y lo indicamos.
         vtraza := 5;
         vnum_err := f_set_carga_ctrl_cabecera(psproces, p_nombre, f_sysdate, NULL, 1,
                                               p_cproces, NULL, vdeserror, 0);
         vtraza := 51;

         IF vnum_err <> 0 THEN   --Si fallan esta funciones de gestin salimos del programa
            p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                        'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera2',
                        10);
            RAISE errorini;   --Error que para ejecucin
         END IF;

         vtraza := 52;
         RAISE vsalir;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN vsalir THEN
         RETURN 103187;   -- error leyendo el fichero
      WHEN e_errdatos THEN
         ROLLBACK;
         p_genera_logs(vobj, vtraza, 'Error:' || vnum_err, vdeserror);
         RETURN vnum_err;
      WHEN errorini THEN   --Error al insertar estados
         ROLLBACK;
         p_genera_logs(vobj, vtraza, 'Error:' || 'ErrorIni' || ' en :' || 1,
                       'Error:' || 'Insertando estados registros');
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         --KO si ha habido algun error en la cabecera
         --coderr := SQLCODE;
         p_genera_logs(vobj, vtraza, 'Error:' || 'ErrorIni en 1',
                       'Error: Insertando estados registros');
         vnum_err := f_set_carga_ctrl_cabecera(psproces, p_nombre, f_sysdate, NULL, 1,
                                               p_cproces, 151541, SQLERRM, 0);
         vtraza := 51;

         IF vnum_err <> 0 THEN
            p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                        'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera2',
                        10);
         --RAISE errorini;
         END IF;

         RETURN 1;
   END f_ejecutar_carga_fichero;

   FUNCTION f_modi_tabla_ext(p_nombre VARCHAR2, p_path IN VARCHAR2)
      RETURN NUMBER IS
      v_iteraciones  NUMBER(2);
   BEGIN
      v_iteraciones := 1;

      --Cargamos el fichero
      LOOP
         BEGIN
            LOCK TABLE int_carga_genericocartera_ext IN EXCLUSIVE MODE;

            EXECUTE IMMEDIATE 'ALTER TABLE int_carga_genericocartera_ext LOCATION (' || p_path
                              || ':''' || p_nombre || ''')';

            EXIT;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'pac_cargas_vida_lcol.f_crea_tabla_ext',
                           v_iteraciones, 'Error modificando tabla. Reintento.', SQLERRM, 10);

               IF k_iteraciones <= v_iteraciones THEN
                  RAISE;   -- propago excepcion
               END IF;

               sleep(k_segundos);
               v_iteraciones := v_iteraciones + 1;
         END;
      END LOOP;

      LOCK TABLE int_carga_genericocartera_ext IN EXCLUSIVE MODE;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_cargas_generico.f_crea_tabla_ext', 1,
                     'Error creando la tabla.', SQLERRM, 10);
         RETURN 103865;
   END f_modi_tabla_ext;

   FUNCTION f_trasp_tabla(pdeserror OUT VARCHAR2, psproces IN NUMBER)
      RETURN NUMBER IS
      v_pasexec      NUMBER := 1;
      vobj           VARCHAR2(200) := 'pac_cargas_conf.f_trasp_tabla';
      v_numlin       int_carga_genericocartera.nlinea%TYPE;
   BEGIN
      v_pasexec := 0;
      pdeserror := NULL;

      SELECT NVL(MAX(nlinea), 0)
        INTO v_numlin
        FROM int_carga_generico
       WHERE proceso = psproces;

      INSERT      /*+ APPEND */INTO int_carga_genericocartera
                  (proceso, nlinea, ncarga, tipo_oper, campo01, campo02, campo03, campo04,
                   campo05, campo06, campo07, campo08, campo09, campo10, campo11, campo12,
                   campo13, campo14, campo15, campo16, campo17, campo18, campo19, campo20,
                   campo21, campo22, campo23, campo24, campo25, campo26, campo27, campo28,
                   campo29, campo30, campo31, campo32, campo33, campo34, campo35, campo36,
                   campo37, campo38, campo39, campo40, campo41, campo42, campo43, campo44,
                   campo45, campo46, campo47, campo48, campo49, campo50)
         (SELECT psproces proceso, ROWNUM + v_numlin nlinea, NULL ncarga, NULL tipo_oper,
                 campo01, campo02, campo03, campo04, campo05, campo06, campo07, campo08,
                 campo09, campo10, campo11, campo12, campo13, campo14, campo15, campo16,
                 campo17, campo18, campo19, campo20, campo21, campo22, campo23, campo24,
                 campo25, campo26, campo27, campo28, campo29, campo30, campo31, campo32,
                 campo33, campo34, campo35, campo36, campo37, campo38, campo39, campo40,
                 campo41, campo42, campo43, campo44, campo45, campo46, campo47, campo48,
                 campo49, campo50
            FROM int_carga_genericocartera_ext);

      v_pasexec := 1;
      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         pdeserror := f_axis_literales(103187, k_cidioma) || SQLERRM;
         p_tab_error(f_sysdate, f_user, vobj, v_pasexec, SQLCODE, SQLERRM);
         RETURN 1;
   END f_trasp_tabla;

   FUNCTION f_set_carga_ctrl_cabecera(
      psproces IN NUMBER,
      ptfichero IN VARCHAR2,
      pfini IN DATE,
      pffin IN DATE,
      pcestado IN NUMBER,
      pcproceso IN NUMBER,
      pcerror IN NUMBER,
      pterror IN VARCHAR2,
      pcbloqueo IN NUMBER DEFAULT 0)
      RETURN NUMBER IS
      -- Bug 0016324. FAL. 18/10/2010
      PRAGMA AUTONOMOUS_TRANSACTION;
      -- Fi Bug 0016324
      vobjectname    VARCHAR2(500) := 'pac_gestion_procesos.f_set_carga_ctrl_cabecera';
      vparam         VARCHAR2(4000)
         := 'parmetros - psproces : ' || psproces || ',tfichero : ' || ptfichero
            || ',fini : ' || pfini || ',ffin : ' || pffin || ',cestado : ' || pcestado
            || ',cproceso : ' || pcproceso || ',pcerror : ' || pcerror || ',pcbloqueo : '
            || pcbloqueo;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vcbloqueo      int_carga_ctrl.cbloqueo%TYPE;
   BEGIN
      IF ptfichero IS NULL
         --OR pfini IS NULL         -- Bug 15490/88884 - FAL - 01/07/2011. Evitar tener que informar finicio proceso una vez hecho el insert.
         OR pcestado IS NULL THEN
         RETURN 1000005;
      END IF;

      IF psproces IS NULL THEN
         --Si es alta de momento nunca llegar a nulo,
         --pero en el caso de que llegara a nulo aqu se tendra que buscar
         --un sproces nuevo.
         NULL;
      END IF;

      -- bloqueo de procesos
      IF pcbloqueo = 1 THEN   -- compruebo si el proceso ya esta bloquedo
         BEGIN
            SELECT cbloqueo
              INTO vcbloqueo
              FROM int_carga_ctrl
             WHERE sproces = psproces;

            IF vcbloqueo = 1 THEN   -- si el proceso ya esta bloqueado..
               RETURN 9905979;
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               NULL;
         END;
      END IF;

      -- Bug 15490/88884 - FAL - 01/07/2011. Evitar tener que informar finicio proceso una vez hecho el insert.
      IF pfini IS NULL THEN
         UPDATE int_carga_ctrl
            SET tfichero = ptfichero,
                fini = NVL(pfini, fini),
                ffin = pffin,
                cestado = pcestado,
                cproceso = pcproceso,
                cerror = pcerror,
                terror = pterror,
                cbloqueo = NVL(pcbloqueo, 0)   -- terminado
          WHERE sproces = psproces;

         COMMIT;
         RETURN 0;
      END IF;

      -- Fi Bug 15490/88884
      BEGIN
         INSERT INTO int_carga_ctrl
                     (sproces, tfichero, fini, ffin, cestado, cerror, terror,
                      cproceso, cbloqueo)
              VALUES (psproces, ptfichero, pfini, pffin, pcestado, pcerror, pterror,
                      pcproceso, NVL(pcbloqueo, 0));
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE int_carga_ctrl
               SET tfichero = ptfichero,
                   fini = NVL(pfini, fini),
                   ffin = pffin,
                   cestado = pcestado,
                   cproceso = pcproceso,
                   cerror = pcerror,
                   terror = pterror,
                   cbloqueo = NVL(pcbloqueo, 0)
             WHERE sproces = psproces;
      END;

      -- Bug 0016324. FAL. 18/10/2010
      COMMIT;
      -- Fi Bug 0016324
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, 1, 'f_set_carga_ctrl_cabecera', SQLERRM);
         RETURN 1000006;
   END f_set_carga_ctrl_cabecera;

   FUNCTION f_carga_generica(psproces IN NUMBER, p_nombre IN VARCHAR2)
      RETURN NUMBER IS
      v_pasexec      NUMBER := 1;
      vobj           VARCHAR2(200) := 'pac_cargas_conf.f_carga_generica';
      mysql_in       VARCHAR2(10000) := '';
      mysql_se       VARCHAR2(10000) := '';
      count_r        NUMBER := 0;
      v_numlin       int_carga_generico.nlinea%TYPE;

      CURSOR cur_map IS
         SELECT tcolori, tcoldest
           FROM gca_cargaconc_mapeo gc, gca_cargaconc cc
          WHERE cc.cfichero = gc.cfichero
            AND UPPER(cc.tdescrip) LIKE UPPER(SUBSTR(p_nombre, 0, 3)) || '%';
   BEGIN
      v_pasexec := 0;

      SELECT COUNT(*)
        INTO count_r
        FROM gca_cargaconc_mapeo gc, gca_cargaconc cc
       WHERE cc.cfichero = gc.cfichero
         AND UPPER(cc.tdescrip) LIKE UPPER(SUBSTR(p_nombre, 0, 3)) || '%';

      mysql_in := 'INSERT INTO GCA_CONCILIACIONDET( sidcon,nlinea,';
      mysql_se := ')(SELECT ' || psproces || ', nlinea-1  ,';

      FOR i IN cur_map LOOP
         mysql_in := mysql_in || i.tcoldest;
         mysql_se := mysql_se || i.tcolori;

         IF count_r > 1 THEN
            mysql_in := mysql_in || ',';
            mysql_se := mysql_se || ',';
         END IF;

         count_r := count_r - 1;
      END LOOP;

      mysql_se :=
         mysql_se
         || ' FROM (SELECT ROWNUM R, ICG.* FROM INT_CARGA_GENERICOCARTERA ICG WHERE ICG.PROCESO = ' ||psproces||') WHERE R >= 1)';
      mysql_in := mysql_in || mysql_se;

      p_control_error('' || f_sysdate, 'SQL-> ', mysql_in);
      EXECUTE IMMEDIATE mysql_in;
      v_pasexec := 1;
      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, vobj, v_pasexec, SQLCODE, SQLERRM);
         RETURN 1;
   END f_carga_generica;

   FUNCTION f_get_conciliacion(
      ptiporeturn IN VARCHAR2,
      pnpoliza IN VARCHAR2,
      precibo IN VARCHAR2,
      psaldo IN VARCHAR2)
      RETURN VARCHAR2 IS
      PRAGMA autonomous_transaction;
      v_cursor       sys_refcursor;
      vpasexec       NUMBER;
      vobject        VARCHAR2(200) := 'PAC_CARGAS_CONF.f_get_conciliacion';
      vparam         VARCHAR2(500) := 'ptiporeturn='||ptiporeturn||' - pnpoliza='||pnpoliza||' -precibo='||precibo||' -psaldo='||psaldo;
      vrecibo        NUMBER := NULL;
      vnrecibo       NUMBER;
      vnrecibo2      NUMBER;
      vsaldo         NUMBER := NULL;
      vcruce         NUMBER := 6;
      vcestado       NUMBER := 2;      
      vcoincide_pol  NUMBER(1) := 1;
      saldo          VARCHAR2(100);
      vpoliza        VARCHAR2(100);
      vnpoliza       VARCHAR2(100);
      vexisterec     NUMBER(1):=0;
   BEGIN
   --INI SGM IAXIS 4060 CONCILIACIONES DE CARTERA 
        --saldo := TO_CHAR(replace(replace(replace(TRIM(replace(TRIM(replace(TRIM(psaldo),'$','')),'.','')),',','.'),chr(10),''),chr(13),''));

            saldo := REPLACE(TO_CHAR(replace(replace(replace(TRIM(replace(TRIM(replace(TRIM(psaldo),'$','')),'.','')),',','.'),chr(10),''),chr(13),'')),'.',',');
    

         BEGIN        
            vnpoliza :=  TO_CHAR(replace(replace(TRIM(pnpoliza),chr(10),''),chr(13),''));
         EXCEPTION
            WHEN OTHERS THEN
            vnpoliza := '1';
         END;  

         BEGIN          
            vnrecibo := TO_CHAR(replace(replace(TRIM(precibo),chr(10),''),chr(13),''));
         EXCEPTION
            WHEN OTHERS THEN
            vnrecibo := 0;
         END;        
              
         BEGIN
           vnpoliza := TO_NUMBER(vnpoliza);
         EXCEPTION WHEN OTHERS THEN
           vnpoliza:=1;
         END;
         
         IF vnpoliza = 1 THEN
            BEGIN
              SELECT r.nrecibo, (v.itotalr - (nvl((select sum(dm.iimporte_moncon) from detmovrecibo dm where dm.nrecibo = vnrecibo),0))) AS importe
                INTO vrecibo, vsaldo
                FROM recibos r, movrecibo m, vdetrecibos_monpol v
               WHERE 1=1
                 AND r.nrecibo = vnrecibo 
                 AND r.nrecibo = m.nrecibo
                 AND r.nrecibo = v.nrecibo                 
                 AND m.smovrec = (SELECT MAX(m2.smovrec)
                                    FROM movrecibo m2
                                   WHERE m2.nrecibo = v.nrecibo);
                                   
                  IF vsaldo = saldo THEN
                      vcruce := 4;
                      vcestado := 2;
                  ELSE
                      vcruce := 5;
                      vcestado := 2;                  
                  END IF;
                                   
             EXCEPTION
                WHEN OTHERS THEN
                  vcruce := 6;
                  vcestado := 2; 
             END;
                                   
         ELSE
                          
             BEGIN        
    
                  SELECT s.npoliza, r.nrecibo, (v.itotalr - (nvl((select sum(dm.iimporte_moncon) from detmovrecibo dm where dm.nrecibo = vnrecibo),0))) AS importe
                    INTO vpoliza, vrecibo, vsaldo
                    FROM recibos r, movrecibo m, vdetrecibos_monpol v, seguros s
                   WHERE 1=1
                     AND s.npoliza = TO_CHAR(vnpoliza)
                     AND r.nrecibo = m.nrecibo
                     AND r.nrecibo = v.nrecibo 
                     AND r.sseguro = s.sseguro              
                     AND m.smovrec = (SELECT MAX(m2.smovrec)
                                        FROM movrecibo m2
                                       WHERE m2.nrecibo = vnrecibo)
                     AND v.itotalr <> 0;
    --los 3 parametros coinciden con datos de confianza                 
                   IF saldo = vsaldo THEN
                        vcestado := 0;               
                        vcruce := 1;
                   ELSE
                        vcestado := 2;               
                        vcruce := 3;               
                   END IF;
                   
        --INI SGM IAXIS 4512 HISTORICO PÓLIZAS PENDIENTES DE FACTURAR - ACTA CONCILIACIÓN
        --marca los registros que no conciliaron los meses anteriores y que llegaron correctamente este mes
                   UPDATE GCA_CONCILIACIONDET set tobserva = 'CONCILIADO EN '|| (TO_CHAR(F_SYSDATE,'MONTH')) || tobserva
                    WHERE  cestado <> 0
                      AND ((instr(tobserva,'CONCILIADO EN ',1,1) = 0) or (tobserva is NULL))
                      AND npoliza = vnpoliza
                      AND nrecibo = vnrecibo
                      AND itotalr = saldo;
                      commit;
        --FIN SGM IAXIS 4512 HISTORICO PÓLIZAS PENDIENTES DE FACTURAR - ACTA CONCILIACIÓN    
             EXCEPTION
                WHEN OTHERS THEN
                  vcoincide_pol := 0;
             END;
         
         END IF;

         --IF precibo IS NOT NULL  AND vcoincide_pol = 0 THEN 
         IF vcoincide_pol = 0 THEN 
         
        --Si no encontro info por poliza/recibo, busca que la poliza solo tenga un recibo de lo contrario arroja el error.
             BEGIN
                SELECT re.nrecibo
                  INTO vnrecibo2
                  FROM seguros se,recibos re
                 WHERE se.sseguro = re.sseguro
                   AND se.npoliza = vnpoliza
                   AND EXISTS (SELECT 1
                               FROM movrecibo m
                              WHERE m.nrecibo = re.nrecibo
                                AND m.smovrec = (SELECT MAX(m1.smovrec) FROM movrecibo m1 WHERE m1.nrecibo = m.nrecibo)
                                AND m.cestrec = 0
                                AND m.fmovfin IS NULL);
             EXCEPTION
                WHEN NO_DATA_FOUND THEN
                
                    BEGIN
                        SELECT re.nrecibo
                          INTO vnrecibo2
                          FROM seguros se,recibos re
                         WHERE se.sseguro = re.sseguro
                           AND se.npoliza = vnpoliza;
                    EXCEPTION
                       WHEN TOO_MANY_ROWS THEN
                        vcestado := 2;               
                        vcruce := 8; 
                       WHEN NO_DATA_FOUND THEN
                        vcestado := 2;               
                        vcruce := 6;
                    END;
                WHEN TOO_MANY_ROWS THEN
                    vcestado := 2;               
                    vcruce := 7;   
             END; 
             
             BEGIN
              -- vnrecibo := TO_CHAR(replace(replace(TRIM(precibo),chr(10),''),chr(13),''));
                      SELECT s.npoliza, r.nrecibo, (v.itotalr - (nvl((select sum(dm.iimporte_moncon) from detmovrecibo dm where dm.nrecibo = vnrecibo2),0))) AS importe
                        INTO vpoliza, vrecibo, vsaldo
                        FROM recibos r, movrecibo m, vdetrecibos_monpol v, seguros s
                       WHERE 1=1
                         AND s.npoliza = vnpoliza
                         AND s.sseguro = r.sseguro
                         AND r.nrecibo = m.nrecibo
                         AND r.nrecibo = v.nrecibo                 
                         AND m.smovrec = (SELECT MAX(m2.smovrec)
                                            FROM movrecibo m2
                                           WHERE m2.nrecibo = v.nrecibo);
                         --AND v.itotalr = saldo;

               IF saldo = vsaldo THEN
                    vcestado := 2;               
                    vcruce := 2;
               ELSE
                    vcestado := 2;               
                    vcruce := 8;               
               END IF;                

               EXCEPTION
                  WHEN OTHERS THEN
                  --no hay coincidencias
                    vcoincide_pol := 2;
               END;
         END IF;

         IF vcoincide_pol = 2 THEN 
                  BEGIN
                      SELECT   s.npoliza, r.nrecibo, (v.itotalr - (nvl((select sum(dm.iimporte_moncon) from detmovrecibo dm where dm.nrecibo = vnrecibo),0))) AS importe
                        INTO vpoliza, vrecibo, vsaldo
                        FROM recibos r, movrecibo m, vdetrecibos v, seguros s
                       WHERE 1=1
                         AND s.sseguro = r.sseguro
                         AND r.nrecibo = m.nrecibo
                         AND r.nrecibo = v.nrecibo                 
                         AND m.smovrec = (SELECT MAX(m2.smovrec)
                                            FROM movrecibo m2
                                           WHERE m2.nrecibo = vnrecibo)
                         AND v.itotalr = saldo;

               IF saldo = vsaldo THEN
                    vcestado := 2;               
                    vcruce := 4;
               ELSE
                    vcestado := 2;               
                    vcruce := 5;               
               END IF;                  

               EXCEPTION
                  WHEN OTHERS THEN
                  --no hay coincidencias
                    vcoincide_pol := 3;
               END;
         END IF;

         IF vcoincide_pol = 3 THEN 
               BEGIN
                  SELECT COUNT(*)
                    INTO vexisterec
                    FROM recibos r
                   WHERE r.nrecibo = vnrecibo;


                    IF vexisterec > 0 THEN
                        vcestado := 2;               
                        vcruce := 5;                     
                    END IF;

               EXCEPTION
                  WHEN OTHERS THEN
                  --no hay coincidencias
                    vcoincide_pol := 3;
               END;
         END IF;
--En este punto si no ha encontrado valores iguales en confianza, mantuvo vcestado 2 y vccruce 6
/*
            IF vseguro IS NULL
               AND vrecibo IS NULL
               AND vsaldo IS NULL THEN
               vcruce := 6;
            END IF;
*/
         IF ptiporeturn = 'CESTADO' THEN
               RETURN vcestado;
         END IF;

         IF ptiporeturn = 'CESTADOI' THEN
               RETURN vcestado;
         END IF;
--   FIN SGM IAXIS 4060 CONCILIACIONES DE CARTERA 
         IF ptiporeturn = 'CCRUCE' THEN
            RETURN vcruce;
         END IF;

         IF ptiporeturn = 'CCRUCEDET' THEN
            RETURN NULL;
         END IF;


      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, 0, SQLCODE, SQLERRM);

         IF ptiporeturn = 'CESTADO' THEN
               RETURN 2;
         END IF;
--   SGM IAXIS 4060 CONCILIACIONES DE CARTERA
         IF ptiporeturn = 'CESTADOI' THEN
               RETURN 2; 
         END IF;

         IF ptiporeturn = 'CCRUCE' THEN
            RETURN vcruce;
         END IF;

         IF ptiporeturn = 'CCRUCEDET' THEN
            RETURN NULL;
         END IF;

   END f_get_conciliacion;

----
--BRSP SAP
   FUNCTION f_conccar_ejecutarcargasap(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER,
      pjob IN NUMBER DEFAULT 0,
      pcusuari IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'PAC_CARGAS_CON.f_conccar_ejecutarcargasap';
      vparam         VARCHAR2(200) := 'p_nombre'||p_nombre||' p_path'||p_path||' p_cproces'||p_cproces||' psproces'||psproces||
      ' pjob'||pjob||' pcusuari'||pcusuari;
      vtraza         NUMBER := 0;
      vnum_err       NUMBER := 0;
      vsalir         EXCEPTION;
      wlinerr        NUMBER := 0;
      pnnumideage    NUMBER := 0;
      codefichero    NUMBER := 0;
   BEGIN
      vtraza := 0;
   -- INI BUG IAXIS-13317 JRVG 31/03/2020
      IF pjob = 1 THEN
         vnum_err :=
            pac_contexto.f_inicializarctx(NVL(pcusuari,
                                              pac_parametros.f_parempresa_t(k_cempresa,
                                                                            'USER_BBDD')));
      END IF;

      SELECT NVL(cpara_error, 0), NVL(cbusca_host, 0), NVL(cformato_decimales, 0),
             NVL(ctablas, 'POL'), cdebug, nregmasivo
        INTO k_cpara_error, k_busca_host, k_cformato_decimales,
             k_tablas, k_cdebug, k_nregmasivo
        FROM cfg_files
       WHERE cempres = k_cempresa
         AND cproceso = p_cproces;

      IF psproces IS NULL
         OR(psproces IS NOT NULL
            AND pjob = 1) THEN
            
         vnum_err := f_ejecutar_carga_ficherosap(p_nombre,
                                                 p_path,
                                                 p_cproces,
                                                 psproces);         

         IF vnum_err <> 0 THEN
            RAISE vsalir;
         END IF;
      END IF;
      
      vtraza   := 1;
       vnum_err := pac_cargas_conf.f_proceso_cargasap(psproces, p_cproces);
      
       IF vnum_err <> 0 THEN
        p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                     'Error llamando a pac_cargas_conf.f_proceso_cargasap', 10);
         
         RAISE vsalir;
          /* Cambios para IAXIS-2015 : Start */
       ELSE
          vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces,
                                                                     p_nombre,
                                                                     null,
                                                                     f_sysdate,
                                                                     4,
                                                                     p_cproces,
                                                                     0,
                                                                     NULL);
          vnum_err := f_procesfin(psproces, 0);
          /* Cambios para IAXIS-2015 : End */
      END IF;
   -- FIN BUG IAXIS-13317 JRVG 31/03/2020   
      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN vsalir THEN
         RETURN vnum_err;
   END f_conccar_ejecutarcargasap;

   FUNCTION f_ejecutar_carga_ficherosap(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER,
      pjob IN NUMBER DEFAULT 0,
      pcusuari IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'PAC_CARGAS_CONF.f_ejecutar_carga_ficherosap';
      linea          NUMBER := 0;
      pcarga         NUMBER;
      vtraza         NUMBER := 0;
      vdeserror      VARCHAR2(1000);
      v_sproces      NUMBER; 
      vsinproc       BOOLEAN := TRUE;   --Indica si tenemos o no proceso
      vnnumlin       NUMBER;
      errorini       EXCEPTION;
      vnum_err       NUMBER := 0;
      vsalir         EXCEPTION;
      verrorfin      BOOLEAN := FALSE;
      vavisfin       BOOLEAN := FALSE;
      vtiperr        NUMBER;
      vcoderror      NUMBER;
      v_deserror     int_carga_ctrl_linea_errs.tmensaje%TYPE;
      e_errdatos     EXCEPTION;
      vparam         VARCHAR2(200):='p_nombre'||p_nombre||'p_path'||p_path||'p_cproces'||
                                    p_cproces||'psproces'||psproces||'pjob'||pjob||'pcusuari'||pcusuari;
   BEGIN
      vtraza := 0;
   -- INI BUG IAXIS-13317 JRVG 31/03/2020 
      vsinproc := TRUE;
      vnum_err := f_procesini(f_user, k_empresaaxis,'CARGA_FICHERO SAP', p_nombre, v_sproces);  
      
      IF vnum_err <> 0 THEN
         RAISE errorini;   --Error que para ejecucin
        END IF;      
      
      psproces := v_sproces;
      vtraza := 1;

      IF p_cproces IS NULL THEN
         vnum_err := 9901092;
         vdeserror := 'cfg_files falta proceso: ' || vobj;
         RAISE e_errdatos;
      END IF;

      vtraza := 11;
      vnum_err :=
         pac_gestion_procesos.f_set_carga_ctrl_cabecera(v_sproces, p_nombre, f_sysdate, NULL,
                                                        3, p_cproces,   
                                                        NULL, NULL);
      vtraza := 12;
      
      IF vnum_err <> 0 THEN   --Si fallan esta funciones de gestin salimos del programa
         p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                     'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera');
         vnum_err := f_proceslin(v_sproces,
                                 f_axis_literales(180856, k_idiomaaaxis) || ':' || p_nombre
                                 || ' : ' || vnum_err,
                                 1, vnnumlin);
         RAISE errorini;   --Error que para ejecucin
      END IF;

      COMMIT;
      
      vtraza := 2;
      --vnum_err := f_modi_tabla_ext(p_nombre, p_path);
      vnum_err := f_modi_tabla_extsap(p_nombre, p_path);

      IF vnum_err <> 0 THEN
         p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                     'Error creando la tabla externa', 10);
                     
         vnum_err := f_proceslin(v_sproces,
                                 f_axis_literales(vnum_err, k_idiomaaaxis) || ':' || p_nombre
                                 || ' : ' || vnum_err,
                                 1, vnnumlin);
                                 
         RAISE errorini;
      END IF;
      
      vtraza := 3; 
      vnum_err := f_trasp_tablasap(vdeserror, psproces);
     
      vtraza := 53;
      if vnum_err = 0 then
         BEGIN
            vnum_err := f_carga_genericasap(psproces, p_nombre, p_path);       
           exception
            WHEN others THEN
              p_tab_error(f_sysdate,
                 f_user,
                 vobj,
                 vtraza,
                 NULL,
                'Error en PROCESO  genericasap  :');
         END;
      end if;
      
      IF vdeserror IS NOT NULL THEN
         --Si hay un error leyendo el fichero salimos del programa del todo y lo indicamos.
         vtraza := 5;
         vnum_err :=
            pac_gestion_procesos.f_set_carga_ctrl_cabecera
                                                         (v_sproces, p_nombre, f_sysdate,
                                                          NULL, 1, p_cproces,   
                                                          NULL, vdeserror);
         vtraza := 51;

         IF vnum_err <> 0 THEN   --Si fallan esta funciones de gestin salimos del programa
            --RAISE ErrGrabarProv;
            p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                        'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera2');
            vnnumlin := NULL;
            vnum_err := f_proceslin(v_sproces,
                                    f_axis_literales(180856, k_idiomaaaxis) || ':' || p_nombre
                                    || ' : ' || vnum_err,
                                    1, vnnumlin);
            RAISE errorini;   --Error que para ejecucin
         END IF;

         vtraza := 52;
         COMMIT;   --Guardamos la tabla temporal int
         
         RAISE vsalir;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN vsalir THEN
         RETURN 103187;
      WHEN e_errdatos THEN
         ROLLBACK;
         pac_cargas_conf.p_genera_logs(vobj, vtraza, 'Error:' || vnum_err, vdeserror,
                                       psproces, 'Error:' || vnum_err || ' ' || vdeserror);
         COMMIT;
         RETURN vnum_err;
      WHEN errorini THEN
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
                                                          NULL, 1, p_cproces,   
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

         RETURN 1;
      --FIN BUG IAXIS-13317 JRVG 31/03/2020
   END f_ejecutar_carga_ficherosap;

   FUNCTION f_modi_tabla_extsap(p_nombre VARCHAR2, p_path IN VARCHAR2)
      RETURN NUMBER IS
      v_iteraciones  NUMBER(2);
   BEGIN
      v_iteraciones := 1;

      LOOP
         BEGIN
            LOCK TABLE int_carga_genericocartera_ext IN EXCLUSIVE MODE;

            EXECUTE IMMEDIATE 'ALTER TABLE int_carga_genericocartera_ext LOCATION (' || p_path
                              || ':''' || p_nombre || ''')';

            EXIT;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'pac_cargas_vida_lcol.f_crea_tabla_ext',
                           v_iteraciones, 'Error modificando tabla. Reintento.', SQLERRM, 10);

               IF k_iteraciones <= v_iteraciones THEN
                  RAISE;
               END IF;

               sleep(k_segundos);
               v_iteraciones := v_iteraciones + 1;
         END;
      END LOOP;

      LOCK TABLE int_carga_genericocartera_ext IN EXCLUSIVE MODE;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_cargas_generico.f_crea_tabla_ext', 1,
                     'Error creando la tabla.', SQLERRM, 10);
         RETURN 103865;
   END f_modi_tabla_extsap;

   FUNCTION f_trasp_tablasap(pdeserror OUT VARCHAR2, psproces IN NUMBER)
      RETURN NUMBER IS
      v_pasexec      NUMBER := 1;
      vobj           VARCHAR2(200) := 'pac_cargas_conf.f_trasp_tablasap';
      v_numlin       int_carga_genericocartera.nlinea%TYPE;
   BEGIN
      v_pasexec := 0;
      pdeserror := NULL;

      SELECT NVL(MAX(nlinea), 0)
        INTO v_numlin
        FROM int_carga_generico
       WHERE proceso = psproces;

      INSERT      /*+ APPEND */INTO int_carga_genericocartera
                  (proceso, nlinea, ncarga, tipo_oper, campo01, campo02, campo03, campo04,
                   campo05, campo06, campo07, campo08, campo09, campo10, campo11, campo12,
                   campo13, campo14, campo15, campo16, campo17, campo18, campo19, campo20,
                   campo21, campo22, campo23, campo24, campo25, campo26, campo27, campo28,
                   campo29, campo30, campo31, campo32, campo33, campo34, campo35, campo36,
                   campo37, campo38, campo39, campo40, campo41, campo42, campo43, campo44,
                   campo45, campo46, campo47, campo48, campo49, campo50)
         (SELECT psproces proceso, ROWNUM + v_numlin nlinea, NULL ncarga, NULL tipo_oper,
                 campo01, campo02, campo03, campo04, campo05, campo06, campo07, campo08,
                 campo09, campo10, campo11, campo12, campo13, campo14, campo15, campo16,
                 campo17, campo18, campo19, campo20, campo21, campo22, campo23, campo24,
                 campo25, campo26, campo27, campo28, campo29, campo30, campo31, campo32,
                 campo33, campo34, campo35, campo36, campo37, campo38, campo39, campo40,
                 campo41, campo42, campo43, campo44, campo45, campo46, campo47, campo48,
                 campo49, campo50
            FROM int_carga_genericocartera_ext);

      v_pasexec := 1;
      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         pdeserror := f_axis_literales(103187, k_cidioma) || SQLERRM;
         p_tab_error(f_sysdate, f_user, vobj, v_pasexec, SQLCODE, SQLERRM);
         RETURN 1;
   END f_trasp_tablasap;

   FUNCTION f_set_carga_ctrl_cabecerasap(
      psproces IN NUMBER,
      ptfichero IN VARCHAR2,
      pfini IN DATE,
      pffin IN DATE,
      pcestado IN NUMBER,
      pcproceso IN NUMBER,
      pcerror IN NUMBER,
      pterror IN VARCHAR2,
      pcbloqueo IN NUMBER DEFAULT 0)
      RETURN NUMBER IS
      PRAGMA AUTONOMOUS_TRANSACTION;
      vobjectname    VARCHAR2(500) := 'pac_gestion_procesos.f_set_carga_ctrl_cabecerasap';
      vparam         VARCHAR2(4000)
         := 'parmetros - psproces : ' || psproces || ',tfichero : ' || ptfichero
            || ',fini : ' || pfini || ',ffin : ' || pffin || ',cestado : ' || pcestado
            || ',cproceso : ' || pcproceso || ',pcerror : ' || pcerror || ',pcbloqueo : '
            || pcbloqueo;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vcbloqueo      int_carga_ctrl.cbloqueo%TYPE;
   BEGIN
      IF ptfichero IS NULL
         OR pcestado IS NULL THEN
         RETURN 1000005;
      END IF;

      IF psproces IS NULL THEN
         NULL;
      END IF;

      IF pcbloqueo = 1 THEN
         BEGIN
            SELECT cbloqueo
              INTO vcbloqueo
              FROM int_carga_ctrl
             WHERE sproces = psproces;

            IF vcbloqueo = 1 THEN
               RETURN 9905979;
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               NULL;
         END;
      END IF;

      IF pfini IS NULL THEN
         UPDATE int_carga_ctrl
            SET tfichero = ptfichero,
                fini = NVL(pfini, fini),
                ffin = pffin,
                cestado = pcestado,
                cproceso = pcproceso,
                cerror = pcerror,
                terror = pterror,
                cbloqueo = NVL(pcbloqueo, 0)
          WHERE sproces = psproces;

         COMMIT;
         RETURN 0;
      END IF;

      BEGIN
         INSERT INTO int_carga_ctrl
                     (sproces, tfichero, fini, ffin, cestado, cerror, terror,
                      cproceso, cbloqueo)
              VALUES (psproces, ptfichero, pfini, pffin, pcestado, pcerror, pterror,
                      pcproceso, NVL(pcbloqueo, 0));
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE int_carga_ctrl
               SET tfichero = ptfichero,
                   fini = NVL(pfini, fini),
                   ffin = pffin,
                   cestado = pcestado,
                   cproceso = pcproceso,
                   cerror = pcerror,
                   terror = pterror,
                   cbloqueo = NVL(pcbloqueo, 0)
             WHERE sproces = psproces;
      END;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, 1, 'f_set_carga_ctrl_cabecerasap',
                     SQLERRM);
         RETURN 1000006;
   END f_set_carga_ctrl_cabecerasap;
  
-- INI BUG IAXIS-13317 JRVG 31/03/2020
   FUNCTION f_carga_genericasap(psproces IN NUMBER, p_nombre IN VARCHAR2, p_path IN VARCHAR2)
      RETURN NUMBER IS
      v_pasexec      NUMBER := 1;
      vobj           VARCHAR2(200) := 'pac_cargas_conf.f_carga_genericasap';
      mysql_in       VARCHAR2(20000) := '';
      mysql_se       VARCHAR2(10000) := '';
      count_r        NUMBER := 0;
      v_numlin       int_carga_generico.nlinea%TYPE;
      --INI SGM IAXIS-4102 saldos a favor del cliente
      llave1         NUMBER;         
      llave2         NUMBER;
      isllave1       NUMBER;
      vumerr         NUMBER;
      vobject        VARCHAR2(200) := 'PAC_CARGAS_CONF.F_CARGA_GENERICASAP';
      v_num_lin      NUMBER :=0;
      vnumerr        NUMBER(8) := 0;
      v_sproces      NUMBER:= 0;
      vnombreCargarSap  VARCHAR2(500);
      vcargarSap     UTL_FILE.file_type;
      vlinea         VARCHAR2(200);
      v_sgsfavcli1    gca_salfavcli.sgsfavcli%type;
      v_sgsfavcli2    gca_salfavcli.sgsfavcli%type;
      
      CURSOR cur_map IS
         SELECT tcolori, tcoldest
           FROM gca_cargaconc_mapeo gc, gca_cargaconc cc
          WHERE cc.cfichero = gc.cfichero
            AND UPPER(cc.tdescrip) LIKE UPPER(SUBSTR(p_nombre, 0, 3)) || '%';

      CURSOR cur_registros(v_sproces IN NUMBER)IS
         SELECT sgsfavcli, nnumidecli,imovimi_moncia, sproces, tnomcli
           FROM gca_salfavcli 
          WHERE sproces = v_sproces; 
      --FIN SGM IAXIS-4102 saldos a favor del cliente              	  

   BEGIN   
    vnombreCargarSap := 'AUXILIAR_27_CRUCES_' ||TO_CHAR(f_sysdate, 'yyyymmdd_hh24miss') || '.txt';
    vcargarSap       := UTL_FILE.fopen(p_path, vnombreCargarSap, 'w');
    vlinea           := 'SGSFAVCLI|IDENTIFICACION|NOMBRE|DETALLE';
    UTL_FILE.put_line(vcargarSap, vlinea);
    
    v_pasexec := 0;
      SELECT COUNT(*)
        INTO count_r
        FROM gca_cargaconc_mapeo gc, gca_cargaconc cc
       WHERE cc.cfichero = gc.cfichero
         AND UPPER(cc.tdescrip) LIKE UPPER(SUBSTR(p_nombre, 0, 3)) || '%';

      mysql_in := 'INSERT INTO gca_salfavcli( sproces,sgsfavcli,';
      mysql_se := ')(SELECT ' || psproces || ',GCA_SALFAVCLI_SEQ.NEXTVAL ,';

      FOR i IN cur_map LOOP
         mysql_in := mysql_in || i.tcoldest;
         mysql_se := mysql_se || i.tcolori;

         IF count_r > 1 THEN
            mysql_in := mysql_in || ',';
            mysql_se := mysql_se || ',';
         END IF;

         count_r := count_r - 1;
      END LOOP;

      mysql_se :=
         mysql_se
         || ' FROM (SELECT ROWNUM R, ICG.* FROM INT_CARGA_GENERICOCARTERA ICG WHERE icg.proceso = '||psproces ||') WHERE R >= 1)';
      mysql_in := mysql_in || mysql_se;

      EXECUTE IMMEDIATE mysql_in;
      COMMIT;
       
      FOR reg IN cur_registros(psproces) LOOP 
       BEGIN
        v_num_lin := v_num_lin + 1;   
        vnumerr:= pac_gestion_procesos.f_set_carga_ctrl_linea(psproces    => reg.sproces,
                                                      pnlinea    => v_num_lin,
                                                      pctipo     => 22,
                                                      pidint     => v_num_lin,
                                                      pidext     => NULL,
                                                      pcestado   => 4,
                                                      pcvalidado => NULL,
                                                      psseguro   => NULL,
                                                      pidexterno => reg.sgsfavcli,
                                                      pncarga    => NULL,
                                                      pnsinies   => NULL,
                                                      pntramit   => NULL,
                                                      psperson   => NULL,
                                                      pnrecibo   => NULL);
     -- Escritura en tabext de archivo .txt
        BEGIN 
       
        SELECT sgsfavcli
          into v_sgsfavcli1
          from gca_salfavcli
         where sproces = psproces
           and sgsfavcli = reg.sgsfavcli
           and imovimi_moncia  = 0;   
        --
           if v_sgsfavcli1 = reg.sgsfavcli then
              vlinea :=reg.sgsfavcli || '|' ||reg.nnumidecli || '|' || 
                        upper(reg.tnomcli) || '|' || '1-SALDO A FAVOR CLIENTE,PROCESO#'|| ':' ||reg.sproces;
              UTL_FILE.put_line(vcargarSap, vlinea);
            
           end if;
           exception
            when no_data_found then
             null;
           end;
           
           -- Escritura 2 en tabext de archivo .txt
        BEGIN 
       
        select sgsfavcli
          into v_sgsfavcli2 
          from gca_salfavcli
         where sproces = psproces
           and sgsfavcli = reg.sgsfavcli
           and nnumidecli in (select nnumidecli
                                from (select sum(imovimi_moncia), nnumidecli
                                        from gca_salfavcli
                                       where sproces = psproces
                                       group by nnumidecli
                                      having sum(imovimi_moncia) = 0));
           --   
           if v_sgsfavcli2 = reg.sgsfavcli then
              vlinea :=reg.sgsfavcli || '|' ||reg.nnumidecli || '|' || 
                        upper(reg.tnomcli) || '|' || '2-SALDO A FAVOR CLIENTE,PROCESO#'|| ':' ||reg.sproces;
              UTL_FILE.put_line(vcargarSap, vlinea); 
           end if;
           exception
            when no_data_found then
             null;
           end; 
      
         exception
          when others then
           p_tab_error(f_sysdate, f_user, vobj,v_num_lin,'Insert carga_ctrl_linea ',sqlerrm);
         end;             
      END LOOP; 
      
      --INI SGM IAXIS-4102 saldos a favor del cliente (Se eliminan registros en 0 o que crucen para un saldo de 0)      
      BEGIN
        delete from gca_salfavcli
         where sproces = psproces
           and nnumidecli in
               (select nnumidecli
                  from (select sum(imovimi_moncia), nnumidecli
                          from gca_salfavcli
                         where sproces = psproces
                         group by nnumidecli
                        having sum(imovimi_moncia) = 0));
                        
            delete from gca_salfavcli
            where sproces = psproces
            and imovimi_moncia  = 0; 
                
      exception
      when others then
         p_tab_error(f_sysdate, f_user, vobj, v_pasexec, sqlcode, sqlerrm);      
      END;
      
--se limpiaran de la tabla los registros que crucen para un saldo 0 cuando el cliente tiene otros registros que no cruzan
      FOR j IN cur_registros(psproces) LOOP
            begin
                select 1
                  into isllave1
                  from tmp_gca_salfavcli
                 where sgsfavcli = j.sgsfavcli;
            exception
            when no_data_found then
                isllave1:=0;
            end;

            if isllave1 = 0 then
                begin
                  select sgsfavcli
                    into llave2
                    from gca_salfavcli
                   where sproces = psproces
                     and nnumidecli = j.nnumidecli
                     and imovimi_moncia = j.imovimi_moncia * -1
                     and sgsfavcli not in (select sgsfavcli from tmp_gca_salfavcli);   
                exception
                when no_data_found then
                    llave2 := 0;                     
                end;

                if llave2 <> 0 then
                    llave1 := j.sgsfavcli;
                    insert into tmp_gca_salfavcli values (llave1);
                    insert into tmp_gca_salfavcli values (llave2);
                end if;
            end if;                 
      END LOOP;      
      COMMIT;

      -- Escritura en tabext archivo .txt
      FOR i IN cur_registros(psproces) LOOP
        begin
          select sgsfavcli
            into v_sgsfavcli1
            from tmp_gca_salfavcli
           where sgsfavcli = i.sgsfavcli;
        exception
          when no_data_found then
            null;
        end;
          if v_sgsfavcli1 = i.sgsfavcli then 
              vlinea := i.sgsfavcli || '|' ||i.nnumidecli || '|' || 
                        upper(i.tnomcli) || '|' || 'CRUCE DE SALDOS,PROCESO#'|| ':' ||i.sproces;
              utl_file.put_line(vcargarsap, vlinea);
          end if;
      END LOOP;
      
      DELETE FROM gca_salfavcli WHERE sgsfavcli IN (SELECT sgsfavcli FROM tmp_gca_salfavcli);
      DELETE FROM tmp_gca_salfavcli;

    --INI IAXIS-4102 se corrige el numero de agente para poder buscarlo en filtros de pantalla    
    --INI IAXIS-4102 JRVG 15/04/2020   
     BEGIN
      UPDATE gca_salfavcli 
         SET nnumideage = nnumidecli,
             tnomage = f_nombre_persona((select distinct p.sperson from per_personas p, agentes a where a.sperson = p.sperson and p.nnumide = nnumidecli), 1, null),
             tnomcli = f_nombre_persona((select distinct p.sperson from per_personas p, agentes a where a.sperson = p.sperson and p.nnumide = nnumidecli), 1, null)
       WHERE nnumidecli IN   
                (SELECT nnumide
                  FROM agentes a,  per_personas pp  
                 WHERE a.sperson = pp.sperson);
      EXCEPTION
      WHEN OTHERS THEN
           p_tab_error(f_sysdate, f_user, vobj,psproces,'Update TipoAgente',sqlerrm);    
      END;
      --
     BEGIN
       UPDATE gca_salfavcli 
          SET tnomcli = f_nombre_persona((select max(p.sperson) from per_personas p where  p.nnumide = nnumidecli), 1, null)
        WHERE nnumidecli not in
              (SELECT nnumide
                 FROM agentes a, per_personas pp
                WHERE a.sperson = pp.sperson);
          EXCEPTION
        WHEN OTHERS THEN
             p_tab_error(f_sysdate, f_user, vobj,psproces,'Update Cliente',sqlerrm);    
     END;
     --
     BEGIN
      UPDATE gca_salfavcli 
         SET  csucursal =(select a.cagente
                            from agentes a, age_paragentes ag
                           where a.cagente = ag.cagente
                             and ag.tvalpar = csucursal)
       WHERE sproces = psproces;  
     EXCEPTION
      WHEN OTHERS THEN
           p_tab_error(f_sysdate, f_user, vobj,psproces,'Update Sucursal',sqlerrm);    
     END;
   --FIN IAXIS-4102 JRVG 15/04/2020         
   --FIN SGM IAXIS-4102 saldos a favor del cliente

      v_pasexec := 1;
      COMMIT;
      
      UTL_FILE.FCLOSE(vcargarSap);
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, vobj, v_pasexec, SQLCODE, SQLERRM);
         RETURN 1;
   END f_carga_genericasap;
-- FIN BUG IAXIS-13317 JRVG 31/03/2020

   FUNCTION f_get_conciliacionsap(
      ptiporeturn IN VARCHAR2,
      pseguro IN VARCHAR2,
      precibo IN VARCHAR2,
      psaldo IN VARCHAR2)
      RETURN VARCHAR2 IS
      v_cursor       sys_refcursor;
      vpasexec       NUMBER;
      vobject        VARCHAR2(200) := 'PAC_rea.f_get_gca_cargaconc';
      vparam         VARCHAR2(500) := '';
      vseguro        NUMBER := NULL;
      vrecibo        NUMBER := NULL;
      vsaldo         NUMBER := NULL;
   BEGIN
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, 0, SQLCODE, SQLERRM);
         RETURN NULL;
   END f_get_conciliacionsap;
   FUNCTION f_get_datos_recibo_t(ptipo IN NUMBER, pnrecibo IN VARCHAR2)
      RETURN VARCHAR2 IS
            v_cursor       sys_refcursor;
      vpasexec       NUMBER := 0;
      vobject        VARCHAR2(200) := 'PAC_CARGAS_CONF.f_get_datos_recibo_t';
      vparam         VARCHAR2(500) := 'ptipo ='||ptipo || ' - pnrecibo='|| pnrecibo;
      vdivisa         VARCHAR2(10);
      vtagente        VARCHAR2(2000);
      vcertificado    VARCHAR2(40);
      vnumcliente     VARCHAR2(20);
      vcliente        VARCHAR2(2000);
      vnrecibo NUMBER;
   BEGIN

      vpasexec := 1;
      SELECT UNIQUE pac_monedas.F_cmoneda_t(p.cdivisa),

              (SELECT ncertdian
               FROM   rango_dian_movseguro rd
               WHERE  rd.sseguro = m.sseguro
                      AND rd.nmovimi = m.nmovimi)
              certificado,
              pp.nnumide,
              (SELECT pd.tapelli1
                      || Decode(pd.tapelli1, NULL, NULL,
                                             ' ')
                      || pd.tapelli2
                      || Decode(pd.tapelli1
                                || pd.tapelli2, NULL, NULL,
                                                Decode(tnombre, NULL, NULL,
                                                                pd.tnombre1
                                                                || ' '
                                                                || pd.tnombre2))
               FROM   per_detper pd
               WHERE  pd.sperson = t.sperson)
              cliente
  INTO   vdivisa, vcertificado, vnumcliente, vcliente
  FROM   seguros s,
       movseguro m,
       tomadores t,
       recibos r,
       productos p,
       movrecibo mr,
       detmovrecibo d,
       per_personas pp
  WHERE  s.sproduc = p.sproduc
       AND s.sseguro = m.sseguro
       AND mr.nrecibo = r.nrecibo
       AND d.nrecibo(+) = r.nrecibo
       AND t.sseguro = s.sseguro
       AND t.nordtom = 1
       AND r.sseguro(+) = m.sseguro
       AND r.nmovimi(+) = m.nmovimi
       AND pp.sperson = t.sperson
       AND TO_CHAR(r.nrecibo) = TO_CHAR(replace(replace(TRIM(pnrecibo),chr(10),''),chr(13),''));
       vpasexec := 2;

   IF ptipo = 2 THEN
    RETURN vnumcliente;
   ELSIF ptipo = 3 THEN
    RETURN vcliente;
   ELSIF ptipo = 5 THEN
    RETURN vcertificado;
   ELSIF ptipo = 10 THEN
    RETURN vdivisa;
   ELSE
    RETURN NULL;
   END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN NULL;
   END f_get_datos_recibo_t;
   FUNCTION f_get_datos_recibo_n(ptipo IN NUMBER, pnrecibo IN VARCHAR2)
      RETURN NUMBER IS
      vpasexec        NUMBER :=0;
      vobject         VARCHAR2(200) := 'PAC_CARGAS_CONF.f_get_datos_recibo_n';
      vparam         VARCHAR2(500) := 'ptipo ='||ptipo || ' - pnrecibo='|| pnrecibo;
      vnumpoliza      NUMBER;
      vnrecibo        NUMBER;
      vcagente        NUMBER;
      vdiasm          NUMBER;
      vtotalrecibo    NUMBER;
      vcomision       NUMBER;
      vgestionoutsour NUMBER;
      vnrecibo1 NUMBER;
   BEGIN

      vpasexec := 1;
      SELECT UNIQUE Decode(s.ncertif, 0, s.npoliza
                                   ||' ',
                                s.npoliza
                                || '-'
                                || s.ncertif)
              numpoliza,
              r.nrecibo,
              Nvl((SELECT ac.cagente
                                              FROM   age_corretaje ac
                                              WHERE  ac.sseguro = s.sseguro
                                                     AND ac.islider = 1
                                                     AND ac.nmovimi = (SELECT
                                                         Max(acc.nmovimi)
                                                                       FROM
                                                         age_corretaje acc
                                                                       WHERE
                                                         acc.sseguro = m.sseguro
                                                         AND acc.nmovimi <=
                                                             m.nmovimi)),
                                             s.cagente) cagente,
              Trunc(f_sysdate) - Trunc(nvl(CASE SIGN(TRUNC(r.femisio)-TRUNC(r.fefecto))--05/09/2019   SGM  IAXIS-4511 CONCILIACION DE CARTERA
                                            WHEN -1 THEN r.femisio
                                            ELSE r.fefecto
                                            END,m.fefecto))
              mad,
              --
             /* Nvl((SELECT SUM(iconcep)
                   FROM   detrecibos
                   WHERE  nrecibo = R.nrecibo
                          AND cconcep = 0), (SELECT SUM(iconcep)
                                             FROM   detmovrecibo_parcial
                                             WHERE  nrecibo = R.nrecibo
                                                    AND cconcep = 0
                                                    AND smovrec = d.smovrec))*/
              Nvl((SELECT (vm.itotalr - (nvl((select sum(dm.iimporte_moncon) from detmovrecibo dm where dm.nrecibo = vm.nrecibo),0)))itotalr
                   FROM   vdetrecibos_monpol vm
                   WHERE  vm.nrecibo = R.nrecibo), 
                          (SELECT SUM(iconcep)
                             FROM   detmovrecibo_parcial
                             WHERE  nrecibo = R.nrecibo
                                AND cconcep = 0
                                AND smovrec = d.smovrec))                                                    
              prima_mon,
              Nvl((SELECT SUM(iconcep)
                   FROM   detrecibos
                   WHERE  nrecibo = R.nrecibo
                          AND cconcep = 11), (SELECT SUM(iconcep)
                                              FROM   detmovrecibo_parcial
                                              WHERE  nrecibo = R.nrecibo
                                                     AND cconcep = 11
                                                     AND smovrec = d.smovrec))
              comi_mon,
              nvl((select cgescar from recibos where nrecibo = R.nrecibo),null)
              gestionadooutsour
  INTO   vnumpoliza, vnrecibo1, vcagente, vdiasm, vtotalrecibo, vcomision, vgestionoutsour
  FROM   seguros s,
       movseguro m,
       tomadores t,
       recibos r,
       productos p,
       movrecibo mr,
       detmovrecibo d,
       per_personas pp
  WHERE  s.sproduc = p.sproduc
       AND s.sseguro = m.sseguro
       AND mr.nrecibo = r.nrecibo
       AND d.nrecibo(+) = r.nrecibo
       AND t.sseguro = s.sseguro
       AND t.nordtom = 1
       AND r.sseguro(+) = m.sseguro
       AND r.nmovimi(+) = m.nmovimi
       AND pp.sperson = t.sperson
       AND TO_CHAR(r.nrecibo) = TO_CHAR(replace(replace(TRIM(pnrecibo),chr(10),''),chr(13),''));
           vpasexec := 2;
   IF ptipo = 1 THEN
    RETURN vcagente;
   ELSIF ptipo = 4 THEN
    RETURN vnumpoliza;
   ELSIF ptipo = 6 THEN
    RETURN vnrecibo1;
   ELSIF ptipo = 7 THEN
    RETURN vdiasm;
   ELSIF ptipo = 8 THEN
    RETURN vtotalrecibo;
   ELSIF ptipo = 9 THEN
    RETURN vcomision;
   ELSIF ptipo = 11 THEN
    RETURN vgestionoutsour;    
   ELSE
    RETURN NULL;
   END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, 0, vparam, SQLERRM);
         RETURN NULL;
   END f_get_datos_recibo_n;
   
--INI 05/09/2019   SGM IAXIS-4511 CONCILIACION DE CARTERA
   FUNCTION f_get_datos_poliza_t(ptipo IN NUMBER, pnpoliza IN VARCHAR2)
      RETURN VARCHAR2 IS
            v_cursor       sys_refcursor;
      vpasexec       NUMBER := 0;
      vobject        VARCHAR2(200) := 'PAC_CARGAS_CONF.f_get_datos_poliza_t';
      vparam         VARCHAR2(500) := 'ptipo ='||ptipo || ' - pnpoliza='|| pnpoliza;
      vdivisa         VARCHAR2(10);
      vtagente        VARCHAR2(2000);
      vcertificado    VARCHAR2(40);
      vnumcliente     VARCHAR2(20);
      vcliente        VARCHAR2(2000);
      vnrecibo        NUMBER;
   BEGIN
   
      BEGIN
      SELECT nrecibo
        INTO vnrecibo
        FROM (SELECT COUNT(1) over(PARTITION BY s.npoliza) contador, s.npoliza, r.nrecibo
               FROM seguros s, recibos r
              WHERE s.sseguro = r.sseguro
                AND s.csituac IN (0, 4)
                AND EXISTS (SELECT 1
                       FROM movrecibo m
                      WHERE m.nrecibo = r.nrecibo
                        AND m.smovrec = (SELECT MAX(m1.smovrec) FROM movrecibo m1 WHERE m1.nrecibo = m.nrecibo)
                        AND m.cestrec = 0
                        AND m.fmovfin IS NULL)
                AND  s.npoliza = TO_CHAR(replace(replace(TRIM(pnpoliza),chr(10),''),chr(13),''))) 
        WHERE contador = 1;
      EXCEPTION
      WHEN NO_DATA_FOUND then
            RETURN NULL;
      END;
   

      vpasexec := 1;
      SELECT UNIQUE pac_monedas.F_cmoneda_t(p.cdivisa),

              (SELECT ncertdian
               FROM   rango_dian_movseguro rd
               WHERE  rd.sseguro = m.sseguro
                      AND rd.nmovimi = m.nmovimi)
              certificado,
              pp.nnumide,
              (SELECT pd.tapelli1
                      || Decode(pd.tapelli1, NULL, NULL,
                                             ' ')
                      || pd.tapelli2
                      || Decode(pd.tapelli1
                                || pd.tapelli2, NULL, NULL,
                                                Decode(tnombre, NULL, NULL,
                                                                pd.tnombre1
                                                                || ' '
                                                                || pd.tnombre2))
               FROM   per_detper pd
               WHERE  pd.sperson = t.sperson)
              cliente
  INTO   vdivisa, vcertificado, vnumcliente, vcliente
  FROM   seguros s,
       movseguro m,
       tomadores t,
       recibos r,
       productos p,
       movrecibo mr,
       detmovrecibo d,
       per_personas pp
  WHERE  s.sproduc = p.sproduc
       AND s.sseguro = m.sseguro
       AND mr.nrecibo = r.nrecibo
       AND d.nrecibo(+) = r.nrecibo
       AND t.sseguro = s.sseguro
       AND t.nordtom = 1
       AND r.sseguro(+) = m.sseguro
       AND r.nmovimi(+) = m.nmovimi
       AND pp.sperson = t.sperson
       AND r.nrecibo = vnrecibo;
       vpasexec := 2;

   IF ptipo = 2 THEN
    RETURN vnumcliente;
   ELSIF ptipo = 3 THEN
    RETURN vcliente;
   ELSIF ptipo = 5 THEN
    RETURN vcertificado;
   ELSIF ptipo = 10 THEN
    RETURN vdivisa;
   ELSE
    RETURN NULL;
   END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN NULL;
   END f_get_datos_poliza_t;
   
   FUNCTION f_get_datos_poliza_n(ptipo IN NUMBER, pnpoliza IN VARCHAR2)
      RETURN NUMBER IS
      vpasexec        NUMBER :=0;
      vobject         VARCHAR2(200) := 'PAC_CARGAS_CONF.f_get_datos_poliza_n';
      vparam         VARCHAR2(500) := 'ptipo ='||ptipo || ' - pnpoliza='|| pnpoliza;
      vnumpoliza      NUMBER;
      vnrecibo        NUMBER;
      vcagente        NUMBER;
      vdiasm          NUMBER;
      vtotalrecibo    NUMBER;
      vcomision       NUMBER;
      vgestionoutsour NUMBER;
      vnrecibo1 NUMBER;
   BEGIN

      BEGIN
      SELECT nrecibo
        INTO vnrecibo
        FROM (SELECT COUNT(1) over(PARTITION BY s.npoliza) contador, s.npoliza, r.nrecibo
               FROM seguros s, recibos r
              WHERE s.sseguro = r.sseguro
                AND s.csituac IN (0, 4)
                AND EXISTS (SELECT 1
                       FROM movrecibo m
                      WHERE m.nrecibo = r.nrecibo
                        AND m.smovrec = (SELECT MAX(m1.smovrec) FROM movrecibo m1 WHERE m1.nrecibo = m.nrecibo)
                        AND m.cestrec = 0
                        AND m.fmovfin IS NULL)
                AND  s.npoliza = TO_CHAR(replace(replace(TRIM(pnpoliza),chr(10),''),chr(13),''))) 
        WHERE contador = 1;
      EXCEPTION
      WHEN NO_DATA_FOUND then
            RETURN NULL;
      END;   
   
   

      vpasexec := 1;
      SELECT UNIQUE Decode(s.ncertif, 0, s.npoliza
                                   ||' ',
                                s.npoliza
                                || '-'
                                || s.ncertif)
              numpoliza,
              r.nrecibo,
              Nvl((SELECT ac.cagente
                                              FROM   age_corretaje ac
                                              WHERE  ac.sseguro = s.sseguro
                                                     AND ac.islider = 1
                                                     AND ac.nmovimi = (SELECT
                                                         Max(acc.nmovimi)
                                                                       FROM
                                                         age_corretaje acc
                                                                       WHERE
                                                         acc.sseguro = m.sseguro
                                                         AND acc.nmovimi <=
                                                             m.nmovimi)),
                                             s.cagente) cagente,
              TRUNC(f_sysdate) - TRUNC(nvl(CASE SIGN(TRUNC(r.femisio)-TRUNC(r.fefecto))
                                            WHEN -1 THEN r.femisio
                                            ELSE r.fefecto
                                            END,m.fefecto))
              mad,
              --
             /* Nvl((SELECT SUM(iconcep)
                   FROM   detrecibos
                   WHERE  nrecibo = R.nrecibo
                          AND cconcep = 0), (SELECT SUM(iconcep)
                                             FROM   detmovrecibo_parcial
                                             WHERE  nrecibo = R.nrecibo
                                                    AND cconcep = 0
                                                    AND smovrec = d.smovrec))*/
              Nvl((SELECT (vm.itotalr - (nvl((select sum(dm.iimporte_moncon) from detmovrecibo dm where dm.nrecibo = vm.nrecibo),0)))itotalr
                   FROM   vdetrecibos_monpol vm
                   WHERE  vm.nrecibo = R.nrecibo), 
                          (SELECT SUM(iconcep)
                             FROM   detmovrecibo_parcial
                             WHERE  nrecibo = R.nrecibo
                                AND cconcep = 0
                                AND smovrec = d.smovrec))                                                    
              prima_mon,
              Nvl((SELECT SUM(iconcep)
                   FROM   detrecibos
                   WHERE  nrecibo = R.nrecibo
                          AND cconcep = 11), (SELECT SUM(iconcep)
                                              FROM   detmovrecibo_parcial
                                              WHERE  nrecibo = R.nrecibo
                                                     AND cconcep = 11
                                                     AND smovrec = d.smovrec))
              comi_mon,
              nvl((select cgescar from recibos where nrecibo = R.nrecibo),null)
              gestionadooutsour
  INTO   vnumpoliza, vnrecibo1, vcagente, vdiasm, vtotalrecibo, vcomision, vgestionoutsour
  FROM   seguros s,
       movseguro m,
       tomadores t,
       recibos r,
       productos p,
       movrecibo mr,
       detmovrecibo d,
       per_personas pp
  WHERE  s.sproduc = p.sproduc
       AND s.sseguro = m.sseguro
       AND mr.nrecibo = r.nrecibo
       AND d.nrecibo(+) = r.nrecibo
       AND t.sseguro = s.sseguro
       AND t.nordtom = 1
       AND r.sseguro(+) = m.sseguro
       AND r.nmovimi(+) = m.nmovimi
       AND pp.sperson = t.sperson
       AND r.nrecibo = vnrecibo;
           vpasexec := 2;
   IF ptipo = 1 THEN
    RETURN vcagente;
   ELSIF ptipo = 4 THEN
    RETURN vnumpoliza;
   ELSIF ptipo = 6 THEN
    RETURN vnrecibo1;
   ELSIF ptipo = 7 THEN
    RETURN vdiasm;
   ELSIF ptipo = 8 THEN
    RETURN vtotalrecibo;
   ELSIF ptipo = 9 THEN
    RETURN vcomision;
   ELSIF ptipo = 11 THEN
    RETURN vgestionoutsour;    
   ELSE
    RETURN NULL;
   END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, 0, vparam, SQLERRM);
         RETURN NULL;
   END f_get_datos_poliza_n;
--FIN 05/09/2019   SGM IAXIS-4511 CONCILIACION DE CARTERA

   FUNCTION f_validar_registro_repetido( pnrecibo IN VARCHAR2, pnpoliza IN VARCHAR2, pitotalr IN VARCHAR2, psproces NUMBER, pnlinea NUMBER)
      RETURN NUMBER IS
      v_cursor       sys_refcursor;
      vpasexec       NUMBER;
      vobject        VARCHAR2(200) := 'PAC_CARGAS_CONF.f_validar_registro_repetido';
      vparam         VARCHAR2(500) := '';
      vcount         NUMBER := 0;
      vretorno       NUMBER := 0;
   BEGIN
      SELECT COUNT(1)
        INTO vcount
        FROM GCA_CONCILIACIONDET
       WHERE nrecibo_fic = pnrecibo
         AND npoliza_fic = pnpoliza
         AND itotalr_fic = pitotalr
         AND sidcon = psproces
         AND nlinea != pnlinea;

      IF vcount > 0 THEN

        UPDATE GCA_CONCILIACIONDET
           SET crepetido = 1
         WHERE nrecibo_fic = pnrecibo
           AND npoliza_fic = pnpoliza
           AND itotalr_fic = pitotalr
           AND sidcon = psproces
           AND nlinea <> pnlinea;

      END IF;
      RETURN vretorno;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, 0, SQLCODE, SQLERRM);
         RETURN 0;
   END f_validar_registro_repetido;
   
   /*************************************************************************
   FUNCTION f_lre_carga_insolvencia
   Ejecurta la carga del archivo de listas restrictivas por ley de insolvencia
   Retorna 0 Ok <> 0 Error
   *************************************************************************/
   FUNCTION f_lre_carga_insolvencia(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER)
      RETURN NUMBER IS
      vtraza         NUMBER;
      vnum_err       NUMBER;
      vobj           VARCHAR2(100) := 'pac_cargas_conf.f_lre_carga_insolvencia';
      vdeserror      VARCHAR2(100);
      esalir         EXCEPTION;
   BEGIN
      vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces, p_nombre,
                                                                 f_sysdate, NULL, 3,
                                                                 p_cproces, NULL, NULL);
      vtraza := 1;
      vnum_err := f_lre_ejecutarfichero(p_nombre, p_path, p_cproces, psproces);
      IF vnum_err <> 0 THEN
         vdeserror := 'Leyendo fichero: ' || p_nombre;
         RAISE esalir;
      END IF;
      vtraza := 2;
      vnum_err := f_lre_insolv_ejecutaproceso(psproces);
      vtraza := 3;
      UPDATE int_carga_ctrl
         SET cestado = vnum_err,
             ffin = f_sysdate
       WHERE sproces = psproces;
      vtraza := 4;
      DELETE      lre_personas
            WHERE NVL(cmarca, 0) = 0;
      vtraza := 5;
      RETURN 0;
   EXCEPTION
      WHEN esalir THEN
         p_genera_logs_g(vobj, vtraza, 'Error: ' || SQLCODE, SQLERRM, psproces,
                         'Error: ' || vdeserror);
         RETURN vnum_err;
      WHEN OTHERS THEN
         p_genera_logs_g(vobj, vtraza, 'Error: ' || SQLCODE, SQLERRM, psproces,
                         'Error: ' || SQLERRM);
         RETURN 1;
   END f_lre_carga_insolvencia;

   /*************************************************************************
   FUNCTION f_lre_insolv_ejecutaproceso
   Ejecurta la carga del archivo de listas restrictivas
   Retorna 1- Error, 2- correcto
   *************************************************************************/
   FUNCTION f_lre_insolv_ejecutaproceso(p_sproces IN NUMBER)
      RETURN NUMBER IS
      reglre         lre_personas%ROWTYPE;
      vcod           NUMBER;
      vexiste        detvalores.tatribu%TYPE;
      vtraza         NUMBER;
      vdeserror      VARCHAR2(1000);
      vobj           VARCHAR2(100) := 'pac_cargas_conf.f_lre_insolv_ejecutaproceso';
      verror         NUMBER;
   BEGIN
      vtraza := 1;
    DELETE lre_personas
    WHERE ctiplis = 62
    AND cclalis = 2;
      FOR cur_lre IN (SELECT *
                        FROM int_carga_lre
                       WHERE proceso = p_sproces) LOOP
         reglre := NULL;
         vtraza := 2;
         reglre.nnumide := cur_lre.nnumide;
         reglre.ctipide := f_buscavalor_g('TIPOIDEN_FICLISEXT', cur_lre.ctipide);
         reglre.ctiplis := cur_lre.clre;
         reglre.nordide := 0;
         reglre.cclalis := 2;
         reglre.ctipper := NULL;
         reglre.tnomape := cur_lre.tnomape;
         reglre.tnombre1 := NULL;
         reglre.tnombre2 := NULL;
         reglre.tapelli1 := NULL;
         reglre.tapelli2 := NULL;
         reglre.cnovedad := 1;
         reglre.cnotifi := NULL;
         IF reglre.ctiplis IS NULL THEN
            vcod := '105940';
            vdeserror := '';
            RAISE e_errdatos;
         ELSE
            vtraza := 3;
            BEGIN
               SELECT DISTINCT tatribu
                          INTO vexiste
                          FROM detvalores
                         WHERE cvalor = 800048
                           AND cidioma = kidiomaaaxis
                           AND catribu = reglre.ctiplis;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  vcod := '102844';
                  RAISE e_errdatos;
            END;
         END IF;
         vtraza := 4;
         SELECT MAX(sperlre), MAX(sperson)
           INTO reglre.sperlre, reglre.sperson
           FROM lre_personas
          WHERE nnumide = reglre.nnumide
            AND ctipide = reglre.ctipide
            AND nordide = reglre.nordide
            AND cclalis = reglre.cclalis
            AND ctiplis = reglre.ctiplis;
         IF reglre.sperson IS NULL THEN
            vtraza := 5;
            SELECT MAX(sperson)   -- Se busca primero por nmero de documento e identificador.
              INTO reglre.sperson
              FROM per_personas
             WHERE nnumide = reglre.nnumide
               AND ctipide = reglre.ctipide;
            IF reglre.sperson IS NULL THEN
               vtraza := 6;
               SELECT MAX(sperson)
                 INTO reglre.sperson
                 FROM per_detper
                WHERE UPPER(tnombre1 || ' ' || tnombre2 || ' ' || tapelli1 || ' ' || tapelli2) =
                                                                          UPPER(reglre.tnomape);
            END IF;
         END IF;
         IF reglre.sperson IS NOT NULL THEN
            vtraza := 7;
            SELECT p.nnumide, p.ctipide, dp.tnombre1, dp.tnombre2,
                   dp.tapelli1, dp.tapelli2,
                   dp.tnombre1 || ' ' || dp.tnombre2 || ' ' || dp.tapelli1 || ' '
                   || dp.tapelli2
              INTO reglre.nnumide, reglre.ctipide, reglre.tnombre1, reglre.tnombre2,
                   reglre.tapelli1, reglre.tapelli2,
                   reglre.tnomape
              FROM per_personas p JOIN per_detper dp ON p.sperson = dp.sperson
             WHERE p.sperson = reglre.sperson;
            vtraza := 7.1;
            verror := pac_marcas.f_set_marca_automatica(kempresa, reglre.sperson, '0113');  -- Marca Ley de insolvencia
            IF verror <> 0 THEN
               p_genera_logs_g(vobj, vtraza, 'Error: ', verror, p_sproces,
                               'Error: Actualizando marca Ley de insolvencia');
            END IF;
         END IF;
         IF reglre.sperlre IS NULL THEN
            SELECT sperlre.NEXTVAL
              INTO reglre.sperlre
              FROM DUAL;
            vtraza := 8;
            INSERT INTO lre_personas
                        (sperlre, nnumide, nordide, ctipide,
                         ctipper,
                         tnomape, tnombre1, tnombre2, tapelli1,
                         tapelli2, sperson, cnovedad, cnotifi,
                         cclalis, ctiplis, finclus, cusumod, cmarca)
                 VALUES (reglre.sperlre, reglre.nnumide, reglre.nordide, reglre.ctipide,
                         DECODE(reglre.ctipper,
                                NULL, DECODE(reglre.ctipide, 37, 2, 1),
                                reglre.ctipper),
                         reglre.tnomape, reglre.tnombre1, reglre.tnombre2, reglre.tapelli1,
                         reglre.tapelli2, reglre.sperson, reglre.cnovedad, reglre.cnotifi,
                         reglre.cclalis, reglre.ctiplis, f_sysdate, f_user, 1);
         ELSE
            vtraza := 9;
            UPDATE lre_personas
               SET cnovedad = 1,
                   fmodifi = f_sysdate,
                   fexclus = NULL,
                   sperson = reglre.sperson,
                   cmarca = 1
             WHERE sperlre = reglre.sperlre
               AND ctiplis = reglre.ctiplis;
         END IF;
      END LOOP;
      RETURN 2;
   EXCEPTION
      WHEN e_errdatos THEN
         p_genera_logs_g(vobj, vtraza, 'Error: ' || SQLCODE, SQLERRM, p_sproces,
                         'Error: ' || vdeserror);
         RETURN 1;
      WHEN OTHERS THEN
         p_genera_logs_g(vobj, vtraza, 'Error: ' || SQLCODE, SQLERRM, p_sproces,
                         'Error: ' || SQLERRM);
         RETURN 1;
   END f_lre_insolv_ejecutaproceso;

 /******************************************************************************
    NOMBRE:     p_setPersona_Cargar_CIFIN
    PROPOSITO:  Este funcion crear y actaulizar persona en iAxis caundo cargar archivo de CIFIN.
    PARAMETROS:
         return            : 0 -> Todo correcto
                             1 -> Se ha producido un error
  *****************************************************************************/

   PROCEDURE p_setPersona_Cargar_CIFIN(pRuta in varchar2,
                                       p_nombre in varchar2,
                                       p_cproces in number,
                                       p_sproces in number,
                                       pCountFail out number,
                                       pCountSuccess out number,
                                       perror  out number
                                      ) IS
    vcountCIFIN             number := 0;
    vnumerr                 NUMBER(8) := 0;
    vsperson                number;
    vmensajes               t_iax_mensajes;
    vcountPersona           number := 0;
    vsexper                 number := 0;
    vestper                 number := 0;
    vagente                 number;
    vtipide                 number;
    vsseguro                number;
    vcountContact           number := 0;
    vcountDireccion         number := 0;
    vcheckExistingPerson    number := 0;
    vnombreCargarCIFIN      VARCHAR2(500);
    vcargarCIFIN            UTL_FILE.file_type;
    vlinea                  VARCHAR2(200);
    vSFINANCI               number;
    vFConsti                date;
    vname                   VARCHAR2(500);
    vtsiglas                VARCHAR2(500) := null;
    videntificationNum      VARCHAR2(11);
    vcheckContactos         boolean := false;
    vcheckDireccions        boolean := false;
    vcheckCIIU              boolean := false;
    vcountFIN_ENDEUDAMIENTO number := 0;
    vcpostal                VARCHAR2(30);
    v_msg                   VARCHAR2(500);
    v_num_lin               number := 0;
    -- INI -IAXIS-5339 - 13/02/2020
    v_error_modelo          VARCHAR2(500):= null;
    -- FIN -IAXIS-5339 - 13/02/2020

    pCONTACTOS_PER  t_iax_contactos_per;
    pdireccions_per t_iax_direcciones;

    CURSOR cur_Cargar_CIFIN IS
      select * from cifin_intermedio_ext p;

  begin
    pCONTACTOS_PER := t_iax_contactos_per();
    pdireccions_per := t_iax_direcciones();

    select count(*) into vcountCIFIN from cifin_intermedio_ext;
    dbms_output.put_line('vcountCIFIN ::' || vcountCIFIN);

    vnombreCargarCIFIN := 'CargarCIFIN_Mal_Datao_' ||
                          TO_CHAR(f_sysdate, 'yyyymmdd_hh24miss') || '.txt';
    vcargarCIFIN       := UTL_FILE.fopen(pRuta, vnombreCargarCIFIN, 'w');
    vlinea             := 'IDENTIFICACION|NOMBRE|DESCRIPCION';
    UTL_FILE.put_line(vcargarCIFIN, vlinea);

    pCountFail :=0;
    pCountSuccess :=0;

    if vcountCIFIN > 0 then
      FOR i IN cur_Cargar_CIFIN LOOP
        -- Buscar persona existe o no
        vsperson := null;
        vagente  := null;
        vSFINANCI:= null;
        vFConsti := null;
        vtsiglas := null;
        vcountContact   := 0;
        vcountDireccion := 0;
        pCONTACTOS_PER.DELETE;
        pdireccions_per.DELETE;
        v_num_lin := v_num_lin + 1;

        if i.tipo_id = 1 then
          select count(*)
            into vcountPersona
            from per_personas p
           where p.nnumide = i.no_id;
        else
          select count(*)
            into vcountPersona
            from per_personas p
           where p.nnumide = i.no_id || i.digito_dq;
        end if;

        if vcountPersona > 0 then
          if i.tipo_id = 1 then
            select p.sperson, p.cagente
              into vsperson, vagente
              from per_personas p
             where p.nnumide = i.no_id;
          else
            select p.sperson, p.cagente
              into vsperson, vagente
              from per_personas p
             where p.nnumide = i.no_id || i.digito_dq;
          end if;

          select f.sfinanci, f.fconsti
            into vSFINANCI, vFConsti
            from fin_general f
           where f.sperson = vsperson
             and rownum = 1;

          if i.tipo_id = 1 then
            -- INI -IAXIS-5339 -13/02/2020. Se ajusta consulta con NVL XXX
            select count(*)
              into vcheckExistingPerson
              from per_detper d
             where upper(NVL(d.tapelli1,'XXX')) = upper(NVL(i.apellido1_dq,'XXX'))
               and upper(NVL(d.tapelli2,'XXX')) = upper(NVL(i.apellido2_dq,'XXX'))
               and upper(NVL(d.tnombre1,'XXX')) = upper(NVL(i.nombre1_dq,'XXX'))
               and upper(NVL(d.tnombre2,'XXX')) = upper(NVL(i.nombre2_dq,'XXX'))
               and d.sperson = vsperson;
            -- FIN -IAXIS-5339 -13/02/2020.
          else
            select count(*)
              into vcheckExistingPerson
              from per_detper d
	      -- INI -IAXIS-5339 -13/02/2020. Se ajusta consulta con NVL XXX
             where upper(NVL(d.tapelli1,'XXX')) = upper(NVL(i.razon_social,'XXX'))
	      -- FIN -IAXIS-5339 -13/02/2020. 
               and d.sperson = vsperson;
          end if;

          if vcheckExistingPerson = 0 then
            if i.tipo_id = 1 then
              vlinea := i.no_id || '|' || upper(i.apellido1_dq) ||' '|| upper(i.apellido2_dq) ||' '||
                        upper(i.nombre1_dq) ||' '|| upper(i.nombre2_dq) || '|NO COINCIDEN NOMBRES';
              UTL_FILE.put_line(vcargarCIFIN, vlinea);
            else
              vlinea := i.no_id || '|' || upper(i.razon_social) || '|NO COINCIDEN NOMBRES';
              UTL_FILE.put_line(vcargarCIFIN, vlinea);
            end if;
            pCountFail := pCountFail + 1;
            vnumerr  := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces   => p_sproces,
                                                                    pnlinea    => v_num_lin,
                                                                    pctipo     => 3,
                                                                    pidint     => v_num_lin,
                                                                    pidext     => v_num_lin,
                                                                    pcestado   => 5,
                                                                    pcvalidado => NULL,
                                                                    psseguro   => NULL,
                                                                    pidexterno => NULL,
                                                                    pncarga    => NULL,
                                                                    pnsinies   => NULL,
                                                                    pntramit   => NULL,
                                                                    psperson   => vsperson,
                                                                    pnrecibo   => NULL);
            CONTINUE;
          end if;
        end if;

        if i.celular_1 is null and i.celular_2 is null and
           i.celular_3 is null and i.correo_1 is null and
           i.correo_2 is null and i.correo_3 is null and
           i.telefono_1 is null and i.telefono_2 is null and
           i.telefono_3 is null then
          if i.tipo_id = 1 then
            vlinea := i.no_id || '|' || upper(i.apellido1_dq) ||' '|| upper(i.apellido2_dq) ||' '||
                        upper(i.nombre1_dq) ||' '|| upper(i.nombre2_dq) || '|FALTA CONTACTO';
            UTL_FILE.put_line(vcargarCIFIN, vlinea);
          else
            vlinea := i.no_id || '|' || upper(i.razon_social) || '|FALTA CONTACTO';
            UTL_FILE.put_line(vcargarCIFIN, vlinea);
          end if;
          vcheckContactos := true;
          pCountFail := pCountFail + 1;

          vnumerr  := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces   => p_sproces,
                                                                    pnlinea    => v_num_lin,
                                                                    pctipo     => 3,
                                                                    pidint     => v_num_lin,
                                                                    pidext     => v_num_lin,
                                                                    pcestado   => 5,
                                                                    pcvalidado => NULL,
                                                                    psseguro   => NULL,
                                                                    pidexterno => NULL,
                                                                    pncarga    => NULL,
                                                                    pnsinies   => NULL,
                                                                    pntramit   => NULL,
                                                                    psperson   => vsperson,
                                                                    pnrecibo   => NULL);
          CONTINUE;
        else
          vcheckContactos := false;
        end if;

        if i.direccion_1 is null and i.direccion_2 is null and
           i.direccion_3 is null then
          if i.tipo_id = 1 then
            vlinea := i.no_id || '|' || upper(i.apellido1_dq) ||' '|| upper(i.apellido2_dq) ||' '||
                        upper(i.nombre1_dq) ||' '|| upper(i.nombre2_dq) || '|FALTA DIRECCION';
            UTL_FILE.put_line(vcargarCIFIN, vlinea);
          else
            vlinea := i.no_id || '|' || upper(i.razon_social) || '|FALTA DIRECCION';
            UTL_FILE.put_line(vcargarCIFIN, vlinea);
          end if;
          vcheckDireccions := true;
          pCountFail := pCountFail + 1;

          vnumerr  := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces   => p_sproces,
                                                                    pnlinea    => v_num_lin,
                                                                    pctipo     => 3,
                                                                    pidint     => v_num_lin,
                                                                    pidext     => v_num_lin,
                                                                    pcestado   => 5,
                                                                    pcvalidado => NULL,
                                                                    psseguro   => NULL,
                                                                    pidexterno => NULL,
                                                                    pncarga    => NULL,
                                                                    pnsinies   => NULL,
                                                                    pntramit   => NULL,
                                                                    psperson   => vsperson,
                                                                    pnrecibo   => NULL);
          CONTINUE;
        else
          vcheckDireccions := false;
        end if;

        if i.codigo_ciiu is null then
          if i.tipo_id = 1 then
            vlinea := i.no_id || '|' || upper(i.apellido1_dq) ||' '|| upper(i.apellido2_dq) ||' '||
                        upper(i.nombre1_dq) ||' '|| upper(i.nombre2_dq) || '|FALTA CIIU';
            UTL_FILE.put_line(vcargarCIFIN, vlinea);
          else
            vlinea := i.no_id || '|' || upper(i.razon_social) || '|FALTA CIIU';
            UTL_FILE.put_line(vcargarCIFIN, vlinea);
          end if;
          vcheckCIIU := true;
          pCountFail := pCountFail + 1;

          vnumerr  := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces   => p_sproces,
                                                                    pnlinea    => v_num_lin,
                                                                    pctipo     => 3,
                                                                    pidint     => v_num_lin,
                                                                    pidext     => v_num_lin,
                                                                    pcestado   => 5,
                                                                    pcvalidado => NULL,
                                                                    psseguro   => NULL,
                                                                    pidexterno => NULL,
                                                                    pncarga    => NULL,
                                                                    pnsinies   => NULL,
                                                                    pntramit   => NULL,
                                                                    psperson   => vsperson,
                                                                    pnrecibo   => NULL);
          CONTINUE;
        else
          vcheckCIIU := false;
        end if;

        if vcheckContactos = false and vcheckDireccions = false and vcheckCIIU = false then
          if i.celular_1 is not null then
            vcountContact := vcountContact + 1;
            pcontactos_per.EXTEND;
            pcontactos_per(vcountContact) := OB_IAX_CONTACTOS_PER('',
                                                                  '',
                                                                  i.celular_1,
                                                                  '',
                                                                  '',
                                                                  '',
                                                                  '');
          end if;
          if i.celular_2 is not null then
            vcountContact := vcountContact + 1;
            pcontactos_per.EXTEND;
            pcontactos_per(vcountContact) := OB_IAX_CONTACTOS_PER('',
                                                                  '',
                                                                  i.celular_2,
                                                                  '',
                                                                  '',
                                                                  '',
                                                                  '');
          end if;
          if i.celular_3 is not null then
            vcountContact := vcountContact + 1;
            pcontactos_per.EXTEND;
            pcontactos_per(vcountContact) := OB_IAX_CONTACTOS_PER('',
                                                                  '',
                                                                  i.celular_3,
                                                                  '',
                                                                  '',
                                                                  '',
                                                                  '');
          end if;
          if i.correo_1 is not null then
            vcountContact := vcountContact + 1;
            pcontactos_per.EXTEND;
            pcontactos_per(vcountContact) := OB_IAX_CONTACTOS_PER('',
                                                                  '',
                                                                  '',
                                                                  '',
                                                                  i.correo_1,
                                                                  '',
                                                                  '');
          end if;
          if i.correo_2 is not null then
            vcountContact := vcountContact + 1;
            pcontactos_per.EXTEND;
            pcontactos_per(vcountContact) := OB_IAX_CONTACTOS_PER('',
                                                                  '',
                                                                  '',
                                                                  '',
                                                                  i.correo_2,
                                                                  '',
                                                                  '');
          end if;
          if i.correo_3 is not null then
            vcountContact := vcountContact + 1;
            pcontactos_per.EXTEND;
            pcontactos_per(vcountContact) := OB_IAX_CONTACTOS_PER('',
                                                                  '',
                                                                  '',
                                                                  '',
                                                                  i.correo_3,
                                                                  '',
                                                                  '');
          end if;
          if i.telefono_1 is not null then
            vcountContact := vcountContact + 1;
            pcontactos_per.EXTEND;
            pcontactos_per(vcountContact) := OB_IAX_CONTACTOS_PER(i.telefono_1,
                                                                  '',
                                                                  '',
                                                                  '',
                                                                  '',
                                                                  '',
                                                                  '');
          end if;
          if i.telefono_2 is not null then
            vcountContact := vcountContact + 1;
            pcontactos_per.EXTEND;
            pcontactos_per(vcountContact) := OB_IAX_CONTACTOS_PER(i.telefono_2,
                                                                  '',
                                                                  '',
                                                                  '',
                                                                  '',
                                                                  '',
                                                                  '');
          end if;
          if i.telefono_3 is not null then
            vcountContact := vcountContact + 1;
            pcontactos_per.EXTEND;
            pcontactos_per(vcountContact) := OB_IAX_CONTACTOS_PER(i.telefono_3,
                                                                  '',
                                                                  '',
                                                                  '',
                                                                  '',
                                                                  '',
                                                                  '');
          end if;

          if i.direccion_1 is not null and i.codigo_depto1_1 is not null and i.codigo_ciudad1_1 is not null then
            vcountDireccion := vcountDireccion + 1;
            pdireccions_per.EXTEND;
            begin
               vcpostal := null;
               select c.cpostal into vcpostal from codpostal c where c.cprovin =  i.codigo_depto1_1 and c.cpoblac = trunc(REPLACE(i.codigo_ciudad1_1,i.codigo_depto1_1,''));
            exception
            WHEN NO_DATA_FOUND THEN
              vcpostal := null;
            end;
            pdireccions_per(vcountDireccion) := ob_iax_direcciones('',
                                                                   '',
                                                                   vcpostal,
                                                                   i.codigo_depto1_1,
                                                                   '',
                                                                   trunc(REPLACE(i.codigo_ciudad1_1,i.codigo_depto1_1,'')),
                                                                   '',
                                                                   '170',
                                                                   '',
                                                                   '15',
                                                                   '',
                                                                   '',
                                                                   '',
                                                                   i.direccion_1,
                                                                   '',
                                                                   '',
                                                                   '',
                                                                   '',
                                                                   '',
                                                                   '',
                                                                   '',
                                                                   '',
                                                                   '',
                                                                   '',
                                                                   '',
                                                                   '',
                                                                   '',
                                                                   '',
                                                                   '',
                                                                   '',
                                                                   '',
                                                                   '',
                                                                   '',
                                                                   '',
                                                                   '',
                                                                   '',
                                                                   trunc(REPLACE(i.codigo_ciudad1_1,i.codigo_depto1_1,'')),
                                                                   '',
                                                                   trunc(REPLACE(i.codigo_ciudad1_1,i.codigo_depto1_1,'')),
                                                                   i.codigo_depto1_1);
          end if;
          if i.direccion_2 is not null and i.codigo_depto1_2 is not null and i.codigo_ciudad1_2 is not null then
            vcountDireccion := vcountDireccion + 1;
            pdireccions_per.EXTEND;
            begin
               vcpostal := null;
               select c.cpostal into vcpostal from codpostal c where c.cprovin =  i.codigo_depto1_2 and c.cpoblac = trunc(REPLACE(i.codigo_ciudad1_2,i.codigo_depto1_2,''));
            exception
            WHEN NO_DATA_FOUND THEN
              vcpostal := null;
            end;
            pdireccions_per(vcountDireccion) := ob_iax_direcciones('',
                                                                   '',
                                                                   vcpostal,
                                                                   i.codigo_depto1_2,
                                                                   '',
                                                                   trunc(REPLACE(i.codigo_ciudad1_2,i.codigo_depto1_2,'')),
                                                                   '',
                                                                   '170',
                                                                   '',
                                                                   '15',
                                                                   '',
                                                                   '',
                                                                   '',
                                                                   i.direccion_2,
                                                                   '',
                                                                   '',
                                                                   '',
                                                                   '',
                                                                   '',
                                                                   '',
                                                                   '',
                                                                   '',
                                                                   '',
                                                                   '',
                                                                   '',
                                                                   '',
                                                                   '',
                                                                   '',
                                                                   '',
                                                                   '',
                                                                   '',
                                                                   '',
                                                                   '',
                                                                   '',
                                                                   '',
                                                                   '',
                                                                   trunc(REPLACE(i.codigo_ciudad1_2,i.codigo_depto1_2,'')),
                                                                   '',
                                                                   trunc(REPLACE(i.codigo_ciudad1_2,i.codigo_depto1_2,'')),
                                                                   i.codigo_depto1_2);
          end if;
          if i.direccion_3 is not null and i.codigo_depto1_3 is not null and  i.codigo_ciudad1_3 is not null then
            vcountDireccion := vcountDireccion + 1;
            pdireccions_per.EXTEND;
            begin
               vcpostal := null;
               select c.cpostal into vcpostal from codpostal c where c.cprovin =  i.codigo_depto1_3 and c.cpoblac = trunc(REPLACE(i.codigo_ciudad1_3,i.codigo_depto1_3,''));
            exception
            WHEN NO_DATA_FOUND THEN
              vcpostal := null;
            end;
            pdireccions_per(vcountDireccion) := ob_iax_direcciones('',
                                                                   '',
                                                                   vcpostal,
                                                                   i.codigo_depto1_3,
                                                                   '',
                                                                   trunc(REPLACE(i.codigo_ciudad1_3,i.codigo_depto1_3,'')),
                                                                   '',
                                                                   '170',
                                                                   '',
                                                                   '15',
                                                                   '',
                                                                   '',
                                                                   '',
                                                                   i.direccion_3,
                                                                   '',
                                                                   '',
                                                                   '',
                                                                   '',
                                                                   '',
                                                                   '',
                                                                   '',
                                                                   '',
                                                                   '',
                                                                   '',
                                                                   '',
                                                                   '',
                                                                   '',
                                                                   '',
                                                                   '',
                                                                   '',
                                                                   '',
                                                                   '',
                                                                   '',
                                                                   '',
                                                                   '',
                                                                   '',
                                                                   trunc(REPLACE(i.codigo_ciudad1_3,i.codigo_depto1_3,'')),
                                                                   '',
                                                                   trunc(REPLACE(i.codigo_ciudad1_3,i.codigo_depto1_3,'')),
                                                                   i.codigo_depto1_3);

          end if;

          begin
            select t.sseguro
              into vsseguro
              from tomadores t
             where t.sperson = vsperson
               and rownum = 1; -- INI - IAXIS-5154 - SWAP - 09/09/2019 - Se incluye el rownum
          exception
            WHEN NO_DATA_FOUND THEN
              vsseguro := null;
          end;

          if i.tipo_id = 1 then
            begin
              select d.catribu
                into vsexper
                from DETVALORES d
               where upper(d.tatribu) =
                     upper(DECODE(i.genero,
                                  'MUJER',
                                  'Femenino',
                                  'Masculino'))
                 and d.cidioma = 8;
            exception
              WHEN NO_DATA_FOUND THEN
                vsexper := null;
            end;
            vname              := i.apellido1_dq;
            videntificationNum := i.no_id;
          else
            vname              := i.razon_social;
            vtsiglas           := vname;
            videntificationNum := i.no_id || i.digito_dq;
          end if;

          begin
            select d.catribu
              into vestper
              from DETVALORES d, homologacion_estado_cifin h
             where upper(d.cvalor) = 13
               and d.cidioma = 8
               and d.tatribu = h.valor_iaxis
               and h.valor_cifin = i.estado_dto;
          exception
            WHEN NO_DATA_FOUND THEN
              vestper := 0;
          end;

          if vagente is null then
            vagente := 19000;
          end if;

          IF i.tipo_id IN (1, 2, 3, 4, 5, 9, 10) THEN
            IF i.tipo_id = 1 THEN
              vtipide := 36;
            ELSIF i.tipo_id = 2 THEN
              vtipide := 37;
            ELSIF i.tipo_id = 3 THEN
              vtipide := 33;
            ELSIF i.tipo_id = 4 THEN
              vtipide := 34;
            ELSIF i.tipo_id = 5 THEN
              vtipide := 24;
            ELSIF i.tipo_id = 9 THEN
              vtipide := 35;
            ELSIF i.tipo_id = 10 THEN
              vtipide := 44;
            END IF;
          ELSE
              vtipide := null;
          END IF;

          vnumerr := pac_md_persona.f_set_persona(vsseguro,
                                                  vsperson,
                                                  vsperson,
                                                  vagente,
                                                  i.tipo_id,
                                                  vtipide,
                                                  videntificationNum,
                                                  vsexper,
                                                  NULL,
                                                  NULL,
                                                  vestper,
                                                  NULL,
                                                  NULL,
                                                  NULL,
                                                  NULL,
                                                  8,
                                                  vname,
                                                  i.apellido2_dq,
                                                  NULL,
                                                  vtsiglas,
                                                  NULL,
                                                  NULL,
                                                  170,
                                                  'POL',
                                                  0,
                                                  NULL,
                                                  i.nombre1_dq,
                                                  i.nombre2_dq,
                                                  0,
                                                  NULL,
                                                  NULL,
                                                  i.codigo_ciiu,
                                                  vSFINANCI,
                                                  vFConsti,
                                                  pCONTACTOS_PER,
                                                  pDIRECCIONS_PER,
                                                  170,
                                                  i.digito_dq,
                                                  vmensajes
                                                  /* CAMBIOS De IAXIS-4538 : Start */
                                                  ,NULL,
                                                  NULL,
                                                  NULL,
                                                  NULL
                                                 /* CAMBIOS De IAXIS-4538 : End */);

          begin
            select f.sfinanci
              into vSFINANCI
              from fin_general f
             where f.sperson = vsperson
               and rownum = 1;
          exception
            WHEN NO_DATA_FOUND THEN
              vSFINANCI := null;
          end;

          if vSFINANCI is not null then
            SELECT count(*)
              INTO vcountFIN_ENDEUDAMIENTO
              FROM FIN_ENDEUDAMIENTO
             WHERE sfinanci = vSFINANCI
             and trunc(fconsulta) = trunc(f_sysdate)
             AND cfuente = 1;

          DBMS_SESSION.set_nls('nls_numeric_characters', ''',.''');

            if vcountFIN_ENDEUDAMIENTO = 0 then
              INSERT INTO FIN_ENDEUDAMIENTO
                (sfinanci,
                 fconsulta,
                 cfuente,
                 iminimo,
                 icappag,
                 icapend,
                 iendtot,
                 ncalifa,
                 ncalifb,
                 ncalifc,
                 ncalifd,
                 ncalife,
                 nconsul,
                 nscore,
                 nmora,
                 nincump)
              VALUES
                (vSFINANCI,
                 trunc(f_sysdate),
                 1,
                 TO_NUMBER(trim(REPLACE(i.INGRESO_MIN_PROBABLE, '.', ','))),
                 TO_NUMBER(trim(REPLACE(i.CAPACIDAD_PAGO, '.', ','))),
                 TO_NUMBER(trim(REPLACE(i.CAPACIDAD_ENDEUDA, '.', ','))),
                 TO_NUMBER(trim(REPLACE(i.ENDEUDA_TOTAL_SFINANCIERO, '.', ','))),
                 TO_NUMBER(trim(REPLACE(i.SUMATORIA_CALIF_A, '.', ','))),
                 TO_NUMBER(trim(REPLACE(i.SUMATORIA_CALIF_B, '.', ','))),
                 TO_NUMBER(trim(REPLACE(i.SUMATORIA_CALIF_C, '.', ','))),
                 TO_NUMBER(trim(REPLACE(i.SUMATORIA_CALIF_D, '.', ','))),
                 TO_NUMBER(trim(REPLACE(i.SUMATORIA_CALIF_E, '.', ','))),
                 TO_NUMBER(trim(REPLACE(i.SUM_CON_ULT_6_MESES, '.', ','))),
                 TO_NUMBER(trim(REPLACE(i.PUNTAJE_SCORE, '.', ','))),
                 TO_NUMBER(trim(REPLACE(i.PROB_MORA, '.', ','))),
                 TO_NUMBER(trim(REPLACE(i.prob_incumplimiento, '.', ',')))
                 );
            else
              UPDATE FIN_ENDEUDAMIENTO
                 SET fconsulta = trunc(f_sysdate),
                     iminimo = TO_NUMBER(trim(REPLACE(i.INGRESO_MIN_PROBABLE, '.', ','))),
                     icappag = TO_NUMBER(trim(REPLACE(i.CAPACIDAD_PAGO, '.', ','))),
                     icapend = TO_NUMBER(trim(REPLACE(i.CAPACIDAD_ENDEUDA, '.', ','))),
                     iendtot = TO_NUMBER(trim(REPLACE(i.ENDEUDA_TOTAL_SFINANCIERO, '.', ','))),
                     ncalifa = TO_NUMBER(trim(REPLACE(i.SUMATORIA_CALIF_A, '.', ','))),
                     ncalifb = TO_NUMBER(trim(REPLACE(i.SUMATORIA_CALIF_B, '.', ','))),
                     ncalifc = TO_NUMBER(trim(REPLACE(i.SUMATORIA_CALIF_C, '.', ','))),
                     ncalifd = TO_NUMBER(trim(REPLACE(i.SUMATORIA_CALIF_D, '.', ','))),
                     ncalife = TO_NUMBER(trim(REPLACE(i.SUMATORIA_CALIF_E, '.', ','))),
                     nconsul = TO_NUMBER(trim(REPLACE(i.SUM_CON_ULT_6_MESES, '.', ','))),
                     nscore  = TO_NUMBER(trim(REPLACE(i.PUNTAJE_SCORE, '.', ','))),
                     nmora   = TO_NUMBER(trim(REPLACE(i.PROB_MORA, '.', ','))),
                     nincump = TO_NUMBER(trim(REPLACE(i.prob_incumplimiento, '.', ',')))
               WHERE sfinanci = vSFINANCI
               and trunc(fconsulta) = trunc(f_sysdate)
               AND cfuente = 1;
            end if;
          end if; /* if de vSFINANCI */

      -- INI - CJAD - 07/ENE2020 - IAXIS-5339 - Cargue en Batch CIFIN (para ficha financiera, automatización de cupos
      IF i.tipo_id = 1 THEN -- Solo para personas naturales
        DECLARE
          PCUPOSUG NUMBER;
          PCUPOGAR NUMBER;
          PCAPAFIN NUMBER;
          PCUPOSUGV1 NUMBER;
          PCUPOGARV1 NUMBER;
          PCAPAFINV1 NUMBER;
          PNCONTPOL NUMBER;
          PNANIOSVINC NUMBER;
          MENSAJES T_IAX_MENSAJES :=NULL;
        BEGIN
          vnumerr:=PAC_IAX_FINANCIERA.F_CALCULA_MODELO(vSFINANCI, NULL, 1, PCUPOSUG, PCUPOGAR,PCAPAFIN ,PCUPOSUGV1 ,PCUPOGARV1 ,PCAPAFINV1 ,PNCONTPOL ,PNANIOSVINC ,NULL, null, mensajes);
          if vnumerr= 0 then
            UPDATE fin_endeudamiento f
               SET f.icupos = PCUPOSUG
                  ,f.icupog = PCUPOGAR
             WHERE f.sfinanci = vSFINANCI
               AND trunc(f.fconsulta) = trunc(f_sysdate)
               AND f.cfuente = 1;
          ELSE
            v_error_modelo := f_axis_literales(9000464,pac_md_common.f_get_cxtidioma())||' - '||f_axis_literales(9909412,pac_md_common.f_get_cxtidioma());
          END IF; 
        END;
      END IF;
      -- FIN - CJAD - 07/ENE2020 - IAXIS-5339 - Cargue en Batch CIFIN (para ficha financiera, automatización de cupos


          if vnumerr > 0 then
            pCountFail := pCountFail + 1;
            rollback;
            if i.tipo_id = 1 then
              vlinea := i.no_id || '|' || upper(i.apellido1_dq) ||' '|| upper(i.apellido2_dq) ||' '||
                        upper(i.nombre1_dq) ||' '|| upper(i.nombre2_dq) || '|DATOS INVÁLIDOS';
            else
              vlinea := i.no_id || '|' || upper(i.razon_social) || '|DATOS INVÁLIDOS';
            end if;
            -- INI -IAXIS-5339 - 13/02/2020
            if v_error_modelo is not null then
              vlinea := vlinea||' '||v_error_modelo;
            end if;
            UTL_FILE.put_line(vcargarCIFIN, vlinea);
            -- FIN -IAXIS-5339 - 13/02/2020
            vnumerr  := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces   => p_sproces,
                                                                    pnlinea    => v_num_lin,
                                                                    pctipo     => 3,
                                                                    pidint     => v_num_lin,
                                                                    pidext     => v_num_lin,
                                                                    pcestado   => 5,
                                                                    pcvalidado => NULL,
                                                                    psseguro   => NULL,
                                                                    pidexterno => NULL,
                                                                    pncarga    => NULL,
                                                                    pnsinies   => NULL,
                                                                    pntramit   => NULL,
                                                                    psperson   => vsperson,
                                                                    pnrecibo   => NULL);
          else
            pCountSuccess := pCountSuccess + 1;
            commit;
            vnumerr  := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces   => p_sproces,
                                                                    pnlinea    => v_num_lin,
                                                                    pctipo     => 3,
                                                                    pidint     => v_num_lin,
                                                                    pidext     => v_num_lin,
                                                                    pcestado   => 4,
                                                                    pcvalidado => NULL,
                                                                    psseguro   => NULL,
                                                                    pidexterno => NULL,
                                                                    pncarga    => NULL,
                                                                    pnsinies   => NULL,
                                                                    pntramit   => NULL,
                                                                    psperson   => vsperson,
                                                                    pnrecibo   => NULL);
          end if;
        end if; /* if de verificar contacto y direccion */
      end loop; /* loop cuando tienes datos en cifin tabla */
    else
      dbms_output.put_line('Archivo no tiene datos para cargar.');
    end if; /* if de cuando tienes dataos en cifin tabla */

  if vcountCIFIN = (pCountSuccess+pCountFail) then
     perror := 0;
  else
     perror := 1;
  end if;
    /* Cerar archivo */
    IF UTL_FILE.is_open(vcargarCIFIN) THEN
      UTL_FILE.fclose(vcargarCIFIN);
    END IF;

  END p_setPersona_Cargar_CIFIN;
--INI SGM IAXIS 3482 PODER INGRESAR ACUERDOS DE PAGO, MASIVAMENTE Y TRAZAR
/*************************************************************************
FUNCTION f_anota_leearchivos_carga
Funcion para cargar la gestion de los outsourcing
*************************************************************************/
   FUNCTION f_leearchivos_acuerdo
      RETURN NUMBER IS
      vprefijo  varchar2(50):='ACUERDOSPAGO';
      varchivo  varchar2(100);
      v_file    UTL_FILE.file_type;
      v_sproces NUMBER;
      vnum_err  NUMBER;
      archivo_duplicado  NUMBER;
      duplicados         BOOLEAN:= False;

   BEGIN

       vnum_err := f_procesini(f_user, 24, '404', 'ACUERDOS_PAGO', v_sproces);

       FOR F IN 1..10 LOOP
            SELECT vprefijo||TO_CHAR(F_SYSDATE - 1,'DDMMYYYY')||LPAD(F,2,'0')||'.csv' 
              INTO varchivo
            FROM DUAL;
          
            BEGIN
            /*se verificaran uno a uno que ficheros hay en el directorio y se ira llamando la funcion para procesar cada uno.
            se acabara proceso cuando UTL_FILE.fopen trate de llamar un archivo que no est¿n directorio*/
                     -- Inicio: Lectura de fichero.
                    v_file := UTL_FILE.fopen('UTLDIR', varchivo, 'R');   --(UBICACION,NOMBRE,MODO APERTURA, MAX LINE SIZE)

                    UTL_FILE.fclose(v_file);--de nuevo lo cerramos, pero en este punto sabemos que existe en el directorio

                    /*llamamos la funcion que empieza a leer el archivo actual y realizar el proceso de carga en tablas
                      Esta funcion se llamara solo si el archivo no ha sido cargado previamente*/

                    BEGIN 
                        SELECT COUNT(*)
                        INTO archivo_duplicado
                        FROM int_agd_observaciones
                        WHERE fichero = varchivo;
                    END;

                    IF (archivo_duplicado = 0) THEN
                        vnum_err := f_anota_acuerdopag_carga(p_nombre => varchivo,
                                                             p_path => 'UTLDIR',
                                                             p_cproces => 406,
                                                             psproces => v_sproces);
                    ELSE
                        vnum_err := f_procesini(f_user, 24, '406', 'ACUERDOS DE PAGO Archivo duplicado, ver INT_AGD_OBSERVACIONES.FICHERO', v_sproces);
                        duplicados :=true;
                    END IF;

            EXCEPTION
                WHEN DUP_VAL_ON_INDEX THEN
                DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_backtrace);
                UTL_FILE.fclose(v_file);
                RETURN 9904284;
                -- Duplicated record
                WHEN VALUE_ERROR THEN
                DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_backtrace);
                --ROLLBACK;
                UTL_FILE.fclose(v_file);
                RETURN 9907933;
             -- Data Error. Check character length OR NUMBER format
                WHEN OTHERS THEN
                    IF duplicados THEN
                        RETURN 89906306;
                    END IF;    
                p_control_error('SGM','ya leyo todo','SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
                UTL_FILE.fclose(v_file);
                RETURN 103187;
      -- An error has occurred while reading the file
            END;            
       END LOOP;
       RETURN 0;
   END f_leearchivos_acuerdo;
/*************************************************************************
FUNCTION f_anota_acuerdopag_carga
Funcion para cargar anotaciones de acuerdos de pago masivamente
*************************************************************************/
   FUNCTION f_anota_acuerdopag_carga(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER)
      RETURN NUMBER IS
      vlin           NUMBER;
      vobj           VARCHAR2(200) := 'PAC_CARGAS_CONF.f_anota_acuerdopag_carga';
      vpar           VARCHAR2(2000)
         := 'p_nombre=' || p_nombre || 'p_path=' || p_path || ' p_cproces=' || p_cproces
            || 'psproces= ' || psproces;
      vnum_err       NUMBER := 0;
   BEGIN
      vnum_err := pac_cargas_conf.f_anota_acuerdopag_cargafic(p_nombre, p_path, p_cproces,
                                                                 psproces);
      --
      IF vnum_err <> 0 THEN
         RAISE e_param_error;
      END IF;

      vlin := 2;
      --
      -- Inicio IAXIS-2418 28/02/2019
      --
      vnum_err := pac_cargas_conf.f_anota_acuerdopag_ejecproc(psproces);
      --
      -- Fin IAXIS-2418 28/02/2019
      --
      --
      UPDATE int_carga_ctrl
         SET cestado = vnum_err,
             ffin = f_sysdate
       WHERE sproces = psproces;

      --
      COMMIT;
      --
      RETURN 0;
   --
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobj, vlin, vpar, SQLCODE);
         RETURN 1;
      WHEN e_object_error THEN
         p_tab_error(f_sysdate, f_user, vobj, vlin, vpar, SQLCODE);
         RETURN 1;
      WHEN OTHERS THEN
         DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_backtrace);
         p_tab_error(f_sysdate, f_user, vobj, vlin, vpar, SQLCODE);
         RETURN 1;
   END f_anota_acuerdopag_carga;
   /*************************************************************************
   FUNCTION f_anota_acuerdopag_cargafic
   *************************************************************************/
   FUNCTION f_anota_acuerdopag_cargafic(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'pac_cargas_conf.f_anota_acuerdopag_cargafic';
      vnum_err       NUMBER := 0;
      v_line         VARCHAR2(32767);
      v_file         UTL_FILE.file_type;
      v_numlineaf    NUMBER := 0; -- IAXIS-2418 28/02/2019
      -- Numero de linea del fichero
      -- Numero de linea del insert
      errorini       EXCEPTION;
      errorcarga     EXCEPTION;
      e_errdatos     EXCEPTION;
      -- Formato Ingls
      v_sep          VARCHAR2(1) := ';';
      v_currfield    VARCHAR2(64);
      v_nrecibo      NUMBER;
      v_ttitobs      VARCHAR2(100);
      v_tobs         VARCHAR2(500);
      v_fanotacion   DATE;

      vlin           NUMBER;
      vidobs         NUMBER;
   --   vincvidobs     NUMBER:=0;
      -- Inicio IAXIS-2418 28/02/2019
      vncarga        NUMBER := f_next_carga_g;
      -- Fin IAXIS-2418 28/02/2019
      vpar           VARCHAR2(2000)
         := 'p_nombre=' || p_nombre || 'p_path=' || p_path || ' p_cproces=' || p_cproces
            || 'psproces= ' || psproces;

      PROCEDURE p_controlar_error(p_traza NUMBER, p_estado NUMBER, v_msg VARCHAR2) IS
      BEGIN
         vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces, p_nombre,
                                                                    f_sysdate, NULL, p_estado,
                                                                    p_cproces, NULL, v_msg);

         IF vnum_err <> 0 THEN
            -- Si fallan esta funciones de gestin salimos del programa
            p_tab_error(f_sysdate, f_user, vobj, p_traza, vnum_err,
                        'Error llamando pac_gestion_procesos.f_set_carga_ctrl_cabecera'
                        || p_traza);
            RAISE errorini;
         END IF;
      END p_controlar_error;
   BEGIN

      SELECT sproces.NEXTVAL
        INTO psproces
        FROM DUAL;

      IF p_cproces IS NULL THEN
         vnum_err := 9901092;
         RAISE e_errdatos;
      END IF;

      p_controlar_error(2, 3, NULL);

      BEGIN
         -- Inicio: Lectura de fichero.
         v_file := UTL_FILE.fopen(p_path, p_nombre, 'R', 256);   --(UBICACION,NOMBRE,MODO APERTURA, MAX LINE SIZE)

         LOOP
            EXIT WHEN v_numlineaf = -1;

            BEGIN
            --   vincvidobs:=vincvidobs+1;
               v_numlineaf := v_numlineaf + 1;
               UTL_FILE.get_line(v_file, v_line, 32767);
               DBMS_OUTPUT.put_line(v_line);

               IF (v_numlineaf > 0) THEN -- IAXIS-2418 28/02/2019
                  -- A partir de la Segona
                  -- Incio IAXIS-2418 28/02/2019
                  v_line := REPLACE(REPLACE(v_line, chr(10), ''), chr(13), '');
                  -- Fin IAXIS-2418 28/02/2019
                  v_currfield := 'NRECIBO';
                  v_nrecibo := pac_util.splitt(v_line, 1, v_sep);  --VSEP SEPARADOR
                  v_currfield := 'TTITOBS';
                  v_ttitobs := pac_util.splitt(v_line, 2, v_sep);
                  v_currfield := 'TOBS';
                  v_tobs := pac_util.splitt(v_line, 3, v_sep);
                  v_currfield := 'FANOTACION';
                  v_fanotacion := TO_DATE(pac_util.splitt(v_line, 4, v_sep), 'DD/MM/YYYY');
                  /*v_currfield := 'FFINCAM';
                  v_ffincam := TO_DATE(pac_util.splitt(v_line, 5, v_sep), 'DD/MM/YYYY');
                  v_currfield := 'IMETA';
                  v_imeta := pac_util.splitt(v_line, 6, v_sep);
                  -- Incio IAXIS-2418 28/02/2019
                  v_currfield := 'IPRODUCCION';
                  v_iproduccion := pac_util.splitt(v_line, 7, v_sep);
                  v_currfield := 'IRECAUDO';
                  v_irecaudo := pac_util.splitt(v_line, 8, v_sep);*/
                     --
                     -- Se realiza insercin de datos sobre tabla externa int_carga_campaage
                     --
                  IF vidobs IS NULL THEN
                     BEGIN
                        SELECT NVL(MAX(idobs), 1) + 1 
                          INTO vidobs
                          FROM AGD_OBSERVACIONES;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           vidobs := 1;
                     END;
                  ELSE
                     vidobs:= vidobs + 1;
                  END IF;                        
                   --  vidobs:= vidobs + vincvidobs;
--   CCONOBS 38 (TÍTULO APUNTE:CARTERA/ACUERDO DE PAGO) Siempre se cargaran masivamente las anotaciones de este tipo
--   CTIPAGD 2  (TIPO DE AGENDA: RECIBO) Siempre se cargaran masivamente las anotaciones de este tipo
                     INSERT INTO INT_AGD_OBSERVACIONES
                       (proceso, nlinea, ncarga, cempres, idobs,
                        cconobs,ctipobs,ttitobs,tobs,fobs,
                        ctipagd,nrecibo,publico,cusualt,falta,fichero)
                     VALUES
                        (psproces, v_numlineaf, vncarga, pac_md_common.f_get_cxtempresa, vidobs,
                            38,1,v_ttitobs,v_tobs, v_fanotacion,
                            2, v_nrecibo,1,f_user, f_sysdate,p_nombre);

                  vnum_err :=
                     pac_gestion_procesos.f_set_carga_ctrl_linea(psproces => psproces,
                                                                 pnlinea => v_numlineaf,
                                                                 pctipo => 20,
                                                                 pidint => v_numlineaf,
                                                                 pidext => v_numlineaf,
                                                                 pcestado => 4,
                                                                 pcvalidado => NULL,
                                                                 psseguro => NULL,
                                                                 pidexterno => NULL,
                                                                 pncarga => NULL,
                                                                 pnsinies => NULL,
                                                                 pntramit => NULL,
                                                                 psperson => NULL,
                                                                 pnrecibo => NULL);
                  --
                  COMMIT;
               --
               END IF;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  -- No hay mas datos para leer.
                  v_numlineaf := -1;
               WHEN OTHERS THEN
                  -- Inicio IAXIS-2418 28/02/2019
                  -- Traza de errores por lnea
                  --p_controlar_error(2, 3, NULL);
                  vnum_err :=
                     pac_gestion_procesos.f_set_carga_ctrl_linea(psproces => psproces,
                                                                 pnlinea => v_numlineaf,
                                                                 pctipo => 20,
                                                                 pidint => v_numlineaf,
                                                                 pidext => v_numlineaf,
                                                                 pcestado => 4,
                                                                 pcvalidado => NULL,
                                                                 psseguro => NULL,
                                                                 pidexterno => NULL,
                                                                 pncarga => NULL,
                                                                 pnsinies => NULL,
                                                                 pntramit => NULL,
                                                                 psperson => NULL,
                                                                 pnrecibo => NULL);
                  p_error_linea_g(psproces, NULL, v_numlineaf,
                                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
                  -- Fin IAXIS-2418 28/02/2019
            END;
         END LOOP;

         UTL_FILE.fclose(v_file);
         RETURN 0;
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_backtrace);
            ROLLBACK;
            UTL_FILE.fclose(v_file);
            p_controlar_error(5, 1,
                              f_axis_literales(9904284, pac_md_common.f_get_cxtidioma())
                              || ' at line ' || v_numlineaf);
            RETURN 9904284;
         -- Duplicated record
         WHEN VALUE_ERROR THEN
            DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_backtrace);
            ROLLBACK;
            UTL_FILE.fclose(v_file);
            p_controlar_error(6, 1,
                              f_axis_literales(9907933, pac_md_common.f_get_cxtidioma())
                              || ' at line ' || v_numlineaf || ', field: ' || v_currfield);
            RETURN 9907933;
         -- Data Error. Check character length OR NUMBER format
         WHEN OTHERS THEN
            DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_backtrace);
            ROLLBACK;
            UTL_FILE.fclose(v_file);
            p_controlar_error(7, 1, f_axis_literales(103187, pac_md_common.f_get_cxtidioma()));
            RETURN 103187;
      -- An error has occurred while reading the file
      END;
   EXCEPTION
      WHEN e_errdatos THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, vobj, vlin, vpar, SQLCODE || CHR(10) || vnum_err);
         DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_backtrace);
         RETURN vnum_err;
      WHEN errorini THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, vobj, vlin, vpar, SQLCODE || CHR(10) || vnum_err);
         DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_backtrace);
         RETURN 108953;
   -- A runtime error has occurred
   END f_anota_acuerdopag_cargafic;

   /*************************************************************************
   FUNCTION f_campana_ejecutarproceso
   Ejecuta la carga del archivo de campaas de agentes
   Retorna 1- Error, 2- correcto
   *************************************************************************/
   FUNCTION f_anota_acuerdopag_ejecproc(p_sproces IN NUMBER)
      RETURN NUMBER IS
      ragenda        AGD_OBSERVACIONES%ROWTYPE;
      vcod           NUMBER;
      vexiste        detvalores.tatribu%TYPE;
      vtraza         NUMBER;
      vdeserror      VARCHAR2(1000);
      vobj           VARCHAR2(100) := 'pac_cargas_conf.f_anota_acuerdopag_ejecproc';
      verror         NUMBER;
   BEGIN
     --
     vtraza := 1;
     --
     FOR cur_agenda IN (SELECT i.*
                            FROM int_agd_observaciones i
                            WHERE proceso = p_sproces) LOOP
       BEGIN
         --
         vtraza := 2;
         --
         ragenda.cempres := cur_agenda.cempres;
         ragenda.idobs := cur_agenda.idobs;
         ragenda.cconobs := cur_agenda.cconobs;
         ragenda.ctipobs := cur_agenda.ctipobs;
         ragenda.ttitobs := cur_agenda.ttitobs;
         ragenda.tobs   := cur_agenda.tobs;
         ragenda.fobs := cur_agenda.fobs;
         ragenda.ctipagd := cur_agenda.ctipagd;
         ragenda.nrecibo := cur_agenda.nrecibo;
         ragenda.publico := cur_agenda.publico;
         ragenda.cusualt   := cur_agenda.cusualt;
         ragenda.falta := cur_agenda.falta;
         --
         vtraza := 3;
         --
         INSERT INTO agd_observaciones VALUES ragenda;
         commit;
         --
         vtraza := 4;
         --
       EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
           --
           vtraza := 5;
           --
           UPDATE agd_observaciones
              SET 
         cempres = ragenda.cempres,
         idobs = ragenda.idobs,
         cconobs = ragenda.cconobs,
         ctipobs = ragenda.ctipobs,
         ttitobs = ragenda.ttitobs,
         tobs   = ragenda.tobs,
         fobs = ragenda.fobs,
         ctipagd = ragenda.ctipagd,
         nrecibo = ragenda.nrecibo,
         publico = ragenda.publico,
         cusualt   = ragenda.cusualt,
         falta = ragenda.falta
            WHERE idobs = ragenda.idobs;
           --
           vtraza := 6;
           --
       END;
     --
       BEGIN
           INSERT INTO AGD_MOVOBS (CEMPRES,IDOBS,NMOVOBS,CESTOBS,FESTOBS,CUSUALT,FALTA,TOBS)
           VALUES (ragenda.cempres,ragenda.idobs,1,0,ragenda.fobs,ragenda.cusualt,ragenda.falta,ragenda.tobs);
       EXCEPTION
         WHEN OTHERS THEN  
         p_genera_logs_g(vobj, vtraza, 'Error: ' || SQLCODE, SQLERRM, p_sproces,
         'Error: ' || SQLERRM);
         RETURN 1;
       END;


     END LOOP;
   --
   RETURN 2;
   EXCEPTION
      WHEN OTHERS THEN
         p_genera_logs_g(vobj, vtraza, 'Error: ' || SQLCODE, SQLERRM, p_sproces,
                         'Error: ' || SQLERRM);
         RETURN 1;
   END f_anota_acuerdopag_ejecproc;

--FIN SGM IAXIS 3482 PODER INGRESAR ACUERDOS DE PAGO, MASIVAMENTE Y TRAZAR   


  /* Cambios de IAXIS-3562 : Starts */

  FUNCTION F_PROCESO_DATSARLAF(PSPROCES IN NUMBER, P_CPROCES IN NUMBER)
    RETURN NUMBER IS
    VOBJ   VARCHAR2(100) := 'pac_cargas_conf.f_proceso_datsarlaf';
    VTRAZA NUMBER := 0;
    ERRORINI EXCEPTION;
    V_TFICHERO INT_CARGA_CTRL.TFICHERO%TYPE;
    VNUM_ERR   NUMBER;
    V_DUMMY    NUMBER := 0;
    VTIPERR    NUMBER := 0;
    VERROR     NUMBER;
    VTERROR    VARCHAR2(4000);
    V_IDIOMA   NUMBER;
    V_SPROCES  NUMBER;
    V_NUMERR   NUMBER := 0;
  BEGIN

    VTRAZA   := 0;
    V_IDIOMA := K_IDIOMAAAXIS;

    IF PSPROCES IS NULL THEN
      VNUM_ERR := 9000505;
      PAC_CARGAS_CONF.P_GENERA_LOGS(VOBJ,
                                    VTRAZA,
                                    'Error:' || VNUM_ERR,
                                    'Parmetro psproces obligatorio.',
                                    PSPROCES,
                                    F_AXIS_LITERALES(VNUM_ERR, V_IDIOMA) || ':' ||
                                    V_TFICHERO || ' : ' || VNUM_ERR);
      RAISE ERRORINI;
    END IF;

    VTRAZA := 1;

    RETURN 0;
  EXCEPTION
    WHEN ERRORINI THEN
      ROLLBACK;
      PAC_CARGAS_CONF.P_GENERA_LOGS(VOBJ,
                                    VTRAZA,
                                    'Error:' || 'ErrorIni' || ' en :' ||
                                    VNUM_ERR,
                                    'Error:' ||
                                    'Insertando estados registros',
                                    PSPROCES,
                                    F_AXIS_LITERALES(108953, V_IDIOMA) || ':' ||
                                    V_TFICHERO || ' : ' || 'errorini'); --NEED TO CHANGE MSG
      VNUM_ERR := F_PROCESFIN(V_SPROCES, 1);
      COMMIT;
      RETURN 1;
    WHEN OTHERS THEN
      ROLLBACK;
      PAC_CARGAS_CONF.P_GENERA_LOGS(VOBJ,
                                    VTRAZA,
                                    'Error:' || VNUM_ERR,
                                    SQLERRM,
                                    PSPROCES,
                                    F_AXIS_LITERALES(103187, V_IDIOMA) || ':' ||
                                    V_TFICHERO || ' : ' || SQLERRM); --NEED TO CHANGE MSG
      VNUM_ERR := PAC_GESTION_PROCESOS.F_SET_CARGA_CTRL_CABECERA(PSPROCES,
                                                                 V_TFICHERO,
                                                                 F_SYSDATE,
                                                                 NULL,
                                                                 1,
                                                                 P_CPROCES,
                                                                 151541,
                                                                 SQLERRM); --NEED TO CHANGE MSG

      IF VNUM_ERR <> 0 THEN
        PAC_CARGAS_CONF.P_GENERA_LOGS(VOBJ,
                                      VTRAZA,
                                      VNUM_ERR,
                                      'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera2',
                                      PSPROCES,
                                      F_AXIS_LITERALES(180856, V_IDIOMA) || ':' ||
                                      V_TFICHERO || ' : ' || VNUM_ERR); --NEED TO CHANGE MSG
        RAISE ERRORINI;
      END IF;

      VNUM_ERR := F_PROCESFIN(V_SPROCES, 1);
      COMMIT;
      RETURN 1;
  END F_PROCESO_DATSARLAF;

  FUNCTION F_CARGA_DATSARLAF_J(P_NOMBRE  IN VARCHAR2,
                               P_PATH    IN VARCHAR2,
                               P_CPROCES IN NUMBER,
                               PSPROCES  IN OUT NUMBER) RETURN NUMBER IS
    VOBJ     VARCHAR2(100) := 'pac_cargas_conf';
    VTRAZA   NUMBER := 0;
    VNUM_ERR NUMBER;
    VSALIR EXCEPTION;
  BEGIN
    VTRAZA := 0;

    SELECT NVL(CPARA_ERROR, 0)
      INTO K_PARA_CARGA
      FROM CFG_FILES
     WHERE CEMPRES = K_EMPRESAAXIS
       AND CPROCESO = P_CPROCES;

    IF PSPROCES IS NULL THEN
      VNUM_ERR := PAC_CARGAS_CONF.F_EJECUTAR_CARGA_DATASARLAF_J(P_NOMBRE,
                                                                P_PATH,
                                                                P_CPROCES,
                                                                PSPROCES);

      IF VNUM_ERR <> 0 THEN
        RAISE VSALIR;
      END IF;
    END IF;

    VTRAZA   := 1;
    VNUM_ERR := PAC_CARGAS_CONF.F_PROCESO_DATSARLAF(PSPROCES, P_CPROCES);

    IF VNUM_ERR <> 0 THEN
      RAISE VSALIR;
    ELSE
      VNUM_ERR := PAC_GESTION_PROCESOS.F_SET_CARGA_CTRL_CABECERA(PSPROCES,
                                                                 P_NOMBRE,
                                                                 NULL,
                                                                 F_SYSDATE,
                                                                 4,
                                                                 P_CPROCES,
                                                                 0,
                                                                 NULL);
      VNUM_ERR := F_PROCESFIN(PSPROCES, 0);
    END IF;

    RETURN 0;
  EXCEPTION
    WHEN VSALIR THEN
      RETURN 1;
  END F_CARGA_DATSARLAF_J;

/* Cambios de IAXIS-4732 : Starts */  
  FUNCTION F_MODI_DATSARLAF_J_EXT(P_NOMBRE VARCHAR2) RETURN NUMBER IS
    V_TNOMFICH VARCHAR2(100);
  BEGIN
    V_TNOMFICH := SUBSTR(P_NOMBRE, 1, INSTR(P_NOMBRE, '.') - 1);

    EXECUTE IMMEDIATE 'alter table Datos_Sarlaf_j_Ext ACCESS PARAMETERS (records delimited by 0x''0A''
                   logfile ' || CHR(39) || V_TNOMFICH ||
                      '.log' || CHR(39) || '
                   badfile ' || CHR(39) || V_TNOMFICH ||
                      '.bad' || CHR(39) || '
                   discardfile ' || CHR(39) ||
                      V_TNOMFICH || '.dis' || CHR(39) || '
                   fields terminated by ''|'' lrtrim
                   MISSING FIELD VALUES ARE NULL
                   REJECT ROWS WITH ALL NULL FIELDS
                   (
                      itomador,
                      ntomador,
                      fecha_dilimiento_cb,
                      departamento_cb,
                      ciudad_cb,
                      sucursal_cb,
                      tipo_solicitud_cb,
                      clase_vin_cb,
                      clase_otro_cb,
                      residencia_sociedad_cb,
                      tomador_aseg_cb,
                      asegurado_otro_cb,
                      tomador_bene_cb,
                      beneficiario_otro_cb,
                      asegu_beneficiario_cb,
                      beneficiario_ase_otro_cb,
                      nrazon_social_ib,
                      tipo_documento_ib,
                      nit_ib,
                      dv_ib,
                      tipo_empresa_ib,
                      ciiu_acti_economica_ib,
                      ciiu_cod_ib,
                      sector_ib,
                      direccion_oficina_ib,
                      pais_oficina_ib,
                      dep_oficina_ib,
                      ciudad_oficina_ib,
                      telefono_oficina_ib,
                      email_ib,
                      pais_sucursal_ib,
                      depart_sucursal_ib,
                      ciudad_sucursal_ib,
                      direccion_sucursal_ib,
                      telefono_sucursal_ib,
                      primer_apellido_rl,
                      segundo_apellido_rl,
                      legal_nombres_rl,
                      tipo_rl,
                      numero_rl,
                      fecha_exp_rl,
                      pais_exped_rl,
                      depart_exped_rl,
                      lugar_exp_rl,
                      fecha_naci_rl,
                      pais_lugar_naci_rl,
                      depart_lugar_naci_rl,
                      lugar_naci_rl,
                      naci_1rl,
                      naci_2rl,
                      email_rl,
                      direccion_resid_rl,
                      pais_resid_rl,
                      departamento_resid_rl,
                      ciudad_resid_rl,
                      telefono_rl,
                      celular_rl,
                      algunos_rl,
                      por_cargo_rl,
                      es_usted_rl,
                      indique_cual_rl,
                      a1_tipo_id,
                      a1_numero_id,
                      a1_nombres,
                      a1_participacion,
                      a1_espersona,
                      a1_per_publicam,
                      a1_sujeto,
                      a2_tipo_id,
                      a2_numero_id,
                      a2_nombres,
                      a2_participacion,
                      a2_espersona,
                      a2_per_publicam,
                      a2_sujeto,
                      a3_tipo_id,
                      a3_numero_id,
                      a3_nombres,
                      a3_participacion,
                      a3_espersona,
                      a3_per_publicam,
                      a3_sujeto,
                      a4_tipo_id,
                      a4_numero_id,
                      a4_nombres,
                      a4_participacion,
                      a4_espersona,
                      a4_per_publicam,
                      a4_sujeto,
                      a5_tipo_id,
                      a5_numero_id,
                      a5_nombres,
                      a5_participacion,
                      a5_espersona,
                      a5_per_publicam,
                      a5_sujeto,
                      vinculo1_relacion_pep,
                      nombre1_completo_pep,
                      tipo1_identificacion_pep,
                      numero1_identificacion_pep,
                      nacionalidad1_pep,
                      entidad1_pep,
                      cargo1_pep,
                      fecha1_desvinculacion_pep,
                      vinculo2_relacion_pep,
                      nombre2_completo_pep,
                      tipo2_identificacion_pep,
                      numero2_identificacion_pep,
                      nacionalidad2_pep,
                      entidad2_pep,
                      cargo2_pep,
                      fecha2_desvinculacion_pep,
                      vinculo3_relacion_pep,
                      nombre3_completo_pep,
                      tipo3_identificacion_pep,
                      numero3_identificacion_pep,
                      nacionalidad3_pep,
                      entidad3_pep,
                      cargo3_pep,
                      fecha3_desvinculacion_pep,
                      vinculo4_relacion_pep,
                      nombre4_completo_pep,
                      tipo4_identificacion_pep,
                      numero4_identificacion_pep,
                      nacionalidad4_pep,
                      entidad4_pep,
                      cargo4_pep,
                      fecha4_desvinculacion_pep,
                      numero1_id_bf,
                      nombres1_bf,
                      nombre1_razonsocial_bf,
                      tipo1_id_bf,
                      id1_bf,
                      participacion1_bf,
                      numero2_id_bf,
                      nombres2_bf,
                      nombre2_razonsocial_bf,
                      tipo2_id_bf,
                      id2_bf,
                      participacion2_bf,
                      numero3_id_bf,
                      nombres3_bf,
                      nombre3_razonsocial_bf,
                      tipo3_id_bf,
                      id3_bf,
                      participacion3_bf,
                      numero4_id_bf,
                      nombres4_bf,
                      nombre4_razonsocial_bf,
                      tipo4_id_bf,
                      id4_bf,
                      participacion4_bf,
                      ingr_mensuales_if,
                      egr_mensuales_if,
                      activos_if,
                      pasivos_if,
                      patrimonio_if,
                      otros_ingresos_if,
                      con_otros_ing_if,
                      declaracion_fondos_df,
                      realiza_transacciones_oi,
                      si_cual_oi,
                      otras_indi_oi,
                      posee_productos_oi,
                      poseee_cuentas_oi,
                      tipo_producto_ai,
                      iden_numero_producto_ai,
                      entidad_ai,
                      monto_ai,
                      pais_ai,
                      departamento_ai,
                      ciudad_ai,
                      moneda_ai,
                      ha_present_rs,
                      ano_rs,
                      ramo_rs,
                      compania_rs,
                      valor_rs,
                      resultado_rs,
                      autoriza_1_ca,
                      autoriza_2_ca,
                      estado_confirmacion_cf,
                      fecha_confirmacion_cf,
                     	fecha_entrevista_ie,
		                  resultado_ie
                  ))';
    EXECUTE IMMEDIATE 'ALTER TABLE DATOS_SARLAF_J_EXT LOCATION (''' ||
                      P_NOMBRE || ''')';
    RETURN 0;
  EXCEPTION
    WHEN OTHERS THEN
      P_TAB_ERROR(F_SYSDATE,
                  F_USER,
                  'pac_cargas_conf.f_modi_datsarlaf_J_ext',
                  1,
                  'Error creando la tabla.',
                  SQLERRM);
      RETURN 107914; -- NEED TO ADD NEW MSG
  END F_MODI_DATSARLAF_J_EXT;
/* Cambios de IAXIS-4732 : Ends */    


/* Cambios de IAXIS-4732 : Starts */  
  PROCEDURE P_TRASP_TABLA_DS_J(PDESERROR OUT VARCHAR2, PSPROCES IN NUMBER) IS
    NUM_ERR   NUMBER;
    V_PASEXEC NUMBER := 1;
    VPARAM    VARCHAR2(1) := NULL;
    VOBJ      VARCHAR2(200) := 'pac_cargas_conf.p_trasp_tabla_ds_j';
    V_NUMERR  NUMBER := 0;
    ERRGRABARPROV  EXCEPTION;
    E_OBJECT_ERROR EXCEPTION;
    V_LINEA      NUMBER := 0;
    V_IDCARGA    NUMBER := 0;
    V_DESC_CARGA VARCHAR2(50) := NULL;

    V_EXISTE_ENDEUDA NUMBER := 0;
    V_EXISTE_SFIANCI NUMBER := 0;
    V_SFINANCI       NUMBER := 0;
    v_numlin         DATOS_SARLAF_J.nlinea%TYPE;
  BEGIN
    V_PASEXEC := 0;
    PDESERROR := NULL;

    SELECT NVL(MAX(ID_CARGA + 1), 1) INTO V_IDCARGA FROM DATOS_SARLAF_J;

    SELECT NVL(MAX(nlinea), 0)
      INTO v_numlin
      FROM DATOS_SARLAF_J
     WHERE proceso = psproces;

    V_DESC_CARGA := 'CARGA DATOS SARLAF JURIDICA';

    INSERT INTO DATOS_SARLAF_J
      (SELECT psproces,
              ROWNUM + v_numlin,
              V_IDCARGA,
              V_DESC_CARGA,
              F_SYSDATE,
              itomador,
              ntomador,
              fecha_dilimiento_cb,
              departamento_cb,
              ciudad_cb,
              sucursal_cb,
              tipo_solicitud_cb,
              clase_vin_cb,
              clase_otro_cb,
              residencia_sociedad_cb,
              tomador_aseg_cb,
              asegurado_otro_cb,
              tomador_bene_cb,
              beneficiario_otro_cb,
              asegu_beneficiario_cb,
              beneficiario_ase_otro_cb,
              nrazon_social_ib,
              tipo_documento_ib,
              nit_ib,
              dv_ib,
              tipo_empresa_ib,
              ciiu_acti_economica_ib,
              ciiu_cod_ib,
              sector_ib,
              direccion_oficina_ib,
              pais_oficina_ib,
              dep_oficina_ib,
              ciudad_oficina_ib,
              telefono_oficina_ib,
              email_ib,
              pais_sucursal_ib,
              depart_sucursal_ib,
              ciudad_sucursal_ib,
              direccion_sucursal_ib,
              telefono_sucursal_ib,
              primer_apellido_rl,
              segundo_apellido_rl,
              legal_nombres_rl,
              tipo_rl,
              numero_rl,
              fecha_exp_rl,
              pais_exped_rl,
              depart_exped_rl,
              lugar_exp_rl,
              fecha_naci_rl,
              pais_lugar_naci_rl,
              depart_lugar_naci_rl,
              lugar_naci_rl,
              naci_1rl,
              naci_2rl,
              email_rl,
              direccion_resid_rl,
              pais_resid_rl,
              departamento_resid_rl,
              ciudad_resid_rl,
              telefono_rl,
              celular_rl,
              algunos_rl,
              por_cargo_rl,
              es_usted_rl,
              indique_cual_rl,
              a1_tipo_id,
              a1_numero_id,
              a1_nombres,
              a1_participacion,
              a1_espersona,
              a1_per_publicam,
              a1_sujeto,
              a2_tipo_id,
              a2_numero_id,
              a2_nombres,
              a2_participacion,
              a2_espersona,
              a2_per_publicam,
              a2_sujeto,
              a3_tipo_id,
              a3_numero_id,
              a3_nombres,
              a3_participacion,
              a3_espersona,
              a3_per_publicam,
              a3_sujeto,
              a4_tipo_id,
              a4_numero_id,
              a4_nombres,
              a4_participacion,
              a4_espersona,
              a4_per_publicam,
              a4_sujeto,
              a5_tipo_id,
              a5_numero_id,
              a5_nombres,
              a5_participacion,
              a5_espersona,
              a5_per_publicam,
              a5_sujeto,
              vinculo1_relacion_pep,
              nombre1_completo_pep,
              tipo1_identificacion_pep,
              numero1_identificacion_pep,
              nacionalidad1_pep,
              entidad1_pep,
              cargo1_pep,
              fecha1_desvinculacion_pep,
              vinculo2_relacion_pep,
              nombre2_completo_pep,
              tipo2_identificacion_pep,
              numero2_identificacion_pep,
              nacionalidad2_pep,
              entidad2_pep,
              cargo2_pep,
              fecha2_desvinculacion_pep,
              vinculo3_relacion_pep,
              nombre3_completo_pep,
              tipo3_identificacion_pep,
              numero3_identificacion_pep,
              nacionalidad3_pep,
              entidad3_pep,
              cargo3_pep,
              fecha3_desvinculacion_pep,
              vinculo4_relacion_pep,
              nombre4_completo_pep,
              tipo4_identificacion_pep,
              numero4_identificacion_pep,
              nacionalidad4_pep,
              entidad4_pep,
              cargo4_pep,
              fecha4_desvinculacion_pep,
              numero1_id_bf,
              nombres1_bf,
              nombre1_razonsocial_bf,
              tipo1_id_bf,
              id1_bf,
              participacion1_bf,
              numero2_id_bf,
              nombres2_bf,
              nombre2_razonsocial_bf,
              tipo2_id_bf,
              id2_bf,
              participacion2_bf,
              numero3_id_bf,
              nombres3_bf,
              nombre3_razonsocial_bf,
              tipo3_id_bf,
              id3_bf,
              participacion3_bf,
              numero4_id_bf,
              nombres4_bf,
              nombre4_razonsocial_bf,
              tipo4_id_bf,
              id4_bf,
              participacion4_bf,
              ingr_mensuales_if,
              egr_mensuales_if,
              activos_if,
              pasivos_if,
              patrimonio_if,
              otros_ingresos_if,
              con_otros_ing_if,
              declaracion_fondos_df,
              realiza_transacciones_oi,
              si_cual_oi,
              otras_indi_oi,
              posee_productos_oi,
              poseee_cuentas_oi,
              tipo_producto_ai,
              iden_numero_producto_ai,
              entidad_ai,
              monto_ai,
              pais_ai,
              departamento_ai,
              ciudad_ai,
              moneda_ai,
              ha_present_rs,
              ano_rs,
              ramo_rs,
              compania_rs,
              valor_rs,
              resultado_rs,
              autoriza_1_ca,
              autoriza_2_ca,
              estado_confirmacion_cf,
              fecha_confirmacion_cf,
              fecha_entrevista_ie,
              resultado_ie              
         FROM DATOS_SARLAF_J_EXT);
    V_PASEXEC := 8;
    COMMIT;
  EXCEPTION
    WHEN E_OBJECT_ERROR THEN
      ROLLBACK;

      IF PDESERROR IS NULL THEN
        PDESERROR := F_AXIS_LITERALES(108953, K_IDIOMAAAXIS); -- NEED TO ADD DIFFERENT MSG
      END IF;

      NULL;
    WHEN OTHERS THEN
      ROLLBACK;
      PDESERROR := F_AXIS_LITERALES(103187, K_IDIOMAAAXIS) || SQLERRM; -- NEED TO ADD DIFFERENT MSG
      P_TAB_ERROR(F_SYSDATE, F_USER, VOBJ, V_PASEXEC, SQLCODE, SQLERRM);
      RAISE;
  END P_TRASP_TABLA_DS_J;
/* Cambios de IAXIS-4732 : Ends */  

  FUNCTION F_EJECUTAR_CARGA_DATASARLAF_J(P_NOMBRE  IN VARCHAR2,
                                         P_PATH    IN VARCHAR2,
                                         P_CPROCES IN NUMBER,
                                         PSPROCES  OUT NUMBER) RETURN NUMBER IS
    VOBJ      VARCHAR2(100) := 'f_ejecutar_carga_datasarlaf_J';
    LINEA     NUMBER := 0;
    PCARGA    NUMBER;
    SENTENCIA VARCHAR2(32000);
    VFICHERO  UTL_FILE.FILE_TYPE;
    VTRAZA    NUMBER := 0;
    VERROR    NUMBER;
    VDESERROR VARCHAR2(1000);
    V_SPROCES NUMBER;
    ERRORINI EXCEPTION;
    VNUM_ERR NUMBER;
    VSALIR EXCEPTION;
    VNNUMLIN   NUMBER;
    VSINPROC   BOOLEAN := TRUE;
    VERRORFIN  BOOLEAN := FALSE;
    VAVISFIN   BOOLEAN := FALSE;
    VTIPERR    NUMBER;
    VCODERROR  NUMBER;
    N_IMP      NUMBER;
    V_DESERROR INT_CARGA_CTRL_LINEA_ERRS.TMENSAJE%TYPE;
    E_ERRDATOS EXCEPTION;

    VNUM_ERR_CARGAR_DSJ NUMBER;
    VNUM_COUNTFAIL      NUMBER;
    VNUM_COUNTSUCCESS   NUMBER;

  BEGIN
    VTRAZA   := 0;
    VSINPROC := TRUE;
    VNUM_ERR := F_PROCESINI(F_USER,
                            K_EMPRESAAXIS,
                            'CARGA_DATSAR_JURIDIC',
                            P_NOMBRE,
                            V_SPROCES);

    IF VNUM_ERR <> 0 THEN
      RAISE ERRORINI;
    END IF;

    PSPROCES := V_SPROCES;
    VTRAZA   := 1;

    IF P_CPROCES IS NULL THEN
      VNUM_ERR  := 9901092; -- NEED TO ADD DIFFERENT MSG
      VDESERROR := 'cfg_files falta proceso: ' || VOBJ;
      RAISE E_ERRDATOS;
    END IF;

    VTRAZA   := 11;
    VNUM_ERR := PAC_GESTION_PROCESOS.F_SET_CARGA_CTRL_CABECERA(V_SPROCES,
                                                               P_NOMBRE,
                                                               F_SYSDATE,
                                                               NULL,
                                                               3,
                                                               P_CPROCES,
                                                               NULL,
                                                               NULL);
    VTRAZA   := 12;

    IF VNUM_ERR <> 0 THEN
      P_TAB_ERROR(F_SYSDATE,
                  F_USER,
                  VOBJ,
                  VTRAZA,
                  VNUM_ERR,
                  'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera');
      VNUM_ERR := F_PROCESLIN(V_SPROCES,
                              F_AXIS_LITERALES(180856, K_IDIOMAAAXIS) || ':' ||
                              P_NOMBRE || ' : ' || VNUM_ERR,
                              1,
                              VNNUMLIN); -- NEED TO ADD DIFFERENT MSG
      RAISE ERRORINI;
    END IF;

    COMMIT;
    VTRAZA := 2;

    VNUM_ERR := F_MODI_DATSARLAF_J_EXT(P_NOMBRE);

    IF VNUM_ERR <> 0 THEN
      P_TAB_ERROR(F_SYSDATE,
                  F_USER,
                  VOBJ,
                  VTRAZA,
                  VNUM_ERR,
                  'Error creando la tabla externa');
      VNUM_ERR := F_PROCESLIN(V_SPROCES,
                              F_AXIS_LITERALES(VNUM_ERR, K_IDIOMAAAXIS) || ':' ||
                              P_NOMBRE || ' : ' || VNUM_ERR,
                              1,
                              VNNUMLIN);
      RAISE ERRORINI;
    END IF;

    VTRAZA := 53;
    IF VNUM_ERR = 0 THEN
      BEGIN
        P_CARGA_DATSARLAF_J(P_PATH,
                            P_NOMBRE,
                            P_CPROCES,
                            V_SPROCES,
                            VNUM_COUNTFAIL,
                            VNUM_COUNTSUCCESS,
                            VNUM_ERR_CARGAR_DSJ);
        IF VNUM_ERR_CARGAR_DSJ <> 0 THEN
          P_TAB_ERROR(F_SYSDATE,
                      F_USER,
                      VOBJ,
                      VTRAZA,
                      VNUM_ERR_CARGAR_DSJ,
                      'Cargar archivo de datsarlaf juridica : Funciona :' ||
                      VNUM_COUNTSUCCESS || ' : No Funciona :' ||
                      VNUM_COUNTFAIL);

          VNUM_ERR := F_PROCESLIN(V_SPROCES,
                                  F_AXIS_LITERALES(VNUM_ERR_CARGAR_DSJ,
                                                   K_IDIOMAAAXIS) || ':' ||
                                  P_NOMBRE || ' : ' || VNUM_ERR_CARGAR_DSJ,
                                  1,
                                  VNNUMLIN);
          RAISE ERRORINI;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          P_TAB_ERROR(F_SYSDATE,
                      F_USER,
                      VOBJ,
                      VTRAZA,
                      VNUM_COUNTFAIL,
                      'Error en cargar archivo de datsarlaf juridica : Funciona :' ||
                      VNUM_COUNTSUCCESS || ' : No Funciona :' ||
                      VNUM_COUNTFAIL);
      END;
    END IF;

    P_TRASP_TABLA_DS_J(VDESERROR, V_SPROCES);
    VTRAZA := 3;

    IF VDESERROR IS NOT NULL THEN
      VTRAZA   := 5;
      VNUM_ERR := PAC_GESTION_PROCESOS.F_SET_CARGA_CTRL_CABECERA(V_SPROCES,
                                                                 P_NOMBRE,
                                                                 F_SYSDATE,
                                                                 NULL,
                                                                 1,
                                                                 P_CPROCES,
                                                                 NULL,
                                                                 VDESERROR);
      VTRAZA   := 51;

      IF VNUM_ERR <> 0 THEN
        P_TAB_ERROR(F_SYSDATE,
                    F_USER,
                    VOBJ,
                    VTRAZA,
                    VNUM_ERR,
                    'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera2');
        VNNUMLIN := NULL;
        VNUM_ERR := F_PROCESLIN(V_SPROCES,
                                F_AXIS_LITERALES(180856, K_IDIOMAAAXIS) || ':' ||
                                P_NOMBRE || ' : ' || VNUM_ERR,
                                1,
                                VNNUMLIN); -- NEED TO ADD DIFFERENT MSG
        RAISE ERRORINI;
      END IF;

      VTRAZA := 52;
      COMMIT;
      RAISE VSALIR;
    END IF;

    COMMIT;
    RETURN 0;
  EXCEPTION
    WHEN VSALIR THEN
      NULL;
      RETURN 1;
    WHEN E_ERRDATOS THEN
      ROLLBACK;
      PAC_CARGAS_CONF.P_GENERA_LOGS(VOBJ,
                                    VTRAZA,
                                    'Error:' || VNUM_ERR,
                                    VDESERROR,
                                    PSPROCES,
                                    'Error:' || VNUM_ERR || ' ' ||
                                    VDESERROR);
      COMMIT;
      RETURN 1;
    WHEN ERRORINI THEN
      ROLLBACK;
      P_TAB_ERROR(F_SYSDATE,
                  F_USER,
                  VOBJ,
                  VTRAZA,
                  'Error:' || 'ErrorIni' || ' en :' || 1,
                  'Error:' || 'Insertando estados registros');
      VNUM_ERR := F_PROCESLIN(V_SPROCES,
                              F_AXIS_LITERALES(108953, K_IDIOMAAAXIS) || ':' ||
                              P_NOMBRE || ' : ' || 'errorini',
                              1,
                              VNNUMLIN); -- NEED TO CHANGE MSG
      COMMIT;
      RETURN 1;
    WHEN OTHERS THEN
      ROLLBACK;

      P_TAB_ERROR(F_SYSDATE,
                  F_USER,
                  VOBJ,
                  VTRAZA,
                  'Error:' || SQLERRM || ' en :' || 1,
                  'Error:' || SQLERRM);
      VNUM_ERR := F_PROCESLIN(V_SPROCES,
                              F_AXIS_LITERALES(103187, K_IDIOMAAAXIS) || ':' ||
                              P_NOMBRE || ' : ' || SQLERRM,
                              1,
                              VNNUMLIN); -- NEED TO CHANGE MSG
      VNUM_ERR := PAC_GESTION_PROCESOS.F_SET_CARGA_CTRL_CABECERA(V_SPROCES,
                                                                 P_NOMBRE,
                                                                 F_SYSDATE,
                                                                 NULL,
                                                                 1,
                                                                 P_CPROCES,
                                                                 151541,
                                                                 SQLERRM); -- NEED TO CHANGE MSG
      VTRAZA   := 51;

      IF VNUM_ERR <> 0 THEN
        P_TAB_ERROR(F_SYSDATE,
                    F_USER,
                    VOBJ,
                    VTRAZA,
                    VNUM_ERR,
                    'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera2');
        VNNUMLIN := NULL;
        VNUM_ERR := F_PROCESLIN(V_SPROCES,
                                F_AXIS_LITERALES(180856, K_IDIOMAAAXIS) || ':' ||
                                P_NOMBRE || ' : ' || VNUM_ERR,
                                1,
                                VNNUMLIN); -- NEED TO CHANGE MSG
      END IF;

      COMMIT;
      RETURN 1;
  END F_EJECUTAR_CARGA_DATASARLAF_J;

  PROCEDURE P_CARGA_DATSARLAF_J(PRUTA         IN VARCHAR2,
                                P_NOMBRE      IN VARCHAR2,
                                P_CPROCES     IN NUMBER,
                                P_SPROCES     IN NUMBER,
                                PCOUNTFAIL    OUT NUMBER,
                                PCOUNTSUCCESS OUT NUMBER,
                                PERROR        OUT NUMBER) IS

    VCOUNTDSJ NUMBER := 0;
    VNUMERR   NUMBER(8) := 0;
    VMENSAJES T_IAX_MENSAJES;

    VNOMBRECARGARDSJ VARCHAR2(500);
    VCARGARDSJ       UTL_FILE.FILE_TYPE;
    VLINEA           VARCHAR2(200);
    VSPERSON         PER_PERSONAS.SPERSON%TYPE;
    VSSARLAFT        DATSARLATF.SSARLAFT%TYPE;
    V_MSG            VARCHAR2(500);
    V_NUM_LIN        NUMBER := 0;

    VTPROVIN PROVINCIAS.TPROVIN%TYPE;
    VTPOBLAC POBLACIONES.TPOBLAC%TYPE;

    VTVINCULACION   DETVALORES.TATRIBU%TYPE;
    VCVINCULACION   DATSARLATF.CVINCULACION%TYPE;
    VRESOCIEDAD     DATSARLATF.RESOCIEDAD%TYPE := NULL;
    VCVINTOMASE     DATSARLATF.CVINTOMASE%TYPE := NULL;
    VCVINTOMBEN     DATSARLATF.CVINTOMBEN%TYPE := NULL;
    VCVINASEBEN     DATSARLATF.CVINASEBEN%TYPE := NULL;
    VCLASE_VIN      VARCHAR2(200) := NULL;
    VIDENTIFICACION NUMBER := NULL;
    VNACTIVI_DSACT  NUMBER := NULL;

    VTPAIS PAISES.TPAIS%TYPE;
    VCPAIS PAISES.CPAIS%TYPE;

    VIDENTIFICACION_PEP SARLATFPEP.IDENTIFICACION%TYPE;
    VIDENTIFICACION_BEN SARLATFBEN.IDENTIFICACION%TYPE;
    VIDENTIFICACION_ACT DETSARLATF_ACT.NACTIVI%TYPE;
    VNRECLA             DETSARLAFT_REC.NRECLA%TYPE;

    VTPAIS_OFICINA PAISES.TPAIS%TYPE;
    VTPAIS_SUR     PAISES.TPAIS%TYPE;

    VTPROVIN_IN_1_IB PROVINCIAS.TPROVIN%TYPE;
    VTPOBLAC_IN_1_IB POBLACIONES.TPOBLAC%TYPE;
    VTPROVIN_IN_2_IB PROVINCIAS.TPROVIN%TYPE;
    VTPOBLAC_IN_2_IB POBLACIONES.TPOBLAC%TYPE;

    VTNACIONALIDAR1_RL PAISES.TPAIS%TYPE;
    VTNACIONALIDAR2_RL PAISES.TPAIS%TYPE;

    VTPAIS_LUGAR_RL PAISES.TPAIS%TYPE;
    VTLUGAR_EXP_RL  POBLACIONES.TPOBLAC%TYPE;
    VTLUGAR_NACI_RL POBLACIONES.TPOBLAC%TYPE;

    VTPAIS_DEPART_RL PAISES.TPAIS%TYPE;
    VTDEPART_EXP_RL  PROVINCIAS.TPROVIN%TYPE;
    VTDEPART_NACI_RL PROVINCIAS.TPROVIN%TYPE;

    VTPAIS_RESID_RL   PAISES.TPAIS%TYPE;
    VTDEPART_RESID_RL PROVINCIAS.TPROVIN%TYPE;
    VTCIUDAD_RESID_RL POBLACIONES.TPOBLAC%TYPE;

    VTSUCURSAL DATSARLATF.TSUCURSAL%TYPE;
    VCSUCURSAL DATSARLATF.CSUCURSAL%TYPE;

    VPASEXEC NUMBER(8) := 0;
    VPARAM   VARCHAR2(500) := 'parametros - Cargar Juridica : ';
    VOBJECT  VARCHAR2(200) := 'pac_cargas_conf.p_carga_Datsarlaf_J';

    CURSOR CUR_CARGAR_DATSARLF_J IS
      SELECT * FROM DATOS_SARLAF_J_EXT;

  BEGIN
    SELECT COUNT(*) INTO VCOUNTDSJ FROM DATOS_SARLAF_J_EXT;
    DBMS_OUTPUT.PUT_LINE('vcountDSJ ::' || VCOUNTDSJ);

    VNOMBRECARGARDSJ := 'Cargar_DSJ_Mal_Datao_' ||
                        TO_CHAR(F_SYSDATE, 'yyyymmdd_hh24miss') || '.txt';

    VCARGARDSJ := UTL_FILE.FOPEN(PRUTA, VNOMBRECARGARDSJ, 'w');
    VLINEA     := 'IDENTIFICACION|NOMBRE|DESCRIPCION';
    UTL_FILE.PUT_LINE(VCARGARDSJ, VLINEA);

    PCOUNTFAIL    := 0;
    PCOUNTSUCCESS := 0;

    IF VCOUNTDSJ > 0 THEN
      FOR I IN CUR_CARGAR_DATSARLF_J LOOP
        V_NUM_LIN := V_NUM_LIN + 1;

        begin
          SELECT P.SPERSON
            INTO VSPERSON
            FROM PER_PERSONAS P
           WHERE P.NNUMIDE LIKE '%' || i.itomador || '%'
       AND ROWNUM = 1;
        exception
          when no_data_found then
            VSPERSON := null;
        end;

        IF VSPERSON IS NOT NULL THEN

          begin
            SELECT D.SSARLAFT
              INTO VSSARLAFT
              FROM DATSARLATF D
             WHERE D.FDILIGENCIA =
                   (SELECT MAX(FDILIGENCIA)
                      FROM DATSARLATF
                     WHERE SPERSON = VSPERSON)
               AND D.SPERSON = VSPERSON
         AND ROWNUM = 1;
          exception
            when no_data_found then
              VSSARLAFT := null;
          end;

          IF VSSARLAFT IS NULL THEN
            SELECT SSARLAFT.NEXTVAL INTO VSSARLAFT FROM DUAL;
          END IF;

          -- CABECERA
          VPASEXEC := 1;
          begin
            if i.Departamento_cb is not null then
              SELECT P.TPROVIN
                INTO VTPROVIN
                FROM PROVINCIAS P
               WHERE P.Cprovin = i.Departamento_cb
                 AND ROWNUM = 1;
            else
              VTPROVIN := null;
            end if;
          exception
            when no_data_found then
              VTPROVIN := null;
          end;

          begin
            if i.ciudad_cb is not null then
              SELECT P.TPOBLAC
                INTO VTPOBLAC
                FROM POBLACIONES P
               WHERE P.CPOBLAC = i.ciudad_cb
                 and P.Cprovin = i.Departamento_cb
                 AND ROWNUM = 1;
            else
              VTPOBLAC := null;
            end if;
          exception
            when no_data_found then
              VTPOBLAC := null;
          end;

          begin
            SELECT D.TATRIBU
              INTO VTVINCULACION
              FROM DETVALORES D
             WHERE D.CIDIOMA = 8
               AND D.CATRIBU = I.TIPO_SOLICITUD_CB
               AND D.CVALOR = 790001;
          exception
            when no_data_found then
              VTVINCULACION := null;
          end;

          begin
			/* Cambios de IAXIS-4732 : Starts */
            if i.sucursal_cb is not null then
              SELECT F_DESAGENTE_T(PAC_AGENTES.F_GET_CAGELIQ(24, 2, R.CAGENTE)) TSUCURSAL,
                     R.CAGENTE CSUCURSAL
                INTO VTSUCURSAL, VCSUCURSAL
                FROM REDCOMERCIAL R
               WHERE R.CTIPAGE = 2
                 AND R.CAGENTE LIKE '%' || i.sucursal_cb || '%'
                 AND ROWNUM = 1;
            else
              VTSUCURSAL := null;
              VCSUCURSAL := null;
            end if;                 
          exception
            when no_data_found then
             begin
               SELECT F_DESAGENTE_T(PAC_AGENTES.F_GET_CAGELIQ(24,
                                                              3,
                                                              R.CAGENTE)) TSUCURSAL,
                      R.CAGENTE CSUCURSAL
                 INTO VTSUCURSAL, VCSUCURSAL
                 FROM REDCOMERCIAL R
                WHERE R.CTIPAGE = 3
                  AND R.CAGENTE LIKE '%' || i.sucursal_cb || '%'
                  AND ROWNUM = 1;
             exception
               when no_data_found then
                 VTSUCURSAL := null;
                 VCSUCURSAL := null;
             end;
            /* Cambios de IAXIS-4732 : Ends */             
          end;

          IF I.CLASE_OTRO_CB IS NULL THEN
            IF UPPER(I.CLASE_VIN_CB) = UPPER('Tomador') THEN
              VCVINCULACION := 1;
            ELSIF UPPER(I.CLASE_VIN_CB) = UPPER('Beneficiario') THEN
              VCVINCULACION := 2;
            ELSIF UPPER(I.CLASE_VIN_CB) = UPPER('Proveedor') THEN
              VCVINCULACION := 3;
            ELSIF UPPER(I.CLASE_VIN_CB) = UPPER('Asegurado') THEN
              VCVINCULACION := 4;
            ELSIF UPPER(I.CLASE_VIN_CB) = UPPER('Afianzado') THEN
              VCVINCULACION := 5;
            ELSIF UPPER(I.CLASE_VIN_CB) = UPPER('Intermediario') THEN
              VCVINCULACION := 6;
            ELSE
              VCVINCULACION := 7;
            END IF;
          ELSE
            VCLASE_VIN := NULL;
          END IF;

          IF UPPER(I.RESIDENCIA_SOCIEDAD_CB) = UPPER('Nacional') THEN
            VRESOCIEDAD := 1;
          ELSE
            VRESOCIEDAD := 2;
          END IF;

          IF UPPER(I.ASEGURADO_OTRO_CB) IS NULL THEN
            IF UPPER(I.TOMADOR_ASEG_CB) = UPPER('Familiar') THEN
              VCVINTOMASE := 1;
            ELSIF UPPER(I.TOMADOR_ASEG_CB) = UPPER('Comercial') THEN
              VCVINTOMASE := 2;
            ELSIF UPPER(I.TOMADOR_ASEG_CB) = UPPER('Laboral') THEN
              VCVINTOMASE := 3;
            END IF;
          ELSE
            VCVINTOMASE := 4;
          END IF;

          IF UPPER(I.BENEFICIARIO_OTRO_CB) IS NULL THEN
            IF UPPER(I.TOMADOR_BENE_CB) = UPPER('Familiar') THEN
              VCVINTOMBEN := 1;
            ELSIF UPPER(I.TOMADOR_BENE_CB) = UPPER('Comercial') THEN
              VCVINTOMBEN := 2;
            ELSIF UPPER(I.TOMADOR_BENE_CB) = UPPER('Laboral') THEN
              VCVINTOMBEN := 3;
            END IF;
          ELSE
            VCVINTOMBEN := 4;
          END IF;

          IF UPPER(I.BENEFICIARIO_ASE_OTRO_CB) IS NULL THEN
            IF UPPER(I.ASEGU_BENEFICIARIO_CB) = UPPER('Familiar') THEN
              VCVINASEBEN := 1;
            ELSIF UPPER(I.ASEGU_BENEFICIARIO_CB) = UPPER('Comercial') THEN
              VCVINASEBEN := 2;
            ELSIF UPPER(I.ASEGU_BENEFICIARIO_CB) = UPPER('Laboral') THEN
              VCVINASEBEN := 3;
            END IF;
          ELSE
            VCVINASEBEN := 4;
          END IF;

          -- INFORMATION BASICA
          VPASEXEC := 2;

          begin
            if i.pais_oficina_ib is not null then
              SELECT P.TPAIS
                INTO VTPAIS_OFICINA
                FROM paises P
               WHERE P.Cpais = i.pais_oficina_ib
                 AND ROWNUM = 1;
            else
              VTPAIS_OFICINA := null;
            end if;
          exception
            when no_data_found then
              VTPAIS_OFICINA := null;
          end;

          begin
            if i.dep_oficina_ib is not null then
              SELECT P.TPROVIN
                INTO VTPROVIN_IN_1_IB
                FROM PROVINCIAS P
               WHERE P.CPROVIN = i.dep_oficina_ib
                 AND ROWNUM = 1;
            else
              VTPROVIN_IN_1_IB := null;
            end if;
          exception
            when no_data_found then
              VTPROVIN_IN_1_IB := null;
          end;

          begin
            if i.ciudad_oficina_ib is not null then
              SELECT P.TPOBLAC
                INTO VTPOBLAC_IN_1_IB
                FROM POBLACIONES P
               WHERE P.CPOBLAC = i.ciudad_oficina_ib
                 and P.Cprovin = i.dep_oficina_ib 
                 AND ROWNUM = 1;
            else
              VTPOBLAC_IN_1_IB := null;
            end if;
          exception
            when no_data_found then
              VTPOBLAC_IN_1_IB := null;
          end;

          begin
            if i.pais_sucursal_ib is not null then
              SELECT P.TPAIS
                INTO VTPAIS_SUR
                FROM paises P
               WHERE P.Cpais = i.pais_sucursal_ib
                 AND ROWNUM = 1;
            else
              VTPAIS_SUR := null;
            end if;
          exception
            when no_data_found then
              VTPAIS_SUR := null;
          end;

          begin
            if i.depart_sucursal_ib is not null then
              SELECT P.TPROVIN
                INTO VTPROVIN_IN_2_IB
                FROM PROVINCIAS P
               WHERE P.CPROVIN = i.depart_sucursal_ib
                 AND ROWNUM = 1;
            else
              VTPROVIN_IN_2_IB := null;
            end if;
          exception
            when no_data_found then
              VTPROVIN_IN_2_IB := null;
          end;

          begin
            if i.ciudad_sucursal_ib is not null then
              SELECT P.TPOBLAC
                INTO VTPOBLAC_IN_2_IB
                FROM POBLACIONES P
               WHERE P.CPOBLAC = i.ciudad_sucursal_ib
                 and P.Cprovin = i.depart_sucursal_ib 
                 AND ROWNUM = 1;
            else
              VTPOBLAC_IN_2_IB := null;
            end if;
          exception
            when no_data_found then
              VTPOBLAC_IN_2_IB := null;
          end;

          -- REPRESENTANTE LEGAL
          VPASEXEC := 3;

          begin
            if i.pais_exped_rl is not null then
              SELECT P.TPAIS
                INTO VTPAIS_DEPART_RL
                FROM paises P
               WHERE P.Cpais = i.pais_exped_rl
                 AND ROWNUM = 1;
            else
              VTPAIS_DEPART_RL := null;
            end if;
          exception
            when no_data_found then
              VTPAIS_DEPART_RL := null;
          end;

          begin
            if i.depart_exped_rl is not null then
              SELECT P.TPROVIN
                INTO VTDEPART_EXP_RL
                FROM PROVINCIAS P
               WHERE P.CPROVIN = i.depart_exped_rl
                 AND ROWNUM = 1;
            else
              VTDEPART_EXP_RL := null;
            end if;
          exception
            when no_data_found then
              VTDEPART_EXP_RL := null;
          end;

          begin
            if i.lugar_exp_rl is not null then
              SELECT P.TPOBLAC
                INTO VTLUGAR_EXP_RL
                FROM POBLACIONES P
               WHERE P.CPOBLAC = i.lugar_exp_rl
                 and P.Cprovin = i.depart_exped_rl                
                 AND ROWNUM = 1;
            else
              VTLUGAR_EXP_RL := null;
            end if;
          exception
            when no_data_found then
              VTLUGAR_EXP_RL := null;
          end;

          begin
            if i.pais_lugar_naci_rl is not null then
              SELECT P.TPAIS
                INTO VTPAIS_LUGAR_RL
                FROM paises P
               WHERE P.Cpais = i.pais_lugar_naci_rl
                 AND ROWNUM = 1;
            else
              VTPAIS_LUGAR_RL := null;
            end if;
          exception
            when no_data_found then
              VTPAIS_LUGAR_RL := null;
          end;

          begin
            if i.depart_lugar_naci_rl is not null then
              SELECT P.TPROVIN
                INTO VTDEPART_NACI_RL
                FROM PROVINCIAS P
               WHERE P.CPROVIN = i.depart_lugar_naci_rl
                 AND ROWNUM = 1;
            else
              VTDEPART_NACI_RL := null;
            end if;
          exception
            when no_data_found then
              VTDEPART_NACI_RL := null;
          end;

          begin
            if i.lugar_naci_rl is not null then
              SELECT P.TPOBLAC
                INTO VTLUGAR_NACI_RL
                FROM POBLACIONES P
               WHERE P.CPOBLAC = i.lugar_naci_rl
                 and P.Cprovin = i.depart_lugar_naci_rl               
                 AND ROWNUM = 1;
            else
              VTLUGAR_NACI_RL := null;
            end if;
          exception
            when no_data_found then
              VTLUGAR_NACI_RL := null;
          end;

          begin
            if i.naci_1rl is not null then
              SELECT P.TPAIS
                INTO VTNACIONALIDAR1_RL
                FROM paises P
               WHERE P.Cpais = i.naci_1rl
                 AND ROWNUM = 1;
            else
              VTNACIONALIDAR1_RL := null;
            end if;
          exception
            when no_data_found then
              VTNACIONALIDAR1_RL := null;
          end;

          begin
            if i.naci_2rl is not null then
              SELECT P.TPAIS
                INTO VTNACIONALIDAR2_RL
                FROM paises P
               WHERE P.Cpais = i.naci_2rl
                 AND ROWNUM = 1;
            else
              VTNACIONALIDAR2_RL := null;
            end if;
          exception
            when no_data_found then
              VTNACIONALIDAR2_RL := null;
          end;

          begin
            if i.pais_resid_rl is not null then
              SELECT P.TPAIS
                INTO VTPAIS_RESID_RL
                FROM paises P
               WHERE P.Cpais = i.pais_resid_rl
                 AND ROWNUM = 1;
            else
              VTPAIS_RESID_RL := null;
            end if;
          exception
            when no_data_found then
              VTPAIS_RESID_RL := null;
          end;

          begin
            if i.departamento_resid_rl is not null then
              SELECT P.TPROVIN
                INTO VTDEPART_RESID_RL
                FROM PROVINCIAS P
               WHERE P.CPROVIN = i.departamento_resid_rl
                 AND ROWNUM = 1;
            else
              VTDEPART_RESID_RL := null;
            end if;
          exception
            when no_data_found then
              VTDEPART_RESID_RL := null;
          end;

          begin
            if i.ciudad_resid_rl is not null then
              SELECT P.TPOBLAC
                INTO VTCIUDAD_RESID_RL
                FROM POBLACIONES P
               WHERE P.CPOBLAC = i.ciudad_resid_rl
                 and P.CPROVIN = i.departamento_resid_rl           
                 AND ROWNUM = 1;
            else
              VTCIUDAD_RESID_RL := null;
            end if;
          exception
            when no_data_found then
              VTCIUDAD_RESID_RL := null;
          end;

          BEGIN
            VPASEXEC := 19;
            VNUMERR  := PAC_MD_PERSONA.F_SET_DATSARLATF(VSSARLAFT,
                                                        F_SYSDATE,
                                                        VSPERSON,
                                                        NVL(TO_DATE(I.FECHA_DILIMIENTO_CB,
                                                                    'dd/mm/yyyy'),
                                                            NULL),
                                                        NULL,
                                                        NULL,
                                                        I.ESTADO_CONFIRMACION_CF,
                                                        NVL(TO_DATE(I.FECHA_CONFIRMACION_CF,
                                                                    'dd/mm/yyyy'),
                                                            NULL),
                                                        VCVINCULACION,
                                                        I.CLASE_OTRO_CB,
                                                        i.departamento_cb,
                                                        VTPROVIN,
                                                        i.ciudad_cb,
                                                        VTPOBLAC,
                                                        VCVINTOMASE,
                                                        I.ASEGURADO_OTRO_CB,
                                                        VCVINTOMBEN,
                                                        I.BENEFICIARIO_OTRO_CB,
                                                        VCVINASEBEN,
                                                        I.BENEFICIARIO_ASE_OTRO_CB,
                                                        NULL,
                                                        NULL,
                                                        NULL,
                                                        NULL,
                                                        NULL,
                                                        NULL,
                                                        NULL,
                                                        NULL,
                                                        NULL,
                                                        NULL,
                                                        NULL,
                                                        NULL,
                                                        NULL,
                                                        NULL,
                                                        NULL,
                                                        NULL,
                                                        NULL,
                                                        NULL,
                                                        NULL,
                                                        NULL,
                                                        I.INGR_MENSUALES_IF,
                                                        I.ACTIVOS_IF,
                                                        I.PATRIMONIO_IF,
                                                        I.EGR_MENSUALES_IF,
                                                        I.PASIVOS_IF,
                                                        I.OTROS_INGRESOS_IF,
                                                        I.CON_OTROS_ING_IF,
                                                        NULL,
                                                        NULL,
                                                        NULL,
                                                        NULL,
                                                        NULL,
                                                        NULL,
                                                        NULL,
                                                        NULL,
                                                        I.REALIZA_TRANSACCIONES_OI,
                                                        I.SI_CUAL_OI,
                                                        I.POSEE_PRODUCTOS_OI,
                                                        I.POSEEE_CUENTAS_OI,
                                                        I.OTRAS_INDI_OI,
                                                        NULL,
                                                        i.ciudad_sucursal_ib,
                                                        i.pais_sucursal_ib,
                                                        i.depart_sucursal_ib,
                                                        i.ciudad_oficina_ib,
                                                        i.dep_oficina_ib,
                                                        i.pais_oficina_ib,                                                        
                                                        NULL,
                                                        VRESOCIEDAD,
                                                        i.naci_2rl,
                                                        I.POR_CARGO_RL,
                                                        NULL,
                                                        NULL,
                                                        I.ES_USTED_RL,
                                                        I.TIPO_RL,
                                                        TO_DATE(I.FECHA_EXP_RL,
                                                                'dd/mm/yyyy'),
                                                        TO_DATE(I.FECHA_NACI_RL,
                                                                'dd/mm/yyyy'),
                                                        I.NRAZON_SOCIAL_IB,
                                                        I.NIT_IB,
                                                        I.DV_IB,
                                                        I.DIRECCION_OFICINA_IB,
                                                        I.TELEFONO_OFICINA_IB,
                                                        NULL,
                                                        I.DIRECCION_SUCURSAL_IB,
                                                        I.TELEFONO_SUCURSAL_IB,
                                                        NULL,
                                                        I.TIPO_EMPRESA_IB,
                                                        null,  -- I.CUALES_RL /* Cambios de IAXIS-4732 */,
                                                        I.SECTOR_IB,
                                                        I.CIIU_COD_IB,
                                                        I.CIIU_ACTI_ECONOMICA_IB,
                                                        I.EMAIL_IB,
                                                        I.PRIMER_APELLIDO_RL,
                                                        I.SEGUNDO_APELLIDO_RL,
                                                        I.LEGAL_NOMBRES_RL,
                                                        I.NUMERO_RL,
                                                        NULL,
                                                        i.naci_1rl,
                                                        I.INDIQUE_CUAL_RL,
                                                        NULL,
                                                        NULL,
                                                        NULL,
                                                        NULL,
                                                        NULL,
                                                        NULL,
                                                        NULL,
                                                        NULL,
                                                        NULL,
                                                        NULL,
                                                        NULL,
                                                        NULL,
                                                        NULL,
                                                        NULL,
                                                        NULL,
                                                        NULL,
                                                        NULL,
                                                        I.ALGUNOS_RL,
                                                        I.HA_PRESENT_RS,
                                                        NULL,
                                                        NULL,
                                                        NULL,
                                                        NULL,
                                                        NULL,
                                                        NULL,
                                                        NULL,
                                                        VTPAIS_OFICINA,
                                                        VTPROVIN_IN_1_IB,
                                                        VTPOBLAC_IN_1_IB,
                                                        VTPAIS_SUR,
                                                        VTPROVIN_IN_2_IB,
                                                        VTPOBLAC_IN_2_IB,
                                                        NULL,
                                                        VTNACIONALIDAR1_RL,
                                                        VTNACIONALIDAR2_RL,
                                                        NULL,
                                                        NULL,
                                                        NULL,
                                                        NULL,
                                                        NULL,
                                                        NULL,
                                                        NULL,
                                                        NULL,
                                                        NULL,
                                                        null,
                                                        i.pais_exped_rl,
                                                        VTPAIS_DEPART_RL,
                                                        i.depart_exped_rl,
                                                        VTDEPART_EXP_RL,
                                                        i.pais_lugar_naci_rl,
                                                        VTPAIS_LUGAR_RL,
                                                        i.depart_lugar_naci_rl,
                                                        VTDEPART_NACI_RL,
                                                        i.lugar_naci_rl,
                                                        VTLUGAR_NACI_RL,
                                                        NULL,
                                                        i.lugar_exp_rl,
                                                        VTLUGAR_EXP_RL,
                                                        NULL,
                                                        NULL,
                                                        VCSUCURSAL,
                                                        i.tipo_solicitud_cb,
                                                        i.sector_ib,
                                                        NULL,
                                                        NULL,
                                                        NULL,
                                                        I.EMAIL_RL,
                                                        I.DIRECCION_RESID_RL,
                                                        i.ciudad_resid_rl,
                                                        VTCIUDAD_RESID_RL,
                                                        i.departamento_resid_rl,
                                                        VTDEPART_RESID_RL,
                                                        i.pais_resid_rl,
                                                        VTPAIS_RESID_RL,
                                                        I.TELEFONO_RL,
                                                        I.CELULAR_RL,
                                                        NULL,
                                                        NULL,
                                                        NULL,
                                                        NULL,
                                                        NVL(TO_DATE(I.Fecha_Entrevista_Ie,'dd/mm/yyyy'),NULL),  -- NULL, /* Cambios de IAXIS-4732 */
                                                        NULL,
                                                        NULL,
                                                        NULL,
                                                        NULL,
                                                        I.Resultado_Ie, -- NULL, /* Cambios de IAXIS-4732 */
                                                        NULL,
                                                        NULL,
                                                        NULL,
                                                        I.DECLARACION_FONDOS_DF,
                                                        I.AUTORIZA_1_CA,
                                                        I.AUTORIZA_2_CA,
                                                        null,
                                                        VMENSAJES);

            IF VNUMERR <> 0 THEN
              VLINEA := I.ITOMADOR || '|' || UPPER(I.NTOMADOR) ||
                        '|Error en Informaci??e datsarlaf para juridica persona.';
              UTL_FILE.PUT_LINE(VCARGARDSJ, VLINEA);

              VNUMERR    := PAC_GESTION_PROCESOS.F_SET_CARGA_CTRL_LINEA(PSPROCES   => P_SPROCES,
                                                                        PNLINEA    => V_NUM_LIN,
                                                                        PCTIPO     => 3,
                                                                        PIDINT     => V_NUM_LIN,
                                                                        PIDEXT     => V_NUM_LIN,
                                                                        PCESTADO   => 1,
                                                                        PCVALIDADO => NULL,
                                                                        PSSEGURO   => NULL,
                                                                        PIDEXTERNO => NULL,
                                                                        PNCARGA    => NULL,
                                                                        PNSINIES   => NULL,
                                                                        PNTRAMIT   => NULL,
                                                                        PSPERSON   => VSPERSON,
                                                                        PNRECIBO   => NULL);
              PCOUNTFAIL := PCOUNTFAIL + 1;
              CONTINUE;
            ELSE
              -- ACCIONISTAS 
              IF I.A1_TIPO_ID IS NOT NULL AND I.A1_NUMERO_ID IS NOT NULL AND
                 I.A1_NOMBRES IS NOT NULL THEN

                begin
                  SELECT MAX(SA.IDENTIFICACION)
                    INTO VIDENTIFICACION
                    FROM SARLATFACC SA
                   WHERE SA.NNUMIDE = I.A1_NUMERO_ID
                     AND SA.SSARLAFT = VSSARLAFT;
                exception
                  when no_data_found then
                    VIDENTIFICACION := null;
                end;

                BEGIN
                  VPASEXEC := 4;
                  VPARAM   := 'vssarlaft : ' || VSSARLAFT ||
                              ' : vIDENTIFICACION  : ' || VIDENTIFICACION ||
                              ' : a1_participacion : ' ||
                              I.A1_PARTICIPACION ||
                              ' : a1_nombres       : ' || I.A1_NOMBRES ||
                              ' : a1_tipo_id       : ' || I.A1_TIPO_ID ||
                              ' : a1_numero_id     : ' || I.A1_NUMERO_ID ||
                              ' : a1_espersona     : ' || I.A1_ESPERSONA ||
                              ' : a1_per_publicam  : ' || I.A1_PER_PUBLICAM ||
                              ' : a1_sujeto        : ' || I.A1_SUJETO;

                  VNUMERR := PAC_MD_PERSONA.F_SET_CACCIONISTA_SARLATF(VSSARLAFT,
                                                                      VIDENTIFICACION,
                                                                      I.A1_PARTICIPACION,
                                                                      I.A1_NOMBRES,
                                                                      I.A1_TIPO_ID,
                                                                      I.A1_NUMERO_ID,
                                                                      I.A1_ESPERSONA,
                                                                      I.A1_PER_PUBLICAM,
                                                                      I.A1_SUJETO,
                                                                      VMENSAJES);
                  IF VNUMERR <> 0 THEN
                    VLINEA := I.ITOMADOR || '|' || UPPER(I.NTOMADOR) ||
                              '|Error en Accionistas : ' || I.A1_NUMERO_ID;
                    UTL_FILE.PUT_LINE(VCARGARDSJ, VLINEA);

                    VNUMERR    := PAC_GESTION_PROCESOS.F_SET_CARGA_CTRL_LINEA(PSPROCES   => P_SPROCES,
                                                                              PNLINEA    => V_NUM_LIN,
                                                                              PCTIPO     => 3,
                                                                              PIDINT     => V_NUM_LIN,
                                                                              PIDEXT     => V_NUM_LIN,
                                                                              PCESTADO   => 1,
                                                                              PCVALIDADO => NULL,
                                                                              PSSEGURO   => NULL,
                                                                              PIDEXTERNO => NULL,
                                                                              PNCARGA    => NULL,
                                                                              PNSINIES   => NULL,
                                                                              PNTRAMIT   => NULL,
                                                                              PSPERSON   => VSPERSON,
                                                                              PNRECIBO   => NULL);
                    PCOUNTFAIL := PCOUNTFAIL + 1;
                    CONTINUE;
                  END IF;
                EXCEPTION
                  WHEN OTHERS THEN
                    PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(VMENSAJES,
                                                      VOBJECT,
                                                      1000001,
                                                      VPASEXEC,
                                                      VPARAM,
                                                      PSQCODE   => SQLCODE,
                                                      PSQERRM   => SQLERRM);
                END;
              END IF;

              IF I.A2_TIPO_ID IS NOT NULL AND I.A2_NUMERO_ID IS NOT NULL AND
                 I.A2_NOMBRES IS NOT NULL THEN

                begin
                  SELECT MAX(SA.IDENTIFICACION)
                    INTO VIDENTIFICACION
                    FROM SARLATFACC SA
                   WHERE SA.NNUMIDE = I.A2_NUMERO_ID
                     AND SA.SSARLAFT = VSSARLAFT;
                exception
                  when no_data_found then
                    VIDENTIFICACION := null;
                end;

                BEGIN
                  VPASEXEC := 5;
                  VPARAM   := 'vssarlaft : ' || VSSARLAFT ||
                              ' : vIDENTIFICACION  : ' || VIDENTIFICACION ||
                              ' : a2_participacion : ' ||
                              I.A2_PARTICIPACION ||
                              ' : a2_nombres       : ' || I.A2_NOMBRES ||
                              ' : a2_tipo_id       : ' || I.A2_TIPO_ID ||
                              ' : a2_numero_id     : ' || I.A2_NUMERO_ID ||
                              ' : a2_espersona     : ' || I.A2_ESPERSONA ||
                              ' : a2_per_publicam  : ' || I.A2_PER_PUBLICAM ||
                              ' : a2_sujeto        : ' || I.A2_SUJETO;

                  VNUMERR := PAC_MD_PERSONA.F_SET_CACCIONISTA_SARLATF(VSSARLAFT,
                                                                      VIDENTIFICACION,
                                                                      I.A2_PARTICIPACION,
                                                                      I.A2_NOMBRES,
                                                                      I.A2_TIPO_ID,
                                                                      I.A2_NUMERO_ID,
                                                                      I.A2_ESPERSONA,
                                                                      I.A2_PER_PUBLICAM,
                                                                      I.A2_SUJETO,
                                                                      VMENSAJES);
                  IF VNUMERR <> 0 THEN
                    VLINEA := I.ITOMADOR || '|' || UPPER(I.NTOMADOR) ||
                              '|Error en Accionistas : ' || I.A2_NUMERO_ID;
                    UTL_FILE.PUT_LINE(VCARGARDSJ, VLINEA);

                    VNUMERR    := PAC_GESTION_PROCESOS.F_SET_CARGA_CTRL_LINEA(PSPROCES   => P_SPROCES,
                                                                              PNLINEA    => V_NUM_LIN,
                                                                              PCTIPO     => 3,
                                                                              PIDINT     => V_NUM_LIN,
                                                                              PIDEXT     => V_NUM_LIN,
                                                                              PCESTADO   => 1,
                                                                              PCVALIDADO => NULL,
                                                                              PSSEGURO   => NULL,
                                                                              PIDEXTERNO => NULL,
                                                                              PNCARGA    => NULL,
                                                                              PNSINIES   => NULL,
                                                                              PNTRAMIT   => NULL,
                                                                              PSPERSON   => VSPERSON,
                                                                              PNRECIBO   => NULL);
                    PCOUNTFAIL := PCOUNTFAIL + 1;
                    CONTINUE;
                  END IF;
                EXCEPTION
                  WHEN OTHERS THEN
                    PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(VMENSAJES,
                                                      VOBJECT,
                                                      1000001,
                                                      VPASEXEC,
                                                      VPARAM,
                                                      PSQCODE   => SQLCODE,
                                                      PSQERRM   => SQLERRM);
                END;
              END IF;

              IF I.A3_TIPO_ID IS NOT NULL AND I.A3_NUMERO_ID IS NOT NULL AND
                 I.A3_NOMBRES IS NOT NULL THEN

                begin
                  SELECT MAX(SA.IDENTIFICACION)
                    INTO VIDENTIFICACION
                    FROM SARLATFACC SA
                   WHERE SA.NNUMIDE = I.A3_NUMERO_ID
                     AND SA.SSARLAFT = VSSARLAFT;
                exception
                  when no_data_found then
                    VIDENTIFICACION := null;
                end;

                BEGIN
                  VPASEXEC := 6;
                  VPARAM   := 'vssarlaft : ' || VSSARLAFT ||
                              ' : vIDENTIFICACION  : ' || VIDENTIFICACION ||
                              ' : a3_participacion : ' ||
                              I.A3_PARTICIPACION ||
                              ' : a3_nombres       : ' || I.A3_NOMBRES ||
                              ' : a3_tipo_id       : ' || I.A3_TIPO_ID ||
                              ' : a3_numero_id     : ' || I.A3_NUMERO_ID ||
                              ' : a3_espersona     : ' || I.A3_ESPERSONA ||
                              ' : a3_per_publicam  : ' || I.A3_PER_PUBLICAM ||
                              ' : a3_sujeto        : ' || I.A3_SUJETO;

                  VNUMERR := PAC_MD_PERSONA.F_SET_CACCIONISTA_SARLATF(VSSARLAFT,
                                                                      VIDENTIFICACION,
                                                                      I.A3_PARTICIPACION,
                                                                      I.A3_NOMBRES,
                                                                      I.A3_TIPO_ID,
                                                                      I.A3_NUMERO_ID,
                                                                      I.A3_ESPERSONA,
                                                                      I.A3_PER_PUBLICAM,
                                                                      I.A3_SUJETO,
                                                                      VMENSAJES);
                  IF VNUMERR <> 0 THEN
                    VLINEA := I.ITOMADOR || '|' || UPPER(I.NTOMADOR) ||
                              '|Error en Accionistas : ' || I.A3_NUMERO_ID;
                    UTL_FILE.PUT_LINE(VCARGARDSJ, VLINEA);

                    VNUMERR    := PAC_GESTION_PROCESOS.F_SET_CARGA_CTRL_LINEA(PSPROCES   => P_SPROCES,
                                                                              PNLINEA    => V_NUM_LIN,
                                                                              PCTIPO     => 3,
                                                                              PIDINT     => V_NUM_LIN,
                                                                              PIDEXT     => V_NUM_LIN,
                                                                              PCESTADO   => 1,
                                                                              PCVALIDADO => NULL,
                                                                              PSSEGURO   => NULL,
                                                                              PIDEXTERNO => NULL,
                                                                              PNCARGA    => NULL,
                                                                              PNSINIES   => NULL,
                                                                              PNTRAMIT   => NULL,
                                                                              PSPERSON   => VSPERSON,
                                                                              PNRECIBO   => NULL);
                    PCOUNTFAIL := PCOUNTFAIL + 1;
                    CONTINUE;
                  END IF;
                EXCEPTION
                  WHEN OTHERS THEN
                    PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(VMENSAJES,
                                                      VOBJECT,
                                                      1000001,
                                                      VPASEXEC,
                                                      VPARAM,
                                                      PSQCODE   => SQLCODE,
                                                      PSQERRM   => SQLERRM);
                END;
              END IF;

              IF I.A4_TIPO_ID IS NOT NULL AND I.A4_NUMERO_ID IS NOT NULL AND
                 I.A4_NOMBRES IS NOT NULL THEN

                begin
                  SELECT MAX(SA.IDENTIFICACION)
                    INTO VIDENTIFICACION
                    FROM SARLATFACC SA
                   WHERE SA.NNUMIDE = I.A4_NUMERO_ID
                     AND SA.SSARLAFT = VSSARLAFT;
                exception
                  when no_data_found then
                    VIDENTIFICACION := null;
                end;

                BEGIN
                  VPASEXEC := 7;
                  VPARAM   := 'vssarlaft : ' || VSSARLAFT ||
                              ' : vIDENTIFICACION  : ' || VIDENTIFICACION ||
                              ' : a4_participacion : ' ||
                              I.A4_PARTICIPACION ||
                              ' : a4_nombres       : ' || I.A4_NOMBRES ||
                              ' : a4_tipo_id       : ' || I.A4_TIPO_ID ||
                              ' : a4_numero_id     : ' || I.A4_NUMERO_ID ||
                              ' : a4_espersona     : ' || I.A4_ESPERSONA ||
                              ' : a4_per_publicam  : ' || I.A4_PER_PUBLICAM ||
                              ' : a4_sujeto        : ' || I.A4_SUJETO;

                  VNUMERR := PAC_MD_PERSONA.F_SET_CACCIONISTA_SARLATF(VSSARLAFT,
                                                                      VIDENTIFICACION,
                                                                      I.A4_PARTICIPACION,
                                                                      I.A4_NOMBRES,
                                                                      I.A4_TIPO_ID,
                                                                      I.A4_NUMERO_ID,
                                                                      I.A4_ESPERSONA,
                                                                      I.A4_PER_PUBLICAM,
                                                                      I.A4_SUJETO,
                                                                      VMENSAJES);
                  IF VNUMERR <> 0 THEN
                    VLINEA := I.ITOMADOR || '|' || UPPER(I.NTOMADOR) ||
                              '|Error en Accionistas : ' || I.A4_NUMERO_ID;
                    UTL_FILE.PUT_LINE(VCARGARDSJ, VLINEA);

                    VNUMERR    := PAC_GESTION_PROCESOS.F_SET_CARGA_CTRL_LINEA(PSPROCES   => P_SPROCES,
                                                                              PNLINEA    => V_NUM_LIN,
                                                                              PCTIPO     => 3,
                                                                              PIDINT     => V_NUM_LIN,
                                                                              PIDEXT     => V_NUM_LIN,
                                                                              PCESTADO   => 1,
                                                                              PCVALIDADO => NULL,
                                                                              PSSEGURO   => NULL,
                                                                              PIDEXTERNO => NULL,
                                                                              PNCARGA    => NULL,
                                                                              PNSINIES   => NULL,
                                                                              PNTRAMIT   => NULL,
                                                                              PSPERSON   => VSPERSON,
                                                                              PNRECIBO   => NULL);
                    PCOUNTFAIL := PCOUNTFAIL + 1;
                    CONTINUE;
                  END IF;
                EXCEPTION
                  WHEN OTHERS THEN
                    PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(VMENSAJES,
                                                      VOBJECT,
                                                      1000001,
                                                      VPASEXEC,
                                                      VPARAM,
                                                      PSQCODE   => SQLCODE,
                                                      PSQERRM   => SQLERRM);
                END;
              END IF;

              IF I.A5_TIPO_ID IS NOT NULL AND I.A5_NUMERO_ID IS NOT NULL AND
                 I.A5_NOMBRES IS NOT NULL THEN

                begin
                  SELECT MAX(SA.IDENTIFICACION)
                    INTO VIDENTIFICACION
                    FROM SARLATFACC SA
                   WHERE SA.NNUMIDE = I.A5_NUMERO_ID
                     AND SA.SSARLAFT = VSSARLAFT;
                exception
                  when no_data_found then
                    VIDENTIFICACION := null;
                end;

                BEGIN
                  VPASEXEC := 8;
                  VPARAM   := 'vssarlaft : ' || VSSARLAFT ||
                              ' : vIDENTIFICACION  : ' || VIDENTIFICACION ||
                              ' : a5_participacion : ' ||
                              I.A5_PARTICIPACION ||
                              ' : a5_nombres       : ' || I.A5_NOMBRES ||
                              ' : a5_tipo_id       : ' || I.A5_TIPO_ID ||
                              ' : a5_numero_id     : ' || I.A5_NUMERO_ID ||
                              ' : a5_espersona     : ' || I.A5_ESPERSONA ||
                              ' : a5_per_publicam  : ' || I.A5_PER_PUBLICAM ||
                              ' : a5_sujeto        : ' || I.A5_SUJETO;

                  VNUMERR := PAC_MD_PERSONA.F_SET_CACCIONISTA_SARLATF(VSSARLAFT,
                                                                      VIDENTIFICACION,
                                                                      I.A5_PARTICIPACION,
                                                                      I.A5_NOMBRES,
                                                                      I.A5_TIPO_ID,
                                                                      I.A5_NUMERO_ID,
                                                                      I.A5_ESPERSONA,
                                                                      I.A5_PER_PUBLICAM,
                                                                      I.A5_SUJETO,
                                                                      VMENSAJES);
                  IF VNUMERR <> 0 THEN
                    VLINEA := I.ITOMADOR || '|' || UPPER(I.NTOMADOR) ||
                              '|Error en Accionistas : ' || I.A5_NUMERO_ID;
                    UTL_FILE.PUT_LINE(VCARGARDSJ, VLINEA);

                    VNUMERR    := PAC_GESTION_PROCESOS.F_SET_CARGA_CTRL_LINEA(PSPROCES   => P_SPROCES,
                                                                              PNLINEA    => V_NUM_LIN,
                                                                              PCTIPO     => 3,
                                                                              PIDINT     => V_NUM_LIN,
                                                                              PIDEXT     => V_NUM_LIN,
                                                                              PCESTADO   => 1,
                                                                              PCVALIDADO => NULL,
                                                                              PSSEGURO   => NULL,
                                                                              PIDEXTERNO => NULL,
                                                                              PNCARGA    => NULL,
                                                                              PNSINIES   => NULL,
                                                                              PNTRAMIT   => NULL,
                                                                              PSPERSON   => VSPERSON,
                                                                              PNRECIBO   => NULL);
                    PCOUNTFAIL := PCOUNTFAIL + 1;
                    CONTINUE;
                  END IF;
                EXCEPTION
                  WHEN OTHERS THEN
                    PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(VMENSAJES,
                                                      VOBJECT,
                                                      1000001,
                                                      VPASEXEC,
                                                      VPARAM,
                                                      PSQCODE   => SQLCODE,
                                                      PSQERRM   => SQLERRM);
                END;
              END IF;

              -- CONOCIMIENTO MEJORADO DE PERSONAS EXPUESTAS PÚBLICAMENTE
              IF I.NUMERO1_IDENTIFICACION_PEP IS NOT NULL AND
                 I.NOMBRE1_COMPLETO_PEP IS NOT NULL THEN

                begin
                  if I.NACIONALIDAD1_PEP is not null then
                    SELECT P.TPAIS
                      INTO VTPAIS
                      FROM PAISES P
                     WHERE P.CPAIS = I.NACIONALIDAD1_PEP
                       AND ROWNUM = 1;
                  else
                    VTCIUDAD_RESID_RL := null;
                  end if;
                exception
                  when no_data_found then
                    VTCIUDAD_RESID_RL := null;
                end;

                begin
                  if I.NUMERO1_IDENTIFICACION_PEP is not null then
                    SELECT MAX(SP.IDENTIFICACION)
                      INTO VIDENTIFICACION_PEP
                      FROM SARLATFPEP SP
                     WHERE SP.NNUMIDE = I.NUMERO1_IDENTIFICACION_PEP
                       AND SP.SSARLAFT = VSSARLAFT;
                  else
                    VIDENTIFICACION_PEP := null;
                  end if;
                exception
                  when no_data_found then
                    VIDENTIFICACION_PEP := null;
                end;

                BEGIN
                  VPASEXEC := 9;
                  VPARAM   := 'vssarlaft : ' || VSSARLAFT ||
                              ' : videntificacion_PEP       : ' ||
                              VIDENTIFICACION_PEP ||
                              ' : vinculo1_relacion_pep     : ' ||
                              I.VINCULO1_RELACION_PEP ||
                              ' : nombre1_completo_pep      : ' ||
                              I.NOMBRE1_COMPLETO_PEP ||
                              ' : tipo1_identificacion_pep  : ' ||
                              I.TIPO1_IDENTIFICACION_PEP ||
                              ' : numero1_identificacion_pep: ' ||
                              I.NUMERO1_IDENTIFICACION_PEP ||
                              ' : VTPAIS                    : ' || VTPAIS ||
                              ' : entidad1_pep              : ' ||
                              I.ENTIDAD1_PEP ||
                              ' : cargo1_pep                : ' ||
                              I.CARGO1_PEP ||
                              ' : fecha1_desvinculacion_pep : ' ||
                              I.FECHA1_DESVINCULACION_PEP;

                  VNUMERR := PAC_MD_PERSONA.F_SET_CPEP_SARLATF(VSSARLAFT,
                                                               VIDENTIFICACION_PEP,
                                                               I.VINCULO1_RELACION_PEP,
                                                               I.NOMBRE1_COMPLETO_PEP,
                                                               I.TIPO1_IDENTIFICACION_PEP,
                                                               I.NUMERO1_IDENTIFICACION_PEP,
                                                               I.NACIONALIDAD1_PEP,
                                                               VTPAIS,
                                                               I.ENTIDAD1_PEP,
                                                               I.CARGO1_PEP,
                                                               NVL(TO_DATE(I.FECHA1_DESVINCULACION_PEP,
                                                                           'dd/mm/yyyy'),
                                                                   NULL),
                                                               VMENSAJES);
                  IF VNUMERR <> 0 THEN
                    VLINEA := I.ITOMADOR || '|' || UPPER(I.NTOMADOR) ||
                              '|Error en Conocimiento mejorado de personas expuestas públicamente : ' ||
                              I.NUMERO1_IDENTIFICACION_PEP;
                    UTL_FILE.PUT_LINE(VCARGARDSJ, VLINEA);

                    VNUMERR    := PAC_GESTION_PROCESOS.F_SET_CARGA_CTRL_LINEA(PSPROCES   => P_SPROCES,
                                                                              PNLINEA    => V_NUM_LIN,
                                                                              PCTIPO     => 3,
                                                                              PIDINT     => V_NUM_LIN,
                                                                              PIDEXT     => V_NUM_LIN,
                                                                              PCESTADO   => 1,
                                                                              PCVALIDADO => NULL,
                                                                              PSSEGURO   => NULL,
                                                                              PIDEXTERNO => NULL,
                                                                              PNCARGA    => NULL,
                                                                              PNSINIES   => NULL,
                                                                              PNTRAMIT   => NULL,
                                                                              PSPERSON   => VSPERSON,
                                                                              PNRECIBO   => NULL);
                    PCOUNTFAIL := PCOUNTFAIL + 1;
                    CONTINUE;
                  END IF;
                EXCEPTION
                  WHEN OTHERS THEN
                    PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(VMENSAJES,
                                                      VOBJECT,
                                                      1000001,
                                                      VPASEXEC,
                                                      VPARAM,
                                                      PSQCODE   => SQLCODE,
                                                      PSQERRM   => SQLERRM);
                END;
              END IF;

              IF I.NUMERO2_IDENTIFICACION_PEP IS NOT NULL AND
                 I.NOMBRE2_COMPLETO_PEP IS NOT NULL THEN

                begin
                  if I.NACIONALIDAD2_PEP is not null then
                    SELECT P.Tpais
                      INTO VTPAIS
                      FROM PAISES P
                     WHERE P.CPAIS = I.NACIONALIDAD2_PEP
                       AND ROWNUM = 1;
                  else
                    VTPAIS := null;
                  end if;
                exception
                  when no_data_found then
                    VTPAIS := null;
                end;

                begin
                  if I.NUMERO2_IDENTIFICACION_PEP is not null then
                    SELECT MAX(SP.IDENTIFICACION)
                      INTO VIDENTIFICACION_PEP
                      FROM SARLATFPEP SP
                     WHERE SP.NNUMIDE = I.NUMERO2_IDENTIFICACION_PEP
                       AND SP.SSARLAFT = VSSARLAFT;
                  else
                    VIDENTIFICACION_PEP := null;
                  end if;
                exception
                  when no_data_found then
                    VIDENTIFICACION_PEP := null;
                end;

                BEGIN
                  VPASEXEC := 10;
                  VPARAM   := 'vssarlaft : ' || VSSARLAFT ||
                              ' : videntificacion_PEP       : ' ||
                              VIDENTIFICACION_PEP ||
                              ' : vinculo2_relacion_pep     : ' ||
                              I.VINCULO2_RELACION_PEP ||
                              ' : nombre2_completo_pep      : ' ||
                              I.NOMBRE2_COMPLETO_PEP ||
                              ' : tipo2_identificacion_pep  : ' ||
                              I.TIPO2_IDENTIFICACION_PEP ||
                              ' : numero2_identificacion_pep: ' ||
                              I.NUMERO2_IDENTIFICACION_PEP ||
                              ' : VTPAIS                    : ' || VTPAIS ||
                              ' : entidad2_pep              : ' ||
                              I.ENTIDAD2_PEP ||
                              ' : cargo2_pep                : ' ||
                              I.CARGO2_PEP ||
                              ' : fecha2_desvinculacion_pep : ' ||
                              I.FECHA2_DESVINCULACION_PEP;

                  VNUMERR := PAC_MD_PERSONA.F_SET_CPEP_SARLATF(VSSARLAFT,
                                                               VIDENTIFICACION_PEP,
                                                               I.VINCULO2_RELACION_PEP,
                                                               I.NOMBRE2_COMPLETO_PEP,
                                                               I.TIPO2_IDENTIFICACION_PEP,
                                                               I.NUMERO2_IDENTIFICACION_PEP,
                                                               I.NACIONALIDAD2_PEP,
                                                               VTPAIS,
                                                               I.ENTIDAD2_PEP,
                                                               I.CARGO2_PEP,
                                                               NVL(TO_DATE(I.FECHA2_DESVINCULACION_PEP,
                                                                           'dd/mm/yyyy'),
                                                                   NULL),
                                                               VMENSAJES);
                  IF VNUMERR <> 0 THEN
                    VLINEA := I.ITOMADOR || '|' || UPPER(I.NTOMADOR) ||
                              '|Error en Conocimiento mejorado de personas expuestas públicamente : ' ||
                              I.NUMERO2_IDENTIFICACION_PEP;
                    UTL_FILE.PUT_LINE(VCARGARDSJ, VLINEA);

                    VNUMERR    := PAC_GESTION_PROCESOS.F_SET_CARGA_CTRL_LINEA(PSPROCES   => P_SPROCES,
                                                                              PNLINEA    => V_NUM_LIN,
                                                                              PCTIPO     => 3,
                                                                              PIDINT     => V_NUM_LIN,
                                                                              PIDEXT     => V_NUM_LIN,
                                                                              PCESTADO   => 1,
                                                                              PCVALIDADO => NULL,
                                                                              PSSEGURO   => NULL,
                                                                              PIDEXTERNO => NULL,
                                                                              PNCARGA    => NULL,
                                                                              PNSINIES   => NULL,
                                                                              PNTRAMIT   => NULL,
                                                                              PSPERSON   => VSPERSON,
                                                                              PNRECIBO   => NULL);
                    PCOUNTFAIL := PCOUNTFAIL + 1;
                    CONTINUE;
                  END IF;
                EXCEPTION
                  WHEN OTHERS THEN
                    PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(VMENSAJES,
                                                      VOBJECT,
                                                      1000001,
                                                      VPASEXEC,
                                                      VPARAM,
                                                      PSQCODE   => SQLCODE,
                                                      PSQERRM   => SQLERRM);
                END;
              END IF;

              IF I.NUMERO3_IDENTIFICACION_PEP IS NOT NULL AND
                 I.NOMBRE3_COMPLETO_PEP IS NOT NULL THEN

                begin
                  if I.NACIONALIDAD3_PEP is not null then
                    SELECT P.TPAIS
                      INTO VTPAIS
                      FROM PAISES P
                     WHERE P.CPAIS = I.NACIONALIDAD3_PEP
                       AND ROWNUM = 1;
                  else
                    VTPAIS := null;
                  end if;
                exception
                  when no_data_found then
                    VTPAIS := null;
                end;

                begin
                  if I.NUMERO3_IDENTIFICACION_PEP is not null then
                    SELECT MAX(SP.IDENTIFICACION)
                      INTO VIDENTIFICACION_PEP
                      FROM SARLATFPEP SP
                     WHERE SP.NNUMIDE = I.NUMERO3_IDENTIFICACION_PEP
                       AND SP.SSARLAFT = VSSARLAFT;
                  else
                    VIDENTIFICACION_PEP := null;
                  end if;
                exception
                  when no_data_found then
                    VIDENTIFICACION_PEP := null;
                end;

                BEGIN
                  VPASEXEC := 11;
                  VPARAM   := 'vssarlaft : ' || VSSARLAFT ||
                              ' : videntificacion_PEP       : ' ||
                              VIDENTIFICACION_PEP ||
                              ' : vinculo3_relacion_pep     : ' ||
                              I.VINCULO3_RELACION_PEP ||
                              ' : nombre3_completo_pep      : ' ||
                              I.NOMBRE3_COMPLETO_PEP ||
                              ' : tipo3_identificacion_pep  : ' ||
                              I.TIPO3_IDENTIFICACION_PEP ||
                              ' : numero3_identificacion_pep: ' ||
                              I.NUMERO3_IDENTIFICACION_PEP ||
                              ' : VTPAIS                    : ' || VTPAIS ||
                              ' : entidad3_pep              : ' ||
                              I.ENTIDAD3_PEP ||
                              ' : cargo3_pep                : ' ||
                              I.CARGO3_PEP ||
                              ' : fecha3_desvinculacion_pep : ' ||
                              I.FECHA3_DESVINCULACION_PEP;

                  VNUMERR := PAC_MD_PERSONA.F_SET_CPEP_SARLATF(VSSARLAFT,
                                                               VIDENTIFICACION_PEP,
                                                               I.VINCULO3_RELACION_PEP,
                                                               I.NOMBRE3_COMPLETO_PEP,
                                                               I.TIPO3_IDENTIFICACION_PEP,
                                                               I.NUMERO3_IDENTIFICACION_PEP,
                                                               I.NACIONALIDAD3_PEP,
                                                               VTPAIS,
                                                               I.ENTIDAD3_PEP,
                                                               I.CARGO3_PEP,
                                                               NVL(TO_DATE(I.FECHA3_DESVINCULACION_PEP,
                                                                           'dd/mm/yyyy'),
                                                                   NULL),
                                                               VMENSAJES);
                  IF VNUMERR <> 0 THEN
                    VLINEA := I.ITOMADOR || '|' || UPPER(I.NTOMADOR) ||
                              '|Error en Conocimiento mejorado de personas expuestas públicamente : ' ||
                              I.NUMERO3_IDENTIFICACION_PEP;
                    UTL_FILE.PUT_LINE(VCARGARDSJ, VLINEA);

                    VNUMERR    := PAC_GESTION_PROCESOS.F_SET_CARGA_CTRL_LINEA(PSPROCES   => P_SPROCES,
                                                                              PNLINEA    => V_NUM_LIN,
                                                                              PCTIPO     => 3,
                                                                              PIDINT     => V_NUM_LIN,
                                                                              PIDEXT     => V_NUM_LIN,
                                                                              PCESTADO   => 1,
                                                                              PCVALIDADO => NULL,
                                                                              PSSEGURO   => NULL,
                                                                              PIDEXTERNO => NULL,
                                                                              PNCARGA    => NULL,
                                                                              PNSINIES   => NULL,
                                                                              PNTRAMIT   => NULL,
                                                                              PSPERSON   => VSPERSON,
                                                                              PNRECIBO   => NULL);
                    PCOUNTFAIL := PCOUNTFAIL + 1;
                    CONTINUE;
                  END IF;
                EXCEPTION
                  WHEN OTHERS THEN
                    PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(VMENSAJES,
                                                      VOBJECT,
                                                      1000001,
                                                      VPASEXEC,
                                                      VPARAM,
                                                      PSQCODE   => SQLCODE,
                                                      PSQERRM   => SQLERRM);
                END;
              END IF;

              IF I.NUMERO4_IDENTIFICACION_PEP IS NOT NULL AND
                 I.NOMBRE4_COMPLETO_PEP IS NOT NULL THEN

                begin
                  if I.NACIONALIDAD4_PEP is not null then
                    SELECT P.TPAIS
                      INTO VTPAIS
                      FROM PAISES P
                     WHERE P.CPAIS = I.NACIONALIDAD4_PEP
                       AND ROWNUM = 1;
                  else
                    VTPAIS := null;
                  end if;
                exception
                  when no_data_found then
                    VTPAIS := null;
                end;

                begin
                  if I.NACIONALIDAD4_PEP is not null then
                    SELECT MAX(SP.IDENTIFICACION)
                      INTO VIDENTIFICACION_PEP
                      FROM SARLATFPEP SP
                     WHERE SP.NNUMIDE = I.NUMERO4_IDENTIFICACION_PEP
                       AND SP.SSARLAFT = VSSARLAFT;
                  else
                    VIDENTIFICACION_PEP := null;
                  end if;
                exception
                  when no_data_found then
                    VIDENTIFICACION_PEP := null;
                end;

                BEGIN
                  VPASEXEC := 12;
                  VPARAM   := 'vssarlaft : ' || VSSARLAFT ||
                              ' : videntificacion_PEP       : ' ||
                              VIDENTIFICACION_PEP ||
                              ' : vinculo4_relacion_pep     : ' ||
                              I.VINCULO4_RELACION_PEP ||
                              ' : nombre4_completo_pep      : ' ||
                              I.NOMBRE4_COMPLETO_PEP ||
                              ' : tipo4_identificacion_pep  : ' ||
                              I.TIPO4_IDENTIFICACION_PEP ||
                              ' : numero4_identificacion_pep: ' ||
                              I.NUMERO4_IDENTIFICACION_PEP ||
                              ' : VTPAIS                    : ' || VTPAIS ||
                              ' : entidad4_pep              : ' ||
                              I.ENTIDAD4_PEP ||
                              ' : cargo4_pep                : ' ||
                              I.CARGO4_PEP ||
                              ' : fecha4_desvinculacion_pep : ' ||
                              I.FECHA4_DESVINCULACION_PEP;

                  VNUMERR := PAC_MD_PERSONA.F_SET_CPEP_SARLATF(VSSARLAFT,
                                                               VIDENTIFICACION_PEP,
                                                               I.VINCULO4_RELACION_PEP,
                                                               I.NOMBRE4_COMPLETO_PEP,
                                                               I.TIPO4_IDENTIFICACION_PEP,
                                                               I.NUMERO4_IDENTIFICACION_PEP,
                                                               I.NACIONALIDAD4_PEP,
                                                               VTPAIS,
                                                               I.ENTIDAD4_PEP,
                                                               I.CARGO4_PEP,
                                                               NVL(TO_DATE(I.FECHA4_DESVINCULACION_PEP,
                                                                           'dd/mm/yyyy'),
                                                                   NULL),
                                                               VMENSAJES);
                  IF VNUMERR <> 0 THEN
                    VLINEA := I.ITOMADOR || '|' || UPPER(I.NTOMADOR) ||
                              '|Error en Conocimiento mejorado de personas expuestas públicamente : ' ||
                              I.NUMERO4_IDENTIFICACION_PEP;
                    UTL_FILE.PUT_LINE(VCARGARDSJ, VLINEA);

                    VNUMERR    := PAC_GESTION_PROCESOS.F_SET_CARGA_CTRL_LINEA(PSPROCES   => P_SPROCES,
                                                                              PNLINEA    => V_NUM_LIN,
                                                                              PCTIPO     => 3,
                                                                              PIDINT     => V_NUM_LIN,
                                                                              PIDEXT     => V_NUM_LIN,
                                                                              PCESTADO   => 1,
                                                                              PCVALIDADO => NULL,
                                                                              PSSEGURO   => NULL,
                                                                              PIDEXTERNO => NULL,
                                                                              PNCARGA    => NULL,
                                                                              PNSINIES   => NULL,
                                                                              PNTRAMIT   => NULL,
                                                                              PSPERSON   => VSPERSON,
                                                                              PNRECIBO   => NULL);
                    PCOUNTFAIL := PCOUNTFAIL + 1;
                    CONTINUE;
                  END IF;
                EXCEPTION
                  WHEN OTHERS THEN
                    PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(VMENSAJES,
                                                      VOBJECT,
                                                      1000001,
                                                      VPASEXEC,
                                                      VPARAM,
                                                      PSQCODE   => SQLCODE,
                                                      PSQERRM   => SQLERRM);
                END;
              END IF;

              -- CONOCIMIENTO AMPLIADO DE ACCIONISTAS Y BENEFICIARIOS FINALES
              IF I.NUMERO1_ID_BF IS NOT NULL AND I.NOMBRES1_BF IS NOT NULL AND
                 I.ID1_BF IS NOT NULL THEN

                begin
                  SELECT MAX(SB.IDENTIFICACION)
                    INTO VIDENTIFICACION_BEN
                    FROM SARLATFBEN SB
                   WHERE SB.NNUMIDESOC = I.NUMERO1_ID_BF
                     AND SB.SSARLAFT = VSSARLAFT;
                exception
                  when no_data_found then
                    VIDENTIFICACION_BEN := null;
                end;

                BEGIN
                  VPASEXEC := 13;
                  VPARAM   := 'vssarlaft : ' || VSSARLAFT ||
                              ' : vIDENTIFICACION_BEN       : ' ||
                              VIDENTIFICACION_BEN ||
                              ' : participacion1_bf         : ' ||
                              I.PARTICIPACION1_BF ||
                              ' : nombres1_bf               : ' ||
                              I.NOMBRES1_BF ||
                              ' : tipo1_id_bf               : ' ||
                              I.TIPO1_ID_BF ||
                              ' : id1_bf                    : ' || I.ID1_BF ||
                              ' : nombre1_razonsocial_bf    : ' ||
                              I.NOMBRE1_RAZONSOCIAL_BF ||
                              ' : numero1_id_bf             : ' ||
                              I.NUMERO1_ID_BF;

                  VNUMERR := PAC_MD_PERSONA.F_SET_ACCIONISTA_SARLATF(VSSARLAFT,
                                                                     VIDENTIFICACION_BEN,
                                                                     I.PARTICIPACION1_BF,
                                                                     I.NOMBRES1_BF,
                                                                     I.TIPO1_ID_BF,
                                                                     I.ID1_BF,
                                                                     I.NOMBRE1_RAZONSOCIAL_BF,
                                                                     I.NUMERO1_ID_BF,
                                                                     VMENSAJES);
                  IF VNUMERR <> 0 THEN
                    VLINEA := I.ITOMADOR || '|' || UPPER(I.NTOMADOR) ||
                              '|Error en Conocimiento ampliado de accionistas y beneficiarios finales : ' ||
                              I.NUMERO1_ID_BF;
                    UTL_FILE.PUT_LINE(VCARGARDSJ, VLINEA);

                    VNUMERR    := PAC_GESTION_PROCESOS.F_SET_CARGA_CTRL_LINEA(PSPROCES   => P_SPROCES,
                                                                              PNLINEA    => V_NUM_LIN,
                                                                              PCTIPO     => 3,
                                                                              PIDINT     => V_NUM_LIN,
                                                                              PIDEXT     => V_NUM_LIN,
                                                                              PCESTADO   => 1,
                                                                              PCVALIDADO => NULL,
                                                                              PSSEGURO   => NULL,
                                                                              PIDEXTERNO => NULL,
                                                                              PNCARGA    => NULL,
                                                                              PNSINIES   => NULL,
                                                                              PNTRAMIT   => NULL,
                                                                              PSPERSON   => VSPERSON,
                                                                              PNRECIBO   => NULL);
                    PCOUNTFAIL := PCOUNTFAIL + 1;
                    CONTINUE;
                  END IF;
                EXCEPTION
                  WHEN OTHERS THEN
                    PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(VMENSAJES,
                                                      VOBJECT,
                                                      1000001,
                                                      VPASEXEC,
                                                      VPARAM,
                                                      PSQCODE   => SQLCODE,
                                                      PSQERRM   => SQLERRM);
                END;
              END IF;

              IF I.NUMERO2_ID_BF IS NOT NULL AND I.NOMBRES2_BF IS NOT NULL AND
                 I.ID2_BF IS NOT NULL THEN

                begin
                  SELECT MAX(SB.IDENTIFICACION)
                    INTO VIDENTIFICACION_BEN
                    FROM SARLATFBEN SB
                   WHERE SB.NNUMIDESOC = I.NUMERO2_ID_BF
                     AND SB.SSARLAFT = VSSARLAFT;
                exception
                  when no_data_found then
                    VIDENTIFICACION_BEN := null;
                end;

                BEGIN
                  VPASEXEC := 14;
                  VPARAM   := 'vssarlaft : ' || VSSARLAFT ||
                              ' : vIDENTIFICACION_BEN       : ' ||
                              VIDENTIFICACION_BEN ||
                              ' : participacion2_bf         : ' ||
                              I.PARTICIPACION2_BF ||
                              ' : nombres2_bf               : ' ||
                              I.NOMBRES2_BF ||
                              ' : tipo2_id_bf               : ' ||
                              I.TIPO2_ID_BF ||
                              ' : id2_bf                    : ' || I.ID2_BF ||
                              ' : nombre2_razonsocial_bf    : ' ||
                              I.NOMBRE2_RAZONSOCIAL_BF ||
                              ' : numero2_id_bf             : ' ||
                              I.NUMERO2_ID_BF;

                  VNUMERR := PAC_MD_PERSONA.F_SET_ACCIONISTA_SARLATF(VSSARLAFT,
                                                                     VIDENTIFICACION_BEN,
                                                                     I.PARTICIPACION2_BF,
                                                                     I.NOMBRES2_BF,
                                                                     I.TIPO2_ID_BF,
                                                                     I.ID2_BF,
                                                                     I.NOMBRE2_RAZONSOCIAL_BF,
                                                                     I.NUMERO2_ID_BF,
                                                                     VMENSAJES);
                  IF VNUMERR <> 0 THEN
                    VLINEA := I.ITOMADOR || '|' || UPPER(I.NTOMADOR) ||
                              '|Error en Conocimiento ampliado de accionistas y beneficiarios finales : ' ||
                              I.NUMERO2_ID_BF;
                    UTL_FILE.PUT_LINE(VCARGARDSJ, VLINEA);

                    VNUMERR    := PAC_GESTION_PROCESOS.F_SET_CARGA_CTRL_LINEA(PSPROCES   => P_SPROCES,
                                                                              PNLINEA    => V_NUM_LIN,
                                                                              PCTIPO     => 3,
                                                                              PIDINT     => V_NUM_LIN,
                                                                              PIDEXT     => V_NUM_LIN,
                                                                              PCESTADO   => 1,
                                                                              PCVALIDADO => NULL,
                                                                              PSSEGURO   => NULL,
                                                                              PIDEXTERNO => NULL,
                                                                              PNCARGA    => NULL,
                                                                              PNSINIES   => NULL,
                                                                              PNTRAMIT   => NULL,
                                                                              PSPERSON   => VSPERSON,
                                                                              PNRECIBO   => NULL);
                    PCOUNTFAIL := PCOUNTFAIL + 1;
                    CONTINUE;
                  END IF;
                EXCEPTION
                  WHEN OTHERS THEN
                    PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(VMENSAJES,
                                                      VOBJECT,
                                                      1000001,
                                                      VPASEXEC,
                                                      VPARAM,
                                                      PSQCODE   => SQLCODE,
                                                      PSQERRM   => SQLERRM);
                END;
              END IF;

              IF I.NUMERO3_ID_BF IS NOT NULL AND I.NOMBRES3_BF IS NOT NULL AND
                 I.ID3_BF IS NOT NULL THEN

                begin
                  SELECT MAX(SB.IDENTIFICACION)
                    INTO VIDENTIFICACION_BEN
                    FROM SARLATFBEN SB
                   WHERE SB.NNUMIDESOC = I.NUMERO3_ID_BF
                     AND SB.SSARLAFT = VSSARLAFT;
                exception
                  when no_data_found then
                    VIDENTIFICACION_BEN := null;
                end;

                BEGIN
                  VPASEXEC := 15;
                  VPARAM   := 'vssarlaft : ' || VSSARLAFT ||
                              ' : vIDENTIFICACION_BEN       : ' ||
                              VIDENTIFICACION_BEN ||
                              ' : participacion3_bf         : ' ||
                              I.PARTICIPACION3_BF ||
                              ' : nombres3_bf               : ' ||
                              I.NOMBRES3_BF ||
                              ' : tipo2_id_bf               : ' ||
                              I.TIPO3_ID_BF ||
                              ' : id3_bf                    : ' || I.ID3_BF ||
                              ' : nombre3_razonsocial_bf    : ' ||
                              I.NOMBRE3_RAZONSOCIAL_BF ||
                              ' : numero3_id_bf             : ' ||
                              I.NUMERO2_ID_BF;

                  VNUMERR := PAC_MD_PERSONA.F_SET_ACCIONISTA_SARLATF(VSSARLAFT,
                                                                     VIDENTIFICACION_BEN,
                                                                     I.PARTICIPACION3_BF,
                                                                     I.NOMBRES3_BF,
                                                                     I.TIPO3_ID_BF,
                                                                     I.ID3_BF,
                                                                     I.NOMBRE3_RAZONSOCIAL_BF,
                                                                     I.NUMERO3_ID_BF,
                                                                     VMENSAJES);
                  IF VNUMERR <> 0 THEN
                    VLINEA := I.ITOMADOR || '|' || UPPER(I.NTOMADOR) ||
                              '|Error en Conocimiento ampliado de accionistas y beneficiarios finales : ' ||
                              I.NUMERO3_ID_BF;
                    UTL_FILE.PUT_LINE(VCARGARDSJ, VLINEA);

                    VNUMERR    := PAC_GESTION_PROCESOS.F_SET_CARGA_CTRL_LINEA(PSPROCES   => P_SPROCES,
                                                                              PNLINEA    => V_NUM_LIN,
                                                                              PCTIPO     => 3,
                                                                              PIDINT     => V_NUM_LIN,
                                                                              PIDEXT     => V_NUM_LIN,
                                                                              PCESTADO   => 1,
                                                                              PCVALIDADO => NULL,
                                                                              PSSEGURO   => NULL,
                                                                              PIDEXTERNO => NULL,
                                                                              PNCARGA    => NULL,
                                                                              PNSINIES   => NULL,
                                                                              PNTRAMIT   => NULL,
                                                                              PSPERSON   => VSPERSON,
                                                                              PNRECIBO   => NULL);
                    PCOUNTFAIL := PCOUNTFAIL + 1;
                    CONTINUE;
                  END IF;
                EXCEPTION
                  WHEN OTHERS THEN
                    PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(VMENSAJES,
                                                      VOBJECT,
                                                      1000001,
                                                      VPASEXEC,
                                                      VPARAM,
                                                      PSQCODE   => SQLCODE,
                                                      PSQERRM   => SQLERRM);
                END;
              END IF;

              IF I.NUMERO4_ID_BF IS NOT NULL AND I.NOMBRES4_BF IS NOT NULL AND
                 I.ID4_BF IS NOT NULL THEN

                begin
                  SELECT MAX(SB.IDENTIFICACION)
                    INTO VIDENTIFICACION_BEN
                    FROM SARLATFBEN SB
                   WHERE SB.NNUMIDESOC = I.NUMERO4_ID_BF
                     AND SB.SSARLAFT = VSSARLAFT;
                exception
                  when no_data_found then
                    VIDENTIFICACION_BEN := null;
                end;

                BEGIN
                  VPASEXEC := 16;
                  VPARAM   := 'vssarlaft : ' || VSSARLAFT ||
                              ' : vIDENTIFICACION_BEN       : ' ||
                              VIDENTIFICACION_BEN ||
                              ' : participacion4_bf         : ' ||
                              I.PARTICIPACION4_BF ||
                              ' : nombres4_bf               : ' ||
                              I.NOMBRES4_BF ||
                              ' : tipo4_id_bf               : ' ||
                              I.TIPO4_ID_BF ||
                              ' : id4_bf                    : ' || I.ID4_BF ||
                              ' : nombre4_razonsocial_bf    : ' ||
                              I.NOMBRE4_RAZONSOCIAL_BF ||
                              ' : numero4_id_bf             : ' ||
                              I.NUMERO4_ID_BF;

                  VNUMERR := PAC_MD_PERSONA.F_SET_ACCIONISTA_SARLATF(VSSARLAFT,
                                                                     VIDENTIFICACION_BEN,
                                                                     I.PARTICIPACION4_BF,
                                                                     I.NOMBRES4_BF,
                                                                     I.TIPO4_ID_BF,
                                                                     I.ID4_BF,
                                                                     I.NOMBRE4_RAZONSOCIAL_BF,
                                                                     I.NUMERO4_ID_BF,
                                                                     VMENSAJES);
                  IF VNUMERR <> 0 THEN
                    VLINEA := I.ITOMADOR || '|' || UPPER(I.NTOMADOR) ||
                              '|Error en Conocimiento ampliado de accionistas y beneficiarios finales : ' ||
                              I.NUMERO4_ID_BF;
                    UTL_FILE.PUT_LINE(VCARGARDSJ, VLINEA);

                    VNUMERR    := PAC_GESTION_PROCESOS.F_SET_CARGA_CTRL_LINEA(PSPROCES   => P_SPROCES,
                                                                              PNLINEA    => V_NUM_LIN,
                                                                              PCTIPO     => 3,
                                                                              PIDINT     => V_NUM_LIN,
                                                                              PIDEXT     => V_NUM_LIN,
                                                                              PCESTADO   => 1,
                                                                              PCVALIDADO => NULL,
                                                                              PSSEGURO   => NULL,
                                                                              PIDEXTERNO => NULL,
                                                                              PNCARGA    => NULL,
                                                                              PNSINIES   => NULL,
                                                                              PNTRAMIT   => NULL,
                                                                              PSPERSON   => VSPERSON,
                                                                              PNRECIBO   => NULL);
                    PCOUNTFAIL := PCOUNTFAIL + 1;
                    CONTINUE;
                  END IF;
                EXCEPTION
                  WHEN OTHERS THEN
                    PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(VMENSAJES,
                                                      VOBJECT,
                                                      1000001,
                                                      VPASEXEC,
                                                      VPARAM,
                                                      PSQCODE   => SQLCODE,
                                                      PSQERRM   => SQLERRM);
                END;
              END IF;

              -- ACTIVIDADES EN OPERACIONES INTERNACIONALES

              IF I.TIPO_PRODUCTO_AI IS NOT NULL AND
                 I.IDEN_NUMERO_PRODUCTO_AI IS NOT NULL THEN

                begin
                  SELECT MAX(DA.NACTIVI)
                    INTO VIDENTIFICACION_ACT
                    FROM DETSARLATF_ACT DA
                   WHERE DA.CIDNUMPROD = I.IDEN_NUMERO_PRODUCTO_AI
                     AND DA.SPERSON = VSPERSON
                     AND DA.SSARLAFT = VSSARLAFT;
                exception
                  when no_data_found then
                    VIDENTIFICACION_ACT := null;
                end;

                begin
                  if I.PAIS_AI is not null then
                    SELECT P.TPAIS
                      INTO VTPAIS
                      FROM PAISES P
                     WHERE P.CPAIS = I.PAIS_AI
                       AND ROWNUM = 1;
                  else
                    VTPAIS := null;
                  end if;
                exception
                  when no_data_found then
                    VTPAIS := null;
                end;

                begin
                  if i.departamento_ai is not null then
                    SELECT P.Tprovin
                      INTO VTPROVIN
                      FROM PROVINCIAS P
                     WHERE P.Cprovin = i.departamento_ai
                       AND ROWNUM = 1;
                  else
                    VTPROVIN := null;
                  end if;
                exception
                  when no_data_found then
                    VTPROVIN := null;
                end;

                begin
                  if i.ciudad_ai is not null then
                    SELECT P.TPOBLAC
                      INTO VTPOBLAC
                      FROM POBLACIONES P
                     WHERE P.CPOBLAC = i.ciudad_ai
                       and P.Cprovin = i.departamento_ai
                       AND ROWNUM = 1;
                  else
                    VTPOBLAC := null;
                  end if;
                exception
                  when no_data_found then
                    VTPOBLAC := null;
                end;

                BEGIN
                  VPASEXEC := 17;
                  VPARAM   := 'vssarlaft : ' || VSSARLAFT ||
                              ' : vIDENTIFICACION_ACT       : ' ||
                              VIDENTIFICACION_ACT ||
                              ' : tipo_producto_ai          : ' ||
                              I.TIPO_PRODUCTO_AI ||
                              ' : iden_numero_producto_ai   : ' ||
                              I.IDEN_NUMERO_PRODUCTO_AI ||
                              ' : entidad_ai                : ' ||
                              I.ENTIDAD_AI ||
                              ' : monto_ai                  : ' ||
                              I.MONTO_AI ||
                              ' : Ciudad_Ai                 : ' ||
                              I.Ciudad_Ai ||
                              ' : pais_ai                   : ' ||
                              I.PAIS_AI ||
                              ' : moneda_ai                 : ' ||
                              I.MONEDA_AI ||
                              ' : VTPAIS                    : ' || VTPAIS ||
                              ' : VTPROVIN                  : ' || VTPROVIN ||
                              ' : VTPOBLAC                  : ' || VTPOBLAC ||
                              ' : departamento_ai           : ' ||
                              I.departamento_ai;

                  VNUMERR := PAC_MD_PERSONA.F_SET_DETSARLATF_ACT(VIDENTIFICACION_ACT,
                                                                 VSPERSON,
                                                                 VSSARLAFT,
                                                                 I.TIPO_PRODUCTO_AI,
                                                                 I.IDEN_NUMERO_PRODUCTO_AI,
                                                                 I.ENTIDAD_AI,
                                                                 I.MONTO_AI,
                                                                 I.Ciudad_Ai,
                                                                 I.Pais_Ai,
                                                                 I.MONEDA_AI,
                                                                 VTPAIS,
                                                                 VTPROVIN,
                                                                 i.departamento_ai,
                                                                 VTPOBLAC,
                                                                 VMENSAJES);

                  IF VNUMERR <> 0 THEN
                    VLINEA := I.ITOMADOR || '|' || UPPER(I.NTOMADOR) ||
                              '|Error en Actividades en operaciones internacionales : ' ||
                              I.IDEN_NUMERO_PRODUCTO_AI;
                    UTL_FILE.PUT_LINE(VCARGARDSJ, VLINEA);

                    VNUMERR    := PAC_GESTION_PROCESOS.F_SET_CARGA_CTRL_LINEA(PSPROCES   => P_SPROCES,
                                                                              PNLINEA    => V_NUM_LIN,
                                                                              PCTIPO     => 3,
                                                                              PIDINT     => V_NUM_LIN,
                                                                              PIDEXT     => V_NUM_LIN,
                                                                              PCESTADO   => 1,
                                                                              PCVALIDADO => NULL,
                                                                              PSSEGURO   => NULL,
                                                                              PIDEXTERNO => NULL,
                                                                              PNCARGA    => NULL,
                                                                              PNSINIES   => NULL,
                                                                              PNTRAMIT   => NULL,
                                                                              PSPERSON   => VSPERSON,
                                                                              PNRECIBO   => NULL);
                    PCOUNTFAIL := PCOUNTFAIL + 1;
                    CONTINUE;
                  END IF;
                EXCEPTION
                  WHEN OTHERS THEN
                    PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(VMENSAJES,
                                                      VOBJECT,
                                                      1000001,
                                                      VPASEXEC,
                                                      VPARAM,
                                                      PSQCODE   => SQLCODE,
                                                      PSQERRM   => SQLERRM);
                END;
              END IF;

              --INFORMACIÓN SOBRE RECLAMACIONES EN SEGUROS
              IF I.ANO_RS IS NOT NULL AND I.RAMO_RS IS NOT NULL THEN

                begin
                  SELECT MAX(DR.NRECLA)
                    INTO VNRECLA
                    FROM DETSARLAFT_REC DR
                   WHERE DR.SPERSON = VSPERSON
                     AND DR.SSARLAFT = VSSARLAFT;
                exception
                  when no_data_found then
                    VNRECLA := null;
                end;

                BEGIN
                  VPASEXEC := 18;
                  VPARAM   := 'vssarlaft : ' || VSSARLAFT ||
                              ' : vnrecla                   : ' || VNRECLA ||
                              ' : ano_rs                    : ' || I.ANO_RS ||
                              ' : ramo_rs                   : ' ||
                              I.RAMO_RS ||
                              ' : compania_rs               : ' ||
                              I.COMPANIA_RS ||
                              ' : valor_rs                  : ' ||
                              I.VALOR_RS ||
                              ' : resultado_rs              : ' ||
                              I.RESULTADO_RS;

                  VNUMERR := PAC_MD_PERSONA.F_SET_DETSARLAFT_REC(VNRECLA,
                                                                 VSPERSON,
                                                                 VSSARLAFT,
                                                                 I.ANO_RS,
                                                                 I.RAMO_RS,
                                                                 I.COMPANIA_RS,
                                                                 I.VALOR_RS,
                                                                 I.RESULTADO_RS,
                                                                 VMENSAJES);
                  IF VNUMERR <> 0 THEN
                    VLINEA := I.ITOMADOR || '|' || UPPER(I.NTOMADOR) ||
                              '|Error en Información sobre reclamaciones en seguros : ' ||
                              I.RAMO_RS;
                    UTL_FILE.PUT_LINE(VCARGARDSJ, VLINEA);

                    VNUMERR    := PAC_GESTION_PROCESOS.F_SET_CARGA_CTRL_LINEA(PSPROCES   => P_SPROCES,
                                                                              PNLINEA    => V_NUM_LIN,
                                                                              PCTIPO     => 3,
                                                                              PIDINT     => V_NUM_LIN,
                                                                              PIDEXT     => V_NUM_LIN,
                                                                              PCESTADO   => 1,
                                                                              PCVALIDADO => NULL,
                                                                              PSSEGURO   => NULL,
                                                                              PIDEXTERNO => NULL,
                                                                              PNCARGA    => NULL,
                                                                              PNSINIES   => NULL,
                                                                              PNTRAMIT   => NULL,
                                                                              PSPERSON   => VSPERSON,
                                                                              PNRECIBO   => NULL);
                    PCOUNTFAIL := PCOUNTFAIL + 1;
                    CONTINUE;
                  END IF;
                EXCEPTION
                  WHEN OTHERS THEN
                    PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(VMENSAJES,
                                                      VOBJECT,
                                                      1000001,
                                                      VPASEXEC,
                                                      VPARAM,
                                                      PSQCODE   => SQLCODE,
                                                      PSQERRM   => SQLERRM);
                END;
              END IF;

              VNUMERR       := PAC_GESTION_PROCESOS.F_SET_CARGA_CTRL_LINEA(PSPROCES   => P_SPROCES,
                                                                           PNLINEA    => V_NUM_LIN,
                                                                           PCTIPO     => 3,
                                                                           PIDINT     => V_NUM_LIN,
                                                                           PIDEXT     => V_NUM_LIN,
                                                                           PCESTADO   => 4,
                                                                           PCVALIDADO => NULL,
                                                                           PSSEGURO   => NULL,
                                                                           PIDEXTERNO => NULL,
                                                                           PNCARGA    => NULL,
                                                                           PNSINIES   => NULL,
                                                                           PNTRAMIT   => NULL,
                                                                           PSPERSON   => VSPERSON,
                                                                           PNRECIBO   => NULL);
              PCOUNTSUCCESS := PCOUNTSUCCESS + 1;
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(VMENSAJES,
                                                VOBJECT,
                                                1000001,
                                                VPASEXEC,
                                                VPARAM,
                                                PSQCODE   => SQLCODE,
                                                PSQERRM   => SQLERRM);
          END;
        ELSE
          -- WHEN NO DATA FOUND FOR PERSONA
          VLINEA := I.ITOMADOR || '|' || UPPER(I.NTOMADOR) ||
                    '|NO COINCIDEN NOMBRES';
          UTL_FILE.PUT_LINE(VCARGARDSJ, VLINEA);

          VNUMERR    := PAC_GESTION_PROCESOS.F_SET_CARGA_CTRL_LINEA(PSPROCES   => P_SPROCES,
                                                                    PNLINEA    => V_NUM_LIN,
                                                                    PCTIPO     => 3,
                                                                    PIDINT     => V_NUM_LIN,
                                                                    PIDEXT     => V_NUM_LIN,
                                                                    PCESTADO   => 5,
                                                                    PCVALIDADO => NULL,
                                                                    PSSEGURO   => NULL,
                                                                    PIDEXTERNO => NULL,
                                                                    PNCARGA    => NULL,
                                                                    PNSINIES   => NULL,
                                                                    PNTRAMIT   => NULL,
                                                                    PSPERSON   => VSPERSON,
                                                                    PNRECIBO   => NULL);
          PCOUNTFAIL := PCOUNTFAIL + 1;
          CONTINUE;
        END IF;
      END LOOP;
    END IF;

    IF VCOUNTDSJ = (PCOUNTSUCCESS + PCOUNTFAIL) THEN
      PERROR := 0;
    ELSE
      PERROR := 1;
    END IF;

    IF UTL_FILE.is_open(VCARGARDSJ) THEN
      UTL_FILE.fclose(VCARGARDSJ);
    END IF;

  END P_CARGA_DATSARLAF_J;

  FUNCTION F_CARGA_DATSARLAF_N(P_NOMBRE  IN VARCHAR2,
                               P_PATH    IN VARCHAR2,
                               P_CPROCES IN NUMBER,
                               PSPROCES  IN OUT NUMBER) RETURN NUMBER IS
    VOBJ     VARCHAR2(100) := 'pac_cargas_conf';
    VTRAZA   NUMBER := 0;
    VNUM_ERR NUMBER;
    VSALIR EXCEPTION;
  BEGIN
    VTRAZA := 0;

    SELECT NVL(CPARA_ERROR, 0)
      INTO K_PARA_CARGA
      FROM CFG_FILES
     WHERE CEMPRES = K_EMPRESAAXIS
       AND CPROCESO = P_CPROCES;

    IF PSPROCES IS NULL THEN
      VNUM_ERR := PAC_CARGAS_CONF.F_EJECUTAR_CARGA_DATASARLAF_N(P_NOMBRE,
                                                                P_PATH,
                                                                P_CPROCES,
                                                                PSPROCES);

      IF VNUM_ERR <> 0 THEN
        RAISE VSALIR;
      END IF;
    END IF;

    VTRAZA   := 1;
    VNUM_ERR := PAC_CARGAS_CONF.F_PROCESO_DATSARLAF(PSPROCES, P_CPROCES);

    IF VNUM_ERR <> 0 THEN
      RAISE VSALIR;
    ELSE
      VNUM_ERR := PAC_GESTION_PROCESOS.F_SET_CARGA_CTRL_CABECERA(PSPROCES,
                                                                 P_NOMBRE,
                                                                 NULL,
                                                                 F_SYSDATE,
                                                                 4,
                                                                 P_CPROCES,
                                                                 0,
                                                                 NULL);
      VNUM_ERR := F_PROCESFIN(PSPROCES, 0);
    END IF;

    RETURN 0;
  EXCEPTION
    WHEN VSALIR THEN
      RETURN 1;
  END F_CARGA_DATSARLAF_N;

/* Cambios de IAXIS-4732 : Starts */
  FUNCTION F_MODI_DATSARLAF_N_EXT(P_NOMBRE VARCHAR2) RETURN NUMBER IS
    V_TNOMFICH VARCHAR2(100);
  BEGIN
    V_TNOMFICH := SUBSTR(P_NOMBRE, 1, INSTR(P_NOMBRE, '.') - 1);

    EXECUTE IMMEDIATE 'alter table datos_sarlaf_n_ext ACCESS PARAMETERS (records delimited by 0x''0A''
                   logfile ' || CHR(39) || V_TNOMFICH ||
                      '.log' || CHR(39) || '
                   badfile ' || CHR(39) || V_TNOMFICH ||
                      '.bad' || CHR(39) || '
                   discardfile ' || CHR(39) ||
                      V_TNOMFICH || '.dis' || CHR(39) || '
                   fields terminated by ''|'' lrtrim
                   MISSING FIELD VALUES ARE NULL
                   REJECT ROWS WITH ALL NULL FIELDS
                   (
                      itomador,
                      ntomador,
                      ide_tomador,
                      fecha_dilimiento_cb,
                      departamento_cb,
                      ciudad_cb,
                      sucursal_cb,
                      tipo_solicitud_cb,
                      clase_vin_cb,
                      clase_otro_cb,
                      tomador_aseg_cb,
                      ase_otro_cb,
                      tomador_bene_cb,
                      bene_otro_cb,
                      asegu_beneficiario_cb,
                      ase_ben_otro_cb,
                      primer_apellido_ib,
                      segundo_apellido_ib,
                      nombres_ib,
                      tipo_documento_ib,
                      numero_ib,
                      fecha_expedicion_ib,
                      pais_exped_ib,
                      depart_exped_ib,
                      lugar_expedicion_ib,
                      fecha_nacimiento_ib,
                      pais_lugar_naci_ib,
                      depart_lugar_naci_ib,
                      lugar_nacimiento_ib,
                      nacionalidad1_ib,
                      nacionalidad2_ib,
                      direccion_residencia_ib,
                      ciiu_actividad_ib,
                      ciiu_cod_ib,
                      sector_ib,
                      tipo_actividad_ib,
                      pais_residencia_ib,
                      dep_residencia_ib,
                      ciudad_residencia_ib,
                      telefono_residencia_ib,
                      celular_ib,
                      email_ib,
                      ocupacion_ib,
                      cargo_ib,
                      emp_tra_pn_ib,
                      dir_emp_pn_ib,
                      dep_empresa_pn_ib,
                      ciuda_emp_pn_ib,
                      tele_empresa_pn_ib,
                      act_sec_pn_ib,
                      ciiu_sec_pn_ib,
                      producto_servicio_ib,
                      usted_sujeto_ib,
                      usted_una_ib,
                      existe_vinculo_ib,
                      por_cargo_ib,
                      vinculo_relacion_1_pep,
                      nombre_completo_1_pep,
                      tipo_iden_1_pep,
                      numero_iden_1_pep,
                      nacionalidad_1_pep,
                      entidad_1_pep,
                      cargo_1_pep,
                      fecha_desvin_1_pep,
                      vinculo_relacion_2_pep,
                      nombre_completo_2_pep,
                      tipo_iden_2_pep,
                      numero_iden_2_pep,
                      nacionalidad_2_pep,
                      entidad_2_pep,
                      cargo_2_pep,
                      fecha_desvin_2_pep,
                      vinculo_relacion_3_pep,
                      nombre_completo_3_pep,
                      tipo_iden_3_pep,
                      numero_iden_3_pep,
                      nacionalidad_3_pep,
                      entidad_3_pep,
                      cargo_3_pep,
                      fecha_desvin_3_pep,
                      vinculo_relacion_4_pep,
                      nombre_completo_4_pep,
                      tipo_iden_4_pep,
                      numero_iden_4_pep,
                      nacionalidad_4_pep,
                      entidad_4_pep,
                      cargo_4_pep,
                      fecha_desvin_4_pep,
                      ingresos_mensuales_ib,
                      egresos_mensuales_ib,
                      activos_ib,
                      pasivos_ib,
                      patrimonio_ib,
                      otros_ingresos_ib,
                      con_otr_ing_ib,
                      declar_fondos_df,
                      realiza_transacciones_oi,
                      si_cual_oi,
                      otras_indique_oi,
                      posee_productos_oi,
                      poseee_cuentas_oi,
                      tipo_producto_oi,
                      id_num_producto_oi,
                      entidad_producto_oi,
                      monto_oi,
                      pais_oi,
                      departmento_oi,
                      ciudad_oi,
                      moneda_oi,
                      pre_reclamacion_rs,
                      ano_rs,
                      ramo_rs,
                      compania_rs,
                      valor_rs,
                      resultado_rs,
                      autoriza_1_ca,
                      autoriza_2_ca,
                      estado_confirmacion_ci,
                      fecha_confirmacion_ci,
                      actividad_principal_ib,
                      fecha_entrevista_ie,
                      resultado_ie
                  ))';
    EXECUTE IMMEDIATE 'ALTER TABLE datos_sarlaf_n_ext LOCATION (''' ||
                      P_NOMBRE || ''')';
    RETURN 0;
  EXCEPTION
    WHEN OTHERS THEN
      P_TAB_ERROR(F_SYSDATE,
                  F_USER,
                  'pac_cargas_conf.f_modi_datsarlf_N_ext',
                  1,
                  'Error creando la tabla.',
                  SQLERRM);
      RETURN 107914; -- NEED TO ADD NEW MSG
  END;
/* Cambios de IAXIS-4732 : Ends */  

/* Cambios de IAXIS-4732 : Starts */  
  PROCEDURE P_TRASP_TABLA_DS_N(PDESERROR OUT VARCHAR2, PSPROCES IN NUMBER) IS
    NUM_ERR   NUMBER;
    V_PASEXEC NUMBER := 1;
    VPARAM    VARCHAR2(1) := NULL;
    VOBJ      VARCHAR2(200) := 'pac_cargas_conf.p_trasp_tabla_ds_N';
    V_NUMERR  NUMBER := 0;
    ERRGRABARPROV  EXCEPTION;
    E_OBJECT_ERROR EXCEPTION;
    V_LINEA      NUMBER := 0;
    V_IDCARGA    NUMBER := 0;
    V_DESC_CARGA VARCHAR2(100) := NULL;

    V_EXISTE_ENDEUDA NUMBER := 0;
    V_EXISTE_SFIANCI NUMBER := 0;
    V_SFINANCI       NUMBER := 0;
    v_numlin         DATOS_SARLAF_N.nlinea%TYPE;

  BEGIN
    V_PASEXEC := 0;
    PDESERROR := NULL;

    SELECT NVL(MAX(ID_CARGA + 1), 1) INTO V_IDCARGA FROM DATOS_SARLAF_N;

    SELECT NVL(MAX(nlinea), 0)
      INTO v_numlin
      FROM DATOS_SARLAF_N
     WHERE proceso = psproces;

    V_DESC_CARGA := 'CARGA DATOS SARLAF NATURAL';

    INSERT INTO DATOS_SARLAF_N
      (SELECT psproces,
              ROWNUM + v_numlin,
              V_IDCARGA,
              V_DESC_CARGA,
              F_SYSDATE,
              itomador,
              ntomador,
              ide_tomador,
              fecha_dilimiento_cb,
              departamento_cb,
              ciudad_cb,
              sucursal_cb,
              tipo_solicitud_cb,
              clase_vin_cb,
              clase_otro_cb,
              tomador_aseg_cb,
              ase_otro_cb,
              tomador_bene_cb,
              bene_otro_cb,
              asegu_beneficiario_cb,
              ase_ben_otro_cb,
              primer_apellido_ib,
              segundo_apellido_ib,
              nombres_ib,
              tipo_documento_ib,
              numero_ib,
              fecha_expedicion_ib,
              pais_exped_ib,
              depart_exped_ib,
              lugar_expedicion_ib,
              fecha_nacimiento_ib,
              pais_lugar_naci_ib,
              depart_lugar_naci_ib,
              lugar_nacimiento_ib,
              nacionalidad1_ib,
              nacionalidad2_ib,
              direccion_residencia_ib,
              ciiu_actividad_ib,
              ciiu_cod_ib,
              sector_ib,
              tipo_actividad_ib,
              pais_residencia_ib,
              dep_residencia_ib,
              ciudad_residencia_ib,
              telefono_residencia_ib,
              celular_ib,
              email_ib,
              ocupacion_ib,
              cargo_ib,
              emp_tra_pn_ib,
              dir_emp_pn_ib,
              dep_empresa_pn_ib,
              ciuda_emp_pn_ib,
              tele_empresa_pn_ib,
              act_sec_pn_ib,
              ciiu_sec_pn_ib,
              producto_servicio_ib,
              usted_sujeto_ib,
              usted_una_ib,
              existe_vinculo_ib,
              por_cargo_ib,
              vinculo_relacion_1_pep,
              nombre_completo_1_pep,
              tipo_iden_1_pep,
              numero_iden_1_pep,
              nacionalidad_1_pep,
              entidad_1_pep,
              cargo_1_pep,
              fecha_desvin_1_pep,
              vinculo_relacion_2_pep,
              nombre_completo_2_pep,
              tipo_iden_2_pep,
              numero_iden_2_pep,
              nacionalidad_2_pep,
              entidad_2_pep,
              cargo_2_pep,
              fecha_desvin_2_pep,
              vinculo_relacion_3_pep,
              nombre_completo_3_pep,
              tipo_iden_3_pep,
              numero_iden_3_pep,
              nacionalidad_3_pep,
              entidad_3_pep,
              cargo_3_pep,
              fecha_desvin_3_pep,
              vinculo_relacion_4_pep,
              nombre_completo_4_pep,
              tipo_iden_4_pep,
              numero_iden_4_pep,
              nacionalidad_4_pep,
              entidad_4_pep,
              cargo_4_pep,
              fecha_desvin_4_pep,
              ingresos_mensuales_ib,
              egresos_mensuales_ib,
              activos_ib,
              pasivos_ib,
              patrimonio_ib,
              otros_ingresos_ib,
              con_otr_ing_ib,
              declar_fondos_df,
              realiza_transacciones_oi,
              si_cual_oi,
              otras_indique_oi,
              posee_productos_oi,
              poseee_cuentas_oi,
              tipo_producto_oi,
              id_num_producto_oi,
              entidad_producto_oi,
              monto_oi,
              pais_oi,
              departmento_oi,
              ciudad_oi,
              moneda_oi,
              pre_reclamacion_rs,
              ano_rs,
              ramo_rs,
              compania_rs,
              valor_rs,
              resultado_rs,
              autoriza_1_ca,
              autoriza_2_ca,
              estado_confirmacion_ci,
              fecha_confirmacion_ci,
              ACTIVIDAD_PRINCIPAL_IB,
              FECHA_ENTREVISTA_IE,
              RESULTADO_IE
         FROM DATOS_SARLAF_N_EXT);
    V_PASEXEC := 8;
    COMMIT;
  EXCEPTION
    WHEN E_OBJECT_ERROR THEN
      ROLLBACK;

      IF PDESERROR IS NULL THEN
        PDESERROR := F_AXIS_LITERALES(108953, K_IDIOMAAAXIS); -- NEED TO ADD DIFFERENT MSG
      END IF;

      NULL;
    WHEN OTHERS THEN
      ROLLBACK;
      PDESERROR := F_AXIS_LITERALES(103187, K_IDIOMAAAXIS) || SQLERRM; -- NEED TO ADD DIFFERENT MSG
      P_TAB_ERROR(F_SYSDATE, F_USER, VOBJ, V_PASEXEC, SQLCODE, SQLERRM);
      RAISE;
  END P_TRASP_TABLA_DS_N;
/* Cambios de IAXIS-4732 : Ends */ 

  FUNCTION F_EJECUTAR_CARGA_DATASARLAF_N(P_NOMBRE  IN VARCHAR2,
                                         P_PATH    IN VARCHAR2,
                                         P_CPROCES IN NUMBER,
                                         PSPROCES  OUT NUMBER) RETURN NUMBER IS
    VOBJ      VARCHAR2(100) := 'f_ejecutar_carga_datasarlaf_N';
    LINEA     NUMBER := 0;
    PCARGA    NUMBER;
    SENTENCIA VARCHAR2(32000);
    VFICHERO  UTL_FILE.FILE_TYPE;
    VTRAZA    NUMBER := 0;
    VERROR    NUMBER;
    VDESERROR VARCHAR2(1000);
    V_SPROCES NUMBER;
    ERRORINI EXCEPTION;
    VNUM_ERR NUMBER;
    VSALIR EXCEPTION;
    VNNUMLIN   NUMBER;
    VSINPROC   BOOLEAN := TRUE;
    VERRORFIN  BOOLEAN := FALSE;
    VAVISFIN   BOOLEAN := FALSE;
    VTIPERR    NUMBER;
    VCODERROR  NUMBER;
    N_IMP      NUMBER;
    V_DESERROR INT_CARGA_CTRL_LINEA_ERRS.TMENSAJE%TYPE;
    E_ERRDATOS EXCEPTION;

    VNUM_ERR_CARGAR_DSN NUMBER;
    VNUM_COUNTFAIL      NUMBER;
    VNUM_COUNTSUCCESS   NUMBER;

  BEGIN
    VTRAZA   := 0;
    VSINPROC := TRUE;
    VNUM_ERR := F_PROCESINI(F_USER,
                            K_EMPRESAAXIS,
                            'CARGA_DATSAR_NATURAL',
                            P_NOMBRE,
                            V_SPROCES);

    IF VNUM_ERR <> 0 THEN
      RAISE ERRORINI;
    END IF;

    PSPROCES := V_SPROCES;
    VTRAZA   := 1;

    IF P_CPROCES IS NULL THEN
      VNUM_ERR  := 9901092; -- NEED TO ADD DIFFERENT MSG
      VDESERROR := 'cfg_files falta proceso: ' || VOBJ;
      RAISE E_ERRDATOS;
    END IF;

    VTRAZA   := 11;
    VNUM_ERR := PAC_GESTION_PROCESOS.F_SET_CARGA_CTRL_CABECERA(V_SPROCES,
                                                               P_NOMBRE,
                                                               F_SYSDATE,
                                                               NULL,
                                                               3,
                                                               P_CPROCES,
                                                               NULL,
                                                               NULL);
    VTRAZA   := 12;

    IF VNUM_ERR <> 0 THEN
      P_TAB_ERROR(F_SYSDATE,
                  F_USER,
                  VOBJ,
                  VTRAZA,
                  VNUM_ERR,
                  'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera');
      VNUM_ERR := F_PROCESLIN(V_SPROCES,
                              F_AXIS_LITERALES(180856, K_IDIOMAAAXIS) || ':' ||
                              P_NOMBRE || ' : ' || VNUM_ERR,
                              1,
                              VNNUMLIN); -- NEED TO ADD DIFFERENT MSG
      RAISE ERRORINI;
    END IF;

    COMMIT;
    VTRAZA := 2;

    VNUM_ERR := F_MODI_DATSARLAF_N_EXT(P_NOMBRE);

    IF VNUM_ERR <> 0 THEN
      P_TAB_ERROR(F_SYSDATE,
                  F_USER,
                  VOBJ,
                  VTRAZA,
                  VNUM_ERR,
                  'Error creando la tabla externa');
      VNUM_ERR := F_PROCESLIN(V_SPROCES,
                              F_AXIS_LITERALES(VNUM_ERR, K_IDIOMAAAXIS) || ':' ||
                              P_NOMBRE || ' : ' || VNUM_ERR,
                              1,
                              VNNUMLIN);
      RAISE ERRORINI;
    END IF;

    VTRAZA := 53;
    IF VNUM_ERR = 0 THEN
      BEGIN
        P_CARGA_DATSARLAF_N(P_PATH,
                            P_NOMBRE,
                            P_CPROCES,
                            V_SPROCES,
                            VNUM_COUNTFAIL,
                            VNUM_COUNTSUCCESS,
                            VNUM_ERR_CARGAR_DSN);
        IF VNUM_ERR_CARGAR_DSN <> 0 THEN
          P_TAB_ERROR(F_SYSDATE,
                      F_USER,
                      VOBJ,
                      VTRAZA,
                      VNUM_ERR_CARGAR_DSN,
                      'Cargar archivo de datos sarlaf natural : Funciona :' ||
                      VNUM_COUNTSUCCESS || ' : No Funciona :' ||
                      VNUM_COUNTFAIL);

          VNUM_ERR := F_PROCESLIN(V_SPROCES,
                                  F_AXIS_LITERALES(VNUM_ERR_CARGAR_DSN,
                                                   K_IDIOMAAAXIS) || ':' ||
                                  P_NOMBRE || ' : ' || VNUM_ERR_CARGAR_DSN,
                                  1,
                                  VNNUMLIN);
          RAISE ERRORINI;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          P_TAB_ERROR(F_SYSDATE,
                      F_USER,
                      VOBJ,
                      VTRAZA,
                      VNUM_COUNTFAIL,
                      'Error en cargar archivo de datos sarlaf natural : Funciona :' ||
                      VNUM_COUNTSUCCESS || ' : No Funciona :' ||
                      VNUM_COUNTFAIL);
      END;
    END IF;

    P_TRASP_TABLA_DS_N(VDESERROR, V_SPROCES);
    VTRAZA := 3;

    IF VDESERROR IS NOT NULL THEN
      VTRAZA   := 5;
      VNUM_ERR := PAC_GESTION_PROCESOS.F_SET_CARGA_CTRL_CABECERA(V_SPROCES,
                                                                 P_NOMBRE,
                                                                 F_SYSDATE,
                                                                 NULL,
                                                                 1,
                                                                 P_CPROCES,
                                                                 NULL,
                                                                 VDESERROR);
      VTRAZA   := 51;

      IF VNUM_ERR <> 0 THEN
        P_TAB_ERROR(F_SYSDATE,
                    F_USER,
                    VOBJ,
                    VTRAZA,
                    VNUM_ERR,
                    'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera2');
        VNNUMLIN := NULL;
        VNUM_ERR := F_PROCESLIN(V_SPROCES,
                                F_AXIS_LITERALES(180856, K_IDIOMAAAXIS) || ':' ||
                                P_NOMBRE || ' : ' || VNUM_ERR,
                                1,
                                VNNUMLIN); -- NEED TO ADD DIFFERENT MSG
        RAISE ERRORINI;
      END IF;

      VTRAZA := 52;
      COMMIT;
      RAISE VSALIR;
    END IF;

    COMMIT;
    RETURN 0;
  EXCEPTION
    WHEN VSALIR THEN
      NULL;
      RETURN 1;
    WHEN E_ERRDATOS THEN
      ROLLBACK;
      PAC_CARGAS_CONF.P_GENERA_LOGS(VOBJ,
                                    VTRAZA,
                                    'Error:' || VNUM_ERR,
                                    VDESERROR,
                                    PSPROCES,
                                    'Error:' || VNUM_ERR || ' ' ||
                                    VDESERROR);
      COMMIT;
      RETURN 1;
    WHEN ERRORINI THEN
      ROLLBACK;
      P_TAB_ERROR(F_SYSDATE,
                  F_USER,
                  VOBJ,
                  VTRAZA,
                  'Error:' || 'ErrorIni' || ' en :' || 1,
                  'Error:' || 'Insertando estados registros');
      VNUM_ERR := F_PROCESLIN(V_SPROCES,
                              F_AXIS_LITERALES(108953, K_IDIOMAAAXIS) || ':' ||
                              P_NOMBRE || ' : ' || 'errorini',
                              1,
                              VNNUMLIN); -- NEED TO CHANGE MSG
      COMMIT;
      RETURN 1;
    WHEN OTHERS THEN
      ROLLBACK;

      P_TAB_ERROR(F_SYSDATE,
                  F_USER,
                  VOBJ,
                  VTRAZA,
                  'Error:' || SQLERRM || ' en :' || 1,
                  'Error:' || SQLERRM);
      VNUM_ERR := F_PROCESLIN(V_SPROCES,
                              F_AXIS_LITERALES(103187, K_IDIOMAAAXIS) || ':' ||
                              P_NOMBRE || ' : ' || SQLERRM,
                              1,
                              VNNUMLIN); -- NEED TO CHANGE MSG
      VNUM_ERR := PAC_GESTION_PROCESOS.F_SET_CARGA_CTRL_CABECERA(V_SPROCES,
                                                                 P_NOMBRE,
                                                                 F_SYSDATE,
                                                                 NULL,
                                                                 1,
                                                                 P_CPROCES,
                                                                 151541,
                                                                 SQLERRM); -- NEED TO CHANGE MSG
      VTRAZA   := 51;

      IF VNUM_ERR <> 0 THEN
        P_TAB_ERROR(F_SYSDATE,
                    F_USER,
                    VOBJ,
                    VTRAZA,
                    VNUM_ERR,
                    'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera2');
        VNNUMLIN := NULL;
        VNUM_ERR := F_PROCESLIN(V_SPROCES,
                                F_AXIS_LITERALES(180856, K_IDIOMAAAXIS) || ':' ||
                                P_NOMBRE || ' : ' || VNUM_ERR,
                                1,
                                VNNUMLIN); -- NEED TO CHANGE MSG
      END IF;

      COMMIT;
      RETURN 1;
  END F_EJECUTAR_CARGA_DATASARLAF_N;

  PROCEDURE P_CARGA_DATSARLAF_N(PRUTA         IN VARCHAR2,
                                P_NOMBRE      IN VARCHAR2,
                                P_CPROCES     IN NUMBER,
                                P_SPROCES     IN NUMBER,
                                PCOUNTFAIL    OUT NUMBER,
                                PCOUNTSUCCESS OUT NUMBER,
                                PERROR        OUT NUMBER) IS

    VCOUNTDSN NUMBER := 0;
    VNUMERR   NUMBER(8) := 0;
    VMENSAJES T_IAX_MENSAJES;

    VNOMBRECARGARDSN VARCHAR2(500);
    VCARGARDSN       UTL_FILE.FILE_TYPE;
    VLINEA           VARCHAR2(200);
    VSPERSON         PER_PERSONAS.SPERSON%TYPE;
    VSSARLAFT        DATSARLATF.SSARLAFT%TYPE;
    V_MSG            VARCHAR2(500);
    V_NUM_LIN        NUMBER := 0;

    VTPROVIN Provincias.TPROVIN%TYPE;
    VTPOBLAC POBLACIONES.TPOBLAC%TYPE;

    VTVINCULACION DETVALORES.TATRIBU%TYPE;
    VCVINCULACION DATSARLATF.CVINCULACION%TYPE;

    VTDEPART_EXPED_IB      PROVINCIAS.TPROVIN%TYPE;
    VTLUGAR_EXPED_IB       POBLACIONES.TPOBLAC%TYPE;
    VTDEPART_LUGAR_NACI_IB PROVINCIAS.TPROVIN%TYPE;
    VTLUGAR_NACI_IB        POBLACIONES.TPOBLAC%TYPE;

    VTNACIONALIDAD1_IB PAISES.TPAIS%TYPE;
    VTNACIONALIDAD2_IB PAISES.TPAIS%TYPE;

    VTPAIS_EXPED_IB      PAISES.TPAIS%TYPE;
    VTPAIS_LUGAR_NACI_IB PAISES.TPAIS%TYPE;

    VTPAISE_RESID_IB  PAISES.TPAIS%TYPE;
    VTDEPART_RESID_IB PROVINCIAS.TPROVIN%TYPE;
    VTCIUDAD_RESID_IB POBLACIONES.TPOBLAC%TYPE;

    VTPAIS_OI   PAISES.TPAIS%TYPE;
    VTPROVIN_OI PROVINCIAS.TPROVIN%TYPE;
    VTPOBLAC_OI POBLACIONES.TPOBLAC%TYPE;

    VTDEPART_OFFICE_IB PROVINCIAS.TPROVIN%TYPE;
    VTCIUDAD_OFFICE_IB POBLACIONES.TPOBLAC%TYPE;

    VCVINTOMASE         DATSARLATF.CVINTOMASE%TYPE := NULL;
    VCVINTOMBEN         DATSARLATF.CVINTOMBEN%TYPE := NULL;
    VCVINASEBEN         DATSARLATF.CVINASEBEN%TYPE := NULL;
    VCLASE_VIN          VARCHAR2(200) := NULL;
    VIDENTIFICACION     NUMBER := NULL;
    VNACTIVI_DSACT      NUMBER := NULL;
    VTPAIS              PAISES.TPAIS%TYPE;
    VCPAIS              PAISES.CPAIS%TYPE;
    VIDENTIFICACION_PEP SARLATFPEP.IDENTIFICACION%TYPE;
    VIDENTIFICACION_BEN SARLATFBEN.IDENTIFICACION%TYPE;
    VIDENTIFICACION_ACT DETSARLATF_ACT.NACTIVI%TYPE;
    VNRECLA             DETSARLAFT_REC.NRECLA%TYPE;
    VTSUCURSAL          DATSARLATF.TSUCURSAL%TYPE;
    VCSUCURSAL          DATSARLATF.CSUCURSAL%TYPE;

    VPASEXEC NUMBER(8) := 0;
    VPARAM   VARCHAR2(4000) := 'parametros - Cargar Natual : ';
    VOBJECT  VARCHAR2(200) := 'pac_cargas_conf.p_carga_Datsarlf_N';

    CURSOR CUR_CARGAR_DATSARLF_N IS
      SELECT * FROM DATOS_SARLAF_N_EXT;

  BEGIN
    SELECT COUNT(*) INTO VCOUNTDSN FROM DATOS_SARLAF_N_EXT;
    DBMS_OUTPUT.PUT_LINE('vcountDSN ::' || VCOUNTDSN);

    VNOMBRECARGARDSN := 'Cargar_DSN_Mal_Datao_' ||
                        TO_CHAR(F_SYSDATE, 'yyyymmdd_hh24miss') || '.txt';
    VCARGARDSN       := UTL_FILE.FOPEN(PRUTA, VNOMBRECARGARDSN, 'w');
    VLINEA           := 'IDENTIFICACION|NOMBRE|DESCRIPCION';
    UTL_FILE.PUT_LINE(VCARGARDSN, VLINEA);

    PCOUNTFAIL    := 0;
    PCOUNTSUCCESS := 0;

    IF VCOUNTDSN > 0 THEN
      FOR I IN CUR_CARGAR_DATSARLF_N LOOP
        V_NUM_LIN := V_NUM_LIN + 1;

        begin
          SELECT P.SPERSON
            INTO VSPERSON
            FROM PER_PERSONAS P
           WHERE P.NNUMIDE LIKE '%' || i.itomador || '%'
       AND ROWNUM = 1;
        exception
          when no_data_found then
            VSPERSON := null;
        end;

        IF VSPERSON IS NOT NULL THEN
          begin
            SELECT D.SSARLAFT
              INTO VSSARLAFT
              FROM DATSARLATF D
             WHERE D.FDILIGENCIA =
                   (SELECT MAX(FDILIGENCIA)
                      FROM DATSARLATF
                     WHERE SPERSON = VSPERSON)
               AND D.SPERSON = VSPERSON
         AND ROWNUM = 1;
          exception
            when no_data_found then
              VSSARLAFT := null;
          end;

          IF VSSARLAFT IS NULL THEN
            SELECT SSARLAFT.NEXTVAL INTO VSSARLAFT FROM DUAL;
          END IF;

          -- CABECERA        
          VPASEXEC := 1;

          begin
            if i.departamento_cb is not null then
              SELECT P.Tprovin
                INTO VTPROVIN
                FROM PROVINCIAS P
               WHERE P.CPROVIN = i.departamento_cb
                 AND ROWNUM = 1;
            else
              VTPROVIN := null;
            end if;
          exception
            when no_data_found then
              VTPROVIN := null;
          end;

          begin
            if i.ciudad_cb is not null then
              SELECT P.TPOBLAC
                INTO VTPOBLAC
                FROM POBLACIONES P
               WHERE P.Cpoblac = i.ciudad_cb
                 and P.CPROVIN = i.departamento_cb
                 AND ROWNUM = 1;
            else
              VTPOBLAC := null;
            end if;
          exception
            when no_data_found then
              VTPOBLAC := null;
          end;

          begin
            if i.TIPO_SOLICITUD_CB is not null then
              SELECT D.TATRIBU
                INTO VTVINCULACION
                FROM DETVALORES D
               WHERE D.CIDIOMA = 8
                 AND D.CATRIBU = I.TIPO_SOLICITUD_CB
                 AND D.CVALOR = 790001;
            else
              VTVINCULACION := null;
            end if;
          exception
            when no_data_found then
              VTVINCULACION := null;
          end;

          begin
            if i.sucursal_cb is not null then
              SELECT F_DESAGENTE_T(PAC_AGENTES.F_GET_CAGELIQ(24,
                                                             2,
                                                             R.CAGENTE)) TSUCURSAL,
                     R.CAGENTE CSUCURSAL
                INTO VTSUCURSAL, VCSUCURSAL
                FROM REDCOMERCIAL R
               WHERE R.CTIPAGE = 2
                 AND R.CAGENTE = i.sucursal_cb
                 AND ROWNUM = 1;
            else
              VTSUCURSAL := null;
              VCSUCURSAL := null;
            end if;
          exception
            when no_data_found then
			/* Cambios de IAXIS-4732 : Starts */
              begin 
                SELECT F_DESAGENTE_T(PAC_AGENTES.F_GET_CAGELIQ(24,
                                                               3,
                                                               R.CAGENTE)) TSUCURSAL,
                       R.CAGENTE CSUCURSAL
                  INTO VTSUCURSAL, VCSUCURSAL
                  FROM REDCOMERCIAL R
                 WHERE R.CTIPAGE = 3
                   AND R.CAGENTE = i.sucursal_cb
                   AND ROWNUM = 1;
              exception
              when no_data_found then  
              VTSUCURSAL := null;
              VCSUCURSAL := null;
              end;
            /* Cambios de IAXIS-4732 : Ends */              
          end;

          IF I.CLASE_OTRO_CB IS NULL THEN
            IF UPPER(I.CLASE_VIN_CB) = UPPER('Tomador') THEN
              VCVINCULACION := 1;
            ELSIF UPPER(I.CLASE_VIN_CB) = UPPER('Beneficiario') THEN
              VCVINCULACION := 2;
            ELSIF UPPER(I.CLASE_VIN_CB) = UPPER('Proveedor') THEN
              VCVINCULACION := 3;
            ELSIF UPPER(I.CLASE_VIN_CB) = UPPER('Asegurado') THEN
              VCVINCULACION := 4;
            ELSIF UPPER(I.CLASE_VIN_CB) = UPPER('Afianzado') THEN
              VCVINCULACION := 5;
            ELSIF UPPER(I.CLASE_VIN_CB) = UPPER('Intermediario') THEN
              VCVINCULACION := 6;
            ELSE
              VCVINCULACION := 7;
            END IF;
          ELSE
            VCLASE_VIN := NULL;
          END IF;

          IF UPPER(I.ASE_OTRO_CB) IS NULL THEN
            IF UPPER(I.TOMADOR_ASEG_CB) = UPPER('Familiar') THEN
              VCVINTOMASE := 1;
            ELSIF UPPER(I.TOMADOR_ASEG_CB) = UPPER('Comercial') THEN
              VCVINTOMASE := 2;
            ELSIF UPPER(I.TOMADOR_ASEG_CB) = UPPER('Laboral') THEN
              VCVINTOMASE := 3;
            END IF;
          ELSE
            VCVINTOMASE := 4;
          END IF;

          IF UPPER(I.BENE_OTRO_CB) IS NULL THEN
            IF UPPER(I.TOMADOR_BENE_CB) = UPPER('Familiar') THEN
              VCVINTOMBEN := 1;
            ELSIF UPPER(I.TOMADOR_BENE_CB) = UPPER('Comercial') THEN
              VCVINTOMBEN := 2;
            ELSIF UPPER(I.TOMADOR_BENE_CB) = UPPER('Laboral') THEN
              VCVINTOMBEN := 3;
            END IF;
          ELSE
            VCVINTOMBEN := 4;
          END IF;

          IF UPPER(I.ASE_BEN_OTRO_CB) IS NULL THEN
            IF UPPER(I.ASEGU_BENEFICIARIO_CB) = UPPER('Familiar') THEN
              VCVINASEBEN := 1;
            ELSIF UPPER(I.ASEGU_BENEFICIARIO_CB) = UPPER('Comercial') THEN
              VCVINASEBEN := 2;
            ELSIF UPPER(I.ASEGU_BENEFICIARIO_CB) = UPPER('Laboral') THEN
              VCVINASEBEN := 3;
            END IF;
          ELSE
            VCVINASEBEN := 4;
          END IF;

          -- INFORMACION BASICA
          VPASEXEC := 2;
          begin
            if i.pais_exped_ib is not null then
              SELECT P.Tpais
                INTO VTPAIS_EXPED_IB
                FROM paises P
               WHERE P.Cpais = i.pais_exped_ib
                 AND ROWNUM = 1;
            else
              VTPAIS_EXPED_IB := null;
            end if;
          exception
            when no_data_found then
              VTPAIS_EXPED_IB := null;
          end;

          begin
            if i.depart_exped_ib is not null then
              SELECT P.TPROVIN
                INTO VTDEPART_EXPED_IB
                FROM PROVINCIAS P
               WHERE P.CPROVIN = i.depart_exped_ib
                 AND ROWNUM = 1;
            else
              VTDEPART_EXPED_IB := null;
            end if;
          exception
            when no_data_found then
              VTDEPART_EXPED_IB := null;
          end;

          begin
            if i.lugar_expedicion_ib is not null then
              SELECT P.TPOBLAC
                INTO VTLUGAR_EXPED_IB
                FROM POBLACIONES P
               WHERE P.CPOBLAC = i.lugar_expedicion_ib
               and P.CPROVIN = i.depart_exped_ib 
                 AND ROWNUM = 1;
            else
              VTLUGAR_EXPED_IB := null;
            end if;
          exception
            when no_data_found then
              VTLUGAR_EXPED_IB := null;
          end;

          begin
            if i.pais_lugar_naci_ib is not null then
              SELECT P.Tpais
                INTO VTPAIS_Lugar_naci_IB
                FROM paises P
               WHERE P.Cpais = i.pais_lugar_naci_ib
                 AND ROWNUM = 1;
            else
              VTPAIS_Lugar_naci_IB := null;
            end if;
          exception
            when no_data_found then
              VTPAIS_Lugar_naci_IB := null;
          end;

          begin
            if i.depart_lugar_naci_ib is not null then
              SELECT P.TPROVIN
                INTO VTDEPART_LUGAR_NACI_IB
                FROM PROVINCIAS P
               WHERE P.CPROVIN = i.depart_lugar_naci_ib
                 AND ROWNUM = 1;
            else
              VTDEPART_LUGAR_NACI_IB := null;
            end if;
          exception
            when no_data_found then
              VTDEPART_LUGAR_NACI_IB := null;
          end;

          begin
            if i.lugar_nacimiento_ib is not null then
              SELECT P.TPOBLAC
                INTO VTLUGAR_NACI_IB
                FROM POBLACIONES P
               WHERE P.CPOBLAC = i.lugar_nacimiento_ib
                 and P.CPROVIN = i.depart_lugar_naci_ib 
                 AND ROWNUM = 1;
            else
              VTLUGAR_NACI_IB := null;
            end if;
          exception
            when no_data_found then
              VTLUGAR_NACI_IB := null;
          end;

          begin
            if i.pais_residencia_ib is not null then
              SELECT P.Tpais
                INTO VTPAISE_RESID_IB
                FROM paises P
               WHERE P.Cpais = i.pais_residencia_ib
                 AND ROWNUM = 1;
            else
              VTPAISE_RESID_IB := null;
            end if;
          exception
            when no_data_found then
              VTPAISE_RESID_IB := null;
          end;

          begin
            if i.dep_residencia_ib is not null then
              SELECT P.TPROVIN
                INTO VTDEPART_RESID_IB
                FROM PROVINCIAS P
               WHERE P.CPROVIN = i.dep_residencia_ib
                 AND ROWNUM = 1;
            else
              VTDEPART_RESID_IB := null;
            end if;
          exception
            when no_data_found then
              VTDEPART_RESID_IB := null;
          end;

          begin
            if i.ciudad_residencia_ib is not null then
              SELECT P.TPOBLAC
                INTO VTCIUDAD_RESID_IB
                FROM POBLACIONES P
               WHERE P.CPOBLAC = i.ciudad_residencia_ib
                 and P.CPROVIN = i.dep_residencia_ib                
                 AND ROWNUM = 1;
            else
              VTCIUDAD_RESID_IB := null;
            end if;
          exception
            when no_data_found then
              VTCIUDAD_RESID_IB := null;
          end;

          begin
            if i.nacionalidad1_ib is not null then
              SELECT P.Tpais
                INTO VTNACIONALIDAD1_IB
                FROM paises P
               WHERE P.CPAIS = i.nacionalidad1_ib
                 AND ROWNUM = 1;
            else
              VTNACIONALIDAD1_IB := null;
            end if;
          exception
            when no_data_found then
              VTNACIONALIDAD1_IB := null;
          end;

          begin
            if i.nacionalidad2_ib is not null then
              SELECT P.Tpais
                INTO VTNACIONALIDAD2_IB
                FROM paises P
               WHERE P.CPAIS = i.nacionalidad2_ib
                 AND ROWNUM = 1;
            else
              VTNACIONALIDAD2_IB := null;
            end if;
          exception
            when no_data_found then
              VTNACIONALIDAD2_IB := null;
          end;

          begin
            if i.DEP_EMPRESA_PN_IB is not null then
              SELECT P.TPROVIN
                INTO VTDEPART_OFFICE_IB
                FROM PROVINCIAS P
               WHERE P.CPROVIN = i.DEP_EMPRESA_PN_IB
                 AND ROWNUM = 1;
            else
              VTDEPART_OFFICE_IB := null;
            end if;
          exception
            when no_data_found then
              VTDEPART_OFFICE_IB := null;
          end;

          begin
            if i.ciuda_emp_pn_ib is not null then
              SELECT P.TPOBLAC
                INTO VTCIUDAD_OFFICE_IB
                FROM POBLACIONES P
               WHERE P.CPOBLAC = i.ciuda_emp_pn_ib
                 and P.CPROVIN = i.DEP_EMPRESA_PN_IB
                 AND ROWNUM = 1;
            else
              VTCIUDAD_OFFICE_IB := null;
            end if;
          exception
            when no_data_found then
              VTCIUDAD_OFFICE_IB := null;
          end;

          BEGIN
            VPASEXEC := 10;
            /*VPARAM   := 'vssarlaft                 : ' || VSSARLAFT ||
            ' : vsperson               : ' || VSPERSON ||
            ' : fecha_dilimiento_cb    : ' ||
            I.FECHA_DILIMIENTO_CB ||
            ' : estado_confirmacion_ci : ' ||
            I.ESTADO_CONFIRMACION_CI ||
            ' : Fecha_Confirmacion_Ci  : ' ||
            I.FECHA_CONFIRMACION_CI ||
            ' : vcvinculacion          : ' || VCVINCULACION ||
            ' : clase_otro_cb          : ' || I.CLASE_OTRO_CB ||
            ' : vcvintomase            : ' || VCVINTOMASE ||
            ' : ase_otro_cb            : ' || I.ASE_OTRO_CB ||
            ' : vcvintomben            : ' || VCVINTOMBEN ||
            ' : bene_otro_cb           : ' || I.BENE_OTRO_CB ||
            ' : vcvinaseben            : ' || VCVINASEBEN ||
            ' : ase_ben_otro_cb        : ' || I.ASE_BEN_OTRO_CB ||
            ' : act_sec_pn_ib          : ' || I.ACT_SEC_PN_IB ||
            ' : sector_ib              : ' || I.SECTOR_IB ||
            ' : ciiu_cod_ib            : ' || I.CIIU_COD_IB ||
            ' : ciiu_actividad_ib      : ' ||
            I.CIIU_ACTIVIDAD_IB ||
            ' : tipo_actividad_ib      : ' ||
            I.TIPO_ACTIVIDAD_IB ||
            ' : ocupacion_ib           : ' || I.OCUPACION_IB ||
            ' : cargo_ib               : ' || I.CARGO_IB ||
            ' : emp_tra_pn_ib          : ' || I.EMP_TRA_PN_IB ||
            ' : dir_emp_pn_ib          : ' || I.DIR_EMP_PN_IB ||
            ' : vcdepart_office_ib     : ' ||
            VCDEPART_OFFICE_IB ||
            ' : departmento_oi         : ' || I.DEPARTMENTO_OI ||
            ' : vcciudad_office_ib     : ' ||
            VCCIUDAD_OFFICE_IB ||
            ' : ciudad_oi              : ' || I.CIUDAD_OI ||
            ' : tele_empresa_pn_ib     : ' ||
            I.TELE_EMPRESA_PN_IB ||
            ' : act_sec_pn_ib          : ' || I.ACT_SEC_PN_IB ||
            ' : ciiu_cod_ib            : ' || I.CIIU_COD_IB ||
            ' : ciiu_actividad_ib      : ' ||
            I.CIIU_ACTIVIDAD_IB ||
            ' : tipo_producto_oi       : ' ||
            I.TIPO_PRODUCTO_OI ||
            ' : ingresos_mensuales_ib  : ' ||
            I.INGRESOS_MENSUALES_IB ||
            ' : activos_ib             : ' || I.ACTIVOS_IB ||
            ' : patrimonio_ib          : ' || I.PATRIMONIO_IB ||
            ' : egresos_mensuales_ib   : ' ||
            I.EGRESOS_MENSUALES_IB ||
            ' : pasivos_ib             : ' || I.PASIVOS_IB ||
            ' : otros_ingresos_ib      : ' ||
            I.OTROS_INGRESOS_IB ||
            ' : con_otr_ing_ib         : ' || I.CON_OTR_ING_IB ||
            ' : por_cargo_ib           : ' || I.POR_CARGO_IB ||
            ' : usted_una_ib           : ' || I.USTED_UNA_IB ||
            ' : existe_vinculo_ib      : ' ||
            I.EXISTE_VINCULO_IB ||
            ' : realiza_transacciones_oi : ' ||
            I.REALIZA_TRANSACCIONES_OI ||
            ' : si_cual_oi             : ' || I.SI_CUAL_OI ||
            ' : posee_productos_oi     : ' ||
            I.POSEE_PRODUCTOS_OI ||
            ' : poseee_cuentas_oi      : ' ||
            I.POSEEE_CUENTAS_OI ||
            ' : otras_indique_oi       : ' ||
            I.OTRAS_INDIQUE_OI ||
            ' : vtsucursal             : ' || VTSUCURSAL ||
            ' : primer_apellido_ib     : ' ||
            I.PRIMER_APELLIDO_IB ||
            ' : segundo_apellido_ib    : ' ||
            I.SEGUNDO_APELLIDO_IB ||
            ' : nombres_ib           : ' || I.NOMBRES_IB ||
            ' : tipo_documento_ib      : ' ||
            I.TIPO_DOCUMENTO_IB ||
            ' : numero_ib              : ' || I.NUMERO_IB ||
            ' : fecha_expedicion       : ' ||
            I.FECHA_EXPEDICION ||
            ' : vclugar_exped_ib       : ' || VCLUGAR_EXPED_IB ||
            ' : fecha_nacimiento       : ' ||
            I.FECHA_NACIMIENTO ||
            ' : vclugar_naci_ib        : ' || VCLUGAR_NACI_IB ||
            ' : vcnacionalidad1_ib     : ' ||
            VCNACIONALIDAD1_IB ||
            ' : direccion_residencia_ib  : ' ||
            I.DIRECCION_RESIDENCIA_IB ||
            ' : vcpaise_resid_ib       : ' || VCPAISE_RESID_IB ||
            ' : vcciudad_resid_ib      : ' || VCCIUDAD_RESID_IB ||
            ' : vcdepart_resid_ib      : ' || VCDEPART_RESID_IB ||
            ' : email_ib         : ' || I.EMAIL_IB ||
            ' : telefono_residencia_ib  : ' ||
            I.TELEFONO_RESIDENCIA_IB ||
            ' : celular_ib           : ' || I.CELULAR_IB ||
            ' : pre_reclamacion_rs     : ' ||
            I.PRE_RECLAMACION_RS ||
            ' : lugar_expedicion_ib    : ' ||
            I.LUGAR_EXPEDICION_IB ||
            ' : lugar_nacimiento_ib    : ' ||
            I.LUGAR_NACIMIENTO_IB ||
            ' : nacionalidad1_ib     : ' || I.NACIONALIDAD1_IB ||
            ' : nacionalidad2_ib       : ' ||
            I.NACIONALIDAD2_IB || ' : pais_oi          : ' ||
            I.PAIS_OI || ' : departmento_oi         : ' ||
            I.DEPARTMENTO_OI || ' : ciudad_oi        : ' ||
            I.CIUDAD_OI || ' : usted_sujeto_ib      : ' ||
            I.USTED_SUJETO_IB || ' : cuales_ib          : ' ||
            I.CUALES_IB || ' : vcdepart_exped_ib      : ' ||
            VCDEPART_EXPED_IB || ' : depart_exped_ib        : ' ||
            I.DEPART_EXPED_IB || ' : vcdepart_lugar_naci_ib : ' ||
            VCDEPART_LUGAR_NACI_IB ||
            ' : depart_lugar_naci_ib   : ' ||
            I.DEPART_LUGAR_NACI_IB ||
            ' : vcnacionalidad2_ib     : ' ||
            VCNACIONALIDAD2_IB || ' : vcsucursal           : ' ||
            VCSUCURSAL || ' : tipo_solicitud_cb      : ' ||
            I.TIPO_SOLICITUD_CB ||
            ' : declar_fondos_df       : ' ||
            I.DECLAR_FONDOS_DF || ' : autoriza_1_ca      : ' ||
            I.AUTORIZA_1_CA || ' : autoriza_2_ca      : ' ||
            I.AUTORIZA_2_CA;*/

            VNUMERR := PAC_MD_PERSONA.F_SET_DATSARLATF(VSSARLAFT,
                                                       F_SYSDATE,
                                                       VSPERSON,
                                                       NVL(TO_DATE(I.FECHA_DILIMIENTO_CB,
                                                                   'dd/mm/yyyy'),
                                                           NULL),
                                                       NULL,
                                                       NULL,
                                                       I.ESTADO_CONFIRMACION_CI,
                                                       NVL(TO_DATE(I.FECHA_CONFIRMACION_CI,
                                                                   'dd/mm/yyyy'),
                                                           NULL),
                                                       VCVINCULACION,
                                                       I.CLASE_OTRO_CB,
                                                       i.departamento_cb,
                                                       VTPROVIN,
                                                       i.ciudad_cb,
                                                       VTPOBLAC,
                                                       VCVINTOMASE,
                                                       I.ASE_OTRO_CB,
                                                       VCVINTOMBEN,
                                                       I.BENE_OTRO_CB,
                                                       VCVINASEBEN,
                                                       I.ASE_BEN_OTRO_CB,
                                                       I.Actividad_Principal_Ib, /* Cambios de IAXIS-4732 */
                                                       I.SECTOR_IB,
                                                       I.CIIU_COD_IB,
                                                       I.CIIU_ACTIVIDAD_IB,
                                                       I.TIPO_ACTIVIDAD_IB,
                                                       I.OCUPACION_IB,
                                                       I.CARGO_IB,
                                                       I.EMP_TRA_PN_IB,
                                                       I.DIR_EMP_PN_IB,
                                                       I.DEP_EMPRESA_PN_IB,
                                                       VTDEPART_OFFICE_IB,
                                                       i.CIUDA_EMP_PN_IB,
                                                       VTCIUDAD_OFFICE_IB,
                                                       I.TELE_EMPRESA_PN_IB,
                                                       I.ACT_SEC_PN_IB,
                                                       I.CIIU_SEC_PN_IB,
                                                       null, -- text ciiu sec_pn
                                                       NULL,
                                                       NULL,
                                                       I.PRODUCTO_SERVICIO_IB,
                                                       I.INGRESOS_MENSUALES_IB,
                                                       I.ACTIVOS_IB,
                                                       I.PATRIMONIO_IB,
                                                       I.EGRESOS_MENSUALES_IB,
                                                       I.PASIVOS_IB,
                                                       I.OTROS_INGRESOS_IB,
                                                       I.CON_OTR_ING_IB,
                                                       I.POR_CARGO_IB,
                                                       I.USTED_UNA_IB,
                                                       NULL,
                                                       I.EXISTE_VINCULO_IB,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       I.REALIZA_TRANSACCIONES_OI,
                                                       I.SI_CUAL_OI,
                                                       I.POSEE_PRODUCTOS_OI,
                                                       I.POSEEE_CUENTAS_OI,
                                                       I.OTRAS_INDIQUE_OI,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       VTSUCURSAL,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       I.PRIMER_APELLIDO_IB,
                                                       I.SEGUNDO_APELLIDO_IB,
                                                       I.NOMBRES_IB,
                                                       I.TIPO_DOCUMENTO_IB,
                                                       I.NUMERO_IB,
                                                       NVL(TO_DATE(I.FECHA_EXPEDICION_IB,
                                                                   'dd/mm/yyyy'),
                                                           NULL),
                                                       i.lugar_expedicion_ib,
                                                       NVL(TO_DATE(I.FECHA_NACIMIENTO_IB,
                                                                   'dd/mm/yyyy'),
                                                           NULL),
                                                       i.lugar_nacimiento_ib,
                                                       i.nacionalidad1_ib,
                                                       I.DIRECCION_RESIDENCIA_IB,
                                                       I.PAIS_RESIDENCIA_IB,
                                                       I.Ciudad_Residencia_Ib,
                                                       i.dep_residencia_ib,
                                                       I.EMAIL_IB,
                                                       I.TELEFONO_RESIDENCIA_IB,
                                                       I.CELULAR_IB,
                                                       NULL,
                                                       I.PRE_RECLAMACION_RS,
                                                       VTLUGAR_EXPED_IB,
                                                       VTLUGAR_NACI_IB,
                                                       VTNACIONALIDAD1_IB,
                                                       VTNACIONALIDAD2_IB,
                                                       VTPAISE_RESID_IB,
                                                       VTDEPART_RESID_IB,
                                                       VTCIUDAD_RESID_IB,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       I.USTED_SUJETO_IB,
                                                       null, --I.CUALES_IB,/* Cambios para IAXIS-4732 */
                                                       i.pais_exped_ib,
                                                       VTPAIS_EXPED_IB,
                                                       I.DEPART_EXPED_IB,
                                                       VTDEPART_EXPED_IB,
                                                       i.pais_lugar_naci_ib,
                                                       VTPAIS_LUGAR_NACI_IB,
                                                       I.DEPART_LUGAR_NACI_IB,
                                                       VTDEPART_LUGAR_NACI_IB,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       i.nacionalidad2_ib,
                                                       NULL,
                                                       VCSUCURSAL,
                                                       I.TIPO_SOLICITUD_CB,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       NVL(TO_DATE(I.Fecha_Entrevista_Ie,'dd/mm/yyyy'),NULL),/* Cambio de IAXIS-4732 */
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       I.resultado_ie, /* Cambio de IAXIS-4732 */
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       I.DECLAR_FONDOS_DF,
                                                       I.AUTORIZA_1_CA,
                                                       I.AUTORIZA_2_CA,
                                                       null,
                                                       VMENSAJES);
            IF VNUMERR <> 0 THEN
              VLINEA := I.ITOMADOR || '|' || UPPER(I.NTOMADOR) ||
                        '|Error en Información de datsarlaf para natural persona.';
              UTL_FILE.PUT_LINE(VCARGARDSN, VLINEA);

              VNUMERR    := PAC_GESTION_PROCESOS.F_SET_CARGA_CTRL_LINEA(PSPROCES   => P_SPROCES,
                                                                        PNLINEA    => V_NUM_LIN,
                                                                        PCTIPO     => 3,
                                                                        PIDINT     => V_NUM_LIN,
                                                                        PIDEXT     => V_NUM_LIN,
                                                                        PCESTADO   => 1,
                                                                        PCVALIDADO => NULL,
                                                                        PSSEGURO   => NULL,
                                                                        PIDEXTERNO => NULL,
                                                                        PNCARGA    => NULL,
                                                                        PNSINIES   => NULL,
                                                                        PNTRAMIT   => NULL,
                                                                        PSPERSON   => VSPERSON,
                                                                        PNRECIBO   => NULL);
              PCOUNTFAIL := PCOUNTFAIL + 1;
              CONTINUE;
            ELSE
              -- CONOCIMIENTO MEJORADO DE PERSONAS EXPUESTAS PÚBLICAMENTE
              VPASEXEC := 3;
              IF I.NUMERO_IDEN_1_PEP IS NOT NULL AND
                 I.NOMBRE_COMPLETO_1_PEP IS NOT NULL THEN
                begin
                  if i.NACIONALIDAD_1_PEP is not null then
                    SELECT P.TPAIS
                      INTO VTPAIS
                      FROM PAISES P
                     WHERE P.CPAIS = I.NACIONALIDAD_1_PEP
                       AND ROWNUM = 1;
                  else
                    VTPAIS := null;
                  end if;
                exception
                  when no_data_found then
                    VTPAIS := null;
                end;

                begin
                  SELECT MAX(SP.IDENTIFICACION)
                    INTO VIDENTIFICACION_PEP
                    FROM SARLATFPEP SP
                   WHERE SP.NNUMIDE = I.NUMERO_IDEN_1_PEP
                     AND SP.SSARLAFT = VSSARLAFT;
                exception
                  when no_data_found then
                    VIDENTIFICACION_PEP := null;
                end;
                BEGIN
                  VPASEXEC := 4;
                  VPARAM   := 'vssarlaft : ' || VSSARLAFT ||
                              ' : videntificacion_PEP : ' ||
                              VIDENTIFICACION_PEP ||
                              ' : vinculo_relacion_1_pep : ' ||
                              I.VINCULO_RELACION_1_PEP ||
                              ' : nombre_completo_1_pep : ' ||
                              I.NOMBRE_COMPLETO_1_PEP ||
                              ' : tipo_iden_1_pep : ' || I.TIPO_IDEN_1_PEP ||
                              ' : numero_iden_1_pep : ' ||
                              I.NUMERO_IDEN_1_PEP ||
                              ' : nacionalidad_1_pep : ' ||
                              I.NACIONALIDAD_1_PEP || ' : VTPAIS : ' ||
                              VTPAIS || ' : entidad_1_pep : ' ||
                              I.ENTIDAD_1_PEP || ' : cargo_1_pep : ' ||
                              I.CARGO_1_PEP || ' : fecha_desvin_1_pep : ' ||
                              I.FECHA_DESVIN_1_PEP;

                  VNUMERR := PAC_MD_PERSONA.F_SET_CPEP_SARLATF(VSSARLAFT,
                                                               VIDENTIFICACION_PEP,
                                                               I.VINCULO_RELACION_1_PEP,
                                                               I.NOMBRE_COMPLETO_1_PEP,
                                                               I.TIPO_IDEN_1_PEP,
                                                               I.NUMERO_IDEN_1_PEP,
                                                               I.NACIONALIDAD_1_PEP,
                                                               VTPAIS,
                                                               I.ENTIDAD_1_PEP,
                                                               I.CARGO_1_PEP,
                                                               NVL(TO_DATE(I.FECHA_DESVIN_1_PEP,
                                                                           'dd/mm/yyyy'),
                                                                   NULL),
                                                               VMENSAJES);
                  IF VNUMERR <> 0 THEN
                    VLINEA := I.ITOMADOR || '|' || UPPER(I.NTOMADOR) ||
                              '|Error en Conocimiento mejorado de personas expuestas públicamente : ' ||
                              I.NUMERO_IDEN_1_PEP;
                    UTL_FILE.PUT_LINE(VCARGARDSN, VLINEA);

                    VNUMERR    := PAC_GESTION_PROCESOS.F_SET_CARGA_CTRL_LINEA(PSPROCES   => P_SPROCES,
                                                                              PNLINEA    => V_NUM_LIN,
                                                                              PCTIPO     => 3,
                                                                              PIDINT     => V_NUM_LIN,
                                                                              PIDEXT     => V_NUM_LIN,
                                                                              PCESTADO   => 1,
                                                                              PCVALIDADO => NULL,
                                                                              PSSEGURO   => NULL,
                                                                              PIDEXTERNO => NULL,
                                                                              PNCARGA    => NULL,
                                                                              PNSINIES   => NULL,
                                                                              PNTRAMIT   => NULL,
                                                                              PSPERSON   => VSPERSON,
                                                                              PNRECIBO   => NULL);
                    PCOUNTFAIL := PCOUNTFAIL + 1;
                    CONTINUE;
                  END IF;
                EXCEPTION
                  WHEN OTHERS THEN
                    PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(VMENSAJES,
                                                      VOBJECT,
                                                      1000001,
                                                      VPASEXEC,
                                                      VPARAM,
                                                      PSQCODE   => SQLCODE,
                                                      PSQERRM   => SQLERRM);
                END;
              END IF;

              IF I.NUMERO_IDEN_2_PEP IS NOT NULL AND
                 I.NOMBRE_COMPLETO_2_PEP IS NOT NULL THEN

                begin
                  if i.NACIONALIDAD_2_PEP is not null then
                    SELECT P.TPAIS
                      INTO VTPAIS
                      FROM PAISES P
                     WHERE P.CPAIS = I.NACIONALIDAD_2_PEP
                       AND ROWNUM = 1;
                  else
                    VTPAIS := null;
                  end if;
                exception
                  when no_data_found then
                    VTPAIS := null;
                end;

                begin
                  SELECT MAX(SP.IDENTIFICACION)
                    INTO VIDENTIFICACION_PEP
                    FROM SARLATFPEP SP
                   WHERE SP.NNUMIDE = I.NUMERO_IDEN_2_PEP
                     AND SP.SSARLAFT = VSSARLAFT;
                exception
                  when no_data_found then
                    VIDENTIFICACION_PEP := null;
                end;

                BEGIN
                  VPASEXEC := 5;
                  VPARAM   := 'vssarlaft : ' || VSSARLAFT ||
                              ' : videntificacion_PEP : ' ||
                              VIDENTIFICACION_PEP ||
                              ' : vinculo_relacion_2_pep : ' ||
                              I.VINCULO_RELACION_2_PEP ||
                              ' : nombre_completo_2_pep : ' ||
                              I.NOMBRE_COMPLETO_2_PEP ||
                              ' : tipo_iden_2_pep : ' || I.TIPO_IDEN_2_PEP ||
                              ' : numero_iden_2_pep : ' ||
                              I.NUMERO_IDEN_2_PEP ||
                              ' : nacionalidad_2_pep : ' ||
                              I.NACIONALIDAD_2_PEP || ' : VTPAIS : ' ||
                              VTPAIS || ' : entidad_2_pep : ' ||
                              I.ENTIDAD_2_PEP || ' : cargo_2_pep : ' ||
                              I.CARGO_2_PEP || ' : fecha_desvin_2_pep : ' ||
                              I.FECHA_DESVIN_2_PEP;

                  VNUMERR := PAC_MD_PERSONA.F_SET_CPEP_SARLATF(VSSARLAFT,
                                                               VIDENTIFICACION_PEP,
                                                               I.VINCULO_RELACION_2_PEP,
                                                               I.NOMBRE_COMPLETO_2_PEP,
                                                               I.TIPO_IDEN_2_PEP,
                                                               I.NUMERO_IDEN_2_PEP,
                                                               I.NACIONALIDAD_2_PEP,
                                                               VTPAIS,
                                                               I.ENTIDAD_2_PEP,
                                                               I.CARGO_2_PEP,
                                                               NVL(TO_DATE(I.FECHA_DESVIN_2_PEP,
                                                                           'dd/mm/yyyy'),
                                                                   NULL),
                                                               VMENSAJES);
                  IF VNUMERR <> 0 THEN
                    VLINEA := I.ITOMADOR || '|' || UPPER(I.NTOMADOR) ||
                              '|Error en Conocimiento mejorado de personas expuestas públicamente : ' ||
                              I.NUMERO_IDEN_2_PEP;
                    UTL_FILE.PUT_LINE(VCARGARDSN, VLINEA);

                    VNUMERR    := PAC_GESTION_PROCESOS.F_SET_CARGA_CTRL_LINEA(PSPROCES   => P_SPROCES,
                                                                              PNLINEA    => V_NUM_LIN,
                                                                              PCTIPO     => 3,
                                                                              PIDINT     => V_NUM_LIN,
                                                                              PIDEXT     => V_NUM_LIN,
                                                                              PCESTADO   => 1,
                                                                              PCVALIDADO => NULL,
                                                                              PSSEGURO   => NULL,
                                                                              PIDEXTERNO => NULL,
                                                                              PNCARGA    => NULL,
                                                                              PNSINIES   => NULL,
                                                                              PNTRAMIT   => NULL,
                                                                              PSPERSON   => VSPERSON,
                                                                              PNRECIBO   => NULL);
                    PCOUNTFAIL := PCOUNTFAIL + 1;
                    CONTINUE;
                  END IF;
                EXCEPTION
                  WHEN OTHERS THEN
                    PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(VMENSAJES,
                                                      VOBJECT,
                                                      1000001,
                                                      VPASEXEC,
                                                      VPARAM,
                                                      PSQCODE   => SQLCODE,
                                                      PSQERRM   => SQLERRM);
                END;
              END IF;

              IF I.NUMERO_IDEN_3_PEP IS NOT NULL AND
                 I.NOMBRE_COMPLETO_3_PEP IS NOT NULL THEN

                begin
                  if i.NACIONALIDAD_3_PEP is not null then
                    SELECT P.TPAIS
                      INTO VTPAIS
                      FROM PAISES P
                     WHERE P.CPAIS = I.NACIONALIDAD_3_PEP
                       AND ROWNUM = 1;
                  else
                    VTPAIS := null;
                  end if;
                exception
                  when no_data_found then
                    VTPAIS := null;
                end;

                begin
                  SELECT MAX(SP.IDENTIFICACION)
                    INTO VIDENTIFICACION_PEP
                    FROM SARLATFPEP SP
                   WHERE SP.NNUMIDE = I.NUMERO_IDEN_3_PEP
                     AND SP.SSARLAFT = VSSARLAFT;
                exception
                  when no_data_found then
                    VIDENTIFICACION_PEP := null;
                end;

                BEGIN
                  VPASEXEC := 6;
                  VPARAM   := 'vssarlaft : ' || VSSARLAFT ||
                              ' : videntificacion_PEP : ' ||
                              VIDENTIFICACION_PEP ||
                              ' : vinculo_relacion_3_pep : ' ||
                              I.VINCULO_RELACION_3_PEP ||
                              ' : nombre_completo_3_pep : ' ||
                              I.NOMBRE_COMPLETO_3_PEP ||
                              ' : tipo_iden_3_pep : ' || I.TIPO_IDEN_3_PEP ||
                              ' : numero_iden_3_pep : ' ||
                              I.NUMERO_IDEN_3_PEP ||
                              ' : nacionalidad_3_pep : ' ||
                              I.NACIONALIDAD_3_PEP || ' : VTPAIS : ' ||
                              VTPAIS || ' : entidad_3_pep : ' ||
                              I.ENTIDAD_3_PEP || ' : cargo_3_pep : ' ||
                              I.CARGO_3_PEP || ' : fecha_desvin_3_pep : ' ||
                              I.FECHA_DESVIN_3_PEP;

                  VNUMERR := PAC_MD_PERSONA.F_SET_CPEP_SARLATF(VSSARLAFT,
                                                               VIDENTIFICACION_PEP,
                                                               I.VINCULO_RELACION_3_PEP,
                                                               I.NOMBRE_COMPLETO_3_PEP,
                                                               I.TIPO_IDEN_3_PEP,
                                                               I.NUMERO_IDEN_3_PEP,
                                                               I.NACIONALIDAD_3_PEP,
                                                               VTPAIS,
                                                               I.ENTIDAD_3_PEP,
                                                               I.CARGO_3_PEP,
                                                               NVL(TO_DATE(I.FECHA_DESVIN_3_PEP,
                                                                           'dd/mm/yyyy'),
                                                                   NULL),
                                                               VMENSAJES);
                  IF VNUMERR <> 0 THEN
                    VLINEA := I.ITOMADOR || '|' || UPPER(I.NTOMADOR) ||
                              '|Error en Conocimiento mejorado de personas expuestas públicamente : ' ||
                              I.NUMERO_IDEN_3_PEP;
                    UTL_FILE.PUT_LINE(VCARGARDSN, VLINEA);

                    VNUMERR    := PAC_GESTION_PROCESOS.F_SET_CARGA_CTRL_LINEA(PSPROCES   => P_SPROCES,
                                                                              PNLINEA    => V_NUM_LIN,
                                                                              PCTIPO     => 3,
                                                                              PIDINT     => V_NUM_LIN,
                                                                              PIDEXT     => V_NUM_LIN,
                                                                              PCESTADO   => 1,
                                                                              PCVALIDADO => NULL,
                                                                              PSSEGURO   => NULL,
                                                                              PIDEXTERNO => NULL,
                                                                              PNCARGA    => NULL,
                                                                              PNSINIES   => NULL,
                                                                              PNTRAMIT   => NULL,
                                                                              PSPERSON   => VSPERSON,
                                                                              PNRECIBO   => NULL);
                    PCOUNTFAIL := PCOUNTFAIL + 1;
                    CONTINUE;
                  END IF;
                EXCEPTION
                  WHEN OTHERS THEN
                    PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(VMENSAJES,
                                                      VOBJECT,
                                                      1000001,
                                                      VPASEXEC,
                                                      VPARAM,
                                                      PSQCODE   => SQLCODE,
                                                      PSQERRM   => SQLERRM);
                END;
              END IF;

              IF I.NUMERO_IDEN_4_PEP IS NOT NULL AND
                 I.NOMBRE_COMPLETO_4_PEP IS NOT NULL THEN

                begin
                  if i.NACIONALIDAD_4_PEP is not null then
                    SELECT P.TPAIS
                      INTO VTPAIS
                      FROM PAISES P
                     WHERE P.CPAIS = I.NACIONALIDAD_4_PEP
                       AND ROWNUM = 1;
                  else
                    VTPAIS := null;
                  end if;
                exception
                  when no_data_found then
                    VTPAIS := null;
                end;

                begin
                  SELECT MAX(SP.IDENTIFICACION)
                    INTO VIDENTIFICACION_PEP
                    FROM SARLATFPEP SP
                   WHERE SP.NNUMIDE = I.NUMERO_IDEN_4_PEP
                     AND SP.SSARLAFT = VSSARLAFT;
                exception
                  when no_data_found then
                    VIDENTIFICACION_PEP := null;
                end;

                BEGIN
                  VPASEXEC := 7;
                  VPARAM   := 'vssarlaft : ' || VSSARLAFT ||
                              ' : videntificacion_PEP : ' ||
                              VIDENTIFICACION_PEP ||
                              ' : vinculo_relacion_4_pep : ' ||
                              I.VINCULO_RELACION_4_PEP ||
                              ' : nombre_completo_4_pep : ' ||
                              I.NOMBRE_COMPLETO_4_PEP ||
                              ' : tipo_iden_4_pep : ' || I.TIPO_IDEN_4_PEP ||
                              ' : numero_iden_4_pep : ' ||
                              I.NUMERO_IDEN_4_PEP ||
                              ' : nacionalidad_4_pep : ' ||
                              I.NACIONALIDAD_4_PEP || ' : VTPAIS : ' ||
                              VTPAIS || ' : entidad_4_pep : ' ||
                              I.ENTIDAD_4_PEP || ' : cargo_4_pep : ' ||
                              I.CARGO_4_PEP || ' : fecha_desvin_4_pep : ' ||
                              I.FECHA_DESVIN_4_PEP;

                  VNUMERR := PAC_MD_PERSONA.F_SET_CPEP_SARLATF(VSSARLAFT,
                                                               VIDENTIFICACION_PEP,
                                                               I.VINCULO_RELACION_4_PEP,
                                                               I.NOMBRE_COMPLETO_4_PEP,
                                                               I.TIPO_IDEN_4_PEP,
                                                               I.NUMERO_IDEN_4_PEP,
                                                               I.NACIONALIDAD_4_PEP,
                                                               VTPAIS,
                                                               I.ENTIDAD_4_PEP,
                                                               I.CARGO_4_PEP,
                                                               NVL(TO_DATE(I.FECHA_DESVIN_4_PEP,
                                                                           'dd/mm/yyyy'),
                                                                   NULL),
                                                               VMENSAJES);
                  IF VNUMERR <> 0 THEN
                    VLINEA := I.ITOMADOR || '|' || UPPER(I.NTOMADOR) ||
                              '|Error en Conocimiento mejorado de personas expuestas públicamente : ' ||
                              I.NUMERO_IDEN_4_PEP;
                    UTL_FILE.PUT_LINE(VCARGARDSN, VLINEA);

                    VNUMERR    := PAC_GESTION_PROCESOS.F_SET_CARGA_CTRL_LINEA(PSPROCES   => P_SPROCES,
                                                                              PNLINEA    => V_NUM_LIN,
                                                                              PCTIPO     => 3,
                                                                              PIDINT     => V_NUM_LIN,
                                                                              PIDEXT     => V_NUM_LIN,
                                                                              PCESTADO   => 1,
                                                                              PCVALIDADO => NULL,
                                                                              PSSEGURO   => NULL,
                                                                              PIDEXTERNO => NULL,
                                                                              PNCARGA    => NULL,
                                                                              PNSINIES   => NULL,
                                                                              PNTRAMIT   => NULL,
                                                                              PSPERSON   => VSPERSON,
                                                                              PNRECIBO   => NULL);
                    PCOUNTFAIL := PCOUNTFAIL + 1;
                    CONTINUE;
                  END IF;
                EXCEPTION
                  WHEN OTHERS THEN
                    PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(VMENSAJES,
                                                      VOBJECT,
                                                      1000001,
                                                      VPASEXEC,
                                                      VPARAM,
                                                      PSQCODE   => SQLCODE,
                                                      PSQERRM   => SQLERRM);
                END;
              END IF;

              -- ACTIVIDADES EN OPERACIONES INTERNACIONALES

              IF I.TIPO_PRODUCTO_OI IS NOT NULL AND
                 I.ID_NUM_PRODUCTO_OI IS NOT NULL THEN
                begin
                  SELECT MAX(DA.NACTIVI)
                    INTO VIDENTIFICACION_ACT
                    FROM DETSARLATF_ACT DA
                   WHERE DA.CIDNUMPROD = I.ID_NUM_PRODUCTO_OI
                     AND DA.SPERSON = VSPERSON
                     AND DA.SSARLAFT = VSSARLAFT;
                exception
                  when no_data_found then
                    VIDENTIFICACION_ACT := null;
                end;

                begin
                  if i.PAIS_OI is not null then
                    SELECT P.TPAIS
                      INTO VTPAIS_OI
                      FROM PAISES P
                     WHERE P.CPAIS = I.PAIS_OI
                       AND ROWNUM = 1;
                  else
                    VTPAIS_OI := null;
                  end if;
                exception
                  when no_data_found then
                    VTPAIS_OI := null;
                end;

                begin
                  if i.DEPARTMENTO_OI is not null then
                    SELECT P.TPROVIN
                      INTO VTPROVIN_OI
                      FROM PROVINCIAS P
                     WHERE P.CPROVIN = I.DEPARTMENTO_OI
                       AND ROWNUM = 1;
                  else
                    VTPROVIN_OI := null;
                  end if;
                exception
                  when no_data_found then
                    VTPROVIN_OI := null;
                end;

                begin
                  if i.ciudad_oi is not null then
                    SELECT P.TPOBLAC
                      INTO VTPOBLAC_OI
                      FROM POBLACIONES P
                     WHERE P.CPOBLAC = i.ciudad_oi
                       and P.CPROVIN = I.DEPARTMENTO_OI
                       AND ROWNUM = 1;
                  else
                    VTPOBLAC_OI := null;
                  end if;
                exception
                  when no_data_found then
                    VTPOBLAC_OI := null;
                end;

                BEGIN
                  VPASEXEC := 8;
                  VPARAM   := 'vssarlaft : ' || VSSARLAFT ||
                              ' : vIDENTIFICACION_ACT : ' ||
                              VIDENTIFICACION_ACT ||
                              ' : tipo_producto_oi : ' ||
                              I.TIPO_PRODUCTO_OI ||
                              ' : id_num_producto_oi : ' ||
                              I.ID_NUM_PRODUCTO_OI ||
                              ' : entidad_producto_oi : ' ||
                              I.ENTIDAD_PRODUCTO_OI || ' : monto_oi : ' ||
                              I.MONTO_OI || ' : VTPOBLAC_OI : ' ||
                              VTPOBLAC_OI || ' : VTPAIS_OI : ' || VTPAIS_OI ||
                              ' : moneda_oi : ' || I.MONEDA_OI ||
                              ' : pais_oi : ' || I.PAIS_OI ||
                              ' : departmento_oi : ' || I.DEPARTMENTO_OI ||
                              ' : VTPROVIN_OI : ' || VTPROVIN_OI ||
                              ' : ciudad_oi : ' || I.CIUDAD_OI;

                  VNUMERR := PAC_MD_PERSONA.F_SET_DETSARLATF_ACT(VIDENTIFICACION_ACT,
                                                                 VSPERSON,
                                                                 VSSARLAFT,
                                                                 I.TIPO_PRODUCTO_OI,
                                                                 I.ID_NUM_PRODUCTO_OI,
                                                                 I.ENTIDAD_PRODUCTO_OI,
                                                                 I.MONTO_OI,
                                                                 I.CIUDAD_OI,
                                                                 I.PAIS_OI,
                                                                 I.MONEDA_OI,
                                                                 VTPAIS_OI,
                                                                 VTPROVIN_OI,
                                                                 I.DEPARTMENTO_OI,
                                                                 VTPOBLAC_OI,
                                                                 VMENSAJES);
                  IF VNUMERR <> 0 THEN
                    VLINEA := I.ITOMADOR || '|' || UPPER(I.NTOMADOR) ||
                              '|Error en Actividades en operaciones internacionales.';
                    UTL_FILE.PUT_LINE(VCARGARDSN, VLINEA);

                    VNUMERR    := PAC_GESTION_PROCESOS.F_SET_CARGA_CTRL_LINEA(PSPROCES   => P_SPROCES,
                                                                              PNLINEA    => V_NUM_LIN,
                                                                              PCTIPO     => 3,
                                                                              PIDINT     => V_NUM_LIN,
                                                                              PIDEXT     => V_NUM_LIN,
                                                                              PCESTADO   => 1,
                                                                              PCVALIDADO => NULL,
                                                                              PSSEGURO   => NULL,
                                                                              PIDEXTERNO => NULL,
                                                                              PNCARGA    => NULL,
                                                                              PNSINIES   => NULL,
                                                                              PNTRAMIT   => NULL,
                                                                              PSPERSON   => VSPERSON,
                                                                              PNRECIBO   => NULL);
                    PCOUNTFAIL := PCOUNTFAIL + 1;
                    CONTINUE;
                  END IF;
                EXCEPTION
                  WHEN OTHERS THEN
                    PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(VMENSAJES,
                                                      VOBJECT,
                                                      1000001,
                                                      VPASEXEC,
                                                      VPARAM,
                                                      PSQCODE   => SQLCODE,
                                                      PSQERRM   => SQLERRM);
                END;
              END IF;

              --INFORMACIÓN SOBRE RECLAMACIONES EN SEGUROS
              IF I.ANO_RS IS NOT NULL AND I.RAMO_RS IS NOT NULL THEN
                begin
                  SELECT MAX(DR.NRECLA)
                    INTO VNRECLA
                    FROM DETSARLAFT_REC DR
                   WHERE DR.SPERSON = VSPERSON
                     AND DR.SSARLAFT = VSSARLAFT;
                exception
                  when no_data_found then
                    VNRECLA := null;
                end;

                BEGIN
                  VPASEXEC := 9;
                  VPARAM   := 'vssarlaft : ' || VSSARLAFT ||
                              ' : vnrecla : ' || VNRECLA || ' : ano_rs : ' ||
                              I.ANO_RS || ' : ramo_rs : ' || I.RAMO_RS ||
                              ' : compania_rs : ' || I.COMPANIA_RS ||
                              ' : valor_rs : ' || I.VALOR_RS ||
                              ' : resultado_rs : ' || I.RESULTADO_RS;

                  VNUMERR := PAC_MD_PERSONA.F_SET_DETSARLAFT_REC(VNRECLA,
                                                                 VSPERSON,
                                                                 VSSARLAFT,
                                                                 I.ANO_RS,
                                                                 I.RAMO_RS,
                                                                 I.COMPANIA_RS,
                                                                 I.VALOR_RS,
                                                                 I.RESULTADO_RS,
                                                                 VMENSAJES);

                  IF VNUMERR <> 0 THEN
                    VLINEA := I.ITOMADOR || '|' || UPPER(I.NTOMADOR) ||
                              '|Error en Información sobre reclamaciones en seguros.';
                    UTL_FILE.PUT_LINE(VCARGARDSN, VLINEA);

                    VNUMERR    := PAC_GESTION_PROCESOS.F_SET_CARGA_CTRL_LINEA(PSPROCES   => P_SPROCES,
                                                                              PNLINEA    => V_NUM_LIN,
                                                                              PCTIPO     => 3,
                                                                              PIDINT     => V_NUM_LIN,
                                                                              PIDEXT     => V_NUM_LIN,
                                                                              PCESTADO   => 1,
                                                                              PCVALIDADO => NULL,
                                                                              PSSEGURO   => NULL,
                                                                              PIDEXTERNO => NULL,
                                                                              PNCARGA    => NULL,
                                                                              PNSINIES   => NULL,
                                                                              PNTRAMIT   => NULL,
                                                                              PSPERSON   => VSPERSON,
                                                                              PNRECIBO   => NULL);
                    PCOUNTFAIL := PCOUNTFAIL + 1;
                    CONTINUE;
                  END IF;
                EXCEPTION
                  WHEN OTHERS THEN
                    PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(VMENSAJES,
                                                      VOBJECT,
                                                      1000001,
                                                      VPASEXEC,
                                                      VPARAM,
                                                      PSQCODE   => SQLCODE,
                                                      PSQERRM   => SQLERRM);
                END;
              END IF;

              VNUMERR       := PAC_GESTION_PROCESOS.F_SET_CARGA_CTRL_LINEA(PSPROCES   => P_SPROCES,
                                                                           PNLINEA    => V_NUM_LIN,
                                                                           PCTIPO     => 3,
                                                                           PIDINT     => V_NUM_LIN,
                                                                           PIDEXT     => V_NUM_LIN,
                                                                           PCESTADO   => 4,
                                                                           PCVALIDADO => NULL,
                                                                           PSSEGURO   => NULL,
                                                                           PIDEXTERNO => NULL,
                                                                           PNCARGA    => NULL,
                                                                           PNSINIES   => NULL,
                                                                           PNTRAMIT   => NULL,
                                                                           PSPERSON   => VSPERSON,
                                                                           PNRECIBO   => NULL);
              PCOUNTSUCCESS := PCOUNTSUCCESS + 1;
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(VMENSAJES,
                                                VOBJECT,
                                                1000001,
                                                VPASEXEC,
                                                VPARAM,
                                                PSQCODE   => SQLCODE,
                                                PSQERRM   => SQLERRM);
          END;

        ELSE
          -- WHEN PERSON IS NOT FOUND.
          VLINEA := I.ITOMADOR || '|' || UPPER(I.NTOMADOR) ||
                    '|NO COINCIDEN NOMBRES';
          UTL_FILE.PUT_LINE(VCARGARDSN, VLINEA);

          VNUMERR    := PAC_GESTION_PROCESOS.F_SET_CARGA_CTRL_LINEA(PSPROCES   => P_SPROCES,
                                                                    PNLINEA    => V_NUM_LIN,
                                                                    PCTIPO     => 3,
                                                                    PIDINT     => V_NUM_LIN,
                                                                    PIDEXT     => V_NUM_LIN,
                                                                    PCESTADO   => 5,
                                                                    PCVALIDADO => NULL,
                                                                    PSSEGURO   => NULL,
                                                                    PIDEXTERNO => NULL,
                                                                    PNCARGA    => NULL,
                                                                    PNSINIES   => NULL,
                                                                    PNTRAMIT   => NULL,
                                                                    PSPERSON   => VSPERSON,
                                                                    PNRECIBO   => NULL);
          PCOUNTFAIL := PCOUNTFAIL + 1;
          CONTINUE;
        END IF;
      END LOOP;
    END IF;

    IF VCOUNTDSN = (PCOUNTSUCCESS + PCOUNTFAIL) THEN
      PERROR := 0;
    ELSE
      PERROR := 1;
    END IF;

    /* Cerar archivo */
    IF UTL_FILE.is_open(VCARGARDSN) THEN
      UTL_FILE.fclose(VCARGARDSN);
    END IF;

  END P_CARGA_DATSARLAF_N;

/* Cambios de IAXIS-3562 : Ends */
--INI SGM IAXIS 3641 CARGUE DE ARCHIVO DE PROVEEDORES
/*************************************************************************
FUNCTION f_anota_leearchivos_carga
Funcion para cargar la gestion de los outsourcing
*************************************************************************/
   FUNCTION f_anota_leearchivos_carga
      RETURN NUMBER IS
      vprefijo  varchar2(50):='GESTIONPROVEEDORES';
      varchivo  varchar2(100);
      v_file    UTL_FILE.file_type;
      v_sproces NUMBER;
      vnum_err  NUMBER;
      archivo_duplicado  NUMBER;
      duplicados         BOOLEAN:= False;

   BEGIN

       vnum_err := f_procesini(f_user, 24, '406', 'GESTION_PROVEEDORES', v_sproces);

       FOR F IN 1..10 LOOP
            SELECT vprefijo||TO_CHAR(F_SYSDATE -1,'DDMMYYYY')||LPAD(F,2,'0')||'.csv' 
              INTO varchivo
            FROM DUAL;
            
            BEGIN
            /*se verificaran uno a uno que ficheros hay en el directorio y se ira llamando la funcion para procesar cada uno.
            se acabar?l proceso cuando UTL_FILE.fopen trate de llamar un archivo que no est?n directorio*/
                     -- Inicio: Lectura de fichero.
                    v_file := UTL_FILE.fopen('UTLDIR', varchivo, 'R');   --(UBICACION,NOMBRE,MODO APERTURA, MAX LINE SIZE)

                    UTL_FILE.fclose(v_file);--de nuevo lo cerramos, pero en este punto sabemos que existe en el directorio

                    /*llamamos la funcion que empieza a leer el archivo actual y realizar el proceso de carga en tablas
                      Esta funcion se llamara solo si el archivo no ha sido cargado previamente*/

                    BEGIN 
                        SELECT COUNT(*)
                        INTO archivo_duplicado
                        FROM int_agd_observaciones
                        WHERE fichero = varchivo;
                    END;

                    IF (archivo_duplicado = 0) THEN
                        vnum_err := f_anota_gescartera_carga(p_nombre => varchivo,
                                                             p_path => 'UTLDIR',
                                                             p_cproces => 406,
                                                             psproces => v_sproces);
                    ELSE
                        vnum_err := f_procesini(f_user, 24, '406', 'GESTION_PROVEEDORES Archivo duplicado, ver INT_AGD_OBSERVACIONES.FICHERO', v_sproces);
                        duplicados :=true;
                    END IF;

            EXCEPTION
                WHEN DUP_VAL_ON_INDEX THEN
                DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_backtrace);
                UTL_FILE.fclose(v_file);
                RETURN 9904284;
                -- Duplicated record
                WHEN VALUE_ERROR THEN
                DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_backtrace);
                --ROLLBACK;
                UTL_FILE.fclose(v_file);
                RETURN 9907933;
             -- Data Error. Check character length OR NUMBER format
                WHEN OTHERS THEN
                    IF duplicados THEN
                        RETURN 89906306;
                    END IF;    
                p_control_error('SGM','ya leyo todo','SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
                UTL_FILE.fclose(v_file);
                RETURN 103187;
      -- An error has occurred while reading the file
            END;            
       END LOOP;
       RETURN 0;
   END f_anota_leearchivos_carga;
/*************************************************************************
FUNCTION f_anota_gescartera_carga
Funcion para cargar la gestion de los outsourcing
*************************************************************************/
   FUNCTION f_anota_gescartera_carga(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER)
      RETURN NUMBER IS
      vlin           NUMBER;
      vobj           VARCHAR2(200) := 'PAC_CARGAS_CONF. f_anota_gescartera_carga';
      vpar           VARCHAR2(2000)
         := 'p_nombre=' || p_nombre || 'p_path=' || p_path || ' p_cproces=' || p_cproces
            || 'psproces= ' || psproces;
      vnum_err       NUMBER := 0;
   BEGIN
   
      vnum_err := pac_cargas_conf.f_anota_gescartera_cargafic(p_nombre, p_path, p_cproces,
                                                                 psproces);
      --
      IF vnum_err <> 0 THEN
         RAISE e_param_error;
      END IF;

      vlin := 2;

      vnum_err := pac_cargas_conf.f_anota_gescartera_ejecproc(psproces);

      UPDATE int_carga_ctrl
         SET cestado = vnum_err,
             ffin = f_sysdate
       WHERE sproces = psproces;

      --
      COMMIT;
      --
      RETURN 0;
   --
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobj, vlin, vpar, SQLCODE);
         RETURN 1;
      WHEN e_object_error THEN
         p_tab_error(f_sysdate, f_user, vobj, vlin, vpar, SQLCODE);
         RETURN 1;
      WHEN OTHERS THEN
         DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_backtrace);
         p_tab_error(f_sysdate, f_user, vobj, vlin, vpar, SQLCODE);
         RETURN 1;
   END f_anota_gescartera_carga;

      /*************************************************************************
   FUNCTION f_anota_gescartera_cargafic
   *************************************************************************/
   FUNCTION f_anota_gescartera_cargafic(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'pac_cargas_conf.f_anota_gescartera_cargafic';
      vnum_err       NUMBER := 0;
      v_line         VARCHAR2(32767);
      v_file         UTL_FILE.file_type;
      v_numlineaf    NUMBER := 0; -- IAXIS-2418 28/02/2019
      -- Numero de linea del fichero
      -- Numero de linea del insert
      errorini       EXCEPTION;
      errorcarga     EXCEPTION;
      e_errdatos     EXCEPTION;
      -- Formato Ingls
      v_sep          VARCHAR2(1) := ';';
      v_currfield    VARCHAR2(64);
      v_nrecibo      NUMBER;
      v_estado       VARCHAR2(100);
      v_nit          VARCHAR2(100);
      v_observacion  VARCHAR2(500);
      v_fcompromiso  DATE;
      v_atendio      VARCHAR2(500);
      v_fgestion     DATE; 
      v_cadena       VARCHAR2(500);

      vlin           NUMBER;
      vidobs         NUMBER;
      vncarga        NUMBER := f_next_carga_g;
      vpar           VARCHAR2(2000)
         := 'p_nombre=' || p_nombre || 'p_path=' || p_path || ' p_cproces=' || p_cproces
            || 'psproces= ' || psproces;

      PROCEDURE p_controlar_error(p_traza NUMBER, p_estado NUMBER, v_msg VARCHAR2) IS
      BEGIN
         vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces, p_nombre,
                                                                    f_sysdate, NULL, p_estado,
                                                                    p_cproces, NULL, v_msg);

         IF vnum_err <> 0 THEN
            -- Si fallan esta funciones de gestin salimos del programa
            p_tab_error(f_sysdate, f_user, vobj, p_traza, vnum_err,
                        'Error llamando pac_gestion_procesos.f_set_carga_ctrl_cabecera'
                        || p_traza);
            RAISE errorini;
         END IF;
      END p_controlar_error;
   BEGIN

      SELECT sproces.NEXTVAL
        INTO psproces
        FROM DUAL;

      IF p_cproces IS NULL THEN
         vnum_err := 9901092;
         RAISE e_errdatos;
      END IF;

      p_controlar_error(2, 3, NULL);

      BEGIN
         -- Inicio: Lectura de fichero.
         v_file := UTL_FILE.fopen(p_path, p_nombre, 'R', 256);   --(UBICACION,NOMBRE,MODO APERTURA, MAX LINE SIZE)

         LOOP
            EXIT WHEN v_numlineaf = -1;

            BEGIN
               v_numlineaf := v_numlineaf + 1;
               UTL_FILE.get_line(v_file, v_line, 32767);
               DBMS_OUTPUT.put_line(v_line);

               IF (v_numlineaf > 0) THEN -- IAXIS-2418 28/02/2019
                  v_line := REPLACE(REPLACE(v_line, chr(10), ''), chr(13), '');

                  v_currfield := 'NRECIBO';
                  v_nrecibo := pac_util.splitt(v_line, 1, v_sep);  --VSEP SEPARADOR
                  v_currfield := 'ESTADO';
                  v_estado := pac_util.splitt(v_line, 2, v_sep);
                  v_currfield := 'OBSERVACION';
                  v_observacion := pac_util.splitt(v_line, 3, v_sep);
                  v_currfield := 'FCOMPROMISO';
                  v_fcompromiso := TO_DATE(pac_util.splitt(v_line, 4, v_sep), 'DD/MM/YYYY');
                  v_currfield := 'ATENDIO';
                  v_atendio := pac_util.splitt(v_line, 5, v_sep);             
                  v_currfield := 'FGESTION';
                  v_fgestion := TO_DATE(pac_util.splitt(v_line, 6, v_sep), 'DD/MM/YYYY');
                  v_currfield := 'NIT';
                  v_nit := pac_util.splitt(v_line, 7, v_sep);                  


                  --concatenamos el texto que se pondra en campo observaciones
                  v_cadena:= v_observacion || chr(13) || 'Fecha Compromiso:' || v_fcompromiso || chr(13)
                              ||'Atendido por:' || v_atendio  || chr(13) ||'Estado:' || v_estado;

                  IF vidobs IS NULL THEN
                     BEGIN
                        SELECT NVL(MAX(idobs), 1) + 1 
                          INTO vidobs
                          FROM AGD_OBSERVACIONES;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           vidobs := 1;
                     END;
                  ELSE
                     vidobs:= vidobs + 1;
                  END IF;                     

--   CTIPAGD 2  (TIPO DE AGENDA: RECIBO) Siempre se cargaran masivamente las anotaciones de este tipo
                     INSERT INTO INT_AGD_OBSERVACIONES
                       (proceso, nlinea, ncarga, cempres, idobs,
                        cconobs,ctipobs,ttitobs,tobs,fobs,
                        ctipagd,nrecibo,publico,cusualt,falta,fichero,nit)
                     VALUES
                        (psproces, v_numlineaf, vncarga, pac_md_common.f_get_cxtempresa, vidobs,
                            37,1,'Gestion Outsourcing',v_cadena, v_fgestion,
                            2, v_nrecibo,1,f_user, f_sysdate,p_nombre,v_nit);

                  vnum_err :=
                     pac_gestion_procesos.f_set_carga_ctrl_linea(psproces => psproces,
                                                                 pnlinea => v_numlineaf,
                                                                 pctipo => 20,
                                                                 pidint => v_numlineaf,
                                                                 pidext => v_numlineaf,
                                                                 pcestado => 4,
                                                                 pcvalidado => NULL,
                                                                 psseguro => NULL,
                                                                 pidexterno => NULL,
                                                                 pncarga => NULL,
                                                                 pnsinies => NULL,
                                                                 pntramit => NULL,
                                                                 psperson => NULL,
                                                                 pnrecibo => NULL);
                  --
                  COMMIT;
               --
               END IF;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  -- No hay mas datos para leer.
                  v_numlineaf := -1;
               WHEN OTHERS THEN
                  vnum_err :=
                     pac_gestion_procesos.f_set_carga_ctrl_linea(psproces => psproces,
                                                                 pnlinea => v_numlineaf,
                                                                 pctipo => 20,
                                                                 pidint => v_numlineaf,
                                                                 pidext => v_numlineaf,
                                                                 pcestado => 4,
                                                                 pcvalidado => NULL,
                                                                 psseguro => NULL,
                                                                 pidexterno => NULL,
                                                                 pncarga => NULL,
                                                                 pnsinies => NULL,
                                                                 pntramit => NULL,
                                                                 psperson => NULL,
                                                                 pnrecibo => NULL);
                  p_error_linea_g(psproces, NULL, v_numlineaf,
                                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
            END;
         END LOOP;

         UTL_FILE.fclose(v_file);
         RETURN 0;
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_backtrace);
            ROLLBACK;
            UTL_FILE.fclose(v_file);
            p_controlar_error(5, 1,
                              f_axis_literales(9904284, pac_md_common.f_get_cxtidioma())
                              || ' at line ' || v_numlineaf);
            RETURN 9904284;
         -- Duplicated record
         WHEN VALUE_ERROR THEN
            DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_backtrace);
            ROLLBACK;
            UTL_FILE.fclose(v_file);
            p_controlar_error(6, 1,
                              f_axis_literales(9907933, pac_md_common.f_get_cxtidioma())
                              || ' at line ' || v_numlineaf || ', field: ' || v_currfield);
            RETURN 9907933;
         -- Data Error. Check character length OR NUMBER format
         WHEN OTHERS THEN
            DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_backtrace);
            ROLLBACK;
            UTL_FILE.fclose(v_file);
            p_controlar_error(7, 1, f_axis_literales(103187, pac_md_common.f_get_cxtidioma()));
            RETURN 103187;
      -- An error has occurred while reading the file
      END;
   EXCEPTION
      WHEN e_errdatos THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, vobj, vlin, vpar, SQLCODE || CHR(10) || vnum_err);
         DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_backtrace);
         RETURN vnum_err;
      WHEN errorini THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, vobj, vlin, vpar, SQLCODE || CHR(10) || vnum_err);
         DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_backtrace);
         RETURN 108953;
   -- A runtime error has occurred
   END f_anota_gescartera_cargafic;

   /*************************************************************************
   FUNCTION f_anota_gescartera_ejecproc
   Ejecuta la carga del archivo de campaas de agentes
   Retorna 1- Error, 2- correcto
   *************************************************************************/
   FUNCTION f_anota_gescartera_ejecproc(p_sproces IN NUMBER)
      RETURN NUMBER IS
      ragenda        AGD_OBSERVACIONES%ROWTYPE;
      vcod           NUMBER;
      vexiste        detvalores.tatribu%TYPE;
      vtraza         NUMBER;
      vdeserror      VARCHAR2(1000);
      vobj           VARCHAR2(100) := 'pac_cargas_conf.f_anota_acuerdopag_ejecproc';
      verror         NUMBER;
      vnit           VARCHAR2(200);
   BEGIN
     --
     vtraza := 1;

     BEGIN
        SELECT nit
          INTO vnit
          FROM int_agd_observaciones i
         WHERE proceso = p_sproces
           AND ROWNUM = 1;
     EXCEPTION
         WHEN OTHERS THEN
         p_genera_logs_g(vobj, vtraza, 'Error: ' || SQLCODE, SQLERRM, p_sproces,
         'Error: ' || SQLERRM);
         RETURN 1;     
     END;
     --
     FOR cur_agenda IN (SELECT i.*
                            FROM int_agd_observaciones i
                            WHERE proceso = p_sproces) LOOP
       BEGIN
         --
         vtraza := 2;
         --
         ragenda.cempres := cur_agenda.cempres;
         ragenda.idobs := cur_agenda.idobs;
         ragenda.cconobs := cur_agenda.cconobs;
         ragenda.ctipobs := cur_agenda.ctipobs;
         ragenda.ttitobs := cur_agenda.ttitobs;
         ragenda.tobs   := cur_agenda.tobs;
         ragenda.fobs := cur_agenda.fobs;
         ragenda.ctipagd := cur_agenda.ctipagd;
         ragenda.nrecibo := cur_agenda.nrecibo;
         ragenda.publico := cur_agenda.publico;
         ragenda.cusualt   := cur_agenda.cusualt;
         ragenda.falta := cur_agenda.falta;
         --
         vtraza := 3;
         --
         INSERT INTO agd_observaciones VALUES ragenda;
         INSERT INTO adm_observa_outsourcing(idobs,nit) values (ragenda.idobs,vnit);

         --
         vtraza := 4;
         --
       EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
           --
           vtraza := 5;
           --
           UPDATE agd_observaciones
              SET 
         cempres = ragenda.cempres,
         idobs = ragenda.idobs,
         cconobs = ragenda.cconobs,
         ctipobs = ragenda.ctipobs,
         ttitobs = ragenda.ttitobs,
         tobs   = ragenda.tobs,
         fobs = ragenda.fobs,
         ctipagd = ragenda.ctipagd,
         nrecibo = ragenda.nrecibo,
         publico = ragenda.publico,
         cusualt   = ragenda.cusualt,
         falta = ragenda.falta
            WHERE idobs = ragenda.idobs;
           --
           vtraza := 6;
           --
       END;
     --
       BEGIN
           INSERT INTO AGD_MOVOBS (CEMPRES,IDOBS,NMOVOBS,CESTOBS,FESTOBS,CUSUALT,FALTA,TOBS)
           VALUES (ragenda.cempres,ragenda.idobs,1,0,ragenda.fobs,ragenda.cusualt,ragenda.falta,ragenda.tobs);
       EXCEPTION
         WHEN OTHERS THEN  
         p_genera_logs_g(vobj, vtraza, 'Error: ' || SQLCODE, SQLERRM, p_sproces,
         'Error: ' || SQLERRM);
         RETURN 1;
       END;


     END LOOP;
   --
   RETURN 2;
   EXCEPTION
      WHEN OTHERS THEN
         p_genera_logs_g(vobj, vtraza, 'Error: ' || SQLCODE, SQLERRM, p_sproces,
                         'Error: ' || SQLERRM);
         RETURN 1;
   END f_anota_gescartera_ejecproc;

--FIN SGM IAXIS 3641 CARGUE DE ARCHIVO DE PROVEEDORES
   
   -- INI IAXIS-4834 CJMR 06/11/2019
   /*************************************************************************
   FUNCTION f_lre_carga_gruposeconomicos
   Ejecurta la carga del archivo de Grupos Ecónomicos
   Retorna 0 Ok <> 0 Error
   *************************************************************************/
   FUNCTION f_lre_carga_gruposeconomicos(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER)
      RETURN NUMBER IS
      vtraza         NUMBER;
      vnum_err       NUMBER;
      vobj           VARCHAR2(100) := 'pac_cargas_conf.f_lre_carga_gruposeconomicos';
      vdeserror      VARCHAR2(100);
      esalir         EXCEPTION;
   BEGIN
      vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces, p_nombre,
                                                                 f_sysdate, NULL, 3,
                                                                 p_cproces, NULL, NULL);
      vtraza := 1;
      vnum_err := f_lre_ejecutarfichero(p_nombre, p_path, p_cproces, psproces);
      IF vnum_err <> 0 THEN
         vdeserror := 'Leyendo fichero: ' || p_nombre;
         RAISE esalir;
      END IF;
      
      vtraza := 2;
      vnum_err := f_lre_grpeco_ejecutaproceso(psproces);
      
      vtraza := 3;
      UPDATE int_carga_ctrl
         SET cestado = vnum_err,
             ffin = f_sysdate
       WHERE sproces = psproces;
      
      vtraza := 4;
      DELETE lre_personas
      WHERE NVL(cmarca, 0) = 0;
      
      vtraza := 5;
      RETURN 0;
   EXCEPTION
      WHEN esalir THEN
         p_genera_logs_g(vobj, vtraza, 'Error: ' || SQLCODE, SQLERRM, psproces,
                         'Error: ' || vdeserror);
         RETURN vnum_err;
      WHEN OTHERS THEN
         p_genera_logs_g(vobj, vtraza, 'Error: ' || SQLCODE, SQLERRM, psproces,
                         'Error: ' || SQLERRM);
         RETURN 1;
   END f_lre_carga_gruposeconomicos;

   /*************************************************************************
   FUNCTION f_lre_grpeco_ejecutaproceso
   Ejecurta la carga del archivo de listas restrictivas para grupos económicos
   Retorna 1- Error, 2- correcto
   *************************************************************************/
   FUNCTION f_lre_grpeco_ejecutaproceso(p_sproces IN NUMBER)
      RETURN NUMBER IS
      reglre         lre_personas%ROWTYPE;
      vcod           NUMBER;
      vexiste        detvalores.tatribu%TYPE;
      vtraza         NUMBER;
      vdeserror      VARCHAR2(1000);
      vobj           VARCHAR2(100) := 'pac_cargas_conf.f_lre_grpeco_ejecutaproceso';
      verror         NUMBER;
      v_cmarca       agr_marcas.cmarca%TYPE;
   BEGIN
      vtraza := 1;
      DELETE lre_personas
      WHERE ctiplis IN (63, 64, 65)
      AND cclalis = 2;
      
      
      FOR cur_lre IN (SELECT *
                        FROM int_carga_lre
                       WHERE proceso = p_sproces) LOOP
         reglre := NULL;
         
         vtraza := 2;
         reglre.nnumide := cur_lre.nnumide;
         reglre.ctipide := f_buscavalor_g('TIPOIDEN_FICLISEXT', cur_lre.ctipide);
         reglre.ctiplis := cur_lre.clre;
         reglre.nordide := 0;
         reglre.cclalis := 2;
         reglre.ctipper := NULL;
         reglre.tnomape := cur_lre.tnomape;
         reglre.tnombre1 := NULL;
         reglre.tnombre2 := NULL;
         reglre.tapelli1 := NULL;
         reglre.tapelli2 := NULL;
         reglre.cnovedad := 1;
         reglre.cnotifi := NULL;
         
         IF reglre.ctiplis IS NULL THEN
            vcod := '105940';
            vdeserror := '';
            RAISE e_errdatos;
         ELSE
            vtraza := 3;
            BEGIN
               SELECT DISTINCT tatribu
                          INTO vexiste
                          FROM detvalores
                         WHERE cvalor = 800048
                           AND cidioma = kidiomaaaxis
                           AND catribu = reglre.ctiplis;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  vcod := '102844';
                  RAISE e_errdatos;
            END;
         END IF;
         
         vtraza := 4;
         SELECT MAX(sperlre), MAX(sperson)
           INTO reglre.sperlre, reglre.sperson
           FROM lre_personas
          WHERE nnumide = reglre.nnumide
            AND ctipide = reglre.ctipide
            AND nordide = reglre.nordide
            AND cclalis = reglre.cclalis
            AND ctiplis = reglre.ctiplis;
         
         IF reglre.sperson IS NULL THEN
            vtraza := 5;
            SELECT MAX(sperson)   -- Se busca primero por número de documento e identificador.
              INTO reglre.sperson
              FROM per_personas
             WHERE nnumide = reglre.nnumide
               AND ctipide = reglre.ctipide;
            
            IF reglre.sperson IS NULL THEN
               vtraza := 6;
               SELECT MAX(sperson)
                 INTO reglre.sperson
                 FROM per_detper
                WHERE UPPER(tnombre1 || ' ' || tnombre2 || ' ' || tapelli1 || ' ' || tapelli2) = UPPER(reglre.tnomape);
            END IF;
         END IF;
         
         IF reglre.sperson IS NOT NULL THEN
            vtraza := 7;
            SELECT p.nnumide, p.ctipide, dp.tnombre1, dp.tnombre2,
                   dp.tapelli1, dp.tapelli2,
                   dp.tnombre1 || ' ' || dp.tnombre2 || ' ' || dp.tapelli1 || ' '
                   || dp.tapelli2
              INTO reglre.nnumide, reglre.ctipide, reglre.tnombre1, reglre.tnombre2,
                   reglre.tapelli1, reglre.tapelli2,
                   reglre.tnomape
              FROM per_personas p JOIN per_detper dp ON p.sperson = dp.sperson
             WHERE p.sperson = reglre.sperson;
            
            vtraza := 7.1;
            IF reglre.ctiplis = 63 THEN
               v_cmarca := '0202';
            ELSIF reglre.ctiplis = 64 THEN
               v_cmarca := '0201';
            ELSIF reglre.ctiplis = 65 THEN
               v_cmarca := '0200';
            END IF;
            
            verror := pac_marcas.f_set_marca_automatica(kempresa, reglre.sperson, v_cmarca);  -- Marcas de grupos económicos
            IF verror <> 0 THEN
               p_genera_logs_g(vobj, vtraza, 'Error: ', verror, p_sproces, 'Error: Actualizando marca de Grupos Económicos ' || v_cmarca);
            END IF;
         END IF;
         
         IF reglre.sperlre IS NULL THEN
            SELECT sperlre.NEXTVAL
              INTO reglre.sperlre
              FROM DUAL;
            
            vtraza := 8;
            INSERT INTO lre_personas
                        (sperlre, nnumide, nordide, ctipide,
                         ctipper,
                         tnomape, tnombre1, tnombre2, tapelli1,
                         tapelli2, sperson, cnovedad, cnotifi,
                         cclalis, ctiplis, finclus, cusumod, cmarca)
                 VALUES (reglre.sperlre, reglre.nnumide, reglre.nordide, reglre.ctipide,
                         DECODE(reglre.ctipper,
                                NULL, DECODE(reglre.ctipide, 37, 2, 1),
                                reglre.ctipper),
                         reglre.tnomape, reglre.tnombre1, reglre.tnombre2, reglre.tapelli1,
                         reglre.tapelli2, reglre.sperson, reglre.cnovedad, reglre.cnotifi,
                         reglre.cclalis, reglre.ctiplis, f_sysdate, f_user, 1);
         ELSE
            vtraza := 9;
            UPDATE lre_personas
               SET cnovedad = 1,
                   fmodifi = f_sysdate,
                   fexclus = NULL,
                   sperson = reglre.sperson,
                   cmarca = 1
             WHERE sperlre = reglre.sperlre
               AND ctiplis = reglre.ctiplis;
         END IF;
      END LOOP;
      
      RETURN 2;
   EXCEPTION
      WHEN e_errdatos THEN
         p_genera_logs_g(vobj, vtraza, 'Error: ' || SQLCODE, SQLERRM, p_sproces, 'Error: ' || vdeserror);
         RETURN 1;
      WHEN OTHERS THEN
         p_genera_logs_g(vobj, vtraza, 'Error: ' || SQLCODE, SQLERRM, p_sproces, 'Error: ' || SQLERRM);
         RETURN 1;
   END f_lre_grpeco_ejecutaproceso;

   -- FIN IAXIS-4834 CJMR 06/11/2019
   
   
   FUNCTION f_modi_vidagrupo_ext(p_nombre VARCHAR2)
      RETURN NUMBER IS
      v_tnomfich     VARCHAR2(100);
   BEGIN
      v_tnomfich := SUBSTR(p_nombre, 1, INSTR(p_nombre, '.') - 1);

      --Modificamos los logs
      EXECUTE IMMEDIATE 'alter table VIDAGRUPO_EXT ACCESS PARAMETERS (records delimited by 0x''0A''
                   logfile '
                        || CHR(39) || v_tnomfich || '.log' || CHR(39)
                        || '
                   badfile ' || CHR(39) || v_tnomfich || '.bad' || CHR(39)
                        || '
                   discardfile ' || CHR(39) || v_tnomfich || '.dis' || CHR(39)
                        || '
                   fields terminated by ''|'' lrtrim
                   MISSING FIELD VALUES ARE NULL
                   REJECT ROWS WITH ALL NULL FIELDS
                   (   TIPO_ID,
                       TIPPER,
                       TIPO_SOCIEDAD,
                       CODVIN,
                       RAZON_SOCIAL,
                       APELLIDO1_DQ,
                       APELLIDO2_DQ,
                       NOMBRE1_DQ,
                       NOMBRE2_DQ,
                       NO_ID,
                       DIGITO_DQ,
                       FECHA_EXPEDICION DATE MASK "dd/mm/yyyy",
                       FECHA_NACIMIENTO DATE MASK "dd/mm/yyyy",
                       CODIGO_PAIS,
                       CODIGO_DEPTO,
                       CODIGO_CIUDAD,
                       GENERO,
                       ESTADO,
                       CODIGO_CIIU,
                       DIRECCION_1,
                       CODIGO_PAIS1_1,
                       CODIGO_DEPTO1_1,
                       CODIGO_CIUDAD1_1,
                       TELEFONO_1,
                       CELULAR_1,
                       CORREO_1,
                       NUM_BANCO,
                       TIPO_CUENTA,
                       NUM_CUENTA ))';

      --Cargamos el fichero
      EXECUTE IMMEDIATE 'ALTER TABLE VIDAGRUPO_EXT LOCATION (''' || p_nombre || ''')';

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_cargas_conf.F_MODI_VIDAGRUPO_EXT', 1,
                     'Error creando la tabla.', SQLERRM);
         RETURN 107914;
   END f_modi_vidagrupo_ext;
   
   
   FUNCTION f_ejecutar_carga_fichero_vg(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,   
      psproces OUT NUMBER)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'f_ejecutar_carga_fichero_vg';
      linea          NUMBER := 0;
      pcarga         NUMBER;
      sentencia      VARCHAR2(32000);
      vfichero       UTL_FILE.file_type;
      vtraza         NUMBER := 0;
      verror         NUMBER;
      vdeserror      VARCHAR2(1000);
      v_sproces      NUMBER;
      errorini       EXCEPTION;   --Indica error grabando estados.--Error que para ejecucin
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
      vnum_err_cargarVIDAGRUPO NUMBER;
      vnum_CountFail NUMBER;
      vnum_CountSuccess NUMBER;
   BEGIN
      vtraza := 0;
      vsinproc := TRUE;
      vnum_err := f_procesini(f_user, k_empresaaxis,'CARGA_VIDAGRUPO', p_nombre, v_sproces);

      IF vnum_err <> 0 THEN
         RAISE errorini;   --Error que para ejecucin
      END IF;

      psproces := v_sproces;
      vtraza := 1;

      IF p_cproces IS NULL THEN
         vnum_err := 9901092;
         vdeserror := 'cfg_files falta proceso: ' || vobj;
         RAISE e_errdatos;
      END IF;

      vtraza := 11;
      vnum_err :=
         pac_gestion_procesos.f_set_carga_ctrl_cabecera(v_sproces, p_nombre, f_sysdate, NULL,
                                                        3, p_cproces,   
                                                        NULL, NULL);
      vtraza := 12;

      IF vnum_err <> 0 THEN   --Si fallan esta funciones de gestin salimos del programa
         p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                     'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera');
         vnum_err := f_proceslin(v_sproces,
                                 f_axis_literales(180856, k_idiomaaaxis) || ':' || p_nombre
                                 || ' : ' || vnum_err,
                                 1, vnnumlin);
         RAISE errorini;   --Error que para ejecucin
      END IF;

      COMMIT;
      vtraza := 2;
      --Creamos la tabla apartir del nombre de fichero enviado dinamicamente.
      vnum_err := f_modi_vidagrupo_ext(p_nombre);

      IF vnum_err <> 0 THEN
         p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                     'Error creando la tabla externa');
         vnum_err := f_proceslin(v_sproces,
                                 f_axis_literales(vnum_err, k_idiomaaaxis) || ':' || p_nombre
                                 || ' : ' || vnum_err,
                                 1, vnnumlin);
         RAISE errorini;   --Error que para ejecucin
      END IF;

    vtraza := 53;
    if vnum_err = 0 then
     begin
      p_setPersona_Cargar_vg(p_path,p_nombre,p_cproces,v_sproces,vnum_CountFail,vnum_CountSuccess,vnum_err_cargarVIDAGRUPO);
      IF vnum_err_cargarVIDAGRUPO <> 0 THEN
         p_tab_error(f_sysdate,
              f_user,
              vobj,
              vtraza,
              vnum_err_cargarVIDAGRUPO,
              'Cargar archivo de VIDAGRUPO : Funciona :'||vnum_CountSuccess || ' : No Funciona :'||vnum_CountFail);

         vnum_err := f_proceslin(v_sproces,
                     f_axis_literales(vnum_err_cargarVIDAGRUPO, k_idiomaaaxis) || ':' ||
                     p_nombre || ' : ' || vnum_err_cargarVIDAGRUPO,
                     1,
                     vnnumlin);
        RAISE errorini;
      END IF;
      exception
      WHEN others THEN
        p_tab_error(f_sysdate,
              f_user,
              vobj,
              vtraza,
              vnum_CountFail,
              'Error en cargar archivo de VidaGrupo : Funciona :'||vnum_CountSuccess || ' : No Funciona :'||vnum_CountFail);
      end;
    end if;

     /* p_trasp_tabla(vdeserror, v_sproces);*/
      vtraza := 3;

      IF vdeserror IS NOT NULL THEN
         --Si hay un error leyendo el fichero salimos del programa del todo y lo indicamos.
         vtraza := 5;
         vnum_err :=
            pac_gestion_procesos.f_set_carga_ctrl_cabecera
                                                         (v_sproces, p_nombre, f_sysdate,
                                                          NULL, 1, p_cproces,   
                                                          NULL, vdeserror);
         vtraza := 51;

         IF vnum_err <> 0 THEN   --Si fallan esta funciones de gestin salimos del programa
            --RAISE ErrGrabarProv;
            p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                        'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera2');
            vnnumlin := NULL;
            vnum_err := f_proceslin(v_sproces,
                                    f_axis_literales(180856, k_idiomaaaxis) || ':' || p_nombre
                                    || ' : ' || vnum_err,
                                    1, vnnumlin);
            RAISE errorini;   --Error que para ejecucin
         END IF;

         vtraza := 52;
         COMMIT;   --Guardamos la tabla temporal int
         RAISE vsalir;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN vsalir THEN
         NULL;
         RETURN 1;
      WHEN e_errdatos THEN
         ROLLBACK;
         pac_cargas_conf.p_genera_logs(vobj, vtraza, 'Error:' || vnum_err, vdeserror,
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
                                                          NULL, 1, p_cproces,   
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
   END f_ejecutar_carga_fichero_vg;
   
   -- Inicio IAXIS-7629  JRVG 20/02/2020 
        
   FUNCTION f_vidagrupo_ejecutarcarga(p_nombre  IN VARCHAR2,
                                      p_path    IN VARCHAR2,
                                      p_cproces IN NUMBER,
                                      psproces  IN OUT NUMBER) RETURN NUMBER IS
        vobj     VARCHAR2(100) := 'pac_cargas_conf';
        vtraza   NUMBER := 0;
        vnum_err NUMBER;
        vsalir EXCEPTION;
      BEGIN
        vtraza := 0;

        SELECT NVL(cpara_error, 0)
          INTO k_para_carga
          FROM cfg_files
         WHERE cempres = k_empresaaxis
           AND cproceso = p_cproces;

        IF psproces IS NULL THEN
          vnum_err := pac_cargas_conf.f_ejecutar_carga_fichero_vg(p_nombre,
                                                                   p_path,
                                                                   p_cproces,
                                                                   psproces);
        
          IF vnum_err <> 0 THEN
            RAISE vsalir;
          END IF;
        END IF;

        vtraza   := 1;
        vnum_err := pac_cargas_conf.f_proceso_vidagrupo(psproces, p_cproces);  --revisar

        IF vnum_err <> 0 THEN
          RAISE vsalir;
          /* Cambios para IAXIS-2015 : Start */
        else
          vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces,
                                                                     p_nombre,
                                                                     null,
                                                                     f_sysdate,
                                                                     4,
                                                                     p_cproces,
                                                                     0,
                                                                     NULL);
          vnum_err := f_procesfin(psproces, 0);
          /* Cambios para IAXIS-2015 : End */
      END IF;

      RETURN 0;
    EXCEPTION
      WHEN vsalir THEN
        RETURN 1;
    END f_vidagrupo_ejecutarcarga;

  FUNCTION f_proceso_vidagrupo(psproces IN NUMBER, p_cproces IN NUMBER)
        RETURN NUMBER IS
        vobj           VARCHAR2(100) := 'pac_cargas_conf.f_proceso_vidagrupo';
        vtraza         NUMBER := 0;
        vdeserror      VARCHAR2(1000);
        errorini       EXCEPTION;   --Indica error grabando estados.--Error que para ejecucin
        vsalir         EXCEPTION;
        emigra         EXCEPTION;
        v_tfichero     int_carga_ctrl.tfichero%TYPE;
        e_errdatos     EXCEPTION;
        e_validaciones EXCEPTION;
        vnum_err       NUMBER;
        v_idioma       NUMBER;
        v_sproces      NUMBER;
        v_idcarga      NUMBER := 0;
        v_numerr       NUMBER := 0;
     BEGIN
        vtraza := 0;
        v_idioma := k_idiomaaaxis;

        IF psproces IS NULL THEN
           vnum_err := 9000505;
           pac_cargas_conf.p_genera_logs(vobj, vtraza, 'Error:' || vnum_err,
                                         'Parmetro psproces obligatorio.', psproces,
                                         f_axis_literales(vnum_err, v_idioma) || ':'
                                         || v_tfichero || ' : ' || vnum_err);
           RAISE errorini;
        END IF;

        vtraza := 1;
        
        RETURN 0;
     EXCEPTION
        WHEN vsalir THEN
           NULL;
           RETURN 1;
        WHEN e_errdatos THEN
           ROLLBACK;
           pac_cargas_conf.p_genera_logs(vobj, vtraza, 'Error:' || vnum_err, vdeserror,
                                         psproces, 'Error:' || vnum_err || ' ' || vdeserror);
           vnum_err := f_procesfin(v_sproces, 1);
           COMMIT;
           RETURN 1;
        WHEN errorini THEN   --Error al insertar estados
           ROLLBACK;
           pac_cargas_conf.p_genera_logs(vobj, vtraza,
                                         'Error:' || 'ErrorIni' || ' en :' || vnum_err,
                                         'Error:' || 'Insertando estados registros', psproces,
                                         f_axis_literales(108953, v_idioma) || ':' || v_tfichero
                                         || ' : ' || 'errorini');
           vnum_err := f_procesfin(v_sproces, 1);
           COMMIT;
           RETURN 1;
        WHEN OTHERS THEN
           ROLLBACK;
           --KO si ha habido algun error en la cabecera
           pac_cargas_conf.p_genera_logs(vobj, vtraza, 'Error:' || vnum_err, SQLERRM, psproces,
                                         f_axis_literales(103187, v_idioma) || ':' || v_tfichero
                                         || ' : ' || SQLERRM);
           vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces, v_tfichero,
                                                                      f_sysdate, NULL, 1,
                                                                      p_cproces, 151541,
                                                                      SQLERRM);

           IF vnum_err <> 0 THEN
              pac_cargas_conf.p_genera_logs
                            (vobj, vtraza, vnum_err,
                             'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera2',
                             psproces,
                             f_axis_literales(180856, v_idioma) || ':' || v_tfichero || ' : '
                             || vnum_err);
              RAISE errorini;
           END IF;

           vnum_err := f_procesfin(v_sproces, 1);
           COMMIT;
           RETURN 1;
     END f_proceso_vidagrupo;
  
     
    -- Inicio IAXIS-7629  JRVG 20/02/2020
     
  /******************************************************************************
    NOMBRE:     p_setPersona_Cargar_Vg
    PROPOSITO:  Esta función crea y actualiza una persona en iAxis cuando carga archivo de VIDAGRUPO.
    PARAMETROS:
         return            : 0 -> Todo correcto
                             1 -> Se ha producido un error
  *****************************************************************************/

   PROCEDURE p_setPersona_Cargar_Vg(pRuta in varchar2,
                                       p_nombre in varchar2,
                                       p_cproces in number,
                                       p_sproces in number,
                                       pCountFail out number,
                                       pCountSuccess out number,
                                       perror  out number ) IS
    vcountVG                number := 0;
    vnumerr                 NUMBER(8) := 0;
    vsperson                number;
    vmensajes               t_iax_mensajes;
    vcountPersona           number := 0;
    --vsexper                 number := 0;
    vestper                 number := 0;
    vagente                 number;
    vtipide                 number;
    vsseguro                number;
    vcountContact           number := 0;
    vcountDireccion         number := 0;
    v_countdireccion        number := 0;
    vcheckExistingPerson    number := 0;
    vcheckUpdateCuenta      number := 0;
    v_existe_telefono       number:= 0;
    v_existe_movil          number:= 0;
    v_existe_correo         number:= 0;
    vnombreCargarVG         VARCHAR2(500);
    vcargarVG               UTL_FILE.file_type;
    vlinea                  VARCHAR2(200);
    vSFINANCI               number;
    vFConsti                date;
    vname                   VARCHAR2(500);
    vtsiglas                VARCHAR2(500) := null;
    videntificationNum      VARCHAR2(12);
    vcheckContactos         boolean := false;
    vcheckDireccions        boolean := false;
    vcheckCIIU              boolean := false;
    --vcountFIN_ENDEUDAMIENTO number := 0;
    vcpostal                VARCHAR2(30);
    --v_msg                   VARCHAR2(500);
    v_num_lin               number := 0;
    --secuencia               varchar(20);
    PCTIPBAN                NUMBER;
    pnorden                 number;
    --ORDEN                   NUMBER;
    PSPERSON                number;
    modo                    number:=0;  -- 0 Inset / 1 Update 
    pctipdir                NUMBER(2);
    vCciiu                  NUMBER;
    vCtipsoci               number;
    pFechaNacimiento        varchar2(20);
    pEstado                 varchar2(4);
    pCsexper                varchar2(4);

    pCONTACTOS_PER  t_iax_contactos_per;
    pdireccions_per t_iax_direcciones;

    CURSOR cur_Cargar_VIDAGRUPO IS
      select * from vidagrupo_ext ;

  begin
    pCONTACTOS_PER := t_iax_contactos_per();
    pdireccions_per := t_iax_direcciones();

    select count(*) into vcountVG from vidagrupo_ext;
    --dbms_output.put_line('vcountVG ::' || vidagrupo_ext);

    vnombreCargarVG := 'CargarVIDAGRUPO_Mal_Datao_' ||
                          TO_CHAR(f_sysdate, 'yyyymmdd_hh24miss') || '.txt';
    vcargarVG       := UTL_FILE.fopen(pRuta, vnombreCargarVG, 'w');
    vlinea             := 'IDENTIFICACION|NOMBRE|DESCRIPCION';
    UTL_FILE.put_line(vcargarVG, vlinea);

    pCountFail :=0;
    pCountSuccess :=0;

    if vcountVG > 0 then
      
      FOR i IN cur_Cargar_VIDAGRUPO LOOP
     
        vsperson := null;
        vagente  := null;
        vSFINANCI:= null;
        vFConsti := null;
        vtsiglas := null;
        vcountContact   := 0;
        vcountDireccion := 0;
        pCONTACTOS_PER.DELETE;
        pdireccions_per.DELETE;
        v_num_lin := v_num_lin + 1;

        if i.tipo_id = 1 then  --VALIDA SI LA PERSONA EXISTE O NO
          pctipdir:= 9; -- Asignamos "Tipo Residencia" para Persona PN
            select count(*)
              into vcountPersona
              from per_personas p
             where p.nnumide = i.no_id;  
        else
          pctipdir:= 10; -- Asignamos "Tipo Oficina Principal" para  Persona PJ
            select count(*)
              into vcountPersona
              from per_personas p
             where p.nnumide = i.no_id || i.digito_dq;
        end if;

        if vcountPersona > 0 then  -- SI EXISTE...
           modo := 1; -- Actualiza Datos
           
            if i.tipo_id = 1 then  
              select p.sperson, p.cagente
                into vsperson, vagente
                from per_personas p
               where p.nnumide = i.no_id;
            else
              select p.sperson, p.cagente
                into vsperson, vagente
                from per_personas p
               where p.nnumide = i.no_id || i.digito_dq;
            end if;

            select f.sfinanci, f.fconsti, f.cciiu,f.ctipsoci -- CHEQUEAMOS SI ESXISTE DATOS EN Fin_general  
              into vSFINANCI, vFConsti, vCciiu, vCtipsoci
              from fin_general f           
             where f.sperson = vsperson
               and rownum = 1;  

            if i.tipo_id = 1 then -- CHEQUEAMOS SI ESXISTE DATOS EN per_detper
               select count(*)
                 into vcheckExistingPerson 
                 from per_detper d
                where upper(d.tapelli1) = upper(i.apellido1_dq)
                  --and upper(d.tapelli2) = upper(i.apellido2_dq)
                  and upper(d.tnombre1) = upper(i.nombre1_dq)
                  --and upper(d.tnombre2) = upper(i.nombre2_dq)
                  and d.sperson = vsperson;
            else
              select count(*)
                into vcheckExistingPerson
                from per_detper d
               where upper(d.tapelli1) = upper(i.razon_social)
                 and d.sperson = vsperson;
            end if;
            
                -- CHEQUEAMOS SI ESXISTE DATOS EN PER_DIRECCIONES
              begin 
                select count(*)
                  into v_countdireccion
                  from per_direcciones
                 where cagente = vagente
                   and upper(tnomvia) = upper(i.direccion_1)
                   and cpoblac = substr(i.codigo_ciudad1_1,3)
                   and cprovin = i.codigo_depto1_1
                   and sperson = vsperson
                   and ctipdir in (1,9)
                   and rownum = 1;
                   
                  select p.fnacimi, p.cestper, p.csexper
                    into pFechaNacimiento, pEstado, pCsexper
                    from per_personas p
                   where p.sperson = vsperson;

                -- CHEQUEAMOS SI ESXISTE DATOS EN PER_CONTACTOS
                select count(*)
                  into v_existe_telefono
                  from per_contactos
                 where sperson = vsperson
                   and tvalcon = i.telefono_1
                   and ctipcon = 1
                   and cagente = vagente;
                   
                select count(*)
                  into v_existe_movil
                  from per_contactos
                 where sperson = vsperson
                   and tvalcon = i.celular_1
                   and ctipcon = 3
                   and cagente = vagente;
                   
                select count(*)
                  into v_existe_correo
                  from per_contactos
                 where sperson = vsperson
                   and tvalcon = i.correo_1
                   and ctipcon = 6
                   and cagente = vagente;
                end;
                
                begin -- CHEQUEAMOS SI ESXISTE DATOS EN PER_CCC
                  select distinct ctipban, norden
                    into pctipban, pnorden
                    from tipos_cuenta
                   where cbanco = i.num_banco
                     and ctipcc = i.tipo_cuenta;
                  exception 
                     when no_data_found then 
                       pctipban := null;
                end;
                
                if pctipban is not null then
                  
                    SELECT COUNT(*)
                      INTO vcheckUpdateCuenta
                      FROM per_ccc C
                     WHERE C.SPERSON = vsperson
                       and c.ctipban = pctipban
                       and c.cnordban = pnorden;
                else 
                    vcheckUpdateCuenta := 0;
                end if;

            if vcheckExistingPerson = 0 then
              if i.tipo_id = (1) then
                vlinea := i.no_id || '|' || upper(i.apellido1_dq) ||' '|| upper(i.apellido2_dq) ||' '||
                          upper(i.nombre1_dq) ||' '|| upper(i.nombre2_dq) || '|NO COINCIDEN NOMBRES';
                UTL_FILE.put_line(vcargarVG, vlinea);
              else
                vlinea := i.no_id || '|' || upper(i.razon_social) || '|NO COINCIDEN NOMBRES';
                UTL_FILE.put_line(vcargarVG, vlinea);
              end if;
              pCountFail := pCountFail + 1;
              vnumerr  := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces   => p_sproces,
                                                                      pnlinea    => v_num_lin,
                                                                      pctipo     => 3,
                                                                      pidint     => v_num_lin,
                                                                      pidext     => v_num_lin,
                                                                      pcestado   => 5,
                                                                      pcvalidado => NULL,
                                                                      psseguro   => NULL,
                                                                      pidexterno => NULL,
                                                                      pncarga    => NULL,
                                                                      pnsinies   => NULL,
                                                                      pntramit   => NULL,
                                                                      psperson   => vsperson,
                                                                      pnrecibo   => NULL);
              CONTINUE;
            end if;
        else
           modo:= 0; -- Modo creación de Persona
        end if;
        
        if i.celular_1 is null and i.correo_1 is null and i.telefono_1 is null then
          
          if i.tipo_id = 1 then
            vlinea := i.no_id || '|' || upper(i.apellido1_dq) ||' '|| upper(i.apellido2_dq) ||' '||
                        upper(i.nombre1_dq) ||' '|| upper(i.nombre2_dq) || '|FALTA CONTACTO';
            UTL_FILE.put_line(vcargarVG, vlinea);
          else
            vlinea := i.no_id || '|' || upper(i.razon_social) || '|FALTA CONTACTO';
            UTL_FILE.put_line(vcargarVG, vlinea);
          end if;
            vcheckContactos := true;
            pCountFail := pCountFail + 1;

            vnumerr  := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces   => p_sproces,
                                                                    pnlinea    => v_num_lin,
                                                                    pctipo     => 3,
                                                                    pidint     => v_num_lin,
                                                                    pidext     => v_num_lin,
                                                                    pcestado   => 5,
                                                                    pcvalidado => NULL,
                                                                    psseguro   => NULL,
                                                                    pidexterno => NULL,
                                                                    pncarga    => NULL,
                                                                    pnsinies   => NULL,
                                                                    pntramit   => NULL,
                                                                    psperson   => vsperson,
                                                                    pnrecibo   => NULL);
          CONTINUE;
          
        else
          vcheckContactos := false;
        end if;

        if i.direccion_1 is null  then
          
          if i.tipo_id = 1 then
            vlinea := i.no_id || '|' || upper(i.apellido1_dq) ||' '|| upper(i.apellido2_dq) ||' '||
                        upper(i.nombre1_dq) ||' '|| upper(i.nombre2_dq) || '|FALTA DIRECCION';
            UTL_FILE.put_line(vcargarVG, vlinea);
          else
            vlinea := i.no_id || '|' || upper(i.razon_social) || '|FALTA DIRECCION';
            UTL_FILE.put_line(vcargarVG, vlinea);
          end if;
            vcheckDireccions := true;
            pCountFail := pCountFail + 1;

            vnumerr  := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces   => p_sproces,
                                                                    pnlinea    => v_num_lin,
                                                                    pctipo     => 3,
                                                                    pidint     => v_num_lin,
                                                                    pidext     => v_num_lin,
                                                                    pcestado   => 5,
                                                                    pcvalidado => NULL,
                                                                    psseguro   => NULL,
                                                                    pidexterno => NULL,
                                                                    pncarga    => NULL,
                                                                    pnsinies   => NULL,
                                                                    pntramit   => NULL,
                                                                    psperson   => vsperson,
                                                                    pnrecibo   => NULL);
          CONTINUE;
        else
          vcheckDireccions := false;
        end if;
  
        if i.codigo_ciiu is null then
          
          if i.tipo_id = 1 then
            vlinea := i.no_id || '|' || upper(i.apellido1_dq) ||' '|| upper(i.apellido2_dq) ||' '||
                        upper(i.nombre1_dq) ||' '|| upper(i.nombre2_dq) || '|FALTA CIIU';
            UTL_FILE.put_line(vcargarVG, vlinea);
          else
            vlinea := i.no_id || '|' || upper(i.razon_social) || '|FALTA CIIU';
            UTL_FILE.put_line(vcargarVG, vlinea);
          end if;
            vcheckCIIU := true;
            pCountFail := pCountFail + 1;

            vnumerr  := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces   => p_sproces,
                                                                    pnlinea    => v_num_lin,
                                                                    pctipo     => 3,
                                                                    pidint     => v_num_lin,
                                                                    pidext     => v_num_lin,
                                                                    pcestado   => 5,
                                                                    pcvalidado => NULL,
                                                                    psseguro   => NULL,
                                                                    pidexterno => NULL,
                                                                    pncarga    => NULL,
                                                                    pnsinies   => NULL,
                                                                    pntramit   => NULL,
                                                                    psperson   => vsperson,
                                                                    pnrecibo   => NULL);
          CONTINUE;
          
        else
          vcheckCIIU := false;
        end if;
        
        if i.tipo_id = 1 then
          vname              := i.apellido1_dq;
          videntificationNum := i.no_id;
        else
          vname              := i.razon_social;
          vtsiglas           := vname;
          videntificationNum := i.no_id || i.digito_dq;
        end if;
          
        if vagente is null then
          vagente := 19000;
        end if;

        if i.tipo_id in (1, 2, 3, 4, 5, 9, 10) then
          if i.tipo_id = 1 then
            vtipide := 36;
          elsif i.tipo_id = 2 then
            vtipide := 37;
          elsif i.tipo_id = 3 then
            vtipide := 33;
          elsif i.tipo_id = 4 then
            vtipide := 34;
          elsif i.tipo_id = 5 then
            vtipide := 24;
          elsif i.tipo_id = 9 then
            vtipide := 35;
          elsif i.tipo_id = 10 then
            vtipide := 44;
          end if;
        else
            vtipide := null;
        end if; 
          
         if vcheckContactos = false and vcheckDireccions = false and vcheckCIIU = false  then
           
          if i.celular_1 is not null then
            vcountContact := vcountContact + 1;
            pcontactos_per.EXTEND;
            pcontactos_per(vcountContact) := OB_IAX_CONTACTOS_PER('','',i.celular_1,'','','','');
          end if;
          
          if i.correo_1 is not null then
            vcountContact := vcountContact + 1;
            pcontactos_per.EXTEND;
            pcontactos_per(vcountContact) := OB_IAX_CONTACTOS_PER('','','','',i.correo_1,'','');
          end if;
          
          if i.telefono_1 is not null then
            vcountContact := vcountContact + 1;
            pcontactos_per.EXTEND;
            pcontactos_per(vcountContact) := OB_IAX_CONTACTOS_PER(i.telefono_1,'','','','','','');
          end if;
          
          if i.direccion_1 is not null and i.codigo_depto1_1 is not null and i.codigo_ciudad1_1 is not null then
              vcountDireccion := vcountDireccion + 1;
              pdireccions_per.EXTEND;
              begin
                 vcpostal := null;
                 select c.cpostal 
                   into vcpostal from codpostal c 
                  where c.cprovin =  i.codigo_depto1_1 
                    and c.cpoblac = trunc(REPLACE(i.codigo_ciudad1_1,i.codigo_depto1_1,''));
              exception
              WHEN NO_DATA_FOUND THEN
                 vcpostal := null;
              end;
              pdireccions_per(vcountDireccion) := ob_iax_direcciones('',
                                                                     '',
                                                                     vcpostal,
                                                                     i.codigo_depto1_1,
                                                                     '',
                                                                     trunc(REPLACE(i.codigo_ciudad1_1,i.codigo_depto1_1,'')),
                                                                     '',
                                                                     i.codigo_pais,
                                                                     '',
                                                                     pctipdir,
                                                                     '',
                                                                     '',
                                                                     '',
                                                                     i.direccion_1,
                                                                     '',
                                                                     '',
                                                                     '',
                                                                     '',
                                                                     '',
                                                                     '',
                                                                     '',
                                                                     '',
                                                                     '',
                                                                     '',
                                                                     '',
                                                                     '',
                                                                     '',
                                                                     '',
                                                                     '',
                                                                     '',
                                                                     '',
                                                                     '',
                                                                     '',
                                                                     '',
                                                                     '',
                                                                     '',
                                                                     trunc(REPLACE(i.codigo_ciudad1_1,i.codigo_depto1_1,'')),
                                                                     '',
                                                                     trunc(REPLACE(i.codigo_ciudad1_1,i.codigo_depto1_1,'')),
                                                                     i.codigo_depto1_1);
           end if;
           
          if modo = 0 then -- Inicio Creacion persona Plantilla VIDAGRUPO
            vnumerr := pac_md_persona.f_set_persona(vsseguro,
                                                    vsperson,
                                                    vsperson,
                                                    vagente,
                                                    i.tipper,
                                                    vtipide,
                                                    videntificationNum,
                                                    i.genero,
                                                    i.fecha_nacimiento,
                                                    NULL,
                                                    vestper,
                                                    NULL,
                                                    NULL,
                                                    NULL,
                                                    NULL,
                                                    8,
                                                    vname,
                                                    i.apellido2_dq,
                                                    NULL,
                                                    vtsiglas,
                                                    NULL,
                                                    NULL,
                                                    i.codigo_pais1_1,
                                                    'POL',
                                                    0,
                                                    NULL,
                                                    i.nombre1_dq,
                                                    i.nombre2_dq,
                                                    0,
                                                    NULL,
                                                    i.tipo_sociedad,
                                                    i.codigo_ciiu,
                                                    vSFINANCI,
                                                    vFConsti,
                                                    pCONTACTOS_PER,
                                                    pDIRECCIONS_PER,
                                                    170,
                                                    i.digito_dq,
                                                    vmensajes,
                                                    NULL,
                                                    NULL,
                                                    NULL,
                                                    NULL);
                                                  
                                                 
           if vnumerr = 0 then
             
            if i.tipo_id =1 then
              
              select p.sperson 
                into psperson
                from per_personas p
               where p.nnumide = i.no_id;
               
               vnumerr := pac_sin_imp_sap.f_set_impuesto_per(i.codvin,null,659,psperson);
               vnumerr := pac_md_persona.f_mod_identificador(psperson,
                                                             vagente,
                                                             vtipide,
                                                             i.no_id,
                                                             1,
                                                             vmensajes,
                                                             'POL',
                                                             i.codigo_pais,
                                                             i.codigo_depto,
                                                             i.codigo_ciudad,
                                                             i.fecha_expedicion);
           
            else
              
              select p.sperson 
                into psperson
                from per_personas p
               where p.nnumide = i.no_id || i.digito_dq;  
               vnumerr := pac_sin_imp_sap.f_set_impuesto_per(i.codvin,null,659,psperson);
                
            end if;
             
          end if ;

          else -- Inicio actualizacion de Datos Plantilla VIDAGRUPO
           
           if  pEstado <> i.estado  then --Estado , Fecha de Nacimiento
            vnumerr := pac_md_persona.f_set_persona(vsseguro,
                                                    vsperson,
                                                    vsperson,
                                                    vagente,
                                                    i.tipper,
                                                    vtipide,
                                                    videntificationNum,
                                                    i.genero,
                                                    i.fecha_nacimiento,
                                                    NULL,
                                                    i.estado,
                                                    NULL,
                                                    NULL,
                                                    NULL,
                                                    NULL,
                                                    8,
                                                    vname,
                                                    i.apellido2_dq,
                                                    NULL,
                                                    vtsiglas,
                                                    NULL,
                                                    NULL,
                                                    i.codigo_pais1_1,
                                                    'POL',
                                                    0,
                                                    NULL,
                                                    i.nombre1_dq,
                                                    i.nombre2_dq,
                                                    0,
                                                    NULL,
                                                    i.tipo_sociedad,
                                                    i.codigo_ciiu,
                                                    vSFINANCI,
                                                    vFConsti,
                                                    null,
                                                    null,
                                                    170,
                                                    i.digito_dq,
                                                    vmensajes,
                                                    NULL,
                                                    NULL,
                                                    NULL,
                                                    NULL);
          end if;
          
          if v_countDireccion = 0 then  --direccion 
            
            vnumerr := pac_md_persona.f_set_persona(vsseguro,
                                                    vsperson,
                                                    vsperson,
                                                    vagente,
                                                    i.tipper,
                                                    vtipide,
                                                    videntificationNum,
                                                    i.genero,
                                                    i.fecha_nacimiento,
                                                    NULL,
                                                    vestper,
                                                    NULL,
                                                    NULL,
                                                    NULL,
                                                    NULL,
                                                    8,
                                                    vname,
                                                    i.apellido2_dq,
                                                    NULL,
                                                    vtsiglas,
                                                    NULL,
                                                    NULL,
                                                    i.codigo_pais1_1,
                                                    'POL',
                                                    0,
                                                    NULL,
                                                    i.nombre1_dq,
                                                    i.nombre2_dq,
                                                    0,
                                                    NULL,
                                                    i.tipo_sociedad,
                                                    i.codigo_ciiu,
                                                    vSFINANCI,
                                                    vFConsti,
                                                    NULL,
                                                    pDIRECCIONS_PER,
                                                    170,
                                                    i.digito_dq,
                                                    vmensajes,
                                                    NULL,
                                                    NULL,
                                                    NULL,
                                                    NULL);
          end if;
          
          if v_existe_telefono = 0 and v_existe_movil = 0  and v_existe_correo = 0 then   -- contacto
            
            vnumerr := pac_md_persona.f_set_persona(vsseguro,
                                                    vsperson,
                                                    vsperson,
                                                    vagente,
                                                    i.tipper,
                                                    vtipide,
                                                    videntificationNum,
                                                    i.genero,
                                                    i.fecha_nacimiento,
                                                    NULL,
                                                    vestper,
                                                    NULL,
                                                    NULL,
                                                    NULL,
                                                    NULL,
                                                    8,
                                                    vname,
                                                    i.apellido2_dq,
                                                    NULL,
                                                    vtsiglas,
                                                    NULL,
                                                    NULL,
                                                    i.codigo_pais1_1,
                                                    'POL',
                                                    0,
                                                    NULL,
                                                    i.nombre1_dq,
                                                    i.nombre2_dq,
                                                    0,
                                                    NULL,
                                                    i.tipo_sociedad,
                                                    i.codigo_ciiu,
                                                    vSFINANCI,
                                                    vFConsti,
                                                    pCONTACTOS_PER,
                                                    null,
                                                    170,
                                                    i.digito_dq,
                                                    vmensajes,
                                                    NULL,
                                                    NULL,
                                                    NULL,
                                                    NULL);
          end if;
          
          IF vCciiu <> i.codigo_ciiu then 
              vnumerr := PAC_IAX_FINANCIERA.F_GRABAR_GENERAL(vsperson, -- Estado Persona, Codigo CIIU
                                                             vSFINANCI,
                                                             '1',
                                                             null,
                                                             null,
                                                             null,
                                                             null,
                                                             null,
                                                             null,
                                                             null,
                                                             i.codigo_pais,
                                                             null,
                                                             null,
                                                             null,
                                                             i.codigo_ciiu,
                                                             vCtipsoci,
                                                             null,
                                                             null,
                                                             null,
                                                             vFConsti,
                                                             null,
                                                             vmensajes);
          end if;
          
          if pFechaNacimiento <> i.fecha_nacimiento  or pCsexper <> i.genero then
            
              vnumerr := pac_md_persona.f_set_basicos_persona(vsperson,  -- Fecha de nacimiento y genero de la persona
                                                              i.tipper,
                                                              vtipide,
                                                              videntificationNum,
                                                              i.genero,
                                                              i.fecha_nacimiento,
                                                              0,
                                                              'POL',
                                                              0,
                                                              NULL,
                                                              vmensajes);
          end if;
          
               vnumerr := pac_md_persona.f_mod_identificador(vsperson, -- Identificadores, fecgha exp, pais, ciudad , depto  (Documentos)
                                                             vagente,
                                                             vtipide,
                                                             i.no_id,
                                                             1,
                                                             vmensajes,
                                                             'POL',
                                                             i.codigo_pais,
                                                             i.codigo_depto,
                                                             i.codigo_ciudad,
                                                             i.fecha_expedicion);
                                                             
             
                vnumerr := pac_md_persona.f_validaccc(pctipban,i.num_banco,vmensajes);
             
             if vnumerr = 0  and pctipban is null then
               
                vnumerr := pac_md_persona.f_set_ccc(vsperson, -- Actualizacion de Cuentas Bancarias
                                                    vagente,
                                                    pnorden,
                                                    pctipban,
                                                    i.num_cuenta,
                                                    1,
                                                    vmensajes,
                                                    'POL',
                                                    0,
                                                    sysdate,
                                                    0,
                                                    i.tipo_cuenta);
             else 
                 vnumerr := pac_md_persona.f_set_ccc(vsperson, -- Actualizacion de Cuentas Bancarias
                                                    vagente,
                                                    pnorden,
                                                    pctipban,
                                                    i.num_cuenta,
                                                    1,
                                                    vmensajes,
                                                    'POL',
                                                    0,
                                                    sysdate,
                                                    0,
                                                    i.tipo_cuenta);
                vnumerr := 0;
             end if;
  
        end if; 
        
        if vnumerr > 0 then
            pCountFail := pCountFail + 1;
            rollback;
            if i.tipo_id = 1 then
              vlinea := i.no_id || '|' || upper(i.apellido1_dq) ||' '|| upper(i.apellido2_dq) ||' '||
                        upper(i.nombre1_dq) ||' '|| upper(i.nombre2_dq) || '|DATOS INVLIDOS  ';
              UTL_FILE.put_line(vcargarVG, vlinea);
            else
              vlinea := i.no_id || '|' || upper(i.razon_social) || '|DATOS INVLIDOS ';
              UTL_FILE.put_line(vcargarVG, vlinea);
            end if;
            vnumerr  := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces   => p_sproces,
                                                                    pnlinea    => v_num_lin,
                                                                    pctipo     => 3,
                                                                    pidint     => v_num_lin,
                                                                    pidext     => v_num_lin,
                                                                    pcestado   => 5,
                                                                    pcvalidado => NULL,
                                                                    psseguro   => NULL,
                                                                    pidexterno => NULL,
                                                                    pncarga    => NULL,
                                                                    pnsinies   => NULL,
                                                                    pntramit   => NULL,
                                                                    psperson   => vsperson,
                                                                    pnrecibo   => NULL);
          else
            pCountSuccess := pCountSuccess + 1;
            commit;
            vnumerr  := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces   => p_sproces,
                                                                    pnlinea    => v_num_lin,
                                                                    pctipo     => 3,
                                                                    pidint     => v_num_lin,
                                                                    pidext     => v_num_lin,
                                                                    pcestado   => 4,
                                                                    pcvalidado => NULL,
                                                                    psseguro   => NULL,
                                                                    pidexterno => NULL,
                                                                    pncarga    => NULL,
                                                                    pnsinies   => NULL,
                                                                    pntramit   => NULL,
                                                                    psperson   => vsperson,
                                                                    pnrecibo   => NULL);
          end if;
          
       END IF; /* if de verificar datos contactabilidad*/
      end loop; /* loop cuando tienes datos en VIDAGRUPO_EXT */
    else
      dbms_output.put_line('Archivo no tiene datos para cargar.');
    end if; /* if de cuando tienes dataos en VIDAGRUPO_EXT */

  if vcountVG = (pCountSuccess+pCountFail) then
     perror := 0;
  else
     perror := 1;
  end if;
    /* Cerar archivo */
    IF UTL_FILE.is_open(vcargarVG) THEN
      UTL_FILE.fclose(vcargarVG);
    END IF;

  END p_setPersona_Cargar_Vg;

-- INI BUG IAXIS-13317 JRVG 31/03/2020  
  FUNCTION f_proceso_cargasap (psproces IN NUMBER, p_cproces IN NUMBER)
        RETURN NUMBER IS
        vobj           VARCHAR2(100) := 'pac_cargas_conf.f_proceso_vidagrupo';
        vtraza         NUMBER := 0;
        vdeserror      VARCHAR2(1000);
        errorini       EXCEPTION;   --Indica error grabando estados.--Error que para ejecucin
        vsalir         EXCEPTION;
        emigra         EXCEPTION;
        --vcoderror      NUMBER;
        --v_deserror     int_carga_ctrl_linea_errs.tmensaje%TYPE;
        v_tfichero     int_carga_ctrl.tfichero%TYPE;
        e_errdatos     EXCEPTION;
        e_validaciones EXCEPTION;
        vnum_err       NUMBER;
        verror         NUMBER;   --Codigo error
        v_idioma       NUMBER;
        v_sproces      NUMBER;
     BEGIN
        vtraza := 0;
        v_idioma := k_idiomaaaxis;

        IF psproces IS NULL THEN
           vnum_err := 9000505;
           pac_cargas_conf.p_genera_logs(vobj, vtraza, 'Error:' || vnum_err,
                                         'Parmetro psproces obligatorio.', psproces,
                                         f_axis_literales(vnum_err, v_idioma) || ':'
                                         || v_tfichero || ' : ' || vnum_err);
           RAISE errorini;
        END IF;

        vtraza := 1;

        RETURN 0;
     EXCEPTION
        WHEN vsalir THEN
           NULL;
           RETURN 1;
        WHEN e_errdatos THEN
           ROLLBACK;
           pac_cargas_conf.p_genera_logs(vobj, vtraza, 'Error:' || vnum_err, vdeserror,
                                         psproces, 'Error:' || vnum_err || ' ' || vdeserror);
           vnum_err := f_procesfin(v_sproces, 1);
           COMMIT;
           RETURN 1;
        WHEN errorini THEN   --Error al insertar estados
           ROLLBACK;
           pac_cargas_conf.p_genera_logs(vobj, vtraza,
                                         'Error:' || 'ErrorIni' || ' en :' || vnum_err,
                                         'Error:' || 'Insertando estados registros', psproces,
                                         f_axis_literales(108953, v_idioma) || ':' || v_tfichero
                                         || ' : ' || 'errorini');
           vnum_err := f_procesfin(v_sproces, 1);
           COMMIT;
           RETURN 1;
        WHEN OTHERS THEN
           ROLLBACK;
           --KO si ha habido algun error en la cabecera
           pac_cargas_conf.p_genera_logs(vobj, vtraza, 'Error:' || vnum_err, SQLERRM, psproces,
                                         f_axis_literales(103187, v_idioma) || ':' || v_tfichero
                                         || ' : ' || SQLERRM);
           vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces, v_tfichero,
                                                                      f_sysdate, NULL, 1,
                                                                      p_cproces, 151541,
                                                                      SQLERRM);

           IF vnum_err <> 0 THEN
              pac_cargas_conf.p_genera_logs
                            (vobj, vtraza, vnum_err,
                             'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera2',
                             psproces,
                             f_axis_literales(180856, v_idioma) || ':' || v_tfichero || ' : '
                             || vnum_err);
              RAISE errorini;
           END IF;

           vnum_err := f_procesfin(v_sproces, 1);
           COMMIT;
           RETURN 1;
     END f_proceso_cargasap;
  -- FIN BUG IAXIS-13317 JRVG 31/03/2020
  
  -- INI IAXIS-5241 JRVG 14/04/2020
   procedure  p_update_cgescar(psproces in number) is
      vobjectname    varchar2(200) := 'PAC_CARGAS_CONF.P_UPDATE_CGESCAR';
      vpas           number := 0;
	  
	  cursor cur_outsorcing  is
      select o.nrecibo,o.aplica_out,o.cgescar,o.cproces
        from outsorcing_ext o, recibos r 
       where o.nrecibo = r.nrecibo
         and cproces = psproces;   
       
    begin
         for i in  cur_outsorcing loop
            vpas:= i.nrecibo;                    
             update recibos
                set cgescar = i.cgescar 
              where nrecibo = i.nrecibo;   --devuelto en el archivo cargado
         end loop;
      commit;
    exception
      when others then
         p_tab_error(f_sysdate, f_user, vobjectname, vpas, psproces,
                     'SQLERROR: ' || sqlcode || ' - ' || sqlerrm);
   end p_update_cgescar;
   --FIN IAXIS-5241 JRVG 14/04/2020

END pac_cargas_conf;

/
