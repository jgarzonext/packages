--------------------------------------------------------
-- Archivo creado  - viernes-febrero-14-2020   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Package Body PAC_AVISOS_CONF
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY PAC_AVISOS_CONF 
IS
   /******************************************************************************
      NOMBRE:    pac_avisos_conf
      PROPÓSITO: Funciones para contragarantias

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        02/03/2016  JAE              1. Creación del objeto.
      2.0        27/02/2019  DFR              2. IAXIS-2416: Convenios-control de expedición
      3.0        06/05/2019  AABC             3. IAXIS-3597: proceso judicial
      4.0        28/08/2019  ECP              4. IAXIS-4985. Tarifa Endosos-Recargo
      5.0        26/09/2019  CJMR             5. IAXIS-3640. Movimientos negativos en moneda extranjera
      6.0        11/10/2019  ECP              6. IAXIS-4082. Convenio Grandes Beneficiarios - RCE Derivado de Contratos
      7.0        28/10/2019  CJMR             7. IAXIS-5422. Nota Beneficiario adicional
      8.0        01/11/2019  CJMR             8. IAXSI-5428. Validación de la comisión para poder tener corretaje
      9.0        04/12/2019  JLTS             9. IAXIS-3264. Se crea la función f_valida_recargo para la validación de la
                                                 pregunta Recargo comercial en baja de amparo debe ser igual a cero(0)
     10.0       12/02/2020   ECP            10. IAXIS-10560. Error validación TRM en endosos           
     11.0       26/03/2020   SP             11. IAXIS-13006 CAMBIOS DE WEB COMPLIANCE	 
   ******************************************************************************/
   --
   /*************************************************************************
      FUNCTION f_duplicidad_riesgo: Valida duplicidad de riesgo
      param IN psproduc   : Código del producto
      param IN psseguro   : Número identificativo interno de SEGUROS
      param IN pcidioma   : Código del Idioma
      param OUT ptmensaje : Mensajes de salida
      Devuelve            : 0 => No duplicidad  1 => Duplicidad
   *************************************************************************/
   FUNCTION f_duplicidad_riesgo (
      psproduc         IN       NUMBER,
      psseguro         IN       NUMBER,
      pcidioma         IN       NUMBER,
      parfix_nvalida   IN       NUMBER,
      ptmensaje        OUT      VARCHAR2
   )
      RETURN NUMBER
   IS
      --
      vpasexec   NUMBER          := 1;
      vobject    VARCHAR2 (200)  := 'PAC_AVISOS_CONF.f_duplicidad_riesgo';
      vparam     VARCHAR2 (300)
         :=    ' psproduc  ='
            || psproduc
            || ' - psseguro='
            || psseguro
            || ' - pcidioma='
            || pcidioma;
      --
      vnumerr    NUMBER          := 0;
      vquery     VARCHAR2 (2000);
   --
   BEGIN
      --
      ptmensaje := NULL;

      --
      IF    psproduc IS NULL
         OR psseguro IS NULL
         OR pcidioma IS NULL
         OR parfix_nvalida IS NULL
      THEN
         --
         RETURN 0;
      --
      END IF;

      --
      IF parfix_nvalida IS NOT NULL
      THEN
         --
         vquery :=
               'begin :v_param := pac_validaciones_conf.f_duplicidad_riesgo_'
            || parfix_nvalida
            || '(';
         vquery := vquery || psproduc;
         vquery := vquery || ', ' || psseguro;
         vquery := vquery || ', ' || pcidioma;
         vquery := vquery || ', :ptmensaje); end;';

         --
         EXECUTE IMMEDIATE vquery
                     USING OUT vnumerr, IN OUT ptmensaje;
      --
      END IF;

      --
      IF vnumerr != 0
      THEN
         --
         ptmensaje :=
               f_axis_literales (9908858, pcidioma)
            || '['
            || parfix_nvalida
            || ']'
            || ' : '
            || ptmensaje;
         --
         RETURN 1;
      --
      END IF;

      --
      RETURN 0;
   --
   EXCEPTION
      WHEN OTHERS
      THEN
         --
         ptmensaje := SQLCODE || ' - ' || SQLERRM;
         --
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                      'ERROR: ' || ptmensaje
                     );
         --
         RETURN 1;
   --
   END f_duplicidad_riesgo;

   --
   /*************************************************************************
      FUNCTION f_valida_plazo

      param in psseguro : Identificador seguro
      return            : NUMBER
   *************************************************************************/
   FUNCTION f_valida_plazo (psseguro IN NUMBER, ptmensaje OUT VARCHAR2)
      RETURN NUMBER
   IS
      --
      mensajes      t_iax_mensajes;
      vmesesretro   NUMBER;                                        --CONF-698
   --
   BEGIN
      --
      vmesesretro :=
         pac_parametros.f_parproducto_n
                               (pac_iax_produccion.poliza.det_poliza.sproduc,
                                'MESESRETRO'
                               );                                   --CONF-698

      --
      IF pac_iax_produccion.poliza.det_poliza IS NULL
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 1000644);
         RAISE e_param_error;
      END IF;

      IF NOT (pac_iax_produccion.poliza.det_poliza.gestion.fefeplazo
                 BETWEEN ADD_MONTHS
                           (TRUNC
                               (pac_iax_produccion.poliza.det_poliza.gestion.fefecto
                               ),
                            -vmesesretro
                           )
                     AND                                            --CONF-698
                        pac_iax_produccion.poliza.det_poliza.gestion.fvencim
             )
      THEN
         ptmensaje := f_axis_literales (9909284, f_idiomauser);
         RETURN 1;
      END IF;

      --
      IF NOT (pac_iax_produccion.poliza.det_poliza.gestion.fvencplazo
                 BETWEEN TRUNC
                           (pac_iax_produccion.poliza.det_poliza.gestion.fefecto
                           )
                     AND pac_iax_produccion.poliza.det_poliza.gestion.fvencim
             )
      THEN
         ptmensaje := f_axis_literales (9909284, f_idiomauser);
         RETURN 1;
      END IF;

      --
      RETURN 0;
   --
   EXCEPTION
      WHEN OTHERS
      THEN
         --
         ptmensaje := f_axis_literales (9909284, f_idiomauser);
         RETURN 1;
   --
   END f_valida_plazo;

   /*************************************************************************
      FUNCTION f_valida_vig_cob

      param in psseguro : Identificador seguro
      return            : NUMBER
   *************************************************************************/
   FUNCTION f_valida_vig_cob (psseguro IN NUMBER, ptmensaje OUT VARCHAR2)
      RETURN NUMBER
   IS
      --
      rie         ob_iax_riesgos;
      gars        t_iax_garantias;
      mensajes    t_iax_mensajes;
      f_fefecto   DATE;
      f_fvencim   DATE;
   --
   BEGIN
      --
      IF pac_iax_produccion.poliza.det_poliza IS NULL
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 1000644);
         RAISE e_param_error;
      END IF;

      --
      rie :=
         pac_iobj_prod.f_partpolriesgo (pac_iax_produccion.poliza.det_poliza,
                                        1,
                                        mensajes
                                       );

      --
      IF rie IS NULL
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 1000646);
         RAISE e_object_error;
      END IF;

      --
      gars := pac_iobj_prod.f_partriesgarantias (rie, mensajes);

      --
      IF mensajes IS NOT NULL
      THEN
         IF mensajes.COUNT > 0
         THEN
            RAISE e_object_error;
         END IF;
      END IF;

      --
      IF gars IS NOT NULL
      THEN
         IF gars.COUNT > 0
         THEN
            SELECT fefecto, fvencim
              INTO f_fefecto, f_fvencim
              FROM estseguros
             WHERE sseguro = psseguro;

            FOR vgar IN gars.FIRST .. gars.LAST
            LOOP
               IF     gars.EXISTS (vgar)
                  AND gars (vgar).finivig IS NOT NULL
                  AND gars (vgar).ffinvig IS NOT NULL
               THEN
                  IF    (gars (vgar).finivig NOT BETWEEN f_fefecto AND f_fvencim
                        )
                     OR (gars (vgar).ffinvig NOT BETWEEN f_fefecto AND f_fvencim
                        )
                  THEN
                     ptmensaje := f_axis_literales (9909282, f_idiomauser);
                     RETURN 1;
                  END IF;
               END IF;
            END LOOP;
         END IF;
      END IF;

      --
      RETURN 0;
   --
   EXCEPTION
      WHEN OTHERS
      THEN
         --
         ptmensaje := f_axis_literales (9909282, f_idiomauser);
         RETURN 1;
   --
   END f_valida_vig_cob;

   --
   FUNCTION f_valida_age_misma_sucursal (
      psseguro_carga   IN       NUMBER,
      pcagente_text    IN       NUMBER,
      ptmensaje        OUT      VARCHAR2
   )
      RETURN NUMBER
   IS
      vpasexec     NUMBER (8)             := 1;
      vparam       VARCHAR2 (100)         := NULL;
      vobject      VARCHAR2 (200)
                         := 'PAC_MD_VALIDACIONES.F_VALIDA_AGE_MISMA_SUCURSAL';
      vcagente     agentes.cagente%TYPE;
      v_contador   NUMBER;
   BEGIN
      BEGIN
         SELECT s.cagente
           INTO vcagente
           FROM seguros s
          WHERE s.sseguro = psseguro_carga;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            RETURN 100504;                              -- Agente inexistente
      END;

      vpasexec := 10;

      --Es un suplemento
      BEGIN
         SELECT COUNT (1)
           INTO v_contador
           FROM (SELECT    pac_redcomercial.f_busca_padre
                                    (pac_md_common.f_get_cxtempresa,
                                     vcagente,
                                     NULL,
                                     f_sysdate
                                    )
                        || ''
                        -  ''
                        || f_desagente_t
                              (pac_redcomercial.f_busca_padre
                                              (pac_md_common.f_get_cxtempresa,
                                               vcagente,
                                               NULL,
                                               f_sysdate
                                              )
                              ) sucursal
                   FROM DUAL
                 MINUS
                 SELECT    pac_redcomercial.f_busca_padre
                                    (pac_md_common.f_get_cxtempresa,
                                     pcagente_text,
                                     NULL,
                                     f_sysdate
                                    )
                        || ''
                        -  ''
                        || f_desagente_t
                              (pac_redcomercial.f_busca_padre
                                              (pac_md_common.f_get_cxtempresa,
                                               pcagente_text,
                                               NULL,
                                               f_sysdate
                                              )
                              ) sucursal
                   FROM DUAL);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            ptmensaje :=
                 f_axis_literales (9909031, pac_md_common.f_get_cxtidioma ());
            RETURN 1;              -- Agente no pertenece a la misma sucursal
      END;

      IF v_contador = 1
      THEN
--          pac_iobj_mensajes.crea_nuevo_mensaje(ptmensaje, 1, 9909031);
         ptmensaje :=
                 f_axis_literales (9909031, pac_md_common.f_get_cxtidioma ());
         RETURN 1;                  --Agente no pertenece a la misma sucursal
      ELSE
         RETURN 0;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         ptmensaje := SQLCODE || ' - ' || SQLERRM;
         RETURN 1;
   END f_valida_age_misma_sucursal;

   /*************************************************************************
    Función que permite validar la existencia de codigo de barras en Carpeta y Caja
    param in pnsinies     : Número de siniestro
         return             : 0 grabación correcta
                           <> 0 grabación incorrecta
   *************************************************************************/
   FUNCTION f_finsin_val_codbarras (
      pnsinies        IN       VARCHAR2,
      pnuevo_estado   IN       NUMBER,
      pcidioma        IN       NUMBER,
      ptmensaje       OUT      VARCHAR2
   )
      RETURN NUMBER
   IS
      cod_carpeta   NUMBER    := 0;
      cod_caja      NUMBER;
      v_carpeta     NUMBER;
      v_caja        NUMBER;
      errorini2     EXCEPTION;
      e_errdatos    EXCEPTION;
   BEGIN
      IF pnuevo_estado != 1
      THEN
         RETURN 0;
      END IF;

      --ini CONF-765 no esta trayendo el aviso ya que cambiaron los detvalores 800022,
      --para evitar a futuro que cambien los detvalores se buscara por tatribu
      SELECT DISTINCT (catribu)
                 INTO v_carpeta
                 FROM detvalores
                WHERE cvalor = 800022
                  AND cidioma = 8
                  AND UPPER (tatribu) LIKE '%C%DIGO DE BARRAS DE LA CARPETA%';

      SELECT DISTINCT (catribu)
                 INTO v_caja
                 FROM detvalores
                WHERE cvalor = 800022
                  AND cidioma = 8
                  AND UPPER (tatribu) LIKE '%C%DIGO DE BARRAS DE LA CAJA%';

      SELECT COUNT (*)
        INTO cod_carpeta
        FROM sin_siniestro_referencias
       WHERE nsinies = pnsinies
                               --   AND ctipref = 8;
             AND ctipref = v_carpeta;

      IF cod_carpeta = 0
      THEN
         RAISE errorini2;
      END IF;

      SELECT COUNT (*)
        INTO cod_caja
        FROM sin_siniestro_referencias
       WHERE nsinies = pnsinies
                               --  AND ctipref = 9;
             AND ctipref = v_caja;

      --fin CONF-765 no esta trayendo el aviso ya que cambiaron los detvalores 800022,
      --para evitar a futuro que cambien los detvalores se buscara por tatribu
      IF cod_caja = 0
      THEN
         RAISE e_errdatos;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN errorini2
      THEN
         ptmensaje :=
                 f_axis_literales (9909660, pac_md_common.f_get_cxtidioma ());
         DBMS_OUTPUT.put_line (DBMS_UTILITY.format_error_backtrace);
         RETURN 1;
      -- Debe indicarse el código de carpeta y caja antes de cerrar el siniestro
      WHEN e_errdatos
      THEN
         ptmensaje :=
                 f_axis_literales (9909661, pac_md_common.f_get_cxtidioma ());
         DBMS_OUTPUT.put_line (DBMS_UTILITY.format_error_backtrace);
         RETURN 1;
      -- Debe indicarse el código de carpeta y caja antes de cerrar el reclamo
      WHEN OTHERS
      THEN
         ptmensaje :=
            SQLCODE || ' - ' || SQLERRM
            || DBMS_UTILITY.format_error_backtrace;
         RETURN 1;
   END f_finsin_val_codbarras;

   /*************************************************************************
     FUNCTION f_ mens_creaconv

     RETURN 0(ok),RETURN 1(ko) */
   FUNCTION f_mens_creaconv (pcidioma IN NUMBER, ptmensaje OUT VARCHAR2)
      RETURN NUMBER
   IS
      vpasexec      NUMBER (5)      := 1;
      squery        VARCHAR2 (5000);
      vobjectname   VARCHAR2 (500)  := 'PAC_AVISOS_CONF.f_mens_creaconv';
      vparam        VARCHAR2 (1000);
   BEGIN
      ptmensaje := f_axis_literales (9909204, pcidioma);
      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      vparam,
                      'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM
                     );
         RETURN 1;
   END f_mens_creaconv;

   --CONF-274 - 20161125 - JLTS - Ini
   FUNCTION f_aviso_suspencion_sin (
      psseguro    IN       NUMBER,
      pcidioma    IN       NUMBER,
      ptmensaje   OUT      VARCHAR2
   )
      RETURN NUMBER
   IS
      vsquery       VARCHAR2 (5000);
      vobjectname   VARCHAR2 (500)
                                  := 'PAC_avisos_conf.f_aviso_suspencion_sin';
      vparam        VARCHAR2 (1000);
      vpasexec      NUMBER (5)      := 1;
      vnumerr       NUMBER (8)      := 0;
      vquants       NUMBER;
      vfsinies      DATE;
      vccausin      NUMBER;
      vsseguro      NUMBER;
   BEGIN
      IF psseguro IS NOT NULL
      THEN
         SELECT COUNT (1)
           INTO vquants
           FROM movseguro m, suspensionseg ss
          WHERE m.sseguro = ss.sseguro
            AND m.nmovimi = ss.nmovimi
            AND m.sseguro = psseguro
            AND m.nmovimi = (SELECT MAX (nmovimi)
                               FROM movseguro ms
                              WHERE ms.sseguro = m.sseguro)
            AND m.cmotmov = 391;

         IF vquants > 0
         THEN
            vnumerr := 1;
            ptmensaje := f_axis_literales (9904518, pcidioma);
         END IF;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      vparam,
                      'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM
                     );
         ptmensaje := SQLERRM;
         RETURN 1;
   END f_aviso_suspencion_sin;

   --CONF-274 - 20161125 - JLTS - Fin

   --CONF-239 JAVENDANO
   FUNCTION f_aviso_lre_persona (
      pnnumide    IN       NUMBER,
      pcidioma    IN       NUMBER,
      ptmensaje   OUT      VARCHAR2
   )
      RETURN NUMBER
   IS
      vexiste   NUMBER;
   BEGIN
      SELECT COUNT (1)
        INTO vexiste
        FROM lre_personas
       WHERE nnumide = pnnumide;

      IF NVL (vexiste, 0) > 1
      THEN
         ptmensaje := f_axis_literales (9909654, pcidioma);
         RETURN 1;
      END IF;

      RETURN 0;
   END f_aviso_lre_persona;

   --CONF-239 JAVENDANO

   /*
        Se mostrará un aviso cuando la póliza tiene coaseguro aceptado (Aviso de póliza)
        RETURN 0(ok),1(error)
        */
   FUNCTION f_aviso_pol_es_coasegurada (
      psseguro         IN       NUMBER,
      pcidioma         IN       NUMBER,
      parfix_nvalida   IN       NUMBER,
      ptmensaje        OUT      VARCHAR2
   )
      RETURN NUMBER
   IS
      vsquery       VARCHAR2 (5000);
      vobjectname   VARCHAR2 (500)
                              := 'PAC_avisos_conf.f_aviso_coaseguro_aceptado';
      vparam        VARCHAR2 (1000);
      vpasexec      NUMBER (5)      := 1;
      vnumerr       NUMBER (8)      := 0;
      vquants       NUMBER;
      vempresa      NUMBER;
      vaviso        VARCHAR2 (500);
   BEGIN
      IF psseguro IS NOT NULL
      THEN
         SELECT   COUNT (1), cempres
             INTO vquants, vempresa
             FROM seguros
            WHERE sseguro = psseguro AND ctipcoa = parfix_nvalida
         GROUP BY ctipcoa, cempres;

         IF vquants > 0
         THEN
            vnumerr := 1;

            IF NVL (pac_parametros.f_parempresa_n (vempresa,
                                                   'LIT_COA_ACEP_CED'
                                                  ),
                    0
                   ) = 1
            THEN
               IF parfix_nvalida = 1
               THEN
                  vaviso :=
                       f_axis_literales (9902113, pcidioma) || ' '
                       || 'cedida';
               ELSIF parfix_nvalida = 8
               THEN
                  vaviso :=
                     f_axis_literales (9902113, pcidioma) || ' '
                     || 'aceptada';
               ELSE
                  vaviso := f_axis_literales (9902113, pcidioma);
               END IF;
            ELSE
               vaviso := f_axis_literales (9902113, pcidioma);
            END IF;

            ptmensaje := vaviso;
         END IF;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 0;
   END f_aviso_pol_es_coasegurada;

      /*************************************************************************
        FUNCTION f_valida_tomador
        Función q valida que en un tomador no pueda ser el mismo asegurado.

        pcidioma  in number
        ptmensaje out: Texto de error
        RETURN 0(ok),return 1 (ko)
   *************************************************************************/
   FUNCTION f_valida_tomador (pcidioma IN NUMBER, ptmensaje OUT VARCHAR2)
      RETURN NUMBER
   IS
      vobjectname      VARCHAR2 (500)   := 'PAC_avisos_conf.f_valida_tomador';
      vparam           VARCHAR2 (1000)                := ' id=' || pcidioma;
      vpasexec         NUMBER (5)                     := 1;
      vnumerr          NUMBER (8)                     := 0;
      v_txtext         VARCHAR2 (1000);
      n_registro       NUMBER;
      v_retorno        NUMBER (8)                     := 0;
      v_tom_sperson    estper_personas.sperson%TYPE;
      v_tom_ctipide    per_personas.ctipide%TYPE;
      v_tom_nnumide    per_personas.nnumide%TYPE;
      v_tom_tapelli1   per_detper.tapelli1%TYPE;
      v_tom_tapelli2   per_detper.tapelli2%TYPE;
      v_tom_tnombre1   per_detper.tnombre1%TYPE;
      v_tom_tnombre2   per_detper.tnombre2%TYPE;
      v_nagente        NUMBER;
      v_nsproduc       NUMBER;
      v_ffefecto       DATE;
      v_npoliza        NUMBER;
      v_ncertif        NUMBER;
      vsperson_aseg    NUMBER;
      v_tom_ctipper    NUMBER;
      vctipper         NUMBER;
      vctipide         NUMBER;
      vnnumide         VARCHAR2 (100);
      vtapelli1        VARCHAR2 (100);
      vtapelli2        VARCHAR2 (100);
      vtnombre1        VARCHAR2 (100);
      vtnombre2        VARCHAR2 (100);
      vcsexper         NUMBER;
      v_npoliza        NUMBER;
   BEGIN
      v_retorno := 0;
      vnumerr :=
         pac_call.f_datos_tomador (1,
                                   v_tom_sperson,
                                   v_tom_ctipper,
                                   v_tom_ctipide,
                                   v_tom_nnumide,
                                   v_tom_tapelli1,
                                   v_tom_tapelli2,
                                   v_tom_tnombre1,
                                   v_tom_tnombre2
                                  );
      vnumerr :=
         pac_call.f_datos_asegurado (1,
                                     vsperson_aseg,
                                     vctipper,
                                     vctipide,
                                     vnnumide,
                                     vtapelli1,
                                     vtapelli2,
                                     vtnombre1,
                                     vtnombre2,
                                     vcsexper
                                    );

      IF (v_tom_sperson = vsperson_aseg)
      THEN
         ptmensaje := f_axis_literales (89906041, pcidioma);
         v_retorno := 1;
      END IF;

      RETURN v_retorno;
   EXCEPTION
      WHEN OTHERS
      THEN
         ptmensaje := SQLCODE || ' - ' || SQLERRM;
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      vparam,
                      'ERROR: ' || ptmensaje
                     );
         RETURN 1;
   END f_valida_tomador;

   /*************************************************************************
      FUNCTION f_valida_convenio

      param in psseguro : Identificador seguro
      return            : NUMBER
   *************************************************************************/
   FUNCTION f_valida_convenio (
      psseguro    IN       NUMBER,
      pcidioma    IN       NUMBER,
      ptmensaje   OUT      VARCHAR2
   )
      RETURN NUMBER
   IS
      --
      mensajes         t_iax_mensajes;
      v_cpregun_2913   preguntas.cpregun%TYPE   := 2913;
      v_crespue_2913   pregunseg.crespue%TYPE;
      -- Inicio IAXIS-2416 27/02/2019
      vsperson_aseg    NUMBER;
      vnumerr          NUMBER;
      vconvenio        NUMBER;
   -- Fin IAXIS-2416 27/02/2019
   --
   BEGIN
      --Ini IAXIS-4082 -- ECP -- 11/10/2019
      IF (pac_iax_produccion.poliza.det_poliza.gestion.cactivi = 1)
      THEN
         IF pac_iax_produccion.poliza.det_poliza.preguntas IS NOT NULL
         THEN
            IF pac_iax_produccion.poliza.det_poliza.preguntas.COUNT > 0
            THEN
               FOR i IN
                  pac_iax_produccion.poliza.det_poliza.preguntas.FIRST .. pac_iax_produccion.poliza.det_poliza.preguntas.LAST
               LOOP
                  IF v_cpregun_2913 =
                        pac_iax_produccion.poliza.det_poliza.preguntas (i).cpregun
                  THEN
                     v_cpregun_2913 :=
                        pac_iax_produccion.poliza.det_poliza.preguntas (i).crespue;
                  END IF;
               END LOOP;
            END IF;
         END IF;

         --
         -- Inicio IAXIS-2416 27/02/2019
         -- Recuperamos el sperson del asegurado
         IF     pac_iax_produccion.poliza.det_poliza.riesgos IS NOT NULL
            AND pac_iax_produccion.poliza.det_poliza.riesgos.COUNT > 0
         THEN
            FOR j IN
               pac_iax_produccion.poliza.det_poliza.riesgos.FIRST .. pac_iax_produccion.poliza.det_poliza.riesgos.LAST
            LOOP
               IF j = 1
               THEN
                  IF     pac_iax_produccion.poliza.det_poliza.riesgos (j).riesgoase IS NOT NULL
                     AND pac_iax_produccion.poliza.det_poliza.riesgos (j).riesgoase.COUNT >
                                                                             0
                  THEN
                     FOR i IN
                        pac_iax_produccion.poliza.det_poliza.riesgos (j).riesgoase.FIRST .. pac_iax_produccion.poliza.det_poliza.riesgos
                                                                                              (j
                                                                                              ).riesgoase.LAST
                     LOOP
                        vsperson_aseg :=
                           pac_iax_produccion.poliza.det_poliza.riesgos (j).riesgoase
                                                                          (i).sperson;
                     END LOOP;
                  END IF;
               END IF;
            END LOOP;
         END IF;

         -- Verificamos si existe convenio Agente/Asegurado
         vnumerr :=
            pac_comisionegocio.f_get_tieneconvcomesp
                        (vsperson_aseg,
                         pac_iax_produccion.poliza.det_poliza.cagente,
                         pac_iax_produccion.poliza.det_poliza.sproduc,
                         pac_iax_produccion.poliza.det_poliza.gestion.fefecto,
                         vconvenio
                        );

         /*IF ((pac_iax_produccion.poliza.det_poliza.gestion.cactivi <>1 and nvl(v_cpregun_2913,0) > 0)
                   or (pac_iax_produccion.poliza.det_poliza.gestion.cactivi <>1 and pac_iax_produccion.poliza.det_poliza.gestion.ctipcom=92)) THEN*/
         -- Se validará siempre la existencia del convenio, no importando el producto u otra condición.
         IF (    NVL (v_crespue_2913, 0) = 0
             AND vconvenio = 1
             AND pac_iax_produccion.poliza.det_poliza.gestion.ctipcom <> 92
            )
         THEN
            -- Fin IAXIS-2416 27/02/2019
            ptmensaje := f_axis_literales (89906045, pcidioma);
            RETURN 1;
         END IF;
      END IF;

      RETURN 0;
   --
   EXCEPTION
      WHEN OTHERS
      THEN
         ptmensaje := f_axis_literales (9909284, pcidioma);
         RETURN 1;
   END f_valida_convenio;

   FUNCTION f_valida_convenio_part (
      psseguro    IN       NUMBER,
      pcidioma    IN       NUMBER,
      ptmensaje   OUT      VARCHAR2
   )
      RETURN NUMBER
   IS
      --
      mensajes         t_iax_mensajes;
      --Ini IAXIS-4082 -- ECP -- 08/09/2019
      v_cpregun_2913   preguntas.cpregun%TYPE   := 2913;
      v_crespue_2913   pregunseg.crespue%TYPE;
   --
   BEGIN
      IF pac_iax_produccion.poliza.det_poliza.preguntas IS NOT NULL
      THEN
         IF pac_iax_produccion.poliza.det_poliza.preguntas.COUNT > 0
         THEN
            FOR i IN
               pac_iax_produccion.poliza.det_poliza.preguntas.FIRST .. pac_iax_produccion.poliza.det_poliza.preguntas.LAST
            LOOP
               IF v_cpregun_2913 =
                     pac_iax_produccion.poliza.det_poliza.preguntas (i).cpregun
               THEN
                  v_crespue_2913 :=
                     NVL
                        (pac_iax_produccion.poliza.det_poliza.preguntas (i).crespue,
                         0
                        );
               END IF;
            END LOOP;
         END IF;
      END IF;

--bartolo herrera
     -- IF (/*pac_iax_produccion.poliza.det_poliza.gestion.cactivi =1 and */pac_iax_produccion.poliza.det_poliza.gestion.ctipcom=92  and nvl(v_cpregun_2913,0) = 0) -- IAXIS-2416 27/02/2019
      --THEN
       --  ptmensaje := f_axis_literales(89906047, pcidioma);
        -- RETURN 1;
      --END IF;
      IF (pac_iax_produccion.poliza.det_poliza.gestion.cactivi =1) then
      IF v_crespue_2913 <> 0
      THEN
         IF pac_iax_produccion.poliza.det_poliza.gestion.ctipcom <> 92
         THEN
            ptmensaje := f_axis_literales (89906275, pcidioma);
            RETURN 1;
         END IF;
      ELSE
         IF pac_iax_produccion.poliza.det_poliza.gestion.ctipcom = 92
         THEN
            ptmensaje := f_axis_literales (89906276, pcidioma);
            RETURN 1;
         END IF;
      END IF;
      end if;
      --Fin IAXIS-4082 -- ECP -- 08/09/2019
         --bartolo herrera  02-05-2019
      RETURN 0;
   --
   EXCEPTION
      WHEN OTHERS
      THEN
         ptmensaje := f_axis_literales (9909284, pcidioma);
         RETURN 1;
   END f_valida_convenio_part;

   /*************************************************************************
        FUNCTION f_valida_trm
       Funcion que valida la trm del dia exista
        pcidioma  in number
        ptmensaje out: Texto de error
        RETURN 0(ok),return 1 (ko)
   *************************************************************************/
   FUNCTION f_valida_trm (pcidioma IN NUMBER, ptmensaje OUT VARCHAR2)
      RETURN NUMBER
   IS
      vobjectname   VARCHAR2 (500)  := 'PAC_avisos_conf.f_valida_trm';
      vparam        VARCHAR2 (1000) := ' id=' || pcidioma;
      vpasexec      NUMBER (5)      := 1;
      vnumerr       NUMBER (8)      := 0;
      v_txtext      VARCHAR2 (1000);
      n_registro    NUMBER;
      v_retorno     NUMBER (8)      := 0;
      v_cmodo       VARCHAR2 (3);
      v_cambio      VARCHAR2 (1);

      -- Ini IAXIS-10560 -- ECP -- 12/02/2020
      CURSOR c_trm (cmodo VARCHAR2, cmodd VARCHAR2)
      IS
         SELECT 'x'
           FROM eco_tipocambio
          WHERE cmonori = cmodo
            AND cmondes = cmodd
            AND trunc (fcambio) = trunc (f_sysdate);
            -- Fin IAXIS-10560 -- ECP -- 12/02/2020
   BEGIN
      v_retorno := 0;
      v_cmodo :=
         pac_monedas.f_cmoneda_t
            (pac_monedas.f_moneda_producto
                                 (pac_iax_produccion.poliza.det_poliza.sproduc)
            );

      IF v_cmodo != 'COP'
      THEN
         OPEN c_trm (v_cmodo, 'COP');

         FETCH c_trm
          INTO v_cambio;

         CLOSE c_trm;

         IF v_cambio IS NULL
         THEN
            ptmensaje := f_axis_literales (89906106, pcidioma);
            v_retorno := 1;
         END IF;
      END IF;

      RETURN v_retorno;
   EXCEPTION
      WHEN OTHERS
      THEN
         ptmensaje := SQLCODE || ' - ' || SQLERRM;
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      vparam,
                      'ERROR: ' || ptmensaje
                     );
         RETURN 1;
   END f_valida_trm;

      /*************************************************************************
        FUNCTION f_valida_trm
       Funcion que valida la trm del dia exista
        pcidioma  in number
        ptmensaje out: Texto de error
        RETURN 0(ok),return 1 (ko)
   *************************************************************************/

   /*************************************************************************
    Función que permite validar la existencia de codigo de barras en Carpeta y Caja
    param in pnsinies     : Número de siniestro
         return             : 0 grabación correcta
                           <> 0 grabación incorrecta
   *************************************************************************/
   FUNCTION f_finsin_tramita_val_codbarras (
      pnsinies        IN       VARCHAR2,
      pntramit        IN       NUMBER,
      pnuevo_estado   IN       NUMBER,
      pcidioma        IN       NUMBER,
      ptmensaje       OUT      VARCHAR2
   )
      RETURN NUMBER
   IS
      -- Inicio IAXIS 3597 AABC 06/05/2019 PROCESO JUDICIAL
      CURSOR agenda
      IS
         SELECT *
           FROM agd_movapunte
          WHERE idapunte IN (SELECT idapunte
                               FROM agd_agenda
                              WHERE tclagd = pnsinies AND ntramit = pntramit);

      v_carpeta    NUMBER;
      v_caja       NUMBER;
      v_countest   NUMBER := 0;
      v_acumest    NUMBER := 0;
   BEGIN
      --
      IF pnuevo_estado <> 0
      THEN
         FOR x IN agenda
         LOOP
            p_control_error ('OSUAREZ', 'PASO AVISO ', x.idapunte);

            SELECT COUNT (1)
              INTO v_countest
              FROM agd_movapunte
             WHERE idapunte = x.idapunte
               AND nmovapu = (SELECT MAX (nmovapu)
                                FROM agd_movapunte
                               WHERE idapunte = x.idapunte)
               AND cestapu = 0;

            p_control_error ('OSUAREZ', 'PASO AVISO COUNT ', v_countest);
            v_acumest := v_acumest + v_countest;
            p_control_error ('OSUAREZ', 'PASO AVISO v_acumest ', v_acumest);
         END LOOP;
      END IF;

      IF v_acumest > 0
      THEN
         --
         ptmensaje :=
                f_axis_literales (89906274, pac_md_common.f_get_cxtidioma ());
         RETURN 89906274;
      --
      END IF;

      IF pnuevo_estado <> 0
      THEN
         SELECT COUNT (*)
           INTO v_carpeta
           FROM agd_observaciones
          WHERE nsinies = pnsinies AND ntramit = pntramit AND cconobs = 25;

         IF v_carpeta = 0
         THEN
            ptmensaje :=
                f_axis_literales (89906107, pac_md_common.f_get_cxtidioma ());
            RETURN 89906107;
         END IF;

         SELECT COUNT (*)
           INTO v_caja
           FROM agd_observaciones
          WHERE nsinies = pnsinies AND ntramit = pntramit AND cconobs = 26;

         IF v_caja = 0
         THEN
            ptmensaje :=
                f_axis_literales (89906107, pac_md_common.f_get_cxtidioma ());
            RETURN 89906107;
         END IF;
      END IF;

      --
      IF pnuevo_estado != 1
      THEN
         RETURN 0;
      END IF;

      --
      -- FIN IAXIS 3597 AABC 06/05/2019 PROCESO JUDICIAL
      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         ptmensaje :=
            SQLCODE || ' - ' || SQLERRM
            || DBMS_UTILITY.format_error_backtrace;
         RETURN 1;
   END f_finsin_tramita_val_codbarras;

   -- INI CJMR 05/03/2019
   /*************************************************************************
    Función que permite validar la existencia de marcas para el tomador y
   asegurado al momento de crear una póliza
   *************************************************************************/

    FUNCTION F_VALIDA_MARCAS(PCIDIOMA IN NUMBER, PTMENSAJE OUT VARCHAR2)
    RETURN NUMBER IS
    VOBJECTNAME  VARCHAR2(500) := 'PAC_AVISOS_CONF.f_valida_marcas';
    VPARAM       VARCHAR2(1000) := ' id=' || PCIDIOMA;
    VPASEXEC     NUMBER(5) := 1;
    VSPERSON_TOM NUMBER;
    VSPERSON_ASE NUMBER;
    NUM_ERR      NUMBER := 0;
    MENSAJES     T_IAX_MENSAJES;
    /* IAXIS-13006 : CAMBIOS DE WEB COMPLIANCE : START  */
    VNOMBREPARACOMPL VARCHAR2(1000);
    VNNUMIDE_TOM     PER_PERSONAS.NNUMIDE%TYPE;
    VNNUMIDE_ASE     PER_PERSONAS.NNUMIDE%TYPE;
    VCTIPPER         PER_PERSONAS.CTIPPER%TYPE;
    VCTIPIDE         PER_PERSONAS.CTIPIDE%TYPE;
    /* IAXIS-13006 : CAMBIOS DE WEB COMPLIANCE : END  */
  BEGIN
    /* IAXIS-13006 : CAMBIOS DE WEB COMPLIANCE : START  */
    BEGIN
      VSPERSON_TOM := PAC_IAX_PRODUCCION.POLIZA.DET_POLIZA.TOMADORES(1)
                      .SPEREAL;
    
      VCTIPPER     := PAC_IAX_PRODUCCION.POLIZA.DET_POLIZA.TOMADORES(1)
                      .CTIPPER;
      VCTIPIDE     := PAC_IAX_PRODUCCION.POLIZA.DET_POLIZA.TOMADORES(1)
                      .CTIPIDE;
      VNNUMIDE_TOM := PAC_IAX_PRODUCCION.POLIZA.DET_POLIZA.TOMADORES(1)
                      .NNUMIDE;
    
      IF VCTIPPER = 1 THEN
        SELECT DECODE(PAC_IAX_PRODUCCION.POLIZA.DET_POLIZA.TOMADORES(1)
                      .TNOMBRE1,
                      NULL,
                      NULL,
                      ' ' || PAC_IAX_PRODUCCION.POLIZA.DET_POLIZA.TOMADORES(1)
                      .TNOMBRE1) || DECODE(PAC_IAX_PRODUCCION.POLIZA.DET_POLIZA.TOMADORES(1)
                                           .TNOMBRE2,
                                           NULL,
                                           NULL,
                                           ' ' || PAC_IAX_PRODUCCION.POLIZA.DET_POLIZA.TOMADORES(1)
                                           .TNOMBRE2) ||
               DECODE(PAC_IAX_PRODUCCION.POLIZA.DET_POLIZA.TOMADORES(1)
                      .TAPELLI1,
                      NULL,
                      NULL,
                      ' ' || PAC_IAX_PRODUCCION.POLIZA.DET_POLIZA.TOMADORES(1)
                      .TAPELLI1) || DECODE(PAC_IAX_PRODUCCION.POLIZA.DET_POLIZA.TOMADORES(1)
                                           .TAPELLI2,
                                           NULL,
                                           NULL,
                                           ' ' || PAC_IAX_PRODUCCION.POLIZA.DET_POLIZA.TOMADORES(1)
                                           .TAPELLI2)
          INTO VNOMBREPARACOMPL
          FROM DUAL;
      ELSE
        VNOMBREPARACOMPL := PAC_IAX_PRODUCCION.POLIZA.DET_POLIZA.TOMADORES(1)
                            .TAPELLI1;
      END IF;
      P_TAB_ERROR(F_SYSDATE,
                  F_USER,
                  VOBJECTNAME,
                  VPASEXEC,
                  VPARAM,
                  'VNNUMIDE_TOM : ' || VNNUMIDE_TOM ||
                  ' VNOMBREPARACOMPL : ' || VNOMBREPARACOMPL ||
                  ' VSPERSON_TOM : ' || VSPERSON_TOM || ' VCTIPIDE : ' ||
                  VCTIPIDE || ' VCTIPPER : ' || VCTIPPER);
      NUM_ERR  := PAC_LISTARESTRINGIDA.F_CONSULTAR_COMPLIANCE(VSPERSON_TOM,
                                                              VNNUMIDE_TOM,
                                                              VNOMBREPARACOMPL,
                                                              VCTIPIDE,
                                                              VCTIPPER);
      VPASEXEC := 2;
      NUM_ERR  := PAC_MARCAS.F_MARCAS_VALIDACION(VSPERSON_TOM, 1, MENSAJES);
    
      IF NUM_ERR = 1 THEN
        PTMENSAJE := 'Tomador: ' || MENSAJES(1).TERROR;
        RETURN 1;
      END IF;
    END;
  
    BEGIN
      FOR I IN PAC_IAX_PRODUCCION.POLIZA.DET_POLIZA.RIESGOS(1)
               .RIESGOASE.FIRST .. PAC_IAX_PRODUCCION.POLIZA.DET_POLIZA.RIESGOS(1)
                                   .RIESGOASE.LAST LOOP
      
        VSPERSON_ASE := PAC_IAX_PRODUCCION.POLIZA.DET_POLIZA.RIESGOS(1).RIESGOASE(I)
                        .SPEREAL;
      
        VCTIPPER     := PAC_IAX_PRODUCCION.POLIZA.DET_POLIZA.RIESGOS(1).RIESGOASE(I)
                        .CTIPPER;
        VCTIPIDE     := PAC_IAX_PRODUCCION.POLIZA.DET_POLIZA.RIESGOS(1).RIESGOASE(I)
                        .CTIPIDE;
        VNNUMIDE_ASE := PAC_IAX_PRODUCCION.POLIZA.DET_POLIZA.RIESGOS(1).RIESGOASE(I)
                        .NNUMIDE;
      
        IF VCTIPPER = 1 THEN
          SELECT DECODE(PAC_IAX_PRODUCCION.POLIZA.DET_POLIZA.RIESGOS(1).RIESGOASE(I)
                        .TNOMBRE1,
                        NULL,
                        NULL,
                        ' ' || PAC_IAX_PRODUCCION.POLIZA.DET_POLIZA.RIESGOS(1).RIESGOASE(I)
                        .TNOMBRE1) ||
                 DECODE(PAC_IAX_PRODUCCION.POLIZA.DET_POLIZA.RIESGOS(1).RIESGOASE(I)
                        .TNOMBRE2,
                        NULL,
                        NULL,
                        ' ' || PAC_IAX_PRODUCCION.POLIZA.DET_POLIZA.RIESGOS(1).RIESGOASE(I)
                        .TNOMBRE2) ||
                 DECODE(PAC_IAX_PRODUCCION.POLIZA.DET_POLIZA.RIESGOS(1).RIESGOASE(I)
                        .TAPELLI1,
                        NULL,
                        NULL,
                        ' ' || PAC_IAX_PRODUCCION.POLIZA.DET_POLIZA.RIESGOS(1).RIESGOASE(I)
                        .TAPELLI1) ||
                 DECODE(PAC_IAX_PRODUCCION.POLIZA.DET_POLIZA.RIESGOS(1).RIESGOASE(I)
                        .TAPELLI2,
                        NULL,
                        NULL,
                        ' ' || PAC_IAX_PRODUCCION.POLIZA.DET_POLIZA.RIESGOS(1).RIESGOASE(I)
                        .TAPELLI2)
            INTO VNOMBREPARACOMPL
            FROM DUAL;
        ELSE
          VNOMBREPARACOMPL := PAC_IAX_PRODUCCION.POLIZA.DET_POLIZA.RIESGOS(1).RIESGOASE(I)
                              .TAPELLI1;
        END IF;
        P_TAB_ERROR(F_SYSDATE,
                    F_USER,
                    VOBJECTNAME,
                    VPASEXEC,
                    VPARAM,
                    'VNNUMIDE_ASE : ' || VNNUMIDE_ASE ||
                    ' VNOMBREPARACOMPL : ' || VNOMBREPARACOMPL ||
                    ' VSPERSON_ASE : ' || VSPERSON_ASE || ' VCTIPIDE : ' ||
                    VCTIPIDE || ' VCTIPPER : ' || VCTIPPER);
        NUM_ERR := PAC_LISTARESTRINGIDA.F_CONSULTAR_COMPLIANCE(VSPERSON_ASE,
                                                               VNNUMIDE_ASE,
                                                               VNOMBREPARACOMPL,
                                                               VCTIPIDE,
                                                               VCTIPPER);
      
      END LOOP;
    
      VPASEXEC := 3;
      NUM_ERR  := PAC_MARCAS.F_MARCAS_VALIDACION(VSPERSON_ASE, 2, MENSAJES);
    
      IF NUM_ERR = 1 THEN
        PTMENSAJE := 'Asegurado: ' || MENSAJES(1).TERROR;
        RETURN 1;
      END IF;
    END;
    /* IAXIS-13006 : CAMBIOS DE WEB COMPLIANCE : END  */
    RETURN 0;
  EXCEPTION
    WHEN OTHERS THEN
      PTMENSAJE := SQLCODE || ' - ' || SQLERRM;
      P_TAB_ERROR(F_SYSDATE,
                  F_USER,
                  VOBJECTNAME,
                  VPASEXEC,
                  VPARAM,
                  'ERROR: ' || PTMENSAJE);
      RETURN 1;
  END F_VALIDA_MARCAS;

   -- FIN CJMR 05/03/2019

   /*************************************************************************
      FUNCTION f_valida_convenio
      INICIO IAXIS-3186 03/04/2019
      param in psseguro : Identificador seguro
      return            : NUMBER
   *************************************************************************/
   FUNCTION f_valida_convenio_gb (
      psseguro    IN       NUMBER,
      pcidioma    IN       NUMBER,
      ptmensaje   OUT      VARCHAR2
   )
      RETURN NUMBER
   IS
      --
      mensajes         t_iax_mensajes;
      v_cpregun_2913   preguntas.cpregun%TYPE   := 2913;
      v_crespue_2913   pregunseg.crespue%TYPE;
      -- Inicio IAXIS-2416 27/02/2019
      vsperson_aseg    NUMBER;
      vnumerr          NUMBER;
      vconvenio        NUMBER;
      vnagente         VARCHAR2 (100);
      vnasegurado      VARCHAR2 (100);
      -- Fin IAXIS-2416 27/02/2019
      --Ini IAXIS-4082 -- ECP -- 29/08/2019
      v_cpregun_2912   preguntas.cpregun%TYPE   := 2912;
      v_trespue_2912   pregunseg.trespue%TYPE;
      --PRAGMA AUTONOMOUS_TRANSACTION;
   --Fin IAXIS-4082 -- ECP -- 29/08/2019
   --
   BEGIN
      --Ini AXIS-4082 -- ECP -- 11/10/2019
      v_cpregun_2913 := 2913;

      IF pac_iax_produccion.poliza.det_poliza.preguntas IS NOT NULL
      THEN
         IF pac_iax_produccion.poliza.det_poliza.preguntas.COUNT > 0
         THEN
            FOR i IN
               pac_iax_produccion.poliza.det_poliza.preguntas.FIRST .. pac_iax_produccion.poliza.det_poliza.preguntas.LAST
            LOOP
               IF v_cpregun_2913 =
                     pac_iax_produccion.poliza.det_poliza.preguntas (i).cpregun
               THEN
                  v_crespue_2913 :=
                     pac_iax_produccion.poliza.det_poliza.preguntas (i).crespue;
               END IF;
            END LOOP;
         END IF;
      END IF;

      IF NVL
            (pac_mdpar_productos.f_get_parproducto
                                 ('CONV_CONTRATANTE',
                                  pac_iax_produccion.poliza.det_poliza.sproduc
                                 ),
             0
            ) = 0
      THEN
         -- Inicio IAXIS-2416 27/02/2019
         -- Recuperamos el sperson del asegurado
         IF     pac_iax_produccion.poliza.det_poliza.riesgos IS NOT NULL
            AND pac_iax_produccion.poliza.det_poliza.riesgos.COUNT > 0
         THEN
            FOR j IN
               pac_iax_produccion.poliza.det_poliza.riesgos.FIRST .. pac_iax_produccion.poliza.det_poliza.riesgos.LAST
            LOOP
               IF j = 1
               THEN
                  IF     pac_iax_produccion.poliza.det_poliza.riesgos (j).riesgoase IS NOT NULL
                     AND pac_iax_produccion.poliza.det_poliza.riesgos (j).riesgoase.COUNT >
                                                                             0
                  THEN
                     FOR i IN
                        pac_iax_produccion.poliza.det_poliza.riesgos (j).riesgoase.FIRST .. pac_iax_produccion.poliza.det_poliza.riesgos
                                                                                              (j
                                                                                              ).riesgoase.LAST
                     LOOP
                        vsperson_aseg :=
                           pac_iax_produccion.poliza.det_poliza.riesgos (j).riesgoase
                                                                          (i).sperson;
                     END LOOP;
                  END IF;
               END IF;
            END LOOP;
         END IF;
      ELSE
         IF pac_iax_produccion.poliza.det_poliza.preguntas IS NOT NULL
         THEN
            IF pac_iax_produccion.poliza.det_poliza.preguntas.COUNT > 0
            THEN
               FOR i IN
                  pac_iax_produccion.poliza.det_poliza.preguntas.FIRST .. pac_iax_produccion.poliza.det_poliza.preguntas.LAST
               LOOP
                  --Ini IAXIS-4082 -- ECP -- 29/08/2019
                  IF v_cpregun_2912 =
                        pac_iax_produccion.poliza.det_poliza.preguntas (i).cpregun
                  THEN
                     v_trespue_2912 :=
                        pac_iax_produccion.poliza.det_poliza.preguntas (i).trespue;
                  END IF;
               --Fin IAXIS-4082 -- ECP -- 29/08/2019
               END LOOP;
            END IF;
         END IF;

         --Ini IAXIS-4082 -- ECP -- 29/08/2019
         IF v_trespue_2912 IS NOT NULL
         THEN
            SELECT sperson
              INTO vsperson_aseg
              FROM per_personas
             WHERE nnumide = v_trespue_2912;
         END IF;
      --Fin IAXIS-4082 -- ECP -- 29/08/2019
      END IF;

      --

      -- Verificamos si existe convenio Agente/Asegurado
      vnumerr :=
         pac_comisionegocio.f_get_tieneconvcomesp
                        (vsperson_aseg,
                         pac_iax_produccion.poliza.det_poliza.cagente,
                         pac_iax_produccion.poliza.det_poliza.sproduc,
                         pac_iax_produccion.poliza.det_poliza.gestion.fefecto,
                         vconvenio
                        );

      IF NVL
            (pac_mdpar_productos.f_get_parproducto
                                 ('CONV_CONTRATANTE',
                                  pac_iax_produccion.poliza.det_poliza.sproduc
                                 ),
             0
            ) = 1
      THEN
         IF (vconvenio = 1) AND (NVL (v_crespue_2913, 0) = 0)
         THEN
            -- Fin IAXIS-2416 27/02/2019
            BEGIN
               SELECT b.tnombre || ' ' || b.tapelli1 || ' ' || b.tapelli2
                 INTO vnagente
                 FROM agentes a, per_detper b
                WHERE a.cagente = pac_iax_produccion.poliza.det_poliza.cagente
                  AND a.sperson = b.sperson;
            END;

            ptmensaje :=
                      vnagente || ' ' || f_axis_literales (89907050, pcidioma);
            RETURN 1;
         END IF;
      ELSE
         /*IF ((pac_iax_produccion.poliza.det_poliza.gestion.cactivi <>1 and nvl(v_cpregun_2913,0) > 0)
                   or (pac_iax_produccion.poliza.det_poliza.gestion.cactivi <>1 and pac_iax_produccion.poliza.det_poliza.gestion.ctipcom=92)) THEN*/
         -- Se validará siempre la existencia del convenio, no importando el producto u otra condición.
         IF (NVL (v_crespue_2913, 0) = 0 AND vconvenio = 1)
         THEN
            -- Fin IAXIS-2416 27/02/2019
            BEGIN
               SELECT b.tnombre || ' ' || b.tapelli1 || ' ' || b.tapelli2
                 INTO vnagente
                 FROM agentes a, per_detper b
                WHERE a.cagente = pac_iax_produccion.poliza.det_poliza.cagente
                  AND a.sperson = b.sperson;
            END;

            ptmensaje :=
                      vnagente || ' ' || f_axis_literales (89906045, pcidioma);
            RETURN 1;
         END IF;
      END IF;
     --Fin IAXIS-4082 -- ECP -- 11/10/2019
      RETURN 0;
   --
   EXCEPTION
      WHEN OTHERS
      THEN
         ptmensaje :=
               f_axis_literales (9909284, pcidioma)
            || ' '
            || vsperson_aseg
            || ' '
            || vnasegurado;
         RETURN 1;
   END f_valida_convenio_gb;

-- FIN IAXIS-3186 03/04/2019

   -- INI IAXIS-3640 CJMR 26/09/2019
   /*************************************************************************
    Función que valida la selección del certificado a afectar en un extorno
   *************************************************************************/
   FUNCTION f_valida_sel_cert_afectar (
      pcidioma    IN       NUMBER,
      ptmensaje   OUT      VARCHAR2
   )
      RETURN NUMBER
   IS
      vobjectname     VARCHAR2 (500)
                               := 'PAC_AVISOS_CONF.f_valida_sel_cert_afectar';
      vparam          VARCHAR2 (1000)          := ' id=' || pcidioma;
      vpasexec        NUMBER (5)               := 1;
      v_crespue9802   pregunseg.crespue%TYPE;
      pri             ob_iax_primas;
      num_err         NUMBER                   := 0;
      mensajes        t_iax_mensajes;
   BEGIN
      IF pac_iax_produccion.issuplem
      THEN
         vpasexec := 2;
         pri :=
            pac_iax_produccion.f_get_primasgaranttot
                    (pac_iax_produccion.poliza.det_poliza.riesgos (1).nriesgo,
                     mensajes
                    );

         IF pac_iax_suplementos.lstmotmov (1).cmotmov = 239 OR pri.itotalr < 0
         THEN
            vpasexec := 3;
            num_err :=
               pac_preguntas.f_get_pregunseg
                    (pac_iax_produccion.poliza.det_poliza.sseguro,
                     pac_iax_produccion.poliza.det_poliza.riesgos (1).nriesgo,
                     9802,
                     'EST',
                     v_crespue9802
                    );

            IF num_err = 120135
            THEN
               vpasexec := 4;
               ptmensaje := f_axis_literales (89907062, pcidioma);
               RETURN 1;
            ELSIF num_err <> 0
            THEN
               vpasexec := 5;
               ptmensaje := f_axis_literales (num_err, pcidioma);
               RETURN 1;
            END IF;
         END IF;
      END IF;

      vpasexec := 6;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         ptmensaje := SQLCODE || ' - ' || SQLERRM;
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      vparam,
                      'ERROR: ' || ptmensaje
                     );
         RETURN 1;
   END f_valida_sel_cert_afectar;

   /*************************************************************************
    Función que valida el valor del certificado a afectar en un extorno
   *************************************************************************/
   FUNCTION f_valida_val_cert_afectar (
      pcidioma    IN       NUMBER,
      ptmensaje   OUT      VARCHAR2
   )
      RETURN NUMBER
   IS
      vobjectname     VARCHAR2 (500)
                               := 'PAC_AVISOS_CONF.f_valida_val_cert_afectar';
      vparam          VARCHAR2 (1000)            := ' id=' || pcidioma;
      vpasexec        NUMBER (5)                 := 1;
      v_crespue9802   pregunseg.crespue%TYPE;
      v_itotalr       vdetrecibos.itotalr%TYPE;
      pri             ob_iax_primas;
      num_err         NUMBER                     := 0;
      mensajes        t_iax_mensajes;
   BEGIN
      IF pac_iax_produccion.issuplem
      THEN
         vpasexec := 2;
         pri :=
            pac_iax_produccion.f_get_primasgaranttot
                    (pac_iax_produccion.poliza.det_poliza.riesgos (1).nriesgo,
                     mensajes
                    );

         IF pac_iax_suplementos.lstmotmov (1).cmotmov = 239 OR pri.itotalr < 0
         THEN
            vpasexec := 3;
            num_err :=
               pac_preguntas.f_get_pregunseg
                    (pac_iax_produccion.poliza.det_poliza.sseguro,
                     pac_iax_produccion.poliza.det_poliza.riesgos (1).nriesgo,
                     9802,
                     'EST',
                     v_crespue9802
                    );

            IF num_err = 0
            THEN
               vpasexec := 4;

               SELECT itotalr
                 INTO v_itotalr
                 FROM vdetrecibos_monpol vdr INNER JOIN recibos r
                      ON r.nrecibo = vdr.nrecibo
                      INNER JOIN rango_dian_movseguro rds
                      ON r.sseguro = rds.sseguro AND rds.nmovimi = r.nmovimi
                WHERE rds.sseguro =
                                  pac_iax_produccion.poliza.det_poliza.ssegpol
                  AND rds.nmovimi = v_crespue9802;

               vpasexec := 5;

               IF ABS (pri.itotalr) > v_itotalr
               THEN
                  ptmensaje := f_axis_literales (89907063, pcidioma);
                  RETURN 1;
               END IF;
            ELSIF num_err <> 0
            THEN
               vpasexec := 6;
               ptmensaje := f_axis_literales (num_err, pcidioma);
               RETURN 1;
            END IF;
         END IF;
      END IF;

      vpasexec := 7;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         ptmensaje := SQLCODE || ' - ' || SQLERRM;
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      vparam,
                      'ERROR: ' || ptmensaje
                     );
         RETURN 1;
   END f_valida_val_cert_afectar;
-- FIN IAXIS-3640 CJMR 26/09/2019

   -- INI IAXIS-5422 CJMR 28/10/2019
   /*************************************************************************
    Función que valida cantidad de beneficiarios en una póliza, especialmente para RC
   *************************************************************************/
  FUNCTION F_VALIDA_NUM_BENEF(PSSEGURO  IN NUMBER,
                              PCIDIOMA  IN NUMBER,
                              PTMENSAJE OUT VARCHAR2) RETURN NUMBER IS
    VOBJECTNAME VARCHAR2(500) := 'PAC_AVISOS_CONF.f_valida_num_benef';
    VPARAM      VARCHAR2(1000) := 'psseguro:' || PSSEGURO || ',  pcidioma=' ||
                                  PCIDIOMA;
    VPASEXEC    NUMBER(5) := 1;
    V_COUNT     NUMBER := 0;
    NUM_ERR     NUMBER;
    NPOS        NUMBER;
    RIE         OB_IAX_RIESGOS;
    MENSAJES    T_IAX_MENSAJES;
    PREG        T_IAX_PREGUNTAS;
    V_SPEREAL   ESTPER_PERSONAS.SPEREAL%TYPE;
    /* IAXIS-13006 : CAMBIOS DE WEB COMPLIANCE : START  */
    VNOMBREPARACOMPL VARCHAR2(1000);
    VSPERSON_BEN     PER_PERSONAS.SPERSON%TYPE;
    VNNUMIDE_BEN     PER_PERSONAS.NNUMIDE%TYPE;
    VCTIPPER         PER_PERSONAS.CTIPPER%TYPE;
    VCTIPIDE         PER_PERSONAS.CTIPIDE%TYPE;
    VNUM_ERR         NUMBER := 0;
    /* IAXIS-13006 : CAMBIOS DE WEB COMPLIANCE : END  */
  
  BEGIN
  
    RIE := PAC_IOBJ_PROD.F_PARTPOLRIESGO(PAC_IAX_PRODUCCION.POLIZA.DET_POLIZA,
                                         1,
                                         MENSAJES);
  
    VPASEXEC := 2;
  
    /* IAXIS-13006 : CAMBIOS DE WEB COMPLIANCE : START  */
  
    IF RIE.BENEFICIARIO.BENEFESP IS NOT NULL THEN
      VPASEXEC := 13;
      IF RIE.BENEFICIARIO.BENEFESP.BENEF_RIESGO.COUNT > 0 THEN
        VPASEXEC := 14;
        FOR I IN RIE.BENEFICIARIO.BENEFESP.BENEF_RIESGO.FIRST .. RIE.BENEFICIARIO.BENEFESP.BENEF_RIESGO.LAST LOOP
          VPASEXEC := 15;
        
          BEGIN
            VNNUMIDE_BEN := RIE.BENEFICIARIO.BENEFESP.BENEF_RIESGO(I)
                            .NNUMIDE;
          
            IF TO_NUMBER(VNNUMIDE_BEN) <> 0 THEN
            
              SELECT PP.CTIPPER, PP.CTIPIDE, PP.SPERSON
                INTO VCTIPPER, VCTIPIDE, VSPERSON_BEN
                FROM PER_PERSONAS PP
               WHERE PP.NNUMIDE = VNNUMIDE_BEN;
            
              IF VCTIPPER = 1 THEN
                SELECT DECODE(PD.TNOMBRE1, NULL, NULL, ' ' || PD.TNOMBRE1) ||
                       DECODE(PD.TNOMBRE2, NULL, NULL, ' ' || PD.TNOMBRE2) ||
                       DECODE(PD.TAPELLI1, NULL, NULL, ' ' || PD.TAPELLI1) ||
                       DECODE(PD.TAPELLI2, NULL, NULL, ' ' || PD.TAPELLI2)
                  INTO VNOMBREPARACOMPL
                  FROM PER_DETPER PD
                 WHERE PD.SPERSON = VSPERSON_BEN;
              ELSE
                SELECT PD.TAPELLI1
                  INTO VNOMBREPARACOMPL
                  FROM PER_DETPER PD
                 WHERE PD.SPERSON = VSPERSON_BEN;
              END IF;
            
              P_TAB_ERROR(F_SYSDATE,
                          F_USER,
                          VOBJECTNAME,
                          VPASEXEC,
                          VPARAM,
                          'VNNUMIDE_BEN : ' || VNNUMIDE_BEN ||
                          ' VNOMBREPARACOMPL : ' || VNOMBREPARACOMPL ||
                          ' VSPERSON_BEN : ' || VSPERSON_BEN ||
                          ' VCTIPIDE : ' || VCTIPIDE || ' VCTIPPER : ' ||
                          VCTIPPER);
              NUM_ERR  := PAC_LISTARESTRINGIDA.F_CONSULTAR_COMPLIANCE(VSPERSON_BEN,
                                                                      VNNUMIDE_BEN,
                                                                      VNOMBREPARACOMPL,
                                                                      VCTIPIDE,
                                                                      VCTIPPER);
              VPASEXEC := 16;
              NUM_ERR := PAC_MARCAS.F_MARCAS_VALIDACION(VSPERSON_BEN,
                                                         4,
                                                         MENSAJES);
            
              IF NUM_ERR = 1 THEN
                PTMENSAJE := 'Beneficiario : ' || MENSAJES(1).TERROR;
                VNUM_ERR := VNUM_ERR + 1 ;
                RETURN 1;
              END IF;
            END IF;
          END;
        END LOOP;
      END IF;
    END IF;
  
    IF VNUM_ERR = 0 THEN
      /* IAXIS-13006 : CAMBIOS DE WEB COMPLIANCE : END  */
    
      IF RIE.BENEFICIARIO.BENEFESP IS NOT NULL THEN
        VPASEXEC := 3;
        IF RIE.BENEFICIARIO.BENEFESP.BENEF_RIESGO.COUNT > 0 THEN
          VPASEXEC := 4;
          FOR I IN RIE.BENEFICIARIO.BENEFESP.BENEF_RIESGO.FIRST .. RIE.BENEFICIARIO.BENEFESP.BENEF_RIESGO.LAST LOOP
            VPASEXEC := 5;
          
            IF RIE.BENEFICIARIO.BENEFESP.BENEF_RIESGO.EXISTS(I) THEN
              VPASEXEC := 6;
              IF PAC_IAX_PRODUCCION.ISSUPLEM THEN
                BEGIN
                  SELECT SPEREAL
                    INTO V_SPEREAL
                    FROM ESTPER_PERSONAS
                   WHERE SSEGURO =
                         PAC_IAX_PRODUCCION.POLIZA.DET_POLIZA.SSEGURO
                     AND SPERSON = RIE.BENEFICIARIO.BENEFESP.BENEF_RIESGO(I)
                        .SPERSON;
                EXCEPTION
                  WHEN OTHERS THEN
                    V_SPEREAL := 0;
                END;
              ELSE
                V_SPEREAL := RIE.BENEFICIARIO.BENEFESP.BENEF_RIESGO(I)
                             .SPERSON;
              
              END IF;
            
              VPASEXEC := 7;
              IF NVL(PAC_PARAMETROS.F_PARPRODUCTO_N(PAC_IAX_PRODUCCION.POLIZA.DET_POLIZA.SPRODUC,
                                                    'BENIDENT_RIES'),
                     0) <> V_SPEREAL THEN
                V_COUNT := V_COUNT + 1;
              END IF;
            END IF;
          END LOOP;
        END IF;
      END IF;
    
      VPASEXEC := 8;
      IF V_COUNT > NVL(PAC_PARAMETROS.F_PARPRODUCTO_N(PAC_IAX_PRODUCCION.POLIZA.DET_POLIZA.SPRODUC,
                                                      'MAX_BEN_ADI'),
                       0) THEN
        PTMENSAJE := F_AXIS_LITERALES(89907070, PCIDIOMA);
        RETURN 1;
      END IF;
    
      VPASEXEC := 9;
      PREG     := RIE.PREGUNTAS;
    
      IF PREG IS NULL THEN
        PREG := T_IAX_PREGUNTAS();
        NPOS := -1;
      END IF;
    
      VPASEXEC := 10;
      IF PREG.COUNT = 0 THEN
        NPOS := -1;
      ELSE
        FOR VPRG IN PREG.FIRST .. PREG.LAST LOOP
          IF PREG.EXISTS(VPRG) THEN
            IF PREG(VPRG).CPREGUN = 9803 THEN
              NPOS := VPRG;
            END IF;
          END IF;
        END LOOP;
      END IF;
    
      VPASEXEC := 11;
      IF NPOS = -1 THEN
        PREG.EXTEND;
        PREG(PREG.LAST) := OB_IAX_PREGUNTAS();
        PREG(PREG.LAST).CPREGUN := 9803;
        PREG(PREG.LAST).CRESPUE := V_COUNT;
        PREG(PREG.LAST).NMOVIMI := PAC_IAX_PRODUCCION.POLIZA.DET_POLIZA.NMOVIMI;
        PREG(PREG.LAST).NMOVIMA := PAC_IAX_PRODUCCION.POLIZA.DET_POLIZA.NMOVIMI;
      ELSIF NPOS > -1 THEN
        PREG(NPOS).CRESPUE := V_COUNT;
        PREG(NPOS).NMOVIMI := PAC_IAX_PRODUCCION.POLIZA.DET_POLIZA.NMOVIMI;
        PREG(NPOS).NMOVIMA := PAC_IAX_PRODUCCION.POLIZA.DET_POLIZA.NMOVIMI;
      END IF;
    
      PAC_IAX_PRODUCCION.POLIZA.DET_POLIZA.RIESGOS(1).PREGUNTAS := PREG;
    
      VPASEXEC := 12;
      RETURN 0;
    /* IAXIS-13006 : CAMBIOS DE WEB COMPLIANCE : START  */
    END IF;
    /* IAXIS-13006 : CAMBIOS DE WEB COMPLIANCE : END  */
  EXCEPTION
    WHEN OTHERS THEN
      PTMENSAJE := SQLCODE || ' - ' || SQLERRM;
      P_TAB_ERROR(F_SYSDATE,
                  F_USER,
                  VOBJECTNAME,
                  VPASEXEC,
                  VPARAM,
                  'ERROR: ' || PTMENSAJE);
      RETURN 1;
  END F_VALIDA_NUM_BENEF;   -- FIN IAXIS-5422 CJMR 28/10/2019

   -- INI IAXIS-5428 CJMR 01/11/2019
   FUNCTION f_valida_comi_corretaje (pcidioma IN NUMBER, 
                                     ptmensaje OUT VARCHAR2)
   RETURN NUMBER IS
      vobjectname     VARCHAR2 (500) := 'PAC_AVISOS_CONF.f_valida_comi_corretaje';
      vparam          VARCHAR2 (1000):= 'pcidioma=' || pcidioma;
      vpasexec        NUMBER (5)     := 1;
      v_cpregun4780   pregunpolseg.cpregun%TYPE := 4780;
      v_crespue4780   pregunpolseg.crespue%TYPE;
      num_err         NUMBER                     := 0;
      mensajes        t_iax_mensajes;

   BEGIN

      IF pac_iax_produccion.poliza.det_poliza.preguntas IS NOT NULL
         AND pac_iax_produccion.poliza.det_poliza.preguntas.COUNT > 0 THEN
         vpasexec := 2;

         FOR i IN pac_iax_produccion.poliza.det_poliza.preguntas.FIRST .. pac_iax_produccion.poliza.det_poliza.preguntas.LAST LOOP
            vpasexec := 3;

            IF v_cpregun4780 = pac_iax_produccion.poliza.det_poliza.preguntas(i).cpregun THEN
               vpasexec := 4;
               v_crespue4780 := pac_iax_produccion.poliza.det_poliza.preguntas(i).crespue;
               EXIT;
            END IF;
         END LOOP;
      END IF;

      vpasexec := 5;
      IF pac_iax_produccion.poliza.det_poliza.gestion.ctipcom <> 90 AND v_crespue4780 = 1 THEN
         IF pac_iax_produccion.issuplem THEN

            vpasexec := 6;
            SELECT a.crespue
            INTO v_crespue4780
            FROM pregunpolseg a
            WHERE a.sseguro = pac_iax_produccion.poliza.det_poliza.ssegpol
            AND a.cpregun = v_cpregun4780
            AND a.nmovimi = (SELECT MAX(b.nmovimi)
                             FROM pregunpolseg b
                             WHERE b.sseguro = a.sseguro
                             AND b.cpregun = a.cpregun);

            vpasexec := 7;
            FOR i IN pac_iax_produccion.poliza.det_poliza.preguntas.FIRST .. pac_iax_produccion.poliza.det_poliza.preguntas.LAST LOOP
               vpasexec := 8;

               IF v_cpregun4780 = pac_iax_produccion.poliza.det_poliza.preguntas(i).cpregun THEN
                  vpasexec := 9;
                  pac_iax_produccion.poliza.det_poliza.preguntas(i).crespue := v_crespue4780;
                  EXIT;
               END IF;
            END LOOP;

         END IF;

         vpasexec := 10;
         ptmensaje := f_axis_literales (89907071, pcidioma);
         RETURN 1;
      END IF;

      vpasexec := 11;
      RETURN 0;

   EXCEPTION
      WHEN OTHERS THEN
         ptmensaje := SQLCODE || ' - ' || SQLERRM;
         p_tab_error (f_sysdate, f_user, vobjectname, vpasexec, vparam, 'ERROR: ' || ptmensaje );
         RETURN 1;
   END f_valida_comi_corretaje;
   -- FIN IAXIS-5428 CJMR 01/11/2019

  -- INI IAXIS-3264 -04/12/2019
  /*************************************************************************
     FUNCTION f_valida_recargo

     param in psseguro : Identificador seguro
     return            : NUMBER
  *************************************************************************/
  FUNCTION f_valida_recargo(psseguro  IN NUMBER,
                            ptmensaje OUT VARCHAR2) RETURN NUMBER IS
    vobjectname   VARCHAR2(500) := 'PAC_AVISOS_CONF.f_valida_recargo';
    vparam        VARCHAR2(1000) := 'psseguro:' || psseguro;
    vpasexec      NUMBER := 0;
    v_cpregun6623 pregunpolseg.cpregun%TYPE := 6623;
    v_contador    NUMBER := 0;
  BEGIN
    vpasexec := 10;
    -- 
    IF pac_iax_produccion.issuplem THEN
      SELECT COUNT(1)
        INTO v_contador
        FROM estpregungaranseg p
       WHERE p.sseguro = psseguro
         AND p.nriesgo = pac_iax_produccion.poliza.det_poliza.riesgos(1).nriesgo
         AND p.cpregun = v_cpregun6623
         AND exists (select 1
                       from estgaranseg g
                       -- SSEGURO, NRIESGO, CGARANT, NMOVIMI, FINIEFE
                      where g.sseguro = p.sseguro
                        and g.nriesgo = p.nriesgo
                        and g.cgarant = p.cgarant
                        and g.nmovimi = p.nmovimi
                        and g.finiefe = p.finiefe
                        and g.cobliga = 1)
         AND p.nmovimi = (SELECT MAX(nmovimi)
                            FROM estpregungaranseg p2
                           WHERE p2.sseguro = p.sseguro
                             AND p2.nriesgo = p.nriesgo
                             AND p2.cpregun = p.cpregun
                             AND p2.cgarant = p.cgarant)
         AND p.crespue > 0;
      IF v_contador > 0 THEN
        ptmensaje := f_axis_literales(89907053, pac_md_common.f_get_cxtidioma());
        RETURN 1;
      END IF;
    END IF;
    RETURN 0;
  END f_valida_recargo;
  -- FIN IAXIS-3264 -04/12/2019


    /*************************************************************************
     FUNCTION f_valida_formato_USF

     psseguro : Identificador seguro
     pcidioma          : NUMBER

     funcion que valida el valor asegurado, la clase de riesgo, en los productos
     de CUMPLIMIENTO para mostrar mensaje al usuario que debe llenar el formato USF. 
  *************************************************************************/
  --INCIO   IAXIS 3750  IRD

   FUNCTION f_valida_formato_usf (
      psseguro    IN       NUMBER,
      pcidioma    In       Number,

      ptmensaje   OUT      VARCHAR2
   )
      RETURN NUMBER
   IS

   v_icapital    NUMBER;
   vobjectname   VARCHAR2(500) := 'PAC_AVISOS_CONF.f_valida_formato_USF';
   vparam        VARCHAR2(1000) := 'psseguro:' || psseguro;
   vpasexec      NUMBER := 0;
   v_cramo       NUMBER(3);
   v_capital     NUMBER;
   v_capital_garantias     NUMBER := 0;
   v_resp_2893     NUMBER;  
   v_resp_2892     NUMBER;
   v_resp_2897     NUMBER;
   v_resp_2897_COA  NUMBER;
 
   v_sproduc       NUMBER;
   v_mon_e         VARCHAR2(4);
   v_cambio        NUMBER;
   v_ccla5         NUMBER(2);
   v_ccla_V        VARCHAR2(2);
   V_PLOCCOA       NUMBER(9,5);

   CURSOR capitales 
     IS 
    SELECT cpregun, crespue 
       FROM estpregungaranseg 
       WHERE sseguro = psseguro 
       AND nmovimi = 1 
       AND cpregun in (2892, 2893, 2897); 


   BEGIN
   --       
   BEGIN
vpasexec := 1;

   SELECT crespue 
        Into v_capital 
   FROM estpregunseg 
   WHERE cpregun = 2883 
   AND sseguro = psseguro;
     EXCEPTION WHEN no_data_found THEN
        v_capital:= 0;
     END;  

    BEGIN
vpasexec := 2;

   SELECT cramo,sproduc 
    INTO v_cramo,v_sproduc 
   FROM estseguros 
   WHERE sseguro = psseguro;
      EXCEPTION WHEN no_data_found THEN
        v_sproduc := 0;
    END;    
-- 
    BEGIN 
vpasexec := 3;
   SELECT DISTINCT d.ccla5
     INTO v_ccla5  
   FROM sgt_subtabs_det d 
   WHERE  d.csubtabla = 9000011
   AND d.ccla1 = 801
   AND d.CVERSUBT = 1
   AND d.cempres = 24
   AND d.Ccla2 = v_sproduc
   AND d.ccla3 in (SELECT g.crespue 
                    FROM estpregunseg g
                    WHERE g.cpregun IN (5876, 2880) 
                    AND g.sseguro = psseguro
                    AND g.crespue = d.ccla3);
     EXCEPTION WHEN no_data_found THEN
        v_ccla5:= null; 

   END;
   
   BEGIN 
     SELECT E.PLOCCOA
       INTO V_PLOCCOA
       FROM ESTCOACUADRO E
       WHERE E.SSEGURO = psseguro; 
   EXCEPTION WHEN no_data_found THEN
        V_PLOCCOA := null;    
   END; 
      
--   
vpasexec := 4;
  v_mon_e := pac_monedas.f_moneda_producto_char(v_sproduc);  
 -- 
    FOR cur_resp IN capitales LOOP 
vpasexec := 5;

        IF cur_resp.cpregun = 2892 THEN       
         v_resp_2892 := cur_resp.crespue;
         v_capital_garantias := v_capital_garantias + (v_capital * v_resp_2892 / 100);   
               
       ELSIF cur_resp.cpregun = 2897 THEN  
         
        v_resp_2897 := cur_resp.crespue;
        v_resp_2897_COA :=  ((v_resp_2897 * V_PLOCCOA) / 100) ;
        v_capital_garantias := v_capital_garantias + v_resp_2897_COA;    
              
	          
        ELSE
        v_resp_2893 := cur_resp.crespue;
        v_capital_garantias := v_capital_garantias + v_resp_2893;
        END IF;
vpasexec := 6;
    END LOOP; 
 --          
vpasexec := 7;
       IF v_ccla5 = 0 THEN
         v_ccla_V := 'A';
       ELSIF v_ccla5 = 1 THEN
         v_ccla_V := 'B';
       ELSIF v_ccla5 = 2 THEN
         v_ccla_V := 'C';
      ELSE
         v_ccla5:= null; 
       END IF;
vpasexec := 8;

       IF v_ccla_V in ('B', 'C') THEN
         ptmensaje := f_axis_literales(89907091, pac_md_common.f_get_cxtidioma());

         RETURN 1; 
       END IF;        

       IF (v_capital_garantias > 5000000000 AND nvl(f_parproductos_v(v_sproduc, 'AVISO_USF'), 0) = 1) OR nvl(f_parproductos_v(v_sproduc, 'AVISO_USF_F'), 0) = 1 THEN  
            ptmensaje := f_axis_literales(89907091, pac_md_common.f_get_cxtidioma());

            RETURN 1; 
       END IF;
vpasexec := 9;

       IF v_mon_e <> 'COP' THEN
            v_cambio := pac_eco_tipocambio.f_importe_cambio(v_mon_e, 'COP',f_sysdate, v_capital_garantias); 
         IF  v_cambio > 5000000000 THEN
            ptmensaje := f_axis_literales(89907091, pac_md_common.f_get_cxtidioma());

            RETURN 1; 
         END IF;
      END IF;   
vpasexec := 10;      

      RETURN 0;

     EXCEPTION
      WHEN OTHERS THEN
         ptmensaje := SQLCODE || ' - ' || sqlerrm;
         p_tab_error (f_sysdate, f_user, vobjectname, vpasexec, vparam, 'ERROR: ' || ptmensaje ||' vpasexec: '||vpasexec );
         RETURN 1;

END f_valida_formato_usf;

--FIN  IAXIS 3750  IRD

  /* IAXIS-13006 : CAMBIOS DE WEB COMPLIANCE : START  */
  FUNCTION F_VALIDA_NUM_BENEF_COMP(PSSEGURO  IN NUMBER,
                                  PCIDIOMA  IN NUMBER,
                                  PTMENSAJE OUT VARCHAR2) RETURN NUMBER IS
    VOBJECTNAME VARCHAR2(500) := 'PAC_AVISOS_CONF.F_VALIDA_NUM_BENEF_COMP';
    VPARAM      VARCHAR2(1000) := 'psseguro:' || PSSEGURO || ',  pcidioma=' ||
                                  PCIDIOMA;
    VPASEXEC    NUMBER(5) := 1;
    NUM_ERR     NUMBER;
    RIE         OB_IAX_RIESGOS;
    MENSAJES    T_IAX_MENSAJES;

    VNOMBREPARACOMPL VARCHAR2(1000);
    VSPERSON_BEN     PER_PERSONAS.SPERSON%TYPE;
    VNNUMIDE_BEN     PER_PERSONAS.NNUMIDE%TYPE;
    VCTIPPER         PER_PERSONAS.CTIPPER%TYPE;
    VCTIPIDE         PER_PERSONAS.CTIPIDE%TYPE;
    VNUM_ERR         NUMBER := 0;
  
  BEGIN
  
    RIE := PAC_IOBJ_PROD.F_PARTPOLRIESGO(PAC_IAX_PRODUCCION.POLIZA.DET_POLIZA,
                                         1,
                                         MENSAJES);
  
    VPASEXEC := 2;
    
    IF RIE.BENEFICIARIO.BENEFESP IS NOT NULL THEN
      VPASEXEC := 3;
      IF RIE.BENEFICIARIO.BENEFESP.BENEF_RIESGO.COUNT > 0 THEN
        VPASEXEC := 4;
        FOR I IN RIE.BENEFICIARIO.BENEFESP.BENEF_RIESGO.FIRST .. RIE.BENEFICIARIO.BENEFESP.BENEF_RIESGO.LAST LOOP
          VPASEXEC := 5;
        
          BEGIN
            VNNUMIDE_BEN := RIE.BENEFICIARIO.BENEFESP.BENEF_RIESGO(I)
                            .NNUMIDE;
          
            IF TO_NUMBER(VNNUMIDE_BEN) <> 0 THEN
            
              SELECT PP.CTIPPER, PP.CTIPIDE, PP.SPERSON
                INTO VCTIPPER, VCTIPIDE, VSPERSON_BEN
                FROM PER_PERSONAS PP
               WHERE PP.NNUMIDE = VNNUMIDE_BEN;
              VPASEXEC := 6;
              IF VCTIPPER = 1 THEN
                SELECT DECODE(PD.TNOMBRE1, NULL, NULL, ' ' || PD.TNOMBRE1) ||
                       DECODE(PD.TNOMBRE2, NULL, NULL, ' ' || PD.TNOMBRE2) ||
                       DECODE(PD.TAPELLI1, NULL, NULL, ' ' || PD.TAPELLI1) ||
                       DECODE(PD.TAPELLI2, NULL, NULL, ' ' || PD.TAPELLI2)
                  INTO VNOMBREPARACOMPL
                  FROM PER_DETPER PD
                 WHERE PD.SPERSON = VSPERSON_BEN;
              ELSE
                SELECT PD.TAPELLI1
                  INTO VNOMBREPARACOMPL
                  FROM PER_DETPER PD
                 WHERE PD.SPERSON = VSPERSON_BEN;
              END IF;
              VPASEXEC := 7;            
              P_TAB_ERROR(F_SYSDATE,
                          F_USER,
                          VOBJECTNAME,
                          VPASEXEC,
                          VPARAM,
                          'VNNUMIDE_BEN : ' || VNNUMIDE_BEN ||
                          ' VNOMBREPARACOMPL : ' || VNOMBREPARACOMPL ||
                          ' VSPERSON_BEN : ' || VSPERSON_BEN ||
                          ' VCTIPIDE : ' || VCTIPIDE || ' VCTIPPER : ' ||
                          VCTIPPER);
              NUM_ERR  := PAC_LISTARESTRINGIDA.F_CONSULTAR_COMPLIANCE(VSPERSON_BEN,
                                                                      VNNUMIDE_BEN,
                                                                      VNOMBREPARACOMPL,
                                                                      VCTIPIDE,
                                                                      VCTIPPER);
              VPASEXEC := 8;
              NUM_ERR := PAC_MARCAS.F_MARCAS_VALIDACION(VSPERSON_BEN,
                                                         4,
                                                         MENSAJES);
              VPASEXEC := 9;
              IF NUM_ERR = 1 THEN
                PTMENSAJE := 'Beneficiario : ' || MENSAJES(1).TERROR;
                VNUM_ERR := VNUM_ERR + 1 ;
                RETURN 1;
              END IF;
            END IF;
          END;
        END LOOP;
      END IF;
    END IF;
  
      RETURN 0;
      
  EXCEPTION
    WHEN OTHERS THEN
      PTMENSAJE := SQLCODE || ' - ' || SQLERRM;
      P_TAB_ERROR(F_SYSDATE,
                  F_USER,
                  VOBJECTNAME,
                  VPASEXEC,
                  VPARAM,
                  'ERROR: ' || PTMENSAJE);
      RETURN 1;
  END F_VALIDA_NUM_BENEF_COMP;
  /* IAXIS-13006 : CAMBIOS DE WEB COMPLIANCE : END  */


END pac_avisos_conf;

/
