--------------------------------------------------------
--  DDL for Package Body PAC_MD_GESTION_PROCESOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_GESTION_PROCESOS" 
AS
/******************************************************************************
   NOMBRE:      pac_md_gestion_procesos
   PROP¿SITO: Funciones para la gesti¿n de la carga de procesos

   REVISIONES:
   Ver        Fecha        Autor             Descripci¿n
   ---------  ----------  ---------------  ------------------------------------
   1.0        10/05/2010   XPL              1. Creaci¿n del package.
   2.0        06/07/2010   PFA              2. 14750: ENSA101 - Reproceso de procesos ya existentes
   3.0        11/10/2010   FAL              3. 0014888: CRT002 - Carga de polizas,recibos y siniestros Allianz
   4.0        26/10/2010   FAL              4. 0016324: CRT002 - Configuracion de las cargas
   5.0        09/11/2010   JBN              5. 0016432: CRT002 - Error en axisint001 - Volumen elevado de registros
   6.0        18/01/2011   ICV              6. 0017155: CRT003 - Informar estado actualizacion compa¿ia
   7.0        26/07/2013   JRH              7  0024736 - 26/07/2013- JRH - 0024736: (POSDE600)-Desarrollo-GAPS Tecnico-Id 25 - Cotizaciones Masivas CP (Carga Fichero)
   8.0        21/12/2015   YDA              8. 0038922: Se crea la funci¿n f_get_tabla_intermedia_text
******************************************************************************/
   e_object_error   EXCEPTION;
   e_param_error    EXCEPTION;

   /*************************************************************************
      funci¿n que graba en la cabecera del control de procesos
       param in psproces  : Num procesos de la carga
       param in ptfichero : Nombre fichero a cargar
       param in pfini     : Fecha inicio carga
       param in pffin     : Fecha fin carga
       param in pcestado  : Estado de la carga
       param in pcproceso : Codigo proceso
       param in pcerror   : Error de la carga (Slitera)
       param in out       : mensajes de error
       return             : 0 todo ha sido correcto
                            1 ha habido un error
   *************************************************************************/
   FUNCTION f_set_carga_ctrl_cabecera(
      psproces    IN       NUMBER,
      ptfichero   IN       VARCHAR2,
      pfini       IN       DATE,
      pffin       IN       DATE,
      pcestado    IN       NUMBER,
      pcproceso   IN       NUMBER,
      pcerror     IN       NUMBER,
      pterror     IN       VARCHAR2,
      pcbloqueo   IN       NUMBER,
      mensajes    IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vobjectname   VARCHAR2 (500)
                       := 'pac_md_gestion_procesos.f_set_carga_ctrl_cabecera';
      vparam        VARCHAR2 (4000)
         :=    'par¿metros - psproces : '
            || psproces
            || ',tfichero : '
            || ptfichero
            || ',fini : '
            || pfini
            || ',ffin : '
            || pffin
            || ',cestado : '
            || pcestado
            || ',cproceso : '
            || pcproceso
            || ',pcerror : '
            || pcerror
            || ',pcbloqueo : '
            || pcbloqueo;
      vpasexec      NUMBER (5)      := 1;
      vnumerr       NUMBER (8)      := 0;
   BEGIN
      IF ptfichero IS NULL OR pfini IS NULL OR pcestado IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vnumerr :=
         pac_gestion_procesos.f_set_carga_ctrl_cabecera (psproces,
                                                         ptfichero,
                                                         pfini,
                                                         pffin,
                                                         pcestado,
                                                         pcproceso,
                                                         pcerror,
                                                         pterror,
                                                         pcbloqueo
                                                        );

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
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_set_carga_ctrl_cabecera;

   /*************************************************************************
      funci¿n que graba en la linea que se esta tratando del fichero a cargar
       param in psproces  : Num procesos de la carga
       param in pnlinea   : Num Linea
       param in pctipo    : Tipo de registro (Poliza, Siniestro, Recibo, Persona)
       param in pidint    : Identificador interno visual
       param in pidext    : Identificador externo
       param in pcestado  : Estado de la linea
       param in pcvalidado: Linea validada
       param in psseguro  : Codigo del seguro en el caso que carguemos un seguro
       param in pnsinies  : Codigo del siniestros en el caso que carguemos un siniestro
       param in pntramit  : Codigo de la tramitaci¿n en el caso que carguemos un siniestro
       param in psperson  : Codigo de la persona en el caso que carguemos una persona
       param in pnrecibo  : Codigo del recibo en el caso que carguemos un recibo
       param out          : mensajes de error
       return             : 0 todo ha sido correcto
                            1 ha habido un error
   *************************************************************************/
   FUNCTION f_set_carga_ctrl_linea(
      psproces     IN       NUMBER,
      pnlinea      IN       NUMBER,
      pctipo       IN       NUMBER,
      pidint       IN       VARCHAR2,
      pidext       IN       VARCHAR2,
      pcestado     IN       NUMBER,
      pcvalidado   IN       NUMBER,
      psseguro     IN       NUMBER,
      -- Bug 14888. FAL. 11/10/2010. A¿adir id. externo (npoliza,nsinies,nrecibo) de la compa¿ia
      pidexterno   IN       VARCHAR2,
      -- Fi Bug 14888
      -- Bug 16324. FAL. 26/10/2010. A¿adir ncarga (relacion con tablas mig)
      pncarga      IN       NUMBER,
      -- Fi Bug 16324
      pnsinies     IN       VARCHAR2,
      pntramit     IN       NUMBER,
      psperson     IN       NUMBER,
      pnrecibo     IN       NUMBER,
      mensajes     IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vobjectname   VARCHAR2 (500)
                          := 'pac_md_gestion_procesos.f_set_carga_ctrl_linea';
      vparam        VARCHAR2 (4000)
         :=    'par¿metros - psproces : '
            || psproces
            || ',pnlinea : '
            || pnlinea
            || ',pctipo : '
            || pctipo
            || ',pidint : '
            || pidint
            || ',pidext : '
            || pidext
            || ',pcestado : '
            || pcestado
            || ',pcvalidado : '
            || pcvalidado
            || ',psseguro : '
            || psseguro
            || ',pnsinies : '
            || pnsinies
            || ',pntramit : '
            || pntramit
            || ',psperson : '
            || psperson
            || ',pnrecibo : '
            || pnrecibo;
      vpasexec      NUMBER (5)      := 1;
      vnumerr       NUMBER (8)      := 0;
   BEGIN
      IF    psproces IS NULL
         OR pctipo IS NULL
         OR pidint IS NULL
         OR pcestado IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vnumerr :=
         pac_gestion_procesos.f_set_carga_ctrl_linea (psproces,
                                                      pnlinea,
                                                      pctipo,
                                                      pidint,
                                                      pidext,
                                                      pcestado,
                                                      pcvalidado,
                                                      psseguro,
                                                      -- Bug 14888. FAL. 11/10/2010. A¿adir id. externo (npoliza,nsinies,nrecibo) de la compa¿ia
                                                      pidexterno,   -- pidext,
                                                      -- Fi Bug 14888
                                                      -- Bug 16324. FAL. 26/10/2010. A¿adir ncarga (relacion con tablas mig)
                                                      pncarga,
                                                      -- Fi Bug 16324
                                                      pnsinies,
                                                      pntramit,
                                                      psperson,
                                                      pnrecibo
                                                     );

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
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_set_carga_ctrl_linea;

   /*************************************************************************
       funci¿n que graba el error de la linea del fichero que se esta cargando
       param in psproces  : Num procesos de la carga
       param in pnlinea   : Num Linea
       param in pnerror   : Num Error
       param in pctipo    : Tipo de error(warning, error, informativo)
       param in pcerror   : Codigo de error
       param in ptmensaje : Mensaje a mostrar
       param out          : mensajes de error
       return             : 0 todo ha sido correcto
                            1 ha habido un error
   *************************************************************************/
   FUNCTION f_set_carga_ctrl_linea_error(
      psproces    IN       NUMBER,
      pnlinea     IN       NUMBER,
      pnerror     IN       NUMBER,
      pctipo      IN       NUMBER,               --warning, error, informativo
      pcerror     IN       NUMBER,
      ptmensaje   IN       VARCHAR2,
      mensajes    IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vobjectname   VARCHAR2 (500)
                    := 'pac_md_gestion_procesos.f_set_carga_ctrl_linea_error';
      vparam        VARCHAR2 (4000)
         :=    'par¿metros - psproces : '
            || psproces
            || ',pnlinea : '
            || pnlinea
            || ',pnerror : '
            || pnerror
            || ',pnerror : '
            || pnerror
            || ',pctipo : '
            || pctipo
            || ',pcerror : '
            || pcerror
            || ',ptmensaje : '
            || ptmensaje;
      vpasexec      NUMBER (5)      := 1;
      vnumerr       NUMBER (8)      := 0;
   BEGIN
      IF    psproces IS NULL
         OR pnlinea IS NULL
         OR pctipo IS NULL
         OR ptmensaje IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vnumerr :=
         pac_gestion_procesos.f_set_carga_ctrl_linea_error (psproces,
                                                            pnlinea,
                                                            pnerror,
                                                            pctipo,
                                                            pcerror,
                                                            ptmensaje
                                                           );

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
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_set_carga_ctrl_linea_error;

   /*************************************************************************
      funci¿n que recupera los registros de la cabecera de carga.
       param in psproces  : Num procesos de la carga
       param in ptfichero : Nombre fichero a cargar
       param in pfini     : Fecha inicio carga
       param in pffin     : Fecha fin carga
       param in pcestado  : Estado de la carga
       param in pcerror   : Error de la carga (Slitera)
       param out          : mensajes de error
       return             : 0 todo ha sido correcto
                            1 ha habido un error
   *************************************************************************/
   FUNCTION f_get_carga_ctrl_cabecera(
      psproces     IN       NUMBER,
      ptfichero    IN       VARCHAR2,
      pfini        IN       DATE,
      pffin        IN       DATE,
      pcestado     IN       NUMBER,
      pcprocesos   IN       NUMBER,                 -- BUG16432:JBN:29/10/2010
      pcrefext     IN       VARCHAR2,               -- BUG17045:LCF:12/01/2011
      pcurcarga    OUT      sys_refcursor,
      mensajes     IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vobjectname   VARCHAR2 (500)
                       := 'pac_md_gestion_procesos.f_get_carga_ctrl_cabecera';
      vparam        VARCHAR2 (4000)
         :=    'par¿metros - psproces : '
            || psproces
            || ',tfichero : '
            || ptfichero
            || ',fini : '
            || pfini
            || ',ffin : '
            || pffin
            || ',cestado : '
            || pcestado
            || ',pcprocesos : '
            || pcprocesos;
      vpasexec      NUMBER (5)      := 1;
      vnumerr       NUMBER (8)      := 0;
      vquery        VARCHAR2 (2000);
   BEGIN
      vnumerr :=
         pac_gestion_procesos.f_get_carga_ctrl_cabecera
                   (psproces,
                    ptfichero,
                    pfini,
                    pffin,
                    pcestado,
                    pcprocesos,
                    pac_md_common.f_get_cxtempresa, -- BUG16432:JBN:29/10/2010
                    pac_md_common.f_get_cxtidioma,
                    pcrefext,
                    vquery
                   );

      IF vnumerr <> 0
      THEN
         RAISE e_object_error;
      END IF;

      pcurcarga := pac_iax_listvalores.f_opencursor (vquery, mensajes);
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
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_get_carga_ctrl_cabecera;

   /*************************************************************************
      funci¿n que recupera los registros de la linea del proceso cargado
       param in psproces  : Num procesos de la carga
       param in pnlinea   : Num Linea
       param in pctipo    : Tipo de carga(Siniestros,polizas, personas, recibos...)
       param in pvalor    : Valor segun tipo de carga(siniestros = nsinies, polizas = sseguro...)
       param in pidint    : Identificador interno
       param in pidext    : Identificador externo
       param in pcestado  : Estado de la linea
       param in pcrevisado : Linea revisada o no
       param out          : mensajes de error
       return             : 0 todo ha sido correcto
                            1 ha habido un error
   *************************************************************************/
   FUNCTION f_get_carga_ctrl_linea(
      psproces         IN       NUMBER,
      pnlinea          IN       NUMBER,
      pctipo           IN       NUMBER,
      pvalor           IN       VARCHAR2,
      pidint           IN       VARCHAR2,
      pidext           IN       VARCHAR2,
      pcestado         IN       NUMBER,
      pcrevisado       IN       NUMBER,
      pcurcargalinea   OUT      sys_refcursor,
      mensajes         IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vobjectname   VARCHAR2 (500)
                          := 'pac_md_gestion_procesos.f_set_carga_ctrl_linea';
      vparam        VARCHAR2 (4000)
         :=    'par¿metros - psproces : '
            || psproces
            || ',pnlinea : '
            || pnlinea
            || ',pctipo : '
            || pctipo
            || ',pvalor : '
            || pvalor
            || ',pidint : '
            || pidint
            || ',pidext : '
            || pidext
            || ',pcestado : '
            || pcestado
            || ',pcrevisado : '
            || pcrevisado;
      vpasexec      NUMBER (5)      := 1;
      vnumerr       NUMBER (8)      := 0;
      vquery        VARCHAR2 (2000);
   BEGIN
      vnumerr :=
         pac_gestion_procesos.f_get_carga_ctrl_linea
                                              (psproces,
                                               pnlinea,
                                               pctipo,
                                               NULL,
                                               NULL,
                                               pvalor,
                                               pidint,
                                               pidext,
                                               pcestado,
                                               pcrevisado,
                                               pac_md_common.f_get_cxtidioma,
                                               vquery
                                              );

      IF vnumerr <> 0
      THEN
         RAISE e_object_error;
      END IF;

      pcurcargalinea := pac_iax_listvalores.f_opencursor (vquery, mensajes);
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
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_get_carga_ctrl_linea;

   /*************************************************************************
       funci¿n que recupera los registros de los errores de la linea del proceso cargado
       param in psproces  : Num procesos de la carga
       param in pnlinea   : Num Linea
       param in pnerror   : Num Error
       param out          : mensajes de error
       return             : 0 todo ha sido correcto
                            1 ha habido un error
   *************************************************************************/
   FUNCTION f_get_carga_ctrl_linea_error(
      psproces              IN       NUMBER,
      pnlinea               IN       NUMBER,
      pnerror               IN       NUMBER,
      pcurcargalinea_errs   OUT      sys_refcursor,
      mensajes              IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vobjectname   VARCHAR2 (500)
                    := 'pac_md_gestion_procesos.f_set_carga_ctrl_linea_error';
      vparam        VARCHAR2 (4000)
         :=    'par¿metros - psproces : '
            || psproces
            || ',pnlinea : '
            || pnlinea
            || ',pnerror : '
            || pnerror;
      vpasexec      NUMBER (5)      := 1;
      vnumerr       NUMBER (8)      := 0;
      vquery        VARCHAR2 (2000);
   BEGIN
      vnumerr :=
         pac_gestion_procesos.f_get_carga_ctrl_linea_error
                                              (psproces,
                                               pnlinea,
                                               pnerror,
                                               pac_md_common.f_get_cxtidioma,
                                               vquery
                                              );

      IF vnumerr <> 0
      THEN
         RAISE e_object_error;
      END IF;

      pcurcargalinea_errs :=
                           pac_iax_listvalores.f_opencursor (vquery, mensajes);
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
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_get_carga_ctrl_linea_error;

--Bug 14750-PFA-06/07/2010
   /*************************************************************************
      funci¿n que recupera los registros de la tabla intermedia correspondiente
       param in psproces  : Num proceso de la carga
       param in pcproceso : Identificador del proceso
       param in pnlinea   : Num Linea
       param out pobtablaproceso   : Informacion de la tabla
       param out          : mensajes de error
       return             : 0 todo ha sido correcto
                            1 ha habido un error
   *************************************************************************/
   FUNCTION f_get_tabla_intermedia(
      psproces          IN       NUMBER,
      pcproceso         IN       NUMBER,
      pnlinea           IN       NUMBER,
      pobtablaproceso   OUT      ob_iax_tabla_procesos,
      mensajes          IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vobjectname     VARCHAR2 (500)
                          := 'pac_md_gestion_procesos.f_get_tabla_intermedia';
      vparam          VARCHAR2 (4000)
         :=    'par¿metros - psproces : '
            || psproces
            || ',pcproceso : '
            || pcproceso
            || ',pnlinea : '
            || pnlinea;
      vpasexec        NUMBER (5)                         := 1;
      vnumerr         NUMBER (8)                         := 0;
      vtablas         VARCHAR2 (2000);
      vquery_info     VARCHAR2 (2000);
      cur             sys_refcursor;
      v_cursor        sys_refcursor;
      vob_iax_info    ob_iax_info;
      -- JLB - I - 26928  RSA - Campos aclaratorios
      v_regclave      cfg_carga_alias.regclave%TYPE;
      v_valorclave    cfg_carga_alias.valorclave%TYPE;
      v_column_name   all_tab_columns.column_name%TYPE;
      v_data_type     all_tab_columns.data_type%TYPE;
      v_talias        cfg_carga_alias_des.talias%TYPE;
      v_bloqedit      int_carga_campo_spl.cedit%TYPE;

      -- JLB - I - 26928  RSA - Campos aclaratorios
      CURSOR get_columns_names (pptabla IN VARCHAR2)
      IS
         SELECT   *
             FROM all_tab_columns
            WHERE table_name = UPPER (pptabla)
         ORDER BY column_id ASC;

      v_aux           VARCHAR2 (32000);
   BEGIN
      vnumerr :=
         pac_gestion_procesos.f_get_tabla_intermedia
                                             (psproces,
                                              pcproceso,
                                              pnlinea,
                                              pac_md_common.f_get_cxtempresa,
                                              vtablas
                                             );

      IF vnumerr <> 0
      THEN
         RAISE e_object_error;
      END IF;

      pobtablaproceso := ob_iax_tabla_procesos ();
      pobtablaproceso.nombre_tabla := vtablas;
      pobtablaproceso.info_tabla := t_iax_info ();
      vob_iax_info := ob_iax_info ();

-- JLB - I - RSA 26928  - Campos aclaratorios

      -- JLB - I - RSA 26928  - Campos aclaratorios
      --Bug.: 15247 - ICV - 16/05/2011
--      FOR i IN get_columns_names(vtablas) LOOP
      --IF UPPER(vtablas) != 'INT_CARGA_LOAD_SPL' THEN
      BEGIN
         vquery_info :=
               '  SELECT distinct a.regclave  regclave from  '
            || vtablas
            || ' p, CFG_CARGA_ALIAS A '
            || ' where p.proceso = '
            || psproces
            || ' and p.nlinea = '
            || pnlinea
            || ' and a.cempres(+) = '
            || pac_md_common.f_get_cxtempresa
            || ' and a.cproceso(+) = '
            || pcproceso;

         EXECUTE IMMEDIATE vquery_info
                      INTO v_regclave;

--
         IF v_regclave <> '*'
         THEN
            vquery_info :=
                  '  SELECT  p.'
               || v_regclave
               || ' from  '
               || vtablas
               || ' p '
               || ' where p.proceso = '
               || psproces
               || ' and p.nlinea = '
               || pnlinea;

--
            EXECUTE IMMEDIATE vquery_info
                         INTO v_valorclave;
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
      END;

      --END IF;

      --HASTA AQUI
      IF UPPER (vtablas) = 'INT_CARGA_LOAD_SPL'
      THEN
         /*vquery_info :=
            ' SELECT t.column_name column_name, t.data_type data_type, t.column_name talias from '
            || ' all_tab_columns t ' || ' where t.table_name = ''' || UPPER(vtablas) || ''''
            || ' and t.column_name not like ' || '''' || '%VCAMPO%' || '''' || ' UNION';*/
         vquery_info :=

               --vquery_info
               --||
               ' SELECT t.column_name column_name, t.data_type data_type, t.column_name||'' ''||s.ccampo talias, s.cedit bloqedit from '
            || vtablas
            || ' p, all_tab_columns t, int_carga_campo_spl s'
            || ' where p.proceso = '
            || psproces
            || ' and s.ctipcam = 2 and p.nlinea = '
            || pnlinea
            || ' and t.table_name = '''
            || UPPER (vtablas)
            || ''''
            || ' and t.column_name like '
            || ''''
            || 'VCAMPO'
            || '''||s.norden'
            || ' and s.cdarchi = p.cdarchi  order by s.norden asc';
         vnumerr := pac_log.f_log_consultas (vquery_info, vobjectname, 1, 4);
      ELSE
         vquery_info :=
               '  SELECT t.column_name column_name, t.data_type data_type, descampos.talias talias, desvisible.cvalue bloqedit from '
            || vtablas
            || ' p, all_tab_columns t,  '
            || '  (select ccampo,  talias from cfg_carga_alias a, cfg_carga_alias_det det, cfg_carga_alias_des des '
            || '  where a.cempres =  '
            || pac_md_common.f_get_cxtempresa
            || ' AND a.cproceso = '
            || pcproceso;

         IF v_regclave <> '*'
         THEN
            vquery_info :=
                  vquery_info
               || '  and a.valorclave(+) = '''
               || v_valorclave
               || '''';
         END IF;

         IF UPPER (vtablas) = 'INT_FACTURAS_AGENTES' THEN --980 KJSC La tabla INT_FACTURAS_AGENTES tiene el campo SPROCES no PROCESO
            vquery_info :=
               vquery_info
            || ' AND a.cregistro= det.cregistro '
            || ' AND a.regclave =  '''
            || v_regclave
            || ''''
            || ' AND des.calias= det.calias '
            || ' AND des.cidioma = '
            || pac_md_common.f_get_cxtidioma
            || ') descampos, '
            || ' (SELECT cc.ccampo, cc.cvalue FROM cfg_cargas_prpty cc WHERE '
            || ' cc.cempres = '
            || pac_md_common.f_get_cxtempresa
            || ' AND cc.cproceso = '
            || pcproceso
            || ' AND cc.cprpty = 1) desvisible '
            || ' WHERE p.sproces = '
            || psproces
            || '  AND p.nlinea = '
            || pnlinea
            || '  AND t.table_name = '''
            || UPPER (vtablas)
            || ''''
            || ' AND descampos.ccampo(+) = t.column_name '
            || ' AND desvisible.ccampo(+) = t.column_name '
            || ' ORDER BY NVL(talias, column_name)';
          ELSE
            vquery_info :=
               vquery_info
            || ' AND a.cregistro= det.cregistro '
            || ' AND a.regclave =  '''
            || v_regclave
            || ''''
            || ' AND des.calias= det.calias '
            || ' AND des.cidioma = '
            || pac_md_common.f_get_cxtidioma
            || ') descampos, '
            || ' (SELECT cc.ccampo, cc.cvalue FROM cfg_cargas_prpty cc WHERE '
            || ' cc.cempres = '
            || pac_md_common.f_get_cxtempresa
            || ' AND cc.cproceso = '
            || pcproceso
            || ' AND cc.cprpty = 1) desvisible '
            || ' WHERE p.proceso = '
            || psproces
            || '  AND p.nlinea = '
            || pnlinea
            || '  AND t.table_name = '''
            || UPPER (vtablas)
            || ''''
            || ' AND descampos.ccampo(+) = t.column_name '
            || ' AND desvisible.ccampo(+) = t.column_name '
            || ' ORDER BY NVL(talias, column_name)';
          END IF;


      END IF;

      v_cursor := pac_md_listvalores.f_opencursor (vquery_info, mensajes);

      LOOP
         FETCH v_cursor
          INTO v_column_name, v_data_type, v_talias, v_bloqedit;

         EXIT WHEN v_cursor%NOTFOUND;

-- JLB - F - RSA_ - Campos aclaratorios
         IF v_data_type = 'XMLTYPE'
         THEN
            vquery_info :=
                  ' SELECT  extract('
               || v_column_name
               || ',''*'').getClobVal() info FROM '
               || vtablas
               || ' where proceso = '
               || psproces
               || ' and nlinea = '
               || pnlinea;

            EXECUTE IMMEDIATE vquery_info
                         INTO v_aux;

            vob_iax_info.valor_columna := v_aux;
            vob_iax_info.nombre_columna := NVL (v_talias, v_column_name);
            vob_iax_info.tipo_columna := v_data_type;
            vob_iax_info.seleccionado := v_bloqedit;
         --Fin Bug.
         ELSE
           IF UPPER (vtablas) = 'INT_FACTURAS_AGENTES' THEN--980 KJSC La tabla INT_FACTURAS_AGENTES tiene el campo SPROCES no PROCESO
            vquery_info :=
                  ' SELECT '
               || v_column_name
               || ' info FROM '
               || vtablas
               || ' where sproces = '
               || psproces
               || ' and nlinea = '
               || pnlinea;
           ELSE
            vquery_info :=
                  ' SELECT '
               || v_column_name
               || ' info FROM '
               || vtablas
               || ' where proceso = '
               || psproces
               || ' and nlinea = '
               || pnlinea;
            END IF;

            cur := pac_md_listvalores.f_opencursor (vquery_info, mensajes);

            LOOP
               FETCH cur
                INTO vob_iax_info.valor_columna;

               EXIT WHEN cur%NOTFOUND;
               vob_iax_info.nombre_columna := NVL (v_talias, v_column_name);
               vob_iax_info.tipo_columna := v_data_type;
               vob_iax_info.seleccionado := v_bloqedit;
               p_tab_error (f_sysdate,
                            f_user,
                            vobjectname,
                            0,
                            vparam,
                               '<'
                            || vob_iax_info.valor_columna
                            || '><'
                            || vob_iax_info.tipo_columna
                            || '><'
                            || vob_iax_info.nombre_columna
                            || '>'
                           );
            END LOOP;

            CLOSE cur;
         END IF;

         pobtablaproceso.info_tabla.EXTEND;
         pobtablaproceso.info_tabla (pobtablaproceso.info_tabla.LAST) :=
                                                                  vob_iax_info;
         vob_iax_info := ob_iax_info ();
      END LOOP;

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
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_get_tabla_intermedia;

   FUNCTION f_get_tabla_intermedia_text(
      psproces    IN       NUMBER,
      pcproceso   IN       NUMBER,
      pnlinea     IN       NUMBER,
      ptexto      OUT      VARCHAR2,
      mensajes    IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vobjectname       VARCHAR2 (500)
                    := 'pac_iax_gestion_procesos.f_get_tabla_intermedia_text';
      vparam            VARCHAR2 (4000)
         :=    'par¿metros - psproces : '
            || psproces
            || ',pcproceso : '
            || pcproceso
            || ',pnlinea : '
            || pnlinea
            || ',pcproceso : '
            || pcproceso;
      vpasexec          NUMBER (5)            := 1;
      vnumerr           NUMBER (8)            := 0;
      vobtablaproceso   ob_iax_tabla_procesos := ob_iax_tabla_procesos ();
      vt_iax_info       t_iax_info            := t_iax_info ();
      vlinea            VARCHAR2 (2000);
   BEGIN
      vnumerr :=
         pac_md_gestion_procesos.f_get_tabla_intermedia (psproces,
                                                         pcproceso,
                                                         pnlinea,
                                                         vobtablaproceso,
                                                         mensajes
                                                        );

      IF vnumerr <> 0
      THEN
         RAISE e_object_error;
      END IF;

      vt_iax_info := vobtablaproceso.info_tabla;
      ptexto := RPAD ('Nombre Columna', 50) || 'Valor Columna' || CHR (10);

      FOR i IN vt_iax_info.FIRST .. vt_iax_info.LAST
      LOOP
         vlinea :=
               RPAD (vt_iax_info (i).nombre_columna, 50)
            || vt_iax_info (i).valor_columna
            || CHR (10);
         ptexto := ptexto || vlinea;
         vlinea := NULL;
      END LOOP;

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
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_get_tabla_intermedia_text;

   /*************************************************************************
      funci¿n que modifica los registros de la tabla intermedia correspondiente
       param in psproces  : Num proceso de la carga
       param in pcproceso : Identificador del proceso
       param in pnlinea   : Num Linea
       param in pcolumna  : Columna a modificar
       param in pvalor    : Valor modificado
       param out          : mensajes de error
       return             : 0 todo ha sido correcto
                            1 ha habido un error
   *************************************************************************/
   FUNCTION f_set_tabla_intermedia(
      psproces    IN       NUMBER,
      pcproceso   IN       NUMBER,
      pnlinea     IN       NUMBER,
      pcolumna    IN       VARCHAR2,
      pvalor      IN       VARCHAR2,
      mensajes    IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vobjectname   VARCHAR2 (500)
                         := 'pac_iax_gestion_procesos.f_set_tabla_intermedia';
      vparam        VARCHAR2 (4000)
         :=    'par¿metros - psproces : '
            || psproces
            || ',pcproceso : '
            || pcproceso
            || ',pnlinea : '
            || pnlinea
            || ',pcolumna : '
            || pcolumna;
      vpasexec      NUMBER (5)       := 1;
      vnumerr       NUMBER (8)       := 0;
      vtablas       VARCHAR2 (32000);
      vquery_info   VARCHAR2 (32000);
      cur           sys_refcursor;

      CURSOR get_columns_names (pptabla IN VARCHAR2, pcolumna IN VARCHAR2)
      IS
         SELECT data_type
           FROM all_tab_columns
          WHERE table_name = UPPER (pptabla) AND column_name = pcolumna;

      v_tipo        VARCHAR2 (400);
      v_columna     VARCHAR2 (100);
      v_campoalias  VARCHAR2 (100);
   BEGIN
      v_columna := pcolumna;
      vnumerr :=
         pac_gestion_procesos.f_get_tabla_intermedia
                                             (psproces,
                                              pcproceso,
                                              pnlinea,
                                              pac_md_common.f_get_cxtempresa,
                                              vtablas
                                             );

      IF vnumerr <> 0
      THEN
         RAISE e_object_error;
      END IF;

      --Bug.: 15247 - ICV - 16/05/2011
      OPEN get_columns_names (vtablas, pcolumna);

      FETCH get_columns_names
       INTO v_tipo;

      CLOSE get_columns_names;

      IF vtablas = 'INT_CARGA_LOAD_SPL'
      THEN
         /*vquery_info :=
            ' SELECT t.column_name column_name, t.data_type data_type, t.column_name talias from '
            || ' all_tab_columns t ' || ' where t.table_name = ''' || UPPER(vtablas) || ''''
            || ' and t.column_name not like ' || '''' || '%VCAMPO%' || '''' || ' UNION';*/
         /*vquery_info :=

            --vquery_info
            --||
            ' SELECT t.column_name column_name from '
            || vtablas || ' p, all_tab_columns t, int_carga_campo_spl s'
            || ' where p.proceso = ' || psproces || ' and s.ctipcam = 2 and p.nlinea = '
            || pnlinea || ' and t.table_name = ''' || UPPER(vtablas) || ''''
            || ' and t.column_name like ' || '''' || 'VCAMPO' || '''||s.norden'
            || ' and s.cdarchi = p.cdarchi and s.column_name = '''|| pcolumna ||'''  order by s.norden asc';

            EXECUTE IMMEDIATE vquery_info
                         INTO v_columna;*/
         v_columna := REGEXP_REPLACE (v_columna, '(\w+).*$', '\1');

         UPDATE int_carga_ctrl_linea
            SET cestado = 3
          WHERE sproces = psproces AND nlinea = pnlinea;
      END IF;

      IF v_tipo = 'XMLTYPE'
      THEN
         vquery_info :=
               'DECLARE
                            v_aux xmltype;
                        BEGIN
                            v_aux := xmltype.createxml('
            || CHR (39)
            || pvalor
            || CHR (39)
            || ');
                            update '
            || vtablas
            || ' set '
            || v_columna
            || ' = v_aux '
            || ' where proceso = '
            || psproces
            || ' and nlinea = '
            || pnlinea
            || ';'
            || '
                        END;';
      ELSE
         BEGIN
            SELECT ccampo
              INTO v_campoalias
              FROM cfg_carga_alias a, cfg_carga_alias_det det, cfg_carga_alias_des des
              WHERE a.cempres = pac_md_common.f_get_cxtempresa()
                AND a.cproceso = pcproceso
                AND a.regclave = a.regclave
                AND a.cregistro = det.cregistro
                AND det.cregistro = a.cregistro
                AND des.calias = det.calias
                AND des.cidioma = pac_md_common.f_get_cxtidioma()
                AND des.talias = v_columna;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_campoalias := NULL;
            WHEN TOO_MANY_ROWS THEN
               v_campoalias := NULL;
            WHEN OTHERS THEN
               v_campoalias := NULL;
         END;
         vquery_info :=
               'UPDATE '
            || vtablas
            || ' SET '
            || NVL(v_campoalias, v_columna)
            || ' = '''
            || pvalor
            || ''' where proceso = '
            || psproces
            || ' and nlinea = '
            || pnlinea;
      END IF;

      --Fin Bug.
      vnumerr := pac_log.f_log_consultas (vquery_info, vobjectname, 1, 4);
                                                               ---rdd 29062015

      EXECUTE IMMEDIATE vquery_info;

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
         -- BUG -21546_108724- 09/02/2012 - JLTS - Cierre de posibles cursores abiertos
         IF get_columns_names%ISOPEN
         THEN
            CLOSE get_columns_names;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobjectname,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_set_tabla_intermedia;

--Fi Bug 14750-PFA-06/07/2010
-- Bug 16432-JBN-09/11/2010
   /*************************************************************************
         funci¿n que modifica el estado de una linea
       param in psproces  : Num proceso de la carga
       param in pcestado :  Nuevo estado a modificar
       param in pnlinea   : Num Linea
       return             : 0 todo ha sido correcto
                            1 ha habido un error
   *************************************************************************/
   FUNCTION f_set_cestado_lineaproceso(
      psproces   IN       NUMBER,
      pnlinea    IN       NUMBER,
      pcestado   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vobjectname   VARCHAR2 (500)
                         := 'pac_gestion_procesos.f_set_cestado_lineaproceso';
      vparam        VARCHAR2 (4000)
         :=    'par¿metros - psproces : '
            || psproces
            || ',pcestado : '
            || pcestado
            || ',pnlinea : '
            || pnlinea;
      vpasexec      NUMBER (5)      := 1;
      vnumerr       NUMBER (8)      := 0;
   BEGIN
      vnumerr :=
         pac_gestion_procesos.f_set_cestado_lineaproceso (psproces,
                                                          pnlinea,
                                                          pcestado
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
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_set_cestado_lineaproceso;

--Fi Bug 16432-JBN-09/11/2010

   --Bug.: 0017155 - 18/01/2011 - ICV
/*************************************************************************
       funci¿n que devuelve un sys_refcursor con el ¿ltimo fichero cargado de la compa¿ia de la p¿liza/siniestro/recibo
       return             : 0 todo ha sido correcto
                            1 ha habido un error
   *************************************************************************/
   FUNCTION f_get_carga_fichero(
      pctipo      IN       NUMBER,
      pccompani   IN       NUMBER,
      psseguro    IN       NUMBER,
      pnsinies    IN       VARCHAR2,
      pnrecibo    IN       NUMBER,
      pcurcarga   OUT      sys_refcursor,
      mensajes    IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vobjectname   VARCHAR2 (500)
                             := 'pac_md_gestion_procesos.f_get_carga_fichero';
      vparam        VARCHAR2 (4000)
         :=    'par¿metros - pctipo : '
            || pctipo
            || ',pccompani : '
            || pccompani
            || ',psseguro : '
            || psseguro
            || ',pnsinies : '
            || pnsinies
            || ',pnrecibo : '
            || pnrecibo;
      vpasexec      NUMBER (5)      := 1;
      vnumerr       NUMBER (8)      := 0;
      vquery        VARCHAR2 (2000);
   BEGIN
      IF     pccompani IS NULL
         AND psseguro IS NULL
         AND pnsinies IS NULL
         AND pnrecibo IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      IF pctipo IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vnumerr :=
         pac_gestion_procesos.f_get_carga_fichero
                                               (pctipo,
                                                pccompani,
                                                psseguro,
                                                pnsinies,
                                                pnrecibo,
                                                pac_md_common.f_get_cxtidioma,
                                                vquery
                                               );

      IF vnumerr <> 0
      THEN
         RAISE e_object_error;
      END IF;

      pcurcarga := pac_iax_listvalores.f_opencursor (vquery, mensajes);
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
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_get_carga_fichero;

--Fi Bug 0017155

   --Bug 24736 - 26/07/2013- JRH - 0024736: (POSDE600)-Desarrollo-GAPS Tecnico-Id 25 - Cotizaciones Masivas CP (Carga Fichero)
/*************************************************************************
       funci¿n que devuelve un sys_refcursor con los ficheros de salida asociados
       return             : 0 todo ha sido correcto
                            1 ha habido un error
   *************************************************************************/
   FUNCTION f_get_ficheros(
      pcempres    IN       NUMBER,
      psproces    IN       NUMBER,
      pcproceso   IN       NUMBER,
      vtimp       OUT      t_iax_impresion,
      mensajes    IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vobjectname   VARCHAR2 (500)
                             := 'pac_md_gestion_procesos.f_get_carga_fichero';
      vparam        VARCHAR2 (4000)
         :=    'par¿metros - psproces : '
            || psproces
            || 'pcproceso:'
            || pcproceso
            || ' pcempres:'
            || pcempres;
      vpasexec      NUMBER (5)       := 1;
      vnumerr       NUMBER (8)       := 0;
      vquery        VARCHAR2 (2000);

      CURSOR c_informes
      IS
         SELECT c.cempres, c.cproces, c.cmap, c.gedox, c.cmodo,
                m.tdesmap nommap
           FROM cfg_informes_cargas c, map_cabecera m
          WHERE c.cempres = pcempres
            AND c.cproces = pcproceso
            AND m.cmapead = c.cmap;

      vejecutarep   NUMBER;
      vresult       VARCHAR2 (4000);
      vpar          VARCHAR2 (4000);
      vobimp        ob_iax_impresion := ob_iax_impresion ();
      v_idfich      VARCHAR2 (4000);
      vsseguro      NUMBER;
      vnpoliza      NUMBER;
   BEGIN
      IF pcempres IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      IF pcproceso IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      IF psproces IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vtimp := t_iax_impresion ();

      FOR reg IN c_informes
      LOOP
         vpar :=
               pac_md_common.f_get_cxtidioma
            || '|'
            || pcempres
            || '|'
            || TO_CHAR (psproces);
         vpasexec := 3;

         IF reg.cmodo IS NOT NULL
         THEN
            IF reg.cmodo = 1
            THEN
               vpasexec := 41;
               vpar := vpar || '|' || 'EST';
            ELSIF reg.cmodo = 2
            THEN
               vpasexec := 42;
               vpar := vpar || '|' || 'EST';
            ELSIF reg.cmodo = 3
            THEN
               vpasexec := 43;
               vpar := vpar || '|' || 'SEG';
            ELSIF reg.cmodo = 4
            THEN
               vpasexec := 44;
               vpar := vpar || '|' || 'SEG';
            END IF;
         END IF;

         vresult :=
                  pac_md_map.f_ejecuta (reg.cmap, vpar, vejecutarep, mensajes);

         IF vresult IS NULL
         THEN
            RAISE e_object_error;
         END IF;

         vtimp.EXTEND;
         vobimp := ob_iax_impresion ();
         vobimp.fichero := vresult;
         vpasexec := 4;
         vtimp (vtimp.LAST) := vobimp;
         v_idfich := reg.nommap;

         IF NVL (reg.gedox, 'N') = 'S' AND reg.cmodo IS NOT NULL
         THEN
            vpasexec := 5;

            IF reg.cmodo = 1
            THEN
               vpasexec := 41;

               SELECT DISTINCT (sseguro)
                          INTO vsseguro
                          FROM int_carga_ctrl_linea
                         WHERE sproces = psproces;
            ELSIF reg.cmodo = 2
            THEN
               vpasexec := 42;

               SELECT DISTINCT (sseguro)
                          INTO vsseguro
                          FROM int_carga_ctrl_linea
                         WHERE sproces = psproces;

               vpasexec := 48;

               SELECT (npoliza)
                 INTO vnpoliza
                 FROM estseguros
                WHERE sseguro = vsseguro;

               vpasexec := 49;

               SELECT (sseguro)
                 INTO vsseguro
                 FROM seguros
                WHERE npoliza = vnpoliza AND ncertif = 0;
            ELSIF reg.cmodo = 3
            THEN
               vpasexec := 43;

               SELECT DISTINCT (sseguro)
                          INTO vsseguro
                          FROM int_carga_ctrl_linea
                         WHERE sproces = psproces;
            ELSIF reg.cmodo = 4
            THEN
               vpasexec := 44;

               SELECT DISTINCT (sseguro)
                          INTO vsseguro
                          FROM int_carga_ctrl_linea
                         WHERE sproces = psproces;

               vpasexec := 45;

               SELECT (npoliza)
                 INTO vnpoliza
                 FROM seguros
                WHERE sseguro = vsseguro;

               vpasexec := 46;

               SELECT (sseguro)
                 INTO vsseguro
                 FROM seguros
                WHERE npoliza = vnpoliza AND ncertif = 0;
            END IF;

            vresult :=
               pac_md_gedox.f_set_docummovseggedox
                                           (vsseguro,
                                            1,
                                            pac_md_common.f_get_cxtusuario (),
                                            reg.nommap,
                                            v_idfich,
                                            reg.nommap,
                                            8,
                                            0,
                                            mensajes,
                                            1  -- Bug 22267 - MDS - 30/05/2012
                                           );
            vpasexec := 5;

            IF vresult <> 0
            THEN
               RAISE e_object_error;
            END IF;
         END IF;
      END LOOP;

      vpasexec := 6;
      --    pfiles := pac_iax_listvalores.f_opencursor(vquery, mensajes);
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
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_get_ficheros;
--Fi Bug 24736 - 26/07/2013- JRH
END pac_md_gestion_procesos;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_GESTION_PROCESOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_GESTION_PROCESOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_GESTION_PROCESOS" TO "PROGRAMADORESCSI";
