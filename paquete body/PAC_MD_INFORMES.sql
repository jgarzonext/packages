--------------------------------------------------------
--  DDL for Package Body PAC_MD_INFORMES
--------------------------------------------------------
CREATE OR REPLACE PACKAGE BODY "PAC_MD_INFORMES" AS
/******************************************************************************
   NOMBRE:      PAC_MD_INFORMES


   REVISIONES:
   Ver        Fecha        Autor             Descripci¿n
   ---------  ----------  ---------------  ------------------------------------
   1.0        11/12/2008   XPL               1. Creaci¿n del package.
   1.1        12/06/2009   JRB               1. Se A¿ade envio de empresa
   2.0        17/02/2010   JMF               2. 0013247 Registro de Asegurados de Fallecimiento link de output de datos
   3.0        29/11/2010   JMF               3. 0016529 CRT003 - An¿lisis listados
   4.0        29/03/2011   APD               4. 0018006: CX703 - Revisi¿ generaci¿ registre cobertures de mort
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

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
      pinicobertura IN DATE,
      pfincobertura IN DATE,
      pfichero IN VARCHAR2,
      ptipoenvio IN NUMBER DEFAULT 1,
      pfgenerado OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_MD_informes.F_LANZAR_COBFALLECIMIENTO';
      vparam         VARCHAR2(1000)
         := 'par¿metros - PINICOBERTURA: ' || pinicobertura || ' - PFINCOBERTURA :'
            || pfincobertura || ' - PFICHERO:' || pfichero || ' - ptipoEnvio:' || ptipoenvio;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vsqlstmt       VARCHAR2(2000);
      vcagentecobfall NUMBER;
      vinicobertura  VARCHAR2(100);
      vfincobertura  VARCHAR2(100);
   BEGIN
      --Comprovaci¿ de par¿metres d'entrada
      vpasexec := 1;

      IF pinicobertura IS NULL
         OR pfichero IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;

      SELECT TO_CHAR(pinicobertura, 'YYYYMMDD')
        INTO vinicobertura
        FROM DUAL;

      vpasexec := 3;

      SELECT TO_CHAR(pfincobertura, 'YYYYMMDD')
        INTO vfincobertura
        FROM DUAL;

      vpasexec := 5;

      -- Bug 0013247 - 17/02/2010 - JMF: Afegir control fmovfin
      SELECT MIN(cagente)
        INTO vcagentecobfall
        FROM redcomercial r1
       WHERE ctipage = 0
         AND fmovfin IS NULL
         AND cempres = pac_md_common.f_get_cxtempresa()
         AND fmovini = (SELECT MIN(r2.fmovini)
                          FROM redcomercial r2
                         WHERE r2.ctipage = 0
                           AND r2.fmovfin IS NULL
                           AND r2.cempres = pac_md_common.f_get_cxtempresa());

      vpasexec := 6;
      pac_md_common.p_set_cxtagente(vcagentecobfall);
      vpasexec := 7;
      pac_md_common.p_set_cxtagenteprod(vcagentecobfall);
      --BUG 8453 - 12/06/2009 - JRB - Se a¿ade env¿o de empresa.
      -- Bug 0013247 - 17/02/2010 - JMF: Afegir param pfgenerado
      vpasexec := 8;
      -- Bug 18006 - APD - 29/03/2011 - se informan los parametros p_tipofichero y p_modoejecucion
      -- de la procedure p_lanza_cobfallecimiento
      p_lanza_cobfallecimiento
                       (vinicobertura, vfincobertura, pfichero, pfgenerado, vnumerr,
                        pac_md_common.f_get_cxtempresa(), ptipoenvio,
                        NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(),
                                                          'TIPOFICHCOBFALL'),
                            1),
                        1);

      -- Fin Bug 18006 - APD - 29/03/2011
      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      vpasexec := 9;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_lanzar_cobfallecimiento;

   FUNCTION f_obtener_traspasos(
      pfdesde IN DATE,
      pfhasta IN DATE,
      pcempres IN NUMBER,
      pfichero OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_nresult      NUMBER := 0;
      v_tmensaje     VARCHAR2(500);
      v_cidioma      NUMBER;
      vobjectname    tab_error.tobjeto%TYPE := 'pac_md_informes.f_obtener_traspasos';
      vpasexec       tab_error.ntraza%TYPE := 0;
      vparam         VARCHAR2(1000)
         := 'pfdesde: ' || TO_CHAR(pfdesde, 'DD/MM/YYYY') || ', pfhasta: '
            || TO_CHAR(pfhasta, 'DD/MM/YYYY');
   BEGIN
      vpasexec := 1;

      IF pfdesde IS NULL
         OR pfhasta IS NULL
         OR pcempres IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      v_nresult := pac_traspasos.f_obtener_traspasos(pfdesde, pfhasta, pcempres, pfichero);
      vpasexec := 3;

      IF NVL(v_nresult, 1) != 0 THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 4;
      v_cidioma := pac_md_common.f_get_cxtidioma;
      vpasexec := 5;
      v_tmensaje := f_axis_literales(105267, v_cidioma) || pfichero;
      vpasexec := 6;
      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, NULL, v_tmensaje);
      vpasexec := 7;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
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
                         - p_cagrpro     -> Agrupaciones producto (separados por comas)
                         - p_cramo       -> Ramos (separados por comas)
                         - p_sproduc     -> Productos (separados por comas)
                         - p_cactivi     -> Actividades (separadas por comas)
                         - p_ccompani    -> Compa¿ias (separadas por comas)
     Par¿metres sortida: - p_fgenerado   -> Nombre/patch completo del fichero generado
                         - mensajes      -> Missatges d'error
     return:             retorna 0 si va tot b¿, sino el codi de l'error
   ******************************************************************************************/

   -- Bug 0016529 - 29/11/2010 - JMF
   FUNCTION f_lanzar_list001(
      p_cinforme IN NUMBER,
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_finiefe IN DATE DEFAULT NULL,
      p_ffinefe IN DATE DEFAULT NULL,
--
      p_ctipage IN NUMBER DEFAULT NULL,
      p_cagente IN NUMBER DEFAULT NULL,
      p_sperson IN NUMBER DEFAULT NULL,
--
      p_cnegocio IN NUMBER DEFAULT NULL,
      p_codigosn IN VARCHAR2 DEFAULT NULL,
      p_sproduc IN VARCHAR2 DEFAULT NULL,
      p_fgenerado OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_INFORMES.F_LANZAR_LIST001';
      vparam         VARCHAR2(1000)
         := 'c=' || p_cinforme || ' i=' || p_cidioma || ' e=' || p_cempres || ' i='
            || p_finiefe || ' f=' || p_ffinefe || ' t=' || p_ctipage || ' c=' || p_cagente
            || ' p=' || p_sperson || ' n=' || p_cnegocio || ' p=' || p_sproduc || ' c='
            || SUBSTR(p_codigosn, 1, 100);
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      v_map          map_cabecera.cmapead%TYPE := '415';
      v_fic          VARCHAR2(200);
      v_smapead      NUMBER;
      v_ini          VARCHAR2(20);
      v_fin          VARCHAR2(20);
      v_emp          NUMBER;
      v_idioma       NUMBER;
      v_tipage       NUMBER;
      v_codage       NUMBER;
      v_cagrpro      VARCHAR2(500);
      v_cramo        VARCHAR2(500);
      v_sproduc      VARCHAR2(500);
      v_cactivi      VARCHAR2(500);
      v_ccompani     VARCHAR2(500);
   BEGIN
      vpasexec := 1;

      IF p_cempres IS NULL THEN
         v_emp := pac_md_common.f_get_cxtempresa();
      ELSE
         v_emp := p_cempres;
      END IF;

      vpasexec := 3;

      IF p_cidioma IS NULL THEN
         SELECT MAX(nvalpar)
           INTO v_idioma
           FROM parinstalacion
          WHERE cparame = 'IDIOMARTF';
      ELSE
         v_idioma := p_cidioma;
      END IF;

      --Comprovaci¿ de par¿metres d'entrada
      vpasexec := 5;

      IF p_cinforme IS NULL THEN
         -- Camp obligatori
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000165,
                                              f_axis_literales(1000165, v_idioma) || ': '
                                              || f_axis_literales(9000569, v_idioma));
         RAISE e_param_error;
      END IF;

      vpasexec := 7;

      IF p_finiefe IS NULL THEN
         -- Camp obligatori
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000165,
                                              f_axis_literales(1000165, v_idioma) || ': '
                                              || f_axis_literales(9000526, v_idioma));
         RAISE e_param_error;
      END IF;

      BEGIN
         SELECT TO_CHAR(p_finiefe, 'YYYYMMDD')
           INTO v_ini
           FROM DUAL;
      EXCEPTION
         WHEN OTHERS THEN
            -- Fecha incorrecta
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000147,
                                                 f_axis_literales(1000147, v_idioma) || ': '
                                                 || f_axis_literales(9000526, v_idioma));
            RAISE e_param_error;
      END;

      vpasexec := 9;

      IF p_ffinefe IS NULL THEN
         -- Camp obligatori
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000165,
                                              f_axis_literales(1000165, v_idioma) || ': '
                                              || f_axis_literales(9000527, v_idioma));
         RAISE e_param_error;
      END IF;

      BEGIN
         SELECT TO_CHAR(p_ffinefe, 'YYYYMMDD')
           INTO v_fin
           FROM DUAL;
      EXCEPTION
         WHEN OTHERS THEN
            -- Fecha incorrecta
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000147,
                                                 f_axis_literales(1000147, v_idioma) || ': '
                                                 || f_axis_literales(9000527, v_idioma));
            RAISE e_param_error;
      END;

      -- Informacion excluyente
      IF p_sperson IS NOT NULL THEN
         vpasexec := 11;
         v_tipage := NULL;
         v_codage := NULL;
      ELSE
         vpasexec := 13;
         v_tipage := p_ctipage;
         v_codage := p_cagente;

         --BUG19533 - JTS - 29/009/2011
         IF v_tipage IS NULL
            AND v_codage IS NULL THEN
            v_codage := pac_md_common.f_get_cxtagente;

            BEGIN
               SELECT ctipage
                 INTO v_tipage
                 FROM agentes
                WHERE cagente = v_codage;
            EXCEPTION
               WHEN OTHERS THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000165,
                                                       f_axis_literales(1000165, v_idioma)
                                                       || ': '
                                                       || f_axis_literales(9901195, v_idioma));
                  RAISE e_param_error;
            END;
         --FiBug 19533
         ELSIF v_tipage IS NOT NULL
               AND v_codage IS NULL THEN
            -- Camp obligatori
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000165,
                                                 f_axis_literales(1000165, v_idioma) || ': '
                                                 || f_axis_literales(9901195, v_idioma));
            RAISE e_param_error;
         END IF;
      END IF;

      vpasexec := 15;

      IF p_cnegocio IS NULL THEN
         -- Camp obligatori
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000165,
                                              f_axis_literales(1000165, v_idioma) || ': '
                                              || f_axis_literales(9901646, v_idioma));
         RAISE e_param_error;
      ELSIF p_cnegocio = 1 THEN
         -- 1.- Total productos
         NULL;
      ELSIF p_cnegocio = 2 THEN
         -- 2.- Agrupaci¿n Productos
         IF p_codigosn IS NULL THEN
            -- Camp obligatori
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000165,
                                                 f_axis_literales(1000165, v_idioma) || ': '
                                                 || f_axis_literales(111204, v_idioma));
            RAISE e_param_error;
         END IF;
      ELSIF p_cnegocio = 3 THEN
         -- 3.- Ramos
         IF p_codigosn IS NULL THEN
            -- Camp obligatori
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000165,
                                                 f_axis_literales(1000165, v_idioma) || ': '
                                                 || f_axis_literales(9002080, v_idioma));
            RAISE e_param_error;
         END IF;
      ELSIF p_cnegocio = 4 THEN
         -- 4.- Productos
         IF p_codigosn IS NULL THEN
            -- Camp obligatori
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000165,
                                                 f_axis_literales(1000165, v_idioma) || ': '
                                                 || f_axis_literales(110916, v_idioma));
            RAISE e_param_error;
         END IF;
      ELSIF p_cnegocio = 5 THEN
         -- 5.- Actividades
         IF p_sproduc IS NULL THEN
            -- Camp obligatori
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000165,
                                                 f_axis_literales(1000165, v_idioma) || ': '
                                                 || f_axis_literales(103477, v_idioma));
            RAISE e_param_error;
         END IF;

         IF p_codigosn IS NULL THEN
            -- Camp obligatori
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000165,
                                                 f_axis_literales(1000165, v_idioma) || ': '
                                                 || f_axis_literales(103477, v_idioma));
            RAISE e_param_error;
         END IF;
      ELSIF p_cnegocio = 6 THEN
         -- 6.- Compa¿¿as
         IF p_codigosn IS NULL THEN
            -- Camp obligatori
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000165,
                                                 f_axis_literales(1000165, v_idioma) || ': '
                                                 || f_axis_literales(9901223, v_idioma));
            RAISE e_param_error;
         END IF;
      END IF;

      vpasexec := 17;
      v_fic := 'list001_' || p_cinforme || '_' || v_ini || '_'
               || TO_CHAR(f_sysdate, 'hh24miss') || '.csv';
      vpasexec := 19;
      pac_map.p_genera_parametros_fichero(v_map,
                                          p_cinforme || '|' || v_idioma || '|' || v_emp || '|'
                                          || v_ini || '|' || v_fin || '|' || v_tipage || '|'
                                          || v_codage || '|' || p_sperson || '|' || p_cnegocio
                                          || '|' || p_codigosn || '|' || p_sproduc,
                                          v_fic, 0);
      vpasexec := 21;
      vnumerr := pac_map.genera_map(v_map, v_smapead);

      IF vnumerr <> 0 THEN
         --108953 Error d'execuci¿
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 108953,
                                              f_axis_literales(108953, v_idioma) || ' ('
                                              || vnumerr || ') '
                                              || f_axis_literales(vnumerr, v_idioma));
         RAISE e_object_error;
      END IF;

      p_fgenerado := f_parinstalacion_t('INFORMES_C') || '\' || v_fic;
      vpasexec := 23;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_lanzar_list001;

   /***********************************************************************
       Recupera los documentos de un seguro
       param in psseguro  : c¿digo de seguro
       param out mensajes : mensajes de error
       return             : ref cursor
    ***********************************************************************/
   FUNCTION f_get_documentacion(
      psseguro IN NUMBER,
      pusuari IN VARCHAR2,
      pcempres IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_INFORMES.f_get_documentacio';
      vparam         VARCHAR2(500)
         := 'par¿metros - psseguro: ' || psseguro || ' - pusuari: ' || pusuari
            || ' - pcempres:' || pcempres;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vccfgdoc       VARCHAR2(50);
      vcursor        sys_refcursor;
      vsquery        VARCHAR2(2000);
   BEGIN
      --Comprovaci¿ dels par¿metres d'entrada
      IF psseguro IS NULL
         OR pusuari IS NULL
         OR pcempres IS NULL THEN
         RAISE e_param_error;
      END IF;

--------------
--Recuperamos el perfil de documentos para ese usuario y empresa
      vnumerr := pac_cfg.f_get_user_cfgdoc(pusuari, pcempres, vccfgdoc);
--------------
      vsquery :=
         ' select mv.cmotmov, mv.tmotmov,pac_axisgedox.f_get_falta(d.iddocgedox) falta, d.iddocgedox iddoc, d.corigen , ff_desvalorfijo(893,'
         || pac_md_common.f_get_cxtidioma || ',d.corigen) torigen, '
         || '  pac_axisgedox.f_get_descdoc(d.iddocgedox) tdescrip, '
         || ' (select c.tipo from cfg_doc c  where c.cempres = ' || pcempres
         || ' and c.ccfgdoc = ''' || vccfgdoc
         || ''' and c.idcat = pac_axisgedox.f_get_Catdoc(d.iddocgedox)) tipo, '
         || ' pac_axisgedox.categoria(pac_axisgedox.f_get_catdoc(d.iddocgedox),'
         || pac_md_common.f_get_cxtidioma || ') tidcat,'
         || '  substr(pac_axisgedox.f_get_filedoc(d.iddocgedox),instr(pac_axisgedox.f_get_filedoc(d.iddocgedox),''\'',-1)+1,length(pac_axisgedox.f_get_filedoc(d.iddocgedox))) fichero,'
         || '  pac_axisgedox.f_get_usuario(d.iddocgedox) cusuari, (select tusunom from  usuarios where cusuari =pac_axisgedox.f_get_usuario(d.iddocgedox)) tusuario '
         || '   from docummovseg d, movseguro m, motmovseg mv  where d.sseguro = m.sseguro and '
         || ' d.nmovimi = m.nmovimi and m.cmotmov = mv.cmotmov and mv.cidioma = '
         || pac_md_common.f_get_cxtidioma || ' and d.sseguro = ' || psseguro
         || '    and pac_axisgedox.f_get_Catdoc(d.iddocgedox) NOT IN (Select idcat '
         || '                                                          from cfg_doc '
         || '                                                          where cempres = '
         || pcempres || ' and ccfgdoc = ' || CHR(39) || vccfgdoc || CHR(39)
         || '                                                            and tipo = 0 ) order by d.iddocgedox desc';
      vpasexec := 3;
      vcursor := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN vcursor;
      WHEN OTHERS THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
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
      pcempres IN NUMBER,
      pcform IN VARCHAR2,
      ptevento IN VARCHAR2,
      psproduc IN NUMBER,
      pstipo IN NUMBER DEFAULT NULL,
      pcarea           IN       NUMBER DEFAULT NULL,
      pcurconfigsinf OUT sys_refcursor,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vobject        VARCHAR2(200) := 'PAC_md_informes.f_get_informes';
      num_err        NUMBER;
      vcempres       NUMBER;
      squery         VARCHAR2(3000);
      vwhere         VARCHAR2(3000);
      vccfgform      VARCHAR2(200);
      vcont          NUMBER;
      vparam         VARCHAR2(2000)
         := 'par¿metros - pcempres: ' || pcempres || ' - pcform: ' || pcform || ' - ptevento:'
            || ptevento || ' - psproduc: ' || psproduc || '- pstipo: ' || pstipo;
      v_ccfgmap      cfg_map.ccfgmap%TYPE;
   BEGIN
      vpasexec := 1;
      vcempres := pcempres;

      IF pcempres IS NULL THEN
         vcempres := pac_md_common.f_get_cxtempresa;
      END IF;

      vwhere := ' where cempres = ' || vcempres || ' and UPPER(cform) = UPPER(''' || pcform
                || ''')';

      IF ptevento IS NOT NULL THEN
         vwhere := vwhere || ' and UPPER(tevento) = UPPER(''' || ptevento || ''')';
      ELSE
         vwhere := vwhere || ' and UPPER(tevento) = ''GENERAL''';
      END IF;

      IF psproduc IS NOT NULL THEN
         vwhere := vwhere || ' and sproduc = ' || psproduc;
      ELSE
         vwhere := vwhere || ' and sproduc = 0 ';
      END IF;

      vccfgform := pac_md_cfg.f_get_user_cfgform(pac_md_common.f_get_cxtusuario, vcempres,
                                                 pcform, mensajes);

      IF vccfgform IS NULL THEN
         RAISE e_object_error;
      END IF;

      SELECT COUNT(1)
        INTO vcont
        FROM cfg_lanzar_informes
       WHERE cempres = vcempres
         AND cform = pcform
         AND ccfgform = vccfgform;

      IF vcont = 0 THEN
         vwhere := vwhere || ' and UPPER(CCFGFORM) = ''GENERAL''';
      ELSE
         vwhere := vwhere || ' and UPPER(CCFGFORM) =UPPER( ''' || vccfgform || ''')';
      END IF;

      IF (pstipo IS NOT NULL) THEN
         vwhere := vwhere || ' and CTIPO  = ' || pstipo;
      ELSE
         vwhere := vwhere || ' and ctipo = 1' || ' and carea = ' ||pcarea;
      END IF;

      -- BUG 21569 - 07/03/2012 - JMP -
      SELECT ccfgmap
        INTO v_ccfgmap
        FROM cfg_user
       WHERE cempres = vcempres
         AND cuser = f_user;

      IF v_ccfgmap IS NOT NULL THEN
         vwhere := vwhere || ' and cmap in (SELECT cmapead FROM cfg_map WHERE cempres = '
                   || vcempres || ' AND UPPER(ccfgmap) = UPPER(''' || v_ccfgmap || '''))';
      END IF;

      -- FIN BUG 21569 - 07/03/2012 - JMP -
      IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa, 'ORDENA_INFORMES'),
             0) = 1 THEN
         squery := 'select C.*, f_axis_literales(slitera,' || pac_md_common.f_get_cxtidioma
                   || ') TLITERA  from CFG_LANZAR_INFORMES C' || vwhere
                   || ' order by f_axis_literales(slitera,' || pac_md_common.f_get_cxtidioma
                   || ')';
      ELSE
         squery := 'select C.*, f_axis_literales(slitera,' || pac_md_common.f_get_cxtidioma
                   || ') TLITERA  from CFG_LANZAR_INFORMES C' || vwhere;
      END IF;

      pcurconfigsinf := pac_md_listvalores.f_opencursor(squery, mensajes);
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_informes;

   FUNCTION f_get_detlanzarinformes(
      pcempresa IN det_lanzar_informes.cempres%TYPE,
      pcmap IN det_lanzar_informes.cmap%TYPE,
      pcidioma IN det_lanzar_informes.cidioma%TYPE DEFAULT NULL,
      ptdescrip IN det_lanzar_informes.tdescrip%TYPE DEFAULT NULL,
      pcinforme IN det_lanzar_informes.cinforme%TYPE DEFAULT NULL,
      odetplantillas OUT sys_refcursor,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vselect        VARCHAR2(2000);
      vpasexec       NUMBER(8) := 1;
      vobject        VARCHAR2(200) := 'PAC_md_informes.f_get_detlanzarinformes';
      num_err        NUMBER;
      vparam         VARCHAR2(2500)
         := 'par¿metros - pcempresa: ' || pcempresa || ' pcmap: ' || pcmap || ' - pcidioma: '
            || pcidioma || ' - ptdescrip:' || ptdescrip || ' - pcinforme: ' || pcinforme;
   BEGIN
      vselect := 'SELECT * FROM det_lanzar_informes WHERE cempres = ' || pcempresa
                 || ' and upper(cmap) =upper(''' || pcmap || ''')';

      IF (pcidioma IS NOT NULL) THEN
         vselect := vselect || ' AND cidioma =' || pcidioma;
      END IF;

      IF (ptdescrip IS NOT NULL) THEN
         vselect := vselect || '  and UPPER(tdescrip)=UPPER(''' || ptdescrip || ''')';
      END IF;

      IF (pcinforme IS NOT NULL) THEN
         vselect := vselect || ' and UPPER(cinforme) =UPPER(''' || pcinforme || ''')';
      END IF;

      odetplantillas := pac_md_listvalores.f_opencursor(vselect, mensajes);
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_detlanzarinformes;

   FUNCTION f_get_params(
      pcempres IN NUMBER,
      pcform IN VARCHAR2,
      ptevento IN VARCHAR2,
      psproduc IN NUMBER,
      pcmap IN VARCHAR2,
      oparams OUT sys_refcursor,
      ocexport OUT sys_refcursor,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vobject        VARCHAR2(200) := 'PAC_md_informes.f_get_params';
      num_err        NUMBER;
      vparam         VARCHAR2(2000)
         := 'par¿metros - pcempres: ' || pcempres || ' - pcform: ' || pcform || ' - ptevento:'
            || ptevento || ' - psproduc: ' || psproduc || '- pcmap: ' || pcmap;
   BEGIN
      oparams :=
         pac_md_listvalores.f_opencursor
            ('SELECT CFG_LANZAR_INFORMES_PARAMS.* ,F_AXIS_LITERALES(SLITERA) TLITERA FROM CFG_LANZAR_INFORMES_PARAMS '
             || ' WHERE cempres = ' || pcempres || ' AND UPPER(cform) = UPPER(''' || pcform
             || ''') and UPPER(tevento)=UPPER(''' || ptevento
             || ''') and UPPER(cmap) =UPPER(''' || pcmap || ''') and sproduc = ' || psproduc
             || ' order by norder asc ',
             mensajes);
      ocexport :=
         pac_md_listvalores.f_opencursor('SELECT LEXPORT FROM CFG_LANZAR_INFORMES '
                                         || ' WHERE cempres = ' || pcempres
                                         || ' AND UPPER(cform) =UPPER(''' || pcform
                                         || ''') and UPPER(tevento)=UPPER(''' || ptevento
                                         || ''') and UPPER(cmap)=UPPER(''' || pcmap
                                         || ''') and sproduc = ' || psproduc,
                                         mensajes);
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_params;

   FUNCTION f_get_params_informe(
      pcempres IN cfg_lanzar_informes_params.cempres%TYPE,
      pcform IN cfg_lanzar_informes_params.cform%TYPE,
      ptevento IN cfg_lanzar_informes_params.tevento%TYPE,
      psproduc IN cfg_lanzar_informes_params.sproduc%TYPE,
      pcmap IN cfg_lanzar_informes_params.cmap%TYPE,
      pccfgform IN cfg_lanzar_informes_params.ccfgform%TYPE,
      oparams OUT sys_refcursor,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vobject        VARCHAR2(200) := 'PAC_md_informes.f_get_params_informe';
      num_err        NUMBER;
      vparam         VARCHAR2(2000)
         := 'par¿metros - pcempres: ' || pcempres || ' - pcform: ' || pcform || ' - ptevento:'
            || ptevento || ' - psproduc: ' || psproduc || '- pcmap: ' || pcmap
            || ' pccfgform=' || pccfgform;
   BEGIN
      oparams :=
         pac_md_listvalores.f_opencursor
            ('SELECT CFG_LANZAR_INFORMES_PARAMS.* ,F_AXIS_LITERALES(cfg_lanzar_informes_params.SLITERA) as TLITERA FROM CFG_LANZAR_INFORMES_PARAMS '
             || ' WHERE cempres = ' || pcempres || ' AND UPPER(cform) = UPPER(''' || pcform
             || ''') and UPPER(tevento)=UPPER(''' || ptevento
             || ''') and UPPER(cmap) =UPPER(''' || pcmap || ''') and sproduc = ' || psproduc
             || ' and upper(ccfgform)=upper(''' || pccfgform || ''') ORDER BY NORDER ASC',
             mensajes);
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_params_informe;

   /*Recull el valor del camp  LVALOR si es SELECT: ALESHORES SENVIA LA SELECT TAL CUAL SI ES LISTA: ALESHORES FALTE VEURE COM SE ENVIE*/
   FUNCTION f_get_parlist(
      pcempres IN NUMBER,
      pcform IN VARCHAR2,
      ptevento IN VARCHAR2,
      psproduc IN NUMBER,
      pcmap IN VARCHAR2,
      pcparam IN VARCHAR2,
      olist OUT sys_refcursor,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vobject        VARCHAR2(200) := 'PAC_md_informes.f_get_parlist';
      squery         VARCHAR2(3000);
      vlvalor        VARCHAR2(4000);
      vselect        VARCHAR2(32000);
      vparam         VARCHAR2(2000)
         := 'par¿metros - pcempres: ' || pcempres || ' - pcform: ' || pcform || ' - ptevento:'
            || ptevento || ' - psproduc: ' || psproduc || '- pcmap: ' || pcmap
            || ' -pcparam: ' || pcparam;
   BEGIN
      vpasexec := 2;

      SELECT lvalor
        INTO vselect
        FROM cfg_lanzar_informes_params
       WHERE cempres = pcempres
         AND UPPER(cform) = UPPER(pcform)
         AND UPPER(tevento) = UPPER(ptevento)
         AND UPPER(cmap) = UPPER(pcmap)
         AND sproduc = psproduc
         AND UPPER(tparam) = UPPER(pcparam);

      vpasexec := 3;

      IF (vselect IS NOT NULL) THEN
         IF (LENGTH(vselect) > 7) THEN
            squery := SUBSTR(vselect, 8);
            vpasexec := 3;
            olist := pac_md_listvalores.f_opencursor(squery, mensajes);
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END;

   FUNCTION f_ejecuta_informe(
      pcmap IN VARCHAR2,
      pcempres IN NUMBER,
      pcexport IN VARCHAR2,
      pparams IN t_iax_info,
      pcidioma IN det_lanzar_informes.cidioma%TYPE,
      pcbatch IN NUMBER DEFAULT '0',
      pemail IN VARCHAR2 DEFAULT NULL,
      onomfichero OUT VARCHAR2,
      ofichero OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes,
      pcgenrec IN NUMBER DEFAULT 0)
      RETURN NUMBER IS
      vparam         VARCHAR2(1000)
         := 'pcmap=' || pcmap || ' pcempres=' || pcempres || ' pcexport=' || pcexport
            || ' pcidioma: ' || pcidioma || ' pcbatch: ' || pcbatch || ' pemail: ' || pemail;
      vpasexec       NUMBER(8) := 1;
      vobject        VARCHAR2(200) := 'PAC_md_informes.f_ejecuta_informe';
      vnombreparam   VARCHAR2(200);
      vtipoparam     VARCHAR2(32000);
      vvalorparam    VARCHAR2(400);
      vdatasource    VARCHAR2(250);
      vsinterf       lanzar_informes.sinterf%TYPE;
      vptfilaname    VARCHAR2(1000);
      vnumerr        NUMBER;
      vperror        int_resultado.terror%TYPE;
      vfichero       detplantillas.cinforme%TYPE;
      vtmsg          VARCHAR2(250);
      vretemail      NUMBER;
      -- bug 0028554 - 13/03/2014 - JMF: parametro opcional pdestcopia
      v_gencarpeta   VARCHAR2(500);
      v_destcopia    VARCHAR2(500);
      -- Inicio IAxis 3648 EA 04/07/2019 Carga masiva ulea
      vtotalulea      NUMBER;
      
      v_cramoulea NUMBER;
      v_valorulea NUMBER;
      v_fechaulea VARCHAR2(200);
      vvalor      number:=0;
      V_NNUMERR   number:=0;
      v_sseguro   number:=0;
      v_icaprie   number:=0;
      cont_insert  number:=0;
      tot_insert  number:=0;
      vireserva   sin_tramita_reserva.ireserva%type;
    vnmovres    sin_tramita_reserva.nmovres%type;
    CURSOR cur_exist (v_cramouleap NUMBER, v_valoruleap NUMBER,v_fechauleap varchar2)
  IS
  SELECT * FROM SIN_TRAMITA_RESERVA_ULEA where femisio=to_date(v_fechauleap,'dd/mm/yyyy') and cramo like decode(v_cramouleap,0,'%',v_cramouleap) and valorulea= v_valoruleap AND ESTADO='INSERTADO'; 
CURSOR cur_insertar (v_cramouleapa NUMBER, v_valoruleapa NUMBER,v_fechauleapa varchar2)
  IS
  SELECT * FROM SIN_TRAMITA_RESERVA_ULEA where femisio=to_date(v_fechauleapa,'dd/mm/yyyy') and cramo like decode(v_cramouleapa,0,'%',v_cramouleapa) and valorulea= v_valoruleapa AND ESTADO='VISUALIZADO';
CURSOR cur (v_cramouleap NUMBER, v_valoruleap NUMBER,v_fechauleap varchar2)
  IS
  
select NSINIES,
CGARANT,
tgarant,
ireserva_moncia,icaprie_moncia,por,
/*FEMISIO,*/
CRAMO,TRAMO/*,
/*CUSUALT,
FALTA*/,cmonres,count(distinct NSINIES) over () totalresgistros
,row_number() over (partition by nsinies order by cramo,nsinies,cgarant desc)+idres as rank
,row_number() over (partition by nsinies order by cramo,nsinies,cgarant desc)+nmovres as nmovres
from(
  select  NSINIES,
str.CGARANT,
tgarant,
ireserva_moncia,icaprie_moncia,por,
/*FEMISIO,*/
seguros.CRAMO,TRAMO/*,
/*CUSUALT,
FALTA*/,cmonres

from sin_movsiniestro
join sin_siniestro using(nsinies)
join seguros using(sseguro)
join (select 'COP' cmonres,nsinies,ctipres, ntramit,cgarant,totalsiniestro,sum(icaprie_moncia) icaprie_moncia,sum(ireserva_moncia) ireserva_moncia,case totalsiniestro  when 0 then 0 else (sum(ireserva_moncia)*1/totalsiniestro) end por from sin_tramita_reserva 
join 
(select nsinies,ntramit,ctipres,sum(ireserva_moncia) totalsiniestro from sin_tramita_reserva where 
(nsinies,ntramit,ctipres,cgarant,nmovres) in 
(SELECT nsinies,ntramit,ctipres,cgarant,max(nmovres) FROM sin_tramita_reserva where ntramit=0 and ctipres<>5 

group by nsinies,ntramit,ctipres,cgarant,idres) group by nsinies,ntramit,ctipres) total using(nsinies,ntramit,ctipres)
where  (nsinies,ntramit,ctipres,cgarant,nmovres) in 
(SELECT nsinies,ntramit,ctipres,cgarant,max(nmovres) FROM sin_tramita_reserva where ntramit=0 and ctipres<>5
group by nsinies,ntramit,ctipres,cgarant,idres)
group by nsinies,ntramit,ctipres,cgarant,totalsiniestro  
) str using(nsinies)
left join ramos ram on ram.cramo=seguros.cramo and ram.cidioma=8
left join garangen on garangen.cgarant=str.cgarant and garangen.cidioma=8
where CTIPSIN=0 and CESTSIN in (0,3,4) and seguros.cramo LIKE '%' and (nsinies,nmovsin) in (select nsinies,max(nmovsin) from sin_movsiniestro group by nsinies)
and ctipres=1 /*and fvencim<=to_date(v_fechauleap, 'dd/mm/yyyy')*/  AND ireserva_moncia>0
union


select  NSINIES,
str.CGARANT,
tgarant,
ireserva_moncia,icaprie_moncia,por,
/*FEMISIO,*/
seguros.CRAMO,TRAMO/*,
/*CUSUALT,
FALTA*/,cmonres from sin_movsiniestro
join sin_siniestro using(nsinies)
join seguros using(sseguro)
join (select 'COP' cmonres,nsinies,ctipres, ntramit,cgarant,totalsiniestro,sum(icaprie_moncia) icaprie_moncia,sum(ireserva_moncia) ireserva_moncia,case totalsiniestro  when 0 then 0 else (sum(ireserva_moncia)*1/totalsiniestro) end por from sin_tramita_reserva 
join 
(select nsinies,ntramit,ctipres,sum(ireserva_moncia) totalsiniestro from sin_tramita_reserva where  
 (nsinies,ntramit,ctipres,cgarant,nmovres) in 
(SELECT nsinies,ntramit,ctipres,cgarant,max(nmovres) FROM sin_tramita_reserva where ntramit=0 and ctipres<>5

group by nsinies,ntramit,ctipres,cgarant,idres) group by nsinies,ntramit,ctipres) total using(nsinies,ntramit,ctipres)
where  (nsinies,ntramit,ctipres,cgarant,nmovres) in 
(SELECT nsinies,ntramit,ctipres,cgarant,max(nmovres) FROM sin_tramita_reserva where ntramit=0 and ctipres<>5
group by nsinies,ntramit,ctipres,cgarant,idres)
group by nsinies,ntramit,ctipres,cgarant,totalsiniestro  
)str using(nsinies)
left join ramos ram on ram.cramo=seguros.cramo and ram.cidioma=8
left join garangen on garangen.cgarant=str.cgarant and garangen.cidioma=8
where CTIPSIN=0 and CESTSIN in (0,3,4) and seguros.cramo LIKE '%' and (nsinies,nmovsin) in (select nsinies,max(nmovsin) from sin_movsiniestro group by nsinies)
/*and fvencim<=to_date(v_fechauleap, 'dd/mm/yyyy')*/  AND ireserva_moncia>0

and nsinies not in
(select  NSINIES from sin_movsiniestro
join sin_siniestro using(nsinies)
join seguros using(sseguro)
join (select 'COP' cmonres,nsinies,ctipres, ntramit,cgarant,totalsiniestro,sum(icaprie_moncia) icaprie_moncia,sum(ireserva_moncia) ireserva_moncia,case totalsiniestro  when 0 then 0 else (sum(ireserva_moncia)*1/totalsiniestro) end por from sin_tramita_reserva 
join 
(select nsinies,ntramit,ctipres,sum(ireserva_moncia) totalsiniestro from sin_tramita_reserva where 
 (nsinies,ntramit,ctipres,cgarant,nmovres) in 
(SELECT nsinies,ntramit,ctipres,cgarant,max(nmovres) FROM sin_tramita_reserva where ntramit=0 and ctipres<>5

group by nsinies,ntramit,ctipres,cgarant,idres) group by nsinies,ntramit,ctipres) total using(nsinies,ntramit,ctipres)
where  (nsinies,ntramit,ctipres,cgarant,nmovres) in 
(SELECT nsinies,ntramit,ctipres,cgarant,max(nmovres) FROM sin_tramita_reserva where ntramit=0 and ctipres<>5
group by nsinies,ntramit,ctipres,cgarant,idres)
group by nsinies,ntramit,ctipres,cgarant,totalsiniestro 
) str using(nsinies)
where CTIPSIN=0 and CESTSIN in (0,3,4) and cramo LIKE '%' and (nsinies,nmovsin) in (select nsinies,max(nmovsin) from sin_movsiniestro group by nsinies)
and ctipres=1 /*and fvencim<=to_date(v_fechauleap, 'dd/mm/yyyy')*/  AND ireserva_moncia>0

)
order by cramo,nsinies,cgarant 
)todo 
join (select nsinies,max(idres) idres,max(nmovres) nmovres from sin_tramita_reserva  group by nsinies) using(nsinies)

WHERE cramo like decode(v_cramouleap,0,'%',v_cramouleap) and (cramo,to_date(v_fechauleap, 'dd/mm/yyyy'),v_valoruleap) not in
(select cramo,femisio,valorulea from sin_tramita_reserva_ulea where estado='INSERTADO')/*AND nsinies = 201780650008*/;
 -- Fin IAxis 3648 EA 04/07/2019 Carga masiva ulea
   BEGIN
      pac_int_online.p_inicializar_sinterf;
      vsinterf := pac_int_online.f_obtener_sinterf;
      vpasexec := 2;
      -- bug 0028554 - 13/03/2014 - JMF: parametro opcional pdestcopia
      v_gencarpeta := NULL;

      IF (vsinterf IS NOT NULL) THEN
         BEGIN
            vpasexec := 3;

            INSERT INTO lanzar_informes
                        (sinterf, cmap, cempres, cexport, cestado, fini, cbatch, cemail,
                         cuser)
                 VALUES (vsinterf, pcmap, pcempres, pcexport, 1, f_sysdate, pcbatch, pemail,
                         f_user);

            COMMIT;
         EXCEPTION
            WHEN OTHERS THEN
               vpasexec := 901;
               ROLLBACK;
               pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                                 psqcode => SQLCODE, psqerrm => SQLERRM);
               RETURN 1;
         END;

         IF (pparams.COUNT) > 0 THEN
            vpasexec := 4;

            FOR vinfo IN pparams.FIRST .. pparams.LAST LOOP
               vpasexec := 5;
               vnombreparam := pparams(vinfo).nombre_columna;
               vvalorparam := pparams(vinfo).valor_columna;
               vtipoparam := pparams(vinfo).tipo_columna;
               vpasexec := 6;

               -- bug 0028554 - 13/03/2014 - JMF: parametro opcional pdestcopia
               IF vnombreparam = 'GENERA_CARPETA' THEN
                  v_gencarpeta := vvalorparam;
               END IF;
               
               IF pcmap = 'Cargue_masivo_ULEA' THEN
                   IF vnombreparam = 'FECHA' THEN
                      v_fechaulea := vvalorparam;
                   END IF;
                    IF vnombreparam = 'CRAMO' THEN
                      v_cramoulea := vvalorparam;
                   END IF;
                    IF vnombreparam = 'VALORULEA' THEN
                      v_valorulea := vvalorparam;
                   END IF;
                  v_gencarpeta := vvalorparam;
               END IF;

               IF (LENGTH(pparams(vinfo).valor_columna) > 0) THEN
                  BEGIN
                     vpasexec := 7;
                     /* INI - JLTS -IAXIS-13244 -27/03/2020 - Se incluye el REPLACE del valor numérico (vtipoparam, 2) */
                     INSERT INTO lanzar_informes_params
                                 (sinterf, tparam, ctipo,
                                  nvalpar,
                                  tvalpar,
                                  fvalpar)
                          VALUES (vsinterf, vnombreparam, vtipoparam,
                                  DECODE(vtipoparam, 2, REPLACE(vvalorparam,'.',''), NULL),
                                  DECODE(vtipoparam, 1, TO_CHAR(vvalorparam), NULL),
                                  DECODE(vtipoparam,
                                         3, TO_DATE(vvalorparam, 'dd/mm/yyyy'),
                                         NULL));
	             /* FIN - JLTS -IAXIS-13244 -27/03/2020*/
                  EXCEPTION
                     WHEN OTHERS THEN
                        pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                                          vpasexec, vparam,
                                                          psqcode => SQLCODE,
                                                          psqerrm => SQLERRM);
                  END;
               END IF;
            END LOOP;
         END IF;
      END IF;

      vpasexec := 8;
      vdatasource := 'DB:';

      SELECT cinforme
        INTO vfichero
        FROM det_lanzar_informes
       WHERE cmap = pcmap
         AND cidioma = pcidioma
         AND cempres = pcempres;

      ofichero := SUBSTR(vfichero, 1, INSTR(vfichero, '.', -1) - 1) || '_' || pcempres
                  || TO_CHAR(f_sysdate, 'yyyymmddhh24miss') || '.' || pcexport;
      --Nombre del fichero sin la ruta
      onomfichero := ofichero;

      -- bug 0028554 - 13/03/2014 - JMF: parametro opcional pdestcopia
      IF v_gencarpeta IS NOT NULL THEN
         v_destcopia := pac_md_common.f_get_parinstalacion_t('INFORMES_C') || '\'
                        || v_gencarpeta || '\' || ofichero;
      ELSE
         v_destcopia := NULL;
      END IF;

      BEGIN
      
      IF (pcbatch = 2) THEN

FOR regexis IN cur_exist(v_cramoulea,v_valorulea,v_fechaulea)  
 LOOP
vtmsg := pac_iobj_mensajes.f_get_descmensaje(1000480,
                                                         pac_md_common.f_get_cxtidioma);
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 1, 'No es posible agregar reservas los parametros ya existen (FECHA,RAMO,VALOR)');
 return 1;
 END LOOP;
 END IF;
         -- bug 0028554 - 13/03/2014 - JMF: parametro opcional v_destcopia
         vnumerr :=
            pac_md_listado.f_crida_llistats
                                     (vsinterf, pcempres, NULL, NULL, NULL, 1, pcexport,
                                      pac_md_common.f_get_parinstalacion_t('PLANTI_C') || '\'
                                      || vfichero,
                                      pac_md_common.f_get_parinstalacion_t('INFORMES_SERV')
                                      || '\' || ofichero,
                                      vdatasource, vperror, mensajes, v_destcopia);
      EXCEPTION
         WHEN OTHERS THEN
            vpasexec := 9;
            ROLLBACK;
            pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                              psqcode => SQLCODE, psqerrm => SQLERRM);
            RETURN 1;
      END;

      ofichero := pac_md_common.f_get_parinstalacion_t('INFORMES_SERV') || '\' || ofichero;

      IF NVL(pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa, 'SO_SERV_FICH'),
             'WINDOWS') = 'UNIX' THEN
         ofichero := REPLACE(ofichero, '\', '/');
      END IF;

      IF vnumerr <> 0 THEN
         vpasexec := 10;

         UPDATE lanzar_informes
            SET cestado = 99,
                terror = vperror,
                -- tfichero = ofichero,
                tfichero = NULL,
                cuser = f_user,
                ffin = f_sysdate
          WHERE sinterf = vsinterf;
      ELSE
         vpasexec := 11;

         IF (pcbatch = 0) THEN
            -- No es blatch
            UPDATE lanzar_informes
               SET cestado = vnumerr,
                   terror = NULL,
                   tfichero = ofichero,
                   cuser = f_user,
                   ffin = f_sysdate
             WHERE sinterf = vsinterf;

            -- No es batch y el informe se ha generado correctament
             --Entonces se manda el correo si se ha informado el pemail
            IF (pemail IS NOT NULL) THEN
               vretemail := f_enviar_mail(vsinterf, pemail, ofichero, onomfichero,
                                          pcmap || ' '
                                          || TO_CHAR(f_sysdate, 'yyyymmddhh24miss'),
                                          NULL, NULL);

               --Si ha ido bien o mal debe actualizar lanzar_informes
               IF (vretemail = 0) THEN
                  UPDATE lanzar_informes
                     SET cestenvio = 0
                   WHERE sinterf = vsinterf;
               ELSE
                  UPDATE lanzar_informes
                     SET cestenvio = 1,
                         terror = 'Error al enviar el correo electr¿nico.'
                   WHERE sinterf = vsinterf;
               END IF;
            END IF;
         ELSE
            vpasexec := 12;
            vtmsg := pac_iobj_mensajes.f_get_descmensaje(9905671,
                                                         pac_md_common.f_get_cxtidioma);
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 0, vtmsg);
         END IF;
      END IF;
IF pcmap = 'CierreDeSiniestros' and pcbatch = 3 THEN
pac_conta_sap.GENERA_INFO_CUENTAS_RES(2);
pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 1, 'Proceso terminado');
RETURN 1;
end if;
IF pcmap = 'Cargue_masivo_ULEA' THEN
    IF (pcbatch = 0) THEN
    
    
    /*DELETE from SIN_TRAMITA_RESERVADET WHERE (NSINIES,NMOVRES,IDRES,NMOVRESDET,ISALRES) IN
    (SELECT NSINIES,NMOVRES,IDRES,1,IRESERVA FROM SIN_TRAMITA_RESERVA_ULEA); 
    
    DELETE  from SIN_TRAMITA_RESERVA WHERE (NSINIES,NTRAMIT,CTIPRES,NMOVRES,CGARANT,IDRES,IRESERVA) IN
    (SELECT NSINIES,0,5,NMOVRES,CGARANT,IDRES,IRESERVA FROM SIN_TRAMITA_RESERVA_ULEA);*/ 
    delete from SIN_TRAMITA_RESERVA_ULEA WHERE  CRAMO like decode(v_cramoulea,0,'%',v_cramoulea) AND FEMISIO=to_date(v_fechaulea,'dd/mm/yyyy') AND VALORULEA=v_valorulea AND ESTADO='VISUALIZADO' and (cramo,to_date(v_fechaulea, 'dd/mm/yyyy'),v_valorulea) not in
(select cramo,femisio,valorulea from sin_tramita_reserva_ulea where estado='INSERTADO');
    commit;
    --IAXIS 3648 EDIER ARTEAGA validacion de data mala. 
    FOR reg IN cur(v_cramoulea,v_valorulea,v_fechaulea)
      LOOP
      vtotalulea:=cur%ROWCOUNT;      
      if reg.cgarant is not null and reg.tgarant is not null
              and reg.icaprie_moncia is not null and reg.CMONRES is not null
              and reg.cramo is not null and reg.tramo is not null
              then
                   INSERT INTO SIN_TRAMITA_RESERVA_ULEA (NSINIES, CGARANT, TGARANT,IDRES,ICAPRIE_MONCIA,NMOVRES, CMONRES, IRESERVA, FEMISIO, CRAMO, TRAMO,VALORULEA, FRESINI, FRESFIN, CUSUALT, FALTA,ESTADO) 
            VALUES 
            (reg.nsinies, reg.cgarant, reg.tgarant,reg.rank,reg.icaprie_moncia,reg.nmovres, reg.CMONRES, round((v_valorulea/reg.totalresgistros)*reg.por,0), TO_DATE(v_fechaulea, 'dd/mm/yyyy'), reg.cramo,reg.tramo,v_valorulea, null, null, f_user(), f_sysdate,'VISUALIZADO');
        end if;
       END LOOP;
	--IAXIS 3648 EDIER ARTEAGA validacion de data mala.   
    COMMIT;
    
    END IF; 
END IF;
IF (pcbatch = 2) THEN



       /*Insert into SIN_TRAMITA_RESERVA (NSINIES,NTRAMIT,CTIPRES,NMOVRES,CGARANT,CCALRES,FMOVRES,CMONRES,IRESERVA,IPAGO,IINGRESO,IRECOBRO,ICAPRIE,IPENALI,FRESINI,FRESFIN,FULTPAG,SIDEPAG,SPROCES,FCONTAB,CUSUALT,FALTA,CUSUMOD,FMODIFI,IPREREC,CTIPGAS,IRESERVA_MONCIA,IPAGO_MONCIA,IINGRESO_MONCIA,IRECOBRO_MONCIA,ICAPRIE_MONCIA,IPENALI_MONCIA,IPREREC_MONCIA,FCAMBIO,IFRANQ,IFRANQ_MONCIA,NDIAS,ITOTIMP,ITOTIMP_MONCIA,ITOTRET,ITOTRET_MONCIA,IDRES,CMOVRES,CSOLIDARIDAD) 
select nsinies,0,5,NMOVRES,cgarant,0,FALTA,CMONRES,IRESERVA,0,0,0,0,null,null,null,null,null,null,null,CUSUALT,FALTA,null,null,null,null,IRESERVA,0,0,0,ICAPRIE_MONCIA,null,null,null,null,null,null,0,0,0,0,IDRES,1,0 
from  sin_tramita_reserva_ulea
;
Insert into SIN_TRAMITA_RESERVADET (NSINIES,IDRES,NMOVRES,NMOVRESDET,CMONRES,CREEXPRESION,CTRASPASO,ISALRES,ISALRESAANT,ISALRESAACT,ICONSTRES,IAUMENRES,ILIBERARES,IDISMIRES,FCAMBIO,ISALRES_MONCIA,ISALRESAANT_MONCIA,ISALRESAACT_MONCIA,ICONSTRES_MONCIA,IAUMENRES_MONCIA,ILIBERARES_MONCIA,IDISMIRES_MONCIA,CUSUALTA,FALTA,CUSUMOD,FMODIFI) 
select nsinies,idres,NMOVRES,1,'COP',0,0,IRESERVA,null,null,null,null,null,null,null,ICAPRIE_MONCIA,null,null,null,null,null,null,null,null,null,null 
from  sin_tramita_reserva_ulea
;
COMMIT;*/
    FOR I IN cur_insertar(v_cramoulea,v_valorulea,v_fechaulea)
      LOOP
      
      tot_insert:=tot_insert+1;  
      vtotalulea:=cur_insertar%ROWCOUNT;
           V_NNUMERR := PAC_IAX_SINIESTROS.F_INICIALIZASINIESTRO(NULL,
                                                                NULL,
                                                                I.NSINIES,
                                                                MENSAJES);        

         IF V_NNUMERR = 0 THEN  
            begin
                 

              BEGIN
                select r.ireserva,r.nmovres
                  INTO VIRESERVA,VNMOVRES
                  from sin_tramita_reserva r
                 where r.nsinies = I.nsinies
                   and r.ctipres = 5
                   and r.idres = (select max(i1.idres)
                                    from sin_tramita_reserva i1
                                   where i1.nsinies = I.nsinies
                                     and i1.ctipres = 5)
                   and r.nmovres = (select max(i2.nmovres)
                                      from sin_tramita_reserva i2
                                     where i2.nsinies = I.nsinies
                                       and i2.ctipres = 5);
									   
			EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  VIRESERVA := NULL;
                  VNMOVRES := NULL; 
              END;
        SELECT sseguro
        INTO v_sseguro
        FROM sin_siniestro
       WHERE nsinies = I.nsinies;
       V_NNUMERR:=pac_siniestros.f_get_capitalgar(I.cgarant, v_sseguro, I.nsinies,v_icaprie);
       
              

               if vireserva is not null then
                 vvalor :=  /*I.ireserva-vireserva*/I.ireserva;
               else
                 vvalor := I.ireserva;  
               end if;
                V_NNUMERR := PAC_IAX_SINIESTROS.F_SET_OBJETO_SINTRAMIRESERVA(I.nsinies, 
                                                                 nvl(to_number(0),null), 
                                                                 nvl(to_number(5),null), 
                                                                  
                                                                 null, 
                                                                 VNMOVRES, 
                                                                 nvl(to_number(I.cgarant),null), 
                                                                 nvl(to_number(0),null), 
                                                                 null, 
                                                                 I.cmonres, 
                                                                 nvl(to_number(vvalor),null), 
                                                                 null,
                                                                 null,
                                                                 null, 
                                                                 nvl(to_number(v_icaprie),null),
                                                                 null, 
                                                                 null,
                                                                 null,
                                                                 null,
                                                                 null, 
                                                                 null,
                                                                 null, 
                                                                 null,
                                                                 null, 
                                                                 'RESER', 
                                                                 'axislist003',  
                                                                 null, 
                                                                 null,
                                                                 nvl(to_number(2),null), 
                                                                 null, 
                                                                 MENSAJES,
                                                                 null, 
                                                                 null, 
                                                                 null,
                                                                 null,
                                                                 null, 
                                                                 null, 
                                                                 null, 
                                                                 null,
                                                                 null,
                                                                 0
                                                                 );
                IF V_NNUMERR = 0 THEN
                cont_insert:=cont_insert+1;
                UPDATE SIN_TRAMITA_RESERVA_ULEA SET ESTADO='INSERTADO' 
                WHERE NSINIES=I.NSINIES  AND cgarant=I.cgarant   
                AND CRAMO like decode(v_cramoulea,0,'%',v_cramoulea) AND FEMISIO=to_date(v_fechaulea,'dd/mm/yyyy') AND VALORULEA=v_valorulea;
                END IF;
         end;
        END IF;
       END LOOP;
       commit;
       pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 1, 'Se agregaron '||cont_insert||'/'||tot_insert||' reservas ULAE');
        return 1;
END IF;
      IF (vnumerr = 0
          AND pcgenrec = 1) THEN
         vnumerr := pac_propio.f_gen_rec_informe(pcmap, pparams);
      END IF;

      COMMIT;
      RETURN vnumerr;   --todo ok
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         vpasexec := 15;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END;

   FUNCTION f_set_detlanzarinformes(
      pcempres IN det_lanzar_informes.cempres%TYPE,
      pcmap IN det_lanzar_informes.cmap%TYPE,
      pcidioma IN det_lanzar_informes.cidioma%TYPE,
      ptdescrip IN det_lanzar_informes.tdescrip%TYPE,
      pcinforme IN det_lanzar_informes.cinforme%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_INFORMES.F_Set_detlanzarinformes';
      vparam         VARCHAR2(2000)
         := 'parametros pcempresa = ' || pcempres || ' pcmap=' || pcmap || ' pcidioma='
            || pcidioma || ' ptdescrip=' || ptdescrip || ' pcinforme=' || pcinforme;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      BEGIN
         vpasexec := 2;

         INSERT INTO det_lanzar_informes
                     (cempres, cmap, cidioma, tdescrip, cinforme)
              VALUES (pcempres, pcmap, pcidioma, ptdescrip, pcinforme);

         COMMIT;
      EXCEPTION
         WHEN OTHERS THEN
            vpasexec := 901;
            ROLLBACK;
            pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec,
                                              vparam, psqcode => SQLCODE, psqerrm => SQLERRM);
            RETURN 1;
      END;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_set_detlanzarinformes;

   FUNCTION f_set_cfglanzarinformes(
      pcempres IN cfg_lanzar_informes.cempres%TYPE,
      pcform IN cfg_lanzar_informes.cform%TYPE,
      pcmap IN cfg_lanzar_informes.cmap%TYPE,
      ptevento IN cfg_lanzar_informes.tevento%TYPE,
      psproduc IN cfg_lanzar_informes.sproduc%TYPE,
      pslitera IN cfg_lanzar_informes.slitera%TYPE,
      plparams IN cfg_lanzar_informes.lparams%TYPE,
      pgenerareport IN cfg_lanzar_informes.genera_report%TYPE,
      pccfgform IN cfg_lanzar_informes.ccfgform%TYPE,
      plexport IN cfg_lanzar_informes.lexport%TYPE,
      pctipo IN cfg_lanzar_informes.ctipo%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_INFORMES.F_Set_cfglanzarinformes';
      vparam         VARCHAR2(2000)
         := 'parametros pcempres=' || pcempres || ' pcmap=' || pcmap || ' ptevento='
            || ptevento || ' psproduc=' || psproduc || ' pslitera=' || pslitera
            || ' plparams=' || plparams || ' pgenerareport=' || pgenerareport || ' pccfgform='
            || pccfgform || ' plexport=' || plexport || ' pctipo=' || pctipo;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_informes.f_ins_cfglanzarinformes(pcempres, pcform, pcmap, ptevento,
                                                      psproduc, pslitera, plparams,
                                                      pgenerareport, pccfgform, plexport,
                                                      pctipo);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_set_cfglanzarinformes;

   FUNCTION f_upd_cfglanzarinformes(
      pcempres IN cfg_lanzar_informes.cempres%TYPE,
      pcmap IN cfg_lanzar_informes.cmap%TYPE,
      ptevento IN cfg_lanzar_informes.tevento%TYPE,
      psproduc IN cfg_lanzar_informes.sproduc%TYPE,
      pccfgform IN cfg_lanzar_informes.ccfgform%TYPE,
      plexport IN cfg_lanzar_informes.lexport%TYPE,
      pslitera IN cfg_lanzar_informes.slitera%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_INFORMES.f_upd_cfglanzarinformes';
      vparam         VARCHAR2(2000)
         := 'parametros pcempres=' || pcempres || ' pcmap=' || pcmap || ' ptevento='
            || ptevento || ' psproduc=' || psproduc || ' pccfgform=' || pccfgform
            || ' plexport=' || plexport || ' pslitera = ' || pslitera;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_informes.f_upd_cfglanzarinformes(pcempres, pcmap, ptevento, psproduc,
                                                      pccfgform, plexport, pslitera);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END;

   FUNCTION f_del_detlanzarinformes(
      pcempres IN det_lanzar_informes.cempres%TYPE,
      pcmap IN det_lanzar_informes.cmap%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_INFORMES.f_del_detlanzarinformes';
      vparam         VARCHAR2(2000)
                                 := 'parametros pcempres = ' || pcempres || ' pcmap=' || pcmap;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      DELETE      det_lanzar_informes
            WHERE cmap = pcmap
              AND cempres = pcempres;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END;

   FUNCTION f_ins_cfglanzarinformesparams(
      pcempres IN cfg_lanzar_informes_params.cempres%TYPE,
      pcform IN cfg_lanzar_informes_params.cform%TYPE,
      pcmap IN cfg_lanzar_informes_params.cmap%TYPE,
      ptevento IN cfg_lanzar_informes_params.tevento%TYPE,
      psproduc IN cfg_lanzar_informes_params.sproduc%TYPE,
      pccfgform IN cfg_lanzar_informes_params.ccfgform%TYPE,
      ptparam IN cfg_lanzar_informes_params.tparam%TYPE,
      pctipo IN cfg_lanzar_informes_params.ctipo%TYPE,
      pnorder IN cfg_lanzar_informes_params.norder%TYPE DEFAULT NULL,
      pslitera IN cfg_lanzar_informes_params.slitera%TYPE DEFAULT NULL,
      pnotnull IN cfg_lanzar_informes_params.notnull%TYPE DEFAULT NULL,
      PLValor IN cfg_lanzar_informes_params.lvalor%TYPE DEFAULT NULL,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_INFORMES.f_ins_cfglanzarinformesparams';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vparam         VARCHAR2(2000)
         := 'parametros pcempres=' || pcempres || ' pcform=' || pcform || ' pcmap=' || pcmap
            || ' ptevento=' || ptevento || ' psproduc=' || psproduc || ' pccfgform='
            || pccfgform || ' ptparam=' || ptparam || ' pctipo=' || pctipo || ' pnorder='
            || pnorder || ' pslitera=' || pslitera || ' pnotnull=' || pnotnull || ' plvalor  '
            || PLValor;
   BEGIN
      vnumerr := pac_informes.f_ins_cfglanzarinformesparams(pcempres, pcform, pcmap, ptevento,
                                                            psproduc, pccfgform, ptparam,
                                                            pctipo, pnorder, pslitera,
                                                            pnotnull, PLValor);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END;

   FUNCTION f_del_cfglanzarinformesparams(
      pcempres IN cfg_lanzar_informes_params.cempres%TYPE,
      pcform IN cfg_lanzar_informes_params.cform%TYPE,
      pcmap IN cfg_lanzar_informes_params.cmap%TYPE,
      ptevento IN cfg_lanzar_informes_params.tevento%TYPE,
      psproduc IN cfg_lanzar_informes_params.sproduc%TYPE,
      pccfgform IN cfg_lanzar_informes_params.ccfgform%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_INFORMES.f_del_cfglanzarinformesparams';
      vparam         VARCHAR2(2000)
         := 'parametros pcempres=' || pcempres || ' pcform=' || pcform || ' pcmap=' || pcmap
            || ' ptevento=' || ptevento || ' psproduc=' || psproduc || ' pccfgform='
            || pccfgform;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_informes.f_del_cfglanzarinformesparams(pcempres, pcform, pcmap, ptevento,
                                                            psproduc, pccfgform);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END;

   FUNCTION f_get_listainformesreports(
      pcempres IN cfg_lanzar_informes.cempres%TYPE,
      pidioma IN axis_literales.cidioma%TYPE,
      pcform IN cfg_lanzar_informes.cform%TYPE,
      pcmap IN cfg_lanzar_informes_params.cmap%TYPE DEFAULT NULL,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      olistinformes  sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vobject        VARCHAR2(200) := 'PAC_md_informes.f_get_listaInformesReports';
      num_err        NUMBER;
      vparam         VARCHAR2(2000)
         := 'par¿metros - pcempres: ' || pcempres || ' pcform ' || pcform || ' - pcmap: '
            || pcmap;
      vselect        VARCHAR2(2500);
      vcmap          VARCHAR2(1000);   -- BUG 38344/217178 - 29/10/2015 - ACL
   BEGIN
      vselect :=
         'SELECT distinct li.CMAP ,li.cempres, li.cform, li.tevento, li.sproduc, li.slitera, F_AXIS_LITERALES(LI.SLITERA,'
         || pidioma || ') as tlitera, '
         || ' li.lparams, li.genera_report, li.ccfgform, li.lexport, li.ctipo, empresas.tempres'
         || ' FROM cfg_lanzar_informes li, empresas, det_lanzar_informes dt '
         || ' WHERE 1 = 1 ' || ' AND li.cempres = ' || pcempres
         || ' AND li.cempres = empresas.cempres  and li.cempres =  dt.cempres '
         || ' AND li.cmap = dt.cmap ' || '  and li.cform =''' || pcform || ''' ';

      IF (pcmap IS NOT NULL) THEN
         -- Inicio BUG 38344/217178 - 29/10/2015 - ACL
         vcmap := pcmap;
         vcmap := REPLACE(vcmap, CHR(39), CHR(39) || CHR(39));
         vselect := vselect || ' and upper(li.cmap) like ''%' || UPPER(vcmap) || '%''';
      -- Fin BUG 38344/217178 - 29/10/2015 - ACL
      END IF;

      olistinformes := pac_md_listvalores.f_opencursor(vselect, mensajes);
      RETURN olistinformes;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF olistinformes%ISOPEN THEN
            CLOSE olistinformes;
         END IF;

         RETURN olistinformes;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF olistinformes%ISOPEN THEN
            CLOSE olistinformes;
         END IF;

         RETURN olistinformes;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF olistinformes%ISOPEN THEN
            CLOSE olistinformes;
         END IF;

         RETURN olistinformes;
   END;

   FUNCTION f_get_cfginforme(
      pcempres IN NUMBER,
      pcform IN VARCHAR2,
      ptevento IN VARCHAR2,
      psproduc IN NUMBER,
      pcmap IN VARCHAR2,
      pcurconfigsinf OUT sys_refcursor,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vobject        VARCHAR2(200) := 'PAC_md_informes.f_get_cfgInforme';
      num_err        NUMBER;
      vcempres       NUMBER;
      squery         VARCHAR2(3000);
      vwhere         VARCHAR2(3000);
      vccfgform      VARCHAR2(200);
      vcont          NUMBER;
      vparam         VARCHAR2(2000)
         := 'par¿metros - pcempres: ' || pcempres || ' - pcform: ' || pcform || ' - ptevento:'
            || ptevento || ' - psproduc: ' || psproduc || '- pcmap: ' || pcmap;
      v_ccfgmap      cfg_map.ccfgmap%TYPE;
   BEGIN
      vpasexec := 1;
      vcempres := pcempres;
      squery := 'select C.*, f_axis_literales(slitera,' || pac_md_common.f_get_cxtidioma
                || ') TLITERA  from CFG_LANZAR_INFORMES C ' || ' where cempres = ' || pcempres
                || ' and upper(cform)=upper(''' || pcform || ''') '
                || ' and UPPER(tevento) = UPPER(''' || ptevento || ''')' || ' and sproduc = '
                || psproduc || ' and upper(cmap)=upper(''' || pcmap || ''')';
      pcurconfigsinf := pac_md_listvalores.f_opencursor(squery, mensajes);
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END;

   FUNCTION f_upd_inf_batch(
      pcestado IN lanzar_informes.cestado%TYPE,
      pterror IN lanzar_informes.terror%TYPE,
      ptfichero IN lanzar_informes.tfichero%TYPE,
      psinterf IN lanzar_informes.sinterf%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_INFORMES.f_upd_inf_batch';
      vparam         VARCHAR2(2000)
         := 'parametros pcestado=' || pcestado || ' pterror=' || pterror || ' ptfichero='
            || ptfichero || ' psinterf=' || psinterf;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vemail         lanzar_informes.cemail%TYPE;
      vcmap          lanzar_informes.cmap%TYPE;
      vretemail      NUMBER;
      vnomfichero    VARCHAR2(200);
   BEGIN
      UPDATE lanzar_informes
         SET cestado = pcestado,
             terror = pterror,
             tfichero = ptfichero,
             cuser = f_user,
             ffin = f_sysdate
       WHERE sinterf = psinterf;

      vpasexec := 2;

      --Si ha ido correctamente envio el mail
      IF (pcestado = 0) THEN
         --Si se ha informado el mail se lanza
         SELECT cemail, cmap
           INTO vemail, vcmap
           FROM lanzar_informes
          WHERE sinterf = psinterf;

         SELECT SUBSTR(ptfichero,
                       GREATEST(INSTR(ptfichero, '/', -1), INSTR(ptfichero, '\', -1)) + 1)
           INTO vnomfichero
           FROM DUAL;

         IF (vemail IS NOT NULL) THEN
            vretemail := f_enviar_mail(psinterf, vemail, ptfichero, vnomfichero,
                                       vcmap || ' ' || TO_CHAR(f_sysdate, 'yyyymmddhh24miss'),
                                       NULL, NULL);

            IF (vretemail = 0) THEN
               UPDATE lanzar_informes
                  SET cestado = 0
                WHERE sinterf = psinterf;
            ELSE
               UPDATE lanzar_informes
                  SET cestenvio = 1,
                      terror = 'Error al enviar el correo electr¿nico.'
                WHERE sinterf = psinterf;
            END IF;
         END IF;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         ROLLBACK;
         RETURN 1;
   END;

   FUNCTION f_get_listainformes(
      pcempres IN lanzar_informes.cempres%TYPE,
      pcmap IN lanzar_informes.cmap%TYPE DEFAULT NULL,
      pcestado IN lanzar_informes.cestado%TYPE DEFAULT NULL,
      pcuser IN lanzar_informes.cuser%TYPE DEFAULT NULL,
      pfini IN lanzar_informes.fini%TYPE DEFAULT NULL,
      pffin IN lanzar_informes.ffin%TYPE DEFAULT NULL,
      pcbatch IN lanzar_informes.cbatch%TYPE DEFAULT NULL,
      pcursoninformes OUT sys_refcursor,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vselect        VARCHAR2(2500);
      vpasexec       NUMBER(8) := 1;
      vobject        VARCHAR2(200) := 'PAC_md_informes.f_get_listaInformes';
      num_err        NUMBER;
      vparam         VARCHAR2(2500)
         := 'par¿metros - pcempres: ' || pcempres || ' - pcmap: ' || pcmap || ' - pcestado:'
            || pcestado || ' - pcuser: ' || pcuser || '- pfini: ' || pfini || ' -pffin: '
            || pffin || ' -pcbatch: ' || pcbatch;
   BEGIN
      vselect :=
         'SELECT   SINTERF, CMAP, CEMPRES, CEXPORT, TFICHERO,CESTADO, TERROR,CUSER, '
         || ' SLITERA, FINI, FFIN, CBATCH, TO_CHAR(FINI,''DD/MM/YYYY HH24:MI:SS'') FECHAINICIO,TO_CHAR(FFIN,''DD/MM/YYYY HH24:MI:SS'') FECHAFIN,'
         || ' CEMAIL, CESTENVIO ' || ' FROM LANZAR_INFORMES WHERE cempres = ' || pcempres;

      IF (pcmap IS NOT NULL) THEN
         vselect := vselect || ' AND upper(cmap)  LIKE upper(''%' || pcmap || '%'')';
      END IF;

      IF (pcestado IS NOT NULL) THEN
         vselect := vselect || '  and cestado = ' || pcestado;
      END IF;

      IF (pcuser IS NOT NULL) THEN
         vselect := vselect || ' and UPPER(cuser) =UPPER(''' || pcuser || ''')';
      END IF;

      IF (pcbatch IS NOT NULL) THEN
         vselect := vselect || ' and cbatch = ' || pcbatch;
      END IF;

      IF (pfini IS NOT NULL) THEN
         vselect := vselect || ' and trunc(fini) >= to_date('''
                    || TO_CHAR(pfini, 'DD/MM/YYYY') || ''',''DD/MM/YYYY'')';
      END IF;

      IF (pffin IS NOT NULL
          AND(pcestado <> 1)) THEN
         vselect := vselect || ' and trunc(ffin) <= to_date('''
                    || TO_CHAR(pffin, 'DD/MM/YYYY') || ''',''DD/MM/YYYY'')';
      END IF;

      pcursoninformes := pac_md_listvalores.f_opencursor(vselect, mensajes);
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_listainformes;

   FUNCTION f_get_idiomasinforme(
      pcempres IN cfg_lanzar_informes.cempres%TYPE,
      pcmap IN det_lanzar_informes.cmap%TYPE,
      pcform IN cfg_lanzar_informes.cform%TYPE,
      pcursoridiomas OUT sys_refcursor,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vselect        VARCHAR2(2500);
      vpasexec       NUMBER(8) := 1;
      vobject        VARCHAR2(200) := 'PAC_md_informes.f_get_idomasinforme';
      num_err        NUMBER;
      vparam         VARCHAR2(2500)
         := 'par¿metros - pcempres: ' || pcempres || ' - pcmap: ' || pcmap || ' - pcform:'
            || pcform;
   BEGIN
      vselect := 'SELECT DET.cmap,det.cidioma, tdescrip, cinforme, i.tidioma '
                 || 'FROM CFG_LANZAR_INFORMES LI, det_lanzar_informes DET, idiomas i '
                 || 'WHERE UPPER(LI.CFORM) = UPPER(''' || pcform || ''')'
                 || ' AND LI.CEMPRES = ' || pcempres
                 || ' AND DET.CMAP =  LI.CMAP  and li.cempres =  det.cempres '
                 || ' and upper(det.CMAP) =upper(''' || pcmap || ''')'
                 || ' and i.cidioma = det.cidioma   ';
      pcursoridiomas := pac_md_listvalores.f_opencursor(vselect, mensajes);
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END;
   ---pac_md_informe IAXIS 3602 Shubhendu Informe Tecnico ---
   --function for inserting data informe technico
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
      vparam     VARCHAR2 (2500) := 'par¿metros - pcempres: ';
      vobject    VARCHAR2 (200)  := 'PAC_iax_informes.f_inforeme_technico';
      num_err    NUMBER;
      numetra varchar2(1000);
      cusalat varchar2(1000);
      csumod varchar2(1000);
   BEGIN
        numetra := 'Numero De tram';
        cusalat := 'user';
        csumod := 'user';
      Insert into  Sin_Informe_Tecnico values(preclamo,pdeplazo,pinterventor,psupervisor,numetra,f_sysdate,cusalat,f_sysdate,csumod,pfelaboracion,pfuentedeinfo);
      commit;
      return 0;
   END;

   FUNCTION f_get_usuarios(
      pcempres IN NUMBER,
      pcursorusuarios OUT sys_refcursor,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vselect        VARCHAR2(2500);
      vpasexec       NUMBER(8) := 1;
      vobject        VARCHAR2(200) := 'PAC_md_informes.f_get_usuarios';
      num_err        NUMBER;
      vparam         VARCHAR2(2500) := 'par¿metros - pcempres: ' || pcempres;
   BEGIN
      vselect := 'select  distinct li.cuser, u.tusunom '
                 || ' from lanzar_informes li, usuarios u ' || ' where li.cempres ='
                 || pcempres || ' and li.cuser =  u.cusuari ' || ' order by tusunom asc ';
      pcursorusuarios := pac_md_listvalores.f_opencursor(vselect, mensajes);
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END;

   FUNCTION f_enviar_mail(
      piddoc IN NUMBER,
      pmailgrc IN VARCHAR2,
      prutafichero IN VARCHAR2,
      pfichero IN VARCHAR2,
      psubject IN VARCHAR2,
      pcuerpo IN VARCHAR2 DEFAULT '',
      pmailcc IN VARCHAR2 DEFAULT '',
      pmailcco IN VARCHAR2 DEFAULT '',
      pdirectorio IN VARCHAR2 DEFAULT 'GEDOXTEMPORAL',
      pfrom IN VARCHAR2 DEFAULT '',
      pdirectorio2 IN VARCHAR2 DEFAULT 'GEDOXTEMPORAL',
      pfichero2 IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER IS
      vterror        VARCHAR2(1000);
      vtfilename     VARCHAR2(50);
      v_lob          BLOB;
      v_buffer_size  INTEGER := 57;
      v_offset       NUMBER := 1;
      v_raw          RAW(32767);
      v_length       NUMBER := 0;
      vcount         NUMBER := 1;
      vemail         VARCHAR2(1000) := '';
      vsseguro       NUMBER := 0;
      vsperson       NUMBER := 0;
      vasunto        VARCHAR2(500);
      vcuerpo        VARCHAR2(4000);
      v_pasexec      NUMBER := 0;
      conn           UTL_SMTP.connection;
      nerror         NUMBER := 0;
      v_mailsender   VARCHAR2(1000) := '';
      fichero        BFILE;
   BEGIN
      --Consulta la direccion de correo de quien envia
      v_mailsender := pac_md_common.f_get_parinstalacion_t('MAIL_USER');

      IF pfrom IS NOT NULL THEN
         v_mailsender := pfrom;
      END IF;

      IF (v_mailsender IS NULL) THEN
         RETURN 151423;
      END IF;

      BEGIN
         conn := pac_send_mail.begin_mail(sender => v_mailsender, recipients => pmailgrc,
                                          cc => pmailcc, cco => pmailcco, subject => psubject,
                                          mime_type => pac_send_mail.multipart_mime_type
                                           || '; charset=iso-8859-1');
         pac_send_mail.attach_text(conn => conn, DATA => pcuerpo, mime_type => 'text/html');
      EXCEPTION
         WHEN OTHERS THEN
            vcount := 0;
            nerror := 9904380;
            v_pasexec := 12;
            p_tab_error(f_sysdate, f_user, 'PAC_MD_INFORMES.f_enviar_mail', v_pasexec,
                        SQLCODE, SQLERRM);
      END;

      v_pasexec := 5;

      IF pfichero IS NOT NULL THEN
         BEGIN
            pac_send_mail.begin_attachment(conn => conn, mime_type => 'text/html',
                                           inline => TRUE, filename => pfichero,
                                           transfer_enc => 'base64');
            fichero := BFILENAME(pdirectorio, pfichero);
            DBMS_LOB.createtemporary(v_lob, FALSE);
            DBMS_LOB.fileopen(fichero, DBMS_LOB.file_readonly);
            DBMS_LOB.loadfromfile(v_lob, fichero, DBMS_LOB.getlength(fichero));
            v_length := DBMS_LOB.getlength(v_lob);

            WHILE v_offset < v_length LOOP
               DBMS_LOB.READ(v_lob, v_buffer_size, v_offset, v_raw);
               UTL_SMTP.write_raw_data(conn, UTL_ENCODE.base64_encode(v_raw));
               UTL_SMTP.write_data(conn, UTL_TCP.crlf);
               v_offset := v_offset + v_buffer_size;
            END LOOP while_loop;

            v_offset := 1;
            v_length := 0;
            v_buffer_size := 57;
            v_raw := NULL;
            v_pasexec := 6;
            pac_send_mail.end_attachment(conn);
            v_pasexec := 7;
            DBMS_LOB.CLOSE(fichero);
         EXCEPTION
            WHEN OTHERS THEN
               vcount := 0;
               --nerror := 103187;
               nerror := 0;
               v_pasexec := 12;
               p_tab_error(f_sysdate, f_user, 'PAC_MD_INFORMES.f_enviar_mail', v_pasexec,
                           SQLCODE, SQLERRM);
         END;
      END IF;

      v_pasexec := 8;

      IF pfichero2 IS NOT NULL THEN
         BEGIN
            pac_send_mail.begin_attachment(conn => conn, mime_type => 'text/html',
                                           inline => TRUE, filename => pfichero2,
                                           transfer_enc => 'base64');
            fichero := BFILENAME(pdirectorio2, pfichero2);
            DBMS_LOB.createtemporary(v_lob, FALSE);
            DBMS_LOB.fileopen(fichero, DBMS_LOB.file_readonly);
            DBMS_LOB.loadfromfile(v_lob, fichero, DBMS_LOB.getlength(fichero));
            v_length := DBMS_LOB.getlength(v_lob);

            WHILE v_offset < v_length LOOP
               DBMS_LOB.READ(v_lob, v_buffer_size, v_offset, v_raw);
               UTL_SMTP.write_raw_data(conn, UTL_ENCODE.base64_encode(v_raw));
               UTL_SMTP.write_data(conn, UTL_TCP.crlf);
               v_offset := v_offset + v_buffer_size;
            END LOOP while_loop;

            v_offset := 1;
            v_length := 0;
            v_buffer_size := 57;
            v_raw := NULL;
            v_pasexec := 9;
            pac_send_mail.end_attachment(conn);
            v_pasexec := 10;
            DBMS_LOB.CLOSE(fichero);
         EXCEPTION
            WHEN OTHERS THEN
               vcount := 0;
               --nerror := 103187;
               nerror := 0;
               v_pasexec := 12;
               p_tab_error(f_sysdate, f_user, 'PAC_MD_INFORMES.f_enviar_mail', v_pasexec,
                           SQLCODE, SQLERRM);
         END;
      END IF;

      BEGIN
         v_pasexec := 11;
         pac_send_mail.end_mail(conn => conn);
      EXCEPTION
         WHEN OTHERS THEN
            v_pasexec := 12;
            nerror := nerror + 1;
            p_tab_error(f_sysdate, f_user, 'PAC_MD_INFORMES.f_enviar_mail', v_pasexec,
                        SQLCODE, SQLERRM);
      END;

      IF (nerror = 0) THEN
         RETURN 0;
      ELSE
         RETURN nerror;
      END IF;

      BEGIN
         v_pasexec := 13;
         DBMS_LOB.filecloseall();
      EXCEPTION
         WHEN DBMS_LOB.unopened_file THEN
            p_tab_error(f_sysdate, f_user, 'PAC_MD_INFORMES.f_enviar_mail', v_pasexec,
                        SQLCODE, SQLERRM);
      END;

      RETURN 1;
   END;
   
    --Inicio Tarea 4136 Kaio
  function F_LISTA_POLIZAS_PENDIENTES(
   pnumerotomador IN NUMBER,
             pnumerointermedirario IN NUMBER,
      pcursor OUT sys_refcursor,
      mensajes IN OUT t_iax_mensajes)

   RETURN number IS

      vpasexec       NUMBER(8) := 1;
      vobject        VARCHAR2(200) := 'PAC_md_informes.F_LISTA_POLIZAS_PENDIENTES';
      num_err        NUMBER;
      vparam         VARCHAR2(2500) := 'par¿metros - pnumerotomador: ' || pnumerotomador || 'par¿metros - pnumerointermedirario: ' || pnumerointermedirario;

    BEGIN
      
      --INI IAXIS-10514 JRVG 02/04/2020
         IF pnumerotomador IS NOT NULL THEN 
             pac_informes.SET_OBS_CONSORCIO(pnumerotomador);
         END IF;
      --FIN IAXIS-10514 JRVG 02/04/2020
         
          OPEN pcursor FOR 

                SELECT DISTINCT

                      SEGU.NPOLIZA AS c_npoliza,
                     SEGU.SSEGURO AS c_segu,                    
                     rc.nrecibo as c_recibo,  
                     (SELECT NCERTDIAN FROM rango_dian_movseguro rd WHERE rd.sseguro = SEGU.SSEGURO and rd.nmovimi = RC.nmovimi  and rownum <= 1) as c_dian,
                     obs.observacion as c_obs,
                     trunc((CURRENT_DATE - mv.fmovini)) as MAD,
                 --INI BUG 4136 JRVG: Correccion para mostrar el iva, gastos y total y se obtiene valores de f_get_import_vdetrecibos_mon                                     
                     to_char(pac_adm.f_get_import_vdetrecibos_mon(24,rc.nrecibo,1), 'FM999G999G999G999G999G999') as c_prima,  
                 --FIN BUG 5214 AABG: Correccion de decimales y se obtiene la prima desde recibos moncon
                 --FIN BUG 4136 JRVG: Correccion para mostrar el iva, gastos y total y se obtiene valores de f_get_import_vdetrecibos_mon
                     to_char(DECODE(pac_eco_tipocambio.f_cambio(
                            pac_monedas.f_moneda_producto_char(segu.sproduc),
                           pac_monedas.f_cmoneda_t(pac_parametros.f_parinstalacion_n('MONEDAINST')),
                            (SELECT trunc(MAX(xx.fcambio)) from detrecibos xx where xx.nrecibo = rc.nrecibo )), 1, NULL,
                            pac_eco_tipocambio.f_cambio(
                 pac_monedas.f_moneda_producto_char(segu.sproduc),
                 pac_monedas.f_cmoneda_t(pac_parametros.f_parinstalacion_n('MONEDAINST')),
                 (SELECT trunc(MAX(xx.fcambio)) from detrecibos xx where xx.nrecibo = rc.nrecibo ))),'FM999,999,999,990.99') as trm,                   
                 --INI BUG 4136 JRVG: Correccion para mostrar el iva, gastos y total y se obtiene valores de f_get_import_vdetrecibos
                 to_char(pac_adm.f_get_import_vdetrecibos(24,rc.nrecibo,1), 'FM999G999G999G999G999G999') as primame, 
                 --INI BUG 4136 JRVG: Correccion para mostrar el iva, gastos y total y se obtiene valores de f_get_import_vdetrecibos_mon  
                 --INI BUG 5214 AABG: Correccion para mostrar el iva, gastos y total y se obtiene valores de detrecibos moncon
                 to_char(pac_adm.f_get_import_vdetrecibos_mon(24,rc.nrecibo,2), 'FM999G999G999G999G999G999') as iva,   
                 to_char(pac_adm.f_get_import_vdetrecibos_mon(24,rc.nrecibo,3), 'FM999G999G999G999G999G999') as gastos,                 
                 to_char(pac_adm.f_get_import_vdetrecibos_mon(24,rc.nrecibo,4), 'FM999G999G999G999G999G999')  as TOTAL,
                 --FIN BUG 5214 AABG: Correccion para mostrar el iva, gastos y total y se obtiene valores de detrecibos moncon
                 --FIN BUG 4136 JRVG: Correccion para mostrar el iva, gastos y total y se obtiene valores de f_get_import_vdetrecibos_mon 
                     (TO_CHAR(pac_redcomercial.f_busca_padre(24, segu.cagente, NULL, NULL))
                        || ' ' ||
                     pac_isqlfor.f_agente(
                     pac_agentes.f_get_cageliq(segu.cempres, 2, segu.cagente))) as SUCURSAL,
                     segu.cagente as intermediario

                     FROM SEGUROS SEGU
                     JOIN TOMADORES TOMA ON TOMA.SSEGURO = SEGU.SSEGURO
                     JOIN RECIBOS RC ON RC.SSEGURO = SEGU.SSEGURO
                     join movrecibo mv on mv.nrecibo = rc.nrecibo and mv.smovrec = (select max(mr.smovrec) from movrecibo mr where mr.nrecibo = mv.nrecibo)
                     join detrecibos sdr on sdr.nrecibo = rc.nrecibo
                     join vdetrecibos detrc on detrc.nrecibo = rc.nrecibo
                     --INI BUG 5214 AABG: Se realiza join con tabla moncon para datos en USD
                     join vdetrecibos_monpol detrcmon on detrcmon.nrecibo = rc.nrecibo
                     --FIN BUG 5214 AABG: Se realiza join con tabla moncon para datos en USD
                     left join agentes ag on ag.cagente = segu.cagente
                     left join rango_dian_movseguro dian on dian.sseguro = rc.sseguro
                     left join obs_cuentacobro obs on rc.sseguro = obs.sseguro and rc.nrecibo = obs.nrecibo                

                     WHERE 
                         --INI BUG 5216 AABG: Se realiza join con personas relacionadas para consorcios
                         (TOMA.SPERSON = pnumerotomador OR TOMA.SPERSON IN (SELECT SPERSON FROM PER_PERSONAS_REL WHERE SPERSON_REL = pnumerotomador))
                         --FIN BUG 5216 AABG: Se realiza join con personas relacionadas para consorcios
                         and segu.cagente = DECODE(nvl(pnumerointermedirario,0), 0, segu.cagente, pnumerointermedirario)
                         and mv.smovrec = (select max(mv2.smovrec)
                         from movrecibo mv2 where mv2.nrecibo = mv.nrecibo)
                         and mv.cestrec = 0
                         and sdr.nrecibo = detrc.nrecibo
                         and sdr.nrecibo = detrcmon.nrecibo
                         AND sdr.cconcep = 0
                         and rc.ctiprec <> 9
                         order by segu.npoliza;

            RETURN 0;       
    EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
    END F_LISTA_POLIZAS_PENDIENTES;

    -- INI IAXIS-4136 JRVG  23/04/2020
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
         pac_informes.f_ins_obs_cuentacobro (pobservacion, psseguro, pnrecibo, pmarca  , mensajes);
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
   --Fin Tarea 4136 Kaio
   
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
   
END pac_md_informes;

/
