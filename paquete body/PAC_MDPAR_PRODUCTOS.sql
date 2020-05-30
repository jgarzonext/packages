--------------------------------------------------------
--  DDL for Package Body PAC_MDPAR_PRODUCTOS
--------------------------------------------------------

CREATE OR REPLACE PACKAGE BODY pac_mdpar_productos
AS
   /******************************************************************************
      NOMBRE:       PAC_MDPAR_PRODUCTOS
      PROPOSITO: Recupera la parametrizacion del producto devolviendo los objetos

      REVISIONES:
      Ver        Fecha        Autor             Descripcion
      ---------  ----------  ---------------  ------------------------------------
      1.0        29/01/2008   ACC              1. Creacion del package.
      2.0        16/02/2009   SBG              2. Creacio funcio f_get_pregtipgru i s'informa CTIPGRU
                                                  de l'objecte OB_IAXPAR_PREGUNTAS (Bug 6296)
      3.0        03/04/2009   DRA              3. 0009217: IAX - Suplement de clausules
      4.0        09/04/2009   JTS              4. BUG9748 - IAX -ACTIVIDAD - Selects contra INCOMPAGARAN, tener en cuenta la actividad
      5.0        17/04/2009   APD              5. Bug 9699 - primero se ha de buscar para la actividad en concreto
                                                  y si no se encuentra nada ir a buscar a PREGUNPROGARAN para la actividad cero
      6.0        15/04/2009   DRA              6. BUG0009661: APR - Tipo de revalorizacion a nivel de producto
      7.0        14/05/2009   ETM              7. BUG0010092: APR - Clausulas por garantia y pregunta
      8.0        28/04/2009   DRA              8. 0009906: APR - Ampliar la parametritzacio de la revaloracio a nivell de garantia
      9.0        28/05/2009   ETM              9. BUG0009855: CEM - Configuraciones varias de Escut Basic,Incluimos el parametro psimul a la funcion f_get_pregpoliza
     10.0        01/07/2009   NMM             10. Bug 10470: CEM - ESCUT - Profesiones sobreprimas y extraprimas
                                                  - f_get_pregpoliza, f_get_datosriesgos, f_get_preggarant
     11.0        13/10/2009   NMM             11. 11432: CEM - Preguntas solo aparecen en simulaciones.
     12.0        24/04/2009   FAL             12. Parametrizar causas de anulacion de poliza en funcion del tipo de baja. Bug 9686.
     13.0        21/10/2009   DRA             13. 0009496: IAX - Contractacio: Gestio de preguntes de garantia + control seleccio minim 1 garantia
     14.0        03/12/2009   JMF             14. 0012227: AGA - Adaptar profesiones con empresa y producto
     15.0        15/01/2010   NMM             15. 12674: CRE087 - Producto ULK- Eliminar pantalla beneficiarios de wizard de contratacion
     16.0        03/02/2010   DRA             16. 0012760: CRE200 - Consulta de polizas: mostrar preguntas automaticas.
     17.0        13/10/2010   FAL             17. 0016073: CRT - Productos anual renovables con duracion definida
     18.0        30/11/2010   SRA             18. 0016803: CRE805 - Rendes flexibles - llista d'anys
     19.0        30/11/2010   LCF             19. 0017182: CRT - Descripcion clausulas
     20.0        01/02/2011   APD             20. 0017362: APR201 - Ajustes GROUPLIFE (V)
     21.0        27/05/2011   APD             21. 0018362: LCOL003 - Parametros en clausulas y visualizacion clausulas automaticas
     22.0        10/06/2011   ETM             22. 0018631: ENSA102- Alta del certificado 0 en Contribucion definida
     23.0        27/06/2011   APD             23. 0018670: ENSA102- Permitir escoger las formas posibles de prestacion a partir del tipo de siniestro
     24.0        25/07/2011   RSC             24. 0019096: LCOL - Parametrizacion basica producto Vida Individual Pagos Permanentes
     25.0        02/01/2012   FAL             25. 0020520: A¿adir duracion vitalicia a los ramos transportes
     26.0        03/01/2012   JMF             26. 0020671: LCOL_T001-LCOL - UAT - TEC: Contrataci?n
     27.0        02/02/2012   JLTS            26. 0021546: LCOL - JLTS - Cierre de cursores
     28.0        09/01/2012   DRA             28. 0020498: LCOL_T001-LCOL - UAT - TEC - Beneficiaris de la p?lissa
     29.0        09/05/2012   APD             29. 0022049: MDP - TEC - Visualizar garantias y sub-garantias
     30.0        27/06/2012   JMC             30. 0022011: AGM101 - Correccion de incidencias detectadas en AGM
     31.0        16/10/2012   DRA             31. 0022402: LCOL_C003: Adaptaci¿n del co-corretaje
     32.0        18/10/2012   DRA             32. 0023911: LCOL: A¿adir Retorno para los productos Colectivos
     33.0        06/11/2012   DRA             33. 0023117: LCOL_T010-LCOL - POLIZAS RENOVABLES Y VIGENCIA DIFERENTE A UN A?O
     34.0        04/02/2013   JMF             0025583: LCOL - Revision incidencias qtracker (IV)
     35.0        08/04/2013   MMS             35. 0026503: POSRA400-(POSRA400)-Vida Grupo Deudores
     36.0        03/06/2013   MMS             36.0 0026501: POSRA400-(POSRA400)-Vida Grupo (Voluntario)
     37.0        06/09/2013   DCT             37.0 0027923  LCOL_F3BTEC-MTF3B - LCOL_TEC23 - Definici?n de condiciones en Certificado
     38.0        28/10/2013   JSV             38.0 0027768: LCOL_F3B-Fase 3B - Parametrizaci?n B?sica AWS
     39.0        14/11/2013   JSV             39.0 0028610: LCOL - TARIFICACI¿N 6047 - TP (Colectivo Pesados)
     40.0        21/01/2014   JTT             40.0 0026501: A¿adir el parametro PMT_NPOLIZA a las preguntas de tipo CONSULTA
     41.0        03/04/2014   dlF             41.0 0027744: Producto de Explotaciones 2014 - Ocultar garantias en modo SSIMULACION
     42.0        15/04/2014   dlF             42.0 0027744: Producto de Explotaciones 2014 - Tratamiento preguntas garantoas en modo SIMULACION
     43.0        23-05-2014   SSM             43.0  (30145/175326) LCOL999-Nueva Estructura de Tarifas AUTOS  - Modificaci¿n, se a¿ade parametro pcodgrup a function pac_bonfran.f_resuelve_formula
     44.0        12-06-2014   SSM             44.0  27768/0176025 : LCOL_F3B-Fase 3B - Parametrizaci?n B?sica AWS
     45.0        16/09/2014   JMF             45.0 0032784: LCOL_T010-Revisi¿n incidencias qtracker (2014/09) QT 13462
     46.0        06/02/2015   AFM             46.0 0034461: Productos de CONVENIOS
     47.0        09/12/2015   FAL             47. 0036730: I - Producto Subsidio Individual
     48.0        14/04/2016   DMCC            48.0 0041438: Nota 232126 - AMA002-Validaciones (Sin validaci¿n de retorno) ID. 10 A seg¿n el tipo de colectivo el tipo de cobro se arrastra o meno
     49.0        10/07/2019   CJMR            49.0 IAXIS-4203 Agrupación RC: Ajustes en evaluación de querys de preguntas
     50.0        03/09/2019   ECP             50.0 IAXIS-4082. Convenio Grandes Beneficiarios - RCE Derivado de Contratos
	 51.0        23/09/2019   CJMR            51.0 IAXIS-5423. Ajustes deducibles.
   ******************************************************************************/
   e_object_error   EXCEPTION;
   e_param_error    EXCEPTION;

   /***********************************************************************
      Oculta o muestra la garantia en modo SIMULACION si ha sido
      configurada.
      return   : visibilidad de la garantia en modo SIMULACION
   ***********************************************************************/
   FUNCTION focultagarantia (
      pnproducto      NUMBER,
      pngarantia      NUMBER,
      pnvisibilidad   PLS_INTEGER
   )
      RETURN NUMBER
   IS
      nvisibilidad   PLS_INTEGER := pnvisibilidad;
   BEGIN
      IF pac_iax_produccion.issimul
      THEN
         SELECT CASE COUNT (1)
                   WHEN 0
                      THEN pnvisibilidad
                   ELSE NVL (MAX (cvalpar), pnvisibilidad)
                END
           INTO nvisibilidad
           FROM pargaranpro
          WHERE sproduc = pnproducto
            AND cgarant = pngarantia
            AND cpargar = 'SIMULACION';
      END IF;

      RETURN nvisibilidad;
   END;

   /***********************************************************************
      Devuelve el parametro de producto especificado
      return   : valor del parametro
   ***********************************************************************/
   FUNCTION f_get_parproducto (clave IN VARCHAR2, psproduc IN NUMBER)
      RETURN NUMBER
   IS
      mensajes   t_iax_mensajes;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (500) := 'clave =' || clave;
      vobject    VARCHAR2 (200) := 'PAC_MDPAR_PRODUCTOS.F_Get_ParProducto';
      vplan      NUMBER;
      v_gars     NUMBER;
   BEGIN
      IF clave = 'NUM_GARAN_PANT'
      THEN
         IF     NVL (f_parproductos_v (psproduc, 'ADMITE_CERTIFICADOS'), 0) =
                                                                            1
            AND NVL (f_parproductos_v (psproduc, 'HEREDA_GARANTIAS'), 0) IN
                                                                       (3, 4)
            AND NOT pac_iax_produccion.isaltacol
         THEN
            IF     pac_iax_produccion.poliza.det_poliza.preguntas IS NOT NULL
               AND pac_iax_produccion.poliza.det_poliza.preguntas.COUNT > 0
            THEN
               FOR i IN
                  pac_iax_produccion.poliza.det_poliza.preguntas.FIRST .. pac_iax_produccion.poliza.det_poliza.preguntas.LAST
               LOOP
                  IF pac_iax_produccion.poliza.det_poliza.preguntas (i).cpregun =
                                                                         4089
                  THEN
                     vplan :=
                        pac_iax_produccion.poliza.det_poliza.preguntas (i).crespue;
                  END IF;
               END LOOP;
            END IF;

            SELECT COUNT (*)
              INTO v_gars
              FROM garanseg g, seguros s
             WHERE g.sseguro = s.sseguro
               AND g.nriesgo = NVL (vplan, 1)
               AND g.ffinefe IS NULL
               AND s.npoliza = pac_iax_produccion.poliza.det_poliza.npoliza
               AND s.ncertif = 0;

            RETURN v_gars;
         ELSE
            RETURN NVL (f_parproductos_v (psproduc, clave), 0);
         END IF;
      ELSE
         RETURN NVL (f_parproductos_v (psproduc, clave), 0);
      END IF;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 0;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 0;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 0;
   END f_get_parproducto;

   /***********************************************************************
      Devuelve el codigo del subtipo de producto VF 37
      return   : codigo del subtipo de producto
   ***********************************************************************/
   FUNCTION f_get_subtipoprod (psproduc IN NUMBER)
      RETURN NUMBER
   IS
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (500) := 'psproduc=' || psproduc;
      vobject    VARCHAR2 (200) := 'PAC_MDPAR_PRODUCTOS.F_Get_SubtipoProd';
      vcsubpro   NUMBER;
      vnumerr    NUMBER (8)     := 0;
      mensajes   t_iax_mensajes;
   BEGIN
      --Comprovacio de parametres d'entrada
      IF psproduc IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      --BUG6936-12022009-XVM
      vnumerr := pac_productos.f_get_subtipoprod (psproduc, vcsubpro);

      IF vnumerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      --BUG6936-12022009-XVM
      RETURN vcsubpro;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 0;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 0;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 0;
   END f_get_subtipoprod;

   /***********************************************************************
      Recupera las formas de pago del producto
      param in psproduc  : codigo del producto
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_formapago (psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur              sys_refcursor;
      squery           VARCHAR2 (1000);
      vpasexec         NUMBER (8)                         := 1;
      vparam           VARCHAR2 (500)              := 'psproduc=' || psproduc;
      vobject          VARCHAR2 (200)
                                     := 'PAC_MDPAR_PRODUCTOS.F_Get_FormaPago';
      -- BUG 0022839 - FAL - 24/07/2012
      v_cond           VARCHAR2 (2000)                    := NULL;
      v_cforpag        prodherencia_colect.cforpag%TYPE;
      num_err          NUMBER;
      -- FI BUG 0022839
        -- Ini Bug 0041438: Nota 232126 - AMA002-Validaciones (Sin validaci¿n de retorno) ID. 10
      vnumerr          NUMBER                             := 0;
      n_registro       NUMBER;
      v_cpregun_4092   pregunpolseg.cpregun%TYPE          := 4092;
      v_crespue_4092   pregunpolseg.crespue%TYPE;
      v_trespue_4092   pregunpolseg.trespue%TYPE;
      v_existepreg     NUMBER;
      v_sseguro        NUMBER;
   -- Fin Bug 0041438: Nota 232126 - AMA002-Validaciones (Sin validaci¿n de retorno) ID. 10
   BEGIN
      --Inicialitzacions
      IF psproduc IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      -- BUG 0022839 - FAL - 24/07/2012
      IF     pac_mdpar_productos.f_get_parproducto ('ADMITE_CERTIFICADOS',
                                                    psproduc
                                                   ) = 1
         AND NOT pac_iax_produccion.isaltacol
      THEN
         num_err := pac_productos.f_get_herencia_col (psproduc, 2, v_cforpag);

         IF NVL (v_cforpag, 0) = 1 AND num_err = 0
         THEN
            -- Ini Bug 0041438: Nota 232126 - AMA002-Validaciones (Sin validaci¿n de retorno) ID. 10
            IF pac_mdpar_productos.f_get_parproducto ('ARRASTRA_CFORPAG',
                                                      psproduc
                                                     ) = 1
            THEN
               SELECT sseguro
                 INTO v_sseguro
                 FROM seguros
                WHERE ncertif = 0
                  AND npoliza = pac_iax_produccion.poliza.det_poliza.npoliza;

               SELECT crespue
                 INTO v_crespue_4092
                 FROM pregunpolseg
                WHERE sseguro = v_sseguro
                  AND cpregun = 4092
                  AND nmovimi =
                               (SELECT MAX (nmovimi)
                                  FROM pregunpolseg
                                 WHERE sseguro = v_sseguro AND cpregun = 4092);
                                             -- BUG 0042821 - FAL - 23/05/2016

               IF NVL (v_crespue_4092, 0) = 2
               THEN
                  v_cond := NULL;
               ELSE
                  v_cond :=
                        'AND F.cforpag = (select cforpag from seguros where ncertif =
                                0 and npoliza = '
                     || pac_iax_produccion.poliza.det_poliza.npoliza
                     || ')';
               END IF;
            ELSE
               -- Fin Bug 0041438: Nota 232126 - AMA002-Validaciones (Sin validaci¿n de retorno) ID. 10
               v_cond :=
                     'AND F.cforpag = (select cforpag from seguros where ncertif = 0 and npoliza = '
                  || pac_iax_produccion.poliza.det_poliza.npoliza
                  || ')';
            END IF;
         ELSE
            v_cond := NULL;
         END IF;
      END IF;

      -- FI BUG 0022839
      squery :=
            'SELECT d.catribu , d.tatribu '
         || ' from     DETVALORES D, FORPAGPRO F,PRODUCTOS P '
         || ' WHERE f.ccolect = p.ccolect '
         || '    AND f.ctipseg = p.ctipseg '
         || '    AND f.cmodali = p.cmodali '
         || '    AND f.cramo = p.cramo '
         || '    AND f.cforpag = d.catribu '
         || '    AND d.cidioma =  '
         || pac_md_common.f_get_cxtidioma
         || '    AND p.sproduc =  '
         || psproduc
         -- || ' AND d.cvalor = 17 ' || ' ORDER BY d.catribu';
         || '    AND d.cvalor = 17 '
         || v_cond
         || ' ORDER BY d.catribu'; -- BUG 0022839 - FAL - 24/07/2012 -  v_cond
      cur := pac_md_listvalores.f_opencursor (squery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_formapago;

   /***********************************************************************
      Recupera las duraciones del producto
      param in psproduc  : codigo del producto
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_tipduracion (
      psproduc   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      cur         sys_refcursor;
      squery      VARCHAR2 (500);
      vcduraci    NUMBER;
      vpasexec    NUMBER (8)     := 1;
      vparam      VARCHAR2 (500) := 'psproduc =' || psproduc;
      vobject     VARCHAR2 (200) := 'PAC_MDPAR_PRODUCTOS.F_Get_TipDuracion';
      vnumerr     NUMBER (8)     := 0;
      wctempor    NUMBER;
      v_cduraci   NUMBER;
      -- BUG23117:DRA:06/11/2012:Inici
      v_crespue   NUMBER;
      v_sseguro   NUMBER;
   -- BUG23117:DRA:06/11/2012:Fi
   BEGIN
      --Comprovacio de parametres d'entrada
      IF psproduc IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_productos.f_get_tipduracion (psproduc, vcduraci);

      IF vnumerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      BEGIN
         SELECT ctempor
           INTO wctempor
           FROM productos
          WHERE sproduc = psproduc;
      EXCEPTION
         WHEN OTHERS
         THEN
            RAISE e_object_error;
      END;

      -- Bug 16073. FAL. 13/10/2010. 0016073: CRT - Productos anual renovables con duracion definida
      IF NVL (wctempor, 0) = 1
      THEN
         cur :=
            pac_md_listvalores.f_detvalorescond (41,
                                                    '(catribu='
                                                 || NVL (vcduraci, 0)
                                                 || ' or catribu=3) ',
                                                 mensajes
                                                );
      -- Bug 0020520 - FAL - 27/12/2011. A¿adir duracion vitalicia a los ramos transportes
      ELSIF NVL (wctempor, 0) = 2
      THEN
         cur :=
            pac_md_listvalores.f_detvalorescond (41,
                                                    '(catribu='
                                                 || NVL (vcduraci, 0)
                                                 || ' or catribu IN (3,4)) ',
                                                 mensajes
                                                );
      -- Fi Bug 0020520
      -- Bug 23117 - RSC - 13/08/2012. LCOL_T010-LCOL - POLIZAS RENOVABLES Y VIGENCIA DIFERENTE A UN ANYO
      ELSIF NVL (wctempor, 0) = 3
      THEN
         -- Fi Bug 16073
         IF     pac_mdpar_productos.f_get_parproducto ('ADMITE_CERTIFICADOS',
                                                       psproduc
                                                      ) = 1
            AND NOT pac_iax_produccion.isaltacol
         THEN
            vnumerr :=
                    pac_productos.f_get_herencia_col (psproduc, 7, v_cduraci);

            IF NVL (v_cduraci, 0) = 1 AND vnumerr = 0
            THEN
               vnumerr :=
                  pac_seguros.f_get_tipo_duracion_cero
                               (NULL,
                                pac_iax_produccion.poliza.det_poliza.npoliza,
                                'SEG',
                                vcduraci
                               );

               IF vnumerr <> 0
               THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, vnumerr);
                  RAISE e_object_error;
               END IF;

               -- BUG23117:DRA:06/11/2012:Inici
               BEGIN
                  SELECT sseguro
                    INTO v_sseguro
                    FROM seguros
                   WHERE npoliza =
                                  pac_iax_produccion.poliza.det_poliza.npoliza
                     AND ncertif = 0;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     v_sseguro := NULL;
               END;

               IF v_sseguro IS NOT NULL
               THEN
                  vnumerr :=
                     pac_preguntas.f_get_pregunpolseg (v_sseguro,
                                                       4790,
                                                       'SEG',
                                                       v_crespue
                                                      );
               ELSE
                  v_crespue := NULL;
               END IF;

               -- BUG23117:DRA:06/11/2012:Fi

               -- Si es de Vigencia Tancada no ha de mostrar el Temporal Renovable
               IF NVL (v_crespue, 2) = 1
               THEN
                  cur :=
                     pac_md_listvalores.f_detvalorescond (41,
                                                             '(catribu='
                                                          || NVL (vcduraci, 0)
                                                          -- BUG 0023640 - FAL - 27/09/2012
                                                          --|| ' or catribu = 6) ',
                                                          || ') ',
                                                          -- FI BUG 0023640
                                                          mensajes
                                                         );
               ELSE
                  vnumerr :=
                         pac_productos.f_get_tipduracion (psproduc, vcduraci);

                  IF vnumerr <> 0
                  THEN
                     pac_iobj_mensajes.crea_nuevo_mensaje (mensajes,
                                                           1,
                                                           vnumerr
                                                          );
                     RAISE e_object_error;
                  END IF;

                  cur :=
                     pac_md_listvalores.f_detvalorescond (41,
                                                             '(catribu='
                                                          || NVL (vcduraci, 0)
                                                          || ' or catribu = 6) ',
                                                          mensajes
                                                         );
               END IF;
            --Bug 22839-XVM-07/11/2012.Inicio
            ELSIF NVL (v_cduraci, 0) = 2
            THEN
               -- BUG23117:DRA:06/11/2012:Inici
               BEGIN
                  SELECT sseguro
                    INTO v_sseguro
                    FROM seguros
                   WHERE npoliza =
                                  pac_iax_produccion.poliza.det_poliza.npoliza
                     AND ncertif = 0;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     v_sseguro := NULL;
               END;

               IF v_sseguro IS NOT NULL
               THEN
                  vnumerr :=
                     pac_preguntas.f_get_pregunpolseg (v_sseguro,
                                                       4790,
                                                       'SEG',
                                                       v_crespue
                                                      );
               ELSE
                  v_crespue := NULL;
               END IF;

               -- BUG23117:DRA:06/11/2012:Fi

               -- Si es de Vigencia Tancada no ha de mostrar el Temporal Renovable
               IF NVL (v_crespue, 2) = 1
               THEN
                  cur :=
                     pac_md_listvalores.f_detvalorescond (41,
                                                          '(catribu = 6) ',
                                                          mensajes
                                                         );
               ELSE
                  cur :=
                     pac_md_listvalores.f_detvalorescond
                                                        (41,
                                                            '(catribu='
                                                         || NVL (vcduraci, 0)
                                                         || ' or catribu = 6) ',
                                                         mensajes
                                                        );
               END IF;
            --Bug 22839-XVM-07/11/2012.Fin
            ELSE
               cur :=
                  pac_md_listvalores.f_detvalorescond (41,
                                                          '(catribu='
                                                       || NVL (vcduraci, 0)
                                                       || ' or catribu = 6) ',
                                                       mensajes
                                                      );
            END IF;
         ELSE
            cur :=
               pac_md_listvalores.f_detvalorescond (41,
                                                       '(catribu='
                                                    || NVL (vcduraci, 0)
                                                    || ' or catribu = 6) ',
                                                    mensajes
                                                   );
         END IF;
      -- Fi Bug 23117
      -- Bug 0026503 - MMS - 08/04/2013. 0026503: POSRA400-(POSRA400)-Vida Grupo Deudores
      ELSIF NVL (wctempor, 0) = 4
      THEN
         IF     pac_mdpar_productos.f_get_parproducto ('ADMITE_CERTIFICADOS',
                                                       psproduc
                                                      ) = 1
            AND NOT pac_iax_produccion.isaltacol
         THEN
            vnumerr :=
                    pac_productos.f_get_herencia_col (psproduc, 7, v_cduraci);

            IF NVL (v_cduraci, 0) = 1 AND vnumerr = 0
            THEN
               vnumerr :=
                  pac_seguros.f_get_tipo_duracion_cero
                               (NULL,
                                pac_iax_produccion.poliza.det_poliza.npoliza,
                                'SEG',
                                vcduraci
                               );

               IF vnumerr <> 0
               THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, vnumerr);
                  RAISE e_object_error;
               END IF;

               cur :=
                  pac_md_listvalores.f_detvalorescond (41,
                                                          '(catribu='
                                                       || NVL (vcduraci, 0),
                                                       --|| ' or catribu = 6) ',
                                                       mensajes
                                                      );
            --Bug 22839-XVM-07/11/2012.Inicio
            ELSIF NVL (v_cduraci, 0) = 2
            THEN
               cur :=
                  pac_md_listvalores.f_detvalorescond (41,
                                                       '(catribu = 0) ',
                                                       mensajes
                                                      );
            --Bug 22839-XVM-07/11/2012.Fin
            ELSE
               cur :=
                  pac_md_listvalores.f_detvalorescond (41,
                                                          '(catribu='
                                                       || NVL (vcduraci, 0)
                                                       || ' or catribu = 2) ',
                                                       mensajes
                                                      );
            END IF;
         ELSE
            cur :=
               pac_md_listvalores.f_detvalorescond (41,
                                                       '(catribu='
                                                    || NVL (vcduraci, 0)
                                                    || ' or catribu = 2) ',
                                                    mensajes
                                                   );
         END IF;
      -- Fi Bug 0026503 MMS 08/04/2013
      --CONVENIOS NUEVO TIPO DURACION
      ELSIF NVL (wctempor, 0) = 5
      THEN
         -- Fi Bug 16073
         IF     pac_mdpar_productos.f_get_parproducto ('ADMITE_CERTIFICADOS',
                                                       psproduc
                                                      ) = 1
            AND NOT pac_iax_produccion.isaltacol
         THEN
            vnumerr :=
                    pac_productos.f_get_herencia_col (psproduc, 7, v_cduraci);

            IF NVL (v_cduraci, 0) = 1 AND vnumerr = 0
            THEN
               vnumerr :=
                  pac_seguros.f_get_tipo_duracion_cero
                               (NULL,
                                pac_iax_produccion.poliza.det_poliza.npoliza,
                                'SEG',
                                vcduraci
                               );

               IF vnumerr <> 0
               THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, vnumerr);
                  RAISE e_object_error;
               END IF;

               -- BUG23117:DRA:06/11/2012:Inici
               BEGIN
                  SELECT sseguro
                    INTO v_sseguro
                    FROM seguros
                   WHERE npoliza =
                                  pac_iax_produccion.poliza.det_poliza.npoliza
                     AND ncertif = 0;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     v_sseguro := NULL;
               END;

               IF v_sseguro IS NOT NULL
               THEN
                  vnumerr :=
                     pac_preguntas.f_get_pregunpolseg (v_sseguro,
                                                       4790,
                                                       'SEG',
                                                       v_crespue
                                                      );
               ELSE
                  v_crespue := NULL;
               END IF;

               -- BUG23117:DRA:06/11/2012:Fi

               -- Si es de Vigencia Tancada no ha de mostrar el Temporal Renovable
               IF NVL (v_crespue, 2) = 1
               THEN
                  cur :=
                     pac_md_listvalores.f_detvalorescond (41,
                                                             '(catribu='
                                                          || NVL (vcduraci, 0)
                                                          -- BUG 0023640 - FAL - 27/09/2012
                                                          --|| ' or catribu = 6) ',
                                                          || ') ',
                                                          -- FI BUG 0023640
                                                          mensajes
                                                         );
               ELSE
                  vnumerr :=
                         pac_productos.f_get_tipduracion (psproduc, vcduraci);

                  IF vnumerr <> 0
                  THEN
                     pac_iobj_mensajes.crea_nuevo_mensaje (mensajes,
                                                           1,
                                                           vnumerr
                                                          );
                     RAISE e_object_error;
                  END IF;

                  cur :=
                     pac_md_listvalores.f_detvalorescond
                        (41,
                            '(catribu='
                         || NVL (vcduraci, 0)
                         || ' or catribu = 6 or catribu = 3) ',
                                                       --JRH A¿adimos temporal
                         mensajes
                        );
               END IF;
            --Bug 22839-XVM-07/11/2012.Inicio
            ELSIF NVL (v_cduraci, 0) = 2
            THEN
               -- BUG23117:DRA:06/11/2012:Inici
               BEGIN
                  SELECT sseguro
                    INTO v_sseguro
                    FROM seguros
                   WHERE npoliza =
                                  pac_iax_produccion.poliza.det_poliza.npoliza
                     AND ncertif = 0;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     v_sseguro := NULL;
               END;

               IF v_sseguro IS NOT NULL
               THEN
                  vnumerr :=
                     pac_preguntas.f_get_pregunpolseg (v_sseguro,
                                                       4790,
                                                       'SEG',
                                                       v_crespue
                                                      );
               ELSE
                  v_crespue := NULL;
               END IF;

               -- BUG23117:DRA:06/11/2012:Fi

               -- Si es de Vigencia Tancada no ha de mostrar el Temporal Renovable
               IF NVL (v_crespue, 2) = 1
               THEN
                  cur :=
                     pac_md_listvalores.f_detvalorescond (41,
                                                          '(catribu = 6) ',
                                                          mensajes
                                                         );
               ELSE
                  cur :=
                     pac_md_listvalores.f_detvalorescond
                                                        (41,
                                                            '(catribu='
                                                         || NVL (vcduraci, 0)
                                                         || ' or catribu = 6) ',
                                                         mensajes
                                                        );
               END IF;
            --Bug 22839-XVM-07/11/2012.Fin
            ELSE
               cur :=
                  pac_md_listvalores.f_detvalorescond (41,
                                                          '(catribu='
                                                       || NVL (vcduraci, 0)
                                                       || ' or catribu = 6) ',
                                                       mensajes
                                                      );
            END IF;
         ELSE
            IF pac_iax_produccion.isaltacol
            THEN
               cur :=
                  pac_md_listvalores.f_detvalorescond (41,
                                                          '(catribu='
                                                       || NVL (vcduraci, 0)
                                                       || ' or catribu = 6) ',
                                                       mensajes
                                                      );
            ELSE
               cur :=
                  pac_md_listvalores.f_detvalorescond
                                         (41,
                                             '(catribu='
                                          || NVL (vcduraci, 0)
                                          || ' or catribu = 6 or catribu = 3) ',
                                          mensajes
                                         );
            END IF;
         END IF;
      ELSIF NVL (wctempor, 0) = 0
      THEN
         cur :=
            pac_md_listvalores.f_detvalorescond (41,
                                                    'catribu='
                                                 || NVL (vcduraci, 0),
                                                 mensajes
                                                );
      END IF;

      RETURN cur;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_tipduracion;

   /***********************************************************************
      Recupera las preguntas a nivel de poliza
      param in psproduc  : codigo del producto
      param out mensajes : mensajes de error
      return             : objeto preguntas
   ***********************************************************************/
   FUNCTION f_get_pregpoliza (
      psproduc    IN       NUMBER,
      psimul      IN       BOOLEAN,               --BUG0009855:ETM: 28/05/2009
      pissuplem   IN       BOOLEAN,
      mensajes    IN OUT   t_iax_mensajes
   )
      RETURN t_iaxpar_preguntas
   IS
      preg             t_iaxpar_preguntas;
      resp             t_iaxpar_respuestas;
      vpasexec         NUMBER (8)                := 1;
      vparam           VARCHAR2 (500)            := 'psproduc=' || psproduc;
      vobject          VARCHAR2 (200)
                                    := 'PAC_MDPAR_PRODUCTOS.F_Get_PregPoliza';
      -- BUG 10470 - 01/07/2009 -JJG - Tratar preguntas tipo 6 - Tabla.i.
      vconsulta        VARCHAR2 (4000);
      cur              sys_refcursor;
      w_cprofes        VARCHAR2 (200);
      w_tprofes        VARCHAR2 (500);

      -- BUG 10470.f.
      -- BUG 6296 - 16/03/2009 - SBG - Afegim nou camp ctipgru al cursor
      CURSOR c_pregpro (pisaltacol IN NUMBER, pissuplemento IN NUMBER)
      IS
         SELECT   prepro.cpregun, preng.tpregun, prepro.cpretip,
                  prepro.npreord, prepro.tprefor, prepro.cpreobl,
                  prepro.cresdef, prepro.cofersn, prepro.tvalfor,
                  prepro.ctabla, prepro.cmodo, cpreg.ctippre, cpreg.ctipgru,
                  cpreg.tconsulta, prepro.cvisible cvisible,
                  prepro.esccero esccero,                  -- Bug 19504   JBN
                                         crecarg
             FROM pregunpro prepro, preguntas preng, codipregun cpreg
            WHERE prepro.cpregun = preng.cpregun
              AND preng.cidioma = pac_md_common.f_get_cxtidioma
              AND prepro.cnivel = 'P'
              AND (   (pissuplemento = 1 AND prepro.cmodo IN ('T', 'S'))
                   OR ((pissuplemento = 0) AND prepro.cmodo IN ('T', 'N'))
                  )
              AND (   prepro.cpretip <> 2
                   OR (    prepro.cpretip = 2
                       AND prepro.esccero = 1
                       AND pisaltacol = 1
                      )
-- Bug 16106 - RSC - 21/09/2010 - APR - Ajustes e implementacion para el alta de colectivos
                   OR (prepro.cvisible = 2)
                  )                                         -- Bug 19504   JBN
              AND (   (prepro.visiblecol = 1 AND pisaltacol = 1)
                   OR (pisaltacol = 0 AND prepro.visiblecert = 1)
                  )        -- Bug 17362 - APD - 01/02/2011 - Ajustes GROUPLIFE
              AND cpreg.cpregun = prepro.cpregun
              AND prepro.sproduc = psproduc
         ORDER BY prepro.npreord;

      CURSOR c_resppro (cprg NUMBER)
      IS
         SELECT   crespue, trespue
             FROM respuestas rsp
            WHERE rsp.cpregun = cprg
              AND rsp.cidioma = pac_md_common.f_get_cxtidioma
         ORDER BY rsp.crespue;

      -- Bug 16106 - RSC - 11/10/2010 - APR - Ajustes e implementacion para el alta de colectivos
      v_isaltacol      NUMBER;
      -- Fin Bug 16106
      v_issuplem       NUMBER                    := 0;
      --Ini IAXIS-4082 -- ECP -- 29/08/2019
      v_cpregun_2912   preguntas.cpregun%TYPE    := 2912;
      v_trespue_2912   pregunseg.trespue%TYPE;
      vsperson         per_detper.sperson%TYPE;
   --Fin IAXIS-4082 -- ECP -- 29/08/2019
   BEGIN
      --Inicialitzacions
      IF psproduc IS NULL
      THEN
          -- BUG 0023615 - JMF - 18/09/2012
         -- RAISE e_param_error;
         RETURN NULL;
      END IF;

      vpasexec := 2;

      -- Bug 16106 - RSC - 11/10/2010 - APR - Ajustes e implementacion para el alta de colectivos
      IF pac_iax_produccion.isaltacol
      THEN
         v_isaltacol := 1;
      ELSE
         v_isaltacol := 0;
      END IF;

      IF pissuplem = TRUE
      THEN
         v_issuplem := 1;
      ELSE
         v_issuplem := 0;
      END IF;

      -- Fin Bug 16106
      FOR prg IN c_pregpro (v_isaltacol, v_issuplem)
      LOOP
         vpasexec := 3;

         -- Bug 11432.13/10/2009.NMM.i.: CEM - Preguntas solo aparecen en simulaciones.
         IF    (psimul = FALSE AND prg.cofersn <> 2)
            OR (psimul = TRUE AND prg.cofersn IN (1, 2))
         THEN
            /*IF psimul = FALSE
               OR(psimul = TRUE
                  AND prg.cofersn <> 0) THEN   -- BUG 9855 - 28/05/2009 - ETM*/
            vpasexec := 4;

            IF preg IS NULL
            THEN
               vpasexec := 5;
               preg := t_iaxpar_preguntas ();
            END IF;

            vpasexec := 6;
            preg.EXTEND;
            preg (preg.LAST) := ob_iaxpar_preguntas ();
            preg (preg.LAST).cpregun := prg.cpregun;
            preg (preg.LAST).tpregun := prg.tpregun;
            -- Bug 22839 - RSC - 17/07/2012 - LCOL - Funcionalidad Certificado 0
            preg (preg.LAST).esccero := prg.esccero;

            IF prg.cpretip = 2 AND prg.esccero = 1 AND v_isaltacol = 1
            THEN
               preg (preg.LAST).cpretip := 1;
            ELSE
               preg (preg.LAST).cpretip := prg.cpretip;
            END IF;

            -- Bug 22839 - RSC - 19/11/2012 - LCOL_T010-LCOL - Funcionalidad Certificado 0
            IF prg.cpretip = 3 AND prg.esccero = 1 AND v_isaltacol = 0
            THEN
               preg (preg.LAST).isaltac := 1;
            END IF;

            -- Fin bug 22839

            -- Fin Bug 22839
            preg (preg.LAST).npreord := prg.npreord;
            preg (preg.LAST).tprefor := prg.tprefor;
            preg (preg.LAST).cpreobl := prg.cpreobl;
            preg (preg.LAST).cresdef := prg.cresdef;
            preg (preg.LAST).cofersn := prg.cofersn;
            preg (preg.LAST).tvalfor := prg.tvalfor;
            preg (preg.LAST).ctabla := prg.ctabla;
            preg (preg.LAST).cmodo := prg.cmodo;
            preg (preg.LAST).cvisible := NVL (prg.cvisible, 0);        --19504
            preg (preg.LAST).crecarg := prg.crecarg;
            vpasexec := 7;

            IF prg.ctippre IN (4, 5)
            THEN                             -- tipo pregunta VF 78 detvalores
               vpasexec := 8;
               preg (preg.LAST).crestip := 0;             -- 0 es texto libre
            ELSIF prg.ctippre IN (3, 8)
            THEN                                        -- tipo pregunta VF 78
               vpasexec := 9;
               preg (preg.LAST).crestip := 2;
             -- 2 indentifica que la resposta es texte pero es guarda crespue
            ELSIF prg.ctippre = 7
            THEN                                        -- tipo pregunta VF 78
               vpasexec := 9;
               preg (preg.LAST).crestip := 3;
             -- 2 indentifica que la resposta es texte pero es guarda crespue
            ELSE
               vpasexec := 10;
               preg (preg.LAST).crestip := 1;
                                             -- 1 la respuesta es desplegable
            END IF;

            vpasexec := 11;
            preg (preg.LAST).ctippre := prg.ctippre;  -- tipo pregunta (VF 78)
            -- BUG 6296 - 16/03/2009 - SBG - Informem nou camp ctipgru
            preg (preg.LAST).ctipgru := prg.ctipgru;
                                              -- tipo grupo preguntas (VF 309)
            resp := NULL;
            vpasexec := 12;

            -- BUG 10470 - 01/07/2009 -JJG/NMM - Tratar preguntas tipo 6 - Tabla.
            IF prg.ctippre IN (6, 8)
            THEN
               vpasexec := 13;
               vconsulta :=
                  REPLACE (prg.tconsulta,
                           ':PMT_IDIOMA',
                           pac_md_common.f_get_cxtidioma
                          );
               -- INI Bug 0012227 - 03/12/2009 - JMF
               vconsulta := REPLACE (vconsulta, ':PMT_SPRODUC', psproduc);
               -- FIN Bug 0012227 - 03/12/2009 - JMF

               -- INI IAXIS-3169 - 15/03/2019 - BARTOLO HERRERA
               vconsulta :=
                  REPLACE
                     (vconsulta,
                      ':PMT_CACTIVI',
                      NVL
                         (pac_iax_produccion.poliza.det_poliza.gestion.cactivi,
                          0
                         )
                     );
               -- FIN IAXIS-3169 - 15/03/2019 - BARTOLO HERRERA

               -- Bug 22839 - RSC - 17/07/2012 - LCOL - Funcionalidad Certificado 0
               vconsulta :=
                  REPLACE (vconsulta,
                           ':PMT_NPOLIZA',
                           pac_iax_produccion.poliza.det_poliza.npoliza
                          );
               vconsulta :=
                  REPLACE (vconsulta,
                           ':PMT_SSEGURO',
                           pac_iax_produccion.poliza.det_poliza.sseguro
                          );
               --BUG25033: 132175: DCT : 10/12/2012: INICIO
               vconsulta :=
                  REPLACE
                         (vconsulta,
                          ':PMT_CFORPAG',
                          pac_iax_produccion.poliza.det_poliza.gestion.cforpag
                         );
               --BUG25033: 132175: DCT : 10/12/2012: FIN

               -- Fin Bug 22839
               --JLV 23/04/2014 a¿adir el agente, es necesario para las campa¿¿as
               vconsulta :=
                  REPLACE (vconsulta,
                           ':PMT_CAGENTE',
                           pac_iax_produccion.poliza.det_poliza.cagente
                          );

                                          
               -- Ini IAXIS-4082 -- ECP -- 03/09/2019
               IF NVL
                     (pac_mdpar_productos.f_get_parproducto
                                 ('CONV_CONTRATANTE',
                                  pac_iax_produccion.poliza.det_poliza.sproduc
                                 ),
                      0
                     ) = 0
               THEN
                  IF pac_iax_produccion.poliza.det_poliza.riesgos
                          (pac_iax_produccion.poliza.det_poliza.riesgos.FIRST).riespersonal IS NOT NULL
                  THEN
                     vconsulta :=
                        REPLACE
                           (vconsulta,
                            ':PMT_ASEGURADOPER',
                            pac_iax_produccion.poliza.det_poliza.riesgos
                               (pac_iax_produccion.poliza.det_poliza.riesgos.FIRST
                               ).riespersonal
                               (pac_iax_produccion.poliza.det_poliza.riesgos
                                   (pac_iax_produccion.poliza.det_poliza.riesgos.FIRST
                                   ).riespersonal.FIRST
                               ).spereal
                           );
                           
                  ELSE
                     
                     vconsulta :=
                          REPLACE (vconsulta, ':PMT_ASEGURADOPER', 'sperson');
                  END IF;
               ELSE
                 
                  IF pac_iax_produccion.poliza.det_poliza.preguntas IS NOT NULL
                  THEN
                     IF pac_iax_produccion.poliza.det_poliza.preguntas.COUNT >
                                                                            0
                     THEN
                        FOR i IN
                           pac_iax_produccion.poliza.det_poliza.preguntas.FIRST .. pac_iax_produccion.poliza.det_poliza.preguntas.LAST
                        LOOP
                           --Ini IAXIS-4082 -- ECP -- 29/08/2019
                           IF v_cpregun_2912 =
                                 pac_iax_produccion.poliza.det_poliza.preguntas
                                                                          (i).cpregun
                           THEN
                              v_trespue_2912 :=
                                 pac_iax_produccion.poliza.det_poliza.preguntas
                                                                          (i).trespue;
                           END IF;

                           --Ini IAXIS-4082 -- ECP -- 29/08/2019
                           IF v_trespue_2912 IS NOT NULL
                           THEN
                              SELECT sperson
                                INTO vsperson
                                FROM per_personas
                               WHERE nnumide = v_trespue_2912;

                              
                              vconsulta :=
                                 REPLACE (vconsulta,
                                          ':PMT_ASEGURADOPER',
                                          vsperson
                                         );
                           ELSE
                              vconsulta :=
                                 REPLACE (vconsulta,
                                          ':PMT_ASEGURADOPER',
                                          'sperson'
                                         );
                           END IF;

                          
                       
                          --Fin IAXIS-4082 -- ECP -- 29/08/2019
                        END LOOP;
                     END IF;
                  ELSE
                     
                     vconsulta :=
                          REPLACE (vconsulta, ':PMT_ASEGURADOPER', 'sperson');
               
                  END IF;
               END IF;

               -- Fin IAXIS-4082 -- ECP -- 03/09/2019
               vpasexec := 14;
               cur := pac_md_listvalores.f_opencursor (vconsulta, mensajes);
               vpasexec := 15;

               FETCH cur
                INTO w_cprofes, w_tprofes;

               vpasexec := 16;

               WHILE cur%FOUND
               LOOP
                  IF resp IS NULL
                  THEN
                     vpasexec := 17;
                     resp := t_iaxpar_respuestas ();

                     IF prg.ctippre = 6
                     THEN
                        preg (preg.LAST).crestip := 1;
                                    -- 1 respuesta desplegable; 0 texto libre
                     END IF;
                  END IF;

                  vpasexec := 18;
                  resp.EXTEND;
                  resp (resp.LAST) := ob_iaxpar_respuestas ();
                  resp (resp.LAST).cpregun := prg.cpregun;
                  resp (resp.LAST).crespue := w_cprofes;
                  resp (resp.LAST).trespue := SUBSTR (w_tprofes, 1, 40);
                  vpasexec := 19;

                  IF prg.ctippre = 8
                  THEN
                     preg (preg.LAST).cresdef := w_cprofes;
                  END IF;

                  FETCH cur
                   INTO w_cprofes, w_tprofes;

                  vpasexec := 20;
               END LOOP;

               -- BUG -21546_108724- 02/02/2012 - JLTS- Cierre de cursores
               IF cur%ISOPEN
               THEN
                  CLOSE cur;
               END IF;

               vpasexec := 21;
               preg (preg.LAST).respuestas := resp;
            ELSE
               -- Fin BUG 10470 - 01/07/2009 -JJG - Tratar preguntas tipo 6 - Tabla.
               vpasexec := 22;

               FOR rsp IN c_resppro (prg.cpregun)
               LOOP
                  vpasexec := 23;

                  IF resp IS NULL
                  THEN
                     vpasexec := 24;
                     resp := t_iaxpar_respuestas ();
                     preg (preg.LAST).crestip := 1;
                          -- 1 la respuesta es desplegable - 0 es texto libre
                  END IF;

                  vpasexec := 25;
                  resp.EXTEND;
                  resp (resp.LAST) := ob_iaxpar_respuestas ();
                  resp (resp.LAST).cpregun := prg.cpregun;
                  resp (resp.LAST).crespue := rsp.crespue;
                  resp (resp.LAST).trespue := rsp.trespue;
                  vpasexec := 26;
               END LOOP;

               vpasexec := 27;
               preg (preg.LAST).respuestas := resp;
            END IF;                             -- BUG 10470 - 01/07/2009 -JJG
         END IF;
      END LOOP;

      vpasexec := 28;
      RETURN (preg);
   --
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         -- BUG -21546_108724- 02/02/2012 - JLTS- Cierre de cursores
         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_get_pregpoliza;

   /***********************************************************************
      Recupera los datos del riesgo (preguntas)
      param in psproduc  : codigo del producto
      param in pcactivi  : codigo de actividad
      param in psimul    : indicador de simulacion
      param out mensajes : mensajes de error
      return             : objeto preguntas
   ***********************************************************************/
   FUNCTION f_get_datosriesgos (
      psproduc   IN       NUMBER,
      pcactivi   IN       NUMBER,
      psimul     IN       BOOLEAN,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN t_iaxpar_preguntas
   IS
      preg          t_iaxpar_preguntas;
      resp          t_iaxpar_respuestas;
      vpasexec      NUMBER (8)          := 1;
      vparam        VARCHAR2 (500)
                      := 'psproduc=' || psproduc || ', pcactivi=' || pcactivi;
      vobject       VARCHAR2 (200)
                                  := 'PAC_MDPAR_PRODUCTOS.F_Get_DatosRiesgos';
      -- BUG 10470 - 01/07/2009 - NMM - Tratar preguntas tipo 6 - Tabla.i.
      vconsulta     VARCHAR2 (4000);
      cur           sys_refcursor;
      w_cprofes     VARCHAR2 (200);
      w_tprofes     VARCHAR2 (500);
      -- BUG 10470.f.
      -- Bug 16106 - RSC - 11/10/2010 - APR - Ajustes e implementacion para el alta de colectivos
      v_isaltacol   NUMBER;

      -- Fin Bug 16106

      -- BUG 6296 - 16/03/2009 - SBG - Afegim nou camp ctipgru al cursor
      CURSOR c_pregactivi (pisaltacol IN NUMBER, pissuplemento IN NUMBER)
      IS
         SELECT   preact.cpregun, preng.tpregun, preact.cpretip,
                  preact.npreord, preact.tprefor, preact.cpreobl,
                  preact.cresdef, preact.cofersn, preact.tvalfor,
                  NULL ctabla, NULL cmodo, cpreg.ctippre, cpreg.ctipgru,
                  cpreg.tconsulta, NULL cvisible, NULL esccero, NULL crecarg,
                  NULL ccalcular, NULL tmodalidad
             FROM pregunproactivi preact, preguntas preng, codipregun cpreg
            WHERE preact.cpregun = preng.cpregun
              AND preng.cidioma = pac_md_common.f_get_cxtidioma
              AND preact.cactivi = pcactivi
              AND          --//acc DE MOMENT PER DEFECTE ES LA ACTIVITAT 0 acc
                  preact.cpretip <> 2
              AND cpreg.cpregun = preact.cpregun
              AND preact.sproduc = psproduc
         UNION ALL
         SELECT   prepro.cpregun, preng.tpregun, prepro.cpretip,
                  prepro.npreord, prepro.tprefor, prepro.cpreobl,
                  prepro.cresdef, prepro.cofersn, prepro.tvalfor,
                  prepro.ctabla, prepro.cmodo, cpreg.ctippre, cpreg.ctipgru,
                  cpreg.tconsulta, prepro.cvisible cvisible,
                  prepro.esccero esccero,                   -- Bug 19504   JBN
                                         prepro.crecarg, prepro.ccalcular,
                  prepro.tmodalidad
             FROM pregunpro prepro, preguntas preng, codipregun cpreg
            WHERE prepro.cpregun = preng.cpregun
              AND preng.cidioma = pac_md_common.f_get_cxtidioma
              AND prepro.cnivel = 'R'
              AND (   (pissuplemento = 1 AND prepro.cmodo IN ('T', 'S'))
                   OR ((pissuplemento = 0) AND prepro.cmodo IN ('T', 'N'))
                  )
              AND (   prepro.cpretip <> 2
                   OR (    prepro.cpretip = 2
                       AND prepro.esccero = 1
                       AND pisaltacol = 1
                      )
-- Bug 16106 - RSC - 21/09/2010 - APR - Ajustes e implementacion para el alta de colectivos
                   OR (prepro.cvisible = 2)                 -- Bug 19504   JBN
                   OR (prepro.cpretip = 2 AND ccalcular = 1)
                  )
              AND (   (prepro.visiblecol = 1 AND pisaltacol = 1)
                   OR (pisaltacol = 0 AND prepro.visiblecert = 1)
                   OR (prepro.cpretip = 2 AND ccalcular = 1)
                  )        -- Bug 17362 - APD - 01/02/2011 - Ajustes GROUPLIFE
              AND cpreg.cpregun = prepro.cpregun
              AND prepro.sproduc = psproduc
              --JRH CONVENIOS
              AND (   (prepro.ctipconv IS NULL)
                   OR (    prepro.ctipconv IS NOT NULL
                       AND prepro.ctipconv =
                              NVL
                                 (pac_iax_produccion.poliza.det_poliza.convempvers.cvida,
                                  -1
                                 )
                      )
                  )
         --JRH CONVENIOS
         ORDER BY npreord;

      CURSOR c_resppro (cprg NUMBER)
      IS
         SELECT   crespue, trespue
             FROM respuestas rsp
            WHERE rsp.cpregun = cprg
              AND rsp.cidioma = pac_md_common.f_get_cxtidioma
         ORDER BY rsp.crespue;

      v_issuplem    NUMBER              := 0;
   BEGIN
      --Inicialitzacions
      IF psproduc IS NULL OR pcactivi IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      -- Bug 16106 - RSC - 11/10/2010 - APR - Ajustes e implementacion para el alta de colectivos
      IF pac_iax_produccion.isaltacol
      THEN
         v_isaltacol := 1;
      ELSE
         v_isaltacol := 0;
      END IF;

      IF pac_iax_produccion.issuplem = TRUE
      THEN
         v_issuplem := 1;
      ELSE
         v_issuplem := 0;
      END IF;

      FOR prg IN c_pregactivi (v_isaltacol, v_issuplem)
      LOOP
         IF preg IS NULL
         THEN
            preg := t_iaxpar_preguntas ();
         END IF;

         -- Bug 11432.13/10/2009.NMM.i.: CEM - Preguntas solo aparecen en simulaciones.
         IF    (psimul = FALSE AND prg.cofersn <> 2)
            OR (psimul = TRUE AND prg.cofersn IN (1, 2))
         THEN
            /*IF psimul = FALSE
               OR(psimul = TRUE
                  AND prg.cofersn <> 0) THEN   --BUG9427-30032009-XVM*/
            preg.EXTEND;
            preg (preg.LAST) := ob_iaxpar_preguntas ();
            preg (preg.LAST).cpregun := prg.cpregun;
            preg (preg.LAST).tpregun := prg.tpregun;
            -- Bug 22839 - RSC - 17/07/2012 - LCOL - Funcionalidad Certificado 0
            preg (preg.LAST).esccero := prg.esccero;

            IF prg.cpretip = 2 AND prg.esccero = 1 AND v_isaltacol = 1
            THEN
               preg (preg.LAST).cpretip := 1;
            ELSE
               preg (preg.LAST).cpretip := prg.cpretip;
            END IF;

            -- Bug 22839 - RSC - 19/11/2012 - LCOL_T010-LCOL - Funcionalidad Certificado 0
            IF prg.cpretip = 3 AND prg.esccero = 1 AND v_isaltacol = 0
            THEN
               preg (preg.LAST).isaltac := 1;
            END IF;

            -- Fin bug 22839

            -- Fin Bug 22839
            preg (preg.LAST).npreord := prg.npreord;
            preg (preg.LAST).tprefor := prg.tprefor;
            preg (preg.LAST).cpreobl := prg.cpreobl;
            preg (preg.LAST).cresdef := prg.cresdef;
            preg (preg.LAST).cofersn := prg.cofersn;
            preg (preg.LAST).tvalfor := prg.tvalfor;
            preg (preg.LAST).ctabla := prg.ctabla;
            preg (preg.LAST).cmodo := prg.cmodo;
            preg (preg.LAST).cvisible := NVL (prg.cvisible, 0);        --19504
            preg (preg.LAST).crecarg := prg.crecarg;
            preg (preg.LAST).ccalcular := prg.ccalcular;
            preg (preg.LAST).tmodalidad := prg.tmodalidad;

            IF prg.ctippre IN (4, 5)
            THEN                             -- tipo pregunta VF 78 detvalores
               preg (preg.LAST).crestip := 0;             -- 0 es texto libre
            ELSIF prg.ctippre = 3
            THEN                                        -- tipo pregunta VF 78
               preg (preg.LAST).crestip := 2;
             -- 2 indentifica que la resposta es texte pero es guarda crespue
            ELSIF prg.ctippre = 7
            THEN                                        -- tipo pregunta VF 78
               vpasexec := 9;
               preg (preg.LAST).crestip := 3;
             -- 2 indentifica que la resposta es texte pero es guarda crespue
            ELSE
               preg (preg.LAST).crestip := 1;
                                             -- 1 la respuesta es desplegable
            END IF;

            preg (preg.LAST).ctippre := prg.ctippre;  -- tipo pregunta (VF 78)
            -- BUG 6296 - 16/03/2009 - SBG - Informem nou camp ctipgru
            preg (preg.LAST).ctipgru := prg.ctipgru;
                                              -- tipo grupo preguntas (VF 309)
            resp := NULL;

            -- BUG 10470 - 01/07/2009 -JJG/NMM - Tratar preguntas tipo 6 - Tabla.
            IF prg.ctippre = 6
            THEN
               vpasexec := 13;
               vconsulta :=
                  REPLACE (prg.tconsulta,
                           ':PMT_IDIOMA',
                           pac_md_common.f_get_cxtidioma
                          );
               -- Bug 22839 - RSC - 17/07/2012 - LCOL - Funcionalidad Certificado 0
               vconsulta :=
                  REPLACE (vconsulta,
                           ':PMT_NPOLIZA',
                           pac_iax_produccion.poliza.det_poliza.npoliza
                          );
               vconsulta :=
                  REPLACE (vconsulta,
                           ':PMT_SSEGURO',
                           pac_iax_produccion.poliza.det_poliza.sseguro
                          );
               -- Fin Bug 22839
               vconsulta := REPLACE (vconsulta, ':PMT_CACTIVI', pcactivi);
                                                 -- IAXIS-4203 CJMR 2019/07/10

               -- Bug 19096 - RSC - 25/07/2011 - LCOL - Parametrizacion basica producto Vida Individual Pagos Permanentes
               IF INSTR (UPPER (vconsulta), 'PROFESIONPROD') > 0
               THEN
                  -- Fin Bug 19096

                  -- INI Bug 0012227 - 03/12/2009 - JMF
                  DECLARE
                     CURSOR c1
                     IS
                        SELECT 1
                          FROM profesionprod a, productos b
                         WHERE a.cramo = b.cramo
                           AND a.cmodali = b.cmodali
                           AND a.ctipseg = b.ctipseg
                           AND a.ccolect = b.ccolect
                           AND b.sproduc = psproduc
                           AND a.cactivi = pcactivi;

                     w_aux   NUMBER (1);
                  BEGIN
                     OPEN c1;

                     FETCH c1
                      INTO w_aux;

                     IF c1%FOUND
                     THEN
                        vconsulta :=
                           REPLACE (vconsulta,
                                    ':PMT_SPRODUC',
                                    psproduc || ' and cactivi=' || pcactivi
                                   );
                     ELSE
                        vconsulta :=
                           REPLACE (vconsulta,
                                    ':PMT_SPRODUC',
                                    psproduc || ' and cactivi=0'
                                   );
                     END IF;

                     CLOSE c1;
                  -- BUG -21546_108724- 02/02/2012 - JLTS- Cierre de cursores
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        IF c1%ISOPEN
                        THEN
                           CLOSE c1;
                        END IF;
                  END;
               -- Bug 19096 - RSC - 25/07/2011 - LCOL - Parametrizacion basica producto Vida Individual Pagos Permanentes
               ELSE
                  vconsulta :=
                         REPLACE (vconsulta, ':PMT_SPRODUC', psproduc || ' ');
               END IF;

               -- Fin Bug 19096

               -- FIN Bug 0012227 - 03/12/2009 - JMF
               vpasexec := 14;
               cur := pac_md_listvalores.f_opencursor (vconsulta, mensajes);
               vpasexec := 15;

               FETCH cur
                INTO w_cprofes, w_tprofes;

               vpasexec := 16;

               WHILE cur%FOUND
               LOOP
                  IF resp IS NULL
                  THEN
                     vpasexec := 17;
                     resp := t_iaxpar_respuestas ();
                     preg (preg.LAST).crestip := 1;
                                    -- 1 respuesta desplegable; 0 texto libre
                  END IF;

                  vpasexec := 18;
                  resp.EXTEND;
                  resp (resp.LAST) := ob_iaxpar_respuestas ();
                  resp (resp.LAST).cpregun := prg.cpregun;
                  resp (resp.LAST).crespue := w_cprofes;
                  resp (resp.LAST).trespue := SUBSTR (w_tprofes, 1, 100);
                  vpasexec := 19;

                  FETCH cur
                   INTO w_cprofes, w_tprofes;

                  vpasexec := 20;
               END LOOP;

               -- BUG -21546_108724- 02/02/2012 - JLTS- Cierre de cursores
               IF cur%ISOPEN
               THEN
                  CLOSE cur;
               END IF;

               vpasexec := 21;
               preg (preg.LAST).respuestas := resp;
            ELSE
               -- Fin BUG 10470 - 01/07/2009 -NMM - Tratar preguntas tipo 6 - Tabla.
               FOR rsp IN c_resppro (prg.cpregun)
               LOOP
                  IF resp IS NULL
                  THEN
                     resp := t_iaxpar_respuestas ();
                     preg (preg.LAST).crestip := 1;
                          -- 1 la respuesta es desplegable - 0 es texto libre
                  END IF;

                  resp.EXTEND;
                  resp (resp.LAST) := ob_iaxpar_respuestas ();
                  resp (resp.LAST).cpregun := prg.cpregun;
                  resp (resp.LAST).crespue := rsp.crespue;
                  resp (resp.LAST).trespue := rsp.trespue;
               END LOOP;

               preg (preg.LAST).respuestas := resp;
            END IF;
         -- Fin BUG 10470 - 01/07/2009 -NMM - Tratar preguntas tipo 6 - Tabla.
         END IF;
      END LOOP;

      RETURN (preg);
   --
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         -- BUG -21546_108724- 02/02/2012 - JLTS- Cierre de cursores
         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_get_datosriesgos;

      /***********************************************************************
      Recupera las preguntas a nivel de garantia
      param in psproduc  : codigo del producto
      param in pcactivi  : codigo de actividad
      param in pcgarant  : codigo de garantia
      param out mensajes : mensajes de error
      return             : objeto preguntas
   ***********************************************************************/
   FUNCTION f_get_preggarant (
      psproduc   IN       NUMBER,
      pcactivi   IN       NUMBER,
      pcgarant   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN t_iaxpar_preguntas
   IS
      preg          t_iaxpar_preguntas;
      resp          t_iaxpar_respuestas;
      vpasexec      NUMBER (8)          := 1;
      vparam        VARCHAR2 (500)
         :=    'psproduc='
            || psproduc
            || ', pcactivi='
            || pcactivi
            || ', pcgarant='
            || pcgarant;
      vobject       VARCHAR2 (200)   := 'PAC_MDPAR_PRODUCTOS.F_Get_PregGarant';
      -- BUG 10470 - 01/07/2009 - NMM - Tratar preguntas tipo 6 - Tabla.i.
      vconsulta     VARCHAR2 (4000);
      cur           sys_refcursor;
      w_cprofes     VARCHAR2 (200);
      w_tprofes     VARCHAR2 (500);
      v_dummy       NUMBER;

      -- BUG 10470.f.
      CURSOR c_preggar (
         ppcgarant       IN   NUMBER,
         pisaltacol      IN   NUMBER,
         pissuplemento   IN   NUMBER
      )
      IS
         -- Bug 9699 - APD - 08/04/2009 - primero se ha de buscar para la actividad en concreto
         -- y si no se encuentra nada ir a buscar a PREGUNPROGARAN para la actividad cero
         SELECT   pregar.cpregun, preng.tpregun, pregar.cpretip,
                  pregar.npreord, pregar.tprefor, pregar.cpreobl,
                  pregar.cresdef, pregar.cofersn, pregar.ctabla,
                  pregar.tvalfor, cpreg.ctippre, cpreg.tconsulta -- BUG 10470.
                                                                ,
                  pregar.cvisible, cpreg.ctipgru,
                  pregar.esccero esccero                               --19504
             FROM pregunprogaran pregar, preguntas preng, codipregun cpreg
            WHERE pregar.cpregun = preng.cpregun
              AND preng.cidioma = pac_md_common.f_get_cxtidioma
              AND pregar.sproduc = psproduc
              AND pregar.cactivi = pcactivi
              AND (   pregar.cpretip <> 2
                   OR (    pregar.cpretip = 2
                       AND pregar.esccero = 1
                       AND pisaltacol = 1
                      )
-- Bug 16106 - RSC - 21/09/2010 - APR - Ajustes e implementacion para el alta de colectivos
                   OR (pregar.cvisible = 2)
                  )                                         -- Bug 19504   JBN
              AND (   (pregar.visiblecol = 1 AND pisaltacol = 1)
                   OR (pisaltacol = 0 AND pregar.visiblecert = 1)
                  )        -- Bug 17362 - APD - 01/02/2011 - Ajustes GROUPLIFE
              AND cpreg.cpregun = pregar.cpregun
              AND pregar.cgarant = ppcgarant
              AND (   (pissuplemento = 1 AND pregar.cmodo IN ('T', 'S'))
                   OR ((pissuplemento = 0) AND pregar.cmodo IN ('T', 'N'))
                  )
         UNION
         SELECT   pregar.cpregun, preng.tpregun, pregar.cpretip,
                  pregar.npreord, pregar.tprefor, pregar.cpreobl,
                  pregar.cresdef, pregar.cofersn, pregar.ctabla,
                  pregar.tvalfor, cpreg.ctippre, cpreg.tconsulta -- BUG 10470.
                                                                ,
                  pregar.cvisible, cpreg.ctipgru,
                  pregar.esccero esccero                               --19504
             FROM pregunprogaran pregar, preguntas preng, codipregun cpreg
            WHERE pregar.cpregun = preng.cpregun
              AND preng.cidioma = pac_md_common.f_get_cxtidioma
              AND pregar.sproduc = psproduc
              AND pregar.cactivi = 0
              AND (   (pissuplemento = 1 AND pregar.cmodo IN ('T', 'S'))
                   OR ((pissuplemento = 0) AND pregar.cmodo IN ('T', 'N'))
                  )
              AND (   pregar.cpretip <> 2
                   OR (    pregar.cpretip = 2
                       AND pregar.esccero = 1
                       AND pisaltacol = 1
                      )
-- Bug 16106 - RSC - 21/09/2010 - APR - Ajustes e implementacion para el alta de colectivos
                   OR (pregar.cvisible = 2)
                  )                                         -- Bug 19504   JBN
              AND (   (pregar.visiblecol = 1 AND pisaltacol = 1)
                   OR (pisaltacol = 0 AND pregar.visiblecert = 1)
                  )        -- Bug 17362 - APD - 01/02/2011 - Ajustes GROUPLIFE
              AND cpreg.cpregun = pregar.cpregun
              AND pregar.cgarant = ppcgarant
              AND NOT EXISTS (
                     SELECT pregar.cpregun, preng.tpregun, pregar.cpretip,
                            pregar.npreord, pregar.tprefor, pregar.cpreobl,
                            pregar.cresdef, pregar.cofersn, pregar.ctabla,
                            pregar.tvalfor, cpreg.ctippre
                       FROM pregunprogaran pregar,
                            preguntas preng,
                            codipregun cpreg
                      WHERE pregar.cpregun = preng.cpregun
                        AND preng.cidioma = pac_md_common.f_get_cxtidioma
                        AND pregar.sproduc = psproduc
                        AND pregar.cactivi = pcactivi
                        AND (   (    pissuplemento = 1
                                 AND pregar.cmodo IN ('T', 'S')
                                )
                             OR (    (pissuplemento = 0)
                                 AND pregar.cmodo IN ('T', 'N')
                                )
                            )
                        AND (   pregar.cpretip <> 2
                             OR (    pregar.cpretip = 2
                                 AND pregar.esccero = 1
                                 AND pisaltacol = 1
                                )
-- Bug 16106 - RSC - 21/09/2010 - APR - Ajustes e implementacion para el alta de colectivos
                             OR (pregar.cvisible = 2)
                            )                               -- Bug 19504   JBN
                        AND (   (pregar.visiblecol = 1 AND pisaltacol = 1)
                             OR (pisaltacol = 0 AND pregar.visiblecert = 1)
                            )
                           -- Bug 17362 - APD - 01/02/2011 - Ajustes GROUPLIFE
                        AND cpreg.cpregun = pregar.cpregun
                        AND pregar.cgarant = ppcgarant)
         ORDER BY 4;                                         --pregar.npreord;

      -- BUG 9496 - 03/04/2009 - SBG - S'afegeix el ORDER BY
      -- Bug 9699 - APD - 08/04/2009 - Fin
      CURSOR c_resppro (cprg NUMBER)
      IS
         SELECT   crespue, trespue
             FROM respuestas rsp
            WHERE rsp.cpregun = cprg
              AND rsp.cidioma = pac_md_common.f_get_cxtidioma
         ORDER BY rsp.crespue;

      -- FINAL BUG 9496 - 03/04/2009 - SBG

      -- Bug 16106 - RSC - 11/10/2010 - APR - Ajustes e implementacion para el alta de colectivos
      v_isaltacol   NUMBER;
      -- Fin Bug 16106
      v_issuplem    NUMBER              := 0;
   BEGIN
      --Inicialitzacions
      IF psproduc IS NULL OR pcactivi IS NULL OR pcgarant IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      -- Bug 16106 - RSC - 11/10/2010 - APR - Ajustes e implementacion para el alta de colectivos
      IF pac_iax_produccion.isaltacol
      THEN
         v_isaltacol := 1;
      ELSE
         v_isaltacol := 0;
      END IF;

      IF pac_iax_produccion.issuplem = TRUE
      THEN
         v_issuplem := 1;
      ELSE
         v_issuplem := 0;
      END IF;

      -- Fin Bug 16106
      FOR prg IN c_preggar (pcgarant, v_isaltacol, v_issuplem)
      LOOP
         IF preg IS NULL
         THEN
            preg := t_iaxpar_preguntas ();
         END IF;

         -- Bug 0027744 - dlF - Producto de Explotaciones 2014 - Tratamiento preguntas garantoas en modo SIMULACION
         IF    (NOT pac_iax_produccion.issimul AND prg.cofersn <> 2)
            OR (pac_iax_produccion.issimul AND prg.cofersn IN (1, 2))
         THEN
            --fin BUG 0027744 - dlF -
            preg.EXTEND;
            preg (preg.LAST) := ob_iaxpar_preguntas ();
            preg (preg.LAST).cpregun := prg.cpregun;
            preg (preg.LAST).tpregun := prg.tpregun;
            -- Bug 22839 - RSC - 17/07/2012 - LCOL - Funcionalidad Certificado 0
            preg (preg.LAST).esccero := prg.esccero;

            IF prg.cpretip = 2 AND prg.esccero = 1 AND v_isaltacol = 1
            THEN
               preg (preg.LAST).cpretip := 1;
            ELSE
               preg (preg.LAST).cpretip := prg.cpretip;
            END IF;

            -- Bug 22839 - RSC - 19/11/2012 - LCOL_T010-LCOL - Funcionalidad Certificado 0
            IF prg.cpretip = 3 AND prg.esccero = 1 AND v_isaltacol = 0
            THEN
               preg (preg.LAST).isaltac := 1;
            END IF;

            -- Fin Bug 22839

            -- Fin bug 22839
            preg (preg.LAST).npreord := prg.npreord;
            preg (preg.LAST).tprefor := prg.tprefor;
            preg (preg.LAST).cpreobl := prg.cpreobl;
            preg (preg.LAST).cresdef := prg.cresdef;
            preg (preg.LAST).cofersn := prg.cofersn;
            preg (preg.LAST).ctabla := prg.ctabla;
            preg (preg.LAST).tvalfor := prg.tvalfor;
            preg (preg.LAST).cvisible := NVL (prg.cvisible, 0);        --19504
            preg (preg.LAST).ctipgru := prg.ctipgru;

            IF prg.ctippre IN (4, 5)
            THEN                             -- tipo pregunta VF 78 detvalores
               preg (preg.LAST).crestip := 0;             -- 0 es texto libre
            ELSIF prg.ctippre = 3
            THEN                                        -- tipo pregunta VF 78
               preg (preg.LAST).crestip := 2;
             -- 2 indentifica que la resposta es texte pero es guarda crespue
            ELSIF prg.ctippre = 7
            THEN                                        -- tipo pregunta VF 78
               vpasexec := 9;
               preg (preg.LAST).crestip := 3;
             -- 2 indentifica que la resposta es texte pero es guarda crespue
            ELSE
               preg (preg.LAST).crestip := 1;
                                             -- 1 la respuesta es desplegable
            END IF;

            preg (preg.LAST).ctippre := prg.ctippre;    -- tipo pregunta VF 78
            resp := NULL;

            -- BUG 10470 - 01/07/2009 -JJG/NMM - Tratar preguntas tipo 6 - Tabla.
            IF prg.ctippre = 6
            THEN
               vpasexec := 13;
               vconsulta :=
                  REPLACE (prg.tconsulta,
                           ':PMT_IDIOMA',
                           pac_md_common.f_get_cxtidioma
                          );
               -- Bug 22839 - RSC - 17/07/2012 - LCOL - Funcionalidad Certificado 0
               vconsulta :=
                  REPLACE (vconsulta,
                           ':PMT_NPOLIZA',
                           pac_iax_produccion.poliza.det_poliza.npoliza
                          );
               vconsulta :=
                  REPLACE (vconsulta,
                           ':PMT_SSEGURO',
                           pac_iax_produccion.poliza.det_poliza.sseguro
                          );
               -- Fin Bug 22839

               -- BUG 0036730 - FAL - 07/01/2016
               vconsulta := REPLACE (vconsulta, ':PMT_CACTIVI', pcactivi);
               vconsulta := REPLACE (vconsulta, ':PMT_SPRODUC', psproduc);

               -- FI BUG 0036730

               -- Bug 27768/156909 - JSV - 25/10/2013
               DECLARE
                  CURSOR c1
                  IS
                     SELECT 1
                       FROM profesionprod a, productos b
                      WHERE a.cramo = b.cramo
                        AND a.cmodali = b.cmodali
                        AND a.ctipseg = b.ctipseg
                        AND a.ccolect = b.ccolect
                        AND b.sproduc = psproduc
                        AND a.cactivi = pcactivi
                        AND a.cgarant = pcgarant;

                  w_aux   NUMBER (1);
               BEGIN
                  BEGIN
                     SELECT 1
                       INTO v_dummy
                       FROM profesionprod a, productos b
                      WHERE a.cramo = b.cramo
                        AND a.cmodali = b.cmodali
                        AND a.ctipseg = b.ctipseg
                        AND a.ccolect = b.ccolect
                        AND b.sproduc = psproduc
                        AND a.cactivi = pcactivi
                        AND a.cgarant = pcgarant
                        AND ROWNUM = 1;

                     BEGIN
                        OPEN c1;

                        FETCH c1
                         INTO w_aux;

                        IF c1%FOUND
                        THEN
                           vconsulta :=
                              REPLACE (vconsulta,
                                       ':PMT_SPRODUC',
                                          psproduc
                                       || ' and cactivi='
                                       || pcactivi
                                       || ' and cgarant='
                                       || pcgarant
                                      );
                        ELSE
                           vconsulta :=
                              REPLACE (vconsulta,
                                       ':PMT_SPRODUC',
                                          psproduc
                                       || ' and cactivi=0'
                                       || ' and cgarant='
                                       || pcgarant
                                      );
                        END IF;

                        CLOSE c1;
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           IF c1%ISOPEN
                           THEN
                              CLOSE c1;
                           END IF;
                     END;
                  EXCEPTION
                     WHEN NO_DATA_FOUND
                     THEN
                        vconsulta :=
                           REPLACE (vconsulta,
                                    ':PMT_SPRODUC',
                                    psproduc || ' '
                                   );
                        vconsulta :=
                           REPLACE (vconsulta, ':PMT_CGARANT',
                                    pcgarant || ' ');
                  END;
               END;

               -- FIN Bug 0012227 - 03/12/2009 - JMF
               vpasexec := 14;
               cur := pac_md_listvalores.f_opencursor (vconsulta, mensajes);
               vpasexec := 15;

               FETCH cur
                INTO w_cprofes, w_tprofes;

               vpasexec := 16;

               WHILE cur%FOUND
               LOOP
                  IF resp IS NULL
                  THEN
                     vpasexec := 17;
                     resp := t_iaxpar_respuestas ();
                     preg (preg.LAST).crestip := 1;
                                    -- 1 respuesta desplegable; 0 texto libre
                  END IF;

                  vpasexec := 18;
                  resp.EXTEND;
                  resp (resp.LAST) := ob_iaxpar_respuestas ();
                  resp (resp.LAST).cpregun := prg.cpregun;
                  resp (resp.LAST).crespue := w_cprofes;
                  resp (resp.LAST).trespue := SUBSTR (w_tprofes, 1, 40);
                  vpasexec := 19;

                  FETCH cur
                   INTO w_cprofes, w_tprofes;

                  vpasexec := 20;
               END LOOP;

               -- BUG -21546_108724- 02/02/2012 - JLTS- Cierre de cursores
               IF cur%ISOPEN
               THEN
                  CLOSE cur;
               END IF;

               vpasexec := 21;
               preg (preg.LAST).respuestas := resp;
            ELSE
               -- Fin BUG 10470 - 01/07/2009 -JJG - Tratar preguntas tipo 6 - Tabla.
               vpasexec := 22;

               FOR rsp IN c_resppro (prg.cpregun)
               LOOP
                  vpasexec := 23;

                  IF resp IS NULL
                  THEN
                     vpasexec := 24;
                     resp := t_iaxpar_respuestas ();
                     preg (preg.LAST).crestip := 1;
                          -- 1 la respuesta es desplegable - 0 es texto libre
                  END IF;

                  vpasexec := 25;
                  resp.EXTEND;
                  resp (resp.LAST) := ob_iaxpar_respuestas ();
                  resp (resp.LAST).cpregun := prg.cpregun;
                  resp (resp.LAST).crespue := rsp.crespue;
                  resp (resp.LAST).trespue := rsp.trespue;
                  vpasexec := 26;
               END LOOP;

               vpasexec := 27;
               preg (preg.LAST).respuestas := resp;
            END IF;                             -- BUG 10470 - 01/07/2009 -JJG
         -- Bug 0027744 - dlF - Producto de Explotaciones 2014 - Tratamiento preguntas garantoas en modo SIMULACION
         END IF;
      --fin BUG 0027744 - dlF -
      END LOOP;

      vpasexec := 28;
      RETURN (preg);
   --
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         -- BUG -21546_108724- 02/02/2012 - JLTS- Cierre de cursores
         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_get_preggarant;

   /***********************************************************************
      Recupera el Tipo de pregunta (detvalores.cvalor = 78)
      param in  pcpregun : codigo de pregunta
      param out mensajes : mensajes de error
      return             : Tipo de pregunta (detvalores.cvalor = 78)
   ***********************************************************************/
   FUNCTION f_get_pregtippre (
      pcpregun   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (500) := 'pcpregun= ' || pcpregun;
      vobject    VARCHAR2 (200) := 'PAC_MDPAR_PRODUCTOS.F_Get_PregGarant';
      retval     NUMBER;
      vnumerr    NUMBER (8)     := 0;
   BEGIN
      --Comprovacio de parametres d'entrada
      IF pcpregun IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_productos.f_get_pregtippre (pcpregun, retval);

      IF vnumerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN retval;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_get_pregtippre;

   /***********************************************************************
      Recupera si la pregunta es automatica/manual (detvalores.cvalor = 787)
      param in  pcpregun : codigo de pregunta
      param in  psproduc : codigo del producto
      param in  tipo     : indica si son preguntas POL RIE GAR
      param in  pcactivi : codigo actividad
      param in  pcgarant : codigo garantia
      param out mensajes : mensajes de error
      return             : Tipo de pregunta (detvalores.cvalor = 787)
   ***********************************************************************/
   FUNCTION f_get_pregunautomatica (
      pcpregun   IN       NUMBER,
      psproduc   IN       NUMBER,
      tipo       IN       VARCHAR2,
      pcactivi   IN       NUMBER,
      pcgarant   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (1500)
         :=    'cpregun= '
            || pcpregun
            || ' psproduc= '
            || psproduc
            || ' tipo= '
            || tipo
            || ' pcactivi= '
            || pcactivi
            || ' pcgarant= '
            || pcgarant;
      vobject    VARCHAR2 (200)
                               := 'PAC_MDPAR_PRODUCTOS.F_Get_PregunAutomatica';
      retval     NUMBER;
      vnumerr    NUMBER (8)      := 0;
   BEGIN
      --Comprovacio de parametres d'entrada
      IF tipo IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      IF tipo = 'POL'
      THEN
         IF psproduc IS NULL OR pcpregun IS NULL
         THEN
            RAISE e_param_error;
         END IF;

         vnumerr := pac_productos.f_get_pregunpol (psproduc, pcpregun, retval);
      ELSIF tipo = 'RIE'
      THEN
         IF psproduc IS NULL OR pcpregun IS NULL OR pcactivi IS NULL
         THEN
            RAISE e_param_error;
         END IF;

         vnumerr :=
            pac_productos.f_get_pregunrie (psproduc,
                                           pcpregun,
                                           pcactivi,
                                           retval
                                          );
      ELSIF tipo = 'GAR'
      THEN
         IF    psproduc IS NULL
            OR pcpregun IS NULL
            OR pcactivi IS NULL
            OR pcgarant IS NULL
         THEN
            RAISE e_param_error;
         END IF;

         vnumerr :=
            pac_productos.f_get_pregungar (psproduc,
                                           pcpregun,
                                           pcactivi,
                                           pcgarant,
                                           retval
                                          );
      END IF;

      IF vnumerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN retval;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 0;
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 0;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 0;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 0;
   END f_get_pregunautomatica;

   /***********************************************************************
      Recupera las clausulas del beneficiario
      param in psproduc  : codigo del producto
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_claubenefi (
      psproduc   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (500) := 'psproduc=' || psproduc;
      vobject    VARCHAR2 (200) := 'PAC_MDPAR_PRODUCTOS.F_Get_ClauBenefi';
   BEGIN
      --Inicialitzacions
      IF psproduc IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      cur :=
         pac_md_listvalores.f_opencursor
            (   'select bp.SCLABEN,ub.TCLABEN, decode(bp.SCLABEN, p.SCLABEN, 1, 0) ncladef '
             || ' from claubenpro bp, clausuben ub, productos p '
             || ' where bp.SCLABEN=ub.SCLABEN and '
             || ' ub.CIDIOMA='
             || pac_md_common.f_get_cxtidioma
             || ' and bp.SPRODUC='
             || psproduc
             || ' and p.sproduc = bp.SPRODUC'
             || ' order by bp.NORDEN',
             mensajes
            );
      RETURN cur;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_claubenefi;

   /***********************************************************************
      Devuelve la descripcion de una clausula de beneficiarios
      param in  psclaben  : codigo de la clausula
      param out mensajes : mensajes de error
      return             : descripcion garantia
   ***********************************************************************/
   FUNCTION f_get_descclausulaben (
      psclaben   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN VARCHAR2
   IS
      dclausu    VARCHAR2 (600);
      RESULT     VARCHAR2 (4000);
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (500)  := 'psclaben=' || psclaben;
      vobject    VARCHAR2 (200)
                               := 'PAC_MDPAR_PRODUCTOS.F_Get_DescClausulaBen';
   BEGIN
      --Inicialitzacions
      IF psclaben IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      RESULT :=
         pac_md_listvalores.f_getdescripvalor (   'SELECT TCLABEN '
                                               || ' FROM CLAUSUBEN  '
                                               || ' WHERE SCLABEN = '
                                               || psclaben
                                               || ' AND '
                                               || '      CIDIOMA = '
                                               || pac_md_common.f_get_cxtidioma,
                                               mensajes
                                              );
      dclausu := SUBSTR (RESULT, 1, 600);
      RETURN RESULT;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_get_descclausulaben;

/***********************************************************************
      Devuelve la descripcion de una clausula con parametros
      param in  sclaben  : codigo de la clausula
      param in  sseguro  : sseguro de la poliza
      param out mensajes : mensajes de error
      return             : descripcion garantia
   ***********************************************************************/
   FUNCTION f_get_descclausulapar (
      psclaben   IN       NUMBER,
      psseguro   IN       NUMBER,
      mensajes   OUT      t_iax_mensajes,
      ptablas    IN       VARCHAR2 DEFAULT 'POL'
   )
      RETURN VARCHAR2
   IS
      dclausu      CLOB;
      RESULT       CLOB;
      vpasexec     NUMBER (8)      := 1;
      vparam       CLOB            := 'psclaben=' || psclaben;
      vobject      CLOB        := 'PAC_MDPAR_PRODUCTOS.F_Get_descclausulapar';
      pcparams     NUMBER (10);
      vtclatex     CLOB;
      vtparame     CLOB;
      vcformat     NUMBER;
      vtit         CLOB;
      vtconsulta   VARCHAR2 (2000);
      w_cvalor     NUMBER;
      w_tvalor     VARCHAR2 (2000);
      v_cur        sys_refcursor;
      vsproduc     NUMBER;
      vnpoliza     NUMBER;
      vcagente     NUMBER;
   BEGIN
      --Inicialitzacions
      IF psclaben IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 22;

      IF ptablas = 'POL'
      THEN
         vpasexec := 23;

         SELECT COUNT (1)
           INTO pcparams
           FROM clauparaseg
          WHERE sseguro = psseguro
            AND sclagen = psclaben
            AND nriesgo = 0
            AND nmovimi = (SELECT MAX (nmovimi)
                             FROM clauparaseg
                            WHERE sseguro = psseguro);

         vpasexec := 24;

         IF pcparams = 0
         THEN
            vpasexec := 25;
            RESULT :=
               pac_md_listvalores.f_getdescripvalor
                                              (   'SELECT TCLATEX '
                                               || ' FROM CLAUSUGEN  '
                                               || ' WHERE SCLAGEN = '
                                               || psclaben
                                               || ' AND '
                                               || '      CIDIOMA = '
                                               || pac_md_common.f_get_cxtidioma,
                                               mensajes
                                              );
            vpasexec := 26;
            dclausu := SUBSTR (RESULT, 1, 600);
            vpasexec := 27;
         ELSE
            vpasexec := 28;

            SELECT tclatex
              INTO vtclatex
              FROM clausugen
             WHERE sclagen = psclaben
               AND cidioma = pac_md_common.f_get_cxtidioma;

            vpasexec := 29;

            -- vtclatex := vtit || ' -' || vtclatex;
            FOR cur IN (SELECT nparame, tparame
                          FROM clauparaseg
                         WHERE sseguro = psseguro
                           AND sclagen = psclaben
                           AND nriesgo = 0
                           AND nmovimi = (SELECT MAX (nmovimi)
                                            FROM clauparaseg
                                           WHERE sseguro = psseguro))
            LOOP
               vpasexec := 30;

               SELECT cformat
                 INTO vcformat
                 FROM clausupara
                WHERE sclagen = psclaben
                  AND nparame = cur.nparame
                  AND cidioma = pac_md_common.f_get_cxtidioma;

               vpasexec := 31;

               IF vcformat = 2
               THEN
                  vpasexec := 32;
                  --LPP se modific¿ el pac_iax_produccion para que guardara en clauparaseg.tparame la descripcion y no el codigo
                  /*IF cur.tparame IS NOT NULL THEN
                     vpasexec := 33;

                     SELECT tparame
                       INTO vtparame
                       FROM clausupara_valores
                      WHERE sclagen = psclaben
                        AND nparame = cur.nparame
                        AND cidioma = pac_md_common.f_get_cxtidioma
                        AND cparame = TO_NUMBER(cur.tparame);

                     vpasexec := 34;
                     vtclatex := REPLACE(vtclatex, '#' || cur.nparame || '#', vtparame);
                     vpasexec := 35;
                  ELSE*/
                  vpasexec := 36;
                  vtclatex :=
                     REPLACE (vtclatex,
                              '#' || cur.nparame || '#',
                              cur.tparame
                             );
                  vpasexec := 37;
                  --END IF;
                  vpasexec := 38;
               ELSIF vcformat = 8
               THEN
                  IF cur.tparame IS NOT NULL
                  THEN
                     vpasexec := 33;

                     SELECT tconsulta
                       INTO vtconsulta
                       FROM clausupara
                      WHERE sclagen = psclaben
                        AND cidioma = pac_md_common.f_get_cxtidioma
                        AND nparame = cur.nparame;

                     SELECT npoliza, sproduc, cagente
                       INTO vnpoliza, vsproduc, vcagente
                       FROM seguros
                      WHERE sseguro = psseguro;

                     vpasexec := 28;
                     vtconsulta :=
                        REPLACE (vtconsulta,
                                 ':PMT_IDIOMA',
                                 pac_md_common.f_get_cxtidioma
                                );
                     -- INI Bug 0012227 - 03/12/2009 - JMF
                     vtconsulta :=
                                REPLACE (vtconsulta, ':PMT_SPRODUC', vsproduc);
                     -- FIN Bug 0012227 - 03/12/2009 - JMF

                     -- Bug 22839 - RSC - 17/07/2012 - LCOL - Funcionalidad Certificado 0
                     vtconsulta :=
                                REPLACE (vtconsulta, ':PMT_NPOLIZA', vnpoliza);
                     vtconsulta :=
                                REPLACE (vtconsulta, ':PMT_SSEGURO', psseguro);
                     -- Fin Bug 22839
                     --JLV 23/04/2014 a¿adir el agente, es necesario para las campa¿as
                     vtconsulta :=
                                REPLACE (vtconsulta, ':PMT_CAGENTE', vcagente);
                     vpasexec := 29;
                     p_tab_error (f_sysdate,
                                  f_user,
                                  'PROBANDO',
                                  vpasexec,
                                     'cvalor: '
                                  || w_cvalor
                                  || ' tvalor:'
                                  || w_tvalor,
                                  vtconsulta
                                 );
                     v_cur :=
                        pac_md_listvalores.f_opencursor (vtconsulta, mensajes);
                     vpasexec := 30;

                     FETCH v_cur
                      INTO w_cvalor, w_tvalor;

                     vpasexec := 34;
                     vtclatex :=
                        REPLACE (vtclatex, '#' || cur.nparame || '#',
                                 w_tvalor);

                     IF v_cur%ISOPEN
                     THEN
                        CLOSE v_cur;
                     END IF;
                  ELSE
                     vpasexec := 36;
                     vtclatex :=
                        REPLACE (vtclatex,
                                 '#' || cur.nparame || '#',
                                 cur.tparame
                                );
                     vpasexec := 37;
                  END IF;
               ELSIF vcformat <> 2
               THEN
                  vpasexec := 39;
                  vtclatex :=
                     REPLACE (vtclatex,
                              '#' || cur.nparame || '#',
                              cur.tparame
                             );
                  vpasexec := 40;
               END IF;
            END LOOP;

            vpasexec := 41;
            vtclatex := REPLACE (vtclatex, CHR (39), CHR (39) || CHR (39));
            vpasexec := 42;
            RESULT :=
               pac_md_listvalores.f_getdescripvalor (   'SELECT '
                                                     || CHR (39)
                                                     || vtclatex
                                                     || CHR (39)
                                                     || ' TCLATEX FROM DUAL',
                                                     mensajes
                                                    );
            vpasexec := 43;
         END IF;
      ELSE
         vpasexec := 2;

         SELECT COUNT (1)
           INTO pcparams
           FROM estclauparaseg
          WHERE sseguro = psseguro
            AND sclagen = psclaben
            AND nriesgo = 0
            AND nmovimi = (SELECT MAX (nmovimi)
                             FROM estclauparaseg
                            WHERE sseguro = psseguro);

         vpasexec := 3;

         IF pcparams = 0
         THEN
            RESULT :=
               pac_md_listvalores.f_getdescripvalor
                                              (   'SELECT TCLATEX '
                                               || ' FROM CLAUSUGEN  '
                                               || ' WHERE SCLAGEN = '
                                               || psclaben
                                               || ' AND '
                                               || '      CIDIOMA = '
                                               || pac_md_common.f_get_cxtidioma,
                                               mensajes
                                              );
            dclausu := SUBSTR (RESULT, 1, 600);
            vpasexec := 4;
         ELSE
            vpasexec := 5;

            SELECT tclatit, tclatex
              INTO vtit, vtclatex
              FROM clausugen
             WHERE sclagen = psclaben
               AND cidioma = pac_md_common.f_get_cxtidioma;

            vpasexec := 6;
            vtclatex := vtit || ' -' || vtclatex;
            vpasexec := 7;

            FOR cur IN (SELECT nparame, tparame
                          FROM estclauparaseg
                         WHERE sseguro = psseguro
                           AND sclagen = psclaben
                           AND nriesgo = 0
                           AND nmovimi = (SELECT MAX (nmovimi)
                                            FROM estclauparaseg
                                           WHERE sseguro = psseguro))
            LOOP
               vpasexec := 8;

               SELECT cformat
                 INTO vcformat
                 FROM clausupara
                WHERE sclagen = psclaben
                  AND nparame = cur.nparame
                  AND cidioma = pac_md_common.f_get_cxtidioma;

               vpasexec := 9;

               IF vcformat = 2
               THEN
                  vpasexec := 10;
                  --LPP se modific¿ el pac_iax_produccion para que guardara en clauparaseg.tparame la descripcion y no el codigo
                  /*IF cur.tparame IS NOT NULL THEN
                     vpasexec := 11;

                     SELECT tparame
                       INTO vtparame
                       FROM clausupara_valores
                      WHERE sclagen = psclaben
                        AND nparame = cur.nparame
                        AND cidioma = pac_md_common.f_get_cxtidioma
                        AND cparame = TO_NUMBER(cur.tparame);

                     vpasexec := 12;
                     vtclatex := REPLACE(vtclatex, '#' || cur.nparame || '#', vtparame);
                  ELSE*/
                  vpasexec := 13;
                  vtclatex :=
                     REPLACE (vtclatex,
                              '#' || cur.nparame || '#',
                              cur.tparame
                             );
               --END IF;
               ELSIF vcformat = 8
               THEN
                  IF cur.tparame IS NOT NULL
                  THEN
                     vpasexec := 33;

                     SELECT tconsulta
                       INTO vtconsulta
                       FROM clausupara
                      WHERE sclagen = psclaben
                        AND cidioma = pac_md_common.f_get_cxtidioma
                        AND nparame = cur.nparame;

                     SELECT npoliza, sproduc, cagente
                       INTO vnpoliza, vsproduc, vcagente
                       FROM estseguros
                      WHERE sseguro = psseguro;

                     vpasexec := 28;
                     vtconsulta :=
                        REPLACE (vtconsulta,
                                 ':PMT_IDIOMA',
                                 pac_md_common.f_get_cxtidioma
                                );
                     -- INI Bug 0012227 - 03/12/2009 - JMF
                     vtconsulta :=
                                REPLACE (vtconsulta, ':PMT_SPRODUC', vsproduc);
                     -- FIN Bug 0012227 - 03/12/2009 - JMF

                     -- Bug 22839 - RSC - 17/07/2012 - LCOL - Funcionalidad Certificado 0
                     vtconsulta :=
                                REPLACE (vtconsulta, ':PMT_NPOLIZA', vnpoliza);
                     vtconsulta :=
                                REPLACE (vtconsulta, ':PMT_SSEGURO', psseguro);
                     -- Fin Bug 22839
                     --JLV 23/04/2014 a¿adir el agente, es necesario para las campa¿as
                     vtconsulta :=
                                REPLACE (vtconsulta, ':PMT_CAGENTE', vcagente);
                     vpasexec := 29;
                     p_tab_error (f_sysdate,
                                  f_user,
                                  'PROBANDO',
                                  vpasexec,
                                     'cvalor: '
                                  || w_cvalor
                                  || ' tvalor:'
                                  || w_tvalor,
                                  vtconsulta
                                 );
                     v_cur :=
                        pac_md_listvalores.f_opencursor (vtconsulta, mensajes);
                     vpasexec := 30;

                     FETCH v_cur
                      INTO w_cvalor, w_tvalor;

                     vpasexec := 34;
                     vtclatex :=
                        REPLACE (vtclatex, '#' || cur.nparame || '#',
                                 w_tvalor);

                     IF v_cur%ISOPEN
                     THEN
                        CLOSE v_cur;
                     END IF;
                  ELSE
                     vpasexec := 36;
                     vtclatex :=
                        REPLACE (vtclatex,
                                 '#' || cur.nparame || '#',
                                 cur.tparame
                                );
                     vpasexec := 37;
                  END IF;
               ELSIF vcformat <> 2
               THEN
                  vpasexec := 14;
                  vtclatex :=
                     REPLACE (vtclatex,
                              '#' || cur.nparame || '#',
                              cur.tparame
                             );
               END IF;

               vpasexec := 15;
            END LOOP;

            vpasexec := 16;
            vtclatex := REPLACE (vtclatex, CHR (39), CHR (39) || CHR (39));
            vpasexec := 17;
            RESULT :=
               pac_md_listvalores.f_getdescripvalor (   'SELECT '
                                                     || CHR (39)
                                                     || vtclatex
                                                     || CHR (39)
                                                     || ' TCLATEX FROM DUAL',
                                                     mensajes
                                                    );
            vpasexec := 18;
         END IF;
      END IF;

      vpasexec := 19;
      RETURN RESULT;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_get_descclausulapar;

-- BUG171999:JBN:19/01/2011 fi

   /***********************************************************************
      Devuelve la descripcion de una clausula con parametros
      param in  sclaben  : codigo de la clausula
      param in  sseguro  : sseguro de la poliza
      param out mensajes : mensajes de error
      return             : descripcion garantia
   ***********************************************************************/
   FUNCTION f_get_descclausulaparmult (
      psclaben   IN       NUMBER,
      pnordcla   IN       NUMBER,
      psseguro   IN       NUMBER,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN VARCHAR2
   IS
      dclausu    VARCHAR2 (600);
      RESULT     VARCHAR2 (4000);
      vpasexec   NUMBER (8)               := 1;
      vparam     VARCHAR2 (500)           := 'psclaben=' || psclaben;
      vobject    VARCHAR2 (200)
                           := 'PAC_MDPAR_PRODUCTOS.F_Get_descclausulaparmult';
      pcparams   NUMBER (1);
      -- Bug 0025583 - 04/02/2013 - JMF
      vtclatex   clausugen.tclatex%TYPE;
      vtparame   VARCHAR2 (2000);
      vcformat   NUMBER;
   BEGIN
      --Inicialitzacions
      IF psclaben IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      SELECT COUNT (1)
        INTO pcparams
        FROM clauparaseg
       WHERE sseguro = psseguro
         AND sclagen = psclaben
         AND nriesgo = 0
         AND nordcla = pnordcla
         AND nmovimi = (SELECT MAX (nmovimi)
                          FROM clauparaseg
                         WHERE sseguro = psseguro);

      IF pcparams = 0
      THEN
         RESULT :=
            pac_md_listvalores.f_getdescripvalor
                                              (   'SELECT TCLATEX '
                                               || ' FROM CLAUSUGEN  '
                                               || ' WHERE SCLAGEN = '
                                               || psclaben
                                               || ' AND '
                                               || '      CIDIOMA = '
                                               || pac_md_common.f_get_cxtidioma,
                                               mensajes
                                              );
         dclausu := SUBSTR (RESULT, 1, 600);
      ELSE
         SELECT tclatex
           INTO vtclatex
           FROM clausugen
          WHERE sclagen = psclaben AND cidioma = pac_md_common.f_get_cxtidioma;

         FOR cur IN (SELECT nparame, tparame
                       FROM clauparaseg
                      WHERE sseguro = psseguro
                        AND sclagen = psclaben
                        AND nriesgo = 0
                        AND nordcla = pnordcla
                        AND nmovimi = (SELECT MAX (nmovimi)
                                         FROM clauparaseg
                                        WHERE sseguro = psseguro))
         LOOP
            --  vtclatex := REPLACE(vtclatex, '#' || cur.nparame || '#', cur.tparame);
            SELECT cformat
              INTO vcformat
              FROM clausupara
             WHERE sclagen = psclaben
               AND nparame = cur.nparame
               AND cidioma = pac_md_common.f_get_cxtidioma;

            IF vcformat <> 2
            THEN
               vtclatex :=
                   REPLACE (vtclatex, '#' || cur.nparame || '#', cur.tparame);
            ELSIF vcformat = 2
            THEN
               --LPP se modific¿ el pac_iax_produccion para que guardara en clauparaseg.tparame la descripcion y no el codigo
               /*IF cur.tparame IS NOT NULL THEN
                  SELECT tparame
                    INTO vtparame
                    FROM clausupara_valores
                   WHERE sclagen = psclaben
                     AND nparame = cur.nparame
                     AND cidioma = pac_md_common.f_get_cxtidioma
                     AND cparame = TO_NUMBER(cur.tparame);

                  vtclatex := REPLACE(vtclatex, '#' || cur.nparame || '#', vtparame);
               ELSE*/
               vtclatex :=
                   REPLACE (vtclatex, '#' || cur.nparame || '#', cur.tparame);
            --END IF;
            END IF;
         END LOOP;

         vtclatex := REPLACE (vtclatex, CHR (39), CHR (39) || CHR (39));
         RESULT :=
            pac_md_listvalores.f_getdescripvalor (   'SELECT '
                                                  || CHR (39)
                                                  || vtclatex
                                                  || CHR (39)
                                                  || ' TCLATEX FROM DUAL',
                                                  mensajes
                                                 );
      END IF;

      RETURN RESULT;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_get_descclausulaparmult;

   /***********************************************************************
      Devuelve las clausulas
      param in cramo     : codigo ramo
      param in cmodali   : codigo modalidad
      param in ctipseg   : codigo tipo de seguro
      param in ccolect   : codigo de colectividad
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_clausulas (
      pcramo     IN       NUMBER,
      pcmodali   IN       NUMBER,
      pctipseg   IN       NUMBER,
      pccolect   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN t_iaxpar_clausulas
   IS
      --
      CURSOR cclau
      IS
         SELECT   c.*
             FROM clausupro c
            WHERE c.ccolect = pccolect
              AND c.cramo = pcramo
              AND c.ctipseg = pctipseg
              AND c.cmodali = pcmodali
              AND (c.multiple IS NULL OR c.multiple != 1)
         --and c.multiple != 1
         ORDER BY c.norden;

            --BUG0010092: APR - Clausulas por garantia y pregunta -INI
            -- Bug 18362 - APD - 23/05/2011 - Si que deben mostrarse las
            -- clausulas por garantia y pregunta
/*
            AND c.ctipcla < 3
            AND c.sclapro NOT IN(SELECT d.sclapro
                                   FROM clausugar d
                                  WHERE d.cramo = pcramo
                                    AND d.cmodali = pcmodali
                                    AND d.ctipseg = pctipseg
                                    AND d.ccolect = pccolect
                                 UNION
                                 SELECT g.sclapro
                                   FROM clausupreg g);
*/
      -- fin Bug 18362 - APD - 23/05/2011
      --BUG0010092: APR - Clausulas por garantia y pregunta - FIN
      CURSOR cur_claupara (pc_sclagen IN NUMBER)
      IS
         SELECT sclagen, nparame, cformat, tparame
           FROM clausupara
          WHERE sclagen = pc_sclagen
            AND cidioma = pac_md_common.f_get_cxtidioma;

      -- BUG 0022839 - FAL - 24/07/2012
      CURSOR cclau_seg
      IS
         SELECT   c.*
             FROM clausupro c, claususeg g, seguros s
            WHERE c.ccolect = pccolect
              AND c.cramo = pcramo
              AND c.ctipseg = pctipseg
              AND c.cmodali = pcmodali
              AND (c.multiple IS NULL OR c.multiple != 1)
              AND c.sclagen = g.sclagen
              AND g.sseguro = s.sseguro
              AND s.npoliza = pac_iax_produccion.poliza.det_poliza.npoliza
              AND s.ncertif = 0
         ORDER BY c.norden;

      -- FI BUG 0022839
      clau        t_iaxpar_clausulas                 := t_iaxpar_clausulas ();
      vpasexec    NUMBER (8)                         := 1;
      vparam      VARCHAR2 (500)
         :=    'pcramo='
            || pcramo
            || ', pcmodali='
            || pcmodali
            || ', pctipseg='
            || pctipseg
            || ', pccolect='
            || pctipseg;
      vobject     VARCHAR2 (200)      := 'PAC_MDPAR_PRODUCTOS.F_Get_Clausulas';
      vnumerr     NUMBER (8)                         := 0;
      vctipo      NUMBER;                              -- Bug APD - 24/05/2011
      v_cclausu   prodherencia_colect.cclausu%TYPE;
                                             -- BUG 0022839 - FAL - 24/07/2012
   BEGIN
      IF    pcramo IS NULL
         OR pctipseg IS NULL
         OR pccolect IS NULL
         OR pcmodali IS NULL
      THEN
         -- BUG 0023615 - JMF - 18/09/2012
         -- RAISE e_param_error;
         RETURN NULL;
      END IF;

      -- BUG 0022839 - FAL - 24/07/2012
      IF     pac_mdpar_productos.f_get_parproducto ('ADMITE_CERTIFICADOS',
                                                    f_sproduc_ret (pcramo,
                                                                   pcmodali,
                                                                   pctipseg,
                                                                   pccolect
                                                                  )
                                                   ) = 1
         AND NOT pac_iax_produccion.isaltacol
      THEN
         vnumerr :=
            pac_productos.f_get_herencia_col (f_sproduc_ret (pcramo,
                                                             pcmodali,
                                                             pctipseg,
                                                             pccolect
                                                            ),
                                              4,
                                              v_cclausu
                                             );

         IF NVL (v_cclausu, 0) IN (1, 2)               -- Bug27305 MMS 2040123
            AND vnumerr = 0
         THEN
            FOR cla IN cclau_seg
            LOOP
               -- Bug 27768/0156133 - APD - 16/10/2013 - no se pueden heredar al certificado
               -- las clausulas exclusivas del certificado 0
               IF NVL (cla.cclaucolec, 3) <> 1
               THEN
                  IF clau IS NULL
                  THEN
                     clau := t_iaxpar_clausulas ();
                  END IF;

                  clau.EXTEND;
                  clau (clau.LAST) := ob_iaxpar_clausulas ();
                  clau (clau.LAST).sclapro := cla.sclapro;
                  clau (clau.LAST).ctipcla := cla.ctipcla;
                  clau (clau.LAST).norden := cla.norden;
                  clau (clau.LAST).sclagen := cla.sclagen;
                  clau (clau.LAST).parametros :=
                     pac_mdpar_productos.f_get_clausulas
                                                     (cla.sclagen,
                                                      clau (clau.LAST).cparams,
                                                      mensajes
                                                     );
                  -- BUG 22843/123300 - FAL - 17/09/2012
                  /*
                  IF cla.ctipcla = 2 THEN   -- VF 32
                     clau(clau.LAST).cobliga := 1;
                  ELSE
                     clau(clau.LAST).cobliga := 0;
                  END IF;
                  */
                  clau (clau.LAST).cobliga := 1;

                  -- FI BUG 22843/123300

                  -- Bug 18362 - APD - 24/05/2011 - se le a? el ctipo al objeto OB_IAXPAR_CLAUSULAS
                  BEGIN
                     SELECT DECODE (tipo, 'PREG', 2, 'GAR', 3)
                       INTO vctipo
                       FROM (SELECT 'GAR' tipo
                               FROM clausugar d
                              WHERE d.cramo = cla.cramo
                                AND d.cmodali = cla.cmodali
                                AND d.ctipseg = cla.ctipseg
                                AND d.ccolect = cla.ccolect
                                AND d.sclapro = cla.sclapro
                             UNION
                             SELECT 'PREG' tipo
                               FROM clausupreg g
                              WHERE g.sclapro = cla.sclapro);

                     IF vctipo IS NULL
                     THEN
                        vctipo := 4;
                     END IF;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        vctipo := 4;
                  END;

                  clau (clau.LAST).ctipo := vctipo;

                  IF clau (clau.LAST).ctipo IN (2, 3)
                  THEN
                     clau (clau.LAST).norden :=
                                              cla.ccapitu * 1000 + cla.norden;
                  END IF;

                  -- fin Bug 18362 - APD - 24/05/2011 -

                  --Comprovacio de parametres
                  IF    cla.sclagen IS NULL
                     OR pac_md_common.f_get_cxtidioma IS NULL
                  THEN
                     RAISE e_param_error;
                  END IF;

                  vnumerr :=
                     pac_productos.f_get_clausugen
                                               (cla.sclagen,
                                                pac_md_common.f_get_cxtidioma,
                                                clau (clau.LAST).tclatit,
                                                clau (clau.LAST).tclatex
                                               );

                  IF vnumerr <> 0
                  THEN
                     pac_iobj_mensajes.crea_nuevo_mensaje (mensajes,
                                                           1,
                                                           vnumerr
                                                          );
                     RAISE e_object_error;
                  END IF;
               END IF;                 -- Bug 27768/0156133 - APD - 16/10/2013
            END LOOP;

            RETURN clau;
         END IF;
      END IF;

      -- FI BUG 0022839
      FOR cla IN cclau
      LOOP
         -- Bug 27768/0156133 - APD - 16/10/2013 - segun la poliza se deben obtener unas
         -- clausulas u otros
         IF    (    pac_mdpar_productos.f_get_parproducto
                                                     ('ADMITE_CERTIFICADOS',
                                                      f_sproduc_ret (pcramo,
                                                                     pcmodali,
                                                                     pctipseg,
                                                                     pccolect
                                                                    )
                                                     ) = 1
                AND pac_iax_produccion.isaltacol
                AND NVL (cla.cclaucolec, 3) IN (1, 3)
               )
            OR (    pac_mdpar_productos.f_get_parproducto
                                                     ('ADMITE_CERTIFICADOS',
                                                      f_sproduc_ret (pcramo,
                                                                     pcmodali,
                                                                     pctipseg,
                                                                     pccolect
                                                                    )
                                                     ) = 1
                AND NOT pac_iax_produccion.isaltacol
                AND NVL (cla.cclaucolec, 3) IN (2, 3)
               )
            OR (pac_mdpar_productos.f_get_parproducto
                                                     ('ADMITE_CERTIFICADOS',
                                                      f_sproduc_ret (pcramo,
                                                                     pcmodali,
                                                                     pctipseg,
                                                                     pccolect
                                                                    )
                                                     ) = 0
               )
         THEN
            IF clau IS NULL
            THEN
               clau := t_iaxpar_clausulas ();
            END IF;

            clau.EXTEND;
            clau (clau.LAST) := ob_iaxpar_clausulas ();
            clau (clau.LAST).sclapro := cla.sclapro;
            clau (clau.LAST).ctipcla := cla.ctipcla;
            clau (clau.LAST).norden := cla.norden;
            clau (clau.LAST).sclagen := cla.sclagen;
            clau (clau.LAST).parametros :=
               pac_mdpar_productos.f_get_clausulas (cla.sclagen,
                                                    clau (clau.LAST).cparams,
                                                    mensajes
                                                   );

            IF cla.ctipcla = 2
            THEN                                                      -- VF 32
               clau (clau.LAST).cobliga := 1;
            ELSE
               clau (clau.LAST).cobliga := 0;
            END IF;

            -- Bug 18362 - APD - 24/05/2011 - se le a? el ctipo al objeto OB_IAXPAR_CLAUSULAS
            BEGIN
               SELECT DECODE (tipo, 'PREG', 2, 'GAR', 3)
                 INTO vctipo
                 FROM (SELECT 'GAR' tipo
                         FROM clausugar d
                        WHERE d.cramo = cla.cramo
                          AND d.cmodali = cla.cmodali
                          AND d.ctipseg = cla.ctipseg
                          AND d.ccolect = cla.ccolect
                          AND d.sclapro = cla.sclapro
                       UNION
                       SELECT 'PREG' tipo
                         FROM clausupreg g
                        WHERE g.sclapro = cla.sclapro);

               IF vctipo IS NULL
               THEN
                  vctipo := 4;
               END IF;
            EXCEPTION
               WHEN OTHERS
               THEN
                  vctipo := 4;
            END;

            clau (clau.LAST).ctipo := vctipo;

            IF clau (clau.LAST).ctipo IN (2, 3)
            THEN
               clau (clau.LAST).norden := cla.ccapitu * 1000 + cla.norden;
            END IF;

            -- fin Bug 18362 - APD - 24/05/2011 -

            --Comprovacio de parametres
            IF cla.sclagen IS NULL OR pac_md_common.f_get_cxtidioma IS NULL
            THEN
               RAISE e_param_error;
            END IF;

            vnumerr :=
               pac_productos.f_get_clausugen (cla.sclagen,
                                              pac_md_common.f_get_cxtidioma,
                                              clau (clau.LAST).tclatit,
                                              clau (clau.LAST).tclatex
                                             );

            IF vnumerr <> 0
            THEN
               pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, vnumerr);
               RAISE e_object_error;
            END IF;
         END IF;                       -- Bug 27768/0156133 - APD - 16/10/2013
      END LOOP;

      RETURN clau;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_get_clausulas;

   /***********************************************************************
      Devuelve las clausulas multiples
      param in cramo     : codigo ramo
      param in cmodali   : codigo modalidad
      param in ctipseg   : codigo tipo de seguro
      param in ccolect   : codigo de colectividad
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_clausulasmult (
      pcramo     IN       NUMBER,
      pcmodali   IN       NUMBER,
      pctipseg   IN       NUMBER,
      pccolect   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN t_iaxpar_clausulas
   IS
      --
      CURSOR cclau
      IS
         SELECT   c.*
             FROM clausupro c
            WHERE c.ccolect = pccolect
              AND c.cramo = pcramo
              AND c.ctipseg = pctipseg
              AND c.cmodali = pcmodali
              AND c.multiple = 1
         ORDER BY c.norden;

      --BUG0010092: APR - Clausulas por garantia y pregunta - FIN
      CURSOR cur_claupara (pc_sclagen IN NUMBER)
      IS
         SELECT sclagen, nparame, cformat, tparame
           FROM clausupara
          WHERE sclagen = pc_sclagen
            AND cidioma = pac_md_common.f_get_cxtidioma;

      clau       t_iaxpar_clausulas := t_iaxpar_clausulas ();
      vpasexec   NUMBER (8)         := 1;
      vparam     VARCHAR2 (500)
         :=    'pcramo='
            || pcramo
            || ', pcmodali='
            || pcmodali
            || ', pctipseg='
            || pctipseg
            || ', pccolect='
            || pctipseg;
      vobject    VARCHAR2 (200)   := 'PAC_MDPAR_PRODUCTOS.F_Get_Clausulasmult';
      vnumerr    NUMBER (8)         := 0;
      vctipo     NUMBER;                               -- Bug APD - 24/05/2011
   BEGIN
      IF    pcramo IS NULL
         OR pctipseg IS NULL
         OR pccolect IS NULL
         OR pcmodali IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      FOR cla IN cclau
      LOOP
         IF clau IS NULL
         THEN
            clau := t_iaxpar_clausulas ();
         END IF;

         clau.EXTEND;
         clau (clau.LAST) := ob_iaxpar_clausulas ();
         clau (clau.LAST).sclapro := cla.sclapro;
         clau (clau.LAST).ctipcla := cla.ctipcla;
         clau (clau.LAST).norden := cla.norden;
         clau (clau.LAST).sclagen := cla.sclagen;
         clau (clau.LAST).parametros :=
            pac_mdpar_productos.f_get_clausulas (cla.sclagen,
                                                 clau (clau.LAST).cparams,
                                                 mensajes
                                                );

         IF cla.ctipcla = 2
         THEN                                                         -- VF 32
            clau (clau.LAST).cobliga := 1;
         ELSE
            clau (clau.LAST).cobliga := 0;
         END IF;

         vctipo := 8;
         clau (clau.LAST).ctipo := vctipo;

         --Comprovacio de parametres
         IF cla.sclagen IS NULL OR pac_md_common.f_get_cxtidioma IS NULL
         THEN
            RAISE e_param_error;
         END IF;

         vnumerr :=
            pac_productos.f_get_clausugen (cla.sclagen,
                                           pac_md_common.f_get_cxtidioma,
                                           clau (clau.LAST).tclatit,
                                           clau (clau.LAST).tclatex
                                          );

         IF vnumerr <> 0
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, vnumerr);
            RAISE e_object_error;
         END IF;
      END LOOP;

      RETURN clau;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_get_clausulasmult;

   /***********************************************************************
      Devuelve la descripcion de una clausula
      param in psclagen  : codigo de la clausula
      param out mensajes : mensajes de error
      return             : descripcion garantia
   ***********************************************************************/
   FUNCTION f_get_descclausula (
      psclagen   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN VARCHAR2
   IS
      dclausu    VARCHAR2 (600);
      RESULT     VARCHAR2 (4000);
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (500)  := 'psclagen=' || psclagen;
      vobject    VARCHAR2 (200)  := 'PAC_MDPAR_PRODUCTOS.F_Get_DescClausula';
   BEGIN
      --Inicialitzacions
      IF psclagen IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      RESULT :=
         pac_md_listvalores.f_getdescripvalor (   'SELECT TCLATEX '
                                               || ' FROM CLAUSUGEN  '
                                               || ' WHERE SCLAGEN = '
                                               || psclagen
                                               || ' AND '
                                               || '      CIDIOMA = '
                                               || pac_md_common.f_get_cxtidioma,
                                               mensajes
                                              );
      --Se comenta el substr porque sino no vemos la descripci¿n entera. 27539#nota:148649
      --dclausu := SUBSTR(RESULT, 1, 600);
      RETURN RESULT;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_get_descclausula;

   /***********************************************************************
      Devuelve las garantias
      param in psproduc  : codigo del producto
      param in pcactivi  : codigo de actividad
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_garantias (
      psproduc   IN       NUMBER,
      pcactivi   IN       NUMBER,
      pnriesgo   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN t_iaxpar_garantias
   IS
      -- Bug 9699 - APD - 24/04/2009 - primero se ha de buscar para la actividad en concreto
      -- y si no se encuentra nada ir a buscar a GARANPRO para la actividad cero
      CURSOR cgaran (pobligacol IN NUMBER, pcmodalidad IN NUMBER)
      IS
         SELECT   gp.cmodali, gp.ccolect, gp.cramo, gp.cgarant, gp.ctipseg,
                  gp.ctarifa, gp.norden, NVL (gm.ctipgar, gp.ctipgar)
                                                                     ctipgar,
                  gp.ctipcap, gp.ctiptar, gp.cgardep, gp.pcapdep, gp.ccapmax,
                  gp.icapmax, gp.icapmin, gp.nedamic, gp.nedamac, gp.nedamar,
                  gp.cformul, gp.ctipfra, gp.ifranqu, gp.cgaranu, gp.cimpcon,
                  gp.cimpdgs, gp.cimpips, gp.cimpces, gp.cimparb, gp.cdtocom,
                  gp.crevali, gp.cextrap, gp.crecarg, gp.cmodtar, gp.prevali,
                  gp.irevali, gp.cmodrev, gp.cimpfng, gp.cactivi, gp.ctarjet,
                  gp.ctipcal, gp.cimpres, gp.cpasmax, gp.cderreg, gp.creaseg,
                  gp.cexclus, gp.crenova, gp.ctecnic, gp.cbasica, gp.cprovis,
                  gp.ctabla, gp.precseg, gp.cramdgs, gp.cdtoint, gp.icaprev,
                  gp.ciedmac, gp.ciedmic, gp.ciedmar, gp.iprimax, gp.iprimin,
                  gp.ciema2c, gp.ciemi2c, gp.ciema2r, gp.nedma2c, gp.nedmi2c,
                  gp.nedma2r, gp.sproduc, gp.cobjaseg, gp.csubobjaseg,
                  gp.cgenrie, gp.cclacap, gp.ctarman, gp.cofersn, gp.nparben,
                  gp.nbns, gp.crecfra, gp.ccontra, gp.cmodint, gp.cpardep,
                  gp.cvalpar, gp.ccapmin, gp.cdetalle, gp.cmoncap,
                  gp.cgarpadre, gp.cvisniv, gp.ciedmrv, gp.nedamrv,
                  gp.cclamin, gm.cdefecto, gm.icapdef, gm.ccapdef,
                  (SELECT tgarant
                     FROM garangen g
                    WHERE g.cgarant = gp.cgarant
                      AND g.cidioma = pac_md_common.f_get_cxtidioma)
                                                                 descripcion,
                  NVL (pac_parametros.f_pargaranpro_n (gp.sproduc,
                                                       gp.cactivi,
                                                       gp.cgarant,
                                                       'PARTIDA'
                                                      ),
                       0
                      ) cpartida
             FROM garanpro gp, garanpromodalidad gm
            WHERE gp.sproduc = psproduc
              AND gp.cactivi = pcactivi
              -- Bug 16106 - RSC - 10/11/2010
              AND (   pobligacol = 0
                   OR     pobligacol = 1
                      AND EXISTS (
                             SELECT g.cgarant
                               FROM garanseg g, seguros s
                              WHERE g.sseguro = s.sseguro
                                AND g.ffinefe IS NULL
                                AND s.npoliza =
                                       pac_iax_produccion.poliza.det_poliza.npoliza
                                AND s.ncertif = 0
                                AND g.nriesgo = NVL (pnriesgo, 1)
                                AND g.cgarant = gp.cgarant)
                  )
              -- Fin Bug 16106
              AND gp.cramo = gm.cramo(+)
              AND gp.cmodali = gm.cmodali(+)
              AND gp.ctipseg = gm.ctipseg(+)
              AND gp.ccolect = gm.ccolect(+)
              AND gp.cactivi = gm.cactivi(+)
              AND gp.cgarant = gm.cgarant(+)
              AND pcmodalidad = gm.cmodalidad(+)
              --Bug 31686/178163 - 27/06/2014 - AMC
              AND (   pcmodalidad IS NULL
                   OR (   (pcmodalidad IS NOT NULL AND gm.ctipgar <> 0)
                       OR gm.ctipgar IS NULL
                      )
                  )
         UNION
         SELECT   gp.cmodali, gp.ccolect, gp.cramo, gp.cgarant, gp.ctipseg,
                  gp.ctarifa, gp.norden, NVL (gm.ctipgar, gp.ctipgar) ctipgar,
                  gp.ctipcap, gp.ctiptar, gp.cgardep, gp.pcapdep, gp.ccapmax,
                  gp.icapmax, gp.icapmin, gp.nedamic, gp.nedamac, gp.nedamar,
                  gp.cformul, gp.ctipfra, gp.ifranqu, gp.cgaranu, gp.cimpcon,
                  gp.cimpdgs, gp.cimpips, gp.cimpces, gp.cimparb, gp.cdtocom,
                  gp.crevali, gp.cextrap, gp.crecarg, gp.cmodtar, gp.prevali,
                  gp.irevali, gp.cmodrev, gp.cimpfng, gp.cactivi, gp.ctarjet,
                  gp.ctipcal, gp.cimpres, gp.cpasmax, gp.cderreg, gp.creaseg,
                  gp.cexclus, gp.crenova, gp.ctecnic, gp.cbasica, gp.cprovis,
                  gp.ctabla, gp.precseg, gp.cramdgs, gp.cdtoint, gp.icaprev,
                  gp.ciedmac, gp.ciedmic, gp.ciedmar, gp.iprimax, gp.iprimin,
                  gp.ciema2c, gp.ciemi2c, gp.ciema2r, gp.nedma2c, gp.nedmi2c,
                  gp.nedma2r, gp.sproduc, gp.cobjaseg, gp.csubobjaseg,
                  gp.cgenrie, gp.cclacap, gp.ctarman, gp.cofersn, gp.nparben,
                  gp.nbns, gp.crecfra, gp.ccontra, gp.cmodint, gp.cpardep,
                  gp.cvalpar, gp.ccapmin, gp.cdetalle, gp.cmoncap,
                  gp.cgarpadre, gp.cvisniv, gp.ciedmrv, gp.nedamrv,
                  gp.cclamin, gm.cdefecto, gm.icapdef, gm.ccapdef,
                  (SELECT tgarant
                     FROM garangen g
                    WHERE g.cgarant = gp.cgarant
                      AND g.cidioma = pac_md_common.f_get_cxtidioma)
                                                                  descripcion,
                  NVL (pac_parametros.f_pargaranpro_n (gp.sproduc,
                                                       gp.cactivi,
                                                       gp.cgarant,
                                                       'PARTIDA'
                                                      ),
                       0
                      ) cpartida
             FROM garanpro gp, garanpromodalidad gm
            WHERE gp.sproduc = psproduc
              AND gp.cactivi = 0
              -- Bug 16106 - RSC - 10/11/2010
              AND gp.cramo = gm.cramo(+)
              AND gp.cmodali = gm.cmodali(+)
              AND gp.ctipseg = gm.ctipseg(+)
              AND gp.ccolect = gm.ccolect(+)
              AND gp.cactivi = gm.cactivi(+)
              AND gp.cgarant = gm.cgarant(+)
              AND pcmodalidad = gm.cmodalidad(+)
              AND (   pobligacol = 0
                   OR     pobligacol = 1
                      AND EXISTS (
                             SELECT g.cgarant
                               FROM garanseg g, seguros s
                              WHERE g.sseguro = s.sseguro
                                AND g.ffinefe IS NULL
                                AND s.npoliza =
                                       pac_iax_produccion.poliza.det_poliza.npoliza
                                AND s.ncertif = 0
                                AND g.nriesgo = NVL (pnriesgo, 1)
                                AND g.cgarant = gp.cgarant)
                  )
              -- Fin Bug 16106
              AND NOT EXISTS (
                     SELECT gp.*,
                            (SELECT tgarant
                               FROM garangen g
                              WHERE g.cgarant = gp.cgarant
                                AND g.cidioma = pac_md_common.f_get_cxtidioma)
                                                                  descripcion
                       FROM garanpro gp
                      WHERE gp.sproduc = psproduc AND gp.cactivi = pcactivi)
              --Bug 31686/178163 - 27/06/2014 - AMC
              AND (   pcmodalidad IS NULL
                   OR (   (pcmodalidad IS NOT NULL AND gm.ctipgar <> 0)
                       OR gm.ctipgar IS NULL
                      )
                  )
         ORDER BY 7;                                                 --norden;

      -- Bug 9699 - APD - 24/04/2009 - Fin

      -- INI BUG 34461, 34462 - Productos de CONVENIOS
      CURSOR cgaran_conv (pobligacol IN NUMBER, pidversion IN NUMBER)
      IS
         SELECT   gp.cmodali, gp.ccolect, gp.cramo, gp.cgarant, gp.ctipseg,
                  gp.ctarifa, gp.norden,
                  DECODE (gm.cobligatoria, 1, 2, 1) ctipgar, gp.ctipcap,
                  gp.ctiptar, gp.cgardep, gp.pcapdep, gp.ccapmax,
                  NVL (gm.icapital, gp.icapmax) icapmax, gp.icapmin,
                  gp.nedamic,
 -- BUG 0034505 - FAL - 6/3/2015 - Asignar capital de la garantia del convenio
                             gp.nedamac, gp.nedamar, gp.cformul, gp.ctipfra,
                  gp.ifranqu, gp.cgaranu, gp.cimpcon, gp.cimpdgs, gp.cimpips,
                  gp.cimpces, gp.cimparb, gp.cdtocom, gp.crevali, gp.cextrap,
                  gp.crecarg, gp.cmodtar, gp.prevali, gp.irevali, gp.cmodrev,
                  gp.cimpfng, gp.cactivi, gp.ctarjet, gp.ctipcal, gp.cimpres,
                  gp.cpasmax, gp.cderreg, gp.creaseg, gp.cexclus, gp.crenova,
                  gp.ctecnic, gp.cbasica, gp.cprovis, gp.ctabla, gp.precseg,
                  gp.cramdgs, gp.cdtoint, gp.icaprev, gp.ciedmac, gp.ciedmic,
                  gp.ciedmar, gp.iprimax, gp.iprimin, gp.ciema2c, gp.ciemi2c,
                  gp.ciema2r, gp.nedma2c, gp.nedmi2c, gp.nedma2r, gp.sproduc,
                  gp.cobjaseg, gp.csubobjaseg, gp.cgenrie, gp.cclacap,
                  gp.ctarman, gp.cofersn, gp.nparben, gp.nbns, gp.crecfra,
                  gp.ccontra, gp.cmodint, gp.cpardep, gp.cvalpar, gp.ccapmin,
                  gp.cdetalle, gp.cmoncap, gp.cgarpadre, gp.cvisniv,
                  gp.ciedmrv, gp.nedamrv, gp.cclamin,
                  DECODE (gm.cobligatoria, 1, 2, 1) cdefecto,
                  gm.icapital icapdef, NULL ccapdef,
                  (SELECT tgarant
                     FROM garangen g
                    WHERE g.cgarant = gp.cgarant
                      AND g.cidioma = pac_md_common.f_get_cxtidioma)
                                                                  descripcion,
                  NVL (pac_parametros.f_pargaranpro_n (gp.sproduc,
                                                       gp.cactivi,
                                                       gp.cgarant,
                                                       'PARTIDA'
                                                      ),
                       0
                      ) cpartida
             FROM garanpro gp, cnv_conv_emp_vers_gar gm
            WHERE gp.sproduc = psproduc
              AND gp.cactivi = 0      --JRH No habr¿n actividades en convenios
              AND (   pobligacol = 0
                   OR     pobligacol = 1
                      AND EXISTS (
                             SELECT g.cgarant
                               FROM garanseg g, seguros s
                              WHERE g.sseguro = s.sseguro
                                AND g.ffinefe IS NULL
                                AND s.npoliza =
                                       pac_iax_produccion.poliza.det_poliza.npoliza
                                AND s.ncertif = 0
                                AND g.nriesgo = NVL (pnriesgo, 1)
                                AND g.cgarant = gp.cgarant)
                  )
              AND pidversion = gm.idversion
              AND gp.cgarant = gm.cgarant
--              AND(pidversion IS NULL
--                  OR((pidversion IS NOT NULL
--                      AND gp.ctipgar <> 0)
--                     OR gp.ctipgar IS NULL))
         ORDER BY 7;

      -- FIN BUG 34461, 34462 - Productos de CONVENIOS

      -- BUG 22843 - FAL - 23/07/2012
      --Bug 31686/178163 - 27/06/2014 - AMC
      CURSOR cgaran_0 (pplan IN NUMBER, pcmodalidad IN NUMBER)
      IS                                             -- (ptipgar IN NUMBER) IS
         SELECT   gp.*,
                  (SELECT tgarant
                     FROM garangen g
                    WHERE g.cgarant = gp.cgarant
                      AND g.cidioma = pac_md_common.f_get_cxtidioma)
                                                                  descripcion,
                  NVL (pac_parametros.f_pargaranpro_n (gp.sproduc,
                                                       gp.cactivi,
                                                       gp.cgarant,
                                                       'PARTIDA'
                                                      ),
                       0
                      ) cpartida
             FROM garanpro gp, garanpromodalidad gm
            WHERE gp.sproduc = psproduc
              AND gp.cactivi = pcactivi
              AND gp.cramo = gm.cramo(+)
              AND gp.cmodali = gm.cmodali(+)
              AND gp.ctipseg = gm.ctipseg(+)
              AND gp.ccolect = gm.ccolect(+)
              AND gp.cactivi = gm.cactivi(+)
              AND gp.cgarant = gm.cgarant(+)
              AND pcmodalidad = gm.cmodalidad(+)
              AND (   pcmodalidad IS NULL
                   OR (   (pcmodalidad IS NOT NULL AND gm.ctipgar <> 0)
                       OR gm.ctipgar IS NULL
                      )
                  )
              AND EXISTS (
                     SELECT g.cgarant
                       FROM garanseg g, seguros s
                      WHERE g.sseguro = s.sseguro
                        AND g.nriesgo = NVL (pplan, g.nriesgo)
                        AND g.ffinefe IS NULL
                        AND s.npoliza =
                                  pac_iax_produccion.poliza.det_poliza.npoliza
                        AND s.ncertif = 0
                        AND g.cgarant = gp.cgarant)
         UNION
         SELECT   gp.*,
                  (SELECT tgarant
                     FROM garangen g
                    WHERE g.cgarant = gp.cgarant
                      AND g.cidioma = pac_md_common.f_get_cxtidioma)
                                                                  descripcion,
                  NVL (pac_parametros.f_pargaranpro_n (gp.sproduc,
                                                       gp.cactivi,
                                                       gp.cgarant,
                                                       'PARTIDA'
                                                      ),
                       0
                      ) cpartida
             FROM garanpro gp, garanpromodalidad gm
            WHERE gp.sproduc = psproduc
              AND gp.cactivi = 0
              AND gp.cramo = gm.cramo(+)
              AND gp.cmodali = gm.cmodali(+)
              AND gp.ctipseg = gm.ctipseg(+)
              AND gp.ccolect = gm.ccolect(+)
              AND gp.cactivi = gm.cactivi(+)
              AND gp.cgarant = gm.cgarant(+)
              AND pcmodalidad = gm.cmodalidad(+)
              AND (   pcmodalidad IS NULL
                   OR (   (pcmodalidad IS NOT NULL AND gm.ctipgar <> 0)
                       OR gm.ctipgar IS NULL
                      )
                  )
              AND EXISTS (
                     SELECT g.cgarant
                       FROM garanseg g, seguros s
                      WHERE g.sseguro = s.sseguro
                        AND g.ffinefe IS NULL
                        AND g.nriesgo = NVL (pplan, g.nriesgo)
                        AND s.npoliza =
                                  pac_iax_produccion.poliza.det_poliza.npoliza
                        AND s.ncertif = 0
                        AND g.cgarant = gp.cgarant)
              AND NOT EXISTS (
                     SELECT gp.*,
                            (SELECT tgarant
                               FROM garangen g
                              WHERE g.cgarant = gp.cgarant
                                AND g.cidioma = pac_md_common.f_get_cxtidioma)
                                                                  descripcion
                       FROM garanpro gp
                      WHERE gp.sproduc = psproduc AND gp.cactivi = pcactivi)
         ORDER BY 7;

      -- FI BUG 22843
      -- Fi Bug 31686/178163 - 27/06/2014 - AMC

      -- INI BUG 34461, 34462 - Productos de CONVENIOS
      CURSOR cgaran_0_conv (pplan IN NUMBER, pidversion IN NUMBER)
      IS
         SELECT   gp.*,
                  (SELECT tgarant
                     FROM garangen g
                    WHERE g.cgarant = gp.cgarant
                      AND g.cidioma = pac_md_common.f_get_cxtidioma)
                                                                  descripcion,
                  NVL (pac_parametros.f_pargaranpro_n (gp.sproduc,
                                                       gp.cactivi,
                                                       gp.cgarant,
                                                       'PARTIDA'
                                                      ),
                       0
                      ) cpartida
             FROM garanpro gp, cnv_conv_emp_vers_gar gm
            WHERE gp.sproduc = psproduc
              AND gp.cactivi = 0
              AND gp.cgarant = gm.cgarant(+)
              AND pidversion = gm.idversion(+)
              AND (   pidversion IS NULL
                   OR (   (pidversion IS NOT NULL AND gp.ctipgar <> 0)
                       OR gp.ctipgar IS NULL
                      )
                  )
              AND EXISTS (
                     SELECT g.cgarant
                       FROM garanseg g, seguros s
                      WHERE g.sseguro = s.sseguro
                        AND g.ffinefe IS NULL
                        AND g.nriesgo = NVL (pplan, g.nriesgo)
                        AND s.npoliza =
                                  pac_iax_produccion.poliza.det_poliza.npoliza
                        AND s.ncertif = 0
                        AND g.cgarant = gp.cgarant)
              AND NOT EXISTS (
                     SELECT gp.*,
                            (SELECT tgarant
                               FROM garangen g
                              WHERE g.cgarant = gp.cgarant
                                AND g.cidioma = pac_md_common.f_get_cxtidioma)
                                                                  descripcion
                       FROM garanpro gp
                      WHERE gp.sproduc = psproduc AND gp.cactivi = pcactivi)
         ORDER BY 7;

      -- FIN BUG 34461, 34462 - Productos de CONVENIOS
      garan             t_iaxpar_garantias;
      vpasexec          NUMBER (8)         := 1;
      vparam            VARCHAR2 (500)
                       := 'psproduc=' || psproduc || ', pcactivi=' || pcactivi;
      vobject           VARCHAR2 (200)
                                      := 'PAC_MDPAR_PRODUCTOS.F_Get_Garantias';
      v_obligacol       NUMBER;
      vnumerr           NUMBER;
      v_crealiza        NUMBER;
      -- BUG 22843 - FAL - 23/07/2012
      v_tipo_herencia   NUMBER
                   := NVL (f_parproductos_v (psproduc, 'HEREDA_GARANTIAS'), 0);
      vplan             NUMBER;
      v_salta           NUMBER;
      riesgo            ob_iax_riesgos;
   -- Fin BUG 22843
   BEGIN
      --Inicialitzacions
      IF psproduc IS NULL OR pcactivi IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      -- Bug 16106 - RSC - 10/11/2010
      IF     NVL (f_parproductos_v (psproduc, 'DETALLE_GARANT'), 0) IN (1, 2)
         AND NVL (f_parproductos_v (psproduc, 'ADMITE_CERTIFICADOS'), 0) = 1
         AND NOT pac_iax_produccion.isaltacol
      THEN
         v_obligacol := 1;
      ELSE
         v_obligacol := 0;
      END IF;

      -- Fin Bug 16106
      -- BUG 22843 - FAL - 23/07/2012
      v_tipo_herencia :=
                      NVL (f_parproductos_v (psproduc, 'HEREDA_GARANTIAS'), 0);

      IF     pac_iax_produccion.poliza.det_poliza.preguntas IS NOT NULL
         AND pac_iax_produccion.poliza.det_poliza.preguntas.COUNT > 0
      THEN
         FOR i IN
            pac_iax_produccion.poliza.det_poliza.preguntas.FIRST .. pac_iax_produccion.poliza.det_poliza.preguntas.LAST
         LOOP
            IF pac_iax_produccion.poliza.det_poliza.preguntas (i).cpregun =
                                                                         4089
            THEN
               vplan :=
                   pac_iax_produccion.poliza.det_poliza.preguntas (i).crespue;
            END IF;
         END LOOP;
      END IF;

      -- Bug 27923 - INICIO - DCT - 06/09/2013 - LCOL_F3BTEC-MTF3B - LCOL_TEC23 - Definici?n de condiciones en Certificado
      IF     v_tipo_herencia IN (1, 3, 4)
         -- Bug 27923 - FIN - DCT - 06/09/2013 - LCOL_F3BTEC-MTF3B - LCOL_TEC23 - Definici?n de condiciones en Certificado
         AND NOT pac_iax_produccion.isaltacol
         -- Bug 0030975 - 11-04-2014 - jmf - abrir cursor con p¿liza informada
         AND pac_iax_produccion.poliza.det_poliza.npoliza IS NOT NULL
      THEN
         -- INI BUG 34461, 34462 - Productos de CONVENIOS
         IF pac_iax_produccion.poliza.det_poliza.convempvers.idversion IS NULL
         THEN
            -- FIN BUG 34461, 34462 - Productos de CONVENIOS
               --Bug 31686/178163 - 27/06/2014 - AMC
            riesgo :=
                pac_iax_produccion.f_get_riesgo (NVL (pnriesgo, 1), mensajes);

            FOR cgar IN cgaran_0 (NVL (vplan, 1), riesgo.cmodalidad)
            LOOP
               IF garan IS NULL
               THEN
                  garan := t_iaxpar_garantias ();
               END IF;

               garan.EXTEND;
               garan (garan.LAST) := ob_iaxpar_garantias ();
               garan (garan.LAST).cgarant := cgar.cgarant;
               -- garan(garan.last).descripcion := cgar.cgarant||' - '||cgar.descripcion;
               garan (garan.LAST).descripcion := cgar.descripcion;
               garan (garan.LAST).norden := cgar.norden;
               garan (garan.LAST).ctipgar := cgar.ctipgar;
               garan (garan.LAST).ctipcap := cgar.ctipcap;
               garan (garan.LAST).ctiptar := cgar.ctiptar;
               garan (garan.LAST).cgardep := cgar.cgardep;
               garan (garan.LAST).cpardep := cgar.cpardep;
               garan (garan.LAST).pcapdep := cgar.pcapdep;
               garan (garan.LAST).icapmax := cgar.icapmax;
               garan (garan.LAST).icapmin := cgar.icapmin;
               garan (garan.LAST).cformul := cgar.cformul;
               garan (garan.LAST).crevali := cgar.crevali;
               garan (garan.LAST).irevali := cgar.irevali;
               garan (garan.LAST).prevali := cgar.prevali;
               garan (garan.LAST).icaprev := cgar.icaprev;
               garan (garan.LAST).cmodtar := cgar.cmodtar;
               garan (garan.LAST).cextrap := cgar.cextrap;
               garan (garan.LAST).crecarg := cgar.crecarg;
               garan (garan.LAST).cmodrev := cgar.cmodrev;
               garan (garan.LAST).cdtocom := cgar.cdtocom;
               garan (garan.LAST).cimpcon := cgar.cimpcon;
               garan (garan.LAST).cimpdgs := cgar.cimpdgs;
               garan (garan.LAST).cimpips := cgar.cimpips;
               garan (garan.LAST).cimpfng := cgar.cimpfng;
               garan (garan.LAST).cimparb := cgar.cimparb;
               garan (garan.LAST).creaseg := cgar.creaseg;
               garan (garan.LAST).cderreg := cgar.cderreg;
               garan (garan.LAST).cdetalle := cgar.cdetalle;
               garan (garan.LAST).cmoncap := cgar.cmoncap;
               -- Bug 26501 - MMS - 27/03/2013
               garan (garan.LAST).cclacap := cgar.cclacap;
               garan (garan.LAST).cclamin := cgar.cclamin;

               -- Fin Bug 26501 - MMS - 27/03/2013
               IF cgar.cmoncap IS NOT NULL
               THEN
                  garan (garan.LAST).tmoncap :=
                     pac_md_listvalores.f_get_tmoneda
                                               (cgar.cmoncap,
                                                garan (garan.LAST).cmoncapint,
                                                mensajes
                                               );
               END IF;

               --JRH 03/2008
               garan (garan.LAST).ctipo :=
                  pac_mdpar_productos.f_get_pargarantia ('TIPO',
                                                         psproduc,
                                                         cgar.cgarant,
                                                         cgar.cactivi
                                                        );
                                             -- BUG 0036730 - FAL - 09/12/2015
               --JRH 03/2008
               garan (garan.LAST).preguntas := NULL;
               garan (garan.LAST).listacapitales :=
                  f_get_garanprocap (psproduc,
                                     pcactivi,
                                     cgar.cramo,
                                     cgar.cmodali,
                                     cgar.ctipseg,
                                     cgar.ccolect,
                                     cgar.cgarant,
                                     mensajes
                                    );
               garan (garan.LAST).incompgaran := NULL;
               garan (garan.LAST).franquicias := NULL;
               garan (garan.LAST).cpartida := cgar.cpartida;
               garan (garan.LAST).cvisniv := cgar.cvisniv;
               garan (garan.LAST).cgarpadre := cgar.cgarpadre;

               BEGIN
                  SELECT DECODE (cgarant, g01, 1, g02, 2, g03, 3, NULL)
                    INTO garan (garan.LAST).cnivgar
                    FROM garanprored
                   WHERE sproduc = cgar.sproduc
                     AND cactivi = cgar.cactivi
                     AND cgarant = cgar.cgarant
                     AND fmovfin IS NULL;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     garan (garan.LAST).cnivgar := NULL;
               END;

               vnumerr :=
                  pac_cfg.f_get_user_accion_permitida
                                           (f_user,
                                            'NIVEL_VISIONGAR',
                                            cgar.sproduc,
                                            pac_md_common.f_get_cxtempresa (),
                                            v_crealiza
                                           );

               IF NVL (cgar.cvisniv, 1) > NVL (v_crealiza, 3)
               THEN
                  garan (garan.LAST).cvisible := 0;
               ELSE
                  garan (garan.LAST).cvisible := 1;
               END IF;

               -- Bug 0027744 - dlF - Producto de Explotaciones 2014 - Ocultar garantias en modo SIMULACION
               garan (garan.LAST).cvisible :=
                  focultagarantia (cgar.sproduc,
                                   cgar.cgarant,
                                   garan (garan.LAST).cvisible
                                  );
            --fin BUG 0027744 - dlF -
            END LOOP;
         -- INI BUG 34461, 34462 - Productos de CONVENIOS
         ELSE
--            FOR cgar IN
--               cgaran_0_conv(NVL(vplan, 1),
--                             pac_iax_produccion.poliza.det_poliza.convempvers.idversion) LOOP
            FOR cgar IN
               cgaran_conv
                  (0,
                   pac_iax_produccion.poliza.det_poliza.convempvers.idversion
                  )
            LOOP
               IF garan IS NULL
               THEN
                  garan := t_iaxpar_garantias ();
               END IF;

               garan.EXTEND;
               garan (garan.LAST) := ob_iaxpar_garantias ();
               garan (garan.LAST).cgarant := cgar.cgarant;
               -- garan(garan.last).descripcion := cgar.cgarant||' - '||cgar.descripcion;
               garan (garan.LAST).descripcion := cgar.descripcion;
               garan (garan.LAST).norden := cgar.norden;
               garan (garan.LAST).ctipgar := cgar.ctipgar;
               garan (garan.LAST).ctipcap := cgar.ctipcap;
               garan (garan.LAST).ctiptar := cgar.ctiptar;
               garan (garan.LAST).cgardep := cgar.cgardep;
               garan (garan.LAST).cpardep := cgar.cpardep;
               garan (garan.LAST).pcapdep := cgar.pcapdep;
               garan (garan.LAST).icapmax := cgar.icapmax;
               garan (garan.LAST).icapmin := cgar.icapmin;
               garan (garan.LAST).cformul := cgar.cformul;
               garan (garan.LAST).crevali := cgar.crevali;
               garan (garan.LAST).irevali := cgar.irevali;
               garan (garan.LAST).prevali := cgar.prevali;
               garan (garan.LAST).icaprev := cgar.icaprev;
               garan (garan.LAST).cmodtar := cgar.cmodtar;
               garan (garan.LAST).cextrap := cgar.cextrap;
               garan (garan.LAST).crecarg := cgar.crecarg;
               garan (garan.LAST).cmodrev := cgar.cmodrev;
               garan (garan.LAST).cdtocom := cgar.cdtocom;
               garan (garan.LAST).cimpcon := cgar.cimpcon;
               garan (garan.LAST).cimpdgs := cgar.cimpdgs;
               garan (garan.LAST).cimpips := cgar.cimpips;
               garan (garan.LAST).cimpfng := cgar.cimpfng;
               garan (garan.LAST).cimparb := cgar.cimparb;
               garan (garan.LAST).creaseg := cgar.creaseg;
               garan (garan.LAST).cderreg := cgar.cderreg;
               garan (garan.LAST).cdetalle := cgar.cdetalle;
               garan (garan.LAST).cmoncap := cgar.cmoncap;
               garan (garan.LAST).cclacap := cgar.cclacap;
               garan (garan.LAST).cclamin := cgar.cclamin;

               IF cgar.cmoncap IS NOT NULL
               THEN
                  garan (garan.LAST).tmoncap :=
                     pac_md_listvalores.f_get_tmoneda
                                               (cgar.cmoncap,
                                                garan (garan.LAST).cmoncapint,
                                                mensajes
                                               );
               END IF;

               garan (garan.LAST).ctipo :=
                  pac_mdpar_productos.f_get_pargarantia ('TIPO',
                                                         psproduc,
                                                         cgar.cgarant,
                                                         cgar.cactivi
                                                        );
                                             -- BUG 0036730 - FAL - 09/12/2015
               garan (garan.LAST).preguntas := NULL;
               garan (garan.LAST).listacapitales :=
                  f_get_garanprocap (psproduc,
                                     pcactivi,
                                     cgar.cramo,
                                     cgar.cmodali,
                                     cgar.ctipseg,
                                     cgar.ccolect,
                                     cgar.cgarant,
                                     mensajes
                                    );
               garan (garan.LAST).incompgaran := NULL;
               garan (garan.LAST).franquicias := NULL;
               garan (garan.LAST).cpartida := cgar.cpartida;
               garan (garan.LAST).cvisniv := cgar.cvisniv;
               garan (garan.LAST).cgarpadre := cgar.cgarpadre;

               BEGIN
                  SELECT DECODE (cgarant, g01, 1, g02, 2, g03, 3, NULL)
                    INTO garan (garan.LAST).cnivgar
                    FROM garanprored
                   WHERE sproduc = cgar.sproduc
                     AND cactivi = cgar.cactivi
                     AND cgarant = cgar.cgarant
                     AND fmovfin IS NULL;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     garan (garan.LAST).cnivgar := NULL;
               END;

               vnumerr :=
                  pac_cfg.f_get_user_accion_permitida
                                           (f_user,
                                            'NIVEL_VISIONGAR',
                                            cgar.sproduc,
                                            pac_md_common.f_get_cxtempresa (),
                                            v_crealiza
                                           );

               IF NVL (cgar.cvisniv, 1) > NVL (v_crealiza, 3)
               THEN
                  garan (garan.LAST).cvisible := 0;
               ELSE
                  garan (garan.LAST).cvisible := 1;
               END IF;

               garan (garan.LAST).cvisible :=
                  focultagarantia (cgar.sproduc,
                                   cgar.cgarant,
                                   garan (garan.LAST).cvisible
                                  );
            --
            END LOOP;
         -- FIN BUG 34461, 34462 - Productos de CONVENIOS
         END IF;
      ELSE
         riesgo :=
                pac_iax_produccion.f_get_riesgo (NVL (pnriesgo, 1), mensajes);

         -- Fi Bug 22843

         -- INI BUG 34461, 34462 - Productos de CONVENIOS
         IF pac_iax_produccion.poliza.det_poliza.convempvers.idversion IS NOT NULL
         THEN
            FOR cgar IN
               cgaran_conv
                  (0,
                   pac_iax_produccion.poliza.det_poliza.convempvers.idversion
                  )
            LOOP
               IF garan IS NULL
               THEN
                  garan := t_iaxpar_garantias ();
               END IF;

               garan.EXTEND;
               garan (garan.LAST) := ob_iaxpar_garantias ();
               garan (garan.LAST).cgarant := cgar.cgarant;
               -- garan(garan.last).descripcion := cgar.cgarant||' - '||cgar.descripcion;
               garan (garan.LAST).descripcion := cgar.descripcion;
               garan (garan.LAST).norden := cgar.norden;
               garan (garan.LAST).ctipgar := cgar.ctipgar;
               garan (garan.LAST).ctipcap := cgar.ctipcap;
               garan (garan.LAST).ctiptar := cgar.ctiptar;
               garan (garan.LAST).cgardep := cgar.cgardep;
               garan (garan.LAST).cpardep := cgar.cpardep;
               garan (garan.LAST).pcapdep := cgar.pcapdep;
               garan (garan.LAST).icapmax := cgar.icapmax;
               garan (garan.LAST).icapmin := cgar.icapmin;
               garan (garan.LAST).cformul := cgar.cformul;
               garan (garan.LAST).crevali := cgar.crevali;
               garan (garan.LAST).irevali := cgar.irevali;
               garan (garan.LAST).prevali := cgar.prevali;
               garan (garan.LAST).icaprev := cgar.icaprev;
               garan (garan.LAST).cmodtar := cgar.cmodtar;
               garan (garan.LAST).cextrap := cgar.cextrap;
               garan (garan.LAST).crecarg := cgar.crecarg;
               garan (garan.LAST).cmodrev := cgar.cmodrev;
               garan (garan.LAST).cdtocom := cgar.cdtocom;
               garan (garan.LAST).cimpcon := cgar.cimpcon;
               garan (garan.LAST).cimpdgs := cgar.cimpdgs;
               garan (garan.LAST).cimpips := cgar.cimpips;
               garan (garan.LAST).cimpfng := cgar.cimpfng;
               garan (garan.LAST).cimparb := cgar.cimparb;
               garan (garan.LAST).creaseg := cgar.creaseg;
               garan (garan.LAST).cderreg := cgar.cderreg;
               garan (garan.LAST).cdetalle := cgar.cdetalle;
               garan (garan.LAST).cmoncap := cgar.cmoncap;
               -- Bug 26501 - MMS - 27/03/2013
               garan (garan.LAST).cclacap := cgar.cclacap;
               garan (garan.LAST).cclamin := cgar.cclamin;

               -- Fin Bug 26501 - MMS - 27/03/2013
               IF cgar.cmoncap IS NOT NULL
               THEN
                  garan (garan.LAST).tmoncap :=
                     pac_md_listvalores.f_get_tmoneda
                                               (cgar.cmoncap,
                                                garan (garan.LAST).cmoncapint,
                                                mensajes
                                               );
               END IF;

               --JRH 03/2008
               garan (garan.LAST).ctipo :=
                  pac_mdpar_productos.f_get_pargarantia ('TIPO',
                                                         psproduc,
                                                         cgar.cgarant,
                                                         cgar.cactivi
                                                        );
                                             -- BUG 0036730 - FAL - 09/12/2015
               --JRH 03/2008
               garan (garan.LAST).preguntas := NULL;
               garan (garan.LAST).listacapitales :=
                  f_get_garanprocap (psproduc,
                                     pcactivi,
                                     cgar.cramo,
                                     cgar.cmodali,
                                     cgar.ctipseg,
                                     cgar.ccolect,
                                     cgar.cgarant,
                                     mensajes
                                    );
               garan (garan.LAST).incompgaran := NULL;
               garan (garan.LAST).franquicias := NULL;
               garan (garan.LAST).cpartida := cgar.cpartida;
              -- 17988: AGM003 - Modificacion pantalla garantias (axisctr007).
               -- Bug 22049 - APD - 30/04/2012 - se a¿aden los campos cnivgar, cvisniv, cvisible, cgarpadre
               garan (garan.LAST).cvisniv := cgar.cvisniv;
               garan (garan.LAST).cgarpadre := cgar.cgarpadre;

               BEGIN
                  SELECT DECODE (cgarant, g01, 1, g02, 2, g03, 3, NULL)
                    INTO garan (garan.LAST).cnivgar
                    FROM garanprored
                   WHERE sproduc = cgar.sproduc
                     AND cactivi = cgar.cactivi
                     AND cgarant = cgar.cgarant
                     AND fmovfin IS NULL;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     garan (garan.LAST).cnivgar := NULL;
               END;

               vnumerr :=
                  pac_cfg.f_get_user_accion_permitida
                                           (f_user,
                                            'NIVEL_VISIONGAR',
                                            cgar.sproduc,
                                            pac_md_common.f_get_cxtempresa (),
                                            v_crealiza
                                           );

               -- la garantia sera visible o no en funcion de cfg_accion.crealiza y garanpro.cvisniv
               -- Se definen tres niveles de vision:
               -- Los usuarios que tengan el nivel 1 solo podran ver las garantias del nivel 1.
               -- Los usuarios que tengan el nivel 2 podran ver las garantias de nivel 1 y 2.
               -- Los usuarios que tengan el nivel 3 podran ver las garantia de nivel 1, 2 y 3.
               -- si no hay configuracion en cfg_accion para la accion 'NIVEL_VISIONGAR' se entiende
               -- que la garantia es visible (se pone por defecto 3 que es el que permite ver todos
               -- los niveles de garantias)
               -- si si que hay parametrizacion en cfg_accion si el nivel de vision de la garantia es
               -- mayor al nivel de vision permitido para el usuario, no se permite ver la garantia
               IF NVL (cgar.cvisniv, 1) > NVL (v_crealiza, 3)
               THEN
                  garan (garan.LAST).cvisible := 0;    -- garantia no visible
               ELSE
                  garan (garan.LAST).cvisible := 1;       -- garantia visible
               END IF;

               -- fin Bug 22049 - APD - 30/04/2012

               -- Bug 0027744 - dlF - Producto de Explotaciones 2014 - Ocultar garantias en modo SIMULACION
               garan (garan.LAST).cvisible :=
                  focultagarantia (cgar.sproduc,
                                   cgar.cgarant,
                                   garan (garan.LAST).cvisible
                                  );
               garan (garan.LAST).ctipgar := cgar.ctipgar;
               garan (garan.LAST).cdefecto := cgar.cdefecto;
               --fin BUG 0027744 - dlF -
               garan (garan.LAST).icapdef := cgar.icapdef;
               garan (garan.LAST).ccapdef := cgar.ccapdef;
            END LOOP;
         -- FIN BUG 34461, 34462 - Productos de CONVENIOS
         ELSE
            FOR cgar IN cgaran (v_obligacol, riesgo.cmodalidad)
            LOOP
               IF garan IS NULL
               THEN
                  garan := t_iaxpar_garantias ();
               END IF;

               garan.EXTEND;
               garan (garan.LAST) := ob_iaxpar_garantias ();
               garan (garan.LAST).cgarant := cgar.cgarant;
               -- garan(garan.last).descripcion := cgar.cgarant||' - '||cgar.descripcion;
               garan (garan.LAST).descripcion := cgar.descripcion;
               garan (garan.LAST).norden := cgar.norden;
               garan (garan.LAST).ctipgar := cgar.ctipgar;
               garan (garan.LAST).ctipcap := cgar.ctipcap;
               garan (garan.LAST).ctiptar := cgar.ctiptar;
               garan (garan.LAST).cgardep := cgar.cgardep;
               garan (garan.LAST).cpardep := cgar.cpardep;
               garan (garan.LAST).pcapdep := cgar.pcapdep;
               garan (garan.LAST).icapmax := cgar.icapmax;
               garan (garan.LAST).icapmin := cgar.icapmin;
               garan (garan.LAST).cformul := cgar.cformul;
               garan (garan.LAST).crevali := cgar.crevali;
               garan (garan.LAST).irevali := cgar.irevali;
               garan (garan.LAST).prevali := cgar.prevali;
               garan (garan.LAST).icaprev := cgar.icaprev;
               garan (garan.LAST).cmodtar := cgar.cmodtar;
               garan (garan.LAST).cextrap := cgar.cextrap;
               garan (garan.LAST).crecarg := cgar.crecarg;
               garan (garan.LAST).cmodrev := cgar.cmodrev;
               garan (garan.LAST).cdtocom := cgar.cdtocom;
               garan (garan.LAST).cimpcon := cgar.cimpcon;
               garan (garan.LAST).cimpdgs := cgar.cimpdgs;
               garan (garan.LAST).cimpips := cgar.cimpips;
               garan (garan.LAST).cimpfng := cgar.cimpfng;
               garan (garan.LAST).cimparb := cgar.cimparb;
               garan (garan.LAST).creaseg := cgar.creaseg;
               garan (garan.LAST).cderreg := cgar.cderreg;
               garan (garan.LAST).cdetalle := cgar.cdetalle;
               garan (garan.LAST).cmoncap := cgar.cmoncap;
               -- Bug 26501 - MMS - 27/03/2013
               garan (garan.LAST).cclacap := cgar.cclacap;
               garan (garan.LAST).cclamin := cgar.cclamin;

               -- Fin Bug 26501 - MMS - 27/03/2013
               IF cgar.cmoncap IS NOT NULL
               THEN
                  garan (garan.LAST).tmoncap :=
                     pac_md_listvalores.f_get_tmoneda
                                               (cgar.cmoncap,
                                                garan (garan.LAST).cmoncapint,
                                                mensajes
                                               );
               END IF;

               --JRH 03/2008
               garan (garan.LAST).ctipo :=
                  pac_mdpar_productos.f_get_pargarantia ('TIPO',
                                                         psproduc,
                                                         cgar.cgarant,
                                                         cgar.cactivi
                                                        );
                                             -- BUG 0036730 - FAL - 09/12/2015
               --JRH 03/2008
               garan (garan.LAST).preguntas := NULL;
               garan (garan.LAST).listacapitales :=
                  f_get_garanprocap (psproduc,
                                     pcactivi,
                                     cgar.cramo,
                                     cgar.cmodali,
                                     cgar.ctipseg,
                                     cgar.ccolect,
                                     cgar.cgarant,
                                     mensajes
                                    );
               garan (garan.LAST).incompgaran := NULL;
               garan (garan.LAST).franquicias := NULL;
               garan (garan.LAST).cpartida := cgar.cpartida;
              -- 17988: AGM003 - Modificacion pantalla garantias (axisctr007).
               -- Bug 22049 - APD - 30/04/2012 - se a¿aden los campos cnivgar, cvisniv, cvisible, cgarpadre
               garan (garan.LAST).cvisniv := cgar.cvisniv;
               garan (garan.LAST).cgarpadre := cgar.cgarpadre;

               BEGIN
                  SELECT DECODE (cgarant, g01, 1, g02, 2, g03, 3, NULL)
                    INTO garan (garan.LAST).cnivgar
                    FROM garanprored
                   WHERE sproduc = cgar.sproduc
                     AND cactivi = cgar.cactivi
                     AND cgarant = cgar.cgarant
                     AND fmovfin IS NULL;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     garan (garan.LAST).cnivgar := NULL;
               END;

               vnumerr :=
                  pac_cfg.f_get_user_accion_permitida
                                           (f_user,
                                            'NIVEL_VISIONGAR',
                                            cgar.sproduc,
                                            pac_md_common.f_get_cxtempresa (),
                                            v_crealiza
                                           );

               -- la garantia sera visible o no en funcion de cfg_accion.crealiza y garanpro.cvisniv
               -- Se definen tres niveles de vision:
               -- Los usuarios que tengan el nivel 1 solo podran ver las garantias del nivel 1.
               -- Los usuarios que tengan el nivel 2 podran ver las garantias de nivel 1 y 2.
               -- Los usuarios que tengan el nivel 3 podran ver las garantia de nivel 1, 2 y 3.
               -- si no hay configuracion en cfg_accion para la accion 'NIVEL_VISIONGAR' se entiende
               -- que la garantia es visible (se pone por defecto 3 que es el que permite ver todos
               -- los niveles de garantias)
               -- si si que hay parametrizacion en cfg_accion si el nivel de vision de la garantia es
               -- mayor al nivel de vision permitido para el usuario, no se permite ver la garantia
               IF NVL (cgar.cvisniv, 1) > NVL (v_crealiza, 3)
               THEN
                  garan (garan.LAST).cvisible := 0;    -- garantia no visible
               ELSE
                  garan (garan.LAST).cvisible := 1;       -- garantia visible
               END IF;

               -- fin Bug 22049 - APD - 30/04/2012

               -- Bug 0027744 - dlF - Producto de Explotaciones 2014 - Ocultar garantias en modo SIMULACION
               garan (garan.LAST).cvisible :=
                  focultagarantia (cgar.sproduc,
                                   cgar.cgarant,
                                   garan (garan.LAST).cvisible
                                  );
               garan (garan.LAST).ctipgar := cgar.ctipgar;
               garan (garan.LAST).cdefecto := cgar.cdefecto;
               --fin BUG 0027744 - dlF -
               garan (garan.LAST).icapdef := cgar.icapdef;
               garan (garan.LAST).ccapdef := cgar.ccapdef;
            END LOOP;
         END IF;
      END IF;                                  -- BUG 22843 - FAL - 23/07/2012

      RETURN garan;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_get_garantias;

   /***********************************************************************
      Devuelve la descripcion de una garantia
      param in  cgarant  : codigo de la garantia
      param out mensajes : mensajes de error
      return             : descripcion garantia
   ***********************************************************************/
   FUNCTION f_get_descgarant (
      pcgarant   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN VARCHAR2
   IS
      dgarant    VARCHAR2 (120)  := NULL;      --bug:22011 - JMC - 27/06/2012
      RESULT     VARCHAR2 (4000);
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (500)  := 'pcgarant=' || pcgarant;
      vobject    VARCHAR2 (200)  := 'PAC_MDPAR_PRODUCTOS.F_Get_DescGarant';
   BEGIN
      --Inicialitzacions
      IF pcgarant IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      RESULT :=
         pac_md_listvalores.f_getdescripvalor
                                        (   'select tgarant from garangen g '
                                         || ' where g.cgarant='
                                         || pcgarant
                                         || ' and '
                                         || '       g.cidioma='
                                         || pac_md_common.f_get_cxtidioma,
                                         mensajes
                                        );
      dgarant := RESULT;                        --bug:22011 - JMC - 27/06/2012
      RETURN dgarant;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_get_descgarant;

   /***********************************************************************
      Devuelve la respuesta de una pregunta
      param in  psproduc : codigo de producto
      param in  pcpregun : codigo de la pregunta
      param in  pcrespue : codigo de la respuesta
      param in  pcidioma : codigo de idioma
      param out mensajes : mensajes de error
      return             : descripcion pregunta
   ***********************************************************************/
   -- Bug 0012227 - 18/12/2009 - JMF: Afegir sproduc
   FUNCTION f_get_pregunrespue (
      psproduc   IN       NUMBER,
      pcpregun   IN       NUMBER,
      pcrespue   IN       NUMBER,
      pcidioma   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN VARCHAR2
   IS
      RESULT     VARCHAR2 (4000);
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (500)
         :=    'psproduc= '
            || psproduc
            || ' pcpregun= '
            || pcpregun
            || ' pcrespue='
            || pcrespue
            || ' pcidioma= '
            || pcidioma;
      vobject    VARCHAR2 (200)  := 'PAC_MDPAR_PRODUCTOS.F_Get_PregunRespue';
      vnumerr    NUMBER (8)      := 0;
   BEGIN
      --Comprovacio de parametres d'entrada
      -- Bug 0012227 - 18/12/2009 - JMF: Afegir sproduc
      IF    pcpregun IS NULL
         OR pcrespue IS NULL
         OR psproduc IS NULL
         OR pcidioma IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      -- BUG26501 - 21/01/2014 - JTT: Passem el parametre npoliza
      vnumerr :=
         pac_productos.f_get_pregunrespue
                                (psproduc,
                                 pcpregun,
                                 pcrespue,
                                 pcidioma,
                                 RESULT,
                                 pac_iax_produccion.poliza.det_poliza.npoliza,
                                 pac_iax_produccion.poliza.det_poliza.cagente
                                );

      IF vnumerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN RESULT;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_get_pregunrespue;

   /***********************************************************************
      Devuelve el tipo de garantia
      param in psproduc  : codigo de producto
      param in pcgarant  : codigo de la garantia
      param out mensajes : mensajes de error
      return             : descripcion garantia
   ***********************************************************************/
   FUNCTION f_get_tipgar (
      psproduc   IN       NUMBER,
      pcgarant   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      RESULT     NUMBER;
      vsproduc   NUMBER;
      squery     VARCHAR2 (4000);
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (500)
                      := 'psproduc=' || psproduc || ', pcgarant=' || pcgarant;
      vobject    VARCHAR2 (200)  := 'PAC_MDPAR_PRODUCTOS.F_Get_TipGar';
   BEGIN
      --Inicialitzacions
      IF psproduc IS NULL OR pcgarant IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      squery :=
            'select ctipgar from garanpro g '
         || ' where g.cgarant='
         || pcgarant
         || '  and  g.sproduc='
         || psproduc;
      RESULT := pac_md_listvalores.f_getdescripvalor (squery, mensajes);
      RETURN RESULT;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_get_tipgar;

   /***********************************************************************
      Devuelve la lista de capitales por garantia
      param in psproduc  : codigo del producto
      param in pcactivi  : codigo de actividad
      param in cramo     : codigo ramo
      param in cmodali   : codigo modalidad
      param in ctipseg   : codigo tipo de seguro
      param in ccolect   : codigo de colectividad
      param in pcgarant  : codigo de garantia
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_garanprocap (
      psproduc   IN       NUMBER,
      pcactivi   IN       NUMBER,
      pcramo     IN       NUMBER,
      pcmodali   IN       NUMBER,
      pctipseg   IN       NUMBER,
      pccolect   IN       NUMBER,
      pcgarant   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN t_iaxpar_garanprocap
   IS
      CURSOR cprocap
      IS
         SELECT   norden, cramo, cmodali, ctipseg, ccolect, cgarant, cactivi,
                  icapital, cdefecto
             FROM garanprocap p
            WHERE p.cramo = pcramo
              AND p.cgarant = pcgarant
              AND p.cactivi = pcactivi
              AND p.ccolect = pccolect
              AND p.cmodali = pcmodali
              AND p.ctipseg = pctipseg
         UNION ALL
         SELECT   norden, cramo, cmodali, ctipseg, ccolect, cgarant, cactivi,
                  icapital, cdefecto
             FROM garanprocap p
            WHERE p.cramo = pcramo
              AND p.cgarant = pcgarant
              AND p.cactivi = 0
              AND p.ccolect = pccolect
              AND p.cmodali = pcmodali
              AND p.ctipseg = pctipseg
              AND NOT EXISTS (
                     SELECT 1 cdefecto
                       FROM garanprocap p1
                      WHERE p1.cramo = pcramo
                        AND p1.cgarant = pcgarant
                        AND p1.cactivi = pcactivi
                        AND p1.ccolect = pccolect
                        AND p1.cmodali = pcmodali
                        AND p1.ctipseg = pctipseg)
         ORDER BY 1;

      gar        t_iaxpar_garanprocap;
      vpasexec   NUMBER (8)           := 1;
      vparam     VARCHAR2 (1500)
         :=    'psproduc='
            || psproduc
            || ', pcactivi='
            || pcactivi
            || ', pcramo='
            || pcramo
            || ', pcmodali='
            || pcmodali
            || ', pctipseg='
            || pctipseg
            || ', pccolect='
            || pccolect
            || ', pcgarant='
            || pcgarant;
      vobject    VARCHAR2 (200)     := 'PAC_MDPAR_PRODUCTOS.F_Get_Garanprocap';
   BEGIN
      --Inicialitzacions
      IF psproduc IS NULL OR pcactivi IS NULL OR pcgarant IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      FOR cpcap IN cprocap
      LOOP
         IF gar IS NULL
         THEN
            gar := t_iaxpar_garanprocap ();
         END IF;

         gar.EXTEND;
         gar (gar.LAST) := ob_iaxpar_garanprocap ();
         gar (gar.LAST).icapital := cpcap.icapital;
         gar (gar.LAST).norden := cpcap.norden;
         gar (gar.LAST).cdefecto := cpcap.cdefecto;
      END LOOP;

      RETURN gar;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_get_garanprocap;

   /***********************************************************************
      Devuelve las garantias incompatibles
      param in psproduc  : codigo del producto
      param in pcactivi  : codigo de actividad
      param in pcramo    : codigo ramo
      param in pcmodali  : codigo modalidad
      param in pctipseg  : codigo tipo de seguro
      param in pccolect  : codigo de colectividad
      param in pcgarant  : codigo de garantia
      param out mensajes : mensajes de error
      return             : objeto actividades
   ***********************************************************************/
   FUNCTION f_get_incompgaran (
      psproduc   IN       NUMBER,
      pcactivi   IN       NUMBER,
      pcramo     IN       NUMBER,
      pcmodali   IN       NUMBER,
      pctipseg   IN       NUMBER,
      pccolect   IN       NUMBER,
      pcgarant   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN t_iaxpar_incompgaran
   IS
      v_cactivi   NUMBER (4);

      CURSOR cingar
      IS
         SELECT ingar.*
           FROM incompgaran ingar
          WHERE ingar.cactivi = v_cactivi
            AND ingar.ccolect = pccolect
            AND ingar.cgarant = pcgarant
            AND ingar.cmodali = pcmodali
            AND ingar.cramo = pcramo
            AND ingar.ctipseg = pctipseg;

      cincgar     t_iaxpar_incompgaran;
      vpasexec    NUMBER (8)           := 1;
      vparam      VARCHAR2 (1500)
         :=    'psproduc='
            || psproduc
            || ', pcactivi='
            || pcactivi
            || ', pcramo='
            || pcramo
            || ', pcmodali='
            || pcmodali
            || ', pctipseg='
            || pctipseg
            || ', pccolect='
            || pccolect
            || ', pcgarant='
            || pcgarant;
      vobject     VARCHAR2 (200)    := 'PAC_MDPAR_PRODUCTOS.F_Get_Incompgaran';
   BEGIN
      --Inicialitzacions
      IF psproduc IS NULL OR pcactivi IS NULL OR pcgarant IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      --BUG9748 - 09/04/2009 - JTS - IAX -ACTIVIDAD - Selects contra INCOMPAGARAN, tener en cuenta la actividad
      SELECT DECODE (COUNT (*), 0, 0, pcactivi)
        INTO v_cactivi
        FROM garanpro
       WHERE cramo = pcramo
         AND ccolect = pccolect
         AND cmodali = pcmodali
         AND cgarant = pcgarant
         AND cactivi = pcactivi;

      --Fi BUG9748
      FOR cgar IN cingar
      LOOP
         IF cincgar IS NULL
         THEN
            cincgar := t_iaxpar_incompgaran ();
         END IF;

         cincgar.EXTEND;
         cincgar (cincgar.LAST) := ob_iaxpar_incompgaran ();
         cincgar (cincgar.LAST).cgarant := cgar.cgarant;
         cincgar (cincgar.LAST).cgarinc := cgar.cgarinc;
      END LOOP;

      RETURN cincgar;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_get_incompgaran;

   /***********************************************************************
      Devuelve las actividades definidas en el producto
      param in psproduc  : codigo del producto
      param in pcramo    : codigo ramo
      param in pcmodali  : codigo modalidad
      param in pctipseg  : codigo tipo de seguro
      param in pccolect  : codigo de colectividad
      param out mensajes : mensajes de error
      return             : objeto actividades
   ***********************************************************************/
   FUNCTION f_get_actividades (
      psproduc   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN t_iaxpar_actividades
   IS
      CURSOR cactv
      IS
         SELECT   activisegu.tactivi, activisegu.cactivi
             FROM productos p, activiprod INNER JOIN activisegu
                  ON activiprod.cactivi = activisegu.cactivi
                AND activiprod.cramo = activisegu.cramo
            WHERE p.sproduc = psproduc
              AND activiprod.ccolect = p.ccolect
              AND activisegu.cidioma = pac_md_common.f_get_cxtidioma
              AND activiprod.cmodali = p.cmodali
              AND activiprod.cramo = p.cramo
              AND activiprod.ctipseg = p.ctipseg
         ORDER BY activisegu.cactivi;

      activ      t_iaxpar_actividades;
      vpasexec   NUMBER (8)           := 1;
      vparam     VARCHAR2 (500)       := 'psproduc=' || psproduc;
      vobject    VARCHAR2 (200)     := 'PAC_MDPAR_PRODUCTOS.F_Get_Actividades';
   BEGIN
      --Inicialitzacions
      IF psproduc IS NULL
      THEN
          -- BUG 0023615 - JMF - 18/09/2012
         -- RAISE e_param_error;
         RETURN NULL;
      END IF;

      FOR cact IN cactv
      LOOP
         IF activ IS NULL
         THEN
            activ := t_iaxpar_actividades ();
         END IF;

         activ.EXTEND;
         activ (activ.LAST) := ob_iaxpar_actividades ();
         activ (activ.LAST).cactivi := cact.cactivi;
         activ (activ.LAST).tactivi := cact.tactivi;
         activ (activ.LAST).garantias := NULL;
      END LOOP;

      RETURN activ;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_get_actividades;

   /*************************************************************************
      Recupera las posibles causas de anulacion de polizas de un determinado producto
      param in psproduc  : codigo del producto
      return             : refcursor
   *************************************************************************/
   FUNCTION f_get_causaanulpol (
      psproduc   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (500) := 'parametros - psproduc: ' || psproduc;
      vobject    VARCHAR2 (200) := 'PAC_MDPAR_PRODUCTOS.F_Get_CausaAnulPol';
   BEGIN
      -- Inicialitzacions
      IF psproduc IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      cur :=
         pac_md_listvalores.f_opencursor
            (   'SELECT cmotmov ccauanula, tmotmov tcauanula '
             || ' FROM motmovseg '
             || ' WHERE cidioma='
             || pac_md_common.f_get_cxtidioma ()
             || ' AND cmotmov IN (SELECT cmotmov '
             || '                 FROM   codimotmov '
             || '                 WHERE  cactivo = 1 '
             || '                 AND    cgesmov = 0 '
             || '                 AND    cmovseg = 3 '
             || '                 AND    cmotmov in (select cmotmov from prodmotmov where sproduc = '
             || psproduc
             || ')) '
             || ' ORDER BY cmotmov ',
             mensajes
            );
      RETURN cur;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_causaanulpol;

--------------------------------------------------------------------------------
-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- BUG 9686 - 24/04/2009 - FAL - Parametrizar causas de anulacion de poliza en funcion del tipo de baja
   /*************************************************************************
      Recupera las posibles causas de anulacion de polizas de un determinado producto
      param in psproduc  : codigo del producto
      param in pctipbaja : tipo de baja
      return             : refcursor
   *************************************************************************/
   FUNCTION f_get_causaanulpol (
      psproduc    IN       NUMBER,
      pctipbaja   IN       NUMBER,
      mensajes    IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (500)
         :=    'parametros - psproduc: '
            || psproduc
            || ' - pctipbaja: '
            || pctipbaja;
      vobject    VARCHAR2 (200) := 'PAC_MDPAR_PRODUCTOS.F_Get_CausaAnulPol';
   BEGIN
      -- Inicialitzacions
      IF psproduc IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      cur :=
         pac_md_listvalores.f_opencursor
            (   'SELECT cmotmov ccauanula, tmotmov tcauanula '
             || ' FROM motmovseg '
             || ' WHERE cidioma='
             || pac_md_common.f_get_cxtidioma ()
             || ' AND cmotmov IN (SELECT cmotmov '
             || '                 FROM   codimotmov '
             || '                 WHERE  cactivo = 1 '
             || '                 AND    cgesmov = 0 '
             || '                 AND    cmovseg = 3 '
             || '                 AND    cmotmov in (select P.cmotmov from prodmotmov P, causanul C '
             || '                                    where P.sproduc = C.sproduc and P.cmotmov = C.cmotmov and '
             || '                                          P.sproduc = '
             || psproduc
             || ' and '
             || '                                          C.ctipbaja = '
             || pctipbaja
             || ')) '
             || ' ORDER BY cmotmov ',
             mensajes
            );
      RETURN cur;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_causaanulpol;

   -- FI BUG 9686 - 24/04/2009 - FAL

   -->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
--------------------------------------------------------------------------------

   /*************************************************************************
      Recupera las posibles causas de siniestros de polizas de un determinado producto
      param in psproduc  : codigo del producto
      return             : refcursor
   *************************************************************************/
   FUNCTION f_get_causasini (psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (500) := 'parametros - psproduc: ' || psproduc;
      vobject    VARCHAR2 (200) := 'PAC_MDPAR_PRODUCTOS.F_Get_CausaSini';
   BEGIN
      IF psproduc IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      cur :=
         pac_md_listvalores.f_opencursor
                   (   'SELECT DISTINCT ca.ccausin,  ca.tcausin '
                    || '  FROM causasini ca, codmotsini cm, prodcaumotsin p '
                    || ' WHERE ca.cidioma = '
                    || pac_md_common.f_get_cxtidioma ()
                    || '   AND ca.ccausin = cm.ccausin '
                    || '   AND cm.ccausin = p.ccausin '
                    || '   AND p.sproduc = '
                    || psproduc
                    || ' ORDER BY ca.ccausin',
                    mensajes
                   );
      RETURN cur;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_causasini;

   /*************************************************************************
      Recupera lista con los motivos de siniestros por producto
      param in psproduc  : codigo del producto
      param in pccausa   : codigo causa de siniestro
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_motivossini (
      psproduc   IN       NUMBER,
      pccausa    IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (200)
           := 'parametros - psproduc:' || psproduc || ', pccausa:' || pccausa;
      vobject    VARCHAR2 (50)  := 'PAC_IAXPAR_PRODUCTOS.F_Get_MotivosSini';
      vsquery    VARCHAR2 (500);
      vcursor    sys_refcursor;
   BEGIN
      -- Comprovacio pas de parametres
      IF psproduc IS NULL OR pccausa IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vsquery :=
            'SELECT DISTINCT C.CMOTSIN,D.TMOTSIN,C.CCAUSIN'
         || '  FROM CODMOTSINI C, DESMOTSINI D, PRODCAUMOTSIN P'
         || ' WHERE D.CIDIOMA = '
         || pac_md_common.f_get_cxtidioma
         || '   AND D.CMOTSIN = C.CMOTSIN'
         || '   AND D.CCAUSIN = C.CCAUSIN'
         || '   AND D.CRAMO   = C.CRAMO'
         || '   AND C.CCAUSIN = '
         || pccausa
         || '   AND P.CRAMO   = C.CRAMO'
         || '   AND P.CMOTSIN = C.CMOTSIN'
         || '   AND P.CCAUSIN = C.CCAUSIN'
         || '   AND P.SPRODUC = '
         || psproduc
         || ' ORDER BY C.CMOTSIN';
      vpasexec := 3;
      vcursor := pac_md_listvalores.f_opencursor (vsquery, mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );

         IF vcursor%ISOPEN
         THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );

         IF vcursor%ISOPEN
         THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );

         IF vcursor%ISOPEN
         THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
   END f_get_motivossini;

   /*************************************************************************
      Comproba si el producto tiene asociado preguntas y de que nivel son
      param in psproduc  : codigo de producto
      param in pcactivi  : codigo de actividad (puede se nula)
      param in pcgarant  : codigo de la garantia (puede se nula)
      param in nivelPreg : P poliza - R riesgo - G garantia
      param out mensajes : mensajes de error
      return             : 0 no tiene preguntas del nivel
                           1 tiene preguntas del nivel
   *************************************************************************/
   FUNCTION f_get_prodtienepreg (
      psproduc    IN       NUMBER,
      pcactivi    IN       NUMBER,
      pcgarant    IN       NUMBER,
      nivelpreg   IN       VARCHAR2,
      mensajes    IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (500)
         :=    'psproduc='
            || psproduc
            || ', pcactivi='
            || pcactivi
            || ', pcgarant='
            || pcgarant
            || ', nivelPreg='
            || nivelpreg;
      vobject    VARCHAR2 (200) := 'PAC_MDPAR_PRODUCTOS.F_Get_ProdTienePreg';
      ncount     NUMBER;
      vnumerr    NUMBER (8)     := 0;
   BEGIN
      -- Inicialitzacions
      IF    psproduc IS NULL
         OR nivelpreg IS NULL
         OR (pcactivi IS NULL AND nivelpreg IN ('R', 'G'))
         OR (pcgarant IS NULL AND nivelpreg = 'G')
      THEN
         RAISE e_param_error;
      END IF;

      IF nivelpreg = 'P'
      THEN
         vnumerr :=
            pac_productos.f_get_prodtienepregp
                                              (psproduc,
                                               pac_md_common.f_get_cxtidioma,
                                               ncount
                                              );
      ELSIF nivelpreg = 'R'
      THEN
         vnumerr :=
            pac_productos.f_get_prodtienepregr
                                              (psproduc,
                                               pcactivi,
                                               pac_md_common.f_get_cxtidioma,
                                               ncount
                                              );
      ELSIF nivelpreg = 'G'
      THEN
         vnumerr :=
            pac_productos.f_get_prodtienepregg
                                              (psproduc,
                                               pcactivi,
                                               pcgarant,
                                               pac_md_common.f_get_cxtidioma,
                                               ncount
                                              );
      END IF;

      IF vnumerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      IF ncount > 0
      THEN
         RETURN 1;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN 0;
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 0;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 0;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 0;
   END f_get_prodtienepreg;

   /*************************************************************************
      Recupera los valores de revalorizacion a nivel de producto
      param int psproduc : codigo de producto
      param out pcrevali : codigo de revalorizacion
      param out pprevali : valor de la revalorizacion
      param out mensajes : mensajes de error
   *************************************************************************/
   PROCEDURE p_revalprod (
      psproduc   IN       NUMBER,
      pcrevali   OUT      NUMBER,
      pprevali   OUT      NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
   IS
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (500) := 'psproduc=' || psproduc;
      vobject    VARCHAR2 (200) := 'PAC_MDPAR_PRODUCTOS.P_RevalProd';
      ncount     NUMBER;
      vnumerr    NUMBER (8)     := 0;
   BEGIN
      -- Inicialitzacions
      IF psproduc IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_productos.f_revalprod (psproduc, pcrevali, pprevali);

      IF vnumerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
   END p_revalprod;

   /*************************************************************************
      Indica si el producto permite modificar la revalorizacion en contratacion
      param in  psproduc : codigo de producto
      param out mensajes : mensajes de error
      return : 1 se permite
               0 no se permite
   *************************************************************************/
   FUNCTION f_permitirrevalprod (
      psproduc   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vcrevali   productos.crevali%TYPE;
      vprevali   productos.prevali%TYPE;
      vpermite   NUMBER (8)               := 0;
      vpasexec   NUMBER (8)               := 1;
      vparam     VARCHAR2 (500)           := 'psproduc=' || psproduc;
      vobject    VARCHAR2 (200)  := 'PAC_MDPAR_PRODUCTOS.f_permitirrevalprod';
      vnumerr    NUMBER (8)               := 0;
   BEGIN
      -- Inicialitzacions
      IF psproduc IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      vpermite :=
         NVL (pac_parametros.f_parproducto_n (psproduc, 'PERMITE_MODIF_REVAL'),
              0
             );
      RETURN vpermite;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 0;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 0;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 0;
   END f_permitirrevalprod;

   /*************************************************************************
      Recupera los valores de revalorizacion a nivel de garantia
      param in psproduc  : codigo de producto
      param in pcactivi  : codigo de actividad
      param in pcgarant  : codigo de garantia
      param in pcrevalipol : codigo de revalorizacion de la poliza
      param in pprevalipol : porcetaje de la revalorizacion de la poliza
      param in pirevalipol : importe de la revalorizacion de la poliza
      param out pcrevali : codigo de revalorizacion
      param out pprevali : valor de la revalorizacion
      param out mensajes : mensajes de error
   *************************************************************************/
   PROCEDURE p_revalgar (
      psproduc      IN       NUMBER,
      pcactivi      IN       NUMBER,
      pcgarant      IN       NUMBER,
      pcrevalipol   IN       NUMBER,                 -- BUG9906:DRA:29/04/2009
      pprevalipol   IN       NUMBER,                 -- BUG9906:DRA:29/04/2009
      pirevalipol   IN       NUMBER,                 -- BUG9906:DRA:29/04/2009
      pcrevali      OUT      NUMBER,
      pprevali      OUT      NUMBER,
      pirevali      OUT      NUMBER,                 -- BUG9906:DRA:28/04/2009
      mensajes      IN OUT   t_iax_mensajes
   )
   IS
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (500)
         :=    'psproduc='
            || psproduc
            || ', pcactivi='
            || pcactivi
            || ', pcgarant='
            || pcgarant
            || ', pcrevalipol='
            || pcrevalipol
            || ', pprevalipol='
            || pprevalipol
            || ', pirevalipol='
            || pirevalipol;
      vobject    VARCHAR2 (200) := 'PAC_MDPAR_PRODUCTOS.P_RevalGar';
      ncount     NUMBER;
      vnumerr    NUMBER (8)     := 0;
   BEGIN
      -- Inicialitzacions
      IF psproduc IS NULL OR pcactivi IS NULL OR pcgarant IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      -- BUG9906:DRA:29/04/2009:Inici
      vnumerr :=
         pac_productos.f_get_revalgar (psproduc,
                                       pcactivi,
                                       pcgarant,
                                       pcrevalipol,
                                       pprevalipol,
                                       pirevalipol,
                                       pcrevali,
                                       pprevali,
                                       pirevali
                                      );

      -- BUG9906:DRA:29/04/2009:Fi
      IF vnumerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
   END p_revalgar;

   /*************************************************************************
      Recupera la documentacion necesaria para poder realizar un determinado
      movimiento en una poliza de un determinado producto.
      param in  psproduc   : codigo del producto
      param in  pcmotmov   : codigo del motivo del movimiento.
      param in  pctipdoc   : Tipo de documentacion a recuperar (0->opcional, 1->obligatoria, NULL->toda)
      param in  pcidioma   : Codigo del idioma para la descripcion de la documentacion.
      param out mensajes   : mensajes de error
      return    refcuror   : informacion de la documentacion necesaria.
   *************************************************************************/
   FUNCTION f_get_documnecmov (
      psproduc   IN       NUMBER,
      pcmotmov   IN       NUMBER,
      pctipdoc   IN       NUMBER,
      pcidioma   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      vobjectname   VARCHAR2 (500) := 'PAC_IAXMD_PRODUCTOS.F_Get_DocumNecMov';
      vparam        VARCHAR2 (500)
         :=    'parametros - psproduc: '
            || psproduc
            || ' -  pctipdoc: '
            || pctipdoc
            || ' - pcmotmov: '
            || pcmotmov
            || ' - pcidioma: '
            || pcidioma;
      vpasexec      NUMBER (5)      := 1;
      vnumerr       NUMBER (8)      := 0;
      vsquery       VARCHAR2 (1000);
      vcursor       sys_refcursor;
   BEGIN
      --Comprovacio dels parametres d'entrada
      IF psproduc IS NULL OR pcmotmov IS NULL OR pcidioma IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      --Generacio de la consulta per recuperar la informacio necessaria
      vsquery :=
            'SELECT dp.cdocument, d.tdocument, dp.nversion, p.sproduc, dp.cmotmov, dp.ctipdoc, dv.tatribu ttipdoc'
         || '  FROM productos p, documentpro dp, document d, detvalores dv '
         || ' WHERE p.sproduc = '
         || psproduc
         || '   AND p.cramo = dp.cramo '
         || '   AND p.cmodali = dp.cmodali '
         || '   AND p.ctipseg = dp.ctipseg '
         || '   AND p.ccolect = dp.ccolect '
         || '   AND dp.fbaja IS NULL '
         || '   AND dp.cmotmov = '
         || pcmotmov
         || '   AND (dp.ctipdoc = '
         || NVL (pctipdoc, -1)
         || ' OR '
         || NVL (pctipdoc, -1)
         || ' = -1) '
         || '   AND dp.cdocument = d.cdocument '
         || '   AND dp.nversion = d.nversion '
         || '   AND d.cidioma = '
         || pcidioma
         || '   AND dv.cvalor = 108 '
         || '   AND dv.cidioma = d.cidioma '
         || '   AND dp.ctipdoc = dv.catribu '
         || ' ORDER BY dp.norden ASC';
      --Recuperacio de la documentacio necessaria pel moviment.
      vcursor := pac_md_listvalores.f_opencursor (vsquery, mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobjectname,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );

         IF vcursor%ISOPEN
         THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobjectname,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            NULL,
                                            SQLCODE,
                                            SQLERRM
                                           );

         IF vcursor%ISOPEN
         THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
   END f_get_documnecmov;

   FUNCTION f_get_descpregun (
      pcpregun   IN       NUMBER,
      pcidioma   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN VARCHAR2
   IS
      v_error    NUMBER;
      v_result   VARCHAR2 (300);
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (500)
                      := 'pcpregun=' || pcpregun || ', pcidioma=' || pcidioma;
      vobject    VARCHAR2 (200) := 'PAC_MDPAR_PRODUCTOS.F_Get_DescPregun';
      ncount     NUMBER;
   BEGIN
      -- Inicialitzacions
      IF pcpregun IS NULL OR pcidioma IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      v_error := f_despregunta (pcpregun, pcidioma, v_result);

      IF v_error <> 0
      THEN
         RAISE e_param_error;
      ELSE
         RETURN v_result;
      END IF;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END;

   --JRH 03/2008 Obtener los periodos de revision
   /*************************************************************************
        Recupera los periodos de revision por producto
        param in  psproduc   : codigo del producto
        param in  pcidioma   : Codigo del idioma para la descripcion de la documentacion.
        param out mensajes   : mensajes de error
        return    refcuror   : informacion de los periodos de revision posibles del producto.
     *************************************************************************/
   FUNCTION f_get_perrevision (
      psproduc   IN       productos.sproduc%TYPE,
      pcidioma   IN       idiomas.cidioma%TYPE,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      vobjectname   tab_error.tdescrip%TYPE
                                   := 'PAC_MDPAR_PRODUCTOS.F_Get_PerRevision';
      vparam        tab_error.tobjeto%TYPE
         := 'parametros - psproduc: ' || psproduc || ' - pcidioma: '
            || pcidioma;
      vpasexec      NUMBER (5)                := 1;
      vnumerr       NUMBER (8)                := 0;
      vsquery       VARCHAR2 (1000);
      vcursor       sys_refcursor;
   BEGIN
      --Comprovacio dels parametres d'entrada
      IF psproduc IS NULL OR pcidioma IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      --Generacio de la consulta per recuperar la informacio necessaria
      vsquery :=
            'SELECT dp.ndurper, dp.ndurper'
         || '  FROM durperiodoprod dp'
         || ' WHERE dp.sproduc = '
         || psproduc
         || '   AND dp.finicio <= F_SYSDATE '
         || '   AND ((dp.ffin  IS NULL) OR (dp.ffin  IS NOT  NULL AND dp.ffin > F_SYSDATE))'
         || ' ORDER BY dp.ndurper ASC';
      --Recuperacio de la documentacio necessaria pel moviment.
      vcursor := pac_md_listvalores.f_opencursor (vsquery, mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobjectname,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );

         IF vcursor%ISOPEN
         THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobjectname,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            NULL,
                                            SQLCODE,
                                            SQLERRM
                                           );

         IF vcursor%ISOPEN
         THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
   END f_get_perrevision;

   --JRH 03/2008

   --JRH 03/2008 Obtener formas de pago de las rentas
   /*************************************************************************
        Recupera los periodos de revision por producto
        param in  psproduc   : codigo del producto
        param in  pcidioma   : Codigo del idioma para la descripcion de la documentacion.
        param out mensajes   : mensajes de error
        return    refcuror   :  informacion de las formas de pago del producto.
     *************************************************************************/
   FUNCTION get_forpagren (
      psproduc   IN       productos.sproduc%TYPE,
      pcidioma   IN       idiomas.cidioma%TYPE,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      vobjectname   tab_error.tdescrip%TYPE
                                       := 'PAC_MDPAR_PRODUCTOS.Get_ForPagRen';
      vparam        tab_error.tobjeto%TYPE
         := 'parametros - psproduc: ' || psproduc || ' - pcidioma: '
            || pcidioma;
      vpasexec      NUMBER (5)                := 1;
      vnumerr       NUMBER (8)                := 0;
      vsquery       VARCHAR2 (1000);
      vcursor       sys_refcursor;
   BEGIN
      --Comprovacio dels parametres d'entrada
      IF psproduc IS NULL OR pcidioma IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      --Generacio de la consulta per recuperar la informacio necessaria
      vsquery :=
            'SELECT d.catribu , d.tatribu '
         || ' from     DETVALORES D, forpagren f'
         || ' WHERE '
         || '     f.cforpag = d.catribu '
         || '    AND d.cidioma =  '
         || pcidioma
         || '    AND f.sproduc =  '
         || psproduc
         || '    AND d.cvalor = 17 '
         || ' ORDER BY d.catribu';
      vpasexec := 4;
      --Recuperacio de la documentacio necessaria pel moviment.
      vcursor := pac_md_listvalores.f_opencursor (vsquery, mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobjectname,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );

         IF vcursor%ISOPEN
         THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobjectname,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            NULL,
                                            SQLCODE,
                                            SQLERRM
                                           );

         IF vcursor%ISOPEN
         THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
   END get_forpagren;

     --JRH 03/2008
     --JRH 03/2008 Obtener los a?posibles para las rentas irregulares
   /*************************************************************************
        Recupera los periodos de revision por producto
        param in  psproduc   : codigo del producto
        param in  pcidioma   : Codigo del idioma para la descripcion de la documentacion.
        param out mensajes   : mensajes de error
        return    refcuror   :  informacion de las formas de pago del producto.
     *************************************************************************/
   FUNCTION get_anyosrentasirreg (
      psproduc   IN       productos.sproduc%TYPE,
      pcidioma   IN       idiomas.cidioma%TYPE,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      vobjectname   tab_error.tdescrip%TYPE
                                := 'PAC_MDPAR_PRODUCTOS.Get_AnyosRentasIrreg';
      vparam        tab_error.tobjeto%TYPE
         := 'parametros - psproduc: ' || psproduc || ' - pcidioma: '
            || pcidioma;
      vpasexec      NUMBER (5)                := 1;
      vnumerr       NUMBER (8)                := 0;
-- Ini Bug 16803 - SRA - 30/11/2010: aumentamos el tama?el string que almacena la query dinamica
      vsquery       VARCHAR2 (4000);
      vsquery2      VARCHAR2 (4000);
-- Fin Bug 16803 - SRA - 30/11/2010
      vcursor       sys_refcursor;
      anyo          NUMBER;
      panyo         NUMBER;
   BEGIN
      --Comprovacio dels parametres d'entrada
      IF psproduc IS NULL OR pcidioma IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      anyo := TO_CHAR (f_sysdate, 'YYYY');

      --Generacio de la consulta per recuperar la informacio necessaria. De momento sacamos 20 valores.
-- Ini Bug 16803 - SRA - 30/11/2010: aumentamos a 80 a?(antes era 20) el rango de a?seleccionables para las resntas irregulares
      FOR i IN 0 .. 80
      LOOP
         panyo := anyo + i;

         IF i = 0
         THEN
            vsquery :=
                  'select '
               || panyo
               || ' codigo,'
               || panyo
               || ' descripcion from dual ';
         ELSE
            vsquery := 'select ' || panyo || ',' || panyo || ' from dual ';
         END IF;

         IF i <> 80
         THEN
-- Fin Bug 16803 - SRA - 30/11/2010
            vsquery2 := vsquery2 || vsquery || ' UNION ';
         ELSE
            vsquery2 := vsquery2 || vsquery;
         END IF;
      END LOOP;

      vpasexec := 5;
      --Recuperacio de la documentacio necessaria pel moviment.
      vcursor := pac_md_listvalores.f_opencursor (vsquery2, mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobjectname,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );

         IF vcursor%ISOPEN
         THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobjectname,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            NULL,
                                            SQLCODE,
                                            SQLERRM
                                           );

         IF vcursor%ISOPEN
         THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
   END get_anyosrentasirreg;

   --JRH 03/2008

   --JRH 03/2008
   /***********************************************************************
      Devuelve el parametro de garantia especificado
      param in clave: El nombre del parametro
      psproduc in clave: El producto
      pgarant in clave: La garantia
      return   : valor del parametro
   ***********************************************************************/
   FUNCTION f_get_pargarantia (
      clave      IN   VARCHAR2,
      psproduc   IN   productos.sproduc%TYPE,
      pgarant    IN   NUMBER,
      pcactivi   IN   NUMBER DEFAULT 0
   )                                         -- BUG 0036730 - FAL - 09/12/2015
      RETURN NUMBER
   IS
      mensajes   t_iax_mensajes;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (500)
         :=    'clave='
            || clave
            || ', psproduc='
            || psproduc
            || ', pgarant='
            || pgarant;
      vobject    VARCHAR2 (200) := 'PAC_MDPAR_PRODUCTOS.F_Get_ParGarantia';
      paramgar   VARCHAR2 (200);
      vnumerr    NUMBER (8)     := 0;
   BEGIN
      --Comprovacio de parametres d'entrada
      IF clave IS NULL OR psproduc IS NULL OR pgarant IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vnumerr :=
         pac_productos.f_get_pargarantia (clave,
                                          psproduc,
                                          pgarant,
                                          paramgar,
                                          pcactivi
                                         );  -- BUG 0036730 - FAL - 09/12/2015

      IF vnumerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN NVL (paramgar, 0);
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 0;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 0;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 0;
   END f_get_pargarantia;

   /***********************************************************************
      Devuelve el objeto producto
      param in sproduc : Codigo producto
      return   : objeto productos
   ***********************************************************************/
   FUNCTION f_get_producto (psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN ob_iaxpar_productos
   IS
      CURSOR cprod (prod NUMBER)
      IS
         SELECT *
           FROM productos
          WHERE sproduc = prod;

      prod       ob_iaxpar_productos := ob_iaxpar_productos ();
      garant     t_iaxpar_garantias;
      vpasexec   NUMBER (8)          := 1;
      vparam     VARCHAR2 (500)      := 'psproduc=' || psproduc;
      vobject    VARCHAR2 (200)      := 'PAC_MDPAR_PRODUCTOS.F_Get_Producto';
      nerr       NUMBER;
   BEGIN
      FOR c IN cprod (psproduc)
      LOOP
         prod.sproduc := psproduc;
         prod.cramo := c.cramo;
         prod.cmodali := c.cmodali;
         prod.ctipseg := c.ctipseg;
         prod.ccolect := c.ccolect;
         prod.ctiprie := c.ctiprie;
         prod.csubpro := c.csubpro;
         prod.cobjase := c.cobjase;
         prod.crevali := c.crevali;
         prod.cdivisa := c.cdivisa;

         BEGIN
            nerr :=
               f_desproducto (c.cramo,
                              c.cmodali,
                              1,
                              pac_md_common.f_get_cxtidioma,
                              prod.descripcion,
                              c.ctipseg,
                              c.ccolect
                             );

            IF nerr <> 0
            THEN
               prod.descripcion := '';
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               prod.descripcion := '';
         END;

         -- Actividades
         BEGIN
            prod.actividades := NULL;
         EXCEPTION
            WHEN OTHERS
            THEN
               -- NO PUEDE RECUPERAR ACTIVIDADES
               NULL;
         END;                                                   -- Actividades

         -- Preguntas
         BEGIN
            prod.preguntas := NULL;
         EXCEPTION
            WHEN OTHERS
            THEN
               -- NO PUEDE RECUPERAR PREGUNTAS
               NULL;
         END;                                                     -- Preguntas

         -- Clausulas
         BEGIN
            prod.clausulas := NULL;
         EXCEPTION
            WHEN OTHERS
            THEN
               -- NO PUEDE RECUPERAR CLAUSULAS
               NULL;
         END;                                                     -- Clausulas
      END LOOP;

      RETURN prod;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_get_producto;

    --JRB 04/2008
   /***********************************************************************
      Devuelve la descripcion del producto
      param in sproduc : Codigo producto
      param in ptipdesc: Tipo descripcion
      return   : descripcion del producto
   ***********************************************************************/
   FUNCTION f_get_descproducto (
      psproduc   IN       productos.sproduc%TYPE,
      ptipdesc   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN VARCHAR2
   IS
      texto       VARCHAR2 (100);
      nerr        NUMBER;
      vpasexec    NUMBER (8)     := 1;
      vparam      VARCHAR2 (500)
                      := 'psproduc=' || psproduc || ', ptipdesc=' || ptipdesc;
      vobject     VARCHAR2 (200) := 'PAC_MDPAR_PRODUCTOS.F_Get_DescProducto';
      vcramo      NUMBER;
      vcmodali    NUMBER;
      vctipseg    NUMBER;
      vccollect   NUMBER;
   BEGIN
      --Comprovacio dels parametres d'entrada
      IF psproduc IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      nerr :=
         pac_mdpar_productos.f_get_identprod (psproduc,
                                              vcramo,
                                              vcmodali,
                                              vctipseg,
                                              vccollect,
                                              mensajes
                                             );

      --IF prdId is null THEN RETURN NULL; END IF;
      --IF prdId.count=0 THEN RETURN NULL; END IF;
      IF nerr <> 0
      THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 4;
      nerr :=
         f_desproducto (vcramo,
                        vcmodali,
                        ptipdesc,
                        pac_md_common.f_get_cxtidioma,
                        texto,
                        vctipseg,
                        vccollect
                       );

      IF nerr <> 0
      THEN
         RAISE e_object_error;
      END IF;

      RETURN texto;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_get_descproducto;

   /***********************************************************************
      Devuelve las garantias de un determinado producto - actividad.
      Si se informa el parametro "pcgarant", se excluye la garantia pasada
      por parametro de la lista de garantias retornadas.
      param in psproduc  : codigo del producto
      param in pcactivi  : codigo de actividad
      param in pcgarant  : codigo de garantia
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_lstgarantias (
      psproduc   IN       productos.sproduc%TYPE,
      pcactivi   IN       activisegu.cactivi%TYPE,
      pcgarant   IN       garanpro.cgarant%TYPE,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      vpasexec    NUMBER (8)     := 1;
      vnumerr     NUMBER (8)     := 0;
      vparam      VARCHAR2 (500)
         :=    'parametros - psproduc:'
            || psproduc
            || ' - pcactivi:'
            || pcactivi
            || ' - pcgarant:'
            || pcgarant;
      vobject     VARCHAR2 (200) := 'PAC_MDPAR_PRODUCTOS.F_Get_LstGarantias';
      vsquery     VARCHAR2 (500);
      vcursor     sys_refcursor;
      v_cgarant   NUMBER;
      v_tgarant   VARCHAR2 (500);
   BEGIN
      -- Comprovacio pas de parametres
      IF psproduc IS NULL OR pcactivi IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      vsquery :=
            'SELECT gp.cgarant, lpad(gp.cgarant,2,''0'')||''-''||gg.tgarant "tgaran" '
         || '  FROM garanpro gp, garangen gg '
         || ' WHERE gp.sproduc = '
         || psproduc
         || '   AND gp.cactivi = '
         || pcactivi;

      IF pcgarant IS NOT NULL
      THEN
         vsquery := vsquery || '   AND gp.cgarant <> ' || pcgarant;
      END IF;

      vsquery :=
            vsquery
         || '   AND gp.cgarant = gg.cgarant '
         || '   AND gg.cidioma = '
         || pac_md_common.f_get_cxtidioma ()
         || ' ORDER BY norden ';
      vpasexec := 5;
      vcursor := pac_md_listvalores.f_opencursor (vsquery, mensajes);

      -- Bug 9699 - APD - 24/04/2009 - Se abre el cursor para saber si la select devuelve registros
      -- primero se ha de buscar para la actividad en concreto
      -- y si no se encuentra nada ir a buscar a GARANPRO para la actividad cero
      FETCH vcursor
       INTO v_cgarant, v_tgarant;

      vpasexec := 6;

      IF vcursor%NOTFOUND
      THEN
         vsquery :=
               'SELECT gp.cgarant, lpad(gp.cgarant,2,''0'')||''-''||gg.tgarant "tgaran" '
            || '  FROM garanpro gp, garangen gg '
            || ' WHERE gp.sproduc = '
            || psproduc
            || '   AND gp.cactivi = 0';

         IF pcgarant IS NOT NULL
         THEN
            vsquery := vsquery || '   AND gp.cgarant <> ' || pcgarant;
         END IF;

         vsquery :=
               vsquery
            || '   AND gp.cgarant = gg.cgarant '
            || '   AND gg.cidioma = '
            || pac_md_common.f_get_cxtidioma ()
            || ' ORDER BY norden ';
         vpasexec := 7;
         vcursor := pac_md_listvalores.f_opencursor (vsquery, mensajes);
      END IF;

      vpasexec := 8;

      -- Bug 9699 - APD - 24/04/2009 - Se cierra el cursor y se vuelve a abrir para que
      -- no se pierda el primer registro del cursor
      CLOSE vcursor;

      vcursor := pac_md_listvalores.f_opencursor (vsquery, mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );

         IF vcursor%ISOPEN
         THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );

         IF vcursor%ISOPEN
         THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );

         IF vcursor%ISOPEN
         THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
   END f_get_lstgarantias;

   /***********************************************************************
      Devuelve el codigo de CDURMIN del producto
      param in sproduc : Codigo producto
      return           : cdurmin del producto
   ***********************************************************************/
   FUNCTION f_get_cdurmin (psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER
   IS
      vpasexec    NUMBER (8)    := 1;
      vparam      VARCHAR2 (50) := 'psproduc=' || psproduc;
      vobject     VARCHAR2 (50) := 'PAC_MDPAR_PRODUCTOS.F_Get_CDurMin';
      v_cdurmin   NUMBER (1);
      nerr        NUMBER (10);
   BEGIN
      --Comprovacio dels parametres d'entrada
      IF psproduc IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      nerr := pac_productos.f_get_cdurmin (psproduc, v_cdurmin);

      IF nerr <> 0
      THEN
         RAISE e_object_error;
      END IF;

      RETURN v_cdurmin;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_get_cdurmin;

   /***********************************************************************
      Recupera la agrupacion del producto buscandola por el SPRODUC (si el
      param. no es null), o bien por CRAMO, CMODALI, CTIPSEG y CCOLECT.
      param in psseguro  : codigo de seguro
      param out mensajes : mensajes de error
      return             : codigo de agrupacion
   ***********************************************************************/
   FUNCTION f_get_agrupacio (
      p_sseguro   IN       NUMBER,
      mensajes    IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vobjectname   VARCHAR2 (50) := 'PAC_MD_SINIESTROS.F_Get_Agrupacio';
      vparam        VARCHAR2 (50) := 'parametros - p_sseguro: ' || p_sseguro;
      vpasexec      NUMBER (2)    := 1;
      vnumerr       NUMBER (8);
      vsproduc      NUMBER (6);
      vcagrpro      NUMBER (2);
   BEGIN
      --Comprovacio dels parametres d'entrada
      IF p_sseguro IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vnumerr := pac_productos.f_get_sproduc (p_sseguro, vsproduc);

      IF vnumerr <> 0
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      vnumerr :=
         pac_productos.f_get_agrupacio (vsproduc,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        vcagrpro
                                       );

      IF vnumerr <> 0
      THEN
         RAISE e_param_error;
      END IF;

      RETURN vcagrpro;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobjectname,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobjectname,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            NULL,
                                            SQLCODE,
                                            SQLERRM
                                           );
         RETURN NULL;
   END f_get_agrupacio;

   /*************************************************************************
      Devuelve objeto registro con las pk de producto
      param in psproduc      : codigo de producto
      param in pcramo
      param in pcmodali
      param in pctipseg
      param in pccollect
      param in out mensajes  : coleccion de mensajes
      return                 : NUMBER
   *************************************************************************/
   FUNCTION f_get_identprod (
      psproduc             NUMBER,
      pcramo      OUT      NUMBER,
      pcmodali    OUT      NUMBER,
      pctipseg    OUT      NUMBER,
      pccollect   OUT      NUMBER,
      mensajes    IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (500) := 'Psproduc=' || psproduc;
      vobject    VARCHAR2 (200) := 'PAC_MDPAR_PRODUCTOS.F_Get_IdentProd';
      vnum_err   NUMBER;
   BEGIN
      -- Comprovacio pas de parametres
      IF psproduc IS NULL
      THEN
         -- BUG 0023615 - JMF - 18/09/2012
         -- RAISE e_param_error;
         RETURN 0;
      END IF;

      vnum_err :=
              f_def_producto (psproduc, pcramo, pcmodali, pctipseg, pccollect);

      IF vnum_err <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, vnum_err);
         RAISE e_object_error;
      END IF;

      RETURN vnum_err;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN vnum_err;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN vnum_err;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN vnum_err;
   END f_get_identprod;

   /*************************************************************************
      Devuelve el sproduc segun parametros
      param in cramo         : codigo del ramo
      param in cmodali       : codigo de modalidad
      param in ctipseg       : codigo de tipo de seguro
      param in ccolect       : codigo de colectividad
      param in out mensajes  : coleccion de mensajes
   *************************************************************************/
   FUNCTION f_get_sproduc (
      cramo               NUMBER,
      cmodali             NUMBER,
      ctipseg             NUMBER,
      ccolect             NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vsproduc   NUMBER;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (500)
         :=    'parametros: CRAMO '
            || cramo
            || 'CMODALI '
            || cmodali
            || ' CTIPSEG '
            || ctipseg
            || ' CCOLECT '
            || ccolect;
      vobject    VARCHAR2 (200) := 'PAC_MD_COMMON.F_Get_SProduc';
   BEGIN
      RETURN pac_productos.f_get_sproduc (cramo, cmodali, ctipseg, ccolect);
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 0;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 0;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 0;
   END f_get_sproduc;

   -- ini t.7817
   /***********************************************************************
      Recupera el valor del campo CTARPOL d'una pregunta asociada a un
      producto.
      param in  p_cramo   : Ramo
      param in  p_cmodali : Modalidad
      param in  p_ctipseg : Tipo de seguro
      param in  p_ccolect : Colectivo
      param in  p_cpregun : Pregunta
      param out p_ctarpol : indica si se debe tarifar o no con el cambio
                            de valor de esta pregunta.
      return              : devuelve 0 si todo bien, sino el codigo del error
   ***********************************************************************/
   FUNCTION f_pregneedtarif (
      p_cramo     IN       pregunpro.cramo%TYPE,
      p_cmodali   IN       pregunpro.cmodali%TYPE,
      p_ctipseg   IN       pregunpro.ctipseg%TYPE,
      p_ccolect   IN       pregunpro.ccolect%TYPE,
      p_cpregun   IN       pregunpro.cpregun%TYPE,
      p_ctarpol   OUT      pregunpro.ctarpol%TYPE,
      mensajes    IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (500)
         :=    'P_cramo='
            || p_cramo
            || ' - P_cmodali='
            || p_cmodali
            || ' - P_ctipseg='
            || p_ctipseg
            || ' - P_ccolect='
            || p_ccolect
            || ' - P_cpregun='
            || p_cpregun;
      vobject    VARCHAR2 (200) := 'PAC_MDPAR_PRODUCTOS.F_PregNeedTarif';
      vnum_err   NUMBER;
   BEGIN
      -- Comprovacio pas de parametres
      IF    p_cramo IS NULL
         OR p_cmodali IS NULL
         OR p_ctipseg IS NULL
         OR p_ccolect IS NULL
         OR p_cpregun IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vnum_err :=
         pac_productos.f_get_ctarpol (p_cramo,
                                      p_cmodali,
                                      p_ctipseg,
                                      p_ccolect,
                                      p_cpregun,
                                      p_ctarpol
                                     );

      IF vnum_err <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, vnum_err);
         RAISE e_object_error;
      END IF;

      RETURN vnum_err;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN vnum_err;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN vnum_err;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN vnum_err;
   END f_pregneedtarif;

   -- fin t.7817

   /***********************************************************************
      Recupera si un producto tiene cuestionario de salud
      param in psproduc  : codigo de producto
      param out pccuesti : indica si tiene cuestionario de salud
      param in out mensajes  : coleccion de mensajes
      return             : devuelve 0 si todo bien, sino el codigo del error
   ***********************************************************************/
   FUNCTION f_get_ccuesti (
      psproduc   IN       NUMBER,
      pccuesti   OUT      NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (500) := 'psproduc=' || psproduc;
      vobject    VARCHAR2 (200) := 'PAC_MDPAR_PRODUCTOS.f_get_ccuesti';
      vnum_err   NUMBER;
   BEGIN
      IF psproduc IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vnum_err := pac_productos.f_get_ccuesti (psproduc, pccuesti);

      IF vnum_err <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, vnum_err);
         RAISE e_object_error;
      END IF;

      RETURN vnum_err;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN vnum_err;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN vnum_err;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN vnum_err;
   END f_get_ccuesti;

   -- BUG 6296 - 16/03/2009 - SBG - Creacio funcio f_get_pregtipgru
   /***********************************************************************
      Recupera el Tipo de grupo de pregunta (detvalores.cvalor = 309)
      param in  pcpregun : codigo de pregunta
      param out mensajes : mensajes de error
      return             : Tipo de grupo de pregunta (detvalores.cvalor = 309)
   ***********************************************************************/
   FUNCTION f_get_pregtipgru (
      pcpregun   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec    NUMBER         := 1;
      vparam      VARCHAR2 (500) := 'pcpregun= ' || pcpregun;
      vobject     VARCHAR2 (200) := 'PAC_MDPAR_PRODUCTOS.F_Get_PregTipGru';
      v_ctipgru   NUMBER;
   BEGIN
      --Inicialitzacions
      IF pcpregun IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      SELECT ctipgru
        INTO v_ctipgru
        FROM codipregun
       WHERE cpregun = pcpregun;

      RETURN v_ctipgru;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_get_pregtipgru;

   /***********************************************************************
      Nos indica si una determinada pregunta es o no semiautomatica
      param in  psproduc : codigo de producto
      param in  pcpregun : codigo de pregunta
      param in  pnivel   : codigo de accesi (poliza, riesgo o garantia)
      param out mensajes : mensajes de error
      param in  pcgarant : codigo de garantia para el acceso por garantia
      return             : Number [0/1]
   ***********************************************************************/
   -- Bug 9109 - 12/02/2009 - RSC - APR: Preguntas semiautomaticas
   FUNCTION f_es_semiautomatica (
      psproduc   IN       NUMBER,
      pcpregun   IN       NUMBER,
      pnivel     IN       VARCHAR2,       -- Nivel 'P' (poliza) o 'R' (riesgo)
      mensajes   OUT      t_iax_mensajes,
      pcgarant   IN       NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      preg   t_iaxpar_preguntas;
   BEGIN
      IF pnivel = 'P'
      THEN                                                    -- nivel poliza
         preg :=
            pac_mdpar_productos.f_get_pregpoliza
                                                (psproduc,
                                                 pac_iax_produccion.issimul,
                                                 pac_iax_produccion.issuplem,
                                                 mensajes
                                                );
      ELSIF pnivel = 'R'
      THEN                                                   -- nivel garantia
         preg := pac_iaxpar_productos.f_get_datosriesgos (mensajes);
      ELSIF pnivel = 'G'
      THEN                                                   -- nivel garantia
         preg := pac_iaxpar_productos.f_get_preggarant (pcgarant, mensajes);
      END IF;

      IF preg IS NOT NULL
      THEN
         IF preg.COUNT > 0
         THEN
            FOR i IN preg.FIRST .. preg.LAST
            LOOP
               IF preg (i).cpregun = pcpregun
               THEN
                  IF (   preg (i).cpretip = 3
                      OR (preg (i).cpretip = 2 AND preg (i).esccero = 1)
                     )
                  THEN
                     RETURN 1;
                  END IF;
               END IF;
            END LOOP;
         END IF;
      END IF;

      RETURN 0;
   END f_es_semiautomatica;

   /***********************************************************************
      Nos retornara el TPREFOR de una determinada pregunta ya sea a nivel de
      poliza, riesgo o garantia.

      param in  psproduc : codigo de producto
      param in  pcpregun : codigo de pregunta
      param in  pnivel   : codigo de accesi (poliza, riesgo o garantia)
      param out mensajes : mensajes de error
      param in  pcgarant : codigo de garantia para el acceso por garantia
      return             : Number [0/1]
   ***********************************************************************/
   -- Bug 9109 - 12/02/2009 - RSC - APR: Preguntas semiautomaticas
   FUNCTION f_get_tpreforsemi (
      psproduc   IN       NUMBER,
      pcpregun   IN       NUMBER,
      pnivel     IN       VARCHAR2,
      mensajes   OUT      t_iax_mensajes,
      pcgarant   IN       NUMBER DEFAULT NULL
   )
      RETURN VARCHAR2
   IS
      preg   t_iaxpar_preguntas;
   BEGIN
      IF pnivel = 'P'
      THEN
         preg :=
            pac_mdpar_productos.f_get_pregpoliza
                                                (psproduc,
                                                 pac_iax_produccion.issimul,
                                                 pac_iax_produccion.issuplem,
                                                 mensajes
                                                );
      ELSIF pnivel = 'R'
      THEN
         preg := pac_iaxpar_productos.f_get_datosriesgos (mensajes);
      ELSIF pnivel = 'G'
      THEN
         preg := pac_iaxpar_productos.f_get_preggarant (pcgarant, mensajes);
      END IF;

      FOR i IN preg.FIRST .. preg.LAST
      LOOP
         IF preg (i).cpregun = pcpregun
         THEN
            RETURN preg (i).tprefor;
         END IF;
      END LOOP;

      RETURN NULL;
   END f_get_tpreforsemi;

   /*************************************************************************
      BUG9217 - 03/04/2009 - DRA
      Retorna por parametro si permite hacer el suplemento de un motivo determinado
      param in  pcuser      : Codigo del usuario
      param in  pcmotmov    : Codigo del motivo
      param in  psproduc    : id. producto
      param out p_permite    : Indica si se permite realizar el suplemento o no
      param out mensajes     : mensajes de error
      return                 : 0.- OK    <> 0 --> ERROR
   *************************************************************************/
   FUNCTION f_permite_supl_prod (
      p_cuser     IN       VARCHAR2,
      p_cmotmov   IN       NUMBER,
      p_sproduc   IN       NUMBER,
      p_permite   OUT      NUMBER,
      mensajes    OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec   NUMBER         := 1;
      vparam     VARCHAR2 (500)
         :=    'p_cuser= '
            || p_cuser
            || ' - p_cmotmov: '
            || p_cmotmov
            || ' - p_sproduc: '
            || p_sproduc;
      vobject    VARCHAR2 (200) := 'PAC_MDPAR_PRODUCTOS.f_permite_supl_prod';
      v_numerr   NUMBER;
   BEGIN
      p_permite := 1;
      v_numerr :=
           pk_suplementos.f_permite_supl_prod (p_cuser, p_cmotmov, p_sproduc);

      IF v_numerr = 180286
      THEN
         p_permite := 0;
      ELSIF v_numerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, v_numerr);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         p_permite := 0;
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         p_permite := 0;
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         p_permite := 0;
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_permite_supl_prod;

   -- BUG9661:DRA:15/04/2009: Inici
   /***********************************************************************
      Recuperar la lista de posibles valores de revalorizacion por producto
      param in  p_sproduc: codigo del producto
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_tipreval (p_sproduc IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      v_select   VARCHAR2 (2000);
      cur        sys_refcursor;
      vpasexec   NUMBER          := 1;
      vparam     VARCHAR2 (500)  := 'p_sproduc= ' || p_sproduc;
      vobject    VARCHAR2 (200)  := 'PAC_MDPAR_PRODUCTOS.f_get_tipreval';
   BEGIN
      v_select :=
         pac_productos.f_get_tipreval (p_sproduc,
                                       pac_md_common.f_get_cxtidioma
                                      );

      IF v_select IS NULL
      THEN
         cur := pac_md_listvalores.f_get_lstcrevali (mensajes);
      ELSE
         cur := pac_md_listvalores.f_opencursor (v_select, mensajes);
      END IF;

      RETURN cur;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN cur;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN cur;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN cur;
   END f_get_tipreval;

   -- BUG9661:DRA:15/04/2009: Fi

   /***********************************************************************
   Donat un producte retornem el codi de clausula per defecte del producte.
   param in  p_sproduc: codi producte
   param out mensajes : missatge error
   return             : ok/error
   ***********************************************************************/
      -- BUG 12674.NMM.15/01/2010.i.
   FUNCTION f_get_claubenefi_def (
      p_sproduc              IN       NUMBER,
      p_clau_benef_defecte   OUT      VARCHAR2,
      mensajes               IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec   NUMBER         := 1;
      vparam     VARCHAR2 (500) := 'p_sproduc= ' || p_sproduc;
      vobject    VARCHAR2 (200) := 'PAC_MDPAR_PRODUCTOS.f_get_claubenefi_def';
      w_err      NUMBER;
   --
   BEGIN
      --Inicialitzacions
      IF p_sproduc IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      w_err :=
          pac_productos.f_get_claubenefi_def (p_sproduc, p_clau_benef_defecte);

      IF w_err <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, w_err);
         RAISE e_object_error;
      END IF;

      RETURN (0);
   --
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN (w_err);
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN (w_err);
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN (w_err);
   END f_get_claubenefi_def;

-- BUG 12674.NMM.15/01/2010.f.

   -- BUG12760:DRA:03/02/2010:Inici
   /***********************************************************************
      Recupera si la pregunta es visible o no
      param in  p_sproduc  : codigo de productos
      param in  p_cpregun  : codigo de pregunta
      param out p_cvisible : 0-> No visible   1-> Visible
      return               : devuelve 0 si todo bien, sino el codigo del error
   ***********************************************************************/
   FUNCTION f_get_pregvisible (
      p_sproduc    IN       NUMBER,
      p_cpregun    IN       NUMBER,
      p_cactivi    IN       NUMBER DEFAULT 0,
                                             -- BUG 0036730 - FAL - 09/12/2015
      p_cvisible   OUT      NUMBER,
      mensajes     OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      --
      vpasexec   NUMBER         := 1;
      vparam     VARCHAR2 (500)
                := 'p_sproduc= ' || p_sproduc || ', p_cpregun= ' || p_cpregun;
      vobject    VARCHAR2 (200) := 'PAC_MDPAR_PRODUCTOS.f_get_pregvisible';
      w_err      NUMBER;
   BEGIN
      IF p_sproduc IS NULL OR p_cpregun IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      w_err :=
         pac_productos.f_get_pregvisible (p_sproduc,
                                          p_cpregun,
                                          p_cactivi,
                                          p_cvisible
                                         );  -- BUG 0036730 - FAL - 09/12/2015

      IF w_err <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, w_err);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   --
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN (w_err);
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN (w_err);
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN (w_err);
   END f_get_pregvisible;

-- BUG12760:DRA:03/02/2010:Fi
/***********************************************************************
      Devuelve Si tiene detalle la garantia
      param in psproduc  : codigo de producto
      param in pcgarant  : codigo de la garantia
      param out mensajes : mensajes de error
      return             : descripcion garantia
   ***********************************************************************/
   FUNCTION f_get_detallegar (
      psproduc   IN       NUMBER,
      pcgarant   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      RESULT     NUMBER;
      vsproduc   NUMBER;
      squery     VARCHAR2 (4000);
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (500)
                      := 'psproduc=' || psproduc || ', pcgarant=' || pcgarant;
      vobject    VARCHAR2 (200)  := 'PAC_MDPAR_PRODUCTOS.f_get_detallegar';
   BEGIN
      --Inicialitzacions
      IF psproduc IS NULL OR pcgarant IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      squery :=
            'select cdetalle from garanpro g '
         || ' where g.cgarant='
         || pcgarant
         || '  and  g.sproduc='
         || psproduc;
      RESULT := pac_md_listvalores.f_getdescripvalor (squery, mensajes);
      RETURN RESULT;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_get_detallegar;

   /***********************************************************************
      Recupera las formas de pago del producto
      param in psproduc  : codigo del producto
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_fprestaprod (
      psproduc   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      cur         sys_refcursor;
      squery      VARCHAR2 (1000);
      vpasexec    NUMBER (8)                    := 1;
      vparam      VARCHAR2 (500)                := 'psproduc=' || psproduc;
      vobject     VARCHAR2 (200)   := 'PAC_MDPAR_PRODUCTOS.f_get_fprestaprod';
      v_tcausin   axis_literales.tlitera%TYPE;
                                              -- Bug 18670 - APD - 16/06/2011
   BEGIN
      --Inicialitzacions
      IF psproduc IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      -- Bug 18670 - APD - 16/06/2011 - se a?n los campos ccausin, cmotsin y cgarant
      -- y sus descripciones
      -- Se pone el mismo codigo que en pac_md_listvalores_sin.f_get_causasini para obtener
      -- la descripcion de ccausa = 1
      IF NVL (pac_parametros.f_parproducto_n (psproduc, 'PRESTACION'), 0) = 1
      THEN
         v_tcausin :=
               'f_axis_literales(9900994,'
            || pac_md_common.f_get_cxtidioma ()
            || ')';
      ELSE
         v_tcausin := 'c.tcausin';
      END IF;

      squery :=
            'SELECT d.catribu , d.tatribu, '
         || 'f.ccausin, (select DECODE(c.ccausin, 1,'
         || v_tcausin
         || ' , c.tcausin) from sin_descausa c where c.ccausin = f.ccausin and c.cidioma = '
         || pac_md_common.f_get_cxtidioma
         || ') tcausin, '
         || 'f.cmotsin, (select tmotsin from sin_desmotcau m where m.ccausin = f.ccausin and m.cmotsin = f.cmotsin and m.cidioma = '
         || pac_md_common.f_get_cxtidioma
         || ') tmotsin, '
         || 'f.cgarant, (select tgarant from garangen g where g.cgarant = f.cgarant and g.cidioma = '
         || pac_md_common.f_get_cxtidioma
         || ') tgarant '
         || ' FROM     DETVALORES D, FPRESTAPROD F, PRODUCTOS P '
         || ' WHERE f.sproduc = p.sproduc '
         || '   AND f.ctippres = d.catribu '
         || '    AND d.cidioma =  '
         || pac_md_common.f_get_cxtidioma
         || '    AND p.sproduc =  '
         || psproduc
         || '   AND d.cvalor = 205 '
         || ' ORDER BY d.catribu';
      -- Fin Bug 18670 - APD - 16/06/2011
      cur := pac_md_listvalores.f_opencursor (squery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_fprestaprod;

   /***********************************************************************
      Devuelve una clausula del producto
      param in cramo     : codigo ramo
      param in cmodali   : codigo modalidad
      param in ctipseg   : codigo tipo de seguro
      param in ccolect   : codigo de colectividad
      param in sclagen   : codigo de la clausula
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_clausula (
      pcramo     IN       NUMBER,
      pcmodali   IN       NUMBER,
      pctipseg   IN       NUMBER,
      pccolect   IN       NUMBER,
      psclagen   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN ob_iaxpar_clausulas
   IS
      --
      CURSOR cclau
      IS
         SELECT   c.*
             FROM clausupro c
            WHERE c.ccolect = pccolect
              AND c.cramo = pcramo
              AND c.ctipseg = pctipseg
              AND c.cmodali = pcmodali
              AND c.sclagen = psclagen
              AND (c.multiple IS NULL OR c.multiple != 1)
         --AND c.multiple != 1
         ORDER BY c.norden;

            --BUG0010092: APR - Clausulas por garantia y pregunta -INI
            -- Bug 18362 - APD - 23/05/2011 - Si que deben mostrarse las
            -- clausulas por garantia y pregunta
/*
            AND c.ctipcla < 3
            AND c.sclapro NOT IN(SELECT d.sclapro
                                   FROM clausugar d
                                  WHERE d.cramo = pcramo
                                    AND d.cmodali = pcmodali
                                    AND d.ctipseg = pctipseg
                                    AND d.ccolect = pccolect
                                 UNION
                                 SELECT g.sclapro
                                   FROM clausupreg g);
*/
      -- Fin Bug 18362 - APD - 23/05/2011
      --BUG0010092: APR - Clausulas por garantia y pregunta - FIN
      CURSOR cur_claupara
      IS
         SELECT sclagen, nparame, cformat, tparame, tvalclau, tconsulta
           FROM clausupara
          WHERE sclagen = psclagen AND cidioma = pac_md_common.f_get_cxtidioma;

      clau        ob_iaxpar_clausulas     := ob_iaxpar_clausulas ();
      vpasexec    NUMBER (8)              := 1;
      vparam      VARCHAR2 (500)
         :=    'pcramo='
            || pcramo
            || ', pcmodali='
            || pcmodali
            || ', pctipseg='
            || pctipseg
            || ', pccolect='
            || pctipseg
            || ', sclagen='
            || psclagen;
      vobject     VARCHAR2 (200)       := 'PAC_MDPAR_PRODUCTOS.F_Get_Clausula';
      vnumerr     NUMBER (8)              := 0;
      vctipo      NUMBER;                              -- Bug APD - 24/05/2011
      resp        t_iaxclausupara_valores;
      vconsulta   VARCHAR2 (2000);
      w_cvalor    NUMBER;
      w_tvalor    VARCHAR2 (2000);
      vsproduc    NUMBER;
      cur         sys_refcursor;
   BEGIN
      IF    pcramo IS NULL
         OR pctipseg IS NULL
         OR pccolect IS NULL
         OR pcmodali IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      FOR cla IN cclau
      LOOP
         IF clau IS NULL
         THEN
            clau := ob_iaxpar_clausulas ();
         END IF;

         SELECT sproduc
           INTO vsproduc
           FROM productos
          WHERE cramo = pcramo
            AND ccolect = pccolect
            AND ctipseg = pctipseg
            AND cmodali = pcmodali;

         clau.sclapro := cla.sclapro;
         clau.ctipcla := cla.ctipcla;
         clau.norden := cla.norden;
         clau.sclagen := psclagen;

         BEGIN
            SELECT COUNT (1)
              INTO clau.cparams
              FROM clausupara cp
             WHERE cp.sclagen = psclagen
               AND cp.cidioma = pac_md_common.f_get_cxtidioma;
         EXCEPTION
            WHEN OTHERS
            THEN
               clau.cparams := 0;
         END;

         -- SI hay parametros creamos el objeto ob_iax_clausupara
         BEGIN
            IF clau.cparams > 0
            THEN
               clau.parametros := t_iax_clausupara ();

               FOR r_cur IN cur_claupara
               LOOP
                  clau.parametros.EXTEND;
                  clau.parametros (clau.parametros.LAST) :=
                                                         ob_iax_clausupara
                                                                          ();
                  clau.parametros (clau.parametros.LAST).sclagen :=
                                                                r_cur.sclagen;
                  clau.parametros (clau.parametros.LAST).nparame :=
                                                                r_cur.nparame;
                  clau.parametros (clau.parametros.LAST).cformat :=
                                                                r_cur.cformat;
                  clau.parametros (clau.parametros.LAST).tparame :=
                                                                r_cur.tparame;
                  -- Bug 18362 - APD - 17/05/2011 - se a? el campo tvalclau
                  clau.parametros (clau.parametros.LAST).tvalclau :=
                                                               r_cur.tvalclau;

                  IF r_cur.cformat = 6
                  THEN
                     vpasexec := 13;
                     vconsulta :=
                        REPLACE (r_cur.tconsulta,
                                 ':PMT_IDIOMA',
                                 pac_md_common.f_get_cxtidioma
                                );
                     -- INI Bug 0012227 - 03/12/2009 - JMF
                     vconsulta :=
                                 REPLACE (vconsulta, ':PMT_SPRODUC', vsproduc);
                     -- FIN Bug 0012227 - 03/12/2009 - JMF

                     -- Bug 22839 - RSC - 17/07/2012 - LCOL - Funcionalidad Certificado 0
                     vconsulta :=
                        REPLACE (vconsulta,
                                 ':PMT_NPOLIZA',
                                 pac_iax_produccion.poliza.det_poliza.npoliza
                                );
                     vconsulta :=
                        REPLACE (vconsulta,
                                 ':PMT_SSEGURO',
                                 pac_iax_produccion.poliza.det_poliza.sseguro
                                );
                     -- Fin Bug 22839
                     --JLV 23/04/2014 a¿adir el agente, es necesario para las campa¿as
                     vconsulta :=
                        REPLACE (vconsulta,
                                 ':PMT_CAGENTE',
                                 pac_iax_produccion.poliza.det_poliza.cagente
                                );
                     vpasexec := 14;
                     cur :=
                         pac_md_listvalores.f_opencursor (vconsulta, mensajes);
                     vpasexec := 15;

                     IF resp IS NULL
                     THEN
                        vpasexec := 24;
                        resp := t_iaxclausupara_valores ();
                     END IF;

                     FETCH cur
                      INTO w_cvalor, w_tvalor;

                     vpasexec := 16;

                     WHILE cur%FOUND
                     LOOP
                        vpasexec := 18;
                        resp.EXTEND;
                        resp (resp.LAST) := ob_iaxclausupara_valores ();
                        resp (resp.LAST).sclagen := r_cur.sclagen;
                        resp (resp.LAST).nparame := r_cur.nparame;
                        resp (resp.LAST).cparame := w_cvalor;
                        resp (resp.LAST).cidioma :=
                                                pac_md_common.f_get_cxtidioma;
                        resp (resp.LAST).tparame := w_tvalor;
                        vpasexec := 26;

                        FETCH cur
                         INTO w_cvalor, w_tvalor;

                        vpasexec := 20;
                     END LOOP;

                     -- BUG -21546_108724- 02/02/2012 - JLTS- Cierre de cursores
                     IF cur%ISOPEN
                     THEN
                        CLOSE cur;
                     END IF;

                     vpasexec := 21;
                     clau.parametros (clau.parametros.LAST).valores := resp;
                  ELSIF r_cur.cformat = 2
                  THEN
                     FOR j IN (SELECT *
                                 FROM clausupara_valores
                                WHERE sclagen = r_cur.sclagen
                                  AND nparame = r_cur.nparame
                                  AND cidioma = pac_md_common.f_get_cxtidioma)
                     LOOP
                        IF resp IS NULL
                        THEN
                           vpasexec := 24;
                           resp := t_iaxclausupara_valores ();
                        END IF;

                        vpasexec := 25;
                        resp.EXTEND;
                        resp (resp.LAST) := ob_iaxclausupara_valores ();
                        resp (resp.LAST).sclagen := j.sclagen;
                        resp (resp.LAST).nparame := j.nparame;
                        resp (resp.LAST).cparame := j.cparame;
                        resp (resp.LAST).cidioma := j.cidioma;
                        resp (resp.LAST).tparame := j.tparame;
                        vpasexec := 26;
                        vpasexec := 27;
                     END LOOP;

                     clau.parametros (clau.parametros.LAST).valores := resp;
                  --lista de valores
                  ELSIF r_cur.cformat = 8
                  THEN
                     vpasexec := 28;
                     vconsulta :=
                        REPLACE (r_cur.tconsulta,
                                 ':PMT_IDIOMA',
                                 pac_md_common.f_get_cxtidioma
                                );
                     -- INI Bug 0012227 - 03/12/2009 - JMF
                     vconsulta :=
                                 REPLACE (vconsulta, ':PMT_SPRODUC', vsproduc);
                     -- FIN Bug 0012227 - 03/12/2009 - JMF

                     -- Bug 22839 - RSC - 17/07/2012 - LCOL - Funcionalidad Certificado 0
                     vconsulta :=
                        REPLACE (vconsulta,
                                 ':PMT_NPOLIZA',
                                 pac_iax_produccion.poliza.det_poliza.npoliza
                                );
                     vconsulta :=
                        REPLACE (vconsulta,
                                 ':PMT_SSEGURO',
                                 pac_iax_produccion.poliza.det_poliza.sseguro
                                );
                     -- Fin Bug 22839
                     --JLV 23/04/2014 a¿adir el agente, es necesario para las campa¿as
                     vconsulta :=
                        REPLACE (vconsulta,
                                 ':PMT_CAGENTE',
                                 pac_iax_produccion.poliza.det_poliza.cagente
                                );
                     vpasexec := 29;
                     cur :=
                         pac_md_listvalores.f_opencursor (vconsulta, mensajes);
                     vpasexec := 30;
                     vpasexec := 24;
                     resp := t_iaxclausupara_valores ();

                     FETCH cur
                      INTO w_cvalor, w_tvalor;

                     vpasexec := 31;
                     resp.EXTEND;
                     resp (resp.LAST) := ob_iaxclausupara_valores ();
                     resp (resp.LAST).sclagen := r_cur.sclagen;
                     resp (resp.LAST).nparame := r_cur.nparame;
                     resp (resp.LAST).cparame := w_cvalor;
                     resp (resp.LAST).cidioma := pac_md_common.f_get_cxtidioma;
                     resp (resp.LAST).tparame := w_tvalor;
                     vpasexec := 33;

                     -- BUG -21546_108724- 02/02/2012 - JLTS- Cierre de cursores
                     IF cur%ISOPEN
                     THEN
                        CLOSE cur;
                     END IF;

                     vpasexec := 35;
                     clau.parametros (clau.parametros.LAST).valores := resp;
                     clau.parametros (clau.parametros.LAST).ttexto := w_cvalor;
                     p_tab_error (f_sysdate,
                                  f_user,
                                  'PROBANDO',
                                  vpasexec,
                                     'cvalor: '
                                  || w_cvalor
                                  || ' tvalor:'
                                  || w_tvalor,
                                  'ssssss'
                                 );
                  END IF;
               -- fin Bug 18362 - APD - 17/05/2011
               END LOOP;
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               clau.parametros := NULL;
               pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                                  vobject,
                                                  1000001,
                                                  vpasexec,
                                                  vparam,
                                                  psqcode      => SQLCODE,
                                                  psqerrm      => SQLERRM
                                                 );
         END;

         IF cla.ctipcla = 2
         THEN                                                         -- VF 32
            clau.cobliga := 1;
         ELSE
            clau.cobliga := 0;
         END IF;

         -- Bug 18362 - APD - 24/05/2011 - se le a? el ctipo al objeto OB_IAXPAR_CLAUSULAS
         BEGIN
            SELECT DECODE (tipo, 'PREG', 2, 'GAR', 3)
              INTO vctipo
              FROM (SELECT 'GAR' tipo
                      FROM clausugar d
                     WHERE d.cramo = cla.cramo
                       AND d.cmodali = cla.cmodali
                       AND d.ctipseg = cla.ctipseg
                       AND d.ccolect = cla.ccolect
                       AND d.sclapro = cla.sclapro
                    UNION
                    SELECT 'PREG' tipo
                      FROM clausupreg g
                     WHERE g.sclapro = cla.sclapro);

            IF vctipo IS NULL
            THEN
               vctipo := 4;
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               vctipo := 4;
         END;

         clau.ctipo := vctipo;

         IF clau.ctipo IN (2, 3)
         THEN
            clau.norden := cla.ccapitu * 1000 + cla.norden;
         END IF;

         -- fin Bug 18362 - APD - 24/05/2011 -

         --Comprovacio de parametres
         IF cla.sclagen IS NULL OR pac_md_common.f_get_cxtidioma IS NULL
         THEN
            RAISE e_param_error;
         END IF;

         vnumerr :=
            pac_productos.f_get_clausugen (cla.sclagen,
                                           pac_md_common.f_get_cxtidioma,
                                           clau.tclatit,
                                           clau.tclatex
                                          );

         IF vnumerr <> 0
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, vnumerr);
            RAISE e_object_error;
         END IF;
      END LOOP;

      RETURN clau;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_get_clausula;

   /***********************************************************************
      Devuelve una clausula del producto
      param in cramo     : codigo ramo
      param in cmodali   : codigo modalidad
      param in ctipseg   : codigo tipo de seguro
      param in ccolect   : codigo de colectividad
      param in sclagen   : codigo de la clausula
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_clausulamult (
      pcramo     IN       NUMBER,
      pcmodali   IN       NUMBER,
      pctipseg   IN       NUMBER,
      pccolect   IN       NUMBER,
      psclagen   IN       NUMBER,
      pnordcla   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN ob_iaxpar_clausulas
   IS
      --
      CURSOR cclau
      IS
         SELECT   c.*
             FROM clausupro c
            WHERE c.ccolect = pccolect
              AND c.cramo = pcramo
              AND c.ctipseg = pctipseg
              AND c.cmodali = pcmodali
              AND c.sclagen = psclagen
              AND c.multiple = 1
         ORDER BY c.norden;

            --BUG0010092: APR - Clausulas por garantia y pregunta -INI
            -- Bug 18362 - APD - 23/05/2011 - Si que deben mostrarse las
            -- clausulas por garantia y pregunta
/*
            AND c.ctipcla < 3
            AND c.sclapro NOT IN(SELECT d.sclapro
                                   FROM clausugar d
                                  WHERE d.cramo = pcramo
                                    AND d.cmodali = pcmodali
                                    AND d.ctipseg = pctipseg
                                    AND d.ccolect = pccolect
                                 UNION
                                 SELECT g.sclapro
                                   FROM clausupreg g);
*/
      -- Fin Bug 18362 - APD - 23/05/2011
      --BUG0010092: APR - Clausulas por garantia y pregunta - FIN
      CURSOR cur_claupara
      IS
         SELECT sclagen, nparame, cformat, tparame, tvalclau, tconsulta
           FROM clausupara
          WHERE sclagen = psclagen AND cidioma = pac_md_common.f_get_cxtidioma;

      clau        ob_iaxpar_clausulas     := ob_iaxpar_clausulas ();
      vpasexec    NUMBER (8)              := 1;
      vparam      VARCHAR2 (500)
         :=    'pcramo='
            || pcramo
            || ', pcmodali='
            || pcmodali
            || ', pctipseg='
            || pctipseg
            || ', pccolect='
            || pctipseg
            || ', sclagen='
            || psclagen;
      vobject     VARCHAR2 (200)       := 'PAC_MDPAR_PRODUCTOS.F_Get_Clausula';
      vnumerr     NUMBER (8)              := 0;
      vctipo      NUMBER;                              -- Bug APD - 24/05/2011
      resp        t_iaxclausupara_valores;
      vconsulta   VARCHAR2 (2000);
      w_cvalor    NUMBER;
      w_tvalor    VARCHAR2 (2000);
      vsproduc    NUMBER;
      cur         sys_refcursor;
   BEGIN
      IF    pcramo IS NULL
         OR pctipseg IS NULL
         OR pccolect IS NULL
         OR pcmodali IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      FOR cla IN cclau
      LOOP
         IF clau IS NULL
         THEN
            clau := ob_iaxpar_clausulas ();
         END IF;

         clau.sclapro := cla.sclapro;
         clau.ctipcla := cla.ctipcla;
         clau.norden := cla.norden;
         clau.sclagen := psclagen;
         clau.norden := pnordcla;

         BEGIN
            SELECT COUNT (1)
              INTO clau.cparams
              FROM clausupara cp
             WHERE cp.sclagen = psclagen
               AND cp.cidioma = pac_md_common.f_get_cxtidioma;
         EXCEPTION
            WHEN OTHERS
            THEN
               clau.cparams := 0;
         END;

         -- SI hay parametros creamos el objeto ob_iax_clausupara
         BEGIN
            IF clau.cparams > 0
            THEN
               clau.parametros := t_iax_clausupara ();

               FOR r_cur IN cur_claupara
               LOOP
                  clau.parametros.EXTEND;
                  clau.parametros (clau.parametros.LAST) :=
                                                         ob_iax_clausupara
                                                                          ();
                  clau.parametros (clau.parametros.LAST).sclagen :=
                                                                r_cur.sclagen;
                  clau.parametros (clau.parametros.LAST).nparame :=
                                                                r_cur.nparame;
                  clau.parametros (clau.parametros.LAST).cformat :=
                                                                r_cur.cformat;
                  clau.parametros (clau.parametros.LAST).tparame :=
                                                                r_cur.tparame;
                  -- Bug 18362 - APD - 17/05/2011 - se a? el campo tvalclau
                  clau.parametros (clau.parametros.LAST).tvalclau :=
                                                               r_cur.tvalclau;

                  IF r_cur.cformat = 6
                  THEN
                     vpasexec := 13;
                     vconsulta :=
                        REPLACE (r_cur.tconsulta,
                                 ':PMT_IDIOMA',
                                 pac_md_common.f_get_cxtidioma
                                );
                     -- INI Bug 0012227 - 03/12/2009 - JMF
                     vconsulta :=
                                 REPLACE (vconsulta, ':PMT_SPRODUC', vsproduc);
                     -- FIN Bug 0012227 - 03/12/2009 - JMF

                     -- Bug 22839 - RSC - 17/07/2012 - LCOL - Funcionalidad Certificado 0
                     vconsulta :=
                        REPLACE (vconsulta,
                                 ':PMT_NPOLIZA',
                                 pac_iax_produccion.poliza.det_poliza.npoliza
                                );
                     vconsulta :=
                        REPLACE (vconsulta,
                                 ':PMT_SSEGURO',
                                 pac_iax_produccion.poliza.det_poliza.sseguro
                                );
                     -- Fin Bug 22839
                     --JLV 23/04/2014 a¿adir el agente, es necesario para las campa¿as
                     vconsulta :=
                        REPLACE (vconsulta,
                                 ':PMT_CAGENTE',
                                 pac_iax_produccion.poliza.det_poliza.cagente
                                );
                     vpasexec := 14;
                     cur :=
                         pac_md_listvalores.f_opencursor (vconsulta, mensajes);
                     vpasexec := 15;

                     FETCH cur
                      INTO w_cvalor, w_tvalor;

                     vpasexec := 16;

                     WHILE cur%FOUND
                     LOOP
                        vpasexec := 18;
                        resp.EXTEND;
                        resp (resp.LAST) := ob_iaxclausupara_valores ();
                        resp (resp.LAST).sclagen := r_cur.sclagen;
                        resp (resp.LAST).nparame := r_cur.nparame;
                        resp (resp.LAST).cparame := w_cvalor;
                        resp (resp.LAST).cidioma :=
                                                pac_md_common.f_get_cxtidioma;
                        resp (resp.LAST).tparame := w_tvalor;
                        vpasexec := 26;

                        FETCH cur
                         INTO w_cvalor, w_tvalor;

                        vpasexec := 20;
                     END LOOP;

                     -- BUG -21546_108724- 02/02/2012 - JLTS- Cierre de cursores
                     IF cur%ISOPEN
                     THEN
                        CLOSE cur;
                     END IF;

                     vpasexec := 21;
                     clau.parametros (clau.parametros.LAST).valores := resp;
                  ELSIF r_cur.cformat = 2
                  THEN
                     FOR j IN (SELECT *
                                 FROM clausupara_valores
                                WHERE sclagen = r_cur.sclagen
                                  AND nparame = r_cur.nparame
                                  AND cidioma = pac_md_common.f_get_cxtidioma)
                     LOOP
                        IF resp IS NULL
                        THEN
                           vpasexec := 24;
                           resp := t_iaxclausupara_valores ();
                        END IF;

                        vpasexec := 25;
                        resp.EXTEND;
                        resp (resp.LAST) := ob_iaxclausupara_valores ();
                        resp (resp.LAST).sclagen := j.sclagen;
                        resp (resp.LAST).nparame := j.nparame;
                        resp (resp.LAST).cparame := j.cparame;
                        resp (resp.LAST).cidioma := j.cidioma;
                        resp (resp.LAST).tparame := j.tparame;
                        vpasexec := 26;
                        vpasexec := 27;
                     END LOOP;

                     clau.parametros (clau.parametros.LAST).valores := resp;
                  --lista de valores
                  END IF;
               -- fin Bug 18362 - APD - 17/05/2011
               END LOOP;
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               clau.parametros := NULL;
               pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                                  vobject,
                                                  1000001,
                                                  vpasexec,
                                                  vparam,
                                                  psqcode      => SQLCODE,
                                                  psqerrm      => SQLERRM
                                                 );
         END;

         IF cla.ctipcla = 2
         THEN                                                         -- VF 32
            clau.cobliga := 1;
         ELSE
            clau.cobliga := 0;
         END IF;

         vctipo := 8;
         clau.ctipo := vctipo;

         /*IF clau.ctipo IN(2, 3) THEN
            clau.norden := cla.ccapitu * 1000 + cla.norden;
         END IF;*/

         -- fin Bug 18362 - APD - 24/05/2011 -

         --Comprovacio de parametres
         IF cla.sclagen IS NULL OR pac_md_common.f_get_cxtidioma IS NULL
         THEN
            RAISE e_param_error;
         END IF;

         vnumerr :=
            pac_productos.f_get_clausugen (cla.sclagen,
                                           pac_md_common.f_get_cxtidioma,
                                           clau.tclatit,
                                           clau.tclatex
                                          );

         IF vnumerr <> 0
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, vnumerr);
            RAISE e_object_error;
         END IF;
      END LOOP;

      RETURN clau;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_get_clausulamult;

   /***********************************************************************
      Devuelve los parametros de una clausulas inicializados
      param in psclagen     : codigo clausula
      param out pcparams   :  Numero de parametros de una clausula
      param out mensajes : mensajes de error
      return             : t_iax_clausupara
   ***********************************************************************/
   FUNCTION f_get_clausulas (
      psclagen   IN       NUMBER,
      pcparams   OUT      NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN t_iax_clausupara
   IS
      --
      CURSOR cur_claupara
      IS
         SELECT sclagen, nparame, cformat, tparame, tvalclau, tconsulta
           FROM clausupara
          WHERE sclagen = psclagen
                AND cidioma = pac_md_common.f_get_cxtidioma;

      parametros   t_iax_clausupara        := t_iax_clausupara ();
      vcparams     NUMBER (2);
      vpasexec     NUMBER (8)              := 1;
      vparam       VARCHAR2 (500)          := 'psclagen=' || psclagen;
      vobject      VARCHAR2 (200)     := 'PAC_MDPAR_PRODUCTOS.F_Get_Clausula';
      vnumerr      NUMBER (8)              := 0;
      vctipo       NUMBER;                            -- Bug APD - 24/05/2011
      resp         t_iaxclausupara_valores;
      vconsulta    VARCHAR2 (2000);
      w_cvalor     NUMBER;
      w_tvalor     VARCHAR2 (2000);
      vsproduc     NUMBER;
      cur          sys_refcursor;
   BEGIN
      BEGIN
         SELECT COUNT (1)
           INTO pcparams
           FROM clausupara cp
          WHERE cp.sclagen = psclagen
            AND cp.cidioma = pac_md_common.f_get_cxtidioma;
      EXCEPTION
         WHEN OTHERS
         THEN
            vcparams := 0;
      END;

      -- SI hay parametros creamos el objeto ob_iax_clausupara
      BEGIN
         IF pcparams > 0
         THEN
            parametros := t_iax_clausupara ();

            FOR r_cur IN cur_claupara
            LOOP
               parametros.EXTEND;
               parametros (parametros.LAST) := ob_iax_clausupara ();
               parametros (parametros.LAST).sclagen := r_cur.sclagen;
               parametros (parametros.LAST).nparame := r_cur.nparame;
               parametros (parametros.LAST).cformat := r_cur.cformat;
               parametros (parametros.LAST).tparame := r_cur.tparame;
               -- Bug 18362 - APD - 17/05/2011 - se a? el campo tvalclau
               parametros (parametros.LAST).tvalclau := r_cur.tvalclau;

               -- fin Bug 18362 - APD - 17/05/2011
               IF r_cur.cformat = 6
               THEN
                  vpasexec := 13;
                  vconsulta :=
                     REPLACE (r_cur.tconsulta,
                              ':PMT_IDIOMA',
                              pac_md_common.f_get_cxtidioma
                             );
                  -- INI Bug 0012227 - 03/12/2009 - JMF
                  vconsulta := REPLACE (vconsulta, ':PMT_SPRODUC', vsproduc);
                  -- FIN Bug 0012227 - 03/12/2009 - JMF

                  -- Bug 22839 - RSC - 17/07/2012 - LCOL - Funcionalidad Certificado 0
                  vconsulta :=
                     REPLACE (vconsulta,
                              ':PMT_NPOLIZA',
                              pac_iax_produccion.poliza.det_poliza.npoliza
                             );
                  vconsulta :=
                     REPLACE (vconsulta,
                              ':PMT_SSEGURO',
                              pac_iax_produccion.poliza.det_poliza.sseguro
                             );
                  -- Fin Bug 22839
                  --JLV 23/04/2014 a¿adir el agente, es necesario para las campa¿as
                  vconsulta :=
                     REPLACE (vconsulta,
                              ':PMT_CAGENTE',
                              pac_iax_produccion.poliza.det_poliza.cagente
                             );
                  vpasexec := 14;
                  cur := pac_md_listvalores.f_opencursor (vconsulta, mensajes);
                  vpasexec := 15;

                  IF resp IS NULL
                  THEN
                     vpasexec := 24;
                     resp := t_iaxclausupara_valores ();
                  END IF;

                  FETCH cur
                   INTO w_cvalor, w_tvalor;

                  vpasexec := 16;

                  WHILE cur%FOUND
                  LOOP
                     vpasexec := 18;
                     resp.EXTEND;
                     resp (resp.LAST) := ob_iaxclausupara_valores ();
                     resp (resp.LAST).sclagen := r_cur.sclagen;
                     resp (resp.LAST).nparame := r_cur.nparame;
                     resp (resp.LAST).cparame := w_cvalor;
                     resp (resp.LAST).cidioma :=
                                                pac_md_common.f_get_cxtidioma;
                     resp (resp.LAST).tparame := w_tvalor;
                     vpasexec := 26;

                     FETCH cur
                      INTO w_cvalor, w_tvalor;

                     vpasexec := 20;
                  END LOOP;

                  -- BUG -21546_108724- 02/02/2012 - JLTS- Cierre de cursores
                  IF cur%ISOPEN
                  THEN
                     CLOSE cur;
                  END IF;

                  vpasexec := 21;
                  parametros (parametros.LAST).valores := resp;
               ELSIF r_cur.cformat = 2
               THEN
                  FOR j IN (SELECT *
                              FROM clausupara_valores
                             WHERE sclagen = r_cur.sclagen
                               AND nparame = r_cur.nparame
                               AND cidioma = pac_md_common.f_get_cxtidioma)
                  LOOP
                     IF resp IS NULL
                     THEN
                        vpasexec := 24;
                        resp := t_iaxclausupara_valores ();
                     END IF;

                     vpasexec := 25;
                     resp.EXTEND;
                     resp (resp.LAST) := ob_iaxclausupara_valores ();
                     resp (resp.LAST).sclagen := j.sclagen;
                     resp (resp.LAST).nparame := j.nparame;
                     resp (resp.LAST).cparame := j.cparame;
                     resp (resp.LAST).cidioma := j.cidioma;
                     resp (resp.LAST).tparame := j.tparame;
                     vpasexec := 26;
                     vpasexec := 27;
                  END LOOP;

                  parametros (parametros.LAST).valores := resp;
               --lista de valores
               ELSIF r_cur.cformat = 8
               THEN
                  vpasexec := 28;
                  vconsulta :=
                     REPLACE (r_cur.tconsulta,
                              ':PMT_IDIOMA',
                              pac_md_common.f_get_cxtidioma
                             );
                  -- INI Bug 0012227 - 03/12/2009 - JMF
                  vconsulta := REPLACE (vconsulta, ':PMT_SPRODUC', vsproduc);
                  -- FIN Bug 0012227 - 03/12/2009 - JMF

                  -- Bug 22839 - RSC - 17/07/2012 - LCOL - Funcionalidad Certificado 0
                  vconsulta :=
                     REPLACE (vconsulta,
                              ':PMT_NPOLIZA',
                              pac_iax_produccion.poliza.det_poliza.npoliza
                             );
                  vconsulta :=
                     REPLACE (vconsulta,
                              ':PMT_SSEGURO',
                              pac_iax_produccion.poliza.det_poliza.sseguro
                             );
                  -- Fin Bug 22839
                  --JLV 23/04/2014 a¿adir el agente, es necesario para las campa¿as
                  vconsulta :=
                     REPLACE (vconsulta,
                              ':PMT_CAGENTE',
                              pac_iax_produccion.poliza.det_poliza.cagente
                             );
                  vpasexec := 29;
                  cur := pac_md_listvalores.f_opencursor (vconsulta, mensajes);
                  vpasexec := 30;
                  resp := t_iaxclausupara_valores ();

                  FETCH cur
                   INTO w_cvalor, w_tvalor;

                  vpasexec := 31;
                  vpasexec := 32;
                  resp.EXTEND;
                  resp (resp.LAST) := ob_iaxclausupara_valores ();
                  resp (resp.LAST).sclagen := r_cur.sclagen;
                  resp (resp.LAST).nparame := r_cur.nparame;
                  resp (resp.LAST).cparame := w_cvalor;
                  resp (resp.LAST).cidioma := pac_md_common.f_get_cxtidioma;
                  resp (resp.LAST).tparame := w_tvalor;
                  vpasexec := 33;
                  vpasexec := 34;

                  -- BUG -21546_108724- 02/02/2012 - JLTS- Cierre de cursores
                  IF cur%ISOPEN
                  THEN
                     CLOSE cur;
                  END IF;

                  vpasexec := 35;
                  parametros (parametros.LAST).valores := resp;
                  parametros (parametros.LAST).ttexto := w_cvalor;
               END IF;
            END LOOP;
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            parametros := NULL;
            pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                               vobject,
                                               1000001,
                                               vpasexec,
                                               vparam,
                                               psqcode      => SQLCODE,
                                               psqerrm      => SQLERRM
                                              );
      END;

      RETURN parametros;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_get_clausulas;

   /***********************************************************************
      Devuelve el parametro de producto productos_ren.cmodextra
      return   : valor del parametro
   ***********************************************************************/
   FUNCTION f_get_cmodextra (
      psproduc     IN       NUMBER,
      pcmodextra   OUT      NUMBER,
      mensajes     OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (500) := 'psproduc=' || psproduc;
      vobject    VARCHAR2 (200) := 'PAC_MDPAR_PRODUCTOS.f_get_cmodextra';
   BEGIN
      --Inicialitzacions
      IF psproduc IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      SELECT cmodextra
        INTO pcmodextra
        FROM producto_ren
       WHERE sproduc = psproduc;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN -1;
   END f_get_cmodextra;

-- Bug 0019578 - FAL - 26/09/2011 - Recuperar si derechos de registro nivel garantia
   /*************************************************************************
      Recupera los valores de si aplica derechos de registro a nivel de garantia
      param in psproduc  : codigo de producto
      param in pcactivi  : codigo de actividad
      param in pcgarant  : codigo de garantia
      param out pcderreg : codigo de si aplica derechos de registro
      param out mensajes : mensajes de error
   *************************************************************************/
   PROCEDURE p_derreggar (
      psproduc   IN       NUMBER,
      pcactivi   IN       NUMBER,
      pcgarant   IN       NUMBER,
      pcderreg   OUT      NUMBER,
      mensajes   OUT      t_iax_mensajes
   )
   IS
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (500)
         :=    'psproduc='
            || psproduc
            || ', pcactivi='
            || pcactivi
            || ', pcgarant='
            || pcgarant;
      vobject    VARCHAR2 (200) := 'PAC_MDPAR_PRODUCTOS.P_derreggar';
      ncount     NUMBER;
      vnumerr    NUMBER (8)     := 0;
   BEGIN
      -- Inicialitzacions
      IF psproduc IS NULL OR pcactivi IS NULL OR pcgarant IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      -- BUG9906:DRA:29/04/2009:Inici
      vnumerr :=
         pac_productos.f_derreggaranpro (psproduc,
                                         pcactivi,
                                         pcgarant,
                                         pcderreg
                                        );

      -- BUG9906:DRA:29/04/2009:Fi
      IF vnumerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
   END p_derreggar;

-- Fi Bug 0019578 - FAL - 26/09/2011

   /***********************************************************************
        Devuelve la descripcin del producto y el cdigo cmoneda(monedas) y cmoneda(eco_codmonedas)
        return   : valor del parametro
     ***********************************************************************/
   FUNCTION f_get_monedaproducto (
      psproduc   IN       NUMBER,
      pcmoneda   OUT      NUMBER,
      pcmonint   OUT      VARCHAR2,
      ptmoneda   OUT      VARCHAR2,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vcmodextra   NUMBER         := 0;
      verr         NUMBER         := 0;
      vpasexec     NUMBER (8)     := 1;
      vparam       VARCHAR2 (1)   := NULL;
      vobject      VARCHAR2 (200)
                                := 'PAC_MDPAR_PRODUCTOS.F_Get_monedaproducto';
      vcdivisa     NUMBER;
   BEGIN
      BEGIN
         SELECT cdivisa
           INTO vcdivisa
           FROM productos
          WHERE sproduc = psproduc;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            pcmoneda := NULL;
      END;

      IF vcdivisa IS NOT NULL
      THEN
         SELECT cmoneda
           INTO pcmoneda
           FROM codidivisa
          WHERE cdivisa = vcdivisa;

         IF pcmoneda IS NOT NULL
         THEN
            ptmoneda :=
               pac_md_listvalores.f_get_tmoneda (pcmoneda, pcmonint,
                                                 mensajes);
         END IF;
      END IF;

      RETURN verr;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_get_monedaproducto;

   -- BUG 0020671 - 03/01/2012 - JMF
   /***********************************************************************
      Recupera si la pregunta es visible o no
      param in  p_sproduc  : codigo de productos
      param in  p_cpregun  : codigo de pregunta
      param in  p_cactivi  : codigo de actividad
      param in  p_cgarant  : codigo de garantia
      param out p_cvisible : 0-> No visible   1-> Visible
      return               : devuelve 0 si todo bien, sino el codigo del error
   ***********************************************************************/
   FUNCTION f_get_pregunprogaranvisible (
      p_sproduc    IN       NUMBER,
      p_cpregun    IN       NUMBER,
      p_cactivi    IN       NUMBER,
      p_cgarant    IN       NUMBER,
      p_cvisible   OUT      NUMBER,
      mensajes     OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      --
      vpasexec   NUMBER         := 1;
      vparam     VARCHAR2 (500)
         :=    'pro='
            || p_sproduc
            || ' pre='
            || p_cpregun
            || ' act='
            || p_cactivi
            || ' gar='
            || p_cgarant;
      vobject    VARCHAR2 (200)
                          := 'PAC_MDPAR_PRODUCTOS.f_get_pregunprogaranvisible';
      w_err      NUMBER;
   BEGIN
      IF p_sproduc IS NULL OR p_cpregun IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      w_err :=
         pac_productos.f_get_pregunprogaranvisible (p_sproduc,
                                                    p_cpregun,
                                                    p_cactivi,
                                                    p_cgarant,
                                                    p_cvisible
                                                   );

      IF w_err <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, w_err);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   --
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN (w_err);
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN (w_err);
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN (w_err);
   END f_get_pregunprogaranvisible;

   -- BUG20498:DRA:09/01/2012:Inici
   /***********************************************************************
      Recupera las preguntas a nivel de clausulas
      param in psproduc  : codigo del producto
      param out mensajes : mensajes de error
      return             : objeto preguntas
   ***********************************************************************/
   FUNCTION f_get_pregclausulas (
      psproduc    IN       NUMBER,
      psimul      IN       BOOLEAN,               --BUG0009855:ETM: 28/05/2009
      pissuplem   IN       BOOLEAN,
      mensajes    IN OUT   t_iax_mensajes
   )
      RETURN t_iaxpar_preguntas
   IS
      preg          t_iaxpar_preguntas;
      resp          t_iaxpar_respuestas;
      vpasexec      NUMBER (8)          := 1;
      vparam        VARCHAR2 (500)      := 'psproduc=' || psproduc;
      vobject       VARCHAR2 (200)
                                 := 'PAC_MDPAR_PRODUCTOS.F_Get_pregclausulas';
      -- BUG 10470 - 01/07/2009 -JJG - Tratar preguntas tipo 6 - Tabla.i.
      vconsulta     VARCHAR2 (4000);
      cur           sys_refcursor;
      w_cprofes     VARCHAR2 (200);
      w_tprofes     VARCHAR2 (500);

      -- BUG 10470.f.
      -- BUG 6296 - 16/03/2009 - SBG - Afegim nou camp ctipgru al cursor
      CURSOR c_pregpro (pisaltacol IN NUMBER, pissuplemento IN NUMBER)
      IS
         SELECT   prepro.cpregun, preng.tpregun, prepro.cpretip,
                  prepro.npreord, prepro.tprefor, prepro.cpreobl,
                  prepro.cresdef, prepro.cofersn, prepro.tvalfor,
                  prepro.ctabla, prepro.cmodo, cpreg.ctippre, cpreg.ctipgru,
                  cpreg.tconsulta,
                  prepro.cvisible cvisible                 -- Bug 19504   JBN
             FROM pregunpro prepro, preguntas preng, codipregun cpreg
            WHERE prepro.cpregun = preng.cpregun
              AND preng.cidioma = pac_md_common.f_get_cxtidioma
              AND prepro.cnivel = 'C'
              AND (   (pissuplemento = 1 AND prepro.cmodo IN ('T', 'S'))
                   OR ((pissuplemento = 0) AND prepro.cmodo IN ('T', 'N'))
                  )
              AND (   prepro.cpretip <> 2
                   OR (    prepro.cpretip = 2
                       AND prepro.esccero = 1
                       AND pisaltacol = 1
                      )
-- Bug 16106 - RSC - 21/09/2010 - APR - Ajustes e implementacion para el alta de colectivos
                   OR (prepro.cvisible = 2)
                  )                                         -- Bug 19504   JBN
              AND (   (prepro.visiblecol = 1 AND pisaltacol = 1)
                   OR (pisaltacol = 0 AND prepro.visiblecert = 1)
                  )        -- Bug 17362 - APD - 01/02/2011 - Ajustes GROUPLIFE
              AND cpreg.cpregun = prepro.cpregun
              AND prepro.sproduc = psproduc
         ORDER BY prepro.npreord;

      CURSOR c_resppro (cprg NUMBER)
      IS
         SELECT   crespue, trespue
             FROM respuestas rsp
            WHERE rsp.cpregun = cprg
              AND rsp.cidioma = pac_md_common.f_get_cxtidioma
         ORDER BY rsp.crespue;

      -- Bug 16106 - RSC - 11/10/2010 - APR - Ajustes e implementacion para el alta de colectivos
      v_isaltacol   NUMBER;
      -- Fin Bug 16106
      v_issuplem    NUMBER              := 0;
   BEGIN
      --Inicialitzacions
      IF psproduc IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;

      -- Bug 16106 - RSC - 11/10/2010 - APR - Ajustes e implementacion para el alta de colectivos
      IF pac_iax_produccion.isaltacol
      THEN
         v_isaltacol := 1;
      ELSE
         v_isaltacol := 0;
      END IF;

      IF pissuplem = TRUE
      THEN
         v_issuplem := 1;
      ELSE
         v_issuplem := 0;
      END IF;

      -- Fin Bug 16106
      FOR prg IN c_pregpro (v_isaltacol, v_issuplem)
      LOOP
         vpasexec := 3;

         -- Bug 11432.13/10/2009.NMM.i.: CEM - Preguntas solo aparecen en simulaciones.
         IF    (psimul = FALSE AND prg.cofersn <> 2)
            OR (psimul = TRUE AND prg.cofersn IN (1, 2))
         THEN
            /*IF psimul = FALSE
               OR(psimul = TRUE
                  AND prg.cofersn <> 0) THEN   -- BUG 9855 - 28/05/2009 - ETM*/
            vpasexec := 4;

            IF preg IS NULL
            THEN
               vpasexec := 5;
               preg := t_iaxpar_preguntas ();
            END IF;

            vpasexec := 6;
            preg.EXTEND;
            preg (preg.LAST) := ob_iaxpar_preguntas ();
            preg (preg.LAST).cpregun := prg.cpregun;
            preg (preg.LAST).tpregun := prg.tpregun;
            preg (preg.LAST).cpretip := prg.cpretip;
            preg (preg.LAST).npreord := prg.npreord;
            preg (preg.LAST).tprefor := prg.tprefor;
            preg (preg.LAST).cpreobl := prg.cpreobl;
            preg (preg.LAST).cresdef := prg.cresdef;
            preg (preg.LAST).cofersn := prg.cofersn;
            preg (preg.LAST).tvalfor := prg.tvalfor;
            preg (preg.LAST).ctabla := prg.ctabla;
            preg (preg.LAST).cmodo := prg.cmodo;
            preg (preg.LAST).cvisible := NVL (prg.cvisible, 0);        --19504
            vpasexec := 7;

            IF prg.ctippre IN (4, 5)
            THEN                             -- tipo pregunta VF 78 detvalores
               vpasexec := 8;
               preg (preg.LAST).crestip := 0;             -- 0 es texto libre
            ELSIF prg.ctippre = 3
            THEN                                        -- tipo pregunta VF 78
               vpasexec := 9;
               preg (preg.LAST).crestip := 2;
             -- 2 indentifica que la resposta es texte pero es guarda crespue
            ELSE
               vpasexec := 10;
               preg (preg.LAST).crestip := 1;
                                             -- 1 la respuesta es desplegable
            END IF;

            vpasexec := 11;
            preg (preg.LAST).ctippre := prg.ctippre;  -- tipo pregunta (VF 78)
            -- BUG 6296 - 16/03/2009 - SBG - Informem nou camp ctipgru
            preg (preg.LAST).ctipgru := prg.ctipgru;
                                              -- tipo grupo preguntas (VF 309)
            resp := NULL;
            vpasexec := 12;

            -- BUG 10470 - 01/07/2009 -JJG/NMM - Tratar preguntas tipo 6 - Tabla.
            IF prg.ctippre = 6
            THEN
               vpasexec := 13;
               vconsulta :=
                  REPLACE (prg.tconsulta,
                           ':PMT_IDIOMA',
                           pac_md_common.f_get_cxtidioma
                          );
               -- INI Bug 0012227 - 03/12/2009 - JMF
               vconsulta := REPLACE (vconsulta, ':PMT_SPRODUC', psproduc);
               -- FIN Bug 0012227 - 03/12/2009 - JMF
               -- BUG26501 - 21/01/2014 - JTT: Passem els parametres PMT_POLIZA i PMT_SSEGURO
               vconsulta :=
                  REPLACE (vconsulta,
                           ':PMT_NPOLIZA',
                           pac_iax_produccion.poliza.det_poliza.npoliza
                          );
               vconsulta :=
                  REPLACE (vconsulta,
                           ':PMT_SSEGURO',
                           pac_iax_produccion.poliza.det_poliza.sseguro
                          );
               --JLV 23/04/2014 a¿adir el agente, es necesario para las campa¿as
               vconsulta :=
                  REPLACE (vconsulta,
                           ':PMT_CAGENTE',
                           pac_iax_produccion.poliza.det_poliza.cagente
                          );
               vpasexec := 14;
               cur := pac_md_listvalores.f_opencursor (vconsulta, mensajes);
               vpasexec := 15;

               FETCH cur
                INTO w_cprofes, w_tprofes;

               vpasexec := 16;

               WHILE cur%FOUND
               LOOP
                  IF resp IS NULL
                  THEN
                     vpasexec := 17;
                     resp := t_iaxpar_respuestas ();
                     preg (preg.LAST).crestip := 1;
                                    -- 1 respuesta desplegable; 0 texto libre
                  END IF;

                  vpasexec := 18;
                  resp.EXTEND;
                  resp (resp.LAST) := ob_iaxpar_respuestas ();
                  resp (resp.LAST).cpregun := prg.cpregun;
                  resp (resp.LAST).crespue := w_cprofes;
                  resp (resp.LAST).trespue := SUBSTR (w_tprofes, 1, 40);
                  vpasexec := 19;

                  FETCH cur
                   INTO w_cprofes, w_tprofes;

                  vpasexec := 20;
               END LOOP;

               vpasexec := 21;
               preg (preg.LAST).respuestas := resp;
            ELSE
               -- Fin BUG 10470 - 01/07/2009 -JJG - Tratar preguntas tipo 6 - Tabla.
               vpasexec := 22;

               FOR rsp IN c_resppro (prg.cpregun)
               LOOP
                  vpasexec := 23;

                  IF resp IS NULL
                  THEN
                     vpasexec := 24;
                     resp := t_iaxpar_respuestas ();
                     preg (preg.LAST).crestip := 1;
                          -- 1 la respuesta es desplegable - 0 es texto libre
                  END IF;

                  vpasexec := 25;
                  resp.EXTEND;
                  resp (resp.LAST) := ob_iaxpar_respuestas ();
                  resp (resp.LAST).cpregun := prg.cpregun;
                  resp (resp.LAST).crespue := rsp.crespue;
                  resp (resp.LAST).trespue := rsp.trespue;
                  vpasexec := 26;
               END LOOP;

               vpasexec := 27;
               preg (preg.LAST).respuestas := resp;
            END IF;                             -- BUG 10470 - 01/07/2009 -JJG
         END IF;
      END LOOP;

      vpasexec := 28;
      RETURN (preg);
   --
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_get_pregclausulas;

-- BUG20498:DRA:09/01/2012:Fi
/***********************************************************************
       Recupera las preguntas a nivel de poliza
       param in psproduc  : codigo del producto
       param out mensajes : mensajes de error
       return             : objeto preguntas
    ***********************************************************************/
   FUNCTION f_get_preguntab_pol (
      psproduc    IN       NUMBER,
      pcpregun    IN       NUMBER,
      psimul      IN       BOOLEAN,
      pissuplem   IN       BOOLEAN,
      mensajes    IN OUT   t_iax_mensajes
   )
      RETURN t_iax_preguntastab_columns
   IS
      tcolumnas     t_iax_preguntastab_columns;
      vpasexec      NUMBER (8)                 := 1;
      vparam        VARCHAR2 (500)
                    := 'psproduc=' || psproduc || ', pcpregun = ' || pcpregun;
      vobject       VARCHAR2 (200)
                                 := 'PAC_MDPAR_PRODUCTOS.f_get_preguntab_pol';
      vconsulta     VARCHAR2 (4000);
      cur           sys_refcursor;
      w_cprofes     VARCHAR2 (200);
      w_tprofes     VARCHAR2 (500);

      CURSOR c_pregprotab (pisaltacol IN NUMBER, pissuplemento IN NUMBER)
      IS
         SELECT   pt.cpregun, pt.columna, pt.tvalida, pt.ctipdato,
                  pt.cobliga, pt.crevaloriza, pc.ctipcol, pc.tconsulta,
                  pc.slitera
             FROM pregunpro prepro, pregunprotab pt, preguntab_colum pc
            WHERE prepro.cpregun = pt.cpregun
              AND pt.cpregun = pc.cpregun
              AND pt.columna = pc.ccolumn
              AND prepro.cpregun = pcpregun
              AND prepro.cnivel = 'P'
              AND (   (pissuplemento = 1 AND prepro.cmodo IN ('T', 'S'))
                   OR ((pissuplemento = 0) AND prepro.cmodo IN ('T', 'N'))
                  )
              AND (   prepro.cpretip <> 2
                   OR (    prepro.cpretip = 2
                       AND prepro.esccero = 1
                       AND pisaltacol = 1
                      )
                   OR (prepro.cvisible = 2)
                  )
              AND (   (prepro.visiblecol = 1 AND pisaltacol = 1)
                   OR (pisaltacol = 0 AND prepro.visiblecert = 1)
                  )
              AND prepro.sproduc = psproduc
              AND pt.sproduc = prepro.sproduc
         ORDER BY prepro.npreord;

      CURSOR c_lista (cprg NUMBER, colum VARCHAR2)
      IS
         SELECT   pcd.clista, tlista
             FROM preguntab_colum_lista pcl, preguntab_colum_deslista pcd
            WHERE pcl.cpregun = cprg
              AND pcd.cpregun = pcl.cpregun
              AND pcl.ccolumn = colum
              AND pcl.ccolumn = pcd.columna
              AND pcd.cidioma = pac_md_common.f_get_cxtidioma
              AND pcl.clista = pcd.clista
         ORDER BY pcd.clista;

      v_isaltacol   NUMBER;
      v_issuplem    NUMBER;
      vindex        NUMBER;
      catribu       NUMBER;
      tatribu       VARCHAR2 (1000);
   BEGIN
      --Inicialitzacions
      IF psproduc IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;

      IF pac_iax_produccion.isaltacol
      THEN
         v_isaltacol := 1;
      ELSE
         v_isaltacol := 0;
      END IF;

      IF pissuplem = TRUE
      THEN
         v_issuplem := 1;
      ELSE
         v_issuplem := 0;
      END IF;

      tcolumnas := t_iax_preguntastab_columns ();

      FOR prg IN c_pregprotab (v_isaltacol, v_issuplem)
      LOOP
         vpasexec := 3;
         tcolumnas.EXTEND;
         vindex := tcolumnas.LAST;
         tcolumnas (vindex) := ob_iax_preguntastab_columns ();
         tcolumnas (vindex).ccolumna := prg.columna;
         tcolumnas (vindex).tcolumna :=
                f_axis_literales (prg.slitera, pac_md_common.f_get_cxtidioma);
         tcolumnas (vindex).tvalida := prg.tvalida;
         tcolumnas (vindex).ctipdato := prg.ctipdato;
         tcolumnas (vindex).ttipdato :=
            ff_desvalorfijo (1079,
                             pac_md_common.f_get_cxtidioma,
                             prg.ctipdato
                            );
         tcolumnas (vindex).cobliga := prg.cobliga;
         tcolumnas (vindex).crevaloriza := prg.crevaloriza;
         tcolumnas (vindex).ctipcol := prg.ctipcol;
         tcolumnas (vindex).ttipcol :=
            ff_desvalorfijo (1079, pac_md_common.f_get_cxtidioma, prg.ctipcol);
         tcolumnas (vindex).tconsulta := prg.tconsulta;

         IF prg.ctipcol = 4
         THEN
            FOR rsp IN c_lista (pcpregun, prg.columna)
            LOOP
               IF tcolumnas (vindex).tlista IS NULL
               THEN
                  tcolumnas (vindex).tlista := t_iax_preglistatab ();
               END IF;

               tcolumnas (vindex).tlista.EXTEND;
               tcolumnas (vindex).tlista (tcolumnas (vindex).tlista.LAST) :=
                                                        ob_iax_preglistatab
                                                                           ();
               tcolumnas (vindex).tlista (tcolumnas (vindex).tlista.LAST).cpregun :=
                                                                      pcpregun;
               tcolumnas (vindex).tlista (tcolumnas (vindex).tlista.LAST).clista :=
                                                                    rsp.clista;
               tcolumnas (vindex).tlista (tcolumnas (vindex).tlista.LAST).tlista :=
                                                                    rsp.tlista;
               tcolumnas (vindex).tlista (tcolumnas (vindex).tlista.LAST).columna :=
                                                                   prg.columna;
            END LOOP;
         ELSIF prg.ctipcol = 5
         THEN
            vconsulta :=
               REPLACE (prg.tconsulta,
                        ':PMT_IDIOMA',
                        pac_md_common.f_get_cxtidioma
                       );
            vconsulta := REPLACE (vconsulta, ':PMT_SPRODUC', psproduc || ' ');
            -- BUG26501 - 21/01/2014 - JTT: Passem els parametres PMT_POLIZA i PMT_SSEGURO
            vconsulta :=
               REPLACE (vconsulta,
                        ':PMT_NPOLIZA',
                        pac_iax_produccion.poliza.det_poliza.npoliza
                       );
            vconsulta :=
               REPLACE (vconsulta,
                        ':PMT_SSEGURO',
                        pac_iax_produccion.poliza.det_poliza.sseguro
                       );
            --JLV 23/04/2014 a¿adir el agente, es necesario para las campa¿as
            vconsulta :=
               REPLACE (vconsulta,
                        ':PMT_CAGENTE',
                        pac_iax_produccion.poliza.det_poliza.cagente
                       );
            vpasexec := 14;
            cur := pac_md_listvalores.f_opencursor (vconsulta, mensajes);
            vpasexec := 15;

            FETCH cur
             INTO catribu, tatribu;

            vpasexec := 16;

            WHILE cur%FOUND
            LOOP
               IF tcolumnas (vindex).tlista IS NULL
               THEN
                  tcolumnas (vindex).tlista := t_iax_preglistatab ();
               END IF;

               tcolumnas (vindex).tlista.EXTEND;
               tcolumnas (vindex).tlista (tcolumnas (vindex).tlista.LAST) :=
                                                        ob_iax_preglistatab
                                                                           ();
               tcolumnas (vindex).tlista (tcolumnas (vindex).tlista.LAST).cpregun :=
                                                                      pcpregun;
               tcolumnas (vindex).tlista (tcolumnas (vindex).tlista.LAST).clista :=
                                                                       catribu;
               tcolumnas (vindex).tlista (tcolumnas (vindex).tlista.LAST).tlista :=
                                                                       tatribu;
               tcolumnas (vindex).tlista (tcolumnas (vindex).tlista.LAST).columna :=
                                                                   prg.columna;

               FETCH cur
                INTO catribu, tatribu;

               vpasexec := 20;
            END LOOP;
         END IF;
      END LOOP;

      vpasexec := 28;
      RETURN (tcolumnas);
   --
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_get_preguntab_pol;

   /***********************************************************************
      Recupera los datos del riesgo (preguntas)
      param in psproduc  : codigo del producto
      param in pcactivi  : codigo de actividad
      param in psimul    : indicador de simulacion
      param out mensajes : mensajes de error
      return             : objeto preguntas
   ***********************************************************************/
   FUNCTION f_get_preguntab_rie (
      psproduc   IN       NUMBER,
      pcactivi   IN       NUMBER,
      pcpregun   IN       NUMBER,
      psimul     IN       BOOLEAN,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN t_iax_preguntastab_columns
   IS
      preg          t_iaxpar_preguntas;
      resp          t_iaxpar_respuestas;
      vpasexec      NUMBER (8)                 := 1;
      vparam        VARCHAR2 (500)
         :=    'psproduc='
            || psproduc
            || ', pcactivi='
            || pcactivi
            || ', pcpregun='
            || pcpregun;
      vobject       VARCHAR2 (200)
                                  := 'PAC_MDPAR_PRODUCTOS.f_get_preguntab_rie';
      vconsulta     VARCHAR2 (4000);
      cur           sys_refcursor;
      w_cprofes     VARCHAR2 (200);
      w_tprofes     VARCHAR2 (500);
      v_isaltacol   NUMBER;
      tcolumnas     t_iax_preguntastab_columns;
      vindex        NUMBER;
      catribu       NUMBER;
      tatribu       VARCHAR2 (1000);

      CURSOR c_pregactivi (pisaltacol IN NUMBER, pissuplemento IN NUMBER)
      IS
         SELECT pt.cpregun, pt.columna, pt.tvalida, pt.ctipdato, pt.cobliga,
                pt.crevaloriza, pc.ctipcol, pc.tconsulta, pc.slitera
           FROM pregunproactivi preact,
                pregunproactivitab pt,
                preguntab_colum pc
          WHERE preact.cpregun = pt.cpregun
            AND pc.cpregun = pt.cpregun
            AND preact.cpregun = pcpregun
            AND preact.cactivi = pcactivi
            AND preact.cactivi = pt.cactivi
            AND preact.cpretip <> 2
            AND preact.sproduc = psproduc
            AND preact.sproduc = pt.sproduc
            AND pt.columna = pc.ccolumn
         UNION ALL
         SELECT pt.cpregun, pt.columna, pt.tvalida, pt.ctipdato, pt.cobliga,
                pt.crevaloriza, pc.ctipcol, pc.tconsulta, pc.slitera
           FROM pregunpro prepro, pregunprotab pt, preguntab_colum pc
          WHERE prepro.cnivel = 'R'
            AND (   (pissuplemento = 1 AND prepro.cmodo IN ('T', 'S'))
                 OR ((pissuplemento = 0) AND prepro.cmodo IN ('T', 'N'))
                )
            AND (   prepro.cpretip <> 2
                 OR (    prepro.cpretip = 2
                     AND prepro.esccero = 1
                     AND pisaltacol = 1
                    )
                 OR (prepro.cvisible = 2)
                )
            AND (   (prepro.visiblecol = 1 AND pisaltacol = 1)
                 OR (pisaltacol = 0 AND prepro.visiblecert = 1)
                )
            AND prepro.cpregun = pt.cpregun
            AND pt.cpregun = pc.cpregun
            AND pc.cpregun = pcpregun
            AND prepro.sproduc = psproduc
            AND prepro.sproduc = pt.sproduc
            AND pt.columna = pc.ccolumn;

      CURSOR c_lista (cprg NUMBER, colum VARCHAR2)
      IS
         SELECT   pcd.clista, tlista
             FROM preguntab_colum_lista pcl, preguntab_colum_deslista pcd
            WHERE pcl.cpregun = cprg
              AND pcd.cpregun = pcl.cpregun
              AND pcl.ccolumn = colum
              AND pcl.ccolumn = pcd.columna
              AND pcd.cidioma = pac_md_common.f_get_cxtidioma
              AND pcl.clista = pcd.clista
         ORDER BY pcd.clista;

      v_issuplem    NUMBER                     := 0;
   BEGIN
      --Inicialitzacions
      IF psproduc IS NULL OR pcactivi IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      -- Bug 16106 - RSC - 11/10/2010 - APR - Ajustes e implementacion para el alta de colectivos
      IF pac_iax_produccion.isaltacol
      THEN
         v_isaltacol := 1;
      ELSE
         v_isaltacol := 0;
      END IF;

      IF pac_iax_produccion.issuplem = TRUE
      THEN
         v_issuplem := 1;
      ELSE
         v_issuplem := 0;
      END IF;

      tcolumnas := t_iax_preguntastab_columns ();

      FOR prg IN c_pregactivi (v_isaltacol, v_issuplem)
      LOOP
         vpasexec := 3;
         tcolumnas.EXTEND;
         vindex := tcolumnas.LAST;
         tcolumnas (vindex) := ob_iax_preguntastab_columns ();
         tcolumnas (vindex).ccolumna := prg.columna;
         tcolumnas (vindex).tcolumna :=
                f_axis_literales (prg.slitera, pac_md_common.f_get_cxtidioma);
         tcolumnas (vindex).tvalida := prg.tvalida;
         tcolumnas (vindex).ctipdato := prg.ctipdato;
         tcolumnas (vindex).ttipdato :=
            ff_desvalorfijo (1079,
                             pac_md_common.f_get_cxtidioma,
                             prg.ctipdato
                            );
         tcolumnas (vindex).cobliga := prg.cobliga;
         tcolumnas (vindex).crevaloriza := prg.crevaloriza;
         tcolumnas (vindex).ctipcol := prg.ctipcol;
         tcolumnas (vindex).ttipcol :=
            ff_desvalorfijo (1079, pac_md_common.f_get_cxtidioma, prg.ctipcol);
         tcolumnas (vindex).tconsulta := prg.tconsulta;

         IF prg.ctipcol = 4
         THEN
            FOR rsp IN c_lista (pcpregun, prg.columna)
            LOOP
               IF tcolumnas (vindex).tlista IS NULL
               THEN
                  tcolumnas (vindex).tlista := t_iax_preglistatab ();
               END IF;

               tcolumnas (vindex).tlista.EXTEND;
               tcolumnas (vindex).tlista (tcolumnas (vindex).tlista.LAST) :=
                                                        ob_iax_preglistatab
                                                                           ();
               tcolumnas (vindex).tlista (tcolumnas (vindex).tlista.LAST).cpregun :=
                                                                      pcpregun;
               tcolumnas (vindex).tlista (tcolumnas (vindex).tlista.LAST).clista :=
                                                                    rsp.clista;
               tcolumnas (vindex).tlista (tcolumnas (vindex).tlista.LAST).tlista :=
                                                                    rsp.tlista;
               tcolumnas (vindex).tlista (tcolumnas (vindex).tlista.LAST).columna :=
                                                                   prg.columna;
            END LOOP;
         ELSIF prg.ctipcol = 5
         THEN
            vconsulta :=
               REPLACE (prg.tconsulta,
                        ':PMT_IDIOMA',
                        pac_md_common.f_get_cxtidioma
                       );
            vconsulta := REPLACE (vconsulta, ':PMT_SPRODUC', psproduc || ' ');
            -- BUG26501 - 21/01/2014 - JTT: Passem els parametres PMT_POLIZA i PMT_SSEGURO
            vconsulta :=
               REPLACE (vconsulta,
                        ':PMT_NPOLIZA',
                        pac_iax_produccion.poliza.det_poliza.npoliza
                       );
            vconsulta :=
               REPLACE (vconsulta,
                        ':PMT_SSEGURO',
                        pac_iax_produccion.poliza.det_poliza.sseguro
                       );
            --JLV 23/04/2014 a¿adir el agente, es necesario para las campa¿as
            vconsulta :=
               REPLACE (vconsulta,
                        ':PMT_CAGENTE',
                        pac_iax_produccion.poliza.det_poliza.cagente
                       );
            vpasexec := 14;
            cur := pac_md_listvalores.f_opencursor (vconsulta, mensajes);
            vpasexec := 15;

            FETCH cur
             INTO catribu, tatribu;

            vpasexec := 16;

            WHILE cur%FOUND
            LOOP
               IF tcolumnas (vindex).tlista IS NULL
               THEN
                  tcolumnas (vindex).tlista := t_iax_preglistatab ();
               END IF;

               tcolumnas (vindex).tlista.EXTEND;
               tcolumnas (vindex).tlista (tcolumnas (vindex).tlista.LAST) :=
                                                        ob_iax_preglistatab
                                                                           ();
               tcolumnas (vindex).tlista (tcolumnas (vindex).tlista.LAST).cpregun :=
                                                                      pcpregun;
               tcolumnas (vindex).tlista (tcolumnas (vindex).tlista.LAST).clista :=
                                                                       catribu;
               tcolumnas (vindex).tlista (tcolumnas (vindex).tlista.LAST).tlista :=
                                                                       tatribu;
               tcolumnas (vindex).tlista (tcolumnas (vindex).tlista.LAST).columna :=
                                                                   prg.columna;

               FETCH cur
                INTO catribu, tatribu;

               vpasexec := 20;
            END LOOP;
         END IF;
      END LOOP;

      RETURN (tcolumnas);
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_get_preguntab_rie;

   /***********************************************************************
      Recupera las preguntas a nivel de garantia
      param in psproduc  : codigo del producto
      param in pcactivi  : codigo de actividad
      param in pcgarant  : codigo de garantia
      param out mensajes : mensajes de error
      return             : objeto preguntas
   ***********************************************************************/
   FUNCTION f_get_preguntab_gar (
      psproduc   IN       NUMBER,
      pcactivi   IN       NUMBER,
      pcpregun   IN       NUMBER,
      pcgarant   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN t_iax_preguntastab_columns
   IS
      preg             t_iaxpar_preguntas;
      resp             t_iaxpar_respuestas;
      vpasexec         NUMBER (8)                 := 1;
      vparam           VARCHAR2 (500)
         :=    'psproduc='
            || psproduc
            || ', pcactivi='
            || pcactivi
            || ', pcgarant='
            || pcgarant;
      vobject          VARCHAR2 (200)
                                  := 'PAC_MDPAR_PRODUCTOS.f_get_preguntab_gar';
      -- BUG 10470 - 01/07/2009 - NMM - Tratar preguntas tipo 6 - Tabla.i.
      vconsulta        VARCHAR2 (4000);
      cur              sys_refcursor;
      w_cprofes        VARCHAR2 (200);
      w_tprofes        VARCHAR2 (500);
      tcolumnas        t_iax_preguntastab_columns;
      vindex           NUMBER;
      catribu          NUMBER;
      tatribu          VARCHAR2 (1000);

-- Se controla el orden de presentacion de las preguntas para ello damos formato numerico SSM
      CURSOR c_preggar (
         ppcgarant       IN   NUMBER,
         pisaltacol      IN   NUMBER,
         pissuplemento   IN   NUMBER
      )
      IS
         SELECT   pt.cpregun, TO_NUMBER (pt.columna) columna, pt.tvalida,
                  pt.ctipdato, pt.cobliga, pt.crevaloriza, pc.ctipcol,
                  pc.tconsulta, pc.slitera
             FROM pregunprogaran pregar,
                  pregunprogarantab pt,
                  preguntab_colum pc
            WHERE pregar.cpregun = pt.cpregun
              AND pt.cpregun = pc.cpregun
              AND pc.cpregun = pcpregun
              AND pregar.sproduc = psproduc
              AND pregar.sproduc = pt.sproduc
              AND pregar.cactivi = pcactivi
              AND pregar.cactivi = pt.cactivi
              AND (   pregar.cpretip <> 2
                   OR (    pregar.cpretip = 2
                       AND pregar.esccero = 1
                       AND pisaltacol = 1
                      )
-- Bug 16106 - RSC - 21/09/2010 - APR - Ajustes e implementacion para el alta de colectivos
                   OR (pregar.cvisible = 2)
                  )                                         -- Bug 19504   JBN
              AND (   (   (pregar.visiblecol = 1 AND pisaltacol = 1)
                       OR (pisaltacol = 0 AND pregar.visiblecert = 1
                          )
                           -- Bug 17362 - APD - 01/02/2011 - Ajustes GROUPLIFE
                      )
                   OR (NVL
                          (pac_parametros.f_parempresa_n
                                           (pac_md_common.f_get_cxtempresa (),
                                            'PREGTAB_EDIT_PROP'
                                           ),
                           0
                          ) = 1
                      )                      -- BUG 0042913 - FAL - 07/06/2016
                  )
              AND pregar.cgarant = ppcgarant
              AND pregar.cgarant = pt.cgarant
              AND pt.columna = pc.ccolumn
              AND (   (pissuplemento = 1 AND pregar.cmodo IN ('T', 'S'))
                   OR ((pissuplemento = 0) AND pregar.cmodo IN ('T', 'N'))
                  )
         UNION
         SELECT   pt.cpregun, TO_NUMBER (pt.columna) columna, pt.tvalida,
                  pt.ctipdato, pt.cobliga, pt.crevaloriza, pc.ctipcol,
                  pc.tconsulta, pc.slitera
             FROM pregunprogaran pregar,
                  pregunprogarantab pt,
                  preguntab_colum pc
            WHERE pregar.cpregun = pt.cpregun
              AND pt.cpregun = pc.cpregun
              AND pc.cpregun = pcpregun
              AND pregar.sproduc = psproduc
              AND pregar.sproduc = pt.sproduc
              AND pregar.cactivi = 0
              AND pregar.cactivi = pt.cactivi
              AND (   pregar.cpretip <> 2
                   OR (    pregar.cpretip = 2
                       AND pregar.esccero = 1
                       AND pisaltacol = 1
                      )
-- Bug 16106 - RSC - 21/09/2010 - APR - Ajustes e implementacion para el alta de colectivos
                   OR (pregar.cvisible = 2)
                  )                                         -- Bug 19504   JBN
              AND (   (pregar.visiblecol = 1 AND pisaltacol = 1)
                   OR (pisaltacol = 0 AND pregar.visiblecert = 1)
                  )        -- Bug 17362 - APD - 01/02/2011 - Ajustes GROUPLIFE
              AND pregar.cgarant = ppcgarant
              AND pregar.cgarant = pt.cgarant
              AND pt.columna = pc.ccolumn
              AND (   (pissuplemento = 1 AND pregar.cmodo IN ('T', 'S'))
                   OR ((pissuplemento = 0) AND pregar.cmodo IN ('T', 'N'))
                  )
              AND NOT EXISTS (
                     SELECT pt.cpregun, TO_NUMBER (pt.columna) columna,
                            pt.tvalida, pt.ctipdato, pt.cobliga,
                            pt.crevaloriza, pc.ctipcol, pc.tconsulta,
                            pc.slitera
                       FROM pregunprogaran pregar,
                            pregunprogarantab pt,
                            preguntab_colum pc
                      WHERE pregar.cpregun = pt.cpregun
                        AND pt.cpregun = pc.cpregun
                        AND pc.cpregun = pcpregun
                        AND pregar.sproduc = psproduc
                        AND pregar.sproduc = pt.sproduc
                        AND pregar.cactivi = pcactivi
                        AND pregar.cactivi = pt.cactivi
                        AND (   pregar.cpretip <> 2
                             OR (    pregar.cpretip = 2
                                 AND pregar.esccero = 1
                                 AND pisaltacol = 1
                                )
-- Bug 16106 - RSC - 21/09/2010 - APR - Ajustes e implementacion para el alta de colectivos
                             OR (pregar.cvisible = 2)
                            )                               -- Bug 19504   JBN
                        AND (   (pregar.visiblecol = 1 AND pisaltacol = 1)
                             OR (pisaltacol = 0 AND pregar.visiblecert = 1)
                            )
                           -- Bug 17362 - APD - 01/02/2011 - Ajustes GROUPLIFE
                        AND pregar.cgarant = ppcgarant
                        AND pregar.cgarant = pt.cgarant
                        AND pt.columna = pc.ccolumn
                        AND (   (    pissuplemento = 1
                                 AND pregar.cmodo IN ('T', 'S')
                                )
                             OR (    (pissuplemento = 0)
                                 AND pregar.cmodo IN ('T', 'N')
                                )
                            ))
         ORDER BY columna;                                   --pregar.npreord;

      CURSOR c_lista (cprg NUMBER, colum VARCHAR2)
      IS
         SELECT   pcd.clista, tlista
             FROM preguntab_colum_lista pcl, preguntab_colum_deslista pcd
            WHERE pcl.cpregun = cprg
              AND pcd.cpregun = pcl.cpregun
              AND pcl.ccolumn = colum
              AND pcl.ccolumn = pcd.columna
              AND pcd.cidioma = pac_md_common.f_get_cxtidioma
              AND pcl.clista = pcd.clista
         ORDER BY pcd.clista;

      v_isaltacol      NUMBER;
      v_issuplem       NUMBER                     := 0;
      v_altacolectiv   BOOLEAN;
   BEGIN
      --Inicialitzacions
      IF psproduc IS NULL OR pcactivi IS NULL OR pcgarant IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      -- Bug 16106 - RSC - 11/10/2010 - APR - Ajustes e implementacion para el alta de colectivos
      IF pac_iax_produccion.isaltacol
      THEN
         v_isaltacol := 1;
      ELSE
         v_isaltacol := 0;
      END IF;

      IF pac_iax_produccion.issuplem = TRUE
      THEN
         v_issuplem := 1;
      ELSE
         v_issuplem := 0;
      END IF;

      -- ini Bug 0032784 - 16/09/2014 - JMF
       -- QT 13462 : recalcular valor isaltacol
      DECLARE
         v_admite_cert   NUMBER;
         v_existe        NUMBER;
         v_escertif0     NUMBER;
      BEGIN
         v_admite_cert :=
                  NVL (f_parproductos_v (psproduc, 'ADMITE_CERTIFICADOS'), 0);
         v_altacolectiv := FALSE;

         IF v_admite_cert = 1
         THEN
            v_existe :=
               pac_seguros.f_get_escertifcero
                                (pac_iax_produccion.poliza.det_poliza.npoliza);

            IF v_issuplem = 0
            THEN
               v_escertif0 :=
                  pac_seguros.f_get_escertifcero
                                (NULL,
                                 pac_iax_produccion.poliza.det_poliza.sseguro
                                );
            ELSE
               v_escertif0 :=
                  pac_seguros.f_get_escertifcero
                                (NULL,
                                 pac_iax_produccion.poliza.det_poliza.ssegpol
                                );
            END IF;

            IF v_escertif0 > 0
            THEN
               v_altacolectiv := TRUE;
            ELSE
               IF v_existe <= 0
               THEN
                  v_altacolectiv := TRUE;
               END IF;
            END IF;
         END IF;

         -------
         IF v_altacolectiv
         THEN
            v_isaltacol := 1;
         ELSE
            v_isaltacol := 0;
         END IF;
      END;

      -- fin Bug 0032784 - 16/09/2014 - JMF
      tcolumnas := t_iax_preguntastab_columns ();

      FOR prg IN c_preggar (pcgarant, v_isaltacol, v_issuplem)
      LOOP
         vpasexec := 3;
         tcolumnas.EXTEND;
         vindex := tcolumnas.LAST;
         tcolumnas (vindex) := ob_iax_preguntastab_columns ();
         tcolumnas (vindex).ccolumna := prg.columna;
         tcolumnas (vindex).tcolumna :=
                f_axis_literales (prg.slitera, pac_md_common.f_get_cxtidioma);
         tcolumnas (vindex).tvalida := prg.tvalida;
         tcolumnas (vindex).ctipdato := prg.ctipdato;
         tcolumnas (vindex).ttipdato :=
            ff_desvalorfijo (1079,
                             pac_md_common.f_get_cxtidioma,
                             prg.ctipdato
                            );
         tcolumnas (vindex).cobliga := prg.cobliga;
         tcolumnas (vindex).crevaloriza := prg.crevaloriza;
         tcolumnas (vindex).ctipcol := prg.ctipcol;
         tcolumnas (vindex).ttipcol :=
            ff_desvalorfijo (1079, pac_md_common.f_get_cxtidioma, prg.ctipcol);
         tcolumnas (vindex).tconsulta := prg.tconsulta;

         IF prg.ctipcol = 4
         THEN
            FOR rsp IN c_lista (pcpregun, prg.columna)
            LOOP
               IF tcolumnas (vindex).tlista IS NULL
               THEN
                  tcolumnas (vindex).tlista := t_iax_preglistatab ();
               END IF;

               tcolumnas (vindex).tlista.EXTEND;
               tcolumnas (vindex).tlista (tcolumnas (vindex).tlista.LAST) :=
                                                        ob_iax_preglistatab
                                                                           ();
               tcolumnas (vindex).tlista (tcolumnas (vindex).tlista.LAST).cpregun :=
                                                                      pcpregun;
               tcolumnas (vindex).tlista (tcolumnas (vindex).tlista.LAST).clista :=
                                                                    rsp.clista;
               tcolumnas (vindex).tlista (tcolumnas (vindex).tlista.LAST).tlista :=
                                                                    rsp.tlista;
               tcolumnas (vindex).tlista (tcolumnas (vindex).tlista.LAST).columna :=
                                                                   prg.columna;
            END LOOP;
         ELSIF prg.ctipcol = 5
         THEN
            vconsulta :=
               REPLACE (prg.tconsulta,
                        ':PMT_IDIOMA',
                        pac_md_common.f_get_cxtidioma
                       );
            vconsulta := REPLACE (vconsulta, ':PMT_SPRODUC', psproduc || ' ');
            --Bug 27768/150984 - 03/09/2013 - AMC
            vconsulta := REPLACE (vconsulta, ':PMT_CGARANT', pcgarant || ' ');
            --Fi Bug 27768/150984 - 03/09/2013 - AMC
            -- BUG26501 - 21/01/2014 - JTT: Passem els parametres PMT_POLIZA i PMT_SSEGURO
            vconsulta :=
               REPLACE (vconsulta,
                        ':PMT_NPOLIZA',
                        pac_iax_produccion.poliza.det_poliza.npoliza
                       );
            vconsulta :=
               REPLACE (vconsulta,
                        ':PMT_SSEGURO',
                        pac_iax_produccion.poliza.det_poliza.sseguro
                       );
            --JLV 23/04/2014 a¿adir el agente, es necesario para las campa¿as
            vconsulta :=
               REPLACE (vconsulta,
                        ':PMT_CAGENTE',
                        pac_iax_produccion.poliza.det_poliza.cagente
                       );
            vpasexec := 14;
            cur := pac_md_listvalores.f_opencursor (vconsulta, mensajes);
            vpasexec := 15;

            FETCH cur
             INTO catribu, tatribu;

            vpasexec := 16;

            WHILE cur%FOUND
            LOOP
               IF tcolumnas (vindex).tlista IS NULL
               THEN
                  tcolumnas (vindex).tlista := t_iax_preglistatab ();
               END IF;

               tcolumnas (vindex).tlista.EXTEND;
               tcolumnas (vindex).tlista (tcolumnas (vindex).tlista.LAST) :=
                                                        ob_iax_preglistatab
                                                                           ();
               tcolumnas (vindex).tlista (tcolumnas (vindex).tlista.LAST).cpregun :=
                                                                      pcpregun;
               tcolumnas (vindex).tlista (tcolumnas (vindex).tlista.LAST).clista :=
                                                                       catribu;
               tcolumnas (vindex).tlista (tcolumnas (vindex).tlista.LAST).tlista :=
                                                                       tatribu;
               tcolumnas (vindex).tlista (tcolumnas (vindex).tlista.LAST).columna :=
                                                                   prg.columna;

               FETCH cur
                INTO catribu, tatribu;

               vpasexec := 20;
            END LOOP;
         END IF;
      END LOOP;

      vpasexec := 28;
      RETURN (tcolumnas);
   --
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_get_preguntab_gar;

   FUNCTION f_get_cabecera_preguntab (
      psproduc    IN       NUMBER,
      pcactivi    IN       NUMBER,
      ptipo       IN       VARCHAR2,
      pcpregun    IN       NUMBER,
      pcgarant    IN       NUMBER,
      psimul      IN       BOOLEAN,
      pissuplem   IN       BOOLEAN,
      mensajes    IN OUT   t_iax_mensajes
   )
      RETURN t_iax_preguntastab_columns
   IS
      vpasexec     NUMBER (8)                 := 1;
      vparam       VARCHAR2 (4000)
         :=    'pcpregun : '
            || pcpregun
            || ',ptipo : '
            || ptipo
            || ',psproduc : '
            || psproduc
            || ',pcactivi : '
            || pcactivi
            || ',pcgarant : '
            || pcgarant;
      vobject      VARCHAR2 (200)
                             := 'PAC_MDPAR_PRODUCTOS.f_get_cabecera_preguntab';
      num_err      NUMBER                     := 0;
      cur          sys_refcursor;
      squery       VARCHAR2 (200);
      tpreguntas   t_iax_preguntastab_columns;
   BEGIN
      IF ptipo = 'P'
      THEN
         tpreguntas :=
            f_get_preguntab_pol (psproduc,
                                 pcpregun,
                                 psimul,
                                 pissuplem,
                                 mensajes
                                );
      ELSIF ptipo = 'R'
      THEN
         tpreguntas :=
            f_get_preguntab_rie (psproduc,
                                 pcactivi,
                                 pcpregun,
                                 psimul,
                                 mensajes
                                );
      ELSIF ptipo = 'G'
      THEN
         tpreguntas :=
            f_get_preguntab_gar (psproduc,
                                 pcactivi,
                                 pcpregun,
                                 pcgarant,
                                 mensajes
                                );
      END IF;

      RETURN tpreguntas;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_get_cabecera_preguntab;

   /***********************************************************************
      Recupera las franquicias del producto
      param in psproduc  : codigo del producto
      param in pcactivi  : codigo de actividad
      param in psimul    : indicador de simulacion
      param out mensajes : mensajes de error
      return             : objeto preguntas
   ***********************************************************************/
   FUNCTION f_get_franquicias (
      psproduc     IN       NUMBER,
      pcactivi     IN       NUMBER,
      pnriesgo     IN       NUMBER,
      psseguro     IN       NUMBER,
      pnmovimi     IN       NUMBER,
      pfefecto     IN       DATE,
      pssegpol     IN       NUMBER,
      pcgrup       IN       NUMBER,
      pcsubgrup    IN       NUMBER,
      pcversion    IN       NUMBER,
      pcnivel      IN       NUMBER,
      pcvalor1     IN       NUMBER,
      pimpvalor1   IN       NUMBER,
      pcvalor2     IN       NUMBER,
      pimpvalor2   IN       NUMBER,
      pcimpmin     IN       NUMBER,
      pimpmin      IN       NUMBER,
      pcimpmax     IN       NUMBER,
      pimpmax      IN       NUMBER,
      psuplem      IN       BOOLEAN,
      psimul       IN       BOOLEAN,
      pcgarant     IN       NUMBER,
      mensajes     IN OUT   t_iax_mensajes
   )
      RETURN t_iax_bf_proactgrup
   IS
      tprodfranq       t_iax_bf_proactgrup;
      resp             t_iaxpar_respuestas;
      vpasexec         NUMBER (8)            := 1;
      vparam           VARCHAR2 (500)
                      := 'psproduc=' || psproduc || ', pcactivi=' || pcactivi;
      vobject          VARCHAR2 (200)
                                   := 'PAC_MDPAR_PRODUCTOS.F_Get_franquicias';
      cur              sys_refcursor;
      v_isaltacol      NUMBER;
      vindex           NUMBER;
      vindex2          NUMBER;
      vindex3          NUMBER;
      vindex4          NUMBER;
      tprodfranqgar    t_iax_bf_progarangrup;
      tgrupsubgrup     t_iax_bf_grupsubgrup;
      vsubgrup         NUMBER;
      tdetnivel        t_iax_bf_detnivel;

      -- Fin Bug 16106

      -- BUG 6296 - 16/03/2009 - SBG - Afegim nou camp ctipgru al cursor
      CURSOR c_franq (pisaltacol IN NUMBER, pissuplemento IN NUMBER)
      IS
         SELECT   bfp.*
             FROM bf_proactgrup bfp
            WHERE bfp.sproduc = psproduc
              AND bfp.cactivi = pcactivi
              AND bfp.cgrup = NVL (pcgrup, bfp.cgrup)
              AND cempres = pac_md_common.f_get_cxtempresa
--Bug 28610/0158924 - JSV - 14/11/2013
              AND pisaltacol = 0
              AND (   pcgarant IS NULL
                   OR (bfp.cgrup IN (
                          SELECT bfpg.codgrup
                            FROM bf_progarangrup bfpg
                           WHERE bfpg.cempres = bfp.cempres
                             AND bfpg.sproduc = bfp.sproduc
                             AND bfpg.cactivi = bfp.cactivi
                             -- INI IAXIS-5423  CJMR 23/09/2019
                             AND bfpg.cgarant in (select gp.cgarant from garanpro gp
                                                  where gp.sproduc = psproduc
                                                  and gp.cactivi = pcactivi
                                                  and gp.cgarant = pcgarant
                                                  union
                                                  select gp.cgarant from garanpro gp
                                                  where gp.sproduc = psproduc
                                                  and gp.cactivi = pcactivi
                                                  and gp.cgardep = pcgarant)--= pcgarant
                             -- FIN IAXIS-5423  CJMR 23/09/2019
                                                        /*AND(psseguro IS NULL
                                                             OR (pcgarant is not null and bfpg.codgrup NOT IN(SELECT cgrup
                                                                                      FROM estbf_bonfranseg
                                                                                     WHERE sseguro = psseguro )))*/
                       )
                      )
                  )
         ORDER BY norden;

      vformula         NUMBER                := 1;
      v_issuplem       NUMBER                := 0;
      vcnivel          NUMBER;
      vcvalor1         NUMBER;
      vimpvalor1       NUMBER;
      vcvalor2         NUMBER;
      vimpvalor2       NUMBER;
      vcimpmin         NUMBER;
      vimpmin          NUMBER;
      vcimpmax         NUMBER;
      vimpmax          NUMBER;
      vnumerr          NUMBER;
      lvalor2          NUMBER;
      limpmin          NUMBER;
      limpmax          NUMBER;
      vvalor           NUMBER;
      vcmodali         NUMBER;
      vccolect         NUMBER;
      vctipseg         NUMBER;
      vcramo           NUMBER;
      v_crealiza       NUMBER;
      vdefectogrup     NUMBER;
      vcniveldefecto   NUMBER;
      -- INI IAXIS-5423  CJMR 23/09/2019
      v_impdef         NUMBER := NULL;
      vexistenivdef    BOOLEAN;
      vcnivdef         NUMBER;
      -- FIN IAXIS-5423  CJMR 23/09/2019
   BEGIN
      
      --Inicialitzacions
      IF psproduc IS NULL OR pcactivi IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      -- Bug 16106 - RSC - 11/10/2010 - APR - Ajustes e implementacion para el alta de colectivos
      IF pac_iax_produccion.isaltacol
      THEN
         v_isaltacol := 1;
      ELSE
         v_isaltacol := 0;
      END IF;

      IF pac_iax_produccion.issuplem = TRUE
      THEN
         v_issuplem := 1;
      ELSE
         v_issuplem := 0;
      END IF;

      vpasexec := 2;

      FOR frq IN c_franq (v_isaltacol, v_issuplem)
      LOOP
         vdefectogrup := NULL;

         IF tprodfranq IS NULL
         THEN
            tprodfranq := t_iax_bf_proactgrup ();
         END IF;

         tprodfranq.EXTEND;
         vindex := tprodfranq.LAST;
         tprodfranq (vindex) := ob_iax_bf_proactgrup ();
         tprodfranq (vindex).cempres := frq.cempres;
         tprodfranq (vindex).sproduc := frq.sproduc;
         tprodfranq (vindex).cactivi := frq.cactivi;
         tprodfranq (vindex).ffecini := frq.ffecini;
         tprodfranq (vindex).cgrup := frq.cgrup;
         tprodfranq (vindex).cobliga := frq.cobliga;
         tprodfranq (vindex).cformulasub := frq.cformulasub;
         tprodfranq (vindex).csubgrupunic := frq.csubgrupunic;
         tprodfranq (vindex).norden := frq.norden;
         tprodfranq (vindex).teccontra := frq.teccontra;
         tprodfranq (vindex).ffecfin := frq.ffecfin;

         IF pcnivel IS NULL
         THEN
            IF frq.formuladefecto IS NOT NULL
            THEN
               vnumerr :=
                  pac_bonfran.f_resuelve_formula (1,
                                                  psseguro,
                                                  pcactivi,
                                                  psproduc,
                                                  frq.cgrup,
                                                  pfefecto,
                                                  pnriesgo,
                                                  frq.formuladefecto,
                                                  pnmovimi,
                                                  vdefectogrup
                                                 );

               IF vnumerr <> 0
               THEN
                  RAISE e_object_error;
               END IF;

               tprodfranq (vindex).formuladefecto := vdefectogrup;
                                                         --frq.formuladefecto;
               p_tab_error (f_sysdate,
                            f_user,
                            'TEST',
                            1,
                            'grup - vdefectogrup',
                            frq.cgrup || '-' || vdefectogrup
                           );
            END IF;
         END IF;

         vpasexec := 3;
         tprodfranqgar := t_iax_bf_progarangrup ();

         SELECT cmodali, ccolect, ctipseg, cramo
           INTO vcmodali, vccolect, vctipseg, vcramo
           FROM productos
          WHERE sproduc = psproduc;

         FOR frqgar IN (SELECT   bfpa.cgarant, gp.cgarpadre, gp.cvisniv
                            FROM bf_proactgrup bfp,
                                 bf_progarangrup bfpa,
                                 garanpro gp
                           WHERE bfp.cempres = bfpa.cempres
                             AND bfp.cactivi = bfpa.cactivi
                             AND bfp.sproduc = bfpa.sproduc
                             AND bfp.cgrup = bfpa.codgrup
                             AND bfp.ffecini = bfpa.ffecini
                             AND bfp.sproduc = psproduc
                             AND bfp.cactivi = pcactivi
                             AND bfp.cgrup = frq.cgrup
                             AND bfp.ffecini = frq.ffecini
                             AND bfp.cempres = pac_md_common.f_get_cxtempresa
                             AND gp.sproduc = bfp.sproduc
                             AND gp.cactivi = bfp.cactivi  -- IAXIS-5423  CJMR 23/09/2019
                             AND gp.cmodali = vcmodali
                             AND gp.ccolect = vccolect
                             AND gp.ctipseg = vctipseg
                             AND gp.cramo = vcramo
                             AND gp.cgarant = bfpa.cgarant
                        ORDER BY bfp.norden)
         LOOP
            IF tprodfranqgar IS NULL
            THEN
               tprodfranqgar := t_iax_bf_progarangrup ();
            END IF;

            vpasexec := 4;
            tprodfranqgar.EXTEND;
            vindex2 := tprodfranqgar.LAST;
            tprodfranqgar (vindex2) := ob_iax_bf_progarangrup ();
            tprodfranqgar (vindex2).cgarant := frqgar.cgarant;
            tprodfranqgar (vindex2).tgarant :=
                ff_desgarantia (frqgar.cgarant, pac_md_common.f_get_cxtidioma);
            tprodfranqgar (vindex2).cgarpadre := frqgar.cgarpadre;
            tprodfranqgar (vindex2).cvisniv := frqgar.cvisniv;

            BEGIN
               SELECT DECODE (cgarant, g01, 1, g02, 2, g03, 3, NULL)
                 INTO tprodfranqgar (vindex2).cnivgar
                 FROM garanprored
                WHERE sproduc = psproduc
                  AND cactivi = pcactivi
                  AND cgarant = frqgar.cgarant
                  AND fmovfin IS NULL;
            EXCEPTION
               WHEN OTHERS
               THEN
                  tprodfranqgar (vindex2).cnivgar := NULL;
            END;

            vnumerr :=
               pac_cfg.f_get_user_accion_permitida
                                           (f_user,
                                            'NIVEL_VISIONGAR',
                                            psproduc,
                                            pac_md_common.f_get_cxtempresa (),
                                            v_crealiza
                                           );

            IF NVL (frqgar.cvisniv, 1) > NVL (v_crealiza, 3)
            THEN
               tprodfranqgar (vindex2).cvisible := 0;
            ELSE
               tprodfranqgar (vindex2).cvisible := 1;
            END IF;
         END LOOP;

         tprodfranq (vindex).garantias := tprodfranqgar;
         tprodfranq (vindex).grupo := ob_iax_bf_codgrup ();
         tprodfranq (vindex).grupo.cempres := frq.cempres;
         tprodfranq (vindex).grupo.cgrup := frq.cgrup;
         vpasexec := 5;

         SELECT b.cversion,
                b.ctipgrup,
                b.ctipvisgrup,
                bd.tgrup,
                ff_desvalorfijo (309,
                                 pac_md_common.f_get_cxtidioma,
                                 b.ctipvisgrup
                                ) ttipvisgrup
           INTO tprodfranq (vindex).grupo.cversion,
                tprodfranq (vindex).grupo.ctipgrup,
                tprodfranq (vindex).grupo.ctipvisgrup,
                tprodfranq (vindex).grupo.tgrup,
                tprodfranq (vindex).grupo.ttipvisgrup
           FROM bf_codgrup b, bf_desgrup bd, bf_versiongrup bv
          WHERE b.cgrup = frq.cgrup
            AND bd.cgrup = b.cgrup
            --    AND ctipgrup = 2   --franquicies
            AND bd.cempres = pac_md_common.f_get_cxtempresa
            AND bd.cempres = b.cempres
            AND bv.cempres = bd.cempres
            AND b.cversion = bd.cversion
            AND b.cversion = bv.cversion
            AND bv.cempres = b.cempres
            AND bv.cgrup = b.cgrup
            AND (   (pcversion IS NOT NULL AND b.cversion = pcversion)
                 OR ((   (    v_issuplem = 1
                          AND (       EXISTS (
                                         SELECT cversion
                                           FROM bf_bonfranseg
                                          WHERE cgrup = frq.cgrup
                                            AND sseguro = pssegpol
                                            AND nriesgo = pnriesgo
                                            AND ffinefe IS NOT NULL
                                            AND nmovimi =
                                                   (SELECT MAX (nmovimi)
                                                      FROM movseguro
                                                     WHERE sseguro = pssegpol))
                                  AND bv.cversion =
                                         (SELECT cversion
                                            FROM bf_bonfranseg
                                           WHERE cgrup = frq.cgrup
                                             AND nriesgo = pnriesgo
                                             AND sseguro = pssegpol
                                             AND nmovimi =
                                                    (SELECT MAX (nmovimi)
                                                       FROM movseguro
                                                      WHERE sseguro = pssegpol)
                                             AND ffinefe IS NOT NULL)
                               OR (    NOT EXISTS (
                                          SELECT cversion
                                            FROM bf_bonfranseg
                                           WHERE cgrup = frq.cgrup
                                             AND sseguro = pssegpol
                                             AND nriesgo = pnriesgo
                                             AND nmovimi =
                                                    (SELECT MAX (nmovimi)
                                                       FROM movseguro
                                                      WHERE sseguro = pssegpol)
                                             AND ffinefe IS NOT NULL)
                                   AND bv.cversion =
                                          (SELECT cversion
                                             FROM bf_versiongrup
                                            WHERE cempres = bd.cempres
                                              AND cgrup = frq.cgrup
                                              AND fdesde <= pfefecto
                                              AND (   fhasta >= pfefecto
                                                   OR fhasta IS NULL
                                                  ))
                                  )
                              )
                         )
                      OR (    v_issuplem = 0
                          AND bv.cversion =
                                 (SELECT cversion
                                    FROM bf_versiongrup
                                   WHERE cempres = bd.cempres
                                     AND cgrup = frq.cgrup
                                     AND fdesde <= pfefecto
                                     AND (fhasta >= pfefecto OR fhasta IS NULL
                                         ))
                         )
                     )
                    )
                )
            AND bd.cidioma = pac_md_common.f_get_cxtidioma;

         vpasexec := 6;

--            tprodfranq(vindex).grupo.lsubgrupos
         IF pcsubgrup IS NULL
         THEN
            vsubgrup := frq.csubgrupunic;

            IF frq.csubgrupunic IS NULL
            THEN
               IF frq.cformulasub IS NOT NULL
               THEN
                  vnumerr :=
                     pac_bonfran.f_resuelve_formula (1,
                                                     psseguro,
                                                     pcactivi,
                                                     psproduc,
                                                     frq.cgrup,
                                                     pfefecto,
                                                     pnriesgo,
                                                     frq.cformulasub,
                                                     pnmovimi,
                                                     vsubgrup
                                                    );

                  IF vnumerr <> 0
                  THEN
                     RAISE e_object_error;
                  END IF;

                  tprodfranq (vindex).csubgrupunic := vsubgrup;
               END IF;
            END IF;
         ELSE
            vsubgrup := pcsubgrup;
         END IF;

         tgrupsubgrup := t_iax_bf_grupsubgrup ();

         IF vsubgrup IS NOT NULL
         THEN
            FOR frqsub IN (SELECT b.cempres, b.cgrup, b.csubgrup, b.cversion,
                                  b.ctipgrupsubgrup, bd.tgrupsubgrup, pgg.cgarant  -- IAXIS-5423  CJMR 23/09/2019
                             FROM bf_grupsubgrup b, bf_desgrupsubgrup bd, bf_progarangrup pgg  -- IAXIS-5423  CJMR 23/09/2019
                            WHERE b.cgrup = frq.cgrup
                              AND b.cempres = pac_md_common.f_get_cxtempresa
                              AND b.cempres = bd.cempres
                              AND b.cgrup = bd.cgrup
                              AND b.csubgrup = bd.csubgrup
                              AND b.csubgrup = vsubgrup
                              AND b.cversion = tprodfranq (vindex).grupo.cversion
                              AND bd.cversion = b.cversion
                              AND bd.cidioma = pac_md_common.f_get_cxtidioma
                              -- INI IAXIS-5423  CJMR 23/09/2019
                              AND pgg.cempres = bd.cempres
                              AND pgg.codgrup = b.cgrup
                              AND pgg.sproduc = psproduc
                              AND pgg.cactivi = pcactivi)
                              -- FIN IAXIS-5423  CJMR 23/09/2019
            LOOP
               --v_impdef := pac_mdpar_productos.f_get_pargarantia ('IMP_DEF_DEDUC', psproduc, frqsub.cgarant, pcactivi); -- IAXIS-5423  CJMR 23/09/2019
               -- INI IAXIS-5423  CJMR 14/11/2019
	       vnumerr := pac_productos.f_get_pargarantia ('IMP_DEF_DEDUC', psproduc, frqsub.cgarant, v_impdef, pcactivi);
               IF vnumerr <> 0
               THEN
                  RAISE e_object_error;
               END IF;
               -- FIN IAXIS-5423  CJMR 14/11/2019
               
               IF tgrupsubgrup IS NULL
               THEN
                  tgrupsubgrup := t_iax_bf_grupsubgrup ();
               END IF;

               vpasexec := 7;
               tgrupsubgrup.EXTEND;
               vindex3 := tgrupsubgrup.LAST;
               tgrupsubgrup (vindex3) := ob_iax_bf_grupsubgrup ();
               tgrupsubgrup (vindex3).cempres := frqsub.cempres;
               tgrupsubgrup (vindex3).cgrup := frqsub.cgrup;
               tgrupsubgrup (vindex3).csubgrup := frqsub.csubgrup;
               tgrupsubgrup (vindex3).cversion := frqsub.cversion;
               tgrupsubgrup (vindex3).ctipgrupsubgrup :=
                                                        frqsub.ctipgrupsubgrup;
               tgrupsubgrup (vindex3).tgrupsubgrup := frqsub.tgrupsubgrup;
               vpasexec := 8;
               tdetnivel := t_iax_bf_detnivel ();
               -- INI IAXIS-5423  CJMR 23/09/2019
               vexistenivdef := FALSE;
               vcnivdef := NULL;
               -- FIN IAXIS-5423  CJMR 23/09/2019

               --lniveles       t_iax_bf_detnivel,   --Lista de niveles
               FOR c_nivel IN
                  (SELECT   b.cempres, b.cgrup, b.csubgrup, b.cversion,
                            b.cnivel, b.norden, b.cdtorec, b.formulaselecc,
                            b.formulavalida, b.formulasinies, b.ctipnivel,
                            b.cvalor1, b.impvalor1, b.cvalor2, b.impvalor2,
                            b.cimpmin, b.impmin, b.cimpmax, b.impmax,
                            b.cdefecto, b.ccontratable, b.cinterviene,
                            b.cpolitica, tnivel,
                            id_listlibre
                                    --, lvalor1, lvalor2--, limpmin--, limpmax
                       FROM bf_detnivel b, bf_desnivel bdl
                      WHERE b.cempres = pac_md_common.f_get_cxtempresa
                        AND b.cempres = bdl.cempres
                        AND b.csubgrup = frqsub.csubgrup
                        AND b.cgrup = frq.cgrup
                        AND b.cgrup = bdl.cgrup
                        AND b.csubgrup = bdl.csubgrup
                        --  AND b.ccontratable = 'S'
                        AND b.cversion = bdl.cversion
                        AND b.cversion = tprodfranq (vindex).grupo.cversion
                        AND bdl.cversion = b.cversion
                        AND b.cnivel = bdl.cnivel
                        AND b.cnivel = NVL (pcnivel, b.cnivel)
                        AND b.cversion = frqsub.cversion
                        AND cidioma = pac_md_common.f_get_cxtidioma
                   ORDER BY norden ASC)
               LOOP
                  vformula := 1;
                  vcnivel := NULL;

                  IF pcnivel IS NULL
                  THEN
                     IF tgrupsubgrup (vindex3).ctipgrupsubgrup = 1
                     THEN
                        
                        --  IF v_issuplem = 1 THEN
                        BEGIN
                           SELECT cnivel, cvalor1, impvalor1, cimpmin, impmin, cniveldefecto         -- IAXIS-5423  CJMR 23/09/2019
                             INTO vcnivel, vcvalor1, vimpvalor1, vcimpmin, vimpmin, vcniveldefecto   -- IAXIS-5423  CJMR 23/09/2019
                             FROM estbf_bonfranseg
                            WHERE cgrup = frq.cgrup
                              AND sseguro = psseguro
                              AND csubgrup = frqsub.csubgrup
                              AND nriesgo = pnriesgo
                              AND cnivel = c_nivel.cnivel
                              /*    AND nmovimi = (SELECT MAX(nmovimi)
                                                   FROM movseguro
                                                  WHERE sseguro = pssegpol)*/
                              AND ffinefe IS NULL;
                           
                        EXCEPTION
                           WHEN NO_DATA_FOUND
                           THEN
                              vcnivel := NULL;

                              BEGIN
                                 SELECT cvalor1, impvalor1, cvalor2,
                                        impvalor2, cimpmin, impmin,
                                        cimpmax, impmax, cnivel,
                                        cniveldefecto
                                   INTO vcvalor1, vimpvalor1, vcvalor2,
                                        vimpvalor2, vcimpmin, vimpmin,
                                        vcimpmax, vimpmax, vcnivel,
                                        vcniveldefecto
                                   FROM estbf_bonfranseg
                                  WHERE cgrup = frq.cgrup
                                    AND sseguro = psseguro
                                    -- AND csubgrup = frqsub.csubgrup
                                    AND nriesgo = pnriesgo
                                    AND cnivel = c_nivel.cnivel
                                    /*     AND nmovimi = (SELECT MAX(nmovimi)
                                                          FROM movseguro
                                                         WHERE sseguro = pssegpol)*/
                                    AND ffinefe IS NULL;
                              EXCEPTION
                                 WHEN OTHERS
                                 THEN
                                    vcnivel := NULL;
                              END;
                        END;

                        IF vcnivel IS NULL
                        THEN
                           IF c_nivel.formulaselecc IS NOT NULL
                           THEN
                              vnumerr :=
                                 pac_bonfran.f_resuelve_formula
                                                      (1,
                                                       psseguro,
                                                       pcactivi,
                                                       psproduc,
                                                       c_nivel.cgrup,
                                                       pfefecto,
                                                       pnriesgo,
                                                       c_nivel.formulaselecc,
                                                       pnmovimi,
                                                       vformula
                                                      );

                              IF vnumerr <> 0
                              THEN
                                 RAISE e_object_error;
                              END IF;
                           END IF;
                        END IF;
                     ELSE
                        --  IF v_issuplem = 1 THEN
                        BEGIN
                           SELECT cvalor1, impvalor1, cvalor2,
                                  impvalor2, cimpmin, impmin, cimpmax,
                                  impmax, cnivel, cniveldefecto
                             INTO vcvalor1, vimpvalor1, vcvalor2,
                                  vimpvalor2, vcimpmin, vimpmin, vcimpmax,
                                  vimpmax, vcnivel, vcniveldefecto
                             FROM estbf_bonfranseg
                            WHERE cgrup = frq.cgrup
                              AND sseguro = psseguro
                              AND csubgrup = frqsub.csubgrup
                              AND nriesgo = pnriesgo
                              AND cnivel = c_nivel.cnivel
                              /*    AND nmovimi = (SELECT MAX(nmovimi)
                                                   FROM movseguro
                                                  WHERE sseguro = pssegpol)*/
                              AND ffinefe IS NULL;
                        EXCEPTION
                           WHEN NO_DATA_FOUND
                           THEN
                              vcnivel := NULL;

                              BEGIN
                                 SELECT cvalor1, impvalor1, cvalor2,
                                        impvalor2, cimpmin, impmin,
                                        cimpmax, impmax, cnivel,
                                        cniveldefecto
                                   INTO vcvalor1, vimpvalor1, vcvalor2,
                                        vimpvalor2, vcimpmin, vimpmin,
                                        vcimpmax, vimpmax, vcnivel,
                                        vcniveldefecto
                                   FROM estbf_bonfranseg
                                  WHERE cgrup = frq.cgrup
                                    AND sseguro = psseguro
                                    --   AND csubgrup = frqsub.csubgrup
                                    AND nriesgo = pnriesgo
                                    AND cnivel = c_nivel.cnivel
                                    /*   AND nmovimi = (SELECT MAX(nmovimi)
                                                        FROM movseguro
                                                       WHERE sseguro = pssegpol)*/
                                    AND ffinefe IS NULL;
                              EXCEPTION
                                 WHEN OTHERS
                                 THEN
                                    vcnivel := NULL;
                              END;
                        END;
                     -- END IF;
                     END IF;
                  ELSE
                     vcnivel := pcnivel;
                  END IF;

                  IF     vformula = 1
                     AND (c_nivel.ccontratable = 'S' OR vcnivel IS NOT NULL)
                  THEN
                     IF tdetnivel IS NULL
                     THEN
                        tdetnivel := t_iax_bf_detnivel ();
                     END IF;

                     vpasexec := 9;
                     tdetnivel.EXTEND;
                     vpasexec := 91;
                     vindex4 := tdetnivel.LAST;
                     vpasexec := 92;
                     tdetnivel (vindex4) := ob_iax_bf_detnivel ();
                     tdetnivel (vindex4).cempres := c_nivel.cempres;
                     tdetnivel (vindex4).cgrup := c_nivel.cgrup;
                     tdetnivel (vindex4).csubgrup := c_nivel.csubgrup;
                     tdetnivel (vindex4).cversion := c_nivel.cversion;
                     tdetnivel (vindex4).cnivel := c_nivel.cnivel;

                     IF     vdefectogrup IS NOT NULL
                        AND vdefectogrup = c_nivel.cnivel
                     THEN
                        p_tab_error (f_sysdate,
                                     f_user,
                                     'TEST',
                                     2,
                                     'grup - vdefectogrup',
                                     frq.cgrup || '-' || vdefectogrup
                                    );
                        tdetnivel (vindex4).cdefecto := 'S';
                     ELSIF vdefectogrup IS NULL
                     THEN
                        tdetnivel (vindex4).cdefecto := c_nivel.cdefecto;
                     END IF;

                     IF (    tgrupsubgrup (vindex3).ctipgrupsubgrup NOT IN
                                                                       (3, 4)
                         AND (   (vcnivel IS NOT NULL AND c_nivel.cvalor1 IN (1, 2)  -- IAXIS-5423  CJMR 23/09/2019
                                 )
                              OR tgrupsubgrup (vindex3).ctipgrupsubgrup = 2
                             )
                        )
                     THEN

                        -- INI IAXIS-5423  CJMR 23/09/2019
                        vexistenivdef := TRUE;
                        vcnivdef := tdetnivel (vindex4).cnivel;
                        -- FIN IAXIS-5423  CJMR 23/09/2019
                        tdetnivel (vindex4).cdefecto := 'S';
                        
                        IF c_nivel.cvalor1 = 1 THEN   -- IAXIS-5423  CJMR 23/09/2019
                           tdetnivel (vindex4).tnivel := c_nivel.tnivel;
                        ELSE
                           tdetnivel (vindex4).tnivel := vimpvalor1;
                        END IF;
                     ELSE
                        tdetnivel (vindex4).tnivel := c_nivel.tnivel;
                     END IF;
                     
                     tdetnivel (vindex4).norden := c_nivel.norden;
                     tdetnivel (vindex4).cdtorec := c_nivel.cdtorec;
                     tdetnivel (vindex4).formulaselecc :=
                                                         c_nivel.formulaselecc;
                     tdetnivel (vindex4).tformulavalida :=
                                                         c_nivel.formulavalida;
                     tdetnivel (vindex4).formulasinies :=
                                                         c_nivel.formulasinies;
                     vpasexec := 93;
                     tdetnivel (vindex4).ctipnivel := c_nivel.ctipnivel;
                     tdetnivel (vindex4).cvalor1 := c_nivel.cvalor1;
                     tdetnivel (vindex4).impvalor1 := c_nivel.impvalor1;
                     tdetnivel (vindex4).cvalor2 := c_nivel.cvalor2;
                     tdetnivel (vindex4).impvalor2 := c_nivel.impvalor2;
                     -- INI IAXIS-5423  CJMR 23/09/2019
                     tdetnivel (vindex4).cimpmin := NVL(vcimpmin, c_nivel.cimpmin);
                     --IF v_issuplem = 0 THEN  CJMR 25/11/2019
                        tdetnivel (vindex4).impmin := NVL(NVL(vimpmin, v_impdef), c_nivel.impmin); -- IAXIS-5423  CJMR 14/11/2019
                     --ELSE
                     --   tdetnivel (vindex4).impmin := NVL(vimpmin, c_nivel.impmin);
                     --END IF;
                     -- INI IAXIS-5423  CJMR 23/09/2019
					 
					 IF psproduc IN(8062, 8063)  THEN
                        tdetnivel (vindex4).impmin := c_nivel.impmin; 
                     END IF;
					 
					 
                     tdetnivel (vindex4).cimpmax := c_nivel.cimpmax;
                     tdetnivel (vindex4).impmax := c_nivel.impmax;
                     tdetnivel (vindex4).ccontratable := c_nivel.ccontratable;
                     tdetnivel (vindex4).cinterviene := c_nivel.cinterviene;
                     tdetnivel (vindex4).id_listlibre := c_nivel.id_listlibre;

                     IF     tgrupsubgrup (vindex3).ctipgrupsubgrup IN (3, 4)
                        AND c_nivel.cvalor1 = 99
                        AND c_nivel.id_listlibre IS NOT NULL
                     THEN
                        tdetnivel (vindex4).listacvalor1 :=
                           f_get_bf_listalibre (c_nivel.id_listlibre,
                                                mensajes
                                               );

                        IF pcvalor1 IS NOT NULL
                        THEN
                           SELECT id_listlibre_2, id_listlibre_min,
                                  id_listlibre_max
                             INTO lvalor2, limpmin,
                                  limpmax
                             FROM bf_listlibre
                            WHERE cempres = pac_md_common.f_get_cxtempresa
                              AND id_listlibre = c_nivel.id_listlibre
                              AND catribu = pcvalor1;

                           tdetnivel (vindex4).lvalor2 := lvalor2;
                           tdetnivel (vindex4).limpmin := limpmin;
                           tdetnivel (vindex4).limpmax := limpmax;
                        END IF;

                        IF lvalor2 IS NOT NULL
                        THEN
                           tdetnivel (vindex4).listacvalor2 :=
                                      f_get_bf_listalibre (lvalor2, mensajes);
                        END IF;

                        IF limpmin IS NOT NULL
                        THEN
                           tdetnivel (vindex4).listacimpmin :=
                                      f_get_bf_listalibre (limpmin, mensajes);
                        END IF;

                        IF limpmax IS NOT NULL
                        THEN
                           tdetnivel (vindex4).listacimpmax :=
                                      f_get_bf_listalibre (limpmax, mensajes);
                        END IF;
                     END IF;

                     vpasexec := 95;
                  END IF;
               END LOOP;
               
               vpasexec := 10;
               -- INI IAXIS-5423  CJMR 23/09/2019
               IF vexistenivdef THEN
                  FOR vindexnivdef IN tdetnivel.FIRST .. tdetnivel.LAST LOOP
                     IF tdetnivel(vindexnivdef).cnivel = vcnivdef THEN
                        tdetnivel (vindexnivdef).cdefecto := 'S';
                     ELSE
                        tdetnivel (vindexnivdef).cdefecto := 'N';
                     END IF;
                  END LOOP;
               END IF;
               -- FIN IAXIS-5423  CJMR 23/09/2019
               
               tgrupsubgrup (vindex3).lniveles := tdetnivel;
            END LOOP;

            tprodfranq (vindex).grupo.lsubgrupos := tgrupsubgrup;
            tprodfranq (vindex).lniveles := tdetnivel;
         END IF;
      END LOOP;

      vpasexec := 11;
      RETURN (tprodfranq);
   --
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         -- BUG -21546_108724- 02/02/2012 - JLTS- Cierre de cursores
         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_get_franquicias;

   -- BUG22402:DRA:16/10/2012:Inici
   /***********************************************************************
      Devuelve el co-corretaje
      param in sproduc   : cdigo de producto
      param out mensajes : mensajes de error
      return             : t_iax_corretaje
   ***********************************************************************/
   FUNCTION f_get_corretaje (psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_corretaje
   IS
      --
      CURSOR corret_seg
      IS
         SELECT c.sseguro, c.cagente, c.nmovimi, c.nordage, c.pcomisi,
                c.ppartici, c.islider
           FROM age_corretaje c, seguros s
          WHERE c.sseguro = s.sseguro
            AND s.npoliza = pac_iax_produccion.poliza.det_poliza.npoliza
            AND s.ncertif = 0;

      t_corret    t_iax_corretaje := t_iax_corretaje ();
      vpasexec    NUMBER (8)      := 1;
      vparam      VARCHAR2 (500)  := 'psproduc=' || psproduc;
      vobject     VARCHAR2 (200)  := 'PAC_MDPAR_PRODUCTOS.F_Get_Corretaje';
      vnumerr     NUMBER (8)      := 0;
      v_ccorret   NUMBER;                           -- BUG22402:DRA:16/10/2012
      v_pcomisi   NUMBER;
      v_pretenc   NUMBER;
   BEGIN
      IF psproduc IS NULL
      THEN
         RAISE e_param_error;
         RETURN NULL;
      END IF;

      IF     pac_mdpar_productos.f_get_parproducto ('ADMITE_CERTIFICADOS',
                                                    psproduc
                                                   ) = 1
         AND NOT pac_iax_produccion.isaltacol
      THEN
         vnumerr := pac_productos.f_get_herencia_col (psproduc, 8, v_ccorret);

         IF NVL (v_ccorret, 0) = 1 AND vnumerr = 0
         THEN
            FOR corret IN corret_seg
            LOOP
               IF t_corret IS NULL
               THEN
                  t_corret := t_iax_corretaje ();
               END IF;

               t_corret.EXTEND;
               t_corret (t_corret.LAST) := ob_iax_corretaje ();
               t_corret (t_corret.LAST).cagente := corret.cagente;
               t_corret (t_corret.LAST).nmovimi :=
                                  pac_iax_produccion.poliza.det_poliza.nmovimi;
               t_corret (t_corret.LAST).nordage := corret.nordage;
               t_corret (t_corret.LAST).ppartici := corret.ppartici;
               t_corret (t_corret.LAST).islider := corret.islider;
               vnumerr :=
                  pac_iax_produccion.f_get_direc_corretaje
                                                     (corret.cagente,
                                                      'POL',
                                                      t_corret (t_corret.LAST),
                                                      mensajes
                                                     );

               IF vnumerr <> 0
               THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, vnumerr);
                  RAISE e_object_error;
               END IF;

               -- Tambi¿n pondremos esto en el PAC_IAX_PRODUCCION.f_leecorretaje para que calcule los n-certificados
               vnumerr :=
                  pac_iax_corretaje.f_calcular_comision_corretaje
                                                             (corret.cagente,
                                                              NULL,
                                                              corret.ppartici,
                                                              v_pcomisi,
                                                              v_pretenc,
                                                              mensajes
                                                             );

               IF vnumerr <> 0
               THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, vnumerr);
                  RAISE e_object_error;
               END IF;

               t_corret (t_corret.LAST).pcomisi := v_pcomisi;
            END LOOP;
         --vnumerr := pac_md_grabardatos.f_grabarcorretaje(t_corret, mensajes);
         --IF vnumerr <> 0 THEN
         --   pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         --   RAISE e_object_error;
         --END IF;
         END IF;
      END IF;

      RETURN t_corret;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_get_corretaje;

   -- BUG22402:DRA:16/10/2012:Fi

   /***********************************************************************
      Devuelve el retorno
      param in sproduc   : c¿digo de producto
      param out mensajes : mensajes de error
      return             : t_iax_corretaje
   ***********************************************************************/
   FUNCTION f_get_retorno (psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_retorno
   IS
      --
      CURSOR retrn_seg
      IS
         SELECT c.sseguro, c.sperson, c.nmovimi, c.pretorno, c.idconvenio
           FROM rtn_convenio c, seguros s
          WHERE c.sseguro = s.sseguro
            AND s.npoliza = pac_iax_produccion.poliza.det_poliza.npoliza
            AND s.ncertif = 0;

      t_retrn      t_iax_retorno  := t_iax_retorno ();
      vpasexec     NUMBER (8)     := 1;
      vparam       VARCHAR2 (500) := 'psproduc=' || psproduc;
      vobject      VARCHAR2 (200) := 'PAC_MDPAR_PRODUCTOS.F_Get_Retorno';
      vnumerr      NUMBER (8)     := 0;
      v_cretorno   NUMBER;                          -- BUG23911:DRA:18/10/2012
      v_pcomisi    NUMBER;
      v_pretenc    NUMBER;
   BEGIN
      IF psproduc IS NULL
      THEN
         RAISE e_param_error;
         RETURN NULL;
      END IF;

      IF     pac_mdpar_productos.f_get_parproducto ('ADMITE_CERTIFICADOS',
                                                    psproduc
                                                   ) = 1
         AND NOT pac_iax_produccion.isaltacol
      THEN
         vnumerr :=
                  pac_productos.f_get_herencia_col (psproduc, 10, v_cretorno);

         IF NVL (v_cretorno, 0) = 1 AND vnumerr = 0
         THEN
            FOR retrn IN retrn_seg
            LOOP
               IF t_retrn IS NULL
               THEN
                  t_retrn := t_iax_retorno ();
               END IF;

               t_retrn.EXTEND;
               t_retrn (t_retrn.LAST) := ob_iax_retorno ();
               t_retrn (t_retrn.LAST).sperson := retrn.sperson;
               t_retrn (t_retrn.LAST).nmovimi :=
                                  pac_iax_produccion.poliza.det_poliza.nmovimi;
               t_retrn (t_retrn.LAST).pretorno := retrn.pretorno;
               t_retrn (t_retrn.LAST).idconvenio := retrn.idconvenio;
               vnumerr :=
                  pac_iax_produccion.f_get_direc_retorno
                                (retrn.sperson,
                                 pac_iax_produccion.poliza.det_poliza.cagente,
                                 'POL',
                                 t_retrn (t_retrn.LAST),
                                 mensajes
                                );

               IF vnumerr <> 0
               THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, vnumerr);
                  RAISE e_object_error;
               END IF;
            END LOOP;
         --vnumerr := pac_md_grabardatos.f_grabarretorno(t_retrn, mensajes);

         --IF vnumerr <> 0 THEN
         --   pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         --   RAISE e_object_error;
         --END IF;
         END IF;
      END IF;

      RETURN t_retrn;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_get_retorno;

   FUNCTION f_get_bf_listalibre (
      pid_listlibre   IN       NUMBER,
      mensajes        IN OUT   t_iax_mensajes
   )
      RETURN t_iax_bf_listlibre
   IS
      vpasexec   NUMBER (8)         := 1;
      vparam     VARCHAR2 (500)     := 'pid_listlibre=' || pid_listlibre;
      vobject    VARCHAR2 (200)  := 'PAC_MDPAR_PRODUCTOS.f_get_bf_listalibre';
      cur        sys_refcursor;
      lista      t_iax_bf_listlibre;
      vindex4    NUMBER;
   BEGIN
      lista := t_iax_bf_listlibre ();

      FOR i IN (SELECT DISTINCT (cvalor)
                           FROM bf_listlibre
                          WHERE cempres = pac_md_common.f_get_cxtempresa
                            AND id_listlibre = pid_listlibre
                            AND ROWNUM = 1)
      LOOP
         FOR x IN (SELECT *
                     FROM bf_listlibre
                    WHERE cempres = pac_md_common.f_get_cxtempresa
                      AND id_listlibre = pid_listlibre
                      AND cvalor = i.cvalor)
         LOOP
            lista.EXTEND;
            vpasexec := 91;
            vindex4 := lista.LAST;
            vpasexec := 92;
            lista (vindex4) := ob_iax_bf_listlibre ();
            lista (vindex4).cempres := x.cempres;
            lista (vindex4).cvalor := x.cvalor;
            lista (vindex4).catribu := x.catribu;
            lista (vindex4).id_listlibre := x.id_listlibre;
            lista (vindex4).tatribu :=
               ff_desvalorfijo (i.cvalor,
                                pac_md_common.f_get_cxtidioma,
                                x.catribu
                               );
            lista (vindex4).idlistalibre2 := x.id_listlibre_2;
            lista (vindex4).id_listlibre_min := x.id_listlibre_min;
            lista (vindex4).id_listlibre_max := x.id_listlibre_max;
         END LOOP;
      END LOOP;

      RETURN lista;
   EXCEPTION
      WHEN OTHERS
      THEN
         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_get_bf_listalibre;

   FUNCTION f_hay_franq_bonusmalus (
      psproduc       IN       NUMBER,
      pcactivi       IN       NUMBER,
      pfranquicias   OUT      NUMBER,
      pbonus         OUT      NUMBER,
      mensajes       IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec      NUMBER (8)     := 1;
      vparam        VARCHAR2 (1)   := NULL;
      vobjectname   VARCHAR2 (200)
                               := 'PAC_IAX_PRODUCCION.f_hay_franq_bonusmalus';
   BEGIN
      IF psproduc IS NOT NULL AND pcactivi IS NOT NULL
      THEN
         SELECT COUNT (1)
           INTO pbonus
           FROM bf_proactgrup bp, bf_codgrup bc
          WHERE bp.cempres = pac_md_common.f_get_cxtempresa
            AND bp.cempres = bc.cempres
            AND bp.sproduc = psproduc
            AND bp.cactivi = pcactivi
            AND bp.cempres = bc.cempres
            AND bp.cgrup = bc.cgrup
            AND ctipgrup = 1;                                          --bonus

         SELECT COUNT (1)
           INTO pfranquicias
           FROM bf_proactgrup bp, bf_codgrup bc
          WHERE bp.cempres = pac_md_common.f_get_cxtempresa
            AND bp.cempres = bc.cempres
            AND bp.sproduc = psproduc
            AND bp.cactivi = pcactivi
            AND bp.cempres = bc.cempres
            AND bp.cgrup = bc.cgrup
            AND ctipgrup = 2;                                    --franquicias
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobjectname,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobjectname,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobjectname,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_hay_franq_bonusmalus;

   /***********************************************************************
      Nos retornara el cpretip de una determinada pregunta ya sea a nivel de
      poliza, riesgo o garantia.

      param in  psproduc : codigo de producto
      param in  pcpregun : codigo de pregunta
      param in  pnivel   : codigo de accesi (poliza, riesgo o garantia)
      param out mensajes : mensajes de error
      param in  pcgarant : codigo de garantia para el acceso por garantia
      return             : Number [0/1]
   ***********************************************************************/
   -- Bug 9109 - 12/02/2009 - RSC - APR: Preguntas semiautomaticas
   FUNCTION f_get_cpretippreg (
      psproduc   IN       NUMBER,
      pcpregun   IN       NUMBER,
      pnivel     IN       VARCHAR2,
      mensajes   OUT      t_iax_mensajes,
      pcgarant   IN       NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      preg   t_iaxpar_preguntas;
   BEGIN
      IF pnivel = 'P'
      THEN
         preg :=
            pac_mdpar_productos.f_get_pregpoliza
                                                (psproduc,
                                                 pac_iax_produccion.issimul,
                                                 pac_iax_produccion.issuplem,
                                                 mensajes
                                                );
      ELSIF pnivel = 'R'
      THEN
         preg := pac_iaxpar_productos.f_get_datosriesgos (mensajes);
      ELSIF pnivel = 'G'
      THEN
         preg := pac_iaxpar_productos.f_get_preggarant (pcgarant, mensajes);
      END IF;

      FOR i IN preg.FIRST .. preg.LAST
      LOOP
         IF preg (i).cpregun = pcpregun
         THEN
            RETURN preg (i).cpretip;
         END IF;
      END LOOP;

      RETURN NULL;
   END f_get_cpretippreg;

   /***********************************************************************
      Nos retornara el esccero de una determinada pregunta ya sea a nivel de
      poliza, riesgo o garantia.

      param in  psproduc : codigo de producto
      param in  pcpregun : codigo de pregunta
      param in  pnivel   : codigo de accesi (poliza, riesgo o garantia)
      param out mensajes : mensajes de error
      param in  pcgarant : codigo de garantia para el acceso por garantia
      return             : Number [0/1]
   ***********************************************************************/
   -- Bug 9109 - 12/02/2009 - RSC - APR: Preguntas semiautomaticas
   FUNCTION f_get_escceropreg (
      psproduc   IN       NUMBER,
      pcpregun   IN       NUMBER,
      pnivel     IN       VARCHAR2,
      mensajes   OUT      t_iax_mensajes,
      pcgarant   IN       NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      preg   t_iaxpar_preguntas;
   BEGIN
      IF pnivel = 'P'
      THEN
         preg :=
            pac_mdpar_productos.f_get_pregpoliza
                                                (psproduc,
                                                 pac_iax_produccion.issimul,
                                                 pac_iax_produccion.issuplem,
                                                 mensajes
                                                );
      ELSIF pnivel = 'R'
      THEN
         preg := pac_iaxpar_productos.f_get_datosriesgos (mensajes);
      ELSIF pnivel = 'G'
      THEN
         preg := pac_iaxpar_productos.f_get_preggarant (pcgarant, mensajes);
      END IF;

      FOR i IN preg.FIRST .. preg.LAST
      LOOP
         IF preg (i).cpregun = pcpregun
         THEN
            RETURN preg (i).esccero;
         END IF;
      END LOOP;

      RETURN NULL;
   END f_get_escceropreg;

   /***********************************************************************
      Nos indica si una determinada pregunta es o no automatica que se calcula antes de tarifar al entrar en la pantalla de garant¿as.
      param in psproduc : codigo de producto
      param in pcpregun : codigo de pregunta
      param in pnivel : codigo de accesi (poliza, riesgo o garantia)
      param out mensajes : mensajes de error
      param in pcgarant : codigo de garantia para el acceso por garantia
      return : Number [0/1]
   ***********************************************************************/
   FUNCTION f_es_automatica_pre_tarif (
      psproduc   IN       NUMBER,
      pcpregun   IN       NUMBER,
      pnivel     IN       VARCHAR2,       -- Nivel 'P' (poliza) o 'R' (riesgo)
      mensajes   OUT      t_iax_mensajes,
      pcgarant   IN       NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      preg   t_iaxpar_preguntas;
   BEGIN
      IF pnivel = 'P'
      THEN                                                    -- nivel poliza
         preg :=
            pac_mdpar_productos.f_get_pregpoliza
                                                (psproduc,
                                                 pac_iax_produccion.issimul,
                                                 pac_iax_produccion.issuplem,
                                                 mensajes
                                                );
      ELSIF pnivel = 'R'
      THEN                                                   -- nivel garantia
         preg := pac_iaxpar_productos.f_get_datosriesgos (mensajes);
      ELSIF pnivel = 'G'
      THEN                                                   -- nivel garantia
         preg := pac_iaxpar_productos.f_get_preggarant (pcgarant, mensajes);
      END IF;

      IF preg IS NOT NULL
      THEN
         IF preg.COUNT > 0
         THEN
            FOR i IN preg.FIRST .. preg.LAST
            LOOP
               IF preg (i).cpregun = pcpregun
               THEN
                  IF (preg (i).cpretip = 2 AND preg (i).ccalcular = 1)
                  THEN
                     RETURN 1;
                  END IF;
               END IF;
            END LOOP;
         END IF;
      END IF;

      RETURN 0;
   END f_es_automatica_pre_tarif;
END pac_mdpar_productos;
/