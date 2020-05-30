--------------------------------------------------------
--  DDL for Package Body PAC_IAX_GFI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_GFI" AS
/******************************************************************************
   NOMBRE:      PAC_IAX_GFI
   PROPÓSITO:   Funciones para el mantenimiento de las Formulas

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        15/04/2007   JMR               1. Creación del package.
   2.0        18/06/2009   DCT               2. Añadir nuevos métodos y nuevas funciones
                                                para gestionar las formulas.
   3.0        17/07/2009   AMC               3. Bug 10716 - Añadir nuevos métodos y nuevas funciones
                                                para gestionar los terminos.
   4.0        11/04/2012   JMB               4. Bug 21336 - Parametrización de parámetros por configuración
                                                y validación del gestor de formulas.
******************************************************************************/
   e_param_error  EXCEPTION;
   e_object_error EXCEPTION;

   /***********************************************************************
      Recupera la lista de las claves de las formulas.
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_claves(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vcursor        sys_refcursor;
      vobject        VARCHAR2(500) := 'PAC_IAX_GFI.F_Get_Claves';
      vparam         VARCHAR2(500) := 'parámetros  ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      --Recuperació dels paràmetres del producte.
      vcursor := pac_md_gfi.f_get_claves(mensajes);
      --Tot ok
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN vcursor;
      WHEN OTHERS THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN vcursor;
   END f_get_claves;

   /***********************************************************************
      Recupera los valores para el combo dejar rastro
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_rastro(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vcursor        sys_refcursor;
      vnumerr        NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_GFI.F_Get_Rastro';
   BEGIN
      --Recuperació dels paràmetres del producte.
      vcursor := pac_md_gfi.f_get_rastro(mensajes);
      --Tot ok
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN vcursor;
      WHEN OTHERS THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN vcursor;
   END f_get_rastro;

   /***********************************************************************
      Recupera los valores posibles para el cutili
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_utili(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vcursor        sys_refcursor;
      vnumerr        NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_GFI.F_Get_Utili';
   BEGIN
      --Recuperació dels paràmetres del producte.
      vcursor := pac_md_gfi.f_get_utili(mensajes);
      --Tot ok
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN vcursor;
      WHEN OTHERS THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN vcursor;
   END f_get_utili;

   /***********************************************************************
      Recupera las formulas que cumplan la condición
               param in pclave      : Clave de la formula
               param in pcodigo    : Código de la formula
               param in pformula    : Formula
               param in pcramo      : Código ramo
               param in pcrastro    : Código rastro
               param in pcutili    : Donde se utilizan las formulas
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_set_consulta(
      pclave IN NUMBER,
      pcodigo IN VARCHAR2,
      pformula IN VARCHAR2,
      pcramo IN NUMBER,
      pcrastro IN NUMBER,
      pcutili IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_gfitree IS
      vcursor        sys_refcursor;
      vnumerr        NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'pclave=' || pclave || ', pcodigo=' || pcodigo || ', pformula=' || pformula
            || ', pcramo=' || pcramo || ', pcrastro=' || pcrastro || ', pcutili=' || pcutili;
      vobject        VARCHAR2(200) := 'PAC_IAX_GFI.F_Set_Consulta';
      tree           t_iax_gfitree;
   BEGIN
      -- Verificación de los parámetros
      vcursor := pac_md_gfi.f_set_consulta(pclave, pcodigo, pformula, pcramo, pcrastro,
                                           pcutili, mensajes);
      vpasexec := 2;
      tree := pac_md_gfi.f_mounttree(vcursor, mensajes);
      COMMIT;
      RETURN tree;
   EXCEPTION
      WHEN e_param_error THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN NULL;
      WHEN e_object_error THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         ROLLBACK;
         RETURN NULL;
   END f_set_consulta;

   /***********************************************************************
      Recupera la información de la formula según el parámetro.
      param in number    : Clave formula
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_formula(pclave IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN ob_iax_gfiform IS
      vcursor        sys_refcursor;
      gfiform        ob_iax_gfiform := ob_iax_gfiform();
      gfiparam       t_iax_gfiparam := t_iax_gfiparam();
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'pclave=' || pclave;
      vobject        VARCHAR2(200) := 'PAC_IAX_GFI.F_Get_Formula';
   BEGIN
      --Recuperació dels paràmetres del producte.
      vcursor := pac_md_gfi.f_get_formula(pclave, mensajes);
      vpasexec := 2;

      LOOP
         FETCH vcursor
          INTO gfiform.clave, gfiform.codigo, gfiform.descripcion, gfiform.formula,
               gfiform.cramo, gfiform.cutili, gfiform.crastro, gfiform.sumatorio;

         EXIT WHEN vcursor%NOTFOUND;
      END LOOP;

      vpasexec := 3;
      vcursor := pac_md_gfi.f_get_parametros(pclave, mensajes);
      vpasexec := 4;

      LOOP
         gfiparam.EXTEND;
         gfiparam(gfiparam.LAST) := ob_iax_gfiparam();

         FETCH vcursor
          INTO gfiparam(gfiparam.LAST).clave, gfiparam(gfiparam.LAST).parametro,
               gfiparam(gfiparam.LAST).tparam;

         EXIT WHEN vcursor%NOTFOUND;
      END LOOP;

      vpasexec := 5;
      gfiform.params := gfiparam;
      --Tot ok
      RETURN gfiform;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN NULL;
   END f_get_formula;

   /***********************************************************************
      Graba la información de la formula
      param in  formula     : Objeto formula
      param out mensajes  : mensajes de error
      return              : NUMBER   :  1 indicando se ha producido un error
                                        0 ha ido correctamente
   ***********************************************************************/
   FUNCTION f_grabar_formula(
      formula ob_iax_gfiform,
      psclave OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_GFI.F_Grabar_Formula';
   BEGIN
      --Recuperació dels paràmetres del producte.
      vnumerr := pac_md_gfi.f_grabarformula(formula, psclave, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_param_error;
      END IF;

      --Tot ok
      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_grabar_formula;

   /***********************************************************************
      Recupera la lista de posibles parámetros a asignar a la formula.
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_lstparametros(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vcursor        sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_GFI.F_Get_LstParametros';
   BEGIN
      --Recuperació dels paràmetres del producte.
      vcursor := pac_md_gfi.f_get_lstparametros(mensajes);
      --Tot ok
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN vcursor;
      WHEN e_object_error THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN vcursor;
      WHEN OTHERS THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN vcursor;
   END f_get_lstparametros;

   /***********************************************************************
      Recupera los parámetros asociados a la formula.
      param in  pclave   : clave formula
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_parametros(pclave IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN t_iax_gfiparam IS
      vcursor        sys_refcursor;
      gfiparam       t_iax_gfiparam := t_iax_gfiparam();
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'pclave=' || pclave;
      vobject        VARCHAR2(200) := 'PAC_IAX_GFI.F_Get_Parametros';
      vclave         NUMBER;
      vparamr        VARCHAR2(30);
      vtparam        VARCHAR2(50);
   BEGIN
      IF pclave IS NULL THEN
         RAISE e_param_error;
      END IF;

      --Recuperació dels paràmetres del producte.
      vcursor := pac_md_gfi.f_get_parametros(pclave, mensajes);
      vpasexec := 2;

      LOOP
         FETCH vcursor
          INTO vclave, vparamr, vtparam;

         EXIT WHEN vcursor%NOTFOUND;
         gfiparam.EXTEND;
         gfiparam(gfiparam.LAST) := ob_iax_gfiparam();
         gfiparam(gfiparam.LAST).clave := vclave;
         gfiparam(gfiparam.LAST).parametro := vparamr;
         gfiparam(gfiparam.LAST).tparam := vtparam;
         EXIT WHEN vcursor%NOTFOUND;
      END LOOP;

      --Tot ok
      RETURN gfiparam;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN NULL;
   END f_get_parametros;

   /***********************************************************************
      Graba la información de los parámetros asociados a la formula.
      param in  T_IAX_GFIPARAM    : Lista parámetros formula
      param out mensajes  : mensajes de error
      return              : NUMBER   :  1 indicando se ha producido un error
                                        0 ha ido correctamente
   ***********************************************************************/
   FUNCTION f_set_grabarformparametros(pparams IN t_iax_gfiparam, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_GFI.F_Set_GrabarFormParametros';
   BEGIN
      IF pparams IS NULL THEN
         RAISE e_param_error;
      END IF;

      --Recuperació dels paràmetres del producte.
      vnumerr := pac_md_gfi.f_get_grabarformparam(pparams, mensajes);
      --Tot ok
      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_grabarformparametros;

   /***********************************************************************
      Elimina el parámetro asociado a la formula.
      param in  pclave   : clave formula
      param in  pparametro : parámetro a eliminar
      param out mensajes : mensajes de error
      return          : NUMBER   :  1 indicando se ha producido un error
                                       0 ha ido correctamente
   ***********************************************************************/
   FUNCTION f_set_eliminarformparam(
      pclave IN NUMBER,
      pparametro IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'pclave=' || pclave || ', pparametro=' || pparametro;
      vobject        VARCHAR2(200) := 'PAC_IAX_GFI.F_Set_EliminarFormParam';
   BEGIN
      IF pclave IS NULL THEN
         RAISE e_param_error;
      END IF;

      --Recuperació dels paràmetres del producte.
      vnumerr := pac_md_gfi.f_get_eliminarformparam(pclave, pparametro, mensajes);
      --Tot ok
      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_eliminarformparam;

   /***********************************************************************
      Recupera la lista de tipos para los términos.
      param out mensajes : Mensajes de salida
      return             : ref cursor

      Bug 10716 - 17/07/2009 - AMC
   ***********************************************************************/
   FUNCTION f_get_lsttipoterm(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_GFI.F_GET_LSTTIPOTERM';
      cur            sys_refcursor;
   BEGIN
      cur := pac_md_gfi.f_get_lsttipoterm(mensajes);

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

         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
   END f_get_lsttipoterm;

   /***********************************************************************
      Recupera la lista del origen del termino.
      param out mensajes : Mensajes de salida
      return             : ref cursor

      Bug 10716 - 17/07/2009 - AMC
   ***********************************************************************/
   FUNCTION f_get_lstorigen(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_GFI.F_GET_LSTORIGEN';
      cur            sys_refcursor;
   BEGIN
      cur := pac_md_gfi.f_get_lstorigen(mensajes);

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

         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
   END f_get_lstorigen;

   /***********************************************************************
      Recupera la lista de operadores.
      param out mensajes : Mensajes de salida
      return             : ref cursor

      Bug 10716 - 17/07/2009 - AMC
   ***********************************************************************/
   FUNCTION f_get_lstoperador(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_GFI.F_GET_LSTOPERADOR';
      cur            sys_refcursor;
   BEGIN
      cur := pac_md_gfi.f_get_lstoperador(mensajes);

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

         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
   END f_get_lstoperador;

   /***********************************************************************
      Recupera la información de los términos.
      param in ptermino : Código identificativo del término
      param in ptipo : Tipo de término (T=Tabla, P=Parámetro, F=Fórmula)
      param in porigen : Origen del término
      param in ptdesc : Descripción del término
      param in poperador : Indica si el termino es un operador o función (0= No, 1= Sí)
      param out mensajes : Mensajes de salida
      return             : sys_refcursor

      Bug 10716 - 17/07/2009 - AMC
   ***********************************************************************/
   FUNCTION f_get_terminos(
      ptermino IN VARCHAR2,
      ptipo IN VARCHAR2,
      porigen IN NUMBER,
      ptdesc IN VARCHAR2,
      poperador IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'ptermino:' || ptermino || ' ptipo:' || ptipo || ' porigen:' || porigen
            || ' ptdesc:' || ptdesc || ' poperador:' || poperador;
      vobject        VARCHAR2(200) := 'PAC_IAX_GFI.F_GET_TERMINOS';
      cur            sys_refcursor;
   BEGIN
      cur := pac_md_gfi.f_get_terminos(ptermino, ptipo, porigen, ptdesc, poperador, mensajes);

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

         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
   END f_get_terminos;

   /***********************************************************************
      Recupera la información del término.
      param in ptermino : Código identificativo del término
      param out mensajes : Mensajes de salida
      return             : ref cursor

      Bug 10716 - 17/07/2009 - AMC
   ***********************************************************************/
   FUNCTION f_get_termino(ptermino IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'ptermino:' || ptermino;
      vobject        VARCHAR2(200) := 'PAC_IAX_GFI.F_GET_TERMINO';
      cur            sys_refcursor;
   BEGIN
      cur := pac_md_gfi.f_get_termino(ptermino, mensajes);

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

         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
   END f_get_termino;

   /***********************************************************************
      Grava la información de los términos.
      param in ptermino : Código identificativo del término
      param in poldterm : Código identificativo del término del antiguo termino
      param in ptipo    : Tipo de término (T=Tabla, P=Parámetro, F=Fórmula)
      param in porigen  : Origen del término
      param in ptdesc   : Descripción del término
      param in poperador : Indica si el termino es un operador o función (0= No, 1= Sí)
      param in pisnew   : 1 es un nuevo termino 0 ja existía
      param out mensajes : Mensajes de salida
      return            : 0 ha ido correctamente o bien el código de literal

      Bug 10716 - 17/07/2009 - AMC
   ***********************************************************************/
   FUNCTION f_grabartermino(
      ptermino IN VARCHAR2,
      ptipo IN VARCHAR2,
      porigen IN NUMBER,
      ptdesc IN VARCHAR2,
      poperador IN NUMBER,
      pisnew IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(400)
         := 'ptermino:' || ptermino || ' ptipo:' || ptipo || ' porigen:' || porigen
            || ' ptdesc:' || ptdesc || ' poperador:' || poperador || ' pisnew:' || pisnew;
      vobject        VARCHAR2(200) := 'PAC_MD_GFI.F_GRABARTERMINO';
      num_err        NUMBER;
   BEGIN
      num_err := pac_md_gfi.f_grabartermino(ptermino, ptipo, porigen, ptdesc, poperador,
                                            pisnew, mensajes);

      IF num_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_param_error;
      END IF;

      COMMIT;
      RETURN num_err;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN -1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN -1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN -1;
   END f_grabartermino;

   /***********************************************************************
      Elimina el término.
      param in ptermino : Código identificativo del término
      param out mensajes : Mensajes de salida
      return            : 0 ha ido correctamente o bien el código de literal

      Bug 10716 - 17/07/2009 - AMC
   ***********************************************************************/
   FUNCTION f_eliminartermino(ptermino IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'ptermino:' || ptermino;
      vobject        VARCHAR2(200) := 'PAC_IAX_GFI.F_ELIMINARTERMINO';
      num_err        NUMBER;
   BEGIN
      num_err := pac_md_gfi.f_eliminartermino(ptermino, mensajes);

      IF num_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_param_error;
      END IF;

      COMMIT;
      RETURN num_err;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN -1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN -1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN -1;
   END f_eliminartermino;

   /***********************************************************************
      Recupera la información de las vigencias del término.
      param in ptermino : Código identificativo del término
      param out mensajes : Mensajes de salida
      return            : sys_refcursor

      Bug 10716 - 16/07/2009 - AMC
   ***********************************************************************/
   FUNCTION f_get_termvigencias(ptermino IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'ptermino:' || ptermino;
      vobject        VARCHAR2(200) := 'PAC_MD_GFI.F_GET_TERMVIGENCIAS';
      cur            sys_refcursor;
   BEGIN
      cur := pac_md_gfi.f_get_termvigencias(ptermino, mensajes);

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

         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
   END f_get_termvigencias;

   /***********************************************************************
      Elimina la vigencia del término.
      param in ptermino : Código identificativo del término
      param in pclave   : Código de la vigencia
      param out mensajes : Mensajes de salida
      return            : 0 ha ido correctamente o bien el código de literal

      Bug 10716 - 17/07/2009 - AMC
   ***********************************************************************/
   FUNCTION f_eliminartermvigen(
      ptermino IN VARCHAR2,
      pclave IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'ptermino:' || ptermino || ' pclave:' || pclave;
      vobject        VARCHAR2(200) := 'PAC_IAX_GFI.F_ELIMINARTERMVIGEN';
      num_err        NUMBER;
   BEGIN
      num_err := pac_md_gfi.f_eliminartermvigen(ptermino, pclave, mensajes);

      IF num_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_param_error;
      END IF;

      COMMIT;
      RETURN num_err;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN -1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN -1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN -1;
   END f_eliminartermvigen;

   /***********************************************************************
      Recupera la información de las vigencia del término.
      param in ptermino : Código identificativo del término
      param in pclave   : Código de la vigencia
      param out mensajes : Mensajes de salida
      return            : sys_refcursor

      Bug 10716 - 17/07/2009 - AMC
   ***********************************************************************/
   FUNCTION f_get_termvigencia(
      ptermino IN VARCHAR2,
      pclave IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'ptermino:' || ptermino || ' pclave:' || pclave;
      vobject        VARCHAR2(200) := 'PAC_IAX_GFI.F_GET_TERMVIGENCIA';
      cur            sys_refcursor;
   BEGIN
      cur := pac_md_gfi.f_get_termvigencia(ptermino, pclave, mensajes);

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

         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
   END f_get_termvigencia;

   /***********************************************************************
      Grabar la vigencia del término.
      param in ptermino : Código identificativo del término
      param in pclave   : Código de la vigencia
      param in pfechaefe : Fecha efecto
      param in pcvalor : Valor de la vigencia
      param in isNew : Indica si Nuevo 1 o 0 edición
      param out mensajes : Mensajes de salida
      return            : 0 ha ido correctamente o bien el código de literal

      Bug 10716 - 17/07/2009 - AMC
   ***********************************************************************/
   FUNCTION f_grabartermvig(
      ptermino IN VARCHAR2,
      pclave IN NUMBER,
      pfechaefe IN DATE,
      pcvalor IN FLOAT,
      isnew IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'ptermino:' || ptermino || ' pclave:' || pclave || ' pfechaefe:' || pfechaefe
            || ' pcvalor:' || pcvalor || ' isNew:' || isnew;
      vobject        VARCHAR2(200) := 'PAC_MD_GFI.F_ELIMINARTERMINO';
      num_err        NUMBER;
   BEGIN
      IF ptermino IS NULL
         OR pfechaefe IS NULL
         OR pcvalor IS NULL THEN
         RAISE e_param_error;
      END IF;

      num_err := pac_md_gfi.f_grabartermvig(ptermino, pclave, pfechaefe, pcvalor, isnew,
                                            mensajes);

      IF num_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_param_error;
      END IF;

      COMMIT;
      RETURN num_err;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN -1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN -1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN -1;
   END f_grabartermvig;

   /* Función que recupera la lista de tramos
       param in ptramo: código de tramo
             in pconcepto: concepto al que se aplica el tramo.
      param out:  mensajes de error
      return:  ref cursor  */
   FUNCTION f_consultram(ptramo IN NUMBER, pconcepto IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vcursor        sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_GFI.F_Consultram';
   BEGIN
      --Comprovació pas de paràmetres
      --IF ptramo IS NULL OR
      --  pconcepto IS NULL THEN
      --   RAISE e_param_error;
      --END IF;

      --Recuperación de la lista de los tramos
      vcursor := pac_md_gfi.f_consultram(ptramo, pconcepto, mensajes);
      --Todo ok
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN vcursor;
      WHEN e_object_error THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN vcursor;
      WHEN OTHERS THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN vcursor;
   END f_consultram;

   /* Función que elimna un tramo.
      param in ptramo: código de tramo
      param out:  mensajes de error
      return              : NUMBER   :  1 indicando se ha producido un error
                                        0 ha ido correctamente  */
   FUNCTION f_eliminartramo(ptramo IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_GFI.F_EliminarTramo';
      vnumerr        NUMBER;
   BEGIN
      --Comprovació pas de paràmetres
      IF ptramo IS NULL THEN
         RAISE e_param_error;
      END IF;

      --Recuperación de la lista de los tramos
      vnumerr := pac_md_gfi.f_eliminartramo(ptramo, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      --Todo ok
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN 1;
   END f_eliminartramo;

   /* Función que recupera la información de los tramos
       param in ptramo: código de tramo
      param out:  mensajes de error
      return:  ref cursor  */
   FUNCTION f_get_tramo(ptramo IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vcursor        sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_GFI.F_Get_Tramo';
   BEGIN
      --Comprovació pas de paràmetres
      IF ptramo IS NULL THEN
         RAISE e_param_error;
      END IF;

      --Recuperación de la información de los tramos
      vcursor := pac_md_gfi.f_get_tramo(ptramo, mensajes);
      --Todo ok
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN vcursor;
      WHEN e_object_error THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN vcursor;
      WHEN OTHERS THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN vcursor;
   END f_get_tramo;

   /* Función que grava la información de los tramos.
      param in ptramo: código de tramo
               pconcepto: Concepto al que se aplica el tramo
               pcptfranja: Concepto Franja
               pcptvalor: Concepto Valor
      param out:  mensajes de salida
      return : NUMBER   :  1 indicando se ha producido un error
                                        0 ha ido correctamente  */
   FUNCTION f_grabartramo(
      ptramo IN NUMBER,
      pconcepto IN VARCHAR2,
      pcptfranja IN VARCHAR2,
      pcptvalor IN VARCHAR2,
      pisnuevo IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vcursor        sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_GFI.F_GrabarTramo';
      vnumerr        NUMBER;
   BEGIN
      --Comprovació pas de paràmetres
      IF ptramo IS NULL
         OR pconcepto IS NULL THEN
         RAISE e_param_error;
      END IF;

      --Recuperación de la lista de los tramos
      vnumerr := pac_md_gfi.f_grabartramo(ptramo, pconcepto, pcptfranja, pcptvalor, pisnuevo,
                                          mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      --Todo ok
      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_grabartramo;

   /* Función que recupera la información de los tramos
      param in ptramo: código de tramo
     param out:  mensajes de error
     return:  ref cursor  */
   FUNCTION f_get_vigtramos(ptramo IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vcursor        sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_GFI.F_Get_VigTramos';
   BEGIN
      --Comprovació pas de paràmetres
      IF ptramo IS NULL THEN
         RAISE e_param_error;
      END IF;

      --Recuperación de la información de los tramos
      vcursor := pac_md_gfi.f_get_vigtramos(ptramo, mensajes);
      --Todo ok
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN vcursor;
      WHEN e_object_error THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN vcursor;
      WHEN OTHERS THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN vcursor;
   END f_get_vigtramos;

   /* Función que recupera la información del detalle del tramo
       param in pdetalletramo: código detalle tramo
      param out:  mensajes de error
      return:  ref cursor  */
   FUNCTION f_get_detvigtramos(pdetalletramo IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vcursor        sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_GFI.F_Get_DetVigTramos';
   BEGIN
      --Comprovació pas de paràmetres
      IF pdetalletramo IS NULL THEN
         RAISE e_param_error;
      END IF;

      --Recuperación de la información de los tramos
      vcursor := pac_md_gfi.f_get_detvigtramos(pdetalletramo, mensajes);
      --Todo ok
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN vcursor;
      WHEN e_object_error THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN vcursor;
      WHEN OTHERS THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN vcursor;
   END f_get_detvigtramos;

   /* Función que graba la información de la vigencia de los tramos
      param in ptramo: código de tramo
               pfechaefecto: Fecha efecto tramo
               pdetalletramo: Detalle tramo
      param out:  mensajes de salida
      return   : NUMBER   :  1 indicando se ha producido un error
                             0 ha ido correctamente  */
   FUNCTION f_grabarvigtram(
      ptramo IN NUMBER,
      pfechaefecto IN DATE,
      pdetalletramo IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_GFI.F_GrabarVigTram';
   BEGIN
      --Comprovació pas de paràmetres
      -- ptramo IS NULL OR
       -- pfechaefecto IS NULL THEN
          --pdetalletramo IS NULL THEN
       --  RAISE e_param_error;
      --END IF;

      --Recuperación de la información de los tramos
      vnumerr := pac_md_gfi.f_grabarvigtram(ptramo, pfechaefecto, pdetalletramo, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      --Todo ok
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN 1;
   END f_grabarvigtram;

   /* Función que graba la información de la vigencia de los tramos
     param in pdetalletramo: Código detalle tramo
              porden:        Número de orden
              pdesde:        Valor desde
              phasta:        Valor hasta
              pvalor:        Valor
     param out:  mensajes de salida
     return   : NUMBER   :  1 indicando se ha producido un error
                            0 ha ido correctamente  */
   FUNCTION f_grabardetvigtram(
      pdetalletramo IN NUMBER,
      porden IN NUMBER,
      pdesde IN NUMBER,
      phasta IN NUMBER,
      pvalor IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_GFI.F_GrabarDetVigTram';
   BEGIN
      --Comprovació pas de paràmetres
      IF pdetalletramo IS NULL
         OR pdesde IS NULL
         OR phasta IS NULL
         OR pvalor IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_gfi.f_grabardetvigtram(pdetalletramo, porden, pdesde, phasta, pvalor,
                                               mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      --Todo ok
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN 1;
   END f_grabardetvigtram;

   /* Función que elimna la vigencia de un tramo.
      param in ptramo: Código de tramo
               pdetalletramo: Código del detalle tramo
      param out:  mensajes de salida
      return              : NUMBER   :  1 indicando se ha producido un error
                                        0 ha ido correctamente  */
   FUNCTION f_eliminarvigencia(
      ptramo IN NUMBER,
      pdetalletramo IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_GFI.F_EliminarVigencia';
      vnumerr        NUMBER;
   BEGIN
      --Comprovació pas de paràmetres
      IF ptramo IS NULL
         OR pdetalletramo IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_gfi.f_eliminarvigencia(ptramo, pdetalletramo, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      --Todo ok
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN 1;
   END f_eliminarvigencia;

   /* Función que elimina el detalle de vigencia del tramo.
      param in pdetalletramo: Código del detalle tramo
               porden: Número de orden de secuencia
      param out:  mensajes de salida
      return              : NUMBER   :  1 indicando se ha producido un error
                                        0 ha ido correctamente  */
   FUNCTION f_eliminardetvigencia(
      pdetalletramo IN NUMBER,
      porden IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_GFI.F_EliminarDetVigencia';
      vnumerr        NUMBER;
   BEGIN
      --Comprovació pas de paràmetres
      IF pdetalletramo IS NULL
         OR porden IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_gfi.f_eliminardetvigencia(pdetalletramo, porden, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      --Todo ok
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN 1;
   END f_eliminardetvigencia;

   ----------
   --BUCLES--
   ----------
   /* Función que recupera la lista de bucles
      param in ptermino: Nombre del término
            in pniterac: Fórmula que nos dirá el número de iteraciones
            in poperacion: Tipo de operación (+, *)
      param out:  mensajes de error
      return:  ref cursor  */
   FUNCTION f_consultbucle(
      ptermino IN VARCHAR2,
      pniterac IN NUMBER,
      poperacion IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vcursor        sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_GFI.F_ConsultBucle';
   BEGIN
      --Comprovació pas de paràmetres
      --IF ptermino IS NULL OR
      --  pniterac IS NULL OR
      --  poperacion IS NULL THEN
      --   RAISE e_param_error;
      --END IF;

      --Recuperación de la lista de bucles
      vcursor := pac_md_gfi.f_consultbucle(ptermino, pniterac, poperacion, mensajes);
      --Todo ok
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN vcursor;
      WHEN e_object_error THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN vcursor;
      WHEN OTHERS THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN vcursor;
   END f_consultbucle;

   /* Función que elimina un bucle
      param in ptermino: Nombre del término
      param out:  mensajes de error
      return              : NUMBER   :  1 indicando se ha producido un error
                                        0 ha ido correctamente  */
   FUNCTION f_eliminarbucle(ptermino IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_GFI.F_EliminarBucle';
      vnumerr        NUMBER;
   BEGIN
      --Comprovació pas de paràmetres
      IF ptermino IS NULL THEN
         RAISE e_param_error;
      END IF;

      --Recuperación de la lista de los bucles
      vnumerr := pac_md_gfi.f_eliminarbucle(ptermino, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      --Todo ok
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN 1;
   END f_eliminarbucle;

   /* Función que recupera la lista de operación para el bucle
      param out:  mensajes de error
      return:  ref cursor  */
   FUNCTION f_get_lstoperacion(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vcursor        sys_refcursor;
      vnumerr        NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_GFI.F_Get_LstOperacion';
   BEGIN
      --Recuperació la lista de operacion para el bucle
      vcursor := pac_md_gfi.f_get_lstoperacion(mensajes);
      --Tot ok
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN vcursor;
      WHEN OTHERS THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN vcursor;
   END f_get_lstoperacion;

   /* Función que grava la información del bucle.
      param in ptermino: Nombre del término
               pniterac: Fórmula que nos dirá el número de iteraciones
               poperacion: Tipo de operación (+, *)
               isnew: 1 Indica que es nuevo y 0 Modificación
      param out:  mensajes de salida
      return              : NUMBER   :  1 indicando se ha producido un error
                                        0 ha ido correctamente  */
   FUNCTION f_grabarbucle(
      ptermino IN VARCHAR2,
      pniterac IN VARCHAR2,
      poperacion IN VARCHAR2,
      isnew IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vcursor        sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_GFI.F_GrabarBucle';
      vnumerr        NUMBER;
   BEGIN
      --Comprovació pas de paràmetres
      IF ptermino IS NULL
         OR pniterac IS NULL
         OR poperacion IS NULL
         OR isnew IS NULL THEN
         RAISE e_param_error;
      END IF;

      --Graba la información del bucle
      vnumerr := pac_md_gfi.f_grabarbucle(ptermino, pniterac, poperacion, isnew, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      --Todo ok
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN 1;
   END f_grabarbucle;

--------------
--EVALUACIóN--
--------------
/* Función que recupera los parámetros para poder evaluar una fórmula.
   param in pclave: Clave fórmula
   param out:  psession: Código único de sesión
               mensajes: Mensajes de salida
   return              : T_IAX_GFIPARAMTRANS   :  Objeto con los parámetros de evaluación.*/
   FUNCTION f_get_paramtrans(pclave IN NUMBER, psession OUT NUMBER, mensajes OUT t_iax_mensajes)
      RETURN t_iax_gfiparamtrans IS
      paramtrans     t_iax_gfiparamtrans;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_GFI.F_Get_Paramtrans';
      vnumerr        NUMBER;
   BEGIN
      --Recuperación de los parámetros para poder evaluar una fórmula.
      paramtrans := pac_md_gfi.f_get_paramtrans(pclave, psession, mensajes);
      --Tot ok
      RETURN paramtrans;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
      --RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
   --RETURN 1;
   END f_get_paramtrans;

   /* Función que grava la información de los parámetros
     param in psession: Número de sesión
              pparamact: Nombre parámetro actual
              pparampos: Nombre parámetro nuevo
              pvalor: Valor del parámetro
     param out: mensajes:  mensajes de salida
     return              : NUMBER   :  1 indicando se ha producido un error
                                       0 ha ido correctamente  */
   FUNCTION f_grabarparamtrans(
      psession IN NUMBER,
      pparamact IN VARCHAR2,
      pparampos IN VARCHAR2,
      pvalor IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vcursor        sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_GFI.F_GrabarParamtrans';
      vnumerr        NUMBER;
   BEGIN
      --Graba la información de los parámetros
      vnumerr := pac_md_gfi.f_grabarparamtrans(psession, pparamact, pparampos, pvalor,
                                               mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      --Todo ok
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN 1;
   END f_grabarparamtrans;

   /* Función que elimina la información de los parámetros
      param in psession: Número de sesión
               pparam: Nombre parámetro
      param out: mensajes:  mensajes de salida
      return              : NUMBER   :  1 indicando se ha producido un error
                                        0 ha ido correctamente  */
   FUNCTION f_eliminarparamtrans(
      psession IN NUMBER,
      pparam IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_GFI.F_EliminarParamtrans';
      vnumerr        NUMBER;
   BEGIN
      --Elimina la información de los parámetros
      vnumerr := pac_md_gfi.f_eliminarparamtrans(psession, pparam, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      --Todo ok
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN 1;
   END f_eliminarparamtrans;

   /* Función que Evalúa el resultado de la fórmula.
      param in psession: Código único de sesión
               pclave: Clave fórmula.
               pdebug: Modo de debug
      param out:  mensajes de salida
      return              : NUMBER   :  Valor devuelto por la fórmula  */
   FUNCTION f_evaluar(
      psession IN NUMBER,
      pclave IN NUMBER,
      pdebug IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_GFI.F_Evaluar';
      valor          NUMBER;
   BEGIN
      --Comprovació pas de paràmetres
      IF psession IS NULL
         OR pclave IS NULL
         OR pdebug IS NULL THEN
         RAISE e_param_error;
      END IF;

      --Evalua el resultado de la fórmula
      valor := pac_md_gfi.f_evaluar(psession, pclave, pdebug, mensajes);
      RETURN valor;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN NULL;
   END f_evaluar;

 ------------------
 --CÓDIGO FUNCIÓN--
 ------------------
/* Función que recupera el código de una fórmula.
   param in pclave: Clave fórmula
   param out:  mensajes: mensajes de error
   return:  ref cursor  */
   FUNCTION f_get_source(pclave IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vcursor        sys_refcursor;
      vnumerr        NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_GFI.F_Get_Source';
   BEGIN
      --Recuperación del código de una fórmula.
      vcursor := pac_md_gfi.f_get_source(pclave, mensajes);
      --Tot ok
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN vcursor;
      WHEN OTHERS THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN vcursor;
   END f_get_source;

-------------
--FUNCIONES--
-------------
/* Función que recupera la lista de procesos
  param out:  mensajes: mensajes de error
  return:  ref cursor  */
   FUNCTION f_get_lstfprocesos(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vcursor        sys_refcursor;
      vnumerr        NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_GFI.F_Get_Lstfprocesos';
   BEGIN
      --Recuperación la lista de procesos
      -- vcursor := PAC_MD_GFI.F_Get_Lstfprocesos(mensajes);

      --Tot ok
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN vcursor;
      WHEN OTHERS THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN vcursor;
   END f_get_lstfprocesos;

   /* Función que recupera la lista de procesos
     param out:  mensajes: mensajes de error
     return:  ref cursor  */
   FUNCTION f_get_lstfrefrescar(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vcursor        sys_refcursor;
      vnumerr        NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_GFI.F_Get_Lstfrefrescar';
   BEGIN
      --Recuperación la lista de procesos
      -- vcursor := PAC_MD_GFI.F_Get_Lstfrefrescar(mensajes);

      --Tot ok
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN vcursor;
      WHEN OTHERS THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN vcursor;
   END f_get_lstfrefrescar;

   /* Función que recupera la información de las funciones
     param in pclave: Clave fórmula
              pformula: Código fórmula
              ptproceso: Proceso que utiliza esta fórmula
              prefresca: Indica que la fórmula se tendría que refrescar
     param out:  mensajes: mensajes de error
     return:  ref cursor  */
   FUNCTION f_get_funciones(
      pclave IN NUMBER,
      pformula IN VARCHAR2,
      ptproceso IN VARCHAR2,
      prefresca IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vcursor        sys_refcursor;
      vnumerr        NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_GFI.F_Get_Funciones';
   BEGIN
      --Recuperación la lista de procesos
      -- vcursor := PAC_MD_GFI.F_Get_Funciones(pclave, pformula, ptproceso, prefresca, mensajes);

      --Tot ok
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN vcursor;
      WHEN OTHERS THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN vcursor;
   END f_get_funciones;

   /* Función que grava la información de la función
     param in pclave: Clave de la fórmula
              pcformula: Código de la fórmula
              ptproceso: Proceso que utiliza esta fórmula
              prefrescar: Indica que la fórmula se tendría que refrescar
     param out: mensajes:  mensajes de salida
     return              : NUMBER   :  1 indicando se ha producido un error
                                       0 ha ido correctamente  */
   FUNCTION f_grabarfuncion(
      pcclave IN NUMBER,
      pcformula IN VARCHAR2,
      ptproceso IN VARCHAR2,
      prefrescar IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_GFI.F_GrabarFuncion';
      vnumerr        NUMBER;
   BEGIN
      --Graba la información de los parámetros
      --vnumerr := PAC_MD_GFI.F_GrabarFuncion(pcclave, pcformula, ptproceso, prefrescar, mensajes);
      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      --Todo ok
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN 1;
   END f_grabarfuncion;

   /* Función que genera la formula determinada
     param in pcodigo: Código de la fórmula
              pcomenta: Si se generan comentarios
     param out: mensajes:  mensajes de salida
     return              : NUMBER   :  1 indicando se ha producido un error
                                       0 ha ido correctamente  */
   FUNCTION f_crea_funcion(
      pcodigo IN VARCHAR2,
      pcomenta IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_GFI.F_Crea_Funcion';
      vnumerr        NUMBER;
   BEGIN
      --Genera la fórmula determinada en la base de datos
      vnumerr := pac_md_gfi.f_crea_funcion(pcodigo, pcomenta, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      --Todo ok
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN 1;
   END f_crea_funcion;

   /* Función que comprueba que la fórmula sea correcta
     param in pformula: Texto de la fórmula
     param out: mensajes:  mensajes de salida
     return              : T_IAX_GFIERRORES   :  Objeto que contiene la información de los errores de la fórmula.*/
   FUNCTION f_checkformula(pformula IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN t_iax_gfierrores IS
      gfierrores     t_iax_gfierrores;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_GFI.F_Get_Paramtrans';
      vnumerr        NUMBER;
   BEGIN
      --Función que comprueba que la formula sea correcta
      --gfierrores := PAC_MD_GFI.F_ChekFormula (pformula, mensajes);

      --Tot ok
      RETURN gfierrores;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN NULL;
   END f_checkformula;

   FUNCTION f_tramo(
      pnsesion IN NUMBER,
      pfecha IN NUMBER,
      pntramo IN NUMBER,
      pbuscar IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      valor          NUMBER;
      ftope          DATE;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'pntramo=' || pntramo;
      vobject        VARCHAR2(200) := 'PAC_IAX_GFI.F_tramo';
   BEGIN
       --Comprovació pas de paràmetres
      /*IF pntramo IS NULL
         OR pbuscar IS NULL THEN
         RAISE e_param_error;
      END IF;*/
      valor := pac_md_gfi.f_tramo(pnsesion, pfecha, pntramo, pbuscar, mensajes);

      IF valor = -1 THEN
         RAISE e_object_error;
      END IF;

      RETURN valor;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN -1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN -1;
   END f_tramo;

   FUNCTION f_evaluar_formula(
      pnsesion IN NUMBER,
      pclave IN NUMBER,
      pdebug IN NUMBER,
      pparametros IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      valor          NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'pclave=' || pclave;
      vobject        VARCHAR2(200) := 'PAC_IAX_GFI.f_evaluar_formula';
      ob_iax_gfi     ob_iax_gfiparamvalor;
      pparametros2   t_iax_gfiparamvalor;
      pparametros1   t_iax_gfiparamsvalor;
      cadena         VARCHAR2(2000);
      v_decimal      VARCHAR2(1);
   BEGIN
      SELECT SUBSTR(VALUE, 1, 1)
        INTO v_decimal
        FROM nls_session_parameters
       WHERE parameter = 'NLS_NUMERIC_CHARACTERS';

      IF pparametros IS NOT NULL THEN
         pparametros1 := SPLIT(pparametros, '|');

         IF pparametros1 IS NOT NULL
            AND pparametros1.COUNT > 0 THEN
            pparametros2 := t_iax_gfiparamvalor();
            ob_iax_gfi := ob_iax_gfiparamvalor();

            FOR i IN pparametros1.FIRST .. pparametros1.LAST LOOP
               cadena := SUBSTR(pparametros1(i), 1, INSTR(pparametros1(i), ':', 1, 1) - 1);
               cadena := REPLACE(REPLACE(cadena, ',', v_decimal), '.', v_decimal);
               ob_iax_gfi.ctipo := TO_NUMBER(cadena);
               cadena := SUBSTR(pparametros1(i), INSTR(pparametros1(i), ':', 1, 1) + 1,
                                INSTR(pparametros1(i), ':', 1, 2)
                                - INSTR(pparametros1(i), ':', 1, 1) - 1);
               ob_iax_gfi.tnombre := cadena;
               cadena := SUBSTR(pparametros1(i), INSTR(pparametros1(i), ':', 1, 2) + 1,
                                LENGTH(pparametros1(i)));
               cadena := REPLACE(REPLACE(cadena, ',', v_decimal), '.', v_decimal);
               ob_iax_gfi.valor := TO_NUMBER(cadena);
               pparametros2.EXTEND();
               pparametros2(pparametros2.LAST) := ob_iax_gfi;
            END LOOP;
         END IF;
      END IF;

      valor := pac_md_gfi.f_evaluar_formula(NVL(pnsesion, 1), pclave, pdebug, pparametros2,
                                            mensajes);

      IF valor IS NULL THEN
         RAISE e_object_error;
      END IF;

      RETURN valor;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN NULL;
   END f_evaluar_formula;

   FUNCTION SPLIT(in_string VARCHAR2, delim VARCHAR2)
      RETURN t_iax_gfiparamsvalor IS
      i              NUMBER := 0;
      pos            NUMBER := 0;
      lv_str         VARCHAR2(100) := in_string;
      strings        t_iax_gfiparamsvalor := t_iax_gfiparamsvalor();
   BEGIN
      pos := INSTR(lv_str, delim, 1, 1);

      WHILE(pos != 0) LOOP
         strings.EXTEND();
         i := i + 1;
         strings(i) := SUBSTR(lv_str, 1, pos - 1);
         lv_str := SUBSTR(lv_str, pos + 1, LENGTH(lv_str));
         pos := INSTR(lv_str, delim, 1, 1);

         IF pos = 0 THEN
            strings(i + 1) := lv_str;
         END IF;
      END LOOP;

      RETURN strings;
   END SPLIT;
END pac_iax_gfi;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_GFI" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_GFI" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_GFI" TO "PROGRAMADORESCSI";
