--------------------------------------------------------
--  DDL for Package Body PAC_IAX_INFORMES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_INFORMES" 
AS
/******************************************************************************
   NOMBRE:      PAC_IAX_INFORMES


   REVISIONES:
   Ver        Fecha        Autor             Descripci¿n
   ---------  ----------  ---------------  ------------------------------------
   1.0        11/12/2008   XPL               1. Creaci¿n del package.
   2.0        17/02/2010   JMF               2. 0013247 Registro de Asegurados de Fallecimiento link de output de datos
   3.0        22/07/2010   SRA               3. 0015489: CEM - LListat de traspassos
   4.0        29/11/2010   JMF               4. 0016529 CRT003 - An¿lisis listados

******************************************************************************/
   e_object_error   EXCEPTION;
   e_param_error    EXCEPTION;

   /******************************************************************************************
     Descripci¿: Funci¿ que genera els registres de cobertura de mort
      Par¿metres entrada: - PINICOBERTURA -> data inicial
                          - PFINCOBERTURA -> data fitxer
                          - PFICHERO      -> nom fitxer on es grabar¿ la informaci¿
                          - ptipoEnvio    -> Tipo 0-Inicial, 1-Periodico.
      Par¿metres sortida: - PFGENERADO    -> Nombre/patch completo del fichero generado
                          - mensajes      -> Missatges d'error
     return:             retorna 0 si va tot b¿, sino el codi de l'error
   ******************************************************************************************/

   -- Bug 0013247 - 17/02/2010 - JMF: Afegir param pfgenerado
   -- Bug 0014113 - 14/04/2010 - JMF: Afegir param p_tipoEnvio
   FUNCTION f_lanzar_cobfallecimiento(
      pinicobertura   IN       DATE,
      pfincobertura   IN       DATE,
      pfichero        IN       VARCHAR2,
      ptipoenvio      IN       NUMBER DEFAULT 1,
      pfgenerado      OUT      VARCHAR2,
      mensajes        OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vobjectname    VARCHAR2 (500)
                              := 'pac_iax_informes.F_LANZAR_COBFALLECIMIENTO';
      vparam         VARCHAR2 (1000)
         :=    'par¿metros - PINICOBERTURA: '
            || pinicobertura
            || ' - PFINCOBERTURA :'
            || pfincobertura
            || ' - PFICHERO:'
            || pfichero;
      vpasexec       NUMBER (5)      := 1;
      vnumerr        NUMBER (8)      := 0;
      vsqlstmt       VARCHAR2 (2000);
      vcagente       NUMBER;
      vcagenteprod   NUMBER;
   BEGIN
      --Comprovaci¿ de par¿metres d'entrada
      IF pinicobertura IS NULL OR pfincobertura IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vcagente := pac_md_common.f_get_cxtagente ();
      vcagenteprod := pac_md_common.f_get_cxtagenteprod ();
      -- Bug 0013247 - 17/02/2010 - JMF: Afegir param pfgenerado
      vnumerr :=
         pac_md_informes.f_lanzar_cobfallecimiento (pinicobertura,
                                                    pfincobertura,
                                                    pfichero,
                                                    ptipoenvio,
                                                    pfgenerado,
                                                    mensajes
                                                   );
      pac_md_common.p_set_cxtagente (vcagente);
      pac_md_common.p_set_cxtagenteprod (vcagente);

      IF vnumerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN 0;
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
   END f_lanzar_cobfallecimiento;

   -- BUG 15296 - 06/07/2010 - SRA: funci¿n para obtener el listado de traspasos
   FUNCTION f_obtener_traspasos(
      pfdesde    IN       DATE,
      pfhasta    IN       DATE,
      pcempres   IN       NUMBER,
      pfichero   OUT      VARCHAR2,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      v_nresult     NUMBER                   := 0;
      v_tmensaje    VARCHAR2 (500);
      v_cidioma     NUMBER;
      vobjectname   tab_error.tobjeto%TYPE
                                    := 'pac_iax_informes.f_obtener_traspasos';
      vpasexec      tab_error.ntraza%TYPE    := 0;
      vparam        VARCHAR2 (1000)
         :=    'pfdesde: '
            || TO_CHAR (pfdesde, 'DD/MM/YYYY')
            || ', pfhasta: '
            || TO_CHAR (pfhasta, 'DD/MM/YYYY');
   BEGIN
      vpasexec := 1;
      v_nresult :=
         pac_md_informes.f_obtener_traspasos (pfdesde,
                                              pfhasta,
                                              pcempres,
                                              pfichero,
                                              mensajes
                                             );

      IF NVL (v_nresult, 1) != 0
      THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 2;
      RETURN v_nresult;
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
         pfichero := NULL;
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
         pfichero := NULL;
         RETURN 1;
   END f_obtener_traspasos;

   /******************************************************************************************
     Descripci¿: Funci¿ que genera els informes de la pantalla de llistats 001
     Par¿metres entrada: - p_cinforme    -> codigo informe (detvalor 1021)
                         - p_cidioma     -> codigo idioma
                         - p_cempres     -> codigo empresa
                         - p_finiefe     -> fecha inicio
                         - p_ffinefe     -> fecha final
                         - p_ctipage     -> Tipo (detvalor 1022) (tipo agente)
                         - p_cagente     -> codigo en funcion del tipo (zona, oficina, agente)
                         - p_sperson     -> codigo cliente
                         - p_cnegocio    -> Negocio (detvalor 1023)
                         - p_codigosn    -> Codigos (separados por comas)
                         - p_sproduc     -> Producto de la actividad
     Par¿metres sortida: - p_fgenerado   -> Nombre/patch completo del fichero generado
                         - mensajes      -> Missatges d'error
     return:             retorna 0 si va tot b¿, sino el codi de l'error
   ******************************************************************************************/

   -- Bug 0016529 - 29/11/2010 - JMF
   FUNCTION f_lanzar_list001(
      p_cinforme    IN       NUMBER,
      p_cidioma     IN       NUMBER DEFAULT NULL,
      p_cempres     IN       NUMBER DEFAULT NULL,
      p_finiefe     IN       DATE DEFAULT NULL,
      p_ffinefe     IN       DATE DEFAULT NULL,
--
      p_ctipage     IN       NUMBER DEFAULT NULL,
      p_cagente     IN       NUMBER DEFAULT NULL,
      p_sperson     IN       NUMBER DEFAULT NULL,
--
      p_cnegocio    IN       NUMBER DEFAULT NULL,
      p_codigosn    IN       VARCHAR2 DEFAULT NULL,
      p_sproduc     IN       VARCHAR2 DEFAULT NULL,
      p_fgenerado   OUT      VARCHAR2,
      mensajes      OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      v_nresult     NUMBER                   := 0;
      v_tmensaje    VARCHAR2 (500);
      v_cidioma     NUMBER;
      vobjectname   tab_error.tobjeto%TYPE
                                       := 'pac_iax_informes.f_lanzar_list001';
      vpasexec      tab_error.ntraza%TYPE    := 0;
      vparam        VARCHAR2 (1000)          := 'i=' || p_cinforme;
   BEGIN
      vpasexec := 1;
      v_nresult :=
         pac_md_informes.f_lanzar_list001 (p_cinforme,
                                           p_cidioma,
                                           p_cempres,
                                           p_finiefe,
                                           p_ffinefe,
                                           p_ctipage,
                                           p_cagente,
                                           p_sperson,
                                           p_cnegocio,
                                           p_codigosn,
                                           p_sproduc,
                                           p_fgenerado,
                                           mensajes
                                          );

      IF NVL (v_nresult, 1) != 0
      THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 2;
      RETURN v_nresult;
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
         p_fgenerado := NULL;
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
         p_fgenerado := NULL;
         RETURN 1;
   END f_lanzar_list001;

   /***********************************************************************
        Recupera los documentos de un seguro
        param in psseguro  : c¿digo de seguro
        param out mensajes : mensajes de error
        return             : ref cursor
     ***********************************************************************/
   FUNCTION f_get_documentacion(
      psseguro   IN       NUMBER,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      vobjectname   VARCHAR2 (500) := 'PAC_IAX_INFORMES.F_Get_documentacion';
      vparam        VARCHAR2 (500) := 'par¿metros - psseguro: ' || psseguro;
      vpasexec      NUMBER (5)     := 1;
      vnumerr       NUMBER (8)     := 0;
      vusuario      VARCHAR2 (20);
      vcempres      NUMBER (2);
      vcursor       sys_refcursor;
      vsinterf      NUMBER;
   BEGIN
      --Comprovaci¿ dels par¿metres d'entrada
      IF psseguro IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      --Recuperamos el usuario
      vusuario := pac_md_common.f_get_cxtusuario ();
      vcempres := pac_md_common.f_get_cxtempresa ();

      IF NVL (pac_parametros.f_parempresa_t (vcempres, 'GESTORDOCUM'), 'X') =
                                                                       'GEDOX'
      THEN
         vcursor :=
            pac_md_informes.f_get_documentacion (psseguro,
                                                 vusuario,
                                                 vcempres,
                                                 mensajes
                                                );
      ELSIF NVL (pac_parametros.f_parempresa_t (vcempres, 'GESTORDOCUM'), 'X') =
                                                                          'WS'
      THEN
         vcursor :=
            pac_md_con.f_get_listado_doc (NULL,
                                          psseguro,
                                          NULL,
                                          vsinterf,
                                          mensajes
                                         );
      END IF;

      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobjectname,
                                            1000005,
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
         IF vcursor%ISOPEN
         THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobjectname,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            NULL,
                                            SQLCODE,
                                            SQLERRM
                                           );
         RETURN vcursor;
   END f_get_documentacion;

   /******************************************************************************************
      Descripci¿n: Recupera la lista de informes que se pueden lanzar des de una pantalla
      Param in pcempres :    c¿digo de empresa
      Param in pcform :      c¿digo de pantalla
      Param in ptevento :    c¿digo de evento
      Param in psproduc :    c¿digo de producto
      Param out pcurconfigsinf : lista de listados
      Param out mensajes       : Mensajes de error
      Retorno 0 -> Ok
              1 -> Ko

      Bug 15743 - 14/10/2010 - XPL/AMC
    ******************************************************************************************/
   FUNCTION f_get_informes(
      pcempres         IN       NUMBER,
      pcform           IN       VARCHAR2,
      ptevento         IN       VARCHAR2,
      psproduc         IN       NUMBER,
      pstipo           IN       NUMBER DEFAULT NULL,
      pcarea           IN       NUMBER DEFAULT NULL,
      pcurconfigsinf   OUT      sys_refcursor,
      mensajes         OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (2000)
         :=    'pcempres='
            || pcempres
            || ' pcform:'
            || pcform
            || ' ptevento:'
            || ptevento
            || ' psproduc:'
            || psproduc
            || ' pstipo: '
            || pstipo;
      vobject    VARCHAR2 (200)  := 'PAC_iax_informes.f_get_informes';
      num_err    NUMBER;
   BEGIN
      vpasexec := 2;
      num_err :=
         pac_md_informes.f_get_informes (pcempres,
                                         pcform,
                                         ptevento,
                                         psproduc,
                                         pstipo,
                                         pcarea,
                                         pcurconfigsinf,
                                         mensajes
                                        );

      IF num_err <> 0
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
   END f_get_informes;

   FUNCTION f_get_params(
      pcempres   IN       NUMBER,
      pcform     IN       VARCHAR2,
      ptevento   IN       VARCHAR2,
      psproduc   IN       NUMBER,
      pcmap      IN       VARCHAR2,
      oparams    OUT      sys_refcursor,
      ocexport   OUT      sys_refcursor,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (2000)
         :=    'pcempres='
            || pcempres
            || ' pcform:'
            || pcform
            || ' ptevento:'
            || ptevento
            || ' psproduc:'
            || psproduc
            || ' pcmap: '
            || pcmap;
      vobject    VARCHAR2 (200)  := 'PAC_iax_informes.f_get_params';
      num_err    NUMBER;
   BEGIN
      vpasexec := 2;
      num_err :=
         pac_md_informes.f_get_params (pcempres,
                                       pcform,
                                       ptevento,
                                       psproduc,
                                       pcmap,
                                       oparams,
                                       ocexport,
                                       mensajes
                                      );

      IF num_err <> 0
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
   END f_get_params;

   FUNCTION f_get_params_informe(
      pcempres    IN       cfg_lanzar_informes_params.cempres%TYPE,
      pcform      IN       cfg_lanzar_informes_params.cform%TYPE,
      ptevento    IN       cfg_lanzar_informes_params.tevento%TYPE,
      psproduc    IN       cfg_lanzar_informes_params.sproduc%TYPE,
      pcmap       IN       cfg_lanzar_informes_params.cmap%TYPE,
      pccfgform   IN       cfg_lanzar_informes_params.ccfgform%TYPE,
      oparams     OUT      sys_refcursor,
      mensajes    OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (2000)
         :=    'pcempres='
            || pcempres
            || ' pcform:'
            || pcform
            || ' ptevento:'
            || ptevento
            || ' psproduc:'
            || psproduc
            || ' pcmap: '
            || pcmap
            || ' pccfgform = '
            || pccfgform;
      vobject    VARCHAR2 (200)  := 'PAC_iax_informes.f_get_params_informe';
      num_err    NUMBER;
   BEGIN
      vpasexec := 2;
      num_err :=
         pac_md_informes.f_get_params_informe (pcempres,
                                               pcform,
                                               ptevento,
                                               psproduc,
                                               pcmap,
                                               pccfgform,
                                               oparams,
                                               mensajes
                                              );

      IF num_err <> 0
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
   END f_get_params_informe;

   FUNCTION f_get_parlist(
      pcempres   IN       NUMBER,
      pcform     IN       VARCHAR2,
      ptevento   IN       VARCHAR2,
      psproduc   IN       NUMBER,
      pcmap      IN       VARCHAR2,
      pcparam    IN       VARCHAR2,
      olist      OUT      sys_refcursor,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (2000)
         :=    'pcempres='
            || pcempres
            || ' pcform:'
            || pcform
            || ' ptevento:'
            || ptevento
            || ' psproduc:'
            || psproduc
            || ' pcmap: '
            || pcmap
            || ' pcparam:'
            || pcparam;
      vobject    VARCHAR2 (200)  := 'PAC_iax_informes.f_get_parlist';
      num_err    NUMBER;
   BEGIN
      vpasexec := 2;
      num_err :=
         pac_md_informes.f_get_parlist (pcempres,
                                        pcform,
                                        ptevento,
                                        psproduc,
                                        pcmap,
                                        pcparam,
                                        olist,
                                        mensajes
                                       );
      vpasexec := 3;

      IF num_err <> 0
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
   END f_get_parlist;

   FUNCTION f_get_detlanzarinformes(
      pcempresa        IN       det_lanzar_informes.cempres%TYPE,
      pcmap            IN       det_lanzar_informes.cmap%TYPE,
      pcidioma         IN       det_lanzar_informes.cidioma%TYPE DEFAULT NULL,
      ptdescrip        IN       det_lanzar_informes.tdescrip%TYPE DEFAULT NULL,
      pcinforme        IN       det_lanzar_informes.cinforme%TYPE DEFAULT NULL,
      odetplantillas   OUT      sys_refcursor,
      mensajes         OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (2500)
         :=    'par¿metros - pcempresa : '
            || pcempresa
            || ' pcmap: '
            || pcmap
            || ' - pcidioma: '
            || pcidioma
            || ' - ptdescrip:'
            || ptdescrip
            || ' - pcinforme: '
            || pcinforme;
      vobject    VARCHAR2 (200)  := 'PAC_iax_informes.f_get_detlanzarinformes';
      num_err    NUMBER;
   BEGIN
      vpasexec := 1;
      num_err :=
         pac_md_informes.f_get_detlanzarinformes (pcempresa,
                                                  pcmap,
                                                  pcidioma,
                                                  ptdescrip,
                                                  pcinforme,
                                                  odetplantillas,
                                                  mensajes
                                                 );

      IF num_err <> 0
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
   END f_get_detlanzarinformes;

   FUNCTION f_ejecuta_informe(
      pcmap         IN       VARCHAR2,
      pcempres      IN       NUMBER,
      pcexport      IN       VARCHAR2,
      pparams       IN       t_iax_info,
      pcidioma      IN       det_lanzar_informes.cidioma%TYPE,
      pcbatch       IN       NUMBER DEFAULT '0',
      pemail        IN       VARCHAR2 DEFAULT NULL,
      onomfichero   OUT      VARCHAR2,
      ofichero      OUT      VARCHAR2,
      mensajes      OUT      t_iax_mensajes,
	  pcgenrec      IN       NUMBER DEFAULT 0
   )
      RETURN NUMBER
   IS
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (2000)
         :=    'pcmap='
            || pcmap
            || ' pcempres:'
            || pcempres
            || ' pcexport:'
            || pcexport
            || ' pcbatch:'
            || pcbatch
            || ' pcidioma: '
            || pcidioma
            || ' pemail: '
            || pemail
            || ' pcgenrec: '
            || pcgenrec;
      vobject    VARCHAR2 (200)  := 'PAC_iax_informes.f_ejecuta_informe';
      num_err    NUMBER;
   BEGIN
      vpasexec := 1;
      num_err :=
         pac_md_informes.f_ejecuta_informe (pcmap,
                                            pcempres,
                                            pcexport,
                                            pparams,
                                            pcidioma,
                                            pcbatch,
                                            pemail,
                                            onomfichero,
                                            ofichero,
                                            mensajes,
											pcgenrec
                                           );

      IF num_err <> 0
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
   END;

   /*FUNCTION f_set_codiplantillas(
      pccodplan IN codiplantillas.ccodplan%TYPE,
      pidconsulta IN codiplantillas.idconsulta%TYPE,
      pgedox IN codiplantillas.gedox%TYPE,
      pidcat IN codiplantillas.idcat%TYPE,
      pcgenfich IN codiplantillas.cgenfich%TYPE DEFAULT NULL,
      pcgenpdf IN codiplantillas.cgenpdf%TYPE DEFAULT NULL,
      pcgenrep IN codiplantillas.cgenrep%TYPE DEFAULT NULL,
      pctipodoc IN codiplantillas.ctipodoc%TYPE DEFAULT NULL,
      pcfdigital IN codiplantillas.cfdigital%TYPE DEFAULT NULL,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_INFORMES.f_set_codiplantillas';
      vparam         VARCHAR2(2000)
         := 'parametros pccodplan=' || pccodplan || ' pidconsulta=' || pidconsulta
            || ' pgedox=' || pgedox || ' pidcat=' || pidcat || ' pcgenfich=' || pcgenfich
            || ' pcgenpdf=' || pcgenpdf || ' pcgenrep=' || pcgenrep || ' pctipodoc='
            || pctipodoc || ' pcfdigital=' || pcfdigital;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_informes.f_set_codiplantillas(pccodplan, pidconsulta, pgedox, pidcat,
                                                      pcgenfich, pcgenpdf, pcgenrep,
                                                      pctipodoc, pcfdigital, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_codiplantillas;*/
   FUNCTION f_set_detlanzarinformes(
      pcempres    IN       det_lanzar_informes.cempres%TYPE,
      pcmap       IN       det_lanzar_informes.cmap%TYPE,
      pcidioma    IN       det_lanzar_informes.cidioma%TYPE,
      ptdescrip   IN       det_lanzar_informes.tdescrip%TYPE,
      pcinforme   IN       det_lanzar_informes.cinforme%TYPE,
      mensajes    OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vobjectname   VARCHAR2 (500)
                                := 'PAC_IAX_INFORMES.f_set_detlanzarinformes';
      vparam        VARCHAR2 (2000)
         :=    'parametros pcempres = '
            || pcempres
            || ' pcmap='
            || pcmap
            || ' pcidioma='
            || pcidioma
            || ' ptdescrip='
            || ptdescrip
            || ' ptdescrip='
            || ptdescrip
            || ' pcinforme='
            || pcinforme;
      vpasexec      NUMBER (5)      := 1;
      vnumerr       NUMBER (8)      := 0;
   BEGIN
      vnumerr :=
         pac_md_informes.f_set_detlanzarinformes (pcempres,
                                                  pcmap,
                                                  pcidioma,
                                                  ptdescrip,
                                                  pcinforme,
                                                  mensajes
                                                 );

      IF vnumerr <> 0
      THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobjectname,
                                            1000006,
                                            vpasexec,
                                            vparam,
                                            vnumerr
                                           );
         ROLLBACK;
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
         ROLLBACK;
         RETURN 1;
   END f_set_detlanzarinformes;

   FUNCTION f_set_cfglanzarinformes(
      pcempres        IN       cfg_lanzar_informes.cempres%TYPE,
      pcform          IN       cfg_lanzar_informes.cform%TYPE,
      pcmap           IN       cfg_lanzar_informes.cmap%TYPE,
      ptevento        IN       cfg_lanzar_informes.tevento%TYPE,
      psproduc        IN       cfg_lanzar_informes.sproduc%TYPE,
      pslitera        IN       cfg_lanzar_informes.slitera%TYPE,
      plparams        IN       cfg_lanzar_informes.lparams%TYPE,
      pgenerareport   IN       cfg_lanzar_informes.genera_report%TYPE,
      pccfgform       IN       cfg_lanzar_informes.ccfgform%TYPE,
      plexport        IN       cfg_lanzar_informes.lexport%TYPE,
      pctipo          IN       cfg_lanzar_informes.ctipo%TYPE,
      mensajes        OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vobjectname   VARCHAR2 (500)
                                := 'PAC_IAX_INFORMES.f_set_cfglanzarinformes';
      vparam        VARCHAR2 (2000)
         :=    'parametros pcempres='
            || pcempres
            || 'pcform= '
            || pcform
            || ' pcmap='
            || pcmap
            || ' ptevento='
            || ptevento
            || ' psproduc='
            || psproduc
            || ' pslitera='
            || pslitera
            || ' plparams='
            || plparams
            || ' pgenerareport='
            || pgenerareport
            || ' pccfgform='
            || pccfgform
            || ' plexport='
            || plexport
            || ' pctipo='
            || pctipo;
      vpasexec      NUMBER (5)      := 1;
      vnumerr       NUMBER (8)      := 0;
   BEGIN
      vnumerr :=
         pac_md_informes.f_set_cfglanzarinformes (pcempres,
                                                  pcform,
                                                  pcmap,
                                                  ptevento,
                                                  psproduc,
                                                  pslitera,
                                                  plparams,
                                                  pgenerareport,
                                                  pccfgform,
                                                  plexport,
                                                  pctipo,
                                                  mensajes
                                                 );

      IF vnumerr <> 0
      THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobjectname,
                                            1000006,
                                            vpasexec,
                                            vparam,
                                            vnumerr
                                           );
         ROLLBACK;
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
         ROLLBACK;
         RETURN 1;
   END f_set_cfglanzarinformes;

   FUNCTION f_upd_cfglanzarinformes(
      pcempres    IN       cfg_lanzar_informes.cempres%TYPE,
      pcmap       IN       cfg_lanzar_informes.cmap%TYPE,
      ptevento    IN       cfg_lanzar_informes.tevento%TYPE,
      psproduc    IN       cfg_lanzar_informes.sproduc%TYPE,
      pccfgform   IN       cfg_lanzar_informes.ccfgform%TYPE,
      plexport    IN       cfg_lanzar_informes.lexport%TYPE,
      pslitera    IN       cfg_lanzar_informes.slitera%TYPE,
      mensajes    OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vobjectname   VARCHAR2 (500)
                                := 'PAC_IAX_INFORMES.f_upd_cfglanzarinformes';
      vparam        VARCHAR2 (2000)
         :=    'parametros pcempres='
            || pcempres
            || ' pcmap='
            || pcmap
            || ' ptevento='
            || ptevento
            || ' psproduc='
            || psproduc
            || ' pccfgform='
            || pccfgform
            || ' plexport='
            || plexport
            || ' slitera= '
            || pslitera;
      vpasexec      NUMBER (5)      := 1;
      vnumerr       NUMBER (8)      := 0;
   BEGIN
      vnumerr :=
         pac_md_informes.f_upd_cfglanzarinformes (pcempres,
                                                  pcmap,
                                                  ptevento,
                                                  psproduc,
                                                  pccfgform,
                                                  plexport,
                                                  pslitera,
                                                  mensajes
                                                 );

      IF vnumerr <> 0
      THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobjectname,
                                            1000006,
                                            vpasexec,
                                            vparam,
                                            vnumerr
                                           );
         ROLLBACK;
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
         ROLLBACK;
         RETURN 1;
   END f_upd_cfglanzarinformes;

   FUNCTION f_del_detlanzarinformes(
      pcempres   IN       det_lanzar_informes.cempres%TYPE,
      pcmap      IN       det_lanzar_informes.cmap%TYPE,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vobjectname   VARCHAR2 (500)
                                := 'PAC_IAX_INFORMES.f_del_detlanzarinformes';
      vparam        VARCHAR2 (2000)
                := 'parametros pcempres = ' || pcempres || ' pcmap=' || pcmap;
      vpasexec      NUMBER (5)      := 1;
      vnumerr       NUMBER (8)      := 0;
   BEGIN
      vnumerr :=
          pac_md_informes.f_del_detlanzarinformes (pcempres, pcmap, mensajes);

      IF vnumerr <> 0
      THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobjectname,
                                            1000006,
                                            vpasexec,
                                            vparam,
                                            vnumerr
                                           );
         ROLLBACK;
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
         ROLLBACK;
         RETURN 1;
   END f_del_detlanzarinformes;

   FUNCTION f_ins_cfglanzarinformesparams(
      pcempres    IN       cfg_lanzar_informes_params.cempres%TYPE,
      pcform      IN       cfg_lanzar_informes_params.cform%TYPE,
      pcmap       IN       cfg_lanzar_informes_params.cmap%TYPE,
      ptevento    IN       cfg_lanzar_informes_params.tevento%TYPE,
      psproduc    IN       cfg_lanzar_informes_params.sproduc%TYPE,
      pccfgform   IN       cfg_lanzar_informes_params.ccfgform%TYPE,
      ptparam     IN       cfg_lanzar_informes_params.tparam%TYPE,
      pctipo      IN       cfg_lanzar_informes_params.ctipo%TYPE,
      pnorder     IN       cfg_lanzar_informes_params.norder%TYPE DEFAULT NULL,
      pslitera    IN       cfg_lanzar_informes_params.slitera%TYPE
            DEFAULT NULL,
      pnotnull    IN       cfg_lanzar_informes_params.notnull%TYPE
            DEFAULT NULL,
      PLValor     IN       cfg_lanzar_informes_params.lvalor%TYPE DEFAULT NULL,
      mensajes    OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vobjectname   VARCHAR2 (500)
                          := 'PAC_IAX_INFORMES.f_ins_cfglanzarinformesparams';
      vparam        VARCHAR2 (2000)
         :=    'parametros pcempres='
            || pcempres
            || ' pcform='
            || pcform
            || ' pcmap='
            || pcmap
            || ' ptevento='
            || ptevento
            || ' psproduc='
            || psproduc
            || ' pccfgform='
            || pccfgform
            || ' ptparam='
            || ptparam
            || ' pctipo='
            || pctipo
            || ' pnorder='
            || pnorder
            || ' pslitera='
            || pslitera
            || ' pnotnull='
            || pnotnull
            || ' plvalor  '
            || PLValor;
      vpasexec      NUMBER (5)      := 1;
      vnumerr       NUMBER (8)      := 0;
   BEGIN
      vnumerr :=
         pac_md_informes.f_ins_cfglanzarinformesparams (pcempres,
                                                        pcform,
                                                        pcmap,
                                                        ptevento,
                                                        psproduc,
                                                        pccfgform,
                                                        ptparam,
                                                        pctipo,
                                                        pnorder,
                                                        pslitera,
                                                        pnotnull,
                                                        PLValor,
                                                        mensajes
                                                       );

      IF vnumerr <> 0
      THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobjectname,
                                            1000006,
                                            vpasexec,
                                            vparam,
                                            vnumerr
                                           );
         ROLLBACK;
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
         ROLLBACK;
         RETURN 1;
   END f_ins_cfglanzarinformesparams;

   FUNCTION f_del_cfglanzarinformesparams(
      pcempres    IN       cfg_lanzar_informes_params.cempres%TYPE,
      pcform      IN       cfg_lanzar_informes_params.cform%TYPE,
      pcmap       IN       cfg_lanzar_informes_params.cmap%TYPE,
      ptevento    IN       cfg_lanzar_informes_params.tevento%TYPE,
      psproduc    IN       cfg_lanzar_informes_params.sproduc%TYPE,
      pccfgform   IN       cfg_lanzar_informes_params.ccfgform%TYPE,
      mensajes    OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vobjectname   VARCHAR2 (500)
                          := 'PAC_IAX_INFORMES.f_del_cfglanzarinformesparams';
      vparam        VARCHAR2 (2000)
         :=    'parametros pcempres='
            || pcempres
            || ' pcform='
            || pcform
            || ' pcmap='
            || pcmap
            || ' ptevento='
            || ptevento
            || ' psproduc='
            || psproduc
            || ' pccfgform='
            || pccfgform;
      vpasexec      NUMBER (5)      := 1;
      vnumerr       NUMBER (8)      := 0;
   BEGIN
      vnumerr :=
         pac_md_informes.f_del_cfglanzarinformesparams (pcempres,
                                                        pcform,
                                                        pcmap,
                                                        ptevento,
                                                        psproduc,
                                                        pccfgform,
                                                        mensajes
                                                       );

      IF vnumerr <> 0
      THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobjectname,
                                            1000006,
                                            vpasexec,
                                            vparam,
                                            vnumerr
                                           );
         ROLLBACK;
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
         ROLLBACK;
         RETURN 1;
   END f_del_cfglanzarinformesparams;

   FUNCTION f_get_listainformesreports(
      pcempres   IN       cfg_lanzar_informes.cempres%TYPE,
      pidioma    IN       axis_literales.cidioma%TYPE,
      pcform     IN       cfg_lanzar_informes.cform%TYPE,
      pcmap      IN       cfg_lanzar_informes_params.cmap%TYPE DEFAULT NULL,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      olistinformes   sys_refcursor;
      vpasexec        NUMBER (8)      := 1;
      vparam          VARCHAR2 (2000)
         := 'pcempres=' || pcempres || 'pcform = ' || pcform || ' pcmap:'
            || pcmap;
      vobject         VARCHAR2 (200)
                             := 'PAC_iax_informes.f_get_listaInformesReports';
      num_err         NUMBER;
   BEGIN
      vpasexec := 1;
      olistinformes :=
         pac_md_informes.f_get_listainformesreports (pcempres,
                                                     pidioma,
                                                     pcform,
                                                     pcmap,
                                                     mensajes
                                                    );

      IF num_err <> 0
      THEN
         RAISE e_object_error;
      END IF;

      RETURN olistinformes;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );

         IF olistinformes%ISOPEN
         THEN
            CLOSE olistinformes;
         END IF;

         RETURN olistinformes;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );

         IF olistinformes%ISOPEN
         THEN
            CLOSE olistinformes;
         END IF;

         RETURN olistinformes;
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

         IF olistinformes%ISOPEN
         THEN
            CLOSE olistinformes;
         END IF;

         RETURN olistinformes;
   END;

   FUNCTION f_get_cfginforme(
      pcempres         IN       NUMBER,
      pcform           IN       VARCHAR2,
      ptevento         IN       VARCHAR2,
      psproduc         IN       NUMBER,
      pcmap            IN       VARCHAR2,
      pcurconfigsinf   OUT      sys_refcursor,
      mensajes         OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (2000)
         :=    'pcempres='
            || pcempres
            || ' pcform:'
            || pcform
            || ' ptevento:'
            || ptevento
            || ' psproduc:'
            || psproduc
            || ' pcmap: '
            || pcmap;
      vobject    VARCHAR2 (200)  := 'PAC_iax_informes.f_get_cfgInforme';
      num_err    NUMBER;
   BEGIN
      vpasexec := 2;
      num_err :=
         pac_md_informes.f_get_cfginforme (pcempres,
                                           pcform,
                                           ptevento,
                                           psproduc,
                                           pcmap,
                                           pcurconfigsinf,
                                           mensajes
                                          );

      IF num_err <> 0
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
   END f_get_cfginforme;

   FUNCTION f_upd_inf_batch(
      pcestado    IN       lanzar_informes.cestado%TYPE,
      pterror     IN       lanzar_informes.terror%TYPE,
      ptfichero   IN       lanzar_informes.tfichero%TYPE,
      psinterf    IN       lanzar_informes.sinterf%TYPE,
      mensajes    OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (2000)
         :=    'parametros pcestado='
            || pcestado
            || ' pterror='
            || pterror
            || ' ptfichero='
            || ptfichero
            || ' psinterf='
            || psinterf;
      vobject    VARCHAR2 (200)  := 'PAC_iax_informes.f_upd_inf_batch';
      num_err    NUMBER;
   BEGIN
      vpasexec := 2;
      num_err :=
         pac_md_informes.f_upd_inf_batch (pcestado,
                                          pterror,
                                          ptfichero,
                                          psinterf,
                                          mensajes
                                         );

      IF num_err <> 0
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
   END;

   FUNCTION f_get_listainformes(
      pcempres          IN       lanzar_informes.cempres%TYPE,
      pcmap             IN       lanzar_informes.cmap%TYPE DEFAULT NULL,
      pcestado          IN       lanzar_informes.cestado%TYPE DEFAULT NULL,
      pcuser            IN       lanzar_informes.cuser%TYPE DEFAULT NULL,
      pfini             IN       lanzar_informes.fini%TYPE DEFAULT NULL,
      pffin             IN       lanzar_informes.ffin%TYPE DEFAULT NULL,
      pcbatch           IN       lanzar_informes.cbatch%TYPE DEFAULT NULL,
      pcursoninformes   OUT      sys_refcursor,
      mensajes          OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (2500)
         :=    'par¿metros - pcempres: '
            || pcempres
            || ' - pcmap: '
            || pcmap
            || ' - pcestado:'
            || pcestado
            || ' - pcuser: '
            || pcuser
            || '- pfini: '
            || pfini
            || ' -pffin: '
            || pffin
            || ' -pcbatch: '
            || pcbatch;
      vobject    VARCHAR2 (200)  := 'PAC_iax_informes.f_get_listaInformes';
      num_err    NUMBER;
   BEGIN
      vpasexec := 2;
      num_err :=
         pac_md_informes.f_get_listainformes (pcempres,
                                              pcmap,
                                              pcestado,
                                              pcuser,
                                              pfini,
                                              pffin,
                                              pcbatch,
                                              pcursoninformes,
                                              mensajes
                                             );

      IF num_err <> 0
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
   END f_get_listainformes;

   FUNCTION f_get_idiomasinforme(
      pcempres         IN       cfg_lanzar_informes.cempres%TYPE,
      pcmap            IN       detplantillas.ccodplan%TYPE,
      pcform           IN       cfg_lanzar_informes.cform%TYPE,
      pcursoridiomas   OUT      sys_refcursor,
      mensajes         OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (2500)
         :=    'par¿metros - pcempres: '
            || pcempres
            || ' - pcmap: '
            || pcmap
            || ' - pcform:'
            || pcform;
      vobject    VARCHAR2 (200)  := 'PAC_iax_informes.f_get_idiomasinforme';
      num_err    NUMBER;
   BEGIN
      vpasexec := 2;
      num_err :=
         pac_md_informes.f_get_idiomasinforme (pcempres,
                                               pcmap,
                                               pcform,
                                               pcursoridiomas,
                                               mensajes
                                              );

      IF num_err <> 0
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
   END;
   --function for inserting data informe technico
   --IAXIS 3602 Shubhendu Informe tecnico   
   FUNCTION f_inforeme_technico(
         preclamo       IN     VARCHAR2,
         pdeplazo       IN     VARCHAR2,
         pinterventor   IN     VARCHAR2,
         psupervisor    IN     VARCHAR2,
         pfuentedeinfo  IN     VARCHAR2,
         pfelaboracion  IN     Date,
         mensajes       OUT    t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec   NUMBER (8)      := 1;
      vnumerr number;
      vparam     VARCHAR2 (2500) := 'par¿metros - pcempres: ';
      vobject    VARCHAR2 (200)  := 'PAC_iax_informes.f_inforeme_technico';
      num_err    NUMBER;
   BEGIN
       vnumerr :=
         pac_md_informes.f_inforeme_technico(preclamo,pdeplazo,pinterventor,psupervisor,pfuentedeinfo,pfelaboracion,mensajes
                                                   );
                                                   return 0;
   END;

   FUNCTION f_get_usuarios(
      pcempres          IN       NUMBER,
      pcursorusuarios   OUT      sys_refcursor,
      mensajes          OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (2500) := 'par¿metros - pcempres: ' || pcempres;
      vobject    VARCHAR2 (200)  := 'PAC_iax_informes.f_get_usuarios';
      num_err    NUMBER;
   BEGIN
      vpasexec := 2;
      num_err :=
         pac_md_informes.f_get_usuarios (pcempres, pcursorusuarios, mensajes);

      IF num_err <> 0
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
   END;

   --kaio 04/06/2019 IAXIS-4113

FUNCTION  f_valida_fecha_madurez(
           pnumeropoliza IN NUMBER,
             pcidioma IN NUMBER) 
          RETURN VARCHAR 
          IS
             VPOLIZADATE DATE;
             VCURRENTDATE DATE;
             VDATEDIFF NUMBER;
             CANTIDADPOLIZA NUMBER :=0;
             VMENSAGE NUMBER := 89906316;
             MSG VARCHAR(200);

             CURSOR c_valida
                IS                
                 SELECT DISTINCT
                 SEGU.NPOLIZA AS c_npoliza,
                 SEGU.SSEGURO AS c_segu ,
                 TOMA.SPERSON AS  c_sperson,
                 mv.smovrec as c_mov,
                 mv.cestrec as c_est,
                 min(mv.fmovini) as c_fecha 


                 FROM SEGUROS SEGU
                 JOIN TOMADORES TOMA ON TOMA.SSEGURO = SEGU.SSEGURO
                 JOIN RECIBOS RC ON RC.SSEGURO = SEGU.SSEGURO
                 join movrecibo mv on mv.nrecibo = rc.nrecibo
                 WHERE TOMA.SPERSON IN
                 (SELECT TOM.SPERSON FROM SEGUROS SEG
                 JOIN TOMADORES TOM ON TOM.SSEGURO = SEG.SSEGURO
                 WHERE SEG.NPOLIZA = pnumeropoliza) and mv.smovrec = (select max(mv2.smovrec) from movrecibo mv2 where mv2.nrecibo = mv.nrecibo) and (mv.cestrec = 0) group by SEGU.NPOLIZA, SEGU.SSEGURO, TOMA.SPERSON, SEGU.FEFECTO, mv.smovrec, 
mv.cestrec;                       
                 C_VALIDAROW C_VALIDA%ROWTYPE;
          BEGIN
              OPEN c_valida; 
              LOOP 
              FETCH c_valida into c_validarow; 
              SELECT CURRENT_DATE INTO VCURRENTDATE FROM dual;
              VDATEDIFF := VCURRENTDATE - c_validarow.c_fecha;
             
              IF (VDATEDIFF > 60) THEN
        	   CANTIDADPOLIZA := CANTIDADPOLIZA+1;
               
              END IF;     
              EXIT WHEN c_valida%notfound;
             
              END LOOP; 
          CLOSE c_valida;


        	IF CANTIDADPOLIZA > 0 THEN
            SELECT TLITERA INTO MSG from axis_literales WHERE SLITERA = VMENSAGE AND CIDIOMA = pcidioma;
        	RETURN REPLACE(MSG,'@@', TO_CHAR(CANTIDADPOLIZA)); 
            
            END IF;

            RETURN ''; 
            
          END f_valida_fecha_madurez;   
		--kaio 04/06/2019 IAXIS-4113
		
		--Inicio tarea 4136 Kaio
   FUNCTION F_LISTA_POLIZAS_PENDIENTES(
       pnumerotomador IN NUMBER,
             pnumerointermedirario IN NUMBER,
      pcursor OUT sys_refcursor,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER
   IS

      vpasexec       NUMBER(8) := 1;
      vobject        VARCHAR2(200) := 'PAC_md_informes.F_LISTA_POLIZAS_PENDIENTES';
      num_err        NUMBER;
      vparam         VARCHAR2(2500) := 'par¿metros - pnumerotomador: ' || pnumerotomador || 'par¿metros - pnumerointermedirario: ' || pnumerointermedirario;
   BEGIN
      vpasexec := 2;
      num_err :=
         pac_md_informes.F_LISTA_POLIZAS_PENDIENTES (pnumerotomador, pnumerointermedirario, pcursor,mensajes);

      IF num_err <> 0
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
   END;
   
  --INI IAXIS-4136 JRVG  23/04/2020
   function f_ins_obs_cuentacobro(
     pobservacion IN obs_cuentacobro.observacion%TYPE,
      psseguro IN obs_cuentacobro.sseguro%TYPE,
      pnrecibo IN obs_cuentacobro.nrecibo%TYPE,
      pmarca  IN  obs_cuentacobro.cmarca%TYPE,
      mensajes IN OUT t_iax_mensajes)

      RETURN NUMBER IS
         
      vobservacion   VARCHAR2(200) := pobservacion;
      vsseguro       NUMBER := psseguro;
      vnrecibo        NUMBER := pnrecibo;
       num_err        NUMBER;
      vobject    VARCHAR2(500) := 'PAC_MD_INFORMES.f_ins_obs_cuentacobro';
      vparam         VARCHAR2(2000)
         := 'parametros pobservacion = ' || pobservacion || ' psseguro=' || psseguro || ' pnrecibo='
            || pnrecibo;
      vpasexec       NUMBER(5) := 1;
      OBSCC_ID NUMBER;
      vobsvacia VARCHAR2(200):='';
   BEGIN

    vpasexec := 2;
      num_err :=
         pac_md_informes.f_ins_obs_cuentacobro (pobservacion, psseguro, pnrecibo, pmarca, mensajes);
   -- FIN IAXIS-4136 JRVG  23/04/2020
      IF num_err <> 0
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
    

   END f_ins_obs_cuentacobro;
    
   -- Fin tarea 4136
		
		
		    --Andres b 04/07/2019 IAXIS-2485
            -- 1 ES PERSONA NATURAL 2 ES PERSONA JURIDICA Y 3 ES CONSORCIO 
FUNCTION  f_tipo_reporte_pagare(
           pnsinies IN VARCHAR2)
          RETURN VARCHAR
          IS
             vreturn VARCHAR(200);
             TIPO_PER NUMBER;   
             TIPO_CONSOR NUMBER;
             FOUND_CUR boolean := false;  

              CURSOR c_valida
                 IS
                SELECT SPERSON_REL, CTIPPER_REL FROM PER_PERSONAS_REL WHERE SPERSON=(
				SELECT TOM.SPERSON FROM SIN_SINIESTRO SIN, TOMADORES TOM WHERE TOM.SSEGURO=SIN.SSEGURO
				AND NSINIES=pnsinies);
 BEGIN
 SELECT CTIPPER INTO TIPO_PER from per_personas where sperson = (SELECT TOM.SPERSON FROM SIN_SINIESTRO SIN, TOMADORES TOM WHERE TOM.SSEGURO=SIN.SSEGURO
				AND NSINIES=pnsinies);
                            
    IF TIPO_PER =1 THEN 
            vreturn:='1';
     ELSIF TIPO_PER =2 THEN
     
     SELECT CTIPSOCI INTO TIPO_CONSOR FROM FIN_GENERAL WHERE SPERSON=(SELECT TOM.SPERSON FROM SIN_SINIESTRO SIN, TOMADORES TOM WHERE TOM.SSEGURO=SIN.SSEGURO
				AND NSINIES=pnsinies);
                
         IF TIPO_CONSOR=10 OR TIPO_CONSOR=9 THEN 
         vreturn:='3';
          ELSE
         vreturn:='2';
          END IF;
     END IF;
     RETURN vreturn;
         EXCEPTION
      WHEN OTHERS
        THEN
        vreturn:='2';
        RETURN vreturn;
 END f_tipo_reporte_pagare;
	    --Andres 04/07/2019 IAXIS-2485
		
		
END pac_iax_informes;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_INFORMES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_INFORMES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_INFORMES" TO "PROGRAMADORESCSI";
