--------------------------------------------------------
--  DDL for Package Body PAC_CONVENIOS_EMP
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY PAC_CONVENIOS_EMP AS
   /*************************************************************
      F_GET_DATOSCONVEMPVERS: Obtener datos cnvenio/versión
      Devuelve:  0 - ok
              nnnn - Error
      1.0       10/05/2019  ECP       1. IAXIS -3631. Cambio de Estado cuando las pòlizas estàn vencidas
   **************************************************************/
   TYPE versiones IS RECORD(
      idconv         cnv_conv_emp_vers.idconv%TYPE,
      idversion      cnv_conv_emp_vers.idversion%TYPE
   );

   TYPE cnvconvempvers IS TABLE OF versiones
      INDEX BY BINARY_INTEGER;

   rec_vers       versiones;
   tab_vers       cnvconvempvers;
   posicion       BINARY_INTEGER;

   FUNCTION f_get_datosconvempvers(
      psseguro IN NUMBER,
      pidversion IN NUMBER,
      pmodo IN VARCHAR2,
      pidconv OUT NUMBER,
      ptcodconv OUT VARCHAR2,
      ptdescri OUT VARCHAR2,
      pcestado OUT NUMBER,
      pcperfil OUT NUMBER,
      pcvida OUT NUMBER,
      pcorganismo OUT NUMBER,
      pnversion OUT NUMBER,
      pcestadovers OUT NUMBER,
      pnversion_ant OUT NUMBER,
      pobserv OUT VARCHAR2)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'param - psseguro: ' || psseguro || ' idversion: ' || pidversion || ' modo:'
            || pmodo;
      vobject        VARCHAR2(200) := 'PAC_CONVENIOS_EMP.F_GET_DATOSCONVEMPVERS';
      lsseguro       seguros.sseguro%TYPE;
      lcidioma       NUMBER := pac_md_common.f_get_cxtidioma;
      ltexto         VARCHAR2(100);
      vtdescri       VARCHAR2(500);
      vcprovin       NUMBER;
      vccaa          NUMBER;
      vcpais         NUMBER;
   BEGIN
      --
      SELECT c.idconv, c.tcodconv, c.cestado, c.cperfil, CV.cvida, c.corganismo, c.tdescri,
             CV.nversion, CV.cestado, CV.tobserv, c.cpais, c.ccaa, c.cprovin
        INTO pidconv, ptcodconv, pcestado, pcperfil, pcvida, pcorganismo, vtdescri,
             pnversion, pcestadovers, pobserv, vcpais, vccaa, vcprovin
        FROM cnv_conv_emp c, cnv_conv_emp_vers CV
       WHERE CV.idversion = pidversion
         AND c.idconv = CV.idconv;

      --
      IF pmodo = 'EST' THEN
         BEGIN
            SELECT ssegpol
              INTO lsseguro
              FROM estseguros
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS THEN
               ltexto := f_axis_literales(140897, lcidioma);
               p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                           ltexto || ' ' || SQLCODE || ' - ' || SQLERRM);
               -- Error al buscar la póliza
               RETURN 140897;
         END;
      ELSE
         lsseguro := psseguro;
      END IF;

      --
      BEGIN
         SELECT nversion
           INTO pnversion_ant
           FROM cnv_conv_emp_seg cs, cnv_conv_emp_vers CV
          WHERE cs.idversion = CV.idversion
            AND sseguro = lsseguro
            AND pac_convenios_emp.f_ultverscnv_poliza(psseguro, pmodo) = CV.idversion
            AND cs.nmovimi = (SELECT MAX(cs2.nmovimi)
                                FROM cnv_conv_emp_seg cs2
                               WHERE cs2.sseguro = cs.sseguro
                                 AND cs2.idversion = cs.idversion);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            -- Puede que no existe version anterior
            pnversion_ant := NULL;
      END;

      --descripcion ambito convenio
      BEGIN
         SELECT vtdescri || '-' || tprovin
           INTO vtdescri
           FROM provincias
          WHERE cprovin = vcprovin;
      EXCEPTION
         WHEN OTHERS THEN
            vtdescri := vtdescri || '-';
      END;

      BEGIN
         SELECT vtdescri || '-' || tccaa
           INTO vtdescri
           FROM ccaas
          WHERE idccaa = vccaa;
      EXCEPTION
         WHEN OTHERS THEN
            vtdescri := vtdescri || '-';
      END;

      BEGIN
         SELECT vtdescri || '-' || tpais
           INTO vtdescri
           FROM paises
          WHERE cpais = vcpais;
      EXCEPTION
         WHEN OTHERS THEN
            vtdescri := vtdescri || '-';
      END;

      ptdescri := vtdescri;
      --
      RETURN 0;
   --
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         ltexto := f_axis_literales(9907513, lcidioma);
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, ltexto);
         RETURN 9907513;   -- No existe convenio/versión
      WHEN OTHERS THEN
         ltexto := f_axis_literales(108190, lcidioma);
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                     ltexto || ' ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 108190;   -- Error general
   END f_get_datosconvempvers;

   /******************************************************************************
       F_GET_DATOSCONVEMPVERS: Obtener la Versión/fecha efecto activa del convenio
       IN:  Identificador del convenio
       OUT: Identificador versión
            Fecha efecto versión
       Retorno:
               0 - O.K.
            nnnn - Código de error
   ******************************************************************************/
   FUNCTION f_get_versactivaconv(
      pidconv IN NUMBER,
      pidversion OUT NUMBER,
      pfefecto OUT DATE,
      pnversion OUT NUMBER)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'param - idconv: ' || pidconv;
      vobject        VARCHAR2(200) := 'PAC_CONVENIOS_EMP.F_GET_VERSACTIVACONV';
      vcuantos       NUMBER := 0;
      ltexto         VARCHAR2(100);
      lcidioma       NUMBER := pac_md_common.f_get_cxtidioma;
   BEGIN
      --
      FOR i IN (SELECT CV.idversion, CV.fefecto, CV.nversion
                  FROM cnv_conv_emp c, cnv_conv_emp_vers CV
                 WHERE c.idconv = pidconv
                   AND c.idconv = CV.idconv
                   AND c.cestado = 1
                   AND CV.cestado = 1) LOOP
         pidversion := i.idversion;
         pfefecto := i.fefecto;
         pnversion := i.nversion;
         vcuantos := vcuantos + 1;
      END LOOP;

      --
      IF vcuantos = 0 THEN
         ltexto := f_axis_literales(9907514, lcidioma);
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, ltexto);
         -- No está activo el convenio/versió
         RETURN 9907514;
      ELSIF vcuantos > 1 THEN
         ltexto := f_axis_literales(9907515, lcidioma);
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, ltexto);
         -- Existe más de un convenio/versión activos
         RETURN 9907515;
      END IF;

      RETURN 0;
   --
   EXCEPTION
      WHEN OTHERS THEN
         ltexto := f_axis_literales(108190, lcidioma);
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                     ltexto || ' ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 108190;   -- Error general
   END f_get_versactivaconv;

   /******************************************************************
       F_ES_POLIZACONVENIOS: Obtener si la póliza es de convenios
       Devuelve:  1 - Si es convenios
               nnnn - No es de convenios (msj de error)
   *******************************************************************/
   FUNCTION f_es_polizaconvenios(psseguro IN NUMBER, pmodo IN VARCHAR2)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'param - psseguro: ' || psseguro || ' modo: ' || pmodo;
      vobject        VARCHAR2(200) := 'PAC_CONVENIOS_EMP.F_ES_POLIZACONVENIOS';
      lcagrpro       seguros.cagrpro%TYPE;
      ltexto         VARCHAR2(100);
      lcidioma       NUMBER := pac_md_common.f_get_cxtidioma;
   BEGIN
      --
      IF pmodo = 'EST' THEN
         SELECT cagrpro
           INTO lcagrpro
           FROM estseguros
          WHERE sseguro = psseguro
            AND cagrpro = 24;
      ELSE
         SELECT cagrpro
           INTO lcagrpro
           FROM seguros
          WHERE sseguro = psseguro
            AND cagrpro = 24;
      END IF;

      --
      RETURN 1;   -- Si es de convenios
   --
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         -- La póliza no pertenece a la agrupación de convenio
         ltexto := f_axis_literales(9907516, lcidioma);
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, ltexto);
         RETURN 9907516;
      WHEN OTHERS THEN
         ltexto := f_axis_literales(108190, lcidioma);
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                     ltexto || ' ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 108190;   -- Error general
   END f_es_polizaconvenios;

   /******************************************************************
       F_ES_PRODUCTOCONVENIOS: Obtener si el producto es de convenios
       Devuelve:  1 - Si es convenios
               nnnn - No es de convenios (msj de error)
   *******************************************************************/
   FUNCTION f_es_productoconvenios(psproduc IN NUMBER)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'param - psproduc: ' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_CONVENIOS_EMP.F_ES_PRODUCTOCONVENIOS';
      lcagrpro       seguros.cagrpro%TYPE;
      ltexto         VARCHAR2(100);
      lcidioma       NUMBER := pac_md_common.f_get_cxtidioma;
   BEGIN
      --
      BEGIN
         SELECT cagrpro
           INTO lcagrpro
           FROM productos
          WHERE sproduc = psproduc
            AND cagrpro = 24;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            -- El producto no pertenece a la agrupación de convenio
            RETURN 9907517;
      END;

      --
      RETURN 1;
   --
   EXCEPTION
      WHEN OTHERS THEN
         ltexto := f_axis_literales(108190, lcidioma);
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                     ltexto || ' ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 108190;   -- Error general
   END f_es_productoconvenios;

   /******************************************************************
       F_CONV_POLIZA: Obtiene el convenio de la póliza
       Devuelve:  null - No se ha encontrado el convenio asociado a la póliza
                  nnnn - Convenio
   *******************************************************************/
   FUNCTION f_conv_poliza(psseguro IN NUMBER, pmodo IN VARCHAR2)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'param - psseguro: ' || psseguro || ' modo: ' || pmodo;
      vobject        VARCHAR2(200) := 'PAC_CONVENIOS_EMP.F_CNV_POLIZA';
      lidconv        cnv_conv_emp_vers.idconv%TYPE;
      lidversion     cnv_conv_emp_vers.idversion%TYPE;
      num_err        NUMBER;
      ltexto         VARCHAR2(100);
      lcidioma       NUMBER := pac_md_common.f_get_cxtidioma;
   BEGIN
      --
      num_err := pac_convenios_emp.f_es_polizaconvenios(psseguro, pmodo);

      IF num_err <> 1 THEN
         RETURN NULL;
      END IF;

      --
      lidconv := NULL;
      lidversion := pac_convenios_emp.f_ultverscnv_poliza(psseguro, pmodo);

      IF lidversion IS NOT NULL THEN
         BEGIN
            SELECT idconv
              INTO lidconv
              FROM cnv_conv_emp_vers
             WHERE idversion = lidversion;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               ltexto := f_axis_literales(9907518, lcidioma);
               p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, ltexto);
               lidconv := NULL;
         END;
      ELSE
         ltexto := f_axis_literales(9907518, lcidioma);
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, ltexto);
      END IF;

      --
      RETURN lidconv;
   --
   EXCEPTION
      WHEN OTHERS THEN
         ltexto := f_axis_literales(108190, lcidioma);
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                     ltexto || ' ' || SQLCODE || ' - ' || SQLERRM);
         RETURN NULL;
   END f_conv_poliza;

   /******************************************************************
       F_ULTVERSCNV_POLIZA: Obtiene la versión actual de la póliza
       Devuelve:  null - No se ha encontrado la versión de la póliza
                  nnnn - Versión de la póliza
   *******************************************************************/
   FUNCTION f_ultverscnv_poliza(psseguro IN NUMBER, pmodo IN VARCHAR2)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'param - psseguro: ' || psseguro || ' modo: ' || pmodo;
      vobject        VARCHAR2(200) := 'PAC_CONVENIOS_EMP.F_ULTVERSCNV_POLIZA';
      lidversion     cnv_conv_emp_seg.idversion%TYPE;
      num_err        NUMBER;
      ltexto         VARCHAR2(100);
      lcidioma       NUMBER := pac_md_common.f_get_cxtidioma;
   BEGIN
      --
      IF pmodo = 'EST' THEN
         BEGIN
            SELECT idversion
              INTO lidversion
              FROM estcnv_conv_emp_seg
             WHERE sseguro = psseguro
               AND nmovimi = (SELECT MAX(nmovimi)
                                FROM estcnv_conv_emp_seg
                               WHERE sseguro = psseguro);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               -- No se ha encotrado la versión de la póliza
               ltexto := f_axis_literales(9907519, lcidioma);
               p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                           ltexto || ' ' || SQLCODE || ' - ' || SQLERRM);
               lidversion := NULL;
         END;
      ELSE
         BEGIN
            SELECT idversion
              INTO lidversion
              FROM cnv_conv_emp_seg
             WHERE sseguro = psseguro
               AND nmovimi = (SELECT MAX(nmovimi)
                                FROM cnv_conv_emp_seg
                               WHERE sseguro = psseguro);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               -- No se ha encotrado la versión de la póliza
               ltexto := f_axis_literales(9907519, lcidioma);
               p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                           ltexto || ' ' || SQLCODE || ' - ' || SQLERRM);
               lidversion := NULL;
         END;
      END IF;

      --
      RETURN lidversion;
   --
   EXCEPTION
      WHEN OTHERS THEN
         ltexto := f_axis_literales(108190, lcidioma);
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                     ltexto || ' ' || SQLCODE || ' - ' || SQLERRM);
         RETURN NULL;
   END f_ultverscnv_poliza;

   /******************************************************************
       F_GET_CONVCONTRATABLE: Indica si un convenio es contratable
       Devuelve:
   *******************************************************************/
   FUNCTION f_get_convcontratable(
      pvers IN ob_iax_convempvers,
      pcempres IN NUMBER,
      pesaviso OUT NUMBER)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'param - psseguro: ' || 'NULL';
      vobject        VARCHAR2(200) := 'PAC_CONVENIOS_EMP.F_GET_CONVCONTRATABLE';
      num_err        NUMBER;
      ltexto         VARCHAR2(100);
      lcidioma       NUMBER := pac_md_common.f_get_cxtidioma;
      vtipousuario   NUMBER := 1;
      vcrealiza      NUMBER;
   BEGIN
      --
      pesaviso := 0;
      vtipousuario := pac_cfg.f_get_user_accion_permitida(f_user, 'TODOS_CONVENIOS', 0,
                                                          pcempres,   -- BUG9981:DRA:06/05/2009
                                                          vcrealiza);

      IF pvers.cperfil = 4 THEN
         RETURN 9907638;
      END IF;

      IF pvers.cperfil = 3
         AND vtipousuario = 0 THEN
         RETURN 9907637;
      END IF;

      IF pvers.nversion IS NULL THEN
         RETURN 9907639;
      END IF;

      RETURN 0;
   --
   EXCEPTION
      WHEN OTHERS THEN
         ltexto := f_axis_literales(108190, lcidioma);
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                     ltexto || ' ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 108190;
   END f_get_convcontratable;

   /******************************************************************
       F_PROCESO_CAMB_VERSCON: Proceso Masivo de cambio de version
       Devuelve:     0 - O.K.
                  nnnn - Error (literal)
                  -1   - Error when others
   *******************************************************************/
   FUNCTION f_proceso_camb_verscon(
      ptcodconv IN VARCHAR2,
      pcidioma IN NUMBER,
      psproces OUT NUMBER)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
                               := 'param - Convenio: ' || ptcodconv || ' Idioma: ' || pcidioma;
      vobject        VARCHAR2(200) := 'PAC_CONVENIOS_EMP.F_PROCESO_CAMB_VERSCON';
      num_err        NUMBER;
      ltexto         VARCHAR2(200);
      lsproces       procesoscab.sproces%TYPE;   -- Nro de Proceso
      lnerror        NUMBER;   -- Nro de errores
      lnumlin        NUMBER;
      lfefecto       cnv_conv_emp_vers.fefecto%TYPE;   -- Fecha efecto versión
      lidversion     cnv_conv_emp_vers.idversion%TYPE;   -- Identif. versión
      lnversion      cnv_conv_emp_vers.nversion%TYPE;   -- N. versión
      pnmovimi       movseguro.nmovimi%TYPE;   -- nro movimiento póliza
      lcempres       NUMBER := pac_contexto.f_contextovalorparametro('IAX_EMPRESA');
      vfefecto       DATE;

      -- Cursor de convenios activos
      CURSOR c_cnv IS
         SELECT   *
             FROM cnv_conv_emp
            WHERE cestado = 1
              AND(tcodconv = ptcodconv
                  OR ptcodconv IS NULL)   -- BUG 0039481 - FAL - 27/01/2016 - No procesaba los convenios con descripción numérica
--              AND tcodconv BETWEEN NVL(ptcodconv, 'AAAAAAAAAAAAAAAAAAAA') AND NVL(ptcodconv, 'ZZZZZZZZZZZZZZZZZZZZ')
         ORDER BY idconv;

      -- Cursor de pólizas
      CURSOR c_pol(vidconv IN NUMBER, vidversion IN NUMBER) IS
         SELECT   s.*
             FROM seguros s, cnv_conv_emp_seg cs, cnv_conv_emp_vers CV
            WHERE s.csituac IN(0, 5)
              AND((NVL(f_parproductos_v(sproduc, 'ADMITE_CERTIFICADOS'), 0) = 1
                   AND s.ncertif <> 0)
                  OR(NVL(f_parproductos_v(sproduc, 'ADMITE_CERTIFICADOS'), 0) = 0
                     AND s.ncertif = 0))
              -- AND pac_convenios_emp.f_conv_poliza(s.sseguro, 'SEG') = vidconv
              AND s.cagrpro = 24
              AND CV.idversion = cs.idversion
              AND CV.idconv = vidconv
              -- AND pac_convenios_emp.f_ultverscnv_poliza(sseguro, 'SEG') <> vidversion
              AND cs.sseguro = s.sseguro
              AND cs.nmovimi = (SELECT MAX(nmovimi)
                                  FROM cnv_conv_emp_seg
                                 WHERE sseguro = s.sseguro)
              AND cs.idversion <> vidversion
         ORDER BY s.sproduc, s.npoliza, s.ncertif;
   BEGIN
      IF ptcodconv IS NULL THEN
         ltexto := f_axis_literales(9907520, pcidioma);
      ELSE
         ltexto := f_axis_literales(9907521, pcidioma) || ' ' || ptcodconv;
      END IF;

      -- Se crea un proceso para el control de errores
      num_err := f_procesini(f_user, lcempres, 'CMBVERSCONVENIO',
                             lcempres || ' ' || ltexto || ' ' || f_sysdate, lsproces);
      lnerror := 0;

      --
      FOR cnv IN c_cnv LOOP
         num_err := pac_convenios_emp.f_get_versactivaconv(cnv.idconv, lidversion, lfefecto,
                                                           lnversion);

         IF num_err <> 0 THEN
            lnerror := lnerror + 1;
            -- Error que retorna la función
            ltexto := f_axis_literales(num_err, pcidioma);
            lnumlin := NULL;
            num_err := f_proceslin(lsproces, ltexto, 0, lnumlin);
         END IF;

         --
         FOR pol IN c_pol(cnv.idconv, lidversion) LOOP
            IF pac_seguros.f_es_col_admin(pol.sseguro, 'SEG') = 1 THEN
               lnerror := lnerror + 1;
               -- Las pólizas administradas no están permitidas en convenios
               ltexto := f_axis_literales(9907522, pcidioma);
               lnumlin := NULL;
               num_err := f_proceslin(lsproces, ltexto, pol.sseguro, lnumlin);
            END IF;

            --
            -- Ini IAXIS-3631 -- ECP -- 10/05/2019
            IF (pol.csituac not in (0,3)
                OR pol.creteni <> 0) THEN
               lnerror := lnerror + 1;
               -- La póliza no está en situación de hacer suplementos
               ltexto := f_axis_literales(104257, pcidioma);
               ltexto := ltexto || ' csituac : ' || pol.csituac || ' creteni : '
                         || pol.creteni;
               lnumlin := NULL;
               num_err := f_proceslin(lsproces, ltexto, pol.sseguro, lnumlin);
            END IF;
           -- Fin IAXIS-3631 -- ECP -- 10/05/2019
            --
            -- FALTA VALIDACIÓN DEL HISTORICO SI EXISTE ALGUNA OTRA VERSION ACTIVA
            --
            vfefecto := GREATEST(lfefecto, pol.fefecto);
            num_err := pac_sup_general.f_cambio_verscon(pol.sseguro, vfefecto, 962, pnmovimi,
                                                        lsproces);

            --
            IF num_err <> 0 THEN
               lnerror := lnerror + 1;
               -- Error que retorna la función
               ltexto := f_axis_literales(num_err, pcidioma);
               lnumlin := NULL;
               num_err := f_proceslin(lsproces, ltexto, pol.sseguro, lnumlin);
            END IF;
         END LOOP;
      --
      END LOOP;

      --
      num_err := f_procesfin(lsproces, lnerror);
      --
      psproces := lsproces;

      IF lnerror = 0 THEN
         RETURN 0;
      ELSE
         -- Proceso finalizado con errores
         RETURN 9901850;
      END IF;
   --
   EXCEPTION
      WHEN OTHERS THEN
         ltexto := f_axis_literales(108190, pcidioma);
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                     ltexto || ' ' || SQLCODE || ' - ' || SQLERRM);
         num_err := f_proceslin(lsproces, ltexto, 0, lnumlin);
         psproces := lsproces;
         RETURN 108190;
   END f_proceso_camb_verscon;

   /******************************************************************
       F_VERSION_A_ANULAR: Indica que versión podemos cancelar en el
                  proceso de cancelación de versión para un Convenio
       Devuelve:     0 - O.K.
                  nnnn - Error (literal)
                  -1   - Error when others
   *******************************************************************/
   FUNCTION f_version_a_anular(ptcodconv IN VARCHAR2, pcoderror OUT NUMBER)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'param - Convenio: ' || ptcodconv;
      vobject        VARCHAR2(200) := 'PAC_CONVENIOS_EMP.F_VERSION_A_ANULAR';
      num_err        NUMBER;
      --
      lidversion     cnv_conv_emp_vers.idversion%TYPE;
      ltexto         VARCHAR2(100);
      lcidioma       NUMBER := pac_md_common.f_get_cxtidioma;
   --
   BEGIN
      pcoderror := 0;

      SELECT MAX(idversion)
        INTO lidversion
        FROM cnv_conv_emp c, cnv_conv_emp_vers CV
       WHERE c.tcodconv = ptcodconv
         AND c.idconv = CV.idconv
         AND CV.cestado IN(1, 2);

      --
      RETURN lidversion;
   --
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         -- No hi ha una versió activa / no validada per al conveni
         pcoderror := 9907524;
         RETURN NULL;
      WHEN OTHERS THEN
         ltexto := f_axis_literales(108190, lcidioma);
         pcoderror := 108190;
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                     ltexto || ' ' || SQLCODE || ' - ' || SQLERRM);
         RETURN NULL;
   END f_version_a_anular;

   /******************************************************************
       F_PROCESO_ANUL_VERSCON: Proceso Masivo masivo de anulación
               de cambio de versión de un convenio en particular.
       Devuelve:     0 - O.K.
                  nnnn - Error (literal)
                  -1   - Error when others
   *******************************************************************/
   FUNCTION f_proceso_anul_verscon(
      ptcodconv IN VARCHAR2,
      pcidioma IN NUMBER,
      psproces OUT NUMBER)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
                               := 'param - Convenio: ' || ptcodconv || ' Idioma: ' || pcidioma;
      vobject        VARCHAR2(200) := 'PAC_CONVENIOS_EMP.F_PROCESO_ANUL_VERSCON';
      num_err        NUMBER;
      lerror         NUMBER;   -- Retorno de la función procesoslin
      ltexto         VARCHAR2(200);
      lsproces       procesoscab.sproces%TYPE;   -- Nro de Proceso
      lnerror        NUMBER;   -- Nro de errores
      lnumlin        NUMBER;
      lfecultmod     cnv_conv_emp_vers.fmodifi%TYPE;   -- Fecha de modificacion
      lidconv        cnv_conv_emp_vers.idconv%TYPE;   -- Identif. convenio
      lidversion     cnv_conv_emp_vers.idversion%TYPE;   -- Identif. versión
      lnsuplem       seguros.nsuplem%TYPE;
      ltobserva      motreten_rev.tobserva%TYPE;
      lmaxnmovimi    movseguro.nmovimi%TYPE;   -- nro movimiento maximo de la póliza
      lnrecibo       recibos.nrecibo%TYPE;   -- Nro recibo del movto de cambio
      lcempres       NUMBER := pac_contexto.f_contextovalorparametro('IAX_EMPRESA');

      -- Cursor de pólizas
      CURSOR c_pol(vidconv IN NUMBER, vidversion IN NUMBER) IS
         SELECT   s.*, cs.nmovimi
             FROM seguros s, cnv_conv_emp_seg cs, movseguro m
            WHERE s.csituac NOT IN(2, 3)
              AND s.sseguro = cs.sseguro
              AND cs.idversion = vidversion
              AND pac_convenios_emp.f_conv_poliza(s.sseguro, 'SEG') = vidconv
              AND pac_convenios_emp.f_ultverscnv_poliza(s.sseguro, 'SEG') = vidversion
              AND m.sseguro = s.sseguro
              AND m.cmotmov IN(100, 962)
              AND m.cmovseg <> 52
              AND m.nmovimi = cs.nmovimi
         -- AND s.sseguro = 153
         ORDER BY s.npoliza, s.ncertif;
   BEGIN
      -- Se crea un proceso para el control de errores

      -- Anulación masiva del suplemento de cambio de versión
      ltexto := f_axis_literales(9907523, pcidioma) || ptcodconv;
      num_err := f_procesini(f_user, lcempres, 'ANUCMBVERSCONV',
                             lcempres || ' ' || ltexto || ' ' || f_sysdate, lsproces);
      lnerror := 0;
      --
      lidversion := pac_convenios_emp.f_version_a_anular(ptcodconv, num_err);

      IF num_err <> 0 THEN
         lnerror := lnerror + 1;
         -- Error que retorna la función
         ltexto := f_axis_literales(num_err, pcidioma);
         lnumlin := NULL;
         lerror := f_proceslin(lsproces, ltexto, 0, lnumlin);
         RETURN num_err;
      END IF;

      --
      BEGIN
         SELECT fmodifi, idconv
           INTO lfecultmod, lidconv
           FROM cnv_conv_emp_vers
          WHERE idversion = lidversion;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            lnerror := lnerror + 1;
            -- No existe convenio/version
            ltexto := f_axis_literales(9907513, pcidioma);
            lnumlin := NULL;
            lerror := f_proceslin(lsproces, ltexto, 0, lnumlin);
            RETURN 9907513;
      END;

      --
      /*IF (f_sysdate - lfecultmod) > f_parempresa_t('DIAS_CANC_VERSION') THEN
         lnerror := lnerror + 1;
         -- Error se han superado los dias permitidos para cancelar la versión
         ltexto := f_axis_literales(9907525, pcidioma);
         lnumlin := NULL;
         lerror := f_proceslin(lsproces, ltexto, 0, lnumlin);
         RETURN 9907525;
      END IF;*/

      --
      -- Se buscan las pólizas
      FOR pol IN c_pol(lidconv, lidversion) LOOP   -- Procesamos todo en bloque como una transacción puesto que a lo sumo habrán 1000 pólizas por convenio (puede tardar como mucho 15 min. el proceso).
         -- Valida si el movimiento se ha realizado en la nueva producción
         IF pol.nmovimi = 1 THEN
            lnerror := lnerror + 1;
            -- Existen pólizas de nueva producción, no se puede cancelar el proceso
            ltexto := f_axis_literales(9907526, pcidioma);
            lnumlin := NULL;
            lerror := f_proceslin(lsproces, ltexto, pol.sseguro, lnumlin);
            RETURN 9907526;
         END IF;

         --
         BEGIN
            SELECT MAX(nmovimi)
              INTO lmaxnmovimi
              FROM movseguro
             WHERE sseguro = pol.sseguro
               AND cmovseg <> 52;

            lmaxnmovimi := NVL(lmaxnmovimi, 0);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               lmaxnmovimi := 0;
            WHEN OTHERS THEN
               -- Nro de movto no encontrado en MOVSEGURO
               ltexto := f_axis_literales(104348, pcidioma);
               p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                           ltexto || ' ' || SQLCODE || ' - ' || SQLERRM);
               lnerror := lnerror + 1;
               lerror := f_proceslin(lsproces, ltexto, pol.sseguro, lnumlin);
               RETURN 104348;
         END;

         -- Valida si existen movimientos posteriores al del cambio de versión
         IF pol.nmovimi <> lmaxnmovimi THEN
            lnerror := lnerror + 1;
            -- Existen pólizas con cambios posteriores. No se puede cancelar el proceso.
            ltexto := f_axis_literales(9907527, pcidioma);
            lnumlin := NULL;
            lerror := f_proceslin(lsproces, ltexto, pol.sseguro, lnumlin);
            RETURN 9907527;
         END IF;

         -- Valida si el movimiento a generado recibos y no está en estado pendiente
         FOR regrec IN (SELECT nrecibo
                          INTO lnrecibo
                          FROM recibos
                         WHERE sseguro = pol.sseguro
                           AND nmovimi = pol.nmovimi) LOOP
            --
            IF regrec.nrecibo IS NOT NULL THEN
               num_err := f_cestrec_mv(lnrecibo, pcidioma);

               IF num_err IN(1, 3) THEN   --JRH Está cobrado o en gestión de cobro
                  lnerror := lnerror + 1;
                  -- Existen recibos que NO estan pendientes. No se puede cancelar el proceso.
                  ltexto := f_axis_literales(9907528, pcidioma);
                  lnumlin := NULL;
                  lerror := f_proceslin(lsproces, ltexto, pol.sseguro, lnumlin);
                  RETURN 9907528;
               END IF;
            END IF;
         END LOOP;

         IF pac_seguros.f_es_col_admin(pol.sseguro, 'SEG') = 1 THEN
            lnerror := lnerror + 1;
            -- Existen recibos que NO estan pendientes. No se puede cancelar el proceso.
            ltexto := f_axis_literales(9907522, pcidioma);
            lnumlin := NULL;
            lerror := f_proceslin(lsproces, ltexto, pol.sseguro, lnumlin);
            RETURN 9907522;
         END IF;

         --
         num_err := pk_rechazo_movimiento.f_rechazo(pol.sseguro, 962, lnsuplem, 3, ltobserva,
                                                    pol.nmovimi);

         --
         IF num_err <> 0 THEN
            lnerror := lnerror + 1;
            -- Error que retorna la función
            ltexto := f_axis_literales(num_err, pcidioma);
            lnumlin := NULL;
            lerror := f_proceslin(lsproces, ltexto, pol.sseguro, lnumlin);
            RETURN num_err;
         END IF;
      --
      END LOOP;

      -- Dejamos la versión como No Validada
      UPDATE cnv_conv_emp_vers
         SET cestado = 0
       WHERE idversion = lidversion;

      --
      lerror := f_procesfin(lsproces, lnerror);
      --
      psproces := lsproces;

      IF lnerror = 0 THEN
         RETURN 0;
      ELSE
         -- Proceso finalizado con errores
         RETURN 9901850;
      END IF;
   --
   EXCEPTION
      WHEN OTHERS THEN
         ltexto := f_axis_literales(108190, pcidioma);
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                     ltexto || ' ' || SQLCODE || ' - ' || SQLERRM);
         num_err := f_proceslin(lsproces, ltexto, 0, lnumlin);
         psproces := lsproces;
         RETURN 108190;
   END f_proceso_anul_verscon;

   /******************************************************************************
       F_GET_DATOSCONVEMPVERS: Obtener la Versión/fecha efecto activa del convenio
       IN:  Identificador del convenio
       OUT: Identificador versión
            Fecha efecto versión
       Retorno:
               0 - O.K.
            nnnn - Código de error
   ******************************************************************************/
   FUNCTION f_get_versactivaconv_selet(pidconv IN NUMBER, pdata IN NUMBER)
      RETURN VARCHAR2 IS
      v_resp         VARCHAR2(20) := NULL;
      idversion      NUMBER;
      lnversion      cnv_conv_emp_vers.nversion%TYPE;   -- N. versión
      fefecto        DATE;
      erro           NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'param - idconv: ' || pidconv;
      vobject        VARCHAR2(200) := 'PAC_CONVENIOS_EMP.F_GET_VERSACTIVACONV_SELECT';
      lcidioma       NUMBER := pac_md_common.f_get_cxtidioma;
      ltexto         VARCHAR2(100);
   BEGIN
      erro := f_get_versactivaconv(pidconv, idversion, fefecto, lnversion);

      IF erro = 0 THEN
         IF pdata = 1 THEN
            v_resp := TO_CHAR(idversion);
         ELSIF pdata = 2 THEN
            v_resp := TO_CHAR(fefecto, 'DD/MM/YYYY');
         ELSIF pdata = 3 THEN
            v_resp := TO_CHAR(lnversion);
         END IF;
      ELSE
         ltexto := f_axis_literales(108190, lcidioma);
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                     ltexto || ' ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 108190;   -- Error general
      END IF;

      RETURN v_resp;
   EXCEPTION
      WHEN OTHERS THEN
         ltexto := f_axis_literales(108190, lcidioma);
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                     ltexto || ' ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 108190;   -- Error general
   END f_get_versactivaconv_selet;

   PROCEDURE p_inicia IS
   BEGIN
      posicion := 0;
      tab_vers.DELETE;
   END;

   PROCEDURE p_inserta_version(
      pidconvenio IN cnv_conv_emp_vers.idconv%TYPE,
      pidversion IN cnv_conv_emp_vers.idversion%TYPE) IS
   BEGIN
      posicion := posicion + 1;
      rec_vers.idconv := pidconvenio;
      rec_vers.idversion := pidversion;
      tab_vers(posicion) := rec_vers;
   END;

   PROCEDURE p_valida_trigger(pinserta IN NUMBER) IS
      vfefecto       DATE;
      vfvencimant    DATE;
      vfvencim       DATE;
      vnum           NUMBER;
      vidversion     NUMBER;
      vidversionant  NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200);
      vobject        VARCHAR2(200) := 'PAC_CONVENIOS_EMP.p_valida_trigger';
      --Bug 34461 209377 KJSC 07/07/2015 CREACION DE LOS MENSAJES
      ltexto         VARCHAR2(100);
      lcidioma       NUMBER := 2;   --pac_md_common.f_get_cxtidioma; por skype Jordi Vidal envia cambio.
      vfinivig       DATE;
      vffinvig       DATE;
      vcestado       NUMBER;
      vcestadoant    NUMBER;
   BEGIN
      WHILE posicion > 0 LOOP
         BEGIN
            rec_vers := tab_vers(posicion);

            BEGIN
               SELECT fvencim, c.idversion, c.cestado
                 INTO vfvencimant, vidversionant, vcestadoant
                 FROM cnv_conv_emp_vers c
                WHERE c.idconv = rec_vers.idconv
                  AND c.idversion = (SELECT MAX(idversion)
                                       FROM cnv_conv_emp_vers d
                                      WHERE d.idconv = rec_vers.idconv
                                        AND d.idversion < rec_vers.idversion);
            EXCEPTION
               WHEN OTHERS THEN
                  vfvencimant := NULL;
            END;

            BEGIN
               SELECT fefecto, fvencim, finivig, ffinvig, cestado
                 INTO vfefecto, vfvencim, vfinivig, vffinvig, vcestado
                 FROM cnv_conv_emp_vers
                WHERE idconv = rec_vers.idconv
                  AND idversion = rec_vers.idversion;
            EXCEPTION
               WHEN OTHERS THEN
                  vfvencim := vfvencimant;
                  vfefecto := vfvencim;
            END;

            --Bug 34461 209377 KJSC 07/07/2015 CREACION DE LOS MENSAJES Y LAS VALIDACIONES DEL TRIGGER VALIDACIONES_CONVENIOS
            --'La Fecha de efecto tiene que ser menor que la fecha de vencimiento'
            IF vfvencim IS NOT NULL THEN
               IF vfvencim <= vfefecto THEN
                  ltexto := f_axis_literales(9908290, lcidioma);
                  raise_application_error(-20001, ltexto);
               END IF;
            END IF;

            --'La Fecha de inicio de vigencia tiene que ser menor que la fecha de fin de vigencia'
            IF vffinvig <= vfinivig THEN
               ltexto := f_axis_literales(9908291, lcidioma);
               raise_application_error(-20001, ltexto);
            END IF;

            IF DELETING THEN
               SELECT COUNT(1)
                 INTO vnum
                 FROM cnv_conv_emp_seg
                WHERE idversion = rec_vers.idversion;

               --'No se puede borrar una versión con pólizas dependientes'
               IF vnum > 0 THEN
                  ltexto := f_axis_literales(9908292, lcidioma);
                  raise_application_error(-20001, ltexto);
               END IF;

               --'No se puede borrar una versión activa o vencida'
               IF vcestado <> 0 THEN
                  ltexto := f_axis_literales(9908293, lcidioma);
                  raise_application_error(-20001, ltexto);
               END IF;
            END IF;

            IF vcestado = 0
               AND vcestadoant = 1 THEN
               SELECT COUNT(1)
                 INTO vnum
                 FROM cnv_conv_emp_seg
                WHERE idversion = rec_vers.idversion;

               --'No se puede cambiar el estado a versión con pólizas dependientes'
               IF vnum > 0 THEN
                  ltexto := f_axis_literales(9908294, lcidioma);
                  raise_application_error(-20001, ltexto);
               END IF;

               --'Una versión no validada no debe tener fecha de vencimiento informada'
               IF vfvencim IS NOT NULL THEN
                  ltexto := f_axis_literales(9908295, lcidioma);
                  raise_application_error(-20001, ltexto);
               END IF;
            END IF;

            --'Una versión vencida debe tener fecha de vencimiento informada'
            IF vcestado = 2
               AND vcestadoant = 1 THEN
               IF vfvencim IS NULL THEN
                  ltexto := f_axis_literales(9908296, lcidioma);
                  raise_application_error(-20001, ltexto);
               END IF;
            END IF;

            --'La Fecha de efecto tiene que ser igual a la fecha de vencimiento del movimiento anterior'
            IF vfvencimant IS NOT NULL THEN
               IF vfvencimant <> vfefecto THEN
                  ltexto := f_axis_literales(9908283, lcidioma);
                  raise_application_error(-20001, ltexto);
               END IF;
            END IF;

            IF vfvencim IS NULL THEN
               SELECT COUNT(1)
                 INTO vnum
                 FROM cnv_conv_emp_vers
                WHERE idconv = rec_vers.idconv
                  AND idversion <> rec_vers.idversion
                  AND fvencim IS NULL;

               --'Solo una única versión puede tener la fecha de vencimiento no informada'
               IF vnum > 0 THEN
                  ltexto := f_axis_literales(9908284, lcidioma);
                  raise_application_error(-20001, ltexto);
               END IF;
            END IF;

            SELECT COUNT(1)
              INTO vnum
              FROM cnv_conv_emp_vers
             WHERE idconv = rec_vers.idconv
               AND cestado = 1;

            --'Solo puede haber una única versión activa'
            IF vnum > 1 THEN
               ltexto := f_axis_literales(9908285, lcidioma);
               raise_application_error(-20001, ltexto);
            END IF;

            IF vnum = 1 THEN
               BEGIN
                  SELECT idversion
                    INTO vidversion
                    FROM cnv_conv_emp_vers
                   WHERE idconv = rec_vers.idconv
                     AND cestado = 1;
               EXCEPTION
                  WHEN OTHERS THEN
                     vidversion := NULL;
               END;

               SELECT COUNT(1)
                 INTO vnum
                 FROM cnv_conv_emp_vers
                WHERE idconv = rec_vers.idconv
                  AND idversion < vidversion
                  AND cestado <> 2;

               --'Las versiones anteriores a la versión activa, han de estar vencidas'
               IF vnum > 1 THEN
                  ltexto := f_axis_literales(9908286, lcidioma);
                  raise_application_error(-20001, ltexto);
               END IF;

               SELECT COUNT(1)
                 INTO vnum
                 FROM cnv_conv_emp_vers
                WHERE idconv = rec_vers.idconv
                  AND idversion > vidversion
                  AND cestado <> 0;

               --'Las versiones posteriores a la versión activa, han de estar no validadas'
               IF vnum > 0 THEN
                  ltexto := f_axis_literales(9908287, lcidioma);
                  raise_application_error(-20001, ltexto);
               END IF;
            END IF;

            SELECT COUNT(1)
              INTO vnum
              FROM cnv_conv_emp_vers
             WHERE idconv = rec_vers.idconv
               AND fvencim IS NULL
               AND cestado <> 0;

            --'Solo una versión no validada puede tener la fecha de vencimiento no informada'
            IF vnum > 1 THEN
               ltexto := f_axis_literales(9908288, lcidioma);
               raise_application_error(-20001, ltexto);
            END IF;
         END;

         IF pinserta = 1 THEN
            SELECT COUNT(1)
              INTO vnum
              FROM cnv_conv_emp_vers_gar
             WHERE idversion = vidversionant;

            IF vnum > 0 THEN
               --duplicamos las garantias para esta version
               INSERT INTO cnv_conv_emp_vers_gar
                           (idversgar, idversion, cgarant, icapital, cobligatoria, numsalario,
                            cnivelr)
                  SELECT sidversgar.NEXTVAL, rec_vers.idversion, cgarant, icapital,
                         cobligatoria, numsalario, cnivelr
                    FROM cnv_conv_emp_vers_gar
                   WHERE idversion = vidversionant;
            END IF;
         -- BUG 0039481 - FAL - ´27/01/2016 - Al crear convenio desde ADF nunca hay una versión (vnum = 0 siempre) y no permite dar de alta 1 convenio. Se comenta
         /*
         SELECT COUNT(1)
           INTO vnum
           FROM cnv_conv_emp_vers
          WHERE idconv = rec_vers.idconv
            AND cestado = 1;

         --'Debe existir una versión activa por convenio'
         IF vnum = 0 THEN
            ltexto := f_axis_literales(9908289, lcidioma);
            raise_application_error(-20001, ltexto);
         END IF;
         */
         END IF;

         /* IF pinserta = 0 THEN
             --borramos las garantias de la version que vamos a eliminar
             DELETE FROM cnv_conv_emp_vers_gar
                   WHERE idversion = vidversionant;
          END IF;*/
         posicion := posicion - 1;
      END LOOP;
   END;
END pac_convenios_emp;

/

  GRANT EXECUTE ON "AXIS"."PAC_CONVENIOS_EMP" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CONVENIOS_EMP" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CONVENIOS_EMP" TO "PROGRAMADORESCSI";
