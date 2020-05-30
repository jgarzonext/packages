--------------------------------------------------------
--  DDL for Package Body PAC_MD_GFI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_GFI" AS
/******************************************************************************
   NOMBRE:       PAC_MD_GFI
   PROPÓSITO: Contiene los métodos y funciones necesarias para poder realizar el mantenimiento de las tablas, realiza las llamadas a sentencias contra la base de datos o funciones propias para devolver la información a los paquetes de la capa interfase de Axis.

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        15/04/2008  CSI               1. Creación del package.
   2.0        19/06/2009  DCT               2. Añadir nuevos métodos y nuevas funciones
                                               para gestionar las formulas.
   3.0        17/07/2009  AMC               3. Bug 10716 - Añadir nuevos métodos y nuevas funciones
                                               para gestionar los terminos.
   4.0        11/04/2012   JMB              4. Bug 21336 - Parametrización de parámetros por configuración
                                               y validación del gestor de formulas.
******************************************************************************/

   /***********************************************************************
        Recupera la lista de las claves de las formulas.
        Se debe hacer la consulta sobre la tabla sgt_formulas recuperando los campos clave y la concatenación
        de los campos clave más codigo.
        param out mensajes : mensajes de error
        return             : ref cursor
     ***********************************************************************/
   FUNCTION f_get_claves(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_GFI.F_Get_Claves';
      vparam         VARCHAR2(500) := 'parámetros  ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      cur            sys_refcursor;
      squery         VARCHAR2(1000);
   BEGIN
      --Inicialitzacions
      squery := 'select clave, clave || '' ''|| codigo clave_codigo from sgt_formulas';
      vpasexec := 2;
      cur := pac_iax_listvalores.f_opencursor(squery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN cur;
      WHEN OTHERS THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN cur;
   END f_get_claves;

   /***********************************************************************
      Recupera los valores para el combo dejar rastro, la consulta de deberá realizar sobre la
      tabla valores con la clave valor 828.
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_rastro(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_GFI.F_Get_Rastro';
      vparam         VARCHAR2(500) := 'parámetros  ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      cur            sys_refcursor;
   -- squery      VARCHAR2(1000);
   BEGIN
      --Inicialitzacions

      --***  squery := 'select cidioma,catribu,tatribu from detvalores where cvalor=';
      vpasexec := 2;
      cur := pac_iax_listvalores.f_detvalores(828, mensajes);   -- F_OPENCURSOR(squery,mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN cur;
      WHEN OTHERS THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN cur;
   END f_get_rastro;

   /***********************************************************************
      Recupera los valores posibles para el cutili, la consulta de deberá realizar sobre la tabla valores
      con la clave valor 203.
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_utili(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_GFI.F_Get_Utili';
      vparam         VARCHAR2(500) := 'parámetros  ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      cur            sys_refcursor;
   --squery      VARCHAR2(1000);
   BEGIN
      --Inicialitzacions

      -- squery := 'select cidioma,tvalor from valores where cvalor=203';
      vpasexec := 2;
      cur := pac_iax_listvalores.f_detvalores(203, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN cur;
      WHEN OTHERS THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN cur;
   END f_get_utili;

   /***********************************************************************
      Recupera la información de la formula según el parámetro. Se debe hacer la consulta sobre la tabla sgt_formulas recuperando
      todos los campos enviando un ref cursor a la capa IAX.
      param in number    : Clave formula
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_formula(pclave IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_GFI.F_Get_Formula';
      vparam         VARCHAR2(500) := 'parámetros  clave: ' || pclave;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      cur            sys_refcursor;
      squery         VARCHAR2(1000);
   BEGIN
      -- Verificación de los parámetros
      IF pclave IS NULL THEN
         RAISE e_param_error;
      END IF;

      --Inicialitzacions
      squery :=
         'select s.clave,s.codigo,s.descripcion,s.formula,s.cramo,s.cutili,s.crastro,
                    (select decode(st.origen, 1, 5, 1) from sgt_term_form st where st.termino = s.codigo and
                         st.tipo =  ''F'') sumatorio
                   from sgt_formulas s
                   where s.clave = '
         || pclave;
      vpasexec := 2;
      cur := pac_iax_listvalores.f_opencursor(squery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN cur;
      WHEN OTHERS THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN cur;
   END f_get_formula;

   /***********************************************************************
      Recupera la lista de posibles parámetros a asignar a la formula. La consulta ha realizar para devolver el ref cursor.
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_lstparametros(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_GFI.F_Get_LstParametros';
      vparam         VARCHAR2(500) := 'parámetros  ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      cur            sys_refcursor;
      squery         VARCHAR2(1000);
   BEGIN
      --Inicialitzacions
      squery := 'select termino from sgt_term_form where origen = 2 order by termino';
      vpasexec := 2;
      cur := pac_iax_listvalores.f_opencursor(squery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN cur;
      WHEN OTHERS THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN cur;
   END f_get_lstparametros;

   /***********************************************************************
      Recupera los parámetros asociados a la formula, realizar la consulta sobre la tabla sgt_trans_formula con la condición de la clave.
      param in  pclave   : clave formula
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_parametros(pclave IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_GFI.F_Get_Parametros';
      vparam         VARCHAR2(500) := 'parámetros clave : ' || pclave;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      cur            sys_refcursor;
      squery         VARCHAR2(1000);
   BEGIN
      -- Verificación de los parámetros
      IF pclave IS NULL THEN
         RAISE e_param_error;
      END IF;

      --Inicialitzacions
      squery :=
         'select clave, parametro,(select tdesc from sgt_term_form where termino=parametro) tparam from sgt_trans_formula where clave = '
         || pclave;
      vpasexec := 2;
      cur := pac_iax_listvalores.f_opencursor(squery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN cur;
      WHEN OTHERS THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN cur;
   END f_get_parametros;

   /***********************************************************************
      Graba la información de los parámetros asociados a la formula, para guardar los parámetros en la tabla se debe hacer sobre
      la tabla sgt_trans_formula con la condición de la clave.

      param in  T_IAX_GFIPARAM    : Lista parámetros formula
      param out mensajes  : mensajes de error
      return              : NUMBER   :  1 indicando se ha producido un error
                                        0 ha ido correctamente
   ***********************************************************************/
   FUNCTION f_get_grabarformparam(pparams IN t_iax_gfiparam, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_GFI.F_Get_GrabarFormParam';
      vparam         VARCHAR2(500) := 'parámetros  ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      -- Verificación de los parámetros
      IF pparams IS NULL THEN
         RAISE e_param_error;
      END IF;

      FOR i IN 1 .. pparams.COUNT LOOP
         INSERT INTO sgt_trans_formula
                     (clave, parametro)
              VALUES (pparams(i).clave, pparams(i).parametro);

         vpasexec := vpasexec + 1;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_grabarformparam;

   /***********************************************************************
      Elimina el parámetro asociado a la formula, se debe hacer sobre la tabla sgt_trans_formula.
      param in  pclave   : clave formula
      param in  pparametro : parámetro a eliminar
      param out mensajes : mensajes de error
      retur              : NUMBER   :  1 indicando se ha producido un error
                                       0 ha ido correctamente

   ***********************************************************************/
   FUNCTION f_get_eliminarformparam(
      pclave IN NUMBER,
      pparametro IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_GFI.FF_Get_EliminarFormParam';
      vparam         VARCHAR2(500)
                        := 'parámetros clave : ' || pclave || ' ,pparametro : ' || pparametro;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      -- Verificación de los parámetros
      IF pclave IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pparametro IS NULL THEN
         RAISE e_param_error;
      END IF;

      --Inicialitzacions
      DELETE FROM sgt_trans_formula
            WHERE clave = pclave
              AND parametro = pparametro;

      vpasexec := 2;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_eliminarformparam;

   /***********************************************************************
      Recupera las formulas que cumplan la condición, se debe hacer la siguiente consulta para recuperar el ref cursor.
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
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_GFI.F_Set_Consulta';
      vparam         VARCHAR2(500)
         := 'parámetros ,clave : ' || pclave || ' ,codigo : ' || pcodigo || ' ,formula : '
            || pformula || ' , ramo :' || pcramo || ' crastro :' || pcrastro || ' , cutili : '
            || pcutili;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      cur            sys_refcursor;
      vcondicio      VARCHAR2(2000);
   BEGIN
      --Inicialitzacions
      vcondicio :=
         'select rownum+1 id,decode(lv,1,1,(rownum+1)-1) padre, lv, DESCRIPCION, clave, tipo
           from
            ( SELECT nvl(level,0)-1 padre, LEVEL lv, x.codigo DESCRIPCION, '
         || 'DECODE((SELECT g.refresca FROM GFI_FUNCIONES g WHERE cformula=x.codigo) ,1,''X'',0,''AFaccept'',''collaps'') tipo, x.clave FROM SGT_FORMULAS x ';

      IF pclave IS NOT NULL
         OR pcodigo IS NOT NULL
         OR pformula IS NOT NULL
         OR pcramo IS NOT NULL
         OR pcutili IS NOT NULL
         OR pcrastro IS NOT NULL
                                -- pcampo IS NOT NULL  OR ptabla IS NOT NULL
      THEN
         vcondicio := vcondicio || ' START WITH ';

         IF pclave IS NOT NULL THEN
            vcondicio := vcondicio || ' x.clave = ' || pclave || ' AND';
         END IF;

         IF pcodigo IS NOT NULL THEN
            vcondicio := vcondicio || ' x.codigo like ''' || pcodigo || ''' AND';
         END IF;

         IF pformula IS NOT NULL THEN
            vcondicio := vcondicio || ' x.formula like ''' || pformula || ''' AND';
         END IF;

         IF pcutili IS NOT NULL THEN
            vcondicio := vcondicio || ' x.cutili = ' || pcutili || ' AND';
         END IF;

         IF pcramo IS NOT NULL THEN
            vcondicio := vcondicio || ' x.cramo = ' || pcramo || ' AND';
         END IF;

         IF pcrastro IS NOT NULL THEN
            vcondicio := vcondicio || ' x.crastro = ' || pcrastro || ' AND';
         END IF;

         -- Eliminem l'últim AND
         vcondicio := SUBSTR(vcondicio, 1, LENGTH(vcondicio) - 3);
      END IF;

      vcondicio :=
         vcondicio
         || ' CONNECT BY Pac_Gfi.comprobar_token(UPPER(x.codigo), PRIOR UPPER(x.formula)) = 1 AND x.codigo <> PRIOR x.codigo)';
      vpasexec := 2;
      cur := pac_iax_listvalores.f_opencursor(vcondicio, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN cur;
      WHEN OTHERS THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN cur;
   END f_set_consulta;

   /***********************************************************************
      Graba la información de la formula, se debe ejecutar el siguiente código adaptándolo al estilo de programación de iAxis.

      param in  formula     : Objeto formula
      param out mensajes  : mensajes de error
      return              : NUMBER   :  1 indicando se ha producido un error
                                        0 ha ido correctamente
   ***********************************************************************/
   FUNCTION f_grabarformula(
      formula IN ob_iax_gfiform,
      psclave OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_GFI.F_GrabarFormula';
      vparam         VARCHAR2(500) := 'parámetros  ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      errs           NUMBER;
      ttexto         VARCHAR2(100);
      boton          NUMBER;
      vformu         sgt_formulas.formula%TYPE;
      vformu1        sgt_formulas.formula%TYPE;
      vcodi          sgt_formulas.codigo%TYPE;
      sclave         NUMBER;
      vcont          NUMBER;

      CURSOR c_formpare IS
         SELECT     LEVEL, x.codigo
               FROM sgt_formulas x
         START WITH x.codigo = vcodi
         CONNECT BY pac_gfi.comprobar_token(PRIOR UPPER(x.codigo), UPPER(x.formula)) = 1;
   BEGIN
      --Inicialitzacions
      -- *** errs:=pk_formulas.search_string(formula.formula, 'P', 1);
      vformu1 := formula.formula;
      errs := pk_formulas.search_string(vformu1, 'P', 1);

      IF errs > 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 108375);
         RAISE e_param_error;
      END IF;

      BEGIN
         SELECT formula, codigo
           INTO vformu, vcodi
           FROM sgt_formulas s
          WHERE s.clave = formula.clave;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            vcodi := NULL;
         WHEN OTHERS THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9000787);
            RAISE e_param_error;
      END;

      vpasexec := 2;

      IF (formula.clave IS NULL
          OR formula.clave = 0
          OR vcodi IS NULL)
         AND formula.codigo IS NOT NULL THEN   --Hem fet un insert
         IF formula.clave IS NULL THEN
            SELECT sgtformulas.NEXTVAL
              INTO sclave
              FROM DUAL;

            SELECT COUNT(1)
              INTO vcont
              FROM sgt_formulas sf
             WHERE sf.clave = sclave;

            IF vcont > 0 THEN
               SELECT MAX(clave) + 1
                 INTO sclave
                 FROM sgt_formulas;
            END IF;
         END IF;

         IF formula.descripcion IS NULL
            OR sclave IS NULL
            OR formula.formula IS NULL THEN
            RAISE e_param_error;
         END IF;

         INSERT INTO sgt_formulas
                     (clave, codigo, descripcion, formula,
                      cramo, cutili, crastro)
              VALUES (sclave, formula.codigo, formula.descripcion, formula.formula,
                      formula.cramo, formula.cutili, formula.crastro);

         -- Insertem o updategem també a la taula de termes la nova formula
         BEGIN
            INSERT INTO sgt_term_form
                        (termino, tipo, origen,
                         tdesc, operador)
                 VALUES (formula.codigo, 'F', DECODE(formula.sumatorio, 1, 5, 1),
                         formula.descripcion, 1);
         END;

         psclave := sclave;
         vpasexec := 3;
      ELSE   -- Hem fet una modificació
         IF formula.descripcion IS NULL
            OR formula.clave IS NULL
            OR formula.formula IS NULL THEN
            RAISE e_param_error;
         END IF;

         psclave := formula.clave;

         UPDATE sgt_formulas
            SET codigo = formula.codigo,
                descripcion = formula.descripcion,
                formula = formula.formula,
                cutili = formula.cutili,
                crastro = formula.crastro,
                cramo = formula.cramo
          WHERE clave = formula.clave;

         IF vformu <> formula.formula
            OR vcodi <> formula.codigo THEN
            FOR reg IN c_formpare LOOP
               UPDATE gfi_funciones
                  SET refresca = 1
                WHERE cformula = reg.codigo;
            END LOOP;

            UPDATE sgt_term_form
               SET termino = formula.codigo,
                   tdesc = formula.descripcion
             WHERE termino = vcodi;
         END IF;

         vpasexec := 4;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         UPDATE sgt_term_form
            SET tipo = 'F',
                origen = DECODE(formula.sumatorio, 1, 5, 1),
                tdesc = formula.descripcion,
                operador = 1
          WHERE termino = formula.codigo;

         RETURN 1;
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         -- PAC_IOBJ_MENSAJES.CREA_NUEVO_MENSAJE(MENSAJES,1,103869);
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         -- raise e_param_error;
         RETURN 1;
   END f_grabarformula;

   /***********************************************************************
      Recupera el node anterior al que es vol consultar
      param in  ptree     : objecte arbre
      param in  pindex    : index actual
      param out mensajes  : mensajes de error
      return              : objeto nodo arbol
   ***********************************************************************/
   FUNCTION f_get_nodeanterior(
      ptree IN t_iax_gfitree,
      pindex IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_gfitree IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_GFI.F_Get_NodeAnterior';
      node           ob_iax_gfitree := NULL;
   BEGIN
      FOR i IN ptree.FIRST .. ptree.LAST LOOP
         IF ptree.EXISTS(i) THEN
            IF i = pindex THEN
               EXIT;
            END IF;

            node := ptree(i);
         END IF;
      END LOOP;

      RETURN node;
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
   END f_get_nodeanterior;

   /***********************************************************************
      Recupera el node anterior al que es vol consultar
      param in  ptree     : objecte arbre
      param in  pindex    : index actual
      param in  pnivell   : nivel del nodo
      param out mensajes  : mensajes de error
      return              : objeto nodo arbol
   ***********************************************************************/
   FUNCTION f_get_nodeanteriornivell(
      ptree IN t_iax_gfitree,
      pindex IN NUMBER,
      pnivell IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_gfitree IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_GFI.F_Get_NodeAnteriorNivell';
      node           ob_iax_gfitree := NULL;
      nod            ob_iax_gfitree := NULL;
   BEGIN
      FOR i IN REVERSE ptree.FIRST .. pindex LOOP
         IF ptree.EXISTS(i) THEN
            nod := ptree(i);

            IF nod.nivel = pnivell THEN
               node := nod;
               EXIT;
            END IF;
         END IF;
      END LOOP;

      RETURN node;
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
   END f_get_nodeanteriornivell;

   /***********************************************************************
      Monta el objeto con los nodos de las formulas
      param in  pcur      : cursor sentencia niveles formulas
      param out mensajes  : mensajes de error
      return              : objeto arbol
   ***********************************************************************/
   FUNCTION f_mounttree(pcur IN sys_refcursor, mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_gfitree IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_GFI.F_Mounttree';
      tree           t_iax_gfitree := t_iax_gfitree();
      nod            ob_iax_gfitree;
      vid            NUMBER;   -- Idenficador nodo
      vpadre         NUMBER;   -- Idenficador nodo padre
      vclave         NUMBER;   -- Clave de la formula
      vnivel         NUMBER;   -- Nivel
      vdescripcion   VARCHAR2(500);   -- Código formula
      vtipo          VARCHAR2(100);   -- Indicar que tipo icono a mostrar
      dummy          NUMBER;
      nivact         NUMBER := -1;
   BEGIN
      LOOP
         FETCH pcur
          INTO vid, dummy, vnivel, vdescripcion, vclave, vtipo;

         EXIT WHEN pcur%NOTFOUND;
         tree.EXTEND();
         tree(tree.LAST) := ob_iax_gfitree();
         tree(tree.LAST).idnode := vid;
         tree(tree.LAST).clave := vclave;
         tree(tree.LAST).nivel := vnivel;
         tree(tree.LAST).descripcion := vdescripcion;
         tree(tree.LAST).tipo := vtipo;
      END LOOP;

      CLOSE pcur;

      vpasexec := 2;

      IF tree IS NULL THEN
         RETURN NULL;
      END IF;

      IF tree.COUNT = 0 THEN
         RETURN NULL;
      END IF;

      vpasexec := 3;

      FOR i IN tree.FIRST .. tree.LAST LOOP
         vpasexec := 4;

         IF tree.EXISTS(i) THEN
            vpasexec := 5;

            IF tree(i).nivel > 1 THEN
               vpasexec := 6;

               IF nivact < tree(i).nivel THEN   --'<>
                  vpasexec := 7;
                  nivact := tree(i).nivel;
                  nod := f_get_nodeanterior(tree, i, mensajes);
                  vpasexec := 8;

                  IF nod IS NOT NULL THEN
                     vpasexec := 9;
                     tree(i).padre := nod.idnode;
                     nod := tree(i);
                  END IF;
               ELSIF nivact > tree(i).nivel THEN
                  vpasexec := 71;
                  nivact := tree(i).nivel;
                  nod := f_get_nodeanteriornivell(tree, i - 1, nivact, mensajes);
                  vpasexec := 8;

                  IF nod IS NOT NULL THEN
                     vpasexec := 9;
                     tree(i).padre := nod.padre;
                  END IF;
               ELSIF nivact = tree(i).nivel THEN
                  IF nod IS NOT NULL THEN
                     tree(i).padre := nod.padre;
                  END IF;
               END IF;
            ELSE
               nivact := -1;
               nod := NULL;
            END IF;
         END IF;
      END LOOP;

      RETURN tree;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF pcur%ISOPEN THEN
            CLOSE pcur;
         END IF;

         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF pcur%ISOPEN THEN
            CLOSE pcur;
         END IF;

         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF pcur%ISOPEN THEN
            CLOSE pcur;
         END IF;

         RETURN NULL;
   END f_mounttree;

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
      vobject        VARCHAR2(200) := 'PAC_MD_GFI.F_GET_LSTTIPOTERM';
      cur            sys_refcursor;
   BEGIN
      cur := pac_gfi.f_get_lsttipoterm(pac_md_common.f_get_cxtidioma);

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
      vobject        VARCHAR2(200) := 'PAC_MD_GFI.F_GET_LSTORIGEN';
      cur            sys_refcursor;
   BEGIN
      cur := pac_gfi.f_get_lstorigen();

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
      cur := pac_gfi.f_get_lstoperador(pac_md_common.f_get_cxtidioma);

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
      vobject        VARCHAR2(200) := 'PAC_MD_GFI.F_GET_TERMINOS';
      cur            sys_refcursor;
   BEGIN
      cur := pac_gfi.f_get_terminos(ptermino, ptipo, porigen, ptdesc, poperador,
                                    pac_md_common.f_get_cxtidioma);

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
      vobject        VARCHAR2(200) := 'PAC_MD_GFI.F_GET_TERMINO';
      cur            sys_refcursor;
   BEGIN
      cur := pac_gfi.f_get_termino(ptermino);

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
      num_err := pac_gfi.f_grabartermino(ptermino, ptipo, porigen, ptdesc, poperador, pisnew);

      IF num_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_param_error;
      END IF;

      RETURN num_err;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN -1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN -1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
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
      vobject        VARCHAR2(200) := 'PAC_MD_GFI.F_ELIMINARTERMINO';
      num_err        NUMBER;
   BEGIN
      num_err := pac_gfi.f_eliminartermino(ptermino);

      IF num_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_param_error;
      END IF;

      RETURN num_err;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN -1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN -1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
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
      cur := pac_gfi.f_get_termvigencias(ptermino);

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
      vobject        VARCHAR2(200) := 'PAC_MD_GFI.F_ELIMINARTERMVIGEN';
      num_err        NUMBER;
   BEGIN
      num_err := pac_gfi.f_eliminartermvigen(ptermino, pclave);

      IF num_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_param_error;
      END IF;

      RETURN num_err;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN -1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN -1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
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
      vobject        VARCHAR2(200) := 'PAC_MD_GFI.F_GET_TERMVIGENCIA';
      cur            sys_refcursor;
   BEGIN
      cur := pac_gfi.f_get_termvigencia(ptermino, pclave);

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
      num_err := pac_gfi.f_grabartermvig(ptermino, pclave, pfechaefe, pcvalor, isnew);

      IF num_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_param_error;
      END IF;

      RETURN num_err;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN -1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN -1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN -1;
   END f_grabartermvig;

      /*************************************************************************
      Recupera la lista de los tramos
        param in ptramo: Código de tramo
                 pconcepto: Concepto al que se aplica el tramo
        param out:  mensajes de salida
        return:  ref cursor
   *************************************************************************/
   FUNCTION f_consultram(ptramo IN NUMBER, pconcepto IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vr_cur         sys_refcursor;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(2000) := '';
      v_object       VARCHAR2(200) := 'PAC_MD_GFI.F_Consultram';
   BEGIN
      vr_cur := pac_gfi.f_consultram(ptramo, pconcepto);
      RETURN vr_cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF vr_cur%ISOPEN THEN
            CLOSE vr_cur;
         END IF;

         RETURN vr_cur;
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
      --Recuperación de la lista de los tramos
      vnumerr := pac_gfi.f_eliminartramo(ptramo);

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
      vobject        VARCHAR2(200) := 'PAC_MD_GFI.F_Get_Tramo';
   BEGIN
      --Recuperación de la información de los tramos
      vcursor := pac_gfi.f_get_tramo(ptramo);
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
      vobject        VARCHAR2(200) := 'PAC_MD_GFI.F_GrabarTramo';
      vnumerr        NUMBER;
   BEGIN
      --Comprovació pas de paràmetres
      IF ptramo IS NULL
         OR pconcepto IS NULL THEN
         RAISE e_param_error;
      END IF;

      --Recuperación de la lista de los tramos
      vnumerr := pac_gfi.f_grabartramo(ptramo, pconcepto, pcptfranja, pcptvalor, pisnuevo);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
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
      vobject        VARCHAR2(200) := 'PAC_MD_GFI.F_Get_VigTramos';
   BEGIN
      --Comprovació pas de paràmetres
      IF ptramo IS NULL THEN
         RAISE e_param_error;
      END IF;

      --Recuperación de la información de los tramos
      vcursor := pac_gfi.f_get_vigtramos(ptramo);
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
      vobject        VARCHAR2(200) := 'PAC_MD_GFI.F_Get_DetVigTramos';
   BEGIN
      --Comprovació pas de paràmetres
      IF pdetalletramo IS NULL THEN
         RAISE e_param_error;
      END IF;

      --Recuperación de la información de los tramos
      vcursor := pac_gfi.f_get_detvigtramos(pdetalletramo);
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

   /* Función que grava la información de los tramos.
      param in ptramo: código de tramo
               pfechaefecto: Fecha efecto tramo
               pdetalletramo: Detalle tramo
      return : NUMBER   :  1 indicando se ha producido un error
                           0 ha ido correctamente  */
   FUNCTION f_grabarvigtram(
      ptramo IN NUMBER,
      pfechaefecto IN DATE,
      pdetalletramo IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vcursor        sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_GFI.F_GrabarVigTram';
      vnumerr        NUMBER;
   BEGIN
      --Comprovació pas de paràmetres
      --IF ptramo IS NULL OR
      --    pfechaefecto IS NULL THEN
      --       RAISE e_param_error;
      -- IF;

      --Recuperación de la lista de los tramos
      vnumerr := pac_gfi.f_grabarvigtram(ptramo, pfechaefecto, pdetalletramo);

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
              pdesde:        Fecha desde
              phasta:        Fecha hasta
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
      vcursor        sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_GFI.F_GrabarDetVigTram';
      vnumerr        NUMBER;
   BEGIN
      --Comprovació pas de paràmetres
      IF pdetalletramo IS NULL
         OR pdesde IS NULL
         OR phasta IS NULL
         OR pvalor IS NULL THEN
         RAISE e_param_error;
      END IF;

      --Recuperación de la lista de los tramos
      vnumerr := pac_gfi.f_grabardetvigtram(pdetalletramo, porden, pdesde, phasta, pvalor);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
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
      vobject        VARCHAR2(200) := 'PAC_MD_GFI.F_EliminarVigencia';
      vnumerr        NUMBER;
   BEGIN
      --Comprovació pas de paràmetres
      IF ptramo IS NULL
         OR pdetalletramo IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_gfi.f_eliminarvigencia(ptramo, pdetalletramo);

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
      vobject        VARCHAR2(200) := 'PAC_MD_GFI.F_EliminarDetVigencia';
      vnumerr        NUMBER;
   BEGIN
      --Comprovació pas de paràmetres
      IF pdetalletramo IS NULL
         OR porden IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_gfi.f_eliminardetvigencia(pdetalletramo, porden);

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
      vobject        VARCHAR2(200) := 'PAC_MD_GFI.F_ConsultBucle';
   BEGIN
      --Comprovació pas de paràmetres
      --IF ptermino IS NULL OR
      --  pniterac IS NULL OR
      --  poperacion IS NULL THEN
      --   RAISE e_param_error;
      --END IF;

      --Recuperación de la lista de bucles
      vcursor := pac_gfi.f_consultbucle(ptermino, pniterac, poperacion);
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
      vobject        VARCHAR2(200) := 'PAC_MD_GFI.F_EliminarBucle';
      vnumerr        NUMBER;
   BEGIN
      --Comprovació pas de paràmetres
      IF ptermino IS NULL THEN
         RAISE e_param_error;
      END IF;

      --Recuperación de la lista de los bucles
      vnumerr := pac_gfi.f_eliminarbucle(ptermino);

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
      vobject        VARCHAR2(200) := 'PAC_MD_GFI.F_Get_LstOperacion';
   BEGIN
      --Recuperació la lista de operacion para el bucle
      vcursor := pac_gfi.f_get_lstoperacion;
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
      vobject        VARCHAR2(200) := 'PAC_MD_GFI.F_GrabarBucle';
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
      vnumerr := pac_gfi.f_grabarbucle(ptermino, pniterac, poperacion, isnew);

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

   /* Función que recupera los parámetros para poder evaluar una fórmula.
   param in pclave: Clave fórmula
   param out:  psession: Código único de sesión
               mensajes: Mensajes de salida
   return              : T_IAX_GFIPARAMTRANS   :  Objeto con los parámetros de evaluación.*/
   FUNCTION f_get_paramtrans(pclave IN NUMBER, psession OUT NUMBER, mensajes OUT t_iax_mensajes)
      RETURN t_iax_gfiparamtrans IS
      vcur           sys_refcursor;
      vparametro     VARCHAR2(50);
      param          t_iax_gfiparamtrans;
      ses            NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_GFI.F_Get_Paramtrans';
   BEGIN
      vcur := pac_gfi.f_get_paramtrans(pclave, ses);
      param := t_iax_gfiparamtrans();
      param.EXTEND();
      param(param.LAST) := ob_iax_gfiparamtrans();
      param(param.LAST).sesion := ses;
      param(param.LAST).parametro := 'SESION';
      param(param.LAST).valor := ses;

      --la variable vcur es la devuelta por PAC_GFI.f_get_paramtrans
      LOOP
         FETCH vcur
          INTO vparametro;

         EXIT WHEN vcur%NOTFOUND;
         param.EXTEND();
         param(param.LAST) := ob_iax_gfiparamtrans();
         param(param.LAST).sesion := ses;
         param(param.LAST).parametro := vparametro;
      END LOOP;
   EXCEPTION
      WHEN e_param_error THEN
         IF vcur%ISOPEN THEN
            CLOSE vcur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN param;
      WHEN OTHERS THEN
         IF vcur%ISOPEN THEN
            CLOSE vcur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN param;
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
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MDI_GFI.F_GrabarParamtrans';
      vnumerr        NUMBER;
   BEGIN
      --Graba la información de los parámetros
      vnumerr := pac_gfi.f_grabarparamtrans(psession, pparamact, pparampos, pvalor);

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
      vobject        VARCHAR2(200) := 'PAC_MDI_GFI.F_EliminarParamtrans';
      vnumerr        NUMBER;
   BEGIN
      --Elimina la información de los parámetros
      vnumerr := pac_gfi.f_eliminarparamtrans(psession, pparam);

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
      vobject        VARCHAR2(200) := 'PAC_GFI.F_Evaluar';
      vnumerr        NUMBER;
      valor          NUMBER;
      codigo         NUMBER;
      vmsj           VARCHAR2(2000) := NULL;
      pformula       VARCHAR2(2000) := NULL;
   BEGIN
      --Comprovació pas de paràmetres
      IF psession IS NULL THEN
         RAISE e_param_error;
      END IF;

      --Evalua el resultado de la fórmula
      valor := pac_gfi.f_evaluar(psession, pclave, pdebug, pformula);

      IF valor IS NOT NULL THEN
--         pac_iobj_mensajes.crea_nuevo_mensaje_var
--                                    (mensajes, 2, 1000502,
--                                     pac_iobj_mensajes.crea_variables_mensaje(codigo || '#'
--                                                                              || TO_CHAR
--                                                                                        (valor),
--                                                                              1));
         NULL;
      ELSE
         vmsj := pac_iobj_mensajes.f_get_descmensaje(108378, pac_md_common.f_get_cxtidioma);
         vmsj := vmsj || ' ' || SUBSTR(pformula, 1, 200);
         pac_iobj_mensajes.crea_nuevo_mensaje_var(mensajes, 1, 108378, vmsj);
         RAISE e_object_error;
      END IF;

      --Todo ok
      RETURN valor;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
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
      vobject        VARCHAR2(200) := 'PAC_MD_GFI.F_Get_Source';
   BEGIN
      --Recuperación del código de una fórmula.
      vcursor := pac_gfi.f_get_source(pclave);
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
      vobject        VARCHAR2(200) := 'PAC_MD_GFI.F_Get_Lstfprocesos';
   BEGIN
      --Recuperación la lista de procesos
      -- vcursor := PAC_GFI.F_Get_Lstfprocesos(pac_md_common.f_get_cxtidioma);

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

   /* Función que recupera la lista de refresco
      param out:  mensajes: mensajes de error
      return:  ref cursor  */
   FUNCTION f_get_lstfrefrescar(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vcursor        sys_refcursor;
      vnumerr        NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_GFI.F_Get_Lstfrefrescar';
   BEGIN
      --Recuperación la lista de refresco
      -- vcursor := PAC_GFI.F_Get_Lstfrefrescar(pac_md_common.f_get_cxtidioma);

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
      vobject        VARCHAR2(200) := 'PAC_MD_GFI.F_Get_Funciones';
   BEGIN
      --Recuperación la lista de procesos
      -- vcursor := PAC_GFI.F_Get_Funciones(pclave, pformula, ptproceso, prefresca);

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
      vobject        VARCHAR2(200) := 'PAC_MD_GFI.F_GrabarFuncion';
      vnumerr        NUMBER;
   BEGIN
      --Graba la información de los parámetros
      --vnumerr := PAC_GFI.F_GrabarFuncion(pcclave, pcformula, ptproceso, prefrescar);
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
      vobject        VARCHAR2(200) := 'PAC_MD_GFI.F_Crea_Funcion';
      vnumerr        NUMBER;
   BEGIN
      --Genera la fórmula determinada en la base de datos
      vnumerr := pac_gfi.f_crea_func(pcodigo, pcomenta);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      --Todo ok
      RETURN 0;
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
      terrors        t_iax_gfierrores := t_iax_gfierrores();
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'pformula=' || pformula;
      vobject        VARCHAR2(200) := 'PAC_MD_GFI.F_CheckFormula';
      nerrs          NUMBER;
      vformula       VARCHAR2(2000);
   BEGIN
      vformula := pformula;
      nerrs := pk_formulas.search_string(vformula, 'P', 1);

      IF nerrs > 0 THEN
         FOR i IN 1 .. nerrs LOOP
            IF terrors IS NULL THEN
               terrors := t_iax_gfierrores();
            END IF;

            terrors.EXTEND;
            terrors(terrors.LAST) := ob_iax_gfierrores();
            terrors(terrors.LAST).numerr := i;

            BEGIN
               terrors(terrors.LAST).texterror := pk_formulas.get_terrs(i);
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;
         END LOOP;
      END IF;

      --Tot ok
      RETURN terrors;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN NULL;
   END f_checkformula;

   /*************************************************************************
    FUNCTION f_tramo
         Funci� que retorna valor tram
         param in pnsesion  : Sesio
         param in pfecha  : Data
         param in pntramo  : Tram
         param in pbuscar : Valor a trobar
         param out: mensajes:  mensajes de salida
         return             : 0 -> Tot correcte
   *************************************************************************/
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
      vobject        VARCHAR2(200) := 'PAC_MD_GFI.F_tramo';
   BEGIN
      valor := pac_gfi.f_tramo(pnsesion, pfecha, pntramo, pbuscar);

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
      pparametros IN t_iax_gfiparamvalor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      valor          NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'pclave=' || pclave;
      vobject        VARCHAR2(200) := 'PAC_MD_GFI.f_evaluar_formula';
      vsseguro       NUMBER;
      param          VARCHAR2(500);
   BEGIN
      valor := pac_sgt.del(pnsesion);
      valor := pac_sgt.put(pnsesion, 'FECHA', TO_CHAR(f_sysdate, 'YYYYMMDD'));   --Siempre lo informamos por si acaso
      valor := pac_sgt.put(pnsesion, 'FECEFE', TO_CHAR(f_sysdate, 'YYYYMMDD'));   --Siempre lo informamos por si acaso

      IF pparametros IS NOT NULL THEN
         IF pparametros.COUNT > 0 THEN
            FOR i IN pparametros.FIRST .. pparametros.LAST LOOP
               IF pparametros(i).ctipo = 1 THEN
                  valor := pac_sgt.put(pnsesion, 'RESP' || pparametros(i).tnombre,
                                       pparametros(i).valor);
               ELSIF pparametros(i).ctipo = 2 THEN
                  valor := pac_sgt.put(pnsesion, pparametros(i).tnombre, pparametros(i).valor);
               END IF;

               IF pparametros(i).tnombre = 'SSEGURO' THEN
                  vsseguro := pparametros(i).valor;
               END IF;
            END LOOP;
         END IF;
      END IF;

      FOR reg IN (SELECT cgarant, nriesgo, itarifa, icapital, ipritar, iprianu
                    FROM garanseg
                   WHERE sseguro = vsseguro
                  UNION
                  SELECT cgarant, nriesgo, itarifa, icapital, ipritar, iprianu
                    FROM estgaranseg
                   WHERE sseguro = vsseguro
                     AND cobliga = 1) LOOP
         param := 'CAP-' || reg.nriesgo || '-' || reg.cgarant;
         valor := pac_sgt.put(pnsesion, param, reg.icapital);
         param := 'IPRIPUR-' || reg.nriesgo || '-' || reg.cgarant;
         valor := pac_sgt.put(pnsesion, param, reg.icapital * NVL(reg.itarifa, 0));
         param := 'IPRITAR-' || reg.nriesgo || '-' || reg.cgarant;
         valor := pac_sgt.put(pnsesion, param, reg.ipritar);
         param := 'IPRIANU-' || reg.nriesgo || '-' || reg.cgarant;
         valor := pac_sgt.put(pnsesion, param, reg.iprianu);
         param := 'GAR_CONTRATADA-' || reg.nriesgo || '-' || reg.cgarant;
         valor := pac_sgt.put(pnsesion, param, 1);
      END LOOP;

      vpasexec := 2;
      valor := pac_md_gfi.f_evaluar(pnsesion, pclave, pdebug, mensajes);

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
END pac_md_gfi;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_GFI" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_GFI" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_GFI" TO "PROGRAMADORESCSI";
