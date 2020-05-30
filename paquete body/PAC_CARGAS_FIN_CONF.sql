CREATE OR REPLACE PACKAGE BODY "PAC_CARGAS_FIN_CONF" AS
   /*************************************************************************
   NOMBRE:       PAC_CARGAS_CONF
   PROP¿SITO: Fichero carga
   REVISIONES:
   Ver        Fecha        Autor             Descripci¿n
   ---------  ----------  ----------  ------------------------------------
   1.0        08/06/2017   ERH         1. Creaci¿n del package.
   2.0        23/05/2019   JLTS        2. Ajuste de la carga f_pais_r_ejecutargafichero
   3.0        09/09/2019   JLTS        3. IAXIS-5154: Se ajusta la función f_pais_r_ejecutargafichero
   *************************************************************************/

  /*************************************************************************
   FUNCTION f_eje_carga_cifras_sectoriales
   *************************************************************************/
   FUNCTION f_eje_carga_cifras_sectoriales(p_nombre  IN VARCHAR2,
                                           p_path    IN VARCHAR2,
                                           p_cproces IN NUMBER,
                                           psproces  IN OUT NUMBER) RETURN NUMBER IS
      vlin     NUMBER;
      vobj     VARCHAR2(200) := 'PAC_CARGAS_FIN_CONF.f_eje_carga_cifras_sectoriales';
      vpar     VARCHAR2(2000) := 'p_nombre=' || p_nombre || 'p_path=' ||
                                 p_path || ' p_cproces=' || p_cproces ||
                                 'psproces= ' || psproces;
      vnum_err NUMBER := 0;
   BEGIN

      vnum_err := pac_cargas_fin_conf. f_eje_carga_fichero_cifras_sec(p_nombre,
                                                                      p_path,
                                                                      p_cproces,
                                                                      psproces);
      --
      IF vnum_err <> 0
      THEN
         RAISE e_param_error;
      END IF;
      vlin := 2;
      --
      UPDATE int_carga_ctrl
         SET cestado = vnum_err, ffin = f_sysdate
       WHERE sproces = psproces;
      --
      COMMIT;
      --
      RETURN 0;
      --
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate,
                     f_user,
                     vobj,
                     vlin,
                     vpar,
                     SQLCODE);
         RETURN 1;
      WHEN e_object_error THEN
         p_tab_error(f_sysdate,
                     f_user,
                     vobj,
                     vlin,
                     vpar,
                     SQLCODE);
         RETURN 1;
      WHEN OTHERS THEN
         dbms_output.put_line(dbms_utility.format_error_backtrace);
         p_tab_error(f_sysdate,
                     f_user,
                     vobj,
                     vlin,
                     vpar,
                     SQLCODE);
         RETURN 1;
   END f_eje_carga_cifras_sectoriales;

  /*************************************************************************
   FUNCTION  f_eje_carga_fichero_cifras_sec
   *************************************************************************/
   -- INI - CP0140M_SYS_PERS_val - 07/11/2018 - JLTS - Se ajusta la función f_eje_carga_fichero_cifras_sec
   FUNCTION f_eje_carga_fichero_cifras_sec(p_nombre  IN VARCHAR2,
                                          p_path    IN VARCHAR2,
                                          p_cproces IN NUMBER,
                                          psproces  OUT NUMBER)
    RETURN NUMBER IS
    vobj        VARCHAR2(100) := 'pac_cargas_conf.f_eje_carga_fichero_score_tp';
    vnum_err    NUMBER := 0;
    v_line      VARCHAR2(32767);
    v_file      utl_file.file_type;
    v_numlineaf NUMBER := 0;
    -- Numero de linea del fichero
    -- Numero de linea del insert
    errorini   EXCEPTION;
    errorcarga EXCEPTION;
    e_errdatos EXCEPTION;
    -- Formato Inglés
    v_sep       VARCHAR2(1) := '|';
    v_currfield VARCHAR2(64);

    v_fefecto CONSTANT DATE := last_day(to_date(extract(year from f_sysdate)-1 ||
                                                '1231',
                                                'YYYYMMDD'));
    v_tcodciiu             VARCHAR2(50);
    v_ncodciiu             number;
    v_nvensecanoant        number;
    v_nvensecanoact        number;
    v_ncosvensecanoant     number;
    v_ncosvensecanoact     number;
    v_nopesecnoact         number;
    v_nopesecnoant         number;
    v_nutilnetsecanoant    number;
    v_nutilnetsecanoact    number;
    v_ncxcsecanoant        number;
    v_ncxcsecanoact        number;
    v_ninvsecanoant        number;
    v_ninvsecanoact        number;
    v_nactcorrsecanoant    number;
    v_nactcorrsecanoact    number;
    v_ntotactsecanoant     number;
    v_ntotactsecanoact     number;
    v_nprovsecanoant       number;
    v_nprovsecanoact       number;
    v_npascorrsecanoant    number;
    v_npascorrsecanoact    number;
    v_ntotpassecanoant     number;
    v_ntotpassecanoact     number;
    v_noblfinsecanoant     number;
    v_noblfinsecanoact     number;
    v_ncapsocsecanoant     number;
    v_ncapsocsecanoact     number;
    v_nresejeantasecanoant number;
    v_nresejeantasecanoact number;
    v_npatsecanoant        number;
    v_npatsecanoact        number;

    vlin NUMBER;
    vpar VARCHAR2(2000) := 'p_nombre=' || p_nombre || 'p_path=' || p_path ||
                           ' p_cproces=' || p_cproces || 'psproces= ' ||
                           psproces;

    PROCEDURE p_controlar_error(p_traza  NUMBER,
                                p_estado NUMBER,
                                v_msg    VARCHAR2) IS
    BEGIN
      vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces,
                                                                 p_nombre,
                                                                 f_sysdate,
                                                                 NULL,
                                                                 p_estado,
                                                                 p_cproces,
                                                                 NULL,
                                                                 v_msg);

      IF vnum_err <> 0 THEN
        -- Si fallan esta funciones de gesti¿n salimos del programa
        p_tab_error(f_sysdate,
                    f_user,
                    vobj,
                    p_traza,
                    vnum_err,
                    'Error llamando pac_gestion_procesos.f_set_carga_ctrl_cabecera' ||
                    p_traza);
        RAISE errorini;
      END IF;

    END p_controlar_error;

  BEGIN
    SELECT sproces.nextval INTO psproces FROM dual;

    IF p_cproces IS NULL THEN
      vnum_err := 9901092;
      RAISE e_errdatos;
    END IF;

    p_controlar_error(2, 3, NULL);

    BEGIN
      -- Inicio: Lectura de fichero.

      v_file := utl_file.fopen(p_path, p_nombre, 'R', 500);

      LOOP
        EXIT WHEN v_numlineaf = -1;

        BEGIN

          v_numlineaf := v_numlineaf + 1;
          utl_file.get_line(v_file, v_line, 32767);
					v_line := translate(v_line,chr(10)||chr(13), ' ');
          dbms_output.put_line(v_line);

          IF (v_numlineaf > 0) THEN
              v_currfield := 'CODCIIU';
              v_tcodciiu  := pac_util.splitt(v_line, 1, v_sep);
              -- Se actualiza el valor numérico con el que viene en el plano
              v_ncodciiu             := v_tcodciiu;
              v_currfield            := 'VENSECANOANT';
              v_nvensecanoant        := to_number(pac_util.splitt(v_line,
                                                                  2,
                                                                  v_sep));
              v_currfield            := 'VENSECANOACT';
              v_nvensecanoact        := to_number(pac_util.splitt(v_line,
                                                                  3,
                                                                  v_sep));
              v_currfield            := 'COSVENSECANOANT';
              v_ncosvensecanoant     := to_number(pac_util.splitt(v_line,
                                                                  4,
                                                                  v_sep));
              v_currfield            := 'COSVENSECANOACT';
              v_ncosvensecanoact     := to_number(pac_util.splitt(v_line,
                                                                  5,
                                                                  v_sep));
              v_currfield            := 'OPESECNOACT';
              v_nopesecnoact         := to_number(pac_util.splitt(v_line,
                                                                  6,
                                                                  v_sep));
              v_currfield            := 'OPESECNOANT';
              v_nopesecnoant         := to_number(pac_util.splitt(v_line,
                                                                  7,
                                                                  v_sep));
              v_currfield            := 'UTILNETSECANOANT';
              v_nutilnetsecanoant    := to_number(pac_util.splitt(v_line,
                                                                  8,
                                                                  v_sep));
              v_currfield            := 'UTILNETSECANOACT';
              v_nutilnetsecanoact    := to_number(pac_util.splitt(v_line,
                                                                  9,
                                                                  v_sep));
              v_currfield            := 'CXCSECANOANT';
              v_ncxcsecanoant        := to_number(pac_util.splitt(v_line,
                                                                  10,
                                                                  v_sep));
              v_currfield            := 'CXCSECANOACT';
              v_ncxcsecanoact        := to_number(pac_util.splitt(v_line,
                                                                  11,
                                                                  v_sep));
              v_currfield            := 'INVSECANOANT';
              v_ninvsecanoant        := to_number(pac_util.splitt(v_line,
                                                                  12,
                                                                  v_sep));
              v_currfield            := 'INVSECANOACT';
              v_ninvsecanoact        := to_number(pac_util.splitt(v_line,
                                                                  13,
                                                                  v_sep));
              v_currfield            := 'ACTCORRSECANOANT';
              v_nactcorrsecanoant    := to_number(pac_util.splitt(v_line,
                                                                  14,
                                                                  v_sep));
              v_currfield            := 'ACTCORRSECANOACT';
              v_nactcorrsecanoact    := to_number(pac_util.splitt(v_line,
                                                                  15,
                                                                  v_sep));
              v_currfield            := 'TOTACTSECANOANT';
              v_ntotactsecanoant     := to_number(pac_util.splitt(v_line,
                                                                  16,
                                                                  v_sep));
              v_currfield            := 'TOTACTSECANOACT';
              v_ntotactsecanoact     := to_number(pac_util.splitt(v_line,
                                                                  17,
                                                                  v_sep));
              v_currfield            := 'PROVSECANOANT';
              v_nprovsecanoant       := to_number(pac_util.splitt(v_line,
                                                                  18,
                                                                  v_sep));
              v_currfield            := 'PROVSECANOACT';
              v_nprovsecanoact       := to_number(pac_util.splitt(v_line,
                                                                  19,
                                                                  v_sep));
              v_currfield            := 'PASCORRSECANOANT';
              v_npascorrsecanoant    := to_number(pac_util.splitt(v_line,
                                                                  20,
                                                                  v_sep));
              v_currfield            := 'PASCORRSECANOACT';
              v_npascorrsecanoact    := to_number(pac_util.splitt(v_line,
                                                                  21,
                                                                  v_sep));
              v_currfield            := 'TOTPASSECANOANT';
              v_ntotpassecanoant     := to_number(pac_util.splitt(v_line,
                                                                  22,
                                                                  v_sep));
              v_currfield            := 'TOTPASSECANOACT';
              v_ntotpassecanoact     := to_number(pac_util.splitt(v_line,
                                                                  23,
                                                                  v_sep));
              v_currfield            := 'OBLFINSECANOANT';
              v_noblfinsecanoant     := to_number(pac_util.splitt(v_line,
                                                                  24,
                                                                  v_sep));
              v_currfield            := 'OBLFINSECANOACT';
              v_noblfinsecanoact     := to_number(pac_util.splitt(v_line,
                                                                  25,
                                                                  v_sep));
              v_currfield            := 'CAPSOCSECANOANT';
              v_ncapsocsecanoant     := to_number(pac_util.splitt(v_line,
                                                                  26,
                                                                  v_sep));
              v_currfield            := 'CAPSOCSECANOACT';
              v_ncapsocsecanoact     := to_number(pac_util.splitt(v_line,
                                                                  27,
                                                                  v_sep));
              v_currfield            := 'RESEJEANTASECANOANT';
              v_nresejeantasecanoant := to_number(pac_util.splitt(v_line,
                                                                  28,
                                                                  v_sep));
              v_currfield            := 'RESEJEANTASECANOACT';
              v_nresejeantasecanoact := to_number(pac_util.splitt(v_line,
                                                                  29,
                                                                  v_sep));
              v_currfield            := 'PATSECANOANT';
              v_npatsecanoant        := to_number(pac_util.splitt(v_line,
                                                                  30,
                                                                  v_sep));
              v_currfield            := 'PATSECANOACT';
              v_npatsecanoact        := to_number(pac_util.splitt(v_line,
                                                                  31,
                                                                  v_sep));

              --
            BEGIN

              --Insert

              INSERT INTO fin_cifras_sectoriales
                (falta,
                 fefecto,
                 scifsec,
                 tcociiu,
                 ncociiu,
                 nvenant,
                 nvenact,
                 ncovean,
                 ncoveac,
                 nutopan,
                 nutopac,
                 nutnean,
                 nutneac,
                 ncucoan,
                 ncucoac,
                 ninvean,
                 ninveac,
                 naccoan,
                 naccoac,
                 ntoacan,
                 ntoacac,
                 nprovan,
                 nprovac,
                 npacoan,
                 npacoac,
                 ntopaan,
                 ntopaac,
                 nobfian,
                 nobfiac,
                 ncasoan,
                 ncasoac,
                 nreejan,
                 nreejac,
                 npatran,
                 npatrac)
              VALUES
                (f_sysdate,
                 v_fefecto,
                 v_numlineaf,
                 v_tcodciiu,
                 v_ncodciiu,
                 v_nvensecanoant,
                 v_nvensecanoact,
                 v_ncosvensecanoant,
                 v_ncosvensecanoact,
                 v_nopesecnoact,
                 v_nopesecnoant,
                 v_nutilnetsecanoant,
                 v_nutilnetsecanoact,
                 v_ncxcsecanoant,
                 v_ncxcsecanoact,
                 v_ninvsecanoant,
                 v_ninvsecanoact,
                 v_nactcorrsecanoant,
                 v_nactcorrsecanoact,
                 v_ntotactsecanoant,
                 v_ntotactsecanoact,
                 v_nprovsecanoant,
                 v_nprovsecanoact,
                 v_npascorrsecanoant,
                 v_npascorrsecanoact,
                 v_ntotpassecanoant,
                 v_ntotpassecanoact,
                 v_noblfinsecanoant,
                 v_noblfinsecanoact,
                 v_ncapsocsecanoant,
                 v_ncapsocsecanoact,
                 v_nresejeantasecanoant,
                 v_nresejeantasecanoact,
                 v_npatsecanoant,
                 v_npatsecanoact);

            EXCEPTION
              WHEN DUP_VAL_ON_INDEX THEN
                UPDATE fin_cifras_sectoriales
                   SET tcociiu = v_tcodciiu,
                       ncociiu = v_ncodciiu,
                       nvenant = v_nvensecanoant,
                       nvenact = v_nvensecanoact,
                       ncovean = v_ncosvensecanoant,
                       ncoveac = v_ncosvensecanoact,
                       nutopan = v_nopesecnoact,
                       nutopac = v_nopesecnoant,
                       nutnean = v_nutilnetsecanoant,
                       nutneac = v_nutilnetsecanoact,
                       ncucoan = v_ncxcsecanoant,
                       ncucoac = v_ncxcsecanoact,
                       ninvean = v_ninvsecanoant,
                       ninveac = v_ninvsecanoact,
                       naccoan = v_nactcorrsecanoant,
                       naccoac = v_nactcorrsecanoact,
                       ntoacan = v_ntotactsecanoant,
                       ntoacac = v_ntotactsecanoact,
                       nprovan = v_nprovsecanoant,
                       nprovac = v_nprovsecanoact,
                       npacoan = v_npascorrsecanoant,
                       npacoac = v_npascorrsecanoact,
                       ntopaan = v_ntotpassecanoant,
                       ntopaac = v_ntotpassecanoact,
                       nobfian = v_noblfinsecanoant,
                       nobfiac = v_noblfinsecanoact,
                       ncasoan = v_ncapsocsecanoant,
                       ncasoac = v_ncapsocsecanoact,
                       nreejan = v_nresejeantasecanoant,
                       nreejac = v_nresejeantasecanoact,
                       npatran = v_npatsecanoant,
                       npatrac = v_npatsecanoact
                 WHERE TO_CHAR(fefecto, 'DD/MM/YYYY') =
                       TO_CHAR(v_fefecto, 'DD/MM/YYYY')
                   AND scifsec = v_numlineaf;

            END;

            vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces   => psproces,
                                                                    pnlinea    => v_numlineaf,
                                                                    pctipo     => 20,
                                                                    pidint     => v_numlineaf,
                                                                    pidext     => v_numlineaf,
                                                                    pcestado   => 4,
                                                                    pcvalidado => NULL,
                                                                    psseguro   => NULL,
                                                                    pidexterno => NULL,
                                                                    pncarga    => NULL,
                                                                    pnsinies   => NULL,
                                                                    pntramit   => NULL,
                                                                    psperson   => NULL,
                                                                    pnrecibo   => NULL);

            --
            COMMIT;
            --
          END IF;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            -- No hay mas datos para leer.
            v_numlineaf := -1;
          WHEN OTHERS THEN
            p_controlar_error(2, 3, NULL);

        END;
      END LOOP;

      utl_file.fclose(v_file);
      RETURN 0;
    EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
        dbms_output.put_line(dbms_utility.format_error_backtrace);
        ROLLBACK;
        utl_file.fclose(v_file);
        p_controlar_error(5,
                          1,
                          f_axis_literales(9904284,
                                           pac_md_common.f_get_cxtidioma()) ||
                          ' at line ' || v_numlineaf);
        RETURN 9904284;
        -- Duplicated record
      WHEN value_error THEN
        dbms_output.put_line(dbms_utility.format_error_backtrace);
        ROLLBACK;
        utl_file.fclose(v_file);
        p_controlar_error(6,
                          1,
                          f_axis_literales(9907933,
                                           pac_md_common.f_get_cxtidioma()) ||
                          ' at line ' || v_numlineaf || ', field: ' ||
                          v_currfield);
        RETURN 9907933;
        -- Data Error. Check character length OR NUMBER format
      WHEN OTHERS THEN
        dbms_output.put_line(dbms_utility.format_error_backtrace);
        ROLLBACK;
        utl_file.fclose(v_file);
        p_controlar_error(7,
                          1,
                          f_axis_literales(103187,
                                           pac_md_common.f_get_cxtidioma()));
        RETURN 103187;
        -- An error has occurred while reading the file
    END;

  EXCEPTION
    WHEN e_errdatos THEN
      ROLLBACK;
      p_tab_error(f_sysdate,
                  f_user,
                  vobj,
                  vlin,
                  vpar,
                  SQLCODE || chr(10) || vnum_err);
      dbms_output.put_line(dbms_utility.format_error_backtrace);
      RETURN vnum_err;
    WHEN errorini THEN
      ROLLBACK;
      p_tab_error(f_sysdate,
                  f_user,
                  vobj,
                  vlin,
                  vpar,
                  SQLCODE || chr(10) || vnum_err);
      dbms_output.put_line(dbms_utility.format_error_backtrace);
      RETURN 108953;
      -- A runtime error has occurred
  END f_eje_carga_fichero_cifras_sec;
  -- FIN - CP0140M_SYS_PERS_val- 07/11/2018 - JLTS - Se ajusta la función f_eje_carga_fichero_cifras_sec

   /*************************************************************************
   FUNCTION f_eje_carga_pais_riesgo
   *************************************************************************/
   FUNCTION f_eje_carga_pais_riesgo(p_nombre  IN VARCHAR2,
                                    p_path    IN VARCHAR2,
                                    p_cproces IN NUMBER,
                                    psproces  IN OUT NUMBER) RETURN NUMBER IS
      vlin     NUMBER;
      vobj     VARCHAR2(200) := 'PAC_CARGAS_FIN_CONF.f_eje_carga_pais_riesgo';
      vpar     VARCHAR2(2000) := 'p_nombre=' || p_nombre || 'p_path=' ||
                                 p_path || ' p_cproces=' || p_cproces ||
                                 'psproces= ' || psproces;
      vnum_err NUMBER := 0;
   BEGIN

      vnum_err := pac_cargas_fin_conf.f_eje_carga_fichero_pais_riesg(p_nombre,
                                                                      p_path,
                                                                      p_cproces,
                                                                      psproces);
      --
      IF vnum_err <> 0
      THEN
         RAISE e_param_error;
      END IF;
      vlin := 2;
      --
      UPDATE int_carga_ctrl
         SET cestado = vnum_err, ffin = f_sysdate
       WHERE sproces = psproces;
      --
      COMMIT;
      --
      RETURN 0;
      --
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate,
                     f_user,
                     vobj,
                     vlin,
                     vpar,
                     SQLCODE);
         RETURN 1;
      WHEN e_object_error THEN
         p_tab_error(f_sysdate,
                     f_user,
                     vobj,
                     vlin,
                     vpar,
                     SQLCODE);
         RETURN 1;
      WHEN OTHERS THEN
         dbms_output.put_line(dbms_utility.format_error_backtrace);
         p_tab_error(f_sysdate,
                     f_user,
                     vobj,
                     vlin,
                     vpar,
                     SQLCODE);
         RETURN 1;
   END f_eje_carga_pais_riesgo;

  /*************************************************************************
   FUNCTION  f_eje_carga_fichero_pais_riesgo
   *************************************************************************/
   FUNCTION  f_eje_carga_fichero_pais_riesg(p_nombre  IN VARCHAR2,
                                            p_path    IN VARCHAR2,
                                            p_cproces IN NUMBER,
                                            psproces  OUT NUMBER) RETURN NUMBER IS
      vobj        VARCHAR2(100) := 'pac_cargas_conf.f_eje_carga_fichero_pais_riesg';
      vnum_err    NUMBER := 0;
      v_line      VARCHAR2(32767);
      v_file      utl_file.file_type;
      v_numlineaf NUMBER := 1;
      -- Numero de linea del fichero
      -- Numero de linea del insert
      errorini   EXCEPTION;
      errorcarga EXCEPTION;
      e_errdatos EXCEPTION;
      -- Formato Ingl¿s
      v_sep       VARCHAR2(1) := ';';
      v_currfield VARCHAR2(64);

        v_fefecto DATE;
          v_cpais NUMBER;
       v_nratingm VARCHAR2(30);
        v_ncalifm NUMBER;
      v_nratingsp VARCHAR2(30);
      v_ncalifisp NUMBER;
       v_nratingf VARCHAR2(30);
        v_ncaliff NUMBER;
        v_ncalpon NUMBER;
        v_ncalaft NUMBER;
        v_ncatopa NUMBER;
        v_nconcal VARCHAR2(250);



      vlin        NUMBER;
      vpar        VARCHAR2(2000) := 'p_nombre=' || p_nombre || 'p_path=' ||
                                    p_path || ' p_cproces=' || p_cproces ||
                                    'psproces= ' || psproces;

      PROCEDURE p_controlar_error(p_traza  NUMBER,
                                  p_estado NUMBER,
                                  v_msg    VARCHAR2) IS
      BEGIN
         vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces,
                                                                    p_nombre,
                                                                    f_sysdate,
                                                                    NULL,
                                                                    p_estado,
                                                                    p_cproces,
                                                                    NULL,
                                                                    v_msg);

         IF vnum_err <> 0
         THEN
            -- Si fallan esta funciones de gesti¿n salimos del programa
            p_tab_error(f_sysdate,
                        f_user,
                        vobj,
                        p_traza,
                        vnum_err,
                        'Error llamando pac_gestion_procesos.f_set_carga_ctrl_cabecera' ||
                        p_traza);
            RAISE errorini;
         END IF;

      END p_controlar_error;

   BEGIN
      SELECT sproces.nextval INTO psproces FROM dual;

      IF p_cproces IS NULL
      THEN
         vnum_err := 9901092;
         RAISE e_errdatos;
      END IF;

      p_controlar_error(2,
                        3,
                        NULL);

      BEGIN
         -- Inicio: Lectura de fichero.

         v_file := utl_file.fopen(p_path,
                                  p_nombre,
                                  'R',
                                  256);

         LOOP
            EXIT WHEN v_numlineaf = -1;

            BEGIN

               v_numlineaf := v_numlineaf + 1;
               utl_file.get_line(v_file,
                                 v_line,
                                 32767);
               dbms_output.put_line(v_line);

               IF (v_numlineaf > 1)
               THEN
                  -- A partir de la Segona
                  v_currfield := 'FEFECTO';
                  v_fefecto   := TO_DATE(pac_util.splitt(v_line,
                                                         1,
                                                         v_sep),
                                         'DD/MM/YYYY');

                  v_currfield := 'CPAIS';
                  v_cpais   := pac_util.splitt(v_line,
                                                 2,
                                                 v_sep);

                  v_currfield := 'NRATINGM';
                  v_nratingm  := pac_util.splitt(v_line,
                                                 3,
                                                 v_sep);
                  v_nratingm  := LTRIM(v_nratingm);

                  v_currfield := 'NCALIFM';
                  v_ncalifm   := pac_util.splitt(v_line,
                                                 4,
                                                 v_sep);

                  v_currfield := 'NRATINGSP';
                  v_nratingsp := pac_util.splitt(v_line,
                                                 5,
                                                 v_sep);
                  v_nratingsp  := LTRIM(v_nratingsp);



                  v_currfield := 'NCALIFISP';
                  v_ncalifisp := pac_util.splitt(v_line,
                                                 6,
                                                 v_sep);

                  v_currfield := 'NRATINGF';
                  v_nratingf  := pac_util.splitt(v_line,
                                                 7,
                                                 v_sep);
                  v_nratingf  := LTRIM(v_nratingf);

                  v_currfield := 'NCALIFF';
                  v_ncaliff   := pac_util.splitt(v_line,
                                                 8,
                                                 v_sep);

                  v_currfield := 'NCALPON';
                  v_ncalpon   := pac_util.splitt(v_line,
                                                 9,
                                                 v_sep);
                  v_currfield := 'NCALAFT';
                  v_ncalaft   := pac_util.splitt(v_line,
                                                 10,
                                                 v_sep);

                  v_currfield := 'NCATOPA';
                  v_ncatopa   := pac_util.splitt(v_line,
                                                 11,
                                                 v_sep);

                  v_currfield := 'NCONCAL';
                  v_nconcal   := pac_util.splitt(v_line,
                                                 12,
                                                 v_sep);


                  --

                  BEGIN

                     --Insert

                    INSERT INTO fin_pais_riesgo_crediticio
                        (falta, fefecto, cpais, nratingm, ncalifm,
                         nratingsp, ncalifisp, nratingf, ncaliff, ncalpon,
                         ncalaft, ncatopa, nconcal)
                    VALUES
                        (f_sysdate, v_fefecto, v_cpais, v_nratingm, v_ncalifm,
                         v_nratingsp, v_ncalifisp, v_nratingf, v_ncaliff, v_ncalpon,
                         v_ncalaft, v_ncatopa, v_nconcal);



                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                        UPDATE  fin_pais_riesgo_crediticio
                           SET   nratingm = v_nratingm,
                                  ncalifm = v_ncalifm,
                                nratingsp = v_nratingsp,
                                ncalifisp = v_ncalifisp,
                                 nratingf = v_nratingf,
                                  ncaliff = v_ncaliff,
                                  ncalpon = v_ncalpon,
                                  ncalaft = v_ncalaft,
                                  ncatopa = v_ncatopa,
                                  nconcal = v_nconcal
                         WHERE  TO_CHAR(fefecto, 'DD/MM/YYYY') = TO_CHAR(v_fefecto,'DD/MM/YYYY')
                           AND  cpais = v_cpais;

                  END;

                  vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces   => psproces,
                                                                          pnlinea    => v_numlineaf,
                                                                          pctipo     => 20,
                                                                          pidint     => v_numlineaf,
                                                                          pidext     => v_numlineaf,
                                                                          pcestado   => 4,
                                                                          pcvalidado => NULL,
                                                                          psseguro   => NULL,
                                                                          pidexterno => NULL,
                                                                          pncarga    => NULL,
                                                                          pnsinies   => NULL,
                                                                          pntramit   => NULL,
                                                                          psperson   => NULL,
                                                                          pnrecibo   => NULL);

                  --
                  COMMIT;
                  --
               END IF;

            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  -- No hay mas datos para leer.
                  v_numlineaf := -1;
               WHEN OTHERS THEN
                  p_controlar_error(2,
                                    3,
                                    NULL);

            END;
         END LOOP;

         utl_file.fclose(v_file);
         RETURN 0;
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            dbms_output.put_line(dbms_utility.format_error_backtrace);
            ROLLBACK;
            utl_file.fclose(v_file);
            p_controlar_error(5,
                              1,
                              f_axis_literales(9904284,
                                               pac_md_common.f_get_cxtidioma()) ||
                              ' at line ' || v_numlineaf);
            RETURN 9904284;
            -- Duplicated record
         WHEN value_error THEN
            dbms_output.put_line(dbms_utility.format_error_backtrace);
            ROLLBACK;
            utl_file.fclose(v_file);
            p_controlar_error(6,
                              1,
                              f_axis_literales(9907933,
                                               pac_md_common.f_get_cxtidioma()) ||
                              ' at line ' || v_numlineaf || ', field: ' ||
                              v_currfield);
            RETURN 9907933;
            -- Data Error. Check character length OR NUMBER format
         WHEN OTHERS THEN
            dbms_output.put_line(dbms_utility.format_error_backtrace);
            ROLLBACK;
            utl_file.fclose(v_file);
            p_controlar_error(7,
                              1,
                              f_axis_literales(103187,
                                               pac_md_common.f_get_cxtidioma()));
            RETURN 103187;
            -- An error has occurred while reading the file
      END;

   EXCEPTION
      WHEN e_errdatos THEN
         ROLLBACK;
         p_tab_error(f_sysdate,
                     f_user,
                     vobj,
                     vlin,
                     vpar,
                     SQLCODE || chr(10) || vnum_err);
         dbms_output.put_line(dbms_utility.format_error_backtrace);
         RETURN vnum_err;
      WHEN errorini THEN
         ROLLBACK;
         p_tab_error(f_sysdate,
                     f_user,
                     vobj,
                     vlin,
                     vpar,
                     SQLCODE || chr(10) || vnum_err);
         dbms_output.put_line(dbms_utility.format_error_backtrace);
         RETURN 108953;
         -- A runtime error has occurred
   END  f_eje_carga_fichero_pais_riesg;


  /*************************************************************************
   FUNCTION f_pais_r_ejecutarcarga
   *************************************************************************/
   FUNCTION f_pais_r_ejecutarcarga(p_nombre  IN VARCHAR2,
                                   p_path    IN VARCHAR2,
                                   p_cproces IN NUMBER,
                                   psproces  IN OUT NUMBER) RETURN NUMBER IS
      vlin     NUMBER;
      vobj     VARCHAR2(200) := 'PAC_CARGAS_FIN_CONF.f_pais_r_ejecutarcarga';
      vpar     VARCHAR2(2000) := 'p_nombre=' || p_nombre || 'p_path=' ||
                                 p_path || ' p_cproces=' || p_cproces ||
                                 'psproces= ' || psproces;
      vnum_err NUMBER := 0;
   BEGIN

      vnum_err := pac_cargas_fin_conf.f_pais_r_ejecutargafichero(p_nombre,
                                                                 p_path,
                                                                 p_cproces,
                                                                 psproces);
      --
      IF vnum_err <> 0
      THEN
         RAISE e_param_error;
      END IF;
      vlin := 2;
      --
      UPDATE int_carga_ctrl
         SET cestado = vnum_err, ffin = f_sysdate
       WHERE sproces = psproces;
      --
      COMMIT;
      --
      RETURN 0;
      --
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate,
                     f_user,
                     vobj,
                     vlin,
                     vpar,
                     SQLCODE);
         RETURN 1;
      WHEN e_object_error THEN
         p_tab_error(f_sysdate,
                     f_user,
                     vobj,
                     vlin,
                     vpar,
                     SQLCODE);
         RETURN 1;
      WHEN OTHERS THEN
         dbms_output.put_line(dbms_utility.format_error_backtrace);
         p_tab_error(f_sysdate,
                     f_user,
                     vobj,
                     vlin,
                     vpar,
                     SQLCODE);
         RETURN 1;
   END f_pais_r_ejecutarcarga;


  /*************************************************************************
   FUNCTION  f_pais_r_ejecutargafichero
   *************************************************************************/
   -- INI -- IAXIS-4242 - 23/05/2019   -JLTS Ajuste de la carga f_pais_r_ejecutargafichero
   FUNCTION  f_pais_r_ejecutargafichero(p_nombre  IN VARCHAR2,
                                        p_path    IN VARCHAR2,
                                        p_cproces IN NUMBER,
                                        psproces  OUT NUMBER) RETURN NUMBER IS
      vobj        VARCHAR2(100) := 'pac_cargas_conf.f_pais_r_ejecutargafichero';
      vnum_err    NUMBER := 0;
      v_line      VARCHAR2(32767);
      v_file      utl_file.file_type;
      v_numlineaf NUMBER := 0;
      -- Numero de linea del fichero
      -- Numero de linea del insert
      errorini   EXCEPTION;
      errorcarga EXCEPTION;
      e_errdatos EXCEPTION;
      -- Formato Ingl¿s
      v_sep       VARCHAR2(1) := ';';
      v_currfield VARCHAR2(64);


         v_cpais NUMBER;
       v_ncalpro NUMBER;
      v_npfiscal NUMBER;
        v_nlroja NUMBER;
       v_nlnegra NUMBER;
       v_nlgriso NUMBER;
        v_nlgris NUMBER;
        v_nlgafi NUMBER;
       v_ncalift NUMBER;
       v_cratin1 VARCHAR2(10);
       v_cratin2 VARCHAR2(10);
       v_cratin3 VARCHAR2(10);
       v_nratin1 NUMBER;
       v_nratin2 NUMBER;
       v_nratin3 NUMBER;
       v_ncalifp NUMBER;
			 v_nanio_efecto NUMBER;



      vlin        NUMBER;
      vpar        VARCHAR2(2000) := 'p_nombre=' || p_nombre || 'p_path=' ||
                                    p_path || ' p_cproces=' || p_cproces ||
                                    'psproces= ' || psproces;

      PROCEDURE p_controlar_error(p_traza  NUMBER,
                                  p_estado NUMBER,
                                  v_msg    VARCHAR2) IS
      BEGIN
         vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces,
                                                                    p_nombre,
                                                                    f_sysdate,
                                                                    NULL,
                                                                    p_estado,
                                                                    p_cproces,
                                                                    NULL,
                                                                    v_msg);

         IF vnum_err <> 0
         THEN
            -- Si fallan esta funciones de gesti¿n salimos del programa
            p_tab_error(f_sysdate,
                        f_user,
                        vobj,
                        p_traza,
                        vnum_err,
                        'Error llamando pac_gestion_procesos.f_set_carga_ctrl_cabecera' ||
                        p_traza);
            RAISE errorini;
         END IF;

      END p_controlar_error;

   BEGIN
      SELECT sproces.nextval INTO psproces FROM dual;

      IF p_cproces IS NULL
      THEN
         vnum_err := 9901092;
         RAISE e_errdatos;
      END IF;

      p_controlar_error(2,
                        3,
                        NULL);

      BEGIN
         -- Inicio: Lectura de fichero.

         v_file := utl_file.fopen(p_path,
                                  p_nombre,
                                  'R',
                                  256);

         LOOP
            EXIT WHEN v_numlineaf = -1;

            BEGIN

               v_numlineaf := v_numlineaf + 1;
               utl_file.get_line(v_file,
                                 v_line,
                                 32767);
               v_line := translate(v_line,chr(10)||chr(13), ' ');
               dbms_output.put_line(v_line);

                  v_currfield := 'NANIO_EFECTO';        --AÑO DE EFECTO
		      -- INI - IAXIS-5154 - JLTS - 09/09/2019 - Se incluye el REPLACE
                      v_nanio_efecto := pac_util.splitt(REPLACE(v_line,',','.'),
                                                 1,
                                                 v_sep);

                  v_currfield := 'CPAIS';        --País CP0468M_SYS_PERS 17/12/2018 AP
                      v_cpais := pac_util.splitt(REPLACE(v_line,',','.'),
                                                 2,
                                                 v_sep);
		      -- FIN - IAXIS-5154 - JLTS - 09/09/2019 - Se incluye el REPLACE

                /*  v_currfield := 'NPFISCAL';
                   v_npfiscal := pac_util.splitt(v_line,
                                                 3,
                                                 v_sep);

                  v_currfield := 'NLROJA';
                     v_nlroja := pac_util.splitt(v_line,
                                                 4,
                                                 v_sep);

                  v_currfield := 'NLNEGRA';
                    v_nlnegra := pac_util.splitt(v_line,
                                                 5,
                                                 v_sep);

                  v_currfield := 'NLGRISO';
                    v_nlgriso := pac_util.splitt(v_line,
                                                 6,
                                                 v_sep);

                  v_currfield := 'NLGRIS';
                     v_nlgris := pac_util.splitt(v_line,
                                                 7,
                                                 v_sep); */

                  v_currfield := 'CRATIN1';  --Ratings Moody's CP0468M_SYS_PERS 17/12/2018 AP
                    v_cratin1 := pac_util.splitt(v_line,
                                                 3,
                                                 v_sep);

                  v_currfield := 'NRATIN1';  --Calificación Moody's CP0468M_SYS_PERS 17/12/2018 AP
		    -- INI - IAXIS-5154 - JLTS - 09/09/2019 - Se incluye el REPLACE
                    v_nratin1 := pac_util.splitt(REPLACE(v_line,',','.'),
                                                 4,
                                                 v_sep);

                  v_currfield := 'CRATIN2'; --Ratings SP
                    v_cratin2 := pac_util.splitt(v_line,
                                                 5,
                                                 v_sep);

                  v_currfield := 'NRATIN2';  --Calificación SP CP0468M_SYS_PERS 17/12/2018 AP
                    v_nratin2 := pac_util.splitt(REPLACE(v_line,',','.'),
                                                 6,
                                                 v_sep);

                  v_currfield := 'CRATIN3'; --Ratings Fitch  CP0468M_SYS_PERS 17/12/2018 AP
                    v_cratin3 := pac_util.splitt(v_line,
                                                 7,
                                                 v_sep);

                  v_currfield := 'NRATIN3'; --Calificación Fitch CP0468M_SYS_PERS 17/12/2018 AP
                    v_nratin3 := pac_util.splitt(REPLACE(v_line,',','.'),
                                                 8,
                                                 v_sep);

                  v_currfield := 'NCALIFP'; --Calificación ponderada CP0468M_SYS_PERS 17/12/2018 AP
                    v_ncalifp := pac_util.splitt(REPLACE(v_line,',','.'),
                                                 9,
                                                 v_sep);

                  v_currfield := 'NLGAFI'; --Calificación LAFT CP0468M_SYS_PERS 17/12/2018 AP
                     v_nlgafi := pac_util.splitt(REPLACE(v_line,',','.'),
                                                 10,
                                                 v_sep);

                 v_currfield := 'NCALIFT'; --Calificación TOTAL PAIS CP0468M_SYS_PERS 17/12/2018 AP
                    v_ncalift := pac_util.splitt(REPLACE(v_line,',','.'),
                                                 11,
                                                 v_sep);
		 -- FIN - IAXIS-5154 - JLTS - 09/09/2019 - Se incluye el REPLACE

               /*  v_currfield := 'NCALPRO';
                    v_ncalpro := pac_util.splitt(v_line,
                                                 11,
                                                 v_sep); */
                  --

                  BEGIN

                     --Insert

                    INSERT INTO fin_pais_riesgo
                        (cpais, nmovimi, fcarga, nlgafi,
                        ncalift, cratin1, cratin2, cratin3, nratin1,
                        nratin2, nratin3, ncalifp,nanio_efecto)
                    VALUES
                        (v_cpais, nmovimi.nextval, F_SYSDATE, v_nlgafi,
                         v_ncalift, v_cratin1, v_cratin2, v_cratin3, v_nratin1,
                         v_nratin2, v_nratin3, v_ncalifp,v_nanio_efecto);

                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                        UPDATE  fin_pais_riesgo
                           SET   nlgafi = v_nlgafi,
                                 ncalift = v_ncalift,
                                 cratin1 = v_cratin1,
                                 cratin2 = v_cratin2,
                                 cratin3 = v_cratin3,
                                 nratin1 = v_nratin1,
                                 nratin2 = v_nratin2,
                                 nratin3 = v_nratin3,
                                 ncalifp = v_ncalifp
                         WHERE   cpais = v_cpais;

                  END;

                  vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces   => psproces,
                                                                          pnlinea    => v_numlineaf,
                                                                          pctipo     => 20,
                                                                          pidint     => v_numlineaf,
                                                                          pidext     => v_numlineaf,
                                                                          pcestado   => 4,
                                                                          pcvalidado => NULL,
                                                                          psseguro   => NULL,
                                                                          pidexterno => f_axis_literales(9909597,pac_md_common.f_get_cxtidioma())||' - '||v_cpais,
                                                                          pncarga    => NULL,
                                                                          pnsinies   => NULL,
                                                                          pntramit   => NULL,
                                                                          psperson   => NULL,
                                                                          pnrecibo   => NULL);

                  --
                  COMMIT;
                  --

            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  -- No hay mas datos para leer.
                  v_numlineaf := -1;
               WHEN OTHERS THEN
                  p_controlar_error(2,
                                    3,
                                    NULL);
									 vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces   => psproces,
																																												 pnlinea    => v_numlineaf,
																																												 pctipo     => 20,
																																												 pidint     => v_numlineaf,
																																												 pidext     => v_numlineaf,
																																												 pcestado   => 1,
																																												 pcvalidado => NULL,
																																												 psseguro   => NULL,
																																												 pidexterno => f_axis_literales(9909597,pac_md_common.f_get_cxtidioma())||' - '||v_cpais,
																																												 pncarga    => NULL,
																																												 pnsinies   => NULL,
																																												 pntramit   => NULL,
																																												 psperson   => NULL,
																																												 pnrecibo   => NULL);
            END;
         END LOOP;

         utl_file.fclose(v_file);
         RETURN 0;
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            dbms_output.put_line(dbms_utility.format_error_backtrace);
            ROLLBACK;
            utl_file.fclose(v_file);
            p_controlar_error(5,
                              1,
                              f_axis_literales(9904284,
                                               pac_md_common.f_get_cxtidioma()) ||
                              ' at line ' || v_numlineaf);
            RETURN 9904284;
            -- Duplicated record
         WHEN value_error THEN
            dbms_output.put_line(dbms_utility.format_error_backtrace);
            ROLLBACK;
            utl_file.fclose(v_file);
            p_controlar_error(6,
                              1,
                              f_axis_literales(9907933,
                                               pac_md_common.f_get_cxtidioma()) ||
                              ' at line ' || v_numlineaf || ', field: ' ||
                              v_currfield);
            RETURN 9907933;
            -- Data Error. Check character length OR NUMBER format
         WHEN OTHERS THEN
            dbms_output.put_line(dbms_utility.format_error_backtrace);
            ROLLBACK;
            utl_file.fclose(v_file);
            p_controlar_error(7,
                              1,
                              f_axis_literales(103187,
                                               pac_md_common.f_get_cxtidioma()));
            RETURN 103187;
            -- An error has occurred while reading the file
      END;

   EXCEPTION
      WHEN e_errdatos THEN
         ROLLBACK;
         p_tab_error(f_sysdate,
                     f_user,
                     vobj,
                     vlin,
                     vpar,
                     SQLCODE || chr(10) || vnum_err);
         dbms_output.put_line(dbms_utility.format_error_backtrace);
         RETURN vnum_err;
      WHEN errorini THEN
         ROLLBACK;
         p_tab_error(f_sysdate,
                     f_user,
                     vobj,
                     vlin,
                     vpar,
                     SQLCODE || chr(10) || vnum_err);
         dbms_output.put_line(dbms_utility.format_error_backtrace);
         RETURN 108953;
         -- A runtime error has occurred
   END  f_pais_r_ejecutargafichero;
   -- FIN -- IAXIS-4242 - 23/05/2019   -JLTS Ajuste de la carga f_pais_r_ejecutargafichero
END pac_cargas_fin_conf;

/

  GRANT EXECUTE ON "AXIS"."PAC_CARGAS_FIN_CONF" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CARGAS_FIN_CONF" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CARGAS_FIN_CONF" TO "PROGRAMADORESCSI";
