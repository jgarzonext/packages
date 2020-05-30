--------------------------------------------------------
--  DDL for Package Body PAC_IAX_MNTPREGUNPROD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_MNTPREGUNPROD" AS
/******************************************************************************
   NNOMBRE:       PAC_IAX_MNTPREGUNPROD
   PROPÓSITO: Funciones para mantenimiento preguntas por productos

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        07/04/2010   AMC              1. Creación del package.
   2.0        21/01/2013   JMF              0025441: RSA001 - Definición del taller de productos

******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*************************************************************************
      Busca preguntas por descripción
      param in ptpregun : texto de la pregunta
      param in pcidioma : código de idioma
      param out mensajes
      return : ref cursor

      Bug 13953 - 07/04/2010 - AMC
   *************************************************************************/
   FUNCTION f_get_preguntas(
      ptpregun IN VARCHAR2,
      pcidioma IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      texto          VARCHAR2(200);
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                        := 'paràmetres - PTPREGUN: ' || ptpregun || ' - PCIDIOMA:' || pcidioma;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPREGUNPROD.f_get_preguntas';
   BEGIN
      cur := pac_md_mntpregunprod.f_get_preguntas(ptpregun, pcidioma, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_preguntas;

   /*************************************************************************
      Recupera el texto de una pregunta
      param in pcpregun : codigo de la pregunta
      param in ptabla : producto/actividad/garantia
      param in psproduc : código producto
      param in pcactivi : codigo de actividad
      param in pcgarant : codigo de la garantia
      param in pcidioma : código de idioma
      param out pctipre : codigo tipo de respuesta
      param out pdescpreg : descripcion de la pregunta
      param out mensajes
      return : Código de error (0: operación correcta sino 1)

      Bug 13953 - 07/04/2010 - AMC
   *************************************************************************/
   FUNCTION f_get_descpregun(
      pcpregun IN NUMBER,
      ptabla IN VARCHAR2,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pcidioma IN NUMBER,
      pctippre OUT NUMBER,
      pdescpreg OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_error        NUMBER;
      v_result       VARCHAR2(300);
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'pcpregun=' || pcpregun || ', pcidioma=' || pcidioma;
      vobject        VARCHAR2(200) := 'PAC_MD_MNTPREGUNPROD.F_Get_DescPregun';
      ncount         NUMBER;
   BEGIN
      -- Inicialitzacions
      IF pcpregun IS NULL THEN
         RAISE e_param_error;
      END IF;

      v_error := pac_md_mntpregunprod.f_get_descpregun(pcpregun, ptabla, psproduc, pcactivi,
                                                       pcgarant, pcidioma, pctippre, pdescpreg,
                                                       mensajes);

      IF v_error <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN v_error;
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
   END f_get_descpregun;

   /*************************************************************************
      Recupera la lista con las diferentes respuestas
      param in pcpregun : codigo de la pregunta
      param in pctippre : codigo tipo de pregunta
      param in pcidioma : codigo de idioma
      param out mensajes : mensajes de error

      Bug 13953 - 08/04/2010 - AMC
   *************************************************************************/
   FUNCTION f_get_listrespue(
      pcpregun IN NUMBER,
      pctippre IN NUMBER,
      pcidioma IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      texto          VARCHAR2(300);
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'paràmetres - pcpregun: ' || pcpregun || ' - PCIDIOMA:' || pcidioma
            || ' - PCTIPPRE:' || pctippre;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPREGUNPROD.f_get_listrespue';
   BEGIN
      IF pcpregun IS NULL
         OR pctippre IS NULL THEN
         RAISE e_param_error;
      END IF;

      cur := pac_md_mntpregunprod.f_get_listrespue(pcpregun, pctippre, pcidioma, mensajes);

      IF cur IS NULL THEN
         RAISE e_object_error;
      END IF;

      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_listrespue;

    /*************************************************************************
      Asigna la pregunta a nivel de producto/actividad/garantia
      param in pcpregun : codigo de la pregunta
      param in ptabla : producto/actividad/garantia
      param in psproduc : código producto
      param in pcactivi : codigo de actividad
      param in pcgarant : codigo de la garantia
      param in pcpretip : tipo respuesta
      param in pnpreord : orden de la pregunta
      param in ptprefor : formula para cálculo respuesta
      param in pcpreobl : Obligatoria u opcional
      param in pnpreimp : Orden de impresión
      param in pcresdef : Respuesta por defecto
      param in pcofersn : Aparece en ofertas
      param in ptvalfor : fórmula para validación respuesta
      param in pcmodo   : Modo
      param in pcnivel  : Nivel, poliza o riesgo
      param in pctarpol : Retarificar
      param in pcvisible : Pregunta visible
      param in pcesccero : Certificado cero
      param in pcvisiblecol : Visible colectivos
      param in pcvisiblecert : Visible certificados
      param in pcrecarg : Recarga de preguntas
      param out mensajes : mensajes de error

      Bug 13953 - 14/04/2010 - AMC
   *************************************************************************/
   FUNCTION f_set_pregunta(
      pcpregun IN NUMBER,
      ptabla IN VARCHAR2,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pcpretip IN NUMBER,
      pnpreord IN NUMBER,
      ptprefor IN VARCHAR2,
      pcpreobl IN NUMBER,
      pnpreimp IN NUMBER,
      pcresdef IN NUMBER,
      pcofersn IN NUMBER,
      ptvalfor IN VARCHAR2,
      pcmodo IN NUMBER,
      pcnivel IN NUMBER,
      pctarpol IN NUMBER,
      pcvisible IN NUMBER,
      pcesccero IN NUMBER,
      pcvisiblecol IN NUMBER,
      pcvisiblecert IN NUMBER,
      pcrecarg IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      verror         NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000)
         := 'paràmetres - pcpregun:' || pcpregun || ' ptabla:' || ptabla || ' psproduc:'
            || psproduc || ' pcactivi:' || pcactivi || ' pcgarant:' || pcgarant
            || ' pcpretip:' || pcpretip || ' pnpreord:' || pnpreord || ' ptprefor:'
            || ptprefor || ' pcpreobl:' || pcpreobl || ' pnpreimp:' || pnpreimp
            || ' pcresdef:' || pcresdef || ' pcofersn:' || pcofersn || ' ptvalfor:'
            || ptvalfor || ' pcmodo:' || pcmodo || ' pcnivel:' || pcnivel || ' pctarpol:'
            || pctarpol || ' pcvisible:' || pcvisible || ' pcesccero:' || pcesccero
            || ' pcvisiblecol:' || pcvisiblecol || ' pcvisiblecert:' || pcvisiblecert
            || ' pcrecarg:' || pcrecarg;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPREGUNPROD.f_set_pregunta';
   BEGIN
      IF pcpregun IS NULL
         OR psproduc IS NULL
         OR pcofersn IS NULL
         OR ptabla IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF ptabla = 'PROD'
         AND pctarpol IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF ptabla = 'ACT'
         AND pcactivi IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF ptabla = 'GAR'
         AND(pcactivi IS NULL
             OR pcgarant IS NULL) THEN
         RAISE e_param_error;
      END IF;

      verror := pac_md_mntpregunprod.f_set_pregunta(pcpregun, ptabla, psproduc, pcactivi,
                                                    pcgarant, pcpretip, pnpreord, ptprefor,
                                                    pcpreobl, pnpreimp, pcresdef, pcofersn,
                                                    ptvalfor, pcmodo, pcnivel, pctarpol,
                                                    pcvisible, pcesccero, pcvisiblecol,
                                                    pcvisiblecert, pcrecarg, mensajes);

      IF verror <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
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
   END f_set_pregunta;

    /*************************************************************************
      Devuel los datos de una pregunta
      param in pcpregun : codigo de la pregunta
      param in ptabla : producto/actividad/garantia
      param in psproduc : código producto
      param in pcactivi : codigo de actividad
      param in pcgarant : codigo de la garantia
      param out propreguntas: preguntas producto
      param out actpreguntas: preguntas actividad
      param out garpreguntas: preguntas garantia
      param out mensajes: mensajes de error

      Bug 13953 - 14/04/2010 - AMC
   *************************************************************************/
   FUNCTION f_get_pregunta(
      pcpregun IN NUMBER,
      ptabla IN VARCHAR2,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      propreguntas OUT ob_iax_prodpreguntas,
      pactpreguntas OUT ob_iax_prodpregunacti,
      pgarpreguntas OUT ob_iax_prodpregunprogaran,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      verror         NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000)
         := 'paràmetres - pcpregun:' || pcpregun || ' ptabla:' || ptabla || ' psproduc:'
            || psproduc || ' pcactivi:' || pcactivi || ' pcgarant:' || pcgarant;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPREGUNPROD.f_get_pregunta';
      pcpretip       NUMBER;
      pnpreord       NUMBER;
      ptprefor       VARCHAR2(100);
      pcpreobl       NUMBER;
      pnpreimp       NUMBER;
      pcresdef       NUMBER;
      pcofersn       NUMBER;
      ptvalfor       VARCHAR2(100);
      pcmodo         VARCHAR2(1);
      pcnivel        VARCHAR2(1);
      pctarpol       NUMBER;
      pcvisible      NUMBER;
   BEGIN
      IF pcpregun IS NULL
         OR ptabla IS NULL
         OR psproduc IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF ptabla = 'ACT'
         AND pcactivi IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF ptabla = 'GAR'
         AND(pcactivi IS NULL
             OR pcgarant IS NULL) THEN
         RAISE e_param_error;
      END IF;

      verror := pac_md_mntpregunprod.f_get_pregunta(pcpregun, ptabla, psproduc, pcactivi,
                                                    pcgarant, propreguntas, pactpreguntas,
                                                    pgarpreguntas, mensajes);
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
   END f_get_pregunta;

    /*************************************************************************
      Borrar una pregunta
      param in pcpregun : codigo de la pregunta
      param in ptabla : producto/actividad/garantia
      param in psproduc : código producto
      param in pcactivi : codigo de actividad
      param in pcgarant : codigo de la garantia
      param out mensajes: mensajes de error

      Bug 13953 - 19/04/2010 - AMC
   *************************************************************************/
   FUNCTION f_del_pregunta(
      pcpregun IN NUMBER,
      ptabla IN VARCHAR2,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      verror         NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000)
         := 'paràmetres - pcpregun:' || pcpregun || ' ptabla:' || ptabla || ' psproduc:'
            || psproduc || ' pcactivi:' || pcactivi || ' pcgarant:' || pcgarant;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPREGUNPROD.f_del_pregunta';
   BEGIN
      IF pcpregun IS NULL
         OR ptabla IS NULL
         OR psproduc IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF ptabla = 'ACT'
         AND pcactivi IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF ptabla = 'GAR'
         AND(pcactivi IS NULL
             OR pcgarant IS NULL) THEN
         RAISE e_param_error;
      END IF;

      verror := pac_md_mntpregunprod.f_del_pregunta(pcpregun, ptabla, psproduc, pcactivi,
                                                    pcgarant, mensajes);

      IF verror <> 0 THEN
         -- Bug 0025441 - 21/01/2013 - JMF
         RAISE e_object_error;
      END IF;

      COMMIT;
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
   END f_del_pregunta;
END pac_iax_mntpregunprod;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_MNTPREGUNPROD" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_MNTPREGUNPROD" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_MNTPREGUNPROD" TO "PROGRAMADORESCSI";
