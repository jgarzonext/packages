--------------------------------------------------------
--  DDL for Package Body PAC_MD_COMMON
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "PAC_MD_COMMON" AS
/******************************************************************************
   NOMBRE:       PAC_MD_COMMON
   PROP¿SITO:  Funciones de uso general para el IAxis

   REVISIONES:
   Ver        Fecha        Autor             Descripci¿n
   ---------  ----------  ---------------  ------------------------------------
   1.0        25/01/2008   ACC                1. Creaci¿n del package.
   2.0        01/12/2009   AMC                2. bug 11308.Se a¿ade la funci¿n f_extrae_npoliza
   3.0        27/08/2010   FAL                2. 0015750: CRE998 - Modificacions m¿dul domiciliacions
******************************************************************************/

   --Define las varibles tipos contexto
   cxtidioma      VARCHAR2(100) := 'IAX_IDIOMA';
   cxtusuario     VARCHAR2(100) := 'IAX_USUARIO';
   cxtagente      VARCHAR2(100) := 'IAX_AGENTE';
   cxtempresa     VARCHAR2(100) := 'IAX_EMPRESA';
   cxtagenteprod  VARCHAR2(100) := 'IAX_AGENTEPROD';
   cxtterminal    VARCHAR2(100) := 'IAX_TERMINAL';
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;
   msgintern      t_iax_mensajes;

   /*************************************************************************
      Comproba que el idioma sea correcto sino hace un distinct a idomas y
      recupera el primero
   *************************************************************************/
   FUNCTION checkidioma(pidioma IN NUMBER)
      RETURN NUMBER IS
      vidioma        NUMBER;
      ncount         NUMBER;
   BEGIN
      BEGIN
         SELECT cidioma
           INTO vidioma
           FROM idiomas
          WHERE cidioma = pidioma;
      EXCEPTION
         WHEN OTHERS THEN
         	/*
            SELECT cidioma
              INTO vidioma
              FROM idiomas
             WHERE ROWNUM = 1; */
           Vidioma :=  PAC_parametros.f_parempresa_n(f_parinstalacion_n('EMPRESADEF'), 'IDIOMA_DEF');
      END;

      RETURN NVL(vidioma, 0);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 0;
   END checkidioma;

   /*************************************************************************
      Graba los errores que se produzcan en la base de datos
      param in ptobjeto  : objeto que produce el error
      param in pntraza   : n¿mero de traza
      param in ptdescrip : descripc¿n error
      param in pterror   : mensaje error
   *************************************************************************/
   PROCEDURE p_grabadberror(
      ptobjeto IN VARCHAR2,
      pntraza IN NUMBER,
      ptdescrip IN VARCHAR2,
      pterror IN VARCHAR2) IS
      vtraza         NUMBER := pntraza;
      vtobjeto       VARCHAR2(500) := SUBSTR(ptobjeto, 1, 500);
      vtdescrip      VARCHAR2(500) := SUBSTR(ptdescrip, 1, 500);
      vterror        VARCHAR2(2500) := SUBSTR(pterror, 1, 2500);
   BEGIN
      IF pntraza IS NULL THEN
         SELECT seq_error_tab_error.NEXTVAL
           INTO vtraza
           FROM DUAL;

         p_grabacontrol(vtobjeto, SUBSTR(vtdescrip, 1, 60), SUBSTR(vterror, 1, 2000));
      END IF;

      p_tab_error(f_sysdate, f_user, vtobjeto, vtraza, vtdescrip, vterror);
   EXCEPTION
      WHEN OTHERS THEN
         BEGIN
            p_tab_error(f_sysdate, f_user, SUBSTR('P_GrabaDBError ' || vtobjeto, 1, 500), 1,
                        vtobjeto || ' ' || pntraza || ' no ha graba error',
                        SQLCODE || ' ' || SQLERRM);
         EXCEPTION
            WHEN OTHERS THEN
               SELECT seq_error_tab_error.NEXTVAL
                 INTO vtraza
                 FROM DUAL;

               p_tab_error(f_sysdate, f_user, SUBSTR('P_GrabaDBError ' || vtobjeto, 1, 500),
                           vtraza, vtobjeto || ' ' || pntraza || ' no ha graba error',
                           SQLCODE || ' ' || SQLERRM);
         END;
   END p_grabadberror;

   /*************************************************************************
      Graba los controles trazas ejecuci¿n procesos
      param in ptobjeto : objeto que produce el error
      param in pdonde   : lugar donde se ha producido el error
      param in psuceso  : descripc¿n error
   *************************************************************************/
   PROCEDURE p_grabacontrol(ptobjeto IN VARCHAR2, pdonde IN VARCHAR2, psuceso IN VARCHAR2) IS
      --INI - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
	  --vid VARCHAR2(200) := SUBSTR(ptobjeto, 1, 200);
	  vid VARCHAR2(200) := SUBSTR(ptobjeto, 1, 30);
	  --FIN - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
      vdonde         VARCHAR2(60) := SUBSTR(pdonde, 1, 60);
      vsuceso        VARCHAR2(2000) := SUBSTR(psuceso, 1, 2000);
      vtraza         NUMBER;
   BEGIN
      p_control_error(vid, vdonde, vsuceso);
   EXCEPTION
      WHEN OTHERS THEN
         BEGIN
            p_tab_error(f_sysdate, f_user, 'P_GrabaControl', 1,
                        ptobjeto || ' ' || pdonde || ' no ha graba control',
                        SQLCODE || ' ' || SQLERRM);
         EXCEPTION
            WHEN OTHERS THEN
               SELECT seq_error_tab_error.NEXTVAL
                 INTO vtraza
                 FROM DUAL;

               p_tab_error(f_sysdate, f_user, SUBSTR('P_GrabaControl ' || ptobjeto, 1, 500),
                           vtraza, ptobjeto || ' ' || pdonde || ' no ha graba control',
                           SQLCODE || ' ' || SQLERRM);
         END;
   END p_grabacontrol;

   /*************************************************************************
      Recupera el valor de un par¿metro de instalaci¿n de tipo alfanum¿rico.
      param in pcparname   : c¿digo de par¿metro
      return               : Valor del par¿metro
                             NULL si no existe
   *************************************************************************/
   FUNCTION f_get_parinstalacion_t(ptparname IN VARCHAR2)
      RETURN VARCHAR2 IS
   BEGIN
      IF ptparname IS NULL THEN
         RETURN NULL;
      END IF;

      RETURN f_parinstalacion_t(ptparname);
   END;

   /*************************************************************************
      Recupera el valor de un par¿metro de instalaci¿n de tipo fecha.
      param in pcparname   : c¿digo de par¿metro
      return               : Valor del par¿metro
                             NULL si no existe
   *************************************************************************/
   FUNCTION f_get_parinstalacion_f(ptparname IN VARCHAR2)
      RETURN DATE IS
   BEGIN
      IF ptparname IS NULL THEN
         RETURN NULL;
      END IF;

      RETURN f_parinstalacion_f(ptparname);
   END;

   /*************************************************************************
      Recupera el valor de un par¿metro de instalaci¿n de tipo num¿rico.
      param in pcparname   : c¿digo de par¿metro
      return               : Valor del par¿metro
                             0 si no existe
   *************************************************************************/
   FUNCTION f_get_parinstalacion_n(ptparname IN VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      IF ptparname IS NULL THEN
         RETURN 0;
      END IF;

      RETURN f_parinstalacion_n(ptparname);
   END;

   /*************************************************************************
      Recupera el valor de un par¿metro de conexi¿n.
      param in pcparname   : c¿digo de par¿metro
      return               : Valor del par¿metro
                             0 si no existe
   *************************************************************************/
   FUNCTION f_get_parconexion(ptparname IN VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      IF ptparname IS NULL THEN
         RETURN NULL;
      END IF;

      RETURN f_parconexion(ptparname);
   END;

   /*************************************************************************
      Crea la variable contexto seg¿n parametros
      param in pcnomcontexto   : nombre del contexto
      param in pcnomparametro  : nombre del parametro
      param in pvalparametro   : valor del parametro
      param in out mensajes    : mensaje error
   *************************************************************************/
   PROCEDURE p_contextoasignaparametro(
      pcnomcontexto IN VARCHAR2,
      pcnomparametro IN VARCHAR2,
      pvalparametro IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes) IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(100)
         := 'pcnomcontexto=' || pcnomcontexto || ' pcnomparametro=' || pcnomparametro
            || ' pvalparametro=' || pvalparametro;
      vobject        VARCHAR2(200) := 'PAC_MD_COMMON.P_Contextoasignaparametro';
   BEGIN
      pac_contexto.p_contextoasignaparametro(pcnomcontexto, pcnomparametro, pvalparametro);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
   END p_contextoasignaparametro;

   /*************************************************************************
      Recupera la variable contexto seg¿n parametros
      param in pcnomcontexto   : nombre del contexto
      param in pcnomparametro  : nombre del parametro
      param in out mensajes    : mensaje error
   *************************************************************************/
   FUNCTION f_contextovalorparametro(
      pcnomcontexto IN VARCHAR2,
      pcnomparametro IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500)
                  := 'pcnomcontexto=' || pcnomcontexto || ' pcnomparametro=' || pcnomparametro;
      vobject        VARCHAR2(200) := 'PAC_MD_COMMON.F_Contextovalorparametro';
   BEGIN
      RETURN pac_contexto.f_contextovalorparametro(pcnomcontexto, pcnomparametro);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_contextovalorparametro;

   /***********************************************************************
      Dado un n¿mero de p¿liza devuelve el c¿digo del ramo
      param in pnpoliza    : n¿mero p¿liza
      param inout mensajes : mensajes de error
      return               : c¿digo ramo o nulo si se produce error
   ***********************************************************************/
   FUNCTION f_get_polramo(pnpoliza IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      cram           NUMBER := NULL;
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(200) := 'pnpoliza=' || pnpoliza;
      vobject        VARCHAR2(200) := 'PAC_MD_COMMON.F_Get_PolRamo';
   BEGIN
      SELECT s.cramo
        INTO cram
        FROM seguros s
       WHERE s.npoliza = pnpoliza;

      RETURN cram;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_polramo;

   /***********************************************************************
      Dado un c¿digo de seguro
      param in psseguro     : c¿digo seguro
      param in pmode        : mode consulta EST POL
      param out onpoliza    : n¿mero p¿liza
      param out oncertif    : n¿mero certificado
      param in out mensajes : mensajes error
   ***********************************************************************/
   PROCEDURE f_get_npoliza(
      psseguro IN NUMBER,
      pmode IN VARCHAR2,
      onpoliza OUT NUMBER,
      oncertif OUT NUMBER,
      mensajes IN OUT t_iax_mensajes) IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500) := 'psseguro=' || psseguro;
      vobject        VARCHAR2(200) := 'PAC_MD_COMMON.F_Get_NPoliza';
   BEGIN
      IF pmode = 'POL' THEN
         SELECT npoliza, ncertif
           INTO onpoliza, oncertif
           FROM seguros
          WHERE sseguro = psseguro;
      ELSE
         SELECT npoliza, ncertif
           INTO onpoliza, oncertif
           FROM estseguros
          WHERE sseguro = psseguro;
      END IF;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
   END f_get_npoliza;

   /***********************************************************************
      Formatea la cuenta bancaria
      param in ctipban : tipo cuenta
      param in cbancar : cuenta bancaria
      return           : cuenta formateada si ha podido aplicar el formato
                         sino devuelve la cuenta
   ***********************************************************************/
   FUNCTION f_formatccc(ctipban IN NUMBER, cbancar IN VARCHAR2)
      RETURN VARCHAR2 IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500) := 'ctipban=' || ctipban || ' cbancar=' || cbancar;
      vobject        VARCHAR2(200) := 'PAC_MD_COMMON.F_FormatCCC';
      RESULT         VARCHAR2(500);
      nerr           NUMBER;
      mensajes       t_iax_mensajes;
   BEGIN
      nerr := f_formatoccc(cbancar, RESULT, ctipban);

      IF RESULT IS NULL THEN
         RETURN cbancar;
      END IF;

      RETURN RESULT;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_formatccc;

   /*************************************************************************
      Establece una variable de contexto
      param in clave         : clave del contexto
      param in valor         : valor del contexto
      param in out mensajes  : colecci¿n de mensajes
   *************************************************************************/
   PROCEDURE p_set_contextparam(
      clave IN VARCHAR2,
      valor IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes) IS
      pctxt          VARCHAR2(100) := pac_md_common.f_get_parinstalacion_t('CONTEXT_USER');
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500) := 'clave=' || clave || ' valor=' || valor;
      vobject        VARCHAR2(200) := 'PAC_MD_COMMON.P_Set_ContextParam';
   BEGIN
      pac_md_common.p_contextoasignaparametro(pctxt, clave, valor, mensajes);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
   END p_set_contextparam;

   /*************************************************************************
      Devuelve valor variable de contexto
      param in clave         : clave del contexto
      param in out mensajes  : colecci¿n de mensajes
      return                 : valor del contexto
   *************************************************************************/
   FUNCTION f_get_contextparam(clave IN VARCHAR2, mensajes IN OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      pctxt          VARCHAR2(100) := pac_md_common.f_get_parinstalacion_t('CONTEXT_USER');
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500) := 'clave=' || clave;
      vobject        VARCHAR2(200) := 'PAC_MD_COMMON.F_Get_ContextParam';
   BEGIN
      RETURN pac_md_common.f_contextovalorparametro(pctxt, clave, mensajes);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_contextparam;

/*************************************************************************
       Define el idioma como contexto
       param in valor         : valor del contexto
    *************************************************************************/
   PROCEDURE p_set_cxtidioma(valor IN NUMBER) IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500) := 'valor=' || valor;
      vobject        VARCHAR2(200) := 'PAC_MD_COMMON.P_Set_CXTIdioma';
   BEGIN
      p_set_contextparam(cxtidioma, valor, msgintern);
      vpasexec := 2;
      --Asignaci¿ context especial per F_USU_IDIOMA
      p_set_contextparam('usu_idioma', valor, msgintern);
   --
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000005, vpasexec, vparam);
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000006, vpasexec, vparam);
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
   END p_set_cxtidioma;

   /*************************************************************************
      Recupera el idioma como contexto
      return   : valor del contexto
   *************************************************************************/
   FUNCTION f_get_cxtidioma
      RETURN NUMBER IS
      vtmp           VARCHAR2(10);
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_COMMON.F_Get_CXTIdioma';
   BEGIN
      vtmp := f_get_contextparam(cxtidioma, msgintern);
      vtmp := pac_md_common.checkidioma(vtmp);
      RETURN NVL(vtmp, 0);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_cxtidioma;

   /*************************************************************************
      Define el usuario como contexto
      param in valor  : valor del contexto
   *************************************************************************/
   PROCEDURE p_set_cxtusuario(valor IN VARCHAR2) IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500) := 'valor=' || valor;
      vobject        VARCHAR2(200) := 'PAC_MD_COMMON.P_Set_CXTUsuario';
   BEGIN
      p_set_contextparam(cxtusuario, valor, msgintern);
      vpasexec := 2;
      --Asignaci¿ context especial per F_USER
      p_set_contextparam('nombre', valor, msgintern);
   --
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000005, vpasexec, vparam);
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000006, vpasexec, vparam);
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
   END p_set_cxtusuario;

   /*************************************************************************
      Recupera el usuario como contexto
      return   : valor del contexto
   *************************************************************************/
   FUNCTION f_get_cxtusuario
      RETURN VARCHAR2 IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_COMMON.P_Set_CXTUsuario';
   BEGIN
      RETURN f_get_contextparam(cxtusuario, msgintern);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_cxtusuario;

   /*************************************************************************
      Define el agente como contexto
      param in valor  : valor del contexto
   *************************************************************************/
   PROCEDURE p_set_cxtagente(valor IN NUMBER) IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500) := 'valor=' || valor;
      vobject        VARCHAR2(200) := 'PAC_MD_COMMON.P_Set_CXTAgente';
   BEGIN
      p_set_contextparam(cxtagente, valor, msgintern);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000005, vpasexec, vparam);
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000006, vpasexec, vparam);
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
   END p_set_cxtagente;

   /*************************************************************************
      Recupera el agente como contexto
      return   : valor del contexto
   *************************************************************************/
   FUNCTION f_get_cxtagente
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_COMMON.P_Set_CXTAgente';
   BEGIN
      RETURN f_get_contextparam(cxtagente, msgintern);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_cxtagente;

   /*************************************************************************
      Define el agente para producci¿ncomo contexto
      param in valor  : valor del contexto
   *************************************************************************/
   PROCEDURE p_set_cxtagenteprod(valor IN NUMBER) IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500) := 'valor=' || valor;
      vobject        VARCHAR2(200) := 'PAC_MD_COMMON.P_Set_CXTAgenteProd';
   BEGIN
      p_set_contextparam(cxtagenteprod, valor, msgintern);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000005, vpasexec, vparam);
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000006, vpasexec, vparam);
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
   END p_set_cxtagenteprod;

   /*************************************************************************
      Recupera el agente para producci¿n como contexto
      return   : valor del contexto
   *************************************************************************/
   FUNCTION f_get_cxtagenteprod
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_COMMON.F_Get_CXTAgenteProd';
   BEGIN
      RETURN f_get_contextparam(cxtagenteprod, msgintern);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_cxtagenteprod;

   /*************************************************************************
      Define la empresa como contexto
      param in valor  : valor del contexto
   *************************************************************************/
   PROCEDURE p_set_cxtempresa(valor IN NUMBER) IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500) := 'valor=' || valor;
      vobject        VARCHAR2(200) := 'PAC_MD_COMMON.P_Set_CXTEmpresa';
   BEGIN
      p_set_contextparam(cxtempresa, valor, msgintern);
      vpasexec := 2;
      --Asignaci¿ context especial per f_empresel
      p_set_contextparam('empresasel', valor, msgintern);
      vpasexec := 3;
      p_set_contextparam('empresa', valor, msgintern);
      vpasexec := 4;
      p_set_contextparam('multiempres', valor, msgintern);
   --
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000005, vpasexec, vparam);
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000006, vpasexec, vparam);
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
   END p_set_cxtempresa;

   /*************************************************************************
      Recupera la empresa como contexto
      return   : valor del contexto
   *************************************************************************/
   FUNCTION f_get_cxtempresa
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_COMMON.P_Set_CXTEmpresa';
   BEGIN
      RETURN f_get_contextparam(cxtempresa, msgintern);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_cxtempresa;

   /***********************************************************************
      Devuelve el modo de trabajo: POL, EST
      param in out mensajes : mensajes error
      return                : varchar2
   ***********************************************************************/
   FUNCTION f_get_ptablas(pmodo IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vpasexec       NUMBER := 1;
      vobject        VARCHAR2(200) := 'PAC_MD_COMMON.F_Get_ptablas';
      vparam         VARCHAR2(500) := 'pmodo : ' || pmodo;
   BEGIN
      RETURN ff_ptablas(pmodo);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
   END f_get_ptablas;

-- JGM - 06/10/2008 -
    /*************************************************************************
       Define el terminal como contexto
       param in valor  : valor del contexto
    *************************************************************************/
   PROCEDURE p_set_cxtterminal(valor IN VARCHAR2) IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500) := 'valor=' || valor;
      vobject        VARCHAR2(200) := 'PAC_MD_COMMON.P_Set_CXTterminal';
   BEGIN
      p_set_contextparam(cxtterminal, valor, msgintern);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000005, vpasexec, vparam);
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000006, vpasexec, vparam);
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
   END p_set_cxtterminal;

   /*************************************************************************
      Recupera el terminal como contexto
      return   : valor del contexto
   *************************************************************************/
   FUNCTION f_get_cxtterminal
      RETURN VARCHAR2 IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_COMMON.P_Set_CXTterminal';
   BEGIN
      RETURN f_get_contextparam(cxtterminal, msgintern);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_cxtterminal;

    -- BUG 8339
    /***************************************************************************
     Funci¿n que retornar¿ el c¿digo de proceso temporal para la gesti¿n del proceso de cartera.
     Par¿metros:
      Salida :
       Mensajes   OUT T_IAX_MENSAJES
     Retorna: el n¿mero de la secuencia
   *****************************************************************************/
   FUNCTION f_get_proceso(psproces OUT NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vsprocar       NUMBER;
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_COMMON.F_GET_PROCESO';
   BEGIN
      --Deber¿ retornar el nextval de la secuencia sprocar
      SELECT sprocar.NEXTVAL
        INTO psproces
        FROM DUAL;

      RETURN(vsprocar);
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_proceso;

-- Bug 11308 - 01/12/2009 - AMC
   /*************************************************************************
      FUNCTION f_extrae_npoliza
        Extrae el n¿ de poliza del c¿digo de cuenta interno
        param in pncontinter   : C¿digo de cuenta interno
        return             : N¿ poliza
   *************************************************************************/
   FUNCTION f_extrae_npoliza(pncontinter IN VARCHAR2)
      RETURN NUMBER IS
      vsprocar       NUMBER;
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500) := NULL;
      vobject        VARCHAR2(200) := 'f_extrae_npoliza';
      vnpoliza       NUMBER;
   BEGIN
      IF pncontinter IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnpoliza := pac_propio.f_extrae_npoliza(pncontinter, f_get_cxtempresa());

      IF vnpoliza IS NULL THEN
         RAISE e_object_error;
      END IF;

      RETURN vnpoliza;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_extrae_npoliza;

--Fi Bug 11308 - 01/12/2009 - AMC

--Ini CONF-219 AP
   /*************************************************************************
      FUNCTION f_extrae_npoliza
        Extrae el n¿ de poliza del c¿digo de cuenta interno
        param in pncontinter   : C¿digo de cuenta interno
        return             : N¿ poliza
   *************************************************************************/
   FUNCTION F_EXTRAE_NPOLCONTRA(pncontrato IN VARCHAR2)
      RETURN NUMBER IS
      vsprocar       NUMBER;
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500) := NULL;
      vobject        VARCHAR2(200) := 'f_extrae_npoliza';
      vnpoliza       NUMBER;
   BEGIN
      IF pncontrato IS NULL THEN
         RAISE e_param_error;
      END IF;
      vnpoliza := pac_propio.F_EXTRAE_NPOLCONTRA(pncontrato, f_get_cxtempresa());

      IF vnpoliza IS NULL THEN
         RAISE e_object_error;
      END IF;

      RETURN vnpoliza;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END F_EXTRAE_NPOLCONTRA;

--Fi CONF-219 AP

   -- Bug 15750 - FAL - 27/08/2010 - Permitir seleccionar varios productos en el proceso domiciliaci¿n
    /***************************************************************************
     Funci¿n que retornar¿ el c¿digo de proceso temporal para la gesti¿n del proceso de domiciliaci¿n.
     Par¿metros:
      Salida :
       Mensajes   OUT T_IAX_MENSAJES
     Retorna: el n¿mero de la secuencia
   *****************************************************************************/
   FUNCTION f_get_procesodom(psproces OUT NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vsprocar       NUMBER;
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_COMMON.F_GET_PROCESODOM';
   BEGIN
      --Deber¿ retornar el nextval de la secuencia sprocar
      SELECT sprodom.NEXTVAL
        INTO psproces
        FROM DUAL;

      RETURN(vsprocar);
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_procesodom;

-- FI Bug 15750 - FAL - 27/08/2010 - Permitir seleccionar varios productos en el proceso domiciliaci¿n
   FUNCTION f_obtener_formatos_moneda(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vsprocar       NUMBER;
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_COMMON.f_obtener_formatos_moneda';
      cur            sys_refcursor;
   BEGIN
      cur := pac_eco_monedas.f_obtener_formatos_moneda;

      IF cur IS NULL THEN
         RAISE e_object_error;
      END IF;

      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_obtener_formatos_moneda;

   FUNCTION f_obtener_formatos_moneda1(
      pmoneda IN eco_codmonedas.cmoneda%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vsprocar       NUMBER;
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_COMMON.f_obtener_formatos_moneda1';
      varret         eco_codmonedas.patron%TYPE;
   BEGIN
      varret := pac_eco_monedas.f_obtener_formatos_moneda1(pmoneda);

      IF varret IS NULL THEN
         RAISE e_object_error;
      END IF;

      RETURN varret;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_obtener_formatos_moneda1;

   FUNCTION f_obtener_formatos_moneda2(
      pmoneda IN monedas.cmoneda%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vsprocar       NUMBER;
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_COMMON.f_obtener_formatos_moneda2';
      varret         eco_codmonedas.patron%TYPE;
   BEGIN
      varret := pac_eco_monedas.f_obtener_formatos_moneda2(pmoneda);

      IF varret IS NULL THEN
         RAISE e_object_error;
      END IF;

      RETURN varret;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(msgintern, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_obtener_formatos_moneda2;
END pac_md_common;

/

  --GRANT EXECUTE ON "AXIS"."PAC_MD_COMMON" TO "R_AXIS";
  --GRANT EXECUTE ON "AXIS"."PAC_MD_COMMON" TO "CONF_DWH";
  --GRANT EXECUTE ON "AXIS"."PAC_MD_COMMON" TO "PROGRAMADORESCSI";
