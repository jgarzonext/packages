CREATE OR REPLACE PACKAGE BODY AXIS."PAC_IAX_IMPRESION" 
AS
/******************************************************************************
   NOMBRE:      PAC_IAX_IMPRESION
   PROPÂ¿Â¿SITO: Funciones para la impresiÂ¿Â¿n de documentos

   REVISIONES:
   Ver        Fecha        Autor             DescripciÂ¿Â¿n
   ---------  ----------  ---------------  ------------------------------------
   1.0        16/01/2008   JAS                1. CreaciÂ¿Â¿n del package.
   1.1        17/01/2008   JTS                1. La ruta del fichero se coge
                                                 de parinstalacion.
   1.2        28/04/2008   ACC                3. Incluir funciones de impresiÂ¿Â¿n
   6.0        04/06/2009   JTS                10233: APR - cartas de impagados ( 2Â¿Â¿ parte)
   7.0        12/08/2009   JTS                10729: APR - Pantalla de impresion de recibos
   9.0        08/02/2010   JTS                12850: CEM210 - Estalvi: Plantilles de pignoracions i bloquejos
   10.0       13/09/2010   XPL                15685: CIV998 - Preparar la aplicaciÂ¿Â¿n para que registre campos concretos en log_actividad
   11.0       31/12/2010   ETM                0016446: GRC - Documento de pago de siniestros
   12.0       24/11/2011   ETM                0019783: LCOL_S001-SIN - Rechazo de tramitaciones
   13.0       23/04/2012   JMF                0022030: MDP_A001-Devoluciones: impresion y gestion de cartas
   14.0       05/06/2012   JMF                0022444: MDP_S001-SIN - Carta de rechazo en alta siniestro
   15.0       24/01/2013   MLA                0025816: RSAG - Enviar un correo con datos adjuntos.
******************************************************************************/
   e_object_error   EXCEPTION;
   e_param_error    EXCEPTION;

   /*************************************************************************
      VisualizaciÂ¿Â¿n de un documento almacenado en GEDOX
      param in piddoc      : Id. del documento que se debe visualizar
      param out ptpath     : Ruta del fichero que se debe visualizar
      param out mensajes   : mensajes de error
      return               : 0/1 -> Ok/Error
   *************************************************************************/
   FUNCTION f_gedox_verdoc (
      piddoc     IN       NUMBER,
      optpath    OUT      VARCHAR2,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vobjectname   VARCHAR2 (500)  := 'PAC_IAX_IMPRESION.F_Gedox_VerDoc';
      vparam        VARCHAR2 (500)  := 'parÃ¡metros - piddoc: ' || piddoc;
      vpasexec      NUMBER (5)      := 0;
      vnumerr       NUMBER (8)      := 1;
      vtfichero     VARCHAR2 (100);
      vtfichpath    VARCHAR2 (250);
      vsinterf      NUMBER;
      vcempres      NUMBER;
      vpathoutws    VARCHAR2 (3000)
                    := pac_md_common.f_get_parinstalacion_t ('INFORMES_SERV');
   BEGIN
      --ComprovaciÂ¿Â¿ dels parÂ¿Â¿metres d'entrada
      IF piddoc IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vcempres := NVL(pac_md_common.f_get_cxtempresa (), pac_parametros.f_parinstalacion_n ('EMPRESADEF'));
      vpasexec := 3;

      IF NVL (pac_parametros.f_parempresa_t (vcempres, 'GESTORDOCUM'), 'X') =
                                                                       'GEDOX'
      THEN
         vnumerr :=
                  pac_md_impresion.f_gedox_verdoc (piddoc, optpath, mensajes);
      ELSIF NVL (pac_parametros.f_parempresa_t (vcempres, 'GESTORDOCUM'), 'X') =
                                                                          'WS'
      THEN
         vnumerr :=
            pac_md_con.f_get_detalle_doc (TO_CHAR (piddoc),
                                          vpathoutws,
                                          TO_CHAR (piddoc),
                                          vsinterf,
                                          mensajes
                                         );
         optpath := vpathoutws;
      END IF;

      IF vnumerr <> 0
      THEN
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobjectname,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobjectname,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
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
         RETURN 1;
   END f_gedox_verdoc;

   /*************************************************************************
      ImpresiÂ¿Â¿n documentaciÂ¿Â¿n generada en la contractaciÂ¿Â¿n de una pÂ¿Â¿liza
      param in psseguro    : CÂ¿Â¿digo del seguro
      param in pcidioma    : CÂ¿Â¿digo del idioma
      param out mensajes   : mensajes de error
      return               : objeto rutas ficheros
   *************************************************************************/
   FUNCTION f_get_documprod (
      psseguro   IN       NUMBER,
      pcidioma   IN       NUMBER,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN t_iax_impresion
   IS
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (500)
                   := 'psseguro: ' || psseguro || ' - pcidioma: ' || pcidioma;
      vobject    VARCHAR2 (200)  := 'PAC_IAX_IMPRESION.F_Get_DocumProd';
      vt_obj     t_iax_impresion := t_iax_impresion ();
      vnumerr    NUMBER;
   BEGIN
      --ComprovaciÂ¿Â¿ de parÂ¿Â¿metres d'entrada
      IF psseguro IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      vt_obj :=
               pac_md_impresion.f_get_documprod (psseguro, pcidioma, mensajes);

      IF vt_obj IS NULL OR vt_obj.COUNT = 0
      THEN
         IF mensajes IS NULL OR mensajes.COUNT = 0
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 2, 500031);
            ROLLBACK;
            RETURN NULL;
         ELSE
            RAISE e_object_error;
         END IF;
      ELSE
         FOR i IN vt_obj.FIRST .. vt_obj.LAST
         LOOP
            vnumerr :=
               pac_md_log.f_log_actividad ('axisimprimir',
                                           1,
                                           NULL,
                                           vt_obj,
                                           i - 1,
                                           vt_obj (i).fichero,
                                           mensajes
                                          );
         END LOOP;
      END IF;

      pac_iax_impresion.pimpresion := vt_obj;
      COMMIT;
      RETURN vt_obj;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         ROLLBACK;
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         ROLLBACK;
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
         ROLLBACK;
         RETURN NULL;
   END f_get_documprod;

   /*************************************************************************
      ImpresiÂ¿Â¿n documentaciÂ¿Â¿n
      param in psseguro    : CÂ¿Â¿digo del seguro
      param in pctipo      : Tipo de Documento
      param in pcidioma    : CÂ¿Â¿digo del idioma
      param out mensajes   : mensajes de error
      return               : objeto rutas ficheros
   *************************************************************************/
   FUNCTION f_get_documprod_tipo (
      psseguro   IN       NUMBER,
      pctipo     IN       VARCHAR,
      pcidioma   IN       NUMBER,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN t_iax_impresion
   IS
      vpasexec     NUMBER (8)                      := 1;
      vparam       VARCHAR2 (500)
         :=    'psseguro: '
            || psseguro
            || ' - pctipo '
            || pctipo
            || ' - pcidioma: '
            || pcidioma;
      vobject      VARCHAR2 (200)  := 'PAC_IAX_IMPRESION.F_Get_DocumProd_tipo';
      vt_obj       t_iax_impresion                 := t_iax_impresion ();
      vtipo        NUMBER;
      vnumerr      NUMBER;
      v_filename   VARCHAR2 (200);
      v_pruta      VARCHAR2 (200);
      vres         NUMBER;
      vinfoimp     pac_md_impresion.ob_info_imp;
      vsproduc     NUMBER;
      vctipdoc     NUMBER;
      vcclase      NUMBER;
      vtdocume     doc_desdocumento.tdocume%TYPE;
      vnorden      NUMBER;
   BEGIN
      --ComprovaciÂ¿Â¿ de parÂ¿Â¿metres d'entrada
      IF psseguro IS NULL OR pctipo IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      --BUG 12850 - JTS - 08/02/2010
      vtipo := pac_md_impresion.f_get_tipo (pctipo);
      vpasexec := 4;

      IF vtipo IS NULL
      THEN
         RAISE e_param_error;
      ELSIF vtipo = 3
      THEN
         vnumerr :=
            pac_iax_simulaciones.f_validaciones ('IMPRIMIR_SIMULACION',
                                                 mensajes
                                                );

         IF vnumerr <> 0
         THEN
            RAISE e_object_error;
         END IF;
      END IF;

      --Fi BUG 12850 - JTS - 08/02/2010
      vpasexec := 5;
      vt_obj :=
         pac_md_impresion.f_get_documprod_tipo (psseguro,
                                                vtipo,
                                                pcidioma,
                                                mensajes
                                               );
      vpasexec := 6;

      IF vt_obj IS NULL OR vt_obj.COUNT = 0
      THEN
         IF mensajes IS NULL OR mensajes.COUNT = 0
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 2, 500031);
            ROLLBACK;
            RETURN NULL;
         ELSE
            RAISE e_object_error;
         END IF;
      ELSE
         FOR i IN vt_obj.FIRST .. vt_obj.LAST
         LOOP
            vnumerr :=
               pac_md_log.f_log_actividad ('axisimprimir',
                                           1,
                                           NULL,
                                           vt_obj,
                                           i - 1,
                                           vt_obj (i).fichero,
                                           mensajes
                                          );
         END LOOP;
      END IF;

      IF vtipo = 3
      THEN
         SELECT sproduc
           INTO vsproduc
           FROM estseguros
          WHERE sseguro = psseguro;

         IF NVL (f_parproductos_v (vsproduc, 'CDOCUME_SIMUL'), 0) <> 0
         THEN
            IF vt_obj IS NOT NULL
            THEN
               vres :=
                  pac_util.f_path_filename (vt_obj (1).fichero,
                                            v_pruta,
                                            v_filename
                                           );
               vinfoimp :=
                  pac_md_impresion.f_get_infoimppol (psseguro,
                                                     vtipo,
                                                     'EST',
                                                     mensajes
                                                    );

               --- TCS_jpaezr_REV_alt_8 ---
               
          SELECT /*+ FULL(D) */ d.ctipdoc, 
                       d.cclase, 
                       dd.tdocume, 
                       d.norden 
                  INTO vctipdoc, 
                       vcclase, 
                       vtdocume, 
                       vnorden 
                  FROM doc_desdocumento dd, 
                       doc_docurequerida d 
                 WHERE d.cdocume = f_parproductos_v(vsproduc, 'CDOCUME_SIMUL') 
                   AND d.sproduc = vinfoimp.sproduc 
                   AND d.cactivi = 0 
                   AND d.cmotmov = 100 
                   AND d.cdocume = dd.cdocume + 0 
                   AND dd.cidioma = pcidioma;  
               

               vres :=
                  pac_docrequerida.f_grabardocrequerida
                                           (NULL,
                                            vinfoimp.sproduc,
                                            psseguro,
                                            0,
                                            vinfoimp.nmovimi,
                                            1,
                                            NULL,
                                            f_parproductos_v (vsproduc,
                                                              'CDOCUME_SIMUL'
                                                             ),
                                            vctipdoc,
                                            vcclase,
                                            vnorden,
                                            vtdocume,
                                            v_filename,
                                            1,
                                            NULL,
                                            NULL
                                           );
            END IF;
         END IF;
      END IF;

      pac_iax_impresion.pimpresion := vt_obj;         --xpl 13092010 bug 15685
      COMMIT;
      RETURN vt_obj;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         ROLLBACK;
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         ROLLBACK;
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
         ROLLBACK;
         RETURN NULL;
   END f_get_documprod_tipo;

   /*************************************************************************
      ImpresiÂ¿Â¿n justificante mÂ¿Â¿dico
      param in P_NREEMB    : NÂ¿Â¿mero de reembolso
      param in P_NFACT     : NÂ¿Â¿mero de factura
      param in P_NRIESGO   : Id. de riesgo
      param out mensajes   : mensajes de error
      return               : objeto rutas ficheros
   *************************************************************************/
   FUNCTION f_imprimir_factura (
      p_nreemb    IN       NUMBER,
      p_nfact     IN       NUMBER,
      p_nriesgo   IN       NUMBER,
      p_sseguro   IN       NUMBER,
      p_tipo      IN       VARCHAR2,
      mensajes    OUT      t_iax_mensajes
   )
      RETURN t_iax_impresion
   IS
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (500)
         :=    'P_NREEMB: '
            || p_nreemb
            || ' P_NFACT: '
            || p_nfact
            || ' P_NRIESGO: '
            || p_nriesgo;
      vobject    VARCHAR2 (200)  := 'PAC_IAX_IMPRESION.F_Imprimir_Factura';
      vt_obj     t_iax_impresion := t_iax_impresion ();
      vnumerr    NUMBER;
   BEGIN
      --ComprovaciÂ¿Â¿ de parÂ¿Â¿metres
      IF    p_nreemb IS NULL
         OR p_nfact IS NULL
         OR p_nriesgo IS NULL
         OR p_sseguro IS NULL
         OR p_tipo IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vt_obj :=
         pac_md_impresion.f_imprimir_factura (p_nreemb,
                                              p_nfact,
                                              p_nriesgo,
                                              p_sseguro,
                                              p_tipo,
                                              mensajes
                                             );
      pac_iax_impresion.pimpresion := vt_obj;         --xpl 13092010 bug 15685

      IF vt_obj IS NOT NULL AND vt_obj.COUNT > 0
      THEN
         FOR i IN vt_obj.FIRST .. vt_obj.LAST
         LOOP
            vnumerr :=
               pac_md_log.f_log_actividad ('axisimprimir',
                                           1,
                                           NULL,
                                           vt_obj,
                                           i - 1,
                                           vt_obj (i).fichero,
                                           mensajes
                                          );
         END LOOP;
      END IF;

      COMMIT;
      RETURN vt_obj;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         ROLLBACK;
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         ROLLBACK;
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
         ROLLBACK;
         RETURN NULL;
   END f_imprimir_factura;

   /*************************************************************************
      ImpresiÂ¿Â¿n del cuestionario de salud por SSEGURO y NRIESGO
      param in psseguro   : CÂ¿Â¿digo interno del seguro
      param in pnriesgo   : NÂ¿Â¿mero del riesgo
      param in pnomfitxer : Nombre del fichero
      param in pmodo      : Modo EST o POL
      param out mensajes  : mensajes de error
      return              : objeto rutas ficheros
   *************************************************************************/
   FUNCTION f_get_questsalud (
      psseguro     IN       NUMBER,
      pnriesgo     IN       NUMBER,
      pnomfitxer   IN       VARCHAR2,
      pmodo        IN       VARCHAR2,
      mensajes     OUT      t_iax_mensajes
   )
      RETURN t_iax_impresion
   IS
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (500)
         :=    'psseguro: '
            || psseguro
            || ', pnriesgo: '
            || pnriesgo
            || ' pnomfitxer:'
            || pnomfitxer
            || ' pmodo:'
            || pmodo;
      vobject    VARCHAR2 (200)  := 'PAC_IAX_IMPRESION.F_Get_QuestSalud';
      vt_obj     t_iax_impresion := t_iax_impresion ();
      vnumerr    NUMBER;
   BEGIN
      --ComprovaciÂ¿Â¿ de parÂ¿Â¿metres d'entrada
      IF psseguro IS NULL OR pnriesgo IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vt_obj :=
         pac_md_impresion.f_get_questsalud (psseguro,
                                            pnriesgo,
                                            pnomfitxer,
                                            pmodo,
                                            mensajes
                                           );

      IF vt_obj IS NULL OR vt_obj.COUNT = 0
      THEN
         IF mensajes IS NULL OR mensajes.COUNT = 0
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 2, 500031);
            ROLLBACK;
            RETURN NULL;
         ELSE
            RAISE e_object_error;
         END IF;
      ELSE
         FOR i IN vt_obj.FIRST .. vt_obj.LAST
         LOOP
            vnumerr :=
               pac_md_log.f_log_actividad ('axisimprimir',
                                           1,
                                           NULL,
                                           vt_obj,
                                           i - 1,
                                           vt_obj (i).fichero,
                                           mensajes
                                          );
         END LOOP;
      END IF;

      pac_iax_impresion.pimpresion := vt_obj;         --xpl 13092010 bug 15685
      COMMIT;
      RETURN vt_obj;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         ROLLBACK;
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         ROLLBACK;
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
         ROLLBACK;
         RETURN NULL;
   END f_get_questsalud;

   --BUG 10233 - JTS - 04/06/2009
   /*************************************************************************
      ImpresiÂ¿Â¿n carta de impago
      param in P_SGESCARTA : ID. de la carta
      param in p_sdevolu   : ID. devolucion
      param out mensajes   : mensajes de error
      return               : objeto rutas ficheros
      -- Bug 0022030 - 23/04/2012 - JMF
   *************************************************************************/
   FUNCTION f_imprimir_carta (
      p_sgescarta   IN       NUMBER,
      p_sdevolu     IN       NUMBER,
      mensajes      OUT      t_iax_mensajes
   )
      RETURN t_iax_impresion
   IS
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (500)
                    := 'p_sgescarta: ' || p_sgescarta || ' dev=' || p_sdevolu;
      vobject    VARCHAR2 (200)  := 'PAC_IAX_IMPRESION.F_Imprimir_Carta';
      vt_obj     t_iax_impresion := t_iax_impresion ();
      vnumerr    NUMBER;
   BEGIN
      --ComprovaciÂ¿Â¿ de parÂ¿Â¿metres
      IF p_sgescarta IS NULL AND p_sdevolu IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vt_obj :=
          pac_md_impresion.f_imprimir_carta (p_sgescarta, p_sdevolu, mensajes);

      IF vt_obj IS NULL
      THEN
         RAISE e_object_error;
      END IF;

      pac_iax_impresion.pimpresion := vt_obj;         --xpl 13092010 bug 15685
      COMMIT;

      IF vt_obj IS NOT NULL AND vt_obj.COUNT > 0
      THEN
         FOR i IN vt_obj.FIRST .. vt_obj.LAST
         LOOP
            vnumerr :=
               pac_md_log.f_log_actividad ('axisimprimir',
                                           1,
                                           NULL,
                                           vt_obj,
                                           i - 1,
                                           vt_obj (i).fichero,
                                           mensajes
                                          );
         END LOOP;
      END IF;

      RETURN vt_obj;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         ROLLBACK;
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         ROLLBACK;
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
         ROLLBACK;
         RETURN NULL;
   END f_imprimir_carta;

--Fi BUG 10233 - JTS - 04/06/2009

   --BUG 10729 - JTS - 12/08/2009
   /*************************************************************************
      ImpresiÂ¿Â¿n recibos
      param in P_SPROIMP   : ID. del lote de recibos a imprimir
      param out mensajes   : mensajes de error
      return               : objeto rutas ficheros
   *************************************************************************/
   FUNCTION f_imprimir_recibos (
      p_sproimp   IN       NUMBER,
      mensajes    OUT      t_iax_mensajes
   )
      RETURN t_iax_impresion
   IS
      vnumerr        NUMBER (8)      := 0;
      vpasexec       NUMBER (8)      := 1;
      vparam         VARCHAR2 (500)  := 'p_sproimp: ' || p_sproimp;
      vobject        VARCHAR2 (200) := 'PAC_IAX_IMPRESION.F_Imprimir_Recibos';
      vt_impresion   t_iax_impresion;
   BEGIN
      vpasexec := 2;
      vt_impresion :=
                    pac_md_impresion.f_imprimir_recibos (p_sproimp, mensajes);
      pac_iax_impresion.pimpresion := vt_impresion;  --xpl 13092010 bug 15685

      IF vt_impresion IS NOT NULL AND vt_impresion.COUNT > 0
      THEN
         FOR i IN vt_impresion.FIRST .. vt_impresion.LAST
         LOOP
            vnumerr :=
               pac_md_log.f_log_actividad ('axisimprimir',
                                           1,
                                           NULL,
                                           vt_impresion,
                                           i - 1,
                                           vt_impresion (i).fichero,
                                           mensajes
                                          );
         END LOOP;
      END IF;

      COMMIT;
      RETURN vt_impresion;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         ROLLBACK;
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         ROLLBACK;
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
         ROLLBACK;
         RETURN NULL;
   END f_imprimir_recibos;

--Fi BUG 10729 - JTS - 12/08/2009
   --BUG 10684 - JGM - 14/09/2009
   /*************************************************************************
      ImpresiÂ¿Â¿n del cuestionario de salud por SSEGURO y NRIESGO
      param in pcempres   : CÂ¿Â¿digo empresa
      param in pcproces   : NÂ¿Â¿mero de proceso
      param in pcagente   : NÂ¿Â¿mero de agente
      param in pnomfitxer : Nombre del fichero
      param out mensajes  : mensajes de error
      return              : objeto rutas ficheros
   *************************************************************************/
   FUNCTION f_get_listcomi (
      pcempres     IN       NUMBER,
      pcproces     IN       NUMBER,
      pcagente     IN       NUMBER,
      pnomfitxer   IN       VARCHAR2,
      mensajes     OUT      t_iax_mensajes
   )
      RETURN t_iax_impresion
   IS
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (500)
         :=    'pcempres: '
            || pcempres
            || ', pcproces: '
            || pcproces
            || ' pcagente:'
            || pcagente
            || ' pnomfitxer:'
            || pnomfitxer;
      vobject    VARCHAR2 (200)  := 'PAC_IAX_IMPRESION.F_Get_ListComi';
      vt_obj     t_iax_impresion := t_iax_impresion ();
      vnumerr    NUMBER;
   BEGIN
      --ComprovaciÂ¿Â¿ de parÂ¿Â¿metres d'entrada
      IF pcempres IS NULL OR pcproces IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vt_obj :=
         pac_md_impresion.f_get_listcomi (pcempres,
                                          pcproces,
                                          pcagente,
                                          pnomfitxer,
                                          mensajes
                                         );

      IF vt_obj IS NULL OR vt_obj.COUNT = 0
      THEN
         IF mensajes IS NULL OR mensajes.COUNT = 0
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 2, 500031);
            RETURN NULL;
         ELSE
            RAISE e_object_error;
         END IF;
      END IF;

      pac_iax_impresion.pimpresion := vt_obj;         --xpl 13092010 bug 15685

      IF vt_obj IS NOT NULL AND vt_obj.COUNT > 0
      THEN
         FOR i IN vt_obj.FIRST .. vt_obj.LAST
         LOOP
            vnumerr :=
               pac_md_log.f_log_actividad ('axisimprimir',
                                           1,
                                           NULL,
                                           vt_obj,
                                           i - 1,
                                           vt_obj (i).fichero,
                                           mensajes
                                          );
         END LOOP;
      END IF;

      RETURN vt_obj;
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
   END f_get_listcomi;

   /*************************************************************************
      --BUG12388 - JTS - 23/12/2009
      ImpresiÂ¿Â¿n traspasos
      param in P_STRAS     : ID. del traspaso a imprimir
      param in P_SSEGURO   : ID. del seguro
      param in P_TIPO      : tipo traspaso, "TRAS/REV" (Traspaso o revocaciÂ¿Â¿n)
      param out mensajes   : mensajes de error
      return               : objeto rutas ficheros
   *************************************************************************/
   FUNCTION f_imprimir_traspas (
      p_stras     IN       NUMBER,
      p_sseguro   IN       NUMBER,
      p_tipo      IN       VARCHAR2,
      mensajes    OUT      t_iax_mensajes
   )
      RETURN t_iax_impresion
   IS
      vnumerr        NUMBER (8)      := 0;
      vpasexec       NUMBER (8)      := 1;
      vparam         VARCHAR2 (500)
         :=    'p_stras: '
            || p_stras
            || ' p_sseguro: '
            || p_sseguro
            || ' p_tipo: '
            || p_tipo;
      vobject        VARCHAR2 (200)  := 'PAC_IAX_IMPRESION.f_imprimir_traspas';
      vt_impresion   t_iax_impresion;
   BEGIN
      vpasexec := 2;
      vt_impresion :=
         pac_md_impresion.f_imprimir_traspas (p_stras,
                                              p_sseguro,
                                              p_tipo,
                                              mensajes
                                             );
      pac_iax_impresion.pimpresion := vt_impresion;   --xpl 13092010 bug 15685

      IF vt_impresion IS NOT NULL AND vt_impresion.COUNT > 0
      THEN
         FOR i IN vt_impresion.FIRST .. vt_impresion.LAST
         LOOP
            vnumerr :=
               pac_md_log.f_log_actividad ('axisimprimir',
                                           1,
                                           NULL,
                                           vt_impresion,
                                           i - 1,
                                           vt_impresion (i).fichero,
                                           mensajes
                                          );
         END LOOP;
      END IF;

      COMMIT;
      RETURN vt_impresion;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         ROLLBACK;
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         ROLLBACK;
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
         ROLLBACK;
         RETURN NULL;
   END f_imprimir_traspas;

   /*************************************************************************
       --BUG 16446 --ETM- 31/12/2010
      ImpresiÂ¿Â¿n recibo
      param in P_NRECIBO   : ID. NRECIBO
      param in P_SSEGURO   : ID. del seguro
      param in P_TIPO      : ctipo
      param out mensajes   : mensajes de error
      return               : objeto rutas ficheros
   *************************************************************************/
   FUNCTION f_imprimir_recibo (
      p_nrecibo   IN       NUMBER,
      p_ndocume   IN       NUMBER,
      p_sseguro   IN       NUMBER,
      p_tipo      IN       VARCHAR2,
      mensajes    OUT      t_iax_mensajes
   )
      RETURN t_iax_impresion
   IS
      vnumerr    NUMBER (8)      := 0;
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (500)
         :=    'p_nrecibo: '
            || p_nrecibo
            || ' p_sseguro: '
            || p_sseguro
            || ' p_tipo: '
            || p_tipo;
      vobject    VARCHAR2 (200)  := 'PAC_IAX_IMPRESION.f_imprimir_recibo';
      vt_obj     t_iax_impresion;
   BEGIN
      vpasexec := 2;
      vt_obj :=
         pac_md_impresion.f_imprimir_recibo (p_nrecibo,
                                             p_ndocume,
                                             p_sseguro,
                                             p_tipo,
                                             mensajes
                                            );
      pac_iax_impresion.pimpresion := vt_obj;

      IF vt_obj IS NOT NULL AND vt_obj.COUNT > 0
      THEN
         FOR i IN vt_obj.FIRST .. vt_obj.LAST
         LOOP
            vnumerr :=
               pac_md_log.f_log_actividad ('axisimprimir',
                                           1,
                                           NULL,
                                           vt_obj,
                                           i - 1,
                                           vt_obj (i).fichero,
                                           mensajes
                                          );
         END LOOP;
      END IF;

      COMMIT;
      RETURN vt_obj;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         ROLLBACK;
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         ROLLBACK;
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
         ROLLBACK;
         RETURN NULL;
   END f_imprimir_recibo;

      /*************************************************************************
      --BUG 16446 --ETM- 31/12/2010
      ImpresiÂ¿Â¿n pagos
         param in p_sseguro    : id de seguro
        param in P_SIDEGAP   : ID. DE PAGOS A  imprimir
        param in P_TIPO      : ctipo plantillas
        param in  p_ccausin : causa del siniestro
        param in p_cmotsin : motivo del siniestro
        param out mensajes   : mensajes de error
       return               : objeto rutas ficheros
   *************************************************************************/
   FUNCTION f_imprimir_pago (
      p_sseguro   IN       NUMBER,
      p_sidepag   IN       NUMBER,
      p_tipo      IN       VARCHAR,
      p_ccausin   IN       NUMBER,
      p_cmotsin   IN       NUMBER,
      mensajes    OUT      t_iax_mensajes
   )
      RETURN t_iax_impresion
   IS
      vnumerr    NUMBER (8)      := 0;
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (1000)
         :=    'P_sseguro: '
            || p_sseguro
            || ' P_sidepag: '
            || p_sidepag
            || ' p_tipo: '
            || p_tipo
            || ' p_ccausin: '
            || p_ccausin
            || ' p_cmotsin: '
            || p_cmotsin;
      vobject    VARCHAR2 (200)  := 'PAC_IAX_IMPRESION.F_Imprimir_Pago';
      vt_obj     t_iax_impresion;
   BEGIN
      --ComprovaciÂ¿Â¿ de parÂ¿Â¿metres
      IF    p_sseguro IS NULL
         OR p_sidepag IS NULL
         OR p_tipo IS NULL
         OR p_ccausin IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vt_obj :=
         pac_md_impresion.f_imprimir_pago (p_sseguro,
                                           p_sidepag,
                                           p_tipo,
                                           p_ccausin,
                                           p_cmotsin,
                                           mensajes
                                          );
      pac_iax_impresion.pimpresion := vt_obj;

      IF vt_obj IS NULL OR vt_obj.COUNT = 0
      THEN
         IF mensajes IS NULL
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 2, 500031);
            ROLLBACK;
            RETURN NULL;
         ELSE
            RAISE e_object_error;
         END IF;
      ELSE
         FOR i IN vt_obj.FIRST .. vt_obj.LAST
         LOOP
            vnumerr :=
               pac_md_log.f_log_actividad ('axisimprimir',
                                           1,
                                           NULL,
                                           vt_obj,
                                           i - 1,
                                           vt_obj (i).fichero,
                                           mensajes
                                          );
         END LOOP;
      END IF;

      COMMIT;
      RETURN vt_obj;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         ROLLBACK;
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         ROLLBACK;
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
         ROLLBACK;
         RETURN NULL;
   END f_imprimir_pago;

    /*************************************************************************
      --BUG 19783 --ETM- 24/11/2011
      ImpresiÂ¿Â¿n pagos
      param in p_nsinies    : id de SINIESTRO
      param in P_ntramit   : numero de tramitacion
      param in P_cestado      : estado de la tramitacion
      param in P_TIPO      : ctipo plantillas
      param out mensajes   : mensajes de error
      return               : objeto rutas ficheros
   *************************************************************************/
   FUNCTION f_imprimir_trami (
      p_nsinies   IN       VARCHAR2,
      p_ntramit   IN       NUMBER,
      p_cestado   IN       NUMBER,
      p_tipo      IN       VARCHAR,
      mensajes    OUT      t_iax_mensajes
   )
      RETURN t_iax_impresion
   IS
      vnumerr    NUMBER (8)      := 0;
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (1000)
         :=    'P_nsinies: '
            || p_nsinies
            || ' P_ntramit: '
            || p_ntramit
            || ' p_cestado: '
            || p_cestado
            || ' p_tipo: '
            || p_tipo;
      vobject    VARCHAR2 (200)  := 'PAC_IAX_IMPRESION.f_imprimir_trami';
      vt_obj     t_iax_impresion;
   BEGIN
      --ComprovaciÂ¿Â¿ de parÂ¿Â¿metres
      IF    p_nsinies IS NULL
         OR p_ntramit IS NULL
         OR p_tipo IS NULL
         OR p_cestado IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vt_obj :=
         pac_md_impresion.f_imprimir_trami (p_nsinies,
                                            p_ntramit,
                                            p_cestado,
                                            p_tipo,
                                            mensajes
                                           );
      pac_iax_impresion.pimpresion := vt_obj;

      IF vt_obj IS NULL OR vt_obj.COUNT = 0
      THEN
         IF mensajes IS NULL
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 2, 500031);
            ROLLBACK;
            RETURN NULL;
         ELSE
            RAISE e_object_error;
         END IF;
      ELSE
         FOR i IN vt_obj.FIRST .. vt_obj.LAST
         LOOP
            vnumerr :=
               pac_md_log.f_log_actividad ('axisimprimir',
                                           1,
                                           NULL,
                                           vt_obj,
                                           i - 1,
                                           vt_obj (i).fichero,
                                           mensajes
                                          );
         END LOOP;
      END IF;

      COMMIT;
      RETURN vt_obj;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         ROLLBACK;
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         ROLLBACK;
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
         ROLLBACK;
         RETURN NULL;
   END f_imprimir_trami;

--FIN --BUG 19783 --ETM- 24/11/2011

   /*************************************************************************
      --BUG 21458 - JTS - 22/05/2012
      FUNCTION f_firmar_doc
       param in p_iddoc    : id del documento GEDOX a firmar
       param in P_firmab64 : firma en BASE64
       param out mensajes  : mensajes de error
      return               : error
   *************************************************************************/
   FUNCTION f_firmar_doc (
      p_iddoc       IN       VARCHAR2,
      p_fichero     IN       VARCHAR2,
      p_firmab64    IN       CLOB,
      p_conffirma   IN       VARCHAR2,
      p_ccodplan    IN       VARCHAR2,
      mensajes      OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (100) := 'p_iddoc: ' || p_iddoc;
      vobject    VARCHAR2 (200) := 'PAC_IAX_IMPRESION.f_firmar_doc';
      verror     NUMBER;
   BEGIN
      --ComprovaciÂ¿Â¿ de parÂ¿Â¿metres
      IF p_iddoc IS NULL OR p_firmab64 IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      verror :=
         pac_md_impresion.f_firmar_doc (p_iddoc,
                                        p_fichero,
                                        p_firmab64,
                                        p_conffirma,
                                        p_ccodplan,
                                        mensajes
                                       );

      IF verror <> 0
      THEN
         ROLLBACK;
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN verror;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
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
         RETURN 1;
   END f_firmar_doc;

   /*************************************************************************
    -- ini BUG 0022444 - JMF - 05/06/2012
      ImpresiÂ¿Â¿n carta rechazo siniestro
       param in p_sseguro : numero sseguro
       param in p_tipo    : tipo de plantilla
       param out mensajes : mensajes de error
       return             : objeto rutas ficheros
   *************************************************************************/
   FUNCTION f_imprimir_cartarechazosin (
      p_sseguro   IN       NUMBER,
      p_tipo      IN       VARCHAR,
      mensajes    OUT      t_iax_mensajes
   )
      RETURN t_iax_impresion
   IS
      vnumerr    NUMBER (8)      := 0;
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (1000)
                       := 'p_sseguro: ' || p_sseguro || ' p_tipo: ' || p_tipo;
      vobject    VARCHAR2 (200)
                            := 'PAC_IAX_IMPRESION.f_imprimir_cartarechazosin';
      vt_obj     t_iax_impresion;
   BEGIN
      --ComprovaciÂ¿Â¿ de parÂ¿Â¿metres
      IF p_sseguro IS NULL OR p_tipo IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vt_obj :=
         pac_md_impresion.f_imprimir_cartarechazosin (p_sseguro,
                                                      p_tipo,
                                                      mensajes
                                                     );
      pac_iax_impresion.pimpresion := vt_obj;

      IF vt_obj IS NULL OR vt_obj.COUNT = 0
      THEN
         IF mensajes IS NULL
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 2, 500031);
            ROLLBACK;
            RETURN NULL;
         ELSE
            RAISE e_object_error;
         END IF;
      ELSE
         FOR i IN vt_obj.FIRST .. vt_obj.LAST
         LOOP
            vnumerr :=
               pac_md_log.f_log_actividad ('axisimprimir',
                                           1,
                                           NULL,
                                           vt_obj,
                                           i - 1,
                                           vt_obj (i).fichero,
                                           mensajes
                                          );
         END LOOP;
      END IF;

      COMMIT;
      RETURN vt_obj;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         ROLLBACK;
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         ROLLBACK;
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
         ROLLBACK;
         RETURN NULL;
   END f_imprimir_cartarechazosin;

-- fin BUG 0022444 - JMF - 05/06/2012

   /*************************************************************************
    -- ini BUG 0021765 - JTS - 19/06/2012
      ImpresiÂ¿Â¿n cartas de preavisos
       param in p_sproces : Sproces
       param in p_tipo    : tipo de plantilla
       param out mensajes : mensajes de error
       return             : objeto rutas ficheros
   *************************************************************************/
   FUNCTION f_imprimir_cartaspreavisos (
      p_sproces   IN       NUMBER,
      p_tipo      IN       VARCHAR,
      mensajes    OUT      t_iax_mensajes
   )
      RETURN t_iax_impresion
   IS
      vnumerr    NUMBER (8)      := 0;
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (1000)
                       := 'p_sproces: ' || p_sproces || ' p_tipo: ' || p_tipo;
      vobject    VARCHAR2 (200)
                            := 'PAC_IAX_IMPRESION.f_imprimir_cartaspreavisos';
      vt_obj     t_iax_impresion;
   BEGIN
      --ComprovaciÂ¿Â¿ de parÂ¿Â¿metres
      --De moment no, quan ho fem be si que mirarem aixo!!!!
      /*IF p_sproces IS NULL
         OR p_tipo IS NULL THEN
         RAISE e_param_error;
      END IF;*/
      vpasexec := 2;
      vt_obj :=
         pac_md_impresion.f_imprimir_cartaspreavisos (p_sproces,
                                                      p_tipo,
                                                      mensajes
                                                     );
      pac_iax_impresion.pimpresion := vt_obj;

      IF vt_obj IS NULL OR vt_obj.COUNT = 0
      THEN
         IF mensajes IS NULL
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 2, 500031);
            ROLLBACK;
            RETURN NULL;
         ELSE
            RAISE e_object_error;
         END IF;
      ELSE
         FOR i IN vt_obj.FIRST .. vt_obj.LAST
         LOOP
            vnumerr :=
               pac_md_log.f_log_actividad ('axisimprimir',
                                           1,
                                           NULL,
                                           vt_obj,
                                           i - 1,
                                           vt_obj (i).fichero,
                                           mensajes
                                          );
         END LOOP;
      END IF;

      COMMIT;
      RETURN vt_obj;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         ROLLBACK;
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         ROLLBACK;
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
         ROLLBACK;
         RETURN NULL;
   END f_imprimir_cartaspreavisos;

   FUNCTION f_get_impagrup (
      pcurcat    OUT   sys_refcursor,
      mensajes   OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vnumerr    NUMBER (8)      := 0;
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (1000) := '';
      vobject    VARCHAR2 (200)  := 'PAC_IAX_IMPRESION.f_get_impagrup';
   BEGIN
      vnumerr := pac_md_impresion.f_get_impagrup (pcurcat, mensajes);
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
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
         RETURN 1;
   END f_get_impagrup;

   /*************************************************************************
       Bug 22328 - 30/07/2012 - JRB
       Inserta el documento
       param in PIDDOCGEDOX : Identificador del documento gedox
       param in PTDESC    : descripcion
       param out mensajes : mensajes de error
       return             : objeto rutas ficheros
   *************************************************************************/
   FUNCTION f_ins_doc (
      piddocgedox   IN       NUMBER,
      ptdesc        IN       VARCHAR2,
      ptfich        IN       VARCHAR2,
      pctipo        IN       NUMBER,
      pcdiferido    IN       NUMBER,
      pccategoria   IN       NUMBER,
      mensajes      OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vnumerr    NUMBER (8)      := 0;
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (1000) := '';
      vobject    VARCHAR2 (200)  := 'PAC_IAX_IMPRESION.f_get_impagrup';
   BEGIN
      IF (   piddocgedox IS NULL
          OR ptdesc IS NULL
          OR ptfich IS NULL
          OR pctipo IS NULL
         )
      THEN
         RAISE e_param_error;
      END IF;

      vnumerr :=
         pac_md_impresion.f_ins_doc (piddocgedox,
                                     ptdesc,
                                     ptfich,
                                     pctipo,
                                     pcdiferido,
                                     pccategoria,
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
                                     mensajes
                                    );

      IF vnumerr = 0
      THEN
         COMMIT;
      ELSE
         ROLLBACK;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         ROLLBACK;
         RETURN 1;
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
         ROLLBACK;
         RETURN 1;
   END f_ins_doc;

/*************************************************************************
       Bug 22328 - 30/07/2012 - JRB
       Recupera algo
       param out PCURCAT : Select de las impresiones agrupadas
       param out mensajes : mensajes de error
       return             : objeto rutas ficheros
   *************************************************************************/
   FUNCTION f_get_impdet (
      pdefault      IN       NUMBER,
      pccategoria   IN       NUMBER,
      pctipo        IN       NUMBER,
      ptfich        IN       VARCHAR2,
      pfsolici      IN       DATE,
      puser         IN       VARCHAR2,
      pfult         IN       DATE,
      pusult        IN       VARCHAR2,
      pcestado      IN       NUMBER,
      psproces      IN       NUMBER,
      pnpoliza      IN       NUMBER,
      pncertif      IN       NUMBER,
      pcagente      IN       NUMBER,
      psproduc      IN       NUMBER,
      pcramo        IN       NUMBER,
      pcurdocs      OUT      sys_refcursor,
      plistzips     OUT      t_iax_impresion,
      mensajes      OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vnumerr    NUMBER (8)      := 0;
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (1000) := '';
      vobject    VARCHAR2 (200)  := 'PAC_IAX_IMPRESION.f_get_impagrup';
   BEGIN
      vnumerr :=
         pac_md_impresion.f_get_impdet (pdefault,
                                        pccategoria,
                                        pctipo,
                                        ptfich,
                                        pfsolici,
                                        puser,
                                        pfult,
                                        pusult,
                                        pcestado,
                                        psproces,
                                        pnpoliza,
                                        pncertif,
                                        pcagente,
                                        psproduc,
                                        pcramo,
                                        pcurdocs,
                                        plistzips,
                                        mensajes
                                       );
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
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
         RETURN 1;
   END f_get_impdet;

   /*************************************************************************
       Bug 22328 - 30/07/2012 - JRB
       Recupera algo
       param out PCURCAT : Select de las impresiones agrupadas
       param out mensajes : mensajes de error
       return             : objeto rutas ficheros
   *************************************************************************/
   FUNCTION f_envia_impresora (
      plistcategorias   IN       VARCHAR2,
      plistdocs         IN       VARCHAR2,
      pidimpresora      IN       NUMBER,
      mensajes          OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vnumerr    NUMBER (8)      := 0;
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (1000) := '';
      vobject    VARCHAR2 (200)  := 'PAC_IAX_IMPRESION.f_envia_impresora';
   BEGIN
      IF    (    pidimpresora IS NOT NULL
             AND (plistcategorias IS NOT NULL OR plistdocs IS NOT NULL)
            )
         OR (pidimpresora IS NULL AND plistdocs IS NOT NULL)
      THEN
         vnumerr :=
            pac_md_impresion.f_envia_impresora (plistcategorias,
                                                plistdocs,
                                                pidimpresora,
                                                mensajes
                                               );
      ELSE
         RAISE e_param_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
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
         RETURN 1;
   END f_envia_impresora;

   /*************************************************************************
       Bug 22328 - 30/07/2012 - JRB
       Recupera algo
       param out PCURCAT : Select de las impresiones agrupadas
       param out mensajes : mensajes de error
       return             : objeto rutas ficheros
   *************************************************************************/
   FUNCTION f_get_categorias (mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      vnumerr    NUMBER (8)      := 0;
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (1000) := '';
      vobject    VARCHAR2 (200)  := 'PAC_IAX_IMPRESION.f_get_impagrup';
      vcursor    sys_refcursor;
   BEGIN
      vcursor := pac_md_impresion.f_get_categorias (mensajes);
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
   END f_get_categorias;

     /*************************************************************************
       Bug 22328 - 30/07/2012 - JRB
       Recupera algo
       param out PCURCAT : Select de las impresiones agrupadas
       param out mensajes : mensajes de error
       return             : objeto rutas ficheros
   *************************************************************************/
   FUNCTION f_get_impresoras (mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      vnumerr    NUMBER (8)      := 0;
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (1000) := '';
      vobject    VARCHAR2 (200)  := 'PAC_IAX_IMPRESION.f_get_impagrup';
      vcursor    sys_refcursor;
   BEGIN
      vcursor := pac_md_impresion.f_get_impresoras (mensajes);
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
   END f_get_impresoras;

   /*************************************************************************
       --BUG 24687 --JTS- 31/12/2010
      ImpresiÂ¿Â¿n sproces
      param in P_sproces   : ID. sproces
      param in P_TIPO      : ctipo
      param out mensajes   : mensajes de error
      return               : objeto rutas ficheros
   *************************************************************************/
   FUNCTION f_imprimir_sproces (
      p_sproces   IN       NUMBER,
      p_tipo      IN       VARCHAR2,
      mensajes    OUT      t_iax_mensajes
   )
      RETURN t_iax_impresion
   IS
      vnumerr    NUMBER (8)      := 0;
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (500)
                       := 'p_sproces: ' || p_sproces || ' p_tipo: ' || p_tipo;
      vobject    VARCHAR2 (200)  := 'PAC_IAX_IMPRESION.f_imprimir_sproces';
      vt_obj     t_iax_impresion;
   BEGIN
      vpasexec := 2;
      vt_obj :=
            pac_md_impresion.f_imprimir_sproces (p_sproces, p_tipo, mensajes);
      pac_iax_impresion.pimpresion := vt_obj;

      IF vt_obj IS NOT NULL AND vt_obj.COUNT > 0
      THEN
         FOR i IN vt_obj.FIRST .. vt_obj.LAST
         LOOP
            vnumerr :=
               pac_md_log.f_log_actividad ('axisimprimir',
                                           1,
                                           NULL,
                                           vt_obj,
                                           i - 1,
                                           vt_obj (i).fichero,
                                           mensajes
                                          );
         END LOOP;
      END IF;

      COMMIT;
      RETURN vt_obj;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         ROLLBACK;
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         ROLLBACK;
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
         ROLLBACK;
         RETURN NULL;
   END f_imprimir_sproces;

   FUNCTION f_recupera_pendientes
      RETURN sys_refcursor
   IS
      vcur   sys_refcursor;
   BEGIN
      vcur := pac_md_impresion.f_recupera_pendientes;
      RETURN vcur;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_IAX_IMPRESION.f_recupera_pendientes',
                      0,
                      SQLCODE,
                      SQLERRM
                     );

         IF vcur%ISOPEN
         THEN
            CLOSE vcur;
         END IF;

         RETURN NULL;
   END f_recupera_pendientes;

   FUNCTION f_genera_pendientes (piddocdif IN NUMBER)
      RETURN sys_refcursor
   IS
      vcur   sys_refcursor;
   BEGIN
      vcur := pac_md_impresion.f_genera_pendientes (piddocdif);
      RETURN vcur;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_IAX_IMPRESION.f_genera_pendientes',
                      1,
                      SQLCODE,
                      SQLERRM
                     );

         IF vcur%ISOPEN
         THEN
            CLOSE vcur;
         END IF;

         RETURN NULL;
   END f_genera_pendientes;

   FUNCTION f_gedox_pendiente (
      piddocdif    IN   NUMBER,
      pnorden      IN   NUMBER,
      ptfilename   IN   VARCHAR2,
      ptruta       IN   VARCHAR2
   )
      RETURN NUMBER
   IS
      vnumerr   NUMBER;
   BEGIN
      vnumerr :=
         pac_md_impresion.f_gedox_pendiente (piddocdif,
                                             pnorden,
                                             ptfilename,
                                             ptruta
                                            );
      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_IAX_IMPRESION.f_gedox_pendiente',
                      1,
                      SQLCODE,
                      SQLERRM
                     );
         RETURN 1;
   END f_gedox_pendiente;

   FUNCTION f_set_fichzip (
      psproces   IN   NUMBER,
      ptagrupa   IN   VARCHAR2,
      pcestado   IN   NUMBER,
      pterror    IN   VARCHAR2
   )
      RETURN NUMBER
   IS
      vnumerr   NUMBER;
   BEGIN
      vnumerr :=
         pac_md_impresion.f_set_fichzip (psproces,
                                         ptagrupa,
                                         pcestado,
                                         pterror
                                        );
      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_IAX_IMPRESION.f_set_fichzip',
                      1,
                      SQLCODE,
                      SQLERRM
                     );
         RETURN 1;
   END f_set_fichzip;

   FUNCTION f_imprimir_via_correo (
      pmodo            IN       VARCHAR2,
      ptevento         IN       VARCHAR2,
      pcidioma         IN       NUMBER,
      pdirectorio      IN       VARCHAR2,
      pdocumentos      IN       VARCHAR2,
      pmimestypes      IN       VARCHAR2,
      pdestinatarios   IN       VARCHAR2,
      psproduc         IN       VARCHAR2,
      psseguro         IN       NUMBER,
      mensajes         OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vnumerr       NUMBER (8)          := 0;
      vpasexec      NUMBER (8)          := 0;
      vobject       VARCHAR2 (50)
                                := 'PAC_AXIS_IMPRESION.f_imprimir_via_correo';
      vparam        VARCHAR2 (500)
         :=    ' pmodo: '
            || pmodo
            || ' ptevento: '
            || ptevento
            || ' pcidioma: '
            || pcidioma
            || ' pdirectorio: '
            || pdirectorio
            || ' pdocumentos: '
            || pdocumentos
            || ' pmimestypes: '
            || pmimestypes
            || ' pdestinatarios: '
            || pdestinatarios
            || ' psproduc: '
            || psproduc;
      conn          UTL_SMTP.connection;
      vt_obj        t_iax_impresion     := t_iax_impresion ();
      vesfinal      BOOLEAN;
      vcempres      NUMBER;
      vcidioma      NUMBER;
      vdirectorio   VARCHAR2 (5000);
   BEGIN
      vpasexec := 1;
      vcempres := pac_md_common.f_get_cxtempresa ();
      vpasexec := 2;

      IF pcidioma IS NULL
      THEN
         vcidioma := pac_md_common.f_get_cxtidioma ();
      ELSE
         vcidioma := pcidioma;
      END IF;

      IF pdirectorio IS NULL
      THEN
         vdirectorio := 'GEDOXTEMPORAL';
      ELSE
         vdirectorio := pdirectorio;
      END IF;

      vpasexec := 3;
      vnumerr :=
         pac_md_impresion.f_imprimir_via_correo (vcempres,
                                                 pmodo,
                                                 ptevento,
                                                 vcidioma,
                                                 vdirectorio,
                                                 pdocumentos,
                                                 pmimestypes,
                                                 pdestinatarios,
                                                 psproduc,
                                                 psseguro,
                                                 mensajes
                                                );

      IF vnumerr <> 0
      THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
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
         RETURN 1;
   END f_imprimir_via_correo;

   FUNCTION f_imprimir_renovcero (
      p_sseguro   IN       NUMBER,
      mensajes    OUT      t_iax_mensajes
   )
      RETURN t_iax_impresion
   IS
      vnumerr    NUMBER (8)      := 0;
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (500)  := ' p_sseguro: ' || p_sseguro;
      vobject    VARCHAR2 (200)  := 'PAC_IAX_IMPRESION.f_imprimir_renovcero';
      vt_obj     t_iax_impresion;
   BEGIN
      vpasexec := 2;
      vt_obj := pac_md_impresion.f_imprimir_renovcero (p_sseguro, mensajes);
      pac_iax_impresion.pimpresion := vt_obj;

      IF vt_obj IS NOT NULL AND vt_obj.COUNT > 0
      THEN
         FOR i IN vt_obj.FIRST .. vt_obj.LAST
         LOOP
            vnumerr :=
               pac_md_log.f_log_actividad ('axisimprimir',
                                           1,
                                           NULL,
                                           vt_obj,
                                           i - 1,
                                           vt_obj (i).fichero,
                                           mensajes
                                          );
         END LOOP;
      END IF;

      COMMIT;
      RETURN vt_obj;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         ROLLBACK;
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         ROLLBACK;
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
         ROLLBACK;
         RETURN NULL;
   END f_imprimir_renovcero;

   FUNCTION f_imprimir_sproces_ccompani (
      p_sproces    IN       NUMBER,
      p_ccompani   IN       NUMBER,
      p_tipo       IN       VARCHAR2,
      mensajes     OUT      t_iax_mensajes
   )
      RETURN t_iax_impresion
   IS
      vnumerr    NUMBER (8)      := 0;
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (500)
         :=    'p_sproces: '
            || p_sproces
            || ' p_ccompani: '
            || p_ccompani
            || ' p_tipo: '
            || p_tipo;
      vobject    VARCHAR2 (200)
                            := 'PAC_IAX_IMPRESION.f_imprimir_sproces_ccompani';
      vt_obj     t_iax_impresion;
   BEGIN
      vpasexec := 2;
      vt_obj :=
         pac_md_impresion.f_imprimir_sproces_ccompani (p_sproces,
                                                       p_ccompani,
                                                       p_tipo,
                                                       mensajes
                                                      );
      pac_iax_impresion.pimpresion := vt_obj;

      IF vt_obj IS NOT NULL AND vt_obj.COUNT > 0
      THEN
         FOR i IN vt_obj.FIRST .. vt_obj.LAST
         LOOP
            vnumerr :=
               pac_md_log.f_log_actividad ('axisimprimir',
                                           1,
                                           NULL,
                                           vt_obj,
                                           i - 1,
                                           vt_obj (i).fichero,
                                           mensajes
                                          );
         END LOOP;
      END IF;

      COMMIT;
      RETURN vt_obj;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         ROLLBACK;
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         ROLLBACK;
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
         ROLLBACK;
         RETURN NULL;
   END f_imprimir_sproces_ccompani;

   FUNCTION f_imprimir_cashdesk (
      p_refdeposito   IN       NUMBER,
      p_tipo          IN       VARCHAR,
      mensajes        OUT      t_iax_mensajes
   )
      RETURN t_iax_impresion
   IS
      vnumerr    NUMBER (8)      := 0;
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (500)
               := 'p_refdeposito: ' || p_refdeposito || ' p_tipo: ' || p_tipo;
      vobject    VARCHAR2 (200)
                           := 'PAC_IAX_IMPRESION.f_imprimir_sproces_ccompani';
      vt_obj     t_iax_impresion;
   BEGIN
      vpasexec := 2;
      vt_obj :=
         pac_md_impresion.f_imprimir_cashdesk (p_refdeposito,
                                               p_tipo,
                                               mensajes
                                              );
      pac_iax_impresion.pimpresion := vt_obj;

      IF vt_obj IS NOT NULL AND vt_obj.COUNT > 0
      THEN
         FOR i IN vt_obj.FIRST .. vt_obj.LAST
         LOOP
            vnumerr :=
               pac_md_log.f_log_actividad ('axisimprimir',
                                           1,
                                           NULL,
                                           vt_obj,
                                           i - 1,
                                           vt_obj (i).fichero,
                                           mensajes
                                          );
         END LOOP;
      END IF;

      COMMIT;
      RETURN vt_obj;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         ROLLBACK;
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         ROLLBACK;
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
         ROLLBACK;
         RETURN NULL;
   END f_imprimir_cashdesk;

   /*************************************************************************
      f_imprimir_sinies_soldoc
      pctipo IN NUMBER
      psseguro IN NUMBER
      pnsinies IN VARCHAR2
      pntramit IN NUMBER
      psidepag IN NUMBER
      mensajes OUT T_IAX_MENSAJES
   *************************************************************************/
   FUNCTION f_imprimir_sinies_soldoc(
      pctipo IN NUMBER,
      psseguro IN NUMBER,
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      psidepag IN NUMBER,
      mensajes OUT T_IAX_MENSAJES)
      RETURN t_iax_impresion IS
      vnumerr    NUMBER (8)      := 0;
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (1000)
         :=    'pctipo: '
            || pctipo
            || ' psseguro: '
            || psseguro
            || ' pnsinies: '
            || pnsinies
            || ' pntramit: '
            || pntramit
            || ' psidepag: '
            || psidepag;
      vobject    VARCHAR2 (200)  := 'PAC_IAX_IMPRESION.f_imprimir_sinies_soldoc';
      vt_obj     t_iax_impresion;
      vsseguro   NUMBER;
   BEGIN
      --ComprovaciÂ¿Â¿ de parÂ¿Â¿metres

           --ComprovaciÂ¿Â¿ de parÂ¿Â¿metres
      IF psseguro IS NULL THEN
        SELECT SSEGURO INTO vsseguro FROM SIN_SINIESTRO
             WHERE NSINIES = pnsinies;
      END IF;

      IF pctipo IS NULL
         OR nvl(psseguro, vsseguro) IS NULL
         OR pnsinies IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vt_obj := pac_md_impresion.f_imprimir_sinies_soldoc(pctipo,
                                                          nvl(psseguro, vsseguro),
                                                          pnsinies,
                                                          pntramit,
                                                          psidepag,
                                                          mensajes);
      pac_iax_impresion.pimpresion := vt_obj;

      IF vt_obj IS NULL OR vt_obj.COUNT = 0
      THEN
         IF mensajes IS NULL
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 2, 500031);
            ROLLBACK;
            RETURN NULL;
         ELSE
            RAISE e_object_error;
         END IF;
      ELSE
         FOR i IN vt_obj.FIRST .. vt_obj.LAST
         LOOP
            vnumerr :=
               pac_md_log.f_log_actividad ('axisimprimir',
                                           1,
                                           NULL,
                                           vt_obj,
                                           i - 1,
                                           vt_obj (i).fichero,
                                           mensajes
                                          );
         END LOOP;
      END IF;

      COMMIT;
      RETURN vt_obj;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         ROLLBACK;
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         ROLLBACK;
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
         ROLLBACK;
         RETURN NULL;
   END f_imprimir_sinies_soldoc;

   /*************************************************************************
      --CONF578- JTS - 31/01/2017
      ImpresiÂ¿Â¿n personas
      param in PSPERSON  : ID. persona
      param in P_TIPO      : ctipo de documento
      param out mensajes   : mensajes de error
      return               : objeto rutas ficheros
   *************************************************************************/
   FUNCTION f_imprimir_sperson(
      p_sperson IN NUMBER,
      p_tipo      IN       VARCHAR2,
      -- INI - TCS_324B - JLTS - 11/02/2019. Se adiciona la opciÃ³n idioma por parÃ¡metro
      p_cidiomarep    IN       NUMBER DEFAULT NULL, 
      -- FIN - TCS_324B - JLTS - 11/02/2019. 
      mensajes    OUT      t_iax_mensajes
   )
      RETURN t_iax_impresion
   IS
      vnumerr    NUMBER (8)      := 0;
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (500)
                       := 'p_sperson: ' || p_sperson || ' p_tipo: ' || p_tipo;
      vobject    VARCHAR2 (200)  := 'PAC_IAX_IMPRESION.f_imprimir_sperson';
      vt_obj     t_iax_impresion;
   BEGIN
      vpasexec := 2;
      -- INI - TCS_324B - JLTS - 11/02/2019. Se adiciona la opciÃ³n idioma por parÃ¡metro
      vt_obj :=
            pac_md_impresion.f_imprimir_sperson (p_sperson, p_tipo, NVL(p_cidiomarep,pac_iax_common.f_get_cxtidioma()), mensajes);
      -- FIN - TCS_324B - JLTS - 11/02/2019.
      pac_iax_impresion.pimpresion := vt_obj;

      IF vt_obj IS NOT NULL AND vt_obj.COUNT > 0
      THEN
         FOR i IN vt_obj.FIRST .. vt_obj.LAST
         LOOP
            vnumerr :=
               pac_md_log.f_log_actividad ('axisimprimir',
                                           1,
                                           NULL,
                                           vt_obj,
                                           i - 1,
                                           vt_obj (i).fichero,
                                           mensajes
                                          );
         END LOOP;
      END IF;

      COMMIT;
      RETURN vt_obj;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         ROLLBACK;
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         ROLLBACK;
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
         ROLLBACK;
         RETURN NULL;
   END f_imprimir_sperson;

     /*************************************************************************
      --TCS_19 - ACL - 08/03/2019
      ImpresiÃ³n pagare contragarantia
      param in pscontgar  : ID. contragarantia
      param in P_TIPO      : ctipo de documento
      param out mensajes   : mensajes de error
      return               : objeto rutas ficheros
   *************************************************************************/
   FUNCTION f_imprimir_scontgar(
      p_scontgar IN NUMBER,
      p_tipo      IN       VARCHAR2,
      mensajes    OUT      t_iax_mensajes
   )
      RETURN t_iax_impresion
   IS
      vnumerr    NUMBER (8)      := 0;
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (500)
                       := 'p_scontgar: ' || p_scontgar || ' p_tipo: ' || p_tipo;
      vobject    VARCHAR2 (200)  := 'PAC_IAX_IMPRESION.f_imprimir_scontgar';
      vt_obj     t_iax_impresion;
   BEGIN
      vpasexec := 2;
      vt_obj :=
            pac_md_impresion.f_imprimir_scontgar (p_scontgar, p_tipo, mensajes);
      pac_iax_impresion.pimpresion := vt_obj;

      IF vt_obj IS NOT NULL AND vt_obj.COUNT > 0
      THEN
         FOR i IN vt_obj.FIRST .. vt_obj.LAST
         LOOP
            vnumerr :=
               pac_md_log.f_log_actividad ('axisimprimir',
                                           1,
                                           NULL,
                                           vt_obj,
                                           i - 1,
                                           vt_obj (i).fichero,
                                           mensajes
                                          );
         END LOOP;
      END IF;

      COMMIT;
      RETURN vt_obj;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         ROLLBACK;
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         ROLLBACK;
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
         ROLLBACK;
         RETURN NULL;
   END f_imprimir_scontgar;
END pac_iax_impresion;
/