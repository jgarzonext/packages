
  CREATE OR REPLACE PACKAGE BODY "PAC_CARGAS_GENERICO" IS
    /******************************************************************************
       NOMBRE:     pac_cargas_generico
       PROP¿SITO: Funciones para la gesti¿n de la carga de procesosa
       REVISIONES:
       Ver        Fecha        Autor             Descripci¿n
       ---------  ----------  ---------------  ------------------------------------
       1.0        05/07/2010   JLB              1. Creaci¿n del package.
       2.0        23/01/2013   MMS              2. 0025584: (f_controledad) Agregamos el par¿metro nedamar a NULL
       3.0        14/11/2013   JMF              0028909: RSA002-Parametrizaci¿n y ajustes Carga de siniestros RSA
       4.0        13/10/2015   NMM              38020: Revisi¿ codi
       5.0        01/04/2019   Swapnil          Cambios de IAXIS-3420
	   6.0 		  03/05/2019   Swapnil		    Cambios de IAXIS-3650
     
   ********************************************************************************/
   k_cempresa CONSTANT empresas.cempres%TYPE
                      := NVL(pac_md_common.f_get_cxtempresa, f_parinstalacion_n('EMPRESADEF'));
   k_cidioma CONSTANT idiomas.cidioma%TYPE
              := pac_parametros.f_parempresa_n(f_parinstalacion_n('EMPRESADEF'), 'IDIOMA_DEF');
   k_cpara_error  cfg_files.cpara_error%TYPE;
   k_busca_host   cfg_files.cbusca_host%TYPE;
   k_cformato_decimales cfg_files.cformato_decimales%TYPE := 0;   -- Decimales se multiplica el valor * 100. Valor por defecto
   k_cdebug       cfg_files.cdebug%TYPE := 99;   -- por defecto maximo debug
   k_nregmasivo   cfg_files.nregmasivo%TYPE := 1;   --por defecto procedsamos una unica entidad (poliza, recibo, siniestro, persona..)

   -- optimizaci¿n buena
   FUNCTION f_recupera_separador_decimal
      RETURN CHAR;

   -- k_sistema_numerico_bd parempresas.tvalpar%TYPE
    --   := NVL(pac_parametros.f_parempresa_t(f_parinstalacion_n('EMPRESADEF'),
     --                                       'SISTEMA_NUMERICO_BD'),
     --         ',.');
   k_sistema_numerico_bd CHAR := f_recupera_separador_decimal;
   --  k_cmotivoanula   motmovseg.cmotmov%TYPE := 324;
   k_tablas       VARCHAR2(3) := 'EST';
   k_iteraciones CONSTANT NUMBER(2) := 10;   -- veces que intento modificar la tabla externa
   k_segundos CONSTANT NUMBER(2) := 10;   -- espera para veces que intento modificar la tabla externa
   k_mascara_date CONSTANT VARCHAR2(12) := 'FXDD/MM/YYYY';
   e_errdatos     EXCEPTION;
   v_tdeserror    int_carga_ctrl_linea_errs.tmensaje%TYPE;
   v_nnumerr      NUMBER;
   v_nnumerr1     NUMBER;
   b_cobro_parcial BOOLEAN := FALSE;

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

-- recupero el seperador de decimal de la base de datos.
   FUNCTION f_recupera_separador_decimal
      RETURN CHAR IS
      v_decimal      CHAR;
   BEGIN
      SELECT SUBSTR(VALUE, 1, 1)
        INTO v_decimal
        FROM nls_session_parameters
       WHERE parameter = 'NLS_NUMERIC_CHARACTERS';

      RETURN v_decimal;
   END f_recupera_separador_decimal;

   /*************************************************************************
                       Procedimiento que guarda logs en las diferentes tablas.
       param p_tabobj in : tab_error tobjeto
       param p_tabtra in : tab_error ntraza
       param p_tabdes in : tab_error tdescrip
       param p_taberr in : tab_error terror
       param p_propro in : PROCESOSLIN sproces
       param p_protxt in : PROCESOSLIN tprolin
       devuelve n¿mero o null si existe error.
   *************************************************************************/
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

   /*************************************************************************
                       Funci¿n que marca linea que tratamos con un estado.
          param p_nsproces   in : proceso
          param p_nlinea     in : linea
          param p_ttipo      in : tipo
          param p_nestado    in : estado
          param p_nvalidado  in : validado
          param p_sseguro    in : seguro
          param p_nsiniestro in : siniestro
          param p_ntramite   in : tramite
          param p_sperson    in : persona
          param p_nrecibo    in : recibo
          devuelve n¿mero o null si existe error.
      *************************************************************************/
   FUNCTION p_marcalinea(
      p_nsproces IN NUMBER,
      p_nlinea IN NUMBER,
      p_ttipo IN VARCHAR2,
      p_nestado IN NUMBER,
      p_nvalidado IN NUMBER,
      p_sseguro IN NUMBER,
      p_id_ext IN VARCHAR2,
      p_ncarg IN NUMBER,
      p_nsiniestro IN NUMBER DEFAULT NULL,
      p_ntramite IN NUMBER DEFAULT NULL,
      p_sperson IN NUMBER DEFAULT NULL,
      p_nrecibo IN NUMBER DEFAULT NULL,
      p_idint IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER IS
      v_tobjeto      VARCHAR2(100) := 'pac_cargas_generico.P_MARCALINEA';
      nnumerr        NUMBER := 0;
      v_ntipo        NUMBER;
   BEGIN
      IF p_ttipo IN('ALTA', 'MODI', 'BAJA') THEN
         v_ntipo := 0;
      ELSIF p_ttipo IN('SIN', 'SINM') THEN
         v_ntipo := 1;
      ELSIF p_ttipo IN('REC', 'RECM') THEN
         v_ntipo := 2;
      ELSIF p_ttipo IN('PER', 'PERM') THEN
         v_ntipo := 3;
      ELSIF p_ttipo IN('PERD') THEN   -- domicilio persona
         v_ntipo := 12;
      ELSIF p_ttipo IN('PROF') THEN   -- profesional
         v_ntipo := 16;
      ELSE
         v_ntipo := 0;   -- deberia ser otra cosa
      END IF;

      nnumerr := pac_gestion_procesos.f_set_carga_ctrl_linea(p_nsproces, p_nlinea, v_ntipo,
                                                             NVL(p_idint, p_nlinea), p_ttipo,
                                                             p_nestado, p_nvalidado, p_sseguro,
                                                             p_id_ext, p_ncarg, p_nsiniestro,
                                                             p_ntramite, p_sperson, p_nrecibo);

      IF nnumerr <> 0 THEN   --Si fallan estas funciones de gesti¿n salimos del programa
         p_genera_logs(v_tobjeto, 1, nnumerr,
                       'proces=' || p_nsproces || ' linea=' || p_nlinea || ' tipo=' || p_ttipo
                       || ' Estado=' || p_nestado || ' id_externo=' || p_id_ext || ' seguro='
                       || p_sseguro);
         nnumerr := 1;
      END IF;

      RETURN nnumerr;
   END p_marcalinea;

   /*************************************************************************
                                                                                                                                                                Funci¿n que marca el error de la linea que tratamos.
          param p_ssproces in : proceso
          param p_nlinea   in : linea
          param p_nnumerr  in : numero error
          param p_ntipo    in : tipo
          param p_ncodigo  in : codigo
          param p_tmensaje in : mensaje
          devuelve n¿mero o null si existe error.
      *************************************************************************/
   FUNCTION p_marcalineaerror(
      p_ssproces IN NUMBER,
      p_nlinea IN NUMBER,
      p_nnumerr IN NUMBER,
      p_ntipo IN NUMBER,
      p_ncodigo IN NUMBER,
      p_tmensaje IN VARCHAR2)
      RETURN NUMBER IS
      v_tobjeto      VARCHAR2(100) := 'pac_cargas_generico.P_MARCALINEAERROR';
      nnumerr        NUMBER := 0;
   BEGIN
      nnumerr := pac_gestion_procesos.f_set_carga_ctrl_linea_error(p_ssproces, p_nlinea,
                                                                   p_nnumerr, p_ntipo,
                                                                   p_ncodigo, p_tmensaje);

      IF nnumerr <> 0 THEN   --Si fallan estas funciones de gesti¿n salimos del programa
         p_genera_logs(v_tobjeto, 1, nnumerr,
                       'proces=' || p_ssproces || ' lineea=' || p_nlinea || ' numerr='
                       || p_nnumerr || ' tipo=' || p_ntipo || ' codigo=' || p_ncodigo
                       || ' mensaje=' || p_tmensaje);
         nnumerr := 1;
      END IF;

      RETURN nnumerr;
   END p_marcalineaerror;

   /*************************************************************************
       Function f_chartodate
       Funci¿n que da un texto y una mascara convierte a date
          si la conversi¿n de char a fecha es correcta.
          param p_ttexto      IN  : caracter a convertir
          devuelve fecha o null si existe error.
      *************************************************************************/
   FUNCTION f_chartodate(p_ttexto IN VARCHAR2)
      RETURN DATE IS
      v_fret         DATE;
   BEGIN
      IF p_ttexto IS NULL THEN
         RETURN NULL;
      END IF;

      v_fret := TO_DATE(p_ttexto, k_mascara_date);
      RETURN v_fret;
   EXCEPTION
      WHEN OTHERS THEN
         v_nnumerr := 9901605;
         v_tdeserror := 'Error: El valor ' || p_ttexto || ' '
                        || ' no cumple el formato de fecha';
         RAISE e_errdatos;
   END f_chartodate;

   /*************************************************************************
                       Funcion f_ChartoNumber
          Si la conversi¿n de char a n¿merico es correcta.
          param p_ttexto  IN  : caracter a convertir
          devuelve n¿merico o null si existe error.
      *************************************************************************/
   FUNCTION f_chartonumber(p_ttexto IN VARCHAR2)
      RETURN NUMBER IS
      v_nret         NUMBER;
   BEGIN
      IF p_ttexto IS NULL THEN
         RETURN NULL;
      END IF;

      IF NVL(k_cformato_decimales, 0) = 0 THEN
         v_nret := TO_NUMBER(p_ttexto) / 100;
      ELSIF NVL(k_cformato_decimales, 0) = 1 THEN
         v_nret := TO_NUMBER(REPLACE(p_ttexto, ',', k_sistema_numerico_bd));
      END IF;

      RETURN v_nret;
   EXCEPTION
      WHEN OTHERS THEN
         v_nnumerr := 1000150;
         v_tdeserror := 'Error: El valor ' || p_ttexto || ' '
                        || ' no cumple el formato de n¿mero'
                        || '. El separador de decimales es :' || ',';
         RAISE e_errdatos;
   END f_chartonumber;

   /*************************************************************************
                                                                                                                                                                                                                                                                 Funci¿n que da correspondencia valor de la empresa en la interface con axis.
         param in p_tcodigo : c¿digo a buscar
         param in p_tvalemp : c¿digo valor de la empresa
         return : c¿digo valor de axis (nulo si no existe)
    *************************************************************************/
   FUNCTION f_buscavalor(p_tcodigo IN VARCHAR2, p_tvalemp IN VARCHAR2)
      RETURN VARCHAR2 IS
      v_vret         int_codigos_emp.cvalaxis%TYPE;
   BEGIN
      SELECT MAX(cvalaxis)
        INTO v_vret
        FROM int_codigos_emp
       WHERE cempres = k_cempresa
         AND ccodigo = p_tcodigo
         AND cvalemp = p_tvalemp;

      RETURN v_vret;
   END f_buscavalor;

   /*************************************************************************
                          Procedimiento que traspasa de la tabla int_carga_generico_ext a int_carga_generico
          param in   out pdeserror   : mensaje de error
          param in psproces   : N¿mero proceso
    *************************************************************************/
   FUNCTION f_trasp_tabla(pdeserror OUT VARCHAR2, psproces IN NUMBER)
      RETURN NUMBER IS
      v_pasexec      NUMBER := 1;
      vobj           VARCHAR2(200) := 'pac_cargas_generico.f_trasp_tabla';
      v_numlin       int_carga_generico.nlinea%TYPE;
   BEGIN
      v_pasexec := 0;
      pdeserror := NULL;

      SELECT NVL(MAX(nlinea), 0)
        INTO v_numlin
        FROM int_carga_generico
       WHERE proceso = psproces;

      INSERT      /*+ APPEND */INTO int_carga_generico
                  (proceso, nlinea, ncarga, tipo_oper, tiporegistro, campo01, campo02, campo03,
                   campo04, campo05, campo06, campo07, campo08, campo09, campo10, campo11,
                   campo12, campo13, campo14, campo15, campo16, campo17, campo18, campo19,
                   campo20, campo21, campo22, campo23, campo24, campo25, campo26, campo27,
                   campo28, campo29, campo30, campo31, campo32, campo33, campo34, campo35,
                   campo36, campo37, campo38, campo39, campo40, campo41, campo42, campo43,
                   campo44, campo45, campo46, campo47, campo48, campo49, campo50)
         (SELECT psproces proceso, ROWNUM + v_numlin nlinea, NULL ncarga, NULL tipo_oper,
                 UPPER(tiporegistro), campo01, campo02, campo03, campo04, campo05, campo06,
                 campo07, campo08, campo09, campo10, campo11, campo12, campo13, campo14,
                 campo15, campo16, campo17, campo18, campo19, campo20, campo21, campo22,
                 campo23, campo24, campo25, campo26, campo27, campo28, campo29, campo30,
                 campo31, campo32, campo33, campo34, campo35, campo36, campo37, campo38,
                 campo39, campo40, campo41, campo42, campo43, campo44, campo45, campo46,
                 campo47, campo48, campo49, campo50
            FROM int_carga_generico_ext);

      v_pasexec := 1;
      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         pdeserror := f_axis_literales(103187, k_cidioma) || SQLERRM;
         p_tab_error(f_sysdate, f_user, vobj, v_pasexec, SQLCODE, SQLERRM, 10);
         RETURN 1;
   END f_trasp_tabla;

   /**********************************************************************
                       Funci¿n que modifica la tabla ext para cargar un fichero
        param in p_nombre : Nombre fichero
        param in p_path : Nombre Path
        retorna 0 si ha ido bien, sino num_err.
   ***********************************************************************/
   FUNCTION f_modi_tabla_ext(p_nombre VARCHAR2, p_path IN VARCHAR2)
      RETURN NUMBER IS
      v_iteraciones  NUMBER(2);
      /* Cambios de IAXIS-3420 : start*/ 
      v_tnomfich     VARCHAR2(100);
      /* Cambios de IAXIS-3420 : end*/ 
   BEGIN
      v_iteraciones := 1;

      --Cargamos el fichero
      /* Cambios de IAXIS-3420 : start*/ 
      v_tnomfich := SUBSTR(p_nombre, 1, INSTR(p_nombre, '.') - 1);
      /*
      LOOP    
        BEGIN
            LOCK TABLE int_carga_generico_ext IN EXCLUSIVE MODE;

            EXECUTE IMMEDIATE 'ALTER TABLE int_carga_generico_ext LOCATION (' || p_path
                              || ':''' || p_nombre || ''')';
       EXIT;
       EXCEPTION
            WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'pac_cargas_generico.f_modi_tabla_ext',
                           v_iteraciones, 'Error modificando tabla. Reintento.', SQLERRM, 10);
               IF k_iteraciones <= v_iteraciones THEN
                  RAISE;   -- propago excepcion
               END IF;

               sleep(k_segundos);
               v_iteraciones := v_iteraciones + 1;
         END;
      END LOOP;
      LOCK TABLE int_carga_generico_ext IN EXCLUSIVE MODE;
      */
   /* Cambios de IAXIS-3420 : end*/   
   
    EXECUTE IMMEDIATE 'alter table INT_CARGA_GENERICO_EXT ACCESS PARAMETERS (records delimited by 0X''0D0A''
                   logfile '
                        || CHR(39) || v_tnomfich || '.log' || CHR(39)
                        || '
                   badfile ' || CHR(39) || v_tnomfich || '.bad' || CHR(39)
                        || '
                   discardfile ' || CHR(39) || v_tnomfich || '.dis' || CHR(39)
                        || '
    fields terminated by '';'' 
    OPTIONALLY ENCLOSED BY ''"''
    MISSING FIELD VALUES ARE NULL
    REJECT ROWS WITH ALL NULL FIELDS
                   (  tiporegistro, 
                      campo01, 
                      campo02, 
                      campo03, 
                      campo04, 
                      campo05, 
                      campo06, 
                      campo07, 
                      campo08, 
                      campo09, 
                      campo10, 
                      campo11, 
                      campo12, 
                      campo13, 
                      campo14, 
                      campo15, 
                      campo16, 
                      campo17, 
                      campo18, 
                      campo19, 
                      campo20, 
                      campo21, 
                      campo22, 
                      campo23, 
                      campo24, 
                      campo25, 
                      campo26, 
                      campo27, 
                      campo28, 
                      campo29, 
                      campo30, 
                      campo31, 
                      campo32, 
                      campo33, 
                      campo34, 
                      campo35, 
                      campo36, 
                      campo37, 
                      campo38, 
                      campo39, 
                      campo40, 
                      campo41, 
                      campo42, 
                      campo43, 
                      campo44, 
                      campo45, 
                      campo46, 
                      campo47, 
                      campo48, 
                      campo49, 
                      campo50, 
                      campo51, 
                      campo52, 
                      campo53, 
                      campo54, 
                      campo55, 
                      campo56, 
                      campo57, 
                      campo58, 
                      campo59, 
                      campo60
                  ))';

      --Cargamos el fichero
     -- EXECUTE IMMEDIATE 'ALTER TABLE INT_CARGA_GENERICO_EXT LOCATION (''' || p_nombre || ''')';
        EXECUTE IMMEDIATE 'ALTER TABLE INT_CARGA_GENERICO_EXT LOCATION ('|| p_path|| ':''' || p_nombre || ''')';
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_cargas_generico.f_crea_tabla_ext', 1,
                     'Error creando la tabla.', SQLERRM, 10);
         RETURN 103865;
   END f_modi_tabla_ext;

   /***************************************************************************
                                            FUNCTION f_next_carga
       Asigna n¿mero de carga
         return         : N¿mero de carga
   ***************************************************************************/
   FUNCTION f_next_carga
      RETURN NUMBER IS
      v_nseq         NUMBER;
   BEGIN
      SELECT sncarga.NEXTVAL
        INTO v_nseq
        FROM DUAL;

      RETURN v_nseq;
   END f_next_carga;

   /*************************************************************************
                          Funcion que inicializa la primera parte (comun) de un suplemento.
      param p_seg in  : seguro tablas reales
      param p_efe in  : fecha efecto
      param p_mot in  : c¿digo motivo suplemento
      param p_est out : seguro tablas estudio
      param p_mov out : n¿mero movimiento
      param p_des out : descripci¿n en caso de error
      devuelve 0 para correcto o n¿mero error.
      *************************************************************************/
   FUNCTION p_iniciar_suple(
      p_sseguro IN NUMBER,
      p_efecto IN DATE,
      p_cmotmov IN NUMBER,
      p_estseguro OUT NUMBER,
      p_nmovimi OUT NUMBER,
      p_des OUT VARCHAR2)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'pac_cargas_generico.P_INICIAR_SUPLE';
      vtraza         NUMBER;
      cerror         NUMBER;
      errdatos       EXCEPTION;
   BEGIN
      p_des := NULL;
--------------------------------------------------------------------------
-- iniciar suple
--------------------------------------------------------------------------
      vtraza := 1060;
      cerror := pk_suplementos.f_permite_suplementos(p_sseguro, p_efecto, p_cmotmov);

      IF cerror <> 0 THEN
         p_des := 'permite suplemento (s=' || p_sseguro || ' e=' || p_efecto || ' m='
                  || p_cmotmov || ')' || ' ' || f_axis_literales(cerror, k_cidioma);

         IF cerror = 103308 THEN
            p_des := p_des || '.Editar linea, modificar fecha suplemento y reprocesar linea';
         END IF;

         RAISE errdatos;
      END IF;

      vtraza := 1061;
      vtraza := 1062;
      p_estseguro := NULL;
      cerror := pk_suplementos.f_inicializar_suplemento(p_sseguro, 'SUPLEMENTO', p_efecto,
                                                        'BBDD', '*', p_cmotmov, p_estseguro,
                                                        p_nmovimi);

      IF cerror <> 0 THEN
         p_des := 'inicializar suplemento (s=' || p_sseguro || ' e=' || p_efecto || ' m='
                  || p_cmotmov || ')' || ' ' || f_axis_literales(cerror, k_cidioma);
         RAISE errdatos;
      END IF;

      BEGIN
         DELETE      pds_estsegurosupl
               WHERE sseguro = p_estseguro
                 AND nmovimi = p_nmovimi
                 AND cmotmov = p_cmotmov;

         -- lo borro y lo vuelvo a insertar como no realizado.
         INSERT INTO pds_estsegurosupl
                     (sseguro, nmovimi, cmotmov, fsuplem, cestado)
              VALUES (p_estseguro, p_nmovimi, p_cmotmov, p_efecto, 'X');
      --          p_tab_error(f_sysdate, f_user, 'pac_cargas_generico.p_iniciar_suple', 1,
      --                       'PDS_ESTSEGUROSUPL', 'p_estseguro:'||p_estseguro||'- p_nmovimi:'||p_nmovimi||'- cmotmov:'||p_cmotmov||'- efecto:' ||p_efecto);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            NULL;   --si ya existe es que est¿n haciendo m¿s suplementos
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'pac_cargas_generico', 1,
                        'Error insertando en pds_estsegurosupl.p_iniciar_suple', SQLERRM, 10);
      END;

      RETURN 0;
   EXCEPTION
      WHEN errdatos THEN
         RETURN cerror;
   END p_iniciar_suple;

   /*************************************************************************
   Funcion que finaliza la parte final (comun) de un suplemento.
      param p_est out : seguro tablas estudio
      param p_mov out : n¿mero movimiento
      param p_seg in  : seguro tablas reales
      param p_des out : descripci¿n en caso de error
      devuelve 0 para correcto o n¿mero error.
      *************************************************************************/
   FUNCTION p_finalizar_suple(
      p_ncarga IN NUMBER,
      p_estseguro IN NUMBER,
      p_nmovimi IN NUMBER,
      p_sseguro IN NUMBER,
      p_des OUT VARCHAR2,
      --                              p_cmotmov IN number,
      pproceso IN NUMBER   --,
                        --                              pfsuplem IN date
   )
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'pac_cargas_generico.P_FINALIZAR_SUPLE';
      vtraza         NUMBER;
      cerror         NUMBER;
      e_nosuple      EXCEPTION;
      errdatos       EXCEPTION;
      n_aux          NUMBER;
      indice         NUMBER;
      indice_e       NUMBER;
      indice_t       NUMBER;
      --   r_seg          seguros%ROWTYPE;
      mensajes       t_iax_mensajes;
      vsproduc       seguros.sproduc%TYPE;
      v_fsuplem      DATE;
      v_sseguro_est  estseguros.sseguro%TYPE := p_estseguro;
   BEGIN
      p_des := NULL;
      vtraza := 1090;
      cerror := pk_suplementos.f_fecha_efecto(p_estseguro, p_nmovimi, v_fsuplem);

      IF cerror <> 0 THEN
         RETURN cerror;
      END IF;

      SELECT sproduc
        INTO vsproduc
        FROM seguros
       WHERE sseguro = p_sseguro;

      v_sseguro_est := p_estseguro;
      cerror := pac_mig_axis.f_lanza_post(p_ncarga, 'EST', v_sseguro_est, vsproduc, v_fsuplem,
                                          p_nmovimi, p_des);

      IF cerror <> 0 THEN
         --  cerror := 151237;
         -- p_des := 'error emision ' || NVL(f_axis_literales(indice_e, k_cidioma), indice_e);
         RAISE errdatos;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_nosuple THEN
         RETURN -2;   -- Warning
      WHEN errdatos THEN
         RETURN cerror;
   END p_finalizar_suple;

   FUNCTION f_marcar_lineas(
      psproces IN NUMBER,
      pncarga IN NUMBER,
      pcestado IN NUMBER,
      ptoperacion IN VARCHAR2,
      pnumerr IN NUMBER,
      pdeserror IN VARCHAR2,
      psseguro IN NUMBER,
      pnlinea IN NUMBER,
      pnrecibo IN NUMBER,
      pnsiniestro IN NUMBER,
      psperson IN NUMBER)
      RETURN NUMBER IS
      nnumerr        NUMBER := 0;
      vvalidado      int_carga_ctrl_linea.cvalidado%TYPE;
   BEGIN
      SELECT DECODE(pcestado, 2, 1, 4, 1, 0)
        INTO vvalidado
        FROM DUAL;

      --
      FOR c_lin IN (SELECT nlinea, idint, idext
                      FROM int_carga_ctrl_linea
                     WHERE sproces = psproces
                       AND ncarga = pncarga) LOOP
         IF NVL(pnlinea, c_lin.nlinea) = c_lin.nlinea THEN
            nnumerr := p_marcalinea(psproces, c_lin.nlinea, ptoperacion, pcestado, vvalidado,
                                    psseguro, c_lin.idext, pncarga, pnsiniestro, NULL,
                                    psperson, pnrecibo, c_lin.idint);
         ELSE
            nnumerr := p_marcalinea(psproces, c_lin.nlinea, ptoperacion, 3, 0, psseguro,
                                    c_lin.idext, pncarga, NULL, NULL, NULL, NULL, c_lin.idint);   -- las otras las dejo como pendientes
         END IF;

         IF nnumerr <> 0 THEN
            RAISE e_errdatos;
         END IF;

         IF pdeserror IS NOT NULL
            AND NVL(pnlinea, c_lin.nlinea) = c_lin.nlinea THEN
            nnumerr := p_marcalineaerror(psproces, c_lin.nlinea, NULL, 1, pnumerr, pdeserror);

            IF nnumerr <> 0 THEN
               RAISE e_errdatos;
            END IF;
         END IF;
      END LOOP;

      RETURN nnumerr;
   EXCEPTION
      WHEN e_errdatos THEN
         ROLLBACK;
         RETURN nnumerr;
      WHEN OTHERS THEN
         RETURN SQLCODE;
   END;

   /*************************************************************************
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            Procedimiento que genera anulaci¿n de p¿liza
          param in x : registro tipo INT_POLIZAS_GENERICO
          param p_deserror out: Descripci¿n del error si existe.
          Devuelve TIPOERROR ( 1-Ha habido error, 2-Es un warning, 4-Ha ido bien, x-Error incontrolado).
          --
          Para modificar una p¿liza, los siguientes campos son obligatorios:
          - p¿liza
          - certificado
          - identificador personas
          - fecha efecto de la operaci¿n
          --
      *************************************************************************/
   FUNCTION f_baja_poliza(
      psproces IN NUMBER,
      pncarga IN NUMBER,
      pnlinea IN NUMBER,
      pctipanul IN NUMBER,
      pbaja IN DATE,
      p_sseguro IN NUMBER,
      p_id IN VARCHAR2,
      p_toperacion IN VARCHAR2,
      p_deserror IN OUT VARCHAR2,
      pcmotmov IN NUMBER DEFAULT NULL,
      precextrn IN NUMBER DEFAULT 1,
      panula_rec IN NUMBER DEFAULT 1)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'pac_cargas_generico.F_BAJA_POLIZA';
      vtraza         NUMBER;
      cerror         NUMBER;
      errdatos       EXCEPTION;
      b_warning      BOOLEAN;
      n_age          seguros.cagente%TYPE;
      vsproduc       seguros.sproduc%TYPE;
      vcactivi       seguros.sproduc%TYPE;
      v_des1         VARCHAR2(100);
      v_des2         VARCHAR2(100);
      w_csituac      NUMBER;
      wnpoliza       NUMBER;
      whaywarnings   NUMBER := 0;
      mensajes       t_iax_mensajes;
      v_ctipoanul    NUMBER(1);
      vrecibos       VARCHAR2(2000);
      vnrecibo       recibos.nrecibo%TYPE;
      vfefecto       DATE;
      vfvencim       DATE;
      vfmovini       DATE;
      vmarcado       NUMBER;
      vtagente       VARCHAR2(200);
      vttiprec       VARCHAR2(200);
      vitotalr       NUMBER;
      vcur           sys_refcursor;
   BEGIN
      vtraza := 1000;
      cerror := 0;
      p_deserror := NULL;
      b_warning := FALSE;
------------------------------------
-- VALIDAR CAMPOS CLAVE: Persona. --
------------------------------------
      vtraza := 1010;

      BEGIN
         SELECT cagente, csituac, npoliza, cactivi
           INTO n_age, w_csituac, wnpoliza, vcactivi
           FROM seguros
          WHERE sseguro = p_sseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            p_deserror := 'N¿mero p¿liza no existe: ';
            cerror := 100500;
            RAISE errdatos;
      END;

      vtraza := 1040;

      IF pbaja IS NULL THEN
         p_deserror := 'Fecha baja no es fecha: ' || pbaja || ' (dd/mm/yyyy)';
         p_deserror := p_deserror
                       || '. Editar linea, modificar fecha baja (campo04) y reprocesar';
         cerror := 102853;
         RAISE errdatos;
      END IF;

      vtraza := 1050;
      --    v_des2 := '';

      --   SELECT tmotmov
      --     INTO v_des1
      --     FROM motmovseg
      --    WHERE cmotmov = NVL(pcmotmov, pctipanul)
      --      AND cidioma = k_cidioma;

      --   vtraza := 1080;
      --    cerror := pac_agensegu.f_set_datosapunte(NULL, p_sseguro, NULL, v_des1,
        --                                           f_axis_literales(100811, k_cidioma) || ' '
          --                                         || v_des1 || CHR(13) || CHR(13) || v_des2,
            --                                       6, 1, f_sysdate, f_sysdate, 0, 0);

      -- IF cerror <> 0 THEN
      --    b_warning := TRUE;
      --    p_genera_logs(vobj, vtraza, 'Agenda', 'c¿digo ' || cerror);
      --    cerror := 0;
      -- END IF;
      vtraza := 1090;

      -- Bug 0016324. FAL. 18/10/2010
      IF w_csituac <> 0 THEN   -- No permita anular poliza si ya lo est¿
         p_deserror := 'La p¿liza ' || p_id || ' no esta vigente';
         cerror := 101483;
         RAISE errdatos;
      ELSE
         vtraza := 1100;

         IF pctipanul = 306 THEN
            v_ctipoanul := 1;
         ELSIF pctipanul = 236 THEN
            v_ctipoanul := 2;
         ELSIF pctipanul = 221 THEN
            v_ctipoanul := 3;
         ELSIF pctipanul = 444 THEN   --JAMF   33921   22/01/2015
            v_ctipoanul := 5;
         ELSE   -- 324 -- anulacion immediata
            v_ctipoanul := 4;
         END IF;

         -- Fi Bug 0016324
         vtraza := 1102;

          -- informo los recibos
-- pendientes
         IF NVL(panula_rec, 1) = 1 THEN   -- si tengo que anular recibos cojo los pendientes
            vcur := pac_anulacion.f_recibos(p_sseguro, pbaja, 0, k_cidioma, cerror);
            vtraza := 1103;

            FETCH vcur
             INTO vnrecibo, vfefecto, vfvencim, vfmovini, vmarcado, vtagente, vttiprec,
                  vitotalr;

            vtraza := 1104;

            IF vnrecibo IS NOT NULL THEN
               vrecibos := vnrecibo;
            END IF;

            vtraza := 1105;

            WHILE vcur%FOUND LOOP
               FETCH vcur
                INTO vnrecibo, vfefecto, vfvencim, vfmovini, vmarcado, vtagente, vttiprec,
                     vitotalr;

               IF vnrecibo IS NOT NULL THEN
                  vrecibos := vrecibos || ',' || vnrecibo;
               END IF;
            END LOOP;
         END IF;

         vtraza := 1106;
-- cobrados
/*
         vcur := pac_anulacion.f_recibos(p_sseguro, pbaja, 1, k_cidioma, cerror);
         vtraza := 1107;

         FETCH vcur
          INTO vnrecibo, vfefecto, vfvencim, vfmovini, vmarcado, vtagente, vttiprec, vitotalr;

         IF vnrecibo IS NOT NULL THEN
            IF vrecibos IS NOT NULL THEN
               vrecibos := vrecibos || ',' || vnrecibo;
            ELSE
               vrecibos := vnrecibo;
            END IF;
         END IF;

         WHILE vcur%FOUND LOOP
            FETCH vcur
             INTO vnrecibo, vfefecto, vfvencim, vfmovini, vmarcado, vtagente, vttiprec,
                  vitotalr;

            IF vnrecibo IS NOT NULL THEN
               vrecibos := vrecibos || ',' || vnrecibo;
            END IF;
         END LOOP;
*/
         cerror :=
            pac_iax_anulaciones.f_anulacion(p_sseguro, v_ctipoanul,   --pctipanul IN NUMBER,
                                            pbaja,   -- pfanulac IN DATE,
                                            pctipanul,   -- pccauanul IN NUMBER,
                                            'Anulaci¿n por carga',   -- pmotanula IN VARCHAR2,
                                            NVL(precextrn, 1),   -- precextrn IN NUMBER,
                                            NVL(panula_rec, 1),   -- panula_rec IN NUMBER,
                                            vrecibos,   --recibos
                                            0,   --paplica_penali IN NUMBER,
                                            mensajes,   --    mensajes OUT t_iax_mensajes,
                                            0   -- pimpextorsion IN NUMBER DEFAULT 0
                                             );
      END IF;

      IF cerror = 0 THEN
         cerror := f_marcar_lineas(psproces, pncarga, 4,   -- pongo ok
                                   p_toperacion, cerror, NULL, p_sseguro, NULL, NULL, NULL,
                                   NULL);

         IF cerror <> 0 THEN
            RAISE errdatos;
         END IF;

         cerror := 4;
      ELSE
         IF mensajes IS NOT NULL THEN
            FOR i IN mensajes.FIRST .. mensajes.LAST LOOP
               p_deserror := mensajes(i).terror;
               cerror := mensajes(i).cerror;
            END LOOP;
         END IF;

         RAISE errdatos;
      END IF;

      RETURN cerror;
   EXCEPTION
      WHEN errdatos THEN
         ROLLBACK;
          --  cerror := p_marcalinea(psproces, pnlinea, p_toperacion, 1, 0, NULL, p_id, pncarga);
          -- cerror := p_marcalineaerror(psproces, pnlinea, NULL, 1, cerror, p_deserror);
         -- cerror := f_marcar_lineas(psproces, pncarga, 1,   -- pongo ok
          --                          p_toperacion, cerror, p_deserror, NULL, NULL);
         RETURN 1;   -- Error
      WHEN OTHERS THEN
         ROLLBACK;
         p_deserror := '(traza=' || vtraza || ') ' || SQLERRM;
         --  cerror     := p_marcalinea(psproces, pnlinea, p_toperacion, 1, 0, NULL, p_id,
         --                            pncarga);
         --cerror     := p_marcalineaerror(psproces, pnlinea, NULL, 1, SQLCODE, p_deserror);
         cerror := f_marcar_lineas(psproces, pncarga, 1,   -- pongo ok
                                   p_toperacion, SQLCODE, p_deserror, NULL, NULL, NULL, NULL,
                                   NULL);
         -- Fi Bug 16324
         RETURN 1;   -- Error incontrolado
   END f_baja_poliza;

   /*************************************************************************
       Procedimiento que ejecuta una carga.
       param in p_ssproces   : N¿mero proceso
       retorna 0 si ha ido bien, 1 en casos contrario
   *************************************************************************/
   FUNCTION f_pol_ejecutar_carga_proceso(p_ssproces IN NUMBER)
      RETURN NUMBER IS
      v_tobjeto      VARCHAR2(100) := 'pac_cargas_generico.f_pol_ejecutar_carga_proceso';
      v_ntraza       NUMBER := 0;
      e_salir        EXCEPTION;

      CURSOR cur_polizas(p_ssproces2 IN NUMBER) IS
         -- Abrimos los certificados como control, despu¿s buscamos todos los registros del fichero.
         SELECT   a.*
             FROM int_carga_generico a
            WHERE proceso = p_ssproces2
              AND NOT EXISTS(SELECT 1
                               FROM int_carga_ctrl_linea b
                              WHERE b.sproces = a.proceso
                                AND b.nlinea = a.nlinea
                                AND b.cestado IN(2, 4, 5, 6))
         ORDER BY nlinea, tiporegistro;   -- registro tipo certificado

      v_toperacion   VARCHAR2(20);
      v_berrorproc   BOOLEAN := FALSE;
      v_bavisproc    BOOLEAN := FALSE;
      v_ncarga       int_carga_generico.ncarga%TYPE;
      v_ncarga2      int_carga_generico.ncarga%TYPE;
      v_ntipoerror   NUMBER := 0;
      --  v_nnumerrset   number;
      v_tfichero     int_carga_ctrl.tfichero%TYPE;
      --Tablas nivel p¿liza
      reg_migpersonas mig_personas%ROWTYPE;
      reg_migregimenfiscal mig_regimenfiscal%ROWTYPE;
      reg_migseg     mig_seguros%ROWTYPE;
      reg_migmovseg  mig_movseguro%ROWTYPE;
      reg_migase     mig_asegurados%ROWTYPE;
      reg_migdirec   mig_direcciones%ROWTYPE;
      reg_migrie     mig_riesgos%ROWTYPE;
      reg_migdetrie  mig_detalle_riesgos%ROWTYPE;
      reg_miggar     mig_garanseg%ROWTYPE;
      -- ini rllf 22092015 a¿adir mig_garanseg y mig_pbext
      reg_miggardet  mig_detgaranseg%ROWTYPE;
      reg_migpbex    mig_pbex%ROWTYPE;
      vprocespb      NUMBER;
      -- fin rllf rll 22092015 a¿adir mig_garanseg y mig_pbext
      reg_migbenespseg mig_benespseg%ROWTYPE;
      reg_migpre     mig_pregunseg%ROWTYPE;
      reg_migpreggaran mig_pregungaranseg%ROWTYPE;
      reg_migpregtab mig_pregunsegtab%ROWTYPE;
      reg_migrenaho  mig_seguros_ren_aho%ROWTYPE;
      reg_comisionsegu mig_comisionsegu%ROWTYPE;
      reg_migagecorretaje mig_age_corretaje%ROWTYPE;
      reg_migagensegu mig_agensegu%ROWTYPE;
      reg_migclausuesp mig_clausuesp%ROWTYPE;
      reg_migcoacuadro mig_coacuadro%ROWTYPE;
      reg_migcoacedido mig_coacedido%ROWTYPE;
      reg_migctaseguro mig_ctaseguro%ROWTYPE;
      -- ini rllf 05102015 a¿adir mig_reemplazos.
      reg_migreemplazos mig_reemplazos%ROWTYPE;
      -- fin rllf 05102015 a¿adir mig_reemplazos.
      v_rowid        ROWID;
      v_id           mig_cargas.ID%TYPE;
      v_id_linea     int_carga_generico.nlinea%TYPE;
      v_sperson      per_personas.sperson%TYPE;
      v_cramo        productos.cramo%TYPE;
      v_cmodali      productos.cmodali%TYPE;
      v_ctipseg      productos.ctipseg%TYPE;
      v_ccolect      productos.ccolect%TYPE;
      v_cnivel       pregunpro.cnivel%TYPE;
      v_ctippre      codipregun.ctippre%TYPE;
      v_cmovseg      codimotmov.cmovseg%TYPE;
      v_sseguro      seguros.sseguro%TYPE;
      v_sseguro0     seguros.sseguro%TYPE;
      v_cagente      seguros.cagente%TYPE;
      v_csituac      seguros.csituac%TYPE;
      v_fefecto0     seguros.fefecto%TYPE;
      v_fefecto      seguros.fefecto%TYPE;
      v_fcarpro      seguros.fcarpro%TYPE;
      -- ini rllf 22092015 a¿adir mig_garanseg y mig_pbext
      v_cramdgs      productos.cramdgs%TYPE;
      -- fin rllf 22092015 a¿adir mig_garanseg y mig_pbext
      --
      v_nmovimi      movseguro.nmovimi%TYPE;
      v_sseguroest   estseguros.sseguro%TYPE;
      v_fsuplemento  movseguro.fefecto%TYPE;
      v_garanpro     garanpro%ROWTYPE;
      wspersonnueva  estper_personas.sperson%TYPE;
      wspersonnueva_cont estper_personas.sperson%TYPE;
      v_ctipben      estbenespseg.ctipben%TYPE;
      v_norden       NUMBER;
      v_cmotmov_965  movseguro.cmotmov%TYPE;
      mensajes       t_iax_mensajes;
      v_sproces      NUMBER;
      vpparticip     benespseg.pparticip%TYPE;
      --
      --vfanulac date;
      --vfefecto date;
      vfiniefe       DATE;
      vffinefe       DATE;
      vfiniben       DATE;
      vffinben       DATE;
      vffecini       DATE;
      vffecfin       DATE;
      vedadmin       NUMBER(6);
      --
      vicapital      garanseg.icapital%TYPE;
      viprianu       garanseg.iprianu%TYPE;
      viextrap       garanseg.iextrap%TYPE;
      virecarg       garanseg.irecarg%TYPE;
      vidtocom       garanseg.idtocom%TYPE;
      --
      v_cforpag0     seguros.cforpag%TYPE;
      -- Bug 27539 - 09/09/2013 - RSC
      v_crecfra0     seguros.crecfra%TYPE;
      v_recfra       seguros.crecfra%TYPE;
      -- Fin bug 27539
      v_cforpag      prodherencia_colect.cforpag%TYPE;
      v_ccompani0    seguros.ccompani%TYPE;
      v_hccompani    prodherencia_colect.ccompani%TYPE;
      -- 26050 guardo las p¿lizas que tengo que bloquear y su situaci¿n
      vsseguroscargados VARCHAR2(2000) := '-1';
-- reglas pata optimizador
      v_admite_certificados parproductos.cvalpar%TYPE;
      v_sproduc      productos.sproduc%TYPE;
      v_ccompani     productos.ccompani%TYPE;
      v_crevali      productos.crevali%TYPE;
      v_prevali      productos.prevali%TYPE;
      v_irevali      productos.irevali%TYPE;
      v_crecfra      productos.crecfra%TYPE;
--      v_npoliza      seguros.npoliza%TYPE;
      v_cmotmov      movseguro.cmotmov%TYPE;
      v_creteni      seguros.creteni%TYPE;
      --
      v_npolizanuevocert0 seguros.npoliza%TYPE;
      --
      v_nmovima      movseguro.nmovimi%TYPE;
      --
      v_numriesgos   mig_riesgos.nriesgo%TYPE;
      -- ini rllf 05/10/2015 migraci¿n de reemplazos
      vsegreempl     mig_seguros.sseguro%TYPE;
      vremplefecto   mig_seguros.fefecto%TYPE;
      -- fin rllf 05/10/2015 migraci¿n de reemplazos
      v_aseg_no_riesgo NUMBER := 0;   -- BUG 0035223 20151001 MMS
      v_dup_aseg_pol VARCHAR2(1) := 'N';   -- BUG 0035223 20151001 MMS
      v_no_val_aseg_pol VARCHAR2(1) := 'N';   -- BUG 0035223 20150121 MMS

      /***************************************************************************
       FUNCTION f_lanza_migracion
           Asigna n¿mero de carga
           Return: N¿mero de carga
       ***************************************************************************/
      FUNCTION f_lanza_migracion(p_id IN VARCHAR2, p_ncarga IN NUMBER)
         RETURN NUMBER IS
         v_ntiperr      NUMBER := 0;
         v_sseg         seguros.sseguro%TYPE;
         v_nmov         movseguro.nmovimi%TYPE;
         v_csituac      seguros.csituac%TYPE;
         v_continuaemtir NUMBER;
      BEGIN
         IF k_tablas <> 'MIG' THEN
            pac_mig_axis.p_migra_cargas(p_id, 'C', p_ncarga, 'DEL', k_tablas);
         ELSE
            pac_mig_axis.p_migra_cargas(p_id, 'C', p_ncarga, 'DEL', k_tablas, 'MIGRACION');
         END IF;

         --Cargamos las SEG para la p¿liza (ncarga)
         FOR reg IN (SELECT *
                       FROM mig_logs_axis
                      WHERE ncarga = p_ncarga
                        AND tipo = 'E'
                        AND ROWNUM <= 10) LOOP
            --Miramos si ha habido alg¿n error y lo informamos.
            v_ntraza := 200;
            v_nnumerr := f_marcar_lineas(p_ssproces, p_ncarga, 1,   -- pongo errr todas las lineas
                                         v_toperacion, 151840, reg.incid, NULL, NULL, NULL,
                                         NULL, NULL);
            v_berrorproc := TRUE;
            v_ntiperr := 1;
         END LOOP;

         IF v_ntiperr = 0 THEN
            FOR reg IN (SELECT *
                          FROM mig_logs_axis
                         WHERE ncarga = p_ncarga
                           AND tipo = 'W'
                           AND ROWNUM <= 10) LOOP   --Miramos si han habido warnings.
               v_ntraza := 202;

               BEGIN
                  SELECT sseguro
                    INTO v_sseg
                    FROM mig_seguros
                   WHERE ncarga = p_ncarga;
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;   --JRH IMP de momento
               END;

               v_nnumerr := f_marcar_lineas(p_ssproces, p_ncarga, 2,   -- pongo errr todas las lineas
                                            v_toperacion, 700145, reg.incid, v_sseg, NULL,
                                            NULL, NULL, NULL);
               v_bavisproc := TRUE;
               v_ntiperr := 2;
            END LOOP;
         END IF;

         IF v_ntiperr = 0 THEN
            --Esto quiere decir que no ha habido ning¿n error (lo indicamos tambi¿n).
            v_ntraza := 204;

            BEGIN
               SELECT sseguro
                 INTO v_sseg
                 FROM mig_seguros
                WHERE ncarga = p_ncarga;
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;   --JRH IMP de momento
            END;

            FOR c_lin IN (SELECT nlinea, idint
                            FROM int_carga_ctrl_linea
                           WHERE sproces = p_ssproces
                             AND ncarga = p_ncarga) LOOP
               v_nnumerr := p_marcalinea(p_ssproces, c_lin.nlinea, v_toperacion, 4, 1, v_sseg,
                                         p_id, p_ncarga, NULL, NULL, NULL, NULL, c_lin.idint);

               IF v_nnumerr <> 0 THEN
                  --Si fallan estas funciones de gesti¿n salimos del programa
                  v_tdeserror := 'Falta marcar linea 4: ' || p_ssproces || '/' || p_id;
                  RAISE e_errdatos;
               END IF;
            END LOOP;

            v_ntiperr := 4;
         END IF;

         IF pac_iax_produccion.isaltacol
            AND v_sseg IS NOT NULL
            AND v_ntiperr IN(2, 4) THEN
            --devuelvo el n¿mero de p¿liza del certificado 0 creado
                         --
            SELECT npoliza
              INTO v_npolizanuevocert0
              FROM seguros
             WHERE sseguro = v_sseg;
         --
         END IF;

         -- Lanzo validaciones  si ha la poliza esta migrada
         RETURN v_ntiperr;   --Devolvemos el tipo error que ha habido
      EXCEPTION
         WHEN e_errdatos THEN
            ROLLBACK;
             -- v_nnumerr1 := p_marcalinea(p_ssproces, v_id_linea, v_toperacion, 1, 0, NULL, p_id,
            --                             p_ncarga);
             -- v_nnumerr := p_marcalineaerror(p_ssproces, v_id_linea, NULL, 1, NVL(v_nnumerr, 1),
             --                                NVL(v_tdeserror, -1));
            v_ntraza := 2043;
            v_nnumerr := f_marcar_lineas(p_ssproces, p_ncarga, 2,   -- pongo errr todas las lineas
                                         v_toperacion, NVL(v_nnumerr, 1), NVL(v_tdeserror, -1),
                                         v_sseg, NULL, NULL, NULL, NULL);
            --COMMIT;
            RETURN v_nnumerr;
         WHEN OTHERS THEN
            v_nnumerr := SQLCODE;
            v_tdeserror := v_ntraza || ' en f_lanza_migracion: ' || SQLERRM;
            ROLLBACK;
            v_nnumerr1 := p_marcalinea(p_ssproces, v_id_linea, v_toperacion, 1, 0, NULL, p_id,
                                       p_ncarga);
            v_nnumerr := p_marcalineaerror(p_ssproces, v_id_linea, NULL, 1, v_nnumerr,
                                           v_tdeserror);
            RETURN SQLCODE;
      END f_lanza_migracion;
   BEGIN
      v_ntraza := 0;

      IF p_ssproces IS NULL THEN
         v_nnumerr := 9000505;
         v_tdeserror := 'Par¿metro p_ssproces obligatorio.';
         p_genera_logs(v_tobjeto, v_ntraza, 'Error:' || v_nnumerr, v_tdeserror);
         RAISE e_salir;
      END IF;

      v_ntraza := 1;
      v_toperacion := NULL;

      FOR x IN cur_polizas(p_ssproces) LOOP
         BEGIN
            --Leemos los registros de la tabla int no procesados OK
            v_ntraza := 3;

            IF x.tiporegistro <> '1' THEN
               v_nnumerr := p_marcalinea(x.proceso, x.nlinea, NULL, 3, 0, NULL, v_id,
                                         v_ncarga, NULL, NULL, NULL, NULL,
                                         x.nlinea || '(' || x.tiporegistro || ')');
               v_id_linea := x.nlinea;
            END IF;

            -- REGISTRO 01-- Cabecera
            IF x.tiporegistro = '1' THEN   -- cabecera
               -- si salto de registro migro el anterior
               IF v_id IS NOT NULL
                  AND v_ntipoerror NOT IN(1, 4) THEN
                  --pac_mig_axis.p_migra_cargas(v_id, 'C', v_ncarga, 'DEL');
                  IF v_toperacion = 'ALTA' THEN
                     v_nnumerr := f_lanza_migracion(v_id, v_ncarga);
                  ELSIF v_toperacion = 'MODI' THEN
                     v_nnumerr := p_finalizar_suple(v_ncarga, v_sseguroest, v_nmovimi,
                                                    v_sseguro, v_tdeserror, p_ssproces);

                     -- tengo que grabar el resultado
                     IF v_nnumerr <> 0 THEN
                        ROLLBACK;
                        v_berrorproc := TRUE;
                        v_nnumerr := f_marcar_lineas(p_ssproces, v_ncarga, 1,   -- pongo error
                                                     v_toperacion, v_nnumerr, v_tdeserror,
                                                     NULL, NULL, NULL, NULL, NULL);
                     ELSE
                        v_nnumerr := f_marcar_lineas(p_ssproces, v_ncarga, 4,   -- pongo ok
                                                     v_toperacion, v_nnumerr, NULL, v_sseguro,
                                                     NULL, NULL, NULL, NULL);
                     END IF;
                  END IF;

                  IF v_nnumerr NOT IN(0, 2, 4) THEN   -- si ha habido error
                     ROLLBACK;

                     IF k_cpara_error <> 1 THEN
                        v_ntipoerror := 4;
                     -- para que continue con la siguiente linea.
                     ELSE
                        v_ntipoerror := 1;   -- para la carga
                        RAISE e_salir;
                     END IF;
                  ELSE
                     COMMIT;
                  END IF;
               END IF;

               -- I - 30428
               IF NVL(x.campo25, 0) = 1 THEN   -- si es colectivo
                  pac_iax_produccion.isaltacol := TRUE;
                  v_npolizanuevocert0 := NULL;   -- borro el posible anterior colectivo
               ELSE
                  pac_iax_produccion.isaltacol := FALSE;
               END IF;

               pac_iax_produccion.issimul := FALSE;
               reg_migseg := NULL;
               v_cagente := NULL;
               v_fefecto := NULL;
               v_fefecto0 := NULL;
               v_sseguro0 := NULL;
               v_nmovimi := NULL;
               reg_migmovseg := NULL;
               reg_migpersonas := NULL;
               reg_migregimenfiscal := NULL;
               reg_migase := NULL;
               reg_migrie := NULL;   ---
               reg_migbenespseg := NULL;
               reg_miggar := NULL;
               -- ini rll 22092015 a¿adir mig_garanseg y mig_pbex
               reg_miggardet := NULL;
               -- fin rllf rll 22092015 a¿adir mig_garanseg y mig_pbex
               reg_migpre := NULL;
               v_sseguroest := NULL;
               v_toperacion := NULL;
               v_ntipoerror := 0;
               v_ncarga := f_next_carga;
               v_id_linea := x.nlinea;

               --Inicializamos la clinea
               IF v_npolizanuevocert0 IS NOT NULL
                  AND x.campo03 IS NULL THEN
                  x.campo03 := v_npolizanuevocert0;

                  -- actualizo la tabla para que si hay error reprocese los registro con la nueva poliza
                  UPDATE int_carga_generico
                     SET campo03 = v_npolizanuevocert0
                   WHERE proceso = x.proceso
                     AND nlinea = x.nlinea;
               END IF;

               v_id := NVL(TRIM(x.campo03), v_ncarga) || '-' || x.campo04;
               -- para gabar el v_ncarga_y el v_id
               v_nnumerr := p_marcalinea(x.proceso, x.nlinea, NULL, 3, 0, NULL, v_id, v_ncarga,
                                         NULL, NULL, NULL, NULL,
                                         x.nlinea || '(' || x.tiporegistro || ')');
               --reg_migseg.sproduc := f_buscavalor('GEN_PRODUCTO', x.campo02);
               reg_migseg.sproduc := x.campo02;
               v_admite_certificados :=
                  NVL(pac_parametros.f_parproducto_n(reg_migseg.sproduc, 'ADMITE_CERTIFICADOS'),
                      0);
               vedadmin := NVL(f_parproductos_v(reg_migseg.sproduc, 'EDADMINTOM'), 0);

               -- Miro si vengo de un colectivo que he cargado previamente..
               IF reg_migseg.sproduc IS NULL THEN
                  --Inicializamos la clinea
                  v_nnumerr := p_marcalinea(x.proceso, x.nlinea, NULL, 3, 0, NULL, v_id,
                                            v_ncarga, NULL, NULL, NULL, NULL,
                                            x.nlinea || '(' || x.tiporegistro || ')');
                  v_tdeserror := ' C¿digo producto no definido: ' || x.campo02;
                  v_nnumerr := 104347;
                  RAISE e_errdatos;
               END IF;

               -- I - 30428
               IF k_tablas = 'MIG'
                  OR pac_iax_produccion.isaltacol THEN
                  v_toperacion := 'ALTA';

                  INSERT INTO mig_cargas
                              (ncarga, cempres, finiorg, ffinorg, ID, estorg)
                       VALUES (v_ncarga, k_cempresa, f_sysdate, f_sysdate, v_id, NULL);
               ELSIF (TRIM(x.campo03) IS NULL
                      AND v_admite_certificados = 0)
                     OR (TRIM(x.campo03) IS NOT NULL
                         AND TRIM(x.campo04) IS NULL
                         AND TRIM(x.campo16) IS NULL
                         AND TRIM(x.campo17) IS NULL
                         AND v_admite_certificados = 1)
                        AND(TRIM(x.campo05) IS NULL) THEN
                  v_toperacion := 'ALTA';

                  INSERT INTO mig_cargas
                              (ncarga, cempres, finiorg, ffinorg, ID, estorg)
                       VALUES (v_ncarga, k_cempresa, f_sysdate, f_sysdate, v_id, NULL);
               ELSIF (TRIM(x.campo03) IS NOT NULL
                      AND v_admite_certificados = 0)
                     OR(TRIM(x.campo03) IS NOT NULL
                        AND TRIM(x.campo04) IS NOT NULL
                        AND v_admite_certificados = 1) THEN
                  v_toperacion := 'MODI';
               ELSIF v_admite_certificados = 1
                     AND TRIM(x.campo03) IS NOT NULL
                     AND TRIM(x.campo04) IS NULL
                     AND TRIM(x.campo16) IS NOT NULL
                     AND TRIM(x.campo17) IS NOT NULL THEN
                  -- Si me llega el certificado 0 a nulo miro si me llega el asegurado
                    -- busco el certificado para ese producto/poliza, y que tenga ese asegurado
                  v_toperacion := 'MODI';

                  BEGIN
                     SELECT ncertif
                       INTO x.campo04   -- lo grabo en el certificado
                       FROM seguros seg, asegurados aseg
                      WHERE npoliza = TRIM(x.campo03)
                        AND sproduc = reg_migseg.sproduc
                        AND ncertif <> 0
                        AND(csituac <>
                               2   -- que no este anulada, si esta anulada pod¿ria ser una anulaci¿n
                            AND csituac <> 3
                            AND NOT(csituac = 4
                                    AND creteni = 3)
                            AND NOT(csituac = 4
                                    AND creteni = 4))
                        AND seg.sseguro = aseg.sseguro
                        AND sperson IN(SELECT sperson
                                         FROM per_personas
                                        WHERE ctipide = TRIM(x.campo16)
                                          AND nnumide = TRIM(x.campo17));
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        --   v_tdeserror :=
                        --      'No se ha encontrado certificado para la poliza y asegurado indicado -->'
                        --      || x.campo03 || ' - ' || x.campo16;
                        --   v_nnumerr := 9001114;
                         --   RAISE e_errdatos;
                        v_toperacion := 'ALTA';

                        -- no la encuentro la trato como alta.
                        INSERT INTO mig_cargas
                                    (ncarga, cempres, finiorg, ffinorg, ID, estorg)
                             VALUES (v_ncarga, k_cempresa, f_sysdate, f_sysdate, v_id, NULL);
                     WHEN TOO_MANY_ROWS THEN
                        v_tdeserror :=
                           'Hay m¿s de un certificado coincidente para la poliza y asegurado indicado -->'
                           || x.campo03 || ' - ' || x.campo16;
                        v_nnumerr := 9001114;
                        RAISE e_errdatos;
                  END;
-- buscamos por referencia externa
               ELSIF TRIM(x.campo05) IS NOT NULL   -- miro si llega la referencia externa
                                                THEN
                  -- Si me llega el certificado 0 a nulo miro si me llega el asegurado
                    -- busco el certificado para ese producto/poliza, y que tenga ese asegurado
                  v_toperacion := 'MODI';

                  BEGIN
                     SELECT npoliza, ncertif
                       INTO x.campo03, x.campo04   -- lo grabo en la poliza / certificado
                       FROM seguros seg
                      WHERE cpolcia = TRIM(x.campo05)
                        AND npoliza = NVL(TRIM(x.campo03), npoliza)
                        AND sproduc = x.campo02
                        AND(csituac <>
                               2   -- que no este anulada, si esta anulada pod¿ria ser una anulaci¿n
                            AND csituac <> 3
                            AND NOT(csituac = 4
                                    AND creteni = 3)
                            AND NOT(csituac = 4
                                    AND creteni = 4));
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        v_toperacion := 'ALTA';

                        -- no la encuentro la trato como alta.
                        INSERT INTO mig_cargas
                                    (ncarga, cempres, finiorg, ffinorg, ID, estorg)
                             VALUES (v_ncarga, k_cempresa, f_sysdate, f_sysdate, v_id, NULL);
                     WHEN TOO_MANY_ROWS THEN
                        v_tdeserror :=
                           'Hay m¿s de una p¿liza coincidente para n¿mero propuesta externo -->'
                           || x.campo05;
                        v_nnumerr := 9001114;
                        RAISE e_errdatos;
                  END;
               ELSE
                  v_tdeserror :=
                     'Error en el campo de poliza/propuesta externa, para el c¿digo de producto definido -->'
                     || x.campo03;
                  v_nnumerr := 9001114;
                  RAISE e_errdatos;
               END IF;

               v_id := NVL(TRIM(x.campo03), v_ncarga) || '-' || x.campo04;
            END IF;

            IF v_toperacion IN('ALTA', 'MODI')
               AND v_ntipoerror NOT IN(1, 4) THEN
               v_ntraza := 1010;

               -- RESTISTRO 1
               IF x.tiporegistro = '1' THEN   -- polizas
                  --
                    -- ini rllf  28/09/2015 cambios PU y MVA.
                  --SELECT ccompani, crecfra, cramo, cmodali,
                  --       ccolect, ctipseg, crevali, prevali, irevali
                  SELECT ccompani, crecfra, cramo, cmodali,
                         ccolect, ctipseg, crevali, prevali, irevali, cramdgs
                    --INTO reg_migseg.ccompani, reg_migseg.crecfra, v_cramo, v_cmodali,
                    --    v_ccolect, v_ctipseg, v_crevali, v_prevali, v_irevali
                  INTO   reg_migseg.ccompani, reg_migseg.crecfra, v_cramo, v_cmodali,
                         v_ccolect, v_ctipseg, v_crevali, v_prevali, v_irevali, v_cramdgs
                    -- fin rllf  28/09/2015 cambios PU y MVA
                  FROM   productos
                   WHERE sproduc = reg_migseg.sproduc;

                  --
                  IF v_admite_certificados = 1
                     -- I - 30428
                     AND NOT pac_iax_produccion.isaltacol THEN
                     -- busco el certificado 0
                     BEGIN
                        SELECT sseguro, cagente, csituac, fefecto, cforpag,
                               ccompani, crecfra, creteni, fcarpro
                          INTO v_sseguro0, v_cagente, v_csituac, v_fefecto0, v_cforpag0,
                               v_ccompani0, v_crecfra0, v_creteni, v_fcarpro
                          FROM seguros
                         WHERE npoliza = x.campo03
                           AND sproduc = reg_migseg.sproduc
                           AND ncertif = 0;   -- busco el certificado 0

                        SELECT m.cmotmov
                          INTO v_cmotmov
                          FROM seguros s, movseguro m
                         WHERE m.sseguro = s.sseguro
                           AND s.sseguro = v_sseguro0
                           AND m.nmovimi = (SELECT MAX(nmovimi)
                                              FROM movseguro
                                             WHERE sseguro = s.sseguro);
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
--                           IF reg_migseg.sproduc = 7004
--                              AND k_tablas = 'MIG'
--                              AND pac_md_common.f_get_cxtempresa() = 17 THEN
--                              v_tdeserror :=
--                                 'Migraci¿n Conmutaci¿n Pensional: no se encuentra la p¿liza con certificado 0 para crear nuevos certificados.';
--                           ELSE
                           v_tdeserror :=
                              f_desproducto_t(v_cramo, v_cmodali, v_ctipseg, v_ccolect, 1,
                                              k_cidioma)
                              || ': No se encuenta la p¿liza el certificado 0, para crear nuevos certificados. P¿liza: '
                              || x.campo03;
--                           END IF;
                           v_nnumerr := 9904779;
                           RAISE e_errdatos;
                     END;

                     -- miro que la fecha de efecto no sea menor
                     IF f_chartodate(x.campo07) < v_fefecto0 THEN
                        v_tdeserror :=
                           f_desproducto_t(v_cramo, v_cmodali, v_ctipseg, v_ccolect, 1,
                                           k_cidioma)
                           || ': La fecha de efecto (' || x.campo07
                           || ') debe ser mayor o igual que la fecha efecto del certificado 0('
                           || TO_DATE(v_fefecto0, 'DD/MM/YYYY') || ')';
                        RAISE e_errdatos;
                        v_nnumerr := 9000823;
                        RAISE e_errdatos;
                     END IF;

                     -- compruebo que certificado abierto
                     IF pac_seguros.f_es_col_admin(v_sseguro0, 'SEG') = 1 THEN
                        IF f_chartodate(x.campo07) > v_fcarpro THEN
                           v_tdeserror :=
                              'La fecha de efecto (' || x.campo07
                              || ') no puede ser superior a la fecha de pr¿ximo recibo del certificado 0('
                              || TO_CHAR(v_fcarpro, 'DD/MM/YYYY') || ')';
                           v_nnumerr := 100883;
                           RAISE e_errdatos;
                        END IF;

                        -- si es colectivo administrado miro si se pueden hacer
                        --v_nnumerr := pac_seguros.f_suplem_obert(v_sseguro0);
                        --Para realizar una carga la caratula tiene que ser propuesta de alta o propuesta de suplemento,
                        --no tener ningun tipo de retenci¿n, y en caso de ser propuesta de suplemento, el ¿ltimo movimiento
                        --tiene que ser una apertura de suplemento (996)
                        IF k_tablas <> 'MIG' THEN
                           IF v_csituac NOT IN(4, 5)
                              OR(v_csituac IN(4, 5)
                                 AND(v_creteni > 0
                                     AND v_creteni <> 20))
                              OR((v_csituac = 4
                                  AND v_cmotmov <> 100)
                                 OR(v_csituac = 5
                                    AND v_cmotmov <> 996)) THEN
                              v_tdeserror :=
                                 f_desproducto_t(v_cramo, v_cmodali, v_ctipseg, v_ccolect, 1,
                                                 k_cidioma)
                                 || ': El certificado 0 no esta en situaci¿n de modificar/crear nuevos certificados. P¿liza: '
                                 || x.campo03;
--                           END IF;
                              v_nnumerr := v_nnumerr;
                              RAISE e_errdatos;
                           END IF;
                        END IF;

                        -- 26050 me guardo el sseguro y la situaci¿n en la que se encuenta
                        IF vsseguroscargados NOT LIKE '%, ' || v_sseguro0 || ' %' THEN
                           UPDATE seguros
                              SET creteni = 20
                            WHERE sseguro = v_sseguro0;

                           COMMIT;   -- bloqueo el certificado 0
                           vsseguroscargados := vsseguroscargados || ', ' || v_sseguro0 || ' ';
                        END IF;
                     -- ok voy a dar de alta colectivos
                     END IF;
                  END IF;

                  reg_migseg.cactivi := 0;   -- NVL(f_buscavalor('GEN_ACTIVIDAD', x.campo02), 0);
                     -- por defecto actividad 0
                  /*   IF reg_migseg.cactivi IS NULL THEN
                        v_tdeserror := ' C¿digo actividad no definido: ' || x.campo02;
                        v_nnumerr := 9000731;
                        RAISE e_errdatos;
                     END IF;
                   */
                  reg_migseg.npoliza := NVL(TRIM(x.campo03), 0);
                  reg_migseg.ncertif := NVL(x.campo04, 0);
                  reg_migseg.cagente := NVL(x.campo01, v_cagente);   --reg_migpersonas.cagente;
                  reg_migseg.frenova := f_chartodate(x.campo08);
                  reg_migseg.cforpag := x.campo06;
                  reg_migseg.fcarpro := f_chartodate(x.campo27);

                  IF k_tablas = 'MIG' THEN
                     reg_migseg.fcaranu := reg_migseg.frenova;   --
                         --if reg_migseg.cforpag in (0,1) then
                      --    reg_migseg.fcarpro := reg_migseg.frenova;
                     --   else
                     reg_migseg.fcarpro := NVL(reg_migseg.fcarpro, reg_migseg.frenova);
                  --   end if;
                  END IF;

                  reg_migseg.fvencim := f_chartodate(x.campo26);
                  reg_migseg.femisio := NULL;   --f_sysdate;
                  --
                  reg_migseg.crevali := NVL(x.campo19, v_crevali);
                  reg_migseg.prevali := NVL(f_chartonumber(x.campo20), v_prevali);
                  reg_migseg.irevali := NVL(f_chartonumber(x.campo21), v_irevali);
                  reg_migseg.ndurcob := x.campo22;
                  reg_migseg.crecfra := NVL(x.campo30, reg_migseg.crecfra);

                  IF v_admite_certificados = 1
                     AND NOT pac_iax_produccion.isaltacol THEN
                     v_nnumerr := pac_productos.f_get_herencia_col(reg_migseg.sproduc, 2,
                                                                   v_cforpag);

                     IF NVL(v_cforpag, 0) = 1 THEN
                        IF v_cforpag0 <> NVL(reg_migseg.cforpag, v_cforpag0) THEN
                           v_nnumerr :=
                              p_marcalineaerror
                                 (x.proceso, x.nlinea, NULL, 2, 103315,
                                  f_desproducto_t(v_cramo, v_cmodali, v_ctipseg, v_ccolect, 1,
                                                  k_cidioma)
                                  || ':Forma de pago se hereda del certificado 0, y es diferente a la informada en fichero');
                        END IF;

                        reg_migseg.cforpag := v_cforpag0;
                     END IF;

                     v_nnumerr := pac_productos.f_get_herencia_col(reg_migseg.sproduc, 9,
                                                                   v_hccompani);

                     IF NVL(v_hccompani, 0) = 1 THEN   -- machaco la del producto si hereda
                        reg_migseg.ccompani := v_ccompani0;
                     END IF;

                     -- Bug 27539 - 09/09/2013 - RSC
                     v_nnumerr := pac_productos.f_get_herencia_col(reg_migseg.sproduc, 3,
                                                                   v_recfra);

                     IF NVL(v_recfra, 0) = 1
                        AND v_nnumerr = 0 THEN
                        reg_migseg.crecfra := v_crecfra0;
                     END IF;
                  -- Fin Bug 27539
                  END IF;

                  --f_buscavalor('FORMA_PAGO', x.campo06);
                  IF v_toperacion = 'ALTA' THEN   -- forma de pago
                     IF reg_migseg.cforpag IS NULL THEN
                        v_tdeserror := f_desproducto_t(v_cramo, v_cmodali, v_ctipseg,
                                                       v_ccolect, 1, k_cidioma)
                                       || ':Forma pago no definida: ' || x.campo06;
                        v_nnumerr := 140704;
                        RAISE e_errdatos;
                     END IF;
                  END IF;

                  IF reg_migseg.cforpag IS NOT NULL THEN
                     -- valido que la forma  de pago sea correcta segun lo definido en el producto
                     BEGIN
                        SELECT cforpag
                          INTO reg_migseg.cforpag
                          FROM forpagpro
                         WHERE cramo = v_cramo
                           AND cmodali = v_cmodali
                           AND ccolect = v_ccolect
                           AND ctipseg = v_ctipseg
                           AND cforpag = reg_migseg.cforpag;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           v_tdeserror := f_desproducto_t(v_cramo, v_cmodali, v_ctipseg,
                                                          v_ccolect, 1, k_cidioma)
                                          || ':Forma pago no permitida para el producto: '
                                          || x.campo06;
                           v_nnumerr := 140704;
                           RAISE e_errdatos;
                     END;
                  END IF;

                  IF v_toperacion = 'ALTA'
                     AND(x.campo09 = ''
                         OR x.campo09 IS NULL) THEN
                     v_tdeserror := f_desproducto_t(v_cramo, v_cmodali, v_ctipseg, v_ccolect,
                                                    1, k_cidioma)
                                    || ':Se debe informar el medio de pago.';
                     RAISE e_errdatos;
                  END IF;

                  IF x.campo09 = 'E' THEN   -- EFECTIVO
                     reg_migseg.ctipban := NULL;
                     reg_migseg.cbancar := NULL;
                     reg_migseg.ctipcob := f_buscavalor('MEDIO PAGO', x.campo09);
                     reg_migseg.ccobban := NULL;
                  ELSIF x.campo09 = 'D' THEN
                     v_ntraza := 1040;
                     reg_migseg.ctipban := x.campo10;
                     reg_migseg.cbancar := x.campo11;
                     reg_migseg.ctipcob := f_buscavalor('MEDIO PAGO', x.campo09);

                     SELECT MAX(ccobban)
                       INTO reg_migseg.ccobban
                       FROM cobbancariosel
                      WHERE cramo = v_cramo
                        AND ctipseg = v_ctipseg
                        AND cmodali = v_cmodali
                        AND ccolect = v_ccolect;

                     IF v_nnumerr <> 0 THEN
                        v_tdeserror := f_desproducto_t(v_cramo, v_cmodali, v_ctipseg,
                                                       v_ccolect, 1, k_cidioma)
                                       || ':Cobbancario no encontrado para el producto -->'
                                       || v_nnumerr;
                        v_nnumerr := 102374;
                        RAISE e_errdatos;
                     END IF;
                  ELSE
                     v_ntraza := 1040;
                     reg_migseg.ctipban := x.campo10;
                     reg_migseg.cbancar := x.campo11;
                     reg_migseg.ctipcob := x.campo09;

                     IF reg_migseg.cbancar IS NOT NULL THEN
                        SELECT MAX(ccobban)
                          INTO reg_migseg.ccobban
                          FROM cobbancariosel
                         WHERE cramo = v_cramo
                           AND ctipseg = v_ctipseg
                           AND cmodali = v_cmodali
                           AND ccolect = v_ccolect;

                        IF v_nnumerr <> 0 THEN
                           v_tdeserror := f_desproducto_t(v_cramo, v_cmodali, v_ctipseg,
                                                          v_ccolect, 1, k_cidioma)
                                          || ':Cobbancario no encontrado para el producto -->'
                                          || v_nnumerr;
                           v_nnumerr := 102374;
                           RAISE e_errdatos;
                        END IF;
                     END IF;
                  END IF;

                  -- solo lo informa cuando es una alta
                  IF v_toperacion = 'ALTA' THEN
                     INSERT INTO mig_cargas_tab_mig
                                 (ncarga, tab_org, tab_des, ntab)
                          VALUES (v_ncarga, 'INT_CARGA_GENERICO', 'MIG_SEGUROS', 1);

                     --recalculo en ncertif si es un alta.
                     IF (k_tablas = 'MIG'
                         AND v_admite_certificados = 0)
                        OR pac_iax_produccion.isaltacol THEN
                        reg_migseg.ncertif := 0;
                     ELSIF k_tablas IN('MIG', 'POL')
                           AND v_admite_certificados = 1 THEN
                        SELECT MAX(ncertif) + 1
                          INTO reg_migseg.ncertif
                          FROM seguros
                         WHERE npoliza = reg_migseg.npoliza
                           AND sproduc = reg_migseg.sproduc;   --tiene que estar el certificado cero dado de alta.
                     ELSIF k_tablas = 'EST' THEN
                        IF NVL(f_parproductos_v(reg_migseg.sproduc, 'NPOLIZA_EN_EMISION'), 0) =
                                                                                             1
                           AND v_admite_certificados = 1 THEN
                           SELECT ssolicit_certif.NEXTVAL
                             INTO reg_migseg.ncertif
                             FROM DUAL;
                        END IF;
                     END IF;

                     reg_migseg.ncarga := v_ncarga;
                     -- I - JLB -
                     reg_migseg.proceso := x.proceso;
                     reg_migseg.cestmig := 1;
                     reg_migseg.mig_pk := v_ncarga || '/' || x.proceso || '/' || x.nlinea;
                     reg_migseg.mig_fk := '-1';   -- vendra en otro registro

                     IF k_tablas = 'EST' THEN
                        reg_migseg.csituac := NVL(x.campo31, 4);
                     ELSE
                        reg_migseg.csituac := NVL(x.campo31, 0);
                     END IF;

                     v_ntraza := 1020;
                     reg_migseg.cempres := k_cempresa;
                     reg_migseg.creafac := 0;
                     reg_migseg.ctipcoa := 0;
                     reg_migseg.ctiprea := 0;
                     reg_migseg.ctipcom := 0;   --Habitual
                     reg_migseg.cidioma := k_cidioma;
                     reg_migseg.creteni := 0;
                     reg_migseg.sciacoa := NULL;
                     reg_migseg.pparcoa := NULL;
                     reg_migseg.npolcoa := NULL;
                     reg_migseg.nsupcoa := NULL;
                     reg_migseg.pdtocom := NULL;
                     reg_migseg.ncuacoa := 1;
                     reg_migseg.cpolcia := x.campo05;
                     reg_migseg.fefecto := f_chartodate(x.campo07);

                     IF v_toperacion = 'ALTA'
                        AND reg_migseg.fefecto IS NULL THEN
                        v_tdeserror := f_desproducto_t(v_cramo, v_cmodali, v_ctipseg,
                                                       v_ccolect, 1, k_cidioma)
                                       || ': Se debe informar la fecha de efecto de la p¿liza.';
                        v_nnumerr := 1000135;
                        RAISE e_errdatos;
                     END IF;

                     --       reg_migseg.ccobban := NULL;
                     reg_migseg.casegur := 1;
                     reg_migseg.nsuplem := 0;
                     reg_migseg.sseguro := 0;
                     reg_migseg.sperson := 0;
                     reg_migseg.nedamar := x.campo18;
                     v_ntraza := 1050;

                     -- ini rllf 05102015 nueva funcionalidad de reemplazos, el codigo no estaba incluido.
                     IF (x.campo28 IS NOT NULL) THEN
                        SELECT MAX(sseguro), MAX(fefecto)
                          INTO vsegreempl, vremplefecto
                          FROM seguros
                         WHERE cpolcia = x.campo28
                           AND ncertif = NVL(x.campo29, 0);

                        IF (vsegreempl > 0) THEN
                           INSERT INTO mig_cargas_tab_mig
                                       (ncarga, tab_org, tab_des, ntab)
                                VALUES (v_ncarga, 'INT_CARGA_GENERICO', 'MIG_REEMPLAZOS', 73);

                           reg_migreemplazos := NULL;
                           reg_migreemplazos.cestmig := 1;
                           reg_migreemplazos.ncarga := v_ncarga;
                           reg_migreemplazos.sseguro := 0;
                           reg_migreemplazos.sreempl := vsegreempl;
                           reg_migreemplazos.mig_pk :=
                              v_ncarga || '/' || x.proceso || '/' || x.nlinea || '/'
                              || vsegreempl;
                           reg_migreemplazos.mig_fk :=
                                                v_ncarga || '/' || x.proceso || '/' || x.nlinea;
                           reg_migreemplazos.fmovdia := vremplefecto;
                           reg_migreemplazos.cusuario := f_user;
                           reg_migreemplazos.ctipo := 3;   -- Ponemos fijo el tipo 3 -> p¿liza saldada.
                           reg_migreemplazos.cagente := reg_migseg.cagente;

                           INSERT INTO mig_reemplazos
                                VALUES reg_migreemplazos
                             RETURNING ROWID
                                  INTO v_rowid;

                           INSERT INTO mig_pk_emp_mig
                                VALUES (0, v_ncarga, 74, reg_migseg.mig_pk);
                        END IF;
                     END IF;

                     -- fin rllf 05102015 nueva funcionalidad de reemplazos, el codigo no estaba incluido.
                     INSERT INTO mig_seguros
                          VALUES reg_migseg
                       RETURNING ROWID
                            INTO v_rowid;

                     INSERT INTO mig_pk_emp_mig
                          VALUES (0, v_ncarga, 1, reg_migseg.mig_pk);
                  END IF;
               -- REGISTRO 02 -- Movimientos
               ELSIF x.tiporegistro = '2' THEN   -- movimientos
                  reg_migmovseg := NULL;
                  v_cmotmov_965 := x.campo02;   -- me guardo el movimiento que es lo utilizar¿ para la carga masiva de asegurados innominados

                  -- compruebo que tipo de movimiento es, segun el codigo de tipo de movimiento

                  -- Miro si estoy en la misma p¿liza de antes y emito
                  IF v_toperacion = 'MODI'
                     AND v_sseguroest IS NOT NULL THEN
                     v_nnumerr := p_finalizar_suple(v_ncarga, v_sseguroest, v_nmovimi,
                                                    v_sseguro, v_tdeserror, p_ssproces);

                     -- tengo que grabar el resultado
                     IF v_nnumerr <> 0 THEN
                        v_berrorproc := TRUE;
                        v_nnumerr := f_marcar_lineas(p_ssproces, v_ncarga, 1,   -- pongo error
                                                     v_toperacion, v_nnumerr, v_tdeserror,
                                                     NULL, NULL, NULL, NULL, NULL);
                     ELSE
                        v_nnumerr := f_marcar_lineas(p_ssproces, v_ncarga, 4,   -- pongo ok
                                                     v_toperacion, v_nnumerr, NULL, v_sseguro,
                                                     NULL, NULL, NULL, NULL);
                     END IF;

                     v_sseguroest := NULL;   -- ya he emitido este suplemento, y genero otro nuevo

                     IF v_nnumerr NOT IN(0, 2, 4) THEN   -- si ha habido error
                        ROLLBACK;

                        IF k_cpara_error <> 1 THEN
                           v_ntipoerror := 4;
                        -- para que continue con la siguiente linea.
                        ELSE
                           v_ntipoerror := 1;   -- para la carga
                           RAISE e_salir;
                        END IF;
                     ELSE
                        COMMIT;
                     -- v_ncarga := f_next_carga;
                     END IF;
                  END IF;

                  BEGIN
                     SELECT cmovseg
                       INTO v_cmovseg
                       FROM codimotmov
                      WHERE cmotmov = x.campo02;

                     -- ojo
                     IF x.campo02 IN(221, 236) THEN
                        v_cmovseg := 3;   --aunque esta como modificaci¿n  se tiene que tratar como baja
                     END IF;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
--                        IF reg_migseg.sproduc = 7001
--                           AND k_tablas = 'MIG'
--                           AND pac_md_common.f_get_cxtempresa() = 17 THEN
--                           v_tdeserror :=
--                              'Migraci¿n Renta Vitalicia: se debe informar el c¿digo de movimiento.';
--                        ELSIF reg_migseg.sproduc = 7004
--                              AND k_tablas = 'MIG'
--                              AND pac_md_common.f_get_cxtempresa() = 17 THEN
--                           v_tdeserror :=
--                              'Migraci¿n Conmutaci¿n Pensional: se debe informar el c¿digo de movimiento.';
--                        ELSE
                        v_tdeserror := f_desproducto_t(v_cramo, v_cmodali, v_ctipseg,
                                                       v_ccolect, 1, k_cidioma)
                                       || ': se debe informar el c¿digo de movimiento.';
--                        END IF;
                        v_nnumerr := 152158;
                        RAISE e_errdatos;
                  END;

                  IF v_cmovseg = 0
                     OR(k_tablas = 'MIG') THEN   -- si es un movimiento de alta o vamos contra las POL (migracion)
                     -- Compruebo que si me llega que la operaci¿n este definida correctamente
                     IF v_toperacion <> 'ALTA'
                        AND k_tablas <> 'MIG' THEN
                        v_tdeserror :=
                           'Se envia un movimiento de alta, y parece ser un modificaci¿n de poliza existente -->'
                           || v_toperacion || ' - Cod.Mov:' || x.campo02;
                        v_nnumerr := 1000591;
                        RAISE e_errdatos;
                     END IF;

                     INSERT INTO mig_cargas_tab_mig
                                 (ncarga, tab_org, tab_des, ntab)
                          VALUES (v_ncarga, 'INT_CARGA_GENERICO', 'MIG_MOVSEGURO', 2);

                     v_ntraza := 2000;
                     --Movseguro
                     reg_migmovseg.sseguro := 0;

                     IF k_tablas <> 'MIG' THEN
                        reg_migmovseg.nmovimi := 1;   -- es un cmovseg = 0 solo puede ser un alta
                     ELSE
                        reg_migmovseg.nmovimi := x.campo01;

                        -- ojo aunque sea mig
                        IF x.campo01 <> 1
                           AND v_cmovseg = 0 THEN   -- solo puede ser movimiento 1 el alta. Sino error.
--                           IF reg_migseg.sproduc = 7004
--                              AND k_tablas = 'MIG'
--                              AND pac_md_common.f_get_cxtempresa() = 17 THEN
--                              v_tdeserror :=
--                                 'Migraci¿n Conmutaci¿n Pensional: el movimiento de alta de p¿liza solamente puede llegar en el primer movimiento.';
--                           ELSIF reg_migseg.sproduc = 7001
--                                 AND k_tablas = 'MIG'
--                                 AND pac_md_common.f_get_cxtempresa() = 17 THEN
--                              v_tdeserror :=
--                                 'Migraci¿n Renta Vitalicia: el movimiento de alta de p¿liza solamente puede llegar en el primer movimiento.';
--                           ELSE
                           v_tdeserror :=
                              'Migraci¿n '
                              || f_desproducto_t(v_cramo, v_cmodali, v_ctipseg, v_ccolect, 1,
                                                 k_cidioma)
                              || '. El movimiento de alta de p¿liza solamente puede llegar en el primer movimiento.';
--                           END IF;
                           v_nnumerr := 152158;
                           RAISE e_errdatos;
                        END IF;
                     END IF;

                     reg_migmovseg.cmotmov := x.campo02;
                     reg_migmovseg.fefecto := f_chartodate(x.campo04);

                     IF reg_migmovseg.fefecto IS NULL THEN
--                        IF reg_migseg.sproduc = 7001
--                           AND k_tablas = 'MIG'
--                           AND pac_md_common.f_get_cxtempresa() = 17 THEN
--                           v_tdeserror :=
--                              'Migraci¿n Renta Vitalicia: se debe informar la fecha de efecto del movimiento.';
--                        ELSIF reg_migseg.sproduc = 7004
--                              AND k_tablas = 'MIG'
--                              AND pac_md_common.f_get_cxtempresa() = 17 THEN
--                           v_tdeserror :=
--                              'Migraci¿n Conmutaci¿n Pensional: se debe informar la fecha de efecto del movimiento.';
--                        ELSE
                        v_tdeserror := f_desproducto_t(v_cramo, v_cmodali, v_ctipseg,
                                                       v_ccolect, 1, k_cidioma)
                                       || ': se debe informar la fecha de efecto del movimiento.';
--                        END IF;
                        v_nnumerr := 1000135;
                        RAISE e_errdatos;
                     END IF;

                     reg_migmovseg.mig_pk := reg_migseg.mig_pk || '/' || x.campo01;
                     reg_migmovseg.mig_fk := reg_migseg.mig_pk;
                     reg_migmovseg.cestmig := 1;
                     reg_migmovseg.ncarga := v_ncarga;
                     v_ntraza := 2010;
                     reg_migmovseg.fmovimi := f_chartodate(x.campo03);

                     IF reg_migmovseg.fmovimi IS NULL THEN
--                        IF reg_migseg.sproduc = 7001
--                           AND k_tablas = 'MIG'
--                           AND pac_md_common.f_get_cxtempresa = 17 THEN
--                           v_tdeserror :=
--                              'Migraci¿n Renta Vitalicia: se debe informar la fecha del movimiento.';
--                        ELSIF reg_migseg.sproduc = 7004
--                              AND k_tablas = 'MIG'
--                              AND pac_md_common.f_get_cxtempresa = 17 THEN
--                           v_tdeserror :=
--                              'Migraci¿n Conmutaci¿n Pensional: se debe informar la fecha del movimiento.';
--                        ELSE
                        v_tdeserror := f_desproducto_t(v_cramo, v_cmodali, v_ctipseg,
                                                       v_ccolect, 1, k_cidioma)
                                       || ': Se debe informar la fecha del movimiento.';
--                        END IF;
                        v_nnumerr := 1000135;
                        RAISE e_errdatos;
                     END IF;

                     INSERT INTO mig_movseguro
                          VALUES reg_migmovseg
                       RETURNING ROWID
                            INTO v_rowid;

                     INSERT INTO mig_pk_emp_mig
                          VALUES (0, v_ncarga, 2, reg_migmovseg.mig_pk);
                  ELSIF v_cmovseg = 1 THEN   --  SUPLEMENTO
                     -- Compruebo que si me llega que la operaci¿n este definida correctamente
                     IF v_toperacion <> 'MODI' THEN
                        v_tdeserror :=
                           f_desproducto_t(v_cramo, v_cmodali, v_ctipseg, v_ccolect, 1,
                                           k_cidioma)
                           || ': Se env¿a un movimiento de modificaci¿n y el sistema est¿ creando un alta.';
                        v_nnumerr := 1000591;
                        RAISE e_errdatos;
                     END IF;

                     IF NVL(reg_migseg.ncertif, 0) = 0
                        AND v_admite_certificados = 1 THEN
                        v_tdeserror :=
                           f_desproducto_t(v_cramo, v_cmodali, v_ctipseg, v_ccolect, 1,
                                           k_cidioma)
                           || ': No se puede realizar el sumplemento sobre el certificado 0.';
                        v_nnumerr := 9001959;
                        RAISE e_errdatos;
                     END IF;

                     -- estoy en suplemento, todos los registros seran updates
                     BEGIN
                        SELECT sseguro, cagente, fefecto
                          INTO v_sseguro, v_cagente, v_fefecto
                          FROM seguros
                         WHERE npoliza = reg_migseg.npoliza
                           AND ncertif = reg_migseg.ncertif
                           AND sproduc = reg_migseg.sproduc
                           AND cactivi = reg_migseg.cactivi
                           AND cempres = k_cempresa;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           v_tdeserror := f_desproducto_t(v_cramo, v_cmodali, v_ctipseg,
                                                          v_ccolect, 1, k_cidioma)
                                          || ': Error recuperando la poliza';
                           v_nnumerr := 9001557;
                           RAISE e_errdatos;
                     END;

                     v_fsuplemento := f_chartodate(x.campo04);

                     IF v_fsuplemento IS NULL THEN
                        v_tdeserror :=
                           f_desproducto_t(v_cramo, v_cmodali, v_ctipseg, v_ccolect, 1,
                                           k_cidioma)
                           || ': Se debe informar la fecha de efecto del suplemento. ';
                        v_tdeserror :=
                           v_tdeserror
                           || '. Editar linea de tipo 02 y modificar fecha efecto (campo04) y reprocesar';
                        v_nnumerr := 1000135;
                        RAISE e_errdatos;
                     END IF;

                     -- inicializo
                     reg_migmovseg.cmotmov := x.campo02;
                     v_nnumerr := p_iniciar_suple(v_sseguro, v_fsuplemento,
                                                  reg_migmovseg.cmotmov, v_sseguroest,
                                                  v_nmovimi, v_tdeserror);

                     IF v_nnumerr <> 0 THEN
                        RAISE e_errdatos;
                     END IF;

                     -- Modifico los campos de la cabcera de la p¿liza. seg¿n tipo de suplemento
                      /* UPDATE estseguros
                        SET  frenova = reg_migseg.frenova,
                             fvencim = reg_migseg.fvencim,
                             cagente = NVL(reg_migseg.cagente, cagente),
                             cforpag = NVL(reg_migseg.cforpag, cforpag),
                             ctipban = reg_migseg.ctipban,
                             cbancar = reg_migseg.cbancar,
                             ctipcob = NVL(reg_migseg.ctipcob, ctipcob),
                             ccobban = NVL(reg_migseg.ccobban, ccobban),
                             crecfra = NVL(reg_migseg.crecfra, crecfra)
                      WHERE sseguro = v_sseguroest;*/
                     IF reg_migmovseg.cmotmov = 212 THEN   -- cambio de agente
                        UPDATE estseguros
                           SET cagente = NVL(reg_migseg.cagente, cagente)
                         WHERE sseguro = v_sseguroest;
                     ELSIF reg_migmovseg.cmotmov = 269 THEN
                        UPDATE estseguros
                           SET cforpag = NVL(reg_migseg.cforpag, cforpag)
                         WHERE sseguro = v_sseguroest;
                     ELSIF reg_migmovseg.cmotmov = 286 THEN
                        UPDATE estseguros
                           SET ctipban = reg_migseg.ctipban,
                               cbancar = reg_migseg.cbancar,
                               ctipcob = reg_migseg.ctipcob,
                               ccobban = NVL(reg_migseg.ccobban, ccobban)
                         WHERE sseguro = v_sseguroest;
                     ELSIF reg_migmovseg.cmotmov = 927 THEN
                        UPDATE estseguros
                           SET crecfra = reg_migseg.crecfra
                         WHERE sseguro = v_sseguroest;
                     ELSIF reg_migmovseg.cmotmov IN(227, 905) THEN
                        UPDATE estseguros
                           SET frenova = reg_migseg.frenova
                         WHERE sseguro = v_sseguroest;
                     ELSIF reg_migmovseg.cmotmov = 226 THEN
                        UPDATE estseguros
                           SET fvencim = reg_migseg.fvencim
                         WHERE sseguro = v_sseguroest;
                     END IF;
                  ---
                  ELSIF v_cmovseg = 2 THEN   --  RENOVACION
                     NULL;
                  -- de momento no hacemos nada...deberiamos pasar cartera...
                  ELSIF v_cmovseg = 3 THEN   -- baja
                     IF v_toperacion NOT IN('MODI', 'BAJA') THEN
--                        IF reg_migseg.sproduc = 7001
--                           AND k_tablas = 'MIG'
--                           AND pac_md_common.f_get_cxtempresa() = 17 THEN
--                           v_tdeserror :=
--                              'Migraci¿n Renta Vitalicia: se env¿a un movimiento de baja y el sistema ha detectado que es: '
--                              || v_toperacion;
--                        ELSIF reg_migseg.sproduc = 7004
--                              AND k_tablas = 'MIG'
--                              AND pac_md_common.f_get_cxtempresa() = 17 THEN
--                           v_tdeserror :=
--                              'Migraci¿n Conmutaci¿n Pensional: se env¿a un movimiento de baja y el sistema ha detectado que es: '
--                              || v_toperacion;
--                        ELSE
                        v_tdeserror :=
                           f_desproducto_t(v_cramo, v_cmodali, v_ctipseg, v_ccolect, 1,
                                           k_cidioma)
                           || ': Se envia un movimiento de baja, y el sistema a detectado que es: -->'
                           || v_toperacion || ' - Cod.Mov:' || x.campo02;
--                        END IF;
                        v_nnumerr := 1000591;
                        RAISE e_errdatos;
                     END IF;

                     v_toperacion := 'BAJA';

                     BEGIN
                        SELECT sseguro
                          INTO v_sseguro
                          FROM seguros
                         WHERE npoliza = reg_migseg.npoliza
                           AND ncertif = reg_migseg.ncertif
                           AND sproduc = reg_migseg.sproduc
                           AND cactivi = reg_migseg.cactivi
                           AND cempres = k_cempresa;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           v_tdeserror := 'Error recuperando poliza';
                           v_nnumerr := 9001557;
                           RAISE e_errdatos;
                     END;

                     v_ntraza := 2110;
                     x.ncarga := v_ncarga;
                     v_ntipoerror := f_baja_poliza(p_ssproces, v_ncarga, x.nlinea, x.campo02,
                                                   f_chartodate(x.campo04), v_sseguro, v_id,
                                                   'BAJA', v_tdeserror, x.campo05, x.campo06,
                                                   x.campo07);
                     v_ntraza := 2120;

                     IF v_ntipoerror NOT IN(0, 4, 2) THEN
                        v_nnumerr := 104298;
                        RAISE e_errdatos;
                     END IF;

                     v_id := NULL;
                     COMMIT;   -- como acaba ok, grabo la anulaci¿n
                  ELSIF v_cmovseg = 4 THEN   -- Rehabilitacion
                     BEGIN
                        SELECT sseguro, cagente
                          INTO v_sseguro, v_cagente
                          FROM seguros
                         WHERE npoliza = reg_migseg.npoliza
                           AND ncertif = reg_migseg.ncertif
                           AND sproduc = reg_migseg.sproduc
                           AND cactivi = reg_migseg.cactivi
                           AND cempres = k_cempresa;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           v_tdeserror := 'Error recuperando poliza';
                           v_nnumerr := 9001557;
                           RAISE e_errdatos;
                     END;

                     --v_nnumerr := pac_rehabilita.f_rehabilita(v_sseguro, x.campo02, v_cagente,
                     --                                         v_nmovimi);
                     v_nnumerr := pac_md_rehabilita.f_rehabilitapol(v_sseguro, x.campo02, 1,
                                                                    mensajes);

                     IF v_nnumerr <> 0 THEN
                        --v_tdeserror := 'Error en la rehabilitaci¿n';
                        --v_nnumerr := 9001557;
                        --RAISE e_errdatos;
                        IF mensajes IS NOT NULL THEN
                           FOR i IN mensajes.FIRST .. mensajes.LAST LOOP
                              v_tdeserror := mensajes(i).terror;
                              v_nnumerr := mensajes(i).cerror;
                              RAISE e_errdatos;
                           END LOOP;
                        END IF;
                     ELSE
                        -- si tiene fecha de vencimiento la borro para que el suplemento no de problemas
                        /*UPDATE seguros
                           SET fvencim = NULL
                         WHERE sseguro = v_sseguro
                           AND fvencim IS NOT NULL;
                            */
                        v_nnumerr := f_marcar_lineas(p_ssproces, v_ncarga, 4,   -- pongo ok
                                                     v_toperacion, v_nnumerr, NULL, v_sseguro,
                                                     NULL, NULL, NULL, NULL);

                        IF v_nnumerr <> 0 THEN
                           RAISE e_errdatos;
                        END IF;

                        v_id := NULL;   -- para que al salir no vuelva a lanzar la migraci¿n como si fuese el primero.
                        COMMIT;   -- ok acepto la rehabilitacion--
                     --marco las lineas como correctas.
                     END IF;
                  END IF;
               ELSIF x.tiporegistro = '3' THEN   -- tomadores
                  IF v_toperacion = 'ALTA'
                     AND reg_migseg.mig_fk = '-1' THEN
                     reg_migpersonas := NULL;
                     v_ntraza := 3010;

                     INSERT INTO mig_cargas_tab_mig
                                 (ncarga, tab_org, tab_des, ntab)
                          VALUES (v_ncarga, 'INT_CARGA_GENERICO', 'MIG_PERSONAS', 1);

                     reg_migpersonas.ncarga := v_ncarga;
                     -- I - JLB -
                     reg_migpersonas.proceso := x.proceso;

                     IF x.campo03 = ''
                        OR x.campo03 IS NULL THEN
--                        IF reg_migseg.sproduc = 7001
--                           AND k_tablas = 'MIG'
--                           AND pac_md_common.f_get_cxtempresa() = 17 THEN
--                           v_tdeserror :=
--                              'Migraci¿n Renta Vitalicia: se debe informar el tipo de identificador del tomador.';
--                        ELSIF reg_migseg.sproduc = 7004
--                              AND k_tablas = 'MIG'
--                              AND pac_md_common.f_get_cxtempresa() = 17 THEN
                        v_tdeserror :=
                           f_desproducto_t(v_cramo, v_cmodali, v_ctipseg, v_ccolect, 1,
                                           k_cidioma)
                           || ': Se debe informar el tipo de identificador del tomador.';
--                        END IF;
                        RAISE e_errdatos;
                     END IF;

                     reg_migpersonas.ctipide := x.campo03;

                     --f_buscavalor('TIPO_IDENTIFICADOR_PERSONA',x.campo03);
                     -- NIF carga fichero (detvalor 672)
                     -- Fi Bug 0017569
                     IF x.campo04 = ''
                        OR x.campo04 IS NULL THEN
--                        IF reg_migseg.sproduc = 7001
--                           AND k_tablas = 'MIG'
--                           AND pac_md_common.f_get_cxtempresa() = 17 THEN
--                           v_tdeserror :=
--                              'Migraci¿n Renta Vitalicia: se debe informar el n¿mero de identificaci¿n del tomador.';
--                        ELSIF reg_migseg.sproduc = 7004
--                              AND k_tablas = 'MIG'
--                              AND pac_md_common.f_get_cxtempresa() = 17 THEN
--                           v_tdeserror :=
--                              'Migraci¿n Conmutaci¿n Pensional: se debe informar el n¿mero de identificaci¿n del tomador.';
--                        ELSE
                        v_tdeserror :=
                           f_desproducto_t(v_cramo, v_cmodali, v_ctipseg, v_ccolect, 1,
                                           k_cidioma)
                           || ': Se debe informar el n¿mero de identificaci¿n del tomador.';
--                        END IF;
                        RAISE e_errdatos;
                     END IF;

                     reg_migpersonas.nnumide := x.campo04;
                     reg_migpersonas.tdigitoide := x.campo05;
                     -- reg_migpersonas.mig_pk := v_ncarga || '/' || x.nlinea || '/'
                     --                           || reg_migpersonas.nnumide;
                     reg_migpersonas.mig_pk := v_ncarga || '/' || reg_migpersonas.ctipide
                                               || '/' || reg_migpersonas.nnumide;
                     v_ntraza := 3030;
                     reg_migpersonas.cestmig := 1;
                     reg_migpersonas.idperson := 0;

                     IF x.campo06 = ''
                        OR x.campo06 IS NULL THEN
--                        IF reg_migseg.sproduc = 7001
--                           AND k_tablas = 'MIG'
--                           AND pac_md_common.f_get_cxtempresa() = 17 THEN
--                           v_tdeserror :=
--                              'Migraci¿n Renta Vitalicia: se debe informar el tipo de persona del tomador.';
--                        ELSIF reg_migseg.sproduc = 7004
--                              AND k_tablas = 'MIG'
--                              AND pac_md_common.f_get_cxtempresa() = 17 THEN
--                           v_tdeserror :=
--                              'Migraci¿n Conmutaci¿n Pensional: se debe informar el tipo de persona del tomador.';
--                        ELSE
                        v_tdeserror := f_desproducto_t(v_cramo, v_cmodali, v_ctipseg,
                                                       v_ccolect, 1, k_cidioma)
                                       || ': Se debe informar el tipo de persona del tomador.';
--                        END IF;
                        RAISE e_errdatos;
                     END IF;

                     reg_migpersonas.cpertip := f_buscavalor('TIPUS PERSONA', x.campo06);

                     IF x.campo07 = ''
                        OR x.campo07 IS NULL THEN
--                        IF reg_migseg.sproduc = 7001
--                           AND k_tablas = 'MIG'
--                           AND pac_md_common.f_get_cxtempresa() = 17 THEN
--                           v_tdeserror :=
--                              'Migraci¿n Renta Vitalicia: se debe informar el apellido 1 del tomador.';
--                        ELSIF reg_migseg.sproduc = 7004
--                              AND k_tablas = 'MIG'
--                              AND pac_md_common.f_get_cxtempresa() = 17 THEN
--                           v_tdeserror :=
--                              'Migraci¿n Conmutaci¿n Pensional: se debe informar el apellido 1 del tomador.';
--                        ELSE
                        v_tdeserror := f_desproducto_t(v_cramo, v_cmodali, v_ctipseg,
                                                       v_ccolect, 1, k_cidioma)
                                       || ': Se debe informar el apellido 1 del tomador.';
--                        END IF;
                        RAISE e_errdatos;
                     END IF;

                     reg_migpersonas.tapelli1 := x.campo07;
                     reg_migpersonas.tapelli2 := x.campo08;
                     reg_migpersonas.cagente := ff_agente_cpervisio(reg_migseg.cagente);
                     reg_migpersonas.cidioma := k_cidioma;
                     reg_migpersonas.tnombre := x.campo09;
                     reg_migpersonas.tnombre2 := x.campo10;
                     v_ntraza := 3060;
                     reg_migpersonas.csexper := f_buscavalor('SEXO', x.campo11);
                     reg_migpersonas.swpubli := 0;
                     reg_migpersonas.fnacimi := f_chartodate(x.campo12);

                     IF reg_migpersonas.fnacimi IS NOT NULL
                        AND TRUNC(reg_migpersonas.fnacimi) > TRUNC(f_sysdate) THEN
--                        IF reg_migseg.sproduc = 7001
--                           AND k_tablas = 'MIG'
--                           AND pac_md_common.f_get_cxtempresa() = 17 THEN
--                           v_tdeserror :=
--                              'Migraci¿n Renta Vitalicia: la fecha de nacimiento del tomador no puede ser superior a la fecha de hoy.';
--                        ELSIF reg_migseg.sproduc = 7004
--                              AND k_tablas = 'MIG'
--                              AND pac_md_common.f_get_cxtempresa() = 17 THEN
--                           v_tdeserror :=
--                              'Migraci¿n Conmutaci¿n Pensional: la fecha de nacimiento del tomador no puede ser superior a la fecha de hoy.';
--                        ELSE
                        v_tdeserror :=
                           f_desproducto_t(v_cramo, v_cmodali, v_ctipseg, v_ccolect, 1,
                                           k_cidioma)
                           || ': La fecha de nacimiento del tomador no puede ser superior a la fecha de hoy.';
--                        END IF;
                        RAISE e_errdatos;
                     END IF;

                     reg_migpersonas.cnacio := x.campo13;
                     reg_migpersonas.cpais := x.campo13;
                     -- pais de residencia = a nacionalidad
                     reg_migpersonas.cestper := 0;
                     reg_migpersonas.cestciv := x.campo14;
                     reg_migpersonas.tdigitoide := x.campo05;
                     reg_migpersonas.tnumtel := x.campo15;
                     reg_migpersonas.tnummov := x.campo16;
                     reg_migpersonas.temail := x.campo17;
                     v_ntraza := 3070;

                     IF reg_migpersonas.cpertip = 1
                        AND reg_migpersonas.csexper IS NULL THEN
--                        IF reg_migseg.sproduc = 7001
--                           AND k_tablas = 'MIG'
--                           AND pac_md_common.f_get_cxtempresa() = 17 THEN
--                           v_tdeserror :=
--                              'Migraci¿n Renta Vitalicia: si el tomador es persona natural se debe informar su sexo.';
--                        ELSIF reg_migseg.sproduc = 7004
--                              AND k_tablas = 'MIG'
--                              AND pac_md_common.f_get_cxtempresa() = 17 THEN
--                           v_tdeserror :=
--                              'Migraci¿n Conmutaci¿n Pensional: si el tomador es persona natural se debe informar su sexo.';
--                        ELSE
                        v_tdeserror :=
                           f_desproducto_t(v_cramo, v_cmodali, v_ctipseg, v_ccolect, 1,
                                           k_cidioma)
                           || ': Si el tomador es persona natural se debe informar su sexo.';
--                        END IF;
                        RAISE e_errdatos;
                     ELSIF reg_migpersonas.cpertip = 1
                           AND reg_migpersonas.fnacimi IS NULL THEN
--                        IF reg_migseg.sproduc = 7001
--                           AND k_tablas = 'MIG'
--                           AND pac_md_common.f_get_cxtempresa() = 17 THEN
--                           v_tdeserror :=
--                              'Migraci¿n Renta Vitalicia: si el tipo de persona del tomador es natural se debe informar su fecha de nacimiento.';
--                        ELSIF reg_migseg.sproduc = 7004
--                              AND k_tablas = 7004
--                              AND pac_md_common.f_get_cxtempresa() = 17 THEN
--                           v_tdeserror :=
--                              'Migraci¿n Conmutaci¿n Pensional: si el tipo de persona del tomador es natural se debe informar su fecha de nacimiento.';
--                        ELSE
                        v_tdeserror :=
                           f_desproducto_t(v_cramo, v_cmodali, v_ctipseg, v_ccolect, 1,
                                           k_cidioma)
                           || ': Si el tipo de persona del tomador es natural se debe informar su fecha de nacimiento.';
--                        END IF;
                        v_nnumerr := 1000401;
                        RAISE e_errdatos;
                     END IF;

                     -- valido -- la fecha de nacimiento del tomador
                     --vedadmin := NVL(f_parproductos_v(reg_migseg.sproduc, 'EDADMINTOM'), 0);

                     -- El producto tiene parametrizada la edad minima del tomador
                     IF vedadmin <> 0 THEN
                        IF NVL(reg_migpersonas.cpertip, 0) = 1 THEN
                           -- Validamos la fecha si el tomador no es persona jur¿dica
                           IF ADD_MONTHS(reg_migpersonas.fnacimi, 12 * vedadmin) >
                                                                     TRUNC(reg_migseg.fefecto) THEN
--                              IF reg_migseg.sproduc = 7001
--                                 AND k_tablas = 'MIG'
--                                 AND pac_md_common.f_get_cxtempresa() = 17 THEN
--                                 v_tdeserror :=
--                                    'Migraci¿n Renta Vitalicia: el tomador no cumple reglas de contrataci¿n.';
--                              ELSIF reg_migseg.sproduc = 7004
--                                    AND k_tablas = 'MIG'
--                                    AND pac_md_common.f_get_cxtempresa() = 17 THEN
--                                 v_tdeserror :=
--                                    'Migraci¿n Conmutaci¿n Pensional: el tomador no cumple reglas de contrataci¿n.';
--                              ELSE
                              v_tdeserror := f_desproducto_t(v_cramo, v_cmodali, v_ctipseg,
                                                             v_ccolect, 1, k_cidioma)
                                             || ': El tomador no cumple reglas de contrataci¿n.';
--                              END IF;
                              v_nnumerr := 9901762;
                              RAISE e_errdatos;
                           END IF;
                        END IF;
                     END IF;

                     BEGIN
                        INSERT INTO mig_personas
                             VALUES reg_migpersonas
                          RETURNING ROWID
                               INTO v_rowid;

                        v_ntraza := 3080;

                        INSERT INTO mig_pk_emp_mig
                             VALUES (0, v_ncarga, 3, reg_migpersonas.mig_pk);
                     EXCEPTION
                        WHEN DUP_VAL_ON_INDEX THEN   -- puede ser que la persona haya llegado como otro figura
                           NULL;
                     END;

                     --
                     IF reg_migseg.mig_fk = '-1' THEN
                        --machacamos el tomador
                        reg_migseg.mig_fk := reg_migpersonas.mig_pk;

                        UPDATE mig_seguros
                           SET mig_fk = reg_migpersonas.mig_pk
                         WHERE ncarga = v_ncarga
                           AND mig_pk = reg_migseg.mig_pk;
                     END IF;

                     -- miro si me llega informado el regimen fiscal
                     IF x.campo18 IS NOT NULL THEN
                        v_ntraza := 3100;

                        INSERT INTO mig_cargas_tab_mig
                                    (ncarga, tab_org, tab_des, ntab)
                             VALUES (v_ncarga, 'INT_CARGA_GENERICO', 'MIG_REGIMENFISCAL', 1);

                        v_ntraza := 3110;
                        reg_migregimenfiscal := NULL;
                        reg_migregimenfiscal.ncarga := v_ncarga;
                        reg_migregimenfiscal.cestmig := 1;
                        reg_migregimenfiscal.mig_pk :=
                                  v_ncarga || '/' || x.nlinea || '/' || reg_migpersonas.nnumide;
                        reg_migregimenfiscal.mig_fk := reg_migpersonas.mig_pk;
                        reg_migregimenfiscal.nanuali := TO_CHAR(reg_migseg.fefecto, 'YYYY');
                        reg_migregimenfiscal.fefecto := reg_migseg.fefecto;
                        reg_migregimenfiscal.cregfis := x.campo18;

                        BEGIN
                           INSERT INTO mig_regimenfiscal
                                VALUES reg_migregimenfiscal
                             RETURNING ROWID
                                  INTO v_rowid;

                           v_ntraza := 3080;

                           INSERT INTO mig_pk_emp_mig
                                VALUES (0, v_ncarga, 4, reg_migregimenfiscal.mig_pk);
                        EXCEPTION
                           WHEN DUP_VAL_ON_INDEX THEN   -- puede ser que la persona haya llegado como otro figura
                              NULL;
                        END;
                     END IF;
                  ELSIF v_toperacion = 'MODI' THEN
                     NULL;   -- NO realizamos suplemento de tomador
                  END IF;
               ELSIF x.tiporegistro = '3A' THEN   --  direccion tomadores Chile
                  IF v_toperacion = 'ALTA' THEN
                     reg_migdirec := NULL;

                     INSERT INTO mig_cargas_tab_mig
                                 (ncarga, tab_org, tab_des, ntab)
                          VALUES (v_ncarga, 'INT_CARGA_GENERICO', 'MIG_DIRECCIONES', 1);

                     reg_migdirec.ncarga := v_ncarga;
                     -- I - JLB -
                     reg_migdirec.proceso := x.proceso;
                     reg_migdirec.mig_pk := v_ncarga || '/' || reg_migpersonas.mig_pk || '/'
                                            || x.nlinea || '/' || x.campo02;
                     reg_migdirec.cestmig := 1;
                     reg_migdirec.sperson := 0;
                     reg_migdirec.mig_fk := reg_migpersonas.mig_pk;
                     reg_migdirec.cagente := reg_migpersonas.cagente;
                     reg_migdirec.cdomici := x.campo02;
                     reg_migdirec.ctipdir := x.campo03;
                     reg_migdirec.csiglas := x.campo04;
                     reg_migdirec.tnomvia := SUBSTR(x.campo05, 1, 200);
                     reg_migdirec.tnum1ia := x.campo06;
                     reg_migdirec.tnum2ia := x.campo07;
                     reg_migdirec.tnum3ia := x.campo08;
                     reg_migdirec.cpoblac := x.campo09;
                     reg_migdirec.localidad := x.campo10;
                     reg_migdirec.cprovin := x.campo11;

                     IF LENGTH(x.campo05) > 200
                        AND reg_migdirec.tnum1ia IS NULL THEN
                        reg_migdirec.tnum1ia := SUBSTR(x.campo05, 201, 100);
                     -- le pongo en el tnum1 el resto de info que no he podido cargar
                             -- por si viene en un "churro"
                     END IF;

                     reg_migdirec.cpostal := x.campo13;

                     BEGIN
                        INSERT INTO mig_direcciones
                             VALUES reg_migdirec
                          RETURNING ROWID
                               INTO v_rowid;

                        INSERT INTO mig_pk_emp_mig
                             VALUES (0, v_ncarga, 3, reg_migdirec.mig_pk);
                     EXCEPTION
                        WHEN DUP_VAL_ON_INDEX THEN   -- puede ser que la persona haya llegado como otro figura
                           NULL;
                     END;

                     IF reg_migseg.cdomici IS NULL
                        AND reg_migdirec.cdomici IS NOT NULL THEN
                        reg_migseg.cdomici := reg_migdirec.cdomici;

                        UPDATE mig_seguros
                           SET cdomici = reg_migdirec.cdomici
                         WHERE ncarga = v_ncarga
                           AND mig_pk = reg_migseg.mig_pk;
                     END IF;

                     v_ntraza := 3320;
                  ELSIF v_toperacion = 'MODI' THEN
                     NULL;
                  END IF;
               ELSIF x.tiporegistro = '3B' THEN   --  direccion tomadores Colombia
                  IF v_toperacion = 'ALTA' THEN
                     reg_migdirec := NULL;

                     INSERT INTO mig_cargas_tab_mig
                                 (ncarga, tab_org, tab_des, ntab)
                          VALUES (v_ncarga, 'INT_CARGA_GENERICO', 'MIG_DIRECCIONES', 1);

                     reg_migdirec.ncarga := v_ncarga;
                     -- I - JLB -
                     reg_migdirec.proceso := x.proceso;
                     reg_migdirec.mig_pk := v_ncarga || '/' || reg_migpersonas.mig_pk || '/'
                                            || x.nlinea || '/' || x.campo02;
                     reg_migdirec.cestmig := 1;
                     reg_migdirec.sperson := 0;
                     reg_migdirec.mig_fk := reg_migpersonas.mig_pk;
                     reg_migdirec.cagente := reg_migpersonas.cagente;
                     reg_migdirec.cdomici := x.campo02;
                     reg_migdirec.cpostal := x.campo20;
                     reg_migdirec.cpoblac := x.campo21;
                     reg_migdirec.cprovin := x.campo22;
                     reg_migdirec.csiglas := NULL;
                     reg_migdirec.tnomvia := NULL;
                     reg_migdirec.nnumvia := x.campo05;
                     reg_migdirec.tcomple := NULL;
                     reg_migdirec.ctipdir := x.campo03;
                     reg_migdirec.cviavp := x.campo04;
                     reg_migdirec.clitvp := x.campo06;
                     reg_migdirec.cbisvp := x.campo07;
                     reg_migdirec.corvp := x.campo08;
                     reg_migdirec.nviaadco := x.campo09;
                     reg_migdirec.clitco := x.campo10;
                     reg_migdirec.corco := x.campo11;
                     reg_migdirec.nplacaco := x.campo12;
                     reg_migdirec.cor2co := x.campo13;
                     reg_migdirec.cdet1ia := x.campo14;
                     reg_migdirec.tnum1ia := x.campo15;
                     reg_migdirec.cdet2ia := x.campo16;
                     reg_migdirec.tnum2ia := x.campo17;
                     reg_migdirec.cdet3ia := x.campo18;
                     reg_migdirec.tnum3ia := x.campo19;

                     BEGIN
                        INSERT INTO mig_direcciones
                             VALUES reg_migdirec
                          RETURNING ROWID
                               INTO v_rowid;

                        INSERT INTO mig_pk_emp_mig
                             VALUES (0, v_ncarga, 3, reg_migdirec.mig_pk);
                     EXCEPTION
                        WHEN DUP_VAL_ON_INDEX THEN   -- puede ser que la persona haya llegado como otro figura
                           NULL;
                     END;

                     IF reg_migseg.cdomici IS NULL
                        AND reg_migdirec.cdomici IS NOT NULL THEN
                        reg_migseg.cdomici := reg_migdirec.cdomici;

                        UPDATE mig_seguros
                           SET cdomici = reg_migdirec.cdomici
                         WHERE ncarga = v_ncarga
                           AND mig_pk = reg_migseg.mig_pk;
                     END IF;

                     v_ntraza := 3300;
                  ELSIF v_toperacion = 'MODI' THEN
                     NULL;
                  END IF;
               ELSIF x.tiporegistro = '4' THEN   -- asegurados y riesgos para casos de vida
                  v_ntraza := 4000;
                  v_aseg_no_riesgo := NVL(f_parproductos_v(reg_migseg.sproduc,
                                                           'ASEG_NO_RIESGO'),
                                          0);   -- BUG 0035223 20151001 MMS
                  reg_migpersonas := NULL;
                  v_dup_aseg_pol := NVL(pac_parametros.f_parproducto_t(reg_migseg.sproduc,
                                                                       'DUP_ASEG_POL'),
                                        'N');   -- BUG 0035223 20151001 MMS
                  v_no_val_aseg_pol :=
                     NVL
                        (pac_parametros.f_parproducto_t(reg_migseg.sproduc,
                                                        'NO_VALIDA_VIG_ASEG'),   -- 'N? debe valirar asegurados, 'S' NO los debe validar
                         'N');   -- BUG 0035223 20160121 MMS
                  reg_migpersonas := NULL;
                  p_control_error('AAC', 'v_toperacion: ' || v_toperacion, 'paso 1');

                  IF v_toperacion = 'ALTA' THEN
                     reg_migase := NULL;
                     reg_migrie := NULL;
                     reg_migpersonas := NULL;
                     v_ntraza := 4010;
                     reg_migase.ffecini := f_chartodate(x.campo15);

                     IF reg_migase.ffecini IS NULL THEN
                        reg_migase.ffecini := reg_migseg.fefecto;   -- si no llega informado en el ALTA pongo la fecha de efecto de la poliza
                     END IF;

                     -- si fecha de inicio de asegurado mas peque¿a que fecha de efecto de la p¿liza, error
                     IF reg_migase.ffecini < reg_migseg.fefecto THEN
--                        IF reg_migseg.sproduc = 7001
--                           AND k_tablas = 'MIG'
--                           AND pac_md_common.f_get_cxtempresa() = 17 THEN
--                           v_tdeserror :=
--                              'Migraci¿n Renta Vitalicia: la fecha de efecto del asegurado no puede ser menor que la fecha de efecto de la p¿liza.';
--                        ELSIF reg_migseg.sproduc = 7004
--                              AND k_tablas = 'MIG'
--                              AND pac_md_common.f_get_cxtempresa() = 17 THEN
--                           v_tdeserror :=
--                              'Migraci¿n Conmutaci¿n Pensional: la fecha de efecto del asegurado no puede ser menor que la fecha de efecto de la p¿liza.';
--                        ELSE
                        v_tdeserror :=
                           f_desproducto_t(v_cramo, v_cmodali, v_ctipseg, v_ccolect, 1,
                                           k_cidioma)
                           || ': La fecha de efecto del asegurado no puede ser menor que la fecha de efecto de la p¿liza.';
--                        END IF;
                        RAISE e_errdatos;
                     ELSIF reg_migase.ffecini <> reg_migseg.fefecto THEN
--                        IF reg_migseg.sproduc = 7001
--                           AND k_tablas = 'MIG'
--                           AND pac_md_common.f_get_cxtempresa() = 17 THEN
--                           v_tdeserror :=
--                              'Migraci¿n Renta Vitalicia: la fecha de efecto del asegurado es diferente a la fecha de efecto de la p¿liza.';
--                        ELSIF reg_migseg.sproduc = 7004
--                              AND k_tablas = 'MIG'
--                              AND pac_md_common.f_get_cxtempresa() = 17 THEN
--                           v_tdeserror :=
--                              'Migraci¿n Conmutaci¿n Pensional: la fecha de efecto del asegurado es diferente a la fecha de la p¿liza.';
--                        ELSE
                        v_tdeserror := f_desproducto_t(v_cramo, v_cmodali, v_ctipseg,
                                                       v_ccolect, 1, k_cidioma)
                                       || ': Error:La fecha de efecto del asegurado '
                                       || reg_migase.ffecini
                                       || ' es diferente a la de efecto de la p¿liza: '
                                       || reg_migseg.fefecto;
--                        END IF;
                        v_nnumerr := 100883;
                        RAISE e_errdatos;
                     END IF;

                     INSERT INTO mig_cargas_tab_mig
                                 (ncarga, tab_org, tab_des, ntab)
                          VALUES (v_ncarga, 'INT_CARGA_GENERICO', 'MIG_PERSONAS', 1);

                     v_ntraza := 4011;

                     -- sera el primero porque sea asegurado, tomador y riesgo
                     INSERT INTO mig_cargas_tab_mig
                                 (ncarga, tab_org, tab_des, ntab)
                          VALUES (v_ncarga, 'INT_CARGA_GENERICO', 'MIG_ASEGURADOS', 40);

                     IF v_aseg_no_riesgo = 0 THEN   -- Bug 35223 MMS 20151001
                        INSERT INTO mig_cargas_tab_mig
                                    (ncarga, tab_org, tab_des, ntab)
                             VALUES (v_ncarga, 'INT_CARGA_GENERICO', 'MIG_RIESGOS', 42);
                     END IF;

                     v_ntraza := 4020;
                     reg_migpersonas.ncarga := v_ncarga;
                     -- I - JLB -
                     reg_migpersonas.proceso := x.proceso;

                     IF x.campo03 = ''
                        OR x.campo03 IS NULL THEN
--                        IF reg_migseg.sproduc = 7001
--                           AND k_tablas = 'MIG'
--                           AND v_toperacion = 'ALTA'
--                           AND pac_md_common.f_get_cxtempresa() = 17 THEN
--                           v_tdeserror :=
--                              'Migraci¿n Renta Vitalicia: se debe informar el tipo de identificador del asegurado.';
--                        ELSIF reg_migseg.sproduc = 7004
--                              AND k_tablas = 'MIG'
--                              AND v_toperacion = 'ALTA'
--                              AND pac_md_common.f_get_cxtempresa() = 17 THEN
--                           v_tdeserror :=
--                              'Migraci¿n Conmutaci¿n Pensional: se debe informar el tipo de identificaci¿n del asegurado.';
--                        ELSE
                        v_tdeserror :=
                           f_desproducto_t(v_cramo, v_cmodali, v_ctipseg, v_ccolect, 1,
                                           k_cidioma)
                           || ': Se debe informar el tipo de identificaci¿n del asegurado.';
--                        END IF;
                        RAISE e_errdatos;
                     END IF;

                     reg_migpersonas.ctipide := x.campo03;

                     --f_buscavalor('TIPO_IDENTIFICADOR_PERSONA', x.campo03);
                     -- NIF carga fichero (detvalor 672)
                     -- Fi Bug 0017569
                     IF x.campo04 = ''
                        OR x.campo04 IS NULL THEN
--                        IF reg_migseg.sproduc = 7001
--                           AND k_tablas = 'MIG'
--                           AND v_toperacion = 'ALTA'
--                           AND pac_md_common.f_get_cxtempresa() = 17 THEN
--                           v_tdeserror :=
--                              'Migraci¿n Renta Vitalicia: se debe informar el n¿mero de identificaci¿n del asegurado.';
--                        ELSIF reg_migseg.sproduc = 7004
--                              AND k_tablas = 'MIG'
--                              AND v_toperacion = 'ALTA'
--                              AND pac_md_common.f_get_cxtempresa() = 17 THEN
--                           v_tdeserror :=
--                              'Migraci¿n Conmutaci¿n Pensional: se debe informar el n¿mero de identificaci¿n del asegurado.';
--                        ELSE
                        v_tdeserror :=
                           f_desproducto_t(v_cramo, v_cmodali, v_ctipseg, v_ccolect, 1,
                                           k_cidioma)
                           || ': Se debe informar el n¿mero de identificaci¿n del asegurado.';
--                        END IF;
                        RAISE e_errdatos;
                     END IF;

                     reg_migpersonas.nnumide := x.campo04;
                     reg_migpersonas.tdigitoide := x.campo05;
                     --  reg_migpersonas.mig_pk := v_ncarga || '/' || x.nlinea || '/'
                     --                            || reg_migpersonas.nnumide;
                     reg_migpersonas.mig_pk := v_ncarga || '/' || reg_migpersonas.ctipide
                                               || '/' || reg_migpersonas.nnumide;
                     v_ntraza := 4030;
                     reg_migpersonas.cestmig := 1;
                     reg_migpersonas.idperson := 0;

                     IF x.campo06 = ''
                        OR x.campo06 IS NULL THEN
--                        IF reg_migseg.sproduc = 7001
--                           AND k_tablas = 'MIG'
--                           AND v_toperacion = 'ALTA'
--                           AND pac_md_common.f_get_cxtempresa() = 17 THEN
--                           v_tdeserror :=
--                              'Migraci¿n Renta Vitalicia: se debe informar el tipo de persona del asegurado.';
--                        ELSIF reg_migseg.sproduc = 7004
--                              AND k_tablas = 'MIG'
--                              AND v_toperacion = 'ALTA'
--                              AND pac_md_common.f_get_cxtempresa() = 17 THEN
--                           v_tdeserror :=
--                              'Migraci¿n Conmutaci¿n Pensional: se debe informar el tipo de persona del asegurado.';
--                        ELSE
                        v_tdeserror := f_desproducto_t(v_cramo, v_cmodali, v_ctipseg,
                                                       v_ccolect, 1, k_cidioma)
                                       || ': Se debe informar el tipo de persona del asegurado.';
--                        END IF;
                        RAISE e_errdatos;
                     END IF;

                     reg_migpersonas.cpertip := f_buscavalor('TIPUS PERSONA', x.campo06);

                     IF x.campo07 = ''
                        OR x.campo07 IS NULL THEN
--                        IF reg_migseg.sproduc = 7001
--                           AND k_tablas = 'MIG'
--                           AND v_toperacion = 'ALTA'
--                           AND pac_md_common.f_get_cxtempresa() = 17 THEN
--                           v_tdeserror :=
--                              'Migraci¿n Renta Vitalicia: se debe informar el apellido 1 del asegurado.';
--                        ELSIF reg_migseg.sproduc = 7004
--                              AND k_tablas = 'MIG'
--                              AND v_toperacion = 'ALTA'
--                              AND pac_md_common.f_get_cxtempresa() = 17 THEN
--                           v_tdeserror :=
--                              'Migraci¿n Conmutaci¿n Pensional: se debe informar el apellido 1 del asegurado.';
--                        ELSE
                        v_tdeserror := f_desproducto_t(v_cramo, v_cmodali, v_ctipseg,
                                                       v_ccolect, 1, k_cidioma)
                                       || ': Se debe informar el apellido 1 del asegurado.';
--                        END IF;
                        RAISE e_errdatos;
                     END IF;

                     reg_migpersonas.tapelli1 := x.campo07;
                     reg_migpersonas.tapelli2 := x.campo08;
                     reg_migpersonas.cagente := ff_agente_cpervisio(reg_migseg.cagente);
                     reg_migpersonas.cidioma := k_cidioma;
                     reg_migpersonas.tnombre := x.campo09;
                     reg_migpersonas.tnombre2 := x.campo10;
                     v_ntraza := 4060;
                     reg_migpersonas.csexper := f_buscavalor('SEXO', x.campo11);
                     reg_migpersonas.swpubli := 0;
                     reg_migpersonas.fnacimi := f_chartodate(x.campo12);

                     IF reg_migpersonas.fnacimi IS NOT NULL
                        AND TRUNC(reg_migpersonas.fnacimi) > TRUNC(f_sysdate) THEN
--                        IF reg_migseg.sproduc = 7001
--                           AND k_tablas = 'MIG'
--                           AND pac_md_common.f_get_cxtempresa() = 17 THEN
--                           v_tdeserror :=
--                              'Migraci¿n Renta Vitalicia: la fecha de nacimiento del asegurado no puede ser superior a la fecha de hoy.';
--                        ELSIF reg_migseg.sproduc = 7004
--                              AND k_tablas = 'MIG'
--                              AND pac_md_common.f_get_cxtempresa() = 17 THEN
--                           v_tdeserror :=
--                              'Migraci¿n Conmutaci¿n Pensional: la fecha de nacimiento del asegurado no puede ser superior a la fecha de hoy.';
--                        ELSE
                        v_tdeserror :=
                           f_desproducto_t(v_cramo, v_cmodali, v_ctipseg, v_ccolect, 1,
                                           k_cidioma)
                           || ': La fecha de nacimiento del asegurado no puede ser superor a la fecha de hoy.';
--                        END IF;
                        RAISE e_errdatos;
                        v_nnumerr := 120058;
                     END IF;

                     reg_migpersonas.cnacio := x.campo13;
                     reg_migpersonas.cpais := x.campo13;
                     -- pais de residencia = a nacionalidad
                     reg_migpersonas.cestper := 0;
                     reg_migpersonas.cestciv := x.campo14;
                     reg_migpersonas.tdigitoide := x.campo05;
                     reg_migpersonas.tnumtel := x.campo17;
                     reg_migpersonas.tnummov := x.campo18;
                     reg_migpersonas.temail := x.campo19;
                     v_ntraza := 4070;

                     IF reg_migpersonas.cpertip = 1
                        AND reg_migpersonas.fnacimi IS NULL THEN
--                        IF reg_migseg.sproduc = 7001
--                           AND k_tablas = 'MIG'
--                           AND pac_md_common.f_get_cxtempresa() = 17 THEN
--                           v_tdeserror :=
--                              'Migraci¿n Renta Vitalicia: si el tipo de persona del asegurado es natural se debe informar su fecha de nacimiento.';
--                        ELSIF reg_migseg.sproduc = 7004
--                              AND k_tablas = 'MIG'
--                              AND pac_md_common.f_get_cxtempresa() = 17 THEN
--                           v_tdeserror :=
--                              'Migraci¿n Conmutaci¿n Pensional: si el tipo de persona del asegurado es natural se debe informar su fecha de nacimiento.';
--                        ELSE
                        v_tdeserror :=
                           f_desproducto_t(v_cramo, v_cmodali, v_ctipseg, v_ccolect, 1,
                                           k_cidioma)
                           || ': Si el tipo de persona del asegurado es natural se debe informar su fecha de nacimiento.';
--                        END IF;
                        v_nnumerr := 151133;
                        RAISE e_errdatos;
                     ELSIF reg_migpersonas.cpertip = 1
                           AND reg_migpersonas.csexper IS NULL THEN
--                        IF reg_migseg.sproduc = 7001
--                           AND k_tablas = 'MIG'
--                           AND pac_md_common.f_get_cxtempresa() = 17 THEN
--                           v_tdeserror :=
--                              'Migraci¿n Renta Vitalicia: si el tipo de persona del asegurado es natural se debe informar su sexo.';
--                        ELSIF reg_migseg.sproduc = 7004
--                              AND k_tablas = 'MIG'
--                              AND pac_md_common.f_get_cxtempresa() = 17 THEN
--                           v_tdeserror :=
--                              'Migraci¿n Conmutaci¿n Pensional: si el tipo de persona del asegurado es natural se debe informar su sexo.';
--                        ELSE
                        v_tdeserror :=
                           f_desproducto_t(v_cramo, v_cmodali, v_ctipseg, v_ccolect, 1,
                                           k_cidioma)
                           || ': Si el tipo de persona del asegurado es natural se debe informar su sexo.';
--                        END IF;
                        v_nnumerr := 151133;
                        RAISE e_errdatos;
                     END IF;

                     --
                     v_ntraza := 4075;

                     BEGIN
                        INSERT INTO mig_personas
                             VALUES reg_migpersonas
                          RETURNING ROWID
                               INTO v_rowid;

                        v_ntraza := 4080;

                        INSERT INTO mig_pk_emp_mig
                             VALUES (0, v_ncarga, 3, reg_migpersonas.mig_pk);
                     EXCEPTION
                        WHEN DUP_VAL_ON_INDEX THEN
                           v_tdeserror := 'Error: El orden de asegurados no es correcto.';
                     END;   -- si da error de que ya existe, porque ha llegado antes la persona

                     --
                     IF reg_migseg.mig_fk = '-1' THEN
                        reg_migseg.mig_fk := reg_migpersonas.mig_pk;

                        -- lo pongo como tomador de momento, si llega el registro tomador lo machacar¿
                        UPDATE mig_seguros
                           SET mig_fk = reg_migpersonas.mig_pk
                         WHERE ncarga = v_ncarga
                           AND mig_pk = reg_migseg.mig_pk;
                     END IF;

                     v_ntraza := 4090;
                     -- Introduzco asegurado
                     reg_migase.sseguro := 0;
                     reg_migase.sperson := reg_migpersonas.idperson;
                     reg_migase.norden := x.campo02;
                     v_ntraza := 4100;
                     --reg_migase.ffecini := f_chartodate(x.campo15, 'DD/MM/YYYY');
                     --reg_migase.ffecfin := f_chartodate(x.campo16, 'DD/MM/YYYY');
                     reg_migase.ffecfin := NULL;
                     reg_migase.ffecmue := NULL;   --Revisar
                     reg_migase.mig_pk := reg_migseg.mig_pk || '/' || reg_migase.norden;
                     reg_migase.mig_fk := reg_migpersonas.mig_pk;
                     reg_migase.mig_fk2 := reg_migseg.mig_pk;
                     reg_migase.cestmig := 1;
                     reg_migase.ncarga := v_ncarga;
                     --           reg_migase.cdomici := v_cdomici;
                     v_ntraza := 4110;

                     IF NVL(f_parproductos_v(reg_migseg.sproduc, 'VALIDA_EDAD_ASEG_PRO'), 1) =
                                                                                              1
                        AND k_tablas <> 'MIG' THEN   -- jlb si es migraci¿ no valido la edad..
                        v_nnumerr :=
                           pac_md_validaciones.f_controledad(reg_migpersonas.fnacimi,
                                                             reg_migase.ffecini,
                                                             reg_migseg.sproduc, NULL,
                                                             mensajes);   -- Bug 0025584 - MMS - 23/01/2013

                        IF v_nnumerr <> 0 THEN
                           -- v_nnumerr := 9001498;
                           -- v_tdeserror := 'Error: en edad del asegurado.';
                             --RAISE e_errdatos;
                           IF mensajes IS NOT NULL THEN
                              FOR i IN mensajes.FIRST .. mensajes.LAST LOOP
                                 v_tdeserror := mensajes(i).terror;
                                 v_nnumerr := mensajes(i).cerror;
                                 RAISE e_errdatos;
                              END LOOP;
                           END IF;
                        END IF;
                     END IF;

                     --
                     BEGIN
                        INSERT INTO mig_asegurados
                             VALUES reg_migase
                          RETURNING ROWID
                               INTO v_rowid;

                        INSERT INTO mig_pk_emp_mig
                             VALUES (0, v_ncarga, 3, reg_migase.mig_pk);
                     EXCEPTION
                        WHEN DUP_VAL_ON_INDEX THEN
                           NULL;
                     END;   -- si da error de que ya existe, porque ha llegado antes la persona

                     v_ntraza := 4120;
                     -- Informo el riesgo
                     reg_migrie.nriesgo := x.campo02;
                     reg_migrie.sseguro := 0;
                     reg_migrie.nmovima := 1;
                     reg_migrie.fefecto := reg_migase.ffecini;   -- f_chartodate(x.campo15, 'DD/MM/YYYY');
                     reg_migrie.sperson := reg_migpersonas.idperson;
                     --  IF x.campo16 IS NULL THEN
                     reg_migrie.nmovimb := NULL;
                     --  ELSE
                     --reg_migrie.nmovimb := 1;
                     --  END IF;
                     v_ntraza := 4130;
                     --reg_migrie.fanulac := f_chartodate(x.campo16, 'DD/MM/YYYY');
                     reg_migrie.fanulac := NULL;
                     reg_migrie.tnatrie := NULL;
                     v_ntraza := 3140;
                     reg_migrie.mig_pk := reg_migseg.mig_pk || '/' || reg_migrie.nriesgo;
                     reg_migrie.mig_fk := reg_migpersonas.mig_pk;
                     reg_migrie.mig_fk2 := reg_migseg.mig_pk;
                     reg_migrie.cestmig := 1;
                     reg_migrie.sperson := reg_migpersonas.idperson;
                     reg_migrie.ncarga := v_ncarga;
                     v_ntraza := 4150;

                     IF v_aseg_no_riesgo = 0 THEN   -- Bug 35223 MMS 20151001
                        BEGIN
                           INSERT INTO mig_riesgos
                                VALUES reg_migrie
                             RETURNING ROWID
                                  INTO v_rowid;

                           INSERT INTO mig_pk_emp_mig
                                VALUES (0, v_ncarga, 41, reg_migrie.mig_pk);
                        EXCEPTION
                           WHEN OTHERS THEN
                              --  if k_tablas <> 'MIG' then
                               --  raise;
                               -- end if;
                              IF reg_migpersonas.mig_pk IS NOT NULL THEN
                                 UPDATE mig_riesgos
                                    SET tnatrie = NULL,
                                        sperson = reg_migpersonas.idperson,
                                        mig_fk = reg_migpersonas.mig_pk;
                              END IF;
                        END;

                        SELECT COUNT('x')
                          INTO v_numriesgos
                          FROM mig_riesgos
                         WHERE mig_fk2 = reg_migrie.mig_fk2
                           AND ncarga = reg_migrie.ncarga;   --- miro cuantos riesgos hay

                        IF reg_migrie.nriesgo > v_numriesgos THEN
                           v_nnumerr := 110169;
                           v_tdeserror := 'Error:El asegurado con n¿ riesgo en fichero '
                                          || x.campo02
                                          || ' no sigue el orden secuencial correcto.';
                           RAISE e_errdatos;
                        END IF;
                     END IF;
                  ELSIF v_toperacion = 'MODI' THEN
                     v_ntraza := 4210;

                     IF f_chartodate(x.campo15) IS NULL THEN
                        v_nnumerr := 9902711;
                        v_tdeserror := 'Error: Fecha inicio asegurado.';
                        RAISE e_errdatos;
                     END IF;

                     -- BUG 0035223 20150121 MMS  ponemos el IF
                     IF v_no_val_aseg_pol = 'N' THEN   -- 'N? debe validar asegurados 'S' no los debe validar
                        -- si fecha de inicio de asegurado mas peque¿a que fecha de efecto de la p¿liza, error
                        IF f_chartodate(x.campo15) < v_fefecto THEN
                           v_nnumerr := 100883;
                           v_tdeserror := 'Error:La fecha de efecto del asegurado '
                                          || f_chartodate(x.campo15)
                                          || ' es menor a la de efecto de la p¿liza: '
                                          || v_fefecto;
                           RAISE e_errdatos;
                        END IF;
                     END IF;

                     v_ntraza := 4212;

                     BEGIN
                        --f_buscavalor('TIPO_IDENTIFICADOR_PERSONA', x.campo03);
                        SELECT per.sperson
                          INTO wspersonnueva
                          FROM estper_personas per, estper_detper pd, estassegurats ase,
                               estseguros seg
                         WHERE seg.sseguro = v_sseguroest
                           AND ase.sseguro = seg.sseguro
                           AND((ase.nriesgo = x.campo02
                                AND v_aseg_no_riesgo = 0)
                               OR(ase.nriesgo = 1
                                  AND v_aseg_no_riesgo = 1))   -- Bug 35223 MMS 20151001
                           AND((v_dup_aseg_pol = 'S'
                                AND ase.nriesgo = x.campo02)
                               OR(v_dup_aseg_pol = 'N'))
                           AND ase.sperson = per.sperson
                           AND per.sperson = pd.sperson
                           AND per.ctipide = x.campo03
                           AND nnumide = x.campo04
                           AND nnumide <> 'Z'
                           AND pd.cagente = ff_agente_cpervisio(reg_migseg.cagente)
                           AND NVL(tapelli1, '*') = NVL(x.campo07, '*')
                           AND NVL(tapelli2, '*') = NVL(x.campo08, '*')
                           AND NVL(tnombre1, '*') = NVL(x.campo09, '*')
                           AND NVL(tnombre2, '*') = NVL(x.campo10, '*');
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           wspersonnueva := NULL;
                        WHEN OTHERS THEN
                           p_tab_error(f_sysdate, f_user, 'pac_cargas_generico.modi(4)', 3,
                                       'Buscando rieso-asegurados others.',
                                       reg_migseg.cagente || '-riesgo:' || x.campo02
                                       || '- nnumide:' || x.campo04 || '-->' || SQLCODE,
                                       10);
                     END;

                     IF wspersonnueva IS NULL THEN
                        v_ntraza := 4220;
                        v_ncarga2 := f_next_carga;
                        reg_migpersonas.ncarga := v_ncarga2;
                        -- I - JLB -
                        reg_migpersonas.proceso := x.proceso;
                        reg_migpersonas.ctipide := x.campo03;
                        --f_buscavalor('TIPO_IDENTIFICADOR_PERSONA', x.campo03);
                        reg_migpersonas.nnumide := x.campo04;
                        reg_migpersonas.tdigitoide := x.campo05;
                        reg_migpersonas.mig_pk :=
                                v_ncarga2 || '/' || x.nlinea || '/' || reg_migpersonas.nnumide;
                        v_ntraza := 4230;
                        reg_migpersonas.cestmig := 1;
                        reg_migpersonas.idperson := 0;
                        reg_migpersonas.cpertip := f_buscavalor('TIPUS PERSONA', x.campo06);
                        reg_migpersonas.tapelli1 := x.campo07;
                        reg_migpersonas.tapelli2 := x.campo08;
                        reg_migpersonas.cagente := ff_agente_cpervisio(reg_migseg.cagente);
                        reg_migpersonas.cidioma := k_cidioma;
                        reg_migpersonas.tnombre := x.campo09;
                        reg_migpersonas.tnombre2 := x.campo10;
                        v_ntraza := 4260;
                        reg_migpersonas.csexper := f_buscavalor('SEXO', x.campo11);
                        reg_migpersonas.swpubli := 0;
                        reg_migpersonas.fnacimi := f_chartodate(x.campo12);

                        IF reg_migpersonas.fnacimi IS NOT NULL THEN
                           IF TRUNC(reg_migpersonas.fnacimi) > TRUNC(f_sysdate) THEN
                              --La Fecha de nacimiento no puede ser superior a la fecha de hoy.
                              v_tdeserror := 'Error fecha nacimiento';
                              v_nnumerr := 120058;
                              RAISE e_errdatos;
                           END IF;
                        END IF;

                        reg_migpersonas.cestper := 0;
                        reg_migpersonas.cnacio := x.campo13;
                        reg_migpersonas.cpais := x.campo13;
                        -- pais de residencia = a nacionalidad
                        reg_migpersonas.cestciv := x.campo14;
                        reg_migpersonas.tdigitoide := x.campo05;
                        reg_migpersonas.tnumtel := x.campo17;
                        reg_migpersonas.tnummov := x.campo18;
                        reg_migpersonas.temail := x.campo19;

                        INSERT INTO mig_personas
                             VALUES reg_migpersonas
                          RETURNING ROWID
                               INTO v_rowid;

                        INSERT INTO mig_pk_emp_mig
                             VALUES (0, v_ncarga2, 1, reg_migpersonas.mig_pk);

                        INSERT INTO mig_cargas
                                    (ncarga, cempres, finiorg, ffinorg, ID, estorg)
                             VALUES (v_ncarga2, k_cempresa, f_sysdate, f_sysdate, v_id, NULL);

                        INSERT INTO mig_cargas_tab_mig
                                    (ncarga, tab_org, tab_des, ntab)
                             VALUES (v_ncarga2, 'INT_CARGA_GENERICO', 'MIG_PERSONAS', 1);

                        v_nnumerr := f_lanza_migracion(v_id, v_ncarga2);

                        IF v_nnumerr NOT IN(0, 2, 4) THEN   -- si ha habido error
                           ROLLBACK;

                           IF k_cpara_error <> 1 THEN
                              v_ntipoerror := 4;
                           -- para que continue con la siguiente linea.
                           ELSE
                              v_ntipoerror := 1;   -- para la carga
                              RAISE e_salir;
                           END IF;
                        END IF;

                        BEGIN
                           SELECT idperson
                             INTO wspersonnueva
                             FROM mig_personas
                            WHERE ncarga = v_ncarga2;
                        EXCEPTION
                           WHEN OTHERS THEN
                              v_nnumerr := 9001557;
                              v_tdeserror := 'Error ' || SQLCODE
                                             || 'No se encuentra el assegurado creado. NIF: '
                                             || x.campo04;
                              RAISE e_errdatos;
                        END;

                        IF v_aseg_no_riesgo = 0 THEN   -- Bug 35223 MMS 20151001
                           SELECT NVL(MAX(norden), 0) + 1
                             INTO v_norden
                             FROM estassegurats
                            WHERE sseguro = v_sseguroest
                              AND nriesgo = x.campo02;

                           vffecini := f_chartodate(x.campo15);
                           -- vffecfin := f_chartodate(x.campo16, 'DD/MM/YYYY');
                           vffecfin := NULL;

                           INSERT INTO estassegurats
                                       (sseguro, sperson, norden, cdomici, ffecini,
                                        ffecfin, ffecmue, nriesgo, fecretroact, cparen)
                                VALUES (v_sseguroest, wspersonnueva, v_norden, NULL, vffecini,
                                        vffecfin, NULL, x.campo02, NULL, NULL);

                           BEGIN
                              INSERT INTO estriesgos
                                          (nriesgo, sseguro, nmovima, fefecto,
                                           sperson,
                                           nmovimb, fanulac)
                                   VALUES (x.campo02, v_sseguroest, v_nmovimi, vffecini,
                                           wspersonnueva,
                                           DECODE(vffecfin, NULL, NULL, v_nmovimi), vffecfin);
                           EXCEPTION
                              WHEN DUP_VAL_ON_INDEX THEN
                                 v_nnumerr := 110169;
                                 v_tdeserror :=
                                    'Error:El asegurado con n¿ riesgo en fichero '
                                    || x.campo02 || ' ya esta insertado en el sistema';
                                 RAISE e_errdatos;
                           END;

                           SELECT COUNT('x')
                             INTO v_numriesgos
                             FROM estriesgos
                            WHERE sseguro = v_sseguroest;   --- miro cuantos riesgos hay

                           IF x.campo02 > v_numriesgos THEN
                              v_nnumerr := 110169;
                              v_tdeserror := 'Error:El asegurado con n¿ riesgo en fichero '
                                             || x.campo02
                                             || ' no sigue el orden secuencial correcto.';
                              RAISE e_errdatos;
                           END IF;
                        ELSE   -- inicio Bug 35223 MMS 20151001
                           SELECT NVL(MAX(norden), 0) + 1
                             INTO v_norden
                             FROM estassegurats
                            WHERE sseguro = v_sseguroest
                              AND nriesgo = 1;

                           vffecini := f_chartodate(x.campo15);

                           -- BUG 0035223 20150121 MMS  ponemos el IF
                           IF v_no_val_aseg_pol = 'N' THEN   -- 'N? debe validar asegurados 'S' no los debe validar
                              vffecfin := NULL;
                           ELSE
                              vffecfin := f_chartodate(x.campo16);
                           END IF;

                           INSERT INTO estassegurats
                                       (sseguro, sperson, norden, cdomici, ffecini,
                                        ffecfin, ffecmue, nriesgo, fecretroact, cparen)
                                VALUES (v_sseguroest, wspersonnueva, v_norden, NULL, vffecini,
                                        vffecfin, NULL, 1, NULL, NULL);
                        END IF;   -- Fin Bug 35223 MMS 20151001
                     ELSE
                        vffecini := f_chartodate(x.campo15);
                        vffecfin := f_chartodate(x.campo16);

                        --                        vfanulac :=
                        --                      vfefecto := f_chartodate(x.campo14, 'DD/MM/YYYY',v_nnumerr, v_tdeserror);
                        IF v_aseg_no_riesgo = 0 THEN   -- Bug 35223 MMS 20151001
                           UPDATE estassegurats
                              SET ffecfin = vffecfin,
                                  ffecini = NVL(vffecini, ffecini)
                            WHERE sseguro = v_sseguroest
                              AND nriesgo = x.campo02
                              AND sperson = wspersonnueva;

                           UPDATE estriesgos
                              SET nmovimb = DECODE(vffecfin, NULL, NULL, v_nmovimi),
                                  fanulac = vffecfin,
                                  fefecto = NVL(vffecini, fefecto)
                            WHERE sseguro = v_sseguroest
                              AND nriesgo = x.campo02
                              AND sperson = wspersonnueva;
                        ELSE
                           UPDATE estassegurats
                              SET ffecfin = vffecfin,
                                  ffecini = NVL(vffecini, ffecini)
                            WHERE sseguro = v_sseguroest
                              AND nriesgo = 1
                              AND sperson = wspersonnueva;
                        END IF;
                     END IF;   -- existe
                  END IF;   -- fin modi
               ELSIF x.tiporegistro = '4A' THEN   --  direccion tomadores Chile
                  IF v_toperacion = 'ALTA' THEN
                     reg_migdirec := NULL;

                     INSERT INTO mig_cargas_tab_mig
                                 (ncarga, tab_org, tab_des, ntab)
                          VALUES (v_ncarga, 'INT_CARGA_GENERICO', 'MIG_DIRECCIONES', 1);

                     reg_migdirec.ncarga := v_ncarga;
                     -- I - JLB -
                     reg_migdirec.proceso := x.proceso;
                     reg_migdirec.mig_pk := v_ncarga || '/' || reg_migpersonas.mig_pk || '/'
                                            || x.nlinea || '/' || x.campo02;
                     reg_migdirec.cestmig := 1;
                     reg_migdirec.sperson := 0;
                     reg_migdirec.mig_fk := reg_migpersonas.mig_pk;
                     reg_migdirec.cagente := reg_migpersonas.cagente;
                     reg_migdirec.cdomici := x.campo02;
                     reg_migdirec.ctipdir := x.campo03;
                     reg_migdirec.csiglas := x.campo04;
                     reg_migdirec.tnomvia := SUBSTR(x.campo05, 1, 200);
                     --reg_migdirec.nnumvia := x.campo06;
                     reg_migdirec.tnum1ia := x.campo06;
                     reg_migdirec.tnum2ia := x.campo07;
                     reg_migdirec.tnum3ia := x.campo08;
                     reg_migdirec.cpoblac := x.campo09;
                     reg_migdirec.localidad := x.campo10;
                     reg_migdirec.cprovin := x.campo11;

                     IF LENGTH(x.campo05) > 200
                        AND reg_migdirec.tnum1ia IS NULL THEN
                        reg_migdirec.tnum1ia := SUBSTR(x.campo05, 201, 100);
                     -- le pongo en el tnum1 el resto de info que no he podido cargar
                             -- por si viene en un "churro"
                     END IF;

                     reg_migdirec.cpostal := x.campo13;

                     INSERT INTO mig_direcciones
                          VALUES reg_migdirec
                       RETURNING ROWID
                            INTO v_rowid;

                     INSERT INTO mig_pk_emp_mig
                          VALUES (0, v_ncarga, 3, reg_migdirec.mig_pk);

                     v_ntraza := 4320;
                  ELSIF v_toperacion = 'MODI' THEN
                     NULL;
                  END IF;
               ELSIF x.tiporegistro = '4B' THEN   --  direccion tomadores Colombia
                  IF v_toperacion = 'ALTA' THEN
                     reg_migdirec := NULL;

                     INSERT INTO mig_cargas_tab_mig
                                 (ncarga, tab_org, tab_des, ntab)
                          VALUES (v_ncarga, 'INT_CARGA_GENERICO', 'MIG_DIRECCIONES', 1);

                     reg_migdirec.ncarga := v_ncarga;
                     -- I - JLB -
                     reg_migdirec.proceso := x.proceso;
                     reg_migdirec.mig_pk := v_ncarga || '/' || reg_migpersonas.mig_pk || '/'
                                            || x.nlinea || '/' || x.campo02;
                     reg_migdirec.cestmig := 1;
                     reg_migdirec.sperson := 0;
                     reg_migdirec.mig_fk := reg_migpersonas.mig_pk;
                     reg_migdirec.cagente := reg_migpersonas.cagente;
                     reg_migdirec.cdomici := x.campo02;
                     reg_migdirec.cpostal := x.campo20;
                     reg_migdirec.cpoblac := x.campo21;
                     reg_migdirec.cprovin := x.campo22;
                     reg_migdirec.csiglas := NULL;
                     reg_migdirec.tnomvia := NULL;
                     reg_migdirec.nnumvia := x.campo05;
                     reg_migdirec.tcomple := NULL;
                     reg_migdirec.ctipdir := x.campo03;
                     reg_migdirec.cviavp := x.campo04;
                     reg_migdirec.clitvp := x.campo06;
                     reg_migdirec.cbisvp := x.campo07;
                     reg_migdirec.corvp := x.campo08;
                     reg_migdirec.nviaadco := x.campo09;
                     reg_migdirec.clitco := x.campo10;
                     reg_migdirec.corco := x.campo11;
                     reg_migdirec.nplacaco := x.campo12;
                     reg_migdirec.cor2co := x.campo13;
                     reg_migdirec.cdet1ia := x.campo14;
                     reg_migdirec.tnum1ia := x.campo15;
                     reg_migdirec.cdet2ia := x.campo16;
                     reg_migdirec.tnum2ia := x.campo17;
                     reg_migdirec.cdet3ia := x.campo18;
                     reg_migdirec.tnum3ia := x.campo19;

                     INSERT INTO mig_direcciones
                          VALUES reg_migdirec
                       RETURNING ROWID
                            INTO v_rowid;

                     INSERT INTO mig_pk_emp_mig
                          VALUES (0, v_ncarga, 3, reg_migdirec.mig_pk);

                     IF reg_migase.cdomici IS NULL
                        AND reg_migdirec.cdomici IS NOT NULL THEN
                        reg_migase.cdomici := reg_migdirec.cdomici;

                        UPDATE mig_asegurados
                           SET cdomici = reg_migdirec.cdomici
                         WHERE ncarga = v_ncarga
                           AND mig_pk = reg_migase.mig_pk;
                     END IF;

                     v_ntraza := 4300;
                  ELSIF v_toperacion = 'MODI' THEN
                     NULL;
                  END IF;
               -- REGISTRO 5DESC - Riesgo descripctivo
               ELSIF x.tiporegistro = '5DES' THEN
                  --
                  v_ntraza := 5000;

                  IF v_toperacion = 'ALTA' THEN
                     INSERT INTO mig_cargas_tab_mig
                                 (ncarga, tab_org, tab_des, ntab)
                          VALUES (v_ncarga, 'INT_CARGA_GENERICO', 'MIG_RIESGOS', 42);

                     v_ntraza := 5010;
                     -- Informo el riesgo
                     reg_migrie.nriesgo := x.campo02;
                     reg_migrie.sseguro := 0;
                     reg_migrie.nmovima := 1;
                     reg_migrie.fefecto := NVL(f_chartodate(x.campo04), reg_migseg.fefecto);
                     reg_migrie.sperson := NULL;
                     --  IF x.campo16 IS NULL THEN
                     reg_migrie.nmovimb := NULL;
                     --  ELSE
                     --reg_migrie.nmovimb := 1;
                     --  END IF;
                     v_ntraza := 5020;
                     reg_migrie.fanulac := f_chartodate(x.campo05);

                     IF reg_migrie.fanulac IS NULL THEN
                        reg_migrie.nmovimb := NULL;
                     ELSE
                        reg_migrie.nmovimb := 1;
                     END IF;

                     reg_migrie.tnatrie := x.campo03;
                     v_ntraza := 5030;
                     reg_migrie.mig_pk := reg_migseg.mig_pk || '/' || reg_migrie.nriesgo;
                     reg_migrie.mig_fk := NULL;
                     reg_migrie.mig_fk2 := reg_migseg.mig_pk;
                     reg_migrie.cestmig := 1;
                     reg_migrie.sperson := NULL;
                     reg_migrie.ncarga := v_ncarga;
                     v_ntraza := 5040;

                     BEGIN
                        INSERT INTO mig_riesgos
                             VALUES reg_migrie
                          RETURNING ROWID
                               INTO v_rowid;

                        INSERT INTO mig_pk_emp_mig
                             VALUES (0, v_ncarga, 42, reg_migrie.mig_pk);
--
                     EXCEPTION
                        WHEN OTHERS THEN
                           -- if k_tablas <> 'MIG' then
                           --  raise;
                           -- end if;
                           UPDATE mig_riesgos
                              SET tnatrie = x.campo03,
                                  sperson = NULL,
                                  mig_fk = NULL
                            WHERE mig_pk = reg_migrie.mig_pk;
                     END;

                     SELECT COUNT('x')
                       INTO v_numriesgos
                       FROM mig_riesgos
                      WHERE mig_fk2 = reg_migrie.mig_fk2
                        AND ncarga = reg_migrie.ncarga;   --- miro cuantos riesgos hay

                     IF reg_migrie.nriesgo > v_numriesgos THEN
                        v_nnumerr := 110169;
                        v_tdeserror := 'Error:El asegurado con n¿ riesgo en fichero '
                                       || x.campo02
                                       || ' no sigue el orden secuencial correcto.';
                        RAISE e_errdatos;
                     END IF;
                  ELSIF v_toperacion = 'MODI' THEN
                     NULL;
                  END IF;
               -- REGISTRO 5DET - DETALLE DE RIESGOS
                    --
               ELSIF x.tiporegistro = '5DET' THEN
                  v_ntraza := 5500;

                  IF v_toperacion = 'ALTA' THEN
                     INSERT INTO mig_cargas_tab_mig
                                 (ncarga, tab_org, tab_des, ntab)
                          VALUES (v_ncarga, 'INT_CARGA_GENERICO', 'MIG_DETALLE_RIESGOS', 45);

                     v_ntraza := 5510;
                     -- Informo el riesgo
                     reg_migdetrie.ncarga := v_ncarga;
                     reg_migdetrie.cestmig := 1;
                     reg_migdetrie.nmovimi := x.campo01;
                     reg_migdetrie.nriesgo := x.campo02;
                     reg_migdetrie.mig_pk := reg_migseg.mig_pk || '/' || '5DET' || '/'
                                             || x.nlinea;
                     reg_migdetrie.mig_fk := reg_migseg.mig_pk || '/' || reg_migdetrie.nmovimi;
                     reg_migdetrie.sseguro := 0;
                     reg_migdetrie.nif := x.campo03;
                     reg_migdetrie.nombre := x.campo04;
                     reg_migdetrie.apellidos := x.campo05;
                     reg_migdetrie.csexo := f_buscavalor('SEXO', x.campo06);
                     reg_migdetrie.fnacim := f_chartodate(x.campo07);
                     reg_migdetrie.falta := f_chartodate(x.campo08);
                     reg_migdetrie.fbaja := f_chartodate(x.campo09);

                     BEGIN
                        INSERT INTO mig_detalle_riesgos
                             VALUES reg_migdetrie
                          RETURNING ROWID
                               INTO v_rowid;

                        INSERT INTO mig_pk_emp_mig
                             VALUES (0, v_ncarga, 45, reg_migdetrie.mig_pk);
--
                     EXCEPTION
                        WHEN OTHERS THEN
                           NULL;
                     END;
                  ELSIF v_toperacion = 'MODI' THEN
                     IF v_cmotmov_965 = '965' THEN   -- suplemento asegurados total, borro los asegurados innominados y cargar¿ nuevos
                        DELETE FROM estasegurados_innom
                              WHERE sseguro = v_sseguroest
                                AND nmovimi = v_nmovimi
                                AND nriesgo = x.campo02;

                        v_cmotmov_965 := NULL;   -- para que no vuelva a borrar,solo la primera vez
                     END IF;

                     BEGIN
                        SELECT NVL(MAX(norden), 0) + 1
                          INTO v_norden
                          FROM estasegurados_innom
                         WHERE sseguro = v_sseguroest
                           AND nmovimi = v_nmovimi
                           AND nriesgo = x.campo02;

                        reg_migdetrie.csexo := f_buscavalor('SEXO', x.campo06);
                        reg_migdetrie.fnacim := f_chartodate(x.campo07);
                        reg_migdetrie.falta := f_chartodate(x.campo08);
                        reg_migdetrie.fbaja := f_chartodate(x.campo09);

                        INSERT INTO estasegurados_innom
                                    (sseguro, nmovimi, nriesgo, norden, nif,
                                     nombre, apellidos, csexo,
                                     fnacim, falta,
                                     fbaja)
                             VALUES (v_sseguroest, v_nmovimi, x.campo02, v_norden, x.campo03,
                                     x.campo04, x.campo05, reg_migdetrie.csexo,
                                     reg_migdetrie.fnacim, reg_migdetrie.falta,
                                     reg_migdetrie.fbaja);
                     EXCEPTION
                        WHEN OTHERS THEN
                           v_nnumerr := 9000471;
                           v_tdeserror := 'Error insertando asegurados innominados.'
                                          || x.campo03 || '-' || x.campo04 || '-' || x.campo05;
                           RAISE e_errdatos;
                     END;
                  END IF;
               -- REGISTRO 06 - Beneficiarios
               ELSIF x.tiporegistro = '6' THEN   -- beneficiarios
                  v_ntraza := 6000;
                  reg_migpersonas := NULL;

                  IF v_toperacion = 'ALTA' THEN
                     reg_migbenespseg := NULL;

                     INSERT INTO mig_cargas_tab_mig
                                 (ncarga, tab_org, tab_des, ntab)
                          VALUES (v_ncarga, 'INT_CARGA_GENERICO', 'MIG_PERSONAS', 1);

                     v_ntraza := 6010;

                     -- sera el primero porque sea asegurado, tomador y riesgo
                     INSERT INTO mig_cargas_tab_mig
                                 (ncarga, tab_org, tab_des, ntab)
                          VALUES (v_ncarga, 'INT_CARGA_GENERICO', 'MIG_BENESPSEG', 65);

                     --
                     v_ntraza := 6020;
                     reg_migpersonas.ncarga := v_ncarga;
                     -- I - JLB -
                     reg_migpersonas.proceso := x.proceso;

                     IF x.campo04 = ''
                        OR x.campo04 IS NULL THEN
                        v_tdeserror :=
                           f_desproducto_t(v_cramo, v_cmodali, v_ctipseg, v_ccolect, 1,
                                           k_cidioma)
                           || ': Se debe informar el tipo de identificador del beneficiario.';
                        RAISE e_errdatos;
                     END IF;

                     reg_migpersonas.ctipide := x.campo04;

                     -- f_buscavalor('TIPO_IDENTIFICADOR_PERSONA', x.campo04);
                     IF x.campo05 = ''
                        OR x.campo05 IS NULL THEN
                        v_tdeserror :=
                           f_desproducto_t(v_cramo, v_cmodali, v_ctipseg, v_ccolect, 1,
                                           k_cidioma)
                           || ': Se debe informar el n¿mero identificador del beneficiario.';
                        RAISE e_errdatos;
                     END IF;

                     reg_migpersonas.nnumide := x.campo05;
                     reg_migpersonas.tdigitoide := x.campo06;

                     -- reg_migpersonas.mig_pk := v_ncarga || '/' || x.nlinea || '/'
                     --                           || reg_migpersonas.nnumide;
                     IF reg_migpersonas.ctipide = 0
                        AND reg_migpersonas.nnumide = 'Z' THEN   -- si es un menor
                        reg_migpersonas.mig_pk :=
                                 v_ncarga || '/' || x.nlinea || '/' || reg_migpersonas.nnumide;
                     ELSE
                        reg_migpersonas.mig_pk :=
                           v_ncarga || '/' || reg_migpersonas.ctipide || '/'
                           || reg_migpersonas.nnumide;
                     END IF;

                     v_ntraza := 6030;
                     reg_migpersonas.cestmig := 1;
                     reg_migpersonas.idperson := 0;

                     IF x.campo07 = ''
                        OR x.campo07 IS NULL THEN
--                        IF reg_migseg.sproduc = 7001
--                           AND k_tablas = 'MIG'
--                           AND pac_md_common.f_get_cxtempresa() = 17 THEN
--                           v_tdeserror :=
--                              'Migraci¿n Renta Vitalicia: se debe informar el tipo de persona del beneficiario.';
--                        ELSIF reg_migseg.sproduc = 7004
--                              AND k_tablas = 'MIG'
--                              AND pac_md_common.f_get_cxtempresa() = 17 THEN
--                           v_tdeserror :=
--                              'Migraci¿n Conmutaci¿n Pensional: se debe informar el tipo de persona del beneficiario.';
--                        ELSE
                        v_tdeserror :=
                           f_desproducto_t(v_cramo, v_cmodali, v_ctipseg, v_ccolect, 1,
                                           k_cidioma)
                           || ': Se debe informar el tipo de persona del beneficiario.';
--                        END IF;
                        RAISE e_errdatos;
                     END IF;

                     reg_migpersonas.cpertip := f_buscavalor('TIPUS PERSONA', x.campo07);

                     IF x.campo08 = ''
                        OR x.campo08 IS NULL THEN
--                        IF reg_migseg.sproduc = 7001
--                           AND k_tablas = 'MIG'
--                           AND pac_md_common.f_get_cxtempresa() = 17 THEN
--                           v_tdeserror :=
--                              'Migraci¿n Renta Vitalicia: se debe informar el apellido 1 del beneficiario.';
--                        ELSIF reg_migseg.sproduc = 7004
--                              AND k_tablas = 'MIG'
--                              AND pac_md_common.f_get_cxtempresa() = 17 THEN
--                           v_tdeserror :=
--                              'Migraci¿n Conmutaci¿n Pensional: se debe informar el apellido 1 del beneficiario.';
--                        ELSE
                        v_tdeserror := f_desproducto_t(v_cramo, v_cmodali, v_ctipseg,
                                                       v_ccolect, 1, k_cidioma)
                                       || ': Se debe informar el apellido 1 del beneficiario.';
--                        END IF;
                        RAISE e_errdatos;
                     END IF;

                     reg_migpersonas.tapelli1 := x.campo08;
                     reg_migpersonas.tapelli2 := x.campo09;
                     reg_migpersonas.cagente := ff_agente_cpervisio(reg_migseg.cagente);
                     reg_migpersonas.cidioma := k_cidioma;
                     reg_migpersonas.tnombre := x.campo10;
                     reg_migpersonas.tnombre2 := x.campo11;
                     v_ntraza := 6060;
                     reg_migpersonas.csexper := f_buscavalor('SEXO', x.campo12);
                     reg_migpersonas.swpubli := 0;
                     reg_migpersonas.fnacimi := f_chartodate(x.campo13);

                     IF reg_migpersonas.fnacimi IS NOT NULL
                        AND TRUNC(reg_migpersonas.fnacimi) > TRUNC(f_sysdate) THEN
--                        IF reg_migseg.sproduc = 7001
--                           AND k_tablas = 'MIG'
--                           AND pac_md_common.f_get_cxtempresa() = 17 THEN
--                           v_tdeserror :=
--                              'Migraci¿n Renta Vitalicia: la fecha de nacimiento del beneficiario no puede ser superior a la fecha de hoy.';
--                        ELSIF reg_migseg.sproduc = 7004
--                              AND k_tablas = 'MIG'
--                              AND pac_md_common.f_get_cxtempresa() = 17 THEN
--                           v_tdeserror :=
--                              'Migraci¿n Conmutaci¿n Pensional: la fecha de nacimiento del beneficiario no puede ser superior a la fecha de hoy.';
--                        ELSE
                        v_tdeserror :=
                           f_desproducto_t(v_cramo, v_cmodali, v_ctipseg, v_ccolect, 1,
                                           k_cidioma)
                           || ': La fecha de nacimiento del beneficiario no puede ser superior a la fecha de hoy.';
--                        END IF;
                        v_nnumerr := 120058;
                        RAISE e_errdatos;
                     END IF;

                     reg_migpersonas.cestper := 0;
                     v_ntraza := 6070;

                     --  BEGIN
                     BEGIN
                        INSERT INTO mig_personas
                             VALUES reg_migpersonas
                          RETURNING ROWID
                               INTO v_rowid;
                     EXCEPTION
                        WHEN DUP_VAL_ON_INDEX THEN
                           NULL;   -- si se habia recibido no reenviamos
                     END;

                     v_ntraza := 6080;

                     INSERT INTO mig_pk_emp_mig
                          VALUES (0, v_ncarga, 4, reg_migpersonas.mig_pk);

                     --   EXCEPTION
                     --       WHEN OTHERS THEN
                     --          NULL;
                     -- la persona venia como asegurado no la vuelvo a crear
                     --    END;
                     v_ntraza := 6090;
                     reg_migbenespseg.ncarga := v_ncarga;
                     reg_migbenespseg.cestmig := 1;
                     reg_migbenespseg.mig_pk := v_ncarga || '/' || x.campo01 || '/'
                                                || x.campo02 || '/' || x.campo03 || '/'
                                                || x.campo05;
                     reg_migbenespseg.mig_fk := reg_migmovseg.mig_pk;
                     reg_migbenespseg.mig_fk2 := reg_migpersonas.mig_pk;
                     reg_migbenespseg.nmovimi := x.campo01;
                     reg_migbenespseg.nriesgo := x.campo02;
                     reg_migbenespseg.nbenefic := x.campo03;
                     reg_migbenespseg.sseguro := 0;
                     reg_migbenespseg.cgarant := NVL(x.campo26, 0);
                     reg_migbenespseg.sperson := 0;
                     reg_migbenespseg.cestado := x.campo27;

                     -- antes de nada valido que el beneficiario ese en la poliza definido anteriormente
                     IF x.campo17 IS NOT NULL
                        AND x.campo18 IS NOT NULL THEN
                        BEGIN
                           SELECT sperson
                             INTO reg_migbenespseg.sperson
                             FROM mig_benespseg ben, mig_personas per
                            WHERE ben.ncarga = v_ncarga
                              AND per.ncarga = ben.ncarga
                              AND per.mig_pk = ben.mig_fk2
                              AND per.nnumide = x.campo18
                              AND per.ctipide = x.campo17;
                        EXCEPTION
                           WHEN NO_DATA_FOUND THEN
--                              IF reg_migseg.sproduc = 7001
--                                 AND k_tablas = 'MIG'
--                                 AND pac_md_common.f_get_cxtempresa() = 17 THEN
--                                 v_tdeserror :=
--                                    'Migraci¿n Renta Vitalicia: no existe beneficiario contingente.';
--                              ELSIF reg_migseg.sproduc = 7004
--                                    AND k_tablas = 'MIG'
--                                    AND pac_md_common.f_get_cxtempresa() = 17 THEN
--                                 v_tdeserror :=
--                                    'Migraci¿n Conmutaci¿n Pensional: no existe beneficiario contingente.';
--                              ELSE
                              v_tdeserror :=
                                 f_desproducto_t(v_cramo, v_cmodali, v_ctipseg, v_ccolect, 1,
                                                 k_cidioma)
                                 || '.Error: No existe beneficiario contigente. Identificador: '
                                 || x.campo18;
--                              END IF;
                              v_nnumerr := 9902573;
                              RAISE e_errdatos;
                        END;
                     END IF;

                     --
                     reg_migbenespseg.ctipide_cont := x.campo17;
                     --f_buscavalor('TIPO_IDENTIFICADOR_PERSONA',x.campo17);
                     reg_migbenespseg.nnumide_cont := x.campo18;
                     reg_migbenespseg.tapelli1_cont := x.campo20;
                     reg_migbenespseg.tapelli2_cont := x.campo21;
                     reg_migbenespseg.tnombre1_cont := x.campo22;
                     reg_migbenespseg.tnombre2_cont := x.campo23;
                     reg_migbenespseg.finiben := f_chartodate(x.campo24);

                     IF x.campo24 = ''
                        OR x.campo24 IS NULL THEN
--                        IF reg_migseg.sproduc = 7001
--                           AND k_tablas = 'MIG'
--                           AND pac_md_common.f_get_cxtempresa() = 17 THEN
--                           v_tdeserror :=
--                              'Migraci¿n Renta Vitalicia: se debe informar la fecha de inicio del beneficiario.';
--                        ELSIF reg_migseg.sproduc = 7004
--                              AND k_tablas = 'MIG'
--                              AND pac_md_common.f_get_cxtempresa() = 17 THEN
--                           v_tdeserror :=
--                              'Migraci¿n Conmutaci¿n Pensional: se debe informar la fecha de inicio del beneficiario.';
--                        ELSE
                        v_tdeserror :=
                           f_desproducto_t(v_cramo, v_cmodali, v_ctipseg, v_ccolect, 1,
                                           k_cidioma)
                           || ': Se debe informar la fecha de inicio del beneficiario.';
--                        END IF;
                        v_nnumerr := 9000572;
                        RAISE e_errdatos;
                     END IF;

                     reg_migbenespseg.ffinben := f_chartodate(x.campo25);

                     IF x.campo14 = ''
                        OR x.campo14 IS NULL THEN
--                        IF reg_migseg.sproduc = 7001
--                           AND k_tablas = 'MIG'
--                           AND pac_md_common.f_get_cxtempresa() = 17 THEN
--                           v_tdeserror :=
--                              'Migraci¿n Renta Vitalicia: se debe informar el tipo de beneficiario.';
--                        ELSIF reg_migseg.sproduc = 7004
--                              AND k_tablas = 'MIG'
--                              AND pac_md_common.f_get_cxtempresa() = 17 THEN
--                           v_tdeserror :=
--                              'Migraci¿n Conmutaci¿n Pensional: se debe informar el tipo de beneficiario.';
--                        ELSE
                        v_tdeserror := f_desproducto_t(v_cramo, v_cmodali, v_ctipseg,
                                                       v_ccolect, 1, k_cidioma)
                                       || ': Se debe informar el tipo de beneficiario.';
--                        END IF;
                        RAISE e_errdatos;
                     END IF;

                     reg_migbenespseg.ctipben := f_buscavalor('GEN_TIPOBENEFICIARIO',
                                                              x.campo14);
                     reg_migbenespseg.cparen := x.campo15;
                     --reg_migbenespseg.pparticip := x.campo16;
                     reg_migbenespseg.pparticip := NVL(f_chartonumber(x.campo16), 0);
                     v_ntraza := 6100;

                     INSERT INTO mig_benespseg
                          VALUES reg_migbenespseg
                       RETURNING ROWID
                            INTO v_rowid;

                     v_ntraza := 6110;

                     INSERT INTO mig_pk_emp_mig
                          VALUES (0, v_ncarga, 4, reg_migbenespseg.mig_pk);
                  ELSIF v_toperacion = 'MODI' THEN
                     --f_buscavalor('TIPO_IDENTIFICADOR_PERSONA', x.campo04);
                     BEGIN
                        SELECT per.sperson
                          INTO wspersonnueva
                          FROM estper_personas per, estper_detper pd, estbenespseg ben
                         WHERE ben.sseguro = v_sseguroest
                           AND ben.nriesgo = x.campo02
                           AND per.sperson = ben.sperson
                           AND ben.nmovimi = v_nmovimi
                           AND per.sperson = pd.sperson
                           AND ctipide = x.campo04
                           AND nnumide = x.campo05
                           AND nnumide <> 'Z'
                           AND pd.cagente = ff_agente_cpervisio(reg_migseg.cagente)
                           AND NVL(tapelli1, '*') = NVL(x.campo08, '*')
                           AND NVL(tapelli2, '*') = NVL(x.campo09, '*')
                           AND NVL(tnombre1, '*') = NVL(x.campo10, '*')
                           AND NVL(tnombre2, '*') = NVL(x.campo11, '*');
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           wspersonnueva := NULL;
                     END;

                     wspersonnueva_cont := NULL;

                     IF x.campo17 IS NOT NULL
                        AND x.campo18 IS NOT NULL THEN
                        -- si me llega un beneficiario contigente los busco dentro de los beneficiarios
                        BEGIN   --
                           -- f_buscavalor('TIPO_IDENTIFICADOR_PERSONA', x.campo17);
                           SELECT per.sperson
                             INTO wspersonnueva_cont
                             FROM estper_personas per, estper_detper pd, estbenespseg ben
                            WHERE ben.sseguro = v_sseguroest
                              AND ben.nriesgo = x.campo02
                              AND per.sperson = ben.sperson
                              AND ben.nmovimi = v_nmovimi
                              AND per.sperson = pd.sperson
                              AND ctipide = x.campo17
                              AND nnumide = x.campo18
                              AND nnumide <> 'Z'
                              AND pd.cagente = ff_agente_cpervisio(reg_migseg.cagente)
                              AND NVL(tapelli1, '*') = NVL(x.campo20, '*')
                              AND NVL(tapelli2, '*') = NVL(x.campo21, '*')
                              AND NVL(tnombre1, '*') = NVL(x.campo22, '*')
                              AND NVL(tnombre2, '*') = NVL(x.campo23, '*')
                              AND ROWNUM = 1;
                        EXCEPTION
                           WHEN NO_DATA_FOUND THEN
                              -- error
                              v_nnumerr := 9902573;
                              v_tdeserror :=
                                 'Error: No existe beneficiario contigente Identificador: '
                                 || x.campo18;
                              RAISE e_errdatos;
                        --wspersonnueva_cont := NULL;
                        END;
                     END IF;

                     IF wspersonnueva IS NULL THEN
                        v_ntraza := 6220;
                        v_ncarga2 := f_next_carga;
                        reg_migpersonas.ncarga := v_ncarga2;
                        -- I - JLB -
                        reg_migpersonas.proceso := x.proceso;
                        reg_migpersonas.ctipide := x.campo04;
                        -- f_buscavalor('TIPO_IDENTIFICADOR_PERSONA', x.campo04);
                        reg_migpersonas.nnumide := x.campo05;
                        reg_migpersonas.tdigitoide := x.campo06;
                        reg_migpersonas.mig_pk :=
                                v_ncarga2 || '/' || x.nlinea || '/' || reg_migpersonas.nnumide;
                        v_ntraza := 6230;
                        reg_migpersonas.cestmig := 1;
                        reg_migpersonas.idperson := 0;
                        reg_migpersonas.cpertip := f_buscavalor('TIPUS PERSONA', x.campo07);
                        reg_migpersonas.tapelli1 := x.campo08;
                        reg_migpersonas.tapelli2 := x.campo09;
                        reg_migpersonas.cagente := ff_agente_cpervisio(reg_migseg.cagente);
                        reg_migpersonas.cidioma := k_cidioma;
                        reg_migpersonas.tnombre := x.campo10;
                        reg_migpersonas.tnombre2 := x.campo11;
                        v_ntraza := 6260;
                        reg_migpersonas.csexper := f_buscavalor('SEXO', x.campo12);
                        reg_migpersonas.swpubli := 0;
                        reg_migpersonas.fnacimi := f_chartodate(x.campo13);

                        IF reg_migpersonas.fnacimi IS NOT NULL THEN
                           IF TRUNC(reg_migpersonas.fnacimi) > TRUNC(f_sysdate) THEN
                              --La Fecha de nacimiento no puede ser superior a la fecha de hoy.
                              v_tdeserror := 'Error fecha nacimiento';
                              v_nnumerr := 120058;
                              RAISE e_errdatos;
                           END IF;
                        END IF;

                        reg_migpersonas.cestper := 0;
                        v_ntraza := 6270;

                        INSERT INTO mig_personas
                             VALUES reg_migpersonas
                          RETURNING ROWID
                               INTO v_rowid;

                        INSERT INTO mig_pk_emp_mig
                             VALUES (0, v_ncarga2, 1, reg_migpersonas.mig_pk);

                        INSERT INTO mig_cargas
                                    (ncarga, cempres, finiorg, ffinorg, ID, estorg)
                             VALUES (v_ncarga2, k_cempresa, f_sysdate, f_sysdate, v_id, NULL);

                        INSERT INTO mig_cargas_tab_mig
                                    (ncarga, tab_org, tab_des, ntab)
                             VALUES (v_ncarga2, 'INT_CARGA_GENERICO', 'MIG_PERSONAS', 1);

                        v_ntraza := 6280;
                        v_nnumerr := f_lanza_migracion(v_id, v_ncarga2);

                        IF v_nnumerr NOT IN(0, 2, 4) THEN   -- si ha habido error
                           ROLLBACK;

                           IF k_cpara_error <> 1 THEN
                              v_ntipoerror := 4;
                           -- para que continue con la siguiente linea.
                           ELSE
                              v_ntipoerror := 1;   -- para la carga
                              RAISE e_salir;
                           END IF;
                        END IF;

                        BEGIN
                           SELECT idperson
                             INTO wspersonnueva
                             FROM mig_personas
                            WHERE ncarga = v_ncarga2;
                        EXCEPTION
                           WHEN OTHERS THEN
                              v_nnumerr := 9001557;
                              v_tdeserror :=
                                 'Error ' || SQLCODE
                                 || 'No se encuentra el beneficiasio creado. NIF: '
                                 || x.campo05;
                              RAISE e_errdatos;
                        END;

                        v_ntraza := 6300;
                        v_ctipben := f_buscavalor('GEN_TIPOBENEFICIARIO', x.campo14);
                        vpparticip := NVL(f_chartonumber(x.campo16), 0);
                        vfiniben := f_chartodate(x.campo24);
                        vffinben := f_chartodate(x.campo25);

                        INSERT INTO estbenespseg
                                    (sseguro, nriesgo, cgarant, nmovimi,
                                     sperson, sperson_tit, finiben,
                                     ffinben, ctipben, cparen, pparticip, cestado)
                             VALUES (v_sseguroest, x.campo02, NVL(x.campo26, 0), v_nmovimi,
                                     wspersonnueva, NVL(wspersonnueva_cont, 0), vfiniben,
                                     vffinben, v_ctipben, x.campo15,
                                                                    --x.campo16
                                                                    vpparticip, x.campo27);
                     ELSE
                        vfiniben := f_chartodate(x.campo24);
                        vffinben := f_chartodate(x.campo25);
                        v_ntraza := 6320;
                        v_ctipben := f_buscavalor('GEN_TIPOBENEFICIARIO', x.campo14);
                        vpparticip := NVL(f_chartonumber(x.campo16), 0);

                        UPDATE estbenespseg
                           SET sperson_tit = NVL(wspersonnueva_cont, sperson_tit),
                               finiben = vfiniben,
                               ffinben = vffinben,
                               ctipben = v_ctipben,
                               cparen = x.campo15,   --pparticip = x.campo16
                               pparticip = vpparticip,
                               cestado = x.campo27
                         WHERE sseguro = v_sseguroest
                           AND nriesgo = x.campo02
                           AND cgarant = NVL(x.campo26, 0)
                           AND nmovimi = v_nmovimi
                           AND sperson = wspersonnueva;
                     END IF;   -- existe
                  END IF;   -- modi
               -- Registro 7 garantias
               ELSIF x.tiporegistro = '7' THEN   -- garantias
                  v_ntraza := 7000;

                  IF v_toperacion = 'ALTA' THEN
                     -- SCO - 07/10/2011 - validaci¿n fecha garant¿a = fecha inicio efecto de la p¿liza
                     IF f_chartodate(x.campo04) <> reg_migseg.fefecto
                        AND(k_tablas = 'MIG'
                            AND NVL(x.campo02, 1) = 1) THEN   -- si es migraci¿n solo valido estas fecha para movimiento 1
                        v_tdeserror := f_desproducto_t(v_cramo, v_cmodali, v_ctipseg,
                                                       v_ccolect, 1, k_cidioma)
                                       || ': La fecha de la garant¿a ' || x.campo01 || '->'
                                       || f_chartodate(x.campo04)
                                       || ' debe ser igual a la fecha de efecto de la p¿liza '
                                       || reg_migseg.fefecto || '.';
                        RAISE e_errdatos;
                     ELSE
                        reg_miggar := NULL;

                        INSERT INTO mig_cargas_tab_mig
                                    (ncarga, tab_org, tab_des, ntab)
                             VALUES (v_ncarga, 'INT_CARGA_GENERICO', 'MIG_GARANSEG', 70);

                        v_ntraza := 7010;
                        reg_miggar := NULL;
                        reg_miggar.mig_fk := reg_migmovseg.mig_pk;
                        reg_miggar.cestmig := 1;
                        reg_miggar.cgarant := x.campo01;

                        BEGIN
                           SELECT *
                             INTO v_garanpro
                             FROM garanpro
                            WHERE sproduc = reg_migseg.sproduc
                              AND cactivi = reg_migseg.cactivi
                              AND cgarant = reg_miggar.cgarant;
                        EXCEPTION
                           WHEN NO_DATA_FOUND THEN
                              v_tdeserror := 'Garantia ' || reg_miggar.cgarant || ' - '
                                             || ff_desgarantia(reg_miggar.cgarant, k_cidioma);
                              v_nnumerr := 105710;
                              RAISE e_errdatos;
                        END;

                        reg_miggar.icapital := f_chartonumber(x.campo06);

                        IF v_garanpro.ctipcap = 1 THEN
                           IF v_garanpro.icapmax <> NVL(reg_miggar.icapital, 0) THEN
                              v_tdeserror := 'Garantia ' || reg_miggar.cgarant || ' - '
                                             || ff_desgarantia(reg_miggar.cgarant, k_cidioma)
                                             || ' capital esperado ' || v_garanpro.icapmax;
                              v_nnumerr := 9904190;
                              RAISE e_errdatos;
                           END IF;
                        ELSIF v_garanpro.ctipcap = 4 THEN
                           IF NVL(vicapital, 0) <> 0 THEN
                              v_tdeserror := 'Garantia ' || reg_miggar.cgarant || ' - '
                                             || ff_desgarantia(reg_miggar.cgarant, k_cidioma)
                                             || ' no tiene capital.';
                              v_nnumerr := 9904190;
                              RAISE e_errdatos;
                           END IF;
                        END IF;

                        reg_miggar.ncarga := v_ncarga;
                        reg_miggar.nriesgo := x.campo03;
                        v_ntraza := 7020;
                        reg_miggar.finiefe := f_chartodate(x.campo04);

                        IF k_tablas = 'MIG' THEN   -- si es migracion si que cargo las fechas
                           reg_miggar.ffinefe := f_chartodate(x.campo05);
                        ELSE
                           reg_miggar.ffinefe := NULL;
                        END IF;

                        --reg_miggar.nmovimi := reg_migmovseg.nmovimi;
                        reg_miggar.nmovimi := x.campo02;
                        reg_miggar.nmovima := 1;
                        reg_miggar.sseguro := 0;
                        v_ntraza := 7030;
                        reg_miggar.mig_pk := reg_migmovseg.mig_pk || '/' || reg_miggar.nmovimi
                                             || '/' || reg_miggar.nriesgo || '/'
                                             || reg_miggar.cgarant;
                        reg_miggar.iprianu := NVL(f_chartonumber(x.campo07), 0);
                        reg_miggar.ipritar := NVL(f_chartonumber(x.campo14), 0);
                        v_ntraza := 7040;
                        reg_miggar.iextrap := NVL(f_chartonumber(x.campo08), 0);
                        -- JLB - 27/09/2013
                        reg_miggar.crevali := NVL(x.campo11, v_garanpro.crevali);
                        reg_miggar.prevali := NVL(f_chartonumber(x.campo12),
                                                  v_garanpro.prevali);
                        reg_miggar.irevali := NVL(f_chartonumber(x.campo13),
                                                  v_garanpro.irevali);
                        --reg_miggar.crevali := 0;
                        --reg_miggar.prevali := 0;
                        --reg_miggar.irevali := 0;
                        -- jlb  JLB - 27/09/2013
                        v_ntraza := 7041;
                        reg_miggar.precarg := NVL(f_chartonumber(x.campo09), 0);
                        reg_miggar.irecarg := reg_miggar.ipritar *(reg_miggar.precarg / 100);   --NVL(f_chartonumber(x.campo09), 0);
                        v_ntraza := 7042;
                        reg_miggar.pdtocom := NVL(f_chartonumber(x.campo10), 0);
                        reg_miggar.idtocom := reg_miggar.ipritar *(reg_miggar.pdtocom / 100);
                        v_ntraza := 7050;
                        reg_miggar.pdtotec := 0;
                        reg_miggar.idtotec := 0;
                        reg_miggar.preccom := 0;
                        reg_miggar.ireccom := 0;
                        reg_miggar.itotanu := reg_miggar.iprianu;

                        INSERT INTO mig_garanseg
                             VALUES reg_miggar
                          RETURNING ROWID
                               INTO v_rowid;

                        INSERT INTO mig_pk_emp_mig
                             VALUES (0, v_ncarga, 7, reg_miggar.mig_pk);
                     END IF;
                  ELSIF v_toperacion = 'MODI'   -- suplementos garantias
                        AND NVL(x.campo15, 0) = 0 THEN   -- si la p¿lia es modificacada y no eliminada
                     -- SCO - 07/10/2011 - validaci¿n fecha garant¿a >= fecha inicio efecto de la p¿liza
                     IF f_chartodate(x.campo04) < reg_migseg.fefecto THEN
                        v_tdeserror :=
                           f_desproducto_t(v_cramo, v_cmodali, v_ctipseg, v_ccolect, 1,
                                           k_cidioma)
                           || ': La fecha de la garant¿a ' || x.campo01 || '->'
                           || f_chartodate(x.campo04)
                           || ' debe ser mayor o igual a la fecha de efecto de la p¿liza '
                           || reg_migseg.fefecto || '.';
                        RAISE e_errdatos;
                     ELSE
                        v_ntraza := 7200;

                        BEGIN
                           SELECT *
                             INTO v_garanpro
                             FROM garanpro
                            WHERE sproduc = reg_migseg.sproduc
                              AND cactivi = reg_migseg.cactivi
                              AND cgarant = x.campo01;
                        EXCEPTION
                           WHEN NO_DATA_FOUND THEN
                              v_tdeserror := 'Garantia ' || reg_miggar.cgarant || ' - '
                                             || ff_desgarantia(reg_miggar.cgarant, k_cidioma);
                              v_nnumerr := 105710;
                              RAISE e_errdatos;
                        END;

                        v_ntraza := 7210;

                        DELETE      estgaranseg
                              WHERE sseguro = v_sseguroest
                                AND nmovimi = v_nmovimi
                                AND cgarant = x.campo01
                                AND nriesgo = x.campo03
                          RETURNING nmovima
                               INTO v_nmovima;   -- borro la garantia

                        IF v_nmovima IS NULL THEN
                           v_nmovima := v_nmovimi;
                        END IF;

                        v_ntraza := 7220;
                        vicapital := f_chartonumber(x.campo06);

                        IF v_garanpro.ctipcap = 1 THEN
                           IF v_garanpro.icapmax <> NVL(vicapital, 0) THEN
                              v_tdeserror := 'Garantia ' || reg_miggar.cgarant || ' - '
                                             || ff_desgarantia(reg_miggar.cgarant, k_cidioma)
                                             || ' capital esperado ' || v_garanpro.icapmax;
                              v_nnumerr := 9904190;
                              RAISE e_errdatos;
                           END IF;
                        ELSIF v_garanpro.ctipcap = 4 THEN
                           IF NVL(vicapital, 0) <> 0 THEN
                              v_tdeserror := 'Garantia ' || reg_miggar.cgarant || ' - '
                                             || ff_desgarantia(reg_miggar.cgarant, k_cidioma)
                                             || ' no tiene capital.';
                              v_nnumerr := 9904190;
                              RAISE e_errdatos;
                           END IF;
                        END IF;

                        -- FAL. 26/08/2011. Alta de las garantias que llegan. Bug 0019231
                        vfiniefe := f_chartodate(x.campo04);
                        -- JLB - I - No cojo la fecha que envian sino la que llega como suplemento
                        vfiniefe := v_fsuplemento;
                        --vffinefe := f_chartodate(x.campo05, 'DD/MM/YYYY');
                        vffinefe := NULL;
                        viprianu := NVL(f_chartonumber(x.campo07), 0);
                        viextrap := NVL(f_chartonumber(x.campo08), 0);
                        virecarg := NVL(f_chartonumber(x.campo09), 0);
                        vidtocom := NVL(f_chartonumber(x.campo10), 0);
                        v_crevali := x.campo11;
                        v_prevali := f_chartonumber(x.campo12);
                        v_irevali := f_chartonumber(x.campo13);

                        BEGIN
                           INSERT INTO estgaranseg
                                       (cgarant, nriesgo, nmovimi, sseguro,
                                        finiefe, norden,
                                        crevali,
                                        ctarifa, icapital, precarg, iextrap, iprianu,
                                        ffinefe, cformul, ctipfra,
                                        ifranqu, irecarg, ipritar, pdtocom, idtocom,
                                        prevali,
                                        irevali, itarifa, itarrea,
                                        ipritot, icaptot, ftarifa, crevalcar, cgasgar,
                                        pgasadq, pgasadm, pdtoint, idtoint, feprev, fpprev,
                                        percre, cmatch, tdesmat, pintfin, cref, cintref,
                                        pdif, pinttec, nparben, nbns,
                                        tmgaran, cderreg, ccampanya, nversio, nmovima,
                                        cageven, nfactor, nlinea, cfranq, nfraver, ngrpfra,
                                        ngrpgara, nordfra, pdtofra, cmotmov, finider, falta,
                                        ctarman, cobliga, ctipgar, itotanu, pdtotec, preccom,
                                        idtotec, ireccom, icaprecomend)
                                VALUES (x.campo01, x.campo03, v_nmovimi, v_sseguroest,
                                        vfiniefe, v_garanpro.norden,
                                        NVL(v_crevali, v_garanpro.crevali),
                                        v_garanpro.ctarifa, vicapital, 0, viextrap, viprianu,
                                        vffinefe, v_garanpro.cformul, v_garanpro.ctipfra,
                                        v_garanpro.ifranqu, virecarg, viprianu, 0, vidtocom,
                                        NVL(v_prevali, v_garanpro.prevali),
                                        NVL(v_irevali, v_garanpro.irevali), NULL, NULL,
                                        viprianu, vicapital, TRUNC(f_sysdate), NULL, NULL,
                                        NULL, NULL, NULL, NULL, NULL, NULL,
                                        NULL, NULL, NULL, NULL, NULL, NULL,
                                        NULL, NULL, v_garanpro.nparben, v_garanpro.nbns,
                                        NULL, v_garanpro.cderreg, NULL, NULL, v_nmovima,
                                        NULL, NULL, NULL, NULL, NULL, NULL,
                                        NULL, NULL, NULL, NULL, NULL, NULL,
                                        0,   --v_garanpro.ctarman,
                                          1, v_garanpro.ctipgar, viprianu, NULL, NULL,
                                        NULL, NULL, NULL);
                        EXCEPTION
                           WHEN DUP_VAL_ON_INDEX THEN
                              UPDATE estgaranseg
                                 SET cobliga = 1,
                                     finiefe = vfiniefe,
                                     icapital = vicapital,
                                     iextrap = viextrap,
                                     iprianu = viprianu,
                                     ffinefe = vffinefe,
                                     irecarg = virecarg,
                                     ipritar = viprianu,
                                     idtocom = vidtocom,
                                     ipritot = viprianu + virecarg + viextrap - vidtocom,
                                     icaptot = vicapital,
                                     itotanu = viprianu
                               WHERE sseguro = v_sseguroest
                                 AND nmovimi = v_nmovimi
                                 AND cgarant = x.campo01
                                 AND nriesgo = x.campo03;
                        END;
                     END IF;

                     --  END IF;
                     v_ntraza := 7250;
                  ELSE   -- si es elminada la descamarco
                     UPDATE estgaranseg
                        SET cobliga = 0
                      WHERE sseguro = v_sseguroest
                        AND nmovimi = v_nmovimi
                        AND cgarant = x.campo01
                        AND nriesgo = x.campo03;   -- desmarco la garantia
                  END IF;
               -- REGISTRO 08 - Preguntas de riesgo
               ELSIF x.tiporegistro = '8' THEN   -- preguntas del riesgo
                  v_ntraza := 8000;

                  IF v_toperacion = 'ALTA' THEN
                     v_ntraza := 8005;

                     INSERT INTO mig_cargas_tab_mig
                                 (ncarga, tab_org, tab_des, ntab)
                          VALUES (v_ncarga, 'INT_CARGA_GENERICO', 'MIG_PREGUNSEG', 80);

                     v_ntraza := 8010;
                     reg_migpre := NULL;
                     reg_migpre.ncarga := v_ncarga;
                     reg_migpre.cestmig := 1;
                     reg_migpre.sseguro := 0;
                     reg_migpre.mig_fk := reg_migseg.mig_pk;
                     reg_migpre.nmovimi := x.campo01;
                     reg_migpre.cpregun := x.campo03;

                     BEGIN
                        SELECT p.cnivel, c.ctippre
                          INTO v_cnivel, v_ctippre
                          FROM pregunpro p, codipregun c
                         WHERE p.sproduc = reg_migseg.sproduc
                           AND p.cpregun = reg_migpre.cpregun
                           AND c.cpregun = reg_migpre.cpregun;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
--                           IF reg_migseg.sproduc = 7001
--                              AND k_tablas = 'MIG'
--                              AND pac_md_common.f_get_cxtempresa() = 17 THEN
--                              v_tdeserror :=
--                                 'Migraci¿n Renta Vitalicia: error en la pregunta '
--                                 || reg_migpre.cpregun;
--                           ELSIF reg_migseg.sproduc = 7004
--                                 AND k_tablas = 'MIG'
--                                 AND pac_md_common.f_get_cxtempresa() = 17 THEN
--                              v_tdeserror :=
--                                 'Migraci¿n Conmutaci¿n Pensional: error en la pregunta '
--                                 || reg_migpre.cpregun;
--                           ELSE
                           v_tdeserror := f_desproducto_t(v_cramo, v_cmodali, v_ctipseg,
                                                          v_ccolect, 1, k_cidioma)
                                          || ': Error en la pregunta ' || reg_migpre.cpregun
                                          || ' no definida para el producto.';
--                           END IF;
                           v_nnumerr := 1000600;
                           RAISE e_errdatos;
                     END;

                     v_ntraza := 8020;

                     IF v_cnivel = 'R' THEN
                        reg_migpre.nriesgo := x.campo02;
                     ELSE
                        reg_migpre.nriesgo := NULL;
                     END IF;

                     IF x.campo04 = ''
                        OR x.campo04 IS NULL THEN
--                        IF reg_migseg.sproduc = 7001
--                           AND k_tablas = 'MIG'
--                           AND pac_md_common.f_get_cxtempresa() = 17 THEN
--                           v_tdeserror :=
--                              'Migraci¿n Renta Vitalicia: se debe informar la respuesta a la pregunta '
--                              || reg_migpre.cpregun || '.';
--                        ELSIF reg_migseg.sproduc = 7004
--                              AND k_tablas = 'MIG'
--                              AND pac_md_common.f_get_cxtempresa() = 17 THEN
--                           v_tdeserror :=
--                              'Migraci¿n Conmutaci¿n Pensional: se debe informar la respuesta a la pregunta '
--                              || reg_migpre.cpregun || '.';
--                        ELSE
                        v_tdeserror := f_desproducto_t(v_cramo, v_cmodali, v_ctipseg,
                                                       v_ccolect, 1, k_cidioma)
                                       || ': Se debe informar la respuesta a la pregunta '
                                       || reg_migpre.cpregun || '.';
--                        END IF;
                        RAISE e_errdatos;
                     END IF;

                     IF v_ctippre = 4 THEN   --la pregunta es de tipo fecha y vendra en formato dd/MM/YYYY y la tengo que transformar a YYYYMMDD
                        reg_migpre.crespue := TO_CHAR(f_chartodate(x.campo04), 'DD/MM/YYYY');
                     ELSE
                        IF v_ctippre IN(1, 2, 3) THEN
                           reg_migpre.crespue := f_chartonumber(x.campo04);
                        ELSE
                           reg_migpre.crespue := x.campo04;
                        END IF;
                     END IF;

                     IF reg_migpre.crespue IS NULL THEN
--                        IF reg_migseg.sproduc = 7001
--                           AND k_tablas = 'MIG'
--                           AND pac_md_common.f_get_cxtempresa() = 17 THEN
--                           v_tdeserror :=
--                              'Migraci¿n Renta Vitalicia: la respuesta a la pregunta '
--                              || x.campo03 || ' no tiene el formato correcto.';
--                        ELSIF reg_migseg.sproduc = 7004
--                              AND k_tablas = 'MIG'
--                              AND pac_md_common.f_get_cxtempresa() = 17 THEN
--                           v_tdeserror :=
--                              'Migraci¿n Conmutaci¿n Pensional: la respuesta a la pregunta '
--                              || x.campo03 || ' no tiene el formato correcto.';
--                        ELSE
                        v_tdeserror := f_desproducto_t(v_cramo, v_cmodali, v_ctipseg,
                                                       v_ccolect, 1, k_cidioma)
                                       || ': La respueta  a la pregunta ' || x.campo03
                                       || '--> ' || ' no tiene el formato correcto'
                                       || x.campo04;
--                        END IF;
                        RAISE e_errdatos;
                     END IF;

                     reg_migpre.mig_pk := reg_migmovseg.mig_pk || '/' || reg_migpre.nmovimi
                                          || '/' || reg_migpre.nriesgo || '/'
                                          || reg_migpre.cpregun;
                     v_ntraza := 8050;

                     BEGIN
                        INSERT INTO mig_pregunseg
                             VALUES reg_migpre
                          RETURNING ROWID
                               INTO v_rowid;

                        INSERT INTO mig_pk_emp_mig
                             VALUES (0, v_ncarga, 8, reg_migpre.mig_pk);
                     EXCEPTION
                        WHEN DUP_VAL_ON_INDEX THEN
                           IF reg_migpre.nriesgo IS NOT NULL THEN
                              -- preguntas a nivel de p¿liza puede dar duplicados
                              RAISE;
                           END IF;
                     END;
                  ELSIF v_toperacion = 'MODI' THEN
                     v_ntraza := 8200;

                     BEGIN
                        SELECT p.cnivel, cp.ctippre
                          INTO v_cnivel, v_ctippre
                          FROM pregunpro p, codipregun cp
                         WHERE p.sproduc = reg_migseg.sproduc
                           AND p.cpregun = x.campo03
                           AND cp.cpregun = p.cpregun;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           v_tdeserror := 'Pregunta ' || x.campo03;
                           v_nnumerr := 1000600;
                           RAISE e_errdatos;
                     END;

                     v_ntraza := 8210;

                     IF v_ctippre = 4 THEN   --la pregunta es de tipo fecha y vendra en formato dd/MM/YYYY y la tengo que transformar a YYYYMMDD
                        reg_migpre.crespue := TO_CHAR(f_chartodate(x.campo04), 'DD/MM/YYYY');
                     ELSE
                        IF v_ctippre IN(1, 2, 3) THEN
                           reg_migpre.crespue := f_chartonumber(x.campo04);
                        ELSE
                           reg_migpre.crespue := x.campo04;
                        END IF;
                     END IF;

                     IF reg_migpre.crespue IS NULL THEN
                        v_tdeserror := 'La respueta  a la pregunta ' || x.campo03 || '--> '
                                       || ' no tiene el formato correcto' || x.campo04;
                        RAISE e_errdatos;
                     END IF;

                     IF v_cnivel = 'R' THEN
                        DELETE      estpregunseg
                              WHERE sseguro = v_sseguroest
                                AND nriesgo = x.campo02
                                AND cpregun = x.campo03
                                AND nmovimi = v_nmovimi;

                        INSERT INTO estpregunseg
                                    (cpregun, sseguro, nriesgo, nmovimi,
                                     crespue,
                                     trespue)
                             VALUES (x.campo03, v_sseguroest, x.campo02, v_nmovimi,
                                     DECODE(v_ctippre, 4, NULL, 5, NULL, reg_migpre.crespue),
                                     DECODE(v_ctippre,
                                            4, reg_migpre.crespue,
                                            5, reg_migpre.crespue,
                                            NULL));
                     ELSE
                        DELETE      estpregunpolseg
                              WHERE sseguro = v_sseguroest
                                AND cpregun = x.campo03
                                AND nmovimi = v_nmovimi;

                        INSERT INTO estpregunpolseg
                                    (cpregun, sseguro, nmovimi,
                                     crespue,
                                     trespue)
                             VALUES (x.campo03, v_sseguroest, v_nmovimi,
                                     DECODE(v_ctippre, 4, NULL, 5, NULL, reg_migpre.crespue),
                                     DECODE(v_ctippre,
                                            4, reg_migpre.crespue,
                                            5, reg_migpre.crespue,
                                            NULL));
                     END IF;
                  END IF;
               -- Registro 9 - preguntas garantias
               ELSIF x.tiporegistro = '9' THEN   -- preguntas por garantias
                  v_ntraza := 9000;

                  IF v_toperacion = 'ALTA' THEN
                     INSERT INTO mig_cargas_tab_mig
                                 (ncarga, tab_org, tab_des, ntab)
                          VALUES (v_ncarga, 'INT_CARGA_GENERICO', 'MIG_PREGUNGARANSEG', 90);

                     v_ntraza := 9010;
                     reg_migpreggaran := NULL;
                     reg_migpreggaran.ncarga := v_ncarga;
                     reg_migpreggaran.cestmig := 1;
                     reg_migpreggaran.sseguro := 0;
                     reg_migpreggaran.mig_fk := reg_migmovseg.mig_pk;
                     reg_migpreggaran.cgarant := x.campo03;
                     --     reg_migpreggaran.nmovimi := x.campo01;
                     reg_migpreggaran.nriesgo := x.campo02;
                     reg_migpreggaran.cpregun := x.campo04;

                     BEGIN
                        SELECT c.ctippre
                          INTO v_ctippre
                          FROM pregunprogaran p, codipregun c
                         WHERE p.sproduc = reg_migseg.sproduc
                           AND p.cactivi = reg_migseg.cactivi
                           AND p.cgarant = reg_migpreggaran.cgarant
                           AND p.cpregun = reg_migpreggaran.cpregun
                           AND c.cpregun = p.cpregun;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           v_tdeserror := 'Garantia: ' || reg_migpreggaran.cgarant
                                          || ' Pregunta ' || reg_migpreggaran.cpregun;
                           v_nnumerr := 1000600;
                           RAISE e_errdatos;
                     END;

                     IF v_ctippre = 4 THEN   --la pregunta es de tipo fecha y vendra en formato dd/MM/YYYY y la tengo que transformar a YYYYMMDD
                        reg_migpreggaran.crespue :=
                                                TO_CHAR(f_chartodate(x.campo05), 'DD/MM/YYYY');
                     ELSE
                        IF v_ctippre IN(1, 2, 3) THEN
                           reg_migpreggaran.crespue := f_chartonumber(x.campo05);
                        ELSE
                           reg_migpreggaran.crespue := x.campo05;
                        END IF;
                     END IF;

                     IF reg_migpreggaran.crespue IS NULL THEN
--                        IF reg_migseg.sproduc = 7001
--                           AND k_tablas = 'MIG'
--                           AND pac_md_common.f_get_cxtempresa() = 17 THEN
--                           v_tdeserror :=
--                              'Migraci¿n Renta Vitalicia: la respuesta a la pregunta '
--                              || x.campo04 || ' no tiene el formato correcto.';
--                        ELSIF reg_migseg.sproduc = 7004
--                              AND k_tablas = 'MIG'
--                              AND pac_md_common.f_get_cxtempresa() = 17 THEN
--                           v_tdeserror :=
--                              'Migraci¿n Conmutaci¿n Pensional: la respuesta a la pregunta '
--                              || x.campo04 || ' no tiene el formato correcto.';
--                        ELSE
                        v_tdeserror := f_desproducto_t(v_cramo, v_cmodali, v_ctipseg,
                                                       v_ccolect, 1, k_cidioma)
                                       || ': La respuesta  a la pregunta ' || x.campo04
                                       || '--> ' || ' no tiene el formato correcto'
                                       || x.campo05;
--                        END IF;
                        RAISE e_errdatos;
                     END IF;

                     reg_migpreggaran.mig_pk := reg_migseg.mig_pk || '/' || x.campo01 || '/'
                                                || reg_migpreggaran.nriesgo || '/'
                                                || reg_migpreggaran.cgarant || '/'
                                                || reg_migpreggaran.cpregun;

                     INSERT INTO mig_pregungaranseg
                          VALUES reg_migpreggaran
                       RETURNING ROWID
                            INTO v_rowid;

                     INSERT INTO mig_pk_emp_mig
                          VALUES (0, v_ncarga, 9, reg_migpreggaran.mig_pk);
                  ELSIF v_toperacion = 'MODI' THEN
                     v_ntraza := 9200;

                     BEGIN
                        SELECT c.ctippre
                          INTO v_ctippre
                          FROM pregunprogaran p, codipregun c
                         WHERE p.sproduc = reg_migseg.sproduc
                           AND p.cactivi = reg_migseg.cactivi
                           AND p.cgarant = x.campo03
                           AND p.cpregun = x.campo04
                           AND c.cpregun = p.cpregun;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           v_tdeserror := 'Garantia: ' || reg_migpreggaran.cgarant
                                          || ' Pregunta ' || reg_migpreggaran.cpregun;
                           v_nnumerr := 1000600;
                           RAISE e_errdatos;
                     END;

                     IF v_ctippre = 4 THEN   --la pregunta es de tipo fecha y vendra en formato dd/MM/YYYY y la tengo que transformar a YYYYMMDD
                        reg_migpreggaran.crespue :=
                                                TO_CHAR(f_chartodate(x.campo05), 'DD/MM/YYYY');
                     ELSE
                        IF v_ctippre IN(1, 2, 3) THEN
                           reg_migpreggaran.crespue := f_chartonumber(x.campo05);
                        ELSE
                           reg_migpreggaran.crespue := x.campo05;
                        END IF;
                     END IF;

                     IF reg_migpreggaran.crespue IS NULL THEN
--                        IF reg_migseg.sproduc = 7001
--                           AND k_tablas = 'MIG'
--                           AND pac_md_common.f_get_cxtempresa() = 17 THEN
--                           v_tdeserror :=
--                              'Migraci¿n Renta Vitalicia: la respuesta a la pregunta '
--                              || x.campo04 || ' no tiene el formato correcto.';
--                        ELSIF reg_migseg.sproduc = 7004
--                              AND k_tablas = 'MIG'
--                              AND pac_md_common.f_get_cxtempresa() = 17 THEN
--                           v_tdeserror :=
--                              'Migraci¿n Conmutaci¿n Pensional: la respuesta a la pregunta '
--                              || x.campo04 || ' no tiene el formato correcto.';
--                        ELSE
                        v_tdeserror := f_desproducto_t(v_cramo, v_cmodali, v_ctipseg,
                                                       v_ccolect, 1, k_cidioma)
                                       || ': La respueta  a la pregunta ' || x.campo04
                                       || '--> ' || ' no tiene el formato correcto'
                                       || x.campo05;
--                        END IF;
                        RAISE e_errdatos;
                     END IF;

                     SELECT NVL(MAX(nmovima), v_nmovimi)
                       INTO v_nmovima
                       FROM estpregungaranseg
                      WHERE sseguro = v_sseguroest
                        AND nriesgo = x.campo02
                        AND cgarant = x.campo03
                        AND nmovimi = v_nmovimi
                        AND cpregun = x.campo04;

                     BEGIN
                        INSERT INTO estpregungaranseg
                                    (sseguro, nriesgo, cgarant, nmovimi,
                                     cpregun,
                                     crespue,
                                     nmovima, finiefe,
                                     trespue)
                             VALUES (v_sseguroest, x.campo02, x.campo03, v_nmovimi,
                                     x.campo04,
                                     DECODE(v_ctippre,
                                            4, NULL,
                                            5, NULL,
                                            reg_migpreggaran.crespue),
                                     v_nmovima, v_fsuplemento,
                                     DECODE(v_ctippre,
                                            4, reg_migpreggaran.crespue,
                                            5, reg_migpreggaran.crespue,
                                            NULL));
                     EXCEPTION
                        WHEN DUP_VAL_ON_INDEX THEN
                           UPDATE estpregungaranseg
                              SET crespue = DECODE(v_ctippre,
                                                   4, NULL,
                                                   5, NULL,
                                                   reg_migpreggaran.crespue),
                                  trespue = DECODE(v_ctippre,
                                                   4, reg_migpreggaran.crespue,
                                                   5, reg_migpreggaran.crespue,
                                                   NULL)
                            WHERE sseguro = v_sseguroest
                              AND nriesgo = x.campo02
                              AND cgarant = x.campo03
                              AND nmovimi = v_nmovimi
                              AND cpregun = x.campo04;
                     END;
                  END IF;
-- a¿ado pregunsegtab
               -- Registro 10 - preguntas garantias tabla
               ELSIF x.tiporegistro = '10' THEN   -- preguntas por garantias
                  v_ntraza := 10000;

                  IF v_toperacion = 'ALTA' THEN
                     INSERT INTO mig_cargas_tab_mig
                                 (ncarga, tab_org, tab_des, ntab)
                          VALUES (v_ncarga, 'INT_CARGA_GENERICO', 'MIG_PREGUNSEGTAB', 100);

                     v_ntraza := 10010;
                     reg_migpregtab := NULL;
                     reg_migpregtab.ncarga := v_ncarga;
                     reg_migpregtab.cestmig := 1;
                     reg_migpregtab.sseguro := 0;
                     reg_migpregtab.mig_fk := reg_migseg.mig_pk;
                     reg_migpregtab.nmovimi := x.campo01;
                     reg_migpregtab.nriesgo := x.campo02;
                     reg_migpregtab.cpregun := x.campo03;
                     reg_migpregtab.fila := x.campo04;
                     reg_migpregtab.columna := x.campo05;
                     reg_migpregtab.mig_pk := reg_migseg.mig_pk || '/'
                                              || reg_migpregtab.nmovimi || '/'
                                              || reg_migpregtab.nriesgo || '/'
                                              || reg_migpregtab.fila || '/'
                                              || reg_migpregtab.columna || '/'
                                              || reg_migpregtab.cpregun;

                     DECLARE
                        v_tipodato     pregunprotab.ctipdato%TYPE;
                     BEGIN
                        SELECT ctipdato
                          INTO v_tipodato
                          FROM pregunprotab
                         WHERE sproduc = reg_migseg.sproduc
                           AND cpregun = reg_migpregtab.cpregun
                           AND columna = reg_migpregtab.columna;

                        IF v_tipodato = 1 THEN
                           reg_migpregtab.crespue := f_chartonumber(x.campo06);
                        ELSE
                           reg_migpregtab.crespue := x.campo06;
                        END IF;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           v_tdeserror := 'Fila: ' || reg_migpregtab.fila || 'Columna: '
                                          || reg_migpregtab.columna || ' Pregunta '
                                          || reg_migpreggaran.cpregun;
                           v_nnumerr := 102741;
                           RAISE e_errdatos;
                     END;

                     INSERT INTO mig_pregunsegtab
                          VALUES reg_migpregtab
                       RETURNING ROWID
                            INTO v_rowid;

                     INSERT INTO mig_pk_emp_mig
                          VALUES (0, v_ncarga, 10, reg_migpregtab.mig_pk);
                  ELSIF v_toperacion = 'MODI' THEN
                     NULL;
                  END IF;
               ELSIF x.tiporegistro = '11' THEN   -- registro de ahorro de rentas
                  v_ntraza := 11000;

                  IF v_toperacion = 'MODI' THEN
                     --   v_sseguroest
                     reg_migseg.mig_pk := v_ncarga || '/' || x.proceso || '/' || x.nlinea;

                     INSERT INTO mig_seguros
                                 (ncarga, cestmig, mig_pk, mig_fk, cagente, npoliza,
                                  ncertif, fefecto, creafac, cactivi, ctiprea, cidioma,
                                  cforpag, cempres, sproduc, casegur, nsuplem, sseguro,
                                  sperson)
                          VALUES (v_ncarga, -1, reg_migseg.mig_pk, 0, reg_migseg.cagente, 0,
                                  0, f_sysdate, 0, 0, 0, 1,
                                  1, 1, reg_migseg.sproduc, 1, 1, v_sseguroest,
                                  0);
                  END IF;

                  IF v_toperacion IN('ALTA', 'MODI') THEN
                     INSERT INTO mig_cargas_tab_mig
                                 (ncarga, tab_org, tab_des, ntab)
                          VALUES (v_ncarga, 'INT_CARGA_GENERICO', 'MIG_SEGUROS_REN_AHO', 110);

                     v_ntraza := 10010;
                     reg_migrenaho := NULL;
                     reg_migrenaho.ncarga := v_ncarga;
                     reg_migrenaho.cestmig := 1;
                     reg_migrenaho.sseguro := 0;
                     reg_migrenaho.mig_pk := reg_migseg.mig_pk || '/' || x.campo01 || '/'
                                             || x.campo02 || '/' || x.campo03;
                     reg_migrenaho.mig_fk := reg_migseg.mig_pk;
                     reg_migrenaho.pinttec := NULL;
                     reg_migrenaho.pcapfall := NULL;
                     reg_migrenaho.pdoscab := NULL;

                     IF x.campo04 = ''
                        OR x.campo04 IS NULL THEN
                        v_tdeserror :=
                           f_desproducto_t(v_cramo, v_cmodali, v_ctipseg, v_ccolect, 1,
                                           k_cidioma)
                           || ': Se debe informar la forma de pago en el ahorro de rentas.';
                        RAISE e_errdatos;
                     END IF;

                     reg_migrenaho.cforpag := x.campo04;
                     reg_migrenaho.ndurper := NULL;
                     reg_migrenaho.frevisio := NULL;
                     reg_migrenaho.fppren := f_chartodate(x.campo03);
                     reg_migrenaho.frevant := NULL;
                     reg_migrenaho.nmesextra := x.campo05;
                     reg_migrenaho.imesextra := x.campo06;
                     reg_migrenaho.f1paren := f_chartodate(x.campo07);

                     IF x.campo05 IS NOT NULL
                        OR x.campo06 IS NOT NULL THEN
                        IF x.campo03 IS NULL THEN
                           v_tdeserror :=
                              f_desproducto_t(v_cramo, v_cmodali, v_ctipseg, v_ccolect, 1,
                                              k_cidioma)
                              || ': Se debe informar la fecha de pago de la pr¿xima renta en el ahorro de rentas.';
                           RAISE e_errdatos;
                        ELSIF x.campo07 IS NULL THEN
                           v_tdeserror :=
                              f_desproducto_t(v_cramo, v_cmodali, v_ctipseg, v_ccolect, 1,
                                              k_cidioma)
                              || ': Se debe informar la fecha de primer pago de renta en el ahorro de rentas.';
                           RAISE e_errdatos;
                        END IF;
                     END IF;

-- solo puede haber un registro--- borro si existe uno  para dejar el movimiento mas alto
                     DELETE      mig_seguros_ren_aho
                           WHERE ncarga = reg_migrenaho.ncarga;

                     INSERT INTO mig_seguros_ren_aho
                          VALUES reg_migrenaho
                       RETURNING ROWID
                            INTO v_rowid;

                     INSERT INTO mig_pk_emp_mig
                          VALUES (0, v_ncarga, 11, reg_migrenaho.mig_pk);
                  END IF;

                  IF v_toperacion = 'MODI' THEN
                     v_nnumerr := f_lanza_migracion(v_id, v_ncarga);

                     IF v_nnumerr NOT IN(0, 2, 4) THEN   -- si ha habido error
                        ROLLBACK;

                        IF k_cpara_error <> 1 THEN
                           v_ntipoerror := 4;
                        -- para que continue con la siguiente linea.
                        ELSE
                           v_ntipoerror := 1;   -- para la carga
                           RAISE e_salir;
                        END IF;
                     END IF;
                  END IF;
               ELSIF x.tiporegistro = '12' THEN   -- Registro de comisi¿n especial de seguro
                  v_ntraza := 12000;

                  IF v_toperacion = 'ALTA' THEN
                     INSERT INTO mig_cargas_tab_mig
                                 (ncarga, tab_org, tab_des, ntab)
                          VALUES (v_ncarga, 'INT_CARGA_GENERICO', 'MIG_COMISIONSEGU', 120);

                     v_ntraza := 12010;
                     reg_comisionsegu := NULL;
                     reg_comisionsegu.ncarga := v_ncarga;
                     reg_comisionsegu.cestmig := 1;
                     reg_comisionsegu.mig_fk := reg_migseg.mig_pk;
                     reg_comisionsegu.cmodcom := x.campo02;
                     reg_comisionsegu.pcomisi := NVL(f_chartonumber(x.campo03), 0);
                     reg_comisionsegu.ninialt := NVL(f_chartonumber(x.campo04), 0);
                     reg_comisionsegu.nfinalt := NVL(f_chartonumber(x.campo05), 0);
                     reg_comisionsegu.nmovimi := x.campo01;

                     IF NVL(reg_comisionsegu.ninialt, 9999) >
                                                            NVL(reg_comisionsegu.nfinalt, 9999) THEN
                        v_tdeserror := 'Inicion altura: ' || reg_comisionsegu.ninialt
                                       || ' no puede ser mayor que fin de altura  '
                                       || reg_comisionsegu.nfinalt;
                        v_nnumerr := 1000450;
                        RAISE e_errdatos;
                     END IF;

                     reg_comisionsegu.mig_pk := reg_migseg.mig_pk || '/' || x.campo01 || '/'
                                                || reg_comisionsegu.cmodcom || '/'
                                                || reg_comisionsegu.ninialt || '/'
                                                || reg_comisionsegu.nfinalt;

                     INSERT INTO mig_comisionsegu
                          VALUES reg_comisionsegu
                       RETURNING ROWID
                            INTO v_rowid;

                     INSERT INTO mig_pk_emp_mig
                          VALUES (0, v_ncarga, 12, reg_comisionsegu.mig_pk);
                  ELSIF v_toperacion = 'MODI' THEN
                     NULL;
                  END IF;
               -- Resgistro de cocorretaje
               -- registro coaseguro
               ELSIF x.tiporegistro = '13' THEN   -- Cabecera coaseguro coacuadro
                  v_ntraza := 13000;

                  IF v_toperacion = 'ALTA' THEN
                     INSERT INTO mig_cargas_tab_mig
                                 (ncarga, tab_org, tab_des, ntab)
                          VALUES (v_ncarga, 'INT_CARGA_GENERICO', 'MIG_COACUADRO', 130);

                     reg_migcoacuadro := NULL;
                     reg_migcoacuadro.ncarga := v_ncarga;
                     reg_migcoacuadro.cestmig := 1;
                     reg_migcoacuadro.mig_pk := reg_migseg.mig_pk || '/' || x.campo01 || '/'
                                                || x.campo02;
                     reg_migcoacuadro.mig_fk := reg_migseg.mig_pk;
                     -- SSEGURO  NUMBER NOT NULL,
                     reg_migcoacuadro.ncuacoa := x.campo02;
                     reg_migcoacuadro.finicoa := f_chartodate(x.campo03);
                     reg_migcoacuadro.ffincoa := f_chartodate(x.campo04);
                     reg_migcoacuadro.ploccoa := f_chartonumber(x.campo05);
                     -- INI RLLF 30/03/2015 Modificaci¿n coaseguro
                     --reg_migcoacuadro.PLOCCOA  := f_chartonumber(x.campo05);
                     reg_migcoacuadro.ploccoa := f_chartonumber(x.campo06);
                     -- FIN RLLF 30/03/2015 Modificaci¿n coaseguro
                     reg_migcoacuadro.fcuacoa := f_sysdate;
                     reg_migcoacuadro.ccompan := x.campo07;
                     reg_migcoacuadro.npoliza := x.campo08;

                     UPDATE mig_seguros
                        SET ncuacoa = x.campo02,
                            ctipcoa = 8
                      WHERE mig_pk = reg_migseg.mig_pk;

                     INSERT INTO mig_coacuadro
                          VALUES reg_migcoacuadro
                       RETURNING ROWID
                            INTO v_rowid;

                     INSERT INTO mig_pk_emp_mig
                          VALUES (0, v_ncarga, 13, reg_migcoacuadro.mig_pk);
                  ELSIF v_toperacion = 'MODI' THEN   -- realmente no tiene sentido que se haga un suplemente de coaseguro
                     NULL;   --- no hago nada de momento
                  END IF;
               ELSIF x.tiporegistro = '13B' THEN   -- Detalle coaseguro cedido
                  v_ntraza := 13500;

                  IF v_toperacion = 'ALTA' THEN
                     INSERT INTO mig_cargas_tab_mig
                                 (ncarga, tab_org, tab_des, ntab)
                          VALUES (v_ncarga, 'INT_CARGA_GENERICO', 'MIG_COACEDIDO', 135);

                     reg_migcoacedido := NULL;
                     reg_migcoacedido.ncarga := v_ncarga;
                     reg_migcoacedido.cestmig := 1;
                     reg_migcoacedido.mig_pk := reg_migcoacuadro.mig_pk || '/' || x.campo02;
                     reg_migcoacedido.mig_fk := reg_migseg.mig_pk;
                     -- SSEGURO  NUMBER NOT NULL,
                     reg_migcoacedido.ncuacoa := reg_migcoacuadro.ncuacoa;
                     reg_migcoacedido.ccompan := x.campo02;
                     reg_migcoacedido.pcescoa := f_chartonumber(x.campo03);
                     reg_migcoacedido.pcomcoa := f_chartonumber(x.campo04);
                     reg_migcoacedido.pcomcon := f_chartonumber(x.campo05);
                     reg_migcoacedido.pcomgas := f_chartonumber(x.campo06);
                     reg_migcoacedido.pcesion := f_chartonumber(x.campo07);

                     UPDATE mig_seguros
                        SET ctipcoa = 1
                      WHERE mig_pk = reg_migseg.mig_pk;

                     INSERT INTO mig_coacedido
                          VALUES reg_migcoacedido
                       RETURNING ROWID
                            INTO v_rowid;

                     INSERT INTO mig_pk_emp_mig
                          VALUES (0, v_ncarga, 13, reg_migcoacedido.mig_pk);
                  ELSIF v_toperacion = 'MODI' THEN   -- realmente no tiene sentido que se haga un suplemente de coaseguro
                     NULL;   --- no hago nada de momento
                  END IF;
               ELSIF x.tiporegistro = '15' THEN
                  v_ntraza := 15000;

                  IF v_toperacion = 'MODI' THEN
                     --   v_sseguroest
                     reg_migseg.mig_pk := v_ncarga || '/' || x.proceso || '/' || x.nlinea;

                     INSERT INTO mig_seguros
                                 (ncarga, cestmig, mig_pk, mig_fk, cagente, npoliza,
                                  ncertif, fefecto, creafac, cactivi, ctiprea, cidioma,
                                  cforpag, cempres, sproduc, casegur, nsuplem, sseguro,
                                  sperson)
                          VALUES (v_ncarga, -1, reg_migseg.mig_pk, 0, reg_migseg.cagente, 0,
                                  0, f_sysdate, 0, 0, 0, 1,
                                  1, 1, reg_migseg.sproduc, 1, 1, v_sseguro,
                                  0);
                  END IF;

                  IF v_toperacion IN('ALTA', 'MODI') THEN
                     INSERT INTO mig_cargas_tab_mig
                                 (ncarga, tab_org, tab_des, ntab)
                          VALUES (v_ncarga, 'INT_CARGA_GENERICO', 'MIG_AGE_CORRETAJE', 150);

                     v_ntraza := 15010;
                     reg_migagecorretaje := NULL;
                     reg_migagecorretaje.ncarga := v_ncarga;
                     reg_migagecorretaje.cestmig := 1;
                     reg_migagecorretaje.mig_pk :=
                        reg_migseg.mig_pk || '/' || x.campo01 || '/' || x.campo02 || '/'
                        || x.nlinea;
                     reg_migagecorretaje.mig_fk := reg_migmovseg.mig_pk;
                     reg_migagecorretaje.sseguro := 0;
                     -- INI 16022015 BUG-34638 No permite la migraci¿n de p¿lizas de ARL con co-corretaje
                     --reg_migagecorretaje.nmovimi := NVL(v_nmovimi, 1);
                     reg_migagecorretaje.nmovimi := NVL(x.campo01, 1);
                     -- FIN 16022015 BUG-34638 No permite la migraci¿n de p¿lizas de ARL con co-corretaje
                     reg_migagecorretaje.nordage := x.campo02;
                     reg_migagecorretaje.cagente := x.campo03;
                     reg_migagecorretaje.pcomisi := f_chartonumber(x.campo04);
                     reg_migagecorretaje.ppartici := f_chartonumber(x.campo05);
                     reg_migagecorretaje.islider := NVL(x.campo06, 0);

-- solo puede haber un registro--- borro si existe uno  para dejar el movimiento mas alto
                     INSERT INTO mig_age_corretaje
                          VALUES reg_migagecorretaje
                       RETURNING ROWID
                            INTO v_rowid;

                     INSERT INTO mig_pk_emp_mig
                          VALUES (0, v_ncarga, 15, reg_migagecorretaje.mig_pk);
                  END IF;

                  IF v_toperacion = 'MODI' THEN
                     v_nnumerr := f_lanza_migracion(v_id, v_ncarga);

                     IF v_nnumerr NOT IN(0, 2, 4) THEN   -- si ha habido error
                        ROLLBACK;

                        IF k_cpara_error <> 1 THEN
                           v_ntipoerror := 4;
                        -- para que continue con la siguiente linea.
                        ELSE
                           v_ntipoerror := 1;   -- para la carga
                           RAISE e_salir;
                        END IF;
                     END IF;
                  END IF;
               -- Registro de agenda
               ELSIF x.tiporegistro = '16' THEN
                  v_ntraza := 16000;

                  IF v_toperacion = 'MODI' THEN
                     --   v_sseguroest
                     reg_migseg.mig_pk := v_ncarga || '/' || x.proceso || '/' || x.nlinea;

                     INSERT INTO mig_seguros
                                 (ncarga, cestmig, mig_pk, mig_fk, cagente, npoliza,
                                  ncertif, fefecto, creafac, cactivi, ctiprea, cidioma,
                                  cforpag, cempres, sproduc, casegur, nsuplem, sseguro,
                                  sperson)
                          VALUES (v_ncarga, -1, reg_migseg.mig_pk, 0, reg_migseg.cagente, 0,
                                  0, f_sysdate, 0, 0, 0, 1,
                                  1, 1, reg_migseg.sproduc, 1, 1, v_sseguro,
                                  0);
                  END IF;

                  IF v_toperacion IN('ALTA', 'MODI') THEN
                     INSERT INTO mig_cargas_tab_mig
                                 (ncarga, tab_org, tab_des, ntab)
                          VALUES (v_ncarga, 'INT_CARGA_GENERICO', 'MIG_AGENSEGU', 160);

                     v_ntraza := 10010;
                     reg_migagensegu := NULL;
                     reg_migagensegu.ncarga := v_ncarga;
                     reg_migagensegu.cestmig := 1;
                     reg_migagensegu.sseguro := 0;
                     reg_migagensegu.mig_pk := reg_migseg.mig_pk || '/' || x.campo01 || '/'
                                               || x.nlinea;
                     reg_migagensegu.mig_fk := reg_migseg.mig_pk;
                     reg_migagensegu.ctipreg := x.campo02;
                     reg_migagensegu.cestado := x.campo03;
                     reg_migagensegu.ttitulo := SUBSTR(x.campo04, 1, 100);
                     reg_migagensegu.ttextos := SUBSTR(x.campo05, 1, 4000);
                     reg_migagensegu.falta := f_chartodate(x.campo06);
                     reg_migagensegu.ffinali := f_chartodate(x.campo07);
                     reg_migagensegu.cmanual := x.campo08;

-- solo puede haber un registro--- borro si existe uno  para dejar el movimiento mas alto
                     INSERT INTO mig_agensegu
                          VALUES reg_migagensegu
                       RETURNING ROWID
                            INTO v_rowid;

                     INSERT INTO mig_pk_emp_mig
                          VALUES (0, v_ncarga, 16, reg_migagensegu.mig_pk);
                  END IF;

                  IF v_toperacion = 'MODI' THEN
                     v_nnumerr := f_lanza_migracion(v_id, v_ncarga);

                     IF v_nnumerr NOT IN(0, 2, 4) THEN   -- si ha habido error
                        ROLLBACK;

                        IF k_cpara_error <> 1 THEN
                           v_ntipoerror := 4;
                        -- para que continue con la siguiente linea.
                        ELSE
                           v_ntipoerror := 1;   -- para la carga
                           RAISE e_salir;
                        END IF;
                     END IF;
                  END IF;
               -- Registro de clausulas
               ELSIF x.tiporegistro = '17' THEN
                  v_ntraza := 17000;

                  IF v_toperacion = 'MODI' THEN
                     --   v_sseguroest
                     reg_migseg.mig_pk := v_ncarga || '/' || x.proceso || '/' || x.nlinea;

                     INSERT INTO mig_seguros
                                 (ncarga, cestmig, mig_pk, mig_fk, cagente, npoliza,
                                  ncertif, fefecto, creafac, cactivi, ctiprea, cidioma,
                                  cforpag, cempres, sproduc, casegur, nsuplem, sseguro,
                                  sperson)
                          VALUES (v_ncarga, -1, reg_migseg.mig_pk, 0, reg_migseg.cagente, 0,
                                  0, f_sysdate, 0, 0, 0, 1,
                                  1, 1, reg_migseg.sproduc, 1, 1, v_sseguro,
                                  0);
                  END IF;

                  IF v_toperacion IN('ALTA', 'MODI') THEN
                     INSERT INTO mig_cargas_tab_mig
                                 (ncarga, tab_org, tab_des, ntab)
                          VALUES (v_ncarga, 'INT_CARGA_GENERICO', 'MIG_CLAUSUESP', 160);

                     v_ntraza := 10010;
                     reg_migclausuesp := NULL;
                     reg_migclausuesp.ncarga := v_ncarga;
                     reg_migclausuesp.cestmig := 1;
                     reg_migclausuesp.sseguro := 0;
                     reg_migclausuesp.mig_pk := reg_migseg.mig_pk || '/' || x.campo01 || '/'
                                                || x.campo02 || '/' || x.nlinea;
                     reg_migclausuesp.mig_fk := reg_migmovseg.mig_pk;

                     IF k_tablas <> 'MIG' THEN
                        reg_migclausuesp.nmovimi := NVL(v_nmovimi, 1);
                     ELSE
                        reg_migclausuesp.nmovimi := x.campo01;
                     END IF;

                     reg_migclausuesp.nriesgo := x.campo02;
                     reg_migclausuesp.nordcla := x.campo03;
                     reg_migclausuesp.cclaesp := x.campo04;
                     reg_migclausuesp.finiclau := f_chartodate(x.campo05);
                     reg_migclausuesp.sclagen := x.campo08;   -- clausula general o de beneficiario
                     reg_migclausuesp.ffinclau := f_chartodate(x.campo06);
                     reg_migclausuesp.tclaesp := x.campo07;

-- solo puede haber un registro--- borro si existe uno  para dejar el movimiento mas alto
                     INSERT INTO mig_clausuesp
                          VALUES reg_migclausuesp
                       RETURNING ROWID
                            INTO v_rowid;

                     INSERT INTO mig_pk_emp_mig
                          VALUES (0, v_ncarga, 17, reg_migclausuesp.mig_pk);
                  END IF;

                  IF v_toperacion = 'MODI' THEN
                     v_nnumerr := f_lanza_migracion(v_id, v_ncarga);

                     IF v_nnumerr NOT IN(0, 2, 4) THEN   -- si ha habido error
                        ROLLBACK;

                        IF k_cpara_error <> 1 THEN
                           v_ntipoerror := 4;
                        -- para que continue con la siguiente linea.
                        ELSE
                           v_ntipoerror := 1;   -- para la carga
                           RAISE e_salir;
                        END IF;
                     END IF;
                  END IF;
               -- cuenta seguro
               ELSIF x.tiporegistro = '21' THEN
                  v_ntraza := 21000;

                  IF v_toperacion = 'ALTA' THEN
                     INSERT INTO mig_cargas_tab_mig
                                 (ncarga, tab_org, tab_des, ntab)
                          VALUES (v_ncarga, 'INT_CARGA_GENERICO', 'MIG_CTASEGURO', 210);

                     reg_migctaseguro := NULL;
                     reg_migctaseguro.ncarga := v_ncarga;
                     reg_migctaseguro.cestmig := 1;
                     reg_migctaseguro.mig_pk := reg_migseg.mig_pk || '/' || x.campo01;
                     reg_migctaseguro.mig_fk := reg_migseg.mig_pk;
                     -- SSEGURO  NUMBER NOT NULL,
                     reg_migctaseguro.sseguro := 0;
                     reg_migctaseguro.nnumlin := x.campo01;
                     reg_migctaseguro.ffecmov := f_chartodate(x.campo02);
                     reg_migctaseguro.fvalmov := f_chartodate(x.campo03);
                     reg_migctaseguro.fcontab := f_chartodate(x.campo04);
                     reg_migctaseguro.cmovimi := x.campo05;
                     reg_migctaseguro.imovimi := f_chartonumber(x.campo06);
                     reg_migctaseguro.nrecibo := x.campo07;
                     reg_migctaseguro.smovrec := x.campo08;
                     reg_migctaseguro.nsinies := x.campo09;
                     reg_migctaseguro.cmovanu := x.campo10;
                     reg_migctaseguro.cesta := x.campo11;
                     reg_migctaseguro.nunidad := x.campo12;
                     reg_migctaseguro.fasign := f_chartodate(x.campo13);
                     reg_migctaseguro.sidepag := x.campo16;
                     reg_migctaseguro.ctipapor := x.campo17;
                     reg_migctaseguro.srecren := x.campo18;
                     reg_migctaseguro.ccalint := 0;
                     reg_migctaseguro.imovim2 := f_chartonumber(x.campo06);
                     reg_migctaseguro.cestado := NULL;
                     reg_migctaseguro.nparpla := NULL;
                     reg_migctaseguro.cestpar := NULL;
                     reg_migctaseguro.iexceso := NULL;
                     reg_migctaseguro.spermin := NULL;

                     INSERT INTO mig_ctaseguro
                          VALUES reg_migctaseguro
                       RETURNING ROWID
                            INTO v_rowid;

                     INSERT INTO mig_pk_emp_mig
                          VALUES (0, v_ncarga, 21, reg_migctaseguro.mig_pk);
                  ELSIF v_toperacion = 'MODI' THEN
                     NULL;   --- no hago nada de momento
                  END IF;
               -- cuenta seguro
               -- ini rllf 22092015 a¿adir mig_garanseg y mig_pbex
               -- detalle de garantias.
               ELSIF x.tiporegistro = '22' THEN
                  v_ntraza := 22000;

                  IF v_toperacion = 'ALTA' THEN
                     INSERT INTO mig_cargas_tab_mig
                                 (ncarga, tab_org, tab_des, ntab)
                          VALUES (v_ncarga, 'INT_CARGA_GENERICO', 'MIG_DETGARANSEG', 71);

                     reg_miggardet := NULL;
                     reg_miggardet.ncarga := v_ncarga;
                     reg_miggardet.cestmig := 1;
                     reg_miggardet.sseguro := 0;
                     reg_miggardet.cgarant := f_chartonumber(x.campo01);
                     reg_miggardet.nmovimi := f_chartonumber(x.campo02);
                     reg_miggardet.nriesgo := x.campo03;
                     reg_miggardet.finiefe := f_chartodate(x.campo04);
                     reg_miggardet.fefecto := f_chartodate(x.campo05);
                     reg_miggardet.ndetgar := f_chartonumber(x.campo06);
                     reg_miggardet.fvencim := x.campo07;
           reg_miggardet.icapital := f_chartonumber(x.campo08);
                     reg_miggardet.iprianu := f_chartonumber(x.campo09);
           reg_miggardet.ipritar := f_chartonumber(x.campo10);
                     reg_miggardet.mig_pk := reg_miggar.mig_pk || '/' || reg_miggardet.finiefe
                                             || '/' || reg_miggardet.ndetgar;
                     reg_miggardet.mig_fk := reg_migmovseg.mig_pk;

                     INSERT INTO mig_detgaranseg
                          VALUES reg_miggardet
                       RETURNING ROWID
                            INTO v_rowid;

                     INSERT INTO mig_pk_emp_mig
                          VALUES (0, v_ncarga, 22, reg_miggardet.mig_pk);
                  ELSIF v_toperacion = 'MODI' THEN
                     NULL;   --- no hago nada de momento
                  END IF;
               -- fin rllf rll 22092015 a¿adir mig_garanseg y mig_pbex

               -- ini rllf 23092015 a¿adir mig_garanseg y mig_pbex
               -- detalle de garantias.
               ELSIF x.tiporegistro = '23' THEN
                  v_ntraza := 23000;

                  IF v_toperacion = 'ALTA' THEN
                     p_control_error('rllf', 'pac_cargas_generico.migra', 'paso 1');

                     INSERT INTO mig_cargas_tab_mig
                                 (ncarga, tab_org, tab_des, ntab)
                          VALUES (v_ncarga, 'INT_CARGA_GENERICO', 'MIG_PBEX', 72);

                     p_control_error('rllf', 'pac_cargas_generico.migra', 'paso 2');

                     SELECT (NVL(MIN(sproces), 0) - 1)
                       INTO vprocespb
                       FROM mig_pbex;

                     reg_migpbex := NULL;
                     reg_migpbex.cempres := k_cempresa;
                     reg_migpbex.ncarga := v_ncarga;
                     reg_migpbex.cestmig := 1;
                     reg_migpbex.sseguro := 0;
                     reg_migpbex.sproces := vprocespb;
                     reg_migpbex.cramo := v_cramo;
                     reg_migpbex.cmodali := v_cmodali;
                     reg_migpbex.ctipseg := v_ctipseg;
                     reg_migpbex.ccolect := v_ccolect;
                     reg_migpbex.cramdgs := v_cramdgs;
                     reg_migpbex.cgarant := f_chartonumber(x.campo01);
                     reg_migpbex.nriesgo := f_chartonumber(x.campo02);
                     reg_migpbex.fcalcul := f_chartodate(x.campo03);
                     reg_migpbex.ivalact := f_chartonumber(x.campo04);
                     reg_migpbex.icapgar := NVL(f_chartonumber(x.campo05), 0);
                     reg_migpbex.ipromat := NVL(f_chartonumber(x.campo06), 0);
                     reg_migpbex.cerror := NVL(f_chartonumber(x.campo07), 0);
                     reg_migpbex.mig_pk := reg_migpbex.sproces || '/' || reg_migseg.mig_pk
                                           || '/' || reg_migpbex.fcalcul || '/'
                                           || reg_migpbex.nriesgo || '/' || reg_migpbex.cgarant;
                     reg_migpbex.mig_fk := reg_migseg.mig_pk;
                     p_control_error('rllf', 'pac_cargas_generico.migra', 'paso 3');

                     INSERT INTO mig_pbex
                          VALUES reg_migpbex
                       RETURNING ROWID
                            INTO v_rowid;

                     p_control_error('rllf', 'pac_cargas_generico.migra',
                                     'paso 4 v_ncarga:' || v_ncarga || ' reg_miggardet.mig_pk:'
                                     || reg_miggardet.mig_pk);

                     INSERT INTO mig_pk_emp_mig
                          VALUES (0, v_ncarga, 23, reg_migpbex.mig_pk);
                  ELSIF v_toperacion = 'MODI' THEN
                     NULL;   --- no hago nada de momento
                  END IF;
               -- fin rllf rll 23092015 a¿adir mig_garanseg y mig_pbex
               ELSE
                  -- no se encuentra el tipo de registro
                  v_nnumerr := 9902907;
                  v_tdeserror := 'El tipo resgistro (campo01): ' || x.tiporegistro || ' '
                                 || 'no parametrizado.';
                  v_nnumerr1 := p_marcalinea(p_ssproces, v_id_linea, v_toperacion, 1, 0, NULL,
                                             v_id, v_ncarga);
                  v_nnumerr := p_marcalineaerror(p_ssproces, v_id_linea, NULL, 1,
                                                 NVL(v_nnumerr, 1), NVL(v_tdeserror, -1));
                  RAISE e_salir;
               END IF;
            ELSE
                --NULL;   -- la dejo como pendiente, viene con de un error
               -- Si llega un registro que no tiene cabecera lo marcamos como warning
               IF v_id IS NULL THEN   -- sino pertenece a ninguna p¿liza
                  v_nnumerr := 9902907;
                  v_tdeserror :=
                     'El tipo registro (tipo registro): ' || x.tiporegistro || ' '
                     || 'no precede de un tipo registro de p¿liza valido o movimiento de p¿liza.';
                  v_nnumerr := p_marcalinea(p_ssproces, v_id_linea, v_toperacion, 2, 0, NULL,
                                            v_id, v_ncarga, NULL, NULL, NULL, NULL,
                                            x.nlinea || '(' || x.tiporegistro || ')');
                  v_nnumerr := p_marcalineaerror(p_ssproces, v_id_linea, NULL, 2,
                                                 NVL(v_nnumerr, 1), NVL(v_tdeserror, -1));
               END IF;
--
            END IF;   -- v_toperacion

            v_ntraza := 9090;
         EXCEPTION
            WHEN e_errdatos THEN
               ROLLBACK;
               v_berrorproc := TRUE;
               v_nnumerr := f_marcar_lineas(p_ssproces, v_ncarga, 1,   -- pongo error
                                            v_toperacion, NVL(v_nnumerr, 1),
                                            NVL(v_ntraza || '-' || v_tdeserror, -1), NULL,
                                            x.nlinea, NULL, NULL, NULL);

               IF k_cpara_error <> 1 THEN
                  v_ntipoerror := 4;
               -- para que continue con la siguiente linea.
               ELSE
                  v_ntipoerror := 1;   -- para la carga
                  RAISE e_salir;
               END IF;
            -- debo obviar todas las lineas hasta la siguiente linea 1
            WHEN e_salir THEN   -- salgo del cursor
               RAISE;
            WHEN OTHERS THEN
               v_nnumerr := SQLCODE;
               v_tdeserror := v_ntraza || ' en f_pol_ejecutar_carga_proceso -' || SQLERRM;
               ROLLBACK;
               v_berrorproc := TRUE;
               v_nnumerr := f_marcar_lineas(p_ssproces, v_ncarga, 1,   -- pongo error
                                            v_toperacion, v_nnumerr, v_tdeserror, NULL,
                                            x.nlinea, NULL, NULL, NULL);

               IF k_cpara_error <> 1 THEN
                  v_ntipoerror := 4;
               -- para que continue con la siguiente linea.
               ELSE
                  v_ntipoerror := 1;   -- para la carga
                  RAISE e_salir;
               END IF;
         END;
      END LOOP;

      v_ntraza := 9500;

      IF v_id IS NOT NULL
         AND v_ntipoerror NOT IN(1, 4) THEN
         -- lanza la ultima migraci¿n, cuando acaba el fichero
         IF v_toperacion = 'ALTA' THEN
            v_nnumerr := f_lanza_migracion(v_id, v_ncarga);
         ELSIF v_toperacion = 'MODI' THEN   -- ejecuto el suplemento
            v_nnumerr := p_finalizar_suple(v_ncarga, v_sseguroest, v_nmovimi, v_sseguro,
                                           v_tdeserror, p_ssproces);

            -- tengo que grabar el resultado
            IF v_nnumerr <> 0 THEN
               v_berrorproc := TRUE;
               v_nnumerr := f_marcar_lineas(p_ssproces, v_ncarga, 1,   -- pongo error
                                            v_toperacion, v_nnumerr, v_tdeserror, NULL, NULL,
                                            NULL, NULL, NULL);
            ELSE
               v_nnumerr := f_marcar_lineas(p_ssproces, v_ncarga, 4,   -- pongo ok
                                            v_toperacion, v_nnumerr, NULL, v_sseguro, NULL,
                                            NULL, NULL, NULL);
            END IF;
         END IF;

         IF v_nnumerr NOT IN(0, 2, 4) THEN   -- si ha habido error
            v_berrorproc := TRUE;
            ROLLBACK;
         ELSE
            COMMIT;
         END IF;
      END IF;

      /* de momento no se emite el certificado 0
                                                                                                                                                                                                                                                                         -- ok he acabado de cargar todo el fichero tengo que emitir
            -- Ojo deberia coger una coleccion
            IF NOT v_berrorproc THEN -- si no ha habido errores
             for reg in (select distinct sseguro  sseguro
                           from seguros seg, int_carga_generico carg
                          where seg.npoliza = carg.campo03
                            and seg.ncertif = 0
                            and carg.proceso = p_ssproces
                            and carg.tiporegistro = '1'
                         ) loop
               IF pac_seguros.f_es_col_admin(reg.sseguro) = 1  and pac_seguros.f_suplem_obert(reg.sseguro) = 0  THEN
                  v_sproces := p_ssproces;
                  v_nnumerr := pac_md_produccion.f_emitir_col_admin(reg.sseguro, v_sproces, mensajes);
                  IF v_nnumerr <> 0 THEN
                     v_ntraza := 8500;
                     IF mensajes IS NOT NULL THEN
                        FOR i IN mensajes.FIRST .. mensajes.LAST LOOP
                           v_tdeserror := mensajes(i).terror;
                           v_nnumerr  := mensajes(i).cerror;
                        END LOOP;
                     END IF;
                     rollback;
                     UPDATE   int_carga_ctrl
                         SET   cestado = 1,
                               ffin    = f_sysdate,
                               cerror  = 140730,
                               terror  = v_tdeserror
                        WHERE  sproces = v_sproces;
                       commit;
                     --  v_nnumerr := 140730;
                     --RAISE e_salir;
                  END IF;
                  COMMIT;  -- grabo la emision del colectivo
               END IF;
             END Loop;
            END IF;
      */
      v_ntraza := 9600;
/*
      --Generaci¿n documentaci¿n masiva diferida
--Tipo 46, documentaci¿n de cotizaci¿n masiva diferida
      IF NOT v_berrorproc THEN   -- si no ha habido errores
         FOR reg IN (SELECT   seg.sseguro
                         FROM seguros seg, int_carga_generico carg
                        WHERE seg.npoliza = carg.campo03
                          AND seg.ncertif = 0
                          AND carg.proceso = p_ssproces
                          AND carg.tiporegistro = '1'
                     GROUP BY seg.sseguro) LOOP
            FOR i IN (SELECT   s.sseguro, s.cidioma,
                               pac_isqlfor.f_max_nmovimi(s.sseguro) nmovimi, ppc.ctipo
                          FROM prod_plant_cab ppc, seguros s
                         WHERE s.sseguro = reg.sseguro
                           AND s.sproduc = ppc.sproduc
                           AND ppc.ctipo = 41
                      GROUP BY s.sseguro, s.cidioma, ppc.ctipo) LOOP
               pac_isql.p_ins_doc_diferida(i.sseguro, i.nmovimi, NULL, NULL, NULL, NULL, NULL,
                                           i.cidioma, i.ctipo);
            END LOOP;

            COMMIT;
         END LOOP;
      END IF;
*/
      v_ntraza := 9999;

      DECLARE
         vquery         VARCHAR2(2000);
      BEGIN
         vquery := ' UPDATE seguros  SET creteni = 0   WHERE sseguro IN ('
                   || vsseguroscargados || ') AND creteni = 20';

         EXECUTE IMMEDIATE vquery;
      END;

-------------------------------- final loop ------------------------------------
-- COMMIT;
      IF v_berrorproc THEN
         RETURN 1;
      ELSIF v_bavisproc THEN
         RETURN 2;
      ELSE
         RETURN 4;
      END IF;
   EXCEPTION
      WHEN e_salir THEN
         ROLLBACK;
         -- v_nnumerr := p_marcalinea(p_ssproces, v_id_linea, v_toperacion, 1, 0, NULL, v_id,
         --             v_ncarga);

         -- v_nnumerr := p_marcalineaerror(p_ssproces, v_id_linea, NULL, 1, NVL(v_nnumerr, 1),
         --           NVL(v_tdeserror, -1));
         RETURN 1;
      -- Fi Bug 16324
      WHEN OTHERS THEN
         v_nnumerr := SQLCODE;
         v_tdeserror := v_ntraza || ' en f_pol_ejecutar_carga_proceso: ' || SQLERRM;
         ROLLBACK;
         v_nnumerr1 := p_marcalinea(p_ssproces, v_id_linea, 0, 1, 0, NULL, v_id, v_ncarga);
         v_nnumerr := p_marcalineaerror(p_ssproces, v_id_linea, NULL, 1, v_nnumerr,
                                        v_tdeserror);
         p_genera_logs(v_tobjeto, v_ntraza, 'Error Incontrolado:' || v_nnumerr, v_tdeserror);
         RETURN 1;
   END f_pol_ejecutar_carga_proceso;

   /*************************************************************************
     Procedimiento que ejecuta una carga de recibos
       param in p_ssproces   : N¿mero proceso
       retorna 0 si ha ido bien, 1 en casos contrario
   *************************************************************************/
   FUNCTION f_rec_ejecutar_carga_proceso(p_ssproces IN NUMBER)
      RETURN NUMBER IS
      v_tobjeto      VARCHAR2(100) := 'pac_cargas_generico.f_pol_ejecutar_carga_proceso_rec';
      v_ntraza       NUMBER := 0;
      e_salir        EXCEPTION;

      CURSOR cur_rec(p_ssproces2 IN NUMBER) IS
         -- Abrimos los certificados como control, despu¿s buscamos todos los registros del fichero.
         SELECT   a.*
             FROM int_carga_generico a
            WHERE proceso = p_ssproces2
              AND NOT EXISTS(SELECT 1
                               FROM int_carga_ctrl_linea b
                              WHERE b.sproces = a.proceso
                                AND b.nlinea = a.nlinea
                                AND b.cestado IN(2, 4, 5, 6))
         ORDER BY nlinea, tiporegistro;   -- registro tipo certificado

      v_toperacion   VARCHAR2(20);
      v_berrorproc   BOOLEAN := FALSE;
      v_berrorlin    BOOLEAN := FALSE;
      v_bavisproc    BOOLEAN := FALSE;
      v_ntipoerror   NUMBER := 0;
--      reg_migseg     mig_seguros%ROWTYPE;
        --
      v_id           mig_cargas.ID%TYPE;
      v_id_linea     NUMBER;
      v_id_linea_1   NUMBER;
      v_sperson      per_personas.sperson%TYPE;
      v_sseguro      seguros.sseguro%TYPE;
      v_ncarga       int_carga_generico.ncarga%TYPE;
      vcmoneda       monedas.cmoneda%TYPE;
      --
      v_mig_seg      mig_seguros%ROWTYPE;
      v_mig_rec      mig_recibos%ROWTYPE;
      v_mig_movrec   mig_movrecibo%ROWTYPE;
      v_mig_recdet   mig_detrecibos%ROWTYPE;
      v_rowid        ROWID;
      v_admite_certificados parproductos.cvalpar%TYPE;

      /***************************************************************************
        FUNCTION f_lanza_migracio_rec
            Asigna n¿mero de carga
            Return: N¿mero de carga
        ***************************************************************************/
      FUNCTION f_lanza_migracion_rec(p_id IN VARCHAR2, p_ncarga IN NUMBER)
         RETURN NUMBER IS
         v_ntiperr      NUMBER := 0;
         vnrecibo       recibos.nrecibo%TYPE;
      BEGIN
         pac_mig_axis.p_migra_cargas(p_id, 'C', p_ncarga, 'DEL', k_tablas, 'RECIBO');

         --Cargamos las SEG para la p¿liza (ncarga)
         FOR reg IN (SELECT *
                       FROM mig_logs_axis
                      WHERE ncarga = p_ncarga
                        AND tipo = 'E') LOOP
            --Miramos si ha habido alg¿n error y lo informamos.
            v_ntraza := 200;
            v_nnumerr := f_marcar_lineas(p_ssproces, p_ncarga, 1,   -- pongo errr todas las lineas
                                         v_toperacion, 151840, reg.incid, NULL, NULL, NULL,
                                         NULL, NULL);
            v_berrorproc := TRUE;
            v_ntiperr := 1;
         END LOOP;

         IF v_ntiperr = 0 THEN
            FOR reg IN (SELECT *
                          FROM mig_logs_axis
                         WHERE ncarga = p_ncarga
                           AND tipo = 'W') LOOP   --Miramos si han habido warnings.
               v_ntraza := 202;

               BEGIN
                  SELECT nrecibo
                    INTO vnrecibo
                    FROM mig_recibos
                   WHERE ncarga = p_ncarga;
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;   --JRH IMP de momento
               END;

               --                  v_nnumerr := p_marcalineaerror(p_ssproces, c_lin.nlinea, NULL, 2, 700145, reg.incid);
               v_nnumerr := f_marcar_lineas(p_ssproces, p_ncarga, 2,   -- pongo errr todas las lineas
                                            v_toperacion, 700145, reg.incid, NULL, NULL,
                                            vnrecibo, NULL, NULL);
               v_bavisproc := TRUE;
               v_ntiperr := 2;
            END LOOP;
         END IF;

         IF v_ntiperr = 0 THEN
            --Esto quiere decir que no ha habido ning¿n error (lo indicamos tambi¿n).
            v_ntraza := 204;

            BEGIN
               SELECT nrecibo
                 INTO vnrecibo
                 FROM mig_recibos
                WHERE ncarga = p_ncarga;
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;   --JRH IMP de momento
            END;

            FOR c_lin IN (SELECT nlinea, idint
                            FROM int_carga_ctrl_linea
                           WHERE sproces = p_ssproces
                             AND ncarga = p_ncarga) LOOP
               v_nnumerr := p_marcalinea(p_ssproces, c_lin.nlinea, v_toperacion, 4, 1, NULL,
                                         p_id, p_ncarga, NULL, NULL, NULL, vnrecibo,
                                         c_lin.idint);

               IF v_nnumerr <> 0 THEN
                  --Si fallan estas funciones de gesti¿n salimos del programa
                  v_tdeserror := 'Falta marcar linea 4: ' || p_ssproces || '/' || p_id;
                  RAISE e_errdatos;
               END IF;
            END LOOP;

            v_ntiperr := 4;
         END IF;

         -- Lanzo validaciones  si ha la poliza esta migrada
         RETURN v_ntiperr;   --Devolvemos el tipo error que ha habido
      EXCEPTION
         WHEN e_errdatos THEN
            ROLLBACK;
            v_nnumerr1 := p_marcalinea(p_ssproces, v_id_linea, v_toperacion, 1, 0, NULL, p_id,
                                       p_ncarga);
            v_nnumerr := p_marcalineaerror(p_ssproces, v_id_linea, NULL, 1, NVL(v_nnumerr, 1),
                                           NVL(v_tdeserror, -1));
            COMMIT;
            RETURN v_nnumerr;
         WHEN OTHERS THEN
            v_nnumerr := SQLCODE;
            v_tdeserror := SQLCODE || ' ' || SQLERRM;
            ROLLBACK;
            v_nnumerr1 := p_marcalinea(p_ssproces, v_id_linea, v_toperacion, 1, 0, NULL, p_id,
                                       p_ncarga);
            v_nnumerr := p_marcalineaerror(p_ssproces, v_id_linea, NULL, 1, v_nnumerr,
                                           v_tdeserror);
            RETURN SQLCODE;
      END f_lanza_migracion_rec;
   --
   BEGIN
      v_ntraza := 0;

      IF p_ssproces IS NULL THEN
         v_nnumerr := 9000505;
         v_tdeserror := 'Par¿metro p_ssproces obligatorio.';
         p_genera_logs(v_tobjeto, v_ntraza, 'Error:' || v_nnumerr, v_tdeserror);
         RAISE e_salir;
      END IF;

      v_ntraza := 1;
      v_toperacion := NULL;
      v_sseguro := NULL;
      v_ncarga := NULL;
      v_id_linea_1 := NULL;

      --  v_ntipoerror := 0;
      FOR x IN cur_rec(p_ssproces) LOOP
         BEGIN
            --Leemos los registros de la tabla int no procesados OK
            IF x.tiporegistro IN(1, 30) THEN   -- si cambio de bloque de registros de recibos
               IF v_id IS NOT NULL
                  AND v_mig_rec.ncarga IS NOT NULL
                  AND v_ntipoerror NOT IN(1, 4) THEN
                  IF v_toperacion = 'REC' THEN
                     v_nnumerr := f_lanza_migracion_rec(v_id, v_ncarga);
                  ELSIF v_toperacion = 'RECM' THEN
                     -- ya he actualizado los movimientos del recibo
                      -- tengo que grabar el resultado
                     NULL;
                  END IF;

                  IF v_nnumerr NOT IN(0, 2, 4) THEN   -- si ha habido error
                     v_berrorlin := TRUE;
                     v_berrorproc := TRUE;
                     ROLLBACK;

                     IF k_cpara_error <> 1 THEN
                        v_ntipoerror := 4;
                     -- para que continue con la siguiente linea.
                     ELSE
                        v_ntipoerror := 1;   -- para la carga
                        RAISE e_salir;
                     END IF;
                  ELSE
                     COMMIT;
                  END IF;
               END IF;

               IF v_id_linea_1 IS NOT NULL
                  AND x.tiporegistro = 1 THEN
                  IF v_berrorlin THEN
                     v_nnumerr := p_marcalinea(x.proceso, v_id_linea_1, 'REC', 1, 0,
                                               v_sseguro, v_id, v_ncarga, NULL, NULL, NULL,
                                               NULL,
                                               v_id_linea_1 || '(' || x.tiporegistro || ')');
                  ELSE
                     v_nnumerr := p_marcalinea(x.proceso, v_id_linea_1, 'REC', 4, 1,
                                               v_sseguro, v_id, v_ncarga, NULL, NULL, NULL,
                                               NULL,
                                               v_id_linea_1 || '(' || x.tiporegistro || ')');
                  END IF;

                  v_id_linea_1 := NULL;
               END IF;

               v_ncarga := f_next_carga;
               v_mig_rec := NULL;
               v_mig_movrec := NULL;
               v_mig_recdet := NULL;
               v_ntipoerror := 0;
            END IF;

            IF x.tiporegistro <> 1 THEN
               v_nnumerr := p_marcalinea(x.proceso, x.nlinea, 'REC', 3, 0, NULL, v_id,
                                         v_ncarga, NULL, NULL, NULL, NULL,
                                         x.nlinea || '(' || x.tiporegistro || ')');
            END IF;

            v_ntraza := 3;
            v_id_linea := x.nlinea;

            IF v_ntipoerror NOT IN(1, 4) THEN
               v_ntraza := 1010;

               -- RESTISTRO 1
               IF x.tiporegistro = '1' THEN   -- polizas
                  v_id := TRIM(x.campo03) || '-' || x.campo04;
                  v_toperacion := NULL;
                  v_ntipoerror := 0;
                  v_nnumerr := p_marcalinea(x.proceso, x.nlinea, 'REC', 3, 0, NULL, v_id,
                                            v_ncarga, NULL, NULL, NULL, NULL,
                                            x.nlinea || '(' || x.tiporegistro || ')');
                  v_sseguro := NULL;
                  --
                  v_id_linea_1 := x.nlinea;
                  --v_ncarga := f_next_carga;
                  v_berrorlin := FALSE;

                  --Inicializamos la clinea
                  IF x.campo02 IS NULL THEN   -- miro si el producto esta cargado
                     --Inicializamos la linea
                     v_nnumerr := p_marcalinea(x.proceso, x.nlinea, 'REC', 3, 0, NULL, v_id,
                                               v_ncarga, NULL, NULL, NULL, NULL,
                                               x.nlinea || '(' || x.tiporegistro || ')');
                     v_tdeserror := ' C¿digo producto no definido: ' || x.campo02;
                     v_nnumerr := 104347;
                     RAISE e_errdatos;
                  END IF;

                  v_admite_certificados :=
                       NVL(pac_parametros.f_parproducto_n(x.campo02, 'ADMITE_CERTIFICADOS'), 0);

                  IF (TRIM(x.campo03) IS NULL
                      AND v_admite_certificados = 0)
                     AND(TRIM(x.campo03) IS NOT NULL
                         AND TRIM(x.campo04) IS NULL
                         AND TRIM(x.campo16) IS NULL
                         AND TRIM(x.campo17) IS NULL
                         AND v_admite_certificados = 1)
                     AND(TRIM(x.campo05) IS NULL) THEN
                     v_tdeserror :=
                        'Error en identificador de p¿liza, para el tipo de producto definido -->'
                        || x.campo02;
                     v_nnumerr := 140897;
                     RAISE e_errdatos;
                  ELSIF (TRIM(x.campo03) IS NOT NULL
                         AND v_admite_certificados = 0)
                        OR(TRIM(x.campo03) IS NOT NULL
                           AND TRIM(x.campo04) IS NOT NULL
                           AND v_admite_certificados = 1) THEN
                     NULL;
                  ELSIF v_admite_certificados = 1
                        AND TRIM(x.campo03) IS NOT NULL
                        AND TRIM(x.campo04) IS NULL
                        AND TRIM(x.campo16) IS NOT NULL
                        AND TRIM(x.campo17) IS NOT NULL THEN
                     -- Si me llega el certificado 0 a nulo miro si me llega el asegurado
                       -- busco el certificado para ese producto/poliza, y que tenga ese asegurado
                     BEGIN
                        SELECT ncertif
                          INTO x.campo04   -- lo grabo en el certificado
                          FROM seguros seg, asegurados aseg
                         WHERE npoliza = TRIM(x.campo03)
                           AND sproduc = x.campo02
                           AND ncertif <> 0
                           AND seg.sseguro = aseg.sseguro
                           AND sperson IN(SELECT sperson
                                            FROM per_personas
                                           WHERE ctipide = TRIM(x.campo16)
                                             AND nnumide = TRIM(x.campo17));
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           v_tdeserror :=
                              'Error en el campo de poliza, para el tipo de producto definido -->'
                              || x.campo03;
                           v_nnumerr := 103946;
                           RAISE e_errdatos;
                        WHEN TOO_MANY_ROWS THEN
                           v_tdeserror :=
                              'Hay m¿s de un certificado coincidente para la poliza y asegurado indicado -->'
                              || x.campo03 || ' - ' || x.campo16;
                           v_nnumerr := 9001114;
                           RAISE e_errdatos;
                     END;
                  -- buscamos por referencia externa
                  ELSIF TRIM(x.campo05) IS NOT NULL   -- miro si llega la referencia externa
                                                   THEN
                     -- Si me llega el certificado 0 a nulo miro si me llega el asegurado
                       -- busco el certificado para ese producto/poliza, y que tenga ese asegurado
                     BEGIN
                        SELECT npoliza, ncertif
                          INTO x.campo03, x.campo04   -- lo grabo en la poliza / certificado
                          FROM seguros seg
                         WHERE cpolcia = TRIM(x.campo05)
                           AND npoliza = NVL(TRIM(x.campo03), npoliza)
                           AND sproduc = x.campo02;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           v_tdeserror :=
                              'Error en el campo de n¿mero propuesta externo, no se encuentra en el sistema -->'
                              || x.campo05;
                           v_nnumerr := 103946;
                           RAISE e_errdatos;
                        WHEN TOO_MANY_ROWS THEN
                           v_tdeserror :=
                              'Hay m¿s de una p¿liza coincidente para n¿mero propuesta externo -->'
                              || x.campo05;
                           v_nnumerr := 9001114;
                           RAISE e_errdatos;
                     END;
                  ELSE
                     v_tdeserror :=
                        'Error en el campo de poliza/propuesta externa, para el c¿digo de producto definido -->'
                        || x.campo03;
                     v_nnumerr := 140897;
                     RAISE e_errdatos;
                  END IF;

                  BEGIN
                     SELECT sseguro
                       INTO v_sseguro
                       FROM seguros
                      WHERE npoliza = NVL(TRIM(x.campo03), 0)
                        AND ncertif = NVL(x.campo04, 0)
                        AND sproduc = x.campo02;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        v_tdeserror :=
                           'Error en el campo de poliza, para el tipo de producto definido -->'
                           || x.campo03;
                        v_nnumerr := 103946;
                        RAISE e_errdatos;
                  END;

                  -- 38020.NMM
                  IF NVL(pac_parametros.f_parempresa_n(k_cempresa, 'CARGA_RECIBO'), 0) = 1 THEN
                     -- Esta comprobaci¿n la ha pedido RSA particularmente para la carga de recibos
                     BEGIN
                        SELECT 0
                          INTO v_nnumerr
                          FROM seguros
                         WHERE ((x.campo05 IS NULL
                                 AND cpolcia IS NULL)
                                OR(x.campo05 IS NOT NULL
                                   AND cpolcia = x.campo05))
                           AND npoliza = TRIM(x.campo03)
                           AND ncertif = NVL(x.campo04, 0)
                           AND cagente = x.campo01;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           v_tdeserror :=
                              'Agente, propuesta y n¿ de p¿liza enviada, no corresponden con ninguna p¿liza existente en el sistema.';
                           v_nnumerr := 9904148;
                           RAISE e_errdatos;
                     END;
                  END IF;
               --
               -- recibo
               ELSIF x.tiporegistro = '30' THEN
                  IF x.campo01 IS NULL THEN   -- es un alta
                     v_toperacion := 'REC';

                     IF v_sseguro IS NULL THEN
                        v_tdeserror :=
                           'No se ha informado correctamente el registro de p¿liza.'
                           || x.campo03;
                        v_nnumerr := 103946;
                        RAISE e_errdatos;
                     END IF;

                     --   v_ncarga := f_next_carga;

                     -- no la encuentro la trato como alta.
                     INSERT INTO mig_cargas
                                 (ncarga, cempres, finiorg, ffinorg, ID, estorg)
                          VALUES (v_ncarga, k_cempresa, f_sysdate, f_sysdate, v_id, NULL);

                     INSERT INTO mig_cargas_tab_mig
                                 (ncarga, tab_org, tab_des, ntab, finides,
                                  ffindes)
                          VALUES (v_ncarga, 'INT_CARGA_GENERICO', 'MIG_SEGUROS', 0, f_sysdate,
                                  f_sysdate);

                     -- v_mig_seg.mig_pk := v_ncarga || '/' ||v_sseguro;
                     -- v_mig_rec.mig_pk := v_ncarga || '/' ||v_sseguro;
                     v_mig_rec.mig_pk := v_ncarga;
                     v_ntraza := 1055;

                     SELECT v_ncarga ncarga, -1 cestmig, v_mig_rec.mig_pk mig_pk,
                            v_mig_rec.mig_pk mig_fk, cagente, npoliza,
                            ncertif, fefecto, creafac,
                            cactivi, ctiprea, cidioma,
                            cforpag, cempres, sproduc,
                            casegur, nsuplem, sseguro,
                            0 sperson
                       INTO v_mig_seg.ncarga, v_mig_seg.cestmig, v_mig_seg.mig_pk,
                            v_mig_seg.mig_fk, v_mig_seg.cagente, v_mig_seg.npoliza,
                            v_mig_seg.ncertif, v_mig_seg.fefecto, v_mig_seg.creafac,
                            v_mig_seg.cactivi, v_mig_seg.ctiprea, v_mig_seg.cidioma,
                            v_mig_seg.cforpag, v_mig_seg.cempres, v_mig_seg.sproduc,
                            v_mig_seg.casegur, v_mig_seg.nsuplem, v_mig_seg.sseguro,
                            v_mig_seg.sperson
                       FROM seguros
                      WHERE sseguro = v_sseguro;

                     v_ntraza := 1060;

                     INSERT INTO mig_seguros
                          VALUES v_mig_seg
                       RETURNING ROWID
                            INTO v_rowid;

                     INSERT INTO mig_pk_emp_mig
                          VALUES (0, v_ncarga, 0, v_mig_seg.mig_pk);

       -- Recupero datos recibos
        --------------------------------------------------------------------------
-- recibos
--------------------------------------------------------------------------
                     INSERT INTO mig_cargas_tab_mig
                                 (ncarga, tab_org, tab_des, ntab)
                          VALUES (v_ncarga, 'INT_CARGA_GENERICO', 'MIG_RECIBOS', 1);

                     v_mig_rec.ncarga := v_ncarga;
                     v_mig_rec.mig_fk := v_mig_rec.mig_pk;
                     v_mig_rec.cestmig := 1;
                     v_mig_rec.nrecibo := TRIM(x.campo01);
                     v_mig_rec.creccia := x.campo02;
                     v_ntraza := 1065;
                     v_mig_rec.nriesgo := x.campo03;
                     v_mig_rec.sseguro := v_sseguro;
                     v_mig_rec.fefecto := f_chartodate(x.campo06);

                     IF v_mig_rec.fefecto IS NULL THEN
                        v_tdeserror := 'Efecto invalido: ' || x.campo06 || ' (dd/mm/yyyy)';
                        v_nnumerr := 1000135;
                        RAISE e_errdatos;
                     END IF;

                     v_ntraza := 1070;
                     v_mig_rec.fvencim := f_chartodate(x.campo07);

                     IF v_mig_rec.fvencim IS NULL THEN
                        v_tdeserror := 'Fecha vencimiento no es fecha: ' || x.campo07
                                       || ' (dd/mm/yyyy)';
                        v_nnumerr := 1000135;
                        RAISE e_errdatos;
                     END IF;

                     v_ntraza := 1075;
                     v_mig_rec.femisio := f_chartodate(x.campo05);
                     v_mig_rec.ctiprec := x.campo09;

                     IF v_mig_rec.ctiprec IS NULL THEN
                        v_tdeserror := 'Tipo recibo: ' || v_mig_rec.ctiprec;
                        v_nnumerr := 102302;
                        RAISE e_errdatos;
                     END IF;

                     v_ntraza := 1080;

                     SELECT MAX(nmovimi)
                       INTO v_mig_rec.nmovimi
                       FROM movseguro
                      WHERE sseguro = v_sseguro
                        AND fefecto = v_mig_rec.fefecto;

                     IF v_mig_rec.nmovimi IS NULL THEN
                        v_ntraza := 1085;

                        SELECT MAX(nmovimi)
                          INTO v_mig_rec.nmovimi
                          FROM movseguro
                         WHERE sseguro = v_sseguro;

                        IF v_mig_rec.nmovimi IS NULL THEN
                           v_tdeserror := 'Seguro: ' || v_sseguro;
                           v_nnumerr := 104348;
                           RAISE e_errdatos;
                        END IF;
                     END IF;

                     --v_mig_rec.nmovimi := n_aux;
                     v_ntraza := 1090;
                     --
                     v_mig_rec.freccob := f_chartodate(x.campo08);
                     v_mig_rec.cestrec := x.campo10;

                     IF v_admite_certificados = 1
                        AND v_mig_seg.ncertif = 0 THEN
                        v_mig_rec.esccero := 1;
                     ELSE
                        v_mig_rec.esccero := 0;
                     END IF;

                     v_ntraza := 1100;

                     INSERT INTO mig_recibos
                          VALUES v_mig_rec
                       RETURNING ROWID
                            INTO v_rowid;

                     INSERT INTO mig_pk_emp_mig
                          VALUES (0, v_ncarga, 1, v_mig_rec.mig_pk);
                  ELSE
                     v_toperacion := 'RECM';
                     v_mig_rec.nrecibo := TRIM(x.campo01);
                  END IF;
               -- movrecibo
               ELSIF x.tiporegistro = '31' THEN
                  INSERT INTO mig_cargas_tab_mig
                              (ncarga, tab_org, tab_des, ntab)
                       VALUES (v_ncarga, 'INT_CARGA_GENERICO', 'MIG_MOVRECIBO', 2);

                  v_mig_movrec.ncarga := v_ncarga;
                  v_mig_movrec.cestmig := 1;
                  v_mig_movrec.mig_pk := v_mig_rec.mig_pk || '/' || x.campo01;
                  v_mig_movrec.mig_fk := v_mig_rec.mig_pk;
                  v_mig_movrec.cestrec := x.campo02;
                  v_mig_movrec.fmovini := f_chartodate(x.campo03);
                  v_mig_movrec.fmovfin := f_chartodate(x.campo04);
                  v_mig_movrec.fefeadm := NULL;
                  v_mig_movrec.fmovdia := f_chartodate(x.campo05);
                  v_mig_movrec.cmotmov := NULL;

                  UPDATE mig_recibos   -- si me llegan movimientos de recibo elimino el posible movimiento de la cabecera
                     SET cestrec = NULL
                   WHERE mig_pk = v_mig_rec.mig_pk;

                  INSERT INTO mig_movrecibo
                       VALUES v_mig_movrec
                    RETURNING ROWID
                         INTO v_rowid;

                  INSERT INTO mig_pk_emp_mig
                       VALUES (0, v_ncarga, 2, v_mig_movrec.mig_pk);
               -- detalle del recibo
               ELSIF x.tiporegistro = '32' THEN
                  INSERT INTO mig_cargas_tab_mig
                              (ncarga, tab_org, tab_des, ntab)
                       VALUES (v_ncarga, 'INT_CARGA_GENERICO', 'MIG_DETRECIBOS', 3);

                  v_mig_recdet.ncarga := v_ncarga;
                  v_mig_recdet.cestmig := 1;
                  v_mig_recdet.mig_pk := v_mig_rec.mig_pk || '/' || x.campo01 || '/'
                                         || x.campo02 || '/' || x.campo03;
                  v_mig_recdet.mig_fk := v_mig_rec.mig_pk;
                  v_mig_recdet.cconcep := x.campo02;
                  v_mig_recdet.cgarant := x.campo03;
                  v_mig_recdet.nriesgo := v_mig_rec.nriesgo;
                  v_mig_recdet.iconcep := f_chartonumber(x.campo04);
                  v_mig_recdet.iconcep_monpol := f_chartonumber(x.campo05);
                  v_mig_recdet.fcambio := f_chartodate(x.campo06);
                  v_mig_recdet.nmovima := NULL;

                  INSERT INTO mig_detrecibos
                       VALUES v_mig_recdet
                    RETURNING ROWID
                         INTO v_rowid;

                  INSERT INTO mig_pk_emp_mig
                       VALUES (0, v_ncarga, 3, v_mig_recdet.mig_pk);
               -- REGISTRO 35 -- Movimientos -- movimientos de pagos parciales
               ELSIF x.tiporegistro = '35' THEN   -- pagos parciales
                  IF v_sseguro IS NULL THEN
                     v_tdeserror :=
                        'Se ha enviado un registro de pago parcial sin informar la linea de poliza';
                     v_nnumerr := 103946;
                     RAISE e_errdatos;
                  END IF;

                  v_toperacion := 'REC';

                  -- Valido RUT - RSA --> ctipide in (41,42)  -- Bug 36263
                  IF x.campo02 IN(41, 42) THEN
                     IF x.campo04 <> pac_ide_persona.f_digito_nif_chile(x.campo02,
                                                                        UPPER(x.campo03)) THEN
                        -- Validacion de digito verificador
                        v_tdeserror := 'Rut (campo03): ' || x.campo03 || ' DV (campo04): '
                                       || x.campo04;
                        v_nnumerr := 9904776;
                        RAISE e_errdatos;
                     END IF;
                  END IF;

                  -- Valido RUT - RSA --> ctipide in (41,42)  -- Bug 36263

                  -- busco la persona
                  BEGIN
                     SELECT sperson
                       INTO v_sperson
                       FROM per_personas
                      WHERE ctipide = x.campo02
                        AND nnumide = x.campo03;
                  EXCEPTION
                     WHEN OTHERS THEN
                        v_sperson := NULL;
                  END;

                  DECLARE
                     vquery         VARCHAR2(2000);
                  BEGIN
                     SELECT DISTINCT cmoneda
                                INTO vcmoneda
                                FROM monedas
                               WHERE ciso4217n = x.campo06;
                  EXCEPTION
                     WHEN OTHERS THEN
                        v_tdeserror :=
                           'Moneda no parametrizada en tabla MONEDAS. C¿digo moneda ISO: '
                           || x.campo06;
                        v_nnumerr := 9902771;
                        RAISE e_errdatos;
                  END;

                  IF f_chartonumber(x.campo05) < 0 THEN
                     -- importe pago moneda producto
                     v_tdeserror := 'Importe moneda producto (campo05): ' || x.campo05;
                     v_nnumerr := 9902884;
                     RAISE e_errdatos;
                  END IF;

                  IF f_chartonumber(x.campo07) < 0 THEN
                     -- Importe moneda pago
                     v_tdeserror := 'Importe moneda pago (campo07): ' || x.campo07;
                     v_nnumerr := 9902884;
                     RAISE e_errdatos;
                  END IF;

                  IF f_chartonumber(x.campo08) < 0 THEN
                     -- Tasa de cambio
                     v_tdeserror := 'Tasa de cambio (campo08): ' || x.campo08;
                     v_nnumerr := 9902884;
                     RAISE e_errdatos;
                  END IF;

                  -- ok le paso los campos a la funcion ...
                  v_nnumerr :=
                     pac_adm_cobparcial.f_carga_pagos_masiva(p_ssproces, v_sperson, v_sseguro,
                                                             f_chartonumber(x.campo05),
                                                             vcmoneda,
                                                             NVL(f_chartonumber(x.campo07),
                                                                 f_chartonumber(x.campo05)),
                                                             NVL(f_chartonumber(x.campo08), 1),
                                                             f_chartodate(x.campo09),
                                                             NVL(x.campo10, 0));

                  IF v_nnumerr <> 0 THEN
                     v_tdeserror := 'Error en inserci¿n del pago parcial.';
                     RAISE e_errdatos;
                  ELSE
                     v_nnumerr := p_marcalinea(p_ssproces, x.nlinea, 'REC', 4, 1, v_sseguro,
                                               v_id, v_ncarga);   -- lo marco como ok

                     IF v_nnumerr <> 0 THEN
                        RAISE e_errdatos;
                     END IF;

                     b_cobro_parcial := TRUE;
                  END IF;

                  COMMIT;
               ELSE
                  -- no se encuentra el tipo de registro
                  v_nnumerr := 9902907;
                  v_tdeserror := 'El tipo registro (campo01): ' || x.tiporegistro || ' '
                                 || 'no parametrizado.';
                  v_nnumerr1 := p_marcalinea(p_ssproces, x.nlinea, 'REC', 1, 0, NULL, v_id,
                                             v_ncarga, NULL, NULL, NULL, NULL,
                                             x.nlinea || '(' || x.tiporegistro || ')');
                  v_nnumerr := p_marcalineaerror(p_ssproces, x.nlinea, NULL, 1,
                                                 NVL(v_nnumerr, 1), NVL(v_tdeserror, -1));
                  RAISE e_errdatos;
               END IF;
            ELSE
               NULL;   -- salto el registro porque viene de un error
            END IF;   -- v_toperacion

            v_ntraza := 9090;
         EXCEPTION
            WHEN e_errdatos THEN
               ROLLBACK;
               v_berrorproc := TRUE;
               v_berrorlin := TRUE;
               v_nnumerr1 := p_marcalinea(p_ssproces, x.nlinea, 'REC', 1, 0, NULL, v_id,
                                          v_ncarga, NULL, NULL, NULL, NULL,
                                          x.nlinea || '(' || x.tiporegistro || ')');
               v_nnumerr := p_marcalineaerror(p_ssproces, x.nlinea, NULL, 1,
                                              NVL(v_nnumerr, 1), NVL(v_tdeserror, -1));

               IF k_cpara_error <> 1 THEN
                  v_ntipoerror := 4;
               -- para que continue con la siguiente linea.
               ELSE
                  v_ntipoerror := 1;   -- para la carga
                  RAISE e_salir;
               END IF;
            -- debo obviar todas las lineas hasta la siguiente linea 1
            WHEN e_salir THEN   -- salgo del cursor
               RAISE;
            WHEN OTHERS THEN
               v_nnumerr := SQLCODE;
               v_tdeserror := SQLERRM;
               ROLLBACK;
               v_berrorproc := TRUE;
               v_berrorlin := TRUE;
               v_nnumerr := f_marcar_lineas(p_ssproces, v_ncarga, 1,   -- pongo error
                                            v_toperacion, v_nnumerr, v_tdeserror, NULL,
                                            x.nlinea, NULL, NULL, NULL);
         END;
      END LOOP;

      v_ntraza := 9500;

      IF v_id IS NOT NULL
         AND v_mig_rec.ncarga IS NOT NULL
         AND v_ntipoerror NOT IN(1, 4) THEN
         -- lanza la ultima migraci¿n, cuando acaba el fichero
         IF v_toperacion = 'REC' THEN
            v_nnumerr := f_lanza_migracion_rec(v_id, v_ncarga);
         ELSIF v_toperacion = 'RECM' THEN   -- ejecuto el suplemento
            NULL;
         END IF;

         IF v_nnumerr NOT IN(0, 2, 4) THEN   -- si ha habido error
            v_berrorlin := TRUE;
            v_berrorproc := TRUE;
            ROLLBACK;
         ELSE
            COMMIT;
         END IF;
      END IF;

      v_ntraza := 9000;

      --
      IF v_id_linea_1 IS NOT NULL THEN
         IF v_berrorlin THEN
            v_nnumerr := p_marcalinea(p_ssproces, v_id_linea_1, 'REC', 1, 0, v_sseguro, v_id,
                                      v_ncarga, NULL, NULL, NULL, NULL, v_id_linea_1 || '(1)');
         ELSE
            v_nnumerr := p_marcalinea(p_ssproces, v_id_linea_1, 'REC', 4, 1, v_sseguro, v_id,
                                      v_ncarga, NULL, NULL, NULL, NULL, v_id_linea_1 || '(1)');
         END IF;
      END IF;

      v_ntraza := 9999;

-------------------------------- final loop ------------------------------------
-- COMMIT;
      IF v_berrorproc THEN
         RETURN 1;
      ELSIF v_bavisproc THEN
         RETURN 2;
      ELSE
         RETURN 4;
      END IF;
   EXCEPTION
      WHEN e_salir THEN
         ROLLBACK;
         -- v_nnumerr := p_marcalinea(p_ssproces, v_id_linea, v_toperacion, 1, 0, NULL, v_id,
         --             v_ncarga);

         -- v_nnumerr := p_marcalineaerror(p_ssproces, v_id_linea, NULL, 1, NVL(v_nnumerr, 1),
         --           NVL(v_tdeserror, -1));
         RETURN 1;
      -- Fi Bug 16324
      WHEN OTHERS THEN
         v_nnumerr := SQLCODE;
         v_tdeserror := SQLCODE || ' ' || SQLERRM;
         ROLLBACK;
         v_nnumerr1 := p_marcalinea(p_ssproces, v_id_linea, 'REC', 1, 0, NULL, v_id, v_ncarga);
         v_nnumerr := p_marcalineaerror(p_ssproces, v_id_linea, NULL, 1, v_nnumerr,
                                        v_tdeserror);
         p_genera_logs(v_tobjeto, v_ntraza, 'Error Incontrolado:' || v_nnumerr, v_tdeserror);
         RETURN 1;
   END f_rec_ejecutar_carga_proceso;

   /*************************************************************************
     Procedimiento que ejecuta una carga de recibos
       param in p_ssproces   : N¿mero proceso
       retorna 0 si ha ido bien, 1 en casos contrario
   *************************************************************************/
   FUNCTION f_sin_ejecutar_carga_proceso(p_ssproces IN NUMBER)
      RETURN NUMBER IS
      v_tobjeto      VARCHAR2(100) := 'pac_cargas_generico.f_sin_ejecutar_carga_proceso';
      v_ntraza       NUMBER := 0;
      e_salir        EXCEPTION;

      CURSOR cur_sin(p_ssproces2 IN NUMBER) IS
         -- Abrimos los certificados como control, despu¿s buscamos todos los registros del fichero.
         SELECT   a.*
             FROM int_carga_generico a
            WHERE proceso = p_ssproces2
              AND NOT EXISTS(SELECT 1
                               FROM int_carga_ctrl_linea b
                              WHERE b.sproces = a.proceso
                                AND b.nlinea = a.nlinea
                                AND b.cestado IN(2, 4, 5, 6))
         ORDER BY nlinea, tiporegistro;   -- registro tipo certificado

      v_toperacion   VARCHAR2(20);
      v_berrorproc   BOOLEAN := FALSE;
      v_berrorlin    BOOLEAN := FALSE;
      v_bavisproc    BOOLEAN := FALSE;
      v_ntipoerror   NUMBER := 0;
      --
      v_id           mig_cargas.ID%TYPE;
      v_id_linea     NUMBER;
      v_id_linea_1   NUMBER;
      v_sperson      per_personas.sperson%TYPE;
      v_sseguro      seguros.sseguro%TYPE;
      v_ncarga       int_carga_generico.ncarga%TYPE;
      v_ncarga2      int_carga_generico.ncarga%TYPE;
      vcmoneda       monedas.cmoneda%TYPE;
      --
      v_mig_seg      mig_seguros%ROWTYPE;
      v_mig_sin      mig_sin_siniestro%ROWTYPE;
      v_mig_movsin   mig_sin_movsiniestro%ROWTYPE;
      v_mig_sintram  mig_sin_tramitacion%ROWTYPE;
      v_mig_sintram_mov mig_sin_tramita_movimiento%ROWTYPE;
      v_mig_sintram_res mig_sin_tramita_reserva%ROWTYPE;
      v_mig_sintram_dest mig_sin_tramita_dest%ROWTYPE;
      v_mig_sintram_pago mig_sin_tramita_pago%ROWTYPE;
      v_mig_sintram_movpago mig_sin_tramita_movpago%ROWTYPE;
      v_mig_sintram_pago_gar mig_sin_tramita_pago_gar%ROWTYPE;
      v_mig_sinreferencias mig_sin_siniestro_referencias%ROWTYPE;
      v_mig_sintram_personasrel mig_sin_tramita_personasrel%ROWTYPE;
      --
      wspersonnueva  estper_personas.sperson%TYPE;
      reg_migpersonas mig_personas%ROWTYPE;
      --
      v_rowid        ROWID;
      v_admite_certificados parproductos.cvalpar%TYPE;
      v_nmovres      mig_sin_tramita_reserva.nmovres%TYPE;

       --
      /***************************************************************************
        FUNCTION f_lanza_migracio_sin
            Asigna n¿mero de carga
            Return: N¿mero de carga
        ***************************************************************************/
      FUNCTION f_lanza_migracion_sin(p_id IN VARCHAR2, p_ncarga IN NUMBER)
         RETURN NUMBER IS
         v_ntiperr      NUMBER := 0;
         vnsinies       sin_siniestro.nsinies%TYPE;
      BEGIN
         pac_mig_axis.p_migra_cargas(p_id, 'C', p_ncarga, 'DEL', k_tablas, 'SINIESTRO');

         --Cargamos las SEG para en siniestro (ncarga)
         FOR reg IN (SELECT *
                       FROM mig_logs_axis
                      WHERE ncarga = p_ncarga
                        AND tipo = 'E') LOOP
            --Miramos si ha habido alg¿n error y lo informamos.
            v_ntraza := 200;
            v_nnumerr := f_marcar_lineas(p_ssproces, p_ncarga, 1,   -- pongo errr todas las lineas
                                         v_toperacion, 151840, reg.incid, NULL, NULL, NULL,
                                         NULL, NULL);
            v_berrorproc := TRUE;
            v_ntiperr := 1;
         END LOOP;

         IF v_ntiperr = 0 THEN
            FOR reg IN (SELECT *
                          FROM mig_logs_axis
                         WHERE ncarga = p_ncarga
                           AND tipo = 'W') LOOP   --Miramos si han habido warnings.
               v_ntraza := 202;

               BEGIN
                  SELECT nsinies
                    INTO vnsinies
                    FROM mig_sin_siniestro
                   WHERE ncarga = p_ncarga;
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;   --JRH IMP de momento
               END;

               -- v_nnumerr := p_marcalineaerror(p_ssproces, c_lin.nlinea, NULL, 2, 700145, reg.incid);
               v_nnumerr := f_marcar_lineas(p_ssproces, p_ncarga, 2,   -- pongo errr todas las lineas
                                            v_toperacion, 700145, reg.incid, NULL, NULL, NULL,
                                            vnsinies, NULL);
               v_bavisproc := TRUE;
               v_ntiperr := 2;
            END LOOP;
         END IF;

         IF v_ntiperr = 0 THEN
            --Esto quiere decir que no ha habido ning¿n error (lo indicamos tambi¿n).
            v_ntraza := 204;

            BEGIN
               SELECT nsinies
                 INTO vnsinies
                 FROM mig_sin_siniestro
                WHERE ncarga = p_ncarga;
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;   --JRH IMP de momento
            END;

            FOR c_lin IN (SELECT nlinea, idint
                            FROM int_carga_ctrl_linea
                           WHERE sproces = p_ssproces
                             AND ncarga = p_ncarga) LOOP
               v_nnumerr := p_marcalinea(p_ssproces, c_lin.nlinea, v_toperacion, 4, 1, NULL,
                                         p_id, p_ncarga, vnsinies, NULL, NULL, NULL,
                                         c_lin.idint);

               IF v_nnumerr <> 0 THEN
                  --Si fallan estas funciones de gesti¿n salimos del programa
                  v_tdeserror := 'Falta marcar linea 4: ' || p_ssproces || '/' || p_id;
                  RAISE e_errdatos;
               END IF;
            END LOOP;

            v_ntiperr := 4;
         END IF;

         -- Lanzo validaciones  si ha la poliza esta migrada
         RETURN v_ntiperr;   --Devolvemos el tipo error que ha habido
      EXCEPTION
         WHEN e_errdatos THEN
            ROLLBACK;
            v_nnumerr1 := p_marcalinea(p_ssproces, v_id_linea, v_toperacion, 1, 0, NULL, p_id,
                                       p_ncarga);
            v_nnumerr := p_marcalineaerror(p_ssproces, v_id_linea, NULL, 1, NVL(v_nnumerr, 1),
                                           NVL(v_tdeserror, -1));
            COMMIT;
            RETURN v_nnumerr;
         WHEN OTHERS THEN
            v_nnumerr := SQLCODE;
            v_tdeserror := SQLCODE || ' ' || SQLERRM;
            ROLLBACK;
            v_nnumerr1 := p_marcalinea(p_ssproces, v_id_linea, v_toperacion, 1, 0, NULL, p_id,
                                       p_ncarga);
            v_nnumerr := p_marcalineaerror(p_ssproces, v_id_linea, NULL, 1, v_nnumerr,
                                           v_tdeserror);
            RETURN SQLCODE;
      END f_lanza_migracion_sin;

      --
      FUNCTION f_valida_reg50(
         x cur_sin%ROWTYPE,
         psproduc IN productos.sproduc%TYPE,
         p_desout IN OUT VARCHAR2)
         RETURN NUMBER IS
      BEGIN
         -- bug 0028909 - 14/11/2013 - JMF: Validaciones
         v_nnumerr := NULL;

         IF TRIM(x.campo02) IS NOT NULL THEN
            SELECT MAX(9902114)
              INTO v_nnumerr
              FROM sin_siniestro
             WHERE nsincia = TRIM(x.campo02);

            IF v_nnumerr IS NOT NULL THEN
               p_desout := 'Duplicado de siniestro.' || TRIM(x.campo02);
               RETURN v_nnumerr;
            END IF;
         END IF;

         IF x.campo03 IS NOT NULL THEN
            v_nnumerr := NULL;

            BEGIN
               SELECT MAX(1)
                 INTO v_nnumerr
                 FROM riesgos
                WHERE sseguro = v_sseguro
                  AND nriesgo = TO_NUMBER(x.campo03);
            EXCEPTION
               WHEN OTHERS THEN
                  v_nnumerr := NULL;
            END;

            IF v_nnumerr IS NULL THEN
               v_nnumerr := 1000646;
               p_desout := 'No se ha encontrado el riesgo.' || TRIM(x.campo03);
               RETURN v_nnumerr;
            END IF;
         END IF;

/*
         IF x.campo07 IS NOT NULL THEN
            v_nnumerr := NULL;

            BEGIN
               SELECT MAX(1)
                 INTO v_nnumerr
                 FROM sin_descausa
                WHERE ccausin = TO_NUMBER(x.campo07);
            EXCEPTION
               WHEN OTHERS THEN
                  v_nnumerr := NULL;
            END;

            IF v_nnumerr IS NULL THEN
               v_nnumerr := 9002104;
               p_desout := 'No se ha encontrado causa siniestro.' || TRIM(x.campo07);
               RETURN v_nnumerr;
            END IF;
         END IF;
         */

         --     IF x.campo08 IS NOT NULL THEN
         v_nnumerr := NULL;

         BEGIN
            SELECT MAX(1)
              INTO v_nnumerr
              --  FROM sin_desmotcau
            FROM   sin_gar_causa
             WHERE sproduc = psproduc
               AND ccausin = TO_NUMBER(x.campo07)
               AND cmotsin = TO_NUMBER(x.campo08);
         EXCEPTION
            WHEN OTHERS THEN
               v_nnumerr := NULL;
         END;

         IF v_nnumerr IS NULL THEN
            v_nnumerr := 9002104;
            p_desout := 'No se ha encontrado motivo siniestro.' || TRIM(x.campo08);
            RETURN v_nnumerr;
         END IF;

         --       END IF;
         IF x.campo10 IS NOT NULL THEN
            v_nnumerr := NULL;

            SELECT MAX(1)
              INTO v_nnumerr
              FROM sin_desevento
             WHERE cevento = x.campo10;

            IF v_nnumerr IS NULL THEN
               v_nnumerr := 9900810;
               p_desout := 'No se ha encontrado c¿digo evento.' || x.campo10;
               RETURN v_nnumerr;
            END IF;
         END IF;

         IF x.campo11 IS NOT NULL THEN
            v_nnumerr := NULL;

            BEGIN
               SELECT MAX(1)
                 INTO v_nnumerr
                 FROM detvalores
                WHERE cvalor = 319
                  AND catribu = TO_NUMBER(x.campo11);
            EXCEPTION
               WHEN OTHERS THEN
                  v_nnumerr := NULL;
            END;

            IF v_nnumerr IS NULL THEN
               v_nnumerr := 9902444;
               p_desout := 'No se ha encontrado medio declaraci¿n.' || x.campo11;
               RETURN v_nnumerr;
            END IF;
         END IF;

         IF x.campo12 IS NOT NULL THEN
            v_nnumerr := NULL;

            BEGIN
               SELECT MAX(1)
                 INTO v_nnumerr
                 FROM detvalores
                WHERE cvalor = 321
                  AND catribu = TO_NUMBER(x.campo12);
            EXCEPTION
               WHEN OTHERS THEN
                  v_nnumerr := NULL;
            END;

            IF v_nnumerr IS NULL THEN
               v_nnumerr := 9001163;
               p_desout := 'No se ha encontrado tipo declarante.' || x.campo12;
               RETURN v_nnumerr;
            END IF;
         END IF;

         IF x.campo13 IS NOT NULL THEN
            v_nnumerr := NULL;

            BEGIN
               SELECT MAX(1)
                 INTO v_nnumerr
                 FROM detvalores
                WHERE cvalor = 672
                  AND catribu = TO_NUMBER(x.campo13);
            EXCEPTION
               WHEN OTHERS THEN
                  v_nnumerr := NULL;
            END;

            IF v_nnumerr IS NULL THEN
               v_nnumerr := 9902391;
               p_desout := 'No se ha encontrado tipo documento.' || x.campo13;
               RETURN v_nnumerr;
            END IF;
         END IF;

         RETURN 0;
      EXCEPTION
         WHEN OTHERS THEN
            p_desout := SQLERRM;
            RETURN 1;
      END f_valida_reg50;

      --
      FUNCTION f_valida_reg51(x cur_sin%ROWTYPE, p_desout IN OUT VARCHAR2)
         RETURN NUMBER IS
      BEGIN
         -- bug 0028909 - 14/11/2013 - JMF: Validaciones
         IF x.campo02 IS NOT NULL THEN
            v_nnumerr := NULL;

            BEGIN
               SELECT MAX(1)
                 INTO v_nnumerr
                 FROM detvalores
                WHERE cvalor = 6
                  AND catribu = TO_NUMBER(x.campo02);
            EXCEPTION
               WHEN OTHERS THEN
                  v_nnumerr := NULL;
            END;

            IF v_nnumerr IS NULL THEN
               v_nnumerr := 112259;
               p_desout := 'No se ha encontrado estado siniestro ' || x.campo02;
               RETURN v_nnumerr;
            END IF;
         END IF;

         IF x.campo02 IS NOT NULL
            AND x.campo04 IS NOT NULL THEN
            v_nnumerr := NULL;

            BEGIN
               SELECT MAX(1)
                 INTO v_nnumerr
                 FROM sin_codcauest
                WHERE cestsin = TO_NUMBER(x.campo02)
                  AND ccauest = TO_NUMBER(x.campo04);
            EXCEPTION
               WHEN OTHERS THEN
                  v_nnumerr := NULL;
            END;

            IF v_nnumerr IS NULL THEN
               v_nnumerr := 100852;
               p_desout := 'No se ha encontrado causa siniestro ' || x.campo02 || '-'
                           || x.campo04;
               RETURN v_nnumerr;
            END IF;
         END IF;

         IF x.campo05 IS NOT NULL THEN
            v_nnumerr := NULL;

            BEGIN
               SELECT MAX(1)
                 INTO v_nnumerr
                 FROM sin_codtramitador
                WHERE ctiptramit = 2
                  AND cempres = k_cempresa
                  AND ctramitad = x.campo05;
            EXCEPTION
               WHEN OTHERS THEN
                  v_nnumerr := NULL;
            END;

            IF v_nnumerr IS NULL THEN
               v_nnumerr := 9001405;
               p_desout := 'Unidad Tramitadora incorrecta ' || x.campo05;
               RETURN v_nnumerr;
            END IF;
         END IF;

         IF x.campo06 IS NOT NULL THEN
            v_nnumerr := NULL;

            BEGIN
               SELECT MAX(1)
                 INTO v_nnumerr
                 FROM sin_codtramitador
                WHERE ctiptramit = 3
                  AND cempres = k_cempresa
                  AND ctramitad = x.campo06;
            EXCEPTION
               WHEN OTHERS THEN
                  v_nnumerr := NULL;
            END;

            IF v_nnumerr IS NULL THEN
               v_nnumerr := 9001401;
               p_desout := 'Tramitador incorrecto ' || x.campo06;
               RETURN v_nnumerr;
            END IF;
         END IF;

         RETURN 0;
      EXCEPTION
         WHEN OTHERS THEN
            p_desout := SQLERRM;
            RETURN 1;
      END f_valida_reg51;

      FUNCTION f_valida_reg52(x cur_sin%ROWTYPE, p_desout IN OUT VARCHAR2)
         RETURN NUMBER IS
      BEGIN
         -- bug 0028909 - 14/11/2013 - JMF: Validaciones
         v_nnumerr := NULL;

         IF x.campo03 IS NOT NULL THEN
            BEGIN
               SELECT MAX(1)
                 INTO v_nnumerr
                 FROM detvalores
                WHERE cvalor = 815
                  AND catribu = TO_NUMBER(x.campo03);
            EXCEPTION
               WHEN OTHERS THEN
                  v_nnumerr := NULL;
            END;

            IF v_nnumerr IS NULL THEN
               v_nnumerr := 9000901;
               p_desout := 'Tipo da¿o incorrecto ' || x.campo03;
               RETURN v_nnumerr;
            END IF;
         END IF;

         IF x.campo04 IS NOT NULL THEN
            IF x.campo04 NOT IN('0', '1') THEN
               v_nnumerr := 9000905;
               p_desout := 'Indicador Tramitaci¿n informativa incorrecto ' || x.campo04;
               RETURN v_nnumerr;
            END IF;
         END IF;

         RETURN 0;
      EXCEPTION
         WHEN OTHERS THEN
            p_desout := SQLERRM;
            RETURN 1;
      END f_valida_reg52;

      FUNCTION f_valida_reg53(x cur_sin%ROWTYPE, p_desout IN OUT VARCHAR2)
         RETURN NUMBER IS
      BEGIN
         -- bug 0028909 - 14/11/2013 - JMF: Validaciones
         IF x.campo03 IS NOT NULL THEN
            v_nnumerr := NULL;

            BEGIN
               SELECT MAX(1)
                 INTO v_nnumerr
                 FROM sin_codtramitador
                WHERE ctiptramit = 2
                  AND cempres = k_cempresa
                  AND ctramitad = x.campo03;
            EXCEPTION
               WHEN OTHERS THEN
                  v_nnumerr := NULL;
            END;

            IF v_nnumerr IS NULL THEN
               v_nnumerr := 9001405;
               p_desout := 'Unidad Tramitadora incorrecta ' || x.campo03;
               RETURN v_nnumerr;
            END IF;
         END IF;

         IF x.campo04 IS NOT NULL THEN
            v_nnumerr := NULL;

            BEGIN
               SELECT MAX(1)
                 INTO v_nnumerr
                 FROM sin_codtramitador
                WHERE ctiptramit = 3
                  AND cempres = k_cempresa
                  AND ctramitad = x.campo04;
            EXCEPTION
               WHEN OTHERS THEN
                  v_nnumerr := NULL;
            END;

            IF v_nnumerr IS NULL THEN
               v_nnumerr := 9001401;
               p_desout := 'Tramitadoro incorrecto ' || x.campo04;
               RETURN v_nnumerr;
            END IF;
         END IF;

         IF x.campo05 IS NOT NULL THEN
            v_nnumerr := NULL;

            BEGIN
               SELECT MAX(1)
                 INTO v_nnumerr
                 FROM detvalores
                WHERE cvalor = 6
                  AND catribu = TO_NUMBER(x.campo05);
            EXCEPTION
               WHEN OTHERS THEN
                  v_nnumerr := NULL;
            END;

            IF v_nnumerr IS NULL THEN
               v_nnumerr := 112259;
               p_desout := 'No se ha encontrado estado tramitaci¿n ' || x.campo05;
               RETURN v_nnumerr;
            END IF;
         END IF;

         IF x.campo06 IS NOT NULL THEN
            v_nnumerr := NULL;

            BEGIN
               SELECT MAX(1)
                 INTO v_nnumerr
                 FROM detvalores
                WHERE cvalor = 665
                  AND catribu = TO_NUMBER(x.campo06);
            EXCEPTION
               WHEN OTHERS THEN
                  v_nnumerr := NULL;
            END;

            IF v_nnumerr IS NULL THEN
               v_nnumerr := 112259;
               p_desout := 'No se ha encontrado subestado tramitaci¿n ' || x.campo06;
               RETURN v_nnumerr;
            END IF;
         END IF;

         IF x.campo05 IS NOT NULL
            AND x.campo08 IS NOT NULL THEN
            v_nnumerr := NULL;

            BEGIN
               SELECT MAX(1)
                 INTO v_nnumerr
                 FROM sin_codcauest
                WHERE cestsin = TO_NUMBER(x.campo05)
                  AND ccauest = TO_NUMBER(x.campo08);
            EXCEPTION
               WHEN OTHERS THEN
                  v_nnumerr := NULL;
            END;

            IF v_nnumerr IS NULL THEN
               v_nnumerr := 100852;
               p_desout := 'No se ha encontrado causa estado ' || x.campo05 || '-'
                           || x.campo08;
               RETURN v_nnumerr;
            END IF;
         END IF;

         RETURN 0;
      EXCEPTION
         WHEN OTHERS THEN
            p_desout := SQLERRM;
            RETURN 1;
      END f_valida_reg53;

      FUNCTION f_valida_reg54(x cur_sin%ROWTYPE, p_desout IN OUT VARCHAR2)
         RETURN NUMBER IS
      BEGIN
         -- bug 0028909 - 14/11/2013 - JMF: Validaciones
         IF x.campo03 IS NOT NULL THEN
            v_nnumerr := NULL;

            BEGIN
               SELECT MAX(1)
                 INTO v_nnumerr
                 FROM detvalores
                WHERE cvalor = 322
                  AND catribu = TO_NUMBER(x.campo03);
            EXCEPTION
               WHEN OTHERS THEN
                  v_nnumerr := NULL;
            END;

            IF v_nnumerr IS NULL THEN
               v_nnumerr := 9001155;
               p_desout := 'No se ha encontrado tipo reserva ' || x.campo03;
               RETURN v_nnumerr;
            END IF;
         END IF;

         IF x.campo05 IS NOT NULL THEN
            IF x.campo05 NOT IN(0, 1) THEN
               v_nnumerr := 9002111;
               p_desout := 'No se ha encontrado tipo c¿lculo ' || x.campo05;
               RETURN v_nnumerr;
            END IF;
         END IF;

         IF x.campo05 = '1' THEN
            v_nnumerr := NULL;

            IF x.campo04 IS NOT NULL THEN
               BEGIN
                  SELECT MAX(1)
                    INTO v_nnumerr
                    FROM garanpro a, codiram b
                   WHERE b.cempres = k_cempresa
                     AND a.cramo = b.cramo
                     AND a.cgarant = TO_NUMBER(x.campo04);
               EXCEPTION
                  WHEN OTHERS THEN
                     v_nnumerr := NULL;
               END;
            END IF;

            IF v_nnumerr IS NULL THEN
               v_nnumerr := 9001413;
               p_desout := 'Para reserva autom¿tica, no existe la garant¿a ' || x.campo04;
               RETURN v_nnumerr;
            END IF;
         END IF;

         IF x.campo07 IS NOT NULL THEN
            v_nnumerr := NULL;

            BEGIN
               SELECT MAX(1)
                 INTO v_nnumerr
                 FROM monedas
                WHERE cmonint = x.campo07;
            EXCEPTION
               WHEN OTHERS THEN
                  v_nnumerr := NULL;
            END;

            IF v_nnumerr IS NULL THEN
               v_nnumerr := 108645;
               p_desout := 'No se ha encontrado moneda ' || x.campo07;
               RETURN v_nnumerr;
            END IF;
         END IF;

         RETURN 0;
      EXCEPTION
         WHEN OTHERS THEN
            p_desout := SQLERRM;
            RETURN 1;
      END f_valida_reg54;

      FUNCTION f_valida_reg55(x cur_sin%ROWTYPE, p_desout IN OUT VARCHAR2)
         RETURN NUMBER IS
      BEGIN
         -- bug 0028909 - 14/11/2013 - JMF: Validaciones
         IF x.campo02 IS NOT NULL THEN
            v_nnumerr := NULL;

            BEGIN
               SELECT MAX(1)
                 INTO v_nnumerr
                 FROM detvalores
                WHERE cvalor = 672
                  AND catribu = TO_NUMBER(x.campo02);
            EXCEPTION
               WHEN OTHERS THEN
                  v_nnumerr := NULL;
            END;

            IF v_nnumerr IS NULL THEN
               v_nnumerr := 9904433;
               p_desout := 'No se ha encontrado tipo documento identidad ' || x.campo02;
               RETURN v_nnumerr;
            END IF;
         END IF;

         IF x.campo05 IS NOT NULL THEN
            IF x.campo05 NOT IN('N', 'J') THEN
               v_nnumerr := 102844;
               p_desout := 'No se ha encontrado tipo persona ' || x.campo05;
               RETURN v_nnumerr;
            END IF;
         END IF;

         IF x.campo10 IS NOT NULL THEN
            IF x.campo10 NOT IN('M', 'F') THEN
               v_nnumerr := 9000771;
               p_desout := 'No se ha encontrado g¿nero persona ' || x.campo10;
               RETURN v_nnumerr;
            END IF;
         END IF;

         IF x.campo12 IS NOT NULL THEN
            v_nnumerr := NULL;

            BEGIN
               SELECT MAX(1)
                 INTO v_nnumerr
                 FROM detvalores
                WHERE cvalor = 10
                  AND catribu = TO_NUMBER(x.campo12);
            EXCEPTION
               WHEN OTHERS THEN
                  v_nnumerr := NULL;
            END;

            IF v_nnumerr IS NULL THEN
               v_nnumerr := 9001213;
               p_desout := 'No se ha encontrado tipo destinatario ' || x.campo12;
               RETURN v_nnumerr;
            END IF;
         END IF;

         IF x.campo16 IS NOT NULL THEN
            v_nnumerr := NULL;

            BEGIN
               SELECT MAX(1)
                 INTO v_nnumerr
                 FROM paises
                WHERE codiso = x.campo16;
            EXCEPTION
               WHEN OTHERS THEN
                  v_nnumerr := NULL;
            END;

            IF v_nnumerr IS NULL THEN
               v_nnumerr := 151951;
               p_desout := 'No se ha encontrado pa¿s ' || x.campo16;
               RETURN v_nnumerr;
            END IF;
         END IF;

         IF x.campo17 IS NOT NULL THEN
            v_nnumerr := NULL;

            BEGIN
               SELECT MAX(1)
                 INTO v_nnumerr
                 FROM detvalores
                WHERE cvalor = 205
                  AND catribu = TO_NUMBER(x.campo17);
            EXCEPTION
               WHEN OTHERS THEN
                  v_nnumerr := NULL;
            END;

            IF v_nnumerr IS NULL THEN
               v_nnumerr := 9001213;
               p_desout := 'No se ha encontrado tipo prestaci¿n ' || x.campo17;
               RETURN v_nnumerr;
            END IF;
         END IF;

         IF x.campo18 IS NOT NULL THEN
            v_nnumerr := NULL;

            BEGIN
               SELECT MAX(1)
                 INTO v_nnumerr
                 FROM detvalores
                WHERE cvalor = 1018
                  AND catribu = TO_NUMBER(x.campo18);
            EXCEPTION
               WHEN OTHERS THEN
                  v_nnumerr := NULL;
            END;

            IF v_nnumerr IS NULL THEN
               v_nnumerr := 9901394;
               p_desout := 'No se ha encontrado relaci¿n asegurado ' || x.campo18;
               RETURN v_nnumerr;
            END IF;
         END IF;

         RETURN 0;
      EXCEPTION
         WHEN OTHERS THEN
            p_desout := SQLERRM;
            RETURN 1;
      END f_valida_reg55;

      FUNCTION f_valida_reg56(x cur_sin%ROWTYPE, p_desout IN OUT VARCHAR2)
         RETURN NUMBER IS
      BEGIN
         -- bug 0028909 - 14/11/2013 - JMF: Validaciones
         IF x.campo03 IS NOT NULL THEN
            v_nnumerr := NULL;

            BEGIN
               SELECT MAX(1)
                 INTO v_nnumerr
                 FROM detvalores
                WHERE cvalor = 672
                  AND catribu = TO_NUMBER(x.campo03);
            EXCEPTION
               WHEN OTHERS THEN
                  v_nnumerr := NULL;
            END;

            IF v_nnumerr IS NULL THEN
               v_nnumerr := 9904433;
               p_desout := 'No se ha encontrado tipo documento identidad ' || x.campo03;
               RETURN v_nnumerr;
            END IF;
         END IF;

         IF x.campo05 IS NOT NULL THEN
            v_nnumerr := NULL;

            BEGIN
               SELECT MAX(1)
                 INTO v_nnumerr
                 FROM detvalores
                WHERE cvalor = 10
                  AND catribu = TO_NUMBER(x.campo05);
            EXCEPTION
               WHEN OTHERS THEN
                  v_nnumerr := NULL;
            END;

            IF v_nnumerr IS NULL THEN
               v_nnumerr := 9001213;
               p_desout := 'No se ha encontrado tipo destinatario ' || x.campo05;
               RETURN v_nnumerr;
            END IF;
         END IF;

         IF x.campo06 IS NOT NULL THEN
            v_nnumerr := NULL;

            BEGIN
               SELECT MAX(1)
                 INTO v_nnumerr
                 FROM detvalores
                WHERE cvalor = 2
                  AND catribu = TO_NUMBER(x.campo06);
            EXCEPTION
               WHEN OTHERS THEN
                  v_nnumerr := NULL;
            END;

            IF v_nnumerr IS NULL THEN
               v_nnumerr := 101516;
               p_desout := 'No se ha encontrado tipo pago ' || x.campo06;
               RETURN v_nnumerr;
            END IF;
         END IF;

         IF x.campo07 IS NOT NULL THEN
            v_nnumerr := NULL;

            BEGIN
               SELECT MAX(1)
                 INTO v_nnumerr
                 FROM detvalores
                WHERE cvalor = 803
                  AND catribu = TO_NUMBER(x.campo07);
            EXCEPTION
               WHEN OTHERS THEN
                  v_nnumerr := NULL;
            END;

            IF v_nnumerr IS NULL THEN
               v_nnumerr := 9001284;
               p_desout := 'No se ha encontrado concepto pago ' || x.campo07;
               RETURN v_nnumerr;
            END IF;
         END IF;

         IF x.campo08 IS NOT NULL THEN
            v_nnumerr := NULL;

            BEGIN
               SELECT MAX(1)
                 INTO v_nnumerr
                 FROM detvalores
                WHERE cvalor = 325
                  AND catribu = TO_NUMBER(x.campo08);
            EXCEPTION
               WHEN OTHERS THEN
                  v_nnumerr := NULL;
            END;

            IF v_nnumerr IS NULL THEN
               v_nnumerr := 9001199;
               p_desout := 'No se ha encontrado causa indemnizaci¿n ' || x.campo08;
               RETURN v_nnumerr;
            END IF;
         END IF;

         IF x.campo09 IS NOT NULL THEN
            v_nnumerr := NULL;

            BEGIN
               SELECT MAX(1)
                 INTO v_nnumerr
                 FROM detvalores
                WHERE cvalor = 813
                  AND catribu = TO_NUMBER(x.campo09);
            EXCEPTION
               WHEN OTHERS THEN
                  v_nnumerr := NULL;
            END;

            IF v_nnumerr IS NULL THEN
               v_nnumerr := 100712;
               p_desout := 'No se ha encontrado forma pago ' || x.campo09;
               RETURN v_nnumerr;
            END IF;
         END IF;

         IF x.campo11 IS NOT NULL THEN
            v_nnumerr := NULL;

            BEGIN
               SELECT MAX(1)
                 INTO v_nnumerr
                 FROM tipos_cuentades
                WHERE ctipban = TO_NUMBER(x.campo11);
            EXCEPTION
               WHEN OTHERS THEN
                  v_nnumerr := NULL;
            END;

            IF v_nnumerr IS NULL THEN
               v_nnumerr := 106023;
               p_desout := 'No se ha encontrado tipo entidad ' || x.campo11;
               RETURN v_nnumerr;
            END IF;
         END IF;

         IF x.campo13 IS NOT NULL THEN
            v_nnumerr := NULL;

            BEGIN
               SELECT MAX(1)
                 INTO v_nnumerr
                 FROM monedas
                WHERE cmonint = x.campo13;
            EXCEPTION
               WHEN OTHERS THEN
                  v_nnumerr := NULL;
            END;

            IF v_nnumerr IS NULL THEN
               v_nnumerr := 108645;
               p_desout := 'No se ha encontrado moneda ' || x.campo13;
               RETURN v_nnumerr;
            END IF;
         END IF;

         IF x.campo16 IS NOT NULL THEN
            v_nnumerr := NULL;

            BEGIN
               SELECT MAX(1)
                 INTO v_nnumerr
                 FROM detvalores
                WHERE cvalor = 922
                  AND catribu = TO_NUMBER(x.campo16);
            EXCEPTION
               WHEN OTHERS THEN
                  v_nnumerr := NULL;
            END;

            IF v_nnumerr IS NULL THEN
               v_nnumerr := 100712;
               p_desout := 'No se ha encontrado forma pago ' || x.campo16;
               RETURN v_nnumerr;
            END IF;
         END IF;

         IF x.campo17 IS NOT NULL THEN
            IF x.campo17 NOT IN('0', '1') THEN
               v_nnumerr := 100712;
               p_desout := 'No se ha encontrado forma pago ' || x.campo17;
               RETURN v_nnumerr;
            END IF;
         END IF;

         IF x.campo18 IS NOT NULL THEN
            v_nnumerr := NULL;

            BEGIN
               SELECT MAX(1)
                 INTO v_nnumerr
                 FROM detvalores
                WHERE cvalor = 800112
                  AND catribu = TO_NUMBER(x.campo18);
            EXCEPTION
               WHEN OTHERS THEN
                  v_nnumerr := NULL;
            END;

            IF v_nnumerr IS NULL THEN
               v_nnumerr := 9904294;
               p_desout := 'No se ha encontrado tipo tributaci¿n ' || x.campo18;
               RETURN v_nnumerr;
            END IF;
         END IF;

         IF x.campo29 IS NOT NULL THEN
            v_nnumerr := NULL;

            BEGIN
               SELECT MAX(1)
                 INTO v_nnumerr
                 FROM monedas
                WHERE cmonint = x.campo29;
            EXCEPTION
               WHEN OTHERS THEN
                  v_nnumerr := NULL;
            END;

            IF v_nnumerr IS NULL THEN
               v_nnumerr := 108645;
               p_desout := 'No se ha encontrado moneda pago ' || x.campo29;
               RETURN v_nnumerr;
            END IF;
         END IF;

         RETURN 0;
      EXCEPTION
         WHEN OTHERS THEN
            p_desout := SQLERRM;
            RETURN 1;
      END f_valida_reg56;

      FUNCTION f_valida_reg57(x cur_sin%ROWTYPE, p_desout IN OUT VARCHAR2)
         RETURN NUMBER IS
      BEGIN
         -- bug 0028909 - 14/11/2013 - JMF: Validaciones
         IF x.campo03 IS NOT NULL THEN
            v_nnumerr := NULL;

            BEGIN
               SELECT MAX(1)
                 INTO v_nnumerr
                 FROM detvalores
                WHERE cvalor = 322
                  AND catribu = TO_NUMBER(x.campo03);
            EXCEPTION
               WHEN OTHERS THEN
                  v_nnumerr := NULL;
            END;

            IF v_nnumerr IS NULL THEN
               v_nnumerr := 9001155;
               p_desout := 'No se ha encontrado tipo reserva ' || x.campo03;
               RETURN v_nnumerr;
            END IF;
         END IF;

         IF x.campo05 IS NOT NULL THEN
            v_nnumerr := NULL;

            BEGIN
               SELECT MAX(1)
                 INTO v_nnumerr
                 FROM monedas
                WHERE cmonint = x.campo05;
            EXCEPTION
               WHEN OTHERS THEN
                  v_nnumerr := NULL;
            END;

            IF v_nnumerr IS NULL THEN
               v_nnumerr := 108645;
               p_desout := 'No se ha encontrado moneda reserva ' || x.campo05;
               RETURN v_nnumerr;
            END IF;
         END IF;

         IF x.campo22 IS NOT NULL THEN
            v_nnumerr := NULL;

            BEGIN
               SELECT MAX(1)
                 INTO v_nnumerr
                 FROM monedas
                WHERE cmonint = x.campo22;
            EXCEPTION
               WHEN OTHERS THEN
                  v_nnumerr := NULL;
            END;

            IF v_nnumerr IS NULL THEN
               v_nnumerr := 108645;
               p_desout := 'No se ha encontrado moneda pago ' || x.campo21;
               RETURN v_nnumerr;
            END IF;
         END IF;

         RETURN 0;
      EXCEPTION
         WHEN OTHERS THEN
            p_desout := SQLERRM;
            RETURN 1;
      END f_valida_reg57;

      FUNCTION f_valida_reg58(x cur_sin%ROWTYPE, p_desout IN OUT VARCHAR2)
         RETURN NUMBER IS
      BEGIN
         -- bug 0028909 - 14/11/2013 - JMF: Validaciones
         IF x.campo04 IS NOT NULL THEN
            v_nnumerr := NULL;

            BEGIN
               SELECT MAX(1)
                 INTO v_nnumerr
                 FROM detvalores
                WHERE cvalor = 3
                  AND catribu = TO_NUMBER(x.campo04);
            EXCEPTION
               WHEN OTHERS THEN
                  v_nnumerr := NULL;
            END;

            IF v_nnumerr IS NULL THEN
               v_nnumerr := 9001326;
               p_desout := 'No se ha encontrado estado pago ' || x.campo04;
               RETURN v_nnumerr;
            END IF;
         END IF;

         IF x.campo06 IS NOT NULL THEN
            v_nnumerr := NULL;

            BEGIN
               SELECT MAX(1)
                 INTO v_nnumerr
                 FROM detvalores
                WHERE cvalor = 324
                  AND catribu = TO_NUMBER(x.campo06);
            EXCEPTION
               WHEN OTHERS THEN
                  v_nnumerr := NULL;
            END;

            IF v_nnumerr IS NULL THEN
               v_nnumerr := 9000948;
               p_desout := 'No se ha encontrado estado validaci¿n ' || x.campo06;
               RETURN v_nnumerr;
            END IF;
         END IF;

         IF x.campo07 IS NOT NULL THEN
            v_nnumerr := NULL;

            BEGIN
               SELECT MAX(1)
                 INTO v_nnumerr
                 FROM detvalores
                WHERE cvalor = 1051
                  AND catribu = TO_NUMBER(x.campo07);
            EXCEPTION
               WHEN OTHERS THEN
                  v_nnumerr := NULL;
            END;

            IF v_nnumerr IS NULL THEN
               v_nnumerr := 9000948;
               p_desout := 'No se ha encontrado subestado validaci¿n ' || x.campo07;
               RETURN v_nnumerr;
            END IF;
         END IF;

         RETURN 0;
      EXCEPTION
         WHEN OTHERS THEN
            p_desout := SQLERRM;
            RETURN 1;
      END f_valida_reg58;

-- 59
      FUNCTION f_valida_reg59(x cur_sin%ROWTYPE, p_desout IN OUT VARCHAR2)
         RETURN NUMBER IS
      BEGIN
         RETURN 0;
      EXCEPTION
         WHEN OTHERS THEN
            p_desout := SQLERRM;
            RETURN 1;
      END f_valida_reg59;

-- Registro 60
      FUNCTION f_valida_reg60(x cur_sin%ROWTYPE, p_desout IN OUT VARCHAR2)
         RETURN NUMBER IS
      BEGIN
         IF x.campo02 IS NOT NULL THEN
            v_nnumerr := NULL;

            BEGIN
               SELECT MAX(1)
                 INTO v_nnumerr
                 FROM detvalores
                WHERE cvalor = 672
                  AND catribu = TO_NUMBER(x.campo02);
            EXCEPTION
               WHEN OTHERS THEN
                  v_nnumerr := NULL;
            END;

            IF v_nnumerr IS NULL THEN
               v_nnumerr := 9904433;
               p_desout := 'No se ha encontrado tipo documento identidad ' || x.campo02;
               RETURN v_nnumerr;
            END IF;
         END IF;

--
         IF x.campo12 IS NOT NULL THEN
            v_nnumerr := NULL;

            BEGIN
               SELECT MAX(1)
                 INTO v_nnumerr
                 FROM detvalores
                WHERE cvalor = 800111
                  AND catribu = TO_NUMBER(x.campo12);
            EXCEPTION
               WHEN OTHERS THEN
                  v_nnumerr := NULL;
            END;

            IF v_nnumerr IS NULL THEN
               v_nnumerr := 9902248;
               p_desout := 'No se ha encontrado tipo de relaci¿n ' || x.campo12;
               RETURN v_nnumerr;
            END IF;
         END IF;

         RETURN 0;
      EXCEPTION
         WHEN OTHERS THEN
            p_desout := SQLERRM;
            RETURN 1;
      END f_valida_reg60;
   BEGIN
      v_ntraza := 0;

      IF p_ssproces IS NULL THEN
         v_nnumerr := 9000505;
         v_tdeserror := 'Par¿metro p_ssproces obligatorio.';
         p_genera_logs(v_tobjeto, v_ntraza, 'Error:' || v_nnumerr, v_tdeserror);
         RAISE e_salir;
      END IF;

      v_ntraza := 1;
      v_toperacion := NULL;
      v_sseguro := NULL;
      v_ncarga := NULL;
      v_id_linea_1 := NULL;

      --    v_ntipoerror := 0;
      FOR x IN cur_sin(p_ssproces) LOOP
         BEGIN
            --Leemos los registros de la tabla int no procesados OK
            IF x.tiporegistro IN(1, 50) THEN   -- si cambio de bloque de resgistros de siniestros
               IF v_id IS NOT NULL
                  AND v_mig_sin.ncarga IS NOT NULL
                  AND v_ntipoerror NOT IN(1, 4) THEN
                  IF v_toperacion = 'SIN' THEN
                     v_nnumerr := f_lanza_migracion_sin(v_id, v_ncarga);
                  ELSIF v_toperacion = 'SINM' THEN
                     -- ya he actualizado los movimientos del recibo
                      -- tengo que grabar el resultado
                     NULL;
                  END IF;

                  IF v_nnumerr NOT IN(0, 2, 4) THEN   -- si ha habido error
                     v_berrorlin := TRUE;
                     v_berrorproc := TRUE;
                     ROLLBACK;

                     IF k_cpara_error <> 1 THEN
                        v_ntipoerror := 4;
                     -- para que continue con la siguiente linea.
                     ELSE
                        v_ntipoerror := 1;   -- para la carga
                        RAISE e_salir;
                     END IF;
                  ELSE
                     COMMIT;
                  END IF;

                  IF v_id_linea_1 IS NOT NULL
                     AND x.tiporegistro = 1 THEN
                     IF v_berrorlin THEN
                        v_nnumerr := p_marcalinea(x.proceso, v_id_linea_1, v_toperacion, 1, 0,
                                                  v_sseguro, v_id, v_ncarga, NULL, NULL, NULL,
                                                  NULL,
                                                  v_id_linea_1 || '(' || x.tiporegistro || ')');
                     ELSE
                        v_nnumerr := p_marcalinea(x.proceso, v_id_linea_1, v_toperacion, 4, 1,
                                                  v_sseguro, v_id, v_ncarga, NULL, NULL, NULL,
                                                  NULL,
                                                  v_id_linea_1 || '(' || x.tiporegistro || ')');
                     END IF;

                     v_id_linea_1 := NULL;
                  END IF;
               END IF;

               v_ncarga := f_next_carga;
               v_mig_sin := NULL;
               v_mig_movsin := NULL;
               v_mig_sintram := NULL;
               v_mig_sintram_mov := NULL;
               v_mig_sintram_res := NULL;
               v_mig_sintram_dest := NULL;
               v_mig_sintram_pago := NULL;
               v_mig_sintram_movpago := NULL;
               v_mig_sintram_pago_gar := NULL;
               reg_migpersonas := NULL;
               v_ntipoerror := 0;
            END IF;

            IF x.tiporegistro <> 1 THEN
               v_nnumerr := p_marcalinea(x.proceso, x.nlinea, v_toperacion, 3, 0, NULL, v_id,
                                         v_ncarga, NULL, NULL, NULL, NULL,
                                         x.nlinea || '(' || x.tiporegistro || ')');
            END IF;

            v_ntraza := 3;
            v_id_linea := x.nlinea;

            IF v_ntipoerror NOT IN(1, 4) THEN
               v_ntraza := 1010;

               -- RESTISTRO 1
               IF x.tiporegistro = '1' THEN   -- polizas
                  v_id := TRIM(x.campo03) || '-' || x.campo04;
                  v_toperacion := NULL;
                  v_ntipoerror := 0;
                  v_nnumerr := p_marcalinea(x.proceso, x.nlinea, v_toperacion, 3, 0, NULL,
                                            v_id, v_ncarga, NULL, NULL, NULL, NULL,
                                            x.nlinea || '(' || x.tiporegistro || ')');
                  v_sseguro := NULL;
                  --
                  v_id_linea_1 := x.nlinea;
                  --v_ncarga := f_next_carga;
                  v_berrorlin := FALSE;

                  --Inicializamos la clinea
                  IF x.campo02 IS NULL THEN   -- miro si el producto esta cargado
                     --Inicializamos la linea
                     v_nnumerr := p_marcalinea(x.proceso, x.nlinea, v_toperacion, 3, 0, NULL,
                                               v_id, v_ncarga, NULL, NULL, NULL, NULL,
                                               x.nlinea || '(' || x.tiporegistro || ')');
                     v_tdeserror := ' C¿digo producto no definido: ' || x.campo02;
                     v_nnumerr := 104347;
                     RAISE e_errdatos;
                  END IF;

                  v_admite_certificados :=
                       NVL(pac_parametros.f_parproducto_n(x.campo02, 'ADMITE_CERTIFICADOS'), 0);

                  IF (TRIM(x.campo03) IS NULL
                      AND v_admite_certificados = 0)
                     AND(TRIM(x.campo03) IS NOT NULL
                         AND TRIM(x.campo04) IS NULL
                         AND TRIM(x.campo16) IS NULL
                         AND TRIM(x.campo17) IS NULL
                         AND v_admite_certificados = 1)
                     AND(TRIM(x.campo05) IS NULL) THEN
                     v_tdeserror :=
                        'Error en identificador de p¿liza, para el tipo de producto definido -->'
                        || x.campo03;
                     v_nnumerr := 140897;
                     RAISE e_errdatos;
                  ELSIF (TRIM(x.campo03) IS NOT NULL
                         AND v_admite_certificados = 0)
                        OR(TRIM(x.campo03) IS NOT NULL
                           AND TRIM(x.campo04) IS NOT NULL
                           AND v_admite_certificados = 1) THEN
                     NULL;
                  ELSIF v_admite_certificados = 1
                        AND TRIM(x.campo03) IS NOT NULL
                        AND TRIM(x.campo04) IS NULL
                        AND TRIM(x.campo16) IS NOT NULL
                        AND TRIM(x.campo17) IS NOT NULL THEN
                     -- Si me llega el certificado 0 a nulo miro si me llega el asegurado
                       -- busco el certificado para ese producto/poliza, y que tenga ese asegurado
                     BEGIN
                        SELECT ncertif
                          INTO x.campo04   -- lo grabo en el certificado
                          FROM seguros seg, asegurados aseg
                         WHERE npoliza = TRIM(x.campo03)
                           AND sproduc = x.campo02
                           AND ncertif <> 0
                           AND seg.sseguro = aseg.sseguro
                           AND sperson IN(SELECT sperson
                                            FROM per_personas
                                           WHERE ctipide = TRIM(x.campo16)
                                             AND nnumide = TRIM(x.campo17));
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           v_tdeserror :=
                              'Error en el campo de poliza, para el tipo de producto definido -->'
                              || x.campo03;
                           v_nnumerr := 103946;
                           RAISE e_errdatos;
                        WHEN TOO_MANY_ROWS THEN
                           v_tdeserror :=
                              'Hay m¿s de un certificado coincidente para la poliza y asegurado indicado -->'
                              || x.campo03 || ' - ' || x.campo16;
                           v_nnumerr := 9001114;
                           RAISE e_errdatos;
                     END;
                  ELSIF TRIM(x.campo05) IS NOT NULL   -- miro si llega la referencia externa
                                                   THEN
                     -- Si me llega el certificado 0 a nulo miro si me llega el asegurado
                       -- busco el certificado para ese producto/poliza, y que tenga ese asegurado
                     BEGIN
                        SELECT npoliza, ncertif
                          INTO x.campo03, x.campo04   -- lo grabo en la poliza / certificado
                          FROM seguros seg
                         WHERE cpolcia = TRIM(x.campo05)
                           AND sproduc = x.campo02;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           v_tdeserror :=
                              'Error en el campo de n¿mero propuesta externo, no se encuentra en el sistema -->'
                              || x.campo05;
                           v_nnumerr := 103946;
                           RAISE e_errdatos;
                        WHEN TOO_MANY_ROWS THEN
                           v_tdeserror :=
                              'Hay m¿s de una p¿liza coincidente para n¿mero propuesta externo -->'
                              || x.campo05;
                           v_nnumerr := 9001114;
                           RAISE e_errdatos;
                     END;
                  ELSE
                     v_tdeserror :=
                        'Error en el campo de poliza, para el n¿mero de producto definido -->'
                        || x.campo03;
                     v_nnumerr := 140897;
                     RAISE e_errdatos;
                  END IF;

                  BEGIN
                     SELECT sseguro
                       INTO v_sseguro
                       FROM seguros
                      WHERE npoliza = NVL(TRIM(x.campo03), 0)
                        AND ncertif = NVL(x.campo04, 0)
                        AND sproduc = x.campo02;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        v_tdeserror :=
                           'Error en el campo de poliza, para el tipo de producto definido -->'
                           || x.campo03;
                        v_nnumerr := 103946;
                        RAISE e_errdatos;
                  END;
               -- siniestro
               ELSIF x.tiporegistro = '50' THEN
                  IF x.campo01 IS NULL THEN   -- es un alta
                     v_toperacion := 'SIN';

                     IF v_sseguro IS NULL THEN
                        v_tdeserror :=
                           'No se ha informado correctamente el registro de p¿liza.'
                           || x.campo03;
                        v_nnumerr := 103946;
                        RAISE e_errdatos;
                     END IF;

                     --   v_ncarga := f_next_carga;

                     -- no la encuentro la trato como alta.
                     INSERT INTO mig_cargas
                                 (ncarga, cempres, finiorg, ffinorg, ID, estorg)
                          VALUES (v_ncarga, k_cempresa, f_sysdate, f_sysdate, v_id, NULL);

                     INSERT INTO mig_cargas_tab_mig
                                 (ncarga, tab_org, tab_des, ntab, finides,
                                  ffindes)
                          VALUES (v_ncarga, 'INT_CARGA_GENERICO', 'MIG_SEGUROS', 0, f_sysdate,
                                  f_sysdate);

                     v_mig_sin.mig_pk := v_ncarga;
                     v_ntraza := 1055;

                     SELECT v_ncarga ncarga, -1 cestmig, v_mig_sin.mig_pk mig_pk,
                            v_mig_sin.mig_pk mig_fk, cagente, npoliza,
                            ncertif, fefecto, creafac,
                            cactivi, ctiprea, cidioma,
                            cforpag, cempres, sproduc,
                            casegur, nsuplem, sseguro,
                            0 sperson
                       INTO v_mig_seg.ncarga, v_mig_seg.cestmig, v_mig_seg.mig_pk,
                            v_mig_seg.mig_fk, v_mig_seg.cagente, v_mig_seg.npoliza,
                            v_mig_seg.ncertif, v_mig_seg.fefecto, v_mig_seg.creafac,
                            v_mig_seg.cactivi, v_mig_seg.ctiprea, v_mig_seg.cidioma,
                            v_mig_seg.cforpag, v_mig_seg.cempres, v_mig_seg.sproduc,
                            v_mig_seg.casegur, v_mig_seg.nsuplem, v_mig_seg.sseguro,
                            v_mig_seg.sperson
                       FROM seguros
                      WHERE sseguro = v_sseguro;

                     v_ntraza := 1060;
                     -- bug 0028909 - 14/11/2013 - JMF: Validaciones
                     v_nnumerr := f_valida_reg50(x, v_mig_seg.sproduc, v_tdeserror);

                     IF v_nnumerr <> 0 THEN
                        RAISE e_errdatos;
                     END IF;

                     INSERT INTO mig_seguros
                          VALUES v_mig_seg
                       RETURNING ROWID
                            INTO v_rowid;

                     INSERT INTO mig_pk_emp_mig
                          VALUES (0, v_ncarga, 0, v_mig_seg.mig_pk);

       -- Recupero datos siniestros
        --------------------------------------------------------------------------
-- siniestros
--------------------------------------------------------------------------
                     INSERT INTO mig_cargas_tab_mig
                                 (ncarga, tab_org, tab_des, ntab)
                          VALUES (v_ncarga, 'INT_CARGA_GENERICO', 'MIG_SIN_SINIESTRO', 1);

                     v_mig_sin.ncarga := v_ncarga;
                     v_mig_sin.mig_fk := v_mig_sin.mig_pk;
                     v_mig_sin.cestmig := 1;
                     v_mig_sin.nsinies := 0;
                     v_mig_sin.sseguro := v_sseguro;
                     v_ntraza := 1065;
                     v_mig_sin.nriesgo := x.campo03;
                     v_mig_sin.fsinies := f_chartodate(x.campo05);
                     v_mig_sin.fnotifi := f_chartodate(x.campo06);

                     SELECT MAX(nmovimi)
                       INTO v_mig_sin.nmovimi
                       FROM movseguro
                      WHERE sseguro = v_sseguro
                        AND fefecto <= v_mig_sin.fsinies;

                     IF v_mig_sin.nmovimi IS NULL THEN
                        v_ntraza := 1085;

                        SELECT MAX(nmovimi)
                          INTO v_mig_sin.nmovimi
                          FROM movseguro
                         WHERE sseguro = v_sseguro;

                        IF v_mig_sin.nmovimi IS NULL THEN
                           v_tdeserror := 'Seguro: ' || v_sseguro;
                           v_nnumerr := 104348;
                           RAISE e_errdatos;
                        END IF;
                     END IF;

                     v_mig_sin.ccausin := x.campo07;
                     v_mig_sin.cmotsin := x.campo08;
                     v_mig_sin.cevento := x.campo10;
                     v_mig_sin.cculpab := NULL;
                     v_mig_sin.creclama := NULL;
                     v_mig_sin.nasegur := NULL;
                     v_mig_sin.cmeddec := x.campo11;
                     v_mig_sin.ctipdec := x.campo12;
                     v_mig_sin.ctipide := x.campo13;
                     v_mig_sin.nnumide := x.campo14;
                     v_mig_sin.tnom1dec := x.campo15;
                     v_mig_sin.tnom2dec := x.campo16;
                     v_mig_sin.tnomdec := TRIM(x.campo15 || ' ' || x.campo16);
                     v_mig_sin.tape1dec := x.campo17;
                     v_mig_sin.tape2dec := x.campo18;
                     v_mig_sin.tteldec := x.campo19;
                     v_mig_sin.temaildec := x.campo20;
                     v_mig_sin.cagente := x.campo21;
                     v_mig_sin.ccarpeta := x.campo22;
                     v_mig_sin.tsinies := x.campo09;
                     v_mig_sin.ncuacoa := NULL;
                     v_mig_sin.nsincoa := NULL;
                     v_mig_sin.csincia := TRIM(x.campo02);
                     v_mig_sin.cusualt := f_user;
                     v_mig_sin.falta := f_sysdate;

                     IF v_mig_sin.fsinies IS NULL THEN
                        v_tdeserror := 'Fecha siniestro no es una fecha valida: ' || x.campo05
                                       || ' (dd/mm/yyyy)';
                        v_nnumerr := 1000135;
                        RAISE e_errdatos;
                     END IF;

                     v_ntraza := 1070;

                     IF v_mig_sin.fnotifi IS NULL THEN
                        v_tdeserror := 'Fecha notificaci¿n no es una fecha valida: '
                                       || x.campo06 || ' (dd/mm/yyyy)';
                        v_nnumerr := 1000135;
                        RAISE e_errdatos;
                     END IF;

                     --
                     v_ntraza := 1100;

                     INSERT INTO mig_sin_siniestro
                          VALUES v_mig_sin
                       RETURNING ROWID
                            INTO v_rowid;

                     INSERT INTO mig_pk_emp_mig
                          VALUES (0, v_ncarga, 1, v_mig_sin.mig_pk);
                  ELSE
                     v_toperacion := 'SINM';
                     v_mig_sin.nsinies := TRIM(x.campo01);
                  END IF;
               -- moviientos de siniestros
               ELSIF x.tiporegistro = '51' THEN
                  -- bug 0028909 - 14/11/2013 - JMF: Validaciones
                  v_nnumerr := f_valida_reg51(x, v_tdeserror);

                  IF v_nnumerr <> 0 THEN
                     RAISE e_errdatos;
                  END IF;

                  INSERT INTO mig_cargas_tab_mig
                              (ncarga, tab_org, tab_des, ntab)
                       VALUES (v_ncarga, 'INT_CARGA_GENERICO', 'MIG_SIN_MOVSINIESTRO', 2);

                  v_mig_movsin.ncarga := v_ncarga;
                  v_mig_movsin.cestmig := 1;
                  v_mig_movsin.mig_pk := v_mig_sin.mig_pk || '/' || x.campo01;
                  v_mig_movsin.mig_fk := v_mig_sin.mig_pk;
                  v_mig_movsin.nsinies := v_mig_sin.nsinies;
                  v_mig_movsin.nmovsin := x.campo01;   --0;   -- para que calcule el siguiente movimiento
                  v_mig_movsin.cestsin := x.campo02;
                  v_mig_movsin.festsin := f_chartodate(x.campo03);
                  v_mig_movsin.ccauest := x.campo04;
                  v_mig_movsin.cunitra := x.campo05;
                  v_mig_movsin.ctramitad := x.campo06;
                  v_mig_movsin.cusualt := f_user;
                  v_mig_movsin.falta := f_sysdate;

                  INSERT INTO mig_sin_movsiniestro
                       VALUES v_mig_movsin
                    RETURNING ROWID
                         INTO v_rowid;

                  INSERT INTO mig_pk_emp_mig
                       VALUES (0, v_ncarga, 2, v_mig_movsin.mig_pk);
               -- tramitaciones
               ELSIF x.tiporegistro = '52' THEN
                  -- bug 0028909 - 14/11/2013 - JMF: Validaciones
                  v_nnumerr := f_valida_reg52(x, v_tdeserror);

                  IF v_nnumerr <> 0 THEN
                     RAISE e_errdatos;
                  END IF;

                  INSERT INTO mig_cargas_tab_mig
                              (ncarga, tab_org, tab_des, ntab)
                       VALUES (v_ncarga, 'INT_CARGA_GENERICO', 'MIG_SIN_TRAMITACION', 3);

                  v_mig_sintram.ncarga := v_ncarga;
                  v_mig_sintram.cestmig := 1;
                  v_mig_sintram.mig_pk := v_mig_sin.mig_pk || '/' || x.campo01;
                  v_mig_sintram.mig_fk := v_mig_sin.mig_pk;
                  v_mig_sintram.nsinies := v_mig_sin.nsinies;
                  v_mig_sintram.ntramit := x.campo01;
                  v_mig_sintram.ctramit := x.campo02;
                  v_mig_sintram.ctcausin := x.campo03;
                  v_mig_sintram.cinform := NVL(x.campo04, 0);
                  v_mig_sintram.fformalizacion := f_chartodate(x.campo05);
                  v_mig_sintram.cusualt := f_user;
                  v_mig_sintram.falta := f_sysdate;

                  INSERT INTO mig_sin_tramitacion
                       VALUES v_mig_sintram
                    RETURNING ROWID
                         INTO v_rowid;

                  INSERT INTO mig_pk_emp_mig
                       VALUES (0, v_ncarga, 3, v_mig_sintram.mig_pk);
               -- Movimientos tramitaciones
               ELSIF x.tiporegistro = '53' THEN
                  -- bug 0028909 - 14/11/2013 - JMF: Validaciones
                  v_nnumerr := f_valida_reg53(x, v_tdeserror);

                  IF v_nnumerr <> 0 THEN
                     RAISE e_errdatos;
                  END IF;

                  INSERT INTO mig_cargas_tab_mig
                              (ncarga, tab_org, tab_des, ntab)
                       VALUES (v_ncarga, 'INT_CARGA_GENERICO', 'MIG_SIN_TRAMITA_MOVIMIENTO', 4);

                  v_mig_sintram_mov.ncarga := v_ncarga;
                  v_mig_sintram_mov.cestmig := 1;
                  v_mig_sintram_mov.mig_pk := v_mig_sin.mig_pk || '/' || x.campo01 || '/'
                                              || x.campo02;
                  v_mig_sintram_mov.mig_fk := v_mig_sin.mig_pk || '/' || x.campo01;
                  v_mig_sintram_mov.nsinies := v_mig_sin.nsinies;
                  v_mig_sintram_mov.ntramit := x.campo01;
                  v_mig_sintram_mov.nmovtra := x.campo02;
                  v_mig_sintram_mov.cunitra := x.campo03;
                  v_mig_sintram_mov.ctramitad := x.campo04;
                  v_mig_sintram_mov.cesttra := x.campo05;
                  v_mig_sintram_mov.csubtra := x.campo06;
                  v_mig_sintram_mov.festtra := f_chartodate(x.campo07);
                  v_mig_sintram_mov.ccauest := x.campo08;
                  v_mig_sintram_mov.cusualt := f_user;
                  v_mig_sintram_mov.falta := f_sysdate;

                  INSERT INTO mig_sin_tramita_movimiento
                       VALUES v_mig_sintram_mov
                    RETURNING ROWID
                         INTO v_rowid;

                  INSERT INTO mig_pk_emp_mig
                       VALUES (0, v_ncarga, 4, v_mig_sintram_mov.mig_pk);
-- Reserva tramitaciones
               ELSIF x.tiporegistro = '54' THEN
                  -- bug 0028909 - 14/11/2013 - JMF: Validaciones
                  v_nnumerr := f_valida_reg54(x, v_tdeserror);

                  IF v_nnumerr <> 0 THEN
                     RAISE e_errdatos;
                  END IF;

                  INSERT INTO mig_cargas_tab_mig
                              (ncarga, tab_org, tab_des, ntab)
                       VALUES (v_ncarga, 'INT_CARGA_GENERICO', 'MIG_SIN_TRAMITA_RESERVA', 5);

                  -- ini bug 0028909 - 09/12/2013 - JMF: Si es automatica, generamos las dependientes
                  -- evitar numero reserva duplicado
                  SELECT MAX(b.nmovres)
                    INTO v_nmovres
                    FROM mig_sin_tramita_reserva b
                   WHERE b.ncarga = v_ncarga
                     AND b.ntramit = x.campo01
                     AND b.nmovres = x.campo02
                     AND b.nsinies = v_mig_sin.nsinies;

                  IF v_nmovres IS NULL THEN
                     v_nmovres := x.campo02;
                  ELSE
                     SELECT MAX(b.nmovres) + 1
                       INTO v_nmovres
                       FROM mig_sin_tramita_reserva b
                      WHERE b.ncarga = v_ncarga
                        AND b.ntramit = x.campo01
                        AND b.nsinies = v_mig_sin.nsinies;
                  END IF;

                  -- fin bug 0028909 - 09/12/2013 - JMF: Si es automatica, generamos las dependientes
                  v_mig_sintram_res.ncarga := v_ncarga;
                  v_mig_sintram_res.cestmig := 1;
                  v_mig_sintram_res.mig_pk := v_mig_sin.mig_pk || '/' || x.campo01 || '/'
                                              || v_nmovres || '/' || x.campo03;
                  v_mig_sintram_res.mig_fk := v_mig_sin.mig_pk || '/' || x.campo01;
                  v_mig_sintram_res.nsinies := v_mig_sin.nsinies;
                  v_mig_sintram_res.ntramit := x.campo01;
                  v_mig_sintram_res.nmovres := v_nmovres;
                  v_mig_sintram_res.ctipres := x.campo03;
                  v_mig_sintram_res.cgarant := x.campo04;
                  v_mig_sintram_res.ccalres := x.campo05;
                  v_mig_sintram_res.fmovres := f_chartodate(x.campo06);
                  v_mig_sintram_res.cmonres := x.campo07;
                  v_mig_sintram_res.ireserva := f_chartonumber(x.campo08);
                  v_mig_sintram_res.ireserva_moncia :=
                                     NVL(f_chartonumber(x.campo09), v_mig_sintram_res.ireserva);
                  v_mig_sintram_res.ipago := NULL;
                  v_mig_sintram_res.iingreso := NULL;
                  v_mig_sintram_res.irecobro := NULL;
                  v_mig_sintram_res.icaprie := NVL(f_chartonumber(x.campo10),
                                                   v_mig_sintram_res.ireserva);
                  v_mig_sintram_res.icaprie_moncia :=
                                      NVL(f_chartonumber(x.campo11), v_mig_sintram_res.icaprie);
                  v_mig_sintram_res.ipenali := f_chartonumber(x.campo12);
                  v_mig_sintram_res.ipenali_moncia :=
                                      NVL(f_chartonumber(x.campo13), v_mig_sintram_res.ipenali);
                  v_mig_sintram_res.fresini := f_chartodate(x.campo14);
                  v_mig_sintram_res.fresfin := f_chartodate(x.campo15);
                  v_mig_sintram_res.fcambio := f_chartodate(x.campo16);
                  v_mig_sintram_res.cmovres := x.campo17;
                  v_mig_sintram_res.fultpag := NULL;
                  v_mig_sintram_res.sidepag := NULL;
                  v_mig_sintram_res.sproces := NULL;
                  v_mig_sintram_res.fcontab := NULL;
                  v_mig_sintram_res.cusualt := f_user;
                  v_mig_sintram_res.falta := f_sysdate;

                  INSERT INTO mig_sin_tramita_reserva
                       VALUES v_mig_sintram_res
                    RETURNING ROWID
                         INTO v_rowid;

                  INSERT INTO mig_pk_emp_mig
                       VALUES (0, v_ncarga, 5, v_mig_sintram_res.mig_pk);

                  -- ini bug 0028909 - 09/12/2013 - JMF: Si es automatica, generamos las dependientes
                  IF x.campo05 = '1' THEN
                     FOR f1 IN (SELECT a.cgardep
                                  FROM sin_gar_dependientes a
                                 WHERE a.cgarant = x.campo04
                                   AND a.cempres = k_cempresa
                                   AND NOT EXISTS(
                                         SELECT 1
                                           FROM mig_sin_tramita_reserva b
                                          WHERE b.ncarga = v_ncarga
                                            AND b.nsinies = v_mig_sin.nsinies
                                            AND b.cgarant = a.cgardep)) LOOP
                        -- evitar numero reserva duplicado
                        SELECT MAX(b.nmovres)
                          INTO v_nmovres
                          FROM mig_sin_tramita_reserva b
                         WHERE b.ncarga = v_ncarga
                           AND b.ntramit = x.campo01
                           AND b.nmovres = x.campo02
                           AND b.nsinies = v_mig_sin.nsinies;

                        IF v_nmovres IS NULL THEN
                           v_nmovres := x.campo02;
                        ELSE
                           SELECT MAX(b.nmovres) + 1
                             INTO v_nmovres
                             FROM mig_sin_tramita_reserva b
                            WHERE b.ncarga = v_ncarga
                              AND b.ntramit = x.campo01
                              AND b.nsinies = v_mig_sin.nsinies;
                        END IF;

                        v_mig_sintram_res.ncarga := v_ncarga;
                        v_mig_sintram_res.cestmig := 1;
                        v_mig_sintram_res.mig_pk :=
                           v_mig_sin.mig_pk || '/' || x.campo01 || '/' || v_nmovres || '/'
                           || x.campo03;
                        v_mig_sintram_res.mig_fk := v_mig_sin.mig_pk || '/' || x.campo01;
                        v_mig_sintram_res.nsinies := v_mig_sin.nsinies;
                        v_mig_sintram_res.ntramit := x.campo01;
                        v_mig_sintram_res.nmovres := v_nmovres;
                        v_mig_sintram_res.ctipres := x.campo03;
                        v_mig_sintram_res.cgarant := f1.cgardep;   -- garantia dependiente
                        v_mig_sintram_res.ccalres := x.campo05;
                        v_mig_sintram_res.fmovres := f_chartodate(x.campo06);
                        v_mig_sintram_res.cmonres := x.campo07;
                        v_mig_sintram_res.ireserva := f_chartonumber(x.campo08);
                        v_mig_sintram_res.ireserva_moncia :=
                                     NVL(f_chartonumber(x.campo09), v_mig_sintram_res.ireserva);
                        v_mig_sintram_res.ipago := NULL;
                        v_mig_sintram_res.iingreso := NULL;
                        v_mig_sintram_res.irecobro := NULL;
                        v_mig_sintram_res.icaprie :=
                                     NVL(f_chartonumber(x.campo10), v_mig_sintram_res.ireserva);
                        v_mig_sintram_res.icaprie_moncia :=
                                      NVL(f_chartonumber(x.campo11), v_mig_sintram_res.icaprie);
                        v_mig_sintram_res.ipenali := f_chartonumber(x.campo12);
                        v_mig_sintram_res.ipenali_moncia :=
                                      NVL(f_chartonumber(x.campo13), v_mig_sintram_res.ipenali);
                        v_mig_sintram_res.fresini := f_chartodate(x.campo14);
                        v_mig_sintram_res.fresfin := f_chartodate(x.campo15);
                        v_mig_sintram_res.fcambio := f_chartodate(x.campo16);
                        v_mig_sintram_res.fultpag := NULL;
                        v_mig_sintram_res.sidepag := NULL;
                        v_mig_sintram_res.sproces := NULL;
                        v_mig_sintram_res.fcontab := NULL;
                        v_mig_sintram_res.cusualt := f_user;
                        v_mig_sintram_res.falta := f_sysdate;

                        INSERT INTO mig_sin_tramita_reserva
                             VALUES v_mig_sintram_res
                          RETURNING ROWID
                               INTO v_rowid;

                        INSERT INTO mig_pk_emp_mig
                             VALUES (0, v_ncarga, 5, v_mig_sintram_res.mig_pk);
                     END LOOP;
                  END IF;
               -- fin bug 0028909 - 09/12/2013 - JMF:

               -- tramitaciones destinatarios
               ELSIF x.tiporegistro = '55' THEN
                  -- bug 0028909 - 14/11/2013 - JMF: Validaciones
                  v_nnumerr := f_valida_reg55(x, v_tdeserror);

                  IF v_nnumerr <> 0 THEN
                     RAISE e_errdatos;
                  END IF;

                  INSERT INTO mig_cargas_tab_mig
                              (ncarga, tab_org, tab_des, ntab)
                       VALUES (v_ncarga, 'INT_CARGA_GENERICO', 'MIG_SIN_TRAMITA_DEST', 6);

                  v_mig_sintram_dest.ncarga := v_ncarga;
                  v_mig_sintram_dest.cestmig := 1;
                  v_mig_sintram_dest.mig_pk := v_mig_sin.mig_pk || '/' || x.campo01 || '/'
                                               || x.campo02 || '/' || x.campo03;
                  v_mig_sintram_dest.mig_fk := v_mig_sin.mig_pk || '/' || x.campo01;
                  v_mig_sintram_dest.nsinies := v_mig_sin.nsinies;
                  v_mig_sintram_dest.ntramit := x.campo01;
                  --     v_mig_sintram_dest.SPERSON  := 'XXX';
                  v_mig_sintram_dest.ctipdes := x.campo12;
                  v_mig_sintram_dest.ctipban := x.campo13;
                  v_mig_sintram_dest.cbancar := x.campo14;
                  v_mig_sintram_dest.cpagdes := 1;
                  v_mig_sintram_dest.cactpro := NULL;
                  v_mig_sintram_dest.pasigna := f_chartonumber(x.campo15);
                  v_mig_sintram_dest.cpaisre := x.campo16;
                  v_mig_sintram_dest.ctipcap := x.campo17;
                  v_mig_sintram_dest.crelase := x.campo18;
                  v_mig_sintram_dest.cusualt := f_user;
                  v_mig_sintram_dest.falta := f_sysdate;

                  -- tengo que crear el destinatario
                  BEGIN
                     --f_buscavalor('TIPO_IDENTIFICADOR_PERSONA', x.campo03);
                     SELECT per.sperson
                       INTO wspersonnueva
                       FROM per_personas per, per_detper pd
                      WHERE per.sperson = pd.sperson
                        AND per.ctipide = x.campo02
                        AND nnumide = x.campo03
                        AND nnumide <> 'Z'
                        AND pd.cagente = ff_agente_cpervisio(v_mig_seg.cagente)
                        AND NVL(tapelli1, '*') = NVL(x.campo06, '*')
                        AND NVL(tapelli2, '*') = NVL(x.campo07, '*')
                        AND NVL(tnombre1, '*') = NVL(x.campo08, '*')
                        AND NVL(tnombre2, '*') = NVL(x.campo09, '*')
                        AND(NVL(tapelli1, '*') = NVL(x.campo06, '*')
                            OR x.campo06 IS NULL)
                        AND(NVL(tapelli2, '*') = NVL(x.campo07, '*')
                            OR x.campo07 IS NULL)
                        AND(NVL(tnombre1, '*') = NVL(x.campo08, '*')
                            OR x.campo08 IS NULL)
                        AND(NVL(tnombre2, '*') = NVL(x.campo09, '*')
                            OR x.campo08 IS NULL)
                        AND ROWNUM = 1;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        wspersonnueva := NULL;
                     WHEN OTHERS THEN
                        p_tab_error(f_sysdate, f_user, 'pac_cargas_generico.destinatario()',
                                    3, 'Creando destinatario de pago de siniestro.',
                                    v_mig_seg.cagente || '-ctipide:' || x.campo02
                                    || '- nnumide:' || x.campo03 || '-->' || SQLCODE,
                                    10);
                  END;

                  IF wspersonnueva IS NULL THEN
                     v_ntraza := 6220;
                     v_ncarga2 := f_next_carga;
                     reg_migpersonas.ncarga := v_ncarga2;
                     -- I - JLB -
                     reg_migpersonas.proceso := x.proceso;
                     reg_migpersonas.ctipide := x.campo02;
                     -- f_buscavalor('TIPO_IDENTIFICADOR_PERSONA', x.campo04);
                     reg_migpersonas.nnumide := x.campo03;
                     reg_migpersonas.tdigitoide := x.campo04;
                     reg_migpersonas.mig_pk := v_ncarga2 || '/' || x.nlinea || '/'
                                               || reg_migpersonas.nnumide;
                     v_ntraza := 6230;
                     reg_migpersonas.cestmig := 1;
                     reg_migpersonas.idperson := 0;
                     reg_migpersonas.cpertip := f_buscavalor('TIPUS PERSONA', x.campo05);
                     reg_migpersonas.tapelli1 := x.campo06;
                     reg_migpersonas.tapelli2 := x.campo07;
                     reg_migpersonas.cagente := ff_agente_cpervisio(v_mig_seg.cagente);
                     reg_migpersonas.cidioma := k_cidioma;
                     reg_migpersonas.tnombre := x.campo08;
                     reg_migpersonas.tnombre2 := x.campo09;
                     v_ntraza := 6260;
                     reg_migpersonas.csexper := f_buscavalor('SEXO', x.campo10);
                     reg_migpersonas.swpubli := 0;
                     reg_migpersonas.fnacimi := f_chartodate(x.campo11);
                     reg_migpersonas.cestper := 0;
                     v_ntraza := 6270;

                     INSERT INTO mig_personas
                          VALUES reg_migpersonas
                       RETURNING ROWID
                            INTO v_rowid;

                     INSERT INTO mig_pk_emp_mig
                          VALUES (0, v_ncarga2, 1, reg_migpersonas.mig_pk);

                     INSERT INTO mig_cargas
                                 (ncarga, cempres, finiorg, ffinorg, ID, estorg)
                          VALUES (v_ncarga2, k_cempresa, f_sysdate, f_sysdate, v_id, NULL);

                     INSERT INTO mig_cargas_tab_mig
                                 (ncarga, tab_org, tab_des, ntab)
                          VALUES (v_ncarga2, 'INT_CARGA_GENERICO', 'MIG_PERSONAS', 1);

                     v_ntraza := 6280;
                     v_nnumerr := f_lanza_migracion_sin(v_id, v_ncarga2);

                     IF v_nnumerr NOT IN(0, 2, 4) THEN   -- si ha habido error
                        ROLLBACK;

                        IF k_cpara_error <> 1 THEN
                           v_ntipoerror := 4;
                        -- para que continue con la siguiente linea.
                        ELSE
                           v_ntipoerror := 1;   -- para la carga
                           RAISE e_salir;
                        END IF;
                     END IF;

                     BEGIN
                        SELECT idperson
                          INTO wspersonnueva
                          FROM mig_personas
                         WHERE ncarga = v_ncarga2;
                     EXCEPTION
                        WHEN OTHERS THEN
                           v_nnumerr := 9001557;
                           v_tdeserror := 'Error ' || SQLCODE
                                          || 'No se encuentra el beneficiasio creado. NIF: '
                                          || x.campo05;
                           RAISE e_errdatos;
                     END;
                  END IF;

                    --
                  --
                  v_mig_sintram_dest.sperson := wspersonnueva;

                  BEGIN
                     INSERT INTO mig_sin_tramita_dest
                          VALUES v_mig_sintram_dest
                       RETURNING ROWID
                            INTO v_rowid;

                     INSERT INTO mig_pk_emp_mig
                          VALUES (0, v_ncarga, 6, v_mig_sintram_dest.mig_pk);
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                        NULL;   -- si ya existe el destinatario para la tramitaci¿n no hace falta crearlo.
                  END;
-- Pagos de tramitaci¿n
               ELSIF x.tiporegistro = '56' THEN
                  -- bug 0028909 - 14/11/2013 - JMF: Validaciones
                  v_nnumerr := f_valida_reg56(x, v_tdeserror);

                  IF v_nnumerr <> 0 THEN
                     RAISE e_errdatos;
                  END IF;

                  INSERT INTO mig_cargas_tab_mig
                              (ncarga, tab_org, tab_des, ntab)
                       VALUES (v_ncarga, 'INT_CARGA_GENERICO', 'MIG_SIN_TRAMITA_PAGO', 7);

                  v_mig_sintram_pago.ncarga := v_ncarga;
                  v_mig_sintram_pago.cestmig := 1;
                  v_mig_sintram_pago.mig_pk := v_mig_sin.mig_pk || '/' || x.nlinea || '/'
                                               || x.campo01 || '/' || x.campo02 || '/'
                                               || x.campo03 || '/' || x.campo04;
                  v_mig_sintram_pago.mig_fk := v_mig_sin.mig_pk || '/' || x.campo01;
                  v_mig_sintram_pago.nsinies := v_mig_sin.nsinies;

                  --Buscar el destinatario del pago en los destinatarios a migrar
                  BEGIN
                     SELECT sperson
                       INTO wspersonnueva
                       FROM mig_sin_tramita_dest
                      WHERE ncarga = v_ncarga
                        AND nsinies = v_mig_sin.nsinies
                        AND ntramit = x.campo01
                        AND sperson = wspersonnueva
                        AND ctipdes = x.campo05;
                  EXCEPTION
                     WHEN OTHERS THEN
                        BEGIN
                           SELECT a.sperson
                             INTO wspersonnueva
                             FROM per_personas a
                            WHERE a.ctipide = x.campo03
                              AND a.nnumide = x.campo04;
                        EXCEPTION
                           WHEN NO_DATA_FOUND THEN
                              v_nnumerr := 109617;
                              v_tdeserror := 'Error ' || SQLCODE
                                             || 'No se encontr¿ la persona. Tipo.Id: '
                                             || x.campo03 || ' Num.Id:' || x.campo04;
                              RAISE e_errdatos;
                           WHEN TOO_MANY_ROWS THEN
                              v_nnumerr := 109617;
                              v_tdeserror :=
                                 'Error ' || SQLCODE
                                 || 'Existen varios registros para esta persona. Tipo.Id: '
                                 || x.campo03 || ' Num.Id:' || x.campo04;
                              RAISE e_errdatos;
                           WHEN OTHERS THEN
                              v_nnumerr := 109617;
                              v_tdeserror := 'Error ' || SQLCODE
                                             || 'No se encontr¿ la persona. Tipo.Id: '
                                             || x.campo03 || ' Num.Id:' || x.campo04;
                              RAISE e_errdatos;
                        END;
                  END;

                  v_mig_sintram_pago.mig_fk := '-1';
                  v_mig_sintram_pago.mig_fk2 := v_mig_sintram.mig_pk;
                  v_mig_sintram_pago.nsinies := v_mig_sin.nsinies;
                  v_mig_sintram_pago.ntramit := x.campo01;
                  v_mig_sintram_pago.sidepag := 0;   -- x.campo02;
                  v_mig_sintram_pago.sperson := wspersonnueva;
                  v_mig_sintram_pago.ctipdes := x.campo05;
                  v_mig_sintram_pago.ctippag := x.campo06;
                  v_mig_sintram_pago.cconpag := x.campo07;
                  v_mig_sintram_pago.ccauind := x.campo08;
                  v_mig_sintram_pago.cforpag := x.campo09;
                  v_mig_sintram_pago.fordpag := f_chartodate(x.campo10);
                  v_mig_sintram_pago.ctipban := x.campo11;
                  v_mig_sintram_pago.cbancar := x.campo12;
                  v_mig_sintram_pago.cmonres := x.campo13;
                  v_mig_sintram_pago.nfacref := x.campo14;
                  v_mig_sintram_pago.ffacref := f_chartodate(x.campo15);
                  v_mig_sintram_pago.ctransfer := x.campo16;
                  v_mig_sintram_pago.cultpag := x.campo17;
                  v_mig_sintram_pago.ctributa := x.campo18;
                  v_mig_sintram_pago.isinret := f_chartonumber(x.campo19);
                  v_mig_sintram_pago.iretenc := f_chartonumber(x.campo20);
                  v_mig_sintram_pago.iiva := f_chartonumber(x.campo21);
                  v_mig_sintram_pago.isuplid := f_chartonumber(x.campo22);
                  v_mig_sintram_pago.ifranq := f_chartonumber(x.campo23);
                  v_mig_sintram_pago.iresrcm := f_chartonumber(x.campo24);
                  v_mig_sintram_pago.iresred := f_chartonumber(x.campo25);
                  v_mig_sintram_pago.ireteiva := f_chartonumber(x.campo26);
                  v_mig_sintram_pago.ireteica := f_chartonumber(x.campo27);
                  v_mig_sintram_pago.iica := f_chartonumber(x.campo28);
                  v_mig_sintram_pago.cmonpag := x.campo29;
                  v_mig_sintram_pago.fcambio := f_chartodate(x.campo30);
                  v_mig_sintram_pago.isinretpag := f_chartonumber(x.campo31);
                  v_mig_sintram_pago.iretencpag := f_chartonumber(x.campo32);
                  v_mig_sintram_pago.iivapag := f_chartonumber(x.campo33);
                  v_mig_sintram_pago.isuplidpag := f_chartonumber(x.campo34);
                  v_mig_sintram_pago.ifranqpag := f_chartonumber(x.campo35);
                  v_mig_sintram_pago.iresrcmpag := f_chartonumber(x.campo36);
                  v_mig_sintram_pago.iresredpag := f_chartonumber(x.campo37);
                  v_mig_sintram_pago.ireteivapag := f_chartonumber(x.campo38);
                  v_mig_sintram_pago.ireteicapag := f_chartonumber(x.campo39);
                  v_mig_sintram_pago.iicapag := f_chartonumber(x.campo40);
                  v_mig_sintram_pago.sperson_presentador := x.campo41;
                  v_mig_sintram_pago.tobserva := x.campo42;
                  v_mig_sintram_pago.iotrosgas := f_chartonumber(x.campo43);
                  v_mig_sintram_pago.iotrosgaspag := f_chartonumber(x.campo44);
                  v_mig_sintram_pago.ibaseipoc := f_chartonumber(x.campo45);
                  v_mig_sintram_pago.ibaseipocpag := f_chartonumber(x.campo46);
                  v_mig_sintram_pago.iipoconsumo := f_chartonumber(x.campo47);
                  v_mig_sintram_pago.iipoconsumopag := f_chartonumber(x.campo48);
                  v_mig_sintram_pago.cusualt := f_user;
                  v_mig_sintram_pago.falta := f_sysdate;

                  INSERT INTO mig_sin_tramita_pago
                       VALUES v_mig_sintram_pago
                    RETURNING ROWID
                         INTO v_rowid;

                  INSERT INTO mig_pk_emp_mig
                       VALUES (0, v_ncarga, 7, v_mig_sintram_pago.mig_pk);
               -- Pagos por garantia de tramitaci¿n
               ELSIF x.tiporegistro = '57' THEN
                  -- bug 0028909 - 14/11/2013 - JMF: Validaciones
                  v_nnumerr := f_valida_reg57(x, v_tdeserror);

                  IF v_nnumerr <> 0 THEN
                     RAISE e_errdatos;
                  END IF;

                  INSERT INTO mig_cargas_tab_mig
                              (ncarga, tab_org, tab_des, ntab)
                       VALUES (v_ncarga, 'INT_CARGA_GENERICO', 'MIG_SIN_TRAMITA_PAGO_GAR', 8);

                  v_mig_sintram_pago_gar.ncarga := v_ncarga;
                  v_mig_sintram_pago_gar.cestmig := 1;
                  v_mig_sintram_pago_gar.mig_pk :=
                              v_mig_sintram_pago.mig_pk || '/' || x.campo03 || '/' || x.campo04;   -- Falta aclarar la llave
                  v_mig_sintram_pago_gar.mig_fk := v_mig_sintram_pago.mig_pk;   -- v
--                  v_mig_sintram_pago_gar.sidepag := v_mig_sintram_pago.sidepag;
                  --v_mig_sintram_pago_gar.NTRAMIT := x.campo01;-- Este campo no esta en la tabla de pagos
                  v_mig_sintram_pago_gar.sidepag := 0;
                  v_mig_sintram_pago_gar.norden := x.campo02;   -- FALTA validar logica para asignar este valor
                  v_mig_sintram_pago_gar.ctipres := x.campo03;
                  v_mig_sintram_pago_gar.nmovres := 0;   -- FALTA NO se sabe como se calcula
                  v_mig_sintram_pago_gar.cgarant := x.campo04;
                  v_mig_sintram_pago_gar.cmonres := x.campo05;
                  v_mig_sintram_pago_gar.isinret := f_chartonumber(x.campo06);
                  v_mig_sintram_pago_gar.iretenc := f_chartonumber(x.campo07);
                  v_mig_sintram_pago_gar.iiva := f_chartonumber(x.campo08);
                  v_mig_sintram_pago_gar.iica := f_chartonumber(x.campo09);
                  v_mig_sintram_pago_gar.isuplid := f_chartonumber(x.campo10);
                  v_mig_sintram_pago_gar.ifranq := f_chartonumber(x.campo11);
                  v_mig_sintram_pago_gar.iresrcm := f_chartonumber(x.campo12);
                  v_mig_sintram_pago_gar.iresred := f_chartonumber(x.campo13);
                  v_mig_sintram_pago_gar.ireteiva := f_chartonumber(x.campo14);
                  v_mig_sintram_pago_gar.ireteica := f_chartonumber(x.campo15);
                  v_mig_sintram_pago_gar.pretenc := f_chartonumber(x.campo16);
                  v_mig_sintram_pago_gar.piva := f_chartonumber(x.campo17);
                  v_mig_sintram_pago_gar.pica := f_chartonumber(x.campo18);
                  v_mig_sintram_pago_gar.preteiva := f_chartonumber(x.campo19);
                  v_mig_sintram_pago_gar.preteica := f_chartonumber(x.campo20);
                  v_mig_sintram_pago_gar.caplfra := x.campo21;
                  v_mig_sintram_pago_gar.cmonpag := x.campo22;
                  v_mig_sintram_pago_gar.fcambio := f_chartodate(x.campo23);
                  v_mig_sintram_pago_gar.isinretpag := f_chartonumber(x.campo24);
                  v_mig_sintram_pago_gar.iretencpag := f_chartonumber(x.campo25);
                  v_mig_sintram_pago_gar.iivapag := f_chartonumber(x.campo26);
                  v_mig_sintram_pago_gar.iicapag := f_chartonumber(x.campo27);
                  v_mig_sintram_pago_gar.isuplidpag := f_chartonumber(x.campo28);
                  v_mig_sintram_pago_gar.ifranqpag := f_chartonumber(x.campo29);
                  v_mig_sintram_pago_gar.iresrcmpag := f_chartonumber(x.campo30);
                  v_mig_sintram_pago_gar.iresredpag := f_chartonumber(x.campo31);
                  v_mig_sintram_pago_gar.ireteivapag := f_chartonumber(x.campo32);
                  v_mig_sintram_pago_gar.ireteicapag := f_chartonumber(x.campo33);
                  v_mig_sintram_pago_gar.crestareserva := x.campo34;
                  v_mig_sintram_pago_gar.iotrosgas := f_chartonumber(x.campo35);
                  v_mig_sintram_pago_gar.iotrosgaspag := f_chartonumber(x.campo36);
                  v_mig_sintram_pago_gar.ibaseipoc := f_chartonumber(x.campo37);
                  v_mig_sintram_pago_gar.ibaseipocpag := f_chartonumber(x.campo38);
                  v_mig_sintram_pago_gar.pipoconsumo := f_chartonumber(x.campo39);
                  v_mig_sintram_pago_gar.iipoconsumo := f_chartonumber(x.campo40);
                  v_mig_sintram_pago_gar.iipoconsumopag := f_chartonumber(x.campo41);
                  v_mig_sintram_pago_gar.cusualt := f_user;
                  v_mig_sintram_pago_gar.falta := f_sysdate;

                  INSERT INTO mig_sin_tramita_pago_gar
                       VALUES v_mig_sintram_pago_gar
                    RETURNING ROWID
                         INTO v_rowid;

                  INSERT INTO mig_pk_emp_mig
                       VALUES (0, v_ncarga, 8, v_mig_sintram_pago_gar.mig_pk);
               -- Movimientos del pago por tramitaci¿n
               ELSIF x.tiporegistro = '58' THEN
                  -- bug 0028909 - 14/11/2013 - JMF: Validaciones
                  v_nnumerr := f_valida_reg58(x, v_tdeserror);

                  IF v_nnumerr <> 0 THEN
                     RAISE e_errdatos;
                  END IF;

                  INSERT INTO mig_cargas_tab_mig
                              (ncarga, tab_org, tab_des, ntab)
                       VALUES (v_ncarga, 'INT_CARGA_GENERICO', 'MIG_SIN_TRAMITA_MOVPAGO', 9);

                  v_mig_sintram_movpago.ncarga := v_ncarga;
                  v_mig_sintram_movpago.cestmig := 1;
                  v_mig_sintram_movpago.mig_pk := v_mig_sintram_pago.mig_pk || '/' || x.campo03;
                  v_mig_sintram_movpago.mig_fk := v_mig_sintram_pago.mig_pk;
                  v_mig_sintram_movpago.sidepag := 0;
                  v_mig_sintram_movpago.nmovpag := x.campo03;
                  v_mig_sintram_movpago.cestpag := x.campo04;
                  v_mig_sintram_movpago.fefepag := f_chartodate(x.campo05);
                  v_mig_sintram_movpago.cestval := x.campo06;
                  v_mig_sintram_movpago.csubpag := x.campo07;
                  v_mig_sintram_movpago.cusualt := f_user;
                  v_mig_sintram_movpago.falta := f_sysdate;

                  INSERT INTO mig_sin_tramita_movpago
                       VALUES v_mig_sintram_movpago
                    RETURNING ROWID
                         INTO v_rowid;

                  INSERT INTO mig_pk_emp_mig
                       VALUES (0, v_ncarga, 9, v_mig_sintram_movpago.mig_pk);
-- registro de siniestro_referencias
               ELSIF x.tiporegistro = '59' THEN
                  -- bug 0028909 - 14/11/2013 - JMF: Validaciones
                  v_nnumerr := f_valida_reg59(x, v_tdeserror);

                  IF v_nnumerr <> 0 THEN
                     RAISE e_errdatos;
                  END IF;

                  INSERT INTO mig_cargas_tab_mig
                              (ncarga, tab_org,
                               tab_des, ntab)
                       VALUES (v_ncarga, 'INT_CARGA_GENERICO',
                               'MIG_SIN_SINIESTRO_REFERENCIAS', 4);

                  v_mig_sinreferencias.ncarga := v_ncarga;
                  v_mig_sinreferencias.cestmig := 1;
                  v_mig_sinreferencias.mig_pk := v_mig_sin.mig_pk || '/' || x.campo01 || '/'
                                                 || x.campo02;
                  v_mig_sinreferencias.mig_fk := v_mig_sin.mig_pk;
                  v_mig_sinreferencias.nsinies := v_mig_sin.nsinies;
                  v_mig_sinreferencias.ctipref := x.campo01;
                  v_mig_sinreferencias.trefext := x.campo02;
                  v_mig_sinreferencias.frefini := f_chartodate(x.campo03);
                  v_mig_sinreferencias.freffin := f_chartodate(x.campo04);
                  v_mig_sinreferencias.cusualt := f_user;
                  v_mig_sinreferencias.falta := f_sysdate;

                  INSERT INTO mig_sin_siniestro_referencias
                       VALUES v_mig_sinreferencias
                    RETURNING ROWID
                         INTO v_rowid;

                  INSERT INTO mig_pk_emp_mig
                       VALUES (0, v_ncarga, 4, v_mig_sinreferencias.mig_pk);
               -- registro de personas relacionadas
               ELSIF x.tiporegistro = '60' THEN
                  -- bug 0028909 - 14/11/2013 - JMF: Validaciones
                  v_nnumerr := f_valida_reg60(x, v_tdeserror);

                  IF v_nnumerr <> 0 THEN
                     RAISE e_errdatos;
                  END IF;

                  INSERT INTO mig_cargas_tab_mig
                              (ncarga, tab_org, tab_des, ntab)
                       VALUES (v_ncarga, 'INT_CARGA_GENERICO', 'MIG_SIN_TRAMITA_PERSONASREL', 6);

                  v_mig_sintram_personasrel.ncarga := v_ncarga;
                  v_mig_sintram_personasrel.cestmig := 1;
                  v_mig_sintram_personasrel.mig_pk :=
                     v_mig_sin.mig_pk || '/' || x.campo01 || '/' || x.campo02 || '/'
                     || x.campo03;
                  v_mig_sintram_personasrel.mig_fk := v_mig_sin.mig_pk || '/' || x.campo01;
                  v_mig_sintram_personasrel.nsinies := v_mig_sin.nsinies;
                  v_mig_sintram_personasrel.ntramit := x.campo01;
                  --     v_mig_sintram_dest.SPERSON  := 'XXX';
                  v_mig_sintram_personasrel.ctipide := x.campo02;
                  v_mig_sintram_personasrel.nnumide := x.campo03;
                  v_mig_sintram_personasrel.tapelli1 := x.campo04;
                  v_mig_sintram_personasrel.tapelli2 := x.campo05;
                  v_mig_sintram_personasrel.tnombre := x.campo06;
                  v_mig_sintram_personasrel.tnombre2 := x.campo07;
                  v_mig_sintram_personasrel.ttelefon := x.campo08;
                  v_mig_sintram_personasrel.temail := x.campo09;
                  v_mig_sintram_personasrel.tmovil := x.campo10;
                  v_mig_sintram_personasrel.tdesc := x.campo11;
                  v_mig_sintram_personasrel.ctiprel := x.campo12;

                  -- miro si ya existe la persona en base de datos
                  BEGIN
                     SELECT per.sperson
                       INTO v_mig_sintram_personasrel.sperson
                       FROM per_personas per, per_detper pd
                      WHERE per.sperson = pd.sperson
                        AND per.ctipide = x.campo02
                        AND nnumide = x.campo03
                        AND nnumide <> 'Z'
                        AND pd.cagente = ff_agente_cpervisio(v_mig_seg.cagente)
                        AND NVL(tapelli1, '*') = NVL(x.campo04, '*')
                        AND NVL(tapelli2, '*') = NVL(x.campo05, '*')
                        AND NVL(tnombre1, '*') = NVL(x.campo06, '*')
                        AND NVL(tnombre2, '*') = NVL(x.campo07, '*')
                        AND ROWNUM = 1;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        NULL;
                     WHEN OTHERS THEN
                        NULL;   --no deberia entrar por aqui nunca
                  END;

                  INSERT INTO mig_sin_tramita_personasrel
                       VALUES v_mig_sintram_personasrel
                    RETURNING ROWID
                         INTO v_rowid;

                  INSERT INTO mig_pk_emp_mig
                       VALUES (0, v_ncarga, 6, v_mig_sintram_personasrel.mig_pk);
               ELSE
                  -- no se encuentra el tipo de registro
                  v_nnumerr := 9902907;
                  v_tdeserror := 'El tipo registro (campo01): ' || x.tiporegistro || ' '
                                 || 'no parametrizado.';
                  v_nnumerr1 := p_marcalinea(p_ssproces, x.nlinea, 'SIN', 1, 0, NULL, v_id,
                                             v_ncarga, NULL, NULL, NULL, NULL,
                                             x.nlinea || '(' || x.tiporegistro || ')');
                  v_nnumerr := p_marcalineaerror(p_ssproces, x.nlinea, NULL, 1,
                                                 NVL(v_nnumerr, 1), NVL(v_tdeserror, -1));
                  RAISE e_errdatos;
               END IF;
            ELSE
               NULL;   -- salto el registro porque viene de un error
            END IF;   -- v_toperacion

            v_ntraza := 9090;
         EXCEPTION
            WHEN e_errdatos THEN
               ROLLBACK;
               v_berrorproc := TRUE;
               v_berrorlin := TRUE;
               v_nnumerr1 := p_marcalinea(p_ssproces, x.nlinea, 'SIN', 1, 0, NULL, v_id,
                                          v_ncarga, NULL, NULL, NULL, NULL,
                                          x.nlinea || '(' || x.tiporegistro || ')');
               v_nnumerr := p_marcalineaerror(p_ssproces, x.nlinea, NULL, 1,
                                              NVL(v_nnumerr, 1), NVL(v_tdeserror, -1));

               IF k_cpara_error <> 1 THEN
                  v_ntipoerror := 4;
               -- para que continue con la siguiente linea.
               ELSE
                  v_ntipoerror := 1;   -- para la carga
                  RAISE e_salir;
               END IF;
            -- debo obviar todas las lineas hasta la siguiente linea 1
            WHEN e_salir THEN   -- salgo del cursor
               RAISE;
            WHEN OTHERS THEN
               v_nnumerr := SQLCODE;
               v_tdeserror := SQLERRM;
               ROLLBACK;
               v_berrorproc := TRUE;
               v_berrorlin := TRUE;
               v_nnumerr := f_marcar_lineas(p_ssproces, v_ncarga, 1,   -- pongo error
                                            v_toperacion, v_nnumerr, v_tdeserror, NULL,
                                            x.nlinea, NULL, NULL, NULL);

               IF k_cpara_error <> 1 THEN
                  v_ntipoerror := 4;
               -- para que continue con la siguiente linea.
               ELSE
                  v_ntipoerror := 1;   -- para la carga
                  RAISE e_salir;
               END IF;
         END;
      END LOOP;

      v_ntraza := 9500;

      IF v_id IS NOT NULL
         AND v_mig_sin.ncarga IS NOT NULL
         AND v_ntipoerror NOT IN(1, 4) THEN
         -- lanza la ultima migraci¿n, cuando acaba el fichero
         IF v_toperacion = 'SIN' THEN
            v_nnumerr := f_lanza_migracion_sin(v_id, v_ncarga);
         ELSIF v_toperacion = 'SINM' THEN   -- ejecuto el suplemento
            NULL;
         END IF;

         IF v_nnumerr NOT IN(0, 2, 4) THEN   -- si ha habido error
            v_berrorlin := TRUE;
            v_berrorproc := TRUE;
            ROLLBACK;
         ELSE
            COMMIT;
         END IF;
      END IF;

      v_ntraza := 9000;

      --
      IF v_id_linea_1 IS NOT NULL THEN
         IF v_berrorlin THEN
            v_nnumerr := p_marcalinea(p_ssproces, v_id_linea_1, 'SIN', 1, 0, v_sseguro, v_id,
                                      v_ncarga, NULL, NULL, NULL, NULL,
                                      v_id_linea_1 || '(' || 1 || ')');
         ELSE
            v_nnumerr := p_marcalinea(p_ssproces, v_id_linea_1, 'SIN', 4, 1, v_sseguro, v_id,
                                      v_ncarga, NULL, NULL, NULL, NULL,
                                      v_id_linea_1 || '(' || 1 || ')');
         END IF;
      END IF;

      v_ntraza := 9999;

-------------------------------- final loop ------------------------------------
-- COMMIT;
      IF v_berrorproc THEN
         RETURN 1;
      ELSIF v_bavisproc THEN
         RETURN 2;
      ELSE
         RETURN 4;
      END IF;
   EXCEPTION
      WHEN e_salir THEN
         ROLLBACK;
         RETURN 1;
      -- Fi Bug 16324
      WHEN OTHERS THEN
         v_nnumerr := SQLCODE;
         v_tdeserror := SQLCODE || ' ' || SQLERRM;
         ROLLBACK;
         v_nnumerr1 := p_marcalinea(p_ssproces, v_id_linea, 'SIN', 1, 0, NULL, v_id, v_ncarga);
         v_nnumerr := p_marcalineaerror(p_ssproces, v_id_linea, NULL, 1, v_nnumerr,
                                        v_tdeserror);
         p_genera_logs(v_tobjeto, v_ntraza, 'Error Incontrolado:' || v_nnumerr, v_tdeserror);
         RETURN 1;
   END f_sin_ejecutar_carga_proceso;

-- Carga de personas
   /*************************************************************************
       Procedimiento que ejecuta  carga de personas.
       param in p_ssproces   : N¿mero proceso
       retorna 0 si ha ido bien, 1 en casos contrario
   *************************************************************************/
   FUNCTION f_per_ejecutar_carga_proceso(p_ssproces IN NUMBER)
      RETURN NUMBER IS
      v_tobjeto      VARCHAR2(100) := 'pac_cargas_generico.f_per_ejecutar_carga_proceso';
      v_ntraza       NUMBER := 0;
      e_salir        EXCEPTION;

      CURSOR cur_personas(p_ssproces2 IN NUMBER) IS
         -- Abrimos los certificados como control, despu¿s buscamos todos los registros del fichero.
         SELECT   a.*
             FROM int_carga_generico a
            WHERE proceso = p_ssproces2
              AND NOT EXISTS(SELECT 1
                               FROM int_carga_ctrl_linea b
                              WHERE b.sproces = a.proceso
                                AND b.nlinea = a.nlinea
                                AND b.cestado IN(2, 4, 5, 6))
         ORDER BY nlinea, tiporegistro;   -- registro tipo certificado

      v_toperacion   VARCHAR2(20);
      v_berrorproc   BOOLEAN := FALSE;
      v_berrorlin    BOOLEAN := FALSE;
      v_bavisproc    BOOLEAN := FALSE;
      v_ncarga       int_carga_generico.ncarga%TYPE;
      v_ntipoerror   NUMBER := 0;
      --  v_nnumerrset   number;
      v_tfichero     int_carga_ctrl.tfichero%TYPE;
      --Tablas nivel p¿liza
      reg_migpersonas mig_personas%ROWTYPE;
      reg_migregimenfiscal mig_regimenfiscal%ROWTYPE;
      reg_migdirec   mig_direcciones%ROWTYPE;
      --
      v_rowid        ROWID;
      v_id           mig_cargas.ID%TYPE;
      v_id_linea     int_carga_generico.nlinea%TYPE;
      v_id_linea_1   NUMBER;
      --
      v_sproces      NUMBER;

      /***************************************************************************
       FUNCTION f_lanza_migracion
           Asigna n¿mero de carga
           Return: N¿mero de carga
       ***************************************************************************/
      FUNCTION f_lanza_migracion_per(p_id IN VARCHAR2, p_ncarga IN NUMBER)
         RETURN NUMBER IS
         v_ntiperr      NUMBER := 0;
         v_sperson      per_personas.sperson%TYPE;
      BEGIN
         pac_mig_axis.p_migra_cargas(p_id, 'C', p_ncarga, 'DEL', k_tablas, 'PERSONAS');

         --Cargamos las SEG para la p¿liza (ncarga)
         FOR reg IN (SELECT *
                       FROM mig_logs_axis
                      WHERE ncarga = p_ncarga
                        AND tipo = 'E') LOOP
            --Miramos si ha habido alg¿n error y lo informamos.
            v_ntraza := 200;
            v_nnumerr := f_marcar_lineas(p_ssproces, p_ncarga, 1,   -- pongo errr todas las lineas
                                         v_toperacion, 151840, reg.incid, NULL, NULL, NULL,
                                         NULL, NULL);
            v_berrorproc := TRUE;
            v_ntiperr := 1;
         END LOOP;

         IF v_ntiperr = 0 THEN
            FOR reg IN (SELECT *
                          FROM mig_logs_axis
                         WHERE ncarga = p_ncarga
                           AND tipo = 'W') LOOP   --Miramos si han habido warnings.
               v_ntraza := 202;

               BEGIN
                  SELECT idperson
                    INTO v_sperson
                    FROM mig_personas
                   WHERE ncarga = p_ncarga;
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;   --JRH IMP de momento
               END;

               v_nnumerr := f_marcar_lineas(p_ssproces, p_ncarga, 2,   -- pongo errr todas las lineas
                                            v_toperacion, 700145, reg.incid, NULL, NULL, NULL,
                                            NULL, v_sperson);
               v_bavisproc := TRUE;
               v_ntiperr := 2;
            END LOOP;
         END IF;

         IF v_ntiperr = 0 THEN
            --Esto quiere decir que no ha habido ning¿n error (lo indicamos tambi¿n).
            v_ntraza := 204;

            BEGIN
               SELECT idperson
                 INTO v_sperson
                 FROM mig_personas
                WHERE ncarga = p_ncarga;
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;   --JRH IMP de momento
            END;

            FOR c_lin IN (SELECT nlinea, idint, tipoper
                            FROM int_carga_ctrl_linea
                           WHERE sproces = p_ssproces
                             AND ncarga = p_ncarga) LOOP
               v_nnumerr := p_marcalinea(p_ssproces, c_lin.nlinea, c_lin.tipoper, 4, 1, NULL,
                                         p_id, p_ncarga, NULL, NULL, v_sperson, NULL,
                                         c_lin.idint);

               IF v_nnumerr <> 0 THEN
                  --Si fallan estas funciones de gesti¿n salimos del programa
                  v_tdeserror := 'Falta marcar linea 4: ' || p_ssproces || '/' || p_id;
                  RAISE e_errdatos;
               END IF;
            END LOOP;

            v_ntiperr := 4;
         END IF;

         -- Lanzo validaciones  si ha la poliza esta migrada
         RETURN v_ntiperr;   --Devolvemos el tipo error que ha habido
      EXCEPTION
         WHEN e_errdatos THEN
            ROLLBACK;
            v_nnumerr := f_marcar_lineas(p_ssproces, p_ncarga, 2,   -- pongo errr todas las lineas
                                         v_toperacion, NVL(v_nnumerr, 1), NVL(v_tdeserror, -1),
                                         NULL, NULL, NULL, NULL, v_sperson);
            RETURN v_nnumerr;
         WHEN OTHERS THEN
            v_nnumerr := SQLCODE;
            v_tdeserror := v_ntraza || ' en f_lanza_migracion_per: ' || SQLERRM;
            ROLLBACK;
            v_nnumerr1 := p_marcalinea(p_ssproces, v_id_linea, v_toperacion, 1, 0, NULL, p_id,
                                       p_ncarga);
            v_nnumerr := p_marcalineaerror(p_ssproces, v_id_linea, NULL, 1, v_nnumerr,
                                           v_tdeserror);
            RETURN SQLCODE;
      END f_lanza_migracion_per;
   BEGIN
      v_ntraza := 0;

      IF p_ssproces IS NULL THEN
         v_nnumerr := 9000505;
         v_tdeserror := 'Par¿metro p_ssproces obligatorio.';
         p_genera_logs(v_tobjeto, v_ntraza, 'Error:' || v_nnumerr, v_tdeserror);
         RAISE e_salir;
      END IF;

      v_ntraza := 1;
      v_ntraza := 1;
      v_toperacion := 'PER';
      v_ncarga := NULL;
      v_id_linea_1 := NULL;

      FOR x IN cur_personas(p_ssproces) LOOP
         BEGIN
            --Leemos los registros de la tabla int no procesados OK
            v_ntraza := 3;

            --Leemos los registros de la tabla int no procesados OK
            IF x.tiporegistro = '70' THEN   -- si cambio de bloque de registros de recibos
               IF v_id IS NOT NULL
                  AND reg_migpersonas.ncarga IS NOT NULL
                  AND v_ntipoerror NOT IN(1, 4) THEN
                  v_nnumerr := f_lanza_migracion_per(v_id, v_ncarga);

                  IF v_nnumerr NOT IN(0, 2, 4) THEN   -- si ha habido error
                     v_berrorlin := TRUE;
                     v_berrorproc := TRUE;
                     ROLLBACK;

                     IF k_cpara_error <> 1 THEN
                        v_ntipoerror := 4;
                     -- para que continue con la siguiente linea.
                     ELSE
                        v_ntipoerror := 1;   -- para la carga
                        RAISE e_salir;
                     END IF;
                  ELSE
                     COMMIT;
                  END IF;
               END IF;

               IF v_id_linea_1 IS NOT NULL
                  AND x.tiporegistro = '70' THEN
                  IF v_berrorlin THEN
                     v_nnumerr := p_marcalinea(x.proceso, v_id_linea_1, 'PER', 1, 0, NULL,
                                               v_id, v_ncarga, NULL, NULL, NULL, NULL,
                                               v_id_linea_1 || '(' || x.tiporegistro || ')');
                  ELSE
                     v_nnumerr := p_marcalinea(x.proceso, v_id_linea_1, 'PER', 4, 1, NULL,
                                               v_id, v_ncarga, NULL, NULL, NULL, NULL,
                                               v_id_linea_1 || '(' || x.tiporegistro || ')');
                  END IF;

                  v_id_linea_1 := NULL;
               END IF;

               v_ncarga := f_next_carga;
               v_id := TRIM(x.campo02) || '-' || x.campo03;
               v_nnumerr := p_marcalinea(x.proceso, x.nlinea, 'PER', 3, 0, NULL,
                                         TRIM(x.campo02) || '-' || x.campo03, v_ncarga, NULL,
                                         NULL, NULL, NULL,
                                         x.nlinea || '(' || x.tiporegistro || ')');

               INSERT INTO mig_cargas
                           (ncarga, cempres, finiorg, ffinorg, ID, estorg)
                    VALUES (v_ncarga, k_cempresa, f_sysdate, f_sysdate, v_id, NULL);

               reg_migpersonas := NULL;
               reg_migregimenfiscal := NULL;
               reg_migdirec := NULL;
               v_ntipoerror := 0;
            ELSIF x.tiporegistro IN('71A', '71B', '71C') THEN
               v_nnumerr := p_marcalinea(x.proceso, x.nlinea, 'PERD', 3, 0, NULL, v_id,
                                         v_ncarga, NULL, NULL, NULL, NULL,
                                         x.nlinea || '(' || x.tiporegistro || ')');
            END IF;

            IF v_ntipoerror NOT IN(1, 4) THEN
               v_ntraza := 70010;

               -- RESTISTRO 1
               IF x.tiporegistro = '70' THEN   -- personas
                  v_id := TRIM(x.campo02) || '-' || x.campo03;
                  v_id_linea_1 := x.nlinea;
                  reg_migpersonas := NULL;
                  v_ntraza := 70010;

                  INSERT INTO mig_cargas_tab_mig
                              (ncarga, tab_org, tab_des, ntab)
                       VALUES (v_ncarga, 'INT_CARGA_GENERICO', 'MIG_PERSONAS', 1);

                  reg_migpersonas.ncarga := v_ncarga;
                  reg_migpersonas.proceso := x.proceso;

                  IF x.campo02 IS NULL
                     OR x.campo03 IS NULL THEN
                     v_tdeserror := 'Se debe informar el tipo y documento de documento.';
                     RAISE e_errdatos;
                  END IF;

                  reg_migpersonas.cagente := ff_agente_cpervisio(x.campo01);
                  reg_migpersonas.ctipide := x.campo02;
                  reg_migpersonas.nnumide := x.campo03;
                  reg_migpersonas.tdigitoide := x.campo04;
                  --  reg_migpersonas.mig_pk := v_ncarga || '/' || x.nlinea || '/'
                  --                            || reg_migpersonas.nnumide;
                  reg_migpersonas.mig_pk := v_ncarga || '/' || reg_migpersonas.ctipide || '/'
                                            || reg_migpersonas.nnumide;
                  v_ntraza := 3030;
                  reg_migpersonas.cestmig := 1;
                  reg_migpersonas.idperson := 0;

                  IF x.campo05 = ''
                     OR x.campo05 IS NULL THEN
                     v_tdeserror := 'Se debe informar el tipo de persona.';
                     RAISE e_errdatos;
                  END IF;

                  reg_migpersonas.cpertip := f_buscavalor('TIPUS PERSONA', x.campo05);

                  IF x.campo06 = ''
                     OR x.campo06 IS NULL THEN
                     v_tdeserror := 'Se debe informar el apellido 1.';
                     RAISE e_errdatos;
                  END IF;

                  reg_migpersonas.tapelli1 := x.campo06;
                  reg_migpersonas.tapelli2 := x.campo07;
                  reg_migpersonas.cidioma := k_cidioma;
                  reg_migpersonas.tnombre := x.campo08;
                  reg_migpersonas.tnombre2 := x.campo09;
                  v_ntraza := 3060;
                  reg_migpersonas.csexper := f_buscavalor('SEXO', x.campo10);

                  IF reg_migpersonas.cpertip = 1
                     AND reg_migpersonas.csexper IS NULL THEN
                     v_tdeserror := 'Si es persona natural se debe informar su sexo.';
                     RAISE e_errdatos;
                  END IF;

                  reg_migpersonas.swpubli := 0;
                  reg_migpersonas.fnacimi := f_chartodate(x.campo11);

                  IF reg_migpersonas.cpertip = 1
                     AND reg_migpersonas.fnacimi IS NULL THEN
                     v_tdeserror :=
                           'Si es persona es natural se debe informar su fecha de nacimiento.';
                     v_nnumerr := 1000401;
                     RAISE e_errdatos;
                  END IF;

                  IF reg_migpersonas.fnacimi IS NOT NULL
                     AND TRUNC(reg_migpersonas.fnacimi) > TRUNC(f_sysdate) THEN
                     v_tdeserror :=
                        'La fecha de nacimiento de la persona no puede ser superior a la fecha de hoy.';
                     RAISE e_errdatos;
                  END IF;

                  reg_migpersonas.cnacio := x.campo12;
                  reg_migpersonas.cestciv := x.campo13;
                  reg_migpersonas.tnumtel := x.campo14;
                  reg_migpersonas.tnummov := x.campo15;
                  reg_migpersonas.temail := x.campo16;
                  reg_migpersonas.tnumfax := x.campo17;
                  v_ntraza := 70070;
                  reg_migpersonas.ctipban := x.campo19;
                  reg_migpersonas.cbancar := x.campo20;
                  reg_migpersonas.snip := x.campo21;
                  reg_migpersonas.cestper := NVL(x.campo22, 0);
                  reg_migpersonas.cprofes := x.campo23;
                  reg_migpersonas.cocupacion := x.campo24;
                  reg_migpersonas.cpais := NVL(x.campo25, reg_migpersonas.cnacio);
                  -- pais de residencia = a nacionalidad
                  reg_migpersonas.fjubila := f_chartodate(x.campo26);
                  reg_migpersonas.fdefunc := f_chartodate(x.campo27);

                  BEGIN
                     INSERT INTO mig_personas
                          VALUES reg_migpersonas
                       RETURNING ROWID
                            INTO v_rowid;

                     v_ntraza := 70080;

                     INSERT INTO mig_pk_emp_mig
                          VALUES (0, v_ncarga, 3, reg_migpersonas.mig_pk);
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN   -- puede ser que la persona haya llegado como otro figura
                        NULL;
                  END;

                  --

                  -- miro si me llega informado el regimen fiscal
                  IF x.campo18 IS NOT NULL THEN
                     v_ntraza := 70100;

                     INSERT INTO mig_cargas_tab_mig
                                 (ncarga, tab_org, tab_des, ntab)
                          VALUES (v_ncarga, 'INT_CARGA_GENERICO', 'MIG_REGIMENFISCAL', 1);

                     v_ntraza := 70110;
                     reg_migregimenfiscal := NULL;
                     reg_migregimenfiscal.ncarga := v_ncarga;
                     reg_migregimenfiscal.cestmig := 1;
                     reg_migregimenfiscal.mig_pk :=
                                  v_ncarga || '/' || x.nlinea || '/' || reg_migpersonas.nnumide;
                     reg_migregimenfiscal.mig_fk := reg_migpersonas.mig_pk;
                     reg_migregimenfiscal.nanuali := TO_CHAR(f_sysdate, 'YYYY');
                     reg_migregimenfiscal.fefecto := TRUNC(f_sysdate);
                     reg_migregimenfiscal.cregfis := x.campo18;

                     BEGIN
                        INSERT INTO mig_regimenfiscal
                             VALUES reg_migregimenfiscal
                          RETURNING ROWID
                               INTO v_rowid;

                        v_ntraza := 70080;

                        INSERT INTO mig_pk_emp_mig
                             VALUES (0, v_ncarga, 70, reg_migregimenfiscal.mig_pk);
                     EXCEPTION
                        WHEN DUP_VAL_ON_INDEX THEN   -- puede ser que la persona haya llegado como otro figura
                           NULL;
                     END;
                  END IF;
               ELSIF x.tiporegistro = '71A' THEN   --  direccion tomadores Chile
                  reg_migdirec := NULL;
                  v_ntraza := 71010;

                  INSERT INTO mig_cargas_tab_mig
                              (ncarga, tab_org, tab_des, ntab)
                       VALUES (v_ncarga, 'INT_CARGA_GENERICO', 'MIG_DIRECCIONES', 1);

                  v_ntraza := 71020;
                  reg_migdirec.ncarga := v_ncarga;
                  -- I - JLB -
                  reg_migdirec.proceso := x.proceso;
                  reg_migdirec.mig_pk := v_ncarga || '/' || reg_migpersonas.mig_pk || '/'
                                         || x.nlinea || '/' || x.campo01;
                  v_ntraza := 71030;
                  reg_migdirec.cestmig := 1;
                  reg_migdirec.sperson := 0;
                  reg_migdirec.mig_fk := reg_migpersonas.mig_pk;
                  reg_migdirec.cagente := reg_migpersonas.cagente;
                  reg_migdirec.cdomici := x.campo01;
                  reg_migdirec.ctipdir := x.campo02;
                  reg_migdirec.csiglas := x.campo03;
                  reg_migdirec.tnomvia := SUBSTR(x.campo04, 1, 200);
                  v_ntraza := 71040;
                  reg_migdirec.tnum1ia := x.campo05;
                  reg_migdirec.tnum2ia := x.campo06;
                  reg_migdirec.tnum3ia := x.campo07;
                  reg_migdirec.cpoblac := x.campo08;
                  v_ntraza := 71050;
                  reg_migdirec.localidad := x.campo09;
                  reg_migdirec.cprovin := x.campo10;
                  v_ntraza := 71060;

                  IF LENGTH(x.campo04) > 200
                     AND reg_migdirec.tnum1ia IS NULL THEN
                     reg_migdirec.tnum1ia := SUBSTR(x.campo05, 201, 100);
                  END IF;

                  v_ntraza := 71080;

                  --   reg_migdirec.cpostal := x.campo12;
                  BEGIN
                     INSERT INTO mig_direcciones
                          VALUES reg_migdirec
                       RETURNING ROWID
                            INTO v_rowid;

                     INSERT INTO mig_pk_emp_mig
                          VALUES (0, v_ncarga, 71, reg_migdirec.mig_pk);
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN   -- puede ser que la persona haya llegado como otro figura
                        NULL;
                  END;
               ELSIF x.tiporegistro = '71B' THEN   --  direccion tomadores Colombia
                  reg_migdirec := NULL;
                  v_ntraza := 71200;

                  INSERT INTO mig_cargas_tab_mig
                              (ncarga, tab_org, tab_des, ntab)
                       VALUES (v_ncarga, 'INT_CARGA_GENERICO', 'MIG_DIRECCIONES', 1);

                  reg_migdirec.ncarga := v_ncarga;
                  reg_migdirec.proceso := x.proceso;
                  v_ntraza := 71210;
                  reg_migdirec.mig_pk := v_ncarga || '/' || reg_migpersonas.mig_pk || '/'
                                         || x.nlinea || '/' || x.campo02;
                  reg_migdirec.cestmig := 1;
                  reg_migdirec.sperson := 0;
                  v_ntraza := 71220;
                  reg_migdirec.mig_fk := reg_migpersonas.mig_pk;
                  reg_migdirec.cagente := reg_migpersonas.cagente;
                  reg_migdirec.cdomici := x.campo01;
                  reg_migdirec.cpostal := x.campo19;
                  reg_migdirec.cpoblac := x.campo20;
                  v_ntraza := 71230;
                  reg_migdirec.cprovin := x.campo21;
                  reg_migdirec.csiglas := NULL;
                  reg_migdirec.tnomvia := NULL;
                  reg_migdirec.nnumvia := x.campo04;
                  reg_migdirec.tcomple := NULL;
                  v_ntraza := 71240;
                  reg_migdirec.ctipdir := x.campo02;
                  reg_migdirec.cviavp := x.campo03;
                  reg_migdirec.clitvp := x.campo05;
                  reg_migdirec.cbisvp := x.campo06;
                  reg_migdirec.corvp := x.campo07;
                  v_ntraza := 71250;
                  reg_migdirec.nviaadco := x.campo08;
                  reg_migdirec.clitco := x.campo09;
                  reg_migdirec.corco := x.campo10;
                  reg_migdirec.nplacaco := x.campo11;
                  v_ntraza := 71260;
                  reg_migdirec.cor2co := x.campo12;
                  reg_migdirec.cdet1ia := x.campo13;
                  reg_migdirec.tnum1ia := x.campo14;
                  reg_migdirec.cdet2ia := x.campo15;
                  v_ntraza := 71270;
                  reg_migdirec.tnum2ia := x.campo16;
                  reg_migdirec.cdet3ia := x.campo17;
                  reg_migdirec.tnum3ia := x.campo18;
                  v_ntraza := 71280;

                  BEGIN
                     INSERT INTO mig_direcciones
                          VALUES reg_migdirec
                       RETURNING ROWID
                            INTO v_rowid;

                     INSERT INTO mig_pk_emp_mig
                          VALUES (0, v_ncarga, 71, reg_migdirec.mig_pk);
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN   -- puede ser que la persona haya llegado como otro figura
                        NULL;
                  END;
               ELSE
                  -- no se encuentra el tipo de registro
                  v_nnumerr := 9902907;
                  v_tdeserror := 'El tipo resgistro (campo01): ' || x.tiporegistro || ' '
                                 || 'no parametrizado.';
                  v_nnumerr1 := p_marcalinea(p_ssproces, v_id_linea, v_toperacion, 1, 0, NULL,
                                             v_id, v_ncarga);
                  v_nnumerr := p_marcalineaerror(p_ssproces, v_id_linea, NULL, 1,
                                                 NVL(v_nnumerr, 1), NVL(v_tdeserror, -1));
                  RAISE e_salir;
               END IF;
            ELSE
                --NULL;   -- la dejo como pendiente, viene con de un error
               -- Si llega un registro que no tiene cabecera lo marcamos como warning
               IF v_id IS NULL THEN   -- sino pertenece a ninguna p¿liza
                  v_nnumerr := 9902907;
                  v_tdeserror := 'El tipo registro (tipo registro): ' || x.tiporegistro || ' '
                                 || 'no precede de un tipo registro de persona valido .';
                  v_nnumerr := p_marcalinea(p_ssproces, v_id_linea, v_toperacion, 2, 0, NULL,
                                            v_id, v_ncarga, NULL, NULL, NULL, NULL,
                                            x.nlinea || '(' || x.tiporegistro || ')');
                  v_nnumerr := p_marcalineaerror(p_ssproces, v_id_linea, NULL, 2,
                                                 NVL(v_nnumerr, 1), NVL(v_tdeserror, -1));
               END IF;
--
            END IF;   -- v_toperacion

            v_ntraza := 70090;
         EXCEPTION
            WHEN e_errdatos THEN
               ROLLBACK;
               v_berrorproc := TRUE;
               v_nnumerr := f_marcar_lineas(p_ssproces, v_ncarga, 1,   -- pongo error
                                            v_toperacion, NVL(v_nnumerr, 1),
                                            NVL(v_ntraza || '-' || v_tdeserror, -1), NULL,
                                            x.nlinea, NULL, NULL, NULL);

               IF k_cpara_error <> 1 THEN
                  v_ntipoerror := 4;
               -- para que continue con la siguiente linea.
               ELSE
                  v_ntipoerror := 1;   -- para la carga
                  RAISE e_salir;
               END IF;
            -- debo obviar todas las lineas hasta la siguiente linea 1
            WHEN e_salir THEN   -- salgo del cursor
               RAISE;
            WHEN OTHERS THEN
               v_nnumerr := SQLCODE;
               v_tdeserror := v_ntraza || ' en f_pol_ejecutar_carga_proceso -' || SQLERRM;
               ROLLBACK;
               v_berrorproc := TRUE;
               v_nnumerr := f_marcar_lineas(p_ssproces, v_ncarga, 1,   -- pongo error
                                            v_toperacion, v_nnumerr, v_tdeserror, NULL,
                                            x.nlinea, NULL, NULL, NULL);

               IF k_cpara_error <> 1 THEN
                  v_ntipoerror := 4;
               -- para que continue con la siguiente linea.
               ELSE
                  v_ntipoerror := 1;   -- para la carga
                  RAISE e_salir;
               END IF;
         END;
      END LOOP;

      v_ntraza := 70500;

      IF v_id IS NOT NULL
         AND v_ntipoerror NOT IN(1, 4) THEN
         -- lanza la ultima migraci¿n, cuando acaba el fichero
         IF v_toperacion = 'PER' THEN
            v_nnumerr := f_lanza_migracion_per(v_id, v_ncarga);
         END IF;

         IF v_nnumerr NOT IN(0, 2, 4) THEN   -- si ha habido error
            v_berrorproc := TRUE;
            ROLLBACK;
         ELSE
            COMMIT;
         END IF;
      END IF;

      v_ntraza := 70999;

-------------------------------- final loop ------------------------------------
-- COMMIT;
      IF v_berrorproc THEN
         RETURN 1;
      ELSIF v_bavisproc THEN
         RETURN 2;
      ELSE
         RETURN 4;
      END IF;
   EXCEPTION
      WHEN e_salir THEN
         ROLLBACK;
         RETURN 1;
      -- Fi Bug 16324
      WHEN OTHERS THEN
         v_nnumerr := SQLCODE;
         v_tdeserror := v_ntraza || ' en f_per_ejecutar_carga_proceso: ' || SQLERRM;
         ROLLBACK;
         v_nnumerr1 := p_marcalinea(p_ssproces, v_id_linea, 0, 1, 0, NULL, v_id, v_ncarga);
         v_nnumerr := p_marcalineaerror(p_ssproces, v_id_linea, NULL, 1, v_nnumerr,
                                        v_tdeserror);
         p_genera_logs(v_tobjeto, v_ntraza, 'Error Incontrolado:' || v_nnumerr, v_tdeserror);
         RETURN 1;
   END f_per_ejecutar_carga_proceso;

   /*************************************************************************
           Procedimiento que ejecuta una carga de un fichero
          param in p_nombre   : Nombre fichero
          param out psproces   : N¿mero proceso
          retorna 0 si ha ido bien, 1 en casos contrario
      *************************************************************************/
   FUNCTION f_ejecutar_carga_fichero(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER,
      pjob IN NUMBER DEFAULT 0,
      pcusuari IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'pac_cargas_generico.f_ejecutar_carga_fichero';
      linea          NUMBER := 0;
      pcarga         NUMBER;
      vtraza         NUMBER := 0;
      vdeserror      VARCHAR2(1000);
      errorini       EXCEPTION;
      --Indica error grabando estados.--Error que para ejecuci¿n
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
      --     IF vnum_err <> 0 THEN   --Si fallan esta funciones de gesti¿n salimos del programa
      --        p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
      --                    'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera');
      --        RAISE errorini;   --Error que para ejecuci¿n
      --     END IF;
      vtraza := 2;
      --Creamos la tabla int_carga_ext apartir del nombre de fichero enviado dinamicamente.
      vnum_err := f_modi_tabla_ext(p_nombre, p_path);

      IF vnum_err <> 0 THEN
         p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                     'Error creando la tabla externa', 10);
         RAISE errorini;   --Error que para ejecuci¿n
      END IF;

      vnum_err := f_trasp_tabla(vdeserror, psproces);
      vtraza := 3;

      IF vnum_err <> 0 THEN
         --Si hay un error leyendo el fichero salimos del programa del todo y lo indicamos.
         vtraza := 5;
         vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces, p_nombre,
                                                                    f_sysdate, NULL, 1,
                                                                    p_cproces, NULL,
                                                                    vdeserror, 0);
         vtraza := 51;

         IF vnum_err <> 0 THEN   --Si fallan esta funciones de gesti¿n salimos del programa
            p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                        'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera2',
                        10);
            RAISE errorini;   --Error que para ejecuci¿n
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
         vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces, p_nombre,
                                                                    f_sysdate, NULL, 1,
                                                                    p_cproces, 151541,
                                                                    SQLERRM, 0);
         vtraza := 51;

         IF vnum_err <> 0 THEN
            p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                        'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera2',
                        10);
         --RAISE errorini;
         END IF;

         RETURN 1;
   END f_ejecutar_carga_fichero;

/*************************************************************************
    Procedimiento que ejecuta una carga
             param in p_nombre   : Nombre fichero
             param in  out psproces   : N¿mero proceso (informado para recargar proceso).
             retorna 0 si ha ido bien, 1 en casos contrario
       *************************************************************************/
   FUNCTION f_pol_ejecutar_carga(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER,
      pjob IN NUMBER DEFAULT 0,
      pcusuari IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'pac_cargas_generico.f_pol_ejecutar_carga';
      vtraza         NUMBER := 0;
      vnum_err       NUMBER := 0;
      vsalir         EXCEPTION;
      wlinerr        NUMBER := 0;
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

      vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces, p_nombre, f_sysdate,
                                                                 NULL, 3,   --pendiente
                                                                 p_cproces, NULL, NULL, 1);   -- bloqueo

      IF vnum_err <> 0 THEN   --Si fallan esta funciones de gesti¿n salimos del programa
         p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                     'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera', 10);
         RAISE vsalir;   --Error que para ejecuci¿n
      END IF;

-- inicializamos trazas de debug
      pac_contexto.p_contextoasignaparametro('DEBUG', NVL(k_cdebug, 99));
--
      vtraza := 1;
      vnum_err := f_pol_ejecutar_carga_proceso(psproces);

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
   END f_pol_ejecutar_carga;

/***************************************************************************
   Procedimiento que ejecuta una carga de recibos
             param in p_nombre   : Nombre fichero
             param in  out psproces   : N¿mero proceso (informado para recargar proceso).
             retorna 0 si ha ido bien, 1 en casos contrario
*************************************************************************/
   FUNCTION f_rec_ejecutar_carga(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER,
      pjob IN NUMBER DEFAULT 0,
      pcusuari IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'pac_cargas_generico.f_pol_ejecutar_carga_rec';
      vtraza         NUMBER := 0;
      vnum_err       NUMBER := 0;
      vsalir         EXCEPTION;
      wlinerr        NUMBER := 0;
      pfcarga        DATE;
      v_sproces      int_carga_ctrl_linea.sproces%TYPE;
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
         -- I - MIRO SI ESTOY intentando un reproceso de RSA --
         IF NVL(pac_parametros.f_parempresa_n(k_cempresa, 'REPROCESO_CARGA_REC'), 0) = 1 THEN
            -- busco en los ficheros para ver si ya esta cargado
            BEGIN
               SELECT sproces
                 INTO v_sproces
                 FROM int_carga_ctrl
                WHERE cproceso = p_cproces
                  AND tfichero = p_nombre;

               psproces := v_sproces;

               UPDATE int_carga_ctrl_linea
                  SET cestado = 6
                WHERE sproces = psproces
                  AND cestado IN(1, 3);   -- los marco como recargados.
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;
         END IF;

         vnum_err := f_ejecutar_carga_fichero(p_nombre, p_path, p_cproces, psproces);

         IF vnum_err <> 0 THEN
            RAISE vsalir;
         END IF;
      END IF;

      vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces, p_nombre, f_sysdate,
                                                                 NULL, 3,   --pendiente
                                                                 p_cproces, NULL, NULL, 1);   -- bloqueo

      IF vnum_err <> 0 THEN   --Si fallan esta funciones de gesti¿n salimos del programa
         p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                     'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera', 10);
         RAISE vsalir;   --Error que para ejecuci¿n
      END IF;

-- inicializamos trazas de debug
      pac_contexto.p_contextoasignaparametro('DEBUG', NVL(k_cdebug, 99));
--
      vtraza := 1;
      --     if  k_tablas <> 'EST' then
      vnum_err := f_rec_ejecutar_carga_proceso(psproces);

      --     end if;
      UPDATE    int_carga_ctrl
            SET cestado = vnum_err,
                ffin = f_sysdate,
                cbloqueo = 0   -- lo desbloqueo
          WHERE sproces = psproces
      RETURNING fini
           INTO pfcarga;

      IF b_cobro_parcial THEN   -- si ha habido un cobro parcial llamo a la funci¿n
         v_nnumerr := pac_caja.f_ins_pagos_masivo(psproces, pfcarga, p_nombre);

         IF v_nnumerr <> 0 THEN
            UPDATE int_carga_ctrl
               SET cestado = 1,
                   terror = 'Error insertando en pagos masivos'
             WHERE sproces = psproces;

            RETURN 1;
         END IF;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN vsalir THEN
         RETURN vnum_err;
   END f_rec_ejecutar_carga;

/*************************************************************************
    Procedimiento que ejecuta una carga de fichero de siniestros segun el estandard.
             param in p_nombre   : Nombre fichero
             param in  out psproces   : N¿mero proceso (informado para recargar proceso).
             retorna 0 si ha ido bien, otro valor en caso contrario
   *************************************************************************/
   FUNCTION f_sin_ejecutar_carga(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER,
      pjob IN NUMBER DEFAULT 0,
      pcusuari IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'pac_cargas_generico.f_sin_ejecutar_carga';
      vtraza         NUMBER := 0;
      vnum_err       NUMBER := 0;
      vsalir         EXCEPTION;
      wlinerr        NUMBER := 0;
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

      vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces, p_nombre, f_sysdate,
                                                                 NULL, 3,   --pendiente
                                                                 p_cproces, NULL, NULL, 1);   -- bloqueo

      IF vnum_err <> 0 THEN   --Si fallan esta funciones de gesti¿n salimos del programa
         p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                     'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera', 10);
         RAISE vsalir;   --Error que para ejecuci¿n
      END IF;

-- inicializamos trazas de debug
      pac_contexto.p_contextoasignaparametro('DEBUG', NVL(k_cdebug, 99));
--
      vtraza := 1;
      vnum_err := f_sin_ejecutar_carga_proceso(psproces);

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
   END f_sin_ejecutar_carga;

-- Nueva carga de personas

   /*************************************************************************
    Procedimiento que ejecuta una carga de fichero de personas segun el estandard.
             param in p_nombre   : Nombre fichero
             param in  out psproces   : N¿mero proceso (informado para recargar proceso).
             retorna 0 si ha ido bien, otro valor en caso contrario
   *************************************************************************/
   FUNCTION f_per_ejecutar_carga(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER,
      pjob IN NUMBER DEFAULT 0,
      pcusuari IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'pac_cargas_generico.f_per_ejecutar_carga';
      vtraza         NUMBER := 0;
      vnum_err       NUMBER := 0;
      vsalir         EXCEPTION;
      wlinerr        NUMBER := 0;
   BEGIN
      vtraza := 0;

      IF pjob = 1 THEN
         vnum_err :=
            pac_contexto.f_inicializarctx(NVL(pcusuari,
                                              pac_parametros.f_parempresa_t(k_cempresa,
                                                                            'USER_BBDD')));
      END IF;

      SELECT NVL(cpara_error, 0), NVL(cbusca_host, 0), NVL(cformato_decimales, 0),
             NVL(ctablas, 'PER'), cdebug, nregmasivo
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

      vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces, p_nombre, f_sysdate,
                                                                 NULL, 3,   --pendiente
                                                                 p_cproces, NULL, NULL, 1);   -- bloqueo

      IF vnum_err <> 0 THEN   --Si fallan esta funciones de gesti¿n salimos del programa
         p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                     'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera', 10);
         RAISE vsalir;   --Error que para ejecuci¿n
      END IF;

-- inicializamos trazas de debug
      pac_contexto.p_contextoasignaparametro('DEBUG', NVL(k_cdebug, 99));
--
      vtraza := 1;
      vnum_err := f_per_ejecutar_carga_proceso(psproces);

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
   END f_per_ejecutar_carga;

-- 28694 - JLB - procesos de paso a JOB
    /*************************************************************************
             procedimiento que ejecuta una carga mediante un job
       param in  out psproces   : N¿mero proceso (informado para recargar proceso).
       retorna 0 si ha ido bien, 1 en casos contrario
   *************************************************************************/
   FUNCTION f_pol_ejecutar_carga_job(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER)
      RETURN NUMBER IS
      vmensaje       NUMBER;
      mensajes       t_iax_mensajes;
      vobj           VARCHAR2(100) := 'PAC_CARGAS_GENERICO.f_pol_ejecutar_carga_job';
      vtraza         NUMBER := 0;
      v_tfichero     VARCHAR2(300) := p_path || '\' || p_nombre;
      vnum_err       NUMBER;
      vnnumlin       NUMBER;
   BEGIN
      IF psproces IS NULL THEN
         SELECT sproces.NEXTVAL
           INTO psproces
           FROM DUAL;

         vmensaje :=
            pac_jobs.f_ejecuta_job
                           (NULL,
                            'declare nerror number; vsproces number := ' || psproces
                            || '; begin nerror := pac_cargas_generico.f_pol_ejecutar_carga('''
                            || p_nombre || ''',''' || p_path || ''',' || p_cproces
                            || ', vsproces, 1,''' || f_user || '''); end;',
                            NULL);

         IF vmensaje > 0 THEN
            RETURN 180856;
         END IF;

         RETURN 9901606;
      ELSE
         vnum_err := f_pol_ejecutar_carga(p_nombre, p_path, p_cproces,   -- BUG16130:DRA:15/10/2010
                                          psproces);
         RETURN vnum_err;
      END IF;

      RETURN 0;
   END f_pol_ejecutar_carga_job;

   /*************************************************************************
       Procedimiento que ejecuta una carga de recibos mediante un job
       param in  out psproces   : N¿mero proceso (informado para recargar proceso).
       retorna 0 si ha ido bien, 1 en casos contrario
   *************************************************************************/
   FUNCTION f_rec_ejecutar_carga_job(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER)
      RETURN NUMBER IS
      vmensaje       NUMBER;
      mensajes       t_iax_mensajes;
      vobj           VARCHAR2(100) := 'PAC_CARGAS_GENERICO.f_rec_ejecutar_carga_job';
      vtraza         NUMBER := 0;
      v_tfichero     VARCHAR2(300) := p_path || '\' || p_nombre;
      vnum_err       NUMBER;
      vnnumlin       NUMBER;
   BEGIN
      IF psproces IS NULL THEN
         SELECT sproces.NEXTVAL
           INTO psproces
           FROM DUAL;

         vmensaje :=
            pac_jobs.f_ejecuta_job
                           (NULL,
                            'declare nerror number; vsproces number := ' || psproces
                            || '; begin nerror := pac_cargas_generico.f_rec_ejecutar_carga('''
                            || p_nombre || ''',''' || p_path || ''',' || p_cproces
                            || ', vsproces, 1,''' || f_user || '''); end;',
                            NULL);

         IF vmensaje > 0 THEN
            RETURN 180856;
         END IF;

         RETURN 9901606;
      ELSE
         vnum_err := f_rec_ejecutar_carga(p_nombre, p_path, p_cproces,   -- BUG16130:DRA:15/10/2010
                                          psproces);
         RETURN vnum_err;
      END IF;

      RETURN 0;
   END f_rec_ejecutar_carga_job;

   /*************************************************************************
       Procedimiento que ejecuta una carga de siniestros mediante un job
       param in  out psproces   : N¿mero proceso (informado para recargar proceso).
       retorna 0 si ha ido bien, 1 en casos contrario
   *************************************************************************/
   FUNCTION f_sin_ejecutar_carga_job(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER)
      RETURN NUMBER IS
      vmensaje       NUMBER;
      mensajes       t_iax_mensajes;
      vobj           VARCHAR2(100) := 'PAC_CARGAS_GENERICO.f_sin_ejecutar_carga_job';
      vtraza         NUMBER := 0;
      v_tfichero     VARCHAR2(300) := p_path || '\' || p_nombre;
      vnum_err       NUMBER;
      vnnumlin       NUMBER;
   BEGIN
      IF psproces IS NULL THEN
         SELECT sproces.NEXTVAL
           INTO psproces
           FROM DUAL;

         vmensaje :=
            pac_jobs.f_ejecuta_job
                           (NULL,
                            'declare nerror number; vsproces number := ' || psproces
                            || '; begin nerror := pac_cargas_generico.f_sin_ejecutar_carga('''
                            || p_nombre || ''',''' || p_path || ''',' || p_cproces
                            || ', vsproces, 1,''' || f_user || '''); end;',
                            NULL);

         IF vmensaje > 0 THEN
            RETURN 180856;
         END IF;

         RETURN 9901606;
      ELSE
         vnum_err := f_sin_ejecutar_carga(p_nombre, p_path, p_cproces,   -- BUG16130:DRA:15/10/2010
                                          psproces);
         RETURN vnum_err;
      END IF;

      RETURN 0;
   END f_sin_ejecutar_carga_job;

   /*************************************************************************
       Procedimiento que ejecuta una carga de personas mediante un job
       param in  out psproces   : N¿mero proceso (informado para recargar proceso).
       retorna 0 si ha ido bien, 1 en casos contrario
   *************************************************************************/
   FUNCTION f_per_ejecutar_carga_job(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER)
      RETURN NUMBER IS
      vmensaje       NUMBER;
      mensajes       t_iax_mensajes;
      vobj           VARCHAR2(100) := 'PAC_CARGAS_GENERICO.f_per_ejecutar_carga_job';
      vtraza         NUMBER := 0;
      v_tfichero     VARCHAR2(300) := p_path || '\' || p_nombre;
      vnum_err       NUMBER;
      vnnumlin       NUMBER;
   BEGIN
      IF psproces IS NULL THEN
         SELECT sproces.NEXTVAL
           INTO psproces
           FROM DUAL;

         vmensaje :=
            pac_jobs.f_ejecuta_job
                           (NULL,
                            'declare nerror number; vsproces number := ' || psproces
                            || '; begin nerror := pac_cargas_generico.f_per_ejecutar_carga('''
                            || p_nombre || ''',''' || p_path || ''',' || p_cproces
                            || ', vsproces, 1,''' || f_user || '''); end;',
                            NULL);

         IF vmensaje > 0 THEN
            RETURN 180856;
         END IF;

         RETURN 9901606;
      ELSE
         vnum_err := f_per_ejecutar_carga(p_nombre, p_path, p_cproces,   -- BUG16130:DRA:15/10/2010
                                          psproces);
         RETURN vnum_err;
      END IF;

      RETURN 0;
   END f_per_ejecutar_carga_job;
   /*************************************************************************
       Procedimiento que ejecuta  carga de profesionales.
       param in p_ssproces   : N¿mero proceso
       retorna 0 si ha ido bien, 1 en casos contrario
   *************************************************************************/

   FUNCTION f_prof_ejecutar_carga_proceso(p_ssproces IN NUMBER)
      RETURN NUMBER IS
      v_tobjeto      VARCHAR2(100) := 'pac_cargas_generico.f_prof_ejecutar_carga_proceso';
      v_ntraza       NUMBER := 0;
      e_salir        EXCEPTION;

      CURSOR cur_proveedores(p_ssproces2 IN NUMBER) IS
         SELECT   a.*
             FROM int_carga_generico a
            WHERE proceso = p_ssproces2
              AND NOT EXISTS(SELECT 1
                               FROM int_carga_ctrl_linea b
                              WHERE b.sproces = a.proceso
                                AND b.nlinea = a.nlinea
                                AND b.cestado IN(2, 4, 5, 6))
         ORDER BY nlinea, tiporegistro;

      v_toperacion   VARCHAR2(20);
      v_berrorproc   BOOLEAN := FALSE;
      v_berrorlin    BOOLEAN := FALSE;
      v_bavisproc    BOOLEAN := FALSE;
      v_ncarga       int_carga_generico.ncarga%TYPE;
      v_ntipoerror   NUMBER := 0;
      v_tfichero     int_carga_ctrl.tfichero%TYPE;
      reg_migpersonas mig_personas%ROWTYPE;
      reg_migregimenfiscal mig_regimenfiscal%ROWTYPE;
      reg_migdirec   mig_direcciones%ROWTYPE;
      reg_migprofesional mig_sin_prof_profesionales%ROWTYPE;
      reg_migprofindicadores mig_sin_prof_indicadores%ROWTYPE;
      reg_migprofrol mig_sin_prof_rol%ROWTYPE;
      reg_migprofcontactos mig_sin_prof_contactos%ROWTYPE;
      reg_migprofccc mig_sin_prof_ccc%ROWTYPE;
      reg_migprofrepre mig_sin_prof_repre%ROWTYPE;
      reg_migprofsede mig_sin_prof_sede%ROWTYPE;
      reg_migprofestados mig_sin_prof_estados%ROWTYPE;
      reg_migprofzonas mig_sin_prof_zonas%ROWTYPE;
      reg_migprofcarga mig_sin_prof_carga%ROWTYPE;
      reg_migprofobservaciones mig_sin_prof_observaciones%ROWTYPE;
      --
      v_rowid        ROWID;
      v_id           mig_cargas.ID%TYPE;
      v_id_linea     int_carga_generico.nlinea%TYPE;
      v_id_linea_1   NUMBER;
      --
      v_sproces      NUMBER;
      v_pk_profesional VARCHAR2(200);

      /***************************************************************************
       FUNCTION f_lanza_migracion
           Asigna n¿mero de carga
           Return: N¿mero de carga
       ***************************************************************************/
      FUNCTION f_lanza_migracion_prof(p_id IN VARCHAR2, p_ncarga IN NUMBER)
         RETURN NUMBER IS
         v_ntiperr      NUMBER := 0;
         v_sperson      per_personas.sperson%TYPE;
      BEGIN
         pac_mig_axis.p_migra_cargas(p_id, 'C', p_ncarga, 'DEL', k_tablas);

         --Cargamos las SEG para la p¿liza (ncarga)
         FOR reg IN (SELECT *
                       FROM mig_logs_axis
                      WHERE ncarga = p_ncarga
                        AND tipo = 'E') LOOP
            --Miramos si ha habido alg¿n error y lo informamos.
            v_ntraza := 200;
            v_nnumerr := f_marcar_lineas(p_ssproces, p_ncarga, 1,   -- pongo errr todas las lineas
                                         v_toperacion, 9909865, reg.incid, NULL, NULL, NULL,
                                         NULL, NULL);
            v_berrorproc := TRUE;
            v_ntiperr := 1;
         END LOOP;

         IF v_ntiperr = 0 THEN
            FOR reg IN (SELECT *
                          FROM mig_logs_axis
                         WHERE ncarga = p_ncarga
                           AND tipo = 'W') LOOP   --Miramos si han habido warnings.
               v_ntraza := 202;

               BEGIN
                  SELECT idperson
                    INTO v_sperson
                    FROM mig_personas
                   WHERE ncarga = p_ncarga;
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;   --JRH IMP de momento
               END;

               v_nnumerr := f_marcar_lineas(p_ssproces, p_ncarga, 2,   -- pongo errr todas las lineas
                                            v_toperacion, 700145, reg.incid, NULL, NULL, NULL,
                                            NULL, v_sperson);
               v_bavisproc := TRUE;
               v_ntiperr := 2;
            END LOOP;
         END IF;

         IF v_ntiperr = 0 THEN
            --Esto quiere decir que no ha habido ning¿n error (lo indicamos tambi¿n).
            v_ntraza := 204;

            BEGIN
               SELECT idperson
                 INTO v_sperson
                 FROM mig_personas
                WHERE ncarga = p_ncarga;
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;   --JRH IMP de momento
            END;

            FOR c_lin IN (SELECT nlinea, idint, tipoper
                            FROM int_carga_ctrl_linea
                           WHERE sproces = p_ssproces
                             AND ncarga = p_ncarga) LOOP
               v_nnumerr := p_marcalinea(p_ssproces, c_lin.nlinea, c_lin.tipoper, 4, 1, NULL,
                                         p_id, p_ncarga, NULL, NULL, v_sperson, NULL,
                                         c_lin.idint);

               IF v_nnumerr <> 0 THEN
                  --Si fallan estas funciones de gesti¿n salimos del programa
                  v_tdeserror := 'Falta marcar linea 4: ' || p_ssproces || '/' || p_id;
                  RAISE e_errdatos;
               END IF;
            END LOOP;

            v_ntiperr := 4;
         END IF;

         -- Lanzo validaciones  si ha la poliza esta migrada
         RETURN v_ntiperr;   --Devolvemos el tipo error que ha habido
      EXCEPTION
         WHEN e_errdatos THEN
            ROLLBACK;
            v_nnumerr := f_marcar_lineas(p_ssproces, p_ncarga, 2,   -- pongo errr todas las lineas
                                         v_toperacion, NVL(v_nnumerr, 1), NVL(v_tdeserror, -1),
                                         NULL, NULL, NULL, NULL, v_sperson);
            RETURN v_nnumerr;
         WHEN OTHERS THEN
            v_nnumerr := SQLCODE;
            v_tdeserror := v_ntraza || ' en f_lanza_migracion_prof: ' || SQLERRM;
            ROLLBACK;
            v_nnumerr1 := p_marcalinea(p_ssproces, v_id_linea, v_toperacion, 1, 0, NULL, p_id,
                                       p_ncarga);
            v_nnumerr := p_marcalineaerror(p_ssproces, v_id_linea, NULL, 1, v_nnumerr,
                                           v_tdeserror);
            RETURN SQLCODE;
      END f_lanza_migracion_prof;
   BEGIN
      v_ntraza := 0;

      IF p_ssproces IS NULL THEN
         v_nnumerr := 9000505;
         v_tdeserror := 'Par¿metro p_ssproces obligatorio.';
         p_genera_logs(v_tobjeto, v_ntraza, 'Error:' || v_nnumerr, v_tdeserror);
         RAISE e_salir;
      END IF;

      v_ntraza := 1;
      v_ntraza := 1;
      v_toperacion := 'PROF';
      v_ncarga := NULL;
      v_id_linea_1 := NULL;

      FOR x IN cur_proveedores(p_ssproces) LOOP
         BEGIN
            --
            v_ntraza := 3;
            --
            IF x.tiporegistro = '80' THEN   -- si cambio de bloque de registros de profesionales
               IF v_id IS NOT NULL
                  AND reg_migprofesional.ncarga IS NOT NULL
                  AND v_ntipoerror NOT IN(1, 4) THEN
                  v_nnumerr := f_lanza_migracion_prof(v_id, v_ncarga);

                  IF v_nnumerr NOT IN(0, 2, 4) THEN   -- si ha habido error
                     v_berrorlin := TRUE;
                     v_berrorproc := TRUE;
                     ROLLBACK;

                     IF k_cpara_error <> 1 THEN
                        v_ntipoerror := 4;
                     -- para que continue con la siguiente linea.
                     ELSE
                        v_ntipoerror := 1;   -- para la carga
                        RAISE e_salir;
                     END IF;
                  ELSE
                     COMMIT;
                  END IF;
               END IF;

               IF v_id_linea_1 IS NOT NULL
                  AND x.tiporegistro = '80' THEN
                  IF v_berrorlin THEN
                     v_nnumerr := p_marcalinea(x.proceso, v_id_linea_1, 'PROF', 1, 0, NULL,
                                               v_id, v_ncarga, NULL, NULL, NULL, NULL,
                                               v_id_linea_1 || '(' || x.tiporegistro || ')');
                  ELSE
                     v_nnumerr := p_marcalinea(x.proceso, v_id_linea_1, 'PROF', 4, 1, NULL,
                                               v_id, v_ncarga, NULL, NULL, NULL, NULL,
                                               v_id_linea_1 || '(' || x.tiporegistro || ')');
                  END IF;

                  v_id_linea_1 := NULL;
               END IF;

               v_ncarga := f_next_carga;
               v_id := TRIM(x.campo03) || '-' || x.campo04;
               v_nnumerr := p_marcalinea(x.proceso, x.nlinea, 'PROF', 3, 0, NULL,
                                         TRIM(x.campo02) || '-' || x.campo03, v_ncarga, NULL,
                                         NULL, NULL, NULL,
                                         x.nlinea || '(' || x.tiporegistro || ')');

               INSERT INTO mig_cargas
                           (ncarga, cempres, finiorg, ffinorg, ID, estorg)
                    VALUES (v_ncarga, k_cempresa, f_sysdate, f_sysdate, v_id, NULL);

               reg_migpersonas := NULL;
               reg_migregimenfiscal := NULL;
               reg_migdirec := NULL;
               reg_migprofesional := NULL;
               reg_migprofindicadores := NULL;
               reg_migprofrol := NULL;
               reg_migprofcontactos := NULL;
               reg_migprofccc := NULL;
               reg_migprofrepre := NULL;
               reg_migprofsede := NULL;
               reg_migprofestados := NULL;
               reg_migprofzonas := NULL;
               reg_migprofcarga := NULL;
               reg_migprofobservaciones := NULL;
               v_ntipoerror := 0;
            ELSIF x.tiporegistro IN('71A', '71B', '71C') THEN
               v_nnumerr := p_marcalinea(x.proceso, x.nlinea, 'PERD', 3, 0, NULL, v_id,
                                         v_ncarga, NULL, NULL, NULL, NULL,
                                         x.nlinea || '(' || x.tiporegistro || ')');
            END IF;

            IF v_ntipoerror NOT IN(1, 4) THEN
               v_ntraza := 90010;


                 IF x.tiporegistro = '80' THEN
                  v_id := TRIM(x.campo03) || '-' || x.campo04;
                  v_id_linea_1 := x.nlinea;
                  INSERT INTO mig_cargas_tab_mig
                              (ncarga, tab_org, tab_des, ntab)
                       VALUES (v_ncarga, 'INT_CARGA_GENERICO', 'MIG_SIN_PROF_PROFESIONALES', 1);
                  v_pk_profesional := v_ncarga || '/' || x.campo03 || '/'
                                            || x.campo04;
                   v_ntraza := 90010;
                  reg_migprofesional.ncarga := v_ncarga;
                  v_ntraza := 90011;
                  reg_migprofesional.cestmig := 1;
                  v_ntraza := 90012;
                  reg_migprofesional.mig_pk := v_ncarga || '/' || x.campo03 || '/'
                                            || x.campo04;
                  v_ntraza := 90013;
                  reg_migprofesional.sprofes := x.campo01;
                  v_ntraza := 90014;
                  reg_migprofesional.idperson := x.campo02;
                  v_ntraza := 90015;
                  reg_migprofesional.ctipide := x.campo03;
                  v_ntraza := 90016;
                  reg_migprofesional.nnumide := x.campo04;
                  v_ntraza := 90017;
                  reg_migprofesional.tdigitoide := x.campo05;
                  v_ntraza := 90018;
                  reg_migprofesional.nregmer := x.campo06;
                  v_ntraza := 90019;
                  reg_migprofesional.fregmer := f_chartodate(x.campo07);
                  v_ntraza := 90020;
                  reg_migprofesional.cdomici := x.campo08;
                  v_ntraza := 90021;
                  reg_migprofesional.cmodcon := x.campo09;
                  v_ntraza := 90022;
                  reg_migprofesional.nlimite := x.campo10;
                  v_ntraza := 90023;
                  reg_migprofesional.cnoasis := x.campo11;
                  v_ntraza := 90024;
                  reg_migprofesional.proceso := x.proceso;

                  BEGIN
                     INSERT INTO mig_sin_prof_profesionales
                          VALUES reg_migprofesional
                       RETURNING ROWID
                            INTO v_rowid;

                     v_ntraza := 70080;

                     INSERT INTO mig_pk_emp_mig
                          VALUES (0, v_ncarga, 80, reg_migprofesional.mig_pk);
                          COMMIT;
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                        NULL;
                  END;



               ELSIF x.tiporegistro = '70' THEN

                  reg_migpersonas := NULL;
                  v_ntraza := 70010;

                  INSERT INTO mig_cargas_tab_mig
                              (ncarga, tab_org, tab_des, ntab)
                       VALUES (v_ncarga, 'INT_CARGA_GENERICO', 'MIG_PERSONAS', 1);

                  reg_migpersonas.ncarga := v_ncarga;
                  reg_migpersonas.proceso := x.proceso;

                  IF x.campo02 IS NULL
                     OR x.campo03 IS NULL THEN
                     v_tdeserror := 'Se debe informar el tipo y documento de documento.';
                     RAISE e_errdatos;
                  END IF;

                  reg_migpersonas.cagente := ff_agente_cpervisio(x.campo01);
                  reg_migpersonas.ctipide := x.campo02;
                  reg_migpersonas.nnumide := x.campo03;
                  reg_migpersonas.tdigitoide := x.campo04;
                  reg_migpersonas.mig_pk := v_ncarga || '/' || reg_migpersonas.ctipide || '/'
                                            || reg_migpersonas.nnumide;
                  v_ntraza := 3030;
                  reg_migpersonas.cestmig := 1;
                  reg_migpersonas.idperson := 0;

                  IF x.campo05 = ''
                     OR x.campo05 IS NULL THEN
                     v_tdeserror := 'Se debe informar el tipo de persona.';
                     RAISE e_errdatos;
                  END IF;

                  reg_migpersonas.cpertip := NVL(f_buscavalor('TIPUS PERSONA', x.campo05),1);

                  IF x.campo06 = ''
                     OR x.campo06 IS NULL THEN
                     v_tdeserror := 'Se debe informar el apellido 1.';
                     RAISE e_errdatos;
                  END IF;

                  reg_migpersonas.tapelli1 := x.campo06;
                  reg_migpersonas.tapelli2 := x.campo07;
                  reg_migpersonas.cidioma := k_cidioma;
                  reg_migpersonas.tnombre := x.campo08;
                  reg_migpersonas.tnombre2 := x.campo09;
                  v_ntraza := 3060;
                  reg_migpersonas.csexper := x.campo10;

                  IF reg_migpersonas.cpertip = 1
                     AND reg_migpersonas.csexper IS NULL THEN
                     v_tdeserror := 'Si es persona natural se debe informar su sexo.';
                     RAISE e_errdatos;
                  END IF;
                  v_ntraza := 3061;

                  reg_migpersonas.swpubli := 0;
                  reg_migpersonas.fnacimi := f_chartodate(x.campo11);
                  v_ntraza := 3062;
                  IF reg_migpersonas.cpertip = 1
                     AND reg_migpersonas.fnacimi IS NULL THEN
                     v_tdeserror :=
                           'Si es persona es natural se debe informar su fecha de nacimiento.';
                     v_nnumerr := 1000401;
                     RAISE e_errdatos;
                  END IF;
                  v_ntraza := 3063;

                  IF reg_migpersonas.fnacimi IS NOT NULL
                     AND TRUNC(reg_migpersonas.fnacimi) > TRUNC(f_sysdate) THEN
                     v_tdeserror :=
                        'La fecha de nacimiento de la persona no puede ser superior a la fecha de hoy.';
                     RAISE e_errdatos;
                  END IF;
                  v_ntraza := 3064;
                  reg_migpersonas.cnacio := x.campo12;
                  reg_migpersonas.cestciv := x.campo13;
                  reg_migpersonas.tnumtel := x.campo14;
                  reg_migpersonas.tnummov := x.campo15;
                  reg_migpersonas.temail := x.campo16;
                  reg_migpersonas.tnumfax := x.campo17;
                  v_ntraza := 70070;
                  reg_migpersonas.ctipban := x.campo19;
                  reg_migpersonas.cbancar := x.campo20;
                  reg_migpersonas.snip := x.campo21;
                  reg_migpersonas.cestper := NVL(x.campo22, 0);
                  reg_migpersonas.cprofes := x.campo23;
                  reg_migpersonas.cocupacion := x.campo24;
                  reg_migpersonas.cpais := NVL(x.campo25, reg_migpersonas.cnacio);
                  -- pais de residencia = a nacionalidad
                  reg_migpersonas.fjubila := f_chartodate(x.campo26);
                  reg_migpersonas.fdefunc := f_chartodate(x.campo27);

                  v_ntraza := 70070;

                  BEGIN
                     INSERT INTO mig_personas
                          VALUES reg_migpersonas
                       RETURNING ROWID
                            INTO v_rowid;

                     v_ntraza := 70080;

                     INSERT INTO mig_pk_emp_mig
                          VALUES (0, v_ncarga, 3, reg_migpersonas.mig_pk);
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                        NULL;
                  END;

                  IF x.campo13 IS NOT NULL THEN
                     v_ntraza := 70100;

                     INSERT INTO mig_cargas_tab_mig
                                 (ncarga, tab_org, tab_des, ntab)
                          VALUES (v_ncarga, 'INT_CARGA_GENERICO', 'MIG_REGIMENFISCAL', 1);

                     v_ntraza := 70110;
                     reg_migregimenfiscal := NULL;
                     reg_migregimenfiscal.ncarga := v_ncarga;
                     reg_migregimenfiscal.cestmig := 1;
                     reg_migregimenfiscal.mig_pk :=
                                  v_ncarga || '/' || x.nlinea || '/' || reg_migpersonas.nnumide;
                     reg_migregimenfiscal.mig_fk := reg_migpersonas.mig_pk;
                     reg_migregimenfiscal.nanuali := TO_CHAR(f_sysdate, 'YYYY');
                     reg_migregimenfiscal.fefecto := TRUNC(f_sysdate);
                     reg_migregimenfiscal.cregfis := x.campo13;

                     BEGIN
                        INSERT INTO mig_regimenfiscal
                             VALUES reg_migregimenfiscal
                          RETURNING ROWID
                               INTO v_rowid;

                        v_ntraza := 70080;

                        INSERT INTO mig_pk_emp_mig
                             VALUES (0, v_ncarga, 70, reg_migregimenfiscal.mig_pk);
                     EXCEPTION
                        WHEN DUP_VAL_ON_INDEX THEN
                           NULL;
                     END;
                  END IF;


               ELSIF x.tiporegistro = '71A' THEN   --  direccion tomadores Chile
                  reg_migdirec := NULL;
                  v_ntraza := 71010;

                  INSERT INTO mig_cargas_tab_mig
                              (ncarga, tab_org, tab_des, ntab)
                       VALUES (v_ncarga, 'INT_CARGA_GENERICO', 'MIG_DIRECCIONES', 1);

                  v_ntraza := 71020;
                  reg_migdirec.ncarga := v_ncarga;
                  reg_migdirec.proceso := x.proceso;
                  reg_migdirec.mig_pk := v_ncarga || '/' || reg_migpersonas.mig_pk || '/'
                                         || x.nlinea || '/' || x.campo01;
                  v_ntraza := 71030;
                  reg_migdirec.cestmig := 1;
                  reg_migdirec.sperson := 0;
                  reg_migdirec.mig_fk := reg_migpersonas.mig_pk;
                  reg_migdirec.cagente := reg_migpersonas.cagente;
                  reg_migdirec.cdomici := x.campo01;
                  reg_migdirec.ctipdir := x.campo02;
                  reg_migdirec.csiglas := x.campo03;
                  reg_migdirec.tnomvia := SUBSTR(x.campo04, 1, 200);
                  v_ntraza := 71040;
                  reg_migdirec.tnum1ia := x.campo05;
                  reg_migdirec.tnum2ia := x.campo06;
                  reg_migdirec.tnum3ia := x.campo07;
                  reg_migdirec.cpoblac := x.campo08;
                  v_ntraza := 71050;
                  reg_migdirec.localidad := x.campo09;
                  reg_migdirec.cprovin := x.campo10;
                  v_ntraza := 71060;

                  IF LENGTH(x.campo04) > 200
                     AND reg_migdirec.tnum1ia IS NULL THEN
                     reg_migdirec.tnum1ia := SUBSTR(x.campo05, 201, 100);
                  END IF;

                  v_ntraza := 71080;

                  --   reg_migdirec.cpostal := x.campo12;
                  BEGIN
                     INSERT INTO mig_direcciones
                          VALUES reg_migdirec
                       RETURNING ROWID
                            INTO v_rowid;

                     INSERT INTO mig_pk_emp_mig
                          VALUES (0, v_ncarga, 71, reg_migdirec.mig_pk);
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN   -- puede ser que la persona haya llegado como otro figura
                        NULL;
                  END;
               ELSIF x.tiporegistro = '71B' THEN   --  direccion tomadores Colombia
                  reg_migdirec := NULL;
                  v_ntraza := 71200;

                  INSERT INTO mig_cargas_tab_mig
                              (ncarga, tab_org, tab_des, ntab)
                       VALUES (v_ncarga, 'INT_CARGA_GENERICO', 'MIG_DIRECCIONES', 1);

                  reg_migdirec.ncarga := v_ncarga;
                  reg_migdirec.proceso := x.proceso;
                  v_ntraza := 71210;
                  reg_migdirec.mig_pk := v_ncarga || '/' || reg_migpersonas.mig_pk || '/'
                                         || x.nlinea || '/' || x.campo02;
                  reg_migdirec.cestmig := 1;
                  reg_migdirec.sperson := 0;
                  v_ntraza := 71220;
                  reg_migdirec.mig_fk := reg_migpersonas.mig_pk;
                  reg_migdirec.cagente := reg_migpersonas.cagente;
                  reg_migdirec.cdomici := x.campo01;
                  reg_migdirec.cpostal := x.campo19;
                  reg_migdirec.cpoblac := x.campo20;
                  v_ntraza := 71230;
                  reg_migdirec.cprovin := x.campo21;
                  reg_migdirec.csiglas := NULL;
                  reg_migdirec.tnomvia := NULL;
                  reg_migdirec.nnumvia := x.campo04;
                  reg_migdirec.tcomple := NULL;
                  v_ntraza := 71240;
                  reg_migdirec.ctipdir := x.campo02;
                  reg_migdirec.cviavp := x.campo03;
                  reg_migdirec.clitvp := x.campo05;
                  reg_migdirec.cbisvp := x.campo06;
                  reg_migdirec.corvp := x.campo07;
                  v_ntraza := 71250;
                  reg_migdirec.nviaadco := x.campo08;
                  reg_migdirec.clitco := x.campo09;
                  reg_migdirec.corco := x.campo10;
                  reg_migdirec.nplacaco := x.campo11;
                  v_ntraza := 71260;
                  reg_migdirec.cor2co := x.campo12;
                  reg_migdirec.cdet1ia := x.campo13;
                  reg_migdirec.tnum1ia := x.campo14;
                  reg_migdirec.cdet2ia := x.campo15;
                  v_ntraza := 71270;
                  reg_migdirec.tnum2ia := x.campo16;
                  reg_migdirec.cdet3ia := x.campo17;
                  reg_migdirec.tnum3ia := x.campo18;
                  v_ntraza := 71280;

                  BEGIN
                     INSERT INTO mig_direcciones
                          VALUES reg_migdirec
                       RETURNING ROWID
                            INTO v_rowid;

                     INSERT INTO mig_pk_emp_mig
                          VALUES (0, v_ncarga, 71, reg_migdirec.mig_pk);
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN   -- puede ser que la persona haya llegado como otro figura
                        NULL;
                  END;
                  --
               ELSIF x.tiporegistro = '81' THEN   --  Impuestos del proveedor
                  --
                  INSERT INTO mig_cargas_tab_mig
                                 (ncarga, tab_org, tab_des, ntab)
                          VALUES (v_ncarga, 'INT_CARGA_GENERICO', 'MIG_SIN_PROF_INDICADORES', 1);

                  v_ntraza := 70110;
                  reg_migprofindicadores := NULL;
                  reg_migprofindicadores.ncarga := v_ncarga;
                  reg_migprofindicadores.cestmig := 1;
                  reg_migprofindicadores.sprofes := reg_migprofesional.sprofes;
                  reg_migprofindicadores.ctipind := x.campo01;
                  reg_migprofindicadores.mig_pk :=
                               v_ncarga || '/' || x.nlinea || '/' || reg_migprofindicadores.sprofes ||
                               reg_migprofindicadores.ctipind;
                  reg_migprofindicadores.mig_fk := v_pk_profesional;
                  reg_migprofindicadores.proceso := x.proceso;

                  --
                  BEGIN
                     INSERT INTO mig_sin_prof_indicadores
                          VALUES reg_migprofindicadores
                       RETURNING ROWID
                            INTO v_rowid;

                      INSERT INTO mig_pk_emp_mig
                          VALUES (0, v_ncarga, 81, reg_migprofindicadores.mig_pk);
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                        NULL;
                  END;
                  --
               ELSIF x.tiporegistro = '82' THEN   --  Rol del proveedor
                  --
                  INSERT INTO mig_cargas_tab_mig
                                 (ncarga, tab_org, tab_des, ntab)
                          VALUES (v_ncarga, 'INT_CARGA_GENERICO', 'MIG_SIN_PROF_ROL', 1);

                  v_ntraza := 70110;
                  reg_migprofrol := NULL;
                  reg_migprofrol.ncarga := v_ncarga;
                  reg_migprofrol.cestmig := 1;
                  reg_migprofrol.sprofes := reg_migprofesional.sprofes;
                  reg_migprofrol.ctippro := x.campo01;
                  reg_migprofrol.csubpro := x.campo02;
                  reg_migprofrol.fbaja := f_chartodate(x.campo03);
                  reg_migprofrol.mig_pk :=
                               v_ncarga || '/' || x.nlinea || '/' || reg_migprofrol.sprofes
                               || reg_migprofrol.ctippro;
                  reg_migprofrol.mig_fk := v_pk_profesional;
                  reg_migprofrol.proceso := x.proceso;

                  --
                  BEGIN
                     INSERT INTO mig_sin_prof_rol
                          VALUES reg_migprofrol
                       RETURNING ROWID
                            INTO v_rowid;

                      INSERT INTO mig_pk_emp_mig
                          VALUES (0, v_ncarga, 82, reg_migprofrol.mig_pk);
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                        NULL;
                  END;
                  --
               ELSIF x.tiporegistro = '83' THEN   --  Persona de contacto del proveedor
                  --
                  INSERT INTO mig_cargas_tab_mig
                                 (ncarga, tab_org, tab_des, ntab)
                          VALUES (v_ncarga, 'INT_CARGA_GENERICO', 'MIG_SIN_PROF_CONTACTOS', 1);

                  v_ntraza := 70110;
                  reg_migprofcontactos := NULL;
                  reg_migprofcontactos.ncarga := v_ncarga;
                  reg_migprofcontactos.cestmig := 1;
                  reg_migprofcontactos.sprofes := reg_migprofesional.sprofes;
                  reg_migprofcontactos.nordcto := x.campo01;
                  reg_migprofcontactos.ctipide := x.campo02;
                  reg_migprofcontactos.cnumide := x.campo03;
                  reg_migprofcontactos.tnombre := x.campo04;
                  reg_migprofcontactos.tmovil   := x.campo05;
                  reg_migprofcontactos.temail := x.campo06;
                  reg_migprofcontactos.tcargo := x.campo07;
                  reg_migprofcontactos.tdirec := x.campo08;
                  reg_migprofcontactos.fbaja := f_chartodate(x.campo09);
                  reg_migprofcontactos.mig_pk :=
                               v_ncarga || '/' || x.nlinea || '/' || reg_migprofesional.sprofes
                               || reg_migprofcontactos.nordcto;
                  reg_migprofcontactos.mig_fk := v_pk_profesional;
                  reg_migprofcontactos.proceso := x.proceso;

                  --
                  BEGIN
                     INSERT INTO mig_sin_prof_contactos
                          VALUES reg_migprofcontactos
                       RETURNING ROWID
                            INTO v_rowid;

                      INSERT INTO mig_pk_emp_mig
                          VALUES (0, v_ncarga, 83, reg_migprofcontactos.mig_pk);
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                        NULL;
                  END;
                  --
               ELSIF x.tiporegistro = '84' THEN   --  Cuentas bancarias del proveedor
                  --
                  INSERT INTO mig_cargas_tab_mig
                                 (ncarga, tab_org, tab_des, ntab)
                          VALUES (v_ncarga, 'INT_CARGA_GENERICO', 'MIG_SIN_PROF_CCC', 1);

                  v_ntraza := 70110;
                  reg_migprofccc := NULL;
                  reg_migprofccc.ncarga := v_ncarga;
                  reg_migprofccc.cestmig := 1;
                  reg_migprofccc.sprofes := reg_migprofesional.sprofes;
                  reg_migprofccc.cnorden := x.campo01;
                  reg_migprofccc.cramo := x.campo02;
                  reg_migprofccc.sproduc := x.campo03;
                  reg_migprofccc.cactivi := x.campo04;
                  reg_migprofccc.ctipban := x.campo05;
                  reg_migprofccc.cbancar := x.campo06;
                  reg_migprofccc.fbaja := f_chartodate(x.campo07);

                  reg_migprofccc.mig_pk :=
                               v_ncarga || '/' || x.nlinea || '/' || reg_migprofesional.sprofes
                               || reg_migprofccc.cnorden;
                  reg_migprofccc.mig_fk := v_pk_profesional;
                  reg_migprofccc.proceso := x.proceso;

                  --
                  BEGIN
                     INSERT INTO mig_sin_prof_ccc
                          VALUES reg_migprofccc
                       RETURNING ROWID
                            INTO v_rowid;

                      INSERT INTO mig_pk_emp_mig
                          VALUES (0, v_ncarga, 84, reg_migprofccc.mig_pk);
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                        NULL;
                  END;
                  --
               ELSIF x.tiporegistro = '89' THEN   --  Representante legal
                  --
                    --
                    INSERT INTO mig_cargas_tab_mig
                                   (ncarga, tab_org, tab_des, ntab)
                            VALUES (v_ncarga, 'INT_CARGA_GENERICO', 'MIG_SIN_PROF_REPRE', 1);

                    v_ntraza := 70110;
                    reg_migprofrepre := NULL;
                    reg_migprofrepre.ncarga := v_ncarga;
                    reg_migprofrepre.cestmig := 1;
                    reg_migprofrepre.sprofes := reg_migprofesional.sprofes;
                    reg_migprofrepre.idperson := x.campo01;
                    reg_migprofrepre.ctipide := x.campo02;
                    reg_migprofrepre.nnumide := x.campo03;
                    reg_migprofrepre.TDIGITOIDE :=  x.campo04;
                    reg_migprofrepre.tcargo := x.campo05;
                    reg_migprofrepre.fbaja := f_chartodate(x.campo06);

                    reg_migprofrepre.mig_pk :=
                                 v_ncarga || '/' || reg_migprofrepre.ctipide
                                 || '/' || reg_migprofrepre.nnumide;
                    reg_migprofrepre.mig_fk := v_pk_profesional;
                    reg_migprofrepre.proceso := x.proceso;

                    --
                    BEGIN

                      INSERT INTO mig_cargas_tab_mig
                                   (ncarga, tab_org, tab_des, ntab)
                            VALUES (v_ncarga, 'INT_CARGA_GENERICO', 'MIG_PERSONAS_REL', 1);

                       INSERT INTO MIG_PERSONAS_REL(NCARGA, CESTMIG, MIG_PK, MIG_FK, FKREL, CTIPREL)
                            VALUES(v_ncarga,1, reg_migprofrepre.mig_pk ,reg_migprofrepre.mig_fk,  reg_migprofrepre.mig_pk, 1);

                       INSERT INTO mig_sin_prof_repre
                            VALUES reg_migprofrepre
                         RETURNING ROWID
                              INTO v_rowid;

                        INSERT INTO mig_pk_emp_mig
                            VALUES (0, v_ncarga, 89, reg_migprofrepre.mig_pk);
                    EXCEPTION
                       WHEN DUP_VAL_ON_INDEX THEN
                          NULL;
                    END;
            ELSIF x.tiporegistro = '90' THEN   --  sede del proveedor

                    --
                    INSERT INTO mig_cargas_tab_mig
                                   (ncarga, tab_org, tab_des, ntab)
                            VALUES (v_ncarga, 'INT_CARGA_GENERICO', 'MIG_SIN_PROF_SEDE', 1);

                    v_ntraza := 70110;
                    reg_migprofsede := NULL;
                    reg_migprofsede.ncarga := v_ncarga;
                    reg_migprofsede.cestmig := 1;
                    reg_migprofsede.sprofes := reg_migprofesional.sprofes;
                    reg_migprofsede.idperson := x.campo01;
                    reg_migprofsede.ctipide := x.campo02;
                    reg_migprofsede.nnumide := x.campo03;
                    reg_migprofsede.TDIGITOIDE :=  x.campo04;
                    reg_migprofsede.thorari := x.campo05;
                    reg_migprofsede.tpercto := x.campo06;
                    reg_migprofsede.fbaja := f_chartodate(x.campo07);

                    reg_migprofsede.mig_pk :=
                                 v_ncarga || '/' || reg_migprofsede.ctipide
                                 || '/' || reg_migprofsede.nnumide;
                    reg_migprofsede.mig_fk := v_pk_profesional;
                    reg_migprofsede.proceso := x.proceso;

                    --
                    BEGIN

                       INSERT INTO mig_cargas_tab_mig
                                   (ncarga, tab_org, tab_des, ntab)
                            VALUES (v_ncarga, 'INT_CARGA_GENERICO', 'MIG_PERSONAS_REL', 1);

                       INSERT INTO MIG_PERSONAS_REL(NCARGA, CESTMIG, MIG_PK, MIG_FK, FKREL, CTIPREL)
                            VALUES(v_ncarga,1, reg_migprofsede.mig_pk ,reg_migprofsede.mig_fk,  reg_migprofsede.mig_pk, 2);

                       INSERT INTO mig_sin_prof_sede
                            VALUES reg_migprofsede
                         RETURNING ROWID
                              INTO v_rowid;

                        INSERT INTO mig_pk_emp_mig
                            VALUES (0, v_ncarga, 90, reg_migprofsede.mig_pk);
                    EXCEPTION
                       WHEN DUP_VAL_ON_INDEX THEN
                          NULL;
                    END;
                    --

                  --

                  --
               ELSIF x.tiporegistro = '85' THEN   --  Estado del proveedor
                  --
                  INSERT INTO mig_cargas_tab_mig
                                 (ncarga, tab_org, tab_des, ntab)
                          VALUES (v_ncarga, 'INT_CARGA_GENERICO', 'MIG_SIN_PROF_ESTADOS', 1);

                  v_ntraza := 70110;
                  reg_migprofestados := NULL;
                  reg_migprofestados.ncarga := v_ncarga;
                  reg_migprofestados.cestmig := 1;
                  reg_migprofestados.sprofes := reg_migprofesional.sprofes;
                  reg_migprofestados.cestado := x.campo01;
                  reg_migprofestados.festado := f_chartodate(x.campo02);
                  reg_migprofestados.cmotbaj := x.campo03;
                  reg_migprofestados.tobserv := x.campo04;

                  reg_migprofestados.mig_pk :=
                               v_ncarga || '/' || x.nlinea || '/' || reg_migprofesional.sprofes
                               || reg_migprofestados.cestado;
                  reg_migprofestados.mig_fk := v_pk_profesional;
                  reg_migprofestados.proceso := x.proceso;

                  --
                  BEGIN
                     INSERT INTO mig_sin_prof_estados
                          VALUES reg_migprofestados
                       RETURNING ROWID
                            INTO v_rowid;

                      INSERT INTO mig_pk_emp_mig
                          VALUES (0, v_ncarga, 90, reg_migprofestados.mig_pk);
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                        NULL;
                  END;
                  --
               ELSIF x.tiporegistro = '86' THEN   --  Zona geogr¿fica en la que act¿a el proveedor
                  --
                  INSERT INTO mig_cargas_tab_mig
                                 (ncarga, tab_org, tab_des, ntab)
                          VALUES (v_ncarga, 'INT_CARGA_GENERICO', 'MIG_SIN_PROF_ZONAS', 1);

                  v_ntraza := 70110;
                  reg_migprofzonas := NULL;
                  reg_migprofzonas.ncarga := v_ncarga;
                  reg_migprofzonas.cestmig := 1;
                  reg_migprofzonas.sprofes := reg_migprofesional.sprofes;

                  reg_migprofzonas.cnordzn := x.campo01;
                  reg_migprofzonas.ctpzona := x.campo02;
                  reg_migprofzonas.cpais := x.campo03;
                  reg_migprofzonas.cprovin := x.campo04;
                  reg_migprofzonas.cpoblac := x.campo05;
                  reg_migprofzonas.fdesde := f_chartodate(x.campo06);
                  reg_migprofzonas.fhasta := f_chartodate(x.campo07);

                  reg_migprofzonas.mig_pk :=
                               v_ncarga || '/' || x.nlinea || '/' || reg_migprofesional.sprofes
                               || reg_migprofzonas.cnordzn;
                  reg_migprofzonas.mig_fk := v_pk_profesional;
                  reg_migprofzonas.proceso := x.proceso;

                  IF x.campo02 = '3'
                     AND  x.campo05 IS NULL THEN
                     v_tdeserror := 'Se debe informar el codigo de ciudad.';
                     RAISE e_errdatos;
                  END IF;

                  --
                  BEGIN
                     INSERT INTO mig_sin_prof_zonas
                          VALUES reg_migprofzonas
                       RETURNING ROWID
                            INTO v_rowid;

                      INSERT INTO mig_pk_emp_mig
                          VALUES (0, v_ncarga, 91, reg_migprofzonas.mig_pk);
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                        NULL;
                  END;
                  --
               ELSIF x.tiporegistro = '87' THEN   --  Carga de trabajo permitida del proveedor
                  --
                  INSERT INTO mig_cargas_tab_mig
                                 (ncarga, tab_org, tab_des, ntab)
                          VALUES (v_ncarga, 'INT_CARGA_GENERICO', 'MIG_SIN_PROF_CARGA', 1);

                  v_ntraza := 70110;
                  reg_migprofcarga := NULL;
                  reg_migprofcarga.cestmig := 1;
                  reg_migprofcarga.ncarga := v_ncarga;
                  reg_migprofcarga.sprofes := reg_migprofesional.sprofes;

                  reg_migprofcarga.ctippro := x.campo01;
                  reg_migprofcarga.csubpro := x.campo02;
                  reg_migprofcarga.fdesde := f_chartodate(x.campo03);
                  reg_migprofcarga.ncardia := x.campo04;
                  reg_migprofcarga.ncarsem := x.campo05;

                  reg_migprofcarga.mig_pk :=
                               v_ncarga || '/' || x.nlinea || '/' || reg_migprofesional.sprofes
                               || reg_migprofcarga.ctippro;
                  reg_migprofcarga.mig_fk := v_pk_profesional;
                  reg_migprofcarga.proceso := x.proceso;

                  --
                  BEGIN
                     INSERT INTO mig_sin_prof_carga
                          VALUES reg_migprofcarga
                       RETURNING ROWID
                            INTO v_rowid;

                      INSERT INTO mig_pk_emp_mig
                          VALUES (0, v_ncarga, 92, reg_migprofcarga.mig_pk);
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                        NULL;
                  END;
                  --
               ELSIF x.tiporegistro = '88' THEN   --  Observaciones del proveedor
                  --
                  INSERT INTO mig_cargas_tab_mig
                                 (ncarga, tab_org, tab_des, ntab)
                          VALUES (v_ncarga, 'INT_CARGA_GENERICO', 'MIG_SIN_PROF_OBSERVACIONES', 1);

                  v_ntraza := 70110;
                  reg_migprofobservaciones := NULL;
                  reg_migprofobservaciones.cestmig := 1;
                  reg_migprofobservaciones.ncarga := v_ncarga;
                  reg_migprofobservaciones.sprofes := reg_migprofesional.sprofes;

                  reg_migprofobservaciones.cnordcm := x.campo01;
                  reg_migprofobservaciones.tcoment := x.campo02;

                  reg_migprofobservaciones.mig_pk :=
                               v_ncarga || '/' || x.nlinea || '/' || reg_migprofesional.sprofes
                               || reg_migprofobservaciones.cnordcm;
                  reg_migprofobservaciones.mig_fk := v_pk_profesional;
                  reg_migprofobservaciones.proceso := x.proceso;

                  --
                  BEGIN
                     INSERT INTO mig_sin_prof_observaciones
                          VALUES reg_migprofobservaciones
                       RETURNING ROWID
                            INTO v_rowid;

                      INSERT INTO mig_pk_emp_mig
                          VALUES (0, v_ncarga, 93, reg_migprofobservaciones.mig_pk);
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                        NULL;
                  END;
                  --
               ELSE
                  -- no se encuentra el tipo de registro
                  v_nnumerr := 9902907;
                  v_tdeserror := 'El tipo resgistro (campo01): ' || x.tiporegistro || ' '
                                 || 'no parametrizado.';
                  v_nnumerr1 := p_marcalinea(p_ssproces, v_id_linea, v_toperacion, 1, 0, NULL,
                                             v_id, v_ncarga);
                  v_nnumerr := p_marcalineaerror(p_ssproces, v_id_linea, NULL, 1,
                                                 NVL(v_nnumerr, 1), NVL(v_tdeserror, -1));
                  RAISE e_salir;
               END IF;

            ELSE
                --NULL;   -- la dejo como pendiente, viene con de un error
               -- Si llega un registro que no tiene cabecera lo marcamos como warning
               IF v_id IS NULL THEN   -- sino pertenece a ninguna p¿liza
                  v_nnumerr := 9902907;
                  v_tdeserror := 'El tipo registro (tipo registro): ' || x.tiporegistro || ' '
                                 || 'no precede de un tipo registro de persona valido .';
                  v_nnumerr := p_marcalinea(p_ssproces, v_id_linea, v_toperacion, 2, 0, NULL,
                                            v_id, v_ncarga, NULL, NULL, NULL, NULL,
                                            x.nlinea || '(' || x.tiporegistro || ')');
                  v_nnumerr := p_marcalineaerror(p_ssproces, v_id_linea, NULL, 2,
                                                 NVL(v_nnumerr, 1), NVL(v_tdeserror, -1));
               END IF;
--
            END IF;   -- v_toperacion

            v_ntraza := 70090;
         EXCEPTION
            WHEN e_errdatos THEN
               ROLLBACK;
               v_berrorproc := TRUE;
               v_nnumerr := f_marcar_lineas(p_ssproces, v_ncarga, 1,   -- pongo error
                                            v_toperacion, NVL(v_nnumerr, 1),
                                            NVL(v_ntraza || '-' || v_tdeserror, -1), NULL,
                                            x.nlinea, NULL, NULL, NULL);

               IF k_cpara_error <> 1 THEN
                  v_ntipoerror := 4;
               -- para que continue con la siguiente linea.
               ELSE
                  v_ntipoerror := 1;   -- para la carga
                  RAISE e_salir;
               END IF;
            -- debo obviar todas las lineas hasta la siguiente linea 1
            WHEN e_salir THEN   -- salgo del cursor
               RAISE;
            WHEN OTHERS THEN
               v_nnumerr := SQLCODE;
               v_tdeserror := v_ntraza || ' en f_pol_ejecutar_carga_proceso -' || SQLERRM;
               ROLLBACK;
               v_berrorproc := TRUE;
               v_nnumerr := f_marcar_lineas(p_ssproces, v_ncarga, 1,   -- pongo error
                                            v_toperacion, v_nnumerr, v_tdeserror, NULL,
                                            x.nlinea, NULL, NULL, NULL);

               IF k_cpara_error <> 1 THEN
                  v_ntipoerror := 4;
               -- para que continue con la siguiente linea.
               ELSE
                  v_ntipoerror := 1;   -- para la carga
                  RAISE e_salir;
               END IF;
         END;
      END LOOP;

      v_ntraza := 70500;

      IF v_id IS NOT NULL
         AND v_ntipoerror NOT IN(1, 4) THEN
         -- lanza la ultima migraci¿n, cuando acaba el fichero
         IF v_toperacion = 'PROF' THEN

            v_nnumerr := f_lanza_migracion_prof(v_id, v_ncarga);
         END IF;

         IF v_nnumerr NOT IN(0, 2, 4) THEN   -- si ha habido error
            v_berrorproc := TRUE;
            ROLLBACK;
         ELSE
            COMMIT;
         END IF;
      END IF;

      v_ntraza := 70999;

-------------------------------- final loop ------------------------------------
-- COMMIT;
      IF v_berrorproc THEN
         RETURN 1;
      ELSIF v_bavisproc THEN
         RETURN 2;
      ELSE
         RETURN 4;
      END IF;
   EXCEPTION
      WHEN e_salir THEN
         ROLLBACK;
         RETURN 1;
      -- Fi Bug 16324
      WHEN OTHERS THEN
         v_nnumerr := SQLCODE;
         v_tdeserror := v_ntraza || ' en f_per_ejecutar_carga_proceso: ' || SQLERRM;
         ROLLBACK;
         v_nnumerr1 := p_marcalinea(p_ssproces, v_id_linea, 0, 1, 0, NULL, v_id, v_ncarga);
         v_nnumerr := p_marcalineaerror(p_ssproces, v_id_linea, NULL, 1, v_nnumerr,
                                        v_tdeserror);
         p_genera_logs(v_tobjeto, v_ntraza, 'Error Incontrolado:' || v_nnumerr, v_tdeserror);
         RETURN 1;
   END f_prof_ejecutar_carga_proceso;

   FUNCTION f_prof_ejecutar_carga(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER,
      pjob IN NUMBER DEFAULT 0,
      pcusuari IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'pac_cargas_generico.f_prof_ejecutar_carga';
      vtraza         NUMBER := 0;
      vnum_err       NUMBER := 0;
      vsalir         EXCEPTION;
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

      vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces, p_nombre, f_sysdate,
                                                                 NULL, 3,
                                                                 p_cproces, NULL, NULL, 1);
      IF vnum_err <> 0 THEN
         p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                     'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera', 10);
         RAISE vsalir;
      END IF;

      pac_contexto.p_contextoasignaparametro('DEBUG', NVL(k_cdebug, 99));
      vnum_err := f_prof_ejecutar_carga_proceso(psproces);

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
   END f_prof_ejecutar_carga;

   FUNCTION f_prof_ejecutar_carga_job(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER)
      RETURN NUMBER IS
      vmensaje       NUMBER;
      vnum_err       NUMBER;
   BEGIN
     p_control_error(1,'psproces', psproces);
      IF psproces IS NULL THEN
         SELECT sproces.NEXTVAL
           INTO psproces
           FROM DUAL;

         vmensaje :=
            pac_jobs.f_ejecuta_job
                           (NULL,
                            'declare nerror number; vsproces number := ' || psproces
                            || '; begin nerror := pac_cargas_generico.f_prof_ejecutar_carga('''
                            || p_nombre || ''',''' || p_path || ''',' || p_cproces
                            || ', vsproces, 1,''' || f_user || '''); end;',
                            NULL);

         IF vmensaje > 0 THEN
            RETURN 180856;
         END IF;

         RETURN 9901606;
      ELSE
         vnum_err := f_prof_ejecutar_carga(p_nombre, p_path, p_cproces,
                                           psproces);
         RETURN vnum_err;
      END IF;

      RETURN 0;
   END f_prof_ejecutar_carga_job;

   /*************************************************************************
       Procedimiento que ejecuta  carga de profesionales.
       param in p_ssproces   : N¿mero proceso
       retorna 0 si ha ido bien, 1 en casos contrario
   *************************************************************************/

   FUNCTION f_reser_ejecutar_carga_proceso(p_ssproces IN NUMBER)
      RETURN NUMBER IS
      v_tobjeto      VARCHAR2(100) := 'pac_cargas_generico.f_reser_ejecutar_carga_proceso ';
      v_ntraza       NUMBER := 0;
      e_salir        EXCEPTION;
      mensajes       t_iax_mensajes;

      CURSOR cur_pagos(p_ssproces2 IN NUMBER) IS
         SELECT   a.*
             FROM int_carga_generico a
            WHERE proceso = p_ssproces2
              AND NOT EXISTS(SELECT 1
                               FROM int_carga_ctrl_linea b
                              WHERE b.sproces = a.proceso
                                AND b.nlinea = a.nlinea
                                AND b.cestado IN(2, 4, 5, 6))
         ORDER BY nlinea, tiporegistro;

      v_id_linea     int_carga_generico.nlinea%TYPE;


      CURSOR cur_persona(pnnumide VARCHAR2) IS
         SELECT SPERSON FROM  PER_PERSONAS
              WHERE NNUMIDE = pnnumide;


       CURSOR cur_reservas(pnsinies VARCHAR2, pntranit NUMBER, ctippres NUMBER) IS
         --IAXIS 7654 AABC MODIFICACION DE PARAMETROS PARA AJUSTE DE CONSULTA
         SELECT ST.NMOVRES, ST.CGARANT, ST.CMONRES, ST.CMOVRES, ST.IDRES, ST.IRESERVA
             FROM SIN_TRAMITA_RESERVA ST
             WHERE ST.NMOVRES = (SELECT MAX(str2.nmovres)
                                   FROM sin_tramita_reserva str2
                                    WHERE str2.nsinies   = ST.nsinies
                                    AND str2.ntramit = ST.ntramit
                                    AND str2.ctipres = ST.ctipres
                                    AND str2.cgarant = ST.cgarant
                                   )
           AND ST.NSINIES = pnsinies
           AND ST.NTRAMIT = pntranit
           AND ST.CTIPRES = ctippres
           AND st.ireserva > 0;
	   --IAXIS 7654 AABC MODIFICACION DE PARAMETROS PARA AJUSTE DE CONSULTA


       sperson_agencia NUMBER;
       sperson_aero NUMBER;
       vnmovres NUMBER;
       vcgarant NUMBER;
       vcmonres VARCHAR2(3) := NULL;
       --IAXIS 7654 AABC MODIFICACION DE PARAMETROS PARA AJUSTE DE CONSULTA
       vcmovres NUMBER; 
       vidres   NUMBER;
       --
       vcmonpag  VARCHAR2(3) := 'COP';
       v_fcambio      DATE;
       v_itasa   NUMBER; 
       v_isinret_aero NUMBER;
       v_iiva_aero    NUMBER;
       v_iotros_aero  NUMBER;
       v_total_aero   NUMBER;
       v_isinret_agen NUMBER;
       v_iiva_agen    NUMBER;
       v_total_agen   NUMBER;
       v_ireserva     NUMBER;
       v_ipagototal   NUMBER;
       --IAXIS 7654 AABC MODIFICACION DE PARAMETROS PARA AJUSTE DE CONSULTA

      BEGIN

      FOR x IN cur_pagos(p_ssproces) LOOP
          BEGIN
             --IAXIS-4555 AABC 14-02-2020 Cambios de persona
             sperson_agencia := NULL;
             sperson_aero    := NULL;
             --IAXIS-4555 AABC 14-02-2020 Cambios de persona
             OPEN cur_persona(x.CAMPO06);
              FETCH cur_persona INTO sperson_agencia;
             CLOSE cur_persona;

             OPEN cur_persona(x.CAMPO07);
              FETCH cur_persona INTO sperson_aero;
             CLOSE cur_persona;

             IF sperson_agencia IS NULL THEN
                v_nnumerr := 2;
                RAISE e_salir;
             END IF;

             IF sperson_aero IS NULL THEN
                v_nnumerr := 3;
                RAISE e_salir;
             END IF;

             --IAXIS 7654 AABC MODIFICACION DE PARAMETROS PARA AJUSTE DE CONSULTA
             OPEN cur_reservas(x.CAMPO02, x.CAMPO03, x.CAMPO04);
              FETCH cur_reservas INTO vnmovres, vcgarant, vcmonres, vcmovres ,vidres,v_ireserva;

              IF cur_reservas%NOTFOUND THEN
                v_nnumerr := 4;
				CLOSE cur_reservas;
                RAISE e_salir;
              END IF;
             CLOSE cur_reservas;
             --IAXIS-4555 AABC cambios en proceso masivo por diferente moneda
             IF vcmonres <> vcmonpag THEN --f_sysdate
                --
                v_fcambio := pac_eco_tipocambio.f_fecha_max_cambio(vcmonres, vcmonpag,f_sysdate);
                v_itasa        := pac_eco_tipocambio.f_cambio(vcmonres, vcmonpag, v_fcambio);
                v_isinret_aero := f_round((x.CAMPO11 / v_itasa),pac_monedas.f_cmoneda_n(vcmonres));
                v_iiva_aero    := f_round((x.CAMPO13 / v_itasa),pac_monedas.f_cmoneda_n(vcmonres));
                v_iotros_aero  := f_round((x.CAMPO14 / v_itasa),pac_monedas.f_cmoneda_n(vcmonres));
                v_total_aero   := v_isinret_aero + v_iiva_aero + v_iotros_aero;
                v_isinret_agen := f_round((x.CAMPO16 / v_itasa),pac_monedas.f_cmoneda_n(vcmonres));
                v_iiva_agen    := f_round((x.CAMPO17 / v_itasa),pac_monedas.f_cmoneda_n(vcmonres));
                v_total_agen   := v_isinret_agen + v_iiva_agen;
                --
             ELSE 
                --
                v_isinret_aero := x.campo11;
                v_iiva_aero    := x.campo13;
                v_iotros_aero  := x.campo14;
                v_total_aero   := x.campo15;
                v_isinret_agen := x.campo16;
                v_iiva_agen    := x.campo18;
                v_total_agen   := x.campo19;               
                --   
             END IF;
             --IAXIS-4555 AABC cambios en proceso masivo por diferente moneda
             v_ipagototal := v_isinret_aero + v_isinret_agen;
             --
             IF v_ireserva > v_ipagototal THEN
                -- 
             v_id_linea := v_id_linea + 1;
                v_nnumerr := pac_md_siniestros.f_pagos_avion(x.CAMPO02, x.CAMPO03, vnmovres, x.CAMPO04, x.CAMPO05, vcgarant, 
                                                             vcmonres, x.CAMPO06, sperson_agencia, x.CAMPO07, sperson_aero,
                                                             x.CAMPO08, to_date(x.CAMPO09, 'dd/mm/yyyy'), x.CAMPO10, v_isinret_aero , 
                                                             x.CAMPO12, v_iiva_aero, v_iotros_aero, v_total_aero, v_isinret_agen, 
                                                             x.CAMPO17, v_iiva_agen , v_total_agen , x.CAMPO20,x.CAMPO21, vcmovres, 
                                                             vidres,  mensajes);
             --IAXIS 7654 AABC MODIFICACION DE PARAMETROS PARA AJUSTE DE CONSULTA 
             IF v_nnumerr != 0 THEN
                  --
              IF mensajes IS NOT NULL THEN
                    --
                  FOR i IN mensajes.FIRST .. mensajes.LAST LOOP
                      --
                     v_tdeserror := mensajes(i).terror;
                     v_nnumerr := mensajes(i).cerror;
                      --
                  END LOOP;
                    --
               END IF;
               /* Cambios de IAXIS-3420 - start */
               v_nnumerr := pac_gestion_procesos.f_set_carga_ctrl_linea(p_ssproces, x.CAMPO01,
                                                                           1,
                                                                           v_nnumerr ||' - '|| v_tdeserror,
                                                                           NULL, 1, 0, NULL,
                                                                           x.CAMPO02, NULL, x.CAMPO02,
                                                                           NULL, NULL, NULL);

             ELSE
                  -- 
              v_nnumerr := pac_gestion_procesos.f_set_carga_ctrl_linea(p_ssproces, x.CAMPO01,
                                                                           1,
                                                                           'Pago realizao - '|| x.CAMPO08,
                                                                           NULL, 4, 0, NULL,
                                                                           x.CAMPO02, NULL,  x.CAMPO02,
                                                                           NULL, NULL, NULL);
               /* Cambios de IAXIS-3420 - end */
             END IF;
                --  
             END IF;   
             --
             EXCEPTION WHEN e_salir THEN
                --
                     IF v_nnumerr = 2 OR v_nnumerr = 3 THEN
                   --
                                 v_tdeserror := v_ntraza || ' ERROR buscando agencias: ' || SQLERRM;
                   --
                     END IF;
                --   
                     IF v_nnumerr = 4 THEN
                   --
                                 v_tdeserror := v_ntraza || ' ERROR no se encuentran reservas: ' || SQLERRM;
                   --
                     END IF;

			/* Cambios de IAXIS-3420 - start */
                    v_nnumerr := pac_gestion_procesos.f_set_carga_ctrl_linea(p_ssproces, x.CAMPO01,
                                                                           1,
                                                                           v_nnumerr ||' - '|| v_tdeserror,
                                                                           NULL, 1, 0, NULL,
                                                                           x.CAMPO02, NULL, x.CAMPO02,
                                                                           NULL, NULL, NULL);
			/* Cambios de IAXIS-3420 - end */   																		   
          END;

     END LOOP;

   RETURN 0;

  EXCEPTION
      WHEN OTHERS THEN
         v_nnumerr := SQLCODE;
         v_tdeserror := v_ntraza || ' en f_reser_ejecutar_carga_proceso: ' || SQLERRM;
         ROLLBACK;
         v_nnumerr := p_marcalineaerror(p_ssproces, v_id_linea, NULL, 1, v_nnumerr,
                                        v_tdeserror);
         p_genera_logs(v_tobjeto, v_ntraza, 'Error Incontrolado:' || v_nnumerr, v_tdeserror);
         RETURN 1;
   END f_reser_ejecutar_carga_proceso;

   FUNCTION f_reserva_ejecutar_carga(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER,
      pjob IN NUMBER DEFAULT 0,
      pcusuari IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'pac_cargas_generico.f_reserva_ejecutar_carga';
      vtraza         NUMBER := 0;
      vnum_err       NUMBER := 0;
      vsalir         EXCEPTION;
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

  /* Cambios de IAXIS-3420 - start */         
      /*     
      IF psproces IS NULL
         OR(psproces IS NOT NULL
            AND pjob = 1) THEN
         vnum_err := f_ejecutar_carga_fichero(p_nombre, p_path, p_cproces, psproces);
         IF vnum_err <> 0 THEN
            RAISE vsalir;
         END IF;
      END IF;
      */
    /* Cambios de IAXIS-3420 - end */   
      vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces, p_nombre, f_sysdate,
                                                                 NULL, 3,
                                                                 p_cproces, NULL, NULL, 1);
      IF vnum_err <> 0 THEN

         p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                     'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera', 20);
         RAISE vsalir;
      END IF;

      pac_contexto.p_contextoasignaparametro('DEBUG', NVL(k_cdebug, 99));
      
      /* Cambios de IAXIS-3420 - start */  
      IF psproces IS NOT NULL THEN
         vnum_err := f_ejecutar_carga_fichero(p_nombre, p_path, p_cproces, psproces);
         IF vnum_err <> 0 THEN
            RAISE vsalir;
         END IF;
      END IF;
      /* Cambios de IAXIS-3420 - end */

      vnum_err := f_reser_ejecutar_carga_proceso(psproces);
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
   END f_reserva_ejecutar_carga;

  FUNCTION f_reserva_ejecutar_carga_job(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER)
      RETURN NUMBER IS
      vmensaje       NUMBER;
      vnum_err       NUMBER;
   BEGIN
   /* Cambios de IAXIS-3420 - start */
    -- p_control_error(1,'psproces', psproces);
   /* Cambios de IAXIS-3420 - end */  
   
      IF psproces IS NULL THEN
         SELECT sproces.NEXTVAL
           INTO psproces
           FROM DUAL;

    /* Cambios de IAXIS-3420 - start */
       /*      
         vmensaje :=
            pac_jobs.f_ejecuta_job
                           (NULL,
                            'declare nerror number; vsproces number := ' || psproces
                            || '; begin nerror := pac_cargas_generico.f_reserva_ejecutar_carga('''
                            || p_nombre || ''',''' || p_path || ''',' || p_cproces
                            || ', vsproces, 1,''' || f_user || '''); end;',
                            NULL);

         IF vmensaje > 0 THEN
            RETURN 180856;
         END IF;

         RETURN 9901606;
      ELSE
    */
   /* Cambios de IAXIS-3420 - end */
   
         vnum_err := f_reserva_ejecutar_carga(p_nombre, p_path, p_cproces,
                                           psproces);
         RETURN vnum_err;
      END IF;

      RETURN 0;
   END f_reserva_ejecutar_carga_job;
   

/* Cambios de IAXIS-3650 :start */   


FUNCTION F_MODI_DATOS_INFORME_EXT(P_NOMBRE VARCHAR2, P_PATH IN VARCHAR2)
  RETURN NUMBER IS
  V_TNOMFICH VARCHAR2(100);
BEGIN
  V_TNOMFICH := SUBSTR(P_NOMBRE, 1, INSTR(P_NOMBRE, '.') - 1);

  EXECUTE IMMEDIATE 'ALTER TABLE DATOS_INFORME_COMITE_EXT ACCESS PARAMETERS (RECORDS DELIMITED BY 0X''0A''
                       LOGFILE ' || CHR(39) ||
                    V_TNOMFICH || '.LOG' || CHR(39) || '
                       BADFILE ' || CHR(39) ||
                    V_TNOMFICH || '.BAD' || CHR(39) || '
                       DISCARDFILE ' || CHR(39) ||
                    V_TNOMFICH || '.DIS' || CHR(39) || '
                       FIELDS TERMINATED BY ''|'' LRTRIM
                       MISSING FIELD VALUES ARE NULL
                       REJECT ROWS WITH ALL NULL FIELDS
                       ( 
                            NSINIES, 
                            NTRAMIT, 
                            CTIPRES, 
                            TTIPRES, 
                            NMOVRES, 
                            CGARANT, 
                            CCALRES, 
                            FMOVRES, 
                            CMONRES, 
                            IRESERVA, 
                            IPAGO, 
                            IINGRESO, 
                            IRECOBRO, 
                            ICAPRIE, 
                            IPENALI, 
                            FRESINI, 
                            FRESFIN, 
                            FULTPAG, 
                            SIDEPAG, 
                            SPROCES, 
                            FCONTAB, 
                            IPREREC, 
                            CTIPGAS, 
                            MODO, 
                            TORIGEN, 
                            IFRANQ, 
                            NDIAS, 
                            CMOVRES, 
                            ITOTIMP, 
                            PIVA, 
                            PPRETENC, 
                            PRETEIVA, 
                            PRETEICA, 
                            IVA_CTIPIND, 
                            RETENC_CTIPIND, 
                            RETEIVA_CTIPIND, 
                            RETEICA_CTIPIND, 
                            ITOTRET, 
                            CSOLIDARIDAD
                       ))';
  EXECUTE IMMEDIATE 'ALTER TABLE DATOS_INFORME_COMITE_EXT LOCATION (' ||
                    P_PATH || ':''' || P_NOMBRE || ''')';
  RETURN 0;
EXCEPTION
  WHEN OTHERS THEN
    P_TAB_ERROR(F_SYSDATE,
                F_USER,
                'pac_cargas_generico.F_MODI_DATOS_INFORME_EXT',
                1,
                'Error creando la tabla.',
                SQLERRM);
    RETURN 107914;
END F_MODI_DATOS_INFORME_EXT;

function P_TRASP_DATOS_INFORME(PDESERROR OUT VARCHAR2, PSPROCES IN NUMBER) 
        RETURN NUMBER IS
  NUM_ERR   NUMBER;
  V_PASEXEC NUMBER := 1;
  VOBJ      VARCHAR2(200) := 'pac_cargas_generico.P_TRASP_DATOS_INFORME';

  V_IDCARGA    NUMBER := 0;
  V_DESC_CARGA VARCHAR2(50) := NULL;
  V_NUMLIN         DATOS_INFORME_COMITE.NLINEA%TYPE;

BEGIN
  V_PASEXEC := 0;
  PDESERROR := NULL;

  SELECT NVL(MAX(ID_CARGA + 1), 1)
    INTO V_IDCARGA
    FROM DATOS_INFORME_COMITE;

  SELECT NVL(MAX(NLINEA), 0)
    INTO V_NUMLIN
    FROM DATOS_INFORME_COMITE
   WHERE PROCESO = PSPROCES;

  V_DESC_CARGA := 'CARGA DATOS INFORME COMITE';
  V_PASEXEC := 1;
  INSERT INTO DATOS_INFORME_COMITE
    (SELECT PSPROCES,
            ROWNUM + V_NUMLIN,
            V_IDCARGA,
            V_DESC_CARGA,
            F_SYSDATE,
            NSINIES,
            NTRAMIT,
            CTIPRES,
            TTIPRES,
            NMOVRES,
            CGARANT,
            CCALRES,
            FMOVRES,
            CMONRES,
            IRESERVA,
            IPAGO,
            IINGRESO,
            IRECOBRO,
            ICAPRIE,
            IPENALI,
            FRESINI,
            FRESFIN,
            FULTPAG,
            SIDEPAG,
            SPROCES,
            FCONTAB,
            IPREREC,
            CTIPGAS,
            MODO,
            TORIGEN,
            IFRANQ,
            NDIAS,
            CMOVRES,
            ITOTIMP,
            PIVA,
            PPRETENC,
            PRETEIVA,
            PRETEICA,
            IVA_CTIPIND,
            RETENC_CTIPIND,
            RETEIVA_CTIPIND,
            RETEICA_CTIPIND,
            ITOTRET,
            CSOLIDARIDAD
       FROM DATOS_INFORME_COMITE_EXT);
  V_PASEXEC := 2;
  NUM_ERR := 0;
  return NUM_ERR;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    PDESERROR := F_AXIS_LITERALES(103187, K_CIDIOMA) || SQLERRM;
    P_TAB_ERROR(F_SYSDATE, F_USER, VOBJ, V_PASEXEC, SQLCODE, SQLERRM, 10);
    NUM_ERR := 1;
    return NUM_ERR;    
END P_TRASP_DATOS_INFORME;

-------------------------------------------------------------------------------------

FUNCTION F_CARGA_PROCESO_INFORME(PRUTA IN VARCHAR2,
                                   PSPROCES IN NUMBER)
      RETURN NUMBER IS
    V_TOBJETO VARCHAR2(100) := 'pac_cargas_generico.f_carga_proceso_informe';
    V_NTRAZA  NUMBER := 0;
    E_SALIR EXCEPTION;
    MENSAJES T_IAX_MENSAJES;
    V_NUM_LIN DATOS_INFORME_COMITE.NLINEA%TYPE;

    VCOUNTDIC  number:=0;
    VNOMBRECARGARDIC VARCHAR2(500);
    VCARGARDIC       UTL_FILE.FILE_TYPE;
    VLINEA           VARCHAR2(200);

    VPARAM   VARCHAR2(4000) := 'parametros - Cargar Informe Comite : ';
    VOBJECT  VARCHAR2(200)  := 'pac_cargas_generico.F_CARGA_PROCESO_INFORME';

    vobsini     ob_iax_siniestros := ob_iax_siniestros();
    vireserva   sin_tramita_reserva.ireserva%type;
    vnmovres    sin_tramita_reserva.nmovres%type;
    
    vvalor      number:=0;
   CURSOR CUR_CARGAR_INFROME_COMITE IS
      SELECT * FROM DATOS_INFORME_COMITE_EXT;

  BEGIN

    v_ntraza := 1;
    SELECT COUNT(*) INTO VCOUNTDIC FROM DATOS_INFORME_COMITE_EXT;
    DBMS_OUTPUT.PUT_LINE('VCOUNTDIC ::' || VCOUNTDIC);

    VNOMBRECARGARDIC := 'CARGAR_INFORME_COMITE_MAL_DATAO_' ||
                        TO_CHAR(F_SYSDATE, 'yyyymmdd_hh24miss') || '.txt';
    VCARGARDIC       := UTL_FILE.FOPEN(PRUTA, VNOMBRECARGARDIC, 'w');
    VLINEA           := 'SINIESTROS|DESCRIPCION';

    UTL_FILE.PUT_LINE(VCARGARDIC, VLINEA);
    v_ntraza := 2;
    IF VCOUNTDIC > 0 THEN      
      FOR I IN CUR_CARGAR_INFROME_COMITE LOOP
        V_NUM_LIN := V_NUM_LIN + 1;
          begin    
          v_ntraza := 3;        

          V_NNUMERR := PAC_IAX_SINIESTROS.F_INICIALIZASINIESTRO(NULL,
                                                                NULL,
                                                                I.NSINIES,
                                                                MENSAJES);        

         IF V_NNUMERR = 0 THEN  
            begin
            v_ntraza := 4;     

              BEGIN
                select r.ireserva,r.nmovres
                  INTO VIRESERVA,VNMOVRES
                  from sin_tramita_reserva r
                 where r.nsinies = I.nsinies
                   and r.ctipres = I.ctipres
                   and r.idres = (select max(i1.idres)
                                    from sin_tramita_reserva i1
                                   where i1.nsinies = I.nsinies
                                     and i1.ctipres = I.ctipres)
                   and r.nmovres = (select max(i2.nmovres)
                                      from sin_tramita_reserva i2
                                     where i2.nsinies = I.nsinies
                                       and i2.ctipres = I.ctipres);
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  VIRESERVA := NULL;
                  VNMOVRES := NULL; 
              END;
              
               if vireserva is not null then
                 vvalor := vireserva + I.ireserva;
               else
                 vvalor := I.ireserva;  
               end if;
                V_NNUMERR := PAC_IAX_SINIESTROS.F_SET_OBJETO_SINTRAMIRESERVA(I.nsinies, 
                                                                 nvl(to_number(I.ntramit),null), 
                                                                 nvl(to_number(I.ctipres),null), 
                                                                 I.ttipres, 
                                                                 VNMOVRES, 
                                                                 nvl(to_number(I.cgarant),null), 
                                                                 nvl(to_number(I.ccalres),null), 
                                                                 nvl(TO_DATE(I.fmovres,'dd/mm/yyyy'),null), 
                                                                 I.cmonres, 
                                                                 nvl(to_number(vvalor),null), 
                                                                 nvl(to_number(I.ipago),null),
                                                                 nvl(to_number(I.iingreso),null),
                                                                 nvl(to_number(I.irecobro),null), 
                                                                 nvl(to_number(I.icaprie),null),
                                                                 nvl(to_number(I.ipenali),null), 
                                                                 nvl(TO_DATE(I.fresini,'dd/mm/yyyy'),null),
                                                                 nvl(TO_DATE(I.fresfin,'dd/mm/yyyy'),null),
                                                                 nvl(TO_DATE(I.fultpag,'dd/mm/yyyy'),null),
                                                                 nvl(to_number(I.sidepag),null), 
                                                                 nvl(to_number(I.sproces),null),
                                                                 nvl(TO_DATE(I.fcontab,'dd/mm/yyyy'),null), 
                                                                 nvl(to_number(I.iprerec),null),
                                                                 nvl(to_number(I.ctipgas),null), 
                                                                 I.modo, 
                                                                 I.torigen, 
                                                                 nvl(to_number(I.ifranq),null), 
                                                                 nvl(to_number(I.ndias),null),
                                                                 nvl(to_number(2),null), 
                                                                 nvl(to_number(I.itotimp),null), 
                                                                 MENSAJES,
                                                                 nvl(to_number(I.piva),null), 
                                                                 nvl(to_number(I.ppretenc),null), 
                                                                 nvl(to_number(I.preteiva),null),
                                                                 nvl(to_number(I.preteica),null),
                                                                 nvl(to_number(I.iva_ctipind),null), 
                                                                 nvl(to_number(I.retenc_ctipind),null), 
                                                                 nvl(to_number(I.reteiva_ctipind),null), 
                                                                 nvl(to_number(I.reteica_ctipind),null),
                                                                 nvl(to_number(I.itotret),null),
                                                                 nvl(to_number(I.csolidaridad),null)
                                                                 );
            v_ntraza := 5;                                                                       
           IF V_NNUMERR != 0 THEN
               IF MENSAJES IS NOT NULL THEN
                  FOR i IN mensajes.FIRST .. mensajes.LAST LOOP
                     v_tdeserror := mensajes(i).terror;
                     v_nnumerr := mensajes(i).cerror;

                  END LOOP;
               END IF;
               v_nnumerr := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces, V_NUM_LIN,
                                                                        1,
                                                                        v_nnumerr ||' - '|| v_tdeserror,
                                                                        NULL, 1, 0, NULL,
                                                                        I.nsinies, I.ntramit,null,
                                                                        NULL, NULL, NULL);
                VLINEA := I.nsinies || '|' || v_tdeserror;
                UTL_FILE.PUT_LINE(VCARGARDIC, VLINEA);                                                                        

           ELSE
              v_nnumerr := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces, V_NUM_LIN,
                                                                       1,
                                                                       'Reserva realizao - '|| I.nsinies,
                                                                       NULL, 4, 0, NULL,
                                                                       I.nsinies,I.ntramit,null,
                                                                       NULL, NULL, NULL);
           END IF;    
           Exception
             when others then                                                                                                                                        
                  v_tdeserror := v_ntraza || ' ERROR es : ' || SQLERRM;
                  v_nnumerr := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces, V_NUM_LIN,
                                                                           1,
                                                                           v_nnumerr ||' - '|| v_tdeserror,
                                                                           NULL, 1, 0, NULL,
                                                                           I.nsinies,I.ntramit,null,
                                                                           NULL, NULL, NULL);   
                 VLINEA := I.nsinies || '|' || v_tdeserror;
                 UTL_FILE.PUT_LINE(VCARGARDIC, VLINEA);                                                                                       
           end; 
         else
            IF MENSAJES IS NOT NULL THEN
                FOR i IN mensajes.FIRST .. mensajes.LAST LOOP
                   v_tdeserror := mensajes(i).terror;
                   v_nnumerr := mensajes(i).cerror;

                END LOOP;
            END IF;
               v_nnumerr := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces, V_NUM_LIN,
                                                                        1,
                                                                        v_nnumerr ||' - '|| v_tdeserror,
                                                                        NULL, 1, 0, NULL,
                                                                        I.nsinies, I.ntramit,null,
                                                                        NULL, NULL, NULL);
                VLINEA := I.nsinies || '|' || v_tdeserror;
                UTL_FILE.PUT_LINE(VCARGARDIC, VLINEA);                                             
         END IF;                  
         Exception
             when others then                                                                                                                                        
                  v_tdeserror := v_ntraza || ' ERROR es : ' || SQLERRM;
                  v_nnumerr := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces, V_NUM_LIN,
                                                                           1,
                                                                           v_nnumerr ||' - '|| v_tdeserror,
                                                                           NULL, 1, 0, NULL,
                                                                           I.nsinies,I.ntramit,null,
                                                                           NULL, NULL, NULL);   
                 VLINEA := I.nsinies || '|' || v_tdeserror;
                 UTL_FILE.PUT_LINE(VCARGARDIC, VLINEA);                                                                                       
         end;
      end loop;
    end if;    

    /* Cerar archivo */
    IF UTL_FILE.is_open(VCARGARDIC) THEN
      UTL_FILE.fclose(VCARGARDIC);
    END IF;

    RETURN 0;

  EXCEPTION
    WHEN OTHERS THEN
      V_NNUMERR   := SQLCODE;
      V_TDESERROR := V_NTRAZA || ' en F_CARGA_PROCESO_INFORME: ' ||
                     SQLERRM;
      ROLLBACK;
      V_NNUMERR := P_MARCALINEAERROR(PSPROCES,
                                     V_NUM_LIN,
                                     NULL,
                                     1,
                                     V_NNUMERR,
                                     V_TDESERROR);
      P_GENERA_LOGS(V_TOBJETO,
                    V_NTRAZA,
                    'Error Incontrolado:' || V_NNUMERR,
                    V_TDESERROR);
      RETURN 1;
  END F_CARGA_PROCESO_INFORME;

  
-------------------------------------------------------------------------------------

FUNCTION F_CARGA_INFORME(P_NOMBRE  IN VARCHAR2,
                         P_PATH    IN VARCHAR2,
                         P_CPROCES IN NUMBER,
                         PSPROCES  IN OUT NUMBER) RETURN NUMBER IS
  VOBJ      VARCHAR2(100) := 'pac_cargas_generico.f_carga_informe';
  VTRAZA    NUMBER := 0;
  VDESERROR VARCHAR2(1000);
  ERRORINI EXCEPTION;
  VNUM_ERR NUMBER := 0;
  VSALIR EXCEPTION;

BEGIN
  VTRAZA := 0;

  IF PSPROCES IS NULL THEN
    SELECT SPROCES.NEXTVAL INTO PSPROCES FROM DUAL;
  END IF;

  VTRAZA := 1;

  IF P_CPROCES IS NULL THEN
    VNUM_ERR  := 9901092;
    VDESERROR := 'cfg_files falta proceso: ' || VOBJ;
    RAISE E_ERRDATOS;
  END IF;

  VTRAZA   := 2;
  VNUM_ERR := F_MODI_DATOS_INFORME_EXT(P_NOMBRE, P_PATH);

  IF VNUM_ERR <> 0 THEN
    P_TAB_ERROR(F_SYSDATE,
                F_USER,
                VOBJ,
                VTRAZA,
                VNUM_ERR,
                'Error creando la tabla externa',
                10);
    RAISE ERRORINI;
  END IF;

  VNUM_ERR := P_TRASP_DATOS_INFORME(VDESERROR, PSPROCES);
  VTRAZA   := 3;

  IF VNUM_ERR <> 0 THEN
    VTRAZA   := 4;
    VNUM_ERR := PAC_GESTION_PROCESOS.F_SET_CARGA_CTRL_CABECERA(PSPROCES,
                                                               P_NOMBRE,
                                                               F_SYSDATE,
                                                               NULL,
                                                               1,
                                                               P_CPROCES,
                                                               NULL,
                                                               VDESERROR,
                                                               0);
    VTRAZA   := 5;

    IF VNUM_ERR <> 0 THEN
      P_TAB_ERROR(F_SYSDATE,
                  F_USER,
                  VOBJ,
                  VTRAZA,
                  VNUM_ERR,
                  'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera2',
                  10);
      RAISE ERRORINI;
    END IF;

    VTRAZA := 6;
    RAISE VSALIR;
  END IF;

  RETURN 0;
EXCEPTION
  WHEN VSALIR THEN
    RETURN 103187;
  WHEN E_ERRDATOS THEN
    ROLLBACK;
    P_GENERA_LOGS(VOBJ, VTRAZA, 'Error:' || VNUM_ERR, VDESERROR);
    RETURN VNUM_ERR;
  WHEN ERRORINI THEN
    ROLLBACK;
    P_GENERA_LOGS(VOBJ,
                  VTRAZA,
                  'Error:' || 'ErrorIni' || ' en :' || 1,
                  'Error:' || 'Insertando estados registros');
    RETURN 1;
  WHEN OTHERS THEN
    ROLLBACK;

    P_GENERA_LOGS(VOBJ,
                  VTRAZA,
                  'Error:' || 'ErrorIni en 1',
                  'Error: Insertando estados registros');
    VNUM_ERR := PAC_GESTION_PROCESOS.F_SET_CARGA_CTRL_CABECERA(PSPROCES,
                                                               P_NOMBRE,
                                                               F_SYSDATE,
                                                               NULL,
                                                               1,
                                                               P_CPROCES,
                                                               151541,
                                                               SQLERRM,
                                                               0);
    VTRAZA   := 7;

    IF VNUM_ERR <> 0 THEN
      P_TAB_ERROR(F_SYSDATE,
                  F_USER,
                  VOBJ,
                  VTRAZA,
                  VNUM_ERR,
                  'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera2',
                  10);
    END IF;

    RETURN 1;
END F_CARGA_INFORME;

-------------------------------------------------------------------------------------

FUNCTION F_EJECUTAR_CARGA_INFORME(P_NOMBRE  IN VARCHAR2,
                                  P_PATH    IN VARCHAR2,
                                  P_CPROCES IN NUMBER,
                                  PSPROCES  IN OUT NUMBER)
  RETURN NUMBER IS
  VOBJ     VARCHAR2(100) := 'pac_cargas_generico.f_ejecutar_carga_informe';
  VTRAZA   NUMBER := 0;
  VNUM_ERR NUMBER := 0;
  VSALIR EXCEPTION;
BEGIN
  VTRAZA := 0;
  IF PSPROCES IS NULL THEN
    SELECT SPROCES.NEXTVAL INTO PSPROCES FROM DUAL;
  else
    return 0;
  end if;  
  SELECT NVL(CPARA_ERROR, 0),
         NVL(CBUSCA_HOST, 0),
         NVL(CFORMATO_DECIMALES, 0),
         NVL(CTABLAS, 'POL'),
         CDEBUG,
         NREGMASIVO
    INTO K_CPARA_ERROR,
         K_BUSCA_HOST,
         K_CFORMATO_DECIMALES,
         K_TABLAS,
         K_CDEBUG,
         K_NREGMASIVO
    FROM CFG_FILES
   WHERE CEMPRES = K_CEMPRESA
     AND CPROCESO = P_CPROCES;

    VNUM_ERR := PAC_GESTION_PROCESOS.F_SET_CARGA_CTRL_CABECERA(PSPROCES,
                                                               P_NOMBRE,
                                                               F_SYSDATE,
                                                               NULL,
                                                               3,
                                                               P_CPROCES,
                                                               NULL,
                                                               NULL,
                                                               1);
  IF VNUM_ERR <> 0 THEN
    P_TAB_ERROR(F_SYSDATE,
                F_USER,
                VOBJ,
                VTRAZA,
                VNUM_ERR,
                'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera',
                20);
    RAISE VSALIR;
  END IF;

  IF PSPROCES IS NOT NULL THEN
    VNUM_ERR := F_CARGA_INFORME(P_NOMBRE,
                                P_PATH,
                                P_CPROCES,
                                PSPROCES);
    IF VNUM_ERR <> 0 THEN
      RAISE VSALIR;
    END IF;
  END IF;

  VNUM_ERR := F_CARGA_PROCESO_INFORME(P_PATH,PSPROCES);

  UPDATE INT_CARGA_CTRL
     SET CESTADO = VNUM_ERR, 
         FFIN = F_SYSDATE, 
         CBLOQUEO = 0
   WHERE SPROCES = PSPROCES;

  COMMIT;
  RETURN 0;
EXCEPTION
  WHEN VSALIR THEN
    RETURN VNUM_ERR;
END F_EJECUTAR_CARGA_INFORME;

-------------------------------------------------------------------------------------
/* CAMBIOS DE IAXIS-3650 :END */
--Inico IAXIS 4184 07/06/2019 MOS Incluir Cambios Cargue Masivo para pagos
  /***********************************************************************
     FUNCTION f_ejecutar_cargue_masivo_proc:
          realiza el cargue masivo de pagos
          autor: Marcelo Ozawa de Sousa - 06/06/2019
   ***********************************************************************/
   
   FUNCTION f_ejecutar_cargue_masivo_proc(p_ssproces IN NUMBER)
      RETURN NUMBER IS
      v_tobjeto      VARCHAR2(100) := 'pac_cargas_generico.f_ejecutar_cargue_masivo_proc';
      v_ntraza       NUMBER := 0;
      e_salir        EXCEPTION;
      mensajes       t_iax_mensajes;
      CURSOR cur_pagos(p_ssproces2 IN NUMBER) IS
         SELECT   a.*
             FROM int_carga_generico a
            WHERE proceso = p_ssproces2
              AND NOT EXISTS(SELECT 1
                               FROM int_carga_ctrl_linea b
                              WHERE b.sproces = a.proceso
                                AND b.nlinea = a.nlinea
                                AND b.cestado IN(2, 4, 5, 6))
         ORDER BY nlinea, tiporegistro;
      v_id_linea     int_carga_generico.nlinea%TYPE;
      CURSOR cur_persona(pnnumide VARCHAR2) IS
         SELECT SPERSON 
           FROM  PER_PERSONAS
              WHERE NNUMIDE = pnnumide;
      --
       CURSOR cur_reservas(pnsinies VARCHAR2, pntranit NUMBER, ctippres NUMBER) IS
         SELECT ST.NMOVRES,ST.CGARANT,ST.CMONRES,ST.IRESERVA
             FROM SIN_TRAMITA_RESERVA ST
          WHERE ST.NMOVRES = (SELECT MAX(str2.nmovres)
                                FROM sin_tramita_reserva str2
                               WHERE str2.nsinies   = ST.nsinies
                                    AND str2.ntramit = ST.ntramit
                                    AND str2.ctipres = ST.ctipres
                                 AND str2.cgarant = ST.cgarant)
           AND ST.NSINIES = pnsinies
           AND ST.NTRAMIT = pntranit
           AND ST.CTIPRES = ctippres;
      --      
       sperson NUMBER;
       vnmovres NUMBER;
       vcgarant NUMBER;
      vcmonres VARCHAR2(3) := NULL;
      vireserva NUMBER;
      --
      vcmonpag  VARCHAR2(3) := 'COP';
      v_itasa   NUMBER; 
      v_isinret NUMBER;
      v_iiva    NUMBER;
      v_ifranq  NUMBER;
      v_cramo  NUMBER;
      v_iotros  NUMBER;
      v_fcambio DATE;
      v_ipagtot NUMBER;
      --
      BEGIN
      FOR x IN cur_pagos(p_ssproces) LOOP
          BEGIN
             --IAXIS-4555 Cambios en validacion de personas 
             sperson := NULL;
             vnmovres := NULL;
             vcgarant := NULL;
             vcmonres := NULL;
             --IAXIS-4555 Cambios en validacion de personas
             OPEN cur_persona(x.CAMPO06);
              FETCH cur_persona INTO sperson;
             CLOSE cur_persona;             
             IF sperson IS NULL THEN
                v_nnumerr := 2;
                RAISE e_salir;
             END IF;            
             OPEN cur_reservas(x.CAMPO02, x.CAMPO03, x.CAMPO04);
              FETCH cur_reservas INTO vnmovres, vcgarant, vcmonres , vireserva;
              IF cur_reservas%NOTFOUND THEN
                v_nnumerr := 4;
				CLOSE cur_reservas;
                RAISE e_salir;
              END IF;
             CLOSE cur_reservas;
             --IAXIS-4555 AABC cambios en proceso masivo por diferente moneda
             IF vcmonres <> vcmonpag THEN --f_sysdate
                --
                v_fcambio := pac_eco_tipocambio.f_fecha_max_cambio(vcmonres, vcmonpag,f_sysdate);
                v_itasa   := pac_eco_tipocambio.f_cambio(vcmonres, vcmonpag, TRUNC(f_sysdate));
                v_isinret := f_round((x.CAMPO10 / v_itasa),pac_monedas.f_cmoneda_n(vcmonres));
                v_iiva    := f_round((x.CAMPO12 / v_itasa),pac_monedas.f_cmoneda_n(vcmonres));
                v_ifranq  := f_round((x.CAMPO13 / v_itasa),pac_monedas.f_cmoneda_n(vcmonres));
                v_iotros  := f_round((x.CAMPO14 / v_itasa),pac_monedas.f_cmoneda_n(vcmonres));
                --
             ELSE 
                --
                v_isinret := x.CAMPO10;
                v_iiva    := x.CAMPO12;
                v_ifranq  := x.CAMPO13;
                v_iotros  := x.CAMPO14;
                --   
             END IF;
             --IAXIS-4555 AABC cambios en proceso masivo por diferente moneda
             -- Inicio IAXIS-4555 EA ingresar deducible para ramo 802 y tipo reserva indemnizatoria
             select distinct cramo into v_cramo from sin_siniestro join seguros using(sseguro) where nsinies=x.CAMPO02;
             IF x.CAMPO04<>1 or v_cramo<>802 THEN
                v_ifranq:=0;
             END IF;
             -- Fin IAXIS-4555 EA ingresar deducible para ramo 802 y tipo reserva indemnizatoria
             v_id_linea := v_id_linea + 1;
             v_ipagtot  := v_isinret + v_iotros;
--Inicio IAXIS 4184 14/06/2019 MOS Incluir forma de pago             
             IF vireserva > v_ipagtot THEN
                --                             
                v_nnumerr := pac_md_siniestros.f_cargue_masivo(x.CAMPO02, x.CAMPO03, vnmovres, x.CAMPO04, x.CAMPO05, 
                                                               vcmonres, x.CAMPO06, sperson, x.CAMPO07, to_date(x.CAMPO08, 'dd/mm/yyyy'), 
                                                               x.CAMPO09, v_isinret, x.CAMPO11, v_iiva,v_ifranq, v_iotros, x.CAMPO15, x.CAMPO16,  
                                                               p_ssproces , x.CAMPO17 , mensajes);
                --
             END IF;                                                  
--Fin IAXIS 4184 14/06/2019 MOS Incluir forma de pago
             IF v_nnumerr != 0 THEN
              IF mensajes IS NOT NULL THEN
                  FOR i IN mensajes.FIRST .. mensajes.LAST LOOP
                     v_tdeserror := mensajes(i).terror;
                     v_nnumerr := mensajes(i).cerror;
                  END LOOP;
               END IF;
               v_nnumerr := pac_gestion_procesos.f_set_carga_ctrl_linea(p_ssproces, x.CAMPO01,
                                                                        1,v_nnumerr ||' - '|| v_tdeserror,
                                                                           NULL, 1, 0, NULL,
                                                                           x.CAMPO02, NULL, x.CAMPO02,
                                                                           NULL, NULL, NULL);
             ELSE
              v_nnumerr := pac_gestion_procesos.f_set_carga_ctrl_linea(p_ssproces, x.CAMPO01,
                                                                           1,
                                                                           'Pago realizao - '|| x.CAMPO07,
                                                                           NULL, 4, 0, NULL,
                                                                           x.CAMPO02, NULL,  x.CAMPO02,
                                                                           NULL, NULL, NULL);
             END IF;
                EXCEPTION
                  WHEN e_salir THEN
                     IF v_nnumerr = 2 OR v_nnumerr = 3 THEN
                                 v_tdeserror := v_ntraza || ' ERROR buscando agencias: ' || SQLERRM;
                     END IF;
                     IF v_nnumerr = 4 THEN
                                 v_tdeserror := v_ntraza || ' ERROR no se encuentran reservas: ' || SQLERRM;
                     END IF;
                    v_nnumerr := pac_gestion_procesos.f_set_carga_ctrl_linea(p_ssproces, x.CAMPO01,
                                                                           1,
                                                                           v_nnumerr ||' - '|| v_tdeserror,
                                                                           NULL, 1, 0, NULL,
                                                                           x.CAMPO02, NULL, x.CAMPO02,
                                                                           NULL, NULL, NULL);
          END;
     END LOOP;
   RETURN 0;
  EXCEPTION
      WHEN OTHERS THEN
         v_nnumerr := SQLCODE;
         v_tdeserror := v_ntraza || ' en f_reser_ejecutar_carga_proceso: ' || SQLERRM;
         ROLLBACK;
         v_nnumerr := p_marcalineaerror(p_ssproces, v_id_linea, NULL, 1, v_nnumerr,
                                        v_tdeserror);
         p_genera_logs(v_tobjeto, v_ntraza, 'Error Incontrolado:' || v_nnumerr, v_tdeserror);
         RETURN 1;
   END f_ejecutar_cargue_masivo_proc;
  /***********************************************************************
     FUNCTION f_res_ejecutar_cargue_masivo:
          realiza el cargue masivo de pagos
          autor: Marcelo Ozawa de Sousa - 06/06/2019
   ***********************************************************************/
   FUNCTION f_res_ejecutar_cargue_masivo(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER,
      pjob IN NUMBER DEFAULT 0,
      pcusuari IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'pac_cargas_generico.f_res_ejecutar_cargue_masivo';
      vtraza         NUMBER := 0;
      vnum_err       NUMBER := 0;
      vsalir         EXCEPTION;
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
      vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces, p_nombre, f_sysdate,
                                                                 NULL, 3,
                                                                 p_cproces, NULL, NULL, 1);
      IF vnum_err <> 0 THEN
         p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                     'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera', 20);
         RAISE vsalir;
      END IF;
      pac_contexto.p_contextoasignaparametro('DEBUG', NVL(k_cdebug, 99));
      IF psproces IS NOT NULL THEN
         vnum_err := f_ejecutar_carga_fichero(p_nombre, p_path, p_cproces, psproces);
         IF vnum_err <> 0 THEN
            RAISE vsalir;
         END IF;
      END IF;
      vnum_err := f_ejecutar_cargue_masivo_proc(psproces);
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
   END f_res_ejecutar_cargue_masivo;
  /***********************************************************************
     FUNCTION f_ejecutar_cargue_masivo_job:
          realiza el cargue masivo de pagos
          autor: Marcelo Ozawa de Sousa - 06/06/2019
   ***********************************************************************/
  FUNCTION f_ejecutar_cargue_masivo_job(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER)
      RETURN NUMBER IS
      vmensaje       NUMBER;
      vnum_err       NUMBER;
   BEGIN
      IF psproces IS NULL THEN
         SELECT sproces.NEXTVAL
           INTO psproces
           FROM DUAL;
         vnum_err := f_res_ejecutar_cargue_masivo(p_nombre, p_path, p_cproces,
                                           psproces);
         RETURN vnum_err;
      END IF;
      RETURN 0;
   END f_ejecutar_cargue_masivo_job;
--Fin IAXIS 4184 07/06/2019 MOS Incluir Cambios Cargue Masivo para pagos
END pac_cargas_generico;

/
